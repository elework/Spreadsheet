public class Spreadsheet.Widgets.ActionBar : Gtk.ActionBar {
    public signal void zoom_level_changed ();

    private Gtk.Adjustment zoom_scale_adj;
    public int zoom_level {
        get {
            return (int) zoom_scale_adj.value;
        }
        set {
            zoom_scale_adj.value = value;
        }
    }

    public string zoom_level_text {
        owned get {
            return "%i %%".printf (zoom_level);
        }
    }

    public ActionBar () {
    }

    construct {
        zoom_scale_adj = new Gtk.Adjustment (100, 10, 400, 10, 10, 0);
        var zoom_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, zoom_scale_adj);
        zoom_scale.set_size_request (100, 0);
        zoom_scale.draw_value = false;

        var zoom_level_label = new Gtk.Label (zoom_level_text);

        pack_end (zoom_level_label);
        pack_end (zoom_scale);

        foreach (var widget in get_children ()) {
            widget.margin = 3;
            widget.margin_end = 12;
        }

        zoom_scale_adj.value_changed.connect (() => {
            zoom_level_label.label = zoom_level_text;
            zoom_level_changed ();
        });
    }
}
