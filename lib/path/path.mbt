///|
/// Structured representation of an HL7 Path expression (e.g. PID-3[0].1.1).
pub(all) struct HL7Path {
  segment_name : String
  segment_index : Int
  field_index : Int
  repetition_index : Int
  component_index : Int
  subcomponent_index : Int
} derive(Eq, Debug)

///|
/// Helper to find index of a character in string.
fn find_char(s : String, target : Char) -> Int {
  let chars = s.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    if chars[i] == target {
      return i
    }
    i = i + 1
  }
  -1
}

///|
/// Helper to parse integer string safely.
fn parse_int(s : String) -> Int {
  let mut res = 0
  let chars = s.to_array()
  let mut i = 0
  while i < chars.length() {
    let c = chars[i]
    if c >= '0' && c <= '9' {
      res = res * 10 + (c.to_int() - '0'.to_int())
    }
    i = i + 1
  }
  res
}

///|
/// Parses an HL7 Path string expression into HL7Path struct.
/// Formats supported: "PID-3", "PID-3.1", "PID-3.1.2", "OBX[1]-5[0].1"
pub fn parse_path(path_str : String) -> Result[HL7Path, @types.HL7Error] {
  let dash_idx = find_char(path_str, '-')
  if dash_idx == -1 {
    return Err(
      @types.HL7Error::PathSyntaxError(
        "Missing '-' segment/field separator in " + path_str,
      ),
    )
  }
  let seg_part = path_str[0:dash_idx].to_owned()
  let rest_part = path_str[dash_idx + 1:].to_owned()

  let mut seg_name = seg_part
  let mut seg_idx = -1
  if seg_part.contains("[") && seg_part.contains("]") {
    let b1 = find_char(seg_part, '[')
    let b2 = find_char(seg_part, ']')
    if b1 != -1 && b2 > b1 {
      seg_name = seg_part[0:b1].to_owned()
      seg_idx = parse_int(seg_part[b1 + 1:b2].to_owned())
    }
  }

  let mut field_idx = 0
  let mut rep_idx = 0
  let mut comp_idx = 0
  let mut subcomp_idx = 0

  let dots = Array::new()
  let chars = rest_part.to_array()
  let mut start = 0
  let mut i = 0
  while i < chars.length() {
    if chars[i] == '.' {
      dots.push(rest_part[start:i].to_owned())
      start = i + 1
    }
    i = i + 1
  }
  dots.push(rest_part[start:chars.length()].to_owned())

  if dots.length() >= 1 {
    let f_str = dots[0]
    if f_str.contains("[") && f_str.contains("]") {
      let b1 = find_char(f_str, '[')
      let b2 = find_char(f_str, ']')
      if b1 != -1 && b2 > b1 {
        field_idx = parse_int(f_str[0:b1].to_owned())
        rep_idx = parse_int(f_str[b1 + 1:b2].to_owned())
      }
    } else {
      field_idx = parse_int(f_str)
    }
  }
  if dots.length() >= 2 {
    comp_idx = parse_int(dots[1])
  }
  if dots.length() >= 3 {
    subcomp_idx = parse_int(dots[2])
  }

  Ok({
    segment_name: seg_name,
    segment_index: seg_idx,
    field_index: field_idx,
    repetition_index: rep_idx,
    component_index: comp_idx,
    subcomponent_index: subcomp_idx,
  })
}

///|
/// Finds all segments matching segment_name in message.
pub fn find_segments(
  msg : @types.Message,
  seg_name : String,
) -> Array[@types.Segment] {
  let res = Array::new()
  for seg in msg.segments {
    if seg.name == seg_name {
      res.push(seg)
    }
  }
  res
}

///|
/// Retrieves single field string value matching path in message (returns empty string if not found).
pub fn get_value(msg : @types.Message, path_str : String) -> String {
  let path = match parse_path(path_str) {
    Ok(p) => p
    Err(_) => return ""
  }
  let matching_segs = find_segments(msg, path.segment_name)
  if matching_segs.length() == 0 {
    return ""
  }
  let seg_target_idx = if path.segment_index >= 0 {
    path.segment_index
  } else {
    0
  }
  if seg_target_idx >= matching_segs.length() {
    return ""
  }
  let seg = matching_segs[seg_target_idx]
  let target_field_array_idx = if path.field_index > 0 {
    path.field_index - 1
  } else {
    0
  }
  if target_field_array_idx >= seg.fields.length() {
    return ""
  }
  let field = seg.fields[target_field_array_idx]
  if path.repetition_index >= field.items.length() {
    return ""
  }
  let item = field.items[path.repetition_index]
  if path.component_index <= 0 {
    // Return full item composite representation
    let buf = StringBuilder::new()
    let mut first = true
    for comp in item.components {
      if !first {
        buf.write_char(msg.delimiters.comp_sep)
      }
      first = false
      match comp {
        SimpleComp(s) => buf.write_string(s)
        SubComponents(subs) => {
          let mut sub_first = true
          for sub in subs {
            if !sub_first {
              buf.write_char(msg.delimiters.subcomp_sep)
            }
            sub_first = false
            buf.write_string(sub)
          }
        }
      }
    }
    return buf.to_string()
  }
  let comp_idx_0 = path.component_index - 1
  if comp_idx_0 >= item.components.length() {
    return ""
  }
  let comp = item.components[comp_idx_0]
  match comp {
    SimpleComp(s) => if path.subcomponent_index <= 0 { s } else { "" }
    SubComponents(subs) =>
      if path.subcomponent_index <= 0 {
        let buf = StringBuilder::new()
        let mut first = true
        for sub in subs {
          if !first {
            buf.write_char(msg.delimiters.subcomp_sep)
          }
          first = false
          buf.write_string(sub)
        }
        buf.to_string()
      } else {
        let sub_idx_0 = path.subcomponent_index - 1
        if sub_idx_0 < subs.length() {
          subs[sub_idx_0]
        } else {
          ""
        }
      }
  }
}

///|
/// Retrieves all string values matching repeated path expressions across all segments.
pub fn get_values(msg : @types.Message, path_str : String) -> Array[String] {
  let res = Array::new()
  let path = match parse_path(path_str) {
    Ok(p) => p
    Err(_) => return res
  }
  let matching_segs = find_segments(msg, path.segment_name)
  let mut s_idx = 0
  while s_idx < matching_segs.length() {
    if path.segment_index < 0 || path.segment_index == s_idx {
      let seg = matching_segs[s_idx]
      let target_field_array_idx = if path.field_index > 0 {
        path.field_index - 1
      } else {
        0
      }
      if target_field_array_idx < seg.fields.length() {
        let field = seg.fields[target_field_array_idx]
        let mut r_idx = 0
        while r_idx < field.items.length() {
          let single_path = path_str + "[" + r_idx.to_string() + "]"
          let val = get_value(msg, single_path)
          if val.length() > 0 {
            res.push(val)
          }
          r_idx = r_idx + 1
        }
      }
    }
    s_idx = s_idx + 1
  }
  res
}

///|
/// Convenience helper to parse raw HL7 message text and extract value matching path.
pub fn get_value_from_raw(raw_text : String, path_str : String) -> String {
  match @parser.parse_message(raw_text) {
    Ok(msg) => get_value(msg, path_str)
    Err(_) => ""
  }
}
