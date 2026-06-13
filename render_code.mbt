///|
/// Extract the language identifier from a `class="language-xxx"` /
/// `class="lang-xxx"` attribute (port of `commonmark.getCodeLanguage`).
fn get_code_language(node : @dom.Node) -> String {
  let class = @domext.attr_or(node, "class", "")
  for part in class.split(" ") {
    let part = part.to_owned()
    if part.contains("language-") || part.contains("lang-") {
      return part
        .replace_all(old="language-", new="")
        .replace_all(old="lang-", new="")
    }
  }
  ""
}

///|
/// Collect the raw text content of a code/pre subtree (port of
/// `commonmark.getCodeWithoutTags`): `br`/`div` introduce newlines,
/// script/style/textarea subtrees are skipped, the first code/pre class
/// provides the info string.
fn get_code_without_tags(start : @dom.Node) -> (String, String) {
  let buf = StringBuilder()
  let mut info_string = ""
  fn walk(node : @dom.Node) {
    if node.kind is Element &&
      @domext.node_name(node) is ("code" | "pre") &&
      info_string is "" {
      info_string = get_code_language(node)
    }
    if node.kind is Element &&
      @domext.node_name(node) is ("style" | "script" | "textarea") {
      return
    }
    if node.kind is Element && @domext.node_name(node) is ("br" | "div") {
      buf.write_char('\n')
    }
    if node.kind is Text {
      buf.write_string(node.data)
      return
    }
    for child in node.children {
      walk(child)
    }
  }

  walk(start)
  (buf.to_string(), info_string)
}

///|
/// Render an inline code span with a dynamically sized backtick fence (port
/// of `commonmark.renderInlineCode`).
fn render_inline_code(
  _ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let fence_char = '`'
  let (code_content, _) = get_code_without_tags(node)
  if @textutils.trim_space(code_content) is "" {
    // No stripping occurs if the code span contains only spaces.
    out.write_char(fence_char)
    out.write_string(code_content)
    out.write_char(fence_char)
    return
  }
  let code = @textutils.collapse_inline_code_content(code_content)
  let max_count = @textutils.calculate_code_fence_occurrences(fence_char, code) +
    1
  let fence = fence_char.to_string().repeat(max_count)
  // Pad when the content starts or ends with a backtick.
  let code = if code.has_prefix("`") { " " + code } else { code }
  let code = if code.has_suffix("`") { code + " " } else { code }
  out.write_string(fence)
  out.write_string(code)
  out.write_string(fence)
}

///|
/// Render a fenced code block (port of `commonmark.renderBlockCode`).
fn render_block_code(
  ctx : RenderCtx,
  out : StringBuilder,
  node : @dom.Node,
) -> Unit {
  let (code, info_string) = get_code_without_tags(node)
  let code = if code.has_suffix("\n") {
    code[:code.length() - 1].to_owned()
  } else {
    code
  }
  let fence_char = ctx.options.code_block_fence.get_char(0).unwrap()
  let fence = @textutils.calculate_code_fence(fence_char, code)
  // Keep the original content intact: newlines become a marker so the
  // post-render newline trimming leaves them alone.
  let code = code.replace_all(old="\n", new=@escape.marker_code_block_newline)
  out.write_string("\n\n")
  out.write_string(fence)
  out.write_string(info_string)
  out.write_char('\n')
  out.write_string(code)
  out.write_char('\n')
  out.write_string(fence)
  out.write_string("\n\n")
}
