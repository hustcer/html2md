# html2md

Convert HTML to Markdown (CommonMark) in MoonBit.

This is a MoonBit port of the Go library
[JohannesKaufmann/html-to-markdown v2](https://github.com/JohannesKaufmann/html-to-markdown).

## Features

- HTML-string entry via `convert`, plus `convert_dom` for already-parsed DOM
  nodes, with the same CommonMark option set on both paths.
- Markdown image rendering for `<img>` and GFM pipe-table rendering for
  `<table>`.
- GFM strikethrough for `s`, `del` and `strike` tags.
- Table-specific behavior for escaped pipes, header alignment markers, simple
  `colspan`/`rowspan` placeholder cells and `role="presentation"` fallback.
- Smart escaping that protects fake Markdown syntax in text while preserving
  real formatting produced from HTML tags.
- Configurable CommonMark output for heading style, emphasis delimiters,
  horizontal rules, bullet markers, code fences, empty-link behavior and list
  separation comments.
- Relative-link resolution against `domain`, plus RFC 3986 query-component
  normalization for spaces, Unicode, valid percent octets and literal `+`.

## Install

```sh
moon add hustcer/html2md
```

Add the import to the package that needs it (`moon.pkg`):

```
import { "hustcer/html2md" }
```

## Usage

```mbt check
///|
test "basic" {
  let html =
    #|<h1>Hello</h1>
    #|<p>Some <b>bold</b> and <i>italic</i> text with a
    #|<a href="https://example.com">link</a>.</p>
  inspect(
    @html2md.convert(html),
    content=(
      #|# Hello
      #|
      #|Some **bold** and *italic* text with a [link](https://example.com).
    ),
  )
}
```

### Lists, code and blockquotes

````mbt check
///|
test "blocks" {
  let html =
    #|<ul><li>first</li><li>second</li></ul>
    #|<pre><code class="language-go">x := 1</code></pre>
    #|<blockquote>a quote</blockquote>
  inspect(
    @html2md.convert(html),
    content=(
      #|- first
      #|- second
      #|
      #|```go
      #|x := 1
      #|```
      #|
      #|> a quote
    ),
  )
}
````

### GFM tables and strikethrough

Pipes inside table cells are escaped, and `s`/`del`/`strike` tags render as
GFM strikethrough:

```mbt check
///|
test "gfm" {
  let html =
    #|<p><del>old</del> value</p>
    #|<table>
    #|  <tr><th>Name</th><th>Value</th></tr>
    #|  <tr><td>A</td><td>1 | 2</td></tr>
    #|</table>
  inspect(
    @html2md.convert(html),
    content=(
      #|~~old~~ value
      #|
      #|| Name | Value |
      #|| --- | --- |
      #|| A | 1 \| 2 |
    ),
  )
}
```

### Smart escaping

Markdown-special characters in _text_ are escaped only when they would
otherwise be parsed as markdown, while real formatting from tags is preserved:

```mbt check
///|
test "escaping" {
  inspect(
    @html2md.convert("<p>fake **bold** and real <strong>bold</strong></p>"),
    content=(
      #|fake \*\*bold\** and real **bold**
    ),
  )
}
```

Escaping can be turned off entirely:

```mbt check
///|
test "escaping disabled" {
  inspect(
    @html2md.convert("<p>1. not a list</p>", escape_mode=Disabled),
    content="1. not a list",
  )
}
```

### Relative links

Provide a `domain` to turn relative URLs into absolute ones. Query components
are percent-encoded with RFC 3986 URL semantics: spaces become `%20`, Unicode
is UTF-8 percent-encoded, valid `%HH` octets are preserved, and `+` stays `+`.

```mbt check
///|
test "domain" {
  inspect(
    @html2md.convert("<a href=\"/page\">link</a>", domain="https://example.com"),
    content="[link](https://example.com/page)",
  )
  inspect(
    @html2md.convert(
      "<a href=\"?q=hello world&next=/a?b=1&plus=a+b\">search</a>",
      domain="https://example.com/path?old=1",
    ),
    content="[search](https://example.com/path?q=hello%20world&next=/a?b=1&plus=a+b)",
  )
}
```

## Options

`convert` (and `convert_dom`, which takes an already-parsed
`@html_parser/dom.Node`) accept the following labeled options:

| Option                        | Type           | Default   | Notes                                            |
| ----------------------------- | -------------- | --------- | ------------------------------------------------ |
| `domain`                      | `String`       | `""`      | Base domain for relative URLs                    |
| `heading_style`               | `HeadingStyle` | `Atx`     | `Atx` (`# H`) or `Setext` (underlined h1/h2)     |
| `em_delimiter`                | `String`       | `"*"`     | `"*"` or `"_"`                                   |
| `strong_delimiter`            | `String`       | `"**"`    | `"**"` or `"__"`                                 |
| `horizontal_rule`             | `String`       | `"* * *"` | any thematic break (≥3 of `*`/`_`/`-`)           |
| `bullet_list_marker`          | `String`       | `"-"`     | `"-"`, `"+"` or `"*"`                            |
| `code_block_fence`            | `String`       | `"```"`   | `"```"` or `"~~~"`                               |
| `escape_mode`                 | `EscapeMode`   | `Smart`   | `Smart` or `Disabled`                            |
| `link_empty_href_behavior`    | `LinkBehavior` | `Render`  | `Render` keeps `[text]()`, `Skip` drops the link |
| `link_empty_content_behavior` | `LinkBehavior` | `Render`  | `Render` keeps `[](href)`, `Skip` drops the link |
| `list_end_comment`            | `Bool`         | `true`    | insert `<!--THE END-->` between adjacent lists   |

Invalid option values raise `ConvertError::InvalidConfig`.

## Development

Useful validation commands before committing:

```sh
moon fmt
moon check --target all
moon test --target all
moon info
```

## License

Apache-2.0
