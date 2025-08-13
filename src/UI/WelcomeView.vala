using Spreadsheet.Models;
using Spreadsheet.Services;

public class Spreadsheet.UI.WelcomeView : Gtk.Box {
    public signal void new_activated ();
    public signal void open_choose_activated ();
    public signal void open_activated (string path);

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

        var recents_manager = RecentsManager.get_default ();

        var recents_listbox = new Gtk.ListBox ();
        recents_listbox.bind_model (recents_manager.recents_liststore, create_recent_row);

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

        recents_manager.recents_liststore.bind_property ("n_items",
            recent_widgets_box, "no_show_all",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _n_items, ref _no_show_all) => {
                _no_show_all = ((uint) _n_items) == 0;
                return true;
            });

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
}
