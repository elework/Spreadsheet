/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;
using Spreadsheet.UI;

public class Spreadsheet.Widgets.Sheet : Gtk.DrawingArea {
    public signal void selection_changed (Cell? new_selection);
    public signal void clear_cell ();
    public signal void forward_input_text (string text);

    public Page page { get; construct; }
    public Cell? selected_cell { get; set; }

    // Brand colors by elementary. See https://elementary.io/brand
    private const string BLUEBERRY_100 = "#8cd5ff";
    private const string BLUEBERRY_500 = "#3689e6";
    private const string BLACK_500 = "#333333";

    /*
     * Cell dimensions:
     *
     *   ---> x
     *  |        <--------->  width
     *  v       |     A     |
     *  y  -----|-----------|-- < border
     *          |           |   ) padding  ^
     *       1  |     foo   |              | height
     *          |           |   ) padding  v
     *     -----|-----------|-- < border
     *                   <->
     *          ^   padding ^
     *          border      border
     */
    private const double DEFAULT_WIDTH = 70;
    private const double DEFAULT_HEIGHT = 25;
    private const double DEFAULT_PADDING = 5;
    private const double DEFAULT_BORDER = 0.5;

    private const int SELECTED_STROKE_WIDTH = 3;
    private const int UNDERLINE_PADDING = 3;
    private const int UNDERLINE_STROKE_WIDTH = 1;
    private const int STRIKETHROUGH_STROKE_WIDTH = 1;

    private double width;
    private double height;
    private double padding;
    private double border;

    private MainWindow window;
    private bool is_holding_ctrl = false;

    public Sheet (Page page, MainWindow window) {
        Object (
            page: page
        );

        this.window = window;

        focusable = true;
        focus_on_click = true;

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

        var button_press_controller = new Gtk.GestureClick () {
            button = Gdk.BUTTON_PRIMARY
        };
        button_press_controller.pressed.connect (on_click);
        add_controller (button_press_controller);

        update_zoom_level ();

        page.notify["zoom-level"].connect (() => {
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

    private bool is_selected (int line, int column) {
        if (selected_cell == null) {
            // No cell is selected, so the given cell is not selected too
            return false;
        }

        if (line != selected_cell.line) {
            return false;
        }

        if (column != selected_cell.column) {
            return false;
        }

        return true;
    }

    private void select (int line, int column) {
        bool ret = is_selected (line, column);
        if (ret) {
            // Do nothing if the given cell is already selected
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

                continue;
            }

            if (cell.line == line) {
                if (cell.column == column) {
                    // Select the new cell
                    cell.selected = true;
                    selected_cell = cell;
                    selection_changed (cell);
                }
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
        double linenum_width = calc_linenum_width (page.lines, height, padding);
        double columnid_height = height;

        /*
         *       |    A    |    B    |   ) columnid_height
         *  -----|---------|---------|-- < border
         *    1  |         |         |   ) height
         *  -----|---------|---------|--
         *    2  |         | * <---------- (x, y)
         *  -----|---------|---------|--
         *  <---> <------->
         *   |   ^  width
         *   |   border
         *  linenum_width
         */
        var column = (int) ((x - linenum_width) / (border + width));
        var line = (int) ((y - columnid_height) / (border + height));

        select (line, column);
        grab_focus ();
    }

    private void zoom_out () {
        int level = page.zoom_level - Page.ZOOM_LEVEL_STEP;
        if (level < Page.ZOOM_LEVEL_MIN) {
            return;
        }

        page.zoom_level = level;
    }

    private void zoom_in () {
        int level = page.zoom_level + Page.ZOOM_LEVEL_STEP;
        if (level > Page.ZOOM_LEVEL_MAX) {
            return;
        }

        page.zoom_level = level;
    }

    private bool on_scroll (double x_delta, double y_delta) {
        if (!is_holding_ctrl) {
            return false;
        }

        // Only sensitive for horizontal scroll
        if (y_delta > 0) {
            zoom_out ();
            return true;
        }

        if (y_delta < 0) {
            zoom_in ();
            return true;
        }

        return false;
    }

    private bool on_key_press (uint keyval, uint keycode, Gdk.ModifierType state) {
        if ((state & Gdk.ModifierType.CONTROL_MASK) != 0) {
            switch (keyval) {
                case Gdk.Key.plus:
                    zoom_in ();
                    return true;
                case Gdk.Key.minus:
                    zoom_out ();
                    return true;
                case Gdk.Key.@0:
                    page.zoom_level = Page.ZOOM_LEVEL_DEFAULT;
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
                clear_cell ();
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

    private static double calc_linenum_width (int linenum_max, double height, double padding) {
        var cr = new Cairo.Context (new Cairo.ImageSurface (Cairo.Format.ARGB32, 0, 0));
        cr.set_font_size (height - (padding * 2));
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

        Cairo.TextExtents linenum_ext;
        cr.text_extents (linenum_max.to_string (), out linenum_ext);

        /*
         *  Calculate this
         *  <------->
         *           |    A    |
         *  ---------|---------|--
         *     100   |         |   <-- Use the maximum line number
         *  ---------|---------|--     to make sure no line numbers will be cut off
         *  <->   <->
         *  padding
         */
        return linenum_ext.width + (padding * 2);
    }

    private void update_zoom_level () {
        double zoom_level = page.zoom_level * 0.01;

        width = DEFAULT_WIDTH * zoom_level;
        height = DEFAULT_HEIGHT * zoom_level;
        padding = DEFAULT_PADDING * zoom_level;
        border = DEFAULT_BORDER * zoom_level;

        double linenum_width = calc_linenum_width (page.lines, height, padding);
        double columnid_height = height;

        double page_width = linenum_width + ((border + width) * page.columns);
        double page_height = columnid_height + ((border + height) * page.lines);
        set_size_request ((int) page_width, (int) page_height);

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

        Gdk.RGBA style_bg_color = get_color ();

        // Ignore return values of Gdk.RGBA.parse() because we feed constant hex color code
        Gdk.RGBA selected_fill = { 0 };
        selected_fill.parse (BLUEBERRY_100);

        Gdk.RGBA selected_stroke = { 0 };
        selected_stroke.parse (BLUEBERRY_500);

        Gdk.RGBA selected_font_color = { 0 };
        selected_font_color.parse (BLACK_500);

        cr.set_font_size (height - (padding * 2));
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

        double linenum_width = calc_linenum_width (page.lines, height, padding);
        double columnid_height = height;
        double cellarea_width = ((border + width) * page.columns);
        double cellarea_height = ((border + height) * page.lines);

        // white background
        cr.set_source_rgb (1, 1, 1);
        cr.rectangle (linenum_width, columnid_height, cellarea_width, cellarea_height);
        cr.fill ();

        cr.set_line_width (border);

        // numbers on the left (1, 2, ...)
        for (int i = 0; i < page.lines; i++) {
            /*
             *                      <---> linenum_width
             *                           |  ) columnid_height
             *                      -----|- < border
             *                        1  |  ) height
             *  (cell_x, cell_y) -> *----|-
             *                        2  |
             *                      -----|-
             */
            Gdk.cairo_set_source_rgba (cr, style_bg_color);
            double cell_x = 0;
            double cell_y = columnid_height + ((border + height) * i);
            cr.rectangle (cell_x, cell_y, linenum_width, height);
            cr.stroke ();

            if (selected_cell != null) {
                if (selected_cell.line == i) {
                    cr.save ();
                    Gdk.cairo_set_source_rgba (cr, selected_fill);
                    cr.rectangle (cell_x, cell_y, linenum_width, height);
                    cr.fill ();
                    cr.restore ();

                    Gdk.cairo_set_source_rgba (cr, selected_font_color);
                }
            }

            string linenum_str = "%d".printf (i + 1);
            Cairo.TextExtents extents;
            cr.text_extents (linenum_str, out extents);
            /*
             *                      <---------> linenum_width
             *                                 |
             *  (cell_x, cell_y) -> *----------|--
             *                         <---> extents.width          ^
             *                         _____   |                    |
             *                        |     |  |  ^                 |
             *                        |  2  |  |  | extents.height  | height
             *  (text_x, text_y) ---> *_____|  |  v                 |
             *                                 |                    v
             *                      -----------|--
             */
            double text_x = cell_x + (linenum_width / 2 - extents.width / 2);
            double text_y = cell_y + (height / 2 + extents.height / 2);

            cr.move_to (text_x, text_y);
            cr.show_text (linenum_str);
        }

        // letters on the top (A, B, ...)
        int i = 0;
        foreach (string letter in new AlphabetGenerator (page.columns)) {
            /*
             *                           * <-- (cell_x, cell_y)
             *       |    A    |    B    |   ) columnid_height
             *  -----|---------|---------|--
             *  <---> <------->
             *   |   ^  width
             *   |   border
             *  linenum_width
             */
            Gdk.cairo_set_source_rgba (cr, style_bg_color);
            double cell_x = linenum_width + ((border + width) * i);
            double cell_y = 0;
            cr.rectangle (cell_x, cell_y, width, columnid_height);
            cr.stroke ();

            if (selected_cell != null) {
                if (selected_cell.column == i) {
                    cr.save ();
                    Gdk.cairo_set_source_rgba (cr, selected_fill);
                    cr.rectangle (cell_x, cell_y, width, height);
                    cr.fill ();
                    cr.restore ();

                    Gdk.cairo_set_source_rgba (cr, selected_font_color);
                }
            }

            Cairo.TextExtents extents;
            cr.text_extents (letter, out extents);
            /*
             *                       <---------> width
             *  (cell_x, cell_y) -> *   <---> extents.width
             *                      |   _____   |                    ^
             *                      |  |     |  |  ^                 |
             *                      |  |  B  |  |  | extents.height  | height
             *  (text_x, text_y) ----> *_____|  |  v                 |
             *                      |           |                    v
             *                     -|-----------|--
             */
            double text_x = cell_x + (width / 2 - extents.width / 2);
            double text_y = cell_y + (height / 2 + extents.height / 2);

            cr.move_to (text_x, text_y);
            cr.show_text (letter);

            i++;
        }

        // draw the cells
        foreach (var cell in page.cells) {
            /*
             *       |    A    |    B    |   ) columnid_height
             *  -----|---------|---------|-- < border
             *    1  |         |         |   ) height
             *  -----|---------*---------|--
             *    2  |         | (cell_x, cell_y)
             *  -----|---------|---------|--
             *  <---> <------->
             *   |   ^  width
             *   |   border
             *  linenum_width
             */
            double cell_x = linenum_width + (border + width) * cell.column;
            double cell_y = columnid_height + (border + height) * cell.line;

            Gdk.RGBA bg_color = cell.cell_style.bg_color;
            if (cell.selected) {
                bg_color = selected_fill;
            }

            if (bg_color != CellStyle.BG_COLOR_DEFAULT) {
                cr.save ();
                Gdk.cairo_set_source_rgba (cr, bg_color);
                cr.rectangle (cell_x, cell_y, width, height);
                cr.fill ();
                cr.restore ();
            }

            Gdk.RGBA stroke_color = cell.cell_style.stroke_color;
            double stroke_width = cell.cell_style.stroke_width;
            if (cell.selected) {
                stroke_color = selected_stroke;
                stroke_width = SELECTED_STROKE_WIDTH;
            }

            if (stroke_color == CellStyle.STROKE_COLOR_DEFAULT) {
                stroke_color = default_cell_stroke;
            }

            cr.save ();
            cr.set_line_width (stroke_width);
            Gdk.cairo_set_source_rgba (cr, stroke_color);
            cr.rectangle (cell_x, cell_y, width, height);
            cr.stroke ();
            cr.restore ();

            // display the text
            Gdk.RGBA color = cell.font_style.font_color;
            if (cell.selected) {
                color = selected_font_color;
            }

            if (color == FontStyle.FONT_COLOR_DEFAULT) {
                color = default_font_color;
            }

            cr.save ();
            Gdk.cairo_set_source_rgba (cr, color);

            /*
             *                       <-----------> width
             *                      |             |
             *  (cell_x, cell_y) -> *-------------|--
             *                      |    <---> extents.width           ^
             *                      |    _____    |                    |
             *                      |   |     |   |   ^                |
             *                      |   | foo |   |   | extents.height | height
             *  (text_x, text_y) -----> *_____|   |   v                |
             *                      |             |   ) padding        v
             *                      |-------------|-- < border
             *                                 <->
             *                            padding ^
             *                                    border
             */
            Cairo.TextExtents extents;
            cr.text_extents (cell.display_content, out extents);
            double text_x = cell_x + (width - (extents.width + padding + border));
            double text_y = cell_y + (height - (border + padding));

            if (cell.font_style.is_underline) {
                cr.move_to (text_x, text_y + UNDERLINE_PADDING);
                cr.set_line_width (UNDERLINE_STROKE_WIDTH);
                cr.rel_line_to (extents.width, 0);
                cr.stroke ();
            }

            if (cell.font_style.is_strikethrough) {
                cr.move_to (text_x, text_y - (extents.height / 2));
                cr.set_line_width (STRIKETHROUGH_STROKE_WIDTH);
                cr.rel_line_to (extents.width, 0);
                cr.stroke ();
            }

            cr.move_to (text_x, text_y);

            var font_slant = Cairo.FontSlant.NORMAL;
            if (cell.font_style.is_italic) {
                font_slant = Cairo.FontSlant.ITALIC;
            }

            var font_weight = Cairo.FontWeight.NORMAL;
            if (cell.font_style.is_bold) {
                font_weight = Cairo.FontWeight.BOLD;
            }

            cr.select_font_face ("Open Sans", font_slant, font_weight);
            cr.show_text (cell.display_content);
            cr.restore ();
        }
    }
}
