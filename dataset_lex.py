import ply.lex as lex


tokens = ['FLOAT', 'INT', 'WORD']

literals = [',', ':', '(', ')', '-']


t_FLOAT = r'[\-+]?\d+\.\d+'
t_INT = r'\d+'
t_WORD = r'[a-zA-Z\s]+'


def t_error(t):
    print("Carater ilegal: ", t.value[0])
    t.lexer.skip(1)


t_ignore = " \t\n\">/º"
lexer = lex.lex()

# PARA TESTAR O ANALISADOR LEXICO:

import sys
with open('dataset.csv') as input:
    for linha in input:
        lexer.input(linha)
        for tok in lexer:
            print(tok)
