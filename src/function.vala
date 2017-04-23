namespace Spreadsheet {

    public class Function : Object {

        public Function (string name, owned ApplyFunc func, string doc = "No documentation") {
            this.name = name;
            this.apply = (owned) func;
            this.doc = doc;
        }

        public string name { get; set; }

        public string doc { get; set; }

        public ApplyFunc apply { get; set; }
    }

    [CCode (has_target = false)]
    public delegate Value ApplyFunc (Value[] args);
}
