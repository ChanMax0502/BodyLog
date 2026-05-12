import SwiftUI

enum BrandFont {
    static let displayXL = Font.system(size: 64, weight: .regular, design: .serif)
    static let displayLG = Font.system(size: 48, weight: .regular, design: .serif)
    static let displayMD = Font.system(size: 36, weight: .regular, design: .serif)
    static let displaySM = Font.system(size: 28, weight: .regular, design: .serif)

    static let titleLG = Font.system(size: 22, weight: .medium, design: .default)
    static let titleMD = Font.system(size: 18, weight: .medium, design: .default)
    static let titleSM = Font.system(size: 16, weight: .medium, design: .default)

    static let bodyMD = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySM = Font.system(size: 14, weight: .regular, design: .default)

    static let caption          = Font.system(size: 13, weight: .medium, design: .default)
    static let captionUppercase = Font.system(size: 12, weight: .medium, design: .default)

    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)

    static let button  = Font.system(size: 14, weight: .medium, design: .default)
    static let navLink = Font.system(size: 14, weight: .medium, design: .default)
}

enum BrandTracking {
    static let displayXL: CGFloat = -1.5
    static let displayLG: CGFloat = -1.0
    static let displayMD: CGFloat = -0.5
    static let displaySM: CGFloat = -0.3
    static let captionUppercase: CGFloat = 1.5
}
