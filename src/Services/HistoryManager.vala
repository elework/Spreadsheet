/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Services.HistoryManager : Object {

    private const int HISTORY_LIMIT = 20; // TODO: make it configurable?

    public Queue<HistoryAction> undo_history = new Queue<HistoryAction> ();
    public Queue<HistoryAction> redo_history = new Queue<HistoryAction> ();

    public bool can_undo () {
        return !undo_history.is_empty ();
    }

    public bool can_redo () {
        return !redo_history.is_empty ();
    }

    public void do_action (HistoryAction act) {
        redo_history.clear ();

        undo_history.push_head (act);
        act.changes = act.run (null, act.target);

        if (undo_history.get_length () > HISTORY_LIMIT) {
            undo_history.pop_tail ();
        }
    }

    public void undo () {
        var act = undo_history.pop_head ();
        act.undo (act.changes.before, act.target);
        redo_history.push_head (act);

        if (redo_history.get_length () > HISTORY_LIMIT) {
            redo_history.pop_tail ();
        }
    }

    public void redo () {
        var act = redo_history.pop_head ();
        undo_history.push_head (act);
        act.run (act.changes.after, act.target);

        if (undo_history.get_length () > HISTORY_LIMIT) {
            undo_history.pop_tail ();
        }
    }
}
