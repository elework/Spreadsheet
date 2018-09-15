public class Spreadsheet.StyleModal : Gtk.Grid {
    public CellStyle cell_style { get; construct; }

    public StyleModal (CellStyle cell_style) {
        margin = 12;

        var bg_button = new Gtk.ColorButton ();
        cell_style.bind_property ("background", bg_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        attach (bg_button, 0, 0, 1, 1);
    }
}
