using Gee;
using Spreadsheet.UI;
using Spreadsheet.Models;

public class Spreadsheet.App : Gtk.Application {
    public static GLib.Settings settings;
    public MainWindow window;

    public static ArrayList<Function> functions { get; set; default = new ArrayList<Function> (); }

    public static int main (string[] args) {
        Gtk.init (ref args);
        return new App ().run (args);
    }

    static construct {
        settings = new Settings ("xyz.gelez.spreadsheet");
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
        var window_x = settings.get_int ("window-x");
        var window_y = settings.get_int ("window-y");
        var window_width = settings.get_int ("window-width");
        var window_height = settings.get_int ("window-height");
        var window_maximized = settings.get_int ("window-maximized");

        if (window_x != -1 || window_y != -1) {
            window = new MainWindow.with_state (this, window_x, window_y, window_width, window_height);
        } else {
            window = new MainWindow (this, window_width, window_height);
        }
    }
}
