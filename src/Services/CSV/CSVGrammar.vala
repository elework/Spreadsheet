using Spreadsheet.Services.Parsing;
using Gee;

namespace Spreadsheet.Services.CSV {

    public class CSVGrammar : Grammar {

        public CSVGrammar () {
            this.rules["root"] = this.root_rules ();
            this.rules["text"] = this.text_rules ();
        }

        private ArrayList<Evaluator> root_rules () {
            return new ArrayList<Evaluator>.wrap ({
                new Evaluator (/,/, token ("comma")),
                new Evaluator (/\n/, token ("new-line")),
                new Evaluator (re ("\""), token ("quote"), false, { "text" }),
                new Evaluator (/./, token ("char"))
            });
        }

        private ArrayList<Evaluator> text_rules () {
            return new ArrayList<Evaluator>.wrap ({
                new Evaluator (/""/, (m) => { return new Token ("char", "\""); }),
                new Evaluator (re ("\""), token ("quote"), true),
                new Evaluator (/./, token ("char")),
            });
        }
    }
}
