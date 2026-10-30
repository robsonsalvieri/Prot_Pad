#include "Totvs.ch"
#include "TopConn.ch"
#include "TbiConn.ch"
#include "Restful.ch"
#include "fileio.ch"

/*/{PROTHEUS.DOC} LOCW052.PRW
ITUP BUSINESS - TOTVS RENTAL
API - Cancelamento de minuta
@TYPE FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 26/02/2026
/*/
WSRESTFUL LOCW052 DESCRIPTION "Cancelamento das Minutas"

	WSMETHOD POST DESCRIPTION "<h2>Metodo para cancelamento das Minutas.</h2>" WSSYNTAX "/LOCW052"

END WSRESTFUL

/*/{PROTHEUS.DOC} LOCW052
ITUP BUSINESS - TOTVS RENTAL
API - Cancelamento de minuta
@TYPE FUNCTION
@AUTHOR Dennis Calabrez
@SINCE 26/02/2026
/*/
WSMETHOD POST WSSERVICE LOCW052
Local bError    := {||}
Local cRet      := ""
Local cMsg      := ""
Local cBody     := DecodeUtf8(::GetContent())
Local aEmp      := {}
Local cFonte    := "LOCW052.PRW"
Local aInfo     := GetAPOInfo(cFonte)
Local lLog      := .F.
Local nX        := 0
Local nCont     := 0
Local aRetorno  := {}
Local aPeriodos := {}
Local aExecAuto := {}
Local cRetorno  := ""
Local aAreaFPF
Local lRet      := .T.

Private lMsErroAuto := .F.
Private cMsErroAuto := ""
Private oJson       := Nil

	If FWJsonDeserialize(cBody, @oJson)

		aEmp := xVerEmp1(Replace(Replace(Replace(oJson:cancelamento:cnpj_empresa,".",""),"/",""),"-",""))
		lLog := if(len(aEmp)==4, aEmp[4], aEmp[3]=="Empresa ja existente.")

		If lLog

			cRet := xAbreEnv1(aEmp[1], aEmp[2])

			If Empty(cRet)

				aPeriodos := oJson:cancelamento:periodos_apontados

				aRetorno := {}
				For nX := 1 to len(aPeriodos)

					FPF->(dbSetOrder(2))
					FPF->(dbSeek(xFilial("FPF") + aPeriodos[nX]:ID))

					If FPF->(EOF())
						aadd(aRetorno, {aPeriodos[nX]:ID, "400", "Minuta nao encontrada"})
						lRet := .F.
					ElseIf FPF->FPF_STATUS == "3"
						aadd(aRetorno, {aPeriodos[nX]:ID, "400", "Minuta baixada, nao elegivel para cancelamento"})
						lRet := .F.
					ElseIf FPF->FPF_STATUS == "5"
						aadd(aRetorno, {aPeriodos[nX]:ID, "400", "Minuta ja cancelada"})
						lRet := .F.
					Else
						If lRet
							aExecAuto := {}
							AAdd(aExecAuto, PadR(AllTrim(aPeriodos[nX]:ID), TamSx3("FPF_MINUTA")[1]))  // [01] Numero da minuta
							AAdd(aExecAuto, PadR(AllTrim("02"), TamSx3("FPF_MOTCAN")[1]))  // [02] Motivo do cancelamento
							AAdd(aExecAuto, "")// [03] Nao utilizado
							AAdd(aExecAuto, "")// [04] Nao utilizado
							AAdd(aExecAuto, "")// [05] Nao utilizado
							AAdd(aExecAuto, "")// [06] Nao utilizado
							AAdd(aExecAuto, "")// [07] Nao utilizado
							AAdd(aExecAuto, "")// [08] Nao utilizado
							AAdd(aExecAuto, "")// [09] Nao utilizado
							AAdd(aExecAuto, "")// [10] Nao utilizado
							AAdd(aExecAuto, "C")// [11] Operacao: "C" = Cancelamento

							cMsErroAuto := ""
							lMsErroAuto := .F.
							aAreaFPF := FPF->(GetArea()) // manter o posicionamento, pois a rotina LOCA005 o desfaz.
							msExecAuto({|A| LOCA005(A)}, aExecAuto)
							FPF->(RestArea(aAreaFPF))
							aadd(aRetorno, {aPeriodos[nX]:ID, "200", "Minuta cancelada"})
							FPF->(RecLock("FPF",.F.))
							FPF->FPF_MOTIVO := oJson:cancelamento:motivo
							FPF->FPF_BXOBS  := oJson:cancelamento:observacao
							FPF->FPF_APIGLA := Str(oJson:cancelamento:geolocalizacao:latitude)
							FPF->FPF_APIGLO := Str(oJson:cancelamento:geolocalizacao:longitude)
							FPF->(MsUnlock())							
						EndIf
					EndIf
				Next
			EndIf
		Else
			cRet := "401 - "
			cMsg := "MINUTA_CANCEL_001|Credenciais invalidas"
		EndIf
	EndIf

	ErrorBlock(bError)

	If empty(cRet) 
		nX := 0
		cRetorno := '"Resultado": ['
		For nX := 1 to len(aRetorno)
            If nCont > 0
                cRetorno += ','
            EndIf			
			cRetorno += '{'
			cRetorno += '"Minuta":"'    + aRetorno[nX,1] + '",'
			cRetorno += '"Status":"'    + aRetorno[nX,2] + '",'
			cRetorno += '"Descricao":"' + aRetorno[nX,3] + '"'
			cRetorno += '}'
			nCont++
		Next
		cRetorno += "],"
		cRetorno += '"Compilado":"'
		cRetorno += DtoS(aInfo[4])+'-'+aInfo[5]+'"'

		If empty(cRetorno) .or. file("\SYSTEM\L052E3.TXT")
			cRetorno := "422 - Nao foi processado nenhuma minuta"
		EndIf
	EndIf

	If empty(cRet)
		cRet := "Processado."
	EndIf

	::SetResponse( Alltrim( FWhttpEncode( '{"Retorno":"'+cRet+'",'+ cRetorno +'}' ) ) )

Return .T.
