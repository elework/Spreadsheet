public class Spreadsheet.StyleModal : Gtk.Grid {
    public FontStyle font_style { get; construct; }
    public CellStyle cell_style { get; construct; }

    public StyleModal (FontStyle font_style, CellStyle cell_style) {
        var style_stack = new Gtk.Stack ();
        style_stack.add_titled (fonts_grid (font_style), "fonts-grid", "Fonts");
        style_stack.add_titled (cells_grid (cell_style), "cells-grid", "Cells");

        var style_stacksw = new Gtk.StackSwitcher ();
        style_stacksw.valign = Gtk.Align.CENTER;
        style_stacksw.set_stack (style_stack);

        margin = 12;
        attach (style_stacksw, 0, 0, 1, 1);
        attach (style_stack, 0, 1, 1, 1);
    }

    private Gtk.Grid fonts_grid (FontStyle font_style) {
        var fonts_grid = new Gtk.Grid ();
        fonts_grid.margin_top = 6;

        var color_label = new Gtk.Label ("Font Color");
        color_label.get_style_context ().add_class ("h4");

        var color_button = new Gtk.ColorButton ();
        font_style.bind_property ("fontcolor", color_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        fonts_grid.attach (color_label, 0, 0, 1, 1);
        fonts_grid.attach (color_button, 0, 1, 1, 1);

        return fonts_grid;
    }

    private Gtk.Grid cells_grid (CellStyle cell_style) {
        var cells_grid = new Gtk.Grid ();
        cells_grid.margin_top = 6;

        var bg_label = new Gtk.Label ("Fill Color");
        bg_label.get_style_context ().add_class ("h4");

        var bg_button = new Gtk.ColorButton ();
        cell_style.bind_property ("background", bg_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var sr_label = new Gtk.Label ("Stroke Color");
        sr_label.get_style_context ().add_class ("h4");

        var sr_button = new Gtk.ColorButton ();
        cell_style.bind_property ("stroke", sr_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        cells_grid.attach (bg_label, 0, 0, 1, 1);
        cells_grid.attach (bg_button, 0, 1, 1, 1);
        cells_grid.attach (sr_label, 0, 2, 1, 1);
        cells_grid.attach (sr_button, 0, 3, 1, 1);

        return cells_grid;
    }
}
