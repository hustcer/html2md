// End-to-end cases ported from testdata/GoldenFiles/blockquote.{in.html,out.md}.

///|
test "golden blockquote: simple" {
  inspect(
    @html2md.convert(
      "<blockquote>\nFirst Line\nSecond Line\nThird Line\n</blockquote>",
    ),
    content=(
      #|> First Line Second Line Third Line
    ),
  )
}

///|
test "golden blockquote: empty variants produce nothing" {
  inspect(@html2md.convert("<blockquote></blockquote>"), content="")
  inspect(@html2md.convert("<blockquote> </blockquote>"), content="")
  inspect(@html2md.convert("<blockquote>  </blockquote>"), content="")
  inspect(@html2md.convert("<blockquote>\n\n</blockquote>"), content="")
}

///|
test "golden blockquote: with one break" {
  inspect(
    @html2md.convert("<blockquote>Line A<br />Line B</blockquote>"),
    content=(
      #|> Line A  
      #|> Line B
    ),
  )
}

///|
test "golden blockquote: with multiple breaks" {
  inspect(
    @html2md.convert(
      "<blockquote><p>Start Line</p><br /><br /><br /><span> </span><br /><br /><br /><p>End Line</p></blockquote>",
    ),
    content=(
      #|> Start Line
      #|> 
      #|> End Line
    ),
  )
  inspect(
    @html2md.convert(
      "<blockquote><p>Start Line<br /><br /><br /><span> </span><br /><br /><br />End Line</p></blockquote>",
    ),
    content=(
      #|> Start Line
      #|> 
      #|> End Line
    ),
  )
}

///|
test "golden blockquote: large" {
  inspect(
    @html2md.convert(
      "<blockquote><p>Paragraph 1</p><p>Paragraph 2</p><p>Paragraph 3</p></blockquote>",
    ),
    content=(
      #|> Paragraph 1
      #|> 
      #|> Paragraph 2
      #|> 
      #|> Paragraph 3
    ),
  )
}

///|
test "golden blockquote: nested" {
  inspect(
    @html2md.convert(
      "<blockquote><p>before</p><blockquote><p>nested</p></blockquote><p>after</p></blockquote>",
    ),
    content=(
      #|> before
      #|> 
      #|> > nested
      #|> 
      #|> after
    ),
  )
}

///|
test "golden blockquote: other elements inside" {
  inspect(
    @html2md.convert(
      "<blockquote><h2>Heading</h2><ol><li>List Item 1</li><li>List Item 2</li></ol><p>A code block:</p><pre><code>code block content</code></pre></blockquote>",
    ),
    content=(
      #|> ## Heading
      #|> 
      #|> 1. List Item 1
      #|> 2. List Item 2
      #|> 
      #|> A code block:
      #|> 
      #|> ```
      #|> code block content
      #|> ```
    ),
  )
}

///|
test "golden blockquote: not a blockquote in text" {
  inspect(
    @html2md.convert("<p>Not a > blockquote</p>"),
    content=(
      #|Not a &gt; blockquote
    ),
  )
  inspect(
    @html2md.convert("<p>\n> not a blockquote\n</p>"),
    content=(
      #|&gt; not a blockquote
    ),
  )
}
