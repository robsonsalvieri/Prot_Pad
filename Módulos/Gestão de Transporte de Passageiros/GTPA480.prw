#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA480.CH'

/*/{Protheus.doc} GTPA480
(long_description)
@type  Static Function
@author flavio.martins
@since 07/11/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA480()
Local oBrowse   := Nil
Local cMsgErro  := ''

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
        
    If G480VldDic(@cMsgErro)    
        oBrowse := FwMBrowse():New()
        oBrowse:SetAlias('H6M')
        oBrowse:SetDescription(STR0001) // "Caixa do Colaborador"
        oBrowse:AddLegend('H6M_STATUS == "1"',"GREEN","Aberto")
        oBrowse:AddLegend('H6M_STATUS == "2"',"RED"	 ,"Fechado")
        oBrowse:Activate()
    Else
        FwAlertHelp(cMsgErro, STR0002) // "Banco de dados desatualizado, não será possível iniciar a rotina"
    Endif

EndIf

Return Nil

/*/{Protheus.doc} MenuDef
(long_description)
@type  Static Function
@author flavio.martins
@since 07/11/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina TITLE STR0003 ACTION 'GTP480Menu(1)' OPERATION 3 ACCESS 0	// "Abrir Caixa"
ADD OPTION aRotina TITLE STR0004 ACTION 'GTP480Menu(2)' OPERATION 2 ACCESS 0	// "Ver Caixa"
ADD OPTION aRotina TITLE STR0005 ACTION 'GTP480Menu(3)' OPERATION 5 ACCESS 0	// "Excluir"
ADD OPTION aRotina TITLE STR0033 ACTION 'GTP480REL()'   OPERATION 4 ACCESS 0	// "Impressão Caixa Colaborador"
	            
Return aRotina

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 07/11/2022
@version 1.0
@param , param_type, param_descr
@return oModel, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruH6M	:= FwFormStruct(1,'H6M')
Local oStruH6N	:= FwFormStruct(1,'H6N')
Local oStruGIC	:= FwFormStruct(1,'GIC')
Local oStruG57	:= FwFormStruct(1,'G57')
Local oStruGZT	:= FwFormStruct(1,'GZT')
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|FieldValid(oMdl,cField,cNewValue,cOldValue) }
Local bCommit   := {|oModel| G480Commit(oModel) }

oStruH6N:AddField("", "", "LEGENDA", "BT", 15,0, Nil, Nil, Nil, .F., {|oModel| SetIniFld(oModel)}, .F., .F., .T.)

oStruH6M:AddTrigger("H6M_STATUS","H6M_STATUS",{ || .T. }, bFldTrig)

oStruH6N:AddTrigger("H6N_STATUS","H6N_STATUS",{ || .T. }, bFldTrig)

oStruH6N:SetProperty("H6N_STATUS", MODEL_FIELD_WHEN, {|oMdl| oMdl:GetValue('H6N_CONFER') == '1' })

oStruH6N:SetProperty("H6N_VLPEND", MODEL_FIELD_VALID, bFldVld)

oModel := MPFormModel():New('GTPA480', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)
oModel:SetVldActivate({|oModel| G480VldAct(oModel)})

oModel:AddFields('H6MMASTER',/*cOwner*/,oStruH6M,,,/*bLoad*/)
oModel:AddGrid('H6NDETAIL','H6MMASTER',oStruH6N, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:AddGrid('GICDETAIL','H6NDETAIL',oStruGIC, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:AddGrid('G57DETAIL','H6NDETAIL',oStruG57, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)
oModel:AddGrid('GZTDETAIL','H6NDETAIL',oStruGZT, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/)

oModel:SetRelation('H6NDETAIL', {{'H6N_FILIAL', 'xFilial("H6N")'}, {'H6N_CODH6M', 'H6M_CODIGO'}}, H6N->(IndexKey(1)))
oModel:SetRelation('GICDETAIL', {{'GIC_FILIAL', 'xFilial("GIC")'}, {'GIC_COLAB' , 'H6N_COLAB'}, {'GIC_AGENCI' , 'H6M_AGENCI'}, {'GIC_DTVEND' , 'H6M_DATACX'}} , RetIndexKey("GIC",10))  //GIC->(IndexKey(10)))
oModel:SetRelation('G57DETAIL', {{'G57_FILIAL', 'xFilial("G57")'}, {'G57_EMISSO', 'H6N_COLAB'}, {'G57_AGENCI' , 'H6M_AGENCI'}, {'G57_EMISSA' , 'H6M_DATACX'}} , RetIndexKey("G57",05))  //G57->(IndexKey(5)))
oModel:SetRelation('GZTDETAIL', {{'GZT_FILIAL', 'xFilial("GZT")'}, {'GZT_COLAB' , 'H6N_COLAB'}, {'GZT_AGENCI' , 'H6M_AGENCI'}, {'GZT_DTVEND' , 'H6M_DATACX'}} , RetIndexKey("GZT",03))  //GZT->(IndexKey(3)))

oModel:AddCalc('TOTCAIXA', 'H6MMASTER', 'H6NDETAIL', 'H6N_RECBIL', 'TOT_RECBIL', 'SUM', { || .T.},, STR0006) // "Tot. Rec. Bilhetes"
oModel:AddCalc('TOTCAIXA', 'H6MMASTER', 'H6NDETAIL', 'H6N_CANBIL', 'TOT_CANBIL', 'SUM', { || .T.},, STR0007) // "Tot. Canc. Bilhetes"
oModel:AddCalc('TOTCAIXA', 'H6MMASTER', 'H6NDETAIL', 'H6N_DEVBIL', 'TOT_DEVBIL', 'SUM', { || .T.},, STR0008) // "Tot. Dev. Bilhetes"
oModel:AddCalc('TOTCAIXA', 'H6MMASTER', 'H6NDETAIL', 'H6N_RECTAX', 'TOT_RECTAX', 'SUM', { || .T.},, STR0009) // "Tot. Rec. Taxas"
oModel:AddCalc('TOTCAIXA', 'H6MMASTER', 'H6NDETAIL', 'H6N_RECADC', 'TOT_RECADC', 'SUM', { || .T.},, STR0010) // "Tot. Rec. Adic."
oModel:AddCalc('TOTCAIXA', 'H6MMASTER', 'H6NDETAIL', 'H6N_TOTLIQ', 'TOT_TOTLIQ', 'SUM', { || .T.},, STR0011) // "Total Liquído"

oModel:GetModel('H6NDETAIL'):SetOptional(.T.)
oModel:GetModel('GICDETAIL'):SetOptional(.T.)
oModel:GetModel('G57DETAIL'):SetOptional(.T.)
oModel:GetModel('GZTDETAIL'):SetOptional(.T.)

oModel:GetModel("GICDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("G57DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("GZTDETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("GICDETAIL"):SetOnlyView(.T.)
oModel:GetModel("G57DETAIL"):SetOnlyView(.T.)
oModel:GetModel("GZTDETAIL"):SetOnlyView(.T.)

oModel:SetDescription(STR0001) // "Caixa do Colaborador"

oModel:GetModel('H6MMASTER'):SetDescription(STR0012) // "Dados do Caixa"

oModel:GetModel('GICDETAIL'):SetMaxLine(999999)

oModel:SetOnDemand(.T.)

oModel:SetCommit(bCommit)
		
Return oModel

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author flavio.martins
@since 09/11/2022
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl, cField, uVal)

If cField == 'H6N_STATUS'

    Do Case
        Case uVal == '1'
            oMdl:LoadValue('LEGENDA', 'BR_BRANCO')
        Case uVal == '2'
            oMdl:LoadValue('LEGENDA', 'BR_AZUL')
        Case uVal == '3'
            oMdl:LoadValue('LEGENDA', 'BR_AMARELO')
            oMdl:LoadValue('H6N_VLPEND', oMdl:GetValue('H6N_TOTLIQ') - oMdl:GetValue('H6N_TOTCAR'))
    EndCase        

Endif

Return uVal

/*/{Protheus.doc} FieldValid
@type Static Function
@author flavio.martins
@since 25/11/2022
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

If cField == 'H6N_VLPEND'

    If cNewValue < 0 
       lRet 	:= .F.
	   cMsgErro := STR0031 // "O valor pendente de acerto não pode ser negativo"
	   cMsgSol  := STR0032 // "Altere para um valor válido" 
    Endif

Endif
	
If !lRet
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"FieldInit",cMsgErro,cMsgSol,cNewValue) 
Endif
	
Return lRet

/*/{Protheus.doc} SetIniFld()
(long_description)
@type  Static Function
@author flavio.martins
@since 10/11/2022
@version 1.0@param , param_type, param_descr
@return cValor
@example
(examples)
@see (links_or_references)
/*/
Static Function SetIniFld(oModel)
Local cValor := ''

Do Case
    Case H6N->H6N_STATUS == '1'
        cValor := 'BR_BRANCO'
    Case H6N->H6N_STATUS == '2'
        cValor := 'BR_AZUL'
    Case H6N->H6N_STATUS == '3'
        cValor := 'BR_AMARELO'
EndCase        

Return cValor

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 07/11/2022
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
Local cFieldsGIC := 'GIC_CODIGO|GIC_BILHET|GIC_TIPO|GIC_STATUS|GIC_DTVEND|GIC_VALTOT|GIC_CHVBPE|GIC_LINHA|GIC_NLINHA|GIC_LOCORI|GIC_NLOCOR|GIC_LOCDES|GIC_NLOCDE'
Local aFieldsGIC := StrToKarr(cFieldsGIC, "|")
Local cFieldsG57 := 'G57_CODIGO|G57_TIPO|G57_DOCDES|G57_SERIE|G57_SUBSER|G57_NUMCOM|G57_EMISSA|G57_VALOR|'
Local aFieldsG57 := StrToKarr(cFieldsG57, "|")
Local cFieldsGZT := 'GZT_CODIGO|GZT_CODGZC|GZT_DESCTP|GZT_DTVEND|GZT_VALOR|GZT_NDOCTO|GZT_CODGIC'
Local aFieldsGZT := StrToKarr(cFieldsGZT, "|")
Local oStruH6M	 := FwFormStruct(2, 'H6M', {|x| !AllTrim(x) $ 'H6M_USUABR|H6M_DTABER|H6M_HRABER|H6M_USUFEC|H6M_DTFECH|H6M_HRFECH|'})
Local oStruH6N	 := FwFormStruct(2, 'H6N', {|x| !AllTrim(x) $ 'H6N_CODH6M|'})
Local oStruGIC	 := FwFormStruct(2, 'GIC', {|x| AllTrim(x) $ cFieldsGIC})
Local oStruG57	 := FwFormStruct(2, 'G57', {|x| AllTrim(x) $ cFieldsG57})
Local oStruGZT	 := FwFormStruct(2, 'GZT', {|x| AllTrim(x) $ cFieldsGZT})

oStruH6N:AddField("LEGENDA","01","","",{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) 

oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Caixa do Colaborador"

oView:AddField('VIEW_H6M', oStruH6M,'H6MMASTER')
oView:AddGrid('VIEW_H6N', oStruH6N,'H6NDETAIL')
oView:AddGrid('VIEW_GIC', oStruGIC,'GICDETAIL')
oView:AddGrid('VIEW_G57', oStruG57,'G57DETAIL')
oView:AddGrid('VIEW_GZT', oStruGZT,'GZTDETAIL')

oStruH6M:AddGroup('GRP001', STR0012,'', 2) // "Dados do Caixa"
oStruH6M:AddGroup('GRP002', STR0028,'', 2) // "Totais do Caixa"

oStruH6M:SetProperty('H6M_CODIGO', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH6M:SetProperty('H6M_AGENCI', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH6M:SetProperty('H6M_DSCAGE', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH6M:SetProperty('H6M_DATACX', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH6M:SetProperty('H6M_NUMFCH', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH6M:SetProperty('H6M_STATUS', MVC_VIEW_GROUP_NUMBER, 'GRP001')
oStruH6M:SetProperty('H6M_RECBIL', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH6M:SetProperty('H6M_CANBIL', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH6M:SetProperty('H6M_DEVBIL', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH6M:SetProperty('H6M_RECTAX', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH6M:SetProperty('H6M_RECADC', MVC_VIEW_GROUP_NUMBER, 'GRP002')
oStruH6M:SetProperty('H6M_TOTLIQ', MVC_VIEW_GROUP_NUMBER, 'GRP002')

oView:CreateHorizontalBox('HEADER', 30)
oView:CreateHorizontalBox('GRID_COL', 25)
oView:CreateHorizontalBox('BOTTOM', 45)

oView:CreateFolder("FOLDER", "BOTTOM")
oView:AddSheet("FOLDER", "ABA01", STR0013) // "Bilhetes"
oView:AddSheet("FOLDER", "ABA02", STR0014) // "Taxas"
oView:AddSheet("FOLDER", "ABA03", STR0015) // "Receitas e Despesas Adicionais"

oView:CreateVerticalBox("BILHETES"  ,100, , , 'FOLDER', 'ABA01')
oView:CreateVerticalBox("TAXAS"     ,100, , , 'FOLDER', 'ABA02')
oView:CreateVerticalBox("RECDESP"   ,100, , , 'FOLDER', 'ABA03')

oView:SetOwnerView('VIEW_H6M', 'HEADER')
oView:SetOwnerView('VIEW_H6N', 'GRID_COL')
oView:SetOwnerView('VIEW_GIC', 'BILHETES')
oView:SetOwnerView('VIEW_G57', 'TAXAS')
oView:SetOwnerView('VIEW_GZT', 'RECDESP')

oView:EnableTitleView("VIEW_H6N", STR0016) // "Colaboradores"

//oView:AddUserButton( "Impressão Caixa Colaborador", "", {|oModel| GTP480REL(oModel)},,,{MODEL_OPERATION_VIEW} )   //"Impressão Caixa Colaborador"

SetOrdStru(oStruGIC, aFieldsGIC)
SetOrdStru(oStruG57, aFieldsG57)
SetOrdStru(oStruGZT, aFieldsGZT)

oStruH6N:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
oStruH6N:SetProperty('H6N_STATUS', MVC_VIEW_CANCHANGE, .T.)
oStruH6N:SetProperty('H6N_VLPEND', MVC_VIEW_CANCHANGE, .T.)

oView:SetContinuosForm(.t.)

Return oView

/*/{Protheus.doc} SetOrdStru
(long_description)
@type  Static Function
@author flavio.martins
@since 08/11/2022
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

/*/{Protheus.doc} G480VldAct
(long_description)
@type  Static Function
@author flavio.martins
@since 07/11/2022
@version 1.0
@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G480VldAct(oModel)
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If !G480VldDic(@cMsgErro)
    lRet     := .F.
    cMsgSol  :=  STR0017 // "Atualize o dicionário para utilizar esta rotina"
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"GA480PosVld", cMsgErro, cMsgSol) 
    Return .F.
Endif

Return lRet

/*/{Protheus.doc} GTP480Menu
(long_description)
@type  Static Function
@author flavio.martins
@since 09/11/2022
@version 1.0
@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTP480Menu(nOpc)
Local lRet      := .T.
Local oModel    := Nil
Local cAgencia  := ''
Local dDataCx   := ''
Local nOperation := 0

If nOpc == 1
    
    If Pergunte("GTPA480",.T.) 

        If Empty(MV_PAR01)
            FwAlertWarning(STR0018, STR0019) // "Informe a agência para a abertura do caixa", "Atenção"
            Return
        Endif

        If Empty(MV_PAR02)
            FwAlertWarning(STR0020, STR0019) // "Informe a data para a abertura do caixa", "Atenção"
            Return
        Endif

        cAgencia := MV_PAR01
        dDataCx  := MV_PAR02

        If !ValidUserAg(Nil, , cAgencia)
            Return
        Endif 

        GI6->(DbSetOrder(1))

        If GI6->(dbSeek(xFilial('GI6')+cAgencia))
            
            If GI6->GI6_CTRCXA != '1'
                FwAlertWarning(STR0030, STR0019) // "Controle de caixa desabilitado para a agência selecionada", "Atenção"
                Return
            Endif

        Endif
               
    Else
        lRet := .F.
    Endif

ElseIf nOpc == 2

    cAgencia := H6M->H6M_AGENCI
    dDataCx  := H6M->H6M_DATACX

ElseIf nOpc == 3

    If H6M->H6M_STATUS == '2'
        lRet := .F.
        FwAlertWarning(STR0021, STR0022) // "Caixa está fechado e não pode ser excluído", "Aviso"
    Else
        FwExecView(STR0023, "VIEWDEF.GTPA480", MODEL_OPERATION_DELETE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, ,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel) // "Exclusão"
        Return
    Endif

Endif

If lRet

    oModel := FwLoadModel('GTPA480')

    dbSelectArea('H6M')
    H6M->(dbSetOrder(2))

    If H6M->(dbSeek(xFilial('H6M')+cAgencia+DtoS(dDataCx)))

        If nOpc == 1
            FwAlertWarning(STR0029, STR0019) // 'Caixa já aberto para esta agência e data', 'Atenção'
            Return
        Endif

        If H6M->H6M_STATUS == '1'
            nOperation := MODEL_OPERATION_UPDATE
        Else
            nOperation := MODEL_OPERATION_VIEW
        Endif
    Else
        nOperation := MODEL_OPERATION_INSERT
    Endif

    oModel:SetOperation(nOperation)
 
    If nOperation != MODEL_OPERATION_VIEW
        FwMsgRun(,{|| LoadDados(oModel, cAgencia, dDataCx)}, STR0024, STR0025) // "Aguarde", "Buscando dados do caixa..."
    Else
        oModel:Activate()
    Endif

    If oModel:IsActive() 
        FwExecView(STR0026, "VIEWDEF.GTPA480", oModel:GetOperation(), /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/, ,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel) // ""Abertura""
    Endif

Endif

Return

/*/{Protheus.doc} LoadDados
(long_description)
@type  Static Function
@author flavio.martins
@since 09/11/2022
@version 1.0
@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadDados(oModel, cAgencia, dDataCx)
Local cAliasTmp := GetNextAlias()
Local oMdlH6N   := oModel:GetModel('H6NDETAIL')

oModel:Activate()

If oModel:GetOperation() == MODEL_OPERATION_INSERT
    oModel:GetModel("H6MMASTER"):SetValue('H6M_AGENCI', cAgencia)
    oModel:GetModel("H6MMASTER"):SetValue('H6M_DATACX', dDataCx)
    oModel:GetModel("H6MMASTER"):SetValue('H6M_USUABR', __cUserId)
    oModel:GetModel("H6MMASTER"):SetValue('H6M_DTABER', dDatabase)
    oModel:GetModel("H6MMASTER"):SetValue('H6M_HRABER', Substr(Time(), 1, 2) + Substr(Time(), 4, 2))
Endif

BeginSql Alias cAliasTmp

    SELECT 'REC_BILHETE'  TIPO,
           GIC_COLAB  COLAB,
           SUM(GIC.GIC_VALTOT)  TOTAL
    FROM %Table:GIC%  GIC
    WHERE GIC.GIC_FILIAL = %xFilial:GIC%
      AND GIC.GIC_AGENCI = %Exp:cAgencia%
      AND GIC.GIC_DTVEND = %Exp:DtoS(dDataCx)%
      AND NOT (GIC.GIC_STATUS IN ('C','D')  )
      AND GIC.GIC_COLAB <> ''
      AND GIC.%NotDel%
    GROUP BY GIC.GIC_COLAB
    UNION
    SELECT 'VENDAS_CARTAO'  TIPO,
           GIC_COLAB  COLAB,
           SUM(GZP.GZP_VALOR)  TOTAL
    FROM %Table:GIC%  GIC
    INNER JOIN %Table:GZP% GZP ON 
        GZP.GZP_FILIAL = %xFilial:GZP%
        AND GZP.GZP_CODIGO = GIC.GIC_CODIGO
        AND GZP.GZP_CODBIL = GIC.GIC_BILHET
        AND GZP.%NotDel%
    WHERE GIC.GIC_FILIAL = %xFilial:GIC%
      AND GIC.GIC_AGENCI = %Exp:cAgencia%
      AND GIC.GIC_DTVEND = %Exp:DtoS(dDataCx)%
      AND NOT (GIC.GIC_STATUS IN ('C','D')  )
      AND GIC.GIC_COLAB <> ''
      AND GIC.%NotDel%
    GROUP BY GIC.GIC_COLAB
    UNION
    SELECT 'CANC_BILHETE'  TIPO,
           GIC_COLAB  COLAB,
           SUM(GIC.GIC_VALTOT)  TOTAL
    FROM %Table:GIC%  GIC
    WHERE GIC.GIC_FILIAL = %xFilial:GIC%
      AND GIC.GIC_AGENCI = %Exp:cAgencia%
      AND GIC.GIC_DTVEND = %Exp:DtoS(dDataCx)%
      AND GIC.GIC_STATUS = 'C'
      AND GIC.GIC_COLAB <> ''
      AND GIC.%NotDel%
    GROUP BY GIC.GIC_COLAB
    UNION
    SELECT 'DEV_BILHETE'  TIPO,
           GIC_COLAB  COLAB,
           SUM(GIC.GIC_VALTOT)  TOTAL
    FROM %Table:GIC%  GIC
    WHERE GIC.GIC_FILIAL = %xFilial:GIC%
      AND GIC.GIC_AGENCI = %Exp:cAgencia%
      AND GIC.GIC_DTVEND = %Exp:DtoS(dDataCx)%
      AND GIC.GIC_STATUS = 'D'
      AND GIC.GIC_COLAB <> ''
      AND GIC.%NotDel%
    GROUP BY GIC.GIC_COLAB
    UNION
    SELECT 'REC_ADICIONAIS'  TIPO,
           GZT_COLAB  COLAB,
           SUM(GZT_VALOR)  TOTAL
    FROM %Table:GZT% GZT
    WHERE GZT_FILIAL = %xFilial:GZT%
      AND GZT_AGENCI = %Exp:cAgencia%
      AND GZT_DTVEND = %Exp:DtoS(dDataCx)%
      AND GZT_COLAB <> ''
      AND GZT.%NotDel%
    GROUP BY GZT_COLAB
    UNION
    SELECT 'REC_TAXAS'  TIPO,
           G57_EMISSO  COLAB,
           SUM(G57.G57_VALOR)  TOTAL
    FROM %Table:G57% G57
    WHERE G57_FILIAL = %xFilial:G57%
      AND G57_AGENCI = %Exp:cAgencia%
      AND G57_EMISSA = %Exp:DtoS(dDataCx)%
      AND G57_EMISSO <> ''
      AND G57.%NotDel%
    GROUP BY G57_EMISSO

EndSql

While (cAliasTmp)->(!Eof())

    If !(oMdlH6N:SeekLine({{"H6N_COLAB",(cAliasTmp)->COLAB}},,.T.))

        If !Empty(oMdlH6N:GetValue('H6N_COLAB'))
            oMdlH6N:AddLine()
        Endif

    Endif
    
    If oMdlH6N:GetValue('H6N_STATUS') == '1'

        oMdlH6N:SetValue('H6N_COLAB', (cAliasTmp)->COLAB)
        
        Do Case
            Case AllTrim((cAliasTmp)->TIPO) == 'REC_BILHETE'
                oMdlH6N:SetValue('H6N_RECBIL', (cAliasTmp)->TOTAL)
            Case AllTrim((cAliasTmp)->TIPO) == 'CANC_BILHETE'
                oMdlH6N:SetValue('H6N_CANBIL', (cAliasTmp)->TOTAL)
            Case AllTrim((cAliasTmp)->TIPO) == 'DEV_BILHETE'
                oMdlH6N:SetValue('H6N_DEVBIL', (cAliasTmp)->TOTAL)
            Case AllTrim((cAliasTmp)->TIPO) == 'REC_TAXAS'
                oMdlH6N:SetValue('H6N_RECTAX', (cAliasTmp)->TOTAL)
            Case AllTrim((cAliasTmp)->TIPO) == 'REC_ADICIONAIS'
                oMdlH6N:SetValue('H6N_RECADC', (cAliasTmp)->TOTAL)
            Case AllTrim((cAliasTmp)->TIPO) == 'VENDAS_CARTAO'
                oMdlH6N:SetValue('H6N_TOTCAR', (cAliasTmp)->TOTAL)
        EndCase

        oMdlH6N:SetValue('H6N_TOTLIQ', (oMdlH6N:GetValue('H6N_RECBIL') +;
                                    oMdlH6N:GetValue('H6N_RECTAX')+;
                                    oMdlH6N:GetValue('H6N_RECADC')-;
                                    oMdlH6N:GetValue('H6N_CANBIL')-;
                                    oMdlH6N:GetValue('H6N_DEVBIL')))

        If Empty(oMdlH6N:GetValue('H6N_SEQ'))
            oMdlH6N:SetValue('H6N_SEQ', StrZero(oMdlH6N:Length(),3))
        Endif

    Endif
    
    (cAliasTmp)->(dbSkip())

EndDo

(cAliasTmp)->(dbCloseArea())

oModel:LoadValue('H6MMASTER', 'H6M_RECBIL', oModel:GetValue('TOTCAIXA', 'TOT_RECBIL'))
oModel:LoadValue('H6MMASTER', 'H6M_CANBIL', oModel:GetValue('TOTCAIXA', 'TOT_CANBIL'))
oModel:LoadValue('H6MMASTER', 'H6M_DEVBIL', oModel:GetValue('TOTCAIXA', 'TOT_DEVBIL'))
oModel:LoadValue('H6MMASTER', 'H6M_RECTAX', oModel:GetValue('TOTCAIXA', 'TOT_RECTAX'))
oModel:LoadValue('H6MMASTER', 'H6M_RECADC', oModel:GetValue('TOTCAIXA', 'TOT_RECADC'))
oModel:LoadValue('H6MMASTER', 'H6M_TOTLIQ', oModel:GetValue('TOTCAIXA', 'TOT_TOTLIQ'))

If oModel:VldData()
    oModel:CommitData()
    oModel:DeActivate()
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:GetModel('H6NDETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('H6NDETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('GICDETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('GICDETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('GICDETAIL'):SetNoUpdateLine(.T.)
    oModel:GetModel('G57DETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('G57DETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('G57DETAIL'):SetNoUpdateLine(.T.)
    oModel:GetModel('GZTDETAIL'):SetNoDeleteLine(.T.)
    oModel:GetModel('GZTDETAIL'):SetNoInsertLine(.T.)
    oModel:GetModel('GZTDETAIL'):SetNoUpdateLine(.T.)

    oModel:Activate()
Endif

Return

/*/{Protheus.doc} G480VldDic
(long_description)
@type  Static Function
@author flavio.martins
@since 07/11/2022
@version 1.0
@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function G480VldDic(cMsgErro)
Local lRet          := .T.
Local aTables       := {'H6M','H6N'}
Local aFields       := {}
Local nX            := 0
Default cMsgErro    := ''

aFields := {'GI6_CTRCXA','H6M_CODIGO','H6M_AGENCI','H6M_DATACX','H6M_STATUS','H6M_NUMFCH',;
            'H6M_RECBIL','H6M_CANBIL','H6M_DEVBIL','H6M_RECTAX','H6M_RECADC','H6M_TOTLIQ',;
            'H6M_USUABR','H6M_DTABER','H6M_HRABER','H6M_USUFEC','H6M_DTFECH','H6M_HRFECH',;
            'H6N_FILIAL','H6N_STATUS','H6N_CODH6M','H6N_SEQ   ','H6N_COLAB ','H6N_RECBIL',;
            'H6N_CANBIL','H6N_DEVBIL','H6N_RECTAX','H6N_RECADC','H6N_TOTLIQ','H6N_TOTCAR',;
            'H6N_VLPEND','H6N_CONFER','H6N_USUCON','H6N_DTCONF','H6N_CODGQP'}

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
	        cMsgErro := I18n(STR0027, {aFields[nX]}) // "Campo #1 não se encontra no dicionário"
	        Exit
	    Endif
	Next
EndIf

Return lRet

/*/{Protheus.doc} G480Commit
(long_description)
@type  Static Function
@author flavio.martins
@since 30/11/2022
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function G480Commit(oModel)
Local lRet      := .T. 
Local nX        := 0
Local aDelVale  := {}
Local oMdlVale  := Nil
Local cMsgErro  := ''
Local cMsgSol   := ''

For nX := 1 To oModel:GetModel('H6NDETAIL'):Length()
    If !Empty(oModel:GetModel('H6NDETAIL'):GetValue('H6N_CODGQP', nX))
        Aadd(aDelVale, oModel:GetModel('H6NDETAIL'):GetValue('H6N_CODGQP', nX))
    Endif
Next

Begin Transaction

FwFormCommit(oModel)

If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. Len(aDelVale) > 0

    dbSelectArea('GQP')
    GQP->(dbSetOrder(1))

    oMdlVale := FwLoadModel("GTPA110")

    For nX := 1 To Len(aDelVale)

        If GQP->(dbSeek(xFilial('GQP')+aDelVale[nX]))
            oMdlVale:SetOperation(MODEL_OPERATION_DELETE)
            oMdlVale:Activate()

            If oMdlVale:VldData()
                oMdlVale:CommitData()
            Else
                lRet := .F.
                DisarmTransaction()
                cMsgErro := "Erro na exclusão dos vales vinculados ao caixa"
                cMsgSol  := "Verifique o status dos vales antes de excluir o caixa"
                oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G480Commit", cMsgErro, cMsgSol) 
                JurShowErro(oMdlVale:GetErrorMessage())
            Endif

        Endif

    Next

Endif

End Transaction

Return lRet


/*/{Protheus.doc} RetIndexKey
Fuunção que checa se existe índice cadastrado
@type  Static Function
@author Fernando Radu Muscalu
@since 03/05/2023
@version 1.0@param , param_type, param_descr
@return lógico, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function RetIndexKey(cAlias,nInd)

    Local cIndexKey := ""

    Default cAlias  := ""

    cIndexKey := (cAlias)->(IndexKey(nInd))

    If ( Empty(cIndexKey) )
        cIndexKey := (cAlias)->(IndexKey(1))        
    EndIf

Return(cIndexKey)

/*/{Protheus.doc} GTP480REL
Função que realiza a impressão do Relatório de Caixa do Colaborador em Html.
@type  Static Function
@author Eduardo Pereira
@since 03/05/2023
@version 12.1.2310
/*/

Function GTP480REL()

//Local cData       := ""
Local cFile       := ""
Local cHTMLDt     := ""
Local cPathhmtl   := Alltrim(SuperGetMv( "MV_DIRDOC", .F., "\DIRDOC\" ) )
Local cHtmlCol    := Alltrim(SuperGetMv( "MV_DIRHTML", .F., "\HTML\" ) )
Local cArqhtml    := ""
Local cHTMLSrc    := ""
Local cPath       := ""
Local lRet        := .T.
Local oHTMLBody   := Nil
Local cQry        := ""
Local oQryA       := Nil
Local cAliasA     := ""
Local aCodH6M     := {}
Local nX          := 0
Local nY          := 0
Local nZ          := 0
Local cNomCol     := ""

//cData += cValToChar(Day(dDataBase))
//cData += " de "
//cData += MesExtenso(dDataBase)
//cData += " de "
//cData += cValToChar(Year(dDataBase))

cQry := " SELECT    "+;
        "   H6M_CODIGO, H6N_COLAB, H6M_DATACX, H6M_AGENCI, H6M_STATUS, H6M_NUMFCH, H6N_RECBIL, H6N_CANBIL, H6N_DEVBIL, H6N_RECTAX, H6N_RECADC, H6N_TOTLIQ "+;
        " FROM ? H6M           "+;
        " INNER JOIN ? H6N     "+;
        "   ON H6N_CODH6M = H6M_CODIGO AND H6N.D_E_L_E_T_ = ' '   "+;
        " WHERE H6M.D_E_L_E_T_ = ' '    "+;
        "   AND H6M_FILIAL = ?          "+;
	    "   AND H6M_CODIGO = ?          "
cQry := ChangeQuery(cQry)
oQryA := FWPreparedStatement():New(cQry)
oQryA:SetUnsafe(1, RetSqlName( "H6M" ))
oQryA:SetUnsafe(2, RetSqlName( "H6N" ))
oQryA:SetString(3, xFilial("H6M"))
oQryA:SetString(4, H6M->H6M_CODIGO)
cQry 	:= oQryA:GetFixQuery()
cAliasA	:= MPSysOpenQuery( cQry )

While (cAliasA)->( !Eof() )
    If (nPosN := ASCan(aCodH6M, {|x|, Alltrim(x[01]) == Alltrim((cAliasA)->H6M_CODIGO)})) > 0   // Codigo Caixa ja considerado
        aAdd(aCodH6M[nPosN,02,01], { (cAliasA)->H6N_COLAB, {{ (cAliasA)->H6M_DATACX, (cAliasA)->H6M_AGENCI, (cAliasA)->H6M_STATUS, (cAliasA)->H6M_NUMFCH, (cAliasA)->H6N_RECBIL, (cAliasA)->H6N_CANBIL, (cAliasA)->H6N_DEVBIL, (cAliasA)->H6N_RECTAX, (cAliasA)->H6N_RECADC, (cAliasA)->H6N_TOTLIQ}} })
    Else
        aAdd(aCodH6M, { (cAliasA)->H6M_CODIGO, {{{ (cAliasA)->H6N_COLAB, {{ (cAliasA)->H6M_DATACX, (cAliasA)->H6M_AGENCI, (cAliasA)->H6M_STATUS, (cAliasA)->H6M_NUMFCH, (cAliasA)->H6N_RECBIL, (cAliasA)->H6N_CANBIL, (cAliasA)->H6N_DEVBIL, (cAliasA)->H6N_RECTAX, (cAliasA)->H6N_RECADC, (cAliasA)->H6N_TOTLIQ}} }}} })
    EndIf
    (cAliasA)->( dbSkip() )
EndDo
(cAliasA)->( dbCloseArea() )

If FWIsInCallStack('GTPA480')
    cArqhtml   := Alltrim(SuperGetMv( "MV_MODCOLA", .F., "CaixaColaborador.html" )  )
    For nX := 1 to Len(aCodH6M)
        cHTMLSrc   := cPathhmtl + cHtmlCol + cArqhtml
        If File(cHTMLSrc)
            For nY := 1 To Len(aCodH6M[nX,02,01])
                For nZ := 1 to Len(aCodH6M[nX,02,01,nY,02])
                    oHTMLBody:= TWFHTML():New(cHTMLSrc)
                    //Dados Empresa e Data
                    oHTMLBody:ValByName('empresa'       , Alltrim(SM0->M0_FILIAL))  // Alltrim(Posicione("SM0", 1, xFilial("SM0") + cEmpAnt + cFilAnt, "M0_FILIAL"))) 
                    oHTMLBody:ValByName('data'		    , DtoC(dDataBase))
                    //Dados Colaborador
                    cNomCol := Alltrim(Posicione("GYG", 1, xFilial("GYG") + aCodH6M[nX,02,01,nY,01], "GYG_NOME"))
                    oHTMLBody:ValByName('colaborador'   , cNomCol)
                    //Dados Caixa
                    oHTMLBody:ValByName('codagencia'	, aCodH6M[nX,02,01,nY,02,nZ,02])
                    oHTMLBody:ValByName('nomeagencia'	, "AGREMA TESTE 01")
                    oHTMLBody:ValByName('datacaixa'	    , DtoC(StoD(aCodH6M[nX,02,01,nY,02,nZ,01])))
                    oHTMLBody:ValByName('status'	    , aCodH6M[nX,02,01,nY,02,nZ,03])
                    oHTMLBody:ValByName('fchremessa'	, aCodH6M[nX,02,01,nY,02,nZ,04])
                    //Totais da Caixa
                    oHTMLBody:ValByName('recbilhete'	, Alltrim(Transform(aCodH6M[nX,02,01,nY,02,nZ,05],"@E 99,999,999.99")))
                    oHTMLBody:ValByName('cancbilhete'	, Alltrim(Transform(aCodH6M[nX,02,01,nY,02,nZ,06],"@E 99,999,999.99")))
                    oHTMLBody:ValByName('devbilhete'	, Alltrim(Transform(aCodH6M[nX,02,01,nY,02,nZ,07],"@E 99,999,999.99")))
                    oHTMLBody:ValByName('rectaxas'		, Alltrim(Transform(aCodH6M[nX,02,01,nY,02,nZ,08],"@E 99,999,999.99")))
                    oHTMLBody:ValByName('recadic'	    , Alltrim(Transform(aCodH6M[nX,02,01,nY,02,nZ,09],"@E 99,999,999.99")))
                    oHTMLBody:ValByName('totliq'	    , Alltrim(Transform(aCodH6M[nX,02,01,nY,02,nZ,10],"@E 99,999,999.99")))
                Next nZ
                If nY == 1  // Entrará apenas na primeira vez se houver mais de um colaborador
                    cPath := cGetFile( "Diretório" + "|*.*" ,"Procurar" ,0, ,.T. ,GETF_LOCALHARD+GETF_RETDIRECTORY ,.T.,)
                EndIf
                cFile := "CAIXA DO COLABORADOR_" + FWTimeStamp(1) + ".htm"
                cHTMLDt := cPath + cValtoChar(nY) + cFile
                oHTMLBody:SaveFile(cHTMLDt)
                lRet := !Empty( MtHTML2Str(cHTMLDt) )
                ShellExecute("open",cHTMLDt,"","",5)
            Next nY
        Else
            MsgStop(STR0034,STR0035)   // "Arquivo não encontrado" - "Verifique os parametros MV_DIRDOC, MV_DIRHTML e MV_MODCOLA"
            lRet := .F.
        EndIf
    Next nX
EndIf        

Return lRet
