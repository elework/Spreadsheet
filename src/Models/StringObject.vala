public class Spreadsheet.Models.StringObject : Object {
    public string string { get; construct; }

    public StringObject (string str) {
        Object (
            string: str
        );
    }
}
