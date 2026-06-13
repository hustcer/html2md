// URL assembly tests exercise `assemble_absolute_url` through the public
// `convert` (via `<a href>`). Query component encoding follows RFC 3986:
// keep allowed query data and valid percent-encoded octets, encode invalid
// units with UTF-8 percent-encoding, and never treat `+` as a space.

///|
fn link(href : String, domain? : String = "") -> String raise {
  @html2md.convert("<a href=\"\{href}\">x</a>", domain~)
}

///|
test "url: fragments" {
  inspect(
    link("#"),
    content=(
      #|[x](#)
    ),
  )
  inspect(
    link("#heading"),
    content=(
      #|[x](#heading)
    ),
  )
  inspect(
    link("#my heading"),
    content=(
      #|[x](#my%20heading)
    ),
  )
}

///|
test "url: relative path with and without domain" {
  inspect(
    link("/page.html?key=val#hash"),
    content=(
      #|[x](/page.html?key=val#hash)
    ),
  )
  inspect(
    link("/page.html?key=val#hash", domain="test.com"),
    content=(
      #|[x](http://test.com/page.html?key=val#hash)
    ),
  )
  inspect(
    link("/page.html?key=val#hash", domain="http://test.com"),
    content=(
      #|[x](http://test.com/page.html?key=val#hash)
    ),
  )
  inspect(
    link("/page.html?key=val#hash", domain="https://test.com"),
    content=(
      #|[x](https://test.com/page.html?key=val#hash)
    ),
  )
  inspect(
    link("/page.html?key=val#hash", domain="https://test.com/random_stuff"),
    content=(
      #|[x](https://test.com/page.html?key=val#hash)
    ),
  )
}

///|
test "url: absolute urls are left alone" {
  inspect(
    link("http://www.example.com", domain="test.com"),
    content=(
      #|[x](http://www.example.com)
    ),
  )
  inspect(
    link("https://www.example.com", domain="test.com"),
    content=(
      #|[x](https://www.example.com)
    ),
  )
  inspect(
    link("slack://open?team=abc", domain="test.com"),
    content=(
      #|[x](slack://open?team=abc)
    ),
  )
}

///|
test "url: query parameter order preserved" {
  inspect(
    link("https://www.example.com?a=1&c=2&b=3&x=&y", domain="test.com"),
    content=(
      #|[x](https://www.example.com?a=1&c=2&b=3&x=&y)
    ),
  )
}

///|
test "url: query component is RFC3986 percent-encoded" {
  inspect(
    link("https://example.com/search?q=hello world&next=/a?b=1&plus=a+b"),
    content=(
      #|[x](https://example.com/search?q=hello%20world&next=/a?b=1&plus=a+b)
    ),
  )
  inspect(
    link("https://example.com/search?q=中文&raw=[x]#frag ment"),
    content=(
      #|[x](https://example.com/search?q=%E4%B8%AD%E6%96%87&raw=%5Bx%5D#frag%20ment)
    ),
  )
  inspect(
    link("https://example.com/search?q=a%2fb&bad=%zz&tail=%"),
    content=(
      #|[x](https://example.com/search?q=a%2Fb&bad=%25zz&tail=%25)
    ),
  )
  inspect(
    link("https://example.com/search?q=1+1%20%3d%202"),
    content=(
      #|[x](https://example.com/search?q=1+1%20%3D%202)
    ),
  )
}

///|
test "url: query-only reference replaces base query" {
  inspect(
    link("?p=2", domain="https://example.com/path?a=1"),
    content=(
      #|[x](https://example.com/path?p=2)
    ),
  )
  inspect(
    link("?p=2", domain="https://example.com"),
    content=(
      #|[x](https://example.com?p=2)
    ),
  )
  inspect(
    link("#new", domain="https://example.com/path?a=1#old"),
    content=(
      #|[x](https://example.com/path?a=1#new)
    ),
  )
}

///|
test "url: query-only reference is re-encoded after base resolution" {
  inspect(
    link("?q=hello world&to=../img.png", domain="https://example.com/path?a=1"),
    content=(
      #|[x](https://example.com/path?q=hello%20world&to=../img.png)
    ),
  )
  inspect(
    link("?q=100% done", domain="https://example.com"),
    content=(
      #|[x](https://example.com?q=100%25%20done)
    ),
  )
}

///|
test "url: relative path dot segments are normalized" {
  inspect(
    link("../img.png", domain="https://example.com/docs/page.html"),
    content=(
      #|[x](https://example.com/img.png)
    ),
  )
  inspect(
    link("./img.png", domain="https://example.com/docs/page.html"),
    content=(
      #|[x](https://example.com/docs/img.png)
    ),
  )
  inspect(
    link("../img.png?q=1#h", domain="https://example.com/docs/page.html?a=1"),
    content=(
      #|[x](https://example.com/img.png?q=1#h)
    ),
  )
}

///|
test "url: mailto query fields are percent-encoded" {
  inspect(
    link("mailto:hi@example.com?subject=Hello World&body=Line 1\nLine 2"),
    content=(
      #|[x](mailto:hi@example.com?subject=Hello%20World&body=Line%201%0ALine%202)
    ),
  )
  inspect(
    link("mailto:hi@example.com?body=1+1=2&note=a%2bb"),
    content=(
      #|[x](mailto:hi@example.com?body=1+1=2&note=a%2Bb)
    ),
  )
}

///|
test "url: special characters percent-encoded" {
  inspect(
    link("https://Open Demo"),
    content=(
      #|[x](https://Open%20Demo)
    ),
  )
  inspect(
    link("https://Open [foo](uri) Demo"),
    content=(
      #|[x](https://Open%20%5Bfoo%5D%28uri%29%20Demo)
    ),
  )
}

///|
test "url: data uri" {
  inspect(
    link("data:image/gif;base64,R0lGODlh", domain="test.com"),
    content=(
      #|[x](data:image/gif;base64,R0lGODlh)
    ),
  )
  inspect(
    link(
      "data:image/svg+xml,%3Csvg viewBox='0 0 56 56' %3E%3C/svg%3E",
      domain="test.com",
    ),
    content=(
      #|[x](data:image/svg+xml,%3Csvg%20viewBox='0%200%2056%2056'%20%3E%3C/svg%3E)
    ),
  )
}
