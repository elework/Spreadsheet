/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Models.StringObject : Object {
    public string string { get; construct; }

    public StringObject (string str) {
        Object (
            string: str
        );
    }
}
