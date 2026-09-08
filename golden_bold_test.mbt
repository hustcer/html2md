// End-to-end cases ported from testdata/GoldenFiles/bold.{in.html,out.md}.

///|
test "adjacent emphasis separates punctuation boundaries" {
  inspect(
    @html2md.convert("<p><strong>a!</strong><em>b</em></p>"),
    content="**a!**<!-- -->*b*",
  )
  inspect(
    @html2md.convert("<p><strong>a</strong><em>!b</em></p>"),
    content="**a**<!-- -->*!b*",
  )
  inspect(
    @html2md.convert("<p><em>a</em><strong>!</strong></p>"),
    content="*a*<!-- -->**!**",
  )
}

///|
test "adjacent emphasis retains nested formatting" {
  inspect(
    @html2md.convert("<p><strong>a<em>b</em></strong><em>c</em></p>"),
    content="**a*b***<!-- -->*c*",
  )
  inspect(
    @html2md.convert("<p><em>a<strong>b</strong></em><strong>c</strong></p>"),
    content="*a**b***<!-- -->**c**",
  )
}

///|
test "emphasis boundaries follow spans and ignore empty output" {
  inspect(
    @html2md.convert(
      "<p><strong>a!</strong><span></span><span><em>b</em></span></p>",
    ),
    content="**a!**<!-- -->*b*",
  )
  inspect(
    @html2md.convert("<p><strong>甲，</strong><em>乙</em></p>"),
    content="**甲，**<!-- -->*乙*",
  )
}

///|
test "emphasis boundaries preserve configured underscore delimiters" {
  inspect(
    @html2md.convert(
      "<p><strong>a!</strong><em>b</em></p>",
      strong_delimiter="__",
      em_delimiter="_",
    ),
    content="__a!__<!-- -->_b_",
  )
  inspect(
    @html2md.convert(
      "<p><strong>a<em>b</em></strong><em>c</em></p>",
      em_delimiter="_",
    ),
    content="**a<!-- -->_b_**<!-- -->_c_",
  )
}

///|
test "adjacent emphasis supports every delimiter combination" {
  for strong in ["**", "__"] {
    for em in ["*", "_"] {
      assert_eq(
        @html2md.convert(
          "<p><b>a!</b><i>b</i><strong>c?</strong></p>",
          strong_delimiter=strong,
          em_delimiter=em,
        ),
        strong +
        "a!" +
        strong +
        "<!-- -->" +
        em +
        "b" +
        em +
        "<!-- -->" +
        strong +
        "c?" +
        strong,
      )
    }
  }
}

///|
test "literal disabled Markdown is not a generated emphasis edge" {
  inspect(
    @html2md.convert(
      "<p>**literal**<span>*more*</span></p>",
      escape_mode=Disabled,
    ),
    content="**literal***more*",
  )
}

///|
test "adjacent bold and italic retain distinct formatting" {
  inspect(
    @html2md.convert("<p><strong>bold</strong><em>italic</em></p>"),
    content=(
      #|**bold**<!-- -->*italic*
    ),
  )
  inspect(
    @html2md.convert("<p><i>italic</i><b>bold</b></p>"),
    content=(
      #|*italic*<!-- -->**bold**
    ),
  )
}

///|
test "adjacent emphasis aliases merge only within their own style" {
  inspect(
    @html2md.convert(
      "<p><b>a</b><strong>b</strong><i>c</i><em>d</em></p>",
      em_delimiter="_",
    ),
    content=(
      #|**ab**<!-- -->_cd_
    ),
  )
  inspect(
    @html2md.convert(
      "<p><em>a</em><span><strong>b</strong></span><i>c</i></p>",
      em_delimiter="_",
    ),
    content=(
      #|_a_<!-- -->**b**<!-- -->_c_
    ),
  )
}

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
test "commonmark italic plugin cases from Go" {
  inspect(
    @html2md.convert("<em>Italic</em>Normal<em>Italic</em>"),
    content="*Italic*Normal*Italic*",
  )
  inspect(
    @html2md.convert("Normal<em>Italic</em>Normal"),
    content="Normal*Italic*Normal",
  )
  inspect(
    @html2md.convert("<em>  A  </em><em>  B  </em>  <em>  C  </em>"),
    content="*A B* *C*",
  )
  inspect(
    @html2md.convert("<em>  A  <em>  B  </em>  C  </em>"),
    content="*A B C*",
  )
  inspect(@html2md.convert("before<i></i>after"), content="beforeafter")
  inspect(@html2md.convert("before<i> </i>after"), content="before after")
  inspect(@html2md.convert("before <i> </i> after"), content="before after")
  inspect(
    @html2md.convert("before<i>\u{a0}</i>after"),
    content="before\u{a0}after",
  )
  inspect(
    @html2md.convert("before<i>\u{200b}</i>after"),
    content="before<!-- -->*\u{200b}*<!-- -->after",
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
      #|before<!-- -->*.middle*after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>middle.</em>after</p>"),
    content=(
      #|before*middle.*<!-- -->after
    ),
  )
  inspect(
    @html2md.convert("<p>before<em>.middle.</em>after</p>"),
    content=(
      #|before<!-- -->*.middle.*<!-- -->after
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
      #|before<!-- -->*?!!middle?!!*<!-- -->after
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
      #|before<!-- -->*-middle-*<!-- -->after
    ),
  )
}

///|
test "golden bold: emphasis with only punctuation" {
  inspect(
    @html2md.convert("<p>check it out<em>.</em></p>"),
    content=(
      #|check it out<!-- -->*.*
    ),
  )
  inspect(
    @html2md.convert("<p>check it out<em>?</em></p>"),
    content=(
      #|check it out<!-- -->*?*
    ),
  )
  inspect(
    @html2md.convert("<p>check it out<em>!!!</em></p>"),
    content=(
      #|check it out<!-- -->*!!!*
    ),
  )
  inspect(
    @html2md.convert("<p><em>!</em>just after</p>"),
    content=(
      #|*!*<!-- -->just after
    ),
  )
  inspect(
    @html2md.convert("<p>just before<em>!</em></p>"),
    content=(
      #|just before<!-- -->*!*
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
