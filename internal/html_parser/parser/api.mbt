// Adapted from html_parser to expose only string parsing to the embedded package.

///|
/// Parse a full HTML document from a string.
///
/// The returned root is a document node with the usual `html`, `head`, and
/// `body` scaffolding. Set `collect_errors=true` to keep parse diagnostics and
/// `strict=true` to raise `@core.HtmlError::StrictMode` on the first parse error.
pub fn parse(
  html : StringView,
  collect_errors~ : Bool = false,
  strict~ : Bool = false,
  scripting_enabled~ : Bool = true,
  xml_coercion~ : Bool = false,
  track_node_locations~ : Bool = false,
  iframe_srcdoc~ : Bool = false,
) -> ParsedHtml raise @core.HtmlError {
  let root = @dom.document()
  let parser = Parser(
    html,
    root,
    scripting_enabled~,
    xml_coercion~,
    track_node_locations~,
    iframe_srcdoc~,
  )
  parser.deferred_initial_doctype_error = parser.report_initial_doctype_error()
  parser.parse_all()
  parser.flush_deferred_initial_doctype_error()
  parser.report_eof_tree_errors()
  scaffold_document(
    root,
    parser.foster_parented_texts,
    parser.forced_body_nodes,
    parser.after_body_comments,
    parser.after_html_comments,
    parser.after_head_whitespace,
  )
  parser.apply_pending_document_html_attrs()
  parser.apply_pending_document_body_attrs()
  append_post_body_html_children(root, parser.post_body_html_children)
  normalize_tables(root)
  populate_selectedcontent(root)
  let errors = if collect_errors || strict { parser.errors } else { [] }
  if strict && !parser.errors.is_empty() {
    raise StrictMode(parser.errors[0])
  }
  { root, errors, }
}

///|
/// Parse an HTML fragment from a string.
///
/// `context` controls the fragment context element used by the tree builder.
/// Without a context, the fragment is parsed into a generic fragment root.
/// The remaining options have the same meaning as in `parse`.
pub fn parse_fragment(
  html : StringView,
  context? : FragmentContext,
  collect_errors~ : Bool = false,
  strict~ : Bool = false,
  scripting_enabled~ : Bool = true,
  xml_coercion~ : Bool = false,
  track_node_locations~ : Bool = false,
  iframe_srcdoc~ : Bool = false,
) -> ParsedHtml raise @core.HtmlError {
  let root = @dom.fragment()
  let parser = Parser(
    html,
    root,
    scripting_enabled~,
    xml_coercion~,
    track_node_locations~,
    iframe_srcdoc~,
  )
  match context {
    Some(fragment_context) =>
      if !parser.parse_fragment_context(fragment_context) {
        parser.parse_all()
      }
    None => parser.parse_all()
  }
  parser.report_eof_tree_errors()
  normalize_tables(root)
  populate_selectedcontent(root)
  let errors = if collect_errors || strict { parser.errors } else { [] }
  if strict && !parser.errors.is_empty() {
    raise StrictMode(parser.errors[0])
  }
  { root, errors, }
}
