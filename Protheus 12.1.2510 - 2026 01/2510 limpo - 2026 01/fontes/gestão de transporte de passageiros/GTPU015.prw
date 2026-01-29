#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015.CH'

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
Function GTPU015()
Local oBrowse   := Nil
Local cMsgErro  := ''

If GU015VldDic(@cMsgErro)    
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
Static Function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.GTPU015' OPERATION 2 ACCESS 0	// "Visualizar"
ADD OPTION aRotina TITLE STR0009 ACTION 'GU015Incl()' OPERATION 3 ACCESS 0	    // "Abrir Caixa"
ADD OPTION aRotina TITLE STR0010 ACTION 'GU015VldOp(4)' OPERATION 4 ACCESS 0    // "Alterar"
ADD OPTION aRotina TITLE STR0011 ACTION 'GU015VldOp(5)' OPERATION 5 ACCESS 0    // "Excluir"
ADD OPTION aRotina TITLE STR0012 ACTION 'GU015Conf()' OPERATION 4 ACCESS 0      // "Conferir Caixa"
ADD OPTION aRotina TITLE STR0013 ACTION 'GU015Fecha()' OPERATION 4 ACCESS 0     // "Fechar Caixa"
ADD OPTION aRotina TITLE STR0014 ACTION 'GU015Reabr()' OPERATION 4 ACCESS 0     // "Reabrir Caixa"
	    
Return aRotina

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
Static Function ModelDef()
Local oModel	 := Nil
Local oStruH7P	 := FwFormStruct(1,'H7P')
Local oStruH7QR  := FwFormStruct(1,"H7Q") 
Local oStruH7QD  := FwFormStruct(1,"H7Q") 
Local bFieldTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFieldVld  := {|oMdl,cField,uNewValue,uOldValue| FieldValid(oMdl,cField,uNewValue,uOldValue)}
Local bPosValid  := {|oModel| PosValid(oModel)}
Local bCommit    := {|oModel| GU15Commit(oModel)}

oStruH7P:AddTrigger("H7P_CODH7M", "H7P_CODH7M", {||.T.}, bFieldTrig)
oStruH7QR:AddTrigger("H7Q_CODH7O", "H7Q_CODH7O", {||.T.}, bFieldTrig)
oStruH7QD:AddTrigger("H7Q_CODH7O", "H7Q_CODH7O", {||.T.}, bFieldTrig)
oStruH7QR:AddTrigger("H7Q_VALOR", "H7Q_VALOR", {||.T.}, bFieldTrig)
oStruH7QD:AddTrigger("H7Q_VALOR", "H7Q_VALOR", {||.T.}, bFieldTrig)

oStruH7QR:AddField("", "", "ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld()}, .F., .F., .T.)
oStruH7QD:AddField("", "", "ANEXO", "BT", 15,0, Nil, Nil, Nil, .F., {|| SetIniFld()}, .F., .F., .T.)
oStruH7QR:AddField("", "", "AC9RECNO", "N", 8,0, Nil, Nil, Nil, .F., {|| }, .F., .F., .T.)

//oStruH7QD:SetProperty('H7Q_QTDPAR', MODEL_FIELD_WHEN, {|oModel| oModel:GetValue('H7Q_CODH7O') == '006'})

oStruH7P:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oStruH7QR:SetProperty('H7Q_CODH7O', MODEL_FIELD_VALID, bFieldVld)
oStruH7QD:SetProperty('H7Q_CODH7O', MODEL_FIELD_VALID, bFieldVld)

oModel := MPFormModel():New('GTPU015', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| GU015VldAct(oModel)})

oModel:AddFields('H7PMASTER',/*cOwner*/,oStruH7P)
oModel:AddGrid('H7QRECEITA', 'H7PMASTER', oStruH7QR, /*bPre*/, /*bLinePost*/, /*bPre*/) 
oModel:AddGrid('H7QDESPESA', 'H7PMASTER', oStruH7QD, /*bPreLin*/, /*bLinePost*/) 

oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H7QDESPESA', 'H7Q_VALOR', 'SALDO_ANTERIOR', 'FORMULA', ,/*{|oModel| CalcSldAnt(oModel)}*/, STR0015,{|oModel| CalcSldAnt(oModel)}) // 'Saldo Anterior'
oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H7QRECEITA', 'H7Q_VALOR', 'CALC_RECEITA', 'SUM', { | |  .T. },, STR0016) // "Receitas"
oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H7QDESPESA', 'H7Q_VALOR', 'CALC_DESPESA', 'SUM', { | |  .T. },, STR0017) // "Despesas"
oModel:AddCalc('CALC_TOTAIS', 'H7PMASTER', 'H7QDESPESA', 'H7Q_VALOR', 'SALDO_ATUAL', 'FORMULA', ,/*{|oModel| CalcSldAtu(oModel)}*/, STR0018,{|oModel| AtuSaldo(oModel)}) // "Saldo Atual"

oModel:SetRelation('H7QRECEITA', {{'H7Q_FILIAL', 'xFilial( "H7Q")'},{'H7Q_CODH7P', 'H7P_CODIGO'},{'H7Q_TIPO', "'1'"}}, H7Q->(IndexKey(1)))
oModel:SetRelation('H7QDESPESA', {{'H7Q_FILIAL', 'xFilial( "H7Q")'},{'H7Q_CODH7P', 'H7P_CODIGO'},{'H7Q_TIPO', "'2'"}}, H7Q->(IndexKey(1)))

oModel:SetDescription(STR0001) // "Fechamento de Caixa"
oModel:GetModel('H7PMASTER'):SetDescription(STR0001) // "Fechamento de Caixa"

oModel:GetModel('H7QRECEITA'):SetOptional(.T.)
oModel:GetModel('H7QDESPESA'):SetOptional(.T.)

oModel:SetCommit(bCommit)
		
Return oModel

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
Static Function ViewDef()
Local oModel	:= ModelDef()
Local oView		:= FwFormView():New()
Local oStruH7PH	:= FwFormStruct(2, 'H7P',{|x| AllTrim(x) $ 'H7P_CODIGO|H7P_STATUS|H7P_DTFECH|H7P_CODH7M|H7P_DSCH7M|'})
Local oStruH7QR := FwFormStruct(2, "H7Q",{|x| !AllTrim(x) $ 'H7Q_FILIAL|H7Q_CODIGO|H7Q_CODH7P|H7Q_TIPO|H7Q_CONFER|H7Q_DTCONF|H7Q_USUCON|'})
Local oStruH7QD := FwFormStruct(2, "H7Q",{|x| !AllTrim(x) $ 'H7Q_FILIAL|H7Q_CODIGO|H7Q_CODH7P|H7Q_TIPO|H7Q_CONFER|H7Q_DTCONF|H7Q_USUCON|'}) 
Local oStruCalc := FwCalcStruct(oModel:GetModel('CALC_TOTAIS'))
Local bdblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}

oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Fechamento de Caixa"

oStruH7QR:SetProperty("H7Q_CODH7O",MVC_VIEW_LOOKUP,"H7OREC")
oStruH7QD:SetProperty("H7Q_CODH7O",MVC_VIEW_LOOKUP,"H7ODES")

oStruH7QR:AddField("ANEXO","01",STR0019,STR0019,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
oStruH7QD:AddField("ANEXO","01",STR0019,STR0019,{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"

oView:AddField('VIEW_HEADER', oStruH7PH, 'H7PMASTER')
oView:AddGrid('VIEW_H7QRECEITA', oStruH7QR, 'H7QRECEITA')
oView:AddGrid('VIEW_H7QDESPESA', oStruH7QD, 'H7QDESPESA')
oView:AddField('VIEW_CALC', oStruCalc, 'CALC_TOTAIS')

oView:CreateHorizontalBox('VIEWTOP', 25)
oView:CreateHorizontalBox('VIEWGRID', 55)
oView:CreateHorizontalBox('VIEWCALC', 20)

oView:CreateVerticalBox('GRIDREC',49,'VIEWGRID')
oView:CreateVerticalBox('GRID_SEP',2,'VIEWGRID')
oView:CreateVerticalBox('GRIDDES',49,'VIEWGRID')

oView:SetOwnerView('VIEW_HEADER', 'VIEWTOP')
oView:SetOwnerView('VIEW_H7QRECEITA', 'GRIDREC')
oView:SetOwnerView('VIEW_H7QDESPESA', 'GRIDDES')
oView:SetOwnerView('VIEW_CALC', 'VIEWCALC')

oView:EnableTitleView("VIEW_HEADER", STR0020) // "Dados do Fechamento de Caixa"
oView:EnableTitleView("VIEW_H7QRECEITA", STR0016) // "Receitas"
oView:EnableTitleView("VIEW_H7QDESPESA", STR0017) // "Despesas"
oView:EnableTitleView("VIEW_CALC", STR0021) // "Totais do Caixa"

oView:SetViewProperty("VIEW_H7QRECEITA", "GRIDDOUBLECLICK", bDblClick)
oView:SetViewProperty("VIEW_H7QDESPESA", "GRIDDOUBLECLICK", bDblClick)

oStruH7PH:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

oView:SetViewAction( 'DELETELINE', { |oView,cIdView,nNumLine| DeletaLinha( oView,cIdView,nNumLine ) } )
oView:SetViewAction( 'UNDELETELINE ', { |oView,cIdView,nNumLine| DeletaLinha( oView,cIdView,nNumLine ) } )

Return oView

/*/{Protheus.doc} FieldTrigger()
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/06/2024
@version 1.0
@return uVal
@type function
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

If cField == 'H7P_CODH7M'
    oMdl:SetValue("H7P_DSCH7M", Posicione('H7M',1,xFilial('H7M')+uVal,'H7M_DESC'))
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

ElseIf cField == 'H7Q_VALOR' .And. oMdl:cId == 'H7QRECEITA'
    oMdl:GetModel():GetModel('CALC_TOTAIS'):SetValue('SALDO_ATUAL',0)
Endif

Return uVal

/*/{Protheus.doc} FieldValid(oMdl, cField, uNewValue, uOldValue) 
//TODO Descrição auto-gerada.
@author flavio.martins
@since 13/06/2024
@version 1.0
@return uVal
@type function
/*/
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

/*/{Protheus.doc} VldRecDesp(cCodH7O, cMsgErro, cMsgSol)
//TODO Descrição auto-gerada.
@author flavio.martins
@since 04/06/2024
@version 1.0
@return uVal
@type function
/*/
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

/*/{Protheus.doc} GU015VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
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

/*/{Protheus.doc} GU015VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 03/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GU015VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H7P','H7Q'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'H7P_CODIGO','H7P_CODH7M','H7P_DTFECH','H7P_STATUS','H7P_TOTDES',;
            'H7P_TOTREC','H7P_DINENV','H7P_DINDSP','H7P_DINACM','H7P_SLDANT',;
            'H7P_DIFDIA','H7P_SLDATU','H7Q_CODIGO','H7Q_CODH7P','H7Q_CODH7O',;
            'H7Q_TIPO','H7Q_VALOR','H7Q_DTINI','H7Q_DTFIM','H7Q_DOCIDT',;
            'H7Q_QTDPAR','H7Q_JUSTIF','H7Q_CODBCO','H7Q_AGEBCO','H7Q_CTABCO',;
            'H7Q_CONFER','H7Q_DTCONF','H7Q_USUCON','H7Q_FILTIT','H7Q_PRETIT',;
            'H7Q_NUMTIT','H7Q_PARTIT','H7Q_TIPTIT'}

For nX := 1 To Len(aTables)
    If !(GTPxVldDic(aTables[nX], {}, .T., .F., @cMsgErro))
        lRet := .F.
        Exit
    Endif
Next

If Empty(cMsgErro)
	For nX := 1 To Len(aFields)
	    If !(Substr(aFields[nX],1,3))->(FieldPos(aFields[nX]))
	        lRet := .F.
	        cMsgErro := I18n("Campo #1 não se encontra no dicionário",{aFields[nX]})
	        Exit
	    Endif
	Next
EndIf

Return lRet

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
Function GU015Incl()

FwExecView(STR0001, "VIEWDEF.GTPU015A", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , 80/*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/) // "Fechamento do Caixa"

Return 

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
Static Function PosValid(oModel)
Local lRet := .T.

If FwIsInCallStack('GTPU015B') 

    oModel:GetModeL('H7PMASTER'):SetValue('H7P_STATUS', '3')

Else

    If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or.;
       oModel:GetOperation() == MODEL_OPERATION_UPDATE

        oModel:GetModel('H7PMASTER'):SetValue('H7P_TOTREC', oModel:GetValue('CALC_TOTAIS', 'CALC_RECEITA'))
        oModel:GetModel('H7PMASTER'):SetValue('H7P_TOTDES', oModel:GetValue('CALC_TOTAIS', 'CALC_DESPESA'))
        oModel:GetModel('H7PMASTER'):SetValue('H7P_SLDATU', oModel:GetValue('CALC_TOTAIS', 'SALDO_ATUAL'))

    Endif

Endif

Return lRet

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
Static Function PreLine(oMdl, nLine, cAction)
Local lRet := .T.

If cAction $ 'DELETE|UNDELETE'
    AtuSaldo(oMdl:GetModel())
Endif

Return lRet

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
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()

If cField == 'ANEXO'
    AttachDocs(oView, oGrid)
Endif

Return .T.

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
Static Function AttachDocs(oView, oGrid)
Local nRecno   :=  0 //oView:GetModel():GetModel('H69DETAIL'):GetDataId()
Local aRecACB  := {}
Local nRecnoAC9 := 0

If oGrid:cViewId == 'VIEW_H7QRECEITA'
    nRecno := oView:GetModel():GetModel('H7QRECEITA'):GetDataId()
Else 
    nRecno := oView:GetModel():GetModel('H7QDESPESA'):GetDataId()
Endif

If nRecno == 0
    FwAlertHelp(STR0027, STR0028, ) // "Atenção", "Grave o registro antes de anexar o documento"
Else

    MsDocument('H7Q', H7Q->(nRecno), 3,,,@aRecACB)

    nRecnoAC9 := AC9->(RecNo())

    If oGrid:cViewId == 'VIEW_H7QRECEITA'
        oView:GetModel():GetModel('H7QRECEITA'):LoadValue("ANEXO", SetIniFld())
        oView:GetModel():GetModel('H7QRECEITA'):LoadValue("AC9RECNO", nRecnoAC9)
    Else
        oView:GetModel():GetModel('H7QDESPESA'):LoadValue("ANEXO", SetIniFld())
    //    oView:GetModel():GetModel('H7QRECEITA'):LoadValue("AC9RECNO", nRecnoAC9)
    Endif

    oView:Refresh()

Endif

Return 

/*/{Protheus.doc} SetIniFld()
(long_description)
@type  Static Function
@author flavio.martins
@since 14/06/2024
@version 1.0@param , param_type, param_descr
@return cValor
@example
(examples)
@see (links_or_references)
/*/
Static Function SetIniFld()
Local cValor := ''

AC9->(dbSetOrder(2))

If AC9->(dbSeek(xFilial('AC9')+'H7Q'+xFilial('H7Q')+xFilial('H7Q')+H7Q->H7Q_CODIGO))
    cValor := "F5_VERD"
Else
    cValor := 'F5_VERM'
Endif

Return cValor

/*/{Protheus.doc} GU015VldOp(nOperation)
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
Function GU015VldOp(nOperation)
Local cCodLocal := H7P->H7P_CODH7M

If GTPUVldAut(cCodLocal, "GTPU015")

    If nOperation == MODEL_OPERATION_UPDATE

        If !(H7P->H7P_STATUS $ '1|4')
            FwAlertInfo(STR0029) // "Status atual do caixa não permite a alteração"
        Endif

    ElseIf nOperation == MODEL_OPERATION_DELETE

        If !(H7P->H7P_STATUS $ '1|4')
            FwAlertInfo(STR0030) // "Status atual do caixa não permite a exclusão"
        Endif

    Endif

    If lRet 
        FwExecView(STR0001, "VIEWDEF.GTPU015", nOperation,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/) // "Fechamento do Caixa" 
    Endif

Endif

Return 

/*/{Protheus.doc} GU015Fecha()
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
Function GU015Fecha()
Local oModel    := Nil
Local cCodLocal := H7P->H7P_CODH7M

If GTPUVldAut(cCodLocal, "GTPU015")

    If !(H7P->H7P_STATUS $ '1|4')
        lRet := .F.
        FwAlertInfo(STR0031) // "Status atual do caixa não permite que o mesmo seja fechado"
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

    Endif

Endif

Return

/*/{Protheus.doc} GU015Conf()
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

Return

/*/{Protheus.doc} GU015Reabr()
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
Function GU015Reabr()
Local lRet      := .T.
Local cCodCaixa := H7P->H7P_CODIGO
Local cCodLocal := H7P->H7P_CODH7M

If GTPUVldAut(cCodLocal, "GTPU015")

    Begin Transaction

        If (H7P->H7P_STATUS $ '1|4|5')
            lRet := .F.
            FwAlertInfo(STR0035) // "Status do caixa não permite a reabertura"
        Else 

            If FwAlertYesNo(STR0036, STR0027) // "A reabertura do caixa poderá excluir os títulos financeiros gerados. Tem certeza que deseja reabrir este caixa?","Atenção"
                FwMsgRun(,{|| lRet := GTPU015D(cCodCaixa)}, STR0037, STR0038) // "Reabrindo o caixa...", "Aguarde..."
            Endif  

            If lRet

                lRet := EstornaCnf(cCodCaixa)

                FwAlertSuccess(STR0039) // "Caixa reaberto com sucesso"
            Else
                DisarmTransaction()
            Endif

        Endif

    End Transaction

Endif

Return lRet 

/*/{Protheus.doc} EstornaCnf(cCodCaixa)
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

/*/{Protheus.doc} GU15Commit(oModel)
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
Static Function GU15Commit(oModel)
Local lRet      := .T.
Local cCodCaixa := ''

cCodCaixa := oModel:GetValue('H7PMASTER', 'H7P_CODIGO')

Begin Transaction

    FwFormCommit(oModel)

    If FwIsInCallStack('GTPU015B') 

        FwMsgRun(,{|| lRet := GTPU015C(cCodCaixa)}, STR0040, STR0038) // "Gerando títulos de despesas e receitas...", "Aguarde..."
    
    Endif

    If !(lRet)
        DisarmTransaction()
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GU15Commit", STR0041, STR0042) // "Conferência do Caixa não realizada", "Verifique os erros"
    Endif

End Transaction

Return lRet

/*/{Protheus.doc} CalcSldAnt(oModel)
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
Static Function CalcSldAnt(oModel)
Local nSaldoAnt := oModel:GetValue('H7PMASTER','H7P_SLDANT')

Return nSaldoAnt

/*/{Protheus.doc} AtuSaldo(oModel)
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
Static Function AtuSaldo(oModel)
Local nSaldoAnt := oModel:GetValue('H7PMASTER','H7P_SLDANT')
Local nReceita  := oModel:GetValue('CALC_TOTAIS','CALC_RECEITA')
Local nDespesa  := oModel:GetValue('CALC_TOTAIS','CALC_DESPESA')
Local nSaldoAtu := 0
Local nX := 1

nReceita := 0

For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

    oModel:GetModel('H7QRECEITA'):GoLine(nX)

    If !oModel:GetModel('H7QRECEITA'):IsDeleted()
        nReceita += oModel:GetValue('H7QRECEITA', 'H7Q_VALOR')
    Endif


Next nX


nSaldoAtu := nSaldoAnt + nReceita - nDespesa

Return nSaldoAtu

/*/{Protheus.doc} DeletaLinha(oView, cIdView, nNumLine)
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
Static Function DeletaLinha(oView, cIdView, nNumLine)
Local oModel := oView:GetModel()

Local nX := 1

nReceita := 0

For nX := 1 To oModel:GetModel('H7QRECEITA'):Length()

    oModel:GetModel('H7QRECEITA'):GoLine(nX)

    If !oModel:GetModel('H7QRECEITA'):IsDeleted()
        nReceita += oModel:GetValue('H7QRECEITA', 'H7Q_VALOR')
    Endif

Next nX

oModel:GetModel('CALC_TOTAIS'):SetValue('SALDO_ATUAL',0)

oView:Refresh('VIEW_CALC')

Return
