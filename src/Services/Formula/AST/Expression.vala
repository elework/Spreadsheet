using Spreadsheet.Models;

namespace Spreadsheet.Services.Formula.AST {

    public abstract class Expression : Object {

        public abstract Value eval (Page sheet);
    }
}
