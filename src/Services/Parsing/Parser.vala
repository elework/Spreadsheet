using Gee;

public errordomain Spreadsheet.Services.Parsing.ParserError {
    UNEXPECTED,
    INCOMPLETE
}

public abstract class Spreadsheet.Services.Parsing.Parser : Object {

    protected ArrayList<Token> tokens { get; set; }

    protected int index = 0;

    protected Token previous { owned get {return tokens[index - 1]; } }

    protected Token current { owned get { return tokens[index]; } }

    protected Token next { owned get { return tokens[index + 1]; } }

    protected Parser (ArrayList<Token> tokens) {
       Object (tokens: tokens);
    }

    protected void eat () {
        index++;
    }

    /**
    * Eat the current token if it is from a certain type
    *
    * @return true if the token has been eaten.
    */
    protected bool accept (string category) {
        if (current.kind == category) {
            eat ();
            return true;
        }
        return false;
    }

    /**
    * If the current token is not of a specific type, throws an error.
    */
    protected bool expect (string cat) throws ParserError {
        if (accept (cat)) {
            return true;
        }
        throw new ParserError.UNEXPECTED (@"Expected a '$cat', got a '$(current.kind)'");
    }

    // Like expect, but doesn't eat the token.
    protected bool want (string cat) throws ParserError {
        if (current.kind == cat) {
            return true;
        }
        throw new ParserError.UNEXPECTED (@"Wanted a '$cat', got a '$(current.kind)'");
    }

    protected void unexpected () throws ParserError {
        throw new ParserError.UNEXPECTED (@"Unexpected '$(current.kind)'");
    }
}
