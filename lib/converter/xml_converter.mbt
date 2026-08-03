///|
/// Escapes special XML characters (<, >, &, ", ').
fn xml_escape(s : String) -> String {
  let buf = StringBuilder::new()
  let chars = s.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let ch = chars[i]
    if ch == '<' {
      buf.write_string("&lt;")
    } else if ch == '>' {
      buf.write_string("&gt;")
    } else if ch == '&' {
      buf.write_string("&amp;")
    } else if ch == '"' {
      buf.write_string("&quot;")
    } else if ch == '\'' {
      buf.write_string("&apos;")
    } else {
      buf.write_char(ch)
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Converts HL7 Message AST into XML representation string.
pub fn to_xml_string(msg : @types.Message) -> String {
  let buf = StringBuilder::new()
  buf.write_string("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
  buf.write_string("<HL7Message>\n")
  for seg in msg.segments {
    buf.write_string("  <" + seg.name + ">\n")
    let mut f_idx = 1
    for field in seg.fields {
      let f_tag = seg.name + "." + f_idx.to_string()
      buf.write_string("    <" + f_tag + ">\n")
      let mut r_idx = 0
      for item in field.items {
        let mut c_idx = 1
        for comp in item.components {
          let c_tag = f_tag + "." + c_idx.to_string()
          match comp {
            SimpleComp(val) => {
              if val.length() > 0 {
                buf.write_string("      <" + c_tag + ">" + xml_escape(val) + "</" + c_tag + ">\n")
              }
            }
            SubComponents(subs) => {
              let mut sub_idx = 1
              for sub in subs {
                let sub_tag = c_tag + "." + sub_idx.to_string()
                if sub.length() > 0 {
                  buf.write_string("        <" + sub_tag + ">" + xml_escape(sub) + "</" + sub_tag + ">\n")
                }
                sub_idx = sub_idx + 1
              }
            }
          }
          c_idx = c_idx + 1
        }
        r_idx = r_idx + 1
      }
      buf.write_string("    </" + f_tag + ">\n")
      f_idx = f_idx + 1
    }
    buf.write_string("  </" + seg.name + ">\n")
  }
  buf.write_string("</HL7Message>")
  buf.to_string()
}

///|
/// Convenience entry: Converts raw HL7 text string into XML string representation.
pub fn to_xml_from_raw(raw_text : String) -> String {
  match @parser.parse_message(raw_text) {
    Ok(msg) => to_xml_string(msg)
    Err(e) => "<HL7Error>" + xml_escape(e.to_formatted_string()) + "</HL7Error>"
  }
}
