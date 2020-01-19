public class Spreadsheet.FontStyle : Object {
    public Gdk.RGBA fontcolor { get; set; }
    public bool is_bold { get; set; }
    public bool is_italic { get; set; }
    public bool is_underline { get; set; }
    public bool is_strikethrough { get; set; }

    public FontStyle () {
        reset_color ();
    }

    public void reset_color () {
        fontcolor = { 0, 0, 0, 1 };
    }
}
