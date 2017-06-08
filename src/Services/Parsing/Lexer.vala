using Gee;

namespace Spreadsheet.Services.Parsing {

    public class Lexer : Object {

        public Grammar grammar { get; set; }

        public Lexer (Grammar g) {
            this.grammar = g;
        }

        public ArrayList<Token?> tokenize (string _expr) {
            string expr = _expr.strip ();
            var res = new ArrayList<Token?> ();
            var stack = new ArrayList<string> ();
            stack.add ("root");

            while (expr.length > 0) { // we consume all the expression
                var top = stack.last ();
                if (this.grammar.rules.has_key (top)) { // we check if the context exists, but it should normally always be true.
                    bool matched = false;
                    foreach (var eval in this.grammar.rules[top]) { // we try to find a matching pattern in the context
                        int size;
                        var tok = eval.eval (expr, out size);
                        if (size > 0) { // it's a match!

                            if (tok.kind != "[[ignore]]") {
                                res.add (tok);
                            }

                            if (eval.pop) {
                                stack.remove (top);
                            }

                            if (eval.push != null) {
                                stack.add_all (new ArrayList<string>.wrap (eval.push));
                            }

                            expr = expr.substring (size);
                            matched = true;
                            break;
                        }
                    }

                    if (!matched) {
                        debug (expr);
                        error ("Unexpected character at %d", _expr.strip ().length - expr.length);
                    }
                } else {
                    critical ("Unknown context: %s\n", top);
                }
            }

            res.add (new Token ("eof", ""));
            return res;
        }
    }
}
