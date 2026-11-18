///|
/// Smoke test for the embedded parser's document root.
test "parser smoke: parse html" {
  let root = parse_dom("<p>hello <b>world</b></p>")
  assert_true(root.kind is Document)
  // html5 semantics: html/head/body are implied
  inspect(root.children[0].name, content="html")
}

///|
/// Baseline for later phases: how the parser structures a typical document.
test "parser smoke: dom shape" {
  let doc = parse_dom("<h1>Title</h1><p>a <strong>b</strong></p><!--note-->")
  inspect(
    @domext.dump(doc),
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
