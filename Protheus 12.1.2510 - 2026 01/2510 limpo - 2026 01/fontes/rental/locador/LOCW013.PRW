#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetFormsApp ³ Autor ³ Dennis Calabrez    ³ Data ³16.01.2025³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Metodo que retorna as Frotas Locadas para o aplicativo     ³±±
±±³Descricao ³ 															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
WSRESTFUL RetFrotasApp DESCRIPTION "Retorna as Frotas Locadas para o aplicativo"

	WSMETHOD GET DESCRIPTION "<h2>Metodo que retorna as Frotas Locadas para o aplicativo.</h2>" WSSYNTAX "/RetFrotasApp/{param1}/{param2}/{param3}/{param4}"

END WSRESTFUL



WSMETHOD GET WSSERVICE RetFrotasApp
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cDados		:= ""
Local cRet          := ""
Local cParam1       := ""
Local cParam2       := ""
Local cParam3       := ""
Local cParam4       := ""
Local cParam5		:= ""
Local cParam6		:= ""
Local aPar          := {}
Local cCodCli       := ""
Local cLojCli       := ""
Local cCnpj         := ""
Local cAut          := ""
Local cObra         := ""
Local cNomProd      := ""
Local cQuery        := ""	
Local lExistPE1     := EXISTBLOCK("LOCW13P1")   
Local lExistPE2     := EXISTBLOCK("LOCW13P2")   
Local aArea
Local aAreaFQF
Local cComple       := ""
Local cOcorre		:= ""
Local cSeq          := ""

	aPar :=  GetUrlParams(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
	cParam2 := aPar[2]
	cParam3 := aPar[3]
	cParam4 := aPar[4]
	cParam5 := aPar[5]
	cParam6 := aPar[6]
	cCodCli := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego o Código do cliente se informado
	cLojCli := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego a Loja do cliente se informada
	cCnpj   := AllTrim(SubStr(cParam3, At("=", cParam3) + 1))//Pego o CNPJ do cliente se informado
	cAut    := AllTrim(SubStr(cParam4, At("=", cParam4) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta
	cObra   := AllTrim(SubStr(cParam5, At("=", cParam5) + 1))//Obra
	cProjeto:= AllTrim(SubStr(cParam6, At("=", cParam6) + 1))//Projeto

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		If (aEmp[3] == "Empresa já existente.")
			cRet := xAbreEnv1(aEmp[1],aEmp[2])
        	//cRet := ""
			aBindParam := {}
			If Empty(cRet)
				cQuery := "SELECT FP0_CLI,FP0_LOJA,FP0_CLINOM,FQ4_CODBEM,T9_NOME,T9_PLACA,FQ4_PROJET,FQ4_OBRA,FPA_DTINI,FPA_DTFIM,FQ4_SEQ, FQ4.R_E_C_N_O_ REG "
				cQuery += "FROM "+RetSqlName("FQ4")+" FQ4 "
				cQuery += "INNER JOIN "+RetSqlName("FQD")+" FQD ON FQD_FILIAL = '"+xFilial("FQD")+"' AND FQD_STAREN = '20' AND FQ4_STATUS = FQD_STATQY AND FQD.D_E_L_E_T_ = ' ' "
				cQuery += "INNER JOIN "+RetSqlName("FP0")+" FP0 ON FP0_FILIAL = '"+xFilial("FP0")+"' AND FQ4_PROJET = FP0_PROJET AND FP0.D_E_L_E_T_ = ' ' "
				If !empty(cProjeto)
					cQuery += "AND FP0_PROJET = ? "
					aadd(aBindParam,Alltrim(cProjeto))
				EndIf
				If !Empty(cCodCli)
					cQuery +=  "AND FP0_CLI = ? "
					aadd(aBindParam,Alltrim(cCodCli))
				EndIf 	
				If !Empty(cLojCli)
					cQuery +=  "AND FP0_LOJA = ? "
					aadd(aBindParam,Alltrim(cLojCli))
				EndIf 	
				If !Empty(cCnpj)
					cQuery +=  "AND FP0_CLICGC = ? "
					aadd(aBindParam,Alltrim(cCnpj))
				EndIf	
				cQuery += "INNER JOIN "+RetSqlName("FPA")+" FPA ON FPA_FILIAL = '"+xFilial("FPA")+"' AND FQ4_PROJET = FPA_PROJET AND FP0.D_E_L_E_T_ = ' ' "
				cQuery += " AND FPA_AS = FQ4_AS "
				If !empty(cObra)
					cQuery += " AND FPA_OBRA = ? "
					aadd(aBindParam,Alltrim(cObra))
				EndIf
				cQuery += "INNER JOIN "+RetSqlName("ST9")+" ST9 ON T9_CODBEM = FQ4_CODBEM AND ST9.D_E_L_E_T_ = ' ' AND T9_FILIAL = '" +xFilial("ST9")+"' "
				cQuery += "WHERE FQ4.D_E_L_E_T_ = ' ' AND FQ4_AS <> ' ' AND FQ4_FILIAL = '"+xFilial("FQ4")+"' "
				cQuery += " AND FQ4.FQ4_SEQ = (SELECT MAX(FQ4A.FQ4_SEQ) FROM "+ RetSqlName("FQ4") + " FQ4A " 
				cQuery += " WHERE FQ4A.D_E_L_E_T_ = ' ' "
				cQuery += " AND FQ4A.FQ4_FILIAL = '"+xFilial("FQ4")+"' "       
				cQuery += " AND FQ4A.FQ4_CODBEM = FQ4.FQ4_CODBEM AND FQ4.FQ4_PROJET = FQ4A.FQ4_PROJET"
				cQuery += ") "			
				cQuery += "ORDER BY FP0_CLI,FP0_LOJA,FQ4_PROJET, FQ4_OBRA,FQ4_CODBEM"
				cQuery := CHANGEQUERY(cQuery)
				If Select("TRBFQ4") > 0
					TRBFQ4->(DbCloseArea())
				EndIf
				MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)//TcQuery cQuery New Alias "TRBFQ4"

				SA1->(DbSetOrder(1))
				SA1->(DbGoTop())   
				SA1->(DbSeek(xFilial("SA1")+TRBFQ4->FP0_CLI+TRBFQ4->FP0_LOJA))                 
				cDados += ', "cnpj" : "'+Alltrim(SA1->A1_CGC)+'", "Nome": "'+Alltrim(SA1->A1_NOME)+'", "Frotas": ['			

				While TRBFQ4->(!EoF()) 

					ST9->(dbSetOrder(1))
					ST9->(dbSeek(xFilial("ST9")+TRBFQ4->FQ4_CODBEM))

					FP1->(dbSetOrder(1))
					FP1->(dbSeek(xFilial("FP1")+TRBFQ4->FQ4_PROJET+TRBFQ4->FQ4_OBRA))

					cSeq := TRBFQ4->FQ4_SEQ

					cOcorre := ""
					cOcorre += '"ocorrencias": ['
					FQF->(dbSetOrder(2))
					If FQF->(dbSeek(xFilial("FQF")+cSeq))
						While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_SEQ) == xFilial("FQF")+cSeq
							cOcorre += '{ "status": "'+FQF->FQF_STATUS+'", '
							cOcorre += ' "dtini": "'+dtos(FQF->FQF_DTINI)+'", '
							cOcorre += ' "hora": "'+FQF->FQF_HORA+'", '
							cOcorre += ' "subst": "'+FQF->FQF_SUBST+'", '

							If lExistPE2
								aAreaFQF := GetArea()
								cOcorre += EXECBLOCK("LOCW13P2" , .T. , .T. )
								RestArea(aAreaFQF)
							EndIf

							cOcorre += ' "cc": "'+FQF->FQF_CC+'"} '
							FQF->(dbSkip())
							If !FQF->(Eof())
								cOcorre += ", "
							EndIf
						EndDo
					Else
						cOcorre += '{ "status": "", '
						cOcorre += ' "dtini": "", '
						cOcorre += ' "hora": "", '
						cOcorre += ' "subst": "", '
						
						If lExistPE2
							aAreaFQF := GetArea()
							cOcorre += EXECBLOCK("LOCW13P2" , .T. , .T. )
							RestArea(aAreaFQF)
						EndIf
						cOcorre += ' "cc": "" }'
					EndIf
                    cOcorre += '] '

					SB1->(DbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+Alltrim(Posicione("ST9",1,xFilial("ST9")+TRBFQ4->FQ4_CODBEM,"T9_CODESTO"))))
					cNomProd := SB1->B1_DESC

					// Ponto de entrada para complemento de campos
					cComple := ""
					If lExistPE1
						aArea := GetArea()
						cComple += EXECBLOCK("LOCW13P1" , .T. , .T., {TRBFQ4->REG} )
						RestArea(aArea)
					EndIf

					cDados += ' { ' 
					cDados += '"projeto" : "'+Alltrim(TRBFQ4->FQ4_PROJET)+'", '
					cDados += '"obra" : "'+Alltrim(TRBFQ4->FQ4_OBRA)+'", '
					cDados += '"as" : "'+Alltrim(Posicione("FPA",1,xFilial("FPA")+TRBFQ4->FQ4_PROJET+TRBFQ4->FQ4_OBRA,"FPA_AS"))+'", '
					cDados += '"nome_obra" : "'+Alltrim(FP1->FP1_NOMORI)+'", '
					cDados += '"data_inicio": "'+TRBFQ4->FPA_DTINI+'", '
					cDados += '"data_fim": "'+TRBFQ4->FPA_DTFIM+'", '
					cDados += '"produto": "'+Alltrim(Posicione("ST9",1,xFilial("ST9")+TRBFQ4->FQ4_CODBEM,"T9_CODESTO"))+'", '
					cDados += '"nome_prod": "'+AllTrim(cNomProd)+'", '
					cDados += '"placa": "'+Alltrim(Posicione("ST9",1,xFilial("ST9")+TRBFQ4->FQ4_CODBEM,"T9_PLACA"))+'", '
					cDados += '"nome_equipo": "'+AllTrim(TRBFQ4->T9_NOME)+'", '
					cDados += '"nserie": "'+AllTrim(ST9->T9_SERIE)+'", '
					cDados += '"modelo": "'+AllTrim(ST9->T9_MODELO)+'", '
					cDados += '"status": "'+AllTrim(ST9->T9_STATUS)+'", '
					cDados += cComple
					cDados += '"equipamento": "'+ALLTRIM(TRBFQ4->FQ4_CODBEM)+'", '
					
					cDados += cOcorre
					
					cDados += '}'

					TRBFQ4->(DbSkip())

					If !TRBFQ4->(Eof())
						cDados += ','
					EndIf

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
Static Function GetUrlParams(cUrl)
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

// Passagem do advpr
Function LOCW013A
return
