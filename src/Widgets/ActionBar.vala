/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Widgets.ActionBar : Adw.Bin {
    public Page active_page {
        get {
            return _active_page;
        }
        set {
            _active_page = value;

            active_page.bind_property ("zoom_level",
                zoom_scale_adj, "value",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

            active_page.bind_property ("zoom_level",
                zoom_level_button, "label",
                BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
                (binding, _zoom_level, ref _label) => {
                    _label = "%i %%".printf ((int) _zoom_level);
                    return true;
                });
        }
    }
    private Page _active_page;

    private Gtk.Adjustment zoom_scale_adj;
    private Gtk.Button zoom_level_button;

    construct {
        zoom_scale_adj = new Gtk.Adjustment (
            Page.ZOOM_LEVEL_DEFAULT,
            Page.ZOOM_LEVEL_MIN,
            Page.ZOOM_LEVEL_MAX,
            Page.ZOOM_LEVEL_STEP,
            Page.ZOOM_LEVEL_STEP,
            0.0
        );

        var zoom_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, zoom_scale_adj) {
            tooltip_text = _("Zoom in/out the sheet"),
            draw_value = false,
            margin_top = 3,
            margin_bottom = 3,
            margin_start = 3,
            margin_end = 12
        };
        zoom_scale.set_size_request (100, 0);

        zoom_level_button = new Gtk.Button () {
            tooltip_text = _("Reset to the default zoom level"),
            margin_end = 12
        };

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_end (zoom_level_button);
        action_bar.pack_end (zoom_scale);

        child = action_bar;

        zoom_level_button.clicked.connect (() => {
            active_page.zoom_level = Page.ZOOM_LEVEL_DEFAULT;
        });
    }
}
