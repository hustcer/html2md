///|
/// Immutable render context threaded through the render pass. State changes
/// (like entering a link) create a derived copy.
priv struct RenderCtx {
  options : Options
  is_inside_link : Bool
}

///|
fn RenderCtx::of(options : Options) -> RenderCtx {
  { options, is_inside_link: false }
}
