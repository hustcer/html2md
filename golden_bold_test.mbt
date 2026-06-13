// End-to-end cases ported from testdata/GoldenFiles/bold.{in.html,out.md}.

///|
test "golden bold: basics" {
  inspect(
    @html2md.convert("<p>some <b>bold</b> and <strong>bold</strong> text</p>"),
    content=(
      #|some **bold** and **bold** text
    ),
  )
  inspect(
    @html2md.convert(
      "<p>some  <b>  bold  </b>  and  <strong>  bold  </strong>  text</p>",
    ),
    content=(
      #|some **bold** and **bold** text
    ),
  )
  inspect(
    @html2md.convert("<p>some<b>bold</b>and<strong>bold</strong>text</p>"),
    content=(
      #|some**bold**and**bold**text
    ),
  )
}

///|
test "golden bold: empty" {
  inspect(
    @html2md.convert("<p>some <strong></strong> text</p>"),
    content=(
      #|some text
    ),
  )
  inspect(
    @html2md.convert("<p>some <strong> </strong> text</p>"),
    content=(
      #|some text
    ),
  )
  inspect(
    @html2md.convert("<p>some <strong>  </strong> text</p>"),
    content=(
      #|some text
    ),
  )
  inspect(
    @html2md.convert("<p>some<strong></strong>text</p>"),
    content=(
      #|sometext
    ),
  )
  inspect(
    @html2md.convert("<p>some<strong> </strong>text</p>"),
    content=(
      #|some text
    ),
  )
  inspect(
    @html2md.convert("<p>some<strong>  </strong>text</p>"),
    content=(
      #|some text
    ),
  )
}

///|
test "golden bold: intra-word" {
  inspect(
    @html2md.convert("<p> normal<b>bold</b>normal </p>"),
    content=(
      #|normal**bold**normal
    ),
  )
  inspect(
    @html2md.convert("<p> <b>bold</b>normal<b>bold</b> </p>"),
    content=(
      #|**bold**normal**bold**
    ),
  )
}

///|
test "golden bold: nested" {
  inspect(
    @html2md.convert("<p><strong><strong>very bold text</strong></strong></p>"),
    content=(
      #|**very bold text**
    ),
  )
  inspect(
    @html2md.convert("<p><b><b>very bold text</b></b></p>"),
    content=(
      #|**very bold text**
    ),
  )
  inspect(
    @html2md.convert("<p><b><b><i><b>hello</b></i></b></b></p>"),
    content=(
      #|***hello***
    ),
  )
  inspect(
    @html2md.convert("<p><b><u><b><i><u><i>hello</i></u></i></b></u></b></p>"),
    content=(
      #|***hello***
    ),
  )
}

///|
test "golden bold: adjacent" {
  inspect(
    @html2md.convert(
      "<div><strong>bold one</strong><strong>bold two</strong></div>",
    ),
    content=(
      #|**bold onebold two**
    ),
  )
  inspect(
    @html2md.convert("<p><b><i>one</i></b> <span><b><i>two</i></b></span></p>"),
    content=(
      #|***one*** ***two***
    ),
  )
  inspect(
    @html2md.convert("<p><strong>a</strong><span><strong>b</strong></span></p>"),
    content=(
      #|**ab**
    ),
  )
  inspect(
    @html2md.convert(
      "<p><strong>a</strong><span><strong>b</strong></span><span><span><strong>c</strong></span></span></p>",
    ),
    content=(
      #|**abc**
    ),
  )
  inspect(
    @html2md.convert(
      "<p><strong>a</strong><span> <strong>b</strong></span></p>",
    ),
    content=(
      #|**a** **b**
    ),
  )
  inspect(
    @html2md.convert(
      "<p><span><strong>Von Max Mustermann,  </strong></span><strong><span>Berlin</span></strong></p>",
    ),
    content=(
      #|**Von Max Mustermann,** **Berlin**
    ),
  )
}

///|
test "golden bold: combinations" {
  inspect(
    @html2md.convert("<p><b><i>bold and italic</i></b></p>"),
    content=(
      #|***bold and italic***
    ),
  )
  inspect(
    @html2md.convert("<p><i><b>italic and bold</b></i></p>"),
    content=(
      #|***italic and bold***
    ),
  )
}

///|
test "golden bold: punctuation around emphasis" {
  inspect(
    @html2md.convert("<p>before<em>middle</em>after</p>"),
    content=(
      #|before*middle*after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>.middle</em>after</p>"),
    content=(
      #|before*.middle*after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>middle.</em>after</p>"),
    content=(
      #|before*middle.*after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>.middle.</em>after</p>"),
    content=(
      #|before*.middle.*after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em> .middle </em>after</p>"),
    content=(
      #|before *.middle* after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em> middle. </em>after</p>"),
    content=(
      #|before *middle.* after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em> .middle. </em>after</p>"),
    content=(
      #|before *.middle.* after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>?!!middle?!!</em>after</p>"),
    content=(
      #|before*?!!middle?!!*after
    ),
  )
  inspect(
    @html2md.convert("<p>before-<em>middle</em>-after</p>"),
    content=(
      #|before-*middle*-after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>-middle-</em>after</p>"),
    content=(
      #|before*-middle-*after
    ),
  )
}

///|
test "golden bold: emphasis with only punctuation" {
  inspect(
    @html2md.convert("<p>check it out<em>.</em></p>"),
    content=(
      #|check it out*.*
    ),
  )
  inspect(
    @html2md.convert("<p>check it out<em>?</em></p>"),
    content=(
      #|check it out*?*
    ),
  )
  inspect(
    @html2md.convert("<p>check it out<em>!!!</em></p>"),
    content=(
      #|check it out*!!!*
    ),
  )
  inspect(
    @html2md.convert("<p><em>!</em>just after</p>"),
    content=(
      #|*!*just after
    ),
  )
  inspect(
    @html2md.convert("<p>just before<em>!</em></p>"),
    content=(
      #|just before*!*
    ),
  )
}

///|
test "golden bold: bold/em adjacent to blocks and links" {
  inspect(
    @html2md.convert("<h4>heading</h4><em>!italic!</em><h4>heading</h4>"),
    content=(
      #|#### heading
      #|
      #|*!italic!*
      #|
      #|#### heading
    ),
  )
  inspect(
    @html2md.convert(
      "<strong>see here:</strong><blockquote>blockquote</blockquote>",
    ),
    content=(
      #|**see here:**
      #|
      #|> blockquote
    ),
  )
  inspect(
    @html2md.convert("<strong>see here:</strong><p>paragraph</p>"),
    content=(
      #|**see here:**
      #|
      #|paragraph
    ),
  )
  inspect(
    @html2md.convert(
      "<em><a href=\"/\">one.</a></em><a href=\"/\"><span>two</span></a>",
    ),
    content=(
      #|[*one.*](/)[two](/)
    ),
  )
  inspect(
    @html2md.convert(
      "<a href=\"/\"><em>one.</em></a><a href=\"/\"><span>two</span></a>",
    ),
    content=(
      #|[*one.*](/)[two](/)
    ),
  )
  inspect(
    @html2md.convert("<div>before<p><em>!paragraph!</em></p>after</div>"),
    content=(
      #|before
      #|
      #|*!paragraph!*
      #|
      #|after
    ),
  )
}
