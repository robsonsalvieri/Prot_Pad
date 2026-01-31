#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW044.PRW
ITUP BUSINESS - TOTVS RENTAL
Liberação da medição
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 02/12/2025
/*/

WSRESTFUL LOCW044 DESCRIPTION "Metodo para aprovar a medição - Rental"
	
	WSMETHOD POST DESCRIPTION "<h2>Metodo para aprovar a medição - Rental.</h2>" WSSYNTAX "/locw044"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW044
ITUP BUSINESS - TOTVS RENTAL
Liberação da medição - Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 02/12/2025
/*/

WSMETHOD POST WSSERVICE LOCW044
Local bError := {||}
Local cEnvLog := ""
Local cRet := ""
Local cBody := DecodeUtf8(::GetContent())
Local aEmp := {}
Local cHist
Local cPV := ""
Local cMedicao := ""
Local cSeq := ""
Local cPedido := ""
Local aAreaFQK 

Private oJson := Nil

	::SetContentType("application/json; charset=iso-8859-1")

	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1],aEmp[2])

				If FQK->(FIELDPOS("FQK_APROV")) == 0 .or. file("\SYSTEM\LOCW44X1.TXT")
					cRet := "ERRO - Faz-se necessario atualizar o dicionario de dados - falta o campo FQK_APROV"
				EndIf

                cMedicao := oJson:medicao
                cSeq := oJson:seq

                FQK->(dbSetOrder(1))
                If !FQK->(dbSeek(xFilial("FQK")+cMedicao+cSeq))
                    cRet := "ERRO - nao foi localizada a medicao"
                EndIf

                If empty(cRet)
                    If FQK->FQK_SITUAC <> "1"
                        cRet := "ERRO - A situacao da medicao nao aceita a aprovacao/reprovacao"
                    EndIf
                EndIf

                If empty(cRet)

                    If oJson:aprova == "A"

                        If oJson:gerpv == "S"
                            If !empty(FQK->FQK_NUMPV)
                                cRet := "ERRO - Ja existe um pedido de vendas para esta medicao"
                            EndIf
                        EndIf

                        If empty(cRet)
                            FQK->(RecLock("FQK",.F.))
                            FQK->FQK_SITUAC := "2"
                            FQK->FQK_APROV := "1"
                            FQK->FQK_DTAP := oJson:dtap
                            FQK->FQK_HAP := oJson:hap
                            FQK->FQK_NAP := oJson:nap

                            cHist := FQK->FQK_OBSAP + Chr(13) + Chr(10)
                            cHist += "Aprovacao da medicao."
                            cHist += "Data: "+oJson:dtap+" Hora: "+oJson:hap + Chr(13) + Chr(10)
                            cHist += "Responsavel: "+alltrim(oJson:nap) + Chr(13) + Chr(10)
                            cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
                            If oJson:gerpv == "N"
                                cHist += "Nao foi solicitado a geracao do pedido de vendas pela API" + Chr(13) + Chr(10)
                            Else

                                aAreaFQK := FQK->(GetArea())
                                LOCA24804C(.T.)
                                FQK->(RestArea(aAreaFQK))
                                cPedido := FQK->FQK_NUMPV

                                If empty(cPedido)
                                    cHist += "Houve uma falha na geracao do pedido de vendas" + Chr(13) + Chr(10)
                                Else
                                    cHist += "O pedido de vendas: "+alltrim(cPedido)+" foi gerado pela API" + Chr(13) + Chr(10)
                                EndIf
                            EndIf
                            FQK->FQK_OBSAP := cHist
                            FQK->(MsUnlock())
                        EndIf

                    Else

                        FQK->(RecLock("FQK",.F.))
                        FQK->FQK_APROV := "2"
                        FQK->FQK_DTAP := oJson:dtap
                        FQK->FQK_HAP := oJson:hap
                        FQK->FQK_NAP := oJson:nap

                        cHist := FQK->FQK_OBSAP + Chr(13) + Chr(10)
                        cHist += "Reprovacao da medicao."
                        cHist += "Data: "+oJson:dtap+" Hora: "+oJson:hap + Chr(13) + Chr(10)
                        cHist += "Responsavel: "+alltrim(oJson:nap) + Chr(13) + Chr(10)
                        cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
                        FQK->FQK_OBSAP := cHist
                        FQK->(MsUnlock())

                    EndIf
                
                EndIf

			Else
				cRet := "ERRO - nao foi possivel identificar a empresa"
			Endif
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK - "
		If oJson:aprova == "A"
            If !empty(cPedido)
			    cRet += "Aprovado a medicao - pedido de vendas: "+cPedido
            Else
                cRet += "Aprovado a medicao"
            EndIf
		Else
			cRet += "Reprovado a medicao"
		EndIf
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"}')) )
	
Return .T.

