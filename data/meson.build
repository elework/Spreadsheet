icon_sizes = ['32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i , 'apps')
    )
endforeach

install_data(
    'com.github.ryonakano.spreadsheet.appdata.xml',
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

install_data(
    'com.github.ryonakano.spreadsheet.desktop',
    install_dir: join_paths(get_option('datadir'), 'applications')
)
