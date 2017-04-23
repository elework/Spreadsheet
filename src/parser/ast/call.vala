using Gee;

namespace Spreadsheet.Parser.AST {
    public class Call : CodeNode {
        public string function_name { get; set; }

        public ArrayList<CodeNode> arguments { get; set; }
    }
}
