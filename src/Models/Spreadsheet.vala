using Gee;

namespace Spreadsheet.Models {

    public class SpreadSheet : Object {

        public string title { get; set; }
        public string file_path { get; set; }
        public ArrayList<Page> pages { get; set; }
    }
}
