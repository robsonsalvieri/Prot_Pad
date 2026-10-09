#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA906B.CH"

Static cAliasGIC := ''

/*/{Protheus.doc} GTPA906
(long_description) Tela de processamento Revogação de Bilhetes Importados da RJIntegra
@type  Function
@author José Carlos
@since 08/03/2026
@version 1.
0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA906B()
	Local cPerg := 'GTPA906B'

	If Pergunte(cPerg,.T.)
		FwExecView(STR0001,"VIEWDEF.GTPA906B",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Revogação de Bilhetes Importados"
	EndIf 
Return 

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruCab	:= FwFormModelStruct():New() 
	Local oStruGrd  := FwFormModelStruct():New()
	Local bLoad		:= {|oModel| GA906BLoad(oModel)}
	Local bCommit   := {|oModel| GA906BCommit(oModel)}
	Local bPosValid := {|oModel| PosValid(oModel)}
	Local bInitData	:= {|oModel| GA906BPesq(oModel)}
	Local bVldActive:= {|oModel| VldActivate(oModel)}

	oModel := MPFormModel():New("GTPA906B",/*bPreValidacao*/, bPosValid/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

	SetMdlStruct(oStruCab, oStruGrd)

	oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
	oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

	//Desativando a exclusão de linhas
	oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

	oModel:SetDescription(STR0002)	                	//'Seleção'
	oModel:GetModel("HEADER"):SetDescription(STR0003)  	//"Filtro"
	oModel:GetModel("GRID"):SetDescription(STR0004)  	//"Bilhetes"
	oModel:GetModel("GRID"):SetMaxLine(99999)
	oModel:SetPrimaryKey({})
	oModel:GetModel("GRID"):SetMaxLine(99999)	

	oModel:GetModel('GRID'):SetNoDeleteLine(.T.)
	oModel:SetActivate(bInitData)
	oModel:SetVldActivate(bVldActive)
	oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
	Local oView		:= nil
	Local oModel	:= FwLoadModel("GTPA906B")
	Local oStruCab	:= FwFormViewStruct():New()
	Local oStruGrd	:= FwFormViewStruct():New()

	// Cria o objeto de View
	oView := FWFormView():New()

	SetViewStru(oStruCab, oStruGrd)

	// Define qual o Modelo de dados a ser utilizado
	oView:SetModel(oModel)

	oView:SetDescription(STR0004)	//"Bilhetes"

	oView:AddField('VIEW_HEADER', oStruCab, 'HEADER')
	oView:AddGrid('VIEW_GRID'	, oStruGrd, 'GRID')

	oView:CreateHorizontalBox('HEADER'	, 40)
	oView:CreateHorizontalBox('GRID'	, 60)

	oView:SetOwnerView('VIEW_HEADER','HEADER')
	oView:SetOwnerView('VIEW_GRID'	,'GRID')

	oView:EnableTitleView("VIEW_HEADER" , STR0003)	    //"Filtro"
	oView:EnableTitleView("VIEW_GRID"   , STR0004)   //"Bilhetes"

	oView:AddIncrementalField('VIEW_GRID','SEQ')

	oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
	oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

	oView:AddOtherObject('ITEM_BILHETES', {|oView| MarkDesMark(oView)} ) // botoes com as acoes
	oView:SetOwnerView("ITEM_BILHETES",'GRID')

	oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

	oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStruct
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStruct(oStruCab, oStruGrd)
	Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

	If ValType(oStruCab) == "O"

        oStruCab:AddField(STR0005  ,STR0005   ,"AGENCIAINI"	,"C", TamSx3('GI6_CODIGO')[1], 0,bFldVld,{|| .F.},{},.F.,{||MV_PAR01},.F.,.F.,.T.) //"Agência de"
        oStruCab:AddField(STR0006  ,STR0006   ,"DAGENCIAINI","C", TamSx3('GI6_DESCRI')[1], 0,{||.T.},{|| .F.},{},.F.,{||GetAdvFval("GI6","GI6_DESCRI",xFilial('GI6')+MV_PAR01,1)},.F.,.F.,.T.) //"Descr. Agência de"

        oStruCab:AddField(STR0007  ,STR0007   ,"AGENCIAFIM"	,"C", TamSx3('GI6_CODIGO')[1], 0,bFldVld,{|| .F.},{},.F.,{||MV_PAR02},.F.,.F.,.T.) //"Agência até"
        oStruCab:AddField(STR0008  ,STR0008   ,"DAGENCIAFIM","C", TamSx3('GI6_DESCRI')[1], 0,{||.T.},{|| .F.},{},.F.,{||GetAdvFval("GI6","GI6_DESCRI",xFilial('GI6')+MV_PAR02,1)},.F.,.F.,.T.) //"Descr. Agência até"
        
        oStruCab:AddField(STR0009  ,STR0009   ,"DATAINI" 	,"D", 8, 0, {|| .T.},{|| .F.},{},.F.,{||MV_PAR03},.F.,.F.,.T.)   //"Data De"
		oStruCab:AddField(STR0010  ,STR0010   ,"DATAFIM"    ,"D", 8, 0, {|| .T.},{|| .F.},{},.F.,{||MV_PAR04},.F.,.F.,.T.)    //"Data Até"

	Endif	

	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( STR0011, ; 	// cTitle 	// 'Marcação'
						STR0011, ;		// cToolTip // 'Marcação' 
						'GIC_FLAG', ;	// cIdField
						'L', ; 			// cTipo
						1, ; 			// nTamanho
						0, ; 			// nDecimal
						bFldVld, ;		// bValid
						{||	.T.},; 		// bWhen
						Nil, ;			// aValues
						Nil, ; 			// lObrigat
						Nil, ; 			// bInit
						Nil, ; 			// lKey
						.F., ; 			// lNoUpd
						.T. ) 			// lVirtual	
        cDescric := GetSX3Cache('GIC_DTVEND','X3_DESCRIC')
		oStruGrd:AddField(cDescric ,cDescric    ,"GIC_DTVEND"	,"D",TamSx3('GIC_DTVEND')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 
        cDescric := GetSX3Cache('GIC_AGENCI','X3_DESCRIC')        
		oStruGrd:AddField(cDescric ,cDescric    ,"GIC_AGENCI"	,"C",TamSx3('GIC_AGENCI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	
		cDescric := GetSX3Cache('GI6_DESCRI','X3_DESCRIC')
		oStruGrd:AddField(cDescric ,cDescric    ,"GI6_DESCRI"	,"C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	
		cDescric := STR0012	//'Nota Gerada'
		oStruGrd:AddField(cDescric ,cDescric    ,"NOTAS"		,"N",4,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	
		cDescric := STR0013 //'Lanc.Contábil'
		oStruGrd:AddField(cDescric ,cDescric    ,"CONTABIL"		,"N",4,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	
		cDescric := STR0014	//'Ficha'
		oStruGrd:AddField(cDescric ,cDescric    ,"FICHA"		,"N",4,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruGrd)
    Local cDescric := ""

	If ValType(oStruCab) == "O"

		oStruCab:AddField("AGENCIAINI" 	,"01",STR0005	,STR0005	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 	// "Agência de"
		oStruCab:AddField("DAGENCIAINI"	,"02",STR0006	,STR0006	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 	// "Descr. Agência de"

		oStruCab:AddField("AGENCIAFIM"	,"03",STR0007	,STR0007	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 	// "Agência até"
		oStruCab:AddField("DAGENCIAFIM"	,"04",STR0008	,STR0008	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 	//"Descr. Agência até"

		oStruCab:AddField("DATAINI"	    ,"05",STR0009	,STR0009	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)  	//"Data De"
		oStruCab:AddField("DATAFIM" 	,"06",STR0010	,STR0010	,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 	//"Data Até"

	Endif
	
	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( 'GIC_FLAG', ; 	// cIdField
						'01', ; 			// cOrdem
						STR0011, ; 			// cTitulo // 'Marcação'
						STR0011, ;			// cDescric // 'Marcação' 
						{STR0011,STR0015}, ; // 'Marcação' // 'Marque os itens que deseja Processar'
						'CHECK', ; 			// cType
						'@!', ; 			// cPicture
						Nil, ; 				// nPictVar
						Nil, ; 				// Consulta F3
						.T., ; 				// lCanChange
						'' , ; 				// cFolder
						Nil, ; 				// cGroup
						Nil, ; 				// aComboValues
						Nil, ; 				// nMaxLenCombo
						Nil, ; 				// cIniBrow
						.T., ; 				// lVirtual
						Nil ) 				// cPictVar
        cDescric := GetSX3Cache('GIC_DTVEND', 'X3_DESCRIC')                
		oStruGrd:AddField("GIC_DTVEND"  ,"02",cDescric,cDescric,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	
        cDescric := GetSX3Cache('GIC_AGENCI', 'X3_DESCRIC')
		oStruGrd:AddField("GIC_AGENCI"	,"03",cDescric,cDescric,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 
        cDescric := GetSX3Cache('GI6_DESCRI', 'X3_DESCRIC')
		oStruGrd:AddField("GI6_DESCRI"	,"04",cDescric,cDescric,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 
        cDescric := STR0012	//'Nota gerada'
		oStruGrd:AddField("NOTAS"		,"05",cDescric,cDescric,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 
        cDescric := STR0013	//'Lanc.Contábil'
		oStruGrd:AddField("CONTABIL"	,"06",cDescric,cDescric,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 
        cDescric := STR0014	//'Ficha'
		oStruGrd:AddField("FICHA"		,"07",cDescric,cDescric,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 

	Endif

Return

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
    
    Case cField == "GIC_FLAG"
        If (FWFldGet('NOTAS') + FWFldGet('CONTABIL') + FWFldGet('FICHA')) > 0
            lRet     := .F.
            cMsgErro := STR0016	//"Existe(m) nota(s) gerada(s) e/ou contabilizações e/ou ficha(s), nesta agência e data. Não permitido marcação."
            cMsgSol  := STR0017	//"Estorne a(s) nota(s) e/ou contabilizações e/ou ficha(s)."
        Endif

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} GA906BLoad
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA906BLoad(oModel)
    Local oMdlCab := NIL
    oMdlCab := oModel:GetModel( 'HEADER' )
Return

/*/{Protheus.doc} GA283DPesq
//TODO Descrição auto-gerada.
@author José Carlos
@since 08/03/2026
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA906BPesq(oModel)
Local lRet 			:= .T.
Local oMdlGrid		:= oModel:GetModel():GetModel('GRID')

If (cAliasGIC)->(!EoF())

	oMdlGrid:SetNoInsertLine(.F.)

	While !(cAliasGIC)->(Eof())

		If !(oMdlGrid:SeekLine( {{"GIC_DTVEND",Stod((cAliasGIC)->GIC_DTVEND)},{"GIC_AGENCI",(cAliasGIC)->GIC_AGENCI}}))

			If !(oMdlGrid:IsEmpty())
				oMdlGrid:AddLine()
			Endif

			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_FLAG"})[1]   	,Iif((cAliasGIC)->(NOTAS+CONTABIL+FICHA) == 0,.T.,.F.))
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_DTVEND"})[1] 	,Stod((cAliasGIC)->GIC_DTVEND))
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_AGENCI"})[1] 	,(cAliasGIC)->GIC_AGENCI)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_DESCRI"})[1] 	,(cAliasGIC)->GI6_DESCRI)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"NOTAS"})[1] 		,(cAliasGIC)->NOTAS)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"CONTABIL"})[1] 	,(cAliasGIC)->CONTABIL)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"FICHA"})[1]		,(cAliasGIC)->FICHA)

		Endif
			
		(cAliasGIC)->(dbSkip())

	End

	oMdlGrid:SetNoInsertLine(.T.)

Endif

oMdlGrid:GoLine(1)

(cAliasGIC)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} GA906BCommit
(long_description)
@type  Static Function
@author José Carlos
@since 08/03/2026
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA906BCommit(oModel)
	oModel:lModify := .T.
	If oModel:VldData()
		FwMsgRun(,{|| GA906BProcessa(oModel)},,STR0018)	//'Gravando...'
		FWAlertSuccess("Sucesso", "Mensagem")
	EndIf 
Return .T.

/*/{Protheus.doc} GA906BProcessa
Processa transferência
@author José Carlos
@since 08/03/2026
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type Static function
/*/
Static Function GA906BProcessa(oMdl)
	Local nSel    := 0
	Local nGrid   := oMdl:GetModel( 'GRID' ):Length()
    Local cAgencia:= ''
    Local dDtVend := ''

    DbSelectArea('GZP')
    GZP->( DbSetOrder(1) )

    DbSelectArea('XXF')
    XXF->( DbSetOrder(3) )

	Begin Transaction 

		// Remover bilhete da Integração
		For nSel:=1 To nGrid
			oMdl:GetModel('GRID'):GoLine(nSel)
			If oMdl:GetModel('GRID'):GetValue('GIC_FLAG')
				cAgencia:= oMdl:GetModel('GRID'):GetValue('GIC_AGENCI')
				dDtVend := oMdl:GetModel('GRID'):GetValue('GIC_DTVEND')
				DelBilhetes(cAgencia,dDtVend)
			EndIf 
		Next nSel	

		FwFormCommit(oMdl)						

	End Transaction

Return 

/*
{Protheus.doc} MarkDesMark()
    Criação do botão para chamada da função Marca Desmarca todos
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return	
*/
Static Function MarkDesMark(oPanel)
    Local oFontB := TFont():New('Consolas',, 16,, .T.,,,,, .F., .F.)
    Local oBPS1  := NIL
    Local oBPS2  := NIL
    oBPS1  := THButton():New(001, 060, STR0019 , oPanel, {|| Mark(FWViewActive(),.T.)  }, 80, 10, oFontB, STR0020)  //"[Marca Todos]" "Marcações"
    oBPS2  := THButton():New(001, 110, STR0021 , oPanel, {|| Mark(FWViewActive(),.F.)  }, 80, 10, oFontB, STR0020)  //"[Desmarca Todos]" "Marcações"
Return Nil 

/*
{Protheus.doc} MarkDesMark(oVi,lFlag)
    Função Marca Desmarca todos conforme parametro recebido
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return
*/
Static Function Mark(oVi,lFlag)
    Local oMdl       := oVi:GetModel()
	Local oMdlGrid   := oMdl:GetModel( 'GRID' )
	Local nI         := 0
	Local aSaveLines := FWSaveRows()
	Local nItens     := oMdlGrid:Length()
	Local lFlagItem  := .F.

	If oMdlGrid:isModified()
		For nI := 1 To nItens
			lFlagItem:= lFlag
			oMdlGrid:GoLine(nI)
			If ( oMdlGrid:GetValue('NOTAS') + oMdlGrid:GetValue('CONTABIL') + oMdlGrid:GetValue('FICHA') ) > 0 
				lFlagItem := .F.					 
			EndIf
			oMdlGrid:SetValue("GIC_FLAG",lFlagItem)
		Next nI 
	EndIf 

	oMdlGrid:GoLine(1)
	FWRestRows(aSaveLines)
Return oVi:Refresh()

/*
{Protheus.doc} PosValid(oModel)
    Função de validação antes da confirmação do formulário, verificando se existe item marcado
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return
*/
Static Function PosValid(oModel)
	Local lRet 		:= .F.
	Local oMdlGrid  := oModel:GetModel( 'GRID' )
	Local oView 	:= FwViewActive()
	Local nX        := 0
	Local nTotGrid  := oMdlGrid:Length()
	Local cMdlId	:= oModel:GetId()	
	Local cMsgErro	:= STR0022	//"Não houve marcação do bilhete para processamento."
	Local cMsgSol	:= STR0023	//"Necessário marcação do bilhete."
	Local cField    := STR0011	//"Marcação"
	Local uNewValue	:= ""
	Local uOldValue := ""

	For nX := 1 To nTotGrid
		If oMdlGrid:GetValue('GIC_FLAG', nX) 
			lRet := .T.
            nTotGrid += 1
		EndIf 
	Next nX 

	oMdlGrid:GoLine(1)
	oView:Refresh()

	If !lRet 
		oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,STR0024,cMsgErro,cMsgSol,uNewValue,uOldValue)	//"Pré Validação Formulário"
	EndIf 

Return lRet 

/*
{Protheus.doc} DelBilhetes(cAgencia,dDtVend)
    Exclui Registros GIC e XXF
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return
*/
Static Function DelBilhetes(cAgencia,dDtVend)
	Local cAliasQry := GetNextAlias()
	Local cCodigo   := ""
	Local cSeek     := ""

	BeginSql Alias cAliasQry
		Select R_E_C_N_O_ as nRegGIC
		From %Table:GIC%
		Where GIC_FILIAL = %xFilial:GIC%
		And GIC_AGENCI = %Exp:cAgencia%
		And GIC_DTVEND = %Exp:Dtos(dDtVend)%
		And %NotDel%
	EndSql 

	While (cAliasQry)->(!Eof())

		GIC->(DbGoTo( (cAliasQry)->nRegGIC ) )
		cCodigo := GIC->GIC_CODIGO 

		RecLock("GIC",.F.)
		GIC->(DBDelete())
		GIC->(MsUnLock())

		cSeek := cEmpAnt + "|" + Alltrim(xFilial("GIC")) + "|" + cCodigo 

		// Exclusão XXF
		CFGA070Mnt('TotalBus' , 'GIC', 'GIC_CODIGO', , cSeek, .T. ) 

		EstornaGZP(cCodigo)

		(cAliasQry)->(DbSkip())
	EndDo 

	(cAliasQry)->(DbCloseArea())

	RecLock("H8A",.T.)
		H8A->H8A_FILIAL := xFilial("H8A")
		H8A->H8A_CODIGO := GetSxEnum('H8A','H8A_CODIGO')
		H8A->H8A_AGENCI := cAgencia
		H8A->H8A_DTVEND := dDtVend
		H8A->H8A_USRRV  := RetCodUsr()
		H8A->H8A_DATA   := Date()
		H8A->H8A_HORA   := Time()
	H8A->(MsUnlock())
	ConfirmSx8()

Return 

/*
{Protheus.doc} VldActivate(oModel)
    Pré-validação do formulário para ativação
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return
*/
Static Function VldActivate(oModel)
	Local lRet	:= .T.
	Local nOpc	:= oModel:GetOperation()

	If nOpc == MODEL_OPERATION_UPDATE
		lRet := ProcPergunte(oModel)
	Endif

Return lRet

/*
{Protheus.doc} ProcPergunte(oModel)
    Localização de registros a partir do Pergunte
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return
*/
Static Function ProcPergunte(oModel)
	Local lRetorno 	:= .T. 
	Local cQuery   	:= ""
	Local cMdlId	:= oModel:GetId()
	Local cField    := 'Vazio'
	Local cMsgErro  := ''
	Local cMsgSol   := ''

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		cMsgErro := STR0025	//'Agência não informado'
		cMsgSol  := STR0026	//'Informe Agência Inicial e Final para realizar a pesquisa'
		lRetorno := .F.
	Endif

	If Empty(MV_PAR03) .Or. Empty(MV_PAR04)
		cMsgErro := STR0027	//'Data não informado'
		cMsgSol  := STR0028	//'Informe Data Inicial e Final para realizar a pesquisa'
		lRetorno := .F.
	Endif

	If lRetorno

		cAliasGIC := GetNextAlias()

		cQuery += " AND GIC.GIC_DTVEND BETWEEN '" + Dtos( MV_PAR03 ) + "' AND '" + Dtos( MV_PAR04 ) + "' "

		cQuery += " AND GIC.GIC_AGENCI BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' " 

		cQuery := "%" + cQuery + "%"	

		BeginSql  Alias cAliasGIC

			SELECT 
				GIC_DTVEND,
				GIC_AGENCI,
				GI6_DESCRI,
				SUM(CASE WHEN GIC_LA  = 'S' THEN 1 ELSE 0 END) AS CONTABIL,
				SUM(CASE WHEN GIC_NOTA <> '' THEN 1 ELSE 0 END) AS NOTAS,
				SUM(CASE WHEN GIC_NUMFCH <> '' THEN 1 ELSE 0 END) AS FICHA 
			FROM %Table:GIC% GIC
			INNER JOIN %Table:GI6% GI6 ON GI6_FILIAL = %xFilial:GI6% 
				AND GI6_CODIGO = GIC_AGENCI
				AND GI6.%NotDel%
			WHERE 
					GIC.GIC_FILIAL = %xFilial:GIC% 
				%Exp:cQuery%
				AND GIC.%NotDel%
			GROUP BY GIC_DTVEND,GIC_AGENCI,GI6_DESCRI

		EndSql

		lRetorno := (cAliasGIC)->(!EoF())

		If !lRetorno
			cMsgErro:= STR0029	//"Não foram encontrados bilhetes com os parâmetros informados"
			cMsgSol := STR0030	//"Revise os parâmetros"
			oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"ProcPergunte",cMsgErro,cMsgSol)
			(cAliasGIC)->(dbCloseArea())			
		EndIf 
	Else 		
		oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"ProcPergunte",cMsgErro,cMsgSol)
	EndIf 

Return lRetorno 

/*
{Protheus.doc} EstornaGZP(cCodigo)
    Exclui integração TEF
    type    Function
    author  José Carlos
    since   08/03/2026
    param   Nil
return
*/
Static Function EstornaGZP(cCodigo)
	Local aAreaAtu := GetArea()

	If GZP->(DbSeek(xFilial('GZP')+cCodigo))
		While GZP->(!Eof()) .And. GZP->GZP_FILIAL == xFilial("GZP") .And. GZP->GZP_CODIGO == cCodigo
			RecLock("GZP",.F.)
			GZP->(DBDelete())
			GZP->(MsUnLock())		

			GZP->(DbSkip())
		EndDo 
	EndIf 

	RestArea( aAreaAtu )
Return
