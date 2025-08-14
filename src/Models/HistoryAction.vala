/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Models.StateChange<G> : Object {
    public G before;
    public G after;

    public StateChange (G before, G after) {
        this.before = before;
        this.after = after;
    }
}

/**
* A recorded action that can be done, undone, and done again.
*/
public class Spreadsheet.Models.HistoryAction<G, H> : Object {
    public delegate StateChange DoFunc<G> (G data, Object target);
    public delegate void UndoFunc<G> (G data, Object target);

    public DoFunc<G> run;
    public UndoFunc<G> undo;
    public string description { get; set; }

    /**
    * The model or widget modified by this action
    */
    public Object target { get; set; }

    public StateChange<G> changes;

    public HistoryAction (string desc, Object target, owned DoFunc<G> run, owned UndoFunc<G> undo) {
        Object (
            description: desc,
            target: target
        );
        this.run = (owned) run;
        this.undo = (owned) undo;
    }
}
