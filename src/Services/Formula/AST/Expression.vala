/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

using Spreadsheet.Models;

public abstract class Spreadsheet.Services.Formula.AST.Expression : Object {
    public abstract Value eval (Page sheet);
}
