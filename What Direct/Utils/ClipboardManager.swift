import Foundation
import UIKit

struct ClipboardManager {
    func suggestedNumber() -> String? {
        guard let text = UIPasteboard.general.string else { return nil }
        let cleaned = PhoneNumberFormatter.clean(text)
        return cleaned.count >= 6 ? text : nil
    }
}
