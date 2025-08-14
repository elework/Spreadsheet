/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

/**
* Class representing a whole Spreadsheet file.
*/
public class Spreadsheet.Models.SpreadSheet : Object {
    public string title { get; set; }
    public string file_path { get; set; }
    public Gee.ArrayList<Page> pages { get; set; default = new Gee.ArrayList<Page> (); }

    public void add_page (Page p) {
        p.document = this;
        pages.add (p);
    }
}
