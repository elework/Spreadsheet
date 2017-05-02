project('Spreadsheet', 'vala', 'c')

gnome = import('gnome')
subdir('data')

glib = dependency('glib-2.0', version: '>=2.38')
gobject = dependency('gobject-2.0')
gee = dependency('gee-0.8')
gtk = dependency('gtk+-3.0')
granite = dependency('granite')
pango = dependency('pango')

executable('spreadsheet',
  res,
  'src/App.vala',
  'src/AlphabetGenerator.vala',

  'src/Functions/Basic.vala',
  'src/Functions/Geometry.vala',

  'src/UI/MainWindow.vala',
  'src/Widgets/Sheet.vala',
  'src/Widgets/FunctionPresenter.vala',

  'src/Services/HistoryManager.vala',

  'src/Models/Cell.vala',
  'src/Models/Function.vala',
  'src/Models/Page.vala',
  'src/Models/HistoryAction.vala',
  'src/Models/Spreadsheet.vala',

  'src/Parser/Evaluator.vala',
  'src/Parser/Grammar.vala',
  'src/Parser/Lexer.vala',
  'src/Parser/Parser.vala',
  'src/Parser/Token.vala',

  'src/Parser/AST/CallExpression.vala',
  'src/Parser/AST/Expression.vala',
  'src/Parser/AST/NumberExpression.vala',
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
