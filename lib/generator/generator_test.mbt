///|
test "generate synthetic ADT and ORU messages" {
  let adt_raw = generate_adt_a01("P10001", "SMITH", "JOHN", "M")
  assert_true(adt_raw.contains("MSH"))
  assert_true(adt_raw.contains("ADT^A01"))
  assert_true(adt_raw.contains("SMITH^JOHN"))

  let oru_raw = generate_oru_r01(
    "P10001", "80053", "Comprehensive Metabolic Panel", "98", "mg/dL", "70-99",
  )
  assert_true(oru_raw.contains("ORU^R01"))
  assert_true(oru_raw.contains("80053^Comprehensive Metabolic Panel"))
  assert_true(oru_raw.contains("98"))
}
