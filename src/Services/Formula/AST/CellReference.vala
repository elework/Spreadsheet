using Spreadsheet.Models;

namespace Spreadsheet.Services.Formula.AST {
    public class CellReference : Expression {
        public string cell_name { get; set; }

        public override Value eval (Page sheet) {
            string letters = cell_name;
            letters.canon ("ABCDEFGHIJKLMNOPQRSTUVWXYZ", '?');
            string _num = cell_name;
            _num.canon ("0123456789", '?');
            int num = int.parse (_num.replace ("?", "")) - 1;
            int col = new AlphabetGenerator ().index_of (letters.replace ("?", ""));
            int index = num + col * (int)sheet.columns;
            var cell = sheet.cells[index];
            if (cell.line != num || cell.column != col) {
                warning ("Wanted cell at %s (%d, %d), got %d %d\n", cell_name, num, col, cell.line, cell.column);
            }
            return double.parse (cell.display_content);
        }
    }
}
