#INCLUDE 'PROTHEUS.CH'
Function GFERomaneio()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFERomaneio()

@author
@since 23/4/2019
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFERomaneio FROM LongNameClass 

	DATA lStatus
	DATA cMensagem
	DATA cErroMensagem
	DATA cFilRom
	DATA cNrRom
	DATA cCdTpOp
	DATA cCdClFr
	DATA cCdTrp
	DATA cDtImpl

	METHOD New() CONSTRUCTOR
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD changeStatus()
	METHOD saveMessage()

	METHOD getNrDC()
	METHOD pesoItemNrDC()

	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setErroMensagem(cErroMensagem)
	METHOD setFilRom(cFilRom)
	METHOD setNrRom(cNrRom)
	METHOD setCdTpOp(cCdTpOp)
	METHOD setCdClFr(cCdClFr)
	METHOD setCdTrp(cCdTrp)
	METHOD setDtImpl(cDtImpl)

	METHOD getStatus()
	METHOD getMensagem()
	METHOD getErroMensagem()
	METHOD getFilRom()
	METHOD getNrRom()
	METHOD getCdTpOp()
	METHOD getCdClFr()
	METHOD getCdTrp()
	METHOD getDtImpl()

ENDCLASS

METHOD New() Class GFERomaneio
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFERomaneio
	FreeObj(oObject)
Return

METHOD ClearData() Class GFERomaneio
Return

METHOD changeStatus() CLASS GFERomaneio	
Return

METHOD saveMessage() CLASS GFERomaneio	
Return

METHOD getNrDC() CLASS GFERomaneio
	Local aDocs     := {}
	Local cAliasGW1 := Nil
	Local cNrRom    := Self:getNrRom()

	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT GW1.GW1_FILIAL,
				GW1.GW1_CDTPDC,
				GW1.GW1_EMISDC,
				GW1.GW1_SERDC,
				GW1.GW1_NRDC
		FROM %Table:GW1% GW1
		WHERE GW1.GW1_NRROM = %Exp:cNrRom%
		AND GW1.%NotDel%
	EndSql
	Do While (cAliasGW1)->(!Eof())
		AADD(aDocs, { (cAliasGW1)->GW1_FILIAL,(cAliasGW1)->GW1_CDTPDC,(cAliasGW1)->GW1_EMISDC,(cAliasGW1)->GW1_SERDC,(cAliasGW1)->GW1_NRDC})
		(cAliasGW1)->(dbSkip())
	EndDo
	(cAliasGW1)->(dbCloseArea())
Return aDocs

METHOD pesoItemNrDC() CLASS GFERomaneio
	Local cAliasGW8 := Nil
	Local cNrDc     := Self:getNrDC()
	Local nPeso     := 0

	cAliasGW8 := GetNextAlias()
	BeginSql Alias cAliasGW8
		SELECT GW8.GW8_PESOR
		FROM %Table:GW8% GW8
		WHERE GW8.GW8_NRDC = %Exp:cNrDc%
		AND GW8.%NotDel%
	EndSql
	If (cAliasGW8)->(!Eof())
		nPeso := (cAliasGW8)->GW8_PESOR
	EndIf
	(cAliasGW8)->(dbCloseArea())
Return nPeso

//-----------------------------------
//Setters
//-----------------------------------
METHOD setStatus(lStatus) CLASS GFERomaneio
	Self:lStatus := lStatus
Return
METHOD setMensagem(cMensagem) CLASS GFERomaneio
	Self:cMensagem := cMensagem
Return
METHOD setErroMensagem(cErroMensagem) CLASS GFERomaneio
	Self:cErroMensagem := cErroMensagem
Return
METHOD setFilRom(cFilRom) CLASS GFERomaneio
	Self:cFilRom := cFilRom
Return
METHOD setNrRom(cNrRom) CLASS GFERomaneio
	Self:cNrRom := cNrRom
Return
METHOD setCdTpOp(cCdTpOp) CLASS GFERomaneio
	Self:cCdTpOp := cCdTpOp
Return
METHOD setCdClFr(cCdClFr) CLASS GFERomaneio
	Self:cCdClFr := cCdClFr
Return
METHOD setCdTrp(cCdTrp) CLASS GFERomaneio
	Self:cCdTrp := cCdTrp
Return
METHOD setDtImpl(cDtImpl) CLASS GFERomaneio
	Self:cDtImpl := cDtImpl
Return

//-----------------------------------
//Getters
//-----------------------------------
METHOD getStatus() CLASS GFERomaneio
Return Self:lStatus

METHOD getMensagem() CLASS GFERomaneio
Return Self:cMensagem

METHOD getErroMensagem() CLASS GFERomaneio
Return Self:cErroMensagem

METHOD getFilRom() CLASS GFERomaneio
Return Self:cFilRom

METHOD getNrRom() CLASS GFERomaneio
Return Self:cNrRom

METHOD getCdTpOp() CLASS GFERomaneio
Return Self:cCdTpOp

METHOD getCdClFr() CLASS GFERomaneio
Return Self:cCdClFr

METHOD getCdTrp() CLASS GFERomaneio
Return Self:cCdTrp

METHOD getDtImpl() CLASS GFERomaneio
Return Self:cDtImpl

