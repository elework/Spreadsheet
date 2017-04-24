using Gee;

namespace Spreadsheet.Models {
    public class Cell : Object {
        public int line { get; set; }
        public int column { get; set; }
        public string display_content { get; set; default = ""; }
        public string formula { get; set; default = ""; }
        public bool selected { get; set; default = false; }
    }
}
