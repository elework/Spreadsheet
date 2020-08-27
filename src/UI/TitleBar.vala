public class Spreadsheet.UI.TitleBar : Gtk.HeaderBar {
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
        var file_ico = new Gtk.Image.from_icon_name ("window-new", Gtk.IconSize.SMALL_TOOLBAR);
        var file_button = new Gtk.ToolButton (file_ico, null);
        file_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>N"}, _("Open another window"));
        file_button.clicked.connect (() => {
            ((Spreadsheet.App) GLib.Application.get_default ()).new_window ();
        });
        pack_start (file_button);

        var open_ico = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_ico, null);
        open_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>O"}, _("Open a file"));
        open_button.clicked.connect (() => {
            window.open_sheet ();
        });
        pack_start (open_button);

        var save_as_ico = new Gtk.Image.from_icon_name ("document-save-as", Gtk.IconSize.SMALL_TOOLBAR);
        var save_as_button = new Gtk.ToolButton (save_as_ico, null);
        save_as_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>S"}, _("Save this file with a different name"));
        save_as_button.clicked.connect (() => {
            window.save_as_sheet ();
        });
        pack_start (save_as_button);

        var redo_ico = new Gtk.Image.from_icon_name ("edit-redo", Gtk.IconSize.SMALL_TOOLBAR);
        redo_button = new Gtk.ToolButton (redo_ico, null);
        redo_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl><Shift>Z"}, _("Redo"));
        redo_button.clicked.connect (() => {
            window.redo_sheet ();
        });
        pack_end (redo_button);

        var undo_ico = new Gtk.Image.from_icon_name ("edit-undo", Gtk.IconSize.SMALL_TOOLBAR);
        undo_button = new Gtk.ToolButton (undo_ico, null);
        undo_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>Z"}, _("Undo"));
        undo_button.clicked.connect (() => {
            window.undo_sheet ();
        });
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
