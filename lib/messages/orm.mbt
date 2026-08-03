///|
/// Order group structure for ORM (General Order) message.
pub(all) struct OrderGroup {
  orc : @segments.ORCSegment
  obr : Option[@segments.OBRSegment]
  rxo : Option[@segments.RXOSegment]
} derive(Eq, Debug)

///|
/// High-level ORM (General Order) Message structure.
pub(all) struct ORMMessage {
  msh : @segments.MSHSegment
  pid : @segments.PIDSegment
  orders : Array[OrderGroup]
} derive(Eq, Debug)

///|
/// Constructs ORMMessage model from AST Message.
pub fn ORMMessage::from_message(msg : @types.Message) -> Result[ORMMessage, @types.HL7Error] {
  if msg.segments.length() == 0 {
    return Err(@types.HL7Error::InvalidHeader("Empty message"))
  }
  let msh = match @segments.MSHSegment::from_segment(msg.segments[0]) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  let mut pid_opt : Option[@segments.PIDSegment] = None
  let orders = Array::new()

  let mut current_orc : Option[@segments.ORCSegment] = None
  let mut current_obr : Option[@segments.OBRSegment] = None
  let mut current_rxo : Option[@segments.RXOSegment] = None

  for seg in msg.segments {
    if seg.name == "PID" {
      match @segments.PIDSegment::from_segment(seg) {
        Ok(p) => pid_opt = Some(p)
        Err(_) => ()
      }
    } else if seg.name == "ORC" {
      match current_orc {
        Some(orc) => {
          orders.push({ orc, obr: current_obr, rxo: current_rxo })
          current_obr = None
          current_rxo = None
        }
        None => ()
      }
      match @segments.ORCSegment::from_segment(seg) {
        Ok(o) => current_orc = Some(o)
        Err(_) => ()
      }
    } else if seg.name == "OBR" {
      match @segments.OBRSegment::from_segment(seg) {
        Ok(b) => current_obr = Some(b)
        Err(_) => ()
      }
    } else if seg.name == "RXO" {
      match @segments.RXOSegment::from_segment(seg) {
        Ok(r) => current_rxo = Some(r)
        Err(_) => ()
      }
    }
  }

  match current_orc {
    Some(orc) => orders.push({ orc, obr: current_obr, rxo: current_rxo })
    None => ()
  }

  let pid = match pid_opt {
    Some(p) => p
    None => return Err(@types.HL7Error::MissingField("PID", 1))
  }

  Ok({ msh, pid, orders })
}

///|
/// High-level ACK (General Acknowledgment) Message structure.
pub(all) struct ACKMessage {
  msh : @segments.MSHSegment
  acknowledgment_code : String
  text_message : String
  referenced_message_control_id : String
} derive(Eq, Debug)

///|
/// Generates an ACK response message for an incoming request MSH header.
pub fn ACKMessage::make_ack(
  req_msh : @segments.MSHSegment,
  ack_code : String,
  text_message : String
) -> ACKMessage {
  let resp_msh : @segments.MSHSegment = {
    sending_app: req_msh.receiving_app,
    sending_facility: req_msh.receiving_facility,
    receiving_app: req_msh.sending_app,
    receiving_facility: req_msh.sending_facility,
    timestamp: req_msh.timestamp,
    security: "",
    message_type: "ACK",
    trigger_event: req_msh.trigger_event,
    message_control_id: "ACK_" + req_msh.message_control_id,
    processing_id: req_msh.processing_id,
    version_id: req_msh.version_id,
  }
  {
    msh: resp_msh,
    acknowledgment_code: ack_code,
    text_message,
    referenced_message_control_id: req_msh.message_control_id,
  }
}
