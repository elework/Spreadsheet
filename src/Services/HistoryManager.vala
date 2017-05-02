using Spreadsheet.Models;

namespace Spreadsheet.Services {

    public class HistoryManager : Object {

        private const int HISTORY_LIMIT = 20; // TODO: make it configurable?

        public static HistoryManager instance {
            owned get {
                if (HistoryManager._instance == null) {
                    HistoryManager._instance = new HistoryManager ();
                }

                return HistoryManager._instance;
            }
        }
        private static HistoryManager _instance;

        public Queue<HistoryAction> undo_history = new Queue<HistoryAction> ();
        public Queue<HistoryAction> redo_history = new Queue<HistoryAction> ();

        public bool can_undo () {
            return !this.undo_history.is_empty ();
        }

        public bool can_redo () {
            return !this.redo_history.is_empty ();
        }

        public void do_action (HistoryAction act) {
            this.redo_history.clear ();

            this.undo_history.push_head (act);
            act.changes = act.run (null, act.target);

            if (this.undo_history.get_length () > HISTORY_LIMIT) {
                this.undo_history.pop_tail ();
            }
        }

        public void undo () {
            var act = this.undo_history.pop_head ();
            act.undo (act.changes.before, act.target);
            this.redo_history.push_head (act);

            if (this.redo_history.get_length () > HISTORY_LIMIT) {
                this.redo_history.pop_tail ();
            }
        }

        public void redo () {
            var act = this.redo_history.pop_head ();
            this.undo_history.push_head (act);
            act.run (act.changes.after, act.target);

            if (this.undo_history.get_length () > HISTORY_LIMIT) {
                this.undo_history.pop_tail ();
            }
        }
    }
}
