public class Spreadsheet.Models.Function : Object {
    public string name { get; construct; }
    public ApplyFunc apply { get; construct; }
    public string doc { get; construct; }

    public Function (string name, owned ApplyFunc func, string doc = _("No documentation")) {
        Object (
            name: name,
            apply: (owned) func,
            doc: doc
        );
    }
}

[CCode (has_target = false)]
public delegate Value Spreadsheet.Models.ApplyFunc (Value[] args);
