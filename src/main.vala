using Gee;
using Spreadsheet.UI;
using Spreadsheet.Functions;

namespace Spreadsheet {

    public class App : Granite.Application {

        public ArrayList<Function> functions { get; set; }

        public static int main (string[] args) {
            Gtk.init (ref args);
            return new App ().run (args);
        }

        construct {
            this.program_name = "Spreadsheet";
            DEBUG = true;
            this.functions = new ArrayList<Function> ();
            var sum_func = new Function ("name", sum, "Add numbers");
            this.functions.add (sum_func);
        }

        public override void activate () {
            new MainWindow (this).present ();
        }
    }
}
