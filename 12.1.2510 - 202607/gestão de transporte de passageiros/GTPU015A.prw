#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU015A.CH'

/*/{Protheus.doc} GTPU015A
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
Function GTPU015A()
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., "Confirmar" },{.T., "Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Confirmar"###"Fechar" //'Fechar' //'Confirmar'

FwExecView(STR0001, "VIEWDEF.GTPU015A", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , 80/*nPercReducao*/, aEnableButtons, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ ) // "Abertura de Caixa" 

Return Nil

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
Local oModel   := Nil
Local oStruH7P := FwFormStruct(1,'H7P')
Local bFieldTrig := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bPosValid  := {|oModel| GU015PosVld(oModel)}
Local bCommit    := {|oModel| GU015ACommit(oModel)}

oStruH7P:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)

oStruH7P:AddTrigger("H7P_CODH7M" ,"H7P_CODH7M" ,{||.T.}, bFieldTrig)

oModel := MPFormModel():New('GTPU015', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)

oModel:AddFields('H7PMASTER',/*cOwner*/,oStruH7P)

oModel:SetDescription(STR0002) // "Fechamento de Caixa"
oModel:GetModel('H7PMASTER'):SetDescription(STR0002) // "Fechamento de Caixa"

oModel:GetModel( 'H7PMASTER'):SetOnlyQuery(.T.)

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
Local oModel	:= FWLoadModel('GTPU015A')
Local oView		:= FwFormView():New()
Local oStruH7PH	:= FwFormStruct(2, 'H7P',{|x| AllTrim(x) $ 'H7P_DTFECH|H7P_CODH7M|H7P_DSCH7M|'})

oView:SetModel(oModel)

oView:SetDescription(STR0002) // "Fechamento de Caixa"

oView:AddField('VIEW_HEADER', oStruH7PH, 'H7PMASTER')

oView:showInsertMsg(.F.)

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
Endif

Return uVal

/*/{Protheus.doc} GU015PosVld(oModel)
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
Static Function GU015PosVld(oModel)
Local lRet := .T.

dbSelectArea('H7P')
H7P->(dbSetOrder(2))

If H7P->(dbSeek(xFilial('H7P')+oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')+;
                    DtoS(oModel:GetModel('H7PMASTER'):GetValue('H7P_DTFECH'))))
    lRet := .F.
	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"PosValid", STR0003,, STR0004) //"Já existe um caixa com os parâmetros informados", "Verifique os parâmetros informados"
Endif

If lRet .And. !(VldCxaAbr(oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')))
    lRet := .F.
	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"PosValid", STR0005, STR0006) // "Local de arrecadação já possui um caixa aberto", "Feche o caixa aberto atual antes de abrir outro caixa"
Endif

Return lRet

Static Function VldCxaAbr(cCodLocal)
Local lRet := .T.
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp

    SELECT COUNT(H7P_CODIGO) TOTAL FROM %Table:H7P%
    WHERE
    H7P_FILIAL = %xFilial:H7P%
    AND H7P_CODH7M = %Exp:cCodLocal%
    AND H7P_STATUS = '1'
    AND %NotDel%

EndSql

lRet := (cAliasTmp)->TOTAL = 0 

(cAliasTmp)->(dbCloseArea())

Return lRet


/*/{Protheus.doc} GU015ACommit(oModel)
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
Static Function GU015ACommit(oModel)
Local oMdlH7P   := Nil
Local cCodLocal := oModel:GetModel('H7PMASTER'):GetValue('H7P_CODH7M')
Local dDataFech := oModel:GetModel('H7PMASTER'):GetValue('H7P_DTFECH')

If GTPUVldAut(cCodLocal, 'GTPU015')

    oMdlH7P := FwLoadModel('GTPU015')
    oMdlH7P:SetOperation(MODEL_OPERATION_INSERT)
    oMdlH7P:Activate();

    oMdlH7P:SetValue('H7PMASTER','H7P_CODH7M', cCodLocal)
    oMdlH7P:SetValue('H7PMASTER','H7P_DTFECH', dDataFech)
    oMdlH7P:SetValue('H7PMASTER','H7P_STATUS', '1')

    FwExecView(STR0002, "VIEWDEF.GTPU015", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oMdlH7P) // "Fechamento do Caixa",

Endif

Return .T.
