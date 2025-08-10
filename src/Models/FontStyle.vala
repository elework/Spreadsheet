public class Spreadsheet.FontStyle : Object {
    public const Gdk.RGBA FONT_COLOR_DEFAULT = { 0, 0, 0, 1 };

    public Gdk.RGBA font_color { get; set; }
    public bool is_bold { get; set; }
    public bool is_italic { get; set; }
    public bool is_underline { get; set; }
    public bool is_strikethrough { get; set; }

    public FontStyle () {
        reset_color ();
    }

    public void reset_color () {
        font_color = FONT_COLOR_DEFAULT;
    }
}
