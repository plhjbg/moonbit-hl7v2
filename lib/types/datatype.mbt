///|
/// Precision specification for HL7 Timestamp (TS / DTM).
pub(all) enum TimePrecision {
  Year
  Month
  Day
  Hour
  Minute
  Second
  Millisecond
} derive(Eq, Debug)

///|
/// Structured HL7 Timestamp (TS / DTM datatype: YYYYMMDDHHMMSS.SSSS±ZZZZ).
pub(all) struct HL7Timestamp {
  year : Int
  month : Int
  day : Int
  hour : Int
  minute : Int
  second : Int
  millisecond : Int
  timezone : String
  precision : TimePrecision
} derive(Eq, Debug)

///|
/// Creates a default HL7Timestamp initialized to zero/empty fields.
pub fn HL7Timestamp::empty() -> HL7Timestamp {
  {
    year: 0,
    month: 0,
    day: 0,
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    timezone: "",
    precision: Year,
  }
}

///|
/// Formats an HL7Timestamp into standard HL7 TS string representation.
pub fn HL7Timestamp::to_hl7_string(self : HL7Timestamp) -> String {
  if self.year == 0 {
    return ""
  }
  let buf = StringBuilder::new()
  let y_str = if self.year < 1000 { "2026" } else { self.year.to_string() }
  buf.write_string(y_str)
  if self.precision == Year {
    return buf.to_string()
  }
  let m_str = if self.month < 10 { "0" + self.month.to_string() } else { self.month.to_string() }
  buf.write_string(m_str)
  if self.precision == Month {
    return buf.to_string()
  }
  let d_str = if self.day < 10 { "0" + self.day.to_string() } else { self.day.to_string() }
  buf.write_string(d_str)
  if self.precision == Day {
    return buf.to_string()
  }
  let h_str = if self.hour < 10 { "0" + self.hour.to_string() } else { self.hour.to_string() }
  buf.write_string(h_str)
  if self.precision == Hour {
    return buf.to_string()
  }
  let min_str = if self.minute < 10 { "0" + self.minute.to_string() } else { self.minute.to_string() }
  buf.write_string(min_str)
  if self.precision == Minute {
    return buf.to_string()
  }
  let s_str = if self.second < 10 { "0" + self.second.to_string() } else { self.second.to_string() }
  buf.write_string(s_str)
  if self.precision == Second {
    if self.timezone.length() > 0 {
      buf.write_string(self.timezone)
    }
    return buf.to_string()
  }
  let ms_str = if self.millisecond < 10 {
    "00" + self.millisecond.to_string()
  } else if self.millisecond < 100 {
    "0" + self.millisecond.to_string()
  } else {
    self.millisecond.to_string()
  }
  buf.write_string("." + ms_str)
  if self.timezone.length() > 0 {
    buf.write_string(self.timezone)
  }
  buf.to_string()
}

///|
/// Hierarchical Identifier (HD datatype: NamespaceID^UniversalID^UniversalIDType).
pub(all) struct HierarchicalID {
  namespace_id : String
  universal_id : String
  universal_id_type : String
} derive(Eq, Debug)

///|
/// Creates a HierarchicalID.
pub fn HierarchicalID::make(namespace_id : String, universal_id : String, universal_id_type : String) -> HierarchicalID {
  { namespace_id, universal_id, universal_id_type }
}

///|
/// Coded Element (CE datatype: Identifier^Text^CodingSystem^AltID^AltText^AltCodingSystem).
pub(all) struct CodedElement {
  identifier : String
  text : String
  coding_system : String
  alt_identifier : String
  alt_text : String
  alt_coding_system : String
} derive(Eq, Debug)

///|
/// Creates a simple CodedElement with identifier, text, and coding system.
pub fn CodedElement::simple(identifier : String, text : String, coding_system : String) -> CodedElement {
  {
    identifier,
    text,
    coding_system,
    alt_identifier: "",
    alt_text: "",
    alt_coding_system: "",
  }
}

///|
/// Extended Person Name (XPN datatype: FamilyName^GivenName^MiddleName^Suffix^Prefix^Degree^NameTypeCode).
pub(all) struct PersonName {
  family_name : String
  given_name : String
  middle_name : String
  suffix : String
  prefix : String
  degree : String
  name_type_code : String
} derive(Eq, Debug)

///|
/// Creates a PersonName.
pub fn PersonName::make(family_name : String, given_name : String, middle_name : String) -> PersonName {
  {
    family_name,
    given_name,
    middle_name,
    suffix: "",
    prefix: "",
    degree: "",
    name_type_code: "L",
  }
}

///|
/// Formats PersonName into a single full display string.
pub fn PersonName::to_display_name(self : PersonName) -> String {
  let buf = StringBuilder::new()
  if self.prefix.length() > 0 {
    buf.write_string(self.prefix + " ")
  }
  buf.write_string(self.given_name)
  if self.middle_name.length() > 0 {
    buf.write_string(" " + self.middle_name)
  }
  if self.family_name.length() > 0 {
    buf.write_string(" " + self.family_name)
  }
  if self.suffix.length() > 0 {
    buf.write_string(", " + self.suffix)
  }
  buf.to_string()
}

///|
/// Extended Composite ID with Check Digit (CX datatype).
pub(all) struct CompositeID {
  id_number : String
  check_digit : String
  check_digit_scheme : String
  assigning_authority : HierarchicalID
  id_type_code : String
} derive(Eq, Debug)

///|
/// Extended Address (XAD datatype).
pub(all) struct ExtendedAddress {
  street_address : String
  other_designation : String
  city : String
  state_or_province : String
  postal_code : String
  country : String
  address_type : String
} derive(Eq, Debug)

///|
/// Creates an ExtendedAddress.
pub fn ExtendedAddress::make(
  street : String,
  city : String,
  state : String,
  zip : String,
  country : String
) -> ExtendedAddress {
  {
    street_address: street,
    other_designation: "",
    city,
    state_or_province: state,
    postal_code: zip,
    country,
    address_type: "H",
  }
}

///|
/// Person Location (PL datatype).
pub(all) struct PersonLocation {
  point_of_care : String
  room : String
  bed : String
  facility : HierarchicalID
  location_status : String
  person_location_type : String
  building : String
  floor : String
} derive(Eq, Debug)
