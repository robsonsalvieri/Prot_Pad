#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GFEA029BLOT()
	FWExecView('', 'VIEWDEF.GFEA029A', MODEL_OPERATION_INSERT, , {|| .T. }) //executado para refazer a view - reload da estrutura de campos
Return

Static Function ModelDef()
	Local oModel        := Nil
	Local oStruGUN      := Nil
	Local oStruGrdGUN   := Nil
	  
    oStruGUN      := FwFormStruct( 1, "GUN", ) // , {|cCampo|  ALLTRIM(cCampo) $ "" } )
    oStruGrdGUN   := FWFormStruct( 1, 'GUN', )
    
    oModel := MpFormModel():New( "GFEA029A",/*bPre*/ ,  , {|oModel| SaveModel(oModel)} , /*bCancel*/ )
    oModel:SetDescription( "Frete Referência via Lote" )  //Frete Referência via Lote
    
    oStruGrdGUN:SetProperty("GUN_CODTAB" , MODEL_FIELD_OBRIGAT, .F.)
    oStruGrdGUN:SetProperty("GUN_TPTAB"  , MODEL_FIELD_OBRIGAT, .F.)
    oStruGrdGUN:SetProperty("GUN_DATDE"  , MODEL_FIELD_OBRIGAT, .F.)
    oStruGrdGUN:SetProperty("GUN_DATATE" , MODEL_FIELD_OBRIGAT, .F.)
    
    oStruGrdGUN:SetProperty("GUN_UMPESO" , MODEL_FIELD_WHEN, {||.T.}) 
    
    oStruGUN:SetProperty("GUN_TPREF"  , MODEL_FIELD_WHEN, {||.T.})
    oStruGUN:SetProperty("GUN_SOLMOD" , MODEL_FIELD_WHEN, {||.T.})
       
    
    oModel:AddFields( "GFEA029A_GUN", , oStruGUN,  ,/*bPost*/ , /*bLoad*/   )
    oModel:AddGrid ( 'MODEL_GRID', 'GFEA029A_GUN', oStruGrdGUN, {|| .T.}, {|| .T.}, {|| .T.}, , ) 
    
    oModel:SetPrimaryKey({"GUN_CODTAB"})
    
Return oModel
//----------------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oStruGUN    	:= nil 
	Local oStruGrdGUN 	:= nil
	Local oView    		:= FwFormView():New() // Instancia o modelo de dados
	Local oModel   		:= FwLoadModel( "GFEA029A" )
	// Array responsável por identificar os campos que serão exibidos em tela
	Local aCmpGrdRef 	:= {'GUN_DUPSEN', 'GUN_PRIOR', 'GUN_CDGRP', 'GUN_DSGRP', 'GUN_CDTRP', 'GUN_NMTRP', 'GUN_MODAL', 'GUN_FRTPES',;
	 						'GUN_PERIMP', 'GUN_EMAIL', 'GUN_TPPRAZ', 'GUN_PRAZO', 'GUN_DMEST', 'GUN_UMPESO', 'GUN_IMPINC'}
	Local aCmpPriRef 	:= {'GUN_DATDE', 'GUN_DATATE', 'GUN_CDTPOP', 'GUN_DSTPOP', 'GUN_CDTPVC', 'GUN_DSTPVC', 'GUN_CDCLFR', 'GUN_DSCLFR',;
							'GUN_NRCIOR', 'GUN_NRREOR', 'GUN_CDREM', 'GUN_NRCIDS', 'GUN_NRREDS', 'GUN_CDDEST',;
							'GUN_INFRTO', 'GUN_INFRTD', 'GUN_TPREF', 'GUN_SOLMOD'}
	Local nX			:= 0
	
	oView:SetModel( oModel )
  
	oStruGUN      := FwFormStruct( 2, "GUN", ) //, {|cCampo|  ALLTRIM(cCampo) $ "" } )
	oStruGrdGUN   := FWFormStruct( 2, 'GUN', )
  
	// Realiza a leitura da estrutura do model e retira os campos que não estão definidos no array base
	For nX := Len(oStruGrdGUN:aFields) To 1 STEP -1
		If ASCAN(aCmpGrdRef,oStruGrdGUN:aFields[nX][1]) == 0
			oStruGrdGUN:RemoveField(oStruGrdGUN:aFields[nX][1])
		EndIf		
	Next
	
	// Realiza a leitura da estrutura do model e retira os campos que não estão definidos no array base
	For nX := Len(oStruGUN:aFields) To 1 STEP -1
		If ASCAN(aCmpPriRef,oStruGUN:aFields[nX][1]) == 0
			oStruGUN:RemoveField(oStruGUN:aFields[nX][1])
		EndIf		
	Next
  
	oView:AddGrid( 'VIEW_GRID', oStruGrdGUN, 'MODEL_GRID' )   
  
	oView:AddField( 'VIEW_GUN',  oStruGUN,   'GFEA029A_GUN' )
	oView:CreateHorizontalBox( 'TELA', 60 )
	oView:CreateHorizontalBox( 'GRID', 40 )   
	oView:SetOwnerView( 'VIEW_GUN', 'TELA' )
	oView:SetOwnerView( 'VIEW_GRID', 'GRID' )
	
	oStruGUN:AddGroup("GrpFrt" , "Frete Referência em Lote", "1", 2)
	
	oStruGUN:SetProperty("GUN_DATDE" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_DATATE" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_CDTPOP" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_DSTPOP" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_CDTPVC" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_DSTPVC" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_CDCLFR" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_DSCLFR" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_NRCIOR" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_NRREOR" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_CDREM" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_NRCIDS" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_NRREDS" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_CDDEST" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_INFRTO" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_INFRTD" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_TPREF" 	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	oStruGUN:SetProperty("GUN_SOLMOD"	, MVC_VIEW_GROUP_NUMBER, "GrpFrt")
	
	oView:SetDescription("Cotação")
Return oView

Static Function SaveModel(oModel)
	Local oModelGUN   	:= oModel:GetModel("GFEA029A_GUN")
	Local oModelGrGUN 	:= oModel:GetModel("MODEL_GRID")
	Local nX          	:= 0
	Local cFilBkp     	:= ""
	Local aArea       	:= GetArea()
	Local oValPrazos  	:= GFEValidaPrazos():New()
	Local cUsrName		:= UsrRetName(RetCodUsr())

	For nX = 1 To oModelGrGUN:Length()
		oModelGrGUN:Goline(nX)

        cFilBkp := xFilial("GUN")
        
        // "Seta" os dados necessários para execução do método de validação
		oValPrazos:setDataDe(oModelGUN:GetValue("GUN_DATDE"))
		oValPrazos:setDataAte(oModelGUN:GetValue("GUN_DATATE"))
		oValPrazos:setCdRem(oModelGUN:GetValue("GUN_CDREM "))
		oValPrazos:setNrCiOr(oModelGUN:GetValue("GUN_NRCIOR"))
		oValPrazos:setNrReOr(oModelGUN:GetValue("GUN_NRREOR"))
		oValPrazos:setCdDest(oModelGUN:GetValue("GUN_CDDEST"))
		oValPrazos:setNrCiDs(oModelGUN:GetValue("GUN_NRCIDS"))
		oValPrazos:setNrReDs(oModelGUN:GetValue("GUN_NRREDS"))
		oValPrazos:setTpTab("4")
		If GFXCP12123("GUN_TPREF")
			oValPrazos:setTpRef(oModelGUN:GetValue("GUN_TPREF"))
		EndIf
		If GFXCP12123("GUN_SOLMOD")
			oValPrazos:setSolMod(oModelGUN:GetValue("GUN_SOLMOD"))
		EndIf
		oValPrazos:setCdTrp(oModelGrGUN:GetValue("GUN_CDTRP"))
		
		// Executa o método de validação
		oValPrazos:Validar()
		
		// Verificado a situação após a execução
		If oValPrazos:getStatus() == .F.
			// Busca o retorno da execução do método
			Help( ,, 'HELP',, oValPrazos:getMensagem(), 1, 0,)
			oValPrazos:Destroy(oValPrazos)
			Return .F.
		EndIf

        RecLock("GUN",.T.)
	        GUN->GUN_FILIAL   := cFilBkp
	        GUN->GUN_CODTAB   := GETSXENUM("GUN","GUN_CODTAB")
	        GUN->GUN_TPTAB    := "4"
		    GUN->GUN_DUPSEN   := oModelGrGUN:GetValue("GUN_DUPSEN")
		    GUN->GUN_DATDE    := oModelGUN:GetValue("GUN_DATDE")
	        GUN->GUN_DATATE   := oModelGUN:GetValue("GUN_DATATE")
	        GUN->GUN_NRCIOR   := oModelGUN:GetValue("GUN_NRCIOR")
	        GUN->GUN_NRREOR   := oModelGUN:GetValue("GUN_NRREOR")
	        GUN->GUN_CDREM    := oModelGUN:GetValue("GUN_CDREM ")
	        GUN->GUN_NRCIDS   := oModelGUN:GetValue("GUN_NRCIDS")
	        GUN->GUN_NRREDS   := oModelGUN:GetValue("GUN_NRREDS")
	        GUN->GUN_CDDEST   := oModelGUN:GetValue("GUN_CDDEST")
	        GUN->GUN_CDTPOP   := oModelGUN:GetValue("GUN_CDTPOP")
	        GUN->GUN_CDTPVC   := oModelGUN:GetValue("GUN_CDTPVC")
	        GUN->GUN_CDGRP    := oModelGrGUN:GetValue("GUN_CDGRP")
	        GUN->GUN_CDTRP    := oModelGrGUN:GetValue("GUN_CDTRP")
	        GUN->GUN_MODAL    := oModelGrGUN:GetValue("GUN_MODAL")
	        GUN->GUN_TPPRAZ   := oModelGrGUN:GetValue("GUN_TPPRAZ")
	        GUN->GUN_PRAZO    := oModelGrGUN:GetValue("GUN_PRAZO")
	        GUN->GUN_DMEST    := oModelGrGUN:GetValue("GUN_DMEST")
	        GUN->GUN_PRIOR    := oModelGrGUN:GetValue("GUN_PRIOR")
	        GUN->GUN_CDCLFR   := oModelGUN:GetValue("GUN_CDCLFR")
	        GUN->GUN_FRTPES   := oModelGrGUN:GetValue("GUN_FRTPES")
	        GUN->GUN_PERIMP   := oModelGrGUN:GetValue("GUN_PERIMP")
	        GUN->GUN_ENVIAE   := oModelGrGUN:GetValue("GUN_ENVIAE")
	        GUN->GUN_EMAIL    := oModelGrGUN:GetValue("GUN_EMAIL")
	        GUN->GUN_PERIOD   := oModelGrGUN:GetValue("GUN_PERIOD")
	        GUN->GUN_STATUS   := oModelGrGUN:GetValue("GUN_STATUS")    
	        If GFXCP12123("GUN_TPREF")
	        	GUN->GUN_TPREF	:= oModelGUN:GetValue("GUN_TPREF")
	        EndIf
	        If GFXCP12123("GUN_SOLMOD")
	        	GUN->GUN_SOLMOD	:= oModelGUN:GetValue("GUN_SOLMOD")
	        EndIf
	        If GFXCP12123("GUN_CRIUSU")
	        	GUN->GUN_CRIUSU := cUsrName
	        EndIf
	        If GFXCP12123("GUN_CRIDAT")
	        	GUN->GUN_CRIDAT := Date()
	        EndIf
	        If GFXCP12123("GUN_IMPINC")
	        	GUN->GUN_IMPINC := oModelGrGUN:GetValue("GUN_IMPINC")
	        EndIf
	        
	        ConfirmSX8()		
		GUN->(MsUnLock())
    Next
       
    oValPrazos:Destroy(oValPrazos)
    
    RestArea(aArea)
Return .T.
