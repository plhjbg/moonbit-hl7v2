test "path syntax parser" {
  let p1 = parse_path("PID-3.1.2")
  assert_true(p1 is Ok(_))
  match p1 {
    Ok(path) => {
      assert_eq(path.segment_name, "PID")
      assert_eq(path.field_index, 3)
      assert_eq(path.component_index, 1)
      assert_eq(path.subcomponent_index, 2)
    }
    Err(_) => ()
  }

  let p2 = parse_path("OBX[1]-5[0].2")
  assert_true(p2 is Ok(_))
  match p2 {
    Ok(path) => {
      assert_eq(path.segment_name, "OBX")
      assert_eq(path.segment_index, 1)
      assert_eq(path.field_index, 5)
      assert_eq(path.repetition_index, 0)
      assert_eq(path.component_index, 2)
    }
    Err(_) => ()
  }
}

test "get value from message using path" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3\rPID|1||10001^^^HOSPITAL||DOE^JOHN^EDWARD||19800101|M"
  let parsed = @parser.parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      assert_eq(get_value(msg, "MSH-9.1"), "ADT")
      assert_eq(get_value(msg, "MSH-9.2"), "A01")
      assert_eq(get_value(msg, "PID-5.1"), "DOE")
      assert_eq(get_value(msg, "PID-5.2"), "JOHN")
      assert_eq(get_value(msg, "PID-3.1"), "10001")
    }
    Err(_) => ()
  }
}
