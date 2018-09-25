public class Spreadsheet.FontStyle : Object {
    public Gdk.RGBA fontcolor { get; construct set; }

    public FontStyle () {
        Gdk.RGBA color = { 0, 0, 0, 1 };
        Object (
            fontcolor: color
        );
    }
}
