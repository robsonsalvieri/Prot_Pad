#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"

Function GFEContratoRomaneio()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFEContratoRomaneio()

@author Leonardo Ribas Jimenez Hernandez
@since 31/01/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFEContratoRomaneio FROM LongNameClass  

	DATA lStatus 
	DATA cMensagem
	DATA cErroMensagem
	
	DATA cNrCt
	DATA cNrNota
	DATA cFilNF
	DATA cNumNF
	DATA cSerNF

	METHOD New() CONSTRUCTOR
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD BuscaContrato()
	
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setErroMensagem(cMensagem)

	METHOD setNrCt(cNrCt)
	METHOD setNrNota(cNrNota)
	METHOD setFilNF(cFilNF)
	METHOD setNumNF(cNumNF)
	METHOD setSerNF(cSerNF)

	METHOD getStatus()
	METHOD getMensagem()
	METHOD getErroMensagem()
	METHOD getFilNF() 
	METHOD getNumNF()
	METHOD getSerNF()
	
	METHOD getNrCt()
	METHOD getNrNota()

ENDCLASS

METHOD New() Class GFEContratoRomaneio
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEContratoRomaneio
	FreeObj(oObject)
Return

METHOD ClearData() Class GFEContratoRomaneio
	Self:setStatus(.T.)
	Self:setMensagem("")
	Self:setErroMensagem("")
	Self:setNrCt("")
	Self:setNrNota("")
	Self:setFilNF("")
	Self:setNumNF("")
	Self:setSerNF("")
Return

METHOD BuscaContrato() CLASS GFEContratoRomaneio

	Local cNrCt := ""
	Local cFilNF := ""
	Local cNumNF := ""
	Local cSerNF := ""

	cFilNF := Self:getFilNF() 
	cNumNF := Self:getNumNF()
	cSerNF := Self:getSerNF()

	If !Empty(cFilNF) .And. !Empty(cNumNF) .And. !Empty(cSerNF)
		aRetorno := AXCTRFRT(cFilNF, cNumNF, cSerNF)

		cFilReq := aRetorno[1]
		cReqFre := aRetorno[2]

		GXS->(dbSetOrder(01))
		If GXS->(dbSeek(cFilReq + cReqFre ))
			cAliasGXS := GetNextAlias()
			cQuery := "SELECT GXS_NRCT"
			cQuery += " FROM " + RetSQLName("GXS")
			cQuery += " WHERE GXS_FILIAL =  '" + cFilReq + "' AND "
			cQuery += "       GXS_IDREQ = '" + cReqFre + "' AND "
			cQuery += "       GXS_MRKBR = 'T' AND "
			cQuery += "       D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGXS, .F., .T.)
			
			(cAliasGXS)->(dbGoTop())
			If (cAliasGXS)->(!Eof())
				cNrCt := (cAliasGXS)->GXS_NRCT
			End
		
			If Select(cAliasGXS) <> 0
				(cAliasGXS)->(dbCloseArea())
			EndIf
		
		EndIf

		Self:setNrCt(cNrCt)
	EndIf

Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setStatus(lStatus) CLASS GFEContratoRomaneio
   Self:lStatus := lStatus
Return
METHOD setNrCt(cNrCt) CLASS GFEContratoRomaneio
	Self:cNrCt := cNrCt
Return
METHOD setNrNota(cNrNota) CLASS GFEContratoRomaneio
	Self:cNrNota := cNrNota
Return
METHOD setFilNF(cFilNF) CLASS GFEContratoRomaneio
	Self:cFilNF := cFilNF
Return
METHOD setNumNF(cNumNF) CLASS GFEContratoRomaneio
	Self:cNumNF := cNumNF
Return
METHOD setSerNF(cSerNF) CLASS GFEContratoRomaneio
	Self:cSerNF := cSerNF
Return
METHOD setMensagem(cMensagem) CLASS GFEContratoRomaneio
   Self:cMensagem := cMensagem
Return
METHOD setErroMensagem(cErroMensagem) CLASS GFEContratoRomaneio
   Self:cErroMensagem := cErroMensagem
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getStatus() CLASS GFEContratoRomaneio
Return Self:lStatus

METHOD getNrCt() CLASS GFEContratoRomaneio
Return Self:cNrCt

METHOD getNrNota() CLASS GFEContratoRomaneio
Return Self:cNrNota

METHOD getFilNF() CLASS GFEContratoRomaneio
Return Self:cFilNF

METHOD getNumNF() CLASS GFEContratoRomaneio
Return Self:cNumNF

METHOD getSerNF() CLASS GFEContratoRomaneio
Return Self:cSerNF

METHOD getMensagem() CLASS GFEContratoRomaneio
Return Self:cMensagem

METHOD getErroMensagem() CLASS GFEContratoRomaneio
Return Self:cErroMensagem
