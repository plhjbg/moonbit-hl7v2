///|
/// Type of structural difference detected between two HL7 messages.
pub(all) enum DiffKind {
  SegmentAdded(String)
  SegmentDeleted(String)
  FieldValueChanged(String, String, String)
} derive(Eq, Debug)

///|
/// Aggregate diff result structure.
pub(all) struct DiffResult {
  diffs : Array[DiffKind]
} derive(Eq, Debug)

///|
/// Returns true if differences exist between the messages.
pub fn DiffResult::has_diff(self : DiffResult) -> Bool {
  self.diffs.length() > 0
}

///|
/// Formats diff result as a readable text summary.
pub fn DiffResult::to_summary(self : DiffResult) -> String {
  if self.diffs.length() == 0 {
    return "Messages are structurally identical."
  }
  let buf = StringBuilder::new()
  buf.write_string("Differences found (" + self.diffs.length().to_string() + "):\n")
  for d in self.diffs {
    match d {
      SegmentAdded(s) => buf.write_string("  [+] Segment Added: " + s + "\n")
      SegmentDeleted(s) => buf.write_string("  [-] Segment Deleted: " + s + "\n")
      FieldValueChanged(path, old_v, new_v) =>
        buf.write_string("  [*] Field " + path + ": '" + old_v + "' -> '" + new_v + "'\n")
    }
  }
  buf.to_string()
}

///|
/// Compares two HL7 Message ASTs and identifies segment and field value deltas.
pub fn diff_messages(msg1 : @types.Message, msg2 : @types.Message) -> DiffResult {
  let diffs = Array::new()
  let segs1 = msg1.segments
  let segs2 = msg2.segments
  let seg_type_counts : Map[String, Int] = Map([])

  let mut i = 0
  let len1 = segs1.length()
  let len2 = segs2.length()
  while i < len1 && i < len2 {
    let s1 = segs1[i]
    let s2 = segs2[i]
    let count = match seg_type_counts.get(s1.name) {
      Some(c) => c
      None => 0
    }
    seg_type_counts.set(s1.name, count + 1)
    let seg_prefix = s1.name + "[" + count.to_string() + "]"

    if s1.name != s2.name {
      diffs.push(DiffKind::SegmentDeleted(s1.name + "[" + i.to_string() + "]"))
      diffs.push(DiffKind::SegmentAdded(s2.name + "[" + i.to_string() + "]"))
    } else {
      // Compare fields
      let f_len1 = s1.fields.length()
      let f_len2 = s2.fields.length()
      let max_f = if f_len1 > f_len2 { f_len1 } else { f_len2 }
      let mut f = 1
      while f <= max_f {
        let p = seg_prefix + "-" + f.to_string()
        let val1 = @path.get_value(msg1, p)
        let val2 = @path.get_value(msg2, p)
        if val1 != val2 {
          diffs.push(DiffKind::FieldValueChanged(p, val1, val2))
        }
        f = f + 1
      }
    }
    i = i + 1
  }

  while i < len1 {
    diffs.push(DiffKind::SegmentDeleted(segs1[i].name + "[" + i.to_string() + "]"))
    i = i + 1
  }

  let mut j = i
  while j < len2 {
    diffs.push(DiffKind::SegmentAdded(segs2[j].name + "[" + j.to_string() + "]"))
    j = j + 1
  }

  { diffs, }
}

///|
/// Convenience entry: Compares two raw HL7 text payloads.
pub fn diff_raw(raw1 : String, raw2 : String) -> Result[DiffResult, @types.HL7Error] {
  let m1 = match @parser.parse_message(raw1) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  let m2 = match @parser.parse_message(raw2) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  Ok(diff_messages(m1, m2))
}
