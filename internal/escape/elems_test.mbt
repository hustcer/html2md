// Unit tests for the un-escaper rules, ported case-by-case from
// internal/escape/elem_*_test.go of the Go reference. The Go tests operate on
// byte slices with the placeholder byte 0x07; here we work in char space (the
// marker is a single BMP code unit), so ASCII cases map 1:1. The few
// multibyte "random input" cases are adapted to char-space expectations.

///|
/// Run an un-escaper at every index of `input` and collect the results,
/// mirroring the `for index := range chars` loops in the Go tests.
fn all_results(f : (Array[Char], Int) -> Int, input : String) -> Array[Int] {
  let chars = input.to_array()
  let out = []
  for i in 0..<chars.length() {
    out.push(f(chars, i))
  }
  out
}

///|
/// Marker string for building inputs (the placeholder before a markdown char).
let m : String = marker_escaping

///|
test "is_fenced_code" {
  debug_inspect(all_results(is_fenced_code, "abc"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_fenced_code, "\{m}`\{m}`a"),
    content="[-1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, "a \{m}`\{m}`\{m}`a"),
    content="[-1, -1, -1, -1, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, "\{m}`\{m}`\{m}`a"),
    content="[-1, 5, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, "\{m}~\{m}~\{m}~a"),
    content="[-1, 5, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, " \{m}`\{m}`\{m}`a"),
    content="[-1, -1, 5, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, "\n\{m}`\{m}`\{m}`a"),
    content="[-1, -1, 5, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, "\{m}`\{m}`\{m}`\na\n\{m}`\{m}`\{m}`"),
    content="[-1, 5, -1, -1, -1, -1, -1, -1, -1, -1, 5, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_fenced_code, "\{m}`\{m}`\{m}`\na\n\{m}`"),
    content="[-1, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1]",
  )
}

///|
test "is_inline_code" {
  debug_inspect(all_results(is_inline_code, "abc"), content="[-1, -1, -1]")
  debug_inspect(all_results(is_inline_code, "`a`"), content="[1, -1, 1]")
}

///|
test "is_divider" {
  debug_inspect(all_results(is_divider, "abc"), content="[-1, -1, -1]")
  debug_inspect(all_results(is_divider, "--"), content="[-1, -1]")
  debug_inspect(
    all_results(is_divider, "--- a"),
    content="[-1, -1, -1, -1, -1]",
  )
  debug_inspect(all_results(is_divider, "---"), content="[3, -1, -1]")
  debug_inspect(all_results(is_divider, "-----"), content="[5, -1, -1, -1, -1]")
  debug_inspect(all_results(is_divider, "--- "), content="[4, -1, -1, -1]")
  debug_inspect(all_results(is_divider, "---\n"), content="[3, -1, -1, -1]")
  debug_inspect(
    all_results(is_divider, "\n ---"),
    content="[-1, -1, 3, -1, -1]",
  )
  debug_inspect(
    all_results(is_divider, "\n \{m}-\{m}-\{m}-"),
    content="[-1, -1, -1, 5, -1, -1, -1, -1]",
  )
}

///|
test "is_atx_header" {
  debug_inspect(all_results(is_atx_header, "abc"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_atx_header, "a\{m}# a"),
    content="[-1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "a \{m}# a"),
    content="[-1, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "\{m}# ab"),
    content="[-1, 1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "\n\{m}# ab"),
    content="[-1, -1, 1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, " \{m}# ab"),
    content="[-1, -1, 1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "\{m}#\{m}# ab"),
    content="[-1, 3, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "\{m}#\{m}#\{m}#\{m}# a"),
    content="[-1, 7, -1, -1, -1, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "\{m}#\{m}#\{m}#\{m}#\{m}#\{m}# a"),
    content="[-1, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_atx_header, "\{m}#\{m}#\{m}#\{m}#\{m}#\{m}#\{m}# a"),
    content="[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]",
  )
  debug_inspect(all_results(is_atx_header, "\{m}#a"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_atx_header, "\{m}# \na"),
    content="[-1, 1, -1, -1, -1]",
  )
  debug_inspect(all_results(is_atx_header, "\{m}#"), content="[-1, 1]")
  debug_inspect(
    all_results(is_atx_header, "\{m}#\ta"),
    content="[-1, 1, -1, -1]",
  )
}

///|
test "is_setext_header" {
  debug_inspect(all_results(is_setext_header, "abc"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_setext_header, "a\{m}=b"),
    content="[-1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_setext_header, "a\n\n\{m}="),
    content="[-1, -1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_setext_header, "a\n\{m}="),
    content="[-1, -1, -1, 1]",
  )
  debug_inspect(all_results(is_setext_header, "\{m}="), content="[-1, -1]")
}

///|
test "is_image_or_link" {
  debug_inspect(all_results(is_image_or_link, "abc"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_image_or_link, "\{m}!\{m}[a]"),
    content="[-1, -1, -1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_image_or_link, "!\{m}[a]"),
    content="[-1, -1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_image_or_link, "\{m}![a]"),
    content="[-1, 1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_image_or_link, "[[[a]"),
    content="[1, 1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_image_or_link, "[a\n]"),
    content="[-1, -1, -1, -1]",
  )
  debug_inspect(all_results(is_image_or_link, "[a"), content="[-1, -1]")
  debug_inspect(all_results(is_image_or_link, "!"), content="[-1]")
}

///|
test "is_italic_or_bold (single index)" {
  inspect(is_italic_or_bold("normal text".to_array(), 0), content="-1")
  inspect(is_italic_or_bold("*a".to_array(), 0), content="1")
  inspect(is_italic_or_bold("\n *a".to_array(), 2), content="1")
  inspect(is_italic_or_bold("text *a".to_array(), 5), content="1")
  inspect(is_italic_or_bold("a*a".to_array(), 1), content="1")
  inspect(is_italic_or_bold(".*a".to_array(), 1), content="1")
  inspect(is_italic_or_bold(" *a".to_array(), 1), content="1")
  inspect(is_italic_or_bold(" *.".to_array(), 1), content="1")
  inspect(is_italic_or_bold(" *".to_array(), 1), content="-1")
  inspect(is_italic_or_bold(" * ".to_array(), 1), content="-1")
  inspect(is_italic_or_bold(" *\n".to_array(), 1), content="-1")
  inspect(is_italic_or_bold(".*.".to_array(), 1), content="1")
  inspect(is_italic_or_bold("*!*".to_array(), 0), content="1")
  inspect(is_italic_or_bold("$*content*".to_array(), 1), content="1")
  inspect(is_italic_or_bold("0$*!*".to_array(), 2), content="1")
}

///|
test "is_italic_or_bold (all indices, char space)" {
  // Go's "random input" cases use \xac (U+00AC); in char space it is one char,
  // so the '*' lands at index 1 (Go's byte-indexed expectation was shifted).
  debug_inspect(
    all_results(is_italic_or_bold, "\u{AC}*!0*"),
    content="[-1, 1, -1, -1, -1]",
  )
  debug_inspect(
    all_results(is_italic_or_bold, "\u{AC}\u{AC}\u{AC}*!0*"),
    content="[-1, -1, -1, 1, -1, -1, -1]",
  )
}

///|
test "is_unordered_list" {
  debug_inspect(all_results(is_unordered_list, "abc"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_unordered_list, "a- b"),
    content="[-1, -1, -1, -1]",
  )
  debug_inspect(all_results(is_unordered_list, "-ab"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_unordered_list, "\{m}- a\n\{m}- b"),
    content="[-1, 1, -1, -1, -1, -1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_unordered_list, " - a"),
    content="[-1, 1, -1, -1]",
  )
}

///|
test "is_ordered_list" {
  debug_inspect(all_results(is_ordered_list, "abc"), content="[-1, -1, -1]")
  debug_inspect(all_results(is_ordered_list, "1. a"), content="[-1, 1, -1, -1]")
  debug_inspect(
    all_results(is_ordered_list, "123. a"),
    content="[-1, -1, -1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_ordered_list, "a1. a"),
    content="[-1, -1, -1, -1, -1]",
  )
  debug_inspect(all_results(is_ordered_list, "1.a"), content="[-1, -1, -1]")
  debug_inspect(all_results(is_ordered_list, "a.b"), content="[-1, -1, -1]")
  debug_inspect(
    all_results(is_ordered_list, " 1. a"),
    content="[-1, -1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_ordered_list, "\{m}1. a\n\{m}1. b"),
    content="[-1, -1, 1, -1, -1, -1, -1, -1, 1, -1, -1]",
  )
}

///|
test "is_block_quote" {
  debug_inspect(all_results(is_block_quote, "> a"), content="[1, -1, -1]")
  debug_inspect(all_results(is_block_quote, " > a"), content="[-1, 1, -1, -1]")
  debug_inspect(all_results(is_block_quote, ">a"), content="[1, -1]")
  debug_inspect(all_results(is_block_quote, "\n> a"), content="[-1, 1, -1, -1]")
  debug_inspect(
    all_results(is_block_quote, "\n > a"),
    content="[-1, -1, 1, -1, -1]",
  )
  debug_inspect(
    all_results(is_block_quote, "\{m}> a"),
    content="[-1, 1, -1, -1]",
  )
  debug_inspect(all_results(is_block_quote, "a> a"), content="[-1, -1, -1, -1]")
}

///|
test "is_backslash" {
  debug_inspect(all_results(is_backslash, "a\\b"), content="[-1, 1, -1]")
  debug_inspect(all_results(is_backslash, "abc"), content="[-1, -1, -1]")
}
