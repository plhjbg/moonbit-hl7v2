///|
/// Group of observation results belonging to an observation request (OBR + Array[OBX]).
pub(all) struct ObservationGroup {
  obr : @segments.OBRSegment
  observations : Array[@segments.OBXSegment]
} derive(Eq, Debug)

///|
/// High-level ORU (Unsolicited Observation Result / Lab Results) Message structure.
pub(all) struct ORUMessage {
  msh : @segments.MSHSegment
  pid : @segments.PIDSegment
  pv1 : @segments.PV1Segment?
  groups : Array[ObservationGroup]
} derive(Eq, Debug)

///|
/// Constructs ORUMessage model from AST Message.
pub fn ORUMessage::from_message(
  msg : @types.Message,
) -> Result[ORUMessage, @types.HL7Error] {
  if msg.segments.length() == 0 {
    return Err(@types.HL7Error::InvalidHeader("Empty message"))
  }
  let msh = match @segments.MSHSegment::from_segment(msg.segments[0]) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  let mut pid_opt : @segments.PIDSegment? = None
  let mut pv1 : @segments.PV1Segment? = None
  let groups = Array::new()

  let mut current_obr : @segments.OBRSegment? = None
  let mut current_obxs = Array::new()

  for seg in msg.segments {
    if seg.name == "PID" {
      match @segments.PIDSegment::from_segment(seg) {
        Ok(p) => pid_opt = Some(p)
        Err(_) => ()
      }
    } else if seg.name == "PV1" {
      match @segments.PV1Segment::from_segment(seg) {
        Ok(v) => pv1 = Some(v)
        Err(_) => ()
      }
    } else if seg.name == "OBR" {
      match current_obr {
        Some(obr) => {
          groups.push({ obr, observations: current_obxs })
          current_obxs = Array::new()
        }
        None => ()
      }
      match @segments.OBRSegment::from_segment(seg) {
        Ok(o) => current_obr = Some(o)
        Err(_) => ()
      }
    } else if seg.name == "OBX" {
      match @segments.OBXSegment::from_segment(seg) {
        Ok(ox) => current_obxs.push(ox)
        Err(_) => ()
      }
    }
  }

  match current_obr {
    Some(obr) => groups.push({ obr, observations: current_obxs })
    None => ()
  }

  let pid = match pid_opt {
    Some(p) => p
    None => return Err(@types.HL7Error::MissingField("PID", 1))
  }

  Ok({ msh, pid, pv1, groups })
}

///|
/// Parses raw string directly into ORUMessage model.
pub fn parse_oru_from_raw(
  raw_text : String,
) -> Result[ORUMessage, @types.HL7Error] {
  let msg = match @parser.parse_message(raw_text) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  ORUMessage::from_message(msg)
}
