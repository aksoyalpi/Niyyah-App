import DeviceActivity
import ManagedSettings

final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  override func intervalDidEnd(for activity: DeviceActivityName) {
    guard activity.rawValue == "niyyah.session" else { return }
    NiyyahStore.endSession()
    NiyyahStore.applyShield()
  }
}
