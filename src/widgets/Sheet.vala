using Gdk;
using Gee;
using Gtk;
using Cairo;
using Spreadsheet.Models;

namespace Spreadsheet.Widgets {
    public class Sheet : EventBox, Scrollable {

        // Cell dimensions
        const int WIDTH = 70;
        const int HEIGHT = 25;
        const int PADDING = 5;

        public Adjustment hadjustment { construct set; get; }

        public ScrollablePolicy hscroll_policy { set; get; }

        public Adjustment vadjustment { construct set; get; }

        public ScrollablePolicy vscroll_policy { set; get; }

        public ArrayList<Cell> cells { get; set; }

        public Cell selected_cell { get; set; }

        public signal void selection_changed (Cell new_selection);

        construct {
            hadjustment = new Adjustment (0, -2, 2, 0.01, 0.1, 0.1);
            hadjustment.value_changed.connect (() => {
                debug ("SCROLLING\n");
                this.queue_draw ();
            });
            cells = new ArrayList<Cell> ();
            const int CELL_LIMIT = 100;
            for (int i = 0; i < CELL_LIMIT; i++) {
                for (int j = 0; j < CELL_LIMIT; j++) {
                    var cell = new Cell () { line = i, column = j };
                    cell.notify["display-content"].connect (() => {
                        this.queue_draw ();
                    });
                    cells.add (cell);
                }
            }
            this.width_request = 50;
            this.height_request = 50;
            this.button_press_event.connect(this.on_click);
        }

        private void select (int line, int col) {
            foreach (var cell in cells) {
                if (cell.selected) {
                    cell.selected = false;
                } else if (cell.line == line && cell.column == col) {
                    cell.selected = true;
                    this.selected_cell = cell;
                    selection_changed (cell);
                }
            }
            this.queue_draw ();
        }

        public bool on_click (EventButton evt) {
            var col = (int)(evt.x / (double)WIDTH);
            var line = (int)(evt.y / (double)HEIGHT);
            this.select (line, col);
            return false;
        }

        public override bool draw (Context cr) {
            const double BORDER = 0.5;

            // white background
            cr.set_source_rgb (1, 1, 1);
            cr.rectangle (0, 0, this.get_allocated_width (), this.get_allocated_height ());
            cr.fill ();

            // draw the cells
            cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);
            cr.set_line_width (BORDER);
            foreach (var cell in this.cells) {
                if (cell.selected) {
                    cr.set_line_width (2.0);
                }
                cr.rectangle (BORDER + cell.column * WIDTH, BORDER + cell.line * HEIGHT, WIDTH, HEIGHT);
                cr.stroke ();

                // display the text
                cr.set_source_rgb (51.0 / 256, 51.0 / 256, 51.0 / 256);
                cr.set_font_size (HEIGHT - PADDING * 2);
                cr.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.NORMAL);

                TextExtents extents;
            	cr.text_extents (cell.display_content, out extents);
                if (extents.width != 0) debug ("EXTENTS: w %g h %g\n", extents.width, extents.height);
                double x = (cell.column + 1) * WIDTH  - (PADDING + BORDER + extents.width);
                double y = (cell.line + 1)   * HEIGHT - (PADDING + BORDER);

                cr.move_to (x, y);
            	cr.show_text (cell.display_content);
                cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);

                if (cell.selected) {
                    cr.set_line_width (BORDER);
                }
            }
            return true;
        }

        public override void size_allocate (Allocation allocation) {
            base.size_allocate (allocation);
        }
    }
}
