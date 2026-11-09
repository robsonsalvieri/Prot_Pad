#Include "Protheus.ch"
#Include "WMSA170.CH"

#DEFINE WMSA17001 "WMSA17001"
#DEFINE WMSA17002 "WMSA17002"
#DEFINE WMSA17003 "WMSA17003"
#DEFINE WMSA17004 "WMSA17004"
#DEFINE WMSA17005 "WMSA17005"
#DEFINE WMSA17006 "WMSA17006"
#DEFINE WMSA17007 "WMSA17007"
#DEFINE WMSA17008 "WMSA17008"
#DEFINE WMSA17009 "WMSA17009"
#DEFINE WMSA17010 "WMSA17010"
#DEFINE WMSA17011 "WMSA17011"
#DEFINE WMSA17012 "WMSA17012"
#DEFINE WMSA17013 "WMSA17013"
#DEFINE WMSA17014 "WMSA17014"
#DEFINE WMSA17015 "WMSA17015"
#DEFINE WMSA17016 "WMSA17016"
#DEFINE WMSA17017 "WMSA17017"
#DEFINE WMSA17018 "WMSA17018"
#DEFINE WMSA17019 "WMSA17019"
#DEFINE WMSA17020 "WMSA17020"
#DEFINE WMSA17021 "WMSA17021"
#DEFINE WMSA17022 "WMSA17022"
#DEFINE WMSA17023 "WMSA17023"
#DEFINE WMSA17024 "WMSA17024"

//----------------------------------------------------------
/*/{Protheus.doc} WMSA170
Gera Enderecos a partir de uma Estrutura Definida
@author Denilson
@version 2.0
@since 22/01/2001
@obs Richard - 21.06.01 -> Gerar codigo do endereço com letras e validacao na digitacao dos intervalos.
/*/
//----------------------------------------------------------
Function WMSA170()
Local aObjects	:= {}
Local aPosObj    := {}
Local aInfo      := {}
Local aSize      := {}
Local aTamSX3    := {}
Local cDesCfg    := CriaVar('DC7_DESCFG',.F.)
Local cDesEst    := CriaVar('DC8_DESEST',.F.)
Local cDesZon    := CriaVar('DC4_DESZON',.F.)
Local cWMA170Exc := CriaVar('DCL_CODIGO',.F.)
Local cDesExc    := CriaVar('DCL_DESCOD',.F.)
Local nX         := 0
Local lRet       := .T.
Local lEnd       := .F.
Local oDlg
Local oGet1
Local oGet2
Local oGet3
Local oGetD

Private aHeader    := {}
Private aCols      := {}
Private cWMA170Cfg := CriaVar('DC7_CODCFG',.F.)
Private cWMA170EFi := CriaVar('DC8_CODEST',.F.)
Private cWMA170Zon := CriaVar('DC4_CODZON',.F.)
Private cWMA170Arm := CriaVar('BE_LOCAL'  ,.F.)
Private cCadastro  := STR0001 // Geracao de Enderecos
Private aRotina    := {{'', 'AxPesqui', 0, 1}, ;
	{'', 'AxVisual', 0, 2}, ;
	{'', 'AxInclui', 0, 3}, ;
	{'', 'AxAltera', 0, 4}, ;
	{'', 'AxDeleta', 0, 5}}
Private cPerg := 'Sim'

	// aHeader
	aAdd(aHeader, {RetTitle('DC7_SEQUEN'), 'DC7_SEQUEN', PesqPict('DC7','DC7_SEQUEN')	, (aTamSX3:=TamSX3('DC7_SEQUEN'))[1], aTamSX3[2], '.T.'				, 'û', 'C', '  ', ' '})
	aAdd(aHeader, {RetTitle('DC7_DESEND'), 'DC7_DESEND', PesqPict('DC7','DC7_DESEND')	, (aTamSX3:=TamSX3('DC7_DESEND'))[1], aTamSX3[2], '.T.'				, 'û', 'C', '  ', ' '})
	aAdd(aHeader, {STR0002               , 'TB_INIC'   , '@!'									, 03                                 , 0         , 'WMA170Vld()'	, 'û', 'C', '  ', ' '})//'Inicio'
	aAdd(aHeader, {STR0003               , 'TB_FIM'    , '@!'									, 03                                 , 0         , 'WMA170Vld()'	, 'û', 'C', '  ', ' '})//'Final'
	aAdd(aHeader, {STR0004               , 'TB_INT'    , '@E 999'								, 03                                 , 0         , 'Positivo()'	, 'û', 'N', '  ', ' '})//'Intervalo'
	ADHeadRec("DC7",aHeader)

	// Dimensoes Especificas
	aSize   := MsAdvSize()
	aAdd(aObjects, {100, 073, .T., .F.})
	aAdd(aObjects, {100, 100, .T., .T.})
	aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
	aPosObj := MsObjSize(aInfo, aObjects)

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	@ aPosObj[1,1]+04, aPosObj[1,2]+01  SAY RetTitle('DC7_CODCFG') PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+03, aPosObj[1,2]+48  MSGET cWMA170Cfg F3 'DC7' SIZE 53,08 PICTURE PesqPict('DC7','DC7_CODCFG') VALID WMA170CfgE(cWMA170Cfg, @cDesCfg, @oGetD) PIXEL
	@ aPosObj[1,1]+04, aPosObj[1,2]+108 SAY RetTitle('DC7_DESCFG') PIXEL
	@ aPosObj[1,1]+03, aPosObj[1,2]+148 MSGET oGet1 Var cDesCfg SIZE 100,08 PIXEL WHEN .F.

	@ aPosObj[1,1]+19, aPosObj[1,2]+01  SAY RetTitle('DC8_CODEST') PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+18, aPosObj[1,2]+48  MSGET cWMA170EFi F3 'DC8' SIZE 53,08 PICTURE PesqPict('DC8','DC8_CODEST') VALID WMA170Estr(cWMA170EFi, @cDesEst) PIXEL
	@ aPosObj[1,1]+19, aPosObj[1,2]+108 SAY RetTitle('DC8_DESEST') PIXEL
	@ aPosObj[1,1]+18, aPosObj[1,2]+148 MSGET oGet2 Var cDesEst SIZE 100,08 PIXEL WHEN .F.

	@ aPosObj[1,1]+34, aPosObj[1,2]+01  SAY RetTitle('DC4_CODZON') PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+33, aPosObj[1,2]+48  MSGET cWMA170Zon F3 'DC4' SIZE 53,08 PICTURE PesqPict('DC4','DC4_CODZON') VALID WMA170Zona(cWMA170Zon, @cDesZon) PIXEL
	@ aPosObj[1,1]+34, aPosObj[1,2]+108 SAY RetTitle('DC4_DESZON') PIXEL
	@ aPosObj[1,1]+33, aPosObj[1,2]+148 MSGET oGet3 Var cDesZon SIZE 100,08 PIXEL WHEN .F.

	@ aPosObj[1,1]+49, aPosObj[1,2]+01  SAY RetTitle('DCL_CODIGO') PIXEL
	@ aPosObj[1,1]+48, aPosObj[1,2]+48  MSGET cWMA170Exc F3 'DCL' SIZE 53,08 PICTURE PesqPict('DCL','DCL_CODIGO') VALID WMA170Exce(cWMA170Exc, @cDesExc) PIXEL
	@ aPosObj[1,1]+49, aPosObj[1,2]+108 SAY RetTitle('DCL_DESCOD') PIXEL
	@ aPosObj[1,1]+48, aPosObj[1,2]+148 MSGET oGet3 Var cDesExc SIZE 100,08 PIXEL WHEN .F.

	@ aPosObj[1,1]+64, aPosObj[1,2]+01  SAY RetTitle('BE_LOCAL') PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+63, aPosObj[1,2]+48  MSGET cWMA170Arm F3 'NNR' SIZE 18,08 PICTURE PesqPict('SBE','BE_LOCAL') VALID VldArmazem(cWMA170Arm) PIXEL
	@ aPosObj[1,1]+64, aPosObj[1,2]+88  SAY STR0019 SIZE 120,08 PIXEL // Incrementa utilizando primeiramente números?
	@ aPosObj[1,1]+63, aPosObj[1,2]+208 MSCOMBOBOX cPerg ITEMS {STR0020,STR0021} PIXEL // Sim  Não

	oGetD := MSGetDados():New(aPosObj[2,1], aPosObj[2,2], aPosObj[2,3], aPosObj[2,4], 3, 'WMA170LiOk()', 'WMA170TdOk()', '', .F.,{'TB_INIC', 'TB_FIM', 'TB_INT'},,,Len(aCols))

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(WMA170TdOk(),(Processa({|lEnd| lRet:=WMA170Gera(cWMA170Cfg, cWMA170EFi, cWMA170Zon, cWMA170Exc, cWMA170Arm)}, STR0001),If(lRet,oDlg:End(),Nil)),Nil)},{||lRet:=.F.,oDlg:End()})//'Geracao de Enderecos'
Return Nil

/*---------------------------------------------------------------------------
---WMA170CfgE
---Valida a Configuração de Enderecos Digitado
---Denilson 22/01/2001
---cCodCfg, Character, (Codigo da Configura‡ao de Enderecos)
---cDesCfg, Character, (Descrição da Configuração de Endereços)
---oGetD, Objeto, (Item da Get Dados a ser atualizado)
---------------------------------------------------------------------------*/
Static Function WMA170CfgE(cCodCfg, cDesCfg, oGetD)
Local aAreaAnt := GetArea()
Local aAreaDC7 := DC7->(GetArea())
Local cSeekDC7 := ''
Local nCntFor  := 0
Local nSeek    := 0
Local nMaxTam  := 0
Local nPosDC7  := 0
Local lRet     := .T.

Default cCodCfg := ''
Default cDesCfg := ''

	If	!NaoVazio(cCodCfg)
		Return(.F.)
	EndIf
	// Posiciona a configuracao do codigo do endereco
	DC7->(DbSetOrder(1))
	If	DC7->(MsSeek(cSeekDC7:=xFilial('DC7')+cCodCfg))
		cDesCfg	:= DC7->DC7_DESCFG
		nPosDC7	:= DC7->(Recno())
		While DC7->(!Eof() .And. DC7->DC7_FILIAL+DC7->DC7_CODCFG == cSeekDC7)
			nMaxTam := Max(nMaxTam,DC7->DC7_POSIC)
			DC7->(DbSkip())
		EndDo
		DC7->(MsGoTo(nPosDC7))
		aHeader[3,4]:=nMaxTam
		aHeader[4,4]:=nMaxTam
		aCols		:= {}
		n			:= 1
		While DC7->(!Eof() .And. DC7->DC7_FILIAL+DC7->DC7_CODCFG == cSeekDC7)
			AAdd(aCols,Array(Len(aHeader)+1))
			For nCntFor := 1 To Len(aHeader)
				If IsHeadAlias(aHeader[nCntFor, 2])
					aCols[Len(aCols), nCntFor] := "DC7"
				ElseIf IsHeadRec(aHeader[nCntFor, 2])
					aCols[Len(aCols), nCntFor] := DC7->(RecNo())
				ElseIf (nSeek:=DC7->(FieldPos(aHeader[nCntFor,2])))>0
					aCols[Len(aCols),nCntFor] := DC7->(FieldGet(nSeek))
				Else
					If	aHeader[nCntFor,8] == 'C'
						aCols[Len(aCols),nCntFor] := Space(aHeader[nCntFor,4])
					ElseIf aHeader[nCntFor,2] == 'TB_INT'
						aCols[Len(aCols),nCntFor] := 1
					EndIf
				EndIf
			Next
			aCols[Len(aCols),Len(aHeader)+1] := .F.
			DC7->(DbSkip())
		EndDo
		oGetD:oBrowse:Refresh()
	Else
		WmsMessage(STR0022,WMSA17011,,,,STR0023) // Selecione uma configuração de endereços cadastrada ou realize o cadastramento de uma nova configuração. (Arquivo utilizado: DC7)
		lRet := .F.
	EndIf
	RestArea(aAreaDC7)
	RestArea(aAreaAnt)
Return(lRet)
/*---------------------------------------------------------------------------
---WMA170Estr
---Valida a Estrutura Fisica Digitada
---Denilson 22.01.2001
---cCodEst, Character, Codigo da Estrutura Fisica
---cDesEst, Character, Descrição da Estrutura Fisica
---------------------------------------------------------------------------*/
Function WMA170Estr(cCodEst, cDesEst)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaDC8   := DC8->(GetArea())

Default cCodEst  := ""
Default cDesEst  := ""
	If (lRet:=NaoVazio(cCodEst))
		dbSelectArea('DC8')
		dbSetOrder(1)
		If dbSeek(xFilial('DC8')+cCodEst, .F.)
			cDesEst := DC8_DESEST
		Else
			WmsMessage(STR0024,WMSA17012,,,,STR0025) // A estrutura física digitada não foi encontrada nos cadastros. // Selecione uma estrutura física já cadastrada ou cadastre uma nova estrutura. (Arquivo atualizado: DC8)
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaDC8)
	RestArea(aAreaAnt)
Return lRet
/*---------------------------------------------------------------------------
---WMA170Zona
---Valida a Zona de Armazenagem Digitada
---Fernando Joly 14/03/2001
---cCodZon, Character, Codigo da Zona
---cDesZon, Character, Descrição Zona
---------------------------------------------------------------------------*/
Function WMA170Zona(cCodZon, cDesZon)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaDC4   := DC4->(GetArea())

Default cCodZon  := ""
Default cDesZon  := ""
	If (lRet:=NaoVazio(cCodZon))
		dbSelectArea('DC4')
		dbSetOrder(1)
		If dbSeek(xFilial('DC4')+cCodZon, .F.)
			cDesZon := DC4_DESZON
		Else
			WmsMessage(STR0026,WMSA17013,,,,STR0027) // A zona de armazenagem digitada não foi encontrada nos cadastros. // Selecione uma zona de armazenagem já cadastrada ou cadastre uma nova zona de armazenagem. (Arquivo atualizado: DC4).
			lRet := .F.
		EndIf
	EndIf
	RestArea(aAreaDC4)
	RestArea(aAreaAnt)
Return lRet
/*---------------------------------------------------------------------------
---WMA170Exce
---Valida a Excecao a Atividades Digitada
---Fernando Joly 20/08/2001
---cCodExc, Character, Codigo da Excecao
---cDesExc, Character, Descrição da Excecao
---------------------------------------------------------------------------*/
Function WMA170Exce(cCodExc, cDesExc)
Local lRet       := .T.
Local aAreaAnt   := GetArea()
Local aAreaDCL   := DCL->(GetArea())

Default cCodExc  := ""
Default cDesExc  := ""
	If !Empty(cCodExc)
		dbSelectArea('DCL')
		dbSetOrder(1)
		If dbSeek(xFilial('DCL')+cCodExc, .F.)
			cDesExc := DCL_DESCOD
		Else
			WmsMessage(STR0028,WMSA17014,,,,STR0029) // A exceção digitada não foi encontrada nos cadastros. // Este campo não é obrigatório, mas se desejar que o intervalo de endereços gerados possua uma exceção, selecione uma já cadastrada ou cadastre uma nova. (Arquivo atualizado: DCL)
			lRet := .F.
		EndIf
	Else
		cDesExc := ""
	EndIf

	RestArea(aAreaDCL)
	RestArea(aAreaAnt)
Return lRet
/*---------------------------------------------------------------------------
---WMA170Gera
---Gera os Endereços
---Denilson 22/01/2001
---cCodCfg, Character, Codigo da Configuracao
---cCodEst, Character, Codigo da Estrutura Fisica
---cCodZon, Character, Codigo da Zona de Armazenamento
---cCodExc, Character, Codigo da Excecao
---cArmazem , Character, Armazem
---------------------------------------------------------------------------*/
Function WMA170Gera(cCodCfg, cCodEst, cCodZon, cCodExc, cArmazem)
Local aEnderecos := {}
Local aNiveis    := {}
// Se preenchido sera utilizado pelo WMS na rotina de "Geracao de Enderecos" para definir a Descricao co endereco (BE_DESCRIC) para os enderecos gerados.
Local cDescEnd   := SuperGetMV("MV_DESCEND",.F.,"")
Local cTamEndCad := AllTrim(Str(TamSX3('BE_LOCALIZ')[1]))
Local cTamEndGer := ""
Local cEndExemp  := ""
Local nX         := 0
Local nY         := 0
Local nPosIni    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INIC'})
Local nPosFim    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_FIM'})
Local nPosInt    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INT'})
Local lRet       := .T.

Default cCodCfg  := ''
Default cCodEst  := ''
Default cCodZon  := ''
Default cCodExc  := ''
Default cArmazem := ''

	ProcRegua(Len(aCols))
	For nX := 1 To Len(aCols)
		IncProc(STR0005) // Gerando os Niveis ...
		AAdd(aNiveis,{})
		cIntIni := AllTrim(aCols[nX,nPosIni])
		cIntFim := AllTrim(aCols[nX,nPosFim])
		AAdd(aNiveis[nX], cIntIni)
		While cIntIni < cIntFim
		For nY := 1 To aCols[nX,nPosInt]
			If cPerg == STR0020 //Sim
				IncStrAlfa(@cIntIni,Len(cIntIni))
			Else
				cIntIni := Soma1(cIntIni)
			EndIf
		Next nY
		AAdd(aNiveis[nX], cIntIni)
		EndDo
	Next nX
	If Len(aNiveis)==1
		cEndExemp  := aNiveis[1,1]
		cTamEndGer := AllTrim(Str(Len(cEndExemp)))
		If Len(cEndExemp)>TamSX3('BE_LOCALIZ')[1]
			WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cTamEndGer},{"[VAR02]",cEndExemp},{"[VAR03]",cTamEndCad}}),WMSA17001,10,,{STR0007}) // O endereço gerado, que possui '[VAR01]' posições (Ex.:'[VAR02]'), é maior que o campo no cadastro de endereços (que tem '[VAR03]' posições. A geração não poderá ser gravada... // Ok
			lRet := .F.
		Else
			lRet := WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]",Str(Len(aNiveis[1]))}}),WMSA17002,3 /*MSG_QUESTION*/) // Esta configuração irá gerar [VAR01] endereços. Confirma a geração? // Sim // Não
			If lRet
				WMA170Grv(aNiveis[1], cCodCfg, cCodEst, cCodZon, cCodExc, cArmazem, cDescEnd)
			EndIf
		EndIf
	ElseIf Len(aNiveis) > 1
		// Realiza a Combina‡ao dos Niveis
		ProcRegua(Len(aNiveis))
		IncProc(STR0009) // Combinando os Niveis...
		aEnderecos := WMA170Comb(aNiveis[1], aNiveis[2])
		For nX := 3 to Len(aNiveis)
			IncProc(STR0009) // Combinando os Niveis...
			aEnderecos := WMA170Comb(aEnderecos, aNiveis[nX])
		Next nX
		cTamEndGer := AllTrim(Str(Len(aEnderecos[1])))
		cEndExemp  := aEnderecos[1]
		If Len(aEnderecos[1])>TamSX3("BE_LOCALIZ")[1]
			WmsMessage(WmsFmtMsg(STR0006,{{"[VAR01]",cTamEndGer},{"[VAR02]",cEndExemp},{"[VAR03]",cTamEndCad}}),WMSA17003,10,,{STR0007}) // O endereço gerado, que possui [VAR01] posições (Ex.:[VAR02]), é maior que o campo no cadastro de endereços (que tem [VAR03] posições. A geração não poderá ser gravada... // Ok
			lRet := .F.
		Else
			lRet := WmsMessage(WmsFmtMsg(STR0008,{{"[VAR01]",Str(Len(aEnderecos))}}),WMSA17004,3 /*MSG_QUESTION*/) // Esta configuração irá gerar [VAR01] endereços. Confirma a geração? // Sim // Não
			If lRet
				WMA170Grv(aEnderecos, cCodCfg, cCodEst, cCodZon, cCodExc, cArmazem, cDescEnd)
			EndIf
		EndIf
	Else
		WmsMessage(STR0010,WMSA17005,5/*MSG_HELP*/) // Não é possivel excluir o unitizador, pois o  mesmo é utilizado pelo cadastro de normas.
		lRet := .F.
	Endif
Return lRet
/*---------------------------------------------------------------------------
---WMA170Comb
---Realiza a Combinação de 2 Niveis
---Denilson 22/01/2001
---aNiv1, Record, Array contendo o 1o Nivel a ser combinado
---aNiv2, Record, Array contendo o 2o Nivel a ser combinado
---------------------------------------------------------------------------*/
Function WMA170Comb(aNiv1, aNiv2)
Local aRet       := {}
Local cString    := ''
Local nX         := 0
Local nY         := 0

Default aNiv1    := {}
Default aNiv2    := {}
	For nX:=1 To Len(aNiv1)
		For nY:=1 To Len(aNiv2)
			cString := AllTrim(aNiv1[nX]+aNiv2[nY])
			aAdd (aRet, cString)
		Next nY
	Next nX
Return aRet
/*---------------------------------------------------------------------------
---WMA170Grv
---Grava os Endereços
---Denilson 22/01/2001
---aEnderecos, Record, (Array com os Enderecos a serem gravados)
---cCodCfg, Character, (Codigo da Configuração)
---cCodEst, Character, (Codigo da Estrutura Fisica)
---cCodZon, Character, (Codigo da Zona)
---cCodExc, Character, (Codigo da Excecao)
---cArmazem, Character, (Codigo do Almoxarifado)
---cDescEnd, Character, (Descricao do Endereco)
---------------------------------------------------------------------------*/
Function WMA170Grv(aEnderecos, cCodCfg, cCodEst, cCodZon, cCodExc, cArmazem, cDescEnd)
Local aAreaAnt   := GetArea()
Local cFilSBE    := xFilial('SBE')
Local cQuery     := ""
Local cAliasQry  := ""
Local cString    := ""
Local cMsg       := ""
Local cVal       := ""
Local nX         := 0
Local nAviso     := 0
Local aValNiv    := {}
Local nAltura    := 0
Local nLargura   := 0
Local nComprim   := 0
Local nCapacid   := 0
Local nTamDesc   := TamSX3("BE_DESCRIC")[1]
Local nNrUnit    := 0
Local lWMA170EN  := ExistBlock('WMA170EN')
Local lWMA170FI  := ExistBlock('WMA170FI')
Local lRetPE     := .T.

Default aEnderecos := {}
Default cCodCfg    := ""
Default cCodEst    := ""
Default cCodZon    := ""
Default cCodExc    := ""
Default cArmazem   := ""
Default cDescEnd   := STR0011 // ENDERECO

	// Seta o tamanho da régua de progressão
	ProcRegua(Len(aEnderecos))

	// Trata o caso do parâmetro MV_DESCEND estar em branco
	cDescEnd := Iif(Empty(cDescEnd),STR0011,cDescEnd)

	// Se a estrutura física tiver sido informada
	If !Empty(cCodEst)
		DC8->(DbSetOrder(1))
		// Busca tamanho e capacidade da estrutura para criar o endereço com base nessas medidas
		If DC8->(DbSeek(xFilial("DC8")+cCodEst))
			nAltura  := DC8->DC8_ALTURA
			nLargura := DC8->DC8_LARGUR
			nComprim := DC8->DC8_COMPRI
			nCapacid := DC8->DC8_CAPACI
			If WmsX312120("DC8","DC8_NRUNIT") .And. WmsX312120("SBE","BE_NRUNIT")
		       nNrUnit := DC8->DC8_NRUNIT
			EndIf
		EndIf
	EndIf

	Begin Transaction
		For nX := 1 To Len(aEnderecos)

			// Incrementa régua de progressão
			IncProc(STR0012) // Gravando os Enderecos...
			// Verifica se já existe um endereço com as mesmas características
			cQuery := "SELECT BE_ESTFIS,"
			cQuery +=       " BE_CODCFG,"
			cQuery +=       " BE_CODZON"
			cQuery +=  " FROM "+RetSqlName("SBE")
			cQuery += " WHERE BE_FILIAL  = '"+cFilSBE+"'"
			cQuery +=   " AND BE_LOCAL   = '"+cArmazem+"'"
			cQuery +=   " AND BE_LOCALIZ = '"+aEnderecos[nX]+"'"
			cQuery +=   " AND (BE_ESTFIS = '"+cCodEst+"'"
			cQuery +=    " OR  BE_CODCFG = '"+cCodCFG+"'"
			cQuery +=    " OR  BE_CODZON = '"+cCodZon+"')"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
			cQuery := ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
			If !(cAliasQry)->(Eof())
				// Caso ainda não tenha selecionado a opção "OK p/ Todos"
				If nAviso != 2
					cMsg := STR0039 // "O Endereço/Armazém"
					cVal := AllTrim(aEnderecos[nX])+"/"+AllTrim(cArmazem)
					If (cAliasQry)->BE_ESTFIS == cCodEst
						cMsg += "/"+STR0040 // "Estrutura"
						cVal += "/"+AllTrim(cCodEst)
					EndIf
					If (cAliasQry)->BE_CODCFG == cCodCFG
						cMsg += "/"+STR0041 // "Configuração"
						cVal += "/"+AllTrim(cCodCFG)
					EndIf
					If (cAliasQry)->BE_CODZON == cCodZon
						cMsg += "/"+STR0042 // "Zona"
						cVal += "/"+AllTrim(cCodZon)
					EndIf
					cMsg   := cMsg + Space(1) + cVal + Space(1) + STR0015 // "já existe no cadastro de endereços (SBE)."
					nAviso := WmsMessage(cMsg,WMSA17006,10,,{STR0007,STR0013,STR0014}) // Ok // Ok p/Todos // Abortar
				EndIf
				// Abortar
				If nAviso == 3
					Exit
				EndIf
			Else
				If lWMA170EN
					lRetPE := ExecBlock('WMA170EN',.F.,.F.,{cFilSBE,;
															cArmazem,;
															cCodEst,;
															cCodCfg,;
															cCodZon,;
															aEnderecos[nX],;
															cCodExc,;
															nAltura,;
															nLargura,;
															nComprim,;
															nCapacid})
					If !lRetPE
						Loop
					EndIf
				EndIf

				cString := cDescEnd+Space(1)+aEnderecos[nX]
				cString := Iif(Len(cString)>nTamDesc,aEnderecos[nX],cString)
				RecLock('SBE',.T.)
				SBE->BE_FILIAL  := cFilSBE
				SBE->BE_LOCAL   := cArmazem
				SBE->BE_ESTFIS  := cCodEst
				SBE->BE_CODCFG  := cCodCfg
				SBE->BE_CODZON  := cCodZon
				SBE->BE_LOCALIZ := aEnderecos[nX]
				SBE->BE_DESCRIC := cString
				SBE->BE_EXCECAO := cCodExc
				SBE->BE_PRIOR   := 'ZZZ'
				SBE->BE_STATUS  := '1'
				SBE->BE_ALTURLC := nAltura
				SBE->BE_LARGLC  := nLargura
				SBE->BE_COMPRLC := nComprim
				SBE->BE_CAPACID := nCapacid
				// Atribui os níveis do endereço para o calculo de proximidade de endereços
				If SBE->(FieldPos("BE_VALNV1")) > 0
					aValNiv := DLXCfgEnd(cCodCfg, aEnderecos[nX])
					SBE->BE_VALNV1 := Iif(Len(aValNiv)> 0,Int(aValNiv[1,1]),0)
					SBE->BE_VALNV2 := Iif(Len(aValNiv)> 1,Int(aValNiv[2,1]),0)
					SBE->BE_VALNV3 := Iif(Len(aValNiv)> 2,Int(aValNiv[3,1]),0)
					SBE->BE_VALNV4 := Iif(Len(aValNiv)> 3,Int(aValNiv[4,1]),0)
					SBE->BE_VALNV5 := Iif(Len(aValNiv)> 4,Int(aValNiv[5,1]),0)
					SBE->BE_VALNV6 := Iif(Len(aValNiv)> 5,Int(aValNiv[6,1]),0)
				EndIf
				If WmsX312120("SBE","BE_NRUNIT")
		           SBE->BE_NRUNIT := nNrUnit
		        EndIf
				SBE->(MsUnLock())
				If lWMA170FI
					ExecBlock('WMA170FI',.F.,.F.)
				EndIf
			EndIf
			(cAliasQry)->(DbCloseArea())
		Next nX
	End Transaction

RestArea(aAreaAnt)
Return Nil

/*---------------------------------------------------------------------------
---WMA170LiOk
---Efetua a Valizacao da Linha da GetDados
---Fernando Joly 14/03/2001
---------------------------------------------------------------------------*/
Function WMA170LiOk()
Local lRet       := .T.
Local nPosIni    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INIC'})
Local nPosFim    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_FIM'})
Local nPosInt    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INT'})
	If Empty(aCols[n, nPosIni]) .Or. Empty(aCols[n, nPosFim])
		WmsMessage(STR0030,WMSA17015,,,,STR0031) // Um ou mais campos obrigatórios não foram preenchidos. // Preencha os campos cujos títulos possuem o símbolo '*' (asterisco).
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(aCols[n, nPosInt])==QtdComp(0)
		WmsMessage(STR0032,WMSA17017,,,,STR0033) // O intervalo informado deve ser maior que 0 (Zero). // Informe o intervalo que será utilizado pelo sistema na geração dos endereços. Se, por exemplo, o intervalo informado for '10', o sistema irá gerar endereços com intervalo de 10 números (0,10,20...).
		lRet := .F.
	EndIf
	If lRet .And. QtdComp(aCols[n, nPosFim]) < QtdComp(aCols[n, nPosIni])
		WmsMessage(STR0034,WMSA17019,,,,STR0035) // O intervalo final deve ser maior que o intervalo inicial. // Informe os intervalos iniciais e finais para a geração dos enderecos. Se, por exemplo, forem informados inicio '0' e  final '10' o sistema irá gerar todos os endereços para o intervalo.
		lRet := .F.
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WMA170TdOk
---Efetua a Valizacao Geral da GetDados
---Fernando Joly 14/03/2001
---------------------------------------------------------------------------*/
Function WMA170TdOk()
Local lRet       := .T.
Local nX         := 0
Local nPosIni    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INIC'})
Local nPosFim    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_FIM'})
Local nPosInt    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INT'})

	For nX := 1 to Len(aCols)
		If	Empty(aCols[nX, nPosIni]) .Or. Empty(aCols[nX, nPosFim])
			WmsMessage(STR0030,WMSA17016,,,,STR0031) // Um ou mais campos obrigatórios não foram preenchidos. // Preencha os campos cujos títulos possuem o símbolo '*' (asterisco).
			lRet := .F.
			Exit
		EndIf
		If	QtdComp(aCols[nX, nPosInt])==QtdComp(0)
			WmsMessage(STR0032,WMSA17018,,,,STR0033) // O intervalo informado deve ser maior que 0 (Zero). // Informe o intervalo que será utilizado pelo sistema na geração dos endereços. Se, por exemplo, o intervalo informado for '10', o sistema irá gerar endereços com intervalo de 10 números (0,10,20...).
			lRet := .F.
			Exit
		EndIf
		If	QtdComp(aCols[nX, nPosFim]) < QtdComp(aCols[nX, nPosIni])
			WmsMessage(STR0034,WMSA17020,,,,STR0035) // O intervalo final deve ser maior que o intervalo inicial. // Informe os intervalos iniciais e finais para a geração dos enderecos. Se, por exemplo, forem informados inicio '0' e  final '10' o sistema irá gerar todos os endereços para o intervalo.
			lRet := .F.
			Exit
		EndIf
	Next nX

	If	lRet
		If	Empty(cWMA170Cfg)
			WmsMessage(STR0036,WMSA17023,5/*MSG_HELP*/) // Código que identifica uma configuração de endereço.
			lRet := .F.
		ElseIf	!WMA170Estr(cWMA170EFi)
			lRet := .F.
		ElseIf	!WMA170Zona(cWMA170Zon)
			lRet := .F.
		ElseIf	!NaoVazio(cWMA170Arm)
			lRet := .F.
		EndIf
	EndIf
Return lRet
/*---------------------------------------------------------------------------
---WMA170Vld
---Valida a digitacao dos intervalos
---Richard Anderson 21/06/2001
---------------------------------------------------------------------------*/
Function WMA170Vld()
Local aAreaAnt   := GetArea()
Local aAreaDC7   := DC7->(GetArea())
Local nPosIni    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_INIC'})
Local nPosFim    := aScan(aHeader, {|x| AllTrim(x[2])=='TB_FIM' })
Local nTamNivel  := 3
Local lRet       := .T.
	dbSelectArea('DC7')
	dbSetOrder(1)
	If dbSeek(xFilial('DC7')+cWMA170Cfg+StrZero(n,Len(DC7_SEQUEN)), .F.)
		nTamNivel := DC7_POSIC
	EndIf

	If 'TB_INIC' $ReadVar()
		aCols[n,nPosFim] := Space(Len(aCols[n,nPosFim]))
		If IsAlpha(&(ReadVar())) .And. !(Len(AllTrim(&(ReadVar())))==nTamNivel)
			WmsMessage(WmsFmtMsg(STR0016,{{"[VAR01]",Str(nTamNivel)}}),WMSA17007,5/*MSG_HELP*/) // Informe um código com [VAR01] posições.
			lRet := .F.
		ElseIf !IsAlpha(&(ReadVar()))
			If (lRet:=Positivo(Val(&(ReadVar()))))
				aCols[n, nPosIni] := rTrim(&(ReadVar()))
			EndIf
		EndIf
	ElseIf 'TB_FIM' $ReadVar()
		If IsAlpha(aCols[n,nPosIni]) .And. !IsAlpha(&(ReadVar()))
			WmsMessage(STR0037,WMSA17024,,,,STR0038) // O intervalo final deve ser informado em caracteres. // Quando o intervalo inicial for informado em caracteres o intervalo final deve ser obrigatoriamente informado em caracteres também.
			lRet := .F.
		ElseIf IsAlpha(&(ReadVar()))
			If !(Len(AllTrim(&(ReadVar())))==nTamNivel)
				WmsMessage(WmsFmtMsg(STR0016,{{"[VAR01]",Str(nTamNivel)}}),WMSA17008,5/*MSG_HELP*/) // Informe um código com [VAR01] posições.
				lRet := .F.
			ElseIf &(ReadVar()) < aCols[n,nPosIni]
				WmsMessage(STR0034,WMSA17021,,,,STR0035) // O intervalo final deve ser maior que o intervalo inicial. // Informe os intervalos iniciais e finais para a geração dos enderecos. Se, por exemplo, forem informados inicio '0' e  final '10' o sistema irá gerar todos os endereços para o intervalo.
				lRet := .F.
			EndIf
		Else
			If Val(&(ReadVar())) < Val(aCols[n,nPosIni])
				WmsMessage(STR0034,WMSA17022,,,,STR0035) // O intervalo final deve ser maior que o intervalo inicial."##"Informe os intervalos iniciais e finais para a geração dos enderecos. Se, por exemplo, forem informados inicio '0' e  final '10' o sistema irá gerar todos os endereços para o intervalo.
				lRet := .F.
			Else
				lRet := Positivo(Val(&(ReadVar())))
			EndIf
			If lRet
				aCols[n, nPosFim] := rTrim(&(ReadVar()))
			EndIf
		EndIf
	EndIf
	RestArea(aAreaDC7)
	RestArea(aAreaAnt)
Return lRet
//------------------------------------------------------------------//
//------------------Incrementa String Alfanumérica------------------//
//------------------------------------------------------------------//
Static Function IncStrAlfa(cIntIni,nTam)
Local cLetra := SubStr(cIntIni,nTam,1)
	If cLetra == '9' .Or. cLetra == 'Z'
		If nTam > 1
			If cLetra == 'Z'
				cLetra := '0'
				IncStrAlfa(@cIntIni,nTam-1)
			Else
				If IsAlpha(SubStr(cIntIni,nTam-1,1))
					cLetra := Soma1(cLetra)
				Else
					cLetra := '0'
					IncStrAlfa(@cIntIni,nTam-1)
				EndIf 
			EndIf
		Else
			cLetra := Soma1(cLetra)
		EndIf
	Else
		cLetra := Soma1(cLetra)
	EndIf
	cIntIni := SubStr(cIntIni,1,nTam-1) + cLetra
Return
//----------------------------------------------------------------------//
//--------------- Realiza validação do armazém informado ---------------//
//----------------------------------------------------------------------//
Static Function VldArmazem(cArmazem)
Local lRet := .T.
Local lRetPE := .T.
	If !NaoVazio(cArmazem)
	   Return .F.
	Else
	   NNR->(DbSetOrder(1)) // NNR_FILIAL+NNR_CODIGO
	   If !(NNR->(DbSeek(xFilial('NNR')+cArmazem)))
	      lRet := .F.
	      WmsMessage(STR0017,WMSA17009,,,,STR0018) // Armazém não encontrado no cadastro locais de estoque (NNR). // Selecione um armazém já cadastrado ou cadastre um novo armazém.
	   EndIf
	EndIf
	If lRet .And. ExistBlock('WMA170AR')
	   lRetPE := ExecBlock('WMA170AR',.F.,.F.,{cArmazem})
	   lRet := Iif(ValType(lRetPE)=="L",lRetPE,lRet)
	EndIf
Return lRet
