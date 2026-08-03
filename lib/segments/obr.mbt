///|
/// High-level typed OBR (Observation Request) segment model.
pub(all) struct OBRSegment {
  set_id : String
  placer_order_number : String
  filler_order_number : String
  universal_service_id : @types.CodedElement
  priority : String
  requested_date_time : String
  observation_date_time : String
  ordering_provider : @types.PersonName
  result_status : String
} derive(Eq, Debug)

///|
/// Extracts OBRSegment model from AST Segment.
pub fn OBRSegment::from_segment(
  seg : @types.Segment,
) -> Result[OBRSegment, @types.HL7Error] {
  if seg.name != "OBR" {
    return Err(
      @types.HL7Error::InvalidSegment(
        "Expected OBR segment, found: " + seg.name,
        1,
      ),
    )
  }
  let set_id = get_field_comp(seg, 1, 1)
  let placer_order_number = get_field_comp(seg, 2, 1)
  let filler_order_number = get_field_comp(seg, 3, 1)

  let id_code = get_field_comp(seg, 4, 1)
  let id_text = get_field_comp(seg, 4, 2)
  let id_sys = get_field_comp(seg, 4, 3)
  let universal_service_id = @types.CodedElement::simple(
    id_code, id_text, id_sys,
  )

  let priority = get_field_comp(seg, 5, 1)
  let requested_date_time = get_field_comp(seg, 6, 1)
  let observation_date_time = get_field_comp(seg, 7, 1)

  let prov_fam = get_field_comp(seg, 16, 2)
  let prov_giv = get_field_comp(seg, 16, 3)
  let ordering_provider = @types.PersonName::make(prov_fam, prov_giv, "")

  let result_status = get_field_comp(seg, 25, 1)

  Ok({
    set_id,
    placer_order_number,
    filler_order_number,
    universal_service_id,
    priority,
    requested_date_time,
    observation_date_time,
    ordering_provider,
    result_status,
  })
}

///|
/// Converts OBRSegment model into AST Segment node.
pub fn OBRSegment::to_segment(
  self : OBRSegment,
  delimiters : @types.Delimiters,
) -> @types.Segment {
  let fields = Array::new()
  fields.push(@types.Field::from_string(self.set_id))
  fields.push(@types.Field::from_string(self.placer_order_number))
  fields.push(@types.Field::from_string(self.filler_order_number))
  let svc_str = self.universal_service_id.identifier +
    delimiters.comp_sep.to_string() +
    self.universal_service_id.text +
    delimiters.comp_sep.to_string() +
    self.universal_service_id.coding_system
  fields.push(@types.Field::from_string(svc_str))
  fields.push(@types.Field::from_string(self.priority))
  fields.push(@types.Field::from_string(self.requested_date_time))
  fields.push(@types.Field::from_string(self.observation_date_time))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  let prov_str = delimiters.comp_sep.to_string() +
    self.ordering_provider.family_name +
    delimiters.comp_sep.to_string() +
    self.ordering_provider.given_name
  fields.push(@types.Field::from_string(prov_str))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(self.result_status))

  @types.Segment::make("OBR", fields)
}
