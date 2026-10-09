#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA421I.CH"

/*/{Protheus.doc} GTPA421I
	Tela de conferência em lote
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Function GTPA421I()

FwExecView(STR0002,"VIEWDEF.GTPA421I",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Conferência de fichas de remessa em lote"

Return 

/*/{Protheus.doc} ModelDef
	ModelDef
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function ModelDef()
Local oModel	 := Nil
Local oStruCab	 := FwFormModelStruct():New() 
Local oStruTot   := FwFormModelStruct():New()
Local oStruGrd   := FwFormModelStruct():New()
Local bLoad		 := {|oModel| GA421ILoad(oModel)}
Local bCommit    := {|oModel| GA421ICommit(oModel)}
Local bPosValid  := {|oModel| PosValid(oModel)}

oModel := MPFormModel():New("GTPA421I",/*bPreValidacao*/, bPosValid/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStruct(oStruCab, oStruTot,oStruGrd)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddFields("TOTAL", "HEADER", oStruTot,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

//Desativando a exclusão de linhas
oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

oModel:SetDescription(STR0001)	//"Ficha de remessa"
oModel:GetModel("HEADER"):SetDescription(STR0003) //"Filtro"
oModel:GetModel("TOTAL"):SetDescription(STR0004) //"Totais"
oModel:GetModel("GRID"):SetDescription(STR0005)  //"Fichas"
oModel:GetModel("GRID"):SetMaxLine(99999)
oModel:SetPrimaryKey({})
oModel:GetModel("GRID"):SetMaxLine(99999)	

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
	ViewDef
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA421I")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruTot	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd,oStruTot)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0001)	//"Ficha de Remessa"

oView:AddField('VIEW_HEADER', oStruCab, 'HEADER')
oView:AddField('VIEW_TOT' 	, oStruTot, 'TOTAL' )
oView:AddGrid('VIEW_GRID'	, oStruGrd, 'GRID'  )

oView:CreateHorizontalBox('HEADER'	, 18)
oView:CreateHorizontalBox('TOTAL'	, 32)
oView:CreateHorizontalBox('GRID'	, 50)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_TOT' 	,'TOTAL')
oView:SetOwnerView('VIEW_GRID'	,'GRID')

oView:EnableTitleView("VIEW_HEADER", STR0003)	//"Filtro"
oView:EnableTitleView("VIEW_TOT"   , STR0004)	//"Totais"
oView:EnableTitleView("VIEW_GRID"  , STR0005) 	//"Fichas"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0006, "", {|| FwMsgRun(,{|| GA421IPesq()},,STR0008)},/*cToolTip*/ ,VK_F5/*nShortCut*/) //"Filtrar (F5)" //"Selecionando registro(s)..."
oView:AddUserButton(STR0007, "", {|| FwMsgRun(,{|| GA421IViewFR()},,STR0008)   },/*cToolTip*/ ,VK_F6/*nShortCut*/) //"Visual. Ficha (F6)" //"Selecionando registro(s)..."

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
	@author João Pires
	@since 16/04/2026
/*/
Static Function SetMdlStruct(oStruCab, oStruTot,oStruGrd)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"

		oStruCab:AddField(STR0009  ,STR0009	,"DATAINI" 	    ,"D", 8, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data De"
		oStruCab:AddField(STR0010  ,STR0010 ,"DATAFIM" 	    ,"D", 8, 0, bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data Até"        
		oStruCab:AddField(STR0011  ,STR0011 ,"AGENCIAINI"	,"C", TamSx3('G6X_AGENCI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agencia de"
		oStruCab:AddField(STR0012  ,STR0012 ,"AGENCIAFIM"   ,"C", TamSx3('G6X_AGENCI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agencia ate"
        oStruCab:AddTrigger("DATAINI"   ,"DATAINI"	 	, { || .T. }, bFldTrig)

	Endif	

	If ValType(oStruTot) == "O"
		oStruTot:AddField(STR0013	,STR0013  ,"QTDREG"		,"N", 4, 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Qtd. Registros"
		oStruTot:AddField(STR0014	,STR0014  ,"TOTREC"		,"N", TamSx3('G6X_VLRREI')[1], TamSx3('G6X_VLRREI')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Total Receita"
		oStruTot:AddField(STR0015	,STR0015  ,"TOTDES"		,"N", TamSx3('G6X_VLRDES')[1], TamSx3('G6X_VLRDES')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Total Despesa"
		oStruTot:AddField(STR0016	,STR0016  ,"TOTLIQ"		,"N", TamSx3('G6X_VLRLIQ')[1], TamSx3('G6X_VLRLIQ')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Total Liquido"
		oStruTot:AddField(STR0017	,STR0017  ,"TOTDEP"		,"N", TamSx3('G6X_VLTODE')[1], TamSx3('G6X_VLTODE')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Total Deposito" 
		oStruTot:AddField(STR0018 	,STR0018  ,"TOTEST"		,"N", TamSx3('G6X_VLTOES')[1], TamSx3('G6X_VLTOES')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Total Estorno" 
		oStruTot:AddField(STR0019   ,STR0019  ,"TOTDIF"		,"N", TamSx3('G6X_VLDIFE')[1], TamSx3('G6X_VLDIFE')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Total Diferença" 

	Endif

	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( STR0020, ; 	// cTitle // 'Marcação'
						STR0020, ;		// cToolTip // 'Marcação' 
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

		oStruGrd:AddField(STR0021 ,STR0021  ,"G6X_AGENCI" ,"C",TamSx3('G6X_AGENCI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Agência"
		oStruGrd:AddField(STR0022 ,STR0022  ,"G6X_NUMFCH" ,"C",TamSx3('G6X_NUMFCH')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Num. Ficha"
		oStruGrd:AddField(STR0023 ,STR0023  ,"GI6_DESCRI" ,"C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Desc. Agência"
        oStruGrd:AddField(STR0024 ,STR0024  ,"G6X_DTINI"  ,"D",TamSx3('G6X_DTINI' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Data Inicial"
        oStruGrd:AddField(STR0025 ,STR0025  ,"G6X_DTFIN"  ,"D",TamSx3('G6X_DTFIN' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Data Final"
        oStruGrd:AddField(STR0026 ,STR0026  ,"G6X_VLRREI" ,"N",TamSx3('G6X_VLRREI')[1],TamSx3('G6X_VLRREI')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Receita"
        oStruGrd:AddField(STR0027 ,STR0027  ,"G6X_VLRDES" ,"N",TamSx3('G6X_VLRDES')[1],TamSx3('G6X_VLRDES')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Despesa"
        oStruGrd:AddField(STR0028 ,STR0028  ,"G6X_VLRLIQ" ,"N",TamSx3('G6X_VLRLIQ')[1],TamSx3('G6X_VLRLIQ')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Liquido"
        oStruGrd:AddField(STR0029 ,STR0029  ,"G6X_VLTODE" ,"N",TamSx3('G6X_VLTODE')[1],TamSx3('G6X_VLTODE')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Deposito"
        oStruGrd:AddField(STR0030 ,STR0030  ,"G6X_VLTOES" ,"N",TamSx3('G6X_VLTOES')[1],TamSx3('G6X_VLTOES')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Estorno"
        oStruGrd:AddField(STR0031 ,STR0031  ,"G6X_VLDIFE" ,"N",TamSx3('G6X_VLDIFE')[1],TamSx3('G6X_VLDIFE')[2],{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Valor Diferença"

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
	Estrutuda da View
	@type Function
	@author João Pires
	@since 16/04/2026

/*/
Static Function SetViewStru(oStruCab, oStruGrd, oStruTot)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("DATAINI" 	,"01",STR0009,STR0009,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data De"
		oStruCab:AddField("DATAFIM"		,"02",STR0010,STR0010,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data Até"
		oStruCab:AddField("AGENCIAINI"	,"03",STR0011,STR0011,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Agencia De"
		oStruCab:AddField("AGENCIAFIM" 	,"04",STR0012,STR0012,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Agencia Ate"
	Endif

	If ValType(oStruTot) == "O"

		oStruTot:AddField("QTDREG"	,"01",STR0013,STR0013,{""},"GET","@E 99999",NIL,Nil ,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Qtd. Registros"
		oStruTot:AddField("TOTREC"	,"02",STR0014,STR0014,{""},"GET",PesqPict( "G6X","G6X_VLRREI" ),NIL,Nil,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Total Receita"
		oStruTot:AddField("TOTDES"	,"03",STR0015,STR0015,{""},"GET",PesqPict( "G6X","G6X_VLRDES" ),NIL,Nil,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Total Despesa"
		oStruTot:AddField("TOTLIQ"	,"04",STR0016,STR0016,{""},"GET",PesqPict( "G6X","G6X_VLRLIQ" ),NIL,Nil,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Total Liquido"
		oStruTot:AddField("TOTDEP"	,"05",STR0017,STR0017,{""},"GET",PesqPict( "G6X","G6X_VLTODE" ),NIL,Nil,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Total Deposito"
		oStruTot:AddField("TOTEST"	,"06",STR0018,STR0018,{""},"GET",PesqPict( "G6X","G6X_VLTOES" ),NIL,Nil,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Total Estorno"
		oStruTot:AddField("TOTDIF"	,"07",STR0019,STR0019,{""},"GET",PesqPict( "G6X","G6X_VLDIFE" ),NIL,Nil,.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Total Diferença"
        

	Endif
	
	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( 'G6X_FLAG', ; 	// cIdField
						'01', ; 			// cOrdem
						STR0020, ; 			// cTitulo // 'Marcação'
						STR0020, ;			// cDescric // 'Marcação' 
						{STR0020,STR0020}, ; // 'Marcação' // 'Marque os itens que deseja Transferir'
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
		oStruGrd:AddField("G6X_AGENCI"  ,"02",STR0021,STR0021,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Agência"		
		oStruGrd:AddField("GI6_DESCRI"  ,"03",STR0023,STR0023,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Desc. Agência"        
        oStruGrd:AddField("G6X_NUMFCH"  ,"04",STR0022,STR0022,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"NUm. Ficha"
		oStruGrd:AddField("G6X_DTINI"	,"05",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Data Inicial"			
		oStruGrd:AddField("G6X_DTFIN"	,"06",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Data Final"			
		oStruGrd:AddField("G6X_VLRREI"  ,"07",STR0026,STR0026,{""},"GET",PesqPict( "G6X","G6X_VLRREI" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Receita"
		oStruGrd:AddField("G6X_VLRDES"	,"08",STR0027,STR0027,{""},"GET",PesqPict( "G6X","G6X_VLRDES" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Valor Despesa"
		oStruGrd:AddField("G6X_VLRLIQ"  ,"09",STR0028,STR0028,{""},"GET",PesqPict( "G6X","G6X_VLRLIQ" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Liquido"
		oStruGrd:AddField("G6X_VLTODE"	,"10",STR0029,STR0029,{""},"GET",PesqPict( "G6X","G6X_VLTODE" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Deposito"			
		oStruGrd:AddField("G6X_VLTOES"	,"11",STR0030,STR0030,{""},"GET",PesqPict( "G6X","G6X_VLTOES" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Estorno"					
		oStruGrd:AddField("G6X_VLDIFE"	,"12",STR0031,STR0031,{""},"GET",PesqPict( "G6X","G6X_VLDIFE" ),NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Vlr Diferença"		        
		

	Endif

Return

/*/{Protheus.doc} FieldValid
    Validação do campo
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case cField == "G6X_FLAG" .AND. !IsinCallStack("Mark")
		SomaGrid()
		
	Case Empty(uNewValue)
		lRet := .T.

    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0032 // "Data final não pode ser menor que a data inicial"
            cMsgSol  := STR0033 // "Altere a data final"
        Endif

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
	Trigger
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
	
Do Case
	Case cField == 'DATAINI' 
		oMdl:SetValue('DATAFIM', dDataBase)	
EndCase

Return uVal

/*/{Protheus.doc} GA200BLoad
	Load
	@type Function
	@author João Pires
	@since 16/04/2026

/*/
Static Function GA421ILoad(oModel)
    Local oMdlCab := NIL
	Local oMdlCom := Nil
    oMdlCab := oModel:GetModel( 'HEADER' )
    oMdlCom := oModel:GetModel( 'TOTAL' )
Return

/*/{Protheus.doc} GA300CCommit
	Realiza o commit do modelo
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function GA421ICommit(oModel)	
	Local lRet		  := .T.

	FwMsgRun(,{||  GA421IConf(oModel)},,STR0034) //"Conferindo fichas..."
	FwMsgRun(,{||  lRet := GA421IArrec(oModel)},,STR0044) //"Fechando fichas..."

	If lRet
		FWAlertSuccess(STR0035) //"Fichas de remessa conferidas com sucesso!"
	Endif


Return .T.

/*/{Protheus.doc} GA421IPesq
//TODO Descrição auto-gerada.
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function GA421IPesq()
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
AtuTotal({0,0,0,0,0,0,0})

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

cQuery += " AND G6X.G6X_STATUS = '2' "

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
    FwAlertHelp(STR0036, STR0038, STR0037) //"Não foram encontrados fichas de remessa com os parâmetros informados","Altere os parâmetros","Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasG6X)->(dbCloseArea())

Return lRet


/*
{Protheus.doc} MarkDesMark(oVi,lFlag)
    Função Marca Desmarca todos conforme parametro recebido
    type    Function
    author  João Pires
    since   22/01/2026
    param   Nil
return
*/
Static Function Mark(oVi,lFlag)
    Local oMdl       := oVi:GetModel()
	Local oMdlGrid   := oMdl:GetModel( 'GRID' )
	Local nI         := 0
	Local aSaveLines := FWSaveRows()
	Local nItens     := oMdlGrid:Length()
	Local aVal		 := {0,0,0,0,0,0,0}

	If oMdlGrid:isModified()
		For nI := 1 To nItens
			oMdlGrid:GoLine(nI)
			oMdlGrid:SetValue("G6X_FLAG",lFlag) 
			If lFlag
				aVal[1] ++
				aVal[2] += oMdlGrid:GetValue("G6X_VLRREI",nI)
				aVal[3] += oMdlGrid:GetValue("G6X_VLRDES",nI)
				aVal[4] += oMdlGrid:GetValue("G6X_VLRLIQ",nI)
				aVal[5] += oMdlGrid:GetValue("G6X_VLTODE",nI)
				aVal[6] += oMdlGrid:GetValue("G6X_VLTOES",nI)
				aVal[7] += oMdlGrid:GetValue("G6X_VLDIFE",nI)
			EndIf 
		Next nI 
	EndIf 

	oMdlGrid:GoLine(1)
	FWRestRows(aSaveLines)
	//Atualiza Soma Marcados
	AtuTotal(aVal)

	GTPDestroy(aVal)

Return oVi:Refresh()

/*
{Protheus.doc} PosValid(oModel)
    Função de validação antes da confirmação do formulário, verificando se existe item marcado
	@type Function
	@author João Pires
	@since 16/04/2026
*/
Static Function PosValid(oModel)
	Local lRet 		:= .F.
	Local oMdlGrid  := oModel:GetModel( 'GRID' )
	Local oView 	:= FwViewActive()
	Local nX        := 0
	Local nTotGrid  := oMdlGrid:Length()
	Local cMdlId	:= oModel:GetId()	
	Local cMsgErro	:= STR0039	//"Não houve marcação de registros para processamento."
	Local cMsgSol	:= STR0040	//"Necessário marcação de registros."
	Local cField    := STR0020	//"Marcação"
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

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTotal
Função atualiza o valor total

	@type Function
	@author João Pires
	@since 16/04/2026
/*/
//-------------------------------------------------------------------
Static Function AtuTotal(aVal)
	oModel := FWModelActive()
    oTot   := oModel:GetModel("TOTAL")
    oTot:SetValue("QTDREG", aVal[1] )
    oTot:SetValue("TOTREC", aVal[2] )
    oTot:SetValue("TOTDES", aVal[3] )
    oTot:SetValue("TOTLIQ", aVal[4] )
    oTot:SetValue("TOTDEP", aVal[5] )
    oTot:SetValue("TOTEST", aVal[6] )
    oTot:SetValue("TOTDIF", aVal[7] )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaGrid
Função de calcula total e atualiza variavel VAR_VALTOT

	@type Function
	@author João Pires
	@since 16/04/2026
/*/
//-------------------------------------------------------------------
Static Function SomaGrid()
	Local aSaveLines := FWSaveRows()
	Local oModel := FWModelActive()
	Local oGrid  := oModel:GetModel("GRID")	
	Local nItens := oGrid:Length()
	Local nX     := 0	
	Local aVal   := {0,0,0,0,0,0,0}

	For nX:= 1 To nItens 
		If oGrid:GetValue('G6X_FLAG', nX)
			aVal[1]++
			aVal[2] += oGrid:GetValue('G6X_VLRREI',nX)
			aVal[3] += oGrid:GetValue('G6X_VLRDES',nX)
			aVal[4] += oGrid:GetValue('G6X_VLRLIQ',nX)
			aVal[5] += oGrid:GetValue('G6X_VLTODE',nX)
			aVal[6] += oGrid:GetValue('G6X_VLTOES',nX)
			aVal[7] += oGrid:GetValue('G6X_VLDIFE',nX)
		EndIf 
	Next nX 
	
	AtuTotal(aVal)	
	FWRestRows(aSaveLines)

	GTPDestroy(aVal)
	GTPDestroy(aSaveLines)
Return .T.

/*
{Protheus.doc} MarkDesMark()
    Criação do botão para chamada da função Marca Desmarca todos
	@type Function
	@author João Pires
	@since 16/04/2026
return
*/
Static Function MarkDesMark(oPanel)
    Local oFontB := TFont():New('Consolas',, 16,, .T.,,,,, .F., .F.)
    Local oBPS1  := NIL
    Local oBPS2  := NIL
    oBPS1  := THButton():New(001, 060, STR0041	, oPanel, {|| Mark(FWViewActive(),.T.)  }, 80, 10, oFontB, STR0043) //"[Marca Todos]" "Marcações"
    oBPS2  := THButton():New(001, 110, STR0042 	, oPanel, {|| Mark(FWViewActive(),.F.)  }, 80, 10, oFontB, STR0043) //"[Desmarca Todos]" "Marcações"
Return Nil 

/*/{Protheus.doc}  GA421IViewFR(oView
	Visualiza ficha de remessa
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function GA421IViewFR()
	Local oModel   := FWModelActive()
	Local oGrid    := oModel:GetModel("GRID")	
	Local aAreaG6X := G6X->(GetArea())

	G6X->(DBSetOrder(3)) //G6X_FILIAL+G6X_AGENCI+G6X_NUMFCH
	If G6X->(DBSeek(xFilial('G6X') + oGrid:GetValue("G6X_AGENCI") + oGrid:GetValue("G6X_NUMFCH")))
		FwExecView(STR0001,"VIEWDEF.GTPA421",MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Ficha de Remessa"
	Endif

	RestArea(aAreaG6X)
Return .T.

/*/{Protheus.doc} GA421IConf
	Realiza a conferêmcia
	@type Function
	@author João Pires
	@since 16/04/2026	
/*/
Static Function GA421IConf(oModel)
	
	conferTaxa(oModel:GetModel("GRID"))
	conferEnco(oModel:GetModel("GRID"))
	conferRecDesp(oModel:GetModel("GRID")) 
	conferReq(oModel:GetModel("GRID")) 

Return .T.

/*/{Protheus.doc} conferRecDesp
	Confere Receita/Despesa
	@type Function
	@author João Pires
	@since 16/04/2026	
/*/
Static Function conferRecDesp(oGrid)
	Local nX		:= 0

	G6X->(DBSetOrder(3)) //G6X_FILIAL+G6X_AGENCI+G6X_NUMFCH
	GZG->(DBSetOrder(2)) //GZG_FILIAL+GZG_AGENCI+GZG_NUMFCH+GZG_TIPO

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)

		If oGrid:GetValue("G6X_FLAG")
			If G6X->(DBSeek(xFilial("G6X") + oGrid:GetValue("G6X_AGENCI") + oGrid:GetValue("G6X_NUMFCH")))
				If GZG->(DBSeek(xFilial("GZG") + G6X->G6X_AGENCI + G6X->G6X_NUMFCH ))
					While GZG->(!Eof()) .AND. GZG->(GZG_FILIAL+GZG_AGENCI+GZG_NUMFCH) == xFilial("GZG") + G6X->G6X_AGENCI + G6X->G6X_NUMFCH
						If GZG->GZG_CONFER == '1'
							If SoftLock("GZG")
								GZG->(RecLock("GZG",.F.))
									GZG->GZG_CONFER := '2'
									GZG->GZG_USUCON := AllTrim(RetCodUsr())	
									GZG->GZG_DTCONF := dDataBase					
								GZG->(MsUnlock())
							Endif
						Endif

						GZG->(DBSkip())
					Enddo		
				Endif

			Endif

		Endif
	Next

Return 

/*/{Protheus.doc} conferReq
	Confere Requisições
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function conferReq(oGrid)
	Local nX		:= 0
	Local cAliasGIC := ""

	G6X->(DBSetOrder(3)) //G6X_FILIAL+G6X_AGENCI+G6X_NUMFCH	

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)

		If oGrid:GetValue("G6X_FLAG")
			If G6X->(DBSeek(xFilial("G6X") + oGrid:GetValue("G6X_AGENCI") + oGrid:GetValue("G6X_NUMFCH")))
				
				cAliasGIC := GetNextAlias()

				BeginSQL alias cAliasGIC

					SELECT GQW.R_E_C_N_O_ AS RECGQW
						FROM %Table:GIC% GIC
							INNER JOIN %Table:GQW% GQW
									ON GQW.GQW_FILIAL = %xFilial:GQW%
										AND GQW.GQW_CODIGO = GIC.GIC_CODREQ
										AND GQW.%NotDel%
						WHERE  GIC_FILIAL = %xFilial:GIC%
							AND GIC_AGENCI = %Exp:G6X->G6X_AGENCI%
							AND GIC_NUMFCH =  %Exp:G6X->G6X_NUMFCH%
							AND GIC_CODREQ <> ''
							AND ( GQW_CONFCH = '1'
									OR GQW_CONFER = '2' )
							AND GIC.%NotDel%
				EndSQL

				While (cAliasGIC)->(!Eof())
					GQW->(DBGoTo((cAliasGIC)->RECGQW))

					If SoftLock("GQW")
						GQW->(RecLock("GQW",.F.))
							GQW->GQW_CONFCH := "2"
							GQW->GQW_CONFER := "1"
							GQW->GQW_USUCON := AllTrim(RetCodUsr())
						GQW->(MsUnlock())
					Endif

					(cAliasGIC)->(DBSkip())
				EndDo

				(cAliasGIC)->(DBCloseArea())

			Endif

		Endif
	Next

Return 

/*/{Protheus.doc} conferTaxa
	Confere Taxas
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function conferTaxa(oGrid)
	Local nX		:= 0
	Local cChave	:= ""

	G6X->(DBSetOrder(3)) //G6X_FILIAL+G6X_AGENCI+G6X_NUMFCH	
	G57->(DBSetOrder(4)) //G57_FILIAL+G57_AGENCI+G57_NUMFCH

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)

		If oGrid:GetValue("G6X_FLAG")
			cChave := oGrid:GetValue("G6X_AGENCI") + oGrid:GetValue("G6X_NUMFCH")

			If G6X->(DBSeek(xFilial("G6X") + cChave ))
				If G57->(DBSeek(xFilial('G57') + cChave ))

					While G57->(!Eof()) .And. G57->(G57_FILIAL+G57_AGENCI+G57_NUMFCH) == xFilial('G57') + cChave
					
						If G57->G57_CONFER == '1' .And. SoftLock("G57")
							G57->(RecLock("G57",.F.))								
								G57->G57_CONFER := "2"
								G57->G57_USUCON := AllTrim(RetCodUsr())
							G57->(MsUnlock())
						Endif

						G57->(DBSkip())
					EndDo

				Endif

			Endif

		Endif
	Next

Return 

/*/{Protheus.doc} conferEnco
	Confere Encomendas (conhecimento)
	@type Function
	@author João Pires
	@since 16/04/2026
/*/
Static Function conferEnco(oGrid)
	Local nX		:= 0
	Local cAliasG99 := ""

	G6X->(DBSetOrder(3)) //G6X_FILIAL+G6X_AGENCI+G6X_NUMFCH	

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)

		If oGrid:GetValue("G6X_FLAG")
			If G6X->(DBSeek(xFilial("G6X") + oGrid:GetValue("G6X_AGENCI") + oGrid:GetValue("G6X_NUMFCH")))
				
				cAliasG99 := GetNextAlias()

				BeginSQL alias cAliasG99

					SELECT G99.R_E_C_N_O_ AS RECG99
					FROM %Table:G99% G99
					WHERE G99_FILIAL =  %xFilial:G99%
					AND G99_NUMFCH = %Exp:G6X->G6X_NUMFCH%					
					AND ((G99_CODEMI = %Exp:G6X->G6X_AGENCI% AND G99_TOMADO IN ('0','1')) OR 
						(G99_CODREC = %Exp:G6X->G6X_AGENCI% AND G99_TOMADO IN ('3','1')))
					AND G99_STATRA = '2'
					AND G99_CONFER = '1'
					AND G99.%NotDel%

				EndSQL

				While (cAliasG99)->(!Eof())
					G99->(DBGoTo((cAliasG99)->RECG99))

					If SoftLock("G99")
						G99->(RecLock("G99",.F.))							
							G99->G99_CONFER := "2"
							G99->G99_USUCON := AllTrim(RetCodUsr())
						G99->(MsUnlock())
					Endif

					(cAliasG99)->(DBSkip())
				EndDo

				(cAliasG99)->(DBCloseArea())

			Endif

		Endif
	Next

Return 

/*/{Protheus.doc} GA421IArrec
	Realiza a arrecadação
	@type Function
	@author João Pires
	@since 25/04/2026	
/*/
Static Function GA421IArrec(oModel)
	Local oGrid 	:= oModel:GetModel("GRID")
	Local oMdl500  	:= FwLoadModel("GTPA500")
	Local nX    	:= 0
	Local lActive   := .F.
	Local lRet		:= .T.	
	Local nContOk   := 0
	Local aError    := {}	
	Local cAgencia 	:= ""
	Local cNumFch  	:= ""
	Local cMsgErro  := ""

	DBSelectArea('G6X')
	G6X->(DBSetOrder(3))

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)
		If oGrid:GetValue("G6X_FLAG")
			lActive  := .F.
			nContOk++
			lRet     := .T.			
			cAgencia := oGrid:GetValue("G6X_AGENCI")
			cNumFch  := oGrid:GetValue("G6X_NUMFCH")

			lRet := GA421IFech(cAgencia,cNumFch,@lActive)

			If lRet .And. !lActive
				
				If G6X->(DBSeek(xFilial("G6X")+cAgencia+cNumFch))
					oMdl500:SetOperation(MODEL_OPERATION_INSERT)
					oMdl500:Activate()	
					lActive := oMdl500:IsActive()
				Endif			

				If lActive 
					lRet := oMdl500:VldData() .And. oMdl500:CommitData()
					oMdl500:DeActivate()

					If !lRet .OR. !GA421IFech(cAgencia,cNumFch,@lActive)
						cMsgErro  := STR0045 //"Falha na Gravação da arrecadação"
						Aadd(aError,{cAgencia,cNumFch,cMsgErro})
					Endif

				Endif

			ElseIf !lRet
				cMsgErro  := STR0045 //"Falha na Gravação da arrecadação"
				Aadd(aError,{cAgencia,cNumFch,cMsgErro})

			Endif

		Endif
	Next nX

	lRet 	:= .T.
	nContOk := nContOk - Len(aError)

	If Len(aError) > 0		
		FWAlertError(STR0046+cValtoChar(nContOk)+CRLF+STR0047+cValtoChar(Len(aError)),STR0037) //"Total de fichas conferidas sucesso: " "Total de fichas com erro na arrecadação: "
		lRet := .F.
	Endif

	GTPDestroy(oMdl500)
	GTPDestroy(aError)


Return lRet


/*/{Protheus.doc} GA421IFech
	Realiza o fechamento da arrecadação
	@type Function
	@author João Pires
	@since 25/04/2026	
/*/
Static Function GA421IFech(cAgencia,cNumFch,lArrec)
	Local lRet 		:= .T.
	Local cAliasG59 := ""
	Local nRecG59   := 0

	cAliasG59 := GetNextAlias()
	nRecG59   := 0
	lArrec 	  := .F.

	BeginSql Alias cAliasG59
		SELECT 
			G59.R_E_C_N_O_ AS RECG59
		FROM %Table:G59% G59
			WHERE G59.G59_FILIAL = %xFilial:G59%
			AND G59.G59_AGENCI =  %Exp:cAgencia%
			AND G59.G59_NUMFCH = %Exp:cNumFch%
			AND G59.G59_STATUS = 'F'
			AND G59.%NotDel%
	EndSql				

   	If (cAliasG59)->(!EOF())
		lArrec  := .T.
		nRecG59 := (cAliasG59)->RECG59
	Endif

	(cAliasG59)->(DBCloseArea())

	If nRecG59 > 0
		G59->(DBGoTo(nRecG59))
		lRet := GA500Fech()
	EndIf


Return lRet
