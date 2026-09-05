import ManagedSettings
import ManagedSettingsUI
import SwiftUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  override func configuration(
    shielding application: Application,
    context: Context
  ) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(
    shielding webDomain: WebDomain,
    context: Context
  ) -> ShieldConfiguration {
    configuration()
  }

  override func configuration(
    shielding application: Application,
    webDomain: WebDomain?,
    context: Context
  ) -> ShieldConfiguration {
    configuration()
  }

  private func configuration() -> ShieldConfiguration {
    NiyyahStore.recordShieldShown()
    let item = ShieldContent.todayItem()
    let title: String
    let subtitle: String
    if let item {
      title = item.source
      switch ShieldContent.style() {
      case "arabicOnly":
        subtitle = item.arabic
      case "englishOnly":
        subtitle = item.translationEn
      default:
        subtitle = item.arabic + "\n\n" + item.translationEn
      }
    } else {
      title = "Niyyah"
      subtitle = "Take a moment before continuing."
    }
    return ShieldConfiguration(
      background: .color(UIColor(red: 0.988, green: 0.984, blue: 0.969, alpha: 1)),
      title: title,
      titleColor: UIColor(red: 0.129, green: 0.122, blue: 0.110, alpha: 1),
      titleFont: Font.system(size: 17, weight: .semibold),
      subtitle: subtitle,
      subtitleColor: UIColor(red: 0.129, green: 0.122, blue: 0.110, alpha: 1),
      subtitleFont: Font.custom("Amiri", size: 24),
      primaryButtonLabel: "I've read it",
      primaryButtonLabelColor: .white,
      primaryButtonBackgroundColor: UIColor(red: 0.184, green: 0.420, blue: 0.310, alpha: 1)
    )
  }
}
