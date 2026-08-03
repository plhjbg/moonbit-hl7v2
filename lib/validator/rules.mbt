///|
/// Severity level of validation issue.
pub(all) enum ValidationSeverity {
  Error
  Warning
  Info
} derive(Eq, Debug)

///|
/// Individual rule violation issue.
pub(all) struct ValidationIssue {
  rule_id : String
  severity : ValidationSeverity
  path : String
  message : String
} derive(Eq, Debug)

///|
/// Aggregate validation report.
pub(all) struct ValidationReport {
  issues : Array[ValidationIssue]
} derive(Eq, Debug)

///|
/// Returns true if no Error level issues exist in report.
pub fn ValidationReport::is_valid(self : ValidationReport) -> Bool {
  for issue in self.issues {
    if issue.severity == Error {
      return false
    }
  }
  true
}

///|
/// Returns total error count in report.
pub fn ValidationReport::error_count(self : ValidationReport) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.severity == Error {
      count = count + 1
    }
  }
  count
}

///|
/// Returns total warning count in report.
pub fn ValidationReport::warning_count(self : ValidationReport) -> Int {
  let mut count = 0
  for issue in self.issues {
    if issue.severity == Warning {
      count = count + 1
    }
  }
  count
}

///|
/// Formats report as human-readable diagnostic text.
pub fn ValidationReport::to_summary(self : ValidationReport) -> String {
  let buf = StringBuilder::new()
  buf.write_string("Validation Summary: Errors=" + self.error_count().to_string() + ", Warnings=" + self.warning_count().to_string() + "\n")
  for issue in self.issues {
    let sev_str = match issue.severity {
      Error => "[ERROR]"
      Warning => "[WARN ]"
      Info => "[INFO ]"
    }
    buf.write_string(sev_str + " Rule " + issue.rule_id + " (" + issue.path + "): " + issue.message + "\n")
  }
  buf.to_string()
}
