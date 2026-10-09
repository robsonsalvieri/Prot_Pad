#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW047.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Lista Medições
@TYPE WSRESTFUL
@AUTHOR DENNIS CALABREZ
@SINCE 07/01/2026
/*/
WSRESTFUL LOCW047 DESCRIPTION "Retorna Lista das Medicoes"

	WSMETHOD GET DESCRIPTION "<h2>Metodo que Retorna Lista das Medicoes.</h2>" WSSYNTAX "/LOCW047/{param1}/{param2}/{param3}/{param4}/{param5}"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW047
ITUP BUSINESS - TOTVS RENTAL
Método para listar Medições
@TYPE WSMETHOD
@AUTHOR DENNIS CALABREZ
@SINCE 07/01/2026
/*/
WSMETHOD GET WSSERVICE LOCW047
Local cEnvLog  		:= ""
Local bError    	:= {||}
Local cDados		:= ""
Local cRet          := ""
Local cMsg          := ""
Local cParam1       := ""
Local cParam2       := ""
Local cParam3       := ""
Local cParam4       := ""
Local cParam5		:= ""
Local cParam6		:= ""
Local aPar          := {}
Local aBindParam    := {}
Local dDtIni        := ""
Local dDtFim        := ""
Local cProje        := ""
Local cAut          := ""
Local cCli          := ""
Local cLoja         := ""
Local cItem		    := ""
Local lLog          := .F.
Local cQuery        :=  ""
Local aEmp          := {}

	aPar :=  LOCW047A(AllTrim(Upper(::GetPath(1)))) //Busco os parâmetros informados na URL/API

	cParam1 := aPar[1]
	cParam2 := aPar[2]
	cParam3 := aPar[3]
	cParam4 := aPar[4]
	cParam5 := aPar[5]
	cParam6 := aPar[6]

	dDtIni  := AllTrim(SubStr(cParam1, At("=", cParam1) + 1))//Pego a Data inicial
	dDtFim  := AllTrim(SubStr(cParam2, At("=", cParam2) + 1))//Pego a Data final
	cProje  := AllTrim(SubStr(cParam3, At("=", cParam3) + 1))//Pego o Projeto se informado
	cAut    := AllTrim(SubStr(cParam4, At("=", cParam4) + 1))//Pego o CNPJ da Empresa para Logar no Protheus na empresa correta
	cCli    := AllTrim(SubStr(cParam5, At("=", cParam5) + 1))//Pego o cliente se informado
	cLoja   := AllTrim(SubStr(cParam6, At("=", cParam6) + 1))//Pego a loja se informado

	::SetContentType("application/json; charset=iso-8859-1")
	
	// Salva bloco de código do tratamento de erro	
	bError := ErrorBlock( { |oError| xTrataError( oError,@cEnvLog ) } )
			
	Begin Sequence	
		aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
		lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa já existente.")
		If lLog
			cRet := xAbreEnv1(aEmp[1],aEmp[2])
			If Empty(dDtIni) .OR. Empty(dDtFim)
				cRet := "400 - "
				cMsg := "Datas de inicio e fim tem que ser obrigatoriamente informadas"
			EndIf
			
			If Empty(cRet)
				cQuery := "SELECT FQK_FILIAL,FQK_SITUAC,FQK_COD,FQK_DTINIC,FQK_DTFIM,FQK_PROJET,FQK_OBRA,FQK_VLRFRA, FQK.R_E_C_N_O_ REG, FQK_MEDSEQ, FQK_VALTOT "
				cQuery += "FROM "+RetSqlName("FQK")+" FQK "
				cQuery += "WHERE FQK_DTINIC >= ? AND FQK_DTINIC <= ? AND FQK.D_E_L_E_T_ = ' ' "
				cQuery += "AND FQK_FILIAL = '" +xFilial("FQK") + "' "
				aadd(aBindParam,dDtIni)
				aadd(aBindParam,dDtFim)
			
				If !Empty(cProje)
					cQuery +=  "AND FQK_PROJET = ? "
					aadd(aBindParam,Alltrim(cProje))
				EndIf 	
				If !Empty(cCli)
					cQuery +=  "AND FQK_CLIENT = ? "
					aadd(aBindParam,Alltrim(cCli))
				EndIf
				If !Empty(cLoja)
					cQuery +=  "AND FQK_LOJA = ? "
					aadd(aBindParam,Alltrim(cLoja))
				EndIf			 					 	
			
				cQuery += "ORDER BY FQK_COD"
				cQuery := CHANGEQUERY(cQuery)

				MPSysOpenQuery(cQuery,"TRBFQK",,,aBindParam)
               
				cDados += ', "Medicao": ['			

				If TRBFQK->(!EoF()) 
					While TRBFQK->(!EoF()) 

						cItem := ""
						cItem += '"Itens": ['
						FQL->(dbSetOrder(1))
						If FQL->(dbSeek(xFilial("FQL")+TRBFQK->FQK_COD))
							While !FQL->(Eof()) .and. TRBFQK->FQK_COD == FQL->FQL_COD;
									            .and. xFilial("FQL") == TRBFQK->FQK_FILIAL
								cItem += '{ "produto": "'+ALLTRIM(FQL->FQL_PROD)+'", '
								cItem += ' "nome_prod": "'+Alltrim(Posicione("SB1",1,xFilial("SB1")+FQL->FQL_PROD,"B1_DESC"))+'", '
								cItem += ' "item": "'+ALLTRIM(FQL->FQL_ITEM)+'", '
								cItem += ' "bem": "'+ALLTRIM(FQL->FQL_FROTA)+'", '
								cItem += ' "nome_bem": "'+ALLTRIM(Posicione("ST9",1,xFilial("ST9")+FQL->FQL_FROTA,"T9_NOME"))+'", '
								cItem += ' "consumo": "'+ALLTRIM(str(FQL->FQL_QTDKM))+'", '
								cItem += ' "excedente": "'+ALLTRIM(str(FQL->FQL_QTDHR))+'", '
								cItem += ' "vlr_unit_excedente": "'+ALLTRIM(str(FQL->FQL_VALHOR))+'", '
								cItem += ' "contador_ini": "'+ALLTRIM(str(FQL->FQL_KMINI))+'", '
								cItem += ' "contador_fim": "'+ALLTRIM(str(FQL->FQL_KMFIM))+'", '
								cItem += ' "vlr_total": "'+ALLTRIM(str(FQL->FQL_VLTOHR))+'"} '

								FQL->(dbSkip())
								If !FQL->(Eof())
									cItem += ", "
								EndIf
							EndDo
						EndIf
						cItem += '] '


						cDados += ' { ' 
						cDados += '"projeto" : "'+Alltrim(TRBFQK->FQK_PROJET)+'", '
						cDados += '"obra" : "'+Alltrim(TRBFQK->FQK_OBRA)+'", '
						cDados += '"codi" : "'+Alltrim(TRBFQK->FQK_COD)+'", '
						cDados += '"seqmed" : "'+Alltrim(TRBFQK->FQK_MEDSEQ)+'", '
						If TRBFQK->FQK_SITUAC == "1"
							cDados += '"situa" : "Digitado", '
						EndIf
						If TRBFQK->FQK_SITUAC == "2" .And. TRBFQK->FQK_VALTOT > 0
							cDados += '"situa" : "Em aprovacao", '
						EndIf	
						If TRBFQK->FQK_SITUAC == "4"
							cDados += '"situa" : "Medido", '
						EndIf							
						If TRBFQK->FQK_SITUAC == "5"
							cDados += '"situa" : "Nao aprovado", '
						EndIf								
						If TRBFQK->FQK_SITUAC == "6" .Or. TRBFQK->FQK_SITUAC == "3"
							cDados += '"situa" : "Cancelado", '
						EndIf
						If TRBFQK->FQK_SITUAC == "2" .And. TRBFQK->FQK_VALTOT == 0
							cDados += '"situa" : "Sem excedente", '
						EndIf									
						
						cDados += '"data_inicio": "'+TRBFQK->FQK_DTINIC+'", '
						cDados += '"data_fim": "'+TRBFQK->FQK_DTFIM+'", '
						cDados += '"franquia" : "'+ALLTRIM(str(TRBFQK->FQK_VLRFRA))+'", '			
						
						cDados += cItem
						
						cDados += '}'

						TRBFQK->(DbSkip())

						If !TRBFQK->(Eof())
							cDados += ','
						EndIf

					EndDo
				Else
					cRet := "204 - "
					cMsg := " A requisicao foi bem-sucedida, mas nao ha conteudo para retornar no corpo da resposta, verifique os parametros"
				EndIf

				cDados += "]"
			EndIf
		Else
			cRet := "401 - "
			cMsg := "Credenciais de autenticacao invalidas ou ausentes, verifique o CNPJ da empresa Protheus"				
		EndIf	
	End Sequence

	ErrorBlock(bError)
	If Empty(cRet)
		cRet := "200 - "
		cMsg := "Recurso encontrado"
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+cMsg+'" '+cDados+'}')) )
	
Return .T.

/*/{PROTHEUS.DOC} LOCW047A
ITUP BUSINESS - TOTVS RENTAL
Alimenta os parâmetros da URL em um Array
@TYPE STATIC FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 07/01/2026
/*/
Static Function LOCW047A(cUrl)
Local cQry    := ""
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
    EndIf

Return (aParams)
