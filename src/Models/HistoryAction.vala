using Gee;
using Gtk;

public class Spreadsheet.Models.StateChange<G> {
    public StateChange (G before, G after) {
        this.before = before;
        this.after = after;
    }

    public G before;
    public G after;
}

/**
* A recorded action that can be done, undone, and done again.
*/
public class Spreadsheet.Models.HistoryAction<G, H> : Object {
    public delegate StateChange DoFunc<G> (G data, Object target);
    public delegate void UndoFunc<G> (G data, Object target);

    public DoFunc<G> run { get; set; }
    public UndoFunc<G> undo { get; set; }
    public string description { get; set; }

    /**
    * The model or widget modified by this action
    */
    public Object target { get; set; }

    public StateChange<G> changes;

    public HistoryAction (string desc, Object target, owned DoFunc<G> run, owned UndoFunc<G> undo) {
        this.description = desc;
        this.target = target;
        this.run = (owned) run;
        this.undo = (owned) undo;
    }
}

