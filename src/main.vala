using Gee;
using Spreadsheet.UI;

namespace Spreadsheet {

    public class App : Granite.Application {

        public static ArrayList<Function> functions { get; set; default = new ArrayList<Function> (); }

        public static int main (string[] args) {
            Gtk.init (ref args);
            return new App ().run (args);
        }

        construct {
            this.program_name = "Spreadsheet";
            DEBUG = true;
            functions.add (new Function ("sum", Functions.sum, "Add numbers"));
            functions.add (new Function ("mul", Functions.mul, "Multiply numbers"));
            functions.add (new Function ("div", Functions.div, "Divide numbers"));
            functions.add (new Function ("sub", Functions.sub, "Substract numbers"));
            functions.add (new Function ("mod", Functions.mod, "Gives the modulo of numbers"));
        }

        public override void activate () {
            new MainWindow (this).present ();
        }
    }
}
