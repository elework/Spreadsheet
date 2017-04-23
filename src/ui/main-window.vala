using Spreadsheet.Parser;
using Granite.Widgets;
using Gtk;

namespace Spreadsheet.UI {

    public class MainWindow : ApplicationWindow {

        public HeaderBar header { get; set; default = new HeaderBar (); }

        public Stack app_stack { get; set; default = new Stack (); }

        public MainWindow (Gtk.Application app) {
            Object (application: app);
            this.set_default_size (1500, 1000);
            this.window_position = WindowPosition.CENTER;

            this.app_stack.add_named (welcome (), "welcome");
            this.app_stack.add_named (sheet (), "app");
            this.set_titlebar (this.header);

            this.add (this.app_stack);
            this.show_welcome ();
            this.show_all ();
        }

        private Welcome welcome () {
            var welcome = new Welcome ("Spreadsheet", "Start something new, or continue what you have been working on.");
            welcome.append ("document-new", "New Sheet", "Create an empty sheet");
            welcome.append ("document-open", "Open a file", "Choose a saved presentation");
            welcome.append ("x-office-spreadsheet", "Open last file", "Continue working on foo.xlsx");
            welcome.activated.connect ((index) => {
                this.open_sheet ();
            });
            return welcome;
        }

        private Box sheet () {
            var tabs = new DynamicNotebook () { allow_restoring = false };
            tabs.insert_tab (new Tab ("New Sheet", null, new Sheet ()), 0);

            var toolbar = new Grid ();
            toolbar.border_width = 10;
            var function_list_bt = new Button.with_label ("f (x)");

            var popup = new Popover (function_list_bt);
            popup.modal = true;
            popup.position = PositionType.BOTTOM;
            popup.border_width = 10;
            var function_list = new Box (Orientation.VERTICAL, 5);
            function_list.add (new Label ("SUM") { width_request = 100, justify = Justification.LEFT });
            function_list.add (new Label ("DIV") { width_request = 100, justify = Justification.LEFT });
            function_list.add (new Label ("SUB") { width_request = 100, justify = Justification.LEFT });
            function_list.add (new Label ("MUL") { width_request = 100, justify = Justification.LEFT });
            function_list.add (new Label ("MOD") { width_request = 100, justify = Justification.LEFT });
            popup.add (function_list);

            function_list_bt.clicked.connect (() => {
                popup.show_all ();
            });

            toolbar.attach (function_list_bt, 0, 0, 1, 1);
            var expr = new Entry ();
            expr.hexpand = true;
            expr.activate.connect (() => {
                print ("Computing %s...\n", expr.text);
                var tokens = new Lexer ().tokenize (expr.text);
                foreach (var tok in tokens) {
                    print ("%s -> %s\n", tok.lexeme, tok.kind);
                }
                var parser = new Parser.Parser (tokens);
                var expression = parser.parse ();
                print (@"$(expr.text) = $(((double)expression.eval ()).to_string ())");
            });
            toolbar.attach (expr, 1, 0);
            toolbar.column_spacing = 10;

            var style_toggle = new ToggleButton.with_label ("Open Sans 14");
            toolbar.add (style_toggle);
            bool resized = false;
            style_toggle.draw.connect ((cr) => {
                int spacing = 20;
                int border = 5; // TODO: get real value
                int square_size = style_toggle.get_allocated_height () - (border * 2);
                int width = style_toggle.get_allocated_width ();

                if (!resized) {
                    style_toggle.width_request += width + spacing + square_size + border; // some space for the color icon
                    resized = true;
                }

                cr.set_source_rgb (0, 0, 0);
                draw_rounded_path (cr, width - (border + square_size), border, square_size, square_size, 2);
                cr.fill ();
                return false;
            });
            var style_popup = new Popover (style_toggle);
            style_popup.modal = true;
            style_popup.position = PositionType.BOTTOM;
            style_popup.border_width = 10;
            style_toggle.toggled.connect (() => {
                if (style_toggle.active) {
                    style_popup.show_all ();
                }
            });
            style_popup.closed.connect (() => {
                style_toggle.active = false;
            });
            style_popup.add (new Label ("Nothing to show here... yet!"));

            var layout = new Box (Orientation.VERTICAL, 0) { homogeneous = false };
            layout.pack_start (toolbar, false);
            layout.pack_start (tabs);
            return layout;
        }

        private void open_sheet () {
            this.init_header ();
            this.header.title = "New Spreadsheet";
            this.header.subtitle = "Not saved yet";
            this.header.show_close_button = true;
            this.show_all ();

            this.app_stack.set_visible_child_name ("app");
        }

        private void show_welcome () {
            this.clear_header ();
            this.header.title = "Spreadsheet";
            this.header.show_close_button = true;

            this.app_stack.set_visible_child_name ("welcome");
        }

        // From http://stackoverflow.com/questions/4183546/how-can-i-draw-image-with-rounded-corners-in-cairo-gtk
        private void draw_rounded_path (Cairo.Context ctx, double x, double y, double width, double height, double radius) {
            double degrees = Math.PI / 180.0;

            ctx.new_sub_path ();
            ctx.arc (x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
            ctx.arc (x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
            ctx.arc (x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
            ctx.arc (x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
            ctx.close_path ();
        }

        void init_header () {
            debug ("init header");
            Image file_ico = new Image.from_icon_name ("document-new", Gtk.IconSize.SMALL_TOOLBAR);
            ToolButton file_button = new ToolButton (file_ico, null);
            file_button.clicked.connect (() => {
                print ("New file\n");
            });
            this.header.pack_end (file_button);

            Image open_ico = new Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
            ToolButton open_button = new ToolButton (open_ico, null);
            open_button.clicked.connect (() => {
                print ("Open\n");
            });
            this.header.pack_end (open_button);

            Image undo_ico = new Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
            ToolButton undo_button = new ToolButton (undo_ico, null);
            undo_button.clicked.connect (() => {
                print ("Undo\n");
            });
            this.header.pack_start (undo_button);

            Image redo_ico = new Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
            ToolButton redo_button = new ToolButton (redo_ico, null);
            redo_button.clicked.connect (() => {
                print ("Redo\n");
            });
            this.header.pack_start (redo_button);
        }

        void clear_header () {
            foreach (var button in this.header.get_children ()) {
                button.destroy ();
            }
        }
    }
}
