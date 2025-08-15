/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.CSV.CSVGrammar : Grammar {
    public CSVGrammar () {
        rules["root"] = root_rules ();
        rules["text"] = text_rules ();
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
