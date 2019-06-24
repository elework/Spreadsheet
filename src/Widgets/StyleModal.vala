public class Spreadsheet.StyleModal : Gtk.Grid {
    private Gtk.ColorButton color_button;
    private Gtk.Button color_reset_button;
    private Gtk.ColorButton bg_button;
    private Gtk.Button bg_reset_button;
    private Gtk.ColorButton sr_button;
    private Gtk.SpinButton sr_width_spin;
    private Gtk.Button sr_reset_button;

    public StyleModal (FontStyle font_style, CellStyle cell_style) {
        var style_stack = new Gtk.Stack ();
        style_stack.add_titled (fonts_grid (font_style), "fonts-grid", _("Fonts"));
        style_stack.add_titled (cells_grid (cell_style), "cells-grid", _("Cells"));

        var style_stacksw = new Gtk.StackSwitcher ();
        style_stacksw.homogeneous = true;
        style_stacksw.halign = Gtk.Align.CENTER;
        style_stacksw.stack = style_stack;

        attach (style_stacksw, 0, 0, 1, 1);
        attach (style_stack, 0, 1, 1, 1);
    }

    private Gtk.Grid fonts_grid (FontStyle font_style) {
        var size_spin_button = new Gtk.SpinButton.with_range (5, 45, 2);
        size_spin_button.tooltip_text = _("Set font size");
        font_style.bind_property ("fontsize", size_spin_button, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        // TODO: Add a widget that can choose a font

        var style_label = new Granite.HeaderLabel (_("Style"));
        style_label.halign = Gtk.Align.START;

        var bold_button = new Gtk.ToggleButton ();
        bold_button.add (new Gtk.Image.from_icon_name ("format-text-bold-symbolic", Gtk.IconSize.BUTTON));
        bold_button.focus_on_click = false;
        bold_button.tooltip_text = _("Bold");
        font_style.bind_property ("is_bold", bold_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var italic_button = new Gtk.ToggleButton ();
        italic_button.add (new Gtk.Image.from_icon_name ("format-text-italic-symbolic", Gtk.IconSize.BUTTON));
        italic_button.focus_on_click = false;
        italic_button.tooltip_text = _("Italic");
        font_style.bind_property ("is_italic", italic_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var underline_button = new Gtk.ToggleButton ();
        underline_button.add (new Gtk.Image.from_icon_name ("format-text-underline-symbolic", Gtk.IconSize.BUTTON));
        underline_button.focus_on_click = false;
        underline_button.tooltip_text = _("Underline");
        font_style.bind_property ("is_underline", underline_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var strikethrough_button = new Gtk.ToggleButton ();
        strikethrough_button.add (new Gtk.Image.from_icon_name ("format-text-strikethrough-symbolic", Gtk.IconSize.BUTTON));
        strikethrough_button.focus_on_click = false;
        strikethrough_button.tooltip_text = _("Strikethrough");
        font_style.bind_property ("is_strikethrough", strikethrough_button, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

        var style_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        style_box.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        style_box.pack_start (bold_button);
        style_box.pack_start (italic_button);
        style_box.pack_start (underline_button);
        style_box.pack_start (strikethrough_button);

        var color_label = new Granite.HeaderLabel (_("Color"));
        color_label.halign = Gtk.Align.START;
        color_button = new Gtk.ColorButton ();
        color_button.halign = Gtk.Align.START;
        color_button.tooltip_text = _("Set font color of a selected cell");
        font_style.bind_property ("fontcolor", color_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        color_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON);
        color_reset_button.halign = Gtk.Align.START;
        color_reset_button.tooltip_text = _("Reset font color of a selected cell to black");

        var left_grid = new Gtk.Grid ();
        left_grid.margin = 6;
        left_grid.attach (size_spin_button, 0, 0, 1, 1);

        var right_grid = new Gtk.Grid ();
        right_grid.margin = 6;
        right_grid.attach (style_label, 0, 0, 1, 1);
        right_grid.attach (style_box, 0, 1, 1, 1);
        right_grid.attach (color_label, 0, 2, 1, 1);
        right_grid.attach (color_button, 0, 3, 1, 1);
        right_grid.attach (color_reset_button, 1, 3, 1, 1);

        var fonts_grid = new Gtk.Grid ();
        fonts_grid.margin_top = 6;
        fonts_grid.orientation = Gtk.Orientation.VERTICAL;
        fonts_grid.column_spacing = 6;
        fonts_grid.attach (left_grid, 0, 0, 1, 1);
        fonts_grid.attach (new Gtk.Separator (Gtk.Orientation.VERTICAL), 1, 0, 1, 1);
        fonts_grid.attach (right_grid, 2, 0, 1, 1);

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
            font_style.color_remove ();
            color_reset_button.sensitive = check_color (color_button, font_default_color);
        });

        return fonts_grid;
    }

    private Gtk.Grid cells_grid (CellStyle cell_style) {
        var cells_grid = new Gtk.Grid ();
        cells_grid.margin_top = 6;
        cells_grid.column_spacing = 6;

        var bg_label = new Granite.HeaderLabel (_("Fill"));
        bg_label.halign = Gtk.Align.START;
        bg_button = new Gtk.ColorButton ();
        bg_button.halign = Gtk.Align.START;
        bg_button.tooltip_text = _("Set fill color of a selected cell");
        cell_style.bind_property ("background", bg_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        bg_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON);
        bg_reset_button.halign = Gtk.Align.START;
        bg_reset_button.tooltip_text = _("Remove fill color of a selected cell");

        var sr_label = new Granite.HeaderLabel (_("Stroke"));
        sr_label.halign = Gtk.Align.START;
        sr_button = new Gtk.ColorButton ();
        sr_button.halign = Gtk.Align.START;
        sr_button.tooltip_text = _("Set stroke color of a selected cell");
        cell_style.bind_property ("stroke", sr_button, "rgba", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        sr_width_spin = new Gtk.SpinButton.with_range (0.1, 3, 0.1);
        sr_width_spin.halign = Gtk.Align.START;
        sr_width_spin.tooltip_text = _("Set the border width of a selected cell");
        cell_style.bind_property ("stroke_width", sr_width_spin, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        sr_reset_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON);
        sr_reset_button.halign = Gtk.Align.START;
        sr_reset_button.tooltip_text = _("Remove stroke color of a selected cell");

        cells_grid.attach (bg_label, 0, 0, 1, 1);
        cells_grid.attach (bg_button, 0, 1, 1, 1);
        cells_grid.attach (bg_reset_button, 1, 1, 1, 1);
        cells_grid.attach (sr_label, 0, 2, 1, 1);
        cells_grid.attach (sr_button, 0, 3, 1, 1);
        cells_grid.attach (sr_width_spin, 1, 3, 1, 1);
        cells_grid.attach (sr_reset_button, 2, 3, 1, 1);

        // Set the sensitivities of the br_remove_button, sr_reset_button and sr_width_spin by whether they have already reset background/stroke colors to the default ones or not when…
        // 1. widgets are created
        Gdk.RGBA bg_default_color = { 255, 255, 255, 0 };
        Gdk.RGBA sr_default_color = { 0, 0, 0, 0 };
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
            cell_style.bg_remove ();
            bg_reset_button.sensitive = check_color (bg_button, bg_default_color);
        });
        sr_reset_button.clicked.connect (() => {
            cell_style.sr_remove ();
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
