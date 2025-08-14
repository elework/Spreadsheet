/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public abstract class Spreadsheet.Services.Formula.AST.Expression : Object {
    public abstract Value eval (Page sheet);
}
