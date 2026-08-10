#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDI071.CH"

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

    If SUPERGETMV("MV_SIGAAGD", .F., .F.) .and. !Empty( aInfo )

        If !FWAliasInDic("NEQ")
            MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
            restarea(aAreaAtu)
            restarea(aAreaSC5)
            return .T.
        Endif
	
        //Verificar se pedido esta aberto
        dbSelectArea('SC5')
        SC5->(dbSetOrder(1)) //Filial + NUM
        cAberto := IIf( SC5->(dbSeek(aInfo[1] + aInfo[2])) .and. Empty(C5_LIBEROK) .and. Empty(C5_NOTA) .and. Empty(C5_BLQ),'S','N')

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

        FWExecView(oModel:GetDescription(), "AGDX040", cOperation, , , , 80, aEnableButtons, , , , oModel)

		oModel:DeActivate()
		oModel:Destroy()
		oModel := NIL
		FreeObj(oModel)

    Endif

	restarea(aAreaAtu)
    restarea(aAreaSC5)

Return .T.
