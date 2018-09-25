public class Spreadsheet.CellStyle : Object {
    public Gdk.RGBA background { get; construct set; }
    public Gdk.RGBA stroke { get; construct set; }
    public double stroke_width { get; construct set; }

    public CellStyle () {
        Gdk.RGBA bg = { 255, 255, 255, 1 };
        Gdk.RGBA sr = { 200, 200, 200, 1 };
        double sr_w = 0.5;
        Object (
            background: bg,
            stroke: sr,
            stroke_width: sr_w
        );
    }
}
