/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2025 Spreadsheet Developers
 */

using Spreadsheet.Models;

public class Spreadsheet.Services.FunctionManager : Object {
    public Gee.ArrayList<Function> functions { get; private set; }

    public static unowned FunctionManager get_default () {
        if (instance == null) {
            instance = new FunctionManager ();
        }

        return instance;
    }
    private static FunctionManager? instance = null;

    private FunctionManager () {
        functions = new Gee.ArrayList<Function> ();

        functions.add (new Function ("sum", Functions.sum, _("Add numbers")));
        functions.add (new Function ("mul", Functions.mul, _("Multiply numbers")));
        functions.add (new Function ("div", Functions.div, _("Divide numbers")));
        functions.add (new Function ("sub", Functions.sub, _("Subtract numbers")));
        functions.add (new Function ("mod", Functions.mod, _("Gives the modulo of numbers")));

        functions.add (new Function ("pow", Functions.pow, _("Elevate a number to the power of a second one")));
        functions.add (new Function ("sqrt", Functions.sqrt, _("The square root of a number")));
        functions.add (new Function ("round", Functions.round, _("Rounds a number to the nearest integer")));
        functions.add (new Function ("floor", Functions.floor, _("Removes the decimal part of a number")));
        functions.add (new Function ("min", Functions.min, _("Return the smallest value")));
        functions.add (new Function ("max", Functions.max, _("Return the biggest value")));
        functions.add (new Function ("mean", Functions.mean, _("Gives the mean of a list of numbers")));

        functions.add (new Function ("cos", Functions.cos, _("Gives the cosine of a number (in radians)")));
        functions.add (new Function ("sin", Functions.sin, _("Gives the sine of an angle (in radians)")));
        functions.add (new Function ("tan", Functions.tan, _("Gives the tangent of a number (in radians)")));
        functions.add (new Function ("arccos", Functions.arccos, _("Gives the arc cosine of a number")));
        functions.add (new Function ("arcsin", Functions.arcsin, _("Gives the arc sine of a number")));
        functions.add (new Function ("arctan", Functions.arctan, _("Gives the arc tangent of a number")));
    }
}
