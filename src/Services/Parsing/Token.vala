/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Services.Parsing.Token {

    public string kind;
    public string lexeme;
    public Token (string? k, string l) {
        kind = k;
        lexeme = l;
    }
}
