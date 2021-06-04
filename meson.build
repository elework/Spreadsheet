project('com.github.elework.spreadsheet', 'vala', 'c')

file_name = 'spreadsheet'

i18n = import('i18n')
add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: join_paths('src', 'Config.vala.in'),
    output: '@BASENAME@',
    configuration: config_data
)

gnome = import('gnome')
asresources = gnome.compile_resources(
    'as-resources',
    join_paths('data', file_name + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

executable(meson.project_name(),
    asresources,
    config_file,
    'src/AlphabetGenerator.vala',
    'src/App.vala',
    'src/Functions/Basic.vala',
    'src/Functions/Geometry.vala',
    'src/Models/Cell.vala',
    'src/Models/CellStyle.vala',
    'src/Models/FontStyle.vala',
    'src/Models/Function.vala',
    'src/Models/HistoryAction.vala',
    'src/Models/Page.vala',
    'src/Models/Spreadsheet.vala',
    'src/Services/CSV/CSVGrammar.vala',
    'src/Services/CSV/CSVParser.vala',
    'src/Services/CSV/CSVWriter.vala',
    'src/Services/Formula/AST/CallExpression.vala',
    'src/Services/Formula/AST/CellReference.vala',
    'src/Services/Formula/AST/Expression.vala',
    'src/Services/Formula/AST/NumberExpression.vala',
    'src/Services/Formula/AST/TextExpression.vala',
    'src/Services/Formula/FormulaGrammar.vala',
    'src/Services/Formula/FormulaParser.vala',
    'src/Services/Parsing/Evaluator.vala',
    'src/Services/Parsing/Grammar.vala',
    'src/Services/Parsing/Lexer.vala',
    'src/Services/Parsing/Parser.vala',
    'src/Services/Parsing/Token.vala',
    'src/Services/FuncSearchList.vala',
    'src/Services/HistoryManager.vala',
    'src/UI/MainWindow.vala',
    'src/UI/TitleBar.vala',
    'src/Widgets/ActionBar.vala',
    'src/Widgets/FunctionPresenter.vala',
    'src/Widgets/Sheet.vala',
    'src/Widgets/StyleModal.vala',
    dependencies: [
        dependency('glib-2.0', version: '>=2.38'),
        dependency('gobject-2.0'),
        dependency('gee-0.8'),
        dependency('gtk+-3.0', version: '>=3.22'),
        dependency('granite', version: '>=5.4.0'),
        dependency('pango')
    ],
    install: true,
    link_args: ['-lm']
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
