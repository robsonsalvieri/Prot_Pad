#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "GPCA003.ch"

/*/{Protheus.doc} GPCA003
Cadastro de bombas, bicos e lacres utilizando MVC

@type function
@version 1.0  
@author Duofy
@since 01/08/2025
/*/

Function GPCA003()

	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'A62' )
	oBrowse:SetDescription( STR0001 )

	// adiciona legenda no Browser
	oBrowse:AddLegend( "A62_STATUS == '1'", "GREEN", STR0012)
	oBrowse:AddLegend( "A62_STATUS == '2'", "RED"  , STR0013)

	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Definição do Menu

@type function
@version 1.0  
@author Rafael Brito
@since 01/07/2022
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title  STR0005  		Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title  STR0006  		Action 'VIEWDEF.GPCA003' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title  STR0007  		Action 'VIEWDEF.GPCA003' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title  STR0008  		Action 'VIEWDEF.GPCA003' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title  STR0009  		Action 'VIEWDEF.GPCA003' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title  STR0010  		Action 'VIEWDEF.GPCA003' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title  STR0011  		Action 'VIEWDEF.GPCA003' 	OPERATION 09 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo

@type function
@version 1.0  
@author Rafael Brito
@since 01/07/2022
/*/
Static Function ModelDef()

	Local oStruA62 := FWFormStruct( 1, 'A62', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruA63 := FWFormStruct( 1, 'A63', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruA64 := FWFormStruct( 1, 'A64', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel
	Local bRelac

	//legenda no grid de bicos
	bRelac := {|A,B,C| FwInitCPO(A,B,C), xRET:=( iif( A63->A63_STATUS<>"2" .and. (Empty(DtoS(A63->A63_DTDES)) .or. DtoS(A63->A63_DTDES)>=DtoS(Date())), "BR_VERDE", "BR_VERMELHO" ) ), FwCloseCPO(A,B,C,.T.), FwSetVarMem(A,B,xRET), xRET }
	oStruA63:AddField('','','STATUS','C',11,0,,,{},.F.,bRelac,,,.T.)

	oStruA63:SetProperty("A63_STATUS" ,MODEL_FIELD_VALID  ,{|| GPCA009AVA() } )
	oStruA63:SetProperty("A63_DTDES" ,MODEL_FIELD_VALID  ,{|| GPCA009AVA() } )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'GPCA003', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - BOMBAS  ////////////////////////////

	// Crio a Enchoice com os campos do cadastro de Tanques
	oModel:AddFields( 'A62MASTER', /*cOwner*/, oStruA62 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "A62_FILIAL" , "A62_CODBOM" })

	// Preencho a descrição da entidade
	oModel:GetModel('A62MASTER'):SetDescription(STR0002)


	///////////////////////////  ITENS - BICOS  //////////////////////////////

	// Crio o grid de bicos
	oModel:AddGrid('A63DETAIL', 'A62MASTER', oStruA63, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

	// Faço o relaciomaneto entre o bomba e bicos
	oModel:SetRelation('A63DETAIL', { { 'A63_FILIAL', 'xFilial( "A63" )' } , { 'A63_CODBOM', 'A62_CODBOM' } } , A63->(IndexKey(2)))

	// Seto a propriedade de não obrigatoriedade do preenchimento do grid
	oModel:GetModel('A63DETAIL'):SetOptional(.T.)

	// Preencho a descrição da entidade
	oModel:GetModel('A63DETAIL'):SetDescription(STR0003)

	// Não permitir duplicar o código do bico
	oModel:GetModel('A63DETAIL'):SetUniqueLine( {'A63_CODBIC','A63_STATUS','A63_DTDES'} )

	///////////////////////////  ITENS - LACRES  //////////////////////////////

	// Crio o grid de Lacres
	oModel:AddGrid('A64DETAIL', 'A62MASTER', oStruA64, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

	// Faço o relaciomaneto entre o bicos e o Lacres
	oModel:SetRelation('A64DETAIL', { { 'A64_FILIAL', 'xFilial( "A64" )' } , { 'A64_CODBOM', 'A62_CODBOM' } } , A64->(IndexKey(3)))

	// Seto a propriedade de não obrigatoriedade do preenchimento do grid
	oModel:GetModel('A64DETAIL'):SetOptional(.T.)

	// Preencho a descrição da entidade
	oModel:GetModel('A64DETAIL'):SetDescription(STR0004)

	// Não permitir duplicar o código do lacre
	oModel:GetModel('A64DETAIL'):SetUniqueLine( {'A64_NROLAC'} )


Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de visão

@type function
@version 1.0  
@author Rafael Brito
@since 01/07/2022
/*/
Static Function ViewDef()

	Local oStruA62 	:= FWFormStruct(2,'A62')
	Local oStruA63 	:= FWFormStruct(2,'A63')
	Local oStruA64 	:= FWFormStruct(2,'A64')
	Local oModel   	:= FWLoadModel('GPCA003')
	Local oView

	// Remove campos a estrutura
	oStruA63:RemoveField('A63_CODBOM')
	oStruA64:RemoveField('A64_CODBOM')

	oStruA63:AddField('STATUS',"01",'','',NIL,'GET','@BMP',,'',.F.,'','',{},1,'BR_VERDE',.T.)

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_A62'	, oStruA62, 'A62MASTER') // cria o cabeçalho - Bombas
	oView:AddGrid('VIEW_A63'	, oStruA63, 'A63DETAIL') // Cria o grid - Bicos
	oView:AddGrid('VIEW_A64'	, oStruA64, 'A64DETAIL') // Cria o grid - Lacres

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_CAB", 30)
	oView:CreateHorizontalBox("PAINEL_DET", 70)

	// Cria Folder na view
	oView:CreateFolder("PASTAS","PAINEL_DET")

	// Cria pastas nas folders
	oView:AddSheet("PASTAS","ABA01",STR0003)
	oView:AddSheet("PASTAS","ABA02",STR0004)

	oView:CreateHorizontalBox("PAINEL_BICOS",100,,,"PASTAS","ABA01")
	oView:CreateHorizontalBox("PAINEL_LACRES",100,,,"PASTAS","ABA02")

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_A62','PAINEL_CAB')
	oView:SetOwnerView("VIEW_A63","PAINEL_BICOS")
	oView:SetOwnerView("VIEW_A64","PAINEL_LACRES")

	// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_A62",STR0002)
	oView:EnableTitleView("VIEW_A63",STR0003)
	oView:EnableTitleView("VIEW_A64",STR0004)

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)


/*/{Protheus.doc} GCP009AVA
Funcao para validar dados informado
- chamado na validacao de campo.

@author pablo
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function GPCA009AVA()

	Local oModel     	:= FWModelActive()
	Local oModelA63  	:= oModel:GetModel( 'A63DETAIL' )
	Local lRet			:= .T.

	if (ReadVar() == "M->A63_STATUS") .or. (ReadVar() == "M->A63_DTDES")

		cStatus := iif( oModelA63:GetValue("A63_STATUS")<>"2" .and. (Empty(DtoS(oModelA63:GetValue("A63_DTDES"))) .or. DtoS(oModelA63:GetValue("A63_DTDES"))>=DtoS(Date())), "BR_VERDE", "BR_VERMELHO" )
		oModelA63:LoadValue('STATUS', cStatus)

		if ReadVar() == "M->A63_STATUS"
			//preencho a data desativação automaticamente
			if cStatus == "BR_VERMELHO"
				oModelA63:LoadValue("A63_DTDES", Date())
			else
				oModelA63:LoadValue("A63_DTDES", STOD(""))
			endif
		endif

	EndIf

Return lRet

Function GCPAV003A(cString)

	Local lRet		 := .T.
	Local nTamCodSLG := TamSX3("LG_CODIGO")[1] //retorna o tamanho do campo codigo estação (LG_CODIGO)

	While !Empty(cString)

		If Len(AllTrim(cString)) > nTamCodSLG .And. SubStr(cString,nTamCodSLG+1,1)  <> '/'
			Alert(STR0014)
			lRet := .F.
		Else
			lRet := .T.
		EndIf

		cString := SubStr(cString,nTamCodSLG+2,Len(cString))

	EndDo

Return (lRet)


/*/{Protheus.doc} TPDVP21B
Tela de seleção de estações que o registro será bloqueado.

@author Totvs GO
@since 05/09/2019
@version 1.0

@return ${return}, ${return_description}

@type function
@obs Programa chamado pelo click no campo
/*/
Function GCPAV003B()

	Local aInf			:= {}
	Local aDados		:= {}

	Local aCampos		:= {{"OK","C",002,0},{"COL1","C",012,0},{"COL2","C",015,0},{"COL3","C",012,0},{"COL4","C",012,0}}
	Local aCampos2		:= {{"OK","","",""},{"COL1","","Estação",""},{"COL2","","Nome",""},{"COL3","","Nr. PDV",""},{"COL4","","Série",""}}

	Local nPosIt		:= 0
	Local nI

	Private cRet		:= ""
	Private oTempTable as object

	Private oMark
	Private cMarca	 	:= "mk"
	Private lImpFechar	:= .F.

	Private oSay1, oSay2, oSay3, oSay4
	Private oTexto
	Private cTexto		:= Space(TamSX3("LG_NOME")[1])
	Private nContSel	:= 0

	Private cBkpInf 	:= ""

	Private oDlgEstacao

	Private aBlqFil		:= {}

	If Alltrim(ReadVar()) == "M->A63_HOST"

		aInf := IIF(!Empty(M->A63_HOST),StrTokArr(AllTrim(M->A63_HOST),"/"),{})
		cBkpInf := M->A63_HOST

		dbSelectArea("SLG")
		SLG->(dbSetOrder(1)) //LG_FILIAL+LG_CODIGO
		SLG->(dbGoTop())
		SLG->(dbSeek(xFilial("SLG")))

		While SLG->(!EOF()) .and. SLG->LG_FILIAL = xFilial("SLG")
			aAdd(aDados,{LG_CODIGO,LG_NOME,LG_PDV,LG_SERIE})
			SLG->(dbSkip())
		EndDo

		//cria a tabela temporaria
		oTempTable := FWTemporaryTable():New("TRBAUX")
		oTempTable:SetFields(aCampos)
		oTempTable:Create()

		DbSelectArea("TRBAUX")

		If Len(aDados) > 0
			For nI := 1 to Len(aDados)
				TRBAUX->(RecLock("TRBAUX",.T.))
				If Len(aInf) > 0
					nPosIt := aScan(aInf,{|x| AllTrim(x) == AllTrim(aDados[nI][1])})
					If nPosIt > 0
						TRBAUX->OK := "mk"
						nContSel++
					Else
						TRBAUX->OK := "  "
					Endif
				Else
					TRBAUX->OK := "  "
				Endif
				TRBAUX->COL1 := aDados[nI][1]
				TRBAUX->COL2 := aDados[nI][2]
				TRBAUX->COL3 := aDados[nI][3]
				TRBAUX->COL4 := aDados[nI][4]
				TRBAUX->(MsUnlock())
			Next
		Else
			TRBAUX->(RecLock("TRBAUX",.T.))
			TRBAUX->OK		:= "  "
			TRBAUX->COL1	:= Space(TamSX3("LG_CODIGO")[1])
			TRBAUX->COL2 	:= Space(TamSX3("LG_NOME")[1])
			TRBAUX->COL3 	:= Space(TamSX3("LG_PDV")[1])
			TRBAUX->COL4 	:= Space(TamSX3("LG_SERIE")[1])
			TRBAUX->(MsUnlock())
		Endif

		TRBAUX->(DbGoTop())



		DEFINE MSDIALOG oDlgEstacao TITLE STR0015 From 000,000 TO 450,700 COLORS 0, 16777215 PIXEL

		@ 005, 005 SAY oSay1 PROMPT STR0016 SIZE 060, 007 OF oDlgEstacao COLORS 0, 16777215 PIXEL
		@ 004, 050 MSGET oTexto VAR cTexto SIZE 200, 010 OF oDlgEstacao COLORS 0, 16777215 PIXEL Picture "@!"
		@ 005, 272 BUTTON oButton1 PROMPT STR0017 SIZE 040, 010 OF oDlgEstacao ACTION FindText(cTexto) PIXEL

		//Browse
		oMark := MsSelect():New("TRBAUX","OK","",aCampos2,,@cMarca,{020,005,190,348})
		oMark:bMark 				:= {|| MarcaIt("TRBAUX",@nContSel,@oSay3)}
		oMark:oBrowse:LCANALLMARK 	:= .T.
		oMark:oBrowse:LHASMARK    	:= .T.
		oMark:oBrowse:bAllMark 		:= {|| MarcaT("TRBAUX",@nContSel,@oSay3)}

		@ 193, 005 SAY oSay2 PROMPT STR0018 SIZE 200, 007 OF oDlgEstacao COLORS 0, 16777215 PIXEL
		@ 193, 090 SAY oSay3 PROMPT cValToChar(nContSel) SIZE 040, 007 OF oDlgEstacao COLORS 0, 16777215 PIXEL

		//Linha horizontal
		@ 203, 005 SAY oSay4 PROMPT Repl("_",342) SIZE 342, 007 OF oDlgEstacao COLORS CLR_GRAY, 16777215 PIXEL

		@ 213, 272 BUTTON oButton2 PROMPT STR0019 SIZE 040, 010 OF oDlgEstacao ACTION Conf002() PIXEL
		@ 213, 317 BUTTON oButton3 PROMPT STR0020 SIZE 030, 010 OF oDlgEstacao ACTION Fech002() PIXEL

		ACTIVATE MSDIALOG oDlgEstacao CENTERED VALID lImpFechar //impede o usuario fechar a janela atraves do [X]

	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FindText
Localiza estação...
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function FindText(_cTexto)

	If !Empty(_cTexto)
		TRBAUX->(dbSkip())

		While TRBAUX->(!EOF())
			If AllTrim(_cTexto) $ TRBAUX->COL2
				Exit
			Endif

			TRBAUX->(dbSkip())
		EndDo
	Else
		TRBAUX->(dbGoTop())
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Conf002
Confirma a seleção
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function Conf002()

	Local lAux 	:= .F.
	Local nAux	:= 0

	TRBAUX->(dbGoTop())

	If Empty(ReadVar())
		__READVAR := "M->A63_HOST"
	EndIf

	M->A63_HOST := PadR("",TamSx3("A63_HOST")[1])

	While TRBAUX->(!EOF())
		If TRBAUX->OK == "mk"
			If !lAux
				M->A63_HOST := AllTrim(TRBAUX->COL1)
				lAux := .T.
			Else
				M->A63_HOST += "/" + AllTrim(TRBAUX->COL1)
			Endif
			nAux += Len(TRBAUX->COL1)
		Endif

		TRBAUX->(dbSkip())
	EndDo

	M->A63_HOST := PadR(M->A63_HOST,TamSx3("A63_HOST")[1])

	Fech002()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Fech002
Fecha a tela de seleção
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function Fech002()

	lImpFechar := .T.

	If Select("TRBAUX") > 0
		TRBAUX->(DbCloseArea())
	Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apagando arquivo temporario                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oTempTable:Delete()

	oDlgEstacao:End()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaIt
SubFunção da U_TPDVP21B - MarcaIt
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function MarcaIt(cTabAux,nContSel,oSay3)

	If (cTabAux)->OK == "mk"
		nContSel++
	Else
		--nContSel
	Endif

	oSay3:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaT
SubFunção da gpca003 - MarcaT
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function MarcaT(cTabAux,nContSel,oSay3)

	Local lMarca 	:= .F.
	Local lNMARCA 	:= .F.

	nContSel := 0

	(cTabAux)->(dbGoTop())

	While (cTabAux)->(!EOF())

		If (cTabAux)->OK == "mk" .And. !lMarca
			RecLock(cTabAux,.F.)
			(cTabAux)->OK := "  "
			(cTabAux)->(MsUnlock())
			lNMarca := .T.
		Else
			If !lNMarca
				RecLock(cTabAux,.F.)
				(cTabAux)->OK := "mk"
				(cTabAux)->(MsUnlock())
				nContSel++
				lMarca := .T.
			Endif
		Endif
		(cTabAux)->(dbSkip())
	EndDo

	(cTabAux)->(dbGoTop())

	oSay3:Refresh()

Return
