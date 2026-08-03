///|
/// High-level ADT (Admit, Discharge, Transfer) Message structure.
pub(all) struct ADTMessage {
  msh : @segments.MSHSegment
  evn : @segments.EVNSegment?
  pid : @segments.PIDSegment
  pv1 : @segments.PV1Segment?
  diagnoses : Array[@segments.DG1Segment]
  allergies : Array[@segments.AL1Segment]
  next_of_kin : Array[@segments.NK1Segment]
} derive(Eq, Debug)

///|
/// Constructs ADTMessage model from AST Message.
pub fn ADTMessage::from_message(
  msg : @types.Message,
) -> Result[ADTMessage, @types.HL7Error] {
  if msg.segments.length() == 0 {
    return Err(@types.HL7Error::InvalidHeader("Empty message"))
  }
  let msh = match @segments.MSHSegment::from_segment(msg.segments[0]) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  let mut evn : @segments.EVNSegment? = None
  let mut pid_opt : @segments.PIDSegment? = None
  let mut pv1 : @segments.PV1Segment? = None
  let diagnoses = Array::new()
  let allergies = Array::new()
  let next_of_kin = Array::new()

  for seg in msg.segments {
    if seg.name == "EVN" {
      match @segments.EVNSegment::from_segment(seg) {
        Ok(e) => evn = Some(e)
        Err(_) => ()
      }
    } else if seg.name == "PID" {
      match @segments.PIDSegment::from_segment(seg) {
        Ok(p) => pid_opt = Some(p)
        Err(_) => ()
      }
    } else if seg.name == "PV1" {
      match @segments.PV1Segment::from_segment(seg) {
        Ok(v) => pv1 = Some(v)
        Err(_) => ()
      }
    } else if seg.name == "DG1" {
      match @segments.DG1Segment::from_segment(seg) {
        Ok(d) => diagnoses.push(d)
        Err(_) => ()
      }
    } else if seg.name == "AL1" {
      match @segments.AL1Segment::from_segment(seg) {
        Ok(a) => allergies.push(a)
        Err(_) => ()
      }
    } else if seg.name == "NK1" {
      match @segments.NK1Segment::from_segment(seg) {
        Ok(n) => next_of_kin.push(n)
        Err(_) => ()
      }
    }
  }

  let pid = match pid_opt {
    Some(p) => p
    None => return Err(@types.HL7Error::MissingField("PID", 1))
  }

  Ok({ msh, evn, pid, pv1, diagnoses, allergies, next_of_kin })
}

///|
/// Parses raw string directly into ADTMessage model.
pub fn parse_adt_from_raw(
  raw_text : String,
) -> Result[ADTMessage, @types.HL7Error] {
  let msg = match @parser.parse_message(raw_text) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  ADTMessage::from_message(msg)
}
