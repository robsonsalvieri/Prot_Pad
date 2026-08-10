#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Contestmulta  ³ Autor ³ Dennis Calabrez ³ Data ³31.01.2025                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo Interações entre locador e locatário para contestação de multas     ³±±
±±³Descricao ³ 															                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL Contestmulta DESCRIPTION " Metodo Aprovação de Multas no APP "

	WSMETHOD POST DESCRIPTION "<h2> Metodo para contestação de Multas no APP .</h2>" WSSYNTAX "/Contestmulta"

END WSRESTFUL



WSMETHOD POST WSSERVICE Contestmulta
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local oJson			:= Nil
Local cRet			:= ""
Local cBody			:= DecodeUtf8(::GetContent())
Local cObservacao   := ""
Local nTamObserv    := TamSX3("B1_OBS")[1]

	//conout("INICIO-Consumido o WebService ReagendaOS - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp4(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv4(aEmp[1],aEmp[2])
				If Empty(cRet)
					TRX->(DbSetOrder(1))
					TRX->(DbGoTop())   
					If TRX->(DbSeek(xFilial("TRX")+ oJson:num_multa))  	
                        //Busca a observação já gravada
                        cObservacao := MSMM(TRX->TRX_MMCOND, nTamObserv)    
                        
                        //Agora defino algum texto, adicionando na observação
                        cObservacao := Alltrim(cObservacao) + ";mensagem no dia: " + dToC(Date()) + " as " + Time() + CHR(13)+CHR(10)                                      			
						cObservacao += ";mensagem: " + oJson:mensagem + CHR(13)+CHR(10)
						cObservacao += ";usuario: " + oJson:usuario + CHR(13)+CHR(10)
						cObservacao += ";tipo: " + oJson:tipo + CHR(13)+CHR(10) 
						cObservacao += CHR(13)+CHR(10)
						RecLock("TRX", .F.)
                            MSMM(, nTamObserv, , cObservacao, 1, , , "TRX", "TRX_MMCOND")
						TRX->(MsUnlock())
					EndIf	
				EndIf
			endif
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" }')) )
	
	//conout("TERMINO-Consumido o WebService RetCCsMovVeiculo - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

Function xVerEmp4(cCNPJ)
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
	endif
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

Function xAbreEnv4(cEmp,cFil)
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
