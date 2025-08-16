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
        var new_button = welcome.append_button (Icon.new_for_string ("document-new"), _("New Sheet"), _("Create an empty sheet"));
        var open_button = welcome.append_button (Icon.new_for_string ("document-open"), _("Open File"), _("Choose a saved file"));

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

        var recent_scrolled = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            halign = Gtk.Align.CENTER,
            child = recents_listbox
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

        recents_listbox.row_activated.connect ((row) => {
            open_activated (((IconLabelRow) row).secondary_text);
        });

        get_style_context ().add_class (Granite.STYLE_CLASS_VIEW);
        append (welcome);
        append (recent_widgets_box);
    }

    private Gtk.Widget create_recent_row (Object item) {
        var path_obj = (StringObject) item;
        var path = path_obj.string;

        string basename = Path.get_basename (path);
        string display_path = path;
        if (GLib.Environment.get_home_dir () in path) {
            display_path = path.replace (GLib.Environment.get_home_dir (), "~");
        }

        return new IconLabelRow ("x-office-spreadsheet", basename, display_path);
    }
}
