/**
* Class representing a whole Spreadsheet file.
*/
public class Spreadsheet.Models.SpreadSheet : Object {

    public void add_page (Page p) {
        p.document = this;
        pages.add (p);
    }

    public string title { get; set; }
    public string file_path { get; set; }
    public Gee.ArrayList<Page> pages { get; set; default = new Gee.ArrayList<Page> (); }
}
