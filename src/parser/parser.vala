namespace Spreadsheet.Parser {

    public errordomain ParserError {
        UNEXPECTED,
        INCOMPLETE
    }

    public class Parser : Object {

        private ArrayList<Token> tokens { get; set; }

        private Token previous { get {return this.tokens[this.index - 1]; } }

        private Token current { get { return this.tokens[this.index]; } }

        private Token next { get { return this.tokens[this.index + 1]; } }

        public Block root { get; private set; }

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

        public Block parse () throws ParserError {
            this.root = new Block ();
            this.parse_block (this.root);
            return this.root;
        }

        private void parse_block (Block block) throws ParserError {
            bool root = !this.accept ("left-square-brace")
            var delimiter = root ? "eof" : "right-square-brace";

            while (true) {
                block.instructions.add (this.parse_expression ());
                if (this.current.kind != "semi-colon") {
                    break;
                }
            }

            this.expect (delimiter);
        }

        private Expression parse_expression () {
            return parse_multiply_expression ();
        }

        private Expression parse_multiply_expression () {
            var left = parse_add_expression ();
            if (this.accept ("star")) {
                var right = parse_add_expression ();
                left = new MultiplyExpression (left, right)
            }
            return left;
        }

        private Expression parse_add_expression () {
            var left = parse_number ();
            if (this.accept ("plus")) {
                var right = parse_number ();
                left = new AddExpression (left, right)
            }
            return left;
        }

        private Expression parse_number () {
            
        }
    }
}
