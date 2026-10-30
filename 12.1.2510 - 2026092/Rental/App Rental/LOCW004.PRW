#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LoginApp ³ Autor ³ Rafael P Goncalves ³ Data ³04.06.2021   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo efetua login no aplicativo                          ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL LoginApp DESCRIPTION "Login no aplicativo"

	WSMETHOD POST DESCRIPTION "<h2>Metodo efetua login no aplicativo.</h2>" WSSYNTAX "/LoginApp"

END WSRESTFUL



WSMETHOD POST WSSERVICE LoginApp
	
	Local cDtIni		:= DtoC(Date())
	Local cHrIni		:= Time()
	Local cEnvLog  		:= ""
	Local bError    	:= {||}
	Local cBody			:= DecodeUtf8(::GetContent())
	Local oJson			:= Nil
	Local lAutoriza		:= .F.
	Local cNomeUsr		:= ""
	Local cLogadoPor	:= ""
	Local cDados		:= ""
	Local cRet			:= ""

	//conout("INICIO-Consumido o WebService LoginApp - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
			cRet := ""//U_xAbreEnv("99","01")
			If Empty(cRet)
				If !lAutoriza
					FQ1->(DbSetOrder(2))//FQ1_FILIAL+FQ1_CPF
					FQ1->(DbGoTop())
					If FQ1->(DbSeek(xFilial("FQ1")+oJson:cCodOuCPF)) 
						If Alltrim(FQ1->FQ1_PSWEAS) == oJson:cSenha
								lAutoriza 	:= .T.
								cNomeUsr  	:= Alltrim(FQ1->FQ1_NOMPRO)
								cLogadoPor	:= "CPF"
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			cRet := "ERRO-Não foi possível converter o json."
		EndIf
		If !lAutoriza
				cRet := "ERRO-Código, cpf ou senha incorreta, revise e tente novamente!"
		EndIf
	End Sequence

	ErrorBlock(bError)
	If !Empty(cEnvLog)
		cRet := "ERRO-"+cEnvLog
	EndIf

	If Empty(cRet)
		cRet 	:= "OK"
		cDados	:= ', "Dados": [{ "CodOuCpf": "'+oJson:cCodOuCPF+'", "Nome":"'+cNomeUsr+'", "LogadoPor": "'+cLogadoPor+'"}]'
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
	//conout("TERMINO-Consumido o WebService LoginApp - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.
