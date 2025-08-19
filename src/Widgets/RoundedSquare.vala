/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

public class Spreadsheet.Widgets.RoundedSquare : Gtk.DrawingArea {
    public Gdk.RGBA color { get; construct; }
    public int width { get; construct; }
    public int height { get; construct; }
    public int radius { get; construct; }

    public RoundedSquare (Gdk.RGBA color, int width, int height, int radius) {
        Object (
            color: color,
            width: width,
            height: height,
            radius: radius
        );
    }

    construct {
        set_size_request (width, height);
    }

    protected override bool draw (Cairo.Context cr) {
        Gdk.cairo_set_source_rgba (cr, color);
        Util.draw_rounded_path (cr, 0, 0, width, height, radius);
        cr.fill ();

        return true;
    }
}
