#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW035SE1
Consulta dos titulos a receber
@type API
@version V1 
@author Frank Zwarg Fuga
@since 15/10/2025
/*/
WSRESTFUL LOCW035SE1 DESCRIPTION "Consulta os títulos a receber"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para consulta dos títulos a receber</h2>" WSSYNTAX "/LOCW035SE1"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW035SE1
ITUP BUSINESS - TOTVS RENTAL
Consulta das faturas
@type API
@version V1 
@author Frank Zwarg Fuga
@since 03/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW035SE1
Local bError := {||}
Local cBody	:= DecodeUtf8(::GetContent())
Local cRet := ""
Local cEnvLog := ""
Local aEmp := {}
Local cQuery := ""
Local cResult := ""
Local aBindParam := {}
Local cCliente := ""
Local cLoja := ""
Local cDataDe := ""
Local cDataAte := ""
Local aPedidos := {}
Local nX
Local lEncontrou := .F.
Local lExistPE1 := EXISTBLOCK("LOCW35P1")   
Local lExistPE2 := EXISTBLOCK("LOCW35P2")   
Local aAreaSE1

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

                    cCliente := oJson:cliente
                    cLoja := oJson:loja
                    cDataDe := oJson:datade
                    cDataAte := oJson:dataate

                    If empty(cCliente)
                        cRet := "O código do cliente é obrigatório para a emissão da consula. "
                    Else

                        LOCACLOSE("TRBSE1")

                        cQuery := "SELECT SE1.R_E_C_N_O_ REG "
                        cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
                        cQuery += "WHERE SE1.E1_CLIENTE = ? AND "
                        cQuery += "SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND "
                        aadd(aBindParam, cCliente)
                        If !empty(cLoja)
                            cQuery += "SE1.E1_LOJA = ? AND "
                            aadd(aBindParam, cLoja)
                        EndIf
                        cQuery += "SE1.E1_EMISSAO >= ? AND SE1.E1_EMISSAO <= ? AND "
                        aadd(aBindParam, cDataDe)
                        aadd(aBindParam, cDataAte)
                        cQuery += "SE1.D_E_L_E_T_ = ' ' AND "
                        cQuery += "SE1.E1_SALDO > 0 "
                        
                        cQuery += "ORDER BY REG "

                        cQuery := CHANGEQUERY(cQuery)
                        MPSysOpenQuery(cQuery,"TRBSE1",,,aBindParam)

                        If !TRBSE1->(Eof())
                            
                            cResult += ', "titulos": ['
                            While !TRBSE1->(Eof())

                                SE1->(dbGoto(TRBSE1->REG))

                                aPedidos := {}

                                SF2->(dbSetOrder(1))                    
                                If SF2->(dbSeek(xFilial(SF2)+SE1->(E1_NUM+E1_PREFIXO+E1_CLIENTE+E1_LOJA)))
                                    SC6->(dbSetOrder(4))
                                    If SC6->(dbSeek(xFilial("SC6")+SF2->(F2_DOC+F2_SERIE)))
                                        While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NOTA+C6_SERIE) == xFilial("SC6")+SF2->(F2_DOC+F2_SERIE)
                                            FPY->(dbSetOrder(1))
                                            If FPY->(dbSeek(xFilial("SC5")+SC6->C6_NUM))
                                                lEncontrou := .F.
                                                For nX := 1 to len(aPedidos)
                                                    If aPedidos[nX,1] == FPY->FPY_PEDVEN
                                                        lEncontrou := .T.
                                                        Exit
                                                    EndIf
                                                Next
                                                If !lEncontrou
                                                    aadd(aPedidos,{FPY->FPY_PEDVEN, FPY->FPY_PROJET, SC6->(Recno()) })
                                                EndIf
                                            EndIf
                                            SC6->(dbSkip())
                                        EndDo
                                    EndIf
                                EndIf

                                SA1->(dbSetOrder(1))
                                SA1->(dbSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

                                SB1->(dbSetOrder(1))
                                SB1->(dbSeek(xFilial("SB1")+TRBFAT->FPA_PRODUT))
                                
                                cResult += ' { '
                                cResult += ' "filial": "'+SE1->E1_FILIAL+'",'
                                cResult += ' "prefixo": "'+SE1->E1_PREFIXO+'",'
                                cResult += ' "titulo": "'+SE1->E1_NUM+'",'
                                cResult += ' "parcela": "'+SE1->E1_PARCELA+'",'
                                cResult += ' "tipo": "'+SE1->E1_TIPO+'",'
                                cResult += ' "emissao": "'+dtoc(SE1->E1_EMISSAO)+'",'
                                cResult += ' "dvenc": "'+dtoc(SE1->E1_VENCTO)+'",'
                                cResult += ' "dvencreal": "'+dtoc(SE1->E1_VENCREA)+'",'
                                cResult += ' "valor": '+str(SE1->E1_VALOR)+','
                                cResult += ' "portado": "'+SE1->E1_PORTADO+'",'
                                cResult += ' "boleto": "'+SE1->E1_BOLETO+'",'
                                cResult += ' "numbor": "'+SE1->E1_NUMBOR+'",'
                                cResult += ' "databor": "'+dtoc(SE1->E1_DATABOR)+'", '
                                cResult += ' "codcli": "'+SE1->E1_CLIENTE+'",'
                                cResult += ' "lojcli": "'+SE1->E1_LOJA+'",'
                                cResult += ' "nomcli": "'+SA1->A1_NOME+'",'
                                cResult += ' "saldo": '+str(SE1->E1_SALDO)+', '

                                // Ponto de entrada para complemento de campos
                                If lExistPE1
                                    aAreaSE1 := SE1->(GetArea())
                                    cResult += EXECBLOCK("LOCW35P1" , .T. , .T. )
                                    SE1->(RestArea(aAreaSE1))
                                EndIf

                                cResult += ' "projetos": [{'
                                If len(aPedidos) == 0
                                    cResult += ' "projeto": "'+""+'"'
                                else
                                    For nX := 1 to len(aPedidos)
                                        cResult += ' "projeto": "'+apedidos[nX,2]+'"'
                                        If lExistPE2
                                            aAreaSE1 := SE1->(GetArea())
                                            cResult += EXECBLOCK("LOCW35P2" , .T. , .T. , {aPedidos[nX,2],aPedidos[nX,3]} )
                                            SE1->(RestArea(aAreaSE1))
                                        EndIf
                                        If nX+1 <= len(aPedidos)
                                            cResult += ', '
                                        EndIf
                                    Next
                                EndIf
                                cResult += '}] '
                                cResult += ' }'

                                TRBSE1->(dbSkip())
                                If !TRBSE1->(Eof())
                                    cResult += ', '
                                EndIf
                            EndDo
                            cResult += '] '
                        else
                            cRet := "Não foram localizados registros válidos para a consulta. "
                        EndIf

                        LOCACLOSE("TRBSE1")

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

