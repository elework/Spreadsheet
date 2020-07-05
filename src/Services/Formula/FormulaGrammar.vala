using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.Formula.FormulaGrammar : Grammar {
    public FormulaGrammar () {
        rules["root"] = root_rules ();
    }

    private Gee.ArrayList<Evaluator> root_rules () {
        return new Gee.ArrayList<Evaluator>.wrap ({
            new Evaluator (/[ \t]/, token ("[[ignore]]")),
            new Evaluator (/[A-Z]+[0-9]+/, token ("cell-name")),
            new Evaluator (/=/, token ("equal")),
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
