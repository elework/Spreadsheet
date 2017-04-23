using Gee;
using Spreadsheet.UI;
using Spreadsheet.Functions;

namespace Spreadsheet {

    public class App : Granite.Application {

        public static ArrayList<Function> functions { get; set; }

        public static int main (string[] args) {
            Gtk.init (ref args);
            return new App ().run (args);
        }

        construct {
            this.program_name = "Spreadsheet";
            DEBUG = true;
            functions = new ArrayList<Function> ();
            var sum_func = new Function ("sum", sum, "Add numbers");
            functions.add (sum_func);
        }

        public override void activate () {
            new MainWindow (this).present ();
        }
    }
}
