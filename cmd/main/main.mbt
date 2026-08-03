///|
fn main {
  println("==========================================================")
  println("  MoonBit Clinical HL7 v2 Parser & Interoperability CLI   ")
  println("==========================================================")

  // 1. Generate Synthetic Clinical HL7 v2 Message
  println("\n1. Generating Synthetic ADT_A01 Admit Patient Message...")
  let raw_adt = @generator.generate_adt_a01("P98765", "ZHAO", "MIN", "F")
  println("Raw HL7 ADT Payload:\n" + raw_adt)

  // 2. Parse Message AST
  println("\n2. Parsing HL7 AST Payload...")
  match @parser.parse_message(raw_adt) {
    Ok(msg) => {
      println(
        "Parsed " + msg.segment_count().to_string() + " segments successfully.",
      )

      // Extract typed MSH model using @segments
      match @segments.MSHSegment::from_segment(msg.segments[0]) {
        Ok(msh_model) =>
          println("MSH Sending Facility: " + msh_model.sending_facility)
        Err(_) => ()
      }

      // 3. Path Querying
      println("\n3. Executing HL7 Path Queries:")
      println("  MSH-9 (Message Type): " + @path.get_value(msg, "MSH-9"))
      println("  PID-3.1 (Patient ID): " + @path.get_value(msg, "PID-3.1"))
      println(
        "  PID-5 (Patient Name): " +
        @path.get_value(msg, "PID-5.1") +
        " " +
        @path.get_value(msg, "PID-5.2"),
      )

      // 4. Schema Validation
      println("\n4. Running HL7 v2 Schema Validator...")
      let val_report = @validator.validate_message(msg)
      println(val_report.to_summary())

      // 5. Multi-Target Conversion
      println("\n5. Converting HL7 to FHIR R4 Patient JSON:")
      println(@converter.to_fhir_patient_json(msg))

      println("\n6. Converting HL7 to Clinical Markdown Summary:")
      println(@converter.to_markdown_summary(msg))

      // 6. High-Level Clinical Envelope Model
      match @messages.parse_adt_from_raw(raw_adt) {
        Ok(adt_envelope) =>
          println(
            "\n7. High-Level ADT Envelope Patient ID: " +
            adt_envelope.pid.patient_identifier_list,
          )
        Err(_) => ()
      }

      // 7. Serializer Reformatting
      match @serializer.reformat_raw_hl7(raw_adt, "\n") {
        Ok(reformatted) =>
          println("\n8. Reformatted Message (\n endings):\n" + reformatted)
        Err(_) => ()
      }

      // 8. Generate ORU Lab Results & Perform AST Diffing
      println(
        "\n9. Generating ORU_R01 Lab Results & Running AST Diff Engine...",
      )
      let raw_oru = @generator.generate_oru_r01(
        "P98765", "80053", "CMP Panel", "105", "mg/dL", "70-99",
      )
      match @diff.diff_raw(raw_adt, raw_oru) {
        Ok(diff_res) => println(diff_res.to_summary())
        Err(_) => ()
      }
    }
    Err(e) => println("Parse Failure: " + e.to_formatted_string())
  }

  println("\n==========================================================")
  println("  HL7 v2 Message Processing Complete. Ready for HIS/LIS!   ")
  println("==========================================================")
}
