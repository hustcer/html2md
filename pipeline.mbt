///|
/// Pre-render phase ① (port of `base.preRenderRemove` at PriorityEarly):
/// drop all nodes whose tag type resolves to Remove, then merge text nodes
/// that became adjacent.
fn pre_render_remove(doc : @dom.Node) -> Unit {
  fn finder(node : @dom.Node) {
    if @domext.tag_type(@domext.node_name(node)) is Some(Remove) {
      @domext.remove_node(node)
      return
    }
    for child in node.children.copy() {
      finder(child)
    }
  }

  finder(doc)
  @domutils.merge_adjacent_text_nodes(doc)
}

///|
fn name_is_bold(node : @dom.Node) -> Bool {
  @domext.node_name(node) is ("strong" | "b")
}

///|
fn name_is_italic(node : @dom.Node) -> Bool {
  @domext.node_name(node) is ("em" | "i")
}

///|
fn name_is_bold_or_italic(node : @dom.Node) -> Bool {
  name_is_bold(node) || name_is_italic(node)
}

///|
fn name_is_strikethrough(node : @dom.Node) -> Bool {
  match @domext.node_name(node) {
    "s" | "del" | "strike" => true
    _ => false
  }
}

///|
fn name_is_both_bold_or_italic(a : @dom.Node, b : @dom.Node) -> Bool {
  (name_is_bold(a) && name_is_bold(b)) ||
  (name_is_italic(a) && name_is_italic(b))
}

///|
fn name_is_both_strikethrough(a : @dom.Node, b : @dom.Node) -> Bool {
  name_is_strikethrough(a) && name_is_strikethrough(b)
}

///|
fn name_is_pre(node : @dom.Node) -> Bool {
  @domext.node_name(node) is "pre"
}

///|
fn name_is_inline_code(node : @dom.Node) -> Bool {
  @domext.node_name(node) is ("code" | "var" | "samp" | "kbd" | "tt")
}

///|
fn name_is_link(node : @dom.Node) -> Bool {
  @domext.node_name(node) is "a"
}

///|
fn name_is_both_link(a : @dom.Node, b : @dom.Node) -> Bool {
  name_is_link(a) && name_is_link(b)
}

///|
fn name_is_heading(node : @dom.Node) -> Bool {
  @domext.is_heading_name(@domext.node_name(node))
}

///|
/// Commonmark DOM normalization passes (port of
/// `commonmark.handlePreRender`), run in the same order as the Go original.
fn pre_render_commonmark(doc : @dom.Node) -> Unit {
  @domutils.rename_fake_spans(doc)

  // Bold / Italic
  @domutils.remove_redundant(doc, name_is_both_bold_or_italic)
  @domutils.merge_adjacent(doc, name_is_bold_or_italic)

  // Strikethrough
  @domutils.remove_redundant(doc, name_is_both_strikethrough)
  @domutils.merge_adjacent(doc, name_is_strikethrough)

  // Code
  @domutils.remove_empty_code(doc)
  @domutils.swap_tags(doc, name_is_inline_code, name_is_pre)
  @domutils.merge_adjacent(doc, name_is_inline_code)
  @domutils.add_space(doc, name_is_bold_or_italic, name_is_inline_code)

  // Link
  @domutils.remove_redundant(doc, name_is_both_link)
  @domutils.swap_tags(doc, name_is_bold_or_italic, name_is_link)

  // Heading
  @domutils.swap_tags(doc, name_is_link, name_is_heading)
  @domutils.leaf_block_alternatives(doc)

  // List
  @domutils.move_list_items(doc)
}

///|
/// The fixed conversion pipeline: pre-render DOM passes, recursive render,
/// post-render text cleanup. Mirrors `Converter.ConvertNode` with the `base`
/// and `commonmark` plugins registered (at their respective priorities).
fn run_pipeline(doc : @dom.Node, options : Options) -> String {
  let ctx = RenderCtx::of(options)

  // ① Pre-Render: remove (early) -> commonmark (standard) -> collapse (late)
  //    -> list end comments (late+100)
  pre_render_remove(doc)
  pre_render_commonmark(doc)
  @collapse.collapse(doc)
  if options.list_end_comment {
    @domutils.add_list_end_comments(doc)
  }

  // ② Render
  let out = StringBuilder()
  render_node(ctx, out, doc)

  // ③ Post-Render: trim (standard) -> unescape (standard+20) ->
  //    code-block newline restore (late)
  let result = out.to_string()
  let result = @textutils.trim_space(result)
  let result = @textutils.trim_consecutive_newlines(result)
  let result = @textutils.trim_unnecessary_hard_line_breaks(result)
  let result = unescape(ctx, result)
  let result = result.replace_all(
    old=@escape.marker_code_block_newline,
    new="\n",
  )
  result
}
