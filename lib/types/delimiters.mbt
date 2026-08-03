///|
/// HL7 v2 Standard Segment and Field Delimiters.
/// MSH-1 is Field Separator (|), MSH-2 is Encoding Characters (^~\&).
pub(all) struct Delimiters {
  field_sep : Char
  comp_sep : Char
  rep_sep : Char
  escape_char : Char
  subcomp_sep : Char
  segment_sep : String
} derive(Eq, Debug)

///|
/// Creates the standard HL7 v2 default delimiter configuration:
/// Field separator: '|'
/// Component separator: '^'
/// Repetition separator: '~'
/// Escape character: '\'
/// Subcomponent separator: '&'
/// Segment separator: "\r"
pub fn Delimiters::default() -> Delimiters {
  {
    field_sep: '|',
    comp_sep: '^',
    rep_sep: '~',
    escape_char: '\\',
    subcomp_sep: '&',
    segment_sep: "\r",
  }
}

///|
/// Creates a custom delimiter configuration with specified separator characters.
pub fn Delimiters::custom(
  field_sep : Char,
  comp_sep : Char,
  rep_sep : Char,
  escape_char : Char,
  subcomp_sep : Char,
  segment_sep : String
) -> Delimiters {
  {
    field_sep,
    comp_sep,
    rep_sep,
    escape_char,
    subcomp_sep,
    segment_sep,
  }
}

///|
/// Returns MSH-2 encoding characters string (e.g. "^~\\&").
pub fn Delimiters::encoding_characters(self : Delimiters) -> String {
  let buf = StringBuilder::new()
  buf.write_char(self.comp_sep)
  buf.write_char(self.rep_sep)
  buf.write_char(self.escape_char)
  buf.write_char(self.subcomp_sep)
  buf.to_string()
}

///|
/// Validates whether the delimiter characters are distinct and valid.
pub fn Delimiters::is_valid(self : Delimiters) -> Bool {
  let f = self.field_sep
  let c = self.comp_sep
  let r = self.rep_sep
  let e = self.escape_char
  let s = self.subcomp_sep
  f != c && f != r && f != e && f != s &&
  c != r && c != e && c != s &&
  r != e && r != s &&
  e != s
}

///|
/// Formats Delimiters as a human-readable summary string.
pub fn Delimiters::to_summary(self : Delimiters) -> String {
  "Field=" +
  self.field_sep.to_string() +
  ", Comp=" +
  self.comp_sep.to_string() +
  ", Rep=" +
  self.rep_sep.to_string() +
  ", Escape=" +
  self.escape_char.to_string() +
  ", Subcomp=" +
  self.subcomp_sep.to_string()
}
