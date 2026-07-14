///|
/// The canonical example from the Go library's ESCAPING.md: fake markdown in
/// text gets escaped, real markdown from tags does not. The escaping is
/// asymmetric (the trailing `*` is followed by a space, so `IsItalicOrBold`
/// does not escape it) — this matches the Go implementation, confirmed by its
/// metadata golden file (`*not emphasized*` -> `\*not emphasized*`).
test "escape: fake vs real bold" {
  inspect(
    @html2md.convert("<p>fake **bold** and real <strong>bold</strong></p>"),
    content=(
      #|fake \*\*bold\** and real **bold**
    ),
  )
}

///|
test "escape: disabled mode keeps raw" {
  inspect(
    @html2md.convert(
      "<p>fake **bold** and real <strong>bold</strong></p>",
      escape_mode=Disabled,
    ),
    content=(
      #|fake **bold** and real **bold**
    ),
  )
}

///|
test "escape: atx header marker only when real" {
  // "# " at line start would become a heading -> escape
  inspect(
    @html2md.convert("<p># heading</p>"),
    content=(
      #|\# heading
    ),
  )
  // "#tag" is not a heading -> keep
  inspect(
    @html2md.convert("<p>#tag</p>"),
    content=(
      #|#tag
    ),
  )
}

///|
test "escape: list markers only at line start" {
  inspect(
    @html2md.convert("<p>- item</p>"),
    content=(
      #|\- item
    ),
  )
  inspect(
    @html2md.convert("<p>1. item</p>"),
    content=(
      #|1\. item
    ),
  )
  inspect(
    @html2md.convert("<p>2) item</p>"),
    content=(
      #|2\) item
    ),
  )
  // a hyphen mid-text is not a list marker
  inspect(
    @html2md.convert("<p>well-known</p>"),
    content=(
      #|well-known
    ),
  )
  // a number mid-text is not an ordered list
  inspect(
    @html2md.convert("<p>version 1.0</p>"),
    content=(
      #|version 1.0
    ),
  )
}

///|
test "escape: blockquote marker only at line start" {
  inspect(
    @html2md.convert("<p>&gt; quote</p>"),
    content=(
      #|&gt; quote
    ),
  )
  inspect(
    @html2md.convert("<p>a &gt; b</p>"),
    content=(
      #|a &gt; b
    ),
  )
}

///|
test "escape: divider" {
  inspect(
    @html2md.convert("<p>---</p>"),
    content=(
      #|\---
    ),
  )
  inspect(
    @html2md.convert("<p>a - b</p>"),
    content=(
      #|a - b
    ),
  )
}

///|
test "escape: brackets and bang" {
  inspect(
    @html2md.convert("<p>[link]</p>"),
    content=(
      #|\[link]
    ),
  )
  inspect(
    @html2md.convert("<p>![img]</p>"),
    content=(
      #|!\[img]
    ),
  )
  // a lone bracket without a closing one is not a link
  inspect(
    @html2md.convert("<p>a [ b</p>"),
    content=(
      #|a [ b
    ),
  )
}

///|
test "escape: backslash and backtick" {
  inspect(
    @html2md.convert("<p>a\\b</p>"),
    content=(
      #|a\\b
    ),
  )
  inspect(
    @html2md.convert("<p>use `code`</p>"),
    content=(
      #|use \`code\`
    ),
  )
}

///|
test "escape: heading ending with pound" {
  inspect(
    @html2md.convert("<h2>Heading #</h2>"),
    content=(
      #|## Heading \#
    ),
  )
}

///|
test "escape: setext underline in text" {
  // "text\n---" where --- underlines would be a setext heading
  inspect(
    @html2md.convert("<p>text<br>---</p>"),
    content=(
      #|text  
      #|\---
    ),
  )
}

///|
test "escape: internal marker characters round-trip as user content" {
  let content = "A\u{F000}B\u{0007}C\u{F002}D"
  inspect(@html2md.convert("<p>" + content + "</p>"), content~)
  inspect(
    @html2md.convert("<pre><code>" + content + "</code></pre>"),
    content="```\n" + content + "\n```",
  )
  inspect(
    @html2md.convert("<a href=\"/A\u{F002}B\" title=\"T\u{0007}\">x</a>"),
    content="[x](/A\u{F002}B \"T\u{0007}\")",
  )
}
