import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(
    shielding application: Application,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(
    shielding webDomain: WebDomain,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    configuration()
  }

  private func configuration() -> ShieldConfiguration {
    NiyyahStore.recordShieldShown()
    let ink = UIColor(red: 0.129, green: 0.122, blue: 0.110, alpha: 1)
    let title: ShieldConfiguration.Label
    let subtitle: ShieldConfiguration.Label
    if let item = ShieldContent.todayItem() {
      title = ShieldConfiguration.Label(text: item.source, color: ink)
      switch ShieldContent.style() {
      case "arabicOnly":
        subtitle = ShieldConfiguration.Label(text: item.arabic, color: ink)
      case "englishOnly":
        subtitle = ShieldConfiguration.Label(text: item.translationEn, color: ink)
      default:
        subtitle = ShieldConfiguration.Label(text: item.arabic + "\n\n" + item.translationEn, color: ink)
      }
    } else {
      title = ShieldConfiguration.Label(text: "Niyyah", color: ink)
      subtitle = ShieldConfiguration.Label(text: "Take a moment before continuing.", color: ink)
    }
    return ShieldConfiguration(
      backgroundColor: UIColor(red: 0.988, green: 0.984, blue: 0.969, alpha: 1),
      title: title,
      subtitle: subtitle,
      primaryButtonLabel: ShieldConfiguration.Label(text: "I've read it", color: .white),
      primaryButtonBackgroundColor: UIColor(red: 0.184, green: 0.420, blue: 0.310, alpha: 1)
    )
  }
}
