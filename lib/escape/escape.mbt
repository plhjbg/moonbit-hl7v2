///|
/// Helper to convert hex char to integer.
fn hex_val(ch : Char) -> Int {
  if ch >= '0' && ch <= '9' {
    ch.to_int() - '0'.to_int()
  } else if ch >= 'A' && ch <= 'F' {
    ch.to_int() - 'A'.to_int() + 10
  } else if ch >= 'a' && ch <= 'f' {
    ch.to_int() - 'a'.to_int() + 10
  } else {
    -1
  }
}

///|
/// Decodes HL7 escape sequences in string given delimiter configuration.
/// Standard sequences: \F\, \S\, \R\, \E\, \T\, \X20\, \X0D\, \X0A\ etc.
pub fn decode(input : String, delimiters : @types.Delimiters) -> String {
  let esc = delimiters.escape_char
  let esc_str = esc.to_string()
  if !input.contains(esc_str) {
    return input
  }
  let chars = input.to_array()
  let buf = StringBuilder::new()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let ch = chars[i]
    if ch == esc {
      // Find closing escape character
      let mut end_idx = -1
      let mut j = i + 1
      while j < len {
        if chars[j] == esc {
          end_idx = j
          break
        }
        j = j + 1
      }
      if end_idx != -1 {
        let seq = input[i + 1:end_idx].to_owned()
        if seq == "F" {
          buf.write_char(delimiters.field_sep)
          i = end_idx + 1
          continue
        } else if seq == "S" {
          buf.write_char(delimiters.comp_sep)
          i = end_idx + 1
          continue
        } else if seq == "R" {
          buf.write_char(delimiters.rep_sep)
          i = end_idx + 1
          continue
        } else if seq == "E" {
          buf.write_char(delimiters.escape_char)
          i = end_idx + 1
          continue
        } else if seq == "T" {
          buf.write_char(delimiters.subcomp_sep)
          i = end_idx + 1
          continue
        } else if seq.has_prefix("X") {
          let hex_part = seq[1:].to_owned()
          let hex_chars = hex_part.to_array()
          if hex_chars.length() == 2 {
            let h1 = hex_val(hex_chars[0])
            let h2 = hex_val(hex_chars[1])
            if h1 != -1 && h2 != -1 {
              let code = h1 * 16 + h2
              buf.write_char(code.unsafe_to_char())
              i = end_idx + 1
              continue
            }
          } else if hex_chars.length() == 4 {
            let h1 = hex_val(hex_chars[0])
            let h2 = hex_val(hex_chars[1])
            let h3 = hex_val(hex_chars[2])
            let h4 = hex_val(hex_chars[3])
            if h1 != -1 && h2 != -1 && h3 != -1 && h4 != -1 {
              let code = h1 * 4096 + h2 * 256 + h3 * 16 + h4
              buf.write_char(code.unsafe_to_char())
              i = end_idx + 1
              continue
            }
          }
        } else if seq == ".br" {
          buf.write_string("\n")
          i = end_idx + 1
          continue
        }
        // Unrecognized escape sequence, output as-is
        buf.write_char(ch)
        i = i + 1
      } else {
        buf.write_char(ch)
        i = i + 1
      }
    } else {
      buf.write_char(ch)
      i = i + 1
    }
  }
  buf.to_string()
}

///|
/// Encodes raw text into HL7 escaped string given delimiter configuration.
pub fn encode(input : String, delimiters : @types.Delimiters) -> String {
  let buf = StringBuilder::new()
  let chars = input.to_array()
  let len = chars.length()
  let esc = delimiters.escape_char
  let esc_str = esc.to_string()
  let mut i = 0
  while i < len {
    let ch = chars[i]
    if ch == delimiters.field_sep {
      buf.write_string(esc_str + "F" + esc_str)
    } else if ch == delimiters.comp_sep {
      buf.write_string(esc_str + "S" + esc_str)
    } else if ch == delimiters.rep_sep {
      buf.write_string(esc_str + "R" + esc_str)
    } else if ch == delimiters.escape_char {
      buf.write_string(esc_str + "E" + esc_str)
    } else if ch == delimiters.subcomp_sep {
      buf.write_string(esc_str + "T" + esc_str)
    } else if ch == '\r' {
      buf.write_string(esc_str + "X0D" + esc_str)
    } else if ch == '\n' {
      buf.write_string(esc_str + ".br" + esc_str)
    } else {
      buf.write_char(ch)
    }
    i = i + 1
  }
  buf.to_string()
}

///|
/// Checks if text contains characters that require HL7 escaping.
pub fn needs_escape(input : String, delimiters : @types.Delimiters) -> Bool {
  let chars = input.to_array()
  let len = chars.length()
  let mut i = 0
  while i < len {
    let ch = chars[i]
    if ch == delimiters.field_sep ||
      ch == delimiters.comp_sep ||
      ch == delimiters.rep_sep ||
      ch == delimiters.escape_char ||
      ch == delimiters.subcomp_sep ||
      ch == '\r' ||
      ch == '\n' {
      return true
    }
    i = i + 1
  }
  false
}
