using Gee;
using Spreadsheet.Services.Formula;
using Spreadsheet.Services.Parsing;

namespace Spreadsheet.Models {

    public class Cell : Object {

        public weak Page page { get; set; }
        public int line { get; set; }
        public int column { get; set; }
        public string display_content { get; set; default = ""; }
        public string formula {
            get {
                return this._formula;
            }
            set {
                this._formula = value;
                try {
                    var parser = new FormulaParser (new Lexer (new FormulaGrammar ()).tokenize (value));
                    var expression = parser.parse ();
                    this.display_content = ((double)expression.eval (this.page)).to_string ();
                } catch (ParserError err) {
                    debug ("Error: " + err.message);
                    this.display_content = "Error";
                }
            }
        }
        private string _formula = "";
        public bool selected { get; set; default = false; }
    }
}
