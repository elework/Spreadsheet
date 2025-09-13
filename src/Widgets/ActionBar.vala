/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Services;

public class Spreadsheet.Widgets.ActionBar : Adw.Bin {
    private Gtk.Adjustment zoom_scale_adj;

    construct {
        unowned var zoom_manager = ZoomManager.get_default ();

        zoom_scale_adj = new Gtk.Adjustment (
            ZoomManager.ZOOM_LEVEL_DEFAULT,
            ZoomManager.ZOOM_LEVEL_MIN,
            ZoomManager.ZOOM_LEVEL_MAX,
            ZoomManager.ZOOM_LEVEL_STEP,
            ZoomManager.ZOOM_LEVEL_STEP,
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

        var zoom_level_button = new Gtk.Button () {
            tooltip_text = _("Reset to the default zoom level"),
            margin_end = 12
        };

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_end (zoom_level_button);
        action_bar.pack_end (zoom_scale);

        child = action_bar;

        zoom_manager.bind_property ("zoom_level",
            zoom_scale_adj, "value",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);

        zoom_scale_adj.bind_property ("value",
            zoom_level_button, "label",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _value, ref _label) => {
                var zoom_level = (double) _value;
                // Display as integer because we don't need precise zoom level
                _label = "%i %%".printf ((int) zoom_level);
                return true;
            });

        zoom_level_button.clicked.connect (() => {
            zoom_manager.zoom_reset ();
        });
    }
}
