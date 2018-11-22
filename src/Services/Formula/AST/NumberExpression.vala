using Spreadsheet.Models;

public class Spreadsheet.Services.Formula.AST.NumberExpression : Expression {

    private double number { get; set; }

    public NumberExpression (double value) {
        number = value;
    }

    public override Value eval (Page sheet) {
        return number;
    }
}
