# Spreadsheet

*A spreadsheet app for elementary OS.*

One day I was lost on the Internet, I found this great [mockup](http://bassultra.deviantart.com/art/Spreadsheet-363147552) of a spreadsheet app, and I decided to make it real.

![Screenshot](screen.png)

## Building

You'll need Vala, Gee, the elementary OS SDK and [meson](https://github.com/mesonbuild/meson) to build this app.

```bash
mkdir build && cd build # Create build directory
meson .. # Configure project
ninja # Builds the project (sometimes it's ninja-build, not ninja)
./spreadsheet # Run the app
```
