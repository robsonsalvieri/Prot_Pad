#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetManutBem ³ Autor³ Dennis Calabrez³ Data ³16.01.2025³     ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Retorna as Frotas em Manutenção para o aplicativo          ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSRESTFUL RetManutBem DESCRIPTION "Retorna as Frotas em Manutenção para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2>Metodo que retorna as Frotas Locadas para o aplicativo.</h2>" WSSYNTAX "/RetManutBem/{param1}/{param2}/{param3}/{param4}"

END WSRESTFUL



WSMETHOD GET WSSERVICE RetManutBem
	
Local cDtIni		:= DtoC(Date())
Local cHrIni		:= Time()
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cDados		:= ""
Local nContForm     := 0
Local nContFam      := 0
Local nContSeq      := 0
Local cRet          := ""
Local cParam1       := ""
Local cParam2       := ""
Local cParam3       := ""
Local cParam4       := ""
Local aPar          := {}
Local cCodCli       := ""
Local cLojCli       := ""
Local cCnpj         := ""
Local cAut          := ""
Local cQuery
Local aBindParam    := {}

	//conout("INICIO-Consumido o WebService RetManutencaoBem - Data e Hora Inicial "+cDtIni+" - "+cHrIni)
	aPar :=  GetUrlParam(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
	cParam2 := aPar[2]
	cParam3 := aPar[3]
	cParam4 := aPar[4]
	cCodCli := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Código do cliente se informado
	cLojCli := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego a Loja do cliente se informada
	cCnpj   := AllTrim(SubStr(cParam3, At("=", cParam3) + 1))//Pego o CNPJ do cliente se informado
	cAut    := AllTrim(SubStr(cParam4, At("=", cParam4) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta
	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		If (aEmp[3] == "Empresa já existente.")
			cRet := xAbreEnv1(aEmp[1],aEmp[2])
        	//cRet := ""
			If Empty(cRet)
				cQuery := "SELECT DISTINCT TJ_PROJETO, TJ_OBRA, TJ_ORDEM,TJ_DTMPINI, T9_PLACA, TE_CARACTE,FP0_CLI,FP0_LOJA,TJ_CODBEM "
				cQuery += "FROM "+RetSqlName("STJ")+" STJ "
				cQuery += "INNER JOIN "+RetSqlName("ST9")+" ST9 ON T9_CODBEM = TJ_CODBEM AND ST9.D_E_L_E_T_ = ' ' "
				cQuery += "INNER JOIN "+RetSqlName("ST4")+" ST4 ON T4_SERVICO = TJ_SERVICO AND ST4.D_E_L_E_T_ = ' ' "
				cQuery += "INNER JOIN "+RetSqlName("STE")+" STE ON TE_TIPOMAN = T4_TIPOMAN AND STE.D_E_L_E_T_ = ' ' "
				cQuery += "INNER JOIN "+RetSqlName("FP0")+" FP0 ON FP0_FILIAL = '"+xFilial("FP0")+"' AND FP0_PROJET = TJ_PROJETO AND FP0.D_E_L_E_T_ = ' ' "
				If !Empty(cCodCli) .and. !Empty(cLojCli)
					cQuery +=  "AND FP0_CLI = ? AND FP0_LOJA = ? "
					aadd(aBindParam,cCodCli)
					aadd(aBindParam,cLojCli)
				EndIf 	
				If !Empty(cCnpj)
					cQuery +=  "AND FP0_CLICGC = ? "
					aadd(aBindParam,cCnpj)
				EndIf				
				cQuery += "WHERE TJ_AS <> '' AND STJ.D_E_L_E_T_ = '' AND TJ_TERMINO = 'N' AND TJ_SITUACA <> 'C' "		
				cQuery += "ORDER BY TJ_ORDEM"

				If Select("TRBSTJ") > 0
					TRBSTJ->(DbCloseArea())
				EndIf

				cQuery := CHANGEQUERY(cQuery)
				MPSysOpenQuery(cQuery,"TRBSTJ",,,aBindParam)

				//TcQuery cQuery New Alias "TRBSTJ"

				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())   
				SA1->(DbSeek(xFilial("SA1")+TRBSTJ->FP0_CLI+TRBSTJ->FP0_LOJA))                 
				cDados += ', "cnpj" : "'+Alltrim(SA1->A1_CGC)+'", "Nome": "'+Alltrim(SA1->A1_NOME)+'", "Frotas": ['			

				While TRBSTJ->(!EoF()) 
					If nContForm > 0
						cDados += ','
					EndIf
						
					nContFam := 0
						
					cDados += ' { ' +;
					'"projeto" : "'+Alltrim(TRBSTJ->TJ_PROJETO)+'"," '+;
					'obra" : "'+Alltrim(TRBSTJ->TJ_OBRA)+'"," '+;
					'nome_obra" : "'+Alltrim(Posicione("FP1",1,xFilial("FP1")+TRBSTJ->TJ_PROJETO+TRBSTJ->TJ_OBRA,"FP1_NOMORI"))+'", " '+;
					'num_os" : "'+Alltrim(TRBSTJ->TJ_ORDEM)+'", " '+;
					'equipamento": "'+ALLTRIM(TRBSTJ->TJ_CODBEM)+'", " '+;
					'tip_manutencao": "'+ALLTRIM(TRBSTJ->TE_CARACTE)+'", " '+;
					'placa": "'+ALLTRIM(TRBSTJ->T9_PLACA)+'", " '+;
					'dt_agendamento": "'+TRBSTJ->TJ_DTMPINI+'"}'

					nContSeq := 0
					nContForm++
					TRBSTJ->(DbSkip())
				EndDo

				cDados += "]"
			EndIf
		EndIf	
	End Sequence

	ErrorBlock(bError)
	If Empty(cRet)
		cRet 	:= "OK"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'" '+cDados+'}')) )
	
	//conout("TERMINO-Consumido o WebService RetFormsApp - Data e Hora Termino "+DtoC(Date())+" - "+Time()+" / Data e Hora Inicial "+cDtIni+" - "+cHrIni)
Return .T.

/*/{PROTHEUS.DOC}
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 20/01/2025
/*/
Static Function GetUrlParam(cUrl)
Local cQry  := ""
Local aParams := {}

    // Captura apenas a parte dos parâmetros após o '?'
    If At("?", cUrl) > 0
        cQry := AllTrim(SubStr(cUrl, At("?", cUrl) + 1))
    Else
        cQry := ""
    EndIf

    // Verifica se existem parâmetros
    If !Empty(cQry)
        // Quebra os parâmetros pelo '&'
        aParams := StrTokArr(cQry, "&")
    Else
        //ConOut("Nenhum parâmetro encontrado na URL.")
    EndIf

Return (aParams)
