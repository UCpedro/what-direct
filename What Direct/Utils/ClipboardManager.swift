import Foundation
import UIKit

struct ClipboardManager {
    func suggestedNumber() -> String? {
        PhoneNumberFormatter.probableClipboardNumber(from: UIPasteboard.general.string)
    }

    func currentString() -> String? {
        UIPasteboard.general.string
    }

    func copy(_ value: String) {
        UIPasteboard.general.string = value
    }
}
