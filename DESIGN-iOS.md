# DESIGN-iOS · SwiftUI 设计系统入口

本文件是 `DESIGN.md`（Anthropic Claude 视觉语言）在 BodyLog iOS 工程内的落地清单。所有新 token 与组件统一加 `Brand` 前缀，与既有 `AppColor` / `AppSpacing` / `AppFont` **并存**（旧 token 不动，HomeView 等老界面保持原状）。

- 颜色：纯代码 `Color(hex:)`，不落 `Assets.xcassets`。单一权威源在 `Theme/Colors.swift`。
- 字体：iOS 系统字体 fallback —— serif 走 `.serif` design（New York）、sans 走默认（SF Pro）、mono 走 `.monospaced`。Copernicus / StyreneB 后续如打包真字体，只改 `Theme/Typography.swift` 内部实现，调用点不动。
- 阴影：DESIGN.md 哲学是 "color-block first, shadow rare"，仅一个 `subtle` token。
- 状态：DESIGN.md 明确不要 hover。Active/Pressed 由 SwiftUI `ButtonStyle` 内置触发，不另开 API。

## Colors · `enum BrandColor`

文件：[BodyLog/DesignSystem/Theme/Colors.swift](BodyLog/DesignSystem/Theme/Colors.swift)

| Swift 入口 | DESIGN.md key | Hex |
|---|---|---|
| `BrandColor.primary` | `{colors.primary}` | `#cc785c` |
| `BrandColor.primaryActive` | `{colors.primary-active}` | `#a9583e` |
| `BrandColor.primaryDisabled` | `{colors.primary-disabled}` | `#e6dfd8` |
| `BrandColor.ink` | `{colors.ink}` | `#141413` |
| `BrandColor.bodyStrong` | `{colors.body-strong}` | `#252523` |
| `BrandColor.body` | `{colors.body}` | `#3d3d3a` |
| `BrandColor.muted` | `{colors.muted}` | `#6c6a64` |
| `BrandColor.mutedSoft` | `{colors.muted-soft}` | `#8e8b82` |
| `BrandColor.hairline` | `{colors.hairline}` | `#e6dfd8` |
| `BrandColor.hairlineSoft` | `{colors.hairline-soft}` | `#ebe6df` |
| `BrandColor.canvas` | `{colors.canvas}` | `#faf9f5` |
| `BrandColor.surfaceSoft` | `{colors.surface-soft}` | `#f5f0e8` |
| `BrandColor.surfaceCard` | `{colors.surface-card}` | `#efe9de` |
| `BrandColor.surfaceCreamStrong` | `{colors.surface-cream-strong}` | `#e8e0d2` |
| `BrandColor.surfaceDark` | `{colors.surface-dark}` | `#181715` |
| `BrandColor.surfaceDarkElevated` | `{colors.surface-dark-elevated}` | `#252320` |
| `BrandColor.surfaceDarkSoft` | `{colors.surface-dark-soft}` | `#1f1e1b` |
| `BrandColor.onPrimary` | `{colors.on-primary}` | `#ffffff` |
| `BrandColor.onDark` | `{colors.on-dark}` | `#faf9f5` |
| `BrandColor.onDarkSoft` | `{colors.on-dark-soft}` | `#a09d96` |
| `BrandColor.accentTeal` | `{colors.accent-teal}` | `#5db8a6` |
| `BrandColor.accentAmber` | `{colors.accent-amber}` | `#e8a55a` |
| `BrandColor.success` | `{colors.success}` | `#5db872` |
| `BrandColor.warning` | `{colors.warning}` | `#d4a017` |
| `BrandColor.error` | `{colors.error}` | `#c64545` |

## Typography · `enum BrandFont`

文件：[BodyLog/DesignSystem/Theme/Typography.swift](BodyLog/DesignSystem/Theme/Typography.swift)

| Swift 入口 | DESIGN.md key | 字号 / 字重 / design | 配套 tracking |
|---|---|---|---|
| `BrandFont.displayXL` | `{typography.display-xl}` | 64 / regular / serif | `BrandTracking.displayXL` = -1.5 |
| `BrandFont.displayLG` | `{typography.display-lg}` | 48 / regular / serif | `BrandTracking.displayLG` = -1.0 |
| `BrandFont.displayMD` | `{typography.display-md}` | 36 / regular / serif | `BrandTracking.displayMD` = -0.5 |
| `BrandFont.displaySM` | `{typography.display-sm}` | 28 / regular / serif | `BrandTracking.displaySM` = -0.3 |
| `BrandFont.titleLG` | `{typography.title-lg}` | 22 / medium / default | — |
| `BrandFont.titleMD` | `{typography.title-md}` | 18 / medium / default | — |
| `BrandFont.titleSM` | `{typography.title-sm}` | 16 / medium / default | — |
| `BrandFont.bodyMD` | `{typography.body-md}` | 16 / regular / default | — |
| `BrandFont.bodySM` | `{typography.body-sm}` | 14 / regular / default | — |
| `BrandFont.caption` | `{typography.caption}` | 13 / medium / default | — |
| `BrandFont.captionUppercase` | `{typography.caption-uppercase}` | 12 / medium / default | `BrandTracking.captionUppercase` = 1.5 |
| `BrandFont.code` | `{typography.code}` | 14 / regular / monospaced | — |
| `BrandFont.button` | `{typography.button}` | 14 / medium / default | — |
| `BrandFont.navLink` | `{typography.nav-link}` | 14 / medium / default | — |

用法示例：

```swift
Text("Meet your thinking partner")
    .font(BrandFont.displayXL)
    .tracking(BrandTracking.displayXL)
    .foregroundColor(BrandColor.ink)
```

## Spacing · `enum BrandSpacing` / Radius · `enum BrandRadius`

文件：[BodyLog/DesignSystem/Theme/Spacing.swift](BodyLog/DesignSystem/Theme/Spacing.swift)

| Swift 入口 | DESIGN.md key | 值 |
|---|---|---|
| `BrandSpacing.xxs` | `{spacing.xxs}` | 4 |
| `BrandSpacing.xs` | `{spacing.xs}` | 8 |
| `BrandSpacing.sm` | `{spacing.sm}` | 12 |
| `BrandSpacing.md` | `{spacing.md}` | 16 |
| `BrandSpacing.lg` | `{spacing.lg}` | 24 |
| `BrandSpacing.xl` | `{spacing.xl}` | 32 |
| `BrandSpacing.xxl` | `{spacing.xxl}` | 48 |
| `BrandSpacing.section` | `{spacing.section}` | 96 |
| `BrandRadius.xs` | `{rounded.xs}` | 4 |
| `BrandRadius.sm` | `{rounded.sm}` | 6 |
| `BrandRadius.md` | `{rounded.md}` | 8 |
| `BrandRadius.lg` | `{rounded.lg}` | 12 |
| `BrandRadius.xl` | `{rounded.xl}` | 16 |
| `BrandRadius.pill` | `{rounded.pill}` / `{rounded.full}` | 9999 |

## Shadow · `BrandShadowStyle`

文件：[BodyLog/DesignSystem/Theme/Shadows.swift](BodyLog/DesignSystem/Theme/Shadows.swift)

| Swift 入口 | DESIGN.md 描述 | 实际值 |
|---|---|---|
| `View.brandShadow(.none)` | 默认无投影 | — |
| `View.brandShadow(.subtle)` | "Subtle drop shadow" 唯一一档 | `rgba(20,20,19,0.08)`，radius 3、y 1 |

用法：

```swift
BrandFeatureCard { Text("…") }.brandShadow(.subtle)
```

## Components

文件入口：[BodyLog/DesignSystem/Components/](BodyLog/DesignSystem/Components/)

| Swift 入口 | DESIGN.md key | 用途 |
|---|---|---|
| `Button(...).buttonStyle(.brand(.primary))` | `{component.button-primary}` + `-active` + `-disabled` | 信号 coral CTA；按下自动 active，`.disabled(true)` 自动 disabled |
| `.buttonStyle(.brand(.secondary))` | `{component.button-secondary}` | Cream 底 + hairline 描边 |
| `.buttonStyle(.brand(.secondaryOnDark))` | `{component.button-secondary-on-dark}` | 暗色卡片内的次级按钮 |
| `.buttonStyle(.brand(.textLink))` | `{component.button-text-link}` | 纯文字按钮（如顶部 "Sign in"） |
| `.buttonStyle(.brand(.coralLink))` | `{component.text-link}` | 内联 coral 文字链接 |
| `BrandIconButton` | `{component.button-icon-circular}` | 36pt 圆形图标按钮 |
| `BrandFeatureCard` | `{component.feature-card}` | surfaceCard 背景，3-up 特性卡 |
| `BrandDarkCard` | `{component.product-mockup-card-dark}` / `{component.code-window-card}` / `{component.pricing-tier-card-featured}` / `{component.cta-band-dark}` | 暗色产品/代码/featured 价位卡；`padding: BrandSpacing.lg` 用于 code-window |
| `BrandOutlinedCard` | `{component.pricing-tier-card}` / `{component.model-comparison-card}` | Canvas + hairline 描边 |
| `BrandCoralCallout` | `{component.callout-card-coral}` / `{component.cta-band-coral}` | 满铺 coral 大 CTA |
| `BrandConnectorTile` | `{component.connector-tile}` | 集成 logo 网格瓦片 |
| `BrandTextField` | `{component.text-input}` + `-focused` | 文本输入；聚焦自动 coral border + 3pt 外环 |
| `BrandPillBadge` | `{component.badge-pill}` | 普通标签 |
| `BrandCoralBadge` | `{component.badge-coral}` | NEW / BETA 类强调标签（自动 uppercase + tracking） |
| `BrandCategoryTab` | `{component.category-tab}` + `-active` | 二级 tab，传入 `isActive` 切换 |

最小示例：

```swift
BrandFeatureCard {
    VStack(alignment: .leading, spacing: BrandSpacing.sm) {
        Text("Feature").font(BrandFont.titleMD)
        Text("说明文字").font(BrandFont.bodyMD).foregroundColor(BrandColor.body)
    }
}
```

```swift
@State var email = ""
BrandTextField(placeholder: "Email", text: $email)
```

## Do / Don't（移植自 DESIGN.md）

**Do**
- 页面底色锚定 `BrandColor.canvas`。
- 显示级标题统一 `BrandFont.display*` 系列（serif），并配上对应 `BrandTracking.display*`。
- coral 仅用于主 CTA 与 `BrandCoralCallout`。
- 段落节奏：cream → cream-card → dark → cream → coral → dark。

**Don't**
- 不要把 serif display 加粗 —— 全部 weight `.regular`。
- 不要在普通文本里滥用 coral。
- 不要连续两段 band 用同一种 surface 色。
- 不要给新增组件臆造 hover 状态。

## 未来迁移点

- 真字体：替换 `Theme/Typography.swift` 内 `Font.system(...)` 为 `Font.custom("Copernicus-Regular", size:)` 即可，调用点零改动。
- 颜色：若需要暗色模式或动态色，把 `BrandColor` 的实现从 `Color(hex:)` 切到 `Color("Token", bundle: .main)` 并在 `Assets.xcassets` 加 light/dark 双值。
- 旧 token (`AppColor` / `AppSpacing` / `AppFont`) 的迁移作为独立任务推进，本次不动。
