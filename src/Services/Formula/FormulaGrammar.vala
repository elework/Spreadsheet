using Spreadsheet.Services.Parsing;
using Gee;

namespace Spreadsheet.Services.Formula {

    public class FormulaGrammar : Grammar {

        public FormulaGrammar () {
            this.rules["root"] = this.root_rules ();
        }

        private ArrayList<Evaluator> root_rules () {
            return new ArrayList<Evaluator>.wrap ({
                new Evaluator (/[ \t]/, token ("[[ignore]]")),
                new Evaluator (/[A-Z]+[0-9]+/, token ("cell-name")),
                new Evaluator (/[A-Za-z][\w]*/, token ("identifier")),
                new Evaluator (/\(/, token ("left-parenthese")),
                new Evaluator (/\)/, token ("right-parenthese")),
                new Evaluator (/,/, token ("comma")),
                new Evaluator (/:/, token ("colon")),
                new Evaluator (/\d+(\.\d+)?/, token ("number")),
                new Evaluator (/\+/, token ("plus")),
                new Evaluator (/\*/, token ("star")),
                new Evaluator (/-/, token ("dash")),
                new Evaluator (/\//, token ("slash")),
                new Evaluator (/%/, token ("percent")),
                new Evaluator (/\^/, token ("carat"))
            });
        }
    }
}
