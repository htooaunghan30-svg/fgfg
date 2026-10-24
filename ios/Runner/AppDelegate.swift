import Flutter
import UIKit
import Foundation
import AVFoundation
import CoreImage
import MachO
import Darwin

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let securityChannelName = "hf.sec.guard"
  private let videoExportChannelName = "hf.video.export"
  private let workoutVideoExporter = WorkoutVideoExporter()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: securityChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "runtimeInfo":
          result(self.runtimeInfo())
        case "systemUptimeMs":
          result(Int64(ProcessInfo.processInfo.systemUptime * 1000))
        default:
          result(FlutterMethodNotImplemented)
        }
      }

      let videoExportChannel = FlutterMethodChannel(
        name: videoExportChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      videoExportChannel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(
            FlutterError(
              code: "VIDEO_EXPORT_UNAVAILABLE",
              message: "App delegate is unavailable.",
              details: nil
            )
          )
          return
        }

        if !self.workoutVideoExporter.handle(call: call, result: result) {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func runtimeInfo() -> [String: Any] {
    var debug = false
    #if DEBUG
      debug = true
    #endif

    let emulator = isRunningOnSimulator()
    let rooted = isJailbroken()
    let hookDetected = isHookingDetected()
    let debuggerConnected = isDebuggerAttached()

    return [
      "platform": "ios",
      "packageName": Bundle.main.bundleIdentifier ?? "",
      "signatureSha256": "",
      "debuggable": debug,
      "debuggerConnected": debuggerConnected,
      "installer": "appstore_or_testflight",
      "emulator": emulator,
      "rooted": rooted,
      "virtualSpace": false,
      "hookDetected": hookDetected,
    ]
  }

  private func isRunningOnSimulator() -> Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }

  private func isJailbroken() -> Bool {
    #if targetEnvironment(simulator)
      return false
    #else
      let fm = FileManager.default
      let suspiciousPaths = [
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/bin/bash",
        "/usr/sbin/sshd",
        "/etc/apt",
      ]
      if suspiciousPaths.contains(where: { fm.fileExists(atPath: $0) }) {
        return true
      }

      // Attempt to write outside the sandbox.
      let testPath = "/private/\(UUID().uuidString)"
      do {
        try "x".write(toFile: testPath, atomically: true, encoding: .utf8)
        try fm.removeItem(atPath: testPath)
        return true
      } catch {
        return false
      }
    #endif
  }

  private func isHookingDetected() -> Bool {
    if getenv("DYLD_INSERT_LIBRARIES") != nil {
      return true
    }

    let needles = [
      "frida",
      "FridaGadget",
      "cydia",
      "substrate",
      "MobileSubstrate",
      "libhooker",
    ]

    let count = _dyld_image_count()
    for i in 0..<count {
      if let name = _dyld_get_image_name(i) {
        let image = String(cString: name)
        if needles.contains(where: { image.localizedCaseInsensitiveContains($0) }) {
          return true
        }
      }
    }
    return false
  }

  private func isDebuggerAttached() -> Bool {
    var info = kinfo_proc()
    var size = MemoryLayout<kinfo_proc>.stride
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    let result = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
    if result != 0 {
      return false
    }
    return (info.kp_proc.p_flag & P_TRACED) != 0
  }
}

private final class WorkoutVideoExporter {
  private let queue = DispatchQueue(label: "hf.video.export.queue", qos: .userInitiated)
  private let ciContext = CIContext()
  private let shortVideoAspectRatio: CGFloat = 9.0 / 16.0
  private let targetRenderWidth: CGFloat = 1080
  private let targetRenderHeight: CGFloat = 1920
  private let minAcceptableVideoBitrate: Double = 16_000_000

  func handle(call: FlutterMethodCall, result: @escaping FlutterResult) -> Bool {
    guard call.method == "exportWorkoutVideo" else {
      return false
    }

    guard
      let arguments = call.arguments as? [String: Any],
      let rawVideoPath = arguments["rawVideoPath"] as? String,
      !rawVideoPath.isEmpty
    else {
      result(
        FlutterError(
          code: "VIDEO_EXPORT_ARGS",
          message: "Missing rawVideoPath.",
          details: nil
        )
      )
      return true
    }

    let inputURL = URL(fileURLWithPath: rawVideoPath)
    guard FileManager.default.fileExists(atPath: inputURL.path) else {
      result(
        FlutterError(
          code: "VIDEO_EXPORT_INPUT",
          message: "Input video does not exist at \(rawVideoPath).",
          details: nil
        )
      )
      return true
    }

    let samples = parseSamples(arguments["samples"] as? [[String: Any]])
    let visualConfig = parseVisualConfig(arguments)
    queue.async {
      self.exportVideo(
        inputURL: inputURL,
        samples: samples,
        visualConfig: visualConfig,
        result: result
      )
    }
    return true
  }

  private func parseVisualConfig(_ arguments: [String: Any]) -> WorkoutOverlayVisualConfig {
    let iconicProgram = (arguments["iconicProgram"] as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let zodiacSignKey = (arguments["zodiacSignKey"] as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let overlayTitle = (arguments["overlayTitle"] as? String)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return WorkoutOverlayVisualConfig(
      iconicProgram: normalizedIconicProgram(iconicProgram),
      zodiacSignKey: zodiacSignKey?.isEmpty == false ? zodiacSignKey! : "aries",
      overlayTitle: overlayTitle?.isEmpty == false ? overlayTitle : nil,
      worldFestivalTheme: parseWorldFestivalTheme(arguments["worldFestivalTheme"] as? [String: Any])
    )
  }

  private func normalizedIconicProgram(_ raw: String?) -> String {
    switch raw?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "zodiac":
      return "zodiac"
    case "worldfestival", "world_festival":
      return "world_festival"
    case "profession_hobby":
      return "profession_hobby"
    default:
      return "none"
    }
  }

  private func parseWorldFestivalTheme(_ raw: [String: Any]?) -> WorldFestivalTheme? {
    guard let raw else {
      return nil
    }

    return WorldFestivalTheme(
      storageKey: (raw["storageKey"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      themeName: (raw["themeName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      label: (raw["label"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      subtitle: (raw["subtitle"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      bannerIcon: (raw["bannerIcon"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      cornerIcon: (raw["cornerIcon"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      watermarkIcon: (raw["watermarkIcon"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      bannerTitle: (raw["bannerTitle"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
      variantId: ((raw["variantId"] as? NSNumber)?.intValue ?? 0),
      primaryStart: boostColor(colorValue(raw["primaryStart"], fallback: UIColor(red: 16 / 255, green: 24 / 255, blue: 36 / 255, alpha: 1))),
      primaryEnd: boostColor(colorValue(raw["primaryEnd"], fallback: UIColor(red: 67 / 255, green: 74 / 255, blue: 110 / 255, alpha: 1))),
      accent1: boostColor(colorValue(raw["accent1"], fallback: UIColor(red: 243 / 255, green: 210 / 255, blue: 138 / 255, alpha: 1))),
      accent2: boostColor(colorValue(raw["accent2"], fallback: UIColor(red: 233 / 255, green: 238 / 255, blue: 247 / 255, alpha: 1))),
      glowColor: boostColor(colorValue(raw["glowColor"], fallback: UIColor(red: 243 / 255, green: 210 / 255, blue: 138 / 255, alpha: 1))),
      phaseUpColor: boostColor(colorValue(raw["phaseUpColor"], fallback: UIColor(red: 243 / 255, green: 210 / 255, blue: 138 / 255, alpha: 1))),
      phaseDownColor: boostColor(colorValue(raw["phaseDownColor"], fallback: UIColor(red: 218 / 255, green: 142 / 255, blue: 82 / 255, alpha: 1))),
      phaseHoldColor: boostColor(colorValue(raw["phaseHoldColor"], fallback: UIColor(red: 233 / 255, green: 238 / 255, blue: 247 / 255, alpha: 1))),
      ringGradient: colorListValue(raw["ringGradient"], fallback: [
        UIColor(red: 17 / 255, green: 24 / 255, blue: 39 / 255, alpha: 1),
        UIColor(red: 124 / 255, green: 92 / 255, blue: 46 / 255, alpha: 1),
        UIColor(red: 243 / 255, green: 210 / 255, blue: 138 / 255, alpha: 1),
      ]).map { boostColor($0) },
      accuracyBarGradient: colorListValue(raw["accuracyBarGradient"], fallback: [
        UIColor(red: 17 / 255, green: 24 / 255, blue: 39 / 255, alpha: 1),
        UIColor(red: 86 / 255, green: 99 / 255, blue: 143 / 255, alpha: 1),
        UIColor(red: 243 / 255, green: 210 / 255, blue: 138 / 255, alpha: 1),
      ]).map { boostColor($0) },
      accuracyLowColor: boostColor(colorValue(raw["accuracyLowColor"], fallback: UIColor(red: 166 / 255, green: 65 / 255, blue: 73 / 255, alpha: 1))),
      accuracyMidColor: boostColor(colorValue(raw["accuracyMidColor"], fallback: UIColor(red: 117 / 255, green: 104 / 255, blue: 178 / 255, alpha: 1))),
      accuracyHighColor: boostColor(colorValue(raw["accuracyHighColor"], fallback: UIColor(red: 243 / 255, green: 210 / 255, blue: 138 / 255, alpha: 1))),
      thresholdLineColor: colorValue(raw["thresholdLineColor"], fallback: .white)
    )
  }

  private func parseSamples(_ rawSamples: [[String: Any]]?) -> [WorkoutOverlaySample] {
    let parsed = rawSamples?
      .compactMap { sample -> WorkoutOverlaySample? in
        let offsetMs = (sample["offsetMs"] as? NSNumber)?.int64Value ?? 0
        let repCount = (sample["repCount"] as? NSNumber)?.intValue ?? 0
        let accuracy = (sample["accuracy"] as? NSNumber)?.doubleValue ?? 0
        let phase = ((sample["phase"] as? String) ?? "idle")
          .trimmingCharacters(in: .whitespacesAndNewlines)
          .lowercased()
        return WorkoutOverlaySample(
          offsetMs: max(0, offsetMs),
          repCount: max(0, repCount),
          accuracy: min(1.0, max(0.0, accuracy)),
          phase: ["up", "down", "hold"].contains(phase) ? phase : "idle"
        )
      }
      .sorted { $0.offsetMs < $1.offsetMs } ?? []

    if parsed.isEmpty {
      return [WorkoutOverlaySample(offsetMs: 0, repCount: 0, accuracy: 0, phase: "idle")]
    }
    return parsed
  }

  private func exportVideo(
    inputURL: URL,
    samples: [WorkoutOverlaySample],
    visualConfig: WorkoutOverlayVisualConfig,
    result: @escaping FlutterResult
  ) {
    let outputURL = FileManager.default.temporaryDirectory
      .appendingPathComponent("workout_overlay_\(Int(Date().timeIntervalSince1970 * 1000)).mp4")
    try? FileManager.default.removeItem(at: outputURL)

    let asset = AVAsset(url: inputURL)
    guard let targetRenderSize = makeShortVideoRenderSize(for: asset) else {
      finishOnMain(
        result: result,
        value: FlutterError(
          code: "VIDEO_EXPORT_SIZE",
          message: "Unable to determine export size for workout video.",
          details: nil
        )
      )
      return
    }
    let timeline = WorkoutOverlayTimeline(samples: samples)
    let overlayRenderer = WorkoutVideoOverlayRenderer(
      timeline: timeline,
      visualConfig: visualConfig
    )

    let videoComposition = AVMutableVideoComposition(asset: asset) { request in
      autoreleasepool {
        let sourceImage = request.sourceImage.clampedToExtent()
        let presentationTimeUs = Int64((CMTimeGetSeconds(request.compositionTime) * 1_000_000).rounded())
        let outputExtent = CGRect(origin: .zero, size: request.renderSize)
        let fittedSource = self.aspectFitImage(
          sourceImage,
          sourceExtent: request.sourceImage.extent,
          outputExtent: outputExtent
        )

        guard let overlayImage = overlayRenderer.makeOverlayImage(
          renderSize: request.renderSize,
          presentationTimeUs: max(0, presentationTimeUs)
        ) else {
          request.finish(
            with: fittedSource,
            context: self.ciContext
          )
          return
        }

        let composed = overlayImage
          .composited(over: fittedSource)
          .cropped(to: outputExtent)
        request.finish(with: composed, context: self.ciContext)
      }
    }
    videoComposition.renderSize = targetRenderSize
    if let videoTrack = asset.tracks(withMediaType: .video).first {
      let nominalFrameRate = videoTrack.nominalFrameRate
      if nominalFrameRate > 0 {
        videoComposition.frameDuration = CMTime(
          value: 1,
          timescale: CMTimeScale(max(1, lround(Double(nominalFrameRate))))
        )
      } else {
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
      }
    } else {
      videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    }

    guard let exportSession = AVAssetExportSession(
      asset: asset,
      presetName: AVAssetExportPresetHighestQuality
    ) else {
      finishOnMain(
        result: result,
        value: FlutterError(
          code: "VIDEO_EXPORT_SESSION",
          message: "Failed to create AVAssetExportSession.",
          details: nil
        )
      )
      return
    }

    exportSession.outputURL = outputURL
    exportSession.outputFileType = .mp4
    exportSession.videoComposition = videoComposition
    exportSession.shouldOptimizeForNetworkUse = false

    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .completed:
        if let qualityError = self.validateExportQuality(
          inputURL: inputURL,
          outputURL: outputURL
        ) {
          try? FileManager.default.removeItem(at: outputURL)
          self.finishOnMain(
            result: result,
            value: FlutterError(
              code: "VIDEO_EXPORT_QUALITY",
              message: qualityError,
              details: nil
            )
          )
          return
        }
        self.finishOnMain(
          result: result,
          value: ["outputPath": outputURL.path]
        )
      case .failed:
        try? FileManager.default.removeItem(at: outputURL)
        self.finishOnMain(
          result: result,
          value: FlutterError(
            code: "VIDEO_EXPORT_FAILED",
            message: exportSession.error?.localizedDescription ?? "Native iOS export failed.",
            details: nil
          )
        )
      case .cancelled:
        try? FileManager.default.removeItem(at: outputURL)
        self.finishOnMain(
          result: result,
          value: FlutterError(
            code: "VIDEO_EXPORT_CANCELLED",
            message: "Native iOS export was cancelled.",
            details: nil
          )
        )
      default:
        try? FileManager.default.removeItem(at: outputURL)
        self.finishOnMain(
          result: result,
          value: FlutterError(
            code: "VIDEO_EXPORT_UNKNOWN",
            message: "Native iOS export ended in state \(exportSession.status.rawValue).",
            details: exportSession.error?.localizedDescription
          )
        )
      }
    }
  }

  private func finishOnMain(result: @escaping FlutterResult, value: Any) {
    DispatchQueue.main.async {
      result(value)
    }
  }

  private func validateExportQuality(inputURL: URL, outputURL: URL) -> String? {
    guard let inputMetadata = readVideoMetadata(url: inputURL) else {
      return nil
    }
    guard let outputMetadata = readVideoMetadata(url: outputURL) else {
      return "Unable to inspect exported video quality."
    }

    let outputAspectRatio = outputMetadata.width / outputMetadata.height
    if abs(outputAspectRatio - shortVideoAspectRatio) > CGFloat(0.03) {
      return "Exported video is not using the short-video 9:16 frame."
    }

    if inputMetadata.longestEdge >= 1280, outputMetadata.longestEdge < 1080 {
      return "Exported video dropped too far below HD resolution."
    }

    if outputMetadata.bitrate > 0 {
      let inputScaledFloor = inputMetadata.bitrate > 0 ? inputMetadata.bitrate * 0.60 : 0
      let bitrateFloor = max(minAcceptableVideoBitrate, inputScaledFloor)
      if outputMetadata.bitrate < bitrateFloor {
        return "Exported video bitrate is too low compared with the original recording."
      }
    }

    if outputMetadata.longestEdge < (inputMetadata.longestEdge * 0.75) ||
      outputMetadata.shortestEdge < (inputMetadata.shortestEdge * 0.75) {
      return "Exported video resolution is too low compared with the original recording."
    }

    return nil
  }

  private func readVideoMetadata(url: URL) -> VideoMetadata? {
    let asset = AVAsset(url: url)
    guard let track = asset.tracks(withMediaType: .video).first else {
      return nil
    }

    let transformedSize = track.naturalSize.applying(track.preferredTransform)
    let width = abs(transformedSize.width)
    let height = abs(transformedSize.height)
    guard width > 0, height > 0 else {
      return nil
    }

    let bitrate = track.estimatedDataRate > 0 ? Double(track.estimatedDataRate) : 0
    return VideoMetadata(width: width, height: height, bitrate: bitrate)
  }

  private func makeShortVideoRenderSize(for asset: AVAsset) -> CGSize? {
    guard asset.tracks(withMediaType: .video).first != nil else {
      return nil
    }
    return CGSize(
      width: evenDimension(targetRenderWidth),
      height: evenDimension(targetRenderHeight)
    )
  }

  private func centerCropRect(for extent: CGRect, targetAspectRatio: CGFloat) -> CGRect {
    guard extent.width > 0, extent.height > 0, targetAspectRatio > 0 else {
      return extent
    }

    let sourceAspectRatio = extent.width / extent.height
    if sourceAspectRatio > targetAspectRatio {
      let cropWidth = extent.height * targetAspectRatio
      let originX = extent.midX - (cropWidth / 2.0)
      return CGRect(
        x: originX,
        y: extent.minY,
        width: cropWidth,
        height: extent.height
      ).integral
    } else if sourceAspectRatio < targetAspectRatio {
      let cropHeight = extent.width / targetAspectRatio
      let originY = extent.midY - (cropHeight / 2.0)
      return CGRect(
        x: extent.minX,
        y: originY,
        width: extent.width,
        height: cropHeight
      ).integral
    }

    return extent.integral
  }

  private func aspectFitImage(
    _ image: CIImage,
    sourceExtent: CGRect,
    outputExtent: CGRect
  ) -> CIImage {
    guard sourceExtent.width > 0,
      sourceExtent.height > 0,
      outputExtent.width > 0,
      outputExtent.height > 0 else {
      return image.cropped(to: outputExtent)
    }

    let scale = min(
      outputExtent.width / sourceExtent.width,
      outputExtent.height / sourceExtent.height
    )
    let fittedWidth = sourceExtent.width * scale
    let fittedHeight = sourceExtent.height * scale
    let offsetX = outputExtent.midX - (fittedWidth / 2.0)
    let offsetY = outputExtent.midY - (fittedHeight / 2.0)

    let normalized = image.transformed(
      by: CGAffineTransform(
        translationX: -sourceExtent.minX,
        y: -sourceExtent.minY
      )
    )
    let scaled = normalized.transformed(
      by: CGAffineTransform(scaleX: scale, y: scale)
    )
    let centered = scaled.transformed(
      by: CGAffineTransform(
        translationX: offsetX,
        y: offsetY
      )
    )
    let background = CIImage(color: CIColor.black).cropped(to: outputExtent)
    return centered.composited(over: background).cropped(to: outputExtent)
  }

  private func evenDimension(_ value: CGFloat) -> CGFloat {
    let rounded = max(2, Int(value.rounded(.down)))
    return CGFloat(rounded % 2 == 0 ? rounded : rounded - 1)
  }
}

private func colorValue(_ raw: Any?, fallback: UIColor) -> UIColor {
  if let number = raw as? NSNumber {
    return colorFromARGB(number.uint32Value)
  }
  if let string = raw as? String {
    let normalized = string.replacingOccurrences(of: "#", with: "")
    if let value = UInt32(normalized, radix: 16) {
      return colorFromARGB(normalized.count <= 6 ? (0xFF000000 | value) : value)
    }
  }
  return fallback
}

private func colorListValue(_ raw: Any?, fallback: [UIColor]) -> [UIColor] {
  guard let list = raw as? [Any] else {
    return fallback
  }
  let parsed = list.compactMap { item -> UIColor? in
    if let number = item as? NSNumber {
      return colorFromARGB(number.uint32Value)
    }
    if let string = item as? String {
      let normalized = string.replacingOccurrences(of: "#", with: "")
      if let value = UInt32(normalized, radix: 16) {
        return colorFromARGB(normalized.count <= 6 ? (0xFF000000 | value) : value)
      }
    }
    return nil
  }
  return parsed.isEmpty ? fallback : parsed
}

private func colorFromARGB(_ value: UInt32) -> UIColor {
  let alpha = CGFloat((value >> 24) & 0xFF) / 255.0
  let red = CGFloat((value >> 16) & 0xFF) / 255.0
  let green = CGFloat((value >> 8) & 0xFF) / 255.0
  let blue = CGFloat(value & 0xFF) / 255.0
  return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

private struct WorkoutOverlaySample {
  let offsetMs: Int64
  let repCount: Int
  let accuracy: Double
  let phase: String
}

private struct WorkoutOverlayState: Hashable {
  let repCount: Int
  let accuracyBucket: Int
  let phase: String

  var accuracyValue: CGFloat {
    CGFloat(accuracyBucket) / 1000.0
  }
}

private struct WorkoutOverlayVisualConfig {
  let iconicProgram: String
  let zodiacSignKey: String
  let overlayTitle: String?
  let worldFestivalTheme: WorldFestivalTheme?
}

private struct WorldFestivalTheme {
  let storageKey: String
  let themeName: String
  let label: String
  let subtitle: String
  let bannerIcon: String
  let cornerIcon: String
  let watermarkIcon: String
  let bannerTitle: String
  let variantId: Int
  let primaryStart: UIColor
  let primaryEnd: UIColor
  let accent1: UIColor
  let accent2: UIColor
  let glowColor: UIColor
  let phaseUpColor: UIColor
  let phaseDownColor: UIColor
  let phaseHoldColor: UIColor
  let ringGradient: [UIColor]
  let accuracyBarGradient: [UIColor]
  let accuracyLowColor: UIColor
  let accuracyMidColor: UIColor
  let accuracyHighColor: UIColor
  let thresholdLineColor: UIColor
}

private struct VideoMetadata {
  let width: CGFloat
  let height: CGFloat
  let bitrate: Double

  var longestEdge: CGFloat {
    max(width, height)
  }

  var shortestEdge: CGFloat {
    min(width, height)
  }
}

private struct ZodiacTheme {
  let signKey: String
  let signLabel: String
  let symbol: String
  let titleStartColor: UIColor
  let titleEndColor: UIColor
  let shellColors: [UIColor]
  let fillColors: [UIColor]
  let sceneTintTopColor: UIColor
  let sceneTintBottomColor: UIColor
  let beamColor: UIColor
  let glowColor: UIColor
  let constellationColor: UIColor
  let engravingColor: UIColor
  let rimTextColor: UIColor
}

private func zodiacTheme(for key: String) -> ZodiacTheme {
  switch key {
  case "taurus":
    return ZodiacTheme(
      signKey: "taurus",
      signLabel: "TAURUS",
      symbol: "\u{2649}",
      titleStartColor: boostColor(UIColor(red: 0.95, green: 0.87, blue: 0.68, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.66, green: 0.47, blue: 0.25, alpha: 1)),
      shellColors: [
        UIColor(red: 0.09, green: 0.18, blue: 0.15, alpha: 1),
        UIColor(red: 0.17, green: 0.29, blue: 0.23, alpha: 1),
        UIColor(red: 0.49, green: 0.38, blue: 0.19, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.91, green: 0.80, blue: 0.57, alpha: 1),
        UIColor(red: 0.59, green: 0.49, blue: 0.27, alpha: 1),
        UIColor(red: 0.38, green: 0.28, blue: 0.13, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.59, green: 0.49, blue: 0.27, alpha: 0.17),
      sceneTintBottomColor: UIColor(red: 0.15, green: 0.30, blue: 0.21, alpha: 0.14),
      beamColor: UIColor(red: 0.89, green: 0.80, blue: 0.59, alpha: 0.13),
      glowColor: boostColor(UIColor(red: 0.82, green: 0.71, blue: 0.40, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.96, green: 0.91, blue: 0.77, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.22, green: 0.15, blue: 0.09, alpha: 1)),
      rimTextColor: UIColor(red: 0.96, green: 0.91, blue: 0.80, alpha: 0.46)
    )
  case "gemini":
    return ZodiacTheme(
      signKey: "gemini",
      signLabel: "GEMINI",
      symbol: "\u{264A}",
      titleStartColor: boostColor(UIColor(red: 0.94, green: 0.88, blue: 0.71, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.71, green: 0.55, blue: 0.29, alpha: 1)),
      shellColors: [
        UIColor(red: 0.11, green: 0.13, blue: 0.30, alpha: 1),
        UIColor(red: 0.23, green: 0.18, blue: 0.44, alpha: 1),
        UIColor(red: 0.49, green: 0.35, blue: 0.19, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.92, green: 0.84, blue: 0.62, alpha: 1),
        UIColor(red: 0.67, green: 0.48, blue: 0.80, alpha: 1),
        UIColor(red: 0.41, green: 0.27, blue: 0.17, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.44, green: 0.35, blue: 0.72, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.16, green: 0.21, blue: 0.42, alpha: 0.13),
      beamColor: UIColor(red: 0.93, green: 0.84, blue: 0.67, alpha: 0.12),
      glowColor: boostColor(UIColor(red: 0.83, green: 0.67, blue: 0.40, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.97, green: 0.93, blue: 0.81, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.22, green: 0.13, blue: 0.09, alpha: 1)),
      rimTextColor: UIColor(red: 0.97, green: 0.93, blue: 0.83, alpha: 0.46)
    )
  case "cancer":
    return ZodiacTheme(
      signKey: "cancer",
      signLabel: "CANCER",
      symbol: "\u{264B}",
      titleStartColor: boostColor(UIColor(red: 0.95, green: 0.88, blue: 0.76, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.68, green: 0.49, blue: 0.33, alpha: 1)),
      shellColors: [
        UIColor(red: 0.10, green: 0.17, blue: 0.31, alpha: 1),
        UIColor(red: 0.20, green: 0.31, blue: 0.43, alpha: 1),
        UIColor(red: 0.47, green: 0.33, blue: 0.21, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.93, green: 0.85, blue: 0.67, alpha: 1),
        UIColor(red: 0.48, green: 0.66, blue: 0.79, alpha: 1),
        UIColor(red: 0.37, green: 0.26, blue: 0.16, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.36, green: 0.56, blue: 0.68, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.15, green: 0.29, blue: 0.37, alpha: 0.13),
      beamColor: UIColor(red: 0.88, green: 0.91, blue: 0.82, alpha: 0.10),
      glowColor: boostColor(UIColor(red: 0.80, green: 0.68, blue: 0.47, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.97, green: 0.94, blue: 0.86, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.20, green: 0.14, blue: 0.10, alpha: 1)),
      rimTextColor: UIColor(red: 0.97, green: 0.94, blue: 0.88, alpha: 0.46)
    )
  case "leo":
    return ZodiacTheme(
      signKey: "leo",
      signLabel: "LEO",
      symbol: "\u{264C}",
      titleStartColor: boostColor(UIColor(red: 0.98, green: 0.89, blue: 0.65, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.76, green: 0.45, blue: 0.18, alpha: 1)),
      shellColors: [
        UIColor(red: 0.22, green: 0.09, blue: 0.07, alpha: 1),
        UIColor(red: 0.38, green: 0.18, blue: 0.09, alpha: 1),
        UIColor(red: 0.58, green: 0.38, blue: 0.15, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.97, green: 0.84, blue: 0.54, alpha: 1),
        UIColor(red: 0.91, green: 0.49, blue: 0.18, alpha: 1),
        UIColor(red: 0.49, green: 0.24, blue: 0.09, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.70, green: 0.36, blue: 0.13, alpha: 0.17),
      sceneTintBottomColor: UIColor(red: 0.33, green: 0.13, blue: 0.07, alpha: 0.13),
      beamColor: UIColor(red: 0.98, green: 0.81, blue: 0.51, alpha: 0.13),
      glowColor: boostColor(UIColor(red: 0.90, green: 0.61, blue: 0.28, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 1.00, green: 0.93, blue: 0.75, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.25, green: 0.11, blue: 0.05, alpha: 1)),
      rimTextColor: UIColor(red: 0.99, green: 0.92, blue: 0.77, alpha: 0.47)
    )
  case "virgo":
    return ZodiacTheme(
      signKey: "virgo",
      signLabel: "VIRGO",
      symbol: "\u{264D}",
      titleStartColor: boostColor(UIColor(red: 0.95, green: 0.89, blue: 0.75, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.65, green: 0.53, blue: 0.33, alpha: 1)),
      shellColors: [
        UIColor(red: 0.10, green: 0.20, blue: 0.18, alpha: 1),
        UIColor(red: 0.23, green: 0.36, blue: 0.31, alpha: 1),
        UIColor(red: 0.49, green: 0.36, blue: 0.21, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.93, green: 0.86, blue: 0.69, alpha: 1),
        UIColor(red: 0.55, green: 0.70, blue: 0.49, alpha: 1),
        UIColor(red: 0.36, green: 0.27, blue: 0.15, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.44, green: 0.60, blue: 0.40, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.16, green: 0.30, blue: 0.22, alpha: 0.13),
      beamColor: UIColor(red: 0.89, green: 0.91, blue: 0.77, alpha: 0.11),
      glowColor: boostColor(UIColor(red: 0.80, green: 0.71, blue: 0.43, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.96, green: 0.94, blue: 0.84, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.19, green: 0.15, blue: 0.09, alpha: 1)),
      rimTextColor: UIColor(red: 0.96, green: 0.94, blue: 0.86, alpha: 0.46)
    )
  case "libra":
    return ZodiacTheme(
      signKey: "libra",
      signLabel: "LIBRA",
      symbol: "\u{264E}",
      titleStartColor: boostColor(UIColor(red: 0.95, green: 0.89, blue: 0.78, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.74, green: 0.53, blue: 0.40, alpha: 1)),
      shellColors: [
        UIColor(red: 0.11, green: 0.15, blue: 0.33, alpha: 1),
        UIColor(red: 0.29, green: 0.29, blue: 0.48, alpha: 1),
        UIColor(red: 0.57, green: 0.37, blue: 0.36, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.95, green: 0.87, blue: 0.73, alpha: 1),
        UIColor(red: 0.78, green: 0.57, blue: 0.67, alpha: 1),
        UIColor(red: 0.44, green: 0.29, blue: 0.22, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.64, green: 0.44, blue: 0.55, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.20, green: 0.22, blue: 0.39, alpha: 0.13),
      beamColor: UIColor(red: 0.92, green: 0.85, blue: 0.82, alpha: 0.10),
      glowColor: boostColor(UIColor(red: 0.83, green: 0.65, blue: 0.57, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.97, green: 0.94, blue: 0.88, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.23, green: 0.15, blue: 0.13, alpha: 1)),
      rimTextColor: UIColor(red: 0.97, green: 0.94, blue: 0.90, alpha: 0.46)
    )
  case "scorpio":
    return ZodiacTheme(
      signKey: "scorpio",
      signLabel: "SCORPIO",
      symbol: "\u{264F}",
      titleStartColor: boostColor(UIColor(red: 0.95, green: 0.87, blue: 0.76, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.65, green: 0.38, blue: 0.36, alpha: 1)),
      shellColors: [
        UIColor(red: 0.13, green: 0.07, blue: 0.16, alpha: 1),
        UIColor(red: 0.29, green: 0.11, blue: 0.27, alpha: 1),
        UIColor(red: 0.49, green: 0.24, blue: 0.20, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.93, green: 0.82, blue: 0.71, alpha: 1),
        UIColor(red: 0.65, green: 0.31, blue: 0.45, alpha: 1),
        UIColor(red: 0.36, green: 0.16, blue: 0.16, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.48, green: 0.18, blue: 0.30, alpha: 0.17),
      sceneTintBottomColor: UIColor(red: 0.21, green: 0.07, blue: 0.13, alpha: 0.14),
      beamColor: UIColor(red: 0.91, green: 0.76, blue: 0.69, alpha: 0.10),
      glowColor: boostColor(UIColor(red: 0.73, green: 0.40, blue: 0.42, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.97, green: 0.90, blue: 0.85, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.21, green: 0.10, blue: 0.11, alpha: 1)),
      rimTextColor: UIColor(red: 0.96, green: 0.91, blue: 0.88, alpha: 0.45)
    )
  case "sagittarius":
    return ZodiacTheme(
      signKey: "sagittarius",
      signLabel: "SAGITTARIUS",
      symbol: "\u{2650}",
      titleStartColor: boostColor(UIColor(red: 0.97, green: 0.89, blue: 0.70, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.69, green: 0.47, blue: 0.22, alpha: 1)),
      shellColors: [
        UIColor(red: 0.11, green: 0.16, blue: 0.31, alpha: 1),
        UIColor(red: 0.17, green: 0.27, blue: 0.46, alpha: 1),
        UIColor(red: 0.52, green: 0.32, blue: 0.14, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.96, green: 0.85, blue: 0.60, alpha: 1),
        UIColor(red: 0.46, green: 0.66, blue: 0.84, alpha: 1),
        UIColor(red: 0.49, green: 0.28, blue: 0.11, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.30, green: 0.48, blue: 0.74, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.14, green: 0.24, blue: 0.41, alpha: 0.13),
      beamColor: UIColor(red: 0.93, green: 0.84, blue: 0.60, alpha: 0.12),
      glowColor: boostColor(UIColor(red: 0.80, green: 0.60, blue: 0.33, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.98, green: 0.93, blue: 0.78, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.20, green: 0.12, blue: 0.06, alpha: 1)),
      rimTextColor: UIColor(red: 0.98, green: 0.94, blue: 0.82, alpha: 0.46)
    )
  case "capricorn":
    return ZodiacTheme(
      signKey: "capricorn",
      signLabel: "CAPRICORN",
      symbol: "\u{2651}",
      titleStartColor: boostColor(UIColor(red: 0.93, green: 0.89, blue: 0.78, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.63, green: 0.54, blue: 0.36, alpha: 1)),
      shellColors: [
        UIColor(red: 0.11, green: 0.16, blue: 0.18, alpha: 1),
        UIColor(red: 0.20, green: 0.30, blue: 0.33, alpha: 1),
        UIColor(red: 0.43, green: 0.35, blue: 0.25, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.91, green: 0.86, blue: 0.73, alpha: 1),
        UIColor(red: 0.53, green: 0.60, blue: 0.57, alpha: 1),
        UIColor(red: 0.33, green: 0.25, blue: 0.17, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.45, green: 0.53, blue: 0.50, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.16, green: 0.24, blue: 0.23, alpha: 0.13),
      beamColor: UIColor(red: 0.89, green: 0.87, blue: 0.80, alpha: 0.10),
      glowColor: boostColor(UIColor(red: 0.72, green: 0.67, blue: 0.51, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.95, green: 0.94, blue: 0.86, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.18, green: 0.15, blue: 0.11, alpha: 1)),
      rimTextColor: UIColor(red: 0.95, green: 0.94, blue: 0.88, alpha: 0.45)
    )
  case "aquarius":
    return ZodiacTheme(
      signKey: "aquarius",
      signLabel: "AQUARIUS",
      symbol: "\u{2652}",
      titleStartColor: boostColor(UIColor(red: 0.91, green: 0.90, blue: 0.80, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.43, green: 0.61, blue: 0.67, alpha: 1)),
      shellColors: [
        UIColor(red: 0.07, green: 0.17, blue: 0.26, alpha: 1),
        UIColor(red: 0.13, green: 0.31, blue: 0.44, alpha: 1),
        UIColor(red: 0.31, green: 0.48, blue: 0.52, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.87, green: 0.89, blue: 0.78, alpha: 1),
        UIColor(red: 0.44, green: 0.71, blue: 0.78, alpha: 1),
        UIColor(red: 0.20, green: 0.40, blue: 0.45, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.34, green: 0.63, blue: 0.70, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.09, green: 0.31, blue: 0.40, alpha: 0.13),
      beamColor: UIColor(red: 0.84, green: 0.94, blue: 0.90, alpha: 0.11),
      glowColor: boostColor(UIColor(red: 0.42, green: 0.73, blue: 0.77, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.89, green: 0.95, blue: 0.94, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.10, green: 0.20, blue: 0.23, alpha: 1)),
      rimTextColor: UIColor(red: 0.89, green: 0.95, blue: 0.94, alpha: 0.45)
    )
  case "pisces":
    return ZodiacTheme(
      signKey: "pisces",
      signLabel: "PISCES",
      symbol: "\u{2653}",
      titleStartColor: boostColor(UIColor(red: 0.93, green: 0.88, blue: 0.80, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.50, green: 0.53, blue: 0.73, alpha: 1)),
      shellColors: [
        UIColor(red: 0.11, green: 0.13, blue: 0.30, alpha: 1),
        UIColor(red: 0.22, green: 0.23, blue: 0.46, alpha: 1),
        UIColor(red: 0.37, green: 0.37, blue: 0.56, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.89, green: 0.86, blue: 0.80, alpha: 1),
        UIColor(red: 0.50, green: 0.56, blue: 0.84, alpha: 1),
        UIColor(red: 0.26, green: 0.30, blue: 0.49, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.36, green: 0.44, blue: 0.78, alpha: 0.16),
      sceneTintBottomColor: UIColor(red: 0.17, green: 0.19, blue: 0.43, alpha: 0.13),
      beamColor: UIColor(red: 0.88, green: 0.87, blue: 0.96, alpha: 0.10),
      glowColor: boostColor(UIColor(red: 0.56, green: 0.60, blue: 0.85, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.92, green: 0.92, blue: 0.97, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.14, green: 0.16, blue: 0.30, alpha: 1)),
      rimTextColor: UIColor(red: 0.92, green: 0.92, blue: 0.97, alpha: 0.45)
    )
  default:
    return ZodiacTheme(
      signKey: "aries",
      signLabel: "ARIES",
      symbol: "\u{2648}",
      titleStartColor: boostColor(UIColor(red: 0.97, green: 0.88, blue: 0.67, alpha: 1)),
      titleEndColor: boostColor(UIColor(red: 0.70, green: 0.49, blue: 0.22, alpha: 1)),
      shellColors: [
        UIColor(red: 0.04, green: 0.12, blue: 0.24, alpha: 1),
        UIColor(red: 0.08, green: 0.17, blue: 0.30, alpha: 1),
        UIColor(red: 0.40, green: 0.30, blue: 0.15, alpha: 1),
      ].map { boostColor($0) },
      fillColors: [
        UIColor(red: 0.95, green: 0.84, blue: 0.58, alpha: 1),
        UIColor(red: 0.76, green: 0.57, blue: 0.28, alpha: 1),
        UIColor(red: 0.47, green: 0.28, blue: 0.13, alpha: 1),
      ].map { boostColor($0) },
      sceneTintTopColor: UIColor(red: 0.14, green: 0.31, blue: 0.52, alpha: 0.17),
      sceneTintBottomColor: UIColor(red: 0.08, green: 0.14, blue: 0.31, alpha: 0.13),
      beamColor: UIColor(red: 1.00, green: 0.83, blue: 0.52, alpha: 0.12),
      glowColor: boostColor(UIColor(red: 0.90, green: 0.76, blue: 0.43, alpha: 1)),
      constellationColor: boostColor(UIColor(red: 0.96, green: 0.90, blue: 0.75, alpha: 1)),
      engravingColor: boostColor(UIColor(red: 0.23, green: 13 / 255, blue: 0.07, alpha: 1)),
      rimTextColor: UIColor(red: 0.96, green: 0.88, blue: 0.70, alpha: 0.44)
    )
  }
}

private final class WorkoutOverlayTimeline {
  private let samples: [WorkoutOverlaySample]

  init(samples: [WorkoutOverlaySample]) {
    self.samples = samples.sorted { $0.offsetMs < $1.offsetMs }
  }

  func state(at presentationTimeUs: Int64) -> WorkoutOverlayState {
    let timeMs = max(Int64(0), presentationTimeUs / 1000)
    var low = 0
    var high = samples.count - 1
    var index = 0

    while low <= high {
      let mid = (low + high) / 2
      if samples[mid].offsetMs <= timeMs {
        index = mid
        low = mid + 1
      } else {
        high = mid - 1
      }
    }

    let sample = samples[index]
    let nextIndex = min(index + 1, samples.count - 1)
    let nextSample = samples[nextIndex]

    let interpolatedAccuracy: Double
    if nextIndex == index || nextSample.offsetMs <= sample.offsetMs {
      interpolatedAccuracy = sample.accuracy
    } else {
      let range = Double(nextSample.offsetMs - sample.offsetMs)
      let rawT = min(1.0, max(0.0, Double(timeMs - sample.offsetMs) / range))
      // Smoothstep easing prevents visible stepping in exported accuracy bar motion.
      let easedT = rawT * rawT * (3.0 - (2.0 * rawT))
      interpolatedAccuracy = sample.accuracy + ((nextSample.accuracy - sample.accuracy) * easedT)
    }

    let bucket = Int((interpolatedAccuracy * 1000.0).rounded())
    return WorkoutOverlayState(
      repCount: sample.repCount,
      accuracyBucket: min(1000, max(0, bucket)),
      phase: sample.phase
    )
  }
}

private final class WorkoutVideoOverlayRenderer {
  private let professionHobbyVerticalOffsetScale: CGFloat = 8.0
  private let professionHobbyMetricClusterExtraOffsetScale: CGFloat = 24.0
  private let timeline: WorkoutOverlayTimeline
  private let visualConfig: WorkoutOverlayVisualConfig
  private var cachedKey: String?
  private var cachedImage: CIImage?

  init(
    timeline: WorkoutOverlayTimeline,
    visualConfig: WorkoutOverlayVisualConfig
  ) {
    self.timeline = timeline
    self.visualConfig = visualConfig
  }

  func makeOverlayImage(renderSize: CGSize, presentationTimeUs: Int64) -> CIImage? {
    guard renderSize.width > 0, renderSize.height > 0 else {
      return nil
    }

    let state = timeline.state(at: presentationTimeUs)
    let animationBucket: Int
    if visualConfig.iconicProgram == "zodiac" || visualConfig.iconicProgram == "world_festival" {
      animationBucket = Int(presentationTimeUs / 160_000)
    } else {
      animationBucket = 0
    }
    let cacheKey = "\(Int(renderSize.width.rounded()))x\(Int(renderSize.height.rounded()))-\(state.repCount)-\(state.accuracyBucket)-\(state.phase)-\(visualConfig.iconicProgram)-\(animationBucket)"
    if cacheKey == cachedKey {
      return cachedImage
    }

    let format = UIGraphicsImageRendererFormat.default()
    format.scale = 1
    format.opaque = false

    let image = UIGraphicsImageRenderer(size: renderSize, format: format).image { rendererContext in
      let context = rendererContext.cgContext
      context.clear(CGRect(origin: .zero, size: renderSize))

      let scale = min(renderSize.width / 390.0, renderSize.height / 844.0)
      let overlayScale = self.resolvedOverlayUIScale(for: renderSize)
      if self.visualConfig.iconicProgram == "world_festival",
        let theme = self.visualConfig.worldFestivalTheme {
        self.drawWorldFestivalOverlay(
          in: context,
          renderSize: renderSize,
          state: state,
          scale: scale,
          presentationTimeUs: presentationTimeUs,
          theme: theme
        )
        return
      }
      if self.visualConfig.iconicProgram == "profession_hobby",
        let theme = self.visualConfig.worldFestivalTheme {
        self.drawProfessionHobbyOverlay(
          in: context,
          renderSize: renderSize,
          state: state,
          scale: scale,
          presentationTimeUs: presentationTimeUs,
          theme: theme
        )
        return
      }
      if self.visualConfig.iconicProgram == "zodiac" {
        self.drawZodiacOverlay(
          in: context,
          renderSize: renderSize,
          state: state,
          scale: scale,
          presentationTimeUs: presentationTimeUs
        )
        return
      }

      let topInset = 44.0 * scale
      let repTop = 92.0 * scale
      let repCounterSize = 92.0 * scale
      let accuracyBarHeight = 24.0 * scale
      let effectiveSideInset = 18.0 * scale
      let accuracyBarWidth = renderSize.width - (effectiveSideInset * 2.0)

      drawAccuracyBar(
        in: context,
        rect: CGRect(
          x: effectiveSideInset,
          y: topInset,
          width: accuracyBarWidth,
          height: accuracyBarHeight
        ),
        accuracy: state.accuracyValue,
        scale: scale,
        presentationTimeUs: presentationTimeUs,
        renderSize: renderSize
      )
      drawRepCounter(
        in: context,
        rect: CGRect(
          x: renderSize.width - effectiveSideInset - repCounterSize,
          y: repTop,
          width: repCounterSize,
          height: repCounterSize
        ),
        repCount: state.repCount,
        scale: scale,
        phase: state.phase
      )
    }

    let ciImage = CIImage(image: image)
    cachedKey = cacheKey
    cachedImage = ciImage
    return ciImage
  }

  private func resolvedOverlayUIScale(for renderSize: CGSize) -> CGFloat {
    let normalizedScale = min(renderSize.width / 720.0, renderSize.height / 1280.0)
    let highResolutionGrowth: CGFloat
    if normalizedScale <= 1.0 {
      highResolutionGrowth = normalizedScale
    } else {
      highResolutionGrowth = 1.0 + ((normalizedScale - 1.0) * 0.18)
    }

    let wideFrameAdjustment: CGFloat = (renderSize.width / renderSize.height) > 0.62 ? 0.95 : 1.0
    let tallFrameLift: CGFloat = (renderSize.height / renderSize.width) > 1.9 ? 1.02 : 1.0
    return min(1.08, max(0.78, highResolutionGrowth * wideFrameAdjustment * tallFrameLift))
  }

  private func drawZodiacOverlay(
    in context: CGContext,
    renderSize: CGSize,
    state: WorkoutOverlayState,
    scale: CGFloat,
    presentationTimeUs: Int64
  ) {
    let theme = zodiacTheme(for: visualConfig.zodiacSignKey)
    let sideInset = 18.0 * scale
    let titleTop = 34.0 * scale
    let coinSize = 92.0 * scale * coinScale(for: theme.signKey)
    let gap = 14.0 * scale
    let barHeight = 28.0 * scale * barHeightScale(for: theme.signKey)
    let barTop = titleTop + (34.0 * scale)
    let barWidth = renderSize.width - (sideInset * 2.0) - coinSize - gap
    let title = visualConfig.overlayTitle ?? "\(theme.signLabel.capitalized) Gratitude"
    let pulse = CGFloat((sin(Double(presentationTimeUs) / 320000.0) + 1.0) / 2.0)
    drawSceneTintTreatment(
      in: context,
      renderSize: renderSize,
      scale: scale,
      theme: theme,
      pulse: pulse
    )

    let glowCenter = CGPoint(
      x: renderSize.width - sideInset - (coinSize * 0.38),
      y: barTop + (coinSize * 0.32)
    )
    if let glowGradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: [
        theme.glowColor.withAlphaComponent(0.34 + (0.16 * pulse)).cgColor,
        theme.glowColor.withAlphaComponent(0.08).cgColor,
        UIColor.clear.cgColor,
      ] as CFArray,
      locations: [0, 0.52, 1]
    ) {
      context.drawRadialGradient(
        glowGradient,
        startCenter: glowCenter,
        startRadius: 0,
        endCenter: glowCenter,
        endRadius: coinSize * 0.88,
        options: []
      )
    }

    let titleFont = UIFont(name: "TimesNewRomanPS-BoldMT", size: max(18.0, 18.0 * scale))
      ?? UIFont.systemFont(ofSize: max(18.0, 18.0 * scale), weight: .bold)
    if theme.signKey == "leo" {
      drawLeoSkyHeader(
        in: context,
        rect: CGRect(
          x: sideInset,
          y: titleTop - (8.0 * scale),
          width: barWidth,
          height: (barTop - titleTop)
        ),
        theme: theme,
        scale: scale,
        pulse: pulse,
        presentationTimeUs: presentationTimeUs
      )
    } else {
      drawText(
        title,
        in: CGRect(
          x: sideInset,
          y: titleTop,
          width: renderSize.width * 0.58,
          height: 26.0 * scale
        ),
        font: titleFont,
        color: theme.titleStartColor,
        alignment: .left,
        shadow: NSShadow.make(
          color: UIColor.black.withAlphaComponent(0.42),
          offset: CGSize(width: 0, height: 2.0 * scale),
          blur: 4.0 * scale
        )
      )
      drawTitleFlourishes(
        in: context,
        sideInset: sideInset,
        centerY: titleTop + (9.0 * scale),
        title: title,
        font: titleFont,
        theme: theme,
        scale: scale
      )
    }

    let barRect = CGRect(
      x: sideInset,
      y: barTop,
      width: barWidth,
      height: barHeight
    )
    drawZodiacAccuracyBar(
      in: context,
      rect: barRect,
      accuracy: state.accuracyValue,
      scale: scale,
      presentationTimeUs: presentationTimeUs,
      theme: theme,
      renderSize: renderSize
    )
    drawBarOrnaments(
      in: context,
      rect: barRect,
      theme: theme,
      scale: scale
    )

    let coinRect = CGRect(
      x: barRect.maxX + gap,
      y: barTop - (coinSize * 0.12),
      width: coinSize,
      height: coinSize
    )
    drawZodiacRepCoin(
      in: context,
      rect: coinRect,
      repCount: state.repCount,
      scale: scale,
      pulse: pulse,
      theme: theme
    )
    drawCoinAccent(
      in: context,
      rect: coinRect,
      theme: theme,
      scale: scale
    )

    context.setFillColor(theme.constellationColor.withAlphaComponent(0.44).cgColor)
    for index in 0..<6 {
      let x = sideInset + (CGFloat(index + 1) * (barWidth / 7.0))
      let y = barTop - (6.0 * scale) - (CGFloat(index % 2) * 4.0 * scale)
      context.fillEllipse(
        in: CGRect(
          x: x,
          y: y,
          width: index % 2 == 0 ? 2.4 * scale : 1.8 * scale,
          height: index % 2 == 0 ? 2.4 * scale : 1.8 * scale
        )
      )
    }
  }

  private func drawWorldFestivalOverlay(
    in context: CGContext,
    renderSize: CGSize,
    state: WorkoutOverlayState,
    scale: CGFloat,
    presentationTimeUs: Int64,
    theme: WorldFestivalTheme
  ) {
    let sideInset = 18.0 * scale
    let titleTop = 34.0 * scale
    let titleHeight = 34.0 * scale
    let barTop = titleTop + titleHeight + (8.0 * scale)
    let barHeight = 28.0 * scale
    let repSize = 92.0 * scale
    let gap = 14.0 * scale
    let barWidth = renderSize.width - (sideInset * 2.0) - repSize - gap
    let exerciseTitle = visualConfig.overlayTitle ?? (theme.bannerTitle.isEmpty ? theme.themeName : theme.bannerTitle)
    let festivalTitle = theme.subtitle.isEmpty ? (theme.label.isEmpty ? theme.themeName : theme.label) : theme.subtitle
    let pulse = CGFloat((sin(Double(presentationTimeUs) / 350000.0) + 1.0) / 2.0)

    fillRectWithGradient(
      in: context,
      rect: CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height * 0.60),
      colors: [
        theme.primaryStart.withAlphaComponent(0.28),
        theme.primaryEnd.withAlphaComponent(0.18),
        UIColor.clear,
      ],
      locations: [0, 0.54, 1],
      start: CGPoint(x: 0, y: 0),
      end: CGPoint(x: 0, y: renderSize.height * 0.60)
    )

    if let glowGradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: [
        theme.glowColor.withAlphaComponent(0.22 + (0.12 * pulse)).cgColor,
        theme.accent1.withAlphaComponent(0.08).cgColor,
        UIColor.clear.cgColor,
      ] as CFArray,
      locations: [0, 0.44, 1]
    ) {
      let glowCenter = CGPoint(x: renderSize.width * 0.82, y: barTop + (repSize * 0.32))
      context.drawRadialGradient(
        glowGradient,
        startCenter: glowCenter,
        startRadius: 0,
        endCenter: glowCenter,
        endRadius: repSize,
        options: []
      )
    }

    let bannerRect = CGRect(
      x: sideInset,
      y: titleTop,
      width: renderSize.width - (sideInset * 2.0),
      height: titleHeight
    )
    fillRoundedRect(
      in: context,
      rect: bannerRect,
      radius: 16.0 * scale,
      colors: [
        theme.primaryStart.withAlphaComponent(0.92),
        theme.primaryEnd.withAlphaComponent(0.88),
      ],
      locations: [0, 1]
    )
    context.setStrokeColor(theme.accent1.withAlphaComponent(0.44).cgColor)
    context.setLineWidth(1.0 * scale)
    context.addPath(UIBezierPath(roundedRect: bannerRect, cornerRadius: 16.0 * scale).cgPath)
    context.strokePath()

    let tagText = "WORLD FESTIVAL"
    let tagFont = UIFont.systemFont(ofSize: max(10.0, 10.0 * scale), weight: .bold)
    let tagWidth = NSString(string: tagText).size(withAttributes: [.font: tagFont]).width
    let contentLeft = bannerRect.minX + (34.0 * scale)
    let contentRight = max(contentLeft + (72.0 * scale), bannerRect.maxX - (14.0 * scale) - tagWidth - (16.0 * scale))
    let maxContentWidth = max(72.0 * scale, contentRight - contentLeft)

    context.setFillColor(UIColor.black.withAlphaComponent(0.14).cgColor)
    context.addPath(
      UIBezierPath(
        roundedRect: CGRect(
          x: contentLeft - (6.0 * scale),
          y: bannerRect.minY + (7.0 * scale),
          width: (maxContentWidth + (14.0 * scale)),
          height: bannerRect.height - (14.0 * scale)
        ),
        cornerRadius: 8.0 * scale
      ).cgPath
    )
    context.fillPath()

    if !theme.bannerIcon.isEmpty {
      let iconRect = CGRect(
        x: bannerRect.minX + (10.0 * scale),
        y: bannerRect.minY + (4.0 * scale),
        width: 26.0 * scale,
        height: bannerRect.height - (8.0 * scale)
      )
      if isPadaukBranchIcon(theme.bannerIcon) {
        drawPadaukBranch(in: context, rect: iconRect, alpha: 0.96)
      } else {
        drawText(
          theme.bannerIcon,
          in: CGRect(x: bannerRect.minX + (10.0 * scale), y: bannerRect.minY + (4.0 * scale), width: 26.0 * scale, height: bannerRect.height),
          font: UIFont.systemFont(ofSize: max(16.0, 18.0 * scale)),
          color: theme.accent2,
          alignment: .center,
          shadow: nil
        )
      }
    }

    drawText(
      fittedSingleLineText(
        festivalTitle,
        font: UIFont.systemFont(ofSize: max(15.0, 16.0 * scale), weight: .bold),
        maxWidth: maxContentWidth
      ),
      in: CGRect(
        x: contentLeft,
        y: bannerRect.minY + (3.0 * scale),
        width: maxContentWidth,
        height: 18.0 * scale
      ),
      font: UIFont.systemFont(ofSize: max(15.0, 16.0 * scale), weight: .bold),
      color: theme.accent2,
      alignment: .left,
      shadow: NSShadow.make(
        color: UIColor.black.withAlphaComponent(0.28),
        offset: CGSize(width: 0, height: 1.5 * scale),
        blur: 4.0 * scale
      )
    )
    drawText(
      fittedSingleLineText(
        exerciseTitle,
        font: UIFont.systemFont(ofSize: max(10.0, 11.0 * scale), weight: .medium),
        maxWidth: maxContentWidth
      ),
      in: CGRect(
        x: contentLeft,
        y: bannerRect.minY + (18.0 * scale),
        width: maxContentWidth,
        height: 14.0 * scale
      ),
      font: UIFont.systemFont(ofSize: max(10.0, 11.0 * scale), weight: .medium),
      color: theme.accent2.withAlphaComponent(0.78),
      alignment: .left,
      shadow: nil
    )

    drawText(
      tagText,
      in: CGRect(
        x: bannerRect.maxX - (tagWidth + (14.0 * scale)),
        y: bannerRect.minY + (10.0 * scale),
        width: tagWidth,
        height: 12.0 * scale
      ),
      font: tagFont,
      color: theme.accent1.withAlphaComponent(0.96),
      alignment: .right,
      shadow: nil
    )

    let barRect = CGRect(x: sideInset, y: barTop, width: barWidth, height: barHeight)
    drawWorldFestivalAccuracyBar(
      in: context,
      rect: barRect,
      accuracy: state.accuracyValue,
      scale: scale,
      presentationTimeUs: presentationTimeUs,
      theme: theme,
      renderSize: renderSize
    )

    let repRect = CGRect(
      x: barRect.maxX + gap,
      y: barTop - (repSize * 0.12),
      width: repSize,
      height: repSize
    )
    drawWorldFestivalRepCounter(
      in: context,
      rect: repRect,
      repCount: state.repCount,
      phase: state.phase,
      scale: scale,
      pulse: pulse,
      theme: theme
    )
  }

  private func drawSceneTintTreatment(
    in context: CGContext,
    renderSize: CGSize,
    scale: CGFloat,
    theme: ZodiacTheme,
    pulse: CGFloat
  ) {
    fillRectWithGradient(
      in: context,
      rect: CGRect(x: 0, y: 0, width: renderSize.width, height: renderSize.height * 0.55),
      colors: [
        theme.sceneTintTopColor,
        theme.sceneTintBottomColor.withAlphaComponent(0.44),
        UIColor.clear,
      ],
      locations: [0, 0.48, 1],
      start: CGPoint(x: 0, y: 0),
      end: CGPoint(x: 0, y: renderSize.height * 0.55)
    )

    context.saveGState()
    context.rotate(
      by: -18.0 * .pi / 180.0
    )
    fillRectWithGradient(
      in: context,
      rect: CGRect(
        x: renderSize.width * 0.18,
        y: -(14.0 * scale),
        width: renderSize.width * 0.22,
        height: renderSize.height * 0.78
      ),
      colors: [
        UIColor.clear,
        theme.beamColor.withAlphaComponent(0.30 + (0.12 * pulse)),
        UIColor.clear,
      ],
      locations: [0, 0.46, 1],
      start: CGPoint(x: renderSize.width * 0.18, y: 0),
      end: CGPoint(x: renderSize.width * 0.40, y: renderSize.height * 0.78)
    )
    context.restoreGState()
  }

  private func drawTitleFlourishes(
    in context: CGContext,
    sideInset: CGFloat,
    centerY: CGFloat,
    title: String,
    font: UIFont,
    theme: ZodiacTheme,
    scale: CGFloat
  ) {
    let titleWidth = NSString(string: title).size(withAttributes: [.font: font]).width
    let leftStart = sideInset
    let leftEnd = sideInset + (22.0 * scale)
    let rightStart = sideInset + titleWidth + (12.0 * scale)
    let rightEnd = rightStart + (26.0 * scale)
    let flourishColor = blendedColor(theme.titleStartColor, theme.titleEndColor, factor: 0.44)
    context.setStrokeColor(flourishColor.withAlphaComponent(0.62).cgColor)
    context.setLineWidth(1.15 * scale)
    context.move(to: CGPoint(x: leftStart, y: centerY))
    context.addLine(to: CGPoint(x: leftEnd, y: centerY))
    context.strokePath()
    context.addArc(
      center: CGPoint(x: leftEnd + (7.0 * scale), y: centerY),
      radius: 7.0 * scale,
      startAngle: .pi * 0.62,
      endAngle: .pi * 1.24,
      clockwise: false
    )
    context.strokePath()
    context.move(to: CGPoint(x: rightStart, y: centerY))
    context.addLine(to: CGPoint(x: rightEnd, y: centerY))
    context.strokePath()
    context.addArc(
      center: CGPoint(x: rightEnd - (7.0 * scale), y: centerY),
      radius: 7.0 * scale,
      startAngle: -.pi * 0.24,
      endAngle: .pi * 0.38,
      clockwise: false
    )
    context.strokePath()
  }

  private func drawLeoSkyHeader(
    in context: CGContext,
    rect: CGRect,
    theme: ZodiacTheme,
    scale: CGFloat,
    pulse: CGFloat,
    presentationTimeUs: Int64
  ) {
    let radius = rect.height / 2.0
    let shadowRect = rect.offsetBy(dx: 0, dy: 3.0 * scale)
    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: 3.0 * scale), blur: 10.0 * scale, color: UIColor.black.withAlphaComponent(0.28).cgColor)
    context.setFillColor(UIColor.black.withAlphaComponent(0.08).cgColor)
    context.addPath(UIBezierPath(roundedRect: shadowRect, cornerRadius: radius).cgPath)
    context.fillPath()
    context.restoreGState()

    fillRoundedRect(
      in: context,
      rect: rect,
      radius: radius,
      colors: [
        UIColor(red: 0.03, green: 0.06, blue: 0.13, alpha: 1),
        UIColor(red: 0.07, green: 0.11, blue: 0.22, alpha: 1),
        UIColor(red: 0.22, green: 0.10, blue: 0.09, alpha: 1),
      ],
      locations: [0, 0.58, 1]
    )

    if let warmGlow = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: [
        theme.glowColor.withAlphaComponent(0.28 + (0.10 * pulse)).cgColor,
        theme.glowColor.withAlphaComponent(0.12).cgColor,
        UIColor.clear.cgColor,
      ] as CFArray,
      locations: [0, 0.52, 1]
    ) {
      let glowCenter = CGPoint(
        x: rect.maxX - (rect.width * 0.12),
        y: rect.maxY - (rect.height * 0.08)
      )
      context.saveGState()
      context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
      context.clip()
      context.drawRadialGradient(
        warmGlow,
        startCenter: glowCenter,
        startRadius: 0,
        endCenter: glowCenter,
        endRadius: rect.width * 0.34,
        options: []
      )
      context.restoreGState()
    }

    fillRoundedRect(
      in: context,
      rect: rect,
      radius: radius,
      colors: [
        theme.constellationColor.withAlphaComponent(0.08),
        UIColor.clear,
        theme.beamColor.withAlphaComponent(0.12),
      ],
      locations: [0, 0.44, 1]
    )

    let starField: [(CGFloat, CGFloat, CGFloat)] = [
      (0.08, 0.26, 1.05),
      (0.16, 0.62, 0.90),
      (0.24, 0.18, 1.25),
      (0.31, 0.50, 0.95),
      (0.42, 0.28, 1.05),
      (0.54, 0.66, 0.88),
      (0.63, 0.20, 1.15),
      (0.74, 0.44, 0.92),
      (0.82, 0.24, 1.32),
      (0.90, 0.58, 0.98),
    ]
    for (index, star) in starField.enumerated() {
      let x = rect.minX + (rect.width * star.0)
      let y = rect.minY + (rect.height * star.1)
      let starRadius = max(1.15 * scale, 1.3 * star.2 * scale)
      if index % 3 == 0 {
        context.setFillColor(theme.glowColor.withAlphaComponent(0.24 + (0.08 * pulse)).cgColor)
        context.fillEllipse(
          in: CGRect(
            x: x - (starRadius * 2.1),
            y: y - (starRadius * 2.1),
            width: starRadius * 4.2,
            height: starRadius * 4.2
          )
        )
      }
      context.setFillColor(theme.constellationColor.withAlphaComponent(0.86).cgColor)
      context.fillEllipse(
        in: CGRect(
          x: x - starRadius,
          y: y - starRadius,
          width: starRadius * 2.0,
          height: starRadius * 2.0
        )
      )
    }

    let constellationRect = rect.insetBy(dx: 18.0 * scale, dy: 6.0 * scale)
    let constellationPoints = constellationPoints(for: "leo").map { point in
      CGPoint(
        x: constellationRect.minX + (constellationRect.width * point.x),
        y: constellationRect.minY + (constellationRect.height * point.y)
      )
    }
    let shimmer = CGFloat((sin(Double(presentationTimeUs) / 410000.0) + 1.0) / 2.0)
    context.setShadow(offset: .zero, blur: 6.0 * scale, color: theme.glowColor.withAlphaComponent(0.28 + (0.10 * shimmer)).cgColor)
    context.setStrokeColor(theme.glowColor.withAlphaComponent(0.26 + (0.08 * shimmer)).cgColor)
    context.setLineWidth(3.0 * scale)
    context.beginPath()
    if let first = constellationPoints.first {
      context.move(to: first)
      for point in constellationPoints.dropFirst() {
        context.addLine(to: point)
      }
      context.strokePath()
    }
    context.setShadow(offset: .zero, blur: 0, color: nil)

    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.72).cgColor)
    context.setLineWidth(1.1 * scale)
    context.beginPath()
    if let first = constellationPoints.first {
      context.move(to: first)
      for point in constellationPoints.dropFirst() {
        context.addLine(to: point)
      }
      context.strokePath()
    }

    context.setFillColor(theme.constellationColor.withAlphaComponent(0.96).cgColor)
    for (index, point) in constellationPoints.enumerated() {
      if index % 2 == 0 {
        context.setFillColor(theme.glowColor.withAlphaComponent(0.22 + (0.08 * pulse)).cgColor)
        context.fillEllipse(
          in: CGRect(
            x: point.x - (2.3 * scale),
            y: point.y - (2.3 * scale),
            width: 4.6 * scale,
            height: 4.6 * scale
          )
        )
      }
      context.setFillColor(theme.constellationColor.withAlphaComponent(0.96).cgColor)
      let diameter = index % 3 == 0 ? 3.6 * scale : 2.7 * scale
      context.fillEllipse(
        in: CGRect(
          x: point.x - (diameter / 2.0),
          y: point.y - (diameter / 2.0),
          width: diameter,
          height: diameter
        )
      )
    }

    context.setStrokeColor(theme.beamColor.withAlphaComponent(0.34).cgColor)
    context.setLineWidth(1.1 * scale)
    context.beginPath()
    context.move(to: CGPoint(x: rect.minX + (rect.width * 0.06), y: rect.maxY - (rect.height * 0.18)))
    context.addCurve(
      to: CGPoint(x: rect.maxX - (rect.width * 0.08), y: rect.minY + (rect.height * 0.24)),
      control1: CGPoint(x: rect.minX + (rect.width * 0.28), y: rect.maxY - (rect.height * 0.04)),
      control2: CGPoint(x: rect.minX + (rect.width * 0.56), y: rect.minY + (rect.height * 0.96))
    )
    context.strokePath()

    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.26).cgColor)
    context.setLineWidth(0.9 * scale)
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.strokePath()
  }

  private func drawBarOrnaments(
    in context: CGContext,
    rect: CGRect,
    theme: ZodiacTheme,
    scale: CGFloat
  ) {
    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.42).cgColor)
    context.setLineWidth(1.05 * scale)
    switch theme.signKey {
    case "aries":
      context.addArc(
        center: CGPoint(x: rect.minX + (6.0 * scale), y: rect.minY + (4.0 * scale)),
        radius: 10.0 * scale,
        startAngle: .pi * 1.16,
        endAngle: .pi * 1.66,
        clockwise: false
      )
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.maxX - (6.0 * scale), y: rect.minY + (4.0 * scale)),
        radius: 10.0 * scale,
        startAngle: -.pi * 0.66,
        endAngle: -.pi * 0.16,
        clockwise: false
      )
      context.strokePath()
    case "taurus":
      context.strokeEllipse(in: CGRect(x: rect.minX + (9.5 * scale), y: rect.midY - (4.5 * scale), width: 9.0 * scale, height: 9.0 * scale))
      context.strokeEllipse(in: CGRect(x: rect.maxX - (18.5 * scale), y: rect.midY - (4.5 * scale), width: 9.0 * scale, height: 9.0 * scale))
    case "gemini":
      context.move(to: CGPoint(x: rect.minX + (20.0 * scale), y: rect.minY + (5.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (20.0 * scale), y: rect.maxY - (5.0 * scale)))
      context.strokePath()
      context.move(to: CGPoint(x: rect.minX + (28.0 * scale), y: rect.minY + (5.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (28.0 * scale), y: rect.maxY - (5.0 * scale)))
      context.strokePath()
    case "cancer":
      context.addArc(
        center: CGPoint(x: rect.minX + (26.0 * scale), y: rect.midY),
        radius: 8.0 * scale,
        startAngle: .pi * 0.22,
        endAngle: .pi * 1.60,
        clockwise: false
      )
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.minX + (38.0 * scale), y: rect.midY),
        radius: 8.0 * scale,
        startAngle: -.pi * 0.78,
        endAngle: .pi * 0.60,
        clockwise: false
      )
      context.strokePath()
    case "leo":
      let cx = rect.midX
      context.move(to: CGPoint(x: cx, y: rect.minY - (4.0 * scale)))
      context.addLine(to: CGPoint(x: cx, y: rect.minY + (6.0 * scale)))
      context.strokePath()
      context.move(to: CGPoint(x: cx - (7.0 * scale), y: rect.minY - (2.0 * scale)))
      context.addLine(to: CGPoint(x: cx - (1.0 * scale), y: rect.minY + (6.0 * scale)))
      context.strokePath()
      context.move(to: CGPoint(x: cx + (7.0 * scale), y: rect.minY - (2.0 * scale)))
      context.addLine(to: CGPoint(x: cx + (1.0 * scale), y: rect.minY + (6.0 * scale)))
      context.strokePath()
    case "virgo":
      context.addArc(
        center: CGPoint(x: rect.minX + (18.0 * scale), y: rect.midY),
        radius: 8.0 * scale,
        startAngle: .pi * 1.55,
        endAngle: .pi * 0.24,
        clockwise: true
      )
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.minX + (27.0 * scale), y: rect.midY + (1.0 * scale)),
        radius: 8.0 * scale,
        startAngle: .pi * 1.58,
        endAngle: .pi * 0.20,
        clockwise: true
      )
      context.strokePath()
    case "libra":
      context.move(to: CGPoint(x: rect.midX - (16.0 * scale), y: rect.minY + (7.0 * scale)))
      context.addLine(to: CGPoint(x: rect.midX + (16.0 * scale), y: rect.minY + (7.0 * scale)))
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.midX, y: rect.minY + (9.0 * scale)),
        radius: 12.0 * scale,
        startAngle: .pi,
        endAngle: 0,
        clockwise: false
      )
      context.strokePath()
    case "scorpio":
      context.move(to: CGPoint(x: rect.maxX - (18.0 * scale), y: rect.midY))
      context.addLine(to: CGPoint(x: rect.maxX - (8.0 * scale), y: rect.midY))
      context.addLine(to: CGPoint(x: rect.maxX - (2.0 * scale), y: rect.midY - (4.0 * scale)))
      context.strokePath()
    case "sagittarius":
      context.move(to: CGPoint(x: rect.minX + (14.0 * scale), y: rect.maxY - (8.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (34.0 * scale), y: rect.minY + (8.0 * scale)))
      context.strokePath()
      context.move(to: CGPoint(x: rect.minX + (28.0 * scale), y: rect.minY + (8.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (34.0 * scale), y: rect.minY + (8.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (34.0 * scale), y: rect.minY + (14.0 * scale)))
      context.strokePath()
    case "capricorn":
      context.move(to: CGPoint(x: rect.midX - (14.0 * scale), y: rect.minY + (9.0 * scale)))
      context.addLine(to: CGPoint(x: rect.midX - (6.0 * scale), y: rect.minY + (3.0 * scale)))
      context.addLine(to: CGPoint(x: rect.midX + (2.0 * scale), y: rect.minY + (10.0 * scale)))
      context.addLine(to: CGPoint(x: rect.midX + (10.0 * scale), y: rect.minY + (4.0 * scale)))
      context.strokePath()
    case "aquarius":
      context.move(to: CGPoint(x: rect.minX + (12.0 * scale), y: rect.minY + (9.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (22.0 * scale), y: rect.minY + (5.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (32.0 * scale), y: rect.minY + (9.0 * scale)))
      context.strokePath()
      context.move(to: CGPoint(x: rect.minX + (36.0 * scale), y: rect.minY + (9.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (46.0 * scale), y: rect.minY + (5.0 * scale)))
      context.addLine(to: CGPoint(x: rect.minX + (56.0 * scale), y: rect.minY + (9.0 * scale)))
      context.strokePath()
    case "pisces":
      context.addArc(
        center: CGPoint(x: rect.minX + (22.0 * scale), y: rect.midY),
        radius: 8.0 * scale,
        startAngle: -.pi / 2.0,
        endAngle: .pi / 2.0,
        clockwise: false
      )
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.minX + (32.0 * scale), y: rect.midY),
        radius: 8.0 * scale,
        startAngle: .pi / 2.0,
        endAngle: -.pi / 2.0,
        clockwise: false
      )
      context.strokePath()
    default:
      break
    }
  }

  private func drawCoinAccent(
    in context: CGContext,
    rect: CGRect,
    theme: ZodiacTheme,
    scale: CGFloat
  ) {
    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.34).cgColor)
    context.setLineWidth(1.0 * scale)
    switch theme.signKey {
    case "leo":
      for index in 0..<6 {
        let angle = CGFloat(-90 + (index * 60)) * .pi / 180.0
        let inner = rect.width * 0.56
        let outer = rect.width * 0.66
        let cx = rect.midX
        let cy = rect.midY
        context.move(to: CGPoint(x: cx + (cos(angle) * inner), y: cy + (sin(angle) * inner)))
        context.addLine(to: CGPoint(x: cx + (cos(angle) * outer), y: cy + (sin(angle) * outer)))
        context.strokePath()
      }
    case "aquarius":
      context.addArc(
        center: CGPoint(x: rect.midX, y: rect.midY - (3.0 * scale)),
        radius: rect.width * 0.32,
        startAngle: .pi * 1.10,
        endAngle: .pi * 1.90,
        clockwise: false
      )
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.midX, y: rect.midY + (6.0 * scale)),
        radius: rect.width * 0.32,
        startAngle: .pi * 1.10,
        endAngle: .pi * 1.90,
        clockwise: false
      )
      context.strokePath()
    case "pisces":
      context.addArc(
        center: CGPoint(x: rect.midX - (8.0 * scale), y: rect.midY),
        radius: rect.width * 0.22,
        startAngle: -.pi / 2.0,
        endAngle: .pi / 2.0,
        clockwise: false
      )
      context.strokePath()
      context.addArc(
        center: CGPoint(x: rect.midX + (8.0 * scale), y: rect.midY),
        radius: rect.width * 0.22,
        startAngle: .pi / 2.0,
        endAngle: -.pi / 2.0,
        clockwise: false
      )
      context.strokePath()
    default:
      context.addArc(
        center: CGPoint(x: rect.midX, y: rect.midY),
        radius: rect.width * 0.40,
        startAngle: .pi * 1.14,
        endAngle: .pi * 1.86,
        clockwise: false
      )
      context.strokePath()
    }
  }

  private func drawAccuracyBar(
    in context: CGContext,
    rect: CGRect,
    accuracy: CGFloat,
    scale: CGFloat,
    presentationTimeUs: Int64,
    renderSize: CGSize,
    theme: WorldFestivalTheme? = nil
  ) {
    if let theme = theme,
       isProfessionSignatureVariant(theme.storageKey) {
      drawProfessionSignatureAccuracyBar(
        in: context,
        rect: rect,
        accuracy: accuracy,
        scale: scale,
        presentationTimeUs: presentationTimeUs,
        theme: theme
      )
      return
    }

    let safeAccuracy = max(0, min(1, accuracy))
    let radius = rect.height / 2.0
    let fillColor: UIColor
    if safeAccuracy >= 0.8 {
      fillColor = theme?.accuracyHighColor ?? UIColor(red: 76.0 / 255.0, green: 175.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
    } else if safeAccuracy >= 0.6 {
      fillColor = theme?.accuracyMidColor ?? UIColor(red: 255.0 / 255.0, green: 152.0 / 255.0, blue: 0.0 / 255.0, alpha: 1)
    } else {
      fillColor = theme?.accuracyLowColor ?? UIColor(red: 244.0 / 255.0, green: 67.0 / 255.0, blue: 54.0 / 255.0, alpha: 1)
    }

    let backgroundColors = [
      (theme?.primaryStart ?? UIColor(red: 10.0 / 255.0, green: 11.0 / 255.0, blue: 13.0 / 255.0, alpha: 1)).withAlphaComponent(0.97),
      (theme?.primaryEnd ?? UIColor(red: 22.0 / 255.0, green: 29.0 / 255.0, blue: 40.0 / 255.0, alpha: 1)).withAlphaComponent(0.95),
    ]
    fillRoundedRect(
      in: context,
      rect: rect,
      radius: radius,
      colors: backgroundColors,
      locations: [0, 1]
    )

    context.setStrokeColor(UIColor.white.withAlphaComponent(0.32).cgColor)
    context.setLineWidth(max(1.05, 1.05 * scale))
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.strokePath()

    let innerRect = rect.insetBy(dx: 2.0 * scale, dy: 2.0 * scale)
    context.setFillColor(UIColor.black.withAlphaComponent(0.22).cgColor)
    context.addPath(UIBezierPath(roundedRect: innerRect, cornerRadius: innerRect.height / 2.0).cgPath)
    context.fillPath()

    let fillRect = CGRect(
      x: innerRect.minX,
      y: innerRect.minY,
      width: innerRect.width * safeAccuracy,
      height: innerRect.height
    )
    if fillRect.width > 0 {
      context.saveGState()
      context.setShadow(
        offset: .zero,
        blur: 9.0 * scale,
        color: fillColor.withAlphaComponent(0.26).cgColor
      )
      context.setFillColor(fillColor.withAlphaComponent(0.92).cgColor)
      context.addPath(UIBezierPath(roundedRect: fillRect, cornerRadius: fillRect.height / 2.0).cgPath)
      context.fillPath()
      context.restoreGState()

      fillRoundedRect(
        in: context,
        rect: fillRect,
        radius: fillRect.height / 2.0,
        colors: [
          fillColor.withAlphaComponent(0.98),
          fillColor.withAlphaComponent(0.90),
          fillColor.withAlphaComponent(0.82),
        ],
        locations: [0, 0.56, 1]
      )

      let shimmerDuration: CGFloat = 1900.0
      let shimmerProgress = CGFloat((presentationTimeUs / 1000) % Int64(shimmerDuration)) / shimmerDuration
      let shimmerX = fillRect.minX + (fillRect.width * shimmerProgress)
      context.saveGState()
      context.addPath(UIBezierPath(roundedRect: fillRect, cornerRadius: fillRect.height / 2.0).cgPath)
      context.clip()
      fillRectWithGradient(
        in: context,
        rect: CGRect(
          x: shimmerX - (18.0 * scale),
          y: fillRect.minY,
          width: 36.0 * scale,
          height: fillRect.height
        ),
        colors: [
          UIColor.clear,
          UIColor.white.withAlphaComponent(0.62),
          UIColor.clear,
        ],
        start: CGPoint(x: shimmerX - (18.0 * scale), y: fillRect.minY),
        end: CGPoint(x: shimmerX + (18.0 * scale), y: fillRect.maxY),
        locations: [0, 0.5, 1]
      )
      context.restoreGState()
    }

    let thresholdX = innerRect.minX + (innerRect.width * 0.8)
    context.setFillColor((theme?.thresholdLineColor ?? UIColor.white).withAlphaComponent(0.68).cgColor)
    context.addPath(
      UIBezierPath(
        roundedRect: CGRect(
          x: thresholdX - (1.2 * scale),
          y: innerRect.minY + (2.0 * scale),
          width: 2.4 * scale,
          height: max(0, innerRect.height - (4.0 * scale))
        ),
        cornerRadius: 9.0 * scale
      ).cgPath
    )
    context.fillPath()

    drawText(
      "ACCURACY",
      in: CGRect(x: innerRect.minX + (10.0 * scale), y: rect.minY, width: rect.width * 0.45, height: rect.height),
      font: UIFont.systemFont(ofSize: max(10.0, 10.0 * scale), weight: .semibold),
      color: UIColor.white.withAlphaComponent(0.88),
      alignment: .left
    )
    drawText(
      "\(Int((max(0, min(1, accuracy)) * 100.0).rounded()))%",
      in: CGRect(x: rect.midX, y: rect.minY, width: rect.width - (12.0 * scale), height: rect.height),
      font: UIFont.systemFont(ofSize: max(10.0, 10.0 * scale), weight: .bold),
      color: UIColor.white.withAlphaComponent(0.96),
      alignment: .right
    )
  }

  private func drawZodiacAccuracyBar(
    in context: CGContext,
    rect: CGRect,
    accuracy: CGFloat,
    scale: CGFloat,
    presentationTimeUs: Int64,
    theme: ZodiacTheme,
    renderSize: CGSize
  ) {
    let radius = rect.height / 2.0
    let shadowRect = rect.offsetBy(dx: 0, dy: 3.0 * scale)
    context.setFillColor(UIColor.black.withAlphaComponent(0.24).cgColor)
    context.addPath(UIBezierPath(roundedRect: shadowRect, cornerRadius: radius).cgPath)
    context.fillPath()

    fillRoundedRect(
      in: context,
      rect: rect,
      radius: radius,
      colors: theme.shellColors,
      locations: [0, 0.64, 1]
    )

    let fillRect = CGRect(
      x: rect.minX + (2.0 * scale),
      y: rect.minY + (2.0 * scale),
      width: max(0, (rect.width - (2.0 * scale)) * min(1.0, max(0.0, accuracy))),
      height: rect.height - (4.0 * scale)
    )
    if fillRect.width > 6.0 * scale {
      fillRoundedRect(
        in: context,
        rect: fillRect,
        radius: radius * 0.88,
        colors: theme.fillColors,
        locations: [0, 0.54, 1]
      )

      let shimmerProgress = CGFloat((presentationTimeUs / 1000) % 2600) / 2600.0
      let shimmerX = fillRect.minX + (fillRect.width * shimmerProgress)
      context.saveGState()
      context.addPath(UIBezierPath(roundedRect: fillRect, cornerRadius: radius * 0.88).cgPath)
      context.clip()
      fillRectWithGradient(
        in: context,
        rect: CGRect(
          x: shimmerX - (24.0 * scale),
          y: fillRect.minY,
          width: 48.0 * scale,
          height: fillRect.height
        ),
        colors: [
          UIColor.clear,
          UIColor(red: 1.0, green: 0.97, blue: 0.88, alpha: 0.38),
          UIColor.clear,
        ],
        locations: [0, 0.5, 1],
        start: CGPoint(x: shimmerX - (24.0 * scale), y: fillRect.minY),
        end: CGPoint(x: shimmerX + (24.0 * scale), y: fillRect.maxY)
      )
      context.restoreGState()
    }

    context.setStrokeColor(theme.glowColor.withAlphaComponent(0.84).cgColor)
    context.setLineWidth(max(1.1, 1.15 * scale))
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.strokePath()

    let insetRect = rect.insetBy(dx: 2.0 * scale, dy: 2.0 * scale)
    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.24).cgColor)
    context.setLineWidth(0.8 * scale)
    context.addPath(UIBezierPath(roundedRect: insetRect, cornerRadius: radius).cgPath)
    context.strokePath()

    let normalizedPoints = constellationPoints(for: theme.signKey)
    let points = normalizedPoints.map { point in
      CGPoint(
        x: rect.minX + (rect.width * point.x),
        y: rect.minY + (rect.height * point.y)
      )
    }
    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.48).cgColor)
    context.setLineWidth(0.9 * scale)
    context.beginPath()
    if let first = points.first {
      context.move(to: first)
      for point in points.dropFirst() {
        context.addLine(to: point)
      }
      context.strokePath()
    }
    context.setFillColor(theme.constellationColor.withAlphaComponent(0.80).cgColor)
    for (index, point) in points.enumerated() {
      let diameter = index % 3 == 0 ? 3.0 * scale : 2.2 * scale
      context.fillEllipse(
        in: CGRect(
          x: point.x - (diameter / 2.0),
          y: point.y - (diameter / 2.0),
          width: diameter,
          height: diameter
        )
      )
    }

    let medallionRadius = rect.height * 0.42
    let medallionCenter = CGPoint(
      x: rect.maxX - (rect.height * 0.78),
      y: rect.midY
    )
    fillCircleWithRadialGradient(
      in: context,
      center: medallionCenter,
      radius: medallionRadius,
      colors: theme.fillColors,
      locations: [0, 0.58, 1]
    )
    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.54).cgColor)
    context.setLineWidth(0.9 * scale)
    context.strokeEllipse(
      in: CGRect(
        x: medallionCenter.x - medallionRadius,
        y: medallionCenter.y - medallionRadius,
        width: medallionRadius * 2.0,
        height: medallionRadius * 2.0
      )
    )

    drawCenteredText(
      "\u{2648}",
      in: CGRect(
        x: medallionCenter.x - medallionRadius,
        y: medallionCenter.y - medallionRadius,
        width: medallionRadius * 2.0,
        height: medallionRadius * 2.0
      ),
      font: UIFont.systemFont(ofSize: max(14.0, rect.height * 0.58), weight: .bold),
      color: theme.engravingColor.withAlphaComponent(0.95)
    )

    drawCenteredText(
      String(format: "%.1f%%", accuracy * 100.0),
      in: CGRect(
        x: rect.minX,
        y: rect.minY,
        width: rect.width - (18.0 * scale),
        height: rect.height
      ),
      font: UIFont.systemFont(ofSize: max(13.0, rect.height * 0.46), weight: .bold),
      color: UIColor(red: 1.0, green: 0.98, blue: 0.93, alpha: 0.96)
    )

    guard accuracy >= 0.8 else {
      return
    }

    let thresholdProgress = min(1.0, max(0.0, (accuracy - 0.8) / 0.2))
    let dropDurationMs = max(CGFloat(1800.0), CGFloat(3000.0) - (CGFloat(600.0) * thresholdProgress))
    let dropCycle = CGFloat((presentationTimeUs / 1000) % Int64(dropDurationMs)) / dropDurationMs
    let easedDrop = dropCycle * dropCycle
    let originX = min(rect.maxX - (rect.height * 0.78), rect.minX + (rect.width * accuracy))
    let targetY = max(renderSize.height * 0.5, rect.maxY + (renderSize.height * 0.08))
    let dropletY = rect.maxY + ((targetY - rect.maxY) * easedDrop)
    let dropletX = originX + (sin(CGFloat(presentationTimeUs) / 540000.0) * (4.0 * scale))
    let fadeStart: CGFloat = 0.72
    let fadeProgress = max(0.0, min(1.0, (dropCycle - fadeStart) / (1.0 - fadeStart)))
    let dropletAlpha = (1.0 - fadeProgress) * (0.72 + (0.28 * thresholdProgress))
    let dropletRadius = (4.4 + (2.2 * thresholdProgress)) * scale

    guard dropletAlpha > 0.01 else {
      return
    }

    if dropCycle < 0.34 {
      let streamAlpha = dropletAlpha * (1.0 - (dropCycle / 0.34))
      let streamPath = UIBezierPath()
      streamPath.move(to: CGPoint(x: originX, y: rect.maxY - (1.0 * scale)))
      streamPath.addCurve(
        to: CGPoint(x: dropletX, y: dropletY - dropletRadius),
        controlPoint1: CGPoint(x: originX + (3.0 * scale), y: rect.maxY + ((dropletY - rect.maxY) * 0.18)),
        controlPoint2: CGPoint(x: dropletX - (6.0 * scale), y: rect.maxY + ((dropletY - rect.maxY) * 0.62))
      )

      context.saveGState()
      context.addPath(streamPath.cgPath)
      context.setLineWidth(max(1.2 * scale, dropletRadius * 0.55))
      context.replacePathWithStrokedPath()
      context.clip()
      fillRectWithGradient(
        in: context,
        rect: CGRect(
          x: min(originX, dropletX) - (12.0 * scale),
          y: rect.maxY - (2.0 * scale),
          width: abs(dropletX - originX) + (24.0 * scale),
          height: max(12.0 * scale, dropletY - rect.maxY + (dropletRadius * 2.0))
        ),
        colors: [
          theme.glowColor.withAlphaComponent(0.0),
          theme.glowColor.withAlphaComponent(streamAlpha * 0.78),
          theme.fillColors[1].withAlphaComponent(streamAlpha * 0.42),
          UIColor.clear,
        ],
        locations: [0, 0.20, 0.72, 1],
        start: CGPoint(x: originX, y: rect.maxY),
        end: CGPoint(x: dropletX, y: dropletY)
      )
      context.restoreGState()
    }

    fillCircleWithRadialGradient(
      in: context,
      center: CGPoint(x: dropletX, y: dropletY),
      radius: dropletRadius * 1.9,
      colors: [
        theme.glowColor.withAlphaComponent(dropletAlpha * 0.34),
        theme.glowColor.withAlphaComponent(dropletAlpha * 0.10),
        UIColor.clear,
      ],
      locations: [0, 0.54, 1]
    )
    fillCircleWithRadialGradient(
      in: context,
      center: CGPoint(x: dropletX, y: dropletY),
      radius: dropletRadius,
      colors: [
        UIColor.white.withAlphaComponent(dropletAlpha * 0.98),
        theme.fillColors[1].withAlphaComponent(dropletAlpha * 0.72),
        theme.fillColors[2].withAlphaComponent(dropletAlpha * 0.18),
        UIColor.clear,
      ],
      locations: [0, 0.24, 0.72, 1]
    )
  }

  private func drawThresholdDropletEffect(
    in context: CGContext,
    originX: CGFloat,
    originY: CGFloat,
    targetY: CGFloat,
    accuracy: CGFloat,
    scale: CGFloat,
    presentationTimeUs: Int64,
    glowColor: UIColor,
    fillMidColor: UIColor,
    fillEndColor: UIColor,
    swayAmplitude: CGFloat
  ) {
    guard accuracy >= 0.8 else {
      return
    }

    let thresholdProgress = min(1.0, max(0.0, (accuracy - 0.8) / 0.2))
    let dropDurationMs = max(CGFloat(1800.0), CGFloat(3000.0) - (CGFloat(600.0) * thresholdProgress))
    let dropCycle = CGFloat((presentationTimeUs / 1000) % Int64(dropDurationMs)) / dropDurationMs
    let easedDrop = dropCycle * dropCycle
    let dropletY = originY + ((targetY - originY) * easedDrop)
    let dropletX = originX + (sin(CGFloat(presentationTimeUs) / 540000.0) * swayAmplitude)
    let fadeStart: CGFloat = 0.72
    let fadeProgress = max(0.0, min(1.0, (dropCycle - fadeStart) / (1.0 - fadeStart)))
    let dropletAlpha = (1.0 - fadeProgress) * (0.72 + (0.28 * thresholdProgress))
    let dropletRadius = (4.4 + (2.2 * thresholdProgress)) * scale

    guard dropletAlpha > 0.01 else {
      return
    }

    if dropCycle < 0.34 {
      let streamAlpha = dropletAlpha * (1.0 - (dropCycle / 0.34))
      let streamPath = UIBezierPath()
      streamPath.move(to: CGPoint(x: originX, y: originY - (1.0 * scale)))
      streamPath.addCurve(
        to: CGPoint(x: dropletX, y: dropletY - dropletRadius),
        controlPoint1: CGPoint(x: originX + (3.0 * scale), y: originY + ((dropletY - originY) * 0.18)),
        controlPoint2: CGPoint(x: dropletX - (6.0 * scale), y: originY + ((dropletY - originY) * 0.62))
      )

      context.saveGState()
      context.addPath(streamPath.cgPath)
      context.setLineWidth(max(1.2 * scale, dropletRadius * 0.55))
      context.replacePathWithStrokedPath()
      context.clip()
      fillRectWithGradient(
        in: context,
        rect: CGRect(
          x: min(originX, dropletX) - (12.0 * scale),
          y: originY - (2.0 * scale),
          width: abs(dropletX - originX) + (24.0 * scale),
          height: max(12.0 * scale, dropletY - originY + (dropletRadius * 2.0))
        ),
        colors: [
          glowColor.withAlphaComponent(0.0),
          glowColor.withAlphaComponent(streamAlpha * 0.78),
          fillMidColor.withAlphaComponent(streamAlpha * 0.42),
          UIColor.clear,
        ],
        locations: [0, 0.20, 0.72, 1],
        start: CGPoint(x: originX, y: originY),
        end: CGPoint(x: dropletX, y: dropletY)
      )
      context.restoreGState()
    }

    fillCircleWithRadialGradient(
      in: context,
      center: CGPoint(x: dropletX, y: dropletY),
      radius: dropletRadius * 1.9,
      colors: [
        glowColor.withAlphaComponent(dropletAlpha * 0.34),
        glowColor.withAlphaComponent(dropletAlpha * 0.10),
        UIColor.clear,
      ],
      locations: [0, 0.54, 1]
    )
    fillCircleWithRadialGradient(
      in: context,
      center: CGPoint(x: dropletX, y: dropletY),
      radius: dropletRadius,
      colors: [
        UIColor.white.withAlphaComponent(dropletAlpha * 0.98),
        fillMidColor.withAlphaComponent(dropletAlpha * 0.72),
        fillEndColor.withAlphaComponent(dropletAlpha * 0.18),
        UIColor.clear,
      ],
      locations: [0, 0.24, 0.72, 1]
    )
  }

  private func drawWorldFestivalAccuracyBar(
    in context: CGContext,
    rect: CGRect,
    accuracy: CGFloat,
    scale: CGFloat,
    presentationTimeUs: Int64,
    theme: WorldFestivalTheme,
    renderSize: CGSize
  ) {
    let radius = rect.height / 2.0
    let shadowRect = rect.offsetBy(dx: 0, dy: 3.0 * scale)
    context.setFillColor(UIColor.black.withAlphaComponent(0.20).cgColor)
    context.addPath(UIBezierPath(roundedRect: shadowRect, cornerRadius: radius).cgPath)
    context.fillPath()

    fillRoundedRect(
      in: context,
      rect: rect,
      radius: radius,
      colors: [
        theme.primaryStart.withAlphaComponent(0.94),
        theme.primaryEnd.withAlphaComponent(0.90),
      ],
      locations: [0, 1]
    )

    let safeAccuracy = min(1.0, max(0.0, accuracy))
    let fillRect = CGRect(
      x: rect.minX + (2.0 * scale),
      y: rect.minY + (2.0 * scale),
      width: max(0, (rect.width - (4.0 * scale)) * safeAccuracy),
      height: rect.height - (4.0 * scale)
    )
    if fillRect.width > 4.0 * scale {
      fillRoundedRect(
        in: context,
        rect: fillRect,
        radius: radius * 0.86,
        colors: theme.accuracyBarGradient,
        locations: [0, 0.56, 1]
      )
      let shimmerProgress = CGFloat((presentationTimeUs / 1000) % 2400) / 2400.0
      let shimmerX = fillRect.minX + (fillRect.width * shimmerProgress)
      context.saveGState()
      context.addPath(UIBezierPath(roundedRect: fillRect, cornerRadius: radius * 0.86).cgPath)
      context.clip()
      fillRectWithGradient(
        in: context,
        rect: CGRect(x: shimmerX - (22.0 * scale), y: fillRect.minY, width: 44.0 * scale, height: fillRect.height),
        colors: [
          UIColor.clear,
          UIColor.white.withAlphaComponent(0.22),
          UIColor.clear,
        ],
        locations: [0, 0.5, 1],
        start: CGPoint(x: shimmerX - (22.0 * scale), y: fillRect.minY),
        end: CGPoint(x: shimmerX + (22.0 * scale), y: fillRect.maxY)
      )
      context.restoreGState()
    }

    let thresholdX = rect.minX + (rect.width * 0.8)
    let markerRect = CGRect(
      x: thresholdX - (1.8 * scale),
      y: rect.minY + (3.0 * scale),
      width: 3.6 * scale,
      height: rect.height - (6.0 * scale)
    )
    context.setFillColor(theme.thresholdLineColor.withAlphaComponent(0.92).cgColor)
    context.addPath(UIBezierPath(roundedRect: markerRect, cornerRadius: 10.0 * scale).cgPath)
    context.fillPath()

    drawThresholdDropletEffect(
      in: context,
      originX: thresholdX,
      originY: rect.maxY - scale,
      targetY: max(renderSize.height * 0.5, rect.maxY + (renderSize.height * 0.22)),
      accuracy: safeAccuracy,
      scale: scale,
      presentationTimeUs: presentationTimeUs,
      glowColor: theme.glowColor,
      fillMidColor: theme.accent1,
      fillEndColor: theme.accuracyHighColor,
      swayAmplitude: 6.0 * scale
    )

    context.setStrokeColor(theme.glowColor.withAlphaComponent(0.72).cgColor)
    context.setLineWidth(1.0 * scale)
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.strokePath()

    drawCenteredText(
      String(format: "%.1f%%", accuracy * 100.0),
      in: CGRect(x: rect.minX, y: rect.minY, width: rect.width - (18.0 * scale), height: rect.height),
      font: UIFont.systemFont(ofSize: max(13.0, rect.height * 0.46), weight: .bold),
      color: theme.accent2.withAlphaComponent(0.96)
    )
  }

  private func drawWorldFestivalRepCounter(
    in context: CGContext,
    rect: CGRect,
    repCount: Int,
    phase: String,
    scale: CGFloat,
    pulse: CGFloat,
    theme: WorldFestivalTheme
  ) {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = rect.width / 2.0
    let phaseColor: UIColor
    switch phase {
    case "down":
      phaseColor = theme.phaseDownColor
    case "hold":
      phaseColor = theme.phaseHoldColor
    default:
      phaseColor = theme.phaseUpColor
    }
    let equipmentIndex = worldFestivalEquipmentIndex(theme.storageKey)

    if let glowGradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: [
        phaseColor.withAlphaComponent(0.28 + (0.16 * pulse)).cgColor,
        theme.glowColor.withAlphaComponent(0.10).cgColor,
        UIColor.clear.cgColor,
      ] as CFArray,
      locations: [0, 0.58, 1]
    ) {
      context.drawRadialGradient(
        glowGradient,
        startCenter: center,
        startRadius: 0,
        endCenter: center,
        endRadius: radius + (12.0 * scale),
        options: []
      )
    }

    fillCircleWithRadialGradient(
      in: context,
      center: center,
      radius: radius,
      colors: theme.ringGradient,
      locations: [0, 0.56, 1]
    )
    fillCircleWithRadialGradient(
      in: context,
      center: center,
      radius: radius * 0.78,
      colors: [
        theme.primaryStart.withAlphaComponent(0.96),
        theme.primaryEnd.withAlphaComponent(0.92),
      ],
      locations: [0, 1]
    )
    if equipmentIndex >= 0 {
      let equipmentRect = CGRect(
        x: center.x - (radius * 0.56),
        y: center.y - (radius * 0.50),
        width: radius * 1.12,
        height: radius * 1.00
      )
      drawWorldFestivalEquipmentCore(
        in: context,
        rect: equipmentRect,
        theme: theme,
        phaseColor: phaseColor,
        pulse: pulse,
        index: equipmentIndex
      )
    }

    context.setStrokeColor(theme.accent1.withAlphaComponent(0.52).cgColor)
    context.setLineWidth(1.2 * scale)
    context.strokeEllipse(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height))

    if !theme.cornerIcon.isEmpty {
      if isPadaukBranchIcon(theme.cornerIcon) {
        drawPadaukBranch(
          in: context,
          rect: CGRect(
            x: rect.midX - (rect.width * 0.14),
            y: rect.minY + (6.0 * scale),
            width: rect.width * 0.28,
            height: rect.height * 0.22
          ),
          alpha: 0.96
        )
      } else {
        drawText(
          theme.cornerIcon,
          in: CGRect(x: rect.minX, y: rect.minY + (8.0 * scale), width: rect.width, height: 18.0 * scale),
          font: UIFont.systemFont(ofSize: max(13.0, 15.0 * scale)),
          color: theme.accent2.withAlphaComponent(0.88),
          alignment: .center,
          shadow: nil
        )
      }
    }

    let repScale: CGFloat = equipmentIndex >= 0 ? 0.27 : 0.30
    drawCenteredText(
      "\(repCount)",
      in: rect,
      font: UIFont.systemFont(ofSize: max(24.0, rect.width * repScale), weight: .black),
      color: phaseColor.withAlphaComponent(0.98)
    )
  }

  private func worldFestivalEquipmentIndex(_ storageKey: String) -> Int {
    switch storageKey.lowercased() {
    case "new_year": return 0
    case "harbin_ice": return 1
    case "australian_open": return 2
    case "sundance": return 3
    case "venice_carnival": return 4
    case "sapporo_snow": return 5
    case "super_bowl": return 6
    case "berlinale": return 7
    case "rio_carnival": return 8
    case "daytona_500": return 9
    case "tokyo_marathon": return 10
    case "the_oscars": return 11
    case "sxsw": return 12
    case "las_fallas": return 13
    case "happiness_day": return 14
    case "hanami": return 15
    case "april_fools": return 16
    case "coachella": return 17
    case "boston_marathon": return 18
    case "earth_day": return 19
    case "london_marathon": return 20
    case "dance_day": return 21
    case "met_gala": return 22
    case "cinco_de_mayo": return 23
    case "cannes": return 24
    case "eurovision": return 25
    case "halloween": return 26
    case "thanksgiving": return 27
    case "diwali": return 28
    case "christmas": return 29
    case "new_years_eve": return 30
    case "french_open": return 31
    case "vivid_sydney": return 32
    case "global_running_day": return 33
    case "environment_day": return 34
    case "white_nights": return 35
    case "midsummer": return 36
    case "yoga_day": return 37
    case "glastonbury": return 38
    case "wimbledon": return 39
    default: return -1
    }
  }

  private func drawWorldFestivalEquipmentCore(
    in context: CGContext,
    rect: CGRect,
    theme: WorldFestivalTheme,
    phaseColor: UIColor,
    pulse: CGFloat,
    index: Int
  ) {
    let path = worldFestivalEquipmentPath(in: rect, index: index)
    context.saveGState()
    context.addPath(path.cgPath)
    context.clip()
    fillRectWithGradient(
      in: context,
      rect: rect,
      colors: [
        blendedColor(theme.primaryStart, theme.accent1, factor: 0.20).withAlphaComponent(0.94),
        blendedColor(theme.primaryEnd, theme.accent2, factor: 0.20).withAlphaComponent(0.92),
      ],
      locations: [0, 1],
      start: CGPoint(x: rect.minX, y: rect.minY),
      end: CGPoint(x: rect.maxX, y: rect.maxY)
    )
    context.restoreGState()

    context.addPath(path.cgPath)
    context.setStrokeColor(theme.accent2.withAlphaComponent(0.24).cgColor)
    context.setLineWidth(max(1.0, rect.width * 0.014))
    context.strokePath()

    context.addPath(path.cgPath)
    context.setStrokeColor(phaseColor.withAlphaComponent(0.48 + (0.18 * pulse)).cgColor)
    context.setLineWidth(max(1.0, rect.width * 0.016))
    context.strokePath()
  }

  private func worldFestivalEquipmentPath(in rect: CGRect, index: Int) -> UIBezierPath {
    let inset = min(rect.width, rect.height) * 0.06
    let r = rect.insetBy(dx: inset, dy: inset)
    let w = r.width
    let h = r.height
    let cx = r.midX
    let cy = r.midY
    let path = UIBezierPath()

    switch index {
    case 0:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.12), y: cy - (h * 0.18), width: w * 0.76, height: h * 0.36), cornerRadius: h * 0.16))
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX, y: cy - (h * 0.28), width: w * 0.24, height: h * 0.56)))
      path.append(UIBezierPath(ovalIn: CGRect(x: r.maxX - (w * 0.24), y: cy - (h * 0.28), width: w * 0.24, height: h * 0.56)))
    case 1:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.12), y: r.minY + (h * 0.26), width: w * 0.76, height: h * 0.74)))
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.18), y: r.minY, width: w * 0.36, height: h * 0.28), cornerRadius: h * 0.12))
    case 2:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.08), y: r.minY, width: w * 0.64, height: h * 0.90)))
      path.append(UIBezierPath(roundedRect: CGRect(x: r.maxX - (w * 0.34), y: cy - (h * 0.08), width: w * 0.34, height: h * 0.16), cornerRadius: h * 0.06))
    case 3:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.22), width: w * 0.84, height: h * 0.78), cornerRadius: h * 0.08))
      path.move(to: CGPoint(x: r.minX + (w * 0.14), y: r.minY + (h * 0.20)))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.14), y: r.minY))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.06), y: r.minY + (h * 0.18)))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.22), y: r.minY + (h * 0.32)))
      path.close()
    case 4:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.04), y: r.minY + (h * 0.18), width: w * 0.92, height: h * 0.64), cornerRadius: h * 0.28))
    case 5:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX, y: cy - (h * 0.20), width: w, height: h * 0.40), cornerRadius: h * 0.24))
    case 6:
      path.move(to: CGPoint(x: r.minX + (w * 0.10), y: cy + (h * 0.22)))
      path.addCurve(to: CGPoint(x: r.maxX - (w * 0.16), y: r.minY + (h * 0.16)),
                    controlPoint1: CGPoint(x: r.minX + (w * 0.06), y: cy - (h * 0.22)),
                    controlPoint2: CGPoint(x: r.minX + (w * 0.36), y: r.minY))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.06), y: cy - (h * 0.02)))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.18), y: cy + (h * 0.22)))
      path.close()
    case 7:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.18), width: w * 0.84, height: h * 0.82), cornerRadius: h * 0.08))
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.16), y: r.minY, width: w * 0.26, height: h * 0.26)))
      path.append(UIBezierPath(ovalIn: CGRect(x: r.maxX - (w * 0.42), y: r.minY, width: w * 0.26, height: h * 0.26)))
    case 8:
      path.move(to: CGPoint(x: r.minX + (w * 0.16), y: r.minY))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.16), y: r.minY))
      path.addLine(to: CGPoint(x: r.maxX, y: cy))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.16), y: r.maxY))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.16), y: r.maxY))
      path.addLine(to: CGPoint(x: r.minX, y: cy))
      path.close()
    case 9:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.06), y: r.minY + (h * 0.06), width: w * 0.88, height: h * 0.88)))
      path.append(UIBezierPath(ovalIn: CGRect(x: cx - (w * 0.12), y: cy - (h * 0.12), width: w * 0.24, height: h * 0.24)))
    case 10:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.10), y: r.minY + (h * 0.06), width: w * 0.80, height: h * 0.94), cornerRadius: h * 0.10))
    case 11:
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.20), y: r.minY + (h * 0.16), width: w * 0.40, height: h * 0.66), cornerRadius: h * 0.08))
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.32), y: r.maxY - (h * 0.16), width: w * 0.64, height: h * 0.16), cornerRadius: h * 0.05))
    case 12:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.06), y: r.minY + (h * 0.18), width: w * 0.88, height: h * 0.82), cornerRadius: h * 0.08))
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.26), y: r.minY, width: w * 0.48, height: h * 0.22), cornerRadius: h * 0.06))
    case 13:
      path.move(to: CGPoint(x: cx - (w * 0.10), y: r.minY + (h * 0.24)))
      path.addLine(to: CGPoint(x: cx + (w * 0.10), y: r.minY + (h * 0.24)))
      path.addLine(to: CGPoint(x: cx + (w * 0.20), y: r.maxY))
      path.addLine(to: CGPoint(x: cx - (w * 0.20), y: r.maxY))
      path.close()
    case 14:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.16), width: w * 0.84, height: h * 0.76), cornerRadius: h * 0.20))
    case 15:
      path.move(to: CGPoint(x: cx, y: r.minY))
      path.addCurve(to: CGPoint(x: cx, y: r.maxY),
                    controlPoint1: CGPoint(x: r.maxX, y: r.minY + (h * 0.24)),
                    controlPoint2: CGPoint(x: r.maxX - (w * 0.02), y: r.maxY))
      path.addCurve(to: CGPoint(x: cx, y: r.minY),
                    controlPoint1: CGPoint(x: r.minX + (w * 0.02), y: r.maxY),
                    controlPoint2: CGPoint(x: r.minX, y: r.minY + (h * 0.24)))
      path.close()
    case 16:
      path.move(to: CGPoint(x: r.minX + (w * 0.10), y: r.maxY - (h * 0.08)))
      path.addLine(to: CGPoint(x: cx, y: r.minY))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.10), y: r.maxY - (h * 0.08)))
      path.close()
    case 17:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.16), y: r.minY, width: w * 0.68, height: h), cornerRadius: h * 0.08))
      path.append(UIBezierPath(ovalIn: CGRect(x: cx - (w * 0.18), y: cy - (h * 0.18), width: w * 0.36, height: h * 0.36)))
    case 18:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.14), y: r.minY + (h * 0.16), width: w * 0.72, height: h * 0.84)))
      path.move(to: CGPoint(x: cx - (w * 0.16), y: r.minY + (h * 0.18)))
      path.addLine(to: CGPoint(x: cx - (w * 0.03), y: r.minY))
      path.addLine(to: CGPoint(x: cx + (w * 0.03), y: r.minY))
      path.addLine(to: CGPoint(x: cx + (w * 0.16), y: r.minY + (h * 0.18)))
      path.close()
    case 19:
      path.move(to: CGPoint(x: cx - (w * 0.04), y: r.minY + (h * 0.06)))
      path.addCurve(to: CGPoint(x: cx - (w * 0.06), y: r.maxY),
                    controlPoint1: CGPoint(x: r.maxX, y: r.minY + (h * 0.12)),
                    controlPoint2: CGPoint(x: r.maxX - (w * 0.06), y: r.maxY - (h * 0.04)))
      path.addCurve(to: CGPoint(x: cx - (w * 0.04), y: r.minY + (h * 0.06)),
                    controlPoint1: CGPoint(x: r.minX + (w * 0.02), y: r.maxY - (h * 0.18)),
                    controlPoint2: CGPoint(x: r.minX + (w * 0.02), y: r.minY + (h * 0.24)))
      path.close()
    case 20:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.10), y: r.minY + (h * 0.10), width: w * 0.80, height: h * 0.90)))
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.10), y: r.minY, width: w * 0.20, height: h * 0.14), cornerRadius: h * 0.04))
    case 21:
      path.move(to: CGPoint(x: r.minX + (w * 0.08), y: cy + (h * 0.10)))
      path.addCurve(to: CGPoint(x: r.maxX - (w * 0.10), y: cy + (h * 0.22)),
                    controlPoint1: CGPoint(x: r.minX + (w * 0.30), y: r.minY),
                    controlPoint2: CGPoint(x: r.maxX - (w * 0.04), y: r.minY + (h * 0.18)))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.18), y: r.maxY - (h * 0.02)))
      path.close()
    case 22:
      path.move(to: CGPoint(x: cx, y: cy))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.04), y: r.minY + (h * 0.16)))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.30), y: cy))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.04), y: r.maxY - (h * 0.16)))
      path.close()
      path.move(to: CGPoint(x: cx, y: cy))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.04), y: r.minY + (h * 0.16)))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.30), y: cy))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.04), y: r.maxY - (h * 0.16)))
      path.close()
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.06), y: cy - (h * 0.08), width: w * 0.12, height: h * 0.16), cornerRadius: h * 0.04))
    case 23:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.04), y: cy + (h * 0.18), width: w * 0.92, height: h * 0.20), cornerRadius: h * 0.12))
      path.append(UIBezierPath(ovalIn: CGRect(x: cx - (w * 0.24), y: r.minY + (h * 0.12), width: w * 0.48, height: h * 0.44)))
    case 24:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.08), width: w * 0.84, height: h * 0.84)))
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.08), y: cy - (h * 0.08), width: w * 0.16, height: h * 0.16), cornerRadius: h * 0.03))
    case 25:
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.14), y: r.minY + (h * 0.06), width: w * 0.28, height: h * 0.56), cornerRadius: h * 0.14))
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.06), y: cy + (h * 0.08), width: w * 0.12, height: h * 0.40), cornerRadius: h * 0.04))
    case 26:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.14), width: w * 0.84, height: h * 0.86)))
      path.append(UIBezierPath(roundedRect: CGRect(x: cx - (w * 0.04), y: r.minY, width: w * 0.08, height: h * 0.16), cornerRadius: h * 0.02))
    case 27:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.10), y: r.maxY - (h * 0.24), width: w * 0.80, height: h * 0.24)))
      path.addArc(withCenter: CGPoint(x: cx, y: r.maxY - (h * 0.10)), radius: w * 0.30, startAngle: .pi, endAngle: 0, clockwise: true)
      path.close()
    case 28:
      path.move(to: CGPoint(x: r.minX + (w * 0.12), y: cy + (h * 0.14)))
      path.addCurve(to: CGPoint(x: r.maxX - (w * 0.12), y: cy + (h * 0.14)),
                    controlPoint1: CGPoint(x: r.minX + (w * 0.24), y: r.maxY),
                    controlPoint2: CGPoint(x: r.maxX - (w * 0.24), y: r.maxY))
      path.addCurve(to: CGPoint(x: r.minX + (w * 0.12), y: cy + (h * 0.14)),
                    controlPoint1: CGPoint(x: r.maxX - (w * 0.26), y: cy - (h * 0.04)),
                    controlPoint2: CGPoint(x: r.minX + (w * 0.26), y: cy - (h * 0.04)))
      path.close()
      path.append(UIBezierPath(ovalIn: CGRect(x: cx - (w * 0.06), y: r.minY + (h * 0.02), width: w * 0.12, height: h * 0.20)))
    case 29:
      path.move(to: CGPoint(x: cx - (w * 0.20), y: r.minY + (h * 0.20)))
      path.addCurve(to: CGPoint(x: cx, y: r.maxY - (h * 0.08)),
                    controlPoint1: CGPoint(x: cx - (w * 0.24), y: cy),
                    controlPoint2: CGPoint(x: cx - (w * 0.28), y: r.maxY - (h * 0.16)))
      path.addCurve(to: CGPoint(x: cx + (w * 0.20), y: r.minY + (h * 0.20)),
                    controlPoint1: CGPoint(x: cx + (w * 0.28), y: r.maxY - (h * 0.16)),
                    controlPoint2: CGPoint(x: cx + (w * 0.24), y: cy))
      path.close()
    case 30:
      path.move(to: CGPoint(x: cx - (w * 0.18), y: r.minY + (h * 0.08)))
      path.addLine(to: CGPoint(x: cx + (w * 0.18), y: r.minY + (h * 0.08)))
      path.addLine(to: CGPoint(x: cx + (w * 0.08), y: cy + (h * 0.10)))
      path.addLine(to: CGPoint(x: cx + (w * 0.02), y: cy + (h * 0.18)))
      path.addLine(to: CGPoint(x: cx + (w * 0.02), y: r.maxY - (h * 0.08)))
      path.addLine(to: CGPoint(x: cx - (w * 0.02), y: r.maxY - (h * 0.08)))
      path.addLine(to: CGPoint(x: cx - (w * 0.02), y: cy + (h * 0.18)))
      path.addLine(to: CGPoint(x: cx - (w * 0.08), y: cy + (h * 0.10)))
      path.close()
    case 31:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.10), y: r.minY + (h * 0.02), width: w * 0.62, height: h * 0.86)))
      path.append(UIBezierPath(roundedRect: CGRect(x: r.maxX - (w * 0.34), y: cy - (h * 0.07), width: w * 0.34, height: h * 0.14), cornerRadius: h * 0.05))
    case 32:
      path.move(to: CGPoint(x: r.minX + (w * 0.10), y: r.maxY))
      path.addLine(to: CGPoint(x: cx - (w * 0.06), y: r.minY + (h * 0.10)))
      path.addLine(to: CGPoint(x: cx + (w * 0.08), y: r.maxY))
      path.close()
      path.move(to: CGPoint(x: cx - (w * 0.02), y: r.maxY))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.20), y: r.minY + (h * 0.16)))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.04), y: r.maxY))
      path.close()
    case 33:
      path.move(to: CGPoint(x: r.minX + (w * 0.06), y: cy + (h * 0.16)))
      path.addCurve(to: CGPoint(x: r.maxX - (w * 0.04), y: cy + (h * 0.14)),
                    controlPoint1: CGPoint(x: r.minX + (w * 0.24), y: cy - (h * 0.02)),
                    controlPoint2: CGPoint(x: r.maxX - (w * 0.18), y: cy - (h * 0.04)))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.14), y: r.maxY - (h * 0.02)))
      path.close()
    case 34:
      path.move(to: CGPoint(x: cx, y: r.minY + (h * 0.04)))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.08), y: r.maxY - (h * 0.10)))
      path.addLine(to: CGPoint(x: r.minX + (w * 0.08), y: r.maxY - (h * 0.10)))
      path.close()
    case 35:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.08), y: r.maxY - (h * 0.18), width: w * 0.84, height: h * 0.18), cornerRadius: h * 0.05))
      path.addArc(withCenter: CGPoint(x: cx, y: r.maxY - (h * 0.08)), radius: w * 0.28, startAngle: .pi, endAngle: 0, clockwise: true)
      path.close()
    case 36:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.08), width: w * 0.84, height: h * 0.84)))
      path.append(UIBezierPath(ovalIn: CGRect(x: cx - (w * 0.14), y: cy - (h * 0.14), width: w * 0.28, height: h * 0.28)))
    case 37:
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.10), y: cy + (h * 0.08), width: w * 0.80, height: h * 0.34), cornerRadius: h * 0.08))
      path.move(to: CGPoint(x: cx, y: r.minY + (h * 0.10)))
      path.addCurve(to: CGPoint(x: cx, y: cy + (h * 0.08)),
                    controlPoint1: CGPoint(x: cx + (w * 0.16), y: cy),
                    controlPoint2: CGPoint(x: cx + (w * 0.04), y: cy + (h * 0.08)))
      path.addCurve(to: CGPoint(x: cx, y: r.minY + (h * 0.10)),
                    controlPoint1: CGPoint(x: cx - (w * 0.04), y: cy + (h * 0.08)),
                    controlPoint2: CGPoint(x: cx - (w * 0.16), y: cy))
      path.close()
    case 38:
      path.move(to: CGPoint(x: r.minX + (w * 0.08), y: r.maxY - (h * 0.06)))
      path.addLine(to: CGPoint(x: cx, y: r.minY + (h * 0.02)))
      path.addLine(to: CGPoint(x: r.maxX - (w * 0.08), y: r.maxY - (h * 0.06)))
      path.close()
      path.append(UIBezierPath(roundedRect: CGRect(x: r.minX + (w * 0.18), y: r.maxY - (h * 0.14), width: w * 0.64, height: h * 0.14), cornerRadius: h * 0.04))
    case 39:
      path.append(UIBezierPath(ovalIn: CGRect(x: r.minX + (w * 0.08), y: r.minY + (h * 0.08), width: w * 0.84, height: h * 0.84)))
      path.addArc(withCenter: CGPoint(x: cx - (w * 0.04), y: cy), radius: w * 0.22, startAngle: 1.50, endAngle: 4.78, clockwise: true)
      path.addArc(withCenter: CGPoint(x: cx + (w * 0.04), y: cy), radius: w * 0.22, startAngle: -1.64, endAngle: 1.64, clockwise: true)
    default:
      path.append(UIBezierPath(ovalIn: r))
    }
    return path
  }

  private func drawZodiacRepCoin(
    in context: CGContext,
    rect: CGRect,
    repCount: Int,
    scale: CGFloat,
    pulse: CGFloat,
    theme: ZodiacTheme
  ) {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = rect.width / 2.0

    if let glowGradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: [
        theme.glowColor.withAlphaComponent(0.30 + (0.18 * pulse)).cgColor,
        theme.glowColor.withAlphaComponent(0.07).cgColor,
        UIColor.clear.cgColor,
      ] as CFArray,
      locations: [0, 0.58, 1]
    ) {
      context.drawRadialGradient(
        glowGradient,
        startCenter: center,
        startRadius: 0,
        endCenter: center,
        endRadius: radius + (10.0 * scale),
        options: []
      )
    }

    fillCircleWithRadialGradient(
      in: context,
      center: center,
      radius: radius,
      colors: theme.fillColors,
      locations: [0, 0.54, 1]
    )

    context.setStrokeColor(theme.glowColor.withAlphaComponent(0.82).cgColor)
    context.setLineWidth(max(1.2, 1.2 * scale))
    context.strokeEllipse(in: rect)

    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.24).cgColor)
    context.setLineWidth(0.9 * scale)
    context.strokeEllipse(in: rect.insetBy(dx: 5.0 * scale, dy: 5.0 * scale))

    context.setStrokeColor(UIColor.black.withAlphaComponent(0.10).cgColor)
    context.setLineWidth(4.0 * scale)
    context.strokeEllipse(
      in: rect
        .insetBy(dx: 1.5 * scale, dy: 1.5 * scale)
        .offsetBy(dx: 0, dy: radius * 0.14)
    )

    context.setStrokeColor(theme.constellationColor.withAlphaComponent(0.34).cgColor)
    context.setLineWidth(0.9 * scale)
    context.move(to: CGPoint(x: center.x - (radius * 0.50), y: center.y + (1.5 * scale)))
    context.addLine(to: CGPoint(x: center.x + (radius * 0.50), y: center.y + (1.5 * scale)))
    context.strokePath()

    drawCenteredText(
      theme.symbol,
      in: CGRect(
        x: rect.minX,
        y: rect.minY + (radius * 0.02),
        width: rect.width,
        height: radius
      ),
      font: UIFont.systemFont(ofSize: max(22.0, rect.width * 0.28), weight: .bold),
      color: theme.engravingColor.withAlphaComponent(0.94)
    )
    drawCenteredText(
      "\(repCount)",
      in: CGRect(
        x: rect.minX,
        y: center.y + (radius * 0.02),
        width: rect.width,
        height: radius * 0.70
      ),
      font: UIFont.systemFont(ofSize: max(18.0, rect.width * 0.22), weight: .bold),
      color: theme.engravingColor.withAlphaComponent(0.96)
    )

    drawCircularText(
      "\(theme.signLabel) * \(theme.signLabel)",
      center: center,
      radius: radius - (7.0 * scale),
      startAngleDegrees: -160.0,
      sweepDegrees: 140.0,
      in: context,
      font: UIFont.systemFont(ofSize: max(5.8, rect.width * 0.055), weight: .regular),
      color: theme.rimTextColor
    )
    drawCircularText(
      "ICONIC GRATITUDE * EXPORT",
      center: center,
      radius: radius - (7.0 * scale),
      startAngleDegrees: 20.0,
      sweepDegrees: 140.0,
      in: context,
      font: UIFont.systemFont(ofSize: max(5.8, rect.width * 0.055), weight: .regular),
      color: theme.rimTextColor
    )
  }

  private func drawRepCounter(
    in context: CGContext,
    rect: CGRect,
    repCount: Int,
    scale: CGFloat,
    phase: String,
    theme: WorldFestivalTheme? = nil
  ) {
    if let theme = theme,
       isProfessionSignatureVariant(theme.storageKey) {
      drawProfessionSignatureRepCounter(
        in: context,
        rect: rect,
        repCount: repCount,
        scale: scale,
        phase: phase,
        theme: theme
      )
      return
    }

    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius = rect.width / 2.0
    let phaseColor: UIColor
    switch phase {
    case "down":
      phaseColor = theme?.phaseDownColor ?? UIColor(red: 1.0, green: 152.0 / 255.0, blue: 0, alpha: 1)
    case "hold":
      phaseColor = theme?.phaseHoldColor ?? UIColor(red: 33.0 / 255.0, green: 150.0 / 255.0, blue: 243.0 / 255.0, alpha: 1)
    default:
      phaseColor = theme?.phaseUpColor ?? UIColor(red: 76.0 / 255.0, green: 175.0 / 255.0, blue: 80.0 / 255.0, alpha: 1)
    }

    context.saveGState()
    context.setShadow(
      offset: .zero,
      blur: 12.0 * scale,
      color: phaseColor.withAlphaComponent(0.32).cgColor
    )
    context.setFillColor(phaseColor.withAlphaComponent(0.20).cgColor)
    context.fillEllipse(in: rect.insetBy(dx: -3.0 * scale, dy: -3.0 * scale))
    context.restoreGState()

    context.saveGState()
    context.setShadow(
      offset: CGSize(width: 0, height: 8.0 * scale),
      blur: 9.0 * scale,
      color: UIColor.black.withAlphaComponent(0.34).cgColor
    )
    context.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
    context.fillEllipse(in: rect)
    context.restoreGState()

    fillCircleWithRadialGradient(
      in: context,
      center: center,
      radius: radius,
      colors: [
        (theme?.primaryEnd ?? UIColor(red: 28.0 / 255.0, green: 36.0 / 255.0, blue: 49.0 / 255.0, alpha: 1)).withAlphaComponent(0.96),
        (theme?.primaryStart ?? UIColor(red: 9.0 / 255.0, green: 12.0 / 255.0, blue: 17.0 / 255.0, alpha: 1)).withAlphaComponent(0.99),
      ],
      locations: [0, 1]
    )

    context.setStrokeColor(phaseColor.withAlphaComponent(0.95).cgColor)
    context.setLineWidth(max(2.0, scale * 2.0))
    context.strokeEllipse(in: rect.insetBy(dx: context.lineWidth / 2.0, dy: context.lineWidth / 2.0))

    let innerRect = rect.insetBy(dx: 6.0 * scale, dy: 6.0 * scale)
    let innerCenter = CGPoint(x: innerRect.midX, y: innerRect.midY)
    fillCircleWithRadialGradient(
      in: context,
      center: innerCenter,
      radius: innerRect.width / 2.0,
      colors: [
        UIColor.white.withAlphaComponent(0.16),
        UIColor.clear,
      ],
      locations: [0, 1]
    )

    context.setStrokeColor(UIColor.white.withAlphaComponent(0.32).cgColor)
    context.setLineWidth(max(1.0, scale))
    context.strokeEllipse(in: innerRect)

    drawCenteredText(
      "\(repCount)",
      in: rect,
      font: UIFont.systemFont(ofSize: max(38.0 * scale, rect.width * 0.365), weight: .heavy),
      color: UIColor.white
    )
  }

  private func isProfessionSignatureVariant(_ key: String) -> Bool {
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

  private func drawProfessionSignatureAccuracyBar(
    in context: CGContext,
    rect: CGRect,
    accuracy: CGFloat,
    scale: CGFloat,
    presentationTimeUs: Int64,
    theme: WorldFestivalTheme
  ) {
    let safeAccuracy = max(0, min(1, accuracy))
    let fillColor: UIColor
    if safeAccuracy >= 0.8 {
      fillColor = theme.accuracyHighColor
    } else if safeAccuracy >= 0.6 {
      fillColor = theme.accuracyMidColor
    } else {
      fillColor = theme.accuracyLowColor
    }

    let key = theme.storageKey
    let radius: CGFloat
    switch key {
    case "profession_fashion_model":
      radius = rect.height * 0.64
    case "profession_photographer":
      radius = rect.height * 0.16
    case "profession_lawyer":
      radius = rect.height * 0.22
    case "profession_swimmer":
      radius = rect.height * 0.52
    case "profession_philosopher":
      radius = rect.height * 0.18
    case "profession_cgd":
      radius = rect.height * 0.26
    case "profession_writer":
      radius = rect.height * 0.12
    case "profession_game_streamer":
      radius = rect.height * 0.20
    default:
      radius = rect.height * 0.34
    }

    fillRoundedRect(
      in: context,
      rect: rect,
      radius: radius,
      colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)],
      locations: [0, 1]
    )
    context.setStrokeColor(theme.accent2.withAlphaComponent(0.34).cgColor)
    context.setLineWidth(max(1.0, 1.2 * scale))
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.strokePath()

    let inner = rect.insetBy(dx: 2.0 * scale, dy: 2.0 * scale)
    context.setFillColor(UIColor.black.withAlphaComponent(0.22).cgColor)
    context.addPath(UIBezierPath(roundedRect: inner, cornerRadius: max(3.0 * scale, radius * 0.78)).cgPath)
    context.fillPath()

    let fillRect = CGRect(x: inner.minX, y: inner.minY, width: inner.width * safeAccuracy, height: inner.height)
    if fillRect.width > 1 {
      fillRoundedRect(
        in: context,
        rect: fillRect,
        radius: max(2.0 * scale, radius * 0.70),
        colors: [
          blend(fillColor, .white, 0.24),
          fillColor,
          blend(fillColor, .black, 0.18),
        ],
        locations: [0, 0.52, 1]
      )
      let shimmer = CGFloat((presentationTimeUs / 1000) % 2100) / 2100.0
      let x = fillRect.minX + (fillRect.width * shimmer)
      fillRectWithGradient(
        in: context,
        rect: CGRect(x: x - (12.0 * scale), y: fillRect.minY, width: 24.0 * scale, height: fillRect.height),
        colors: [UIColor.clear, UIColor.white.withAlphaComponent(0.48), UIColor.clear],
        locations: [0, 0.5, 1],
        start: CGPoint(x: x - (12.0 * scale), y: fillRect.minY),
        end: CGPoint(x: x + (12.0 * scale), y: fillRect.maxY)
      )
    }

    if key == "profession_lawyer" {
      for idx in 0..<7 {
        let x = inner.minX + (CGFloat(idx + 1) * inner.width / 8.0)
        context.setStrokeColor(theme.accent1.withAlphaComponent(0.16).cgColor)
        context.setLineWidth(idx == 3 ? 1.8 * scale : 0.9 * scale)
        context.move(to: CGPoint(x: x, y: inner.minY + (1.4 * scale)))
        context.addLine(to: CGPoint(x: x, y: inner.maxY - (1.4 * scale)))
        context.strokePath()
      }
      drawText("VERIFIED", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.36, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent2.withAlphaComponent(0.90), alignment: .left)
      drawText("BALANCED", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.92), alignment: .right)
    } else if key == "profession_business_coach" {
      for lane in 0..<3 {
        let y = inner.minY + (inner.height * (0.28 + (CGFloat(lane) * 0.22)))
        context.setStrokeColor(theme.accent1.withAlphaComponent(0.18).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
    } else if key == "profession_fashion_model" {
      context.setStrokeColor(UIColor.white.withAlphaComponent(0.38).cgColor)
      context.setLineWidth(0.9 * scale)
      context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: inner.minY + (2.0 * scale)))
      context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: inner.minY + (2.0 * scale)))
      context.strokePath()
      drawText("COUTURE", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height), font: UIFont(name: "TimesNewRomanPS-BoldMT", size: max(8.0, 8.0 * scale)) ?? UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.88), alignment: .right)
    } else if key == "profession_actor" {
      for i in 0..<10 {
        let x = inner.minX + (inner.width * CGFloat(i) / 9.0)
        context.setFillColor(UIColor.white.withAlphaComponent(0.30).cgColor)
        context.fillEllipse(in: CGRect(x: x - (0.9 * scale), y: inner.minY + (0.9 * scale), width: 1.8 * scale, height: 1.8 * scale))
        context.fillEllipse(in: CGRect(x: x - (0.9 * scale), y: inner.maxY - (2.7 * scale), width: 1.8 * scale, height: 1.8 * scale))
      }
      drawText("TAKE", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.28, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.90), alignment: .left)
    } else if key == "profession_photographer" {
      let c = 8.0 * scale
      context.setStrokeColor(theme.accent2.withAlphaComponent(0.46).cgColor)
      context.setLineWidth(1.0 * scale)
      context.move(to: CGPoint(x: inner.minX, y: inner.minY + c)); context.addLine(to: CGPoint(x: inner.minX, y: inner.minY)); context.addLine(to: CGPoint(x: inner.minX + c, y: inner.minY)); context.strokePath()
      context.move(to: CGPoint(x: inner.maxX - c, y: inner.minY)); context.addLine(to: CGPoint(x: inner.maxX, y: inner.minY)); context.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + c)); context.strokePath()
      drawText("SHARP", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.46, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.90), alignment: .right)
    } else if key == "profession_presenter" {
      for lane in 0..<4 {
        let y = inner.minY + (inner.height * (0.20 + (CGFloat(lane) * 0.20)))
        context.setStrokeColor(theme.accent2.withAlphaComponent(0.14 + (CGFloat(lane) * 0.03)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
      let pulse = CGFloat(0.62 + (0.38 * abs(sin((Double(presentationTimeUs) / 1_000_000.0) * 3.0))))
      context.setFillColor(theme.accuracyHighColor.withAlphaComponent(pulse).cgColor)
      context.fillEllipse(in: CGRect(x: inner.minX + (7.8 * scale), y: inner.midY - (2.2 * scale), width: 4.4 * scale, height: 4.4 * scale))
      drawText("LIVE", in: CGRect(x: inner.minX + (16.0 * scale), y: inner.minY, width: inner.width * 0.28, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.92), alignment: .left)
    } else if key == "profession_business_owner" {
      for lane in 0..<4 {
        let y = inner.minY + (inner.height * (0.22 + (CGFloat(lane) * 0.20)))
        context.setStrokeColor(theme.accent1.withAlphaComponent(0.16 + (CGFloat(lane) * 0.04)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
      drawText("ON TRACK", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent2.withAlphaComponent(0.90), alignment: .right)
    } else if key == "profession_gym_trainer" {
      let pulse = CGFloat(0.5 + (0.5 * abs(sin((Double(presentationTimeUs) / 1_000_000.0) * 4.6))))
      for idx in 0..<5 {
        let x = inner.minX + (inner.width * (0.18 + (CGFloat(idx) * 0.16)))
        let h = inner.height * (0.28 + CGFloat(idx % 2) * 0.26)
        let barRect = CGRect(x: x - (2.0 * scale), y: inner.maxY - h, width: 4.0 * scale, height: h - (2.0 * scale))
        context.setFillColor(theme.accuracyHighColor.withAlphaComponent(0.45 + (0.45 * pulse)).cgColor)
        context.addPath(UIBezierPath(roundedRect: barRect, cornerRadius: 2.0 * scale).cgPath)
        context.fillPath()
      }
      drawText("FORM", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.30, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.92), alignment: .left)
    } else if key == "profession_swimmer" {
      for row in 0..<3 {
        let y = inner.minY + (inner.height * (0.30 + (CGFloat(row) * 0.20)))
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.22 + (CGFloat(row) * 0.10)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (4.0 * scale), y: y))
        context.addCurve(
          to: CGPoint(x: inner.maxX - (4.0 * scale), y: y),
          control1: CGPoint(x: inner.minX + (inner.width * 0.28), y: y - (2.4 * scale)),
          control2: CGPoint(x: inner.minX + (inner.width * 0.64), y: y + (2.4 * scale))
        )
        context.strokePath()
      }
      drawText("FLOW", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.26, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.92), alignment: .left)
    } else if key == "profession_psychologist" {
      let calmPulse = CGFloat(0.45 + (0.55 * abs(sin((Double(presentationTimeUs) / 1_000_000.0) * 1.8))))
      context.setFillColor(theme.accuracyHighColor.withAlphaComponent(calmPulse).cgColor)
      context.fillEllipse(in: CGRect(x: inner.minX + (7.8 * scale), y: inner.midY - (2.2 * scale), width: 4.4 * scale, height: 4.4 * scale))
      context.setStrokeColor(theme.accent2.withAlphaComponent(0.24).cgColor)
      context.setLineWidth(1.0 * scale)
      context.move(to: CGPoint(x: inner.minX + (16.0 * scale), y: inner.midY))
      context.addLine(to: CGPoint(x: inner.maxX - (8.0 * scale), y: inner.midY))
      context.strokePath()
      drawText("MINDFUL", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.90), alignment: .right)
    } else if key == "profession_philosopher" {
      for i in 0..<4 {
        let x = inner.minX + (inner.width * (0.18 + (CGFloat(i) * 0.20)))
        context.setStrokeColor(theme.accent1.withAlphaComponent(0.14 + (CGFloat(i) * 0.04)).cgColor)
        context.setLineWidth(0.9 * scale)
        context.move(to: CGPoint(x: x, y: inner.minY + (3.0 * scale)))
        context.addLine(to: CGPoint(x: x, y: inner.maxY - (3.0 * scale)))
        context.strokePath()
      }
      drawText("TRUTH", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.24, height: inner.height), font: UIFont(name: "TimesNewRomanPS-BoldMT", size: max(8.0, 8.0 * scale)) ?? UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent2.withAlphaComponent(0.90), alignment: .left)
    } else if key == "profession_manager" {
      for lane in 0..<4 {
        let y = inner.minY + (inner.height * (0.24 + (CGFloat(lane) * 0.19)))
        context.setStrokeColor(theme.accent2.withAlphaComponent(0.16 + (CGFloat(lane) * 0.03)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
      drawText("ON TRACK", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.88), alignment: .right)
    } else if key == "profession_director" {
      for i in 0..<8 {
        let x = inner.minX + (inner.width * CGFloat(i) / 7.0)
        context.setFillColor(UIColor.white.withAlphaComponent(0.30).cgColor)
        context.fillEllipse(in: CGRect(x: x - (0.85 * scale), y: inner.minY + (0.95 * scale), width: 1.7 * scale, height: 1.7 * scale))
        context.fillEllipse(in: CGRect(x: x - (0.85 * scale), y: inner.maxY - (2.65 * scale), width: 1.7 * scale, height: 1.7 * scale))
      }
      let beam = CGFloat((presentationTimeUs / 1000) % 2200) / 2200.0
      let bx = inner.minX + (inner.width * beam)
      fillRectWithGradient(
        in: context,
        rect: CGRect(x: bx - (8.0 * scale), y: inner.minY, width: 16.0 * scale, height: inner.height),
        colors: [UIColor.clear, theme.accent1.withAlphaComponent(0.34), UIColor.clear],
        locations: [0, 0.5, 1],
        start: CGPoint(x: bx - (8.0 * scale), y: inner.minY),
        end: CGPoint(x: bx + (8.0 * scale), y: inner.maxY)
      )
      drawText("SYNCED", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.24, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.90), alignment: .left)
    } else if key == "profession_cgd" {
      for g in 0...4 {
        let x = inner.minX + (inner.width * CGFloat(g) / 4.0)
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.13).cgColor)
        context.setLineWidth(0.9 * scale)
        context.move(to: CGPoint(x: x, y: inner.minY)); context.addLine(to: CGPoint(x: x, y: inner.maxY)); context.strokePath()
      }
      for g in 1...3 {
        let y = inner.minY + (inner.height * CGFloat(g) / 4.0)
        context.setStrokeColor(theme.accuracyMidColor.withAlphaComponent(0.12).cgColor)
        context.setLineWidth(0.9 * scale)
        context.move(to: CGPoint(x: inner.minX, y: y)); context.addLine(to: CGPoint(x: inner.maxX, y: y)); context.strokePath()
      }
      drawText("RENDER", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.46, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.90), alignment: .right)
    } else if key == "profession_it_engineer" {
      for lane in 0..<4 {
        let y = inner.minY + (inner.height * (0.22 + (CGFloat(lane) * 0.21)))
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.22 + (CGFloat(lane) * 0.06)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.28), y: y))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.28), y: y + (2.6 * scale)))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.62), y: y + (2.6 * scale)))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.62), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
      drawText("SECURE", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.24, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.90), alignment: .left)
    } else if key == "profession_musician" {
      for lane in 0..<5 {
        let y = inner.minY + (inner.height * (0.18 + (CGFloat(lane) * 0.16)))
        let h = inner.height * (0.12 + CGFloat(lane % 3) * 0.14)
        let x = inner.minX + (inner.width * (0.12 + (CGFloat(lane) * 0.16)))
        context.setFillColor(theme.accuracyHighColor.withAlphaComponent(0.44 + (CGFloat(lane) * 0.08)).cgColor)
        context.addPath(UIBezierPath(roundedRect: CGRect(x: x, y: y, width: 4.0 * scale, height: h), cornerRadius: 2.0 * scale).cgPath)
        context.fillPath()
      }
      drawText("TEMPO", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.24, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyMidColor.withAlphaComponent(0.92), alignment: .left)
    } else if key == "profession_writer" {
      for line in 0..<4 {
        let y = inner.minY + (inner.height * (0.22 + (CGFloat(line) * 0.20)))
        context.setStrokeColor(theme.accent2.withAlphaComponent(0.16 + (CGFloat(line) * 0.04)).cgColor)
        context.setLineWidth(0.95 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
      drawText("DRAFT", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.22, height: inner.height), font: UIFont(name: "TimesNewRomanPS-BoldMT", size: max(8.0, 8.0 * scale)) ?? UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accent1.withAlphaComponent(0.90), alignment: .left)
    } else if key == "profession_game_streamer" {
      for lane in 0..<4 {
        let y = inner.minY + (inner.height * (0.20 + (CGFloat(lane) * 0.20)))
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.20 + (CGFloat(lane) * 0.08)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: inner.minX + (6.0 * scale), y: y))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.24), y: y))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.24), y: y + (2.4 * scale)))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.54), y: y + (2.4 * scale)))
        context.addLine(to: CGPoint(x: inner.minX + (inner.width * 0.54), y: y))
        context.addLine(to: CGPoint(x: inner.maxX - (6.0 * scale), y: y))
        context.strokePath()
      }
      drawText("LIVE", in: CGRect(x: inner.minX + (8.0 * scale), y: inner.minY, width: inner.width * 0.20, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.95), alignment: .left)
    } else if key == "profession_social_media_influencer" {
      let pulse = CGFloat(0.58 + (0.42 * abs(sin((Double(presentationTimeUs) / 1_000_000.0) * 2.8))))
      for node in 0..<5 {
        let x = inner.minX + (inner.width * (0.14 + (CGFloat(node) * 0.18)))
        let y = inner.maxY - (inner.height * (0.18 + (CGFloat(node) * 0.12)))
        context.setFillColor(theme.accuracyMidColor.withAlphaComponent((0.36 + (CGFloat(node) * 0.1)) * pulse).cgColor)
        context.fillEllipse(in: CGRect(x: x - (1.9 * scale), y: y - (1.9 * scale), width: 3.8 * scale, height: 3.8 * scale))
      }
      drawText("TRENDING", in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height), font: UIFont.systemFont(ofSize: max(8.0, 8.0 * scale), weight: .bold), color: theme.accuracyHighColor.withAlphaComponent(0.90), alignment: .right)
    }

    drawText(
      "\(Int((safeAccuracy * 100.0).rounded()))%",
      in: CGRect(x: inner.midX, y: inner.minY, width: inner.width * 0.48, height: inner.height),
      font: UIFont.systemFont(ofSize: max(10.0, 10.0 * scale), weight: .bold),
      color: UIColor.white.withAlphaComponent(0.96),
      alignment: .right
    )
  }

  private func drawProfessionSignatureRepCounter(
    in context: CGContext,
    rect: CGRect,
    repCount: Int,
    scale: CGFloat,
    phase: String,
    theme: WorldFestivalTheme
  ) {
    let key = theme.storageKey
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let phaseColor: UIColor
    switch phase {
    case "down": phaseColor = theme.phaseDownColor
    case "hold": phaseColor = theme.phaseHoldColor
    default: phaseColor = theme.phaseUpColor
    }

    if key == "profession_lawyer" {
      let seal = rect.insetBy(dx: 8.0 * scale, dy: 8.0 * scale)
      fillRoundedRect(in: context, rect: seal, radius: 14.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.82).cgColor)
      context.setLineWidth(2.0 * scale)
      context.addPath(UIBezierPath(roundedRect: seal, cornerRadius: 14.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_business_coach" {
      let p = UIBezierPath()
      p.move(to: CGPoint(x: center.x, y: rect.minY + (6.0 * scale)))
      p.addLine(to: CGPoint(x: rect.maxX - (8.0 * scale), y: rect.minY + (24.0 * scale)))
      p.addLine(to: CGPoint(x: rect.maxX - (8.0 * scale), y: rect.maxY - (24.0 * scale)))
      p.addLine(to: CGPoint(x: center.x, y: rect.maxY - (6.0 * scale)))
      p.addLine(to: CGPoint(x: rect.minX + (8.0 * scale), y: rect.maxY - (24.0 * scale)))
      p.addLine(to: CGPoint(x: rect.minX + (8.0 * scale), y: rect.minY + (24.0 * scale)))
      p.close()
      context.saveGState()
      context.addPath(p.cgPath)
      context.clip()
      fillRectWithGradient(in: context, rect: rect, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1], start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY))
      context.restoreGState()
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.84).cgColor)
      context.setLineWidth(2.0 * scale)
      context.addPath(p.cgPath)
      context.strokePath()
    } else if key == "profession_fashion_model" {
      let oval = rect.insetBy(dx: 6.0 * scale, dy: 8.0 * scale)
      fillCircleWithRadialGradient(in: context, center: CGPoint(x: oval.midX, y: oval.midY), radius: oval.width / 2.0, colors: [theme.primaryEnd.withAlphaComponent(0.98), theme.primaryStart.withAlphaComponent(0.98)], locations: [0, 1])
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.88).cgColor)
      context.setLineWidth(1.8 * scale)
      context.strokeEllipse(in: oval)
    } else if key == "profession_actor" {
      let plaque = rect.insetBy(dx: 7.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: plaque, radius: 10.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.98)], locations: [0, 1])
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.82).cgColor)
      context.setLineWidth(1.8 * scale)
      context.addPath(UIBezierPath(roundedRect: plaque, cornerRadius: 10.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_photographer" {
      let ring = rect.insetBy(dx: 8.0 * scale, dy: 8.0 * scale)
      fillCircleWithRadialGradient(in: context, center: center, radius: ring.width / 2.0, colors: [theme.primaryEnd.withAlphaComponent(0.98), theme.primaryStart.withAlphaComponent(0.98)], locations: [0, 1])
      context.setStrokeColor(theme.accent2.withAlphaComponent(0.72).cgColor)
      context.setLineWidth(1.8 * scale)
      context.strokeEllipse(in: ring)
    } else if key == "profession_presenter" {
      let badge = rect.insetBy(dx: 9.0 * scale, dy: 12.0 * scale)
      fillRoundedRect(in: context, rect: badge, radius: 12.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accent2.withAlphaComponent(0.84).cgColor)
      context.setLineWidth(1.8 * scale)
      context.addPath(UIBezierPath(roundedRect: badge, cornerRadius: 12.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_business_owner" {
      let panel = rect.insetBy(dx: 7.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: panel, radius: 10.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.84).cgColor)
      context.setLineWidth(1.9 * scale)
      context.addPath(UIBezierPath(roundedRect: panel, cornerRadius: 10.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_gym_trainer" {
      fillCircleWithRadialGradient(in: context, center: center, radius: radius - (8.0 * scale), colors: [theme.primaryEnd.withAlphaComponent(0.98), theme.primaryStart.withAlphaComponent(0.98)], locations: [0, 1])
      for i in 0..<12 {
        let angle = ((Double(i) * 30.0) - 90.0) * .pi / 180.0
        let x1 = center.x + CGFloat(cos(angle)) * (radius - (8.0 * scale))
        let y1 = center.y + CGFloat(sin(angle)) * (radius - (8.0 * scale))
        let x2 = center.x + CGFloat(cos(angle)) * (radius - (14.0 * scale))
        let y2 = center.y + CGFloat(sin(angle)) * (radius - (14.0 * scale))
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.70).cgColor)
        context.setLineWidth(1.1 * scale)
        context.move(to: CGPoint(x: x1, y: y1)); context.addLine(to: CGPoint(x: x2, y: y2)); context.strokePath()
      }
    } else if key == "profession_swimmer" {
      let capsule = rect.insetBy(dx: 8.0 * scale, dy: 12.0 * scale)
      fillRoundedRect(in: context, rect: capsule, radius: capsule.height / 2.0, colors: [theme.primaryStart.withAlphaComponent(0.96), theme.primaryEnd.withAlphaComponent(0.98)], locations: [0, 1])
      for row in 0..<3 {
        let y = capsule.minY + (capsule.height * (0.28 + (CGFloat(row) * 0.22)))
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.30 + (CGFloat(row) * 0.08)).cgColor)
        context.setLineWidth(1.0 * scale)
        context.move(to: CGPoint(x: capsule.minX + (8.0 * scale), y: y))
        context.addCurve(
          to: CGPoint(x: capsule.maxX - (8.0 * scale), y: y),
          control1: CGPoint(x: capsule.minX + (capsule.width * 0.3), y: y - (2.0 * scale)),
          control2: CGPoint(x: capsule.minX + (capsule.width * 0.7), y: y + (2.0 * scale))
        )
        context.strokePath()
      }
    } else if key == "profession_psychologist" {
      let shell = rect.insetBy(dx: 9.0 * scale, dy: 9.0 * scale)
      fillRoundedRect(in: context, rect: shell, radius: 14.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.96), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accent2.withAlphaComponent(0.72).cgColor)
      context.setLineWidth(1.6 * scale)
      context.addPath(UIBezierPath(roundedRect: shell, cornerRadius: 14.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_philosopher" {
      let p = UIBezierPath()
      p.move(to: CGPoint(x: center.x, y: rect.minY + (8.0 * scale)))
      p.addLine(to: CGPoint(x: rect.maxX - (14.0 * scale), y: rect.minY + (14.0 * scale)))
      p.addLine(to: CGPoint(x: rect.maxX - (8.0 * scale), y: center.y))
      p.addLine(to: CGPoint(x: rect.maxX - (14.0 * scale), y: rect.maxY - (14.0 * scale)))
      p.addLine(to: CGPoint(x: center.x, y: rect.maxY - (8.0 * scale)))
      p.addLine(to: CGPoint(x: rect.minX + (14.0 * scale), y: rect.maxY - (14.0 * scale)))
      p.addLine(to: CGPoint(x: rect.minX + (8.0 * scale), y: center.y))
      p.addLine(to: CGPoint(x: rect.minX + (14.0 * scale), y: rect.minY + (14.0 * scale)))
      p.close()
      context.saveGState()
      context.addPath(p.cgPath)
      context.clip()
      fillRectWithGradient(in: context, rect: rect, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.97)], locations: [0, 1], start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY))
      context.restoreGState()
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.82).cgColor)
      context.setLineWidth(1.7 * scale)
      context.addPath(p.cgPath)
      context.strokePath()
    } else if key == "profession_manager" {
      let panel = rect.insetBy(dx: 7.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: panel, radius: 10.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accuracyMidColor.withAlphaComponent(0.84).cgColor)
      context.setLineWidth(1.8 * scale)
      context.addPath(UIBezierPath(roundedRect: panel, cornerRadius: 10.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_director" {
      let plaque = rect.insetBy(dx: 7.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: plaque, radius: 10.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.98)], locations: [0, 1])
      context.setStrokeColor(theme.accent1.withAlphaComponent(0.86).cgColor)
      context.setLineWidth(1.9 * scale)
      context.addPath(UIBezierPath(roundedRect: plaque, cornerRadius: 10.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_cgd" {
      let artboard = rect.insetBy(dx: 8.0 * scale, dy: 8.0 * scale)
      fillRoundedRect(in: context, rect: artboard, radius: 8.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.97)], locations: [0, 1])
      context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.86).cgColor)
      context.setLineWidth(1.7 * scale)
      context.addPath(UIBezierPath(roundedRect: artboard, cornerRadius: 8.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_it_engineer" {
      let term = rect.insetBy(dx: 8.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: term, radius: 6.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.82).cgColor)
      context.setLineWidth(1.7 * scale)
      context.addPath(UIBezierPath(roundedRect: term, cornerRadius: 6.0 * scale).cgPath)
      context.strokePath()
    } else if key == "profession_musician" {
      fillCircleWithRadialGradient(in: context, center: center, radius: radius - (8.0 * scale), colors: [theme.primaryEnd.withAlphaComponent(0.98), theme.primaryStart.withAlphaComponent(0.98)], locations: [0, 1])
      for i in 0..<10 {
        let x = rect.minX + (rect.width * (0.1 + (CGFloat(i) * 0.08)))
        let h = rect.height * (0.06 + CGFloat(i % 4) * 0.06)
        context.setFillColor(theme.accuracyHighColor.withAlphaComponent(0.54).cgColor)
        context.addPath(UIBezierPath(roundedRect: CGRect(x: x, y: center.y - h, width: 2.0 * scale, height: h * 2.0), cornerRadius: 1.0 * scale).cgPath)
        context.fillPath()
      }
    } else if key == "profession_writer" {
      let plaque = rect.insetBy(dx: 7.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: plaque, radius: 8.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accuracyMidColor.withAlphaComponent(0.82).cgColor)
      context.setLineWidth(1.5 * scale)
      context.addPath(UIBezierPath(roundedRect: plaque, cornerRadius: 8.0 * scale).cgPath)
      context.strokePath()
      for r in 0..<3 {
        let y = plaque.minY + (plaque.height * (0.28 + (CGFloat(r) * 0.20)))
        context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.20 + (CGFloat(r) * 0.08)).cgColor)
        context.setLineWidth(0.9 * scale)
        context.move(to: CGPoint(x: plaque.minX + (8.0 * scale), y: y))
        context.addLine(to: CGPoint(x: plaque.maxX - (8.0 * scale), y: y))
        context.strokePath()
      }
    } else if key == "profession_game_streamer" {
      let p = UIBezierPath()
      p.move(to: CGPoint(x: center.x, y: rect.minY + (8.0 * scale)))
      p.addLine(to: CGPoint(x: rect.maxX - (10.0 * scale), y: rect.minY + (20.0 * scale)))
      p.addLine(to: CGPoint(x: rect.maxX - (10.0 * scale), y: rect.maxY - (20.0 * scale)))
      p.addLine(to: CGPoint(x: center.x, y: rect.maxY - (8.0 * scale)))
      p.addLine(to: CGPoint(x: rect.minX + (10.0 * scale), y: rect.maxY - (20.0 * scale)))
      p.addLine(to: CGPoint(x: rect.minX + (10.0 * scale), y: rect.minY + (20.0 * scale)))
      p.close()
      context.saveGState()
      context.addPath(p.cgPath)
      context.clip()
      fillRectWithGradient(in: context, rect: rect, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1], start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY))
      context.restoreGState()
      context.setStrokeColor(theme.accuracyHighColor.withAlphaComponent(0.88).cgColor)
      context.setLineWidth(1.8 * scale)
      context.addPath(p.cgPath)
      context.strokePath()
    } else if key == "profession_social_media_influencer" {
      let badge = rect.insetBy(dx: 8.0 * scale, dy: 10.0 * scale)
      fillRoundedRect(in: context, rect: badge, radius: 12.0 * scale, colors: [theme.primaryStart.withAlphaComponent(0.98), theme.primaryEnd.withAlphaComponent(0.96)], locations: [0, 1])
      context.setStrokeColor(theme.accuracyMidColor.withAlphaComponent(0.86).cgColor)
      context.setLineWidth(1.7 * scale)
      context.addPath(UIBezierPath(roundedRect: badge, cornerRadius: 12.0 * scale).cgPath)
      context.strokePath()
      context.setFillColor(theme.accuracyHighColor.withAlphaComponent(0.86).cgColor)
      context.fillEllipse(in: CGRect(x: badge.maxX - (12.2 * scale), y: badge.minY + (7.8 * scale), width: 4.4 * scale, height: 4.4 * scale))
    }

    drawCenteredText(
      "\(repCount)",
      in: rect,
      font: UIFont.systemFont(ofSize: max(34.0 * scale, rect.width * 0.34), weight: .bold),
      color: UIColor.white
    )
    context.setStrokeColor(phaseColor.withAlphaComponent(0.26).cgColor)
    context.setLineWidth(max(1.0, 1.2 * scale))
    context.strokeEllipse(in: rect.insetBy(dx: 10.0 * scale, dy: 10.0 * scale))
  }

  private func blend(_ a: UIColor, _ b: UIColor, _ factor: CGFloat) -> UIColor {
    let f = max(0, min(1, factor))
    var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
    var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
    a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
    b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    return UIColor(
      red: ar + ((br - ar) * f),
      green: ag + ((bg - ag) * f),
      blue: ab + ((bb - ab) * f),
      alpha: aa + ((ba - aa) * f)
    )
  }

  private func drawProfessionHobbyOverlay(
    in context: CGContext,
    renderSize: CGSize,
    state: WorkoutOverlayState,
    scale: CGFloat,
    presentationTimeUs: Int64,
    theme: WorldFestivalTheme
  ) {
    let sideInset = 18.0 * scale
    let topInset = 44.0 * scale
    let repTop = 92.0 * scale
    let repCounterSize = 92.0 * scale
    let accuracyBarHeight = 24.0 * scale
    let accuracyBarWidth = renderSize.width - (sideInset * 2.0)
    let verticalOffset = professionHobbyVerticalOffsetScale * scale

    context.saveGState()
    context.translateBy(x: 0, y: verticalOffset)

    drawProfessionHobbyTitleRibbon(
      in: context,
      renderSize: renderSize,
      scale: scale,
      accuracy: state.accuracyValue,
      theme: theme
    )

    context.saveGState()
    context.translateBy(
      x: 0,
      y: professionHobbyMetricClusterExtraOffsetScale * scale
    )

    drawAccuracyBar(
      in: context,
      rect: CGRect(
        x: sideInset,
        y: topInset,
        width: accuracyBarWidth,
        height: accuracyBarHeight
      ),
      accuracy: state.accuracyValue,
      scale: scale,
      presentationTimeUs: presentationTimeUs,
      renderSize: renderSize,
      theme: theme
    )
    drawRepCounter(
      in: context,
      rect: CGRect(
        x: renderSize.width - sideInset - repCounterSize,
        y: repTop,
        width: repCounterSize,
        height: repCounterSize
      ),
      repCount: state.repCount,
      scale: scale,
      phase: state.phase,
      theme: theme
    )

    context.restoreGState()
    context.restoreGState()
  }

  private func drawProfessionHobbyTitleRibbon(
    in context: CGContext,
    renderSize: CGSize,
    scale: CGFloat,
    accuracy: CGFloat,
    theme: WorldFestivalTheme
  ) {
    let sideInset = 18.0 * scale
    let topInset = 28.0 * scale
    let barHeight = 30.0 * scale
    let ribbonRect = CGRect(
      x: sideInset,
      y: topInset,
      width: renderSize.width - (sideInset * 2.0),
      height: barHeight
    )

    fillRoundedRect(
      in: context,
      rect: ribbonRect,
      radius: 13.0 * scale,
      colors: [
        theme.primaryStart.withAlphaComponent(0.88),
        theme.primaryEnd.withAlphaComponent(0.92),
      ],
      locations: [0, 1]
    )
    context.setStrokeColor(theme.accent1.withAlphaComponent(0.42).cgColor)
    context.setLineWidth(max(1.0, 1.1 * scale))
    context.addPath(UIBezierPath(roundedRect: ribbonRect, cornerRadius: 13.0 * scale).cgPath)
    context.strokePath()

    let iconRect = CGRect(
      x: ribbonRect.minX + (8.0 * scale),
      y: ribbonRect.midY - (10.0 * scale),
      width: 20.0 * scale,
      height: 20.0 * scale
    )
    fillRoundedRect(
      in: context,
      rect: iconRect,
      radius: iconRect.height / 2.0,
      colors: [theme.accent1, theme.accent2],
      locations: [0, 1]
    )
    context.setStrokeColor(UIColor.white.withAlphaComponent(0.22).cgColor)
    context.setLineWidth(max(1.0, 0.9 * scale))
    context.addEllipse(in: iconRect)
    context.strokePath()

    drawText(
      theme.bannerIcon.isEmpty ? "*" : theme.bannerIcon,
      in: iconRect.offsetBy(dx: 0, dy: -0.2 * scale),
      font: UIFont.systemFont(ofSize: max(8.0, iconRect.height * 0.43), weight: .bold),
      color: .white,
      alignment: .center,
      shadow: nil
    )

    let precisionState: String
    if accuracy >= 0.82 {
      precisionState = "OPTIMAL"
    } else if accuracy >= 0.68 {
      precisionState = "STABLE"
    } else {
      precisionState = "CALIBRATING"
    }

    let badgeFont = UIFont.systemFont(ofSize: max(7.0, 8.0 * scale), weight: .bold)
    let precisionWidth = NSString(string: precisionState).size(withAttributes: [.font: badgeFont]).width
    let badgeWidth = max(68.0 * scale, precisionWidth + (16.0 * scale))
    let badgeRect = CGRect(
      x: ribbonRect.maxX - (10.0 * scale) - badgeWidth,
      y: ribbonRect.midY - (9.0 * scale),
      width: badgeWidth,
      height: 18.0 * scale
    )
    context.setFillColor(UIColor.white.withAlphaComponent(0.14).cgColor)
    context.addPath(UIBezierPath(roundedRect: badgeRect, cornerRadius: 4.0 * scale).cgPath)
    context.fillPath()
    context.setStrokeColor(theme.accent2.withAlphaComponent(0.54).cgColor)
    context.setLineWidth(max(1.0, 0.8 * scale))
    context.addPath(UIBezierPath(roundedRect: badgeRect, cornerRadius: 4.0 * scale).cgPath)
    context.strokePath()

    let textLeft = iconRect.maxX + (8.0 * scale)
    let textRight = badgeRect.minX - (8.0 * scale)
    let textRect = CGRect(
      x: textLeft,
      y: ribbonRect.minY,
      width: max(0, textRight - textLeft),
      height: ribbonRect.height
    )
    context.saveGState()
    context.clip(to: textRect)
    let rawProfessionName = theme.label.isEmpty ? theme.themeName : theme.label
    let professionName = rawProfessionName
      .replacingOccurrences(
        of: "\\s*\\(pre[- ]show\\)\\s*",
        with: " ",
        options: [.regularExpression, .caseInsensitive]
      )
      .trimmingCharacters(in: .whitespacesAndNewlines)
    drawText(
      professionName,
      in: CGRect(
        x: textRect.minX,
        y: ribbonRect.minY + (8.0 * scale),
        width: textRect.width,
        height: 14.0 * scale
      ),
      font: UIFont.systemFont(ofSize: max(8.0, 10.0 * scale), weight: .bold),
      color: UIColor.white.withAlphaComponent(0.98),
      alignment: .left,
      shadow: nil
    )
    context.restoreGState()

    drawCenteredText(
      precisionState,
      in: badgeRect,
      font: badgeFont,
      color: theme.accent2.withAlphaComponent(0.96)
    )
  }

  private func drawWatermark(
    in context: CGContext,
    rect: CGRect
  ) {
    let radius = rect.height / 2.0
    context.setFillColor(UIColor.black.withAlphaComponent(0.26).cgColor)
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.fillPath()

    context.setStrokeColor(UIColor.white.withAlphaComponent(0.18).cgColor)
    context.setLineWidth(1)
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.strokePath()

    drawCenteredText(
      "H&F",
      in: rect,
      font: UIFont.systemFont(ofSize: max(12.0, rect.width * 0.18), weight: .bold),
      color: UIColor.white.withAlphaComponent(0.46)
    )
  }

  private func drawCenteredText(
    _ text: String,
    in rect: CGRect,
    font: UIFont,
    color: UIColor
  ) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraph,
    ]

    let attributed = NSAttributedString(string: text, attributes: attributes)
    let size = attributed.size()
    let drawRect = CGRect(
      x: rect.minX,
      y: rect.midY - (size.height / 2.0),
      width: rect.width,
      height: size.height
    )
    attributed.draw(in: drawRect)
  }

  private func isPadaukBranchIcon(_ icon: String) -> Bool {
    return icon == "padauk_branch"
  }

  private func drawPadaukBranch(
    in context: CGContext,
    rect: CGRect,
    alpha: CGFloat
  ) {
    let safeAlpha = max(0, min(1, alpha))
    let flowerColor = UIColor(red: 244.0 / 255.0, green: 197.0 / 255.0, blue: 66.0 / 255.0, alpha: 0.92 * safeAlpha)
    let petalHighlight = UIColor(red: 1.0, green: 224.0 / 255.0, blue: 92.0 / 255.0, alpha: 0.98 * safeAlpha)
    let branchColor = UIColor(red: 106.0 / 255.0, green: 74.0 / 255.0, blue: 43.0 / 255.0, alpha: 0.92 * safeAlpha)
    let leafColor = UIColor(red: 107.0 / 255.0, green: 146.0 / 255.0, blue: 86.0 / 255.0, alpha: 0.88 * safeAlpha)

    context.saveGState()
    context.setStrokeColor(branchColor.cgColor)
    context.setLineWidth(max(1.4, min(rect.width, rect.height) * 0.08))
    context.setLineCap(.round)
    context.move(to: CGPoint(x: rect.minX + (rect.width * 0.18), y: rect.minY + (rect.height * 0.84)))
    context.addCurve(
      to: CGPoint(x: rect.minX + (rect.width * 0.78), y: rect.minY + (rect.height * 0.24)),
      control1: CGPoint(x: rect.minX + (rect.width * 0.32), y: rect.minY + (rect.height * 0.72)),
      control2: CGPoint(x: rect.minX + (rect.width * 0.52), y: rect.minY + (rect.height * 0.48))
    )
    context.strokePath()
    context.restoreGState()

    func drawLeaf(center: CGPoint, scale: CGFloat, rotation: CGFloat) {
      context.saveGState()
      context.translateBy(x: center.x, y: center.y)
      context.rotate(by: rotation)
      let leaf = UIBezierPath()
      leaf.move(to: .zero)
      leaf.addCurve(
        to: CGPoint(x: rect.width * 0.13 * scale, y: 0),
        controlPoint1: CGPoint(x: rect.width * 0.04 * scale, y: -(rect.height * 0.04 * scale)),
        controlPoint2: CGPoint(x: rect.width * 0.10 * scale, y: -(rect.height * 0.02 * scale))
      )
      leaf.addCurve(
        to: CGPoint(x: 0, y: rect.height * 0.02 * scale),
        controlPoint1: CGPoint(x: rect.width * 0.10 * scale, y: rect.height * 0.04 * scale),
        controlPoint2: CGPoint(x: rect.width * 0.04 * scale, y: rect.height * 0.04 * scale)
      )
      leaf.addCurve(
        to: .zero,
        controlPoint1: CGPoint(x: -(rect.width * 0.03 * scale), y: rect.height * 0.01 * scale),
        controlPoint2: CGPoint(x: -(rect.width * 0.03 * scale), y: -(rect.height * 0.01 * scale))
      )
      context.setFillColor(leafColor.cgColor)
      context.addPath(leaf.cgPath)
      context.fillPath()
      context.restoreGState()
    }

    func drawFlower(center: CGPoint, radius: CGFloat) {
      context.saveGState()
      context.setShadow(offset: .zero, blur: radius * 0.6, color: flowerColor.withAlphaComponent(0.28).cgColor)
      context.setFillColor(flowerColor.cgColor)
      context.fillEllipse(in: CGRect(x: center.x - (radius * 1.1), y: center.y - (radius * 1.1), width: radius * 2.2, height: radius * 2.2))
      context.restoreGState()

      for index in 0..<5 {
        let angle = (-CGFloat.pi / 2.0) + ((CGFloat.pi * 2.0 / 5.0) * CGFloat(index))
        let petalCenter = CGPoint(
          x: center.x + (cos(angle) * radius * 0.64),
          y: center.y + (sin(angle) * radius * 0.64)
        )
        context.saveGState()
        context.translateBy(x: petalCenter.x, y: petalCenter.y)
        context.rotate(by: angle)
        if let gradient = CGGradient(
          colorsSpace: CGColorSpaceCreateDeviceRGB(),
          colors: [
            petalHighlight.cgColor,
            flowerColor.cgColor,
            UIColor(red: 226.0 / 255.0, green: 170.0 / 255.0, blue: 42.0 / 255.0, alpha: 0.78 * safeAlpha).cgColor,
          ] as CFArray,
          locations: [0, 0.62, 1]
        ) {
          context.addEllipse(in: CGRect(x: -(radius * 0.42), y: -(radius * 0.62), width: radius * 0.84, height: radius * 1.24))
          context.clip()
          context.drawRadialGradient(
            gradient,
            startCenter: .zero,
            startRadius: 0,
            endCenter: .zero,
            endRadius: radius,
            options: []
          )
        }
        context.restoreGState()
      }

      context.setFillColor(UIColor(red: 1.0, green: 241.0 / 255.0, blue: 168.0 / 255.0, alpha: safeAlpha).cgColor)
      context.fillEllipse(in: CGRect(x: center.x - (radius * 0.26), y: center.y - (radius * 0.26), width: radius * 0.52, height: radius * 0.52))
      context.setFillColor(UIColor(red: 179.0 / 255.0, green: 122.0 / 255.0, blue: 18.0 / 255.0, alpha: 0.96 * safeAlpha).cgColor)
      context.fillEllipse(in: CGRect(x: center.x - (radius * 0.14), y: center.y - (radius * 0.14), width: radius * 0.28, height: radius * 0.28))
    }

    drawLeaf(center: CGPoint(x: rect.minX + (rect.width * 0.36), y: rect.minY + (rect.height * 0.68)), scale: 1.0, rotation: -0.31)
    drawLeaf(center: CGPoint(x: rect.minX + (rect.width * 0.57), y: rect.minY + (rect.height * 0.48)), scale: 0.88, rotation: 0.59)
    drawLeaf(center: CGPoint(x: rect.minX + (rect.width * 0.66), y: rect.minY + (rect.height * 0.36)), scale: 0.76, rotation: -0.63)

    let flowerRadius = min(rect.width, rect.height) * 0.15
    drawFlower(center: CGPoint(x: rect.minX + (rect.width * 0.58), y: rect.minY + (rect.height * 0.46)), radius: flowerRadius)
    drawFlower(center: CGPoint(x: rect.minX + (rect.width * 0.72), y: rect.minY + (rect.height * 0.29)), radius: flowerRadius * 0.74)
    drawFlower(center: CGPoint(x: rect.minX + (rect.width * 0.42), y: rect.minY + (rect.height * 0.60)), radius: flowerRadius * 0.68)
  }

  private func drawCircularText(
    _ text: String,
    center: CGPoint,
    radius: CGFloat,
    startAngleDegrees: CGFloat,
    sweepDegrees: CGFloat,
    in context: CGContext,
    font: UIFont,
    color: UIColor
  ) {
    let characters = Array(text)
    guard !characters.isEmpty else { return }
    let step = characters.count <= 1 ? 0 : sweepDegrees / CGFloat(characters.count - 1)
    for (index, character) in characters.enumerated() {
      let angle = (startAngleDegrees + (step * CGFloat(index))) * .pi / 180.0
      let x = center.x + (cos(angle) * radius)
      let y = center.y + (sin(angle) * radius)
      context.saveGState()
      context.translateBy(x: x, y: y)
      context.rotate(by: angle + (.pi / 2.0))
      let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
      ]
      let letter = NSAttributedString(string: String(character), attributes: attributes)
      let size = letter.size()
      letter.draw(
        in: CGRect(
          x: -(size.width / 2.0),
          y: -(size.height / 2.0),
          width: size.width,
          height: size.height
        )
      )
      context.restoreGState()
    }
  }

  private func drawText(
    _ text: String,
    in rect: CGRect,
    font: UIFont,
    color: UIColor,
    alignment: NSTextAlignment,
    shadow: NSShadow? = nil
  ) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    var attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraph,
    ]
    if let shadow = shadow {
      attributes[.shadow] = shadow
    }
    NSAttributedString(string: text, attributes: attributes).draw(in: rect)
  }

  private func fittedSingleLineText(
    _ text: String,
    font: UIFont,
    maxWidth: CGFloat
  ) -> String {
    let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalized.isEmpty else { return "" }
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    if NSString(string: normalized).size(withAttributes: attributes).width <= maxWidth {
      return normalized
    }

    var trimmed = normalized
    while !trimmed.isEmpty &&
      NSString(string: "\(trimmed)...").size(withAttributes: attributes).width > maxWidth {
      trimmed.removeLast()
      trimmed = trimmed.trimmingCharacters(in: .whitespaces)
    }
    return trimmed.isEmpty ? "..." : "\(trimmed)..."
  }

  private func fillRoundedRect(
    in context: CGContext,
    rect: CGRect,
    radius: CGFloat,
    colors: [UIColor],
    locations: [CGFloat]
  ) {
    context.saveGState()
    context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
    context.clip()
    fillRectWithGradient(
      in: context,
      rect: rect,
      colors: colors,
      locations: locations,
      start: CGPoint(x: rect.minX, y: rect.minY),
      end: CGPoint(x: rect.maxX, y: rect.maxY)
    )
    context.restoreGState()
  }

  private func fillRectWithGradient(
    in context: CGContext,
    rect: CGRect,
    colors: [UIColor],
    locations: [CGFloat],
    start: CGPoint,
    end: CGPoint
  ) {
    let gradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: colors.map { $0.cgColor } as CFArray,
      locations: locations
    )
    if let gradient {
      context.drawLinearGradient(
        gradient,
        start: start,
        end: end,
        options: []
      )
    }
  }

  private func fillCircleWithRadialGradient(
    in context: CGContext,
    center: CGPoint,
    radius: CGFloat,
    colors: [UIColor],
    locations: [CGFloat]
  ) {
    context.saveGState()
    context.addEllipse(
      in: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2.0,
        height: radius * 2.0
      )
    )
    context.clip()
    let gradient = CGGradient(
      colorsSpace: CGColorSpaceCreateDeviceRGB(),
      colors: colors.map { $0.cgColor } as CFArray,
      locations: locations
    )
    if let gradient {
      context.drawRadialGradient(
        gradient,
        startCenter: CGPoint(x: center.x - (radius * 0.18), y: center.y - (radius * 0.24)),
        startRadius: 0,
        endCenter: center,
        endRadius: radius,
        options: []
      )
    }
    context.restoreGState()
  }

  private func blendedColor(_ start: UIColor, _ end: UIColor, factor: CGFloat) -> UIColor {
    let safeFactor = min(1, max(0, factor))
    var startRed: CGFloat = 0
    var startGreen: CGFloat = 0
    var startBlue: CGFloat = 0
    var startAlpha: CGFloat = 0
    var endRed: CGFloat = 0
    var endGreen: CGFloat = 0
    var endBlue: CGFloat = 0
    var endAlpha: CGFloat = 0
    start.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
    end.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
    return UIColor(
      red: startRed + ((endRed - startRed) * safeFactor),
      green: startGreen + ((endGreen - startGreen) * safeFactor),
      blue: startBlue + ((endBlue - startBlue) * safeFactor),
      alpha: startAlpha + ((endAlpha - startAlpha) * safeFactor)
    )
  }

  private func constellationPoints(for signKey: String) -> [CGPoint] {
    switch signKey {
    case "taurus":
      return [
        CGPoint(x: 0.08, y: 0.56), CGPoint(x: 0.17, y: 0.45), CGPoint(x: 0.31, y: 0.62),
        CGPoint(x: 0.42, y: 0.36), CGPoint(x: 0.55, y: 0.47), CGPoint(x: 0.67, y: 0.31),
        CGPoint(x: 0.82, y: 0.50),
      ]
    case "gemini":
      return [
        CGPoint(x: 0.10, y: 0.33), CGPoint(x: 0.10, y: 0.69), CGPoint(x: 0.28, y: 0.40),
        CGPoint(x: 0.28, y: 0.63), CGPoint(x: 0.50, y: 0.34), CGPoint(x: 0.50, y: 0.66),
        CGPoint(x: 0.74, y: 0.45),
      ]
    case "cancer":
      return [
        CGPoint(x: 0.09, y: 0.62), CGPoint(x: 0.21, y: 0.48), CGPoint(x: 0.33, y: 0.58),
        CGPoint(x: 0.45, y: 0.41), CGPoint(x: 0.59, y: 0.52), CGPoint(x: 0.73, y: 0.37),
        CGPoint(x: 0.84, y: 0.46),
      ]
    case "leo":
      return [
        CGPoint(x: 0.08, y: 0.52), CGPoint(x: 0.20, y: 0.38), CGPoint(x: 0.34, y: 0.45),
        CGPoint(x: 0.45, y: 0.29), CGPoint(x: 0.57, y: 0.55), CGPoint(x: 0.69, y: 0.64),
        CGPoint(x: 0.82, y: 0.42),
      ]
    case "virgo":
      return [
        CGPoint(x: 0.08, y: 0.37), CGPoint(x: 0.17, y: 0.66), CGPoint(x: 0.30, y: 0.42),
        CGPoint(x: 0.43, y: 0.62), CGPoint(x: 0.54, y: 0.35), CGPoint(x: 0.68, y: 0.58),
        CGPoint(x: 0.82, y: 0.40),
      ]
    case "libra":
      return [
        CGPoint(x: 0.08, y: 0.59), CGPoint(x: 0.22, y: 0.40), CGPoint(x: 0.34, y: 0.40),
        CGPoint(x: 0.46, y: 0.60), CGPoint(x: 0.58, y: 0.40), CGPoint(x: 0.70, y: 0.40),
        CGPoint(x: 0.84, y: 0.59),
      ]
    case "scorpio":
      return [
        CGPoint(x: 0.08, y: 0.35), CGPoint(x: 0.17, y: 0.67), CGPoint(x: 0.29, y: 0.41),
        CGPoint(x: 0.41, y: 0.65), CGPoint(x: 0.56, y: 0.48), CGPoint(x: 0.70, y: 0.38),
        CGPoint(x: 0.84, y: 0.56),
      ]
    case "sagittarius":
      return [
        CGPoint(x: 0.10, y: 0.66), CGPoint(x: 0.22, y: 0.48), CGPoint(x: 0.34, y: 0.36),
        CGPoint(x: 0.48, y: 0.54), CGPoint(x: 0.58, y: 0.36), CGPoint(x: 0.72, y: 0.26),
        CGPoint(x: 0.84, y: 0.52),
      ]
    case "capricorn":
      return [
        CGPoint(x: 0.08, y: 0.57), CGPoint(x: 0.19, y: 0.43), CGPoint(x: 0.32, y: 0.59),
        CGPoint(x: 0.45, y: 0.37), CGPoint(x: 0.57, y: 0.55), CGPoint(x: 0.68, y: 0.33),
        CGPoint(x: 0.82, y: 0.49),
      ]
    case "aquarius":
      return [
        CGPoint(x: 0.08, y: 0.42), CGPoint(x: 0.20, y: 0.54), CGPoint(x: 0.32, y: 0.40),
        CGPoint(x: 0.46, y: 0.54), CGPoint(x: 0.58, y: 0.38), CGPoint(x: 0.72, y: 0.52),
        CGPoint(x: 0.84, y: 0.40),
      ]
    case "pisces":
      return [
        CGPoint(x: 0.10, y: 0.35), CGPoint(x: 0.22, y: 0.52), CGPoint(x: 0.34, y: 0.66),
        CGPoint(x: 0.48, y: 0.50), CGPoint(x: 0.60, y: 0.35), CGPoint(x: 0.72, y: 0.52),
        CGPoint(x: 0.84, y: 0.66),
      ]
    default:
      return [
        CGPoint(x: 0.08, y: 0.60), CGPoint(x: 0.16, y: 0.40), CGPoint(x: 0.28, y: 0.52),
        CGPoint(x: 0.40, y: 0.34), CGPoint(x: 0.56, y: 0.50), CGPoint(x: 0.70, y: 0.36),
        CGPoint(x: 0.82, y: 0.56),
      ]
    }
  }

  private func barHeightScale(for signKey: String) -> CGFloat {
    switch signKey {
    case "taurus", "capricorn":
      return 1.04
    case "gemini", "aquarius":
      return 0.94
    case "leo", "sagittarius":
      return 1.02
    case "pisces", "cancer":
      return 0.98
    default:
      return 1.0
    }
  }

  private func coinScale(for signKey: String) -> CGFloat {
    switch signKey {
    case "leo":
      return 1.08
    case "taurus", "capricorn":
      return 1.04
    case "gemini", "virgo":
      return 0.96
    case "libra":
      return 0.98
    case "pisces":
      return 1.02
    default:
      return 1.0
    }
  }
}

private func boostColor(_ color: UIColor) -> UIColor {
  var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
  if color.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
    // We boost saturation by 18% and brightness by a scaled 8% + 0.02 base offset
    // to match the original CIColorControls filter intent.
    let newS = min(1.0, max(0.0, s * 1.18))
    let newB = min(1.0, max(0.0, (b * 1.08) + 0.02))
    return UIColor(hue: h, saturation: newS, brightness: newB, alpha: a)
  }
  return color
}

private extension NSShadow {
  static func make(color: UIColor, offset: CGSize, blur: CGFloat) -> NSShadow {
    let shadow = NSShadow()
    shadow.shadowColor = color
    shadow.shadowOffset = offset
    shadow.shadowBlurRadius = blur
    return shadow
  }
}
