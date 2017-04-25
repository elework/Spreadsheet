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
                }
            }
            this.button_press_event.connect(this.on_click);
        }

        public Sheet.for_page (Page page) {
            foreach (var cell in page.cells) {
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
                    this.selected_cell = null;
                    selection_changed (null);
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

        private double get_left_margin (Context cr = new Context (new ImageSurface (Format.ARGB32, 0, 0))) {
            cr.save ();
            cr.set_font_size (HEIGHT - PADDING * 2);
            cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);
            TextExtents left_ext;
            cr.text_extents (this.lines.to_string (), out left_ext);
            cr.restore ();
            return left_ext.width + BORDER;
        }

        public override bool draw (Context cr) {
            cr.set_font_size (HEIGHT - PADDING * 2);
            cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

            double left_margin = this.get_left_margin ();

            // white background
            cr.set_source_rgb (1, 1, 1);
            cr.rectangle (left_margin, HEIGHT, this.get_allocated_width () - left_margin, this.get_allocated_height () - HEIGHT);
            cr.fill ();

            // draw the letters and the numbers on the side
            cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);
            cr.set_line_width (BORDER);

            // numbers on the left side
            for (int i = 0; i < this.lines; i++) {
                cr.rectangle (0, HEIGHT + BORDER + i * HEIGHT, left_margin, HEIGHT);
                cr.stroke ();

                TextExtents extents;
            	cr.text_extents (i.to_string (), out extents);
                double x = left_margin - (PADDING + BORDER + extents.width);
                double y = HEIGHT + HEIGHT * i - (PADDING + BORDER);
                cr.set_source_rgb (51.0 / 256, 51.0 / 256, 51.0 / 256);
                cr.move_to (x, y);
            	cr.show_text (i.to_string ());
                cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);
            }

            // letters on the top
            int i = 0;
            foreach (string letter in new AlphabetGenerator (this.columns)) {
                cr.rectangle (left_margin + BORDER + i * WIDTH, 0, WIDTH, HEIGHT);
                cr.stroke ();

                double x = left_margin + (WIDTH * i) + PADDING;
                double y = HEIGHT - PADDING;
                cr.set_source_rgb (51.0 / 256, 51.0 / 256, 51.0 / 256);
                cr.move_to (x, y);
            	cr.show_text (letter);
                cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);

                i++;
            }

            // draw the cells
            foreach (var cell in this.cells) {
                if (cell.selected) {
                    cr.set_line_width (2.0);
                }
                cr.rectangle (left_margin + BORDER + cell.column * WIDTH, HEIGHT + BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
                cr.stroke ();

                // display the text
                cr.set_source_rgb (51.0 / 256, 51.0 / 256, 51.0 / 256);
                TextExtents extents;
            	cr.text_extents (cell.display_content, out extents);
                double x = left_margin + ((cell.column + 1) * WIDTH  - (PADDING + BORDER + extents.width));
                double y = HEIGHT      + ((cell.line + 1)   * HEIGHT - (PADDING + BORDER));

                cr.move_to (x, y);
            	cr.show_text (cell.display_content);
                cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);

                if (cell.selected) {
                    cr.set_line_width (BORDER);
                }
            }
            return true;
        }
    }
}
