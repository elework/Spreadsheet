using Spreadsheet.Models;

public abstract class Spreadsheet.Services.Formula.AST.Expression : Object {
    public abstract Value eval (Page sheet);
}
