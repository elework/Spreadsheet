using Gee;
using Spreadsheet.Services;
using Spreadsheet.UI;
using Spreadsheet.Models;

public class Spreadsheet.App : Gtk.Application {
    public static GLib.Settings settings;
    public MainWindow window { get; private set; }

    public static ArrayList<Function> functions { get; set; default = new ArrayList<Function> (); }

    public static int main (string[] args) {
        Gtk.init (ref args);
        return new App ().run (args);
    }

    static construct {
        settings = new Settings ("com.github.ryonakano.spreadsheet");
    }

    construct {
        application_id = "com.github.ryonakano.spreadsheet";
        flags = ApplicationFlags.FLAGS_NONE;
        functions.add (new Function ("sum", Functions.sum, _("Add numbers")));
        functions.add (new Function ("mul", Functions.mul, _("Multiply numbers")));
        functions.add (new Function ("div", Functions.div, _("Divide numbers")));
        functions.add (new Function ("sub", Functions.sub, _("Substract numbers")));
        functions.add (new Function ("mod", Functions.mod, _("Gives the modulo of numbers")));

        functions.add (new Function ("pow", Functions.pow, _("Elevate a number to the power of a second one")));
        functions.add (new Function ("sqrt", Functions.sqrt, _("The square root of a number")));
        functions.add (new Function ("round", Functions.round, _("Rounds a number to the nearest integer")));
        functions.add (new Function ("floor", Functions.floor, _("Removes the decimal part of a number")));
        functions.add (new Function ("min", Functions.min, _("Return the smallest value")));
        functions.add (new Function ("max", Functions.max, _("Return the biggest value")));
        functions.add (new Function ("mean", Functions.mean, _("Gives the mean of a list of numbers")));

        functions.add (new Function ("cos", Functions.cos, _("Gives the cosinus of a number (in radians)")));
        functions.add (new Function ("sin", Functions.sin, _("Gives the sinus of an angle (in radians)")));
        functions.add (new Function ("tan", Functions.tan, _("Gives the tangent of a number (in radians)")));
        functions.add (new Function ("arccos", Functions.arccos, _("Gives the arc cosinus of a number")));
        functions.add (new Function ("arcsin", Functions.arcsin, _("Gives the arc sinus of a number")));
        functions.add (new Function ("arctan", Functions.arctan, _("Gives the arg tangent of a number")));
    }

    public override void activate () {
        new_window ();

        var back_action = new SimpleAction ("back", null);
        add_action (back_action);
        set_accels_for_action ("app.back", {"<Alt>Home"});
        back_action.activate.connect (() => {
            window.show_welcome ();
        });

        var open_action = new SimpleAction ("open", null);
        add_action (open_action);
        set_accels_for_action ("app.open", {"<Control>o"});
        open_action.activate.connect (() => {
            if (window != null && window.app_stack.visible_child_name == "app") {
                window.open_sheet ();
            }
        });

        var quit_action = new SimpleAction ("quit", null);
        add_action (quit_action);
        set_accels_for_action ("app.quit", {"<Control>q"});
        quit_action.activate.connect (() => {
            if (window != null) {
                window.destroy ();
            }
        });

        var save_action = new SimpleAction ("save", null);
        add_action (save_action);
        set_accels_for_action ("app.save", {"<Control>s"});
        save_action.activate.connect (() => {
            if (window != null && window.app_stack.visible_child_name == "app") {
                window.save_sheet ();
            }
        });

        var save_as_action = new SimpleAction ("save_as", null);
        add_action (save_as_action);
        set_accels_for_action ("app.save_as", {"<Control><Shift>s"});
        save_as_action.activate.connect (() => {
            if (window != null && window.app_stack.visible_child_name == "app") {
                window.save_as_sheet ();
            }
        });

        var undo_action = new SimpleAction ("undo", null);
        add_action (undo_action);
        set_accels_for_action ("app.undo", {"<Control>z"});
        undo_action.activate.connect (() => {
            if (window != null && window.app_stack.visible_child_name == "app" && HistoryManager.instance.can_undo ()) {
                window.undo_sheet ();
            }
        });

        var redo_action = new SimpleAction ("redo", null);
        add_action (redo_action);
        set_accels_for_action ("app.redo", {"<Control><Shift>z"});
        redo_action.activate.connect (() => {
            if (window != null && window.app_stack.visible_child_name == "app" && HistoryManager.instance.can_redo ()) {
                window.redo_sheet ();
            }
        });

        var focus_expression_action = new SimpleAction ("focus_expression", null);
        add_action (focus_expression_action);
        set_accels_for_action ("app.focus_expression", {"F2"});
        focus_expression_action.activate.connect (() => {
            window.expression.grab_focus ();
        });

        var back_focus_action = new SimpleAction ("back_focus", null);
        add_action (back_focus_action);
        set_accels_for_action ("app.back_focus", {"Escape"});
        back_focus_action.activate.connect (() => {
            window.active_sheet.grab_focus ();
            window.expression.text = "";
        });
    }

    public void new_window () {
        // Fetch window state from GLib.Settings
        var window_x = settings.get_int ("window-x");
        var window_y = settings.get_int ("window-y");
        var window_width = settings.get_int ("window-width");
        var window_height = settings.get_int ("window-height");
        var window_maximized = settings.get_boolean ("window-maximized");

        if (window != null) {
            window = new MainWindow (this);
            window.move (window_x + 30, window_y + 30);
        } else if (window_x != -1 || window_y != -1) { // Not a first time launch
            window = new MainWindow (this);
            window.move (window_x, window_y);

            if (window_maximized) {
                window.maximize ();
            }
        } else { // First time launch
            window = new MainWindow (this);
            window.window_position = Gtk.WindowPosition.CENTER;
        }

        window.set_default_size (window_width, window_height);
        window.show_all ();
    }
}
