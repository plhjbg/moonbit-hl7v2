///|
test "parse ADT_A01 high level message" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3\rPID|1||10001||DOE^JOHN||19800101|M\rPV1|1|I|3NW^301^1||||12345^SMITH^JAMES"
  let parsed = parse_adt_from_raw(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(adt) => {
      assert_eq(adt.msh.message_type, "ADT")
      assert_eq(adt.msh.trigger_event, "A01")
      assert_eq(adt.pid.patient_identifier_list, "10001")
      match adt.pv1 {
        Some(pv1) => {
          assert_eq(pv1.patient_class, "I")
          assert_eq(pv1.assigned_location.point_of_care, "3NW")
        }
        None => ()
      }
    }
    Err(_) => ()
  }
}

///|
test "parse ORU_R01 message with observations" {
  let hl7_raw = "MSH|^~\\&|LIS||||||ORU^R01|MSG00002|P|2.3\rPID|1||10002||SMITH^MARY\rOBR|1|ORD100|LAB200|80053^Comprehensive Metabolic Panel|||20260803100000\rOBX|1|NM|GLU^Glucose||95|mg/dL|70-99|N|||F\rOBX|2|NM|NA^Sodium||140|mmol/L|135-145|N|||F"
  let parsed = parse_oru_from_raw(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(oru) => {
      assert_eq(oru.groups.length(), 1)
      let grp = oru.groups[0]
      assert_eq(grp.obr.placer_order_number, "ORD100")
      assert_eq(grp.observations.length(), 2)
      assert_eq(grp.observations[0].observation_value, "95")
      assert_eq(grp.observations[1].observation_value, "140")
    }
    Err(_) => ()
  }
}

///|
test "ack message generation" {
  let req_raw = "MSH|^~\\&|CLIENT_APP|HOSPITAL|LIS_APP|HIS|20260803120000||ADT^A08|REQ999|P|2.3\rPID|1||P001"
  let msh_res = @segments.parse_msh_from_raw(req_raw)
  assert_true(msh_res is Ok(_))
  match msh_res {
    Ok(msh) => {
      let ack = ACKMessage::make_ack(msh, "AA", "Message Accepted")
      assert_eq(ack.msh.sending_app, "LIS_APP")
      assert_eq(ack.msh.receiving_app, "CLIENT_APP")
      assert_eq(ack.acknowledgment_code, "AA")
      assert_eq(ack.referenced_message_control_id, "REQ999")
    }
    Err(_) => ()
  }
}
