///|
/// Generates a valid synthetic ADT_A01 Admit Patient HL7 v2 raw string message.
pub fn generate_adt_a01(
  patient_id : String,
  family_name : String,
  given_name : String,
  gender : String,
) -> String {
  let delims = @types.Delimiters::default()
  let msh_seg = @types.Segment::make("MSH", [
    @types.Field::from_string(delims.field_sep.to_string()),
    @types.Field::from_string(delims.encoding_characters()),
    @types.Field::from_string("MOCK_LIS"),
    @types.Field::from_string("CLINIC_FACILITY"),
    @types.Field::from_string("HIS_APP"),
    @types.Field::from_string("CENTER_FACILITY"),
    @types.Field::from_string("20260803140000"),
    @types.Field::from_string(""),
    @types.Field::make([
      @types.FieldItem::make([
        @types.Component::SimpleComp("ADT"),
        @types.Component::SimpleComp("A01"),
      ]),
    ]),
    @types.Field::from_string("MSG_" + patient_id),
    @types.Field::from_string("P"),
    @types.Field::from_string("2.3"),
  ])

  let name_item = @types.FieldItem::make([
    @types.Component::SimpleComp(family_name),
    @types.Component::SimpleComp(given_name),
  ])
  let pid_seg = @types.Segment::make("PID", [
    @types.Field::from_string("1"),
    @types.Field::from_string(""),
    @types.Field::from_string(patient_id),
    @types.Field::from_string(""),
    @types.Field::make([name_item]),
    @types.Field::from_string(""),
    @types.Field::from_string("19850515"),
    @types.Field::from_string(gender),
    @types.Field::from_string(""),
    @types.Field::from_string(""),
    @types.Field::from_string("100 MAIN STREET^^CITY^STATE^12345"),
  ])

  let pv1_seg = @types.Segment::make("PV1", [
    @types.Field::from_string("1"),
    @types.Field::from_string("I"),
    @types.Field::from_string("4EAST^401^A"),
    @types.Field::from_string("EMERGENCY"),
  ])

  let msg : @types.Message = {
    delimiters: delims,
    segments: [msh_seg, pid_seg, pv1_seg],
  }
  @serializer.serialize_message(msg)
}

///|
/// Generates a valid synthetic ORU_R01 Lab Results HL7 v2 raw string message.
pub fn generate_oru_r01(
  patient_id : String,
  test_code : String,
  test_name : String,
  result_val : String,
  units : String,
  ref_range : String,
) -> String {
  let delims = @types.Delimiters::default()
  let msh_seg = @types.Segment::make("MSH", [
    @types.Field::from_string(delims.field_sep.to_string()),
    @types.Field::from_string(delims.encoding_characters()),
    @types.Field::from_string("MOCK_LIS"),
    @types.Field::from_string("LAB_FACILITY"),
    @types.Field::from_string("HIS_APP"),
    @types.Field::from_string("CENTER_FACILITY"),
    @types.Field::from_string("20260803141500"),
    @types.Field::from_string(""),
    @types.Field::make([
      @types.FieldItem::make([
        @types.Component::SimpleComp("ORU"),
        @types.Component::SimpleComp("R01"),
      ]),
    ]),
    @types.Field::from_string("MSG_LAB_" + patient_id),
    @types.Field::from_string("P"),
    @types.Field::from_string("2.3"),
  ])

  let pid_seg = @types.Segment::make("PID", [
    @types.Field::from_string("1"),
    @types.Field::from_string(""),
    @types.Field::from_string(patient_id),
  ])

  let obr_svc = @types.FieldItem::make([
    @types.Component::SimpleComp(test_code),
    @types.Component::SimpleComp(test_name),
    @types.Component::SimpleComp("LN"),
  ])
  let obr_seg = @types.Segment::make("OBR", [
    @types.Field::from_string("1"),
    @types.Field::from_string("ORD_" + patient_id),
    @types.Field::from_string("LAB_" + patient_id),
    @types.Field::make([obr_svc]),
  ])

  let obx_svc = @types.FieldItem::make([
    @types.Component::SimpleComp(test_code),
    @types.Component::SimpleComp(test_name),
  ])
  let obx_seg = @types.Segment::make("OBX", [
    @types.Field::from_string("1"),
    @types.Field::from_string("NM"),
    @types.Field::make([obx_svc]),
    @types.Field::from_string("1"),
    @types.Field::from_string(result_val),
    @types.Field::from_string(units),
    @types.Field::from_string(ref_range),
    @types.Field::from_string("N"),
    @types.Field::from_string(""),
    @types.Field::from_string(""),
    @types.Field::from_string("F"),
  ])

  let msg : @types.Message = {
    delimiters: delims,
    segments: [msh_seg, pid_seg, obr_seg, obx_seg],
  }
  @serializer.serialize_message(msg)
}
