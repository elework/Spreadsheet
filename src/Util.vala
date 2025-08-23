/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

namespace Spreadsheet.Util {
    public const string FILE_SUFFIX = ".csv";

    // From http://stackoverflow.com/questions/4183546/how-can-i-draw-image-with-rounded-corners-in-cairo-gtk
    public static void draw_rounded_path (Cairo.Context ctx, double x, double y, double width, double height, double radius) {
        double degrees = Math.PI / 180.0;

        ctx.new_sub_path ();
        ctx.arc (x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees);
        ctx.arc (x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees);
        ctx.arc (x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees);
        ctx.arc (x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
        ctx.close_path ();
    }

    public static string keyval_to_utf8 (uint keyval) {
        var unicode = ((unichar) Gdk.keyval_to_unicode (keyval));

        // HACK: I wish if Vala binding for g_unichar_to_utf8() would be separated like
        //     public string to_utf8 ()
        //     public int compute_utf8_len ()
        // instead of
        //     public int to_utf8 (string? outbuf)
        char input_text[6];
        unicode.to_utf8 ((string ?) input_text);

        return (string) input_text;
    }
}
