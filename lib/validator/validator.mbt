///|
/// Helper to check if string is numeric.
fn is_numeric(s : String) -> Bool {
  if s.length() == 0 {
    return false
  }
  let chars = s.to_array()
  let mut i = 0
  let mut has_dot = false
  while i < chars.length() {
    let c = chars[i]
    if c == '-' || c == '+' {
      if i != 0 {
        return false
      }
    } else if c == '.' {
      if has_dot {
        return false
      }
      has_dot = true
    } else if c < '0' || c > '9' {
      return false
    }
    i = i + 1
  }
  true
}

///|
/// Validates an HL7 AST Message according to HL7 v2 standard rules.
pub fn validate_message(msg : @types.Message) -> ValidationReport {
  let issues = Array::new()

  // 1. MSH Header checks
  if msg.segments.length() == 0 {
    issues.push({
      rule_id: "REQ-001",
      severity: Error,
      path: "MSH",
      message: "Message contains no segments",
    })
    return { issues, }
  }

  let first_seg = msg.segments[0]
  if first_seg.name != "MSH" {
    issues.push({
      rule_id: "REQ-002",
      severity: Error,
      path: "MSH",
      message: "First segment must be MSH, found: " + first_seg.name,
    })
  }

  // Check required MSH fields
  let msh_9 = @path.get_value(msg, "MSH-9")
  if msh_9.length() == 0 {
    issues.push({
      rule_id: "REQ-003",
      severity: Error,
      path: "MSH-9",
      message: "MSH-9 Message Type is required",
    })
  }

  let msh_10 = @path.get_value(msg, "MSH-10")
  if msh_10.length() == 0 {
    issues.push({
      rule_id: "REQ-004",
      severity: Error,
      path: "MSH-10",
      message: "MSH-10 Message Control ID is required",
    })
  }

  let msh_11 = @path.get_value(msg, "MSH-11")
  if msh_11.length() == 0 {
    issues.push({
      rule_id: "REQ-005",
      severity: Warning,
      path: "MSH-11",
      message: "MSH-11 Processing ID is missing",
    })
  }

  let msh_12 = @path.get_value(msg, "MSH-12")
  if msh_12.length() == 0 {
    issues.push({
      rule_id: "REQ-006",
      severity: Warning,
      path: "MSH-12",
      message: "MSH-12 Version ID is missing",
    })
  }

  // 2. Segment-level validation
  let mut pid_count = 0
  let seg_type_counts : Map[String, Int] = Map([])
  for seg in msg.segments {
    let count = match seg_type_counts.get(seg.name) {
      Some(c) => c
      None => 0
    }
    seg_type_counts.set(seg.name, count + 1)
    let prefix = seg.name + "[" + count.to_string() + "]"

    if seg.name == "PID" {
      pid_count = pid_count + 1
      let pid_id = @path.get_value(msg, prefix + "-3")
      if pid_id.length() == 0 {
        issues.push({
          rule_id: "PID-001",
          severity: Error,
          path: prefix + "-3",
          message: "PID-3 Patient Identifier List is required",
        })
      }
    } else if seg.name == "OBX" {
      let val_type = @path.get_value(msg, prefix + "-2")
      if val_type.length() == 0 {
        issues.push({
          rule_id: "OBX-001",
          severity: Error,
          path: prefix + "-2",
          message: "OBX-2 Value Type is required",
        })
      }
      let obs_id = @path.get_value(msg, prefix + "-3")
      if obs_id.length() == 0 {
        issues.push({
          rule_id: "OBX-002",
          severity: Error,
          path: prefix + "-3",
          message: "OBX-3 Observation Identifier is required",
        })
      }
      let val = @path.get_value(msg, prefix + "-5")
      if val_type == "NM" && val.length() > 0 {
        if !(is_numeric(val)) {
          issues.push({
            rule_id: "TYPE-NM-001",
            severity: Error,
            path: prefix + "-5",
            message: "OBX-5 value '" + val + "' is not a valid NM numeric value",
          })
        }
      }
    }
  }

  let msg_type = @path.get_value(msg, "MSH-9.1")
  if (msg_type == "ADT" || msg_type == "ORU" || msg_type == "ORM") && pid_count == 0 {
    issues.push({
      rule_id: "STRUCT-001",
      severity: Error,
      path: "PID",
      message: "Message type " + msg_type + " requires at least one PID segment",
    })
  }

  { issues, }
}

///|
/// Convenience entry: Parses raw text and validates HL7 v2 rules.
pub fn validate_raw(raw_text : String) -> ValidationReport {
  match @parser.parse_message(raw_text) {
    Ok(msg) => validate_message(msg)
    Err(e) => {
      let issues = [{
        rule_id: "PARSE-001",
        severity: Error,
        path: "ROOT",
        message: e.to_formatted_string(),
      }]
      { issues, }
    }
  }
}
