import spacy # https://spacy.io/  (pip3 install spacy)
import re
import io

nlp = spacy.load('pt_core_news_sm')

CNJ = ''
cpf = ''
nome = ''
email = ''
strCNPJ = ''
vlrCausa = ''
linhaAtual = ''

#Busca o nome do Autor
def getNomeAutor(texto):
	aPatternName = ["casad","solteir","desempregad","brasileir","divorciad","nascid","portador"]
	regexName = r"^([^,]+[A-Z])"
	nome = ''

	for linhas in texto:

		# Procura as palavras chaves
		if any(i in linhas.lower() for i in aPatternName):
			nL = texto.index(linhas)
			linhaAtual = texto[nL]
			matches = re.finditer(regexName, linhaAtual, re.DOTALL)

			# Realiza os matchs do Regex 
			for matchNum, match in enumerate(matches):
				nome = match.group()
				linhaAtual = ''

			# Se não achou no Regex, busca pela entidade
			if nome == '':
				linhaAtual = nlp(texto[nL])

				# Verifica palavra por palavra para encontrar a entidade
				for word in linhaAtual.ents:
					if word.label_ == 'PER':
						nome = word.text
						linhaAtual = ''
					elif word.label_ == 'MISC' and nome == '':
						nome = word.text
						linhaAtual = ''
			else:
				break
	return nome

# Busca o CPF do Autor
def getcpfAutor(texto, nome):
	aPatterncpf = ["cpf","cpf/mf"]
	regexcpf = r"\d{3}\.\d{3}\.\d{3}\-\d{2}"
	cpf = ''

	for linhas in texto:
		# Verifica se encontra o pattern do cpf
		if any(i in linhas.lower() for i in aPatterncpf):
			nL = texto.index(linhas)

			if nL > 5:
				startLine = nL - 5
			else:
				startLine = 1

			endLine = nL + 6
			linhas = texto[startLine:endLine]
			linhas = ''.join(linhas)
			linhas = linhas.replace("\r","")
			linhas = linhas.replace("\n","")
		
		# Se o nome for encontrado nas linhas selecionadas (startLine:endLine)
		if nome in linhas and nome != '':
			matches = re.finditer(regexcpf, linhas, re.DOTALL)

			for matchNum, match in enumerate(matches):
				cpf = match.group()

				if cpf != '':
					break
	return cpf

#Busca o E-mail do autor
def getEmailAutor(texto, nome):
	regexEmail = r"[\w\.-]+@[\w\.-]+"
	aPatternEmail = ["endereço eletrônico","e-mail","email"]
	email = ''

	for linhas in texto:

		if any(i in linhas.lower() for i in aPatternEmail):
			nL = texto.index(linhas)

			if nL > 6:
				startLine = nL - 6
			else:
				startLine = 1

			endLine = nL + 2
			linhas = texto[startLine:endLine]
			linhas = ''.join(linhas)

			# Se o nome for encontrado nas linhas selecionadas (startLine:endLine)
			if nome in linhas and nome != '':
				matches = re.finditer(regexEmail, linhas, re.DOTALL)

				# Verifica o Regex
				for matchNum, match in enumerate(matches):
					email = match.group()
					
				if email != '':
					break
				
	return email

# Busca o CNPJ do Polo Passivo
def getCNPJ(texto):
	regexCNPJ = r"\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}"
	strCNPJ = ''
	CNPJ = ''
	aCNPJ =[]
	i = 0
	#Varre as linhas do texto procurando CNPJ
	for linhas in texto:
		nL = texto.index(linhas)
		startLine = nL - 1
		endLine = nL + 2
		linhas = texto[startLine:endLine]
		linhas = ''.join(linhas)
		linhas = linhas.replace("\r","")
		linhas = linhas.replace("\n","")
		matches = re.finditer(regexCNPJ, linhas, re.DOTALL)
		# Se encontrar um CNPJ, adiciona no array
		for matchNum, match in enumerate(matches):

			CNPJ = match.group() 

			if CNPJ not in aCNPJ:
				aCNPJ.append(CNPJ)
	#Formata os dados do array e converte em string
	for reg in aCNPJ:
		i+=1
		CNPJ = ' {"id":'+str(i)+' , "CNPJ":"' + reg + '"} '
		aCNPJ[i-1] = CNPJ
		strCNPJ = ', '.join(aCNPJ) # Transforma o array aCNPJ em string para ser aceito no JSON

	return strCNPJ

#Busca o número do processo
def getProcesso(texto):
	aPatternCnj = ["autos do processo","processo número","processo","número do processo"]
	regexCNJ =  r"\d{7}\-\d{2}\.\d{4}\.\d{1}\.\d{2}\.\d{4}"
	CNJ = ''

	for linhas in texto:
		if any(i in linhas.lower() for i in aPatternCnj):
			nL = texto.index(linhas)
			linhaAtual = texto[nL]
			matches = re.finditer(regexCNJ, linhaAtual, re.DOTALL)

			for matchNum, match in enumerate(matches):
				CNJ = match.group()
				linhaAtual = ''

				if CNJ != '':
					break

	return CNJ

#Busca o valor da causa
def getValorCausa(texto):
	aPatternVlrCausa = ["à causa o valor equivale a","a causa o valor equivale a"]
	aPatternVlrCausa.append("à causa o valor de")
	aPatternVlrCausa.append("à causa, o valor de")
	aPatternVlrCausa.append("a causa o valor de")
	aPatternVlrCausa.append("a causa, o valor de")
	aPatternVlrCausa.append("à causa o montante")
	aPatternVlrCausa.append("à causa, o montante")
	aPatternVlrCausa.append("a causa o montante")
	aPatternVlrCausa.append("a causa, o montante")
	aPatternVlrCausa.append("alçada, o valor de")
	aPatternVlrCausa.append("alcada, o valor de")
	aPatternVlrCausa.append("alçada o valor de")
	aPatternVlrCausa.append("alcada o valor de")
	aPatternVlrCausa.append("alçada o montante")
	aPatternVlrCausa.append("alcada o montante")

	aPatternVlrCausa.append( "valor da causa")
	regexValor = r"\d{1,3}(\.\d{3})*,\d{2}"
	valor = ''

	for linhas in texto:

		if any(i in linhas.lower() for i in aPatternVlrCausa):
			nL = texto.index(linhas)

			if nL > 2:
				startLine = nL - 2
			else:
				startLine = 1

			endLine = nL + 6
			linhas = texto[startLine:endLine]
			linhas = ''.join(linhas)
			linhas = linhas.replace("\r","")
			linhas = linhas.replace("\n","")
			matches = re.finditer(regexValor, linhas, re.DOTALL)

			# Verifica o Regex
			for matchNum, match in enumerate(matches):
				valor = match.group()

				if valor != '':
					break

	return valor

# Busca os dados do processo
def findPattern(data):

	newData = io.StringIO(data) # Converte o conteúdo do body para string
	texto = newData.readlines()

	nome = getNomeAutor(texto)
	strCNPJ = getCNPJ(texto)
	CNJ = getProcesso(texto)
	vlrCausa = getValorCausa(texto)

	# Monta a estrutura do JSON
	oJson = '{"autor":"'+ nome + '", '  
	oJson += '"cpf":"'+ getcpfAutor(texto, nome) + '", '
	oJson += '"email":"' + getEmailAutor(texto, nome) + '", '
	oJson += '"polopassivo":['+ strCNPJ +'], '
	oJson += '"processo":"'+ CNJ +'", '
	oJson += '"valorCausa":"'+ vlrCausa + '" }'

	return oJson
