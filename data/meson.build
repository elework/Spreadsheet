icon_sizes = ['32', '48', '64', '128']

install_data(
    file_name + '.gschema.xml',
    rename: meson.project_name() + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

foreach i : icon_sizes
    install_data(
        'icons' / i / file_name + '.svg',
        rename: meson.project_name() + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps'
    )
endforeach

i18n.merge_file(
    input: file_name + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: file_name + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.project_source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)
