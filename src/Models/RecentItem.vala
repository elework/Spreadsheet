/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Models.RecentItem : Object {
    public string path { get; construct; }

    public RecentItem (string path) {
        Object (
            path: path
        );
    }
}
