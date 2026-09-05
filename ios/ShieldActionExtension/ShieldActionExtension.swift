import DeviceActivity
import Foundation
import ManagedSettings

final class ShieldActionExtension: ShieldActionDelegate {
  override func handle(
    action: ShieldAction,
    for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    guard action == .primaryButtonPressed else {
      completionHandler(.close)
      return
    }
    let seconds = NiyyahStore.readingSecondsSinceShown() ?? 0
    NiyyahStore.addReading(seconds: seconds)
    NiyyahStore.startSession()
    scheduleSessionEnd()
    completionHandler(.close)
  }

  private func scheduleSessionEnd() {
    let start = Date()
    let end = NiyyahStore.sessionEndDate
      ?? start.addingTimeInterval(TimeInterval(NiyyahStore.sessionMinutes * 60))
    let calendar = Calendar.current
    let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
    let schedule = DeviceActivitySchedule(
      intervalStart: calendar.dateComponents(components, from: start),
      intervalEnd: calendar.dateComponents(components, from: end),
      repeats: false
    )
    try? DeviceActivityCenter().startMonitoring(
      DeviceActivityName("niyyah.session"),
      during: schedule
    )
  }
}
