public class Spreadsheet.CellStyle : Object {
    public Gdk.RGBA background { get; construct set; }
    public Gdk.RGBA stroke { get; construct set; }
    public double stroke_width { get; construct set; }

    public CellStyle () {
        Gdk.RGBA bg = { 255, 255, 255, 0 };
        Gdk.RGBA sr = { 0, 0, 0, 0 };
        double sr_w = 0.5;
        Object (
            background: bg,
            stroke: sr,
            stroke_width: sr_w
        );
    }

    public void bg_remove () {
        background = { 255, 255, 255, 0 };
    }

    public void sr_remove () {
        stroke = { 0, 0, 0, 0 };
    }
}
