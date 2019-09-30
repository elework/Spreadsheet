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

    public HeaderBar header {
        get;
        set;
        default = new HeaderBar () { show_close_button = true };
    }

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
            header.subtitle = value.file_path == null ? _("Not saved yet") : value.file_path;

            while (tabs.n_tabs > 0) {
                tabs.remove_tab (tabs.get_tab_by_index (0));
            }

            Sheet? last_sheet = null;
            foreach (var page in value.pages) {
                var scrolled = new Gtk.ScrolledWindow (null, null);
                var viewport = new Gtk.Viewport (null, null);
                viewport.set_size_request (tabs.get_allocated_width (), tabs.get_allocated_height ());
                scrolled.add (viewport);

                var sheet = new Sheet (page, this);
                foreach (var cell in page.cells) {
                    style_popup.foreach ((ch) => {
                        style_popup.remove (ch);
                    });
                    if (cell.selected) {
                        style_popup.add (new StyleModal (cell.font_style, cell.cell_style));
                        break;
                    }
                }
                sheet.selection_changed.connect ((cell) => {
                    style_popup.foreach ((ch) => {
                        style_popup.remove (ch);
                    });
                    if (cell != null) {
                        expression.text = cell.formula;
                        function_list_bt.sensitive = true;
                        expression.sensitive = true;
                        style_toggle.sensitive = true;
                        style_popup.add (new StyleModal (cell.font_style, cell.cell_style));
                    } else {
                        expression.text = "";
                        function_list_bt.sensitive = false;
                        expression.sensitive = false;
                        style_toggle.sensitive = false;
                    }
                });
                sheet.focus_expression_entry.connect (() => {
                    expression.grab_focus ();
                });

                sheet.selection_cleared.connect (() => {
                    clear_formula ();
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
    ToolButton save_as_button { get; set; }
    ToolButton undo_button { get; set; }
    ToolButton redo_button { get; set; }

    private Button function_list_bt;
    public Entry expression;
    private ToggleButton style_toggle;
    Popover style_popup;

    public App app { get; construct; }
    public HistoryManager history_manager { get; private set; default = new HistoryManager (); }
    private uint configure_id;

    private void update_header () {
        undo_button.sensitive = history_manager.can_undo ();
        redo_button.sensitive = history_manager.can_redo ();
    }

    public MainWindow (App app) {
        Object (
            application: app,
            app: app
        );
    }

    construct {
        app_stack.add_named (welcome (), "welcome");
        app_stack.add_named (sheet (), "app");
        set_titlebar (header);

        add (app_stack);
        show_welcome ();
    }

    protected override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            Spreadsheet.App.settings.set_boolean ("is-maximized", is_maximized);

            if (!is_maximized) {
                int x, y, w, h;
                get_position (out x, out y);
                get_size (out w, out h);
                Spreadsheet.App.settings.set ("window-position", "(ii)", x, y);
                Spreadsheet.App.settings.set ("window-size", "(ii)", w, h);
            }

            return false;
        });

        return base.configure_event (event);
    }

    private Welcome welcome () {
        var welcome = new Welcome (_("Spreadsheet"), _("Start something new, or continue what you have been working on."));
        welcome.append ("document-new", _("New Sheet"), _("Create an empty sheet"));
        welcome.append ("document-open", _("Open File"), _("Choose a saved file"));
        //  TODO: Uncomment when we support opening recent files in welcome screen
        //  See https://github.com/ryonakano/Spreadsheet/issues/56
        //  welcome.append ("x-office-spreadsheet", _("Open Last File"), _("Continue working on foo.xlsx"));
        welcome.activated.connect ((index) => {
            if (index == 0) {
                new_sheet ();
            } else if (index == 1) {
                var chooser = new FileChooserDialog (
                    _("Open a file"), this, FileChooserAction.OPEN,
                    _("_Cancel"),
                    ResponseType.CANCEL,
                    _("_Open"),
                    ResponseType.ACCEPT);

                Gtk.FileFilter filter = new Gtk.FileFilter ();
                filter.add_pattern ("*.csv");
                filter.set_filter_name (_("CSV files"));
                chooser.add_filter (filter);

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
        function_list_bt = new Button.with_label ("f (x)");
        function_list_bt.tooltip_text = _("Insert functions to a selected cell");
        expression = new Entry () { hexpand = true };
        expression.tooltip_text = _("Click to insert numbers or functions to a selected cell");

        var popup = new Popover (function_list_bt) {
            width_request = 320,
            height_request = 600,
            modal = true,
            position = PositionType.BOTTOM,
            border_width = 10
        };

        var function_list = new ListBox ();
        var functions_liststore = new GLib.ListStore (Type.OBJECT);
        foreach (var func in App.functions) {
            functions_liststore.append (new FuncSearchList (func.name, func.doc));

            var row = new ListBoxRow () { selectable = false };
            row.margin_top = row.margin_bottom = 3;
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

        var function_list_search_entry = new SearchEntry ();
        function_list_search_entry.margin_bottom = 6;
        function_list_search_entry.placeholder_text = _("Search functions");

        var function_list_scrolled = new ScrolledWindow (null, null);
        function_list_scrolled.expand = true;
        function_list_scrolled.add (function_list);

        var function_list_grid = new Grid ();
        function_list_grid.orientation = Orientation.HORIZONTAL;
        function_list_grid.attach (function_list_search_entry, 0, 0, 1, 1);
        function_list_grid.attach (function_list_scrolled, 0, 1, 1, 1);

        popup.add (function_list_grid);

        function_list_bt.clicked.connect (popup.show_all);

        expression.activate.connect (update_formula);

        function_list.set_filter_func ((list_box_row) => {
            var item = (FuncSearchList) functions_liststore.get_item (list_box_row.get_index ());
            return function_list_search_entry.text.down () in item.funcsearchlist_item.down ();
        });

        function_list_search_entry.search_changed.connect (() => {
            function_list.invalidate_filter ();
        });

        style_toggle = new ToggleButton.with_label ("Open Sans 14");
        style_toggle.tooltip_text = _("Set colors to letters in a selected cell");
        bool resized = false;
        style_toggle.draw.connect ((cr) => { // draw the color rectangle on the right of the style button
            int spacing = 10;
            int padding = 5;
            int border = get_style_context ().get_border (StateFlags.NORMAL).left;
            int square_size = style_toggle.get_allocated_height () - (border * 2);
            int width = style_toggle.get_allocated_width ();

            if (!resized) {
                style_toggle.get_child ().halign = Gtk.Align.START;
                style_toggle.width_request += width + spacing + square_size + border; // some space for the color icon
                resized = true;
            }

            cr.set_source_rgb (0, 0, 0);
            draw_rounded_path (cr, width - (border + square_size - padding), border + padding, square_size - (padding * 2), square_size - (padding * 2), 2);
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

    private void new_sheet () {
        int id = 1;
        string file_name = "";
        string suffix = "";
        string documents = "";
        File? path = null;

        init_header ();

        do {
            file_name = _("Untitled Spreadsheet %i").printf (id++);
            suffix = ".csv";

            documents = Environment.get_user_special_dir (UserDirectory.DOCUMENTS);
            path = File.new_for_path ("%s/%s%s".printf (documents, file_name, suffix));
        } while (path.query_exists ());

        var file = new SpreadSheet () {
            title = file_name,
            file_path = path.get_path ()
        };
        file.add_page (new Page.empty () { title = _("Sheet 1") });
        this.file = file;
        show_all ();
        save_sheet ();

        app_stack.set_visible_child_name ("app");
        id++;
    }

    public void open_sheet () {
        var chooser = new FileChooserDialog (
            _("Open a file"), this, FileChooserAction.OPEN,
            _("_Cancel"),
            ResponseType.CANCEL,
            _("_Open"),
            ResponseType.ACCEPT);

        Gtk.FileFilter filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.csv");
        filter.set_filter_name (_("CSV files"));
        chooser.add_filter (filter);

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

    // Triggered when an opened sheet is modified
    public void save_sheet () {
        new CSVWriter (active_sheet.page).write_to_file (file.file_path);
    }

    public void save_as_sheet () {
        string path = "";
        var chooser = new FileChooserDialog (
            _("Save your work"), this, FileChooserAction.SAVE,
            _("_Cancel"),
            ResponseType.CANCEL,
            _("_Save"),
            ResponseType.ACCEPT);

        Gtk.FileFilter filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.csv");
        filter.set_filter_name (_("CSV files"));
        chooser.add_filter (filter);
        chooser.do_overwrite_confirmation = true;

        if (chooser.run () == ResponseType.ACCEPT) {
            path = chooser.get_filename ();
            if (!path.has_suffix (".csv")) {
                path += ".csv";
            }
        } else {
            chooser.close ();
            return;
        }

        chooser.close ();
        new CSVWriter (active_sheet.page).write_to_file (path);

        // Open the saved file
        try {
            file = new CSVParser.from_file (path).parse ();
        } catch (ParserError err) {
            debug ("Error: " + err.message);
        }
    }

    public void undo_sheet () {
        history_manager.undo ();
        update_header ();
    }

    public void redo_sheet () {
        history_manager.redo ();
        update_header ();
    }

    public void show_welcome () {
        clear_header ();
        header.title = _("Spreadsheet");
        header.subtitle = null;
        expression.text = "";

        app_stack.set_visible_child_name ("welcome");
    }

    private void update_formula () {
        if (active_sheet.selected_cell != null) {
            history_manager.do_action (new HistoryAction<string?, Cell> (
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

    private void clear_formula () {
        if (active_sheet.selected_cell != null) {
            history_manager.do_action (new HistoryAction<string?, Cell> (
                "Clear the formula",
                active_sheet.selected_cell,
                (_text, _target) => {
                    Cell target = (Cell)_target;
                    string undo_data = target.formula;
                    target.formula = "";
                    expression.text = "";
                    return new StateChange<string> (undo_data, "");
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

        Image file_ico = new Image.from_icon_name ("window-new", Gtk.IconSize.SMALL_TOOLBAR);
        file_button = new ToolButton (file_ico, null);
        file_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>N"}, _("Open another window"));
        file_button.clicked.connect (() => {
            app.new_window ();
        });
        header.pack_start (file_button);

        Image open_ico = new Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        ToolButton open_button = new ToolButton (open_ico, null);
        open_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>O"}, _("Open a file"));
        open_button.clicked.connect (() => {
            open_sheet ();
        });
        header.pack_start (open_button);

        Image save_as_ico = new Image.from_icon_name ("document-save-as", Gtk.IconSize.SMALL_TOOLBAR);
        save_as_button = new ToolButton (save_as_ico, null);
        save_as_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>S"}, _("Save this file with a different name"));
        save_as_button.clicked.connect (() => {
            save_as_sheet ();
        });
        header.pack_start (save_as_button);

        Image redo_ico = new Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
        redo_button = new ToolButton (redo_ico, null);
        redo_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>Z"}, _("Redo"));
        redo_button.clicked.connect (() => {
            redo_sheet ();
        });
        header.pack_end (redo_button);

        Image undo_ico = new Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
        undo_button = new ToolButton (undo_ico, null);
        undo_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>Z"}, _("Undo"));
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
