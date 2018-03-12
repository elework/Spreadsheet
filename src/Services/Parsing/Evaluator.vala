
public delegate Spreadsheet.Services.Parsing.Token Evaluation (string match);

public class Spreadsheet.Services.Parsing.Evaluator : Object {

    public Evaluation evaluation { get; owned set; }

    public Regex pattern { get; set; }

    public bool pop { get; set; }

    public string[] push { get; set; }

    public Evaluator (Value _re, owned Evaluation eval, bool pop = false, string[] push = {}) {
        Regex re = /./;
        if (_re.type () == typeof (string)) {
            try {
                re = new Regex ((string) _re);
            } catch (Error err) {
                assert_not_reached ();
            }
        } else if (_re.type () == typeof (Regex)) {
            re = (Regex) _re;
        } else {
            error ("_re should be a Regex or a string.");
        }

        pattern = re;
        evaluation = (owned) eval;
        pop = pop;
        push = push;
    }

    public Token eval (string expr, out int size) {
        MatchInfo info;
        if (pattern.match (expr, RegexMatchFlags.ANCHORED, out info)) {
            size = info.fetch (0).length;
            return evaluation (info.fetch (0));
        }
        size = 0;
        return new Token ("[[error]]", "oops");
    }
}

