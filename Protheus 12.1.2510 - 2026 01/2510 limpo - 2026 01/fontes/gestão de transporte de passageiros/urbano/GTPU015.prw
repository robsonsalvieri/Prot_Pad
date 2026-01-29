#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015.CH'
Static nGU015VldOp := 0
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPU015
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GTPU015()
Local oBrowse   := Nil
Local cMsgErro  := ''

If GU015VldDic(@cMsgErro)    
    H7P->(DbSetOrder(2))
    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('H7P')
    oBrowse:SetDescription(STR0001) // "Fechamento de Caixa"
   	oBrowse:AddLegend('H7P_STATUS == "1"',"YELLOW", STR0002) // "Aberto"
	oBrowse:AddLegend('H7P_STATUS == "2"',"GREEN", STR0003) // "Fechado"
	oBrowse:AddLegend('H7P_STATUS == "3"',"BLUE", STR0004) // "Conferido"
	oBrowse:AddLegend('H7P_STATUS == "4"',"ORANGE", STR0005) // "Reaberto"
	oBrowse:AddLegend('H7P_STATUS == "5"',"RED",STR0006) // "Encerrado"

    oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, STR0007) // "Banco de dados desatualizado, não será possível iniciar a rotina"
Endif

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}
        
    ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.GTPU015' OPERATION 2 ACCESS 0  // "Visualizar"
    ADD OPTION aRotina TITLE STR0009 ACTION 'GU015Incl()'     OPERATION 3 ACCESS 0	// "Abrir Caixa"
    ADD OPTION aRotina TITLE STR0010 ACTION 'GU015VldOp(4)'   OPERATION 4 ACCESS 0  // "Alterar"
    ADD OPTION aRotina TITLE STR0011 ACTION 'GU015VldOp(5)'   OPERATION 5 ACCESS 0  // "Excluir"
    ADD OPTION aRotina TITLE STR0013 ACTION 'GU015Fecha()'    OPERATION 4 ACCESS 0  // "Fechar Caixa"
    ADD OPTION aRotina TITLE STR0012 ACTION 'GU015Conf()'     OPERATION 4 ACCESS 0  // "Conferir Caixa"
    ADD OPTION aRotina TITLE STR0014 ACTION 'GU015Reabr()'    OPERATION 4 ACCESS 0  // "Reabrir Caixa"
	    
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	 := Nil
Local oStruH7P	 := FwFormStruct(1,'H7P')
Local oStruH7PT	 := FwFormStruct(1,'H7P')
Local oStruH7QR  := FwFormStruct(1,"H7Q") 
Local oStruH7QD  := FwFormStruct(1,"H7Q") 
Local oStruH81   := FwFormStruct(1,"H81") 
Local bFieldTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFieldVld  := {|oMdl,cField,uNewValue,uOldValue| FieldValid(oMdl,cField,uNewValue,uOldValue)}
Local bPosValid  := {|oModel| PosValid(oModel)}
Local bCommit    := {|oModel| GU15Commit(oModel)}

If H7Q->(FieldPos("H7Q_TPLINH")) > 0
    SetStructH7Q(oStruH7QR,oStruH7QD,'M')
    oStruH7QR:AddTrigger("H7Q_TPLINH", "H7Q_TPLINH", {||.T.}, bFieldTrig)
    oStruH7QD:AddTrigger("H7Q_TPLINH", "H7Q_TPLINH", {||.T.}, bFieldTrig)
Endif

oStruH7P:AddTrigger("H7P_CODH7M", "H7P_CODH7M", {||.T.}, bFieldTrig)
oStruH7P:AddTrigger("H7P_SLDANT", "H7P_SLDANT", {||.T.}, bFieldTrig)
oStruH7QR:AddTrigger("H7Q_CODH7O", "H7Q_CODH7O", {||.T.}, bFieldTrig)
oStruH7QD:AddTrigger("H7Q_CODH7O", "H7Q_CODH7O", {||.T.}, bFieldTrig)
oStruH7QR:AddTrigger("H7Q_VALOR", "H7Q_VALOR", {||.T.}, bFieldTrig)
oStruH7QD:AddTrigger("H7Q_VALOR", "H7Q_VALOR", {||.T.}, bFieldTrig)


oStruH7QR:AddField("", "", "ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld()}, .F., .F., .T.)
oStruH7QD:AddField("", "", "ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld()}, .F., .F., .T.)
oStruH81:AddField("", "", "ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld('H81')}, .F., .F., .T.)

//oStruH7QD:SetProperty('H7Q_QTDPAR', MODEL_FIELD_WHEN, {|oModel| oModel:GetValue('H7Q_CODH7O') == '006'})

oStruH7P:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oStruH7PT:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oStruH81:SetProperty("H81_VLRDEP", MODEL_FIELD_OBRIGAT, .T.)

oStruH7QR:SetProperty('H7Q_CODH7O', MODEL_FIELD_VALID, bFieldVld)
oStruH7QD:SetProperty('H7Q_CODH7O', MODEL_FIELD_VALID, bFieldVld)

oStruH7PT:SetProperty('*', MODEL_FIELD_WHEN, { || .F. })
oStruH81:SetProperty('H81_DTDEPO'	, MODEL_FIELD_VALID, {|| VldDtDepo()})
oStruH81:SetProperty('H81_VLRDEP'	, MODEL_FIELD_VALID, {|| Positivo()})
oStruH81:SetProperty('H81_TPMOV'	, MODEL_FIELD_INIT, {|| '1'})
oModel := MPFormModel():New('GTPU015', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| GU015VldAct(oModel)})

oModel:AddFields('H7PMASTER',/*cOwner*/,oStruH7P)
oModel:AddFields('H7PTOTAL','H7PMASTER',oStruH7PT)
oModel:AddGrid('H7QRECEITA', 'H7PMASTER', oStruH7QR, /*bPre*/, /*bLinePost*/, /*bPre*/) 
oModel:AddGrid('H7QDESPESA', 'H7PMASTER', oStruH7QD, /*bPreLin*/, /*bLinePost*/) 
oModel:AddGrid('H81DEPOSITO', 'H7PMASTER', oStruH81, /*bPreLin*/, /*bLinePost*/) 

oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H7QRECEITA', 'H7Q_VALOR', 'CALC_RECEITA', 'FORMULA',,, STR0016,{|oModel| CalcSaldo(oModel)}) // "Receitas"
oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H7QDESPESA', 'H7Q_VALOR', 'CALC_DESPESA', 'FORMULA',,, STR0016,{|oModel| CalcSaldo(oModel)}) // "Receitas"
oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H81DEPOSITO', 'H81_VLRDEP', 'CALC_DESPESA', 'FORMULA',,, STR0016,{|oModel| CalcSaldo(oModel)}) // "Receitas"

oModel:SetRelation('H7QRECEITA',  {{'H7Q_FILIAL', 'xFilial( "H7Q")'},{'H7Q_CODH7P', 'H7P_CODIGO'},{'H7Q_TIPO', "'1'"}}, H7Q->(IndexKey(1)))
oModel:SetRelation('H7QDESPESA',  {{'H7Q_FILIAL', 'xFilial( "H7Q")'},{'H7Q_CODH7P', 'H7P_CODIGO'},{'H7Q_TIPO', "'2'"}}, H7Q->(IndexKey(1)))
oModel:SetRelation('H81DEPOSITO',{{'H81_FILIAL', 'xFilial( "H81")'},{'H81_CODH7P', 'H7P_CODIGO'}}, H81->(IndexKey(2)))

oModel:SetDescription(STR0001) // "Fechamento de Caixa"
oModel:GetModel('H7PMASTER'):SetDescription(STR0001) // "Fechamento de Caixa"

oModel:GetModel('H7PTOTAL'):SetOnlyQuery(.T.)
oModel:GetModel('H7QRECEITA'):SetOptional(.T.)
oModel:GetModel('H7QDESPESA'):SetOptional(.T.)
oModel:GetModel('H81DEPOSITO'):SetOptional(.T.)

oModel:SetCommit(bCommit)
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= ModelDef()
Local oView		:= FwFormView():New()
Local oStruH7PH	:= FwFormStruct(2, 'H7P',{|x| AllTrim(x) $ 'H7P_CODIGO|H7P_STATUS|H7P_DTFECH|H7P_CODH7M|H7P_DSCH7M|'})
Local oStruH7QR := FwFormStruct(2, "H7Q",{|x| !AllTrim(x) $ 'H7Q_FILIAL|H7Q_CODIGO|H7Q_CODH7P|H7Q_TIPO|H7Q_CONFER|H7Q_DTCONF|H7Q_USUCON|H7Q_TPLINH|'})
Local oStruH7QD := FwFormStruct(2, "H7Q",{|x| !AllTrim(x) $ 'H7Q_FILIAL|H7Q_CODIGO|H7Q_CODH7P|H7Q_TIPO|H7Q_CONFER|H7Q_DTCONF|H7Q_USUCON|H7Q_TPLINH|'}) 
Local oStruH7PT	:= FwFormStruct(2, 'H7P',{|x| AllTrim(x) $ 'H7P_SLDANT|H7P_TOTREC|H7P_TOTDES|H7P_SLDATU|H7P_DEPOSI|H7P_TOTEST'})
Local bdblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}
Local oStruH81  := FWFormStruct(2,'H81')

If H7Q->(FieldPos("H7Q_TPLINH")) > 0
    SetStructH7Q(oStruH7QR,oStruH7QD,"V")
Endif

oStruH81:RemoveField("H81_CODIGO")
oStruH81:RemoveField("H81_CODH7P")
//oStruH81:RemoveField("H81_TPMOV" )
//oStruH7PT:RemoveField("H7P_TOTEST" )

oStruH7PT:SetProperty("H7P_SLDANT" , MVC_VIEW_ORDEM, '01')
oStruH7PT:SetProperty("H7P_TOTREC" , MVC_VIEW_ORDEM, '02')
oStruH7PT:SetProperty("H7P_TOTDES" , MVC_VIEW_ORDEM, '03')
oStruH7PT:SetProperty("H7P_DEPOSI" , MVC_VIEW_ORDEM, '04')
oStruH7PT:SetProperty("H7P_TOTEST" , MVC_VIEW_ORDEM, '05')
oStruH7PT:SetProperty("H7P_SLDATU" , MVC_VIEW_ORDEM, '06')

oStruH81:SetProperty("H81_CODBCO" , MVC_VIEW_ORDEM, '07')
oStruH81:SetProperty("H81_AGEBCO" , MVC_VIEW_ORDEM, '08')
oStruH81:SetProperty("H81_CTABCO" , MVC_VIEW_ORDEM, '09')
oStruH81:SetProperty("H81_VLRDEP" , MVC_VIEW_ORDEM, '10')
oStruH81:SetProperty("H81_DTDEPO" , MVC_VIEW_ORDEM, '11')
oStruH81:SetProperty("H81_FORPGT" , MVC_VIEW_ORDEM, '12')
oStruH81:SetProperty("H81_TPMOV"  , MVC_VIEW_ORDEM, '13')
oStruH81:SetProperty("H81_COMENT" , MVC_VIEW_ORDEM, '14')
oStruH81:SetProperty("H81_FILTIT" , MVC_VIEW_ORDEM, '15')
oStruH81:SetProperty("H81_PRETIT" , MVC_VIEW_ORDEM, '16')
oStruH81:SetProperty("H81_NUMTIT" , MVC_VIEW_ORDEM, '17')
oStruH81:SetProperty("H81_PARTIT" , MVC_VIEW_ORDEM, '18')
oStruH81:SetProperty("H81_TIPTIT" , MVC_VIEW_ORDEM, '19')
oStruH81:SetProperty("H81_CLIFOR" , MVC_VIEW_ORDEM, '20')
oStruH81:SetProperty("H81_LOJTIT" , MVC_VIEW_ORDEM, '21')

oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Fechamento de Caixa"

oStruH7QR:SetProperty("H7Q_CODH7O",MVC_VIEW_LOOKUP,"H7OREC")
oStruH7QD:SetProperty("H7Q_CODH7O",MVC_VIEW_LOOKUP,"H7ODES")

oStruH7QR:AddField("ANEXO","01",STR0019,STR0019,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
oStruH7QD:AddField("ANEXO","01",STR0019,STR0019,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
oStruH81:AddField("ANEXO","01",STR0019,STR0019,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"

oView:AddField('VIEW_HEADER', oStruH7PH, 'H7PMASTER')
oView:AddField('VIEW_TOTAL', oStruH7PT, 'H7PTOTAL')
oView:AddGrid('VIEW_H7QRECEITA', oStruH7QR, 'H7QRECEITA')
oView:AddGrid('VIEW_H7QDESPESA', oStruH7QD, 'H7QDESPESA')
oView:AddGrid('VIEW_H81DEPOSITO', oStruH81, 'H81DEPOSITO')

oView:AddIncrementalField('VIEW_H81DEPOSITO','H81_SEQ')

oView:CreateHorizontalBox('VIEWTOP'     , 20)
oView:CreateHorizontalBox('VIEWGRID'    , 60) 
oView:CreateHorizontalBox('VIEWTOTAL'   , 20)

oView:CreateFolder( 'FOLDER1', 'VIEWGRID')
oView:AddSheet('FOLDER1','SHEET1',STR0049) // "Receita e Despesa"  
oView:CreateVerticalBox( 'BOX1ESQ', 50, , , 'FOLDER1', 'SHEET1') // BOX DE RECEITAS
oView:CreateVerticalBox( 'BOX1DIR', 50, , , 'FOLDER1', 'SHEET1') // BOX DE DESPESAS

oView:AddSheet('FOLDER1','SHEET2',STR0048) // "Depósitos"  
oView:CreateHorizontalBox( 'BOX2', 100, , , 'FOLDER1', 'SHEET2')

oView:SetOwnerView('VIEW_HEADER'        , 'VIEWTOP' )
oView:SetOwnerView('VIEW_H7QRECEITA'    , 'BOX1ESQ' )   
oView:SetOwnerView('VIEW_H7QDESPESA'    , 'BOX1DIR' )   
oView:SetOwnerView('VIEW_H81DEPOSITO'   , 'BOX2'    )   
oView:SetOwnerView('VIEW_TOTAL'         , 'VIEWTOTAL')

oView:EnableTitleView("VIEW_HEADER"     , STR0020)      // "Dados do Fechamento de Caixa"
oView:EnableTitleView("VIEW_H7QRECEITA" , STR0016)      // "Receitas"
oView:EnableTitleView("VIEW_H7QDESPESA" , STR0017)      // "Despesas"
oView:EnableTitleView("VIEW_H81DEPOSITO", STR0048)      // "Depósitos"
oView:EnableTitleView("VIEW_TOTAL"      , STR0021)      // "Totais do Caixa"

oView:SetViewProperty("VIEW_H7QRECEITA", "GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VIEW_H7QDESPESA", "GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VIEW_H81DEPOSITO","GRIDDOUBLECLICK", bDblClick)

oStruH7PH:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_FILTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_PRETIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_NUMTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_PARTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_TIPTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_CLIFOR', MVC_VIEW_CANCHANGE, .F.)
oStruH7QR:SetProperty('H7Q_LOJTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_FILTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_PRETIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_NUMTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_PARTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_TIPTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_CLIFOR', MVC_VIEW_CANCHANGE, .F.)
oStruH7QD:SetProperty('H7Q_LOJTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_FILTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_PRETIT', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_NUMTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_PARTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_TIPTIT', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_CLIFOR', MVC_VIEW_CANCHANGE, .F.)
oStruH81:SetProperty('H81_LOJTIT', MVC_VIEW_CANCHANGE, .F.)

oView:SetViewAction('DELETELINE'    , { |oView,cIdView,nNumLine| DeletaLinha( oView,cIdView,nNumLine ) } )
oView:SetViewAction('UNDELETELINE'  , { |oView,cIdView,nNumLine| DeletaLinha( oView,cIdView,nNumLine ) } )
If FwIsInCallStack('GU015VldOp') .And. nGU015VldOp == MODEL_OPERATION_UPDATE
    oView:AddUserButton("Refaz Sld. Ant.", "CLIPS",{|oModel| GU15SldAtu(oModel)}, "Refaz saldo anterior",,) 
EndIf     
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/06/2024
@version 1.0
@return uVal
@type function
/*/
//-------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'H7P_CODH7M'
    oMdl:SetValue("H7P_DSCH7M", Posicione('H7M',1,xFilial('H7M')+uVal,'H7M_DESC'))
ElseIf cField == 'H7P_SLDANT'    
    oMdl:GetModel():GetModel("H7PTOTAL"):LoadValue("H7P_SLDANT", uVal)
ElseIf cField == 'H7Q_CODH7O'
    oMdl:SetValue("H7Q_DSCH7O", Posicione('H7O',1,xFilial('H7O')+uVal,'H7O_DESCRI'))

    If oMdl:cId == 'H7QRECEITA' 
        oMdl:SetValue("H7Q_TIPO", "1")
    Else
        oMdl:SetValue("H7Q_TIPO", "2")
    Endif

    If uVal == '003'  // GTV 
        oMdl:SetValue("H7Q_CODBCO", Posicione('H7M',1,xFilial('H7M')+oMdl:GetModel():GetValue('H7PMASTER', 'H7P_CODH7M'),'H7M_BANCO'))
        oMdl:SetValue("H7Q_AGEBCO", Posicione('H7M',1,xFilial('H7M')+oMdl:GetModel():GetValue('H7PMASTER', 'H7P_CODH7M'),'H7M_AGENCIA'))
        oMdl:SetValue("H7Q_AGEBCO", Posicione('H7M',1,xFilial('H7M')+oMdl:GetModel():GetValue('H7PMASTER', 'H7P_CODH7M'),'H7M_CONTA'))
    Endif
ElseIf cField == 'H7Q_TPLINH'
    oMdl:SetValue("DESCTPLIN", Posicione('GQC',1,xFilial('GQC')+uVal,'GQC_DESCRI')) 
Endif

Return uVal
//-------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl, cField, uNewValue, uOldValue) 
//TODO Descrição auto-gerada.
@author flavio.martins
@since 13/06/2024
@version 1.0
@param oMdl - Modelo Ativo
@param cField - Campo a ser verificado
@param uNewValue - Novo valor
@param uOldValue - Valor antigo
@return uVal
@type Static function
/*/
//-------------------------------------------------------------------
Static Function FieldValid(oMdl, cField, uNewValue, uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

If cField == 'H7Q_CODH7O'
    lRet := VldRecDesp(uNewValue, @cMsgErro, @cMsgSol)
Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} VldRecDesp(cCodH7O, cMsgErro, cMsgSol)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/06/2024
@version 1.0
@param cCodH7O - Código H7O
@param cMsgErro - Mensagem de erros
@param cMsgSol - Mensagem de solucão
@return uVal
@type function
/*/
//-------------------------------------------------------------------
Static Function VldRecDesp(cCodH7O, cMsgErro, cMsgSol)
Local lRet := .T.

dbSelectArea('H7O')
H7O->(dbSetOrder(1))

If H7O->(dbSeek(xFilial('H7O')+cCodH7O))
    
    If H7O->H7O_INCMAN == '2' 
        cMsgErro := STR0022 // "O registro selecionado não permite a inclusão manual"
        cMsgSol  := STR0023 // "Verifique o registro selecionado"
        lRet := .F.
    Endif

Else 
    cMsgErro := STR0024 // "O código informado não existe no cadastro de tipos de receitas e despesas"
    cMsgSol  := STR0025 // "Verifique o codigo informado"
    lRet := .F.
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GU015VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@param oModel - Modelo Ativo
@return lógico, return_type, return_description
/*/
//-------------------------------------------------------------------
Static Function GU015VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !GU015VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0026 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GU015VldAct", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GU015VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@param cMsgErro - Mensagem de erro
@return lógico, return_type, return_description
/*/
//-------------------------------------------------------------------
Static Function GU015VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H7P','H7Q','H6R', 'H7I','H81'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'H7P_CODIGO','H7P_CODH7M','H7P_DTFECH','H7P_STATUS','H7P_TOTDES',;
            'H7P_TOTREC','H7P_DINENV','H7P_DINDSP','H7P_DINACM','H7P_SLDANT','H7P_DEPOSI',;
            'H7P_DIFDIA','H7P_SLDATU','H7Q_CODIGO','H7Q_CODH7P','H7Q_CODH7O','H7P_TOTEST',;
            'H7Q_TIPO','H7Q_VALOR','H7Q_DTINI','H7Q_DTFIM','H7Q_DOCIDT','H81_TPMOV',;
            'H7Q_QTDPAR','H7Q_JUSTIF','H7Q_CODBCO','H7Q_AGEBCO','H7Q_CTABCO',;
            'H7Q_CONFER','H7Q_DTCONF','H7Q_USUCON','H7Q_FILTIT','H7Q_PRETIT',;
            'H7Q_NUMTIT','H7Q_PARTIT','H7Q_TIPTIT','H6R_CODH7O','H7I_CODH7P','H7Q_TPLINH'}

For nX := 1 To Len(aTables)
    If aTables[nX] == 'H81' .And. Select('H81') == 0
        ChkFile('H81')
    EndIf 
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n(STR0043, {aFields[nX]}) // "Campo #1 não se encontra no dicionário"
	        Exit
	    Endif
	Next
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GU015Incl()
(long_description)
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Function GU015Incl()

FwExecView(STR0054, "VIEWDEF.GTPU015A", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , 80/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/) // "Fechamento do Caixa"

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} PosValid(oModel)
(long_description)
@type Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function PosValid(oModel)
Local lRet       := .T.
local nI         := 0
local nX         := 0
Local oDetReceit := Nil
Local oDetDespes := Nil

    If FwIsInCallStack('GTPU015B') 
        oDetReceit := oModel:GetModel("H7QRECEITA")
        For nI := 1 To oDetReceit:GetQtdLine()
            oDetReceit:GoLine( nI )
            If oDetReceit:GetValue('H7Q_CONFER') == '1'
                lRet := .F.
                oModel:setErrorMessage(,, oDetReceit:GetId(),, "PosValid", STR0044,,,) //"Existe(m) receita(s) não conferida(s), verifique! "
                Exit
            EndIf
        Next nI
        If lRet
            oDetDespes := oModel:GetModel("H7QDESPESA")
            For nX := 1 To oDetDespes:GetQtdLine()
                oDetDespes:GoLine( nX )
                If oDetDespes:GetValue('H7Q_CONFER') == '1'
                    lRet := .F.
                    oModel:setErrorMessage(,, oDetDespes:GetId(),, "PosValid", STR0045,,,) //"Existe(m) despesa(s) não conferida(s), verifique! "
                    Exit
                EndIf
            Next nX
        EndIf
        If lRet
            oModel:GetModel('H7PMASTER'):SetValue('H7P_STATUS', '3')
        EndIf

    Else
        If oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or.;
            oModel:GetOperation() == MODEL_OPERATION_INSERT

            oModel:GetModel('H7PMASTER'):LoadValue('H7P_SLDANT', oModel:GetModel('H7PTOTAL'):GetValue('H7P_SLDANT'))
            oModel:GetModel('H7PMASTER'):LoadValue('H7P_TOTREC', oModel:GetModel('H7PTOTAL'):GetValue('H7P_TOTREC'))
            oModel:GetModel('H7PMASTER'):LoadValue('H7P_TOTDES', oModel:GetModel('H7PTOTAL'):GetValue('H7P_TOTDES'))
            oModel:GetModel('H7PMASTER'):LoadValue('H7P_SLDATU', oModel:GetModel('H7PTOTAL'):GetValue('H7P_SLDATU'))
            oModel:GetModel('H7PMASTER'):LoadValue('H7P_DEPOSI', oModel:GetModel('H7PTOTAL'):GetValue('H7P_DEPOSI'))
            oModel:GetModel('H7PMASTER'):LoadValue('H7P_TOTEST', oModel:GetModel('H7PTOTAL'):GetValue('H7P_TOTEST'))
        Endif

    Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
(long_description)
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()

If cField == 'ANEXO'
    AttachDocs(oView, oGrid)
Endif

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} AttachDocs(oView, oGrid)
(long_description)
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------------------
Static Function AttachDocs(oView, oGrid)
Local nRecno   :=  0 //oView:GetModel():GetModel('H69DETAIL'):GetDataId()
Local aRecACB  := {}
Local nRecnoAC9 := 0
Local cAlias   := 'H7Q'

If oGrid:cViewId == 'VIEW_H7QRECEITA'
    nRecno := oView:GetModel():GetModel('H7QRECEITA'):GetDataId()
ElseIf oGrid:cViewId == 'VIEW_H7QDESPESA' 
    nRecno := oView:GetModel():GetModel('H7QDESPESA'):GetDataId()
ElseIf oGrid:cViewId == 'VIEW_H81DEPOSITO'      
    nRecno := oView:GetModel():GetModel('H81DEPOSITO'):GetDataId()
    cAlias := 'H81'
Endif

If nRecno == 0
    FwAlertHelp(STR0027, STR0028, ) // "Atenção", "Grave o registro antes de anexar o documento"
Else

    //MsDocument('H7Q', H7Q->(nRecno), 3,,,@aRecACB)
    MsDocument(cAlias, (cAlias)->(nRecno), 3,,,@aRecACB)

    nRecnoAC9 := AC9->(RecNo())

    If oGrid:cViewId == 'VIEW_H7QRECEITA'
        oView:GetModel():GetModel('H7QRECEITA'):LoadValue("ANEXO", SetIniFld())
    ElseIf oGrid:cViewId == 'VIEW_H7QDESPESA'
        oView:GetModel():GetModel('H7QDESPESA'):LoadValue("ANEXO", SetIniFld())
    ElseIf oGrid:cViewId == 'VIEW_H81DEPOSITO' 
        oView:GetModel():GetModel('H81DEPOSITO'):LoadValue("ANEXO", SetIniFld('H81'))            
    Endif

    oView:Refresh()

Endif

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} SetIniFld()
Seta a cor da legenda do botão de anexo
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0
@return cValor
/*/
//-------------------------------------------------------------------
Static Function SetIniFld(cId)
Local cValor := ''
Local cSeek  := ''

Default cId  := ''

If Empty(cId)
    cSeek := 'H7Q'+xFilial('H7Q')+xFilial('H7Q')+H7Q->H7Q_CODIGO
Else
    cSeek := 'H81'+xFilial('H81')+xFilial('H81')+H81->(H81_CODIGO+H81_CODH7P+H81_SEQ)
EndIf 

AC9->(dbSetOrder(2))

If AC9->(dbSeek(xFilial('AC9')+cSeek))
    cValor := "F5_VERD"
Else
    cValor := 'F5_VERM'
Endif

Return cValor
//-------------------------------------------------------------------
/*/{Protheus.doc} GU015VldOp(nOperation)
(long_description)
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@param nOperation - Operação executada
@return lógico, return_type, return_description
/*/
//-------------------------------------------------------------------
Function GU015VldOp(nOperation)
Local lRet      := .T.
Local cDescrAcao:= ''
    nGU015VldOp := nOperation
    If nOperation == MODEL_OPERATION_UPDATE
        cDescrAcao := STR0010
        If !(H7P->H7P_STATUS $ '1|4')
            lRet := .F.
            FwAlertInfo(STR0029) // "Status atual do caixa não permite a alteração"
        Endif

    ElseIf nOperation == MODEL_OPERATION_DELETE
        cDescrAcao := STR0011
        If !(H7P->H7P_STATUS $ '1|4')
            lRet := .F.
            FwAlertInfo(STR0030) // "Status atual do caixa não permite a exclusão"
        Endif

    Endif

    If lRet 
        FwExecView(cDescrAcao, "VIEWDEF.GTPU015", nOperation,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/) // "Fechamento do Caixa" 
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GU015Fecha()
Realiza o fechamento do caixa
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@return lógico, return_type, return_description
/*/
//-------------------------------------------------------------------
Function GU015Fecha()
Local oModel    := Nil
Local aAreaH7P  := H7P->(GetArea())
Local lRet      := .T.

    If !(H7P->H7P_STATUS $ '1|4')
        lRet := .F.
        FwAlertInfo(STR0031) // "Status atual do caixa não permite que o mesmo seja fechado"
    Else
        H7I->(DbSetOrder(4))
        If  H7I->(DBSeek(xFilial("H7I") +  DTOS(H7P->H7P_DTFECH) + H7P->H7P_CODH7M + "1")) .Or. H7I->(DBSeek(xFilial("H7I") + DTOS(H7P->H7P_DTFECH) + H7P->H7P_CODH7M  + "3")) // Prestação pendente ou reaberta
            lRet := .F.
            FwAlertInfo(STR0047) // "Existe Prestação de contas pendente ou reaberta, não é possível que o caixa seja fechado"
        ElseIf VldFechamento(H7P->H7P_CODH7M, DTOS(H7P->H7P_DTFECH))
            lRet := .F.
            FwAlertInfo(STR0055) // "Existe caixa anterior em aberto ou reaberto. Finalize os caixas anteriores para continuar."
        Else

            oModel := FwLoadModel('GTPU015')
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()

            oModel:SetValue('H7PMASTER', 'H7P_STATUS', '2')

            If oModel:VldData() .And. oModel:CommitData()
                FwAlertSuccess(STR0032) // "Caixa fechado com sucesso"
            Endif

            oModel:DeActivate()
            oModel:Destroy()

        EndIf

    Endif

H7P->(RestArea(aAreah7p))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GU015Conf()
Realiza a conferência
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function GU015Conf()
Local lRet := .T.

If H7P->H7P_STATUS == '3'
    lRet := .F.
    FwAlertInfo(STR0033) // "Caixa já conferido"
ElseIf H7P->H7P_STATUS != '2'
    lRet := .F.
    FwAlertInfo(STR0034) // "Status atual do caixa não permite a conferência"
Endif

If lRet 
    GTPU015B()
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GU015Reabr()
Realiza a reabertura do caixa
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@return lRet - .T./.F. - indica se o caixa foi reaberto
/*/
//-------------------------------------------------------------------
Function GU015Reabr()
Local lRet      := .T.
Local cCodCaixa := H7P->H7P_CODIGO
Local cCodLocal := H7P->H7P_CODH7M
Local cData     := H7P->H7P_DTFECH
Local aAreaAtu  := GetArea()
Local nRegAtu   := H7P->(Recno())
    Begin Transaction

        If (H7P->H7P_STATUS $ '1|4|5')
            lRet := .F.
            FwAlertInfo(STR0035) // "Status do caixa não permite a reabertura"
        Else 
            dbSelectArea('H7P')
            H7P->(dbSetOrder(2))

            If H7P->(dbSeek(xFilial('H7P')+cCodLocal))
                While H7P->(!Eof()) .AND. H7P->H7P_CODH7M == cCodLocal 
                    If H7P->H7P_DTFECH > cData .And. !(H7P_STATUS  $ '1|4|5')
                        lRet := .F.
                        exit
                    EndIf
                    H7P->(dbSkip())
                EndDo

            EndIf
            H7P->(DbGoTo(nRegAtu))
            If lRet
                If FwAlertYesNo(STR0036, STR0027) // "A reabertura do caixa poderá excluir os títulos financeiros gerados. Tem certeza que deseja reabrir este caixa?","Atenção"
                    FwMsgRun(,{|| lRet := GTPU015D(cCodCaixa)}, STR0037, STR0038) // "Reabrindo o caixa...", "Aguarde..."
                Else
                    lRet := .F.
                Endif
            Else
                FwAlertHelp(STR0046+' '+STR0050)//"Não é possível realizar a reabertura do caixa, pois existe(em) caixa(s) com data posterior!","Exclua os caixas posteriores para continuar."
            EndIf

            If lRet
                lRet := EstornaCnf(cCodCaixa)
                FwAlertSuccess(STR0039) // "Caixa reaberto com sucesso"
            Else
                DisarmTransaction()
            Endif

        Endif

    End Transaction
H7P->(dbSetOrder(2))    
RestArea(aAreaAtu)
Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} EstornaCnf(cCodCaixa)
(long_description)
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@param cCodCaixa - Código do caixa
@return lógico, return_type, return_description
/*/
//-------------------------------------------------------------------
Static Function EstornaCnf(cCodCaixa)
Local lRet      := .T.
Local oModel    := FwLoadModel('GTPU015')
Local nX        := 0

oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

    oModel:GetModel('H7QRECEITA'):GoLine(nX)
    oModel:GetModel('H7QRECEITA'):SetValue('H7Q_CONFER', '1')
    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_DTCONF')
    oModel:GetModel('H7QRECEITA'):ClearField('H7Q_USUCON')

Next nX

For nX := 1 To oModel:GetModel('H7QDESPESA'):Length()

    oModel:GetModel('H7QDESPESA'):GoLine(nX)
    oModel:GetModel('H7QDESPESA'):SetValue('H7Q_CONFER', '1')
    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_DTCONF')
    oModel:GetModel('H7QDESPESA'):ClearField('H7Q_USUCON')

Next nX

    FwFormCommit(oModel)
    oModel:DeActivate()
    oModel:Destroy()

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GU15Commit(oModel)
Gera titulo na conferência 
@type Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@param oModel
@return lRet - .T. / .F. - Indica se a conferência foi feita com sucesso
/*/
//-------------------------------------------------------------------
Static Function GU15Commit(oModel)
Local lRet        := .T.
Local cCodCaixa   := ''
Local aNewH81     := {}
Local aDelH81     := {}
Local lMsDocument := .F.

cCodCaixa := oModel:GetValue('H7PMASTER', 'H7P_CODIGO')

If oModel:GetModel():GetOperation() == MODEL_OPERATION_INSERT
    If  !(VldDataIncl(oModel))
        Return .F.     
    EndIf 
EndIf 

If FwIsInCallStack('GU015INCL') .Or. FwIsInCallStack('GU015VldOp') 
    HasNewGTV(oModel:GetModel("H81DEPOSITO"),@aNewH81,@aDelH81)
EndIf 

//DSERGTP-8038: se o array estiver preenchido, então efetua a pergunta para o usuario,
//se ele deseja anexar os arquivos GTVs na base de conheimento
If ( Len(aNewH81) > 0 )

    cMsgYesNo := "Há novos depósitos. "
    cMsgYesNo += "Os documentos podem ser anexados na base de conhecimento. " + CHR(13) + CHR(10)
    cMsgYesNo += "Porém, os anexos poderão ser arquivados na base de conhecimento, "
    cMsgYesNo += "futuramente, durante a alteração da ficha de remessa. " + CHR(13) + CHR(10)
    cMsgYesNo += "Deseja anexar os documentos na base de conhecimento agora? "			

    lMsDocument :=  MsgYesNo(cMsgYesNo,"Anexar")

EndIf

Begin Transaction

    lRet := FwFormCommit(oModel)
   
    If ( lRet .And. lMsDocument )
        
        oModel:DeActivate()
        oModel:SetOperation(MODEL_OPERATION_VIEW)
        oModel:Activate()

        AttachGTV(oModel:GetModel("H81DEPOSITO"),aNewH81)
    
    EndIf

    If lRet .And. FwIsInCallStack('GTPU015B') 

        FwMsgRun(,{|| lRet := GTPU015C(cCodCaixa)}, STR0040, STR0038) // "Gerando títulos de despesas e receitas...", "Aguarde..."
    
    Endif

    If ( Len(aDelH81) > 0 )
        DettachGTV(aDelH81)
    EndIf

    If !(lRet)
        DisarmTransaction()
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GU15Commit", STR0041, STR0042) // "Conferência do Caixa não realizada", "Verifique os erros"
    Endif

End Transaction
H7P->(DbSetOrder(2))
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DeletaLinha(oView, cIdView, nNumLine)
(long_description)
@type Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0
@param oView
@param cIdView
@param nNumLine
/*/
//-------------------------------------------------------------------
Static Function DeletaLinha(oView, cIdView, nNumLine)
Local oModel := oView:GetModel()

CalcSaldo(oModel)

oView:Refresh('VIEW_TOTAL')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GU15RetSld(cCodLocal, cDataFech)
Busca o valor do saldo
@type Static Function
@author flavio.martins
@since 04/07/2024
@version 1.0
@param cCodLocal
@param cDataFech
@return nSaldo - Valor do saldo
/*/
//-------------------------------------------------------------------
Function GU15RetSld(cCodLocal, cDataFech, lStatusFech)
    Local aAreaAtu  := GetArea()
    Local nSaldo    := 0
    Local cAliasQry := GetNextAlias()

    Default cCodLocal   := ''
    Default cDataFech   := ''
    Default lStatusFech := .F.

    BeginSql Alias cAliasQry

        SELECT H7P_SLDATU,H7P_STATUS
        FROM %Table:H7P% H7P 
        WHERE 
        H7P.H7P_FILIAL = %xFilial:H7P% 
        AND H7P.H7P_CODH7M = %Exp:cCodLocal% 
        AND H7P.H7P_DTFECH = (
            SELECT MAX(H7P_DTFECH) 
            FROM %Table:H7P% 
            WHERE 
            H7P_FILIAL = %xFilial:H7P% 
            AND H7P_CODH7M = %Exp:cCodLocal%  
            AND H7P_DTFECH < %Exp:cDataFech%  
            AND %NotDel%
        ) 
        AND H7P.%NotDel%

    EndSql

    If (cAliasQry)->(!Eof())
        nSaldo      := (cAliasQry)->H7P_SLDATU
        lStatusFech := (H7P_STATUS $ '2|3' )
    EndIf 

    (cAliasQry)->(dbCloseArea())
    RestArea(aAreaAtu)

Return nSaldo
//-------------------------------------------------------------------
/*/{Protheus.doc} CalcSaldo(oModel)
(long_description)
@type Static Function
@author flavio.martins
@since 01/07/2024
@version 1.0
@param oModel - Modelo ativo
@return lógico, return_type, return_description
/*/
//-------------------------------------------------------------------
Static Function CalcSaldo(oModel)
Local aLinhas   := FWSaveRows()
Local nX        := 0
Local nReceita  := 0
Local nDespesa  := 0
Local nSaldoAnt := 0
Local nSaldoAtu := 0
Local nDeposito := 0
Local nDepEstor := 0

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or.;
    oModel:GetOperation() == MODEL_OPERATION_UPDATE

    For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

        If !(oModel:GetModel('H7QRECEITA'):IsDeleted(nX))

            nReceita += oModel:GetModel('H7QRECEITA'):GetValue('H7Q_VALOR',nX)

        Endif

    Next

    For nX := 1 To oModel:GetModel('H7QDESPESA'):Length()
	        
        If !(oModel:GetModel('H7QDESPESA'):IsDeleted(nX))

            nDespesa += oModel:GetModel('H7QDESPESA'):GetValue('H7Q_VALOR',nX)

        Endif

    Next

    nSaldoAnt := oModel:GetModel('H7PTOTAL'):GetValue('H7P_SLDANT')
    nSaldoAtu := ((nSaldoAnt + nReceita) - nDespesa)

    For nX := 1 To oModel:GetModel('H81DEPOSITO'):Length()
	        
        If !(oModel:GetModel('H81DEPOSITO'):IsDeleted(nX))

            If oModel:GetModel('H81DEPOSITO'):GetValue('H81_TPMOV',nX) != '2'
                nDeposito += oModel:GetModel('H81DEPOSITO'):GetValue('H81_VLRDEP',nX)
            Else
                nDepEstor += oModel:GetModel('H81DEPOSITO'):GetValue('H81_VLRDEP',nX)
            EndIf

        Endif

    Next    

    nSaldoAtu:= nSaldoAtu - nDeposito + nDepEstor

    oModel:GetModel('H7PTOTAL'):LoadValue('H7P_TOTREC', nReceita)
    oModel:GetModel('H7PTOTAL'):LoadValue('H7P_TOTDES', nDespesa)
    oModel:GetModel('H7PTOTAL'):LoadValue('H7P_SLDATU', nSaldoAtu)
    oModel:GetModel('H7PTOTAL'):LoadValue('H7P_DEPOSI', nDeposito)
    oModel:GetModel('H7PTOTAL'):LoadValue('H7P_TOTEST', nDepEstor)

Endif

FWRestRows(aLinhas)

Return 0

//DSERGTP-8038
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} HasNewGTV(oSubH81,aNewH81,aDelH81)

Função que verifica se tem documento a ser anexado ou a ser apagado da base de conhecimento

@Params:
	oSubH81:	objeto, Instância da classe FwFormGridModel
	aNewH81*:	array, possui as linhas do grid H81DETAIL com os itens novos de depósito GTV
	aDelH81*:	array, possui as chaves de AC9 dos documentos de H81 que deverão ser excluídos
	
	*parâmetros que são passados por referência
@return	
	
@author	SIGAGTP 
@since		25/11/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function HasNewGTV(oSubH81,aNewH81,aDelH81)

	Local cChave	:= ""
	Local cChaveAC9	:= ""

	Local nI		:= 0
	Local nOper		:= oSubH81:GetModel():GetOperation()

	Local lHasAttach:= .F.

	Local aAreaH81	:= {}
	Local aAreaAC9 	:= {}

	Default aNewH81 := {}
	Default aDelH81	:= {}

	If ( Len(aNewH81) == 0 .And. nOper != MODEL_OPERATION_DELETE )

		aAreaH81 := H81->(GetArea())
		aAreaAC9 := AC9->(GetArea())
		
		For nI := 1 to oSubH81:Length()

			If ( !Empty(oSubH81:GetValue("H81_SEQ",nI)) .AND. oSubH81:GetValue("H81_VLRDEP",nI) > 0 )
			
				cChave := oSubH81:GetValue("H81_FILIAL",nI)
				cChave += oSubH81:GetValue("H81_CODIGO",nI)
				cChave += oSubH81:GetValue("H81_CODH7P",nI)
				cChave += oSubH81:GetValue("H81_SEQ",nI)
			
				H81->(DbSetOrder(1))	//H81_FILIAL, H81_CODIGO, H81_CODH7P, H81_SEQ, R_E_C_N_O_, D_E_L_E_T_
				lHasReg := H81->(DbSeek(cChave))
			Else	
				lHasReg := .F.	
			EndIf

			AC9->(dbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_	
			
			If ( lHasReg )			

				cChaveAC9 := xFilial('AC9') 
				cChaveAC9 += 'H81' 
				cChaveAC9 += oSubH81:GetValue("H81_FILIAL",nI) 
				cChaveAC9 += cChave
				
				lHasAttach := AC9->(dbSeek(cChaveAC9))
			
			EndIf

			If H81->(FieldPos("H81_FORPGT")) > 0  
				//Não foi inserido
				If ( !(oSubH81:IsInserted(nI)) )					
					
					//Existe registro em H81?					
					If ( lHasReg )					
						//a linha foi deletada, então o documento anexo, anteriormente
						//deverá ser excluído
						If ( oSubH81:IsDeleted(nI) .And. lHasAttach )
							aAdd(aDelH81,cChaveAC9)	//Chave de busca do objeto anexado na base de conhecimento
						//O Depósito GTV existe, mas não possui documento anexado
						ElseIf ( oSubH81:GetValue("ANEXO",nI) != "F5_VERD" )
							aAdd(aNewH81,nI)	//Linha do submodelo H81DETAIL
						EndIf							
						
					EndIf					

				Else
					aAdd(aNewH81,nI)	//Linha do submodelo H81DETAIL
				EndIf
			
			Else
				//Se não é GTV, mas ao mesmo tempo foi atualizado a linha no modelo de dados,
				//pode ser que anteriormente, o depósito fora um GTV e tenha anexo na
				//base de conhecimento. Caso seja o cenário, então a base de conhecimento, 
				//deverá ser excluída.
				If ( oSubH81:IsUpdated(nI) .And.  ( lHasAttach .And. lHasReg .And. oSubH81:GetValue("H81_TPDEPO",nI) <> "5" .And. H81->H81_TPDEPO == "5") )
					aAdd(aDelH81,cChaveAC9)	//Chave de busca do objeto anexado na base de conhecimento
				EndIf

			EndIf

		Next nI

		RestArea(aAreaH81)
		RestArea(aAreaAC9)

	ElseIf ( nOper == MODEL_OPERATION_DELETE )
		
		aAreaAC9 := AC9->(GetArea())

		AC9->(dbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_	
		
		For nI := 1 to oSubH81:Length()
			
			If ( oSubH81:GetValue("ANEXO",nI) == "F5_VERD" )

				cChave := oSubH81:GetValue("H81_FILIAL",nI)
                cChave += oSubH81:GetValue("H81_CODIGO",nI)
				cChave += oSubH81:GetValue("H81_CODH7P",nI)
				cChave += oSubH81:GetValue("H81_SEQ",nI)
				
				cChaveAC9 := xFilial('AC9') 
				cChaveAC9 += 'H81' 
				cChaveAC9 += oSubH81:GetValue("H81_FILIAL",nI) 
				cChaveAC9 += cChave
				
				If ( AC9->(dbSeek(cChaveAC9)) )
					aAdd(aDelH81,cChaveAC9)
				EndIf

			EndIf

		Next nI

		RestArea(aAreaAC9)

	EndIf

Return()


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} DettachGTV(aDelH81)

Função para exclusão da base de conhecimento, os documentos de GTV que tiveram os depósitos
excluídos da H81

@Params:
	aDelH81*:	array, possui as chaves de AC9 dos documentos de H81 que deverão ser excluídos
		
	*parâmetros que são passados por referência
@return	
	
@author	SIGAGTP 
@since		25/11/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function DettachGTV(aDelH81)

	Local aAreaH81	:= H81->(GetArea())

	Local cEntidade := ""
	Local cFilAC9	:= ""
	
	Local nI		:= 0

	//Se tiver exclusões
	AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_	
	
	For nI := 1 to Len(aDelH81)
		
		If ( AC9->(DbSeek(aDelH81[nI]))	)

			cEntidade 	:= AC9->AC9_CODENT
			cFilAC9		:= AC9->AC9_FILIAL
			
			While ( Alltrim(AC9->(AC9_FILIAL+AC9_CODENT)) == Alltrim(cFilAC9+cEntidade) )

				ACB->(DbSetOrder(1))	//ACB_FILIAL, ACB_CODOBJ, R_E_C_N_O_, D_E_L_E_T_
				
				If ( ACB->(DbSeek(AC9->(AC9_FILIAL+AC9_CODOBJ))) )
					
					RecLock("ACB",.F.)
						ACB->(DbDelete())
					ACB->(MsUnlock())

				EndIf
				
				ACC->(DbSetOrder(1))	//ACC_FILIAL, ACC_CODOBJ, R_E_C_N_O_, D_E_L_E_T_
				
				If ( ACC->(DbSeek(AC9->(AC9_FILIAL+AC9_CODOBJ))) )
					RecLock("ACC",.F.)
						ACC->(DbDelete())
					ACC->(MsUnlock())
				EndIf
				
				RecLock("AC9",.F.)
					AC9->(DbDelete())
				AC9->(MsUnlock())
				
				cFilAC9		:= AC9->AC9_FILIAL
				cEntidade	:= AC9->AC9_CODENT

				AC9->(DbSkip())

			End While

		EndIf

	Next nI

	RestArea(aAreaH81)

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AttachGTV(oSubH81,aNewH81)

Função que chama o formulário da base de conhecimento para anexar a GTV

@Params:
	oSubH81:	objeto, Instância da classe FwFormGridModel
	aNewH81*:	array, possui as linhas do grid H81DETAIL com os itens novos de depósito GTV
		
	*parâmetros que são passados por referência
@return	
	
@author	SIGAGTP 
@since		25/11/2022
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function AttachGTV(oSubH81,aNewH81)

	Local nI 		:= 0
	Local aAreaH81	:= H81->(GetArea())
	//se tiver inclusões
	For nI := 1 to Len(aNewH81)
		
		oSubH81:GoLine(aNewH81[nI])

		cChave := oSubH81:GetValue("H81_FILIAL")
		cChave += oSubH81:GetValue("H81_CODIGO")
		cChave += oSubH81:GetValue("H81_CODH7P")
		cChave += oSubH81:GetValue("H81_SEQ")
		
		H81->(DbSetOrder(1))	//H81_FILIAL, H81_CODIGO, H81_CODH7P, H81_SEQ, R_E_C_N_O_, D_E_L_E_T_
		If ( H81->(DbSeek(cChave)) )
			MsDocument('H81',H81->(Recno()),3)
		EndIf	

	Next nI

	RestArea(aAreaH81)

Return()    

Static Function VldDataIncl(oModel)
Local lRet := .T.

dbSelectArea('H7P')
H7P->(dbSetOrder(2))

If H7P->(dbSeek(xFilial('H7P')+oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')+;
                    DtoS(oModel:GetModel('H7PMASTER'):GetValue('H7P_DTFECH'))))
    lRet := .F.
	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"VldDataIncl", STR0051,, STR0052) //"Já existe um caixa com os parâmetros informados", "Verifique os parâmetros informados"
Endif

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldDtDepo()
Valida data de deposito - Datas validas maiores que a data fechamento
@type Function
@author José Carlos
@since 04/04/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldDtDepo()
    Local lRetorno := .T. 
    Local oModel	:= FwModelActive()
    Local dDtFecham := oModel:GetValue('H7PMASTER', 'H7P_DTFECH')
    If !Empty(oModel:GetModel("H81DEPOSITO"):GetValue('H81_DTDEPO') ) .And. oModel:GetModel("H81DEPOSITO"):GetValue('H81_DTDEPO') < dDtFecham
        lRetorno := .F.
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"VldDtDepo", STR0058,, STR0059)     //'Data do depósito menor que a data do fechamento' 'Informe uma data válida.'
    EndIf         
Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} VldFechamento()
Valida Fechamento - Permite caso não haja datas anteriores Aberto ou Reaberto
@type Function
@author flavio.martins
@since 03/06/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldFechamento(cCodLocal, cDataFech)
    Local lRetorno := .T.
    Local cAliasTmp:= GetNextAlias()

    BeginSql Alias cAliasTmp

    SELECT H7P.H7P_CODIGO 
    FROM %Table:H7P% H7P 
    WHERE 
      H7P.H7P_FILIAL = %xFilial:H7P%
      AND H7P.H7P_CODH7M = %Exp:cCodLocal%
      AND H7P.H7P_DTFECH < %Exp:cDataFech%
      AND H7P.H7P_STATUS IN ('1','4')
      AND H7P.%NotDel%

    EndSql

    lRetorno := (cAliasTmp)->(!Eof())

    (cAliasTmp)->(DbCloseArea())

Return lRetorno 

//-------------------------------------------------------------------
/*/{Protheus.doc} GU15SldAtu(oModel)
Atualização saldos anterior e atual
@type Function
@author jose.darocha
@since 07/04/2025
@version 1.0
@param cCodLocal
@param cDataFech
@return NIL
/*/
//-------------------------------------------------------------------
Function GU15SldAtu(oModel)
    Local aAreaAtu    := GetArea()
    Local cCodLocal   := H7P->H7P_CODH7M
    Local cDataFech   := Dtos(H7P->H7P_DTFECH)    
    Local lStatusFech := .F.
    Local nSldInicial := 0

    GU15RetSld(cCodLocal, cDataFech, @lStatusFech)

    If ! (lStatusFech)
        FwAlertInfo(STR0057) // "Para o recalculo, o caixa na data anterior deve estar Fechado ou Conferido."
        Return Nil
    Else 
        nSldInicial := GU15RetSld(cCodLocal, cDataFech)
        
        oModel:GetModel('H7PTOTAL'):LoadValue('H7P_SLDANT',nSldInicial)

        CalcSaldo(oModel)

    EndIF 
    RestArea(aAreaAtu)
Return NIL 


Static Function SetStructH7Q(oStruH7QR,oStruH7QD,cTipo)

	If cTipo == "M"
	
		If ValType( oStruH7QR ) == "O"
				
			oStruH7QR:AddField("DESCTPLIN",;							// 	[01]  C   Titulo do campo // "Filial"
								"DESCTPLIN",;							// 	[02]  C   ToolTip do campo // "Filial"
								"DESCTPLIN",;							// 	[03]  C   Id do Field // "Filial"
								"C",;									// 	[04]  C   Tipo do campo
								TamSx3("GQC_DESCRI")[1],;				// 	[05]  N   Tamanho do campo
								0,;										// 	[06]  N   Decimal do campo
								Nil,;									// 	[07]  B   Code-block de validação do campo
								Nil,;									// 	[08]  B   Code-block de validação When do campo
								Nil,;									//	[09]  A   Lista de valores permitido do campo
								.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil,;									//	[11]  B   Code-block de inicializacao do campo
								.F.,;									//	[12]  L   Indica se trata-se de um campo chave
								.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.)									// 	[14]  L   Indica se o campo é virtual
				

            oStruH7QR:SetProperty('DESCTPLIN'	, MODEL_FIELD_INIT, {|| IIF(!INCLUI,Posicione('GQC',1,xFilial('GQC')+H7Q->H7Q_TPLINH,'GQC_DESCRI'),"")})

		Endif
		
		If ValType( oStruH7QD ) == "O"
				
			oStruH7QD:AddField("DESCTPLIN",;							// 	[01]  C   Titulo do campo // "Filial"
								"DESCTPLIN",;							// 	[02]  C   ToolTip do campo // "Filial"
								"DESCTPLIN",;							// 	[03]  C   Id do Field // "Filial"
								"C",;									// 	[04]  C   Tipo do campo
								TamSx3("GQC_DESCRI")[1],;				// 	[05]  N   Tamanho do campo
								0,;										// 	[06]  N   Decimal do campo
								Nil,;									// 	[07]  B   Code-block de validação do campo
								Nil,;									// 	[08]  B   Code-block de validação When do campo
								Nil,;									//	[09]  A   Lista de valores permitido do campo
								.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
								Nil,;									//	[11]  B   Code-block de inicializacao do campo
								.F.,;									//	[12]  L   Indica se trata-se de um campo chave
								.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
								.T.)									// 	[14]  L   Indica se o campo é virtual


            oStruH7QD:SetProperty('DESCTPLIN'	, MODEL_FIELD_INIT, {|| IIF(!INCLUI,Posicione('GQC',1,xFilial('GQC')+H7Q->H7Q_TPLINH,'GQC_DESCRI'),"")})	
		Endif
		
		
	Else

		If ValType( oStruH7QR ) == "O"
	
			oStruH7QR:AddField(	"DESCTPLIN",;				// [01]  C   Nome do Campo
		                        "27",;						// [02]  C   Ordem
		                        STR0060,;						// [03]  C   Titulo do campo // "Tipo Linha"
		                        STR0060,;						// [04]  C   Descricao do campo // "Tipo Linha"
		                        {STR0060},;					// [05]  A   Array com Help // "Selecionar"  //"Tipo Linha"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "@!",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo					            
			                    
		EndIf
		    		    
        If ValType( oStruH7QD ) == "O"
	
			oStruH7QD:AddField(	"DESCTPLIN",;				// [01]  C   Nome do Campo
		                        "27",;						// [02]  C   Ordem
		                        STR0060,;						// [03]  C   Titulo do campo // "Tipo Linha"
		                        STR0060,;						// [04]  C   Descricao do campo // "Tipo Linha"
		                        {STR0060},;					// [05]  A   Array com Help // "Selecionar"  //"Tipo Linha"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "@!",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
			
			
			                    
		EndIf
			
		
	EndIf
	
Return
