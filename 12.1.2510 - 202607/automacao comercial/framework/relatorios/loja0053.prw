#INCLUDE "Protheus.ch"
#INCLUDE "LOJA0053.ch"

#DEFINE nEstruLeia		9
#DEFINE nEstruItem		4
#DEFINE nLPagP01		080
#DEFINE nLPagP02		130
#DEFINE nLPagP03		220
#DEFINE nLPagL01		080
#DEFINE nLPagL02		165
#DEFINE nLPagL03		220
#DEFINE nReserva		1000

Function LOJA0053;Return Nil //Funcao dummy - uso interno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse    ³LJFrmtLay  ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe criada para facilitar a utilizacao da funcao FrmLeiaute º±±
±±º          ³utilizada para retornar strings formatadas, gerar arquivos     º±±
±±º          ³texto formatados, arquivos CSV e gera relatorios de acordo com º±±
±±º          ³a formatacao dos dados e distribuicao das colunas.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Class LJCFrmtLay

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³P R O P R I E D A D E S  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Data nClTipo
/*
Opcoes do nClTipo :
0. Retorna texto formatado 
1. Grava arquivo texto 
2. Gera relatorio 
3. Gera arquivo CSV 
4. Imprimir em ECF
*/
Data nClTotCol
Data lClUsaDel
Data cClDelCol
Data cClDelLin
Data cClTitulo
Data cClPaperSize
Data cClOrienta
Data nClPosCab
Data aClLeiaute	
/*
Estrutura do aClLeiaute :
1. [N] Leiaute 
2. [A] Distribuicao colunas
3. [A] Alinhamento colunas
4. [L] Cabecalho?
5. [A] Cabecalho colunas
6. [L] Imprime delimitador?
7. [A] Nome dos campos
8. [A] Tipo de dados dos campos
9. [A] Formatacao de campos
*/
Data aClLstItens
/*
Estrutura da lista geral de itens (aClLeiaute) :
1. [N] Leiaute
2. [A] Itens correspondentes as colunas
3. [C] Bloco de dados
4. [L] Determina se o campo esta contido dentro de uma regra de filtragem
*/
Data cClDirDest
Data cClArqDest
Data nClLeiaAtivo
Data lClShowFile
Data lClAutoAjCol
Data lClUseHeadCW			//Usar o cabecalho para determinar largura das colunas da estrutura de leiaute?
Data lClTotColDef			//Determina se o total de colunas foi definido pelo usuario
Data nClPos					//Posicao pesquisada no array de leiaute pela funcao VldPosLeia
Data aClTipoPT				//Array que determina a formatacao padrao por tipo de variavel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Propriedades dos filtros  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Data aClFiltro
/*
Estrutura da lista dos filtros ativos (aClFiltro) : 
1. [N] Posicao leiaute 
2. [C] Bloco
3. [C] Filtro
4. [N] Posicao de um campo especifico
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Propriedades das querys  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Data aClQry	
/* 
Estrutura da array para armazenar as Querys relacionadas com a estrutura (aClQry) :
1. [N] nPosLeia 
2. [C] Instrucao SQL 
3. [L] lParser 
4. [L] Formata campos 
5. [L] Gera cabec?
*/
Data aClQryGrv
/* Estrutura da array das querys jah gravadas (aClQryGrv) : 
1. [N] nPosLeia 
2. [C] cBloco 
3. [L] Sem registros
*/
Data aClQryData	
/*
Array que armazenara o resultado das querys (aClQryData)
1. [N] nPosLeia 
2. [A] Array de dados
3. [N] Posicao na array aClLstItens
*/
Data cClQryBloco			//Armazena o ultimo bloco utilizado pelo controlador da querys

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³M E T O D O S  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Inicializador
Method New(nClTipo,nClTotCol,lClUsaDel,cClDelCol,cClDelLin,cClTitulo,nClPaperSize,cClOrienta,nClPosCab)

//Manipulacao
Method Add(nPosLeia,aItens,cBloco,lVerBloco,nPosD)	//lVerBloco - apenas para utilizacao interna
Method AddStruct(nPosLeia,nNumCol,lCab,lDelimita,aLargCol,aAlinha,aCab,aNomeCMP)
Method AutoAdjCol(nPosLeia,lOpc)
Method DelData(nPosLeia,cAlvo,nPosAlvo,cBloco)
Method DelStruct(nPosLeia)
Method Exec()
Method FindFile(cPath)
Method Finish()
Method GetData(nPosLeia,cAlvo,nPosAlvo,cBloco)
Method GetFile()
Method GetPageSize(cTaman)
Method GetPageOri(cOrienta)
Method GetPosition()
Method GetStruct(nPosLeia,nOpc)
Method GetTotRec(nPosLeia,cBloco)
Method OpenFile()
Method PrintBlank(nPosLeia,nQtde)
Method PrintBlaWD(nPosLeia,nQtde)
Method PrintInfo(nPosLeia)
Method PrintLine(nPosD,nPosLeia)
Method PrintLineWD(nPosD,nPosLeia)
Method PrintText(cTexto,nPosD,nPosLeia)
Method ReplStru(nPosLeia,aEstru,uOpc)
Method RefreshF(nPosLeia,cBloco)
Method RefreshQ(nPosLeia)
Method SetAlign(nPosLeia,aEstru,uCmp)
Method SetColDel(cCarac)
Method SetColWidth(nPosLeia,aEstru)
Method SetFieldN(nPosLeia,aEstru,uCmp)
Method SetFile(cArq)
Method SetFilter(nPosLeia,cBloco,uCmp,cAlvo)
Method SetHeadCW(lOpc)
Method SetHeader(nPosLeia,aEstru,uCmp)
Method SetPageOri(cOrienta)
Method SetPageSize(cTaman)
Method SetLinDel(cCarac)
Method SetMainHead(nPosLeia)
Method SetTitle(cTitulo)
Method SetTotCol(nLarg)
Method SetType(nTipo)
Method SetUseDel(nPosLeia)
Method ShowFile(lOpc)
Method UseHeader(nPosLeia,lOpc)

//Metodos para querys
Method SetQry(nPosLeia,cQry,lParser,lExec,lGrava,lFormata,lCab)
Method ExecQry(nPosLeia,lGravaData)
Method RecQry(nPosLeia)
Method DelQry(nPosLeia,lApagaData,nNivel)	//Apagar a query podendo apagar os dados gerados por ela
Method GetQryBlock(nPosLeia)
Method GetQrySQL(nPosLeia)

EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³New        ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para inicializacao da classe e instanciar o objeto.     º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method New(nTipo,nTotCol,lUsaDel,cDelCol,cDelLin,cTitulo,cPaperSize,cOrienta,nPosCab) Class LJCFrmtLay

Default nTipo			:= 0
Default nTotCol		:= 0
Default lUsaDel		:= .T.
Default cDelCol		:= "-"
Default cDelLin		:= "|"
Default cTitulo		:= STR0001 //"RELATÓRIO CUSTOMIZADO"
Default cPaperSize		:= "G"
Default cOrienta		:= "P"
Default nPosCab		:= 0

If ValType(nTipo) # "N"
	If ValType(nTipo) == "C" .AND. nTipo $ "0123456789"
		nTipo := cValToChar(nTipo)
	Else
		nTipo := 0
	Endif	
Endif
If !cValToChar(nTipo) $ "0|1|2|3|4"
	nTipo := 0
Endif
If nTipo == 2 //Relatorio
	If !cPaperSize $ "P|M|G"
		cPaperSize := "G"
	Endif
	If !cOrienta $ "P|L"
		cOrienta := "P"
	Endif	
	If nTotCol == 0
		Do Case
			Case cOrienta == "P"
				Do Case 
					Case cPaperSize == "P
						nTotCol := nLPagP01
					Case cPaperSize == "M"
						nTotCol := nLPagP02
					Case cPaperSize == "G"
						nTotCol := nLPagP03
				EndCase
			Case cOrienta == "L"
				Do Case 
					Case cPaperSize == "P
						nTotCol := nLPagL01
					Case cPaperSize == "M"
						nTotCol := nLPagL02
					Case cPaperSize == "G"
						nTotCol := nLPagL03
				EndCase
			Otherwise
				nTotCol := nLPagP01
		EndCase
		Self:lClTotColDef := .F.
	Else
		Self:lClTotColDef := .T.
	Endif
Else
	If nTotCol == 0
		Self:lClTotColDef := .F.
		nTotCol := nLPagP02
	Else
		Self:lClTotColDef := .T.
	Endif
Endif
//Alimentar array de formatados de campo padrao
Self:aClTipoPT := {}
aAdd(Self:aClTipoPT,{"N","@E 9,999,999.99"})
aAdd(Self:aClTipoPT,{"D","@D"})
aAdd(Self:aClTipoPT,{"C","@!"})
//Alimentar variaveis
Self:nClTipo		:= nTipo
Self:nClTotCol		:= nTotCol
Self:lClUsaDel		:= lUsaDel
Self:cClDelCol		:= AllTrim(Substr(cDelCol,1,1))
Self:cClDelLin		:= AllTrim(Substr(cDelLin,1,1))
Self:cClTitulo		:= cTitulo
Self:cClPaperSize	:= cPaperSize
Self:cClOrienta		:= cOrienta
Self:nClPosCab		:= nPosCab
Self:aClLeiaute		:= {}
Self:aClLstItens	:= {}
Self:cClDirDest		:= ""
Self:cClArqDest		:= ""
Self:nClLeiaAtivo	:= 0
Self:lClShowFile	:= .T.
Self:lClAutoAjCol	:= .T.
Self:lClUseHeadCW	:= .T.
Self:nClPos			:= 0
Self:aClFiltro		:= {}
Self:aClQry			:= {}
Self:aClQryGrv		:= {}
Self:aClQryData		:= {}
Self:cClQryBloco	:= "1000"
//Adicionar a estrutura reservada de numero 01, utilizada para as funcoes PrintXXXX
aAdd(Self:aClLeiaute,{1,{100},{"L"},.F.,{},.F.,{},{},{}})

Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Add        ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para adicionar itens a imprimir.                        º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method Add(nPosLeia,aItens,cBloco,lVerBloco,nPosD) Class LJCFrmtLay

Local lRet			:= .F.
Local ni			:= 0
Local nPos			:= 0
Local aTMP			:= {}

Default nPosLeia	:= 0
Default aItens		:= {}
Default cBloco		:= "0"
Default lVerBloco	:= .T.
Default nPosD		:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.) .OR. !ValType(cBloco) $ "C|N" .OR. ValType(nPosD) # "N"
	Return lRet
Else
	nPos := Self:nClPos
Endif
//Verificar se o numero de itens eh identico ao numero de elementos da estrutura do leiaute
If Len(Self:aClLeiaute[nPos][2]) # Len(aItens)
	Return lRet
Endif
If ValType(aItens) # "A"
	Return lRet
Endif
//Verificar se nao existem elementos nulos
For ni := 1	 to Len(aItens)
	If aItens[ni] == Nil
		aItens[ni] := ""
	Endif
	aAdd(aTMP,aItens[ni])
Next ni
//Se o bloco for maior ou igual ao definido como reservado, zerar
If ValType(cBloco) == "N"
	cBloco := Int(Abs(cValToChar(cBloco)))
Endif
If lVerBloco .AND. Val(cBloco) >= nReserva
	cBloco := "0"
Endif
//Adicionar elemento passado
If Empty(nPosD)
	aAdd(Self:aClLstItens,{nPosLeia,aTMP,cBloco,.F.})
Else
	InsArray({nPosLeia,aTMP,cBloco,.F.},@Self:aClLstItens,nPosD)
Endif
//Atualizar a array de tipos de dados de acordo com os valores passados

Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³AddStruct  ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para adicionar estrtura de impressao.                   º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method AddStruct(nPosLeia,nNumCol,lCab,lDelimita,aLargCol,aAlinha,aCab,aNomeCMP) Class LJCFrmtLay

Local lRet			:= .F.
Local ni			:= 0
Local nPos			:= 0
Local aTMP			:= {}
Local aTMP02		:= {}
Local nTam			:= 0

Default nNumCol	:= 0
Default lCab		:= .F.
Default lDelimita	:= .T.
Default aLargCol	:= {}
Default aAlinha	:= {}
Default aCab		:= {}
Default aNomeCMP	:= {}

If !ValType(lCab) == "L" .OR. !ValType(lDelimita) == "L" .OR. !ValType(aLargCol) == "A" .OR. !ValType(aAlinha) == "A" .OR. !ValType(aCab) == "A" .OR.ValType(aNomeCMP) # "A"
	Return lRet
Endif
//Se a posicao do leiaute nao for declarada ou se a posicao for a primeira (reservada)
If ValType(nPosLeia) # "N" .OR. Empty(nPosLeia) .OR. nPosLeia == 1
	Return lRet
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao da posicao do leiaute  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Len(Self:aClLeiaute) == 0
	//Verificar se a posicao indicada do leiaute existe, caso exista remover
	If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) > 0
		::EstruDel(nPosLeia)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alinhando o numero de colunas com o array de posicoes  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLargCol) > 0 .AND. nNumCol == 0
	nNumCol := Len(aLargCol)
ElseIf nNumCol == 0
	nNumCol := 1
Endif
aTMP := Array(nEstruLeia)
//Posicao da estrutura do leiaute
aTMP[1] := nPosLeia
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Distribuicao das colunas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aLargCol) == 0
	If nNumCol = 1
		aTMP[2] := {100}
	Else
		//Se o auto ajuste estiver desabilitado, calcular largura fixa entre as colunas, senao gravar zero para a funcao AutoAjuste fazer a distribuicao
		If !Self:lClAutoAjCol
			nTam := Round(Abs(((Self:nClTotCol / nNumCol) / Self:nClTotCol) * 100),0)
			For ni := 1 to nNumCol
				aAdd(aLargCol,nTam)
			Next ni
			aTMP[2] := aLargCol
		Else
			For ni := 1 to nNumCol
				aAdd(aLargCol,0)
			Next ni
			aTMP[2] := aLargCol	
		Endif
	Endif
Else
	aTMP[2] := aLargCol
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alinhamento das colunas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Caso o tamanho do array de alinhamento for divergente, zerar
If !Len(aAlinha) == 0 .AND. Len(aAlinha) # Len(aTMP[2])
	aAlinha := {}
Endif
//Se necessario, alimentar o array automaticamente
If Len(aAlinha) == 0
	For ni := 1 to nNumCol
		aAdd(aAlinha,"L")
	Next ni	
	aTMP[3] := aAlinha
Else
	//Validar seus conteudos
	For ni := 1 to Len(aAlinha)
		If !AllTrim(aAlinha[ni]) $ "L|C|R"
			aAlinha[ni] := "L"
		Endif
	Next ni
Endif 
aTMP[3] := aAlinha
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabecalho colunas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCab
	//Caso o tamanho do array de cabecalho for divergente, zerar
	If (!Empty(Len(aCab)) .AND. Len(aCab) # Len(aTMP[2])) .OR. Len(aCab) == 0
		aCab := {}
		lCab := .F.
	Endif
	If lCab
		//Se necessario, alimentar o array automaticamente
		If !Len(aCab) == 0
			//Validar seus conteudos
			For ni := 1 to Len(aCab)
				If ValType(aCab[ni]) # "C"
					aCab[ni] := ""
				Endif
			Next ni
		Endif 
	Endif
	aTMP[4] := lCab
	aTMP[5] := aCab
Else
	aTMP[4] := lCab
	aTMP[5]	:= {}
Endif
aTMP[6] := lDelimita
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome dos campos  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Caso o tamanho do array de cabecalho for divergente, zerar
If (!Empty(Len(aNomeCMP)) .AND. Len(aNomeCMP) # Len(aTMP[2])) .OR. Len(aNomeCMP) == 0
	aNomeCMP := {}
Endif
aTMP[7] := aNomeCMP
//Atribuir array ao controle de estrutura de leiautes
aAdd(Self:aClLeiaute,aTMP)
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetColWidthºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alterar a estrutura de posicionamentos de colunas  º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetColWidth(nPosLeia,aEstru) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0

Default nPosLeia	:= 0
Default aEstru		:= {}

If Len(aEstru) == 0 .OR. ValType(aEstru) # "A"
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
Self:aClLeiaute[nPos][2] := aEstru
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetAlign   ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alterar a estrutura de alinhamento das colunas     º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetAlign(nPosLeia,aEstru,uCmp) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0
Local nCmp			:= 0

Default nPosLeia	:= 0
Default aEstru		:= {}
Default uCmp		:= 0

If Len(aEstru) == 0 .OR. ValType(aEstru) # "A" .OR. (ValType(uCmp) # "N" .AND. ValType(uCmp) # "C")
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
Do Case
	Case ValType(uCmp) == "N"
		If !Empty(uCmp)
			nCmp := uCmp
			If nCmp > Len(Self:aClLeiaute[nPos][3]) .OR. Len(aEstru) > 1
				nCmp := 0
			Endif
		Endif
	Case ValType(uCmp) == "C"
		nCmp := aScan(::GetStruct(nPosLeia,7),{|x| AllTrim(x) == AllTrim(uCmp)})
		If nCmp == 0
			Return lRet
		Endif
EndCase
If nCmp == 0
	Self:aClLeiaute[nPos][3] := aEstru
Else
	Self:aClLeiaute[nPos][3][nCmp] := aEstru[1]
Endif
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetHeader  ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alterar a estrutura de cabecalhos das colunas      º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetHeader(nPosLeia,aEstru,uCmp) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0
Local nCmp			:= 0

Default nPosLeia	:= 0
Default aEstru		:= {}
Default uCmp		:= 0

If ValType(aEstru) # "A" .OR. (ValType(uCmp) # "N" .AND. ValType(uCmp) # "C")
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
Do Case
	Case ValType(uCmp) == "N"
		If !Empty(uCmp)
			nCmp := uCmp
			If nCmp > Len(Self:aClLeiaute[nPos][5]) .OR. Len(aEstru) > 1
				nCmp := 0
			Endif
		Endif
	Case ValType(uCmp) == "C"
		nCmp := aScan(::GetStruct(nPosLeia,7),{|x| AllTrim(x) == AllTrim(uCmp)})
		If nCmp == 0
			Return lRet
		Endif
EndCase
If Len(aEstru) == 0
	Self:aClLeiaute[nPos][4] := .F.
	Self:aClLeiaute[nPos][5] := {}
Else
	If nCmp == 0
		Self:aClLeiaute[nPos][4] := .T.
		Self:aClLeiaute[nPos][5] := aEstru
	Else
		Self:aClLeiaute[nPos][4] := .T.
		Self:aClLeiaute[nPos][5][nCmp] := aEstru	
	Endif
Endif
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetStruct  ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar uma determina estrutura da colecao        º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetStruct(nPosLeia,nOpc) Class LJCFrmtLay

Local uResp			:= {}
Local nPos			:= 0

Default nPosLeia	:= 0
Default nOpc		:= 0

If ValType(nOpc) # "N" .OR. nOpc > nEstruLeia
	Return uResp
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
If nOpc == 0
	//Retorna toda a estrutura
	uResp := Self:aClLeiaute[nPos]
Else
	//Retorna determinada posicao
	uResp := Self:aClLeiaute[nPos][nOpc]
Endif
Self:nClLeiaAtivo := nPosLeia

Return uResp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³UseHeader  ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para determinar se uma dada estrutura utiliza cabecalho º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method UseHeader(nPosLeia,lOpc) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0

Default nPosLeia	:= 0
Default lOpc		:= .F.

If ValType(lOpc) # "L"
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
Self:aClLeiaute[nPos][4] := lOpc
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³DelStruct  ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para remover alguma posicao da estrtura de impressao.	 º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method DelStruct(nPosLeia) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0
Local aTMP			:= {}
Local nTot			:= 0
Local ni			:= 0

Default nPosLeia	:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
nTot := Len(Self:aClLeiaute)
For ni := 1 to nTot
	If ni # nPos
		aAdd(aTMP,Self:aClLeiaute[ni])
	Endif
Next ni
Self:aClLeiaute := Array(0)
Self:aClLeiaute := aTMP
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ReplStru   ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para substituir alguma posicao da estrtura de impressao.º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method ReplStru(nPosLeia,aEstru,uOpc) Class LJCFrmtLay

Local lRet			:= .F.
Local nOpc			:= 0
Local nPos			:= 0

Default nPosLeia	:= 0
Default aEstru		:= .F.
Default uOpc		:= 0

If !ValType(uOpc) $ "C|N"
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
If nOpc > Len(Self:aClLeiaute[nPos])
	Return lRet
Endif
If ValType(uOpc) == "C"
	uOpc := AllTrim(Upper(uOpc))
	Do Case
		Case uOpc == "DIST"
			nOpc := 2
		Case uOpc == "ALIG"
			nOpc := 3
		Case uOpc == "HEADER"
			nOpc := 4
		Case uOpc == "HEADERS"
			nOpc := 5
		Case uOpc == "DELIMIT"
			nOpc := 6
		Case uOpc == "FIELDS"
			nOpc := 7
		Otherwise
			Return lRet
	EndCase
Else
	nOpc := uOpc
	If nOpc > nEstruLeia
		Return lRet
	Endif
Endif
If nOpc == 0
	If Len(aEstru) == 0 .OR. ValType(aEstru) # "A" .OR. Len(aEstru) # nEstruLeia
		Return lRet
	Endif
	//Validar tipos de dados da array de estrutura de leiaute
	If !ValType(aEstru[1]) == "N" .OR. !ValType(aEstru[2]) == "A" .OR. !ValType(aEstru[3]) == "A" .OR. !ValType(aEstru[4]) == "L" .OR. ;
		!ValType(aEstru[5]) == "A" .OR. !ValType(aEstru[6]) == "L"
		
		Return lRet
	Endif	
	//Retorna toda a estrutura
	Self:aClLeiaute[nPos] := aEstru
Else
	//Valida tipo de dados do campo
	If !Empty(Self:aClLeiaute[nPos][nOpc]) .AND. ValType(Self:aClLeiaute[nPos][nOpc]) # ValType(aEstru)
		Return lRet
	Endif	
	//Valida opcoes de cabecalho
	If nOpc == 4
		If Len(Self:aClLeiaute[nPos][5]) == 0 .AND. aEstru
			Return lRet
		Endif
	ElseIf nOpc == 5
		If (ValType(aEstru) # "A" .OR. Len(aEstru) == 0) .AND. Self:aClLeiaute[nPos][4]
			Self:aClLeiaute[nPos][4] := .F.
		Else
			If ValType(aEstru) == "A" .AND. Len(aEstru) > 0 .AND. !Self:aClLeiaute[nPos][4]
				Self:aClLeiaute[nPos][4] := .T.
			Endif		
		Endif
	Endif
	//Retorna determinada posicao
	Self:aClLeiaute[nPos][nOpc] := aEstru
Endif
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³FindFile   ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para permitir que o usuario procure e defina qual o     º±±
±±º          ³arquivo de destino a ser gerado.                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method FindFile(cPath) Class LJCFrmtLay

Local lRet				:= .F.
Local cStartPath		:= IIf(Right(GetSrvProfString("StartPath",""),1)=="\",GetSrvProfString("StartPath",""),GetSrvProfString("StartPath","")+"\")
Local aPath				:= Array(4)
Local cArqTMP			:= ""
Local cTipoArq    		:= ""
Local lOk				:= .T.
                       
Default cPath			:= ""

If !cValToChar(Self:nClTipo) $ "1|3"
	Return lRet
Endif
If !Empty(cPath)
	SplitPath(cPath,@aPath[1],@aPath[2],@aPath[3],@aPath[4])
	aEval(aPath,{|x| IIf(Empty(x), lOk := .F.,.T.)})
	//Indica que o path nao esta completo
	If !lOk
		If !Empty(aPath[1]) .OR. !Empty(aPath[2])
			cPath := AllTrim(aPath[1] + aPath[2])
		Else
			cPath := ""
		Endif
		lOk := .T.
	Else
		If !File(cPath)
			ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0002 + AllTrim(cPath) + STR0003) //", o arquivo sugerido ("###") naõ existe!"
			Return lRet
		Endif
		If Self:nClTipo == 1
			If AllTrim(Upper(aPath[4])) # ".TXT" .AND. AllTrim(Upper(aPath[4])) # ".LOG"
				ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0004) //", para geração de arquivos texto, a extensão do arquivo deve ser TXT ou LOG."
				Return lRet
			Endif
		ElseIf Self:nClTipo == 3
			If AllTrim(Upper(aPath[4])) # ".CSV"
				ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0005) //", para geração de arquivos texto delimitados, a extensão do arquivo deve ser CSV."
				Return lRet
			Endif
		Endif
		//Nao perguntar sobre o arquivo, jah que este foi passado e validado
		lOk := .F.
		cArqTMP := AllTrim(cPath)
	Endif
	aPath := {}
Endif
If lOk
	If Self:nClTipo == 1
		cTipoArq := STR0016 //"Arquivos Texto (*.TXT) |*.txt| Arquivos LOG (*.LOG) |*.log|"
	ElseIf Self:nClTipo == 3
		cTipoArq := STR0017 //"Arquivos CSV (*.CSV) |*.csv|"
	Endif
	cArqTMP := cGetFile(cTipoArq,IIf(!Empty(cPath),cPath,Self:cClDirDest))
	If Empty(cArqTMP)
		Return lRet
	Endif
Endif
aPath := Array(4)
SplitPath(cArqTMP,@aPath[1],@aPath[2],@aPath[3],@aPath[4])
Self:cClDirDest := aPath[1] + aPath[2]
Self:cClArqDest := aPath[3] + aPath[4]

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetFile    ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para permitir que o usuario defina qual o arquivo de    º±±
±±º          ³destino a ser gerado.                                          º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetFile(cArq) Class LJCFrmtLay

Local lRet				:= .F.
Local lOk				:= .T.
Local aPath				:= Array(4)
Local cPath				:= ""
Local cArqTMP			:= ""

Default cArq			:= ""

If !cValToChar(Self:nClTipo) $ "1|3"
	Return lRet
Endif
If !Empty(cArq)
	SplitPath(cArq,@aPath[1],@aPath[2],@aPath[3],@aPath[4])
	aEval(aPath,{|x| IIf(Empty(x), lOk := .F.,.T.)})
	//Verificar se o caminho existe
	If (Empty(aPath[1]) .AND. Empty(aPath[2]))
		If Self:lClShowFile
			ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0006 + AllTrim(aPath[1] + aPath[2]) + STR0007) //", o caminho sugerido ("###") não existe!"
		Endif
		Return lRet
	Endif
	//Indica que o path nao esta completo
	If !lOk
		If !Empty(aPath[1]) .OR. !Empty(aPath[2])
			cPath := AllTrim(aPath[1] + aPath[2])
		Else
			cPath := ""
		Endif
	Else
		cPath := AllTrim(aPath[1] + aPath[2])
		cArqTMP := AllTrim(aPath[3] + aPath[4])
		If File(cPath + cArqTMP) .AND. Self:lClShowFile
			If !ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0002 + AllTrim(cPath + cArqTMP) + STR0008,.T.) //", o arquivo sugerido ("###") já existe, deseja sobreescrevê-lo?"
				Return lRet
			Endif
		Endif
		If Self:nClTipo == 1
			If AllTrim(Upper(aPath[4])) # ".TXT" .AND. AllTrim(Upper(aPath[4])) # ".LOG"
				If Self:lClShowFile
					ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0004) //", para geração de arquivos texto, a extensão do arquivo deve ser TXT ou LOG."
				Endif
				Return lRet
			Endif
		ElseIf Self:nClTipo == 3
			If AllTrim(Upper(aPath[4])) # ".CSV"
				If Self:lClShowFile
					ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0005) //", para geração de arquivos texto delimitados, a extensão do arquivo deve ser CSV."
				Endif
				Return lRet
			Endif
		Endif
	Endif
	aPath := {}
Endif
Self:cClDirDest := cPath
Self:cClArqDest := cArqTMP

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³OpenFile   ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para permitir que o usuario defina qual o arquivo de    º±±
±±º          ³destino a ser gerado.                                          º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method OpenFile() Class LJCFrmtLay

Local lRet				:= .F.
Local cArqTMP			:= ""

If !cValToChar(Self:nClTipo) $ "1|3"
	Return lRet
Endif
If Empty(Self:cClDirDest) .OR. Empty(Self:cClArqDest)
	Return lRet
Endif
cArqTMP := AllTrim(Self:cClDirDest + Self:cClArqDest)
If !File(cArqTMP)
	If Self:lClShowFile
		ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0009 + cArqTMP + STR0010) //", o arquivo "###" não pode ser aberto!"
	Endif
	Return lRet
Endif
ShellExecute("open",cArqTMP,"","",1)

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Exec       ºAutor  ³Vendas Clientes       º Data ³  20/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para colocar em acao o resultado das configuracoes      º±±
±±º          ³definidas pelo usuario na formatacao de layout                 º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method Exec() Class LJCFrmtLay

Local lRet				:= .F.
Local aLeiaOK			:= {}
Local aDadosOK			:= {}
Local ni				:= 0
Local nx				:= 0
Local aTMP				:= {}
Local lOk				:= .T.
Local nPos				:= 0
Local nOpc				:= 0
Local uResp				:= Nil
Local nTamPapel			:= 0
Local cArq				:= ""

If !cValToChar(Self:nClTipo) $ "0|1|2|3|4" .OR. Empty(Self:nClTotCol)
	Return lRet
Endif
If !AllTrim(Self:cClPaperSize) $ "P|M|G"
	ExibeMens(STR0011 + Self:cClPaperSize) //"Tamanho invalido de papel : "
	Return lRet
Endif
If cValToChar(Self:nClTipo) $ "1|3"
	If Empty(Self:cClDirDest) .OR. Empty(Self:cClArqDest)
		ExibeMens(STR0012) //"Para o tipo definido de formato é necessário definir o arquivo de destino!"
		Return lRet
	Endif
	cArq := Self:cClDirDest + Self:cClArqDest
Endif
//Validar os arrays contidos em cada estrutura de leiaute
aTMP := Self:aClLeiaute
For ni := 1 to Len(aTMP)
	lOk := .T.
	If Len(aTMP[ni][2]) == Len(aTMP[ni][3])
		//Validar conteudo da distribuicao das colunas
		For nx := 1 to Len(aTMP[ni][2])
			If ValType(aTMP[ni][2][nx]) # "N"
				lOk := .F.
				Exit
			Endif
		Next nx
		//Validar o conteudo dos alinhamentos
		For nx := 1 to Len(aTMP[ni][3])
			If ValType(aTMP[ni][3][nx]) # "C"
				If !aTMP[ni][3][nx] $ "L|C|R"
					lOk := .F.
					Exit
				Endif
			Endif
		Next nx
	Else
		lOk := .F.
	Endif
	If lOk .AND. aTMP[ni][4]
		If Len(aTMP[ni][2]) == Len(aTMP[ni][5])
			//Validar conteudo da distribuicao das colunas
			For nx := 1 to Len(aTMP[ni][5])
				If ValType(aTMP[ni][5][nx]) # "C"
					aTMP[ni][4] := .F.
					Exit
				Endif
			Next nx			
		Else
			//Desabilitar o cabecalho
			aTMP[ni][4] := .F.
		Endif
	Endif
	If lOk
		aAdd(aLeiaOk,aTMP[ni])
	Endif
Next ni
If Len(aLeiaOk) == 0
	Return lRet
Endif
//Utilizar apenas os itens de leiaute que estao validados para a impressao dos dados
aTMP := Self:aClLstItens
For ni := 1 to Len(aTMP)
	If (nPos := aScan(aLeiaOk,{|x| x[1] == aTMP[ni][1]})) > 0
		//Validar numero de colunas x dados
		If Len(aLeiaOk[nPos][2]) == Len(aTMP[ni][2])
			//Verificar a existencia de um filtro e caso exista, considerar apenas os registros marcados na filtragem
			If aScan(Self:aClFiltro,{|x| x[1] == aTMP[ni][1] .AND. IIf(x[2] == "0",.T.,AllTrim(x[2]) == AllTrim(aTMP[ni][3]))}) == 0
				aAdd(aDadosOK,aTMP[ni])
			Else
				//Caso exista o filtro, considerar apenas os marcados
				If aTMP[ni][4]
					aAdd(aDadosOK,aTMP[ni])
				Endif
			Endif
		Endif
	Endif
Next ni
If Len(aLeiaOk) == 0 .OR. Len(aDadosOK) == 0
	Return lRet
Endif
Do Case 
	Case Self:nClTipo == 0		//Retorna texto formatado
		nOpc := 0
	Case Self:nClTipo == 1		//Grava arquivo texto
		nOpc := 0
	Case Self:nClTipo == 2		//Gera relatorio
		nOpc := 2
	Case Self:nClTipo == 3		//Grava arquivo CSV
		nOpc := 3
	Case Self:nClTipo == 4		//Imprimir em ECF
		nOpc := 1
EndCase
Do Case 
	Case Self:cClPaperSize == "P"
		nTamPapel := 1
	Case Self:cClPaperSize == "M"
		nTamPapel := 2
	Case Self:cClPaperSize == "G"
		nTamPapel := 3
	Otherwise
		nTamPapel := 3
EndCase
//Caso o ajuste automatico da distribuicao das colunas tenha sido configurado para sim
If Self:lClAutoAjCol
	aTMP := AutoAjuste(aLeiaOk,aDadosOk,Self:lClUseHeadCW)
	If Len(aTMP) # 0
		For ni := 1 to Len(aTMP)
			If (nPos := aScan(aLeiaOK,{|x| x[1] == aTMP[ni][1]})) > 0
				aLeiaOk[nPos][2] := aTMP[ni][2]
			Endif
		Next ni
	Endif
Endif
uResp := FrmLeiaute(nOpc,aLeiaOK,aDadosOk,Self:nClTotCol,Self:cClDelCol,Self:cClDelLin,Self:lClUsaDel,"",Self:cClTitulo,nTamPapel,Self:cClOrienta,Self:nClPosCab)
If cValToChar(Self:nClTipo) $ "1|3"
	If File(cArq)
		fErase(cArq)
	Endif
	MemoWrite(cArq,uResp)
	If Self:lClShowFile
		Self:OpenFile()
	Endif
ElseIf cValToChar(Self:nClTipo) == "4" .AND. Empty(uResp)
	ExibeMens(AllTrim(UsrRetName(__cUserID)) + STR0013) //", houve algum problema na impressão do relatório gerencial!"
Endif

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PrintLine  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha separadora.                     º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method PrintLine(nPosD,nPosLeia) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0

Default nPosLeia		:= 1
Default nPosD			:= 0

If (Empty(nPosLeia) .AND. Empty(Self:nClLeiaAtivo)) .OR. ValType(nPosD) # "N"
	Return lRet
Endif
//Validar existencia e colunas do leiaute
If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Else
	//Utilizar apenas leiautes com 1 coluna
	If Len(Self:aClLeiaute[nPos][2]) # 1
		Return lRet
	Endif
Endif
nPos := IIf(!Empty(nPosLeia),nPosLeia,Self:nClLeiaAtivo)
If Empty(nPosD)
	aAdd(Self:aClLstItens,{nPos,{"=CLINHASD"},"0",.F.})
	If Self:nClTipo == 2
		If Self:cClDelCol == "_"
			aAdd(Self:aClLstItens,{nPos,{"=CLBRANCO"},"0",.F.})
		Endif
	Endif
Else
	InsArray({nPos,{"=CLINHASD"},"0",.F.},@Self:aClLstItens,nPosD)
	If Self:nClTipo == 2
		If Self:cClDelCol == "_"
			InsArray({nPos,{"=CLBRANCO"},"0",.F.},@Self:aClLstItens,nPosD + 1)
		Endif
	Endif	
Endif
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PrintText  ºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha contendo o texto definido.      º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method PrintText(cTexto,nPosD,nPosLeia) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0

Default nPosLeia		:= 1
Default cTexto			:= ""
Default nPosD			:= 0

If (Empty(nPosLeia) .AND. Empty(Self:nClLeiaAtivo)) .OR. Empty(cTexto) .OR. ValType(cTexto) # "C" .OR. ValType(nPosD) # "N"
	Return lRet
Endif
//Validar existencia e colunas do leiaute
If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Else
	//Utilizar apenas leiautes com 1 coluna
	If Len(Self:aClLeiaute[nPos][2]) # 1
		Return lRet
	Endif
Endif
If Empty(nPosD)
	aAdd(Self:aClLstItens,{nPos,{cTexto},"0",.F.})
Else
	InsArray({nPos,{cTexto},"0",.F.},@Self:aClLstItens,nPosD)
Endif
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PrintLineWDºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha separadora com delimitador.     º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method PrintLineWD(nPosD,nPosLeia) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0

Default nPosLeia		:= 1
Default nPosD			:= 0

If (Empty(nPosLeia) .AND. Empty(Self:nClLeiaAtivo)) .OR. ValType(nPosD) # "N"
	Return lRet
Endif
//Validar existencia e colunas do leiaute
If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Else
	//Utilizar apenas leiautes com 1 coluna
	If Len(Self:aClLeiaute[nPos][2]) # 1
		Return lRet
	Endif
Endif
nPos := IIf(!Empty(nPosLeia),nPosLeia,Self:nClLeiaAtivo)
If Empty(nPosD)
	aAdd(Self:aClLstItens,{nPos,{"=CLINHA"},"0",.F.})
	If Self:nClTipo == 2
		If Self:cClDelCol == "_"
			aAdd(Self:aClLstItens,{nPos,{"=CLBRANCOCD"},"0",.F.})
		Endif
	Endif
Else
	InsArray({nPos,{"=CLINHA"},"0",.F.},@Self:aClLstItens,nPosD)
	If Self:nClTipo == 2
		If Self:cClDelCol == "_"
			InsArray({nPos,{"=CLBRANCOCD"},"0",.F.},@Self:aClLstItens,nPosD + 1)
		Endif
	Endif	
Endif
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PrintBlank ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha em branco.                      º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method PrintBlank(nPosLeia,nQtde) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local ni				:= 0

Default nPosLeia		:= 1
Default nQtde			:= 1

If Empty(nPosLeia) .AND. Empty(Self:nClLeiaAtivo)
	Return lRet
Endif
//Validar existencia e colunas do leiaute
If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Else
	//Utilizar apenas leiautes com 1 coluna
	If Len(Self:aClLeiaute[nPos][2]) # 1
		Return lRet
	Endif
Endif
nPos := IIf(!Empty(nPosLeia),nPosLeia,Self:nClLeiaAtivo)
For ni := 1 to nQtde
	aAdd(Self:aClLstItens,{nPos,{"=CLBRANCO"},"0",.F.})
Next ni
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PrintBlaWD ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha em branco com delimitadores.    º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method PrintBlaWD(nPosLeia,nQtde) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local ni				:= 0

Default nPosLeia		:= 1
Default nQtde			:= 1

If Empty(nPosLeia) .AND. Empty(Self:nClLeiaAtivo)
	Return lRet
Endif
//Validar existencia e colunas do leiaute
If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Else
	//Utilizar apenas leiautes com 1 coluna
	If Len(Self:aClLeiaute[nPos][2]) # 1
		Return lRet
	Endif
Endif
nPos := IIf(!Empty(nPosLeia),nPosLeia,Self:nClLeiaAtivo)
For ni := 1 to nQtde
	aAdd(Self:aClLstItens,{nPos,{"=CLBRANCOCD"},"0",.F.})
Next ni
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³PrintInfo  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha com alguma informacao pre-defi- º±±
±±º          ³nida com comentarios.                                          º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method PrintInfo(nPosLeia,nOpc) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local cComando			:= ""

Default nPosLeia		:= 1
Default nPos			:= 0

If (Empty(nPosLeia) .AND. Empty(Self:nClLeiaAtivo)) .OR. Empty(nOpc)
	Return lRet
Endif
//Validar existencia e colunas do leiaute
If (nPos := aScan(Self:aClLeiaute,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Else
	//Utilizar apenas leiautes com 1 coluna
	If Len(Self:aClLeiaute[nPos][2]) # 1
		Return lRet
	Endif
Endif
nPos := IIf(!Empty(nPosLeia),nPosLeia,Self:nClLeiaAtivo)
Do Case
	Case nOpc == 1
		cComando := "=CCNPJ"		//CNPJ
	Case nOpc == 2
		cComando := "=CINSC"		//INSCRICAO ESTADUAL
	Case nOpc == 3
		cComando := "=CEND"			//ENDERECO
	Case nOpc == 4
		cComando := "=CCOMPEND"		//COMPLEMENTO DE ENDERECO
	Case nOpc == 5
		cComando := "=CEMPRESA"		//NOME DA EMPRESA
	Otherwise
		Return lRet
EndCase
aAdd(Self:aClLstItens,{nPos,{cComando},"0",.F.})
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetPositionºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para imprimir uma linha com alguma informacao pre-defi- º±±
±±º          ³nida com comentarios.                                          º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetPosition() Class LJCFrmtLay

Return ::nClLeiaAtivo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetType    ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alterar o tipo de impressao do leiaute.            º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetType(nTipo) Class LJCFrmtLay

Default nTipo		:= 0

If ValType(nTipo) # "N"
	If ValType(nTipo) == "C" .AND. nTipo $ "0123456789"
		nTipo := cValToChar(nTipo)
	Else
		nTipo := 0
	Endif	
Endif
If !cValToChar(nTipo) $ "0|1|2|3|4"
	nTipo := 0
Endif
Self:nClTipo := nTipo

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetFile    ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar o arquivo a ser gravado definido pelo     º±±
±±º          ³usuario.                                                       º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetFile() Class LJCFrmtLay

Local cArq			:= ""

If !Empty(Self:cClDirDest) .AND. !Empty(Self:cClArqDest)
	cArq := Self:cClDirDest + Self:cClArqDest
Endif

Return cArq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ShowFile   ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para que o usuario defina se o arquivo gerado devera    º±±
±±º          ³ser mostrado ou nao. Por padrao, seu valor eh sim.             º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method ShowFile(lOpc) Class LJCFrmtLay

Default lOpc		:= .T.

Self:lClShowFile := lOpc

Return Nil 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetTitle   ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para que alterar o titulo do relatorio que sera gerado. º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetTitle(cTitulo) Class LJCFrmtLay

Local lRet			:= .F.

Default cTitulo 	:= ""

If ValType(cTitulo) # "C"
	Return lRet
Endif
Self:cClTitulo := cTitulo

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetColDel  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar o caracter separador de colunas.        º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetColDel(cCarac) Class LJCFrmtLay

Local lRet			:= .F.

Default cCarac		:= ""

If ValType(cCarac) # "C"
	Return lRet
Endif
cCarac := AllTrim(Substr(cCarac,1,1))
Self:cClDelCol := cCarac

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetLinDel  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar o caracter separador de linha.          º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetLinDel(cCarac) Class LJCFrmtLay

Local lRet			:= .F.

Default cCarac		:= ""

If ValType(cCarac) # "C"
	Return lRet
Endif
cCarac := AllTrim(Substr(cCarac,1,1))
Self:cClDelLin := cCarac

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetPageSizeºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar o tamanho da pagina a ser impresso.     º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetPageSize(cTaman) Class LJCFrmtLay

Local lRet			:= .F.
Local nTotCol		:= 0

Default cTaman		:= "G"

If Empty(cTaman) .OR. ValType(cTaman) # "C"
	Return lRet
Endif
cTaman := AllTrim(Substr(cTaman,1,1))
If !cTaman $ "P|M|G"
	Return lRet
Endif
Self:cClPaperSize := cTaman
//Ajustar o numero de colunas caso o total da area nao tenha sido definido pelo usuario
If !Self:lClTotColDef .AND. Self:nClTipo == 2 //Relatorio
	Do Case
		Case Self:cClOrienta == "P"
			Do Case 
				Case Self:cClPaperSize == "P"
					nTotCol := nLPagP01
				Case Self:cClPaperSize == "M"
					nTotCol := nLPagP02
				Case Self:cClPaperSize == "G"
					nTotCol := nLPagP03
			EndCase
		Case Self:cClOrienta == "L"
			Do Case 
				Case Self:cClPaperSize == "P"
					nTotCol := nLPagL01
				Case Self:cClPaperSize == "M"
					nTotCol := nLPagL02
				Case Self:cClPaperSize == "G"
					nTotCol := nLPagL03
			EndCase
		Otherwise
			nTotCol := nLPagP01
	EndCase
	If nTotCol # Self:nClTotCol
		Self:nClTotCol := nTotCol
	Endif
Endif

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetPageOri ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar a orientacao da pagina a ser impressa.  º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetPageOri(cOrienta) Class LJCFrmtLay

Local lRet			:= .F.
Local nTotCol		:= 0

Default cOrienta	:= "P"

If Empty(cOrienta) .OR. ValType(cOrienta) # "C"
	Return lRet
Endif
cOrienta := AllTrim(Substr(cOrienta,1,1))
If !cOrienta $ "P|L"
	Return lRet
Endif
Self:cClOrienta := cOrienta
//Ajustar o numero de colunas caso o total da area nao tenha sido definido pelo usuario
If !Self:lClTotColDef .AND. Self:nClTipo == 2 //Relatorio
	Do Case
		Case Self:cClOrienta == "P"
			Do Case 
				Case Self:cClPaperSize == "P
					nTotCol := nLPagP01
				Case Self:cClPaperSize == "M"
					nTotCol := nLPagP02
				Case Self:cClPaperSize == "G"
					nTotCol := nLPagP03
			EndCase
		Case Self:cClOrienta == "L"
			Do Case 
				Case Self:cClPaperSize == "P
					nTotCol := nLPagL01
				Case Self:cClPaperSize == "M"
					nTotCol := nLPagL02
				Case Self:cClPaperSize == "G"
					nTotCol := nLPagL03
			EndCase
		Otherwise
			nTotCol := nLPagP01
	EndCase
	If nTotCol # Self:nClTotCol
		Self:nClTotCol := nTotCol
	Endif
Endif

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetTotCol  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar o total de colunas da area de impressao.º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetTotCol(nLarg) Class LJCFrmtLay

Local lRet			:= .F.

Default nLarg		:= 0

If Empty(nLarg) .OR. ValType(nLarg) # "N"
	Return lRet
Endif
nLarg := Round(Abs(nLarg),0)
Self:nClTotCol := nLarg

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³AutoAdjCol ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para definir se a largura das colunas do leiaute deve   º±±
±±º          ³ser ajustado automaticamente de acordo com o tamanho dos       º±±
±±º          ³dados contidos dentro da estrutura.Funciona soh com pos.zeradasº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method AutoAdjCol(nPosLeia,lOpc) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0

Default nPosLeia	:= 0
Default lOpc		:= .F.

If ValType(lOpc) # "L"
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
Self:lClAutoAjCol := lOpc
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetHeadCW  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar se o cabecalho de um determinado leiauteº±±
±±º          ³deve ser usado na composicao da largura das colunas, no caso   º±±
±±º          ³do emprego do ajuste auto., caso o cab. seja maior que o dado. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetHeadCW(lOpc) Class LJCFrmtLay

Local lRet			:= .F.

Default lOpc		:= .T.

If ValType(lOpc) # "L"
	Return lRet
Endif
Self:lClUseHeadCW := lOpc

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetMainHeadºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para configurar com qual cabecalhos de estrutura de     º±±
±±º          ³leiaute sera montado o cabecalho principal do relatorio.       º±±
±±º          ³Aplicavel apenas para relatorios.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetMainHead(nPosLeia) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0

Default nPosLeia	:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
//Se tiver cabecalho
If Self:aClLeiaute[nPos][4]
	Self:nClPosCab := nPos
Endif
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetPageSizeºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar o tamanho da pagina atual.                º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetPageSize() Class LJCFrmtLay

Return Self:cClPaperSize

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetPageOri ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar a orientacao de paginal atual.            º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetPageOri()  Class LJCFrmtLay

Return Self:cClOrienta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetQry     ºAutor  ³Vendas Clientes       º Data ³  25/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para associar uma instrucao SQL a um leiaute.           º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetQry(nPosLeia,cQry,lParser,lExec,lGrava,lFormata,lCab) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0
Local lOk			:= .T.

Default nPosLeia	:= 0
Default cQry		:= ""
Default lParser	:= .T.
Default lExec		:= .F.
Default lFormata	:= .F.
Default lGrava		:= .F.
Default lCab		:= .F.

#IFNDEF TOP
	Return lRet
#ENDIF
If Empty(cQry) .OR. ValType(cQry) # "C" .OR. ValType(lParser) # "L" .OR. ValType(lExec) # "L" .OR. ValType(lFormata) # "L"
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.)
	Return lRet
Else
	nPos := Self:nClPos
Endif
//Validar conteudo da instrucao SQL
If At("UPDATE ",cQry) > 0 .OR. At("INSERT ",cQry) > 0 .OR. At("ALTER ",cQry) > 0 .OR. At("DELETE ",cQry) > 0 .OR. At("DROP ",cQry) > 0
	Return lRet
Endif
If At("SELECT ",cQry) == 0 .OR. At("FROM ",cQry) == 0
	Return lRet
Endif
//Verificar se jah existe uma query nesta posicao, se existir apagar a referencia e excluir os dados
If (nPos := aScan(Self:aClQry,{|x| x[1] == nPosLeia})) > 0
	Self:DelQry(Self:aClQry[nPos][1],.T.,1)
Endif	
aAdd(Self:aClQry,{nPosLeia,cQry,lParser,lFormata,lCab})
//Verificar se a query deve ser executada
If lExec
	If !Self:ExecQry(nPosLeia,lGrava)
		Return lRet
	Endif
Endif
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³DelQry     ºAutor  ³Vendas Clientes       º Data ³  25/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para limpar os dados gerados pela execucao de uma       º±±
±±º          ³instrucao SQL                                                  º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method DelQry(nPosLeia,lApagaData,nNivel) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local nPos02			:= 0
Local cBloco 			:= 0
Local aTMP				:= {}
Local ni				:= 0

Default nPosLeia		:= 0
Default lApagaData		:= .T.
Default nNivel			:= 1

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
//Remover item da lista de query associada a leiaute
If aScan(Self:aClQry,{|x| x[1] == nPosLeia}) > 0
	If nNivel == 1
		aTMP := {}
		For ni := 1 to Len(Self:aClQry)
			If Self:aClQry[ni][1] # nPosLeia
				aAdd(aTMP,Self:aClQry[ni])
			Endif
		Next ni
		Self:aClQry := aTMP
	Endif
	//Caso exista query gravada
	If aScan(Self:aClQryGrv,{|x| x[1] == nPosLeia}) > 0
		cBloco := Self:GetQryBlock(nPosLeia)
		If nNivel <= 2
			//Remover item da lista de armazenamento de resultado de query
			aTMP := {}
			For ni := 1 to Len(Self:aClQryData)
				If Self:aClQryData[ni][1] # nPosLeia
					aAdd(aTMP,Self:aClQryData[ni])
				Endif
			Next ni
			Self:aClQryData := aClone(aTMP)
		Endif
		If nNivel <= 3
			//Remover item da lista de querys gravadas
			aTMP := {}
			For ni := 1 to Len(Self:aClQryGrv)
				If Self:aClQryGrv[ni][1] # nPosLeia
					aAdd(aTMP,Self:aClQryGrv[ni])
				Endif
			Next ni
			Self:aClQryGrv := aClone(aTMP)
			//Remover dos itens do leiaute que foram gravados
			If lApagaData .AND. !Empty(cBloco)
				aTMP := {}
				For ni := 1 to Len(Self:aClLstItens)
					If Self:aClLstItens[ni][1] == nPosLeia .AND. Self:aClLstItens[ni][3] # cBloco
						aAdd(aTMP,Self:aClLstItens[ni])
					ElseIf Self:aClLstItens[ni][1] # nPosLeia
						aAdd(aTMP,Self:aClLstItens[ni])
					Endif
				Next ni
				Self:aClLstItens := aClone(aTMP)
			Endif
		Endif
	Endif
Endif
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ExecQry    ºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para gravar a query no array intermediario de dados de  º±±
±±º          ³resultado de querys                                            º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method ExecQry(nPosLeia,lGravaData) Class LJCFrmtLay

Local lRet				:= .F.
Local cQry				:= ""
Local nPos				:= 0
Local cAlias			:= GetNextAlias()
Local cBloco			:= Soma1(Self:cClQryBloco,4)
Local ni				:= 0
Local aTMP				:= {}
Local lCabPad			:= .F.
Local aCabPad			:= {}
Local nCmpLeia			:= 0
Local nCmpAlin			:= 0
Local lCmpFrmt			:= 0
Local aCmpFrmt			:= {}
Local nPosF				:= 0
Local uValor			:= Nil
Local nRegAtu			:= 0
Local lNomeCmp			:= .F.
Local aNomeCmp			:= {}
Local aAreaSX3			:= SX3->(GetArea())
Local cTipo				:= ""
Local cPTN				:= "@E 9,999,999.99"

Default nPosLeia		:= 0
Default lGravaData		:= .F.

If !VldPosLeia(nPosLeia,Self:aClLeiaute)
	Return lRet
Endif
//Caso nao exista query definida para o leiaute definido
If (nPos := aScan(Self:aClQry,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Endif
lCab := Self:aClQry[nPos][5]
dbSelectArea("SX3")
SX3->(dbSetOrder(2))
//Determinar o numero de campos e alinhamento
nCmpLeia := Len(::GetStruct(nPosLeia,2))
nCmpAlin := Len(::GetStruct(nPosLeia,3))
//Se o cabecalho deve ser montado na execucao da query
If lCab
	lCabPad	:= ::GetStruct(nPosLeia,4)
	aCabPad	:= ::GetStruct(nPosLeia,5)
	//Caso jah exista um cabecalho padrao definido, descartar
	If lCabPad .AND. Len(aCabPad) > 0
		lCab := .F.
	Endif
Endif
//Definir se os nomes dos campos devem ser determinados
lNomeCmp := Len(::GetStruct(nPosLeia,7)) == 0
//Instrucao SQL
cQry := Self:aClQry[nPos][2]
If !Self:aClQry[nPos][3]
	dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAlias,.T.,.F.)
Else
	dbUseArea(.T.,__cRDD,TcGenQry(,,ChangeQuery(cQry)),cAlias,.T.,.F.)
Endif
(cAlias)->(dbGoTop())
//Apagar registros anteriores
Self:DelQry(Self:aClQry[nPos][1],.T.,2)
//Alimentar array intermediaria
If !(cAlias)->(Eof())
	aAdd(Self:aClQryGrv,{nPosLeia,cBloco,.F.})
	//Se o numero de campos do leiaute estiver como 0 ou 1, acertar em relacao ao numero de campos da query
	If nCmpLeia == 0 .OR. nCmpLeia == 1
		aTMP := {}
		For ni := 1 to (cAlias)->(FCount())
			aAdd(aTMP,0)
		Next ni
		Self:ReplStru(nPosLeia,aTMP,"DIST")
		nCmpLeia := Len(::GetStruct(nPosLeia,2))
		//Se o numero de campos de alinhamento estiver divergente, acertar
		If nCmpAlin # nCmpLeia
			aTMP := {}
			For ni := 1 to nCmpLeia
				aAdd(aTMP,"L")
			Next ni
			Self:ReplStru(nPosLeia,aTMP,"ALIG")
		Endif
	Endif
	//Se os nomes dos campos nao estiverem definidos, definir
	If lNomeCmp
		aTMP := {}
		For ni := 1 to (cAlias)->(FCount())
			aAdd(aTMP,(cAlias)->(FieldName(ni)))
		Next ni	
		Self:ReplStru(nPosLeia,aTMP,"FIELDS")
	Endif
	//Formatacao de dados e montagem de cabecalho caso nao definido
	aTMP := {}
	If Self:aClQry[nPos][4] .OR. lCab
		For ni := 1 to (cAlias)->(FCount())
			If SX3->(dbSeek(AllTrim((cAlias)->(FieldName(ni)))))
				If Self:aClQry[nPos][4]
					TcSetField(cAlias,SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL)
					If !Empty(SX3->X3_PICTURE)
						lCmpFrmt := .T.
						aAdd(aCmpFrmt,{SX3->X3_CAMPO,SX3->X3_PICTURE})
					Endif
				Endif
				If lCab
					aAdd(aTMP,Upper(SX3->X3_TITULO))
				Endif
			Else
				If Self:aClQry[nPos][4]
					cTipo := cDataType((cAlias)->(FieldGet(ni)))
					Do Case 
						Case cTipo == "N"
							TcSetField(cAlias,(cAlias)->(FieldName(ni)),cTipo,18,2)
							lCmpFrmt := .T.
							aAdd(aCmpFrmt,{(cAlias)->(FieldName(ni)),cPTN})
					EndCase
				Endif
				If lCab
					aAdd(aTMP,(cAlias)->(FieldName(ni)))
				Endif
			Endif
		Next ni
		//Se o numero de campos for identico ao numero de cabecalhos
		If lCab .AND. nCmpLeia == Len(aTMP)
			Self:ReplStru(nPosLeia,.T.,"HEADER")
			Self:ReplStru(nPosLeia,aTMP,"HEADERS")
			//Acertar alinhamento
			aTMP := {}
		Endif
	Endif
	nRegAtu := Self:GetTotRec() + 1
	Do While !(cAlias)->(Eof())
		aTMP := {}
		For ni := 1 to (cAlias)->(FCount())
			uValor := (cAlias)->(FieldGet(ni))
			If lCmpFrmt
				If (nPosF := aScan(aCmpFrmt,{|x| AllTrim(x[1]) == AllTrim((cAlias)->(FieldName(ni)))})) == 0 .OR. (Empty(uValor) .AND. ValType(uValor) # "N")
					aAdd(aTMP,uValor)
				Else
					aAdd(aTMP,Transform(uValor,aCmpFrmt[nPosF][2]))
				Endif
			Else
				aAdd(aTMP,uValor)
			Endif
		Next ni
		If !lGravaData
			aAdd(Self:aClQryData,{nPosLeia,aTMP,0})
		Else
			aAdd(Self:aClQryData,{nPosLeia,aTMP,nRegAtu})
			Self:Add(nPosLeia,aTMP,cBloco,.F.)
			nRegAtu++
		Endif
		(cAlias)->(dbSkip())
	EndDo
Else
	aAdd(Self:aClQryGrv,{nPosLeia,cBloco,.T.})	//Processado, mas sem registros encontrados
Endif
FechaArqT(cAlias)
RestArea(aAreaSX3)
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³RecQry     ºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para gravar o resultado gravado na array de dados inter-º±±
±±º          ³mediaria para a array de dados padrao.                         º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method RecQry(nPosLeia) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local cBloco			:= ""
Local lSemReg			:= .F.
Local ni				:= 0
Local nTotREG			:= 0
Local nRegAtu			:= Self:GetTotRec() + 1

Default nPosLeia		:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute)
	Return lRet
Endif
//Caso nao exista query definida para o leiaute definido
If (nPos := aScan(Self:aClQry,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Endif
//Caso nao exista query gravada para o leiaute definido
If (nPos := aScan(Self:aClQryGrv,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Endif
cBloco := Self:aClQryGrv[nPos][2]
lSemReg := Self:aClQryGrv[nPos][3]
If lSemReg .OR. Empty(cBloco) .OR. Val(cBloco) < nReserva
	Return lRet
Endif
//Caso nao exista registros na array temporaria
If (nPos := aScan(Self:aClQryData,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Endif
//Nao pode haver registros com esta posicao e bloco dentro da array de dados, caso exista apagar para reprocessar
If aScan(Self:aClLstItens,{|x| x[1] == nPosLeia .AND. x[3] == cBloco}) > 0
	//Apagar somente registros da posicao e bloco, para gravar novamente
	Self:DelQry(Self:aClQryData[nPos][1],.T.,3)	
Endif
//Gravar informacoes
nTotREG	:= Len(Self:aClQryData)
For ni := 1 to nTotREG
	aAdd(Self:aClLstItens,{nPosLeia,Self:aClQryData[ni][2],cBloco,.F.})
	//Se o controle de posicao do registro gravado na aClLstItens estiver zerado, associar a posicao do registro gravado
	If Self:aClQryData[ni][3] == 0
		Self:aClQryData[ni][3] := nRegAtu
	Endif
	nRegAtu++
Next ni
Self:nClLeiaAtivo := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetQryBlockºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar o numero do bloco associado a uma query   º±±
±±º          ³executada.                                                     º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetQryBlock(nPosLeia) Class LJCFrmtLay

Local nPos			:= 0
Local cBloco		:= "0"

Default nPosLeia	:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute)
	Return cBloco
Endif
If (nPos := aScan(Self:aClQryGrv,{|x| x[1] == nPosLeia})) == 0
	Return cBloco
Endif
cBloco := Self:aClQryGrv[nPos][2]
Self:nClLeiaAtivo := nPosLeia

Return cBloco

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetQrySQL  ºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar a instrucao SQL associada a um leiaute.   º±±
±±º          ³executada.                                                     º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetQrySQL(nPosLeia) Class LJCFrmtLay

Local cQuery		:= ""
Local nPos			:= 0

Default nPosLeia	:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute)
	Return cQuery
Endif
If (nPos := aScan(Self:aClQry,{|x| x[1] == nPosLeia})) == 0
	Return cQuery
Endif
cQuery := Self:aClQry[nPos][2]
Self:nClLeiaAtivo := nPosLeia

Return cQuery

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³DelData    ºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para excluir itens do array de dados principal.         º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method DelData(nPosLeia,cAlvo,nPosAlvo,cBloco) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local nTotREG			:= 0
Local ni				:= 0
Local nx				:= 0
Local aPosDel			:= {}
Local aPosDel02			:= {}
Local cTMP				:= ""
Local cTipo				:= ""
Local nTipoPesq			:= 0
Local aTMP				:= {}

Default nPosLeia		:= 0
Default cAlvo			:= ""
Default nPosAlvo		:= ""
Default cBloco			:= ""

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.) .OR. ValType(cAlvo) # "C" .OR. ValType(nPosAlvo) # "N"
	Return lRet
Else
	nPos := Self:nClPos
Endif
nPosAlvo := Round(Abs(nPosAlvo),0)
nTotREG := Len(Self:aClLstItens)
If Len(cAlvo) > 0
	//Determinar o tipo de pesquisa
	If At("%",cAlvo) > 0
		If Substr(cAlvo,1,1) == "%" .AND. Right(cAlvo,1) == "$"
			nTipoPesq := 4	//Pesquisa contem
		ElseIf Substr(cAlvo,1,1) == "%"
			nTipoPesq := 2	//Pesquisa termina com
		ElseIf Right(cAlvo,1) == "%"
			nTipoPesq := 3	//Pesquisa inicia com
		Else
			nTipoPesq := 1
		Endif
	Else
		nTipoPesq := 1		//Pesquisa cheia
	Endif
	//Pesquisar por conteudo
	For ni := 1 to nTotREG
		If Self:aClLstItens[ni][1] == nPosLeia .AND. IIf(!Empty(cBloco), cBloco == AllTrim(Self:aClLstItens[ni][3]), .T.)
			aTMP := Self:aClLstItens[ni][2]
			cTMP := ""
			If nPosAlvo == 0
				For nx := 1 to Len(aTMP)
					cTipo := ValType(aTMP[nx])
					Do Case
						Case cTipo == "A"
							cTMP += ""
						Case cTipo == "C"
							cTMP += aTMP[nx]
						Case cTipo == "D"
							cTMP += DtoC(aTMP[nx])
						Case cTipo == "N"
							cTMP += cValToChar(aTMP[nx])
						Case cTipo == "L"
							cTMP += cValToChar(aTMP[nx])
						OtherWise
							cTMP += aTMP[nx]
					EndCase
				Next nx
			Else
				cTMP := aTMP[nPosAlvo]
			Endif
			//Comparar
			Do Case
				Case nTipoPesq == 1		//Pesquisa cheia
					If cAlvo == Substr(cTMP,1,Len(cAlvo))
						aAdd(aPosDel,ni)
					Endif
				Case nTipoPesq == 2		//Pesquisa termina com
					If Substr(cAlvo,At("%",cAlvo) + 1,Len(cAlvo)) == Right(RTrim(cTMP),Len(cAlvo)-1)
						aAdd(aPosDel,ni)
					Endif
				Case nTipoPesq == 3		//Pesquisa inicia com
					If Substr(cAlvo,1,Len(cAlvo) - 1) == Substr(cTMP,1,Len(cAlvo) - 1)
						aAdd(aPosDel,ni)
					Endif
				Case nTipoPesq == 4		//Pesquisa contem
					If At(Substr(cAlvo,At("%",cAlvo) + 1,Rat("%",cAlvo) - 2),cTMP) > 0
						aAdd(aPosDel,ni)
					Endif						
			EndCase
		Endif
	Next ni
Else
	aAdd(aPosDel,"*")
Endif
//Exclusao de dados
If Len(aPosDel) # 0
	If cValToChar(aPosDel[1]) == "*"
		aTMP := {}
		For ni := 1 to nTotREG
			//Se o item nao pertencer ao leiaute definido, manter
			If Self:aClLstItens[ni][1] # nPosLeia 
				aAdd(aTMP,Self:aClLstItens[ni])
			Else
				//Se o leiaute for o mesmo, mas existir filtro por bloco, filtrar e manter os itens de blocos distintos
				If !Empty(cBloco)
					If cBloco # AllTrim(Self:aClLstItens[ni][3])
						aAdd(aTMP,Self:aClLstItens[ni])
					Endif
				Endif
			Endif
		Next ni
		Self:aClLstItens := aClone(aTMP)
		//Caso existam registros para apagar na aClQryGrv e aClQryData
		Self:DelQry(nPosLeia,.F.,2)		
	Else
		aTMP := {}
		For ni := 1 to nTotREG
			If aScan(aPosDel,{|x| x == ni}) == 0
				aAdd(aTMP,Self:aClLstItens[ni])
			Else
				//Verificar se o registro foi gravado a partir de uma query
				If Val(Self:aClLstItens[ni][3]) >= nReserva
					//Verificar se a posicao do registro esta associada na array de dados
					If (nPos := aScan(Self:aClQryData,{|x| x[1] == nPosLeia .AND. x[3] == ni})) > 0
						aAdd(aPosDel02,nPos)
					Endif
				Endif
			Endif
		Next ni
		Self:aClLstItens := aClone(aTMP)
		//Caso existam registros para apagar na aClQryData
		If Len(aPosDel02) # 0
			aTMP := {}
			nTotREG := Len(Self:aClQryData)
			For ni := 1 to nTotREG
				If aScan(aPosDel02,{|x| x == ni}) == 0
					aAdd(aTMP,Self:aClQryData[ni])
				Endif
			Next ni
			Self:aClQryData := aClone(aTMP)
			//Se o recipiente de dados temporario da query estiver vazio, determinar o controle de gravacao como sem registros
			If Len(Self:aClQryData) == 0
				If (nPos := aScan(Self:aClQryGrv,{|x| x[1] == nPosLeia})) > 0
					Self:aClQryGrv[nPos][3] := .T.
				Endif
			Endif
		Endif
	Endif
Endif
		
Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Finish     ºAutor  ³Vendas Clientes       º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para remover a instancia do objeto.                     º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method Finish() Class LJCFrmtLay

Local oObj:= Self

FreeObj(oObj)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetTotRec	 ºAutor  ³Vendas Clientes       º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar o total de registros consolidado no array º±±
±±º          ³de dados (aClLstItens), podendo-se filtrar por leiaute e por   º±±
±±º          ³bloco de dados.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetTotRec(nPosLeia,cBloco) Class LJCFrmtLay

Local nTotREG			:= 0
Local ni				:= 0
Local nLim				:= Len(Self:aClLstItens)

Default nPosLeia		:= 0
Default cBloco			:= ""

If ValType(nPosLeia) # "N" .OR. ValType(cBloco) # "C"
	Return nTotREG
Endif
cBloco := AllTrim(cBloco)
For ni := 1 to nLim
	If Empty(nPosLeia)
		nTotREG++
	Else
		If Self:aClLstItens[ni][1] == nPosLeia
			If Empty(cBloco)
				nTotREG++
			Else
				If AllTrim(Self:aClLstItens[ni][3]) == cBloco
					nTotREG++
				Endif
			Endif
		Endif
	Endif
Next ni

Return nTotREG

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetFieldN  ºAutor  ³Vendas Clientes       º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para alterar a estrutura de nome de campos das colunas. º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetFieldN(nPosLeia,aEstru,uCmp) Class LJCFrmtLay

Local lRet			:= .F.
Local nPos			:= 0
Local nCmp			:= 0

Default nPosLeia	:= 0
Default aEstru		:= {}
Default uCmp		:= 0

If ValType(aEstru) # "A" .OR. (ValType(uCmp) # "N" .AND. ValType(uCmp) # "C")
	Return lRet
Endif
If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos)
	Return lRet
Else
	nPos := Self:nClPos
Endif
Do Case
	Case ValType(uCmp) == "N"
		If !Empty(uCmp)
			nCmp := uCmp
			If nCmp > Len(Self:aClLeiaute[nPos][7]) .OR. Len(aEstru) > 1
				nCmp := 0
			Endif
		Endif
	Case ValType(uCmp) == "C"
		nCmp := aScan(::GetStruct(nPosLeia,7),{|x| AllTrim(x) == AllTrim(uCmp)})
		If nCmp == 0
			Return lRet
		Endif
EndCase
If Len(aEstru) == 0
	Self:aClLeiaute[nPos][7] := {}
Else
	If nCmp == 0
		Self:aClLeiaute[nPos][7] := aEstru
	Else
		Self:aClLeiaute[nPos][7][nCmp] := aEstru	
	Endif
Endif
Self:nClLeiaAtivo := nPosLeia

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³GetData    ºAutor  ³Vendas Clientes       º Data ³  30/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para retornar uma array com os dados coincidentes encon-º±±
±±º          ³trados com o paramentro de pesquisa.                           º±±
±±º          ³Retorno :{                                                     º±±
±±º          ³          Pos.Leiaute,                                         º±±
±±º          ³          {array de dados},                                    º±±
±±º          ³          Posicao do registro no array principal               º±±
±±º          ³          }                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method GetData(nPosLeia,cAlvo,nPosAlvo,cBloco) Class LJCFrmtLay

Local nPos				:= 0
Local nTotREG			:= 0
Local ni				:= 0
Local nx				:= 0
Local aPosRet			:= {}
Local cTMP				:= ""
Local cTipo				:= ""
Local nTipoPesq			:= 0
Local aTMP				:= {}

Default nPosLeia		:= 0
Default cAlvo			:= ""
Default nPosAlvo		:= ""
Default cBloco			:= ""

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.) .OR. ValType(cAlvo) # "C" .OR. ValType(nPosAlvo) # "N"
	Return aPosRet
Else
	nPos := Self:nClPos
Endif
nPosAlvo := Round(Abs(nPosAlvo),0)
nTotREG := Len(Self:aClLstItens)
If Len(cAlvo) > 0
	//Determinar o tipo de pesquisa
	If At("%",cAlvo) > 0
		If Substr(cAlvo,1,1) == "%" .AND. Right(cAlvo,1) == "$"
			nTipoPesq := 4	//Pesquisa contem
		ElseIf Substr(cAlvo,1,1) == "%"
			nTipoPesq := 2	//Pesquisa termina com
		ElseIf Right(cAlvo,1) == "%"
			nTipoPesq := 3	//Pesquisa inicia com
		Else
			nTipoPesq := 1
		Endif
	Else
		nTipoPesq := 1		//Pesquisa cheia
	Endif
	//Pesquisar por conteudo
	For ni := 1 to nTotREG
		If Self:aClLstItens[ni][1] == nPosLeia .AND. IIf(!Empty(cBloco), cBloco == AllTrim(Self:aClLstItens[ni][3]), .T.)
			aTMP := Self:aClLstItens[ni][2]
			cTMP := ""
			If nPosAlvo == 0
				For nx := 1 to Len(aTMP)
					cTipo := ValType(aTMP[nx])
					Do Case
						Case cTipo == "A"
							cTMP += ""
						Case cTipo == "C"
							cTMP += aTMP[nx]
						Case cTipo == "D"
							cTMP += DtoC(aTMP[nx])
						Case cTipo == "N"
							cTMP += cValToChar(aTMP[nx])
						Case cTipo == "L"
							cTMP += cValToChar(aTMP[nx])
						OtherWise
							cTMP += aTMP[nx]
					EndCase
				Next nx
			Else
				cTMP := aTMP[nPosAlvo]
			Endif
			//Comparar
			Do Case
				Case nTipoPesq == 1		//Pesquisa cheia
					If cAlvo == Substr(cTMP,1,Len(cAlvo))
						aAdd(aPosRet,{Self:aClLstItens[ni][1],Self:aClLstItens[ni][2],ni})
					Endif
				Case nTipoPesq == 2		//Pesquisa termina com
					If Substr(cAlvo,At("%",cAlvo) + 1,Len(cAlvo)) == Right(RTrim(cTMP),Len(cAlvo)-1)
						aAdd(aPosRet,{Self:aClLstItens[ni][1],Self:aClLstItens[ni][2],ni})
					Endif
				Case nTipoPesq == 3		//Pesquisa inicia com
					If Substr(cAlvo,1,Len(cAlvo) - 1) == Substr(cTMP,1,Len(cAlvo) - 1)
						aAdd(aPosRet,{Self:aClLstItens[ni][1],Self:aClLstItens[ni][2],ni})
					Endif
				Case nTipoPesq == 4		//Pesquisa contem
					If At(Substr(cAlvo,At("%",cAlvo) + 1,Rat("%",cAlvo) - 2),cTMP) > 0
						aAdd(aPosRet,{Self:aClLstItens[ni][1],Self:aClLstItens[ni][2],ni})
					Endif						
			EndCase
		Endif
	Next ni
Endif

Return aPosRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetFilter  ºAutor  ³Vendas Clientes       º Data ³  02/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para marcar registros que se enquadra dentro de uma     º±±
±±º          ³regra de filtragem.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetFilter(nPosLeia,cBloco,uCmp,cAlvo) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0
Local nTotREG			:= 0
Local ni				:= 0
Local nx				:= 0
Local cTMP				:= ""
Local cTipo				:= ""
Local nTipoPesq			:= 0
Local aTMP				:= {}
Local nCont				:= 0
Local nCmp				:= 0

Default nPosLeia		:= 0
Default cBloco			:= ""
Default uCmp			:= 0
Default cAlvo			:= ""

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.) .OR. ValType(cAlvo) # "C" .OR. ValType(cBloco) # "C" .OR. (ValType(uCmp) # "C" .AND. ValType(uCmp) # "N")
	Return lRet
Else
	nPos := Self:nClPos
Endif
//Tratamento de campo
Do Case
	Case ValType(uCmp) == "N"
		If !Empty(uCmp)
			nCmp := uCmp
			If nCmp > Len(Self:aClLeiaute[nPos][3]) .OR. Len(aEstru) > 1
				nCmp := 0
			Endif
		Endif
	Case ValType(uCmp) == "C"
		nCmp := aScan(::GetStruct(nPosLeia,7),{|x| AllTrim(x) == AllTrim(uCmp)})
		If nCmp == 0
			Return lRet
		Endif
EndCase
nTotREG := Len(Self:aClLstItens)
If Len(cAlvo) > 0
	//Determinar o tipo de pesquisa
	If At("%",cAlvo) > 0
		If Substr(cAlvo,1,1) == "%" .AND. Right(cAlvo,1) == "$"
			nTipoPesq := 4	//Pesquisa contem
		ElseIf Substr(cAlvo,1,1) == "%"
			nTipoPesq := 2	//Pesquisa termina com
		ElseIf Right(cAlvo,1) == "%"
			nTipoPesq := 3	//Pesquisa inicia com
		Else
			nTipoPesq := 1
		Endif
	Else
		nTipoPesq := 1		//Pesquisa cheia
	Endif
	//Pesquisar por conteudo
	For ni := 1 to nTotREG
		If Self:aClLstItens[ni][1] == nPosLeia .AND. IIf(!Empty(cBloco), cBloco == AllTrim(Self:aClLstItens[ni][3]), .T.)
			aTMP := Self:aClLstItens[ni][2]
			cTMP := ""		
			If nCmp == 0
				//Desmarcar o status de filtragem
				Self:aClLstItens[ni][4] := .F.
				For nx := 1 to Len(aTMP)
					cTipo := ValType(aTMP[nx])
					Do Case
						Case cTipo == "A"
							cTMP += ""
						Case cTipo == "C"
							cTMP += aTMP[nx]
						Case cTipo == "D"
							cTMP += DtoC(aTMP[nx])
						Case cTipo == "N"
							cTMP += cValToChar(aTMP[nx])
						Case cTipo == "L"
							cTMP += cValToChar(aTMP[nx])
						OtherWise
							cTMP += aTMP[nx]
					EndCase
				Next nx
			Else
				cTMP := aTMP[nCmp]
			Endif
			//Comparar
			Do Case
				Case nTipoPesq == 1		//Pesquisa cheia
					If cAlvo == Substr(cTMP,1,Len(cAlvo))
						Self:aClLstItens[ni][4] := .T.
						nCont++
					Endif
				Case nTipoPesq == 2		//Pesquisa termina com
					If Substr(cAlvo,At("%",cAlvo) + 1,Len(cAlvo)) == Right(RTrim(cTMP),Len(cAlvo)-1)
						Self:aClLstItens[ni][4] := .T.
						nCont++
					Endif
				Case nTipoPesq == 3		//Pesquisa inicia com
					If Substr(cAlvo,1,Len(cAlvo) - 1) == Substr(cTMP,1,Len(cAlvo) - 1)
						Self:aClLstItens[ni][4] := .T.
						nCOnt++
					Endif
				Case nTipoPesq == 4		//Pesquisa contem
					If At(Substr(cAlvo,At("%",cAlvo) + 1,Rat("%",cAlvo) - 2),cTMP) > 0
						Self:aClLstItens[ni][4] := .T.
						nCont++
					Endif						
			EndCase
		Endif
	Next ni
	If !Empty(nCont)
		//Verificar se o leiaute + bloco jah possui filtro
		If (nPos := aScan(Self:aClFiltro,{|x| x[1] == nPosLeia .AND. AllTrim(x[2]) == AllTrim(cBloco)})) > 0
			Self:aClFiltro[nPos][1] := nPosLeia
			Self:aClFiltro[nPos][2] := cBloco
			Self:aClFiltro[nPos][3] := cAlvo
		Else
			aAdd(Self:aClFiltro,{nPosLeia,IIf(Empty(cBloco),"0",cBloco),cAlvo,nCmp})
		Endif
	Endif
Else
	For ni := 1 to nTotREG
		If Self:aClLstItens[ni][1] == nPosLeia .AND. IIf(!Empty(cBloco), cBloco == AllTrim(Self:aClLstItens[ni][3]), .T.)
			//Desmarcar o status de filtragem
			Self:aClLstItens[ni][4] := .F.
		Endif
	Next ni
	//Verificar se o leiaute + bloco jah possui filtro e apagar
	If (nPos := aScan(Self:aClFiltro,{|x| x[1] == nPosLeia .AND. AllTrim(x[2]) == IIf(Empty(cBloco),"0",AllTrim(cBloco))})) > 0
		For ni := 1 to Len(Self:aClFiltro)
			If ni # nPos
				aAdd(aTMP,Self:aClFiltro[ni])
			Endif
		Next ni
		Self:aClFiltro := aClone(aTMP)
	Endif
Endif

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³RefreshF   ºAutor  ³Vendas Clientes       º Data ³  02/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para atualizar a marcacao de itens de dados que se      º±±
±±º          ³enquadram dentro de uma regra de filtragem definida.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method RefreshF(nPosLeia,cBloco) Class LJCFrmtLay

Local lRet				:= .F.
Local nPos				:= 0

Default nPosLeia		:= 0
Default cBloco			:= "0"

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.) .OR. ValType(cBloco) # "C"
	Return lRet
Endif
If (nPos := aScan(Self:aClFiltro,{|x| x[1] == nPosLeia .AND. AllTrim(x[2]) == AllTrim(cBloco)})) == 0
	Return lRet
Endif
Self:SetFilter(Self:aClFiltro[nPos][1],Self:aClFiltro[nPos][2],Self:aClFiltro[nPos][4],Self:aClFiltro[nPos][3])

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³RefreshQ   ºAutor  ³Vendas Clientes       º Data ³  02/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para atualizar a marcacao de itens de dados que se      º±±
±±º          ³enquadram dentro de uma regra de filtragem definida.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method RefreshQ(nPosLeia) Class LJCFrmtLay

Local lRet				:= .F.

Default nPosLeia		:= 0

If !VldPosLeia(nPosLeia,Self:aClLeiaute,@Self:nClPos,.T.)
	Return lRet
Endif
Self:ExecQry(nPosLeia,.T.)

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³SetUseDel  ºAutor  ³Vendas Clientes       º Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo para atualizar se um determinado leiaute utiliza ou nao º±±
±±º          ³delimitadores.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Method SetUseDel(lValor) Class LJCFrmtLay

Local lRet				:= .F.

Default lValor			:= .F.

If ValType(lValor) # "L"
	Return lRet
Endif
Self:lClUsaDel := lValor

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldPosLeia ºAutor  ³Vendas Clientes       º Data ³  25/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a posicao de leiaute                                    º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldPosLeia(nPosLeia,aLeia,nPosAt,lPrimeiro)

Local lRet			:= .F.
Local nPos			:= 0

Default nPosLeia	:= 0
Default aLeia		:= {}
Default nPosAt		:= 0
Default lPrimeiro	:= .F.

If ValType(nPosLeia) # "N" .OR. Empty(nPosLeia) .OR. ValType(aLeia) # "A"
	Return lRet
Endif
//Se a estrutura definida estiver vazia
If Len(aLeia) == 0
	Return lRet
Endif
//Verificar se a posicao indicada do leiaute existe
If (nPos := aScan(aLeia,{|x| x[1] == nPosLeia})) == 0
	Return lRet
Endif
//Verificar se a posicao solicitada nao eh a primeira, que eh reservada
If lPrimeiro .AND. nPosLeia == 1
	ExibeMens(STR0014) //"A primeira posiçao do leiaute é reservada, por favor utilize outra posição."
	Return lRet
Endif
nPosAt := nPos

Return !lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ExibeMens  ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                               º±±
±±º          ³                                                               º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExibeMens(cTexto,lPerg)

Local lRet			:= .T.
Local lJob			:= Select("SX6") == 0
Local lMostra		:= .F.
Local cID			:= "[LJCFRMTLAY] "

Default cTexto		:= ""
Default lPerg		:= .F.

If Empty(cTexto) .OR. ValType(cTexto) # "C"
	Return Nil
Endif
If Type("lMsHelpAuto") == "L"
	If !lMsHelpAuto .OR. lJob
		lMostra := .F.
	Else
		lMostra := .T.
	Endif
Else
	lMostra := .T.	
Endif
If !lMostra
	If !lPerg
		ConOut(cID + cTexto)
    Endif
Else
	If !lPerg
		MsgAlert(cTexto)
	Else
		lRet := ApMsgYesNo(cTexto)
	Endif
Endif    

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³AutoAjuste ºAutor  ³Vendas Clientes       º Data ³  23/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para ajustar automaticamente a distribuicao das colunas º±±
±±º          ³proporcionalmente ao tamanho dos dados contidos em cada uma dasº±±
±±º          ³colunas.                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AutoAjuste(aLeia,aDados,lAjLargCab)

Local aRet			:= {}
Local aTamMax		:= {}
Local ni			:= 0
Local nx			:= 0
Local nz			:= 0
Local cStr			:= ""
Local cTipo			:= ""
Local aTamCol		:= {}
Local nPerc			:= 0
Local nTamTot		:= 0
Local nPosLeia		:= 0
Local lOk			:= .T.
Local lCab			:= .F.
Local aCab			:= {}

Default aDados		:= {}

If Len(aDados) == 0 .OR. ValType(aDados) # "A"
	Return aRet
Endif
//Se a estrutura de dados for indevida
If Len(aDados[1]) # nEstruItem
	Return aRet
Endif
//Se a estrutura definida estiver vazia
If Len(aLeia) == 0
	Return aRet
Endif
For nz := 1 to Len(aLeia)
	aTamMax := {}
	lOk := .T.
	If lAjLargCab
		lCab := aLeia[nz][4]
		If lCab
			aCab := aLeia[nz][5]
		Else
			aCab := {}
		Endif
	Else
		lCab := .F.
	Endif
	If Len(aLeia[nz][2]) > 0
		For ni := 1 to Len(aLeia[nz][2])
			If aLeia[nz][2][ni] # 0
				lOk := .F.
				Exit
			Endif
		Next ni
	Endif
	If lOk
		nPosLeia := aLeia[nz][1]
		aTamCol := {}
		aTamMax	:= Array(Len(aLeia[nz][2]))
		For ni := 1 to Len(aTamMax)
			aTamMax[ni] := 0
		Next ni
		//Varrer o array de dados identificando o tamanho maximo de cada coluna pertencente ao leiaute definido
		For ni := 1 to Len(aDados)
			If aDados[ni][1] == nPosLeia
				For nx := 1 to Len(aDados[ni][2])
					If aDados[ni][2][nx] # Nil
						cTipo := ValType(aDados[ni][2][nx])
						Do Case
							Case cTipo == "D"
								cStr := DtoC(aDados[ni][2][nx])
							Case cTipo == "L"
								cStr := cValToChar(aDados[ni][2][nx])
							Case cTipo == "N"
								cStr := cValToChar(aDados[ni][2][nx])
							Otherwise
								cStr := aDados[ni][2][nx]
						EndCase
						cStr := RTrim(cStr)
						//Caso o ajuste por tamanho de cabecalho esteja ativo, caso o tamanho do cabecalho for maior que do dado, prevalecer o tamanho do cabecalho
						If lCab
							If Len(cStr) < Len(RTrim(aCab[nx]))
								cStr := aCab[nx] + Space(1) //Adicionar um espaco
							Endif
						Endif
						If Len(cStr) > aTamMax[nx]
							aTamMax[nx] := Len(cStr)
						Endif				
					Endif
				Next nx
			Endif
		Next ni
		//Definir o tamanho total das colunas
		aEval(aTamMax,{|x| nTamTot += x})
		//Fazer a nova distribuicao das colunas
		If nTamTot > 0
			For ni := 1 to Len(aTamMax)
				nPerc := Round(Abs((aTamMax[ni] / nTamTot) * 100),0)
				aAdd(aTamCol,nPerc)
			Next ni
			//Verificar se o tamanho total nao esta usando a area total, caso nao esteja adicionar ao ultimo elemento a diferenca
			nTamTot := 0
			aEval(aTamCol,{|x| nTamTot += x})
			If nTamTot < 100
				aTamCol[Len(aTamCol)] := aTail(aTamCol) + (100 - nTamTot)
			Endif
		Endif
		//Atualizar a distribuicao das colunas no leiaute
		aAdd(aRet,{nPosLeia,aTamCol})
	Endif
Next nz
		
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FrmLeiaute ºAutor  ³Vendas Clientes       º Data ³  18/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para imprimir relatorio gerencial ou retornar uma       º±±
±±º          ³string formatada de acordo com um leiaute fornecido.           º±±
±±º          ³Existe ainda o recurso de COMANDOS, que permitem que comandos  º±±
±±º          ³de impressao pre-estabelecidos sejam impressos. Vide lista.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nImprime - Opcoes de impressao                                 º±±
±±º          ³           0.Sem impressao                                     º±±
±±º          ³           1.Impressao do relatorio gerencial na ECF           º±±
±±º          ³           2.Impressao de relatorio convencional               º±±
±±º          ³           3.Arquivo CSV                                       º±±
±±º          ³                                                               º±±
±±º          ³aTipos   - Array de leiaute com a seguinte estrutura :         º±±
±±º          ³[OBRI] [N] 1.Posicao (Variacoes de leiaute)                    º±±
±±º          ³[OBRI] [A] 2.Colunas (Divisao das colunas em percentuais)      º±±
±±º          ³[OBRI] [A] 3.Alinhamento (Alinhamento colunas ("L","C","R"))   º±±
±±º          ³[OBRI] [L] 4.Cabecalho? (Imprimir cabecalho?)                  º±±
±±º          ³[OBRI] [A] 5.Itens cabecalho (Itens do cabecalho)              º±±
±±º          ³[OPCI] [L] 6.Imprimir delimitador? (Mesmo que um delimitador   º±±
±±º          ³             nao seja usado, em leiaute com multiplas colunas  º±±
±±º          ³             estas sao separadas por espaco p/ nao truncar     º±±
±±º          ³                                                               º±±
±±º          ³aRel     - Array contendo os dados que devem ser impressos     º±±
±±º          ³           dentro do leiaute fornecido.                        º±±
±±º          ³                                                               º±±
±±º          ³nCol     - Numero de colunas da area de impressao              º±±
±±º          ³                                                               º±±
±±º          ³cCol     - Caracter delimitador de colunas (opcional)          º±±
±±º          ³                                                               º±±
±±º          ³cLin     - Caracter delimitador de linhas (opcional)           º±±
±±º          ³                                                               º±±
±±º          ³lUsaDL   - Determina se a rotina deve utilizar o del de linha  º±±
±±º          ³                                                               º±±
±±º          ³cLinSep  - Determina qual a linha separadora (opcional)        º±±
±±º          ³                                                               º±±
±±º          ³cTitulo  - Titulo a ser impresso (apenas qdo nImprime = 2)     º±±
±±º          ³                                                               º±±
±±º          ³nTamPapel- Tamanho do papel (1-[P]equeno 2-[M]edio [3]-Grande	 º±±
±±º          ³                                                               º±±
±±º          ³cOrienta - Orientacao do papel : [P]ortrait ou [L]andscape     º±±
±±º          ³                                                               º±±
±±º          ³nPosCab  - Pos. do array leiaute que sera usado como cabecalho º±±
±±º          ³                                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

COMANDOS (DEVEM SER USADOS EM LINHAS COM UMA UNICA COLUNA)
=CLINHA			- LINHA SEPARADORA
=CLBRANCO		- LINHA EM BRANCO
=CEMPRESA		- NOME DA EMPRESA
=CCNPJ			- CNPJ
=CINSC			- INSCRICAO ESTADUAL
=CEND			- ENDERECO
=CCOMPEND		- COMPLEMENTO DE ENDERECO
=CLBRANCOCD		- LINHA EM BRANCO COM DELIMITADOR
=CLINHASD		- LINHA SEPARADORA SEM DELIMITADOR
*/

Function FrmLeiaute(nImprime,aTipos,aRel,nCol,cCol,cLin,lUsaDL,cLinSep,cTitulo,nTamPapel,cOrienta,nPosCab)

Local cTMP				:= ""
Local cImpF				:= ""
Local ni				:= 0
Local nx				:= 0
Local aCol				:= {}
Local nTotCol			:= 0
Local lUsaDel			:= .T.
Local nPos				:= 0
Local nPos02			:= 0
Local uValCol			:= ""
Local nColUtil			:= 0
Local nLarg				:= 0
Local aImpCab			:= {}	//Determina quais estruturas do leiaute que utilizam cabecalho jah teiveram sua impressao feita
Local nHndl				:= Nil
Local cImpressora		:= ""
Local cPorta			:= ""
Local cBuffer			:= ""
Local lImpOk			:= .F.
Local aLOG				:= {}
Local nPerc				:= 0
Local lColMinL			:= 5	//Numero minimo de colunas que deve conter a estrutura de leiaute
Local lColMaxL			:= 9	//Numero maximo de colunas que deve conter a estrutura de leiaute
Local aCabRel			:= {}
Local lImpCabR4			:= .F.
Local nColOri			:= 0
Local cComando			:= ""
//							COMANDO			IMPRIME DELIMITADOR?
Local aComando			:= {{"=CLINHA"		,.F.},;		//LINHA SEPARADORA
							{"=CLBRANCO"	,.F.},;		//LINHA EM BRANCO
							{"=CEMPRESA"	,.T.},;		//NOME DA EMPRESA
							{"=CCNPJ"		,.T.},;		//CNPJ
							{"=CINSC"		,.T.},;		//INSCRICAO ESTADUAL
							{"=CEND"		,.T.},;		//ENDERECO
							{"=CCOMPEND"	,.T.},;		//COMPLEMENTO DE ENDERECO
							{"=CLBRANCOCD"	,.T.},;		//LINHA EM BRANCO COM DELIMITADOR
							{"=CLINHASD"	,.F.}}		//LINHA SEPARADORA SEM DELIMITADOR +
Local lCSV				:= IIf(nImprime == 3 .AND. lUsaDL,.T.,.F.)

Private cLS			:= ""

Default nImprime		:= 0
Default aTipos			:= {}
Default aRel			:= {}
Default cCol			:= "-"
Default cLin			:= "|"
Default lUsaDL			:= .T.
Default cLinSep 		:= "+" + Replicate(cCol,nCol - 2) + "+"
Default cTitulo		:= STR0015 //"RELATÓRIO GERENCIAL"
Default nTamPapel		:= 3
Default cOrienta		:= "P"
Default nPosCab		:= 0

If Len(aTipos) == 0 .OR. Len(aRel) == 0 .OR. nCol == 0
	Return IIf(nImprime == 0,cImpF,.F.)
Endif
nColUtil := IIf(lUsaDL,nCol - 2,nCol)
cLS := IIf(!Empty(cLinSep),cLinSep,"+" + Replicate(cCol,nCol - 2) + "+")
//Delimitador diferenciado para CSV
If lCSV
	cLin := ";"
Endif
//Tratamento de impressora
If nImprime == 1
	/*
	cImpressora	:= LJGetStation("IMPFISC")
	cPorta		:= LJGetStation("PORTIF")
	If !Empty(cImpressora) .OR. !Empty(cPorta)
		nHndl := IFAbrir(cImpressora,cPorta)
		If IFStatus(nHndl,"9",@cBuffer) == 0
			lImpOk := !lImpOk
		Endif
	Endif
	*/
	If lFiscal .AND.  IfAbrECF(nHdlECF) == 0
		lImpOk := !lImpOk
	Endif
	//Alterar o delimitador de linha caso seja pipe, pois este caracter eh utilizado pela funcao IfRelGer na comunicacao com a impressora
	If AllTrim(cLin) == "|"
		cLin := "!"
	Endif
Endif
//Montagem do texto de impressao
For ni := 1 to Len(aRel)
	cTMP 		:= ""
	lUsaDel 	:= .T.
	nPos02 		:= 0
	lImpCabR4 	:= .F.
	If ValType(aRel[ni][2]) # "A"
		Return IIf(nImprime == 0,cImpF := "",.F.)
	Endif
	If (nPos := aScan(aTipos,{|x| x[1] == aRel[ni][1]})) > 0
		//Validar o numero de parametros maximo e minimo da array de estrutura do leiaute
		If Len(aTipos[nPos]) < lColMinL .OR. Len(aTipos[nPos]) > lColMaxL
			Return IIf(nImprime == 0,cImpF := "",.F.)
		Endif	
		//Validar o tipo de dados das posicoes 2,3 e 5
		If ValType(aTipos[nPos][2]) # "A" .OR. ValType(aTipos[nPos][3]) # "A" .OR. (aTipos[nPos][4] .AND. ValType(aTipos[nPos][5]) # "A")
			Return IIf(nImprime == 0,cImpF := "",.F.)
		Endif
		//Validar tamanho dos arrays
		If Len(aRel[ni][2]) # Len(aTipos[nPos][2]) .OR. Len(aTipos[nPos][2]) # Len(aTipos[nPos][3])
			Return IIf(nImprime == 0,cImpF := "",.F.)
		Endif
		//Verificar se existem arrays vazios
		If Len(aRel[ni][2]) == 0 .OR. Len(aTipos[nPos][2]) == 0 .OR. Len(aTipos[nPos][3]) == 0
			Return IIf(nImprime == 0,cImpF := "",.F.)
		Endif
		//Determinar qual o cabecalho a ser impresso
		If nImprime == 2 .AND. nPosCab == nPos
			If aTipos[nPos][4] .AND. Len(aTipos[nPos][5]) # 0 .AND. Len(aCabRel) == 0
				lImpCabR4 := .T.
				aCabRel := Array(1)
			Endif
		Endif
		If !lCSV
			//Verificar se o parametro que define se o delimitador deve ser impresso esta sendo utilizado
			If Len(aTipos[nPos]) >= 6
				If ValType(aTipos[nPos][6]) == "L"
					If !aTipos[nPos][6]
						//Se o delimitador do grupo de leiaute estiver definindo que o delimitador nao deve ser utilizado, esta configuracao valera para todo o seu conteudo
						//independentemente das configuracoes especiais dos conteudos.
						lUsaDel := .F.
					Endif
				Endif
			Endif
		Endif		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ajustar a largura das colunas  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCol := Array(Len(aTipos[nPos][2]))
		nColOri := Len(aCol)
		If Len(aCol) > 1
			nTotCol := 0
			For nx := 1 to Len(aCol)
				aCol[nx] := Round(Abs((aTipos[nPos][2][nx] / 100) * nColUtil),0)
			Next nx
			aEval(aCol,{|x| nTotCol += x})
			If nTotCol # nColUtil .AND. Abs(nTotCol - nColUtil) > 2
				If nTotCol < nColUtil .AND. nImprime == 2
					//Se o total do percentual das colunas for inferior ao total disponivel, criar uma nova com a diferenca. Isso permite que as informacoes nao fiquem
					//demasiadamente espacadas no relatorio. Utiliza-se apenas o que foi solicitado.				
					aAdd(aCol,Round(Abs(((nColUtil - nTotCol) / nColUtil) * nColUtil),0))
				Else
					//Ajustar todos percentuais das colunas, para maior ou menor, caso a soma dos percentuais exceda ao limite de colunas uteis
					nPerc := nColUtil / nTotCol
					For nx := 1 to Len(aCol)
						aCol[nx] := Round(Abs(aCol[nx] * nPerc),0)
					Next nx
				Endif
			Endif
			nTotCol := 0
			aEval(aCol,{|x| nTotCol += x})
			//Ajustar o numero de colunas caso seja divergente do total de colunas de impressao (pequeno ajuste de possiveis divergencias causadas pelo aj. automatico)
			If nTotCol > nColUtil
				aCol[Len(aCol)] := aTail(aCol) - (nTotCol - nColUtil)
			ElseIf nTotCol < nColUtil
				aCol[Len(aCol)] := aTail(aCol) + (nColUtil - nTotCol)
			Endif
		Else
			nTotCol := 0
			For nx := 1 to Len(aCol)
				aCol[nx] := Round(Abs((aTipos[nPos][2][nx] / 100) * nColUtil),0)
			Next nx
			aEval(aCol,{|x| nTotCol += x})
			//Se o total do percentual das colunas for inferior ao total disponivel, criar uma nova com a diferenca. Isso permite que as informacoes nao fiquem
			//demasiadamente espacadas no relatorio. Utiliza-se apenas o que foi solicitado.
			If nTotCol < nColUtil .AND. nImprime == 2
				aCol[1] := nTotCol
				aAdd(aCol,Round(Abs(((nColUtil - nTotCol) / nColUtil) * nColUtil),0))
			Else
				aCol[1] := nColUtil			
			Endif
			If (nPos02 := aScan(aComando,{|x| Upper(AllTrim(x[1])) == Upper(AllTrim(aRel[ni][2][1]))})) == 0
				If aRel[ni][1] == 1
					If aRel[ni][2][1] == cLS .AND. lUsaDel
						lUsaDel	:= .F.
					Endif
				Endif
			Else
				If lUsaDel
					lUsaDel	:= aComando[nPos02][2]
				Endif
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montar cabecalho  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aTipos[nPos][4]
			If aScan(aImpCab,{|x| x == aRel[ni][1]}) == 0
				If !lCSV
					cTMP += IIf(lUsaDel .AND. lUsaDL,cLIN,"")
				Endif
				For nx := 1 to Len(aCol)
					nLarg := aCol[nx]
					//No caso de impressao com delimitador de linha, abater uma coluna da largura da coluna corrente, que sera destinada ao separador
					If nx < Len(aCol)
						nLarg--
					Endif
					If nx <= nColOri
						uValCol := IIf(aTipos[nPos][5][nx] == Nil, "", aTipos[nPos][5][nx])
					Else
						uValCol := ""
					Endif
					//Apenas o primeiro elemento de uma array eh considerada, pois o dado da coluna deve ser atomico
					If ValType(uValCol) == "A"
						uValCol := uValCol[1]
					Endif
					Do Case
						Case ValType(uValCol) == "L"
							uValCol := cValToChar(uValCol)
						Case ValType(uValCol) == "N"
							uValCol := cValToChar(uValCol)
						Case ValType(uValCol) == "D"
							uValCol := DtoC(uValCol)
						Case ValType(uValCol) == "A"
							uValCol := ""
					EndCase
					//Ajustar tamanho
					If !lCSV
						uValCol := PadR(Substr(uValCol,1,nLarg),nLarg)
						//Alimentar cabecalho ou string de impressao
						If lImpCabR4
							aCabRel[1] := IIf(!aCabRel[1] == Nil,aCabRel[1],"") + uValCol + IIf(lUsaDel .AND. lUsaDL,cLIN,IIf(nx < Len(aCol)," ",""))
						Else
							cTMP += uValCol + IIf(lUsaDel .AND. lUsaDL,cLIN,IIf(nx < Len(aCol)," ",""))
						Endif
					Else
						cTMP += uValCol + IIf(nx < Len(aCol),cLin,"")
					Endif
				Next nx
				If !lImpCabR4 .AND. !lCSV
					cTMP += CRLF + IIf(lUsaDel .AND. lUsaDL,&("cLS"),Substr(&("cLS"),2,Len(&("cLS")) - 2) + Replicate(cCol,2)) + CRLF
				Else
					cTMP += CRLF
				Endif
				aAdd(aImpCab,aRel[ni][1])
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montar a string de impressao dentro do leiaute definido  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lCSV
			cTMP += IIf(lUsaDel .AND. lUsaDL,cLIN,"")
		Endif
		For nx := 1 to Len(aCol)
			nLarg := aCol[nx]
			//No caso de impressao com delimitador de linha, abater uma coluna da largura da coluna corrente, que sera destinada ao separador
			If nx < Len(aCol)
				nLarg--
			Endif
			If nx <= nColOri
				uValCol := IIf(aRel[ni][2][nx] == Nil, "", aRel[ni][2][nx])
			Else
				uValCol := ""
			Endif
			//Apenas o primeiro elemento de uma array eh considerada, pois o dado da coluna deve ser atomico
			If ValType(uValCol) == "A"
				uValCol := uValCol[1]
			Endif
			Do Case
				Case ValType(uValCol) == "L"
					uValCol := cValToChar(uValCol)
				Case ValType(uValCol) == "N"
					uValCol := cValToChar(uValCol)
				Case ValType(uValCol) == "D"
					uValCol := DtoC(uValCol)
				Case ValType(uValCol) == "A"
					uValCol := ""
			EndCase
			//Verificar se o conteudo da coluna trata-se de um comando
			If nPos02 # 0
				cComando := aComando[nPos02][1]
				Do Case 
					Case cComando == "=CLINHA"
						If !lCSV
							uValCol := cLS
							nLarg 	:= nCol
						Else
							uValCol := Replicate(cLin,Len(aCol))
						Endif
					Case cComando == "=CLBRANCO"
						If !lCSV
							uValCol := Space(nCol)
							nLarg 	:= nCol
						Else
							uValCol := Replicate(cLin,Len(aCol))
						Endif							
					Case cComando == "=CEMPRESA"
						uValCol := AllTrim(SM0->M0_NOMECOM)
					Case cComando == "=CCNPJ"
						uValCol := "CNPJ:" + AllTrim(SM0->M0_CGC)
					Case cComando == "=CINSC"
						uValCol := "INSC.EST.:" + AllTrim(SM0->M0_INSC)
					Case cComando == "=CEND"
						uValCol := AllTrim(SM0->M0_ENDENT)
					Case cComando == "=CCOMPEND"
						uValCol := AllTrim(SM0->M0_CIDENT) + "-" + AllTrim(SM0->M0_ESTENT) + "-CEP:" + AllTrim(SM0->M0_CEPENT)
					Case cComando == "=CLBRANCOCD"
						If !lCSV					
							uValCol := Space(nColUtil)
						Else
							uValCol := Replicate(cLin,Len(aCol))
						Endif							
					Case cComando == "=CLINHASD"
						If !lCSV
							uValCol := Substr(cLS,2,Len(cLS) - 2) + Replicate(cCol,2)
							nLarg 	:= nCol						
						Else 
							uValCol := Replicate(cLin,Len(aCol))
						Endif
				EndCase							
			Endif
			If !lCSV
				//Ajustar tamanho
				uValCol := Substr(AllTrim(uValCol),1,nLarg)
				//Alinhamento
				If Len(uValCol) < aCol[nx]
					If nx <= nColOri
						Do Case 
							Case AllTrim(aTipos[nPos][3][nx]) == "C"
								cTMP += PadC(uValCol,nLarg)
							Case AllTrim(aTipos[nPos][3][nx]) == "R"
								cTMP += PadL(uValCol,nLarg)
							Otherwise
								cTMP += PadR(uValCol,nLarg)
						EndCase
					Else
						cTMP += PadR(uValCol,nLarg)
					Endif
				Else
					cTMP += uValCol
				Endif
				cTMP += IIf(lUsaDel .AND. lUsaDL,cLIN,IIf(nx < Len(aCol)," ",""))
			Else
				cTMP += uValCol + IIf(nx < Len(aCol),cLin,"")
			Endif
		Next nx
	Endif
	cImpF += cTMP + CRLF
Next ni
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gerar relatorio  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cImpF) .AND. nImprime == 2
	cTMP := ""
	For ni := 1 to Len(cImpF)
		If Substr(cImpF,ni,1) $ CRLF
			aAdd(aLOG,cTMP)
			cTMP := ""
			ni++
		Else
			cTMP += Substr(cImpF,ni,1)
		Endif
	Next ni
	If Len(aLOG) # 0
		fMakeLog({aLOG},aCabRel,Nil,.T.,cTitulo,cTitulo,IIf(nTamPapel == 1,"P",IIf(nTamPapel == 2,"M","G")),cOrienta,,.F.)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gerar impressao do relatorio gerencial (ECF)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cImpF) .AND. nImprime == 1
	If lImpOk
		If IFRelGer(nHdlECF,cImpF,1) == 0
			cImpF := .T.
		Else
			cImpF := .F.
		Endif
	Else
		cImpF := .F.
	Endif
Endif

Return cImpF

/*                                                  	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³cDataType ºAutor  ³Vendas Clientes       º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que ao receber uma string, determina qual o seu tipo   º±±
±±º          ³de dados de acordo com o seu conteudo.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cValData - String a ser identificada                          º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function cDataType(cValData)

Local cTipo				:= ""
Local aElemTipo			:= Array(5)
Local ni				:= 0
Local nx				:= 0
Local nCont				:= 0
Local aResultado		:= {}
Local lOk				:= .F.

Static cArrayD			:= CHR(34) + "'{}[]()"

Private aData			:= Array(3)
Private aArrayD		:= Array(5)	//Controle de delimitadores de array - validacao

Default cValData		:= ""

If (cTipo := ValType(cValData)) # "C" .OR. Empty(cValData)
	Return cTipo
Endif
//1. Tipo de dados 2. Correspondencias 3. Tamanho minimo 4. Tamanho maximo 5. Descartar 6. Caracteres associados 7. Prioridade
aElemTipo[1] := {"C"	,0	,1	,0	,.F.	,""	,2}
aElemTipo[2] := {"N"	,0	,1	,0	,.F.	,""	,1}
aElemTipo[3] := {"D"	,0	,6	,10	,.F.	,""	,1}
aElemTipo[4] := {"L"	,0	,3	,3	,.F.	,""	,1}
aElemTipo[5] := {"A"	,0	,3	,0	,.F.	,""	,1}	//Minimo : {<elemento>}
cValData := AllTrim(cValData)
For ni := 1 to Len(cValData)
	lOk := .F.
	If Substr(cValData,ni,1) $ "0123456789"
		aElemTipo[2][2]++
		aElemTipo[2][6] += Substr(cValData,ni,1)
		aElemTipo[3][2]++
		aElemTipo[3][6] += Substr(cValData,ni,1)
		aElemTipo[5][2]++
		aElemTipo[5][6] += Substr(cValData,ni,1)
		lOk := .T.
	Endif	
	If Upper(Substr(cValData,ni,1)) $ "ABCDEFGHIJKLMNOPQRSTUVXWYZ"
		aElemTipo[1][2]++
		aElemTipo[1][6] += Upper(Substr(cValData,ni,1))
		aElemTipo[5][2]++
		aElemTipo[5][6] += Upper(Substr(cValData,ni,1))
		If Upper(Substr(cValData,ni,1)) $ "TF"
			aElemTipo[4][2]++
			aElemTipo[4][6] += Upper(Substr(cValData,ni,1))			
		Endif
		lOk := .T.
	Endif
	If Substr(cValData,ni,1) $ ","
		aElemTipo[1][2]++
		aElemTipo[1][6] += Substr(cValData,ni,1)
		aElemTipo[5][2]++
		aElemTipo[5][6] += Substr(cValData,ni,1)
		lOk := .T.
	Endif	
	If Substr(cValData,ni,1) $ "."
		aElemTipo[1][2]++
		aElemTipo[1][6] += Substr(cValData,ni,1)
		aElemTipo[2][2]++
		aElemTipo[2][6] += Substr(cValData,ni,1)
		aElemTipo[4][2]++
		aElemTipo[4][6] += Substr(cValData,ni,1)
		aElemTipo[5][2]++
		aElemTipo[5][6] += Substr(cValData,ni,1)
		lOk := .T.
	Endif	
	If Substr(cValData,ni,1) $ "/"
		aElemTipo[1][2]++
		aElemTipo[1][6] += Substr(cValData,ni,1)
		aElemTipo[3][2]++
		aElemTipo[3][6] += Substr(cValData,ni,1)
		aElemTipo[5][2]++
		aElemTipo[5][6] += Substr(cValData,ni,1)
		lOk := .T.
	Endif
	If Substr(cValData,ni,1) $ "-"
		If Substr(cValData,ni + 1,1) $ "0123456789"
			aElemTipo[2][2]++
			aElemTipo[2][6] += Substr(cValData,ni,1)		
		Else
			aElemTipo[1][2]++
			aElemTipo[1][6] += Substr(cValData,ni,1)		
		Endif
		aElemTipo[5][2]++
		aElemTipo[5][6] += Substr(cValData,ni,1)
		lOk := .T.		
	Endif
	If Substr(cValData,ni,1) $ cArrayD
		aElemTipo[1][2]++
		aElemTipo[1][6] += Substr(cValData,ni,1)
		aElemTipo[5][2]++
		aElemTipo[5][6] += Substr(cValData,ni,1)
		lOk := .T.
	Endif	
	If !lOk
		aElemTipo[1][2]++
		aElemTipo[1][6] += Substr(cValData,ni,1)
	Endif
Next ni
//Descartar os fora de padrao
For ni := 1 to Len(aElemTipo)
	//Se nao houver elementos
	If Empty(aElemTipo[ni][2])
		aElemTipo[ni][5] := .T.
	Else
		//Se o numero de elementos for inferior ao minimo ou superior ao maximo, descartar
		If aElemTipo[ni][2] < aElemTipo[ni][3] .OR. IIf(aElemTipo[ni][4] == 0, .F., aElemTipo[ni][2] > aElemTipo[ni][4])
			aElemTipo[ni][5] := .T.
		Else
			Do Case 
				Case aElemTipo[ni][1] == "A"
					If At("{",aElemTipo[ni][6]) == 0 .OR. At("}",aElemTipo[ni][6]) == 0
						aElemTipo[ni][5] := .T.
					Else
						If Substr(aElemTipo[ni][6],1,1) # "{" .OR. Substr(aElemTipo[ni][6],Len(aElemTipo[ni][6]),1) # "}"
							aElemTipo[ni][5] := .T.
						Else
							//Validar delimitadores
							For nx := 1 to Len(aArrayD)
								aArrayD[nx] := 0
							Next nx
							For nx := 1 to Len(aElemTipo[ni][6])
								If Substr(aElemTipo[ni][6],nx,1) $ cArrayD
									Do Case
										Case Substr(aElemTipo[ni][6],nx,1) == CHR(34)
											aArrayD[1]++
										Case Substr(aElemTipo[ni][6],nx,1) == "'"
											aArrayD[2]++
										Case Substr(aElemTipo[ni][6],nx,1) $ "[]"
											aArrayD[3]++
										Case Substr(aElemTipo[ni][6],nx,1) $ "{}"
											aArrayD[4]++
										Case Substr(aElemTipo[ni][6],nx,1) $ "()"
											aArrayD[5]++
									EndCase
								Endif 
							Next nx
							//Conferir
							For nx := 1 to Len(aArrayD)
								If aArrayD[nx] > 0
									If Mod(aArrayD[nx],2) # 0	//Numero impar - faltando delimitador
										aElemTipo[ni][5] := .T.
										Exit
									Endif
								Endif
							Next nx	
						Endif
					Endif
				Case aElemTipo[ni][1] == "D"
					nCont := 0
					For nx := 1 to Len(aElemTipo[ni][6])
						If Substr(aElemTipo[ni][6],nx,1) == "/"
							nCont++
						Endif
					Next nx
					//Caso nao exista os separadores de data ou o tamanho do elemento seja diferente da variavel ou nao seja uma data valida
					If nCont # 2 .OR. aElemTipo[ni][2] # Len(cValData)
						aElemTipo[ni][5] := .T.
					Else
						//Verificar se a data eh valida
						If Empty(CtoD(aElemTipo[ni][6]))
							//Verificar se a data esta no formato ano/mes/dia
							For nx := 1 to Len(aData)
								aData[nx] := ""
							Next nx
							nCont := 0
							For nx := 1 to Len(aElemTipo[ni][6])
								If Substr(aElemTipo[ni][6],nx,1) = "/"
									nCont++
								Endif
								If nCont == 0
									aData[3] += Substr(aElemTipo[ni][6],nx,1)
								ElseIf nCont == 1
									aData[2] += Substr(aElemTipo[ni][6],nx,1)
								Else
									aData[1] += Substr(aElemTipo[ni][6],nx,1)
								Endif
							Next nx
		                    If Empty(CtoD(aData[1] + "/" + aData[2] + "/" + aData[3]))
								//Verificar se a data nao esta no formato britanico
								For nx := 1 to Len(aData)
									aData[nx] := ""
								Next nx
								nCont := 0
								For nx := 1 to Len(aElemTipo[ni][6])
									If Substr(aElemTipo[ni][6],nx,1) = "/"
										nCont++
									Endif
									If nCont == 0
										aData[2] += Substr(aElemTipo[ni][6],nx,1)
									ElseIf nCont == 1
										aData[1] += Substr(aElemTipo[ni][6],nx,1)
									Else
										aData[3] += Substr(aElemTipo[ni][6],nx,1)
									Endif
								Next nx
			                    If Empty(CtoD(aData[1] + "/" + aData[2] + "/" + aData[3]))
			                    	aElemTipo[ni][5] := .T.
			                    Endif
			     			Endif
						Endif
					Endif
				Case aElemTipo[ni][1] == "L"
					If Substr(aElemTipo[ni][6],1,1) # "." .OR. !Substr(aElemTipo[ni][6],2,1) $ "T|F" .OR. Substr(aElemTipo[ni][6],3,1) # "."
						aElemTipo[ni][5] := .T.
					Else
						//Caso o tamanho do elemento seja diferente da variavel
						If aElemTipo[ni][2] # Len(cValData)
						 	aElemTipo[ni][5] := .T.
						Endif
					Endif
				Case aElemTipo[ni][1] == "N"
					nCont := 0
					For nx := 1 to Len(aElemTipo[ni][6])
						If Substr(aElemTipo[ni][6],nx,1) $ "0123456789."
							nCont++
						Endif
					Next nx
					//Caso nao exista numeros ou exista delimitador de data ou exista algum valor caracter
					If nCont == 0 .OR. At("/",cValData) > 0 .OR. !Empty(aElemTipo[1][6])
						If nCont # 0 .AND. At("/",cValData) == 0 .AND. !Empty(aElemTipo[1][6])
							nCont := 0
							For nx := 1 to Len(aElemTipo[1][6])
								If !Substr(aElemTipo[1][6],nx,1) $ "."
									nCont++
									Exit
								Endif
							Next nx
							If nCont > 0
								aElemTipo[ni][5] := .T.
							Endif
						Else
							aElemTipo[ni][5] := .T.
						Endif
					Else
						//Verificar se existe mais de um separador decimal, o que invalida o conteudo como numero
						If At(".",aElemTipo[1][6]) # Rat(".",aElemTipo[1][6])
							aElemTipo[ni][5] := .T.
						Endif
					Endif
			EndCase
		Endif
	Endif	
Next ni
//Guardar apenas os remanescentes para comparacao
For ni := 1 to Len(aElemTipo)
	If !aElemTipo[ni][5]
		aAdd(aResultado,aElemTipo[ni])
	Endif
Next ni
//Se necessario, determinar qual o tipo de dados pela prioridade (ordem crescente)
If Len(aResultado) == 1
	cTipo := aResultado[1][1]
Else
	aSort(aResultado,,,{|x,y| x[7] < x[7]})
	cTipo := aResultado[1][1]
Endif

Return cTipo

/*                                                  	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³InsArray  ºAutor  ³Vendas Clientes       º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para incluir uma nova posicao dentro de uma array de   º±±
±±º          ³destino.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function InsArray(aREGOri,aREGDest,nPosD)

Local lRet				:= .F.
Local ni				:= 0
Local nx				:= 0
Local aTMP				:= {}
Local nTotal			:= 0
Local nTotal02			:= 0
Local lZera				:= .F.

Default aREGOri		:= {}
Default aREGDest		:= {}
Default nPosD			:= 1

If Len(aREGOri) == 0 .OR. Len(aREGDest) == 0 .OR. ValType(aREGOri) # "A" .OR. ValType(aREGDest) # "A" .OR. ValType(nPosD) # "N" .OR. Empty(nPosD)
	Return lRet
Endif
//Verificar se a array de origem esta encapsulada dentro de outra array, senao encapsular
If ValType(aREGORI[1]) # "A"
	aAdd(aTMP,aREGOri)
	aREGOri := aClone(aTMP)
	aTMP := {}
Endif
If Len(aREGDest) == 0
	lZera := !lZera
Else
	If Len(aREGOri[1]) # Len(aREGDest[1])
		Return lRet
	Endif
Endif
nTotal 		:= Len(aREGDest)
nTotal02	:= Len(aREGOri)
If !lZera
	If nPosD <= Len(aREGDest)
		//Posicao inferior ou igual ao limite da array de destino
		For ni := 1 to nTotal
			If ni == nPosD
				For nx := 1 to nTotal02
					aAdd(aTMP,aREGOri[nx])
				Next nx
			Endif
			aAdd(aTMP,aREGDest[ni])
		Next nx
	Else
		//Posicao superior ao limite da array de destino, inserir no final da array
		aTMP := aClone(aREGDest)
		For nx := 1 to nTotal02
			aAdd(aTMP,aREGOri[nx])
		Next nx
	Endif
Else
	For nx := 1 to nTotal02
		aAdd(aTMP,aREGOri[nx])
	Next nx
Endif
aREGDest := aClone(aTMP)
	
Return !lRet

/*                                                  	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AtTipoDadoºAutor  ³Vendas Clientes       º Data ³  31/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para retornar uma array com os tipos de dados contidos º±±
±±º          ³nos elementos de uma array de dados.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Generico                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*Static Function AtTipoDado(aREG)

Local aRet				:= {}

Default aREG			:= {}

//If ValTLen(aREG) == 0 

Return aRet */
