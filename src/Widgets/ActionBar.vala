public class Spreadsheet.Widgets.ActionBar : Gtk.Bin {
    public signal void zoom_level_changed ();

    private const double ZOOM_LEVEL_MIN = 10.0;
    private const double ZOOM_LEVEL_MAX = 400.0;
    private const double ZOOM_LEVEL_STEP = 10.0;
    private const double ZOOM_LEVEL_DEFAULT = 100.0;

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
        zoom_scale_adj = new Gtk.Adjustment (
            zoom_level,
            ZOOM_LEVEL_MIN,
            ZOOM_LEVEL_MAX,
            ZOOM_LEVEL_STEP,
            ZOOM_LEVEL_STEP,
            0.0
        );

        var zoom_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, zoom_scale_adj) {
            tooltip_text = (_("Zoom in/out the sheet")),
            draw_value = false,
            margin_top = 3,
            margin_bottom = 3,
            margin_start = 3,
            margin_end = 12
        };
        zoom_scale.set_size_request (100, 0);

        var zoom_level_button = new Gtk.Button.with_label (zoom_level_text) {
            tooltip_text = (_("Reset to the default zoom level")),
            margin_end = 12
        };

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
            zoom_level = ZOOM_LEVEL_DEFAULT;
        });
    }
}
