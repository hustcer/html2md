# Findings

## 参考库（Go html-to-markdown v2）关键事实
- 四阶段管线：Parse → PreRender(DOM 变换) → Render(递归) → PostRender(文本收尾)
- marker：转义占位 0x07（单字节）；代码块换行 U+F002
- EscapedChar 集合：`\ * _ - + . > | $ # = [ ] ( ) ! ~ ` " '`
- base 插件：remove 标签集 {#comment, head, script, style, link, meta, iframe, noscript, input, textarea}；TextTransformer：`<`→`&lt;` `>`→`&gt;`（不转 &）→ escape_content；PostRender：TrimSpace → TrimConsecutiveNewlines → TrimUnnecessaryHardLineBreaks → UnEscape(优先级+20)
- commonmark PreRender 顺序（handle_pre_render.go）：RenameFakeSpans → RemoveRedundant(bold/italic) → MergeAdjacent(bold/italic) → RemoveEmptyCode → SwapTags(code,pre) → MergeAdjacent(code) → AddSpace(bold/italic,code) → RemoveRedundant(link) → SwapTags(bold/italic,link) → SwapTags(link,heading) → LeafBlockAlternatives → MoveListItems；AddListEndComments 在 collapse 之后（PriorityLate+100）
- 总体 PreRender 顺序：remove(PriorityEarly=base.preRenderRemove+MergeAdjacentTextNodes) → commonmark.handlePreRender(Standard) → collapse(PriorityLate) → AddListEndComments(Late+100)
- heading：ATX 内容换行→空格、多空格合一、TrimSpace、结尾#强制转义(s[len-2]='\\' 覆盖占位符)；Setext level<3：TrimConsecutiveNewlines+EscapeMultiLine，宽度=最宽行 rune 数(忽略 marker，min 3)
- list：li 渲染→TrimSpace→跳过空项；前缀 ul: marker+" "，ol: start+i 按最大序号宽度 %0Nd. 补零；indent=前缀 rune 宽度；item 做 TrimConsecutiveNewlines+TrimUnnecessaryHardLineBreaks+UnEscapeContent；多行项除首行外加 indent，U+F002 后追加 indent
- inline code：fenceChar='`'；全空内容直接 `content`;否则 CollapseInlineCodeContent；fence=最长连续+1；首/尾是 ` 则补空格
- pre：getCodeWithoutTags(text 拼接，br/div→\n，跳过 style/script/textarea，info 取第一个 code/pre 的 class language-/lang-)；尾 \n 去掉；fence=CalculateCodeFence(最长连续+1，min 3)；\n→U+F002
- link：href trim + AssembleAbsoluteURL；空 href 且 Skip→TryNext；title 换行→空格；内容空白外移；TrimConsecutiveNewlines+EscapeMultiLine；href=="" 时 title 置空；is_inside_link ctx 中 text 的 marker+']' → '\]'
- image：src 空→TryNext；alt/title 换行→空格；alt 的 [] 加 \（若前面无 \）
- blockquote：TrimSpace→空则成功返回；TrimConsecutiveNewlines+TrimUnnecessaryHardLineBreaks→PrefixLines("> ")→\n\n 包裹
- br→"  \n"；hr→"\n\n* * *\n\n"
- collapse 算法：见 collapse.go 移植注释（prevText/keepLeadingWs 游标机）
- URL：`#` 直返；\n→%0A \t→%09；data: URI 只做 percentEncodingReplacer（空格[]()<> → %20 %5B %5D %28 %29 %3C %3E）；查询按 & 分段、各段 k/v QueryUnescape→QueryEscape、+→%20；有 domain 时 ResolveReference
- 空文档：Go 版 html.Parse 永不失败，空输入产出空输出（无错误）；NewConverter 校验错误在 ConvertNode 时返回

## 依赖（bobzhang/html_parser@0.1.7）
- `@parser.parse(html, sanitize=false) -> ParsedHtml raise @core.HtmlError`；`ParsedHtml.root : @dom.Node`（pub 字段）
- `@dom.Node`：pub(all) struct {kind, name, ns, attrs: Map[String,String?], data, children: Array[Node], mut parent, ...}；方法 append_child/insert_before/remove_child/replace_child/clone_node/text()
- NodeKind: Document|Fragment|Element|Text|Comment|Doctype
- name/data/attrs 字段不可变（attrs Map 本身可变 set）；children 是 Array 可变
- async 依赖只在其 cmd/* 包；库本体不沾
- 其 to_markdown 不复用（img/table 直出 HTML、盲转义、零配置）

## MoonBit 注意事项
- 字符串 UTF-16；s[i] 是 UInt16 码元；get_char(i) 安全
- 测试用 inspect + moon test --update
- moon.pkg 新格式（import {...} / options(...)）

## P7 设计约束
- strikethrough 先作为固定 commonmark/GFM 渲染器加入，不开放 Go 版插件注册机制；目标标签覆盖 `s`、`del`、`strike`。
- table 先输出 GFM pipe table：header 行、delimiter 行、body 行；单元格内容复用现有 inline 渲染后压成单行，并转义 pipe。
- table 不在 P7 内实现 alignment/colspan/rowspan 的完整 HTML 表格模型；复杂表格优先保持可读 Markdown，不引入公共 API。
- `bobzhang/html_parser` 会把裸 `<table><tr>...` 规范化为 `table > tbody > tr`，table 行收集需要递归穿过 `thead/tbody/tfoot`。
