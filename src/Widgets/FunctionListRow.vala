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
        doc_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        box.pack_start (name_label);
        box.pack_start (doc_label);

        selectable = false;
        margin_top = 3;
        margin_bottom = 3;

        realize.connect (() => {
            // Use the pointing hand cursor instead of the normal arrow cursor
            get_window ().cursor = new Gdk.Cursor.from_name (get_display (), "pointer");
        });

        child = box;
    }
}
