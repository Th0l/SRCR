from math import radians, cos, sin, asin, sqrt
import pandas as pd
import xlrd
import re

def excellToCsv():

    xls = xlrd.open_workbook('lista_adjacencias_paragens.xlsx', on_demand=True)
    sheets = xls.sheet_names();
    csv = "csvs/carreira_"
    for sheet in range(0,len(sheets)):
        file_name = csv + sheets[sheet] + ".csv"
        read_file = pd.read_excel('lista_adjacencias_paragens.xlsx', sheet_name=sheets[sheet])
        read_file.to_csv(file_name, index = None, header=True)

def csvToProlog():                                          #LINHAS INCOMPLETAS VÃO SER DESCARTADAS

    file = open("base_de_conhecimento.pl","w")
    check = 0

    with open('nodos.csv') as fp:                           #Vai abrir o CSV e meter na var fp
        for line in fp:                                     #Vai ler linha a linha
            lista = re.split('[;\n]',line)                  #Vai separar a linha q leu pelos ; e pelos \n
            lista = ["void" if x == '' else x for x in lista]
            #truncLista = list(filter(None,lista))           #Vai remover todas as strings vazias q correspondem a \n ou ausencia de valores
            tamanho = len(lista)                       #Tamanho da lista, tamanho = 11, significa q tem todos os elementos necessários
            #0-GID , 1-Latitude , 2-longitude , 3-Estado , 4-Abrigo , 5-Publicidade , 6-Operadora , 7-Carreira , 8-codigoRua , 9-nomeRua , 10-Freguesia
            if(tamanho == 12 and check >= 1):
                toWrite = "paragem(" + lista[0] + ","
                toWrite = toWrite + lista[1] + ","
                toWrite = toWrite + lista[2] + ","
                toWrite = toWrite + str.lower(lista[3]) + ","
                toWrite = toWrite + str.lower(lista[4]).replace('"','').replace(' ','_').replace(',','_') + ","            #Substitui caracteres inuteis pois o csv esta cheio deles
                toWrite = toWrite + str.lower(lista[5]) + ","
                toWrite = toWrite + str.lower(lista[6]) + ","
                toWrite = toWrite + "[" + lista[7] + "]" + ","
                toWrite = toWrite + lista[8] + ","
                toWrite = toWrite + "'" + str.lower(lista[9]).replace(',','').replace("'",'') + "'" + ","#.replace(' ','_').replace(',','_').replace("'",'') + ","            #Substitui caracteres inuteis pois o csv esta cheio deles
                toWrite = toWrite + "'" + str.lower(lista[10]).replace(',','').replace("'",'') + "'" + ").\n" #.replace(' ','_').replace(',','_').replace("'",'') + ").\n"        #Substitui caracteres inuteis pois o csv esta cheio deles

                file.write(toWrite)

            check += 1

    file.close()

def adjacencias():                                          #ELEMENTOS CONSECUTIVOS REPETIDOS VAO SER DESCATADOS
    file = open("base_de_conhecimento.pl","a")

    xls = xlrd.open_workbook('lista_adjacencias_paragens.xlsx', on_demand=True)
    sheets = xls.sheet_names();
    csv = "csvs/carreira_"
    col_list = ["gid"]                                      #So vai ler do csv os elementos q pertencem a coluna gid
    myset = set()

    file.write('\n')

    for sheet in range(0,len(sheets)):
        file_name = csv + sheets[sheet] + ".csv"
        df = pd.read_csv(file_name, usecols=col_list)

        gid = df["gid"]                                     #Mete em gid o array correspondente aos valores da coluna gid

        for loop in range(0,len(gid)-1):
            string = "adjacente(" + str(gid[loop]) + "," + str(gid[loop+1]) + "," + sheets[sheet] + ").\n"
            string2 = str(gid[loop]) + "," + str(gid[loop+1])
            if(gid[loop] != gid[loop+1]):                   #Csv tem elementos repetidos consecutivamente, para evitar termos adjacente(512,512), este if existe
                file.write(string)
                myset.add(string2)

    file.write('\n')

    for val in myset:
        gucci = "nextTo("+val+").\n"
        file.write(gucci)
    file.close()


#---To Execute--------------------------------------------------------------------------------------------------------------------------------------------------
#excellToCsv()
csvToProlog()
adjacencias()
