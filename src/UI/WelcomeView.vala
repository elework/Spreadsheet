public class Spreadsheet.UI.WelcomeView : Gtk.Box {
    public signal void new_activated ();
    public signal void open_choose_activated ();
    public signal void open_activated (string path);

    private Gtk.ListBox recent_list;

    public WelcomeView () {
    }

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 0;

        var welcome = new Granite.Widgets.Welcome (
            _("Spreadsheet"),
            _("Start something new, or continue what you have been working on.")
        );
        welcome.append ("document-new", _("New Sheet"), _("Create an empty sheet"));
        welcome.append ("document-open", _("Open File"), _("Choose a saved file"));
        welcome.activated.connect ((index) => {
            if (index == 0) {
                new_activated ();
            } else if (index == 1) {
                open_choose_activated ();
            }
        });

        var recent_title = new Gtk.Label (_("Recent files")) {
            halign = Gtk.Align.CENTER,
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 24,
            margin_end = 24
        };
        recent_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        recent_list = new Gtk.ListBox ();

        var recent_scrolled = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            halign = Gtk.Align.CENTER
        };
        recent_scrolled.add (recent_list);

        var recent_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        recent_box.pack_start (recent_title, false, false);
        recent_box.pack_start (recent_scrolled);

        var recent_widgets_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        recent_widgets_box.pack_start (new Gtk.Separator (Gtk.Orientation.VERTICAL), false);
        recent_widgets_box.pack_start (recent_box);

        Spreadsheet.App.settings.bind_with_mapping ("recent-files",
            recent_widgets_box, "no_show_all",
            SettingsBindFlags.GET,
            (_no_show_all, _recent_files, user_data) => {
                _no_show_all = ((string[]) _recent_files).length <= 0;
                return true;
            },
            (SettingsBindSetMappingShared) null,
            null, null);

        update_listview ();

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        pack_start (welcome);
        pack_start (recent_widgets_box);
    }

    public void add_recents (string recent_file_path) {
        var recents = Spreadsheet.App.settings.get_strv ("recent-files");

        const int MAX_FILE_COUNT = 20;

        /* Create a new array, append the most recent one at the start, and
           then store all of the previous recent files except the most
           recent one. */
        var new_recents = new Array<string> ();
        new_recents.insert_val (0, recent_file_path);

        foreach (var recent in recents) {
            if (new_recents.length >= MAX_FILE_COUNT) {
                break;
            }

            if (recent != recent_file_path) {
                new_recents.append_val (recent);
            }
        }

        Spreadsheet.App.settings.set_strv ("recent-files", new_recents.data);
        update_listview ();
    }

    private void update_listview () {
        foreach (var item in recent_list.get_children ()) {
            item.destroy ();
        }

        var recent_files = Spreadsheet.App.settings.get_strv ("recent-files");
        string[]? new_recent_files = null;

        foreach (var file_name in recent_files) {
            var file = File.new_for_path (file_name);
            if (file.query_exists ()) {
                var basename = file.get_basename ();
                var path = file.get_path ();
                string display_path = path;
                if (GLib.Environment.get_home_dir () in path) {
                    display_path = path.replace (GLib.Environment.get_home_dir (), "~");
                }

                // IconSize.DIALOG because it's 48px, just like WelcomeButton needs
                var spreadsheet_icon = new Gtk.Image.from_icon_name ("x-office-spreadsheet", Gtk.IconSize.DIALOG);

                var list_item = new Granite.Widgets.WelcomeButton (spreadsheet_icon, basename, display_path);
                list_item.clicked.connect (() => {
                    open_activated (path);
                });
                new_recent_files += file_name;
                recent_list.add (list_item);
            } else {
                /* In case the file doesn't exist, display a list item, but
                   mark the file as missing? */
            }
        }

        Spreadsheet.App.settings.set_strv ("recent-files", new_recent_files);
    }
}
