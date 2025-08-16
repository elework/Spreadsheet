/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Widgets.IconLabelRow : Gtk.Box {
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
        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 12;

        var icon = new Gtk.Image.from_icon_name (icon_name);

        var label = new Granite.HeaderLabel (primary_text) {
            secondary_text = secondary_text
        };

        append (icon);
        append (label);
    }
}
