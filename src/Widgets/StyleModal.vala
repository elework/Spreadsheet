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
        // TODO: Add a widget that can choose a font and its size

        var bold_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            tooltip_text = _("Bold")
        };
        bold_button.add (new Gtk.Image.from_icon_name ("format-text-bold-symbolic", Gtk.IconSize.BUTTON));

        var italic_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            tooltip_text = _("Italic")
        };
        italic_button.add (new Gtk.Image.from_icon_name ("format-text-italic-symbolic", Gtk.IconSize.BUTTON));

        var underline_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            tooltip_text = _("Underline")
        };
        underline_button.add (new Gtk.Image.from_icon_name ("format-text-underline-symbolic", Gtk.IconSize.BUTTON));

        var strikethrough_button = new Gtk.ToggleButton () {
            focus_on_click = false,
            tooltip_text = _("Strikethrough")
        };
        strikethrough_button.add (new Gtk.Image.from_icon_name ("format-text-strikethrough-symbolic", Gtk.IconSize.BUTTON));

        font_style.bind_property ("is_bold", bold_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        font_style.bind_property ("is_italic", italic_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        font_style.bind_property ("is_underline", underline_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        font_style.bind_property ("is_strikethrough", strikethrough_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var style_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        style_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        style_box.pack_start (bold_button);
        style_box.pack_start (italic_button);
        style_box.pack_start (underline_button);
        style_box.pack_start (strikethrough_button);

        var color_button = new Gtk.ColorButton () {
            halign = Gtk.Align.START,
            tooltip_text = _("Set font color of a selected cell")
        };
        font_style.bind_property ("fontcolor", color_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var color_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
            halign = Gtk.Align.START,
            tooltip_text = _("Reset font color of a selected cell to black")
        };

        var right_grid = new Gtk.Grid ();
        right_grid.attach (new Granite.HeaderLabel (_("Style")), 0, 0, 1, 1);
        right_grid.attach (style_box, 0, 1, 1, 1);
        right_grid.attach (new Granite.HeaderLabel (_("Color")), 0, 2, 1, 1);
        right_grid.attach (color_button, 0, 3, 1, 1);
        right_grid.attach (color_reset_button, 1, 3, 1, 1);

        var fonts_grid = new Gtk.Grid () {
            margin_top = 6,
            orientation = Gtk.Orientation.VERTICAL,
            column_spacing = 6
        };
        fonts_grid.attach (right_grid, 0, 0, 1, 1);

        // Set the sensitivity of the color_reset_button by whether it has already reset font color to the default one or not when…
        // 1. widgets are created
        Gdk.RGBA font_default_color = { 0, 0, 0, 1 };
        color_reset_button.sensitive = check_color (color_button, font_default_color);
        // 2. user clicks the color_button and sets a new font color
        color_button.color_set.connect (() =>{
            color_reset_button.sensitive = check_color (color_button, font_default_color);
        });
        // 3. user clicks the color_reset_button and resets a font color
        color_reset_button.clicked.connect (() => {
            font_style.reset_color ();
            color_reset_button.sensitive = check_color (color_button, font_default_color);
        });

        return fonts_grid;
    }

    private Gtk.Grid create_cells_grid (CellStyle cell_style) {
        var bg_button = new Gtk.ColorButton () {
            halign = Gtk.Align.START,
            tooltip_text = _("Set fill color of a selected cell")
        };

        var bg_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
            halign = Gtk.Align.START,
            tooltip_text = _("Remove fill color of a selected cell")
        };

        var sr_button = new Gtk.ColorButton () {
            halign = Gtk.Align.START,
            tooltip_text = _("Set stroke color of a selected cell")
        };

        var sr_width_spin = new Gtk.SpinButton.with_range (0.1, 3, 0.1) {
            halign = Gtk.Align.START,
            tooltip_text = _("Set the border width of a selected cell")
        };

        var sr_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
            halign = Gtk.Align.START,
            tooltip_text = _("Remove stroke color of a selected cell")
        };

        cell_style.bind_property ("background", bg_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        cell_style.bind_property ("stroke", sr_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        cell_style.bind_property ("stroke_width", sr_width_spin, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var cells_grid = new Gtk.Grid () {
            margin_top = 6,
            column_spacing = 6
        };
        cells_grid.attach (new Granite.HeaderLabel (_("Fill")), 0, 0, 1, 1);
        cells_grid.attach (bg_button, 0, 1, 1, 1);
        cells_grid.attach (bg_reset_button, 1, 1, 1, 1);
        cells_grid.attach (new Granite.HeaderLabel (_("Stroke")), 0, 2, 1, 1);
        cells_grid.attach (sr_button, 0, 3, 1, 1);
        cells_grid.attach (sr_width_spin, 1, 3, 1, 1);
        cells_grid.attach (sr_reset_button, 2, 3, 1, 1);

        // Set the sensitivities of the br_remove_button, sr_reset_button and sr_width_spin by whether they have already reset background/stroke colors to the default ones or not when…
        // 1. widgets are created
        Gdk.RGBA bg_default_color = { 1, 1, 1, 1 };
        Gdk.RGBA sr_default_color = { 0, 0, 0, 1 };
        bg_reset_button.sensitive = check_color (bg_button, bg_default_color);
        sr_reset_button.sensitive = check_color (sr_button, sr_default_color);
        sr_width_spin.sensitive = check_color (sr_button, sr_default_color);
        // 2. user clicks br_button/sr_button and sets new background/stroke colors
        bg_button.color_set.connect (() =>{
            bg_reset_button.sensitive = check_color (bg_button, bg_default_color);
        });
        sr_button.color_set.connect (() =>{
            sr_reset_button.sensitive = check_color (sr_button, sr_default_color);
            sr_width_spin.sensitive = check_color (sr_button, sr_default_color);
        });
        // 3. user clicks bg_reset_button/sr_reset_button and resets background/stroke colors
        bg_reset_button.clicked.connect (() => {
            cell_style.reset_background_color ();
            bg_reset_button.sensitive = check_color (bg_button, bg_default_color);
        });
        sr_reset_button.clicked.connect (() => {
            cell_style.reset_stroke_color ();
            sr_width_spin.value = 1.0;
            sr_reset_button.sensitive = check_color (sr_button, sr_default_color);
            sr_width_spin.sensitive = check_color (sr_button, sr_default_color);
        });

        return cells_grid;
    }

    private bool check_color (Gtk.ColorButton bt, Gdk.RGBA dc) {
        if (bt.rgba == dc) {
            return false;
        } else {
            return true;
        }
    }
}
