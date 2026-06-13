// URL assembly tests, ported from `converter/url_test.go`. They exercise
// `assemble_absolute_url` through the public `convert` (via `<a href>`).
//
// Note: unlike the Go reference we do NOT re-encode query strings (see PLAN.md
// risk #4), so the mailto query-encoding cases are intentionally omitted.

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
