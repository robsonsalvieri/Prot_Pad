#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"
#include "FWEVENTVIEWCONSTS.CH"
  
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
Local cEventID 	:= "100"
Local cMessagem	:= " "
Local aSx5      :=  {}

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
					//BUSCA NA SX5 NA TABELA E3 O EVENTO 097 - DSERLOCA-10509 Dennis Calabrez 24/03/2026
					aSx5 := FWGetSX5("E3", cEventID) 				
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
						If Len(aSx5) > 0//SE EXISTIR O EVENTO 100 EXECUTA O EVENT VIEWER - DSERLOCA-10513 - Dennis Calabrez 24/03/2026
							cMessagem += "Nome do Cliente: "+Posicione("SA1",1,xFilial("SA1") + oJson:cod_cli ,"A1_NOME") + CHR(13)+CHR(10)
							cMessagem += " Código/Loja " + oJson:cod_cli+"/"+oJson:loj_cli + CHR(13)+CHR(10)
							cMessagem += " CNH: " + oJson:cnh+ CHR(13)+CHR(10)
							cMessagem += " CPF: " + oJson:cpf +CHR(13)+CHR(10) 
							EventInsert(FW_EV_CHANEL_ENVIRONMENT, FW_EV_CATEGORY_MODULES, cEventID,FW_EV_LEVEL_INFO,"","Cadastro de Motorista via LOCW014",cMessagem,.T.)											
						EndIf						
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
Local aRet 	   		:= {"","","",.F.}
	
	aRet[1] := cCNPJ
	aRet[2] := "EmpSM0[nPosEmp][2]"
	aRet[3] := "Empresa já existente."
	aRet[4] := .T.

	
Return (aRet)

Function xAbreEnv1(cEmp,cFil)
Local cRet	  := ""
Local aHeader := {}
	
    // PREENCHE CABEÇALHO DA REQUISIÇÃO
    AAdd(aHeader, "Content-Type: application/json; charset=UTF-8")
    AAdd(aHeader, "Accept: application/json")
    AAdd(aHeader, "User-Agent: Chrome/65.0 (compatible; Protheus " + GetBuild() + ")")

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
