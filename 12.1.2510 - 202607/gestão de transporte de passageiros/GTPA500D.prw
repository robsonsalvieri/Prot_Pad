#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA500D.CH"

/*/{Protheus.doc} GTPA500D
	Tela de estorno da arrecadaçãoem lote
	@type Function
	@author João Pires
	@since 27/04/2026
/*/
Function GTPA500D()

FwExecView(STR0001,"VIEWDEF.GTPA500D",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Estorno de arrecadação em lote"

Return 

/*/{Protheus.doc} ModelDef
	ModelDef
	@type Function
	@author João Pires
	@since 27/04/2026
/*/
Static Function ModelDef()
Local oModel	 := Nil
Local oStruCab	 := FwFormModelStruct():New() 
Local oStruGrd   := FwFormModelStruct():New()
Local oStruTot   := FwFormModelStruct():New()
Local bLoad		 := {|oModel| GA500DLoad(oModel)}
Local bCommit    := {|oModel| GA500DCommit(oModel)}
Local bPosValid  := {|oModel| PosValid(oModel)}

oModel := MPFormModel():New("GTPA500D",/*bPreValidacao*/, bPosValid/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStruct(oStruCab,oStruGrd,oStruTot)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddFields("TOTAL" , "HEADER"  , oStruTot,,,bLoad)
oModel:AddGrid("GRID"    , "HEADER"  , oStruGrd,,,,,)

//Desativando a exclusão de linhas
oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

oModel:SetDescription(STR0002)	//"Arrecadação"
oModel:GetModel("HEADER"):SetDescription(STR0003) //"Filtro"
oModel:GetModel("GRID"  ):SetDescription(STR0002) //"Arrecadação"
oModel:GetModel("TOTAL" ):SetDescription(STR0004) //"Totais"
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
	@since 27/04/2026
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA500D")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()
Local oStruTot	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd,oStruTot)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0002)	//"Arrecadação"

oView:AddField('VIEW_HEADER', oStruCab, 'HEADER')
oView:AddField('VIEW_TOTAL' , oStruTot, 'TOTAL' )
oView:AddGrid('VIEW_GRID'	, oStruGrd, 'GRID'  )

oView:CreateHorizontalBox('HEADER'	, 20)
oView:CreateHorizontalBox('GRID'	, 60)
oView:CreateHorizontalBox('TOTAL'	, 20)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID'	,'GRID')
oView:SetOwnerView('VIEW_TOTAL'	,'TOTAL')

oView:EnableTitleView("VIEW_HEADER", STR0003) //"Filtro"
oView:EnableTitleView("VIEW_GRID"  , STR0002) //"Fichas"
oView:EnableTitleView("VIEW_TOTAL" , STR0004) //"Totais"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0005, "", {|| FwMsgRun(,{|| GA500DPesq()},,STR0006)},/*cToolTip*/ ,VK_F5/*nShortCut*/) //"Filtrar (F5)" //"Selecionando registro(s)..."

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:AddOtherObject('ITEM_ARREC', {|oView| MarkDesMark(oView)} ) // botoes com as acoes
oView:SetOwnerView("ITEM_ARREC",'GRID')

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStruct
	Estrutura do Model
	@type Function
	@author João Pires
	@since 27/04/2026
/*/
Static Function SetMdlStruct(oStruCab, oStruGrd,oStruTot)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"

		oStruCab:AddField(STR0007  ,STR0007	,"DATAINI" 	    ,"D", 8, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data De"
		oStruCab:AddField(STR0008  ,STR0008 ,"DATAFIM" 	    ,"D", 8, 0, bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data Até"        
		oStruCab:AddField(STR0009  ,STR0009 ,"AGENCIAINI"	,"C", TamSx3('G59_AGENCI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agencia de"
		oStruCab:AddField(STR0010  ,STR0010 ,"AGENCIAFIM"   ,"C", TamSx3('G59_AGENCI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agencia ate"
        oStruCab:AddTrigger("DATAINI"   ,"DATAINI"	 	, { || .T. }, bFldTrig)

	Endif	


	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( STR0011, ; 	// cTitle // 'Marcação'
						STR0011, ;		// cToolTip // 'Marcação' 
						'G59_FLAG', ;	// cIdField
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

		oStruGrd:AddField(STR0012 ,STR0012  ,"G59_CODIGO" ,"C",TamSx3('G59_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Código"
		oStruGrd:AddField(STR0013 ,STR0013  ,"G59_AGENCI" ,"C",TamSx3('G59_AGENCI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Agência"
		oStruGrd:AddField(STR0014 ,STR0014  ,"G59_NUMFCH" ,"C",TamSx3('G59_NUMFCH')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Num. Ficha"
		oStruGrd:AddField(STR0015 ,STR0015  ,"GI6_DESCRI" ,"C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Desc. Agência"
        oStruGrd:AddField(STR0016 ,STR0016  ,"G59_DATINI"  ,"D",TamSx3('G59_DATINI' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Data Inicial"
        oStruGrd:AddField(STR0017 ,STR0017  ,"G59_DATFIM"  ,"D",TamSx3('G59_DATFIM' )[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Data Final"
		oStruGrd:AddField(STR0018 ,STR0018  ,"STATUSE" ,"C",7,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Status"
        

	Endif	

	If ValType(oStruTot) == "O"
		oStruTot:AddField(STR0019 ,STR0019  ,"QTDREG" ,"N", 4, 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Qtd. Registros"
	Endif
	
Return

/*/{Protheus.doc} SetViewStru
	Estrutuda da View
	@type Function
	@author João Pires
	@since 27/04/2026

/*/
Static Function SetViewStru(oStruCab, oStruGrd, oStruTot)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("DATAINI" 	,"01",STR0007,STR0007,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data De"
		oStruCab:AddField("DATAFIM"		,"02",STR0008,STR0008,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data Até"
		oStruCab:AddField("AGENCIAINI"	,"03",STR0009,STR0009,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Agencia De"
		oStruCab:AddField("AGENCIAFIM" 	,"04",STR0010,STR0010,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Agencia Ate"
	Endif

	
	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( 'G59_FLAG', ; 	// cIdField
						'01', ; 			// cOrdem
						STR0011, ; 			// cTitulo // 'Marcação'
						STR0011, ;			// cDescric // 'Marcação' 
						{STR0011,STR0011}, ; // 'Marcação' // 'Marque os itens que deseja Transferir'
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
		oStruGrd:AddField("G59_CODIGO"  ,"02",STR0012,STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Código"		
		oStruGrd:AddField("G59_AGENCI"  ,"03",STR0013,STR0013,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Agência"		
		oStruGrd:AddField("GI6_DESCRI"  ,"04",STR0015,STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Desc. Agência"        
        oStruGrd:AddField("G59_NUMFCH"  ,"05",STR0014,STR0014,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"NUm. Ficha"
		oStruGrd:AddField("G59_DATINI"	,"06",STR0016,STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Data Inicial"			
		oStruGrd:AddField("G59_DATFIM"	,"07",STR0017,STR0017,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Data Final"			
		oStruGrd:AddField("STATUSE"  	,"08",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Status"		
		

	Endif

	If ValType(oStruTot) == "O"
		oStruTot:AddField("QTDREG"	,"01",STR0019,STR0019,{""},"GET","@E 99999",NIL,Nil ,.F.,NIL,NIL,{},NIL,NIL,.F.) //"Qtd. Registros"
	Endif

Return

/*/{Protheus.doc} FieldValid
    Validação do campo
	@type Function
	@author João Pires
	@since 27/04/2026
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case cField == "G59_FLAG" .AND. !IsinCallStack("Mark")
		SomaGrid()
		
	Case Empty(uNewValue)
		lRet := .T.

    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0020 // "Data final não pode ser menor que a data inicial"
            cMsgSol  := STR0021 // "Altere a data final"
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
	@since 27/04/2026
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
	@since 27/04/2026

/*/
Static Function GA500DLoad(oModel)
    Local oMdlCab := NIL
	Local oMdlTot := Nil
    oMdlCab := oModel:GetModel( 'HEADER' )
    oMdlTot := oModel:GetModel( 'TOTAL' )
Return

/*/{Protheus.doc} GA300CCommit
	Realiza o commit do modelo
	@type Function
	@author João Pires
	@since 27/04/2026
/*/
Static Function GA500DCommit(oModel)	
	Local lRet		  := .T.

	FwMsgRun(,{||  lRet := GA500DEst(oModel)},,STR0022) //"Abertura da arrecadação..."	

	If lRet
		FWAlertSuccess(STR0023) //"Arrecadação estornada com sucesso!"
	Endif


Return .T.

/*/{Protheus.doc} GA500DPesq
//TODO Descrição auto-gerada.
	@type Function
	@author João Pires
	@since 27/04/2026
/*/
Static Function GA500DPesq()
Local lRet 			:= .T.
Local cAliasG59		:= ''
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
AtuTotal(0)

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND G59.G59_DATINI BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
    cQuery += " AND G59.G59_DATFIM BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cAgIni) .And. !Empty(cAgFim)
	cQuery += " AND G59.G59_AGENCI BETWEEN '" + cAgIni + "' AND '" + cAgFim + "' "
Endif

If lHabFilBrw
    cQuery += " AND G59_AGENCI IN (SELECT G9X_CODGI6 FROM " + RetSqlName("G9X") 
    cQuery += " WHERE G9X_FILIAL = '" + xFilial('G9X') + "' "
    cQuery += " AND G9X_CODUSR = '" + __cUserId + "' "
    cQuery += " AND D_E_L_E_T_ = ' ' ) "    
EndIF

cQuery += " AND G59.G59_STATUS = 'T' "

cQuery := "%" + cQuery + "%"

cAliasG59 := GetNextAlias()

BeginSql Alias cAliasG59

    SELECT G59_CODIGO,
		G59_AGENCI,
        G59_NUMFCH,
		CASE WHEN G59_STATUS = 'T' THEN 'FECHADO' ELSE 'ABERTO' END AS STATUSE,          
        GI6_DESCRI,
        G59_DATINI,
        G59_DATFIM
    FROM %Table:G59% G59
       INNER JOIN %Table:GI6% GI6
               ON GI6.GI6_FILIAL = %xFilial:GI6% 
                  AND GI6.GI6_CODIGO = G59.G59_AGENCI
                  AND GI6.%NotDel%
    WHERE  G59_FILIAL = %xFilial:G59% 
        %Exp:cQuery%
       AND G59.%NotDel%
    ORDER BY G59_DATINI 

EndSql

If (cAliasG59)->(!EoF())

	oMdlGrid:SetNoInsertLine(.F.)

	While !(cAliasG59)->(Eof())

		If !(oMdlGrid:IsEmpty())
			oMdlGrid:AddLine()
		Endif
					
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G59_FLAG"})[1]    ,.F.)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G59_CODIGO"})[1]  ,(cAliasG59)->G59_CODIGO)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G59_AGENCI"})[1]  ,(cAliasG59)->G59_AGENCI)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_DESCRI"})[1]  ,(cAliasG59)->GI6_DESCRI)
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G59_NUMFCH"})[1]  ,(cAliasG59)->G59_NUMFCH)		
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G59_DATINI"})[1]  ,StoD((cAliasG59)->G59_DATINI))
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"G59_DATFIM"})[1]  ,StoD((cAliasG59)->G59_DATFIM))
		oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"STATUSE"})[1]     ,(cAliasG59)->STATUSE)
        	
		(cAliasG59)->(dbSkip())

	End

	oMdlGrid:SetNoInsertLine(.T.)

Else 
    FwAlertHelp(STR0024, STR0025, STR0026) //"Não foram encontrados registros com os parâmetros informados","Altere os parâmetros","Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasG59)->(dbCloseArea())

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
	Local nCont		 := 0

	If oMdlGrid:isModified()
		For nI := 1 To nItens
			oMdlGrid:GoLine(nI)
			oMdlGrid:SetValue("G59_FLAG",lFlag) 
			If lFlag
				nCont++				
			EndIf 
		Next nI 
	EndIf 

	oMdlGrid:GoLine(1)
	FWRestRows(aSaveLines)
	//Atualiza Soma Marcados
	AtuTotal(nCont)

Return oVi:Refresh()

/*
{Protheus.doc} PosValid(oModel)
    Função de validação antes da confirmação do formulário, verificando se existe item marcado
	@type Function
	@author João Pires
	@since 27/04/2026
*/
Static Function PosValid(oModel)
	Local lRet 		:= .F.
	Local oMdlGrid  := oModel:GetModel( 'GRID' )
	Local oView 	:= FwViewActive()
	Local nX        := 0
	Local nTotGrid  := oMdlGrid:Length()
	Local cMdlId	:= oModel:GetId()	
	Local cMsgErro	:= STR0027	//"Não houve marcação de registros para processamento."
	Local cMsgSol	:= STR0028	//"Necessário marcação de registros."
	Local cField    := STR0011	//"Marcação"
	Local uNewValue	:= ""
	Local uOldValue := ""

	For nX := 1 To nTotGrid
		If oMdlGrid:GetValue('G59_FLAG', nX) 
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
	@since 27/04/2026
/*/
//-------------------------------------------------------------------
Static Function AtuTotal(nQtd)
	oModel := FWModelActive()
    oTot   := oModel:GetModel("TOTAL")    
	oTot:SetValue("QTDREG", nQtd )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaGrid
Função de calcula total e atualiza variavel VAR_VALTOT

	@type Function
	@author João Pires
	@since 27/04/2026
/*/
//-------------------------------------------------------------------
Static Function SomaGrid()
	Local aSaveLines := FWSaveRows()
	Local oModel := FWModelActive()
	Local oGrid  := oModel:GetModel("GRID")	
	Local nItens := oGrid:Length()
	Local nX     := 0	
	Local nCont  := 0

	For nX:= 1 To nItens 
		If oGrid:GetValue('G59_FLAG', nX)
			nCont++
		EndIf 
	Next nX 
	
	AtuTotal(nCont)	
	FWRestRows(aSaveLines)

	GTPDestroy(aSaveLines)
Return .T.

/*
{Protheus.doc} MarkDesMark()
    Criação do botão para chamada da função Marca Desmarca todos
	@type Function
	@author João Pires
	@since 27/04/2026
return
*/
Static Function MarkDesMark(oPanel)
    Local oFontB := TFont():New('Consolas',, 16,, .T.,,,,, .F., .F.)
    Local oBPS1  := NIL
    Local oBPS2  := NIL
    oBPS1  := THButton():New(001, 060, STR0029	, oPanel, {|| Mark(FWViewActive(),.T.)  }, 80, 10, oFontB, STR0031) //"[Marca Todos]" "Marcações"
    oBPS2  := THButton():New(001, 110, STR0030 	, oPanel, {|| Mark(FWViewActive(),.F.)  }, 80, 10, oFontB, STR0031) //"[Desmarca Todos]" "Marcações"
Return Nil 

/*/{Protheus.doc} GA500DEst
	Realiza o estorno da arrecadação
	@type Function
	@author João Pires
	@since 25/04/2026	
/*/
Static Function GA500DEst(oModel)
	Local oGrid 	:= oModel:GetModel("GRID")
	Local oMdl500  	:= FwLoadModel("GTPA500")
	Local nX    	:= 0	
	Local lRet		:= .T.	
	Local nContOk   := 0
	Local aError    := {}		
	Local cMsgErro  := ""

	DBSelectArea('G59')
	G59->(DBSetOrder(1))

	For nX := 1 to oGrid:Length()
		oGrid:GoLIne(nX)
		If oGrid:GetValue("G59_FLAG")						
			nContOk++
			lRet := .F.

			If G59->(DBSeek(xFilial("G59")+oGrid:GetValue("G59_CODIGO")))	
				lRet := .T.

				If G59->G59_STATUS

					lRet := GA500Abre(.T.)

				Endif

				If lRet
					oMdl500:SetOperation(MODEL_OPERATION_DELETE)
					oMdl500:Activate()	
					lRet := oMdl500:IsActive()		

					If lRet 
						lRet := oMdl500:VldData() .And. oMdl500:CommitData()
						oMdl500:DeActivate()						
					Endif

				Endif												
				
			Endif

			If !lRet 
				cMsgErro  := STR0032 //"Falha no estorno da arrecadação"
				Aadd(aError,{oGrid:GetValue("G59_AGENCI"),oGrid:GetValue("G59_NUMFCH"),cMsgErro})
			Endif

		Endif
	Next nX

	lRet 	:= .T.
	nContOk := nContOk - Len(aError)

	If Len(aError) > 0		
		FWAlertError(STR0033+cValtoChar(nContOk)+CRLF+STR0034+cValtoChar(Len(aError)),STR0026)	//"Arrecadação estornadas com sucesso: ""Arrecadação com falha no estorno: "
		lRet := .F.
	Endif

	GTPDestroy(oMdl500)
	GTPDestroy(aError)

Return lRet
