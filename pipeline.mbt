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
/// The fixed conversion pipeline: pre-render DOM passes, recursive render,
/// post-render text cleanup. Mirrors `Converter.ConvertNode` with the `base`
/// and `commonmark` plugins registered.
fn run_pipeline(doc : @dom.Node, options : Options) -> String {
  // ① Pre-Render
  pre_render_remove(doc)
  // (P4: commonmark DOM normalization passes run here)
  @collapse.collapse(doc)
  // (P4: list end comments are added here, after collapse)

  // ② Render
  let out = StringBuilder()
  render_node(RenderCtx::of(options), out, doc)

  // ③ Post-Render (trim at PriorityStandard, unescape at +20, marker at Late)
  let result = out.to_string()
  let result = @textutils.trim_space(result)
  let result = @textutils.trim_consecutive_newlines(result)
  let result = @textutils.trim_unnecessary_hard_line_breaks(result)
  // (P5: unescape runs here)
  // (P4: code-block newline markers are restored here)
  result
}
