#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW030CEXTRA
Retorno dos Custos Extras que estão pendentes de aprovação
@type API
@version V1 
@author Frank Zwarg Fuga
@since 03/10/2025
/*/
WSRESTFUL LOCW030CEXTRA DESCRIPTION "Metodo que retorna com a alista de custo extras que estão pendente de aprovacao"

	WSMETHOD POST DESCRIPTION "<h2>Metodo que retorna com a alista de custo extras que estão pendente de aprovacao</h2>" WSSYNTAX "/LOCW030CEXTRA"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW030CEXTRA 
ITUP BUSINESS - TOTVS RENTAL
Retorna com a lista de custo extras que estão pendentes de aprovação
Se cSeq e cProjeto for recebido pelo método, indica que iremos aprovar e gerar o PV
Se cSeq estiver em branco, indica que iremos gerar a lista dos custos extras e retornar no método
@type API
@version V1 
@author Frank Zwarg Fuga
@since 03/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW030CEXTRA 
Local bError     := {||}
Local cBody	     := DecodeUtf8(::GetContent())
Local cRet       := ""
Local cEnvLog    := ""
Local aEmp       := {}
Local cQuery     := ""
Local cResult    := ""
Local cDtIni     := ""
Local cDtfim     := ""
Local cProjeto   := ""
Local aBindParam := {}
Local cSeq       := ""
Local cCobra     :=  ""
Local cCliente   := ""
Local cLoja      := ""
Local cLink      := ""// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026 
Local nI         := 0// DSERLOCA-10464 - Dennis Calabrez  - 09/02/2026
Local aParam     := {}// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
Local lLog       := .F.// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
Local cMsg       := ""// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
Local nContLink  := 0// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026

Private oJson    := Nil

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
            aEmp := xVerEmp(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
            lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa já existente.")// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
			If lLog// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
                cRet := xAbreEnv(aEmp[1],aEmp[2])
                If Empty(cRet)

                    LOCACLOSE("TRBFPG")

                    cDtIni := oJson:cdtini
                    cDtFim := oJson:cdtfim
                    cProjeto := oJson:cprojeto
                    cCobra   := Upper(oJson:ccobra) // Dserloca 10396 - Circenis - 23/01/2026 Novo parametro de Cobra (S/N)
                    cCliente := oJson:cod_cli
                    cLoja    := oJson:loj_cli    
                    cSeq     := oJson:cseq

                    cQuery := "SELECT "
                    cQuery += "FPG_FILIAL, " //Filial
                    cQuery += "FPG_PROJET, " //Projeto
                    cQuery += "FPG_OBRA, "   //Obra
                    cQuery += "FPG_NRAS, "   //AS
                    cQuery += "FPG_CUSTO, "  //Centro de custo
                    cQuery += "FPG_CODDES, " //Código do Equipamento
                    cQuery += "FPG_PRODUT, " //Código do Produto
                    cQuery += "FPG_QUANT, "  //Quantidade
                    cQuery += "FPG_VLUNIT, " //Valor Unitário
                    cQuery += "FPG_VALOR, "  //Valor Qtd x Unitário
                    cQuery += "FPG_TAXAP, "  //Taxa Percentual
                    cQuery += "FPG_TAXAV, "  //Taxa Valor
                    cQuery += "FPG_VALTOT, " //Valor com Taxa
                    cQuery += "FPG_COBRA, "  //Identifica se está aprovado
                    cQuery += "FPG_DTENT, "  //Data da movimentação
                    cQuery += "FPG_DTPAG, "  //Data do pagamento
                    cQuery += "FPG_STATUS, " //1=Pendente, 2=Faturado
                    cQuery += "FPG_COBRAT, " //Identifica se Cobra Taxa
                    cQuery += "FPG_JUNTO, "  //Identifica se cobra junto com a locação
                    cQuery += "FPG_NATURE, " //Identifica a natureza
                    cQuery += "FPG_SEQ, "    //Código da movimentação
                    cQuery += "COALESCE(CAST(SUBSTRING(FPG_LINK, 1, 4000) AS VARCHAR(4000)), '') OBS, " //DSERLOCA-9266 - Dennis - 26/11/25
                    cQuery += "FPG_PVNUM "  //Código do pedido de vendas
                    cQuery += "FROM " + RETSQLNAME("FPG") + " FPG "
                    cQuery += " INNER JOIN " + RETSQLNAME("FP0") + " FP0 " // Dserloca 10396 - Circenis - 23/01/2026 Filtragem pelo cliente
                    cQuery += " ON FP0_FILIAL = '"+xFilial("FP0")+"'"
                    If !empty(cProjeto)
                        cQuery += "AND FP0_PROJET = ? "
                        aadd(aBindParam,cProjeto)
                    EndIf
                    If !empty(cCliente)
                        cQuery += "AND FP0_CLI = ? "
                        aadd(aBindParam,cCliente)
                    EndIf
                    If !empty(cLoja)
                        cQuery += "AND FP0_LOJA = ? "
                        aadd(aBindParam,cLoja)
                    EndIf
                    cQuery += "  AND FP0.D_E_L_E_T_ = ' '"
                    cQuery += "WHERE FPG_FILIAL = '"+xFilial("FPG")+"' AND FPG.D_E_L_E_T_ = ' ' AND "
                    cQuery += "FPG_PVNUM = ' ' AND FPG_VALTOT > 0 AND "
                    cQuery += "FPG_DTENT >= ? AND FPG_DTENT <= ? "
                    aadd(aBindParam,cDtIni)
                    aadd(aBindParam,cDtFim)
                    cQuery += "AND FPG_PROJET = FP0_PROJET "
                    If !empty(cCobra) // Dserloca 10396 - Circenis - 23/01/2026 Novo parametro de Cobra (S/N)
                        cQuery += "AND FPG_COBRA = ? "
                        aadd(aBindParam, cCobra)
                    EndIf  
                    If !empty(cSeq) // DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
                        cQuery += "AND FPG_SEQ = ? "
                        aadd(aBindParam, cSeq)
                    EndIf  
                    If !empty(cProjeto) // DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
                        cQuery += "AND FPG_PROJET = ? "
                        aadd(aBindParam, cProjeto)
                    EndIf                                           
                    cQuery := CHANGEQUERY(cQuery)
                    
                    MPSysOpenQuery(cQuery,"TRBFPG",,,aBindParam)
                    // DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
                    If TRBFPG->(EOF())
						cRet := "204 - "
						cMsg := " A requisicao foi bem-sucedida, mas nao ha conteudo para retornar no corpo da resposta, verifique os parametros"
                    Else
                        cResult += ', "custos": ['
                        While !TRBFPG->(Eof())
                            cLink := TRBFPG->OBS
                            FPA->(dbSetOrder(3))
                            FPA->(dbSeek(xFilial("FPA")+TRBFPG->FPG_NRAS))

                            FP0->(dbSetOrder(1))
                            FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))

                            SA1->(dbSetOrder(1))
                            SA1->(dbSeek(xFilial("SA1")+FP0->(FP0_CLI+FP0_LOJA)))

                            SB1->(dbSetOrder(1))
                            SB1->(dbSeek(xFilial("SB1")+TRBFPG->FPG_PRODUT))

                            ST9->(dbSetOrder(1))
                            ST9->(dbSeek(xFilial("ST9")+TRBFPG->FPG_CODDES))

                            cResult += '{'
                            cResult += '"filial": "'+xFilial("FPG")+'", '
                            cResult += '"projeto": "'+alltrim(TRBFPG->FPG_PROJET)+'", '
                            cResult += '"obra": "'+alltrim(TRBFPG->FPG_OBRA)+'", '
                            cResult += '"as": "'+alltrim(TRBFPG->FPG_NRAS)+'", '
                            cResult += '"centrocusto": "'+alltrim(TRBFPG->FPG_CUSTO)+'", '
                            cResult += '"bem": "'+alltrim(TRBFPG->FPG_CODDES)+'", '
                            cResult += '"cliente": "'+alltrim(FP0->FP0_CLI)+'", '
                            cResult += '"loja": "'+alltrim(FP0->FP0_LOJA)+'", '
                            cResult += '"nome": "'+alltrim(SA1->A1_NOME)+'", '
                            cResult += '"descbem": "'+alltrim(ST9->T9_NOME)+'", '
                            cResult += '"produto": "'+alltrim(TRBFPG->FPG_PRODUT)+'", '
                            cResult += '"descprod": "'+alltrim(SB1->B1_DESC)+'", '
                            cResult += '"qtd": '+alltrim(str(TRBFPG->FPG_QUANT))+', '
                            cResult += '"vlrunit": '+alltrim(str(TRBFPG->FPG_VLUNIT))+', '
                            cResult += '"TaxaP": '+alltrim(str(TRBFPG->FPG_TAXAP))+', '
                            cResult += '"taxav": '+alltrim(str(TRBFPG->FPG_TAXAV))+', '
                            cResult += '"valtot": '+alltrim(str(TRBFPG->FPG_VALTOT))+', '
                            cResult += '"cobra": "'+TRBFPG->FPG_COBRA+'", '
                            cResult += '"dtent": "'+alltrim(TRBFPG->FPG_DTENT)+'", '
                            cResult += '"dtpago": "'+alltrim(TRBFPG->FPG_DTPAG)+'", '
                            cResult += '"status": "'+TRBFPG->FPG_STATUS+'", '
                            cResult += '"cobrat": "'+TRBFPG->FPG_COBRAT+'", '
                            cResult += '"junto": "'+TRBFPG->FPG_JUNTO+'", '
                            cResult += '"nature": "'+TRBFPG->FPG_NATURE+'", '
                            cResult += '"seq": "'+TRBFPG->FPG_SEQ+'",'
                            cResult += '"links": ['
                            // DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
                            If !Empty(cLink)
                                aParam := StrTokArr(cLink, ";")
                                nContLink := 0
                                For nI := 1 to len(aParam)
                                    If !Empty(AllTrim(aParam[nI]))
                                        If nContLink > 0
                                            cResult += ','
                                        EndIf
                                        cResult += '"'+STRTRAN(STRTRAN(AllTrim(aParam[nI]),CHR(13),""),CHR(10),"")+'"'
                                        nContLink++
                                    EndIf
                                Next
                            EndIf
                            cResult += '],'
                            cResult += '"pv": "'+TRBFPG->FPG_PVNUM+'" '
                            cResult += '}'
                            TRBFPG->(dbSkip())
                            If !TRBFPG->(Eof())
                                cResult += ', '
                            EndIf

                        EndDo
                        cResult += ']'
                    EndIf

                    LOCACLOSE("TRBFPG")
                    
                EndIf
			Else
				cRet := "401 - "// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
				cMsg := "Credenciais de autenticacao invalidas ou ausentes, verifique o CNPJ da empresa Protheus"	                
            Endif

		EndIf
	End Sequence

	If Empty(cRet)
		cRet := "200 - "// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
		cMsg := "Recurso encontrado"
	EndIf                              
    

    ::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cResult+'}')) )// DSERLOCA-10464 - Dennis Calabrez - 09/02/2026
	
Return .T.

/*/{Protheus.doc} LOCW030A
Aprovação do custo extra e geração do pedido de vendas
@type function
@version v.1
@author Frank Zwarg Fuga
@since 10/08/2025
/*/
Function LOCW030A(cProjeto, cSeq)
Local cRet := ""
Local cResult := ""
Local lLocaliza := .F.
Local lLibera := .F.
Local lGeraPV := .F.
Local aExecAuto := {}
Local aAs := {}
Local aAreaFPG 

Private aRetExec := {}

    If Empty(cRet)
		cRet := "OK "
	EndIf                              

    FPG->(dbSetOrder(1))
    If FPG->(dbSeek(xFilial("FPG")+cProjeto))
        While !FPG->(Eof()) .and. FPG->(FPG_FILIAL+alltrim(FPG_PROJET)) == xFilial("FPG")+alltrim(cProjeto)
            If FPG->FPG_SEQ == cSeq
                lLocaliza := .T.

                // Passo 1 - Liberar o custo extra
                If FPG->FPG_COBRA == "S" .or. !empty(FPG->FPG_PVNUM)
                    cRet := "Este custo extra já foi liberado anteriormente."
                Else
                    lLibera := .T.
                    FPG->(RecLock("FPG",.F.))
                    FPG->FPG_COBRA := "S"
                    FPG->(MsUnlock())
                EndIF

                // Passo 2 - Gerar o faturamento
                If lLibera

                    FP0->(dbSetOrder(1))
                    FP0->(dbSeek(xFilial("FP0")+cProjeto))

                    aadd(aExecAuto, .T.)
                    aadd(aExecAuto, aRetExec)
                    aadd(aExecAuto, FP0->FP0_CLI)
                    aadd(aExecAuto, FP0->FP0_LOJA)
                    aadd(aExecAuto, FP0->FP0_CLI)
                    aadd(aExecAuto, FP0->FP0_LOJA)
                    aadd(aExecAuto,"                ")
                    aadd(aExecAuto, "ZZZZZZZZZZZZZZZZ")
                    aadd(aExecAuto, "                              ")
                    aadd(aExecAuto, "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
                    aadd(aExecAuto, FPG->FPG_OBRA)
                    aadd(aExecAuto, FPG->FPG_OBRA)  
                    aadd(aExecAuto, FPG->FPG_DTENT)
                    aadd(aExecAuto, FPG->FPG_DTENT)
                    aadd(aExecAuto, 3)
                    aadd(aExecAuto, ctod(""))
                    aadd(aExecAuto, ctod("01/01/2045"))

                    aadd(aAs,{FPG->FPG_AS})

                    aAreaFPG := FPG->(GetArea())

                    MSEXECAUTO({|A,B,C,D,E,F,G| LOCA021(A,B,C,D,E,F,G)},;
				    Nil, cProjeto, cProjeto, aAs, .T. , 2 , aExecAuto)

                    FPG->(RestArea(aAreaFPG))

                    If !empty(FPG->FPG_PVNUM)
                        lGeraPV := .T.
                    EndIf

                EndIf

                Exit
            EndIf
            FPG->(dbSkip())
        EndDo
    EndIf

    If !lLocaliza
        cRet := "O projeto informado não foi localizado."
    Else
        If !lLibera
            cRet := "Não foi possível fazer a liberação do custo extra."
        Else
            If !lGeraPV
                cRet := "Não foi possível gerar o pedido de venda."
            Else
                cResult += ', "pedido": {'
                cResult += ' "projeto": "'+cProjeto+'",'
                cResult += ' "pedido": "'+FPG->FPG_PVNUM+'"'
                cResult += ' }'
            EndIF
        EndIf
    EndIf
    
Return {cRet, cResult}
