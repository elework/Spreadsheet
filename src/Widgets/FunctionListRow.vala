/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Widgets.FunctionListRow : Gtk.Box {
    public string name_text { get; set; }
    public string doc_text { get; set; }

    public FunctionListRow () {
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;
        spacing = 0;
        margin_top = 3;
        margin_bottom = 3;

        var name_label = new Gtk.Label (name_text) {
            justify = Gtk.Justification.LEFT,
            halign = Gtk.Align.START,
        };

        var doc_label = new Gtk.Label (doc_text) {
            justify = Gtk.Justification.FILL,
            halign = Gtk.Align.START,
        };
        doc_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        append (name_label);
        append (doc_label);

        realize.connect (() => {
            // Use the pointing hand cursor instead of the normal arrow cursor
            cursor = new Gdk.Cursor.from_name ("pointer", null);
        });

        bind_property ("name_text", name_label, "label", BindingFlags.DEFAULT);
        bind_property ("doc_text", doc_label, "label", BindingFlags.DEFAULT);
    }
}
