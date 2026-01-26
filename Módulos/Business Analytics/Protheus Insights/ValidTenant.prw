#Include "Protheus.ch"

//#Define ALGORITHMS {{'SHA256', 5}, {'SHA512', 7}}

/*/{Protheus.doc} Jwt
  
  JsonWebToken for Protheus using ADVPL
  @author Danilo Santos
  @since 01/06/2023
  @version P12
/*/

Class ValidPermission from LongNameClass
  Data cJWT
  //Data cSecret
  //Data cAlgorithm
  //Data nAlgorithm
  Method New() Constructor
  Method ReadI14()
  Method VerifyPermissionInsight()
EndClass

/*/{Protheus.doc} New
  
  Constructor Method
  @author DANILO SANTOS
  @since 02/07/2023
  @version P12
  @param cSecret, String, Secret Key that will be used to generate the hash by HMAC
  @return Self
  /*/
Method New() Class ValidPermission
  //::cAlgorithm := ""
  //::nAlgorithm := 0
  //::cSecret := ""
  ::cJWT := ""
Return Self
/*/{Protheus.doc} Sign
  
  Returns a JsonWebToken as string
  
  @author DANILO SANTOS
  @since 02/07/2023
  @version P12
  @param  oPayload, Object, An object from JsonObject
  @return cToken, String, A new JsonWebToken
  /*/
Method ReadI14(cTenant) class ValidPermission
  Local cRAW := ""
 
  cRAW := VldTenantI14(cTenant)   //(cTenantClient)
  Self:cJWT := cRAW
Return cRAW


/*/{Protheus.doc} Verify
  
  Returns if JsonWebToken is valid. If JsonWebToken is true and the param oPay is provided, oPay will be populated
    with a JsonObject
  @author DANILO SANTOS
  @since 02/07/2023
  @version P12
  /*/
Method VerifyPermissionInsight(self) class ValidPermission

Local aParts := StrTokArr(self:cJWT, '.')
Local cPayload := ""
Local lTValid := .F.
Local oJsonA

If Len(aParts) > 0
    cPayload := aParts[2]
    cSign := StrTran(decode64(cPayload), "=", "")
    oJsonA := JsonObject():new()
    cParseRes := oJsonA:fromJson(cSign)

    lTValid := alltrim(str(oJsonA['exp'])) > FWTimeStamp(4, DATE(), TIME())
Endif 
Return lTValid


Function VldTenantI14(cTenant)
    
	Local cQuery 		  As Character
 	Local cNextAlias 	As Character 
  Local cJWTPerm := ""
  
  Default cTenant := ""
  cNextAlias := GetNextAlias()

  cQuery := "SELECT * "
  cQuery += " FROM " + RetSqlName("I14") + " I14 "
  cQuery += " WHERE "
  cQuery += " I14.I14_FILIAL = '" + SPACE(TAMSX3("I14_FILIAL" )[1]) + "' AND"
  cQuery += " I14.I14_RACTEN = '" + cTenant + "' AND"	//RacTenant
  cQuery += " I14.I14_REQTYP = 'PER' AND"
  cQuery += " I14.D_E_L_E_T_ = ' ' "

  cQuery := ChangeQuery(cQuery)

  dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cNextAlias, .F.,.T. )

	If (cNextAlias)->(!Eof())
		nRecI14 := (cNextAlias)->R_E_C_N_O_
		DbSelectArea('I14')
		DbSetOrder(1)
		dbgoto(nRecI14)
		cJWTPerm := I14->I14_MSGRAW
		I14->(dbCloseArea())
    (cNextAlias)->(dbCloseArea())
	EndIf

Return cJWTPerm
