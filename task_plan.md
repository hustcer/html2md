# Task Plan: html2md MoonBit 库 P0~P7

## Goal
按 PLAN.md 实现 MoonBit 版 html2md 库（对齐 JohannesKaufmann/html-to-markdown v2），完成 P0~P7。P7 当前范围是 GFM table 与 strikethrough `~~`，随后同步 PLAN.md。

## Phases
| Phase | 内容 | Status |
|---|---|---|
| P0 脚手架 | moon.mod/moon.pkg/依赖/冒烟 | complete |
| P1 DOM 适配层 | internal/domext | complete |
| P2 文本工具+折叠 | internal/textutils、internal/collapse | complete |
| P3 引擎+基础行为 | render 骨架、fallback、remove、文本管线、post-render | complete |
| P4 commonmark 渲染 | 全部 render_* + internal/domutils 变换 | complete |
| P5 智能转义 | internal/escape：marker + 11 un-escaper | complete |
| P6 收尾 | url.mbt、配置校验、README.mbt.md、moon info | complete |
| P7a strikethrough | 渲染 `s`/`del`/`strike` 为 `~~...~~`，覆盖嵌套与转义 | complete |
| P7b GFM table | 渲染 `table/thead/tbody/tr/th/td` 为 GFM Markdown 表格，覆盖 header、body、inline 内容与转义 | complete |
| P7c 文档同步 | 更新 README/PLAN/progress/findings，标记 P7 完成状态 | complete |
| P7d 验证 | `moon fmt`、`moon check --target all`、`moon test --target all`、`moon info` | complete |

## Key Decisions
- 解析器用 bobzhang/html_parser@0.1.7（仅 parser/dom/core 包），不自研
- 不用其自带 to_markdown（基础款），转换管线全自建
- DOM 适配：children 数组型 + name/data 不可变 → domext 替换式助手
- marker：转义占位 U+0007，代码块换行 U+F002
- 每个 Phase 完成 = moon check + moon test + moon fmt + moon info 全过，然后 commit
- P7 不引入运行时插件框架，先作为固定流水线内置渲染器实现 table 和 strikethrough。
- GFM table 输出要求至少一行 header 与 delimiter；缺少显式 header 时使用首行作为 header，空表 fallback 为子节点渲染。
- P7 已完成固定渲染器实现；Renderer 自定义钩子留作后续 P8 设计。
- URL query 重编码按 RFC 3986/WHATWG URL 的标准语义实现，不盲目复刻 Go 版键值对重写；`+` 保留为字面 plus，空格编码为 `%20`。

## Errors Encountered
| Error | Attempt | Resolution |
|---|---|---|
