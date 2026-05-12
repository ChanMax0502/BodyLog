import SwiftUI

struct BrandPillBadge: View {
    let label: String
    init(_ label: String) { self.label = label }

    var body: some View {
        Text(label)
            .font(BrandFont.caption)
            .foregroundColor(BrandColor.ink)
            .padding(.horizontal, BrandSpacing.sm)
            .padding(.vertical, BrandSpacing.xxs)
            .background(BrandColor.surfaceCard)
            .clipShape(Capsule())
    }
}

struct BrandCoralBadge: View {
    let label: String
    init(_ label: String) { self.label = label }

    var body: some View {
        Text(label)
            .font(BrandFont.captionUppercase)
            .textCase(.uppercase)
            .tracking(BrandTracking.captionUppercase)
            .foregroundColor(BrandColor.onPrimary)
            .padding(.horizontal, BrandSpacing.sm)
            .padding(.vertical, BrandSpacing.xxs)
            .background(BrandColor.primary)
            .clipShape(Capsule())
    }
}

#Preview("Badges") {
    HStack(spacing: BrandSpacing.sm) {
        BrandPillBadge("Featured")
        BrandCoralBadge("New")
        BrandCoralBadge("Beta")
    }
    .padding(BrandSpacing.lg)
    .background(BrandColor.canvas)
}
