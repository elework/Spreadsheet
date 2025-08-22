/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;
using Spreadsheet.Services;
using Spreadsheet.Widgets;

public class Spreadsheet.UI.WelcomeView : Gtk.Box {
    public signal void new_activated ();
    public signal void open_choose_activated ();
    public signal void open_activated (string path);

    public WelcomeView () {
    }

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;
        spacing = 0;

        var welcome = new Granite.Placeholder (_("Spreadsheet")) {
            description = _("Start something new, or continue what you have been working on.")
        };
        var new_button = welcome.append_button (new ThemedIcon ("document-new"), _("New Sheet"), _("Create an empty sheet"));
        var open_button = welcome.append_button (new ThemedIcon ("document-open"), _("Open File"), _("Choose a saved file"));

        var recent_title = new Gtk.Label (_("Recent files")) {
            halign = Gtk.Align.CENTER,
            margin_top = 24,
            margin_bottom = 24,
            margin_start = 24,
            margin_end = 24
        };
        recent_title.add_css_class (Granite.STYLE_CLASS_H2_LABEL);

        var recents_manager = RecentsManager.get_default ();

        var recents_selection_model = new Gtk.NoSelection (recents_manager.recents_liststore);

        var recents_factory = new Gtk.SignalListItemFactory ();
        recents_factory.setup.connect (recents_setup);
        recents_factory.bind.connect (recents_bind);

        var recents_list = new Gtk.ListView (recents_selection_model, recents_factory) {
            single_click_activate = true
        };

        var recent_scrolled = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            hexpand = true,
            vexpand = true,
            child = recents_list
        };

        var recent_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        recent_box.append (recent_title);
        recent_box.append (recent_scrolled);

        var recent_widgets_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        recent_widgets_box.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        recent_widgets_box.append (recent_box);

        recents_manager.recents_liststore.bind_property ("n_items",
            recent_widgets_box, "visible",
            BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE,
            (binding, _n_items, ref _visible) => {
                _visible = ((uint) _n_items) > 0;
                return true;
            });

        new_button.clicked.connect (() => {
            new_activated ();
        });
        open_button.clicked.connect (() => {
            open_choose_activated ();
        });

        recents_list.activate.connect ((pos) => {
            var recent_item = recents_manager.recents_liststore.get_item (pos) as RecentItem;
            open_activated (recent_item.path);
        });

        add_css_class (Granite.STYLE_CLASS_VIEW);
        append (welcome);
        append (recent_widgets_box);
    }

    private void recents_setup (Object obj) {
        var list_item = obj as Gtk.ListItem;

        var row = new IconLabelRow ();
        list_item.child = row;
    }

    private void recents_bind (Object obj) {
        var list_item = obj as Gtk.ListItem;

        var recent_item = list_item.item as RecentItem;
        var path = recent_item.path;

        string basename = Path.get_basename (path);
        string display_path = path;
        if (Environment.get_home_dir () in path) {
            display_path = path.replace (Environment.get_home_dir (), "~");
        }

        var row = list_item.child as IconLabelRow;
        row.icon_name = "x-office-spreadsheet";
        row.primary_text = basename;
        row.secondary_text = display_path;
    }
}
