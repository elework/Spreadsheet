using Spreadsheet;
using Spreadsheet.Models;

public class Spreadsheet.Services.Formula.AST.CallExpression : Expression {

    public string function { get; set; }
    public Gee.ArrayList<Expression> parameters { get; set; }

    public CallExpression (string func, Gee.ArrayList<Expression> params) {
        Object (function: func, parameters: params);
    }

    public override Value eval (Page sheet) {
        var params = new Value[] {};
        foreach (var param in parameters) {
            params += param.eval (sheet);
        }

        foreach (var func in App.functions) {
            if (func.name == function) {
                return func.apply (params);
            }
        }
        return "Error: can't find any function named %s".printf (function);
    }
}
