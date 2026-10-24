# Keep Flutter engine and generated plugin registrant.
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep app entry points used by AndroidManifest.
-keep class com.example.healthy_life.MainActivity { *; }
-keep class com.foregroundservice.ForegroundService { *; }

# Keep WorkManager classes that may be instantiated by class name.
-keep class * extends androidx.work.ListenableWorker
-keep class dev.fluttercommunity.workmanager.** { *; }

# Keep camera / recording plugin bridges.
-keep class io.flutter.plugins.camera.** { *; }
-keep class com.isvisoft.flutter_screen_recording.** { *; }
-keep class com.foregroundservice.** { *; }

# Keep secure storage bridge classes.
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep ML Kit pose and Google internals used by runtime loading.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_pose_bundled.** { *; }

# Keep Isar / generated adapters used by native bridge.
-keep class io.isar.** { *; }

# Keep Media3 transformer/effect classes used by workout post-processing overlays.
-keep class androidx.media3.** { *; }

# Keep native workout video overlay renderer classes referenced by method channel/exporter callbacks.
-keep class com.example.healthy_life.WorkoutVideoExportChannel { *; }
-keep class com.example.healthy_life.WorkoutCanvasOverlay { *; }
-keep class com.example.healthy_life.WorkoutOverlayTimeline { *; }
-keep class com.example.healthy_life.OverlaySample { *; }
-keep class com.example.healthy_life.OverlayState { *; }
-keep class com.example.healthy_life.OverlayVisualConfig { *; }
-keep class com.example.healthy_life.ZodiacTheme { *; }

# Keep Kotlin metadata and annotations for reflection-heavy libs.
-keep class kotlin.Metadata { *; }
-keepattributes *Annotation*,InnerClasses,EnclosingMethod,Signature,LineNumberTable,SourceFile

# Suppress harmless warnings from transitive dependencies.
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**
-dontwarn org.jetbrains.annotations.**
-dontwarn androidx.media3.**
-dontwarn com.google.mlkit.**
-dontwarn com.google.android.gms.**
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_pose_detection.** { *; }
