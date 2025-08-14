/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.UI;

public class Spreadsheet.Widgets.TitleBar : Gtk.HeaderBar {
    public MainWindow window { get; construct; }

    private Gtk.ToolButton undo_button;
    private Gtk.ToolButton redo_button;

    public TitleBar (MainWindow window) {
        Object (
            window: window,
            show_close_button: true
        );
    }

    construct {
        var new_window_icon = new Gtk.Image.from_icon_name ("window-new", Gtk.IconSize.SMALL_TOOLBAR);
        var new_window_button = new Gtk.ToolButton (new_window_icon, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>N" }, _("Open another window")),
            action_name = App.ACTION_PREFIX + App.ACTION_NAME_NEW
        };

        var open_icon = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_icon, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>O" }, _("Open a file")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_OPEN
        };

        var save_as_icon = new Gtk.Image.from_icon_name ("document-save-as", Gtk.IconSize.SMALL_TOOLBAR);
        var save_as_button = new Gtk.ToolButton (save_as_icon, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl><Shift>S" }, _("Save this file with a different name")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_SAVE_AS
        };

        var redo_icon = new Gtk.Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
        redo_button = new Gtk.ToolButton (redo_icon, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl><Shift>Z" }, _("Redo")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_REDO
        };

        var undo_icon = new Gtk.Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
        undo_button = new Gtk.ToolButton (undo_icon, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({ "<Ctrl>Z" }, _("Undo")),
            action_name = MainWindow.ACTION_PREFIX + MainWindow.ACTION_NAME_UNDO
        };

        pack_start (new_window_button);
        pack_start (open_button);
        pack_start (save_as_button);
        pack_end (redo_button);
        pack_end (undo_button);

        set_buttons_visibility (false);
        update_header ();
    }

    public void set_buttons_visibility (bool is_visible) {
        foreach (var button in get_children ()) {
            button.visible = is_visible;
            button.no_show_all = !is_visible;
        }
    }

    public void update_header () {
        undo_button.sensitive = window.history_manager.can_undo ();
        redo_button.sensitive = window.history_manager.can_redo ();
    }

    public void set_titles (string title, string? subtitle) {
        this.title = title;
        this.subtitle = subtitle;
    }
}
