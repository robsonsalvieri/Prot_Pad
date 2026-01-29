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
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruGrd  := FwFormModelStruct():New()
Local bLoad		:= {|oModel| GA283DLoad(oModel)}
Local bCommit   := {|oModel| GA283DCommit(oModel)}

oModel := MPFormModel():New("GTPA283D",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStruct(oStruCab, oStruGrd)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

oModel:SetDescription(STR0002)	//'Seleção'
oModel:GetModel("HEADER"):SetDescription(STR0003) //"Filtro"
oModel:GetModel("GRID"):SetDescription(STR0004)  //"Requisições"
oModel:SetPrimaryKey({})

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
Local oStruGrd	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0004)	//"Requisições"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid('VIEW_GRID' ,oStruGrd,'GRID')

oView:CreateHorizontalBox('HEADER', 35)
oView:CreateHorizontalBox('GRID', 65)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID','GRID')

oView:EnableTitleView("VIEW_HEADER", STR0003)	//"Filtro"
oView:EnableTitleView("VIEW_GRID", STR0004) //"Requisições"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0005, "", {|oView| FwMsgRun(,{|| GA283DPesq(oView)},,STR0006)},/*cToolTip*/ ,VK_F5/*nShortCut*/) //"Pesquisar" //"Selecionando registro(s)..."

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
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
Static Function SetMdlStru(oStruCab, oStruGrd)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"

		oStruCab:AddField(STR0007   ,STR0007	,"DATAINI" 	    ,"D", 8, 0, {|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Data De"
		oStruCab:AddField(STR0008   ,STR0008    ,"DATAFIM" 	    ,"D", 8, 0, bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Data Até"

		oStruCab:AddField(STR0009	,STR0009   	,"AGENCIAINI"	,"C", TamSx3('GQW_CODAGE')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agência De"
		oStruCab:AddField(STR0010   ,STR0010  	,"AGENCIAFIM"	,"C", TamSx3('GQW_CODAGE')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Agência Até"

        oStruCab:AddField(STR0011  	,STR0011   	,"CLIENTEINI"	,"C", TamSx3('GQW_CODCLI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Cliente De"
		oStruCab:AddField(STR0012   ,STR0012    ,"LOJAINI"	    ,"C", TamSx3('GQW_CODLOJ')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Loja De"

        oStruCab:AddField(STR0013 	,STR0013  	,"CLIENTEFIM"	,"C", TamSx3('GQW_CODCLI')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Cliente Até"  		
		oStruCab:AddField(STR0014   ,STR0014    ,"LOJAFIM"	    ,"C", TamSx3('GQW_CODLOJ')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Loja Até" 		

        oStruCab:AddTrigger("DATAINI"   ,"DATAINI"	 	, { || .T. }, bFldTrig)
        oStruCab:AddTrigger("AGENCIAINI","AGENCIAINI" 	, { || .T. }, bFldTrig)
        oStruCab:AddTrigger("CLIENTEINI","CLIENTEINI" 	, { || .T. }, bFldTrig)

	Endif	

	If ValType(oStruGrd) == "O"

		oStruGrd:AddField(STR0015 ,STR0015  ,"ORIGEM"	,"C",TamSx3('GQW_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Req.Origem"
		oStruGrd:AddField(STR0016 ,STR0016  ,"DESTINO"	,"C",TamSx3('GQW_CODIGO')[1],0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Req.Destino" 	
		oStruGrd:AddField(STR0017 ,STR0017	,"ORIGINAL"	,"C",TamSx3('GQW_CODIGO')[1],0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //"Req.Original" 	
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
		oStruGrd:AddField(STR0032 ,STR0032  ,"GIC_CODIGO","C",TamSx3('GIC_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)  //'Código'	
		oStruGrd:AddField(STR0033 ,STR0033  ,"A1_COD","C",TamSx3('A1_COD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	//'Cód.Cliente'
		oStruGrd:AddField(STR0034 ,STR0034  ,"A1_LOJA","C",TamSx3('A1_LOJA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) //'Lj.'	

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
Static Function SetViewStru(oStruCab, oStruGrd)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("DATAINI" 	,"01",STR0007,STR0007,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data De"
		oStruCab:AddField("DATAFIM"		,"02",STR0008,STR0008,{""},"GET","",NIL,"",.T.,NIL,NIL,{},	NIL,NIL,.F.) // "Data Até"

		oStruCab:AddField("AGENCIAINI"	,"03",STR0009,STR0009,{""},"GET","",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Agência De"
		oStruCab:AddField("AGENCIAFIM"	,"04",STR0010,STR0010,{""},"GET","",NIL,"GI6",.T.,NIL,NIL,{},	NIL,NIL,.F.) //"Agência Até" 		

		oStruCab:AddField("CLIENTEINI"	,"05",STR0011,STR0011,{""},"GET","",NIL,"SA1",.T.,NIL,NIL,{},NIL,NIL,.F.)  //"Cliente De"
		oStruCab:AddField("LOJAINI" 	,"06",STR0012,STR0012,{""},"GET","",NIL,""   ,.T.,NIL,NIL,{},	NIL,NIL,.F.) //"Loja De"

		oStruCab:AddField("CLIENTEFIM"	,"07",STR0013,STR0013,{""},"GET","",NIL,"SA1",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Cliente Até"
		oStruCab:AddField("LOJAFIM"		,"08",STR0014,STR0014,{""},"GET","",NIL,"",.T.,NIL,NIL,{},	NIL,NIL,.F.) //"Loja Até"

	Endif
	
	If ValType(oStruGrd) == "O"

		oStruGrd:AddField("ORIGEM"	    ,"01",STR0015,STR0015,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Req.Origem"		
		oStruGrd:AddField("DESTINO"	    ,"02",STR0016,STR0016,{""},"GET","@!",NIL,"GQW",.T.,NIL,NIL,{},NIL,NIL,.F.)	//"Req.Destino" 		
		oStruGrd:AddField("ORIGINAL"	,"03",STR0017,STR0017,{""},"GET","@!",NIL,"GICREQ",.T.,NIL,NIL,{},NIL,NIL,.F.) //"Req.Original"		
		oStruGrd:AddField("GQW_CODAGE"	,"04",STR0018,STR0018,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Cód.Agência'			
		oStruGrd:AddField("GIC_NUMBPE"	,"05",STR0026,STR0026,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Nr.BPE'				
		oStruGrd:AddField("GIC_BILHET"	,"06",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Nr.Bilhete"			
		oStruGrd:AddField("GIC_DTVIAG"	,"07",STR0019,STR0019,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Dt.Viagem'			
        oStruGrd:AddField("GIC_DTVEND"	,"08",STR0020,STR0020,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Dt.Venda'			
		oStruGrd:AddField("GIC_VALTOT"	,"09",STR0021,STR0021,{""},"GET","@E 999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	//"Vlr.Total"
		oStruGrd:AddField("GIC_LOCORI"	,"10",STR0030,STR0030,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Loc.Origem" 			
		oStruGrd:AddField("GIC_LOCDES"	,"11",STR0031,STR0031,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Cód.Loc.Des."			
		oStruGrd:AddField("GIC_NOMEPA"	,"12",STR0022,STR0022,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Nome Passageiro'	
		oStruGrd:AddField("A1_NOME"	    ,"13",STR0023,STR0023,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Cliente'			
		oStruGrd:AddField("GIC_CHVBPE"	,"14",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Chave BPE" 			
		oStruGrd:AddField("GIC_LINHA"	,"15",STR0027,STR0027,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Cód.Linha"			
		oStruGrd:AddField("GIC_NLINHA"	,"16",STR0028,STR0028,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"Nome Linha"			
		oStruGrd:AddField("GIC_CCF"		,"17",STR0029,STR0029,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //"CCF"			
		oStruGrd:AddField("GIC_CODIGO"	,"18",STR0032,STR0032,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Código'		
		oStruGrd:AddField("A1_COD"		,"19",STR0033,STR0033,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Cód.Cliente'	
		oStruGrd:AddField("A1_LOJA"		,"20",STR0034,STR0034,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) //'Lj.'				

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
Local cLoja     := ""
Local cCodReq	:= ""
Local aDados    := {}
Do Case
	Case Empty(uNewValue)
		lRet := .T.
    
    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0035 // "Data final não pode ser menor que a data inicial"
            cMsgSol  := STR0036 // "Altere a data final"
        Endif

    Case cField == "AGENCIAINI" .Or. cField == "AGENCIAFIM"
        If !Empty(uNewValue) .And. Empty(GetAdvFval('GI6','GI6_CODIGO',xFilial('GI6')+uNewValue,1))
            lRet     := .F.
            cMsgErro := STR0037	//"Agência não localizado."
            cMsgSol  := STR0038 //"Informe agência cadastrada."
        Endif

    Case cField == "CLIENTEINI" .Or. cField == "CLIENTEFIM"
        If !Empty(uNewValue) 
			cLoja    := GetAdvFval('SA1','A1_LOJA',xFilial('SA1')+uNewValue,1)
			If Empty(cLoja)
            	lRet     := .F.
            	cMsgErro := STR0039	//"Cliente não localizado."
            	cMsgSol  := STR0040	//"Informe Cliente cadastrado."
			Else
				If cField == "CLIENTEINI" 
					oModel:GetModel('HEADER'):LoadValue('LOJAINI',cLoja)
				ElseIf cField == "CLIENTEFIM"
					oModel:GetModel('HEADER'):LoadValue('LOJAFIM',cLoja)
				EndIf 
			EndIf 				
        Endif
	Case cField == "DESTINO"
		lRet := Vazio() .Or. ExistCpo("GQW",uNewValue)	
		If lRet 
			If oModel:GetModel('GRID'):GetValue('ORIGEM') == uNewValue
				lRet     := .F.
            	cMsgErro := STR0041	//"Agência informada igual a ORIGEM."
            	cMsgSol  := STR0042	//"Informe agência diferente à da ORIGEM."
			EndIf
			If lRet 
				aDados := GetAdvFval("GQW",{'GQW_STATUS','GQW_CONFER'},xFilial("GQW")+uNewValue,1)
				If aDados[1] == '1' .Or. aDados[2] == '1'
					lRet     := .F.
					cMsgErro := STR0043	//"Cód. Requisição Conferida/Baixado não é permitido."
					cMsgSol  := STR0044	//"Informe outro código válido."
				EndIf  
			EndIf  	
			If lRet 
				aDados := GetAdvFval("GQW",{'GQW_CODLOT'},xFilial("GQW")+uNewValue,1)
				If !Empty(aDados[1])
					lRet     := .F.
					cMsgErro := I18n(STR0055, { aDados[1] } ) 	// "Cód. Requisição [#1] existe em Lotes de Requisição."
					cMsgSol  := STR0044	//"Informe outro código válido."
				EndIf  
			EndIf 							
		EndIf 	
	Case cField == "ORIGINAL"	
		cCodReq := GetAdvFval('GQW','GQW_CODIGO',xFilial('GQW')+uNewValue+oModel:GetModel('GRID'):GetValue('A1_COD')+oModel:GetModel('GRID'):GetValue('A1_LOJA'),5)
		If Empty(cCodReq)
			lRet     := .F.
			cMsgErro := STR0045	//"Requisição Original não localizada."
			cMsgSol  := STR0046	//"Informe requisição cadastrada."
		Else 
			If cCodReq == oModel:GetModel('GRID'):GetValue('ORIGEM') 
				lRet     := .F.
            	cMsgErro := STR0047	//"Agência informada igual a ORIGEM."
            	cMsgSol  := STR0048	//"Informe agência diferente à da ORIGEM."
			Else 
				oModel:GetModel('GRID'):LoadValue('DESTINO',cCodReq)
			EndIf 								
		EndIf 
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
	Case cField == 'AGENCIAINI'
	    oMdl:SetValue('AGENCIAFIM', uVal)
	Case cField == 'CLIENTEINI'
    	oMdl:SetValue('CLIENTEFIM', uVal)
	Case cField == 'LOJAINI'
    	oMdl:SetValue('LOJAFIM', uVal)
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
    oMdlCab := oModel:GetModel( 'HEADER' )
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
Local oMdlGrid    := oModel:GetModel( 'GRID' )
Local nX          := 0
Local aOrigem     := {}
Local aDestino    := {}
Local aAux		  := {}

For nX := 1 To oMdlGrid:Length()

	If !Empty(oMdlGrid:GetValue('DESTINO', nX) )
		aAux := {oMdlGrid:GetValue('GIC_CODIGO', nX)}
		NewAscanArray( @aOrigem	, aAux, oMdlGrid:GetValue('ORIGEM' , nX) )
		NewAscanArray( @aDestino, aAux, oMdlGrid:GetValue('DESTINO', nX) )
	Endif

Next

If Len(aOrigem) > 0
	FwMsgRun(,{|| GA283DTrnasf(aOrigem,aDestino)},,STR0049)	//"Transferindo requisições..."
EndIf 

GTPDestroy(aOrigem)
GTPDestroy(aDestino)

Return .T.

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
Local cAliasGIC		:= GetNextAlias()
Local oMdlHead		:= oView:GetModel():GetModel('HEADER')
Local oMdlGrid		:= oView:GetModel():GetModel('GRID')
Local cDataIni		:= Dtos(oMdlHead:GetValue('DATAINI'))
Local cDataFim		:= Dtos(oMdlHead:GetValue('DATAFIM'))
Local cAgencDe 		:= oMdlHead:GetValue('AGENCIAINI')
Local cAgencAte		:= oMdlHead:GetValue('AGENCIAFIM')
Local cCliIni		:= oMdlHead:GetValue('CLIENTEINI')
Local cCliFim		:= oMdlHead:GetValue('CLIENTEFIM')
Local cLjIni		:= oMdlHead:GetValue('LOJAINI')
Local cLjFim		:= oMdlHead:GetValue('LOJAFIM')
Local cDescLin		:= ""
Local cQuery		:= ""

If Empty(cDataIni) .Or. Empty(cDataFim)
	FwAlertHelp(STR0050, STR0051,  STR0052) //'Período não informado', 'Informe as datas inicial e final para realizar a pesquisa', 'Atenção'
	Return
Endif

If !Empty(cDataIni) .And. !Empty(cDataFim)
	cQuery += " AND GQW.GQW_DATEMI BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
Endif

If !Empty(cAgencAte)
	cQuery += " AND GQW.GQW_CODAGE BETWEEN '" + cAgencDe + "' AND '" + cAgencAte + "' "
Endif

If !Empty(cCliFim) 
	cQuery += " AND GQW.GQW_CODCLI BETWEEN '" + cCliIni + "' AND '" + cCliFim + "' "
    If !Empty(cLjFim) 
        cQuery += " AND GQW.GQW_CODLOJ BETWEEN '" + cLjIni + "' AND '" + cLjFim + "' "
    Endif
Endif

cQuery += "AND GQW.GQW_STATUS = '2' AND GQW.GQW_CONFER = '2' AND GQW.GQW_CODLOT = ' '"

cQuery := "%" + cQuery + "%"

oMdlGrid:ClearData()

BeginSql  Alias cAliasGIC

	SELECT 
        GQW_CODIGO,
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
			
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"ORIGEM"})[1]       ,(cAliasGIC)->GQW_CODIGO)
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

		Endif
			
		(cAliasGIC)->(dbSkip())

	End

Else 
    FwAlertHelp(STR0053, STR0054, STR0052) //"Não foram encontrados bilhetes com os parâmetros informados","Altere os parâmetros","Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasGIC)->(dbCloseArea())

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
Static Function GA283DTrnasf(aOrigem,aDestino)
	Local nSel        := 0
	Local nItem       := 0
	Local nGrid       := 0
	Local nRequisicao := 0
	Local oMdlGQW     := FwLoadModel("GTPA283")
	Local cOrigReq    := ""
	Local cDestReq    := ""
	Local cBilhete    := ""
	Local lRet
	Local lContinua   := .T.
	Local aError      := {}
	Local lIsActive   := .F.

	DBSelectArea('GQW')
	GQW->(DbSetOrder(1))

	Begin Transaction 

		// Remover bilhete da Requisição atual
		For nSel:=1 To Len( aOrigem )

			cOrigReq := aOrigem[nSel][1]

			If GQW->(DbSeek(xFilial('GQW')+cOrigReq))

				oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
				oMdlGQW:Activate()		
				lIsActive := oMdlGQW:IsActive()
				// Se a quantidade da GRID for igual a da Transferencia, DELETAR a Requisição
				nGrid     	:= oMdlGQW:GetModel( 'GRIDGIC' ):Length()
				nRequisicao := Len(aOrigem[nSel][2])

				If nGrid == 1 .And. oMdlGQW:GetModel('GRIDGIC'):IsEmpty() .Or. (nGrid == nRequisicao)

					oMdlGQW:DeActivate()
					oMdlGQW:SetOperation(MODEL_OPERATION_DELETE)
					oMdlGQW:Activate()		

				Else 

					For nItem:=1 To nRequisicao

						cBilhete:= aOrigem[nSel][2][nItem]
							
						If oMdlGQW:IsActive() .AND. oMdlGQW:GetModel('GRIDGIC'):SeekLine({{'GIC_CODIGO',cBilhete}}) 
							oMdlGQW:GetModel('GRIDGIC'):DeleteLine() 
						EndIf 

					Next nItem 

				EndIf 

				lRet := oMdlGQW:VldData() .And. oMdlGQW:CommitData()
				If !lRet 
					lContinua := .F.
					aError := oMdlGQW:GetErrorMessage()
					DisarmTransaction()
					Exit				
				EndIf 

				oMdlGQW:DeActivate()

			EndIf 

		Next nSel							

		// Atualizar bilhete da Requisição Destino
		If lContinua

			For nSel:=1 To Len( aDestino )

				cDestReq := aDestino[nSel][1]

				If GQW->(DbSeek(xFilial('GQW')+cDestReq))

					oMdlGQW:SetOperation(MODEL_OPERATION_UPDATE)
					oMdlGQW:Activate()		
					lIsActive := oMdlGQW:IsActive()

					For nItem:=1 To Len(aDestino[nSel][2])

						cBilhete:= aDestino[nSel][2][nItem]

						If lIsActive .AND. !( oMdlGQW:GetModel('GRIDGIC'):SeekLine({{'GIC_CODIGO',cBilhete}}) )
							oMdlGQW:GetModel('GRIDGIC'):AddLine(.T.)
						EndIf 
						
						oMdlGQW:GetModel('GRIDGIC'):SetValue("GIC_CODIGO",  cBilhete  )

					Next nItem 

					lRet := oMdlGQW:VldData() .And. oMdlGQW:CommitData()
					If !lRet 
						aError := oMdlGQW:GetErrorMessage()
						lContinua := .F.
					EndIf 

					If lIsActive
						oMdlGQW:DeActivate()
					EndIf 

				Endif

			Next nSel 

		EndIf 

	End Transaction

	GTPDestroy(oMdlGQW)

	If !Empty(aError)
		JurShowErro(aError)
	EndIF 

Return 

/*/{Protheus.doc} NewAscanArray
Ordena Vetor por requisição
@author José Carlos
@since 03/12/2025
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type Static function
/*/
Static Function NewAscanArray( aVetor, aAux, cRequisicao )
    Local nX   := 0
    LocaL nPos := 0

    If (nPos := AsCan( aVetor,{|z| z[1] == cRequisicao} )) == 0
		Aadd( aVetor,{cRequisicao, {} })
		nPos := Len(aVetor)
	EndIf 

    For nX:=1 To Len(aAux)
        Aadd( aVetor[nPos,2],aAux[nX])    
    Next nX 

Return
