#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "FWEVENTVIEWCONSTS.CH"

/*/{PROTHEUS.DOC} LOCW041PV.PRW
ITUP BUSINESS - TOTVS RENTAL
Liberação do PV - Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 26/11/2025
/*/

WSRESTFUL LOCW041PV DESCRIPTION "Metodo para aprovar os pedidos de venda - Rental"
	
	WSMETHOD POST DESCRIPTION "<h2>Metodo para aprovar os pedidos de venda - Rental.</h2>" WSSYNTAX "/locw041pv"

END WSRESTFUL


/*/{PROTHEUS.DOC} LOCW041PV
ITUP BUSINESS - TOTVS RENTAL
Liberação do PV - Rental
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 26/11/2025
/*/

WSMETHOD POST WSSERVICE LOCW041PV
Local bError    := {||}
Local cEnvLog   := ""
Local cRet	    := ""
Local cBody	    := DecodeUtf8(::GetContent())
Local cHist     := ""
Local lCorreto  := .F.
Local aEmp      := {}
Local cOpera    := ""
Local cEventID 	:= "096" // ID do EventViewer - ISSUE DSERLOCA-10044 - Frank 06/01/2026
Local cMessagem	:= " " // Mensagem utilizada no EventViewer - ISSUE DSERLOCA-10044 - Frank 06/01/2026

Private oJson  := Nil
Private lTransf
Private lLiber

	::SetContentType("application/json; charset=iso-8859-1")

	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1],aEmp[2])

				If FPY->(FIELDPOS("FPY_APROV")) == 0 .or. FPY->(FIELDPOS("FPY_HIST")) == 0 .or. file("\SYSTEM\LOCW41X1.TXT")
					cRet := "Faltam no dicionário os campos FPY_APROV e FPY_HIST"
				EndIf

				If empty(oJson:pv)
					cRet := "Faltou informar o codigo do pedido de vendas"
				EndIf

				//Issue: DSERLOCA-9873 - Leonardo Pacheco Fuga - 12/12/2025 - Novo tipo pendente
				If !Empty(oJson:aprova) .and. oJson:aprova <> "A" .and. oJson:aprova <> "R" .and. oJson:aprova <> "P"
					cRet := "Identificacao da aprovacao invalida. Use: A=Aprovado, R=Reprovado, P=Pendente, ou vazio para Pendente"
				EndIf

				If Empty(cRet)
					FPY->(dbSetOrder(1))
					If !FPY->(dbSeek(xFilial("FPY")+oJson:pv))
						cRet := "Pedido de vendas nao localizado na tabela do Rental"
					Else
						If alltrim(FPY->FPY_STATUS) <> "1"
							cRet := "Pedido de vendas bloqueado pelo Rental"
						EndIf
					EndIf

					If empty(cRet)
						SC5->(dbSetOrder(1))
						If !SC5->(dbSeek(xFilial("SC5")+oJson:pv))
							cRet := "Pedido de vendas nao localizado no faturamento"
						EndIf
					EndIf

				EndIf

				If empty(cRet)
					If oJson:aprova == "R" .and. FPY->FPY_APROV == "2"
						cRet := "Pedido de vendas ja recusado no Rental"
					EndIf
				EndIf

				//Issue: DSERLOCA-9873 - Leonardo Pacheco Fuga - 12/12/2025 - Novo tipo pendente
				If Empty(cRet) .and. oJson:aprova == "P"
					If !empty(SC5->C5_NOTA)
						lCorreto := .F.
						cRet := "Ja existe nota emitida para este pedido."
					EndIF
				EndIF

				//Issue: DSERLOCA-9873 - Leonardo Pacheco Fuga - 12/12/2025 - Novo tipo pendente
				If Empty(cRet) .and. oJson:aprova == "P"
					cHist := FPY->FPY_HIST + Chr(13) + Chr(10)
					FPY->(RecLock("FPY",.F.))
					FPY->FPY_APROV := "" // Vazio = Pendente
					cHist += "Pendencia do pedido de venda."
					cHist += "Data: "+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10)
					If !Empty(alltrim(oJson:aprovador))
						cHist += "Responsavel: "+alltrim(oJson:aprovador) + Chr(13) + Chr(10)
					EndIf
					If !Empty(alltrim(oJson:obs))
						cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
					EndIf
					FPY->FPY_HIST := cHist
					FPY->(MsUnlock())
					lCorreto := .T.
				EndIf

				If Empty(cRet)
					If oJson:aprova == "R"
						If !empty(SC5->C5_NOTA)
							lCorreto := .F.
							cRet := "Ja existe nota emitida para este pedido."
						Else

							SC5->(RecLock("SC5",.F.))
							SC5->C5_BLQ := "1"
							SC5->(MsUnlock())

							SA1->(dbSetOrder(1))
							SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))

							cHist := FPY->FPY_HIST + Chr(13) + Chr(10)
							cMessagem := "Pedido de vendas: "+SC5->C5_NUM+CHR(13)+CHR(10) // ISSUE DSERLOCA-10044 - Frank 06/01/2026
							FPY->(RecLock("FPY",.F.))
							FPY->FPY_APROV := "2"
							cHist += "Reprovacao do pedido de vendas."
							cHist += "Data: "+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10)
							cHist += "Responsavel: "+alltrim(oJson:aprovador) + Chr(13) + Chr(10)

							cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
							FPY->FPY_HIST := cHist 
							FPY->(MsUnlock())
							lCorreto := .T.

							cMessagem += "Reprovado pelo cliente: "+alltrim(SA1->A1_NOME)
							EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Reprovação do Pedido no Rental",cMessagem,.T.) // ISSUE DSERLOCA-10044 - Frank 06/01/2026

						EndIF
					ElseIf oJson:aprova == "A"
						If FPY->FPY_APROV == "1"
							cRet := "Registro ja aprovado"
						Else
							If !empty(SC5->C5_NOTA)
								cRet := "Ja foi gerado a nota fiscal para este pedido de vendas"
							EndIf

							//if empty(cRet)
							//	If SC5->C5_LIBEROK == "S" 
							//		cRet := "Este pedido de vendas ja foi liberado anteriormente"
							//	EndIf
							//EndIf

							if empty(cRet)

								SC6->(dbSetOrder(1))
								SC6->(dbSeek(xFilial("SC6")+oJson:pv))
								While !SC6->(Eof()) .and. SC6->(C6_FILIAL+C6_NUM) == xFilial("SC6")+oJson:pv
									If empty(SC6->C6_NOTA)
										SC6->(RecLock("SC6"),.F.)
										SC6->C6_QTDLIB := SC6->C6_QTDVEN
										SC6->(MsUnlock())
									EndIF
									SC6->(dbSkip())
								EndDo

								SC5->(RecLock("SC5",.F.))
								SC5->C5_BLQ := ""
								SC5->(MsUnlock())

								SA1->(dbSetOrder(1))
								SA1->(dbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))

								Pergunte("MTA440",.F.)
								lTransf:=MV_PAR01==1
								lLiber := .T.
								A440Libera("SC5",SC5->(Recno()),4,.T.)

								If SC5->C5_LIBEROK == "S"

									cHist := FPY->FPY_HIST + Chr(13) + Chr(10)
									FPY->(RecLock("FPY",.F.))
									FPY->FPY_APROV := "1"
									cMessagem := "Pedido de vendas: "+SC5->C5_NUM+CHR(13)+CHR(10) // ISSUE DSERLOCA-10044 - Frank 06/01/2026
									cHist += "Aprovacao do pedido de vendas."
									cHist += "Data: "+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10)
									cHist += "Responsavel: "+alltrim(oJson:aprovador) + Chr(13) + Chr(10)
									cHist += "Observacao: "+alltrim(oJson:obs) + Chr(13) + Chr(10)
									FPY->FPY_HIST := cHist
									FPY->(MsUnlock())
									lCorreto := .T.
								
									cMessagem += "Aprovado pelo cliente: "+alltrim(SA1->A1_NOME)
									EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Aprovação do Pedido no Rental",cMessagem,.T.) // ISSUE DSERLOCA-10044 - Frank 06/01/2026
								
								Else
									cRet := "Falha na liberacao do pedido de vendas."
									lCorreto := .F.
								EndIf
        
							EndIf

						EndIF

					EndIF
				EndIF

			endif
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	cOpera := ""
	If oJson:aprova == "R"
		cOpera := " - Reprovacao do pedido de vendas."
	EndIf
	If oJson:aprova == "A"
		cOpera := " - Aprovacao do pedido de vendas."
	EndIf
	//Issue: DSERLOCA-9873 - Leonardo Pacheco Fuga - 12/12/2025 - Novo tipo pendente
	If oJson:aprova == "P"
		cOpera := " - Pendencia do pedido de vendas."
	EndIf

	cRet += if(lCorreto,' - Operacao realizada com sucesso',' - Erro na execucao')

	cRet += cOpera
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'"}')) )
	
Return .T.

