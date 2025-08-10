namespace Spreadsheet.Functions {
    private double number (Value num) {
        Type num_type = num.type ();

        // Can't use switch-case because results of typeof() is not constant

        if (num_type == typeof (int)) {
            return (double) num.get_int ();
        }

        if (num_type == typeof (double)) {
            return (double) num;
        }

        if (num_type == typeof (string)) {
            return double.parse ((string) num);
        }

        return 0.0;
    }

    public Value sum (Value[] args) {
        double res = number (args[0]);

        foreach (Value num in args[1:args.length]) {
            res += number (num);
        }

        return res;
    }

    public Value sub (Value[] args) {
        double res = number (args[0]);

        foreach (Value num in args[1:args.length]) {
            res -= number (num);
        }

        return res;
    }

    public Value mul (Value[] args) {
        double res = number (args[0]);

        foreach (Value num in args[1:args.length]) {
            res *= number (num);
        }

        return res;
    }

    public Value div (Value[] args) {
        double res = number (args[0]);

        foreach (Value num in args[1:args.length]) {
            res /= number (num);
        }

        return res;
    }

    public Value mod (Value[] args) {
        double res = number (args[0]);

        foreach (Value num in args[1:args.length]) {
            res %= number (num);
        }

        return res;
    }

    public Value pow (Value[] args) {
        return Math.pow (number (args[0]), number (args[1]));
    }

    public Value sqrt (Value[] args) {
        return Math.sqrt (number (args[0]));
    }

    public Value round (Value[] args) {
        return Math.round (number (args[0]));
    }

    public Value floor (Value[] args) {
        return Math.floor (number (args[0]));
    }

    public Value min (Value[] args) {
        double min = number (args[0]);

        foreach (var arg in args) {
            double num = number (arg);

            if (num < min) {
                min = num;
            }
        }

        return min;
    }

    public Value max (Value[] args) {
        double max = number (args[0]);

        foreach (var arg in args) {
            double num = number (arg);

            if (num > max) {
                max = num;
            }
        }

        return max;
    }

    public Value mean (Value[] args) {
        return ((double) sum (args)) / args.length;
    }
}
