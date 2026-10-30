#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA421M.CH"

/*/{Protheus.doc} GTPA421M
	Tela de Exclusão em lote
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Function GTPA421M()
	FwExecView(STR0001,"VIEWDEF.GTPA421M",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Exclusão em lote"
Return 

/*/{Protheus.doc} ModelDef
	ModelDef
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function ModelDef()
Local oModel	 := Nil
Local oStruCab	 := FwFormModelStruct():New() 
Local oStruGrd   := FwFormModelStruct():New()
Local bLoad		 := {|oModel| GA421MLOAD(oModel)}
Local bCommit    := {|oModel| GA421MCommit(oModel)}
Local bPosValid  := {|oModel| PosValid(oModel)}

oModel := MPFormModel():New("GTPA421M",/*bPreValidacao*/, bPosValid/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStruct(oStruCab, oStruGrd)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

//Desativando a exclusão de linhas
oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

oModel:SetDescription(STR0002)	//"Ficha de remessa"
oModel:GetModel("HEADER"):SetDescription(STR0003) //"Filtro"
oModel:GetModel("GRID"):SetDescription(STR0004)  //"Fichas"
oModel:GetModel("GRID"):SetMaxLine(99999)
oModel:SetPrimaryKey({})
oModel:GetModel("GRID"):SetMaxLine(99999)	

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
	ViewDef
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA421M")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0002)	//"Ficha de Remessa"

oView:AddField('VIEW_HEADER', oStruCab, 'HEADER')
oView:AddGrid('VIEW_GRID'	, oStruGrd, 'GRID'  )

oView:CreateHorizontalBox('HEADER'	, 30)
oView:CreateHorizontalBox('GRID'	, 70)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID'	,'GRID')

oView:EnableTitleView("VIEW_HEADER", STR0003)	//"Filtro"
oView:EnableTitleView("VIEW_GRID"  , STR0004) 	//"Fichas"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0005, "", {|| FwMsgRun(,{|| GA421MPesq()},,STR0006)},/*cToolTip*/ ,VK_F5/*nShortCut*/) //"Filtrar (F5)" //"Selecionando registro(s)..."

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:AddOtherObject('ITEM_FICHA', {|oView| MarkDesMark(oView)} ) // botoes com as acoes
oView:SetOwnerView("ITEM_FICHA",'GRID')

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStruct
	Estrutura do Model
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function SetMdlStruct(oStruCab, oStruGrd)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"

		oStruCab:AddField(STR0007 ,STR0007 ,"DATAINI" 	,"D", 8, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data De"
		oStruCab:AddField(STR0008 ,STR0008 ,"DATAFIM" 	,"D", 8, 0, bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data Até"        
		oStruCab:AddField(STR0009 ,STR0009 ,"AGENCIAINI","C", TamSx3('G6X_AGENCI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agência De"
		oStruCab:AddField(STR0010 ,STR0010 ,"AGENCIAFIM","C", TamSx3('G6X_AGENCI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agência até"
        oStruCab:AddTrigger("DATAINI"   ,"DATAINI"	 	, { || .T. }, bFldTrig)

	Endif	

	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( STR0011, ; 	// cTitle // 'Marcação'
						STR0011, ;		// cToolTip // 'Marcação' 
						'G6X_FLAG', ;	// cIdField
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

		oStruGrd:AddField(STR0012 ,STR0012  ,"G6X_AGENCI" ,"C",TamSx3('G6X_AGENCI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Agência"
		oStruGrd:AddField(STR0013 ,STR0013  ,"G6X_NUMFCH" ,"C",TamSx3('G6X_NUMFCH')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Num. Ficha"
		oStruGrd:AddField(STR0014 ,STR0014  ,"GI6_DESCRI" ,"C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Desc. Agência"
        oStruGrd:AddField(STR0015 ,STR0015  ,"G6X_DTINI"  ,"D",TamSx3('G6X_DTINI' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Data Inicial"
        oStruGrd:AddField(STR0016 ,STR0016  ,"G6X_DTFIN"  ,"D",TamSx3('G6X_DTFIN' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Data Final"
        oStruGrd:AddField(STR0017 ,STR0017  ,"G6X_VLRREI" ,"N",TamSx3('G6X_VLRREI')[1],TamSx3('G6X_VLRREI')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Receita"
        oStruGrd:AddField(STR0018 ,STR0018  ,"G6X_VLRDES" ,"N",TamSx3('G6X_VLRDES')[1],TamSx3('G6X_VLRDES')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Despesa"
        oStruGrd:AddField(STR0019 ,STR0019  ,"G6X_VLRLIQ" ,"N",TamSx3('G6X_VLRLIQ')[1],TamSx3('G6X_VLRLIQ')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Liquido"
        oStruGrd:AddField(STR0020 ,STR0020  ,"G6X_VLTODE" ,"N",TamSx3('G6X_VLTODE')[1],TamSx3('G6X_VLTODE')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Deposito"
        oStruGrd:AddField(STR0021 ,STR0021  ,"G6X_VLTOES" ,"N",TamSx3('G6X_VLTOES')[1],TamSx3('G6X_VLTOES')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Estorno"
        oStruGrd:AddField(STR0022 ,STR0022  ,"G6X_VLDIFE" ,"N",TamSx3('G6X_VLDIFE')[1],TamSx3('G6X_VLDIFE')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Diferença"

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
	Estrutuda da View
	@type Function
	@author José Carlos
	@since 16/06/2026

/*/
Static Function SetViewStru(oStruCab, oStruGrd)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("DATAINI" 	,"01",STR0007,STR0007,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data De"
		oStruCab:AddField("DATAFIM"		,"02",STR0008,STR0008,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data Até"
		oStruCab:AddField("AGENCIAINI"	,"03",STR0009,STR0009,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Agência De"
		oStruCab:AddField("AGENCIAFIM" 	,"04",STR0010,STR0010,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Agência Até"
	Endif

	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( 'G6X_FLAG', ; 	// cIdField
						'01', ; 			// cOrdem
						STR0011, ; 			// cTitulo // 'Marcação'
						STR0011, ;			// cDescric // 'Marcação' 
						{STR0011,STR0023},; // 'Marcação' // 'Marque os itens que deseja Estornar'
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
		oStruGrd:AddField("G6X_AGENCI"  ,"02",STR0012 ,STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Agência"		
		oStruGrd:AddField("GI6_DESCRI"  ,"03",STR0013 ,STR0013,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Desc. Agência"        
        oStruGrd:AddField("G6X_NUMFCH"  ,"04",STR0014 ,STR0014,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"NUm. Ficha"
		oStruGrd:AddField("G6X_DTINI"	,"05",STR0015 ,STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Data Inicial"			
		oStruGrd:AddField("G6X_DTFIN"	,"06",STR0016 ,STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Data Final"			
		oStruGrd:AddField("G6X_VLRREI"  ,"07",STR0017 ,STR0017,{""},"GET",PesqPict( "G6X","G6X_VLRREI" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Receita"
		oStruGrd:AddField("G6X_VLRDES"	,"08",STR0018 ,STR0018,{""},"GET",PesqPict( "G6X","G6X_VLRDES" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Valor Despesa"
		oStruGrd:AddField("G6X_VLRLIQ"  ,"09",STR0019 ,STR0019,{""},"GET",PesqPict( "G6X","G6X_VLRLIQ" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Liquido"
		oStruGrd:AddField("G6X_VLTODE"	,"10",STR0020 ,STR0020,{""},"GET",PesqPict( "G6X","G6X_VLTODE" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Deposito"			
		oStruGrd:AddField("G6X_VLTOES"	,"11",STR0021 ,STR0021,{""},"GET",PesqPict( "G6X","G6X_VLTOES" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Estorno"					
		oStruGrd:AddField("G6X_VLDIFE"	,"12",STR0022 ,STR0022,{""},"GET",PesqPict( "G6X","G6X_VLDIFE" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Diferença"		        
	
	Endif

Return

/*/{Protheus.doc} FieldValid
    Validação do campo
	@type Function
	@author José Carlos
	@since 16/06/2026
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

    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0024	//"Data final não pode ser menor que a data inicial"
            cMsgSol  := STR0025	//"Altere a data final"
        Endif

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
	Trigger
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
	
Do Case
	Case cField == 'DATAINI' 
		oMdl:SetValue('DATAFIM', dDataBase)	
EndCase

Return uVal

/*/{Protheus.doc} GA421MLOAD
	Load
	@type Function
	@author José Carlos
	@since 16/06/2026

/*/
Static Function GA421MLOAD(oModel)
    Local oMdlCab := NIL
	Local oMdlCom := Nil
    oMdlCab := oModel:GetModel( 'HEADER' )
    oMdlCom := oModel:GetModel( 'TOTAL' )
Return

/*/{Protheus.doc} GA421MCommit
	Realiza o commit do modelo
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function GA421MCommit(oModel)	
	Local lRet		  := .T.

	FwMsgRun(,{||  GA421MEst(oModel)},,STR0026) //"Excluindo fichas..."

	If lRet
		FWAlertSuccess(STR0027) //"Final do processamento!"
	Endif


Return .T.

/*/{Protheus.doc} GA421MPesq
//TODO Descrição auto-gerada.
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function GA421MPesq()
Local lRet 			:= .T.
Local cAliasG6X		:= ''
Local oView			:= FwViewActive()
Local oMdlHead		:= oView:GetModel():GetModel('HEADER')
Local oMdlGrid		:= oView:GetModel():GetModel('GRID')
Local cDataIni		:= Dtos(oMdlHead:GetValue('DATAINI'))
Local cDataFim		:= Dtos(oMdlHead:GetValue('DATAFIM'))
Local cAgIni		:= oMdlHead:GetValue('AGENCIAINI')
Local cAgFim		:= oMdlHead:GetValue('AGENCIAFIM')
Local cQuery		:= ""
Local lHabFilBrw 	:= GTPGetRules("HABFILUSR",,,.F.)

oMdlGrid:ClearData()

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND G6X.G6X_DTINI BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
    cQuery += " AND G6X.G6X_DTFIN BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cAgIni) .And. !Empty(cAgFim)
	cQuery += " AND G6X.G6X_AGENCI BETWEEN '" + cAgIni + "' AND '" + cAgFim + "' "
Endif

If lHabFilBrw
    cQuery += " AND G6X_AGENCI IN (SELECT G9X_CODGI6 FROM " + RetSqlName("G9X") 
    cQuery += " WHERE G9X_FILIAL = '" + xFilial('G9X') + "' "
    cQuery += " AND G9X_CODUSR = '" + __cUserId + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' ) "    
EndIF

cQuery += " AND G6X.G6X_STATUS in ('1','5') "

cQuery := "%" + cQuery + "%"

cAliasG6X := GetNextAlias()

BeginSql Alias cAliasG6X

    SELECT G6X_AGENCI,
        G6X_NUMFCH,
        G6X_STATUS,
        GI6_DESCRI,
        G6X_DTINI,
        G6X_DTFIN,
        G6X_VLRREI,
        G6X_VLRDES,
        G6X_VLRLIQ,
        G6X_VLTODE,
        G6X_VLTOES,
        G6X_VLDIFE
    FROM %Table:G6X% G6X
       INNER JOIN %Table:GI6% GI6
               ON GI6.GI6_FILIAL = %xFilial:GI6% 
                  AND GI6.GI6_CODIGO = G6X.G6X_AGENCI
                  AND GI6.%NotDel%
    WHERE  G6X_FILIAL = %xFilial:G6X% 
        %Exp:cQuery%
       AND G6X.%NotDel%
    ORDER BY G6X_DTINI 

EndSql

If (cAliasG6X)->(!EoF())

	oMdlGrid:SetNoInsertLine(.F.)

	While !(cAliasG6X)->(Eof())

		If !(oMdlGrid:IsEmpty())
			oMdlGrid:AddLine()
		Endif
					
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_FLAG"})[1]    ,.F.)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_AGENCI"})[1]  ,(cAliasG6X)->G6X_AGENCI)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_DESCRI"})[1]  ,(cAliasG6X)->GI6_DESCRI)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_NUMFCH"})[1]  ,(cAliasG6X)->G6X_NUMFCH)		
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_DTINI"})[1]   ,StoD((cAliasG6X)->G6X_DTINI))
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_DTFIN"})[1]   ,StoD((cAliasG6X)->G6X_DTFIN))
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_VLRREI"})[1]  ,(cAliasG6X)->G6X_VLRREI)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_VLRDES"})[1]  ,(cAliasG6X)->G6X_VLRDES)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_VLRLIQ"})[1]  ,(cAliasG6X)->G6X_VLRLIQ)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_VLTODE"})[1]  ,(cAliasG6X)->G6X_VLTODE)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_VLTOES"})[1]  ,(cAliasG6X)->G6X_VLTOES)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G6X_VLDIFE"})[1]  ,(cAliasG6X)->G6X_VLDIFE)
        	
		(cAliasG6X)->(dbSkip())

	End

	oMdlGrid:SetNoInsertLine(.T.)

Else 
    FwAlertHelp(STR0028, STR0029, STR0030) //"Não foram encontrados fichas de remessa com os parâmetros informados","Altere os parâmetros","Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasG6X)->(dbCloseArea())

Return lRet


/*
{Protheus.doc} Mark(oVi,lFlag)
    Função Marca Desmarca todos conforme parametro recebido
    type    Function
    author  José Carlos
    since   16/06/2026
    param   Nil
return
*/
Static Function Mark(oVi,lFlag)
    Local oMdl       := oVi:GetModel()
	Local oMdlGrid   := oMdl:GetModel( 'GRID' )
	Local nI         := 0
	Local aSaveLines := FWSaveRows()
	Local nItens     := oMdlGrid:Length()

	If oMdlGrid:isModified()
		For nI := 1 To nItens
			oMdlGrid:GoLine(nI)
			oMdlGrid:SetValue("G6X_FLAG",lFlag) 
		Next nI 
	EndIf 

	oMdlGrid:GoLine(1)
	FWRestRows(aSaveLines)

	GTPDestroy(aSaveLines)

Return oVi:Refresh()

/*
{Protheus.doc} PosValid(oModel)
    Função de validação antes da confirmação do formulário, verificando se existe item marcado
	@type Function
	@author José Carlos
	@since 16/06/2026
*/
Static Function PosValid(oModel)
	Local lRet 		:= .F.
	Local oMdlGrid  := oModel:GetModel( 'GRID' )
	Local oView 	:= FwViewActive()
	Local nX        := 0
	Local nTotGrid  := oMdlGrid:Length()
	Local cMdlId	:= oModel:GetId()	
	Local cMsgErro	:= STR0031	//"Não houve marcação de registros para processamento."
	Local cMsgSol	:= STR0032	//"Necessário marcação de registros."
	Local cField    := STR0033	//"Marcação"
	Local uNewValue	:= ""
	Local uOldValue := ""

	For nX := 1 To nTotGrid
		If oMdlGrid:GetValue('G6X_FLAG', nX) 
			lRet := .T.
			nX:= nTotGrid + 1
		EndIf 
	Next nX 

	oMdlGrid:GoLine(1)
	oView:Refresh()

	If !lRet 
		oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"PosValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
	EndIf 

Return lRet 

/*
{Protheus.doc} MarkDesMark()
    Criação do botão para chamada da função Marca Desmarca todos
	@type Function
	@author José Carlos
	@since 16/06/2026
return
*/
Static Function MarkDesMark(oPanel)
    Local oFontB := TFont():New('Consolas',, 16,, .T.,,,,, .F., .F.)
    Local oBPS1  := NIL
    Local oBPS2  := NIL
    oBPS1  := THButton():New(001, 060, STR0034	, oPanel, {|| Mark(FWViewActive(),.T.)  }, 80, 10, oFontB, STR0035) //"[Marca Todos]" "Marcações"
    oBPS2  := THButton():New(001, 110, STR0036 	, oPanel, {|| Mark(FWViewActive(),.F.)  }, 80, 10, oFontB, STR0035) //"[Desmarca Todos]" "Marcações"
Return Nil 

/*/{Protheus.doc} GA421kConf
	Realiza a conferêmcia
	@type Function
	@author José Carlos
	@since 16/06/2026	
/*/
Static Function GA421MEst(oModel)
	
	ExcluiFicha(oModel:GetModel("GRID"))

Return .T.

/*/{Protheus.doc} ExcluiFicha
	Confere Taxas
	@type Function
	@author José Carlos
	@since 16/06/2026
/*/
Static Function ExcluiFicha(oGrid)
	Local nX		:= 0
	Local cChave	:= ""
    Local oMdlFicha := Nil

	G6X->(DBSetOrder(3)) //G6X_FILIAL+G6X_AGENCI+G6X_NUMFCH	

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)

		If oGrid:GetValue("G6X_FLAG")
			cChave := oGrid:GetValue("G6X_AGENCI") + oGrid:GetValue("G6X_NUMFCH")

			If G6X->(DBSeek(xFilial("G6X") + cChave ))
                oMdlFicha := FwLoadModel('GTPA421')
                oMdlFicha:SetOperation(MODEL_OPERATION_DELETE)
                oMdlFicha:Activate()
                If oMdlFicha:VldData()
                    FwFormCommit(oMdlFicha)
                EndIf 
                oMdlFicha:DeActivate()
                oMdlFicha:Destroy()
                GTPDestroy(oMdlFicha)
			Endif

		Endif
	Next

Return 
