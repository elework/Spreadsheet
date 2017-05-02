using Gee;
using Spreadsheet.Parser.AST;

namespace Spreadsheet.Parser {

    public errordomain ParserError {
        UNEXPECTED,
        INCOMPLETE
    }

    public class Parser : Object {

        private ArrayList<Token> tokens { get; set; }

        private int index = 0;

        private Token previous { owned get {return this.tokens[this.index - 1]; } }

        private Token current { owned get { return this.tokens[this.index]; } }

        private Token next { owned get { return this.tokens[this.index + 1]; } }

        public Expression root { get; private set; }

        public Parser (ArrayList<Token> tokens) {
            this.tokens = tokens;
        }

        private void eat () {
            this.index++;
        }

        /**
        * Eat the current token if it is from a certain type
        *
        * @return true if the token has been eaten.
        */
        private bool accept (string category) {
            if (this.current.kind == category) {
                this.eat ();
                return true;
            }
            return false;
        }

        /**
        * If the current token is not of a specific type, throws an error.
        */
        private bool expect (string cat) throws ParserError {
            if (this.accept (cat)) {
                return true;
            }
            throw new ParserError.UNEXPECTED (@"Expected a '$cat', got a '$(this.current.kind)'");
        }

        // Like expect, but doesn't eat the token.
        private bool want (string cat) throws ParserError {
            if (this.current.kind == cat) {
                return true;
            }
            throw new ParserError.UNEXPECTED (@"Wanted a '$cat', got a '$(this.current.kind)'");
        }

        private void unexpected () throws ParserError {
            throw new ParserError.UNEXPECTED (@"Unexpected '$(this.current.kind)'");
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
            } else {
                unexpected ();
                return new NumberExpression (0.0);
            }
        }

        private Expression parse_exponent () throws ParserError {
            var left = this.parse_primary_expression ();
            if (this.accept ("carat")) {
                var right = this.parse_primary_expression ();
                left = new CallExpression ("pow", new ArrayList<Expression>.wrap ({ left, right }));
            }
            return left;
        }

        private Expression parse_multiplication () throws ParserError {
            var left = this.parse_exponent ();
            if (this.accept ("star")) {
                var right = this.parse_exponent ();
                left = new CallExpression ("mul", new ArrayList<Expression>.wrap ({ left, right }));
            }
            return left;
        }

        private Expression parse_division () throws ParserError {
            var left = this.parse_multiplication ();
            if (this.accept ("slash")) {
                var right = this.parse_multiplication ();
                left = new CallExpression ("div", new ArrayList<Expression>.wrap ({ left, right }));
            }
            return left;
        }

        private Expression parse_modulo () throws ParserError {
            Expression left = this.parse_division ();
            if (this.accept ("percent")) {
                var right = this.parse_division ();
                left = new CallExpression ("mod", new ArrayList<Expression>.wrap ({ left, right }));
            }
            return left;
        }

        private Expression parse_substraction () throws ParserError {
            var left = this.parse_addition ();
            if (this.accept ("dash")) {
                var right = this.parse_addition ();
                left = new CallExpression ("sub", new ArrayList<Expression>.wrap ({ left, right }));
            }
            return left;
        }

        private Expression parse_addition () throws ParserError {
            var left = this.parse_modulo ();
            if (this.accept ("plus")) {
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
    }
}
