/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Services.Formula.AST.NumberExpression : Expression {
    public double number { get; construct; }

    public NumberExpression (double number) {
        Object (
            number: number
        );
    }

    public override Value eval (Models.Page sheet) {
        return number;
    }
}
