using Spreadsheet.Models;

public class Spreadsheet.Services.Formula.AST.TextExpression : Expression {
    public string text { get; construct; }

    public TextExpression (string text) {
        Object (
            text: text
        );
    }

    public override Value eval (Page sheet) {
        return text;
    }
}
