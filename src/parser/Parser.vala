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

        private bool accept (string category) {
            if (this.current.kind == category) {
                this.eat ();
                return true;
            }
            return false;
        }

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

        public CallExpression parse () throws ParserError {
            return this.parse_block ();
        }

        private CallExpression parse_block () throws ParserError {
            bool root = !this.accept ("left-square-brace");
            var delimiter = root ? "eof" : "right-square-brace";
            CallExpression last;

            while (true) {
                last = this.parse_call_expression ();
                if (this.current.kind == delimiter) {
                    break;
                } else {
                    this.expect ("semi-colon");
                }
            }

            this.expect (delimiter);
            return last;
        }

        private CallExpression parse_call_expression () throws ParserError {
            var func = this.current.lexeme;
            expect ("identifier");
            expect ("left-parenthese");
            var params = new ArrayList<Expression> ();
            while (!this.accept ("right-parenthese")) {
                if (this.current.kind == "identifier") {
                    params.add (this.parse_call_expression ());
                } else if (this.current.kind == "number") {
                    params.add (this.parse_number ());
                } else if (!(this.accept ("comma") || this.accept ("right-parenthese"))) {
                    throw new ParserError.UNEXPECTED ("Expected a function name or a number, got %s".printf (this.current.kind));
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
