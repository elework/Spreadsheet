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
}
