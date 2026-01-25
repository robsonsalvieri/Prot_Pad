#INCLUDE "GFEX021.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE GFEX021001 'GFEX21001'
#DEFINE GFEX021002 'GFEX21002'
#DEFINE GFEX021003 'GFEX21003'
#DEFINE GFEX021004 'GFEX21004'
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEX021
Cadastro de Configuração Tipo Operação 

@author João Leonardo Schmidt
@since 27/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEX021()
	Local oBrowse := Nil
	Local cERPGFE := SuperGetMv("MV_ERPGFE",.F.,"1")

	If cERPGFE == "2"
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("GVS")
		oBrowse:SetMenuDef("GFEX021")
		oBrowse:SetDescription(STR0003)

		oBrowse:Activate()
	Else
		GFEMessage(5, GFEX021001,STR0001,STR0002)
	EndIf
Return Nil

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "AxPesqui"        OPERATION 1  ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEX021" OPERATION 2  ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GFEX021" OPERATION 3  ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GFEX021" OPERATION 4  ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GFEX021" OPERATION 5  ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.GFEX021" OPERATION 9  ACCESS 0 // "Copiar"
	ADD OPTION aRotina TITLE STR0010 ACTION "VIEWDEF.GFEX021" OPERATION 8  ACCESS 0 // "Imprimir"
	ADD OPTION aRotina TITLE STR0011 ACTION "GFEX021TES()"    OPERATION 10 ACCESS 0 // "Simulador de Regras"
Return aRotina

Static Function ModelDef()
	Local oModel     := Nil
	Local oStructGVS := FWFormStruct(1,"GVS")

	oModel := MPFormModel():New("GFEX021", /* */, {|oModel| GFEX021VAL(oModel)}, /**/, /**/, /*bCancel*/)
	oModel:AddFields("GFEX021_GVS", Nil, oStructGVS,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetPrimaryKey({"GVS_FILIAL", "GVS_CFOP", "GVS_TPIMP", "GVS_TRBIMP", "GVS_CRDICM", "GVS_CRDPC", "GVS_FGER" , "GVS_TPONUS", "GVS_TES"})
	oModel:SetDescription(STR0012) // "Configuração Tipo Operação
	oStructGVS:SetProperty("GVS_CFOP" , MODEL_FIELD_OBRIGAT, .F.)

Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEX021")
	Local oView      := Nil
	Local oStructGVS := FWFormStruct(2,"GVS")

	oView := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField( "GFEX021_GVS" , oStructGVS, /*cLinkID*/ )
Return oView

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEX020VAL(oModel)
Validações
@type  Function
@author Squad GFEF
@since 11/06/2020
@version 1.0
@param oModel, object, Modelo de dados
@example
(examples)
@see (links_or_references)
/*/
//---------------------------------------------------------------------------------------------
Function GFEX021VAL(oModel)
	Local lRet       := .T.
	Local oModelGVS  := oModel:GetModel("GFEX021_GVS") //Recebe o model do Grid
	Local nOperation := oModel:GetOperation()
	Local cAliasQry  := Nil
	Local cWhere	 := ""

	If nOperation == MODEL_OPERATION_INSERT

		If GFXCP1212410("GVS_TES")
			cWhere += " AND GVS.GVS_TES = '" + oModelGVS:GetValue("GVS_TES") + "'"
		EndIf
		cWhere 	:= "%" + cWhere + "%"

		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT 1
			FROM %Table:GVS% GVS
			WHERE GVS.GVS_FILIAL = %xFilial:GVS%
			AND GVS.GVS_CFOP = %Exp:oModelGVS:GetValue("GVS_CFOP")%
			AND GVS.GVS_TPIMP = %Exp:oModelGVS:GetValue("GVS_TPIMP")%
			AND GVS.GVS_TRBIMP = %Exp:oModelGVS:GetValue("GVS_TRBIMP")%
			AND GVS.GVS_CRDICM = %Exp:oModelGVS:GetValue("GVS_CRDICM")%
			AND GVS.GVS_CRDPC = %Exp:oModelGVS:GetValue("GVS_CRDPC")%
			AND GVS.GVS_FGER = %Exp:oModelGVS:GetValue("GVS_FGER")%
			AND GVS.GVS_TPONUS = %Exp:oModelGVS:GetValue("GVS_TPONUS")%
			AND GVS.%NotDel%
			%Exp:cWhere%
		EndSql

		If (cAliasQry)->(!Eof())
			oModel:SetErrorMessage(,,,,,"["+GFEX021002+"] "+STR0013,STR0014)
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf
Return lRet

Function GFEX021BOPER(cCFOP, cTPIMP, cTRBIMP, cCRDICM, cCRDPC, cFGER, cTPONUS, aMsgTES, cTES)
	Local lFindGVS  	:= .F.
	Local lFindGVS1 	:= .F.
	Local aRet      	:= Array(11)
	Local cAliasQry 	:= Nil
	Local aAux      	:= {}
	Local nMaisEsp  	:= 0
	Local nDes      	:= 0
	Local aChave    	:= Array(9)
	Local aGVS_TPIMP  	:= RetSx3Box(Posicione('SX3',2,'GVS_TPIMP','X3CBox()'),,,1)
	Local aGVS_TRBIMP 	:= RetSx3Box(Posicione('SX3',2,'GVS_TRBIMP','X3CBox()'),,,1)
	Local aGVS_CRDICM 	:= RetSx3Box(Posicione('SX3',2,'GVS_CRDICM','X3CBox()'),,,1)
	Local aGVS_CRDPC  	:= RetSx3Box(Posicione('SX3',2,'GVS_CRDPC','X3CBox()'),,,1)
	Local aGVS_FGER   	:= RetSx3Box(Posicione('SX3',2,'GVS_FGER','X3CBox()'),,,1)
	Local aGVS_TPONUS 	:= RetSx3Box(Posicione('SX3',2,'GVS_TPONUS','X3CBox()'),,,1)
	Local cTitles       := ""
	Local cSelect		:= " "
	Local cWhere 		:= " "

	Default cCFOP   := "0"
	Default cTPIMP  := "0"
	Default cTRBIMP := "0"
	Default cCRDICM := "0"
	Default cCRDPC  := "0"
	Default cFGER   := "0"
	Default cTPONUS := "0"
	Default cTES	:= Space(3)
	Default aMsgTES := {}

	cAliasQry := GetNextAlias()
	
	BeginSql Alias cAliasQry
		SELECT 1
		FROM %Table:GVS% GVS
		WHERE GVS.GVS_FILIAL = %xFilial:GVS%
		AND GVS.%NotDel% 
	EndSql
	
	If (cAliasQry)->(!Eof())
		lFindGVS := .T.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
	
	// Verifica se existe dados na GVS
	If lFindGVS
		lFindGVS1 := .F.
			
		If GFXCP1212410("GVS_TES")
			cSelect 	  := ", GVS.GVS_TES"
			cWhere 		  := " AND (GVS.GVS_TES = '" + cTES + "' OR GVS.GVS_TES = ' ')"
		EndIf	

		cSelect := "%" + cSelect + "%"
		cWhere 	:= "%" + cWhere + "%"

		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT GVS.GVS_CFOP,
		    	   GVS.GVS_TPIMP,
				   GVS.GVS_TRBIMP,
				   GVS.GVS_CRDICM,
				   GVS.GVS_CRDPC,
				   GVS.GVS_FGER,
				   GVS.GVS_TPONUS,
				   GVS.GVS_TPOPER
				   %Exp:cSelect%
			FROM %Table:GVS% GVS
			WHERE GVS.GVS_FILIAL = %xFilial:GVS%
			AND (GVS.GVS_CFOP = %Exp:cCFOP%
				OR GVS.GVS_CFOP = '000'
				OR GVS.GVS_CFOP = '0000'
				OR GVS.GVS_CFOP = '')
			AND (GVS.GVS_TPIMP = %Exp:cTPIMP%
				OR GVS.GVS_TPIMP = '0')
			AND (GVS.GVS_TRBIMP = %Exp:cTRBIMP%
				OR GVS.GVS_TRBIMP = '0')
			AND (GVS.GVS_CRDICM = %Exp:cCRDICM%
				OR GVS.GVS_CRDICM = '0')
			AND (GVS.GVS_CRDPC = %Exp:cCRDPC%
				OR GVS.GVS_CRDPC = '0')
			AND (GVS.GVS_FGER = %Exp:cFGER%
				OR GVS.GVS_FGER = '0')
			AND (GVS.GVS_TPONUS = %Exp:cTPONUS%
				OR GVS.GVS_TPONUS = '0')
			AND GVS.%NotDel% 
			%Exp:cWhere%
		EndSql
		
		If (cAliasQry)->(!Eof())
			lFindGVS1 := .T.

			aAdd(aMsgTES, STR0034)

			Do While (cAliasQry)->(!Eof())
				If GFXCP1212410("GVS_TES")
					aAux := GFEX021CRI((cAliasQry)->GVS_CFOP,;
									   (cAliasQry)->GVS_TPIMP,;
									   (cAliasQry)->GVS_TRBIMP,;
									   (cAliasQry)->GVS_CRDICM,;
									   (cAliasQry)->GVS_CRDPC,;
									   (cAliasQry)->GVS_FGER,;
									   (cAliasQry)->GVS_TPONUS,;
									   (cAliasQry)->GVS_TES)
				Else
					aAux := GFEX021CRI((cAliasQry)->GVS_CFOP,;
									   (cAliasQry)->GVS_TPIMP,;
									   (cAliasQry)->GVS_TRBIMP,;
									   (cAliasQry)->GVS_CRDICM,;
									   (cAliasQry)->GVS_CRDPC,;
									   (cAliasQry)->GVS_FGER,;
									   (cAliasQry)->GVS_TPONUS)
				EndIf

				If aAux[1] > nMaisEsp .Or. (aAux[1] == nMaisEsp .And. aAux[2] <= nDes)
					nMaisEsp  := aAux[1]
					nDes      := aAux[2]
					cTitles   := aAux[3]
					aChave[1] := (cAliasQry)->GVS_CFOP
					aChave[2] := (cAliasQry)->GVS_TPIMP
					aChave[3] := (cAliasQry)->GVS_TRBIMP
					aChave[4] := (cAliasQry)->GVS_CRDICM
					aChave[5] := (cAliasQry)->GVS_CRDPC
					aChave[6] := (cAliasQry)->GVS_FGER
					aChave[7] := (cAliasQry)->GVS_TPONUS
					aChave[8] := (cAliasQry)->GVS_TPOPER
					If GFXCP1212410("GVS_TES")
						aChave[9] := (cAliasQry)->GVS_TES
					EndIf
				EndIf
			
				(cAliasQry)->(dbSkip())
			EndDo
		EndIf
		
		(cAliasQry)->(dbCloseArea())
		
		// Verifica se há dados para chave na GVS
		If lFindGVS1
			aRet[1]  := .T.
			aRet[2]  := aChave[8]
			aRet[3]  := Posicione("SX5",1,xFilial("SX5")+"DJ"+AllTrim(aChave[8]),"X5_DESCRI")
			aRet[4]  := aChave[1]
			aRet[5]	 := IIf((nSeek := Ascan(aGVS_TPIMP , { |x| x[2] == aChave[2]} )) > 0,AllTrim( aGVS_TPIMP[nSeek,3]) ,'')
			aRet[6]  := IIf((nSeek := Ascan(aGVS_TRBIMP, { |x| x[2] == aChave[3]})) > 0,AllTrim( aGVS_TRBIMP[nSeek,3]),'')
			aRet[7]  := IIf((nSeek := Ascan(aGVS_CRDICM, { |x| x[2] == aChave[4]})) > 0,AllTrim( aGVS_CRDICM[nSeek,3]),'')
			aRet[8]  := IIf((nSeek := Ascan(aGVS_CRDPC , { |x| x[2] == aChave[5]} )) > 0,AllTrim( aGVS_CRDPC[nSeek,3]) ,'')
			aRet[9]  := IIf((nSeek := Ascan(aGVS_FGER  , { |x| x[2] == aChave[6]}  )) > 0,AllTrim( aGVS_FGER[nSeek,3])  ,'')
			aRet[10] := IIf((nSeek := Ascan(aGVS_TPONUS, { |x| x[2] == aChave[7]})) > 0,AllTrim( aGVS_TPONUS[nSeek,3]),'')
			If GFXCP1212410("GVS_TES")
				aRet[11]  := aChave[9]
			EndIf						
		Else
			aRet[1] := .F.
			aRet[2] := "03"
			aRet[3] := STR0015 // "Nenhuma regra encontrada."
			aAdd(aMsgTES,STR0015) // "Nenhuma regra encontrada."
		EndIf
	Else
		aRet[1] := .F.
		aRet[2] := "02"
		aRet[3] := STR0016 // "Não existe nenhum registro na tabela GVS."
		aAdd(aMsgTES,STR0016) // "Não existe nenhum registro na tabela GVS."
	EndIf
Return aRet

Function GFEX021CRI(cCFOP, cTPIMP, cTRBIMP, cCRDICM, cCRDPC, cFGER, cTPONUS, cTES)
	Local aRet 	  := Array(3)
	Local nCont	  := 0
	Local nPos	  := 0
	Local cTitles := ""

	Default cTES  := Space(3)

	If (cCFOP != "000" .And. cCFOP != "0000" .And. !Empty(cCFOP))
		cTitles += STR0019 + "," //-- "CFOP"
		nCont := nCont + 1
		If nPos == 0
			nPos := 1
		EndIf
	EndIf

	If cTPIMP != "0"
		cTitles += STR0020 + "," //--"Tipo de Imposto"
		nCont := nCont + 1
		If nPos == 0
			nPos := 2
		EndIf
	EndIf

	If cTRBIMP != "0"
		cTitles += STR0021 + "," //-- "Tributação"
		nCont := nCont + 1
		If nPos == 0
			nPos := 3
		EndIf
	EndIf

	If cCRDICM != "0"
		cTitles += STR0022 + "," //-- "Cred ICMS"
		nCont := nCont + 1
		If nPos == 0
			nPos := 4
		EndIf
	EndIf

	If cCRDPC != "0"
		cTitles += STR0023 + "," //-- "Cred PIS/COF"
		nCont := nCont + 1
		If nPos == 0
			nPos := 5
		EndIf
	EndIf

	If cFGER != "0"
		cTitles += STR0024 + "," //-- "Fato Gerador"
		nCont := nCont + 1
		If nPos == 0
			nPos := 6
		EndIf
	EndIf

	If cTPONUS != "0"
		cTitles += STR0025 + "," //-- "Tipo de Ônus"
		nCont := nCont + 1
		If nPos == 0
			nPos := 7
		EndIf
	EndIf

	If GFXCP1212410("GVS_TES")
		If cTES != "000" .And. !Empty(cTES)
			cTitles += STR0035 + "," //-- "TES"
			nCont := nCont + 1
			If nPos == 0
				nPos := 8
			EndIf
		EndIf
	EndIf

	aRet[1] := nCont
	aRet[2] := nPos
	aRet[3] := Subs(cTitles,1,Max(Len(cTitles),1)-1)
Return aRet

Function GFEX021TES()
	Local oSize       := Nil
	Local oGet1       := Nil
	Local oGet2       := Nil
	Local oSay1       := Nil
	Local aPosEnch    := {}
	Local aCmbTpImp   := {}
	Local aCmbTribImp := {}
	Local aCmbIcmCrd  := {}
	Local aCmbPCCrd   := {}
	Local aCmbFatGer  := {}
	Local aCmbTpOnus  := {}
	Local aGVS_TPIMP  := RetSx3Box(Posicione('SX3',2,'GVS_TPIMP','X3CBox()'),,,1)
	Local aGVS_TRBIMP := RetSx3Box(Posicione('SX3',2,'GVS_TRBIMP','X3CBox()'),,,1)
	Local aGVS_CRDICM := RetSx3Box(Posicione('SX3',2,'GVS_CRDICM','X3CBox()'),,,1)
	Local aGVS_CRDPC  := RetSx3Box(Posicione('SX3',2,'GVS_CRDPC','X3CBox()'),,,1)
	Local aGVS_FGER   := RetSx3Box(Posicione('SX3',2,'GVS_FGER','X3CBox()'),,,1)
	Local aGVS_TPONUS := RetSx3Box(Posicione('SX3',2,'GVS_TPONUS','X3CBox()'),,,1)

	Private oListBox    := Nil
	Private oDlg        := Nil
	Private oMsgBar     := Nil
	Private cAlias      := Nil
	Private cOpCFOP     := "    "
	Private cOpTpImp    := ""
	Private cOpTribImp  := ""
	Private cOpIcmCrd   := ""
	Private cOpPCCrd    := ""
	Private cOpFatGer   := ""
	Private cOpTpOnus   := ""

	Default cTES 		:= Space(3)
	Default cOpTES 		:= Space(3)

	// Habilita a skin padrão dos componentes visuais
	SetSkinDefault()

	// Carrega array com as opções do combo-box com as traduções
	aEval( aGVS_TPIMP , {|x| IIf(!Empty(x[1]),Aadd( aCmbTpImp, x[1]),Nil)})
	aEval( aGVS_TRBIMP, {|x| IIf(!Empty(x[1]),Aadd( aCmbTribImp, x[1]),Nil)})
	aEval( aGVS_CRDICM, {|x| IIf(!Empty(x[1]),Aadd( aCmbIcmCrd, x[1]),Nil)})
	aEval( aGVS_CRDPC , {|x| IIf(!Empty(x[1]),Aadd( aCmbPCCrd, x[1]),Nil)})
	aEval( aGVS_FGER  , {|x| IIf(!Empty(x[1]),Aadd( aCmbFatGer, x[1]),Nil)})
	aEval( aGVS_TPONUS, {|x| IIf(!Empty(x[1]),Aadd( aCmbTpOnus, x[1]),Nil)})

	aCampos := {{"CFOP"   ,"C",4,0},;
		{"TPIMP"  ,"C",10,0},;
		{"TRBIMP" ,"C",20,0},;
		{"CRDICM" ,"C",20,0},;
		{"CRDPC"  ,"C",20,0},;
		{"FGER"   ,"C",20,0},;
		{"TPONUS" ,"C",20,0},;
		{"TPOPER" ,"C",2,0},;
		{"DSOPER" ,"C",30,0},;
		{"TES"    ,"C",3,0}}

	cAlias := GFECriaTab({aCampos,{"TPOPER"}})

	dbSelectArea(cAlias)
	ZAP

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ENCHOICE", 100, 60, .T., .T. ) // Adiciona enchoice
	oSize:SetWindowSize({000, 000, 450, 1000})
	oSize:lLateral := .F.  // Calculo vertical
	oSize:Process() //executa os calculos

	aPosEnch := {oSize:GetDimension("ENCHOICE","LININI"),oSize:GetDimension("ENCHOICE","COLINI"),oSize:GetDimension("ENCHOICE","LINEND"),oSize:GetDimension("ENCHOICE","COLEND")}

	DEFINE MSDIALOG oDlg TITLE STR0018 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

	If GFXCP1212410("GVS_TES")
		@ aPosEnch[1]+002, aPosEnch[2]+050 SAY oSay1  PROMPT STR0019 SIZE 050, 010 OF oDlg PIXEL // "CFOP"
		@ aPosEnch[1]+002, aPosEnch[2]+150 SAY oSay7  PROMPT STR0035 SIZE 050, 010 OF oDlg PIXEL // "TES"
		@ aPosEnch[1]+002, aPosEnch[2]+250 SAY oSay2  PROMPT STR0020 SIZE 050, 010 OF oDlg PIXEL // "Tipo de Imposto"
		@ aPosEnch[1]+002, aPosEnch[2]+350 SAY oSay3  PROMPT STR0021 SIZE 050, 010 OF oDlg PIXEL // "Tributação"
		@ aPosEnch[1]+027, aPosEnch[2]+050 SAY oSay4  PROMPT STR0022 SIZE 057, 010 OF oDlg PIXEL // "Cred ICMS"
		@ aPosEnch[1]+027, aPosEnch[2]+150 SAY oSay5  PROMPT STR0023 SIZE 078, 010 OF oDlg PIXEL // "Cred PIS/COF"
		@ aPosEnch[1]+027, aPosEnch[2]+250 SAY oSay6  PROMPT STR0024 SIZE 078, 010 OF oDlg PIXEL // "Fato Gerador"
		@ aPosEnch[1]+027, aPosEnch[2]+350 SAY oSay10 PROMPT STR0025 SIZE 078, 010 OF oDlg PIXEL // "Tipo de Ônus"
	Else
		@ aPosEnch[1]+002, aPosEnch[2]+050 SAY oSay1  PROMPT STR0019 SIZE 050, 010 OF oDlg PIXEL // "CFOP"
		@ aPosEnch[1]+002, aPosEnch[2]+150 SAY oSay2  PROMPT STR0020 SIZE 050, 010 OF oDlg PIXEL // "Tipo de Imposto"
		@ aPosEnch[1]+002, aPosEnch[2]+250 SAY oSay3  PROMPT STR0021 SIZE 050, 010 OF oDlg PIXEL // "Tributação"
		@ aPosEnch[1]+002, aPosEnch[2]+350 SAY oSay4  PROMPT STR0022 SIZE 057, 010 OF oDlg PIXEL // "Cred ICMS"
		@ aPosEnch[1]+027, aPosEnch[2]+050 SAY oSay5  PROMPT STR0023 SIZE 078, 010 OF oDlg PIXEL // "Cred PIS/COF"
		@ aPosEnch[1]+027, aPosEnch[2]+150 SAY oSay6  PROMPT STR0024 SIZE 078, 010 OF oDlg PIXEL // "Fato Gerador"
		@ aPosEnch[1]+027, aPosEnch[2]+250 SAY oSay10 PROMPT STR0025 SIZE 078, 010 OF oDlg PIXEL // "Tipo de Ônus"
	EndIf

	If GFXCP1212410("GVS_TES")
		@ aPosEnch[1]+012, aPosEnch[2]+050 MSGET oGet1     VAR cOpCFOP                      SIZE 080, 010 OF oDlg F3 "13" PIXEL HASBUTTON
		@ aPosEnch[1]+012, aPosEnch[2]+150 MSGET oGet2     VAR cTES                         SIZE 080, 010 OF oDlg F3 "SF4" PIXEL HASBUTTON
		@ aPosEnch[1]+012, aPosEnch[2]+250 COMBOBOX oCombo VAR cOpTpImp   ITEMS aCmbTpImp   SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+012, aPosEnch[2]+350 COMBOBOX oCombo VAR cOpTribImp ITEMS aCmbTribImp SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+050 COMBOBOX oCombo VAR cOpIcmCrd  ITEMS aCmbIcmCrd  SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+150 COMBOBOX oCombo VAR cOpPCCrd   ITEMS aCmbPCCrd   SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+250 COMBOBOX oCombo VAR cOpFatGer  ITEMS aCmbFatGer  SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+350 COMBOBOX oCombo VAR cOpTpOnus  ITEMS aCmbTpOnus  SIZE 080, 010 OF oDlg PIXEL
	Else
		@ aPosEnch[1]+012, aPosEnch[2]+050 MSGET oGet1  VAR cOpCFOP SIZE 080, 010 OF oDlg  F3 "13" PIXEL HASBUTTON
		@ aPosEnch[1]+012, aPosEnch[2]+150 COMBOBOX oCombo VAR cOpTpImp   ITEMS aCmbTpImp   SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+012, aPosEnch[2]+250 COMBOBOX oCombo VAR cOpTribImp ITEMS aCmbTribImp SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+012, aPosEnch[2]+350 COMBOBOX oCombo VAR cOpIcmCrd  ITEMS aCmbIcmCrd  SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+050 COMBOBOX oCombo VAR cOpPCCrd   ITEMS aCmbPCCrd   SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+150 COMBOBOX oCombo VAR cOpFatGer  ITEMS aCmbFatGer  SIZE 080, 010 OF oDlg PIXEL
		@ aPosEnch[1]+037, aPosEnch[2]+250 COMBOBOX oCombo VAR cOpTpOnus  ITEMS aCmbTpOnus  SIZE 080, 010 OF oDlg PIXEL
	EndIf

	oMsgBar := TMsgBar():New(oDlg, "",.F.,.F.,.F.,.F., RGB(116,116,116),,,.F.)

	dbSelectArea(cAlias)

	@ aPosEnch[1]+063, aPosEnch[2]+020 LISTBOX oListBox FIELDS (cAlias)->CFOP, (cAlias)->TES, (cAlias)->TPIMP, (cAlias)->TRBIMP, (cAlias)->CRDICM, (cAlias)->CRDPC, (cAlias)->FGER, (cAlias)->TPONUS, (cAlias)->TPOPER, (cAlias)->DSOPER;
		HEADER STR0019, STR0035, STR0020, STR0021, STR0022, STR0023, STR0024, STR0025, STR0026, STR0027 SIZE 450, 100 OF oDlg PIXEL ColSizes 25,25,50,50,50,50,50,50,50,100

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(ODlg,{||RptStatus( {|| GFEX021BUSCA(), oListBox:Refresh()}, STR0028+"...",STR0029, .T. )},{||ODlg:End()},,) CENTERED
	GFEDelTab(cAlias)
Return

Function GFEX021BUSCA()
	Local aRet
	Default cTES := " "

	dbSelectArea(cAlias)
	ZAP

	If cOpCFOP == "    " .Or. cOpCFOP == "0000" .Or. (ExistCpo("SX5","13"+cOpCFOP))
		aRet := GFEX021BOPER(cOpCFOP, cOpTpImp, cOpTribImp, cOpIcmCrd, cOpPCCrd, cOpFatGer, cOpTpOnus, ,cTES)

		If aRet[1] == .T.
			RecLock(cAlias,.T.)
			(cAlias)->CFOP   := aRet[4]
			(cAlias)->TPIMP  := aRet[5]
			(cAlias)->TRBIMP := aRet[6]
			(cAlias)->CRDICM := aRet[7]
			(cAlias)->CRDPC  := aRet[8]
			(cAlias)->FGER   := aRet[9]
			(cAlias)->TPONUS := aRet[10]
			(cAlias)->TPOPER := aRet[2]
			(cAlias)->DSOPER := aRet[3]
			(cAlias)->TES    := Iif(!Empty(aRet[11]), aRet[11], " - ")
			(cAlias)->(MsUnlock())

			dbSelectArea(cAlias)
			(cAlias)->(dbGoTop())
		Else
			GFEMessage(5,GFEX021003,STR0030,STR0014)
		EndIf
	EndIf

Return

Function GFEX021VLCOP()
	Local lRet     := .F.
	Local lValCamp := .F.

	lValCamp := ExistCpo("SX5","13"+M->GVS_CFOP) .Or. Pertence("") .Or. Pertence("0000")

	If lValCamp
		lRet := .T.
	Else
		GFEMessage(5,GFEX021004,STR0031,STR0032) // {("Não existe registro referente ao CFOP informado."), ("Informe um código existente no cadastro ou efetue o cadastro no programa de manutenção do respectivo.")}
	EndIf

Return lRet
