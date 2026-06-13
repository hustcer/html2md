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
/// The commonmark un-escaper handlers, in registration order. Filled in P5;
/// with an empty list `unescape` simply strips the markers (no escaping).
fn commonmark_unescapers() -> Array[@escape.UnEscaper] {
  []
}
