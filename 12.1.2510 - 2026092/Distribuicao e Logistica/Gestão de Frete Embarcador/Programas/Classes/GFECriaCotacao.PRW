#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFECriaCotacao()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFECriaCotacao()

@author Leonardo Ribas Jimenez Hernandez
@since 21/08/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFECriaCotacao FROM LongNameClass 

	DATA lStatus
	DATA cMensagem
	DATA cErroMensagem
	
	DATA cCdTrp
	DATA cCodRef
	DATA cFilRef
	DATA nFrtCot
	DATA cOriCot

	METHOD New() CONSTRUCTOR
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD ConCriaCot(aCotFrt,oModel)
	METHOD BuscaCotacao(oModel)
	
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setErroMensagem(cMensagem)

	METHOD setCdTrp(cCdTrp)
	METHOD setCodRef(cCodRef)
	METHOD setFilRef(cFilRef)
	METHOD setFrtCot(nFrtCot)
	METHOD setOriCot(cOriCot)
	
	METHOD getStatus()
	METHOD getMensagem()
	METHOD getErroMensagem()
	
	METHOD getCdTrp()
	METHOD getCodRef()
	METHOD getFilRef()
	METHOD getFrtCot()
	METHOD getOriCot()

ENDCLASS

METHOD New() Class GFECriaCotacao
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFECriaCotacao
	FreeObj(oObject)
Return

METHOD ClearData() Class GFECriaCotacao
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:setErroMensagem("")
Return

METHOD ConCriaCot(aCotFrt,oModel) CLASS GFECriaCotacao
	Local oModelGXS := oModel:GetModel("GFEA078_GXS")
	Local nX := 0

	For nX := 1 To Len(aCotFrt)
 		If nX > 1 .Or. (oModelGXS:Length(.F.) > 0 .And. oModelGXS:Length(.T.) == 0)
			oModelGXS:AddLine()
 		EndIf
		 
		If !oModelGXS:SetValue("GXS_CODREF",AllTrim(aCotFrt[nX][1]))
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf

		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_CDTRP",AllTrim(aCotFrt[nX][2]))
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
			
		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_FILREF",AllTrim(aCotFrt[nX][3]))
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
			
		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_FRTCOT",aCotFrt[nX][4])
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
			
		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_ORICOT",Self:getOriCot())
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf	
		
		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_SEQ",PadL(cValToChar(nX), TamSX3("GXS_SEQ")[1], "0"))
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
		
		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_TPPRAZ",aCotFrt[nX][5])
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
		
		If Self:getStatus() .And. !oModelGXS:SetValue("GXS_PRAZO",aCotFrt[nX][6])
			Self:setStatus(.F.)
			Self:setMensagem(oModel:getErrorMessage()[6])
		EndIf
		
		If GFXCP12123("GXS_UMPESO")
			If Self:getStatus() .And. !oModelGXS:SetValue("GXS_UMPESO",aCotFrt[nX][8])
				Self:setStatus(.F.)
				Self:setMensagem(oModel:getErrorMessage()[6])
			EndIf
		EndIf
	Next nX

	oModelGXS:SeekLine({{"GXS_SEQ","01"}})

Return

METHOD BuscaCotacao(oModel) CLASS GFECriaCotacao
	Local oModelGXS := oModel:GetModel("GFEA078_GXS")
	
	If oModelGXS:Length(.T.) > 0 .And. !Empty(oModelGXS:GetValue('GXS_CDTRP'))
		Self:setStatus(.F.)
	EndIf
Return
//-----------------------------------
//Setters
//-----------------------------------
METHOD setStatus(lStatus) CLASS GFECriaCotacao
   Self:lStatus := lStatus
Return
METHOD setCdTrp(cCdTrp) CLASS GFECriaCotacao
	Self:cCdTrp := cCdTrp
Return
METHOD setCodRef(cCodRef) CLASS GFECriaCotacao
	Self:cCodRef := cCodRef
Return
METHOD setFilRef(cFilRef) CLASS GFECriaCotacao
	Self:cFilRef := cFilRef
Return
METHOD setFrtCot(nFrtCot) CLASS GFECriaCotacao
	Self:nFrtCot := nFrtCot
Return
METHOD setOriCot(cOriCot) CLASS GFECriaCotacao
	Self:cOriCot := cOriCot
Return
METHOD setMensagem(cMensagem) CLASS GFECriaCotacao
   Self:cMensagem := cMensagem
Return
METHOD setErroMensagem(cErroMensagem) CLASS GFECriaCotacao
   Self:cErroMensagem := cErroMensagem
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getStatus() CLASS GFECriaCotacao
Return Self:lStatus

METHOD getCdTrp() CLASS GFECriaCotacao
Return Self:cCdTrp

METHOD getCodRef() CLASS GFECriaCotacao
Return Self:cCodRef

METHOD getFilRef() CLASS GFECriaCotacao
Return Self:cFilRef

METHOD getFrtCot() CLASS GFECriaCotacao
Return Self:nFrtCot

METHOD getOriCot() CLASS GFECriaCotacao
Return Self:cOriCot

METHOD getMensagem() CLASS GFECriaCotacao
Return Self:cMensagem

METHOD getErroMensagem() CLASS GFECriaCotacao
Return Self:cErroMensagem
