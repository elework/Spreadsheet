using Spreadsheet.Widgets;
using Spreadsheet.Models;
using Spreadsheet.Services;
using Spreadsheet.Services.CSV;
using Spreadsheet.Services.Parsing;
using Gtk;
using Gdk;

public class Spreadsheet.UI.MainWindow : ApplicationWindow {
    public App app { get; construct; }
    public HistoryManager history_manager { get; private set; default = new HistoryManager (); }
    private RecentsManager recents_manager;
    private uint configure_id;

    private TitleBar header;
    public Widgets.ActionBar action_bar { get; private set; }

    private WelcomeView welcome_view;
    private Stack app_stack;
    private Button function_list_bt;
    private Entry expression;
    private ToggleButton style_toggle;
    private Popover style_popup;

    private Hdy.TabView tab_view = new Hdy.TabView ();

    public Sheet active_sheet {
        get {
            ScrolledWindow scroll = (ScrolledWindow)tab_view.selected_page.child;
            Viewport vp = (Viewport)scroll.get_child ();
            return (Sheet)vp.get_child ();
        }
    }

    private SpreadSheet _file;
    public SpreadSheet file {
        get {
            return _file;
        }
        set {
            _file = value;

            string? display_path = value.file_path;
            if (GLib.Environment.get_home_dir () in display_path) {
                display_path = display_path.replace (GLib.Environment.get_home_dir (), "~");
            }

            header.set_titles (value.title, display_path == null ? _("Not saved yet") : display_path);

            while (tab_view.n_pages > 0) {
                tab_view.close_page (tab_view.get_nth_page (0));
            }

            Sheet? last_sheet = null;
            foreach (var page in value.pages) {
                var scrolled = new Gtk.ScrolledWindow (null, null);
                var viewport = new Gtk.Viewport (null, null);
                viewport.set_size_request (tab_view.get_allocated_width (), tab_view.get_allocated_height ());
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
                sheet.forward_key_press.connect ((do_forward) => {
                    expression.grab_focus_without_selecting ();
                    expression.move_cursor (Gtk.MovementStep.BUFFER_ENDS, expression.text.length, false);

                    return do_forward (expression);
                });

                sheet.selection_cleared.connect (() => {
                    clear_formula ();
                });

                viewport.add (sheet);
                last_sheet = sheet;

                var tabpage = tab_view.append (scrolled);
                tabpage.title = page.title;
            }
            last_sheet.grab_focus ();
        }
    }

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_NAME_NEW = "new";
    public const string ACTION_NAME_OPEN = "open";
    public const string ACTION_NAME_SAVE_AS = "save_as";
    public const string ACTION_NAME_UNDO = "undo";
    public const string ACTION_NAME_REDO = "redo";
    private const string ACTION_NAME_WELCOME = "welcome";
    private const string ACTION_NAME_SAVE = "save";
    private const string ACTION_NAME_FOCUS_EXPRESSION = "focus_expression";
    private const string ACTION_NAME_UNFOCUS_EXPRESSION = "unfocus_expression";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_NAME_WELCOME, on_welcome_activate },
        { ACTION_NAME_OPEN, on_open_activate },
        { ACTION_NAME_SAVE, on_save_activate },
        { ACTION_NAME_SAVE_AS, on_save_as_activate },
        { ACTION_NAME_UNDO, on_undo_activate },
        { ACTION_NAME_REDO, on_redo_activate },
        { ACTION_NAME_FOCUS_EXPRESSION, on_focus_expression_activate },
        { ACTION_NAME_UNFOCUS_EXPRESSION, on_unfocus_expression_activate },
    };

    public MainWindow (App app) {
        Object (
            application: app,
            app: app
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/io/github/elework/spreadsheet/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        recents_manager = RecentsManager.get_default ();
        welcome_view = new WelcomeView ();

        app_stack = new Stack ();
        app_stack.add_named (welcome_view, "welcome");
        app_stack.add_named (sheet (), "app");

        header = new TitleBar (this);
        set_titlebar (header);

        add (app_stack);

        add_action_entries (ACTION_ENTRIES, this);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_WELCOME, { "<Alt>Home" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_OPEN, { "<Control>o" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_SAVE, { "<Control>s" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_SAVE_AS, { "<Control><Shift>s" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_UNDO, { "<Control>z" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_REDO, { "<Control><Shift>z" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_FOCUS_EXPRESSION, { "F2" });
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_UNFOCUS_EXPRESSION, { "Escape" });

        welcome_view.new_activated.connect (new_sheet);
        welcome_view.open_choose_activated.connect (open_sheet_choose);
        welcome_view.open_activated.connect ((path) => {
            open_sheet (path);
        });

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
                int w;
                int h;
                get_size (out w, out h);
                Spreadsheet.App.settings.set ("window-size", "(ii)", w, h);
            }

            return false;
        });

        return base.configure_event (event);
    }

    private Grid toolbar () {
        var toolbar = new Grid ();
        toolbar.border_width = 10;
        toolbar.column_spacing = 10;

        function_list_bt = new Button.with_label ("f(x)");
        function_list_bt.get_style_context ().add_class ("func-list-button");
        function_list_bt.tooltip_text = _("Insert functions to a selected cell");

        expression = new Entry ();
        expression.hexpand = true;
        expression.tooltip_text = _("Click to insert numbers or functions to a selected cell");

        var popup = new Popover (function_list_bt);
        popup.width_request = 320;
        popup.height_request = 600;
        popup.modal = true;
        popup.position = PositionType.BOTTOM;
        popup.border_width = 10;

        var function_list = new ListBox ();
        var functions_liststore = new GLib.ListStore (Type.OBJECT);
        foreach (var func in FunctionManager.get_default ().functions) {
            functions_liststore.append (new FuncSearchList (func.name, func.doc));

            var row = new FunctionListRow (func);
            function_list.add (row);
        }

        function_list.row_activated.connect ((row) => {
            var func_row = row as FunctionListRow;

            expression.text += ")";
            expression.buffer.insert_text (expression.get_position (), (func_row.function.name + "(").data);
        });

        var function_list_search_entry = new SearchEntry ();
        function_list_search_entry.margin_bottom = 6;
        function_list_search_entry.placeholder_text = _("Search functions");

        var function_list_scrolled = new ScrolledWindow (null, null);
        function_list_scrolled.vexpand = true;
        function_list_scrolled.hexpand = true;
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
        style_toggle.get_style_context ().add_class ("toggle-button");
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

        style_popup = new Popover (style_toggle);
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

        toolbar.attach (function_list_bt, 0, 0, 1, 1);
        toolbar.attach (expression, 1, 0);
        toolbar.add (style_toggle);
        return toolbar;
    }

    private Box sheet () {
        action_bar = new Widgets.ActionBar ();

        // TODO: Create new sheet on click
        var new_tab_button = new Gtk.Button.from_icon_name ("list-add-symbolic");

        var tab_bar = new Hdy.TabBar () {
            view = tab_view,
            autohide = false,
            expand_tabs = false,
            inverted = true,
            start_action_widget = new_tab_button
        };

        var layout = new Box (Orientation.VERTICAL, 0);
        layout.homogeneous = false;
        layout.pack_start (toolbar (), false);
        layout.pack_start (tab_bar, false);
        layout.pack_start (tab_view);
        layout.pack_end (action_bar, false);
        return layout;
    }

    private void on_welcome_activate () {
        if (app_stack.visible_child_name == "welcome") {
            return;
        }

        show_welcome ();
    }

    private void on_open_activate () {
        open_sheet_choose ();
    }

    private void on_save_activate () {
        if (app_stack.visible_child_name != "app") {
            return;
        }

        save_sheet ();
    }

    private void on_save_as_activate () {
        if (app_stack.visible_child_name != "app") {
            return;
        }

        save_as_sheet ();
    }

    private void on_undo_activate () {
        if (app_stack.visible_child_name != "app") {
            return;
        }

        if (!history_manager.can_undo ()) {
            return;
        }

        undo_sheet ();
    }

    private void on_redo_activate () {
        if (app_stack.visible_child_name != "app") {
            return;
        }

        if (!history_manager.can_redo ()) {
            return;
        }

        redo_sheet ();
    }

    private void on_focus_expression_activate () {
        if (app_stack.visible_child_name != "app") {
            return;
        }

        expression.grab_focus ();
    }

    private void on_unfocus_expression_activate () {
        if (app_stack.visible_child_name != "app") {
            return;
        }

        active_sheet.grab_focus ();
        expression.text = "";
    }

    private void new_sheet () {
        int id = 1;
        string file_name = "";
        string suffix = "";
        string documents = "";
        File? path = null;

        header.set_buttons_visibility (true);

        do {
            file_name = _("Untitled Spreadsheet %i").printf (id++);
            suffix = ".csv";

            documents = Environment.get_user_special_dir (UserDirectory.DOCUMENTS);
            path = File.new_for_path ("%s/%s%s".printf (documents, file_name, suffix));
        } while (path.query_exists ());

        var page = new Page.empty ();
        page.title = _("Sheet 1");

        var file = new SpreadSheet ();
        file.title = file_name;
        file.file_path = path.get_path ();
        file.add_page (page);
        this.file = file;

        show_all ();
        save_sheet ();

        app_stack.set_visible_child_name ("app");
        id++;
    }

    private void open_sheet_choose () {
        var chooser = new FileChooserNative (
            _("Open a file"), this, FileChooserAction.OPEN, _("_Open"), _("_Cancel")
        );

        Gtk.FileFilter filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.csv");
        filter.set_filter_name (_("CSV files"));
        chooser.add_filter (filter);

        chooser.response.connect ((response_id) => {
            if (response_id != ResponseType.ACCEPT) {
                chooser.destroy ();
                return;
            }

            open_sheet (chooser.get_filename ());

            chooser.destroy ();
        });

        chooser.show ();
    }

    public bool open_sheet (string path) {
        SpreadSheet file;

        try {
            file = new CSVParser.from_file (path).parse ();
        } catch (ParserError err) {
            warning ("Failed to parse CSV file. path=%s: %s", path, err.message);

            var error_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                _("Unable to Open File"),
                _("Failed to parse file. The file may not be a valid CSV format."),
                "dialog-warning",
                Gtk.ButtonsType.CLOSE
            ) {
                transient_for = this,
                modal = true
            };
            error_dialog.response.connect (error_dialog.destroy);
            error_dialog.show_all ();

            return false;
        }

        this.file = file;
        recents_manager.add_recents (file.file_path);
        header.set_buttons_visibility (true);
        app_stack.set_visible_child_name ("app");
        show_all ();

        return true;
    }

    // Triggered when an opened sheet is modified
    public void save_sheet () {
        new CSVWriter (active_sheet.page).write_to_file (file.file_path);
        recents_manager.add_recents (file.file_path);
    }

    private void save_as_sheet () {
        string path = "";
        var chooser = new FileChooserNative (
            _("Save your work"), this, FileChooserAction.SAVE, _("_Save"), _("_Cancel")
        );

        Gtk.FileFilter filter = new Gtk.FileFilter ();
        filter.add_pattern ("*.csv");
        filter.set_filter_name (_("CSV files"));
        chooser.add_filter (filter);
        chooser.do_overwrite_confirmation = true;

        chooser.response.connect ((response_id) => {
            if (response_id != ResponseType.ACCEPT) {
                chooser.destroy ();
                return;
            }

            path = chooser.get_filename ();
            if (!path.has_suffix (".csv")) {
                path += ".csv";
            }

            new CSVWriter (active_sheet.page).write_to_file (path);
            recents_manager.add_recents (path);

            // Open the saved file
            try {
                file = new CSVParser.from_file (path).parse ();
            } catch (ParserError err) {
                debug ("Error: " + err.message);
            }

            chooser.destroy ();
        });

        chooser.show ();
    }

    private void undo_sheet () {
        history_manager.undo ();
        header.update_header ();
    }

    private void redo_sheet () {
        history_manager.redo ();
        header.update_header ();
    }

    public void show_welcome () {
        header.set_buttons_visibility (false);
        header.set_titles (_("Spreadsheet"), null);
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
        header.update_header ();
        active_sheet.move_bottom ();
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
        header.update_header ();
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
}
