package com.example.healthy_life

import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Debug
import android.os.SystemClock
import android.provider.OpenableColumns
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.net.InetSocketAddress
import java.net.Socket
import java.security.MessageDigest
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val securityChannelName = "hf.sec.guard"
    private val videoExportChannelName = "hf.video.export"
    private val overlayAssetsChannelName = "hf.overlay.assets"
    private val svgPickerRequestCode = 4107
    private var pendingSvgPickerResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "runtimeInfo" -> result.success(runtimeInfo())
                    "systemUptimeMs" -> result.success(SystemClock.elapsedRealtime())
                    else -> result.notImplemented()
                }
            }

        val videoExportChannel = WorkoutVideoExportChannel(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, videoExportChannelName)
            .setMethodCallHandler { call, result ->
                if (!videoExportChannel.handle(call, result)) {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, overlayAssetsChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickSvgFile" -> {
                        if (pendingSvgPickerResult != null) {
                            result.error(
                                "SVG_PICK_BUSY",
                                "Another SVG picker request is already active.",
                                null,
                            )
                            return@setMethodCallHandler
                        }
                        pendingSvgPickerResult = result
                        launchSvgPicker()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Uses Activity result callback for FlutterActivity compatibility.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != svgPickerRequestCode) {
            return
        }

        val result = pendingSvgPickerResult ?: return
        pendingSvgPickerResult = null

        if (resultCode != RESULT_OK) {
            result.success(null)
            return
        }

        val uri = data?.data
        if (uri == null) {
            result.success(null)
            return
        }

        runCatching {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        }

        runCatching {
            val cachedFile = cacheSvgSelection(uri)
            mapOf(
                "path" to cachedFile.absolutePath,
                "name" to queryDisplayName(uri).ifBlank { cachedFile.name },
            )
        }.onSuccess { payload ->
            result.success(payload)
        }.onFailure { error ->
            result.error(
                "SVG_PICK_FAILED",
                error.message ?: "Unable to import selected SVG file.",
                null,
            )
        }
    }

    private fun launchSvgPicker() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "image/svg+xml"
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("image/svg+xml"))
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        }
        startActivityForResult(intent, svgPickerRequestCode)
    }

    private fun cacheSvgSelection(uri: Uri): File {
        val inputStream = contentResolver.openInputStream(uri)
            ?: error("Unable to read the selected SVG file.")
        val targetFile = File(
            cacheDir,
            "overlay_svg_${System.currentTimeMillis()}.svg",
        )
        inputStream.use { input ->
            FileOutputStream(targetFile).use { output ->
                input.copyTo(output)
            }
        }
        return targetFile
    }

    private fun queryDisplayName(uri: Uri): String {
        val fallback = uri.lastPathSegment ?: ""
        return runCatching {
            contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null,
            )?.use { cursor ->
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0 && cursor.moveToFirst()) {
                    cursor.getString(index) ?: fallback
                } else {
                    fallback
                }
            } ?: fallback
        }.getOrDefault(fallback)
    }

    private fun runtimeInfo(): Map<String, Any?> {
        val installer = installerPackageName()
        return mapOf(
            "platform" to "android",
            "packageName" to packageName,
            "signatureSha256" to signingCertSha256(),
            "debuggable" to isDebuggableBuild(),
            "debuggerConnected" to Debug.isDebuggerConnected(),
            "installer" to installer,
            "emulator" to isProbablyEmulator(),
            "rooted" to isProbablyRooted(),
            "virtualSpace" to isProbablyVirtualSpace(installer),
            "hookDetected" to isHookingDetected(),
        )
    }

    private fun signingCertSha256(): String? {
        return try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES,
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            }

            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                packageInfo.signatures
            }

            val first = signatures?.firstOrNull() ?: return null
            val digest = MessageDigest.getInstance("SHA-256").digest(first.toByteArray())
            digest.joinToString("") { byte -> "%02X".format(byte) }
        } catch (_: Exception) {
            null
        }
    }

    private fun isDebuggableBuild(): Boolean {
        return (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    private fun installerPackageName(): String {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                packageManager.getInstallSourceInfo(packageName).installingPackageName ?: ""
            } else {
                @Suppress("DEPRECATION")
                packageManager.getInstallerPackageName(packageName) ?: ""
            }
        } catch (_: Exception) {
            ""
        }
    }

    private fun isProbablyEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT ?: ""
        val model = Build.MODEL ?: ""
        val manufacturer = Build.MANUFACTURER ?: ""
        val brand = Build.BRAND ?: ""
        val device = Build.DEVICE ?: ""
        val product = Build.PRODUCT ?: ""
        val hardware = Build.HARDWARE ?: ""

        if (fingerprint.startsWith("generic") ||
            fingerprint.startsWith("unknown") ||
            fingerprint.contains("emulator", ignoreCase = true) ||
            fingerprint.contains("sdk_gphone", ignoreCase = true)
        ) return true

        if (model.contains("google_sdk", ignoreCase = true) ||
            model.contains("emulator", ignoreCase = true) ||
            model.contains("android sdk built for x86", ignoreCase = true)
        ) return true

        if (manufacturer.contains("genymotion", ignoreCase = true)) return true

        if (brand.startsWith("generic", ignoreCase = true) &&
            device.startsWith("generic", ignoreCase = true)
        ) return true

        if (product.contains("sdk", ignoreCase = true) ||
            product.contains("emulator", ignoreCase = true) ||
            product.contains("simulator", ignoreCase = true)
        ) return true

        if (hardware.contains("goldfish", ignoreCase = true) ||
            hardware.contains("ranchu", ignoreCase = true) ||
            hardware.contains("vbox86", ignoreCase = true)
        ) return true

        return readSystemProperty("ro.kernel.qemu") == "1"
    }

    private fun readSystemProperty(key: String): String {
        return try {
            val clazz = Class.forName("android.os.SystemProperties")
            val get = clazz.getMethod("get", String::class.java)
            (get.invoke(null, key) as? String) ?: ""
        } catch (_: Exception) {
            ""
        }
    }

    private fun isProbablyRooted(): Boolean {
        val tags = Build.TAGS ?: ""
        if (tags.contains("test-keys")) return true

        val suPaths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/data/local/bin/su",
            "/data/local/xbin/su",
            "/su/bin/su",
        )
        if (suPaths.any { path -> File(path).exists() }) return true

        return canExecuteSuQuickCheck()
    }

    private fun canExecuteSuQuickCheck(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("su", "-c", "id"))
            val finished = process.waitFor(180, TimeUnit.MILLISECONDS)
            if (!finished) {
                process.destroy()
                false
            } else {
                process.exitValue() == 0
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun isHookingDetected(): Boolean {
        // Lightweight signals only (no extra permissions).
        if (isLocalFridaPortOpen()) return true
        if (containsSuspiciousMarkersInProcMaps()) return true
        return false
    }

    private fun isLocalFridaPortOpen(): Boolean {
        val ports = intArrayOf(27042, 27043)
        for (port in ports) {
            try {
                Socket().use { socket ->
                    socket.connect(InetSocketAddress("127.0.0.1", port), 60)
                    return true
                }
            } catch (_: Exception) {
                // ignore
            }
        }
        return false
    }

    private fun containsSuspiciousMarkersInProcMaps(): Boolean {
        return try {
            val maps = File("/proc/self/maps")
            if (!maps.exists()) return false
            val content = maps.readText()
            val needles = listOf(
                "frida",
                "gum-js-loop",
                "gadget",
                "xposed",
                "substrate",
                "zygisk",
                "riru",
            )
            needles.any { needle -> content.contains(needle, ignoreCase = true) }
        } catch (_: Exception) {
            false
        }
    }

    private fun isProbablyVirtualSpace(installer: String): Boolean {
        val sourceDir = applicationInfo.sourceDir ?: ""
        val dataDir = applicationInfo.dataDir ?: ""

        val containerMarkers = listOf(
            "com.lbe.parallel",
            "com.parallel.space",
            "com.excelliance.dualaid",
            "com.applisto.appcloner",
            "com.cloneapp",
            "com.dualspace",
        )

        if (containerMarkers.any { marker ->
                sourceDir.contains(marker, ignoreCase = true) ||
                    dataDir.contains(marker, ignoreCase = true)
            }) {
            return true
        }

        val suspiciousInstallers = listOf(
            "com.lbe.parallel",
            "com.parallel.space",
            "com.excelliance.dualaid",
            "com.applisto.appcloner",
            "com.cloneapp",
            "com.chelpus.lackypatch",
            "com.dimonvideo.luckypatcher",
        )

        if (installer.isNotEmpty() && suspiciousInstallers.any { it.equals(installer, ignoreCase = true) }) {
            return true
        }

        return false
    }
}
