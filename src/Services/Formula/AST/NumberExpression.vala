using Spreadsheet.Models;

public class Spreadsheet.Services.Formula.AST.NumberExpression : Expression {

    private double number { get; set; }

    public NumberExpression (double value) {
        this.number = value;
    }

    public override Value eval (Page sheet) {
        return this.number;
    }
}
