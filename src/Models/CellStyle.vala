public class Spreadsheet.CellStyle : Object {
    public const Gdk.RGBA BG_COLOR_DEFAULT = { 1, 1, 1, 1 };

    public const Gdk.RGBA STROKE_COLOR_DEFAULT = { 0, 0, 0, 1 };

    public const double STROKE_WIDTH_MIN = 0.1;
    public const double STROKE_WIDTH_MAX = 3.0;
    public const double STROKE_WIDTH_DEFAULT = 1.0;
    public const double STROKE_WIDTH_STEP = 0.1;

    public Gdk.RGBA bg_color { get; private set; }
    public Gdk.RGBA stroke_color { get; private set; }
    public double stroke_width { get; private set; }

    public CellStyle () {
        Object (
            bg_color: BG_COLOR_DEFAULT,
            stroke_color: STROKE_COLOR_DEFAULT,
            stroke_width: STROKE_WIDTH_DEFAULT
        );
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
