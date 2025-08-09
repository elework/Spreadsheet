using Spreadsheet.Services;
using Spreadsheet.UI;

public class Spreadsheet.App : Gtk.Application {
    public static GLib.Settings settings;
    private MainWindow window;

    public static int main (string[] args) {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);

        var app = new App ();
        return app.run (args);
    }

    static construct {
        settings = new Settings ("io.github.elework.spreadsheet");
    }

    construct {
        application_id = "io.github.elework.spreadsheet";
        flags = ApplicationFlags.HANDLES_OPEN;
    }

    protected override void startup () {
        base.startup ();

        // Follow OS-wide dark preference
        unowned var granite_settings = Granite.Settings.get_default ();
        unowned var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.bind_property ("prefers-color-scheme", gtk_settings, "gtk-application-prefer-dark-theme",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, granite_prop, ref gtk_prop) => {
                gtk_prop = (Granite.Settings.ColorScheme) granite_prop == Granite.Settings.ColorScheme.DARK;
                return true;
            }
        );

        setup_shortcuts ();
    }

    protected override void open (File[] csv_files, string hint) {
        foreach (var csv_file in csv_files) {
            new_window ();

            try {
                var file = new Spreadsheet.Services.CSV.CSVParser.from_file (csv_file.get_path ()).parse ();
                window.file = file;
                window.header.set_buttons_visibility (true);
                window.show_all ();
                window.app_stack.set_visible_child_name ("app");
            } catch (Spreadsheet.Services.Parsing.ParserError err) {
                debug ("Error: " + err.message);
            }
        }
    }

    protected override void activate () {
        new_window ();
    }

    private void setup_shortcuts () {
        var new_action = new SimpleAction ("new", null);
        add_action (new_action);
        set_accels_for_action ("app.new", {"<Control>n"});
        new_action.activate.connect (() => {
            new_window ();
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
