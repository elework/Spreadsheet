/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

namespace Spreadsheet.Functions {
    public Value cos (Value[] args) {
        return Math.cos (number (args[0]));
    }

    public Value sin (Value[] args) {
        return Math.sin (number (args[0]));
    }

    public Value tan (Value[] args) {
        return Math.tan (number (args[0]));
    }

    public Value arccos (Value[] args) {
        return Math.acos (number (args[0]));
    }

    public Value arcsin (Value[] args) {
        return Math.asin (number (args[0]));
    }

    public Value arctan (Value[] args) {
        return Math.atan (number (args[0]));
    }
}
