project(
    'com.github.elework.spreadsheet',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.59.0'
)

file_name = 'spreadsheet'

i18n = import('i18n')
add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

if get_option('enable_debug')
    add_project_arguments('--debug', language: 'vala')
endif

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

gnome = import('gnome')
asresources = gnome.compile_resources(
    'as-resources',
    'data' / file_name + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true,
    update_desktop_database: true
)

sources = files(
    'src' / 'AlphabetGenerator.vala',
    'src' / 'App.vala',
    'src' / 'Functions' / 'Basic.vala',
    'src' / 'Functions' / 'Geometry.vala',
    'src' / 'Models' / 'Cell.vala',
    'src' / 'Models' / 'CellStyle.vala',
    'src' / 'Models' / 'FontStyle.vala',
    'src' / 'Models' / 'Function.vala',
    'src' / 'Models' / 'HistoryAction.vala',
    'src' / 'Models' / 'Page.vala',
    'src' / 'Models' / 'Spreadsheet.vala',
    'src' / 'Services' / 'CSV' / 'CSVGrammar.vala',
    'src' / 'Services' / 'CSV' / 'CSVParser.vala',
    'src' / 'Services' / 'CSV' / 'CSVWriter.vala',
    'src' / 'Services' / 'Formula' / 'AST' / 'CallExpression.vala',
    'src' / 'Services' / 'Formula' / 'AST' / 'CellReference.vala',
    'src' / 'Services' / 'Formula' / 'AST' / 'Expression.vala',
    'src' / 'Services' / 'Formula' / 'AST' / 'NumberExpression.vala',
    'src' / 'Services' / 'Formula' / 'AST' / 'TextExpression.vala',
    'src' / 'Services' / 'Formula' / 'FormulaGrammar.vala',
    'src' / 'Services' / 'Formula' / 'FormulaParser.vala',
    'src' / 'Services' / 'Parsing' / 'Evaluator.vala',
    'src' / 'Services' / 'Parsing' / 'Grammar.vala',
    'src' / 'Services' / 'Parsing' / 'Lexer.vala',
    'src' / 'Services' / 'Parsing' / 'Parser.vala',
    'src' / 'Services' / 'Parsing' / 'Token.vala',
    'src' / 'Services' / 'FuncSearchList.vala',
    'src' / 'Services' / 'HistoryManager.vala',
    'src' / 'UI' / 'MainWindow.vala',
    'src' / 'UI' / 'TitleBar.vala',
    'src' / 'Widgets' / 'ActionBar.vala',
    'src' / 'Widgets' / 'FunctionPresenter.vala',
    'src' / 'Widgets' / 'Sheet.vala',
    'src' / 'Widgets' / 'StyleModal.vala'
)

executable(meson.project_name(),
    asresources,
    config_file,
    sources,
    dependencies: [
        dependency('gee-0.8'),
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('granite', version: '>=5.4.0'),
        dependency('gtk+-3.0', version: '>=3.22'),
        dependency('libhandy-1', version: '>=1.2.0'),
        dependency('pango')
    ],
    install: true,
    link_args: ['-lm']
)

subdir('data')
subdir('po')
