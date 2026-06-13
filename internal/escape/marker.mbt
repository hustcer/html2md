///|
/// Placeholder inserted before every markdown-special character during the
/// text phase; resolved to `\` or dropped in the post-render un-escape pass.
/// The Go library uses the one-byte-wide bell character (0x07).
pub const MARKER_ESCAPING : Char = '\u{0007}'

///|
/// String form of `MARKER_ESCAPING` for replace operations.
pub let marker_escaping : String = "\u{0007}"

///|
/// Stand-in for newlines inside code blocks, so that post-render newline
/// trimming leaves code content untouched (Go: U+F002).
pub const MARKER_CODE_BLOCK_NEWLINE : Char = '\u{F002}'

///|
/// String form of `MARKER_CODE_BLOCK_NEWLINE` for replace operations.
pub let marker_code_block_newline : String = "\u{F002}"
