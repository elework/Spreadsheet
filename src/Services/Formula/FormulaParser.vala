using Spreadsheet.Services.Formula.AST;
using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.Formula.FormulaParser : Parsing.Parser {
    public FormulaParser (Gee.ArrayList<Token> tokens) {
        base (tokens);
    }

    public Expression parse () throws ParserError {
        return parse_block ();
    }

    private Expression parse_block () throws ParserError {
        bool root = !accept ("left-square-brace");
        var delimiter = root ? "eof" : "right-square-brace";

        Expression last;
        while (true) {
            last = parse_expression ();

            if (current.kind == delimiter) {
                break;
            }
        }

        expect (delimiter);
        return last;
    }

    private Expression parse_expression () throws ParserError {
        return parse_substraction ();
    }

    private Expression parse_primary_expression () throws ParserError {
        if (current.kind == "equal") {
            accept ("equal");

            if (current.kind == "identifier") {
                return parse_call_expression ();
            }

            if (current.kind == "number") {
                return parse_number ();
            }

            if (accept ("left-parenthese")) {
                var res = parse_expression ();
                expect ("right-parenthese");
                return res;
            }

            if (current.kind == "cell-name") {
                return parse_cell_name ();
            }

            unexpected ();
            return new NumberExpression (0.0);
        }

        if (current.kind == "number") {
            if (next.kind == "text") {
                return parse_text ();
            }

            return parse_number ();
        }

        if (current.kind == "cell-name") {
            if (index > 0) {
                return parse_cell_name ();
            }

            /*
             * Do not consider as cell-name like other spreadsheet apps
             * if cell-name appears as the first token.
             */
            return parse_text ();
        }

        return parse_text ();
    }

    private Expression parse_exponent () throws ParserError {
        var left = parse_primary_expression ();

        while (accept ("carat")) {
            var right = parse_primary_expression ();
            left = new CallExpression ("pow", new Gee.ArrayList<Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private Expression parse_multiplication () throws ParserError {
        var left = parse_exponent ();

        while (accept ("star")) {
            var right = parse_exponent ();
            left = new CallExpression ("mul", new Gee.ArrayList<Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private Expression parse_division () throws ParserError {
        var left = parse_multiplication ();

        while (accept ("slash")) {
            var right = parse_multiplication ();
            left = new CallExpression ("div", new Gee.ArrayList<Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private Expression parse_modulo () throws ParserError {
        Expression left = parse_division ();

        while (accept ("percent")) {
            var right = parse_division ();
            left = new CallExpression ("mod", new Gee.ArrayList<Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private Expression parse_substraction () throws ParserError {
        var left = parse_addition ();

        while (accept ("dash")) {
            var right = parse_addition ();
            left = new CallExpression ("sub", new Gee.ArrayList<Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private Expression parse_addition () throws ParserError {
        var left = parse_modulo ();

        while (accept ("plus")) {
            var right = parse_modulo ();
            left = new CallExpression ("sum", new Gee.ArrayList<Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private CallExpression parse_call_expression () throws ParserError {
        var func = current.lexeme;
        expect ("identifier");
        expect ("left-parenthese");

        var params = new Gee.ArrayList<Expression> ();
        while (true) {
            params.add (parse_expression ());

            if (accept ("right-parenthese")) {
                break;
            }

            if (!accept ("comma")) {
                throw new ParserError.UNEXPECTED ("Use a comma to separate parameters");
            }
        }

        return new CallExpression (func, params);
    }

    private NumberExpression parse_number () throws ParserError {
        want ("number");

        NumberExpression res;
        if ("." in current.lexeme) {
            res = new NumberExpression (double.parse (current.lexeme));
        } else {
            res = new NumberExpression (double.parse (current.lexeme + ".0"));
        }

        eat ();
        return res;
    }

    private TextExpression parse_text () throws ParserError {
        string val = "";

        while (current.kind != "eof") {
            val += current.lexeme;
            eat ();
        }

        return new TextExpression (val);
    }

    private CellReference parse_cell_name () throws ParserError {
        var cell = new CellReference () { cell_name = current.lexeme };
        expect ("cell-name");
        return cell;
    }
}
