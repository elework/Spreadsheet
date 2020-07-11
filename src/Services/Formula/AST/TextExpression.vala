using Spreadsheet.Models;

public class Spreadsheet.Services.Formula.AST.TextExpression : Expression {
    public string text { get; construct; }

    public TextExpression (string value) {
        Object (
            text: value,
            expression_type: ExpressionType.STRING
        );
    }

    public override Value eval (Page sheet) {
        return text;
    }
}
