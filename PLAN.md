# html2md (MoonBit) 实现方案

> 参考库：[JohannesKaufmann/html-to-markdown v2](https://github.com/JohannesKaufmann/html-to-markdown)（Go）
> 目标：纯 MoonBit 库（无 CLI），将 HTML 转换为 CommonMark Markdown。

## 1. 参考库架构总结（移植规格）

Go 版的处理流水线分为四个阶段：

```
html.Parse → DOM 树
  ① Pre-Render   一组按优先级排序的 DOM 变换（删 script/style、合并相邻节点、空白折叠……）
  ② Render       递归渲染：#text → TextTransformer 链；元素 → Renderer 链（返回 Success/TryNext）；
                 无人处理 → fallback（block 则前后写 "\n\n"，递归渲染子节点）
  ③ Post-Render  对最终字节流做收尾（TrimSpace、压缩连续换行、反转义、还原代码块换行标记）
```

关键机制：

- **TagType**：`block | inline | remove`。`remove` 在 Pre-Render 早期整棵删除（#comment/head/script/style/link/meta/iframe/noscript/input/textarea）；未注册的标签按内置 block/inline 名单兜底。
- **空白折叠**（collapse 包，移植自 turndown）：把 `\r\n\t ` 折叠为单个空格；block/br 边界处剪掉首尾空格；`pre`、void 元素、`code` 周围保留空格；游标式遍历（nextNode/removeNode）。
- **智能转义**（marker 机制）：文本阶段在每个 Markdown 特殊字符（`\ * _ - + . > | $ # = [ ] ( ) ! ~ ` " '`）前插入占位符 `\a`(0x07)；Post-Render 阶段由一组 UnEscaper（IsItalicOrBold/IsStrikethrough/IsBlockQuote/IsAtxHeader/IsSetextHeader/IsDivider/IsOrderedList/IsUnorderedList/IsImageOrLink/IsFencedCode/IsInlineCode/IsBackslash）按上下文判断该字符是否真的会被解析成 Markdown 语法——是则把占位符替换为 `\`，否则删除占位符。
- **代码块换行标记**：`pre` 内容的 `\n` 临时替换为 ``，防止被“压缩连续换行”破坏，Post-Render 最后还原；列表项缩进时该标记后还要补缩进。
- **commonmark 渲染规则**（默认配置）：
  - 标题：ATX（默认）`# …`，行内换行压成空格、多空格合一、结尾 `#` 强制转义；Setext（h1/h2）下划线宽度=内容最宽行（按 rune 数、忽略 marker，最小 3）。
  - 粗斜体：`**`/`*`（可配 `__`/`_`），内容多行时每行都加定界符（DelimiterForEveryLine）。
  - 删除线（GFM）：`s`/`del`/`strike` 渲染为 `~~...~~`，普通文本中的 `~~` 通过智能转义避免误解析。
  - 链接：inlined 风格 `[text](href "title")`；href 经 TrimSpace + AssembleAbsoluteURL（相对路径用 domain 拼绝对 URL、查询参数重编码、空格→%20、`[]()<>` 百分号转义）；内容两侧空白外移（SurroundingSpaces）；多行内容 EscapeMultiLine；`is_inside_link` 上下文里 `]` 强制转义；空 href/空内容行为可配（Render/Skip）。
  - 图片：`![alt](src "title")`，alt 中 `[]` 手动转义，src 为空则 TryNext。
  - 表格（GFM）：`table/thead/tbody/tfoot/tr/th/td` 渲染为 pipe table；单元格内容压成单行并转义 `|`；无显式表头时首行作为 GFM header。
  - 列表：先渲染每个 li 到缓冲并 TrimSpace；ol 支持 `start` 属性，序号按最大宽度补零（`01.`）；缩进=前缀 rune 宽度；多行项逐行缩进，且对 `` 标记追加缩进；li 渲染时在列表层做 UnEscape。
  - 代码：行内 code 动态计算反引号数（最长连续 +1），首尾是反引号时补空格，内容折叠换行（CollapseInlineCodeContent）；pre 块用围栏（最长连续围栏字符 +1，最小 3），语言从 `class="language-xxx|lang-xxx"` 提取，内容换行替换为 ``。
  - blockquote：内容 Trim 后逐行加 `> ` 前缀（PrefixLines）。
  - hr：`* * *`；br：`"  \n"`（硬换行）。
  - 列表结束注释：相邻两个列表之间插入 `<!--THE END-->` 注释，防止两个列表被解析为一个（可关）。
- **Pre-Render DOM 变换**（commonmark + base）：
  - RenameFakeSpans：`display:inline` 的 div 改名为 span。
  - RemoveRedundant（嵌套同类 bold/italic、嵌套 a 去内层）、MergeAdjacent（相邻同类 strong/em、code 合并）、MergeAdjacentTextNodes。
  - RemoveEmptyCode、SwapTags（code⊃pre 交换为 pre⊃code；strong⊃a 交换为 a⊃strong；a⊃h2 交换为 h2⊃a）。
  - AddSpace：`A<strong>B</strong>` 边界缺空格时补（针对 bold/italic/code）。
  - LeafBlockAlternatives：标题/段落等 leaf block 里的 block 子元素降级处理。
  - MoveListItems：游离 li 包进 ul；ul 直接嵌 ul 时挂到前一个 li 下。
  - AddListEndComments（PriorityLate+100，在 collapse 之后）。
- **base 插件**其余职责：TextTransformer 把 `<`→`&lt;`、`>`→`&gt;`（不转 `&`），然后做 marker 转义；Post-Render Trim + 压缩 `\n{3,}`→`\n\n` + TrimUnnecessaryHardLineBreaks + 反转义。
- **错误**：未注册渲染器/只注册 commonmark 没注册 base 时报错（MoonBit 版流水线固定，不需要）。配置校验（validation.go）：非法定界符/围栏/列表符号报错。
- **扩展插件**：table（GFM 表格）与 strikethrough（`~~`）已作为固定流水线内置渲染器完成；Renderer 自定义钩子留作后续版本。

## 2. MoonBit 版总体设计

### 2.1 设计取舍（与 Go 版的差异）

| Go 版                               | MoonBit 版                                                               | 理由                                                                                                                                                                                                        |
| ----------------------------------- | ------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 运行时插件注册 + 优先级排序         | **固定流水线**（base+commonmark 内置），保留少量函数钩子位               | 99% 用法就是 base+commonmark；MoonBit 倾向静态、简单 API；v2 可再开放 Renderer 钩子                                                                                                                         |
| `x/net/html` 全规格解析器           | 引入 **`bobzhang/html_parser`**（仅依赖其 `parser`/`dom`/`core` 三个包） | JustHTML 的规格级移植，带 html5lib 一致性测试、完整实体表、adoption agency；与 x/net/html 同为 HTML5 语义（含 html/head/body 隐式补全），与 Go 参考行为对齐度反而更高；自研方案（~950 行 + 实体表）整体砍掉 |
| `[]byte` 处理                       | UTF-16 `String`/`StringView` + `StringBuilder`                           | marker 选用 BMP 单码元字符（`''`、`''`），逻辑等价                                                                                                                                                         |
| options struct + functional options | **标签化可选参数**（labeled optional params）                            | MoonBit 惯用法（skill 明确反对 options struct）                                                                                                                                                             |
| `net/url` 解析                      | 内置极简 URL 处理（scheme 识别、相对路径拼接、百分号转义、查询重编码）   | 够用即可，行为对齐 Go 版 defaultAssembleAbsoluteURL                                                                                                                                                         |
| 返回 `([]byte, error)`              | `-> String raise ConvertError`                                           | MoonBit 受检错误                                                                                                                                                                                            |

### 2.2 模块与包布局

模块名：`hustcer/html2md`；依赖：`moon add bobzhang/html_parser@0.1.7`（锁版本）。`preferred-target` 不限定——该依赖的 async 只被其 `cmd/*` CLI 包引用，库本体（`parser`/`dom`/`core`）不沾 async，三后端理论通吃（P0 用 `moon check --target all` 冒烟验证）。

```
html2md/
├── moon.mod                        # import bobzhang/html_parser
├── PLAN.md
├── README.mbt.md → README.md      # 文档即测试
├── moon.pkg                        # 门面包 @html2md
├── html2md.mbt                     # pub convert / convert_dom；选项枚举 HeadingStyle/EscapeMode/LinkBehavior
├── options.mbt                     # 内部 Options 汇总（私有 struct，由 convert 的标签参数填充）+ 校验
├── render.mbt                      # 渲染引擎：render_node 分派、fallback、文本管线
├── render_heading.mbt / render_emphasis.mbt / render_strikethrough.mbt
├── render_link.mbt / render_image.mbt / render_table.mbt
├── render_list.mbt / render_code.mbt / render_blockquote.mbt / render_misc.mbt(hr/br/comment)
├── ctx.mbt                         # RenderCtx：options + domain + is_inside_link 等（不可变，{..ctx, ...} 派生）
├── url.mbt                         # assemble_absolute_url + 查询重编码
└── internal/
    ├── domext/                     # @html_parser/dom 适配层：遍历游标(next/prev sibling 语义)、
    │                               # rename/set_text 等"替换式"变更助手、is_block/is_inline/is_void 名单、attr 取值
    ├── collapse/                   # 空白折叠（turndown 算法移植，基于 domext 游标）
    ├── textutils/                  # trim_consecutive_newlines / prefix_lines / delimiter_for_every_line /
    │                               # calculate_code_fence / collapse_inline_code / escape_multiline /
    │                               # surrounding_spaces / surround_by_quotes / trim_hard_line_breaks
    ├── domutils/                   # merge_adjacent(_text_nodes) / remove_redundant / remove_empty_code /
    │                               # swap_tags / add_space / rename_fake_spans / leaf_block_alternatives /
    │                               # move_list_items / add_list_end_comments
    └── escape/                     # marker 常量 + escape_content + 11 个 un-escaper + unescape_content
```

要点（遵循 MoonBit 包组织规范）：

- DOM 类型直接复用依赖的 `@html_parser/dom.Node`（`pub(all)` struct：`kind/name/attrs/data/children + mut parent`，带 `append_child/insert_before/remove_child/replace_child/clone_node`）。两个适配点（在 `internal/domext` 解决）：
  1. 它是 **children 数组型** DOM（非兄弟链表），collapse/domutils 里的 `next_sibling` 游标遍历改为"父节点 + 下标"游标；
  2. `name`/`data` 字段不可变 → RenameFakeSpans、文本合并等就地改名/改文改为**节点替换**（构造新节点 + `replace_child`），封装成 `rename(node, new_name)`、`set_text(node, s)` 助手。
- 公共 API 面收窄：门面只暴露 `convert`（输入 `String`）与 `convert_dom`（输入 `@html_parser/dom.Node`，供已解析场景复用）；解析由依赖完成（`@parser.parse(html, sanitize=false)` 默认即不消毒，`ParsedHtml.root` 取根）。不再自建 dom/parser 公开包。
- `internal/*` 只放实现支撑（适配层、转义、折叠、文本工具、DOM 变换），不暴露公共类型。

### 2.3 公共 API 草图

````moonbit
pub(all) enum HeadingStyle { Atx; Setext }
pub(all) enum EscapeMode { Smart; Disabled }
pub(all) enum LinkBehavior { Render; Skip }

pub(all) suberror ConvertError {
  InvalidConfig(String)
} derive(Debug)

///| 一步到位：解析 + 转换
pub fn convert(
  html : String,
  domain? : String,                          // 相对链接补全
  heading_style? : HeadingStyle = Atx,
  em_delimiter? : String = "*",              // "*" | "_"
  strong_delimiter? : String = "**",         // "**" | "__"
  horizontal_rule? : String = "* * *",
  bullet_list_marker? : String = "-",        // "-" | "+" | "*"
  code_block_fence? : String = "```",        // "```" | "~~~"
  escape_mode? : EscapeMode = Smart,
  link_empty_href_behavior? : LinkBehavior = Render,
  link_empty_content_behavior? : LinkBehavior = Render,
  list_end_comment? : Bool = true,
) -> String raise ConvertError

///| 已有 DOM 时复用（与 Go 版 ConvertNode 对应；Node 为 @html_parser/dom 的类型）
pub fn convert_dom(doc : @dom.Node, ...同上...) -> String raise ConvertError
````

### 2.4 渲染引擎（固定流水线）

```
convert(html, ...) =
  校验配置（对齐 validation.go：定界符/围栏/列表符号合法性）
  doc = @parser.parse(html, sanitize=false).root   // bobzhang/html_parser
  ① pre-render（固定顺序，对齐 Go 版优先级序）：
     remove_tags → merge_adjacent_text_nodes → rename_fake_spans →
     remove_redundant(bold/italic, link) → merge_adjacent(bold/italic, code) →
     remove_empty_code → swap_tags(code/pre, bold/link, link/heading) →
     add_space → leaf_block_alternatives → move_list_items →
     collapse_whitespace → add_list_end_comments
  ② render：render_node(ctx, sb, doc)
     - Text  → "<"/">" 实体化 → escape_content(插 marker) → is_inside_link 时 "]" 强制转义
     - Element → match 标签名分派到各 render_*；未命中 → fallback(block 写 \n\n + 子节点)
  ③ post-render：trim → trim_consecutive_newlines → trim_hard_line_breaks →
     unescape_content(11 个 un-escaper) → 替换 '' 为 '\n'
```

`RenderCtx` 为不可变 struct（options + domain + is_inside_link），需要变体时 `{ ..ctx, is_inside_link: true }`；Go 版 ctx.Value 的动态状态全部静态化。Writer 直接用 `StringBuilder`。

### 2.5 为什么不直接用 `bobzhang/html_parser` 自带的 `to_markdown`

该依赖自带一个 `@markdown.to_markdown(node, html_passthrough?)`（约 900 行），定位是"够用的基础转换"，与本项目目标差距明显，故只复用其解析器，转换管线完全自建：

| 能力       | html_parser 的 to_markdown                                                 | 本项目（对齐 Go html-to-markdown v2）                                                                  |
| ---------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 图片 `img` | 原样输出 HTML                                                              | `![alt](src "title")` + alt 转义 + URL 处理                                                            |
| 表格       | 原样输出 HTML                                                              | GFM pipe table（P7 已实现）                                                                            |
| 转义       | 全文盲转 `\ ` \* \_ [ ]`，且 `&`→`&amp;`（过度转义）；仅行首少量上下文判断 | marker + 11 个上下文 un-escaper 的智能转义                                                             |
| 配置       | 无任何选项                                                                 | 标题风格/定界符/围栏/列表符号/链接行为/escape_mode/domain 等十余项                                     |
| DOM 规范化 | 无                                                                         | 合并相邻 strong/em/code、code⊃pre 交换、补边界空格、游离 li 收容、列表结束注释等十余个 pre-render 变换 |
| 细节保真   | br→单换行、hr 固定 `---`、无 setext、无 ol start/序号补零                  | 硬换行 `"  \n"`、动态围栏长度、`` 机制、序号补零、相对 URL 补全…                                       |

### 2.6 测试策略

- 全程快照测试：`inspect(@html2md.convert(...), content=...)` + `moon test --update`。
- 用例来源：
  1. 移植 Go 版 `convert_test.go`、`commonmark_test.go`、`collapse_test.go`、`escape_test.go`、各 `textutils/domutils` 单测的代表性用例；
  2. `README.mbt.md` 中的文档用例（既是文档又是测试）;
  3. 每个 internal 包配独立 `*_test.mbt`（黑盒为主，collapse/escape 需要白盒时用 `_wbtest.mbt`）。
- 交叉验证（可选）：写个一次性脚本跑 Go 版生成 golden 输出，与 MoonBit 版 diff。
- 验证闭环：`moon check`（含 `--warn-list +unnecessary_annotation`）→ `moon test` → `moon fmt` → `moon info`（review `pkg.generated.mbti`）。

## 3. 实施阶段

| 阶段               | 内容                                                                                            | 验收                                   |
| ------------------ | ----------------------------------------------------------------------------------------------- | -------------------------------------- |
| P0 脚手架          | moon.mod/包结构/spec.mbt（declare 公共 API）/`moon add bobzhang/html_parser@0.1.7` + 三后端冒烟 | `moon check --target all` 通过         |
| P1 DOM 适配层      | internal/domext：游标遍历、rename/set_text 替换助手、block/inline/void 名单、解析冒烟测试       | 适配层单测 + DOM 结构 dump 快照        |
| P2 文本工具 + 折叠 | textutils、collapse                                                                             | 移植对应 Go 单测                       |
| P3 引擎 + 基础行为 | render 骨架、fallback、remove、文本管线、post-render                                            | 简单段落/嵌套 div 端到端               |
| P4 commonmark 渲染 | heading/emphasis/link/image/list/code/blockquote/hr/br + domutils 全部变换                      | 移植 commonmark_test 用例              |
| P5 智能转义        | marker + 11 个 un-escaper + EscapeMode                                                          | 移植 escape 用例（`fake **bold**` 等） |
| P6 收尾            | url.mbt、配置校验、README.mbt.md、`moon info` 固化 .mbti                                        | 全量 `moon test` 绿                    |
| P7 扩展            | table（GFM）、strikethrough                                                | `moon test gfm_p7_test.mbt --target all` |
| P8 可选            | Renderer 自定义钩子、插件子包                                              | 后续版本设计                             |

工作量预估（源码行数，不含测试）：domext ~250、collapse ~150、textutils ~350、domutils ~450、escape ~450、渲染器 ~650、门面/选项/url ~300，合计约 2600 行（引入解析器依赖后较自研方案省约 950 行 + 实体表）；测试约 1200+ 行。

## 4. 风险与对策

1. **依赖风险（bobzhang/html_parser 0.1.x）**：API 仍可能变动 → 锁定 `@0.1.7`；升级时 diff 其 `pkg.generated.mbti`；适配面收敛在 `internal/domext` 一个包里，必要时可换回自研解析器而不动渲染管线。`convert_dom` 公开签名暴露了依赖的 `Node` 类型，文档中注明。
2. **children 数组型 DOM 与 Go 兄弟链表语义差异**：collapse/domutils 的游标遍历、边遍历边删改节点的逻辑需在 domext 游标上重新推演 → 对照 Go 版 collapse_test（632 行）逐用例移植验证。
3. **UTF-16 与字节语义差异**：Go 版按字节扫描、marker 是单字节 → MoonBit 按 UTF-16 码元扫描，marker 用单码元字符，逐函数对照单测保证等价；代理对用 `get_char`/迭代器处理。
4. **URL 处理简化**：当前已覆盖相对路径、query-only reference、fragment 与 dot-segment normalization；仍未完整实现 Go 版查询参数重编码，用 url_test.go 用例约束。
5. **列表/转义是细节重灾区**：序号补零、缩进、`` 缩进追加、列表层 UnEscape 时机等，严格按 Go 源码逐行移植并配快照测试。
