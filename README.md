# Spreadsheet

Spreadsheet is a spreadsheet app built with Vala and GTK+, and especially for elementary OS.

![Screenshot](screen.png)

It was originally developed by [Baptiste Gelez](https://github.com/BaptisteGelez), who wrote:

> One day I was lost on the Internet, I found this great [mockup](https://www.deviantart.com/bassultra/art/Spreadsheet-363147552) of a spreadsheet app, and I decided to make it real.

The goal of this project is to build a spreadsheet app that perfectly fits in elementary OS. However, this app may have been built and made available elsewhere by community members. These builds may have modifications or changes and are not provided or supported by us.

## Building and Installation

You'll need the following dependencies:

* libgee-0.8-dev
* libgranite-dev (>= 5.2.0)
* libgtk-3-dev (>= 3.22)
* meson
* valac

On elementary OS (or any distribution with `apt`), you can get them with the following command:

    sudo apt install valac libgranite-dev meson

Then clone the project and go to its root directory. Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.spreadsheet`

    sudo ninja install
    com.github.ryonakano.spreadsheet

## Contributing

There are many ways you can contribute, even if you don't know how to code.

### Reporting Bugs or Suggesting Improvements

Simply [create a new issue](https://github.com/ryonakano/Spreadsheet/issues/new) describing your problem and how to reproduce or your suggestion. If you are not used to do, [this section](https://elementary.io/ja/docs/code/reference#reporting-bugs) is for you.

### Writing Some Code

Before coding, fork the project and build it as explained above.

We use Vala, as many other elementary OS apps, so it would be better if you know a bit about it, but you don't have to be an expert.

Before writing some code, let the others know on what you'll be working. The best way to do that is to go to the related issue (or create one if any related issue doesn't exist yet), and to say that you are working on it. Then start a new branch on your fork, based on `master` (and be sure master is up-to-date). You can start coding.

We follow the [coding style of elementary OS](https://elementary.io/docs/code/reference#code-style) and [its Human Interface Guidelines](https://elementary.io/ja/docs/human-interface-guidelines#human-interface-guidelines) in our code, please try to respect them. But there are two differences:

* We also name our namespaces after the folder they are in (e.g. `Spreadsheet.Services.Formula.AST` is in `src/Services/Formula/AST`)
* We don't put the GPL in every file, since the project is licensed under the MIT license
