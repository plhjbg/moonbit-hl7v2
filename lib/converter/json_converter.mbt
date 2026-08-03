///|
/// Converts string value into JSON escaped string.
fn json_escape(s : String) -> String {
  let buf = StringBuilder::new()
  let chars = s.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let ch = chars[i]
    if ch == '"' {
      buf.write_string("\\\"")
    } else if ch == '\\' {
      buf.write_string("\\\\")
    } else if ch == '\n' {
      buf.write_string("\\n")
    } else if ch == '\r' {
      buf.write_string("\\r")
    } else if ch == '\t' {
      buf.write_string("\\t")
    } else {
      buf.write_char(ch)
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Converts HL7 Message AST into JSON representation string.
pub fn to_json_string(msg : @types.Message) -> String {
  let buf = StringBuilder::new()
  buf.write_string("{\n")
  buf.write_string("  \"delimiters\": \"" + json_escape(msg.delimiters.to_summary()) + "\",\n")
  buf.write_string("  \"segments\": [\n")
  let mut seg_first = true
  for seg in msg.segments {
    if !seg_first {
      buf.write_string(",\n")
    }
    seg_first = false
    buf.write_string("    {\n")
    buf.write_string("      \"name\": \"" + json_escape(seg.name) + "\",\n")
    buf.write_string("      \"fields\": [\n")
    let mut field_first = true
    for field in seg.fields {
      if !field_first {
        buf.write_string(",\n")
      }
      field_first = false
      buf.write_string("        [\n")
      let mut item_first = true
      for item in field.items {
        if !item_first {
          buf.write_string(",\n")
        }
        item_first = false
        buf.write_string("          [\n")
        let mut comp_first = true
        for comp in item.components {
          if !comp_first {
            buf.write_string(",\n")
          }
          comp_first = false
          match comp {
            SimpleComp(s) => buf.write_string("            \"" + json_escape(s) + "\"")
            SubComponents(subs) => {
              buf.write_string("            [\n")
              let mut sub_first = true
              for sub in subs {
                if !sub_first {
                  buf.write_string(",\n")
                }
                sub_first = false
                buf.write_string("              \"" + json_escape(sub) + "\"")
              }
              buf.write_string("\n            ]")
            }
          }
        }
        buf.write_string("\n          ]")
      }
      buf.write_string("\n        ]")
    }
    buf.write_string("\n      ]\n")
    buf.write_string("    }")
  }
  buf.write_string("\n  ]\n")
  buf.write_string("}")
  buf.to_string()
}

///|
/// Convenience entry: Converts raw HL7 text string into JSON string representation.
pub fn to_json_from_raw(raw_text : String) -> String {
  match @parser.parse_message(raw_text) {
    Ok(msg) => to_json_string(msg)
    Err(e) => "{\"error\": \"" + json_escape(e.to_formatted_string()) + "\"}"
  }
}
