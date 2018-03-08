public class Spreadsheet.StyleModal : Gtk.Grid {
    public CellStyle style { get; construct; }

    public StyleModal (CellStyle style) {
        Object (style: style);
    }

    construct {
        margin = 12;

        var bg_button = new Gtk.ColorButton ();
        style.bind_property ("background", bg_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        attach (bg_button, 0, 0, 1, 1);
    }
}