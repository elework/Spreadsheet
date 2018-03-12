using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.CSV.CSVGrammar : Grammar {
    public CSVGrammar () {
        this.rules["root"] = this.root_rules ();
        this.rules["text"] = this.text_rules ();
    }

    private Gee.ArrayList<Evaluator> root_rules () {
        return new Gee.ArrayList<Evaluator>.wrap ({
            new Evaluator (/,/, token ("comma")),
            new Evaluator (/\n/, token ("new-line")),
            new Evaluator (re ("\""), token ("quote"), false, { "text" }),
            new Evaluator (/./, token ("char"))
        });
    }

    private Gee.ArrayList<Evaluator> text_rules () {
        return new Gee.ArrayList<Evaluator>.wrap ({
            new Evaluator (/""/, (m) => { return new Token ("char", "\""); }),
            new Evaluator (re ("\""), token ("quote"), true),
            new Evaluator (/./, token ("char")),
        });
    }
}
