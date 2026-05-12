import SwiftUI

struct BrandCategoryTab: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(BrandFont.navLink)
                .foregroundColor(isActive ? BrandColor.ink : BrandColor.muted)
                .padding(.horizontal, 14)
                .padding(.vertical, BrandSpacing.xs)
                .background(isActive ? BrandColor.surfaceCard : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: BrandRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Category tabs") {
    HStack(spacing: BrandSpacing.xs) {
        BrandCategoryTab(label: "All", isActive: true, action: {})
        BrandCategoryTab(label: "Productivity", isActive: false, action: {})
        BrandCategoryTab(label: "Developer", isActive: false, action: {})
    }
    .padding(BrandSpacing.lg)
    .background(BrandColor.canvas)
}
