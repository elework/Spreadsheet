/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Services.Formula.AST.NumberExpression : Expression {
    public double number { get; construct; }

    public NumberExpression (double number) {
        Object (
            number: number
        );
    }

    public override Value eval (Page sheet) {
        return number;
    }
}
