///|
/// Helper to split string by a delimiter character without splitting on escape sequences.
pub fn split_by_char(text : String, sep : Char) -> Array[String] {
  let result = Array::new()
  let chars = text.to_array()
  let len = chars.length()
  let mut start = 0
  let mut i = 0
  while i < len {
    if chars[i] == sep {
      let part = text[start:i].to_owned()
      result.push(part)
      start = i + 1
    }
    i = i + 1
  }
  let last_part = text[start:len].to_owned()
  result.push(last_part)
  result
}

///|
/// Splits HL7 v2 raw text stream into individual segment lines.
/// Normalizes \r\n, \r, and \n line endings.
pub fn split_segments(raw_text : String) -> Array[String] {
  let result = Array::new()
  let lines = split_by_char(raw_text, '\r')
  for line in lines {
    let sublines = split_by_char(line, '\n')
    for sub in sublines {
      let trimmed = sub.trim()
      if trimmed.length() > 0 {
        result.push(trimmed.to_owned())
      }
    }
  }
  result
}

///|
/// Extracts MSH delimiters from raw message text or first line.
/// Returns (Delimiters, error_opt)
pub fn extract_msh_delimiters(
  raw_text : String,
) -> Result[@types.Delimiters, @types.HL7Error] {
  let lines = split_segments(raw_text)
  if lines.length() == 0 {
    return Err(@types.HL7Error::InvalidHeader("Empty HL7 message payload"))
  }
  let first_line = lines[0]
  if !first_line.has_prefix("MSH") {
    return Err(
      @types.HL7Error::InvalidHeader(
        "First segment must be MSH, found: " + first_line[0:3].to_owned(),
      ),
    )
  }
  let chars = first_line.to_array()
  if chars.length() < 8 {
    return Err(
      @types.HL7Error::InvalidHeader("MSH header line too short for delimiters"),
    )
  }
  let field_sep = chars[3]
  let comp_sep = chars[4]
  let rep_sep = chars[5]
  let escape_char = chars[6]
  let subcomp_sep = chars[7]
  let delims = @types.Delimiters::custom(
    field_sep, comp_sep, rep_sep, escape_char, subcomp_sep, "\r",
  )
  if !delims.is_valid() {
    return Err(
      @types.HL7Error::InvalidHeader(
        "Invalid or duplicate MSH delimiter configuration",
      ),
    )
  }
  Ok(delims)
}
