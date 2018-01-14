project('xyz.gelez.spreadsheet', 'vala', 'c')

gnome = import('gnome')
glib = dependency('glib-2.0', version: '>=2.38')
gobject = dependency('gobject-2.0')
gee = dependency('gee-0.8')
gtk = dependency('gtk+-3.0')
granite = dependency('granite')
pango = dependency('pango')

res = gnome.compile_resources(
  'spreadsheet',
  files('data/gresources.xml'),
  source_dir: [ join_paths(meson.source_root(), 'data') ]
)


subdir('src')

executable(meson.project_name(),
  [ sources, res ],
  dependencies: [
    glib,
    gobject,
    gee,
    gtk,
    granite,
    pango
  ],
  install: true,
  link_args: ['-lm']
)
