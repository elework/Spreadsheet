project('com.github.ryonakano.spreadsheet', 'vala', 'c')

gnome = import('gnome')
glib = dependency('glib-2.0', version: '>=2.38')
gobject = dependency('gobject-2.0')
gee = dependency('gee-0.8')
gtk = dependency('gtk+-3.0', version: '>=3.22')
granite = dependency('granite', version: '>=5.2.0')
pango = dependency('pango')

subdir('data')

executable(meson.project_name(),
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
    'src/Widgets/FunctionPresenter.vala',
    'src/Widgets/Sheet.vala',
    'src/Widgets/StyleModal.vala',
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

install_data(
    'data/com.github.ryonakano.spreadsheet.gschema.xml',
    install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)

meson.add_install_script('meson/post_install.py')
