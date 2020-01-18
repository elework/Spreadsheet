public class Spreadsheet.CellStyle : Object {
    public Gdk.RGBA background { get; set; }
    public Gdk.RGBA stroke { get; set; }
    public double stroke_width { get; set; default = 1.0; }

    public CellStyle () {
        reset_background_color ();
        reset_stroke_color ();
    }

    public void reset_background_color () {
        background = { 1, 1, 1, 1 };
    }

    public void reset_stroke_color () {
        stroke = { 0, 0, 0, 1 };
    }
}
