///|
/// High-level typed PID (Patient Identification) segment model.
pub(all) struct PIDSegment {
  set_id : String
  patient_id : String
  patient_identifier_list : String
  patient_name : @types.PersonName
  mother_maiden_name : String
  dob : String
  gender : String
  patient_address : @types.ExtendedAddress
  phone_home : String
  phone_business : String
  primary_language : String
  marital_status : String
  account_number : String
  ssn : String
} derive(Eq, Debug)

///|
/// Extracts PIDSegment model from AST Segment.
pub fn PIDSegment::from_segment(seg : @types.Segment) -> Result[PIDSegment, @types.HL7Error] {
  if seg.name != "PID" {
    return Err(@types.HL7Error::InvalidSegment("Expected PID segment, found: " + seg.name, 1))
  }
  let set_id = get_field_comp(seg, 1, 1)
  let patient_id = get_field_comp(seg, 2, 1)
  let patient_identifier_list = get_field_comp(seg, 3, 1)

  let fam_name = get_field_comp(seg, 5, 1)
  let given_name = get_field_comp(seg, 5, 2)
  let mid_name = get_field_comp(seg, 5, 3)
  let patient_name = @types.PersonName::make(fam_name, given_name, mid_name)

  let mother_maiden_name = get_field_comp(seg, 6, 1)
  let dob = get_field_comp(seg, 7, 1)
  let gender = get_field_comp(seg, 8, 1)

  let street = get_field_comp(seg, 11, 1)
  let city = get_field_comp(seg, 11, 3)
  let state = get_field_comp(seg, 11, 4)
  let zip = get_field_comp(seg, 11, 5)
  let country = get_field_comp(seg, 11, 6)
  let patient_address = @types.ExtendedAddress::make(street, city, state, zip, country)

  let phone_home = get_field_comp(seg, 13, 1)
  let phone_business = get_field_comp(seg, 14, 1)
  let primary_language = get_field_comp(seg, 15, 1)
  let marital_status = get_field_comp(seg, 16, 1)
  let account_number = get_field_comp(seg, 18, 1)
  let ssn = get_field_comp(seg, 19, 1)

  Ok({
    set_id,
    patient_id,
    patient_identifier_list,
    patient_name,
    mother_maiden_name,
    dob,
    gender,
    patient_address,
    phone_home,
    phone_business,
    primary_language,
    marital_status,
    account_number,
    ssn,
  })
}

///|
/// Converts PIDSegment model into AST Segment node.
pub fn PIDSegment::to_segment(self : PIDSegment, delimiters : @types.Delimiters) -> @types.Segment {
  let fields = Array::new()
  fields.push(@types.Field::from_string(self.set_id))
  fields.push(@types.Field::from_string(self.patient_id))
  fields.push(@types.Field::from_string(self.patient_identifier_list))
  fields.push(@types.Field::from_string(""))
  let name_str = self.patient_name.family_name +
    delimiters.comp_sep.to_string() +
    self.patient_name.given_name +
    delimiters.comp_sep.to_string() +
    self.patient_name.middle_name
  fields.push(@types.Field::from_string(name_str))
  fields.push(@types.Field::from_string(self.mother_maiden_name))
  fields.push(@types.Field::from_string(self.dob))
  fields.push(@types.Field::from_string(self.gender))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(""))
  let addr_str = self.patient_address.street_address +
    delimiters.comp_sep.to_string() +
    delimiters.comp_sep.to_string() +
    self.patient_address.city +
    delimiters.comp_sep.to_string() +
    self.patient_address.state_or_province +
    delimiters.comp_sep.to_string() +
    self.patient_address.postal_code +
    delimiters.comp_sep.to_string() +
    self.patient_address.country
  fields.push(@types.Field::from_string(addr_str))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(self.phone_home))
  fields.push(@types.Field::from_string(self.phone_business))
  fields.push(@types.Field::from_string(self.primary_language))
  fields.push(@types.Field::from_string(self.marital_status))
  fields.push(@types.Field::from_string(""))
  fields.push(@types.Field::from_string(self.account_number))
  fields.push(@types.Field::from_string(self.ssn))

  @types.Segment::make("PID", fields)
}
