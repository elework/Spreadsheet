/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Services.CSV.CSVWriter : Object {
    public Page page { get; construct set; }

    public CSVWriter (Page page) {
        Object (page: page);
    }

    public string to_string () {
        Gee.ArrayList<Gee.ArrayList<string>> table = new Gee.ArrayList<Gee.ArrayList<string>> ();
        int max_records = 0;
        foreach (var cell in page.cells) {
            while (table.size - 1 < cell.line) {
                table.add (new Gee.ArrayList<string> ());
            }
            var line = table[cell.line];
            while (line.size - 1 < cell.column) {
                line.add ("");
            }
            table[cell.line][cell.column] = cell.formula;
            if (cell.column > max_records) {
                max_records = cell.column;
            }
        }
        string csv = "";
        foreach (var line in table) {
            bool first = true;
            int records = 0;
            foreach (var cell in line) {
                if (first) {
                    first = false;
                } else {
                    csv += ",";
                }
                csv += @"\"$cell\"";
                records++;
            }
            while (records < max_records) {
                csv += ",";
            }
            csv += "\n";
        }
        return csv;
    }

    public void write_to_file (string path) {
        try {
            FileUtils.set_contents (path, to_string ());
        } catch (Error e) {
            critical ("Error: " + e.message);
        }
    }
}
