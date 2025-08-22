/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

/**
 * Remembers recently opened files.
 */
public class Spreadsheet.Services.RecentsManager : Object {
    private const int RECENTS_NUM_MAX = 20;

    public static unowned RecentsManager get_default () {
        if (instance == null) {
            instance = new RecentsManager ();
        }

        return instance;
    }
    private static RecentsManager? instance = null;

    public ListStore recents_liststore { get; construct; }

    private RecentsManager () {
    }

    construct {
        recents_liststore = new ListStore (typeof (RecentItem));
        load ();
        sync ();
    }

    private void load () {
        recents_liststore.remove_all ();

        var recents_gsettings = Spreadsheet.App.settings.get_strv ("recent-files");

        int recents_num = int.min (recents_gsettings.length, RECENTS_NUM_MAX);
        for (int i_rev = (recents_num - 1); i_rev >= 0; i_rev--) {
            prepend_internal (recents_gsettings[i_rev]);
        }
    }

    private void sync () {
        var new_recents = new Array<string> ();

        uint recents_num = uint.min (recents_liststore.n_items, RECENTS_NUM_MAX);
        for (uint i = 0; i < recents_num; i++) {
            var obj = ((RecentItem) recents_liststore.get_item (i));
            new_recents.append_val (obj.path);
        }

        Spreadsheet.App.settings.set_strv ("recent-files", new_recents.data);
    }

    private void cut_off (uint preserve_count) {
        for (uint i = preserve_count; i < recents_liststore.n_items; i++) {
            recents_liststore.remove (i);
        }
    }

    private bool prepend_internal (string path) {
        var file = File.new_for_path (path);
        if (!file.query_exists ()) {
            warning ("Invalid path. path=%s", path);
            return false;
        }

        var recent_item = new RecentItem (path);

        uint pos;
        bool dup_exists = recents_liststore.find_with_equal_func (
            recent_item,
            ((a, b) => {
                return ((RecentItem) a).path == ((RecentItem) b).path;
            }),
            out pos
        );
        if (dup_exists) {
            recents_liststore.remove (pos);
        }

        cut_off (RECENTS_NUM_MAX - 1);

        recents_liststore.insert (0, recent_item);

        return true;
    }

    public void prepend (string path) {
        bool ret = prepend_internal (path);
        if (!ret) {
            return;
        }

        sync ();
    }
}
