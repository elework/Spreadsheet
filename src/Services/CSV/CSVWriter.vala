using Gee;
using Spreadsheet.Models;

namespace Spreadsheet.Services.CSV {
    public class CSVWriter : Object {
        private Page page { get; set; }

        public CSVWriter (Page page) {
            this.page = page;
        }

        public string to_string () {
            ArrayList<ArrayList<string>> table = new ArrayList<ArrayList<string>> ();
            int max_records = 0;
            foreach (var cell in this.page.cells) {
                while (table.size - 1 < cell.line) {
                    table.add (new ArrayList<string> ());
                }
                var line = table[cell.line];
                while (line.size - 1 < cell.column) {
                    line.add ("");
                }
                table[cell.line][cell.column] = cell.formula;
                if (cell.column > max_records) {
                    max_records = cell.column;
                }
            }
            string csv = "";
            foreach (var line in table) {
                bool first = true;
                int records = 0;
                foreach (var cell in line) {
                    if (first) {
                        first = false;
                    } else {
                        csv += ",";
                    }
                    csv += @"\"$cell\"";
                    records++;
                }
                while (records < max_records) {
                    csv += ",";
                }
                csv += "\n";
            }
            return csv;
        }

        public void write_to_file (string path) {
            try {
                FileUtils.set_contents (path, this.to_string ());
            } catch (Error e) {

            }
        }
    }
}
