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

executable(meson.project_name(),
  'src/AlphabetGenerator.vala',
  'src/App.vala',
  'src/Functions/Basic.vala',
  'src/Functions/Geometry.vala',
  'src/Models/Cell.vala',
  'src/Models/CellStyle.vala',
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
  'src/Services/HistoryManager.vala',
  'src/UI/MainWindow.vala',
  'src/Widgets/FunctionPresenter.vala',
  'src/Widgets/Sheet.vala',
  'src/Widgets/StyleModal.vala',
  res,
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
