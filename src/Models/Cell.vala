/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Services.Formula;
using Spreadsheet.Services.Parsing;

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
                var parser = new FormulaParser (new Lexer (new FormulaGrammar ()).tokenize (value));
                var expression = parser.parse ();

                var eval = expression.eval (page);
                if (eval.type () == typeof (double)) {
                    display_content = ((double)eval).to_string ();
                } else if (eval.type () == typeof (string)) {
                    display_content = (string)eval;
                }
            } catch (ParserError err) {
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
