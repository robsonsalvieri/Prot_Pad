#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetUsersApp ³ Autor ³ Rafael P Goncalves ³ Data ³15.07.2021³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna os usuários que acessam o aplicativo    ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÝÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL RetUsersApp DESCRIPTION "Retorna os formulários para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2>Metodo que retorna os formulários para o aplicativo.</h2>" WSSYNTAX "/RetUsersApp"

END WSRESTFUL

WSMETHOD GET WSSERVICE RetUsersApp
	
	Local cDtIni		:= DtoC(Date())
	Local cHrIni		:= Time()
	Local cEnvLog  		:= ""
	Local bError    	:= {||}
	Local cDados		:= ""
    Local nCont         := 0
    Local cRet          := ""

	//conout("INICIO-Consumido o WebService RetUsersApp - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
        cRet := ""//U_xAbreEnv("01","0101")
        If Empty(cRet)
            FQ1->(DbSetOrder(1))
            FQ1->(DbGoTop())
            cDados := ', "Dados" : ['
            
            While FQ1->(!EoF()) .AND. !Empty(FQ1->FQ1_CPF) .AND. !Empty(FQ1->FQ1_PSWEAS)
                If nCont > 0
                    cDados += ','
                EndIf
                
                cDados += ' { "CPF" : "'+Alltrim(FQ1->FQ1_CPF)+'", "Nome": "'+Alltrim(FQ1->FQ1_NOMPRO)+'", "Senha": "'+Alltrim(FQ1->FQ1_PSWEAS)+'"}'

                nCont++
                FQ1->(DbSkip())
            EndDo
            
            cDados += " ]"
        EndIf
	End Sequence

	ErrorBlock(bError)
	If !Empty(cEnvLog)
		//cRet := "ERRO-"+cEnvLog
	EndIf

	If Empty(cRet)
		cRet 	:= "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
	//conout("TERMINO-Consumido o WebService RetUsersApp - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.
