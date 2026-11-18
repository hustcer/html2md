///|
/// Convert an HTML string to CommonMark Markdown.
///
/// Mirrors `htmltomarkdown.ConvertString` of the Go library
/// JohannesKaufmann/html-to-markdown v2 (base + commonmark plugins).
///
/// # Example
/// ```mbt check
/// test {
///   inspect(
///     @html2md.convert("<h1>Title</h1><p>Some <b>bold</b> text.</p>"),
///     content=(
///       #|# Title
///       #|
///       #|Some **bold** text.
///     ),
///   )
/// }
/// ```
pub fn convert(
  html : String,
  domain~ : String = "",
  heading_style~ : HeadingStyle = Atx,
  em_delimiter~ : String = "*",
  strong_delimiter~ : String = "**",
  horizontal_rule~ : String = "* * *",
  bullet_list_marker~ : String = "-",
  code_block_fence~ : String = "```",
  escape_mode~ : EscapeMode = Smart,
  link_empty_href_behavior~ : LinkBehavior = Render,
  link_empty_content_behavior~ : LinkBehavior = Render,
  list_end_comment~ : Bool = true,
) -> String raise ConvertError {
  convert_dom(
    parse_dom(html),
    domain~,
    heading_style~,
    em_delimiter~,
    strong_delimiter~,
    horizontal_rule~,
    bullet_list_marker~,
    code_block_fence~,
    escape_mode~,
    link_empty_href_behavior~,
    link_empty_content_behavior~,
    list_end_comment~,
  )
}

///|
/// Parse an HTML string into a mutable document node for `convert_dom`.
///
/// The parser adds implied `html`, `head`, and `body` elements and applies
/// HTML error recovery.
///
/// ```mbt check
/// test {
///   let doc = @html2md.parse_dom("<p>Hello <em>MoonBit</em></p>")
///   inspect(@html2md.convert_dom(doc), content="Hello *MoonBit*")
/// }
/// ```
pub fn parse_dom(html : StringView) -> @dom.Node raise ConvertError {
  let parsed = @parser.parse(html) catch {
    err => raise ParseFailed("\{Repr(err)}")
  }
  parsed.root
}

///|
/// Convert a node from `hustcer/html2md/dom` to CommonMark Markdown.
///
/// Note: the tree is normalized **in place** during conversion (nodes may be
/// removed, merged or renamed). Pass a `clone_node(deep=true)` copy if the
/// tree must stay untouched.
pub fn convert_dom(
  doc : @dom.Node,
  domain~ : String = "",
  heading_style~ : HeadingStyle = Atx,
  em_delimiter~ : String = "*",
  strong_delimiter~ : String = "**",
  horizontal_rule~ : String = "* * *",
  bullet_list_marker~ : String = "-",
  code_block_fence~ : String = "```",
  escape_mode~ : EscapeMode = Smart,
  link_empty_href_behavior~ : LinkBehavior = Render,
  link_empty_content_behavior~ : LinkBehavior = Render,
  list_end_comment~ : Bool = true,
) -> String raise ConvertError {
  let options = Options::build(
    domain~,
    heading_style~,
    em_delimiter~,
    strong_delimiter~,
    horizontal_rule~,
    bullet_list_marker~,
    code_block_fence~,
    escape_mode~,
    link_empty_href_behavior~,
    link_empty_content_behavior~,
    list_end_comment~,
  )
  run_pipeline(doc, options)
}
