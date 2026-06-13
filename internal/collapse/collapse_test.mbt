///|
fn run(html : String) -> String raise {
  let doc = @parser.parse(html, sanitize=false)
  @collapse.collapse(doc.root)
  @domext.dump(doc.root)
}

///|
test "collapse: basic example" {
  inspect(
    run("   <p>Foo   bar</p>  <p>Words</p> "),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        #text "Foo bar"
      #|      p
      #|        #text "Words"
      #|
    ),
  )
}

///|
test "collapse: without whitespace" {
  inspect(
    run("<p>Some<strong>Text</strong></p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        #text "Some"
      #|        strong
      #|          #text "Text"
      #|
    ),
  )
}

///|
test "collapse: with one space & space in paragraph" {
  inspect(
    run("<p>Some <strong> text. </strong></p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        #text "Some "
      #|        strong
      #|          #text "text."
      #|
    ),
  )
}

///|
test "collapse: with one space inside strong" {
  inspect(
    run("<p>Some<strong> text. </strong></p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        #text "Some"
      #|        strong
      #|          #text " text."
      #|
    ),
  )
}

///|
test "collapse: with three spaces" {
  inspect(
    run("<p>Some<strong>   text.   </strong></p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        #text "Some"
      #|        strong
      #|          #text " text."
      #|
    ),
  )
}

///|
test "collapse: with three spaces at beginning of paragraph" {
  inspect(
    run("<p><strong>   text.   </strong></p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        strong
      #|          #text "text."
      #|
    ),
  )
}

///|
test "collapse: with image between" {
  inspect(
    run(
      "<p><strong>  a  </strong><img src=\"/img.png\" /><strong>  b  </strong></p>",
    ),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        strong
      #|          #text "a "
      #|        img src="/img.png"
      #|        strong
      #|          #text " b"
      #|
    ),
  )
}

///|
test "collapse: spans with newline between each other" {
  inspect(
    run("<p>\n<span>(Text A)</span>\n<span>(Text B)</span>\n</p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        span
      #|          #text "(Text A)"
      #|        #text " "
      #|        span
      #|          #text "(Text B)"
      #|        #text ""
      #|
    ),
  )
}

///|
test "collapse: pre content untouched" {
  inspect(
    run("<pre>  keep\n   this  </pre><p>  collapse   me </p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      pre
      #|        #text "  keep\n   this  "
      #|      p
      #|        #text "collapse me"
      #|
    ),
  )
}

///|
test "collapse: code with space preserved" {
  inspect(
    run("<p><code> </code>aaa</p>"),
    content=(
      #|#document
      #|  html
      #|    head
      #|    body
      #|      p
      #|        code
      #|          #text " "
      #|        #text "aaa"
      #|
    ),
  )
}

///|
test "collapse: standalone element without children" {
  let strong = @dom.element("strong")
  @collapse.collapse(strong)
  inspect(
    @domext.dump(strong),
    content=(
      #|strong
      #|
    ),
  )
}

///|
test "collapse: code element as root keeps content" {
  let code = @dom.element("code", children=[@dom.text("  text  ")])
  @collapse.collapse(code)
  inspect(
    @domext.dump(code),
    content=(
      #|code
      #|  #text "  text  "
      #|
    ),
  )
}

///|
test "collapse: two text nodes in span" {
  let span = @dom.element("span", children=[
    @dom.text("  a  "),
    @dom.text("  b  "),
  ])
  @collapse.collapse(span)
  inspect(
    @domext.dump(span),
    content=(
      #|span
      #|  #text "a "
      #|  #text "b"
      #|
    ),
  )
}

///|
test "collapse: empty text node removed" {
  let body = @dom.element("body", children=[
    @dom.text(""),
    @dom.element("span", children=[@dom.text("Hello")]),
  ])
  @collapse.collapse(body)
  inspect(
    @domext.dump(body),
    content=(
      #|body
      #|  span
      #|    #text "Hello"
      #|
    ),
  )
}
