/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

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
        Object (
            limit: limit,
            index: start_at
        );
    }

    public AlphabetGenerator iterator () {
        return this;
    }

    public int index_of (string letters) {
        int res = 0;
        int i = 1;

        /*
         * Regard the alphabets as base-26 numeral system that only use alphabets.
         *
         * e.g. ABC
         * = (26^2 * (<index of A> + 1)) + (26^1 * (<index of B> + 1)) + (26^0 * <index of C>)
         * = (26^2 * 1) + (26^1 * 2) + (26^0 * 2)
         * = 730
         *
         * See the below comment for detail of "index + 1"
         */
        foreach (char letter in letters.to_utf8 ()) {
            int exponent = letters.length - i;
            int index_in_alphabet = new Gee.ArrayList<string>.wrap (ALPHABET).index_of (letter.to_string ());

            /*
             * The base-26 numeral system that only use alphabets should be like this in theory:
             *
             *   A, B, ..., Z, BA, BB, ...
             *   (A instead of 0, B instead of 1, and so on)
             *
             * However, we expect like this:
             *
             *   A, B, ..., Z, AA, AB, ..., AZ, BA, BB, ...
             *                 ~~~~~~~~~~~~~~~
             *
             * This can be achieved by treating index_in_alphabet as count instead of index:
             *
             *   * 26^0 place: treat as index (A instead of 0, B instead of 1, and so on)
             *   * 26^n place (n > 0): treat as count (A instead of 1, B instead of 2, and so on)
             */
            if (exponent > 0) {
                index_in_alphabet = index_in_alphabet + 1;
            }

            int place_res = (int)Math.pow (ALPHABET.length, exponent) * index_in_alphabet;
            res += place_res;
            i++;
        }

        return res;
    }

    public string get_at (uint index) {
        if (index >= ALPHABET.length) {
            return get_at ((index / ALPHABET.length) - 1) + get_at (index % ALPHABET.length);
        }

        return ALPHABET[index];
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
