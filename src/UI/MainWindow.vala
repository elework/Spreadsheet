/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

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

    private Gtk.HeaderBar header;
    private Granite.HeaderLabel header_label;
    private Gtk.Button new_window_button;
    private Gtk.Button open_button;
    private Gtk.Button save_as_button;
    private Gtk.Button redo_button;
    private Gtk.Button undo_button;

    public Widgets.ActionBar action_bar { get; private set; }

    private WelcomeView welcome_view;
    private Gtk.Box edit_view;
    private Stack app_stack;
    private Gtk.MenuButton function_list_bt;
    private Entry expression;
    private Gtk.MenuButton style_toggle;
    private Popover style_popup;

    private Adw.TabView tab_view = new Adw.TabView ();

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

            header_label.label = value.title;
            header_label.secondary_text = display_path == null ? _("Not saved yet") : display_path;

            while (tab_view.n_pages > 0) {
                tab_view.close_page (tab_view.get_nth_page (0));
            }

            Sheet? last_sheet = null;
            foreach (var page in value.pages) {
                var viewport = new Gtk.Viewport (null, null);
                viewport.set_size_request (tab_view.get_allocated_width (), tab_view.get_allocated_height ());
                var scrolled = new Gtk.ScrolledWindow () {
                    child = viewport
                };

                var sheet = new Sheet (page, this);
                foreach (var cell in page.cells) {
                    if (cell.selected) {
                        style_popup.child = new StyleModal (cell.font_style, cell.cell_style);
                        break;
                    }
                }
                sheet.selection_changed.connect ((cell) => {
                    if (cell != null) {
                        expression.text = cell.formula;
                        function_list_bt.sensitive = true;
                        expression.sensitive = true;
                        style_toggle.sensitive = true;
                        style_popup.child = new StyleModal (cell.font_style, cell.cell_style);
                    } else {
                        expression.text = "";
                        function_list_bt.sensitive = false;
                        expression.sensitive = false;
                        style_toggle.sensitive = false;
                    }
                });
                sheet.forward_key_press.connect ((do_forward) => {
                    expression.grab_focus_without_selecting ();

                    return do_forward (expression);
                });

                sheet.selection_cleared.connect (() => {
                    clear_formula ();
                });

                viewport.child = sheet;
                last_sheet = sheet;

                var tabpage = tab_view.append (scrolled);
                tabpage.title = page.title;
            }
            last_sheet.grab_focus ();
        }
    }

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_NAME_OPEN = "open";
    public const string ACTION_NAME_SAVE_AS = "save_as";
    public const string ACTION_NAME_UNDO = "undo";
    public const string ACTION_NAME_REDO = "redo";
    private const string ACTION_NAME_WELCOME = "welcome";
    private const string ACTION_NAME_SAVE = "save";
    private const string ACTION_NAME_FOCUS_EXPRESSION = "focus_expression";
    private const string ACTION_NAME_UNFOCUS_EXPRESSION = "unfocus_expression";

    public const string[] ACTION_ACCELS_OPEN = { "<Control>o", null };
    public const string[] ACTION_ACCELS_SAVE_AS = { "<Control><Shift>s", null };
    public const string[] ACTION_ACCELS_UNDO = { "<Control>z", null };
    public const string[] ACTION_ACCELS_REDO = { "<Control><Shift>z", null };
    private const string[] ACTION_ACCELS_WELCOME = { "<Alt>Home", null };
    private const string[] ACTION_ACCELS_SAVE = { "<Control>s", null };
    private const string[] ACTION_ACCELS_FOCUS_EXPRESSION = { "F2", null };
    private const string[] ACTION_ACCELS_UNFOCUS_EXPRESSION = { "Escape", null };

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
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        recents_manager = RecentsManager.get_default ();
        welcome_view = new WelcomeView ();

        edit_view = sheet ();

        app_stack = new Stack ();
        app_stack.add_child (welcome_view);
        app_stack.add_child (edit_view);

        header = build_header ();
        set_titlebar (header);

        child = app_stack;

        add_action_entries (ACTION_ENTRIES, this);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_WELCOME, ACTION_ACCELS_WELCOME);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_OPEN, ACTION_ACCELS_OPEN);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_SAVE, ACTION_ACCELS_SAVE);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_SAVE_AS, ACTION_ACCELS_SAVE_AS);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_UNDO, ACTION_ACCELS_UNDO);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_REDO, ACTION_ACCELS_REDO);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_FOCUS_EXPRESSION, ACTION_ACCELS_FOCUS_EXPRESSION);
        app.set_accels_for_action (ACTION_PREFIX + ACTION_NAME_UNFOCUS_EXPRESSION, ACTION_ACCELS_UNFOCUS_EXPRESSION);

        update_header ();

        welcome_view.new_activated.connect (new_sheet);
        welcome_view.open_choose_activated.connect (open_sheet_choose);
        welcome_view.open_activated.connect ((path) => {
            open_sheet (path);
        });

        show_welcome ();
    }

    private Grid toolbar () {
        var toolbar = new Grid () {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10
        };
        toolbar.column_spacing = 10;

        expression = new Entry ();
        expression.hexpand = true;
        expression.tooltip_text = _("Click to insert numbers or functions to a selected cell");

        var function_list = new ListBox ();
        var functions_liststore = new GLib.ListStore (Type.OBJECT);
        foreach (var func in FunctionManager.get_default ().functions) {
            functions_liststore.append (new FuncSearchList (func.name, func.doc));

            var row = new FunctionListRow (func);
            function_list.append (row);
        }

        function_list.row_activated.connect ((row) => {
            var func_row = row as FunctionListRow;

            expression.text += ")";
            expression.buffer.insert_text (expression.get_position (), (func_row.function.name + "(").data);
        });

        var function_list_search_entry = new SearchEntry ();
        function_list_search_entry.margin_bottom = 6;
        function_list_search_entry.placeholder_text = _("Search functions");

        var function_list_scrolled = new ScrolledWindow ();
        function_list_scrolled.vexpand = true;
        function_list_scrolled.hexpand = true;
        function_list_scrolled.child = function_list;

        var function_list_grid = new Grid ();
        function_list_grid.orientation = Orientation.HORIZONTAL;
        function_list_grid.margin_top = 10;
        function_list_grid.margin_bottom = 10;
        function_list_grid.margin_start = 10;
        function_list_grid.margin_end = 10;
        function_list_grid.attach (function_list_search_entry, 0, 0, 1, 1);
        function_list_grid.attach (function_list_scrolled, 0, 1, 1, 1);

        var popup = new Popover ();
        popup.width_request = 320;
        popup.height_request = 600;
        popup.position = PositionType.BOTTOM;
        popup.child = function_list_grid;

        function_list_bt = new Gtk.MenuButton () {
            label = "f(x)"
        };
        function_list_bt.get_style_context ().add_class ("func-list-button");
        function_list_bt.tooltip_text = _("Insert functions to a selected cell");

        expression.activate.connect (update_formula);

        function_list.set_filter_func ((list_box_row) => {
            var item = (FuncSearchList) functions_liststore.get_item (list_box_row.get_index ());
            return function_list_search_entry.text.down () in item.funcsearchlist_item.down ();
        });

        function_list_search_entry.search_changed.connect (() => {
            function_list.invalidate_filter ();
        });

        style_popup = new Popover ();
        style_popup.position = PositionType.BOTTOM;

        style_toggle = new Gtk.MenuButton () {
            label = "Open Sans 14",
            popover = style_popup
        };
        style_toggle.get_style_context ().add_class ("toggle-button");
        style_toggle.tooltip_text = _("Set colors to letters in a selected cell");
        bool resized = false;
        /*
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
            Util.draw_rounded_path (cr, width - (border + square_size - padding), border + padding, square_size - (padding * 2), square_size - (padding * 2), 2);
            cr.fill ();
            return false;
        });
        */

        toolbar.attach (function_list_bt, 0, 0, 1, 1);
        toolbar.attach (expression, 1, 0);
        toolbar.attach (style_toggle, 2, 0);
        return toolbar;
    }

    private Box sheet () {
        action_bar = new Widgets.ActionBar ();

        // TODO: Create new sheet on click
        var new_tab_button = new Gtk.Button.from_icon_name ("list-add-symbolic");

        var tab_bar = new Adw.TabBar () {
            view = tab_view,
            autohide = false,
            expand_tabs = false,
            inverted = true,
            start_action_widget = new_tab_button
        };

        var layout = new Box (Orientation.VERTICAL, 0);
        layout.homogeneous = false;
        layout.append (toolbar ());
        layout.append (tab_bar);
        layout.append (tab_view);
        layout.append (action_bar);
        return layout;
    }

    private void on_welcome_activate () {
        if (app_stack.visible_child == welcome_view) {
            return;
        }

        show_welcome ();
    }

    private void on_open_activate () {
        open_sheet_choose ();
    }

    private void on_save_activate () {
        if (app_stack.visible_child != edit_view) {
            return;
        }

        save_sheet ();
    }

    private void on_save_as_activate () {
        if (app_stack.visible_child != edit_view) {
            return;
        }

        save_as_sheet ();
    }

    private void on_undo_activate () {
        if (app_stack.visible_child != edit_view) {
            return;
        }

        if (!history_manager.can_undo ()) {
            return;
        }

        undo_sheet ();
    }

    private void on_redo_activate () {
        if (app_stack.visible_child != edit_view) {
            return;
        }

        if (!history_manager.can_redo ()) {
            return;
        }

        redo_sheet ();
    }

    private void on_focus_expression_activate () {
        if (app_stack.visible_child != edit_view) {
            return;
        }

        expression.grab_focus ();
    }

    private void on_unfocus_expression_activate () {
        if (app_stack.visible_child != edit_view) {
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

        set_header_buttons_visibility (true);

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

        save_sheet ();

        app_stack.visible_child = edit_view;
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

            open_sheet (chooser.get_file ().get_path ());

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
            error_dialog.present ();

            return false;
        }

        this.file = file;
        recents_manager.prepend (file.file_path);
        set_header_buttons_visibility (true);
        app_stack.visible_child = edit_view;

        return true;
    }

    // Triggered when an opened sheet is modified
    public void save_sheet () {
        new CSVWriter (active_sheet.page).write_to_file (file.file_path);
        recents_manager.prepend (file.file_path);
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

        chooser.response.connect ((response_id) => {
            if (response_id != ResponseType.ACCEPT) {
                chooser.destroy ();
                return;
            }

            path = chooser.get_file ().get_path ();
            if (!path.has_suffix (".csv")) {
                path += ".csv";
            }

            new CSVWriter (active_sheet.page).write_to_file (path);
            recents_manager.prepend (path);

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
        update_header ();
    }

    private void redo_sheet () {
        history_manager.redo ();
        update_header ();
    }

    public void show_welcome () {
        set_header_buttons_visibility (false);
        header_label.label = _("Spreadsheet");
        header_label.secondary_text = null;
        expression.text = "";

        app_stack.visible_child = welcome_view;
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
        update_header ();
        active_sheet.grab_focus ();
    }

    private Gtk.HeaderBar build_header () {
        new_window_button = new Gtk.Button.from_icon_name ("window-new") {
            tooltip_markup = Granite.markup_accel_tooltip (App.ACTION_ACCELS_NEW, _("Open another window")),
            action_name = App.ACTION_PREFIX + App.ACTION_NAME_NEW
        };

        open_button = new Gtk.Button.from_icon_name ("document-open") {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_OPEN, _("Open a file")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_OPEN
        };

        save_as_button = new Gtk.Button.from_icon_name ("document-save-as") {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_SAVE_AS, _("Save this file with a different name")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_SAVE_AS
        };

        redo_button = new Gtk.Button.from_icon_name ("edit-redo") {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_REDO, _("Redo")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_REDO
        };

        undo_button = new Gtk.Button.from_icon_name ("edit-undo") {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_UNDO, _("Undo")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_UNDO
        };

        header_label = new Granite.HeaderLabel (_("Spreadsheet")) {
            secondary_text = _("Not saved yet")
        };

        var header = new Gtk.HeaderBar () {
            title_widget = header_label
        };
        header.pack_start (new_window_button);
        header.pack_start (open_button);
        header.pack_start (save_as_button);
        header.pack_end (redo_button);
        header.pack_end (undo_button);

        return header;
    }

    private void set_header_buttons_visibility (bool is_visible) {
        new_window_button.visible = is_visible;
        open_button.visible = is_visible;
        save_as_button.visible = is_visible;
        redo_button.visible = is_visible;
        undo_button.visible = is_visible;
    }

    private void update_header () {
        bool can_undo = history_manager.can_undo ();
        ((SimpleAction) lookup_action (MainWindow.ACTION_NAME_UNDO)).set_enabled (can_undo);

        bool can_redo = history_manager.can_redo ();
        ((SimpleAction) lookup_action (MainWindow.ACTION_NAME_REDO)).set_enabled (can_redo);
    }
}
