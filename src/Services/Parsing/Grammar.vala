/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public abstract class Spreadsheet.Services.Parsing.Grammar : Object {
    public Gee.HashMap<string, Gee.ArrayList<Evaluator>> rules {
        get;
        set;
        default = new Gee.HashMap<string, Gee.ArrayList<Evaluator>> ();
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
