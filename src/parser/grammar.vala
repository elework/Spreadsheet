using Gee;

namespace Spreadsheet.Parser {

    public class Grammar : Object {

        public HashMap<string, ArrayList<Evaluator>> rules {
            get;
            set;
            default = new HashMap<string, ArrayList<Evaluator>> ();
        }

        public Grammar () {
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
                new Evaluator (/\d+(\.\d+)?/, token ("number"))
            });
        }

        private Evaluation token (string t) {
            string type = t;
            return (m) => {
                return new Token (type, m);
            };
        }
    }
}
