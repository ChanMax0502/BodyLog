import SwiftUI

struct BrandTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    @FocusState private var focused: Bool

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .focused($focused)
        .font(BrandFont.bodyMD)
        .foregroundColor(BrandColor.ink)
        .tint(BrandColor.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(height: 40)
        .background(BrandColor.canvas)
        .overlay(
            RoundedRectangle(cornerRadius: BrandRadius.md, style: .continuous)
                .strokeBorder(focused ? BrandColor.primary : BrandColor.hairline, lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BrandRadius.md, style: .continuous)
                .stroke(BrandColor.primary.opacity(focused ? 0.15 : 0), lineWidth: 3)
        )
        .clipShape(RoundedRectangle(cornerRadius: BrandRadius.md, style: .continuous))
    }
}

#Preview("TextField") {
    struct Demo: View {
        @State var a = ""
        @State var b = "已输入内容"
        var body: some View {
            VStack(spacing: BrandSpacing.md) {
                BrandTextField(placeholder: "Email", text: $a)
                BrandTextField(placeholder: "Password", text: $b, isSecure: true)
            }
            .padding(BrandSpacing.lg)
            .background(BrandColor.canvas)
        }
    }
    return Demo()
}
