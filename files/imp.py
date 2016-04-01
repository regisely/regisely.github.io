import re
import csv
import requests
import lxml.html
from unicodedata import normalize

r = requests.get("http://mapa.vemprarua.net/br/")
tree = lxml.html.fromstring(r.content)

nomes_favor = tree.xpath('//div[@class="panel panel-primary lista-parlamentares favor"]//b/text()')
nomes_favor = [normalize('NFKD', unicode(x)).encode('ascii', 'ignore') for x in nomes_favor]
part_favor = tree.xpath('//div[@class="panel panel-primary lista-parlamentares favor"]//a//span/text()')
parts_favor = [re.sub(r'.*- ', '', x.split('/')[0]) for x in part_favor]
est_favor = [x.split('/')[1] for x in part_favor]

senador = [1] * len(nomes_favor)
for i in range(len(nomes_favor)-1):
    if nomes_favor[i][0] > nomes_favor[i+1][0]:
        senador[i+1:] = [0] * (len(senador) - (i+1))

dados = [("Voto", "Nome", "Partido", "Estado", "Senador")]
favor = zip(["A favor"]*len(nomes_favor), nomes_favor, parts_favor, est_favor, senador)
for fav in favor:
    dados.append(fav)

nomes_contra = tree.xpath('//div[@class="panel panel-red lista-parlamentares contra"]//b/text()')
nomes_contra = [normalize('NFKD', unicode(x)).encode('ascii', 'ignore') for x in nomes_contra]
part_contra = tree.xpath('//div[@class="panel panel-red lista-parlamentares contra"]//a//span/text()')
parts_contra = [re.sub(r'.*- ', '', x.split('/')[0]) for x in part_contra]
est_contra = [x.split('/')[1] for x in part_contra]

senador = [1] * len(nomes_contra)
for i in range(len(nomes_contra)-1):
    if nomes_contra[i][0] > nomes_contra[i+1][0]:
        senador[i+1:] = [0] * (len(senador) - (i+1))

contra = zip(["Contra"]*len(nomes_contra), nomes_contra, parts_contra, est_contra, senador)
for cont in contra:
    dados.append(cont)

nomes_ind = tree.xpath('//div[@class="panel panel-yellow lista-parlamentares"]//b/text()')
nomes_ind = [normalize('NFKD', unicode(x)).encode('ascii', 'ignore') for x in nomes_ind]
part_ind = tree.xpath('//div[@class="panel panel-yellow lista-parlamentares"]//a//span/text()')
parts_ind = [re.sub(r'.*- ', '', x.split('/')[0]) for x in part_ind]
est_ind = [x.split('/')[1] for x in part_ind]

senador = [1] * len(nomes_ind)
for i in range(len(nomes_ind)-1):
    if nomes_ind[i][0] > nomes_ind[i+1][0]:
        senador[i+1:] = [0] * (len(senador) - (i+1))

indecisos = zip([None]*len(nomes_ind), nomes_ind, parts_ind, est_ind, senador)
for indeciso in indecisos:
    dados.append(indeciso)

with open("imp.csv", 'wb') as f:
    writer = csv.writer(f, delimiter=';')
    writer.writerows(dados)
