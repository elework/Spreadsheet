/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;
using Spreadsheet.UI;


public class Spreadsheet.Widgets.Sheet : Gtk.DrawingArea {

    // Brand colors by elementary. See https://elementary.io/brand
    private const string BLUEBERRY_100 = "#8cd5ff";
    private const string BLUEBERRY_500 = "#3689e6";
    private const string BLACK_500 = "#333333";

    // Cell dimensions
    const double DEFAULT_WIDTH = 70;
    const double DEFAULT_HEIGHT = 25;
    const double DEFAULT_PADDING = 5;
    const double DEFAULT_BORDER = 0.5;

    double width;
    double height;
    double padding;
    double border;
    double? initial_left_margin = null;

    public Page page { get; set; }

    private MainWindow window;
    private bool is_holding_ctrl = false;

    public Cell? selected_cell { get; set; }

    public signal void selection_changed (Cell? new_selection);

    public signal void selection_cleared ();

    public signal void forward_input_text (string text);

    public Sheet (Page page, MainWindow window) {
        this.page = page;
        this.window = window;
        foreach (var cell in page.cells) {
            if (selected_cell == null) {
                selected_cell = cell;
                cell.selected = true;
            }

            cell.notify["display-content"].connect (() => {
                queue_draw ();
                window.save_sheet ();
            });
            cell.font_style.notify.connect (() => {
                queue_draw ();
                window.save_sheet ();
            });
            cell.cell_style.notify.connect (() => {
                queue_draw ();
                window.save_sheet ();
            });
        }
        focusable = true;
        focus_on_click = true;

        var button_press_controller = new Gtk.GestureClick () {
            button = Gdk.BUTTON_PRIMARY
        };
        button_press_controller.pressed.connect (on_click);
        add_controller (button_press_controller);

        update_zoom_level ();

        window.action_bar.zoom_level_changed.connect (() => {
            update_zoom_level ();
        });

        var scroll_controller = new Gtk.EventControllerScroll (Gtk.EventControllerScrollFlags.VERTICAL);
        scroll_controller.scroll.connect (on_scroll);
        add_controller (scroll_controller);

        var key_press_controller = new Gtk.EventControllerKey ();
        key_press_controller.key_pressed.connect (on_key_press);
        key_press_controller.key_released.connect (on_key_release);
        add_controller (key_press_controller);
    }

    private void select (int line, int col) {
        // Do nothing if the new selected cell are the same with the currently selected
        if (line == selected_cell.line && col == selected_cell.column) {
            return;
        }

        foreach (var cell in page.cells) {
            if (cell.selected) {
                cell.selected = false;
                // Unselect the cell if it was previously selected cell
                if (cell == selected_cell) {
                    selected_cell = null;
                    selection_changed (null);
                }
            } else if (cell.line == line && cell.column == col) {
                // Select the new cell
                cell.selected = true;
                selected_cell = cell;
                selection_changed (cell);
            }
        }
        queue_draw ();
    }

    private void move (int line_add, int column_add) {
        if (selected_cell == null) {
            select (0, 0);
            return;
        }

        int line_after = selected_cell.line + line_add;
        int column_after = selected_cell.column + column_add;

        // Ignore key press to the outside of the sheet
        if (line_after < 0 || line_after >= page.lines) {
            return;
        }
        if (column_after < 0 || column_after >= page.columns) {
            return;
        }

        select (line_after, column_after);
    }

    public void move_top () {
        move (-1, 0);
    }

    public void move_bottom () {
        move (1, 0);
    }

    public void move_right () {
        move (0, 1);
    }

    public void move_left () {
        move (0, -1);
    }

    private void on_click (int n_press, double x, double y) {
        var left_margin = get_left_margin ();
        var col = (int)((x - left_margin) / (double)width);
        var line = (int)((y - height) / (double)height);
        select (line, col);
        grab_focus ();
    }

    private bool on_scroll (double x_delta, double y_delta) {
        if (!is_holding_ctrl) {
            return false;
        }

        if (y_delta > 0) {
            window.action_bar.zoom_level -= 10;
            return true;
        }

        if (y_delta < 0) {
            window.action_bar.zoom_level += 10;
            return true;
        }

        return false;
    }

    private bool on_key_press (uint keyval, uint keycode, Gdk.ModifierType state) {
        if ((state & Gdk.ModifierType.CONTROL_MASK) != 0) {
            switch (keyval) {
                case Gdk.Key.plus:
                    window.action_bar.zoom_level += 10;
                    return true;
                case Gdk.Key.minus:
                    window.action_bar.zoom_level -= 10;
                    return true;
                case Gdk.Key.@0:
                    window.action_bar.zoom_level = 100;
                    return true;
                case Gdk.Key.Home:
                    select (0, 0);
                    return true;
                default:
                    break;
            }
        }

        switch (keyval) {
            case Gdk.Key.Tab:
                move_right ();
                return true;
            case Gdk.Key.Right:
                move_right ();
                return true;
            case Gdk.Key.Down:
            case Gdk.Key.Return:
                move_bottom ();
                return true;
            case Gdk.Key.Up:
                move_top ();
                return true;
            case Gdk.Key.Left:
                move_left ();
                return true;
            case Gdk.Key.BackSpace:
            case Gdk.Key.Delete:
                selection_cleared ();
                return true;
            case Gdk.Key.Control_L:
            case Gdk.Key.Control_R:
                // Activate the scroll event handler
                is_holding_ctrl = true;
                return true;
            default:
                // Check if the keyval corresponds to a character key or modifier key that we don't handle
                if (Gdk.keyval_to_unicode (keyval) == 0) {
                    // Do nothing if the button pressed is ONLY a modifier. If a combination
                    // is pressed, e.g. Shift+Tab, it is not treated as a modifier, and should
                    // instead be checked with the state parameter before here.
                    return true;
                }

                break;
        }

        // No special key is used, thus the intent is user input
        string input_text = Util.keyval_to_utf8 (keyval);
        forward_input_text (input_text);

        return true;
    }

    private void on_key_release (uint keyval, uint keycode, Gdk.ModifierType state) {
        // Deactivate the scroll event handler
        is_holding_ctrl = false;
    }

    private double get_left_margin () {
        Cairo.Context cr = new Cairo.Context (new Cairo.ImageSurface (Cairo.Format.ARGB32, 0, 0));
        cr.set_font_size (height - padding * 2);
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
        Cairo.TextExtents left_ext;
        cr.text_extents (page.lines.to_string (), out left_ext);
        return left_ext.width + border;
    }

    private double get_initial_left_margin () {
        if (initial_left_margin == null) {
            Cairo.Context cr = new Cairo.Context (new Cairo.ImageSurface (Cairo.Format.ARGB32, 0, 0));
            cr.set_font_size (DEFAULT_HEIGHT - DEFAULT_PADDING * 2);
            cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            Cairo.TextExtents left_ext;
            cr.text_extents (page.lines.to_string (), out left_ext);
            initial_left_margin = left_ext.width + DEFAULT_BORDER;
        }

        return initial_left_margin;
    }

    private void update_zoom_level () {
        double zoom_level = window.action_bar.zoom_level * 0.01;

        set_size_request ((int) ((get_initial_left_margin () + DEFAULT_WIDTH * page.columns) * zoom_level), (int) (DEFAULT_HEIGHT + DEFAULT_HEIGHT * page.lines * zoom_level));
        width = DEFAULT_WIDTH * zoom_level;
        height = DEFAULT_HEIGHT * zoom_level;
        padding = DEFAULT_PADDING * zoom_level;
        border = DEFAULT_BORDER * zoom_level;

        queue_draw ();
    }

    protected override void snapshot (Gtk.Snapshot snapshot) {
        Graphene.Rect bounds;
        bool ret = compute_bounds (this, out bounds);
        if (!ret) {
            warning ("Failed to compute_bounds(), sheet will not be drawn!");
            return;
        }

        Cairo.Context cr = snapshot.append_cairo (bounds);

        Gdk.RGBA default_cell_stroke = { 0.3f, 0.3f, 0.3f, 1 };
        Gdk.RGBA default_font_color = { 0, 0, 0, 1 };

        Gdk.RGBA normal = get_color ();

        // Ignore return values of Gdk.RGBA.parse() because we feed constant hex color code
        Gdk.RGBA selected_fill = { 0 };
        selected_fill.parse (BLUEBERRY_100);

        Gdk.RGBA selected_stroke = { 0 };
        selected_stroke.parse (BLUEBERRY_500);

        Gdk.RGBA selected_font_color = { 0 };
        selected_font_color.parse (BLACK_500);

        cr.set_font_size (height - padding * 2);
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

        double left_margin = get_left_margin ();

        // white background
        cr.set_source_rgb (1, 1, 1);
        cr.rectangle (left_margin, height, get_width () - left_margin, get_height () - height);
        cr.fill ();

        // draw the letters and the numbers on the side
        cr.set_line_width (border);

        // numbers on the left side
        for (int i = 0; i < page.lines; i++) {
            Gdk.cairo_set_source_rgba (cr, normal);
            cr.rectangle (0, height + border + i * height, left_margin, height);
            cr.stroke ();

            if (selected_cell != null && selected_cell.line == i) {
                cr.save ();
                Gdk.cairo_set_source_rgba (cr, selected_fill);
                cr.rectangle (0, height + border + i * height, left_margin, height);
                cr.fill ();
                cr.restore ();

                Gdk.cairo_set_source_rgba (cr, selected_font_color);
            }

            string rownum_str = "%d".printf (i + 1);
            Cairo.TextExtents extents;
            cr.text_extents (rownum_str, out extents);
            double x = left_margin / 2 - extents.width / 2;
            double y = height + border + height * i + height / 2 + extents.height / 2;

            cr.move_to (x, y);
            cr.show_text (rownum_str);
        }

        // letters on the top
        int i = 0;
        foreach (string letter in new AlphabetGenerator (page.columns)) {
            Gdk.cairo_set_source_rgba (cr, normal);
            cr.rectangle (left_margin + border + i * width, 0, width, height);
            cr.stroke ();

            if (selected_cell != null && selected_cell.column == i) {
                cr.save ();
                Gdk.cairo_set_source_rgba (cr, selected_fill);
                cr.rectangle (left_margin + border + i * width, 0, width, height);
                cr.fill ();
                cr.restore ();

                Gdk.cairo_set_source_rgba (cr, selected_font_color);
            }

            Cairo.TextExtents extents;
            cr.text_extents (letter, out extents);
            double x = left_margin + border + width * i + width / 2 - extents.width / 2;
            double y = height / 2 + extents.height / 2;
            cr.move_to (x, y);
            cr.show_text (letter);

            i++;
        }

        // draw the cells
        foreach (var cell in page.cells) {
            Gdk.RGBA bg = cell.cell_style.bg_color;
            Gdk.RGBA bg_default = { 1, 1, 1, 1 };

            if (cell.selected) {
                bg = selected_fill;
            }

            if (bg != bg_default) {
                cr.save ();
                Gdk.cairo_set_source_rgba (cr, bg);
                cr.rectangle (left_margin + border + cell.column * width, height + border + cell.line * height, width, height);
                cr.fill ();
                cr.restore ();
            }

            Gdk.RGBA sr = cell.cell_style.stroke_color;
            Gdk.RGBA sr_default = { 0, 0, 0, 1 };
            double sr_w = cell.cell_style.stroke_width;
            cr.save ();

            if (sr_w != 1.0) {
                cr.set_line_width (sr_w);
            } else {
                cr.set_line_width (1.0);
            }

            if (cell.selected) {
                sr = selected_stroke;
                cr.set_line_width (3.0);
            }

            if (sr != sr_default) {
                Gdk.cairo_set_source_rgba (cr, sr);
            } else {
                Gdk.cairo_set_source_rgba (cr, default_cell_stroke);
            }

            cr.rectangle (left_margin + border + cell.column * width, height + border + cell.line * height, width, height);
            cr.stroke ();
            cr.restore ();

            // display the text
            Gdk.RGBA color = cell.font_style.font_color;
            Gdk.RGBA color_default = { 0, 0, 0, 1 };
            cr.save ();

            if (cell.selected) {
                color = selected_font_color;
            }

            if (color != color_default) {
                Gdk.cairo_set_source_rgba (cr, color);
            } else {
                Gdk.cairo_set_source_rgba (cr, default_font_color);
            }

            Cairo.TextExtents extents;
            cr.text_extents (cell.display_content, out extents);
            double x = left_margin + ((cell.column + 1) * width - (padding + border + extents.width));
            double y = height + ((cell.line + 1) * height - (padding + border));

            if (cell.font_style.is_underline) {
                const int UNDERLINE_PADDING = 3;
                cr.move_to (x, y + UNDERLINE_PADDING);
                cr.set_line_width (1);
                cr.rel_line_to (extents.width, 0);
                cr.stroke ();
            }

            if (cell.font_style.is_strikethrough) {
                cr.move_to (x, y - extents.height / 2);
                cr.set_line_width (1);
                cr.rel_line_to (extents.width, 0);
                cr.stroke ();
            }

            cr.move_to (x, y);
            var font_weight = Cairo.FontWeight.NORMAL;
            var font_slant = Cairo.FontSlant.NORMAL;

            if (cell.font_style.is_bold) {
                font_weight = Cairo.FontWeight.BOLD;
            }

            if (cell.font_style.is_italic) {
                font_slant = Cairo.FontSlant.ITALIC;
            }

            cr.select_font_face ("Open Sans", font_slant, font_weight);
            cr.show_text (cell.display_content);
            cr.restore ();
        }
    }
}
