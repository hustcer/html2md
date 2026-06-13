///|
/// Convert an HTML string to CommonMark Markdown.
///
/// Mirrors `htmltomarkdown.ConvertString` of the Go library
/// JohannesKaufmann/html-to-markdown v2 (base + commonmark plugins).
pub fn convert(
  html : String,
  domain? : String = "",
  heading_style? : HeadingStyle = Atx,
  em_delimiter? : String = "*",
  strong_delimiter? : String = "**",
  horizontal_rule? : String = "* * *",
  bullet_list_marker? : String = "-",
  code_block_fence? : String = "```",
  escape_mode? : EscapeMode = Smart,
  link_empty_href_behavior? : LinkBehavior = Render,
  link_empty_content_behavior? : LinkBehavior = Render,
  list_end_comment? : Bool = true,
) -> String raise ConvertError {
  let doc = @parser.parse(html, sanitize=false) catch {
    err => raise ConvertError::ParseFailed("\{to_repr(err)}")
  }
  convert_dom(
    doc.root,
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
/// Convert an already parsed DOM tree (from `bobzhang/html_parser`) to
/// CommonMark Markdown.
///
/// Note: the tree is normalized **in place** during conversion (nodes may be
/// removed, merged or renamed). Pass a `clone_node(deep=true)` copy if the
/// tree must stay untouched.
pub fn convert_dom(
  doc : @dom.Node,
  domain? : String = "",
  heading_style? : HeadingStyle = Atx,
  em_delimiter? : String = "*",
  strong_delimiter? : String = "**",
  horizontal_rule? : String = "* * *",
  bullet_list_marker? : String = "-",
  code_block_fence? : String = "```",
  escape_mode? : EscapeMode = Smart,
  link_empty_href_behavior? : LinkBehavior = Render,
  link_empty_content_behavior? : LinkBehavior = Render,
  list_end_comment? : Bool = true,
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
