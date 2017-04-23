namespace Spreadsheet.Parser.AST {
    public class Block : CodeNode {
        public ArrayList<Expression> instructions { get; set; default = new ArrayList<Expression> (); }
    }
}
