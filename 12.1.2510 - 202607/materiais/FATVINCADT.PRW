#Include 'Totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FATVINCADT.CH'

Static _jFatVinc := JsonObject():New()
Static __oQryAdt := Nil

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

//------------------------------------------------------------------------------
/*/{Protheus.doc} GrvAdtDKN
	Realiza a gravação da tabela DKN durante o faturamento 
    de um pedido de venda com um RA vinculado a Nota de Debito.

    @param cPrefRA, caractere, Prefixo do título RA
    @param cNumRA, caractere, Numero do título RA
    @param cCliente, caractere, Código do cliente
    @param cLoja, caractere, Loja do cliente
    @param cDocNF, caractere, Número do Documento de Saída
    @param cSerieNF, caractere, Série do Documento de Saída

    @Return .T., logico, Retorno sempre verdadeiro
    @author CRM/Faturamento
    @since 01/2026
/*/
//------------------------------------------------------------------------------
Function GrvAdtDKN(cPrefRA as character, cNumRA as character, cCliente as character, cLoja as character, cDocNF as character, cSerieNF as character) as logical
	Local aDados   	 as array 
    Local aAdianta   as array 
    Local aInsParam	 as array
	Local aItVinc 	 as array
    Local aQtdItens  as array
	Local cItem		 as character
    Local cQtdNF     as character
	Local cFilDKN	 as character
    Local cFilFIE	 as character
    Local lAdComPart as logical
    Local nX 		 as numeric
    Local nZ 		 as numeric
    Local cQuery     as character
    Local cAliasSQL  as character

	Default cPrefRA     := ""
    Default cNumRA      := ""
    Default cCliente    := ""
    Default cLoja       := ""
    Default cDocNF      := ""
    Default cSerieNF    := ""

	aDados 		:= {}
    aInsParam   := {}
	aItVinc 	:= {}
	cItem		:= "00"
    cQtdNF      := "00"
	cFilDKN		:= FwXFilial("DKN")
	nX 			:= 1
    nZ          := 1
    aAdianta    := CfgAdianta()
    lAdComPart  := 'C' $ aAdianta[1,1]+aAdianta[1,2]+aAdianta[1,3]
    cFilFIE     := Iif(lAdComPart,cFilAnt,FWxFilial("FIE"))
    cQuery      := ""
    cAliasSQL   := ""

    aQtdItens := NDItens(cDocNF + cSerieNF + cCliente + cLoja)

    If __oQryAdt == Nil
        cQuery    := GetNDQry(lAdComPart)
        __oQryAdt := FwExecStatement():New(cQuery)
    EndIf

    aAdd(aInsParam, FwXFilial("FK7"))
    aAdd(aInsParam, 'RA')
    aAdd(aInsParam, FwXFilial("F7Q"))
    aAdd(aInsParam, 'SF2')
    aAdd(aInsParam, FwXFilial("SF2"))
    aAdd(aInsParam, cFilFIE)
    aAdd(aInsParam, 'R')
    aAdd(aInsParam, 'RA')
    aAdd(aInsParam, cCliente)
    aAdd(aInsParam, cLoja)
    aAdd(aInsParam, cDocNF)
    aAdd(aInsParam, cSerieNF)
    aAdd(aInsParam, ' ')

    For nX := 1 to Len(aInsParam)
        __oQryAdt:SetString(nX, aInsParam[nX])
    Next nX

    cAliasSQL := __oQryAdt:OpenAlias()

    While (cAliasSQL)->(!Eof())

        cQtdNF := Soma1(cQtdNF)
        For nZ := 1 to Len(aQtdItens)
            cItem := aQtdItens[nZ]

            RecLock("DKN",.T.)
            // -- Dados do documento de crédito/débito
            DKN->DKN_FILIAL	:= cFilDKN
            DKN->DKN_TPMOV	:= "2" //-- 2 - Saída
            DKN->DKN_DOC	:= cDocNF
            DKN->DKN_SERIE	:= cSerieNF
            DKN->DKN_CLIfOR	:= (cAliasSQL)->F7Q_CLIFOR
            DKN->DKN_LOJA	:= (cAliasSQL)->F7Q_LOJA
            DKN->DKN_ITEMNF := cQtdNF

            // -- Dados do documento referênciado
            DKN->DKN_DOCREF := (cAliasSQL)->F7Q_DOC
            DKN->DKN_SERREF := (cAliasSQL)->F7Q_SERIE
            DKN->DKN_PARREF := (cAliasSQL)->F7Q_CLIFOR
            DKN->DKN_LOJREF := (cAliasSQL)->F7Q_LOJA
            DKN->DKN_CHVNFE := (cAliasSQL)->F2_CHVNFE
            DKN->DKN_ITNFRE := cItem
            DKN->DKN_ORIGEM := 'MATA461'

            DKN->(MsUnLock())
        Next nZ

        (cAliasSQL)->(dbSkip())
    EndDo

    aSize(aInsParam, 0)
    (cAliasSQL)->(dbCloseArea())

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} DelAdtDKN
	Realiza a deleção da tabela DKN gerada durante o faturamento 
    de um pedido de venda com um RA vinculado a Nota de Debito.

    @param cPrefRA, caractere, Prefixo do título RA
    @param cNumRA, caractere, Numero do título RA
    @param cParcRA, caractere, Parcela do título RA
    @param cCliente, caractere, Código do cliente
    @param cLoja, caractere, Loja do cliente
    @param cDocNF, caractere, Número do Documento de Saída
    @param cSerieNF, caractere, Série do Documento de Saída

    @Return .T., logico, Retorno sempre verdadeiro
    @author CRM/Faturamento
    @since 01/2026
/*/
//------------------------------------------------------------------------------
Function DelAdtDKN(cPrefRA as character, cNumRA as character, ParcRA as character, cCliente as character, cLoja as character, cDocNF as character, cSerieNF as character) as array
	Local aArea      as array
    Local aAreaFR3	 as array
    Local aAreaDKN	 as array
    Local aDados   	 as array 
    Local aAdianta   as array 
    Local aInsParam	 as array
	Local aItVinc 	 as array
	Local cItem		 as character
	Local cFilDKN	 as character
    Local cFilFIE	 as character
    Local lAdComPart as logical
    Local nX 		 as numeric

    Default cPrefRA     := ""
    Default cNumRA      := ""
    Default cParcRA     := ""
    Default cCliente    := ""
    Default cLoja       := ""
    Default cDocNF      := ""
    Default cSerieNF    := ""

    aArea       := GetArea()
    aAreaFR3	:= FR3->(GetArea())
    aAreaDKN	:= DKN->(GetArea())
	aDados 		:= {}
    aInsParam   := {}
	aItVinc 	:= {}
	cItem		:= "00"
	cFilDKN		:= FwXFilial("DKN")
    nX 			:= 1
    aAdianta    := CfgAdianta()    
    lAdComPart  := 'C' $ aAdianta[1,1]+aAdianta[1,2]+aAdianta[1,3]    
    cFilFIE     := Iif(lAdComPart,cFilAnt,FWxFilial("FIE"))

    DbSelectArea("FR3")
    FR3->(dbSetOrder(Iif(lAdComPart,8,2)))
    If !dbSeek(cFilFIE + "R" + cCliente + cLoja + cPrefRA + cNumRA + cParcRA + "RA" + cDocNF + cSerieNF)
        
        DbSelectArea("DKN")
        DKN->(DbSetOrder(1)) // -- DKN_FILIAL+DKN_DOC+DKN_SERIE+DKN_CLIFOR+DKN_LOJA+DKN_DOCREF+DKN_SERREF+DKN_PARREF+DKN_LOJREF+DKN_ITNFRE+DKN_TPMOV
        If DKN->(DbSeek(cFilDKN + cDocNF + cSerieNF + cCliente + cLoja))
            While DKN->(!Eof()) .and. Alltrim(DKN->(DKN_DOC+DKN_SERIE)) == Alltrim(cDocNF + cSerieNF) .and. Alltrim(DKN->(DKN_CLIFOR+DKN_LOJA)) == Alltrim(cCliente + cLoja) .And. DKN->DKN_ORIGEM = 'MATA461'
                Reclock("DKN",.F.)
                DKN->(DbDelete())
                DKN->(MsUnlock())

                DKN->(DbSkip())
            EndDo
        EndIf
    EndIf

    RestArea(aAreaDKN)
    RestArea(aAreaFR3)
    RestArea(aArea)

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} NDItens
	Verifica os itens da Nota de Débito.

    @param cDocNF, caractere, Número do Documento de Saída
    @param cSerieNF, caractere, Série do Documento de Saída
    @param cCliente, caractere, Código do cliente
    @param cLoja, caractere, Loja do cliente

    @Return aQtdItens, array, Retorna os itens que da Nota de Débito
    @author CRM/Faturamento
    @since 01/2026
/*/
//------------------------------------------------------------------------------
Static Function NDItens(cDocNF as character, cSerieNF as character, cCliente as character, cLoja as character) as array
    Local aArea      as array
    Local aAreaSD2	 as array
    Local aQtdItens  as array

    Default cDocNF      := ""
    Default cSerieNF    := ""
    Default cCliente    := ""
    Default cLoja       := ""

    aArea       := GetArea()
    aAreasd2	:= SD2->(GetArea())
    aQtdItens   := {}

    DbSelectArea("SD2")
    SD2->(DbSetOrder(3))
    If SD2->(DbSeek(FWxFilial("SD2") + cDocNF + cSerieNF + cCliente + cLoja))
        While SD2->(!Eof()) .And. (cDocNF + cSerieNF + cCliente + cLoja) == (SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA)
            aAdd(aQtdItens, SD2->D2_ITEM)
            SD2->(dbSkip())
        Enddo
    EndIf

    RestArea(aAreaSD2)
    RestArea(aArea)

Return aQtdItens

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetNDQry
	Monta a string com a query para localizar as notas de débitos 
    vinculadas ao RA utilizado no pedido de venda.

    @param lAdComPart, logico, Verifica se a tabela FIE está compartilhada

    @Return cQuery, caractere, Retorna uma string com a query para localizar as notas de débitos
    @author CRM/Faturamento
    @since 01/2026
/*/
//------------------------------------------------------------------------------
Static Function GetNDQry(lAdComPart as logic) as character
    Local cQuery as character
    Local cFilFR3 as character

    Default lAdComPart := .F.

    cQuery := ""
    cFilFR3 := "FR3_FILIAL"

    If lAdComPart
        cFilFR3 := "FR3_FILORI"
    EndIf

    cQuery := "SELECT F7Q.F7Q_DOC, F7Q.F7Q_SERIE, F7Q.F7Q_CLIFOR, F7Q.F7Q_LOJA, SF2.F2_CHVNFE "
    cQuery += "FROM "+ RetSqlName("FR3") +" FR3 "
    cQuery += "INNER JOIN "+ RetSqlName("FK7") +" FK7 "
    cQuery += "ON FK7.FK7_FILIAL = ? "
    cQuery += "AND FK7.FK7_TIPO = ? "
    cQuery += "AND FK7.FK7_CLIFOR = FR3.FR3_CLIENT "
    cQuery += "AND FK7.FK7_LOJA = FR3.FR3_LOJA "
    cQuery += "AND FK7.FK7_PREFIX = FR3.FR3_PREFIX "
    cQuery += "AND FK7.FK7_NUM = FR3.FR3_NUM "
    cQuery += "AND FK7.FK7_PARCEL = FR3.FR3_PARCEL "
    cQuery += "AND FK7.D_E_L_E_T_ = FR3.D_E_L_E_T_ "
    cQuery += "INNER JOIN "+ RetSqlName("F7Q") +" F7Q "
    cQuery += "ON F7Q.F7Q_FILIAL = ? "
    cQuery += "AND F7Q.F7Q_TABORI = ? "
    cQuery += "AND F7Q.F7Q_IDDOC = FK7.FK7_IDDOC "
    cQuery += "AND F7Q.D_E_L_E_T_ = FK7.D_E_L_E_T_ "
	cQuery += "INNER JOIN "+ RetSqlName("SF2") +" SF2 "
	cQuery += "ON SF2.F2_FILIAL = ? "
	cQuery += "AND SF2.F2_DOC = F7Q.F7Q_DOC "
	cQuery += "AND SF2.F2_SERIE = F7Q.F7Q_SERIE "
	cQuery += "AND SF2.F2_CLIENTE = F7Q.F7Q_CLIFOR "
	cQuery += "AND SF2.F2_LOJA = F7Q.F7Q_LOJA "
    cQuery += "AND SF2.D_E_L_E_T_ = F7Q.D_E_L_E_T_ "
    cQuery += "WHERE FR3."+cFilFR3+" = ? "
    cQuery += "AND FR3.FR3_CART = ? "
    cQuery += "AND FR3.FR3_TIPO = ? "
    cQuery += "AND FR3.FR3_CLIENT = ? "
    cQuery += "AND FR3.FR3_LOJA = ? "
    cQuery += "AND FR3.FR3_DOC = ? "
    cQuery += "AND FR3.FR3_SERIE = ? "
    cQuery += "AND FR3.D_E_L_E_T_ = ? "

    cQuery	:= ChangeQuery(cQuery)

Return cQuery
