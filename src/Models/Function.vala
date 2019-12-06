public class Spreadsheet.Models.Function : Object {

    public Function (string name, owned ApplyFunc func, string doc = "No documentation") {
        Object (name: name, apply: (owned) func, doc: doc);
    }

    public string name { get; set; }

    public string doc { get; set; }

    public ApplyFunc apply { get; set; }
}

[CCode (has_target = false)]
public delegate Value Spreadsheet.Models.ApplyFunc (Value[] args);
