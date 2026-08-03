test "msh segment model roundtrip" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ADT^A01|MSG00001|P|2.3"
  let parsed = @parser.parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      let msh_res = MSHSegment::from_segment(msg.segments[0])
      assert_true(msh_res is Ok(_))
      match msh_res {
        Ok(msh) => {
          assert_eq(msh.sending_app, "LIS")
          assert_eq(msh.sending_facility, "HOSPITAL")
          assert_eq(msh.message_type, "ADT")
          assert_eq(msh.trigger_event, "A01")
          assert_eq(msh.message_control_id, "MSG00001")

          let ast_seg = msh.to_segment(msg.delimiters)
          assert_eq(ast_seg.name, "MSH")
        }
        Err(_) => ()
      }
    }
    Err(_) => ()
  }
}

test "pid and obx segment models" {
  let hl7_raw = "MSH|^~\\&|LIS||||||ORU^R01|1|P|2.3\rPID|1||10001||DOE^JOHN||19800101|M\rOBX|1|NM|GLU^Glucose||95|mg/dL|70-99|N|||F"
  let parsed = @parser.parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      let pid_res = PIDSegment::from_segment(msg.segments[1])
      assert_true(pid_res is Ok(_))
      match pid_res {
        Ok(pid) => {
          assert_eq(pid.patient_identifier_list, "10001")
          assert_eq(pid.patient_name.family_name, "DOE")
          assert_eq(pid.patient_name.given_name, "JOHN")
          assert_eq(pid.gender, "M")
        }
        Err(_) => ()
      }

      let obx_res = OBXSegment::from_segment(msg.segments[2])
      assert_true(obx_res is Ok(_))
      match obx_res {
        Ok(obx) => {
          assert_eq(obx.value_type, "NM")
          assert_eq(obx.observation_id.identifier, "GLU")
          assert_eq(obx.observation_value, "95")
          assert_eq(obx.units, "mg/dL")
          assert_eq(obx.abnormal_flags, "N")
        }
        Err(_) => ()
      }
    }
    Err(_) => ()
  }
}
