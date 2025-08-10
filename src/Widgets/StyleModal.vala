public class Spreadsheet.StyleModal : Gtk.Grid {
    public StyleModal (FontStyle font_style, CellStyle cell_style) {
        var style_stack = new Gtk.Stack ();
        style_stack.add_titled (create_fonts_grid (font_style), "fonts-grid", _("Font"));
        style_stack.add_titled (create_cells_grid (cell_style), "cells-grid", _("Cell"));

        var style_stack_switcher = new Gtk.StackSwitcher () {
            homogeneous = true,
            halign = Gtk.Align.CENTER,
            stack = style_stack
        };

        attach (style_stack_switcher, 0, 0, 1, 1);
        attach (style_stack, 0, 1, 1, 1);
    }

    private Gtk.Grid create_fonts_grid (FontStyle font_style) {
        var style_header_label = new Granite.HeaderLabel (_("Style"));

        // TODO: Add a widget that can choose a font and its size

        var bold_icon = new Gtk.Image.from_icon_name ("format-text-bold-symbolic", Gtk.IconSize.BUTTON);
        var bold_button = new Gtk.ToggleButton () {
            child = bold_icon,
            focus_on_click = false,
            tooltip_text = _("Bold")
        };

        var italic_icon = new Gtk.Image.from_icon_name ("format-text-italic-symbolic", Gtk.IconSize.BUTTON);
        var italic_button = new Gtk.ToggleButton () {
            child = italic_icon,
            focus_on_click = false,
            tooltip_text = _("Italic")
        };

        var underline_icon = new Gtk.Image.from_icon_name ("format-text-underline-symbolic", Gtk.IconSize.BUTTON);
        var underline_button = new Gtk.ToggleButton () {
            child = underline_icon,
            focus_on_click = false,
            tooltip_text = _("Underline")
        };

        var strikethrough_icon = new Gtk.Image.from_icon_name ("format-text-strikethrough-symbolic", Gtk.IconSize.BUTTON);
        var strikethrough_button = new Gtk.ToggleButton () {
            child = strikethrough_icon,
            focus_on_click = false,
            tooltip_text = _("Strikethrough")
        };

        font_style.bind_property ("is_bold",
                bold_button, "active",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        font_style.bind_property ("is_italic",
                italic_button, "active",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        font_style.bind_property ("is_underline",
                underline_button, "active",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        font_style.bind_property ("is_strikethrough",
                strikethrough_button, "active",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var style_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        style_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        style_box.pack_start (bold_button);
        style_box.pack_start (italic_button);
        style_box.pack_start (underline_button);
        style_box.pack_start (strikethrough_button);

        var color_header_label = new Granite.HeaderLabel (_("Color"));

        var color_button = new Gtk.ColorButton () {
            halign = Gtk.Align.START,
            tooltip_text = _("Set font color of a selected cell")
        };

        font_style.bind_property ("font_color",
                color_button, "rgba",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var color_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
            halign = Gtk.Align.START,
            tooltip_text = _("Reset font color of a selected cell to black")
        };

        var right_grid = new Gtk.Grid ();
        right_grid.attach (style_header_label, 0, 0, 1, 1);
        right_grid.attach (style_box, 0, 1, 1, 1);
        right_grid.attach (color_header_label, 0, 2, 1, 1);
        right_grid.attach (color_button, 0, 3, 1, 1);
        right_grid.attach (color_reset_button, 1, 3, 1, 1);

        var fonts_grid = new Gtk.Grid () {
            margin_top = 6,
            orientation = Gtk.Orientation.VERTICAL,
            column_spacing = 6
        };
        fonts_grid.attach (right_grid, 0, 0, 1, 1);

        // Make the buttons sensitive only there are changes from the defaults
        font_style.bind_property ("font_color",
                color_reset_button, "sensitive",
                BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
                (binding, _font_color, ref _sensitive) => {
                    _sensitive = !((Gdk.RGBA) _font_color).equal (FontStyle.FONT_COLOR_DEFAULT);
                    return true;
                });

        color_reset_button.clicked.connect (() => {
            font_style.reset_color ();
        });

        return fonts_grid;
    }

    private Gtk.Grid create_cells_grid (CellStyle cell_style) {
        var bg_header_label = new Granite.HeaderLabel (_("Fill"));

        var bg_color_button = new Gtk.ColorButton () {
            halign = Gtk.Align.START,
            tooltip_text = _("Set fill color of a selected cell")
        };

        var bg_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
            halign = Gtk.Align.START,
            tooltip_text = _("Remove fill color of a selected cell")
        };

        var stroke_header_label = new Granite.HeaderLabel (_("Stroke"));

        var stroke_color_button = new Gtk.ColorButton () {
            halign = Gtk.Align.START,
            tooltip_text = _("Set stroke color of a selected cell")
        };

        var stroke_width_spin = new Gtk.SpinButton.with_range (
            CellStyle.STROKE_WIDTH_MIN,
            CellStyle.STROKE_WIDTH_MAX,
            CellStyle.STROKE_WIDTH_STEP
        ) {
            halign = Gtk.Align.START,
            tooltip_text = _("Set the border width of a selected cell")
        };

        var stroke_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
            halign = Gtk.Align.START,
            tooltip_text = _("Remove stroke color of a selected cell")
        };

        cell_style.bind_property ("bg_color",
                bg_color_button, "rgba",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        cell_style.bind_property ("stroke_color",
                stroke_color_button, "rgba",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        cell_style.bind_property ("stroke_width",
                stroke_width_spin, "value",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var cells_grid = new Gtk.Grid () {
            margin_top = 6,
            column_spacing = 6
        };
        cells_grid.attach (bg_header_label, 0, 0, 1, 1);
        cells_grid.attach (bg_color_button, 0, 1, 1, 1);
        cells_grid.attach (bg_reset_button, 1, 1, 1, 1);
        cells_grid.attach (stroke_header_label, 0, 2, 1, 1);
        cells_grid.attach (stroke_color_button, 0, 3, 1, 1);
        cells_grid.attach (stroke_width_spin, 1, 3, 1, 1);
        cells_grid.attach (stroke_reset_button, 2, 3, 1, 1);

        // Make the buttons sensitive only there are changes from the defaults
        cell_style.bind_property ("bg_color",
                bg_reset_button, "sensitive",
                BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
                (binding, _bg_color, ref _sensitive) => {
                    _sensitive = !((Gdk.RGBA) _bg_color).equal (CellStyle.BG_COLOR_DEFAULT);
                    return true;
                });
        cell_style.bind_property ("stroke_color",
                stroke_reset_button, "sensitive",
                BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
                (binding, _stroke_color, ref _sensitive) => {
                    _sensitive = !((Gdk.RGBA) _stroke_color).equal (CellStyle.STROKE_COLOR_DEFAULT);
                    return true;
                });
        cell_style.bind_property ("stroke_color",
                stroke_width_spin, "sensitive",
                BindingFlags.SYNC_CREATE | BindingFlags.DEFAULT,
                (binding, _stroke_color, ref _sensitive) => {
                    _sensitive = !((Gdk.RGBA) _stroke_color).equal (CellStyle.STROKE_COLOR_DEFAULT);
                    return true;
                });

        bg_reset_button.clicked.connect (() => {
            cell_style.reset_background_color ();
        });
        stroke_reset_button.clicked.connect (() => {
            cell_style.reset_stroke_color ();
            cell_style.reset_stroke_width ();
        });

        return cells_grid;
    }
}
