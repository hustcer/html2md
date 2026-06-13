///|
/// Smoke test: the html_parser dependency parses and exposes a usable DOM.
test "dependency smoke: parse html" {
  let doc = @parser.parse("<p>hello <b>world</b></p>", sanitize=false)
  let root = doc.root
  guard root.kind is Document
  // html5 semantics: html/head/body are implied
  inspect(root.children[0].name, content="html")
}
