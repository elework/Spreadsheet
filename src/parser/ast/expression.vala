namespace Spreadsheet.Parser.AST {
    public abstract class Expression : Object {
        public abstract Value eval ();
    }
}
