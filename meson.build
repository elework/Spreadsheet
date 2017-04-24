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
  'src/main.vala',
  'src/functions.vala',

  'src/ui/main-window.vala',
  'src/widgets/sheet.vala',
  'src/widgets/function-presenter.vala',

  'src/models/cell.vala',
  'src/models/function.vala',
  'src/models/page.vala',
  'src/models/spreadsheet.vala',

  'src/parser/evaluator.vala',
  'src/parser/grammar.vala',
  'src/parser/lexer.vala',
  'src/parser/parser.vala',
  'src/parser/token.vala',

  'src/parser/ast/call-expression.vala',
  'src/parser/ast/expression.vala',
  'src/parser/ast/number-expression.vala',
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
