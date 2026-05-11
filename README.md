# BodyLog

身体变化记录与追踪 App · iOS · 纯本地存储 · 隐私优先

## 开发环境

- Xcode 26.4 +
- iOS 16.0 +
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## 生成与打开工程

```bash
xcodegen generate
open BodyLog.xcodeproj
```

`BodyLog.xcodeproj` 不入库（见 `.gitignore`），权威源是 `project.yml`。新增 / 删除文件后重新执行 `xcodegen generate` 即可。

## 命令行编译验证

```bash
xcodebuild \
  -project BodyLog.xcodeproj \
  -scheme BodyLog \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 目录结构

详见 [`BodyLog_PRD_MVP_v1.1.docx`](BodyLog_PRD_MVP_v1.1.docx) 与 `BodyLog/` 子目录中的源码注释。
