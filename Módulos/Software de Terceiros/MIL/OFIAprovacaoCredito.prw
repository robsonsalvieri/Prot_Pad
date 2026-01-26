#include 'totvs.ch'

/*/{Protheus.doc} OFIAprovacaoCredito
	Classe para as regras de negócio de aprovação de crédito
	@author Renan Migliaris
	@since 10/04/2025
	@version version
	/*/

Class OFIAprovacaoCredito from LongNameClass
    public data TotNf
    public data numOrc
    public data motivo
    public data statusAnt
    public data statusNovo
    public data filial
    public data nomeUsuario
    public data nomeTecnico
    public data alcada
    public data funName
    public data libVOO

    method new(cNumOrc, cMotivo, cFunName)
    method checkAlcada(cOrigem)
    method validarFase()
    method updateStatusOrcamento()
    method gravarLiberacaoCredito()
    method gravaLiberacaoCreditoOfixa019()
    method gravarLog()
    method _validaAlcada()
EndClass

method new(cNumOrc, cMotivo, cFunName, cLibVOO) class OFIAprovacaoCredito
	::numOrc := cNumOrc
    ::libVOO := cLibVOO
	::motivo := decodeUtf8(cMotivo)
    ::funName := cFunName

    DbSelectArea("VAI")
    DbSetOrder(4)
    DbSeek(xFilial("VAI")+__cUserID)
    ::nomeTecnico := VAI->VAI_NOMTEC
    ::nomeUsuario := VAI->VAI_NOMUSU
    ::alcada := VAI->VAI_ALLBCR
    VAI->(dbCloseArea())
return self

method checkAlcada(cOrigem) class OFIAprovacaoCredito
    if cOrigem == "VS1"
        DbSelectArea("VS1")
        DbSetOrder(1)
        if !dbSeek(xFilial("VS1") + ::numOrc)
            return .f.
        endif
        ::totNf := VS1->VS1_VTOTNF
        ::filial := VS1->VS1_FILIAL
        VS1->(dbCloseArea())
    elseif cOrigem == "VSW"
        DbSelectArea(cOrigem)
        DbSetOrder(3)
        if !dbSeek(xFilial(cOrigem) + ::numOrc)
            return .f.
        endif
        ::totNf := VSW->VSW_VALCRE
        ::filial := VSW->VSW_FILIAL
    endif
return ::_validaAlcada()

method _validaAlcada() class OFIAprovacaoCredito
    local lRet := .t.

    if ::alcada > 0
        if  ::alcada < ::totNf
            lret := .f.
        endif
    endif
return lRet

method validarFase() class OFIAprovacaoCredito
    local cFases := OI001GETFASE(::numOrc)
    local nPos := At("3", cFases)
    ::statusNovo := SubStr(cFases, nPos + 1, 1)
return .t.


method updateStatusOrcamento() class OFIAprovacaoCredito
    DbSelectArea("VS1")
    DbSetOrder(1)
    dbSeek(xFilial("VS1") + ::numOrc)
    reclock("VS1", .f.)
    ::statusAnt := VS1->VS1_STATUS
    VS1->VS1_STATUS := ::statusNovo
    msUnlock()

    if ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
        OA3700011_Grava_DTHR_Status_Orcamento(::numOrc, ::statusNovo, "APROVACAO")
    endif
return

method gravarLiberacaoCredito() class OFIAprovacaoCredito
    local oJson := JsonObject():new()

    SetFunName(::funName)

    oJson["funName"] := ::funName
    oJson["nomeTecnico"] := ::nomeTecnico
    oJson["nomeUsuario"] := ::nomeUsuario
    oJson["numeroOrcamento"] := ::numOrc
    oJson["motivo"] := ::motivo

    OF016001J_GravaLiberacao(oJSon)
return

method gravarLog() class OFIAprovacaoCredito
    if FindFunction("FM_GerLog")
        FM_GerLog("F", ::NumOrc, , ::filial, ::statusAnt)
    endif
return

method gravaLiberacaoCreditoOfixa019() class OFIAprovacaoCredito
    local lRet := .t.
    Local cQAlVSW := "SQLVSW"
    local oWsData := JsonObject():new()
    local cQuery := ''
    Local cFinalQuery := ''
    Local oStatement := FWPreparedStatement():New()

	cQuery := "SELECT VSW_USULIB, VSW_DTHLIB, VSW_MOTIVO, R_E_C_N_O_ AS VSWRECNO"
	cQuery += "  FROM "+RetSqlName("VSW")
	cQuery += " WHERE VSW_LIBVOO = ?"
	cQuery += "   AND D_E_L_E_T_ = ' '"

    //Define a consulta e os parâmetros
	oStatement:SetQuery(cQuery)
	oStatement:SetString(1,::libVOO)
	cFinalQuery := oStatement:GetFixQuery()
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cFinalQuery ), cQAlVSW , .F., .T. )

    oWsData["recno"] := (cQAlVSW)->VSWRECNO
    oWsData["motivo"] := decodeUtf8(::motivo)
    oWsData["nomeUsuario"] := ::nomeUsuario

    (cQAlVSW)->(dbCloseArea())
    OF019002J_GravaLibCredito(oWsData)
return lRet
