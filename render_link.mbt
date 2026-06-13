///|
/// Render `<a>` as an inlined link (port of `commonmark.renderLink` +
/// `renderLinkInlined`). Returns false to fall through to other renderers.
fn render_link(ctx : RenderCtx, out : StringBuilder, node : @dom.Node) -> Bool {
  let link_ctx = { ..ctx, is_inside_link: true }
  let href = @textutils.trim_space(@domext.attr_or(node, "href", ""))
  let href = assemble_absolute_url("a", href, ctx.options.domain)
  if href is "" && ctx.options.link_empty_href_behavior is Skip {
    return false
  }
  let title = @domext.attr_or(node, "title", "").replace_all(old="\n", new=" ")
  let buf = StringBuilder()
  render_children(link_ctx, buf, node)
  let content = buf.to_string()
  if @textutils.trim_space(content) is "" &&
    ctx.options.link_empty_content_behavior is Skip {
    return false
  }
  // A link without href is valid, like e.g. [text]() — but a title would
  // make it invalid.
  let title = if href is "" { "" } else { title }
  let (before, trimmed, after) = @textutils.surrounding_spaces(content)
  let trimmed = @textutils.trim_consecutive_newlines(trimmed)
  let trimmed = @textutils.escape_multiline(trimmed)
  out.write_string(before)
  out.write_char('[')
  out.write_string(trimmed)
  out.write_string("](")
  out.write_string(href)
  if title != "" {
    // The destination and title must be separated by a space
    out.write_char(' ')
    out.write_string(@textutils.surround_by_quotes(title))
  }
  out.write_char(')')
  out.write_string(after)
  true
}
