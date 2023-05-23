#!/usr/bin/env python3

import json

with open('./json/install.json') as file:
    data = json.load(file)

# scripts = data['sqlfiles']

scripts = data['sqlfiles']

# script1 = scripts[0]
# script2 = scripts[1]
# script3 = scripts[2]

for script in scripts:
    # Criar uma variável com o nome do item e atribuir o valor
    # locals()[item] = lista[item]
    print(script)

    # Você pode fazer outras operações com a variável aqui
    # Por exemplo, imprimir o valor do item
    # print(item, ":", locals()[item])


# print(script1)
# print(script2)
# print(script3)