/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Services.FuncSearchList : Object {
    public string funcsearchlist_item { get; set; }

    public FuncSearchList (string name, string desctiption) {
        funcsearchlist_item = "%s %s".printf (name, desctiption);
    }
}
