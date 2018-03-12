using Spreadsheet.Services.Parsing;
using Spreadsheet.Models;
using Gee;

public class Spreadsheet.Services.CSV.CSVParser : Parsing.Parser {

    private string path { get; set; }

    public CSVParser.from_file (string path) {
        try {
            string content;
            FileUtils.get_contents (path, out content);
            this (new Lexer (new CSVGrammar ()).tokenize (content));
            this.path = path;
        } catch (Error err) {
            critical (err.message);
        }
    }

    public CSVParser (ArrayList<Token> tokens) {
        base (tokens);
    }

    public Models.SpreadSheet parse (string page_name = "Sheet 1") throws ParserError {
        string basepath = Path.get_basename (this.path);
        var sheet = new Models.SpreadSheet () {
            title = basepath,
            file_path = this.path
        };
        var page = new Page () {
            title = page_name
        };
        this.parse_sheet (page);
        sheet.add_page (page);
        return sheet;
    }

    public ArrayList<Cell> parse_sheet (Page page) throws ParserError {
        var cells = new ArrayList<Cell> ();
        int fields_count = 0;
        int line = 0;
        int col = 0;
        while (true) {
            var cell = new Cell ();
            cell.line = line;
            cell.column = col;
            page.add_cell (cell);
            cell.formula = this.parse_text ();

            if (this.accept ("new-line")) {
                if (col != fields_count) {
                    throw new ParserError.UNEXPECTED (@"Unexpected number of fields on line $line");
                }
                line++;
                col = 0;
            } else if (this.accept ("eof")) {
                break;
            } else {
                this.expect ("comma");
                col++;
                if (line == 0) {
                    fields_count++;
                }
            }
        }
        return cells;
    }

    private string parse_text () throws ParserError {
        bool quoted = this.accept ("quote");
        string res = "";
        while (this.current.kind == "char") {
            res += this.current.lexeme;
            this.eat ();
        }
        if (quoted) {
            this.expect ("quote");
        }
        return res;
    }
}

