public class Spreadsheet.Widgets.ActionBar : Gtk.Bin {
    public signal void zoom_level_changed ();

    private Gtk.Adjustment zoom_scale_adj;

    public int zoom_level {
        get {
            return App.settings.get_int ("zoom-level");
        }
        set {
            zoom_scale_adj.value = value;
            App.settings.set_int ("zoom-level", value);
        }
    }

    public string zoom_level_text {
        owned get {
            return "%i %%".printf (zoom_level);
        }
    }

    construct {
        zoom_scale_adj = new Gtk.Adjustment (zoom_level, 10, 400, 10, 10, 0);

        var zoom_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, zoom_scale_adj);
        zoom_scale.tooltip_text = (_("Zoom in/out the sheet"));
        zoom_scale.set_size_request (100, 0);
        zoom_scale.draw_value = false;
        zoom_scale.margin_top = 3;
        zoom_scale.margin_bottom = 3;
        zoom_scale.margin_start = 3;
        zoom_scale.margin_end = 12;

        var zoom_level_button = new Gtk.Button.with_label (zoom_level_text);
        zoom_level_button.tooltip_text = (_("Reset to the default zoom level"));
        zoom_level_button.margin_end = 12;

        var action_bar = new Gtk.ActionBar ();
        action_bar.pack_end (zoom_level_button);
        action_bar.pack_end (zoom_scale);

        child = action_bar;

        zoom_scale_adj.value_changed.connect (() => {
            zoom_level = (int) zoom_scale_adj.value;
            zoom_level_button.label = zoom_level_text;
            zoom_level_changed ();
        });

        zoom_level_button.clicked.connect ((event) => {
            zoom_level = 100;
        });
    }
}
