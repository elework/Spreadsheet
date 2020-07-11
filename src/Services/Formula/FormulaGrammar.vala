using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.Formula.FormulaGrammar : Grammar {
    private string func_name_regex = "";

    public FormulaGrammar () {
        rules["root"] = root_rules ();
    }

    private string get_func_name_regex () {
        if (func_name_regex != "") {
            return func_name_regex;
        }
 
        for (int i = 0; i < App.functions.size; i++) {
            func_name_regex += "%s|%s".printf (App.functions[i].name, App.functions[i].name.ascii_up ());

            if (i + 1 != App.functions.size) {
                func_name_regex += "|";
            }
        }

        return func_name_regex;
    }

    private Gee.ArrayList<Evaluator> root_rules () {
        return new Gee.ArrayList<Evaluator>.wrap ({
            new Evaluator (/[ \t]/, token ("[[ignore]]")),
            new Evaluator (/[A-Z]+[0-9]+/, token ("cell-name")),
            new Evaluator (/=/, token ("equal")),
            new Evaluator (new GLib.Regex (get_func_name_regex ()), token ("identifier")),
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
            new Evaluator (/\^/, token ("carat")),
            new Evaluator (/.*/, token ("text"))
        });
    }
}
