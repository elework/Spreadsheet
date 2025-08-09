using Gtk;
using Spreadsheet.Models;

public class Spreadsheet.Widgets.FunctionListRow : EventBox {
    public Function function { get; set; }

    public FunctionListRow (Function func) {
        var box = new Box (Orientation.VERTICAL, 0);
        function = func;

        var name_label = new Label (function.name);
        name_label.justify = Justification.LEFT;
        name_label.halign = Align.START;
        box.pack_start (name_label);

        var doc_label = new Label (function.doc);
        doc_label.justify = Justification.FILL;
        doc_label.halign = Align.START;
        doc_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        box.pack_start (doc_label);

        add (box);
    }
}
