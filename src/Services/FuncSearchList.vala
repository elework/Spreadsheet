public class Spreadsheet.Services.FuncSearchList : Object {
    public string funcsearchlist_item { get; set; }

    public FuncSearchList (string name, string desctiption) {
        funcsearchlist_item = "%s %s".printf (name, desctiption);
    }
}
