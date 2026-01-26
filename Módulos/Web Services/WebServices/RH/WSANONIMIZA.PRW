#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "WSANONIMIZA.CH"

WSSERVICE ANONIMIZA DESCRIPTION STR0001
	WSDATA CPF			AS String
	WSDATA Nome			AS String
	WSDATA Email		AS String
	WSDATA Observacao	AS String	
	
	WSDATA ContHtml		AS String
	
	WSMETHOD PutSolic	DESCRIPTION STR0002
ENDWSSERVICE                                  


WSMETHOD PutSolic WSRECEIVE CPF, Nome, Email, Observacao WSSEND ContHtml WSSERVICE ANONIMIZA

	Local lret := .F.
	Local nx := 4
	Local ny := 1
	Local aCampos := {"TMP_CPF", "TMP_NOME", "TMP_EMAIL", "TMP_OBS"}
	Local aDados  := {CPF, Nome, Email, Observacao}

	DbSelectArea("RH3")
	Begin Transaction
		RecLock("RH3",.T.)
			RH3->RH3_FILIAL 	:= xFilial("RH3")
			RH3->RH3_CODIGO 	:= GetSX8Num("RH3", "RH3_CODIGO",RetSqlName("RH3"))
			RH3->RH3_MAT	   	:= ""
			RH3->RH3_TIPO		:= "X" //ANONIMIZACAO
			RH3->RH3_ORIGEM		:= "PORTAL"
			RH3->RH3_STATUS		:= "1" 
			RH3->RH3_DTSOLI		:= dDataBase
			RH3->RH3_FILINI		:= SRA->RA_FILIAL
			RH3->RH3_MATINI		:= ""
			RH3->RH3_EMPAPR		:= cEmpAnt
			RH3->RH3_EMPINI		:= cEmpAnt
			RH3->RH3_EMP		:= cEmpAnt
		RH3->(MsUnLock())

		
		for ny:= 1 to nx
			RecLock("RH4",.T.)
				RH4_FILIAL := xFilial("RH4")
				RH4_CODIGO := RH3->RH3_CODIGO
				RH4_ITEM	:= ny
				RH4_CAMPO	:= aCampos[ny]
				RH4_VALANT	:= "" 
				RH4_VALNOV	:= aDados[ny]
			RH4->(MsUnLock())
		next ny
			
		lret := .T.

	End Transaction

	if lRet
		RH3->(ConfirmSX8())
	ENDIF

return lret