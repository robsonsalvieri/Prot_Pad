#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA901.CH'

Static c901BCodigo 
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA901()
Cadastro de Lista de Passageiros
@sample		GTPA901()
@return		oBrowse  Retorna o Cadastro de Lista de Passageiros
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA901()

Local oBrowse	 := Nil
Local cCod       := ""
Local cAliasFilt := ""
Local nCont      := 0

Local aFiltro    := {}
Local aRotina	 := {}
Local aNewFlds   := {}
Local aNewGqb    := {}

If ( !FindFunction("GTPHASACCESS") .Or.; 
	( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

    cAliasFilt  := GetNextAlias()
    aRotina     := MenuDef()
    aNewFlds    := {'GQ8_DESCRI', 'GQ8_OBSERV','GQ8_CODGY0','GQ8_CODGYD'}
    aNewGqb     := {'GQB_FILIAL', 'GQB_CODIGO','GQB_ITEM','GQB_NOME','GQB_CPF','GQB_CEP',;
                'GQB_ENDERE','GQB_COMPLE','GQB_BAIRRO','GQB_MUNICI','GQB_ESTADO'}

    If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
        aNewFlds    := {'GQ8_DESCRI', 'GQ8_OBSERV','GQ8_CODGY0','GQ8_CODGYD','GQ8_CODG6R'}
    Endif

    If !(GTPxVldDic('GQ8', aNewFlds, .T., .T.)) .AND. !(GTPxVldDic('GQB', aNewGqb, .T., .T.))
    
        FwAlertHelp(STR0008, STR0009,)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"

    Else
        
        oBrowse:=FWMBrowse():New()
        oBrowse:SetAlias("GQ8")
        oBrowse:SetDescription(STR0001)		// "Lista de Passageiros"

        If (FwIsInCallStack('GTPA900'))

           BeginSQL Alias cAliasFilt
               SELECT GQ8.GQ8_CODIGO 
               FROM %Table:GQ8% GQ8
                INNER JOIN %Table:GY0% GY0
                    ON GY0.GY0_FILIAL = %XFilial:GY0%
                    AND GY0.GY0_NUMERO = GQ8.GQ8_CODGY0
                    AND GY0.GY0_STATUS = '2'
                    AND GY0.%NotDel%
                WHERE GQ8.GQ8_FILIAL = %XFilial:GQ8%
                    AND GQ8.%NotDel%
            EndSQL

                
            IF (cAliasFilt)->(!EOF())
            
                While (cAliasFilt)->(!Eof())
            
                    cCod += (cAliasFilt)->GQ8_CODIGO + '|'
                    If Len(cCod) >= 1024
                        AADD(aFiltro, cCod)	
                        cCod := ""		
                    EndIf
                    (cAliasFilt)->(dbSkip())
                End
                If LEN(aFiltro) == 0 .AND. !(EMPTY(cCod))
                    AADD(aFiltro, cCod)
                EndIf 
                For nCont := 1 To LEN(aFiltro)
                    oBrowse:SetFilterDefault ( 'GQ8_CODIGO $ "' + aFiltro[nCont] + '"')
                Next nCont
            
            Endif


            If Select(cAliasFilt) > 0
               (cAliasFilt)->(dbCloseArea())
            Endif

        Endif

        oBrowse:Activate()


    Endif

EndIf

Return()



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
@sample		MenuDef()
@return		aRotina - Array de opções do menu
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002     ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 // #Pesquisar
ADD OPTION aRotina TITLE STR0003     ACTION 'VIEWDEF.GTPA901' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina TITLE STR0004     ACTION 'VIEWDEF.GTPA901' OPERATION 3 ACCESS 0 // Incluir
ADD OPTION aRotina TITLE STR0005     ACTION 'VIEWDEF.GTPA901' OPERATION 4 ACCESS 0 // Alterar
ADD OPTION aRotina TITLE STR0006     ACTION 'VIEWDEF.GTPA901' OPERATION 5 ACCESS 0 // Excluir
ADD OPTION aRotina TITLE STR0010     ACTION 'GTPR901'         OPERATION 2 ACCESS 0 // 'Lista Passageiro'

Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel - Retorna o Modelo de dados 
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= nil
Local oStruGQ8	:= nil	//Lista de passageiros-cabeçalho
Local oStruGQB	:= nil	//Lista de passageiros-Itens
Local aNewFlds  := {'GQ8_DESCRI', 'GQ8_OBSERV','GQ8_CODGY0','GQ8_CODGYD'}
Local aNewGqb   := {'GQB_FILIAL', 'GQB_CODIGO','GQB_ITEM','GQB_NOME','GQB_CPF','GQB_CEP',;
                     'GQB_ENDERE','GQB_COMPLE','GQB_BAIRRO','GQB_MUNICI','GQB_ESTADO'}
Local bCommit	:= {|oModel|G901Commit(oModel)}        
Local bPosValid	:= {|oModel|TP901TdOK(oModel)}

If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
    aNewFlds    := {'GQ8_DESCRI', 'GQ8_OBSERV','GQ8_CODGY0','GQ8_CODGYD','GQ8_CODG6R'}
Endif

If !(GTPxVldDic('GQ8', aNewFlds, .T., .T.)) .AND. !(GTPxVldDic('GQB', aNewGqb, .T., .T.))
    FwAlertHelp(STR0008, STR0009,)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"

Else

    oStruGQ8	:= FWFormStruct(1,'GQ8')
    oStruGQB	:= FwFormStruct(1,'GQB')

    oStruGQ8:SetProperty('GQ8_CODGY0', MODEL_FIELD_OBRIGAT, .F.)
    oStruGQ8:SetProperty('GQ8_CODGYD', MODEL_FIELD_OBRIGAT, .F.)
    If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
        oStruGQ8:SetProperty('GQ8_CODG6R', MODEL_FIELD_OBRIGAT, .F.)
    Endif

    oModel := MPFormModel():New('GTPA901', /*bPreValidacao*/, bPosValid /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    oModel:AddFields('GQ8MASTER',/*cOwner*/,oStruGQ8)
    oModel:AddGrid('GQBDETAIL','GQ8MASTER',oStruGQB, /*bLinePre*/, { | oModel | TP901LOK( oModel ) } /*bLinePos*/, /*bPre - Grid Inteiro*/, /*bPos - Grid Inteiro*/, /*bLoad - Carga do modelo manualmente*/)

    oModel:SetRelation( 'GQBDETAIL', { { 'GQB_FILIAL', 'xFilial( "GQ8" )' }, { 'GQB_CODIGO'	, 'GQ8_CODIGO' } } , GQB->(IndexKey(1))) 

    //Não permite repetir incluir o mesmo CPF.
    //oModel:GetModel('GQBDETAIL'):SetUniqueLine({'GQB_CPF'})

    //Não permite GRID (GQBDETAIL) sem dados "Passageiros"
    oModel:GetModel('GQBDETAIL'):SetOptional(.F.)

    oModel:SetDescription(STR0001)				// "Lista de passageiros"
    oModel:GetModel('GQBDETAIL'):SetDescription(STR0001)	// "Passageiros"
    oModel:SetPrimaryKey({"GQ8_FILIAL","GQ8_CODIGO"})

    oModel:SetVldActivate({|oModel| G901VldAct(oModel)})
    
    oModel:SetCommit(bCommit)

EndIf
Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
@sample		ViewDef()
@return		oView - Retorna a View
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef() 
Local oView		:= FWFormView():New()
Local oStruGQ8	:= nil
Local oStruGQB	:= nil
Local aNewFlds   := {'GQ8_DESCRI', 'GQ8_OBSERV','GQ8_CODGY0','GQ8_CODGYD'}
Local aNewGqb    := {'GQB_FILIAL', 'GQB_CODIGO','GQB_ITEM','GQB_NOME','GQB_CPF','GQB_CEP',;
                     'GQB_ENDERE','GQB_COMPLE','GQB_BAIRRO','GQB_MUNICI','GQB_ESTADO'}

If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
    aNewFlds   := {'GQ8_DESCRI', 'GQ8_OBSERV','GQ8_CODGY0','GQ8_CODGYD','GQ8_CODG6R'}
Endif

If !(GTPxVldDic('GQ8', aNewFlds, .T., .T.)) .AND. !(GTPxVldDic('GQB', aNewGqb, .T., .T.))
    FwAlertHelp(STR0008, STR0009,)	// "Dicionário desatualizado", "Atualize o dicionário para utilizar esta rotina"

Else

    oStruGQ8	:= FWFormStruct(2, 'GQ8')
    oStruGQB	:= FWFormStruct(2, 'GQB')

    oStruGQB:RemoveField('GQB_CODIGO')

    If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
        oStruGQ8:SetProperty('GQ8_CODG6R' , MVC_VIEW_LOOKUP, "G6R")
    Endif
    oView:SetModel(oModel)

    oView:AddField('VIEW_GQ8' ,oStruGQ8,'GQ8MASTER')
    oView:AddGRID('VIEW_GQB'  ,oStruGQB,'GQBDETAIL')

    oView:AddIncrementField('VIEW_GQB','GQB_ITEM')

    // Criar um box horizontal para receber algum elemento da view
    oView:CreateHorizontalBox( 'SUPERIOR', 35 )
    oView:CreateHorizontalBox( 'INFERIOR', 65 )

    oView:SetOwnerView('VIEW_GQ8','SUPERIOR')
    oView:SetOwnerView('VIEW_GQB','INFERIOR')

    // Liga a identificacao do componente
    oView:EnableTitleView('VIEW_GQ8',STR0001)	//"Lista de passageiros"
    oView:EnableTitleView('VIEW_GQB',STR0007)	//"Passageiros"
EndIf
Return( oView )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G901VldAct(oModel)
Validação na ativação do modelo
@sample		G901VldAct(oModel)
@return		lRet = Lógico
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function G901VldAct(oModel)
Local lRet      := .T.
Local aNewFlds  := {'GQ8_DESCRI', 'GQ8_OBSERV'}
Local cMsgErro  := ''
Local cMsgSol   := ''

If !(GTPxVldDic('GQ8', aNewFlds, .T., .T.))
    lRet     := .F.
    cMsgErro := STR0008 // "Dicionário desatualizado"
    cMsgSol  := STR0009 // "Atualize o dicionário para utilizar esta rotina"  
    oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"G901VldAct",cMsgErro,cMsgSol,,)
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G901BRFil
Função de retorno da consulta especifica
@sample		G901BRFil
@return		lRet = Lógico
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G901BRFil()
Local cRet :=''

cRet:=	c901BCodigo

Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G901BFil
Montagem da tela customizada de consulta
@sample		G901BFil
@return		lRet = Lógico
@author	GTP
@since		21/07/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function G901BFil()

Local aRetorno 		:= {}
Local cQuery   		:= "" 
Local cValid        := ""         
Local lRet     		:= .F.
Local oLookUp  		:= Nil
Local oMldMaster	:=  FwModelActive()
Local cQryGYD       := ""
Local cCont         := ""

cIdSubMdl 	:= "GQ8MASTER"
cField		:= "GQ8_CODGY0"
cValid		:= "GYD_NUMERO"
cCont       := oMldMaster:GetModel(cIdSubMdl):GETVALUE(cField)

cQryGYD := " SELECT TOP 1 GYD_REVISA "
cQryGYD += " FROM "+RetSqlName("GYD")+ " GYD "
cQryGYD += " WHERE GYD.GYD_FILIAL = '"+xFilial("GYD")+"' and "
cQryGYD += " GYD_NUMERO = '"+cCont+"' and "
cQryGYD += " GYD.D_E_L_E_T_ = ' ' "
cQryGYD += " ORDER BY GYD_REVISA DESC "

cQuery := " SELECT GYD_FILIAL, GYD_NUMERO,GYD_REVISA, GYD_CODGYD "
cQuery += " FROM " + RetSqlName("GYD") + " GYD  "
cQuery += " WHERE GYD.D_E_L_E_T_ = ' ' "
cQuery += " AND GYD.GYD_FILIAL = '"+xFilial('GYD')+"' "
cQuery += " AND GYD." + cValid + " = '" + cCont + "' "
cQuery += " AND GYD.GYD_REVISA=("+cQryGYD+" ) "

cQuery := ChangeQuery(cQuery)

oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GYD_FILIAL","GYD_NUMERO","GYD_REVISA", "GYD_CODGYD"})

oLookUp:AddIndice("Filial"		, "GYD_FILIAL")
oLookUp:AddIndice("Número"		, "GYD_NUMERO")
oLookUp:AddIndice("Revisão"		, "GYD_REVISA")
oLookUp:AddIndice("Linha"		, "GYD_CODGYD")

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	c901BCodigo := aRetorno[4]
EndIf   

FreeObj(oLookUp)

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA901ORC(oModel)
Função utilizada para chamada da rotina GTPA900
@sample		GTPA901ORC
@return		oModel = oModel
@author	GTP
@since		19/08/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA901ORC(oMdl900)
Local aFldsGQ8  := oMdl900:GetModel('GQ8DETAIL'):GetStruct():GetFields()
Local aFldsGQB  := oMdl900:GetModel('GQBDETAIL'):GetStruct():GetFields()
Local n1        := 0
Local n2        := 0

oMdl901   := FwLoadModel('GTPA901')

oMdl901:SetOperation(MODEL_OPERATION_INSERT)
oMdl901:GetModel('GQ8MASTER'):GetStruct():SetProperty("GQ8_CODGY0", MODEL_FIELD_WHEN, { ||.F.})
oMdl901:GetModel('GQ8MASTER'):GetStruct():SetProperty("GQ8_CODGYD", MODEL_FIELD_WHEN, { ||.F.})
oMdl901:GetModel('GQ8MASTER'):GetStruct():SetProperty("GQ8_CODGY0", MODEL_FIELD_OBRIGAT, .F.) 
oMdl901:GetModel('GQ8MASTER'):GetStruct():SetProperty("GQ8_CODGYD", MODEL_FIELD_OBRIGAT, .F.)
If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
    oMdl901:GetModel('GQ8MASTER'):GetStruct():SetProperty("GQ8_CODG6R", MODEL_FIELD_OBRIGAT, .F.)
endif
oMdl901:Activate()

For n1 := 1 To Len(aFldsGQ8)
    If aFldsGQ8[n1][3] <> 'GQ8_CODIGO' 
        oMdl901:GetModel('GQ8MASTER'):LoadValue(aFldsGQ8[n1][3], oMdl900:GetModel('GQ8DETAIL'):GetValue(aFldsGQ8[n1][3]))
    Endif
Next

For n2 := 1 To oMdl900:GetModel('GQBDETAIL'):Length()

    If !Empty(oMdl901:GetModel('GQBDETAIL'):GetValue('GQB_ITEM')) 
        oMdl901:GetModel('GQBDETAIL'):AddLine()
    Endif

    For n1 := 1 To Len(aFldsGQB)
        oMdl901:GetModel('GQBDETAIL'):LoadValue(aFldsGQB[n1][3], oMdl900:GetModel('GQBDETAIL'):GetValue(aFldsGQB[n1][3], n2))
    Next

Next

FWExecView( "Lista de passageiros" , "VIEWDEF.GTPA901", 3,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , oMdl901)    

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G901Commit(oModel)
Função para commit do Model
@sample		G901Commit
@return		lRet - Lógico
@author	GTP
@since		19/08/2020
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function G901Commit(oModel)
Local lRet      := .T.
Local n1        := 0
Local n2        := 0
Local aFldsGQ8  := oModel:GetModel('GQ8MASTER'):GetStruct():GetFields()
Local aFldsGQB  := oModel:GetModel('GQBDETAIL'):GetStruct():GetFields()

If oModel:VldData()

    If !(FwIsInCallStack('GTPA901ORC'))
        lRet := FWFormCommit(oModel)
    Else
        oMdl901 := FwLoadModel('GTPA901')
        oMdl901:SetOperation(MODEL_OPERATION_INSERT)
        oMdl901:Activate()

        For n1 := 1 To Len(aFldsGQ8)
            oMdl901:GetModel('GQ8MASTER'):LoadValue(aFldsGQ8[n1][3], oModel:GetModel('GQ8MASTER'):GetValue(aFldsGQ8[n1][3]))
        Next

        For n2 := 1 To oModel:GetModel('GQBDETAIL'):Length()

            If !Empty(oMdl901:GetModel('GQBDETAIL'):GetValue('GQB_ITEM')) //!(AllTrim(oMdl901:GetModel('GQBDETAIL'):GetValue('GQB_CODIGO')) == '')
                oMdl901:GetModel('GQBDETAIL'):AddLine()
            Endif

            For n1 := 1 To Len(aFldsGQB)
                oMdl901:GetModel('GQBDETAIL'):LoadValue(aFldsGQB[n1][3], oModel:GetModel('GQBDETAIL'):GetValue(aFldsGQB[n1][3], n2))
            Next

        Next
    EndIf
Else
    lRet := .F.
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP901TdOK()
Definição do Menu
 
@sample	TP901TdOK()
 
@return	lRet - verifica se validação está ok
 
@author	Flavio Oliveira
@since		29/01/2024
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function TP901TdOK(oModel)

	Local oMdlGQ8	:= oModel:GetModel('GQ8MASTER')
    Local oMdlGQB   := oModel:GetModel('GQBDETAIL')	
    Local nLinha     := 0
    Local lRet	:= .T.
	
	If (oMdlGQ8:GetOperation() == MODEL_OPERATION_INSERT .OR. oMdlGQ8:GetOperation() == MODEL_OPERATION_UPDATE)

        If  GQ8->(ColumnPos("GQ8_CODG6R")) > 0
            If ((Empty(oMdlGQ8:GetValue("GQ8_CODGY0"))) .Or. (Empty(oMdlGQ8:GetValue("GQ8_CODGYD")))) .And. (Empty(oMdlGQ8:GetValue("GQ8_CODG6R")))
    			lRet := .F.
    			Help( ,, 'Help',"TP901TdOK", STR0011, 1, 0 )//"Necessário preecnher os Campos: 'Cód. Contrato e Cód Linha' ou o Campo: Cód. Orçamento"
		
            ElseIf (!Empty(oMdlGQ8:GetValue("GQ8_CODGY0"))) .And. (!Empty(oMdlGQ8:GetValue("GQ8_CODGYD"))) .And. (!Empty(oMdlGQ8:GetValue("GQ8_CODG6R")))
    			lRet := .F.
    			Help( ,, 'Help',"TP901TdOK", STR0012, 1, 0 )//"Não é permitido preencher todos os 3 Campos: 'Cód. Contrato e Cód Linha' e Cód. Orçamento" 

           ElseIf (!Empty(oMdlGQ8:GetValue("GQ8_CODGY0"))) .And. (Empty(oMdlGQ8:GetValue("GQ8_CODGYD"))) .And. (!Empty(oMdlGQ8:GetValue("GQ8_CODG6R")))
          		lRet := .F.
    			Help( ,, 'Help',"TP901TdOK", STR0013, 1, 0 )//"Não é permitido preencher o Campo: Cód. Contrato e o Campo: Cód. Orçamento"

           ElseIf (Empty(oMdlGQ8:GetValue("GQ8_CODGY0"))) .And. (!Empty(oMdlGQ8:GetValue("GQ8_CODGYD"))) .And. (!Empty(oMdlGQ8:GetValue("GQ8_CODG6R")))
    			lRet := .F.
    			Help( ,, 'Help',"TP901TdOK", STR0014, 1, 0 )//"Não é permitido preencher o Campo: Cód Linha e o Campo: Cód. Orçamento"
           EndIf
        Endif

    EndIf


Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP901LOK()
Definição do Menu
 
@sample	TP901LOK()
 
@return	lRet - verifica se validação está ok na linha do Grid
 
@author	Flavio Oliveira
@since		29/01/2024
@version	P12
/*/
Static Function TP901LOK( oModel )
    
    Local lRet      := .T.
    Local nI
    Local _cCODCPF := Alltrim(oModel:GetValue("GQB_CPF"))

    //Busca o modelo ativo na memória e define o bloco de código que irá sobrepor o bPos e se irá acumular com a antiga validação
    FwModelActive( oModel, .T. )

    nLinGrd := oModel:GetLine()

    //Percorrendo a grid com os itens
    For nI := 1 to oModel:Length()
         //Posicionando na linha atual
        oModel:GoLine(nI) 

        //Exceto linha atual e se a linha tiver deletada
		If nI <> nLinGrd .and. !oModel:IsDeleted()
			If	 Alltrim(oModel:GetValue("GQB_CPF")) == _cCODCPF .And. !Empty(oModel:GetValue("GQB_CPF")) 				
				lRet := .F.
				cErro := I18n(STR0016, { cValToChar(nI) } ) //"CPF na Linha [ #1 ] duplicado. Corrigir!"
                Help( ,, 'Help',"TP901LOK", cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0015})	    
				Exit
			Endif
		Endif	
	Next nI

Return lRet
