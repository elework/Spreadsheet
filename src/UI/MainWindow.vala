using Spreadsheet.Widgets;
using Spreadsheet.Models;
using Spreadsheet.Services;
using Spreadsheet.Services.Formula;
using Spreadsheet.Services.CSV;
using Spreadsheet.Services.Parsing;
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

        public SpreadSheet file {
            get {
                return this._file;
            }
            set {
                this._file = value;
                this.header.title = value.title;
                this.header.subtitle = value.file_path == null ? "Not saved yet" : value.file_path;

                while (this.tabs.n_tabs > 0) {
                    this.tabs.remove_tab (this.tabs.get_tab_by_index (0));
                }

                foreach (var page in value.pages) {
                    var scrolled = new Gtk.ScrolledWindow (null, null);
                    var viewport = new Gtk.Viewport (null, null);
                    viewport.set_size_request (this.tabs.get_allocated_width (), this.tabs.get_allocated_height ());
                    scrolled.add (viewport);

                    var sheet = new Sheet (page);
                    sheet.selection_changed.connect ((cell) => {
                        if (cell != null) {
                            this.expression.text = cell.formula;
                            this.expression.sensitive = true;
                        } else {
                            this.expression.text = "";
                            this.expression.sensitive = false;
                        }
                    });
                    viewport.add (sheet);

                    this.tabs.insert_tab (new Tab (page.title, null, scrolled), 0);
                }
            }
        }
        private SpreadSheet _file;

        ToolButton file_button { get; set; }
        ToolButton open_button { get; set; }
        ToolButton save_button { get; set; }
        ToolButton undo_button { get; set; }
        ToolButton redo_button { get; set; }

        Entry expression;

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
            this.expression = new Entry () { hexpand = true };

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
                    this.expression.text += ")";
                    this.expression.buffer.insert_text (this.expression.get_position (), (func.name + "(").data);
                    return true;
                });
                function_list.add (row);
            }
            popup.add (function_list);

            function_list_bt.clicked.connect (popup.show_all);

            this.expression.activate.connect (this.update_formula);

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
            toolbar.attach (this.expression, 1, 0);
            toolbar.add (style_toggle);
            return toolbar;
        }

        private Box sheet () {
            var layout = new Box (Orientation.VERTICAL, 0) { homogeneous = false };
            layout.pack_start (this.toolbar (), false);
            layout.pack_start (this.tabs);
            return layout;
        }

        private void open_sheet () {
            this.init_header ();
            var file = new SpreadSheet () {
                title = "New Spreadsheet"
            };
            file.add_page (new Page.empty () { title = "Page 1" });
            this.file = file;
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

        private void update_formula () {
            if (this.active_sheet.selected_cell != null) {
                HistoryManager.instance.do_action (new HistoryAction<string?, Cell> (
                    @"Change the formula to $(this.expression.text)",
                    this.active_sheet.selected_cell,
                    (_text, _target) => {
                        string text = _text == null ? this.expression.text : (string)_text;
                        Cell target = (Cell)_target;

                        string last_text = target.formula;
                        target.formula = text;

                        var undo_data = last_text;
                        return new StateChange<string> (undo_data, text);
                    },
                    (_text, _target) => {
                        string text = (string)_text;
                        Cell target = (Cell)_target;

                        target.formula = text;
                        this.expression.text = text;
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

            Image save_ico = new Image.from_icon_name ("document-save", Gtk.IconSize.SMALL_TOOLBAR);
            save_button = new ToolButton (save_ico, null);
            save_button.clicked.connect (() => {
                string path = "";
                if (this.file.file_path.has_suffix (".csv")) {
                    path = this.file.file_path;
                } else {
                    var chooser = new FileChooserDialog (
                        "Save your work", this, FileChooserAction.SAVE,
                        "_Cancel",
                        ResponseType.CANCEL,
                        "_Open",
                        ResponseType.ACCEPT);

                    Gtk.FileFilter filter = new Gtk.FileFilter ();
                    filter.add_pattern ("*.csv");
                    filter.set_filter_name ("CSV files");
                    chooser.set_filter (filter);

                    if (chooser.run () == ResponseType.ACCEPT) {
                        path = chooser.get_filename ();
                    } else {
                        chooser.close ();
                        return;
                    }

                    chooser.close ();
                }
                new CSVWriter (this.active_sheet.page).write_to_file (path);
            });
            this.header.pack_end (save_button);

            Image open_ico = new Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
            ToolButton open_button = new ToolButton (open_ico, null);
            open_button.clicked.connect (() => {
                var chooser = new FileChooserDialog (
    				"Open a file", this, FileChooserAction.OPEN,
    				"_Cancel",
    				ResponseType.CANCEL,
    				"_Open",
    				ResponseType.ACCEPT);

        		Gtk.FileFilter filter = new Gtk.FileFilter ();
                filter.add_pattern ("*.csv");
                filter.set_filter_name ("CSV files");
        		chooser.set_filter (filter);

        		if (chooser.run () == ResponseType.ACCEPT) {
        			this.file = new CSVParser.from_file (chooser.get_filename ()).parse ();
        		}

        		chooser.close ();
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
