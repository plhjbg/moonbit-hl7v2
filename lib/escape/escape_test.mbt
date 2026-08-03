test "escape decode basic delimiters" {
  let d = @types.Delimiters::default()
  let raw = "Blood\\S\\Pressure\\F\\Test"
  let decoded = decode(raw, d)
  assert_eq(decoded, "Blood^Pressure|Test")
}

test "escape decode hex bytes and line break" {
  let d = @types.Delimiters::default()
  let raw = "Line 1\\.br\\Line 2\\X0D\\CarriageReturn"
  let decoded = decode(raw, d)
  assert_eq(decoded, "Line 1\nLine 2\rCarriageReturn")
}

test "escape encode roundtrip" {
  let d = @types.Delimiters::default()
  let original = "Field|Comp^Rep~Esc\\Sub&Text"
  let encoded = encode(original, d)
  assert_eq(encoded, "Field\\F\\Comp\\S\\Rep\\R\\Esc\\E\\Sub\\T\\Text")
  let roundtrip = decode(encoded, d)
  assert_eq(roundtrip, original)
}

test "needs_escape predicate" {
  let d = @types.Delimiters::default()
  assert_true(needs_escape("Hello|World", d))
  assert_false(needs_escape("NormalText123", d))
}
