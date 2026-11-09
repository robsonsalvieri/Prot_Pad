#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE "OFIA534.CH"

Function OFIA534()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) // "Programa Promocional"
	oBrowse:SetAlias('VBV')
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/


Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'OA5340015_ImportaArquivo()' OPERATION 3 ACCESS 0 // Importar
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.OFIA534' OPERATION 1 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/


Static Function ModelDef()

	Local oModel
	Local oStrVBV := FWFormStruct(1, "VBV")
	Local oStrVBX := FWFormStruct(1, "VBX")

	oModel := MPFormModel():New('OFIA534',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oStrVBX:SetProperty( 'VBX_CODVBV' , MODEL_FIELD_INIT , { || FWFldGet('VBV_CODIGO') } )

	oStrVBX:AddTrigger( "VBX_CODFAB", "VBX_GRUITE", {|| .T.}, { |oModel| Posicione("SB1",13,xFilial("SB1")+FWFldGet('VBX_CODFAB'),"B1_GRUPO") } )
	oStrVBX:AddTrigger( "VBX_CODFAB", "VBX_CODITE", {|| .T.}, { |oModel| Posicione("SB1",13,xFilial("SB1")+FWFldGet('VBX_CODFAB'),"B1_CODITE") } )

	oModel:AddFields('VBVMASTER',/*cOwner*/ 	, oStrVBV)
	oModel:AddGrid('VBXDETAIL'	,'VBVMASTER'	, oStrVBX, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )

	oModel:SetRelation( 'VBXDETAIL', { { 'VBX_FILIAL', 'xFilial( "VBX" )' }, { 'VBX_CODVBV', 'VBV_CODIGO' } }, VBX->( IndexKey( 1 ) ) )

	oModel:SetPrimaryKey( { "VBV_FILIAL", "VBV_CODIGO" } )
	oModel:SetDescription( STR0001 ) // "Programa Promocional"
	oModel:GetModel('VBVMASTER'):SetDescription(STR0004) // "Informações do Programa Promocional"
	oModel:GetModel('VBXDETAIL'):SetDescription(STR0005) // "Informações dos Itens do Programa Promocional"

Return oModel

/*/{Protheus.doc} ViewDef()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/


Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVBV:= FWFormStruct(2, "VBV")
	Local oStrVBX:= FWFormStruct(2, "VBX")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVBV', 45)
	oView:AddField('VIEW_VBV', oStrVBV, 'VBVMASTER')
	oView:EnableTitleView('VIEW_VBV', STR0001 ) // "Programa Promocional"
	oView:SetOwnerView('VIEW_VBV','BOXVBV')

	oView:CreateHorizontalBox( 'BOXVBX', 55)
	oView:AddGrid("VIEW_VBX", oStrVBX, 'VBXDETAIL')
	oView:SetOwnerView('VIEW_VBX','BOXVBX')

Return oView


/*/{Protheus.doc} OA5340015_ImportaArquivo()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/


Function OA5340015_ImportaArquivo()

Local aParamBox  := {}
Local aRet       := {}
Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE

Local oViewGer  := FWLoadView("OFIA534")
Local oModelGer := FWLoadModel("OFIA534")

Private oConfig

Private aComboCab := {}
Private aComboIte := {}
Private aDadosCab := {}
Private aDadosIte := {}

aAdd(aParamBox,{6,STR0006,Space(200),"","","",80,	.T.,"(*.csv) |*.csv",,nOpcGetFil}) // "Arquivo:"

If !(ParamBox(aParamBox,"",@aRet,,,,,,,,.f.,.t.))
	Return .f.
EndIf

If OA5340095_LeituraArquivo(aRet[1])

	cPlano := aDadosCab[1] // Nome do Programa Promocional

	VBV->(DbSetOrder(2))
	If VBV->(DbSeek(xFilial("VBV") + cPlano ))
		If MsgYesNo(STR0007) // "Programa já cadastrado. Deseja seguir com a importação?"
			RecLock("VBV", .f.)
				VBV->VBV_ATIVO := "0" // Não
			MsUnLock()
		EndIf
	EndIf

	oConfig := OFJDConfig():New("OFIA534_"+cPlano)

	oModelGer:SetOperation(MODEL_OPERATION_INSERT)
	oModelGer:Activate()

	OA5340105_PreencheCabec(oModelGer)

	OA5340115_PreencheItens(oModelGer)

	CursorArrow()

	oViewGer:addUserButton(STR0008,'', { |oView| OA5340035_RelacionaCampos(oView,oModelGer) },,,, .t. )	// "Relacionar Campos"

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0001 ) // "Programa Promocional"
	oExecView:setModel(oModelGer)
	oExecView:setView(oViewGer)
	oExecView:setCancel( { || .T. } )
	oExecView:openView(.T.)

EndIf

Return

/*/{Protheus.doc} OA5340025_LevantaData()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Function OA5340025_LevantaData(uAuxValor)

Local cAno := ""
Local cMes := ""
Local cDia := ""

If !Empty(uAuxValor)

	cAno := Right(uAuxValor,4)
	cMes := UPPER( Right( Left( uAuxValor , Len(uAuxValor) - Len(cAno) ),3) )
	cDia := PADL(Left(uAuxValor, Len(uAuxValor) - (Len(cMes) + Len(cAno)) ),2,"0")

	Do Case
		Case cMes == "JAN" ; cMes := "01"
		Case cMes == "FEB" ; cMes := "02"
		Case cMes == "MAR" ; cMes := "03"
		Case cMes == "APR" ; cMes := "04"
		Case cMes == "MAY" ; cMes := "05"
		Case cMes == "JUN" ; cMes := "06"
		Case cMes == "JUL" ; cMes := "07"
		Case cMes == "AUG" ; cMes := "08"
		Case cMes == "SEP" ; cMes := "09"
		Case cMes == "OCT" ; cMes := "10"
		Case cMes == "NOV" ; cMes := "11"
		Otherwise ; cMes := "12"
	End Case
	uAuxValor := CtoD( cDia + "/" + cMes + "/" + cAno )
EndIf

Return uAuxValor

/*/{Protheus.doc} OA5340035_RelacionaCampos

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340035_RelacionaCampos(oView,oModelGer)

	Local oModelRel 
	Local oViewRel

	Local oStruCab
	Local oStruIte
	Local oStruViewCb
	Local oStruViewIt

	Local bLoadInfCb := {|oModel| OA5340065_GetInformacaoCabec(oModel)}
	Local bLoadItens := {|oModel| OA5340075_GetInformacaoItens(oModel)}

	Private cCpoRemCab := "VBV_FILIAL|VBV_CODIGO|VBV_DPERFI|VBV_ATIVO|"
	Private cCpoRemIte := "VBX_FILIAL|VBX_CODVBV|VBX_GRUITE|VBX_CODITE|VBX_DESITE|"

	oModCab  := OA5340045_ConfiguracaoCampoCabec()
	oModIte  := OA5340055_ConfiguracaoCampoItem()

	oStruCab  := oModCab:GetModel()
	oStruIte  := oModIte:GetModel()

	oStruViewCb  := oModCab:GetView()
	oStruViewIt  := oModIte:GetView()

	// Model
	oStruCab:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .f.)
	oStruCab:SetProperty( 'CVBV_DESCRI' , MODEL_FIELD_OBRIGAT, .t.)
	oStruCab:SetProperty( 'CVBV_PROGRM' , MODEL_FIELD_OBRIGAT, .t.)
	oStruCab:SetProperty( 'CVBV_DPERIN' , MODEL_FIELD_OBRIGAT, .t.)
	oStruCab:SetProperty( 'CVBV_MOEDA'  , MODEL_FIELD_OBRIGAT, .t.)
	oStruCab:SetProperty( 'CVBV_PERDES' , MODEL_FIELD_OBRIGAT, .t.)
	oStruCab:SetProperty( 'CVBV_ORDVAL' , MODEL_FIELD_OBRIGAT, .t.)

	oStruIte:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .f.)
	oStruIte:SetProperty( 'CVBX_CODFAB' , MODEL_FIELD_OBRIGAT, .t.)

	oModelRel := MPFormModel():New( 'RELCPO', /* bPre */, /*bPost*/ , { |oModel| OA5340085_Gravar(oModel,oView:GetModel("VBVMASTER")) } /* bCommit */ , { || .T. }/* bCancel */ )

	oModelRel:AddFields('RELACAOCPOCAB', /* cOwner */ , oStruCab  , /* <bPre> */ , /* <bPost> */ , bLoadInfCb /* <bLoad> */ )
	oModelRel:GetModel('RELACAOCPOCAB'  ):SetDescription( STR0009 )	// "Campos do Cabeçalho do Programa Promocional"
	
	oModelRel:AddFields('RELACAOCPOITE' ,'RELACAOCPOCAB' , oStruIte , /* <bPre >*/ , /* <bPost > */, bLoadItens /* <bLoad> */ )
	oModelRel:GetModel('RELACAOCPOITE' ):SetDescription( STR0010 )	// "Campos dos Itens do Programa Promocional"

	oModelRel:SetDescription( STR0011 ) // "Relaciona Campos - Programa Promocional"

	oModelRel:SetPrimaryKey({})

	// View
	oViewRel := FWFormView():New()
	oViewRel:SetModel(oModelRel)

	oStruViewCb:RemoveField("CVBV_FILIAL")
	oStruViewCb:RemoveField("CVBV_CODIGO")
	oStruViewCb:RemoveField("CVBV_DPERFI")

	oStruViewIt:RemoveField("CVBX_FILIAL")
	oStruViewIt:RemoveField("CVBX_CODVBV")
	oStruViewIt:RemoveField("CVBX_GRUITE")
	oStruViewIt:RemoveField("CVBX_CODITE")
	oStruViewIt:RemoveField("CVBX_DESITE")

	oViewRel:CreateHorizontalBox( 'BOX_CONFG_CAB' , 50)
	oViewRel:AddField('VIEW_CONFG_CAB', oStruViewCb, 'RELACAOCPOCAB')
	oViewRel:SetOwnerView('VIEW_CONFG_CAB','BOX_CONFG_CAB')
	oViewRel:EnableTitleView('VIEW_CONFG_CAB', STR0009 ) // "Campos do Cabeçalho do Programa Promocional"

	oViewRel:CreateHorizontalBox( 'BOX_CONFG_ITEM' , 50)
	oViewRel:AddField('VIEW_CONFG_ITE' , oStruViewIt , 'RELACAOCPOITE')
	oViewRel:SetOwnerView('VIEW_CONFG_ITE','BOX_CONFG_ITEM')
	oViewRel:EnableTitleView('VIEW_CONFG_ITE', STR0010 ) // "Campos dos Itens do Programa Promocional"

	oViewRel:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oViewRel:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oViewRel:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oViewRel:showUpdateMsg(.f.)
	oViewRel:showInsertMsg(.f.)

	// Execução da view e apresentação da tela
	oViewCfg := FWViewExec():New()
	oViewCfg:setTitle( STR0012 ) // "Relaciona Campos"
	oViewCfg:setModel(oModelRel)
	oViewCfg:setView(oViewRel)
	oViewCfg:setCancel( { || .T. } )
	oViewCfg:setOperation(MODEL_OPERATION_UPDATE)
	oViewCfg:openView(.T.)

	OA5340105_PreencheCabec(oModelGer)

	OA5340115_PreencheItens(oModelGer)

	oView:Refresh()

Return

/*/{Protheus.doc} OA5340045_ConfiguracaoCampoCabec()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340045_ConfiguracaoCampoCabec()

	Local oRetorno := OFDMSStruct():New()
	Local oStrVBV := FWFormStruct(3, "VBV")
	Local nX := 0

	For nX := 1 to Len(oStrVBV[FORM_STRUCT_TABLE_MODEL])

		cCampo := oStrVBV[ FORM_STRUCT_TABLE_MODEL ][ nX ][ MVC_MODEL_IDFIELD ]
		IF !(cCampo $ cCpoRemCab) // Se o campo não estiver contido
			oRetorno:AddField( { ;
				{ "cTitulo"  , RetTitle(cCampo) } ,;
				{ "cTooltip" , RetTitle(cCampo) } ,;
				{ "cIdField" , "C"+cCampo } ,;
				{ "cTipo"    , "C" } ,;
				{ "nTamanho" , 2 } ,;
				{ "aComboValues" , aComboCab } ;
			})
		EndIf

	Next

Return oRetorno


/*/{Protheus.doc} OA5340055_ConfiguracaoCampoItem()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340055_ConfiguracaoCampoItem()

	Local oRetorno := OFDMSStruct():New()
	Local oStrVBX := FWFormStruct(3, "VBX")
	Local nX := 0

	For nX := 1 to Len(oStrVBX[FORM_STRUCT_TABLE_MODEL])

		cCampo := oStrVBX[ FORM_STRUCT_TABLE_MODEL ][ nX ][ MVC_MODEL_IDFIELD ]

		IF !(cCampo $ cCpoRemIte) // Se o campo não estiver contido
			oRetorno:AddField( { ;
				{ "cTitulo"  , RetTitle(cCampo) } ,;
				{ "cTooltip" , RetTitle(cCampo) } ,;
				{ "cIdField" , "C"+cCampo } ,;
				{ "cTipo"    , "C" } ,;
				{ "nTamanho" , 2 } ,;
				{ "aComboValues" , aComboIte } ;
			})
		EndIf

	Next

Return oRetorno

/*/{Protheus.doc} OA5340065_GetInformacaoCabec()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340065_GetInformacaoCabec(oModel)

	Local aDados := {}
	Local oStrVBV := FWFormStruct(3, "VBV")
	Local nX := 0

	For nX := 1 to Len(oStrVBV[FORM_STRUCT_TABLE_MODEL])

		cCampo := oStrVBV[ FORM_STRUCT_TABLE_MODEL ][ nX ][ MVC_MODEL_IDFIELD ]

		IF !(cCampo $ cCpoRemCab) // Se o campo não estiver contido
			AAdd(aDados, oConfig:GetValue("C"+cCampo, "" ))
		EndIf

	Next

Return { aDados, 0 }


/*/{Protheus.doc} OA5340075_GetInformacaoItens()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340075_GetInformacaoItens(oModel)

	Local aDados := {}
	Local oStrVBX := FWFormStruct(3, "VBX")
	Local nX := 0

	For nX := 1 to Len(oStrVBX[FORM_STRUCT_TABLE_MODEL])

		cCampo := oStrVBX[ FORM_STRUCT_TABLE_MODEL ][ nX ][ MVC_MODEL_IDFIELD ]

		IF !(cCampo $ cCpoRemIte) // Se o campo não estiver contido
			AAdd(aDados, oConfig:GetValue("C"+cCampo, "" ))
		EndIf

	Next

Return { aDados, 0 }

/*/{Protheus.doc} OA5340085_Gravar()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340085_Gravar(oModel,oModAtuVBV)

	Local jJson := JsonObject():New()
	Local nI := 0

	Local oModVBV := oModel:GetModel('RELACAOCPOCAB')
	Local oModVBX := oModel:GetModel('RELACAOCPOITE')

	Local oStructCab := oModVBV:GetStruct()
	Local aFieldsCab := oStructCab:GetFields()

	Local oStructIte := oModVBX:GetStruct()
	Local aFieldsIte := oStructIte:GetFields()

	For nI := 1 to Len(aFieldsCab)

		cCampo := aFieldsCab[nI,3]

		jJson[cCampo] := oModVBV:GetValue(cCampo)

	Next

	For nI := 1 to Len(aFieldsIte)

		cCampo := aFieldsIte[nI,3]

		jJson[cCampo] := oModVBX:GetValue(cCampo)

	Next

	oConfig:Save(jJson)

Return .t.


/*/{Protheus.doc} OA5340095_LeituraArquivo()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340095_LeituraArquivo(cArquivo)

	Local nLinha := 0
	Local lCond    := .F. // flag se entrou na tabela de condições
	Local aHeaderCab  := {}  // cabeçalho da tabela de condições

	Local aCab        := {}
	Local aHeaderItem    := {}

	Local lRetorno := .f.
	Local nX       := 0

	oFile := FWFileReader():New(cArquivo)

	if oFile:Open()

		while oFile:hasLine()

			nLinha++
			cLinha := Alltrim(oFile:getLine())

			If nLinha == 8 // Linha que contém as colunas que vão compor o cabeçalho
				aHeaderCab := strtokarr2(cLinha, ",")
				lCond   := .T.
				Loop
			ElseIf nLinha == 11 // Linha que contém as colunas que vão compor o item
				aHeaderItem := strtokarr2(cLinha, ",")
				lCond   := .T.
				Loop
			EndIf

			If lCond

				aCols := strtokarr2(cLinha,",",.t.)

				For nX := 1 To Len(aHeaderCab)
					If !Empty(aHeaderCab[nX])
						aAdd(aCab, (AllTrim(aHeaderCab[nX])) )
						aAdd(aDadosCab, Alltrim(aCols[nX]) )
					EndIf
				Next

				If Len(aHeaderCab) > 0
					aHeaderCab := {}
				EndIf

				If Len(aHeaderItem) > 0
					aAdd(aDadosIte, aClone(aCols) )
				EndIf

			Else

				// Parte dos metadados
				aCols := strtokarr2(cLinha, ",")

				For nX := 1 To Len(aCols) Step 2
					If nX+1 <= Len(aCols) .and. !Empty(aCols[nX])

						aAdd(aCab,(AllTrim(aCols[nX])) )

						aAdd(aDadosCab, Alltrim(aCols[nX+1]))

					EndIf
				Next

			EndIf

		end do

		aAdd(aComboCab,"")
		For nX := 1 To Len(aCab)
			aAdd(aComboCab, cValToChar(nX) + "=" + Alltrim(aCab[nX]) )
		Next
		
		aAdd(aComboIte,"")
		For nX := 1 To Len(aHeaderItem)
			aAdd(aComboIte, cValToChar(nX) + "=" + Alltrim(aHeaderItem[nX]) )
		Next

		lRetorno := .t.

	EndIf

Return lRetorno


/*/{Protheus.doc} OA5340105_PreencheCabec()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340105_PreencheCabec(oModelGer)

	Local oStrVBV  := FWFormStruct(3, "VBV")
	Local cCampo   := ""
	Local cId      := ""
	Local xValue   := ""
	Local nPosCont := 0
	Local cConteud := ""
	Local nX       := 0
	Local cDtIni   := ""
	Local cDtFim   := ""

	oModelCab := oModelGer:GetModel("VBVMASTER")
	
	oModelCab:GetStruct():SetProperty( 'VBV_DESCRI' , MODEL_FIELD_OBRIGAT, .t.)
	oModelCab:GetStruct():SetProperty( 'VBV_PROGRM' , MODEL_FIELD_OBRIGAT, .t.)
	oModelCab:GetStruct():SetProperty( 'VBV_DPERIN' , MODEL_FIELD_OBRIGAT, .t.)
	oModelCab:GetStruct():SetProperty( 'VBV_DPERFI' , MODEL_FIELD_OBRIGAT, .t.)
	oModelCab:GetStruct():SetProperty( 'VBV_MOEDA'  , MODEL_FIELD_OBRIGAT, .t.)
	oModelCab:GetStruct():SetProperty( 'VBV_PERDES' , MODEL_FIELD_OBRIGAT, .t.)

	For nX := 1 to Len(oStrVBV[FORM_STRUCT_TABLE_MODEL])

		cCampo := oStrVBV[ FORM_STRUCT_TABLE_MODEL ][ nX ][ MVC_MODEL_IDFIELD ]
		cId    := "C"+cCampo

		xValue := oConfig:GetValue( cId, Space(2) )

		If Empty(xValue)
			Loop
		EndIf

		nPosCont := Val(xValue)

		cConteud := aDadosCab[nPosCont]

		If cId == "CVBV_DPERIN"

			cDtIni := Alltrim(Left(cConteud,At("-",cConteud)-1))
			cDtFim := Alltrim(StrTran(Right(cConteud,At("-",cConteud)),"-",""))

			cConteud := OA5340025_LevantaData(cDtIni)

			cDtFim := OA5340025_LevantaData(cDtFim)

			oModelCab:LoadValue("VBV_DPERFI",cDtFim)
		
		ElseIf cId == "CVBV_PERDES"

			cConteud := StrTran(cConteud,"!","")
			cConteud := StrTran(cConteud,"%","")

			cConteud := Val(Alltrim(cConteud))

		ElseIf cId == "CVBV_ORDVAL"

			cConteud := Val(Left(cConteud,At("-",cConteud)-1))

		Else

			cTpCpo := GeTSX3Cache( cCampo, "X3_TIPO")

			If cTpCpo == "N"
				cConteud := Val(cConteud)
			EndIf

		EndIf

		oModelCab:LoadValue(cCampo, cConteud)

	Next

Return

/*/{Protheus.doc} OA5340115_PreencheItens()

	

@author Renato Vinicius
@since 12/09/2025
@version undefined
@type function
/*/

Static Function OA5340115_PreencheItens(oModelGer)

	Local oStrVBX := FWFormStruct(3, "VBX")
	Local cCampo   := ""
	Local cId      := ""
	Local xValue   := ""
	Local nPosCont := 0
	Local nX       := 0
	Local nJ       := 0
	Local lAddLine := .t.

	oModelDet := oModelGer:GetModel("VBXDETAIL")

	oModelDet:SetNoDeleteLine()
	oModelDet:SetNoUpdateLine()

	If oModelDet:Length() > 1
		lAddLine := .f.
	EndIf

	If oModelDet:GetMaxLines() < LEN(aDadosIte)
		oModelDet:SetMaxLine(LEN(aDadosIte))
	EndIf

	For nX := 1 to Len(oStrVBX[FORM_STRUCT_TABLE_MODEL])

		cCampo := oStrVBX[ FORM_STRUCT_TABLE_MODEL ][ nX ][ MVC_MODEL_IDFIELD ]
		cId    := "C"+cCampo

		xValue := oConfig:GetValue( cId, Space(2) )

		If Empty(xValue)
			Loop
		EndIf

		oModelDet:SetNoInsertLine(.F.)
		oModelDet:SetNoUpdateLine(.f.)

		nPosCont := Val(xValue)

		For nJ := 1 to Len(aDadosIte)

			If lAddLine
				oModelDet:AddLine()
				oModelDet:SetValue( "VBX_CODVBV", oModelGer:GetValue("VBVMASTER","VBV_CODIGO") )
			Else
				oModelDet:goLine(nJ)
			EndIf

			cTpCpo := GeTSX3Cache( cCampo, "X3_TIPO")
			cConteud := aDadosIte[nJ,nPosCont]
			If cTpCpo == "N"
				cConteud := Val(cConteud)
			EndIf
			oModelDet:SetValue( cCampo, cConteud )

		Next

		oModelDet:SetNoInsertLine()
		oModelDet:SetNoUpdateLine()

		lAddLine := .f.

	Next

	If oModelDet:Length() > 1
		oModelDet:GoLine(1)
	EndIf

Return