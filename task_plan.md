# Task Plan: html2md MoonBit 库 P0~P6

## Goal
按 PLAN.md 实现 MoonBit 版 html2md 库（对齐 JohannesKaufmann/html-to-markdown v2），完成 P0~P6，每组任务审查通过后 commit。

## Phases
| Phase | 内容 | Status |
|---|---|---|
| P0 脚手架 | moon.mod/moon.pkg/依赖/冒烟 | complete |
| P1 DOM 适配层 | internal/domext | complete |
| P2 文本工具+折叠 | internal/textutils、internal/collapse | complete |
| P3 引擎+基础行为 | render 骨架、fallback、remove、文本管线、post-render | complete |
| P4 commonmark 渲染 | 全部 render_* + internal/domutils 变换 | complete |
| P5 智能转义 | internal/escape：marker + 11 un-escaper | in_progress |
| P6 收尾 | url.mbt、配置校验、README.mbt.md、moon info | pending |

## Key Decisions
- 解析器用 bobzhang/html_parser@0.1.7（仅 parser/dom/core 包），不自研
- 不用其自带 to_markdown（基础款），转换管线全自建
- DOM 适配：children 数组型 + name/data 不可变 → domext 替换式助手
- marker：转义占位 U+0007，代码块换行 U+F002
- 每个 Phase 完成 = moon check + moon test + moon fmt + moon info 全过，然后 commit

## Errors Encountered
| Error | Attempt | Resolution |
|---|---|---|
