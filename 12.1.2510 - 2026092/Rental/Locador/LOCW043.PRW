#Include "locw043.ch"
#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "FWEVENTVIEWCONSTS.CH"

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
// ISSUE: A DEFINIR - Code Review - 20/02/2026 - Correcoes apontadas no code review
Local bError := {||}
Local cEnvLog := ""
Local cRet := ""
Local cBody := DecodeUtf8(::GetContent())
Local aEmp := {}
Local cQuery       := ""
Local aBindParam := {}
Local cHist        := ""
Local aAs := {} // filtro por AS
Local cPrjd       := "" // Projeto inicial
Local cPrja       := "" // Projeto final
Local aExecAuto := {} 
Local cPedido := ""
Local cPV := ""
Local cFonte    := "LOCW043.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local cEventID 	:= "099"
Local cMessagem	:= " "
Local aSx5      :=  {}

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
			If (aEmp[4])
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1],aEmp[2])

				If FPG->(FIELDPOS("FPG_APROV")) == 0 .or. file("\SYSTEM\LOCW43X1.TXT")
					cRet := STR0001 //"500 - Faz-se necessario atualizar o dicionario de dados - falta o campo FPG_APROV"
				EndIf

				If empty(cRet)
					cQuery := "SELECT R_E_C_N_O_ REG "
					cQuery += "FROM " + RETSQLNAME("FPG") + " FPG "
					cQuery += "WHERE FPG.FPG_SEQ = ? "
					aadd(aBindParam,oJson:seq)
					cQuery += "AND FPG.D_E_L_E_T_ = ' ' "
					cQuery := CHANGEQUERY(cQuery)
					MPSysOpenQuery(cQuery,"TRBFPG",,,aBindParam)
					
					If TRBFPG->(Eof())
						cRet := STR0002 //"404 - Registro nao localizado"
					Else
						FPG->(dbGoto(TRBFPG->(REG)))
					EndIF
				
				EndIf

				If empty(cRet)
					//BUSCA NA SX5 NA TABELA E3 O EVENTO 097 - DSERLOCA-10513 Dennis Calabrez 23/03/2026
					aSx5 := FWGetSX5("E3", cEventID)  				

					If oJson:aprova == "A"
						If !empty(FPG->FPG_PVNUM)
							cRet := STR0003 //"400 - Ja foi faturado este custo extra nao pode ser aprovado novamente"
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

							// Commita as alteracoes do FPG (APROV, COBRA, etc.) antes do LOCA021
							// consultar o banco via MPSysOpenQuery. Atribuicoes de campo escrevem
							// apenas no buffer em memoria; o UPDATE SQL ocorre somente no MsUnlock().
							FPG->(MsUnlock())

							If oJson:GERPV == "S"
								MsExecAuto({|A,B,C,D,E,F,G| LOCA021(A,B,C,D,E,F,G)} ,;
								Nil , cPrjd , cPrja, aAs , .T. , 2 , aExecAuto)
							EndIf

							If len(aRetExec) > 0
								cPedido := aRetExec[1][1]
								cPV := STR0004+alltrim(cPedido) //" - Pedido de vendas: "
							Else
								cPedido := ""
								cPV := STR0005 //" - Nao foi possivel gerar o PV"
							EndIf

							If oJson:GERPV == "N"
								cPV := ""
							EndIf

							If FPG->(FIELDPOS("FPG_OBSCUS")) > 0
								FPG->(dbGoto(TRBFPG->(REG)))
								FPG->(RecLock("FPG",.F.))
								cHist := FPG->FPG_OBSCUS + Chr(13) + Chr(10)
								cHist += STR0006 //"Aprovacao do custo extra."
								cHist += STR0007+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10) //"Data: "
								cHist += STR0008+alltrim(oJson:aprovador) + Chr(13) + Chr(10) //"Responsavel: "
								cHist += STR0009+alltrim(oJson:obs) + Chr(13) + Chr(10) //"Observacao: "
								If oJson:GERPV == "N"
									cHist += STR0010 + Chr(13) + Chr(10) //"Nao foi solicitado a geracao do pedido de vendas pela API"
								Else
									If empty(cPedido)
										cHist += STR0011 + Chr(13) + Chr(10) //"Houve uma falha na geracao do pedido de vendas"
									Else
										cHist += STR0012+alltrim(cPedido)+" foi gerado pela API" + Chr(13) + Chr(10) //"O pedido de vendas: "
									EndIf
								EndIf
								FPG->FPG_OBSCUS := cHist
								FPG->(MsUnlock())
								If Len(aSx5) > 0//SE EXISTIR O EVENTO 099 EXECUTA O EVENT VIEWER - DSERLOCA-10513 - Dennis Calabrez 23/03/2026
									cMessagem += "Nome do Cliente: "+Posicione("FP0",1,xFilial("FP0") + FPG->FPG_PROJET ,"FP0_CLINOM") + CHR(13)+CHR(10)
									cMessagem += " Código/Loja " + Posicione("FP0",1,xFilial("FP0") + FPG->FPG_PROJET ,"FP0_CLI")+"/"+Posicione("FP0",1,xFilial("FP0") + FPG->FPG_PROJET ,"FP0_LOJA") + CHR(13)+CHR(10)
									cMessagem += " Sequência: " + oJson:seq+ CHR(13)+CHR(10)
									cMessagem += " Aprova: " +"Aprovacao do Custo Extra." + CHR(13)+CHR(10) 
									cMessagem += " Observação: " + oJson:obs +CHR(13)+CHR(10) 
									cMessagem += " Aprovador: " +  alltrim(oJson:aprovador) + CHR(13)+CHR(10)
									cMessagem += " Data Aprovação: " +  alltrim(oJson:data) + CHR(13)+CHR(10)
									cMessagem += " Hora Aprovação: " +  alltrim(oJson:hora) + CHR(13)+CHR(10)
									cMessagem += " Gera Pedido de Venda: " +  alltrim(oJson:GERPV) + CHR(13)+CHR(10)
									EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Aprovação/Reprovação de Medição",cMessagem,.T.)											
								EndIf 								
							EndIf

						EndIF
					Else

						If !empty(FPG->FPG_PVNUM)
							cRet := STR0013 //"400 - Ja foi faturado este custo extra, nao pode ser aprovado novamente"
						Else

							FPG->(RecLock("FPG",.F.))
							FPG->FPG_APROV := "2"
							FPG->FPG_DTAP := ctod(oJson:data)
							FPG->FPG_HAP := oJson:hora
							FPG->FPG_NAP := oJson:aprovador
							FPG->FPG_COBRA := "R"

							If FPG->(FIELDPOS("FPG_OBSCUS")) > 0 
								cHist := FPG->FPG_OBSCUS + Chr(13) + Chr(10)
								cHist += STR0014 //"Reprovacao do custo extra."
								cHist += STR0007+oJson:data+" Hora: "+oJson:hora + Chr(13) + Chr(10) //"Data: "
								cHist += STR0008+alltrim(oJson:aprovador) + Chr(13) + Chr(10) //"Responsavel: "
								cHist += STR0009+alltrim(oJson:obs) + Chr(13) + Chr(10) //"Observacao: "
								FPG->FPG_OBSCUS := cHist
							EndIf

							FPG->(MsUnlock())
							If Len(aSx5) > 0//SE EXISTIR O EVENTO 099 EXECUTA O EVENT VIEWER - DSERLOCA-10513 - Dennis Calabrez 23/03/2026
								cMessagem += "Nome do Cliente: "+Posicione("FP0",1,xFilial("FP0") + FPG->FPG_PROJET ,"FP0_CLINOM") + CHR(13)+CHR(10)
								cMessagem += " Código/Loja " + Posicione("FP0",1,xFilial("FP0") + FPG->FPG_PROJET ,"FP0_CLI")+"/"+Posicione("FP0",1,xFilial("FP0") + FPG->FPG_PROJET ,"FP0_LOJA") + CHR(13)+CHR(10)
								cMessagem += " Sequência: " + oJson:seq+ CHR(13)+CHR(10)
								cMessagem += " Aprova: " +"Reprovação do Custo Extra." + CHR(13)+CHR(10) 
								cMessagem += " Observação: " + oJson:obs +CHR(13)+CHR(10) 
								cMessagem += " Aprovador: " +  alltrim(oJson:aprovador) + CHR(13)+CHR(10)
								cMessagem += " Data Aprovação: " +  alltrim(oJson:data) + CHR(13)+CHR(10)
								cMessagem += " Hora Aprovação: " +  alltrim(oJson:hora) + CHR(13)+CHR(10)
								cMessagem += " Gera Pedido de Venda: " +  alltrim(oJson:GERPV) + CHR(13)+CHR(10)
								EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Aprovação/Reprovação de Medição",cMessagem,.T.)											
							EndIf							

						EndIf

					EndIf

				EndIf
				LOCACLOSE("TRBFPG")
			Else
				cRet := STR0015 //"401 - nao foi possivel identificar a empresa"
			Endif
		EndIf
	End Sequence
	ErrorBlock(bError)

	If Empty(cRet)
		cRet := "200 - "
		If oJson:aprova == "A"
			cRet += STR0016+cPv //"Aprovado o custo extra"
		Else
			cRet += STR0017 //"Reprovado o custo extra"
		EndIf
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'","compilado":"'+DtoS(aInfo[4])+' '+aInfo[5]+'"}')) )
	
Return .T.

