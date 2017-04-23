using Gee;
using Gtk;
using Cairo;
using Spreadsheet.Models;

namespace Spreadsheet.UI {
    public class Sheet : EventBox, Scrollable {

        public Adjustment hadjustment { construct set; get; }

        public ScrollablePolicy hscroll_policy { set; get; }

        public Adjustment vadjustment { construct set; get; }

        public ScrollablePolicy vscroll_policy { set; get; }

        public ArrayList<Cell> cells { get; set; }

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
                    cells.add (new Cell () { line = i, column = j });
                }
            }
            this.width_request = 50;
            this.height_request = 50;
        }

        public override bool draw (Context cr) {
            string[] drawn_cols = {};
            int[] drawn_lines = {};
            const int WIDTH = 80, HEIGHT = 30;
            cr.set_source_rgb (1, 1, 1);
            cr.rectangle (0, 0, this.get_allocated_width (), this.get_allocated_height ());
            cr.fill ();
            cr.set_source_rgb (200.0 / 256, 200.0 / 256, 200.0 / 256);
            cr.set_line_width (0.5);
            foreach (var cell in this.cells) {
                cr.rectangle (0.5 + cell.column * WIDTH, 0.5 + cell.line * HEIGHT, WIDTH, HEIGHT);
                cr.stroke ();
            }
            return true;
        }

        public override void size_allocate (Allocation allocation) {
            debug ("alloc: %d, %d; %d, %d\n", allocation.x, allocation.y, allocation.width, allocation.height);
            base.size_allocate (allocation);
        }
    }
}
