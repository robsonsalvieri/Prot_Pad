#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPU014.CH'

/*/{Protheus.doc} GTPU014
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
Function GTPU014()
Local oBrowse   := Nil
Local cMsgErro  := ''

If GU014VldDic(@cMsgErro)   

	Processa({|| GTPU014Load()})

    oBrowse := FwMBrowse():New()
    oBrowse:SetAlias('H7O')
    oBrowse:SetDescription(STR0001) // "Tipos de Receitas e Despesa - Urbano"
    oBrowse:Activate()
Else
    FwAlertHelp(cMsgErro, STR0002) // "Banco de dados desatualizado, não será possível iniciar a rotina"
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
	
ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.GTPU014' OPERATION 2 ACCESS 0	//'Visualizar'
ADD OPTION aRotina TITLE "Incluir" ACTION 'VIEWDEF.GTPU014' OPERATION 3 ACCESS 0	//'Incluir'
ADD OPTION aRotina TITLE "Alterar" ACTION 'VIEWDEF.GTPU014' OPERATION 4 ACCESS 0	//'Alterar'
ADD OPTION aRotina TITLE "Excluir" ACTION 'VIEWDEF.GTPU014' OPERATION 5 ACCESS 0	//'Excluir'
	    
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
Local oModel	:= Nil
Local oStruH7O	:= FwFormStruct(1,'H7O')
Local bPosValid   := {|oModel| GU014PosVld(oModel)}

oStruH7O:SetProperty("*", MODEL_FIELD_WHEN, {|| FwFldGet('H7O_PROPRI') <> 'S'})
oStruH7O:SetProperty("H7O_PREREC", MODEL_FIELD_WHEN, {|| FwFldGet('H7O_GERTIT') == '1' .And. FwFldGet('H7O_TIPO') $ '1|3'})
oStruH7O:SetProperty("H7O_NATREC", MODEL_FIELD_WHEN, {|| FwFldGet('H7O_GERTIT') == '1' .And. FwFldGet('H7O_TIPO') $ '1|3'})
oStruH7O:SetProperty("H7O_PREDES", MODEL_FIELD_WHEN, {|| FwFldGet('H7O_GERTIT') == '1' .And. FwFldGet('H7O_TIPO') $ '2|3'})
oStruH7O:SetProperty("H7O_NATDES", MODEL_FIELD_WHEN, {|| FwFldGet('H7O_GERTIT') == '1' .And. FwFldGet('H7O_TIPO') $ '2|3'})

oModel := MPFormModel():New('GTPU014', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| GU014VldAct(oModel)})

oModel:AddFields('H7OMASTER',/*cOwner*/,oStruH7O)

oModel:SetDescription(STR0001) // "Tipos de Receitas e Despesa - Urbano"
oModel:GetModel('H7OMASTER'):SetDescription(STR0001) // "Tipos de Receitas e Despesa - Urbano"
		
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
Local oStruH7O	:= FwFormStruct(2, 'H7O')

oStruH7O:SetProperty('H7O_PROPRI', MVC_VIEW_CANCHANGE, .F.)

oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Tipos de Receitas e Despesas - Urbano"

oView:AddField('VIEW_H7O', oStruH7O,'H7OMASTER')

Return oView

/*/{Protheus.doc} GU014VldAct
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
Static Function GU014VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !GU014VldDic(@cMsgErro)
    lRet := .F.
    cMsgSol :=  STR0003 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GU014VldAct", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet

/*/{Protheus.doc} GU014VldDic
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
Static Function GU014VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H7O'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'H7O_CODIGO','H7O_DESCRI','H7O_TIPO  ','H7O_PROPRI',;
			'H7O_INCMAN','H7O_GERTIT','H7O_BXATIT','H7O_PREREC',;
			'H7O_NATREC','H7O_PREDES','H7O_NATDES'}

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

Static Function GU014PosVld(oModel)
Local lRet := .T.

If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. oModel:GetValue('H7OMASTER','H7O_PROPRI') == 'S'
	lRet := .F.
	oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU014PosVld", STR0004) // "Registros criados pelo sistema não podem ser excluídos"
Endif

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE

	If oModel:GetValue('H7OMASTER', 'H7O_GERTIT') == '1' .And. oModel:GetValue('H7OMASTER', 'H7O_TIPO') $ '1|3' .And.;
		(Empty(oModel:GetValue('H7OMASTER', 'H7O_PREREC')) .Or. Empty(oModel:GetValue('H7OMASTER', 'H7O_NATREC')))

		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU014PosVld", STR0005, STR0006) // "Tipo de Receita/Despesa configurado para gerar título financeiro", "É necessário informar o prefixo e a natureza de receita para geração do título"

	ElseIf oModel:GetValue('H7OMASTER', 'H7O_GERTIT') == '1' .And. oModel:GetValue('H7OMASTER', 'H7O_TIPO') $ '2|3' .And.;
		(Empty(oModel:GetValue('H7OMASTER', 'H7O_PREDES')) .Or. Empty(oModel:GetValue('H7OMASTER', 'H7O_NATDES')))

		lRet := .F.
		oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","GU014PosVld", STR0007, STR0008) // "Tipo de Receita/Despesa configurado para gerar título financeiro", "É necessário informar o prefixo e a natureza de despesa para geração do título"

	Endif

Endif

Return lRet

/*/{Protheus.doc} GTPU014Load()
(long_description)
@type  Static Function
@author flavio.martins
@since 12/06/2024
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPU014Load()
Local lRet      := .T.
Local aArea     := GetArea()
Local oModel	:= FwLoadModel('GTPU014')
Local oMdlH7O	:= oModel:GetModel('H7OMASTER')
Local aDados	:= {}
Local nX		:= 0

aAdd(aDados,{StrZero(01,TamSx3('H7O_CODIGO')[1]), 'TARIFA', '1', 'S', '2'})
aAdd(aDados,{StrZero(02,TamSx3('H7O_CODIGO')[1]), 'PEDAGIO','1', 'S', '2'})
aAdd(aDados,{StrZero(03,TamSx3('H7O_CODIGO')[1]), 'GTV', '2', 'S', '1'})              
aAdd(aDados,{StrZero(04,TamSx3('H7O_CODIGO')[1]), 'FURTO/ROUBO', '2', 'S', '1'})           
aAdd(aDados,{StrZero(05,TamSx3('H7O_CODIGO')[1]), 'ABONO', '2', 'S','1'})         
aAdd(aDados,{StrZero(06,TamSx3('H7O_CODIGO')[1]), 'DESCONTO EM FOLHA', '2', 'S', '1'})             
aAdd(aDados,{StrZero(07,TamSx3('H7O_CODIGO')[1]), 'VALE TRANSPORTE', '2', 'S', '1'})             

H7O->(dbSetOrder(1))
For nX := 1 to Len(aDados)
	If !H7O->(dbSeek(xFilial('H7O')+aDados[nX][1]))
	
		oModel:SetOperation(MODEL_OPERATION_INSERT)

		If oModel:Activate()
			oMdlH7O:LoadValue('H7O_CODIGO'	,aDados[nX][1])
			oMdlH7O:LoadValue('H7O_DESCRI'	,aDados[nX][2])
			oMdlH7O:LoadValue('H7O_TIPO'	,aDados[nX][3])
			oMdlH7O:LoadValue('H7O_PROPRI'	,aDados[nX][4])
			oMdlH7O:LoadValue('H7O_INCMAN'	,aDados[nX][5])
			
            If oModel:VldData() 
				oModel:CommitData()
			EndIf

		EndIf
		
		oModel:Deactivate()
	
	EndIf
Next

oModel:Destroy()
RestArea(aArea)
GtpDestroy(aDados)

Return lRet
