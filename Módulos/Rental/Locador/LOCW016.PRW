#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReagendaOS  ³ Autor ³ Dennis Calabrez ³ Data ³20.01.2025                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo Reagenda Ordem de Serviço no app                                     ³±±
±±³Descricao ³ 															                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL ReagendaOS DESCRIPTION "Metodo Reagenda Ordem de Serviço no app"

	WSMETHOD POST DESCRIPTION "<h2>Metodo Reagenda Ordem de Serviço no app.</h2>" WSSYNTAX "/ReagendaOS"

END WSRESTFUL



WSMETHOD POST WSSERVICE ReagendaOS
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local oJson			:= Nil
Local cRet			:= ""
Local cBody			:= DecodeUtf8(::GetContent())

	//conout("INICIO-Consumido o WebService ReagendaOS - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp2(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv2(aEmp[1],aEmp[2])
				If Empty(cRet)
					STJ->(DbSetOrder(1))
					STJ->(DbGoTop())   
					If STJ->(DbSeek(xFilial("STJ")+ oJson:num_os))  				
						RecLock("STJ", .F.)
							STJ->TJ_DTMPINI := StoD(oJson:nova_dt)
							STJ->TJ_DTMPFIM := StoD(oJson:nova_dt)
							If oJson:status_os ==  "C"//cancelamento de OS
								STJ->TJ_OBSERVA := "OS CANCELADA PELO PORTAL DO LOCADOR" 	
								STJ->TJ_SITUACA := "C"			
							EndIf	
						STJ->(MsUnlock())
					EndIf	
				EndIf
			endif
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados":"'+DTOC(STJ->TJ_DTMPINI)+'"}' )))
	
	//conout("TERMINO-Consumido o WebService RetCCsMovVeiculo - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

Function xVerEmp2(cCNPJ)
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

Function xAbreEnv2(cEmp,cFil)
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
