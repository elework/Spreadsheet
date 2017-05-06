using Gee;

namespace Spreadsheet.Services.Parsing {

    public errordomain ParserError {
        UNEXPECTED,
        INCOMPLETE
    }

    public abstract class Parser : Object {

        protected ArrayList<Token> tokens { get; set; }

        protected int index = 0;

        protected Token previous { owned get {return this.tokens[this.index - 1]; } }

        protected Token current { owned get { return this.tokens[this.index]; } }

        protected Token next { owned get { return this.tokens[this.index + 1]; } }

        public Parser (ArrayList<Token> tokens) {
            this.tokens = tokens;
        }

        protected void eat () {
            this.index++;
        }

        /**
        * Eat the current token if it is from a certain type
        *
        * @return true if the token has been eaten.
        */
        protected bool accept (string category) {
            if (this.current.kind == category) {
                this.eat ();
                return true;
            }
            return false;
        }

        /**
        * If the current token is not of a specific type, throws an error.
        */
        protected bool expect (string cat) throws ParserError {
            if (this.accept (cat)) {
                return true;
            }
            throw new ParserError.UNEXPECTED (@"Expected a '$cat', got a '$(this.current.kind)'");
        }

        // Like expect, but doesn't eat the token.
        protected bool want (string cat) throws ParserError {
            if (this.current.kind == cat) {
                return true;
            }
            throw new ParserError.UNEXPECTED (@"Wanted a '$cat', got a '$(this.current.kind)'");
        }

        protected void unexpected () throws ParserError {
            throw new ParserError.UNEXPECTED (@"Unexpected '$(this.current.kind)'");
        }
    }
}
