package com.example.healthy_life

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorMatrix
import android.graphics.ColorMatrixColorFilter
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Picture
import android.graphics.PorterDuff
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.SweepGradient
import android.graphics.Typeface
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.media.MediaMetadataRetriever
import android.media.MediaFormat
import androidx.media3.common.Effect
import androidx.media3.common.MediaItem
import androidx.media3.common.audio.AudioProcessor
import androidx.media3.common.util.UnstableApi
import androidx.media3.transformer.DefaultEncoderFactory
import androidx.media3.effect.CanvasOverlay
import androidx.media3.effect.OverlayEffect
import androidx.media3.effect.Presentation
import androidx.media3.transformer.Composition
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.Transformer
import androidx.media3.transformer.VideoEncoderSettings
import com.caverock.androidsvg.SVG
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.max
import kotlin.math.min
import kotlin.math.roundToInt

@UnstableApi
class WorkoutVideoExportChannel(
    private val appContext: Context,
) {
    private val shortVideoAspectRatio = 9f / 16f
    private val targetVideoWidth = 1080
    private val targetVideoHeight = 1920
    private val targetVideoBitrate = 16_000_000
    private val minAcceptableVideoBitrate = 8_000_000L
    private val mainHandler = Handler(Looper.getMainLooper())
    private val svgPictureCache = mutableMapOf<String, Picture?>()

    fun handle(call: MethodCall, result: MethodChannel.Result): Boolean {
        if (call.method != "exportWorkoutVideo") {
            return false
        }

        val rawVideoPath = call.argument<String>("rawVideoPath")
        if (rawVideoPath.isNullOrBlank()) {
            result.error("VIDEO_EXPORT_ARGS", "Missing rawVideoPath.", null)
            return true
        }

        val inputFile = File(rawVideoPath)
        if (!inputFile.exists()) {
            result.error(
                "VIDEO_EXPORT_INPUT",
                "Input video does not exist: $rawVideoPath",
                null,
            )
            return true
        }

        val samples = parseSamples(call.argument<List<*>>("samples"))
        val visualConfig = parseVisualConfig(call)
        val outputFile = File(
            appContext.cacheDir,
            "workout_overlay_${System.currentTimeMillis()}.mp4",
        )
        if (outputFile.exists()) {
            outputFile.delete()
        }

        exportVideo(
            inputFile = inputFile,
            outputFile = outputFile,
            samples = samples,
            visualConfig = visualConfig,
            result = result,
        )
        return true
    }

    private fun parseVisualConfig(call: MethodCall): OverlayVisualConfig {
        return OverlayVisualConfig(
            iconicProgram = normalizeIconicProgram(call.argument<String>("iconicProgram")),
            zodiacSignKey = call.argument<String>("zodiacSignKey").orEmpty().ifBlank { "aries" },
            overlayTitle = call.argument<String>("overlayTitle")?.trim()?.takeIf { it.isNotEmpty() },
            customOverlay = parseCustomOverlayConfig(call.argument<Map<*, *>>("overlayCustomization")),
            worldFestivalTheme = parseWorldFestivalTheme(call.argument<Map<*, *>>("worldFestivalTheme")),
        )
    }

private fun normalizeIconicProgram(raw: String?): String {
        return when (raw?.trim()?.lowercase(Locale.US)) {
            "zodiac" -> "zodiac"
            "worldfestival", "world_festival" -> "world_festival"
            "profession_hobby" -> "profession_hobby"
            "luxury_overlay_studio" -> "luxury_overlay_studio"
            else -> "none"
        }
    }

    private fun parseSamples(rawSamples: List<*>?): List<OverlaySample> {
        val parsed = rawSamples
            ?.mapNotNull { item ->
                val sample = item as? Map<*, *> ?: return@mapNotNull null
                val offsetMs = (sample["offsetMs"] as? Number)?.toLong() ?: 0L
                val repCount = (sample["repCount"] as? Number)?.toInt() ?: 0
                val accuracy = (sample["accuracy"] as? Number)?.toFloat() ?: 0f
                val phase = (sample["phase"] as? String)?.trim()?.lowercase(Locale.US).orEmpty()
                OverlaySample(
                    offsetMs = max(0L, offsetMs),
                    repCount = max(0, repCount),
                    accuracy = accuracy.coerceIn(0f, 1f),
                    phase = when (phase) {
                        "up", "down", "hold" -> phase
                        else -> "idle"
                    },
                )
            }
            ?.sortedBy { it.offsetMs }
            .orEmpty()

        return if (parsed.isEmpty()) {
            listOf(OverlaySample(offsetMs = 0L, repCount = 0, accuracy = 0f, phase = "idle"))
        } else {
            parsed
        }
    }

    private fun exportVideo(
        inputFile: File,
        outputFile: File,
        samples: List<OverlaySample>,
        visualConfig: OverlayVisualConfig,
        result: MethodChannel.Result,
    ) {
        val responded = AtomicBoolean(false)
        val overlay = WorkoutCanvasOverlay(WorkoutOverlayTimeline(samples), visualConfig, svgPictureCache)
        val editedMediaItem = EditedMediaItem.Builder(
            MediaItem.fromUri(Uri.fromFile(inputFile)),
        ).setEffects(
            Effects(
                emptyList<AudioProcessor>(),
                listOf<Effect>(
                    Presentation.createForWidthAndHeight(
                        targetVideoWidth,
                        targetVideoHeight,
                        Presentation.LAYOUT_SCALE_TO_FIT_WITH_CROP,
                    ),
                    OverlayEffect(listOf(overlay)),
                ),
            ),
        ).build()

        val listener = object : Transformer.Listener {
            override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                val qualityError = validateExportQuality(
                    inputFile = inputFile,
                    outputFile = outputFile,
                )
                if (qualityError != null) {
                    outputFile.delete()
                    if (responded.compareAndSet(false, true)) {
                        mainHandler.post {
                            result.error(
                                "VIDEO_EXPORT_QUALITY",
                                qualityError,
                                null,
                            )
                        }
                    }
                    return
                }
                if (responded.compareAndSet(false, true)) {
                    mainHandler.post {
                        result.success(
                            mapOf(
                                "outputPath" to outputFile.absolutePath,
                            ),
                        )
                    }
                }
            }

            override fun onError(
                composition: Composition,
                exportResult: ExportResult,
                exportException: ExportException,
            ) {
                outputFile.delete()
                if (responded.compareAndSet(false, true)) {
                    mainHandler.post {
                        result.error(
                            "VIDEO_EXPORT_FAILED",
                            exportException.message ?: "Native Android export failed.",
                            exportException.stackTraceToString(),
                        )
                    }
                }
            }
        }

        try {
            val requestedVideoSettings = VideoEncoderSettings.Builder()
                .setBitrate(targetVideoBitrate)
                .build()
            val encoderFactory = DefaultEncoderFactory.Builder(appContext)
                .setRequestedVideoEncoderSettings(requestedVideoSettings)
                .setEnableFallback(true)
                .build()
            Transformer.Builder(appContext)
                .setVideoMimeType(MediaFormat.MIMETYPE_VIDEO_AVC)
                .setPortraitEncodingEnabled(true)
                .setEncoderFactory(encoderFactory)
                .addListener(listener)
                .build()
                .start(editedMediaItem, outputFile.absolutePath)
        } catch (error: Exception) {
            outputFile.delete()
            if (responded.compareAndSet(false, true)) {
                mainHandler.post {
                    result.error(
                        "VIDEO_EXPORT_START_FAILED",
                        error.message ?: "Failed to start native Android export.",
                        error.stackTraceToString(),
                    )
                }
            }
        }
    }

    private fun validateExportQuality(
        inputFile: File,
        outputFile: File,
    ): String? {
        if (!outputFile.exists() || outputFile.length() <= 0L) {
            return "Exported video file is empty."
        }

        val inputMetadata = readVideoMetadata(inputFile) ?: return null
        val outputMetadata = readVideoMetadata(outputFile)
            ?: return "Unable to inspect exported video quality."

        if (outputMetadata.width <= 0 || outputMetadata.height <= 0) {
            return "Exported video has invalid resolution."
        }

        val outputAspectRatio =
            outputMetadata.displayWidth.toFloat() / outputMetadata.displayHeight.toFloat()
        if (abs(outputAspectRatio - shortVideoAspectRatio) > 0.03f) {
            return "Exported video is not using the short-video 9:16 frame."
        }

        if (inputMetadata.longestEdge >= 1280 &&
            outputMetadata.longestEdge < 1080
        ) {
            return "Exported video dropped too far below HD resolution."
        }

        if (outputMetadata.bitrate > 0L) {
            val inputScaledFloor =
                if (inputMetadata.bitrate > 0L) (inputMetadata.bitrate * 0.60f).toLong() else 0L
            val bitrateFloor = max(minAcceptableVideoBitrate, inputScaledFloor)
            if (outputMetadata.bitrate < bitrateFloor) {
                return "Exported video bitrate is too low compared with the original recording."
            }
        }

        if (outputMetadata.longestEdge < (inputMetadata.longestEdge * 0.75f).toInt() ||
            outputMetadata.shortestEdge < (inputMetadata.shortestEdge * 0.75f).toInt()
        ) {
            return "Exported video resolution is too low compared with the original recording."
        }

        return null
    }

    private fun readVideoMetadata(file: File): VideoMetadata? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(file.absolutePath)
            val width =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                    ?.toIntOrNull() ?: return null
            val height =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                    ?.toIntOrNull() ?: return null
            val rotation =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION)
                    ?.toIntOrNull() ?: 0
            val bitrate =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
                    ?.toLongOrNull() ?: 0L
            VideoMetadata(
                width = width,
                height = height,
                bitrate = bitrate,
                rotationDegrees = rotation,
            )
        } catch (_: Exception) {
            null
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun parseCustomOverlayConfig(raw: Map<*, *>?): CustomOverlayConfig {
        val paletteMap = raw?.get("palette") as? Map<*, *>
        val iconsMap = raw?.get("icons") as? Map<*, *>
        val narrativeMap = raw?.get("narrative") as? Map<*, *>
        val repCounterMap = raw?.get("repCounter") as? Map<*, *>
        val accuracyBarMap = raw?.get("accuracyBar") as? Map<*, *>
        val layoutMap = raw?.get("layout") as? Map<*, *>
        val finishMap = raw?.get("finish") as? Map<*, *>

        return CustomOverlayConfig(
            customModeEnabled = raw.boolean("customModeEnabled", false),
            performanceMode = raw.string("performanceMode", "auto"),
            title = raw.string("title", "Pulse Atelier"),
            subtitle = raw.string("subtitle", "Luxury motion overlay"),
            brandingText = raw.string("brandingText", "H&F Signature"),
            showBranding = raw.boolean("showBranding", true),
            palette = CustomOverlayPalette(
                primary = boostColor(paletteMap.color("primary", Color.rgb(17, 24, 39))),
                secondary = boostColor(paletteMap.color("secondary", Color.rgb(124, 92, 46))),
                accent = boostColor(paletteMap.color("accent", Color.rgb(243, 210, 138))),
                phaseUp = boostColor(paletteMap.color("phaseUp", Color.rgb(243, 210, 138))),
                phaseDown = boostColor(paletteMap.color("phaseDown", Color.rgb(218, 142, 82))),
                phaseHold = boostColor(paletteMap.color("phaseHold", Color.rgb(233, 238, 247))),
                surface = paletteMap.color("surface", Color.argb(204, 16, 24, 36)), // Keep surface/background as is
                textPrimary = boostColor(paletteMap.color("textPrimary", Color.rgb(249, 244, 232))),
                textSecondary = boostColor(paletteMap.color("textSecondary", Color.rgb(207, 213, 227))),
            ),
            icons = CustomOverlayIcons(
                autoSwitch = iconsMap.boolean("autoSwitch", true),
                defaultIcon = parseCustomOverlayIconSlot(
                    iconsMap?.get("default") as? Map<*, *>,
                    fallback = "◆",
                ),
                upIcon = parseCustomOverlayIconSlot(
                    iconsMap?.get("up") as? Map<*, *>,
                    fallback = "↑",
                ),
                downIcon = parseCustomOverlayIconSlot(
                    iconsMap?.get("down") as? Map<*, *>,
                    fallback = "↓",
                ),
                holdIcon = parseCustomOverlayIconSlot(
                    iconsMap?.get("hold") as? Map<*, *>,
                    fallback = "•",
                ),
            ),
            narrative = CustomOverlayNarrative(
                firstFlowText = narrativeMap.string("firstFlowText", ""),
                firstFlowRep = narrativeMap.int("firstFlowRep", 1).coerceIn(1, 999),
                firstFlowTextColor = narrativeMap.color("firstFlowTextColor", Color.rgb(249, 244, 232)),
                firstFlowTextColorSecondary = narrativeMap.color("firstFlowTextColorSecondary", Color.rgb(243, 210, 138)),
                secondFlowText = narrativeMap.string("secondFlowText", ""),
                secondFlowRep = narrativeMap.int("secondFlowRep", 3).coerceIn(1, 999),
                secondFlowTextColor = narrativeMap.color("secondFlowTextColor", Color.rgb(249, 244, 232)),
                secondFlowTextColorSecondary = narrativeMap.color("secondFlowTextColorSecondary", Color.rgb(243, 210, 138)),
                thirdFlowText = narrativeMap.string("thirdFlowText", ""),
                thirdFlowRep = narrativeMap.int("thirdFlowRep", 5).coerceIn(1, 999),
                thirdFlowTextColor = narrativeMap.color("thirdFlowTextColor", Color.rgb(249, 244, 232)),
                thirdFlowTextColorSecondary = narrativeMap.color("thirdFlowTextColorSecondary", Color.rgb(243, 210, 138)),
                fourthFlowText = narrativeMap.string("fourthFlowText", ""),
                fourthFlowRep = narrativeMap.int("fourthFlowRep", 7).coerceIn(1, 999),
                fourthFlowTextColor = narrativeMap.color("fourthFlowTextColor", Color.rgb(249, 244, 232)),
                fourthFlowTextColorSecondary = narrativeMap.color("fourthFlowTextColorSecondary", Color.rgb(243, 210, 138)),
            ),
            repCounter = CustomOverlayRepCounter(
                ringThickness = repCounterMap.float("ringThickness", 8f).coerceIn(4f, 16f),
                shape = repCounterMap.string("shape", "circle"),
                contourSoftness = repCounterMap.float("contourSoftness", 0.55f).coerceIn(0f, 1f),
                glowIntensity = repCounterMap.float("glowIntensity", 0.78f).coerceIn(0f, 1f),
                surfaceDepth = repCounterMap.float("surfaceDepth", 0.72f).coerceIn(0f, 1f),
                orbitIntensity = repCounterMap.float("orbitIntensity", 0.68f).coerceIn(0f, 1f),
                animationStyle = repCounterMap.string("animationStyle", "ripple"),
                scale = repCounterMap.float("scale", 1f).coerceIn(0.75f, 1.3f),
                opacity = repCounterMap.float("opacity", 0.97f).coerceIn(0.4f, 1f),
                show = repCounterMap.boolean("show", true),
            ),
            accuracyBar = CustomOverlayAccuracyBar(
                style = accuracyBarMap.string("style", "gradient"),
                styleIntensity = accuracyBarMap.float("styleIntensity", 0.62f).coerceIn(0f, 1f),
                showThresholdLine = accuracyBarMap.boolean("showThresholdLine", true),
                markerDensity = accuracyBarMap.float("markerDensity", 0.46f).coerceIn(0f, 1f),
                glowIntensity = accuracyBarMap.float("glowIntensity", 0.80f).coerceIn(0f, 1f),
                spillLength = accuracyBarMap.float("spillLength", 0.66f).coerceIn(0f, 1f),
                spillWidth = accuracyBarMap.float("spillWidth", 0.58f).coerceIn(0f, 1f),
                thresholdGlow = accuracyBarMap.float("thresholdGlow", 0.76f).coerceIn(0f, 1f),
                liquidMotion = accuracyBarMap.float("liquidMotion", 0.70f).coerceIn(0f, 1f),
                show = accuracyBarMap.boolean("show", true),
            ),
            layout = CustomOverlayLayout(
                bannerPosition = layoutMap.string("bannerPosition", "top"),
                statsCardPosition = layoutMap.string("statsCardPosition", "bottom"),
                globalScale = layoutMap.float("globalScale", 1f).coerceIn(0.8f, 1.2f),
                opacity = layoutMap.float("opacity", 0.96f).coerceIn(0.4f, 1f),
            ),
            finish = CustomOverlayFinish(
                vignetteStrength = finishMap.float("vignetteStrength", 0.34f).coerceIn(0f, 1f),
                bloomIntensity = finishMap.float("bloomIntensity", 0.42f).coerceIn(0f, 1f),
                sparkleDensity = finishMap.float("sparkleDensity", 0.28f).coerceIn(0f, 1f),
                sheenSweep = finishMap.float("sheenSweep", 0.36f).coerceIn(0f, 1f),
            ),
        )
    }

    private fun parseCustomOverlayIconSlot(
        raw: Map<*, *>?,
        fallback: String,
    ): CustomOverlayIconSlot {
        val glyph = raw.string("glyph", fallback).ifBlank { fallback }
        val svgPath = raw.string("svgPath", "").trim().takeIf { it.isNotEmpty() }
        return CustomOverlayIconSlot(
            glyph = glyph,
            svgPath = svgPath,
        )
    }

    private fun parseWorldFestivalTheme(raw: Map<*, *>?): WorldFestivalTheme? {
        raw ?: return null

        fun colorValue(key: String, fallback: Int): Int = when (val value = raw[key]) {
            is Number -> value.toInt()
            is String -> {
                val normalized = value.removePrefix("#")
                normalized.toLongOrNull(16)?.let {
                    if (normalized.length <= 6) {
                        (0xFF000000 or it).toInt()
                    } else {
                        it.toInt()
                    }
                } ?: fallback
            }
            else -> fallback
        }

        fun colorList(key: String, fallback: List<Int>): List<Int> {
            val rawList = raw[key] as? List<*> ?: return fallback
            val parsed = rawList.mapNotNull { item ->
                when (item) {
                    is Number -> item.toInt()
                    is String -> {
                        val normalized = item.removePrefix("#")
                        normalized.toLongOrNull(16)?.let {
                            if (normalized.length <= 6) {
                                (0xFF000000 or it).toInt()
                            } else {
                                it.toInt()
                            }
                        }
                    }
                    else -> null
                }
            }
            return if (parsed.isEmpty()) fallback else parsed
        }

        return WorldFestivalTheme(
            storageKey = (raw["storageKey"] as? String)?.trim().orEmpty(),
            themeName = (raw["themeName"] as? String)?.trim().orEmpty(),
            label = (raw["label"] as? String)?.trim().orEmpty(),
            subtitle = (raw["subtitle"] as? String)?.trim().orEmpty(),
            bannerIcon = (raw["bannerIcon"] as? String)?.trim().orEmpty(),
            cornerIcon = (raw["cornerIcon"] as? String)?.trim().orEmpty(),
            watermarkIcon = (raw["watermarkIcon"] as? String)?.trim().orEmpty(),
            bannerTitle = (raw["bannerTitle"] as? String)?.trim().orEmpty(),
            variantId = (raw["variantId"] as? Number)?.toInt()?.coerceIn(0, 39) ?: 0,
            primaryStart = boostColor(colorValue("primaryStart", Color.rgb(16, 24, 36))),
            primaryEnd = boostColor(colorValue("primaryEnd", Color.rgb(67, 74, 110))),
            accent1 = boostColor(colorValue("accent1", Color.rgb(243, 210, 138))),
            accent2 = boostColor(colorValue("accent2", Color.rgb(233, 238, 247))),
            glowColor = boostColor(colorValue("glowColor", Color.rgb(243, 210, 138))),
            phaseUpColor = boostColor(colorValue("phaseUpColor", Color.rgb(243, 210, 138))),
            phaseDownColor = boostColor(colorValue("phaseDownColor", Color.rgb(218, 142, 82))),
            phaseHoldColor = boostColor(colorValue("phaseHoldColor", Color.rgb(233, 238, 247))),
            ringGradient = colorList(
                "ringGradient",
                listOf(
                    Color.rgb(17, 24, 39),
                    Color.rgb(124, 92, 46),
                    Color.rgb(243, 210, 138),
                    Color.rgb(17, 24, 39),
                ),
            ).map { boostColor(it) },
            accuracyBarGradient = colorList(
                "accuracyBarGradient",
                listOf(
                    Color.rgb(17, 24, 39),
                    Color.rgb(86, 99, 143),
                    Color.rgb(243, 210, 138),
                ),
            ).map { boostColor(it) },
            accuracyLowColor = boostColor(colorValue("accuracyLowColor", Color.rgb(166, 65, 73))),
            accuracyMidColor = boostColor(colorValue("accuracyMidColor", Color.rgb(117, 104, 178))),
            accuracyHighColor = boostColor(colorValue("accuracyHighColor", Color.rgb(243, 210, 138))),
            thresholdLineColor = colorValue("thresholdLineColor", Color.WHITE),
        )
    }
}

private fun boostColor(color: Int): Int {
    val hsv = FloatArray(3)
    Color.colorToHSV(color, hsv)
    // Increase saturation by ~22% (matching old global matrix setSaturation(1.22f))
    hsv[1] = (hsv[1] * 1.22f).coerceIn(0f, 1f)
    // Increase value/brightness by ~16% + offset (matching 1.16f multiplier + 0.04f offset)
    hsv[2] = ((hsv[2] * 1.16f) + 0.04f).coerceIn(0f, 1f)
    return Color.HSVToColor(Color.alpha(color), hsv)
}

private data class VideoMetadata(
    val width: Int,
    val height: Int,
    val bitrate: Long,
    val rotationDegrees: Int,
) {
    private val isQuarterTurn: Boolean
        get() = abs(rotationDegrees / 90) % 2 == 1

    val displayWidth: Int
        get() = if (isQuarterTurn) height else width

    val displayHeight: Int
        get() = if (isQuarterTurn) width else height

    val longestEdge: Int
        get() = max(displayWidth, displayHeight)

    val shortestEdge: Int
        get() = min(displayWidth, displayHeight)
}

private fun Map<*, *>?.string(key: String, fallback: String): String {
    return (this?.get(key) as? String)?.trim()?.takeIf { it.isNotEmpty() } ?: fallback
}

private fun Map<*, *>?.boolean(key: String, fallback: Boolean): Boolean {
    return this?.get(key) as? Boolean ?: fallback
}

private fun Map<*, *>?.float(key: String, fallback: Float): Float {
    val value = this?.get(key)
    return when (value) {
        is Number -> value.toFloat()
        is String -> value.toFloatOrNull() ?: fallback
        else -> fallback
    }
}

private fun Map<*, *>?.int(key: String, fallback: Int): Int {
    val value = this?.get(key)
    return when (value) {
        is Number -> value.toInt()
        is String -> value.toIntOrNull() ?: fallback
        else -> fallback
    }
}

private fun Map<*, *>?.color(key: String, fallback: Int): Int {
    val value = this?.get(key)
    return when (value) {
        is Number -> value.toInt()
        is String -> {
            val normalized = value.removePrefix("#")
            normalized.toLongOrNull(16)?.let {
                if (normalized.length <= 6) {
                    (0xFF000000 or it).toInt()
                } else {
                    it.toInt()
                }
            } ?: fallback
        }
        else -> fallback
    }
}

private data class OverlaySample(
    val offsetMs: Long,
    val repCount: Int,
    val accuracy: Float,
    val phase: String,
)

private data class OverlayState(
    val repCount: Int,
    val accuracy: Float,
    val phase: String,
)

private data class OverlayVisualConfig(
    val iconicProgram: String,
    val zodiacSignKey: String,
    val overlayTitle: String?,
    val customOverlay: CustomOverlayConfig,
    val worldFestivalTheme: WorldFestivalTheme?,
)

private data class CustomOverlayConfig(
    val customModeEnabled: Boolean,
    val performanceMode: String,
    val title: String,
    val subtitle: String,
    val brandingText: String,
    val showBranding: Boolean,
    val palette: CustomOverlayPalette,
    val icons: CustomOverlayIcons,
    val narrative: CustomOverlayNarrative,
    val repCounter: CustomOverlayRepCounter,
    val accuracyBar: CustomOverlayAccuracyBar,
    val layout: CustomOverlayLayout,
    val finish: CustomOverlayFinish,
)

private data class CustomOverlayPalette(
    val primary: Int,
    val secondary: Int,
    val accent: Int,
    val phaseUp: Int,
    val phaseDown: Int,
    val phaseHold: Int,
    val surface: Int,
    val textPrimary: Int,
    val textSecondary: Int,
)

private data class CustomOverlayIconSlot(
    val glyph: String,
    val svgPath: String?,
)

private data class CustomOverlayIcons(
    val autoSwitch: Boolean,
    val defaultIcon: CustomOverlayIconSlot,
    val upIcon: CustomOverlayIconSlot,
    val downIcon: CustomOverlayIconSlot,
    val holdIcon: CustomOverlayIconSlot,
)

private data class CustomOverlayNarrative(
    val firstFlowText: String,
    val firstFlowRep: Int,
    val firstFlowTextColor: Int,
    val firstFlowTextColorSecondary: Int,
    val secondFlowText: String,
    val secondFlowRep: Int,
    val secondFlowTextColor: Int,
    val secondFlowTextColorSecondary: Int,
    val thirdFlowText: String,
    val thirdFlowRep: Int,
    val thirdFlowTextColor: Int,
    val thirdFlowTextColorSecondary: Int,
    val fourthFlowText: String,
    val fourthFlowRep: Int,
    val fourthFlowTextColor: Int,
    val fourthFlowTextColorSecondary: Int,
) {
    fun cues(): List<OverlayNarrativeCueTemplate> = listOf(
        OverlayNarrativeCueTemplate(firstFlowText, firstFlowRep, firstFlowTextColor, firstFlowTextColorSecondary),
        OverlayNarrativeCueTemplate(secondFlowText, secondFlowRep, secondFlowTextColor, secondFlowTextColorSecondary),
        OverlayNarrativeCueTemplate(thirdFlowText, thirdFlowRep, thirdFlowTextColor, thirdFlowTextColorSecondary),
        OverlayNarrativeCueTemplate(fourthFlowText, fourthFlowRep, fourthFlowTextColor, fourthFlowTextColorSecondary),
    )
}

private data class OverlayNarrativeCueTemplate(
    val message: String,
    val repTarget: Int,
    val textColor: Int,
    val textColorSecondary: Int,
)

private data class OverlayNarrativeCue(
    val message: String,
    val repTarget: Int,
    val triggerOffsetMs: Long,
    val textColor: Int,
    val textColorSecondary: Int,
)

private const val NARRATIVE_CUE_FLOW_LEAD_IN_MS = 1200L
private const val NARRATIVE_CUE_VISIBLE_HOLD_MS = 3000L
private const val NARRATIVE_CUE_FADE_OUT_MS = 700L
private const val NARRATIVE_CUE_DISPLAY_DURATION_MS =
    NARRATIVE_CUE_FLOW_LEAD_IN_MS +
        NARRATIVE_CUE_VISIBLE_HOLD_MS +
        NARRATIVE_CUE_FADE_OUT_MS

private data class CustomOverlayRepCounter(
    val ringThickness: Float,
    val shape: String,
    val contourSoftness: Float,
    val glowIntensity: Float,
    val surfaceDepth: Float,
    val orbitIntensity: Float,
    val animationStyle: String,
    val scale: Float,
    val opacity: Float,
    val show: Boolean,
)

private data class CustomOverlayAccuracyBar(
    val style: String,
    val styleIntensity: Float,
    val showThresholdLine: Boolean,
    val markerDensity: Float,
    val glowIntensity: Float,
    val spillLength: Float,
    val spillWidth: Float,
    val thresholdGlow: Float,
    val liquidMotion: Float,
    val show: Boolean,
)

private data class CustomOverlayLayout(
    val bannerPosition: String,
    val statsCardPosition: String,
    val globalScale: Float,
    val opacity: Float,
)

private data class CustomOverlayFinish(
    val vignetteStrength: Float,
    val bloomIntensity: Float,
    val sparkleDensity: Float,
    val sheenSweep: Float,
)

private data class WorldFestivalTheme(
    val storageKey: String,
    val themeName: String,
    val label: String,
    val subtitle: String,
    val bannerIcon: String,
    val cornerIcon: String,
    val watermarkIcon: String,
    val bannerTitle: String,
    val variantId: Int,
    val primaryStart: Int,
    val primaryEnd: Int,
    val accent1: Int,
    val accent2: Int,
    val glowColor: Int,
    val phaseUpColor: Int,
    val phaseDownColor: Int,
    val phaseHoldColor: Int,
    val ringGradient: List<Int>,
    val accuracyBarGradient: List<Int>,
    val accuracyLowColor: Int,
    val accuracyMidColor: Int,
    val accuracyHighColor: Int,
    val thresholdLineColor: Int,
)

private data class ZodiacTheme(
    val signKey: String,
    val signLabel: String,
    val symbol: String,
    val titleStartColor: Int,
    val titleEndColor: Int,
    val shellStartColor: Int,
    val shellMidColor: Int,
    val shellEndColor: Int,
    val fillStartColor: Int,
    val fillMidColor: Int,
    val fillEndColor: Int,
    val sceneTintTopColor: Int,
    val sceneTintBottomColor: Int,
    val beamColor: Int,
    val glowColor: Int,
    val constellationColor: Int,
    val engravingColor: Int,
    val rimTextColor: Int,
)

private fun zodiacThemeFor(key: String): ZodiacTheme {
    return when (key) {
        "taurus" -> ZodiacTheme(
            signKey = "taurus",
            signLabel = "TAURUS",
            symbol = "\u2649",
            titleStartColor = boostColor(Color.rgb(241, 221, 174)),
            titleEndColor = boostColor(Color.rgb(169, 121, 63)),
            shellStartColor = boostColor(Color.rgb(23, 46, 38)),
            shellMidColor = boostColor(Color.rgb(43, 74, 58)),
            shellEndColor = boostColor(Color.rgb(125, 96, 48)),
            fillStartColor = boostColor(Color.rgb(232, 205, 145)),
            fillMidColor = boostColor(Color.rgb(150, 126, 68)),
            fillEndColor = boostColor(Color.rgb(96, 72, 34)),
            sceneTintTopColor = Color.argb(44, 150, 126, 68),
            sceneTintBottomColor = Color.argb(36, 37, 76, 53),
            beamColor = Color.argb(34, 226, 204, 151),
            glowColor = boostColor(Color.rgb(208, 182, 103)),
            constellationColor = boostColor(Color.rgb(244, 233, 196)),
            engravingColor = boostColor(Color.rgb(56, 38, 22)),
            rimTextColor = Color.argb(112, 244, 232, 204),
        )
        "gemini" -> ZodiacTheme(
            signKey = "gemini",
            signLabel = "GEMINI",
            symbol = "\u264A",
            titleStartColor = boostColor(Color.rgb(238, 225, 180)),
            titleEndColor = boostColor(Color.rgb(183, 141, 74)),
            shellStartColor = boostColor(Color.rgb(28, 33, 76)),
            shellMidColor = boostColor(Color.rgb(59, 45, 112)),
            shellEndColor = boostColor(Color.rgb(126, 88, 48)),
            fillStartColor = boostColor(Color.rgb(235, 213, 158)),
            fillMidColor = boostColor(Color.rgb(171, 122, 205)),
            fillEndColor = boostColor(Color.rgb(105, 70, 43)),
            sceneTintTopColor = Color.argb(42, 112, 89, 184),
            sceneTintBottomColor = Color.argb(34, 42, 54, 108),
            beamColor = Color.argb(30, 236, 214, 170),
            glowColor = boostColor(Color.rgb(211, 172, 102)),
            constellationColor = boostColor(Color.rgb(247, 236, 205)),
            engravingColor = boostColor(Color.rgb(55, 32, 23)),
            rimTextColor = Color.argb(114, 247, 237, 211),
        )
        "cancer" -> ZodiacTheme(
            signKey = "cancer",
            signLabel = "CANCER",
            symbol = "\u264B",
            titleStartColor = boostColor(Color.rgb(242, 225, 195)),
            titleEndColor = boostColor(Color.rgb(172, 126, 84)),
            shellStartColor = boostColor(Color.rgb(25, 44, 78)),
            shellMidColor = boostColor(Color.rgb(52, 78, 110)),
            shellEndColor = boostColor(Color.rgb(120, 83, 54)),
            fillStartColor = boostColor(Color.rgb(238, 217, 170)),
            fillMidColor = boostColor(Color.rgb(123, 168, 202)),
            fillEndColor = boostColor(Color.rgb(95, 65, 41)),
            sceneTintTopColor = Color.argb(40, 91, 144, 173),
            sceneTintBottomColor = Color.argb(34, 39, 74, 95),
            beamColor = Color.argb(28, 223, 233, 210),
            glowColor = boostColor(Color.rgb(205, 173, 119)),
            constellationColor = boostColor(Color.rgb(247, 239, 219)),
            engravingColor = boostColor(Color.rgb(51, 34, 24)),
            rimTextColor = Color.argb(116, 245, 236, 212),
        )
        "leo" -> ZodiacTheme(
            signKey = "leo",
            signLabel = "LEO",
            symbol = "\u264C",
            titleStartColor = boostColor(Color.rgb(250, 226, 167)),
            titleEndColor = boostColor(Color.rgb(194, 115, 45)),
            shellStartColor = boostColor(Color.rgb(56, 24, 19)),
            shellMidColor = boostColor(Color.rgb(98, 46, 24)),
            shellEndColor = boostColor(Color.rgb(147, 97, 39)),
            fillStartColor = boostColor(Color.rgb(248, 214, 138)),
            fillMidColor = boostColor(Color.rgb(232, 126, 47)),
            fillEndColor = boostColor(Color.rgb(124, 61, 24)),
            sceneTintTopColor = Color.argb(44, 179, 92, 34),
            sceneTintBottomColor = Color.argb(34, 85, 33, 18),
            beamColor = Color.argb(34, 250, 207, 130),
            glowColor = boostColor(Color.rgb(229, 156, 72)),
            constellationColor = boostColor(Color.rgb(255, 237, 191)),
            engravingColor = boostColor(Color.rgb(67, 29, 15)),
            rimTextColor = Color.argb(118, 255, 230, 187),
        )
        "virgo" -> ZodiacTheme(
            signKey = "virgo",
            signLabel = "VIRGO",
            symbol = "\u264D",
            titleStartColor = boostColor(Color.rgb(241, 228, 190)),
            titleEndColor = boostColor(Color.rgb(165, 135, 84)),
            shellStartColor = boostColor(Color.rgb(26, 51, 45)),
            shellMidColor = boostColor(Color.rgb(58, 91, 78)),
            shellEndColor = boostColor(Color.rgb(126, 92, 53)),
            fillStartColor = boostColor(Color.rgb(236, 219, 175)),
            fillMidColor = boostColor(Color.rgb(141, 178, 124)),
            fillEndColor = boostColor(Color.rgb(93, 68, 38)),
            sceneTintTopColor = Color.argb(40, 111, 152, 103),
            sceneTintBottomColor = Color.argb(34, 42, 77, 55),
            beamColor = Color.argb(30, 228, 232, 196),
            glowColor = boostColor(Color.rgb(203, 180, 109)),
            constellationColor = boostColor(Color.rgb(245, 240, 213)),
            engravingColor = boostColor(Color.rgb(48, 37, 23)),
            rimTextColor = Color.argb(116, 244, 238, 214),
        )
        "libra" -> ZodiacTheme(
            signKey = "libra",
            signLabel = "LIBRA",
            symbol = "\u264E",
            titleStartColor = boostColor(Color.rgb(242, 226, 198)),
            titleEndColor = boostColor(Color.rgb(188, 136, 102)),
            shellStartColor = boostColor(Color.rgb(29, 39, 84)),
            shellMidColor = boostColor(Color.rgb(73, 73, 122)),
            shellEndColor = boostColor(Color.rgb(145, 94, 92)),
            fillStartColor = boostColor(Color.rgb(242, 222, 185)),
            fillMidColor = boostColor(Color.rgb(198, 146, 171)),
            fillEndColor = boostColor(Color.rgb(111, 76, 56)),
            sceneTintTopColor = Color.argb(40, 162, 112, 140),
            sceneTintBottomColor = Color.argb(34, 51, 55, 100),
            beamColor = Color.argb(28, 236, 216, 205),
            glowColor = boostColor(Color.rgb(211, 166, 145)),
            constellationColor = boostColor(Color.rgb(248, 239, 224)),
            engravingColor = boostColor(Color.rgb(60, 39, 33)),
            rimTextColor = Color.argb(116, 247, 235, 223),
        )
        "scorpio" -> ZodiacTheme(
            signKey = "scorpio",
            signLabel = "SCORPIO",
            symbol = "\u264F",
            titleStartColor = boostColor(Color.rgb(242, 221, 194)),
            titleEndColor = boostColor(Color.rgb(166, 97, 91)),
            shellStartColor = boostColor(Color.rgb(32, 17, 41)),
            shellMidColor = boostColor(Color.rgb(73, 29, 70)),
            shellEndColor = boostColor(Color.rgb(124, 61, 52)),
            fillStartColor = boostColor(Color.rgb(236, 210, 180)),
            fillMidColor = boostColor(Color.rgb(167, 79, 114)),
            fillEndColor = boostColor(Color.rgb(92, 42, 40)),
            sceneTintTopColor = Color.argb(44, 123, 46, 77),
            sceneTintBottomColor = Color.argb(36, 53, 18, 34),
            beamColor = Color.argb(28, 233, 195, 176),
            glowColor = boostColor(Color.rgb(186, 103, 106)),
            constellationColor = boostColor(Color.rgb(247, 230, 217)),
            engravingColor = boostColor(Color.rgb(56, 26, 30)),
            rimTextColor = Color.argb(114, 244, 224, 218),
        )
        "sagittarius" -> ZodiacTheme(
            signKey = "sagittarius",
            signLabel = "SAGITTARIUS",
            symbol = "\u2650",
            titleStartColor = boostColor(Color.rgb(246, 228, 181)),
            titleEndColor = boostColor(Color.rgb(176, 121, 55)),
            shellStartColor = boostColor(Color.rgb(28, 40, 80)),
            shellMidColor = boostColor(Color.rgb(43, 70, 118)),
            shellEndColor = boostColor(Color.rgb(133, 81, 35)),
            fillStartColor = boostColor(Color.rgb(244, 216, 154)),
            fillMidColor = boostColor(Color.rgb(117, 169, 215)),
            fillEndColor = boostColor(Color.rgb(125, 72, 29)),
            sceneTintTopColor = Color.argb(42, 76, 123, 188),
            sceneTintBottomColor = Color.argb(34, 37, 61, 105),
            beamColor = Color.argb(30, 237, 214, 152),
            glowColor = boostColor(Color.rgb(205, 154, 84)),
            constellationColor = boostColor(Color.rgb(251, 238, 198)),
            engravingColor = boostColor(Color.rgb(50, 31, 16)),
            rimTextColor = Color.argb(116, 248, 236, 204),
        )
        "capricorn" -> ZodiacTheme(
            signKey = "capricorn",
            signLabel = "CAPRICORN",
            symbol = "\u2651",
            titleStartColor = boostColor(Color.rgb(238, 228, 198)),
            titleEndColor = boostColor(Color.rgb(160, 138, 92)),
            shellStartColor = boostColor(Color.rgb(28, 42, 48)),
            shellMidColor = boostColor(Color.rgb(50, 77, 84)),
            shellEndColor = boostColor(Color.rgb(110, 90, 64)),
            fillStartColor = boostColor(Color.rgb(232, 220, 185)),
            fillMidColor = boostColor(Color.rgb(135, 153, 146)),
            fillEndColor = boostColor(Color.rgb(85, 65, 43),),
            sceneTintTopColor = Color.argb(40, 116, 136, 128),
            sceneTintBottomColor = Color.argb(34, 41, 61, 58),
            beamColor = Color.argb(28, 227, 221, 205),
            glowColor = boostColor(Color.rgb(184, 171, 130)),
            constellationColor = boostColor(Color.rgb(244, 239, 220)),
            engravingColor = boostColor(Color.rgb(47, 39, 29)),
            rimTextColor = Color.argb(114, 240, 236, 223),
        )
        "aquarius" -> ZodiacTheme(
            signKey = "aquarius",
            signLabel = "AQUARIUS",
            symbol = "\u2652",
            titleStartColor = boostColor(Color.rgb(233, 229, 204)),
            titleEndColor = boostColor(Color.rgb(110, 155, 170)),
            shellStartColor = boostColor(Color.rgb(18, 43, 67)),
            shellMidColor = boostColor(Color.rgb(32, 78, 112)),
            shellEndColor = boostColor(Color.rgb(79, 122, 132)),
            fillStartColor = boostColor(Color.rgb(222, 226, 199)),
            fillMidColor = boostColor(Color.rgb(111, 182, 200)),
            fillEndColor = boostColor(Color.rgb(52, 101, 115)),
            sceneTintTopColor = Color.argb(42, 87, 160, 179),
            sceneTintBottomColor = Color.argb(34, 22, 78, 101),
            beamColor = Color.argb(28, 214, 241, 231),
            glowColor = boostColor(Color.rgb(107, 185, 197)),
            constellationColor = boostColor(Color.rgb(227, 243, 239)),
            engravingColor = boostColor(Color.rgb(26, 50, 58)),
            rimTextColor = Color.argb(114, 227, 243, 239),
        )
        "pisces" -> ZodiacTheme(
            signKey = "pisces",
            signLabel = "PISCES",
            symbol = "\u2653",
            titleStartColor = boostColor(Color.rgb(236, 225, 203)),
            titleEndColor = boostColor(Color.rgb(128, 135, 186)),
            shellStartColor = boostColor(Color.rgb(28, 34, 76)),
            shellMidColor = boostColor(Color.rgb(56, 58, 116)),
            shellEndColor = boostColor(Color.rgb(95, 95, 142)),
            fillStartColor = boostColor(Color.rgb(228, 219, 203)),
            fillMidColor = boostColor(Color.rgb(127, 143, 214)),
            fillEndColor = boostColor(Color.rgb(67, 76, 126)),
            sceneTintTopColor = Color.argb(42, 92, 112, 198),
            sceneTintBottomColor = Color.argb(34, 43, 49, 110),
            beamColor = Color.argb(28, 225, 221, 247),
            glowColor = boostColor(Color.rgb(144, 152, 216)),
            constellationColor = boostColor(Color.rgb(235, 234, 246)),
            engravingColor = boostColor(Color.rgb(36, 41, 76)),
            rimTextColor = Color.argb(114, 234, 232, 246),
        )
        "aries" -> ZodiacTheme(
            signKey = "aries",
            signLabel = "ARIES",
            symbol = "\u2648",
            titleStartColor = boostColor(Color.rgb(248, 225, 170)),
            titleEndColor = boostColor(Color.rgb(179, 126, 57)),
            shellStartColor = boostColor(Color.rgb(9, 30, 62)),
            shellMidColor = boostColor(Color.rgb(21, 44, 77)),
            shellEndColor = boostColor(Color.rgb(102, 76, 38)),
            fillStartColor = boostColor(Color.rgb(243, 215, 147)),
            fillMidColor = boostColor(Color.rgb(194, 146, 72)),
            fillEndColor = boostColor(Color.rgb(120, 72, 34)),
            sceneTintTopColor = Color.argb(44, 36, 78, 132),
            sceneTintBottomColor = Color.argb(34, 21, 36, 79),
            beamColor = Color.argb(32, 255, 213, 132),
            glowColor = boostColor(Color.rgb(230, 194, 110)),
            constellationColor = boostColor(Color.rgb(246, 229, 191)),
            engravingColor = boostColor(Color.rgb(58, 33, 18)),
            rimTextColor = Color.argb(112, 245, 225, 179),
        )
        else -> zodiacThemeFor("aries")
    }
}

private class WorkoutOverlayTimeline(
    samples: List<OverlaySample>,
) {
    private val samples = samples.sortedBy { it.offsetMs }

    fun narrativeCues(templates: List<OverlayNarrativeCueTemplate>): List<OverlayNarrativeCue> {
        val cues = mutableListOf<OverlayNarrativeCue>()
        var searchStartIndex = 0

        templates.forEach { template ->
            val trimmed = template.message.trim()
            if (trimmed.isEmpty()) {
                return@forEach
            }
            val repTarget = template.repTarget.coerceAtLeast(1)
            val triggerSampleIndex = samples.indexOfFirstFrom(searchStartIndex) { sample ->
                sample.repCount == repTarget && sample.accuracy >= 0.80f
            }
            if (triggerSampleIndex >= 0) {
                val sample = samples[triggerSampleIndex]
                cues += OverlayNarrativeCue(
                    message = trimmed,
                    repTarget = repTarget,
                    triggerOffsetMs = sample.offsetMs,
                    textColor = template.textColor,
                    textColorSecondary = template.textColorSecondary,
                )
                searchStartIndex = triggerSampleIndex + 1
            }
        }

        return cues
    }

    fun stateAt(presentationTimeUs: Long): OverlayState {
        val timeMs = max(0L, presentationTimeUs / 1000L)
        var low = 0
        var high = samples.lastIndex
        var index = 0

        while (low <= high) {
            val mid = (low + high) ushr 1
            val sample = samples[mid]
            if (sample.offsetMs <= timeMs) {
                index = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        val sample = samples[index]
        val nextIndex = min(index + 1, samples.lastIndex)
        val nextSample = samples[nextIndex]
        val interpolatedAccuracy =
            if (nextIndex == index || nextSample.offsetMs <= sample.offsetMs) {
                sample.accuracy
            } else {
                val range = (nextSample.offsetMs - sample.offsetMs).toFloat()
                val rawT = ((timeMs - sample.offsetMs).toFloat() / range).coerceIn(0f, 1f)
                // Use smoothstep easing to avoid visible stepping in the exported accuracy bar.
                val easedT = rawT * rawT * (3f - (2f * rawT))
                sample.accuracy + ((nextSample.accuracy - sample.accuracy) * easedT)
            }
        return OverlayState(
            repCount = sample.repCount,
            accuracy = interpolatedAccuracy.coerceIn(0f, 1f),
            phase = sample.phase,
        )
    }
}

private inline fun <T> List<T>.indexOfFirstFrom(
    startIndex: Int,
    predicate: (T) -> Boolean,
): Int {
    val safeStartIndex = startIndex.coerceAtLeast(0)
    for (index in safeStartIndex until size) {
        if (predicate(this[index])) {
            return index
        }
    }
    return -1
}

@UnstableApi
private class WorkoutCanvasOverlay(
    private val timeline: WorkoutOverlayTimeline,
    private val visualConfig: OverlayVisualConfig,
    private val svgPictureCache: MutableMap<String, Picture?>,
) : CanvasOverlay(true) {
    private val professionHobbyVerticalOffsetScale = 8f
    private val professionHobbyMetricClusterExtraOffsetScale = 24f
    private val narrativeCues =
        timeline.narrativeCues(visualConfig.customOverlay.narrative.cues())

    companion object {
        // Per theme cache - static UI cached globally by theme and resolution
        private val themeStaticCache = mutableMapOf<String, Bitmap?>()
    }

    // Common paint objects (still initialized once)
    private val accuracyBarBackgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(102, 0, 0, 0)
        style = Paint.Style.FILL
    }
    private val accuracyBarStrokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(46, 255, 255, 255)
        style = Paint.Style.STROKE
        strokeWidth = 1f
    }
    private val markerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(230, 255, 255, 255)
        style = Paint.Style.FILL
    }
    private val repCardPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(199, 17, 17, 17)
        style = Paint.Style.FILL
    }
    private val repRingPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(235, 76, 175, 80)
        style = Paint.Style.STROKE
    }
    private val repInnerRingPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(20, 255, 255, 255)
        style = Paint.Style.STROKE
        strokeWidth = 1f
    }
    private val repCountPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(255, 76, 175, 80)
        textAlign = Paint.Align.CENTER
        typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD)
    }
    private val repLabelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(209, 255, 255, 255)
        textAlign = Paint.Align.CENTER
        typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD)
    }
    private val accuracyTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        textAlign = Paint.Align.CENTER
        typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD)
    }
    private val watermarkPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(66, 0, 0, 0)
        style = Paint.Style.FILL
    }
    private val watermarkStrokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(46, 255, 255, 255)
        style = Paint.Style.STROKE
        strokeWidth = 1f
    }
    private val watermarkTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(117, 255, 255, 255)
        textAlign = Paint.Align.CENTER
        typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD)
    }
    private val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(46, 0, 0, 0)
        style = Paint.Style.FILL
    }
    private val overlayPolishPaint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.DITHER_FLAG).apply {
        isFilterBitmap = true
    }

    override fun onDraw(canvas: Canvas, presentationTimeUs: Long) {
        val state = timeline.stateAt(presentationTimeUs)
        val width = canvas.width.toFloat()
        val height = canvas.height.toFloat()
        if (width <= 0f || height <= 0f) {
            return
        }

        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

        val scale = min(width / 390f, height / 844f)
        val overlayScale = resolveOverlayUiScale(width, height)

        // Luxury overlay studio uses custom user-editable themes - no caching
        if (visualConfig.iconicProgram == "luxury_overlay_studio") {
            drawCustomOverlay(
                canvas = canvas,
                width = width,
                height = height,
                scale = overlayScale,
                state = state,
                presentationTimeUs = presentationTimeUs,
            )
            return
        }

        // Per theme caching for world_festival themes
        val themeKey = visualConfig.worldFestivalTheme?.storageKey ?: "default"
        val cacheKey = "${themeKey}_${width.toInt()}x${height.toInt()}"

        // Render static base layer once per theme/resolution combination
        if (themeStaticCache[cacheKey] == null) {
            val staticBitmap = Bitmap.createBitmap(width.toInt(), height.toInt(), Bitmap.Config.ARGB_8888)
            val baseCanvas = Canvas(staticBitmap)

            if (visualConfig.iconicProgram == "world_festival" && visualConfig.worldFestivalTheme != null) {
                drawWorldFestivalStaticBase(
                    canvas = baseCanvas,
                    width = width,
                    height = height,
                    scale = scale,
                    theme = visualConfig.worldFestivalTheme!!,
                )
            }

            themeStaticCache[cacheKey] = staticBitmap
        }

        // Draw pre-rendered static base layer first - this is O(1) GPU blit operation
        themeStaticCache[cacheKey]?.let {
            canvas.drawBitmap(it, 0f, 0f, overlayPolishPaint)
        }

        // ONLY DRAW DYNAMIC CHANGING ELEMENTS EVERY FRAME
        if (visualConfig.iconicProgram == "world_festival" && visualConfig.worldFestivalTheme != null) {
            drawWorldFestivalDynamicOverlay(
                canvas = canvas,
                width = width,
                height = height,
                scale = scale,
                state = state,
                presentationTimeUs = presentationTimeUs,
                theme = visualConfig.worldFestivalTheme!!,
            )
            return
        } else if (visualConfig.iconicProgram == "profession_hobby" && visualConfig.worldFestivalTheme != null) {
            drawProfessionHobbyOverlay(
                canvas = canvas,
                width = width,
                height = height,
                scale = scale,
                state = state,
                presentationTimeUs = presentationTimeUs,
                theme = visualConfig.worldFestivalTheme!!,
            )
            return
        }

        if (visualConfig.customOverlay.customModeEnabled || visualConfig.iconicProgram == "luxury_overlay_studio") {
            drawCustomOverlay(
                canvas = canvas,
                width = width,
                height = height,
                scale = overlayScale,
                state = state,
                presentationTimeUs = presentationTimeUs,
            )
            return
        }

        if (visualConfig.iconicProgram == "zodiac") {
            drawZodiacOverlay(
                canvas = canvas,
                width = width,
                height = height,
                scale = scale,
                state = state,
                presentationTimeUs = presentationTimeUs,
            )
            return
        }

        val sideInset = 18f * scale
        val topInset = 44f * scale
        val repTop = 92f * scale
        val repCounterSize = 92f * scale
        val accuracyBarHeight = 24f * scale
        val accuracyBarWidth = width - (sideInset * 2f)

        drawAccuracyBar(
            canvas = canvas,
            rect = RectF(
                sideInset,
                topInset,
                sideInset + accuracyBarWidth,
                topInset + accuracyBarHeight,
            ),
            accuracy = state.accuracy,
            scale = scale,
            presentationTimeUs = presentationTimeUs,
            theme = null,
        )

        drawRepCounter(
            canvas = canvas,
            rect = RectF(
                width - sideInset - repCounterSize,
                repTop,
                width - sideInset,
                repTop + repCounterSize,
            ),
            repCount = state.repCount,
            scale = scale,
            phase = state.phase,
            theme = null,
        )
    }

    private fun drawProfessionHobbyOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val verticalOffset = professionHobbyVerticalOffsetScale * scale
        val metricClusterExtraOffset = professionHobbyMetricClusterExtraOffsetScale * scale
        canvas.save()
        canvas.translate(0f, verticalOffset)

        drawProfessionHobbyTitleRibbon(
            canvas = canvas,
            width = width,
            scale = scale,
            accuracy = state.accuracy,
            theme = theme,
        )

        canvas.save()
        canvas.translate(0f, metricClusterExtraOffset)
        when (theme.storageKey) {
            "profession_human_resource" -> drawHROverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_marketing_specialist" -> drawMarketingOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_fashion_designer" -> drawFashionDesignerOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_beautician" -> drawBeauticianOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_doctor" -> drawDoctorOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_teacher" -> drawTeacherOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_pharmacist" -> drawPharmacistOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_nurse" -> drawNurseOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_accountant" -> drawAccountantOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_data_scientist" -> drawDataScientistOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_electrical_engineer" -> drawElectricalEngineerOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_mechanical_engineer" -> drawMechanicalEngineerOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            "profession_it_engineer" -> drawNetworkEngineerOverlay(
                canvas, width, height, scale, state, presentationTimeUs, theme,
            )
            else -> {
                val sideInset = 18f * scale
                val topInset = 44f * scale
                val repTop = 92f * scale
                val repCounterSize = 92f * scale
                val accuracyBarHeight = 24f * scale
                val accuracyBarWidth = width - (sideInset * 2f)

                drawAccuracyBar(
                    canvas = canvas,
                    rect = RectF(
                        sideInset, topInset,
                        sideInset + accuracyBarWidth, topInset + accuracyBarHeight,
                    ),
                    accuracy = state.accuracy,
                    scale = scale,
                    presentationTimeUs = presentationTimeUs,
                    theme = theme,
                )
                drawRepCounter(
                    canvas = canvas,
                    rect = RectF(
                        width - sideInset - repCounterSize, repTop,
                        width - sideInset, repTop + repCounterSize,
                    ),
                    repCount = state.repCount,
                    scale = scale,
                    phase = state.phase,
                    theme = theme,
                )
            }
        }
        canvas.restore()

        canvas.restore()
    }

    private fun drawProfessionHobbyTitleRibbon(
        canvas: Canvas,
        width: Float,
        scale: Float,
        accuracy: Float,
        theme: WorldFestivalTheme,
    ) {
        val sideInset = 18f * scale
        val topInset = 28f * scale
        val barHeight = 30f * scale
        val ribbonRect = RectF(
            sideInset,
            topInset,
            width - sideInset,
            topInset + barHeight,
        )
        val radius = 13f * scale

        val path = Path().apply {
            addRoundRect(ribbonRect, radius, radius, Path.Direction.CW)
        }
        canvas.drawPath(
            path,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    ribbonRect.left,
                    ribbonRect.top,
                    ribbonRect.right,
                    ribbonRect.bottom,
                    intArrayOf(
                        adjustAlpha(theme.primaryStart, 0.88f),
                        adjustAlpha(theme.primaryEnd, 0.92f),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawPath(
            path,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent1, 0.42f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.1f * scale)
            },
        )

        val iconSize = 20f * scale
        val iconRect = RectF(
            ribbonRect.left + (8f * scale),
            ribbonRect.centerY() - (iconSize * 0.5f),
            ribbonRect.left + (8f * scale) + iconSize,
            ribbonRect.centerY() + (iconSize * 0.5f),
        )
        canvas.drawOval(
            iconRect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    iconRect.left,
                    iconRect.top,
                    iconRect.right,
                    iconRect.bottom,
                    intArrayOf(theme.accent1, theme.accent2),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawOval(
            iconRect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(Color.WHITE, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.9f * scale)
            },
        )
        drawCenteredText(
            canvas = canvas,
            text = theme.bannerIcon.ifBlank { "*" },
            centerX = iconRect.centerX(),
            centerY = iconRect.centerY() - (0.2f * scale),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                textAlign = Paint.Align.CENTER
                textSize = max(8f, iconRect.height() * 0.43f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )

        val titleLeft = iconRect.right + (8f * scale)
        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(Color.WHITE, 0.98f)
            textAlign = Paint.Align.LEFT
            textSize = max(8f, 10f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val precision = when {
            accuracy >= 0.82f -> "OPTIMAL"
            accuracy >= 0.68f -> "STABLE"
            else -> "CALIBRATING"
        }
        val badgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.accent2, 0.96f)
            textAlign = Paint.Align.CENTER
            textSize = max(7f, 8f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val badgeWidth = max(68f * scale, badgePaint.measureText(precision) + (16f * scale))
        val badgeRect = RectF(
            ribbonRect.right - (10f * scale) - badgeWidth,
            ribbonRect.centerY() - (9f * scale),
            ribbonRect.right - (10f * scale),
            ribbonRect.centerY() + (9f * scale),
        )
        canvas.drawRoundRect(
            badgeRect,
            4f * scale,
            4f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(Color.WHITE, 0.14f)
            },
        )
        canvas.drawRoundRect(
            badgeRect,
            4f * scale,
            4f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent2, 0.54f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.8f * scale)
            },
        )

        val textRight = badgeRect.left - (8f * scale)
        val professionValue = theme.label
            .ifBlank { theme.themeName }
            .replace(Regex("\\s*\\(pre[- ]show\\)\\s*", RegexOption.IGNORE_CASE), " ")
            .trim()
        canvas.save()
        canvas.clipRect(titleLeft, ribbonRect.top, textRight, ribbonRect.bottom)
        canvas.drawText(
            professionValue,
            titleLeft,
            ribbonRect.centerY() + (4f * scale),
            titlePaint,
        )
        canvas.restore()

        drawCenteredText(
            canvas = canvas,
            text = precision,
            centerX = badgeRect.centerX(),
            centerY = badgeRect.centerY(),
            paint = badgePaint,
        )
    }

    // ═══════════════════════════════════════════════════════════════════════
    // HUMAN RESOURCE — Org-chart precision overlay
    // Colors: ivory, charcoal, deep navy, muted gold, soft teal
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawHROverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)

        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTop = 84f * scale
        val repRect = RectF(repLeft, repTop, repLeft + repSize, repTop + repSize)

        val ivory = Color.rgb(234, 224, 206)
        val charcoal = Color.rgb(49, 53, 61)
        val navy = Color.rgb(26, 37, 53)
        val gold = Color.rgb(201, 162, 87)
        val teal = Color.rgb(109, 195, 190)
        val pulse = ((sin(presentationTimeUs / 480000.0) + 1.0) / 2.0).toFloat()

        // ── Ambient: subtle org-chart network lines in top canvas area ──
        val netPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(28, 109, 195, 190)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.85f * scale)
        }
        // Horizontal root line
        canvas.drawLine(sideInset, barTop - (18f * scale), sideInset + (barWidth * 0.72f), barTop - (18f * scale), netPaint)
        // Vertical drops from root
        listOf(0.16f, 0.38f, 0.62f).forEach { xFrac ->
            val x = sideInset + (barWidth * xFrac)
            canvas.drawLine(x, barTop - (18f * scale), x, barTop - (7f * scale), netPaint)
            canvas.drawRect(
                x - (6f * scale), barTop - (7f * scale),
                x + (6f * scale), barTop - (1f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = Color.argb(36, 109, 195, 190)
                },
            )
        }

        // ── HR Accuracy bar: segmented panel bar with alignment ticks ──
        // Track background
        val trackRadius = barHeight * 0.28f
        canvas.drawRoundRect(
            barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(
                        Color.argb(200, 26, 37, 53),
                        Color.argb(220, 18, 26, 37),
                    ),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Panel dividers (department boundaries)
        val panelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(60, 109, 195, 190)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
        }
        listOf(0.25f, 0.5f, 0.75f).forEach { frac ->
            val x = barRect.left + (barRect.width() * frac)
            canvas.drawLine(x, barRect.top + (3f * scale), x, barRect.bottom - (3f * scale), panelPaint)
        }
        // Fill
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(
                barRect, trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(
                            Color.argb(220, 49, 53, 61),
                            adjustAlpha(gold, 0.92f),
                            adjustAlpha(ivory, 0.96f),
                        ),
                        floatArrayOf(0f, 0.55f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
            // Shimmer sheen
            val shimmerX = barRect.left + (fillWidth * ((presentationTimeUs / 1800000.0 % 1.0).toFloat()))
            canvas.drawRect(
                shimmerX - (10f * scale), barRect.top,
                shimmerX + (10f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        shimmerX - (12f * scale), barRect.top,
                        shimmerX + (12f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(60, 255, 248, 230), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
            canvas.restore()
        }
        // Alignment ticks above bar
        val tickPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(teal, 0.70f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.9f * scale)
        }
        listOf(0.25f, 0.5f, 0.75f, 1.0f).forEach { frac ->
            if (frac <= safeAccuracy + 0.01f) {
                val x = barRect.left + (barRect.width() * frac)
                canvas.drawLine(x, barRect.top - (4f * scale), x, barRect.top - (9f * scale), tickPaint)
            }
        }
        // 80% threshold marker
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(ivory, 0.82f) },
        )
        // Bar outer stroke
        canvas.drawRoundRect(
            barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.30f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            },
        )
        // Micro-labels below bar
        val microLabels = listOf("CULTURE", "ENGAGEMENT", "VERIFIED", "BALANCED")
        val microPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(teal, 0.72f)
            textAlign = Paint.Align.CENTER
            textSize = max(8f, 8.5f * scale)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        microLabels.forEachIndexed { i, label ->
            val frac = 0.125f + (i * 0.25f)
            canvas.drawText(label, barRect.left + (barRect.width() * frac), barRect.bottom + (11f * scale), microPaint)
        }
        // Accuracy text
        canvas.drawText(
            "${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(),
            barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(ivory, 0.96f) else adjustAlpha(gold, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            },
        )

        // ── HR Rep counter: premium identity badge (rounded rect card) ──
        val cardCorner = repSize * 0.14f
        // Card drop shadow
        canvas.drawRoundRect(
            RectF(repRect.left + (2f * scale), repRect.top + (4f * scale), repRect.right + (2f * scale), repRect.bottom + (4f * scale)),
            cardCorner, cardCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(80, 0, 0, 0)
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        // Card background
        canvas.drawRoundRect(
            repRect, cardCorner, cardCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    repRect.left, repRect.top, repRect.left, repRect.bottom,
                    intArrayOf(
                        Color.argb(240, 26, 37, 53),
                        Color.argb(252, 18, 26, 37),
                    ),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Glass highlight
        canvas.drawRoundRect(
            RectF(repRect.left, repRect.top, repRect.right, repRect.top + (repSize * 0.44f)),
            cardCorner, cardCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    repRect.left, repRect.top, repRect.left, repRect.top + (repSize * 0.44f),
                    intArrayOf(Color.argb(60, 255, 255, 255), Color.TRANSPARENT),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Outer border (double)
        canvas.drawRoundRect(
            repRect, cardCorner, cardCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(gold, 0.72f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.5f, 1.6f * scale)
            },
        )
        canvas.drawRoundRect(
            RectF(repRect.left + (4f * scale), repRect.top + (4f * scale), repRect.right - (4f * scale), repRect.bottom - (4f * scale)),
            cardCorner * 0.7f, cardCorner * 0.7f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.9f * scale)
            },
        )
        // Teal glow halo
        canvas.drawRoundRect(
            repRect, cardCorner, cardCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.14f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 7f * scale)
                maskFilter = BlurMaskFilter(10f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        // Phase color indicator bar at top of card
        val phaseColor = when (state.phase) {
            "up" -> teal
            "down" -> Color.rgb(158, 181, 216)
            else -> gold
        }
        canvas.drawRoundRect(
            RectF(repRect.left + (8f * scale), repRect.top + (7f * scale), repRect.right - (8f * scale), repRect.top + (10f * scale)),
            99f, 99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(phaseColor, 0.88f) },
        )
        // Watermark HR monogram
        canvas.drawText(
            "HR",
            repRect.centerX(), repRect.centerY() + (repSize * 0.08f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(22, 234, 224, 206)
                textAlign = Paint.Align.CENTER
                textSize = repSize * 0.68f
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
        // Rep digit
        val repText = state.repCount.toString()
        canvas.drawText(
            repText,
            repRect.centerX(), repRect.centerY() + (repSize * 0.22f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(ivory, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(repSize * 0.52f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(130, 0, 0, 0))
            },
        )
        // REPS label
        canvas.drawText(
            "REPS",
            repRect.centerX(), repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(gold, 0.80f)
                textAlign = Paint.Align.CENTER
                textSize = max(8f, 8f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
        // Bottom footer: PEOPLE ALIGNMENT
        canvas.drawText(
            "PEOPLE ALIGNMENT",
            repRect.centerX(), repRect.top - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            },
        )
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MARKETING SPECIALIST — Campaign funnel analytics overlay
    // Colors: rich magenta, electric cyan, gold, deep violet, black
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawMarketingOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)

        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTop = 84f * scale
        val repRect = RectF(repLeft, repTop, repLeft + repSize, repTop + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val magenta = Color.rgb(255, 63, 164)
        val cyan = Color.rgb(47, 226, 255)
        val gold = Color.rgb(255, 195, 77)
        val violet = Color.rgb(45, 20, 80)
        val pulse = ((sin(presentationTimeUs / 400000.0) + 1.0) / 2.0).toFloat()
        val scanPhase = ((presentationTimeUs / 1000L) % 2800L).toFloat() / 2800f

        // ── Ambient: growth signal glow behind rep counter ──
        canvas.drawCircle(
            repCenter, repCenterY, repSize * 0.82f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb((18 + (14 * pulse)).toInt(), 255, 63, 164)
                maskFilter = BlurMaskFilter(28f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )

        // ── Marketing Accuracy bar: funnel-shaped bar ──
        // Funnel tapers slightly: left end is taller than right
        val funnelTopOffset = barHeight * 0.14f  // extra height at left
        val funnelPath = Path().apply {
            moveTo(barRect.left, barRect.top - funnelTopOffset)
            lineTo(barRect.right, barRect.top)
            lineTo(barRect.right, barRect.bottom)
            lineTo(barRect.left, barRect.bottom + funnelTopOffset)
            close()
        }
        // Track background
        canvas.drawPath(
            funnelPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    barRect.left, barRect.top, barRect.right, barRect.top,
                    intArrayOf(Color.argb(220, 45, 20, 80), Color.argb(200, 27, 15, 48)),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Fill funnel
        if (safeAccuracy > 0f) {
            val fillRight = barRect.left + (barRect.width() * safeAccuracy)
            val funnelFillFrac = safeAccuracy
            val fillTopOff = funnelTopOffset * (1f - funnelFillFrac)
            val fillPath = Path().apply {
                moveTo(barRect.left, barRect.top - funnelTopOffset)
                lineTo(fillRight, barRect.top - fillTopOff)
                lineTo(fillRight, barRect.bottom + fillTopOff)
                lineTo(barRect.left, barRect.bottom + funnelTopOffset)
                close()
            }
            canvas.drawPath(
                fillPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        barRect.left, barRect.top, fillRight, barRect.top,
                        intArrayOf(
                            adjustAlpha(violet, 0.90f),
                            adjustAlpha(magenta, 0.96f),
                            adjustAlpha(cyan, 0.98f),
                        ),
                        floatArrayOf(0f, 0.55f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
            // Signal wave lines inside fill
            val wavePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(50, 255, 255, 255)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.8f * scale)
            }
            repeat(3) { i ->
                val waveY = barRect.top + (barRect.height() * (0.25f + (i * 0.25f)))
                val wavePath = Path()
                var first = true
                var x = barRect.left
                while (x <= fillRight) {
                    val frac = (x - barRect.left) / barRect.width()
                    val y = waveY + (sin((frac * Math.PI * 4) + (presentationTimeUs / 350000.0)).toFloat() * (2.5f * scale))
                    if (first) { wavePath.moveTo(x, y); first = false } else wavePath.lineTo(x, y)
                    x += 4f * scale
                }
                canvas.drawPath(wavePath, wavePaint)
            }
            // Spark at leading edge
            if (safeAccuracy > 0.05f) {
                val sparkX = fillRight
                canvas.drawCircle(
                    sparkX, barRect.centerY(),
                    4f * scale,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = RadialGradient(
                            sparkX, barRect.centerY(), 8f * scale,
                            intArrayOf(adjustAlpha(cyan, 1f), adjustAlpha(magenta, 0.60f), Color.TRANSPARENT),
                            floatArrayOf(0f, 0.4f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
            }
        }
        // 80% threshold marker
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(markerX - (1.5f * scale), barRect.top + (1f * scale), markerX + (1.5f * scale), barRect.bottom - (1f * scale)),
            99f, 99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(gold, 0.88f) },
        )
        // Funnel stroke
        canvas.drawPath(
            funnelPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(magenta, 0.30f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            },
        )
        // Micro-labels
        val mktLabels = listOf("ENGAGEMENT", "OPTIMIZED", "LIVE", "CVR")
        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(cyan, 0.70f)
            textAlign = Paint.Align.CENTER
            textSize = max(8f, 8.5f * scale)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        mktLabels.forEachIndexed { i, label ->
            val frac = 0.125f + (i * 0.25f)
            canvas.drawText(label, barRect.left + (barRect.width() * frac), barRect.bottom + (12f * scale), labelPaint)
        }
        // Accuracy text
        canvas.drawText(
            "${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(cyan, 0.98f) else adjustAlpha(magenta, 0.92f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(120, 0, 0, 0))
            },
        )

        // ── Marketing Rep counter: luminous analytics badge ──
        val repRadius = repSize / 2f
        // Ring glow
        canvas.drawCircle(
            repCenter, repCenterY, repRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(magenta, 0.22f + (0.12f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = repRadius * 0.22f
                maskFilter = BlurMaskFilter(14f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        // Shell background
        canvas.drawCircle(
            repCenter, repCenterY, repRadius - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    repCenter, repCenterY, repRadius,
                    intArrayOf(
                        Color.argb(240, 45, 20, 80),
                        Color.argb(252, 27, 12, 40),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        // Ring: magenta → cyan sweep
        canvas.drawCircle(
            repCenter, repCenterY, repRadius - (3f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = SweepGradient(
                    repCenter, repCenterY,
                    intArrayOf(magenta, cyan, gold, magenta),
                    null,
                )
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 6f * scale)
            },
        )
        // Dashed reach-marker outer arc
        val reachPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(cyan, 0.40f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1.2f * scale)
            pathEffect = android.graphics.DashPathEffect(floatArrayOf(6f * scale, 5f * scale), 0f)
        }
        val reachOval = RectF(
            repCenter - repRadius - (4f * scale), repCenterY - repRadius - (4f * scale),
            repCenter + repRadius + (4f * scale), repCenterY + repRadius + (4f * scale),
        )
        canvas.drawOval(reachOval, reachPaint)
        // Scan line sweep
        val scanX = repRect.left + (repRect.width() * scanPhase)
        canvas.save()
        canvas.clipRect(repRect)
        canvas.drawRect(
            scanX - (8f * scale), repRect.top, scanX + (8f * scale), repRect.bottom,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    scanX - (10f * scale), repRect.top, scanX + (10f * scale), repRect.top,
                    intArrayOf(Color.TRANSPARENT, Color.argb(40, 47, 226, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.restore()
        // Expanding signal pulse rings
        val pulseCycle = ((presentationTimeUs / 1000L) % 1600L).toFloat() / 1600f
        val pulseRadius = repRadius * (1.1f + (0.5f * pulseCycle))
        val pulseAlpha = (1f - pulseCycle) * 0.35f
        canvas.drawCircle(
            repCenter, repCenterY, pulseRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(magenta, pulseAlpha)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.5f * scale)
            },
        )
        // Rep digit
        canvas.drawText(
            state.repCount.toString(),
            repCenter, repCenterY + (repSize * 0.20f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                textAlign = Paint.Align.CENTER
                textSize = min(repRadius * 0.82f, 50f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(160, 0, 0, 0))
            },
        )
        // LIVE chip
        canvas.drawRoundRect(
            RectF(repCenter - (18f * scale), repRect.bottom - (22f * scale), repCenter + (18f * scale), repRect.bottom - (10f * scale)),
            99f, 99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(magenta, 0.88f) },
        )
        canvas.drawText(
            "LIVE",
            repCenter, repRect.bottom - (13f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.WHITE
                textAlign = Paint.Align.CENTER
                textSize = max(7f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
        // Top label
        canvas.drawText(
            "CONVERSION SIGNAL",
            repCenter, repRect.top - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(magenta, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            },
        )
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FASHION DESIGNER — Atelier runway overlay
    // Colors: black, champagne gold, soft blush, ivory, pearl silver, lavender
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawFashionDesignerOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 44f * scale
        val barHeight = 18f * scale  // ultra-thin runway strip
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)

        val repSize = 94f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)

        val champagne = Color.rgb(231, 207, 162)
        val blush = Color.rgb(241, 221, 230)
        val ivory = Color.rgb(234, 224, 206)
        val lavender = Color.rgb(201, 190, 223)
        val nearBlack = Color.rgb(23, 20, 23)
        val shimmerPhase = ((presentationTimeUs / 1000L) % 2400L).toFloat() / 2400f
        val pulse = ((sin(presentationTimeUs / 520000.0) + 1.0) / 2.0).toFloat()

        // ── Fashion Accuracy bar: ultra-thin runway strip with stitch borders ──
        // Outer stitch-line border top
        val stitchPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(champagne, 0.48f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
            pathEffect = android.graphics.DashPathEffect(floatArrayOf(4f * scale, 3.5f * scale), 0f)
        }
        canvas.drawLine(barRect.left, barRect.top - (4f * scale), barRect.right, barRect.top - (4f * scale), stitchPaint)
        canvas.drawLine(barRect.left, barRect.bottom + (4f * scale), barRect.right, barRect.bottom + (4f * scale), stitchPaint)

        // Track background
        canvas.drawRect(
            barRect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    barRect.left, barRect.top, barRect.right, barRect.top,
                    intArrayOf(Color.argb(220, 23, 20, 23), Color.argb(210, 42, 35, 42)),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Fill: champagne gold → ivory, sharp triangular hem at leading edge
        if (safeAccuracy > 0f) {
            val fillRight = barRect.left + (barRect.width() * safeAccuracy)
            val hemCut = barHeight * 0.5f
            val fillPath = Path().apply {
                moveTo(barRect.left, barRect.top)
                lineTo(fillRight - hemCut, barRect.top)
                lineTo(fillRight, barRect.centerY())
                lineTo(fillRight - hemCut, barRect.bottom)
                lineTo(barRect.left, barRect.bottom)
                close()
            }
            canvas.drawPath(
                fillPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        barRect.left, barRect.top, fillRight, barRect.top,
                        intArrayOf(
                            Color.argb(200, 42, 35, 42),
                            adjustAlpha(champagne, 0.90f),
                            adjustAlpha(ivory, 0.96f),
                        ),
                        floatArrayOf(0f, 0.50f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
            // Lavender shimmer sweep
            val shimX = barRect.left + (barRect.width() * shimmerPhase)
            canvas.drawRect(
                shimX - (9f * scale), barRect.top, shimX + (9f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        shimX - (11f * scale), barRect.top, shimX + (11f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(55, 201, 190, 223), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP,
                    )
                },
            )
        }
        // Pattern marks × at 25%, 50%, 75%
        val markPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(champagne, 0.50f)
            textAlign = Paint.Align.CENTER
            textSize = max(7f, barHeight * 0.62f)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        listOf(0.25f, 0.5f, 0.75f).forEach { frac ->
            canvas.drawText("×", barRect.left + (barRect.width() * frac), barRect.centerY() + (barHeight * 0.28f), markPaint)
        }
        // 80% threshold
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawLine(
            markerX, barRect.top - (8f * scale), markerX, barRect.bottom + (8f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(ivory, 0.72f)
                strokeWidth = max(1f, 1f * scale)
            },
        )
        // Bar border
        canvas.drawRect(
            barRect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(champagne, 0.28f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.9f * scale)
            },
        )
        // Accuracy text
        canvas.drawText(
            "${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(ivory, 0.96f) else adjustAlpha(champagne, 0.88f)
                textAlign = Paint.Align.CENTER
                textSize = max(9f, barHeight * 0.58f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            },
        )
        // Fashion micro-labels
        val fashionLabels = listOf("CRAFTED", "ALIGNED", "SILHOUETTE", "ATELIER")
        val fashionLabelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(lavender, 0.68f)
            textAlign = Paint.Align.CENTER
            textSize = max(8f, 8f * scale)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        fashionLabels.forEachIndexed { i, label ->
            val frac = 0.125f + (i * 0.25f)
            canvas.drawText(label, barRect.left + (barRect.width() * frac), barRect.bottom + (12f * scale), fashionLabelPaint)
        }

        // ── Fashion Rep counter: high-fashion monogram plaque ──
        val cornerChamfer = repSize * 0.08f
        val plaqueRadius = repSize * 0.10f
        // Drop shadow
        canvas.drawRoundRect(
            RectF(repRect.left + (2f * scale), repRect.top + (4f * scale), repRect.right + (2f * scale), repRect.bottom + (4f * scale)),
            plaqueRadius, plaqueRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(90, 0, 0, 0)
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        // Plaque background
        canvas.drawRoundRect(
            repRect, plaqueRadius, plaqueRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    repRect.left, repRect.top, repRect.left, repRect.bottom,
                    intArrayOf(
                        Color.argb(245, 28, 22, 28),
                        Color.argb(255, 18, 14, 18),
                    ),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Fabric drape subtle gradient (diagonal)
        canvas.drawRoundRect(
            repRect, plaqueRadius, plaqueRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    repRect.left, repRect.top, repRect.right, repRect.bottom,
                    intArrayOf(Color.argb(30, 201, 190, 223), Color.TRANSPARENT, Color.argb(18, 201, 190, 223)),
                    floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )
        // Outer border — thin double line
        canvas.drawRoundRect(
            repRect, plaqueRadius, plaqueRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(champagne, 0.72f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.2f, 1.3f * scale)
            },
        )
        canvas.drawRoundRect(
            RectF(repRect.left + (3.5f * scale), repRect.top + (3.5f * scale), repRect.right - (3.5f * scale), repRect.bottom - (3.5f * scale)),
            plaqueRadius * 0.6f, plaqueRadius * 0.6f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(champagne, 0.20f)
                style = Paint.Style.STROKE
                strokeWidth = max(0.8f, 0.9f * scale)
            },
        )
        // Lavender shimmer sweep on plaque
        val plaqueShimX = repRect.left + (repRect.width() * shimmerPhase)
        canvas.save()
        canvas.clipRect(repRect)
        canvas.drawRect(
            plaqueShimX - (12f * scale), repRect.top, plaqueShimX + (12f * scale), repRect.bottom,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    plaqueShimX - (14f * scale), repRect.top, plaqueShimX + (14f * scale), repRect.top,
                    intArrayOf(Color.TRANSPARENT, Color.argb(52, 201, 190, 223), Color.TRANSPARENT),
                    floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.restore()
        // Glass highlight top half
        canvas.save()
        canvas.clipRect(repRect)
        canvas.drawRoundRect(
            RectF(repRect.left, repRect.top, repRect.right, repRect.top + (repSize * 0.42f)),
            plaqueRadius, plaqueRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    repRect.left, repRect.top, repRect.left, repRect.top + (repSize * 0.42f),
                    intArrayOf(Color.argb(50, 255, 255, 255), Color.TRANSPARENT),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.restore()
        // 4 corner pin diamonds ◈
        val pinColor = adjustAlpha(champagne, 0.60f)
        val pinPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = pinColor
            textAlign = Paint.Align.CENTER
            textSize = max(8f, 8f * scale)
        }
        val pinInset = 10f * scale
        listOf(
            repRect.left + pinInset to repRect.top + pinInset,
            repRect.right - pinInset to repRect.top + pinInset,
            repRect.left + pinInset to repRect.bottom - pinInset,
            repRect.right - pinInset to repRect.bottom - pinInset,
        ).forEach { (px, py) ->
            canvas.drawText("◈", px, py + (4f * scale), pinPaint)
        }
        // Watermark FD
        canvas.drawText(
            "FD",
            repRect.centerX(), repRect.centerY() + (repSize * 0.10f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(18, 231, 207, 162)
                textAlign = Paint.Align.CENTER
                textSize = repSize * 0.66f
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
        // Phase indicator line
        val fashionPhaseColor = when (state.phase) {
            "up" -> champagne
            "down" -> blush
            else -> lavender
        }
        canvas.drawRoundRect(
            RectF(repRect.left + (12f * scale), repRect.top + (8f * scale), repRect.right - (12f * scale), repRect.top + (10.5f * scale)),
            99f, 99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(fashionPhaseColor, 0.80f) },
        )
        // Rep digit — slender, champagne gold
        canvas.drawText(
            state.repCount.toString(),
            repRect.centerX(), repRect.centerY() + (repSize * 0.22f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(champagne, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(repSize * 0.50f, 46f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(120, 0, 0, 0))
            },
        )
        // ATELIER micro-caps beneath digit
        canvas.drawText(
            "ATELIER",
            repRect.centerX(), repRect.bottom - (10f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(lavender, 0.76f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            },
        )
        // Top label
        canvas.drawText(
            "ATELIER LUXE",
            repRect.centerX(), repRect.top - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(champagne, 0.62f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            },
        )
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BEAUTICIAN — Radiance glow beauty studio overlay
    // Colors: rose gold, pearl white, soft nude, champagne, warm peach
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawBeauticianOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)

        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val roseGold = Color.rgb(240, 199, 184)
        val peach = Color.rgb(231, 167, 194)
        val champagne = Color.rgb(255, 223, 168)
        val pearl = Color.rgb(255, 245, 240)
        val nude = Color.rgb(231, 192, 174)
        val neonPink = Color.rgb(255, 120, 180)
        val pulse = ((sin(presentationTimeUs / 460000.0) + 1.0) / 2.0).toFloat()
        val shimmerPhase = ((presentationTimeUs / 1000L) % 2600L).toFloat() / 2600f

        // ── Ambient: warm beauty studio bloom behind canvas ──
        canvas.drawRect(
            0f, 0f, width, height,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    width * 0.72f, height * 0.30f, width * 0.65f,
                    intArrayOf(Color.argb(15, 240, 199, 184), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )

        // ── Beautician Accuracy bar: smooth glow-meter pill ──
        val pillRadius = barHeight * 0.5f
        // Outer neon glow
        canvas.drawRoundRect(
            barRect, pillRadius, pillRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonPink, 0.20f + (0.12f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 8f * scale)
                maskFilter = BlurMaskFilter(10f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        // Double glass rim outer
        canvas.drawRoundRect(
            barRect, pillRadius, pillRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(200, 42, 28, 36), Color.argb(220, 32, 20, 28)),
                    null, Shader.TileMode.CLAMP,
                )
            },
        )
        // Fill: rose gold → champagne
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(
                barRect, pillRadius, pillRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(
                            Color.argb(215, 42, 28, 36),
                            adjustAlpha(roseGold, 0.92f),
                            adjustAlpha(champagne, 0.96f),
                        ),
                        floatArrayOf(0f, 0.52f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
            // Luminous shimmer sweep
            val shimX = barRect.left + (fillWidth * shimmerPhase)
            canvas.drawRect(
                shimX - (10f * scale), barRect.top, shimX + (10f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        shimX - (12f * scale), barRect.top, shimX + (12f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(70, 255, 240, 225), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP,
                    )
                },
            )
            // Top gloss highlight
            canvas.drawRoundRect(
                RectF(barRect.left, barRect.top, barRect.left + fillWidth, barRect.top + (barHeight * 0.42f)),
                pillRadius, pillRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        barRect.left, barRect.top, barRect.left, barRect.top + (barHeight * 0.42f),
                        intArrayOf(Color.argb(68, 255, 255, 255), Color.TRANSPARENT),
                        null, Shader.TileMode.CLAMP,
                    )
                },
            )
            canvas.restore()
        }
        // Inner glass rim strokes
        canvas.drawRoundRect(
            barRect, pillRadius, pillRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(roseGold, 0.45f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.2f, 1.3f * scale)
            },
        )
        canvas.drawRoundRect(
            RectF(barRect.left + (2f * scale), barRect.top + (2f * scale), barRect.right - (2f * scale), barRect.bottom - (2f * scale)),
            pillRadius, pillRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(peach, 0.20f)
                style = Paint.Style.STROKE
                strokeWidth = max(0.8f, 0.9f * scale)
            },
        )
        // Micro-labels inside bar
        val beautyLabels = listOf("GLOW", "BALANCED", "REFRESHED", "RADIANT")
        val beautyLabelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize = max(8f, 8.5f * scale)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        beautyLabels.forEachIndexed { i, label ->
            val frac = 0.125f + (i * 0.25f)
            val labelX = barRect.left + (barRect.width() * frac)
            val labelAlpha = if (frac <= safeAccuracy + 0.13f) 0.88f else 0.42f
            beautyLabelPaint.color = adjustAlpha(pearl, labelAlpha)
            canvas.drawText(label, labelX, barRect.bottom + (12f * scale), beautyLabelPaint)
        }
        // 80% threshold marker
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(pearl, 0.82f) },
        )
        // Accuracy text
        canvas.drawText(
            "${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(pearl, 0.98f) else adjustAlpha(roseGold, 0.92f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(120, 0, 0, 0))
            },
        )

        // ── Beautician Rep counter: gem-like vanity mirror frame ──
        val repRadius = repSize / 2f
        // Warm bloom halo
        canvas.drawCircle(
            repCenter, repCenterY, repRadius * 1.3f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    repCenter, repCenterY, repRadius * 1.3f,
                    intArrayOf(Color.argb((28 + (18 * pulse)).toInt(), 240, 199, 184), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )
        // Shell background
        canvas.drawCircle(
            repCenter, repCenterY, repRadius - (5f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    repCenter, repCenterY, repRadius,
                    intArrayOf(
                        Color.argb(245, 42, 28, 36),
                        Color.argb(255, 32, 20, 28),
                    ),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )
        // Outer ring: rose gold → peach → champagne
        canvas.drawCircle(
            repCenter, repCenterY, repRadius - (2.5f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = SweepGradient(
                    repCenter, repCenterY,
                    intArrayOf(roseGold, peach, champagne, pearl, roseGold),
                    null,
                )
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 6f * scale)
            },
        )
        // Neon highlight glow ring
        canvas.drawCircle(
            repCenter, repCenterY, repRadius + (3f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonPink, 0.16f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(4f, 6f * scale)
                maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        // 12 sparkle diamonds ✦ around outer ring
        val sparkleCount = 12
        val sparkleRadius = repRadius + (10f * scale)
        val sparkleSize = max(7f, 7f * scale)
        repeat(sparkleCount) { i ->
            val angle = Math.toRadians((i * (360.0 / sparkleCount)) - 90.0)
            val sx = repCenter + (kotlin.math.cos(angle).toFloat() * sparkleRadius)
            val sy = repCenterY + (kotlin.math.sin(angle).toFloat() * sparkleRadius)
            val sparkleAlpha = if (safeAccuracy >= 0.8f) 0.88f else 0.40f + (0.20f * pulse)
            canvas.drawText(
                "✦", sx, sy + (sparkleSize * 0.35f),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(if (i % 3 == 0) champagne else roseGold, sparkleAlpha)
                    textAlign = Paint.Align.CENTER
                    textSize = sparkleSize
                },
            )
        }
        // High-accuracy sparkle particles
        if (safeAccuracy >= 0.80f) {
            val particleCount = 6
            val particlePhase = ((presentationTimeUs / 1000L) % 1800L).toFloat() / 1800f
            repeat(particleCount) { i ->
                val angle = Math.toRadians(((i * 60.0) + (particlePhase * 360.0)))
                val pRadius = repRadius * (0.95f + (0.30f * ((i % 3) * 0.16f)))
                val px = repCenter + (kotlin.math.cos(angle).toFloat() * pRadius)
                val py = repCenterY + (kotlin.math.sin(angle).toFloat() * pRadius)
                val pAlpha = ((safeAccuracy - 0.8f) / 0.2f) * (0.7f - ((i.toFloat() / particleCount) * 0.3f))
                canvas.drawCircle(
                    px, py, (2.2f + (i % 2)) * scale,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(pearl, pAlpha)
                        maskFilter = BlurMaskFilter(3f * scale, BlurMaskFilter.Blur.NORMAL)
                    },
                )
            }
        }
        // Glass highlight
        canvas.drawCircle(
            repCenter - (repRadius * 0.16f), repCenterY - (repRadius * 0.20f), repRadius * 0.54f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    repCenter - (repRadius * 0.16f), repCenterY - (repRadius * 0.20f), repRadius * 0.54f,
                    intArrayOf(Color.argb(62, 255, 255, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP,
                )
            },
        )
        // Phase indicator inner ring
        val beautyPhaseColor = when (state.phase) {
            "up" -> roseGold
            "down" -> peach
            else -> champagne
        }
        canvas.drawCircle(
            repCenter, repCenterY, repRadius - (8f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(beautyPhaseColor, 0.65f)
                style = Paint.Style.STROKE
                strokeWidth = max(2f, 2.5f * scale)
            },
        )
        // Rep digit
        canvas.drawText(
            state.repCount.toString(),
            repCenter, repCenterY + (repSize * 0.20f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(pearl, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(repRadius * 0.80f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(140, 0, 0, 0))
            },
        )
        // RADIANCE micro-caps beneath digit
        canvas.drawText(
            "RADIANCE",
            repCenter, repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(roseGold, 0.80f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            },
        )
        // Top label
        canvas.drawText(
            "RADIANCE GLOW",
            repCenter, repRect.top - (8f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(peach, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            },
        )
    }

    // ═══════════════════════════════════════════════════════════════════════
    // DOCTOR — Medical telemetry precision overlay
    // Colors: clean white, deep navy, silver, soft red, teal
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawDoctorOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val white = Color.rgb(245, 248, 252)
        val navy = Color.rgb(18, 32, 56)
        val silver = Color.rgb(192, 204, 216)
        val softRed = Color.rgb(220, 72, 80)
        val teal = Color.rgb(48, 192, 180)
        val pulse = ((sin(presentationTimeUs / 440000.0) + 1.0) / 2.0).toFloat()
        val ecgPhase = ((presentationTimeUs / 1000L) % 2200L).toFloat() / 2200f

        // ── Ambient: subtle ECG pulse line above bar ──
        val ecgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(55, 48, 192, 180)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1.2f * scale)
            strokeCap = Paint.Cap.ROUND
        }
        val ecgPath = Path()
        val ecgY = barTop - (14f * scale)
        val ecgW = barWidth * 0.55f
        ecgPath.moveTo(sideInset, ecgY)
        // Flat baseline, then spike, then return
        val spikeX = sideInset + (ecgW * ecgPhase)
        ecgPath.lineTo(spikeX - (20f * scale), ecgY)
        ecgPath.lineTo(spikeX - (8f * scale), ecgY)
        ecgPath.lineTo(spikeX - (4f * scale), ecgY - (10f * scale))
        ecgPath.lineTo(spikeX, ecgY + (8f * scale))
        ecgPath.lineTo(spikeX + (5f * scale), ecgY - (5f * scale))
        ecgPath.lineTo(spikeX + (9f * scale), ecgY)
        ecgPath.lineTo(sideInset + ecgW, ecgY)
        canvas.drawPath(ecgPath, ecgPaint)

        // ── Doctor Accuracy bar: vital-signs precision bar ──
        val trackRadius = barHeight * 0.22f
        // Track
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(210, 18, 32, 56), Color.argb(228, 12, 22, 38)),
                    null, Shader.TileMode.CLAMP)
            })
        // Calibration ticks
        val calPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(60, 48, 192, 180)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
        }
        (1..9).forEach { i ->
            val x = barRect.left + (barRect.width() * (i / 10f))
            val tickH = if (i % 5 == 0) barHeight * 0.55f else barHeight * 0.28f
            canvas.drawLine(x, barRect.top + ((barHeight - tickH) / 2f), x, barRect.bottom - ((barHeight - tickH) / 2f), calPaint)
        }
        // Fill
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(barRect, trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(Color.argb(200, 18, 32, 56), adjustAlpha(teal, 0.90f), adjustAlpha(white, 0.94f)),
                        floatArrayOf(0f, 0.52f, 1f), Shader.TileMode.CLAMP)
                })
            // Heartbeat scan shimmer
            val scanX = barRect.left + (fillWidth * ecgPhase)
            canvas.drawRect(scanX - (8f * scale), barRect.top, scanX + (8f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(scanX - (10f * scale), barRect.top, scanX + (10f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(65, 48, 192, 180), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                })
            canvas.restore()
        }
        // 80% threshold marker
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(softRed, 0.88f) })
        // Bar stroke
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.30f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        // Micro-labels
        listOf("VITALS", "STABLE", "SYNC", "DIAGNOSTIC").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(teal, 0.72f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        // Accuracy text
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(white, 0.96f) else adjustAlpha(teal, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            })

        // ── Doctor Rep counter: octagonal health gauge ──
        val octRadius = repSize / 2f
        // Outer glow
        canvas.drawCircle(repCenter, repCenterY, octRadius * 1.08f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.18f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = octRadius * 0.18f
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Octagon shape
        val octPath = Path()
        repeat(8) { i ->
            val angle = Math.toRadians((i * 45.0) - 22.5)
            val x = repCenter + (octRadius * kotlin.math.cos(angle).toFloat())
            val y = repCenterY + (octRadius * kotlin.math.sin(angle).toFloat())
            if (i == 0) octPath.moveTo(x, y) else octPath.lineTo(x, y)
        }
        octPath.close()
        // Octagon fill
        canvas.drawPath(octPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(repCenter, repCenterY, octRadius,
                intArrayOf(Color.argb(235, 24, 42, 68), Color.argb(250, 12, 22, 38)),
                floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
        })
        // Glass highlight
        canvas.drawPath(octPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(repRect.left, repRect.top, repRect.left, repRect.top + (repSize * 0.44f),
                intArrayOf(Color.argb(55, 255, 255, 255), Color.TRANSPARENT),
                null, Shader.TileMode.CLAMP)
        })
        // Octagon ring border
        canvas.drawPath(octPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = SweepGradient(repCenter, repCenterY, intArrayOf(silver, teal, white, teal, silver), null)
            style = Paint.Style.STROKE
            strokeWidth = max(2f, 2.5f * scale)
        })
        // Inner ring
        val innerOctPath = Path()
        repeat(8) { i ->
            val angle = Math.toRadians((i * 45.0) - 22.5)
            val r = octRadius - (7f * scale)
            val x = repCenter + (r * kotlin.math.cos(angle).toFloat())
            val y = repCenterY + (r * kotlin.math.sin(angle).toFloat())
            if (i == 0) innerOctPath.moveTo(x, y) else innerOctPath.lineTo(x, y)
        }
        innerOctPath.close()
        canvas.drawPath(innerOctPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(teal, 0.22f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.9f * scale)
        })
        // Phase indicator
        val docPhaseColor = when (state.phase) { "up" -> teal; "down" -> softRed; else -> silver }
        canvas.drawCircle(repCenter, repCenterY, octRadius - (10f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(docPhaseColor, 0.55f)
                style = Paint.Style.STROKE
                strokeWidth = max(2f, 2.5f * scale)
            })
        // Pulse dot
        canvas.drawCircle(repCenter, repRect.top + (8f * scale), 3f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(softRed, 0.85f + (0.15f * pulse)) })
        // Rep digit
        canvas.drawText(state.repCount.toString(), repCenter, repCenterY + (repSize * 0.22f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(white, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(octRadius * 0.80f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(130, 0, 0, 0))
            })
        canvas.drawText("REPS", repCenter, repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(silver, 0.78f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText("DIAGNOSTIC READY", repCenter, repRect.top - (7f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7f, 7f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // TEACHER — Academic knowledge overlay
    // Colors: ivory, navy, warm gold, soft green, charcoal
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawTeacherOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 44f * scale
        val barHeight = 24f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 95f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)

        val ivory = Color.rgb(236, 228, 208)
        val navy = Color.rgb(24, 38, 72)
        val warmGold = Color.rgb(212, 172, 88)
        val softGreen = Color.rgb(104, 168, 120)
        val charcoal = Color.rgb(52, 56, 64)
        val pulse = ((sin(presentationTimeUs / 500000.0) + 1.0) / 2.0).toFloat()
        val pagePhase = ((presentationTimeUs / 1000L) % 3200L).toFloat() / 3200f

        // ── Ambient: faint classroom grid above bar ──
        val gridPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(22, 104, 168, 120)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.7f * scale)
        }
        repeat(5) { i ->
            val x = sideInset + (barWidth * ((i + 1) / 6f))
            canvas.drawLine(x, barTop - (22f * scale), x, barTop - (4f * scale), gridPaint)
        }
        canvas.drawLine(sideInset, barTop - (16f * scale), sideInset + barWidth * 0.86f, barTop - (16f * scale), gridPaint)

        // ── Teacher Accuracy bar: chalk-line / index card bar ──
        val trackRadius = barHeight * 0.26f
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(215, 24, 38, 72), Color.argb(230, 18, 28, 52)),
                    null, Shader.TileMode.CLAMP)
            })
        // Chalk underline marks
        val chalkPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(55, 236, 228, 208)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.9f * scale)
            pathEffect = android.graphics.DashPathEffect(floatArrayOf(5f * scale, 4f * scale), 0f)
        }
        canvas.drawLine(barRect.left + (4f * scale), barRect.bottom - (3f * scale),
            barRect.right - (4f * scale), barRect.bottom - (3f * scale), chalkPaint)
        // Annotation marks (small × at thirds)
        val annotatePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(warmGold, 0.55f)
            textAlign = Paint.Align.CENTER
            textSize = max(8f, barHeight * 0.55f)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        listOf(0.33f, 0.66f).forEach { frac ->
            canvas.drawText("✓", barRect.left + (barRect.width() * frac), barRect.centerY() + (barHeight * 0.25f), annotatePaint)
        }
        // Fill: highlighting glow gradient
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(barRect, trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(Color.argb(200, 24, 38, 72), adjustAlpha(softGreen, 0.88f), adjustAlpha(warmGold, 0.94f)),
                        floatArrayOf(0f, 0.55f, 1f), Shader.TileMode.CLAMP)
                })
            // Page-turn shimmer at leading edge
            val shimX = barRect.left + fillWidth
            canvas.drawRect(shimX - (10f * scale), barRect.top, shimX + (4f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(shimX - (12f * scale), barRect.top, shimX + (5f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(60, 236, 228, 208), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.6f, 1f), Shader.TileMode.CLAMP)
                })
            canvas.restore()
        }
        // 80% marker
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(warmGold, 0.85f) })
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(softGreen, 0.28f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        listOf("LESSON", "FOCUS", "CLARITY", "OPTIMAL").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(softGreen, 0.70f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(ivory, 0.96f) else adjustAlpha(warmGold, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            })

        // ── Teacher Rep counter: academic lecture plaque (rounded rect) ──
        val pCorner = repSize * 0.12f
        canvas.drawRoundRect(RectF(repRect.left + (2f * scale), repRect.top + (4f * scale), repRect.right + (2f * scale), repRect.bottom + (4f * scale)),
            pCorner, pCorner, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(80, 0, 0, 0)
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        canvas.drawRoundRect(repRect, pCorner, pCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(repRect.left, repRect.top, repRect.left, repRect.bottom,
                    intArrayOf(Color.argb(240, 24, 38, 72), Color.argb(252, 16, 28, 52)),
                    null, Shader.TileMode.CLAMP)
            })
        // Page highlight glow moving across plaque
        val pageShimX = repRect.left + (repRect.width() * pagePhase)
        canvas.save()
        canvas.clipRect(repRect)
        canvas.drawRect(pageShimX - (14f * scale), repRect.top, pageShimX + (14f * scale), repRect.bottom,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(pageShimX - (16f * scale), repRect.top, pageShimX + (16f * scale), repRect.top,
                    intArrayOf(Color.TRANSPARENT, Color.argb(38, 212, 172, 88), Color.TRANSPARENT),
                    floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
            })
        canvas.restore()
        // Glass highlight
        canvas.drawRoundRect(RectF(repRect.left, repRect.top, repRect.right, repRect.top + (repSize * 0.40f)),
            pCorner, pCorner, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(repRect.left, repRect.top, repRect.left, repRect.top + (repSize * 0.40f),
                    intArrayOf(Color.argb(52, 255, 255, 255), Color.TRANSPARENT), null, Shader.TileMode.CLAMP)
            })
        // Double border
        canvas.drawRoundRect(repRect, pCorner, pCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(warmGold, 0.70f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.5f, 1.5f * scale)
            })
        canvas.drawRoundRect(RectF(repRect.left + (4f * scale), repRect.top + (4f * scale), repRect.right - (4f * scale), repRect.bottom - (4f * scale)),
            pCorner * 0.6f, pCorner * 0.6f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(softGreen, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.9f * scale)
            })
        // Teal glow halo
        canvas.drawRoundRect(repRect, pCorner, pCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(softGreen, 0.12f + (0.08f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 6f * scale)
                maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Phase bar at top
        val teachPhaseColor = when (state.phase) { "up" -> softGreen; "down" -> warmGold; else -> ivory }
        canvas.drawRoundRect(RectF(repRect.left + (8f * scale), repRect.top + (7f * scale), repRect.right - (8f * scale), repRect.top + (10f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(teachPhaseColor, 0.85f) })
        // Watermark
        canvas.drawText("✎", repRect.centerX(), repRect.centerY() + (repSize * 0.12f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(20, 236, 228, 208)
                textAlign = Paint.Align.CENTER
                textSize = repSize * 0.60f
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText(state.repCount.toString(), repRect.centerX(), repRect.centerY() + (repSize * 0.22f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(ivory, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(repSize * 0.52f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(130, 0, 0, 0))
            })
        canvas.drawText("REPS", repRect.centerX(), repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(warmGold, 0.80f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText("OPTIMAL FLOW", repRect.centerX(), repRect.top - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(softGreen, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // PHARMACIST — Clinical apothecary overlay
    // Colors: emerald, white, silver, soft amber, deep graphite + gold
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawPharmacistOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val emerald = Color.rgb(52, 186, 128)
        val white = Color.rgb(246, 250, 248)
        val silver = Color.rgb(194, 206, 200)
        val amber = Color.rgb(212, 162, 72)
        val graphite = Color.rgb(38, 42, 46)
        val gold = Color.rgb(198, 158, 82)
        val pulse = ((sin(presentationTimeUs / 420000.0) + 1.0) / 2.0).toFloat()
        val shimmerPhase = ((presentationTimeUs / 1000L) % 2000L).toFloat() / 2000f

        // ── Pharmacist Accuracy bar: capsule-segment bar ──
        val pillRadius = barHeight * 0.50f
        // Track
        canvas.drawRoundRect(barRect, pillRadius, pillRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(218, 38, 42, 46), Color.argb(232, 26, 30, 34)),
                    null, Shader.TileMode.CLAMP)
            })
        // Molecular lattice nodes above bar
        val nodePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(44, 52, 186, 128) }
        val bondPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(28, 52, 186, 128)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
        }
        val nodePositions = listOf(0.10f to 0f, 0.22f to -1f, 0.34f to 0f, 0.46f to -1f, 0.58f to 0f)
        nodePositions.forEach { (xFrac, yOff) ->
            val nx = barRect.left + (barWidth * xFrac)
            val ny = barTop - (12f + (yOff * 6f)) * scale
            canvas.drawCircle(nx, ny, 3f * scale, nodePaint)
        }
        for (i in 0 until nodePositions.size - 1) {
            val (x1f, y1o) = nodePositions[i]; val (x2f, y2o) = nodePositions[i + 1]
            canvas.drawLine(barRect.left + (barWidth * x1f), barTop - (12f + (y1o * 6f)) * scale,
                barRect.left + (barWidth * x2f), barTop - (12f + (y2o * 6f)) * scale, bondPaint)
        }
        // Capsule segment dividers
        val capsulePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(65, 52, 186, 128)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.9f * scale)
        }
        listOf(0.25f, 0.5f, 0.75f).forEach { frac ->
            canvas.drawLine(barRect.left + (barRect.width() * frac), barRect.top + (3f * scale),
                barRect.left + (barRect.width() * frac), barRect.bottom - (3f * scale), capsulePaint)
        }
        // Fill
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(barRect, pillRadius, pillRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(Color.argb(200, 38, 42, 46), adjustAlpha(emerald, 0.88f), adjustAlpha(white, 0.92f)),
                        floatArrayOf(0f, 0.52f, 1f), Shader.TileMode.CLAMP)
                })
            // Sterile shimmer
            val shimX = barRect.left + (fillWidth * shimmerPhase)
            canvas.drawRect(shimX - (9f * scale), barRect.top, shimX + (9f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(shimX - (11f * scale), barRect.top, shimX + (11f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(62, 52, 186, 128), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                })
            canvas.restore()
        }
        // Dosage marks
        listOf(0.25f, 0.5f, 0.75f, 1.0f).forEach { frac ->
            if (frac <= safeAccuracy + 0.01f) {
                val x = barRect.left + (barRect.width() * frac)
                canvas.drawLine(x, barRect.top - (4f * scale), x, barRect.top - (9f * scale),
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(amber, 0.72f)
                        style = Paint.Style.STROKE
                        strokeWidth = max(1f, 0.9f * scale)
                    })
            }
        }
        // 80% threshold
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(amber, 0.88f) })
        canvas.drawRoundRect(barRect, pillRadius, pillRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(emerald, 0.32f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        listOf("Rx", "DOSE", "STERILE", "VERIFIED").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(emerald, 0.70f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(white, 0.96f) else adjustAlpha(emerald, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            })

        // ── Pharmacist Rep counter: translucent capsule counter ──
        val capsuleW = repSize
        val capsuleH = repSize * 0.72f
        val capsuleTop = repCenterY - (capsuleH / 2f)
        val capsuleRect = RectF(repCenter - (capsuleW / 2f), capsuleTop, repCenter + (capsuleW / 2f), capsuleTop + capsuleH)
        val capCorner = capsuleH / 2f
        // Drop shadow
        canvas.drawRoundRect(RectF(capsuleRect.left + (2f * scale), capsuleRect.top + (4f * scale), capsuleRect.right + (2f * scale), capsuleRect.bottom + (4f * scale)),
            capCorner, capCorner, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(85, 0, 0, 0)
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Capsule background — left half emerald, right half white/silver
        canvas.save()
        canvas.clipRect(capsuleRect.left, capsuleRect.top, capsuleRect.centerX(), capsuleRect.bottom)
        canvas.drawRoundRect(capsuleRect, capCorner, capCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(230, 38, 42, 46) })
        canvas.restore()
        canvas.save()
        canvas.clipRect(capsuleRect.centerX(), capsuleRect.top, capsuleRect.right, capsuleRect.bottom)
        canvas.drawRoundRect(capsuleRect, capCorner, capCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(capsuleRect.centerX(), capsuleRect.top, capsuleRect.right, capsuleRect.top,
                    intArrayOf(Color.argb(210, 52, 186, 128), Color.argb(230, 30, 150, 100)),
                    null, Shader.TileMode.CLAMP)
            })
        canvas.restore()
        // Seam divider
        canvas.drawLine(capsuleRect.centerX(), capsuleRect.top + (4f * scale), capsuleRect.centerX(), capsuleRect.bottom - (4f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(120, 194, 206, 200); strokeWidth = max(1.5f, 1.5f * scale) })
        // Glass sheen
        canvas.save()
        canvas.clipRect(capsuleRect)
        canvas.drawRoundRect(RectF(capsuleRect.left, capsuleRect.top, capsuleRect.right, capsuleRect.top + (capsuleH * 0.40f)),
            capCorner, capCorner, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(capsuleRect.left, capsuleRect.top, capsuleRect.left, capsuleRect.top + (capsuleH * 0.40f),
                    intArrayOf(Color.argb(62, 255, 255, 255), Color.TRANSPARENT), null, Shader.TileMode.CLAMP)
            })
        // Shimmer
        val capShimX = capsuleRect.left + (capsuleRect.width() * shimmerPhase)
        canvas.drawRect(capShimX - (10f * scale), capsuleRect.top, capShimX + (10f * scale), capsuleRect.bottom,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(capShimX - (12f * scale), capsuleRect.top, capShimX + (12f * scale), capsuleRect.top,
                    intArrayOf(Color.TRANSPARENT, Color.argb(48, 246, 250, 248), Color.TRANSPARENT),
                    floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
            })
        canvas.restore()
        // Border
        canvas.drawRoundRect(capsuleRect, capCorner, capCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(emerald, 0.60f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.5f, 1.5f * scale)
            })
        canvas.drawRoundRect(capsuleRect, capCorner, capCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(emerald, 0.16f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 7f * scale)
                maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Glow dot at top
        canvas.drawCircle(repCenter, repTopY, 3f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(gold, 0.88f) })
        // Phase indicator
        val pharmPhaseColor = when (state.phase) { "up" -> emerald; "down" -> amber; else -> silver }
        canvas.drawRoundRect(RectF(capsuleRect.left + (8f * scale), capsuleRect.top + (4f * scale), capsuleRect.centerX() - (4f * scale), capsuleRect.top + (6.5f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(pharmPhaseColor, 0.80f) })
        canvas.drawText(state.repCount.toString(), repCenter, repCenterY + (capsuleH * 0.24f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(white, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(capsuleH * 0.58f, 46f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(130, 0, 0, 0))
            })
        canvas.drawText("DOSE", repCenter, capsuleRect.bottom - (7f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(silver, 0.78f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText("APOTHECARY", repCenter, repRect.top - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(emerald, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7f, 7f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // NURSE — Compassionate care telemetry overlay
    // Colors: calming blue, white, silver, teal, gentle coral
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawNurseOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val calmBlue = Color.rgb(88, 148, 212)
        val white = Color.rgb(244, 248, 252)
        val silver = Color.rgb(190, 204, 218)
        val teal = Color.rgb(64, 192, 182)
        val coral = Color.rgb(232, 128, 112)
        val pulse = ((sin(presentationTimeUs / 460000.0) + 1.0) / 2.0).toFloat()
        val sweepPhase = ((presentationTimeUs / 1000L) % 2400L).toFloat() / 2400f

        // ── Ambient: soft pulse sweep glow ──
        canvas.drawRect(0f, 0f, width, height,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(width * 0.70f, height * 0.28f, width * 0.55f,
                    intArrayOf(Color.argb(12, 88, 148, 212), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })

        // ── Nurse Accuracy bar: rounded patient-monitor bar with care indicators ──
        val trackRadius = barHeight * 0.50f  // fully rounded pill
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(215, 28, 46, 72), Color.argb(230, 18, 32, 52)),
                    null, Shader.TileMode.CLAMP)
            })
        // Pulse sweep indicator
        val sweepX = barRect.left + (barRect.width() * sweepPhase)
        canvas.drawRect(sweepX - (6f * scale), barRect.top, sweepX + (6f * scale), barRect.bottom,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(sweepX - (8f * scale), barRect.top, sweepX + (8f * scale), barRect.top,
                    intArrayOf(Color.TRANSPARENT, Color.argb(38, 64, 192, 182), Color.TRANSPARENT),
                    floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
            })
        // Fill
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(barRect, trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(Color.argb(200, 28, 46, 72), adjustAlpha(calmBlue, 0.88f), adjustAlpha(teal, 0.92f)),
                        floatArrayOf(0f, 0.52f, 1f), Shader.TileMode.CLAMP)
                })
            // Soft glow transition shimmer
            val shimX = barRect.left + (fillWidth * sweepPhase)
            canvas.drawRect(shimX - (10f * scale), barRect.top, shimX + (10f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(shimX - (12f * scale), barRect.top, shimX + (12f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(55, 244, 248, 252), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                })
            // Top gloss
            canvas.drawRoundRect(RectF(barRect.left, barRect.top, barRect.left + fillWidth, barRect.top + (barHeight * 0.40f)),
                trackRadius, trackRadius, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.top + (barHeight * 0.40f),
                        intArrayOf(Color.argb(65, 255, 255, 255), Color.TRANSPARENT), null, Shader.TileMode.CLAMP)
                })
            canvas.restore()
        }
        // 80% threshold
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(coral, 0.88f) })
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.30f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        listOf("STABLE", "ASSISTED", "MONITORED", "CARE+").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(teal, 0.72f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(white, 0.96f) else adjustAlpha(calmBlue, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            })

        // ── Nurse Rep counter: rounded telemetry shield ──
        val shieldRadius = repSize / 2f
        // Warm halo
        canvas.drawCircle(repCenter, repCenterY, shieldRadius * 1.12f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(calmBlue, 0.14f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = shieldRadius * 0.18f
                maskFilter = BlurMaskFilter(14f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Shell
        canvas.drawCircle(repCenter, repCenterY, shieldRadius - (5f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(repCenter, repCenterY, shieldRadius,
                    intArrayOf(Color.argb(238, 28, 46, 72), Color.argb(252, 16, 30, 48)),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })
        // Ring: calm blue → teal sweep
        canvas.drawCircle(repCenter, repCenterY, shieldRadius - (3f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = SweepGradient(repCenter, repCenterY,
                    intArrayOf(calmBlue, teal, white, coral, calmBlue), null)
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 6f * scale)
            })
        // Soft coral glow ring
        canvas.drawCircle(repCenter, repCenterY, shieldRadius + (3f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(coral, 0.14f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(4f, 6f * scale)
                maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Inner care ring
        canvas.drawCircle(repCenter, repCenterY, shieldRadius - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        // Phase indicator
        val nursePhaseColor = when (state.phase) { "up" -> teal; "down" -> calmBlue; else -> coral }
        canvas.drawCircle(repCenter, repCenterY, shieldRadius - (11f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(nursePhaseColor, 0.55f)
                style = Paint.Style.STROKE
                strokeWidth = max(2f, 2.5f * scale)
            })
        // Pulse ring expanding
        val nursePulseCycle = ((presentationTimeUs / 1000L) % 1600L).toFloat() / 1600f
        canvas.drawCircle(repCenter, repCenterY, shieldRadius * (1.05f + (0.4f * nursePulseCycle)),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(calmBlue, (1f - nursePulseCycle) * 0.28f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.5f * scale)
            })
        // Glass highlight
        canvas.drawCircle(repCenter - (shieldRadius * 0.15f), repCenterY - (shieldRadius * 0.18f), shieldRadius * 0.50f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(repCenter - (shieldRadius * 0.15f), repCenterY - (shieldRadius * 0.18f), shieldRadius * 0.50f,
                    intArrayOf(Color.argb(58, 255, 255, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })
        canvas.drawText(state.repCount.toString(), repCenter, repCenterY + (repSize * 0.20f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(white, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(shieldRadius * 0.80f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(130, 0, 0, 0))
            })
        canvas.drawText("REPS", repCenter, repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(silver, 0.80f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText("CARE MONITOR", repCenter, repRect.top - (7f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(teal, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7f, 7f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ACCOUNTANT — Enterprise fiscal precision overlay
    // Colors: graphite, gold, emerald, black, silver
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawAccountantOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val graphite = Color.rgb(48, 52, 58)
        val gold = Color.rgb(198, 158, 72)
        val emerald = Color.rgb(56, 168, 112)
        val nearBlack = Color.rgb(18, 20, 22)
        val silver = Color.rgb(188, 196, 206)
        val pulse = ((sin(presentationTimeUs / 480000.0) + 1.0) / 2.0).toFloat()

        // ── Accountant Accuracy bar: audit ledger bar ──
        val trackRadius = barHeight * 0.18f  // slightly rectangular
        // Ledger grid above bar
        val ledgerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(28, 198, 158, 72)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.7f * scale)
        }
        canvas.drawLine(sideInset, barTop - (18f * scale), sideInset + barWidth, barTop - (18f * scale), ledgerPaint)
        canvas.drawLine(sideInset, barTop - (10f * scale), sideInset + barWidth, barTop - (10f * scale), ledgerPaint)
        listOf(0.2f, 0.4f, 0.6f, 0.8f).forEach { frac ->
            canvas.drawLine(sideInset + (barWidth * frac), barTop - (22f * scale),
                sideInset + (barWidth * frac), barTop - (4f * scale), ledgerPaint)
        }
        // Track
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(215, 48, 52, 58), Color.argb(230, 30, 33, 36)),
                    null, Shader.TileMode.CLAMP)
            })
        // Tick marks
        val tickPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(62, 198, 158, 72)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
        }
        (1..19).forEach { i ->
            val x = barRect.left + (barRect.width() * (i / 20f))
            val h = if (i % 5 == 0) barHeight * 0.60f else barHeight * 0.28f
            canvas.drawLine(x, barRect.top + ((barHeight - h) / 2f), x, barRect.bottom - ((barHeight - h) / 2f), tickPaint)
        }
        // Fill
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(barRect, trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(Color.argb(200, 48, 52, 58), adjustAlpha(emerald, 0.85f), adjustAlpha(gold, 0.92f)),
                        floatArrayOf(0f, 0.55f, 1f), Shader.TileMode.CLAMP)
                })
            // Fine shimmer
            val shimX = barRect.left + (fillWidth * ((presentationTimeUs / 2000000.0 % 1.0).toFloat()))
            canvas.drawRect(shimX - (8f * scale), barRect.top, shimX + (8f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(shimX - (10f * scale), barRect.top, shimX + (10f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(55, 198, 158, 72), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                })
            canvas.restore()
        }
        // 80% marker
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(RectF(markerX - (1.5f * scale), barRect.top + (1f * scale), markerX + (1.5f * scale), barRect.bottom - (1f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(gold, 0.90f) })
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(gold, 0.28f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        listOf("AUDITED", "BALANCED", "VERIFIED", "NOMINAL").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(gold, 0.68f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(silver, 0.96f) else adjustAlpha(gold, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1f * scale, Color.argb(100, 0, 0, 0))
            })

        // ── Accountant Rep counter: metallic audit badge ──
        val badgeCorner = repSize * 0.10f
        canvas.drawRoundRect(RectF(repRect.left + (2f * scale), repRect.top + (4f * scale), repRect.right + (2f * scale), repRect.bottom + (4f * scale)),
            badgeCorner, badgeCorner, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(88, 0, 0, 0)
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        canvas.drawRoundRect(repRect, badgeCorner, badgeCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(repRect.left, repRect.top, repRect.left, repRect.bottom,
                    intArrayOf(Color.argb(245, 48, 52, 58), Color.argb(255, 24, 26, 28)),
                    null, Shader.TileMode.CLAMP)
            })
        // Metallic sheen gradient top
        canvas.drawRoundRect(RectF(repRect.left, repRect.top, repRect.right, repRect.top + (repSize * 0.42f)),
            badgeCorner, badgeCorner, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(repRect.left, repRect.top, repRect.left, repRect.top + (repSize * 0.42f),
                    intArrayOf(Color.argb(62, 255, 255, 255), Color.TRANSPARENT), null, Shader.TileMode.CLAMP)
            })
        // Gold diagonal stripe accent
        canvas.save()
        canvas.clipRect(repRect)
        val stripePath = Path().apply {
            moveTo(repRect.left, repRect.top + (repSize * 0.15f))
            lineTo(repRect.left + (repSize * 0.22f), repRect.top)
            lineTo(repRect.left + (repSize * 0.30f), repRect.top)
            lineTo(repRect.left, repRect.top + (repSize * 0.23f))
            close()
        }
        canvas.drawPath(stripePath, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(gold, 0.14f) })
        canvas.restore()
        // Double border
        canvas.drawRoundRect(repRect, badgeCorner, badgeCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(gold, 0.70f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.5f, 1.6f * scale)
            })
        canvas.drawRoundRect(RectF(repRect.left + (4f * scale), repRect.top + (4f * scale), repRect.right - (4f * scale), repRect.bottom - (4f * scale)),
            badgeCorner * 0.6f, badgeCorner * 0.6f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(emerald, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.9f * scale)
            })
        // Gold glow halo
        canvas.drawRoundRect(repRect, badgeCorner, badgeCorner,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(gold, 0.12f + (0.08f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 7f * scale)
                maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Phase indicator
        val accPhaseColor = when (state.phase) { "up" -> emerald; "down" -> gold; else -> silver }
        canvas.drawRoundRect(RectF(repRect.left + (8f * scale), repRect.top + (7f * scale), repRect.right - (8f * scale), repRect.top + (10f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(accPhaseColor, 0.85f) })
        // Watermark ₿ → use ∑ for accountant
        canvas.drawText("∑", repRect.centerX(), repRect.centerY() + (repSize * 0.10f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(20, 198, 158, 72)
                textAlign = Paint.Align.CENTER
                textSize = repSize * 0.65f
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText(state.repCount.toString(), repCenter, repCenterY + (repSize * 0.22f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(silver, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(repSize * 0.52f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(130, 0, 0, 0))
            })
        canvas.drawText("REPS", repCenter, repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(gold, 0.80f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText("AUDIT VERIFIED", repCenter, repRect.top - (6f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(emerald, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7f, 7f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // DATA SCIENTIST — Neural analytics glassmorphism overlay
    // Colors: deep navy, cyan, violet, silver, black + neon highlights
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawDataScientistOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 26f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val navy = Color.rgb(14, 22, 46)
        val cyan = Color.rgb(42, 218, 255)
        val violet = Color.rgb(128, 72, 220)
        val silver = Color.rgb(186, 198, 216)
        val nearBlack = Color.rgb(10, 14, 22)
        val neonCyan = Color.rgb(0, 232, 255)
        val neonViolet = Color.rgb(148, 82, 255)
        val pulse = ((sin(presentationTimeUs / 380000.0) + 1.0) / 2.0).toFloat()
        val dataPhase = ((presentationTimeUs / 1000L) % 1800L).toFloat() / 1800f

        // ── Ambient: neural network node canvas bloom ──
        canvas.drawRect(0f, 0f, width, height,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(width * 0.75f, height * 0.22f, width * 0.60f,
                    intArrayOf(Color.argb(14, 42, 218, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })
        // Data pipeline node graph above bar
        val nodeR = 3.5f * scale
        val nodeCyan = Color.argb(52, 42, 218, 255)
        val nodeViolet = Color.argb(38, 128, 72, 220)
        val edgePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(28, 42, 218, 255)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
        }
        val nodes = listOf(
            sideInset + barWidth * 0.08f to barTop - (16f * scale),
            sideInset + barWidth * 0.22f to barTop - (10f * scale),
            sideInset + barWidth * 0.38f to barTop - (18f * scale),
            sideInset + barWidth * 0.54f to barTop - (8f * scale),
            sideInset + barWidth * 0.70f to barTop - (16f * scale),
        )
        nodes.forEachIndexed { i, (nx, ny) ->
            canvas.drawCircle(nx, ny, nodeR, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = if (i % 2 == 0) nodeCyan else nodeViolet })
        }
        for (i in 0 until nodes.size - 1) {
            canvas.drawLine(nodes[i].first, nodes[i].second, nodes[i + 1].first, nodes[i + 1].second, edgePaint)
        }
        // Animated data pulse dot on pipeline
        val pulseDotIdx = (dataPhase * (nodes.size - 1)).toInt().coerceIn(0, nodes.size - 2)
        val pulseFrac = (dataPhase * (nodes.size - 1)) - pulseDotIdx
        val pdx = nodes[pulseDotIdx].first + ((nodes[pulseDotIdx + 1].first - nodes[pulseDotIdx].first) * pulseFrac)
        val pdy = nodes[pulseDotIdx].second + ((nodes[pulseDotIdx + 1].second - nodes[pulseDotIdx].second) * pulseFrac)
        canvas.drawCircle(pdx, pdy, 5f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonCyan, 0.82f)
                maskFilter = BlurMaskFilter(5f * scale, BlurMaskFilter.Blur.NORMAL)
            })

        // ── Data Scientist Accuracy bar: heatmap pipeline bar ──
        val trackRadius = barHeight * 0.28f
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(220, 14, 22, 46), Color.argb(235, 8, 14, 28)),
                    null, Shader.TileMode.CLAMP)
            })
        // Heatmap fill: uses multi-stop gradient for pipeline depth
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            canvas.drawRoundRect(barRect, trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left + barRect.width(), barRect.top,
                        intArrayOf(
                            Color.argb(200, 14, 22, 46),
                            adjustAlpha(violet, 0.88f),
                            adjustAlpha(cyan, 0.94f),
                            adjustAlpha(neonCyan, 1f),
                        ),
                        floatArrayOf(0f, 0.35f, 0.70f, 1f),
                        Shader.TileMode.CLAMP)
                })
            // Flowing data pulse shimmer
            val shimX = barRect.left + (fillWidth * dataPhase)
            canvas.drawRect(shimX - (10f * scale), barRect.top, shimX + (10f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(shimX - (12f * scale), barRect.top, shimX + (12f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, Color.argb(72, 42, 218, 255), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                })
            // Prediction trace lines
            val tracePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(38, 255, 255, 255)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.8f * scale)
            }
            repeat(2) { i ->
                val ty = barRect.top + (barRect.height() * (0.28f + (i * 0.44f)))
                val tracePath = Path()
                var x = barRect.left; var first = true
                while (x <= barRect.left + fillWidth) {
                    val frac = (x - barRect.left) / barRect.width()
                    val y = ty + (sin((frac * Math.PI * 5) + (presentationTimeUs / 300000.0) + (i * Math.PI)).toFloat() * (2.2f * scale))
                    if (first) { tracePath.moveTo(x, y); first = false } else tracePath.lineTo(x, y)
                    x += 3f * scale
                }
                canvas.drawPath(tracePath, tracePaint)
            }
            canvas.restore()
        }
        // 80% threshold marker (neon)
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawRoundRect(RectF(markerX - (1.5f * scale), barRect.top + (2f * scale), markerX + (1.5f * scale), barRect.bottom - (2f * scale)),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(neonViolet, 0.88f) })
        canvas.drawRoundRect(RectF(markerX - (4f * scale), barRect.top, markerX + (4f * scale), barRect.bottom),
            99f, 99f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonViolet, 0.22f)
                maskFilter = BlurMaskFilter(6f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(cyan, 0.32f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        listOf("MODEL", "ACCURACY", "LATENCY", "CONFIDENCE").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(cyan, 0.70f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.30f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) adjustAlpha(neonCyan, 0.98f) else adjustAlpha(cyan, 0.90f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(120, 0, 0, 0))
            })

        // ── Data Scientist Rep counter: luminous data node cluster ──
        val dsRadius = repSize / 2f
        // Outer neon bloom
        canvas.drawCircle(repCenter, repCenterY, dsRadius * 1.18f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(cyan, 0.16f + (0.10f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = dsRadius * 0.20f
                maskFilter = BlurMaskFilter(16f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Glassmorphism shell — semi-transparent dark
        canvas.drawCircle(repCenter, repCenterY, dsRadius - (4f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(repCenter, repCenterY - (dsRadius * 0.15f), dsRadius,
                    intArrayOf(Color.argb(210, 24, 36, 72), Color.argb(240, 10, 14, 26)),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })
        // Glassmorphism back-light shimmer (translucent layer)
        canvas.drawCircle(repCenter - (dsRadius * 0.14f), repCenterY - (dsRadius * 0.18f), dsRadius * 0.60f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(repCenter - (dsRadius * 0.14f), repCenterY - (dsRadius * 0.18f), dsRadius * 0.60f,
                    intArrayOf(Color.argb(50, 42, 218, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })
        // Ring: violet → cyan neon gradient
        canvas.drawCircle(repCenter, repCenterY, dsRadius - (2f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = SweepGradient(repCenter, repCenterY,
                    intArrayOf(violet, cyan, neonCyan, neonViolet, violet), null)
                style = Paint.Style.STROKE
                strokeWidth = max(5f, 6.5f * scale)
            })
        // Neon glow ring
        canvas.drawCircle(repCenter, repCenterY, dsRadius + (2f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonCyan, 0.20f + (0.12f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(4f, 6f * scale)
                maskFilter = BlurMaskFilter(10f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // 6 satellite data nodes orbiting
        val orbitR = dsRadius + (14f * scale)
        repeat(6) { i ->
            val baseAngle = Math.toRadians((i * 60.0) - 90.0)
            val nx = repCenter + (orbitR * kotlin.math.cos(baseAngle).toFloat())
            val ny = repCenterY + (orbitR * kotlin.math.sin(baseAngle).toFloat())
            canvas.drawCircle(nx, ny, 2.8f * scale,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(if (i % 2 == 0) cyan else violet, 0.75f)
                    maskFilter = BlurMaskFilter(3f * scale, BlurMaskFilter.Blur.NORMAL)
                })
        }
        // Animated orbit dot
        val orbitAngle = Math.toRadians((dataPhase * 360.0) - 90.0)
        val orbitDotX = repCenter + (orbitR * kotlin.math.cos(orbitAngle).toFloat())
        val orbitDotY = repCenterY + (orbitR * kotlin.math.sin(orbitAngle).toFloat())
        canvas.drawCircle(orbitDotX, orbitDotY, 4f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonCyan, 0.90f)
                maskFilter = BlurMaskFilter(4f * scale, BlurMaskFilter.Blur.NORMAL)
            })
        // Inner ring
        canvas.drawCircle(repCenter, repCenterY, dsRadius - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(cyan, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            })
        // Phase ring
        val dsPhaseColor = when (state.phase) { "up" -> neonCyan; "down" -> neonViolet; else -> silver }
        canvas.drawCircle(repCenter, repCenterY, dsRadius - (11f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(dsPhaseColor, 0.55f)
                style = Paint.Style.STROKE
                strokeWidth = max(2f, 2.5f * scale)
            })
        // Expanding data ping
        val dsPingCycle = ((presentationTimeUs / 1000L) % 1400L).toFloat() / 1400f
        canvas.drawCircle(repCenter, repCenterY, dsRadius * (1.08f + (0.40f * dsPingCycle)),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(cyan, (1f - dsPingCycle) * 0.26f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.5f * scale)
            })
        // Glass highlight
        canvas.drawCircle(repCenter - (dsRadius * 0.15f), repCenterY - (dsRadius * 0.18f), dsRadius * 0.48f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(repCenter - (dsRadius * 0.15f), repCenterY - (dsRadius * 0.18f), dsRadius * 0.48f,
                    intArrayOf(Color.argb(55, 255, 255, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 1f), Shader.TileMode.CLAMP)
            })
        canvas.drawText(state.repCount.toString(), repCenter, repCenterY + (repSize * 0.20f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonCyan, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = min(dsRadius * 0.80f, 48f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(5f * scale, 0f, 2f * scale, adjustAlpha(cyan, 0.55f))
            })
        canvas.drawText("SYNC", repCenter, repRect.bottom - (9f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(violet, 0.82f)
                textAlign = Paint.Align.CENTER
                textSize = max(7.5f, 7.5f * scale)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })
        canvas.drawText("CONFIDENCE CORE", repCenter, repRect.top - (8f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(cyan, 0.65f)
                textAlign = Paint.Align.CENTER
                textSize = max(7f, 7f * scale)
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
            })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ELECTRICAL ENGINEER — Voltage Precision Interface
    // Colors: cyan, amber, violet, white, dark graphite
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawElectricalEngineerOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 24f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val cyan = Color.rgb(0, 220, 255)
        val amber = Color.rgb(255, 180, 0)
        val violet = Color.rgb(160, 80, 255)
        val white = Color.rgb(255, 255, 255)
        val graphite = Color.rgb(30, 34, 40)
        val pulse = ((sin(presentationTimeUs / 240000.0) + 1.0) / 2.0).toFloat()
        val surgePhase = ((presentationTimeUs / 1000L) % 1200L).toFloat() / 1200f

        // ── Electrical Accuracy bar: Voltage Waveform Channel ──
        val trackRadius = 4f * scale
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                    intArrayOf(Color.argb(250, 30, 34, 40), Color.argb(250, 16, 20, 24)),
                    null, Shader.TileMode.CLAMP)
            })

        // Grid nodes
        val nodePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(60, 0, 220, 255)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1f * scale)
        }
        val circuitGap = barWidth / 12f
        for (i in 0..12) {
            val cx = barRect.left + (i * circuitGap)
            canvas.drawCircle(cx, barRect.top - (6f * scale), 2f * scale, nodePaint)
            if (i > 0) {
                canvas.drawLine(cx - circuitGap + (3f * scale), barRect.top - (6f * scale),
                    cx - (3f * scale), barRect.top - (6f * scale), nodePaint)
            }
        }

        // Fill
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.save()
            canvas.clipRect(barRect.left, barRect.top, barRect.left + fillWidth, barRect.bottom)
            
            // Segmented glow conductors
            val segments = 20
            val segW = barWidth / segments
            for (i in 0..segments) {
                val sx = barRect.left + (i * segW)
                if (sx < barRect.left + fillWidth) {
                    val colorPhase = if (i % 3 == 0) amber else cyan
                    canvas.drawRect(sx + (1f * scale), barRect.top + (2f * scale), sx + segW - (1f * scale), barRect.bottom - (2f * scale),
                        Paint(Paint.ANTI_ALIAS_FLAG).apply {
                            shader = LinearGradient(sx, barRect.top, sx, barRect.bottom,
                                intArrayOf(adjustAlpha(colorPhase, 0.4f), adjustAlpha(white, 0.9f), adjustAlpha(colorPhase, 0.4f)),
                                floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                        })
                }
            }
            
            // Electric surge moving right
            val surgeX = barRect.left + (fillWidth * surgePhase)
            canvas.drawRect(surgeX - (10f * scale), barRect.top, surgeX + (10f * scale), barRect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(surgeX - (10f * scale), barRect.top, surgeX + (10f * scale), barRect.top,
                        intArrayOf(Color.TRANSPARENT, adjustAlpha(cyan, 0.8f), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                    xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.SCREEN)
                })
            canvas.restore()
        }
        // 80% mark - polarity node
        val markerX = barRect.left + (barRect.width() * 0.8f)
        canvas.drawCircle(markerX, barRect.top - (6f * scale), 4f * scale, 
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(amber, 0.90f) })
            
        canvas.drawRoundRect(barRect, trackRadius, trackRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(violet, 0.50f)
                style = Paint.Style.STROKE
                strokeWidth = max(1.5f, 1.5f * scale)
            })

        listOf("VOLTS", "WAVEFORM", "POLARITY", "CIRCUIT").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (11f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(cyan, 0.80f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }

        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.centerX(), barRect.centerY() + (barHeight * 0.35f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) white else cyan
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.48f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(4f * scale, 0f, 0f, adjustAlpha(cyan, 0.8f))
            })

        // ── Electrical Rep counter: Hexagonal Relay Panel ──
        val hexR = repSize / 2f
        val hexPath = Path()
        for (i in 0..5) {
            val angle = Math.toRadians((i * 60.0) + 30.0)
            val px = repCenter + (hexR * kotlin.math.cos(angle).toFloat())
            val py = repCenterY + (hexR * kotlin.math.sin(angle).toFloat())
            if (i == 0) hexPath.moveTo(px, py) else hexPath.lineTo(px, py)
        }
        hexPath.close()

        // Outer glow
        canvas.drawPath(hexPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(cyan, 0.20f + (0.10f * pulse))
            style = Paint.Style.STROKE
            strokeWidth = hexR * 0.15f
            maskFilter = BlurMaskFilter(16f * scale, BlurMaskFilter.Blur.NORMAL)
        })
        
        canvas.drawPath(hexPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(240, 20, 24, 30)
            style = Paint.Style.FILL
        })

        val hexStrokePath = Path()
        for (i in 0..5) {
            val angle = Math.toRadians((i * 60.0) + 30.0)
            val px = repCenter + ((hexR - (4f * scale)) * kotlin.math.cos(angle).toFloat())
            val py = repCenterY + ((hexR - (4f * scale)) * kotlin.math.sin(angle).toFloat())
            if (i == 0) hexStrokePath.moveTo(px, py) else hexStrokePath.lineTo(px, py)
        }
        hexStrokePath.close()

        canvas.drawPath(hexStrokePath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(repRect.left, repRect.top, repRect.right, repRect.bottom,
                intArrayOf(cyan, violet, amber), null, Shader.TileMode.CLAMP)
            style = Paint.Style.STROKE
            strokeWidth = max(3f, 3f * scale)
        })
        
        // Inner digital dial
        canvas.drawCircle(repCenter, repCenterY, hexR * 0.65f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(cyan, 0.1f)
            style = Paint.Style.FILL
        })
        
        val phaseCol = when (state.phase) { "up" -> cyan; "down" -> violet; else -> amber }
        canvas.drawCircle(repCenter, repCenterY, hexR * 0.65f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(phaseCol, 0.8f)
            style = Paint.Style.STROKE
            strokeWidth = max(2f, 2f * scale)
            pathEffect = android.graphics.DashPathEffect(floatArrayOf(5f * scale, 5f * scale), 0f)
        })
        
        val currentSurge = ((presentationTimeUs / 1000L) % 800L).toFloat() / 800f
        canvas.drawCircle(repCenter, repCenterY, hexR * 0.65f + (hexR * 0.35f * currentSurge), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(cyan, (1f - currentSurge) * 0.5f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1f * scale)
        })

        val repCountValue = state.repCount ?: 0
        canvas.drawText("$repCountValue", repCenter, repCenterY + (hexR * 0.25f), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(white, 0.95f)
            textAlign = Paint.Align.CENTER
            textSize = min(hexR * 0.80f, 48f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            setShadowLayer(8f * scale, 0f, 0f, adjustAlpha(cyan, 0.8f))
        })
        
        canvas.drawText("⚡", repCenter, repCenterY - (hexR * 0.35f), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(amber, 0.85f)
            textAlign = Paint.Align.CENTER
            textSize = min(hexR * 0.30f, 24f * scale)
        })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // MECHANICAL ENGINEER — Torque Calibration Interface
    // Colors: steel silver, gold, charcoal, bronze, red
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawMechanicalEngineerOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 28f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val silver = Color.rgb(180, 190, 200)
        val brushedGold = Color.rgb(205, 175, 100)
        val charcoal = Color.rgb(45, 45, 50)
        val bronze = Color.rgb(160, 110, 70)
        val redCal = Color.rgb(220, 50, 40)
        val gearRot = ((presentationTimeUs / 1000L).toFloat() / 20f)

        // ── Mechanical Accuracy bar: Calibrated sliding rail ──
        val trackRadius = 2f * scale
        val railPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                intArrayOf(Color.argb(255, 60, 60, 65), Color.argb(255, 30, 30, 35), Color.argb(255, 60, 60, 65)),
                floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
        }
        canvas.drawRoundRect(barRect, trackRadius, trackRadius, railPaint)
        
        val redTickPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(redCal, 0.70f)
            strokeWidth = max(2f, 2f * scale)
            style = Paint.Style.STROKE
        }
        val silverTickPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(silver, 0.50f)
            strokeWidth = max(1f, 1f * scale)
            style = Paint.Style.STROKE
        }
        
        for (i in 0..40) {
            val cx = barRect.left + (barWidth * (i / 40f))
            if (i % 5 == 0) {
                canvas.drawLine(cx, barRect.top - (5f * scale), cx, barRect.bottom, redTickPaint)
            } else {
                canvas.drawLine(cx, barRect.top, cx, barRect.bottom, silverTickPaint)
            }
        }

        // Fill - Heavy metal slider
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            canvas.drawRoundRect(
                barRect.left, barRect.top + (2f * scale), barRect.left + fillWidth, barRect.bottom - (2f * scale),
                trackRadius, trackRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(barRect.left, barRect.top, barRect.left, barRect.bottom,
                        intArrayOf(adjustAlpha(brushedGold, 0.8f), adjustAlpha(bronze, 0.9f), adjustAlpha(brushedGold, 0.8f)),
                        floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                }
            )
            // Slider head
            canvas.drawRoundRect(
                barRect.left + fillWidth - (8f * scale), barRect.top - (4f * scale), barRect.left + fillWidth, barRect.bottom + (4f * scale),
                2f * scale, 2f * scale,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(0f, barRect.top, 0f, barRect.bottom, intArrayOf(silver, Color.GRAY, silver), null, Shader.TileMode.CLAMP)
                }
            )
            canvas.drawLine(barRect.left + fillWidth - (4f * scale), barRect.top, barRect.left + fillWidth - (4f * scale), barRect.bottom, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = charcoal; strokeWidth = 2f * scale })
        }
        
        // Target bracket
        val markerX = barRect.left + (barRect.width() * 0.8f)
        val bracketPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = redCal
            style = Paint.Style.STROKE
            strokeWidth = 3f * scale
            strokeCap = Paint.Cap.SQUARE
        }
        canvas.drawPath(Path().apply {
            moveTo(markerX - (6f * scale), barRect.top - (6f * scale))
            lineTo(markerX, barRect.top - (6f * scale))
            lineTo(markerX, barRect.bottom + (6f * scale))
            lineTo(markerX - (6f * scale), barRect.bottom + (6f * scale))
        }, bracketPaint)

        canvas.drawRoundRect(barRect, trackRadius, trackRadius, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = charcoal; style = Paint.Style.STROKE; strokeWidth = 2f * scale
        })

        listOf("TORQUE", "ALIGNMENT", "TOLERANCE", "LOAD").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (12f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(silver, 0.85f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
        }

        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.left + (barWidth * 0.5f), barRect.bottom + (28f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (safeAccuracy >= 0.8f) brushedGold else silver
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.50f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            })

        // ── Mechanical Rep counter: Gear & Metal Hex Nut ──
        val gearR = repSize / 2f
        canvas.save()
        canvas.translate(repCenter, repCenterY)
        canvas.rotate(gearRot)

        val gearPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(0f, 0f, gearR,
                intArrayOf(charcoal, Color.BLACK), null, Shader.TileMode.CLAMP)
        }
        canvas.drawCircle(0f, 0f, gearR, gearPaint)

        val toothPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = bronze
            style = Paint.Style.STROKE
            strokeWidth = 6f * scale
        }
        for (i in 0..11) {
            val a = Math.toRadians(i * 30.0)
            val dx = (gearR * kotlin.math.cos(a)).toFloat()
            val dy = (gearR * kotlin.math.sin(a)).toFloat()
            canvas.drawLine(dx * 0.8f, dy * 1.15f, dx * 1.15f, dy * 1.15f, toothPaint) // Need a good gear draw, let's keep it simple
            canvas.drawLine(dx * 0.85f, dy * 0.85f, dx * 1.08f, dy * 1.08f, toothPaint) 
        }
        canvas.restore()

        // Inner Hex Nut panel
        val hexPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(repRect.left, repRect.top, repRect.right, repRect.bottom,
                intArrayOf(silver, Color.GRAY, silver), null, Shader.TileMode.CLAMP)
        }
        val innerHexR = gearR * 0.75f
        val nutPath = Path()
        for (i in 0..5) {
            val a = Math.toRadians((i * 60.0) + 30.0)
            val px = repCenter + (innerHexR * kotlin.math.cos(a).toFloat())
            val py = repCenterY + (innerHexR * kotlin.math.sin(a).toFloat())
            if (i == 0) nutPath.moveTo(px, py) else nutPath.lineTo(px, py)
        }
        nutPath.close()
        canvas.drawPath(nutPath, hexPaint)
        
        // Bevel rim
        canvas.drawPath(nutPath, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.BLACK; style = Paint.Style.STROKE; strokeWidth = 2f * scale
        })
        
        // Piston lock ring inner
        val phaseCol = when (state.phase) { "up" -> brushedGold; "down" -> bronze; else -> silver }
        canvas.drawCircle(repCenter, repCenterY, innerHexR * 0.6f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = charcoal
            style = Paint.Style.FILL
        })
        canvas.drawCircle(repCenter, repCenterY, innerHexR * 0.6f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = phaseCol
            style = Paint.Style.STROKE
            strokeWidth = 3f * scale
        })

        canvas.drawText("${state.repCount ?: 0}", repCenter, repCenterY + (innerHexR * 0.35f), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = silver
            textAlign = Paint.Align.CENTER
            textSize = min(innerHexR * 1.0f, 48f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            setShadowLayer(4f * scale, 0f, 2f * scale, Color.BLACK)
        })
    }

    // ═══════════════════════════════════════════════════════════════════════
    // COMPUTER NETWORK ENGINEER — Signal Matrix Interface
    // Colors: deep navy, neon blue, cyan, silver, magenta
    // ═══════════════════════════════════════════════════════════════════════
    private fun drawNetworkEngineerOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val safeAccuracy = state.accuracy.coerceIn(0f, 1f)
        val sideInset = 20f * scale
        val barTop = 40f * scale
        val barHeight = 22f * scale
        val barWidth = width - (sideInset * 2f)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val repSize = 96f * scale
        val repLeft = width - sideInset - repSize
        val repTopY = 84f * scale
        val repRect = RectF(repLeft, repTopY, repLeft + repSize, repTopY + repSize)
        val repCenter = repRect.centerX()
        val repCenterY = repRect.centerY()

        val navy = Color.rgb(10, 15, 30)
        val neonBlue = Color.rgb(20, 120, 255)
        val cyan = Color.rgb(0, 240, 255)
        val silver = Color.rgb(200, 210, 220)
        val magenta = Color.rgb(220, 40, 255)
        val white = Color.rgb(255, 255, 255)
        val dataPhase = ((presentationTimeUs / 1000L).toFloat() % 1500f) / 1500f

        // ── IT Accuracy bar: Packet Transmission Strip ──
        canvas.drawRect(barRect, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(200, 10, 15, 30) })
        canvas.drawRect(barRect, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = navy; style = Paint.Style.STROKE; strokeWidth = 2f * scale })
        
        // Node clusters above
        for (i in 0..5) {
            val nx = barRect.left + (barWidth * (i / 5f))
            canvas.drawRect(nx - (2f * scale), barRect.top - (8f * scale), nx + (2f * scale), barRect.top, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonBlue, 0.7f)
            })
            canvas.drawCircle(nx, barRect.top - (10f * scale), 3f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = cyan
                setShadowLayer(4f * scale, 0f, 0f, cyan)
            })
        }

        // Fill Data Blocks
        if (safeAccuracy > 0f) {
            val fillWidth = barRect.width() * safeAccuracy
            val blockCount = 20
            val blockW = (fillWidth / blockCount) - (2f * scale)
            val gap = 2f * scale
            
            for (i in 0 until blockCount) {
                val bx = barRect.left + (i * (blockW + gap))
                val blockPhase = if (i % 4 == 0) magenta else cyan
                canvas.drawRect(bx, barRect.top + (2f * scale), bx + blockW, barRect.bottom - (2f * scale), 
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(blockPhase, 0.85f)
                    }
                )
            }
            
            // Pulse sweep
            val pingX = barRect.left + (barWidth * dataPhase)
            canvas.drawLine(pingX, barRect.top - (15f * scale), pingX, barRect.bottom + (15f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = white
                strokeWidth = 3f * scale
                setShadowLayer(6f * scale, 0f, 0f, cyan)
            })
        }
        
        val markerX = barRect.left + (barWidth * 0.8f)
        canvas.drawRect(markerX - (3f * scale), barRect.top - (4f * scale), markerX + (3f * scale), barRect.bottom + (4f * scale), Paint().apply {
            color = adjustAlpha(magenta, 0.9f)
            style = Paint.Style.STROKE
            strokeWidth = 2f * scale
        })

        listOf("LATENCY", "THROUGHPUT", "SYNC", "PACKET").forEachIndexed { i, label ->
            canvas.drawText(label, barRect.left + (barRect.width() * (0.125f + i * 0.25f)), barRect.bottom + (12f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = silver
                    textAlign = Paint.Align.CENTER
                    textSize = max(8f, 8.5f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                })
        }
        
        canvas.drawText("${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}%",
            barRect.left + (barRect.width() * 0.5f), barRect.bottom + (26f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = cyan
                textAlign = Paint.Align.CENTER
                textSize = max(10f, barHeight * 0.5f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 0f, neonBlue)
            })

        // ── IT Rep counter: Server Tile Node ──
        val nodeW = repSize * 0.9f
        val nodeH = repSize * 0.9f
        val nodeRect = RectF(repCenter - (nodeW/2), repCenterY - (nodeH/2), repCenter + (nodeW/2), repCenterY + (nodeH/2))
        
        canvas.drawRect(nodeRect, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(220, 15, 20, 35)
        })
        canvas.drawRect(nodeRect, Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = neonBlue
            style = Paint.Style.STROKE
            strokeWidth = max(2f, 2f * scale)
            setShadowLayer(8f * scale, 0f, 0f, cyan)
        })

        // Corner server brackets
        val cornerS = 12f * scale
        val bracketP = Paint().apply { color = cyan; strokeWidth = 3f * scale; style = Paint.Style.STROKE }
        canvas.drawPath(Path().apply {
            moveTo(nodeRect.left, nodeRect.top + cornerS); lineTo(nodeRect.left, nodeRect.top); lineTo(nodeRect.left + cornerS, nodeRect.top)
            moveTo(nodeRect.right - cornerS, nodeRect.top); lineTo(nodeRect.right, nodeRect.top); lineTo(nodeRect.right, nodeRect.top + cornerS)
            moveTo(nodeRect.left, nodeRect.bottom - cornerS); lineTo(nodeRect.left, nodeRect.bottom); lineTo(nodeRect.left + cornerS, nodeRect.bottom)
            moveTo(nodeRect.right - cornerS, nodeRect.bottom); lineTo(nodeRect.right, nodeRect.bottom); lineTo(nodeRect.right, nodeRect.bottom - cornerS)
        }, bracketP)

        // Route pulsing lines
        for (i in 0..4) {
            val ly = nodeRect.top + ((i + 1) * (nodeH / 6f))
            canvas.drawLine(nodeRect.left + (5f * scale), ly, nodeRect.right - (5f * scale), ly, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(neonBlue, 0.4f)
                strokeWidth = 1f * scale
            })
        }

        val phaseCol = when (state.phase) { "up" -> cyan; "down" -> magenta; else -> silver }
        canvas.drawRect(nodeRect.left + (10f * scale), nodeRect.bottom - (12f * scale), nodeRect.right - (10f * scale), nodeRect.bottom - (6f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(phaseCol, 0.9f)
        })

        canvas.drawText("${state.repCount ?: 0}", repCenter, repCenterY + (nodeH * 0.2f), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = white
            textAlign = Paint.Align.CENTER
            textSize = min(nodeH * 0.60f, 48f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            setShadowLayer(5f * scale, 0f, 0f, cyan)
        })
        
        canvas.drawText("NODE", repCenter, nodeRect.top + (14f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = silver
            textAlign = Paint.Align.CENTER
            textSize = min(nodeH * 0.15f, 14f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        })
    }

    private fun resolveOverlayUiScale(width: Float, height: Float): Float {
        val normalizedScale = min(width / 720f, height / 1280f)
        val highResolutionGrowth = if (normalizedScale <= 1f) {
            normalizedScale
        } else {
            1f + ((normalizedScale - 1f) * 0.18f)
        }
        val wideFrameAdjustment = if ((width / height) > 0.62f) 0.95f else 1f
        val tallFrameLift = if ((height / width) > 1.9f) 1.02f else 1f
        return (highResolutionGrowth * wideFrameAdjustment * tallFrameLift)
            .coerceIn(0.78f, 1.08f)
    }

    private fun drawCustomOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
    ) {
        val config = visualConfig.customOverlay
        val palette = config.palette
        val overlayScale = scale * config.layout.globalScale
        val sideInset = 16f * overlayScale
        val counterSize = 98f * overlayScale * config.repCounter.scale
        val gap = 12f * overlayScale
        val bannerHeight = 54f * overlayScale
        val barHeight = 24f * overlayScale
        val statsHeight = 70f * overlayScale
        val bannerPosition = config.layout.bannerPosition
        val visualDrop = 24f * overlayScale

        // Banner always at top
        val bannerTop = 24f * overlayScale + visualDrop
        val showStatsCard = config.layout.statsCardPosition != "none"

        val statsTop =
            if (showStatsCard) {
                slotPositionY(
                    config.layout.statsCardPosition,
                    top = height * 0.16f,
                    center = height * 0.60f,
                    bottom = height - statsHeight - (26f * overlayScale),
                )
            } else {
                height * 0.72f
            }

        val barRect: RectF
        val counterRect: RectF

        if (bannerPosition == "left" || bannerPosition == "right") {
            // Vertical layout: accuracy bar on top, rep counter below, on the specified side
            val columnWidth = max(120f * overlayScale, counterSize)
            val columnTop = bannerTop + bannerHeight + (14f * overlayScale)

            if (bannerPosition == "left") {
                // Left side placement
                barRect = RectF(
                    sideInset,
                    columnTop,
                    sideInset + columnWidth,
                    columnTop + barHeight,
                )
                val counterTop = columnTop + barHeight + (12f * overlayScale)
                counterRect = RectF(
                    sideInset,
                    counterTop,
                    sideInset + counterSize,
                    counterTop + counterSize,
                )
            } else {
                // Right side placement
                barRect = RectF(
                    width - sideInset - columnWidth,
                    columnTop,
                    width - sideInset,
                    columnTop + barHeight,
                )
                val counterTop = columnTop + barHeight + (12f * overlayScale)
                counterRect = RectF(
                    width - sideInset - counterSize,
                    counterTop,
                    width - sideInset,
                    counterTop + counterSize,
                )
            }
        } else {
            // Top (default): original horizontal layout
            val barWidth = max(120f * overlayScale, width - (sideInset * 2f) - counterSize - gap)
            var barTop = bannerTop + bannerHeight + (14f * overlayScale)
            val maxBarTop = min(
                statsTop - (barHeight + (22f * overlayScale)),
                height - (barHeight + statsHeight + (54f * overlayScale)),
            )
            barTop = barTop.coerceAtMost(max(28f * overlayScale, maxBarTop))
            val counterTop = max(
                bannerTop + (8f * overlayScale),
                barTop - (counterSize * 0.34f),
            )
            barRect = RectF(
                sideInset,
                barTop,
                sideInset + barWidth,
                barTop + barHeight,
            )
            counterRect = RectF(
                width - sideInset - counterSize,
                counterTop,
                width - sideInset,
                counterTop + counterSize,
            )
        }

        val statsRect = RectF(
            sideInset,
            statsTop,
            width - sideInset,
            statsTop + statsHeight,
        )
        val activeCue = activeNarrativeCues(presentationTimeUs).firstOrNull()

        drawCustomAmbientTreatment(
            canvas = canvas,
            width = width,
            height = height,
            config = config,
            presentationTimeUs = presentationTimeUs,
        )

        if (config.showBranding && activeCue == null) {
            drawCustomBanner(
                canvas = canvas,
                rect = RectF(
                    sideInset,
                    bannerTop,
                    width - sideInset,
                    bannerTop + bannerHeight,
                ),
                config = config,
                iconSlot = iconSlotForState(state.phase, config.icons),
                scale = overlayScale,
            )
        }

        if (config.accuracyBar.show) {
            drawCustomAccuracyBar(
                canvas = canvas,
                rect = barRect,
                accuracy = state.accuracy,
                config = config,
                scale = overlayScale,
                presentationTimeUs = presentationTimeUs,
                screenHeight = height,
            )
        }

        if (config.repCounter.show) {
            drawCustomRepCounter(
                canvas = canvas,
                rect = counterRect,
                repCount = state.repCount,
                phase = state.phase,
                config = config,
                scale = overlayScale,
                presentationTimeUs = presentationTimeUs,
            )
        }

        if (showStatsCard) {
            drawCustomStatsCard(
                canvas = canvas,
                rect = statsRect,
                state = state,
                config = config,
                scale = overlayScale,
            )
        }

        drawCustomNarrativeTransition(
            canvas = canvas,
            width = width,
            height = height,
            barRect = barRect,
            statsRect = statsRect,
            config = config,
            scale = overlayScale,
            presentationTimeUs = presentationTimeUs,
        )
    }

    private fun drawCustomAmbientTreatment(
        canvas: Canvas,
        width: Float,
        height: Float,
        config: CustomOverlayConfig,
        presentationTimeUs: Long,
    ) {
        val palette = config.palette
        val motionFactor = if (config.performanceMode == "low") 0f else 1f
        val shimmer = ((sin(presentationTimeUs / 420000.0) + 1.0) / 2.0).toFloat()
        val vignette = config.finish.vignetteStrength.coerceIn(0f, 1f)
        val bloom = config.finish.bloomIntensity.coerceIn(0f, 1f)
        val sparkleDensity = config.finish.sparkleDensity.coerceIn(0f, 1f)

        val topTint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f,
                0f,
                0f,
                height * 0.66f,
                intArrayOf(
                    adjustAlpha(palette.primary, (0.36f + (0.12f * bloom)) * config.layout.opacity),
                    adjustAlpha(palette.secondary, (0.18f + (0.06f * bloom)) * config.layout.opacity),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.44f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, width, height, topTint)

        val accentGlow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                width * 0.84f,
                height * 0.16f,
                width * 0.32f,
                intArrayOf(
                    adjustAlpha(palette.accent, 0.16f + (0.10f * shimmer * motionFactor) + (0.12f * bloom)),
                    adjustAlpha(palette.secondary, 0.08f + (0.04f * bloom)),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.46f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, width, height, accentGlow)

        if (vignette > 0f) {
            val vignettePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    width / 2f,
                    height / 2f,
                    max(width, height) * 0.64f,
                    intArrayOf(
                        Color.TRANSPARENT,
                        Color.TRANSPARENT,
                        adjustAlpha(Color.BLACK, 0.16f + (0.22f * vignette)),
                    ),
                    floatArrayOf(0f, 0.62f, 1f),
                    Shader.TileMode.CLAMP,
                )
            }
            canvas.drawRect(0f, 0f, width, height, vignettePaint)
        }

        val guidePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(18, 255, 255, 255)
            strokeWidth = 1f
        }
        repeat(4) { index ->
            val y = height * (0.18f + (index * 0.17f))
            canvas.drawLine(width * 0.08f, y, width * 0.92f, y, guidePaint)
        }

        if (motionFactor > 0f) {
            val sparklePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(palette.accent, 0.14f + (0.18f * sparkleDensity))
            }
            val sparkles = mutableListOf(
                Triple(width * 0.86f, height * 0.18f, 3.0f),
                Triple(width * 0.20f, height * 0.74f, 2.2f),
                Triple(width * 0.72f, height * 0.62f, 1.8f),
            )
            if (sparkleDensity > 0.30f) sparkles += Triple(width * 0.58f, height * 0.24f, 1.9f)
            if (sparkleDensity > 0.55f) sparkles += Triple(width * 0.30f, height * 0.36f, 1.6f)
            if (sparkleDensity > 0.80f) sparkles += Triple(width * 0.82f, height * 0.48f, 1.4f)
            sparkles.forEach { (x, y, r) ->
                canvas.drawCircle(x, y, r, sparklePaint)
            }
        }
    }

    private fun drawCustomBanner(
        canvas: Canvas,
        rect: RectF,
        config: CustomOverlayConfig,
        iconSlot: CustomOverlayIconSlot,
        scale: Float,
    ) {
        val palette = config.palette
        val radius = rect.height() / 2f
        val sheen = config.finish.sheenSweep.coerceIn(0f, 1f)
        val bloom = config.finish.bloomIntensity.coerceIn(0f, 1f)
        val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.right,
                rect.bottom,
                intArrayOf(
                    adjustAlpha(palette.surface, config.layout.opacity),
                    adjustAlpha(blendColors(palette.primary, palette.secondary, 0.55f), config.layout.opacity),
                ),
                null,
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRoundRect(rect, radius, radius, backgroundPaint)
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(Color.WHITE, 0.03f + (0.10f * sheen)),
                        adjustAlpha(Color.WHITE, 0.09f + (0.16f * sheen)),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.32f, 0.84f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(palette.textPrimary, 0.12f)
                style = Paint.Style.STROKE
                strokeWidth = 1.1f * scale
                setShadowLayer(6f * scale, 0f, 0f, adjustAlpha(palette.accent, 0.05f + (0.10f * bloom)))
            },
        )

        val medallionSize = rect.height() - (10f * scale)
        val medallionRect = RectF(
            rect.left + (6f * scale),
            rect.top + (5f * scale),
            rect.left + (6f * scale) + medallionSize,
            rect.top + (5f * scale) + medallionSize,
        )
        canvas.drawOval(
            medallionRect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    medallionRect.left,
                    medallionRect.top,
                    medallionRect.right,
                    medallionRect.bottom,
                    intArrayOf(palette.accent, blendColors(palette.accent, palette.secondary, 0.42f)),
                    null,
                    Shader.TileMode.CLAMP,
                )
            },
        )
        val medallionIconRect = RectF(
            medallionRect.left + (medallionRect.width() * 0.20f),
            medallionRect.top + (medallionRect.height() * 0.20f),
            medallionRect.right - (medallionRect.width() * 0.20f),
            medallionRect.bottom - (medallionRect.height() * 0.20f),
        )
        val renderedSvg = drawSvgIcon(
            canvas = canvas,
            svgPath = iconSlot.svgPath,
            rect = medallionIconRect,
            clipAsOval = true,
        )
        if (!renderedSvg) {
            drawCenteredText(
                canvas,
                iconSlot.glyph,
                medallionRect.centerX(),
                medallionRect.centerY(),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = palette.primary
                    textAlign = Paint.Align.CENTER
                    textSize = max(16f, rect.height() * 0.34f)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                },
            )
        }

        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = palette.textPrimary
            textAlign = Paint.Align.LEFT
            textSize = max(15f, rect.height() * 0.28f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val subtitlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(palette.textSecondary, 0.94f)
            textAlign = Paint.Align.LEFT
            textSize = max(11f, rect.height() * 0.18f)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
        }
        val brandingPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(palette.accent, 0.96f)
            textAlign = Paint.Align.RIGHT
            textSize = max(10f, rect.height() * 0.16f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val titleX = medallionRect.right + (12f * scale)
        val titleBaseline = rect.top + (rect.height() * 0.44f)
        canvas.drawText(config.title, titleX, titleBaseline, titlePaint)
        canvas.drawText(config.subtitle, titleX, titleBaseline + (14f * scale), subtitlePaint)
        canvas.drawText(
            config.brandingText.uppercase(Locale.US),
            rect.right - (16f * scale),
            rect.centerY() + (4f * scale),
            brandingPaint,
        )
    }

    private fun drawCustomAccuracyBar(
        canvas: Canvas,
        rect: RectF,
        accuracy: Float,
        config: CustomOverlayConfig,
        scale: Float,
        presentationTimeUs: Long,
        screenHeight: Float,
    ) {
        val palette = config.palette
        val radius = rect.height() / 2f
        val glowIntensity = config.accuracyBar.glowIntensity.coerceIn(0f, 1f)
        val styleIntensity = config.accuracyBar.styleIntensity.coerceIn(0f, 1f)
        val spillLength = config.accuracyBar.spillLength.coerceIn(0f, 1f)
        val spillWidth = config.accuracyBar.spillWidth.coerceIn(0f, 1f)
        val thresholdGlow = config.accuracyBar.thresholdGlow.coerceIn(0f, 1f)
        val liquidMotion = config.accuracyBar.liquidMotion.coerceIn(0f, 1f)
        val vividPrimary = intensifyColor(palette.primary, 0.12f)
        val vividSecondary = intensifyColor(palette.secondary, 0.16f)
        val vividAccent = intensifyColor(palette.accent, 0.18f)
        val vividText = intensifyColor(palette.textPrimary, 0.10f)
        val fillColor = phaseColorForCustom(
            phase = if (accuracy >= 0.8f) "up" else if (accuracy >= 0.6f) "down" else "hold",
            palette = palette,
        )
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(fillColor, 0.06f + (0.12f * glowIntensity) + (0.06f * styleIntensity))
                maskFilter = BlurMaskFilter(
                    (8f + (12f * glowIntensity) + (6f * styleIntensity)) * scale,
                    BlurMaskFilter.Blur.NORMAL,
                )
            },
        )
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = when (config.accuracyBar.style) {
                "glass" -> LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(vividText, palette.surface, 0.76f - (0.14f * styleIntensity)), 0.94f * config.layout.opacity),
                        adjustAlpha(blendColors(palette.surface, vividSecondary, 0.20f + (0.12f * styleIntensity)), 0.86f * config.layout.opacity),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
                "velvet" -> LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(palette.primary, palette.surface, 0.28f), 0.98f * config.layout.opacity),
                        adjustAlpha(blendColors(vividSecondary, palette.primary, 0.42f + (0.18f * styleIntensity)), 0.95f * config.layout.opacity),
                        adjustAlpha(blendColors(palette.surface, vividAccent, 0.12f + (0.10f * styleIntensity)), 0.92f * config.layout.opacity),
                    ),
                    floatArrayOf(0f, 0.58f, 1f),
                    Shader.TileMode.CLAMP,
                )
                "prism" -> LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(vividSecondary, 0.86f * config.layout.opacity),
                        adjustAlpha(vividAccent, 0.92f * config.layout.opacity),
                        adjustAlpha(phaseColorForCustom("down", palette), 0.88f * config.layout.opacity),
                        adjustAlpha(vividText, 0.84f * config.layout.opacity),
                    ),
                    floatArrayOf(0f, 0.34f, 0.68f, 1f),
                    Shader.TileMode.CLAMP,
                )
                else -> LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(palette.surface, vividPrimary, 0.16f), 0.96f * config.layout.opacity),
                        adjustAlpha(blendColors(vividPrimary, vividSecondary, 0.52f), 0.97f * config.layout.opacity),
                    ),
                    null,
                    Shader.TileMode.CLAMP,
                )
            }
        }
        canvas.drawRoundRect(rect, radius, radius, trackPaint)
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividText, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.0f * scale)
            },
        )

        if (config.accuracyBar.style == "glass" || config.accuracyBar.style == "velvet") {
            canvas.drawRoundRect(
                RectF(rect.left + (3f * scale), rect.top + (3f * scale), rect.right - (3f * scale), rect.top + (rect.height() * 0.48f)),
                radius,
                radius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        rect.left,
                        rect.top,
                        rect.left,
                        rect.top + (rect.height() * 0.52f),
                        intArrayOf(
                            adjustAlpha(Color.WHITE, if (config.accuracyBar.style == "glass") 0.12f + (0.10f * styleIntensity) else 0.05f + (0.05f * styleIntensity)),
                            Color.TRANSPARENT,
                        ),
                        floatArrayOf(0f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
        }

        val density = 4 + (config.accuracyBar.markerDensity * 8f).toInt()
        if (config.accuracyBar.style == "segmented" || config.accuracyBar.style == "prism") {
            val segmentPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = if (config.accuracyBar.style == "prism") {
                    adjustAlpha(Color.WHITE, 0.08f + (0.10f * styleIntensity))
                } else {
                    Color.argb(18, 255, 255, 255)
                }
            }
            repeat(density) { index ->
                val segmentGap = 3f * scale
                val segmentWidth = (rect.width() - (segmentGap * (density - 1))) / density
                val left = rect.left + (index * (segmentWidth + segmentGap))
                val right = left + segmentWidth
                canvas.drawRoundRect(
                    RectF(left, rect.top + (3f * scale), right, rect.bottom - (3f * scale)),
                    radius,
                    radius,
                    segmentPaint,
                )
            }
        }

        val fillWidth = rect.width() * accuracy.coerceIn(0f, 1f)
        if (fillWidth > 6f * scale) {
            val fillRect = RectF(rect.left, rect.top, rect.left + fillWidth, rect.bottom)
            val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = when (config.accuracyBar.style) {
                    "flat" -> LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right,
                        fillRect.top,
                        intArrayOf(fillColor, fillColor),
                        null,
                        Shader.TileMode.CLAMP,
                    )
                    "glass" -> LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right,
                        fillRect.bottom,
                        intArrayOf(
                            adjustAlpha(blendColors(fillColor, Color.WHITE, 0.24f + (0.18f * styleIntensity)), 0.96f),
                            adjustAlpha(fillColor, 0.98f),
                            adjustAlpha(blendColors(fillColor, vividAccent, 0.30f), 0.92f),
                        ),
                        floatArrayOf(0f, 0.52f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                    "neon" -> LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right,
                        fillRect.bottom,
                        intArrayOf(
                            intensifyColor(fillColor, 0.18f),
                            intensifyColor(vividAccent, 0.24f + (0.20f * styleIntensity)),
                            adjustAlpha(Color.WHITE, 0.94f),
                        ),
                        floatArrayOf(0f, 0.68f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                    "prism" -> LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right,
                        fillRect.bottom,
                        intArrayOf(
                            phaseColorForCustom("down", palette),
                            fillColor,
                            vividAccent,
                            vividText,
                        ),
                        floatArrayOf(0f, 0.34f, 0.72f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                    "velvet" -> LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right,
                        fillRect.bottom,
                        intArrayOf(
                            blendColors(fillColor, palette.primary, 0.36f),
                            fillColor,
                            blendColors(fillColor, palette.secondary, 0.24f + (0.14f * styleIntensity)),
                        ),
                        floatArrayOf(0f, 0.58f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                    else -> LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right,
                        fillRect.bottom,
                        intArrayOf(
                            blendColors(fillColor, palette.secondary, 0.18f),
                            fillColor,
                            vividAccent,
                        ),
                        floatArrayOf(0f, 0.56f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                }
            }
            canvas.drawRoundRect(fillRect, radius, radius, fillPaint)

            if (config.accuracyBar.style == "neon") {
                canvas.drawRoundRect(
                    fillRect,
                    radius,
                    radius,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(vividAccent, 0.18f + (0.24f * styleIntensity))
                        maskFilter = BlurMaskFilter((10f + (10f * styleIntensity)) * scale, BlurMaskFilter.Blur.NORMAL)
                    },
                )
            }

            if (config.performanceMode != "low" && config.accuracyBar.style != "flat") {
                val shimmerDuration = max(1200f, 2200f - (900f * liquidMotion))
                val shimmer = ((presentationTimeUs / 1000L) % shimmerDuration.toLong()).toFloat() / shimmerDuration
                val shimmerX = fillRect.left + (fillRect.width() * shimmer)
                val shimmerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        shimmerX - (18f * scale),
                        fillRect.top,
                        shimmerX + (18f * scale),
                        fillRect.bottom,
                        intArrayOf(Color.TRANSPARENT, adjustAlpha(Color.WHITE, 0.44f), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                }
                canvas.save()
                canvas.clipRect(fillRect)
                canvas.drawRect(
                    shimmerX - (22f * scale),
                    fillRect.top,
                    shimmerX + (22f * scale),
                    fillRect.bottom,
                    shimmerPaint,
                )
                canvas.restore()

                val streamPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(
                        if (config.accuracyBar.style == "velvet") vividAccent else palette.textPrimary,
                        0.05f + (0.10f * liquidMotion) + (0.04f * styleIntensity),
                    )
                    style = Paint.Style.STROKE
                    strokeWidth = max(1f, 1.0f * scale)
                }
                repeat(2) { index ->
                    val streamY = fillRect.top + (fillRect.height() * (0.32f + (index * 0.24f)))
                    val streamPath = Path().apply {
                        moveTo(fillRect.left, streamY)
                        cubicTo(
                            fillRect.left + (fillRect.width() * 0.24f),
                            streamY - (fillRect.height() * (0.14f + (0.10f * liquidMotion))),
                            fillRect.left + (fillRect.width() * 0.68f),
                            streamY + (fillRect.height() * (0.12f + (0.08f * liquidMotion))),
                            fillRect.right,
                            streamY - (fillRect.height() * 0.04f),
                        )
                    }
                    canvas.save()
                    canvas.clipRect(fillRect)
                    canvas.drawPath(streamPath, streamPaint)
                    canvas.restore()
                }

                if (config.accuracyBar.style == "prism") {
                    repeat(3) { index ->
                        val stripeX = fillRect.left + (fillRect.width() * (0.18f + (index * 0.24f)))
                        canvas.drawRect(
                            stripeX,
                            fillRect.top,
                            stripeX + (4f + (4f * styleIntensity)) * scale,
                            fillRect.bottom,
                            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                                shader = LinearGradient(
                                    stripeX,
                                    fillRect.top,
                                    stripeX,
                                    fillRect.bottom,
                                    intArrayOf(
                                        adjustAlpha(Color.WHITE, 0.16f + (0.10f * styleIntensity)),
                                        Color.TRANSPARENT,
                                    ),
                                    floatArrayOf(0f, 1f),
                                    Shader.TileMode.CLAMP,
                                )
                            },
                        )
                    }
                }
            }
        }

        if (config.accuracyBar.showThresholdLine) {
            val markerX = rect.left + (rect.width() * 0.8f)
            canvas.drawRoundRect(
                RectF(
                    markerX - ((1.6f + (1.1f * thresholdGlow)) * scale),
                    rect.top + (4f * scale),
                    markerX + ((1.6f + (1.1f * thresholdGlow)) * scale),
                    rect.bottom - (4f * scale),
                ),
                99f,
                99f,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(palette.textPrimary, 0.72f + (0.24f * thresholdGlow))
                },
            )
            canvas.drawRoundRect(
                RectF(
                    markerX - ((4.0f + (4.5f * thresholdGlow)) * scale),
                    rect.top + (2f * scale),
                    markerX + ((4.0f + (4.5f * thresholdGlow)) * scale),
                    rect.bottom - (2f * scale),
                ),
                99f,
                99f,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(palette.textPrimary, 0.08f + (0.22f * thresholdGlow))
                    maskFilter = BlurMaskFilter((8f + (12f * thresholdGlow)) * scale, BlurMaskFilter.Blur.NORMAL)
                },
            )
        }

        if (accuracy >= 0.8f) {
            val markerX = rect.left + (rect.width() * 0.8f)
            val targetDropY = max(
                screenHeight * 0.5f,
                rect.bottom + (rect.height() * (2.0f + (1.6f * spillLength))),
            )
            drawThresholdDropletEffect(
                canvas = canvas,
                originX = markerX,
                originY = rect.bottom - (1.5f * scale),
                targetY = targetDropY,
                accuracy = accuracy,
                scale = scale,
                presentationTimeUs = presentationTimeUs,
                glowColor = vividText,
                fillMidColor = fillColor,
                fillEndColor = palette.secondary,
                swayAmplitude = (4.2f + (2.2f * spillWidth) + (1.6f * liquidMotion)) * scale,
            )
        }

        drawCenteredText(
            canvas = canvas,
            text = "${String.format(Locale.US, "%.1f", accuracy * 100f)}% ACCURACY",
            centerX = rect.centerX(),
            centerY = rect.centerY(),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = vividText
                textAlign = Paint.Align.CENTER
                textSize = max(11f, rect.height() * 0.44f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3.2f * scale, 0f, 1.6f * scale, adjustAlpha(Color.BLACK, 0.34f))
            },
        )
    }

    private fun drawCustomRepCounter(
        canvas: Canvas,
        rect: RectF,
        repCount: Int,
        phase: String,
        config: CustomOverlayConfig,
        scale: Float,
        presentationTimeUs: Long,
    ) {
        val palette = config.palette
        val phaseColor = phaseColorForCustom(phase, palette)
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = rect.width() / 2f
        val ringWidth = config.repCounter.ringThickness
        val contourSoftness = config.repCounter.contourSoftness.coerceIn(0f, 1f)
        val surfaceDepth = config.repCounter.surfaceDepth.coerceIn(0f, 1f)
        val orbitIntensity = config.repCounter.orbitIntensity.coerceIn(0f, 1f)
        val ringRect = RectF(
            rect.left + (ringWidth / 2f),
            rect.top + (ringWidth / 2f),
            rect.right - (ringWidth / 2f),
            rect.bottom - (ringWidth / 2f),
        )
        val shellRect = RectF(
            rect.left + ringWidth + (4f * scale),
            rect.top + ringWidth + (4f * scale),
            rect.right - ringWidth - (4f * scale),
            rect.bottom - ringWidth - (4f * scale),
        )
        val outerShapePath = buildCustomCounterShapePath(ringRect, config.repCounter.shape, contourSoftness)
        val innerShapePath = buildCustomCounterShapePath(shellRect, config.repCounter.shape, contourSoftness)

        val shellPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                centerX,
                centerY,
                radius,
                intArrayOf(
                    adjustAlpha(blendColors(palette.textPrimary, palette.surface, 0.82f - (surfaceDepth * 0.18f)), config.repCounter.opacity * config.layout.opacity),
                    adjustAlpha(palette.surface, config.repCounter.opacity * config.layout.opacity),
                    adjustAlpha(blendColors(palette.primary, palette.surface, 0.32f + (surfaceDepth * 0.18f)), config.repCounter.opacity * config.layout.opacity),
                ),
                floatArrayOf(0f, 0.56f + (surfaceDepth * 0.10f), 1f),
                Shader.TileMode.CLAMP,
            )
        }
        val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(
                phaseColor,
                0.10f + (0.18f * config.repCounter.glowIntensity) + (0.08f * contourSoftness),
            )
            style = Paint.Style.STROKE
            strokeWidth = ringWidth + (config.repCounter.glowIntensity * 10f)
            maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
        }
        val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = ringWidth
            strokeCap = Paint.Cap.ROUND
            shader = SweepGradient(
                centerX,
                centerY,
                intArrayOf(palette.secondary, palette.accent, phaseColor, palette.secondary),
                null,
            )
        }

        if (config.repCounter.shape == "arc") {
            canvas.drawCircle(centerX, centerY, radius, glowPaint)
            canvas.drawCircle(centerX, centerY, radius - ringWidth - (4f * scale), shellPaint)
        } else {
            canvas.drawPath(outerShapePath, glowPaint)
            canvas.drawPath(innerShapePath, shellPaint)
        }
        if (config.repCounter.shape == "arc") {
            canvas.drawArc(
                ringRect,
                212f,
                296f,
                false,
                ringPaint,
            )
        } else {
            canvas.drawPath(outerShapePath, ringPaint)
        }

        if (config.performanceMode != "low" && config.repCounter.animationStyle != "minimal") {
            val pulse = ((sin(presentationTimeUs / 360000.0) + 1.0) / 2.0).toFloat()
            val pulsePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(phaseColor, if (config.repCounter.animationStyle == "ripple") 0.10f else 0.06f)
                style = Paint.Style.STROKE
                strokeWidth = if (config.repCounter.animationStyle == "ripple") 1.5f * scale else 1f * scale
            }
            if (config.repCounter.shape == "arc" || config.repCounter.shape == "circle") {
                canvas.drawCircle(
                    centerX,
                    centerY,
                    radius + (4f * scale * pulse),
                    pulsePaint,
                )
            } else {
                val pulseRect = RectF(
                    rect.left - (4f * scale * pulse),
                    rect.top - (4f * scale * pulse),
                    rect.right + (4f * scale * pulse),
                    rect.bottom + (4f * scale * pulse),
                )
                canvas.drawPath(
                    buildCustomCounterShapePath(pulseRect, config.repCounter.shape, contourSoftness),
                    pulsePaint,
                )
            }
            val orbitRadius = radius - ringWidth - ((7f + (8f * orbitIntensity)) * scale)
            val orbitStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(phaseColor, 0.06f + (0.10f * orbitIntensity))
                style = Paint.Style.STROKE
                strokeWidth = max(1f, (0.8f + orbitIntensity) * scale)
            }
            if (config.repCounter.shape == "arc" || config.repCounter.shape == "circle") {
                canvas.drawCircle(centerX, centerY, orbitRadius, orbitStroke)
            } else {
                val orbitRect = RectF(
                    centerX - orbitRadius,
                    centerY - orbitRadius,
                    centerX + orbitRadius,
                    centerY + orbitRadius,
                )
                canvas.drawPath(
                    buildCustomCounterShapePath(orbitRect, config.repCounter.shape, contourSoftness),
                    orbitStroke,
                )
            }
            repeat(3) { index ->
                val angle = ((presentationTimeUs / 220000.0) + index * 2.0).toFloat()
                val x = centerX + (kotlin.math.cos(angle.toDouble()).toFloat() * orbitRadius * 0.92f)
                val y = centerY + (sin(angle.toDouble()).toFloat() * orbitRadius * 0.92f)
                canvas.drawCircle(
                    x,
                    y,
                    (1.3f + (orbitIntensity * 2.0f) + (index * 0.35f)) * scale,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(palette.accent, 0.10f + (0.16f * orbitIntensity))
                    },
                )
            }
        }
        val shellOutlinePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(palette.textPrimary, 0.06f + (0.12f * surfaceDepth))
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.9f * scale)
        }
        if (config.repCounter.shape == "arc") {
            canvas.drawCircle(
                centerX,
                centerY,
                radius - ringWidth - (4f * scale),
                shellOutlinePaint,
            )
        } else {
            canvas.drawPath(innerShapePath, shellOutlinePaint)
        }

        val repIconSlot = iconSlotForState(phase, config.icons)
        val repIconRect = RectF(
            centerX - (rect.width() * 0.12f),
            centerY - (rect.width() * 0.33f),
            centerX + (rect.width() * 0.12f),
            centerY - (rect.width() * 0.09f),
        )
        val repIconBackdrop = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(blendColors(palette.primary, palette.surface, 0.36f), 0.56f)
        }
        canvas.drawRoundRect(
            repIconRect,
            12f * scale,
            12f * scale,
            repIconBackdrop,
        )
        canvas.drawRoundRect(
            repIconRect,
            12f * scale,
            12f * scale,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(palette.textPrimary, 0.10f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.8f * scale)
            },
        )
        val renderedRepSvg = drawSvgIcon(
            canvas = canvas,
            svgPath = repIconSlot.svgPath,
            rect = RectF(
                repIconRect.left + (6f * scale),
                repIconRect.top + (6f * scale),
                repIconRect.right - (6f * scale),
                repIconRect.bottom - (6f * scale),
            ),
        )
        if (!renderedRepSvg) {
            drawCenteredText(
                canvas = canvas,
                text = repIconSlot.glyph,
                centerX = centerX,
                centerY = centerY - (rect.width() * 0.20f),
                paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(palette.accent, 0.94f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(15f, rect.width() * 0.18f)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                },
            )
        }
        drawCenteredText(
            canvas = canvas,
            text = repCount.toString(),
            centerX = centerX,
            centerY = centerY - (rect.width() * 0.01f),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = palette.textPrimary
                textAlign = Paint.Align.CENTER
                textSize = max(28f, rect.width() * 0.33f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
        drawCenteredText(
            canvas = canvas,
            text = phase.uppercase(Locale.US),
            centerX = centerX,
            centerY = centerY + (rect.width() * 0.20f),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = phaseColor
                textAlign = Paint.Align.CENTER
                textSize = max(11f, rect.width() * 0.10f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
    }

    private fun drawCustomStatsCard(
        canvas: Canvas,
        rect: RectF,
        state: OverlayState,
        config: CustomOverlayConfig,
        scale: Float,
    ) {
        val palette = config.palette
        val radius = 24f * scale
        val sheen = config.finish.sheenSweep.coerceIn(0f, 1f)
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(palette.primary, palette.surface, 0.38f), 0.86f),
                        adjustAlpha(palette.surface, 0.94f),
                    ),
                    null,
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(palette.textPrimary, 0.10f)
                style = Paint.Style.STROKE
                strokeWidth = 1f * scale
            },
        )
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(Color.WHITE, 0.02f + (0.06f * sheen)),
                        Color.TRANSPARENT,
                        adjustAlpha(palette.accent, 0.03f + (0.08f * sheen)),
                    ),
                    floatArrayOf(0f, 0.56f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(palette.textSecondary, 0.86f)
            textAlign = Paint.Align.LEFT
            textSize = max(10f, rect.height() * 0.16f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val valuePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = palette.textPrimary
            textAlign = Paint.Align.LEFT
            textSize = max(13f, rect.height() * 0.22f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val highlightPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = palette.accent
            textAlign = Paint.Align.RIGHT
            textSize = max(22f, rect.height() * 0.34f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        }
        val startX = rect.left + (16f * scale)
        val baseY = rect.top + (26f * scale)

        canvas.drawText("REPS", startX, baseY, labelPaint)
        canvas.drawText(state.repCount.toString(), startX, baseY + (18f * scale), valuePaint)

        canvas.drawText("PHASE", startX + (72f * scale), baseY, labelPaint)
        canvas.drawText(state.phase.uppercase(Locale.US), startX + (72f * scale), baseY + (18f * scale), valuePaint.apply {
            color = phaseColorForCustom(state.phase, palette)
        })
        valuePaint.color = palette.textPrimary

        canvas.drawText("MODE", startX + (160f * scale), baseY, labelPaint)
        canvas.drawText(config.performanceMode.uppercase(Locale.US), startX + (160f * scale), baseY + (18f * scale), valuePaint)

        canvas.drawText(
            "${String.format(Locale.US, "%.0f", state.accuracy * 100f)}%",
            rect.right - (16f * scale),
            rect.centerY() + (8f * scale),
            highlightPaint,
        )
    }

    private fun drawCustomNarrativeTransition(
        canvas: Canvas,
        width: Float,
        height: Float,
        barRect: RectF,
        statsRect: RectF,
        config: CustomOverlayConfig,
        scale: Float,
        presentationTimeUs: Long,
    ) {
        val activeCues = activeNarrativeCues(presentationTimeUs)
        if (activeCues.isEmpty()) {
            return
        }
        val activeCue = activeCues.last()
        val elapsedMs = max(0L, (presentationTimeUs / 1000L) - activeCue.triggerOffsetMs)
        val flowLeadInProgress =
            (elapsedMs / NARRATIVE_CUE_FLOW_LEAD_IN_MS.toFloat()).coerceIn(0f, 1f)
        val fadeStartMs =
            (NARRATIVE_CUE_FLOW_LEAD_IN_MS + NARRATIVE_CUE_VISIBLE_HOLD_MS).toFloat()
        val fadeProgress = if (elapsedMs <= fadeStartMs) {
            0f
        } else {
            ((elapsedMs - fadeStartMs) / NARRATIVE_CUE_FADE_OUT_MS.toFloat()).coerceIn(0f, 1f)
        }
        val flowProgress = smoothStep(0f, 1f, flowLeadInProgress)
        val textProgress = smoothStep(0.10f, 1f, flowLeadInProgress)
        val fadeOut = 1f - smoothStep(0f, 1f, fadeProgress)
        val overallAlpha = (0.96f * fadeOut).coerceIn(0f, 1f)
        if (overallAlpha <= 0.01f) {
            return
        }

        val palette = config.palette
        val highlightColor = phaseColorForCustom("up", palette)
        val thresholdX = barRect.left + (barRect.width() * 0.8f)
        val startY = barRect.bottom - (1.5f * scale)
        val halfScreenY = min(height * 0.56f, statsRect.top - (18f * scale))
        val currentFrontY = lerp(startY, halfScreenY, flowProgress)
        val streamWidth = (18f + (24f * config.accuracyBar.spillWidth)) * scale
        val flowSwing = sin((presentationTimeUs / 420000.0) + activeCue.repTarget).toFloat() * (9f * scale)
        val ribbonPath = buildLuxuryNarrativeFlowPath(
            originX = thresholdX,
            originY = startY,
            destinationX = thresholdX + flowSwing,
            destinationY = currentFrontY,
            width = streamWidth,
            presentationTimeUs = presentationTimeUs,
        )
        drawNarrativeWaterRibbon(
            canvas = canvas,
            ribbonPath = ribbonPath,
            originX = thresholdX,
            originY = startY,
            destinationX = thresholdX + flowSwing,
            destinationY = currentFrontY,
            streamWidth = streamWidth,
            palette = palette,
            highlightColor = highlightColor,
            alpha = overallAlpha,
            progress = flowProgress,
            scale = scale,
            presentationTimeUs = presentationTimeUs,
        )

        val cardLeft = width * 0.14f
        val cardRight = width * 0.86f
        val cardHeight = 118f * scale
        val cardGap = 12f * scale
        val baseTop = halfScreenY - (26f * scale) - (10f * scale * (1f - textProgress))
        val maxCardBottom = height * 0.92f
        var stackedCardTop = baseTop

        activeCues.forEachIndexed { index, cue ->
            val cueElapsedMs = max(0L, (presentationTimeUs / 1000L) - cue.triggerOffsetMs)
            val cueLeadInProgress =
                (cueElapsedMs / NARRATIVE_CUE_FLOW_LEAD_IN_MS.toFloat()).coerceIn(0f, 1f)
            val cueFadeProgress = if (cueElapsedMs <= fadeStartMs) {
                0f
            } else {
                ((cueElapsedMs - fadeStartMs) / NARRATIVE_CUE_FADE_OUT_MS.toFloat())
                    .coerceIn(0f, 1f)
            }
            val cueTextProgress = smoothStep(0.10f, 1f, cueLeadInProgress)
            val cueFadeOut = 1f - smoothStep(0f, 1f, cueFadeProgress)
            val cueAlpha = (cueTextProgress * cueFadeOut).coerceIn(0f, 1f)
            if (cueAlpha <= 0.02f) {
                return@forEachIndexed
            }

            val top = stackedCardTop
            val bottom = min(maxCardBottom, top + cardHeight)
            val rect = RectF(cardLeft, top, cardRight, bottom)
            drawNarrativeTextCard(
                canvas = canvas,
                rect = rect,
                title = "LUXURY FLOW ${cue.repTarget}",
                message = cue.message,
                palette = palette,
                textColor = cue.textColor,
                textColorSecondary = cue.textColorSecondary,
                alpha = cueAlpha,
                scale = scale * (if (index == activeCues.lastIndex) 1f else 0.97f),
            )
            stackedCardTop = bottom + cardGap
            if (stackedCardTop >= maxCardBottom) {
                return@forEachIndexed
            }
        }

        if (flowProgress > 0.56f) {
            val mistAlpha = ((flowProgress - 0.56f) / 0.44f).coerceIn(0f, 1f) * fadeOut
            val activeCardCenterX = (cardLeft + cardRight) * 0.5f
            val activeCardTop = baseTop
            canvas.drawCircle(
                activeCardCenterX,
                activeCardTop + (18f * scale),
                (cardRight - cardLeft) * (0.26f + (0.08f * mistAlpha)),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = RadialGradient(
                        activeCardCenterX,
                        activeCardTop + (18f * scale),
                        (cardRight - cardLeft) * 0.28f,
                        intArrayOf(
                            adjustAlpha(palette.accent, 0.12f * mistAlpha),
                            adjustAlpha(palette.secondary, 0.08f * mistAlpha),
                            Color.TRANSPARENT,
                        ),
                        floatArrayOf(0f, 0.44f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
        }
    }

    private fun activeNarrativeCues(presentationTimeUs: Long): List<OverlayNarrativeCue> {
        if (narrativeCues.isEmpty()) {
            return emptyList()
        }
        val timeMs = max(0L, presentationTimeUs / 1000L)
        return narrativeCues.filter { cue ->
            timeMs in cue.triggerOffsetMs..(cue.triggerOffsetMs + NARRATIVE_CUE_DISPLAY_DURATION_MS)
        }
    }

    private fun buildLuxuryNarrativeFlowPath(
        originX: Float,
        originY: Float,
        destinationX: Float,
        destinationY: Float,
        width: Float,
        presentationTimeUs: Long,
    ): Path {
        val sway = sin((presentationTimeUs / 340000.0) + 0.4).toFloat() * (width * 0.28f)
        val travel = max(1f, destinationY - originY)
        val controlY1 = originY + (travel * 0.24f)
        val controlY2 = originY + (travel * 0.68f)
        return Path().apply {
            moveTo(originX - (width * 0.32f), originY)
            cubicTo(
                originX - width,
                controlY1,
                destinationX - (width * 0.58f) + sway,
                controlY2,
                destinationX - (width * 0.22f),
                destinationY,
            )
            cubicTo(
                destinationX + (width * 0.36f),
                controlY2 - (travel * 0.08f),
                originX + width + sway,
                controlY1 + (travel * 0.06f),
                originX + (width * 0.32f),
                originY,
            )
            close()
        }
    }

    private fun drawNarrativeWaterRibbon(
        canvas: Canvas,
        ribbonPath: Path,
        originX: Float,
        originY: Float,
        destinationX: Float,
        destinationY: Float,
        streamWidth: Float,
        palette: CustomOverlayPalette,
        highlightColor: Int,
        alpha: Float,
        progress: Float,
        scale: Float,
        presentationTimeUs: Long,
    ) {
        val safeAlpha = alpha.coerceIn(0f, 1f)
        val depthColor = blendColors(palette.primary, palette.secondary, 0.42f)
        val refractedColor = intensifyColor(blendColors(highlightColor, palette.textPrimary, 0.46f), 0.12f)
        val causticColor = intensifyColor(palette.textPrimary, 0.24f)
        val travel = max(1f, destinationY - originY)
        val frontRadius = (streamWidth * (0.72f + (0.12f * progress))).coerceAtLeast(14f * scale)

        canvas.drawPath(
            ribbonPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(depthColor, (0.18f + (0.18f * progress)) * safeAlpha)
                maskFilter = BlurMaskFilter((18f + (14f * progress)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )

        canvas.drawPath(
            ribbonPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    originX - (streamWidth * 0.8f),
                    originY,
                    destinationX + (streamWidth * 0.4f),
                    destinationY,
                    intArrayOf(
                        adjustAlpha(blendColors(depthColor, highlightColor, 0.12f), 0.86f * safeAlpha),
                        adjustAlpha(blendColors(highlightColor, palette.secondary, 0.28f), 0.92f * safeAlpha),
                        adjustAlpha(refractedColor, 0.68f * safeAlpha),
                        adjustAlpha(blendColors(depthColor, palette.primary, 0.12f), 0.42f * safeAlpha),
                    ),
                    floatArrayOf(0f, 0.22f, 0.60f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        canvas.save()
        canvas.clipPath(ribbonPath)
        val causticTravel = ((presentationTimeUs / 1000L) % 2200L).toFloat() / 2200f
        repeat(3) { index ->
            val bandShift = (index * 0.18f) + causticTravel
            val path = Path().apply {
                val startY = lerp(originY + (travel * (0.08f + (index * 0.10f))), destinationY - (travel * 0.12f), bandShift.coerceIn(0f, 1f))
                moveTo(originX - (streamWidth * 0.64f), startY)
                cubicTo(
                    originX - (streamWidth * 0.18f),
                    startY - (streamWidth * 0.22f),
                    destinationX - (streamWidth * 0.34f),
                    startY + (travel * 0.06f),
                    destinationX + (streamWidth * 0.16f),
                    startY + (travel * 0.14f),
                )
            }
            canvas.drawPath(
                path,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(causticColor, (0.14f - (index * 0.02f)) * safeAlpha)
                    style = Paint.Style.STROKE
                    strokeWidth = max(1f, (1.4f - (index * 0.22f)) * scale)
                },
            )
        }
        canvas.restore()

        canvas.drawPath(
            ribbonPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                strokeWidth = max(1.1f, 1.4f * scale)
                shader = LinearGradient(
                    originX - (streamWidth * 0.22f),
                    originY,
                    destinationX,
                    destinationY,
                    intArrayOf(
                        adjustAlpha(causticColor, 0.56f * safeAlpha),
                        adjustAlpha(refractedColor, 0.34f * safeAlpha),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.36f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        canvas.drawCircle(
            destinationX,
            destinationY + (frontRadius * 0.08f),
            frontRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(highlightColor, 0.18f * safeAlpha)
                maskFilter = BlurMaskFilter(16f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawCircle(
            destinationX,
            destinationY,
            frontRadius * 0.94f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    destinationX - (frontRadius * 0.24f),
                    destinationY - (frontRadius * 0.30f),
                    frontRadius,
                    intArrayOf(
                        adjustAlpha(causticColor, 0.94f * safeAlpha),
                        adjustAlpha(refractedColor, 0.70f * safeAlpha),
                        adjustAlpha(blendColors(highlightColor, depthColor, 0.48f), 0.38f * safeAlpha),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.22f, 0.64f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        repeat(4) { index ->
            val drift = ((presentationTimeUs / 1000L) % 1800L).toFloat() / 1800f
            val angle = (index * 0.88f) + (drift * 1.6f)
            val dropletX = destinationX + (kotlin.math.cos(angle.toDouble()).toFloat() * frontRadius * (0.54f + (index * 0.10f)))
            val dropletY = destinationY + (kotlin.math.sin(angle.toDouble()).toFloat() * frontRadius * (0.22f + (index * 0.12f))) + (index * 2.2f * scale)
            val dropletRadius = (2.0f + (index * 0.8f)) * scale
            canvas.drawCircle(
                dropletX,
                dropletY,
                dropletRadius * 1.8f,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(highlightColor, 0.10f * safeAlpha)
                    maskFilter = BlurMaskFilter(6f * scale, BlurMaskFilter.Blur.NORMAL)
                },
            )
            canvas.drawCircle(
                dropletX,
                dropletY,
                dropletRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = RadialGradient(
                        dropletX - (dropletRadius * 0.35f),
                        dropletY - (dropletRadius * 0.35f),
                        dropletRadius,
                        intArrayOf(
                            adjustAlpha(causticColor, 0.80f * safeAlpha),
                            adjustAlpha(refractedColor, 0.44f * safeAlpha),
                            Color.TRANSPARENT,
                        ),
                        floatArrayOf(0f, 0.42f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
        }
    }

    private fun drawNarrativeTextCard(
        canvas: Canvas,
        rect: RectF,
        title: String,
        message: String,
        palette: CustomOverlayPalette,
        textColor: Int,
        textColorSecondary: Int,
        alpha: Float,
        scale: Float,
    ) {
        val safeAlpha = alpha.coerceIn(0f, 1f)
        val radius = 26f * scale
        val vividTextColor = intensifyColor(textColor, 0.08f)
        val vividTextColorSecondary = intensifyColor(textColorSecondary, 0.10f)
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(palette.primary, palette.surface, 0.34f), 0.90f * safeAlpha),
                        adjustAlpha(blendColors(palette.surface, palette.secondary, 0.18f), 0.86f * safeAlpha),
                    ),
                    null,
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(palette.accent, 0.12f * safeAlpha)
                maskFilter = BlurMaskFilter(18f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(palette.textPrimary, 0.14f * safeAlpha)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.0f * scale)
            },
        )

        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.CENTER
            textSize = max(10f, 12f * scale)
            typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
            letterSpacing = 0.12f
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.right,
                rect.top + (18f * scale),
                intArrayOf(
                    adjustAlpha(intensifyColor(vividTextColor, 0.12f), 0.98f * safeAlpha),
                    adjustAlpha(intensifyColor(vividTextColorSecondary, 0.18f), 0.96f * safeAlpha),
                    adjustAlpha(intensifyColor(vividTextColor, 0.06f), 0.94f * safeAlpha),
                ),
                floatArrayOf(0f, 0.52f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        val bodyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            textAlign = Paint.Align.LEFT
            textSize = max(15f, 17f * scale)
            typeface = Typeface.create(Typeface.SERIF, Typeface.NORMAL)
            setShadowLayer(3f * scale, 0f, 1.4f * scale, adjustAlpha(Color.BLACK, 0.24f * safeAlpha))
            shader = LinearGradient(
                rect.left,
                rect.top + (34f * scale),
                rect.right,
                rect.bottom,
                intArrayOf(
                    adjustAlpha(vividTextColor, 0.98f * safeAlpha),
                    adjustAlpha(blendColors(vividTextColorSecondary, vividTextColor, 0.34f), 0.96f * safeAlpha),
                    adjustAlpha(vividTextColorSecondary, 0.94f * safeAlpha),
                ),
                floatArrayOf(0f, 0.44f, 1f),
                Shader.TileMode.CLAMP,
            )
        }

        drawCenteredText(
            canvas = canvas,
            text = title,
            centerX = rect.centerX(),
            centerY = rect.top + (18f * scale),
            paint = titlePaint,
        )
        drawWrappedCenteredText(
            canvas = canvas,
            text = message,
            rect = RectF(
                rect.left + (20f * scale),
                rect.top + (34f * scale),
                rect.right - (20f * scale),
                rect.bottom - (16f * scale),
            ),
            paint = bodyPaint,
            maxLines = 5,
        )
    }

    private fun drawWorldFestivalStaticBase(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        theme: WorldFestivalTheme,
    ) {
        val performanceMode = visualConfig.customOverlay.performanceMode
        val overlayScale = scale * if (performanceMode == "low") 0.96f else 1.02f
        val sideInset = 18f * overlayScale
        val bannerHeight = 60f * overlayScale
        val visualDrop = 28f * overlayScale
        val bannerTop = 28f * overlayScale + visualDrop
        val counterSize = 116f * overlayScale
        val gap = 16f * overlayScale
        val barHeight = max(30f * overlayScale, 34f * overlayScale)
        val barWidth = max(136f * overlayScale, width - (sideInset * 2f) - counterSize - gap)
        val barTop = bannerTop + bannerHeight + (18f * overlayScale)
        val counterTop = max(bannerTop + (8f * overlayScale), barTop - (counterSize * 0.28f))
        val bannerRect = RectF(sideInset, bannerTop, width - sideInset, bannerTop + bannerHeight)
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val counterRect = RectF(
            width - sideInset - counterSize,
            counterTop,
            width - sideInset,
            counterTop + counterSize,
        )
        val signatureRect = RectF(
            counterRect.left + (10f * overlayScale),
            counterRect.bottom + (10f * overlayScale),
            counterRect.right,
            counterRect.bottom + (42f * overlayScale),
        )

        // Draw ALL STATIC elements that never change during video
        drawWorldFestivalAmbientTreatmentStatic(
            canvas = canvas,
            width = width,
            height = height,
            scale = overlayScale,
            theme = theme,
            performanceMode = performanceMode,
        )
        drawWorldFestivalBanner(
            canvas = canvas,
            rect = bannerRect,
            theme = theme,
            scale = overlayScale,
        )
        // Draw static accuracy bar background only
        drawWorldFestivalAccuracyBarStatic(
            canvas = canvas,
            rect = barRect,
            scale = overlayScale,
            height = height,
            theme = theme,
            performanceMode = performanceMode,
        )
        // Draw static rep counter background only
        drawWorldFestivalRepCounterStatic(
            canvas = canvas,
            rect = counterRect,
            scale = overlayScale,
            theme = theme,
            performanceMode = performanceMode,
        )
    }

    private fun drawWorldFestivalDynamicOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
    ) {
        val performanceMode = visualConfig.customOverlay.performanceMode
        val overlayScale = scale * if (performanceMode == "low") 0.96f else 1.02f
        val sideInset = 18f * overlayScale
        val bannerHeight = 60f * overlayScale
        val visualDrop = 28f * overlayScale
        val bannerTop = 28f * overlayScale + visualDrop
        val counterSize = 116f * overlayScale
        val gap = 16f * overlayScale
        val barHeight = max(30f * overlayScale, 34f * overlayScale)
        val barWidth = max(136f * overlayScale, width - (sideInset * 2f) - counterSize - gap)
        val barTop = bannerTop + bannerHeight + (18f * overlayScale)
        val counterTop = max(bannerTop + (8f * overlayScale), barTop - (counterSize * 0.28f))
        val barRect = RectF(sideInset, barTop, sideInset + barWidth, barTop + barHeight)
        val counterRect = RectF(
            width - sideInset - counterSize,
            counterTop,
            width - sideInset,
            counterTop + counterSize,
        )

        // ONLY DRAW DYNAMIC CHANGING VALUES HERE
        drawWorldFestivalAmbientDynamic(
            canvas = canvas,
            width = width,
            height = height,
            scale = overlayScale,
            theme = theme,
            performanceMode = performanceMode,
            presentationTimeUs = presentationTimeUs,
        )
        if (visualConfig.customOverlay.accuracyBar.show) {
            drawWorldFestivalAccuracyBarDynamic(
                canvas = canvas,
                rect = barRect,
                accuracy = state.accuracy,
                scale = overlayScale,
                height = height,
                theme = theme,
                performanceMode = performanceMode,
                presentationTimeUs = presentationTimeUs,
            )
        }
        if (visualConfig.customOverlay.repCounter.show) {
            drawWorldFestivalRepCounterDynamic(
                canvas = canvas,
                rect = counterRect,
                repCount = state.repCount,
                phase = state.phase,
                scale = overlayScale,
                theme = theme,
                performanceMode = performanceMode,
                presentationTimeUs = presentationTimeUs,
            )
        }
    }

    private fun drawWorldFestivalAmbientTreatmentStatic(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
    ) {
        // Static ambient elements that don't animate
        val warmGlow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                width * 0.16f,
                height * 0.12f,
                width * 0.42f,
                intArrayOf(
                    adjustAlpha(theme.accent1, if (performanceMode == "low") 0.12f else 0.18f),
                    adjustAlpha(theme.primaryStart, 0.04f),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.52f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        val canopy = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f,
                0f,
                width,
                height * 0.24f,
                intArrayOf(
                    adjustAlpha(blendColors(theme.primaryStart, theme.primaryEnd, 0.18f), 0.24f),
                    adjustAlpha(theme.primaryEnd, 0.10f),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.55f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, width, height, warmGlow)
        canvas.drawRect(0f, 0f, width, height * 0.26f, canopy)

        val arcPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.accent2, if (performanceMode == "low") 0.08f else 0.12f)
            style = Paint.Style.STROKE
            strokeWidth = 1.1f * scale
        }
        canvas.drawArc(
            RectF(width * 0.05f, height * 0.08f, width * 0.58f, height * 0.46f),
            204f,
            112f,
            false,
            arcPaint,
        )
    }

    private fun drawWorldFestivalAmbientDynamic(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
        presentationTimeUs: Long,
    ) {
        // ONLY animated dynamic elements
        val pulse = ((sin(presentationTimeUs / 580000.0) + 1.0) / 2.0).toFloat()
        val coolGlow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                width * 0.84f,
                height * 0.20f,
                width * 0.36f,
                intArrayOf(
                    adjustAlpha(theme.glowColor, 0.14f + (0.10f * pulse)),
                    adjustAlpha(theme.primaryEnd, 0.05f),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.46f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, width, height, coolGlow)

        if (performanceMode != "low") {
            val sparklePaint = Paint(Paint.ANTI_ALIAS_FLAG)
            repeat(6) { index ->
                val t = ((presentationTimeUs / 1000L) % 4000L) / 4000f
                val x = width * (0.12f + (index * 0.13f))
                val y = height * (0.13f + ((index % 3) * 0.05f))
                val radius = (1.4f + ((index % 3) * 0.5f)) * scale
                sparklePaint.color = adjustAlpha(
                    if (index % 2 == 0) theme.accent1 else theme.glowColor,
                    0.16f + (0.10f * ((t + (index * 0.08f)) % 1f)),
                )
                canvas.drawCircle(x, y, radius, sparklePaint)
            }
        }
    }

    private fun drawWorldFestivalAccuracyBarStatic(
        canvas: Canvas,
        rect: RectF,
        scale: Float,
        height: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
    ) {
        val variantId = theme.variantId
        val tuning = visualConfig.customOverlay.accuracyBar
        val glowIntensity = tuning.glowIntensity.coerceIn(0f, 1f)
        val thresholdGlow = tuning.thresholdGlow.coerceIn(0f, 1f)
        val vividAccent2 = intensifyColor(theme.accent2, 0.12f)
        val vividGlow = intensifyColor(theme.glowColor, 0.18f)
        val trackPath = buildWorldFestivalBarPath(rect, variantId, 0f)
        val innerPath = buildWorldFestivalBarPath(rect, variantId, max(1.4f * scale, 1.2f))

        // Draw static background and outline - never changes
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividGlow, (if (performanceMode == "low") 0.11f else 0.16f) + (0.18f * glowIntensity))
                maskFilter = BlurMaskFilter((10f + (12f * glowIntensity)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(theme.primaryStart, Color.BLACK, 0.12f), 0.94f),
                        adjustAlpha(blendColors(theme.primaryEnd, theme.primaryStart, 0.32f), 0.96f),
                        adjustAlpha(blendColors(intensifyColor(theme.accuracyBarGradient.last(), 0.14f), theme.primaryEnd, 0.16f), 0.78f),
                    ),
                    floatArrayOf(0f, 0.54f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.left,
                    rect.bottom,
                    intArrayOf(
                        Color.argb(54, 255, 255, 255),
                        Color.argb(18, 255, 252, 242),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.24f, 0.74f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividAccent2, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.2f * scale)
            },
        )

        canvas.save()
        canvas.clipPath(innerPath)
        canvas.drawRect(
            rect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    theme.accuracyBarGradient.map { adjustAlpha(intensifyColor(it, 0.10f), 0.24f) }.toIntArray(),
                    null,
                    Shader.TileMode.CLAMP,
                )
            },
        )

        if (performanceMode != "low") {
            val sheenPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent2, 0.08f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            }
            repeat(3) { index ->
                val y = rect.top + (rect.height() * (0.24f + (index * 0.24f)))
                val path = Path().apply {
                    moveTo(rect.left - (6f * scale), y)
                    cubicTo(
                        rect.left + (rect.width() * 0.28f),
                        y - (rect.height() * 0.18f),
                        rect.left + (rect.width() * 0.64f),
                        y + (rect.height() * 0.18f),
                        rect.right + (6f * scale),
                        y - (rect.height() * 0.04f),
                    )
                }
                canvas.drawPath(path, sheenPaint)
            }
        }

        // Static threshold line marker
        val markerX = rect.left + (rect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(
                markerX - ((1.8f + (1.2f * thresholdGlow)) * scale),
                rect.top + (3f * scale),
                markerX + ((1.8f + (1.2f * thresholdGlow)) * scale),
                rect.bottom - (3f * scale),
            ),
            99f,
            99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(intensifyColor(theme.thresholdLineColor, 0.10f), 0.82f + (0.18f * thresholdGlow))
            },
        )

        drawWorldFestivalBarOrnaments(
            canvas = canvas,
            rect = rect,
            variantId = variantId,
            scale = scale,
            theme = theme,
            performanceMode = performanceMode,
        )
        canvas.restore()
    }

    private fun drawWorldFestivalAccuracyBarDynamic(
        canvas: Canvas,
        rect: RectF,
        accuracy: Float,
        scale: Float,
        height: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
        presentationTimeUs: Long,
    ) {
        val safeAccuracy = accuracy.coerceIn(0f, 1f)
        val variantId = theme.variantId
        val tuning = visualConfig.customOverlay.accuracyBar
        val glowIntensity = tuning.glowIntensity.coerceIn(0f, 1f)
        val spillLength = tuning.spillLength.coerceIn(0f, 1f)
        val spillWidth = tuning.spillWidth.coerceIn(0f, 1f)
        val thresholdGlow = tuning.thresholdGlow.coerceIn(0f, 1f)
        val liquidMotion = tuning.liquidMotion.coerceIn(0f, 1f)
        val vividAccent1 = intensifyColor(theme.accent1, 0.16f)
        val vividAccent2 = intensifyColor(theme.accent2, 0.12f)
        val flowDuration = max(1800f, 3600f - (1400f * liquidMotion))
        val flowPhase = ((presentationTimeUs / 1000L) % flowDuration.toLong()).toFloat() / flowDuration
        val fillColor = accuracyColorForFestival(theme, safeAccuracy)

        // Dynamic fill and animations
        val fillWidth = rect.width() * safeAccuracy
        if (fillWidth > 3f * scale) {
            val fillPath = buildWorldFestivalLiquidPath(rect, safeAccuracy, variantId, flowPhase)
            canvas.drawPath(
                fillPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        rect.left,
                        rect.top,
                        rect.left + fillWidth,
                        rect.bottom,
                        intArrayOf(
                            adjustAlpha(blendColors(fillColor, theme.primaryEnd, 0.24f), 0.94f),
                            adjustAlpha(fillColor, 0.98f),
                            adjustAlpha(vividAccent1, 1f),
                        ),
                        floatArrayOf(0f, 0.56f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )

            val highlightPath = buildWorldFestivalLiquidPath(
                RectF(rect.left, rect.top + (rect.height() * 0.08f), rect.right, rect.bottom - (rect.height() * 0.42f)),
                safeAccuracy * 0.96f,
                variantId,
                (flowPhase + 0.18f) % 1f,
            )
            canvas.drawPath(
                highlightPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(vividAccent2, (if (performanceMode == "low") 0.10f else 0.16f) + (0.12f * liquidMotion))
                },
            )
            canvas.drawRect(
                rect.left,
                rect.top + (rect.height() * 0.62f),
                rect.left + fillWidth,
                rect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        rect.left,
                        rect.top,
                        rect.left,
                        rect.bottom,
                        intArrayOf(
                            Color.TRANSPARENT,
                            adjustAlpha(blendColors(fillColor, Color.BLACK, 0.12f), 0.12f),
                            adjustAlpha(blendColors(fillColor, Color.BLACK, 0.22f), 0.24f),
                        ),
                        floatArrayOf(0f, 0.34f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )

            if (performanceMode != "low") {
                val shimmerX = rect.left + (fillWidth * flowPhase)
                canvas.drawRect(
                    shimmerX - (14f * scale),
                    rect.top,
                    shimmerX + (14f * scale),
                    rect.bottom,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = LinearGradient(
                            shimmerX - (16f * scale),
                            rect.top,
                            shimmerX + (16f * scale),
                            rect.bottom,
                            intArrayOf(Color.TRANSPARENT, adjustAlpha(vividAccent2, 0.34f), Color.TRANSPARENT),
                            floatArrayOf(0f, 0.5f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
            }
        }

        // Dynamic threshold glow effect
        val markerX = rect.left + (rect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(
                markerX - ((4.2f + (4.8f * thresholdGlow)) * scale),
                rect.top + (1f * scale),
                markerX + ((4.2f + (4.8f * thresholdGlow)) * scale),
                rect.bottom - (1f * scale),
            ),
            99f,
            99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.thresholdLineColor, 0.12f + (0.24f * thresholdGlow))
                maskFilter = BlurMaskFilter((8f + (12f * thresholdGlow)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )

        if (safeAccuracy >= 0.8f) {
            drawWorldFestivalLiquidSpill(
                canvas = canvas,
                originX = markerX,
                originY = rect.bottom - (1.5f * scale),
                screenHeight = height,
                scale = scale,
                intensity = ((safeAccuracy - 0.8f) / 0.2f).coerceIn(0f, 1f),
                variantId = variantId,
                theme = theme,
                performanceMode = performanceMode,
                presentationTimeUs = presentationTimeUs,
                spillLength = spillLength,
                spillWidth = spillWidth,
                glowIntensity = glowIntensity,
                liquidMotion = liquidMotion,
            )
        }
    }

    private fun drawWorldFestivalRepCounterStatic(
        canvas: Canvas,
        rect: RectF,
        scale: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
    ) {
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = rect.width() / 2f
        val ringWidth = max(7f * scale, rect.width() * 0.082f)
        val vividAccent2 = intensifyColor(theme.accent2, 0.12f)
        val vividGlow = intensifyColor(theme.glowColor, 0.18f)
        val equipmentIndex = worldFestivalEquipmentIndex(theme.storageKey)

        // Static ring glow background - never changes
        canvas.drawCircle(
            centerX,
            centerY,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividGlow, if (performanceMode == "low") 0.14f else 0.24f)
                style = Paint.Style.STROKE
                strokeWidth = ringWidth + (6f * scale)
                maskFilter = BlurMaskFilter(14f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )

        // Static shell background - never changes
        val shellRadius = radius - ringWidth - (4f * scale)
        canvas.drawCircle(
            centerX,
            centerY,
            shellRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    centerX,
                    centerY,
                    shellRadius,
                    intArrayOf(
                        adjustAlpha(blendColors(vividAccent2, theme.primaryEnd, 0.16f), 1f),
                        adjustAlpha(blendColors(theme.primaryStart, theme.primaryEnd, 0.24f), 0.98f),
                        adjustAlpha(blendColors(theme.primaryStart, Color.BLACK, 0.12f), 0.98f),
                    ),
                    floatArrayOf(0f, 0.58f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        if (equipmentIndex >= 0) {
            drawWorldFestivalEquipmentCoreStatic(
                canvas = canvas,
                rect = RectF(
                    centerX - (shellRadius * 0.70f),
                    centerY - (shellRadius * 0.62f),
                    centerX + (shellRadius * 0.70f),
                    centerY + (shellRadius * 0.62f),
                ),
                theme = theme,
                scale = scale,
                equipmentIndex = equipmentIndex,
            )
        }
        canvas.drawCircle(
            centerX - (shellRadius * 0.18f),
            centerY - (shellRadius * 0.22f),
            shellRadius * 0.78f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    centerX - (shellRadius * 0.18f),
                    centerY - (shellRadius * 0.22f),
                    shellRadius * 0.84f,
                    intArrayOf(
                        Color.argb(82, 255, 255, 255),
                        Color.argb(26, 255, 248, 234),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.24f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        // Static ring gradient - never changes
        if (theme.variantId % 2 == 0) {
            canvas.drawCircle(
                centerX,
                centerY,
                radius - (ringWidth / 2f),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    style = Paint.Style.STROKE
                    strokeCap = Paint.Cap.ROUND
                    strokeWidth = ringWidth
                    shader = SweepGradient(
                        centerX,
                        centerY,
                        (theme.ringGradient + theme.ringGradient.first()).toIntArray(),
                        null,
                    )
                },
            )
        } else {
            canvas.drawArc(
                RectF(
                    rect.left + (ringWidth / 2f),
                    rect.top + (ringWidth / 2f),
                    rect.right - (ringWidth / 2f),
                    rect.bottom - (ringWidth / 2f),
                ),
                216f,
                144f,
                false,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    style = Paint.Style.STROKE
                    strokeWidth = ringWidth
                    shader = SweepGradient(
                        centerX,
                        centerY,
                        (theme.ringGradient + theme.ringGradient.first()).toIntArray(),
                        null,
                    )
                },
            )
        }
    }

    private fun drawWorldFestivalRepCounterDynamic(
        canvas: Canvas,
        rect: RectF,
        repCount: Int,
        phase: String,
        scale: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
        presentationTimeUs: Long,
    ) {
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = rect.width() / 2f
        val phaseColor = phaseColorForFestival(theme, phase)
        val surfaceDepth = visualConfig.customOverlay.repCounter.surfaceDepth.coerceIn(0f, 1f)
        val orbitIntensity = visualConfig.customOverlay.repCounter.orbitIntensity.coerceIn(0f, 1f)
        val pulse = ((sin(presentationTimeUs / 360000.0) + 1.0) / 2.0).toFloat()
        val ringWidth = max(7f * scale, rect.width() * 0.082f)
        val vividAccent1 = intensifyColor(theme.accent1, 0.18f)
        val vividAccent2 = intensifyColor(theme.accent2, 0.12f)
        val equipmentIndex = worldFestivalEquipmentIndex(theme.storageKey)

        // Dynamic phase indicator ring
        canvas.drawCircle(
            centerX,
            centerY,
            radius - ringWidth - (2f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = phaseColor
                style = Paint.Style.STROKE
                strokeWidth = max(3f * scale, 2f)
                strokeCap = Paint.Cap.ROUND
            },
        )

        // Dynamic rep number text
        val repText = repCount.toString()
        val repTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = vividAccent1
            textAlign = Paint.Align.CENTER
            typeface = android.graphics.Typeface.create(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD)
            textSize = min(radius * if (equipmentIndex >= 0) 0.72f else 0.8f, 48f * scale)
        }
        val repTextBounds = android.graphics.Rect()
        repTextPaint.getTextBounds(repText, 0, repText.length, repTextBounds)
        canvas.drawText(
            repText,
            centerX,
            centerY + (repTextBounds.height() / 2f),
            repTextPaint,
        )
        if (equipmentIndex >= 0) {
            val coreRect = RectF(
                centerX - ((radius - ringWidth - (4f * scale)) * 0.70f),
                centerY - ((radius - ringWidth - (4f * scale)) * 0.62f),
                centerX + ((radius - ringWidth - (4f * scale)) * 0.70f),
                centerY + ((radius - ringWidth - (4f * scale)) * 0.62f),
            )
            drawWorldFestivalEquipmentCoreDynamic(
                canvas = canvas,
                rect = coreRect,
                phaseColor = phaseColor,
                pulse = pulse,
                scale = scale,
                equipmentIndex = equipmentIndex,
            )
        }

        // Dynamic phase glow effect
        if (performanceMode != "low") {
            canvas.drawCircle(
                centerX,
                centerY,
                radius - ringWidth - (1f * scale),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(phaseColor, 0.3f + (0.2f * pulse))
                    style = Paint.Style.STROKE
                    strokeWidth = max(1f, 2f * scale)
                    maskFilter = BlurMaskFilter(8f * scale, BlurMaskFilter.Blur.NORMAL)
                },
            )
        }

        // Dynamic orbital elements
        if (orbitIntensity > 0f) {
            val orbitRadius = radius - ringWidth - (8f * scale)
            val orbitAngle = ((presentationTimeUs / 2000000.0) % (2 * Math.PI)).toFloat()
            val orbitX = centerX + (orbitRadius * kotlin.math.cos(orbitAngle))
            val orbitY = centerY + (orbitRadius * sin(orbitAngle))

            canvas.drawCircle(
                orbitX.toFloat(),
                orbitY.toFloat(),
                4f * scale,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(vividAccent2, 0.6f * orbitIntensity)
                    maskFilter = BlurMaskFilter(3f * scale, BlurMaskFilter.Blur.NORMAL)
                },
            )
        }
    }

    private fun worldFestivalEquipmentIndex(storageKey: String): Int {
        return when (storageKey.lowercase(Locale.US)) {
            "new_year" -> 0
            "harbin_ice" -> 1
            "australian_open" -> 2
            "sundance" -> 3
            "venice_carnival" -> 4
            "sapporo_snow" -> 5
            "super_bowl" -> 6
            "berlinale" -> 7
            "rio_carnival" -> 8
            "daytona_500" -> 9
            "tokyo_marathon" -> 10
            "the_oscars" -> 11
            "sxsw" -> 12
            "las_fallas" -> 13
            "happiness_day" -> 14
            "hanami" -> 15
            "april_fools" -> 16
            "coachella" -> 17
            "boston_marathon" -> 18
            "earth_day" -> 19
            "london_marathon" -> 20
            "dance_day" -> 21
            "met_gala" -> 22
            "cinco_de_mayo" -> 23
            "cannes" -> 24
            "eurovision" -> 25
            "halloween" -> 26
            "thanksgiving" -> 27
            "diwali" -> 28
            "christmas" -> 29
            "new_years_eve" -> 30
            "french_open" -> 31
            "vivid_sydney" -> 32
            "global_running_day" -> 33
            "environment_day" -> 34
            "white_nights" -> 35
            "midsummer" -> 36
            "yoga_day" -> 37
            "glastonbury" -> 38
            "wimbledon" -> 39
            else -> -1
        }
    }

    private fun drawWorldFestivalEquipmentCoreStatic(
        canvas: Canvas,
        rect: RectF,
        theme: WorldFestivalTheme,
        scale: Float,
        equipmentIndex: Int,
    ) {
        val path = buildWorldFestivalEquipmentPath(rect, equipmentIndex)
        canvas.drawPath(
            path,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(theme.primaryStart, theme.accent1, 0.20f), 0.94f),
                        adjustAlpha(blendColors(theme.primaryEnd, theme.accent2, 0.20f), 0.92f),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawPath(
            path,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent2, 0.24f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.0f * scale)
            },
        )
    }

    private fun drawWorldFestivalEquipmentCoreDynamic(
        canvas: Canvas,
        rect: RectF,
        phaseColor: Int,
        pulse: Float,
        scale: Float,
        equipmentIndex: Int,
    ) {
        val path = buildWorldFestivalEquipmentPath(rect, equipmentIndex)
        canvas.drawPath(
            path,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(phaseColor, 0.10f + (0.16f * pulse))
                maskFilter = BlurMaskFilter((4f + (3f * pulse)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawPath(
            path,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(phaseColor, 0.48f + (0.18f * pulse))
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.2f * scale)
            },
        )
    }

    private fun buildWorldFestivalEquipmentPath(rect: RectF, equipmentIndex: Int): Path {
        val inset = min(rect.width(), rect.height()) * 0.06f
        val r = RectF(rect.left + inset, rect.top + inset, rect.right - inset, rect.bottom - inset)
        val w = r.width()
        val h = r.height()
        val cx = r.centerX()
        val cy = r.centerY()
        val path = Path()
        when (equipmentIndex) {
            0 -> { // barbell plate
                path.addRoundRect(RectF(r.left + (w * 0.12f), cy - (h * 0.18f), r.right - (w * 0.12f), cy + (h * 0.18f)), h * 0.16f, h * 0.16f, Path.Direction.CW)
                path.addOval(RectF(r.left, cy - (h * 0.28f), r.left + (w * 0.24f), cy + (h * 0.28f)), Path.Direction.CW)
                path.addOval(RectF(r.right - (w * 0.24f), cy - (h * 0.28f), r.right, cy + (h * 0.28f)), Path.Direction.CW)
            }
            1 -> { // kettlebell
                path.addOval(RectF(r.left + (w * 0.12f), r.top + (h * 0.26f), r.right - (w * 0.12f), r.bottom), Path.Direction.CW)
                path.addRoundRect(RectF(cx - (w * 0.18f), r.top, cx + (w * 0.18f), r.top + (h * 0.28f)), h * 0.12f, h * 0.12f, Path.Direction.CW)
            }
            2 -> { // racket
                path.addOval(RectF(r.left + (w * 0.08f), r.top, r.right - (w * 0.28f), r.bottom - (h * 0.10f)), Path.Direction.CW)
                path.addRoundRect(RectF(r.right - (w * 0.34f), cy - (h * 0.08f), r.right, cy + (h * 0.08f)), h * 0.06f, h * 0.06f, Path.Direction.CW)
            }
            3 -> { // clapper board
                path.addRoundRect(RectF(r.left + (w * 0.08f), r.top + (h * 0.22f), r.right - (w * 0.08f), r.bottom), h * 0.08f, h * 0.08f, Path.Direction.CW)
                path.moveTo(r.left + (w * 0.14f), r.top + (h * 0.20f))
                path.lineTo(r.right - (w * 0.14f), r.top)
                path.lineTo(r.right - (w * 0.06f), r.top + (h * 0.18f))
                path.lineTo(r.left + (w * 0.22f), r.top + (h * 0.32f))
                path.close()
            }
            4 -> { // carnival mask
                path.addRoundRect(RectF(r.left + (w * 0.04f), r.top + (h * 0.18f), r.right - (w * 0.04f), r.bottom - (h * 0.18f)), h * 0.28f, h * 0.28f, Path.Direction.CW)
            }
            5 -> { // snowboard
                path.addRoundRect(RectF(r.left, cy - (h * 0.20f), r.right, cy + (h * 0.20f)), h * 0.24f, h * 0.24f, Path.Direction.CW)
            }
            6 -> { // football helmet
                path.moveTo(r.left + (w * 0.10f), cy + (h * 0.22f))
                path.cubicTo(r.left + (w * 0.06f), cy - (h * 0.22f), r.left + (w * 0.36f), r.top, r.right - (w * 0.16f), r.top + (h * 0.16f))
                path.lineTo(r.right - (w * 0.06f), cy - (h * 0.02f))
                path.lineTo(r.right - (w * 0.18f), cy + (h * 0.22f))
                path.close()
            }
            7 -> { // camera
                path.addRoundRect(RectF(r.left + (w * 0.08f), r.top + (h * 0.18f), r.right - (w * 0.08f), r.bottom), h * 0.08f, h * 0.08f, Path.Direction.CW)
                path.addOval(RectF(r.left + (w * 0.16f), r.top, r.left + (w * 0.42f), r.top + (h * 0.26f)), Path.Direction.CW)
                path.addOval(RectF(r.right - (w * 0.42f), r.top, r.right - (w * 0.16f), r.top + (h * 0.26f)), Path.Direction.CW)
            }
            8 -> { // drum
                path.moveTo(r.left + (w * 0.16f), r.top)
                path.lineTo(r.right - (w * 0.16f), r.top)
                path.lineTo(r.right, cy)
                path.lineTo(r.right - (w * 0.16f), r.bottom)
                path.lineTo(r.left + (w * 0.16f), r.bottom)
                path.lineTo(r.left, cy)
                path.close()
            }
            9 -> { // steering wheel
                path.addOval(RectF(r.left + (w * 0.06f), r.top + (h * 0.06f), r.right - (w * 0.06f), r.bottom - (h * 0.06f)), Path.Direction.CW)
                path.addOval(RectF(cx - (w * 0.12f), cy - (h * 0.12f), cx + (w * 0.12f), cy + (h * 0.12f)), Path.Direction.CW)
            }
            10 -> { // marathon bib
                path.addRoundRect(RectF(r.left + (w * 0.10f), r.top + (h * 0.06f), r.right - (w * 0.10f), r.bottom), h * 0.10f, h * 0.10f, Path.Direction.CW)
            }
            11 -> { // trophy
                path.addRoundRect(RectF(cx - (w * 0.20f), r.top + (h * 0.16f), cx + (w * 0.20f), r.bottom - (h * 0.18f)), h * 0.08f, h * 0.08f, Path.Direction.CW)
                path.addRoundRect(RectF(cx - (w * 0.32f), r.bottom - (h * 0.16f), cx + (w * 0.32f), r.bottom), h * 0.05f, h * 0.05f, Path.Direction.CW)
            }
            12 -> { // boombox
                path.addRoundRect(RectF(r.left + (w * 0.06f), r.top + (h * 0.18f), r.right - (w * 0.06f), r.bottom), h * 0.08f, h * 0.08f, Path.Direction.CW)
                path.addRoundRect(RectF(r.left + (w * 0.26f), r.top, r.right - (w * 0.26f), r.top + (h * 0.22f)), h * 0.06f, h * 0.06f, Path.Direction.CW)
            }
            13 -> { // torch
                path.moveTo(cx - (w * 0.10f), r.top + (h * 0.24f))
                path.lineTo(cx + (w * 0.10f), r.top + (h * 0.24f))
                path.lineTo(cx + (w * 0.20f), r.bottom)
                path.lineTo(cx - (w * 0.20f), r.bottom)
                path.close()
            }
            14 -> { // smile device
                path.addRoundRect(RectF(r.left + (w * 0.08f), r.top + (h * 0.16f), r.right - (w * 0.08f), r.bottom - (h * 0.08f)), h * 0.20f, h * 0.20f, Path.Direction.CW)
            }
            15 -> { // petal
                path.moveTo(cx, r.top)
                path.cubicTo(r.right, r.top + (h * 0.24f), r.right - (w * 0.02f), r.bottom, cx, r.bottom)
                path.cubicTo(r.left + (w * 0.02f), r.bottom, r.left, r.top + (h * 0.24f), cx, r.top)
                path.close()
            }
            16 -> { // jester hat
                path.moveTo(r.left + (w * 0.10f), r.bottom - (h * 0.08f))
                path.lineTo(cx, r.top)
                path.lineTo(r.right - (w * 0.10f), r.bottom - (h * 0.08f))
                path.close()
            }
            17 -> { // speaker stack
                path.addRoundRect(RectF(r.left + (w * 0.16f), r.top, r.right - (w * 0.16f), r.bottom), h * 0.08f, h * 0.08f, Path.Direction.CW)
                path.addOval(RectF(cx - (w * 0.18f), cy - (h * 0.18f), cx + (w * 0.18f), cy + (h * 0.18f)), Path.Direction.CW)
            }
            18 -> { // medal
                path.addOval(RectF(r.left + (w * 0.14f), r.top + (h * 0.16f), r.right - (w * 0.14f), r.bottom), Path.Direction.CW)
                path.moveTo(cx - (w * 0.16f), r.top + (h * 0.18f))
                path.lineTo(cx - (w * 0.03f), r.top)
                path.lineTo(cx + (w * 0.03f), r.top)
                path.lineTo(cx + (w * 0.16f), r.top + (h * 0.18f))
                path.close()
            }
            19 -> { // eco leaf badge
                path.moveTo(cx - (w * 0.04f), r.top + (h * 0.06f))
                path.cubicTo(r.right, r.top + (h * 0.12f), r.right - (w * 0.06f), r.bottom - (h * 0.04f), cx - (w * 0.06f), r.bottom)
                path.cubicTo(r.left + (w * 0.02f), r.bottom - (h * 0.18f), r.left + (w * 0.02f), r.top + (h * 0.24f), cx - (w * 0.04f), r.top + (h * 0.06f))
                path.close()
            }
            20 -> { // stopwatch
                path.addOval(RectF(r.left + (w * 0.10f), r.top + (h * 0.10f), r.right - (w * 0.10f), r.bottom), Path.Direction.CW)
                path.addRoundRect(RectF(cx - (w * 0.10f), r.top, cx + (w * 0.10f), r.top + (h * 0.14f)), h * 0.04f, h * 0.04f, Path.Direction.CW)
            }
            21 -> { // dance shoe
                path.moveTo(r.left + (w * 0.08f), cy + (h * 0.10f))
                path.cubicTo(r.left + (w * 0.30f), r.top, r.right - (w * 0.04f), r.top + (h * 0.18f), r.right - (w * 0.10f), cy + (h * 0.22f))
                path.lineTo(r.left + (w * 0.18f), r.bottom - (h * 0.02f))
                path.close()
            }
            22 -> { // tuxedo bow tie
                path.moveTo(cx, cy)
                path.lineTo(r.left + (w * 0.04f), r.top + (h * 0.16f))
                path.lineTo(r.left + (w * 0.30f), cy)
                path.lineTo(r.left + (w * 0.04f), r.bottom - (h * 0.16f))
                path.close()
                path.moveTo(cx, cy)
                path.lineTo(r.right - (w * 0.04f), r.top + (h * 0.16f))
                path.lineTo(r.right - (w * 0.30f), cy)
                path.lineTo(r.right - (w * 0.04f), r.bottom - (h * 0.16f))
                path.close()
                path.addRoundRect(RectF(cx - (w * 0.06f), cy - (h * 0.08f), cx + (w * 0.06f), cy + (h * 0.08f)), h * 0.04f, h * 0.04f, Path.Direction.CW)
            }
            23 -> { // sombrero
                path.addRoundRect(RectF(r.left + (w * 0.04f), cy + (h * 0.18f), r.right - (w * 0.04f), r.bottom - (h * 0.06f)), h * 0.12f, h * 0.12f, Path.Direction.CW)
                path.addOval(RectF(cx - (w * 0.24f), r.top + (h * 0.12f), cx + (w * 0.24f), cy + (h * 0.26f)), Path.Direction.CW)
            }
            24 -> { // film reel
                path.addOval(RectF(r.left + (w * 0.08f), r.top + (h * 0.08f), r.right - (w * 0.08f), r.bottom - (h * 0.08f)), Path.Direction.CW)
                path.addRoundRect(RectF(cx - (w * 0.08f), cy - (h * 0.08f), cx + (w * 0.08f), cy + (h * 0.08f)), h * 0.03f, h * 0.03f, Path.Direction.CW)
            }
            25 -> { // microphone
                path.addRoundRect(RectF(cx - (w * 0.14f), r.top + (h * 0.06f), cx + (w * 0.14f), cy + (h * 0.18f)), h * 0.14f, h * 0.14f, Path.Direction.CW)
                path.addRoundRect(RectF(cx - (w * 0.06f), cy + (h * 0.08f), cx + (w * 0.06f), r.bottom), h * 0.04f, h * 0.04f, Path.Direction.CW)
            }
            26 -> { // pumpkin
                path.addOval(RectF(r.left + (w * 0.08f), r.top + (h * 0.14f), r.right - (w * 0.08f), r.bottom), Path.Direction.CW)
                path.addRoundRect(RectF(cx - (w * 0.04f), r.top, cx + (w * 0.04f), r.top + (h * 0.16f)), h * 0.02f, h * 0.02f, Path.Direction.CW)
            }
            27 -> { // platter cloche
                path.addOval(RectF(r.left + (w * 0.10f), r.bottom - (h * 0.24f), r.right - (w * 0.10f), r.bottom), Path.Direction.CW)
                path.addArc(RectF(r.left + (w * 0.14f), r.top + (h * 0.14f), r.right - (w * 0.14f), r.bottom - (h * 0.10f)), 180f, 180f)
                path.close()
            }
            28 -> { // diya lamp
                path.moveTo(r.left + (w * 0.12f), cy + (h * 0.14f))
                path.cubicTo(r.left + (w * 0.24f), r.bottom, r.right - (w * 0.24f), r.bottom, r.right - (w * 0.12f), cy + (h * 0.14f))
                path.cubicTo(r.right - (w * 0.26f), cy - (h * 0.04f), r.left + (w * 0.26f), cy - (h * 0.04f), r.left + (w * 0.12f), cy + (h * 0.14f))
                path.close()
                path.addOval(RectF(cx - (w * 0.06f), r.top + (h * 0.02f), cx + (w * 0.06f), r.top + (h * 0.22f)), Path.Direction.CW)
            }
            29 -> { // bell
                path.moveTo(cx - (w * 0.20f), r.top + (h * 0.20f))
                path.cubicTo(cx - (w * 0.24f), cy, cx - (w * 0.28f), r.bottom - (h * 0.16f), cx, r.bottom - (h * 0.08f))
                path.cubicTo(cx + (w * 0.28f), r.bottom - (h * 0.16f), cx + (w * 0.24f), cy, cx + (w * 0.20f), r.top + (h * 0.20f))
                path.close()
            }
            30 -> { // champagne glass
                path.moveTo(cx - (w * 0.18f), r.top + (h * 0.08f))
                path.lineTo(cx + (w * 0.18f), r.top + (h * 0.08f))
                path.lineTo(cx + (w * 0.08f), cy + (h * 0.10f))
                path.lineTo(cx + (w * 0.02f), cy + (h * 0.18f))
                path.lineTo(cx + (w * 0.02f), r.bottom - (h * 0.08f))
                path.lineTo(cx - (w * 0.02f), r.bottom - (h * 0.08f))
                path.lineTo(cx - (w * 0.02f), cy + (h * 0.18f))
                path.lineTo(cx - (w * 0.08f), cy + (h * 0.10f))
                path.close()
            }
            31 -> { // clay court racket
                path.addOval(RectF(r.left + (w * 0.10f), r.top + (h * 0.02f), r.right - (w * 0.28f), r.bottom - (h * 0.12f)), Path.Direction.CW)
                path.addRoundRect(RectF(r.right - (w * 0.34f), cy - (h * 0.07f), r.right, cy + (h * 0.07f)), h * 0.05f, h * 0.05f, Path.Direction.CW)
            }
            32 -> { // opera house sails
                path.moveTo(r.left + (w * 0.10f), r.bottom)
                path.lineTo(cx - (w * 0.06f), r.top + (h * 0.10f))
                path.lineTo(cx + (w * 0.08f), r.bottom)
                path.close()
                path.moveTo(cx - (w * 0.02f), r.bottom)
                path.lineTo(r.right - (w * 0.20f), r.top + (h * 0.16f))
                path.lineTo(r.right - (w * 0.04f), r.bottom)
                path.close()
            }
            33 -> { // running shoe
                path.moveTo(r.left + (w * 0.06f), cy + (h * 0.16f))
                path.cubicTo(r.left + (w * 0.24f), cy - (h * 0.02f), r.right - (w * 0.18f), cy - (h * 0.04f), r.right - (w * 0.04f), cy + (h * 0.14f))
                path.lineTo(r.left + (w * 0.14f), r.bottom - (h * 0.02f))
                path.close()
            }
            34 -> { // recycle triangle
                path.moveTo(cx, r.top + (h * 0.04f))
                path.lineTo(r.right - (w * 0.08f), r.bottom - (h * 0.10f))
                path.lineTo(r.left + (w * 0.08f), r.bottom - (h * 0.10f))
                path.close()
            }
            35 -> { // bridge arch
                path.addRoundRect(RectF(r.left + (w * 0.08f), r.bottom - (h * 0.18f), r.right - (w * 0.08f), r.bottom), h * 0.05f, h * 0.05f, Path.Direction.CW)
                path.addArc(RectF(r.left + (w * 0.14f), r.top + (h * 0.10f), r.right - (w * 0.14f), r.bottom - (h * 0.08f)), 180f, 180f)
                path.close()
            }
            36 -> { // flower wreath
                path.addOval(RectF(r.left + (w * 0.08f), r.top + (h * 0.08f), r.right - (w * 0.08f), r.bottom - (h * 0.08f)), Path.Direction.CW)
                path.addOval(RectF(cx - (w * 0.14f), cy - (h * 0.14f), cx + (w * 0.14f), cy + (h * 0.14f)), Path.Direction.CW)
            }
            37 -> { // lotus mat
                path.addRoundRect(RectF(r.left + (w * 0.10f), cy + (h * 0.08f), r.right - (w * 0.10f), r.bottom - (h * 0.04f)), h * 0.08f, h * 0.08f, Path.Direction.CW)
                path.moveTo(cx, r.top + (h * 0.10f))
                path.cubicTo(cx + (w * 0.16f), cy, cx + (w * 0.04f), cy + (h * 0.08f), cx, cy + (h * 0.08f))
                path.cubicTo(cx - (w * 0.04f), cy + (h * 0.08f), cx - (w * 0.16f), cy, cx, r.top + (h * 0.10f))
                path.close()
            }
            38 -> { // stage tent
                path.moveTo(r.left + (w * 0.08f), r.bottom - (h * 0.06f))
                path.lineTo(cx, r.top + (h * 0.02f))
                path.lineTo(r.right - (w * 0.08f), r.bottom - (h * 0.06f))
                path.close()
                path.addRoundRect(RectF(r.left + (w * 0.18f), r.bottom - (h * 0.14f), r.right - (w * 0.18f), r.bottom), h * 0.04f, h * 0.04f, Path.Direction.CW)
            }
            39 -> { // tennis ball
                path.addOval(RectF(r.left + (w * 0.08f), r.top + (h * 0.08f), r.right - (w * 0.08f), r.bottom - (h * 0.08f)), Path.Direction.CW)
                path.addArc(RectF(r.left + (w * 0.20f), r.top + (h * 0.10f), r.right - (w * 0.28f), r.bottom - (h * 0.10f)), 86f, 188f)
                path.addArc(RectF(r.left + (w * 0.28f), r.top + (h * 0.10f), r.right - (w * 0.20f), r.bottom - (h * 0.10f)), -94f, 188f)
            }
            else -> {
                path.addOval(r, Path.Direction.CW)
            }
        }
        return path
    }

    private fun drawWorldFestivalBanner(
    canvas: Canvas,
    rect: RectF,
    theme: WorldFestivalTheme,
    scale: Float,
) {
    val radius = 22f * scale
    canvas.drawRoundRect(
        RectF(rect).apply { offset(0f, 4f * scale) },
        radius,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(Color.BLACK, 0.18f)
            maskFilter = BlurMaskFilter(14f * scale, BlurMaskFilter.Blur.NORMAL)
        },
    )
    canvas.drawRoundRect(
        rect,
        radius,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.right,
                rect.bottom,
                intArrayOf(
                    adjustAlpha(blendColors(theme.primaryStart, Color.BLACK, 0.08f), 0.92f),
                    adjustAlpha(blendColors(theme.primaryEnd, theme.primaryStart, 0.26f), 0.94f),
                    adjustAlpha(blendColors(theme.primaryEnd, theme.accent1, 0.22f), 0.86f),
                ),
                floatArrayOf(0f, 0.56f, 1f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawRoundRect(
        rect,
        radius,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.left,
                rect.bottom,
                intArrayOf(
                    Color.argb(72, 255, 255, 255),
                    Color.argb(18, 255, 252, 240),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.28f, 0.76f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawRoundRect(
        rect,
        radius,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.accent2, 0.16f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1.1f * scale)
        },
    )

    val medallionSize = rect.height() - (16f * scale)
    val medallionRect = RectF(
        rect.left + (12f * scale),
        rect.top + (8f * scale),
        rect.left + (12f * scale) + medallionSize,
        rect.bottom - (8f * scale),
    )
    canvas.drawOval(
        medallionRect,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                medallionRect.centerX(),
                medallionRect.centerY(),
                medallionRect.width() * 0.58f,
                intArrayOf(
                    adjustAlpha(theme.accent1, 0.96f),
                    adjustAlpha(blendColors(theme.accent2, theme.accent1, 0.45f), 0.90f),
                    adjustAlpha(blendColors(theme.primaryEnd, theme.accent1, 0.18f), 0.88f),
                ),
                floatArrayOf(0f, 0.52f, 1f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawOval(
        RectF(
            medallionRect.left + (2f * scale),
            medallionRect.top + (2f * scale),
            medallionRect.right - (2f * scale),
            medallionRect.bottom - (2f * scale),
        ),
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                medallionRect.centerX() - (medallionRect.width() * 0.16f),
                medallionRect.centerY() - (medallionRect.height() * 0.22f),
                medallionRect.width() * 0.56f,
                intArrayOf(
                    Color.argb(120, 255, 255, 255),
                    Color.argb(40, 255, 250, 238),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.24f, 1f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawOval(
        medallionRect,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.accent2, 0.18f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1f * scale)
        },
    )
    canvas.drawOval(
        RectF(
            medallionRect.left + (3f * scale),
            medallionRect.top + (3f * scale),
            medallionRect.right - (3f * scale),
            medallionRect.bottom - (3f * scale),
        ),
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.accent2, 0.18f)
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.8f * scale)
        },
    )
    if (isPadaukBranchIcon(theme.bannerIcon)) {
        drawPadaukBranch(
            canvas = canvas,
            rect = RectF(
                medallionRect.left + (6f * scale),
                medallionRect.top + (6f * scale),
                medallionRect.right - (6f * scale),
                medallionRect.bottom - (6f * scale),
            ),
            alpha = 0.96f,
        )
    } else {
        drawCenteredText(
            canvas = canvas,
            text = theme.bannerIcon.ifBlank { "*" },
            centerX = medallionRect.centerX() + (0.9f * scale),
            centerY = medallionRect.centerY() + (1.1f * scale),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(Color.BLACK, 0.30f)
                textAlign = Paint.Align.CENTER
                textSize = max(17f, medallionRect.height() * 0.46f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
        drawCenteredText(
            canvas = canvas,
            text = theme.bannerIcon.ifBlank { "*" },
            centerX = medallionRect.centerX(),
            centerY = medallionRect.centerY(),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = blendColors(theme.primaryStart, Color.BLACK, 0.18f)
                textAlign = Paint.Align.CENTER
                textSize = max(17f, medallionRect.height() * 0.46f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
    }

    val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = theme.accent2
        textAlign = Paint.Align.LEFT
        textSize = max(14f, rect.height() * 0.25f)
        typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
    }
    val subtitlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.accent2, 0.76f)
        textAlign = Paint.Align.LEFT
        textSize = max(10f, rect.height() * 0.15f)
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
    }
    val tagPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.accent1, 0.96f)
        textAlign = Paint.Align.RIGHT
        textSize = max(10f, rect.height() * 0.16f)
        typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
    }
    val tagText = "WORLD FESTIVAL"
    val tagWidth = tagPaint.measureText(tagText)
    val titleX = medallionRect.right + (12f * scale)
    val contentRight = (rect.right - (14f * scale) - tagWidth - (16f * scale)).coerceAtLeast(titleX + (72f * scale))
    val textMaxWidth = max(72f * scale, contentRight - titleX)
    var exerciseTitle = (visualConfig.overlayTitle ?: theme.bannerTitle.ifBlank { theme.themeName })
    var festivalTitle = theme.subtitle.ifBlank { theme.label.ifBlank { theme.themeName } }
    
    // Normalize pre-show labels
    if (exerciseTitle.contains("(pre show)", ignoreCase = true)) {
        exerciseTitle = exerciseTitle.replace("(pre show)", "", ignoreCase = true).trim() + " (pre-show)"
    }
    if (festivalTitle.contains("(pre show)", ignoreCase = true)) {
        festivalTitle = festivalTitle.replace("(pre show)", "", ignoreCase = true).trim() + " (pre-show)"
    }

    val safeFestivalTitle = ellipsizeToWidth(festivalTitle, titlePaint, textMaxWidth)
    val safeExerciseTitle = ellipsizeToWidth(exerciseTitle, subtitlePaint, textMaxWidth)

    val contentPlate = RectF(
        titleX - (6f * scale),
        rect.top + (7f * scale),
        contentRight + (8f * scale),
        rect.bottom - (7f * scale),
    )
    canvas.drawRoundRect(
        contentPlate,
        8f * scale,
        8f * scale,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(Color.BLACK, 0.14f)
        },
    )

    canvas.save()
    canvas.clipRect(titleX - (2f * scale), rect.top, contentRight, rect.bottom)
    canvas.drawText(safeFestivalTitle, titleX, rect.bottom - (rect.height() * 0.58f), titlePaint)
    canvas.drawText(safeExerciseTitle, titleX, rect.bottom - (rect.height() * 0.32f), subtitlePaint)
    canvas.drawLine(
        titleX,
        rect.top + (rect.height() * 0.76f),
        min(contentRight - (4f * scale), titleX + (44f * scale) + titlePaint.measureText(safeFestivalTitle) * 0.42f),
        rect.top + (rect.height() * 0.76f),
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                titleX,
                rect.top,
                titleX + (120f * scale),
                rect.top,
                intArrayOf(
                    adjustAlpha(theme.accent1, 0.58f),
                    adjustAlpha(theme.accent2, 0.14f),
                    Color.TRANSPARENT,
                ),
                null,
                Shader.TileMode.CLAMP,
            )
            strokeWidth = max(1f, 1.1f * scale)
        },
    )
    canvas.restore()
    canvas.drawText(
        tagText,
        rect.right - (14f * scale),
        rect.top + (rect.height() * 0.50f),
        tagPaint,
    )
}

    private fun drawWorldFestivalAccuracyBar(
        canvas: Canvas,
        rect: RectF,
        accuracy: Float,
        scale: Float,
        height: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
        presentationTimeUs: Long,
    ) {
        val safeAccuracy = accuracy.coerceIn(0f, 1f)
        val variantId = theme.variantId
        val tuning = visualConfig.customOverlay.accuracyBar
        val glowIntensity = tuning.glowIntensity.coerceIn(0f, 1f)
        val spillLength = tuning.spillLength.coerceIn(0f, 1f)
        val spillWidth = tuning.spillWidth.coerceIn(0f, 1f)
        val thresholdGlow = tuning.thresholdGlow.coerceIn(0f, 1f)
        val liquidMotion = tuning.liquidMotion.coerceIn(0f, 1f)
        val vividAccent1 = intensifyColor(theme.accent1, 0.16f)
        val vividAccent2 = intensifyColor(theme.accent2, 0.12f)
        val vividGlow = intensifyColor(theme.glowColor, 0.18f)
        val flowDuration = max(1800f, 3600f - (1400f * liquidMotion))
        val flowPhase = ((presentationTimeUs / 1000L) % flowDuration.toLong()).toFloat() / flowDuration
        val trackPath = buildWorldFestivalBarPath(rect, variantId, 0f)
        val innerPath = buildWorldFestivalBarPath(rect, variantId, max(1.4f * scale, 1.2f))
        val fillColor = accuracyColorForFestival(theme, safeAccuracy)

        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividGlow, (if (performanceMode == "low") 0.11f else 0.16f) + (0.18f * glowIntensity))
                maskFilter = BlurMaskFilter((10f + (12f * glowIntensity)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(blendColors(theme.primaryStart, Color.BLACK, 0.12f), 0.94f),
                        adjustAlpha(blendColors(theme.primaryEnd, theme.primaryStart, 0.32f), 0.96f),
                        adjustAlpha(blendColors(intensifyColor(theme.accuracyBarGradient.last(), 0.14f), theme.primaryEnd, 0.16f), 0.78f),
                    ),
                    floatArrayOf(0f, 0.54f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.left,
                    rect.bottom,
                    intArrayOf(
                        Color.argb(54, 255, 255, 255),
                        Color.argb(18, 255, 252, 242),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.24f, 0.74f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawPath(
            trackPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividAccent2, 0.22f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.2f * scale)
            },
        )

        canvas.save()
        canvas.clipPath(innerPath)
        canvas.drawRect(
            rect,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    theme.accuracyBarGradient.map { adjustAlpha(intensifyColor(it, 0.10f), 0.24f) }.toIntArray(),
                    null,
                    Shader.TileMode.CLAMP,
                )
            },
        )

        if (performanceMode != "low") {
            val sheenPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent2, 0.08f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1f * scale)
            }
            repeat(3) { index ->
                val y = rect.top + (rect.height() * (0.24f + (index * 0.24f)))
                val path = Path().apply {
                    moveTo(rect.left - (6f * scale), y)
                    cubicTo(
                        rect.left + (rect.width() * 0.28f),
                        y - (rect.height() * 0.18f),
                        rect.left + (rect.width() * 0.64f),
                        y + (rect.height() * 0.18f),
                        rect.right + (6f * scale),
                        y - (rect.height() * 0.04f),
                    )
                }
                canvas.drawPath(path, sheenPaint)
            }
        }

        val fillWidth = rect.width() * safeAccuracy
        if (fillWidth > 3f * scale) {
            val fillPath = buildWorldFestivalLiquidPath(rect, safeAccuracy, variantId, flowPhase)
            canvas.drawPath(
                fillPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        rect.left,
                        rect.top,
                        rect.left + fillWidth,
                        rect.bottom,
                        intArrayOf(
                            adjustAlpha(blendColors(fillColor, theme.primaryEnd, 0.24f), 0.94f),
                            adjustAlpha(fillColor, 0.98f),
                            adjustAlpha(vividAccent1, 1f),
                        ),
                        floatArrayOf(0f, 0.56f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )

            val highlightPath = buildWorldFestivalLiquidPath(
                RectF(rect.left, rect.top + (rect.height() * 0.08f), rect.right, rect.bottom - (rect.height() * 0.42f)),
                safeAccuracy * 0.96f,
                variantId,
                (flowPhase + 0.18f) % 1f,
            )
            canvas.drawPath(
                highlightPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(vividAccent2, (if (performanceMode == "low") 0.10f else 0.16f) + (0.12f * liquidMotion))
                },
            )
            canvas.drawRect(
                rect.left,
                rect.top + (rect.height() * 0.62f),
                rect.left + fillWidth,
                rect.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        rect.left,
                        rect.top,
                        rect.left,
                        rect.bottom,
                        intArrayOf(
                            Color.TRANSPARENT,
                            adjustAlpha(blendColors(fillColor, Color.BLACK, 0.12f), 0.12f),
                            adjustAlpha(blendColors(fillColor, Color.BLACK, 0.22f), 0.24f),
                        ),
                        floatArrayOf(0f, 0.34f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )

            if (performanceMode != "low") {
                val shimmerX = rect.left + (fillWidth * flowPhase)
                canvas.drawRect(
                    shimmerX - (14f * scale),
                    rect.top,
                    shimmerX + (14f * scale),
                    rect.bottom,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = LinearGradient(
                            shimmerX - (16f * scale),
                            rect.top,
                            shimmerX + (16f * scale),
                            rect.bottom,
                            intArrayOf(Color.TRANSPARENT, adjustAlpha(vividAccent2, 0.34f), Color.TRANSPARENT),
                            floatArrayOf(0f, 0.5f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
            }
        }

        drawWorldFestivalBarOrnaments(
            canvas = canvas,
            rect = rect,
            variantId = variantId,
            scale = scale,
            theme = theme,
            performanceMode = performanceMode,
        )
        canvas.restore()

        val markerX = rect.left + (rect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(
                markerX - ((1.8f + (1.2f * thresholdGlow)) * scale),
                rect.top + (3f * scale),
                markerX + ((1.8f + (1.2f * thresholdGlow)) * scale),
                rect.bottom - (3f * scale),
            ),
            99f,
            99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(intensifyColor(theme.thresholdLineColor, 0.10f), 0.82f + (0.18f * thresholdGlow))
            },
        )
        canvas.drawRoundRect(
            RectF(
                markerX - ((4.2f + (4.8f * thresholdGlow)) * scale),
                rect.top + (1f * scale),
                markerX + ((4.2f + (4.8f * thresholdGlow)) * scale),
                rect.bottom - (1f * scale),
            ),
            99f,
            99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.thresholdLineColor, 0.12f + (0.24f * thresholdGlow))
                maskFilter = BlurMaskFilter((8f + (12f * thresholdGlow)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )

        if (safeAccuracy >= 0.8f) {
            drawWorldFestivalLiquidSpill(
                canvas = canvas,
                originX = markerX,
                originY = rect.bottom - (1.5f * scale),
                screenHeight = height,
                scale = scale,
                intensity = ((safeAccuracy - 0.8f) / 0.2f).coerceIn(0f, 1f),
                variantId = variantId,
                theme = theme,
                performanceMode = performanceMode,
                presentationTimeUs = presentationTimeUs,
                spillLength = spillLength,
                spillWidth = spillWidth,
                glowIntensity = glowIntensity,
                liquidMotion = liquidMotion,
            )
        }

        drawCenteredText(
            canvas = canvas,
            text = "${String.format(Locale.US, "%.1f", safeAccuracy * 100f)}% ACCURACY",
            centerX = rect.centerX(),
            centerY = rect.centerY(),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = vividAccent2
                textAlign = Paint.Align.CENTER
                textSize = max(11f, rect.height() * 0.40f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3.6f * scale, 0f, 1.7f * scale, adjustAlpha(Color.BLACK, 0.34f))
            },
        )
    }

    private fun drawWorldFestivalBarOrnaments(
        canvas: Canvas,
        rect: RectF,
        variantId: Int,
        scale: Float,
        theme: WorldFestivalTheme,
        performanceMode: String,
    ) {
        val ornamentIndex = variantId / 10
        when (ornamentIndex) {
            0 -> {
                canvas.drawPath(
                    buildWorldFestivalBarPath(rect, variantId, 3f * scale),
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accent2, 0.12f)
                        style = Paint.Style.STROKE
                        strokeWidth = max(1f, 0.9f * scale)
                    },
                )
            }
            1 -> {
                val latticePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.12f)
                    strokeWidth = max(1f, 1f * scale)
                }
                repeat(5) { index ->
                    val x = rect.left + (rect.width() * (0.10f + (index * 0.17f)))
                    canvas.drawLine(x - (4f * scale), rect.top + (4f * scale), x + (4f * scale), rect.bottom - (4f * scale), latticePaint)
                }
            }
            2 -> {
                val beadPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.glowColor, if (performanceMode == "low") 0.12f else 0.18f)
                }
                repeat(6) { index ->
                    val x = rect.left + (rect.width() * (0.08f + (index * 0.15f)))
                    val y = if (index % 2 == 0) rect.top + (6f * scale) else rect.bottom - (6f * scale)
                    canvas.drawCircle(x, y, 1.8f * scale, beadPaint)
                }
            }
            else -> {
                val flarePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.16f)
                    style = Paint.Style.FILL
                }
                canvas.drawOval(RectF(rect.left - (8f * scale), rect.top + (4f * scale), rect.left + (12f * scale), rect.bottom - (4f * scale)), flarePaint)
                canvas.drawOval(RectF(rect.right - (12f * scale), rect.top + (4f * scale), rect.right + (8f * scale), rect.bottom - (4f * scale)), flarePaint)
            }
        }
    }

    private fun drawWorldFestivalLiquidSpill(
        canvas: Canvas,
        originX: Float,
        originY: Float,
        screenHeight: Float,
        scale: Float,
        intensity: Float,
        variantId: Int,
        theme: WorldFestivalTheme,
        performanceMode: String,
        presentationTimeUs: Long,
        spillLength: Float,
        spillWidth: Float,
        glowIntensity: Float,
        liquidMotion: Float,
    ) {
        val targetDropY = max(
            screenHeight * 0.5f,
            originY + (screenHeight * (0.18f + (0.08f * intensity) + (0.03f * spillLength))),
        )
        drawThresholdDropletEffect(
            canvas = canvas,
            originX = originX,
            originY = originY,
            targetY = targetDropY,
            accuracy = 0.8f + (0.2f * intensity.coerceIn(0f, 1f)),
            scale = scale,
            presentationTimeUs = presentationTimeUs,
            glowColor = theme.glowColor,
            fillMidColor = theme.accent1,
            fillEndColor = theme.accuracyHighColor,
            swayAmplitude = ((screenHeight * 0.012f) + ((variantId % 10) * 0.8f) + (4f * spillWidth) + (2f * liquidMotion)) * scale,
        )
    }

    private fun drawThresholdDropletEffect(
        canvas: Canvas,
        originX: Float,
        originY: Float,
        targetY: Float,
        accuracy: Float,
        scale: Float,
        presentationTimeUs: Long,
        glowColor: Int,
        fillMidColor: Int,
        fillEndColor: Int,
        swayAmplitude: Float,
    ) {
        if (accuracy < 0.8f) {
            return
        }

        val thresholdProgress = ((accuracy - 0.8f) / 0.2f).coerceIn(0f, 1f)
        val dropDurationMs = max(1800f, 3000f - (600f * thresholdProgress))
        val dropCycle =
            ((presentationTimeUs / 1000L) % dropDurationMs.toLong()).toFloat() / dropDurationMs
        val easedDrop = dropCycle * dropCycle
        val dropletY = originY + ((targetY - originY) * easedDrop)
        val dropletX =
            originX + (kotlin.math.sin(presentationTimeUs / 540000.0).toFloat() * swayAmplitude)
        val fadeStart = 0.72f
        val fadeProgress = ((dropCycle - fadeStart) / (1f - fadeStart)).coerceIn(0f, 1f)
        val dropletAlpha = (1f - fadeProgress) * (0.72f + (0.28f * thresholdProgress))
        val dropletRadius = (4.4f + (2.2f * thresholdProgress)) * scale

        if (dropletAlpha <= 0.01f) {
            return
        }

        if (dropCycle < 0.34f) {
            val streamAlpha = dropletAlpha * (1f - (dropCycle / 0.34f))
            val streamPath = Path().apply {
                moveTo(originX, originY - (1f * scale))
                cubicTo(
                    originX + (3f * scale),
                    originY + ((dropletY - originY) * 0.18f),
                    dropletX - (6f * scale),
                    originY + ((dropletY - originY) * 0.62f),
                    dropletX,
                    dropletY - dropletRadius,
                )
            }
            canvas.drawPath(
                streamPath,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    style = Paint.Style.STROKE
                    strokeCap = Paint.Cap.ROUND
                    strokeJoin = Paint.Join.ROUND
                    strokeWidth = max(1.2f * scale, dropletRadius * 0.55f)
                    shader = LinearGradient(
                        originX,
                        originY,
                        dropletX,
                        dropletY,
                        intArrayOf(
                            adjustAlpha(glowColor, 0f),
                            adjustAlpha(glowColor, streamAlpha * 0.78f),
                            adjustAlpha(fillMidColor, streamAlpha * 0.42f),
                            Color.TRANSPARENT,
                        ),
                        floatArrayOf(0f, 0.20f, 0.72f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
        }

        canvas.drawCircle(
            dropletX,
            dropletY,
            dropletRadius * 1.9f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    dropletX,
                    dropletY,
                    dropletRadius * 1.9f,
                    intArrayOf(
                        adjustAlpha(glowColor, dropletAlpha * 0.34f),
                        adjustAlpha(glowColor, dropletAlpha * 0.10f),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.54f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawCircle(
            dropletX,
            dropletY,
            dropletRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    dropletX - (dropletRadius * 0.18f),
                    dropletY - (dropletRadius * 0.22f),
                    dropletRadius,
                    intArrayOf(
                        adjustAlpha(Color.WHITE, dropletAlpha * 0.98f),
                        adjustAlpha(fillMidColor, dropletAlpha * 0.72f),
                        adjustAlpha(fillEndColor, dropletAlpha * 0.18f),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.24f, 0.72f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
    }

    private fun drawFestivalWaterRibbon(
        canvas: Canvas,
        ribbonPath: Path,
        originX: Float,
        originY: Float,
        destinationX: Float,
        destinationY: Float,
        streamWidth: Float,
        theme: WorldFestivalTheme,
        alpha: Float,
        progress: Float,
        scale: Float,
        performanceMode: String,
        presentationTimeUs: Long,
    ) {
        val safeAlpha = alpha.coerceIn(0f, 1f)
        val depthColor = blendColors(theme.primaryStart, theme.primaryEnd, 0.44f)
        val refractedColor = intensifyColor(blendColors(theme.accent1, theme.accent2, 0.34f), 0.14f)
        val causticColor = intensifyColor(theme.thresholdLineColor, 0.18f)
        val travel = max(1f, destinationY - originY)
        val frontRadius = (streamWidth * (0.58f + (0.10f * progress))).coerceAtLeast(13f * scale)

        canvas.drawPath(
            ribbonPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.glowColor, ((if (performanceMode == "low") 0.12f else 0.16f) + (0.16f * progress)) * safeAlpha)
                maskFilter = BlurMaskFilter((16f + (16f * progress)) * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawPath(
            ribbonPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    originX - (streamWidth * 0.72f),
                    originY,
                    destinationX + (streamWidth * 0.32f),
                    destinationY,
                    intArrayOf(
                        adjustAlpha(blendColors(depthColor, theme.accent1, 0.18f), 0.88f * safeAlpha),
                        adjustAlpha(blendColors(theme.accent1, theme.accent2, 0.26f), 0.94f * safeAlpha),
                        adjustAlpha(refractedColor, 0.70f * safeAlpha),
                        adjustAlpha(blendColors(theme.primaryEnd, depthColor, 0.26f), 0.34f * safeAlpha),
                    ),
                    floatArrayOf(0f, 0.24f, 0.62f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        if (performanceMode != "low") {
            canvas.save()
            canvas.clipPath(ribbonPath)
            val causticTravel = ((presentationTimeUs / 1000L) % 2400L).toFloat() / 2400f
            repeat(3) { index ->
                val bandShift = (index * 0.18f) + causticTravel
                val path = Path().apply {
                    val startY = lerp(
                        originY + (travel * (0.08f + (index * 0.11f))),
                        destinationY - (travel * 0.12f),
                        bandShift.coerceIn(0f, 1f),
                    )
                    moveTo(originX - (streamWidth * 0.56f), startY)
                    cubicTo(
                        originX - (streamWidth * 0.14f),
                        startY - (streamWidth * 0.18f),
                        destinationX - (streamWidth * 0.30f),
                        startY + (travel * 0.06f),
                        destinationX + (streamWidth * 0.14f),
                        startY + (travel * 0.13f),
                    )
                }
                canvas.drawPath(
                    path,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(causticColor, (0.14f - (index * 0.025f)) * safeAlpha)
                        style = Paint.Style.STROKE
                        strokeWidth = max(1f, (1.35f - (index * 0.18f)) * scale)
                    },
                )
            }
            canvas.restore()
        }

        canvas.drawPath(
            ribbonPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.3f * scale)
                shader = LinearGradient(
                    originX - (streamWidth * 0.18f),
                    originY,
                    destinationX,
                    destinationY,
                    intArrayOf(
                        adjustAlpha(causticColor, 0.52f * safeAlpha),
                        adjustAlpha(refractedColor, 0.30f * safeAlpha),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.40f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        canvas.drawCircle(
            destinationX,
            destinationY + (frontRadius * 0.08f),
            frontRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.glowColor, 0.20f * safeAlpha)
                maskFilter = BlurMaskFilter(14f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawCircle(
            destinationX,
            destinationY,
            frontRadius * 0.92f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    destinationX - (frontRadius * 0.24f),
                    destinationY - (frontRadius * 0.30f),
                    frontRadius,
                    intArrayOf(
                        adjustAlpha(causticColor, 0.92f * safeAlpha),
                        adjustAlpha(refractedColor, 0.68f * safeAlpha),
                        adjustAlpha(blendColors(theme.accent1, depthColor, 0.46f), 0.36f * safeAlpha),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.22f, 0.66f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        if (performanceMode != "low") {
            repeat(4) { index ->
                val drift = ((presentationTimeUs / 1000L) % 1800L).toFloat() / 1800f
                val angle = (index * 0.86f) + (drift * 1.5f)
                val dropletX =
                    destinationX + (kotlin.math.cos(angle.toDouble()).toFloat() * frontRadius * (0.54f + (index * 0.10f)))
                val dropletY =
                    destinationY + (kotlin.math.sin(angle.toDouble()).toFloat() * frontRadius * (0.22f + (index * 0.11f))) + (index * 2.1f * scale)
                val dropletRadius = (2.0f + (index * 0.7f)) * scale
                canvas.drawCircle(
                    dropletX,
                    dropletY,
                    dropletRadius * 1.7f,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.glowColor, 0.10f * safeAlpha)
                        maskFilter = BlurMaskFilter(6f * scale, BlurMaskFilter.Blur.NORMAL)
                    },
                )
                canvas.drawCircle(
                    dropletX,
                    dropletY,
                    dropletRadius,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = RadialGradient(
                            dropletX - (dropletRadius * 0.35f),
                            dropletY - (dropletRadius * 0.35f),
                            dropletRadius,
                            intArrayOf(
                                adjustAlpha(causticColor, 0.78f * safeAlpha),
                                adjustAlpha(refractedColor, 0.42f * safeAlpha),
                                Color.TRANSPARENT,
                            ),
                            floatArrayOf(0f, 0.42f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
            }
        }
    }

    private fun drawWorldFestivalRepCounter(
    canvas: Canvas,
    rect: RectF,
    repCount: Int,
    phase: String,
    scale: Float,
    theme: WorldFestivalTheme,
    performanceMode: String,
    presentationTimeUs: Long,
) {
    val centerX = rect.centerX()
    val centerY = rect.centerY()
    val radius = rect.width() / 2f
    val equipmentIndex = worldFestivalEquipmentIndex(theme.storageKey)
    val phaseColor = phaseColorForFestival(theme, phase)
    val surfaceDepth = visualConfig.customOverlay.repCounter.surfaceDepth.coerceIn(0f, 1f)
    val orbitIntensity = visualConfig.customOverlay.repCounter.orbitIntensity.coerceIn(0f, 1f)
    val pulse = ((sin(presentationTimeUs / 360000.0) + 1.0) / 2.0).toFloat()
    val ringWidth = max(7f * scale, rect.width() * 0.082f)
    val vividAccent1 = intensifyColor(theme.accent1, 0.18f)
    val vividAccent2 = intensifyColor(theme.accent2, 0.12f)
    val vividGlow = intensifyColor(theme.glowColor, 0.18f)

    canvas.drawCircle(
        centerX,
        centerY,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(vividGlow, if (performanceMode == "low") 0.14f else 0.24f + (0.08f * pulse))
            style = Paint.Style.STROKE
            strokeWidth = ringWidth + (6f * scale)
            maskFilter = BlurMaskFilter(14f * scale, BlurMaskFilter.Blur.NORMAL)
        },
    )

    val shellRadius = radius - ringWidth - (4f * scale)
    canvas.drawCircle(
        centerX,
        centerY,
        shellRadius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                centerX,
                centerY,
                shellRadius,
                intArrayOf(
                    adjustAlpha(blendColors(vividAccent2, theme.primaryEnd, 0.16f + (0.14f * surfaceDepth)), 1f),
                    adjustAlpha(blendColors(theme.primaryStart, theme.primaryEnd, 0.24f), 0.98f),
                    adjustAlpha(blendColors(theme.primaryStart, Color.BLACK, 0.12f + (0.10f * surfaceDepth)), 0.98f),
                ),
                floatArrayOf(0f, 0.58f + (surfaceDepth * 0.10f), 1f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawCircle(
        centerX - (shellRadius * 0.18f),
        centerY - (shellRadius * 0.22f),
        shellRadius * 0.78f,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                centerX - (shellRadius * 0.18f),
                centerY - (shellRadius * 0.22f),
                shellRadius * 0.84f,
                intArrayOf(
                    Color.argb(82, 255, 255, 255),
                    Color.argb(26, 255, 248, 234),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.24f, 1f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    if (equipmentIndex >= 0) {
        drawWorldFestivalEquipmentCoreStatic(
            canvas = canvas,
            rect = RectF(
                centerX - (shellRadius * 0.70f),
                centerY - (shellRadius * 0.62f),
                centerX + (shellRadius * 0.70f),
                centerY + (shellRadius * 0.62f),
            ),
            theme = theme,
            scale = scale,
            equipmentIndex = equipmentIndex,
        )
        drawWorldFestivalEquipmentCoreDynamic(
            canvas = canvas,
            rect = RectF(
                centerX - (shellRadius * 0.70f),
                centerY - (shellRadius * 0.62f),
                centerX + (shellRadius * 0.70f),
                centerY + (shellRadius * 0.62f),
            ),
            phaseColor = phaseColor,
            pulse = pulse,
            scale = scale,
            equipmentIndex = equipmentIndex,
        )
    }

    if (theme.variantId % 2 == 0) {
        canvas.drawCircle(
            centerX,
            centerY,
            radius - (ringWidth / 2f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                strokeCap = Paint.Cap.ROUND
                strokeWidth = ringWidth
                shader = SweepGradient(
                    centerX,
                    centerY,
                    (theme.ringGradient + theme.ringGradient.first()).toIntArray(),
                    null,
                )
            },
        )
    } else {
        canvas.drawArc(
            RectF(
                rect.left + (ringWidth / 2f),
                rect.top + (ringWidth / 2f),
                rect.right - (ringWidth / 2f),
                rect.bottom - (ringWidth / 2f),
            ),
            216f,
            292f,
            false,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                strokeCap = Paint.Cap.ROUND
                strokeWidth = ringWidth
                shader = SweepGradient(
                    centerX,
                    centerY,
                    (theme.ringGradient + theme.ringGradient.first()).toIntArray(),
                    null,
                )
            },
        )
    }

    canvas.drawCircle(
        centerX,
        centerY,
        radius - ringWidth - (2f * scale),
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(vividAccent2, 0.12f + (0.14f * surfaceDepth))
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 0.9f * scale)
        },
    )
    canvas.drawArc(
        RectF(
            centerX - (radius - (ringWidth * 0.55f)),
            centerY - (radius - (ringWidth * 0.55f)),
            centerX + (radius - (ringWidth * 0.55f)),
            centerY + (radius - (ringWidth * 0.55f)),
        ),
        206f,
        96f,
        false,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeCap = Paint.Cap.ROUND
            strokeWidth = max(1f, 1.2f * scale)
            color = Color.argb(76, 255, 248, 236)
        },
    )

    if (theme.watermarkIcon.isNotBlank()) {
        if (isPadaukBranchIcon(theme.watermarkIcon)) {
            drawPadaukBranch(
                canvas = canvas,
                rect = RectF(
                    centerX - (rect.width() * 0.20f),
                    centerY - (rect.height() * 0.02f),
                    centerX + (rect.width() * 0.18f),
                    centerY + (rect.height() * 0.28f),
                ),
                alpha = 0.28f,
            )
        } else {
            drawCenteredText(
                canvas = canvas,
                text = theme.watermarkIcon,
                centerX = centerX,
                centerY = centerY + (2f * scale),
                paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(vividAccent2, 0.20f)
                    textAlign = Paint.Align.CENTER
                    textSize = max(28f, rect.width() * 0.30f)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                },
            )
        }
    }

    if (performanceMode != "low") {
        val orbitPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(vividAccent1, 0.18f + (0.20f * orbitIntensity))
        }
        val orbitRadius = (radius - (ringWidth * 0.7f)) * (0.82f + (0.10f * orbitIntensity))
        canvas.drawCircle(
            centerX,
            centerY,
            orbitRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividAccent2, 0.08f + (0.14f * orbitIntensity))
                style = Paint.Style.STROKE
                strokeWidth = max(1f, (0.7f + orbitIntensity) * scale)
            },
        )
        repeat(3) { index ->
            val angle = ((presentationTimeUs / 180000.0) + index * 2.1).toFloat()
            val x = centerX + (kotlin.math.cos(angle.toDouble()).toFloat() * orbitRadius * 0.88f)
            val y = centerY + (sin(angle.toDouble()).toFloat() * orbitRadius * 0.88f)
            canvas.drawCircle(x, y, (1.2f + (orbitIntensity * 2.2f) + index) * scale, orbitPaint)
        }
    }

    if (equipmentIndex < 0 && isPadaukBranchIcon(theme.bannerIcon)) {
        drawPadaukBranch(
            canvas = canvas,
            rect = RectF(
                centerX - (rect.width() * 0.13f),
                centerY - (rect.width() * 0.35f),
                centerX + (rect.width() * 0.12f),
                centerY - (rect.width() * 0.09f),
            ),
            alpha = 0.98f,
        )
    } else if (equipmentIndex < 0) {
        drawCenteredText(
            canvas = canvas,
            text = theme.bannerIcon.ifBlank { "✦" },
            centerX = centerX,
            centerY = centerY - (rect.width() * 0.22f),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(vividAccent1, 0.98f)
                textAlign = Paint.Align.CENTER
                textSize = max(16f, rect.width() * 0.18f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                setShadowLayer(3f * scale, 0f, 1.4f * scale, adjustAlpha(Color.BLACK, 0.28f))
            },
        )
    }
    drawCenteredText(
        canvas = canvas,
        text = repCount.toString(),
        centerX = centerX,
        centerY = centerY - (if (equipmentIndex >= 0) 0f else (rect.width() * 0.02f)),
        paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = vividAccent2
            textAlign = Paint.Align.CENTER
            textSize = max(30f, rect.width() * if (equipmentIndex >= 0) 0.30f else 0.34f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            setShadowLayer(4f * scale, 0f, 1.8f * scale, adjustAlpha(Color.BLACK, 0.34f))
        },
    )
    drawCenteredText(
        canvas = canvas,
        text = phase.uppercase(Locale.US),
        centerX = centerX,
        centerY = centerY + (rect.width() * 0.20f),
        paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = phaseColor
            textAlign = Paint.Align.CENTER
            textSize = max(11f, rect.width() * 0.10f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        },
    )
    drawCenteredText(
        canvas = canvas,
        text = "REPS",
        centerX = centerX,
        centerY = centerY + (rect.width() * 0.34f),
        paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(vividAccent2, 0.84f)
            textAlign = Paint.Align.CENTER
            textSize = max(10f, rect.width() * 0.08f)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        },
    )
}

    private fun drawWorldFestivalSignaturePill(
        canvas: Canvas,
        rect: RectF,
        scale: Float,
        theme: WorldFestivalTheme,
    ) {
        val radius = rect.height() / 2f
        // Removed the background gradient box and stroke border per user request.
        val label = if (theme.cornerIcon.isNotBlank() && !isPadaukBranchIcon(theme.cornerIcon)) {
            theme.cornerIcon
        } else {
            ""
        }
        if (isPadaukBranchIcon(theme.cornerIcon)) {
            drawPadaukBranch(
                canvas = canvas,
                rect = RectF(
                    rect.left + (8f * scale),
                    rect.top + (4f * scale),
                    rect.left + (26f * scale),
                    rect.bottom - (4f * scale),
                ),
                alpha = 0.94f,
            )
        }
        drawCenteredText(
            canvas = canvas,
            text = label,
            centerX = if (isPadaukBranchIcon(theme.cornerIcon)) rect.centerX() + (8f * scale) else rect.centerX(),
            centerY = rect.centerY(),
            paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent2, 0.88f)
                textAlign = Paint.Align.CENTER
                textSize = max(10f, rect.height() * 0.34f)
                typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            },
        )
    }

    private fun buildWorldFestivalBarPath(rect: RectF, variantId: Int, inset: Float): Path {
        val left = rect.left + inset
        val top = rect.top + inset
        val right = rect.right - inset
        val bottom = rect.bottom - inset
        if (right <= left || bottom <= top) return Path()

        val safe = RectF(left, top, right, bottom)
        val family = variantId % 10
        val w = safe.width()
        val h = safe.height()
        val cx = safe.centerX()
        val cy = safe.centerY()
        val path = Path()

        when (family) {
            0 -> {
                val wave = h * 0.12f
                val radius = h * 0.36f
                path.moveTo(safe.left + radius, safe.top + wave)
                path.quadTo(safe.left, cy, safe.left + (radius * 0.4f), safe.bottom - wave)
                path.cubicTo(safe.left + (w * 0.24f), safe.bottom + (wave * 0.85f), safe.left + (w * 0.52f), safe.bottom - (wave * 0.25f), safe.right - (w * 0.18f), safe.bottom - wave)
                path.quadTo(safe.right, cy, safe.right - radius, safe.top + wave)
                path.cubicTo(safe.left + (w * 0.68f), safe.top - (wave * 0.55f), safe.left + (w * 0.34f), safe.top + (wave * 0.10f), safe.left + radius, safe.top + wave)
            }
            1, 3 -> {
                val bevel = h * 0.52f
                path.moveTo(safe.left + bevel, safe.top)
                path.lineTo(safe.right - bevel, safe.top)
                path.lineTo(safe.right, cy)
                path.lineTo(safe.right - bevel, safe.bottom)
                path.lineTo(safe.left + bevel, safe.bottom)
                path.lineTo(safe.left, cy)
            }
            2 -> {
                val pinch = h * 0.18f
                val bulb = h * 0.34f
                path.moveTo(safe.left + bulb, safe.top + pinch)
                path.quadTo(safe.left - (bulb * 0.2f), safe.top + (h * 0.22f), safe.left + (bulb * 0.18f), cy)
                path.quadTo(safe.left - (bulb * 0.2f), safe.bottom - (h * 0.22f), safe.left + bulb, safe.bottom - pinch)
                path.cubicTo(safe.left + (w * 0.34f), safe.bottom, safe.left + (w * 0.46f), safe.bottom - (pinch * 0.2f), safe.right - bulb, safe.bottom - pinch)
                path.quadTo(safe.right + (bulb * 0.2f), safe.bottom - (h * 0.22f), safe.right - (bulb * 0.18f), cy)
                path.quadTo(safe.right + (bulb * 0.2f), safe.top + (h * 0.22f), safe.right - bulb, safe.top + pinch)
                path.cubicTo(safe.left + (w * 0.46f), safe.top + (pinch * 0.2f), safe.left + (w * 0.34f), safe.top, safe.left + bulb, safe.top + pinch)
            }
            4 -> {
                val peak = h * 0.22f
                val radius = h * 0.28f
                path.moveTo(safe.left + radius, safe.top + peak)
                path.quadTo(safe.left + (w * 0.16f), safe.top - peak, safe.left + (w * 0.28f), safe.top + (peak * 0.65f))
                path.quadTo(safe.left + (w * 0.42f), safe.top - (peak * 1.15f), cx, safe.top + peak)
                path.quadTo(safe.left + (w * 0.58f), safe.top - (peak * 1.15f), safe.left + (w * 0.72f), safe.top + (peak * 0.65f))
                path.quadTo(safe.left + (w * 0.84f), safe.top - peak, safe.right - radius, safe.top + peak)
                path.quadTo(safe.right, cy, safe.right - radius, safe.bottom - peak)
                path.lineTo(safe.left + radius, safe.bottom - peak)
                path.quadTo(safe.left, cy, safe.left + radius, safe.top + peak)
            }
            5 -> {
                path.moveTo(safe.left + (h * 0.42f), safe.top + (h * 0.10f))
                path.cubicTo(safe.left, safe.top + (h * 0.22f), safe.left, safe.bottom - (h * 0.22f), safe.left + (h * 0.42f), safe.bottom - (h * 0.10f))
                path.cubicTo(safe.left + (w * 0.36f), safe.bottom + (h * 0.10f), safe.left + (w * 0.62f), safe.bottom + (h * 0.10f), safe.right - (h * 0.42f), safe.bottom - (h * 0.10f))
                path.cubicTo(safe.right, safe.bottom - (h * 0.22f), safe.right, safe.top + (h * 0.22f), safe.right - (h * 0.42f), safe.top + (h * 0.10f))
                path.cubicTo(safe.left + (w * 0.62f), safe.top - (h * 0.10f), safe.left + (w * 0.36f), safe.top - (h * 0.10f), safe.left + (h * 0.42f), safe.top + (h * 0.10f))
            }
            6 -> {
                val crest = h * 0.18f
                path.moveTo(safe.left + (h * 0.36f), safe.top + crest)
                path.quadTo(safe.left + (w * 0.18f), safe.top - (crest * 0.1f), safe.left + (w * 0.34f), safe.top + (crest * 0.55f))
                path.quadTo(safe.left + (w * 0.54f), safe.top - (crest * 0.45f), safe.left + (w * 0.74f), safe.top + (crest * 0.4f))
                path.quadTo(safe.right, cy, safe.right - (h * 0.30f), safe.bottom - crest)
                path.quadTo(safe.left + (w * 0.68f), safe.bottom + (crest * 0.55f), safe.left + (w * 0.44f), safe.bottom - (crest * 0.12f))
                path.quadTo(safe.left + (w * 0.20f), safe.bottom + (crest * 0.35f), safe.left + (h * 0.28f), safe.bottom - crest)
                path.quadTo(safe.left, cy, safe.left + (h * 0.36f), safe.top + crest)
            }
            7 -> {
                val tail = h * 0.62f
                val r = h * 0.44f
                path.addRoundRect(
                    RectF(safe.left, safe.top, safe.right - tail, safe.bottom),
                    floatArrayOf(r, r, h * 0.22f, h * 0.22f, h * 0.22f, h * 0.22f, r, r),
                    Path.Direction.CW,
                )
                path.moveTo(safe.right - tail, safe.top)
                path.lineTo(safe.right, cy)
                path.lineTo(safe.right - tail, safe.bottom)
            }
            8 -> {
                val carve = h * 0.16f
                path.moveTo(safe.left + (h * 0.42f), safe.top)
                path.lineTo(safe.right - (h * 0.42f), safe.top)
                path.quadTo(safe.right, safe.top, safe.right, cy - carve)
                path.quadTo(safe.right - (w * 0.06f), cy, safe.right, cy + carve)
                path.quadTo(safe.right, safe.bottom, safe.right - (h * 0.42f), safe.bottom)
                path.lineTo(safe.left + (h * 0.42f), safe.bottom)
                path.quadTo(safe.left, safe.bottom, safe.left, cy + carve)
                path.quadTo(safe.left + (w * 0.06f), cy, safe.left, cy - carve)
                path.quadTo(safe.left, safe.top, safe.left + (h * 0.42f), safe.top)
            }
            else -> {
                val radius = h * 0.34f
                val bite = h * 0.18f
                path.moveTo(safe.left + radius, safe.top + bite)
                path.cubicTo(safe.left + (w * 0.22f), safe.top - bite, safe.left + (w * 0.42f), safe.top + bite, cx, safe.top + (bite * 0.1f))
                path.cubicTo(safe.left + (w * 0.64f), safe.top - bite, safe.left + (w * 0.82f), safe.top + bite, safe.right - radius, safe.top + bite)
                path.quadTo(safe.right, cy, safe.right - radius, safe.bottom - bite)
                path.cubicTo(safe.left + (w * 0.82f), safe.bottom + bite, safe.left + (w * 0.64f), safe.bottom - bite, cx, safe.bottom - (bite * 0.1f))
                path.cubicTo(safe.left + (w * 0.42f), safe.bottom + bite, safe.left + (w * 0.22f), safe.bottom - bite, safe.left + radius, safe.bottom - bite)
                path.quadTo(safe.left, cy, safe.left + radius, safe.top + bite)
            }
        }

        path.close()
        return path
    }

    private fun buildWorldFestivalLiquidPath(rect: RectF, progress: Float, variantId: Int, flowPhase: Float): Path {
        val safeProgress = progress.coerceIn(0f, 1f)
        if (safeProgress <= 0f) return Path()

        val fillWidth = max(rect.height() * 0.36f, rect.width() * safeProgress)
        val fillRight = min(rect.right, rect.left + fillWidth)
        val family = variantId % 10
        val wave = rect.height() * (0.10f + ((family % 4) * 0.018f))
        val bulge = rect.height() * (0.18f + ((family % 3) * 0.035f))
        val phase = sin(flowPhase * Math.PI * 2.0).toFloat() * wave * 0.45f

        return Path().apply {
            moveTo(rect.left, rect.top)
            lineTo(fillRight - (bulge * 1.35f), rect.top)
            cubicTo(fillRight - (bulge * 0.35f), rect.top + (wave * 0.12f), fillRight + (bulge * 0.30f), rect.centerY() - wave - phase, fillRight - (bulge * 0.08f), rect.centerY())
            cubicTo(fillRight + (bulge * 0.30f), rect.centerY() + wave - phase, fillRight - (bulge * 0.35f), rect.bottom - (wave * 0.12f), fillRight - (bulge * 1.35f), rect.bottom)
            lineTo(rect.left, rect.bottom)
            close()
        }
    }

    private fun buildWorldFestivalSpillPath(
        originX: Float,
        originY: Float,
        screenHeight: Float,
        variantId: Int,
        intensity: Float,
        flowPhase: Float,
        widthFactor: Float = 1f,
    ): Path {
        val family = variantId % 10
        val ornament = variantId / 10
        val reach = screenHeight * (0.18f + ((0.30f + (ornament * 0.05f)) * intensity))
        val sway = (screenHeight * 0.012f) + (family * 0.8f)
        val ripple = sin(flowPhase * Math.PI * 2.0).toFloat() * sway
        val bottomY = min(screenHeight * 0.74f, originY + reach)
        val waistX = originX + ripple
        val lowerX = originX - (ripple * 0.55f)
        val streamHalf = (10f + (18f * intensity)) * widthFactor.coerceIn(0.6f, 1.8f)

        return Path().apply {
            moveTo(originX - (streamHalf * 0.42f), originY)
            cubicTo(originX - streamHalf, originY + (reach * 0.12f), waistX - (streamHalf * 0.55f), originY + (reach * 0.36f), waistX, originY + (reach * 0.52f))
            cubicTo(lowerX + (streamHalf * 0.45f), originY + (reach * 0.70f), lowerX + (streamHalf * 0.22f), bottomY - (reach * 0.10f), lowerX + (streamHalf * 0.12f), bottomY)
            cubicTo(lowerX - (streamHalf * 0.24f), bottomY - (reach * 0.08f), lowerX - (streamHalf * 0.82f), originY + (reach * 0.70f), waistX - (streamHalf * 0.62f), originY + (reach * 0.52f))
            cubicTo(waistX - (streamHalf * 1.02f), originY + (reach * 0.34f), originX - (streamHalf * 0.58f), originY + (reach * 0.12f), originX - (streamHalf * 0.42f), originY)
            close()
        }
    }

    private fun slotPositionY(position: String, top: Float, center: Float, bottom: Float): Float {
        return when (position) {
            "center" -> center
            "bottom" -> bottom
            else -> top
        }
    }

    private fun phaseColorForCustom(phase: String, palette: CustomOverlayPalette): Int {
        return when (phase) {
            "up" -> palette.phaseUp
            "down" -> palette.phaseDown
            "hold" -> palette.phaseHold
            else -> palette.accent
        }
    }

    private fun phaseColorForFestival(theme: WorldFestivalTheme, phase: String): Int {
        return when (phase) {
            "up" -> theme.phaseUpColor
            "down" -> theme.phaseDownColor
            "hold" -> theme.phaseHoldColor
            else -> theme.accent1
        }
    }

    private fun accuracyColorForFestival(theme: WorldFestivalTheme, accuracy: Float): Int {
        return when {
            accuracy >= 0.8f -> theme.accuracyHighColor
            accuracy >= 0.6f -> theme.accuracyMidColor
            else -> theme.accuracyLowColor
        }
    }

    private fun iconSlotForState(phase: String, icons: CustomOverlayIcons): CustomOverlayIconSlot {
        if (!icons.autoSwitch) {
            return icons.defaultIcon
        }
        return when (phase) {
            "up" -> icons.upIcon
            "down" -> icons.downIcon
            "hold" -> icons.holdIcon
            else -> icons.defaultIcon
        }
    }

    private fun drawSvgIcon(
        canvas: Canvas,
        svgPath: String?,
        rect: RectF,
        clipAsOval: Boolean = false,
    ): Boolean {
        val picture = loadSvgPicture(svgPath) ?: return false
        val pictureWidth = max(1, picture.width).toFloat()
        val pictureHeight = max(1, picture.height).toFloat()
        val scale = min(rect.width() / pictureWidth, rect.height() / pictureHeight)
        if (!scale.isFinite() || scale <= 0f) {
            return false
        }

        val drawnWidth = pictureWidth * scale
        val drawnHeight = pictureHeight * scale
        val left = rect.left + ((rect.width() - drawnWidth) / 2f)
        val top = rect.top + ((rect.height() - drawnHeight) / 2f)

        canvas.save()
        val clipPath = Path().apply {
            if (clipAsOval) {
                addOval(rect, Path.Direction.CW)
            } else {
                addRoundRect(
                    rect,
                    rect.width() * 0.18f,
                    rect.height() * 0.18f,
                    Path.Direction.CW,
                )
            }
        }
        canvas.clipPath(clipPath)
        canvas.translate(left, top)
        canvas.scale(scale, scale)
        canvas.drawPicture(picture)
        canvas.restore()
        return true
    }

    private fun loadSvgPicture(svgPath: String?): Picture? {
        val path = svgPath?.trim()?.takeIf { it.isNotEmpty() } ?: return null
        return svgPictureCache.getOrPut(path) {
            val file = File(path)
            if (!file.exists()) {
                return@getOrPut null
            }
            runCatching {
                val svg = SVG.getFromString(file.readText())
                val width = svg.documentWidth.takeIf { it > 0f }?.roundToInt() ?: 512
                val height = svg.documentHeight.takeIf { it > 0f }?.roundToInt() ?: 512
                svg.renderToPicture(max(64, width), max(64, height))
            }.getOrNull()
        }
    }

    private fun drawZodiacOverlay(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        state: OverlayState,
        presentationTimeUs: Long,
    ) {
        val theme = zodiacThemeFor(visualConfig.zodiacSignKey)
        val sideInset = 18f * scale
        val visualDrop = 28f * scale
        val titleTop = 34f * scale + visualDrop
        val coinSize = 92f * scale * coinScaleFor(theme.signKey)
        val gap = 14f * scale
        val barHeight = 28f * scale * barHeightScaleFor(theme.signKey)
        val barTop = titleTop + (34f * scale)
        val barWidth = width - (sideInset * 2f) - coinSize - gap
        val title = theme.signLabel
        val pulse = ((sin(presentationTimeUs / 320000.0) + 1.0) / 2.0).toFloat()
        drawSceneTintTreatment(canvas, width, height, scale, theme, pulse)
        drawSignBackdropMotif(
            canvas = canvas,
            width = width,
            height = height,
            scale = scale,
            theme = theme,
            pulse = pulse,
            presentationTimeUs = presentationTimeUs,
        )

        val ambientRect = RectF(
            width - (coinSize * 1.65f),
            8f * scale,
            width - sideInset + (coinSize * 0.2f),
            8f * scale + (coinSize * 1.6f),
        )
        val ambientPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                ambientRect.centerX(),
                ambientRect.centerY(),
                ambientRect.width() * 0.5f,
                intArrayOf(
                    adjustAlpha(theme.glowColor, 0.24f + (0.16f * pulse)),
                    adjustAlpha(theme.glowColor, 0.08f),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.52f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawOval(ambientRect, ambientPaint)

        val titlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                sideInset,
                0f,
                sideInset + (width * 0.46f),
                0f,
                intArrayOf(
                    theme.titleStartColor,
                    blendColors(theme.titleStartColor, theme.titleEndColor, 0.44f),
                    theme.titleEndColor,
                ),
                null,
                Shader.TileMode.CLAMP,
            )
            textAlign = Paint.Align.LEFT
            typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
            textSize = max(18f, 18f * scale)
            setShadowLayer(4f * scale, 0f, 2f * scale, Color.argb(96, 0, 0, 0))
        }
        val titleMetrics = titlePaint.fontMetrics
        val titleBaseline = titleTop - titleMetrics.ascent
        val titleRect = RectF(
            sideInset - (10f * scale),
            titleTop - (10f * scale),
            min(width - sideInset, sideInset + titlePaint.measureText(title) + (44f * scale)),
            titleBaseline + titleMetrics.descent + (10f * scale),
        )
        if (theme.signKey == "leo") {
            drawLeoSkyHeader(
                canvas = canvas,
                rect = RectF(
                    sideInset,
                    titleTop - (8f * scale),
                    sideInset + barWidth,
                    barTop - (8f * scale),
                ),
                theme = theme,
                scale = scale,
                pulse = pulse,
                presentationTimeUs = presentationTimeUs,
            )
        } else {
            drawZodiacTitleCartouche(
                canvas = canvas,
                rect = titleRect,
                theme = theme,
                scale = scale,
                pulse = pulse,
                presentationTimeUs = presentationTimeUs,
            )
            canvas.drawText(
                title,
                sideInset + (2f * scale),
                titleBaseline,
                titlePaint,
            )
            drawTitleFlourishes(canvas, sideInset, titleTop + (9f * scale), title, titlePaint, scale, theme)
        }

        val barRect = RectF(
            sideInset,
            barTop,
            sideInset + barWidth,
            barTop + barHeight,
        )
        if (visualConfig.customOverlay.accuracyBar.show) {
            drawZodiacAccuracyBar(
                canvas = canvas,
                rect = barRect,
                accuracy = state.accuracy,
                scale = scale,
                presentationTimeUs = presentationTimeUs,
                theme = theme,
                screenHeight = height,
            )
            drawBarOrnaments(canvas, barRect, theme, scale)
        }

        val coinRect = RectF(
            barRect.right + gap,
            barTop - (coinSize * 0.12f),
            barRect.right + gap + coinSize,
            barTop - (coinSize * 0.12f) + coinSize,
        )
        if (visualConfig.customOverlay.repCounter.show) {
            drawZodiacRepCoin(
                canvas = canvas,
                rect = coinRect,
                repCount = state.repCount,
                scale = scale,
                pulse = pulse,
                presentationTimeUs = presentationTimeUs,
                theme = theme,
            )
            drawCoinAccent(canvas, coinRect, theme, scale)
        }

        val sparklePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.44f)
            style = Paint.Style.FILL
        }
        repeat(6) { index ->
            val x = sideInset + ((index + 1) * (barWidth / 7f))
            val y = barTop - (6f * scale) - ((index % 2) * 4f * scale)
            canvas.drawCircle(x, y, if (index % 2 == 0) 1.4f * scale else 1.0f * scale, sparklePaint)
        }
    }

    private fun drawSceneTintTreatment(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        theme: ZodiacTheme,
        pulse: Float,
    ) {
        val topGradient = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f,
                0f,
                0f,
                height * 0.55f,
                intArrayOf(
                    theme.sceneTintTopColor,
                    adjustAlpha(theme.sceneTintBottomColor, 0.44f),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.48f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, width, height, topGradient)

        val beamPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                width * 0.15f,
                0f,
                width * 0.68f,
                height,
                intArrayOf(
                    Color.TRANSPARENT,
                    adjustAlpha(theme.beamColor, 0.30f + (0.12f * pulse)),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.46f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.save()
        canvas.rotate(-18f, width * 0.5f, height * 0.34f)
        canvas.drawRect(width * 0.22f, -8f * scale, width * 0.44f, height * 0.72f, beamPaint)
        canvas.restore()
    }

    private fun drawSignBackdropMotif(
        canvas: Canvas,
        width: Float,
        height: Float,
        scale: Float,
        theme: ZodiacTheme,
        pulse: Float,
        presentationTimeUs: Long,
    ) {
        val shimmer = ((sin(presentationTimeUs / 430000.0) + 1.0) / 2.0).toFloat()
        val accentStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.14f + (0.08f * shimmer))
            style = Paint.Style.STROKE
            strokeWidth = max(1f, 1.15f * scale)
        }
        val accentFill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.glowColor, 0.05f + (0.07f * pulse))
            style = Paint.Style.FILL
        }

        when (theme.signKey) {
            "aries" -> {
                val leftHorn = Path().apply {
                    moveTo(width * 0.08f, height * 0.20f)
                    cubicTo(width * 0.18f, height * 0.10f, width * 0.26f, height * 0.23f, width * 0.30f, height * 0.16f)
                }
                val rightHorn = Path().apply {
                    moveTo(width * 0.54f, height * 0.14f)
                    cubicTo(width * 0.62f, height * 0.07f, width * 0.74f, height * 0.16f, width * 0.82f, height * 0.10f)
                }
                canvas.drawPath(leftHorn, accentStroke)
                canvas.drawPath(rightHorn, accentStroke)
            }
            "taurus" -> {
                canvas.drawOval(
                    RectF(width * 0.08f, height * 0.10f, width * 0.28f, height * 0.23f),
                    accentStroke,
                )
                canvas.drawArc(
                    RectF(width * 0.06f, height * 0.04f, width * 0.18f, height * 0.17f),
                    320f,
                    150f,
                    false,
                    accentStroke,
                )
                canvas.drawArc(
                    RectF(width * 0.18f, height * 0.04f, width * 0.30f, height * 0.17f),
                    70f,
                    150f,
                    false,
                    accentStroke,
                )
            }
            "gemini" -> {
                val left = RectF(width * 0.08f, height * 0.08f, width * 0.12f, height * 0.24f)
                val right = RectF(width * 0.18f, height * 0.08f, width * 0.22f, height * 0.24f)
                canvas.drawRoundRect(left, 8f * scale, 8f * scale, accentFill)
                canvas.drawRoundRect(right, 8f * scale, 8f * scale, accentFill)
                canvas.drawLine(left.centerX(), left.top, right.centerX(), right.top, accentStroke)
                canvas.drawLine(left.centerX(), left.bottom, right.centerX(), right.bottom, accentStroke)
            }
            "cancer" -> {
                canvas.drawArc(
                    RectF(width * 0.06f, height * 0.08f, width * 0.22f, height * 0.22f),
                    25f,
                    300f,
                    false,
                    accentStroke,
                )
                canvas.drawArc(
                    RectF(width * 0.18f, height * 0.11f, width * 0.34f, height * 0.25f),
                    205f,
                    300f,
                    false,
                    accentStroke,
                )
            }
            "leo" -> {
                val cx = width * 0.18f
                val cy = height * 0.16f
                repeat(7) { index ->
                    val angle = Math.toRadians((-120 + (index * 22)).toDouble())
                    canvas.drawLine(
                        cx + (kotlin.math.cos(angle).toFloat() * (18f * scale)),
                        cy + (kotlin.math.sin(angle).toFloat() * (18f * scale)),
                        cx + (kotlin.math.cos(angle).toFloat() * (34f * scale)),
                        cy + (kotlin.math.sin(angle).toFloat() * (34f * scale)),
                        accentStroke,
                    )
                }
                canvas.drawCircle(cx, cy, 10f * scale, accentFill)
            }
            "virgo" -> {
                val path = Path().apply {
                    moveTo(width * 0.09f, height * 0.10f)
                    cubicTo(width * 0.16f, height * 0.08f, width * 0.18f, height * 0.22f, width * 0.26f, height * 0.18f)
                    cubicTo(width * 0.22f, height * 0.17f, width * 0.20f, height * 0.26f, width * 0.28f, height * 0.24f)
                }
                canvas.drawPath(path, accentStroke)
            }
            "libra" -> {
                canvas.drawLine(width * 0.08f, height * 0.18f, width * 0.30f, height * 0.18f, accentStroke)
                canvas.drawArc(
                    RectF(width * 0.12f, height * 0.10f, width * 0.26f, height * 0.18f),
                    180f,
                    180f,
                    false,
                    accentStroke,
                )
            }
            "scorpio" -> {
                val path = Path().apply {
                    moveTo(width * 0.08f, height * 0.09f)
                    lineTo(width * 0.08f, height * 0.22f)
                    cubicTo(width * 0.16f, height * 0.18f, width * 0.22f, height * 0.18f, width * 0.28f, height * 0.12f)
                    lineTo(width * 0.32f, height * 0.08f)
                }
                canvas.drawPath(path, accentStroke)
            }
            "sagittarius" -> {
                canvas.drawLine(width * 0.08f, height * 0.22f, width * 0.26f, height * 0.10f, accentStroke)
                canvas.drawLine(width * 0.20f, height * 0.10f, width * 0.26f, height * 0.10f, accentStroke)
                canvas.drawLine(width * 0.26f, height * 0.10f, width * 0.26f, height * 0.16f, accentStroke)
            }
            "capricorn" -> {
                val ridge = Path().apply {
                    moveTo(width * 0.08f, height * 0.22f)
                    lineTo(width * 0.14f, height * 0.12f)
                    lineTo(width * 0.20f, height * 0.20f)
                    lineTo(width * 0.27f, height * 0.09f)
                    lineTo(width * 0.33f, height * 0.19f)
                }
                canvas.drawPath(ridge, accentStroke)
            }
            "aquarius" -> {
                repeat(2) { row ->
                    val y = height * (0.11f + (row * 0.05f))
                    val wave = Path().apply {
                        moveTo(width * 0.08f, y)
                        lineTo(width * 0.13f, y - (7f * scale))
                        lineTo(width * 0.18f, y)
                        lineTo(width * 0.23f, y - (7f * scale))
                        lineTo(width * 0.28f, y)
                        lineTo(width * 0.33f, y - (7f * scale))
                    }
                    canvas.drawPath(wave, accentStroke)
                }
            }
            "pisces" -> {
                canvas.drawArc(
                    RectF(width * 0.08f, height * 0.09f, width * 0.20f, height * 0.24f),
                    270f,
                    180f,
                    false,
                    accentStroke,
                )
                canvas.drawArc(
                    RectF(width * 0.20f, height * 0.09f, width * 0.32f, height * 0.24f),
                    90f,
                    180f,
                    false,
                    accentStroke,
                )
                canvas.drawLine(width * 0.20f, height * 0.11f, width * 0.20f, height * 0.23f, accentStroke)
            }
        }
    }

    private fun drawZodiacTitleCartouche(
    canvas: Canvas,
    rect: RectF,
    theme: ZodiacTheme,
    scale: Float,
    pulse: Float,
    presentationTimeUs: Long,
) {
    val radius = rect.height() * 0.42f
    val basePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        shader = LinearGradient(
            rect.left,
            rect.top,
            rect.right,
            rect.bottom,
            intArrayOf(
                adjustAlpha(theme.shellStartColor, 0.80f),
                adjustAlpha(theme.shellMidColor, 0.92f),
                adjustAlpha(theme.shellEndColor, 0.82f),
            ),
            floatArrayOf(0f, 0.58f, 1f),
            Shader.TileMode.CLAMP,
        )
    }
    val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.glowColor, 0.13f + (0.08f * pulse))
        maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
    }
    val outerStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.constellationColor, 0.42f)
        style = Paint.Style.STROKE
        strokeWidth = max(1f, 1.1f * scale)
    }
    val innerStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.rimTextColor, 0.55f)
        style = Paint.Style.STROKE
        strokeWidth = max(0.8f, 0.8f * scale)
    }

    canvas.drawRoundRect(RectF(rect).apply { offset(0f, 2f * scale) }, radius, radius, glowPaint)
    canvas.drawRoundRect(rect, radius, radius, basePaint)
    canvas.drawRoundRect(
        rect,
        radius,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.left,
                rect.bottom,
                intArrayOf(
                    Color.argb(82, 255, 255, 255),
                    Color.argb(24, 255, 247, 235),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.24f, 0.76f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawRoundRect(rect, radius, radius, outerStroke)
    canvas.drawRoundRect(
        RectF(rect.left + (2f * scale), rect.top + (2f * scale), rect.right - (2f * scale), rect.bottom - (2f * scale)),
        radius,
        radius,
        innerStroke,
    )
    val sideMedallionRadius = rect.height() * 0.18f
    listOf(rect.left + (26f * scale), rect.right - (26f * scale)).forEach { cx ->
        canvas.drawCircle(
            cx,
            rect.centerY(),
            sideMedallionRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    cx - (sideMedallionRadius * 0.18f),
                    rect.centerY() - (sideMedallionRadius * 0.22f),
                    sideMedallionRadius,
                    intArrayOf(
                        adjustAlpha(theme.titleStartColor, 0.74f),
                        adjustAlpha(theme.titleEndColor, 0.52f),
                        adjustAlpha(theme.shellEndColor, 0.36f),
                    ),
                    floatArrayOf(0f, 0.54f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawCircle(
            cx,
            rect.centerY(),
            sideMedallionRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.constellationColor, 0.24f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 0.9f * scale)
            },
        )
    }

    val ornamentPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.constellationColor, 0.46f + (0.08f * pulse))
        style = Paint.Style.STROKE
        strokeWidth = max(1f, 1.05f * scale)
    }
    when (theme.signKey) {
        "aries" -> {
            canvas.drawArc(RectF(rect.left - (14f * scale), rect.top - (4f * scale), rect.left + (16f * scale), rect.bottom - (2f * scale)), 305f, 122f, false, ornamentPaint)
            canvas.drawArc(RectF(rect.right - (16f * scale), rect.top - (4f * scale), rect.right + (14f * scale), rect.bottom - (2f * scale)), 112f, 122f, false, ornamentPaint)
        }
        "taurus" -> {
            canvas.drawCircle(rect.left + (14f * scale), rect.centerY(), 4.2f * scale, ornamentPaint)
            canvas.drawCircle(rect.right - (14f * scale), rect.centerY(), 4.2f * scale, ornamentPaint)
            canvas.drawArc(RectF(rect.left + (6f * scale), rect.top - (10f * scale), rect.left + (24f * scale), rect.top + (8f * scale)), 180f, 180f, false, ornamentPaint)
            canvas.drawArc(RectF(rect.right - (24f * scale), rect.top - (10f * scale), rect.right - (6f * scale), rect.top + (8f * scale)), 180f, 180f, false, ornamentPaint)
        }
        "gemini" -> {
            canvas.drawLine(rect.left + (12f * scale), rect.top + (6f * scale), rect.left + (12f * scale), rect.bottom - (6f * scale), ornamentPaint)
            canvas.drawLine(rect.left + (20f * scale), rect.top + (6f * scale), rect.left + (20f * scale), rect.bottom - (6f * scale), ornamentPaint)
            canvas.drawLine(rect.right - (12f * scale), rect.top + (6f * scale), rect.right - (12f * scale), rect.bottom - (6f * scale), ornamentPaint)
            canvas.drawLine(rect.right - (20f * scale), rect.top + (6f * scale), rect.right - (20f * scale), rect.bottom - (6f * scale), ornamentPaint)
        }
        "cancer" -> {
            canvas.drawArc(RectF(rect.left + (10f * scale), rect.top + (5f * scale), rect.left + (24f * scale), rect.bottom - (5f * scale)), 30f, 260f, false, ornamentPaint)
            canvas.drawArc(RectF(rect.right - (24f * scale), rect.top + (5f * scale), rect.right - (10f * scale), rect.bottom - (5f * scale)), 210f, 260f, false, ornamentPaint)
        }
        "leo" -> {
            repeat(5) { index ->
                val x = rect.left + (14f * scale) + (index * 6f * scale)
                canvas.drawLine(x, rect.top - (3f * scale), x, rect.top + (5f * scale), ornamentPaint)
            }
        }
        "virgo" -> {
            val vine = Path().apply {
                moveTo(rect.left + (10f * scale), rect.centerY())
                cubicTo(rect.left + (16f * scale), rect.top + (5f * scale), rect.left + (24f * scale), rect.bottom - (5f * scale), rect.left + (30f * scale), rect.centerY())
            }
            canvas.drawPath(vine, ornamentPaint)
        }
        "libra" -> {
            canvas.drawLine(rect.left + (12f * scale), rect.bottom - (6f * scale), rect.right - (12f * scale), rect.bottom - (6f * scale), ornamentPaint)
            canvas.drawArc(RectF(rect.centerX() - (16f * scale), rect.top + (3f * scale), rect.centerX() + (16f * scale), rect.top + (15f * scale)), 180f, 180f, false, ornamentPaint)
        }
        "scorpio" -> {
            val tail = Path().apply {
                moveTo(rect.right - (30f * scale), rect.centerY())
                lineTo(rect.right - (14f * scale), rect.centerY())
                lineTo(rect.right - (8f * scale), rect.centerY() - (5f * scale))
            }
            canvas.drawPath(tail, ornamentPaint)
        }
        "sagittarius" -> {
            canvas.drawLine(rect.right - (28f * scale), rect.bottom - (8f * scale), rect.right - (10f * scale), rect.top + (8f * scale), ornamentPaint)
            canvas.drawLine(rect.right - (16f * scale), rect.top + (8f * scale), rect.right - (10f * scale), rect.top + (8f * scale), ornamentPaint)
            canvas.drawLine(rect.right - (10f * scale), rect.top + (8f * scale), rect.right - (10f * scale), rect.top + (14f * scale), ornamentPaint)
        }
        "capricorn" -> {
            val ridge = Path().apply {
                moveTo(rect.left + (10f * scale), rect.bottom - (6f * scale))
                lineTo(rect.left + (16f * scale), rect.top + (8f * scale))
                lineTo(rect.left + (24f * scale), rect.bottom - (6f * scale))
                lineTo(rect.left + (32f * scale), rect.top + (10f * scale))
            }
            canvas.drawPath(ridge, ornamentPaint)
        }
        "aquarius" -> {
            repeat(2) { row ->
                val y = rect.top + (8f * scale) + (row * 7f * scale)
                val wave = Path().apply {
                    moveTo(rect.left + (10f * scale), y)
                    lineTo(rect.left + (16f * scale), y - (3f * scale))
                    lineTo(rect.left + (22f * scale), y)
                    lineTo(rect.left + (28f * scale), y - (3f * scale))
                    lineTo(rect.left + (34f * scale), y)
                }
                canvas.drawPath(wave, ornamentPaint)
            }
        }
        "pisces" -> {
            canvas.drawArc(RectF(rect.left + (10f * scale), rect.top + (6f * scale), rect.left + (24f * scale), rect.bottom - (6f * scale)), 270f, 180f, false, ornamentPaint)
            canvas.drawArc(RectF(rect.left + (22f * scale), rect.top + (6f * scale), rect.left + (36f * scale), rect.bottom - (6f * scale)), 90f, 180f, false, ornamentPaint)
            canvas.drawLine(rect.left + (23f * scale), rect.top + (6f * scale), rect.left + (23f * scale), rect.bottom - (6f * scale), ornamentPaint)
        }
    }

    val shimmerProgress = ((presentationTimeUs / 1000L) % 2400L).toFloat() / 2400f
    val shimmerX = rect.left + (rect.width() * shimmerProgress)
    val shimmerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        shader = LinearGradient(
            shimmerX - (18f * scale),
            rect.top,
            shimmerX + (18f * scale),
            rect.bottom,
            intArrayOf(Color.TRANSPARENT, Color.argb(46, 255, 249, 233), Color.TRANSPARENT),
            floatArrayOf(0f, 0.5f, 1f),
            Shader.TileMode.CLAMP,
        )
    }
    canvas.save()
    canvas.clipRect(rect)
    canvas.drawRect(
        RectF(shimmerX - (24f * scale), rect.top, shimmerX + (24f * scale), rect.bottom),
        shimmerPaint,
    )
    canvas.restore()
}

    private fun drawTitleFlourishes(
        canvas: Canvas,
        sideInset: Float,
        centerY: Float,
        title: String,
        titlePaint: Paint,
        scale: Float,
        theme: ZodiacTheme,
    ) {
        val titleWidth = titlePaint.measureText(title)
        val leftEnd = sideInset - (6f * scale)
        val rightStart = sideInset + titleWidth + (12f * scale)
        val flourishPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                sideInset,
                centerY,
                sideInset + (100f * scale),
                centerY,
                intArrayOf(
                    adjustAlpha(theme.titleStartColor, 0.18f),
                    adjustAlpha(theme.titleStartColor, 0.66f),
                    adjustAlpha(theme.titleEndColor, 0.18f),
                ),
                null,
                Shader.TileMode.CLAMP,
            )
            style = Paint.Style.STROKE
            strokeWidth = 1.15f * scale
        }
        canvas.drawLine(sideInset, centerY, leftEnd + (22f * scale), centerY, flourishPaint)
        canvas.drawArc(
            RectF(
                leftEnd + (16f * scale),
                centerY - (7f * scale),
                leftEnd + (30f * scale),
                centerY + (7f * scale),
            ),
            110f,
            110f,
            false,
            flourishPaint,
        )
        canvas.drawLine(rightStart, centerY, rightStart + (26f * scale), centerY, flourishPaint)
        canvas.drawArc(
            RectF(
                rightStart + (18f * scale),
                centerY - (7f * scale),
                rightStart + (34f * scale),
                centerY + (7f * scale),
            ),
            -40f,
            110f,
            false,
            flourishPaint,
        )
    }

    private fun drawLeoSkyHeader(
        canvas: Canvas,
        rect: RectF,
        theme: ZodiacTheme,
        scale: Float,
        pulse: Float,
        presentationTimeUs: Long,
    ) {
        val radius = rect.height() / 2f
        val shadowRect = RectF(rect).apply { offset(0f, 3f * scale) }
        val shadowPaintLocal = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(42, 0, 0, 0)
            maskFilter = BlurMaskFilter(10f * scale, BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawRoundRect(shadowRect, radius, radius, shadowPaintLocal)

        val skyPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.right,
                rect.bottom,
                intArrayOf(
                    Color.rgb(8, 16, 34),
                    Color.rgb(18, 28, 56),
                    Color.rgb(55, 26, 24),
                ),
                floatArrayOf(0f, 0.58f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRoundRect(rect, radius, radius, skyPaint)

        val warmGlowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                rect.right - (rect.width() * 0.12f),
                rect.bottom - (rect.height() * 0.06f),
                rect.width() * 0.34f,
                intArrayOf(
                    adjustAlpha(theme.glowColor, 0.28f + (0.10f * pulse)),
                    adjustAlpha(theme.fillMidColor, 0.16f),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.52f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRoundRect(rect, radius, radius, warmGlowPaint)

        val veilPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.left,
                rect.bottom,
                intArrayOf(
                    adjustAlpha(theme.constellationColor, 0.08f),
                    Color.TRANSPARENT,
                    adjustAlpha(theme.beamColor, 0.12f),
                ),
                floatArrayOf(0f, 0.44f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRoundRect(rect, radius, radius, veilPaint)

        val starField = listOf(
            Triple(0.08f, 0.26f, 1.05f),
            Triple(0.16f, 0.62f, 0.90f),
            Triple(0.24f, 0.18f, 1.25f),
            Triple(0.31f, 0.50f, 0.95f),
            Triple(0.42f, 0.28f, 1.05f),
            Triple(0.54f, 0.66f, 0.88f),
            Triple(0.63f, 0.20f, 1.15f),
            Triple(0.74f, 0.44f, 0.92f),
            Triple(0.82f, 0.24f, 1.32f),
            Triple(0.90f, 0.58f, 0.98f),
        )
        val starPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.86f)
            style = Paint.Style.FILL
        }
        val starGlowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.glowColor, 0.34f + (0.10f * pulse))
            style = Paint.Style.FILL
            maskFilter = BlurMaskFilter(8f * scale, BlurMaskFilter.Blur.NORMAL)
        }
        starField.forEachIndexed { index, (xFactor, yFactor, sizeFactor) ->
            val x = rect.left + (rect.width() * xFactor)
            val y = rect.top + (rect.height() * yFactor)
            val starRadius = max(1.15f * scale, 1.3f * sizeFactor * scale)
            if (index % 3 == 0) {
                canvas.drawCircle(x, y, starRadius * 2.1f, starGlowPaint)
            }
            canvas.drawCircle(x, y, starRadius, starPaint)
        }

        val constellationRect = RectF(
            rect.left + (18f * scale),
            rect.top + (6f * scale),
            rect.right - (22f * scale),
            rect.bottom - (6f * scale),
        )
        val constellationPoints = constellationPointsFor("leo")
        val constellationPath = Path()
        constellationPoints.forEachIndexed { index, pair ->
            val x = constellationRect.left + (constellationRect.width() * pair.first)
            val y = constellationRect.top + (constellationRect.height() * pair.second)
            if (index == 0) {
                constellationPath.moveTo(x, y)
            } else {
                constellationPath.lineTo(x, y)
            }
        }
        val shimmer = ((sin(presentationTimeUs / 410000.0) + 1.0) / 2.0).toFloat()
        val constellationGlow = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.glowColor, 0.22f + (0.10f * shimmer))
            style = Paint.Style.STROKE
            strokeWidth = 3.0f * scale
            maskFilter = BlurMaskFilter(6f * scale, BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawPath(constellationPath, constellationGlow)

        val constellationStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.72f)
            style = Paint.Style.STROKE
            strokeWidth = 1.1f * scale
        }
        canvas.drawPath(constellationPath, constellationStroke)

        val nodePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.96f)
            style = Paint.Style.FILL
        }
        constellationPoints.forEachIndexed { index, pair ->
            val x = constellationRect.left + (constellationRect.width() * pair.first)
            val y = constellationRect.top + (constellationRect.height() * pair.second)
            if (index % 2 == 0) {
                canvas.drawCircle(x, y, 2.3f * scale, starGlowPaint)
            }
            canvas.drawCircle(x, y, if (index % 3 == 0) 1.8f * scale else 1.35f * scale, nodePaint)
        }

        val arcPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.beamColor, 0.34f)
            style = Paint.Style.STROKE
            strokeWidth = 1.1f * scale
        }
        val arcPath = Path().apply {
            moveTo(rect.left + (rect.width() * 0.06f), rect.bottom - (rect.height() * 0.18f))
            cubicTo(
                rect.left + (rect.width() * 0.28f), rect.bottom - (rect.height() * 0.04f),
                rect.left + (rect.width() * 0.56f), rect.top + (rect.height() * 0.96f),
                rect.right - (rect.width() * 0.08f), rect.top + (rect.height() * 0.24f),
            )
        }
        canvas.drawPath(arcPath, arcPaint)

        val borderPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.26f)
            style = Paint.Style.STROKE
            strokeWidth = 0.9f * scale
        }
        canvas.drawRoundRect(rect, radius, radius, borderPaint)
    }

    private fun drawBarOrnaments(
        canvas: Canvas,
        rect: RectF,
        theme: ZodiacTheme,
        scale: Float,
    ) {
        val ornamentPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.42f)
            style = Paint.Style.STROKE
            strokeWidth = 1.05f * scale
        }
        when (theme.signKey) {
            "aries" -> {
                canvas.drawArc(
                    RectF(rect.left - (8f * scale), rect.top - (10f * scale), rect.left + (18f * scale), rect.top + (12f * scale)),
                    210f,
                    90f,
                    false,
                    ornamentPaint,
                )
                canvas.drawArc(
                    RectF(rect.right - (18f * scale), rect.top - (10f * scale), rect.right + (8f * scale), rect.top + (12f * scale)),
                    240f,
                    90f,
                    false,
                    ornamentPaint,
                )
            }
            "taurus" -> {
                canvas.drawCircle(rect.left + (14f * scale), rect.centerY(), 4.5f * scale, ornamentPaint)
                canvas.drawCircle(rect.right - (14f * scale), rect.centerY(), 4.5f * scale, ornamentPaint)
            }
            "gemini" -> {
                canvas.drawLine(rect.left + (20f * scale), rect.top + (5f * scale), rect.left + (20f * scale), rect.bottom - (5f * scale), ornamentPaint)
                canvas.drawLine(rect.left + (28f * scale), rect.top + (5f * scale), rect.left + (28f * scale), rect.bottom - (5f * scale), ornamentPaint)
            }
            "cancer" -> {
                canvas.drawArc(RectF(rect.left + (18f * scale), rect.top + (4f * scale), rect.left + (34f * scale), rect.bottom - (4f * scale)), 40f, 250f, false, ornamentPaint)
                canvas.drawArc(RectF(rect.left + (30f * scale), rect.top + (4f * scale), rect.left + (46f * scale), rect.bottom - (4f * scale)), 220f, 250f, false, ornamentPaint)
            }
            "leo" -> {
                val cx = rect.centerX()
                canvas.drawLine(cx, rect.top - (4f * scale), cx, rect.top + (6f * scale), ornamentPaint)
                canvas.drawLine(cx - (7f * scale), rect.top - (2f * scale), cx - (1f * scale), rect.top + (6f * scale), ornamentPaint)
                canvas.drawLine(cx + (7f * scale), rect.top - (2f * scale), cx + (1f * scale), rect.top + (6f * scale), ornamentPaint)
            }
            "virgo" -> {
                canvas.drawArc(RectF(rect.left + (10f * scale), rect.top + (4f * scale), rect.left + (26f * scale), rect.bottom - (6f * scale)), 290f, 120f, false, ornamentPaint)
                canvas.drawArc(RectF(rect.left + (18f * scale), rect.top + (6f * scale), rect.left + (34f * scale), rect.bottom - (4f * scale)), 280f, 110f, false, ornamentPaint)
            }
            "libra" -> {
                canvas.drawLine(rect.centerX() - (16f * scale), rect.top + (7f * scale), rect.centerX() + (16f * scale), rect.top + (7f * scale), ornamentPaint)
                canvas.drawArc(RectF(rect.centerX() - (12f * scale), rect.top + (2f * scale), rect.centerX() + (12f * scale), rect.top + (16f * scale)), 180f, 180f, false, ornamentPaint)
            }
            "scorpio" -> {
                val path = Path()
                path.moveTo(rect.right - (18f * scale), rect.centerY())
                path.lineTo(rect.right - (8f * scale), rect.centerY())
                path.lineTo(rect.right - (2f * scale), rect.centerY() - (4f * scale))
                canvas.drawPath(path, ornamentPaint)
            }
            "sagittarius" -> {
                canvas.drawLine(rect.left + (14f * scale), rect.bottom - (8f * scale), rect.left + (34f * scale), rect.top + (8f * scale), ornamentPaint)
                canvas.drawLine(rect.left + (28f * scale), rect.top + (8f * scale), rect.left + (34f * scale), rect.top + (8f * scale), ornamentPaint)
                canvas.drawLine(rect.left + (34f * scale), rect.top + (8f * scale), rect.left + (34f * scale), rect.top + (14f * scale), ornamentPaint)
            }
            "capricorn" -> {
                val path = Path()
                path.moveTo(rect.centerX() - (14f * scale), rect.top + (9f * scale))
                path.lineTo(rect.centerX() - (6f * scale), rect.top + (3f * scale))
                path.lineTo(rect.centerX() + (2f * scale), rect.top + (10f * scale))
                path.lineTo(rect.centerX() + (10f * scale), rect.top + (4f * scale))
                canvas.drawPath(path, ornamentPaint)
            }
            "aquarius" -> {
                canvas.drawLine(rect.left + (12f * scale), rect.top + (9f * scale), rect.left + (22f * scale), rect.top + (5f * scale), ornamentPaint)
                canvas.drawLine(rect.left + (22f * scale), rect.top + (5f * scale), rect.left + (32f * scale), rect.top + (9f * scale), ornamentPaint)
                canvas.drawLine(rect.left + (36f * scale), rect.top + (9f * scale), rect.left + (46f * scale), rect.top + (5f * scale), ornamentPaint)
                canvas.drawLine(rect.left + (46f * scale), rect.top + (5f * scale), rect.left + (56f * scale), rect.top + (9f * scale), ornamentPaint)
            }
            "pisces" -> {
                canvas.drawArc(RectF(rect.left + (14f * scale), rect.top + (5f * scale), rect.left + (30f * scale), rect.bottom - (5f * scale)), 270f, 180f, false, ornamentPaint)
                canvas.drawArc(RectF(rect.left + (24f * scale), rect.top + (5f * scale), rect.left + (40f * scale), rect.bottom - (5f * scale)), 90f, 180f, false, ornamentPaint)
            }
        }
    }

    private fun drawCoinAccent(
        canvas: Canvas,
        rect: RectF,
        theme: ZodiacTheme,
        scale: Float,
    ) {
        val accentPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.34f)
            style = Paint.Style.STROKE
            strokeWidth = 1f * scale
        }
        when (theme.signKey) {
            "leo" -> {
                repeat(6) { index ->
                    val angle = Math.toRadians((-90 + (index * 60)).toDouble())
                    val inner = rect.width() * 0.56f
                    val outer = rect.width() * 0.66f
                    val cx = rect.centerX()
                    val cy = rect.centerY()
                    canvas.drawLine(
                        cx + (kotlin.math.cos(angle).toFloat() * inner),
                        cy + (kotlin.math.sin(angle).toFloat() * inner),
                        cx + (kotlin.math.cos(angle).toFloat() * outer),
                        cy + (kotlin.math.sin(angle).toFloat() * outer),
                        accentPaint,
                    )
                }
            }
            "aquarius" -> {
                canvas.drawArc(RectF(rect.left - (2f * scale), rect.centerY() - (8f * scale), rect.right + (2f * scale), rect.centerY() + (2f * scale)), 200f, 140f, false, accentPaint)
                canvas.drawArc(RectF(rect.left - (2f * scale), rect.centerY() + (2f * scale), rect.right + (2f * scale), rect.centerY() + (12f * scale)), 200f, 140f, false, accentPaint)
            }
            "pisces" -> {
                canvas.drawArc(RectF(rect.left + (10f * scale), rect.top + (8f * scale), rect.centerX() + (6f * scale), rect.bottom - (8f * scale)), 90f, 180f, false, accentPaint)
                canvas.drawArc(RectF(rect.centerX() - (6f * scale), rect.top + (8f * scale), rect.right - (10f * scale), rect.bottom - (8f * scale)), 270f, 180f, false, accentPaint)
            }
            else -> {
                canvas.drawArc(RectF(rect.left + (6f * scale), rect.top + (6f * scale), rect.right - (6f * scale), rect.bottom - (6f * scale)), 205f, 130f, false, accentPaint)
            }
        }
    }

    private fun drawAccuracyBar(
        canvas: Canvas,
        rect: RectF,
        accuracy: Float,
        scale: Float,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme?,
    ) {
        val professionKey = theme?.storageKey.orEmpty()
        if (isProfessionSignatureVariant(professionKey) && theme != null) {
            drawProfessionSignatureAccuracyBar(
                canvas = canvas,
                rect = rect,
                accuracy = accuracy,
                scale = scale,
                presentationTimeUs = presentationTimeUs,
                theme = theme,
                key = professionKey,
            )
            return
        }

        val safeAccuracy = accuracy.coerceIn(0f, 1f)
        val radius = rect.height() / 2f
        val fillColor = when {
            safeAccuracy >= 0.8f -> theme?.accuracyHighColor ?: Color.rgb(76, 175, 80)
            safeAccuracy >= 0.6f -> theme?.accuracyMidColor ?: Color.rgb(255, 152, 0)
            else -> theme?.accuracyLowColor ?: Color.rgb(244, 67, 54)
        }

        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(theme?.primaryStart ?: Color.argb(248, 10, 11, 13), 0.97f),
                        adjustAlpha(theme?.primaryEnd ?: Color.argb(242, 22, 29, 40), 0.94f),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        canvas.drawRoundRect(
            rect,
            radius,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(78, 255, 255, 255)
                style = Paint.Style.STROKE
                strokeWidth = max(1.05f, 1.05f * scale)
            },
        )

        val innerRect = RectF(
            rect.left + (2f * scale),
            rect.top + (2f * scale),
            rect.right - (2f * scale),
            rect.bottom - (2f * scale),
        )
        val innerRadius = innerRect.height() / 2f

        canvas.drawRoundRect(
            innerRect,
            innerRadius,
            innerRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(56, 0, 0, 0)
            },
        )

        val fillWidth = innerRect.width() * safeAccuracy
        if (fillWidth > 0f) {
            val fillRect = RectF(
                innerRect.left,
                innerRect.top,
                innerRect.left + fillWidth,
                innerRect.bottom,
            )
            canvas.drawRoundRect(
                fillRect,
                innerRadius,
                innerRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(fillColor, 0.26f)
                    maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
                },
            )
            canvas.drawRoundRect(
                fillRect,
                innerRadius,
                innerRadius,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        fillRect.left,
                        fillRect.top,
                        fillRect.right.coerceAtLeast(fillRect.left + 1f),
                        fillRect.bottom,
                        intArrayOf(
                            blendColors(fillColor, Color.WHITE, 0.24f),
                            fillColor,
                            blendColors(fillColor, Color.BLACK, 0.20f),
                        ),
                        floatArrayOf(0f, 0.56f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )

            val shimmerDurationMs = 1900f
            val shimmerProgress =
                ((presentationTimeUs / 1000L) % shimmerDurationMs.toLong()).toFloat() / shimmerDurationMs
            val shimmerX = fillRect.left + (fillRect.width() * shimmerProgress)
            val shimmerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    shimmerX - (16f * scale),
                    fillRect.top,
                    shimmerX + (16f * scale),
                    fillRect.bottom,
                    intArrayOf(Color.TRANSPARENT, Color.argb(158, 255, 255, 255), Color.TRANSPARENT),
                    floatArrayOf(0f, 0.5f, 1f),
                    Shader.TileMode.CLAMP,
                )
            }
            canvas.save()
            canvas.clipRect(fillRect)
            canvas.drawRect(
                shimmerX - (18f * scale),
                fillRect.top,
                shimmerX + (18f * scale),
                fillRect.bottom,
                shimmerPaint,
            )
            canvas.restore()
        }

        val thresholdX = innerRect.left + (innerRect.width() * 0.8f)
        canvas.drawRoundRect(
            RectF(
                thresholdX - (1.2f * scale),
                innerRect.top + (2f * scale),
                thresholdX + (1.2f * scale),
                innerRect.bottom - (2f * scale),
            ),
            99f,
            99f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme?.thresholdLineColor ?: Color.WHITE, 0.68f)
            },
        )

        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(222, 255, 255, 255)
            textAlign = Paint.Align.LEFT
            textSize = max(10f, 10f * scale)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        val valuePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(246, 255, 255, 255)
            textAlign = Paint.Align.RIGHT
            textSize = max(10f, 10f * scale)
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        val labelBaseline =
            rect.centerY() - ((labelPaint.fontMetrics.ascent + labelPaint.fontMetrics.descent) / 2f)
        val valueBaseline =
            rect.centerY() - ((valuePaint.fontMetrics.ascent + valuePaint.fontMetrics.descent) / 2f)
        canvas.drawText("ACCURACY", innerRect.left + (10f * scale), labelBaseline, labelPaint)
        canvas.drawText("${(safeAccuracy * 100f).roundToInt()}%", innerRect.right - (12f * scale), valueBaseline, valuePaint)
    }

    private fun drawZodiacAccuracyBar(
    canvas: Canvas,
    rect: RectF,
    accuracy: Float,
    scale: Float,
    presentationTimeUs: Long,
    theme: ZodiacTheme,
    screenHeight: Float,
) {
    val radius = rect.height() / 2f
    val shadowRect = RectF(rect).apply { offset(0f, 3f * scale) }
    val shadowPaintLocal = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(56, 0, 0, 0)
        maskFilter = BlurMaskFilter(8f * scale, BlurMaskFilter.Blur.NORMAL)
    }
    canvas.drawRoundRect(shadowRect, radius, radius, shadowPaintLocal)

    val backgroundPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        shader = LinearGradient(
            rect.left,
            rect.top,
            rect.right,
            rect.bottom,
            intArrayOf(
                theme.shellStartColor,
                theme.shellMidColor,
                theme.shellEndColor,
            ),
            floatArrayOf(0f, 0.64f, 1f),
            Shader.TileMode.CLAMP,
        )
    }
    canvas.drawRoundRect(rect, radius, radius, backgroundPaint)
    canvas.drawRoundRect(
        rect,
        radius,
        radius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                rect.left,
                rect.top,
                rect.left,
                rect.bottom,
                intArrayOf(
                    Color.argb(60, 255, 255, 255),
                    Color.argb(18, 255, 245, 230),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.20f, 0.74f),
                Shader.TileMode.CLAMP,
            )
        },
    )

    val fillWidth = rect.width() * accuracy.coerceIn(0f, 1f)
    if (fillWidth > 6f * scale) {
        val fillRect = RectF(rect.left + (2f * scale), rect.top + (2f * scale), rect.left + fillWidth, rect.bottom - (2f * scale))
        val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                fillRect.left,
                fillRect.top,
                fillRect.right,
                fillRect.bottom,
                intArrayOf(
                    theme.fillStartColor,
                    theme.fillMidColor,
                    theme.fillEndColor,
                ),
                floatArrayOf(0f, 0.54f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRoundRect(fillRect, radius * 0.88f, radius * 0.88f, fillPaint)
        canvas.drawRoundRect(
            RectF(fillRect.left, fillRect.top, fillRect.right, fillRect.top + (fillRect.height() * 0.48f)),
            radius * 0.76f,
            radius * 0.76f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    fillRect.left,
                    fillRect.top,
                    fillRect.left,
                    fillRect.bottom,
                    intArrayOf(
                        Color.argb(84, 255, 255, 255),
                        Color.argb(18, 255, 249, 236),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.34f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawRoundRect(
            RectF(fillRect.left, fillRect.top + (fillRect.height() * 0.54f), fillRect.right, fillRect.bottom),
            radius * 0.76f,
            radius * 0.76f,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    fillRect.left,
                    fillRect.top,
                    fillRect.left,
                    fillRect.bottom,
                    intArrayOf(
                        Color.TRANSPARENT,
                        adjustAlpha(blendColors(theme.fillEndColor, Color.BLACK, 0.16f), 0.10f),
                        adjustAlpha(blendColors(theme.fillEndColor, Color.BLACK, 0.24f), 0.22f),
                    ),
                    floatArrayOf(0f, 0.42f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        val shimmerProgress = ((presentationTimeUs / 1000L) % 2600L).toFloat() / 2600f
        val shimmerX = fillRect.left + (fillRect.width() * shimmerProgress)
        val shimmerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                shimmerX - (18f * scale),
                fillRect.top,
                shimmerX + (18f * scale),
                fillRect.bottom,
                intArrayOf(
                    Color.TRANSPARENT,
                    Color.argb(92, 255, 247, 225),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.5f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.save()
        canvas.clipRect(fillRect)
        canvas.drawRect(
            RectF(
                shimmerX - (24f * scale),
                fillRect.top,
                shimmerX + (24f * scale),
                fillRect.bottom,
            ),
            shimmerPaint,
        )
        canvas.restore()

        val thumbBob = ((sin(presentationTimeUs / 450000.0) + 1.0) / 2.0).toFloat()
        val thumbRadius = 5f * scale + (1.5f * scale * thumbBob)
        val edgeX = fillRect.right

        val thumbGlowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.glowColor, 0.68f + (0.32f * thumbBob))
            maskFilter = BlurMaskFilter(5f * scale, BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawCircle(edgeX, rect.centerY(), thumbRadius * 1.6f, thumbGlowPaint)

        val thumbCorePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(255, 255, 255, 255)
        }
        canvas.drawCircle(edgeX, rect.centerY(), thumbRadius * 0.7f, thumbCorePaint)

        if (accuracy >= 0.8f) {
            val thresholdProgress = ((accuracy - 0.8f) / 0.2f).coerceIn(0f, 1f)
            val dropDurationMs = max(1800f, 3000f - (600f * thresholdProgress))
            val dropCycle =
                ((presentationTimeUs / 1000L) % dropDurationMs.toLong()).toFloat() / dropDurationMs
            val easedDrop = dropCycle * dropCycle
            val targetY = max(screenHeight * 0.5f, rect.bottom + (screenHeight * 0.08f))
            val dropletY = rect.bottom + ((targetY - rect.bottom) * easedDrop)
            val dropletX =
                edgeX + (kotlin.math.sin(presentationTimeUs / 540000.0).toFloat() * (4f * scale))
            val fadeStart = 0.72f
            val fadeProgress = ((dropCycle - fadeStart) / (1f - fadeStart)).coerceIn(0f, 1f)
            val dropletAlpha = (1f - fadeProgress) * (0.72f + (0.28f * thresholdProgress))
            val dropletRadius = (4.4f + (2.2f * thresholdProgress)) * scale

            if (dropletAlpha > 0.01f) {
                if (dropCycle < 0.34f) {
                    val streamAlpha = dropletAlpha * (1f - (dropCycle / 0.34f))
                    val streamPath = Path().apply {
                        moveTo(edgeX, rect.bottom - (1f * scale))
                        cubicTo(
                            edgeX + (3f * scale),
                            rect.bottom + ((dropletY - rect.bottom) * 0.18f),
                            dropletX - (6f * scale),
                            rect.bottom + ((dropletY - rect.bottom) * 0.62f),
                            dropletX,
                            dropletY - dropletRadius,
                        )
                    }
                    canvas.drawPath(
                        streamPath,
                        Paint(Paint.ANTI_ALIAS_FLAG).apply {
                            style = Paint.Style.STROKE
                            strokeCap = Paint.Cap.ROUND
                            strokeJoin = Paint.Join.ROUND
                            strokeWidth = max(1.2f * scale, dropletRadius * 0.55f)
                            shader = LinearGradient(
                                edgeX,
                                rect.bottom,
                                dropletX,
                                dropletY,
                                intArrayOf(
                                    adjustAlpha(theme.glowColor, 0f),
                                    adjustAlpha(theme.glowColor, streamAlpha * 0.78f),
                                    adjustAlpha(theme.fillMidColor, streamAlpha * 0.42f),
                                    Color.TRANSPARENT,
                                ),
                                floatArrayOf(0f, 0.20f, 0.72f, 1f),
                                Shader.TileMode.CLAMP,
                            )
                        },
                    )
                }

                canvas.drawCircle(
                    dropletX,
                    dropletY,
                    dropletRadius * 1.9f,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = RadialGradient(
                            dropletX,
                            dropletY,
                            dropletRadius * 1.9f,
                            intArrayOf(
                                adjustAlpha(theme.glowColor, dropletAlpha * 0.34f),
                                adjustAlpha(theme.glowColor, dropletAlpha * 0.10f),
                                Color.TRANSPARENT,
                            ),
                            floatArrayOf(0f, 0.54f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
                canvas.drawCircle(
                    dropletX,
                    dropletY,
                    dropletRadius,
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = RadialGradient(
                            dropletX - (dropletRadius * 0.18f),
                            dropletY - (dropletRadius * 0.22f),
                            dropletRadius,
                            intArrayOf(
                                adjustAlpha(Color.WHITE, dropletAlpha * 0.98f),
                                adjustAlpha(theme.fillMidColor, dropletAlpha * 0.72f),
                                adjustAlpha(theme.fillEndColor, dropletAlpha * 0.18f),
                                Color.TRANSPARENT,
                            ),
                            floatArrayOf(0f, 0.24f, 0.72f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
            }
        }
    }

    val outerStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.glowColor, 0.88f)
        style = Paint.Style.STROKE
        strokeWidth = max(1.2f, 1.15f * scale)
    }
    canvas.drawRoundRect(rect, radius, radius, outerStroke)

    val innerStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.constellationColor, 0.28f)
        style = Paint.Style.STROKE
        strokeWidth = 0.8f * scale
    }
    canvas.drawRoundRect(
        RectF(rect.left + (2f * scale), rect.top + (2f * scale), rect.right - (2f * scale), rect.bottom - (2f * scale)),
        radius,
        radius,
        innerStroke,
    )

    val constellationPoints = constellationPointsFor(theme.signKey)
    val path = Path()
    constellationPoints.forEachIndexed { index, pair ->
        val x = rect.left + (rect.width() * pair.first)
        val y = rect.top + (rect.height() * pair.second)
        if (index == 0) {
            path.moveTo(x, y)
        } else {
            path.lineTo(x, y)
        }
    }
    val constellationStroke = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.constellationColor, 0.52f)
        style = Paint.Style.STROKE
        strokeWidth = 0.9f * scale
    }
    canvas.drawPath(path, constellationStroke)
    val starPaintLocal = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.constellationColor, 0.84f)
        style = Paint.Style.FILL
    }
    constellationPoints.forEachIndexed { index, pair ->
        val x = rect.left + (rect.width() * pair.first)
        val y = rect.top + (rect.height() * pair.second)
        canvas.drawCircle(x, y, if (index % 3 == 0) 1.6f * scale else 1.15f * scale, starPaintLocal)
    }

    // Sign-specific customizations for accuracy bar
    when (theme.signKey) {
        "aries" -> {
            // Aries: Warrior helmet horns
            val hornPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
            }
            // Left horn
            canvas.drawPath(Path().apply {
                moveTo(rect.left + (8f * scale), rect.top + (rect.height() * 0.3f))
                lineTo(rect.left + (4f * scale), rect.top + (rect.height() * 0.1f))
                lineTo(rect.left + (12f * scale), rect.top + (rect.height() * 0.15f))
                close()
            }, hornPaint)
            // Right horn
            canvas.drawPath(Path().apply {
                moveTo(rect.right - (8f * scale), rect.top + (rect.height() * 0.3f))
                lineTo(rect.right - (4f * scale), rect.top + (rect.height() * 0.1f))
                lineTo(rect.right - (12f * scale), rect.top + (rect.height() * 0.15f))
                close()
            }, hornPaint)
        }
        "taurus" -> {
            // Taurus: Bull horns
            val hornPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
            }
            // Left horn
            canvas.drawCircle(rect.left + (6f * scale), rect.top + (rect.height() * 0.25f), 4f * scale, hornPaint)
            // Right horn
            canvas.drawCircle(rect.right - (6f * scale), rect.top + (rect.height() * 0.25f), 4f * scale, hornPaint)
        }
        "gemini" -> {
            // Gemini: Twin pillars
            val pillarPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.6f)
            }
            // Left pillar
            canvas.drawRoundRect(
                RectF(rect.left + (2f * scale), rect.top + (rect.height() * 0.1f),
                      rect.left + (6f * scale), rect.bottom - (rect.height() * 0.1f)),
                2f * scale, 2f * scale, pillarPaint
            )
            // Right pillar
            canvas.drawRoundRect(
                RectF(rect.right - (6f * scale), rect.top + (rect.height() * 0.1f),
                      rect.right - (2f * scale), rect.bottom - (rect.height() * 0.1f)),
                2f * scale, 2f * scale, pillarPaint
            )
        }
        "cancer" -> {
            // Cancer: Crab claws
            val clawPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
            }
            // Left claw
            canvas.drawPath(Path().apply {
                moveTo(rect.left + (4f * scale), rect.centerY())
                lineTo(rect.left - (2f * scale), rect.centerY() - (6f * scale))
                lineTo(rect.left + (2f * scale), rect.centerY() - (3f * scale))
                lineTo(rect.left - (2f * scale), rect.centerY() + (6f * scale))
                close()
            }, clawPaint)
            // Right claw
            canvas.drawPath(Path().apply {
                moveTo(rect.right - (4f * scale), rect.centerY())
                lineTo(rect.right + (2f * scale), rect.centerY() - (6f * scale))
                lineTo(rect.right - (2f * scale), rect.centerY() - (3f * scale))
                lineTo(rect.right + (2f * scale), rect.centerY() + (6f * scale))
                close()
            }, clawPaint)
        }
        "leo" -> {
            // Leo: Lion mane/crown
            val manePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.7f)
            }
            // Crown spikes
            for (i in 0..4) {
                val x = rect.left + (rect.width() * (0.2f + i * 0.15f))
                canvas.drawPath(Path().apply {
                    moveTo(x, rect.top + (2f * scale))
                    lineTo(x - (2f * scale), rect.top - (4f * scale))
                    lineTo(x + (2f * scale), rect.top - (4f * scale))
                    close()
                }, manePaint)
            }
        }
        "virgo" -> {
            // Virgo: Flowing vines
            val vinePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.6f)
                style = Paint.Style.STROKE
                strokeWidth = 2f * scale
                strokeCap = Paint.Cap.ROUND
            }
            // Left vine
            canvas.drawPath(Path().apply {
                moveTo(rect.left + (4f * scale), rect.centerY())
                cubicTo(rect.left + (8f * scale), rect.centerY() - (8f * scale),
                       rect.left + (12f * scale), rect.centerY() + (4f * scale),
                       rect.left + (16f * scale), rect.centerY())
            }, vinePaint)
            // Right vine
            canvas.drawPath(Path().apply {
                moveTo(rect.right - (4f * scale), rect.centerY())
                cubicTo(rect.right - (8f * scale), rect.centerY() - (8f * scale),
                       rect.right - (12f * scale), rect.centerY() + (4f * scale),
                       rect.right - (16f * scale), rect.centerY())
            }, vinePaint)
        }
        "libra" -> {
            // Libra: Scale balance
            val scalePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
                style = Paint.Style.STROKE
                strokeWidth = 2f * scale
            }
            // Balance beam
            canvas.drawLine(rect.centerX() - (10f * scale), rect.centerY(),
                          rect.centerX() + (10f * scale), rect.centerY(), scalePaint)
            // Left pan
            canvas.drawCircle(rect.centerX() - (10f * scale), rect.centerY() + (6f * scale), 3f * scale, scalePaint)
            // Right pan
            canvas.drawCircle(rect.centerX() + (10f * scale), rect.centerY() + (6f * scale), 3f * scale, scalePaint)
        }
        "scorpio" -> {
            // Scorpio: Stinger tail
            val stingerPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
            }
            canvas.drawPath(Path().apply {
                moveTo(rect.right - (4f * scale), rect.centerY())
                lineTo(rect.right + (8f * scale), rect.centerY() - (2f * scale))
                lineTo(rect.right + (4f * scale), rect.centerY() + (6f * scale))
                lineTo(rect.right - (2f * scale), rect.centerY() + (2f * scale))
                close()
            }, stingerPaint)
        }
        "sagittarius" -> {
            // Sagittarius: Arrow tip
            val arrowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
            }
            canvas.drawPath(Path().apply {
                moveTo(rect.right - (4f * scale), rect.centerY())
                lineTo(rect.right + (6f * scale), rect.centerY() - (3f * scale))
                lineTo(rect.right + (6f * scale), rect.centerY() + (3f * scale))
                close()
            }, arrowPaint)
        }
        "capricorn" -> {
            // Capricorn: Goat horns
            val hornPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.8f)
            }
            // Curved horns
            canvas.drawPath(Path().apply {
                moveTo(rect.left + (6f * scale), rect.top + (rect.height() * 0.3f))
                cubicTo(rect.left + (2f * scale), rect.top + (rect.height() * 0.1f),
                       rect.left + (10f * scale), rect.top + (rect.height() * 0.15f),
                       rect.left + (6f * scale), rect.top + (rect.height() * 0.3f))
            }, hornPaint)
            canvas.drawPath(Path().apply {
                moveTo(rect.right - (6f * scale), rect.top + (rect.height() * 0.3f))
                cubicTo(rect.right - (2f * scale), rect.top + (rect.height() * 0.1f),
                       rect.right - (10f * scale), rect.top + (rect.height() * 0.15f),
                       rect.right - (6f * scale), rect.top + (rect.height() * 0.3f))
            }, hornPaint)
        }
        "aquarius" -> {
            // Aquarius: Water waves
            val wavePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.6f)
                style = Paint.Style.STROKE
                strokeWidth = 2f * scale
                strokeCap = Paint.Cap.ROUND
            }
            // Wave pattern
            canvas.drawPath(Path().apply {
                moveTo(rect.left + (4f * scale), rect.centerY())
                cubicTo(rect.left + (12f * scale), rect.centerY() - (6f * scale),
                       rect.left + (20f * scale), rect.centerY() + (6f * scale),
                       rect.left + (28f * scale), rect.centerY())
                cubicTo(rect.left + (36f * scale), rect.centerY() - (6f * scale),
                       rect.right - (12f * scale), rect.centerY() + (6f * scale),
                       rect.right - (4f * scale), rect.centerY())
            }, wavePaint)
        }
        "pisces" -> {
            // Pisces: Fish scales
            val scalePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.fillMidColor, 0.7f)
            }
            // Scale pattern
            for (i in 0..5) {
                val y = rect.top + (rect.height() * (0.2f + i * 0.12f))
                for (j in 0..8) {
                    val x = rect.left + (rect.width() * (0.1f + j * 0.1f))
                    if (x < rect.right - (8f * scale)) {
                        canvas.drawCircle(x, y, 1.5f * scale, scalePaint)
                    }
                }
            }
        }
    }

    val medallionRadius = rect.height() * 0.42f
    val medallionCenterX = rect.right - (rect.height() * 0.78f)
    val medallionCenterY = rect.centerY()
    val medallionPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        shader = RadialGradient(
            medallionCenterX,
            medallionCenterY,
            medallionRadius,
            intArrayOf(
                theme.fillStartColor,
                theme.fillMidColor,
                theme.fillEndColor,
            ),
            floatArrayOf(0f, 0.58f, 1f),
            Shader.TileMode.CLAMP,
        )
    }
    canvas.drawCircle(medallionCenterX, medallionCenterY, medallionRadius, medallionPaint)
    canvas.drawCircle(
        medallionCenterX - (medallionRadius * 0.16f),
        medallionCenterY - (medallionRadius * 0.18f),
        medallionRadius * 0.72f,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                medallionCenterX - (medallionRadius * 0.16f),
                medallionCenterY - (medallionRadius * 0.18f),
                medallionRadius * 0.76f,
                intArrayOf(
                    Color.argb(78, 255, 255, 255),
                    Color.argb(22, 255, 246, 234),
                    Color.TRANSPARENT,
                ),
                floatArrayOf(0f, 0.22f, 1f),
                Shader.TileMode.CLAMP,
            )
        },
    )
    canvas.drawCircle(
        medallionCenterX,
        medallionCenterY,
        medallionRadius,
        Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.48f)
            style = Paint.Style.STROKE
            strokeWidth = 0.9f * scale
        },
    )

    val symbolPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = adjustAlpha(theme.engravingColor, 0.94f)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
        textSize = max(14f, rect.height() * 0.58f)
    }
    drawCenteredText(canvas, theme.symbol, medallionCenterX, medallionCenterY, symbolPaint)

    val accuracyLabel = String.format(Locale.US, "%.1f%%", accuracy * 100f)
    val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.argb(246, 255, 249, 233)
        textAlign = Paint.Align.CENTER
        typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        textSize = max(13f, rect.height() * 0.46f)
        setShadowLayer(3f * scale, 0f, 1.5f * scale, Color.argb(90, 0, 0, 0))
    }
    drawCenteredText(
        canvas = canvas,
        text = accuracyLabel,
        centerX = rect.centerX() - (10f * scale),
        centerY = rect.centerY(),
        paint = textPaint,
    )
}

    private fun drawRepCounter(
        canvas: Canvas,
        rect: RectF,
        repCount: Int,
        scale: Float,
        phase: String,
        theme: WorldFestivalTheme?,
    ) {
        val professionKey = theme?.storageKey.orEmpty()
        if (isProfessionSignatureVariant(professionKey) && theme != null) {
            drawProfessionSignatureRepCounter(
                canvas = canvas,
                rect = rect,
                repCount = repCount,
                scale = scale,
                phase = phase,
                theme = theme,
                key = professionKey,
            )
            return
        }

        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = rect.width() / 2f
        val phaseColor = when (phase) {
            "down" -> theme?.phaseDownColor ?: Color.rgb(255, 152, 0)
            "hold" -> theme?.phaseHoldColor ?: Color.rgb(33, 150, 243)
            else -> theme?.phaseUpColor ?: Color.rgb(76, 175, 80)
        }

        canvas.drawCircle(
            centerX,
            centerY,
            radius + (3f * scale),
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(phaseColor, 0.26f)
                maskFilter = BlurMaskFilter(12f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawCircle(
            centerX,
            centerY + (8f * scale),
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(86, 0, 0, 0)
                maskFilter = BlurMaskFilter(9f * scale, BlurMaskFilter.Blur.NORMAL)
            },
        )
        canvas.drawCircle(
            centerX,
            centerY,
            radius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    centerX - (radius * 0.20f),
                    centerY - (radius * 0.28f),
                    radius,
                    intArrayOf(
                        adjustAlpha(theme?.primaryEnd ?: Color.argb(242, 28, 36, 49), 0.95f),
                        adjustAlpha(theme?.primaryStart ?: Color.argb(248, 9, 12, 17), 0.98f),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        val ringWidth = max(2.0f, 2.0f * scale)
        canvas.drawCircle(centerX, centerY, radius - (ringWidth / 2f), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(phaseColor, 0.95f)
            style = Paint.Style.STROKE
            strokeWidth = ringWidth
        })

        val innerRadius = radius - (6f * scale)
        canvas.drawCircle(
            centerX,
            centerY,
            innerRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    centerX - (innerRadius * 0.20f),
                    centerY - (innerRadius * 0.28f),
                    innerRadius,
                    intArrayOf(
                        Color.argb(26, 255, 255, 255),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawCircle(
            centerX,
            centerY,
            innerRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = Color.argb(80, 255, 255, 255)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, scale)
            },
        )

        repCountPaint.textSize = max(38f * scale, rect.width() * 0.365f)
        repCountPaint.color = Color.WHITE
        drawCenteredText(
            canvas = canvas,
            text = repCount.toString(),
            centerX = centerX,
            centerY = centerY,
            paint = repCountPaint,
        )
    }

    private fun isProfessionSignatureVariant(key: String): Boolean {
        return key == "profession_lawyer" ||
            key == "profession_business_coach" ||
            key == "profession_fashion_model" ||
            key == "profession_actor" ||
            key == "profession_photographer" ||
            key == "profession_presenter" ||
            key == "profession_business_owner" ||
            key == "profession_gym_trainer" ||
            key == "profession_swimmer" ||
            key == "profession_psychologist" ||
            key == "profession_philosopher" ||
            key == "profession_manager" ||
            key == "profession_director" ||
            key == "profession_cgd" ||
            key == "profession_it_engineer" ||
            key == "profession_musician" ||
            key == "profession_writer" ||
            key == "profession_game_streamer" ||
            key == "profession_social_media_influencer"
    }

    private fun drawProfessionSignatureAccuracyBar(
        canvas: Canvas,
        rect: RectF,
        accuracy: Float,
        scale: Float,
        presentationTimeUs: Long,
        theme: WorldFestivalTheme,
        key: String,
    ) {
        val safeAccuracy = accuracy.coerceIn(0f, 1f)
        val fillColor = when {
            safeAccuracy >= 0.8f -> theme.accuracyHighColor
            safeAccuracy >= 0.6f -> theme.accuracyMidColor
            else -> theme.accuracyLowColor
        }
        val cornerRadius = when (key) {
            "profession_fashion_model" -> rect.height() * 0.64f
            "profession_photographer" -> rect.height() * 0.16f
            "profession_lawyer" -> rect.height() * 0.22f
            "profession_swimmer" -> rect.height() * 0.52f
            "profession_philosopher" -> rect.height() * 0.18f
            "profession_cgd" -> rect.height() * 0.26f
            "profession_writer" -> rect.height() * 0.12f
            "profession_game_streamer" -> rect.height() * 0.20f
            else -> rect.height() * 0.34f
        }

        canvas.drawRoundRect(
            rect,
            cornerRadius,
            cornerRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = LinearGradient(
                    rect.left,
                    rect.top,
                    rect.right,
                    rect.bottom,
                    intArrayOf(
                        adjustAlpha(theme.primaryStart, 0.98f),
                        adjustAlpha(theme.primaryEnd, 0.96f),
                    ),
                    floatArrayOf(0f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )
        canvas.drawRoundRect(
            rect,
            cornerRadius,
            cornerRadius,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.accent2, 0.34f)
                style = Paint.Style.STROKE
                strokeWidth = max(1f, 1.2f * scale)
            },
        )

        val inner = RectF(rect.left + (2f * scale), rect.top + (2f * scale), rect.right - (2f * scale), rect.bottom - (2f * scale))
        canvas.drawRoundRect(
            inner,
            max(3f * scale, cornerRadius * 0.78f),
            max(3f * scale, cornerRadius * 0.78f),
            Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(52, 0, 0, 0) },
        )

        val fill = RectF(inner.left, inner.top, inner.left + (inner.width() * safeAccuracy), inner.bottom)
        if (fill.width() > 1f) {
            canvas.drawRoundRect(
                fill,
                max(2f * scale, cornerRadius * 0.70f),
                max(2f * scale, cornerRadius * 0.70f),
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        fill.left,
                        fill.top,
                        fill.right.coerceAtLeast(fill.left + 1f),
                        fill.bottom,
                        intArrayOf(
                            blendColors(fillColor, Color.WHITE, 0.24f),
                            fillColor,
                            blendColors(fillColor, Color.BLACK, 0.18f),
                        ),
                        floatArrayOf(0f, 0.52f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
            val shimmer = ((presentationTimeUs / 1000L) % 2100L).toFloat() / 2100f
            val x = fill.left + (fill.width() * shimmer)
            canvas.drawRect(
                x - (12f * scale),
                fill.top,
                x + (12f * scale),
                fill.bottom,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(
                        x - (12f * scale),
                        fill.top,
                        x + (12f * scale),
                        fill.bottom,
                        intArrayOf(Color.TRANSPARENT, Color.argb(120, 255, 255, 255), Color.TRANSPARENT),
                        floatArrayOf(0f, 0.5f, 1f),
                        Shader.TileMode.CLAMP,
                    )
                },
            )
        }

        when (key) {
            "profession_lawyer" -> {
                repeat(7) { index ->
                    val x = inner.left + ((index + 1) * inner.width() / 8f)
                    canvas.drawLine(
                        x,
                        inner.top + (1.4f * scale),
                        x,
                        inner.bottom - (1.4f * scale),
                        Paint(Paint.ANTI_ALIAS_FLAG).apply {
                            color = adjustAlpha(theme.accent1, 0.16f)
                            strokeWidth = if (index == 3) 1.8f * scale else 0.9f * scale
                        },
                    )
                }
                canvas.drawText("VERIFIED", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.90f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
                canvas.drawText("BALANCED", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.92f)
                    textAlign = Paint.Align.RIGHT
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_business_coach" -> {
                val lanePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.18f)
                    strokeWidth = 1.0f * scale
                }
                repeat(3) { lane ->
                    val y = inner.top + (inner.height() * (0.28f + (lane * 0.22f)))
                    canvas.drawLine(inner.left + (6f * scale), y, inner.right - (6f * scale), y, lanePaint)
                }
                repeat(4) { node ->
                    val x = inner.left + (inner.width() * (0.2f + (node * 0.2f)))
                    val y = inner.bottom - (inner.height() * (0.18f + (node * 0.12f)))
                    canvas.drawCircle(x, y, 1.8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accent1, 0.88f) })
                }
            }
            "profession_fashion_model" -> {
                canvas.drawLine(inner.left + (6f * scale), inner.top + (2f * scale), inner.right - (6f * scale), inner.top + (2f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(Color.WHITE, 0.38f)
                    strokeWidth = 0.9f * scale
                })
                canvas.drawLine(inner.left + (6f * scale), inner.bottom - (2f * scale), inner.right - (6f * scale), inner.bottom - (2f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.30f)
                    strokeWidth = 0.9f * scale
                })
                canvas.drawText("COUTURE", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accent1, 0.88f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
                })
            }
            "profession_actor" -> {
                val perforation = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.30f) }
                repeat(10) { i ->
                    val x = inner.left + (inner.width() * i / 9f)
                    canvas.drawCircle(x, inner.top + (1.8f * scale), 0.9f * scale, perforation)
                    canvas.drawCircle(x, inner.bottom - (1.8f * scale), 0.9f * scale, perforation)
                }
                canvas.drawText("TAKE", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.90f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_photographer" -> {
                val g = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.46f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1f * scale
                }
                val c = 8f * scale
                canvas.drawLine(inner.left, inner.top + c, inner.left, inner.top, g)
                canvas.drawLine(inner.left, inner.top, inner.left + c, inner.top, g)
                canvas.drawLine(inner.right - c, inner.top, inner.right, inner.top, g)
                canvas.drawLine(inner.right, inner.top, inner.right, inner.top + c, g)
                canvas.drawLine(inner.left, inner.bottom - c, inner.left, inner.bottom, g)
                canvas.drawLine(inner.left, inner.bottom, inner.left + c, inner.bottom, g)
                canvas.drawLine(inner.right - c, inner.bottom, inner.right, inner.bottom, g)
                canvas.drawLine(inner.right, inner.bottom - c, inner.right, inner.bottom, g)
                canvas.drawText("SHARP", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accuracyHighColor, 0.90f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_presenter" -> {
                repeat(4) { lane ->
                    val y = inner.top + (inner.height() * (0.20f + (lane * 0.20f)))
                    canvas.drawLine(inner.left + (6f * scale), y, inner.right - (6f * scale), y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accent2, 0.14f + (lane * 0.03f))
                        strokeWidth = 1f * scale
                    })
                }
                val livePulse = 0.62f + (0.38f * kotlin.math.abs(kotlin.math.sin((presentationTimeUs / 1000000.0).toFloat() * 3.0f)))
                canvas.drawCircle(inner.left + (10f * scale), inner.centerY(), 2.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, livePulse)
                })
                canvas.drawText("LIVE", inner.left + (16f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.92f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_business_owner" -> {
                repeat(4) { lane ->
                    val y = inner.top + (inner.height() * (0.22f + (lane * 0.20f)))
                    canvas.drawLine(inner.left + (6f * scale), y, inner.right - (6f * scale), y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accent1, 0.16f + (lane * 0.04f))
                        strokeWidth = 1f * scale
                    })
                }
                repeat(5) { p ->
                    val x = inner.left + (inner.width() * (0.14f + (p * 0.17f)))
                    val y = inner.bottom - (inner.height() * (0.14f + (p * 0.12f)))
                    canvas.drawCircle(x, y, 1.7f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accent1, 0.84f) })
                }
                canvas.drawText("ON TRACK", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accent2, 0.9f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_gym_trainer" -> {
                val pulse = 0.5f + (0.5f * kotlin.math.abs(kotlin.math.sin((presentationTimeUs / 1000000.0).toFloat() * 4.6f)))
                repeat(5) { idx ->
                    val x = inner.left + (inner.width() * (0.18f + (idx * 0.16f)))
                    val h = inner.height() * (0.28f + (idx % 2) * 0.26f)
                    canvas.drawRoundRect(
                        RectF(x - (2.0f * scale), inner.bottom - h, x + (2.0f * scale), inner.bottom - (2f * scale)),
                        2f * scale,
                        2f * scale,
                        Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accuracyHighColor, 0.45f + (0.45f * pulse)) },
                    )
                }
                canvas.drawText("FORM", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.92f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_swimmer" -> {
                repeat(3) { row ->
                    val y = inner.top + (inner.height() * (0.30f + (row * 0.20f)))
                    val wave = Path().apply {
                        moveTo(inner.left + (4f * scale), y)
                        cubicTo(inner.left + (inner.width() * 0.28f), y - (2.4f * scale), inner.left + (inner.width() * 0.64f), y + (2.4f * scale), inner.right - (4f * scale), y)
                    }
                    canvas.drawPath(wave, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.22f + (row * 0.10f))
                        style = Paint.Style.STROKE
                        strokeWidth = 1.0f * scale
                    })
                }
                canvas.drawText("FLOW", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.92f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_psychologist" -> {
                val calmPulse = 0.45f + (0.55f * kotlin.math.abs(kotlin.math.sin((presentationTimeUs / 1000000.0).toFloat() * 1.8f)))
                canvas.drawCircle(inner.left + (10f * scale), inner.centerY(), 2.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, calmPulse)
                })
                canvas.drawLine(inner.left + (16f * scale), inner.centerY(), inner.right - (8f * scale), inner.centerY(), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.24f)
                    strokeWidth = 1f * scale
                })
                canvas.drawText("MINDFUL", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accent1, 0.9f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_philosopher" -> {
                repeat(4) { i ->
                    val x = inner.left + (inner.width() * (0.18f + (i * 0.2f)))
                    canvas.drawLine(x, inner.top + (3f * scale), x, inner.bottom - (3f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accent1, 0.14f + (i * 0.04f))
                        strokeWidth = 0.9f * scale
                    })
                }
                canvas.drawText("TRUTH", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.9f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
                })
            }
            "profession_manager" -> {
                repeat(4) { lane ->
                    val y = inner.top + (inner.height() * (0.24f + (lane * 0.19f)))
                    canvas.drawLine(inner.left + (6f * scale), y, inner.right - (6f * scale), y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accent2, 0.16f + (lane * 0.03f))
                        strokeWidth = 1f * scale
                    })
                }
                repeat(5) { node ->
                    val x = inner.left + (inner.width() * (0.14f + (node * 0.18f)))
                    val y = inner.top + (inner.height() * (0.22f + ((node % 2) * 0.20f)))
                    canvas.drawCircle(x, y, 1.7f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accuracyMidColor, 0.86f) })
                }
                canvas.drawText("ON TRACK", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accent1, 0.88f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_director" -> {
                repeat(8) { i ->
                    val x = inner.left + (inner.width() * i / 7f)
                    canvas.drawCircle(x, inner.top + (1.8f * scale), 0.85f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.30f) })
                    canvas.drawCircle(x, inner.bottom - (1.8f * scale), 0.85f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.30f) })
                }
                val beamX = inner.left + (inner.width() * (((presentationTimeUs / 1000L) % 2200L).toFloat() / 2200f))
                canvas.drawRect(beamX - (8f * scale), inner.top, beamX + (8f * scale), inner.bottom, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(beamX - (8f * scale), inner.top, beamX + (8f * scale), inner.bottom, intArrayOf(Color.TRANSPARENT, adjustAlpha(theme.accent1, 0.34f), Color.TRANSPARENT), floatArrayOf(0f, 0.5f, 1f), Shader.TileMode.CLAMP)
                })
                canvas.drawText("SYNCED", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.90f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_cgd" -> {
                repeat(5) { g ->
                    val x = inner.left + (inner.width() * g / 4f)
                    canvas.drawLine(x, inner.top, x, inner.bottom, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.13f)
                        strokeWidth = 0.9f * scale
                    })
                }
                repeat(3) { g ->
                    val y = inner.top + (inner.height() * (g + 1) / 4f)
                    canvas.drawLine(inner.left, y, inner.right, y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyMidColor, 0.12f)
                        strokeWidth = 0.9f * scale
                    })
                }
                repeat(4) { p ->
                    val x = inner.left + (inner.width() * (0.16f + (p * 0.2f)))
                    val y = inner.top + (inner.height() * (0.72f - (p * 0.16f)))
                    canvas.drawCircle(x, y, 1.5f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accuracyHighColor, 0.9f) })
                }
                canvas.drawText("RENDER", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accuracyHighColor, 0.9f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_it_engineer" -> {
                repeat(4) { lane ->
                    val y = inner.top + (inner.height() * (0.22f + (lane * 0.21f)))
                    val p = Path().apply {
                        moveTo(inner.left + (6f * scale), y)
                        lineTo(inner.left + (inner.width() * 0.28f), y)
                        lineTo(inner.left + (inner.width() * 0.28f), y + (2.6f * scale))
                        lineTo(inner.left + (inner.width() * 0.62f), y + (2.6f * scale))
                        lineTo(inner.left + (inner.width() * 0.62f), y)
                        lineTo(inner.right - (6f * scale), y)
                    }
                    canvas.drawPath(p, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.22f + (lane * 0.06f))
                        style = Paint.Style.STROKE
                        strokeWidth = 1f * scale
                    })
                }
                canvas.drawText("SECURE", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.9f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_musician" -> {
                repeat(5) { lane ->
                    val y = inner.top + (inner.height() * (0.18f + (lane * 0.16f)))
                    val h = inner.height() * (0.12f + ((lane % 3) * 0.14f))
                    canvas.drawRoundRect(
                        RectF(inner.left + (inner.width() * (0.12f + (lane * 0.16f))), y, inner.left + (inner.width() * (0.12f + (lane * 0.16f))) + (4f * scale), y + h),
                        2f * scale,
                        2f * scale,
                        Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accuracyHighColor, 0.44f + (lane * 0.08f)) },
                    )
                }
                canvas.drawText("TEMPO", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyMidColor, 0.92f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_writer" -> {
                repeat(4) { line ->
                    val y = inner.top + (inner.height() * (0.22f + (line * 0.2f)))
                    canvas.drawLine(inner.left + (6f * scale), y, inner.right - (6f * scale), y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accent2, 0.16f + (line * 0.04f))
                        strokeWidth = 0.95f * scale
                    })
                }
                canvas.drawText("DRAFT", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.90f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
                })
            }
            "profession_game_streamer" -> {
                repeat(4) { lane ->
                    val y = inner.top + (inner.height() * (0.20f + (lane * 0.2f)))
                    val zig = Path().apply {
                        moveTo(inner.left + (6f * scale), y)
                        lineTo(inner.left + (inner.width() * 0.24f), y)
                        lineTo(inner.left + (inner.width() * 0.24f), y + (2.4f * scale))
                        lineTo(inner.left + (inner.width() * 0.54f), y + (2.4f * scale))
                        lineTo(inner.left + (inner.width() * 0.54f), y)
                        lineTo(inner.right - (6f * scale), y)
                    }
                    canvas.drawPath(zig, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.20f + (lane * 0.08f))
                        style = Paint.Style.STROKE
                        strokeWidth = 1f * scale
                    })
                }
                canvas.drawText("LIVE", inner.left + (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.95f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
            "profession_social_media_influencer" -> {
                val pulse = 0.58f + (0.42f * kotlin.math.abs(kotlin.math.sin((presentationTimeUs / 1000000.0).toFloat() * 2.8f)))
                repeat(5) { node ->
                    val x = inner.left + (inner.width() * (0.14f + (node * 0.18f)))
                    val y = inner.bottom - (inner.height() * (0.18f + (node * 0.12f)))
                    canvas.drawCircle(x, y, 1.9f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyMidColor, (0.36f + (node * 0.1f)) * pulse)
                    })
                }
                canvas.drawText("TRENDING", inner.right - (8f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    textAlign = Paint.Align.RIGHT
                    color = adjustAlpha(theme.accuracyHighColor, 0.9f)
                    textSize = max(8f, 8f * scale)
                    typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
                })
            }
        }

        canvas.drawText("${(safeAccuracy * 100f).roundToInt()}%", inner.right - (10f * scale), inner.centerY() + (4f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(244, 255, 255, 255)
            textAlign = Paint.Align.RIGHT
            textSize = max(10f, 10f * scale)
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
        })
    }

    private fun drawProfessionSignatureRepCounter(
        canvas: Canvas,
        rect: RectF,
        repCount: Int,
        scale: Float,
        phase: String,
        theme: WorldFestivalTheme,
        key: String,
    ) {
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = rect.width() / 2f
        val phaseColor = when (phase) {
            "down" -> theme.phaseDownColor
            "hold" -> theme.phaseHoldColor
            else -> theme.phaseUpColor
        }

        when (key) {
            "profession_lawyer" -> {
                val sealRect = RectF(rect.left + (8f * scale), rect.top + (8f * scale), rect.right - (8f * scale), rect.bottom - (8f * scale))
                canvas.drawRoundRect(sealRect, 14f * scale, 14f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(sealRect.left, sealRect.top, sealRect.right, sealRect.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(sealRect, 14f * scale, 14f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.82f)
                    style = Paint.Style.STROKE
                    strokeWidth = 2f * scale
                })
                canvas.drawLine(sealRect.left + (10f * scale), sealRect.top + (14f * scale), sealRect.right - (10f * scale), sealRect.top + (14f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.28f)
                    strokeWidth = 1f * scale
                })
            }
            "profession_business_coach" -> {
                val hex = Path().apply {
                    moveTo(centerX, rect.top + (6f * scale))
                    lineTo(rect.right - (8f * scale), rect.top + (24f * scale))
                    lineTo(rect.right - (8f * scale), rect.bottom - (24f * scale))
                    lineTo(centerX, rect.bottom - (6f * scale))
                    lineTo(rect.left + (8f * scale), rect.bottom - (24f * scale))
                    lineTo(rect.left + (8f * scale), rect.top + (24f * scale))
                    close()
                }
                canvas.drawPath(hex, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(rect.left, rect.top, rect.right, rect.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawPath(hex, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.84f)
                    style = Paint.Style.STROKE
                    strokeWidth = 2f * scale
                })
                val trend = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.82f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.4f * scale
                }
                canvas.drawLine(rect.left + (22f * scale), rect.bottom - (24f * scale), rect.left + (32f * scale), rect.bottom - (30f * scale), trend)
                canvas.drawLine(rect.left + (32f * scale), rect.bottom - (30f * scale), rect.left + (42f * scale), rect.bottom - (20f * scale), trend)
                canvas.drawLine(rect.left + (42f * scale), rect.bottom - (20f * scale), rect.left + (54f * scale), rect.bottom - (34f * scale), trend)
            }
            "profession_fashion_model" -> {
                val jewelRect = RectF(rect).apply { inset(6f * scale, 8f * scale) }
                canvas.drawOval(jewelRect, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = RadialGradient(centerX, centerY, radius, intArrayOf(adjustAlpha(theme.primaryEnd, 0.98f), adjustAlpha(theme.primaryStart, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawOval(jewelRect, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.88f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.8f * scale
                })
                canvas.drawCircle(centerX, rect.top + (14f * scale), 2.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accent2, 0.86f) })
            }
            "profession_actor" -> {
                val plaque = RectF(rect.left + (7f * scale), rect.top + (10f * scale), rect.right - (7f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(plaque, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(plaque.left, plaque.top, plaque.right, plaque.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(plaque, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.82f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.8f * scale
                })
                repeat(8) { i ->
                    val y = plaque.top + (plaque.height() * i / 7f)
                    canvas.drawCircle(plaque.left + (2.5f * scale), y, 0.85f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.36f) })
                    canvas.drawCircle(plaque.right - (2.5f * scale), y, 0.85f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.36f) })
                }
            }
            "profession_photographer" -> {
                canvas.drawCircle(centerX, centerY, radius - (8f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = RadialGradient(centerX, centerY, radius, intArrayOf(adjustAlpha(theme.primaryEnd, 0.98f), adjustAlpha(theme.primaryStart, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawCircle(centerX, centerY, radius - (8f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.72f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.8f * scale
                })
                repeat(6) { idx ->
                    val angle = Math.toRadians((idx * 60.0) + 20.0)
                    val x = centerX + (cos(angle).toFloat() * (radius - (18f * scale)))
                    val y = centerY + (sin(angle).toFloat() * (radius - (18f * scale)))
                    canvas.drawCircle(x, y, 1.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accent1, 0.58f) })
                }
            }
            "profession_presenter" -> {
                val badge = RectF(rect.left + (9f * scale), rect.top + (12f * scale), rect.right - (9f * scale), rect.bottom - (12f * scale))
                canvas.drawRoundRect(badge, 12f * scale, 12f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(badge.left, badge.top, badge.right, badge.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(badge, 12f * scale, 12f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.84f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.8f * scale
                })
                canvas.drawCircle(badge.left + (10f * scale), badge.centerY(), 2.3f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.90f)
                })
            }
            "profession_business_owner" -> {
                val panel = RectF(rect.left + (7f * scale), rect.top + (10f * scale), rect.right - (7f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(panel, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(panel.left, panel.top, panel.right, panel.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(panel, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.84f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.9f * scale
                })
                canvas.drawLine(panel.left + (10f * scale), panel.bottom - (10f * scale), panel.right - (10f * scale), panel.top + (10f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.52f)
                    strokeWidth = 1.2f * scale
                })
            }
            "profession_gym_trainer" -> {
                canvas.drawCircle(centerX, centerY, radius - (8f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = RadialGradient(centerX, centerY, radius, intArrayOf(adjustAlpha(theme.primaryEnd, 0.98f), adjustAlpha(theme.primaryStart, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                repeat(12) { i ->
                    val angle = Math.toRadians((i * 30.0) - 90.0)
                    val x1 = centerX + cos(angle).toFloat() * (radius - (8f * scale))
                    val y1 = centerY + sin(angle).toFloat() * (radius - (8f * scale))
                    val x2 = centerX + cos(angle).toFloat() * (radius - (14f * scale))
                    val y2 = centerY + sin(angle).toFloat() * (radius - (14f * scale))
                    canvas.drawLine(x1, y1, x2, y2, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.7f)
                        strokeWidth = 1.1f * scale
                    })
                }
            }
            "profession_swimmer" -> {
                val capsule = RectF(rect.left + (8f * scale), rect.top + (12f * scale), rect.right - (8f * scale), rect.bottom - (12f * scale))
                canvas.drawRoundRect(capsule, capsule.height() / 2f, capsule.height() / 2f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(capsule.left, capsule.top, capsule.right, capsule.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.96f), adjustAlpha(theme.primaryEnd, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                repeat(3) { row ->
                    val y = capsule.top + (capsule.height() * (0.28f + (row * 0.22f)))
                    val wave = Path().apply {
                        moveTo(capsule.left + (8f * scale), y)
                        cubicTo(capsule.left + (capsule.width() * 0.3f), y - (2f * scale), capsule.left + (capsule.width() * 0.7f), y + (2f * scale), capsule.right - (8f * scale), y)
                    }
                    canvas.drawPath(wave, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.30f + (row * 0.08f))
                        style = Paint.Style.STROKE
                        strokeWidth = 1f * scale
                    })
                }
            }
            "profession_psychologist" -> {
                val shell = RectF(rect.left + (9f * scale), rect.top + (9f * scale), rect.right - (9f * scale), rect.bottom - (9f * scale))
                canvas.drawRoundRect(shell, 14f * scale, 14f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(shell.left, shell.top, shell.right, shell.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.96f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(shell, 14f * scale, 14f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent2, 0.72f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.6f * scale
                })
                canvas.drawCircle(centerX - (8f * scale), centerY, 3.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accent2, 0.36f) })
                canvas.drawCircle(centerX + (8f * scale), centerY, 3.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(theme.accuracyHighColor, 0.32f) })
            }
            "profession_philosopher" -> {
                val oct = Path().apply {
                    moveTo(centerX, rect.top + (8f * scale))
                    lineTo(rect.right - (14f * scale), rect.top + (14f * scale))
                    lineTo(rect.right - (8f * scale), centerY)
                    lineTo(rect.right - (14f * scale), rect.bottom - (14f * scale))
                    lineTo(centerX, rect.bottom - (8f * scale))
                    lineTo(rect.left + (14f * scale), rect.bottom - (14f * scale))
                    lineTo(rect.left + (8f * scale), centerY)
                    lineTo(rect.left + (14f * scale), rect.top + (14f * scale))
                    close()
                }
                canvas.drawPath(oct, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(rect.left, rect.top, rect.right, rect.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.97f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawPath(oct, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.82f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.7f * scale
                })
            }
            "profession_manager" -> {
                val panel = RectF(rect.left + (7f * scale), rect.top + (10f * scale), rect.right - (7f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(panel, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(panel.left, panel.top, panel.right, panel.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(panel, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyMidColor, 0.84f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.8f * scale
                })
            }
            "profession_director" -> {
                val plaque = RectF(rect.left + (7f * scale), rect.top + (10f * scale), rect.right - (7f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(plaque, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(plaque.left, plaque.top, plaque.right, plaque.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(plaque, 10f * scale, 10f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accent1, 0.86f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.9f * scale
                })
                repeat(8) { i ->
                    val y = plaque.top + (plaque.height() * i / 7f)
                    canvas.drawCircle(plaque.left + (2.3f * scale), y, 0.8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.32f) })
                    canvas.drawCircle(plaque.right - (2.3f * scale), y, 0.8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply { color = adjustAlpha(Color.WHITE, 0.32f) })
                }
            }
            "profession_cgd" -> {
                val artboard = RectF(rect.left + (8f * scale), rect.top + (8f * scale), rect.right - (8f * scale), rect.bottom - (8f * scale))
                canvas.drawRoundRect(artboard, 8f * scale, 8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(artboard.left, artboard.top, artboard.right, artboard.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.97f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(artboard, 8f * scale, 8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.86f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.7f * scale
                })
                canvas.drawLine(artboard.left, artboard.centerY(), artboard.right, artboard.centerY(), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyMidColor, 0.28f)
                    strokeWidth = 1f * scale
                })
                canvas.drawLine(artboard.centerX(), artboard.top, artboard.centerX(), artboard.bottom, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.28f)
                    strokeWidth = 1f * scale
                })
            }
            "profession_it_engineer" -> {
                val term = RectF(rect.left + (8f * scale), rect.top + (10f * scale), rect.right - (8f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(term, 6f * scale, 6f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(term.left, term.top, term.right, term.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(term, 6f * scale, 6f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.82f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.7f * scale
                })
                repeat(3) { i ->
                    val y = term.top + (term.height() * (0.28f + (i * 0.22f)))
                    canvas.drawLine(term.left + (8f * scale), y, term.right - (8f * scale), y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.24f + (i * 0.10f))
                        strokeWidth = 1f * scale
                    })
                }
            }
            "profession_musician" -> {
                canvas.drawCircle(centerX, centerY, radius - (8f * scale), Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = RadialGradient(centerX, centerY, radius, intArrayOf(adjustAlpha(theme.primaryEnd, 0.98f), adjustAlpha(theme.primaryStart, 0.98f)), null, Shader.TileMode.CLAMP)
                })
                repeat(10) { i ->
                    val x = rect.left + (rect.width() * (0.1f + (i * 0.08f)))
                    val h = rect.height() * (0.06f + ((i % 4) * 0.06f))
                    canvas.drawRoundRect(RectF(x, centerY - h, x + (2f * scale), centerY + h), 1f * scale, 1f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.54f)
                    })
                }
            }
            "profession_writer" -> {
                val plaque = RectF(rect.left + (7f * scale), rect.top + (10f * scale), rect.right - (7f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(plaque, 8f * scale, 8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(plaque.left, plaque.top, plaque.right, plaque.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(plaque, 8f * scale, 8f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyMidColor, 0.82f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.5f * scale
                })
                repeat(3) { r ->
                    val y = plaque.top + (plaque.height() * (0.28f + (r * 0.2f)))
                    canvas.drawLine(plaque.left + (8f * scale), y, plaque.right - (8f * scale), y, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        color = adjustAlpha(theme.accuracyHighColor, 0.20f + (r * 0.08f))
                        strokeWidth = 0.9f * scale
                    })
                }
            }
            "profession_game_streamer" -> {
                val hex = Path().apply {
                    moveTo(centerX, rect.top + (8f * scale))
                    lineTo(rect.right - (10f * scale), rect.top + (20f * scale))
                    lineTo(rect.right - (10f * scale), rect.bottom - (20f * scale))
                    lineTo(centerX, rect.bottom - (8f * scale))
                    lineTo(rect.left + (10f * scale), rect.bottom - (20f * scale))
                    lineTo(rect.left + (10f * scale), rect.top + (20f * scale))
                    close()
                }
                canvas.drawPath(hex, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(rect.left, rect.top, rect.right, rect.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawPath(hex, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.88f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.8f * scale
                })
            }
            "profession_social_media_influencer" -> {
                val badge = RectF(rect.left + (8f * scale), rect.top + (10f * scale), rect.right - (8f * scale), rect.bottom - (10f * scale))
                canvas.drawRoundRect(badge, 12f * scale, 12f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    shader = LinearGradient(badge.left, badge.top, badge.right, badge.bottom, intArrayOf(adjustAlpha(theme.primaryStart, 0.98f), adjustAlpha(theme.primaryEnd, 0.96f)), null, Shader.TileMode.CLAMP)
                })
                canvas.drawRoundRect(badge, 12f * scale, 12f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyMidColor, 0.86f)
                    style = Paint.Style.STROKE
                    strokeWidth = 1.7f * scale
                })
                canvas.drawCircle(badge.right - (10f * scale), badge.top + (10f * scale), 2.2f * scale, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(theme.accuracyHighColor, 0.86f)
                })
            }
        }

        val repsPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            textSize = max(34f * scale, rect.width() * 0.34f)
            setShadowLayer(4f * scale, 0f, 1.8f * scale, adjustAlpha(phaseColor, 0.40f))
        }
        drawCenteredText(canvas, repCount.toString(), centerX, centerY, repsPaint)
    }

    private fun getZodiacRepPath(signKey: String, cx: Float, cy: Float, rawR: Float): Path {
        val p = Path()
        val r = rawR * 1.05f 
        when (signKey) {
            "aries" -> {
                p.moveTo(cx, cy - r * 0.9f)
                p.quadTo(cx - r * 1.1f, cy - r * 1.1f, cx - r * 0.9f, cy)
                p.quadTo(cx - r * 0.8f, cy + r, cx, cy + r)
                p.quadTo(cx + r * 0.8f, cy + r, cx + r * 0.9f, cy)
                p.quadTo(cx + r * 1.1f, cy - r * 1.1f, cx, cy - r * 0.9f)
            }
            "taurus" -> {
                p.moveTo(cx - r * 0.8f, cy - r * 0.8f)
                p.lineTo(cx + r * 0.8f, cy - r * 0.8f)
                p.quadTo(cx + r * 1.2f, cy + r * 0.2f, cx + r * 0.5f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.5f, cy + r * 0.9f)
                p.quadTo(cx - r * 1.2f, cy + r * 0.2f, cx - r * 0.8f, cy - r * 0.8f)
            }
            "gemini" -> {
                p.moveTo(cx - r * 0.7f, cy - r * 0.9f)
                p.lineTo(cx + r * 0.7f, cy - r * 0.9f)
                p.lineTo(cx + r * 0.9f, cy - r * 0.7f)
                p.lineTo(cx + r * 0.9f, cy + r * 0.7f)
                p.lineTo(cx + r * 0.7f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.7f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.9f, cy + r * 0.7f)
                p.lineTo(cx - r * 0.9f, cy - r * 0.7f)
                p.close()
            }
            "cancer" -> {
                p.moveTo(cx - r * 0.8f, cy - r * 0.2f)
                p.cubicTo(cx - r * 0.8f, cy - r * 1.5f, cx + r * 0.8f, cy - r * 1.5f, cx + r * 0.8f, cy - r * 0.2f)
                p.cubicTo(cx + r * 0.8f, cy + r * 1.2f, cx - r * 0.8f, cy + r * 1.2f, cx - r * 0.8f, cy - r * 0.2f)
            }
            "leo" -> {
                var angle = -Math.PI / 2
                val spikes = 8
                for (i in 0 until spikes * 2) {
                    val distance = if (i % 2 == 0) r * 1.05f else r * 0.75f
                    val x = cx + kotlin.math.cos(angle).toFloat() * distance
                    val y = cy + kotlin.math.sin(angle).toFloat() * distance
                    if (i == 0) p.moveTo(x, y) else p.lineTo(x, y)
                    angle += Math.PI / spikes
                }
                p.close()
            }
            "virgo" -> {
                p.moveTo(cx, cy - r * 1.05f)
                p.quadTo(cx + r * 0.4f, cy - r * 0.4f, cx + r * 1.05f, cy)
                p.quadTo(cx + r * 0.4f, cy + r * 0.4f, cx, cy + r * 1.05f)
                p.quadTo(cx - r * 0.4f, cy + r * 0.4f, cx - r * 1.05f, cy)
                p.quadTo(cx - r * 0.4f, cy - r * 0.4f, cx, cy - r * 1.05f)
            }
            "libra" -> {
                p.moveTo(cx - r * 0.8f, cy - r * 0.6f)
                p.lineTo(cx + r * 0.8f, cy - r * 0.6f)
                p.lineTo(cx + r * 1.0f, cy + r * 0.1f)
                p.lineTo(cx + r * 0.8f, cy + r * 0.8f)
                p.lineTo(cx - r * 0.8f, cy + r * 0.8f)
                p.lineTo(cx - r * 1.0f, cy + r * 0.1f)
                p.close()
            }
            "scorpio" -> {
                p.moveTo(cx, cy - r * 0.9f)
                p.cubicTo(cx + r * 1.2f, cy - r * 0.9f, cx + r * 1.2f, cy + r * 0.4f, cx, cy + r * 1.1f)
                p.cubicTo(cx - r * 1.2f, cy + r * 0.4f, cx - r * 1.2f, cy - r * 0.9f, cx, cy - r * 0.9f)
            }
            "sagittarius" -> {
                p.moveTo(cx, cy - r * 1.1f)
                p.lineTo(cx + r * 0.8f, cy - r * 0.3f)
                p.lineTo(cx + r * 0.6f, cy + r * 0.9f)
                p.lineTo(cx, cy + r * 1.1f)
                p.lineTo(cx - r * 0.6f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.8f, cy - r * 0.3f)
                p.close()
            }
            "capricorn" -> {
                p.moveTo(cx, cy - r * 1.1f)
                p.lineTo(cx + r * 0.9f, cy - r * 0.4f)
                p.lineTo(cx + r * 0.7f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.7f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.9f, cy - r * 0.4f)
                p.close()
            }
            "aquarius" -> {
                p.moveTo(cx - r * 0.6f, cy - r * 0.9f)
                p.lineTo(cx + r * 0.6f, cy - r * 0.9f)
                p.quadTo(cx + r * 1.1f, cy + r * 0.2f, cx + r * 0.4f, cy + r * 0.9f)
                p.lineTo(cx - r * 0.4f, cy + r * 0.9f)
                p.quadTo(cx - r * 1.1f, cy + r * 0.2f, cx - r * 0.6f, cy - r * 0.9f)
            }
            "pisces" -> {
                p.addOval(RectF(cx - r * 0.95f, cy - r * 0.85f, cx + r * 0.95f, cy + r * 0.85f), Path.Direction.CW)
            }
            else -> {
                p.addCircle(cx, cy, r, Path.Direction.CW)
            }
        }
        return p
    }

    private fun getScaledZodiacRepPath(basePath: Path, cx: Float, cy: Float, scaleFactor: Float): Path {
        val scaled = Path()
        val m = android.graphics.Matrix()
        m.postScale(scaleFactor, scaleFactor, cx, cy)
        basePath.transform(m, scaled)
        return scaled
    }

    private fun drawZodiacRepCoin(
        canvas: Canvas,
        rect: RectF,
        repCount: Int,
        scale: Float,
        pulse: Float,
        presentationTimeUs: Long,
        theme: ZodiacTheme,
    ) {
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = rect.width() / 2f
        
        val basePath = getZodiacRepPath(theme.signKey, centerX, centerY, radius)
        val glowPath = getScaledZodiacRepPath(basePath, centerX, centerY, (radius + (5f * scale)) / radius)
        val innerPath = getScaledZodiacRepPath(basePath, centerX, centerY, 0.74f)
        val linePath = getScaledZodiacRepPath(basePath, centerX, centerY, (radius - (5f * scale)) / radius)
        
        val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.glowColor, 0.26f + (0.20f * pulse))
            maskFilter = BlurMaskFilter(16f * scale, BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawPath(glowPath, glowPaint)

        val coinPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                centerX - (radius * 0.18f),
                centerY - (radius * 0.24f),
                radius,
                intArrayOf(
                    theme.fillStartColor,
                    theme.fillMidColor,
                    theme.fillEndColor,
                ),
                floatArrayOf(0f, 0.54f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawPath(basePath, coinPaint)
        
        canvas.drawPath(
            innerPath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                shader = RadialGradient(
                    centerX - (radius * 0.14f),
                    centerY - (radius * 0.20f),
                    radius * 0.76f,
                    intArrayOf(
                        Color.argb(92, 255, 255, 255),
                        Color.argb(24, 255, 248, 232),
                        Color.TRANSPARENT,
                    ),
                    floatArrayOf(0f, 0.26f, 1f),
                    Shader.TileMode.CLAMP,
                )
            },
        )

        val auroraAngle = ((presentationTimeUs / 1000L) % 4000L).toFloat() / 4000f * 360f
        val auroraMatrix = android.graphics.Matrix().apply {
            postRotate(auroraAngle, centerX, centerY)
        }
        val auroraPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = android.graphics.SweepGradient(
                centerX,
                centerY,
                intArrayOf(
                    adjustAlpha(theme.glowColor, 0.9f),
                    adjustAlpha(theme.fillStartColor, 0.9f),
                    adjustAlpha(theme.fillMidColor, 0.9f),
                    adjustAlpha(theme.fillEndColor, 0.9f),
                    adjustAlpha(theme.glowColor, 0.9f),
                ),
                floatArrayOf(0f, 0.25f, 0.5f, 0.75f, 1f)
            ).apply { setLocalMatrix(auroraMatrix) }
            style = Paint.Style.STROKE
            strokeWidth = max(2.5f, 2.5f * scale)
        }
        canvas.drawPath(basePath, auroraPaint)
        
        canvas.drawPath(
            linePath,
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(theme.constellationColor, 0.32f)
                style = Paint.Style.STROKE
                strokeWidth = 0.9f * scale
            },
        )
        
        val symbolShadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.engravingColor, 0.42f)
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
            textSize = max(22f, rect.width() * 0.28f)
        }
        drawCenteredText(
            canvas,
            theme.symbol,
            centerX + (0.8f * scale),
            centerY - (radius * 0.32f) + (0.8f * scale),
            symbolShadowPaint,
        )
        val symbolPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.engravingColor, 0.96f)
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.SERIF, Typeface.BOLD)
            textSize = max(22f, rect.width() * 0.28f)
        }
        drawCenteredText(
            canvas,
            theme.symbol,
            centerX,
            centerY - (radius * 0.34f),
            symbolPaint,
        )

        val repsPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.engravingColor, 0.98f)
            textAlign = Paint.Align.CENTER
            typeface = Typeface.create(Typeface.DEFAULT_BOLD, Typeface.BOLD)
            textSize = max(18f, rect.width() * 0.22f)
        }
        drawCenteredText(
            canvas,
            repCount.toString(),
            centerX,
            centerY + (radius * 0.28f),
            repsPaint,
        )

        val sparklePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = adjustAlpha(theme.constellationColor, 0.70f)
            style = Paint.Style.FILL
        }
        repeat(4) { index ->
            val angle = Math.toRadians((-72 + (index * 48)).toDouble())
            val sparkleX = centerX + (kotlin.math.cos(angle).toFloat() * radius * 0.78f)
            val sparkleY = centerY + (kotlin.math.sin(angle).toFloat() * radius * 0.78f)
            canvas.drawCircle(sparkleX, sparkleY, (1.0f + ((index % 2) * 0.35f)) * scale, sparklePaint)
        }
    }

    private fun drawWatermark(
        canvas: Canvas,
        rect: RectF,
    ) {
        val radius = rect.height() / 2f
        canvas.drawRoundRect(rect, radius, radius, watermarkPaint)
        canvas.drawRoundRect(rect, radius, radius, watermarkStrokePaint)

        watermarkTextPaint.textSize = max(12f, rect.width() * 0.18f)
        drawCenteredText(
            canvas = canvas,
            text = "H&F",
            centerX = rect.centerX(),
            centerY = rect.centerY(),
            paint = watermarkTextPaint,
        )
    }

    private fun drawCenteredText(
        canvas: Canvas,
        text: String,
        centerX: Float,
        centerY: Float,
        paint: Paint,
    ) {
        val metrics = paint.fontMetrics
        val baseline = centerY - ((metrics.ascent + metrics.descent) / 2f)
        canvas.drawText(text, centerX, baseline, paint)
    }

    private fun isPadaukBranchIcon(icon: String?): Boolean = false

    private fun drawPadaukBranch(
        canvas: Canvas,
        rect: RectF,
        alpha: Float,
    ) {
        val safeAlpha = alpha.coerceIn(0f, 1f)
        val width = rect.width()
        val height = rect.height()
        val flowerRadius = min(width, height) * 0.15f

        canvas.drawPath(
            Path().apply {
                moveTo(rect.left + (width * 0.18f), rect.top + (height * 0.84f))
                cubicTo(
                    rect.left + (width * 0.32f),
                    rect.top + (height * 0.72f),
                    rect.left + (width * 0.52f),
                    rect.top + (height * 0.48f),
                    rect.left + (width * 0.78f),
                    rect.top + (height * 0.24f),
                )
            },
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(Color.rgb(106, 74, 43), 0.92f * safeAlpha)
                style = Paint.Style.STROKE
                strokeCap = Paint.Cap.ROUND
                strokeWidth = max(1.4f, min(width, height) * 0.08f)
            },
        )

        fun drawLeaf(centerX: Float, centerY: Float, scale: Float, rotation: Float) {
            canvas.save()
            canvas.translate(centerX, centerY)
            canvas.rotate(rotation)
            canvas.drawPath(
                Path().apply {
                    moveTo(0f, 0f)
                    cubicTo(width * 0.04f * scale, -height * 0.04f * scale, width * 0.10f * scale, -height * 0.02f * scale, width * 0.13f * scale, 0f)
                    cubicTo(width * 0.10f * scale, height * 0.04f * scale, width * 0.04f * scale, height * 0.04f * scale, 0f, height * 0.02f * scale)
                    cubicTo(-width * 0.03f * scale, height * 0.01f * scale, -width * 0.03f * scale, -height * 0.01f * scale, 0f, 0f)
                },
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(Color.rgb(107, 146, 86), 0.88f * safeAlpha)
                },
            )
            canvas.restore()
        }

        fun drawFlower(centerX: Float, centerY: Float, radius: Float) {
            canvas.drawCircle(
                centerX,
                centerY,
                radius * 1.12f,
                Paint(Paint.ANTI_ALIAS_FLAG).apply {
                    color = adjustAlpha(Color.rgb(244, 197, 66), 0.26f * safeAlpha)
                    maskFilter = BlurMaskFilter(radius * 0.6f, BlurMaskFilter.Blur.NORMAL)
                },
            )
            repeat(5) { index ->
                val angle = (-Math.PI / 2.0) + ((Math.PI * 2.0 / 5.0) * index)
                val petalCenterX = centerX + (kotlin.math.cos(angle).toFloat() * radius * 0.64f)
                val petalCenterY = centerY + (kotlin.math.sin(angle).toFloat() * radius * 0.64f)
                canvas.save()
                canvas.translate(petalCenterX, petalCenterY)
                canvas.rotate(Math.toDegrees(angle).toFloat())
                canvas.drawOval(
                    RectF(-radius * 0.42f, -radius * 0.62f, radius * 0.42f, radius * 0.62f),
                    Paint(Paint.ANTI_ALIAS_FLAG).apply {
                        shader = RadialGradient(
                            0f,
                            0f,
                            radius,
                            intArrayOf(
                                adjustAlpha(Color.rgb(255, 224, 92), 0.98f * safeAlpha),
                                adjustAlpha(Color.rgb(244, 197, 66), 0.92f * safeAlpha),
                                adjustAlpha(Color.rgb(226, 170, 42), 0.78f * safeAlpha),
                            ),
                            floatArrayOf(0f, 0.62f, 1f),
                            Shader.TileMode.CLAMP,
                        )
                    },
                )
                canvas.restore()
            }
            canvas.drawCircle(centerX, centerY, radius * 0.26f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(Color.rgb(255, 241, 168), safeAlpha)
            })
            canvas.drawCircle(centerX, centerY, radius * 0.14f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
                color = adjustAlpha(Color.rgb(179, 122, 18), 0.96f * safeAlpha)
            })
        }

        drawLeaf(rect.left + (width * 0.36f), rect.top + (height * 0.68f), 1f, -18f)
        drawLeaf(rect.left + (width * 0.57f), rect.top + (height * 0.48f), 0.88f, 34f)
        drawLeaf(rect.left + (width * 0.66f), rect.top + (height * 0.36f), 0.76f, -36f)
        drawFlower(rect.left + (width * 0.58f), rect.top + (height * 0.46f), flowerRadius)
        drawFlower(rect.left + (width * 0.72f), rect.top + (height * 0.29f), flowerRadius * 0.74f)
        drawFlower(rect.left + (width * 0.42f), rect.top + (height * 0.60f), flowerRadius * 0.68f)
    }

    private fun buildCustomCounterShapePath(
        rect: RectF,
        shape: String,
        softness: Float,
    ): Path {
        val safeSoftness = softness.coerceIn(0f, 1f)
        return when (shape) {
            "hex" -> buildRoundedPolygonPath(rect, 6, safeSoftness)
            "diamond" -> buildRoundedDiamondPath(rect, safeSoftness)
            "shield" -> buildShieldPath(rect, safeSoftness)
            "flower" -> buildFlowerPath(rect, safeSoftness)
            else -> Path().apply { addOval(rect, Path.Direction.CW) }
        }
    }

    private fun buildRoundedPolygonPath(
        rect: RectF,
        sides: Int,
        softness: Float,
    ): Path {
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = min(rect.width(), rect.height()) / 2f
        val points = (0 until sides).map { index ->
            val angle = (-Math.PI / 2.0) + ((Math.PI * 2.0 * index) / sides.toDouble())
            android.graphics.PointF(
                centerX + (kotlin.math.cos(angle).toFloat() * radius),
                centerY + (sin(angle).toFloat() * radius),
            )
        }
        return buildRoundedPointsPath(points, min(rect.width(), rect.height()) * (0.04f + (0.10f * softness)))
    }

    private fun buildRoundedDiamondPath(rect: RectF, softness: Float): Path {
        val points = listOf(
            android.graphics.PointF(rect.centerX(), rect.top),
            android.graphics.PointF(rect.right, rect.centerY()),
            android.graphics.PointF(rect.centerX(), rect.bottom),
            android.graphics.PointF(rect.left, rect.centerY()),
        )
        return buildRoundedPointsPath(points, min(rect.width(), rect.height()) * (0.06f + (0.12f * softness)))
    }

    private fun buildShieldPath(rect: RectF, softness: Float): Path {
        val radius = min(rect.width(), rect.height()) * (0.10f + (0.12f * softness))
        return Path().apply {
            moveTo(rect.left + radius, rect.top + (rect.height() * 0.10f))
            quadTo(rect.left, rect.top + (rect.height() * 0.10f), rect.left, rect.top + radius)
            lineTo(rect.left, rect.centerY())
            quadTo(rect.left, rect.bottom - (rect.height() * 0.18f), rect.centerX(), rect.bottom)
            quadTo(rect.right, rect.bottom - (rect.height() * 0.18f), rect.right, rect.centerY())
            lineTo(rect.right, rect.top + radius)
            quadTo(rect.right, rect.top + (rect.height() * 0.10f), rect.right - radius, rect.top + (rect.height() * 0.10f))
            close()
        }
    }

    private fun buildFlowerPath(rect: RectF, softness: Float): Path {
        val centerX = rect.centerX()
        val centerY = rect.centerY()
        val radius = min(rect.width(), rect.height()) / 2f
        val inner = radius * (0.68f - (0.10f * softness))
        val petals = 6
        val points = (0 until petals * 2).map { index ->
            val isOuter = index % 2 == 0
            val angle = (-Math.PI / 2.0) + ((Math.PI * index) / petals.toDouble())
            val distance = if (isOuter) radius else inner
            android.graphics.PointF(
                centerX + (kotlin.math.cos(angle).toFloat() * distance),
                centerY + (sin(angle).toFloat() * distance),
            )
        }
        return buildRoundedPointsPath(points, min(rect.width(), rect.height()) * (0.04f + (0.09f * softness)))
    }

    private fun buildRoundedPointsPath(
        points: List<android.graphics.PointF>,
        radius: Float,
    ): Path {
        if (points.size < 3) {
            return Path().apply {
                points.forEachIndexed { index, point ->
                    if (index == 0) moveTo(point.x, point.y) else lineTo(point.x, point.y)
                }
                close()
            }
        }
        return Path().apply {
            points.forEachIndexed { index, current ->
                val previous = points[(index - 1 + points.size) % points.size]
                val next = points[(index + 1) % points.size]
                val prevDistance = distanceBetween(previous, current)
                val nextDistance = distanceBetween(current, next)
                val startRatio = if (prevDistance <= 0.0001f) 0f else (radius / prevDistance).coerceIn(0f, 0.45f)
                val endRatio = if (nextDistance <= 0.0001f) 0f else (radius / nextDistance).coerceIn(0f, 0.45f)
                val start = lerpPoint(current, previous, startRatio)
                val end = lerpPoint(current, next, endRatio)
                if (index == 0) {
                    moveTo(start.x, start.y)
                } else {
                    lineTo(start.x, start.y)
                }
                quadTo(current.x, current.y, end.x, end.y)
            }
            close()
        }
    }

    private fun distanceBetween(a: android.graphics.PointF, b: android.graphics.PointF): Float {
        val dx = b.x - a.x
        val dy = b.y - a.y
        return kotlin.math.sqrt((dx * dx) + (dy * dy))
    }

    private fun lerpPoint(
        from: android.graphics.PointF,
        to: android.graphics.PointF,
        factor: Float,
    ): android.graphics.PointF {
        val safeFactor = factor.coerceIn(0f, 1f)
        return android.graphics.PointF(
            from.x + ((to.x - from.x) * safeFactor),
            from.y + ((to.y - from.y) * safeFactor),
        )
    }

    private fun drawWrappedCenteredText(
        canvas: Canvas,
        text: String,
        rect: RectF,
        paint: Paint,
        maxLines: Int,
    ) {
        val lines = wrapTextLines(
            text = text,
            paint = paint,
            maxWidth = rect.width(),
            maxLines = maxLines,
        )
        if (lines.isEmpty()) {
            return
        }
        val metrics = paint.fontMetrics
        val lineHeight = (metrics.descent - metrics.ascent) * 1.08f
        val contentHeight = lineHeight * lines.size
        var baseline = rect.centerY() - (contentHeight / 2f) - metrics.ascent
        lines.forEach { line ->
            canvas.drawText(
                line,
                rect.centerX() - (paint.measureText(line) / 2f),
                baseline,
                paint,
            )
            baseline += lineHeight
        }
    }

    private fun wrapTextLines(
        text: String,
        paint: Paint,
        maxWidth: Float,
        maxLines: Int,
    ): List<String> {
        val normalized = text.trim().replace(Regex("\\s+"), " ")
        if (normalized.isEmpty()) {
            return emptyList()
        }
        val words = normalized.split(" ")
        val lines = mutableListOf<String>()
        var currentLine = StringBuilder()

        for ((index, word) in words.withIndex()) {
            val candidate = if (currentLine.isEmpty()) word else "${currentLine} $word"
            if (paint.measureText(candidate) <= maxWidth || currentLine.isEmpty()) {
                currentLine = StringBuilder(candidate)
                continue
            }

            lines += currentLine.toString()
            if (lines.size == maxLines - 1) {
                val remaining = words.subList(index, words.size).joinToString(" ")
                lines += ellipsizeToWidth(remaining, paint, maxWidth)
                return lines
            }
            currentLine = StringBuilder(word)
        }

        if (currentLine.isNotEmpty() && lines.size < maxLines) {
            lines += currentLine.toString()
        }
        return lines.take(maxLines)
    }

    private fun ellipsizeToWidth(
        text: String,
        paint: Paint,
        maxWidth: Float,
    ): String {
        if (paint.measureText(text) <= maxWidth) {
            return text
        }
        var trimmed = text.trim()
        while (trimmed.isNotEmpty() && paint.measureText("$trimmed…") > maxWidth) {
            trimmed = trimmed.dropLast(1).trimEnd()
        }
        return if (trimmed.isEmpty()) "…" else "$trimmed…"
    }

    private fun drawCircularText(
        canvas: Canvas,
        text: String,
        centerX: Float,
        centerY: Float,
        radius: Float,
        startAngle: Float,
        sweepAngle: Float,
        paint: Paint,
    ) {
        if (text.isEmpty()) return
        val chars = text.toCharArray()
        val step = if (chars.size <= 1) 0f else sweepAngle / (chars.size - 1)
        chars.forEachIndexed { index, char ->
            val angle = Math.toRadians((startAngle + (step * index)).toDouble())
            val x = centerX + (kotlin.math.cos(angle).toFloat() * radius)
            val y = centerY + (kotlin.math.sin(angle).toFloat() * radius)
            canvas.save()
            canvas.rotate((Math.toDegrees(angle) + 90.0).toFloat(), x, y)
            canvas.drawText(char.toString(), x, y, paint)
            canvas.restore()
        }
    }

    private fun constellationPointsFor(signKey: String): List<Pair<Float, Float>> {
        return when (signKey) {
            "taurus" -> listOf(
                0.08f to 0.56f, 0.17f to 0.45f, 0.31f to 0.62f, 0.42f to 0.36f,
                0.55f to 0.47f, 0.67f to 0.31f, 0.82f to 0.50f,
            )
            "gemini" -> listOf(
                0.10f to 0.33f, 0.10f to 0.69f, 0.28f to 0.40f, 0.28f to 0.63f,
                0.50f to 0.34f, 0.50f to 0.66f, 0.74f to 0.45f,
            )
            "cancer" -> listOf(
                0.09f to 0.62f, 0.21f to 0.48f, 0.33f to 0.58f, 0.45f to 0.41f,
                0.59f to 0.52f, 0.73f to 0.37f, 0.84f to 0.46f,
            )
            "leo" -> listOf(
                0.08f to 0.52f, 0.20f to 0.38f, 0.34f to 0.45f, 0.45f to 0.29f,
                0.57f to 0.55f, 0.69f to 0.64f, 0.82f to 0.42f,
            )
            "virgo" -> listOf(
                0.08f to 0.37f, 0.17f to 0.66f, 0.30f to 0.42f, 0.43f to 0.62f,
                0.54f to 0.35f, 0.68f to 0.58f, 0.82f to 0.40f,
            )
            "libra" -> listOf(
                0.08f to 0.59f, 0.22f to 0.40f, 0.34f to 0.40f, 0.46f to 0.60f,
                0.58f to 0.40f, 0.70f to 0.40f, 0.84f to 0.59f,
            )
            "scorpio" -> listOf(
                0.08f to 0.35f, 0.17f to 0.67f, 0.29f to 0.41f, 0.41f to 0.65f,
                0.56f to 0.48f, 0.70f to 0.38f, 0.84f to 0.56f,
            )
            "sagittarius" -> listOf(
                0.10f to 0.66f, 0.22f to 0.48f, 0.34f to 0.36f, 0.48f to 0.54f,
                0.58f to 0.36f, 0.72f to 0.26f, 0.84f to 0.52f,
            )
            "capricorn" -> listOf(
                0.08f to 0.57f, 0.19f to 0.43f, 0.32f to 0.59f, 0.45f to 0.37f,
                0.57f to 0.55f, 0.68f to 0.33f, 0.82f to 0.49f,
            )
            "aquarius" -> listOf(
                0.08f to 0.42f, 0.20f to 0.54f, 0.32f to 0.40f, 0.46f to 0.54f,
                0.58f to 0.38f, 0.72f to 0.52f, 0.84f to 0.40f,
            )
            "pisces" -> listOf(
                0.10f to 0.35f, 0.22f to 0.52f, 0.34f to 0.66f, 0.48f to 0.50f,
                0.60f to 0.35f, 0.72f to 0.52f, 0.84f to 0.66f,
            )
            else -> listOf(
                0.08f to 0.60f, 0.16f to 0.40f, 0.28f to 0.52f, 0.40f to 0.34f,
                0.56f to 0.50f, 0.70f to 0.36f, 0.82f to 0.56f,
            )
        }
    }

    private fun barHeightScaleFor(signKey: String): Float {
        return when (signKey) {
            "taurus", "capricorn" -> 1.04f
            "gemini", "aquarius" -> 0.94f
            "leo", "sagittarius" -> 1.02f
            "pisces", "cancer" -> 0.98f
            else -> 1f
        }
    }

    private fun coinScaleFor(signKey: String): Float {
        return when (signKey) {
            "leo" -> 1.08f
            "taurus", "capricorn" -> 1.04f
            "gemini", "virgo" -> 0.96f
            "libra" -> 0.98f
            "pisces" -> 1.02f
            else -> 1f
        }
    }

    private fun adjustAlpha(color: Int, factor: Float): Int {
        val alpha = (Color.alpha(color) * factor).toInt().coerceIn(0, 255)
        return Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))
    }

    private fun blendColors(startColor: Int, endColor: Int, factor: Float): Int {
        val safeFactor = factor.coerceIn(0f, 1f)
        return Color.argb(
            (Color.alpha(startColor) + ((Color.alpha(endColor) - Color.alpha(startColor)) * safeFactor)).toInt(),
            (Color.red(startColor) + ((Color.red(endColor) - Color.red(startColor)) * safeFactor)).toInt(),
            (Color.green(startColor) + ((Color.green(endColor) - Color.green(startColor)) * safeFactor)).toInt(),
            (Color.blue(startColor) + ((Color.blue(endColor) - Color.blue(startColor)) * safeFactor)).toInt(),
        )
    }

    private fun intensifyColor(color: Int, factor: Float): Int {
        val safeFactor = factor.coerceIn(0f, 1f)
        return blendColors(color, Color.WHITE, safeFactor * 0.14f)
    }

    private fun lerp(start: Float, end: Float, factor: Float): Float {
        val safeFactor = factor.coerceIn(0f, 1f)
        return start + ((end - start) * safeFactor)
    }

    private fun smoothStep(edge0: Float, edge1: Float, value: Float): Float {
        if (abs(edge1 - edge0) < 0.0001f) {
            return if (value >= edge1) 1f else 0f
        }
        val t = ((value - edge0) / (edge1 - edge0)).coerceIn(0f, 1f)
        return t * t * (3f - (2f * t))
    }
}
