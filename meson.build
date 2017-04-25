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
  'src/Functions.vala',

  'src/ui/MainWindow.vala',
  'src/widgets/Sheet.vala',
  'src/widgets/FunctionPresenter.vala',

  'src/models/Cell.vala',
  'src/models/Function.vala',
  'src/models/Page.vala',
  'src/models/Spreadsheet.vala',

  'src/parser/Evaluator.vala',
  'src/parser/Grammar.vala',
  'src/parser/Lexer.vala',
  'src/parser/Parser.vala',
  'src/parser/Token.vala',

  'src/parser/ast/CallExpression.vala',
  'src/parser/ast/Expression.vala',
  'src/parser/ast/NumberExpression.vala',
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
