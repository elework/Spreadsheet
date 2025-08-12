public class Spreadsheet.UI.WelcomeView : Gtk.Box {
    public signal void new_activated ();
    public signal void open_choose_activated ();
    public signal void open_activated (string path);

    private const int RECENTS_NUM_MAX = 20;

    private class StringObject : Object {
        public string string { get; construct; }

        public StringObject (string str) {
            Object (
                string: str
            );
        }
    }

    private ListStore recents_liststore;
    private Gtk.ListBox recents_listbox;

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

        // TODO: Replace with Gtk.StringList after porting to GTK 4
        recents_liststore = new ListStore (typeof (StringObject));
        recents_init (recents_liststore);
        recents_sync (recents_liststore);

        recents_listbox = new Gtk.ListBox ();
        recents_listbox.bind_model (recents_liststore, create_recent_row);

        var recent_scrolled = new Gtk.ScrolledWindow (null, null) {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            halign = Gtk.Align.CENTER
        };
        recent_scrolled.add (recents_listbox);

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

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);
        pack_start (welcome);
        pack_start (recent_widgets_box);
    }

    private Gtk.Widget create_recent_row (Object item) {
        var path_obj = (StringObject) item;
        var path = path_obj.string;

        string basename = Path.get_basename (path);
        string display_path = path;
        if (GLib.Environment.get_home_dir () in path) {
            display_path = path.replace (GLib.Environment.get_home_dir (), "~");
        }

        // IconSize.DIALOG because it's 48px, just like WelcomeButton needs
        var spreadsheet_icon = new Gtk.Image.from_icon_name ("x-office-spreadsheet", Gtk.IconSize.DIALOG);

        var recent_row = new Granite.Widgets.WelcomeButton (spreadsheet_icon, basename, display_path);
        recent_row.clicked.connect (() => {
            open_activated (path);
        });

        return recent_row;
    }

    private void recents_init (ListStore recents) {
        recents.remove_all ();

        var recents_gsettings = Spreadsheet.App.settings.get_strv ("recent-files");

        int recents_num = int.min (recents_gsettings.length, RECENTS_NUM_MAX);
        for (int i_rev = (recents_num - 1); i_rev >= 0; i_rev--) {
            add_recents_internal (recents, recents_gsettings[i_rev]);
        }
    }

    private void recents_sync (ListStore recents) {
        var new_recents = new Array<string> ();

        int recents_num = int.min (((int) recents.n_items), RECENTS_NUM_MAX);
        for (int i = 0; i < recents_num; i++) {
            var obj = ((StringObject) recents.get_item (i));
            new_recents.append_val (obj.string);
        }

        Spreadsheet.App.settings.set_strv ("recent-files", new_recents.data);
    }

    private void recents_cut_off (ListStore recents, uint preserve_count) {
        for (uint i = preserve_count; i < recents.n_items; i++) {
            recents.remove (i);
        }
    }

    private bool add_recents_internal (ListStore recents, string path) {
        var file = File.new_for_path (path);
        if (!file.query_exists ()) {
            warning ("Invalid path. path=%s", path);
            return false;
        }

        var path_obj = new StringObject (path);

        uint pos;
        bool dup_exists = recents.find_with_equal_func (
            path_obj,
            ((a, b) => {
                return ((StringObject) a).string == ((StringObject) b).string;
            }),
            out pos
        );
        if (dup_exists) {
            recents.remove (pos);
        }

        recents_cut_off (recents, (RECENTS_NUM_MAX - 1));

        recents.insert (0, path_obj);

        return true;
    }

    public void add_recents (string path) {
        bool ret = add_recents_internal (recents_liststore, path);
        if (!ret) {
            return;
        }

        recents_sync (recents_liststore);
    }
}
