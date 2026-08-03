///|
/// High-level typed MSH (Message Header) segment model.
pub(all) struct MSHSegment {
  sending_app : String
  sending_facility : String
  receiving_app : String
  receiving_facility : String
  timestamp : String
  security : String
  message_type : String
  trigger_event : String
  message_control_id : String
  processing_id : String
  version_id : String
} derive(Eq, Debug)

///|
/// Helper to extract string from AST field item component safely.
fn get_field_comp(seg : @types.Segment, field_idx_1 : Int, comp_idx_1 : Int) -> String {
  let f_idx_0 = field_idx_1 - 1
  if f_idx_0 >= seg.fields.length() {
    return ""
  }
  let field = seg.fields[f_idx_0]
  if field.items.length() == 0 {
    return ""
  }
  let item = field.items[0]
  let c_idx_0 = comp_idx_1 - 1
  if c_idx_0 >= item.components.length() {
    return ""
  }
  match item.components[c_idx_0] {
    SimpleComp(s) => s
    SubComponents(subs) => if subs.length() > 0 { subs[0] } else { "" }
  }
}

///|
/// Extracts MSHSegment model from AST Segment.
pub fn MSHSegment::from_segment(seg : @types.Segment) -> Result[MSHSegment, @types.HL7Error] {
  if seg.name != "MSH" {
    return Err(@types.HL7Error::InvalidSegment("Expected MSH segment, found: " + seg.name, 1))
  }
  let sending_app = get_field_comp(seg, 3, 1)
  let sending_facility = get_field_comp(seg, 4, 1)
  let receiving_app = get_field_comp(seg, 5, 1)
  let receiving_facility = get_field_comp(seg, 6, 1)
  let timestamp = get_field_comp(seg, 7, 1)
  let security = get_field_comp(seg, 8, 1)
  let message_type = get_field_comp(seg, 9, 1)
  let trigger_event = get_field_comp(seg, 9, 2)
  let message_control_id = get_field_comp(seg, 10, 1)
  let processing_id = get_field_comp(seg, 11, 1)
  let version_id = get_field_comp(seg, 12, 1)

  Ok({
    sending_app,
    sending_facility,
    receiving_app,
    receiving_facility,
    timestamp,
    security,
    message_type,
    trigger_event,
    message_control_id,
    processing_id,
    version_id,
  })
}

///|
/// Parses raw HL7 message and returns MSHSegment model if valid.
pub fn parse_msh_from_raw(raw_text : String) -> Result[MSHSegment, @types.HL7Error] {
  let msg = match @parser.parse_message(raw_text) {
    Ok(m) => m
    Err(e) => return Err(e)
  }
  if msg.segments.length() == 0 {
    return Err(@types.HL7Error::InvalidHeader("No segments in message"))
  }
  MSHSegment::from_segment(msg.segments[0])
}

///|
/// Converts MSHSegment model into AST Segment node.
pub fn MSHSegment::to_segment(self : MSHSegment, delimiters : @types.Delimiters) -> @types.Segment {
  let fields = Array::new()
  // MSH-1
  fields.push(@types.Field::from_string(delimiters.field_sep.to_string()))
  // MSH-2
  fields.push(@types.Field::from_string(delimiters.encoding_characters()))
  // MSH-3
  fields.push(@types.Field::from_string(self.sending_app))
  // MSH-4
  fields.push(@types.Field::from_string(self.sending_facility))
  // MSH-5
  fields.push(@types.Field::from_string(self.receiving_app))
  // MSH-6
  fields.push(@types.Field::from_string(self.receiving_facility))
  // MSH-7
  fields.push(@types.Field::from_string(self.timestamp))
  // MSH-8
  fields.push(@types.Field::from_string(self.security))
  // MSH-9 (Message Type ^ Trigger Event)
  let msg_type_str = if self.trigger_event.length() > 0 {
    self.message_type + delimiters.comp_sep.to_string() + self.trigger_event
  } else {
    self.message_type
  }
  fields.push(@types.Field::from_string(msg_type_str))
  // MSH-10
  fields.push(@types.Field::from_string(self.message_control_id))
  // MSH-11
  fields.push(@types.Field::from_string(self.processing_id))
  // MSH-12
  fields.push(@types.Field::from_string(self.version_id))

  @types.Segment::make("MSH", fields)
}
