using Gee;
using Spreadsheet.Services.Formula.AST;
using Spreadsheet.Services.Parsing;

public class Spreadsheet.Services.Formula.FormulaParser : Parsing.Parser {

    public Expression root { get; private set; }

    public FormulaParser (ArrayList<Token> tokens) {
        base (tokens);
    }

    public Expression parse () throws ParserError {
        return this.parse_block ();
    }

    private Expression parse_block () throws ParserError {
        bool root = !this.accept ("left-square-brace");
        var delimiter = root ? "eof" : "right-square-brace";
        Expression last;

        while (true) {
            last = this.parse_expression ();
            if (this.current.kind == delimiter) {
                break;
            } else {
                this.expect ("semi-colon");
            }
        }

        this.expect (delimiter);
        return last;
    }

    private Expression parse_expression () throws ParserError {
        return this.parse_substraction ();
    }

    private Expression parse_primary_expression () throws ParserError {
        if (this.current.kind == "identifier") {
            return this.parse_call_expression ();
        } else if (this.current.kind == "number") {
            return this.parse_number ();
        } else if (this.accept("left-parenthese")) {
            var res = this.parse_expression ();
            expect ("right-parenthese");
            return res;
        } else if (this.current.kind == "cell-name") {
            return this.parse_cell_name ();
        } else {
            unexpected ();
            return new NumberExpression (0.0);
        }
    }

    private Expression parse_exponent () throws ParserError {
        var left = this.parse_primary_expression ();
        while (this.accept ("carat")) {
            var right = this.parse_primary_expression ();
            left = new CallExpression ("pow", new ArrayList<Expression>.wrap ({ left, right }));
        }
        return left;
    }

    private Expression parse_multiplication () throws ParserError {
        var left = this.parse_exponent ();
        while (this.accept ("star")) {
            var right = this.parse_exponent ();
            left = new CallExpression ("mul", new ArrayList<Expression>.wrap ({ left, right }));
        }
        return left;
    }

    private Expression parse_division () throws ParserError {
        var left = this.parse_multiplication ();
        while (this.accept ("slash")) {
            var right = this.parse_multiplication ();
            left = new CallExpression ("div", new ArrayList<Expression>.wrap ({ left, right }));
        }
        return left;
    }

    private Expression parse_modulo () throws ParserError {
        Expression left = this.parse_division ();
        while (this.accept ("percent")) {
            var right = this.parse_division ();
            left = new CallExpression ("mod", new ArrayList<Expression>.wrap ({ left, right }));
        }
        return left;
    }

    private Expression parse_substraction () throws ParserError {
        var left = this.parse_addition ();
        while (this.accept ("dash")) {
            var right = this.parse_addition ();
            left = new CallExpression ("sub", new ArrayList<Expression>.wrap ({ left, right }));
        }
        return left;
    }

    private Expression parse_addition () throws ParserError {
        var left = this.parse_modulo ();
        while (this.accept ("plus")) {
            var right = this.parse_modulo ();
            left = new CallExpression ("sum", new ArrayList<Expression>.wrap ({ left, right }));
        }
        return left;
    }

    private CallExpression parse_call_expression () throws ParserError {
        var func = this.current.lexeme;
        expect ("identifier");
        expect ("left-parenthese");
        var params = new ArrayList<Expression> ();
        while (true) {
            params.add (this.parse_expression ());

            if (this.accept ("right-parenthese")) {
                break;
            }

            if (!this.accept ("comma")) {
                throw new ParserError.UNEXPECTED ("Use a comma to separate parameters");
            }
        }
        return new CallExpression (func, params);
    }

    private NumberExpression parse_number () throws ParserError {
        want ("number");
        NumberExpression res;
        if ("." in this.current.lexeme) {
            res = new NumberExpression (double.parse (this.current.lexeme));
        } else {
            res = new NumberExpression (double.parse (this.current.lexeme + ".0"));
        }
        eat ();
        return res;
    }

    private CellReference parse_cell_name () throws ParserError {
        var cell = new CellReference () { cell_name = this.current.lexeme };
        expect ("cell-name");
        return cell;
    }
}

