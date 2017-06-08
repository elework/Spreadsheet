using Gee;

namespace Spreadsheet.Services.Parsing {

    public abstract class Grammar : Object {
        public HashMap<string, ArrayList<Evaluator>> rules {
            get;
            set;
            default = new HashMap<string, ArrayList<Evaluator>> ();
        }

        protected Evaluation token (string t) {
            string type = t;
            return (m) => {
                return new Token (type, m);
            };
        }

        protected Regex re (string pattern) {
            try {
                return new Regex (pattern);
            } catch (Error err) {
                assert_not_reached ();
            }
        }
    }
}
