///|
test "convert: simple paragraph" {
  inspect(@html2md.convert("<p>hello world</p>"), content="hello world")
}

///|
test "convert: two paragraphs" {
  inspect(@html2md.convert("<p>a</p><p>b</p>"), content="a\n\nb")
}

///|
test "convert: empty input" {
  inspect(@html2md.convert(""), content="")
}

///|
test "convert: script/style/head removed" {
  inspect(
    @html2md.convert(
      "<head><title>t</title></head><script>x=1</script><style>.a{}</style><p>kept</p>",
    ),
    content="kept",
  )
}

///|
test "convert: comments removed" {
  inspect(@html2md.convert("<p>a<!-- hidden -->b</p>"), content="ab")
}

///|
test "convert: nested blocks" {
  inspect(
    @html2md.convert("<div><div>inner</div>after</div>"),
    content="inner\n\nafter",
  )
}

///|
test "convert: unknown inline tag falls through" {
  inspect(@html2md.convert("<p>a <abbr>HTML</abbr> b</p>"), content="a HTML b")
}

///|
test "convert: whitespace collapsed" {
  inspect(
    @html2md.convert("<p>Some\n  text   here</p>"),
    content="Some text here",
  )
}

///|
test "convert: angle brackets entity-escaped" {
  inspect(@html2md.convert("<p>1 &lt; 2 &gt; 0</p>"), content="1 &lt; 2 &gt; 0")
}

///|
test "convert: invalid option raises" {
  try @html2md.convert("<p>x</p>", em_delimiter="!") catch {
    InvalidConfig(msg) =>
      inspect(
        msg,
        content="invalid em_delimiter \"!\": must be exactly 1 character of \"*\" or \"_\"",
      )
    _ => fail("unexpected error kind")
  } noraise {
    _ => fail("expected to fail")
  }
}
