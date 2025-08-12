using Spreadsheet.Models;
using Spreadsheet.Services;

public class Spreadsheet.Services.Formula.AST.CallExpression : Expression {
    public string function { get; construct; }
    public Gee.ArrayList<Expression> parameters { get; construct; }

    public CallExpression (string function, Gee.ArrayList<Expression> parameters) {
        Object (
            function: function,
            parameters: parameters
        );
    }

    public override Value eval (Page sheet) {
        var params = new Value[] {};
        foreach (var param in parameters) {
            params += param.eval (sheet);
        }

        foreach (var func in FunctionManager.get_default ().functions) {
            if (func.name == function) {
                return func.apply (params);
            }
        }

        warning ("Error: can't find any function named %s".printf (function));
        return "Error";
    }
}
