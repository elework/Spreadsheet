/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public abstract class Spreadsheet.Services.Formula.AST.Expression : Object {
    public abstract Value eval (Models.Page sheet);
}
