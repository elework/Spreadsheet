using Gee;

/**
* Generates identifier using the alphabet and an index.
*
* 0 -> A
* 1 -> B
* ...
* 25 -> Z
* 26 -> AA
* 27 -> AB
* ...
* 701 -> ZZ
* 702 -> AAA
* 703 -> AAB
*/
public class Spreadsheet.AlphabetGenerator : Object {

    private const string[] ALPHABET = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                                        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" };

    public uint limit { get; construct set; }
    public uint index { get; construct set; }

    public AlphabetGenerator (uint limit = 26, uint start_at = 0) requires (limit > start_at) {
        Object (limit: limit, index: start_at);
    }

    public AlphabetGenerator iterator () {
        return this;
    }

    public int index_of (string letters) {
        int res = 0;
        int i = 0;
        foreach (char letter in letters.to_utf8 ()) {
            int power = letters.length - i;
            int index_in_alphabet = new ArrayList<string>.wrap (ALPHABET).index_of (letter.to_string ());
            res += (int)Math.pow (index_in_alphabet, power);
            i++;
        }
        return res;
    }

    public string get_at (uint index) {
        if (index >= ALPHABET.length) {
            return get_at ((index / ALPHABET.length) - 1) + get_at (index % ALPHABET.length);
        } else {
            return ALPHABET[index];
        }
    }

    public new string get () {
        var res = get_at (index);
        index++;
        return res;
    }

    public bool next () {
        return index < limit;
    }
}
