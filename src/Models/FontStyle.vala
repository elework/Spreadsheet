public class Spreadsheet.FontStyle : Object {
    public Gdk.RGBA fontcolor { get; set; }
    public bool is_bold { get; set; }
    public bool is_italic { get; set; }
    public bool is_underline { get; set; }
    public bool is_strikethrough { get; set; }

    public FontStyle () {
        fontcolor = { 0, 0, 0, 1 };
    }

    public void color_remove () {
        fontcolor = { 0, 0, 0, 1 };
    }
}
