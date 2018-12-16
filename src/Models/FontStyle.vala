public class Spreadsheet.FontStyle : Object {
    public Gdk.RGBA fontcolor { get; construct set; }
    public int fontsize { get; construct set; }
    public bool is_bold { get; construct set; }
    public bool is_italic { get; construct set; }
    public bool is_underline { get; construct set; }
    public bool is_strikethrough { get; construct set; }

    public FontStyle () {
        Gdk.RGBA color = { 0, 0, 0, 1 };
        int size = 15;
        bool is_bold = false;
        bool is_italic = false;
        bool is_underline = false;
        bool is_strikethrough = false;
        Object (
            fontcolor: color,
            fontsize: size,
            is_bold: is_bold,
            is_italic: is_italic,
            is_underline: is_underline,
            is_strikethrough: is_strikethrough
        );
    }

    public void color_remove () {
        fontcolor = { 0, 0, 0, 1 };
    }
}
