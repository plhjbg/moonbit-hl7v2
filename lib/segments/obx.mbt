///|
/// High-level typed OBX (Observation/Result) segment model.
pub(all) struct OBXSegment {
  set_id : String
  value_type : String
  observation_id : @types.CodedElement
  observation_sub_id : String
  observation_value : String
  units : String
  reference_range : String
  abnormal_flags : String
  probability : String
  nature_of_abnormal_test : String
  observation_result_status : String
  date_time_of_observation : String
} derive(Eq, Debug)

///|
/// Extracts OBXSegment model from AST Segment.
pub fn OBXSegment::from_segment(
  seg : @types.Segment,
) -> Result[OBXSegment, @types.HL7Error] {
  if seg.name != "OBX" {
    return Err(
      @types.HL7Error::InvalidSegment(
        "Expected OBX segment, found: " + seg.name,
        1,
      ),
    )
  }
  let set_id = get_field_comp(seg, 1, 1)
  let value_type = get_field_comp(seg, 2, 1)

  let id_code = get_field_comp(seg, 3, 1)
  let id_text = get_field_comp(seg, 3, 2)
  let id_sys = get_field_comp(seg, 3, 3)
  let observation_id = @types.CodedElement::simple(id_code, id_text, id_sys)

  let observation_sub_id = get_field_comp(seg, 4, 1)
  let observation_value = get_field_comp(seg, 5, 1)
  let units = get_field_comp(seg, 6, 1)
  let reference_range = get_field_comp(seg, 7, 1)
  let abnormal_flags = get_field_comp(seg, 8, 1)
  let probability = get_field_comp(seg, 9, 1)
  let nature_of_abnormal_test = get_field_comp(seg, 10, 1)
  let observation_result_status = get_field_comp(seg, 11, 1)
  let date_time_of_observation = get_field_comp(seg, 14, 1)

  Ok({
    set_id,
    value_type,
    observation_id,
    observation_sub_id,
    observation_value,
    units,
    reference_range,
    abnormal_flags,
    probability,
    nature_of_abnormal_test,
    observation_result_status,
    date_time_of_observation,
  })
}

///|
/// Converts OBXSegment model into AST Segment node.
pub fn OBXSegment::to_segment(
  self : OBXSegment,
  delimiters : @types.Delimiters,
) -> @types.Segment {
  let fields = Array::new()
  fields.push(@types.Field::from_string(self.set_id))
  fields.push(@types.Field::from_string(self.value_type))
  let obs_str = self.observation_id.identifier +
    delimiters.comp_sep.to_string() +
    self.observation_id.text +
    delimiters.comp_sep.to_string() +
    self.observation_id.coding_system
  fields.push(@types.Field::from_string(obs_str))
  fields.push(@types.Field::from_string(self.observation_sub_id))
  fields.push(@types.Field::from_string(self.observation_value))
  fields.push(@types.Field::from_string(self.units))
  fields.push(@types.Field::from_string(self.reference_range))
  fields.push(@types.Field::from_string(self.abnormal_flags))
  fields.push(@types.Field::from_string(self.probability))
  fields.push(@types.Field::from_string(self.nature_of_abnormal_test))
  fields.push(@types.Field::from_string(self.observation_result_status))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(self.date_time_of_observation))

  @types.Segment::make("OBX", fields)
}
