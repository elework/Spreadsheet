namespace Spreadsheet.Services.Parsing {

    public class Token {

        public string kind;
        public string lexeme;
        public Token (string? k, string l) {
            this.kind = k;
            this.lexeme = l;
        }
    }
}
