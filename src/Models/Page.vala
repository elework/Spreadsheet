using Gee;

namespace Spreadsheet.Models {

    public class Page : Object {

        public string title { get; set; }
        public ArrayList<Cell> cells { get; set; }
    }
}
