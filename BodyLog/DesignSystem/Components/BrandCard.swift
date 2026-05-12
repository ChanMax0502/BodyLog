import SwiftUI

private struct BrandCardShell<Content: View>: View {
    let background: Color
    let foreground: Color
    let radius: CGFloat
    let padding: CGFloat
    let borderColor: Color?
    let content: () -> Content

    var body: some View {
        content()
            .foregroundColor(foreground)
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .overlay(
                Group {
                    if let borderColor {
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: 1)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

struct BrandFeatureCard<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        BrandCardShell(
            background: BrandColor.surfaceCard,
            foreground: BrandColor.ink,
            radius: BrandRadius.lg,
            padding: BrandSpacing.xl,
            borderColor: nil,
            content: content
        )
    }
}

struct BrandDarkCard<Content: View>: View {
    let padding: CGFloat
    let content: () -> Content

    init(padding: CGFloat = BrandSpacing.xl, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        BrandCardShell(
            background: BrandColor.surfaceDark,
            foreground: BrandColor.onDark,
            radius: BrandRadius.lg,
            padding: padding,
            borderColor: nil,
            content: content
        )
    }
}

struct BrandCoralCallout<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        BrandCardShell(
            background: BrandColor.primary,
            foreground: BrandColor.onPrimary,
            radius: BrandRadius.lg,
            padding: BrandSpacing.xxl,
            borderColor: nil,
            content: content
        )
    }
}

struct BrandConnectorTile<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        BrandCardShell(
            background: BrandColor.canvas,
            foreground: BrandColor.ink,
            radius: BrandRadius.lg,
            padding: 20,
            borderColor: BrandColor.hairline,
            content: content
        )
    }
}

struct BrandOutlinedCard<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        BrandCardShell(
            background: BrandColor.canvas,
            foreground: BrandColor.ink,
            radius: BrandRadius.lg,
            padding: BrandSpacing.xl,
            borderColor: BrandColor.hairline,
            content: content
        )
    }
}

#Preview("Cards") {
    ScrollView {
        VStack(spacing: BrandSpacing.lg) {
            BrandFeatureCard {
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("Feature").font(BrandFont.titleMD)
                    Text("A slightly darker cream surface used for feature explanations.")
                        .font(BrandFont.bodyMD)
                        .foregroundColor(BrandColor.body)
                }
            }
            BrandDarkCard {
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("Product mockup").font(BrandFont.titleMD)
                    Text("Dark navy surface for code and product chrome.")
                        .font(BrandFont.bodyMD)
                        .foregroundColor(BrandColor.onDarkSoft)
                }
            }
            BrandCoralCallout {
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("Try Claude").font(BrandFont.displaySM)
                    Text("Coral callout — used sparingly for major CTAs.")
                        .font(BrandFont.bodyMD)
                }
            }
            BrandOutlinedCard {
                Text("Pricing tier card").font(BrandFont.titleLG)
            }
            BrandConnectorTile {
                Text("Connector").font(BrandFont.titleSM)
            }
        }
        .padding(BrandSpacing.lg)
    }
    .background(BrandColor.canvas)
}
