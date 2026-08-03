test "convert hl7 message to json, xml, fhir, and markdown" {
  let hl7_raw = "MSH|^~\\&|LIS|HOSPITAL|HIS|CENTER|20260803120000||ORU^R01|MSG00001|P|2.3\rPID|1||10001^^^HOSPITAL||DOE^JOHN||19800101|M\rOBX|1|NM|GLU^Glucose||95|mg/dL|70-99|N|||F"
  let parsed = @parser.parse_message(hl7_raw)
  assert_true(parsed is Ok(_))
  match parsed {
    Ok(msg) => {
      let json_str = to_json_string(msg)
      assert_true(json_str.contains("\"segments\""))
      assert_true(json_str.contains("GLU"))

      let xml_str = to_xml_string(msg)
      assert_true(xml_str.contains("<HL7Message>"))
      assert_true(xml_str.contains("<OBX>"))

      let fhir_patient = to_fhir_patient_json(msg)
      assert_true(fhir_patient.contains("\"resourceType\": \"Patient\""))
      assert_true(fhir_patient.contains("\"family\": \"DOE\""))

      let fhir_obs = to_fhir_observation_json(msg)
      assert_true(fhir_obs.contains("\"resourceType\": \"Observation\""))
      assert_true(fhir_obs.contains("\"value\": 95"))

      let md = to_markdown_summary(msg)
      assert_true(md.contains("# Clinical Message Summary"))
      assert_true(md.contains("Glucose"))
    }
    Err(_) => ()
  }
}
