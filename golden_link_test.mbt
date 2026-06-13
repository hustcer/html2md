// End-to-end cases ported from testdata/GoldenFiles/link.{in.html,out.md}.
//
// Note on standalone <a>...<br>...</a> cases: the Go whole-document golden
// keeps a trailing space after the closing ")" (the link is mid-document, so
// the final TrimSpace does not reach it). Here each fragment is the whole
// document, so the trailing space is trimmed — the standalone-correct result.

///|
test "golden link: no href" {
  inspect(
    @html2md.convert("<p><a>no href</a></p>"),
    content=(
      #|[no href]()
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"\">no href</a></p>"),
    content=(
      #|[no href]()
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"\" title=\"link title\">no href</a></p>"),
    content=(
      #|[no href]()
    ),
  )
}

///|
test "golden link: no content" {
  inspect(
    @html2md.convert("<p><a href=\"/no_content\"></a></p>"),
    content=(
      #|[](/no_content)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/no_content\"> </a></p>"),
    content=(
      #|[](/no_content)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/no_content\"><br /></a></p>"),
    content=(
      #|[](/no_content)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/no_content\" title=\"link title\"></a></p>"),
    content=(
      #|[](/no_content "link title")
    ),
  )
}

///|
test "golden link: basic href variants" {
  inspect(
    @html2md.convert("<p><a href=\"/page.html\">relative link</a></p>"),
    content=(
      #|[relative link](/page.html)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"http://simple.org/\">absolute link</a></p>"),
    content=(
      #|[absolute link](http://simple.org/)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/page?b=1&a=2\">query params</a></p>"),
    content=(
      #|[query params](/page?b=1&a=2)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"#heading\">fragment heading</a></p>"),
    content=(
      #|[fragment heading](#heading)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"#\">fragment</a></p>"),
    content=(
      #|[fragment](#)
    ),
  )
}

///|
test "golden link: mailto with newline and trailing whitespace" {
  inspect(
    @html2md.convert(
      "<p>Wir freuen uns über eine <a href=\"mailto:hi@example.com?body=Hello\nJohannes\t\t\">Mail</a>!</p>",
    ),
    content=(
      #|Wir freuen uns über eine [Mail](mailto:hi@example.com?body=Hello%0AJohannes)!
    ),
  )
}

///|
test "golden link: broken/whitespace href" {
  inspect(
    @html2md.convert("<p><a href=\"/page\n\n\">broken link</a></p>"),
    content=(
      #|[broken link](/page)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/page\n\n.html\">broken link</a></p>"),
    content=(
      #|[broken link](/page%0A%0A.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<p><a href=\"  example.com  \">with whitespace around</a></p>",
    ),
    content=(
      #|[with whitespace around](example.com)
    ),
  )
  inspect(
    @html2md.convert(
      "<p><a href=\"http://Open Demo\">with space inside</a></p>",
    ),
    content=(
      #|[with space inside](http://Open%20Demo)
    ),
  )
}

///|
test "golden link: titles" {
  inspect(
    @html2md.convert("<p><a href=\"/\" title=\"link title\">content</a></p>"),
    content=(
      #|[content](/ "link title")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><a href=\"/\" title=\"  link title  \">content</a></p>",
    ),
    content=(
      #|[content](/ "  link title  ")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><a href=\"/\" title=\"\nlink\n\ntitle\n\">content</a></p>",
    ),
    content=(
      #|[content](/ " link  title ")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><a href=\"/\" title=\"&quot;link title&quot;\">content</a></p>",
    ),
    content=(
      #|[content](/ '"link title"')
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/\" title=\"'link title'\">content</a></p>"),
    content=(
      #|[content](/ "'link title'")
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/\" title='\"link title\"'>content</a></p>"),
    content=(
      #|[content](/ '"link title"')
    ),
  )
}

///|
test "golden link: escaping inside list/link/paragraph" {
  inspect(
    @html2md.convert(
      "<ul><li><a href=\"/page.html\">a(b)[c]</a></li><p><a href=\"/page.html\">a]</a></p></ul>",
    ),
    content=(
      #|- [a(b)\[c\]](/page.html)
      #|  
      #|  [a\]](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<div><p><a href=\"/page.html\">a(b)[c]</a></p><p><a href=\"/page.html\">a]</a></p></div>",
    ),
    content=(
      #|[a(b)\[c\]](/page.html)
      #|
      #|[a\]](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<div><p>a(b)[c]</p><p>[a]</p><p>[a</p><p>a]</p><p>(a)</p><p>(a</p><p>a)</p></div>",
    ),
    content=(
      #|a(b)\[c]
      #|
      #|\[a]
      #|
      #|[a
      #|
      #|a]
      #|
      #|(a)
      #|
      #|(a
      #|
      #|a)
    ),
  )
}

///|
test "golden link: adjacent" {
  inspect(
    @html2md.convert("<p><a href=\"/\">A</a><a href=\"/\">B</a></p>"),
    content=(
      #|[A](/)[B](/)
    ),
  )
  inspect(
    @html2md.convert("<p><a href=\"/\">A</a> <a href=\"/\">B</a></p>"),
    content=(
      #|[A](/) [B](/)
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<a href=\"/\">A</a>middle<a href=\"/\">B</a>after</p>",
    ),
    content=(
      #|before[A](/)middle[B](/)after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before <a href=\"/\">A</a> middle <a href=\"/\">B</a> after</p>",
    ),
    content=(
      #|before [A](/) middle [B](/) after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before  <a href=\"/\">A</a>  middle  <a href=\"/\">B</a>  after</p>",
    ),
    content=(
      #|before [A](/) middle [B](/) after
    ),
  )
}

///|
test "golden link: anchor links in headings" {
  inspect(
    @html2md.convert(
      "<h1 id=\"intro\"><a href=\"#intro\">Introduction</a></h1>",
    ),
    content=(
      #|# [Introduction](#intro)
    ),
  )
  inspect(
    @html2md.convert(
      "<h1 id=\"intro\"><a href=\"#intro\" class=\"anchor\"></a>\n  Introduction</h1>",
    ),
    content=(
      #|# [](#intro)Introduction
    ),
  )
  inspect(
    @html2md.convert(
      "<h1 id=\"intro\">\n  Introduction\n  <a href=\"#intro\" class=\"anchor\">#</a></h1>",
    ),
    content=(
      #|# Introduction [#](#intro)
    ),
  )
  inspect(
    @html2md.convert(
      "<h1 id=\"intro\"><a href=\"#intro\" class=\"anchor\">🔗</a>\n  Introduction</h1>",
    ),
    content=(
      #|# [🔗](#intro) Introduction
    ),
  )
}

///|
test "golden link: content with spaces" {
  inspect(
    @html2md.convert("<p>before<a href=\"/\"> content </a>after</p>"),
    content=(
      #|before [content](/) after
    ),
  )
  inspect(
    @html2md.convert("<p>before <a href=\"/\"> content </a> after</p>"),
    content=(
      #|before [content](/) after
    ),
  )
  inspect(
    @html2md.convert("<p>before  <a href=\"/\">  content  </a>  after</p>"),
    content=(
      #|before [content](/) after
    ),
  )
}

///|
test "golden link: inline styles inside link" {
  inspect(
    @html2md.convert(
      "<p><a href=\"/\"><strong>bold</strong> and <em>italic</em> text</a></p>",
    ),
    content=(
      #|[**bold** and *italic* text](/)
    ),
  )
  inspect(
    @html2md.convert(
      "<p><strong>bold <a href=\"/\">and <em>italic</em></a> text</strong></p>",
    ),
    content=(
      #|**bold [and *italic*](/) text**
    ),
  )
}

///|
test "golden link: with line breaks" {
  inspect(
    @html2md.convert("<a href=\"/\">A<br/>B</a>"),
    content=(
      #|[A  
      #|B](/)
    ),
  )
  inspect(
    @html2md.convert("<a href=\"/\">A<br/><br/>B</a>"),
    content=(
      #|[A  
      #|\
      #|B](/)
    ),
  )
  inspect(
    @html2md.convert("<a href=\"/\">A<br/><br/><br/>B</a>"),
    content=(
      #|[A  
      #|\
      #|B](/)
    ),
  )
  inspect(
    @html2md.convert("<a href=\"/\"><div>A</div><div>B</div><div>C</div></a>"),
    content=(
      #|[A  
      #|\
      #|B  
      #|\
      #|C](/)
    ),
  )
}

///|
test "golden link: multiline with too many newlines" {
  inspect(
    @html2md.convert(
      "<a href=\"/\"><p>Start Line</p><br /><br /><br /><span> </span><br /><br /><br /><p>End Line</p></a>",
    ),
    content=(
      #|[Start Line  
      #|\
      #|End Line](/)
    ),
  )
  inspect(
    @html2md.convert(
      "<a href=\"/\"><br /><br /><br /><p>newlines around the link content</p><br /><br /><br /></a>",
    ),
    content=(
      #|[newlines around the link content](/)
    ),
  )
  inspect(
    @html2md.convert(
      "<ul><li><a href=\"/\"><p>first text</p><br /><br /><br /><br /><br /><br /><br /><br /><p>second text</p></a></li></ul>",
    ),
    content=(
      #|- [first text  
      #|  \
      #|  second text](/)
    ),
  )
}

///|
test "golden link: with image and multiline" {
  inspect(
    @html2md.convert(
      "<p><a href=\"/page.html\"><img src=\"/image.jpg\"></a></p>",
    ),
    content=(
      #|[![](/image.jpg)](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<div><a href=\"/page.html\"><p>first text</p><img src=\"/image.jpg\"><p>second text</p></a></div>",
    ),
    content=(
      #|[first text  
      #|\
      #|![](/image.jpg)  
      #|\
      #|second text](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<div><a href=\"/page.html\"><h4>Heading A</h4><h3>Heading B</h3></a></div>",
    ),
    content=(
      #|[**Heading A**  
      #|**Heading B**](/page.html)
    ),
  )
  inspect(
    @html2md.convert(
      "<div><a aria-label=\"aria label\" title=\"title\" href=\"/\"><svg height=\"24\" width=\"24\"><path d=\"...\"></path></svg></a></div>",
    ),
    content=(
      #|[](/ "title")
    ),
  )
}

///|
test "golden link: link and strong inside word" {
  inspect(
    @html2md.convert(
      "<p>before <strong><a href=\"/\">a inside strong</a></strong> after</p>",
    ),
    content=(
      #|before [**a inside strong**](/) after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<strong><a href=\"/\">a inside strong</a></strong>after</p>",
    ),
    content=(
      #|before[**a inside strong**](/)after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before <a href=\"/\"><strong>strong inside a</strong></a> after</p>",
    ),
    content=(
      #|before [**strong inside a**](/) after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<a href=\"/\"><strong>strong inside a</strong></a>after</p>",
    ),
    content=(
      #|before[**strong inside a**](/)after
    ),
  )
}

///|
test "golden link: strong link with spaces and empty spans" {
  inspect(
    @html2md.convert(
      "<p>before  <strong><a href=\"/\">middle</a></strong>  after</p>",
    ),
    content=(
      #|before [**middle**](/) after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<strong><a href=\"/\">  middle  </a></strong>after</p>",
    ),
    content=(
      #|before [**middle**](/) after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<strong><span></span><a href=\"/\">with empty span</a><span></span></strong>after</p>",
    ),
    content=(
      #|before**[with empty span](/)**after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<strong><span>  </span><a href=\"/\">with empty span</a><span>  </span></strong>after</p>",
    ),
    content=(
      #|before **[with empty span](/)** after
    ),
  )
}

///|
test "golden link: strong with link and extra text" {
  inspect(
    @html2md.convert("<p>before<strong><a href=\"/\">a</a> b</strong>after</p>"),
    content=(
      #|before**[a](/) b**after
    ),
  )
  inspect(
    @html2md.convert("<p>before<strong><a href=\"/\">a</a>b</strong>after</p>"),
    content=(
      #|before**[a](/)b**after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<strong><a href=\"/\">a</a> b <a href=\"/\">c</a></strong>after</p>",
    ),
    content=(
      #|before**[a](/) b [c](/)**after
    ),
  )
}

///|
test "golden link: italic/bold combinations" {
  inspect(
    @html2md.convert(
      "<p>before<i><a href=\"/\">a inside italic</a></i>after</p>",
    ),
    content=(
      #|before[*a inside italic*](/)after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<a href=\"/\"><i>italic inside a</i></a>after</p>",
    ),
    content=(
      #|before[*italic inside a*](/)after
    ),
  )
  inspect(
    @html2md.convert("<p>before<b><a href=\"/\">a inside b</a></b>after</p>"),
    content=(
      #|before[**a inside b**](/)after
    ),
  )
  inspect(
    @html2md.convert("<p>before<a href=\"/\"><b>b inside a</b></a>after</p>"),
    content=(
      #|before[**b inside a**](/)after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<b><a href=\"/\"><strong>already bold</strong></a></b>after</p>",
    ),
    content=(
      #|before[**already bold**](/)after
    ),
  )
}

///|
test "golden link: deeply nested bold/italic with link" {
  inspect(
    @html2md.convert(
      "<p>before<b><span><a href=\"/\">middle</a></span></b>after</p>",
    ),
    content=(
      #|before**[middle](/)**after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<b><i><a href=\"/\">inside bold & italic</a></i></b>after</p>",
    ),
    content=(
      #|before**[*inside bold & italic*](/)**after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<b><i><a href=\"/\">inside bold & italic</a>a</i>b</b>after</p>",
    ),
    content=(
      #|before***[inside bold & italic](/)a*b**after
    ),
  )
  inspect(
    @html2md.convert("<p>before<b>a<i>b<a href=\"/\">c</a>d</i>e</b>after</p>"),
    content=(
      #|before**a*b[c](/)d*e**after
    ),
  )
  inspect(
    @html2md.convert(
      "<p>before<b><i>italic</i><a href=\"/\">link</a><strong>strong</strong></b>after</p>",
    ),
    content=(
      #|before***italic*[link](/)strong**after
    ),
  )
}

///|
test "golden link: nesting with table (link in link)" {
  inspect(
    @html2md.convert(
      "<a href=\"/a\"><table><tr><td><p>before</p><a href=\"/b\">another link</a><p>after</p></td></tr></table></a>",
    ),
    content=(
      #|[before  
      #|\
      #|another link  
      #|\
      #|after](/a)
    ),
  )
}
