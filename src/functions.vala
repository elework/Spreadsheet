namespace Spreadsheet.Functions {
    public Value sum (Value[] args) {
        int res = 0;
        foreach (Value num in args) {
            if (num.type () == typeof (int)) {
                res += (int) num;
            } else if (num.type () == typeof (string)) {
                res += int.parse ((string) num);
            }
        }
        return res;
    }
}
