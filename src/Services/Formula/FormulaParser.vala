/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Services.Formula.FormulaParser : Parsing.Parser {
    public FormulaParser (Gee.ArrayList<Parsing.Token> tokens) {
        base (tokens);
    }

    public AST.Expression parse () throws Parsing.ParserError {
        return parse_block ();
    }

    private AST.Expression parse_block () throws Parsing.ParserError {
        bool root = !accept ("left-square-brace");
        var delimiter = root ? "eof" : "right-square-brace";

        AST.Expression last;
        while (true) {
            last = parse_expression ();

            if (current.kind == delimiter) {
                break;
            }
        }

        expect (delimiter);
        return last;
    }

    private AST.Expression parse_expression () throws Parsing.ParserError {
        return parse_substraction ();
    }

    private AST.Expression parse_primary_expression () throws Parsing.ParserError {
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
            return new AST.NumberExpression (0.0);
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

    private AST.Expression parse_exponent () throws Parsing.ParserError {
        var left = parse_primary_expression ();

        while (accept ("carat")) {
            var right = parse_primary_expression ();
            left = new AST.CallExpression ("pow", new Gee.ArrayList<AST.Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private AST.Expression parse_multiplication () throws Parsing.ParserError {
        var left = parse_exponent ();

        while (accept ("star")) {
            var right = parse_exponent ();
            left = new AST.CallExpression ("mul", new Gee.ArrayList<AST.Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private AST.Expression parse_division () throws Parsing.ParserError {
        var left = parse_multiplication ();

        while (accept ("slash")) {
            var right = parse_multiplication ();
            left = new AST.CallExpression ("div", new Gee.ArrayList<AST.Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private AST.Expression parse_modulo () throws Parsing.ParserError {
        AST.Expression left = parse_division ();

        while (accept ("percent")) {
            var right = parse_division ();
            left = new AST.CallExpression ("mod", new Gee.ArrayList<AST.Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private AST.Expression parse_substraction () throws Parsing.ParserError {
        var left = parse_addition ();

        while (accept ("dash")) {
            var right = parse_addition ();
            left = new AST.CallExpression ("sub", new Gee.ArrayList<AST.Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private AST.Expression parse_addition () throws Parsing.ParserError {
        var left = parse_modulo ();

        while (accept ("plus")) {
            var right = parse_modulo ();
            left = new AST.CallExpression ("sum", new Gee.ArrayList<AST.Expression>.wrap ({ left, right }));
        }

        return left;
    }

    private AST.CallExpression parse_call_expression () throws Parsing.ParserError {
        var func = current.lexeme;
        expect ("identifier");
        expect ("left-parenthese");

        var params = new Gee.ArrayList<AST.Expression> ();
        while (true) {
            params.add (parse_expression ());

            if (accept ("right-parenthese")) {
                break;
            }

            if (!accept ("comma")) {
                throw new Parsing.ParserError.UNEXPECTED ("Use a comma to separate parameters");
            }
        }

        return new AST.CallExpression (func, params);
    }

    private AST.NumberExpression parse_number () throws Parsing.ParserError {
        want ("number");

        AST.NumberExpression res;
        if ("." in current.lexeme) {
            res = new AST.NumberExpression (double.parse (current.lexeme));
        } else {
            res = new AST.NumberExpression (double.parse (current.lexeme + ".0"));
        }

        eat ();
        return res;
    }

    private AST.TextExpression parse_text () throws Parsing.ParserError {
        string val = "";

        while (current.kind != "eof") {
            val += current.lexeme;
            eat ();
        }

        return new AST.TextExpression (val);
    }

    private AST.CellReference parse_cell_name () throws Parsing.ParserError {
        var cell = new AST.CellReference () { cell_name = current.lexeme };
        expect ("cell-name");
        return cell;
    }
}
