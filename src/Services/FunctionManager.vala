/*
 * SPDX-License-Identifier: MIT
 * SPDX-FileCopyrightText: 2017-2026 Spreadsheet Developers
 */

public class Spreadsheet.Services.FunctionManager : Object {
    public Gee.ArrayList<Models.Function> functions { get; private set; }
    public Gtk.FilterListModel filter_model { get; private set; }

    public static unowned FunctionManager get_default () {
        if (instance == null) {
            instance = new FunctionManager ();
        }

        return instance;
    }
    private static FunctionManager? instance = null;

    private Gtk.StringFilter func_filter;

    private FunctionManager () {
    }

    construct {
        functions = new Gee.ArrayList<Models.Function> ();

        functions.add (new Models.Function ("sum", Functions.sum, _("Add numbers")));
        functions.add (new Models.Function ("mul", Functions.mul, _("Multiply numbers")));
        functions.add (new Models.Function ("div", Functions.div, _("Divide numbers")));
        functions.add (new Models.Function ("sub", Functions.sub, _("Subtract numbers")));
        functions.add (new Models.Function ("mod", Functions.mod, _("Gives the modulo of numbers")));

        functions.add (new Models.Function ("pow", Functions.pow, _("Elevate a number to the power of a second one")));
        functions.add (new Models.Function ("sqrt", Functions.sqrt, _("The square root of a number")));
        functions.add (new Models.Function ("round", Functions.round, _("Rounds a number to the nearest integer")));
        functions.add (new Models.Function ("floor", Functions.floor, _("Removes the decimal part of a number")));
        functions.add (new Models.Function ("min", Functions.min, _("Return the smallest value")));
        functions.add (new Models.Function ("max", Functions.max, _("Return the biggest value")));
        functions.add (new Models.Function ("mean", Functions.mean, _("Gives the mean of a list of numbers")));

        functions.add (new Models.Function ("cos", Functions.cos, _("Gives the cosine of a number (in radians)")));
        functions.add (new Models.Function ("sin", Functions.sin, _("Gives the sine of an angle (in radians)")));
        functions.add (new Models.Function ("tan", Functions.tan, _("Gives the tangent of a number (in radians)")));
        functions.add (new Models.Function ("arccos", Functions.arccos, _("Gives the arc cosine of a number")));
        functions.add (new Models.Function ("arcsin", Functions.arcsin, _("Gives the arc sine of a number")));
        functions.add (new Models.Function ("arctan", Functions.arctan, _("Gives the arc tangent of a number")));

        var func_name_exp = new Gtk.PropertyExpression (typeof (Models.Function), null, "name");
        var func_doc_exp = new Gtk.PropertyExpression (typeof (Models.Function), null, "doc");

        var func_exp = new Gtk.CClosureExpression (
            typeof (string), null,
            { func_name_exp, func_doc_exp },
            (Callback) create_func_searchterm,
            null, null);

        func_filter = new Gtk.StringFilter (func_exp) {
            ignore_case = true,
            match_mode = Gtk.StringFilterMatchMode.SUBSTRING
        };

        var func_liststore = new ListStore (typeof (Models.Function));
        foreach (var func in functions) {
            func_liststore.append (func);
        }

        filter_model = new Gtk.FilterListModel (func_liststore, func_filter);
    }

    public void filter (string term) {
        func_filter.search = term;
    }

    private static string create_func_searchterm (Models.Function func) {
        return "%s %s".printf (func.name, func.doc);
    }
}
