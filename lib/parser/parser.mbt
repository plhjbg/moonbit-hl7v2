///|
/// Parses subcomponent string into Component AST node.
pub fn parse_component(comp_text : String, delimiters : @types.Delimiters) -> @types.Component {
  let subcomp_sep = delimiters.subcomp_sep
  if comp_text.contains(subcomp_sep.to_string()) {
    let raw_subs = split_by_char(comp_text, subcomp_sep)
    let decoded_subs = Array::new()
    for sub in raw_subs {
      decoded_subs.push(@escape.decode(sub, delimiters))
    }
    @types.Component::SubComponents(decoded_subs)
  } else {
    @types.Component::SimpleComp(@escape.decode(comp_text, delimiters))
  }
}

///|
/// Parses field item component string into FieldItem AST node.
pub fn parse_field_item(item_text : String, delimiters : @types.Delimiters) -> @types.FieldItem {
  let comp_sep = delimiters.comp_sep
  let raw_comps = split_by_char(item_text, comp_sep)
  let components = Array::new()
  for comp in raw_comps {
    components.push(parse_component(comp, delimiters))
  }
  @types.FieldItem::make(components)
}

///|
/// Parses raw field text (including repetition ~ separator) into Field AST node.
pub fn parse_field(field_text : String, delimiters : @types.Delimiters) -> @types.Field {
  let rep_sep = delimiters.rep_sep
  let raw_items = split_by_char(field_text, rep_sep)
  let items = Array::new()
  for item_text in raw_items {
    items.push(parse_field_item(item_text, delimiters))
  }
  @types.Field::make(items)
}

///|
/// Parses a single segment line string into Segment AST node.
pub fn parse_segment(line : String, delimiters : @types.Delimiters, line_no : Int) -> Result[@types.Segment, @types.HL7Error] {
  if line.length() < 3 {
    return Err(@types.HL7Error::InvalidSegment("Segment line too short", line_no))
  }
  let seg_name = line[0:3].to_owned()
  let fields = Array::new()
  if seg_name == "MSH" {
    // MSH-1 is field separator (|)
    fields.push(@types.Field::from_string(delimiters.field_sep.to_string()))
    // MSH-2 is encoding characters (^~\&)
    fields.push(@types.Field::from_string(delimiters.encoding_characters()))
    let raw_fields = split_by_char(line, delimiters.field_sep)
    let mut i = 2
    while i < raw_fields.length() {
      fields.push(parse_field(raw_fields[i], delimiters))
      i = i + 1
    }
  } else {
    let raw_fields = split_by_char(line, delimiters.field_sep)
    let mut i = 1
    while i < raw_fields.length() {
      fields.push(parse_field(raw_fields[i], delimiters))
      i = i + 1
    }
  }
  Ok(@types.Segment::make(seg_name, fields))
}

///|
/// Main entry: Parses raw HL7 v2 message text into Message AST structure.
pub fn parse_message(raw_text : String) -> Result[@types.Message, @types.HL7Error] {
  let delimiters = match extract_msh_delimiters(raw_text) {
    Ok(d) => d
    Err(e) => return Err(e)
  }
  let lines = split_segments(raw_text)
  let segments = Array::new()
  let mut line_no = 1
  for line in lines {
    match parse_segment(line, delimiters, line_no) {
      Ok(seg) => segments.push(seg)
      Err(e) => return Err(e)
    }
    line_no = line_no + 1
  }
  Ok({ delimiters, segments })
}

///|
/// Parses multiple HL7 messages from a batch string payload separated by empty lines or MSH headers.
pub fn parse_batch(batch_text : String) -> Array[Result[@types.Message, @types.HL7Error]] {
  let results = Array::new()
  let lines = split_segments(batch_text)
  let current_msg_lines = StringBuilder::new()
  let mut in_msg = false
  for line in lines {
    if line.has_prefix("MSH") {
      if in_msg {
        let msg_str = current_msg_lines.to_string()
        if msg_str.trim().length() > 0 {
          results.push(parse_message(msg_str))
        }
        current_msg_lines.reset()
      }
      in_msg = true
      current_msg_lines.write_string(line + "\r")
    } else if in_msg {
      current_msg_lines.write_string(line + "\r")
    }
  }
  if in_msg {
    let msg_str = current_msg_lines.to_string()
    if msg_str.trim().length() > 0 {
      results.push(parse_message(msg_str))
    }
  }
  results
}
