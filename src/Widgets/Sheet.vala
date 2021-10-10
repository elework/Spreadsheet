using Gdk;
using Gee;
using Gtk;
using Cairo;
using Spreadsheet.Models;
using Spreadsheet.UI;


public class Spreadsheet.Widgets.Sheet : EventBox {

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

    public Cell? selected_cell { get; set; }

    public signal void selection_changed (Cell? new_selection);

    public signal void selection_cleared ();

    public signal void focus_expression_entry (string? input);

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
        can_focus = true;
        button_press_event.connect (on_click);

        update_zoom_level ();

        window.action_bar.zoom_level_changed.connect (() => {
            update_zoom_level ();
        });

        key_press_event.connect ((key) => {
            // This is true if the ONLY button pressed is a modifier. If a combination
            // is pressed, e.g. Shift+Tab, it is not treated as a modifier, and should
            // instead be checked with the EventKey::state field.
            if (key.is_modifier != 0) {
                return true;
            }

            if (Gdk.ModifierType.CONTROL_MASK in key.state) {
                switch (key.keyval) {
                    case Gdk.Key.plus:
                        window.action_bar.zoom_level += 10;
                        return true;
                    case Gdk.Key.minus:
                        window.action_bar.zoom_level -= 10;
                        return true;
                    case Gdk.Key.@0:
                        window.action_bar.zoom_level = 100;
                        return true;
                }
            }

            switch (key.keyval) {
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
            }
            // No special key is used, thus the intent is user input
            // Switch focus to the expression entry
            focus_expression_entry (key.str);
            return true;
        });

        add_events (Gdk.EventMask.SCROLL_MASK);
    }

    protected override bool scroll_event (Gdk.EventScroll event) {
        if (Gdk.ModifierType.CONTROL_MASK in event.state) {
            switch (event.direction) {
                case Gdk.ScrollDirection.UP:
                    window.action_bar.zoom_level += 10;
                    break;
                case Gdk.ScrollDirection.DOWN:
                    window.action_bar.zoom_level -= 10;
                    break;
                default:
                    break;
            }
        }

        return base.scroll_event (event);
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

    private void move (int line_add, int col_add) {
        // Ignore key press to the outside of the sheet
        if (selected_cell.line + line_add < 0 || selected_cell.column + col_add < 0) {
            return;
        }

        if (selected_cell != null) {
            select (selected_cell.line + line_add, selected_cell.column + col_add);
        } else {
            select (0, 0);
        }
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

    public bool on_click (EventButton evt) {
        var left_margin = get_left_margin ();
        var col = (int)((evt.x - left_margin) / (double)width);
        var line = (int)((evt.y - height) / (double)height);
        select (line, col);
        grab_focus ();
        return false;
    }

    private double get_left_margin () {
        Context cr = new Context (new ImageSurface (Format.ARGB32, 0, 0));
        cr.set_font_size (height - padding * 2);
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
        TextExtents left_ext;
        cr.text_extents (page.lines.to_string (), out left_ext);
        return left_ext.width + border;
    }

    private double get_initial_left_margin () {
        if (initial_left_margin == null) {
            Context cr = new Context (new ImageSurface (Format.ARGB32, 0, 0));
            cr.set_font_size (DEFAULT_HEIGHT - DEFAULT_PADDING * 2);
            cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            TextExtents left_ext;
            cr.text_extents (page.lines.to_string (), out left_ext);
            initial_left_margin = left_ext.width + DEFAULT_BORDER;
        }

        return initial_left_margin;
    }

    private void update_zoom_level () {
        double zoom_level = window.action_bar.zoom_level * 0.01;

        set_size_request ((int) ((get_initial_left_margin () + DEFAULT_WIDTH * page.columns) * zoom_level), (int) (DEFAULT_HEIGHT * page.lines * zoom_level));
        width = DEFAULT_WIDTH * zoom_level;
        height = DEFAULT_HEIGHT * zoom_level;
        padding = DEFAULT_PADDING * zoom_level;
        border = DEFAULT_BORDER * zoom_level;

        queue_draw ();
    }

    public override bool draw (Context cr) {
        RGBA default_cell_stroke = { 0.3, 0.3, 0.3, 1 };
        RGBA default_font_color = { 0, 0, 0, 1 };

        var style = window.get_style_context ();

        RGBA normal = style.get_color (Gtk.StateFlags.NORMAL);
        RGBA selected = style.get_color (Gtk.StateFlags.SELECTED);

        cr.set_font_size (height - padding * 2);
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

        double left_margin = get_left_margin ();

        // white background
        cr.set_source_rgb (1, 1, 1);
        cr.rectangle (left_margin, height, get_allocated_width () - left_margin, get_allocated_height () - height);
        cr.fill ();

        // draw the letters and the numbers on the side
        Gdk.cairo_set_source_rgba (cr, normal);
        cr.set_line_width (border);

        // numbers on the left side
        for (int i = 0; i < page.lines; i++) {
            cr.rectangle (0, height + border + i * height, left_margin, height);
            cr.stroke ();

            if (selected_cell != null && selected_cell.line == i) {
                cr.save ();
                style.render_frame (cr, 0, height + border + i * height, left_margin, height);
                cr.restore ();

                Gdk.cairo_set_source_rgba (cr, selected);
            } else {
                Gdk.cairo_set_source_rgba (cr, normal);
            }

            TextExtents extents;
            cr.text_extents (i.to_string (), out extents);
            double x = left_margin / 2 - extents.width / 2;
            double y = border + height * i + height / 2 + extents.height / 2;

            cr.move_to (x, y);
            if (i != 0) {
                cr.show_text (i.to_string ());
            }
        }

        // letters on the top
        int i = 0;
        foreach (string letter in new AlphabetGenerator (page.columns)) {
            cr.rectangle (left_margin + border + i * width, 0, width, height);
            cr.stroke ();

            if (selected_cell != null && selected_cell.column == i) {
                cr.save ();
                style.render_frame (cr, left_margin + border + i * width, 0, width, height);
                cr.restore ();

                Gdk.cairo_set_source_rgba (cr, selected);
            } else {
                Gdk.cairo_set_source_rgba (cr, normal);
            }

            TextExtents extents;
            cr.text_extents (letter, out extents);
            double x = left_margin + border + width * i + width / 2 - extents.width / 2;
            double y = border + height / 2 + extents.height / 2;
            cr.fill ();
            cr.move_to (x, y);
            cr.show_text (letter);

            i++;
        }

        // draw the cells
        foreach (var cell in page.cells) {
            Gdk.RGBA bg = cell.cell_style.background;
            Gdk.RGBA bg_default = { 1, 1, 1, 1 };
            if (bg != bg_default) {
                cr.save ();
                Gdk.cairo_set_source_rgba (cr, bg);
                cr.rectangle (left_margin + border + cell.column * width, height + border + cell.line * height, width, height);
                cr.fill ();
                cr.restore ();
            }

            Gdk.RGBA sr = cell.cell_style.stroke;
            Gdk.RGBA sr_default = { 0, 0, 0, 1 };
            double sr_w = cell.cell_style.stroke_width;
            cr.save ();

            if (sr_w != 1.0) {
                cr.set_line_width (sr_w);
            } else {
                cr.set_line_width (1.0);
            }

            if (sr != sr_default) {
                Gdk.cairo_set_source_rgba (cr, sr);
            } else {
                Gdk.cairo_set_source_rgba (cr, default_cell_stroke);
            }

            if (cell.selected) {
                cr.set_line_width (3.0);
            }

            cr.rectangle (left_margin + border + cell.column * width, height + border + cell.line * height, width, height);
            cr.stroke ();
            cr.restore ();

            // display the text
            Gdk.RGBA color = cell.font_style.fontcolor;
            Gdk.RGBA color_default = { 0, 0, 0, 1 };
            cr.save ();
            if (color != color_default) {
                Gdk.cairo_set_source_rgba (cr, color);
            } else {
                Gdk.cairo_set_source_rgba (cr, default_font_color);
            }

            TextExtents extents;
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

        return true;
    }
}
