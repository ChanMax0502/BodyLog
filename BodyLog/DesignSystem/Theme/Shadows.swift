import SwiftUI

enum BrandShadowStyle {
    case none
    case subtle
}

enum BrandShadow {
    static let subtleColor  = Color(.sRGB, red: 20.0/255, green: 20.0/255, blue: 19.0/255, opacity: 0.08)
    static let subtleRadius: CGFloat = 3
    static let subtleX:      CGFloat = 0
    static let subtleY:      CGFloat = 1
}

private struct BrandShadowModifier: ViewModifier {
    let style: BrandShadowStyle

    func body(content: Content) -> some View {
        switch style {
        case .none:
            content
        case .subtle:
            content.shadow(
                color: BrandShadow.subtleColor,
                radius: BrandShadow.subtleRadius,
                x: BrandShadow.subtleX,
                y: BrandShadow.subtleY
            )
        }
    }
}

extension View {
    func brandShadow(_ style: BrandShadowStyle) -> some View {
        modifier(BrandShadowModifier(style: style))
    }
}
