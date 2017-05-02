using Spreadsheet.Parser;
using Spreadsheet.Widgets;
using Spreadsheet.Models;
using Spreadsheet.Services;
using Granite.Widgets;
using Gtk;
using Gdk;
using Gee;

namespace Spreadsheet.UI {

    public class MainWindow : ApplicationWindow {

        public HeaderBar header { get; set; default = new HeaderBar (); }

        public Stack app_stack { get; set; default = new Stack (); }

        public DynamicNotebook tabs {
            get;
            set;
            default = new DynamicNotebook () { allow_restoring = false };
        }

        public Sheet active_sheet {
            get {
                ScrolledWindow scroll = (ScrolledWindow)this.tabs.current.page;
                Viewport vp = (Viewport)scroll.get_child ();
                return (Sheet)vp.get_child ();
            }
        }

        ToolButton file_button { get; set; }
        ToolButton open_button { get; set; }
        ToolButton undo_button { get; set; }
        ToolButton redo_button { get; set; }

        private void update_header () {
            this.undo_button.sensitive = HistoryManager.instance.can_undo ();
            this.redo_button.sensitive = HistoryManager.instance.can_redo ();
        }

        public MainWindow (Gtk.Application app) {
            Object (application: app);
            this.set_default_size (1500, 1000);
            this.window_position = WindowPosition.CENTER;
            this.icon = new Pixbuf.from_resource_at_scale ("/xyz/gelez/spreadsheet/icons/icon.svg", 48, 48, true);

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

        private Grid toolbar () {
            var toolbar = new Grid () {
                border_width = 10,
                column_spacing = 10
            };
            var function_list_bt = new Button.with_label ("f (x)");
            var expr = new Entry () { hexpand = true };

            var popup = new Popover (function_list_bt) {
                modal = true,
                position = PositionType.BOTTOM,
                border_width = 10
            };
            var function_list = new ListBox ();
            foreach (var func in App.functions) {
                var row = new ListBoxRow () { selectable = false };
                row.add (new FunctionPresenter (func));
                row.realize.connect (() => {
                    row.get_window ().cursor = new Cursor.from_name (row.get_display (), "pointer");
                });
                row.button_press_event.connect ((evt) => {
                    expr.text += ")";
                    expr.buffer.insert_text (expr.get_position (), (func.name + "(").data);
                    return true;
                });
                function_list.add (row);
            }
            popup.add (function_list);

            function_list_bt.clicked.connect (popup.show_all);

            expr.activate.connect (() => {
                this.update_formula (expr);
            });
            this.active_sheet.selection_changed.connect ((cell) => {
                if (cell != null) {
                    expr.text = cell.formula;
                    expr.sensitive = true;
                } else {
                    expr.text = "";
                    expr.sensitive = false;
                }
            });

            var style_toggle = new ToggleButton.with_label ("Open Sans 14");
            bool resized = false;
            style_toggle.draw.connect ((cr) => { // draw the color rectangle on the right of the style button
                int spacing = 20;
                int border = this.get_style_context ().get_border (StateFlags.NORMAL).left;
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
            var style_popup = new Popover (style_toggle) {
                modal = true,
                position = PositionType.BOTTOM,
                border_width = 10
            };
            style_toggle.toggled.connect (() => {
                if (style_toggle.active) {
                    style_popup.show_all ();
                }
            });
            style_popup.closed.connect (() => {
                style_toggle.active = false;
            });
            style_popup.add (new Label ("Nothing to show here... yet!"));

            toolbar.attach (function_list_bt, 0, 0, 1, 1);
            toolbar.attach (expr, 1, 0);
            toolbar.add (style_toggle);
            return toolbar;
        }

        private Box sheet () {
            Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
            Gtk.Viewport viewport = new Gtk.Viewport (null, null);
            viewport.set_size_request (this.tabs.get_allocated_width (), this.tabs.get_allocated_height ());
            scrolled.add (viewport);

            var sheet = new Sheet ();
            viewport.add (sheet);

            this.tabs.insert_tab (new Tab ("New Sheet", null, scrolled), 0);

            var layout = new Box (Orientation.VERTICAL, 0) { homogeneous = false };
            layout.pack_start (this.toolbar (), false);
            layout.pack_start (this.tabs);
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

        private string parse_formula (string formula) {
            try {
                var parser = new Parser.Parser (new Lexer ().tokenize (formula));
                var expression = parser.parse ();
                return ((double)expression.eval (this.active_sheet)).to_string ();
            } catch (ParserError err) {
                debug ("Error: " + err.message);
                return "Error";
            }
        }

        private void update_formula (Entry expr) {
            if (this.active_sheet.selected_cell != null) {
                HistoryManager.instance.do_action (new HistoryAction<string?, Cell> (
                    @"Change the formula to $(expr.text)",
                    this.active_sheet.selected_cell,
                    (_text, _target) => {
                        string text = _text == null ? expr.text : (string)_text;
                        Cell target = (Cell)_target;

                        string last_text = target.formula;
                        target.formula = text;
                        target.display_content = this.parse_formula (text);

                        var undo_data = last_text;
                        return new StateChange<string> (undo_data, text);
                    },
                    (_text, _target) => {
                        string text = (string)_text;
                        Cell target = (Cell)_target;

                        target.formula = text;
                        expr.text = text;
                        target.display_content = text == "" ? "" : this.parse_formula (text); // avoid 'Unexpected end of file'
                    }
                ));
            }
            update_header ();
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
            Image file_ico = new Image.from_icon_name ("document-new", Gtk.IconSize.SMALL_TOOLBAR);
            file_button = new ToolButton (file_ico, null);
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
            undo_button = new ToolButton (undo_ico, null);
            undo_button.clicked.connect (() => {
                HistoryManager.instance.undo ();
                update_header ();
            });
            this.header.pack_start (undo_button);

            Image redo_ico = new Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
            redo_button = new ToolButton (redo_ico, null);
            redo_button.clicked.connect (() => {
                HistoryManager.instance.redo ();
                update_header ();
            });
            this.header.pack_start (redo_button);

            this.update_header ();
        }

        void clear_header () {
            foreach (var button in this.header.get_children ()) {
                button.destroy ();
            }
        }
    }
}
