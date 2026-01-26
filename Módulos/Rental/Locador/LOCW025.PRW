#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EncerraOs   ³ Autor ³ Rafael P Goncalves ³ Data ³11.05.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo encerra a os feita pelo fornecedor/portal           ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL EncerraOs DESCRIPTION "Encerra O.S do fornecedor"

	WSMETHOD POST DESCRIPTION "<h2>Metodo encerra O.S do fornecedor.</h2>" WSSYNTAX "/EncerraOs"

END WSRESTFUL

WSMETHOD POST WSSERVICE EncerraOs
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cBody			:= DecodeUtf8(::GetContent())
Local oJson			:= Nil
Local cRet          := ""

	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp5(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
                 cRet := xAbreEnv5(aEmp[1],aEmp[2])
            endif
           
			If Empty(cRet)
                FH1->(DbSetOrder(1))
                FH1->(DbGoTop())
                If FH1->(DbSeek(xFilial("FH1")+oJson:Ordem))
                    While FH1->(!EoF()) .AND. FH1->FH1_ORDEM == oJson:Ordem
                        If Empty(FH1->FH1_DTENC)
                            If RecLock("FH1",.F.)
                                FH1->FH1_DTENC  := Date()
                                FH1->FH1_HRENC  := Time()
                                FH1->(MsUnLocK())
                            EndIf
                        Else
                            cRet := "ERRO-O.S já se encontra encerrada em "+DtoC(FH1->FH1_DTENC)+" às "+FH1->FH1_HRENC+"."
                        EndIf
                        FH1->(DbSkip())
                    End     
                EndIf
			EndIf
		EndIf
	End Sequence

	ErrorBlock(bError)

	If Empty(cRet)
		cRet := "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" }')) )
	
	//conout("TERMINO-Consumido o WebService EncerraOs - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.
