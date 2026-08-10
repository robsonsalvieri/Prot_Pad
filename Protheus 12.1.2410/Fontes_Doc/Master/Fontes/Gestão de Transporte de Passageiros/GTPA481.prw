#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA481.CH'

/*/{Protheus.doc} GTPA481
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA481(oModel)
Local nOperation := MODEL_OPERATION_VIEW
Local cMsgErro   := ""

Private oMdl421  := Nil
Private dDataIni := Nil
Private dDataFim := Nil

Default oModel := FwLoadModel("GTPA421")

If !G480VldDic(@cMsgErro)    
    FwAlertHelp(cMsgErro, STR0025) // "Banco de dados desatualizado, não será possível iniciar a rotina"
    Return
Endif

If !oModel:IsActive() 
    oModel:SetOperation(MODEL_OPERATION_VIEW)
    oModel:Activate()
    nOperation := MODEL_OPERATION_UPDATE
Endif

oMdl421  := oModel:GetModel("G6XMASTER")
dDataIni := oModel:GetValue("G6XMASTER", "G6X_DTINI")
dDataFim := oModel:GetValue("G6XMASTER", "G6X_DTFIN")

dbSelectArea("GI6")

GI6->(DbSetOrder(1))

If GI6->(dbSeek(xFilial("GI6")+oModel:GetValue("G6XMASTER", "G6X_AGENCI"))) .And. GI6->(FieldPos("GI6_CTRCXA")) > 0 

    If GI6->GI6_CTRCXA == '1'
        FwExecView(STR0024, "VIEWDEF.GTPA481", nOperation, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, 10 ,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) // "Caixa de Colaboradores - Conferência"
    Else
        FwAlertWarning(STR0010, STR0011) // "Controle de caixa desabilitado para esta agência", "Atenção"
    Endif

Endif

Return Nil

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruG6X	:= FwFormStruct(1,'G6X')
Local oStruH6M	:= FwFormStruct(1,'H6M')
Local oStruH6N	:= FwFormStruct(1,'H6N')
Local bLoad		:= {|oModel| GA481Load(oModel)}
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldInit	:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bCommit   := {|oModel| G481Commit(oModel)}  
Local bVldAct   := {|oModel| GA481VldAct(oModel)}
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|FieldValid(oMdl,cField,cNewValue,cOldValue) }

oStruH6M:AddField("", "", "H6M_LEGEND", "BT", 15,0, Nil, Nil, Nil, .F., bFldInit /*{|oModel| SetIniFld(oModel)}*/, .F., .F., .T.)
oStruH6N:AddField("", "", "H6N_LEGEND", "BT", 15,0, Nil, Nil, Nil, .F., bFldInit /*{|oModel| SetIniFld(oModel)}*/, .F., .F., .T.)

oStruH6N:AddTrigger("H6N_STATUS","H6N_STATUS",{ || .T. }, bFldTrig)
oStruH6N:SetProperty("H6N_CONFER", MODEL_FIELD_VALID, bFldVld)

oModel := MPFormModel():New('GTPA481', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('G6XMASTER',/*cOwner*/,oStruG6X,,,bLoad)
oModel:AddGrid('H6MDETAIL','G6XMASTER',oStruH6M, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:AddGrid('H6NDETAIL','H6MDETAIL',oStruH6N, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

oModel:SetRelation('H6MDETAIL', {{'H6M_FILIAL', 'xFilial("H6M")'}, {'H6M_AGENCI', 'G6X_AGENCI'}}, H6M->(IndexKey(1)))
oModel:SetRelation('H6NDETAIL', {{'H6N_FILIAL', 'xFilial("H6N")'}, {'H6N_CODH6M', 'H6M_CODIGO'}}, H6N->(IndexKey(1)))

If Type("dDataIni") == "D" .And. Type("dDataFim") == "D"
    oModel:GetModel("H6MDETAIL"):SetLoadFilter(, "( H6M_DATACX >= '" + DtoS(dDataIni) + "'" + " AND H6M_DATACX <= '" + DtoS(dDataFim) + "')" )
Endif

oModel:GetModel('H6MDETAIL'):SetOptional(.T.)
oModel:GetModel('H6NDETAIL'):SetOptional(.T.)

oModel:GetModel('G6XMASTER'):SetOnlyView(.T.)
oModel:GetModel('H6MDETAIL'):SetOnlyView(.T.)

oModel:SetDescription(STR0001) // "Caixa de Colaboradores - Consulta"

oModel:GetModel('G6XMASTER'):SetDescription(STR0002) // "Ficha de Remessa"

oModel:SetVldActivate(bVldAct)
oModel:SetCommit(bCommit)

Return oModel

/*/{Protheus.doc} FieldInit
@type Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet := uVal

If cField == 'H6N_LEGEND'
    Do Case
        Case H6N->H6N_STATUS == '1'
            uRet := 'BR_BRANCO'
        Case H6N->H6N_STATUS == '2'
            uRet := 'BR_AZUL'
        Case H6N->H6N_STATUS == '3'
            uRet := 'BR_AMARELO'
    EndCase  
Endif

If cField == 'H6M_LEGEND'

    If H6M->H6M_STATUS == '1'
        uRet := 'BR_VERDE'
    Else
        uRet := 'BR_VERMELHO'
    Endif

Endif

Return uRet

/*/{Protheus.doc} FieldValid
@type Static Function
@author flavio.martins
@since 23/11/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,cNewValue,cOldValue)
Local oModel    := oMdl:GetModel()
Local lRet	    := .T.
Local cMsgErro	:= "" 
Local cMsgSol 	:= ""

If cField == 'H6N_CONFER'

    If cNewValue != '2' .And. !Empty(oMdl:GetValue('H6N_CODGQP'))
       lRet 	:= .F.
	   cMsgErro := STR0020 // "O caixa já possui um vale gerado. O status da conferência não poderá ser alterado"
	   cMsgSol  := "" 
    Endif

Endif
	
If !lRet
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"FieldInit",cMsgErro,cMsgSol,cNewValue) 
Endif
	
Return lRet

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , param_type, param_descr
@return oView, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oModel	 := ModelDef()
Local oView		 := FwFormView():New()
Local cFieldsG6X := 'G6X_AGENCI|G6X_DESCAG|G6X_DTINI|G6X_DTFIN|G6X_DTREME|G6X_NUMFCH'
Local cFieldsH6M := 'H6M_LEGEND|H6M_STATUS|H6M_CODIGO|H6M_DATACX|H6M_RECBIL|H6M_CANBIL|H6M_DEVBIL|H6M_RECTAX|H6M_RECADC'
Local aFieldsH6M := StrToKarr(cFieldsH6M, "|")
Local cFieldsH6N := 'H6N_LEGEND|H6N_STATUS|H6N_SEQ|H6N_COLAB|H6N_NCOLAB|H6N_RECBIL|H6N_CANBIL|H6N_DEVBIL|H6N_RECTAX|H6N_RECADC|H6N_TOTLIQ|H6N_TOTCAR|H6N_VLPEND|H6N_CONFER|H6N_CODGQP'
Local aFieldsH6N := StrToKarr(cFieldsH6N, "|")
Local oStruG6X	 := FwFormStruct(2, 'G6X', {|x| AllTrim(x) $ cFieldsG6X})
Local oStruH6M	 := FwFormStruct(2, 'H6M', {|x| AllTrim(x) $ cFieldsH6M})
Local oStruH6N	 := FwFormStruct(2, 'H6N', {|x| AllTrim(x) $ cFieldsH6N})
Local bDblClick  := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}
	
oStruH6M:AddField("H6M_LEGEND","01","","",{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) 
oStruH6N:AddField("H6N_LEGEND","01","","",{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) 

oView:SetModel(oModel)

oView:SetDescription(STR0002) // "Caixa de Colaboradores - Consulta"

oView:AddField('VIEW_G6X', oStruG6X,'G6XMASTER')
oView:AddGrid('VIEW_H6M', oStruH6M,'H6MDETAIL')
oView:AddGrid('VIEW_H6N', oStruH6N,'H6NDETAIL')

oView:CreateHorizontalBox('HEADER'  , 30)
oView:CreateHorizontalBox('GRID_H6M', 35)
oView:CreateHorizontalBox('GRID_H6N', 35)

oView:SetOwnerView('VIEW_G6X', 'HEADER')
oView:SetOwnerView('VIEW_H6M', 'GRID_H6M')
oView:SetOwnerView('VIEW_H6N', 'GRID_H6N')

oView:EnableTitleView("VIEW_G6X", STR0003) // "Dados da Ficha de Remessa"
oView:EnableTitleView("VIEW_H6M", STR0004) // "Caixas"
oView:EnableTitleView("VIEW_H6N", STR0005) // "Colaboradores"

SetOrdStru(oStruH6M, aFieldsH6M)
SetOrdStru(oStruH6N, aFieldsH6N)

oView:SetViewProperty("VIEW_H6M", "GRIDDOUBLECLICK", bDblClick)

oStruH6N:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruH6N:SetProperty('H6N_CONFER', MVC_VIEW_CANCHANGE, .T.)

oView:AddUserButton(STR0012, "GTPA481",{|oView| GerVlColab(oView)}, STR0012, , {MODEL_OPERATION_UPDATE})   // "Vale do Colaborador"

Return oView

/*/{Protheus.doc} SetOrdStru
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetOrdStru(oStruct, aFields)
Local nX := 0

For nX := 1 To Len(aFields)
    oStruct:SetProperty(aFields[nX], MVC_VIEW_ORDEM , StrZero(nX, 2))
Next

Return

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)

dbSelectArea('H6M')
H6M->(DbSetOrder(1))

If H6M->(dbSeek(xFilial('H6M')+oGrid:GetModel('H6MDETAIL'):GetValue("H6M_CODIGO")))
    FwExecView(STR0009, "VIEWDEF.GTPA480", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,  ,/*aButtons*/, {||.T.}/*bCancel*/,,,/*oModel*/) // "Consulta"
Endif

Return .T.

/*/{Protheus.doc} GA481Load
(long_description)
@type  Static Function
@author flavio.martins
@since 16/11/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA481Load(oModel)
Local aLoad 	:= {}
Local aDados    := {}
Local aStruMdl  := {}
Local nX        := 0        

If oModel:GetId() == 'G6XMASTER'

    If oMdl421 != Nil
        aStruMdl := oModel:GetStruct():GetFields()

        For nX := 1 To Len(aStruMdl)

            aAdd(aDados, oMdl421:GetValue(aStruMdl[nX][3]))

        Next

        aAdd(aLoad, aDados)
        aAdd(aLoad, 0) 

    Endif

Endif

Return aLoad

/*/{Protheus.doc} G481Commit
//TODO Descrição auto-gerada.
@author flavio.martins
@since 21/11/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function G481Commit(oModel)
Local lRet    := .T.
Local nX      := 0
Local oGtpLog := GtpLog():New(STR0022) // "Vales"
Local cColab   := ''
Local cAgencia := ''
Local nVlrPend := 0
Local cCodGQP  := ''

If oModel:GetOperation() == MODEL_OPERATION_UPDATE

    If oModel:GetModel('H6NDETAIL'):SeekLine({{'H6N_STATUS', '3'},;
            {'H6N_CODGQP', Space(TamSx3("H6N_CODGQP")[1])},;
            {'H6N_CONFER', '2'}})
        If FwAlertYesNo(STR0013) // "Encontrado colaboradores com valores pendentes de acerto. Deseja gerar os vales agora ?"
            
            For nX := 1 To oModel:GetModel('H6NDETAIL'):Length()
    
                oModel:GetModel('H6NDETAIL'):GoLine(nX)

                If oModel:GetModel('H6NDETAIL'):GetValue('H6N_STATUS') == '3' .And.;
                  oModel:GetModel('H6NDETAIL'):GetValue('H6N_CONFER') == '2'.And.;
                  Empty(oModel:GetModel('H6NDETAIL'):GetValue('H6N_CODGQP'))

                    cColab   := oModel:GetModel('H6NDETAIL'):GetValue('H6N_COLAB')
                    cAgencia := oModel:GetModel('H6MDETAIL'):GetValue('H6M_AGENCI')
                    nVlrPend := oModel:GetModel('H6NDETAIL'):GetValue('H6N_VLPEND')
                
                    cCodGQP := InsVlColab(cColab, cAgencia, nVlrPend)

                    If !Empty(cCodGQP)

                        oModel:GetModel('H6NDETAIL'):SetValue('H6N_CODGQP', cCodGQP)

                        oGtpLog:SetText(I18n(STR0023,; // "Gerado vale de #1 no valor de #2 para o colaborador #3"
                            {oModel:GetValue('H6NDETAIL', 'H6N_CODGQP'),;
                            Transform(oModel:GetValue('H6NDETAIL', 'H6N_VLPEND'), "@E 99,999.99"),;
                            oModel:GetValue('H6NDETAIL', 'H6N_COLAB') + ;
                            " - " + oModel:GetValue('H6NDETAIL', 'H6N_NCOLAB')}))

                    Endif
                Endif
            Next

        Endif
    Endif
    
    For nX := 1 To oModel:GetModel('H6NDETAIL'):Length()

        oModel:GetModel('H6NDETAIL'):GoLine(nX)

        If oModel:GetValue('H6NDETAIL', 'H6N_CONFER') $ '2|3' .And. Empty(oModel:GetValue('H6NDETAIL', 'H6N_USUCON'))
            oModel:GetModel('H6NDETAIL'):SetValue('H6N_USUCON', __cUserId)
            oModel:GetModel('H6NDETAIL'):SetValue('H6N_DTCONF', dDataBase)
        ElseIf oModel:GetValue('H6NDETAIL', 'H6N_CONFER') == '1' .And. !Empty(oModel:GetValue('H6NDETAIL', 'H6N_USUCON'))
            oModel:GetModel('H6NDETAIL'):ClearField('H6N_USUCON')
            oModel:GetModel('H6NDETAIL'):ClearField('H6N_DTCONF')
        Endif

    Next

    If oModel:VldData()
        FwFormCommit(oModel)

        If oGtpLog:HasInfo() .And. !IsBlind()
            oGtpLog:ShowLog()
        Endif

    Endif

    oGtplog:Destroy()

Endif

Return lRet

/*/{Protheus.doc} GA481VldAct
//TODO Descrição auto-gerada.
@author flavio.martins
@since 22/11/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function GA481VldAct(oModel)
Local cStatus	:= G6X->G6X_STATUS
Local lRet		:= .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G480VldDic(@cMsgErro)
    lRet     := .F.
    cMsgSol  :=  STR0026 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA481PosVld", cMsgErro, cMsgSol) 
    Return .F.
Endif

If oModel:GetOperation() == MODEL_OPERATION_UPDATE

    If !(cStatus $ '2|5')
        cMsgErro := STR0014 // "Status atual da Ficha de Remessa não permite a conferência"
        cMsgSol  := ""
        lRet := .F.
    Endif

    If !lRet
        oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G481VldAct",cMsgErro,cMsgSol,,)
    Endif

Endif
	    
Return lRet

/*/{Protheus.doc} GerVlColab
//TODO Descrição auto-gerada.
@author flavio.martins
@since 22/11/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function GerVlColab(oView)
Local oModel    := oView:GetModel()
Local cTpVale	:= GTPGetRules('TPVALECXA')
Local cCodGQP   := 0
Local cColab    := ''
Local cAgencia  := ''
Local nVlrPend  := 0

Default lMessage := .T.

If oModel:GetValue('H6NDETAIL', 'H6N_STATUS') != '3'
    FwAlertWarning(STR0015, STR0011) // "Opção válida apenas para caixas com status 'Acerto Pendente'", "Atenção"
    Return
Endif

If oModel:GetValue('H6NDETAIL', 'H6N_CONFER') != '2'
    FwAlertWarning(STR0021, STR0011) // "O vale só pode ser gerado para caixas com o status 'Conferido'", "Atenção"
    Return
Endif

If Empty(cTpVale)
    FwAlertWarning(STR0016, STR0011) // "Para gerar os vales é necessário que o parâmetro 'TPVALECXA' esteja configurado", "Atenção"
    Return
Endif

If Empty(oModel:GetValue('H6NDETAIL', 'H6N_CODGQP')) 
    
    If FwAlertYesNo(STR0027) // "Confirma a geração do vale para o colaborador ?"

        cColab   := oModel:GetValue('H6NDETAIL', 'H6N_COLAB')
        cAgencia := oModel:GetValue('H6MDETAIL', 'H6M_AGENCI')
        nVlrPend := oModel:GetValue('H6NDETAIL', 'H6N_VLPEND')

        cCodGQP := InsVlColab(cColab, cAgencia, nVlrPend)

        If !Empty(cCodGQP)
            oModel:GetModel('H6NDETAIL'):SetValue('H6N_CODGQP', cCodGQP)
            FwFormCommit(oModel)

            oModel:GetModel('H6NDETAIL'):SeekLine({{'H6N_CODGQP', cCodGQP}})

            FwAlertSuccess(I18n(STR0023, {oModel:GetValue('H6NDETAIL', 'H6N_CODGQP'),;
                AllTrim(Transform(oModel:GetValue('H6NDETAIL', 'H6N_VLPEND'), "@E 99,999.99")),;
                oModel:GetValue('H6NDETAIL', 'H6N_COLAB') + ;
                " - " + oModel:GetValue('H6NDETAIL', 'H6N_NCOLAB')}))
        Endif

    Endif

Else

    dbSelectArea('GQP')
    GQP->(DbSetOrder(1))

    If GQP->(dbSeek(xFilial('GQP')+oModel:GetValue('H6NDETAIL', 'H6N_CODGQP')))
        FwExecView(STR0009, "VIEWDEF.GTPA110", MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,  ,/*aButtons*/, {||.T.}/*bCancel*/,,,) // "Consulta"
    Endif
    
Endif

Return

/*/{Protheus.doc} InsVlColab
//TODO Descrição auto-gerada.
@author flavio.martins
@since 22/11/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel
@type function
/*/
Static Function InsVlColab(cColab, cAgencia, nVlrPend)
Local oMdlVale  := FwLoadModel("GTPA110")
Local cTpVale	:= GTPGetRules('TPVALECXA')
Local cCodGQP   := ''

oMdlVale:SetOperation(MODEL_OPERATION_INSERT)
oMdlVale:Activate()
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_TIPO'  , cTpVale)
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_CODFUN', cColab)
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_EMISSA', dDataBase)
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_VIGENC', dDataBase)
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_CODAGE', cAgencia)
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_VALOR' , nVlrPend)
oMdlVale:GetModel('FIELDGQP'):SetValue('GQP_DESFIN', STR0019) // 'PENDÊNCIA DE ACERTO VENDAS EMBARCADAS'

If oMdlVale:VldData()
    cCodGQP := oMdlVale:GetModel('FIELDGQP'):GetValue('GQP_CODIGO')
    oMdlVale:CommitData()
Endif

oMdlVale:DeActivate()
oMdlVale:Destroy()

Return cCodGQP
