namespace Spreadsheet.Functions {
    private double number (Value num) {
        var res = 0.0;
        if (num.type () == typeof (int)) {
            res = (double) num.get_int ();
        } else if (num.type () == typeof (double)) {
            res = (double) num;
        } else if (num.type () == typeof (string)) {
            res = double.parse ((string) num);
        }
        return res;
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
            if (number (arg) < min) {
                min = number (arg);
            }
        }
        return min;
    }

    public Value max (Value[] args) {
        double max = number (args[0]);
        foreach (var arg in args) {
            if (number (arg) > max) {
                max = number (arg);
            }
        }
        return max;
    }

    public Value mean (Value[] args) {
        return ((double) sum (args)) / args.length;
    }
}
