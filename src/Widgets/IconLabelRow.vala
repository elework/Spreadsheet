/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Widgets.IconLabelRow : Gtk.Grid {
    public string icon_name { get; set; }
    public string primary_text { get; set; }
    public string secondary_text { get; set; }

    construct {
        margin_top = 6;
        margin_bottom = 6;
        margin_start= 6;
        margin_end = 6;

        var icon = new Gtk.Image () {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin_end = 6,
            icon_size = Gtk.IconSize.LARGE
        };

        var primary_label = new Gtk.Label (null) {
            halign = Gtk.Align.START,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        primary_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var secondary_label = new Gtk.Label (null) {
            halign = Gtk.Align.START,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        secondary_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        attach (icon, 0, 0, 1, 2);
        attach (primary_label, 1, 0, 1, 1);
        attach (secondary_label, 1, 1, 1, 1);

        bind_property ("icon_name", icon, "icon_name", BindingFlags.DEFAULT);
        bind_property ("primary_text", primary_label, "label", BindingFlags.DEFAULT);
        bind_property ("secondary_text", secondary_label, "label", BindingFlags.DEFAULT);
    }
}
