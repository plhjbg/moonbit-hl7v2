///|
/// Typed EVN (Event Type) segment model.
pub(all) struct EVNSegment {
  event_type_code : String
  recorded_date_time : String
  date_time_planned : String
  event_reason_code : String
  operator_id : String
  event_occurred : String
} derive(Eq, Debug)

pub fn EVNSegment::from_segment(seg : @types.Segment) -> Result[EVNSegment, @types.HL7Error] {
  if seg.name != "EVN" {
    return Err(@types.HL7Error::InvalidSegment("Expected EVN, found: " + seg.name, 1))
  }
  Ok({
    event_type_code: get_field_comp(seg, 1, 1),
    recorded_date_time: get_field_comp(seg, 2, 1),
    date_time_planned: get_field_comp(seg, 3, 1),
    event_reason_code: get_field_comp(seg, 4, 1),
    operator_id: get_field_comp(seg, 5, 1),
    event_occurred: get_field_comp(seg, 6, 1),
  })
}

///|
/// Typed ORC (Common Order) segment model.
pub(all) struct ORCSegment {
  order_control : String
  placer_order_number : String
  filler_order_number : String
  order_status : String
  response_flag : String
  quantity_timing : String
  transaction_date_time : String
  ordering_provider : @types.PersonName
} derive(Eq, Debug)

pub fn ORCSegment::from_segment(seg : @types.Segment) -> Result[ORCSegment, @types.HL7Error] {
  if seg.name != "ORC" {
    return Err(@types.HL7Error::InvalidSegment("Expected ORC, found: " + seg.name, 1))
  }
  let prov_fam = get_field_comp(seg, 12, 2)
  let prov_giv = get_field_comp(seg, 12, 3)
  Ok({
    order_control: get_field_comp(seg, 1, 1),
    placer_order_number: get_field_comp(seg, 2, 1),
    filler_order_number: get_field_comp(seg, 3, 1),
    order_status: get_field_comp(seg, 5, 1),
    response_flag: get_field_comp(seg, 6, 1),
    quantity_timing: get_field_comp(seg, 7, 1),
    transaction_date_time: get_field_comp(seg, 9, 1),
    ordering_provider: @types.PersonName::make(prov_fam, prov_giv, ""),
  })
}

///|
/// Typed DG1 (Diagnosis) segment model.
pub(all) struct DG1Segment {
  set_id : String
  diagnosis_coding_method : String
  diagnosis_code : @types.CodedElement
  diagnosis_description : String
  diagnosis_date_time : String
  diagnosis_type : String
  major_diagnostic_category : String
} derive(Eq, Debug)

pub fn DG1Segment::from_segment(seg : @types.Segment) -> Result[DG1Segment, @types.HL7Error] {
  if seg.name != "DG1" {
    return Err(@types.HL7Error::InvalidSegment("Expected DG1, found: " + seg.name, 1))
  }
  let code = get_field_comp(seg, 3, 1)
  let txt = get_field_comp(seg, 3, 2)
  let sys = get_field_comp(seg, 3, 3)
  Ok({
    set_id: get_field_comp(seg, 1, 1),
    diagnosis_coding_method: get_field_comp(seg, 2, 1),
    diagnosis_code: @types.CodedElement::simple(code, txt, sys),
    diagnosis_description: get_field_comp(seg, 4, 1),
    diagnosis_date_time: get_field_comp(seg, 5, 1),
    diagnosis_type: get_field_comp(seg, 6, 1),
    major_diagnostic_category: get_field_comp(seg, 7, 1),
  })
}

///|
/// Typed AL1 (Allergy Information) segment model.
pub(all) struct AL1Segment {
  set_id : String
  allergy_type_code : String
  allergy_code : @types.CodedElement
  allergy_severity_code : String
  allergy_reaction_code : String
  identification_date : String
} derive(Eq, Debug)

pub fn AL1Segment::from_segment(seg : @types.Segment) -> Result[AL1Segment, @types.HL7Error] {
  if seg.name != "AL1" {
    return Err(@types.HL7Error::InvalidSegment("Expected AL1, found: " + seg.name, 1))
  }
  let code = get_field_comp(seg, 3, 1)
  let txt = get_field_comp(seg, 3, 2)
  let sys = get_field_comp(seg, 3, 3)
  Ok({
    set_id: get_field_comp(seg, 1, 1),
    allergy_type_code: get_field_comp(seg, 2, 1),
    allergy_code: @types.CodedElement::simple(code, txt, sys),
    allergy_severity_code: get_field_comp(seg, 4, 1),
    allergy_reaction_code: get_field_comp(seg, 5, 1),
    identification_date: get_field_comp(seg, 6, 1),
  })
}

///|
/// Typed NK1 (Next of Kin / Associated Parties) segment model.
pub(all) struct NK1Segment {
  set_id : String
  name : @types.PersonName
  relationship : @types.CodedElement
  address : @types.ExtendedAddress
  phone_number : String
  business_phone : String
} derive(Eq, Debug)

pub fn NK1Segment::from_segment(seg : @types.Segment) -> Result[NK1Segment, @types.HL7Error] {
  if seg.name != "NK1" {
    return Err(@types.HL7Error::InvalidSegment("Expected NK1, found: " + seg.name, 1))
  }
  let fam = get_field_comp(seg, 2, 1)
  let giv = get_field_comp(seg, 2, 2)
  let name = @types.PersonName::make(fam, giv, "")

  let rel_code = get_field_comp(seg, 3, 1)
  let rel_txt = get_field_comp(seg, 3, 2)
  let relationship = @types.CodedElement::simple(rel_code, rel_txt, "")

  let st = get_field_comp(seg, 4, 1)
  let cty = get_field_comp(seg, 4, 3)
  let ste = get_field_comp(seg, 4, 4)
  let zip = get_field_comp(seg, 4, 5)
  let address = @types.ExtendedAddress::make(st, cty, ste, zip, "")

  Ok({
    set_id: get_field_comp(seg, 1, 1),
    name,
    relationship,
    address,
    phone_number: get_field_comp(seg, 5, 1),
    business_phone: get_field_comp(seg, 6, 1),
  })
}

///|
/// Typed RXO (Pharmacy Prescribe Order) segment model.
pub(all) struct RXOSegment {
  requested_give_code : @types.CodedElement
  requested_give_amount : String
  requested_give_units : @types.CodedElement
  requested_dosage_form : @types.CodedElement
} derive(Eq, Debug)

pub fn RXOSegment::from_segment(seg : @types.Segment) -> Result[RXOSegment, @types.HL7Error] {
  if seg.name != "RXO" {
    return Err(@types.HL7Error::InvalidSegment("Expected RXO, found: " + seg.name, 1))
  }
  let gc = get_field_comp(seg, 1, 1)
  let gt = get_field_comp(seg, 1, 2)
  let requested_give_code = @types.CodedElement::simple(gc, gt, "")

  let uc = get_field_comp(seg, 3, 1)
  let ut = get_field_comp(seg, 3, 2)
  let requested_give_units = @types.CodedElement::simple(uc, ut, "")

  let dc = get_field_comp(seg, 5, 1)
  let dt = get_field_comp(seg, 5, 2)
  let requested_dosage_form = @types.CodedElement::simple(dc, dt, "")

  Ok({
    requested_give_code,
    requested_give_amount: get_field_comp(seg, 2, 1),
    requested_give_units,
    requested_dosage_form,
  })
}

///|
/// Typed RXE (Pharmacy Encoded Order) segment model.
pub(all) struct RXESegment {
  give_code : @types.CodedElement
  give_amount : String
  give_units : @types.CodedElement
  give_dosage_form : @types.CodedElement
} derive(Eq, Debug)

pub fn RXESegment::from_segment(seg : @types.Segment) -> Result[RXESegment, @types.HL7Error] {
  if seg.name != "RXE" {
    return Err(@types.HL7Error::InvalidSegment("Expected RXE, found: " + seg.name, 1))
  }
  let gc = get_field_comp(seg, 2, 1)
  let gt = get_field_comp(seg, 2, 2)
  let give_code = @types.CodedElement::simple(gc, gt, "")

  let uc = get_field_comp(seg, 4, 1)
  let ut = get_field_comp(seg, 4, 2)
  let give_units = @types.CodedElement::simple(uc, ut, "")

  let dc = get_field_comp(seg, 6, 1)
  let dt = get_field_comp(seg, 6, 2)
  let give_dosage_form = @types.CodedElement::simple(dc, dt, "")

  Ok({
    give_code,
    give_amount: get_field_comp(seg, 3, 1),
    give_units,
    give_dosage_form,
  })
}

///|
/// Typed FT1 (Financial Transaction) segment model.
pub(all) struct FT1Segment {
  set_id : String
  transaction_id : String
  transaction_date : String
  transaction_posting_date : String
  transaction_type : String
  transaction_code : @types.CodedElement
  transaction_amount : String
} derive(Eq, Debug)

pub fn FT1Segment::from_segment(seg : @types.Segment) -> Result[FT1Segment, @types.HL7Error] {
  if seg.name != "FT1" {
    return Err(@types.HL7Error::InvalidSegment("Expected FT1, found: " + seg.name, 1))
  }
  let tc = get_field_comp(seg, 7, 1)
  let tt = get_field_comp(seg, 7, 2)
  let transaction_code = @types.CodedElement::simple(tc, tt, "")

  Ok({
    set_id: get_field_comp(seg, 1, 1),
    transaction_id: get_field_comp(seg, 2, 1),
    transaction_date: get_field_comp(seg, 4, 1),
    transaction_posting_date: get_field_comp(seg, 5, 1),
    transaction_type: get_field_comp(seg, 6, 1),
    transaction_code,
    transaction_amount: get_field_comp(seg, 11, 1),
  })
}

///|
/// Typed IN1 (Insurance) segment model.
pub(all) struct IN1Segment {
  set_id : String
  health_plan_id : @types.CodedElement
  insurance_company_id : String
  insurance_company_name : String
  group_number : String
  group_name : String
} derive(Eq, Debug)

pub fn IN1Segment::from_segment(seg : @types.Segment) -> Result[IN1Segment, @types.HL7Error] {
  if seg.name != "IN1" {
    return Err(@types.HL7Error::InvalidSegment("Expected IN1, found: " + seg.name, 1))
  }
  let pc = get_field_comp(seg, 2, 1)
  let pt = get_field_comp(seg, 2, 2)
  let health_plan_id = @types.CodedElement::simple(pc, pt, "")

  Ok({
    set_id: get_field_comp(seg, 1, 1),
    health_plan_id,
    insurance_company_id: get_field_comp(seg, 3, 1),
    insurance_company_name: get_field_comp(seg, 4, 1),
    group_number: get_field_comp(seg, 8, 1),
    group_name: get_field_comp(seg, 9, 1),
  })
}

///|
/// Typed PR1 (Procedures) segment model.
pub(all) struct PR1Segment {
  set_id : String
  procedure_coding_method : String
  procedure_code : @types.CodedElement
  procedure_description : String
  procedure_date_time : String
} derive(Eq, Debug)

pub fn PR1Segment::from_segment(seg : @types.Segment) -> Result[PR1Segment, @types.HL7Error] {
  if seg.name != "PR1" {
    return Err(@types.HL7Error::InvalidSegment("Expected PR1, found: " + seg.name, 1))
  }
  let pc = get_field_comp(seg, 3, 1)
  let pt = get_field_comp(seg, 3, 2)
  let sys = get_field_comp(seg, 3, 3)
  let procedure_code = @types.CodedElement::simple(pc, pt, sys)

  Ok({
    set_id: get_field_comp(seg, 1, 1),
    procedure_coding_method: get_field_comp(seg, 2, 1),
    procedure_code,
    procedure_description: get_field_comp(seg, 4, 1),
    procedure_date_time: get_field_comp(seg, 5, 1),
  })
}

///|
/// Typed SPM (Specimen) segment model.
pub(all) struct SPMSegment {
  set_id : String
  specimen_id : String
  specimen_type : @types.CodedElement
  specimen_collection_date_time : String
  specimen_source_site : String
} derive(Eq, Debug)

pub fn SPMSegment::from_segment(seg : @types.Segment) -> Result[SPMSegment, @types.HL7Error] {
  if seg.name != "SPM" {
    return Err(@types.HL7Error::InvalidSegment("Expected SPM, found: " + seg.name, 1))
  }
  let stc = get_field_comp(seg, 4, 1)
  let stt = get_field_comp(seg, 4, 2)
  let specimen_type = @types.CodedElement::simple(stc, stt, "")

  Ok({
    set_id: get_field_comp(seg, 1, 1),
    specimen_id: get_field_comp(seg, 2, 1),
    specimen_type,
    specimen_collection_date_time: get_field_comp(seg, 17, 1),
    specimen_source_site: get_field_comp(seg, 8, 1),
  })
}
