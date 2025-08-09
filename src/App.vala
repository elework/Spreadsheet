using Spreadsheet.Services;
using Spreadsheet.UI;

public class Spreadsheet.App : Gtk.Application {
    public static GLib.Settings settings;
    private MainWindow window;

    private const string ACTION_PREFIX = "app.";
    private const string ACTION_NAME_NEW = "new";
    private const string ACTION_NAME_QUIT = "quit";

    private const GLib.ActionEntry[] ACTION_ENTRIES = {
        { ACTION_NAME_NEW, on_new_activate },
        { ACTION_NAME_QUIT, on_quit_activate },
    };

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

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action (ACTION_PREFIX + ACTION_NAME_NEW, { "<Control>n" });
        set_accels_for_action (ACTION_PREFIX + ACTION_NAME_QUIT, { "<Control>q" });
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

    private void on_new_activate () {
        new_window ();
    }

    private void on_quit_activate () {
        if (active_window == null) {
            return;
        }

        active_window.destroy ();
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
