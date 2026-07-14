///|
test "render table: spans are bounded" {
  inspect(parse_table_span("1000"), content="1000")
  inspect(parse_table_span("1001"), content="1000")
  inspect(parse_table_span("999999999999999999999999"), content="1000")
  inspect(parse_table_span("65534", max_value=65534), content="65534")
  inspect(parse_table_span("70000", max_value=65534), content="65534")
  let budget : TableSpanBudget = { remaining: MAX_TABLE_SPAN_EXPANSION }
  debug_inspect(take_table_spans(1000, 65534, budget), content="(1000, 1)")
  inspect(budget.remaining, content="1")
  debug_inspect(take_table_spans(1000, 65534, budget), content="(2, 1)")
  inspect(budget.remaining, content="0")
}
