/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

/**
* A single page of a Spreadsheet
*/
public class Spreadsheet.Models.Page : Object {
    public const int ZOOM_LEVEL_MIN = 10;
    public const int ZOOM_LEVEL_MAX = 400;
    public const int ZOOM_LEVEL_STEP = 10;
    public const int ZOOM_LEVEL_DEFAULT = 100;

    public weak SpreadSheet document { get; set; }
    public string title { get; set; }
    public Gee.ArrayList<Cell> cells { get; set; default = new Gee.ArrayList<Cell> (); }
    public int lines { get; private set; default = 0; }
    public int columns { get; private set; default = 0; }
    public int zoom_level { get; set; default = 100; }

    construct {
        App.settings.bind ("zoom-level", this, "zoom_level", SettingsBindFlags.DEFAULT);
    }

    public Page.empty (int cols = 100, int lines = 100) {
        for (int i = 0; i < cols; i++) {
            for (int j = 0; j < lines; j++) {
                var cell = new Cell () {
                    line = j,
                    column = i
                };
                if (i == 0 && j == 0) {
                    cell.selected = true;
                }
                add_cell (cell);
            }
        }
    }

    public void add_cell (Cell c) {
        c.page = this;
        cells.add (c);
        if (c.line + 1 > lines) {
            lines = c.line + 1;
        }
        if (c.column + 1 > columns) {
            columns = c.column + 1;
        }
    }

    public void zoom_out () {
        int level = zoom_level - ZOOM_LEVEL_STEP;
        if (level < ZOOM_LEVEL_MIN) {
            return;
        }

        zoom_level = level;
    }

    public void zoom_in () {
        int level = zoom_level + ZOOM_LEVEL_STEP;
        if (level > ZOOM_LEVEL_MAX) {
            return;
        }

        zoom_level = level;
    }

    public void zoom_reset () {
        zoom_level = ZOOM_LEVEL_DEFAULT;
    }
}
