public class Spreadsheet.StyleModal : Gtk.Grid {
    public CellStyle cell_style { get; construct; }

    public StyleModal (CellStyle cell_style) {
        var style_stack = new Gtk.Stack ();
        style_stack.add_titled (fonts_grid (), "fonts-grid", "Fonts");
        style_stack.add_titled (cells_grid (cell_style), "cells-grid", "Cells");

        var style_stacksw = new Gtk.StackSwitcher ();
        style_stacksw.valign = Gtk.Align.CENTER;
        style_stacksw.set_stack (style_stack);

        margin = 12;
        attach (style_stacksw, 0, 0, 1, 1);
        attach (style_stack, 0, 1, 1, 1);
    }

    private Gtk.Grid fonts_grid () {
        var fonts_grid = new Gtk.Grid ();
        fonts_grid.margin = 12;
        return fonts_grid;
    }

    private Gtk.Grid cells_grid (CellStyle cell_style) {
        var cells_grid = new Gtk.Grid ();
        cells_grid.margin_top = 6;

        var bg_label = new Gtk.Label ("Fill Color");
        bg_label.get_style_context ().add_class ("h4");

        var bg_button = new Gtk.ColorButton ();
        cell_style.bind_property ("background", bg_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        cells_grid.attach (bg_label, 0, 0, 1, 1);
        cells_grid.attach (bg_button, 0, 1, 1, 1);

        return cells_grid;
    }
}
