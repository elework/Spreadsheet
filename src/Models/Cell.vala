/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Models.Cell : Object {

    public weak Page page { get; set; }
    public int line { get; set; }
    public int column { get; set; }
    public string display_content { get; set; default = ""; }
    public string formula {
        get {
            return _formula;
        }
        set {
            _formula = value;

            if (_formula == "") {
                display_content = _formula;
                return;
            }

            try {
                var grammar = new Services.Formula.FormulaGrammar ();
                var lexer = new Services.Parsing.Lexer (grammar);
                var parser = new Services.Formula.FormulaParser (lexer.tokenize (value));
                var expression = parser.parse ();

                var eval = expression.eval (page);
                if (eval.type () == typeof (double)) {
                    display_content = ((double)eval).to_string ();
                } else if (eval.type () == typeof (string)) {
                    display_content = (string)eval;
                }
            } catch (Services.Parsing.ParserError err) {
                debug ("Error: " + err.message);
                display_content = "Error";
            }
        }
    }
    private string _formula = "";
    public bool selected { get; set; default = false; }
    public FontStyle font_style { get; set; default = new FontStyle (); }
    public CellStyle cell_style { get; set; default = new CellStyle (); }
}
