///|
/// Serializes a Component AST node into raw HL7 component string.
pub fn serialize_component(comp : @types.Component, delimiters : @types.Delimiters) -> String {
  match comp {
    SimpleComp(s) => @escape.encode(s, delimiters)
    SubComponents(subs) => {
      let buf = StringBuilder::new()
      let mut first = true
      for sub in subs {
        if !first {
          buf.write_char(delimiters.subcomp_sep)
        }
        first = false
        buf.write_string(@escape.encode(sub, delimiters))
      }
      buf.to_string()
    }
  }
}

///|
/// Serializes a FieldItem AST node into raw HL7 component group string.
pub fn serialize_field_item(item : @types.FieldItem, delimiters : @types.Delimiters) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for comp in item.components {
    if !first {
      buf.write_char(delimiters.comp_sep)
    }
    first = false
    buf.write_string(serialize_component(comp, delimiters))
  }
  buf.to_string()
}

///|
/// Serializes a Field AST node (handling ~ repetition separator) into raw field string.
pub fn serialize_field(field : @types.Field, delimiters : @types.Delimiters) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for item in field.items {
    if !first {
      buf.write_char(delimiters.rep_sep)
    }
    first = false
    buf.write_string(serialize_field_item(item, delimiters))
  }
  buf.to_string()
}

///|
/// Serializes a Segment AST node into raw segment line (without segment separator).
pub fn serialize_segment(seg : @types.Segment, delimiters : @types.Delimiters) -> String {
  let buf = StringBuilder::new()
  buf.write_string(seg.name)
  if seg.name == "MSH" {
    // MSH-1 is field_sep, MSH-2 is encoding chars
    buf.write_char(delimiters.field_sep)
    buf.write_string(delimiters.encoding_characters())
    let mut i = 2
    while i < seg.fields.length() {
      buf.write_char(delimiters.field_sep)
      buf.write_string(serialize_field(seg.fields[i], delimiters))
      i = i + 1
    }
  } else {
    for field in seg.fields {
      buf.write_char(delimiters.field_sep)
      buf.write_string(serialize_field(field, delimiters))
    }
  }
  buf.to_string()
}

///|
/// Serializes complete HL7 Message AST back into standard HL7 v2 string with specified line ending.
pub fn serialize_message_with_line_ending(msg : @types.Message, line_ending : String) -> String {
  let buf = StringBuilder::new()
  let mut first = true
  for seg in msg.segments {
    if !first {
      buf.write_string(line_ending)
    }
    first = false
    buf.write_string(serialize_segment(seg, msg.delimiters))
  }
  buf.to_string()
}

///|
/// Serializes HL7 Message AST using default delimiters and carriage return (\r) segment separator.
pub fn serialize_message(msg : @types.Message) -> String {
  serialize_message_with_line_ending(msg, "\r")
}

///|
/// Parses raw HL7 string and re-formats it using standard normalized line endings.
pub fn reformat_raw_hl7(raw_text : String, line_ending : String) -> Result[String, @types.HL7Error] {
  match @parser.parse_message(raw_text) {
    Ok(msg) => Ok(serialize_message_with_line_ending(msg, line_ending))
    Err(e) => Err(e)
  }
}
