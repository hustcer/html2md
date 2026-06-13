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
- 8 个 commonmark golden 文件 → golden_{blockquote,bold,code,heading,image,link,list,metadata}_test.mbt（按注释拆片段，逐字节对照 .out.md）
- url_test 全量结构性用例 + option-func + validation + Windows CR + Example → url_test/options_test/convert_basic_test
- 跳过（有原因）：converter 插件注册/优先级/ctx 机制测试、base/renderers 扩展 API、DataRace、strikethrough/table（P7）、cli
- 223/223 三后端全绿
