#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA200.CH"

Static scCRLF     := Chr(13) + Chr(10)

Static slM200SUB  := ExistBlock("M200SUB")
Static lM200REVI  := ExistBlock("M200REVI")
Static sl200Auto  := .F.
Static slRevTab   := FindFunction('PCPREVTAB') .AND. SuperGetMv("MV_REVFIL",.F.,.F.)
Static slRevAtu   := FindFunction('PCPREVATU') .AND. SuperGetMv("MV_REVFIL",.F.,.F.)
Static slReplica  := SuperGetMv("MV_PCPRLEP", .F., 2) == 1
Static slRevAut   := SuperGetMv("MV_REVAUT" , .F., .F.)
Static slRevProd  := SuperGetMv("MV_REVPROD", .F., .F.)
Static slUsaSBZ   := SuperGetMV("MV_ARQPROD", .F., "SB1") == 'SBZ'
Static snG1COMP	  := GetSx3Cache("G1_COMP" , "X3_TAMANHO")
Static snG1GROPC  := GetSx3Cache("G1_GROPC", "X3_TAMANHO")
Static snG1OPC    := GetSx3Cache("G1_OPC"  , "X3_TAMANHO")
Static snD4OP     := GetSx3Cache("D4_OP"   , "X3_TAMANHO")
Static soRecNo

Static _lNewMRP     := Nil

/*/{Protheus.doc} A200Subst
Substituicao de componentes na Estrutura
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - aAutoCab  , array  , Array com as informações do cabeçalho do programa
                                 e com parâmetros adicionais para identificar alguns comportamentos do programa.
@param 02 - aAutoItens, array  , Array com as informações dos componentes que serão modificados.
                                 Para a operação de Exclusão, este array não é considerado.
/*/
Function A200Subst(aAutoCab, aAutoItens)

	Local aArea      := GetArea()
	Local aAreaSX3   := SX3->(GetArea())
	Local aButtons   := {}
	Local cCodOrig   := Criavar("G1_COMP" ,.F.)
	Local cCodDest   := Criavar("G1_COMP" ,.F.)
	Local cGrpOrig   := Criavar("G1_GROPC",.F.)
	Local cGrpDest   := Criavar("G1_GROPC",.F.)
	Local cDescOrig  := Criavar("B1_DESC" ,.F.)
	Local cDescDest  := Criavar("B1_DESC" ,.F.)
	Local cOpcOrig   := Criavar("G1_OPC"  ,.F.)
	Local cOpcDest   := Criavar("G1_OPC"  ,.F.)
	Local oSay
	Local oSay2
	Local lOk        := .F.
	Local lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.) //Variavel lPyme utilizada para Tratamento do Siga PyME
	Local nPosCoOrig
	Local nPosGrOrig
	Local nPosOpOrig
	Local nPosCoDest
	Local nPosGrDest
	Local nPosOpDest
	Local oDlg
	Local oSize
	Local oSize2
	Local oSize3

	Private oProdOrig
	Private cFilQuery := ""

	Default aAutoCab   := {}
	Default aAutoItens := {}

	If !Empty(aAutoCab)
		sl200Auto  := .T.
		nPosCoOrig := aScan(aAutoCab, {|x| x[1] == "G1_CODORIG"} )
		nPosGrOrig := aScan(aAutoCab, {|x| x[1] == "G1_GRPORIG"} )
		nPosOpOrig := aScan(aAutoCab, {|x| x[1] == "G1_OPCORIG"} )
		nPosCoDest := aScan(aAutoCab, {|x| x[1] == "G1_CODDEST"} )
		nPosGrDest := aScan(aAutoCab, {|x| x[1] == "G1_GRPDEST"} )
		nPosOpDest := aScan(aAutoCab, {|x| x[1] == "G1_OPCDEST"} )

		//Os Campos de produto origem e destino devem ser preenchidos
		If nPosCoOrig >= 1 .And. nPosCoDest >= 1
			cCodOrig := PadR(aAutoCab[nPosCoOrig,2], snG1COMP )
			cGrpOrig := PadR(aAutoCab[nPosGrOrig,2], snG1GROPC)
			cOpcOrig := PadR(aAutoCab[nPosOpOrig,2], snG1OPC  )
			cCodDest := PadR(aAutoCab[nPosCoDest,2], snG1COMP )
			cGrpDest := PadR(aAutoCab[nPosGrDest,2], snG1GROPC)
			cOpcDest := PadR(aAutoCab[nPosOpDest,2], snG1OPC  )

			If A200SubOK(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest)
				A200PrSubs(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest, aAutoItens,aAutoCab)
			EndIf
		EndIf
		sl200Auto := .F.

	Else
		dbSelectArea("SG1")
		DEFINE MSDIALOG oDlg FROM  140, 000 TO 385, 615 TITLE OemToAnsi(STR0128) PIXEL //"Substituicao de Componentes"

		//Calcula dimensões Em linha
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "LABEL1" 	,  100, 50, .T., .T. ) //Totalmente dimensionavel
		oSize:AddObject( "LABEL2"   ,  100, 50, .T., .T. ) //Totalmente dimensionavel
		oSize:lProp 	:= .T. //Proporcional
		oSize:aMargins 	:= { 6, 6, 6, 6 } //Espaco ao lado dos objetos 0, entre eles 3
		oSize:Process() 	   //Dispara os calculos

		//Calcula dimensões Em Coluna
		oSize2 := FwDefSize():New()
		oSize2:aWorkArea := oSize:GetNextCallArea( "LABEL1" )
		oSize2:AddObject( "ESQ",  100, 50, .T., .T. ) //Totalmente dimensionavel
		oSize2:AddObject( "DIR",  100, 50, .T., .T. ) //Totalmente dimensionavel
		oSize2:lLateral := .T.
		oSize2:lProp 	:= .T. //Proporcional
		oSize2:aMargins := { 3, 3, 3, 3 } //Espaco ao lado dos objetos 0, entre eles 3
		oSize2:Process() 	   //Dispara os calculos

		//Calcula dimensões Em Coluna
		oSize3 := FwDefSize():New()
		oSize3:aWorkArea := oSize:GetNextCallArea( "LABEL2" )
		oSize3:AddObject( "ESQ",  100, 50, .T., .T. ) //Totalmente dimensionavel
		oSize3:AddObject( "DIR",  100, 50, .T., .T. ) //Totalmente dimensionavel
		oSize3:lLateral := .T.
		oSize3:lProp 	:= .T. //Proporcional
		oSize3:aMargins := { 3, 3, 3, 3 } //Espaco ao lado dos objetos 0, entre eles 3
		oSize3:Process() 	   //Dispara os calculos

		DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
		@ oSize:GetDimension("LABEL1","LININI"), oSize:GetDimension("LABEL1","COLINI") TO oSize:GetDimension("LABEL1","LINEND"), oSize:GetDimension("LABEL1","COLEND");
			LABEL OemToAnsi(STR0129) OF oDlg PIXEL //"Componente Original"

		@ oSize:GetDimension("LABEL2","LININI"), oSize:GetDimension("LABEL2","COLINI") TO oSize:GetDimension("LABEL2","LINEND"), oSize:GetDimension("LABEL2","COLEND");
			LABEL OemToAnsi(STR0130) OF oDlg PIXEL //"Novo Componente"

		@ oSize2:GetDimension("ESQ","LININI")+10, oSize2:GetDimension("ESQ","COLINI")+30 MSGET oProdOrig VAR cCodOrig   F3 "SB1" Picture PesqPict("SG1","G1_COMP");
			Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) .And. A200IniDsc(1,oSay,cCodOrig,cCodDest) SIZE 105,09 OF oDlg PIXEL

		If !lPyme
			@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+40 MSGET cGrpOrig   F3 "SGAPCP" Picture PesqPict("SG1","G1_GROPC");
				Valid Vazio(cGrpOrig) .Or. ExistCpo("SGA",cGrpOrig) SIZE 15,09 OF oDlg PIXEL

			@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+120 MSGET cOpcOrig   Picture PesqPict("SG1","G1_OPC");
				Valid If(!Empty(cGrpOrig),NaoVazio(cOpcOrig) .And.ExistCpo("SGA",cGrpOrig+cOpcOrig),Vazio(cOpcOrig)) SIZE 15,09 OF oDlg PIXEL
		EndIf

		@ oSize3:GetDimension("ESQ","LININI")+10, oSize3:GetDimension("ESQ","COLINI")+30 MSGET cCodDest   F3 "SB1" Picture PesqPict("SG1","G1_COMP");
			Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest)  .And. A200IniDsc(2,oSay2,cCodDest,cCodOrig) SIZE 105,9 OF oDlg PIXEL

		If !lPyme
			@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+40 MSGET cGrpDest   F3 "SGAPCP" Picture PesqPict("SG1","G1_GROPC");
				Valid Vazio(cGrpDest) .Or. ExistCpo("SGA",cGrpDest) SIZE 15,09 OF oDlg PIXEL

			@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+120 MSGET cOpcDest   Picture PesqPict("SG1","G1_OPC");
				Valid If(!Empty(cGrpDest),NaoVazio(cOpcDest).And.ExistCpo("SGA",cGrpDest+cOpcDest),Vazio(cOpcDest)) SIZE 15,09 OF oDlg PIXEL
		EndIf

		@ oSize2:GetDimension("ESQ","LININI")+24, oSize2:GetDimension("ESQ","COLINI")+33     SAY oSay Prompt cDescOrig  SIZE 130,6 OF oDlg PIXEL
		@ oSize3:GetDimension("ESQ","LININI")+24, oSize3:GetDimension("ESQ","COLINI")+33     SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL
		@ oSize2:GetDimension("ESQ","LININI")+12, oSize2:GetDimension("ESQ","COLINI")        SAY OemtoAnsi(STR0011)     SIZE 24,7  OF oDlg PIXEL //"Produto"

		If !lPyme
			@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI")    SAY RetTitle("G1_GROPC")   SIZE 42,13 OF oDlg PIXEL
			@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI")+85 SAY RetTitle("G1_OPC")     SIZE 30,7  OF oDlg PIXEL
		EndIf

		@ oSize3:GetDimension("ESQ","LININI")+12, oSize3:GetDimension("ESQ","COLINI")        SAY OemToAnsi(STR0011)     SIZE 24,7  OF oDlg PIXEL //"Produto"

		If !lPyme
			@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI")    SAY RetTitle("G1_GROPC") SIZE 42,13 OF oDlg PIXEL
			@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI")+85 SAY RetTitle("G1_OPC")   SIZE 30,7  OF oDlg PIXEL
		EndIf

		aAdd(aButtons,{STR0278,{|| A200SubGrl(oDlg,cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest)}, STR0278})  //"Confirmar Geral" //"Confirmar Geral"

		ACTIVATE MSDIALOG oDlg CENTER;
			ON INIT (EnchoiceBar(oDlg, {|| Iif(A200SubOK(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest), (lOk:=.T., oDlg:End()), lOk := .F.)} , {|| (lOk := .F., oDlg:End())},,aButtons ),oProdOrig:SetFocus())
		If lOk	//Processa substituicao dos componentes
			Processa({|| A200PrSubs(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest) })
		EndIf
	EndIf

	//Remove lock's - Fonte PCPA200EVDEF
	SG1UnLockR(,,soRecNo)
	soRecNo := Nil

	SX3->(RestArea(aAreaSX3))
	RestArea(aArea)
Return

/*/{Protheus.doc} A200PrSubs
Monta markbowse para selecao e substituicao dos componentes
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - cCodOrig, caracter, Codigo do produto origem
@param 02 - cGrpOrig, caracter, Grupo de opcionais origem
@param 03 - cOpcOrig, caracter, Opcionais do produto origem
@param 04 - cCodDest, caracter, Codigo do produto destino
@param 05 - cGrpDest, caracter, Grupo de opcionais destino
@param 06 - cOpcDest, caracter, Opcionais do produto destino
/*/
Static Function A200PrSubs(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest, aAutoItens, aAutoCab)
	Local cFilSG1		:= ""
	Local lPyme			:= Iif(Type("__lPyme") <> "U", __lPyme, .F.)	//Variavel lPyme utilizada para Tratamento do Siga PyME
	Local bSubs			:= {|| A200DoSubs()}

	Private aDadosDest  := {cCodDest, cGrpDest, cOpcDest}
	Private cCadastro   := OemToAnsi(STR0128)						//"Substituicao de Componentes"
	Private cCodOrig2   := cCodOrig
	Private cMarca200   := ThisMark()
	Private lA200SubFil := ExistBlock("A200SUBFIL")
	Private lMarkAll    := .F.
	Private lHelpList   := .F.

	If sl200Auto
		A200DoSubs(, , , , , aAutoItens, aAutoCab)
	Else
		cFilQuery := " "

		cFilSG1 :=     " G1_FILIAL = '" + xFIlial("SG1") + "'"
		cFilSG1 += " AND G1_COMP = '" + cCodOrig + "'"
		cFilSG1 += " AND D_E_L_E_T_ = ' '"

		If !lPyme
			cFilSG1 += " AND G1_GROPC = '" + cGrpOrig + "'"
 			cFilSG1 += " AND G1_OPC = '" + cOpcOrig + "'"
		EndIf

		If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
			cFilSG1 += " AND 1 = 1"
		Else
			cFilSG1 += " AND 1 = 2"
		EndIf

		//Realiza a Filtragem
		dbSelectArea("SG1")
		SG1->(dbSetOrder(1))
		If !SG1->(MsSeek(xFIlial("SG1")))
			Help(" ",1,"RECNO")
		Else
			cFilSG1 += getCondRev("")

			//Ponto de Entrada para filtrar a estrutura (produto pai) do componente a ser substituido
			If lA200SubFil
				cFilSG1 := ExecBlock("A200SUBFIL",.F.,.F.,{cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest, cFilSG1})
			EndIf

			cFilQuery := cFilSG1

			oMark := FWMarkBrowse():New()
			oMark:SetAlias( "SG1" )
			oMark:SetDescription( OemToAnsi(STR0128) )	//"Substituicao de Componentes"
			oMark:SetFieldMark( "G1_OK" )
			oMark:SetFilterDefault("@"+cFilSG1)
			oMark:SetValid({|| ValidMarca() })
			oMark:SetAfterMark({|| RELockSG1() })
			oMark:SetAllMark({|| MarkAll(oMark) })
			oMark:SetIgnoreARotina(.t.)
			oMark:SetMenuDef("")
			oMark:AddButton(STR0131,bSubs,,1,0)//{STR0131,"A200DoSubs", 0 , 1}
			oMark:Activate()
		EndIf
	EndIf

	//Restaura condicao original
	dbSelectArea("SG1")
	RetIndex("SG1")
	dbClearFilter()
Return Nil

/*/{Protheus.doc} ValidMarca
Valida a marcacao de registros para substituicao
@author brunno.costa
@since 21/01/2019
@version 1.0
@return lRet, logico, indica se pode ou nao marcar o registro para substituicao
/*/
Static Function ValidMarca()
	Local lExibHelp  := .T.
	Local lRet       := .T.
	Local aBloqueio  := {}
	Local lInRefresh := IsInCallStack("LINEREFRESH")
	Local nRecno     := SG1->(Recno())

	If !lInRefresh
		If !RegValido(nRecno)//Verifica se o registro esta excluido ou se esta em EOF - sem registros dentro da condicao de filtro
			lRet := .F.
			SG1->(DbSkip())                   //Forca desposicianamento de registro
			SG1->(DbGoTop())                  //Posiciona no primeiro registro
			oMark:Refresh()                   //Atualiza MarkBrowse eliminando registros invalidos
			IF SG1->(Eof())
				//Não existem registros válidos para a substituição.
				//Reinicie o processo utilizando outro 'Produto Original'.
				Help( ,  , "Help", ,  STR0197, 1, 0, , , , , , {STR0198})
			Else
				//Este registro foi excluído por outro usuário.
				//Selecione outro registro e tente novamente.
				Help( ,  , "Help", ,  STR0195, 1, 0, , , , , , {STR0196})
			EndIf
		EndIf
	EndIf

	If lRet .and. !SG1->(Eof()) .AND. !IsInCallStack("SHOWDATA") .AND. !IsInCallStack("LINEREFRESH")
		soRecNo := Iif(soRecNo == Nil, JsonObject():New(), soRecNo)
		If !oMark:IsMark(oMark:Mark())
			If SG1->(SimpleLock())                              //Bloqueou registro atual da SG1
				soRecNo[cValToChar(SG1->(RecNo()))] := .T.
			Else                                                //NAO Bloqueou registro atual da SG1
				lRet      := .F.
				If soRecNo[cValToChar(SG1->(RecNo()))] == Nil .OR.;
				   soRecNo[cValToChar(SG1->(RecNo()))] .OR. !lMarkAll

					aBloqueio := StrTokArr(TCInternal(53),"|")
					//Esta estrutura 'X' está bloqueada para o usuário: Y
					//"Entre em contato com o usuário ou tente novamente."
					Help( ,  , "Help", ,  STR0184 + AllTrim(SG1->G1_COD) + STR0185 + aBloqueio[1] + scCRLF + scCRLF + " [" + aBloqueio[2] + "]";
						, 1, 0, , , , , , {STR0186})
				EndIf
				soRecNo[cValToChar(SG1->(RecNo()))] := .F.
			EndIf

		Else                                                  //Desbloqueia registro atual da SG1
			soRecNo[cValToChar(SG1->(RecNo()))] := Nil
			//Remove lock - Fonte PCPA200EVDEF
			SG1UnLockR(SG1->(RecNo()))
		EndIf
	EndIf

	If lRet .and. slReplica .AND. !Empty(SG1->G1_LISTA)
		lRet       := .F.

		If lMarkAll .AND. !lHelpList
			lHelpList := .T.
		ElseIf lMarkAll .AND. lHelpList
			lExibHelp := .F.
		EndIf

		If lExibHelp
			Help(,,'Help',,STR0138,1,0,,,,,,; //"Registro inválido para substituição pois está relacionado a uma lista e o parâmetro MV_PCPRLEP está com conteúdo '1'."
						{STR0139})            //"Utilize um registro válido ou reconfigure o parâmetro MV_PCPRLEP."
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} MarkAll
Marca todos os registros
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - oMark, objeto, objeto da MarkBrowse
/*/
Static Function MarkAll(oMark)
	Local aArea  := GetArea()
	lMarkAll  := .T.

	While !SG1->(Eof())
		If oMark:IsMark(oMark:Mark()) .OR. ValidMarca()
			oMark:MarkRec()
		EndIf
		SG1->(DbSkip())
	End

	lMarkAll  := .F.
	lHelpList := .F.

	RestArea(aArea)
	oMark:Refresh(.F.)
Return

/*/{Protheus.doc} A200DoSubs
Grava a substituicao dos componentes
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - cAlias,     caracter, Alias do registro           (OPC)
@param 02 - nRecno,     numerico, Numero do registro          (OPC)
@param 03 - nOpc,       caracter, Numero da opcao selecionada (OPC)
@param 04 - cMarca200,  caracter, Marca para substituicao
@param 05 - lInverte,   caracter, Inverte marcacao
@param 06 - aAutoItens, array,    Execauto - Estruturas a serem processadas
@param 07 - aAutoCab,   array,    Execauto - Cabeçalho das estruturas
@param 08 - lGeral,     lógico,   Indicador se o processamento é feito pela opção Confirmar Geral
@param 09 - aRSGF,      array,    Array da SGF carregada na opção Confirmar Geral
@param 10 - aRSEM,      array,    Array de OP carregada na opção Confirmar Geral
@param 11 - aRSG1,      array,    Array da SG1 carregada na opção Confirmar Geral
/*/
Static Function A200DoSubs(cAlias, nRecno, nOpc, cMarca200, lInverte, aAutoItens, aAutoCab, lGeral, aRSGF, aRSEM, aRSG1)
	Local aAreaSGF    := SGF->(GetArea())
	Local aAtualiza   := {}
	Local aDadosG1    := {}
	Local aErrEstrut  := {}
	Local lIntNewMRP  := FindFunction("Ma637MrpOn") .AND. FWAliasInDic( "HW9", .F. ) .AND. Ma637MrpOn(@_lNewMRP)
	Local aMRPxJson   := Iif(lIntNewMRP, {{}, JsonObject():New()}, {}) //{aDados para commit, JsonObject() com RECNOS} - Integracao Novo MRP
	Local aOrdens     := {}
	Local aProdPai    := {}
	Local aRecnoSEM   := {}
	Local aRecnosSG1  := {}
	Local aRecnosSGF  := {}
	Local cAliasRev   := ""
    Local cAliasR     := ""
	Local cAliasTmp   := GetNextAlias()
	Local cCodDest    := Criavar("G1_COMP" , .F.)
	Local cCodOrig    := Criavar("G1_COMP" , .F.)
	Local cCodPai     := ""
	Local cGrpOrig    := ""
	Local lG1Lista    := FieldPos("G1_LISTA") > 0
	Local cLista      := IIf(lG1Lista, Criavar("G1_LISTA", .F.), "  ")
	Local cLocal      := ""
	Local cLocProc    := GetMvNNR('MV_LOCPROC','99')
	Local cOpcOrig    := Criavar("C2_OPC"  , .F.)
    Local cProdPai    := ""
	Local cQuery      := ""
	Local cQuery2     := ""
	Local cQueryRev   := ""
	Local cRevAtu     := ""
	Local cRevMaior   := ""
	Local cRevProd    := ""
	Local cTRT        := ""
	Local lAltEmp     := .F.
	Local lAtualiza   := .F.
	Local lErr        := .F.
	Local lIntMrp     := .F.
	Local lNatuRev    := .F.
	Local lOnline     := .F.
	Local lRet        := .F.
	Local nAtuRev     := 0
	Local nI          := 0
	Local nJ          := 0
	Local nPos        := 0
	Local nQuant      := 0
	Local nX          := 0
	Local nz          := 0
	Local oPaisInt    := Nil

	Default lGeral    := .F.
	Default aRSGF     := {}
	Default aRSEM     := {}
	Default aRSG1     := {}

	Private aIntegPPI 	:= {}

	If Type("lMsErroAuto") == "U"
		Private lMsErroAuto := .F.
	EndIf

	If FindFunction("IntNewMRP")
		lIntMrp := IntNewMRP("MRPBILLOFMATERIAL", @lOnline)
		If !lOnline
			lIntMrp := .F.
		EndIf
	EndIf

	If lIntMrp
		oPaisInt := JsonObject():New()
	EndIf

	Pergunte('PCPA200', .F.)

	If lGeral
		dbSelectArea("SG1")
		lG1Lista    := FieldPos("G1_LISTA") > 0
		cLista      := IIf(lG1Lista, Criavar("G1_LISTA", .F.), "  ")

		aRecnosSG1 := aRSG1
		aRecnosSGF := aRSGF
		aRecnoSEM  := aRSEM
		lRet := .T.
	Else
		If sl200Auto
			lRet := .T.
			For nI := 1 to len(aAutoItens)
				SG1->(dbSetOrder(2))
				If SG1->(dbSeek(xFIlial("SG1")+cCodOrig2+aAutoItens[nI,2]))
					lRet := a200VldOpe(aRecnosSGF, aRecnoSEM)
					If !lRet
						Exit
					EndIf
					aAdd(aRecnosSG1,SG1->(Recno()))
					If lIntMrp
						If oPaisInt[SG1->G1_FILIAL+SG1->G1_COD] == Nil
							oPaisInt[SG1->G1_FILIAL+SG1->G1_COD] := 0
						EndIf
						oPaisInt[SG1->G1_FILIAL+SG1->G1_COD]++
					EndIf
				EndIf
			Next nI
		Else
			SGF->(dbSetOrder(2))
			dbSelectArea("SG1")
			SG1->(dbSeek(xFIlial("SG1")))
			While SG1->(!Eof());
				.And. SG1->G1_FILIAL == xFIlial("SG1")

				//Verifica os registros marcados para substituicao
				If IsMark("G1_OK", oMark:Mark(), lInverte)
					lRet := .T.
					lRet := a200VldOpe(aRecnosSGF, aRecnoSEM)
					If !lRet
						Exit
					EndIf
					aAdd(aRecnosSG1,SG1->(Recno()))
					If lIntMrp
						If oPaisInt[SG1->G1_FILIAL+SG1->G1_COD] == Nil
							oPaisInt[SG1->G1_FILIAL+SG1->G1_COD] := 0
						EndIf
						oPaisInt[SG1->G1_FILIAL+SG1->G1_COD]++
					EndIf
				EndIf

				SG1->(dbSkip())
			EndDo
		EndIf
	EndIf

	If lRet
		If lGeral
			MsProcTxt(STR0266) //"Analisando ordens de produção em aberto."
		EndIf

		For nz := 1 to Len(aRecnoSEM)
			SG1->(dbGoTo(aRecnoSEM[nz]))

			dbSelectArea('SC2')
			SC2->(dbSetOrder(2))
			If SC2->(dbSeek(xFIlial('SC2')+SG1->G1_COD))
				While SC2->(!Eof());
					.AND. SC2->C2_PRODUTO == SG1->G1_COD

					If A650DefLeg(1) .OR. A650DefLeg(2) //Prevista ou em aberto
						dbSelectArea('SD4')
						SD4->(dbSetOrder(1))
						If SD4->(dbSeek(xFIlial('SD4')+SG1->G1_COMP+PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,snD4OP)+SG1->G1_TRT))
							While SD4->(!EOF());
								.AND. SD4->D4_COD == SG1->G1_COMP;
								.AND. SD4->D4_OP  == PadR(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN,snD4OP);
								.AND. SD4->D4_TRT == SG1->G1_TRT

								nResult := aScan(aOrdens, {|x| x[2] == SD4->D4_OP})
								If nResult == 0
									aAdd(aOrdens, {.T., SD4->D4_OP, SC2->C2_PRODUTO, { SD4->(Recno()) }, .F., SG1->(Recno()) } )
								Else
									aAdd(aOrdens[nResult][4], SD4->(Recno()) )
								EndIf

								SD4->(dbSkip())
							End
						EndIf
					EndIf

					SC2->(dbSkip())
				End
			EndIf
		Next

		//Grava a substituicao de componentes
		If !slRevAut
			If lGeral

				MsProcTxt(STR0267)	//"Substituindo o componente nas estruturas."

				cTabG1 := RetSqlName("SG1")
				cRecG1 := cTabG1 +'.R_E_C_N_O_'

				cQuery := "UPDATE " + cTabG1 + " "
				cQuery +=   " SET G1_COMP  = '" + aDadosDest[1] + "' ,"
				cQuery +=   "     G1_GROPC = '" + aDadosDest[2] + "' ,"
				cQuery +=	"     G1_OPC = '"   + aDadosDest[3] + "' "

				If lG1Lista
					cQuery +=  ", G1_LISTA = '" + cLista + "'"
				EndIf

				cQuery += " WHERE G1_COD <> '" + aDadosDest[1] + "' "
				cQuery += "   AND EXISTS ( SELECT 1 "
				cQuery += "                  FROM A200SUB SUB "
				cQuery += "                 WHERE SUB.SUB_RECNO = " +cRecG1+ " ) "

				TcSqlExec(cQuery)
			Else
				cGrpOrig := aDadosDest[2]
				cCodOrig := cCodOrig2
				cOpcOrig := aDadosDest[3]
				cCodDest := aDadosDest[1]
				If Len(aRecnosSG1) < 1001 .And. Len(aRecnosSG1) > 0  //tratamento para oracle pois tem limite de 1000 itens no "IN"
					cQuery2 := " WHERE G1_COD <> '" + aDadosDest[1] + "' AND R_E_C_N_O_ IN ("
					For nz := 1 to Len(aRecnosSG1)
						If nz > 1
							cQuery2+= ","
						EndIf
						cQuery2 += "'" + Str(aRecnosSG1[nz], 10, 0) + "'"
					Next nz
					cQuery2 += ")"


					// Primeiro busca os registros que serão alterados
					cQuery := "SELECT SG1.G1_FILIAL, SG1.G1_COD, SG1.R_E_C_N_O_, "
					If "G1_REVINI+G1_REVFIM" $ FWX2Unico("SG1")
						cQuery += " (SELECT COUNT(SG12.G1_COD) "
						cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
						If slRevAtu .And. slUsaSBZ
							cQuery += "	LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON SBZ.BZ_FILIAL = '" + xFilial('SBZ')+ "' AND SBZ.BZ_COD = SG1.G1_COD AND SBZ.D_E_L_E_T_ = ' ' "
						Else
							cQuery += "	LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial('SB1')+ "' AND SB1.B1_COD = SG1.G1_COD AND SB1.D_E_L_E_T_ = ' ' "
						EndIf
						cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
						cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
						cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
						cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "
						cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
						If slRevAtu .And. slUsaSBZ
							cQuery += "	AND SBZ.BZ_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
						Else
							cQuery += "	AND SB1.B1_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
						EndIf
						cQuery += "	) EXISTE "
					Else
						cQuery += " (SELECT COUNT(SG12.G1_COD) "
						cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
						cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
						cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
						cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
						cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "
						cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
						cQuery += "	) EXISTE "
					EndIf
					cQuery += "FROM " + RetSqlName("SG1") + " SG1 "
					cQuery += cQuery2

					dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .T., .T.)
					While (cAliasTmp)->(!EOF())
						If (cAliasTmp)->EXISTE > 0
							aAdd(aErrEstrut, {(cAliasTmp)->G1_COD, STR0132} ) //"Componente já Cadastrado na Estrutura."
							If lIntMrp
								If oPaisInt[(cAliasTmp)->(G1_FILIAL+G1_COD)] == Nil
									oPaisInt[(cAliasTmp)->(G1_FILIAL+G1_COD)] := 0
								Else
									oPaisInt[(cAliasTmp)->(G1_FILIAL+G1_COD)]--
								EndIf
							EndIf
							(cAliasTmp)->(dbSkip())
							Loop
						EndIf
						aAdd(aAtualiza, (cAliasTmp)->R_E_C_N_O_)
						(cAliasTmp)->(dbSkip())
					End
					(cAliasTmp)->(dbCloseArea())

					If Len(aAtualiza) > 0
						//Depois atualiza
						cQuery := "UPDATE " + RetSqlName("SG1")
						cQuery +=   " SET G1_COMP = '"  + aDadosDest[1] + "'" + ;
									", G1_GROPC = '" + aDadosDest[2] + "'" + ;
									", G1_OPC = '"   + aDadosDest[3] + "'"
						If lG1Lista
							cQuery +=  ", G1_LISTA = '" + cLista + "'"
						EndIf
						cQuery += " WHERE G1_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("

						For nz := 1 to Len(aAtualiza)
							If nz > 1
								cQuery += ","
							EndIf
							cQuery += "'" + Str(aAtualiza[nz],10,0) + "'"
						Next nz
						cQuery += ")"
						TcSqlExec(cQuery)
					EndIf
				Else
					For nz := 1 to Len(aRecnosSG1)
						lAtualiza := .F.
						cQuery2 := " WHERE G1_COD <> '" + aDadosDest[1] + "' AND R_E_C_N_O_ = "
						cQuery2 += "'" + Str(aRecnosSG1[nz],10,0) + "'"

						cQuery := "SELECT SG1.G1_FILIAL, SG1.G1_COD, SG1.R_E_C_N_O_, "
						If "G1_REVINI+G1_REVFIM" $ FWX2Unico("SG1")
							cQuery += " (SELECT COUNT(SG12.G1_COD) "
							cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
							If slRevAtu .And. slUsaSBZ
								cQuery += "	LEFT JOIN " + RetSqlName("SBZ") + " SBZ ON SBZ.BZ_FILIAL = '" + xFilial('SBZ')+ "' AND SBZ.BZ_COD = SG1.G1_COD AND SBZ.D_E_L_E_T_ = ' ' "
							Else
								cQuery += "	LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial('SB1')+ "' AND SB1.B1_COD = SG1.G1_COD AND SB1.D_E_L_E_T_ = ' ' "
							EndIf
							cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
							cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
							cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
							cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "
							cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
							If slRevAtu .And. slUsaSBZ
								cQuery += "	AND SBZ.BZ_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
							Else
								cQuery += "	AND SB1.B1_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM "
							EndIf
							cQuery += "	) EXISTE "
						Else
							cQuery += " (SELECT COUNT(SG12.G1_COD) "
							cQuery += "    FROM " + RetSqlName("SG1") + " SG12 "
							cQuery += "   WHERE SG12.G1_FILIAL  = '" + xFilial('SG1')+ "' "
							cQuery += "     AND SG12.G1_COD     = SG1.G1_COD "
							cQuery += "     AND SG12.G1_COMP    = '"+aDadosDest[1]+"' "
							cQuery += "     AND SG12.G1_TRT     = SG1.G1_TRT "
							cQuery += " 	  AND SG12.D_E_L_E_T_ = ' ' "
							cQuery += "	) EXISTE "
						EndIf
						cQuery += "FROM " + RetSqlName("SG1") + " SG1 "
						cQuery += cQuery2

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
						While (cAliasTmp)->(!EOF())
							If (cAliasTmp)->EXISTE > 0
								aAdd(aErrEstrut, {(cAliasTmp)->G1_COD, STR0132} ) //"Componente já Cadastrado na Estrutura."
								If lIntMrp
									If oPaisInt[(cAliasTmp)->(G1_FILIAL+G1_COD)] == Nil
										oPaisInt[(cAliasTmp)->(G1_FILIAL+G1_COD)] := 0
									Else
										oPaisInt[(cAliasTmp)->(G1_FILIAL+G1_COD)]--
									EndIf
								EndIf
								(cAliasTmp)->(dbSkip())
								Loop
							EndIf
							aAdd(aAtualiza, (cAliasTmp)->R_E_C_N_O_)
							lAtualiza := .T.
							(cAliasTmp)->(dbSkip())
						End
						(cAliasTmp)->(dbCloseArea())

						If lAtualiza
							//Depois atualiza
							cQuery := "UPDATE " + RetSqlName("SG1")
							cQuery +=   " SET G1_COMP = '"  + aDadosDest[1] + "'" + ;
										", G1_GROPC = '" + aDadosDest[2] + "'" + ;
										", G1_OPC = '"   + aDadosDest[3] + "'"
							If lG1Lista
								cQuery +=  ", G1_LISTA = '" + cLista + "'"
							EndIf
							cQuery += cQuery2

							TcSqlExec(cQuery)
						EndIf
					Next nz
				EndIf
			EndIf
		Else
			If lGeral
				MsProcTxt(STR0267)	//"Substituindo o componente nas estruturas."
			EndIf

			dbSelectArea("SG1")
			SG1->(dbClearFilter())

			aSize(aProdPai,0)

			For nz := 1 to Len(aRecnosSG1)
				//POSICIONA NO REGISTRO DA SG1 PARA PEGAR O PRODUTO PAI E AS INFORMAÇÕES PARA GRAVAR O REGISTRO NOVO
				SG1->(dbGoto(aRecnosSG1[NZ]))

				nAtuRev := aScan(aProdPai,{|x| x[1] == SG1->G1_COD})
				If nAtuRev == 0
				   aAdd(aProdPai,{SG1->G1_COD})
				EndIf

				//PELO PRODUTO PAI, POSICIONA A SB1, SALVA O VALOR DA REVISÃO E INCREMENTA
				SB1->(dbSeek(xFIlial("SB1")+SG1->G1_COD))

				//PEGA REVISÃO
				cQueryRev := "SELECT MAX(G1_REVFIM) REVFIM FROM "
				cQueryRev += RetSqlName("SG1") + " SG1 "
				cQueryRev += " WHERE SG1.D_E_L_E_T_ = ' ' "
				cQueryRev += " AND SG1.G1_FILIAL = '" + xFIlial("SG1") + "' "
				cQueryRev += " AND SG1.G1_COD    = '" + SG1->G1_COD + "' "
				cQueryRev := ChangeQuery(cQueryRev)
				cAliasR := GetNextAlias()
				dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryRev), cAliasR, .T., .T.)

				While (cAliasR)->(!Eof())
					cRevMaior := (cAliasR)->(REVFIM)
					(cAliasR)->(dbSkip())
				Enddo
				(cAliasR)->(dbCloseArea())

				cRevProd := Iif(slRevAtu, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU) //SB1->B1_REVATU
				cRevMaior := Iif( cRevProd > cRevMaior, cRevProd, cRevMaior)
				cGrpOrig := aDadosDest[2]
				cCodOrig := cCodOrig2
				cOpcOrig := aDadosDest[3]
				cCodDest := aDadosDest[1]

				If SG1->(dbSeek(xFIlial("SG1")+SB1->B1_COD+aDadosDest[1]+SG1->G1_TRT))
					While SG1->(!Eof()) .And. SB1->B1_COD == SG1->G1_COD .And. SG1->G1_COMP == aDadosDest[1]
						If SG1->G1_REVFIM == cRevProd
							lErr := .T.
							//Se já existir o componente origem na estrutura, não faz a alteração.
							aAdd(aErrEstrut, {SG1->G1_COD, STR0132} ) //"Componente já Cadastrado na Estrutura."
							If lIntMrp
								If oPaisInt[SG1->G1_FILIAL+SG1->G1_COD] == Nil
									oPaisInt[SG1->G1_FILIAL+SG1->G1_COD] := 0
								Else
									oPaisInt[SG1->G1_FILIAL+SG1->G1_COD]--
								EndIf
							EndIf
							Exit
						EndIf
						SG1->(dbSkip())
					End
					If lErr
						lErr := .F.
						Loop
					EndIf
				EndIf
				//Retorna para o registro correto da SG1.
				dbSelectArea("SG1")
				SG1->(dbGoto(aRecnosSG1[NZ]))

				cRevAtu := cRevMaior
				If nAtuRev == 0
					cRevAtu := Soma1(cRevMaior)
				 	If slRevTab
				 		PCPREVTAB(SB1->B1_COD, cRevAtu)
				 	Else
				 		//ATUALIZA REVISÃO DA SB1
				 		Reclock("SB1",.F.)
				 		Replace B1_REVATU With cRevAtu
				 		MsUnlock()
				 	EndIf
				EndIf

				aAdd(aAtualiza,aRecnosSG1[NZ])

				aDadosG1 := {}
				//PEGA INFORMAÇÕES DA SG1 PARA CRIAR NOVO REGISTRO
				aAdd(aDadosG1, SG1->G1_COD    )
				aAdd(aDadosG1, aDadosDest[1]  )
				aAdd(aDadosG1, SG1->G1_TRT    )
				aAdd(aDadosG1, SG1->G1_QUANT  )
				aAdd(aDadosG1, SG1->G1_PERDA  )
				aAdd(aDadosG1, SG1->G1_INI    )
				aAdd(aDadosG1, SG1->G1_FIM    )
				aAdd(aDadosG1, SG1->G1_OBSERV )
				aAdd(aDadosG1, SG1->G1_FIXVAR )
				aAdd(aDadosG1, aDadosDest[2]  )
				aAdd(aDadosG1, aDadosDest[3]  )
				aAdd(aDadosG1, cRevAtu        )
				aAdd(aDadosG1, cRevAtu        )
				aAdd(aDadosG1, SG1->G1_NIV    )
				aAdd(aDadosG1, SG1->G1_NIVINV )
				aAdd(aDadosG1, SG1->G1_POTENCI)
				aAdd(aDadosG1, SG1->G1_OK     )
				aAdd(aDadosG1, SG1->G1_VECTOR )
				aAdd(aDadosG1, SG1->G1_TIPVEC )
				aAdd(aDadosG1, SG1->G1_VLCOMPE)
				aAdd(aDadosG1, Iif(FieldPos("G1_USAALT") > 0, SG1->G1_USAALT, ""))

				If nAtuRev == 0
					//ATUALIZA A REVISAO FINAL DOS DEMAIS COMPONENTES
					cQuery    := " SELECT SG1.R_E_C_N_O_ G1REC "
					cQuery    +=   " FROM " + RetSqlName("SG1") + " SG1 "
					cQuery    +=  " WHERE SG1.D_E_L_E_T_ = ' ' "
					cQuery    +=    " AND SG1.G1_FILIAL = '" + xFIlial("SG1") + "' "
					cQuery    +=    " AND SG1.G1_COD    = '" + aDadosG1[1] + "' "
					cQuery    +=    " AND SG1.R_E_C_N_O_ <> " + cValToChar(aRecnosSG1[NZ])
					cQuery    := ChangeQuery(cQuery)
					cAliasRev := GetNextAlias()
					dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasRev, .T., .T.)
					While (cAliasRev)->(!Eof())
						SG1->(dbGoTo((cAliasRev)->(G1REC)))
						If SG1->(RecNo()) == aRecnosSG1[NZ] .Or.!( cRevProd >= SG1->G1_REVINI  .and. cRevProd <= SG1->G1_REVFIM)
							(cAliasRev)->(dbSkip())
							Loop
						EndIf
						lNatuRev := .F.
						If SG1->G1_COMP == cCodOrig
							For nX := 1 to Len(aRecnosSG1)
								If SG1->(RecNo()) == aRecnosSG1[nX]
									lNatuRev := .T.
									Exit
								EndIf
							Next nX
							If lNatuRev
								(cAliasRev)->(dbSkip())
								Loop
							EndIf
						EndIf
						Reclock("SG1",.F.)
						Replace SG1->G1_REVFIM With aDadosG1[13]
						SG1->(MsUnlock())
						(cAliasRev)->(dbSkip())
					End
					(cAliasRev)->(dbCloseArea())

					A200RevisG5(aDadosG1[1],,slRevAut)
				EndIf

				//CRIA UM REGISTRO COM O COMPONENTE DESTINO, COM REVISAO INICIAL IGUAL A NOVA REVISAO CRIADA
				Reclock("SG1",.T.)
				Replace G1_FILIAL  With xFIlial("SG1")
				Replace G1_COD     With aDadosG1[1]
				Replace G1_COMP    With aDadosG1[2]
				Replace G1_TRT     With aDadosG1[3]
				Replace G1_QUANT   With aDadosG1[4]
				Replace G1_PERDA   With aDadosG1[5]
				Replace G1_INI     With aDadosG1[6]
				Replace G1_FIM     With aDadosG1[7]
				Replace G1_OBSERV  With aDadosG1[8]
				Replace G1_FIXVAR  With aDadosG1[9]
				Replace G1_GROPC   With aDadosG1[10]
				Replace G1_OPC     With aDadosG1[11]
				Replace G1_REVINI  With aDadosG1[12]
				Replace G1_REVFIM  With aDadosG1[13]
				Replace G1_NIV     With aDadosG1[14]
				Replace G1_NIVINV  With aDadosG1[15]
				Replace G1_POTENCI With aDadosG1[16]
				Replace G1_OK      With aDadosG1[17]
				Replace G1_VECTOR  With aDadosG1[18]
				Replace G1_TIPVEC  With aDadosG1[19]
				Replace G1_VLCOMPE With aDadosG1[20]

				If FieldPos("G1_USAALT") > 0
					If !Empty(aDadosG1[21])
						Replace G1_USAALT With aDadosG1[21]
					Else
						Replace G1_USAALT With "1"
					EndIf
				EndIf

				cGrpOrig := aDadosG1[10]
				cCodOrig := cCodOrig2
				cOpcOrig := aDadosG1[11]
				cCodDest := aDadosG1[2]
				SG1->(MsUnlock())
			Next nz

			If !sl200Auto .And. !lGeral
				oMark:Refresh()
			EndIf
		EndIf

		Pergunte('PCPA200', .F.)

		If !sl200Auto .And. !lGeral
			oMark:Refresh()
		EndIf

		//Grava a substituicao de componentes na tabela SGF
		dbSelectArea("SGF")
		If Len(aRecnosSGF) > 0
			If lGeral
				MsProcTxt(STR0268) //"Atualizando os componentes x operações."
			EndIf

			For nz := 1 to Len(aRecnosSGF)
				SGF->(dbGoto(aRecnosSGF[NZ]))

				If lIntNewMRP
					A637AddJIn(@aMRPxJson, "DELETE") //Exclui registro anterior
				EndIf

				//Verificar os empenhos das ordens de produção em aberto
				If cValToChar(MV_PAR03) == '1'
					dbSelectArea("SD4")
					cAlias  := GetNextAlias()
					If AllTrim(Upper(TcGetDb())) $ "|POSTGRES|ORACLE|DB2|"
						BeginSql Alias cAlias
							SELECT SD4.D4_OP, SC2.C2_PRODUTO, SC2.R_E_C_N_O_, SD4.R_E_C_N_O_ SD4RECNO FROM %Table:SD4% SD4
							INNER JOIN %Table:SC2% SC2 ON SD4.D4_OP = SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN
							WHERE SC2.C2_FILIAL  = %Exp:SGF->GF_FILIAL% AND
								SC2.C2_PRODUTO = %Exp:SGF->GF_PRODUTO% AND
								SD4.D4_COD     = %Exp:SGF->GF_COMP% AND
								SD4.D4_TRT     = %Exp:SGF->GF_TRT% AND
								SC2.%NotDel%
						EndSql

					Else
						BeginSql Alias cAlias
							SELECT SD4.D4_OP, SC2.C2_PRODUTO, SC2.R_E_C_N_O_, SD4.R_E_C_N_O_ SD4RECNO FROM %Table:SD4% SD4
							INNER JOIN %Table:SC2% SC2 ON SD4.D4_OP = SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN
							WHERE SC2.C2_FILIAL  = %Exp:SGF->GF_FILIAL% AND
								SC2.C2_PRODUTO = %Exp:SGF->GF_PRODUTO% AND
								SD4.D4_COD     = %Exp:SGF->GF_COMP% AND
								SD4.D4_TRT     = %Exp:SGF->GF_TRT% AND
								SC2.%NotDel%
						EndSql
					EndIf

					While (cAlias)->(!EOF())
						SC2->(dbGoTo((cAlias)->R_E_C_N_O_))
						If A650DefLeg(1) .OR. A650DefLeg(2) //Prevista ou em aberto
							nResult := aScan(aOrdens,{|x| x[2] == (cAlias)->D4_OP})
							If nResult == 0
								aAdd(aOrdens,{.T.       ,;
									(cAlias)->D4_OP     ,;
									(cAlias)->C2_PRODUTO,;
									{(cAlias)->SD4RECNO},;
									.F.                 ,;
									aRecnosSG1[1]		})
							Else
								aAdd(aOrdens[nResult][4], (cAlias)->SD4RECNO)
							EndIf
						EndIf
						(cAlias)->(dbSkip())
					End
					(cAlias)->(dbCloseArea())
				EndIf

				Reclock("SGF", .F.)
				Replace SGF->GF_COMP With aDadosDest[1]
				SGF->(MsUnlock())

				If lIntNewMRP
					A637AddJIn(@aMRPxJson, "INSERT") //Insere registro alterado
				EndIf
			Next nz

			If lIntNewMRP .AND. aMRPxJson != Nil .and. Len(aMRPxJson[1]) > 0
				MATA637INT("INSERT", aMRPxJson[1])
				aSize(aMRPxJson[1], 0)
				FreeObj(aMRPxJson[2])
				aMRPxJson[2] := Nil
			EndIf
		EndIf

		If PCPIntgPPI()
			SG1->(dbClearFilter())
			If !sl200Auto .And. !lGeral
				oMark:SetFilterDefault("")
			EndIf

			SG1->(dbSetOrder(1))
			For nz := 1 to Len(aRecnosSG1)
				SG1->(dbGoto(aRecnosSG1[nz]))
				//Verifica se deve ser processado. (filtros)
				cCodPai := SG1->G1_COD
				PCPA200PPI( , cCodPai, 4, .T., .T.)
			Next nz
			P200ErrPPI()

			If !sl200Auto .And. !lGeral
				oMark:SetFilterDefault("@" + cFilQuery)
				oMark:Refresh()
			EndIf
		EndIf

		//Replicar alteração para os empenhos da ordem
		If Len(aOrdens) > 0

			//Eliminar ordens que não tiveram SG1 atualizado
			if !lGeral
				For nI := Len(aOrdens) to 1 Step - 1
					nResult := aScan(aAtualiza, aOrdens[nI][6])
					If nResult == 0
						ADEL(aOrdens , nI)
						ASIZE(aOrdens, Len(aOrdens)-1)
					EndIf
				Next
			Endif

			aMata380 := {}
			nQuant   := 0

			If !sl200Auto .And. !lGeral
				If Len(aOrdens) > 0 .And. MATA637LIS(aOrdens)
					lAltEmp := .T.
				EndIf
			Else
				If lGeral
					lAltEmp	:= .F.
					If CVALTOCHAR(MV_PAR03) == '1'
						lAltEmp	:= .T.
					EndIf
				Else
					nPos :=	aScan(aAutoCab, {|x| x[1] == "ALTEMPENHO"} )
					If ( nPos > 0 .And. aAutoCab[nPos,2] == "S" .And. Len(aOrdens) > 0)
						lAltEmp	:= .T.
					Else
						lAltEmp	:= .F.
					EndIf
				EndIf
			EndIf

			If lAltEmp

				If lGeral
					MsProcTxt(STR0269) //"Atualizando os empenhos das ordens de produção."
				EndIf

				For nI := 1 to Len(aOrdens)
					If aOrdens[nI][1] == .T.

						nQuant := 0
						aMata380 := {}

						For nJ := 1 to Len(aOrdens[nI][4])

							SD4->(dbGoTo(aOrdens[nI][4][nJ]))

							nQuant  += SD4->D4_QUANT
							cTRT    := SD4->D4_TRT
							cProdPai:= SD4->D4_PRODUTO

							aAdd( aMata380, {{'D4_OP'    , SD4->D4_OP     , Nil}, ;
											{'D4_COD'    , SD4->D4_COD    , Nil}, ;
											{'D4_TRT'    , SD4->D4_TRT    , Nil}, ;
											{'D4_LOTECTL', SD4->D4_LOTECTL, Nil}, ;
											{'D4_NUMLOTE', SD4->D4_NUMLOTE, Nil}})

							MsExecAuto( { |x,y| MATA380(x,y) }, aMata380[1], 5 )
							If lMsErroAuto
								MostraErro()
							EndIf
							aSize(aMata380, 0)
						Next

						dbSelectArea('SB1')
						SB1->(dbSetOrder(1))
						SB1->(dbSeek(xFIlial('SB1')+aDadosDest[1]))

						cLocal := If(SB1->B1_APROPRI=="I", cLocProc, SB1->B1_LOCPAD)

						dbSelectArea('SC2')
						SC2->(dbSetOrder(1))
						SC2->(dbSeek(xFIlial('SC2')+aOrdens[nI][2]))

						aSize(aMata380, 0)

						dbSelectArea('SB2')
						SB2->(dbSetOrder(1))
						If !SB2->(dbSeek(xFIlial("SB2")+aDadosDest[1]+cLocal))
							CriaSB2(aDadosDest[1],cLocal)
						EndIf

						// ALTERAÇÃO MATEUS HENGLE - 23/06/23
						If slUsaSBZ // VERIFICA SE O PARAMETRO ESTÁ SETADO COM A SBZ
							cLocal:= GetAdvFVal("SBZ","BZ_LOCPAD",xFilial("SBZ")+aDadosDest[1],1,cLocal,.T.) //https://tdn.totvs.com/pages/releaseview.action?pageId=6814937
						EndIf
						// ALTERAÇÃO MATEUS HENGLE - 23/06/23

						aAdd( aMata380, {{'D4_OP'    , aOrdens[nI][2], Nil}, ;
										{'D4_COD'    , aDadosDest[1] , Nil}, ;
										{'D4_LOCAL'  , cLocal       , Nil}, ;
										{'D4_QTDEORI', nQuant        , Nil},;
										{'D4_QUANT'  , nQuant        , Nil},;
										{'D4_DATA'   , SC2->C2_DATPRI, Nil},;
										{'D4_TRT'    , cTRT          , Nil},;
										{'D4_PRODUTO',cProdPai       , Nil}})

						MsExecAuto( { |x,y| MATA380(x,y) }, aMata380[1] , 3 )
						If lMsErroAuto
							MostraErro()
						EndIf
					EndIf
				Next
			EndIf
		EndIf

		//Integração das estruturas com o MRP.
		If lIntMrp
			PCPA200MRP(Nil, Nil, oPaisInt)
		EndIf

		dbSelectArea("SG1")

		//M200SUB - Ponto de entrada executado apos a gravacao da substituicao dos componentes
		If slM200SUB
			ExecBlock("M200SUB",.F.,.F.,aRecnosSG1)
		EndIf

		//Altera conteudo do parametro de niveis
		If Len(aRecnosSG1) > 0
			a200NivAlt()
		EndIf

	EndIf

	SGF->(RestArea(aAreaSGF))

	If Len(aErrEstrut) > 0
		A200ErrStr(aErrEstrut)
	EndIf

	//Remove lock's - Fonte PCPA200EVDEF
	SG1UnLockR(,,soRecNo)
	soRecNo := Nil

	If lIntMrp
		FreeObj(oPaisInt)
	EndIf

	If lRet .And. !sl200Auto .And. !lGeral
		oMark:GetOwner():End()
		oMark := FWMarkBrowse():New()
		oMark:SetAlias( "SG1" )
		oMark:SetDescription( OemToAnsi(STR0128) )	//"Substituicao de Componentes"
		oMark:SetFieldMark( "G1_OK" )
		oMark:SetFilterDefault("@"+cFilQuery)
		oMark:SetValid({|| ValidMarca() })
		oMark:SetAfterMark({|| RELockSG1() })
		oMark:SetAllMark({|| MarkAll(oMark) })
		oMark:Activate()
	EndIf

Return

/*/{Protheus.doc} RELockSG1
Reloca a SG1 após bug frame que remove o lock pré-existe em MarkBrowse
@author brunno.costa
@since 11/04/2019
@version 1.0
/*/
Static Function RELockSG1()
	If !SG1->(Eof()) .AND. !IsInCallStack("SHOWDATA") .AND. !IsInCallStack("LINEREFRESH")
		soRecNo := Iif(soRecNo == Nil, JsonObject():New(), soRecNo)
		If soRecNo[cValToChar(SG1->(RecNo()))]
			SG1->(SimpleLock())
		EndIf
	EndIf
Return

/*/{Protheus.doc} A200ErrStr
Monta tela para exibir o que nao foi substituido pois o componente ja existia na estrutura.
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - aErrEstrut, array, Array contendo os produtos nao substituidos
@return .T.
/*/
Static Function A200ErrStr(aErrEstrut)
	Local aHeader  := { }
	Local aSizes   := { }
	Local oBrowse
	Local oDlgErr
	Local oGroup
	Local oPanel

	aAdd(aHeader,STR0011) //Produto
	aAdd(aHeader,STR0135) //Mensagem

	aAdd(aSizes,60)
	aAdd(aSizes,100)
	aAdd(aSizes,30)
	aAdd(aSizes,70)
	aAdd(aSizes,30)
	aAdd(aSizes,70)

	DEFINE MSDIALOG oDlgErr TITLE STR0136 FROM 0,0 TO 350,800 PIXEL //"Listagem de Inconsistencias"
	oPanel  := tPanel():Create(oDlgErr, 1, 1,,,,,,, 350, 800)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oGroup  := TGroup():New(05,07,152,396,STR0137,oPanel,,,.T.) //"Dados"
	oBrowse := TWBrowse():New(14,12,380,135,,aHeader,aSizes,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
	oBrowse:SetArray(aErrEstrut)
	oBrowse:bLine := {|| { aErrEstrut[oBrowse:nAT,01], aErrEstrut[oBrowse:nAt,02]} }
	DEFINE SBUTTON FROM 158,370 TYPE 1 ACTION (oDlgErr:End()) ENABLE OF oPanel
	ACTIVATE MSDIALOG oDlgErr CENTER
Return .T.

/*/{Protheus.doc} A200IniDsc
Inicializa a descricao dos codigos digitados
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - nOpcao    , numerico , Indica se esta validando origem (1) ou destino (2)
@param 02 - oSay      , objeto   , Objeto say que deve ser atualizado
@param 03 - cProduto  , caracter , Codigo do produto digitado
@param 04 - cProdDesOr, caracter , Cod.do produto origem(nOpcao=2) ou destino(nOpcao=1)
@return lRet, logico, indica se o produto origem ja existe na estrutura do produto destino
/*/
Static Function A200IniDsc(nOpcao,oSay,cProduto,cProdDesOr)
	Local aEstruOrig   := {}
	Local lRet		   := .T.

	Default cProdDesOr := Criavar("G1_COMP", .F.)

	Private nEstru     := 0

	SB1->(MsSeek(xFilial("SB1")+cProduto))

	If nOpcao == 1
		cDescOrig:=SB1->B1_DESC

		// Preenche descricao do produto
		oSay:SetText(cDescOrig)
	ElseIf nOpcao == 2
		cDescDest:=SB1->B1_DESC

		// Preenche descricao do produto
		oSay:SetText(cDescDest)
	EndIf

	// Troca a cor do texto para vermelho
	oSay:SetColor(CLR_HRED,GetSysColor(15))

	If !Empty(cProdDesOr)
		//Os produtos origem e destino foram informados. Explode sempre o produto destino.
		aEstruOrig := Estrut( If(nOpcao == 2,cProduto,cProdDesOr) ,1)

		//Verifica se o produto origem ja' existe na estrutura do produto destino
		If (aScan(aEstruOrig,{|x| x[3] == If(nOpcao == 2, cProdDesOr, cProduto) }) > 0)
			Help(' ',1,'A200NODES')
			lRet := .F.
		EndIf
	EndIf
Return (lRet)

/*/{Protheus.doc} a200NivAlt
Seta o Parametro MV_NIVALT para 'S'
@author Fernando Joly/Eduardo
@since 19.05.1999
@version 1.0
@return lRet, logico, False caso ocorra algum problema na Validacao True C.C.
/*/
Static Function a200NivAlt()
	Local aAreaAnt   := GetArea()
	Local lRet       := .F.
	//-- Seta o Parametro para Altera‡Æo de Niveis
	If !(GetMV('MV_NIVALT')=='S')
		lRet := .T.
		PutMV('MV_NIVALT','S')
	EndIf
	RestArea(aAreaAnt)
Return lRet

/*/{Protheus.doc} A200SubOK
Validacao Final da Substituicao de Estrutura
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - cCodOrig, caracter, Codigo do produto origem
@param 02 - cGrpOrig, caracter, Grupo de opcionais origem
@param 03 - cOpcOrig, caracter, Opcionais do produto origem
@param 04 - cCodDest, caracter, Codigo do produto destino
@param 05 - cGrpDest, caracter, Grupo de opcionais destino
@param 06 - cOpcDest, caracter, Opcionais do produto destino
@return lRet, logico, False caso ocorra algum problema na Valida‡„o, True C.C.
/*/
Static Function A200SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
	Local lRet := .T.

	//Valida a utilização do conceito de versão da produção em conjunto com o conceito de componentes opcionais
	If AliasInDic("SVC") .And. (!Empty(cGrpDest) .Or. !Empty(cOpcDest))
		dbSelectArea("SVC")
		dbSetOrder(1)
		If SVC->(DbSeek(xFilial("SVC")))
			Help( ,  , "Help", ,  STR0210,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
				 1, 0, , , , , , {STR0211})  //"Para a utilização dos opcionais, não pode haver versão de produção cadastrada."
			lRet := .F.
		EndIf
	EndIf

	Do Case
		Case Vazio(cCodOrig) .Or. !ExistCpo("SB1",cCodOrig)
			lRet := .F.
			Help('', 1, 'A200PRDORI')
		Case Vazio(cCodDest) .Or. !ExistCpo("SB1",cCodDest)
			lRet := .F.
			Help('', 1, 'A200PRDDES')
	EndCase
Return lRet

/*/{Protheus.doc} a200VldOpe
Validar a operação x Componente
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - aRecnosSGF, array, array de Recnos da SGF. Retorna por referencia.
@param 02 - aRecnoSEM , array, array de Recnos da SG1 sem operacao. Retorna por referencia.
@return lRet, logico, indica se ja existe o componente destino para o mesmo roteiro no cad. de Operação x Componente
/*/
Static Function a200VldOpe(aRecnosSGF, aRecnoSEM)
	Local cRoteiro  := ""
	Local lRet      := .T.
	Local nRecnoSGF := 0

	SGF->(dbSetOrder(2))
	// Valida SGF - Oper. x Compon.
	If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD))
		While SGF->(!Eof());
			.And. SGF->GF_FILIAL  == xFilial("SGF");
			.And. SGF->GF_PRODUTO == SG1->G1_COD

			cRoteiro := SGF->GF_ROTEIRO

			If SGF->GF_COMP == SG1->G1_COMP // Encontra o componente a ser substituido
				nRecnoSGF := SGF->(Recno())
				SGF->(dbSetOrder(2))
				If SGF->(dbSeek(xFilial("SGF")+SG1->G1_COD+cRoteiro+aDadosDest[1]))
					//Já existe o componente destino para o mesmo roteiro no cad. de Operação x Componente
					Help(" ",1,"A200SUBS",,;
						AllTrim(RetTitle("GF_PRODUTO"))+": "+AllTrim(SG1->G1_COD)+"   "+;
						AllTrim(RetTitle("GF_ROTEIRO"))+": "+cRoteiro+"   "+;
						AllTrim(RetTitle("GF_COMP"))+": "+AllTrim(aDadosDest[1]), 4, 0)
					lRet := .F.
					Exit
				EndIf
				SGF->(dbGoto(nRecnoSGF))
				AADD(aRecnosSGF, nRecnoSGF)
			Else
				if CVALTOCHAR(MV_PAR03) == '1'
					AADD(aRecnoSEM, SG1->(Recno()))
				Endif
			EndIf
			SGF->(dbSkip())
		EndDo
	ElseIf CVALTOCHAR(MV_PAR03) == '1'
		AADD(aRecnoSEM, SG1->(Recno()))
	Endif
Return lRet

/*/{Protheus.doc} A200RevisG5
Atualiza cadastro de revisao de componentes SG5
@author brunno.costa
@since 21/01/2019
@version 1.0
@param 01 - cProduto, caracter, codigo do produto
@param 02 - lShow   , logico  , indica se mostra tela de seleção da revisao atual - processo de revisao manual
@param 03 - lRevAut , logico  , indica se contempla processo de revisao automatico (.T.) ou manual (.F.)
@return cRevisao, caracter, codigo da revisao atual do produto
/*/
Static Function A200RevisG5(cProduto, lShow, lRevAut)

	Local aArea      := {}
	Local aAreaSB1   := {}
	Local aAreaSG5   := {}
	Local aRevisoes  := {}
	Local cRevisao   := CriaVar("G1_REVINI")

	Default lShow	 := .T.
	Default lRevAut  := .F.

	aArea := GetArea()
	dbSelectArea("SG5")
	aAreaSG5 := SG5->(GetArea())
	SG5->(dbSetOrder(1))
	If SG5->(dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(SG5->G5_PRODUTO))))
		Do While SG5->(!Eof());
			.And. SG5->G5_FILIAL  == xFilial("SG5");
			.And. SG5->G5_PRODUTO == SubStr(cProduto,1,Len(G5_PRODUTO))

			AADD(aRevisoes,{.F., SG5->G5_REVISAO, DTOC(SG5->G5_DATAREV)})
			cRevisao := SG5->G5_REVISAO
			SG5->(dbSkip())
		EndDo
	EndIf

	dbSelectArea("SB1")
	aAreaSB1 := SB1->(GetArea())
	SB1->(dbSetOrder(1))
	If dbSeek(xFilial("SB1")+cProduto)
		cRevSB := Iif(slRevAtu, PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
		If(cRevSB > cRevisao)
			cRevisao :=	cRevSB //SB1->B1_REVATU
		endif
	EndIf
	RestArea(aAreaSB1)

	AADD(aRevisoes, {.T.,cRevisao,DTOC(dDataBase)} )

	If !Empty(cRevisao)
		dbSelectArea("SG5")
		SG5->(dbSetOrder(1))

		If SG5->(dbSeek(xFilial("SG5")+SubStr(cProduto,1,Len(SG5->G5_PRODUTO))+cRevisao))
			RecLock("SG5",.F.)
		Else
			RecLock("SG5",.T.)
			SG5->G5_FILIAL  := xFilial("SG5")
			SG5->G5_PRODUTO := cProduto
			SG5->G5_REVISAO := cRevisao
		Endif

		SG5->G5_DATAREV := dDataBase
		IF FieldPos("G5_USER") > 0
			SG5->G5_USER := RetCodUsr()
		EndIf

		//Quando Controle de Revisao estiver ativo, grava os campos conforme
		//realizado na A201AtuAx() para Revisao de Estruturas
		If slRevProd .And. Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_REVPROD") == "1"
			SG5->G5_STATUS := "2"
			SG5->G5_MSBLQL := "1"
		EndIf

		If lM200REVI
			ExecBlock("M200REVI", .f., .f.)
		EndIf

		SG5->(MsUnlock())
	EndIf
	RestArea(aAreaSG5)
	RestArea(aArea)
Return cRevisao

/*/{Protheus.doc} RegValido
Verifica se o registro ainda está válido para ser selecionado
@author marcelo.neumann
@since 26/04/2019
@version 1.0
@param nRecno, caracter, Recno a ser validado
@return lValido, logical, Indica se o registro ainda está válido
/*/
Static Function RegValido(nRecno)

	Local aArea     := GetArea()
	Local cAliasTmp := GetNextAlias()
	Local cQuery    := ""
	Local cFiltro   := StrTran(oMark:GetFilterDefault(), "@", " ", 1, 1)
	Local lValido   := .F.

	cQuery := "SELECT 1 FROM " + RetSqlName("SG1")
	cQuery += " WHERE R_E_C_N_O_ = " + cValToChar(nRecno)
	cQuery +=   " AND " + cFiltro

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .T., .F.)
	If (cAliasTmp)->(!EOF())
		lValido := .T.
	EndIf
	(cAliasTmp)->(DbCloseArea())

	RestArea(aArea)

Return lValido

/*/{Protheus.doc} A200SubGrl
Substitui todas as estrutura sem abrir a tela para seleção.
@author michele.girardi
@since 13/05/2024
@version 1.0
@param 01 - oDlg    , objeto, objeto da tela de substituição
@param 02 - cCodOrig, caracter, Codigo do produto origem
@param 03 - cGrpOrig, caracter, Grupo de opcionais origem
@param 04 - cOpcOrig, caracter, Opcionais do produto origem
@param 05 - cCodDest, caracter, Codigo do produto destino
@param 06 - cGrpDest, caracter, Grupo de opcionais destino
@param 07 - cOpcDest, caracter, Opcionais do produto destino
/*/
Static Function A200SubGrl(oDlg, cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest)
	Local aRecnoSEM  := {}
	Local aRecnosSG1 := {}
	Local aRecnosSGF := {}
	Local lRet          := .T.

	Private aDadosDest := {cCodDest, cGrpDest, cOpcDest}
	Private cCodOrig2  := cCodOrig

	Pergunte('PCPA200', .F.)

	A200CriaT()

	MsAguarde({||A200IncluiT(@lRet,cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest,@aRecnosSGF,@aRecnoSEM,@aRecnosSG1)},STR0274,STR0275) //"Aguarde..." //"Processando..."

	If lRet
		MsAguarde({||A200DoSubs(, , , , , , ,.T.,aRecnosSGF,aRecnoSEM,aRecnosSG1)},STR0274,STR0275)
	EndIf

	If lRet
		MSGINFO(STR0276,STR0278) //"Substituição realizada com sucesso."
	Else
		MSGINFO(STR0277,STR0278) //"Substituição não realizada."
	EndIf

	oDlg:End()

Return lRet

/*/{Protheus.doc} A200CriaT
Cria temporária para utilizar na opção Confirmar Geral
@author michele.girardi
@since 14/05/2024
@version 1.0
/*/
Static Function A200CriaT()

	Local aFields := {}
	Local cCampo  := ' '
	Local cNCampo := ' '
	Local cTab    := ' '

	cTab := 'A200SUB'

	cNCampo := 'SUB_FILIAL'
    cCampo  := 'G1_FILIAL'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'SUB_COD'
    cCampo  := 'G1_COD'
    aAdd(aFields, {cNCampo,GetSX3Cache(cCampo, "X3_TIPO"),GetSX3Cache(cCampo, "X3_TAMANHO"),GetSX3Cache(cCampo, "X3_DECIMAL")})

	cNCampo := 'SUB_RECNO'
    aAdd(aFields, {cNCampo,'N',12,0})

	lOk := TCDelFile(cTab)

	//Cria Tabela no Banco
	dbCreate(cTab, aFields, "TOPCONN")

Return

/*/{Protheus.doc} A200IncluiT
Inclui os registros na tabela para que seja utilizada no processamento
da substituição - Confirmar Geral
@author michele.girardi
@since 14/05/2024
@version 1.0
@param 01 - lRet    ,   lógico,   Retorno
@param 02 - cCodOrig,   caracter, Codigo do produto origem
@param 03 - cGrpOrig,   caracter, Grupo de opcionais origem
@param 04 - cOpcOrig,   caracter, Opcionais do produto origem
@param 05 - cCodDest,   caracter, Codigo do produto destino
@param 06 - cGrpDest,   caracter, Grupo de opcionais destino
@param 07 - cOpcDest,   caracter, Opcionais do produto destino
@param 08 - aRecnosSGF, array,    Array com os Recnos da SG1 para atualizar a SGF
@param 09 - aRecnoSEM,  array,    Array com os Recnos da SG1 para atualizar OPs
@param 10 - aRecnosSG1, array,    Array com os Recnos da SG1 para atualizar a SG1
/*/
Static Function A200IncluiT(lRet, cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest,aRecnosSGF,aRecnoSEM,aRecnosSG1)
	Local aAreaSGF   := SGF->(GetArea())
	Local cFilSG1		:= " "
	Local cAliasQry     := GetNextAlias()
	Local cAliasQry1    := GetNextAlias()
	Local lPyme			:= Iif(Type("__lPyme") <> "U", __lPyme, .F.)	//Variavel lPyme utilizada para Tratamento do Siga PyME
	Local nAtual        := 0
	Local nTotal        := 0

	MsProcTxt(STR0270) //"Buscando os registros a serem substituidos."

	cFilSG1 := "INSERT INTO A200SUB (SUB_FILIAL,"
	cFilSG1 +=                     " SUB_COD,"
	cFilSG1 +=                     " SUB_RECNO,"
	cFilSG1 +=                     " R_E_C_N_O_)"
	cFilSG1 += " SELECT SG1.G1_FILIAL,"
	cFilSG1 +=        " SG1.G1_COD,"
	cFilSG1 +=        " SG1.R_E_C_N_O_,"
	cFilSG1 +=        " SG1.R_E_C_N_O_"
	cFilSG1 +=   " FROM " + RetSqlName('SG1') + " SG1"
	cFilSG1 +=  " WHERE SG1.G1_FILIAL  = '" + xFIlial("SG1") + "'"
	cFilSG1 +=    " AND SG1.G1_COMP    = '" + cCodOrig + "'"
	cFilSG1 +=    " AND SG1.D_E_L_E_T_ = ' '"

	If !lPyme
		cFilSG1 += " AND SG1.G1_GROPC = '" + cGrpOrig + "'"
 		cFilSG1 += " AND SG1.G1_OPC   = '" + cOpcOrig + "'"
	EndIf

	If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
		cFilSG1 += " AND 1 = 1"
	Else
		cFilSG1 += " AND 1 = 2"
	EndIf

	cFilSG1 += getCondRev("SG1")

	cFilSG1 += " AND (SELECT COUNT(SG12.G1_COD)"
	cFilSG1 +=        " FROM " + RetSqlName("SG1") + " SG12"
	cFilSG1 +=       " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cFilSG1 +=          " ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
	cFilSG1 +=         " AND SB1.B1_COD = SG1.G1_COD"
	cFilSG1 +=         " AND SB1.D_E_L_E_T_ = ' '"
	If slRevAtu .And. slUsaSBZ
		cFilSG1 +=    " LEFT JOIN " + RetSqlName("SBZ") + " SBZ"
		cFilSG1 +=      " ON SBZ.BZ_FILIAL = '" + xFilial('SBZ') + "'"
		cFilSG1 +=     " AND SBZ.BZ_COD = SG1.G1_COD"
		cFilSG1 +=     " AND SBZ.D_E_L_E_T_ = ' '"
	EndIf
	cFilSG1 +=       " WHERE SG12.G1_FILIAL  = '" + xFilial('SG1') + "'"
	cFilSG1 +=         " AND SG12.G1_COD     = SG1.G1_COD"
	cFilSG1 +=         " AND SG12.G1_COMP    = '" + aDadosDest[1] + "'"
	cFilSG1 +=         " AND SG12.G1_TRT     = SG1.G1_TRT"
	cFilSG1 +=         " AND SG12.D_E_L_E_T_ = ' '"
	If slRevAtu .And. slUsaSBZ
		cFilSG1 +=     " AND COALESCE(SBZ.BZ_REVATU, SB1.B1_REVATU) BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM"
	Else
		cFilSG1 +=     " AND SB1.B1_REVATU BETWEEN SG12.G1_REVINI AND SG12.G1_REVFIM"
	EndIf
	cFilSG1 += ") = 0"

	MATExecQry(cFilSG1)

	MsProcTxt(STR0271) //"Processando os registros a serem substituidos."

	cFilSG1 := " SELECT COUNT(*) REGISTROS FROM A200SUB "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFilSG1),cAliasQry1,.T.,.T.)
	If (cAliasQry1)->(!Eof())
		nTotal := (cAliasQry1)->REGISTROS
	EndIf
	(cAliasQry1)->(dbCloseArea())

	If nTotal == 0
		Help( ,  , "Help", ,  STR0197, 1, 0, , , , , , {STR0198})
		lRet := .F.
	EndIf

	If lRet
		cFilSG1 := "SELECT SUB_FILIAL, "
		cFilSG1 += "       SUB_COD, "
		cFilSG1 += "       SUB_RECNO "
		cFilSG1 += "  FROM A200SUB "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFilSG1),cAliasQry,.T.,.T.)
		While (cAliasQry)->(!Eof())

			nAtual++
			MsProcTxt(STR0272	 + cValToChar(nAtual) + STR0273 + cValToChar(nTotal) + "...") //"Analisando registro " " de "

			SG1->(dbGoto((cAliasQry)->SUB_RECNO))

			lRet := a200VldOpe(@aRecnosSGF, @aRecnoSEM)
			If !lRet
				Exit
			EndIf
			aAdd(aRecnosSG1,SG1->(Recno()))

			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

	SGF->(RestArea(aAreaSGF))

Return lRet

/*/{Protheus.doc} getCondRev
Retorna a condição para filtrar a revisão dos componentes.
@type  Static Function
@author Lucas Fagundes
@since 18/06/2025
@version P12
@param cAliasSG1, Caracter, Alias utilizado para a SG1.
@return cCondRev, Caracter, Condição para filtrar a revisão.
/*/
Static Function getCondRev(cAliasSG1)
	Local cCondRev := ""
	Local cReplace := ""
	Local cSearch  := ""

	If slRevAtu .And. slUsaSBZ
		cCondRev += " AND EXISTS (SELECT 1 "
		cCondRev +=               " FROM " + RetSqlName('SB1') + " SB1"
		cCondRev +=               " LEFT JOIN " + RetSqlName('SBZ') + " SBZ"
		cCondRev +=                 " ON SBZ.BZ_FILIAL  = '" + xFilial("SBZ") + "'"
		cCondRev +=                " AND SBZ.BZ_COD     = [ALIASSG1].G1_COD"
		cCondRev +=                " AND SBZ.D_E_L_E_T_ = ' '"
		cCondRev +=              " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
		cCondRev +=                " AND SB1.B1_COD     = [ALIASSG1].G1_COD"
		cCondRev +=                " AND SB1.D_E_L_E_T_ = ' '
		cCondRev +=                " AND ((COALESCE(SBZ.BZ_REVATU, SB1.B1_REVATU) BETWEEN [ALIASSG1].G1_REVINI AND [ALIASSG1].G1_REVFIM) "
		cCondRev +=                     " OR [ALIASSG1].G1_REVFIM = 'ZZZ')) "
	ElseIf slRevAut
		cCondRev += " AND EXISTS (SELECT 1 "
		cCondRev +=               " FROM " + RetSqlName('SB1') + " SB1 "
		cCondRev +=              " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cCondRev +=                " AND SB1.D_E_L_E_T_ = ' ' "
		cCondRev +=                " AND SB1.B1_COD     = [ALIASSG1].G1_COD "
		cCondRev +=                " AND ((SB1.B1_REVATU BETWEEN [ALIASSG1].G1_REVINI AND [ALIASSG1].G1_REVFIM) "
		cCondRev +=                     " OR [ALIASSG1].G1_REVFIM = 'ZZZ')) "
	Else
		cCondRev += " AND EXISTS (SELECT 1 "
		cCondRev +=               " FROM " + RetSqlName('SB1') + " SB1 "
		cCondRev +=              " WHERE SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
		cCondRev +=                " AND SB1.D_E_L_E_T_ = ' ' "
		cCondRev +=                " AND SB1.B1_COD     = [ALIASSG1].G1_COD "
		cCondRev +=                " AND (((SB1.B1_REVATU BETWEEN [ALIASSG1].G1_REVINI AND [ALIASSG1].G1_REVFIM) "
		cCondRev +=                     " OR [ALIASSG1].G1_REVFIM = 'ZZZ') OR (B1_REVATU = ' '))) "
	EndIf

	cSearch  := "[ALIASSG1]"
	cReplace := cAliasSG1

	If Empty(cAliasSG1)
		cSearch  := "[ALIASSG1]."
		cReplace := ""
	EndIf

	cCondRev := StrTran(cCondRev, cSearch, cReplace)

Return cCondRev
