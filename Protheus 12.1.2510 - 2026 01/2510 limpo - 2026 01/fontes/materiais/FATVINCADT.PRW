#Include 'Totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FATVINCADT.CH'

Static _jFatVinc := JsonObject():New()

Function FATVINCADT()
    
//   Local NOPC := 1
//  Local  oModel := Nil
//  Local oMdlCab := Nil
// Local aButtons := { {.F., Nil},;            //- Copiar
// 							{.F., Nil},;            //- Recortar
// 							{.F., Nil},;            //- Colar
// 							{.F., Nil},;            //- Calculadora
// 							{.F., Nil},;            //- Spool
// 							{.F., Nil},;            //- Imprimir
// 							if(nOpc==1,{.T., 'Confirmar'},{.F., Nil}),;        //- 'Enviar'
// 							{.T., 'Cancelar'},;        //- 'Cancelar'
// 							{.F., Nil},;            //- WalkThrough
// 							{.F., Nil},;            //- Ambiente
// 							{.F., Nil},;            //- Mashup
// 							{.F., Nil},;            //- Help
// 							{.F., Nil},;            //- Formulário HTML
// 							{.F., Nil},;            // - ECM
// 							{.F., Nil}}             // - Desabilitar o botão Salvar e Criar Novo
 
//  oModel := FWLoadModel('FATVINCADT')
//  oModel:SetOperation(3)
//  oModel:Activate()
//  oMdlCab :=oModel:GetModel("MASTER")

//  oMdlCab:SetValue('E1_CLIENTE','FIN501')//'FIN501' //Obrigatório
//  oMdlCab:SetValue('E1_LOJA','01')//'01' //Obrigatório

//     FWExecView('Vincular Adiantamentos', 'FATVINCADT', MODEL_OPERATION_INSERT, /*oDlg*/, {||.T.}, /*bOk*/, 10, aButtons, /*bCancel*/, /*cOperatId*/, /*cToolBar*/, )

Return

/*/{Protheus.doc} ModelDef
 Realiza a montagem do modelo de dados.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function ModelDef() As Object
    Local oStrCab	As Object
	Local oStrFil	As Object
	Local oModel	As Object

    oStrCab	:= FieldsModel(.T.)
    oStrFil	:= FieldsModel()
    oModel	:= Nil
    
	oModel := MPFormModel():New('FATVINCADT',Nil,Nil ,{|| VincAdtId()} ) 

	oModel:SetDescription( STR0002 )

	oModel:AddFields( 'MASTER', , oStrCab )
	oModel:GetModel( 'MASTER' ):SetDescription( STR0003 ) 
    oModel:SetPrimaryKey({'OK'})

	oModel:AddGrid( 'DETAIL', 'MASTER', oStrFil, /*bLinPre*/, /*bLinPos*/ ,,, )
	oModel:GetModel( 'DETAIL' ):SetDescription( STR0004 ) 
	oModel:GetModel('DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel( 'DETAIL' ):SetOptional(.T.)

	oStrFil:SetProperty( '*' , MODEL_FIELD_OBRIGAT, .F. )

	oModel:SetActivate( { |oModel| BuscarReg() } )

Return oModel
/*/{Protheus.doc} ViewDef
 Realiza a montagem da view.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel    As Object
	Local oView     As Object
    Local oStrCab	As Object
	Local oStrFil	As Object
    
    oModel      := FWLoadModel('FATVINCADT')
    oView       := FWFormView():New()
    oStrCab	    := FieldsView(.T.)
    oStrFil	    := FieldsView()

	oStrCab:SetProperty('E1_CLIENTE',MVC_VIEW_CANCHANGE, .F.)
	oStrCab:SetProperty('E1_LOJA',MVC_VIEW_CANCHANGE, .F.)

	oStrFil:SetProperty('*',MVC_VIEW_CANCHANGE, .F.)

	oStrFil:SetProperty('OK',MVC_VIEW_CANCHANGE, .T.)

	oView:SetModel(oModel)
	oView:AddField('VIEW_CAB'	, oStrCab, 'MASTER')
	oView:AddGrid( 'VIEW_FILT' , oStrFil, 'DETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR'   , 30 )   
	oView:CreateHorizontalBox( 'INFERIOR'   , 70 )

    oView:CreateVerticalBox( 'EMCIMAESQ', 90, 'SUPERIOR' )
	oView:CreateVerticalBox( 'EMCIMADIR', 10, 'SUPERIOR' )

    oView:SetOwnerView( 'VIEW_CAB', 'EMCIMAESQ') 
    oView:SetOwnerView('VIEW_FILT', 'INFERIOR')

	oView:AddOtherObject('PANEL1', {|oPanel| COMP41BUT1(oPanel)}) //Limpar Tela
	oView:SetOwnerView('PANEL1','EMCIMADIR')

	oView:AddOtherObject('PANEL2', {|oPanel| COMP41BUT2(oPanel)}) //Buscar
	oView:SetOwnerView('PANEL2','EMCIMADIR')

	
	oStrCab:AddGroup( 'GRP_FATVINCADT_001', 'Filtros', '', 2 )

	oStrCab:SetProperty( '*'  , MVC_VIEW_GROUP_NUMBER, 'GRP_FATVINCADT_001' )

	oView:showInsertMsg(.F.) // -- Desativa a mensagem registro inserido.
	oView:SetViewAction('ASKONCANCELSHOW', {|oView| .F.}) // -- Desativa mensagem de 'há alterações não salvas'

Return oView
/*/{Protheus.doc} COMP41BUT2
 Adiciona o Botão Limpar Tela no painel.

@param oPanel -> Painel
@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function COMP41BUT1( oPanel )
	@ 10, 10 Button STR0005 Size 36, 13 Message STR0005 Pixel Action LimpaTela() of oPanel
Return 
//------------------------------------------------------------------------------
/*/{Protheus.doc} COMP41BUT2
 Adiciona o Botão Buscar no painel.

@param oPanel -> Painel
@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function COMP41BUT2( oPanel )
	@ 30, 10 Button STR0006 Size 36, 13 Message STR0006 Pixel Action FWMsgRun(, {|| BuscarReg()}, STR0010, STR0011) of oPanel
Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetColsIt
 Realiza o retorno dos campos da Grid.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function GetColsIt() As Array
    Local aCpoInfo  As Array  

    aCpoInfo  := {}

    aAdd(aCpoInfo, {STR0007                                          , 'OK'               ,'L'   ,'@!'    , 2      , {||.T.}})
    aAdd(aCpoInfo, {GetSX3Cache('FK7_IDDOC'    ,'X3_TITULO')          , 'id'               ,'C'   ,'@!'    ,GetSX3Cache('FK7_IDDOC'      ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_FILIAL'    ,'X3_TITULO')         ,'billBranch'        ,'C'   ,'@!'    ,GetSX3Cache('E1_FILIAL'     ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_PREFIXO'    ,'X3_TITULO')        , 'billPrefix'       ,'C'   ,'@!'    ,GetSX3Cache('E1_PREFIXO'    ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_NUM'    ,'X3_TITULO')            ,'billNumber'        ,'C'   ,'@!'    ,GetSX3Cache('E1_NUM'        ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_PARCELA'    ,'X3_TITULO')        ,'billInstal'        ,'C'   ,'@!'    ,GetSX3Cache('E1_PARCELA'    ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_TIPO'    ,'X3_TITULO')           ,'billType'          ,'C'   ,'@!'    ,GetSX3Cache('E1_TIPO'       ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_CLIENTE'    ,'X3_TITULO')        ,'partCode'          ,'C'   ,'@!'    ,GetSX3Cache('E1_CLIENTE'    ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_LOJA'    ,'X3_TITULO')           ,'partUnit'          ,'C'   ,'@!'    ,GetSX3Cache('E1_LOJA'       ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_NOMCLI'    ,'X3_TITULO')        ,'partic'            ,'C'   ,'@!'    ,GetSX3Cache('E1_NOMCLI'    ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_MOEDA'    ,'X3_TITULO')          ,'billCurr'          ,'N'   ,'@!'    ,GetSX3Cache('E1_MOEDA'      ,'X3_TAMANHO')      ,Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_VALOR'    ,'X3_TITULO')          ,'billValue'         ,'N'   ,'@!'    ,GetSX3Cache('E1_VALOR'      ,'X3_TAMANHO')      ,Nil})

Return aCpoInfo
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetFldCab
 Realiza o retorno dos campos do cabeçalho.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function GetFldCab() As Array
    Local aCpoInfo As Array

    aCpoInfo  := {}

    aAdd(aCpoInfo, {GetSX3Cache('E1_CLIENTE'    ,'X3_TITULO')          ,'E1_CLIENTE'          ,'C'     ,PesqPict('SE1','E1_CLIENTE')    ,GetSX3Cache('E1_CLIENTE', 'X3_TAMANHO')    , Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_LOJA'       ,'X3_TITULO')          ,'E1_LOJA'             ,'C'     ,PesqPict('SE1','E1_LOJA')       ,GetSX3Cache('E1_LOJA', 'X3_TAMANHO')   , Nil})
    aAdd(aCpoInfo, {GetSX3Cache('E1_NUM'        ,'X3_TITULO')          ,'E1_NUM'              ,'C'     ,PesqPict('SE1','E1_NUM')        ,GetSX3Cache('E1_NUM', 'X3_TAMANHO') , Nil })
    aAdd(aCpoInfo, {GetSX3Cache('E1_PREFIXO'    ,'X3_TITULO')          ,'E1_PREFIXO'          ,'C'     ,PesqPict('SE1','E1_PREFIXO')    ,GetSX3Cache('E1_PREFIXO', 'X3_TAMANHO') , Nil })
    aAdd(aCpoInfo, {STR0008                                            ,'DTINI'               ,'D'     ,Nil                             ,GetSX3Cache('E1_EMISSAO', 'X3_TAMANHO'), Nil })
    aAdd(aCpoInfo, {STR0009                                            ,'DTFIM'               ,'D'     ,Nil                             ,GetSX3Cache('E1_VENCTO', 'X3_TAMANHO'), Nil })
   
Return aCpoInfo
//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldsModel
 Realiza o retorno da estrutura dos campos do MODEL.

@param lCab = .T. -> Retorno da estrutura de campos do cabeçalho / .F. ->  Retorno da estrutura de campos da Grid
@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function FieldsModel(lCab) As Object
    Local oStructMn	 As Object
    Local aColIt     As Array
    Local aFldCab    As Array
    Local nX         As Number
    Default   lCab   := .F.

    oStructMn	 := FWFormModelStruct():New()
    aColIt     := {}
    aFldCab    := {}
    nX         := 1
    
    If lCab
        aFldCab :=  GetFldCab()
        For nX :=1 to Len(aFldCab)
		    oStructMn:AddField(aFldCab[nX][1] ,aFldCab[nX][1]  ,aFldCab[nX][2]  , aFldCab[nX][3], aFldCab[nX][5] )
        Next nX
    Else
        aColIt := GetColsIt()
        For nX:= 1  To Len(aColIt)
            oStructMn:AddField(aColIt[nX][1] ,aColIt[nX][1]  ,aColIt[nX][2]  , aColIt[nX][3], aColIt[nX][5], 0,aColIt[nX][6] ,Nil , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, '.F.'))
	    Next nX
    EndIf
		
Return oStructMn
//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldsView
 Realiza o retorno da estrutura dos campos da VIEW.

@param lCab = .T. -> Retorno da estrutura de campos do cabeçalho / .F. ->  Retorno da estrutura de campos da Grid
@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function FieldsView(lCab) As Object
    Local oStructMn	As Object
    Local aColIt    As Array
    Local aFldCab    As Array
    Local nX        As Number
    Default   lCab       := .F.

    oStructMn	:= FWFormViewStruct():New()
    aColIt      := {}
    aFldCab     := {}
    nX          := 1

    If lCab
		  aFldCab := GetFldCab()
        For nX:= 1  To Len(aFldCab)
	        oStructMn:AddField(aFldCab[nX][2] , cValToChar(nX) , aFldCab[nX][1]  , aFldCab[nX][1], , aFldCab[nX][3], aFldCab[nX][4] , , aFldCab[nX][6], .T., , , , , , .T., ,  )
	    Next nX
    Else
        aColIt := GetColsIt()
        For nX:= 1  To Len(aColIt)
	        oStructMn:AddField(aColIt[nX][2] , cValToChar(nX) , aColIt[nX][1]  , aColIt[nX][1], {}, aColIt[nX][4] )
	    Next nX
    EndIf
		
Return oStructMn
//------------------------------------------------------------------------------
/*/{Protheus.doc} BuscarReg
 Realiza a carga de dados na tabela.

@author CRM/Faturamento
@since 11/25
/*/
//------------------------------------------------------------------------------
Static Function BuscarReg() 
    Local jParam        As Json
    Local jResponse     As Json
    Local oObj          As Object
    Local oModel        As Object
	Local oMdlItens     As Object
    Local lHasNext      As Logical
    Local nPage         As Number
    Local nI            As Number
    Local aItensSelec    As Array
    
    jParam        := GetJParFin()
    jResponse     := JsonObject():new()
    oObj          := Nil
    oModel        := FwModelActive()
    oMdlItens     := Nil
    aItensSelec   :=  _jFatVinc['identification']
    lHasNext      := .T.
    nPage         := 1
    nI            := 1

    oObj := totvs.protheus.backoffice.fin.debittaxinvoice.debittaxinvoice():new()
    
	oMdlItens := oModel:GetModel('DETAIL')

    oObj:setParameters(jParam)

    oMdlItens:ClearData(.T.)

    while lHasNext
        jResponse := oObj:getAdvanceReceivable(nPage++)
        if jResponse:hasProperty('hasNext')
            lHasNext := jResponse['hasNext']
            If !Empty(jResponse['items']) .And. Len(jResponse['items']) > 0
                For nI := 1 to len(jResponse['items'])
                	if nI > 1
							oMdlItens:AddLine()
					Endif
                    If Ascan(aItensSelec, jResponse['items'][nI]['identification']) > 0
                         oMdlItens:LoadValue( 'OK'         ,.T.)
                    EndIF

                    oMdlItens:LoadValue( 'id'         ,jResponse['items'][nI]['identification'])
                    oMdlItens:LoadValue(  'billBranch' , jResponse['items'][nI]['billBranch'])
                    oMdlItens:LoadValue(  'billPrefix' , jResponse['items'][nI]['billPrefix'])
                    oMdlItens:LoadValue(  'billInstal' , jResponse['items'][nI]['billInstallment'])
                    oMdlItens:LoadValue(  'billType'   ,jResponse['items'][nI]['billType'])
                    oMdlItens:LoadValue(  'partCode'   ,jResponse['items'][nI]['participantCode'])
                    oMdlItens:LoadValue(  'partUnit'   ,jResponse['items'][nI]['participantUnit'])
                    oMdlItens:LoadValue(  'partic'     ,jResponse['items'][nI]['participantName'])
                    oMdlItens:LoadValue(  'billCurr'   ,jResponse['items'][nI]['billCurrency'])
                    oMdlItens:LoadValue(  'billValue'  ,jResponse['items'][nI]['billValue'])
                    oMdlItens:LoadValue(  'billNumber' , jResponse['items'][nI]['billNumber'])
                Next
            Else
                oMdlItens:LoadValue( 'OK'          ,.F.)
                oMdlItens:LoadValue( 'id'          ,"")
                oMdlItens:LoadValue(  'billBranch' ,"")
                oMdlItens:LoadValue(  'billPrefix' ,"")
                oMdlItens:LoadValue(  'billInstal' ,"")
                oMdlItens:LoadValue(  'billType'   ,"")
                oMdlItens:LoadValue(  'partCode'   ,"")
                oMdlItens:LoadValue(  'partUnit'   ,"")
                oMdlItens:LoadValue(  'partic'     ,"")
                oMdlItens:LoadValue(  'billCurr'   ,1)
                oMdlItens:LoadValue(  'billValue'  ,0)
                oMdlItens:LoadValue(  'billNumber' ,"")
            EndIf
        Else
            lHasNext := .F.
        EndIf
    EndDo
    
    oMdlItens:GoLine(1)
    oMdlItens:SetNoInsertLine(.T.)
    
   RefreView()
 
Return 
/*/{Protheus.doc} GetJParFin
 Realiza a montagem e retorno do JSON para consumo da classe do Fin.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function GetJParFin() As Object
    Local jParam        As Json
    Local oModel        As Object
    Local oMdlCab       As Object
	Local oMdlItens     As Object

    Local cPref         As Character
    Local cNum          As Character
    Local dEmisao       As Date
    Local dVenc         As Date
    Local jFld600       As Json
    
    jParam        := JsonObject():new()
    oModel        := FwModelActive()
    oView         := FwViewActive()
    oMdlCab       := Nil
    oMdlItens     := Nil
 
	oMdlCab := oModel:GetModel('MASTER')
	oMdlItens := oModel:GetModel('DETAIL')

    jFld600    := GetJfld600()
    oMdlCab:SetValue('E1_CLIENTE',jFld600['A1_COD'])
    oMdlCab:SetValue('E1_LOJA'   ,jFld600['A1_LOJA'])

    jParam['billBranch']      := cFilAnt //Obrigatório
    jParam['participantCode'] := jFld600['A1_COD']//Obrigatório
    jParam['participantUnit'] := jFld600['A1_LOJA'] //Obrigatório
    
    cPref    := oMdlCab:GetValue('E1_PREFIXO')
    cNum     := oMdlCab:GetValue('E1_NUM') 
    dEmisao  := oMdlCab:GetValue('DTINI')
    dVenc    := oMdlCab:GetValue('DTFIM')
    
    //Campos Opcionais
    If !Empty(cPref)
        jParam['billPrefix'] := cPref
    EndIf
    If !Empty(cNum)
        jParam['billNumber'] := cNum
    EndIf
    If !Empty(dEmisao)
        jParam['FromDate'] := dEmisao
    EndIf
    If !Empty(dVenc)
        jParam['ToDate'] := dVenc
    EndIf
Return  jParam
/*/{Protheus.doc} LimpaTela
 Realiza a limpeza da view.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function LimpaTela()
	Local oModel    As Object
	Local oMdlFil   As Object
	Local oMdlCab   As Object

    oModel    := FwModelActive()
    oMdlCab   := oModel:GetModel('MASTER')
    oMdlFil   := oModel:GetModel('DETAIL')

    _jFatVinc:DelName("billPrefix")
    _jFatVinc:DelName("billNumber")
    _jFatVinc:DelName("FromDate")
    _jFatVinc:DelName("ToDate")

    oMdlCab:SetValue('E1_PREFIXO', '')
    oMdlCab:SetValue('E1_NUM', '')
    oMdlCab:SetValue('DTINI', cToD('  /  /    '))
    oMdlCab:SetValue('DTFIM', cToD('  /  /    '))

	If oMdlFil:CanClearData()
		oMdlFil:ClearData(.T.)
	EndIf

	RefreView()

Return
/*/{Protheus.doc} VincAdtId
 Realiza a ação ao selecionar os dados da grid e clicar em confirmar.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Function VincAdtId() As Logical
	Local oModel    As Object
	Local oMdlCab   As Object
	Local oMdlDet   As Object
    Local cId       As Character
    Local nX        As Number
    Local jParam    As Json
    Local nTotTit   As Number

    oModel      := FwModelActive()
    oMdlCab     := oModel:GetModel('MASTER')
    oMdlDet     := oModel:GetModel('DETAIL')
    oDebitT     := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():New()
    jParam      := GetJParFin()
    nTotTit     := 0
   
    _jFatVinc := jParam
    _jFatVinc['identification'] := {}
    oDebitT:setParameters(jParam)
    
    For nX:= 1 To oMdlDet:GetQtdLine()
        oMdlDet:Goline(nX) 
        cId := oMdlDet:GetValue('id')

        If oMdlDet:GetValue('OK') .And. oDebitT:setBillLock(cId)
             AADD(_jFatVinc['identification'], cId)
             nTotTit += oMdlDet:GetValue('billValue')
        EndIf

    Next nX

        _jFatVinc['totalTitulos'] := nTotTit
Return .T.

/*/{Protheus.doc} GetJVAdt
 Realiza o GET dos dados dos itens selecionados na GRID.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Function GetJVAdt() As Json
Return _jFatVinc
/*/{Protheus.doc} SetJVAdt
 Seta o valor para do _jFatVinc somente utilizada para execução de rotina automatica.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Function SetJVAdt(jVAdt) 
_jFatVinc := jVAdt
 
Return 
/*/{Protheus.doc} PrepGrav
 Realiza a preparação e gravação dos registros com a função prepareRecordF7Q.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Function FatPrepGrv() As Logical
    Local oDebitTax         As Object
    Local jParam            As Json
    Local lResult           As logical
    Local jFld600           As Json
 
    oDebitTax    := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():New()
    jParam       := GetJVAdt()
    jFld600      := GetJfld600()
    
    jParam['documentBranch']    := cFilAnt
    jParam['documentNumber']    := jFld600['F2_DOC']
    jParam['documentSeries']    := jFld600['F2_SERIE']
    jParam['mainSourceTable']   := "SF2"
     
    oDebitTax:setParameters(jParam)
    oDebitTax:prepareRecordF7Q()
 
    // Realiza a gravação do registro na tabela F7Q
    lResult := oDebitTax:recordInsertF7Q()
 
Return lResult
/*/{Protheus.doc} PrepGrav
 Realiza a preparação e gravação dos registros com a função prepareRecordF7Q.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Function FatPrepDel(cDoc, cSerie, cCliente, cLoja) As Logical
    Local oDebitTax         As Object
    Local jParam            As Json
    Local lResult           As logical

    Default cDoc     := ""
    Default cSerie   := ""
    Default cCliente := ""
    Default cLoja    := ""

    oDebitTax    := totvs.protheus.backoffice.fin.debittaxinvoice.DebitTaxInvoice():New()
    jParam       := GetJVAdt()
    
    jParam['billBranch']        := cFilAnt 
    jParam['participantCode']   := cCliente
    jParam['participantUnit']   := cLoja
    jParam['documentBranch']    := cFilAnt
    jParam['documentNumber']    := cDoc
    jParam['documentSeries']    := cSerie
    jParam['mainSourceTable']   := "SF2"

    oDebitTax:setParameters(jParam)
    lCanDelete := oDebitTax:validateDeletionF7Q(jParam)
 
    If lCanDelete
        oDebitTax:prepareDeletionF7Q()
        lDeleted := oDebitTax:recordDeletionF7Q()
    EndIf
 
Return lResult

/*/{Protheus.doc} RefreView
 Realiza o refresh da View.

@author CRM/Faturamento
@since 10/25
/*/
//------------------------------------------------------------------------------
Static Function RefreView()
    Local oView As Object

    oView := FwViewActive()
    
    If  oView <> Nil .And. oView:IsActive()
        oView:Refresh()
    EndIf

Return
