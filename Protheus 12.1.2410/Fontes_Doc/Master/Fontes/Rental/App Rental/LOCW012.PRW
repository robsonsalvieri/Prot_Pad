#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} UltProjBem 
ITUP BUSINESS - TOTVS RENTAL
Retorna com o último projeto do Bem
Cod Review 30/09/2025 - Dennis Calabres
O objetivo desta API é:
Retornar onde está o movimento, no caso do bem não estar disponível.
Se ele estiver disponível retornar a AS em branco
/*/
WSRESTFUL UltProjBem DESCRIPTION "Metodo retorna o ultimo projeto e cliente do bem"

	WSMETHOD POST DESCRIPTION "<h2>Metodo retorna o ultimo projeto e cliente do bem.</h2>" WSSYNTAX "/UltProjBem"

END WSRESTFUL

/*/{PROTHEUS.DOC} UltProjBem 
ITUP BUSINESS - TOTVS RENTAL
Retorna com o último projeto do Bem
Cod Review 30/09/2025 - Frank Z Fuga
/*/
WSMETHOD POST WSSERVICE UltProjBem 
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local cDados	    := ""
Local cRet			:= ""
Local cFilContrato  := ""
Local cProjeto      := ""
Local cObra         := ""
Local cNrAS         := ""
Local cCentroCusto  := ""
Local cNrProposta   := ""
Local cCodCliente   := ""
Local cLojaCliente  := ""
Local cNomeCliente  := ""
Local cEmailCliente := ""
Local cStatusBem    := ""
Local aUltProjBem   := {}
Local lReserva      := .F.
Local cContador     := ""
Local cTemCont      := ""

Private oJson		:= Nil

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
                cRet := xAbreEnv(aEmp[1],aEmp[2])
                If Empty(cRet)
                    ST9->(DbSetOrder(1))
                    If ST9->(DbSeek(xFilial("ST9")+Alltrim(oJson:cCodBem)))

                        cStatusBem := Alltrim(ST9->T9_STATUS)
                        aUltProjBem := LOCW012A(oJson:cCodBem,cStatusBem,IIf(Type("oJson:CodForm") == "C",oJson:CodForm,NIL))
                        
                        cRet            := aUltProjBem[1]
                        cFilContrato    := aUltProjBem[2]
                        cProjeto        := aUltProjBem[3]
                        cObra           := aUltProjBem[4]
                        cNrAS           := aUltProjBem[5]
                        cCentroCusto    := aUltProjBem[6]
                        cNrProposta     := aUltProjBem[7]
                        cCodCliente     := aUltProjBem[8]
                        cLojaCliente    := aUltProjBem[9]
                        cNomeCliente    := aUltProjBem[10]
                        cEmailCliente   := aUltProjBem[11]
                        lReserva        := aUltProjBem[12]
                        cContador       := aUltProjBem[13]
                        cTemCont        := aUltProjBem[14]

                        If Empty(cRet)
                            cDados := ', "Dados": {'
                            cDados += ' "Filial": "'+cFilContrato+'",'
                            cDados += ' "Projeto": "'+cProjeto+'",'
                            cDados += ' "Obra": "'+cObra+'",'
                            cDados += ' "NrAS": "'+cNrAS+'",'
                            cDados += ' "CentroCusto": "'+cCentroCusto+'",'
                            cDados += ' "NrProposta": "'+cNrProposta+'",'
                            cDados += ' "CodCliente": "'+cCodCliente+'",'
                            cDados += ' "LojaCliente": "'+cLojaCliente+'",'
                            cDados += ' "NomeCliente": "'+cNomeCliente+'",'
                            cDados += ' "EmailCliente": "'+cEmailCliente+'",'
                            cDados += ' "StatusBem": "'+cStatusBem+'",'
                            cDados += ' "Contador": "'+cContador+'",'
                            cDados += ' "TemContador": "'+cTemCont+'",'
                            cDados += ' "Reserva": '+Iif(lReserva,"true","false")
                            cDados += '}'
                        EndIf
                    Else
                        cRet := "ERRO-Bem não encontrado."
                    EndIf
                EndIf
            endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"'+cDados+'}')) )
	
Return .T.

/*/{PROTHEUS.DOC} LOCW012A 
ITUP BUSINESS - TOTVS RENTAL
Função que busca o ultimo projeto que o bem está alocado
Cod Review 30/09/2025 - Frank Z Fuga
xUltProjBem - era o nome antigo desta função
/*/
Function LOCW012A(cCodBem,cStatusBem,cCodForm)
Local cRet          := ""
Local cQuery        := ""
Local cFilContrato  := ""
Local cProjeto      := ""
Local cObra         := ""
Local cNrAS         := ""
Local cCentroCusto  := ""
Local cNrProposta   := ""
Local cCodCliente   := ""
Local cLojaCliente  := ""
Local cNomeCliente  := ""
Local cEmailCliente := ""
Local lReserva      := .F.
Local cStatOld      := ""
Local cContador     := ""
Local cTemCont      := ""

Default cCodForm    := NIL

    cContador := AllTrim(Str(ST9->T9_POSCONT))
    cTemCont  := Alltrim(ST9->T9_TEMCONT)

    LOCACLOSE("TRBTQY")
    
    cQuery := " SELECT FQD_STATQY, FQD_STAREN "
    cQuery += " FROM " + RETSQLNAME("FQD") + " FQD "
    cQuery += " WHERE FQD_STATQY = ? AND FQD.D_E_L_E_T_ = ''"
    cQuery := CHANGEQUERY(cQuery)
    aBindParam := {cStatusBem}
    MPSysOpenQuery(cQuery,"TRBTQY",,,aBindParam)
    If TRBTQY->(EOF())
        cRet := "ERRO-Status do bem não localizado na tabela relacional FQD."
    Else
        cStatusBem := TRBTQY->FQD_STATQY
        cStatOld   := TRBTQY->FQD_STAREN
    EndIf

    TRBTQY->(dbCloseArea())

    If empty(cRet)

        // Se o Bem estiver como disponível retornar tudo em branco
        If cStatusBem == "00" .or. cStatusBem == "  "
            // O bem estará como livre para uso.
        Else
            // Em qualquer outo status vamos verificar se o último movimento é da FPA, ou da FPF
            // e retornaremos a AS correspondente.

            LOCACLOSE("TRBFQ4")

            cQuery := "SELECT FQ4_FILIAL, FQ4_PROJET, FQ4_AS, FQ4_LOG, FQ4_OBRA"
            cQuery += "FROM "+RetSqlName("FQ4")+" FQ4 "
            cQuery += "WHERE "
            cQuery += "FQ4_FILIAL = '"+xFilial("FQ4")+"' "
            cQuery += "AND FQ4.D_E_L_E_T_ = ' ' "
            cQuery += "AND FQ4_CODBEM = ? "
            cQuery += "ORDER BY FQ4.R_E_C_N_O_ DESC "
            cQuery := CHANGEQUERY(cQuery)
            aBindParam := {Alltrim(cCodBem)}
            MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)   
            
            If !TRBFQ4->(EoF())

                FPA->(dbSetOrder(3))
                FPA->(dbSeek(xFilial("FPA")+TRBFQ4->FQ4_AS))
                FP0->(dbSetOrder(1))
                FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))

                cFilContrato    := xFilial("FQ4")
                cProjeto        := Alltrim(TRBFQ4->FQ4_PROJET)
                cObra           := Alltrim(TRBFQ4->FQ4_OBRA)
                cNrAS           := Alltrim(TRBFQ4->FQ4_AS)
                cCentroCusto    := Alltrim(FPA->FPA_CUSTO)
                cNrProposta     := Alltrim(FP0->FP0_PROJET)
                cCodCliente     := Alltrim(FP0->FP0_CLI)
                cLojaCliente    := Alltrim(FP0->FP0_LOJA)
                cNomeCliente    := Alltrim(FP0->FP0_CLINOM)
                cEmailCliente   := Lower(Alltrim(FP0->FP0_CLIEMA))

                LOCACLOSE("TRBZ03")

                cQuery := "SELECT FQF_FILIAL, FQF_PROJET, FQF_AS FROM "+RetSqlName("FQF")+" FQF "
                cQuery += "WHERE FQF.D_E_L_E_T_ = ' ' "
                cQuery += "AND FQF_CODBEM = ? "
                cQuery += "AND FQF_PROJET = ? "
                cQuery += "AND FQF_AS = ? "
                cQuery += "ORDER BY FQF.R_E_C_N_O_ DESC"
                cQuery := CHANGEQUERY(cQuery)
                aBindParam := {Alltrim(cCodBem), cProjeto, cNrAS}
                MPSysOpenQuery(cQuery,"TRBZ03",,,aBindParam)

                If !TRBZ03->(EoF())
                    lReserva := .T.
                EndIf

                LOCACLOSE("TRBZ03")

            EndIF
        EndIf
    EndIf

Return ({cRet,;
    PadR(cFilContrato,TamSx3("FPA_FILIAL")[1]),;
    PadR(cProjeto,TamSx3("FPA_PROJET")[1]),;
    PadR(cObra,TamSx3("FPA_OBRA")[1]),;
    PadR(cNrAS,TamSx3("FPA_AS")[1]),;
    PadR(cCentroCusto,TamSx3("FPA_CUSTO")[1]),;
    PadR(cNrProposta,TamSx3("FP0_PROJET")[1]),;
    PadR(cCodCliente,TamSx3("FP0_CLI")[1]),;
    PadR(cLojaCliente,TamSx3("FP0_LOJA")[1]),;
    PadR(cNomeCliente,TamSx3("FP0_CLINOM")[1]),;
    PadR(cEmailCliente,TamSx3("FP0_CLIEMA")[1]),;
    lReserva,;
    PadR(cContador,TamSx3("T9_POSCONT")[1]),;
    PadR(cTemCont,TamSx3("T9_TEMCONT")[1]);
})
 


 
  