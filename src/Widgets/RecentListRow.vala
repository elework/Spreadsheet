/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Widgets.RecentListRow : Gtk.Grid {
    public string icon_name { get; set; }
    public string filename { get; set; }
    public string path { get; set; }

    construct {
        margin_top = 6;
        margin_bottom = 6;
        margin_start= 6;
        margin_end = 6;

        icon_name = "image-missing";
        filename = "";
        path = "";

        var icon = new Gtk.Image.from_icon_name (icon_name) {
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            margin_end = 6,
            icon_size = Gtk.IconSize.LARGE
        };

        var filename_label = new Gtk.Label (filename) {
            halign = Gtk.Align.START,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        filename_label.add_css_class (Granite.STYLE_CLASS_H3_LABEL);

        var path_label = new Gtk.Label (path) {
            halign = Gtk.Align.START,
            wrap = true,
            wrap_mode = Pango.WrapMode.WORD
        };
        path_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        attach (icon, 0, 0, 1, 2);
        attach (filename_label, 1, 0, 1, 1);
        attach (path_label, 1, 1, 1, 1);

        bind_property ("icon_name", icon, "icon_name", BindingFlags.DEFAULT);
        bind_property ("filename", filename_label, "label", BindingFlags.DEFAULT);
        bind_property ("path", path_label, "label", BindingFlags.DEFAULT);
    }
}
