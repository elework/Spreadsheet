project('Spreadsheet', 'vala', 'c')

gnome = import('gnome')
glib = dependency('glib-2.0', version: '>=2.38')
gobject = dependency('gobject-2.0')
gee = dependency('gee-0.8')
gtk = dependency('gtk+-3.0')
granite = dependency('granite')
pango = dependency('pango')

subdir('data')
subdir('src')

executable('spreadsheet',
  res,
  sources,
  dependencies: [
    glib,
    gobject,
    gee,
    gtk,
    granite,
    pango
  ],
  link_args: ['-lm']
)
