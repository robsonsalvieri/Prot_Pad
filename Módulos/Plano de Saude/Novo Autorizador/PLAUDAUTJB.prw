#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"

//-----------------------------------------------------------------
/*/{Protheus.doc} PLAUDAUTJB
 Schedule para job
Função que chama o Job de comunicação para atualizar o status do parecer da auditoria no novo autorizador
(criado novo fonte para criacao do SchedDef e o nome do fonte deve ser o mesmo do Job)

@author renan.almeida
@since 06/05/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Function PLAUDAUTJB()

	Local cCodOpe := PlsIntPad()

	if LockByName('PLJBAUDAUT' + cCodOpe,.T.,.F.)
		PLJBAUDAUT()
		UnLockByName('PLJBAUDAUT' + cCodOpe) //Libera semaforo
	else
		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] O processo PLJBAUDAUT ainda esta em execucao","auditoria_novo_autorizador.log")
	endIf

	BE4->(dbSetOrder(1))
	if BE4->(FieldPos("BE4_COMAUT")) > 0
		if LockByName('PLJBINTAUT' + cCodOpe,.T.,.F.)
			PLJBINTAUT()
			UnLockByName('PLJBINTAUT' + cCodOpe)
		else
			PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] O processo PLJBINTAUT ainda esta em execucao","upd_intern_novo_autorizador.log")
		endIf
	endIf
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
 Schedule para job
 
@author renan.almeida
@since 06/05/2020
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
	Local aOrd   := {}
	Local aParam := {}

	aParam := { 'P','PARAMDEF','',aOrd,'PLAUDAUTJB'}
    
Return aParam