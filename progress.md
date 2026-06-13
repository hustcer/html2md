# Progress Log

## Session 2026-06-13

- 方案设计完成（PLAN.md），用户确认；决定引入 bobzhang/html_parser@0.1.7
- P0 开始：脚手架 + 依赖 + spec
- P0 完成并提交 7573005：脚手架 + 依赖 + 选项校验 + 冒烟（moon check --target all 全过）
- P1 完成并提交 bedb91a：internal/domext（6 测试）+ DOM shape 基线快照，8/8 绿
- P2 开始：textutils + collapse
- P2 完成并提交：textutils（9 测试）+ collapse（14 测试），31/31 绿
- P3 开始：渲染引擎骨架
- P4 完成并提交 0e42a7a：全部 commonmark 渲染器 + 9 个 domutils 变换 + url.mbt + 完整管线，53/53 绿；快照逐条对照 Go 预期吻合（补零序号/域名拼接/动态反引号/列表结束注释）
- P5 开始：智能转义 11 个 un-escaper
- P5 完成并提交 1044136：11 个 un-escaper（char 空间）+ 注册 + 10 转义测试，63/63 绿；非对称转义经 metadata golden 坐实
- P6 开始：url 测试、配置校验对齐、README.mbt.md、moon info 固化
- P6 完成并提交 006c12c：配置校验对齐 Go、url_test、domutils 单测、README.mbt.md（文档即测试）、清零警告（含 warning 73），三后端各 83/83 绿
- P0~P6 全部完成 ✅

## Test migration pass (后续)

- 用户要求核查所有 Go 测试用例迁移情况
- escape elem 单元测试 → elems_test.mbt（11 un-escaper, char 空间）
- escape util/escapeContent/unEscapeContent → util_wbtest.mbt + escape_wbtest.mbt
- textutils 全量子用例 → textutils_test.mbt
- collapse whitespace_test → whitespace_wbtest.mbt
- domutils 8 变换全量 → domutils_test.mbt（手写期望树对照 Go tester）
- 8 个 commonmark golden 文件 → golden\_{blockquote,bold,code,heading,image,link,list,metadata}\_test.mbt（按注释拆片段，逐字节对照 .out.md）
- url_test 全量结构性用例 + option-func + validation + Windows CR + Example → url_test/options_test/convert_basic_test
- 跳过（有原因）：converter 插件注册/优先级/ctx 机制测试、base/renderers 扩展 API、DataRace、strikethrough/table（P7）、cli
- 223/223 三后端全绿

## P7 session (GFM table + strikethrough)

- 用户要求先完成 P7 的 GFM table 与 strikethrough `~~`，再更新 PLAN.md，并继续使用 planning-with-files。
- 已恢复规划上下文：P0-P6 完成，P7 原先作为可选项跳过。
- 当前计划：先实现 strikethrough 固定渲染器，再实现 GFM table 固定渲染器，补黑盒测试和 README/PLAN，同步 `moon fmt/check/test/info` 验证。
- 已实现固定渲染器：`render_strikethrough.mbt` 处理 `s/del/strike`，`render_table.mbt` 处理 GFM pipe table；普通文本 `~~` 加入智能转义。
- 已新增 `gfm_p7_test.mbt`，覆盖删除线、假删除线文本、thead/tbody 表格、tbody-only 表格、行内内容和 `|` 转义；`moon test gfm_p7_test.mbt --target all` 四后端 5/5 通过。
- 已更新 README.mbt.md 和 PLAN.md：P7 table/strikethrough 标记为已内置支持，Renderer hooks 移到后续 P8。
- 验证完成：`moon fmt`、`moon check --target all --diagnostic-limit 200`、`moon test --target all`（四后端 231/231 通过）、`moon info`。
- `planning-with-files` 的 `check-complete.sh` 对当前 legacy markdown 表格未识别出 phases，输出 `0/0 phases complete`；已人工核对 `task_plan.md` 中 P7a-P7d 均为 complete。

## URL query re-encoding session

- 用户要求补齐 URL 查询参数重编码，并明确以标准规范和行业共识为准，不盲目对齐 Go 版。
- 采用 RFC 3986 query 组件规则：保留 unreserved/sub-delims/`:`/`@`/`/`/`?` 和合法 `%HH`，空格编码为 `%20`，Unicode 使用 UTF-8 百分号编码，非法 `%` 编为 `%25`，`+` 不当作空格。
- 已实现 `url.mbt` query 组件标准化，并新增 `url_test.mbt` 覆盖普通 URL、query-only reference、Unicode、非法 `%`、合法 `%HH` 与 `mailto` query。
- 验证完成：`moon fmt`、`moon test url_test.mbt --target all`、`moon check --target all --diagnostic-limit 200`、`moon test --target all`（四后端 234/234 通过）、`moon info`、`git diff --check`。

## Test migration audit pass

- 用户要求检查 `/Users/hustcer/iWork/refs/html-to-markdown` 中未迁测试，并把可以迁的都迁过来。
- 已补迁 Go strikethrough 插件基础和 golden 行为：内部 `~~` 转义、嵌套/相邻删除线、`~`/`*` 普通文本；同时补齐 strikethrough pre-render 的 redundant/adjacent DOM 处理。
- 已补迁 Go commonmark italic 专项中未明显覆盖的小用例：相邻 italic、嵌套 italic、空 italic、NBSP、zero-width-space。
- 已补迁 Go table 默认行为中无需新增公共 option API 的用例：空单元、caption fallback、inline/block cell、align 属性、简单 colspan/rowspan 空占位、presentation table fallback、可工作的父容器场景。
- 仍不可迁：CLI 测试、converter 动态插件/注册/优先级/ctx 测试、base RenderAsHTML 扩展 API 测试、DataRace、Go table 插件 option API（skip empty rows/header promotion/cell padding/newline behavior/span mirror 等可配置项）、strikethrough 自定义 delimiter option。
