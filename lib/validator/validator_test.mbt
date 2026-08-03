test "validate valid ADT message" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3\rPID|1||10001^^^HOSPITAL||DOE^JOHN||19800101|M"
  let report = validate_raw(hl7_raw)
  assert_true(report.is_valid())
  assert_eq(report.error_count(), 0)
}

test "validate missing PID segment in ADT message" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3"
  let report = validate_raw(hl7_raw)
  assert_false(report.is_valid())
  assert_eq(report.error_count() > 0, true)
}

test "validate invalid numeric OBX value" {
  let hl7_raw = "MSH|^~\\&|LIS||||||ORU^R01|MSG00002|P|2.3\rPID|1||10002\rOBX|1|NM|GLU^Glucose||INVALID_NUM|mg/dL|70-99|N|||F"
  let report = validate_raw(hl7_raw)
  assert_false(report.is_valid())
  assert_eq(report.error_count(), 1)
}
