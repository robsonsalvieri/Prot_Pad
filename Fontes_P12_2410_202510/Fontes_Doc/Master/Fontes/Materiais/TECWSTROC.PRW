#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc}  MESA OPERACIONAL PO-UI

Classe WSRESTFUL - API Web Service RESTFUL - Planejamento Operacional - Troca de Efetivo

@Metodos WSMETHOD

@author     Serviços - Planejamento Operacional - Troca de Efetivo
@since      27/05/2024
/*/
//------------------------------------------------------------------------------
WSRESTFUL TECWSTROC DESCRIPTION "Planejamento Operacional - Troca de Efetivo"

	WSDATA cFil      AS STRING //Filial
	WSDATA cData     AS STRING //Data única
    WSDATA cAtend1   AS STRING //Atendente A - Troca de Efetivo
    WSDATA cAtend2   AS STRING //Atendente B - Troca de Efetivo

	//TROCA DE EFETIVO
	WSMETHOD GET tdaAtend    DESCRIPTION 'Retorna os atendentes da AA1'                     PATH "tdaAtend"		PRODUCES APPLICATION_JSON
	WSMETHOD GET vldAFunc	 DESCRIPTION 'Validação de Atendente A na Troca de Efetivo'     PATH "vldAFunc"    PRODUCES APPLICATION_JSON
	WSMETHOD GET vldBFunc	 DESCRIPTION 'Validação de Atendente B na Troca de Efetivo'     PATH "vldBFunc"    PRODUCES APPLICATION_JSON
	WSMETHOD GET tdaCommit	 DESCRIPTION 'Commit do modelo para troca de Efetivo'           PATH "tdaCommit"    PRODUCES APPLICATION_JSON

END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método GET de Atendentes para Troca de atendente

@author     Jack Junior
@since      27/05/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET tdaAtend WSRECEIVE cFil WSREST TECWSTROC
Local cAliasTmp := GetNextAlias()
Local oResponse := JsonObject():New()
Local cFilTMP   := ""
Local cJoinSRA  := ""
Local cQry      := ""
Local cWhereAA1 := ""
Local lMultFil  := IsMultFil()

cFilTMP := self:cFil

//Tratamento de multifilial:
cJoinSRA  := JoinSQL(lMultFil, "SRA.RA_FILIAL", "AA1", "SRA", cFilTMP, "JOIN")
cWhereAA1 := JoinSQL(lMultFil, "AA1.AA1_FILIAL", "AA1", "AA1", cFilTMP, "WHERE")
	
//-- Necessário utilizar FieldPos, pois o campo de bloqueio de registro é opcional para o cliente.
If AA1->(FieldPos('AA1_MSBLQL')) > 0
    cQry := " AND AA1.AA1_MSBLQL <> '1'"
Else
    cQry := " AND 1 = 1"
EndIf

cQry := sqlEmbeded(cQry)

BeginSql Alias cAliasTmp
    SELECT  
        AA1.AA1_FILIAL, AA1.AA1_CODTEC, AA1.AA1_NOMTEC, 
        AA1.AA1_CDFUNC, AA1.AA1_FUNFIL, AA1.AA1_ALOCA, 
        COALESCE(SRA.RA_TPCONTR,' ') RA_TPCONTR
    FROM %table:AA1% AA1
        LEFT JOIN %table:SRA% SRA //Funcionários
            ON %exp:cJoinSRA%
	        AND SRA.RA_MAT = AA1.AA1_CDFUNC
            AND SRA.%NotDel%
            %exp:cQry%
    WHERE
        %exp:cWhereAA1%
        AND AA1.%NotDel%
        %exp:cQry%
EndSql

DbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

oResponse['tdaAtend'] := {}

If (cAliasTmp)->(! Eof())
	While (cAliasTmp)->(! Eof())

        //Pega a descrição do combobox
        cAloca := AllTrim((cAliasTmp)->AA1_ALOCA) + '-' + AtDescCbox((cAliasTmp)->AA1_ALOCA, 'AA1_ALOCA')
        cTpContr := AllTrim((cAliasTmp)->RA_TPCONTR) + '-' + AtDescCbox((cAliasTmp)->RA_TPCONTR, 'RA_TPCONTR')

		//Monta o Objeto JSon a ser retornado:
		Aadd(oResponse['tdaAtend'], JsonObject():New())

		aTail(oResponse['tdaAtend'])['filial']    := AllTrim((cAliasTmp)->AA1_FILIAL)
		aTail(oResponse['tdaAtend'])['codTec']    := AllTrim((cAliasTmp)->AA1_CODTEC)
		aTail(oResponse['tdaAtend'])['nomeTec']   := EncodeUTF8(AllTrim((cAliasTmp)->AA1_NOMTEC))
		aTail(oResponse['tdaAtend'])['matricula'] := AllTrim((cAliasTmp)->AA1_CDFUNC)
		aTail(oResponse['tdaAtend'])['filRH']     := AllTrim((cAliasTmp)->AA1_FUNFIL)
		aTail(oResponse['tdaAtend'])['alocacao']  := EncodeUTF8(cAloca)
		aTail(oResponse['tdaAtend'])['tipoCont']  := EncodeUTF8(cTpContr)

		(cAliasTmp)->(DbSkip())
	Enddo
EndIf
(cAliasTmp)->(DbCloseArea())

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método GET de validação de Atendente A e retorno de campos do Modelo

@author     Jack Junior
@since      27/05/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET vldAFunc WSRECEIVE cFil, cData, cAtend1 WSREST TECWSTROC
Local oResponse := JsonObject():New()
Local cCodAtend := ""
Local dDate     := Stod("")
Local lRet      := .T.
Local cMsgRet   := ""
Local cNomeA    := ""
Local cFilA     := ""
Local cContrA   := ""
Local cLocalA   := ""
Local cDescA    := ""
Local cPostoA   := ""
Local cTurnoA   := ""
Local cSeqA     := ""
Local oModel    := Nil
Local oMdlDAT	:= Nil
Local oMdlATA	:= Nil

// Inicializa as variáveis de parâmetros recebidos
cCodAtend   := self:cAtend1
dDate       := Stod(self:cData)

oModel:= FWLoadModel("TECA190E")
oModel:SetOperation(3)
oModel:Activate()

oMdlDAT	:= oModel:GetModel("DATMASTER")
oMdlATA	:= oModel:GetModel("ATAMASTER")

lRet := lRet .And. oMdlDAT:SetValue("DAT_INI",dDate)
lRet := lRet .And. oMdlATA:SetValue("ATA_CODTEC",cCodAtend)

If lRet
    cNomeA  := EncodeUTF8(AllTrim(oMdlATA:GetValue("ATA_NOMTEC")))
    cFilA   := AllTrim(oMdlATA:GetValue("ATA_FILIAL"))
    cContrA := AllTrim(oMdlATA:GetValue("ATA_CONTRT"))
    cLocalA := AllTrim(oMdlATA:GetValue("ATA_LOCAL"))
    cDescA  := EncodeUTF8(AllTrim(oMdlATA:GetValue("ATA_NOMLOC")))
    cPostoA := AllTrim(oMdlATA:GetValue("ATA_POSTO"))
    cTurnoA := AllTrim(oMdlATA:GetValue("ATA_TURNO"))
    cSeqA   := AllTrim(oMdlATA:GetValue("ATA_SEQ"))
Else
    cMsgRet := oModel:GetErrorMessage()[6]
EndIf

oModel:DeActivate()

oResponse['vldAFunc'] := {}
//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['vldAFunc'], JsonObject():New())

aTail(oResponse['vldAFunc'])['retorno']     := lRet
aTail(oResponse['vldAFunc'])['mensagem']    := EncodeUTF8(cMsgRet)
aTail(oResponse['vldAFunc'])['nomeTecA']    := cNomeA
aTail(oResponse['vldAFunc'])['contrTecA']   := cContrA
aTail(oResponse['vldAFunc'])['localTecA']   := cLocalA
aTail(oResponse['vldAFunc'])['descLocTecA'] := cDescA
aTail(oResponse['vldAFunc'])['postoTecA']   := cPostoA
aTail(oResponse['vldAFunc'])['turnoTecA']   := cTurnoA
aTail(oResponse['vldAFunc'])['seqTecA']     := cSeqA

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método GET de validação de Atendente B e retorno de campos do Modelo

@author     Jack Junior
@since      27/05/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET vldBFunc WSRECEIVE cFil, cData, cAtend1, cAtend2 WSREST TECWSTROC
Local oResponse := JsonObject():New()
Local cCodAtend1:= ""
Local cCodAtend2:= ""
Local dDate     := Stod("")
Local lRet      := .T.
Local cMsgRet   := ""
Local cNomeB    := ""
Local cFilB     := ""
Local cContrB   := ""
Local cLocalB   := ""
Local cDescB    := ""
Local cPostoB   := ""
Local cTurnoB   := ""
Local cSeqB     := ""
Local cTurnoA   := ""
Local cSeqA     := ""
Local oModel    := Nil
Local oMdlDAT	:= Nil
Local oMdlATA	:= Nil
Local oMdlATB	:= Nil

// Inicializa as variáveis de parâmetros recebidos
cCodAtend1   := self:cAtend1
cCodAtend2   := self:cAtend2
dDate        := Stod(self:cData)

oModel:= FWLoadModel("TECA190E")
oModel:SetOperation(3)
oModel:Activate()

oMdlDAT	:= oModel:GetModel("DATMASTER")
oMdlATA	:= oModel:GetModel("ATAMASTER")
oMdlATB	:= oModel:GetModel("ATBMASTER")

lRet := lRet .And. oMdlDAT:SetValue("DAT_INI",dDate)
lRet := lRet .And. oMdlATA:SetValue("ATA_CODTEC",cCodAtend1)
lRet := lRet .And. oMdlATB:SetValue("ATB_CODTEC",cCodAtend2)

If lRet
    cNomeB  := EncodeUTF8(AllTrim(oMdlATB:GetValue("ATB_NOMTEC")))
    cFilB   := AllTrim(oMdlATB:GetValue("ATB_FILIAL"))
    cContrB := AllTrim(oMdlATB:GetValue("ATB_CONTRT"))
    cLocalB := AllTrim(oMdlATB:GetValue("ATB_LOCAL"))
    cDescB  := EncodeUTF8(AllTrim(oMdlATB:GetValue("ATB_NOMLOC")))
    cPostoB := AllTrim(oMdlATB:GetValue("ATB_POSTO"))
    cTurnoB := AllTrim(oMdlATB:GetValue("ATB_TURNO"))
    cSeqB   := AllTrim(oMdlATB:GetValue("ATB_SEQ"))
    cTurnoA := AllTrim(oMdlATA:GetValue("ATA_TURNO"))
    cSeqA   := AllTrim(oMdlATA:GetValue("ATA_SEQ"))
Else
    lError := .T.
    cMsgRet := oModel:GetErrorMessage()[6]
EndIf

oModel:DeActivate()

oResponse['vldBFunc'] := {}
//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['vldBFunc'], JsonObject():New())

aTail(oResponse['vldBFunc'])['retorno']     := lRet
aTail(oResponse['vldBFunc'])['mensagem']    := EncodeUTF8(cMsgRet)
aTail(oResponse['vldBFunc'])['nomeTecB']    := cNomeB
aTail(oResponse['vldBFunc'])['contrTecB']   := cContrB
aTail(oResponse['vldBFunc'])['localTecB']   := cLocalB
aTail(oResponse['vldBFunc'])['descLocTecB'] := cDescB
aTail(oResponse['vldBFunc'])['postoTecB']   := cPostoB
aTail(oResponse['vldBFunc'])['turnoTecB']   := cTurnoB
aTail(oResponse['vldBFunc'])['seqTecB']     := cSeqB
aTail(oResponse['vldBFunc'])['turnoTecA']   := cTurnoA
aTail(oResponse['vldBFunc'])['seqTecA']     := cSeqA

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} NOVA MESA OPERACIONAL PO-UI

Método GET de Commit do modelo TECA190E - Troca de Efetivo

@author     Jack Junior
@since      27/05/2024
/*/
//------------------------------------------------------------------------------
WSMETHOD GET tdaCommit WSRECEIVE cFil, cData, cAtend1, cAtend2 WSREST TECWSTROC
Local oResponse  := JsonObject():New()
Local cCodAtend1 := ""
Local cCodAtend2 := ""
Local dDate      := Stod("")
Local lRet       := .T.
Local cMsgRet    := ""
Local oModel    := Nil
Local oMdlDAT	:= Nil
Local oMdlATA	:= Nil
Local oMdlATB	:= Nil

//Inicializa as variáveis de parâmetros recebidos
cCodAtend1   := self:cAtend1
cCodAtend2   := self:cAtend2
dDate        := Stod(self:cData)

oModel:= FWLoadModel("TECA190E")
oModel:SetOperation(3)
oModel:Activate()

oMdlDAT	:= oModel:GetModel("DATMASTER")
oMdlATA	:= oModel:GetModel("ATAMASTER")
oMdlATB	:= oModel:GetModel("ATBMASTER")

lRet := lRet .And. oMdlDAT:SetValue("DAT_INI",dDate)
lRet := lRet .And. oMdlATA:SetValue("ATA_CODTEC",cCodAtend1)
lRet := lRet .And. oMdlATB:SetValue("ATB_CODTEC",cCodAtend2)

If lRet
    //Inicia o Commit dos dados para Troca dos Efetivos
    BEGIN TRANSACTION
    If oModel:VldData() .And. oModel:CommitData()
        lRet := .T.
        cMsgRet := "Troca de Efetivo realizada com sucesso."
    Else
        lRet := .F.
        cMsgRet := oModel:GetErrorMessage()[6]
    EndIf
    END TRANSACTION
Else
    cMsgRet := oModel:GetErrorMessage()[6]
EndIf

oModel:DeActivate()

oResponse['tdaCommit'] := {}
//Monta o Objeto JSon a ser retornado:
Aadd(oResponse['tdaCommit'], JsonObject():New())

aTail(oResponse['tdaCommit'])['retorno']  := lRet
aTail(oResponse['tdaCommit'])['mensagem'] := EncodeUTF8(cMsgRet)

//Retorna o JSon com informações solicitadas de acordo com filtros:
Self:SetResponse(oResponse:toJson())
oResponse:fromJson("{}")
oResponse := NIL

Return
