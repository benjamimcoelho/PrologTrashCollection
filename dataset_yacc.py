import ply.yacc as yacc
from dataset_lex import tokens
from dataset_lex import literals
import sys
import re
from geopy.distance import distance

last_street = ''
info = []
pontoId = 0


def deleteNewLine(string):
    return re.sub(r'\n', '', string)


def strip_one_space(s):
    if s.endswith(" "):
        s = s[:-1]
    if s.startswith(" "):
        s = s[1:]
    return s


def getAdjacencias(rua, arestas):
    res = []
    for aresta in arestas:
        if aresta[0] == rua:
            res.append(aresta[1])
    return res


def exportArestas(arestas, pontos_recolha):
    arestas_pontos = []
    for i in pontos_recolha.items():
        adjacencias = getAdjacencias(i[1][3], arestas)
        for j in pontos_recolha.items():
            if j[1][3] in adjacencias:
                d = distance((i[1][0], i[1][1]), (j[1][0], j[1][1])).km
                arestas_pontos.append((i[0], j[0], d))

    with open("arestas.pl", 'w') as f:
        f.write(':- module(arestas, [aresta/3]).\n')
        for aresta in arestas_pontos:
            f.write('aresta( ' + str(aresta[0]) + ' , ' +
                    str(aresta[1]) + ' , ' + str(aresta[2]) + ' ).\n')


def exportPontosRecolha(pontos_recolha):
    with open("pontosRecolha.pl", 'w') as f:
        f.write(':- module(pontosRecolha, [pontoRecolha/6]).\n')
        for i in pontos_recolha.items():
            f.write('pontoRecolha( ' + i[0] + ' , ' + i[1][0] + ' , ' + i[1][1] +
                    ' , \'' + i[1][2] + '\' , \'' + strip_one_space(i[1][3]) + '\' , ' + str(i[1][4]) + ').\n')

# id -> [latitude,longitude,Freguesia,rua,[(tipo residuo,tipo_contentor,litros)...]]


def contains(list, elem):
    for i in range(len(list)):
        if list[i] == elem:
            return True
    return False


def addIfNew(list, elem):
    if not contains(list, elem) and elem[0] != elem[1]:
        list.append(elem)


def updateContentor():
    global last_street, info, pontoId
    if pontoId in parser.pontos_recolha:  # se o ponto de recolha já existir, so temos de adicionar o contentor
        aux = parser.pontos_recolha.get(pontoId)
        aux2 = aux[4]
        if not contains(aux2, info[4][0]):
            aux2.append(info[4][0])
            aux[4] = aux2
            parser.pontos_recolha.update({pontoId: aux})
    else:  # se o ponto de recolha ainda n existir temos de adicioná-lo
        parser.pontos_recolha.update({pontoId: info})


def p_Entry(p):
    "Entry : FLOAT ',' FLOAT ',' INT ',' WORD ',' RUAS ',' WORD ',' WORD ',' INT ',' INT ',' INT"
    global info
    p[0] = p[1] + p[3] + p[5] + p[7] + p[9] + \
        p[11] + p[13] + p[15] + p[17] + p[19]
    info[0] = p[1]
    info[1] = p[3]
    info[2] = p[7]
    info[4] = [(p[11], p[13], deleteNewLine(p[19]))]

    updateContentor()


def p_RUAS_Par(p):
    "RUAS : INT ':' WORD '(' PAR LIXO ':' WORD '-' WORD ')'"
    global last_street, info, pontoId
    p[0] = 'ruas par'
    addIfNew(parser.arestas, (p[8], p[3]))
    addIfNew(parser.arestas, (p[3], p[10]))
    last_street = p[3]
    info = [0, 0, 0, p[3], [], 0]
    pontoId = p[1]


def p_RUAS_Impar(p):
    "RUAS : INT ':' WORD '(' IMPAR LIXO ':' WORD '-' WORD ')'"
    global last_street, info, pontoId
    p[0] = 'ruas impar'
    addIfNew(parser.arestas, (p[10], p[3]))
    addIfNew(parser.arestas, (p[3], p[8]))
    last_street = p[3]
    info = [0, 0, 0, p[3], []]
    pontoId = p[1]


def p_RUAS_Ambos(p):
    "RUAS : INT ':' WORD '(' AMBOS LIXO ':' WORD '-' WORD ')'"
    global last_street, info, pontoId
    p[0] = 'ruas ambos'
    addIfNew(parser.arestas, (p[8], p[3]))
    addIfNew(parser.arestas, (p[3], p[10]))
    addIfNew(parser.arestas, (p[10], p[3]))
    addIfNew(parser.arestas, (p[3], p[8]))
    last_street = p[3]
    info = [0, 0, 0, p[3], []]
    pontoId = p[1]


def p_RUAS_rua_rua(p):
    "RUAS : INT ':' WORD ',' WORD"
    global last_street, info, pontoId
    p[0] = 'rua'
    addIfNew(parser.arestas, (p[3], p[5]))
    addIfNew(parser.arestas, (p[3], last_street))
    addIfNew(parser.arestas, (last_street, p[3]))
    last_street = p[3]
    info = [0, 0, 0, p[3], []]
    pontoId = p[1]


def p_RUAS_rua_int(p):
    "RUAS : INT ':' WORD ',' INT"
    global last_street, info, pontoId
    p[0] = 'rua'
    addIfNew(parser.arestas, (p[3], last_street))
    addIfNew(parser.arestas, (last_street, p[3]))
    last_street = p[3]
    info = [0, 0, 0, p[3], []]
    pontoId = p[1]


def p_RUAS_rua_seq(p):
    "RUAS : INT ':' WORD ',' SEQ"
    global last_street, info, pontoId
    p[0] = 'rua'
    addIfNew(parser.arestas, (p[3], last_street))
    addIfNew(parser.arestas, (last_street, p[3]))
    last_street = p[3]
    info = [0, 0, 0, p[3], []]
    pontoId = p[1]


def p_RUAS_rua_INT_WORD(p):
    "RUAS : INT ':' WORD ',' INT WORD"
    global last_street, info, pontoId
    p[0] = 'rua'
    addIfNew(parser.arestas, (p[3], last_street))
    addIfNew(parser.arestas, (last_street, p[3]))
    last_street = p[3]
    info = [0, 0, 0, p[3], []]
    pontoId = p[1]


def p_error(p):
    global l
    print("Syntax error in input: ", p)
    print('linha ' + str(l))


parser = yacc.yacc()


# id -> [latitude,longitude,Freguesia,rua,[(tipo residuo,tipo_contentor,litros)...]]
parser.pontos_recolha = {}


# rua -> rua (significa que o camiao viaja no sentido esquerda para a direita)
parser.arestas = []
total = 0
l = 0


with open('dataset.csv') as input:
    for linha in input:
        result = parser.parse(linha)
        if result:
            # print('entry valida: \n\n' + result)
            total += 1
        l += 1

print('TOTAL ENTRIES VÁLIDAS: ' + str(total))
# print(parser.arestas)
# print(str(len(parser.arestas)))
# print(parser.pontos_recolha)
# print(str(len(parser.pontos_recolha)))
exportArestas(parser.arestas, parser.pontos_recolha)
exportPontosRecolha(parser.pontos_recolha)
