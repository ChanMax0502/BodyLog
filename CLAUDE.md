# BodyLog · Claude 指南

iOS 端「身体变化记录与追踪」App，中文优先、纯本地存储、隐私优先。当前 MVP v0.1.0。

## 技术栈

- **语言/版本**：Swift 5.9，Xcode 26.4+，iOS 16.0+，仅 iPhone 竖屏
- **UI**：SwiftUI（无 UIKit）
- **持久化**：Core Data，实体 `Tracker` / `Entry`，单例 `PersistenceController`
- **能力模块**：
  - Face ID：`Core/Auth/BiometricAuth`
  - 本地通知：`Core/Notifications/ReminderScheduler`
  - 图片本地存储：`Core/Storage/ImageStorage` + `ThumbnailCache`
- **依赖**：无外部依赖（不用 SPM / CocoaPods）
- **本地化**：zh-Hans 优先
- **工程生成**：XcodeGen（`project.yml` 是权威源）

## 构建与运行

```bash
# 生成 / 同步 Xcode 工程
xcodegen generate
open BodyLog.xcodeproj

# 命令行编译验证
xcodebuild -project BodyLog.xcodeproj -scheme BodyLog \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug CODE_SIGNING_ALLOWED=NO build
```

> 新增 / 删除 / 移动 Swift 文件后**必须**重跑 `xcodegen generate`，否则文件不会进入 build。

## 目录结构与架构

```
BodyLog/
├─ BodyLogApp.swift / RootView.swift   // 入口与根导航
├─ Stores/        // TrackerStore、EntryStore（@MainActor ObservableObject）
├─ Models/        // Core Data 实体类 + Entity+Extensions.swift
├─ Core/
│  ├─ Persistence/    // PersistenceController
│  ├─ Auth/           // BiometricAuth
│  ├─ Storage/        // ImageStorage、ThumbnailCache
│  └─ Notifications/  // ReminderScheduler
├─ Features/      // Home / DailyLog / Calendar / Capture / Tracker / Settings / Lock
├─ DesignSystem/  // Theme、AppColor、AppSpacing、AppRadius
└─ Resources/     // BodyLog.xcdatamodeld、Assets.xcassets、Info.plist
```

- **架构**：MVVM-lite，SwiftUI + `@Published` + `@EnvironmentObject`，无第三方状态库
- **命名**：View 以 `View` 结尾；Core Data 实体扩展走 `Entity+Extensions.swift`
- **颜色**：从 `Assets.xcassets/Colors/` 取色，用语义名（`bgPrimary` / `textSecondary` / `accentBlue` 等），不要硬编码
- **UI 文案**：中文

## 开发禁忌与注意事项

- **不要手动编辑 `BodyLog.xcodeproj`**：改 `project.yml` 后重跑 `xcodegen generate`
- **不要把 `BodyLog.xcodeproj` 加入提交**：已在 `.gitignore` 中
- **新增依赖前必须先确认**：项目目前零外部依赖
- **只实现明确要求的功能**，不为假想需求预留扩展点
- **改动局部代码时保持原有风格**，不顺手重构未涉及的代码
- **不修改测试文件**（当前也没有测试 target）
- 产品需求权威文档：`documents/V1.1/BodyLog_PRD_MVP_v1.1.docx`

## UI Design
所有 UI 实现必须先阅读项目根目录的 DESIGN.md,严格遵循其中的色板、字体层级、组件样式、间距规则。
