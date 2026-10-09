#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW051.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Aprovação de minuta
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 25/02/2026
/*/
WSRESTFUL LOCW051 DESCRIPTION "Aprovacao das Minutas"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para aprovacao das Minutas.</h2>" WSSYNTAX "/LOCW051"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW051
ITUP BUSINESS - TOTVS RENTAL
API - Aprovação de minuta
@TYPE FUNCTION
@AUTHOR Frank Zwarg Fuga
@SINCE 25/02/2026
/*/
WSMETHOD POST WSSERVICE LOCW051
Local bError := {||}
Local cRet := ""
Local cBody := DecodeUtf8(::GetContent())
Local aEmp := {}
Local cFonte := "LOCW051.PRW"
Local aInfo := GetAPOInfo(cFonte)
Local lLog := .F.
Local cAmb //"ambiente"
Local cLog //"login_inclusao"
Local cCli //"cliente_nome"
Local cCpf //"cliente_cpf"
Local cEma //"cliente_email"
Local cApo //"data_apontamento"
Local cLat //"gps_latitude"
Local cLon //"gps_longitude"
Local cHor //"gps_horario"
Local cClima //"clima_condicao"
Local cTempe //"clima_temperatura"
Local cAlmoI //"almoco_inicio"
Local cAlmoF //"almoco_fim"
Local cJantI //"janta_inicio"
Local cJantF //"janta_fim"
Local aPeriodos //Periodos apontados
Local aMidias //Mídias
Local aAssina //Assinaturas
Local aExecAuto := {}
Local nX
Local cAssina
Local cMidias
Local aRetorno := {}
Local cRetorno 
Local aAreaFPF

Private lMsErroAuto := .F.
Private cMsErroAuto := ""
Private oJson := Nil

	If FWJsonDeserialize(cBody,@oJson)

		aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cnpj_empresa,".",""),"/",""),"-",""))
		lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa já existente.")
		
		If lLog

			cRet := xAbreEnv1(aEmp[1],aEmp[2])
			
			If Empty(cRet)   

				cAmb := oJson:ambiente
				cLog := oJson:login_inclusao
				cCli := oJson:cliente_nome
				cCpf := oJson:cliente_cpf
				cEma := oJson:cliente_email
				cApo := oJson:data_apontamento
				cLat := oJson:gps_latitude
				cLon := oJson:gps_longitude
				cHor := oJson:gps_horario
				cClima := oJson:clima_condicao
				cTempe := oJson:clima_temperatura
				cAlmoI := oJson:almoco_inicio
				cAlmoF := oJson:almoco_fim
				cJantI := oJson:janta_inicio
				cJantF := oJson:janta_fim
				aPeriodos := oJson:periodos_apontados
				aMidias := oJson:midias
				aAssina := oJson:assinatura

				cAssina := ""
				For nX := 1 to len(aAssina)
				   oTemp := aAssina[nX]
				   cAssina += "NOME: "+oTemp:NOME + CHR(13)+CHR(10)
				   cAssina += "URL: "+oTemp:URL + CHR(13)+CHR(10)
				   cAssina += CHR(13)+CHR(10)
				Next

				cMidias := ""
				For nX := 1 to len(aMidias)
					oTemp := aMidias[nX]
					cMidias += "NOME: "+oTemp:NOME + CHR(13)+CHR(10)
					cMidias += "URL: "+oTemp:URL + CHR(13)+CHR(10)
					cMidias += CHR(13)+CHR(10)
				Next

				aRetorno := {}
				For nX := 1 to len(aPeriodos)

					oTemp := aPeriodos[nX]
					
					// A validação do oTemp:ID é feita no msExecAuto
					// As demais validações de horário e conflitos são feitas no msExecAuto
					FPF->(dbSetOrder(2))
					FPF->(dbSeek(xFilial("FPF")+oTemp:ID)) 
					
					aExecAuto := {}
					aadd(aExecAuto,oTemp:ID) // código da minuta
					aadd(aExecAuto,oTemp:inicio) // hora inicial 
					aadd(aExecAuto,oTemp:fim) // hora final
					aadd(aExecAuto,oTemp:parada) // hora parada
					aadd(aExecAuto,oTemp:motivo_parada) // motivo da parada 
					aadd(aExecAuto,cAlmoI) // almoço inicial
					aadd(aExecAuto,cAlmoF) // almoço final
					aadd(aExecAuto,cJantI) // jantar inicial
					aadd(aExecAuto,cJantF) // jantar final
					aadd(aExecAuto,oTemp:obs) // observação
					aadd(aExecAuto,"B") // operação de baixa

					cMsErroAuto := ""
					lMsErroAuto := .F.
					aAreaFPF := FPF->(GetArea()) // manter o posicionamento, pois a rotina LOCA005 o desfaz.
					msExecAuto({|A| LOCA005(A)}, aExecAuto)
					FPF->(RestArea(aAreaFPF))

					If lMsErroAuto
						aadd(aRetorno,{oTemp:ID, ".F.", cMsErroAuto})
						lRet := .F.
					Else
						If FPF->FPF_STATUS <> "3" .or. file("\SYSTEM\L051E1.TXT")
							aadd(aRetorno,{oTemp:ID, ".F.", "Nao foi possivel baixar o registro"})
							lRet := .F.
						Else
							aadd(aRetorno,{oTemp:ID, ".T.", "Minuta baixada"})
							// Se foi possível baixar atualizar os demais campos da FPF
							FPF->(RecLock("FPF",.F.))
							FPF->FPF_NOMPF  := cCli
							FPF->FPF_CPF    := cCpf
							FPF->FPF_EMAIL  := cEma
							FPF->FPF_LINK   := ""
							FPF->FPF_APIAMB := cAmb 
							FPF->FPF_APILOG := cLog
							FPF->FPF_APIDAP := ctod( substr(cApo,9,2) + "/" + substr(cApo,6,2) + "/" + substr(cApo,1,4) )
							FPF->FPF_APIHAP := substr(cApo,12,8)
							FPF->FPF_APIGLA := cLat
							FPF->FPF_APIGLO := cLon
							FPF->FPF_APIDAT := ctod( substr(cHor,9,2) + "/" + substr(cHor,6,2) + "/" + substr(cHor,1,4) )
							FPF->FPF_APIHOR := substr(cHor,12,8)
							FPF->FPF_APICCO := cClima
							FPF->FPF_APITEM := cTempe
							FPF->FPF_APIMID := cMidias
							FPF->FPF_APIASS := cAssina
							FPF->(MsUnlock())
						EndIf
					EndIF
				Next

			EndIf
		Else
			cRet := "401 - "
			cMsg := "Credenciais invalidas"
		EndIf   
	EndIf    
    
    ErrorBlock(bError)

	If empty(cRet)
		cRetorno := '"Resultado": [' 
		For nX := 1 to len(aRetorno)
			if nX > 1
				cRetorno += ", "
			EndIf
			cRetorno += '{'
			cRetorno += '"Minuta":'
			cRetorno += '"'+aRetorno[nX,1]+'"'
			cRetorno += ','
			cRetorno += '"Status":'
			cRetorno += '"'+aRetorno[nX,2]+'"'
			cRetorno += ','
			cRetorno += '"Motivo":'
			cRetorno += '"'+aRetorno[nX,3]+'"'
			cRetorno += '}'
		Next
		cRetorno += "],"
		cRetorno += '"Compilado":'
		cRetorno += '"'+DtoS(aInfo[4])+'-'+aInfo[5]+'"'

		If empty(cRetorno) .or. file("\SYSTEM\L051E3.TXT")
			cRetorno := "422 - Nao foi processado nenhuma minuta"
		EndIf
	EndIF

	If empty(cRet)
		cRet := "Processado."
	EndIf
    
	::SetResponse( Alltrim( FWhttpEncode( '{"Retorno":"'+cRet+'",'+ cRetorno +'}' ) ) )
    
Return .T.
