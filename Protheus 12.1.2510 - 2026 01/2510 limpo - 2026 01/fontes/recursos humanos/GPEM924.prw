#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'
#INCLUDE 'GPEM924.ch'

#define  CRLF chr(13)+chr(10)
Static cMsgSucesso := STR0001//"Segundo Passo"

/*/{Protheus.doc} GPEM924
    Monitor de Processamento da Integração GPE x NG

    @type  Function
    @author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27

/*/
Function GPEM924()

Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("RJP")
oBrowse:SetDescription(OemToAnsi(STR0002)) //"Monitor Integração NG"

//Define as legendas
oBrowse:AddLegend('!Empty(RJP->RJP_DTIN) .And. AllTrim(RJP->RJP_RTN) == "'+STR0001+'" '  ,"BR_VERDE" 		,STR0003)//"Segundo Passo"##"Processado"
oBrowse:AddLegend('Empty(RJP->RJP_DTIN) '                                                ,"BR_AZUL" 	    ,STR0004)//"Pendente"
oBrowse:AddLegend('!Empty(RJP->RJP_DTIN) .And. AllTrim(RJP->RJP_RTN) <> "'+STR0001+'" '  ,"BR_VERMELHO" 	,STR0005)//"Segundo Passo"##"Falha"

oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
    Carrega as opções de menu.

    @type  Function
    @author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27
    
    @return aRotina, Array, Array com as opções de Menu
    
/*/
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title STR0006    Action "VIEWDEF.GPEM924"   Operation 2 Access 0//"Visualizar"
Add Option aRotina Title STR0007    Action "GPEM924MNU(1)"      Operation 4 Access 0//"Reenvio"
Add Option aRotina Title STR0020    Action "GPEM924MNU(3)"      Operation 4 Access 0//"Histórico Envio"
Add Option aRotina Title STR0021    Action "GPEM924MNU(5)"      Operation 4 Access 0//"Limpar Histórico"
Add Option aRotina Title STR0008    Action "GPEM924MNU(2)"      Operation 5 Access 0//"Excluir"


    
Return aRotina

/*/{Protheus.doc} ModelDef
    Reponsável pela montagem do modelo

    @type  Static Function
    @author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27
    
    @return oModel, Object, Objeto do Modelo
    
    /*/
Static Function ModelDef()

Local oModel     
Local oStruRJP	:= FwFormStruct(1,"RJP") 

oModel := MPFormModel():New("GPEM924",/*bPreValidacao*/,/*bTudoOk*/,/*bCommit*/,/*bCancel*/)

oModel:AddFields("RJPMASTER",/*Owner*/,oStruRJP)
oModel:SetPrimaryKey({'RJP_FILIAL','RJP_FIL','RJP_MAT'})

oModel:SetDescription(OemToAnsi(STR0002))//"Monitor Integração NG"

oModel:GetModel("RJPMASTER"):SetDescription(OemToAnsi(STR0002))//"Monitor Integração NG"

Return oModel

/*/{Protheus.doc} ViewDef
    Responsável pela montagem da View

    @type  Static Function
    author rafaelalmeida
    @since 05/06/2020
    @version 12.1.27
    
    @return oView, Object, Objeto View
/*/
Static Function ViewDef(param_name)
    
Local oModel:= FwLoadModel("GPEM924") 
Local oStruRJP := FwFormStruct(2,"RJP")
Local oView := FwFormView():New()

oView:SetModel(oModel)

oView:AddField("VIEW_RJP",oStruRJP,"RJPMASTER")

oView:CreateHorizontalBox("SUPERIOR",100,,,,)

oView:SetOwnerView("VIEW_RJP","SUPERIOR")

Return oView

/*/{Protheus.doc} GPEM924MNU
    
    Função para chamar as static functions.

    @type  Function
    @author rafaelalmeida
    @since 05/06/2020
    @version version
    @param nTipo, Numeric, Determina qual static será acionada pelo menu.
    
    /*/
Function GPEM924MNU(nTipo)

    Default nTipo := 0

    Do Case
        Case nTipo == 1// Limpeza do campo RJ_DTIN
            ClearDTIn()
        Case nTipo == 2// Exclusão do registro.
            DelRjp()
        Case nTipo == 3// Visualizar Histórico de Envio
            FWExecView(STR0020, "GPEM927", MODEL_OPERATION_VIEW,,{||.T.}) //"Histórico Envio"
        Case nTipo == 5// Limpar Histórico
            fDelHist()
    EndCase

Return Nil

/*/{Protheus.doc} ClearDtIn
    
    Limpa o campo RJ_DTIN

    @type  Static Function
    @author rafaelalmeida

    @since 05/06/2020
    @version 12.1.27
    
/*/
Static Function ClearDTIn()

    Local aAreOld := {RJP->(GetArea()),GetArea()}

    If Upper(AllTrim(RJP->RJP_RTN)) <>  Upper(Alltrim(cMsgSucesso))
        If MsgNoYes(STR0010)//"Tem certeza que deseja disponibilizar este registro para reenvio?"
            RecLock('RJP',.F.)
            RJP->RJP_DTIN   := StoD('')
            RJP->RJP_HORAIN := ''
            RJP->RJP_RTN    := ''
            RJP->(MsUnlock())
            MsgInfo(STR0011,STR0012)//"Registro disponbilizado para reenvio!"##"GPEM924 - Reenvio"
        else
            MsgInfo(STR0013,STR0012)//"Reenvio cancelado!"##"GPEM924 - Reenvio"
        EndIf
    else
        If MsgNoYes(STR0030)  //"Registro enviado com sucesso, confirma o reenvio? "
            RecLock('RJP',.F.)
            RJP->RJP_DTIN   := StoD('')
            RJP->RJP_HORAIN := ''
            RJP->RJP_RTN    := ''
            RJP->(MsUnlock())
            MsgInfo(STR0011,STR0012)
        Else
            MsgInfo(STR0013,STR0012)//"Reenvio cancelado!"##"GPEM924 - Reenvio" 
        Endif    
    EndIf

    aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil

/*/{Protheus.doc} DelRJP
    Exclui o registro da RJP.

    @type  Static Function
    @author rafaelalmeida

    @since 05/06/2020
    @version 12.1.27
    
    
    /*/
Static Function DelRJP()

    Local aAreOld := {RJP->(GetArea()),GetArea()}

    If Empty(RJP->RJP_DTIN) 
        If MsgNoYes(STR0015)//"Tem certeza que deseja excluir o registro posicionado?"
            RecLock('RJP',.F.)
            RJP->(dbDelete())
            RJP->(MsUnlock())
            MsgInfo(STR0016,STR0017)//"Registro excluido com sucesso!"##"GPEM924 - Exclusão"
        Else
            MsgInfo(STR0018,STR0017)//"Exclusão cancelada!"##"GPEM924 - Exclusão"
        EndIf
    else
        MsgStop(STR0019)//"Não é possível excluir registros já enviados!"
    EndIf

    aEval(aAreOld, {|xAux| RestArea(xAux)})

Return 

/*/{Protheus.doc} fDelHist
    Função para exclusão do histórico em lote
    @type  Function
    @author martins.marcio
    @since 05/12/2023
    @version version
/*/
Static Function fDelHist()

   	Local cAliasRU7	:= ""
    Local aArea		:= GetArea()
    Local cFilDe    := ""
    Local cFilAt    := ""
    Local cDtIntDe  := STOD("")
    Local cDtIntAt  := STOD("20991231")
    Local lExcPerm  := .F.
    Local nCont7    := 0
    Local cQryDel   := ""
    Local lExsPergunte  := .F.
    Local oSX1

    oSX1 := FWSX1Util():New()
	oSX1:AddGroup("GPEM927")
	oSX1:SearchGroup()
		
	If (Len(oSX1:aGrupo) >= 1 .And. Len(oSX1:aGrupo[1][2]) >= 1) 
		lExsPergunte := .T.
	EndIf

    If lExsPergunte 
        If Pergunte("GPEM927", .T.)        
            // Recebe o valor das perguntas preenchidas
            cFilDe      := FwxFilial("RU7",mv_par01)
            cFilAt      := FwxFilial("RU7",mv_par02)
            cDtIntDe    := mv_par03
            cDtIntAt    := mv_par04
            lExcPerm    := IIf(mv_par05 == 2, .T., .F.)    
                
            cAliasRU7	:= GetNextAlias()

            BeginSql alias cAliasRU7
                SELECT RU7_FILIAL, RU7_ID, RU7_SEQ, RU7_DTIN, RU7_HORAIN, R_E_C_N_O_ RECNRU7
                FROM %table:RU7% RU7
                WHERE
                RU7_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAt%
                AND RU7_DTIN BETWEEN %exp:cDtIntDe% AND %exp:cDtIntAt%
                AND RU7.%NotDel%
            EndSql

            If !(cAliasRU7)->(Eof())
                DbSelectArea("RU7")
                While !(cAliasRU7)->(Eof())
                    RU7->(DbGoTo((cAliasRU7)->RECNRU7))
                    If Reclock("RU7", .F.)
                        RU7->(DbDelete())
                        RU7->(MsUnlock())
                    EndIf
                    nCont7 ++
                    (cAliasRU7)->(DbSkip())
                EndDo
                If lExcPerm .And. MsgNoYes(OemToAnsi(STR0022) + CRLF + CRLF + OemToAnsi(STR0023)) //"Confirma a exclusão permanente do histórico de envio?" ## "Após a confirmação NÃO SERÁ POSSÍVEL DESFAZER."
                    cQryDel := "DELETE FROM " + RetSqlName("RU7") + " WHERE D_E_L_E_T_ = '*'"
                    TcSqlExec( cQryDel )
                EndIf
                ApMsgInfo(OemToAnsi(STR0024) + CRLF + CRLF + OemToAnsi(STR0025) + cValToChar(nCont7) + OemToAnsi(STR0026)) //"Operação realizada com sucesso." ## "Foram apagadas " ## " linhas de histórico."
            Else
                ApMsgInfo(OemToAnsi(STR0027)) //"Não foram encontrados registros com os parâmetros informados."
            EndIf
            (cAliasRU7)->(DbCloseArea())
        EndIf
    Else
         ApMsgInfo(OemToAnsi(STR0028)) //"Para utilizar essa opção atualize o dicionário de dados via Expedição Contínua - deverá ser criado grupo de perguntas GPEM927."
    EndIf
    
    RestArea( aArea )

Return
