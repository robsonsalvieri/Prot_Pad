#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW040
Altera o Contador do Bem
@type API
@version V1 
@author Dennis Calabrez
@since 25/11/2025
/*/
WSRESTFUL LOCW040CT DESCRIPTION "Metodo Altera o Contador do Bem"

	WSMETHOD POST DESCRIPTION "<h2>Metodo Altera o Contador do Bem.</h2>" WSSYNTAX "/LOCW040CT"

END WSRESTFUL

/*/{Protheus.doc} LOCW040CT
Altera o Contador do Bem
@type API
@version V1 
@author Dennis Calabrez
@since 25/11/2025
/*/
WSMETHOD POST WSSERVICE LOCW040CT
	
Local cHrIni	  := Time()
Local oJson		  := Nil
Local cRet		  := ""
Local cBody	      := DecodeUtf8(::GetContent())
Local lRet        := .T.
Local cMsg        := ""
Local cQuery      := ""
Local aBindParam  := {}
	
	::SetContentType("application/json; charset=iso-8859-1")
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp5(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				cRet := xAbreEnv5(aEmp[1],aEmp[2])
				If Empty(cRet)

					cQuery := "SELECT ST9.R_E_C_N_O_, ST9.T9_CODBEM, ST9.T9_PLACA, ST9.T9_TEMCONT, ST9.T9_POSCONT  "
					cQuery += "FROM "+RetSqlName("ST9")+" ST9 "
					cQuery += " WHERE T9_FILIAL = '" +xFilial("ST9") + "' "
					cQuery += " AND ST9.D_E_L_E_T_ = ' ' "	
					cQuery +=  "AND T9_CODBEM = ? "
					aadd(aBindParam,oJson:bem)
					If !Empty(oJson:placa)
						cQuery +=  "AND T9_PLACA = ? "
						aadd(aBindParam,oJson:placa)
					EndIf							

					cQuery := CHANGEQUERY(cQuery)
					MPSysOpenQuery(cQuery,"TRBST9",,,aBindParam)	

					If !TRBST9->(EoF())		

						If TRBST9->T9_TEMCONT == "S"//Verifica se o Bem controla Contador							

							If val(oJson:contador) >= TRBST9->T9_POSCONT//Condição para alterar o Contador com a função da NG
								NGTRETCON(TRBST9->T9_CODBEM,dDatabase,val(oJson:contador),cHrIni,1,,,"A",xFilial("ST9"))
							Else
								lRet := .F.	
								cRet := "Erro no Contador informado"
								cMsg := "Nao foi possivel prosseguir, contador informado "+ oJson:contador +" menor que o contador atual "+ ALLTRIM(STR(TRBST9->T9_POSCONT)) + " corrigir o contador informado no APP."
							EndIF

							If lRet
								ST9->(DbGoTo(TRBST9->R_E_C_N_O_))//Posiciona no RECNO na ST9 a ser alterado o contador
								RecLock("STJ", .F.)
								ST9->T9_POSCONT := val(oJson:contador)
								ST9->(MsUnlock())
							EndIf 
						Else
							lRet := .F.	
							cRet := "Erro no Contador informado"
							cMsg := "O Bem ou Placa informado não controla contador"							
						EndIf
					Else
						lRet := .F.	
						cRet := "Não encontrado"
						cMsg := "Bem ou Placa não encontrado"						
					EndIf
				EndIf
			Endif
		EndIf

	End Sequence


	If Empty(cRet) .AND. lRet
		cRet := "OK"
		cMsg := "Contador Atualizado "+ oJson:contador 
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados":"'+cMsg+'"}' )))

Return .T.
