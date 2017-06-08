using Gee;

namespace Spreadsheet.Models {

    /**
    * Class representing a whole Spreadsheet file.
    */
    public class SpreadSheet : Object {

        public void add_page (Page p) {
            p.document = this;
            this.pages.add (p);
        }

        public string title { get; set; }
        public string file_path { get; set; }
        public ArrayList<Page> pages { get; set; default = new ArrayList<Page> (); }
    }
}
