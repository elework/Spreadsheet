using Gdk;
using Gee;
using Gtk;
using Cairo;
using Spreadsheet.Models;

namespace Spreadsheet.Widgets {

    public class Sheet : EventBox {

        // Cell dimensions
        const int WIDTH = 70;
        const int HEIGHT = 25;
        const int PADDING = 5;
        const double BORDER = 0.5;

        public ArrayList<Cell> cells { get; set; default = new ArrayList<Cell> (); }

        public Cell? selected_cell { get; set; }

        public uint lines { get; set; }

        public uint columns { get; set; }

        public signal void selection_changed (Cell? new_selection);

        public Sheet (uint lines = 100, int cols = 100) {
            this.lines = lines;
            this.columns = cols;
            for (int i = 0; i < lines; i++) {
                for (int j = 0; j < cols; j++) {
                    var cell = new Cell () { line = i, column = j };
                    cell.notify["display-content"].connect (this.queue_draw);
                    cells.add (cell);

                    if (this.selected_cell == null) {
                        this.selected_cell = cell;
                        cell.selected = true;
                    }
                }
            }
            this.button_press_event.connect(this.on_click);
        }

        public Sheet.for_page (Page page) {
            foreach (var cell in page.cells) {
                if (this.selected_cell == null) {
                    this.selected_cell = cell;
                    cell.selected = true;
                }

                if (cell.column > this.columns) {
                    this.columns = cell.column;
                }

                if (cell.line > this.lines) {
                    this.lines = cell.line;
                }

                cell.notify["display-content"].connect (this.queue_draw);
            }
            this.button_press_event.connect(this.on_click);
        }

        private void select (int line, int col) {
            foreach (var cell in cells) {
                if (cell.selected) {
                    cell.selected = false;
                    if (cell == this.selected_cell) { // unselect it if it was selected
                        this.selected_cell = null;
                        selection_changed (null);
                    }
                } else if (cell.line == line && cell.column == col) {
                    cell.selected = true;
                    this.selected_cell = cell;
                    selection_changed (cell);
                }
            }
            this.queue_draw ();
        }

        public bool on_click (EventButton evt) {
            var left_margin = this.get_left_margin ();
            var col = (int)((evt.x - left_margin) / (double)WIDTH);
            var line = (int)((evt.y - HEIGHT) / (double)HEIGHT);
            this.select (line, col);
            return false;
        }

        private double get_left_margin () {
            Context cr = new Context (new ImageSurface (Format.ARGB32, 0, 0));
            cr.set_font_size (HEIGHT - PADDING * 2);
            cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            TextExtents left_ext;
            cr.text_extents (this.lines.to_string (), out left_ext);
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

            var main_window = this.get_toplevel ();
            Gtk.StyleContext style = main_window.get_style_context ();

            /*RGBA bg_color = sctx.get_background_color (Gtk.StateFlags.NORMAL);
            RGBA selected_bg_color;
            RGBA selected_border_color = sctx.get_border_color (Gtk.StateFlags.SELECTED);
            RGBA gray_bg;
            RGBA light_gray;

            sctx.lookup_color ("selected_bg_color_color", out selected_bg_color);
            sctx.lookup_color ("border_color", out selected_border_color);
            sctx.lookup_color ("bg_color", out gray_bg);
            sctx.lookup_color ("fg_color", out light_gray);*/

            RGBA selected_bg_color = { 205.0, 232.0, 245.0, 1 };
            RGBA selected_border_color = { 0, 136.0, 204.0, 1 };
            RGBA gray_bg = { 200.0, 200.0, 200.0, 1 };
            RGBA light_gray = { 51.0, 51.0, 51.0, 1 };

            cr.set_font_size (HEIGHT - PADDING * 2);
            cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

            double left_margin = this.get_left_margin ();

            // white background
            style.render_background (cr, left_margin, HEIGHT, this.get_allocated_width () - left_margin, this.get_allocated_height () - HEIGHT);

            // draw the letters and the numbers on the side
            set_color (cr, gray_bg);
            cr.set_line_width (BORDER);

            // numbers on the left side
            for (int i = 0; i < this.lines; i++) {
                cr.rectangle (0, HEIGHT + BORDER + i * HEIGHT, left_margin, HEIGHT);
                cr.stroke ();

                if (this.selected_cell != null && this.selected_cell.line == i) {
                    cr.save ();
                    /*set_color (cr, style.get_color (Gtk.StateFlags.SELECTED));
                    cr.rectangle (0, HEIGHT + BORDER + i * HEIGHT, left_margin, HEIGHT);
                    cr.fill ();*/
                    style.render_frame (cr, 0, HEIGHT + BORDER + i * HEIGHT, left_margin, HEIGHT);
                    cr.restore ();

                    set_color (cr, style.get_color (Gtk.StateFlags.SELECTED));
                } else {
                    set_color (cr, style.get_color (Gtk.StateFlags.NORMAL));
                }

                TextExtents extents;
                cr.text_extents (i.to_string (), out extents);
                double x = left_margin - (PADDING + BORDER + extents.width);
                double y = HEIGHT + HEIGHT * i - (PADDING + BORDER);

                cr.move_to (x, y);
                cr.show_text (i.to_string ());
                set_color (cr, gray_bg);
            }

            // letters on the top
            int i = 0;
            foreach (string letter in new AlphabetGenerator (this.columns)) {
                cr.rectangle (left_margin + BORDER + i * WIDTH, 0, WIDTH, HEIGHT);
                cr.stroke ();

                if (this.selected_cell != null && this.selected_cell.column == i) {
                    cr.save ();
                    /*set_color (cr, style.get_color (Gtk.StateFlags.SELECTED));
                    cr.rectangle (left_margin + BORDER + i * WIDTH, 0, WIDTH, HEIGHT);
                    cr.fill ();*/
                    style.render_frame (cr, left_margin + BORDER + i * WIDTH, 0, WIDTH, HEIGHT);
                    cr.restore ();

                    set_color (cr, style.get_color (Gtk.StateFlags.SELECTED));
                } else {
                    set_color (cr, style.get_color (Gtk.StateFlags.NORMAL));
                }

                double x = left_margin + (WIDTH * i) + PADDING;
                double y = HEIGHT - PADDING;
                cr.move_to (x, y);
                cr.show_text (letter);
                set_color (cr, gray_bg);

                i++;
            }

            // draw the cells
            foreach (var cell in this.cells) {
                if (cell.selected) {
                    cr.set_line_width (3.0);

                    // blue background
                    cr.save ();
                    /*set_color (cr, selected_bg_color);
                    cr.rectangle (left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
                    cr.fill ();*/
                    //style.render_focus (cr, left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
                    cr.restore ();

                    set_color (cr, style.get_color (Gtk.StateFlags.SELECTED));
                } else {
                    set_color (cr, style.get_color (Gtk.StateFlags.NORMAL));
                }
                //style.render_frame (cr, left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);

                cr.rectangle (left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
                cr.stroke ();

                // display the text
                set_color (cr, style.get_color (Gtk.StateFlags.NORMAL));
                TextExtents extents;
                cr.text_extents (cell.display_content, out extents);
                double x = left_margin + ((cell.column + 1) * WIDTH  - (PADDING + BORDER + extents.width));
                double y = HEIGHT      + ((cell.line + 1)   * HEIGHT - (PADDING + BORDER));

                cr.move_to (x, y);
                cr.show_text (cell.display_content);
                set_color (cr, gray_bg);

                if (cell.selected) {
                    cr.set_line_width (BORDER);
                }
            }
            return true;
        }
    }
}
