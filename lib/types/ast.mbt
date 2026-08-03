///|
/// Subcomponent node in HL7 AST (level 4).
pub(all) enum SubComponent {
  SimpleSubComp(String)
} derive(Eq, Debug)

///|
/// Component node in HL7 AST (level 3).
pub(all) enum Component {
  SimpleComp(String)
  SubComponents(Array[String])
} derive(Eq, Debug)

///|
/// Single field item inside a field repetition (level 2).
pub(all) struct FieldItem {
  components : Array[Component]
} derive(Eq, Debug)

///|
/// Creates a FieldItem from components array.
pub fn FieldItem::make(components : Array[Component]) -> FieldItem {
  { components, }
}

///|
/// Creates a FieldItem from a single text string.
pub fn FieldItem::from_string(value : String) -> FieldItem {
  { components: [SimpleComp(value)] }
}

///|
/// Field node representing one field index containing repetitions (level 1).
pub(all) struct Field {
  items : Array[FieldItem]
} derive(Eq, Debug)

///|
/// Creates a Field with array of FieldItems.
pub fn Field::make(items : Array[FieldItem]) -> Field {
  { items, }
}

///|
/// Creates a single non-repeating Field from a text string.
pub fn Field::from_string(value : String) -> Field {
  { items: [FieldItem::from_string(value)] }
}

///|
/// Returns true if field is empty (no items or empty string).
pub fn Field::is_empty(self : Field) -> Bool {
  if self.items.length() == 0 {
    return true
  }
  if self.items.length() == 1 {
    let item = self.items[0]
    if item.components.length() == 0 {
      return true
    }
    if item.components.length() == 1 {
      match item.components[0] {
        SimpleComp(s) => s.length() == 0
        SubComponents(subs) => subs.length() == 0
      }
    } else {
      false
    }
  } else {
    false
  }
}

///|
/// Segment node in HL7 AST.
pub(all) struct Segment {
  name : String
  fields : Array[Field]
} derive(Eq, Debug)

///|
/// Creates a new Segment.
pub fn Segment::make(name : String, fields : Array[Field]) -> Segment {
  { name, fields }
}

///|
/// Returns the number of fields in the segment.
pub fn Segment::field_count(self : Segment) -> Int {
  self.fields.length()
}

///|
/// HL7 Message AST container.
pub(all) struct Message {
  delimiters : Delimiters
  segments : Array[Segment]
} derive(Eq, Debug)

///|
/// Creates a new empty Message.
pub fn Message::empty() -> Message {
  { delimiters: Delimiters::default(), segments: [] }
}

///|
/// Returns the total number of segments in the message.
pub fn Message::segment_count(self : Message) -> Int {
  self.segments.length()
}
