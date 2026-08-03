///|
/// Converts HL7 Message PID segment into FHIR R4 Patient JSON object representation.
pub fn to_fhir_patient_json(msg : @types.Message) -> String {
  let pid_id = @path.get_value(msg, "PID-3.1")
  let fam_name = @path.get_value(msg, "PID-5.1")
  let giv_name = @path.get_value(msg, "PID-5.2")
  let gender_hl7 = @path.get_value(msg, "PID-8")
  let gender_fhir = if gender_hl7 == "M" {
    "male"
  } else if gender_hl7 == "F" {
    "female"
  } else {
    "other"
  }
  let dob = @path.get_value(msg, "PID-7")
  let city = @path.get_value(msg, "PID-11.3")
  let state = @path.get_value(msg, "PID-11.4")

  let buf = StringBuilder::new()
  buf.write_string("{\n")
  buf.write_string("  \"resourceType\": \"Patient\",\n")
  buf.write_string("  \"id\": \"" + json_escape(pid_id) + "\",\n")
  buf.write_string("  \"name\": [\n")
  buf.write_string("    {\n")
  buf.write_string("      \"family\": \"" + json_escape(fam_name) + "\",\n")
  buf.write_string("      \"given\": [\"" + json_escape(giv_name) + "\"]\n")
  buf.write_string("    }\n")
  buf.write_string("  ],\n")
  buf.write_string("  \"gender\": \"" + gender_fhir + "\",\n")
  buf.write_string("  \"birthDate\": \"" + json_escape(dob) + "\",\n")
  buf.write_string("  \"address\": [\n")
  buf.write_string("    {\n")
  buf.write_string("      \"city\": \"" + json_escape(city) + "\",\n")
  buf.write_string("      \"state\": \"" + json_escape(state) + "\"\n")
  buf.write_string("    }\n")
  buf.write_string("  ]\n")
  buf.write_string("}")
  buf.to_string()
}

///|
/// Converts HL7 Message OBX segment into FHIR R4 Observation JSON object representation.
pub fn to_fhir_observation_json(msg : @types.Message) -> String {
  let pid_id = @path.get_value(msg, "PID-3.1")
  let obs_code = @path.get_value(msg, "OBX-3.1")
  let obs_text = @path.get_value(msg, "OBX-3.2")
  let obs_val = @path.get_value(msg, "OBX-5")
  let units = @path.get_value(msg, "OBX-6")
  let ref_range = @path.get_value(msg, "OBX-7")

  let buf = StringBuilder::new()
  buf.write_string("{\n")
  buf.write_string("  \"resourceType\": \"Observation\",\n")
  buf.write_string("  \"status\": \"final\",\n")
  buf.write_string("  \"code\": {\n")
  buf.write_string("    \"coding\": [{\n")
  buf.write_string("      \"code\": \"" + json_escape(obs_code) + "\",\n")
  buf.write_string("      \"display\": \"" + json_escape(obs_text) + "\"\n")
  buf.write_string("    }]\n")
  buf.write_string("  },\n")
  buf.write_string("  \"subject\": {\n")
  buf.write_string(
    "    \"reference\": \"Patient/" + json_escape(pid_id) + "\"\n",
  )
  buf.write_string("  },\n")
  buf.write_string("  \"valueQuantity\": {\n")
  buf.write_string(
    "    \"value\": " +
    (if obs_val.length() > 0 { obs_val } else { "0" }) +
    ",\n",
  )
  buf.write_string("    \"unit\": \"" + json_escape(units) + "\"\n")
  buf.write_string("  },\n")
  buf.write_string("  \"referenceRange\": [{\n")
  buf.write_string("    \"text\": \"" + json_escape(ref_range) + "\"\n")
  buf.write_string("  }]\n")
  buf.write_string("}")
  buf.to_string()
}

///|
/// Formats HL7 Message into a clean Markdown clinical summary report table.
pub fn to_markdown_summary(msg : @types.Message) -> String {
  let buf = StringBuilder::new()
  let msg_type = @path.get_value(msg, "MSH-9")
  let control_id = @path.get_value(msg, "MSH-10")
  let sender = @path.get_value(msg, "MSH-3")
  let pid_id = @path.get_value(msg, "PID-3.1")
  let pat_name = @path.get_value(msg, "PID-5.2") +
    " " +
    @path.get_value(msg, "PID-5.1")
  let gender = @path.get_value(msg, "PID-8")
  let dob = @path.get_value(msg, "PID-7")

  buf.write_string("# Clinical Message Summary\n\n")
  buf.write_string("## Header & Patient Information\n\n")
  buf.write_string("| Property | Value |\n")
  buf.write_string("| :--- | :--- |\n")
  buf.write_string("| **Message Type** | `" + msg_type + "` |\n")
  buf.write_string("| **Control ID** | `" + control_id + "` |\n")
  buf.write_string("| **Sending Application** | " + sender + " |\n")
  buf.write_string("| **Patient ID** | `" + pid_id + "` |\n")
  buf.write_string("| **Patient Name** | " + pat_name + " |\n")
  buf.write_string("| **Gender / DOB** | " + gender + " / " + dob + " |\n\n")

  let obx_segs = @path.find_segments(msg, "OBX")
  if obx_segs.length() > 0 {
    buf.write_string("## Observation & Lab Results\n\n")
    buf.write_string(
      "| Test ID | Test Description | Value | Units | Reference Range | Flag |\n",
    )
    buf.write_string("| :--- | :--- | :--- | :--- | :--- | :--- |\n")
    let mut i = 0
    while i < obx_segs.length() {
      let prefix = "OBX[" + i.to_string() + "]"
      let t_id = @path.get_value(msg, prefix + "-3.1")
      let t_desc = @path.get_value(msg, prefix + "-3.2")
      let val = @path.get_value(msg, prefix + "-5")
      let units = @path.get_value(msg, prefix + "-6")
      let ref_r = @path.get_value(msg, prefix + "-7")
      let flag = @path.get_value(msg, prefix + "-8")
      buf.write_string(
        "| `" +
        t_id +
        "` | " +
        t_desc +
        " | **" +
        val +
        "** | " +
        units +
        " | " +
        ref_r +
        " | " +
        flag +
        " |\n",
      )
      i = i + 1
    }
  }
  buf.to_string()
}
