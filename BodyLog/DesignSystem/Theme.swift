import SwiftUI

enum AppFont {
    static let largeTitle  = Font.system(.largeTitle, design: .default).weight(.semibold)
    static let title       = Font.system(.title2, design: .default).weight(.semibold)
    static let cardTitle   = Font.system(.headline, design: .default).weight(.semibold)
    static let body        = Font.system(.body)
    static let footnote    = Font.system(.footnote)
    static let caption     = Font.system(.caption)
}

enum AppDuration {
    static let short:  Double = 0.25
    static let medium: Double = 0.35
}
