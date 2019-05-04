using Gdk;
using Gee;
using Gtk;
using Cairo;
using Spreadsheet.Models;
using Spreadsheet.UI;


public class Spreadsheet.Widgets.Sheet : EventBox {

    // Cell dimensions
    const int WIDTH = 70;
    const int HEIGHT = 25;
    const int PADDING = 5;
    const double BORDER = 0.5;

    public Page page { get; set; }

    private MainWindow window;

    public Cell? selected_cell { get; set; }

    public signal void selection_changed (Cell? new_selection);

    public signal void focus_expression_entry ();

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
        key_press_event.connect ((key) => {
            return true; // without this Tab is not handled correctly ¯\_(ツ)_/¯
        });
        key_release_event.connect ((key) => {
            switch (key.keyval) {
                case Gdk.Key.Right:
                case Gdk.Key.Tab:
                    move_right ();
                    return false;
                case Gdk.Key.Down:
                case Gdk.Key.Return:
                    move_bottom ();
                    return false;
                case Gdk.Key.Up:
                    move_top ();
                    return false;
                case Gdk.Key.Left:
                    move_left ();
                    return false;
            }
            return true;
        });
    }

    private void select (int line, int col) {
        foreach (var cell in page.cells) {
            if (cell.selected) {
                cell.selected = false;
                if (cell == selected_cell) { // unselect it if it was selected
                    selected_cell = null;
                    selection_changed (null);
                }
            } else if (cell.line == line && cell.column == col) {
                cell.selected = true;
                selected_cell = cell;
                selection_changed (cell);
            }
        }
        queue_draw ();
    }

    private void move (int line_add, int col_add) {
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
        var col = (int)((evt.x - left_margin) / (double)WIDTH);
        var line = (int)((evt.y - HEIGHT) / (double)HEIGHT);
        select (line, col);
        grab_focus ();
        return false;
    }

    private double get_left_margin () {
        Context cr = new Context (new ImageSurface (Format.ARGB32, 0, 0));
        cr.set_font_size (HEIGHT - PADDING * 2);
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
        TextExtents left_ext;
        cr.text_extents (page.lines.to_string (), out left_ext);
        return left_ext.width + BORDER;
    }

    // I hope Vala will support extension methods one day...
    private void set_color (Context cr, RGBA color) {
        if (color.blue > 1.0) {
            color.blue = color.blue / 256;
        }
        if (color.red > 1.0) {
            color.red = color.red / 256;
        }
        if (color.green > 1.0) {
            color.green = color.green / 256;
        }
        cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
    }

    public override bool draw (Context cr) {
        RGBA default_cell_stroke = { 77.0, 77.0, 77.0, 1 };
        RGBA default_font_color = { 0, 0, 0, 1 };

        var style = window.get_style_context ();

        RGBA normal = style.get_color (Gtk.StateFlags.NORMAL);
        RGBA selected = style.get_color (Gtk.StateFlags.SELECTED);

        cr.set_font_size (HEIGHT - PADDING * 2);
        cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

        double left_margin = get_left_margin ();

        // white background
        cr.set_source_rgb (1, 1, 1);
        cr.rectangle (left_margin, HEIGHT, get_allocated_width () - left_margin, get_allocated_height () - HEIGHT);
        cr.fill ();

        // draw the letters and the numbers on the side
        set_color (cr, normal);
        cr.set_line_width (BORDER);

        // numbers on the left side
        for (int i = 0; i < page.lines; i++) {
            cr.rectangle (0, HEIGHT + BORDER + i * HEIGHT, left_margin, HEIGHT);
            cr.stroke ();

            if (selected_cell != null && selected_cell.line == i) {
                cr.save ();
                style.render_frame (cr, 0, HEIGHT + BORDER + i * HEIGHT, left_margin, HEIGHT);
                cr.restore ();

                set_color (cr, selected);
            } else {
                set_color (cr, normal);
            }

            TextExtents extents;
            cr.text_extents (i.to_string (), out extents);
            double x = left_margin / 2 - extents.width / 2;
            double y = BORDER + HEIGHT * i + HEIGHT / 2 + extents.height / 2;

            cr.move_to (x, y);
            if (i != 0) {
                cr.show_text (i.to_string ());
            }
        }

        // letters on the top
        int i = 0;
        foreach (string letter in new AlphabetGenerator (page.columns)) {
            cr.rectangle (left_margin + BORDER + i * WIDTH, 0, WIDTH, HEIGHT);
            cr.stroke ();

            if (selected_cell != null && selected_cell.column == i) {
                cr.save ();
                style.render_frame (cr, left_margin + BORDER + i * WIDTH, 0, WIDTH, HEIGHT);
                cr.restore ();

                set_color (cr, selected);
            } else {
                set_color (cr, normal);
            }

            TextExtents extents;
            cr.text_extents (letter, out extents);
            double x = left_margin + BORDER + WIDTH * i + WIDTH / 2 - extents.width / 2;
            double y = BORDER + HEIGHT / 2 + extents.height / 2;
            cr.fill ();
            cr.move_to (x, y);
            cr.show_text (letter);

            i++;
        }

        // draw the cells
        foreach (var cell in page.cells) {
            Gdk.RGBA bg = cell.cell_style.background;
            Gdk.RGBA bg_default = { 255, 255, 255, 0 };
            if (bg != bg_default) {
                cr.save ();
                set_color (cr, bg);
                cr.rectangle (left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
                cr.fill ();
                cr.restore ();
            }

            Gdk.RGBA sr = cell.cell_style.stroke;
            Gdk.RGBA sr_default = { 0, 0, 0, 0 };
            double sr_w = cell.cell_style.stroke_width;
            cr.save ();

            if (sr_w != 1.0) {
                cr.set_line_width (sr_w);
            } else {
                cr.set_line_width (1.0);
            }

            if (sr != sr_default) {
                set_color (cr, sr);
            } else {
                set_color (cr, default_cell_stroke);
            }

            if (cell.selected) {
                cr.set_line_width (3.0);
            }

            cr.rectangle (left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
            cr.stroke ();
            cr.restore ();

            // display the text
            Gdk.RGBA color = cell.font_style.fontcolor;
            Gdk.RGBA color_default = { 0, 0, 0, 1 };
            cr.save ();
            if (color != color_default) {
                set_color (cr, color);
            } else {
                set_color (cr, default_font_color);
            }

            TextExtents extents;
            cr.text_extents (cell.display_content, out extents);
            double x = left_margin + ((cell.column + 1) * WIDTH  - (PADDING + BORDER + extents.width));
            double y = HEIGHT      + ((cell.line + 1)   * HEIGHT - (PADDING + BORDER));
            cr.move_to (x, y);
            cr.show_text (cell.display_content);
            cr.restore ();
        }

        return true;
    }
}
