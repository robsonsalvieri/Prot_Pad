#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "restful.ch"
#INCLUDE "RUSRESTPRF.CH"

/*table is MP_SYSTEM_PROFILE*/
wsrestful rusrestprf description STR0005 FORMAT "application/json,text/html"

    WSDATA cProgram AS STRING OPTIONAL
    WSDATA ctaskPro AS STRING OPTIONAL
    WSDATA ctypePro AS STRING OPTIONAL
    WSDATA userCode AS STRING OPTIONAL

    //Create and update
    WSMETHOD POST postProfile ;
        DESCRIPTION STR0006 ;
        WSSYNTAX "profile/{Program}/{taskPro}/{typePro}";
        PATH "profile/{Program}/{taskPro}/{typePro}"  ;
        PRODUCES APPLICATION_JSON

    //Get profile information
    WSMETHOD GET getProfile ;
        DESCRIPTION STR0007 ;
        WSSYNTAX "profile/{Program}/{taskPro}/{typePro}";
        PATH "profile/{Program}/{taskPro}/{typePro}"  ;
        PRODUCES APPLICATION_JSON

    //delete
    WSMETHOD DELETE deleteProfile ;
        DESCRIPTION STR0008 ;
        WSSYNTAX "profile/{Program}/{taskPro}/{typePro}";
        PATH "profile/{Program}/{taskPro}/{typePro}"  ;
        PRODUCES APPLICATION_JSON 

end wsrestful

/*Post information at profile register*/
/*https://tdn.totvs.com/display/framework/FWProfile*/
WSMETHOD POST postProfile PATHPARAM Program,TaskPro,TypePro WSRECEIVE userCode WSSERVICE rusrestprf
    Local cBody 		:= self:getContent() As Character
    Local cCodUsrP 	    := "" As Character //Cod user to be saved profile
    Local cProgram 	    := "" As Character //Program name 
    Local ctaskPro  	:= "" As Character //task name at program
    Local ctypePro  	:= "" As Character
    Local oFwProfile	:= FWPROFILE():New() As Object
    Local oRet		    := JsonObject():New() As Object
    Local idProfile     := '' As Character

    Self:SetContentType("application/json")

    If Len(::aURLParms) <> 4 
        lRet := .F.
        SetRestFault(001, STR0001) // "Incorrect parameter count"
    Else
        /*Can be any format
        */
        If !Empty(cBody)
            cBody 		:= DecodeUTF8(cBody)
            cCodUsrP 	:= iif(empty(::userCode),__CUSERID,::userCode)
            cProgram 	:= ::aURLParms[2]
            ctaskPro  	:= ::aURLParms[3]
            ctypePro  	:= ::aURLParms[4]
            oFwProfile:SetUser(cCodUsrP)
            oFwProfile:SetProgram(cProgram)
            oFwProfile:SetTask(ctaskPro)
            oFwProfile:SetType(ctypePro)
            oFwProfile:SetStringProfile(cBody)

            If oFwProfile:Save()
        // Devolve o retorno para o Rest
                idProfile := cProgram+'/'+ctaskPro+'/'+ctypePro
                oRet['status'] :="success"
                oRet["idProfile"] := idProfile
                oRet["cProgram"] := cProgram
                oRet["ctaskPro"] := ctaskPro
                oRet["ctypePro"] := ctypePro
                oRet["cCodUsrP"] := cCodUsrP
                ::SetResponse( oRet )
            Else
                SetRestFault(500, STR0002) // 'Error when saving'
                lRet := .F.
            EndIf
            oFwProfile:Destroy()
            oFwProfile:= Nil
            FreeObj(oFwProfile)
            FreeObj(oRet)
        Else
            SetRestFault(400, STR0003) // 'Body is empty'
            lRet := .F.
        EndIf
    EndIf


Return (.T.)



WSMETHOD GET getProfile  PATHPARAM Program,taskPro,typePro WSRECEIVE userCode WSSERVICE rusrestprf
    Local oRet As Object		    
    Local oFwProfile As Object	
    Local cProf :=    '' As Character
    Local oJsonRet As Object
    Local cCodUsrP 	:= Iif(empty(::userCode),__CUSERID,::userCode) As Character
    Local cProgram 	:= ::aURLParms[2] As Character
    Local cTaskPro  	:= ::aURLParms[3] As Character
    Local cTypePro  	:= ::aURLParms[4] As Character

    Self:SetContentType("application/json")

    If Len(::aURLParms) <> 4 
        lRet := .F.
        SetRestFault(001, STR0001) // "Incorrect parameter count"
    Else
        oFwProfile	:= FWPROFILE():New()
        oFwProfile:SetUser(cCodUsrP)//RetCodUsr()
        oFwProfile:SetProgram(cProgram)
        oFwProfile:SetTask(ctaskPro)
        oFwProfile:SetType(ctypePro)
        oFwProfile:Activate()
        cProf := oFwProfile:LoadStrProfile()

        If !Empty(cProf)
            oRet:= JsonObject():New()
            oRet["status"] :="success"
            
            oJsonRet := JsonObject():new()
            ret := oJsonRet:FromJson(cProf) //test if its a json object
            If ValType(ret) == "U"
                oRet["data"] := oJsonRet
            Else
                oRet["data"] := cProf
            EndIf  
            FreeObj(oJsonRet)

            oRet["cProgram"] := cProgram
            oRet["ctaskPro"] := ctaskPro
            oRet["ctypePro"] := ctypePro
            oRet["cCodUsrP"] := cCodUsrP
            ::SetResponse( EncodeUtf8(oRet:toJson()) )
            FreeObj(oRet)
        EndIf
        oFwProfile:Destroy()
        FreeObj(oFwProfile)
    EndIf

Return (.T.)



WSMETHOD DELETE deleteProfile PATHPARAM Program,taskPro,typePro WSRECEIVE userCode WSSERVICE rusrestprf
    Local oRet As Object		    
    Local oFwProfile As Object	
    Local cCodUsrP 	:= Iif(empty(::userCode),__CUSERID,::userCode) As Character
    Local cProgram 	:= ::aURLParms[2] As Character
    Local cTaskPro  := ::aURLParms[3] As Character
    Local cTypePro  := ::aURLParms[4] As Character

    Self:SetContentType("application/json")

    If Len(::aURLParms) <> 4 
        lRet := .F.
        SetRestFault(001, STR0001) // "Incorrect parameter count"
    Else
        oRet	  := JsonObject():New()

        oFwProfile:= FWPROFILE():New()
        oFwProfile:SetUser(cCodUsrP)//RetCodUsr()
        oFwProfile:SetProgram(cProgram)
        oFwProfile:SetTask(cTaskPro)
        oFwProfile:SetType(cTypePro)

        If oFwProfile:Delete()
            ::SetResponse( '{"status":"success" }' )
        Else
            SetRestFault(500, STR0004) // 'Error when delete'
            lRet := .F.
        EndIf
        oFwProfile:Destroy()
        oFwProfile:= Nil
        FreeObj(oRet)
        FreeObj(oFwProfile)
    EndIf
Return(.T.)
                   
//Merge Russia R14 
                   
