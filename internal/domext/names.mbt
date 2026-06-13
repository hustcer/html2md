///|
/// How a tag behaves during conversion, mirroring `converter.tagType` of the
/// Go library.
pub(all) enum TagType {
  Block
  Inline
  Remove
} derive(Eq, Debug)

///|
/// Tags removed entirely in the pre-render phase (registered by the Go `base`
/// plugin).
pub fn is_removed_name(name : String) -> Bool {
  match name {
    "#comment"
    | "head"
    | "script"
    | "style"
    | "link"
    | "meta"
    | "iframe"
    | "noscript"
    | "input"
    | "textarea" => true
    _ => false
  }
}

///|
/// Inline element names, mirroring `dom.NameIsInlineNode` of
/// github.com/JohannesKaufmann/dom.
pub fn is_inline_name(name : String) -> Bool {
  match name {
    "#text"
    | "a"
    | "abbr"
    | "acronym"
    | "audio"
    | "b"
    | "bdi"
    | "bdo"
    | "big"
    | "br"
    | "button"
    | "canvas"
    | "cite"
    | "code"
    | "data"
    | "datalist"
    | "del"
    | "dfn"
    | "em"
    | "embed"
    | "i"
    | "iframe"
    | "img"
    | "input"
    | "ins"
    | "kbd"
    | "label"
    | "map"
    | "mark"
    | "meter"
    | "noscript"
    | "object"
    | "output"
    | "picture"
    | "progress"
    | "q"
    | "ruby"
    | "s"
    | "samp"
    | "script"
    | "select"
    | "slot"
    | "small"
    | "span"
    | "strong"
    | "sub"
    | "sup"
    | "svg"
    | "template"
    | "textarea"
    | "time"
    | "u"
    | "tt"
    | "var"
    | "video"
    | "wbr" => true
    _ => false
  }
}

///|
/// Block element names, mirroring `dom.NameIsBlockNode` of
/// github.com/JohannesKaufmann/dom.
pub fn is_block_name(name : String) -> Bool {
  match name {
    "address"
    | "article"
    | "aside"
    | "blockquote"
    | "details"
    | "dialog"
    | "dd"
    | "div"
    | "dl"
    | "dt"
    | "fieldset"
    | "figcaption"
    | "figure"
    | "footer"
    | "form"
    | "h1"
    | "h2"
    | "h3"
    | "h4"
    | "h5"
    | "h6"
    | "header"
    | "hgroup"
    | "hr"
    | "li"
    | "main"
    | "nav"
    | "ol"
    | "p"
    | "pre"
    | "section"
    | "table"
    | "ul" => true
    _ => false
  }
}

///|
pub fn is_heading_name(name : String) -> Bool {
  name is ("h1" | "h2" | "h3" | "h4" | "h5" | "h6")
}

///|
/// Void element names as used by the whitespace-collapse algorithm
/// (`collapse/is_node.go`; "source" intentionally excluded there).
pub fn is_void_name(name : String) -> Bool {
  match name {
    "area"
    | "base"
    | "br"
    | "col"
    | "command"
    | "embed"
    | "hr"
    | "img"
    | "input"
    | "keygen"
    | "link"
    | "meta"
    | "param"
    | "track"
    | "wbr" => true
    _ => false
  }
}

///|
/// Preformatted element names for the whitespace-collapse algorithm
/// (the Go port extends the original "pre" with "code").
pub fn is_preformatted_name(name : String) -> Bool {
  name is ("pre" | "code")
}

///|
/// Resolve the tag type the same way as `Converter.getTagType`:
/// explicitly registered types (the remove set) win, then the block list,
/// then the inline list; `None` for unknown tags.
pub fn tag_type(name : String) -> TagType? {
  if is_removed_name(name) {
    Some(Remove)
  } else if is_block_name(name) {
    Some(Block)
  } else if is_inline_name(name) {
    Some(Inline)
  } else {
    None
  }
}

///|
/// Whether a node renders as a markdown block (used for `\n\n` separation in
/// the fallback renderer and for whitespace collapsing).
pub fn is_block_tag_type(name : String) -> Bool {
  tag_type(name) is Some(Block)
}
