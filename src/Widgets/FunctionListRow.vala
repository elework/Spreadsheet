/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Widgets.FunctionListRow : Gtk.ListBoxRow {
    public Function function { get; construct; }

    public FunctionListRow (Function function) {
        Object (
            function: function
        );
    }

    construct {
        var name_label = new Gtk.Label (function.name) {
            justify = Gtk.Justification.LEFT,
            halign = Gtk.Align.START,
        };

        var doc_label = new Gtk.Label (function.doc) {
            justify = Gtk.Justification.FILL,
            halign = Gtk.Align.START,
        };
        doc_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.append (name_label);
        box.append (doc_label);

        selectable = false;
        margin_top = 3;
        margin_bottom = 3;

        realize.connect (() => {
            // Use the pointing hand cursor instead of the normal arrow cursor
            cursor = new Gdk.Cursor.from_name ("pointer", null);
        });

        child = box;
    }
}
