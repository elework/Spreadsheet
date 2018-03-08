public class Spreadsheet.CellStyle : Object {
    public Gdk.RGBA background { get; construct set; }

    public CellStyle () {
        Gdk.RGBA bg = { 255, 255, 255, 255 };
        Object (
            background: bg
        );
    }
}