///|
/// Error representation for HL7 v2 operations.
pub(all) enum HL7Error {
  InvalidHeader(String)
  InvalidSegment(String, Int)
  MissingField(String, Int)
  ParseError(String, Int, Int)
  EscapeError(String)
  PathSyntaxError(String)
  ValidationError(String, String)
  UnsupportedVersion(String)
  ConversionError(String)
} derive(Eq, Debug)

///|
/// Formats an HL7Error into a detailed diagnostic message.
pub fn HL7Error::to_formatted_string(self : HL7Error) -> String {
  match self {
    InvalidHeader(msg) => "[HL7 Header Error] " + msg
    InvalidSegment(seg_name, line) =>
      "[HL7 Segment Error] Invalid segment '" +
      seg_name +
      "' at line " +
      line.to_string()
    MissingField(seg_name, field_idx) =>
      "[HL7 Field Error] Missing required field " +
      seg_name +
      "-" +
      field_idx.to_string()
    ParseError(msg, line, col) =>
      "[HL7 Parse Error] " +
      msg +
      " (Line " +
      line.to_string() +
      ", Col " +
      col.to_string() +
      ")"
    EscapeError(seq) => "[HL7 Escape Error] Unrecognized escape sequence: " + seq
    PathSyntaxError(path) =>
      "[HL7 Path Error] Invalid path expression: '" + path + "'"
    ValidationError(rule_id, detail) =>
      "[HL7 Validation Error] Rule [" + rule_id + "]: " + detail
    UnsupportedVersion(ver) =>
      "[HL7 Version Error] Unsupported HL7 v2 version: " + ver
    ConversionError(reason) => "[HL7 Conversion Error] " + reason
  }
}
