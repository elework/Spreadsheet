public class Spreadsheet.CellStyle : Object {
    public const Gdk.RGBA BG_COLOR_DEFAULT = { 1, 1, 1, 1 };

    public const Gdk.RGBA STROKE_COLOR_DEFAULT = { 0, 0, 0, 1 };

    public const double STROKE_WIDTH_MIN = 0.1;
    public const double STROKE_WIDTH_MAX = 3.0;
    public const double STROKE_WIDTH_DEFAULT = 1.0;
    public const double STROKE_WIDTH_STEP = 0.1;

    public Gdk.RGBA bg_color { get; set; }
    public Gdk.RGBA stroke_color { get; set; }
    public double stroke_width { get; set; }

    public CellStyle () {
        reset_background_color ();
        reset_stroke_color ();
        reset_stroke_width ();
    }

    public void reset_background_color () {
        bg_color = BG_COLOR_DEFAULT;
    }

    public void reset_stroke_color () {
        stroke_color = STROKE_COLOR_DEFAULT;
    }

    public void reset_stroke_width () {
        stroke_width = STROKE_WIDTH_DEFAULT;
    }
}
