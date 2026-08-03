test "parse basic MSH and PID message" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3\rPID|1||10001^^^HOSPITAL||DOE^JOHN^EDWARD||19800101|M|||123 MAIN ST^^CITY^ST^12345"
  let parsed = parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      assert_eq(msg.segments.length(), 2)
      assert_eq(msg.segments[0].name, "MSH")
      assert_eq(msg.segments[1].name, "PID")
    }
    Err(_) => ()
  }
}

test "parse repetition fields and subcomponents" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ORU^R01|MSG00002|P|2.3.1\rOBX|1|ST|WBC^White Blood Cell&WBC-Count||7.5|10*3/uL|4.0-10.0~3.8-10.5|N|||F"
  let parsed = parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      let obx = msg.segments[1]
      assert_eq(obx.name, "OBX")
      assert_eq(obx.fields.length() >= 7, true)
    }
    Err(_) => ()
  }
}

test "parse invalid header error" {
  let invalid_raw = "PID|1||10001"
  let parsed = parse_message(invalid_raw)
  assert_true(parsed is Err(_))
}

test "parse batch messages" {
  let batch_raw = "MSH|^~\\&|LIS||||||ADT^A01|101|P|2.3\rPID|1||P001\rMSH|^~\\&|LIS||||||ADT^A08|102|P|2.3\rPID|1||P002"
  let batch_res = parse_batch(batch_raw)
  assert_eq(batch_res.length(), 2)
  for res in batch_res {
    assert_true(res is Ok(_))
  }
}
