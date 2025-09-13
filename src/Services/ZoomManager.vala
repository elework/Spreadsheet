/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Services.ZoomManager : Object {
    public const int ZOOM_LEVEL_MIN = 10;
    public const int ZOOM_LEVEL_MAX = 400;
    public const int ZOOM_LEVEL_STEP = 10;
    public const int ZOOM_LEVEL_DEFAULT = 100;

    public int zoom_level { get; set; }

    public static unowned ZoomManager get_default () {
        if (instance == null) {
            instance = new ZoomManager ();
        }

        return instance;
    }
    private static ZoomManager? instance = null;

    private ZoomManager () {
    }

    construct {
        App.settings.bind ("zoom-level", this, "zoom_level", SettingsBindFlags.DEFAULT);
    }

    public void zoom_out () {
        int level = zoom_level - ZOOM_LEVEL_STEP;
        if (level < ZOOM_LEVEL_MIN) {
            return;
        }

        zoom_level = level;
    }

    public void zoom_in () {
        int level = zoom_level + ZOOM_LEVEL_STEP;
        if (level > ZOOM_LEVEL_MAX) {
            return;
        }

        zoom_level = level;
    }

    public void zoom_reset () {
        zoom_level = ZOOM_LEVEL_DEFAULT;
    }
}
