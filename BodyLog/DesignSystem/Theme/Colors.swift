import SwiftUI

enum BrandColor {
    static let primary           = Color(hex: 0xCC785C)
    static let primaryActive     = Color(hex: 0xA9583E)
    static let primaryDisabled   = Color(hex: 0xE6DFD8)

    static let ink           = Color(hex: 0x141413)
    static let body          = Color(hex: 0x3D3D3A)
    static let bodyStrong    = Color(hex: 0x252523)
    static let muted         = Color(hex: 0x6C6A64)
    static let mutedSoft     = Color(hex: 0x8E8B82)
    static let onPrimary     = Color(hex: 0xFFFFFF)
    static let onDark        = Color(hex: 0xFAF9F5)
    static let onDarkSoft    = Color(hex: 0xA09D96)

    static let canvas                = Color(hex: 0xFAF9F5)
    static let surfaceSoft           = Color(hex: 0xF5F0E8)
    static let surfaceCard           = Color(hex: 0xEFE9DE)
    static let surfaceCreamStrong    = Color(hex: 0xE8E0D2)
    static let surfaceDark           = Color(hex: 0x181715)
    static let surfaceDarkElevated   = Color(hex: 0x252320)
    static let surfaceDarkSoft       = Color(hex: 0x1F1E1B)

    static let hairline      = Color(hex: 0xE6DFD8)
    static let hairlineSoft  = Color(hex: 0xEBE6DF)

    static let accentTeal    = Color(hex: 0x5DB8A6)
    static let accentAmber   = Color(hex: 0xE8A55A)

    static let success       = Color(hex: 0x5DB872)
    static let warning       = Color(hex: 0xD4A017)
    static let error         = Color(hex: 0xC64545)
}

extension Color {
    fileprivate init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
