using Spreadsheet.Models;

public abstract class Spreadsheet.Services.Formula.AST.Expression : Object {
    public enum ExpressionType {
        NUMBER,
        STRING
    }

    public ExpressionType expression_type { get; construct; default = ExpressionType.NUMBER; }
    public abstract Value eval (Page sheet);
}
