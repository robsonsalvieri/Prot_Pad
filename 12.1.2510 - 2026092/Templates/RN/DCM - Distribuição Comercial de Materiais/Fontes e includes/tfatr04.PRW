#INCLUDE "TFATR04.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Rdmake   ³ TFATR04                                ³ Data ³ 27/06/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor    ³ VEndas Clientes                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de comissao por vendedor                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Template Function TFATR04

CHKTEMPLATE("DCM")  

Private cString      := "SA3"
Private lEnd         := .F.
Private limite       := 132
Private tamanho		 := "M"
Private M_Pag        := 1
Private nomeprog     := "TFATR04"
Private nTipo        := 18
Private aReturn		 := { STR0001, 1, STR0002, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cArqDbf		 := ""
Private wnrel        := "TFATR04"
Private cDesc1       := STR0003 //"Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := STR0004 //"de acordo com os parametros informados pelo usuario."
Private cDesc3       := STR0005 //"Comissao por vendedor"
Private aOrd         := {}
Private titulo       := STR0006 //"Comissoes por Vendedor"
Private nLin         := 80
Private Cabec1       := STR0007 //"EMISSAO   DCTO   CLIENTE                                             B.CALCULO      %   COMISSAO   OBSSERVACOES"
//                          99/99/99 999999 999999 1234567890123456789012345678901234567890 999,999,999.99  99.99 999,999.99  123456789012345678901234567890
//                          01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456790123456790123456789012
//                                    1         2         3         4         5         6         7         8         9         0        1        2         3
Private Cabec2       := ""
Private nOrdem       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(Padr("TFAT04",Len(SX1->X1_GRUPO)) ,.F.)
DbSelectArea("SA3")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,"TFAT04",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Rdmake   ³ RunReport                              ³ Data ³ 27/06/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor    ³ Vendas Clientes                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa o Relatorio de comissao por vendedor    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem    := aReturn[8]
Local cCondFat  := ""
Local _cDepto   := ""
Local _cDescVe  := ""
Local _nX	    := 0
Local cAliasTFA := ""
Local cArqTRA	:= ""
Local aStruct	:= {}

AAdd(aStruct,{"VENDEDOR","C",6 ,0}) //"VENDEDOR"
AAdd(aStruct,{"EMISSAO" ,"D",8 ,0}) //"EMISSAO"
AAdd(aStruct,{"DCTO"    ,"C",6 ,0}) //"DCTO"
AAdd(aStruct,{"CLIENTE" ,"C",6 ,0}) //"CLIENTE"
AAdd(aStruct,{"PERCOM"  ,"N",7 ,2}) //"PERCOM"
AAdd(aStruct,{"BCALCULO","N",12,2}) //"BCALCULO"
AAdd(aStruct,{"COMISSAO","N",12,2}) //"COMISSAO"

cAliasTFA 	:= GetNextAlias()
cArqTRA 	:= CriaTrab(aStruct,.T.)
dbUseArea(.T.,,cArqTRA,cAliasTFA,.F.,.F.)

Processa({||Monta_TFA(@cAliasTFA)})

DbSelectArea(cAliasTFA)
SetRegua(RecCount())
DbGotop()

_dEmissao := CtoD('  /  /  ')
_cDcto    := ''
_cVend    := ''
_nTotBCalculo := 0
_nTotComissao := 0
_aPerCom  := {}

While (cAliasTFA)->(!Eof())
	IncRegua()
	
	If nLin > 55 .OR. (_cVend <> (cAliasTFA)->VENDEDOR .AND. MV_PAR07 = 1)
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin      := 8
		_cVend    := AllTrim((cAliasTFA)->VENDEDOR)
		_dEmissao := CtoD('  /  /  ')
		_cDcto    := ''
		_cDescVe  := _cVend+' - '+Posicione("SA3",1,xFilial("SA3")+_cVend,"A3_NOME")
		_cPosto   := Posicione('SU7',3,xFilial('SU7')+Alltrim(SA3->A3_NOME),'U7_POSTO')
		_cDepto   := Posicione('SU0',1,xFilial('SU0')+_cPosto,'U0_NOME')
		@nLin,00 PSAY _cDescVe + ' - ' + _cDepto
		nLin+=2
	ElseIf (_cVend <> (cAliasTFA)->VENDEDOR .AND. MV_PAR07 = 2)
		_cVend    := AllTrim((cAliasTFA)->VENDEDOR)
		_dEmissao := CtoD('  /  /  ')
		_cDcto    := ''
		_cDescVe  := _cVend+' - '+Posicione("SA3",1,xFilial("SA3")+_cVend,"A3_NOME")
		_cPosto   := Posicione('SU7',3,xFilial('SU7')+Alltrim(SA3->A3_NOME),'U7_POSTO')
		_cDepto   := Posicione('SU0',1,xFilial('SU0')+_cPosto,'U0_NOME')
		nLin+=2		
		@nLin,00 PSAY _cDescVe + ' - ' + _cDepto
		nLin+=2
	EndIf
	
	If _dEmissao <> (cAliasTFA)->EMISSAO
		@nLin,00 PSAY (cAliasTFA)->EMISSAO
		_dEmissao := (cAliasTFA)->EMISSAO
	EndIf
	If _cDcto <> (cAliasTFA)->DCTO
		@nLin,09 PSAY (cAliasTFA)->DCTO
		@nLin,16 PSAY (cAliasTFA)->CLIENTE
		@nLin,23 PSAY Posicione('SA1',1,xFilial('SA1')+(cAliasTFA)->CLIENTE,'A1_NOME')
		_cDcto := (cAliasTFA)->DCTO
	EndIf
	@nLin,64 PSAY (cAliasTFA)->BCALCULO PICTURE "@ER 999,999,999.99"
	@nLin,80 PSAY (cAliasTFA)->PERCOM   PICTURE "@ER 999.99"
	@nLin,86 PSAY (cAliasTFA)->COMISSAO PICTURE "@ER 999,999.99"
	nLin++
	
	If AsCan(_aPerCom,{|x|Str(x[1],6,2)=Str((cAliasTFA)->PERCOM,6,2)}) = 0
		AaDd(_aPerCom,{(cAliasTFA)->PERCOM,(cAliasTFA)->BCALCULO,(cAliasTFA)->COMISSAO})
	Else
		_aPerCom[AsCan(_aPerCom,{|x|x[1]=(cAliasTFA)->PERCOM}),2] += (cAliasTFA)->BCALCULO
		_aPerCom[AsCan(_aPerCom,{|x|x[1]=(cAliasTFA)->PERCOM}),3] += (cAliasTFA)->COMISSAO
	EndIf
	_nTotBCalculo += (cAliasTFA)->BCALCULO
	_nTotComissao += (cAliasTFA)->COMISSAO
	
	DbSkip()
	
	If _dEmissao <> (cAliasTFA)->EMISSAO .OR. _cDcto <> (cAliasTFA)->DCTO
		nLin++
	EndIf
	
	If _cVend <> (cAliasTFA)->VENDEDOR .AND. MV_PAR07 = 1
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin      := 8
			@nLin,00 PSAY _cDescVe + ' - ' + _cDepto
			nLin+=2
		Else
			++nLin
		EndIf
		@nLin,00 PSAY 'TOTAL ->'
		@nLin,64 PSAY _nTotBCalculo PICTURE "@ER 999,999,999.99"
		@nLin,86 PSAY _nTotComissao PICTURE "@ER 999,999.99"
		nLin += 2
		@nLin,00 PSAY 'RESUMO ->'
		ASort(_aPerCom,,,{|x,y|x[1]<y[1]})
		For _nX := 1 To Len(_aPerCom)
			@nLin,15 PSAY 'P '+Transform(_aPerCom[_nX,1],"@er 999.99")
			@nLin,35 PSAY _aPerCom[_nX,2] PICTURE "@ER 999,999,999.99"
			@nLin,55 PSAY _aPerCom[_nX,3] PICTURE "@ER 999,999.99"
			@nLin,75 PSAY Round((_aPerCom[_nX,3]/_nTotComissao)*100,2) PICTURE "@ER 999.99%"
			nLin++
		Next
		_aPerCom := {}
		_nTotBCalculo := 0
		_nTotComissao := 0
		
	EndIf
	
End

If MV_PAR07 = 2
	If nLin > 55
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin      := 8
		@nLin,00 PSAY _cDescVe + ' - ' + _cDepto
	EndIf
	nLin+=3
	@nLin,00 PSAY 'TOTAL ->'
	@nLin,64 PSAY _nTotBCalculo PICTURE "@ER 999,999,999.99"
	@nLin,86 PSAY _nTotComissao PICTURE "@ER 999,999.99"
	nLin += 2
	@nLin,00 PSAY 'RESUMO ->'
	ASort(_aPerCom,,,{|x,y|x[1]<y[1]})
	For _nX := 1 To Len(_aPerCom)
		@nLin,15 PSAY 'P '+Transform(_aPerCom[_nX,1],"@ER 999.99")
		@nLin,35 PSAY _aPerCom[_nX,2] PICTURE "@ER 999,999,999.99"
		@nLin,55 PSAY _aPerCom[_nX,3] PICTURE "@ER 999,999.99"
		@nLin,75 PSAY Round((_aPerCom[_nX,3]/_nTotComissao)*100,2) PICTURE "@ER 999.99%"
		nLin++
	Next
EndIf

DbSelectArea(cAliasTFA)
(cAliasTFA)->(dbCloseArea())

Set Device to Screen

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	Set Printer to
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Rdmake   ³ Monta_Tfa                              ³ Data ³ 27/06/2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor    ³ Vendas Clientes                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta query                                      		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Monta_Tfa(cAliasTFA)
Local _cQuery 	 := ""	//Query a ser montada
Local _nCount 	 := 0	//Numero de registros processados pela query
Local _nX	  	 := 0	//Controle de loop	
Local cD2_CF	 := " SUBSTRING(D2_CF,2,3) IN " 
Local cMV_CFRELS := SuperGetMv('MV_CFRELS',.F.,"'12','102','108','904'")	//Conteudo do parameteo MV_CFRELS

//Evita erro na execucao da query se o parametro MV_CFRELS existir mas estiver vazio 
If Empty(cMV_CFRELS)
	cMV_CFRELS := "'12','102','108','904'"
EndIf

For _nX := 1 To 2
	If _nX = 1
		_cQuery := "SELECT Count(DISTINCT F2_VEND1+F2_EMISSAO+D2_DOC) AS TOTAL FROM "
	Else
		_cQuery := "SELECT DISTINCT F2_VEND1 AS VENDEDOR,F2_EMISSAO AS EMISSAO,"
		_cQuery += "D2_DOC AS DCTO, F2_CLIENTE AS CLIENTE,C6_PERCOM AS PERCOM,SUM(D2_TOTAL) AS BCALCULO, SUM(D2_TOTAL*(C6_PERCOM/100)) AS COMISSAO FROM "
	EndIf
	_cQuery += RetSqlName("SD2")+" SD2 , "
	_cQuery += RetSqlName("SF2")+" SF2 , "
	_cQuery += RetSqlName("SU7")+" SU7 , "
	_cQuery += RetSqlName("SA3")+" SA3 , "
	_cQuery += RetSqlName("SC6")+" SC6  "
	_cQuery += " WHERE "
	_cQuery += "SD2.D_E_L_E_T_ <> '*' AND "
	_cQuery += "SF2.D_E_L_E_T_ <> '*' AND "
	_cQuery += "SA3.D_E_L_E_T_ <> '*' AND "
	_cQuery += "SC6.D_E_L_E_T_ <> '*' AND "
	_cQuery += "SU7.D_E_L_E_T_ <> '*' AND "
	If !Empty(MV_PAR06)
		_cQuery += "SD2.D2_FILIAL = '"+MV_PAR06+"' AND "
		_cQuery += "SF2.F2_FILIAL = '"+MV_PAR06+"' AND "
		_cQuery += "SC6.C6_FILIAL = '"+MV_PAR06+"' AND "
		_cQuery += "SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND "
		_cQuery += "SU7.U7_FILIAL = '"+xFilial("SU7")+"' AND "
	EndIf
	_cQuery += " D2_DOC = F2_DOC AND "
	_cQuery += " D2_SERIE = F2_SERIE AND "
	_cQuery += " D2_FILIAL = F2_FILIAL AND "
	_cQuery += " D2_FILIAL = C6_FILIAL AND "
	_cQuery += " D2_DOC = C6_NOTA AND "
	_cQuery += " D2_SERIE = C6_SERIE AND "
	_cQuery += " D2_COD = C6_PRODUTO AND "
	_cQuery += " F2_VEND1 >= '"+MV_PAR01+"' AND "
	_cQuery += " F2_VEND1 <= '"+MV_PAR02+"' AND "
	_cQuery += " F2_VEND1 = U7_CODVEN AND "
	_cQuery += " F2_VEND1 = A3_COD AND "
	_cQuery += " D2_EMISSAO >= '"+DTOS(MV_PAR03)+"' AND "
	_cQuery += " D2_EMISSAO <= '"+DTOS(MV_PAR04)+"' AND "
	_cQuery += " D2_TIPO = 'N' AND "
	_cQuery += cD2_CF +" (" +cMV_CFRELS+ ")" +" "
	If !Empty(MV_PAR05)
		_cQuery += " AND U7_POSTO  = '"+MV_PAR05+"' "
	EndIf
	If _nX = 2
		_cQuery += " GROUP BY F2_VEND1, F2_EMISSAO, D2_DOC, F2_CLIENTE, C6_PERCOM "
		_cQuery += " ORDER BY F2_VEND1, F2_EMISSAO, D2_DOC, F2_CLIENTE, C6_PERCOM "
	EndIf
	// AND D2_ITEMPV = C6_ITEM
	
	
	
	_cQuery := ChangeQuery(_cQuery)
	
	TCQUERY _cQuery NEW ALIAS "QUERY"
	
	If _nX = 1
		_nCount := QUERY->TOTAL
		DbCloseArea()
	EndIf
	
Next

TcSetField('QUERY','EMISSAO','D')

DbSelectArea("QUERY")
ProcRegua(_nCount)
DbGotop()

While !Eof()
	IncProc()
	RecLock(cAliasTFA,.T.)
	(cAliasTFA)->VENDEDOR := QUERY->VENDEDOR
	(cAliasTFA)->PERCOM   := QUERY->PERCOM
	(cAliasTFA)->DCTO     := QUERY->DCTO
	(cAliasTFA)->EMISSAO  := QUERY->EMISSAO
	(cAliasTFA)->CLIENTE  := QUERY->CLIENTE
	(cAliasTFA)->PERCOM   := QUERY->PERCOM
	(cAliasTFA)->BCALCULO := QUERY->BCALCULO
	(cAliasTFA)->COMISSAO := QUERY->COMISSAO
	MsUnLock()
	
	DbSelectArea("QUERY")
	DbSkip()
End

DbSelectArea("QUERY")
DbCloseArea()

Return