import ply.lex as lex

reserved = {
    'Par ': 'PAR',
    'Impar ': 'IMPAR',
    'Ambos ': 'AMBOS',
}

tokens = ['FLOAT', 'INT', 'WORD', 'LIXO', 'SEQ'] + list(reserved.values())

literals = [',', ':', ')', '(', '-']


def t_WORD(t):
    r'\s*[a-zA-Z][\.\d\w\s]*'
    t.type = reserved.get(t.value, 'WORD')    # Check for reserved words
    return t


t_FLOAT = r'[\-+]?\d+\.\d+'
t_INT = r'\s*\d+\s*'
t_LIXO = r'\(\d*\-\>\d*\)\(\d*\-\>\d*\)'
t_SEQ = r'\s*(\d+\-)+\d+'


def t_error(t):
    #global l
    print("Carater ilegal: ", t.value[0])
    #print('Linha :' + str(l))
    t.lexer.skip(1)


t_ignore = "\t\n\"/º"
lexer = lex.lex()

# PARA TESTAR O ANALISADOR LEXICO:
"""
l = 0
import sys
with open('dataset.csv') as input:
    for linha in input:
        lexer.input(linha)
        for tok in lexer:
            print(tok)
        l += 1
"""
