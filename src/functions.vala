namespace Spreadsheet.Functions {
    public Value sum (Value[] args) {
        double res = 0.0;
        foreach (Value num in args) {
            if (num.type () == typeof (int)) {
                res += (int) num;
            } else if (num.type () == typeof (double)) {
                res += (double) num;
            } else if (num.type () == typeof (string)) {
                res += int.parse ((string) num);
            }
        }
        return res;
    }
}
