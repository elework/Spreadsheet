/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Services.Formula.FormulaGrammar : Parsing.Grammar {
    private string func_name_regex = "";

    public FormulaGrammar () {
        rules["root"] = root_rules ();
    }

    private string get_func_name_regex () {
        if (func_name_regex == "") {
            string[]? func_names = null;
            foreach (var function in FunctionManager.get_default ().functions) {
                func_names += function.name;
                func_names += function.name.ascii_up ();
            }

            func_name_regex = string.joinv ("|", func_names);
        }

        return func_name_regex;
    }

    private Gee.ArrayList<Parsing.Evaluator> root_rules () {
        return new Gee.ArrayList<Parsing.Evaluator>.wrap ({
            new Parsing.Evaluator (/[ \t]/, token ("[[ignore]]")),
            new Parsing.Evaluator (/[A-Z]+[0-9]+/, token ("cell-name")),
            new Parsing.Evaluator (/=/, token ("equal")),
            new Parsing.Evaluator (get_func_name_regex (), token ("identifier")),
            new Parsing.Evaluator (/\(/, token ("left-parenthese")), // vala-lint=space-before-paren
            new Parsing.Evaluator (/\)/, token ("right-parenthese")),
            new Parsing.Evaluator (/,/, token ("comma")),
            new Parsing.Evaluator (/:/, token ("colon")),
            new Parsing.Evaluator (/\d+(\.\d+)?/, token ("number")), // vala-lint=space-before-paren
            new Parsing.Evaluator (/\+/, token ("plus")),
            new Parsing.Evaluator (/\*/, token ("star")),
            new Parsing.Evaluator (/-/, token ("dash")),
            new Parsing.Evaluator (/\//, token ("slash")),
            new Parsing.Evaluator (/%/, token ("percent")),
            new Parsing.Evaluator (/\^/, token ("carat")),
            new Parsing.Evaluator (/\D+/, token ("text"))
        });
    }
}
