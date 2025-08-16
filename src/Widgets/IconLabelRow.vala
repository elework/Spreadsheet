/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Widgets.IconLabelRow : Gtk.ListBoxRow {
    public string icon_name { get; construct; }
    public string primary_text { get; construct; }
    public string secondary_text { get; construct; }

    public IconLabelRow (string icon_name, string primary_text, string secondary_text) {
        Object (
            icon_name: icon_name,
            primary_text: primary_text,
            secondary_text: secondary_text
        );
    }

    construct {
        var icon = new Gtk.Image.from_icon_name (icon_name) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            icon_size = Gtk.IconSize.LARGE
        };

        var primary_label = new Gtk.Label (primary_text) {
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        primary_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var secondary_label = new Gtk.Label (secondary_text) {
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        secondary_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var grid = new Gtk.Grid () {
            margin_top = 6,
            margin_bottom = 6,
            margin_start= 6,
            margin_end = 6
        };
        grid.attach (icon, 0, 0, 1, 2);
        grid.attach (primary_label, 1, 0, 1, 1);
        grid.attach (secondary_label, 1, 1, 1, 1);

        child = grid;
    }
}
