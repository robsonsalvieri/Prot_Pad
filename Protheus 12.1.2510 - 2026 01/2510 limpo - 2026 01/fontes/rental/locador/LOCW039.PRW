#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW039FH1
Aprova/Reprova OS
@type API
@version V1 
@author Frank Zwarg Fuga
@since 28/10/2025
/*/
WSRESTFUL LOCW039FH1 DESCRIPTION "Aprovação/Reprova de OS"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para aprovação/reprova de OS</h2>" WSSYNTAX "/LOCW039FH1"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW039FH1
ITUP BUSINESS - TOTVS RENTAL
Aprova/Reprova OS
@type API
@version V1 
@author Frank Zwarg Fuga
@since 28/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW039FH1
Local bError := {||}
Local cBody	:= DecodeUtf8(::GetContent())
Local cRet := ""
Local cEnvLog := ""
Local aEmp := {}
Local cQuery := ""
Local cResult := ""
Local aBindParam := {}
Local cOrdem := ""
Local cAprova := ""
Local cCondicao := ""
Local lPrim := .T.
Local cCondUsar := ""
Local cDoc := ""
Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local lcVal := SUPERGETMV("MV_LOCX051",.F.,.T.)
Local cNomApr := Alltrim(UsrRetName(RetCodUsr()))
Local cCodApr := RetCodUsr()

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

                    cOrdem := oJson:ordem
                    cAprova := oJson:aprova
                    cCondicao := oJson:condicao

                    If empty(cOrdem) .or. (alltrim(cAprova)<>"A" .and. alltrim(cAprova)<>"R")
                        cRet := "Houve a falta de parâmetros para a localização do registro"
                    EndIf

                    If empty(cRet)

                        cOrdem  := alltrim(cOrdem)
                        cAprova := alltrim(cAprova)

                        LOCACLOSE("TRBFH1")

                        cQuery := "SELECT FH1.R_E_C_N_O_ REG " 
                        cQuery += "FROM "+RetSqlName("FH1")+" FH1 "
                        cQuery += "WHERE FH1.FH1_ORDEM = ? AND FH1.D_E_L_E_T_ = ' ' AND FH1.FH1_FILIAL = '" +xFilial("FH1") + "' "
                        cQuery += "AND FH1.FH1_STAPRO = '1' "
                        cQuery := CHANGEQUERY(cQuery)
                        aBindParam := {cOrdem}
                        MPSysOpenQuery(cQuery,"TRBFH1",,,aBindParam)

                        If !TRBFH1->(Eof())

                            // Validar se existe a condição de pagamento para todos os registros
                            If cAprova == "A"
                                If empty(cCondicao)
                                    TRBFH1->(dbGotop())
                                    While !TRBFH1->(Eof())
                                        FH1->(dbGoto(TRBFH1->REG))
                                        SA2->(DbSetOrder(1))
                                        SA2->(DbSeek(xFilial("SA2")+FH1->FH1_CODFOR+FH1->FH1_LOJFOR))   
                                        If Empty(SA2->A2_COND)
                                            cRet := "Falta informar a condição de pagamento."
                                            Exit
                                        EndIF             
                                        TRBFH1->(dbSkip())
                                    EndDo
                                EndIf
                            EndIf

                            If empty(cRet)
                                lPrim := .T.
                                TRBFH1->(dbGotop())
                                While !TRBFH1->(Eof())
                                    FH1->(dbGoto(TRBFH1->REG))

                                    // Rotina de reprova
                                    If cAprova == "R"
                                        RecLock("FH1", .F.)
                                        FH1->FH1_STAPRO := "3"
                                        FH1->(MsUnlock())
                                        TRBFH1->(dbSkip())
                                        Loop
                                    EndIf

                                    // Rotina de aprovação
                                    cCondUsar := cCondicao
                                    SA2->(DbSetOrder(1))
                                    SA2->(DbSeek(xFilial("SA2")+FH1->FH1_CODFOR+FH1->FH1_LOJFOR))   
                                    If !Empty(SA2->A2_COND)
                                        cCondUsar := SA2->A2_COND
                                    EndIf

                                    If lPrim
                                        aCabec := {}

                                        cDoc := GetSXENum("SC7","C7_NUM")
                                        ConfirmSX8()

                                        aadd(aCabec, {"C7_NUM", cDoc})
                                        aadd(aCabec, {"C7_EMISSAO", dDataBase})
                                        aadd(aCabec, {"C7_FORNECE", FH1->FH1_CODFOR})
                                        aadd(aCabec, {"C7_LOJA", FH1->FH1_LOJFOR})
                                        aadd(aCabec, {"C7_COND", cCondUsar})
                                        aadd(aCabec, {"C7_CONTATO", "AUTO"})
                                        aadd(aCabec, {"C7_FILENT", cFilAnt})
                                        lPrim := .F.
                                    EndIf

                                    aLinha := {}
                                    aadd(aLinha, {"C7_PRODUTO", FH1->FH1_CODIGO, Nil})
                                    aadd(aLinha, {"C7_QUANT", FH1->FH1_QUANTI, Nil})
                                    If FH1->FH1_VLRAUN <> 0
                                        aadd(aLinha, {"C7_PRECO", FH1->FH1_VLRAUN, Nil})
                                        aadd(aLinha, {"C7_TOTAL", FH1->FH1_VLRAUN * FH1->FH1_QUANTI, Nil})
                                    Else
                                        aadd(aLinha, {"C7_PRECO", FH1->FH1_VLRUNI, Nil})
                                        aadd(aLinha, {"C7_TOTAL", FH1->FH1_VLRUNI * FH1->FH1_QUANTI, Nil})  
                                    EndIf                      
                                    aadd(aLinha, {"C7_CC", Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_CCUSTO'), Nil})
                                    If lcVal
                                        aadd(aLinha, {"C7_CLVL", Posicione('STJ', 1, FWxFilial('STJ') + FH1->FH1_ORDEM, 'TJ_AS'), Nil})
                                    EndIf   
                                    aadd(aLinha, {"C7_OP", FH1->FH1_ORDEM+"OS"+"001", Nil})

                                    aadd(aItens,aLinha)

                                    TRBFH1->(dbSkip())
                                EndDo

                                If len(aCabec) > 0 .and. len(aItens) > 0 // aCabec estará em zerado quando for recusa
                                    MSExecAuto({|a,b,c,d,e,f,g,h| MATA120(a,b,c,d,e,f,g,h)},1,aCabec,aItens,3,.F.,,,)
                                    If SC7->(DbSeek(xFilial("SC7")+cDoc)) 
                                        If SC7->C7_NUM == cDoc
                                            TRBFH1->(dbGotop())
                                            While !TRBFH1->(Eof())
                                                FH1->(dbGoto(TRBFH1->REG))
                                                RecLock("FH1", .F.)
                                                If FH1->FH1_VLRAUN <> 0
                                                    FH1->FH1_VLRAUN := FH1->FH1_VLRAUN
                                                    FH1->FH1_VLRATO := FH1->FH1_VLRAUN * FH1->FH1_QUANTI
                                                Else    
                                                    FH1->FH1_VLRAUN := FH1->FH1_VLRUNI
                                                    FH1->FH1_VLRATO := FH1->FH1_VLRUNI * FH1->FH1_QUANTI  
                                                EndIf                    
                                                FH1->FH1_PEDCOM := cDoc
                                                FH1->FH1_DTAPRO := dDataBase
                                                FH1->FH1_HRAPRO := Time()
                                                FH1->FH1_STAPRO := "2"
                                                FH1->FH1_NOMAPR := cNomApr 
                                                FH1->FH1_CODAPR := cCodApr 
                                                FH1->(MsUnlock())
                                                TRBFH1->(dbSkip())
                                            EndDo
                                        EndIF
                                    Else
                                        cRet := "Ocorreu um problema na geracao do Pedido de Compra.A aprovacao automatica da OS nao foi concluida.Realize a aprovacao manualmente pela rotina LOCA101 - Aprovacao de OS e verifique o erro apresentado."
                                    EndIf                                         
                                EndIF
                            EndIF
                        Else
                            cRet := "Falha na localização do registro"
                        EndIf

                        LOCACLOSE("TRBFH1")

                        If empty(cRet)
                            If cAprova == "A"
                                cRet := "A aprovação foi executada com sucesso."
                                cResult := ',"Pedido":"'+cDoc+'"'
                            Else
                                cRet := "A reprovação foi executada com sucesso."
                            EndIF
                        EndIf

                    EndIf

                EndIf
            endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "OK "
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cResult+'}')) )
	

Return .T.

