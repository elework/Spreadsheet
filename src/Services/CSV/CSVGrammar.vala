/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Services.CSV.CSVGrammar : Parsing.Grammar {
    public CSVGrammar () {
        rules["root"] = root_rules ();
        rules["text"] = text_rules ();
    }

    private Gee.ArrayList<Parsing.Evaluator> root_rules () {
        return new Gee.ArrayList<Parsing.Evaluator>.wrap ({
            new Parsing.Evaluator (/,/, token ("comma")),
            new Parsing.Evaluator (/\n/, token ("new-line")),
            new Parsing.Evaluator (re ("\""), token ("quote"), false, { "text" }),
            new Parsing.Evaluator (/./, token ("char"))
        });
    }

    private Gee.ArrayList<Parsing.Evaluator> text_rules () {
        return new Gee.ArrayList<Parsing.Evaluator>.wrap ({
            new Parsing.Evaluator (/""/, (m) => { return new Parsing.Token ("char", "\""); }),
            new Parsing.Evaluator (re ("\""), token ("quote"), true),
            new Parsing.Evaluator (/./, token ("char")),
        });
    }
}
