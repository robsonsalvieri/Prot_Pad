#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW043CE.PRW
ITUP BUSINESS - TOTVS RENTAL
Liberação do custo extra - Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 02/12/2025
/*/

WSRESTFUL LOCW043CE DESCRIPTION "Metodo para aprovar o custo extra - Rental"
	
	WSMETHOD POST DESCRIPTION "<h2>Metodo para aprovar o custo extra - Rental.</h2>" WSSYNTAX "/locw043ce"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW043CE
ITUP BUSINESS - TOTVS RENTAL
Liberação do custo extra - Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 02/12/2025
/*/

WSMETHOD POST WSSERVICE LOCW043CE
Local bError := {||}
Local cEnvLog := ""
Local cRet := ""
Local cBody := DecodeUtf8(::GetContent())
Local aEmp := {}
Local cQuery
Local aBindParam := {}
Local cHist
Local aAs := {} // filtro por AS
Local cPrjd // Projeto inicial
Local cPrja // Projeto final
Local aExecAuto := {} 
Local cPedido := ""
Local cPV := ""

Private oJson := Nil
Private lMsErroAuto := .F.
Private lAutoErrNoFile := .T.
Private aRetExec := {}

	::SetContentType("application/json; charset=iso-8859-1")

	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1],aEmp[2])

				If FPG->(FIELDPOS("FPG_APROV")) == 0 .or. file("\SYSTEM\LOCW43X1.TXT")
					cRet := "ERRO - Faz-se necessario atualizar o dicionario de dados - falta o campo FPG_APROV"
				EndIf

				If empty(cRet)
					cQuery := "SELECT R_E_C_N_O_ REG "
					cQuery += "FROM " + RETSQLNAME("FPG") + " FPG "
					cQuery += "WHERE FPG.FPG_SEQ = ? "
					aadd(aBindParam,alltrim(oJson:seq))
					cQuery += "AND FPG.D_E_L_E_T_ = ' ' "
					cQuery := CHANGEQUERY(cQuery)
					MPSysOpenQuery(cQuery,"TRBFPG",,,aBindParam)
					
					If TRBFPG->(Eof())
						cRet := "ERRO - Registro nao localizado"
					Else
						FPG->(dbGoto(TRBFPG->(REG)))
					EndIF
				
				EndIf

				If empty(cRet)

					If oJson:aprova == "A"
						If !empty(FPG->FPG_PVNUM)
							cRet := "ERRO - Ja foi faturado este custo extra nao pode ser recusado"
						Else
							FPG->(RecLock("FPG",.F.))
							FPG->FPG_APROV := "1"
							FPG->FPG_DTAP := ctod(oJson:data)
							FPG->FPG_HAP := oJson:hora
							FPG->FPG_NAP := oJson:aprovador
							FPG->FPG_COBRA := "S"

							aAs := {FPG->FPG_NRAS}
							cPrjd := FPG->FPG_PROJET
							cPrja := FPG->FPG_PROJET
							
							aadd(aExecAuto,.T.)
							aadd(aExecAuto,aRetExec)
							aadd(aExecAuto,"      ")
							aadd(aExecAuto,"ZZZZZZ")
							aadd(aExecAuto,"  ")
							aadd(aExecAuto,"ZZ")
							aadd(aExecAuto,"                ")
							aadd(aExecAuto,"ZZZZZZZZZZZZZZZZ")
							aadd(aExecAuto,"                              ")
							aadd(aExecAuto,"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
							aadd(aExecAuto,"   ")
							aadd(aExecAuto,"ZZZ")  
							aadd(aExecAuto,FPG->FPG_DTENT)
							aadd(aExecAuto,FPG->FPG_DTENT)
							aadd(aExecAuto,3)
							aadd(aExecAuto,ctod(""))
							aadd(aExecAuto,ctod("01/01/2045"))

							If oJson:gerpv == "S"
								MsExecAuto({|A,B,C,D,E,F,G| LOCA021(A,B,C,D,E,F,G)} ,;
								Nil , cPrjd , cPrja, aAs , .T. , 2 , aExecAuto)
							EndIf

							If len(aRetExec) > 0
								cPedido := aRetExec[1][1]
								cPV := " - Pedido de vendas: "+alltrim(cPedido)
							Else
								cPedido := ""
								cPV := " - Nao foi possivel gerar o PV"
							EndIf

							If oJson:gerpv == "N"
								cPV := ""
							EndIf

							If FPG->(FIELDPOS("FPG_OBSCUS")) > 0 
								cHist := FPG->FPG_OBSCUS + Chr(13) + Chr(10)
								cHist += "Aprovacao do custo extra."
								cHist += "Data: "+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10)
								cHist += "Responsavel: "+alltrim(oJson:aprovador) + Chr(13) + Chr(10)
								cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
								If oJson:gerpv == "N"
									cHist += "Nao foi solicitado a geracao do pedido de vendas pela API" + Chr(13) + Chr(10)
								Else
									If empty(cPedido)
										cHist += "Houve uma falha na geracao do pedido de vendas" + Chr(13) + Chr(10)
									Else
										cHist += "O pedido de vendas: "+alltrim(cPedido)+" foi gerado pela API" + Chr(13) + Chr(10)
									EndIf
								EndIf
								FPG->FPG_OBSCUS := cHist
							EndIf

							FPG->(MsUnlock())
						EndIF
					Else

						If !empty(FPG->FPG_PVNUM)
							cRet := "ERRO: Ja foi faturado este custo extra, nao pode ser aprovado novamente"
						Else

							FPG->(RecLock("FPG",.F.))
							FPG->FPG_APROV := "2"
							FPG->FPG_DTAP := ctod(oJson:data)
							FPG->FPG_HAP := oJson:hora
							FPG->FPG_NAP := oJson:aprovador
							FPG->FPG_COBRA := "R"

							If FPG->(FIELDPOS("FPG_OBSCUS")) > 0 
								cHist := FPG->FPG_OBSCUS + Chr(13) + Chr(10)
								cHist += "Reprovacao do custo extra."
								cHist += "Data: "+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10)
								cHist += "Responsavel: "+alltrim(oJson:aprovador) + Chr(13) + Chr(10)
								cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
								FPG->FPG_OBSCUS := cHist
							EndIf

							FPG->(MsUnlock())

						EndIf

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
			cRet += "Aprovado o custo extra"+cPv
		Else
			cRet += "Reprovado o custo extra"
		EndIf
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"}')) )
	
Return .T.

