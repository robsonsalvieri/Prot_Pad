#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'WMSSAAS001.CH'

#define CTRL Chr(13)+Chr(10)
#define WMSSAAS00101 "WMSSAAS00101"

Static oBrowse
Static lMarkAll := .F. // Indicador de marca/desmarca todos
Static cWmsMark := ""

Function WmsSaas001()
SetKey( VK_F11 , { || WMSSS001X1() } )

DBSelectArea('DBZ')
DBZ->(DBSetOrder(2))

oBrowse:= FWMarkBrowse():New()
oBrowse:SetAlias('DBZ')
oBrowse:SetDescription(STR0001) //--Convergência Integração WMS Saas
oBrowse:SetFieldMark("DBZ_OK")
oBrowse:SetAllMark({||WMSSAllMrk()})
oBrowse:SetValid({||WMSSVldMrk()})

// -- Legendas (Já adiciona filtros)
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusCriado()","WHITE",STR0012) //--Criado
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusLiberado()","YELLOW",STR0013) //--Liberado
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusIntegrado()","GREEN",STR0014) //--Integrado
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusErroIntegracao()","RED",STR0015) //--Erro na integração
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusCancelado()","CANCEL",STR0016) //--Cancelado
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusFinalizado()","OK",STR0017) //--Finalizado
oBrowse:AddLegend("DBZ_STATUS== WMSSaasConvergencia():getStatusFinalizadoDivergente()","BLUE",STR0018) //--Finalizado com Divergência


// -- Filtros de tipo de transação
oBrowse:AddFilter(STR0019, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoRecebimento()") //--Recebimentos
oBrowse:AddFilter(STR0020, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoPedidoVenda()") //--Pedidos de Venda
oBrowse:AddFilter(STR0034, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoFaturamentoPedidoVenda()") //--Faturamento Pedidos de Venda
oBrowse:AddFilter(STR0030, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoEstoqueInventario()") //--Inventário
oBrowse:AddFilter(STR0031, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoEstoqueMovimentoSimplificado()") //--Movimento Simplificado
oBrowse:AddFilter(STR0032, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoEstoqueMovimentoTransferencia()") //--Movimento Transferência
oBrowse:AddFilter(STR0033, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoFaturamentoAntecipado()") //--Faturamento Antecipado
oBrowse:AddFilter(STR0035, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoManufaturaRequisicao()") //-- Manufatura Requisicao
oBrowse:AddFilter(STR0036, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoManufaturaApontamentoProducao()") //-- Manufatura Apontamento Producao
oBrowse:AddFilter(STR0037, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoEstoqueTransferenciaEntrada()") //-- Estoque Transferencia Entrada
oBrowse:AddFilter(STR0038, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoEstoqueTransferenciaSaida()") //-- Estoque Transferencia Saida
oBrowse:AddFilter(STR0040, "DBZ_TIPOTR == WMSSaasConvergencia():getTipoTransacaoEstoqueRequisicaoArmazem()") //-- Estoque Requisicao Armazem

// -- Filtro de Status que podem ser atualizados
oBrowse:AddFilter(STR0021, "WMSSaasConvergencia():isStatusDisponivelLiberacao(DBZ_STATUS)") //--Disponíveis para liberação
oBrowse:SetParam({|| WMSSSelDBZ(oBrowse) })
If Pergunte("WMSSAAS001",.T.)
    oBrowse:SetFilterDefault("DBZ_CRIACA >= '"+FwTimeStamp(3,MV_PAR01, "00:00")+"' .And. DBZ_CRIACA <= '"+FwTimeStamp(3,MV_PAR02, "23:59")+"'")
    oBrowse:SetdbFFilter(.T.)
	oBrowse:SetUseFilter(.T.)
    oBrowse:Activate()
EndIf

SetKey(VK_F11,Nil)

Return NIL

/*/{Protheus.doc} ModelDef
    Modelo de dados do MVC
    @type  Static Function
    @author user
    @since 23/05/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function ModelDef()
Local oModel
Local oEstDBZ:= FWFormStruct(1,'DBZ')
Local oEstDBY:= FWFormStruct(1,'DBY')

    oModel := MPFormModel():New('WmsSaas001')

    oModel:addFields('DBZ_MASTER',,oEstDBZ)
    oModel:addGrid('DBY_DETAILS','DBZ_MASTER',oEstDBY)

    oModel:SetRelation('DBY_DETAILS', { { 'DBY_FILIAL', 'XFilial("DBY")' }, { 'DBY_ID', 'DBZ_ID' } }, DBY->(IndexKey(1)) )

    oModel:SetDescription(STR0001)//'Convergência Integração WMS Saas'
    oModel:getModel('DBZ_MASTER'):SetDescription(STR0002)//'Documento de Integração'
    oModel:getModel('DBY_DETAILS'):SetDescription(STR0003)//'Itens para Integração'

    oModel:GetModel( 'DBY_DETAILS' ):SetOptional(.T.)

    oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
    Definicao da View
    @type  Static Function
    @author user
    @since 23/05/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
Local oView
Local oModel := FWLoadModel( 'WmsSaas001' )
Local oEstDBZ:= FWFormStruct(2,'DBZ')
Local oEstDBY:= FWFormStruct(2,'DBY')

    oView := FWFormView():New() 

    oView:SetModel(oModel)
    oView:AddField('MASTER_DBZ' , oEstDBZ,'DBZ_MASTER')
    oView:AddGrid('DETAILS_DBY' , oEstDBY,'DBY_DETAILS')
    
    oView:CreateHorizontalBox( 'BOXFORM1', 30)
    oView:CreateHorizontalBox( 'BOXFORM2', 70)

    oView:SetOwnerView('MASTER_DBZ','BOXFORM1')
    oView:SetOwnerView('DETAILS_DBY','BOXFORM2')

    oView:EnableTitleView('MASTER_DBZ' , STR0004 )// -- Documento de Integração
    oView:EnableTitleView('DETAILS_DBY' , STR0005 )// -- Itens para Integração

    oView:setOnlyView("MASTER_DBZ")
    oView:setOnlyView("DETAILS_DBY")

Return oView

/*/{Protheus.doc} MenuDef
    Definicao do menu
    @type  Static Function
    @author user
    @since 23/05/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function MenuDef()
Local aRotina := {}
    ADD OPTION aRotina TITLE STR0022 ACTION 'VIEWDEF.WMSSAAS001' OPERATION 2 ACCESS 0 //'Visualizar'
    ADD OPTION aRotina TITLE STR0006 ACTION 'WMSSLibera'         OPERATION 2 ACCESS 0 //"Liberar"
Return aRotina


/*/{Protheus.doc} WMSSSelDBZ
    Recarrega browse
    @type  Static Function
    @author user
    @since 05/06/2024
    @version version
    @param param_name, param_type, param_descr
    @example
    (examples)
    @see (DLOGWMSMSP-16358)
/*/
Static Function WMSSSelDBZ(oBrowse)

    If Pergunte("WMSSAAS001",.T.)
        oBrowse:SetFilterDefault("DBZ_CRIACA >= '"+FwTimeStamp(3,MV_PAR01, "00:00")+"' .And. DBZ_CRIACA <= '"+FwTimeStamp(3,MV_PAR02, "23:59")+"'")
        oBrowse:SetdbFFilter(.T.)
        oBrowse:SetUseFilter(.T.)
        oBrowse:Refresh(.T.)
    EndIf
Return


/*/{Protheus.doc} WMSSS001X1
    Ativa pergunte de transacoes automaticas
    @type  Static Function
    @author equipe WMS Protheus
    @since 07/03/2025
    @see (DLOGWMSMSP-17240)
/*/
Static Function WMSSS001X1()
    Pergunte("WMSSAAS01A",.T.,STR0039) //"Transações com Liberação Automática"
    Pergunte("WMSSAAS001",.F.)
Return Nil

/*/{Protheus.doc} WMSSLibera
    Realiza a liberação de itens marcados
    @type  Static Function
    @author user
    @since 26/06/2024
    @version version
    @see (DLOGWMSMSP-16455)
/*/
Function WMSSLibera()
Local aAreaDBZ   := DBZ->(GetArea())
Local cAliasDBZ  := GetNextAlias()
Local aLiberados := {}
Local cWhere     := "% AND DBZ.DBZ_STATUS IN ('"+WMSSaasConvergencia():getStatusCriado()+"','"+WMSSaasConvergencia():getStatusCancelado()+"','"+WMSSaasConvergencia():getStatusErroIntegracao()+"')%"
Local cFilBkp    := cFilAnt
  
    BeginSql Alias cAliasDBZ
        SELECT DBZ.DBZ_FILIAL,DBZ.DBZ_NUMDOC,DBZ.DBZ_TIPOTR,DBZ.DBZ_ID,DBZ.R_E_C_N_O_ AS RECDBZ
          FROM %Table:DBZ% DBZ
         WHERE DBZ.DBZ_CRIACA BETWEEN %Exp:FwTimeStamp(3,MV_PAR01, "00:00")% AND %Exp:FwTimeStamp(3,MV_PAR02, "23:59")%
           AND DBZ.DBZ_OK = %Exp:WMSSMark()%
           AND DBZ.%NotDel%
           %Exp:cWhere%
    EndSql
    If (cAliasDBZ)->(!Eof())
        If FWAlertNoYes(STR0024, STR0008) //"Confirma a liberação de todos os itens marcados?"/"Liberação WMS SaaS"
            While (cAliasDBZ)->(!Eof())
                cFilAnt := (cAliasDBZ)->DBZ_FILIAL
                If WMSSLibReg((cAliasDBZ)->DBZ_TIPOTR,(cAliasDBZ)->DBZ_ID)
                    DBZ->(DbGoTo((cAliasDBZ)->RECDBZ))
                    If RecLock("DBZ", .F.)
                        DBZ->DBZ_OK := ' '
                        DBZ->(MsUnlock())
                        aAdd(aLiberados, AllTrim((cAliasDBZ)->DBZ_NUMDOC))
                    EndIf
                EndIf
                (cAliasDBZ)->( DbSkip() )
            EndDo 
            cFilAnt := cFilBkp
            If !Empty(aLiberados)
                WMSSResLib(aLiberados)
            EndIf
        EndIf
    EndIf
    (cAliasDBZ)->(dbCloseArea())
    RestArea(aAreaDBZ)
Return


/*/{Protheus.doc} WMSSAllMrk
    Marca somente itens filtrados
    @type  Static Function
    @author user
    @since 26/06/2024
    @version version
    @see (DLOGWMSMSP-16455)
/*/
Static Function WMSSAllMrk()
Local aAreaDBZ  := DBZ->(GetArea())
Local cAliasDBZ := Nil
Local cAliasAux := Nil
Local lRet := .T.
    
    cAliasAux := GetNextAlias()
    BeginSql Alias cAliasAux
        SELECT 1
          FROM %Table:DBZ% DBZ
         WHERE DBZ.DBZ_OK = %Exp:WMSSMark()%
           AND DBZ.%NotDel%
    EndSql
    lMarkAll := (cAliasAux)->(Eof())
   (cAliasAux)->(dbCloseArea())

    cAliasDBZ := oBrowse:Alias()
    (cAliasDBZ)->(DbGoTop())
    While (cAliasDBZ)->(!Eof())
        lRet := .T.
        If WMSSVldMrk()
            If (lMarkAll .And. WMSSMark() = DBZ->DBZ_OK) .Or. ; //Funcao marcar e ja esta marcado, nao faz nada
            (!lMarkAll .And. Empty(DBZ->DBZ_OK)) //Funcao desmarcar e nao esta marcado, nao faz nada
                lRet := .F.
            EndIf
            If lRet .And. Reclock('DBZ',.F.)
                DBZ->DBZ_OK := Iif(lMarkAll,WMSSMark(),Space(TamSx3("DBZ_OK")[1]))
                DBZ->(MsUnlock())
            EndIf
        EndIf
        (cAliasDBZ)->(DbSkip())
    EndDo

    RestArea(aAreaDBZ)
    oBrowse:Refresh()

Return Nil

Static Function WMSSVldMrk()
Local cAliasDBZ := oBrowse:Alias()
Local oConv := Nil
Local cFilBkp := cFilAnt
Local lRet := .F. 
    
    cFilAnt := (cAliasDBZ)->DBZ_FILIAL
    oConv := WMSSaasConvergencia():LoadById((cAliasDBZ)->DBZ_ID)
    lRet := (oConv:isCriado() .Or. oConv:isCancelado() .Or. oConv:isErroIntegracao())
    cFilAnt := cFilBkp

Return lRet


/*/{Protheus.doc} WMSSMark
    (Recupera a marca do browse)
    @type  Function
    @author user
    @since 26/06/2024
    @see (DLOGWMSMSP-16358)
    /*/
Static Function WMSSMark()
	cWmsMark := oBrowse:cMark
Return cWmsMark


/*/{Protheus.doc} WMSSResLib
    (Gera resultado da liberação de todos os itens apresentados)
    @type  Function
    @author user
    @since 04/06/2024
    @see (DLOGWMSMSP-16358)
    /*/
Function WMSSResLib(aLib)
Local cMensagem := ""

    If !Empty(aLib)	  
        cMensagem += STR0025 +CTRL //"Documentos liberados:"
        cMensagem += CenArr2Str(aLib, ", ")
        cMensagem += "."
        
        WmsMessage(cMensagem,WMSSAAS00101)
    EndIf
Return

/*/{Protheus.doc} WMSSNome
	Busca o nome do Cliente ou fornecedor para alimentar o X3_RELACAO do campo DBZ_NOMEPE
	@author Fagner Ferraz
	@since 27/10/2025
	@return ClienteOuFornecedor, character, Cliente ou fornecedor
/*/
Function WMSSNome(cTipoTR, cNumDoc, cSerie, cClifor, cLoja)
	Local cNome	:= ""

	If cTipoTR $ "01|02|03|07"
		If cTipoTR == "01" //Recebimento
            SF1->(DbSetOrder(1))
			If SF1->(DbSeek(xFilial("SF1")+;
                    Padr(cNumDoc,TamSX3("F1_DOC")[1])+;
                    Padr(cSerie,TamSX3("F1_SERIE")[1])+;
                    Padr(cClifor,TamSX3("F1_FORNECE")[1])+;
                    Padr(cLoja,TamSX3("F1_LOJA")[1])))

                If SF1->F1_TIPO $ "B|D"                       
                    cNome := Posicione("SA1",1,xFilial("SA1")+Padr(cClifor,TamSX3("A1_COD")[1])+Padr(cLoja,TamSX3("A1_LOJA")[1]),"A1_NOME")                          
                Else
                    cNome := Posicione("SA2",1,xFilial("SA2")+Padr(cClifor,TamSX3("A2_COD")[1])+Padr(cLoja,TamSX3("A2_LOJA")[1]),"A2_NOME")	
                EndIf

            EndIf		
		ElseIf cTipoTR == "02" //Pedido de venda
            SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5")+Padr(cNumDoc,TamSX3("C5_NUM")[1])))
            
                If SC5->C5_TIPO $ "B|D"
                    cNome := Posicione("SA2",1,xFilial("SA2")+Padr(cClifor,TamSX3("A2_COD")[1])+Padr(cLoja,TamSX3("A2_LOJA")[1]),"A2_NOME")		                          
                Else
                    cNome := Posicione("SA1",1,xFilial("SA1")+Padr(cClifor,TamSX3("A1_COD")[1])+Padr(cLoja,TamSX3("A1_LOJA")[1]),"A1_NOME")
                EndIf

            EndIf	
		Else //Faturamento
			SF2->(DbSetOrder(1))
            If SF2->(DbSeek(xFilial("SF2")+;
                    Padr(cNumDoc,TamSX3("F2_DOC")[1])+;
                    Padr(cSerie,TamSX3("F2_SERIE")[1])+;
                    Padr(cClifor,TamSX3("F2_CLIENTE")[1])+;
                    Padr(cLoja,TamSX3("F2_LOJA")[1]))) 
                                    
                If SF2->F2_TIPO $ "B|D"
                    cNome := Posicione("SA2",1,xFilial("SA2")+Padr(cClifor,TamSX3("A2_COD")[1])+Padr(cLoja,TamSX3("A2_LOJA")[1]),"A2_NOME")		                          
                Else
                    cNome := Posicione("SA1",1,xFilial("SA1")+Padr(cClifor,TamSX3("A1_COD")[1])+Padr(cLoja,TamSX3("A1_LOJA")[1]),"A1_NOME")
                EndIf

            EndIf		
		EndIf
	EndIf

Return cNome
