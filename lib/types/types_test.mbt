///|
test "delimiters default and custom" {
  let d = Delimiters::default()
  assert_eq(d.field_sep, '|')
  assert_eq(d.comp_sep, '^')
  assert_eq(d.rep_sep, '~')
  assert_eq(d.escape_char, '\\')
  assert_eq(d.subcomp_sep, '&')
  assert_true(d.is_valid())
  assert_eq(d.encoding_characters(), "^~\\&")
}

///|
test "hl7 timestamp formatting" {
  let ts : HL7Timestamp = {
    year: 2026,
    month: 8,
    day: 3,
    hour: 14,
    minute: 30,
    second: 45,
    millisecond: 123,
    timezone: "+0800",
    precision: Millisecond,
  }
  let s = ts.to_hl7_string()
  assert_eq(s, "20260803143045.123+0800")
}

///|
test "person name display" {
  let pn = PersonName::make("Smith", "John", "Edward")
  assert_eq(pn.to_display_name(), "John Edward Smith")
}

///|
test "ast field empty check" {
  let f_empty = Field::from_string("")
  assert_true(f_empty.is_empty())
  let f_val = Field::from_string("hello")
  assert_false(f_val.is_empty())
}

///|
test "hl7 error formatting" {
  let err = HL7Error::MissingField("MSH", 9)
  assert_eq(
    err.to_formatted_string(),
    "[HL7 Field Error] Missing required field MSH-9",
  )
}
