namespace Spreadsheet.Parser.AST {

    public class NumberExpression : Expression {
        
        private double number { get; set; }

        public NumberExpression (double value) {
            this.number = value;
        }

        public override Value eval () {
            return this.number;
        }
    }
}
