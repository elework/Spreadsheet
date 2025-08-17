/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Services.CSV;
using Spreadsheet.Services.Parsing;
using Spreadsheet.UI;

public class Spreadsheet.App : Gtk.Application {
    public static GLib.Settings settings { get; private set; }

    public const string ACTION_PREFIX = "app.";
    public const string ACTION_NAME_NEW = "new";
    private const string ACTION_NAME_QUIT = "quit";

    public const string[] ACTION_ACCELS_NEW = { "<Control>n", null };
    private const string[] ACTION_ACCELS_QUIT = { "<Control>q", null };

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
        set_accels_for_action (ACTION_PREFIX + ACTION_NAME_NEW, ACTION_ACCELS_NEW);
        set_accels_for_action (ACTION_PREFIX + ACTION_NAME_QUIT, ACTION_ACCELS_QUIT);
    }

    protected override void open (File[] csv_files, string hint) {
        foreach (var csv_file in csv_files) {
            var window = new_window ();
            var path = csv_file.get_path ();

            window.open_sheet (path);
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

    private MainWindow new_window () {
        var window = new MainWindow (this);
        window.present ();

        /*
         * Don't bind Settings to windows because state change in one window
         * affects all of other windows.
         */
        window.maximized =  App.settings.get_boolean ("is-maximized");
        window.default_width = App.settings.get_int ("window-width");
        window.default_height = App.settings.get_int ("window-height");

        App.settings.bind ("is-maximized", window, "maximized", SettingsBindFlags.SET);
        App.settings.bind ("window-width", window, "default_width", SettingsBindFlags.SET);
        App.settings.bind ("window-height", window, "default_height", SettingsBindFlags.SET);

        return window;
    }
}
