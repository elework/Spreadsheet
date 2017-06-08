using Spreadsheet.Models;

namespace Spreadsheet.Services.Formula.AST {

    public class NumberExpression : Expression {

        private double number { get; set; }

        public NumberExpression (double value) {
            this.number = value;
        }

        public override Value eval (Page sheet) {
            return this.number;
        }
    }
}
