#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{Protheus.doc} LOCW065
 Altera Ordem de Serviço
@type API
@version V1 
@author Dennis Calabrez
@since 23/07/2026
/*/
WSRESTFUL LOCW065 DESCRIPTION "Metodo Altera Ordem de Serviço - Rental"

	WSMETHOD POST DESCRIPTION "<h2>Metodo Altera Ordem de Serviço - Rental.</h2>" WSSYNTAX "/LOCW065"

END WSRESTFUL

/*/{Protheus.doc} LOCW065
 Altera Ordem de Serviço
@type API
@version V1 
@author Dennis Calabrez
@since 23/07/2026
/*/
WSMETHOD POST WSSERVICE LOCW065
	
Local oJson		  := Nil
Local cRet		  := ""
Local cBody	      := DecodeUtf8(::GetContent())
Local lRet        := .T.
Local cMsg        := ""
Local cQuery      := ""
Local aBindParam  := {}
Local cAut        := ""
	
	::SetContentType("application/json; charset=iso-8859-1")
			
	Begin Sequence
		If FWJsonDeserialize(cBody,@oJson)
			aEmp := xVerEmp1(Replace(Replace(Replace(cAut,".",""),"/",""),"-",""))
			If (aEmp[3] == "Empresa já existente.")
				cRet := xAbreEnv1(aEmp[1],aEmp[2])
				If Empty(cRet)

					dbSelectArea("FPA")
					dbSetOrder(1)
					if dbSeek(xFilial("FPA")+PADR(oJson:projeto,TamSX3("FPA_PROJET")[1])+oJson:obra)	

						dbSelectArea("FPA")
						dbSetOrder(3)
						if !dbSeek(xFilial("FPA")+PADR(oJson:nras,TamSX3("FPA_AS")[1]))										
							lRet := .F.	
							cRet := "400 - "
							cMsg := "A.S. nao encontrada ou inexistente"								
						EndIf

						dbSelectArea("FQ5")
						dbSetOrder(20)
						if dbSeek(xFilial("FQ5")+PADR(oJson:nras,TamSX3("FQ5_AS")[1]))		
							If FQ5->FQ5_STATUS == "9"								
								lRet := .F.	
								cRet := "400 - "
								cMsg := "A.S. cancelada nao pode ser movimentada"	
							EndIf							
						EndIf						

						cQuery := "SELECT STJ.R_E_C_N_O_,   "
						cQuery += " STJ.TJ_ORDEM,STJ.TJ_AS,STJ.TJ_PROJETO,STJ.TJ_OBRA "	
						cQuery += "FROM "+RetSqlName("STJ")+" STJ "
						cQuery += " WHERE TJ_FILIAL = '" +xFilial("STJ") + "' "
						cQuery += " AND STJ.D_E_L_E_T_ = ' ' "	
						cQuery +=  "AND TJ_ORDEM = ? "
						aadd(aBindParam,oJson:os)						

						cQuery := CHANGEQUERY(cQuery)
						MPSysOpenQuery(cQuery,"TRBSTJ",,,aBindParam)	

						If !TRBSTJ->(EoF())		

							If lRet
								STJ->(DbGoTo(TRBSTJ->R_E_C_N_O_))
								RecLock("STJ", .F.)
								STJ->TJ_AS      := oJson:nras
								STJ->TJ_PROJETO := oJson:projeto
								STJ->TJ_OBRA    := oJson:obra
								STJ->(MsUnlock())
							EndIf 
		
						Else
							lRet := .F.	
							cRet := "400 - "
							cMsg := "Ordem de servico nao encontrada"						
						EndIf
					Else	
						lRet := .F.	
						cRet := "400 - "
						cMsg := "Projeto ou Obra nao encontados"						
					EndIf
				EndIf
			Endif
		EndIf

	End Sequence


	If Empty(cRet) .AND. lRet
		cRet := "200 - "
		cMsg := "Ordem de Servico informado atualizado com sucesso "
	EndIf                              
    
	::SetResponse(Alltrim(FWhttpEncode('{"Retorno":"'+cRet+'", "Dados":"'+cMsg+'"}' )))

Return .T.
