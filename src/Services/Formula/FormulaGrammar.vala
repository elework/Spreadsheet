using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.Formula.FormulaGrammar : Grammar {
    private string func_name_regex = "";

    public FormulaGrammar () {
        rules["root"] = root_rules ();
    }

    private string get_func_name_regex () {
        if (func_name_regex == "") {
            string[]? func_names = null;
            foreach (var function in App.functions) {
                func_names += function.name;
                func_names += function.name.ascii_up ();
            }

            func_name_regex = string.joinv ("|", func_names);
        }

        return func_name_regex;
    }

    private Gee.ArrayList<Evaluator> root_rules () {
        return new Gee.ArrayList<Evaluator>.wrap ({
            new Evaluator (/[ \t]/, token ("[[ignore]]")),
            new Evaluator (/[A-Z]+[0-9]+/, token ("cell-name")),
            new Evaluator (/=/, token ("equal")),
            new Evaluator (get_func_name_regex (), token ("identifier")),
            new Evaluator (/\(/, token ("left-parenthese")), // vala-lint=space-before-paren
            new Evaluator (/\)/, token ("right-parenthese")),
            new Evaluator (/,/, token ("comma")),
            new Evaluator (/:/, token ("colon")),
            new Evaluator (/\d+(\.\d+)?/, token ("number")), // vala-lint=space-before-paren
            new Evaluator (/\+/, token ("plus")),
            new Evaluator (/\*/, token ("star")),
            new Evaluator (/-/, token ("dash")),
            new Evaluator (/\//, token ("slash")),
            new Evaluator (/%/, token ("percent")),
            new Evaluator (/\^/, token ("carat")),
            new Evaluator (/\D+/, token ("text"))
        });
    }
}
