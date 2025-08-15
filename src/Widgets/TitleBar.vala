/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.UI;

public class Spreadsheet.Widgets.TitleBar : Gtk.HeaderBar {
    public MainWindow window { get; construct; }

    private Gtk.Button undo_button;
    private Gtk.Button redo_button;

    public TitleBar (MainWindow window) {
        Object (
            window: window,
            show_close_button: true
        );
    }

    construct {
        var new_window_button = new Gtk.Button.from_icon_name ("window-new", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_markup = Granite.markup_accel_tooltip (App.ACTION_ACCELS_NEW, _("Open another window")),
            action_name = App.ACTION_PREFIX + App.ACTION_NAME_NEW
        };

        var open_button = new Gtk.Button.from_icon_name ("document-open", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_OPEN, _("Open a file")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_OPEN
        };

        var save_as_button = new Gtk.Button.from_icon_name ("document-save-as", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_SAVE_AS, _("Save this file with a different name")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_SAVE_AS
        };

        redo_button = new Gtk.Button.from_icon_name ("edit-redo", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_REDO, _("Redo")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_REDO
        };

        undo_button = new Gtk.Button.from_icon_name ("edit-undo", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_markup = Granite.markup_accel_tooltip (MainWindow.ACTION_ACCELS_UNDO, _("Undo")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_UNDO
        };

        pack_start (new_window_button);
        pack_start (open_button);
        pack_start (save_as_button);
        pack_end (redo_button);
        pack_end (undo_button);

        set_buttons_visibility (false);
    }

    public void set_buttons_visibility (bool is_visible) {
        foreach (var button in get_children ()) {
            button.visible = is_visible;
            button.no_show_all = !is_visible;
        }
    }

    public void update_header () {
        bool can_undo = window.history_manager.can_undo ();
        undo_button.sensitive = can_undo;
        ((SimpleAction) window.lookup_action (MainWindow.ACTION_NAME_UNDO)).set_enabled (can_undo);

        bool can_redo = window.history_manager.can_redo ();
        redo_button.sensitive = can_redo;
        ((SimpleAction) window.lookup_action (MainWindow.ACTION_NAME_REDO)).set_enabled (can_redo);
    }

    public void set_titles (string title, string? subtitle) {
        this.title = title;
        this.subtitle = subtitle;
    }
}
