test "diff identical messages" {
  let hl7 = "MSH|^~\\&|LIS||||||ADT^A01|1|P|2.3\rPID|1||10001||DOE^JOHN"
  let res = diff_raw(hl7, hl7)
  assert_true(res is Ok(_))
  match res {
    Ok(diff) => assert_false(diff.has_diff())
    Err(_) => ()
  }
}

test "diff modified field value and added segment" {
  let raw1 = "MSH|^~\\&|LIS||||||ADT^A01|1|P|2.3\rPID|1||10001||DOE^JOHN"
  let raw2 = "MSH|^~\\&|LIS||||||ADT^A01|1|P|2.3\rPID|1||10001||SMITH^JOHN\rOBX|1|NM|GLU||95"
  let res = diff_raw(raw1, raw2)
  assert_true(res is Ok(_))
  match res {
    Ok(diff) => {
      assert_true(diff.has_diff())
      let summary = diff.to_summary()
      assert_true(summary.contains("SMITH"))
      assert_true(summary.contains("Segment Added"))
    }
    Err(_) => ()
  }
}
