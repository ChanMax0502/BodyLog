import SwiftUI

enum BrandButtonVariant {
    case primary
    case secondary
    case secondaryOnDark
    case textLink
    case coralLink
}

struct BrandButtonStyle: ButtonStyle {
    let variant: BrandButtonVariant
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let palette = palette(pressed: configuration.isPressed)
        return configuration.label
            .font(BrandFont.button)
            .foregroundColor(palette.fg)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(minHeight: height)
            .background(palette.bg)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.md, style: .continuous)
                    .strokeBorder(palette.border, lineWidth: palette.border == .clear ? 0 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: BrandRadius.md, style: .continuous))
            .opacity(configuration.isPressed && variant == .textLink ? 0.6 : 1)
            .opacity(configuration.isPressed && variant == .coralLink ? 0.6 : 1)
    }

    private var horizontalPadding: CGFloat {
        switch variant {
        case .textLink, .coralLink: return 0
        default: return 20
        }
    }

    private var verticalPadding: CGFloat {
        switch variant {
        case .textLink, .coralLink: return 0
        default: return 12
        }
    }

    private var height: CGFloat {
        switch variant {
        case .textLink, .coralLink: return 0
        default: return 40
        }
    }

    private struct Palette {
        let bg: Color
        let fg: Color
        let border: Color
    }

    private func palette(pressed: Bool) -> Palette {
        switch variant {
        case .primary:
            if !isEnabled {
                return Palette(bg: BrandColor.primaryDisabled, fg: BrandColor.muted, border: .clear)
            }
            return Palette(
                bg: pressed ? BrandColor.primaryActive : BrandColor.primary,
                fg: BrandColor.onPrimary,
                border: .clear
            )
        case .secondary:
            return Palette(
                bg: pressed ? BrandColor.surfaceSoft : BrandColor.canvas,
                fg: BrandColor.ink,
                border: BrandColor.hairline
            )
        case .secondaryOnDark:
            return Palette(
                bg: pressed ? BrandColor.surfaceDarkSoft : BrandColor.surfaceDarkElevated,
                fg: BrandColor.onDark,
                border: .clear
            )
        case .textLink:
            return Palette(bg: .clear, fg: BrandColor.ink, border: .clear)
        case .coralLink:
            return Palette(bg: .clear, fg: BrandColor.primary, border: .clear)
        }
    }
}

extension ButtonStyle where Self == BrandButtonStyle {
    static func brand(_ variant: BrandButtonVariant) -> BrandButtonStyle {
        BrandButtonStyle(variant: variant)
    }
}

struct BrandIconButton<Icon: View>: View {
    let action: () -> Void
    let icon: () -> Icon

    init(action: @escaping () -> Void, @ViewBuilder icon: @escaping () -> Icon) {
        self.action = action
        self.icon = icon
    }

    var body: some View {
        Button(action: action) {
            icon()
                .foregroundColor(BrandColor.ink)
                .frame(width: 36, height: 36)
                .background(BrandColor.canvas)
                .overlay(
                    Circle().strokeBorder(BrandColor.hairline, lineWidth: 1)
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Buttons") {
    VStack(alignment: .leading, spacing: BrandSpacing.md) {
        Button("Try Claude") {}.buttonStyle(.brand(.primary))
        Button("Disabled") {}.buttonStyle(.brand(.primary)).disabled(true)
        Button("Secondary") {}.buttonStyle(.brand(.secondary))
        Button("On dark") {}.buttonStyle(.brand(.secondaryOnDark))
            .padding(BrandSpacing.md).background(BrandColor.surfaceDark)
        Button("Sign in") {}.buttonStyle(.brand(.textLink))
        Button("Learn more") {}.buttonStyle(.brand(.coralLink))
        HStack(spacing: BrandSpacing.sm) {
            BrandIconButton(action: {}) { Image(systemName: "arrow.left") }
            BrandIconButton(action: {}) { Image(systemName: "arrow.right") }
        }
    }
    .padding(BrandSpacing.lg)
    .background(BrandColor.canvas)
}
