#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPU013.CH"
 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU013
Prestação de Contas

@type function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/21/2024
/*/
//-------------------------------------------------------------------
Function GTPU013()

    Local oBrowse as object    

    oBrowse := FWMBrowse():New()
    oBrowse:SetDescription(STR0001) //"Prestação de Contas"
    oBrowse:SetAlias("H7I")
    oBrowse:SetLocate()         
    oBrowse:Activate()
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/21/2024
@return aRotina, Opções de Menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

    Local aRotina := {}
    
    aadd(aRotina, {STR0024 , "VIEWDEF.GTPU013", 0, 2, 0, NIL}) //"Visualizar"
    aadd(aRotina, {STR0025 , "GU013Inclu()"   , 0, 3, 0, NIL}) //"Incluir"    
    aadd(aRotina, {STR0027 , "GU013Confe()"   , 0, 4, 0, NIL}) //"Conferir"
    aadd(aRotina, {STR0026 , "GU013Alter()"   , 0, 4, 0, NIL}) //"Alterar" 
    aadd(aRotina, {STR0051 , "GU013Reabr()"   , 0, 4, 0, NIL}) //"Reabrir"
    aadd(aRotina, {STR0028 , "GU013Exclu()"   , 0, 5, 0, NIL}) //"Excluir"
    

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/21/2024
@return oModel, Modelo
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

    Local oModel     := Nil
    Local oStrSup    := FWFormStruct( 1, 'H7I' )
    Local oStrGer    := FWFormStruct( 1, 'H7J' )
    Local oStrPag    := FWFormStruct( 1, 'H7L' )
    Local oStrEst    := FWFormStruct( 1, 'H7K' )
    Local bPosValid  := {|oModel| PosValid(oModel)}
    Local bCommit    := {|oModel| GTPU13Com(oModel)}
    //Local bLinePost  := {|oModel| VldLinePost(oModel)}
    Local bWhen      := {|oMdl, cField, uVal| GTP013WHEN(oMdl, cField, uVal)}
    Local bFieldVld  := {|oMdl, cField, uNewValue, uOldValue | FieldValid(oMdl, cField, uNewValue, uOldValue)}
    Local bFieldTrig := {|oMdl, cField, uVal| FieldTrigger(oMdl, cField, uVal)}
    Local lNewFil    := H7I->(FieldPos("H7I_MATMOT")) > 0 .AND. H7J->(FieldPos("H7J_CODLIN")) > 0

    oStrSup:AddTrigger("H7I_MOTORI", "H7I_MOTORI", {||.T.}, bFieldTrig)
    oStrEst:AddTrigger("H7K_ROLSAI", "H7K_ROLSAI", {||.T.}, bFieldTrig)
    oStrGer:AddTrigger("H7J_VEICUL", "H7J_VEICUL", {||.T.}, bFieldTrig)
    oStrGer:AddTrigger("H7J_CODH6V", "H7J_CODH6V", {||.T.}, bFieldTrig)
    oStrSup:AddTrigger("H7I_PGCOFR", "H7I_PGCOFR", {||.T.}, bFieldTrig)
    oStrSup:AddTrigger("H7I_PGDINH", "H7I_PGDINH", {||.T.}, bFieldTrig)
    oStrGer:AddTrigger("H7J_ESCALA", "H7J_ESCALA", {||.T.}, bFieldTrig)
    oStrGer:AddTrigger("H7J_TVIIDA", "H7J_TVIIDA", {||.T.}, bFieldTrig)
    oStrGer:AddTrigger("H7J_TVVOLT", "H7J_TVVOLT", {||.T.}, bFieldTrig)
    oStrPag:AddTrigger("H7L_NUMPAS", "H7L_NUMPAS", {||.T.}, bFieldTrig)
     
    if lNewFil
        oStrSup:AddTrigger("H7I_MATMOT", "H7I_MATMOT", {||.T.}, bFieldTrig)
        oStrGer:AddTrigger("H7J_CODLIN", "H7J_CODLIN", {||.T.}, bFieldTrig)
    endif
    
    oModel	:= MPFormModel():New('GTPU013', , bPosValid, bCommit , )

    oModel:AddFields("H7IMASTER", NIL, oStrSup)

    oModel:addGrid('H7JDETAIL', 'H7IMASTER', oStrGer,,,,,)
    oModel:addGrid('H7LDETAIL', 'H7JDETAIL', oStrPag,,,,,)
    oModel:addGrid('H7KDETAIL', 'H7JDETAIL', oStrEst,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)    

    oModel:SetRelation("H7JDETAIL", {{"H7J_FILIAL", "XFILIAL('H7J')"}, {"H7J_CODIGO", "H7I_CODIGO"}}, H7J->(IndexKey(1)))
    oModel:SetRelation("H7LDETAIL", {{"H7L_FILIAL", "XFILIAL('H7L')"}, {"H7L_CODIGO", "H7I_CODIGO"}, {"H7L_SERVIC", "H7J_SERVIC"}}, H7L->(IndexKey(1)))
    oModel:SetRelation("H7KDETAIL", {{"H7K_FILIAL", "XFILIAL('H7K')"}, {"H7K_CODIGO", "H7I_CODIGO"}, {"H7K_SERVIC", "H7J_SERVIC"}}, H7K->(IndexKey(1))) 

    oModel:GetModel( 'H7JDETAIL' ):SetUniqueLine( { 'H7J_SERVIC', 'H7J_ESCALA' } )

    oModel:GetModel( 'H7LDETAIL' ):SetUniqueLine( { 'H7L_TPAGAM' } )
    oModel:GetModel( 'H7LDETAIL' ):SetOptional(.T.)     

    oModel:GetModel( 'H7KDETAIL' ):SetUniqueLine( { 'H7K_SENTID', 'H7K_HRSAIP' } )
    oModel:GetModel( 'H7KDETAIL' ):SetOptional(.T.)

    oModel:SetDescription( STR0001 ) //"Prestação de Contas"   
   
    oModel:AddCalc('TOT_VALO', 'H7JDETAIL', 'H7LDETAIL', 'H7L_VLRTOT', 'H7J_VLRTOT', 'FORMULA', { | |  .T. },,'Total Serviço'    ,{|oModel| AtuTotal(oModel, "H7L_VLRTOT")})     
    oModel:AddCalc('TOT_PASS', 'H7JDETAIL', 'H7LDETAIL', 'H7L_NUMPAS', 'H7J_TOTPAS', 'FORMULA', { | |  .T. },,'Total Passageiros',{|oModel, cTipo| PasTotal(oModel, "1")})
    oModel:AddCalc('TOT_PASS', 'H7JDETAIL', 'H7LDETAIL', 'H7L_VLRUNI', 'H7J_TOTPAG', 'FORMULA', { | |  .T. },,'Total Passageiros',{|oModel, cTipo| PasTotal(oModel, "2")})
    oModel:AddCalc('TOT_PASS', 'H7JDETAIL', 'H7LDETAIL', 'H7L_NUMPAS', 'H7J_PEDAGI', 'FORMULA', { | |  .T. },,'Total Passageiros',{|oModel, cTipo| PasTotal(oModel, "3")})
    oModel:AddCalc('VIEW_TOT', 'H7IMASTER', 'H7JDETAIL', 'H7J_VLRTOT', 'H7I_VLRTOT', 'FORMULA', { | |  .T. },,'Valor total'      ,{|oModel| AtuTotal(oModel, "H7J_VLRTOT")})  
    oModel:AddCalc('VIEW_TOT', 'H7IMASTER', 'H7LDETAIL', 'H7L_VLRTOT', 'H7J_TOTDIN', 'FORMULA', { | |  .T. },,'Total Dinheiro'   ,{|oModel| AtuTotal(oModel, "H7J_TOTDIN")}) 
    oModel:AddCalc('VIEW_TOT', 'H7IMASTER', 'H7JDETAIL', 'H7J_TOTDIN', 'H7I_TOTDIN', 'FORMULA', { | |  .T. },,'Total Dinheiro'   ,{|oModel| AtuTotal(oModel, "H7I_TOTDIN")}) 
    oModel:AddCalc('VIEW_TOT', 'H7IMASTER', 'H7JDETAIL', 'H7J_TOTDIN', 'H7I_VLRDEV', 'FORMULA', { | |  .T. },,'Total Devido'     ,{|oModel| AtuTotal(oModel, "H7I_VLRDEV")}) 
    oModel:AddCalc('VIEW_TOT', 'H7IMASTER', 'H7JDETAIL', 'H7J_PEDAGI', 'H7I_PEDAGI', 'FORMULA', { | |  .T. },,'Total Devido'     ,{|oModel| AtuTotal(oModel, "H7J_PEDAGI")})   
            
    oStrSup:SetProperty("H7I_DATREF", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT})          
    oStrSup:SetProperty("H7I_MOTORI", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT})
    oStrSup:SetProperty("H7I_CARMOT", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT})
    oStrSup:SetProperty("H7I_COBRAD", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT})
    oStrSup:SetProperty("H7I_CARCOB", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT})
    oStrSup:SetProperty("H7I_DTSERV", MODEL_FIELD_WHEN, bWhen) 
    oStrSup:SetProperty("H7I_COLETA", MODEL_FIELD_WHEN, bWhen)

    oStrGer:SetProperty("H7J_SERVIC", MODEL_FIELD_WHEN, bWhen)   
    oStrGer:SetProperty("H7J_ESCALA", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_DESCAL", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_CODH6V", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_PREFLI", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_DESCLI", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_VEICUL", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_TURNO" , MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_DATAIS", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_DATATS", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_HRINIS", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_HRTERS", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_TOTPAS", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_TOTPAG", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_TOTGRA", MODEL_FIELD_WHEN, bWhen)  
    oStrGer:SetProperty("H7J_VLRTOT", MODEL_FIELD_WHEN, bWhen) 
    oStrGer:SetProperty("H7J_TOTVIA", MODEL_FIELD_WHEN, .F.  ) 

    oStrPag:SetProperty("H7L_TPAGAM", MODEL_FIELD_WHEN, bWhen) 
    oStrPag:SetProperty("H7L_NUMPAS", MODEL_FIELD_WHEN, bWhen) 
    oStrPag:SetProperty("H7L_VLRUNI", MODEL_FIELD_WHEN, bWhen) 
    oStrPag:SetProperty("H7L_CODH6S", MODEL_FIELD_WHEN, bWhen)     
    
    oStrSup:SetProperty('H7I_MOTORI', MODEL_FIELD_VALID, bFieldVld)
    oStrSup:SetProperty('H7I_DATREF', MODEL_FIELD_VALID, bFieldVld)
    oStrSup:SetProperty('H7I_DTSERV', MODEL_FIELD_VALID, bFieldVld)
    oStrSup:SetProperty('H7I_COBRAD', MODEL_FIELD_VALID, bFieldVld)
    oStrSup:SetProperty('H7I_LOCARR', MODEL_FIELD_VALID, bFieldVld)
    oStrGer:SetProperty('H7J_SERVIC', MODEL_FIELD_VALID, bFieldVld)
    oStrGer:SetProperty('H7J_DATAIS', MODEL_FIELD_VALID, bFieldVld)
    oStrGer:SetProperty('H7J_DATATS', MODEL_FIELD_VALID, bFieldVld)
    oStrGer:SetProperty('H7J_ESCALA', MODEL_FIELD_VALID, bFieldVld)    
    oStrPag:SetProperty('H7L_TPAGAM', MODEL_FIELD_VALID, bFieldVld)
    oStrPag:SetProperty('H7L_CODH6S', MODEL_FIELD_VALID, bFieldVld)
    If lNewFil
        oStrGer:SetProperty("H7J_CODLIN", MODEL_FIELD_VALID, bFieldVld  ) 
    Endif
   
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/21/2024
@return oView, View
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

    Local oView      := FWFormView():New()
    Local oModel     := FwLoadModel( 'GTPU013' )
    Local oStrSuperi := {} 
    Local oStrGerais := {}
    Local oStrPagame := FWFormStruct(2, "H7L", {|x| !AllTrim( x ) + "|" $ 'H7L_PEDAGI|' })
    Local oStrEstati := FWFormStruct(2, "H7K")
    Local oStrTotais := FwFormStruct(2, 'H7I', {|x|  AllTrim( x ) + "|" $ 'H7I_VLRTOT|H7I_TOTDIN|H7I_VLRDEV|H7I_PGCOFR|H7I_PGDINH|H7I_PEDAGI|' } )
    Local cCmpFil    := ""
    Local lNewFil    := H7I->(FieldPos("H7I_MATMOT")) > 0 .AND. H7J->(FieldPos("H7J_CODLIN")) > 0

    // Campos para o cabeçalho da prestação
    cCmpFil := 'H7I_CODIGO|H7I_DATREF|H7I_COLETA|H7I_STATUS|H7I_MOTORI|H7I_NOMOTO|H7I_CARMOT|H7I_COBRAD|H7I_NOMCOB|H7I_CARCOB|H7I_LOCARR|H7I_DESLOC|H7I_CONFER|H7I_NOMCON|H7I_DTSERV|H7I_NOMINC|'
    cCmpFil += IIF(lNewFil,'H7I_MATMOT|','')
	oStrSuperi := FwFormStruct( 2, 'H7I', {|x| AllTrim( x ) + "|" $ cCmpFil } )

    // Campos para o grid de serviços
    cCmpFil := 'H7J_SERVIC|H7J_ESCALA|H7J_DESCAL|H7J_CODH6V|H7J_PREFLI|H7J_DESCLI|H7J_VEICUL|H7J_TURNO|H7J_DATAIS|H7J_DATATS|H7J_HRINIS|H7J_HRTERS|H7J_TOTPAS|H7J_TOTPAG|H7J_TOTGRA|H7J_TOTVIA|H7J_TVIIDA|H7J_TVVOLT|H7J_VLRTOT|H7J_HRRINI|H7J_HRRFIN|'
    cCmpFil += IIF(lNewFil,'H7J_CODLIN|','')
    oStrGerais := FWFormStruct(2, "H7J", {|x| AllTrim( x ) + "|" $  cCmpFil})

    IF lNewFil   
        oStrSuperi:SetProperty("H7I_MATMOT" , MVC_VIEW_ORDEM,  '06')
        oStrGerais:SetProperty("H7J_CODLIN" , MVC_VIEW_ORDEM,  '04')
        oStrGerais:SetProperty("H7J_CODH6V" , MVC_VIEW_ORDEM,  '05')
        oStrGerais:SetProperty("H7J_PREFLI" , MVC_VIEW_ORDEM,  '07')
        oStrGerais:SetProperty("H7J_CODH6V" , MVC_VIEW_TITULO, STR0079)//"Seq. Linha"
        oStrGerais:SetProperty("H7J_CODH6V" , MVC_VIEW_DESCR,  STR0079)//"Seq. Linha"               
    ENDIF
    oStrGerais:SetProperty("H7J_TOTVIA" , MVC_VIEW_CANCHANGE,  .F.)
   
    oView:SetModel(oModel)
   
    oView:SetDescription( STR0001) //"Prestação de Contas"

    oView:AddField('VIEW_H7I', oStrSuperi, 'H7IMASTER' )
    oView:AddGrid('VIEW_H7J' , oStrGerais, 'H7JDETAIL')
    oView:AddGrid('VIEW_H7L' , oStrPagame, 'H7LDETAIL')
    oView:AddGrid('VIEW_H7K' , oStrEstati, 'H7KDETAIL')
    oView:AddField('VIEW_TOT', oStrTotais, 'H7IMASTER')
   
    oView:CreateHorizontalBox( 'CABECALHO'  , 25)
    oView:CreateHorizontalBox( 'SERVIÇOS'   , 25)
    oView:CreateHorizontalBox( 'INFORMACOES', 25)
    oView:CreateHorizontalBox( 'TOTAIS'     , 15)

    oView:CreateVerticalBox('PAGAMENTO'  , 50 , 'INFORMACOES')
    oView:CreateVerticalBox("ESTATISTICO", 50 , 'INFORMACOES')
    
    oView:EnableTitleView("VIEW_H7I", STR0005) //"Informação dos serviços"
    oView:EnableTitleView("VIEW_H7L", STR0006) //"Dados de Pagamento"
    oView:EnableTitleView("VIEW_H7K", STR0007) //"Dados Estatísticos"
    oView:EnableTitleView("VIEW_TOT", STR0008) //"Totais"
      
    oView:SetOwnerView('VIEW_H7I', 'CABECALHO')
    oView:SetOwnerView('VIEW_H7J', 'SERVIÇOS')
    oView:SetOwnerView('VIEW_H7L', 'PAGAMENTO')
    oView:SetOwnerView('VIEW_H7K', 'ESTATISTICO') 
    oView:SetOwnerView('VIEW_TOT', 'TOTAIS') 

    oView:AddUserButton("Carrega serviços", "", {|oView| GU013Serv(oView)}) //Carrega serviços

    oView:SetViewAction('DELETELINE'  , { |oView| DeletaLinha( oView ) } )
    oView:SetViewAction('UNDELETELINE', { |oView| DeletaLinha( oView ) } )
    
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função chamada pelo bloco de validação dos campos

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param oMdl, object, Modelo
@param cField, character, Campo
@param uNewValue, variant, Novo Valor
@param uOldValue, variant, Antigo Valor
@return lRet, Retorna se permite o conteúdo do campo ou não.
/*/
//-------------------------------------------------------------------
Static Function FieldValid(oMdl, cField, uNewValue, uOldValue) 
    
    Local lRet		:= .T.
    Local oModel	:= oMdl:GetModel()
    Local cMdlId	:= oMdl:GetId()
    Local cMsgErro	:= ""
    Local cMsgSol	:= ""

    If cField == 'H7I_MOTORI'
        lRet := VLDH7IMOTO(uNewValue, @cMsgErro, @cMsgSol)
    Endif

    If cField == 'H7I_COBRAD'
        lRet := VLDH7ICOBR(uNewValue, @cMsgErro, @cMsgSol)
    Endif
    
    If cField $ 'H7I_LOCARR|H7J_SERVIC'
        lRet := GTPFecVal(uNewValue, @cMsgErro, @cMsgSol, oModel, cField)
    EndIf

    If cField $ 'H7J_DATAIS|H7J_DATATS|H7I_DATREF|H7I_DTSERV'
        lRet := GTPDtSVal(uNewValue, @cMsgErro, @cMsgSol, oModel, cField)
    EndIf

    If cField $ 'H7L_TPAGAM|H7L_CODH6S|H7J_ESCALA'
        lRet := GTPValDig(uNewValue, @cMsgErro, @cMsgSol, oModel, cField)
    EndIf   

    If cField == 'H7J_CODLIN'
        lRet := Empty(uNewValue) .OR. ExistCPO("H6V",uNewValue,4)
    Endif 

    If !lRet .and. !Empty(cMsgErro)
        oModel:SetErrorMessage(cMdlId, cField, cMdlId, cField, "FieldValid", cMsgErro, cMsgSol, uNewValue, uOldValue)
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função chamada pelo bloco de gatilhos dos campos

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param oMdl, object, Modelo
@param cField, character, Campo
@param uVal, variant, Conteúdo do campo
@return uVal, Conteúdo do campo
/*/
//-------------------------------------------------------------------
Static Function FieldTrigger(oMdl, cField, uVal)
    Local oModelH7J := oMdl:GetModel():GetModel("H7JDETAIL")
    Local oModelH7L := oMdl:GetModel():GetModel("H7LDETAIL")
    Local oModelH7K := oMdl:GetModel():GetModel("H7KDETAIL")
    Local oModelH7I := oMdl:GetModel():GetModel("H7IMASTER")
    Local nTotV     := 0
    Local nPedagio  := 0
    Local cCodPed   := ""
    
    If cField $ 'H7J_ESCALA'
        LoadH7K(oMdl)
    ElseIf cField $ 'H7I_MOTORI'
        GTPUGatH7H(oMdl)
    ElseIf cField == 'H7K_ROLSAI'
        GTPUGatH6Z(oMdl, uVal)
    ElseIf cField == 'H7J_VEICUL'
        GTPUGatH6Z(oMdl, uVal, '1')
    ElseIf cField $ 'H7I_PGCOFR|H7I_PGDINH'
        GTPUGatDin(oMdl)
    ElseIf cField $ 'H7J_CODH6V'
        If !oModelH7L:IsEmpty()
            oModelH7J:LoadValue("H7J_ESCALA", "" )
            oModelH7J:LoadValue("H7J_DESCAL", "" )
            GTPxClearData(oModelH7L)
            GTPxClearData(oModelH7K)            
        EndIf
    ElseIf cField $ 'H7I_MATMOT'
        If Empty(uVal)
            oModelH7I:SetValue('H7I_MOTORI','')   
        Else
            oModelH7I:SetValue('H7I_MOTORI',GetAdvFVal('GYG','GYG_CODIGO',xFilial('GYG')+uVal,2,''))   
        Endif
    ElseIf cField $ 'H7J_CODLIN'
        If EMPTY(uVal) 
            oModelH7J:SetValue('H7J_CODH6V','')        
        Else
            oModelH7J:LoadValue('H7J_CODH6V',GetAdvFVal('H6V','H6V_CODIGO',xFilial('H6V')+uVal,4,''))                
            oModelH7J:LoadValue('H7J_DESCLI',GetAdvFVal('H6V','H6V_DESCRI',xFilial('H6V')+oModelH7J:getvalue('H7J_CODH6V'),1,''))                    
            oModelH7J:LoadValue('H7J_PREFLI',GetAdvFVal('H6V','H6V_PREFIX',xFilial('H6V')+oModelH7J:getvalue('H7J_CODH6V'),1,''))                    
            oModelH7J:LoadValue('H7J_KMPREV',GetAdvFVal('H6V','H6V_KMLINH',xFilial('H6V')+oModelH7J:getvalue('H7J_CODH6V'),1,''))                    
        Endif
    ElseIf cField $ 'H7J_TVIIDA'
        nTotV := oModelH7J:GetValue('H7J_TVVOLT') + uVal
        oModelH7J:LoadValue('H7J_TOTVIA',nTotV)
    ElseIf cField $ 'H7J_TVVOLT'
        nTotV := oModelH7J:GetValue('H7J_TVIIDA') + uVal
        oModelH7J:LoadValue('H7J_TOTVIA',nTotV)
    ElseIf cField $ 'H7L_NUMPAS'
    	H6X->(DbSetOrder(2))
        If H6V->(DbSeek(xFilial("H6V")+oModelH7J:GetValue("H7J_CODH6V"))) .And. H6V->H6V_TIPCAL == '1'                
            cCodPed := H6V->H6V_PEDAGI        
        ElseIf H6X->(DbSeek(xFilial("H6X")+oModelH7J:GetValue("H7J_CODH6V"))) .And. H6W->(DbSeek(xFilial("H6W")+H6X->H6X_CODIGO))
            cCodPed := H6W->H6W_PEDAGI                
        EndIf            
        If H72->(DbSeek(xFilial("H72")+cCodPed)) .And. oModelH7I:GetValue("H7I_DTSERV") >= H72->H72_DTINIV .And. oModelH7I:GetValue("H7I_DTSERV") <= H72->H72_DTFIMV
            nPedagio :=  H72->H72_VALOR
        EndIf        
        oModelH7L:LoadValue('H7L_PEDAGI', uVal * nPedagio)         
    Endif

Return uVal

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDH7LTPAG
Validação do campo H7L_TPAGAM

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param uNewValue, variant, Conteúdo do campo
@param cMsgErro, character, Mensagem de erro que retornará por referência
@param cMsgSol, character, Mensagem de solicitação que retornará por referência
@return lRet, Retorno que permitirá o conteúdo do campo ou não
/*/
//-------------------------------------------------------------------
Static Function VLDH7LTPAG(uNewValue, cMsgErro, cMsgSol)

    Local lRet     := .T.
    Local aAreaH6R := H6R->(GetArea()) 

    If ! Empty(uNewValue)
        H6R->(dbSetOrder(1))
        If !H6R->(dbSeek(xFilial("H6R") + uNewValue))
            lRet     := .F.
            cMsgErro :=  STR0017 // "Tipo de Pagamento não existe no cadastro."
            cMsgSol  :=  STR0018 // "Pressione F3 ou clique na Lupa para trazer o Tipo de Pagamento correto."
        EndIf   
    EndIf  

    RestArea(aAreaH6R)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadH7J
Carregar dados no grid LoadH7J 
@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param oModel, object, Modelo da H7J
/*/
//-------------------------------------------------------------------
Static Function LoadH7K(oModel)
    Local oMdl      := oModel:GetModel()
    Local oModelH7I := oMdl:GetModel("H7IMASTER")
    Local oModelH7J := oMdl:GetModel("H7JDETAIL")
    Local oModelH7K := oMdl:GetModel("H7KDETAIL")    
    Local cMotori   := oModelH7I:GetValue("H7I_MOTORI")     
    Local cQryH7F	:= ""
    Local cQryH7G   := ""
    Local cCodH7F   := ""
    Local cCodH76   := ""
    Local cAliasH7F := ""
    Local cAliasH7G := ""
    Local cEscala   := oModelH7J:GetValue("H7J_ESCALA")
    Local oView     := FWViewActive()

    Default oModel := Nil
    
    If !oModelH7K:IsEmpty()
        //ModelH7J:LoadValue("H7J_VEICUL", "")
        GTPxClearData(oModelH7K)               
    Endif  
    
    // Query para pegar a alocação   
    cAliasH7F := GetNextAlias()

    cQryH7F	:= " SELECT H7F_CODIGO CODIGO,"
    cQryH7F	+=       " H7F_CODH76 CODH76,"
    cQryH7F	+=       " H7G_CODH70 CODH70,"
    cQryH7F	+=       " H7G_CODH6V CODH6V,"
    cQryH7F	+=       " MIN(H7G_HRINIC) HRINICIO,"
    cQryH7F	+=       " MAX(H7G_HRFINA) HRFINAL"
    cQryH7F	+= " FROM " + RetSqlName("H7F") + " H7F "
    cQryH7F +=        " INNER JOIN " + RetSqlName("H7G") + " H7G "
    cQryH7F +=                " ON ( H7G.H7G_FILIAL = H7F.H7F_FILIAL "
    cQryH7F +=                     " AND H7G.H7G_CODH7F = H7F.H7F_CODIGO "
    cQryH7F +=                     " AND H7G.H7G_CODGYG = '" + cMotori + "'"
    cQryH7F +=                     " AND H7G_CODH76 = H7F_CODH76 "
    cQryH7F +=                     " AND H7G_CODH7I = ''"
    cQryH7F +=                     " AND H7G_TIPO  = '7'"
    cQryH7F +=                     " AND H7G.D_E_L_E_T_ = ' ')"
    cQryH7F	+= " WHERE  H7F.H7F_FILIAL = '" + xFilial("H7F") + "'"
    cQryH7F	+=        " AND H7F.H7F_DATA = '" + DTOS(oModelH7I:GetValue("H7I_DTSERV")) + "'"    
    cQryH7F	+=        " AND H7F_CODH76 = '" + cEscala + "'"    
    cQryH7F	+=        " AND H7F.D_E_L_E_T_ = ' ' "
    cQryH7F	+= " GROUP BY H7F_CODH76 ,"
    cQryH7F	+=          " H7F_CODIGO ,"
    cQryH7F	+=          " H7G_CODH70 ,"
    cQryH7F	+=          " H7G_CODH6V "

    cQryH7F := ChangeQuery(cQryH7F)   

    DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryH7F), cAliasH7F, .F., .T.)

    If (cAliasH7F)->(!EOF())

        cCodH7F := (cAliasH7F)->CODIGO
        cCodH76 := (cAliasH7F)->CODH76

        oModelH7J:SetValue("H7J_VEICUL", (cAliasH7F)->CODH70)
        
        // Query para pegar os horários
        cAliasH7G := GetNextAlias()

        cQryH7G	:= " SELECT H7G_SENTID SENTIDO, "
        cQryH7G	+=        " H7G_HRINIC HRINICIO,"
        cQryH7G	+=        " H7G_HRFINA HRFINAL,"
        cQryH7G	+=        " H6Z_INICRO ROLINICIAL,"
        cQryH7G	+=        " H6Z_CODIGO CODROLETA"
        cQryH7G	+= " FROM  " + RetSqlName("H7G") + " H7G "    
        cQryH7G	+=        " INNER JOIN "+ RetSqlName("H70") + " H70 " 
        cQryH7G	+=                " ON ( H70.H70_FILIAL =  '" + xFilial("H70") + "'"  
        cQryH7G	+=                     " AND H70.H70_CODVEI = H7G_CODH70"
        cQryH7G	+=                     " AND H70.D_E_L_E_T_ = '' )"
        cQryH7G	+=        " LEFT JOIN "+ RetSqlName("H6Z") + " H6Z " 
        cQryH7G	+=               " ON ( H6Z.H6Z_FILIAL =  '" + xFilial("H6Z") + "'"  
        cQryH7G	+=                    " AND H6Z.H6Z_CODIGO = H70_ROLVEI"
        cQryH7G	+=                     " AND H6Z.D_E_L_E_T_ = '' )"
        cQryH7G	+= " WHERE  H7G.H7G_FILIAL =  '" + xFilial("H7G") + "'"  
        cQryH7G	+=       " AND H7G_CODH7F = '" + cCodH7F + "'"
        cQryH7G	+=       " AND H7G_CODGYG = '" + cMotori + "'"
        cQryH7G	+=       " AND H7G_CODH76 = '" + cCodH76 + "'"
        cQryH7G	+=       " AND H7G_CODH70 = '" + ((cAliasH7F)->CODH70) + "'"
        cQryH7G	+=       " AND H7G.D_E_L_E_T_ = ' '"
        cQryH7G	+= " ORDER BY H7G_HRINIC

        cQryH7G := ChangeQuery(cQryH7G)        

        DbUseArea(.T., "TOPCONN", TCGenQry(,,cQryH7G), cAliasH7G, .F., .T.)

        While (cAliasH7G)->(!EOF())

            If !Empty( oModelH7K:GetValue("H7K_SENTID"))
                oModelH7K:AddLine()
            EndIf            
            oModelH7K:LoadValue("H7K_SENTID", (cAliasH7G)->SENTIDO)

            If len(Alltrim(StrTran((cAliasH7G)->HRINICIO,":",""))) < 4
                oModelH7K:LoadValue("H7K_HRSAIP", PADR("0"+Alltrim(StrTran((cAliasH7G)->HRINICIO,":","")), TamSx3("H7K_HRSAIP")[1],"0"))
            Else
                oModelH7K:LoadValue("H7K_HRSAIP", PADR(StrTran((cAliasH7G)->HRINICIO,":",""), TamSx3("H7K_HRSAIP")[1],"0")) 
            EndIf

            If len(Alltrim(StrTran((cAliasH7G)->HRFINAL,":",""))) < 4
                oModelH7K:LoadValue("H7K_HRCHEP", PADR("0"+Alltrim(StrTran((cAliasH7G)->HRFINAL,":","")), TamSx3("H7K_HRCHEP")[1],"0"))
            Else            
                oModelH7K:LoadValue("H7K_HRCHEP", PADR(StrTran((cAliasH7G)->HRFINAL ,":",""), TamSx3("H7K_HRCHEP")[1],"0")) 
            EndIf

            (cAliasH7G)->(dbSkip())
            
        EndDo                
        (cAliasH7G)->(DbCloseArea())
        
    EndiF            
    
    (cAliasH7F)->(DbCloseArea())

    oModelH7J:GoLine( 1 ) 
    oModelH7K:GoLine( 1 )
   
    If ValType(oView) == "O"
        oView:Refresh('VIEW_H7J')
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPUGatH7H
Gatilha o cartão do motorista
@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param oModel, object, Modelo da H7J
/*/
//-------------------------------------------------------------------
Static Function GTPUGatH7H(oModel)
    Local oMdl      := oModel:GetModel()    
    Local oModelH7I := oMdl:GetModel("H7IMASTER")
    Local oModelH7J := oMdl:GetModel("H7JDETAIL")

    Default oModel := Nil
    
    If !oModelH7J:IsEmpty()
        GTPxClearData(oModelH7J)        
    EndIf   

    If H7I->(FieldPos("H7I_MATMOT")) > 0
        oModelH7I:LoadValue('H7I_MATMOT',GetAdvFVal('GYG','GYG_FUNCIO',xFilial('GYG')+FwFldGet("H7I_MOTORI"),1,''))   
    Endif

    H7H->(DbSetOrder(2))
    IF H7H->(DbSeek(xFilial("H7H")+FwFldGet("H7I_MOTORI")))    
        While xFilial("H7H") == H7H->H7H_FILIAL .And. FwFldGet("H7I_MOTORI") == H7H->H7H_COLABO 
            If Empty(H7H->H7H_DTINIC) .Or. (DDATABASE >= H7H->H7H_DTINIC .And. DDATABASE <= H7H->H7H_DTFINA)
                oModelH7I:LoadValue("H7I_CARMOT", H7H->H7H_NUMCAR)
            EndIf
            H7H->(DbSkip())
        EndDo
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDH7IMOTO
Validação do campo H7I_MOTORI

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param uNewValue, variant, Conteúdo do campo
@param cMsgErro, character, Mensagem de erro que retornará por referência
@param cMsgSol, character, Mensagem de solicitação que retornará por referência
@return lRet, Retorno que permitirá o conteúdo do campo ou não
/*/
//-------------------------------------------------------------------
Static Function VLDH7IMOTO(uNewValue, cMsgErro, cMsgSol)

    Local lRet     := .T.
    Local aAreaAtu := GetArea()
    Local aAreaGYG := GYG->(GetArea())

    GYG->(dbSetOrder(1))

    If !Empty(uNewValue) .And. GYG->(dbSeek(xFilial("GYG") + uNewValue)) .And. GYG->GYG_RECCOD != "01"        
        lRet     := .F.
        cMsgErro := STR0019 // "Motorista não localizado no cadastro."
        cMsgSol  := STR0020 // "Verifique o cadastro deste colaborador e se está parametrizado como motorista."
    EndIf

    RestArea(aAreaGYG)
    RestArea(aAreaAtu)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VLDH7ICOBR
Validação do campo H7I_COBRAD

@type static function
@version 12.1.2310
@author Djalma Borges Neto
@since 6/24/2024
@param uNewValue, variant, Conteúdo do campo
@param cMsgErro, character, Mensagem de erro que retornará por referência
@param cMsgSol, character, Mensagem de solicitação que retornará por referência
@return lRet, Retorno que permitirá o conteúdo do campo ou não
/*/
//-------------------------------------------------------------------
Static Function VLDH7ICOBR(uNewValue, cMsgErro, cMsgSol)

    Local lRet     := .T.
    Local aAreaAtu := GetArea()
    Local aAreaGYG := GYG->(GetArea())

    GYG->(dbSetOrder(1))

    If !Empty(uNewValue) .And. GYG->(dbSeek(xFilial("GYG") + uNewValue)) .And. GYG->GYG_RECCOD != "02"         
        lRet     := .F.
        cMsgErro := STR0021 // "Cobrador não localizado no cadastro."
        cMsgSol  := STR0022 // "Verifique o cadastro deste colaborador e se está parametrizado como cobrador."
    EndIf

    RestArea(aAreaGYG)
    RestArea(aAreaAtu)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GU013Inclu
Opção de Menu para Incluir a Prestação de Contas

@type function
@version 12.1.2310
@author DJALMA BORGES NETO
@since 7/05/2024
/*/
//-------------------------------------------------------------------
Function GU013Inclu()
    Local oMdlH7I   := FwLoadModel('GTPU013')
    Local aAreaH7I  := H7I->(GetArea())
    Local aAreaCTG  := CTG->(GetArea())
    Local cExercic  := AllTrim(str(year(dDataBase)))  
    Local cPeriod   := AllTrim(str(Month(dDataBase)))

    CTG->(DbSetOrder(4))
    If CTG->(DbSeek(xFilial("CTG") + PADR(cExercic , TAMSX3("CTG_EXERC")[1]) + cPeriod )) ;
       .And. dDataBase >= CTG->CTG_DTINI .And. dDataBase <= CTG->CTG_DTFIM .And. CTG->CTG_STATUS <> "1"
            
        FwAlertHelp(STR0068, STR0069) // "Esse período no calendário contábil não está disponível" // "É necessário abrir o calendário contábil para o periodo"

    Else

        oMdlH7I:SetOperation(MODEL_OPERATION_INSERT)
        oMdlH7I:Activate()
        
        oMdlH7I:SetValue('H7IMASTER', 'H7I_USRINC', RetCodUsr())
        oMdlH7I:SetValue('H7IMASTER', 'H7I_NOMINC', FwGetUserName(RetCodUsr()))  

        FWExecView("Incluir","VIEWDEF.GTPU013",MODEL_OPERATION_INSERT,,{|| .T.}, , , , , , , oMdlH7I) 

        oMdlH7I:DeActivate()

    EndIf

    H7I->(RestArea(aAreaH7I))
    CTG->(RestArea(aAreaCTG))

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GU013Alter
Opção de Menu para Alterar a Prestação de Contas

@type function
@version 12.1.2310
@author DJALMA BORGES NETO
@since 7/05/2024
/*/
//-------------------------------------------------------------------
Function GU013Alter()
    
    If H7I->H7I_STATUS <> '2'
        FWExecView(STR0026, "VIEWDEF.GTPU013", MODEL_OPERATION_UPDATE,, {|| .T.})
    Else
        FwAlertHelp(STR0002, STR0023 ) // "Não é permitido alterar uma Prestação de Contas que já foi conferida e/ou já teve o caixa fechado."
    EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} GU013Exclu
Opção de Menu para Excluir a Prestação de Contas

@type function
@version 12.1.2310
@author DJALMA BORGES NETO
@since 7/05/2024
/*/
//-------------------------------------------------------------------
Function GU013Exclu()

    If H7I->H7I_STATUS <> '2' 
        FWExecView(STR0028, "VIEWDEF.GTPU013", MODEL_OPERATION_DELETE,, {|| .T.})
    Else
        FwAlertHelp(STR0002, STR0029) //"Não é permitido excluir uma Prestação de Contas que já foi conferida e/ou já teve o caixa fechado."
    EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GU013Confe
Opção de Menu para Conferir a Prestação de Contas

@type function
@version 12.1.2310
@author DJALMA BORGES NETO
@since 6/25/2024
/*/
//-------------------------------------------------------------------
Function GU013Confe()
    Local oMdlH7I   := FwLoadModel('GTPU013')
    Local aAreaH7I  := H7I->(GetArea())
    
    oMdlH7I:SetOperation(MODEL_OPERATION_UPDATE)
    oMdlH7I:Activate()
    
    If H7I->H7I_STATUS <> '2' .And. DTOS(ddatabase) >= DTOS(H7I->H7I_DATREF)

        oMdlH7I:SetValue('H7IMASTER', 'H7I_CONFER', RetCodUsr())
        oMdlH7I:SetValue('H7IMASTER', 'H7I_NOMCON', FwGetUserName(RetCodUsr()))  
        oMdlH7I:SetValue('H7IMASTER', 'H7I_DTPRCO', ddatabase)                   
        oMdlH7I:SetValue('H7IMASTER', 'H7I_STATUS', "2") 

        FwExecView("Conferência", "VIEWDEF.GTPU013", MODEL_OPERATION_UPDATE,, {|| .T.}, , , , , , , oMdlH7I)         

    Else
        FwAlertHelp(STR0002, STR0030)//"Não é possível conferir uma Prestação de contas concluida"    
    EndIf

    oMdlH7I:DeActivate()
    H7I->(RestArea(aAreaH7I))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GU013Reabr
Opção de Menu para Reabrir a Prestação de Contas

@type function
@version 12.1.2310
@author Karyna Rainho Morato Martins
@since 18/10/2024
/*/
//-------------------------------------------------------------------
Function GU013Reabr()

    Local oModel    := Nil
    Local aAreaH7I  := H7I->(GetArea())
    
    H7P->(dbSetOrder(2))
    If !H7P->(dbSeek(xFilial("H7P") + H7I->H7I_LOCARR + DTOS(H7I->H7I_DATREF))) .And. H7I->H7I_STATUS == '2'

        oModel := FwLoadModel('GTPU013')
        oModel:SetOperation(4)
        oModel:Activate()

        oModel:SetValue('H7IMASTER', 'H7I_USRREA', RetCodUsr())
        oModel:SetValue('H7IMASTER', 'H7I_NOMREA', FwGetUserName(RetCodUsr()))  
        oModel:SetValue('H7IMASTER', 'H7I_STATUS', "3")     

        If oModel:VldData() .And. oModel:CommitData()
            FwAlertSuccess(STR0052) // "Prestação reaberta com sucesso"
        Else
            FwAlertHelp(STR0002, oModel:GetErrorMessage()[6])
        Endif                 
        
        oModel:DeActivate()

    ElseIf H7I->H7I_STATUS == '1'
        FwAlertHelp(STR0002, STR0053)//"Não é possível reabrir uma Prestação de contas aberta"  
    Else
        FwAlertHelp(STR0002, STR0054)//"Não é possível reabrir uma Prestação de contas com um caixa aberto"    
    EndIf
    
    H7I->(RestArea(aAreaH7I))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GU013Serv()
Realiza a conferência
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GU013Serv(oView)
    Local oModel    := oView:GetModel()
    Local oModelH7I := oModel:GetModel("H7IMASTER")
    Local lRet      := .T.
    
    If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !Empty(oModelH7I:GetValue('H7I_MOTORI')) .And. !Empty(oModelH7I:GetValue('H7I_DTSERV')) .And. oModelH7I:GetValue('H7I_INTEGR')== 'N'
        GTPU013A(oModel)
    ElseIf oModel:GetOperation() <> MODEL_OPERATION_INSERT 
        FwAlertHelp("Não é possível carregar os serviços", "Para carregar é preciso incluir uma prestação")//"Não é possível carregar os serviços"  // "Para carregar é preciso incluir uma prestação"
    ElseIf oModelH7I:GetValue('H7I_INTEGR') == 'S'
        FwAlertHelp("Não é possível carregar os serviços", "Para carregar não pode ter integrado uma filipeta")//"Não é possível carregar os serviços"  // "Para carregar é preciso incluir uma prestação"
    Else
        FwAlertHelp(STR0071, STR0072)//"Não foi informado a Data do Serviço ou o Motorista"  // "É necessário informar a Data do Serviço ou um motorista"
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid
Função de validação

@type Static Function
@param  oModel, object, Modelo da H7I
@return lRet - Retorna .T. ser estiver tudo certo, senão, mostra mensagem em tela
@author Karyna Martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)  
    Local oMdl      := oModel:GetModel()
    Local oMdlH7I   := oMdl:GetModel("H7IMASTER")
    Local oMdlH7J   := oMdl:GetModel("H7JDETAIL")
    Local oMdlH7K   := oMdl:GetModel("H7KDETAIL")
    Local aAreaH7I  := H7I->(GetArea())
    Local aHour     := {}
    Local cMsgErro  := ""
    Local cMsgSol   := ""        
    Local cHrIni    := ""
    Local cHrFim    := ""
    Local cDifHrH7J := "00:00:00"
    Local cDifHrH7K := "00:00:00"
    Local dDtIni    := ""
    Local dDtFim    := STOD("  /  /    ")
    Local dDtFec    := DTOS(oModel:GetModel("H7IMASTER"):GetValue("H7I_DATREF"))
    Local cLocAr    := oModel:GetModel("H7IMASTER"):GetValue("H7I_LOCARR")
    Local lRet      := .T.
    Local nI        := 0
    Local nX        := 0
    Local nQtdRol   := 0
    Local nQtdPass  := 0
    Local nRolEnt   := 0
    Local nRolSai   := 0
    Local nRolSH7J  := 0
    Local cVeiH7J   := ''
    Local lValHrEst := .F.
   
    If oModel:GetOperation() == MODEL_OPERATION_INSERT 

        H7I->(DbSetOrder(3)) //H7I_FILIAL+H7I_COLETA                                                                                                                                           
        If H7I->(DBSEEK( xFilial("H7I") + oMdlH7I:GetValue('H7I_COLETA') )) 

            lRet     := .F.
            cMsgErro := STR0011 // "Já existe um cadastro com esse número de filipeta"
            cMsgSol  := STR0012 // "É necessário informar um número de filipeta diferente"

        ElseIf Empty(oMdlH7I:GetValue('H7I_MOTORI')) .And. Empty(oMdlH7I:GetValue('H7I_COBRAD'))

            lRet     := .F.
            cMsgErro := STR0032 // "Não foi informado um colaborador"
            cMsgSol  := STR0033 // "É necessário informar um motorista ou um cobrador"
        
        EndIf
    
        H7P->(dbSetOrder(2))
        If H7P->(dbSeek(xFilial("H7P") + cLocAr + dDtFec)) .And. !H7P->H7P_STATUS $ "1|4"
            lRet     := .F.
            cMsgErro :=  STR0061 // "Já existe um caixa fechado para essa data e local de arrecadação"
            cMsgSol  :=  STR0062 // "Reabrir o caixa ou realizar uma nova prestação com data e local diferentes"
        EndIf   
   

    ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !Empty(oMdlH7I:GetValue('H7I_DTPRCO'))

        If Empty(oMdlH7I:GetValue('H7I_LOCARR'))

            lRet     := .F.    
            cMsgErro := STR0036 // "O local de arrecadação não foi preenchido"
            cMsgSol  := STR0037 // "É necessário informar um local de arrecadação"

        EndIf

    EndIf

    If lRet        
        
        For nX := 1 To oMdlH7J:GetQtdLine()
            oMdlH7J:GoLine(nX)
            
            nQtdRol    := 0
            nQtdPass   := oMdlH7J:GetValue("H7J_TOTPAS")
            dDtIni     := oMdlH7J:GetValue("H7J_DATAIS")
            dDtFim     := oMdlH7J:GetValue("H7J_DATATS")
            cHrIni     := Transform(oMdlH7J:GetValue("H7J_HRRINI"), PesqPict("H7J","H7J_HRRINI"))
            cHrFim     := Transform(oMdlH7J:GetValue("H7J_HRRFIN"), PesqPict("H7J","H7J_HRRFIN"))
            cDifHrH7J  := ElapTime(cHrIni, cHrFim )

            For nI := 1 To oMdlH7K:GetQtdLine()            
                oMdlH7K:GoLine(nI)   
                nRolEnt := oMdlH7K:GetValue("H7K_ROLENT") 
                nRolSai := oMdlH7K:GetValue("H7K_ROLSAI") 

                If nX > 1 .And. oMdlH7K:GetLine() == 1 .And. nRolSH7J <> nRolEnt .And. oMdlH7J:GetValue("H7J_VEICUL") == cVeiH7J     
                    lRet := .F.
                    cMsgErro := STR0073 + oMdlH7J:GetValue("H7J_SERVIC") + STR0074 // "Roleta inicial do serviço: " // " difere da roleta final do serviço anterior"
                    cMsgSol  := STR0075 +  cValToChar(nRolSH7J)// "Informe roleta inicial: "                                                                                                                                                                                                                                                                                                                                                                                                                                    
                    exit
                ElseIf nX > 1 .And. nRolSH7J > nRolEnt .And. nRolSai > 0 .And. nRolSH7J >= nRolSai .And. oMdlH7J:GetValue("H7J_VEICUL") == cVeiH7J 
                    lRet := .F.
                    cMsgErro := STR0076 + oMdlH7J:GetValue("H7J_SERVIC") + STR0077 // "Roleta do serviço: " // " já foi utilizada no serviço anterior"
                    cMsgSol  := STR0078 +  cValToChar(nRolSH7J)// "Informe roleta maior que "                                                                                                                                                                                                                                                                                                                                                                                                                                      
                    exit
                Else        

                    If nRolSai > nRolEnt
                        nQtdRol += nRolSai - nRolEnt
                    EndIf

                    If !Empty(oMdlH7K:GetValue("H7K_HRSAIR")) .OR. !Empty(oMdlH7K:GetValue("H7K_HRCHER"))
                        lValHrEst := .T.
                    Endif

                    cHrIni := Transform(oMdlH7K:GetValue("H7K_HRSAIR"), PesqPict("H7K","H7K_HRSAIR"))
                    cHrFim := Transform(oMdlH7K:GetValue("H7K_HRCHER"), PesqPict("H7K","H7K_HRCHER"))
                    aHour  := StrTokarr(cDifHrH7K, ":")
                    cDifHrH7K := IncTime( DifPeriodo(dDtIni, cHrIni, dDtFim, cHrFim), Val(aHour[1]), Val(aHour[2]), Val(aHour[3]) )  
                EndIf
                
            Next nI     

            If !lRet
                exit
            EndIf
            If nQtdRol <> nQtdPass
                lRet := .F.
                cMsgErro := STR0041 + " " + cValToChar(nQtdRol) + STR0042 +" " + cValToChar(nQtdPass)+")  " // "Quantidades Roleta (" ### ") não pode ser diferente da quantidade de passageiros (" ### ")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                cMsgSol  := STR0040 + " " +oMdlH7J:GetValue("H7J_SERVIC") +" " // "Informe a quantidade de roletas igual a quantidade de passageiros, serviço: "                                                                                                                                                                                                                                                                                                                                                                                                                                      
                exit
            ElseIf lValHrEst .AND. (cDifHrH7J < cDifHrH7K)
                lRet := .F.
                cMsgErro := STR0055 + cDifHrH7K + STR0056 + cDifHrH7J // ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
                cMsgSol  := STR0057 // "Informe o intervalo de horas estátisticas menor ou igual as horas realizadas do colaborador"    
                exit                                                                                                                                                                                                                                                                                                                                                                                                                                 
            EndIf    

            nRolSH7J := oMdlH7J:GetValue("H7J_ROLSAI")     
            cVeiH7J := oMdlH7J:GetValue("H7J_VEICUL")     

        Next nX
        
    EndIf    
    
    If !lRet
        oModel:SetErrorMessage(oModel:GetId(), "", oModel:GetId(), "", "GU013PosVld", cMsgErro, cMsgSol) 
    EndIf

    RestArea(aAreaH7I)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DeletaLinha
Função de calcula total

@type Static Function
@param  oView, cIdView, nNumLine
@return nSaldoAtu - Saldo atualizado
@author Karyna Martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function DeletaLinha(oView,cIdView, nNumLine)
    Local oModel := oView:GetModel()

    AtuTotal(oModel,"H7L_VLRTOT")
    AtuTotal(oModel,"H7J_VLRTOT")
    AtuTotal(oModel,"H7J_TOTDIN")
    AtuTotal(oModel,"H7I_TOTDIN")
    AtuTotal(oModel,"H7I_VLRDEV")
    AtuTotal(oModel,"H7J_PEDAGI")
    PasTotal(oModel, "1")
    PasTotal(oModel, "2")
    PasTotal(oModel, "3")

    oView:Refresh()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTotal
Função de calcula total

@type Static Function
@param  oModel
@param  cTipo = 1-Serviços, 2-Prestacao
@return nSaldoAtu - Saldo atualizado
@author Karyna Martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function AtuTotal(oModel, cCampo)
    Local aLinhas   := FWSaveRows()
    Local aAreaH6R  := H6R->(GetArea())
    Local oMdl      := oModel:GetModel()
    Local oMdlH7I   := oMdl:GetModel("H7IMASTER")
    Local oMdlH7J   := oMdl:GetModel("H7JDETAIL")
    Local oMdlH7L   := oMdl:GetModel("H7LDETAIL")  
    Local nX        := 1
    Local nSaldoAtu := 0
   
    Default cCampo := ""
    
    If cCampo $ "H7L_VLRTOT|H7J_TOTDIN"

        For nX := 1 To oMdlH7L:Length()

            If !oMdlH7L:IsDeleted(nX)
                If cCampo $ "H7L_VLRTOT
                    nSaldoAtu += oMdlH7L:GetValue("H7L_VLRTOT", nX)
                Else
                    H6R->( DbSetOrder(1) )
                    If H6R->( DbSeek(xFilial("H6R")+oMdlH7L:GetValue('H7L_TPAGAM', nX)) ) .And. H6R->H6R_ESPECI
                        nSaldoAtu   += oMdlH7L:GetValue("H7L_VLRTOT", nX)
                    EndIf
                EndIf
            Endif

        Next nX

        If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and. oModel:GetOperation() <> MODEL_OPERATION_VIEW
            If cCampo $ "H7L_VLRTOT
                oMdlH7J:LoadValue('H7J_VLRTOT', nSaldoAtu)               
            Else
                oMdlH7J:LoadValue('H7J_TOTDIN', nSaldoAtu)                 
            EndIf
        EndIf

    ElseIf cCampo $ "H7J_VLRTOT|H7I_TOTDIN|H7I_VLRDEV|H7J_PEDAGI" 

        For nX := 1 To oMdlH7J:Length()

            If !oMdlH7J:IsDeleted(nX)
                If cCampo $ "H7J_VLRTOT|H7J_PEDAGI"
                    nSaldoAtu += oMdlH7J:GetValue(cCampo,nX)
                Else
                    nSaldoAtu += oMdlH7J:GetValue("H7J_TOTDIN",nX)
                EndIf
            Endif

        Next nX

        If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and. oModel:GetOperation() <> MODEL_OPERATION_VIEW
            If cCampo == "H7J_VLRTOT"
                oMdlH7I:LoadValue('H7I_VLRTOT', nSaldoAtu)
            ElseIf cCampo == "H7J_PEDAGI"
                oMdlH7I:LoadValue('H7I_PEDAGI', nSaldoAtu)
            ElseIf cCampo $ "H7I_VLRDEV
                oMdlH7I:LoadValue('H7I_VLRDEV', nSaldoAtu := nSaldoAtu - (oMdlH7I:GetValue("H7I_PGCOFR") + oMdlH7I:GetValue("H7I_PGDINH")))
            Else   
                oMdlH7I:LoadValue('H7I_TOTDIN', nSaldoAtu)
            EndIf
        EndIf
        
    EndIf

    RestArea(aAreaH6R)
    FWRestRows(aLinhas)       
  
Return nSaldoAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} PasTotal
Função de calcula total

@type Static Function
@param  oModel, object
@param  cTipo = 1-Total Passageiros, 2-Valor total
@return nSaldoAtu - Saldo atualizado
@author Karyna Martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function PasTotal(oModel, cTipo)
    Local aLinhas   := FWSaveRows()
    Local oMdl      := oModel:GetModel()
    Local oMdlH7I   := oMdl:GetModel("H7IMASTER")
    Local oMdlH7L   := oMdl:GetModel("H7LDETAIL")
    Local oMdlH7J   := oMdl:GetModel("H7JDETAIL")
    Local nX        := 1
    Local nPassag   := 0
    Local nGratui   := 0
    Local nPagant   := 0
    Local nPedagio  := 0
    Local cCodPed   := ""

    Default cTipo := ""

    For nX := 1 To oMdlH7L:Length()

        oMdlH7L:GoLine(nX)

        If !oMdlH7L:IsDeleted()
            nPassag += oMdlH7L:GetValue("H7L_NUMPAS")
            If oMdlH7L:GetValue("H7L_VLRTOT") > 0
                nPagant += oMdlH7L:GetValue("H7L_NUMPAS")
            Else
                nGratui += oMdlH7L:GetValue("H7L_NUMPAS")
            EndIf                     
        Endif

    Next nX

    If oModel:GetOperation() <> MODEL_OPERATION_DELETE .and. oModel:GetOperation() <> MODEL_OPERATION_VIEW
        H6X->(DbSetOrder(2))
        If cTipo == "1"
            oMdlH7J:LoadValue('H7J_TOTPAS', nPassag)
        ElseIf cTipo == "2"
            oMdlH7J:LoadValue('H7J_TOTGRA', nGratui)
            oMdlH7J:LoadValue('H7J_TOTPAG', nPagant)
        ElseIf cTipo == "3"                     
            If H6V->(DbSeek(xFilial("H6V")+oMdlH7J:GetValue("H7J_CODH6V"))) .And. H6V->H6V_TIPCAL == '1'                
                cCodPed := H6V->H6V_PEDAGI        
            ElseIf H6X->(DbSeek(xFilial("H6X")+oMdlH7J:GetValue("H7J_CODH6V"))) .And. H6W->(DbSeek(xFilial("H6W")+H6X->H6X_CODIGO))
                cCodPed := H6W->H6W_PEDAGI                
            EndIf            
            If H72->(DbSeek(xFilial("H72")+cCodPed)) .And. oMdlH7I:GetValue("H7I_DTSERV") >= H72->H72_DTINIV .And. oMdlH7I:GetValue("H7I_DTSERV") <= H72->H72_DTFIMV
                nPedagio :=  H72->H72_VALOR
            EndIf
            oMdlH7J:LoadValue('H7J_PEDAGI', nPassag * nPedagio)
        EndIf
    EndIf

    FWRestRows(aLinhas)

Return nPassag


//-------------------------------------------------------------------
/*/{Protheus.doc} GTPUGatH6Z
Gatilho para o campo de roleta de saida

@type Static Function
@param  oModel, object
@param  nValor = Valor da roleta de saida (ultimo digitado)
@author Breno Gomes
@since 21/08/2024
/*/
//-------------------------------------------------------------------
Static Function GTPUGatH6Z(oModel, cValor, cTpRol)

    Local oMdl      := oModel:GetModel()
    Local oModelH7J := oMdl:GetModel("H7JDETAIL")
    Local oModelH7K := oMdl:GetModel("H7KDETAIL")
    
    Default cValor   := ''
    Default cTpRol   := '2'
    
    If cTpRol == '1'
        oModelH7K:GoLine(1)
        If Empty(oModelH7K:GetValue("H7K_ROLSAI"))
            cCodRoleta := Posicione('H70', 1, xFilial('H70') + cValor, 'H70_ROLVEI')
            cValorRol  := Posicione('H6Z', 1, xFilial('H6Z') + cCodRoleta, 'H6Z_INICRO')
            oModelH7K:SetValue("H7K_CODH6Z", cCodRoleta)
            oModelH7K:SetValue("H7K_ROLENT", cValorRol)
            If oModelH7K:GetLine() == 1
                oModelH7J:SetValue("H7J_ROLENT", cValorRol)
            EndIf
        EndIf
    ElseIf cValor > 0
        oModelH7J:SetValue("H7J_ROLSAI", cValor)  
        If oModelH7K:GetLine() == 1
            oModelH7J:SetValue("H7J_ROLENT", oModelH7K:GetValue("H7K_ROLENT"))
        EndIf      
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPUGatDin
Gatilho para calcular o campo Devido dinheiro

@type Static Function
@param  oModel, object
@param  nValor = Valor da roleta de saida (ultimo digitado)
@author Breno Gomes
@since 21/08/2024
/*/
//-------------------------------------------------------------------
Static Function GTPUGatDin(oModel)

    Local oMdl      := oModel:GetModel()
    Local oModelH7I := oMdl:GetModel("H7IMASTER")
    Local nTotDin   := oModelH7I:GetValue("H7I_TOTDIN")
    Local nPgCofr   := oModelH7I:GetValue("H7I_PGCOFR")
    Local nPagDin   := oModelH7I:GetValue("H7I_PGDINH")
    
    oModelH7I:LoadValue("H7I_VLRDEV", (nTotDin - (nPgCofr + nPagDin)) )
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU13Com
Commit gtpu013, alterando o campo de roleta inicial no modelo GTPU006, assumindo agora a roleta final

@type Static Function
@param  oModel, object
@author Breno Gomes
@since 21/08/2024
/*/
//-------------------------------------------------------------------
Static function GTPU13Com(oModel)
    Local lRet       := .T.
    Local nI         := 0
    Local oMdl       := oModel:GetModel()
    Local oMdlH7J    := oMdl:GetModel("H7JDETAIL")
    Local oModelH7I  := oMdl:GetModel("H7IMASTER")
    Local oMdlH80    := Nil
    Local oModelH6Z  := Nil
    Local nOperation := oMdl:GetOperation()
    Local nH80_USER  := GetSx3Cache('H80_USER','X3_TAMANHO')
    FWFormCommit(oModel)
    If nOperation != MODEL_OPERATION_DELETE
        For nI := 1 To oMdlH7J:GetQtdLine()
            oMdlH7J:GoLine(nI)
            If !Empty(oMdlH7J:GetValue("H7J_CODH6Z")) .And. oMdlH7J:GetValue("H7J_ROLSAI") > 0
                H6Z->(DbSetOrder(1)) // H6Z_FILIAL+H6Z_CODIGO
                If H6Z->(DbSeek(xFilial("H6Z") + oMdlH7J:GetValue("H7J_CODH6Z")))
                    //Entrando em modo de alteração, para atualizar o campo H6Z_INICRO
                    oModelH6Z := FWLoadModel("GTPU006")
                    oModelH6Z:SetOperation(4)
                    oModelH6Z:Activate()
                    oModelH6Z:SetValue("H6ZMASTER","H6Z_INICRO", oMdlH7J:GetValue("H7J_ROLSAI"))
                    If H6Z->H6Z_INICRO <> oMdlH7J:GetValue("H7J_ROLSAI")
                        oMdlH80 := oModelH6Z:GetModel("H80DETAIL")
                        oMdlH80:AddLine()
                        oMdlH80:SetValue("H80_CODH7I", oModelH7I:GetValue('H7I_CODIGO'))
                        oMdlH80:SetValue("H80_CODH6Z", oMdlH7J:GetValue("H7J_CODH6Z"))
                        oMdlH80:SetValue("H80_DESCRI", GetAdvFval("H6Z","H6Z_DESCR",xFilial("H6Z")+oMdlH7J:GetValue("H7J_CODH6Z"),1))
                        oMdlH80:SetValue("H80_DTALTE", dDataBase)
                        oMdlH80:SetValue("H80_USER"  , Padr(FwGetUserName(RetCodUsr()),nH80_USER) )
                        oMdlH80:SetValue("H80_NUMINI", cValToChar(oMdlH7J:GetValue('H7J_ROLENT')))
                        oMdlH80:SetValue("H80_NUMFIN", cValToChar(oMdlH7J:GetValue('H7J_ROLSAI')))
                        oMdlH80:SetValue("H80_MOTIVO", '3')
                    EndIf 
                    If ( oModelH6Z:VldData() )
                        oModelH6Z:CommitData()
                        oModelH6Z:DeActivate()
                    Else
                        lRet := .F.
                        oModelH6Z:SetErrorMessage()
                    EndIf
                EndIf
            EndIf
        Next nI
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldRolSai
Verifica se o valor colocado na roleta final (H7K_ROLSAI) é maior que a roleta inicial

@type Static Function
@param nRolIni,   numeric - Roleta inicial
@param nRolFinal, numeric - Roleta final
@author Breno Gomes
@since 21/08/2024
/*/
//-------------------------------------------------------------------
Function VldRolSai(nRolFinal)
    Local lRet      := .T. 
    Local oMdl      := FwModelActive()
    Local oModelH7K := oMdl:GetModel("H7KDETAIL")
    Local nRolIni   := oModelH7K:GetValue('H7K_ROLENT')

    If nRolFinal > 0 .And. nRolFinal < nRolIni
        lRet := .F.
        oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0043, STR0044, STR0045)   
    EndIf 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTP013WHEN
Valida se deve alterar os campos H7K_SENTID|H7K_HRSAIP|H7K_HRCHEP

@type Static Function
@param  oModel, object
@param  cTipo = 1-Total Passageiros, 2-Valor total
@return nSaldoAtu - Saldo atualizado
@author Karyna Martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function GTP013WHEN(oModel, cField, uVal)
    Local oMdl      := oModel:GetModel()
    Local oModelH7I := oMdl:GetModel("H7IMASTER")
    Local oModelH7J := oMdl:GetModel("H7JDETAIL")
    Local oModelH7L := oMdl:GetModel("H7LDETAIL")
    Local oModelH7K := oMdl:GetModel("H7KDETAIL")
    Local lRet		:= .T.

    If (cField $ "H7I_COLETA" .And. (oModelH7I:GetValue('H7I_INTEGR') == "S" .Or. oModel:GetOperation() <> MODEL_OPERATION_INSERT));  
            .Or. (((!ExistBlock("GTPU013") .Or. !FWIsInCallStack("FWMSGRUN") ) .Or. oModelH7I:GetValue('H7I_INTEGR') == "S" ) .And. cField $ "H7L_VLRUNI" .And. !Empty(oModelH7L:GetValue('H7L_CODH6S')));
            .Or. (cField $ "H7I_DTSERV" .And. !Empty(oModelH7I:GetValue('H7I_DTSERV')) .And. !Empty(oModelH7I:GetValue('H7I_MOTORI')));
            .Or. (cField $ "H7J_CODH6V|H7J_ESCALA" .And. oModel:GetOperation() <> MODEL_OPERATION_INSERT)
        lRet := .F.
        
    ElseIf oModelH7I:GetValue('H7I_INTEGR') <> NIL .And. oModelH7I:GetValue('H7I_INTEGR') == "S"

        If cField $ "H7L_TPAGAM|H7L_NUMPAS|H7L_VLRUNI|H7L_CODH6S" .And. !Empty(oModelH7L:GetValue('H7L_TPAGAM'))
            H6R->( DbSetOrder(1) )
            If H6R->( DbSeek(xFilial("H6R")+oModelH7L:GetValue('H7L_TPAGAM')) ) .And. H6R->H6R_INCMAN == '1'
                oModelH7L:SetNoDeleteLine(.F.)
            Else
                lRet := .F.
                oModelH7L:SetNoDeleteLine(.T.) 
            EndIf
          
        ElseIf !cField $ "H7L_TPAGAM|H7L_VLRUNI|H7L_NUMPAS|H7L_CODH6S|H7J_ESCALA"
            lRet := .F.

            oModelH7J:SetNoInsertLine(.T.)
            oModelH7J:SetNoDeleteLine(.T.)
            //oModelH7K:SetNoInsertLine(.T.)   
            oModelH7K:SetNoDeleteLine(.T.)  
            oModelH7L:SetNoDeleteLine(.T.)              
            
        EndIf
    
    ElseIf cField $ "H7J_VEICUL" .And. oModelH7K:GetValue('H7K_ROLSAI')
        lRet := .F.

    EndIf
     
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldLinePost
Gatilha o ultimo valor da roleta de saida para a roleta de entrada da próxima linha se houver

@type Static Function
@param oModel, modelo GTPU013

@author Breno Gomes
@since 22/08/2024
/*/
//-------------------------------------------------------------------
Function VldLinePost(oModel)
    Local oMdl      := oModel:GetModel()
    Local oModelH7K := oMdl:GetModel("H7KDETAIL")
    Local nLinePos  := oModelH7K:GetLine()
    Local nQtdLine  := oModelH7K:GetQtdLine()
    Local nRolFinal := oModelH7K:GetValue('H7K_ROLSAI', nLinePos)

    If nRolFinal > 0 .And. nLinePos < nQtdLine
        nLinePos += 1
        oModelH7K:GoLine(nLinePos)
        oModelH7K:SetValue('H7K_ROLENT', nRolFinal)
    EndIf
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPUVldHor
Valida informações dos campos de horário

@type Static Function
@param cCampo, campo a ser validado

@author Breno Gomes
@since 23/08/2024
/*/
//-------------------------------------------------------------------
function GTPUVldHor(cCampo)
    Local lRet      := .T. 
    Local aHora     := {}
    Local oMdl      := FwModelActive()
    Local oModelH7J := oMdl:GetModel("H7JDETAIL")
    Local oModelH7K := oMdl:GetModel("H7KDETAIL")
    Local cHora     := oModelH7K:GetValue(cCampo)

    If atVldHora(cHora)//Valida a hora
        aHora := StrTokarr(cHora, ":")
        // Converte as partes para numérico
        If (Len(aHora) == 3 .And. Val(aHora[3]) > 59) .Or. Val(Substring(cHora,5,2)) > 59 //Valida os segundos, segunda validação, se acaso o registro no estiver separado por :
            lRet := .F. 
            oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0046, cCampo, STR0047) 
        EndIf
    Else 
        lRet := .F. 
        oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0046, cCampo, STR0047) 
    EndIf

    If cCampo $ 'H7K_HRSAIP|H7K_HRSAIR' //hr chegada real com hora real iniciio
        If cHora < oModelH7J:GetValue("H7J_HRRINI") 
            lRet := .F. 
            oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0046, STR0058 , STR0049) // "Horário não pode ser menor que a horário real de inicio"                                                                                                                                                                                                                                                                                                                                                                                                                                                           
        EndIf
    ElseIf cCampo $ 'H7K_HRCHEP|H7K_HRCHER'// hora saida real  com hora real fim.
        If cHora > oModelH7J:GetValue("H7J_HRRFIN")
            lRet := .F. 
            oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0046, STR0050, STR0049) // "Horário não pode ser maior que o horário real final"
        ElseIf cCampo $ 'H7K_HRCHEP' .And. cHora < oModelH7K:GetValue("H7K_HRSAIP") .And. DTOS(oModelH7J:GetValue("H7J_DATAIS")) == DTOS(oModelH7J:GetValue("H7J_DATATS"))
            lRet := .F. 
            oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0046, STR0059, STR0049) // "Horário Chegada prevista não pode ser menor que o horário saida prevista"
        ElseIf cCampo $ 'H7K_HRCHER' .and. cHora < oModelH7K:GetValue("H7K_HRSAIR") .And. DTOS(oModelH7J:GetValue("H7J_DATAIS")) == DTOS(oModelH7J:GetValue("H7J_DATATS"))
            lRet := .F. 
            oMdl:SetErrorMessage(oMdl:GetId(), "", oMdl:GetId(), "", STR0046, STR0060, STR0049) // "Horário chegada realizada não pode ser menor que o horário saida realizada"
        EndIf
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPFecVal(uNewValue, cMsgErro, cMsgSol, oModel)
Função de validação

@type Static Function
@author karyna.martins
@since 03/06/2024
/*/
//-------------------------------------------------------------------
Static Function GTPFecVal(uNewValue, cMsgErro, cMsgSol, oModel,cField)
	Local lRet      := .T.
    Local dDtFec    := DTOS(oModel:GetModel("H7IMASTER"):GetValue("H7I_DATREF"))
    Local cLocAr    := IIF(cField $ "H7I_LOCARR", uNewValue, oModel:GetModel("H7IMASTER"):GetValue("H7I_LOCARR"))
    Local aAreaH7P  := H7P->(GetArea()) 

    If !Empty(cLocAr)
        DBSelectArea("H7M")
        H7M->(dbSetOrder(1))
        If !H7M->(dbSeek(xFilial("H7M") + cLocAr ))
            lRet     := .F.
            cMsgErro :=  STR0080 // "Local de Arrecadação inválido"
            cMsgSol  :=  STR0081 // "Verifique o código informado e tente novamente"
        Endif
    EndIf

    If lRet .AND. !Empty(cLocAr)
        H7P->(dbSetOrder(2))
        If H7P->(dbSeek(xFilial("H7P") + cLocAr + dDtFec)) .And. !H7P->H7P_STATUS $ "1|4"
            lRet     := .F.
            cMsgErro :=  STR0061 // "Já existe um caixa fechado para essa data e local de arrecadação"
            cMsgSol  :=  STR0062 // "Reabrir o caixa ou realizar uma nova prestação com data e local diferentes"
        EndIf   
    EndIf  

    RestArea(aAreaH7P)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPDtSVal
Função de validação de data do serviço

@type Static Function
@author karyna.martins
@since 17/09/2024
/*/
//-------------------------------------------------------------------
Static Function GTPDtSVal(uNewValue, cMsgErro, cMsgSol, oModel, cCampo)
    Local lRet    := .T.
    Local cDtRef  := DTOS(oModel:GetModel("H7IMASTER"):GetValue("H7I_DATREF"))
    Local cDtServ := DTOS(oModel:GetModel("H7IMASTER"):GetValue("H7I_DTSERV"))
    Local cDtTSer := IIF(!Empty(oModel:GetModel("H7IMASTER"):GetValue("H7I_DTSERV")), DTOS(oModel:GetModel("H7IMASTER"):GetValue("H7I_DTSERV")+1), "")

    If cCampo $ 'H7I_DATREF|H7I_DTSERV'.And. DTOS(uNewValue) > DTOS(ddatabase)
        lRet     := .F.
        cMsgErro := STR0034 // "Data informada maior que a data do sistema "
        cMsgSol  := STR0035 // "É necessário informar uma data menor ou igual do sistema"
    Else
        If (!Empty(DtoS(FwFldGet("H7J_DATATS"))) .And. DtoS(FwFldGet("H7J_DATATS")) < DtoS(FwFldGet("H7J_DATAIS"))) 
            lRet     := .F.
            cMsgErro :=  STR0063 // "Data inicio maior que Data término"
            cMsgSol  :=  STR0064 // "Digite uma data válida"
        ElseIf DtoS(FwFldGet("H7J_DATAIS")) > cDtRef .Or. DtoS(FwFldGet("H7J_DATATS")) > DTOS(oModel:GetModel("H7IMASTER"):GetValue("H7I_DATREF")+1)
            lRet     := .F.
            cMsgErro :=  STR0065 // "Data do serviço maior que a Data da prestação"
            cMsgSol  :=  STR0064 // "Digite uma data válida"
        ElseIf (!Empty(cDtServ) .And. !Empty(DtoS(FwFldGet("H7J_DATAIS"))) .And. DtoS(FwFldGet("H7J_DATAIS")) > cDtServ) ;
            .Or. (!Empty(cDtTSer) .And. !Empty(DtoS(FwFldGet("H7J_DATATS"))) .And. DtoS(FwFldGet("H7J_DATATS")) > cDtTSer )

            lRet     := .F.
            cMsgErro :=  STR0066 // "Data do inicio/término do serviço maior que a Data do serviço"
            cMsgSol  :=  STR0064 // "Digite uma data válida"

        ElseIf (!Empty(cDtServ) .And. !Empty(DtoS(FwFldGet("H7J_DATAIS"))) .And. DtoS(FwFldGet("H7J_DATAIS")) < cDtServ) ;
            .Or. (!Empty(cDtServ) .And. !Empty(DtoS(FwFldGet("H7J_DATATS"))) .And. DtoS(FwFldGet("H7J_DATATS")) < cDtServ )

            lRet     := .F.
            cMsgErro :=  STR0067 // "Data do inicio/término do serviço menor que a Data do serviço"
            cMsgSol  :=  STR0064 // "Digite uma data válida"

        EndIf   
    EndIf                                                             

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPDtSVal
Função de validação do tipo de pagamento

@type Static Function
@author karyna.martins
@since 17/09/2024
/*/
//-------------------------------------------------------------------
Static Function GTPValDig(uNewValue, cMsgErro, cMsgSol, oModel, cCampo)

    Local cAlias   := GetNextAlias()
    Local cQuery   := ''
    Local lRet     := .F.

    If cCampo == 'H7L_TPAGAM'       //Valida forma de pagamento
        cQuery := QryFormPag(FWFldGet("H7I_INTEGR") == "S")
    ElseIf cCampo == 'H7L_CODH6S'   // Valida tarifa
        cQuery := QryTarifas()
    ElseIf cCampo == 'H7J_ESCALA'   // Valida escala
        cQuery := QryEscala()
    EndIf

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F. )

    While !(cAlias)->( EOF() )
        If uNewValue == (cAlias)->CODIGO
            lRet     := .T.
        EndIf
        (cAlias)->(DbSkip())
    End

    (cAlias)->(DbCloseArea())

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} QryTarifas
Aplica filtro para trazer as tarifas vinculadas a linha e o tipo de pagamento

@type Function
@return cQuery - Query para a tabela de tarifa
@author Breno Gomes
@since  16/09/2024
/*/
//-------------------------------------------------------------------
Function QryTarifas()
Local cQuery    := ''
Local oMdlH7I	:= Nil
Local oMdlH7L	:= Nil
Local oMdlH7J   := Nil
Local oModel    := FwModelActive()

    oMdlH7I := oModel:GetModel("H7IMASTER")
    oMdlH7J := oModel:GetModel("H7JDETAIL")
    oMdlH7L := oModel:GetModel("H7LDETAIL")

    cQuery += " SELECT CASE"
    cQuery +=   " WHEN H6V.H6V_TIPCAL = 1 "
    cQuery +=       " THEN H79.H79_CODH6S "
    cQuery +=   " WHEN H6V.H6V_TIPCAL = 2 "
    cQuery +=       " THEN H85.H85_CODH6S "
    cQuery +=   " WHEN H6V.H6V_TIPCAL = 3 "
    cQuery +=       " THEN COALESCE(H85.H85_CODH6S, H79.H79_CODH6S) "
    cQuery +=   " END AS CODIGO "
    cQuery += " FROM " + RetSqlName('H6S') + " H6S "
    cQuery += " INNER JOIN " + RetSqlName('H6U') + " H6U"
    cQuery +=         " ON H6U.H6U_FILIAL = '" + xFilial( "H6U" ) + "' "
    cQuery +=            " AND H6U.H6U_CODH6R = '" +oMdlH7L:GetValue("H7L_TPAGAM")+ "'"
    cQuery +=            " AND H6U.H6U_CODH6S = H6S_CODIGO"
    cQuery +=            " AND H6U.D_E_L_E_T_ = ''"
    cQuery += " INNER JOIN " + RetSqlName('H6V') + " H6V ""
	cQuery +=         " ON H6V.H6V_FILIAL = '" + xFilial( "H6V" ) + "' "
	cQuery +=            " AND H6V.H6V_CODIGO = '" + oMdlH7J:GetValue("H7J_CODH6V") + "'"
	cQuery +=            " AND H6V.D_E_L_E_T_ = '' "
    cQuery += " LEFT JOIN " + RetSqlName('H79') + " H79"
    cQuery +=         " ON H79.H79_FILIAL = '" + xFilial( "H79" ) + "' "
    cQuery +=            " AND H79.H79_CODH6V = H6V.H6V_CODIGO"
    cQuery +=            " AND H79.H79_CODH6S = H6U.H6U_CODH6S"
    cQuery +=            " AND H79.D_E_L_E_T_ = ''"
    cQuery += " LEFT JOIN " + RetSqlName('H6X') + " H6X "
	cQuery +=         " ON H6X.H6X_FILIAL = '" + xFilial( "H6X" ) + "' "
	cQuery +=           " AND H6X_CODLIN = H6V.H6V_CODIGO
	cQuery +=           " AND H6X.D_E_L_E_T_ = ''
    cQuery += " LEFT JOIN " + RetSqlName('H85') + " H85 "
    cQuery +=         " ON H85.H85_FILIAL   = '" + xFilial( "H85" ) + "' "
    cQuery +=           " AND H85_CODH6W = H6X.H6X_CODIGO "
    cQuery +=           " AND H85.H85_CODH6S  = H6U.H6U_CODH6S "
    cQuery +=           " AND H85.D_E_L_E_T_   = '' "
    cQuery += " WHERE H6S.H6S_FILIAL = '" + xFilial( "H6S" ) + "' " 
    cQuery +=       " AND ('" + DTOS(oMdlH7I:GetValue("H7I_DTSERV")) + "' BETWEEN H6S.H6S_DTINIV AND H6S.H6S_DTFIMV ) "
    cQuery +=       " AND H6S.D_E_L_E_T_ = ''"

Return cQuery 

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFormPag
Query para as formas de pagamento conforme linha selecionada

@type Function
@return cQuery - Query para a tabela de tarifa
@author Karyna Martins
@since  29/11/2024
/*/
//-------------------------------------------------------------------
Function QryFormPag(lInteg)
    Local cQuery    := ''

    Default lInteg  := .F.

    cQuery +=       " SELECT H6R_CODIGO CODIGO "
    cQuery +=       " FROM " + RetSqlName('H6R') + " H6R "

    If !lInteg .And. !Empty(FWFldGet("H7J_CODH6V"))
        cQuery +=   " INNER JOIN " + RetSqlName('H79') + " H79 "
        cQuery +=      " ON H79.H79_FILIAL = '" + xFilial( "H79" ) + "' "
        cQuery +=          " AND H79.H79_CODH6V = '" + FWFldGet("H7J_CODH6V")+ "' "
        cQuery +=          " AND H79.H79_DTEXCL = '' "
        cQuery +=          " AND H79.D_E_L_E_T_ = '' "
        cQuery +=   " INNER JOIN  " + RetSqlName('H6U') + " H6U "
        cQuery +=       " ON H6U.H6U_FILIAL = '" + xFilial( "H6U" ) + "' "
        cQuery +=          " AND H6U.H6U_CODH6S = H79.H79_CODH6S "
        cQuery +=          " AND H6U.H6U_CODH6R = H6R_CODIGO "
        cQuery +=          " AND H6U.D_E_L_E_T_ = '' "
    EndIf

    cQuery +=       " WHERE H6R.H6R_FILIAL = '" + xFilial( "H6R" ) + "' "

    If lInteg 
        cQuery +=   " AND H6R.H6R_INCMAN = '1' " "
    EndIf

    cQuery +=       " AND H6R.D_E_L_E_T_ = '' "

Return cQuery 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU13GTar
Gatilho para o campo de tarifas, de acordo com o tipo de pagamento selecionado

@type Function
@return cTarifa - Primeira tarifa encontrada
@author Breno Gomes
@since  16/09/2024
/*/
//-------------------------------------------------------------------
Function GTPU13GTar()
Local cAlias   := GetNextAlias()
Local cQuery   := QryTarifas()
Local cTarifa  := ''

    cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(, , cQuery), cAlias, .F., .F. )

    If !(cAlias)->( EOF() )
        cTarifa := (cAlias)->CODIGO 
    EndIf
    
Return cTarifa

//-------------------------------------------------------------------
/*/{Protheus.doc} QryEscala
Query conforme as linhas selecionadas

@type Function
@return cTarifa - Primeira tarifa encontrada
@author Karyna Martins
@since  29/11/2024
/*/
//-------------------------------------------------------------------
Function QryEscala()
    Local cQuery    := ''

    cQuery += " SELECT H76_CODIGO CODIGO"
    cQuery += " FROM  " + RetSqlName('H76') + " H76 "
    cQuery += " INNER JOIN " + RetSqlName('H77') + " H77 "
    cQuery +=   " ON H77.H77_FILIAL = '" + xFilial( "H79" ) + "' " 
    cQuery +=       " AND H77.H77_CODH76 = H76.H76_CODIGO
    cQuery +=       " AND H77.H77_CODH6V = '" + FWFldGet("H7J_CODH6V")+ "' "
    cQuery +=       " AND H77.D_E_L_E_T_ = ''
    cQuery += " WHERE H76.H76_FILIAL = '" + xFilial( "H79" ) + "' "
    cQuery +=       " AND H76.D_E_L_E_T_ = ''
    cQuery += " GROUP BY H76_CODIGO
    
Return cQuery
