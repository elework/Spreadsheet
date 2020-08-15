using Gee;
using Spreadsheet.Services;
using Spreadsheet.UI;
using Spreadsheet.Models;

public class Spreadsheet.App : Gtk.Application {
    public static GLib.Settings settings;
    private MainWindow window;

    public static ArrayList<Function> functions { get; set; default = new ArrayList<Function> (); }

    public static int main (string[] args) {
        Gtk.init (ref args);
        return new App ().run (args);
    }

    static construct {
        settings = new Settings ("com.github.elework.spreadsheet");
    }

    construct {
        application_id = "com.github.elework.spreadsheet";
        flags = ApplicationFlags.HANDLES_OPEN;
        functions.add (new Function ("sum", Functions.sum, _("Add numbers")));
        functions.add (new Function ("mul", Functions.mul, _("Multiply numbers")));
        functions.add (new Function ("div", Functions.div, _("Divide numbers")));
        functions.add (new Function ("sub", Functions.sub, _("Subtract numbers")));
        functions.add (new Function ("mod", Functions.mod, _("Gives the modulo of numbers")));

        functions.add (new Function ("pow", Functions.pow, _("Elevate a number to the power of a second one")));
        functions.add (new Function ("sqrt", Functions.sqrt, _("The square root of a number")));
        functions.add (new Function ("round", Functions.round, _("Rounds a number to the nearest integer")));
        functions.add (new Function ("floor", Functions.floor, _("Removes the decimal part of a number")));
        functions.add (new Function ("min", Functions.min, _("Return the smallest value")));
        functions.add (new Function ("max", Functions.max, _("Return the biggest value")));
        functions.add (new Function ("mean", Functions.mean, _("Gives the mean of a list of numbers")));

        functions.add (new Function ("cos", Functions.cos, _("Gives the cosine of a number (in radians)")));
        functions.add (new Function ("sin", Functions.sin, _("Gives the sine of an angle (in radians)")));
        functions.add (new Function ("tan", Functions.tan, _("Gives the tangent of a number (in radians)")));
        functions.add (new Function ("arccos", Functions.arccos, _("Gives the arc cosine of a number")));
        functions.add (new Function ("arcsin", Functions.arcsin, _("Gives the arc sine of a number")));
        functions.add (new Function ("arctan", Functions.arctan, _("Gives the arc tangent of a number")));
    }

    protected override void open (File[] csv_files, string hint) {
        if (csv_files.length == 0) {
            return;
        }

        setup_shortcuts ();

        foreach (var csv_file in csv_files) {
            new_window ();

            try {
                var file = new Spreadsheet.Services.CSV.CSVParser.from_file (csv_file.get_path ()).parse ();
                window.file = file;
                window.header.init_header ();
                window.show_all ();
                window.app_stack.set_visible_child_name ("app");
            } catch (Spreadsheet.Services.Parsing.ParserError err) {
                debug ("Error: " + err.message);
            }
        }
    }

    protected override void activate () {
        new_window ();
        setup_shortcuts ();
    }

    private void setup_shortcuts () {
        var back_action = new SimpleAction ("back", null);
        add_action (back_action);
        set_accels_for_action ("app.back", {"<Alt>Home"});
        back_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app") {
                active_window.show_welcome ();
            }
        });

        var new_action = new SimpleAction ("new", null);
        add_action (new_action);
        set_accels_for_action ("app.new", {"<Control>n"});
        new_action.activate.connect (() => {
            new_window ();
        });

        var open_action = new SimpleAction ("open", null);
        add_action (open_action);
        set_accels_for_action ("app.open", {"<Control>o"});
        open_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app") {
                active_window.open_sheet ();
            }
        });

        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});
        quit_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null) {
                active_window.destroy ();
            }
        });

        var save_action = new SimpleAction ("save", null);
        add_action (save_action);
        set_accels_for_action ("app.save", {"<Control>s"});
        save_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app") {
                active_window.save_sheet ();
            }
        });

        var save_as_action = new SimpleAction ("save_as", null);
        add_action (save_as_action);
        set_accels_for_action ("app.save_as", {"<Control><Shift>s"});
        save_as_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app") {
                active_window.save_as_sheet ();
            }
        });

        var undo_action = new SimpleAction ("undo", null);
        add_action (undo_action);
        set_accels_for_action ("app.undo", {"<Control>z"});
        undo_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app" && active_window.history_manager.can_undo ()) {
                active_window.undo_sheet ();
            }
        });

        var redo_action = new SimpleAction ("redo", null);
        add_action (redo_action);
        set_accels_for_action ("app.redo", {"<Control><Shift>z"});
        redo_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app" && active_window.history_manager.can_redo ()) {
                active_window.redo_sheet ();
            }
        });

        var focus_expression_action = new SimpleAction ("focus_expression", null);
        add_action (focus_expression_action);
        set_accels_for_action ("app.focus_expression", {"F2"});
        focus_expression_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app") {
                active_window.expression.grab_focus ();
            }
        });

        var back_focus_action = new SimpleAction ("back_focus", null);
        add_action (back_focus_action);
        set_accels_for_action ("app.back_focus", {"Escape"});
        back_focus_action.activate.connect (() => {
            var active_window = get_windows ().nth_data (0) as MainWindow;
            if (active_window != null && active_window.app_stack.visible_child_name == "app") {
                active_window.active_sheet.grab_focus ();
                active_window.expression.text = "";
            }
        });
    }

    public void new_window () {
        int window_x, window_y, window_width, window_height;
        settings.get ("window-position", "(ii)", out window_x, out window_y);
        settings.get ("window-size", "(ii)", out window_width, out window_height);
        var is_maximized = settings.get_boolean ("is-maximized");

        if (get_windows () != null) {
            window = new MainWindow (this);
            window.move (window_x + 30, window_y + 30);
        } else if (window_x != -1 || window_y != -1) { // Not a first time launch
            window = new MainWindow (this);
            window.move (window_x, window_y);
        } else { // First time launch
            window = new MainWindow (this);
            window.window_position = Gtk.WindowPosition.CENTER;
        }

        if (is_maximized) {
            window.maximize ();
        }

        window.set_default_size (window_width, window_height);
        window.show_all ();
    }
}
