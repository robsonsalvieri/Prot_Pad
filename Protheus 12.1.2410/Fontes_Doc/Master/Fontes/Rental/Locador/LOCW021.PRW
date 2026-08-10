#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraOS  ³ Autor ³ Dennis Calabrez ³ Data ³05.02.2025                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo Gera Ordem de Serviço no app                                        ³±±
±±³Descricao ³ 															                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL GeraOS DESCRIPTION "Metodo Gera Ordem de Serviço no app"

	WSMETHOD POST DESCRIPTION "<h2>Metodo Gera Ordem de Serviço no app.</h2>" WSSYNTAX "/GeraOS"

END WSRESTFUL



WSMETHOD POST WSSERVICE GeraOS
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local oJson			:= Nil
Local cRet			:= ""
Local aRet          := {}
Local cBody			:= DecodeUtf8(::GetContent())
Local lRet          := .T.
Local cMsg          := ""
Local cQuery        := ""
Local aBindParam    := {}
	//conout("INICIO-Consumido o WebService ReagendaOS - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp5(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv5(aEmp[1],aEmp[2])
				If Empty(cRet)

                	//ST9->(dbSetOrder(1))
                	//ST9->(DbGoTop())
                	//ST9->(dbSeek(xFilial("ST9")+oJson:bem))
					cQuery := "SELECT * "
					cQuery += "FROM "+RetSqlName("ST9")+" ST9 "
					cQuery += " WHERE T9_FILIAL = '" +xFilial("ST9") + "' "
					cQuery += " AND ST9.D_E_L_E_T_ = ' ' "	
					If !Empty(oJson:bem)
						cQuery +=  "AND T9_CODBEM = ? "
						aadd(aBindParam,oJson:bem)
					EndIf
					If !Empty(oJson:placa)
						cQuery +=  "AND T9_PLACA = ? "
						aadd(aBindParam,oJson:placa)
					EndIf							

					//TcQuery cQuery New Alias "TRBFH1"
					cQuery := CHANGEQUERY(cQuery)
					MPSysOpenQuery(cQuery,"TRBST9",,,aBindParam)					

                	If val(oJson:hodometro) > TRBST9->T9_POSCONT
                    	NGTRETCON(TRBST9->T9_CODBEM,dDatabase,val(oJson:hodometro),cHrIni,1,,,"A",xFilial("ST9"))
					Else
						lRet := .F.	
						cMsg := "Nao foi possivel prosseguir, contador informado "+ oJson:hodometro +" menor que o contador atual "+ ALLTRIM(STR(TRBST9->T9_POSCONT)) + " corrigir o contador informado no APP."
					EndIF

					If lRet
						aRet := NGGERAOS("C", dDatabase, TRBST9->T9_CODBEM, oJson:servico, '0','N','N','N',cFilAnt,"L")
						FPA->(dbSetOrder(3))
						FPA->(dbSeek(xFilial("FPA")+oJson:num_as))
						RecLock("STJ", .F.)
							STJ->TJ_AS      := oJson:num_as
							STJ->TJ_PROJETO := FPA->FPA_PROJET//Alltrim(Posicione("FPA",3,xFilial("FPA")+oJson:as,"FPA_PROJET"))
							STJ->TJ_OBRA    := FPA->FPA_OBRA//Alltrim(Posicione("FPA",3,xFilial("FPA")+oJson:as,"FPA_OBRA"))
							STJ->TJ_POSCONT := val(oJson:hodometro)
							STJ->TJ_OBSERVA := oJson:desc_obs 
						STJ->(MsUnlock())
					EndIf 
				EndIf
			Endif
		EndIf

	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	If lRet 
		::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados":"'+aRet[1][3]+'"}' )))
	Else	
		::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados":"'+cMsg+'"}' )))

	EndIf
	//conout("TERMINO-Consumido o WebService RetCCsMovVeiculo - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

Function xVerEmp5(cCNPJ)
Local aRet 	   		:= {"","",""}
Local cNextEmp		:= ""
Local cNextFil		:= ""
	
	//cCNPJ 		:= Replace(Replace(Replace(cCNPJ,".",""),"/",""),"-","")
	//cRaizCNPJ	:= Replace(Replace(Replace(cRaizCNPJ,".",""),"/",""),"-","")
	
	//ConOut("Verificando Empresa")

	aEmpSM0	:= FWLoadSM0()
	nPosEmp := aScan(aEmpSM0,{|x| Alltrim(x[18]) == Alltrim( cCNPJ ) })
	if nPosEmp > 0 
		aRet[1] := aEmpSM0[nPosEmp][1]
		aRet[2] := aEmpSM0[nPosEmp][2]
	Endif
	DbCloseAll()
	RpcClearEnv()

	//Se não existe
	If Empty(aRet[1])
		aRet[1] := cNextEmp
		aRet[2] := cNextFil
		aRet[3] := "Não existe empresa."
	Else
		aRet[3] := "Empresa já existente."
	EndIf
	
Return (aRet)

Function xAbreEnv5(cEmp,cFil)
Local cEnvLog	:= ""
Local cRet		:= ""
Local lRetEmp	:= .F.
Local bError    := {||}

	//ConOut("Abrindo Ambiente")
	
	// Salva bloco de código do tratamento de erro
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
	
	Begin Sequence

		RpcClearEnv() 
		RpcSetType(3) 
		lRetEmp := RpcSetEnv(cEmp,cFil,,,"FAT",GetEnvServer(),{""})

	End Sequence
	ErrorBlock(bError)
	
Return (cRet)
