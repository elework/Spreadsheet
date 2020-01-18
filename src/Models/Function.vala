public class Spreadsheet.Models.Function : Object {
    public string name { get; set; }
    public ApplyFunc apply { get; set; }
    public string doc { get; set; }

    public Function (string name, owned ApplyFunc func, string doc = (_("No documentation")) {
        Object (
            name: name,
            apply: (owned) func,
            doc: doc
        );
    }
}

[CCode (has_target = false)]
public delegate Value Spreadsheet.Models.ApplyFunc (Value[] args);
