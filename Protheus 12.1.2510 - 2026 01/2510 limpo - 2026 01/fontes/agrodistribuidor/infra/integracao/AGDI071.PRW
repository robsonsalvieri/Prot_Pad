#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDI071.CH"

#DEFINE SOLICITACAO_RECEITA_REPOSITORY agd.solicitacaoReceitaRepository.agdSolicitacaoReceitaRepository

/** {Protheus.doc} AGDI071
Rotina chamada através do Pedido de Venda - MATA410 com objetivo de criar no menu 
na acao relacionada a opcao para relacionar engenheiro e local descarte ao pedido
@type function
@version 12
@author agroDistribuidor
@since 09/09/2025
@return variant, nil
**/
Function AGDI071SM(paRotina)
	Local aRotina := paRotina

    If SUPERGETMV("MV_SIGAAGD", .F., .F.)
        aAdd(aRotina, {OemToAnsi(STR0001),"AGDI071({SC5->C5_FILIAL, SC5->C5_NUM })" ,0, 0, 0 ,NIL} )
    Endif

Return aRotina


/*/{Protheus.doc} AGDI071
Função de relacionamento de Pedido X agroDistribuidor
@type function
@version 12
@author agroDistribuidor
@since 09/09/2025
@return variant, nil
/*/
Function AGDI071(aInfo)
    Local aAreaAtu   := GetArea()
    Local aAreaSC5	 := SC5->(GetArea())
    Local oStmt      := FWPreparedStatement():New()
    Local cOperation := ""
    Local cAberto    := "N"
    Local cAchou     := "N"
    Local cQuery     := ""
	Local nQtd       := 0
    Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
    Local lPossuiSol 
    Local nRetView   := .F.

    If SUPERGETMV("MV_SIGAAGD", .F., .F.) .and. !Empty( aInfo )

        If !FWAliasInDic("NEQ")
            MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
            restarea(aAreaAtu)
            restarea(aAreaSC5)
            return .T.
        Endif
	
        //Verificar se pedido nao está encerrado
        dbSelectArea('SC5')
        SC5->(dbSetOrder(1)) //Filial + NUM
        cAberto := IIf( SC5->(dbSeek(aInfo[1] + aInfo[2])) .and. Empty(C5_NOTA),'S','N')

        lPossuiSol := existSolic(SC5->C5_NUM)

        dbSelectArea('NEQ')
        NEQ->(dbSetOrder(1)) //Filial + NUM
        cAchou := IIf( NEQ->(dbSeek(aInfo[1] + aInfo[2])),'S','N')

        If cAberto == "N"
            If cAchou == "N"
                restarea(aAreaAtu)
                restarea(aAreaSC5)
                return .T.
            Else
                cOperation := MODEL_OPERATION_VIEW
            Endif
        Else
            If cAchou == "S"
                if lPossuiSol
                    AGDHELP(STR0002,STR0003) //"Ajuda" //"Já existe uma solicitação de receituário gerada. Esta alteração não afetará as informações já enviadas na solicitação existente."
                Endif
                cOperation := MODEL_OPERATION_UPDATE
            Else
                cOperation := MODEL_OPERATION_INSERT
            Endif
        Endif

		oModel := FwLoadModel("AGDX040")
        oModel:SetOperation(cOperation)
		oModel:Activate()

        oNEQ := oModel:GetModel('AGDX040_NEQ')

        If cOperation == MODEL_OPERATION_INSERT
            oNEQ:SetValue("NEQ_FILIAL", aInfo[1])
            oNEQ:SetValue("NEQ_NUM"   , aInfo[2])

            //Atualizar se houver local descarte PADRÃO para filial do pedido
            dbSelectArea('NEO')
            NEO->(dbSetOrder(2))
            If NEO->(dbSeek(aInfo[1] + '1')) //1-Sim,2-Nao
                oNEQ:SetValue("NEQ_FILDES", NEO->NEO_FILIAL)
                oNEQ:SetValue("NEQ_CODDES", NEO->NEO_CODIGO)
            Endif

            //Atualizar se houver apenas 1 engenheiro cadastrado para filial do pedido
            cQuery := " SELECT COUNT(*) AS QTD FROM " + RetSqlName("NP8")
            cQuery += " WHERE D_E_L_E_T_ = '' AND NP8_FILIAL = ?"
            cQuery := ChangeQuery(cQuery)
            oStmt:SetQuery(cQuery)
            oStmt:SetString(1, aInfo[1])
            nQtd := MPSysExecScalar(oStmt:GetFixQuery(), "QTD")
            If nQtd == 1
                dbSelectArea('NP8')
                NP8->(dbSetOrder(1))
                If NP8->(dbSeek(aInfo[1]))
                    oNEQ:SetValue("NEQ_FILENG", NP8->NP8_FILIAL)
                    oNEQ:SetValue("NEQ_CODENG", NP8->NP8_CODIGO)
                Endif
            Endif
        Endif

        nRetView := FWExecView(oModel:GetDescription(), "AGDX040", cOperation, , , , 80, aEnableButtons, , , , oModel)

        if nRetView == 0 .and. cOperation == MODEL_OPERATION_UPDATE
            dbSelectArea('NEQ')
            NEQ->(dbSetOrder(1))
            If NEQ->(dbSeek(aInfo[1] + aInfo[2]))
                AGDI71UP(NEQ->NEQ_FILIAL, ;
                        NEQ->NEQ_NUM, ;
                        NEQ->NEQ_CODDES, ;
                        NEQ->NEQ_CODENG)
            EndIf
        EndIf

		oModel:DeActivate()
		oModel:Destroy()
		oModel := NIL
		FreeObj(oModel)

    Endif

	restarea(aAreaAtu)
    restarea(aAreaSC5)

Return .T.

/*/{Protheus.doc} existSolic
Verifica se existe solicitação de receituario para o pedido de vendas 
@type function
@version P12 
@author scheronlini.martins
@since 12/11/2025
@param cNumPed, character, Numero do Pedido
@return variant, return_.t. se existir solicitação, senão retorna .f.
/*/
Function existSolic(cNumPed)
	Local cAliQry    := GetNextAlias()
	Local cQuery     := ""
	Local oStatement := nil
    Local lPossuiSol := .F.

	cQuery := ""
	cQuery += " SELECT DISTINCT "
	cQuery += "   NET.NET_CODIGO "
	cQuery += " FROM " + RetSqlName("NET") + " NET "
	cQuery += " WHERE NET.NET_FILIAL = ? "
	cQuery += "   AND NET.NET_NUMPED = ? "
	cQuery += "   AND NET.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1, fwxFilial("NET"))
	oStatement:SetString(2, cNumPed)

	cQuery := oStatement:GetFixQuery()

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliQry, .T., .T.)
    
    (cAliQry)->(DBGoTop())
	if !(cAliQry)->(EoF())
		lPossuiSol := .T.
	Endif

	(cAliQry)->(DbCloseArea())

Return lPossuiSol

/*/{Protheus.doc} AGDI71UP
Atualiza solicitações relacionadas ao pedido quando dados do agronegócio são alterados
@type function
@version 12
@author beatriz.dantas
@since 05/01/2026
@param cFilPed, character, Filial do Pedido
@param cNumPed, character, Número do Pedido
@param cCodDes, character, Código do Local de Descarte
@param cCodEng, character, Código do Engenheiro
@return logical, .T. se processou com sucesso
/*/
Function AGDI71UP(cFilPed, cNumPed, cCodDes, cCodEng)
    Local aAreaNET    := NET->(GetArea())
    Local cAliQry     := GetNextAlias()
    Local cQuery      := ""
    Local oStatement  := Nil
    Local oModel      := Nil
    Local oNET        := Nil
    Local lRet        := .T.
    Local aStatus     := {"0", "4"} as array// 0=Pendente;1=Confirmada;2=Cancelada;3=Invalida;4=Incompleta                                                                      
    Local nParamOrder := 1 as numeric
    Local oRepository := nil as object 
    
    cQuery := " SELECT NET.R_E_C_N_O_ AS RECNET "
    cQuery += " FROM " + RetSqlName("NET") + " NET "
    cQuery += " WHERE NET.NET_FILIAL = ? "
    cQuery += "   AND NET.NET_NUMPED = ? "
    cQuery += "   AND NET.NET_STSSOL IN (?) " // Status: Incompleta, Pendente
    cQuery += "   AND NET.D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    
    oStatement := FWPreparedStatement():New()
    oStatement:SetQuery(cQuery)
    oStatement:SetString(nParamOrder++, cFilPed)
    oStatement:SetString(nParamOrder++, cNumPed)
    oStatement:SetIn(nParamOrder++, aStatus)
    
    cQuery := oStatement:GetFixQuery()
    dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliQry, .T., .T.)
    
    (cAliQry)->(DBGoTop())
    While !(cAliQry)->(EoF())
        
        dbSelectArea("NET")
        NET->(dbGoTo((cAliQry)->RECNET))

        oModel := FwLoadModel("AGDA040")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()
        
        oNET := oModel:GetModel('AGDA040_NET')

        If !Empty(cCodDes)
            oNET:SetValue("NET_LOCDES", cCodDes)
        EndIf
        
        If !Empty(cCodEng)
            oNET:SetValue("NET_CODENG", cCodEng)
        EndIf 
        
        If oModel:VldData()
            oModel:CommitData() 
        EndIf
        
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

        If NET->NET_STSSOL == "4" //4=Incompleta
            oRepository := SOLICITACAO_RECEITA_REPOSITORY():New(NET->NET_FILIAL + NET->NET_CODIGO)

            If !oRepository:isIncompleta()
                oRepository:atualizaStatus("1") // .F. = Registro está completo, muda status para 1=Confirmada. //dispara EAI automaticamente pos utiliza FwLoadModel("AGDA040").
            EndIf

            FwFreeObj(oRepository)
        EndIf
        
        (cAliQry)->(dbSkip())
    EndDo
    
    (cAliQry)->(DbCloseArea())
    RestArea(aAreaNET)
    
Return lRet
