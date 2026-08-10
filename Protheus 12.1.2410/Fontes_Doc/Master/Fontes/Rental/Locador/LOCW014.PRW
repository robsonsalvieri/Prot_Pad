#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaMotoristas  ³ Autor ³ Dennis Calabrez ³ Data ³20.01.2025               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo cadastra Motoristas no app                                          ³±±
±±³Descricao ³ 															                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL CriaMotoristas DESCRIPTION "Metodo cadastra Motoristas no app"

	WSMETHOD POST DESCRIPTION "<h2>Metodo cadastra Motoristas no app.</h2>" WSSYNTAX "/CriaMotoristas"

END WSRESTFUL



WSMETHOD POST WSSERVICE CriaMotoristas
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local oJson			:= Nil
Local cRet			:= ""
Local cBody			:= DecodeUtf8(::GetContent())
Local cCodigo       := ""

	//conout("INICIO-Consumido o WebService RetCCsMovVeiculo - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				//cRet := xAbreEnv1(aEmp[1],oJson:FilBem)
				cRet := xAbreEnv1(aEmp[1],aEmp[2])
				If Empty(cRet)
					cCodigo := GERNUMDA4()//SubStr(oJson:cpf,1,6)//GetSX8Num('DA4', 'DA4_COD') 
					DA4->(dbSetOrder(1))  
					If !DA4->(dbSeek(xFilial("DA4")+cCodigo))
						RecLock("DA4", .T.)
							DA4->DA4_FILIAL := xFilial('DA4')
							DA4->DA4_COD    := cCodigo
							DA4->DA4_NOME   := oJson:nome_motorista
							DA4->DA4_NREDUZ := oJson:nome_motorista
							DA4->DA4_NUMCNH := oJson:cnh
							DA4->DA4_CGC    := oJson:cpf
							If FieldPos("DA4_CODCLI") > 0//se existir o campo gravo a informação no mesmo
								DA4->DA4_CODCLI := oJson:cod_cli
							EndIf	
							If FieldPos("DA4_LOJCLI") > 0
								DA4->DA4_LOJCLI := oJson:loj_cli//se existir o campo gravo a informação no mesmo
							EndIf							
						DA4->(MsUnlock())
					Else
						cRet := "Codigo de Motorista ja cadastrado. Verifique!"	
					EndIf	
				EndIf
			endif
		EndIf
	End Sequence


	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados":"'+ALLTRIM(DA4->DA4_NOME)+'"}' )))
	
	//conout("TERMINO-Consumido o WebService RetCCsMovVeiculo - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

Function xVerEmp1(cCNPJ)
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

Function xAbreEnv1(cEmp,cFil)
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

Function GERNUMDA4()
Local cCodigo  := "000000"   
Local aArea    := GetArea()

	DA4->(dbSetOrder(1))
	DA4->(dbSeek(xFilial("DA4")))
	While !DA4->(Eof()) .and. DA4->DA4_FILIAL == xFilial("DA4")
		cCodigo := DA4->DA4_COD
		DA4->(dbSkip())
	EndDo

	cCodigo := Soma1( cCodigo )
	
RestArea(aArea)

Return cCodigo                    
