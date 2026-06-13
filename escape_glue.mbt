///|
/// Insert escape markers into text content, honoring the escape mode (wraps
/// `@escape.escape_content`).
fn escape(ctx : RenderCtx, content : String) -> String {
  @escape.escape_content(content, enabled=ctx.options.escape_mode is Smart)
}

///|
/// Resolve escape markers using the commonmark un-escaper rule set, honoring
/// the escape mode (wraps `@escape.unescape_content`).
fn unescape(ctx : RenderCtx, content : String) -> String {
  @escape.unescape_content(
    content,
    commonmark_unescapers(),
    enabled=ctx.options.escape_mode is Smart,
  )
}

///|
/// The commonmark un-escaper handlers, in the same registration order as the
/// Go commonmark plugin.
fn commonmark_unescapers() -> Array[@escape.UnEscaper] {
  [
    @escape.is_italic_or_bold, @escape.is_block_quote, @escape.is_atx_header, @escape.is_setext_header,
    @escape.is_divider, @escape.is_ordered_list, @escape.is_unordered_list, @escape.is_image_or_link,
    @escape.is_fenced_code, @escape.is_inline_code, @escape.is_backslash,
  ]
}
