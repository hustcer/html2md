///|
/// Smoke test: the html_parser dependency parses and exposes a usable DOM.
test "dependency smoke: parse html" {
  let doc = @parser.parse("<p>hello <b>world</b></p>", sanitize=false)
  let root = doc.root
  guard root.kind is Document
  // html5 semantics: html/head/body are implied
  inspect(root.children[0].name, content="html")
}

///|
/// Baseline for later phases: how the parser structures a typical document.
test "dependency smoke: dom shape" {
  let doc = @parser.parse(
    "<h1>Title</h1><p>a <strong>b</strong></p><!--note-->",
    sanitize=false,
  )
  inspect(
    @domext.dump(doc.root),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      h1
      #|        #text "Title"
      #|      p
      #|        #text "a "
      #|        strong
      #|          #text "b"
      #|      #comment "note"
      #|
    ),
  )
}
