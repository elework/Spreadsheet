using Gtk;
using Spreadsheet.Models;

namespace Spreadsheet.Widgets {

    public class FunctionPresenter : EventBox {

        public Function function { get; set; }

        public FunctionPresenter (Function func) {
            var box = new Box (Orientation.VERTICAL, 5);
            this.function = func;

            var name_label = new Label (this.function.name);
            name_label.justify = Justification.LEFT;
            name_label.halign = Align.START;
            box.pack_start (name_label);

            var doc_label = new Label (this.function.doc);
            doc_label.justify = Justification.FILL;
            doc_label.halign = Align.START;
            doc_label.use_markup = true;
            doc_label.sensitive = false;
            box.pack_start (doc_label);

            this.add (box);
        }
    }
}
