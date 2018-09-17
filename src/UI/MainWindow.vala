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

public class Spreadsheet.UI.MainWindow : ApplicationWindow {

    public HeaderBar header { get; set; default = new HeaderBar (); }

    public Stack app_stack { get; set; default = new Stack (); }

    public DynamicNotebook tabs {
        get;
        set;
        default = new DynamicNotebook () { allow_restoring = false };
    }

    public Sheet active_sheet {
        get {
            ScrolledWindow scroll = (ScrolledWindow)tabs.current.page;
            Viewport vp = (Viewport)scroll.get_child ();
            return (Sheet)vp.get_child ();
        }
    }

    public SpreadSheet file {
        get {
            return _file;
        }
        set {
            _file = value;
            header.title = value.title;
            header.subtitle = value.file_path == null ? "Not saved yet" : value.file_path;

            while (tabs.n_tabs > 0) {
                tabs.remove_tab (tabs.get_tab_by_index (0));
            }

            Sheet? last_sheet = null;
            foreach (var page in value.pages) {
                var scrolled = new Gtk.ScrolledWindow (null, null);
                var viewport = new Gtk.Viewport (null, null);
                viewport.set_size_request (tabs.get_allocated_width (), tabs.get_allocated_height ());
                scrolled.add (viewport);

                var sheet = new Sheet (page);
                sheet.selection_changed.connect ((cell) => {
                    style_popup.foreach ((ch) => {
                        style_popup.remove (ch);
                    });
                    if (cell != null) {
                        expression.text = cell.formula;
                        expression.sensitive = true;
                        style_popup.add (new StyleModal (cell.style));
                    } else {
                        expression.text = "";
                        expression.sensitive = false;
                    }
                });
                sheet.focus_expression_entry.connect (() => {
                    expression.grab_focus ();
                });
                viewport.add (sheet);
                last_sheet = sheet;

                tabs.insert_tab (new Tab (page.title, null, scrolled), 0);
            }
            last_sheet.grab_focus ();
        }
    }
    private SpreadSheet _file;

    ToolButton file_button { get; set; }
    ToolButton open_button { get; set; }
    ToolButton save_button { get; set; }
    ToolButton undo_button { get; set; }
    ToolButton redo_button { get; set; }

    public Entry expression;
    Popover style_popup;

    private void update_header () {
        undo_button.sensitive = HistoryManager.instance.can_undo ();
        redo_button.sensitive = HistoryManager.instance.can_redo ();
    }

    public MainWindow (Gtk.Application app) {
        Object (application: app);
        set_default_size (1500, 1000);
        window_position = WindowPosition.CENTER;
        try {
            icon = new Pixbuf.from_resource_at_scale ("/xyz/gelez/spreadsheet/icons/icon.svg", 48, 48, true);
        } catch (Error err) {
            debug ("Error: " + err.message);
        }

        app_stack.add_named (welcome (), "welcome");
        app_stack.add_named (sheet (), "app");
        set_titlebar (header);

        add (app_stack);
        show_welcome ();
        show_all ();
    }

    private Welcome welcome () {
        var welcome = new Welcome ("Spreadsheet", "Start something new, or continue what you have been working on.");
        welcome.append ("document-new", "New Sheet", "Create an empty sheet");
        welcome.append ("document-open", "Open a file", "Choose a saved presentation");
        welcome.append ("x-office-spreadsheet", "Open last file", "Continue working on foo.xlsx");
        welcome.activated.connect ((index) => {
            if (index == 0) {
                new_sheet ();
            } else if (index == 1) {
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
                    try {
                        file = new CSVParser.from_file (chooser.get_filename ()).parse ();
                    } catch (ParserError err) {
                        debug ("Error: " + err.message);
                    }
                } else {
                    chooser.close ();
                    return;
                }

                chooser.close ();
                init_header ();
                show_all ();
                app_stack.set_visible_child_name ("app");
            }
        });
        return welcome;
    }

    private Grid toolbar () {
        var toolbar = new Grid () {
            border_width = 10,
            column_spacing = 10
        };
        var function_list_bt = new Button.with_label ("f (x)");
        expression = new Entry () { hexpand = true };

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
                expression.text += ")";
                expression.buffer.insert_text (expression.get_position (), (func.name + "(").data);
                return true;
            });
            function_list.add (row);
        }
        popup.add (function_list);

        function_list_bt.clicked.connect (popup.show_all);

        expression.activate.connect (update_formula);

        var style_toggle = new ToggleButton.with_label ("Open Sans 14");
        bool resized = false;
        style_toggle.draw.connect ((cr) => { // draw the color rectangle on the right of the style button
            int spacing = 20;
            int border = get_style_context ().get_border (StateFlags.NORMAL).left;
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
        style_popup = new Popover (style_toggle) {
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

        toolbar.attach (function_list_bt, 0, 0, 1, 1);
        toolbar.attach (expression, 1, 0);
        toolbar.add (style_toggle);
        return toolbar;
    }

    private Box sheet () {
        var layout = new Box (Orientation.VERTICAL, 0) { homogeneous = false };
        layout.pack_start (toolbar (), false);
        layout.pack_start (tabs);
        return layout;
    }

    public void new_sheet () {
        init_header ();
        var file = new SpreadSheet () {
            title = "New Spreadsheet"
        };
        file.add_page (new Page.empty () { title = "Page 1" });
        this.file = file;
        header.show_close_button = true;
        show_all ();

        app_stack.set_visible_child_name ("app");
    }

    public void open_sheet () {
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
            try {
                file = new CSVParser.from_file (chooser.get_filename ()).parse ();
            } catch (ParserError err) {
                debug ("Error: " + err.message);
            }
        } else {
            chooser.close ();
            return;
        }

        chooser.close ();
    }

    public void save_sheet () {
        string path = "";
        if (file.file_path.has_suffix (".csv")) {
            path = file.file_path;
        } else {
            var chooser = new FileChooserDialog (
                "Save your work", this, FileChooserAction.SAVE,
                "_Cancel",
                ResponseType.CANCEL,
                "_Save",
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
        new CSVWriter (active_sheet.page).write_to_file (path);
    }

    public void undo_sheet () {
        HistoryManager.instance.undo ();
        update_header ();
    }

    public void redo_sheet () {
        HistoryManager.instance.redo ();
        update_header ();
    }

    private void show_welcome () {
        clear_header ();
        header.title = "Spreadsheet";
        header.show_close_button = true;

        app_stack.set_visible_child_name ("welcome");
    }

    private void update_formula () {
        if (active_sheet.selected_cell != null) {
            HistoryManager.instance.do_action (new HistoryAction<string?, Cell> (
                @"Change the formula to $(expression.text)",
                active_sheet.selected_cell,
                (_text, _target) => {
                    string text = _text == null ? expression.text : (string)_text;
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
                    expression.text = text;
                }
            ));
        }
        update_header ();
        active_sheet.grab_focus ();
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
        clear_header ();

        Image file_ico = new Image.from_icon_name ("document-new", Gtk.IconSize.SMALL_TOOLBAR);
        file_button = new ToolButton (file_ico, null);
        file_button.clicked.connect (() => {
            new_sheet ();
        });
        header.pack_start (file_button);

        Image open_ico = new Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        ToolButton open_button = new ToolButton (open_ico, null);
        open_button.clicked.connect (() => {
            open_sheet ();
        });
        header.pack_start (open_button);

        Image save_ico = new Image.from_icon_name ("document-save", Gtk.IconSize.SMALL_TOOLBAR);
        save_button = new ToolButton (save_ico, null);
        save_button.clicked.connect (() => {
            save_sheet ();
        });
        header.pack_start (save_button);

        Image redo_ico = new Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
        redo_button = new ToolButton (redo_ico, null);
        redo_button.clicked.connect (() => {
            redo_sheet ();
        });
        header.pack_end (redo_button);

        Image undo_ico = new Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
        undo_button = new ToolButton (undo_ico, null);
        undo_button.clicked.connect (() => {
            undo_sheet ();
        });
        header.pack_end (undo_button);

        update_header ();
    }

    void clear_header () {
        foreach (var button in header.get_children ()) {
            button.destroy ();
        }
    }
}

