#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW032FAT
Consulta das faturas
@type API
@version V1 
@author Frank Zwarg Fuga
@since 09/10/2025
/*/
WSRESTFUL LOCW032FAT DESCRIPTION "Consulta das faturas"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para consulta das faturas</h2>" WSSYNTAX "/LOCW032FAT"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW032FAT
ITUP BUSINESS - TOTVS RENTAL
Consulta das faturas
@type API
@version V1 
@author Frank Zwarg Fuga
@since 03/10/2025
/*/
WSMETHOD POST WSSERVICE LOCW032FAT
Local bError := {||}
Local cBody	:= DecodeUtf8(::GetContent())
Local cRet := ""
Local cEnvLog := ""
Local aEmp := {}
Local cQuery := ""
Local cResult := ""
Local aBindParam := {}
Local cCliente := " "
Local cLoja := " "
Local cOrigem := " "
Local cTipo := " "
Local nQtd1 := 0
Local nVlr1 := 0
Local nQtd2 := 0
Local nVlr2 := 0
Local nQtd3 := 0
Local nVlr3 := 0
Local cDescGrua := " "
Local cNome := " "
Local cDataDe := ""
Local cDataAte := ""
Local cAprov := ""

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
                    If type("oJson:aprova") == "C"
						cAprov    := oJson:aprova
					EndIf

                    If empty(cCliente)
                        cRet := "O código do cliente é obrigatório para a emissão da consula. "
                    Else

                        LOCACLOSE("TRBFAT")

                        cQuery := "SELECT "
                        cQuery += "SC6.C6_ITEM, "
                        cQuery += "SC6.C6_UM, SC6.C6_VALOR, SC6.C6_ENTREG, SC6.C6_TES, " 
                        cQuery += "SC6.C6_NOTA, SC6.C6_SERIE, SC6.C6_DATFAT, "
                        cQuery += "FPY.FPY_FILIAL, FPY.FPY_CLIFAT, FPY.FPY_LOJFAT, FPY.FPY_PROJET, FPY_TIPFAT, "
                        cQuery += "FPY.FPY_OBRA, FPZ.FPZ_AS, FPZ.FPZ_PEDVEN, FPZ.FPZ_DTPED, FPZ.FPZ_DTINI, FPZ.FPZ_DTFIM, FPZ.FPZ_PROJET, FPZ.FPZ_ITEM, FPZ.FPZ_FROTA, "
                        cQuery += "FPZ.FPZ_PERLOC, FPZ.FPZ_GERAEM, FPZ.FPZ_ITMFPZ, FPZ.FPZ_QUANT, FPZ.FPZ_VALUNI, FPZ.FPZ_TOTAL, FPZ.FPZ_VIAGEM, "
                        cQuery += "FPZ.FPZ_DIAS, FPZ.FPZ_CLVL, FPZ.FPZ_OBRA, FPZ.FPZ_MEDICA, FPZ.FPZ_EXTRA, "
                        cQuery += "FPA.FPA_GRUA, FPA.FPA_TIPOSE, FPA.FPA_PRODUT, FPA_OBRA, "
                        cQuery += "SC5.C5_CONDPAG, SC5.C5_CLIENTE, SC5.C5_LOJACLI"
                        cQuery += "FROM "+RetSqlName("FPZ")+" FPZ "
                        cQuery += "INNER JOIN " + RetSQLName("FP0") + " FP0 ON "
                        cQuery += "FP0.FP0_FILIAL = '"+xFilial("FP0")+"' AND "
                        cQuery += "FP0.FP0_PROJET = FPZ.FPZ_PROJET AND "
                        cQuery += "FP0.D_E_L_E_T_ = ' ' "

                        cQuery += "INNER JOIN " + RetSQLName("FPY") + " FPY ON "
                        cQuery += "FPY.FPY_FILIAL = '"+xFilial("FPY")+"' AND "
                        cQuery += "FPY.FPY_PEDVEN = FPZ.FPZ_PEDVEN AND "
                        cQuery += "FPY.FPY_STATUS = '1 ' AND "
                        cQuery += "FPY.FPY_TIPFAT <> 'R' AND "
                        If !Empty(oJson:tipo_fat)
                            cQuery += "FPY.FPY_TIPFAT = ? AND "
                            aadd(aBindParam, oJson:tipo_fat)
                        EndIf
                        If cAprov == "A"
                            cQuery += " FPY.FPY_APROV = '1' AND "
                        EndIf
                        If cAprov == "R"
                            cQuery += " FPY.FPY_APROV = '2' AND "
                        EndIf
                        If cAprov == "P"
                            cQuery += " FPY.FPY_APROV = '' AND "
                        EndIf                        

                        cQuery += "FPY.D_E_L_E_T_ = ' ' "

                        cQuery += "INNER JOIN " + RetSQLName("SC6") + " SC6 ON "
                        cQuery += "SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND "
                        cQuery += "SC6.C6_NUM = FPZ.FPZ_PEDVEN AND "
                        cQuery += "SC6.C6_ITEM = FPZ.FPZ_ITEM AND "
                        cQuery += "SC6.C6_ENTREG >= ? AND SC6.C6_ENTREG <= ? AND "
                        aadd(aBindParam, cDataDe)
                        aadd(aBindParam, cDataAte)
                        cQuery += "SC6.D_E_L_E_T_ = ' ' "
                        
                        //cQuery += "AND SC6.C6_DATFAT <> '' "

                        cQuery += "INNER JOIN " + RetSQLName("SC5") + " SC5 ON "
                        cQuery += "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
                        cQuery += "SC5.C5_NUM = SC6.C6_NUM AND "
                        cQuery += "SC5.C5_NOTA = '' AND "
                        //cQuery += "SC5.C5_LIBEROK = '' AND "
                        cQuery += "SC5.C5_CLIENTE = ? AND "
                        aadd(aBindParam, cCliente)
                        If !empty(cLoja)
                            cQuery += "SC5.C5_LOJACLI = ? AND "
                            aadd(aBindParam, cLoja)
                        EndIf
                        
                        cQuery += "SC5.D_E_L_E_T_ = ' ' "

                        cQuery += "INNER JOIN " + RetSQLName("FPA") + " FPA ON "
                        cQuery += "FPA.FPA_FILIAL = '"+xFilial("FPA")+"' AND "
                        cQuery += "FPA.FPA_AS = FPZ.FPZ_AS AND "
                        cQuery += "FPA.D_E_L_E_T_ = ' ' "

                        cQuery += "ORDER BY FPY.FPY_PROJET "

                        cQuery := CHANGEQUERY(cQuery)
                        MPSysOpenQuery(cQuery,"TRBFAT",,,aBindParam)

                        If !TRBFAT->(Eof())
                            cResult += ', "faturas": ['
                            While !TRBFAT->(Eof())

                                nQtd1 := 0
                                nVlr1 := 0
                                nQtd2 := 0
                                nVlr2 := 0
                                nQtd3 := 0
                                nVlr3 := 0
                                cDescGrua := " "
                                cNome := " "

                                FP0->(dbSetOrder(1))
                                FP0->(dbSeek(xFilial("FP0")+TRBFAT->FPY_PROJET))

                                If !empty(TRBFAT->FPA_GRUA)
                                    ST9->(dbSetOrder(1))
                                    ST9->(dbSeek(xFilial("ST9")+TRBFAT->FPA_GRUA))
                                    cDescGrua := alltrim(ST9->T9_NOME)
                                EndIf

                                SA1->(dbSetOrder(1))
                                SA1->(dbSeek(xFilial("SA1")+TRBFAT->(C5_CLIENTE+C5_LOJACLI)))

                                SB1->(dbSetOrder(1))
                                SB1->(dbSeek(xFilial("SB1")+TRBFAT->FPA_PRODUT))
                                
                                cResult += ' {"filial": "'+TRBFAT->FPY_FILIAL+'",'
                                cResult += ' "projeto": "'+TRBFAT->FPY_PROJET+'",'
                                cResult += ' "obra": "'+TRBFAT->FPY_OBRA+'",'
                                cResult += ' "as": "'+TRBFAT->FPZ_AS+'",'
                                cResult += ' "bem": "'+TRBFAT->FPA_GRUA+'",'
                                cResult += ' "desbem": "'+cDescGrua+'",'
                                cResult += ' "cliente": "'+TRBFAT->C5_CLIENTE+'",'
                                cResult += ' "loja": "'+TRBFAT->C5_LOJACLI+'",'
                                cResult += ' "nome": "'+SA1->A1_NOME+'",'
                                cResult += ' "pedido": "'+TRBFAT->FPZ_PEDVEN+'",'
                                cResult += ' "periodo_loc": "'+TRBFAT->FPZ_PERLOC+'",'
                                cResult += ' "placa": "'+Posicione("ST9",1,xFilial("ST9")+TRBFAT->FPA_GRUA,"T9_PLACA")+'",'
                                cResult += ' "nome_obra": "'+Posicione("FP1",1,xFilial("FP1")+TRBFAT->FPA_PROJET+TRBFAT->FPA_OBRA,"FP1_NOMORI")+'",'
                                cTipo := " "
                                If TRBFAT->FPY_TIPFAT == "P"
                                    cTipo := "padrao"
                                ElseIf TRBFAT->FPY_TIPFAT == "M"
                                    cTipo := "medicao"
                                EndIf
                                cResult += ' "tipo": "'+cTipo+'",'  // extra, remessa, locacao

                                cOrigem := ""
                                If TRBFAT->FPZ_EXTRA == "N"
                                    If TRBFAT->FPA_TIPOSE == "L"
                                        cOrigem := "locacao"
                                    ElseIf TRBFAT->FPA_TIPOSE == "O"
                                        cOrigem := "outros"
                                    ElseIf TRBFAT->FPA_TIPOSE == "Z"
                                        cOrigem := "cobranca unica"
                                    ElseIf TRBFAT->FPA_TIPOSE == "M"
                                        cOrigem := "mao de obra"   
                                    ElseIf TRBFAT->FPA_TIPOSE == "S"
                                        cOrigem := "substituido" 
                                    EndIf
                                Else
                                    cOrigem := "custo extra"
                                EndIF
                                cResult += ' "origem": "'+cOrigem+'",' 

                                cResult += ' "item": "'+TRBFAT->FPZ_ITEM+'",'
                                cResult += ' "valor": '+alltrim(str(TRBFAT->C6_VALOR))+','
                                cResult += ' "emissao": "'+dtoc(stod(TRBFAT->C6_ENTREG))+'",'
                                cResult += ' "tes": "'+TRBFAT->C6_TES+'",'
                                cResult += ' "produto": "'+TRBFAT->FPA_PRODUT+'",'
                                cResult += ' "descricao": "'+SB1->B1_DESC+'",'
                                cResult += ' "nota": "'+TRBFAT->C6_NOTA+'",'
                                cResult += ' "serie": "'+TRBFAT->C6_SERIE+'",'
                                cResult += ' "faturamento": "'+dtoc(stod(TRBFAT->C6_DATFAT))+'",'
                                cResult += ' "condicao": "'+TRBFAT->C5_CONDPAG+'"'
                                cResult += ' }'
                                TRBFAT->(dbSkip())
                                If !TRBFAT->(Eof())
                                    cResult += ', '
                                EndIf
                            EndDo
                            cResult += '] '
                        else
                            cRet := "Não foram localizados registros válidos para a consulta. "
                        EndIf

                        LOCACLOSE("TRBFAT")

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

