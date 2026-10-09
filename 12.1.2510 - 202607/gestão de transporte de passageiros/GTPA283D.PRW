#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA283D.CH"

/*/{Protheus.doc} GTPA283D
(long_description) Tela de processamento de transferência de Requisições
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.
0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA283D()

FwExecView(STR0001,"VIEWDEF.GTPA283D",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) //"Transferência"

Return 

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	 := Nil
Local oStruCab	 := FwFormModelStruct():New() 
Local oStruCompl := FwFormModelStruct():New()
Local oStruGrd   := FwFormModelStruct():New()
Local bLoad		 := {|oModel| GA283DLoad(oModel)}
Local bCommit    := {|oModel| GA283DCommit(oModel)}
Local bPosValid  := {|oModel| PosValid(oModel)}

oModel := MPFormModel():New("GTPA283D",/*bPreValidacao*/, bPosValid/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStruct(oStruCab, oStruGrd,oStruCompl)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddFields("COMPLE", "HEADER", oStruCompl,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

//Desativando a exclusão de linhas
oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

oModel:SetDescription(STR0002)	//'Seleção'
oModel:GetModel("HEADER"):SetDescription(STR0003) //"Filtro"
oModel:GetModel("COMPLE"):SetDescription(STR0075) //"Dados Complementares"
oModel:GetModel("GRID"):SetDescription(STR0004)  //"Bilhetes"
oModel:GetModel("GRID"):SetMaxLine(99999)
oModel:SetPrimaryKey({})
oModel:AddCalc( 'CALC_SOMA', 'HEADER', 'GRID' , 'GIC_VALTOT', 'VAR_VALTOT', 'SUM', { | | .T.},,STR0074,,14,2) //"Total"
oModel:AddCalc( 'CALC_SOMA', 'HEADER', 'GRID' , 'GIC_VALTOT', 'VAR_QUANT' , 'SUM', { | | .T.},,STR0076,,14,2) //"Qntd. Selecionada"
oModel:GetModel("GRID"):SetMaxLine(99999)	

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA283D")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruComp	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()
Local oStruCalc := FWCalcStruct( oModel:GetModel('CALC_SOMA') )

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd,oStruComp)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0004)	//"Requisições"

oView:AddField('VIEW_HEADER', oStruCab, 'HEADER')
oView:AddField('VIEW_COMPL' , oStruComp, 'COMPLE')
oView:AddGrid('VIEW_GRID'	, oStruGrd, 'GRID')
oView:AddField('VIEW_CALC'	, oStruCalc,'CALC_SOMA')

oView:CreateHorizontalBox('HEADER'	, 23)
oView:CreateHorizontalBox('COMPLE'	, 17)
oView:CreateHorizontalBox('GRID'	, 50)
oView:CreateHorizontalBox('TOTAL'	, 10)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_COMPL' ,'COMPLE')
oView:SetOwnerView('VIEW_GRID'	,'GRID')
oView:SetOwnerView('VIEW_CALC'	,'TOTAL')

oView:AddOtherObject("OTHER_PANEL1", {|oPanel| SaveButton(oPanel)})
oView:SetOwnerView("OTHER_PANEL1",'COMPLE')

oView:EnableTitleView("VIEW_HEADER", STR0003)	//"Filtro"
oView:EnableTitleView("VIEW_COMPL",  STR0075)	//"Dados Complementares"
oView:EnableTitleView("VIEW_GRID",   STR0004) 	//"Bilhetes"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0005, "", {|oView| FwMsgRun(,{|| GA283DPesq(oView)},,STR0006)},/*cToolTip*/ ,VK_F5/*nShortCut*/) //"Filtrar" //"Selecionando registro(s)..."

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:AddOtherObject('ITEM_REQUISICAO', {|oView| MarkDesMark(oView)} ) // botoes com as acoes
oView:SetOwnerView("ITEM_REQUISICAO",'GRID')

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStruct
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStruct(oStruCab, oStruGrd,oStruComp)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"

		oStruCab:AddField(STR0007   ,STR0007	,"DATAINI" 	    ,"D", 8, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data De"
		oStruCab:AddField(STR0008   ,STR0008    ,"DATAFIM" 	    ,"D", 8, 0, bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Data Até"

        oStruCab:AddField(STR0011  	,STR0011   	,"CLIENTEINI"	,"C", TamSx3('GQW_CODCLI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Cliente de"
		oStruCab:AddField(STR0012   ,STR0012    ,"LOJAINI"	    ,"C", TamSx3('GQW_CODLOJ')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Loja de"

		oStruCab:AddField(STR0079  	,STR0079   	,"CLIENTEFIM"	,"C", TamSx3('GQW_CODCLI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Cliente ate"
		oStruCab:AddField(STR0080   ,STR0080    ,"LOJAFIM"	    ,"C", TamSx3('GQW_CODLOJ')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Loja ate"

		oStruCab:AddField(STR0081  	,STR0081   	,"AGENCIAINI"	,"C", TamSx3('GQW_CODAGE')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agencia de"
		oStruCab:AddField(STR0082   ,STR0082    ,"AGENCIAFIM"   ,"C", TamSx3('GQW_CODAGE')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agencia ate"

        oStruCab:AddTrigger("DATAINI"   ,"DATAINI"	 	, { || .T. }, bFldTrig)

	Endif	

	If ValType(oStruComp) == "O"
		oStruComp:AddField(STR0057	,STR0057   	,"DESTINO"		,"C", TamSx3('GQW_CODORI')[1], 0,bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Num. Requisição"	
		oStruComp:AddField(STR0033  ,STR0033    ,"CLIENTE"		,"C", TamSx3('A1_COD')[1], 	   0,bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //'Cód.Cliente'
		oStruComp:AddField(STR0034  ,STR0034	,"LOJA"			,"C", TamSx3('A1_LOJA')[1],    0,bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Loja
		
		oStruComp:SetProperty("DESTINO",MODEL_FIELD_OBRIGAT, .F. )		
		oStruComp:SetProperty("CLIENTE",MODEL_FIELD_OBRIGAT, .F. )
		oStruComp:SetProperty("LOJA"   ,MODEL_FIELD_OBRIGAT, .F. )

		oStruComp:AddTrigger("DESTINO"   ,"DESTINO"	 	, { || .T. }, bFldTrig)

	Endif

	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( STR0058, ; 	// cTitle // 'Marcação'
						STR0058, ;		// cToolTip // 'Marcação' 
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

		oStruGrd:AddField(STR0015 ,STR0015  ,"ORIGEM"		,"C",TamSx3('GQW_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Código"
		oStruGrd:AddField(STR0083 ,STR0083  ,"RORIGEM"		,"C",TamSx3('GQW_CODORI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Req.Origem"
		oStruGrd:AddField(STR0018 ,STR0018  ,"GQW_CODAGE"	,"C",TamSx3('GQW_CODAGE')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Cód.Agência'	
		oStruGrd:AddField(STR0019 ,STR0019  ,"GIC_DTVIAG"	,"D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Dt.Viagem'							
		oStruGrd:AddField(STR0020 ,STR0020	,"GIC_DTVEND"	,"D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Dt.Venda' 							
		oStruGrd:AddField(STR0021 ,STR0021  ,"GIC_VALTOT"	,"N",TamSx3('GIC_VALTOT')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Vlr.Total"	
        oStruGrd:AddField(STR0022 ,STR0022  ,"GIC_NOMEPA"	,"C",TamSx3('GIC_NOMEPA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Nome Passageiro'	
		oStruGrd:AddField(STR0023 ,STR0023  ,"A1_NOME"		,"C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	//'Cliente'
		oStruGrd:AddField(STR0024 ,STR0024  ,"GIC_BILHET"	,"C",TamSx3('GIC_BILHET')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Nr.Bilhete"	
		oStruGrd:AddField(STR0025 ,STR0025  ,"GIC_CHVBPE"	,"C",TamSx3('GIC_CHVBPE')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Chave BPE" 	
		oStruGrd:AddField(STR0026 ,STR0026  ,"GIC_NUMBPE"	,"C",TamSx3('GIC_NUMBPE')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Nr.BPE'	
		oStruGrd:AddField(STR0027 ,STR0027  ,"GIC_LINHA"	,"C",TamSx3('GIC_LINHA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Cód.Linha" 	
		oStruGrd:AddField(STR0028 ,STR0028	,"GIC_NLINHA"	,"C",TamSx3('GIC_NLINHA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Nome Linha" 	
		oStruGrd:AddField(STR0029 ,STR0029	,"GIC_CCF"		,"C",TamSx3('GIC_CCF')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"CCF"		
		oStruGrd:AddField(STR0030 ,STR0030  ,"GIC_LOCORI"	,"C",TamSx3('GIC_LOCORI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Loc.Origem" 	
		oStruGrd:AddField(STR0031 ,STR0031  ,"GIC_LOCDES"	,"C",TamSx3('GIC_LOCDES')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  //"Cód.Loc.Des."	
		oStruGrd:AddField(STR0032 ,STR0032  ,"GIC_CODIGO"	,"C",TamSx3('GIC_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  //'Código Bil.'	
		oStruGrd:AddField(STR0033 ,STR0033  ,"A1_COD"		,"C",TamSx3('A1_COD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	//'Cód.Cliente'
		oStruGrd:AddField(STR0034 ,STR0034  ,"A1_LOJA"		,"C",TamSx3('A1_LOJA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Loja'	
		oStruGrd:AddField(STR0056 ,STR0056   ,"A1_NOME"		,"C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Nome Cliente'	

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruGrd, oStruComp)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("DATAINI" 	,"01",STR0007,STR0007,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data De"
		oStruCab:AddField("DATAFIM"		,"02",STR0008,STR0008,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data Até"

		oStruCab:AddField("CLIENTEINI"	,"03",STR0011,STR0011,{""},"GET","@!",NIL,"SA1",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Cliente De"
		oStruCab:AddField("LOJAINI" 	,"04",STR0012,STR0012,{""},"GET","@!",NIL,""   ,.T.,NIL,NIL,{},NIL,NIL,.F.) //"Loja De"

		oStruCab:AddField("CLIENTEFIM"	,"05",STR0079,STR0079,{""},"GET","@!",NIL,"SA1",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Cliente Ate"
		oStruCab:AddField("LOJAFIM" 	,"06",STR0080,STR0080,{""},"GET","@!",NIL,""   ,.T.,NIL,NIL,{},NIL,NIL,.F.) //"Loja Ate"

		oStruCab:AddField("AGENCIAINI"	,"07",STR0081,STR0081,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Agencia De"
		oStruCab:AddField("AGENCIAFIM" 	,"08",STR0082,STR0082,{""},"GET","@!",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Agencia Ate"
	Endif

	If ValType(oStruComp) == "O"

		oStruComp:AddField("DESTINO"	,"01",STR0083,STR0083,{""},"GET","",NIL,Nil  ,.T.,NIL,NIL,{},NIL,NIL,.F.)	//"Req. Origem"
		oStruComp:AddField("CLIENTE"	,"02",STR0033,STR0033,{""},"GET","",NIL,"GQV",.T.,NIL,NIL,{},NIL,NIL,.F.)	//'Cód.Cliente'
		oStruComp:AddField("LOJA"	    ,"03",STR0034,STR0034,{""},"GET","",NIL,Nil  ,.T.,NIL,NIL,{},NIL,NIL,.F.)	//"Loja" 	


	Endif
	

	
	If ValType(oStruGrd) == "O"
		oStruGrd:AddField( 'GIC_FLAG', ; 	// cIdField
						'01', ; 			// cOrdem
						STR0058, ; 			// cTitulo // 'Marcação'
						STR0058, ;			// cDescric // 'Marcação' 
						{STR0058,STR0059}, ; // 'Marcação' // 'Marque os itens que deseja Transferir'
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
		oStruGrd:AddField("ORIGEM"	    ,"02",STR0015,STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Código"		
		oStruGrd:AddField("RORIGEM"	    ,"03",STR0083,STR0083,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Req.Origem"		
		oStruGrd:AddField("GQW_CODAGE"	,"04",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Cód.Agência'					
		oStruGrd:AddField("GIC_NUMBPE"	,"05",STR0026,STR0026,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Nr.BPE'				
		oStruGrd:AddField("A1_COD"		,"06",STR0033,STR0033,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Cód.Cliente'	
		oStruGrd:AddField("A1_LOJA"		,"07",STR0034,STR0034,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Loja'		
		oStruGrd:AddField("A1_NOME"		,"08",STR0056,STR0056,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Nome Cliente'	
		oStruGrd:AddField("GIC_NOMEPA"	,"09",STR0022,STR0022,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Nome Passageiro'			
		oStruGrd:AddField("GIC_BILHET"	,"10",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Nr.Bilhete"						
		oStruGrd:AddField("GIC_DTVIAG"	,"11",STR0019,STR0019,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Dt.Viagem'			
        oStruGrd:AddField("GIC_DTVEND"	,"12",STR0020,STR0020,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Dt.Venda'			
		oStruGrd:AddField("GIC_VALTOT"	,"13",STR0021,STR0021,{""},"GET","@E 999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Vlr.Total"
		oStruGrd:AddField("GIC_LOCORI"	,"14",STR0030,STR0030,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Loc.Origem" 			
		oStruGrd:AddField("GIC_LOCDES"	,"15",STR0031,STR0031,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Cód.Loc.Des."			
		oStruGrd:AddField("GIC_CHVBPE"	,"16",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Chave BPE" 			
		oStruGrd:AddField("GIC_LINHA"	,"17",STR0027,STR0027,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Cód.Linha"			
		oStruGrd:AddField("GIC_NLINHA"	,"18",STR0028,STR0028,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Nome Linha"			
		oStruGrd:AddField("GIC_CCF"		,"19",STR0029,STR0029,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"CCF"			
		oStruGrd:AddField("GIC_CODIGO"	,"20",STR0032,STR0032,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Código'		
		

	Endif

Return

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
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
Local _uAux     

Do Case
	Case cField == "GIC_FLAG" .AND. !IsinCallStack("Mark")
		SomaGrid()
		
	Case Empty(uNewValue)
		lRet := .T.

    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0035 // "Data final não pode ser menor que a data inicial"
            cMsgSol  := STR0036 // "Altere a data final"
        Endif

	Case cField == "CLIENTE" 
	 	If !Empty(uNewValue) 
			_uAux    := GetAdvFval('SA1','A1_LOJA',xFilial('SA1')+uNewValue,1)
			If Empty(_uAux) .OR. !ExistCpo("GQV",uNewValue+AllTrim(_uAux))
            	lRet     := .F.
            	cMsgErro := STR0039	//"Cliente não localizado."
            	cMsgSol  := STR0040	//"Informe Cliente cadastrado."
			Else
				oModel:GetModel('COMPLE'):LoadValue('LOJA',_uAux)				
			EndIf 				
        Endif	

	Case cField == "LOJA" 
	 	If !Empty(uNewValue) 
			_uAux  := oModel:GetModel('COMPLE'):GetValue('CLIENTE')
			If Empty(_uAux) .OR. !ExistCpo("GQV",_uAux+uNewValue)
            	lRet     := .F.
            	cMsgErro := STR0039	//"Cliente não localizado."
            	cMsgSol  := STR0040	//"Informe Cliente cadastrado."						
			EndIf 				
        Endif			
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
	
Do Case
	Case cField == 'DATAINI' 
		oMdl:SetValue('DATAFIM', dDataBase)	
	
    
EndCase

Return uVal

/*/{Protheus.doc} GA200BLoad
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA283DLoad(oModel)
    Local oMdlCab := NIL
	Local oMdlCom := Nil
    oMdlCab := oModel:GetModel( 'HEADER' )
    oMdlCom := oModel:GetModel( 'COMPLE' )
Return

/*/{Protheus.doc} GA300CCommit
(long_description)
@type  Static Function
@author José Carlos
@since 03/12/2025
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA283DCommit(oModel)	
	Local lRet		  := .T.

	Begin Transaction
		
		FwMsgRun(,{|| lRet :=  GA283DTrnasf(oModel)},,STR0049)	//"Transferindo requisições..."

		If !lRet
			DisarmTransaction()
			MsgAlert(STR0084) //"Falha na gravação das informações"			
		Endif

	End Transaction

Return lRet

/*/{Protheus.doc} GA283DPesq
//TODO Descrição auto-gerada.
@author José Carlos
@since 03/12/2025
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA283DPesq(oView)
Local lRet 			:= .T.
Local cAliasGIC		:= ''
Local oMdlHead		:= oView:GetModel():GetModel('HEADER')
Local oMdlGrid		:= oView:GetModel():GetModel('GRID')
Local oMdlComp		:= oView:GetModel():GetModel('COMPLE')
Local cDataIni		:= Dtos(oMdlHead:GetValue('DATAINI'))
Local cDataFim		:= Dtos(oMdlHead:GetValue('DATAFIM'))
Local cCliIni		:= oMdlHead:GetValue('CLIENTEINI')
Local cCliFim		:= oMdlHead:GetValue('CLIENTEFIM')
Local cLjIni		:= oMdlHead:GetValue('LOJAINI')
Local cLjFim		:= oMdlHead:GetValue('LOJAFIM')
Local cAgIni		:= oMdlHead:GetValue('AGENCIAINI')
Local cAgFim		:= oMdlHead:GetValue('AGENCIAFIM')
Local cDescLin		:= ""
Local cQuery		:= ""

If oMdlGrid:Length() > 1
	If !MsgYesNo(STR0087,STR0085) //"As informações salvas em tela serão perdidas, Continuar?" "Atenção"
		Return lRet
	Endif
Endif
oMdlGrid:ClearData()
oMdlComp:ClearField("DESTINO")
oMdlComp:ClearField("CLIENTE")
oMdlComp:ClearField("LOJA")

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND GIC.GIC_DTVEND BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cCliIni) .And. !Empty(cCliFim)
	cQuery += " AND GQW.GQW_CODCLI BETWEEN '" + cCliIni + "' AND '" + cCliFim + "' "
Endif

If !Empty(cLjIni) .And. !Empty(cLjFim)
	cQuery += " AND GQW.GQW_CODLOJ BETWEEN '" + cLjIni + "' AND '" + cLjFim + "' "
Endif

If !Empty(cAgIni) .And. !Empty(cAgFim)
	cQuery += " AND GQW.GQW_CODAGE BETWEEN '" + cAgIni + "' AND '" + cAgFim + "' "
Endif

cQuery += " AND GQW.GQW_STATUS = '2' AND GQW.GQW_CODLOT = ' ' "

cQuery := "%" + cQuery + "%"

cAliasGIC := GetNextAlias()

BeginSql  Alias cAliasGIC

	SELECT 
        GQW_CODIGO,
		GQW_CODORI,
        GQW_CODAGE,
        GQW_DATEMI,
        GQW_CODCLI,
        GQW_CODLOJ,
        GIC_CODIGO,			
		GIC_BILHET,
		GIC_LINHA,
		GIC_DTVIAG,
		GIC_DTVEND,
		GIC_VALTOT,
		GIC_CHVBPE,
		GIC_SENTID,
		GIC_CCF,
		GIC_LOCORI,
		GIC_LOCDES,
        GIC_NOMEPA,
        GIC_NUMBPE,
		GI2.GI2_NUMLIN,
		GI1ORI.GI1_DESCRI AS LOCORI,
		GI1DES.GI1_DESCRI AS LOCDES,
        A1_NOME,
		A1_COD,
		A1_LOJA
	FROM %Table:GQW% GQW
    INNER JOIN %Table:GIC% GIC ON GIC.GIC_FILIAL = %xFilial:GIC% 
        AND GIC.GIC_CODREQ = GQW_CODIGO AND GIC.%NotDel%
    INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% 
        AND SA1.A1_COD = GQW_CODCLI 
        AND SA1.A1_LOJA = GQW_CODLOJ 
        AND SA1.%NotDel%
	LEFT JOIN %Table:GI2% GI2 ON GI2.GI2_FILIAL = %xFilial:GI2%
	    AND GI2.GI2_COD = GIC.GIC_LINHA
	    AND GI2.GI2_HIST ='2'
	    AND GI2.%NotDel%
	LEFT JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
	    AND GI1ORI.GI1_COD= GI2.GI2_LOCINI
	    AND GI1ORI.%NotDel%
	LEFT JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
	    AND GI1DES.GI1_COD = GI2.GI2_LOCFIM
	    AND GI1DES.%NotDel%
	WHERE GQW.GQW_FILIAL = %xFilial:GQW%
	    %Exp:cQuery%
	    AND GQW.%NotDel%
	ORDER BY GQW_CODIGO 		

EndSql

If (cAliasGIC)->(!EoF())

	oMdlGrid:SetNoInsertLine(.F.)

	While !(cAliasGIC)->(Eof())

		If !(oMdlGrid:SeekLine({{"GIC_CODIGO",(cAliasGIC)->GIC_CODIGO}}))

			If !(oMdlGrid:IsEmpty())
				oMdlGrid:AddLine()
			Endif

			If (cAliasGIC)->GIC_SENTID == '1'
				cDescLin := AllTrim((cAliasGIC)->LOCORI) + '/' + AllTrim((cAliasGIC)->LOCDES)
			Else
				cDescLin := AllTrim((cAliasGIC)->LOCDES) + '/' + AllTrim((cAliasGIC)->LOCORI)
			Endif			
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_FLAG"})[1]     ,.F.)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"ORIGEM"})[1]       ,(cAliasGIC)->GQW_CODIGO)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"RORIGEM"})[1]      ,(cAliasGIC)->GQW_CODORI)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GQW_CODAGE"})[1]   ,(cAliasGIC)->GQW_CODAGE)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_DTVIAG"})[1]   ,StoD((cAliasGIC)->GIC_DTVIAG))
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_DTVEND"})[1]   ,StoD((cAliasGIC)->GIC_DTVEND))
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_VALTOT"})[1]   ,(cAliasGIC)->GIC_VALTOT)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_NOMEPA"})[1]   ,(cAliasGIC)->GIC_NOMEPA)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"A1_NOME"})[1]      ,(cAliasGIC)->A1_NOME)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_BILHET"})[1]   ,(cAliasGIC)->GIC_BILHET)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_CHVBPE"})[1]   ,(cAliasGIC)->GIC_CHVBPE)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_NUMBPE"})[1]   ,(cAliasGIC)->GIC_NUMBPE)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_LINHA"})[1]    ,(cAliasGIC)->GIC_LINHA)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_NLINHA"})[1]   , cDescLin)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_CCF"})[1]      ,(cAliasGIC)->GIC_CCF)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_LOCORI"})[1]   ,(cAliasGIC)->GIC_LOCORI)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_LOCDES"})[1]   ,(cAliasGIC)->GIC_LOCDES)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_CODIGO"})[1]   ,(cAliasGIC)->GIC_CODIGO )
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"A1_COD"})[1]   	,(cAliasGIC)->A1_COD )
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"A1_LOJA"})[1]   	,(cAliasGIC)->A1_LOJA )
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"A1_NOME"})[1]   	,(cAliasGIC)->A1_NOME )


		Endif
			
		(cAliasGIC)->(dbSkip())

	End

	oMdlGrid:SetNoInsertLine(.T.)

Else 
    FwAlertHelp(STR0053, STR0054, STR0052) //"Não foram encontrados bilhetes com os parâmetros informados","Altere os parâmetros","Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasGIC)->(dbCloseArea())

AtuTotal(0,0)

Return lRet

/*/{Protheus.doc} GA283DTrnasf
Processa transferência
@author José Carlos
@since 03/12/2025
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type Static function
/*/
Static Function GA283DTrnasf(oModel)
	Local lRet		:= .T.
	Local oGrid		:= oModel:GetModel('GRID')	
	Local oMdlGQW  	:= FwLoadModel("GTPA283")
	Local nX		:= 0
	Local aError	:= {}
	Local lConf		:= .F.

	For nX := 1 to oGrid:Length()
		oGrid:GoLine(nX)
		lConf		:= .F.
		DBSelectArea('GQW')
		GQW->(DbSetOrder(1))

		If GQW->(DbSeek(xFilial('GQW')+oGrid:GetValue("ORIGEM"))) 
			
			If (ALLTRIM(GQW->GQW_CODORI) <> ALLTRIM(oGrid:GetValue("RORIGEM"))) .or.;
			   (ALLTRIM(GQW->GQW_CODCLI) <> ALLTRIM(oGrid:GetValue("A1_COD"))) .or.;
			   (ALLTRIM(GQW->GQW_CODLOJ) <> ALLTRIM(oGrid:GetValue("A1_LOJA"))) 

				//Desvincula o bilhete da requisição original
				oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
				oMdlGQW:Activate()		
				lRet := oMdlGQW:IsActive()

				If (ALLTRIM(GQW->GQW_CONFER)) == '1' .AND. (ALLTRIM(GQW->GQW_CONFCH)) == "2"
					lConf := .T.
				Endif

				If lRet .AND. oMdlGQW:GetModel('GRIDGIC'):Length() <= 1 

					oMdlGQW:DeActivate()
					oMdlGQW:SetOperation(MODEL_OPERATION_DELETE) 
					oMdlGQW:Activate()	

				ElseIf lRet .AND. oMdlGQW:GetModel('GRIDGIC'):SeekLine({{'GIC_NUMBPE',oGrid:GetValue("GIC_NUMBPE")}}) 

					oMdlGQW:GetModel('GRIDGIC'):DeleteLine()   

				Endif

				If lRet
					lRet := oMdlGQW:VldData() .And. oMdlGQW:CommitData()
				Endif

				If !lRet .OR. !GA283DNewReq(@oMdlGQW,@oGrid,lConf)
					aError := oMdlGQW:GetErrorMessage()					
					Exit															
				Endif

			Endif

		Endif

	Next nX

	If !Empty(aError)
		JurShowErro(aError)
	EndIF 

	GTPDestroy(oMdlGQW)
	GTPDestroy(aError)

Return lRet

/*
{Protheus.doc} MarkDesMark()
    Criação do botão para chamada da função Marca Desmarca todos
    type    Function
    author  José Carlos
    since   22/01/2026
    param   Nil
return
*/
Static Function MarkDesMark(oPanel)
    Local oFontB := TFont():New('Consolas',, 16,, .T.,,,,, .F., .F.)
    Local oBPS1  := NIL
    Local oBPS2  := NIL
    oBPS1  := THButton():New(001, 060, STR0068	, oPanel, {|| Mark(FWViewActive(),.T.)  }, 80, 10, oFontB, STR0069) //"[Marca Todos]" "Marcações"
    oBPS2  := THButton():New(001, 110, STR0070 	, oPanel, {|| Mark(FWViewActive(),.F.)  }, 80, 10, oFontB, STR0069) //"[Desmarca Todos]" "Marcações"
Return Nil 

/*
{Protheus.doc} MarkDesMark(oVi,lFlag)
    Função Marca Desmarca todos conforme parametro recebido
    type    Function
    author  José Carlos
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
	Local nSoma      := 0 
	Local nQtdB 	 := 0

	If oMdlGrid:isModified()
		For nI := 1 To nItens
			oMdlGrid:GoLine(nI)
			oMdlGrid:SetValue("GIC_FLAG",lFlag) 
			If lFlag
				nSoma += oMdlGrid:GetValue("GIC_VALTOT")
				nQtdB++
			EndIf 
		Next nI 
	EndIf 

	oMdlGrid:GoLine(1)
	FWRestRows(aSaveLines)
	//Atualiza Soma Marcados
	AtuTotal(nSoma,nQtdB)
Return oVi:Refresh()

/*
{Protheus.doc} PosValid(oModel)
    Função de validação antes da confirmação do formulário, verificando se existe item marcado
    type    Function
    author  José Carlos
    since   22/01/2026
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
	Local cMsgErro	:= STR0071	//"Não houve marcação da requisição para processamento."
	Local cMsgSol	:= STR0072	//"Necessário marcação da requisição."
	Local cField    := STR0058	//"Marcação"
	Local uNewValue	:= ""
	Local uOldValue := ""

	For nX := 1 To nTotGrid
		If oMdlGrid:GetValue('GIC_FLAG', nX) 
			lRet := .T.
			nX:= nTotGrid + 1
		EndIf 
	Next nX 

	oMdlGrid:GoLine(1)
	oView:Refresh()

	If !lRet 
		oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,STR0073,cMsgErro,cMsgSol,uNewValue,uOldValue)	//"Pré Validação Formulário"
	EndIf 

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTotal
Função atualiza o valor total

@type Static Function
@param  oModel
@return 
@author José Carlos
@since 23/01/2026
/*/
//-------------------------------------------------------------------
Static Function AtuTotal(nValor,nQtd)
    oModel := FWModelActive()
    oTot   := oModel:GetModel("CALC_SOMA")
    oTot:SetValue("VAR_VALTOT", nValor )
    oTot:SetValue("VAR_QUANT", nQtd )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaGrid
Função de calcula total e atualiza variavel VAR_VALTOT

@type Static Function
@param  oModel
@return n
@author José Carlos
@since 23/01/2026
/*/
//-------------------------------------------------------------------
Static Function SomaGrid()
	Local aSaveLines := FWSaveRows()
	Local oModel := FWModelActive()
	Local oGrid  := oModel:GetModel("GRID")
	Local nItens := oGrid:Length()
	Local nX     := 0
	Local nSoma  := 0
	Local nQtdB  := 0

	For nX:= 1 To nItens 
		If oGrid:GetValue('GIC_FLAG', nX)
			nSoma += oGrid:GetValue('GIC_VALTOT', nX)
			nQtdB++
		EndIf 
	Next nX 

	AtuTotal(nSoma,nQtdB)

	FWRestRows(aSaveLines)
Return .T.


/*/{Protheus.doc} GA283DSave
Salvar os dados complementares na grid 
@author João Pires
@since 03/03/2026
@version 1.0
/*/
Static Function GA283DSave()
	Local lRet 			:= .T.	
	Local oView 		:= FWViewActive()
	Local oMdlComp		:= oView:GetModel():GetModel('COMPLE')
	Local oMdlGrid		:= oView:GetModel():GetModel('GRID')
	Local nX 			:= 0
	Local nLine			:= 0
	Local cNumReq		:= ""
	Local cCliCod		:= ""
	Local cCliLoj		:= ""
	Local cCliNom		:= ""

	cNumReq := oMdlComp:GetValue("DESTINO")
	cCliCod := oMdlComp:GetValue("CLIENTE")
	cCliLoj := oMdlComp:GetValue("LOJA")

	If !Empty(cCliCod) .AND. Empty(cCliLoj)
		FWAlertError(STR0040, STR0039) //"Cliente não localizado." "Informe Cliente cadastrado."
		Return .F.
	Endif

	oMdlGrid:SetNoInsertLine(.F.)
	nLine := oMdlGrid:GetLine()

	for nX := 1 to oMdlGrid:Length()
		oMdlGrid:GoLine(nX)

		If oMdlGrid:GetValue("GIC_FLAG")
			
			If !Empty(cNumReq) 
				oMdlGrid:LoadValue("RORIGEM",ALLTRIM(cNumReq))
			Endif

			If !Empty(cCliCod) .AND. !Empty(cCliLoj)					
					cCliNom := GetAdvFval('SA1','A1_NOME',xFilial('SA1')+cCliCod+cCliLoj,1)
					oMdlGrid:LoadValue("A1_COD",cCliCod)
					oMdlGrid:LoadValue("A1_LOJA",cCliLoj)
					oMdlGrid:LoadValue("A1_NOME",ALLTRIM(cCliNom))				
			Endif

		Endif


	Next nX

	oMdlGrid:SetNoInsertLine(.T.)

	oMdlGrid:GoLine(nLine)

	oMdlComp:ClearField("DESTINO")
	oMdlComp:ClearField("CLIENTE")
	oMdlComp:ClearField("LOJA")

	oView:Refresh()	

Return lRet

/*/{Protheus.doc} GA283DNewReq
	Cria nova requisição ou vincula o bilhete a uma já existente
	@type  Static Function
	@author João Pires
	@since 10/03/2026
	@version 1.0
/*/
Static Function GA283DNewReq(oMdlGQW,oGrid,lConf)
	Local lRet 		:= .T.
	Local lValComp  := GTPGetRules("VALIDCOMP",,,.F.)	
	Local cAliasQry := GetNextAlias()	
	Local cQryGQW   := ""

	If oMdlGQW:IsActive()
		oMdlGQW:DeActivate()
	Endif

	cQryGQW := " SELECT GQW_CODIGO, "
	cQryGQW += " 	GQW.R_E_C_N_O_ REQGQW "
	cQryGQW += " FROM   "+RetSqlName("GQW")+" GQW "
	cQryGQW += " WHERE  GQW_FILIAL = '"+xFilial("GQW")+"' "	
	cQryGQW += " 	AND GQW_CODORI = '"+oGrid:GetValue("RORIGEM")+"' "
	cQryGQW += " 	AND GQW_CODCLI = '"+oGrid:GetValue("A1_COD")+"' "
	cQryGQW += " 	AND GQW_CODLOJ = '"+oGrid:GetValue("A1_LOJA")+"' "
	cQryGQW += " 	AND GQW.GQW_CODAGE = '"+oGrid:GetValue("GQW_CODAGE")+"'  "
	cQryGQW += " 	AND GQW.GQW_STATUS = '2' "
	cQryGQW += " 	AND GQW.GQW_CONFER = '2' "
	cQryGQW += " 	AND GQW.GQW_CODLOT = ' ' "	
	If lValComp .AND. GQW->(FieldPos("GQW_COMPET")) > 0
		cQryGQW += " 	AND (GQW_COMPET = ' ' OR GQW_COMPET = '"+AnoMes(oGrid:GetValue("GIC_DTVEND"))+"') "
	Endif
	cQryGQW += " 	AND GQW.D_E_L_E_T_ = ' ' "
	
    cQryGQW := ChangeQuery(cQryGQW)  

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryGQW), cAliasQry, .F., .T.)

	If (cAliasQry)->(!Eof())
		GQW->(DBGoTo((cAliasQry)->REQGQW))

		oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
		oMdlGQW:Activate()		
		lRet := oMdlGQW:IsActive()		

		If lRet
			oMdlGQW:GetModel('GRIDGIC'):AddLine(.T.)
			lRet := oMdlGQW:GetModel('GRIDGIC'):SetValue("GIC_CODIGO",  oGrid:GetValue("GIC_CODIGO")  )
		Endif

	Else
		oMdlGQW:SetOperation(MODEL_OPERATION_INSERT)
		oMdlGQW:Activate()
		lRet := oMdlGQW:IsActive()

		IF lRet
			oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODORI",  oGrid:GetValue("RORIGEM")  			  )
			oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_REQDES",  STR0086+oGrid:GetValue("RORIGEM")  	  ) //"Requisição"
			oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODCLI",  oGrid:GetValue("A1_COD") 				  )
			oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODLOJ",  oGrid:GetValue("A1_LOJA") 				  )
			oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_CODAGE",  oGrid:GetValue("GQW_CODAGE")   		  )
			oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_DATEMI",  oGrid:GetValue("GIC_DTVEND")  			  )
			If GQW->(FieldPos("GQW_COMPET")) > 0
				oMdlGQW:GetModel('FIELDGQW'):SetValue("GQW_COMPET",  AnoMes(oGrid:GetValue("GIC_DTVEND"))  )
			Endif
			
			oMdlGQW:GetModel('GRIDGIC'):SetValue("GIC_CODIGO",  oGrid:GetValue("GIC_CODIGO")  )

		ENDIF

	Endif
	
	(cAliasQry)->(DBCloseArea())

	If 	lRet .AND. lConf

		oMdlGQW:GetModel('FIELDGQW'):LoadValue("GQW_CONFER", "1")
		oMdlGQW:GetModel('FIELDGQW'):LoadValue("GQW_CONFCH", "2")

	EndIF


	If lRet
		lRet := oMdlGQW:VldData() .And. oMdlGQW:CommitData()
	Endif

	

	If oMdlGQW:IsActive()
		oMdlGQW:DeActivate()
	Endif


Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveButton()
Insere botão para salvar os dados da grid
  
@author	João Pires
@since		11/03/2026
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function SaveButton( oPanel )

	//-- Insere botao no objeto oPanel
	@ 23, 400 Button STR0077 	Size 40, 15 Message STR0077		Pixel; // "Salvar"
		Action  (GA283DSave()) of oPanel 

Return
