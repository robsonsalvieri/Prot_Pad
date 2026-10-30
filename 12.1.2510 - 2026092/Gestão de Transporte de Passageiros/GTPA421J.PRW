#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA421J.CH"

/*/{Protheus.doc} GTPA421J
    Entrega em Lote de Fichas de Remessa
    @type  Function
    @author José Carlos
    @since 26/04/2026
    @version 1
    @param 
    @return nil,null, Sem Retorno
    @example    GTPA421J()
    @see (links_or_references)
/*/
Function GTPA421J()
    Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0002 },{.T., STR0003},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Processar" //"Fechar"
    If ( !FindFunction("GTPHASACCESS") .Or.; 
        ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 

        FWExecView(STR0001,"VIEWDEF.GTPA421J",MODEL_OPERATION_UPDATE,,{|| .T.}, /*bOk*/ , 75/*nPercReducao*/, aEnableButtons, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ )    //"Entrega em lote"

    EndIf  
Return()

/*/{Protheus.doc} ModelDef
    Model para Lote entrega de Fichas de Remessa 
    @type  Static Function
    @author José Carlos
    @since 26/04/2026
    @version 1
    @param 
    @return oModel, objeto, instância da classe FwFormModel
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
    Local oModel    := Nil
    Local oStruPerg	:= FWFormModelStruct():New() // "Grupo de Perguntas"
    Local bCommit   := {|oModel| CommitEntrega(oModel)}
    Local bLoad     := {|oModel| GA421JLoad(oModel)}    
    Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
    Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
    Local nTamAgenc := TamSx3('GIC_AGENCI')[1]

    oModel := MPFormModel():New("GTPA421J",,,)

	oStruPerg:AddField(STR0004,STR0004  ,"AGENCIA" ,"C",nTamAgenc, 0,bFldVld  ,{|| .T.},{},.T.,Nil,.F.,.F.,.T.) //"Código Agência:"
    oStruPerg:AddField(STR0005,STR0005  ,"DATAINI" ,"D",        8, 0,{|| .T.} ,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Data De"
    oStruPerg:AddField(STR0006,STR0006  ,"DATAFIM" ,"D",        8, 0, bFldVld ,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) //"Data Até"        
    
    oStruPerg:AddTrigger("DATAINI"   ,"DATAINI"	 	, { || .T. }, bFldTrig)

    oModel:AddFields("CABEC", /*cOwner*/, oStruPerg,,,bLoad/*bLoad*/) 
    oModel:GetModel( "CABEC" ):SetDescription( STR0007 ) //'Lote entrega de Fichas de Remessa'   
    oModel:SetDescription(STR0008) //'Ficha de Remessa'

    oModel:SetPrimaryKey({})
    oModel:SetCommit(bCommit)

Return oModel     


/*/{Protheus.doc} ViewDef
    View para a Conferência de Bilhetes
    @type  Static Function
    @author José Carlos
    @since 26/04/2026
    @version 1
    @param 
    @return oView, objeto, instância da Classe FWFormView
    @example
    (examples)
    @see (links_or_references)
/*/ 
Static Function ViewDef()
    Local oView		:= nil
    Local oModel    := FwLoadModel("GTPA421J")
    Local oStruPerg := FWFormViewStruct():New()

    // Cria o objeto de View
    oView := FWFormView():New()    

    oStruPerg:AddField("AGENCIA",;					// [01] C Nome do Campo
                        "01",;						// [02] C Ordem
                        STR0004,;			        // [03] C Titulo do campo       //"Código Agência:"
                        STR0004,;			        // [04] C Descrição do campo    //"Código Agência:"
                        {STR0004},;		            // [05] A Array com Help        //"Código Agência:"
                        "GET",; 					// [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;						// [07] C Picture
                        NIL,; 						// [08] B Bloco de Picture Var
                        'GI6',;						// [09] C Consulta F3
                        .T.,; 						// [10] L Indica se o campo é editável
                        '',; 						// [11] C Pasta do campo
                        NIL,; 						// [12] C Agrupamento do campo
                        Nil,; 						// [13] A Lista de valores permitido do campo (Combo)
                        NIL,; 						// [14] N Tamanho Maximo da maior opção do combo
                        NIL,;	 					// [15] C Inicializador de Browse
                        .F.) 						// [16] L Indica se o campo é virtual

    oStruPerg:AddField("DATAINI","02",STR0005,STR0005   ,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data De"
    oStruPerg:AddField("DATAFIM","03",STR0006,STR0006   ,{""},"GET",""  ,NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Data Até"

    oStruPerg:SetProperty( 'AGENCIA', MVC_VIEW_CANCHANGE, .T.)
    oStruPerg:SetProperty( 'DATAINI', MVC_VIEW_CANCHANGE, .T.)
    oStruPerg:SetProperty( 'DATAFIM', MVC_VIEW_CANCHANGE, .T.)

    oView:SetModel(oModel)
    oView:SetDescription(STR0009)  //"Seleção de Agência"
    oView:AddField('VIEW_PERG' ,oStruPerg,'CABEC')
    oView:CreateHorizontalBox('TELA', 100)
    oView:SetOwnerView('VIEW_PERG','TELA')                        
    oView:SetViewAction("ASKONCANCELSHOW",{||.F.})
    oView:ShowUpdateMsg(.F.)

Return oView

/*/{Protheus.doc} GA421JLoad
	Load
	@type Function
	@author José Carlos
	@since 26/04/2026

/*/
Static Function GA421JLoad(oModel)
    Local oMdlCab := NIL
    oMdlCab := oModel:GetModel( 'CABEC' )
Return

/*/{Protheus.doc} FieldValid
    Validação do campo
	@type Function
	@author José Carlos
	@since 26/04/2026
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
    Local lRet		:= .T.
    Local oModel	:= oMdl:GetModel()
    Local cMdlId	:= oMdl:GetId()
    Local cMsgErro	:= ""
    Local cMsgSol	:= ""

    Do Case
            
        Case Empty(uNewValue)
            lRet := .T.

        Case cField == "DATAFIM"
            If uNewValue < oModel:GetModel('CABEC'):GetValue('DATAINI')
                lRet     := .F.
                cMsgErro := STR0010 //"Data final não pode ser menor que a data inicial"
                cMsgSol  := STR0011 //"Altere a data final"
            Endif
        Case cField == "AGENCIA"
            lRet := Alltrim(GetAdvFval("GI6","GI6_CODIGO",xFilial("GI6")+uNewValue,1,'')) <> ''
            If !lRet 
                cMsgErro := STR0012 //"Agência não localizado no cadastro."
                cMsgSol  := STR0013 //"Verifique o código da agência no cadastro."
            EndIf 
    EndCase

    If !lRet .and. !Empty(cMsgErro)
        oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
    Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
	Trigger
	@type Function
	@author José Carlos
	@since 26/04/2026
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
	
    Do Case
        Case cField == 'DATAINI' 
            oMdl:SetValue('DATAFIM', dDataBase)	
    EndCase

Return uVal


/*/{Protheus.doc} CommitEntrega(oModel)
    Realiza o commit 
    @type  Static Function
    @author Flavio Martins
    @since 27/10/2017
    @version 1
    @param oModel
    @return
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CommitEntrega(oModel)
    Local lRet := .T.

    FWMsgRun(, {|| lRet:= ProcessaEntrega(oModel) },"", STR0014)  //"Processando registro(s) ..."

Return lRet 

Static Function ProcessaEntrega(oModel)
    Local lRetorno     := .T.
    Local cAliasQry    := GetNextAlias()
    Local cAgencia     := oModel:GetModel( 'CABEC' ):GetValue( 'AGENCIA' )
    Local cDataInicial := Dtos(oModel:GetModel( 'CABEC' ):GetValue( 'DATAINI' ))
    Local cDataFinal   := Dtos(oModel:GetModel( 'CABEC' ):GetValue( 'DATAFIM' ))
    Local dDataAux     := dDataBase

    BeginSql Alias cAliasQry
        Select G6X_DTREME, R_E_C_N_O_ as REGISTRO
        From %table:G6X%
        Where 
            G6X_FILIAL = %xFilial:G6X%
        and G6X_AGENCI = %Exp:cAgencia%
        and G6X_DTINI BETWEEN %Exp:cDataInicial% and %Exp:cDataFinal%
        and G6X_STATUS IN ('1','5')
        and %NotDel%
        order by G6X_DTREME
    EndSql 

    If (cAliasQry)->(!Eof())
        While (cAliasQry)->(!Eof())
            G6X->(DbGoTo((cAliasQry)->REGISTRO))
            dDataBase:= Stod((cAliasQry)->G6X_DTREME)
            A421EncFic()
            (cAliasQry)->(DbSkip())
        EndDo 
    Else 
        FWAlertInfo(STR0015, STR0016)  //"Não localizado registro(s) com os parâmetros informados." "Informativo"                 
    EndIf 

    (cAliasQry)->(DbCloseArea())

    dDataBase := dDataAux

Return lRetorno 
