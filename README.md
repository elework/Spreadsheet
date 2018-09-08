# Spreadsheet

*A spreadsheet app for elementary OS.*

One day I was lost on the Internet, I found this great [mockup](http://bassultra.deviantart.com/art/Spreadsheet-363147552) of a spreadsheet app, and I decided to make it real.

![Screenshot](screen.png)

The goal of this project is to build a Spreadsheet app that perfectly fits in elementary OS
(so, sorry if you are using an other distribution, or if you are not using GNU/Linux, but I propably won't provide builds for you, at least in a near future).

## Building

You'll need Vala, Gee, the elementary OS SDK and [meson](https://github.com/mesonbuild/meson) to build this app.
On elementary OS (or any distribution with `apt`), you can run this command to get them.

```bash
sudo apt install valac libgee-0.8-dev elementary-sdk meson
```

Then clone the project with and go to its root directory. You can build with these commands:

```bash
mkdir build && cd build # Create build directory
meson .. # Configure project
ninja # Builds the project (sometimes it's ninja-build, not ninja)
./xyz.gelez.spreadsheet # Run the app
```

To build the project again you'll only need the two last commands.

## Contributing

There is many ways you can contribute, even if you don't know how to code.

### Reporting bugs or suggesting improvements

If you have GitHub account, simply create a new issue describing your problem and how to reproduce.

If you don't have a GitHub account and don't want to create one, you can contact me on Mastodon, i'm `Bat@unixcorn.xyz`.

### Writing some code

Before coding, fork the project and build it as explained above.

We are using Vala, as many other elementary OS apps, so it would be better if you know a bit about it, but you don't have to be an expert.

Before writing some code, let the others know on what you'll be working. The best way to do that is to go to the related issue (or create it if it doesn't exist yet),
and to say that you are working on it. Then start a new branch on your fork, based on `master` (and be sure master is up-to-date). You can start coding.

We use the [same conventions as elementary OS](https://elementary.io/docs/code/reference#code-style) in our code, please try to respect them.
But there is two differences:

- we also name our namespaces after the folder they are in (`Spreadsheet.Parser.AST` is in `src/parser/ast`)
- we don't put the GPL in every file, since the project is licensed under the MIT license
