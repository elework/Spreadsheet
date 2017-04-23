using Gee;

namespace Spreadsheet.Models {
    public class Cell : Object {
        public int line { get; set; }
        public int column { get; set; }
        public string display_content { get; set; }
        public string formula { get; set; }
        public bool selected { get; set; }
    }
}
