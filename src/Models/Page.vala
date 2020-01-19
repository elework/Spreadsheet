/**
* A single page of a Spreadsheet
*/
public class Spreadsheet.Models.Page : Object {
    public weak SpreadSheet document { get; set; }
    public string title { get; set; }
    public Gee.ArrayList<Cell> cells { get; set; default = new Gee.ArrayList<Cell> (); }
    public int lines { get; private set; default = 0; }
    public int columns { get; private set; default = 0; }

    public Page.empty (int cols = 100, int lines = 100) {
        for (int i = 0; i < cols; i++) {
            for (int j = 0; j < lines; j++) {
                var cell = new Cell () {
                    line = j,
                    column = i
                };
                if (i == 0 && j == 0) {
                    cell.selected = true;
                }
                add_cell (cell);
            }
        }
    }

    public void add_cell (Cell c) {
        c.page = this;
        cells.add (c);
        if (c.line + 1 > lines) {
            lines = c.line + 1;
        }
        if (c.column + 1 > columns) {
            columns = c.column + 1;
        }
    }
}
