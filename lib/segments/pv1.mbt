///|
/// High-level typed PV1 (Patient Visit) segment model.
pub(all) struct PV1Segment {
  set_id : String
  patient_class : String
  assigned_location : @types.PersonLocation
  admission_type : String
  readmission_indicator : String
  attending_doctor : @types.PersonName
  referring_doctor : @types.PersonName
  hospital_service : String
  admit_date_time : String
  discharge_date_time : String
} derive(Eq, Debug)

///|
/// Extracts PV1Segment model from AST Segment.
pub fn PV1Segment::from_segment(
  seg : @types.Segment,
) -> Result[PV1Segment, @types.HL7Error] {
  if seg.name != "PV1" {
    return Err(
      @types.HL7Error::InvalidSegment(
        "Expected PV1 segment, found: " + seg.name,
        1,
      ),
    )
  }
  let set_id = get_field_comp(seg, 1, 1)
  let patient_class = get_field_comp(seg, 2, 1)
  let poc = get_field_comp(seg, 3, 1)
  let room = get_field_comp(seg, 3, 2)
  let bed = get_field_comp(seg, 3, 3)
  let assigned_location : @types.PersonLocation = {
    point_of_care: poc,
    room,
    bed,
    facility: @types.HierarchicalID::make("", "", ""),
    location_status: "",
    person_location_type: "",
    building: "",
    floor: "",
  }
  let admission_type = get_field_comp(seg, 4, 1)
  let readmission_indicator = get_field_comp(seg, 13, 1)

  let att_fam = get_field_comp(seg, 7, 2)
  let att_giv = get_field_comp(seg, 7, 3)
  let attending_doctor = @types.PersonName::make(att_fam, att_giv, "")

  let ref_fam = get_field_comp(seg, 8, 2)
  let ref_giv = get_field_comp(seg, 8, 3)
  let referring_doctor = @types.PersonName::make(ref_fam, ref_giv, "")

  let hospital_service = get_field_comp(seg, 10, 1)
  let admit_date_time = get_field_comp(seg, 44, 1)
  let discharge_date_time = get_field_comp(seg, 45, 1)

  Ok({
    set_id,
    patient_class,
    assigned_location,
    admission_type,
    readmission_indicator,
    attending_doctor,
    referring_doctor,
    hospital_service,
    admit_date_time,
    discharge_date_time,
  })
}
