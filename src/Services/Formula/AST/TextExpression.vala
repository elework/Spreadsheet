/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Services.Formula.AST.TextExpression : Expression {
    public string text { get; construct; }

    public TextExpression (string text) {
        Object (
            text: text
        );
    }

    public override Value eval (Models.Page sheet) {
        return text;
    }
}
