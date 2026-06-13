// White-box ports of converter/escape_test.go (escapeContent / unEscapeContent).

///|
test "escape_content inserts a marker before markdown chars" {
  // '>' is a markdown char, so a marker is inserted before it.
  let out = escape_content("a>").to_array()
  inspect(out.length(), content="3")
  inspect(out[0], content="a")
  inspect(out[1] == MARKER_ESCAPING, content="true")
  inspect(out[2], content=">")
}

///|
test "escape_content is a no-op when disabled" {
  inspect(escape_content("a>*_", enabled=false), content="a>*_")
}

///|
test "unescape_content drops or keeps the marker per handler" {
  // A handler that only escapes '>'.
  let handlers : Array[UnEscaper] = [
    (chars, index) => if chars[index] == '>' { 1 } else { -1 },
  ]

  // marker + "ab": '>' handler does not match -> marker dropped.
  inspect(unescape_content("\u{0007}ab", handlers), content="ab")

  // marker + ">a": handler matches -> marker becomes backslash.
  inspect(unescape_content("\u{0007}>a", handlers), content="\\>a")
}

///|
test "unescape_content is a no-op when disabled" {
  inspect(
    unescape_content("\u{0007}>a", [], enabled=false),
    content="\u{0007}>a",
  )
}
