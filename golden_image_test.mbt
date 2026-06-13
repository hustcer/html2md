// End-to-end cases ported from testdata/GoldenFiles/image.{in.html,out.md}.

///|
test "golden image: no src is skipped" {
  inspect(@html2md.convert("<p><img /></p>"), content="")
  inspect(@html2md.convert("<p><img src=\"\" /></p>"), content="")
}

///|
test "golden image: basics" {
  inspect(
    @html2md.convert("<p><img src=\"/relative_url\" /></p>"),
    content=(
      #|![](/relative_url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"www.example.com/absolute_url\" /></p>"),
    content=(
      #|![](www.example.com/absolute_url)
    ),
  )
}

///|
test "golden image: alt and title attributes" {
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt=\"alt text\" /></p>"),
    content=(
      #|![alt text](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" title=\"title text\" /></p>"),
    content=(
      #|![](/url "title text")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" alt=\"alt text\" title=\"title text\" /></p>",
    ),
    content=(
      #|![alt text](/url "title text")
    ),
  )
}

///|
test "golden image: special characters in alt" {
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" alt=\"  the  alt  attribute  \" /></p>",
    ),
    content=(
      #|![  the  alt  attribute  ](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt='the alt \"attribute\"' /></p>"),
    content=(
      #|![the alt "attribute"](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt=\"the alt 'attribute'\" /></p>"),
    content=(
      #|![the alt 'attribute'](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt=\"the\nalt\nattribute\" /></p>"),
    content=(
      #|![the alt attribute](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt=\"the [alt] attribute\" /></p>"),
    content=(
      #|![the \[alt\] attribute](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt=\"the (alt) attribute\" /></p>"),
    content=(
      #|![the (alt) attribute](/url)
    ),
  )
  inspect(
    @html2md.convert("<p><img src=\"/url\" alt=\"the ](alt) attribute\" /></p>"),
    content=(
      #|![the \](alt) attribute](/url)
    ),
  )
}

///|
test "golden image: special characters in title" {
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title=\"  the  title  attribute  \" /></p>",
    ),
    content=(
      #|![](/url "  the  title  attribute  ")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title='the title \"attribute\"' /></p>",
    ),
    content=(
      #|![](/url 'the title "attribute"')
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title=\"the title 'attribute'\" /></p>",
    ),
    content=(
      #|![](/url "the title 'attribute'")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title=\"the\ntitle\nattribute\" /></p>",
    ),
    content=(
      #|![](/url "the title attribute")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title=\"the [title] attribute\" /></p>",
    ),
    content=(
      #|![](/url "the [title] attribute")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title=\"the (title) attribute\" /></p>",
    ),
    content=(
      #|![](/url "the (title) attribute")
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"/url\" title=\"the )(title) attribute\" /></p>",
    ),
    content=(
      #|![](/url "the )(title) attribute")
    ),
  )
}

///|
test "golden image: data uris" {
  inspect(
    @html2md.convert("<p><img src=\"data:image/gif;base64,abcdefghij\" /></p>"),
    content=(
      #|![](data:image/gif;base64,abcdefghij)
    ),
  )
  inspect(
    @html2md.convert(
      "<p><img src=\"data:image/svg+xml;utf8,&lt;svg xmlns=&#39;http://www.w3.org/2000/svg&#39; width=&#39;1080&#39; height=&#39;956&#39;&gt;&lt;/svg&gt;\" /></p>",
    ),
    content=(
      #|![](data:image/svg+xml;utf8,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20width='1080'%20height='956'%3E%3C/svg%3E)
    ),
  )
}

///|
test "golden image: link with just an image" {
  inspect(
    @html2md.convert(
      "<p><a><i><img src=\"/search.svg\" alt=\"Such Icon\" /></i></a> <a><i><img src=\"/email.svg\" alt=\"Email Icon\" /></i></a></p>",
    ),
    content=(
      #|[*![Such Icon](/search.svg)*]() [*![Email Icon](/email.svg)*]()
    ),
  )
  inspect(
    @html2md.convert(
      "<p><i><a><img src=\"/search.svg\" alt=\"Such Icon\" /></a></i> <i><a><img src=\"/email.svg\" alt=\"Email Icon\" /></a></i></p>",
    ),
    content=(
      #|[*![Such Icon](/search.svg)*]() [*![Email Icon](/email.svg)*]()
    ),
  )
}

///|
test "golden image: image inside (empty) link" {
  inspect(
    @html2md.convert(
      "<a href=\"/page.html\" title=\"link title text\"><img src=\"/image.jpg\" alt=\"image alt text\" title=\"image title text\" /></a>",
    ),
    content=(
      #|[![image alt text](/image.jpg "image title text")](/page.html "link title text")
    ),
  )
  inspect(
    @html2md.convert(
      "<a href=\"\" title=\"link title text\"><img src=\"/src\" alt=\"image alt text\" /></a>",
    ),
    content=(
      #|[![image alt text](/src)]()
    ),
  )
}

///|
test "golden image: picture and figure" {
  inspect(
    @html2md.convert(
      "<picture><source srcset=\"/image.webp 960w\" type=\"image/webp\" /><img src=\"/image.jpg\" title=\"title text\" alt=\"alt text\" /></picture>",
    ),
    content=(
      #|![alt text](/image.jpg "title text")
    ),
  )
  inspect(
    @html2md.convert(
      "<figure><div><picture><source srcset=\"/image.webp 960w\" type=\"image/webp\" /><img src=\"/image.jpg\" title=\"title text\" alt=\"alt text\" /></picture></div><figcaption>caption text</figcaption></figure>",
    ),
    content=(
      #|![alt text](/image.jpg "title text")
      #|
      #|caption text
    ),
  )
}
