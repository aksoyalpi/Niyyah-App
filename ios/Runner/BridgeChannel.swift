import Flutter
import FamilyControls
import SwiftUI
import UIKit

enum BridgeChannel {
  static let name = "niyyah/bridge"

  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: name, binaryMessenger: messenger)
    channel.setMethodCallHandler(handle)

    let center = NotificationCenter.default
    center.addObserver(
      forName: UIApplication.didBecomeActiveNotification,
      object: nil,
      queue: .main
    ) { _ in NiyyahStore.syncSettings() }
    center.addObserver(
      forName: UIApplication.didEnterBackgroundNotification,
      object: nil,
      queue: .main
    ) { _ in NiyyahStore.syncSettings() }
  }

  static func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    switch call.method {
    case "getAuthorization":
      result(["status": AuthorizationCenter.shared.authorizationStatus.rawValue])
    case "requestAuthorization":
      Task { result(await requestAuthorization()) }
    case "pickAppsToBlock":
      presentPicker(result)
    case "selectedAppCount":
      result(["count": NiyyahStore.selectionCount])
    case "getStats":
      result(["days": NiyyahStore.daysPayload()])
    case "syncSettings":
      NiyyahStore.syncSettings()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  static func requestAuthorization() async -> [String: Any] {
    do {
      _ = try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    } catch {}
    return ["status": AuthorizationCenter.shared.authorizationStatus.rawValue]
  }

  static func presentPicker(_ result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      guard NiyyahStore.isAuthorized else {
        result(["count": NiyyahStore.selectionCount])
        return
      }
      guard let root = UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
        .first
      else {
        result(["count": NiyyahStore.selectionCount])
        return
      }
      var responded = false
      func respond(_ selection: FamilyActivitySelection?) {
        guard !responded else { return }
        responded = true
        if let selection {
          NiyyahStore.saveSelection(selection)
        }
        result(["count": NiyyahStore.selectionCount])
      }
      var host: UIHostingController<AppPickerView>?
      host = UIHostingController(
        rootView: AppPickerView(selection: NiyyahStore.loadSelection()) { selection in
          host?.dismiss(animated: true)
          respond(selection)
        }
      )
      host?.isModalInPresentation = true
      root.present(host!, animated: true)
    }
  }
}
