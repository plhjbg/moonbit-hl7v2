test "serializer roundtrip with parser" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3\rPID|1||10001^^^HOSPITAL||DOE^JOHN^EDWARD||19800101|M"
  let parsed = @parser.parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      let serialized = serialize_message(msg)
      let parsed_again = @parser.parse_message(serialized)
      assert_true(parsed_again is Ok(_))
      match parsed_again {
        Ok(msg2) => {
          assert_eq(msg2.segments.length(), 2)
          assert_eq(msg2.segments[0].name, "MSH")
          assert_eq(msg2.segments[1].name, "PID")
        }
        Err(_) => ()
      }
    }
    Err(_) => ()
  }
}
