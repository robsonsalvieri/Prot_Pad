#INCLUDE 'PROTHEUS.CH'

#DEFINE SITUACAO_CRIADO		'1'
#DEFINE SITUACAO_EMITIDO	'2'
#DEFINE SITUACAO_ENVIADO	'3'
#DEFINE SITUACAO_CONFIRMADO	'4'
#DEFINE SITUACAO_ENCERRADO	'5'
#DEFINE SITUACAO_CANCELADO	'6'

Function GFESituation()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFESituation()

@author
@since 12/6/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFESituation FROM LongNameClass 

	DATA cTitleWindow
	DATA cTitleCombo
	DATA cBtnConfirm
	DATA cBtnCancel
	DATA aListSituation
	DATA cSituation
	DATA lStatus
	DATA cMensagem
	DATA lOk
	DATA cCurrentSituation
	DATA cNewSituation
	DATA cNumberContract
	DATA cCondicaoEncerramento
	DATA cJustificativa

	METHOD New() CONSTRUCTOR
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD choiceSituation()
	METHOD createWindow()
	METHOD closeWindows()

	METHOD setTitleWindow(cTitleWindow)
	METHOD setTitleCombo(cTitleCombo)
	METHOD setBtnConfirm(cBtnConfirm)
	METHOD setBtnCancel(cBtnCancel)
	METHOD setListSituation(aListSituation)
	METHOD setSituation(cNewSituation, oDlg)
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setOk(lOk)
	METHOD setCurrentSituation(cSituation)
	METHOD setNewSituation(cSituation)
	METHOD setNumberContract(cNumberContract)
	METHOD setCondicaoEncerramento(cCondicaoEncerramento)
	METHOD setJustificativa(cJustificativa)

	METHOD getTitleWindow()
	METHOD getTitleCombo()
	METHOD getBtnConfirm()
	METHOD getBtnCancel()
	METHOD getListSituation()
	METHOD getSituation()
	METHOD getStatus()
	METHOD getMensagem()
	METHOD getOk()
	METHOD getCurrentSituation()
	METHOD getNewSituation()	
	METHOD getNumberContract()
	METHOD getCondicaoEncerramento()
	METHOD getJustificativa()
	
	METHOD hasRomaneio()
	METHOD hasRequisicaoAgro()
	METHOD validSituation()
ENDCLASS

METHOD New() Class GFESituation
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFESituation
	FreeObj(oObject)
Return

METHOD ClearData() Class GFESituation
	Self:setTitleWindow("")
	Self:setTitleCombo("")
	Self:setBtnConfirm("Salvar")
	Self:setBtnCancel("Cancelar")
	Self:aListSituation	:= {}
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:setOk(.T.)
	Self:setCurrentSituation("")
	Self:setNewSituation("")
	Self:setNumberContract("")
	Self:setCondicaoEncerramento("")
	Self:setJustificativa('')
Return

METHOD choiceSituation() CLASS GFESituation
	Self:createWindow()
Return Self:getOk()

METHOD createWindow() CLASS GFESituation
	Local oComboBo
	Local nComboBo

   	DEFINE MSDIALOG oDlg TITLE Self:getTitleWindow() FROM 000,000 TO 220,271 PIXEL
   		
		If(Self:getTitleCombo() != "")
			@ 4, 006  SAY Self:getTitleCombo() SIZE 120,7 PIXEL OF oDlg
		EndIf 
		@ 12, 05 MSCOMBOBOX oComboBo VAR nComboBo ITEMS Self:getListSituation() SIZE 100, 010 OF oDlg PIXEL 
		@ 30, 05 SAY 'Justificativa' SIZE 120,7 PIXEL OF oDlg
		@ 38, 05 GET Self:cJustificativa TEXT SIZE 100, 040 OF oDlg PIXEL WHEN (nComboBo == '6')
		@ 88, 05 BUTTON Self:getBtnConfirm() SIZE 27 , 012 PIXEL OF oDlg ACTION(Self:setSituation(nComboBo,oDlg))
		@ 88, 35 BUTTON Self:getBtnCancel() SIZE 27, 012 PIXEL OF oDlg ACTION(Self:closeWindow(oDlg))
		 
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return

METHOD closeWindows() CLASS GFESituation
	Self:setOk(.F.)
	oDlg:End()
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setSituation(cNewSituation, oDlg) CLASS GFESituation
	Self:setOk(.T.)
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:cSituation := cNewSituation
	oDlg:End()
Return

METHOD setTitleWindow(cTitleWindow) CLASS GFESituation
	Self:cTitleWindow := cTitleWindow
Return
METHOD setTitleCombo(cTitleCombo) CLASS GFESituation
	Self:cTitleCombo := cTitleCombo
Return
METHOD setBtnConfirm(cBtnConfirm) CLASS GFESituation
	Self:cBtnConfirm := cBtnConfirm
Return
METHOD setBtnCancel(cBtnCancel) CLASS GFESituation
	Self:cBtnCancel := cBtnCancel
Return
METHOD setListSituation(aListSituation) CLASS GFESituation
	Self:aListSituation := aListSituation
Return
METHOD setStatus(lStatus) CLASS GFESituation
	Self:lStatus := lStatus
Return
METHOD setMensagem(cMensagem) CLASS GFESituation
	Self:cMensagem := cMensagem
Return
METHOD setOk(lOk) CLASS GFESituation
	Self:lOk := lOk
Return
METHOD setCurrentSituation(cSituation) CLASS GFESituation
	Self:cCurrentSituation := cSituation
Return
METHOD setNewSituation(cSituation) CLASS GFESituation
	Self:cNewSituation := cSituation
Return
METHOD setNumberContract(cNumberContract) CLASS GFESituation
	Self:cNumberContract := cNumberContract
Return
METHOD setCondicaoEncerramento(cCondicaoEncerramento) CLASS GFESituation
	Self:cCondicaoEncerramento := cCondicaoEncerramento
Return
METHOD setJustificativa(cJustificativa) CLASS GFESituation
	Self:cJustificativa := cJustificativa
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getTitleWindow() CLASS GFESituation
Return Self:cTitleWindow

METHOD getTitleCombo() CLASS GFESituation
Return Self:cTitleCombo

METHOD getBtnConfirm() CLASS GFESituation
Return Self:cBtnConfirm

METHOD getBtnCancel() CLASS GFESituation
Return Self:cBtnCancel

METHOD getListSituation() CLASS GFESituation
Return Self:aListSituation

METHOD getSituation() CLASS GFESituation
Return Self:cSituation

METHOD getStatus() CLASS GFESituation
Return Self:lStatus

METHOD getMensagem() CLASS GFESituation
Return Self:cMensagem

METHOD getOk() CLASS GFESituation
Return Self:lOk

METHOD getCurrentSituation() CLASS GFESituation
Return Self:cCurrentSituation

METHOD getNewSituation() CLASS GFESituation
Return Self:cNewSituation

METHOD getNumberContract() CLASS GFESituation
Return Self:cNumberContract

METHOD getCondicaoEncerramento() CLASS GFESituation
Return Self:cCondicaoEncerramento

METHOD getJustificativa() CLASS GFESituation
Return Self:cJustificativa

//-----------------------------------
//Validators
//-----------------------------------
METHOD hasRomaneio() CLASS GFESituation
	Local hasRegistro := .F.
	Local aArea := GetArea()
	Local aAreaGXT := GXT->(GetArea())
	Local aAreaGWN := GWN->(GetArea())

	If Empty( Self:getNumberContract() )
		Self:setStatus(.F.)
		Self:setMensagem('É necessário informar o Número do Contrato.')
		Return .F.
	EndIf	

	BeginSql Alias 'QryGWN'
	SELECT
		TOP 1 1
	FROM
		%table:GXT% GXT
	INNER JOIN 
		%table:GWN% GWN
	ON
		GWN.GWN_FILIAL = GXT.GXT_FILIAL AND
		GWN.GWN_NRCT = GXT.GXT_NRCT
	Where
		GXT.GXT_FILIAL = %xFilial:GXT% AND
		GXT.GXT_NRCT =  %exp:Self:getNumberContract()% AND
		GXT.%NotDel% AND
		GWN.%NotDel%
	EndSql				

	QryGWN->( dbGotop() )
	hasRegistro := !QryGWN->( Eof() )
	
	QryGWN->(DbCloseArea())
	RestArea(aArea)
	RestArea(aAreaGXT)
	RestArea(aAreaGWN)

Return hasRegistro

METHOD hasRequisicaoAgro() CLASS GFESituation
	Local hasRegistro := .F.
	Local aArea := GetArea()
	Local aAreaGXT := GXT->(GetArea())
	Local aAreaGXS := GXS->(GetArea())
	Local aAreaGXR := GXR->(GetArea())

	If Empty( Self:getNumberContract() )
		Self:setStatus(.F.)
		Self:setMensagem('É necessário informar o Número do Contrato.')
		Return .F.
	EndIf	

	BeginSql Alias 'QryGXS'
	SELECT
		TOP 1 1
	FROM
		%table:GXT% GXT
	INNER JOIN 
		%table:GXS% GXS
	ON
		GXS.GXS_FILIAL = GXT.GXT_FILIAL AND
		GXS.GXS_NRCT = GXT.GXT_NRCT
	INNER JOIN
		%table:GXR% GXR
	ON
		GXR.GXR_FILIAL = GXS.GXS_FILIAL AND
		GXR.GXR_IDREQ = GXS.GXS_IDREQ AND
		GXR.GXR_TPIDEN = '5'
	Where
		GXT.GXT_FILIAL = %xFilial:GXT% AND
		GXT.GXT_NRCT =  %exp:Self:getNumberContract()% AND
		GXT.%NotDel% AND
		GXS.%NotDel% AND
		GXR.%NotDel%

	EndSql				

	QryGXS->( dbGotop() )
	hasRegistro := !QryGXS->( Eof() )

	QryGXS->(DbCloseArea())
	RestArea(aArea)
	RestArea(aAreaGXT)
	RestArea(aAreaGXS)
	RestArea(aAreaGXR)

Return hasRegistro

METHOD validSituation() CLASS GFESituation
	
	If Empty( Self:getCurrentSituation() )
		Self:setStatus(.F.)
		Self:setMensagem('É necessário informar a Situação atual do Contrato.')
		Return
	EndIf

	If Empty( Self:getNewSituation() )
		Self:setStatus(.F.)
		Self:setMensagem('É necessário informar a Situação nova do Contrato.')
		Return
	EndIf

	If Self:getNewSituation() == Self:getCurrentSituation()
		Self:setStatus(.T.)
		Return
	EndIf

	Do Case		
	Case Self:getNewSituation() == SITUACAO_CRIADO		
		
		If Self:getCurrentSituation() $ ( SITUACAO_EMITIDO + '|' + SITUACAO_ENVIADO + '|' + SITUACAO_CONFIRMADO ) 
			If Self:hasRomaneio()					
				Self:setStatus(.F.)
				Self:setMensagem('Não foi possível alterar a situação pois o contrato possui romaneio relacionado.')
				Return
			Else
				If Self:getStatus() == .F.
					Return
				EndIf
			EndIf
		Else
			Self:setStatus(.F.)				
			Self:setMensagem('Somente é possível alterar a situação para Criada quando ela estiver como Emitida, Enviada ou Confirmada.')
			Return
		EndIf

	Case Self:getNewSituation() == SITUACAO_EMITIDO
		
		If Self:getCurrentSituation() == SITUACAO_ENVIADO
			If Self:hasRomaneio()					
				Self:setStatus(.F.)
				Self:setMensagem('Não foi possível alterar a situação pois o contrato possui romaneio relacionado.')
				Return
			Else
				If Self:getStatus() == .F.
					Return
				EndIf					
			EndIf
		Else
			Self:setStatus(.F.)				
			Self:setMensagem('Somente é possível alterar a situação para Emitida se ela estiver como Enviada.')
			Return
		EndIf

	Case Self:getNewSituation() == SITUACAO_ENVIADO

		If Self:getCurrentSituation() == SITUACAO_CONFIRMADO
			If Self:hasRomaneio()					
				Self:setStatus(.F.)
				Self:setMensagem('Não foi possível alterar a situação pois o contrato possui romaneio relacionado.')
				Return
			Else
				If Self:getStatus() == .F.
					Return
				EndIf				
			EndIf
		Else
			Self:setStatus(.F.)				
			Self:setMensagem('Somente é possível alterar a situação para Enviada se ela estiver como Confirmada.')
			Return
		EndIf	

	Case Self:getNewSituation() == SITUACAO_CONFIRMADO
		
		If .Not. Self:getCurrentSituation() $ ( SITUACAO_ENVIADO + '|' + SITUACAO_ENCERRADO + '|' + SITUACAO_CANCELADO )
			Self:setStatus(.F.)				
			Self:setMensagem('Somente é possível alterar a situação para Confirmada se ela estiver como Enviada, Encerrada ou Cancelada.')
			Return
		EndIf

	Case Self:getNewSituation() == SITUACAO_ENCERRADO
		
		If Self:getCondicaoEncerramento() == '1'	// Manual
			If Self:hasRequisicaoAgro()
				Self:setStatus(.F.)
				Self:setMensagem('Não foi possível alterar a situação pois o contrato possui Requisição de Agronegócio relacionada.')
				Return
			Else
				// Tratamento de exceção
				If Self:getStatus() == .F.
					Return
				EndIf				
			EndIf
		Else
			Self:setStatus(.F.)				
			Self:setMensagem('Somente é possível alterar a situação para Encerrada se a Condição de Encerramento for Manual.')
			Return
		EndIf

	Case Self:getNewSituation() == SITUACAO_CANCELADO
		
		If Empty(Self:cJustificativa)
			Self:setStatus(.F.)
			Self:setMensagem('É necessário informar a Justificativa ao cancelar o contrato.')
			Return		
		EndIf

		If Self:getCurrentSituation() != SITUACAO_ENCERRADO
			If Self:hasRomaneio()					
				Self:setStatus(.F.)
				Self:setMensagem('Não foi possível alterar a situação pois o contrato possui romaneio relacionado.')
				Return
			Else
				// Tratamento de exceção
				If Self:getStatus() == .F.
					Return
				EndIf				
			EndIf
		Else
			Self:setStatus(.F.)				
			Self:setMensagem('Somente é possível alterar a situação para Cancelada se ela não estiver Encerrada.')
			Return			
		EndIf

	EndCase

	Self:setStatus(.T.)
	
Return