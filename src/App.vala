using Gee;
using Spreadsheet.Services;
using Spreadsheet.UI;
using Spreadsheet.Models;

public class Spreadsheet.App : Gtk.Application {

    MainWindow window;

    public static ArrayList<Function> functions { get; set; default = new ArrayList<Function> (); }

    public static int main (string[] args) {
        Gtk.init (ref args);
        return new App ().run (args);
    }

    construct {
        application_id = "xyz.gelez.spreadsheet";
        flags = ApplicationFlags.FLAGS_NONE;
        functions.add (new Function ("sum", Functions.sum, "Add numbers"));
        functions.add (new Function ("mul", Functions.mul, "Multiply numbers"));
        functions.add (new Function ("div", Functions.div, "Divide numbers"));
        functions.add (new Function ("sub", Functions.sub, "Substract numbers"));
        functions.add (new Function ("mod", Functions.mod, "Gives the modulo of numbers"));

        functions.add (new Function ("pow", Functions.pow, "Elevate a number to the power of a second one"));
        functions.add (new Function ("sqrt", Functions.sqrt, "The square root of a number"));
        functions.add (new Function ("round", Functions.round, "Rounds a number to the nearest integer"));
        functions.add (new Function ("floor", Functions.floor, "Removes the decimal part of a number"));
        functions.add (new Function ("min", Functions.min, "Return the smallest value"));
        functions.add (new Function ("max", Functions.max, "Return the biggest value"));
        functions.add (new Function ("mean", Functions.mean, "Gives the mean of a list of numbers"));

        functions.add (new Function ("cos", Functions.cos, "Gives the cosinus of a number (in radians)"));
        functions.add (new Function ("sin", Functions.sin, "Gives the sinus of an angle (in radians)"));
        functions.add (new Function ("tan", Functions.tan, "Gives the tangent of a number (in radians)"));
        functions.add (new Function ("arccos", Functions.arccos, "Gives the arc cosinus of a number"));
        functions.add (new Function ("arcsin", Functions.arcsin, "Gives the arc sinus of a number"));
        functions.add (new Function ("arctan", Functions.arctan, "Gives the arg tangent of a number"));
    }

    public override void activate () {
        window = new MainWindow (this);
        window.present ();

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

        var save_action = new SimpleAction ("save", null);
        add_action (save_action);
        set_accels_for_action ("app.save", {"<Control>s"});
        save_action.activate.connect (() => {
            if (window != null && window.app_stack.visible_child_name == "app") {
                window.save_sheet ();
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
}
