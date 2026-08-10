#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFERequisicaoFrete()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFERequisicaoFrete()

@author Leonardo Ribas Jimenez Hernandez
@since 29/5/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFERequisicaoFrete FROM LongNameClass 
	
	DATA cIdReq
	DATA cCodUsu
	Data cFil
	DATA cSitRes
	DATA cMotRej
	DATA cMotCanc
	DATA cNewSitRes
	DATA lStatus
	DATA cMensagem

	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD Destroy(oObject)
   
	METHOD ValNegociacao()
	METHOD validCancel()
	METHOD changeResultSituation()
	METHOD changeSituation()
	
	METHOD setIdReq(cIdReq)
	METHOD setCodUsu(cCodUsu)
	METHOD setFil(cFil)
	METHOD setSitRes(cSitRes)
	METHOD setMotRej(cMotRej)
	METHOD setMotCanc(cMotCanc)
	METHOD setNewSitRes(cNewSitRes)
   	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)

	METHOD getIdReq()
	METHOD getCodUsu()
	METHOD getFil()
	METHOD getSitRes()
	METHOD getMotRej()
	METHOD getMotCanc()
	METHOD getNewSitRes()
	METHOD getStatus()
	METHOD getMensagem()

ENDCLASS

METHOD New() Class GFERequisicaoFrete
   Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFERequisicaoFrete
   FreeObj(oObject)
Return

METHOD ClearData() Class GFERequisicaoFrete
	Self:setIdReq("")
	Self:setCodUsu("")
	Self:setFil("")
	Self:setSitRes("")
	Self:setMotRej("")
	Self:setNewSitRes("")
	Self:setStatus(.T.)
	Self:setMensagem("")
Return

//-----------------------------------
// Métodos de Negócio
//-----------------------------------
METHOD ValNegociacao() Class GFERequisicaoFrete
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
			
			If !Empty(GXR->GXR_CODUSU) .And. (AllTrim(GXR->(GXR_CODUSU)) <> Self:getCodUsu())
				Self:setStatus(.F.)
				Self:setMensagem("Esta requisição não está vinculada ao seu usuário.")
				Return
			EndIf
			
			If GXR->(GXR_SIT != "4")
				Self:setStatus(.F.)
				Self:setMensagem("A requisição está diferente do estado Atendida. Não é possível aceitar ou recusar essa negociação.")
				Return
			EndIf
			
			If GXR->(GXR_SITRES) == Self:getNewSitRes() .And. GXR->(GXR_SITRES) == "1"
				Self:setStatus(.F.)
				Self:setMensagem("A requisição já foi aceita.")
				Return
			ElseIf GXR->(GXR_SITRES) == Self:getNewSitRes() .And. GXR->(GXR_SITRES) == "2"
				Self:setStatus(.F.)
				Self:setMensagem("A requisição já foi recusada.")
				Return
			EndIf
			
			If GXR->(GXR_SITRES == "1")
				Self:setMensagem("Requisição já foi aceita.")
				Return
			ElseIf GXR->(GXR_SITRES == "2") 
				Self:setMensagem("Requisição já foi recusada.")
				Return
			EndIf
		EndIf
		
		Self:setStatus(.T.)
		Self:setMensagem("")
	EndIf	
Return

METHOD validCancel() Class GFERequisicaoFrete
	If (!Empty(Self:getIdReq()))
		GXR->(dbSetOrder(1))
		If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
		
			// Como a função é executada pela própria rotina, o registro já está posicionado.
			// quando a função for chamada externamente, deverá posicionar no registro para depois executar a ação.
			If !Empty(Self:getFil())
				GXR->(dbSetOrder(1))
				If !GXR->(dbSeek(Self:getFil() + Self:getIdReq()))
					Self:setMensagem("Requisição de Negociação de Frete não existe na base de dados! Verifique os dados informados. Filial:("+ Self:getFil() +") Requisição:("+ Self:getIdReq() +") ")
					Self:setStatus(.F.)
					Return
				EndIf
			EndIf
			
			If GXR->GXR_SIT == '5' //cancelada
				Self:setMensagem("Requisição de Negociação de Frete não pode ser cancelada, pois já se encontra nesta situação.")
				Self:setStatus(.F.)
				Return
			EndIf
			
			If GXR->GXR_SIT != "3" .And. GXR->GXR_SIT != "2" //em negociação e requisitada
				Self:setMensagem("A Requisição de Negociação de Frete não pode ser cancelada, pois somente requisições Em Negociação ou Requisitada podem ser canceladas.")
				Self:setStatus(.F.)
				Return
			EndIf
		EndIf
		Self:setStatus(.T.)
		Self:setMensagem("")
	EndIf	
Return

METHOD changeResultSituation() Class GFERequisicaoFrete
	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
		RecLock("GXR", .F.)
			GXR->GXR_SITRES	:= Self:getSitRes()
			GXR->GXR_MOTREJ 	:= Self:getMotRej()
		GXR->(MsUnlock())	
	EndIf
Return

METHOD changeSituation() Class GFERequisicaoFrete
	GXR->(dbSetOrder(1))
	If GXR->(dbSeek(xFilial("GXR") + Self:getIdReq()))
		RecLock("GXR", .F.)
			GXR->GXR_SIT		:= Self:getSitRes()
			GXR->GXR_MOTCAN 	:= Self:getMotCanc()
		GXR->(MsUnlock())	
	EndIf
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setIdReq(cIdReq) CLASS GFERequisicaoFrete
   Self:cIdReq := cIdReq
Return

METHOD setCodUsu(cCodUsu) CLASS GFERequisicaoFrete
   Self:cCodUsu := cCodUsu
Return

METHOD setFil(cFil) CLASS GFERequisicaoFrete
	Self:cFil := cFil
Return

METHOD setSitRes(cSitRes) CLASS GFERequisicaoFrete
   Self:cSitRes := cSitRes
Return

METHOD setMotRej(cMotRej) CLASS GFERequisicaoFrete
   Self:cMotRej := cMotRej
Return

METHOD setMotCanc(cMotCanc) CLASS  GFERequisicaoFrete
	Self:cMotCanc := cMotCanc
Return

METHOD setNewSitRes(cNewSitRes) CLASS GFERequisicaoFrete
   Self:cNewSitRes := cNewSitRes
Return

METHOD setStatus(lStatus) CLASS GFERequisicaoFrete
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFERequisicaoFrete
   Self:cMensagem := cMensagem
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getIdReq() CLASS GFERequisicaoFrete
Return Self:cIdReq

METHOD getCodUsu() CLASS GFERequisicaoFrete
Return Self:cCodUsu

METHOD getFil() CLASS GFERequisicaoFrete
Return Self:cFil

METHOD getSitRes() CLASS GFERequisicaoFrete
Return Self:cSitRes

METHOD getMotRej() CLASS GFERequisicaoFrete
Return Self:cMotRej

METHOD getMotCanc() CLASS GFERequisicaoFrete
Return Self:cMotCanc

METHOD getNewSitRes() CLASS GFERequisicaoFrete
Return Self:cNewSitRes

METHOD getStatus() CLASS GFERequisicaoFrete
Return Self:lStatus

METHOD getMensagem() CLASS GFERequisicaoFrete
Return Self:cMensagem