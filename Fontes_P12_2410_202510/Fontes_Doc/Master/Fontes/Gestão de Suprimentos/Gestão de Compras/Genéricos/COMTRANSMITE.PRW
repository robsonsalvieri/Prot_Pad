#Include 'PROTHEUS.CH'
#Include 'TOTVS.CH'
#Include "PARMTYPE.CH" 
#Include "RwMake.ch"
#Include "TbiConn.ch"
#Include "FILEIO.CH"
#include "RESTFUL.ch"

Static oFindUlt
Static oFindCKO
Static oFind2CKO
Static oFindDHW
Static oFindDHY
Static oNewDHW
Static oChave
Static lAuthToken := GetRpoRelease() >= "12.1.2510"

/*/{Protheus.doc} ComTransmite
	Classe/Objeto para integração do importador XML x Transmite
@author rodrigo.mpontes
@since 14/01/2022
/*/
Class ComTransmite
	Data cKeyGrant	    As Character
	Data cKeyScope	    As Character
    Data cApiToken      As Character
	Data cApiTra	    As Character
    Data cApiUrlToken   As Character
    Data cApiUrlCodFil  As Character
    Data cApiUrlExpNFE  As Character
    Data cApiUrlExpNFS  As Character
    Data cApiUrlExpCTE  As Character
    Data cApiUrlExpCTO  As Character
    Data cApiUrlZipNFE  As Character
    Data cApiUrlZipNFS  As Character
    Data cApiUrlZipCTE  As Character
    Data cApiUrlZipCTO  As Character
    Data cApiSetExpNFE  As Character
    Data cApiSetExpCTE  As Character
    Data cApiSetExpCTO  As Character
    Data cApiSetExpNFS  As Character
    Data cNGin          As Character
    Data cNGLidos       As Character
    Data cMVDOCIMP	    As Character
    Data cMVXMLTRA	    As Character
    Data cMVXMLCID	    As Character
    Data cMVXMLCSEC	    As Character
    Data cLastError     As Character
    Data cThreadId      As Character
    Data cDirTransmite  As Character
    Data cMVAPITran     As Character
	Data cBarra			As Character
    Data lExported      As Logical
    Data lSOWin         As Logical
    Data lAPIError      As Logical
    Data lDHW           As Logical
    Data lDHY           As Logical
    Data lDHZ           As Logical
    Data lHistDHY       As Logical
    Data lDHYFil        As Logical
    Data lDHZFil        As Logical
    Data lCkoRepro      As Logical
    Data lCkoTra        As Logical
    Data lCKO           As Logical
	Data lCKORecibo		As Logical
    Data lDHYDHZMes     As Logical
    Data lCpoNewDoc     As Logical
    Data lGrvBulk       As Logical
    Data lMVBulk        As Logical
    Data lPerfTra       As Logical
    Data lImpXml        As Logical
    Data lCkoImpXML     As Logical
    Data lIntGfe        As Logical
    Data aHeaderOut	    As Array
    Data aEdiCOM        As Array
    Data aExcEdi        As Array
    Data nTamCod        As Numeric
    Data nTamTp         As Numeric
    Data nTamId         As Numeric
    Data nTArqXML       As Numeric
    Data nDocReq        As Numeric
    Data nDias          As Numeric
    Data nTamMaxDoc     As Numeric
    Data nTamSer        As Numeric
    Data nNumProc       As Numeric
    Data nTamNomFor     As Numeric
    Data nTamChv        As Numeric
    Data nTamRec        As Numeric
    Data nTamNFSe       As Numeric
    Data dDataIni       As Date

	Method New() Constructor

	Method TokenTotvsTransmite()
	Method LogMessage()
    Method CleanUp()
    Method NewNFSDoc()
    Method NewNumDoc()
    Method LogSegPlan()

    Method FindXML()
    Method FindCKODOC()
    
    Method XMLInLidos()
    Method XMLTransmite()
	
	Method GetParam()
	Method GetCodigoFilial()
    Method GetConvFile()
    Method GetConvXML()
    Method GetObjXML()
    Method GetNumSeq()
    Method GetNumPer()
    Method GetDadosXML()
    Method GetCodFilDHW()
    Method GetIdsExpXML()
    Method GetNewReceipt() 
    Method GetIdDHY()
    Method GetZIP()
    Method GetXML()
    Method GetDocUpdTra()
    Method GetImpXTra()

    Method PostXMLCKO()
    Method PostStatus()
    
	Method PutHeaderOut()
    Method PutIdDHY()
    Method PutStatusDHY()
    Method PutHistDHZ()

    Method UpdStatus()
    Method UpdGFEStatus()
    Method UpdDocStatus()
    Method UpdDocCKO()
    Method UpdCKOStran()

    Method ReadRecibo()
    Method PrepProcIds()

    Method IPToolConsult()
    Method IPToolRecTab()
    Method IPToolDocCKO()
    Method IPToolUpdStatus()
    Method IPToolCheckChv()
        
EndClass

/*/{Protheus.doc} New
	Método construtor
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method New() Class COMTransmite
    Self:cKeyGrant      := "client_credentials" 
	Self:cKeyScope      := "authorization_api"
	Self:cApiUrlToken   := "/totvs.rac/connect/token" 
    Self:cApiUrlCodFil  := "/api/companies"
    Self:cApiUrlExpNFE  := "/api/v3/mde/exportxmlbatch"
    Self:cApiUrlExpNFS  := "/api/v3/nfserecebida/exportbatch"
    Self:cApiUrlExpCTE  := "/api/v3/cterecebido/exportbatch"
    Self:cApiUrlExpCTO  := "/api/v3/cteosrecebido/exportbatch"
    Self:cApiUrlZipNFE  := "/api/v3/mde/exportbatch/"
    Self:cApiUrlZipNFS  := "/api/v3/nfserecebida/exportxmlbatch/"
    Self:cApiUrlZipCTE  := "/api/v3/cterecebido/exportbatch/"
    Self:cApiUrlZipCTO  := "/api/v3/cteosrecebido/exportbatch/"
    Self:cApiSetExpNFE  := "/api/v3/mde/setstatusintegration"
    Self:cApiSetExpNFS  := "/api/v3/nfserecebida/setstatusintegration"
    Self:cApiSetExpCTE  := "/api/v3/cterecebido/setstatusintegration"
    Self:cApiSetExpCTO  := "/api/v3/cteosrecebido/setstatusintegration"
    Self:lSOWin         := !isSrvUnix() //Se é SO Windows
	Self:cBarra			:= Iif(!Self:lSOWin,"/","\") 
    Self:cThreadId      := AllTrim(Str(ThreadId()))
    Self:lDHW           := ChkFile("DHW")
	Self:lDHY           := ChkFile("DHY")
    Self:lDHZ           := ChkFile("DHZ")
    Self:lCKO           := ChkFile("CKO")
    Self:lCkoImpXML     := Self:lCKO .And. CKO->(FieldPos("CKO_ARQXML")) > 0 .And. !Empty(CKO->(IndexKey(5)))
    Self:lImpXml        := Self:GetParam(17)
    Self:cNGIn          := Self:GetParam(1)
    Self:cNGLidos       := Self:GetParam(2)
    Self:cMVDOCIMP      := Self:GetParam(4)
    Self:cMVXMLCID      := Self:GetParam(5)
    Self:cMVXMLCSEC     := Self:GetParam(6)
	Self:cMVAPITran     := Self:GetParam(7)
    Self:cMVXMLTRA      := Self:GetParam(3)
	Self:cApiToken      := Self:GetParam(8)
	Self:cApiTra	    := Self:GetParam(9)
	Self:cDirTransmite  := Self:GetParam(10)
    Self:aExcEdi        := Self:GetParam(11)
    Self:dDataIni       := Self:GetParam(12)
    Self:nDocReq        := Self:GetParam(13)
    Self:nDias          := Self:GetParam(14)
    Self:nNumProc       := Self:GetParam(15)
    Self:lMVBulk        := Self:GetParam(16)
    Self:lIntGfe        := Self:GetParam(18)
	Self:lHistDHY       := .T.
    Self:aEdiCOM        := {"109","214","273","319"}
    Self:cLastError     := ''
    Self:lAPIError      := .F.
    Self:aHeaderOut     := {}
    Self:nTamCod        := Iif(Self:lDHY,TamSX3("DHY_CODFIL")[1],40)
    Self:nTamTp         := Iif(Self:lDHY,TamSX3("DHY_TPXML")[1],5)
    Self:nTamId         := Iif(Self:lDHY,TamSX3("DHY_ID")[1],36)
    Self:nTamMaxDoc     := TamSX3("F1_DOC")[1]
    Self:nTamSer        := TamSX3("F1_SERIE")[1]
    Self:nTamNomFor     := Iif(Self:lCKO,TamSX3("CKO_NOMFOR")[1],30)
    Self:nTamChv        := Iif(Self:lCKO,TamSX3("CKO_CHVDOC")[1],50)
    Self:nTArqXML       := Iif(Self:lCKO,TamSX3("CKO_ARQXML")[1],60)
    Self:lDHYFil        := Self:lDHY .And. DHY->(FieldPos("DHY_FILTRO")) > 0 .And. DHY->(FieldPos("DHY_TENT")) > 0 .And. DHY->(FieldPos("DHY_DTID")) > 0
	Self:lDHZFil        := Self:lDHZ .And. DHZ->(FieldPos("DHZ_FILTRO")) > 0 .And. DHZ->(FieldPos("DHZ_TENT")) > 0 .And. DHZ->(FieldPos("DHZ_DTID")) > 0 .And. DHZ->(FieldPos("DHZ_DTLID")) > 0
    Self:lDHYDHZMes     := Self:lDHY .And. Self:lDHZ .And. DHY->(FieldPos("DHY_MESSAG")) > 0 .And. DHZ->(FieldPos("DHZ_MESSAG")) > 0
	Self:lCkoRepro      := Self:lCKO .And. CKO->(FieldPos("CKO_DOC")) > 0 .And. CKO->(FieldPos("CKO_SERIE")) > 0 .And. CKO->(FieldPos("CKO_NOMFOR")) > 0 .And. !Empty(SDS->(IndexKey(4)))
    Self:lCkoTra        := Self:lCKO .And. CKO->(FieldPos("CKO_CHVDOC")) > 0 .And. CKO->(FieldPos("CKO_ORIGEM")) > 0 .And. CKO->(FieldPos("CKO_STRAN")) > 0 .And. CKO->(FieldPos("CKO_ERRTRA")) > 0
	Self:lCKORecibo		:= Self:lCKO .And. CKO->(FieldPos("CKO_RECIBO")) > 0 
    Self:lCpoNewDoc     := Self:lCKO .And. CKO->(FieldPos("CKO_NFELET")) > 0 .And. SDS->(FieldPos("DS_NFELETR")) > 0
    Self:lGrvBulk       := Self:lMVBulk .And. FwBulk():CanBulk()
    Self:lPerfTra       := (Self:nNumProc >= 1 .And. Self:lGrvBulk)
    Self:nTamRec        := Iif(Self:lCKORecibo,TamSX3("CKO_RECIBO")[1],36)
    Self:nTamNFSe       := Iif(Self:lCpoNewDoc,TamSX3("CKO_NFELET")[1],20)
Return Nil

/*/{Protheus.doc} GetParam
	Parametrização COMTransmite

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetParam(nOpc) Class COMTransmite

    Local cMVTransmite  := ""
    Local cMVNGIn       := ""
    Local cMVNGLidos    := ""
    Local cMVRet        := ""
    Local cDir          := ""
	Local xMVRet        := Nil
    Local aDir          := {}
    Local nI            := 0

	If nOpc == 1
		cMVNGIn := SuperGetMV("MV_NGINN",.F.,"\neogrid\in")
		cMVNGIn := Iif(Self:lSOWin,StrTran(cMVNGIn,"/",Self:cBarra),StrTran(cMVNGIn,"\",Self:cBarra))
        cMVRet	:= Iif(SubStr(cMVNGIn, Len(cMVNGIn)) <> Self:cBarra,cMVNGIn+Self:cBarra,cMVNGIn)
        cMVRet 	:= Iif(SubStr(cMVRet,1,1) <> Self:cBarra,Self:cBarra+cMVRet,cMVRet)
        cMVRet 	:= AllTrim(cMVRet)
		xMVRet	:= cMVRet
	Elseif nOpc == 2
		cMVNGLidos 	:= SuperGetMV("MV_NGLIDOS",.F.,"\neogrid\lidos")
        cMVNGLidos 	:= Iif(Self:lSOWin,StrTran(cMVNGLidos,"/",Self:cBarra),StrTran(cMVNGLidos,"\",Self:cBarra))
        cMVRet		:= Iif(SubStr(cMVNGLidos, Len(cMVNGLidos)) <> Self:cBarra,cMVNGLidos+Self:cBarra,cMVNGLidos)
        cMVRet 		:= Iif(SubStr(cMVRet,1,1) <> Self:cBarra,Self:cBarra+cMVRet,cMVRet)
        cMVRet 		:= AllTrim(cMVRet)
		xMVRet		:= cMVRet
	Endif

	If nOpc == 1 .Or. nOpc == 2
        aDir := Separa(cMVRet,Self:cBarra)
        If Len(aDir) > 0
            cDir := ""
            For nI := 1 To Len(aDir)
                If !Empty(aDir[nI])
                    cDir += Self:cBarra + aDir[nI]
                    If !ExistDir(cDir)
                        MakeDir(cDir) 
                    Endif
                Endif 
            Next nI
        Endif
	Endif

    If nOpc == 3
		//Integração Importador x Transmite esta ativa ? 
        If Self:lImpXml .And. !Empty(Self:cMVXMLCID) .And. !Empty(Self:cMVXMLCSEC)  .And. !Empty(Self:cMVAPITran)     
            cMVTransmite 	:= "\transmite\"
            cMVTransmite 	:= Iif(Self:lSOWin,StrTran(cMVTransmite,"/",Self:cBarra),StrTran(cMVTransmite,"\",Self:cBarra))
            cMVRet 			:= Iif(SubStr(cMVTransmite, Len(cMVTransmite)) <> Self:cBarra,cMVTransmite+Self:cBarra,cMVTransmite)
            cMVRet 			:= Iif(SubStr(cMVRet,1,1) <> Self:cBarra,Self:cBarra+cMVRet,cMVRet)
            cMVRet 			:= AllTrim(cMVRet)
            
            cDir := Self:cNGIn + SubStr( cMVRet, 2, Len(cMVRet)-2)

            If !ExistDir(cDir)
                MakeDir(cDir) 
            Endif

            cDirThread := Self:cNGIn + SubStr( cMVRet, 2, Len(cMVRet)) + Self:cThreadId

            If !ExistDir(cDirThread)
                MakeDir(cDirThread) 
            Endif

            cMVRet := cDirThread + Self:cBarra
            xMVRet := cMVRet
        EndIf

    Elseif nOpc == 4
        xMVRet := SuperGetMV("MV_DOCIMP",.F.,"NFE/NFS/CTE/CTO")
    Elseif nOpc == 5
        xMVRet := SuperGetMV("MV_XMLCID",.F.,"")
    Elseif nOpc == 6
        xMVRet := SuperGetMV("MV_XMLCSEC",.F.,"")
    Elseif nOpc == 7
        xMVRet := Lower(SuperGetMV("MV_APITRAN",.F.,"production"))
	Elseif nOpc == 8
        xMVRet := Iif(Self:cMVAPITran == "production"	,"https://admin.rac.totvs.app",;
                  Iif(Self:cMVAPITran == "staging"		,"https://admin.rac.staging.totvs.app",;
                  Iif(Self:cMVAPITran == "development"	,"https://admin.rac.dev.totvs.app","")))
	Elseif nOpc = 9
        xMVRet := Iif(Self:cMVAPITran == "production"	,"https://api-transmite.totvs.app",;
                  Iif(Self:cMVAPITran == "staging"		,"https://api-transmite.staging.totvs.app",;
                  Iif(Self:cMVAPITran == "development"	,"https://api-transmite.dev.totvs.app","")))
	Elseif nOpc == 10
        cMVTransmite := "\transmite\"
        cMVTransmite := Iif(Self:lSOWin,StrTran(cMVTransmite,"/",Self:cBarra),StrTran(cMVTransmite,"\",Self:cBarra))
        cDir         := Iif(SubStr(cMVTransmite, Len(cMVTransmite)) <> Self:cBarra,cMVTransmite+Self:cBarra,cMVTransmite)
        cDir         := Iif(SubStr(cDir,1,1) <> Self:cBarra,Self:cBarra+cDir,cDir)
        
        xMVRet := Self:cNGIn + SubStr( cDir, 2, Len(cDir))
	Elseif nOpc == 11
        xMVRet := &(GetNewPar("MV_EXCEDI",'{}')) 
    Elseif nOpc == 12
        xMVRet := SuperGetMV("MV_DTINITR",.F.,"") 
    Elseif nOpc == 13
        xMVRet := SuperGetMV("MV_DOCREQ",.F.,500)
        xMVRet := Iif(xMVRet>1000 .Or. xMVRet==0,500,xMVRet)
    Elseif nOpc == 14
        xMVRet := SuperGetMV("MV_XMLDIAS",.F.,30)
    Elseif nOpc == 15
        xMVRet := SuperGetMV("MV_MTHRTR",.F.,1)
    Elseif nOpc == 16
        xMVRet := SuperGetMV("MV_BULKTR",.F.,.F.)
    Elseif nOpc == 17
        xMVRet := SuperGetMv("MV_IMPXML",.F.,.F.) .And. Self:lCkoImpXML
    Elseif nOpc == 18
        xMVRet := SuperGetMV("MV_INTGFE",.F.,.F.) .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
	Endif
	
    FwFreeArray(aDir)

Return xMVRet

/*/{Protheus.doc} TokenTotvsTransmite
	Método para autenticar usuario/senha
@param  lAuth       T = Autenticado / F = Não autenticado

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method TokenTotvsTransmite() Class COMTransmite

    Local aHeader		:= {}
    Local cURL      	:= ""
    Local cResource 	:= ""
    Local cPostParam    := ""
    Local cTextJson 	:= ""
    Local cToken    	:= ""
    Local oJsonResp 	:= Nil
    Local oRest     	:= Nil
    Local lAuth			:= .F.

    cURL     	:= Self:cApiToken
    
    aHeader := {"Content-Type:application/x-www-form-urlencoded"} 

	cResource 	:= Self:cApiUrlToken
    cPostParam  := 'grant_type='+Self:cKeyGrant+'&client_id='+Self:cMVXMLCID+'&client_secret='+Self:cMVXMLCSEC+'&scope='+Self:cKeyScope

    //Realiza o post de acordo com o cURL e cResource
    oRest := FwRest():New(cURL)
    oRest:SetPath(cResource)
    oRest:SetPostParams(cPostParam)
    oJsonResp := JsonObject():New()

    If lAuth := oRest:Post(aHeader)
        cTextJson := oRest:GetResult() 
		oJsonResp:FromJson(cTextJson)
		cToken := oJsonResp:GetJsonObject("access_token")
		
		//Monta header com token
		Self:PutHeaderOut(cToken)
		Self:LogMessage("","Data: " + DtoC(Date()) + " - Hora: " + Time() + " - TOKEN: " + cToken)
    Else
        cTextJson := oRest:GetResult()
        Self:cLastError := oRest:GetLastError()
        Self:lAPIError := .T.
        
        Self:LogMessage(cTextJson, oRest:GetLastError())
    EndIf

    //-- Limpa objetos da memória
    FreeObj(oJsonResp)
    FreeObj(oRest)

    FwFreeArray(aHeader)

Return lAuth

/*/{Protheus.doc} PutHeaderOut
	Método para adicionar HeaderOut

@param	cToken	Token autenticação

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PutHeaderOut(cToken) Class COMTransmite

	Self:aHeaderOut := {}
	aAdd(Self:aHeaderOut, 'Content-Type: application/json; charset=UTF-8')
	aAdd(Self:aHeaderOut, 'Accept: application/json')
	aAdd(Self:aHeaderOut, 'Authorization: Bearer ' + cToken)

Return

/*/{Protheus.doc} GetCodigoFilial
	Busca Id empresa no Transmite

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetCodigoFilial(cCGC,cIE,cUF,cEmp,cFil) Class COMTransmite

    Local cRetId        := ""
    Local cUrl          := Self:cApiTra
    Local cResource 	:= ""
    Local cTextJson 	:= ""
	Local cGetParam		:= ""
    Local oJsonResp 	:= Nil
    Local oRest     	:= Nil

    cGetParam   := "?$filter=CpfCnpj eq '" + AllTrim(cCGC) + "' and IE eq '" + AllTrim(cIE) + "'&$select=CodigoFilial
    cGetParam   := StrTran(cGetParam," ","%20")
    cResource   := Self:cApiUrlCodFil + cGetParam
    
    oRest 	:= FwRest():New(cURL)
    oRest:SetPath(cResource)
    
    oJsonResp := JsonObject():New() 
    
    If oRest:Get(Self:aHeaderOut)
        cTextJson := oRest:GetResult()
        cTextJson   := StrTran(cTextJson,"[","")
        cTextJson   := StrTran(cTextJson,"]","")
        oJsonResp:FromJson(cTextJson)
        cRetId := oJsonResp:GetJsonObject("CodigoFilial")
    Else
		cTextJson := oRest:GetResult() 
		Self:cLastError := oRest:GetLastError()
		Self:lAPIError := .T.
		
		Self:LogMessage(cTextJson, oRest:GetLastError())
	EndIf

    //-- Limpa objetos da memória
    FreeObj(oJsonResp)
    FreeObj(oRest)

Return cRetId

/*/{Protheus.doc} LogMessage
	Registra mensagem de log
    
@param  cJson       Texto formato JSON
@param  cMessage    Texto

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method LogMessage(cJson, cMessage) Class COMTransmite 

	Default cJson := ''
	Default cMessage := ''

	FWLogMsg('WARN',, 'COMTransmite', FunName(), '', '01', CRLF + 'COMTransmite:JSON: ' + cJson + CRLF + ' COMTransmite:MSG: ' + cMessage, 0, 0, {})

	If (FWIsInCallStack( "ImpTraTool" ) .Or. FWIsInCallStack( "IMPTRASEG" ) .Or. FWIsInCallStack( "UPDTRASEG" ))  .And. (FWIsInCallStack( "ColAutoRead" ) .Or. FWIsInCallStack( "SchedImpTra" ) .OR. FWIsInCallStack( "SchedUpdTra" ))
		aAdd(aImpTraTool,'COMTransmite:JSON: ' + cJson + CRLF + 'COMTransmite:MSG: ' + cMessage + CRLF + CRLF)
	Endif

    If "UNAUTHORIZED" $ Upper(cMessage) //Recorrencia para quando perder Token
        Self:TokenTotvsTransmite()
    Endif

Return Nil

/*/{Protheus.doc} XMLINLIDOS
	Busca XMLs a serem importador para CKO na pasta IN/Lidos

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method XMLInLidos() Class COMTransmite

	Local aFiles	:= {}

    Self:FindXML(Self:cNGIn, @aFiles)

    If Len(aFiles) > 0
        Self:LogMessage("","Lendo XMLs da pasta IN") 
        If Len(aFiles) > 0
            Self:LogMessage("","Gravando XMLs da pasta IN")
            Self:PostXMLCKO(aFiles,"IN")

            Self:LogMessage("","Movendo arquivos da IN para Lidos")
            Self:CleanUp("MOV",aFiles)
        Endif
    Endif

    FwFreeArray(aFiles)

Return

/*/{Protheus.doc} FindXML
	Busca XMLs

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method FindXML(cDir, aFiles) Class COMTransmite

    Local nI        := 1
    Local nZ        := 0
    Local aExt      := {".XML",".xml",".Xml",".xMl",".xmL",".XMl",".XmL",".xML"}
    Local aDocXML   := {}

    For nI := 1 To Len(aExt)
        aDocXML := Directory(cDir + "*" + aExt[nI],"D",,.F.)

        For nZ := 1 To Len(aDocXML)
            aAdd(aFiles,{aDocXML[nZ,1],aDocXML[nZ,3],aDocXML[nZ,4]})
        Next nZ

        If Len(aFiles) > 0
            Exit
        Endif
    Next nI

    FwFreeArray(aExt)
    FwFreeArray(aDocXML) 

Return

/*/{Protheus.doc} CleanUp
	Limpa e move arquivos

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method CleanUp(cOpc,aXML,cZip,cCamSegPlan) Class COMTransmite

    Local nI        := 0
    Local nZ        := 0
    Local aFiles    := {}
    Local aFiles2   := {}
    Local nErase    := 0
    Local lRet      := .T.
    
    If cOpc == "MOV" //Move arquivos da pasta IN para Lidos
        For nI := 1 To Len(aXML)
            If File(Self:cNGIn + aXML[nI,1])
                ( __CopyFile(Self:cNGIn+aXML[nI,1], Self:cNGLidos+aXML[nI,1],,,Self:lSOWin))
                nErase := FErase( Self:cNGIn+aXML[nI,1],,Self:lSOWin)
                Self:LogMessage("","Arquivo movido: " + Self:cNGIn+aXML[nI,1] + Iif(nErase==0," sim"," nao"))
            Endif
        Next nI
    Elseif cOpc == "DEL"
        For nI := 1 To Len(aXML)
            If File(Self:cMVXMLTRA + aXML[nI,1])
                nErase := FErase( Self:cMVXMLTRA+aXML[nI,1],,Self:lSOWin)
                Self:LogMessage("","Arquivo excluido: " + Self:cMVXMLTRA+aXML[nI,1] + Iif(nErase==0," sim"," nao"))
            Endif
        Next nI

        nErase := FErase(cZip)
        Self:LogMessage("","Zip excluido: " + cZip + Iif(nErase==0," sim"," nao"))
    Elseif cOpc == "DELP"
        lRet := DirRemove(Self:cMVXMLTRA)
        Self:LogMessage("","Pasta excluido: " + Self:cMVXMLTRA + Iif(lRet," sim"," nao"))
    Elseif cOpc == "DELL"
        aFiles  := {}
        aFiles2 := {}
        aFiles  := Directory(Self:cDirTransmite + "*.*", "D")

        If Len(aFiles) > 0
            For nI := 1 To Len(aFiles)
                If Val(aFiles[nI,1]) > 0 .And. aFiles[nI,5] == "D" .And. aFiles[nI,3] < dDataBase
                    If !DirRemove(Self:cDirTransmite+aFiles[nI,1])
                        aFiles2 := Directory(Self:cDirTransmite+aFiles[nI,1] + Self:cBarra + "*.*", "D")
                        If Len(aFiles2) > 0
                            For nZ := 1 To Len(aFiles2)
                                nErase := FErase(Self:cDirTransmite+aFiles[nI,1]+Self:cBarra+aFiles2[nZ,1])
                                Self:LogMessage("","Arquivo excluido: " + Self:cDirTransmite+aFiles[nI,1]+Self:cBarra+aFiles2[nZ,1] + Iif(nErase==0," sim"," nao"))
                            Next nZ
                            lRet := DirRemove(Self:cDirTransmite+aFiles[nI,1])
                            Self:LogMessage("","Pasta excluido: " + Self:cDirTransmite+aFiles[nI,1] + Iif(lRet," sim"," nao"))
                        Endif
                    Endif
                Endif
            Next nI
        Endif
        FwFreeArray(aFiles)
        FwFreeArray(aFiles2)
    Elseif cOpc == "DELSEG"
        aFiles  := Directory(cCamSegPlan + "*.*", "D")
        For nI := 1 To Len(aFiles)
            If aFiles[nI,3] < dDataBase
                nErase := FErase(cCamSegPlan+aFiles[nI,1])
            Endif
        Next nI
        FwFreeArray(aFiles)
    Endif
    
Return Nil

/*/{Protheus.doc} PostXMLCKO
	Grava XMLs na tabela CKO

@param  aXML    XMLs a serem importados
@param  cOpc    Modo de importação (IN - Pasta IN / TR - Transmite)
@param  cRecibo Recibo sendo lido

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PostXMLCKO(aXML,cOpc,cRecibo) Class COMTransmite
	
    Local nI        := 0
    Local cXML      := ""
    Local cFile     := ""
    Local cFileNew  := ""
    Local lNewReg	:= .T.
    Local lGrvCKO	:= .T.
    Local lAtuTra   := .F.
    Local aCKODados	:= {}
    Local cDocXML   := ""
    Local cSerXML   := ""
    Local cNomXML   := ""
    Local cChvXML   := ""
    Local cEmpCKO   := ""
    Local cFilCKO   := ""
    Local cDocEletr := ""
    Local cNumSeq   := ""
    Local aFindCKO  := {} 
    Local cLog      := Iif(cOpc=="IN","[IN]: ","[TRANSMITE]: ")
    local lCancelado:= .f.
    Local oBulkCKO  := Nil
    Local aRegCKO   := {}
    Local aFieldCKO := {{"CKO_ARQUIV"},{"CKO_CODEDI"},{"CKO_XMLRET"},{"CKO_DT_RET"},{"CKO_HR_RET"},{"CKO_DT_IMP"},{"CKO_HR_IMP"},;
                        {"CKO_STATUS"},{"CKO_DESSTA"},{"CKO_FLAG"},{"CKO_ARQXML"},{"CKO_EMPPRO"},{"CKO_FILPRO"}}
    
    Default cRecibo := ""

    If Self:lPerfTra
        oBulkCKO := FwBulk():New(RetSqlName("CKO"),1000)
        
        If Self:lCkoRepro 
            aAdd(aFieldCKO, {"CKO_DOC"})
            aAdd(aFieldCKO, {"CKO_SERIE"})
            aAdd(aFieldCKO, {"CKO_NOMFOR"})
        Endif

        If Self:lCkoTra
            aAdd(aFieldCKO, {"CKO_CHVDOC"})
            aAdd(aFieldCKO, {"CKO_ORIGEM"})
            aAdd(aFieldCKO, {"CKO_STRAN"})
        Endif

        If Self:lCKORecibo
		    aAdd(aFieldCKO, {"CKO_RECIBO"})
        Endif

        If Self:lCpoNewDoc
		    aAdd(aFieldCKO, {"CKO_NFELET"})
		Endif

        oBulkCKO:setFields(aFieldCKO)
    Endif
    
    For nI := 1 To Len(aXML)
        lNewReg     := .T.
        lGrvCKO	    := .T.
        cFile       := aXML[nI,1] 
        aFindCKO    := {}
        cDocXML     := ""
        cSerXML     := ""
        cNomXML     := ""
        cChvXML     := ""
        cDocEletr   := ""
        lCancelado  := .f.
        lAtuTra     := .F.
        
        Self:LogMessage("","Lendo XML:" + cLog + cFile)
    	cXML := Self:GetConvFile(cFile,cOpc)  

        If !Empty(cXML)
            Self:LogMessage("","Convertendo arquivo XML com nomenclatura 109/214/273/319")
            cFileNew := Self:GetConvXML(cXML,cFile)
            
            Self:LogMessage("","Arquivo XML convertido: " + cFileNew)
            
            Self:LogMessage("","Verificando se XML ja gravado CKO")
            CKO->(dbSetorder(1))
            If CKO->(dbSeek(cFileNew))
                lNewReg	:= .F. 
                lGrvCKO := Iif(CKO->CKO_FLAG<>'1',.T.,.F.) 	
                lCancelado := !lGrvCKO
            Endif

            Self:LogMessage("","Verificando se XML pertence ao COM (109/214/273/319)")
            // Verifica se tipo de XML está configurado para ser importado
            If !Empty(Self:aEdiCOM)
                If aScan(Self:aEdiCOM,{|x| AllTrim(x) == AllTrim(SubStr(cFileNew,1,3))}) == 0
                    lGrvCKO := .F.
                Endif
            Endif

            Self:LogMessage("","Verificando se XML pertence a alguma exceção")
            // Verifica se tipo de XML não está configurado como excessão de importação
            If !Empty(Self:aExcEdi)
                If aScan(Self:aExcEdi,{|x| AllTrim(x) == AllTrim(SubStr(cFileNew,1,3))}) > 0
                    lGrvCKO := .F.
                EndIf
            EndIf

            If lGrvCKO
                /* aCKODados
                [1] - Chave Doc
                [2] - Numero Doc
                [3] - Serie Doc
                [4] - Nome Fornecedor
                [5] - Empresa
                [6] - Filial
                [7] - Numero Doc NFS
                */
                aCKODados := Self:GetDadosXML(cXML)

                If Self:lCkoTra //Busca Chave DOC
                    cChvXML	:= aCKODados[1]
                Endif

                If Self:lCkoRepro 
                    cDocXML	:= aCKODados[2]
                    cSerXML	:= aCKODados[3]
                    cNomXML	:= aCKODados[4]
                Endif
                
                cEmpCKO := aCKODados[5]
                cFilCKO := aCKODados[6]

                If Self:lCpoNewDoc .And. Len(aCKODados) > 6 //Busca nova chave NFS
                    cDocEletr := aCKODados[7]
                Endif
 
                If lNewReg
                    Self:LogMessage("","Novo registro:FindCKODOC")
                    aFindCKO := Self:FindCKODOC(cChvXML)
                    If !Empty(aFindCKO[1]) //Encontrou CKO
                        lCancelado := .T.
                        cFileNew := aFindCKO[1]
                        Self:LogMessage("","Novo registro:Encontrou:FindCKODOC" + cFileNew)
                        
                        lNewReg  := .F.
                        lGrvCKO := Iif(aFindCKO[2]<>'1',.T.,.F.)

                        lAtuTra := aFindCKO[3]
                        Self:LogMessage("","Novo registro:Encontrou:FindCKODOC:lAtuTra: " + Iif(lAtuTra,"T","F"))
                        If lAtuTra .And. !lGrvCKO //Atualiza STRAN - Status
                            lGrvCKO := .T.
                        Endif

                        If lGrvCKO
                            CKO->(dbSeek(cFileNew))
                        Endif 	
                    Endif 
                Endif
            Endif

            //Verifica se o documento cancelado esta na CKO e atualiza o registro cancelado.
            if lCancelado .And. FindFunction("ColNTCan")
                if ColNTCan(cXml,cFile,.t.)
                    lGrvCKO := .F.
                endif
            endif

            If lGrvCKO 
                Self:LogMessage("","Gravando CKO")
                cEDI := SubStr(cFileNew,1,3) 
                cFileNew := PadR(Lower(cFileNew),Len(CKO->CKO_ARQUIV))

                Begin Transaction

                    If lNewReg .And. Self:lPerfTra
                        aRegCKO := {} 

                        aAdd(aRegCKO,cFileNew)               //CKO_ARQUIV
                        aAdd(aRegCKO,cEDI)                   //CKO_CODEDI
                        aAdd(aRegCKO,cXML)                   //CKO_XMLRET
                        aAdd(aRegCKO,aXML[nI,2])             //CKO_DT_RET - Data do arquivo
                        aAdd(aRegCKO,aXML[nI,3])             //CKO_HR_RET - Hora do arquivo
                        aAdd(aRegCKO,Date())                 //CKO_DT_IMP - Data da importacao pelo Schedule
                        aAdd(aRegCKO,Time())                 //CKO_HR_IMP - Hora da importacao pelo Schedule
                        aAdd(aRegCKO,ColCKOStatus()[2][1])   //CKO_STATUS
                        aAdd(aRegCKO,ColCKOStatus()[2][2])   //CKO_DESSTA
                        aAdd(aRegCKO,"0")                    //CKO_FLAG
                        aAdd(aRegCKO,cFile)                  //CKO_ARQXML
                        aAdd(aRegCKO,cEmpCKO)                //CKO_EMPPRO
                        aAdd(aRegCKO,cFilCKO)                //CKO_FILPRO   

                        If Self:lCkoRepro
                            
                            If oBulkCKO:Count() > 0 .And. SubStr(cDocXML,1,1) == "T"
                                cNumSeq := SubStr(cDocXML,2)
                                cNumSeq := Soma1(cNumSeq)
                                cDocXML := "T" + cNumSeq
                            Endif

                            aAdd(aRegCKO,PadR(cDocXML,Self:nTamMaxDoc))            //CKO_DOC
                            aAdd(aRegCKO,cSerXML)            //CKO_SERIE
                            aAdd(aRegCKO,PadR(cNomXML,Self:nTamNomFor))            //CKO_NOMFOR
                        Endif 

                        If Self:lCkoTra
                            aAdd(aRegCKO,PadR(cChvXML,Self:nTamChv))            //CKO_CHVDOC
                            aAdd(aRegCKO,Iif(cOpc == "TR", "TRANSMITE", "IMP-IN")) //CKO_STRAN
                            aAdd(aRegCKO,Iif(cOpc == "TR" .Or. (cOpc == "IN" .And. cEDI == "319") , "1", "0")) //CKO_STRAN
                        Endif 

                        If Self:lCKORecibo
                            aAdd(aRegCKO,cRecibo)            //CKO_RECIBO
                        Endif

                        If Self:lCpoNewDoc
                            aAdd(aRegCKO,cDocEletr)          //CKO_NFELET 
                        Endif

                        oBulkCKO:addData(aRegCKO)
                    Else
                        IF RecLock("CKO",lNewReg) 
                            If !lAtuTra 
                                CKO->CKO_ARQUIV	:= cFileNew
                                CKO->CKO_CODEDI	:= cEDI
                                CKO->CKO_XMLRET	:= cXML
                                CKO->CKO_DT_RET	:= aXML[nI,2] //Data do arquivo
                                CKO->CKO_HR_RET	:= aXML[nI,3] //Hora do arquivo
                                CKO->CKO_DT_IMP	:= Date() //Data da importacao pelo Schedule
                                CKO->CKO_HR_IMP	:= Time() //Hora da importacao pelo Schedule
                                CKO->CKO_STATUS	:= ColCKOStatus()[2][1]
                                CKO->CKO_DESSTA	:= ColCKOStatus()[2][2]
                                CKO->CKO_FLAG	:= "0"
                                CKO->CKO_ARQXML := cFile 
                                CKO->CKO_EMPPRO	:= cEmpCKO
                                CKO->CKO_FILPRO	:= cFilCKO
                                
                                //Gravação Documento/Serie/Nome fornecedor
                                If Self:lCkoRepro 
                                    CKO->CKO_DOC	:= cDocXML
                                    CKO->CKO_SERIE	:= cSerXML
                                    CKO->CKO_NOMFOR	:= cNomXML
                                Endif                            
                                
                                //Gravção Chave do documento
                                If Self:lCkoTra
                                    CKO->CKO_CHVDOC	:= cChvXML
                                    If cOpc == "TR"
                                        CKO->CKO_ORIGEM := "TRANSMITE"
                                    Elseif cOpc == "IN"
                                        CKO->CKO_ORIGEM := "IMP-IN"
                                    Endif

                                    If lNewReg 
                                        CKO->CKO_STRAN  :=  Iif(cOpc == "TR" .Or. (cOpc == "IN" .And. cEDI == "319") , "1", "0")
                                    Endif                            
                                Endif

                                If Self:lCKORecibo .And. !Empty(cRecibo)
                                    CKO->CKO_RECIBO  := cRecibo
                                Endif

                                 If Self:lCpoNewDoc
                                    CKO->CKO_NFELET  := cDocEletr 
                                Endif
                            Else
                                CKO->CKO_STRAN  := "1"
                                CKO->CKO_ORIGEM := "TRANSMITE"
                            Endif
                            CKO->( msUnlock() ) 
                        Endif
                    Endif
                                
                End Transaction
            Endif
        Endif
    Next nI

    If Self:lPerfTra
        Self:LogMessage("","Gravando CKO (Bulk)")   
        oBulkCKO:Close()

        Self:LogMessage("","Erro Bulk: " + oBulkCKO:GetError())
        oBulkCKO:Destroy()

        FreeObj(oBulkCKO)
    Endif

    FwFreeArray(aCKODados)
    FwFreeArray(aFindCKO)
    FwFreeArray(aFieldCKO)
    FwFreeArray(aRegCKO)

Return

/*/{Protheus.doc} GetConvFile
	Converte arquivo XML em cXML

@param  cFile    XML convertido
@param  cOpc     IN-IN / TR-TRANSMITE

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetConvFile(cFile,cOpc) Class COMTransmite

Local cLine	:= ""
Local cXML  := ""
Local nArq  := 0

nArq := FT_FUse(Iif(cOpc == "TR",Self:cMVXMLTRA,Self:cNGIn) + cFile ) 

If nArq >= 0 

	cLine	:= ""
	cXml	:= ""
		
	While !FT_FEof() 
		cLine := FT_FReadLn()
		If ( Len(cLine) < 1023 )
			cXml += Alltrim(cLine)
		Else
			cLine := ""
			While .T.
				If ( Len(FT_fReadLn()) < 1023 )
					cLine	+= FT_FReadLn()
					cXml	+= cLine 
					Exit
				Else
					cLine += FT_FReadLn() 	 			
					FT_FSkip() 
				Endif
			Enddo
		Endif
		FT_FSkip()
	Enddo

	//-- Fecha o arquivo aberto
	FT_FUSE()
	
	If "ObsContxCampo" $ cXML
		cXml := StrTran(cXml,"ObsContxCampo","ObsCont xCampo")
	Endif
	 	 
	If "ReferenceURI" $ cXml
		cXml := StrTran(cXml,"ReferenceURI","Reference URI") 
	Endif
				
Endif
	
Return cXML

/*/{Protheus.doc} GetConvXML
	Converte arquivo XML para nomenclatura a ser importada

@param  cXML    XML convertido
@param  cFile   Nome do arquivo

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetConvXML(cXML,cFile) Class COMTransmite
    
    Local oFullXML  := Nil
    Local cError	:= ""
    Local cWarning	:= ""
    Local cCodEdi   := ""
    Local aArea		:= GetArea()
    
    Self:GetObjXML(cXML,@oFullXML,@cError,@cWarning)

    //Verifica se estar importando uma NFE ou CTE
    If ValType(oFullXML) == "O"
        If ValType(XmlChildEx(oFullXML,"_NFE")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O" //-- Nota normal, devolucao, beneficiamento, bonificacao
			cCodEdi := Iif(Self:lPerfTra,"109_","109_NFE_")
        Elseif ValType(XmlChildEx(oFullXML,"_CTE")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_CTESIMPPROC")) == "O"//-- Nota de transporte
            cCodEdi := Iif(Self:lPerfTra,"214_","214_CTE_")
        Elseif ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O" //-- Nota de transporte CTEOS
            cCodEdi := Iif(Self:lPerfTra,"273_","273_CTE_")
        Elseif ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O" //-- Nota de Serviço
            cCodEdi := Iif(Self:lPerfTra,"319_","319_NFS_")
        Endif
    Endif

    If !Empty(cCodEdi)
        Self:LogMessage("","Arquivo XML é : " + cCodEdi)
    Endif

    //Busca pelo arquivo original, verificando se ja foi importado
    CKO->(DbSetOrder(5))
    If CKO->(dbSeek(PadR(lower(cFile),LEN(CKO->CKO_ARQXML)))) .Or. CKO->(dbSeek(PadR(upper(cFile),LEN(CKO->CKO_ARQXML)))) .Or. ;
        CKO->(dbSeek(PadR(cFile,LEN(CKO->CKO_ARQXML))))
        Self:LogMessage("","Encontrou:cFile " + cFile + " na CKO_ARQXML:RECNO: " + AllTrim(Str(CKO->(Recno()))))            
        cRet := CKO->CKO_ARQUIV
    Else
        Self:LogMessage("","Não encontrou:cFile " + cFile + " na CKO_ARQXML. Gerar novo sequencial")
        If Self:lPerfTra
            cRet := Self:GetNumPer(cCodEdi)
        Else
            cRet := Self:GetNumSeq(cCodEdi)
        Endif
    Endif

    //-- Limpa objetos da memória
    If oFullXML <> Nil
        FreeObj(oFullXML)
    EndIf

    RestArea(aArea)
    FwFreeArray(aArea)

    DelClassIntF()

Return cRet

/*/{Protheus.doc} GetObjXML
	Objeto XML

@param cXML     Conteudo XML

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetObjXML(cXML,oObjXML,cError,cWarning) Class COMTransmite

    Local nPosPesq	:= 0
    Local cXMLEncod	:= ""

    If SubStr(cXml,1,1) != "<"
        nPosPesq := At("<",cXml)
        cXml  := SubStr(cXml,nPosPesq,Len(cXml))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
    EndIf

    cXMLEncod := EncodeUtf8(cXml)

    If Empty(cXMLEncod)
        cXMLEncod 	:= cXml
        cXml 		:= A140IRemASC(cXMLEncod)
        cXMLEncod 	:= EncodeUtf8(cXml)
    EndIf

    If !Empty(cXMLEncod)
        oObjXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
    EndIf

    //Verificar com Transmite sobre UTF16(somente NFS está vindo com problema)
    If ValType(oObjXML) <> "O"
        cXMLEncod 	:= cXml
        cXml 		:= A140IRemASC(cXMLEncod)
        cXMLEncod 	:= EncodeUtf16(cXml)

        If !Empty(cXMLEncod)
            oObjXML := XmlParser(cXMLEncod,"_",@cError,@cWarning)
        Endif
    Endif

Return

/*/{Protheus.doc} GetNumSeq
	Sequencia para nomenclatura de arquivo

@param  cCodEdi Edi importado (109/214/273/319)

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetNumSeq(cCodEdi) Class COMTransmite

    Local aArea		:= GetArea()
    Local cAliasImp	:= GetNextAlias()
    Local cNumSeq	:= "000000000000000001"
    Local cArq		:= cCodEdi + cNumSeq + ".xml"
    Local cQry		:= ""
    Local cQryStat  := ""
    Local cEdiQry	:= SubStr(cCodEdi,1,3)
    Local cEdiArq   := ""
    Local nIniDoc   := 0
    Local nSeq      := 18

    If cEdiQry == "109"
        cEdiArq := cEdiQry + "_NFE_0"
    Elseif cEdiQry == "214" .Or. cEdiQry == "273"
        cEdiArq := cEdiQry + "_CTE_0"
    Elseif cEdiQry == "319"
        cEdiArq := cEdiQry + "_NFS_0"
    Endif

    If oFindUlt == Nil
        oFindUlt := FWPreparedStatement():New()

        cQry := " SELECT CKO_ARQUIV"
        cQry += " FROM " + RetSqlName("CKO")
        cQry += " WHERE CKO_CODEDI = ?"
        cQry += " AND UPPER(CKO_ARQUIV) LIKE ?"
        cQry += " AND CKO_ARQXML <> ?"
        cQry += " AND D_E_L_E_T_ = ?"
        cQry := ChangeQuery(cQry)
        oFindUlt:SetQuery(cQry) 
    EndIf
    oFindUlt:SetString(1,cEdiQry)
    oFindUlt:SetString(2,"%"+cEdiArq+"%")
    oFindUlt:SetString(3,Space(TamSX3("CKO_ARQXML")[1]))
    oFindUlt:SetString(4,Space(1))

    cQryStat := oFindUlt:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliasImp)

    Self:LogMessage("","GetNumSeq:Query: " + cQry)
    While (cAliasImp)->(!EOF())
        cNumSeq := StrTran(Upper((cAliasImp)->CKO_ARQUIV),".XML","")
        cNumSeq := StrTran(cNumSeq,SubStr(cEdiArq,1,Len(cEdiArq)-1),"")
        
        If Val(cNumSeq) > nIniDoc
            nIniDoc := Val(cNumSeq)
        Endif

        (cAliasImp)->(DbSkip())
    Enddo

    Self:LogMessage("","GetNumSeq:nIniDoc: " + AllTrim(Str(nIniDoc)))
    If nIniDoc == 0
        nIniDoc := 1
    Else
        nIniDoc += 1
    Endif

    cNumSeq := StrZero(nIniDoc,nSeq)
    Self:LogMessage("","GetNumSeq:cNumSeq: " + cNumSeq)

    cArq := cCodEdi + cNumSeq + ".xml"
    Self:LogMessage("","GetNumSeq:NewFile: " + cArq)

    (cAliasImp)->(DbCloseArea())

    RestArea(aArea)
    FwFreeArray(aArea)

Return cArq

/*/{Protheus.doc} GetNumPer
	Sequencia para nomenclatura de arquivo

@param  cCodEdi Edi importado (109/214/273/319)

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetNumPer(cCodEdi) Class COMTransmite

    Local aArea		:= CKO->(GetArea())
    Local cNumSeq	:= ""
    Local cArq		:= ""
    Local nSeq      := 22
    Local cUUIDSeq  := UUIDRandomSeq()
    
    cNumSeq := Left(cUUIDSeq,nSeq)

    cArq := cCodEdi + cNumSeq + ".xml" 

    Self:LogMessage("","GetNumPer:NewFile: " + cArq)

    RestArea(aArea)
    FwFreeArray(aArea) 

Return cArq

/*/{Protheus.doc} GetDadosXML
	Busca dados no XML

@param  cXML    XML

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetDadosXML(cXML) Class COMTransmite 

    Local aArea		:= GetArea()
    Local oFullXML	:= Nil
    Local cError	:= ""
    Local cWarning	:= ""
    Local cDocXML	:= ""
    Local cSerXML	:= ""
    Local cForXML	:= ""
    Local cCGC		:= ""
    Local cIE		:= ""
    Local cEmpCKO	:= ""
    Local cFilCKO	:= ""
    Local oXML		:= Nil
    Local oXML2		:= Nil
    Local oXML3     := Nil
    Local cTagToma3	:= ""
    Local cTgTom3	:= ""
    Local cTagRem  	:= ""
    Local cTagDest 	:= ""
    Local cIERem   	:= ""
    Local cIEDest  	:= ""
    Local cTagToma4	:= ""
    Local cTagRec	:= ""
    Local cTagExp	:= ""
    Local cTagCGC	:= ""
    Local cDataNFS  := ""
    Local cDocNFS   := ""
    Local cCNPJNFS  := ""
    Local cChvXML   := ""
    Local aSM0      := {}
    Local nX		:= 0
    Local nQtdCNPJ	:= 0
    Local nFilImp	:= 0
    Local aFilInsc	:= {}
    Local lInscDup	:= .F.
    Local lCOLFILDUP:= ExistBlock("COLFILDUP")
    Local lNFS		:= .F.
    Local aNewDoc   := {}
    Local lCTeSimp  := .F.

    Self:GetObjXML(cXML,@oFullXML,@cError,@cWarning)

    If ValType(oFullXML) == "O" .And. Empty(cError)
        If ValType(XmlChildEx(oFullXML,"_NFEPROC")) == "O"
            Self:LogMessage("","GetDadosXML:NFE")
            If ValType(XmlChildEx(oFullXML:_NFEPROC,"_PROTNFE")) == "O"
                If ValType(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE,"_INFPROT")) == "O"
                    If ValType(XmlChildEx(oFullXML:_NFEPROC:_PROTNFE:_INFPROT,"_CHNFE")) == "O"
                        cChvXML := oFullXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
                        Self:LogMessage("","GetDadosXML:NFE:cChvXML: " + cChvXML)
                    Endif
                Endif
            Endif
            
            If ValType(XmlChildEx(oFullXML:_NFEPROC,"_NFE")) == "O"
                If ValType(XmlChildEx(oFullXML:_NFEPROC:_NFE,"_INFNFE")) == "O"
                    If Empty(cChvXML) .And. ValType(XmlChildEx(oFullXML:_NFEPROC:_NFE:_INFNFE,"_ID")) == "O"
                        cChvXML := StrTran(Upper(oFullXML:_NFEPROC:_NFE:_INFNFE:_ID:TEXT),"NFE","")
                        Self:LogMessage("","GetDadosXML:NFE:cChvXML: " + cChvXML)
                    Endif
                    cDocXML := oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_nNF:Text
                    cSerXML	:= oFullXML:_NFeProc:_NFe:_InfNfe:_Ide:_Serie:Text
                    cForXML := oFullXML:_NFeProc:_NFe:_InfNfe:_Emit:_xNome:Text
                    
                    Self:LogMessage("","GetDadosXML:NFE:cDocXML: " + cDocXML)
                    Self:LogMessage("","GetDadosXML:NFE:cSerXML: " + cSerXML)
                    Self:LogMessage("","GetDadosXML:NFE:cForXML: " + cForXML)

                    If XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_DEST,"_CNPJ") # NIL
                        cCGC := oFullXML:_NFeProc:_NFe:_InfNfe:_DEST:_CNPJ:TEXT
                    Elseif XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_DEST,"_CPF") # NIL
                        cCGC := oFullXML:_NFeProc:_NFe:_InfNfe:_DEST:_CPF:TEXT
                    EndIf

                    If XmlChildEx(oFullXML:_NFeProc:_NFe:_InfNfe:_DEST,"_IE") # NIL
                        cIE := oFullXML:_NFeProc:_NFe:_InfNfe:_DEST:_IE:TEXT					
                    EndIf
                Endif
            Endif

        Elseif ValType(XmlChildEx(oFullXML,"_NFE")) == "O"
                If ValType(XmlChildEx(oFullXML:_NFE,"_INFNFE")) == "O"
                    If Empty(cChvXML) .And. ValType(XmlChildEx(oFullXML:_NFE:_INFNFE,"_ID")) == "O"
                        cChvXML := StrTran(Upper(oFullXML:_NFE:_INFNFE:_ID:TEXT),"NFE","")
                        Self:LogMessage("","GetDadosXML:NFE:cChvXML: " + cChvXML)
                    Endif
                    cDocXML := oFullXML:_NFe:_InfNfe:_Ide:_nNF:Text
                    cSerXML	:= oFullXML:_NFe:_InfNfe:_Ide:_Serie:Text
                    cForXML := oFullXML:_NFe:_InfNfe:_Emit:_xNome:Text

                    Self:LogMessage("","GetDadosXML:NFE:cDocXML: " + cDocXML)
                    Self:LogMessage("","GetDadosXML:NFE:cSerXML: " + cSerXML)
                    Self:LogMessage("","GetDadosXML:NFE:cForXML: " + cForXML)

                    If XmlChildEx(oFullXML:_NFe:_InfNfe:_DEST,"_CNPJ") # NIL
                        cCGC := oFullXML:_NFe:_InfNfe:_DEST:_CNPJ:TEXT
                    Elseif XmlChildEx(oFullXML:_NFe:_InfNfe:_DEST,"_CPF") # NIL
                        cCGC := oFullXML:_NFe:_InfNfe:_DEST:_CPF:TEXT
                    Endif

                    If XmlChildEx(oFullXML:_NFe:_InfNfe:_DEST,"_IE") # NIL
                        cIE := oFullXML:_NFe:_InfNfe:_DEST:_IE:TEXT					
                    Endif
                Endif 
        Elseif ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_CTESIMPPROC")) == "O"
            If ValType(XmlChildEx(oFullXML,"_CTEPROC")) == "O"
                Self:LogMessage("","GetDadosXML:CTE")
                oXML := oFullXML:_CteProc:_CTe
            Elseif ValType(XmlChildEx(oFullXML,"_CTEOSPROC")) == "O"
                Self:LogMessage("","GetDadosXML:CTEOS")
                oXML := oFullXML:_CteOsProc:_CTeOs
            Elseif ValType(XmlChildEx(oFullXML,"_CTESIMPPROC")) == "O"
                Self:LogMessage("","GetDadosXML:CTESIMP")
                oXML := oFullXML:_CteSimpProc:_CTeSimp
                lCTeSimp := .T.
            Endif

            If ValType(XmlChildEx(oXML,"_INFCTE")) == "O"
                cDocXML := oXML:_InfCte:_Ide:_nCt:Text
                cSerXML	:= oXML:_InfCte:_Ide:_Serie:Text
                cForXML := oXML:_InfCte:_Emit:_xNome:Text
                cChvXML := Right(Alltrim(oXML:_InfCte:_Id:Text),44)

                Self:LogMessage("","GetDadosXML:CTE:CTEOS:CTESIMP:cDocXML: " + cDocXML)
                Self:LogMessage("","GetDadosXML:CTE:CTEOS:CTESIMP:cSerXML: " + cSerXML)
                Self:LogMessage("","GetDadosXML:CTE:CTEOS:CTESIMP:cForXML: " + cForXML)
                Self:LogMessage("","GetDadosXML:CTE:CTEOS:CTESIMP:cChvXML: " + cChvXML) 

                If !lCTeSimp
                    cTagRem  	:= If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O", If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_CNPJ")) == "O","_CNPJ","_CPF"),"")
                    cTagDest 	:= If(ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_CNPJ")) == "O","_CNPJ","_CPF"),"")
                    cIERem   	:= If(ValType(XmlChildEx(oXML:_InfCte,"_REM")) == "O", If(ValType(XmlChildEx(oXML:_InfCte:_Rem,"_IE")) == "O","_IE",""),"")
                    cIEDest  	:= If(ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O",If(ValType(XmlChildEx(oXML:_InfCte:_Dest,"_IE")) == "O","_IE",""),"")

                    If ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA03")) <> "U"
                        cTagToma3	:= AllTrim(oXML:_InfCte:_Ide:_Toma03:_TOMA:Text)
                        cTgTom3	:= "_TOMA03"
                    Elseif ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA3")) <> "U"
                        cTagToma3	:= AllTrim(oXML:_InfCte:_Ide:_Toma3:_TOMA:Text)
                        cTgTom3	:= "_TOMA3"
                    Endif
                
                    If ValType(XmlChildEx(oXML:_InfCte:_Ide,cTgTom3)) <> "U" 
                        If cTagToma3 == "0" //Remetente
                            If ValType(XmlChildEx(oXML:_InfCte:_Rem,cTagRem)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cTagRem):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Rem,cIERem)) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Rem,cIERem):Text)
                            EndIf
                        ElseIf cTagToma3 == "1" //Expedidor
                            cTagExp := If(ValType(XmlChildEx(oXML:_InfCte:_Exped,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Exped,cTagExp)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,cTagExp):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Exped,"_IE")) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Exped,"_IE"):Text)
                            EndIf
                        ElseIf cTagToma3 == "2" //Recebedor
                            cTagRec := If(ValType(XmlChildEx(oXML:_InfCte:_Receb,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Receb,cTagRec)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,cTagRec):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Receb,"_IE")) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Receb,"_IE"):Text)
                            EndIf
                        ElseIf cTagToma3 == "3" //Destinatario
                            If ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
                            EndIF
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
                            EndIF
                        EndIf
                    ElseIf ValType(XmlChildEx(oXML:_InfCte:_Ide,"_TOMA4")) <> "U"
                        If AllTrim(oXML:_InfCte:_Ide:_Toma4:_TOMA:Text) == "4"
                            cTagToma4 := If(ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4)) == "O"
                                cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,cTagToma4):Text)
                            EndIf
                            
                            If ValType(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_IE")) == "O"
                                cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Ide:_Toma4,"_IE"):Text)
                            EndIf
                        EndIf
                    Elseif ValType(XmlChildEx(oXML:_InfCte,"_TOMA")) <> "U"
                        cTagCGC := If(ValType(XmlChildEx(oXML:_InfCte:_Toma,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                        If ValType(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC)) == "O"
                            cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC):Text)
                        EndIf
                        
                        If ValType(XmlChildEx(oXML:_InfCte:_Toma,"_IE")) == "O"
                            cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,"_IE"):Text)
                        EndIf
                    Else //Se o xml não possui as tags Toma3 e Toma4, o documento será processado na filial do destinatario
                        If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cTagDest)) == "O"
                            cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cTagDest):Text)
                        EndIF
                        
                        If ValType(XmlChildEx(oXML:_InfCte,"_DEST")) == "O" .And. ValType(XmlChildEx(oXML:_InfCte:_Dest,cIEDest)) == "O"
                            cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Dest,cIEDest):Text)			
                        EndIF
                    EndIf
                Else //CTe Simplificado
                    If ValType(XmlChildEx(oXML:_InfCte,"_TOMA")) == "O"
                        cTagCGC := If(ValType(XmlChildEx(oXML:_InfCte:_Toma,"_CNPJ")) == "O","_CNPJ","_CPF")
                            
                        If ValType(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC)) == "O"
                            cCGC 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,cTagCGC):Text)
                        EndIf
                        
                        If ValType(XmlChildEx(oXML:_InfCte:_Toma,"_IE")) == "O"
                            cIE 	:= AllTrim(XmlChildEx(oXML:_InfCte:_Toma,"_IE"):Text)
                        EndIf
                    EndIF
                Endif
            Endif
        Elseif ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O" .Or. ValType(XmlChildEx(oFullXML,"_PROCNEOGRIDNFSE")) == "O"
            Self:LogMessage("","GetDadosXML:NFS")
            
            If ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O" .And. ValType(XmlChildEx(oFullXML:_PROCTRANSMITENFSE,"_TRANSMITE")) == "O"
                oXML    := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE
                
                If ValType(XmlChildEx(oXML,"_RETTRANSMITENFSE")) == "O"
                    oXML2   := oXML:_RETTRANSMITENFSE
                Endif

                If ValType(XmlChildEx(oXML,"_TRANSMITERPS")) == "O"
                    oXML3   := oXML:_TRANSMITERPS
                Endif
            Elseif ValType(XmlChildEx(oFullXML,"_PROCNEOGRIDNFSE")) == "O" .And. ValType(XmlChildEx(oFullXML:_PROCNEOGRIDNFSE,"_NEOGRID")) == "O"
                oXML    := oFullXML:_PROCNEOGRIDNFSE:_NEOGRID
                
                If ValType(XmlChildEx(oXML,"_RETNEOGRIDNFSE")) == "O"
                    oXML2   := oXML:_RETNEOGRIDNFSE
                Endif

                If ValType(XmlChildEx(oXML,"_NEOGRIDRPS")) == "O"
                    oXML3   := oXML:_NEOGRIDRPS
                Endif
            Endif
            
            If ValType(XmlChildEx(oXML2,"_CNPJPREST")) == "O"
                cCNPJNFS  := oXML2:_CNPJPREST:TEXT
            Elseif ValType(XmlChildEx(oXML2,"_CPFPREST")) == "O"
                cCNPJNFS  := oXML2:_CPFPREST:TEXT
            Endif

            If ValType(XmlChildEx(oXML2,"_NNFSE")) == "O"
                cDocNFS   := oXML2:_NNFSE:TEXT
                cDocXML   := cDocNFS
            Endif

            If ValType(XmlChildEx(oXML2,"_DTEMISNFSE")) == "O"
                cDataNFS  := oXML2:_DTEMISNFSE:TEXT
            Endif

            If FindFunction("ComNFSNewDoc")
                aNewDoc := ComNFSNewDoc(cDocXML,oFullXML,"CKO")
                If Len(aNewDoc) > 0
                    cDocXML := aNewDoc[1]
                Endif
            Endif
            
            cChvXML := cDataNFS + "|" + cCNPJNFS + "|" + cDocNFS
            
            cForXML := oXML3:_RPS:_PRESTADOR:_RSOCIALPREST:TEXT
            
            If ValType(XmlChildEx(oXML3:_RPS:_TOMADOR,"_CNPJTOM")) == "O"
                cCGC  := oXML3:_RPS:_TOMADOR:_CNPJTOM:TEXT
            Elseif ValType(XmlChildEx(oXML3:_RPS:_TOMADOR,"_CPFTOM")) == "O"
                cCGC  := oXML3:_RPS:_TOMADOR:_CPFTOM:TEXT
            Endif
            
            lNFS    := .T.
            
            Self:LogMessage("","GetDadosXML:NFS:cChvXML: " + cChvXML)
            Self:LogMessage("","GetDadosXML:NFS:cDocXML: " + cDocXML)
            Self:LogMessage("","GetDadosXML:NFS:cSerXML: " + cSerXML)
            Self:LogMessage("","GetDadosXML:NFS:cForXML: " + cForXML)
        Endif

        If !Empty(cCGC)
            aSM0       := FWLoadSM0()

            For nX := 1 To Len(aSM0)
                If cCGC $ aSM0[nX][SM0_CGC]
                    nQtdCNPJ++
                EndIf
            Next nX

            Self:LogMessage("","GetDadosXML:CGC possui: " + Alltrim(Str(nQtdCNPJ)) + " empresas")
            If nQtdCNPJ == 1
                If (nFilImp := (ASCan(aSM0,{|x| AllTrim(x[SM0_CGC]) == cCgc }))) > 0
                    cEmpCKO := AllTrim(aSM0[nFilImp][SM0_GRPEMP])				
                    cFilCKO := AllTrim(aSM0[nFilImp][SM0_CODFIL])	
                Endif
            Elseif nQtdCNPJ > 1
                If !Empty(AllTrim(cIE))
                    //FORCA O CONTEUDO ISENTO
                    If "ISENT" $ cIE
                        cIE := "ISENTO"
                    EndIf  
                Else
                    If !lNFS
                        cIE := "ISENTO"
                    Endif 
                EndIf
                    
                aFilInsc := InscEstSM0(cCgc,cIE,@lInscDup)
                
                If !Empty(aFilInsc)
                    cEmpCKO := aFilInsc[1]				
                    cFilCKO := aFilInsc[2]
                Elseif Empty(aFilInsc) .And. lInscDup .And. lCOLFILDUP
                    aFilInsc := ExecBlock("COLFILDUP",.F.,.F.,{cCgc,cIE})
                    If ValType(aFilInsc) == "A" .And. Len(aFilInsc) == 2
                        cEmpCKO := aFilInsc[1]				
                        cFilCKO := aFilInsc[2] 
                    Endif
                Endif
            Endif

            Self:LogMessage("","GetDadosXML:DOC:cEmpCKO: " + cEmpCKO)
            Self:LogMessage("","GetDadosXML:DOC:cFilCKO: " + cFilCKO)
        Endif
    Endif

    //-- Limpa objetos da memória
    If oFullXML <> Nil
        FreeObj(oFullXML)
    EndIf
    If oXML <> Nil
        FreeObj(oXML)
    EndIf
    If oXML2 <> Nil
        FreeObj(oXML2)
    EndIf
    If oXML3 <> Nil
        FreeObj(oXML3)
    EndIf

    RestArea(aArea)
    FwFreeArray(aArea)
    FwFreeArray(aSM0)
    FwFreeArray(aFilInsc)

    DelClassIntF() 

Return {cChvXML,cDocXML,cSerXML,cForXML,cEmpCKO,cFilCKO,cDocNFS}  

/*/{Protheus.doc} FindCKODOC
	Busca mesmo documento na CKO

@param  cChvXML     Chave documento

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method FindCKODOC(cChvXML) Class COMTransmite

Local cQry        := ""
Local cQryStat    := ""
Local cCKOAli     := ""
Local cFile       := "" //Preenchido = Encontro CKO / Em branco =  Não existe CKO
Local cFlag       := ""
Local lAtuTra     := .F.

If Self:lCkoTra .And. Self:lCkoRepro
    Self:LogMessage(,"FindCKODOC:cChvXML: " + cChvXML)
    
    If !Empty(cChvXML)
        cCKOAli     := GetNextAlias()

        If oFindCKO == nil 
            oFindCKO := FWPreparedStatement():New()

            cQry := " SELECT CKO_ARQUIV, CKO_FLAG, CKO_ORIGEM FROM " + RetSqlName("CKO") + " CKO"
            cQry += " WHERE CKO.CKO_CHVDOC = ? "
            cQry += " AND D_E_L_E_T_ = ?"
            cQry := ChangeQuery(cQry)

            oFindCKO:SetQuery(cQry) 
        EndIf 
        oFindCKO:SetString(1,cChvXML)
        oFindCKO:SetString(2,Space(1))

        cQryStat := oFindCKO:GetFixQuery()
        MpSysOpenQuery(cQryStat,cCKOAli)

        Self:LogMessage(,"FindCKODOC:Query:cChvXML: " + cQryStat)
        If (cCKOAli)->(!EOF())
            cFile    := (cCKOAli)->CKO_ARQUIV
            cFlag    := (cCKOAli)->CKO_FLAG
            lAtuTra := Iif(AllTrim((cCKOAli)->CKO_ORIGEM) <> "TRANSMITE",.T.,.F.)
            Self:LogMessage("","FindCKODOC:Query:cChvXML:cFile " + cFile)
        Endif

        (cCKOAli)->(DbCloseArea())
    Endif
Endif

Return {cFile,cFlag,lAtuTra}

/*/{Protheus.doc} XMLTRANSMITE
	Busca XMLs a serem importador atraves do Transmite para CKO

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method XMLTransmite() Class COMTransmite
	
	Local nI		:= 0
    Local aCodFil   := {}
    Local aTpXml	:= {}
    Local aIdCodFil := {}
    Local aProcs    := {}
    Local cRaizNome	:= 'COMTRAPROC'
    Local cToken    := ""

    If lAuthToken
        cToken := totvs.framework.users.rpc.getAuthToken()
    EndIf

    Self:LogMessage("","Verifica quais XML serão importados (NFE/NFS/CTE/CTO)")
    
    If "NFE" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"NFE",Self:cApiUrlExpNFE,Self:cApiUrlZipNFE})
    Endif
    
    If "NFS" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"NFS",Self:cApiUrlExpNFS,Self:cApiUrlZipNFS})
    Endif
    
    If "CTE" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"CTE"  ,Self:cApiUrlExpCTE,Self:cApiUrlZipCTE})
    Endif

    If "CTO" $ Self:cMVDOCIMP
        aAdd(aTpXML,{"CTO",Self:cApiUrlExpCTO,Self:cApiUrlZipCTO})
    Endif

    Self:LogMessage("","Verifica quais filiais estão configuradas com o Transmite")
    Self:GetCodFilDHW(@aCodFil)

    If Len(aCodFil) > 0
        Self:LogMessage("","Busca Ids de exportação dos XML")
        Self:GetIdsExpXML(aTpXML,aCodFil)

        Self:GetIdDHY(@aIdCodFil,aCodFil,aTpXML)

        If Len(aIdCodFil) > 0
            If Self:nNumProc > 1 .and. Self:lPerfTra 
                aProcs := Self:PrepProcIds(Self:nNumProc,Len(aIdCodFil),cRaizNome) 
                For nI := 1 to Len(aProcs)
                    StartJob("JOBCOMTRA", GetEnvServer(), .F., cEmpAnt,cFilAnt,aProcs[nI][2],aProcs[nI][1],aProcs[nI][4],__cUserId,cUserName,cAcesso,cUsuario,aProcs[nI][5],aProcs[nI][6],aIdCodFil,cToken)
                Next nI
            Else
                Self:ReadRecibo(aIdCodFil)

                Self:LogMessage("","Apaga Id/Historico") 
                Self:PutHistDHZ()

                Self:LogMessage("","Apaga pasta com numero da Thread")
                Self:Cleanup("DELP")
                Self:Cleanup("DELL")
            Endif            
        Endif
    Endif

    Self:LogMessage("","Apaga pasta com numero da Thread")
    Self:Cleanup("DELP")
    Self:Cleanup("DELL")

    FwFreeArray(aCodFil)
    FwFreeArray(aTpXml)
    FwFreeArray(aIdCodFil)
    FwFreeArray(aProcs)

Return

/*/{Protheus.doc} ReadRecibo
	Leitura dos Recibos

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method ReadRecibo(aIdCodFil,cOpc,aRetIpTool) Class COMTransmite 

Local cResource	:= ""
Local cDtTempo	:= ""
Local cZip      := ""
Local cRetorno  := ""
Local oJsonResp := Nil
Local oRest     := Nil
Local nZ        := 0

Local xRetorno  := NIL
Local xStatus   := NIL
Local xMessage  := Nil

Default cOpc        := ""
Default aRetIpTool  := {}

oRest 	:= FwRest():New(Self:cApiTra)

For nZ := 1 To Len(aIdCodFil)
    If Empty(cOpc)
        Self:LogMessage("","Lendo recibo da Filial | Tipo XML | Recibo: " + aIdCodFil[nZ,1] + "|" + aIdCodFil[nZ,2] + "|" + aIdCodFil[nZ,3])
    Endif
    oJsonResp := JsonObject():New()
    cResource := aIdCodFil[nZ,4] + aIdCodFil[nZ,3]
    oRest:SetPath(cResource) 

    cRetorno    := ""
    nStatus     := 0
    If oRest:Get(Self:aHeaderOut)
        cTextJson := oRest:GetResult() 
        oJsonResp:FromJson(cTextJson)
        xRetorno    := oJsonResp:GetJsonObject("Retorno")
        cRetorno    := Iif(ValType(xRetorno)=="C",xRetorno,oJsonResp:GetJsonObject("retorno"))

        xStatus     := oJsonResp:GetJsonObject("Status")
        nStatus     := Iif(ValType(xStatus)=="N",xStatus,oJsonResp:GetJsonObject("status"))

        xMessage     := oJsonResp:GetJsonObject("Descricao")
        cMessage     := Iif(ValType(xMessage)=="C",xMessage,oJsonResp:GetJsonObject("descricao"))
        
        cDtTempo := DtoS(Date())+StrTran(Time(),":","")
        
        If Empty(cOpc)
            If nStatus > 0
                If nStatus == 1 .And. !Empty(cRetorno) //Recibo com retorno (tem XMLs)
                    Self:LogMessage(cTextJson,"Descompacta XML do Id: " + aIdCodFil[nZ,3])
                    cZip  := Self:GetZIP(cRetorno,aIdCodFil[nZ,2],cDtTempo) //Gerar arquivo ZIP
                    If !Empty(cZip) //Entra somente se foi criado o arquivo ZIP
                        Self:LogMessage("","Gravando XMLs na CKO do Id: " + aIdCodFil[nZ,3])
                        If Self:GetXML(cZip,aIdCodFil[nZ,3]) //Entra somente se houver arquivos XML descompactados e atualiza status
                            Self:LogMessage("","Atualiza status Id: " + aIdCodFil[nZ,3])
                            Self:PutStatusDHY(aIdCodFil[nZ,1],aIdCodFil[nZ,2],aIdCodFil[nZ,3],nStatus,cMessage)
                        Endif
                    Endif
                Elseif nStatus == 1 .And. Empty(cRetorno)
                    Self:LogMessage(cTextJson,"Recibo sem retorno: " + cMessage + CRLF + "Atualiza status Id: " + aIdCodFil[nZ,2])
                    Self:PutStatusDHY(aIdCodFil[nZ,1],aIdCodFil[nZ,2],aIdCodFil[nZ,3],nStatus,cMessage)
                Elseif nStatus == 2
                    Self:LogMessage("","Recibo com erro: " + cMessage)
                    Self:LogMessage("","Atualiza status Id: " + aIdCodFil[nZ,3])
                    Self:PutStatusDHY(aIdCodFil[nZ,1],aIdCodFil[nZ,2],aIdCodFil[nZ,3],nStatus,cMessage)
                Endif
            Elseif nStatus == 0
                Self:LogMessage(cTextJson,"Atualiza status Id (Aguardando) - Tentativas: " + aIdCodFil[nZ,3])
                Self:PutStatusDHY(aIdCodFil[nZ,1],aIdCodFil[nZ,2],aIdCodFil[nZ,3],nStatus)
            Endif
        Else
            If !Empty(cRetorno)
				aAdd(aRetIpTool,"Recibo: " + cRecibo + " com retorno: " + SubStr(cRetorno,1,50) + CRLF + CRLF)
			Else
				aAdd(aRetIpTool,"Recibo: " + cRecibo + " sem retorno" + CRLF + CRLF)
			Endif

            aAdd(aRetIpTool,"Tipo XML: " + aIdCodFil[nZ,2] + " Status: " + AllTrim(Str(nStatus)) + " Mensagem: " + cMessage + CRLF + CRLF)
        Endif
    Else
        cTextJson := oRest:GetResult()
        Self:cLastError := oRest:GetLastError()
        Self:lAPIError := .T.
        
        If Empty(cOpc)
            Self:LogMessage(cTextJson, "Erro ao consultar recibo: " + oRest:GetLastError())
        Else
            aAdd(aRetIpTool," Recibo: " + cRecibo + " com erro" + CRLF + CRLF)
			aAdd(aRetIpTool," Tipo XML: " + aIdCodFil[nZ,2] + CRLF + CRLF)
			aAdd(aRetIpTool," Erro cTextJson: " + cTextJson + CRLF + CRLF)
			aAdd(aRetIpTool," Erro GetLastError: " + oRest:GetLastError() + CRLF + CRLF)
        Endif
    EndIf
Next nZ

//-- Limpa objetos da memória
If oJsonResp <> Nil
    FreeObj(oJsonResp)
EndIf

If oRest <> Nil
    FreeObj(oRest)
EndIf

Return

/*/{Protheus.doc} GetCodFilDHW
	Busca Id empresa na DHW

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetCodFilDHW(aRetId) Class COMTransmite

    Local cQry          := ""
    Local cAliTmp       := ""
    Local cQryStat      := ""

    If Self:lDHW
        cAliTmp := GetNextAlias() 

        If oFindDHW == nil 
            oFindDHW := FWPreparedStatement():New()

            cQry := " SELECT DHW_CODFIL FROM " + RetSqlName("DHW")
            cQry += " WHERE D_E_L_E_T_ = ?"
            cQry += " AND DHW_CODFIL <> ?"
            cQry += " GROUP BY DHW_CODFIL"
            cQry := ChangeQuery(cQry)

            oFindDHW:SetQuery(cQry) 
        EndIf 
        oFindDHW:SetString(1,Space(1))
        oFindDHW:SetString(2,Space(Len(DHW->DHW_CODFIL))) 

        cQryStat := oFindDHW:GetFixQuery()
        MpSysOpenQuery(cQryStat,cAliTmp)

        While (cAliTmp)->(!EOF())
            Self:LogMessage("","Adicionando Filial: " + (cAliTmp)->DHW_CODFIL)
            aAdd(aRetId,(cAliTmp)->DHW_CODFIL)
            (cAliTmp)->(DbSkip()) 
        Enddo
        (cAliTmp)->(DbCloseArea())
    Endif

Return

/*/{Protheus.doc} GetIdsExpXML
Busca Ids não importados

@param  aTpXML  Tipo XML (NFE/NFS/CTE)
@param  aCodFil Codigo Filial (DHW_CODFIL)
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetIdsExpXML(aTpXML,aCodFil) Class COMTransmite

    Local nI        := 0
    Local nY        := 0
    Local oRestPost := Nil
    Local oJsonResp := Nil
    Local cResource := ""
    Local aIdCodFil := {}
    Local cExp      := ""
    Local cExpOrd   := ""
    Local cFiltro   := ""
    Local cCnpjTom  := ""
    
    If !Empty(Self:dDataIni)
        nMes        := Month(Self:dDataIni)
        nYear       := Year(Self:dDataIni)
        nDay        := Day(Self:dDataIni)
        cDataIni    := AllTrim(Str(nYear)) + "-" + AllTrim(StrZero(nMes,2)) + "-" + AllTrim(StrZero(nDay,2))  +"T00:00:00"
    Endif

    //Operador ge = Maior ou igual
    //Operador gt = Maior
    //Operador le = Menor ou igual
    //Operador lt = Menor 
    
    For nI := 1 To Len(aCodFil)
        For nY := 1 To Len(aTpXML)
            cExp := ""
            If aTpXML[nY,1] == "NFE"
                If !Empty(Self:dDataIni)
                    cExp    := " and DhEmi ge '" + cDataIni + "'"
                Endif
                cExp += " and Ator eq 'Destinatario'"
                cExpOrd := "DhEmi"
            ElseIf aTpXML[nY,1] == "NFS"
                If !Empty(Self:dDataIni)
                    cExp    := " and DataEmissao ge '" + cDataIni + "'"
                Endif
                cExpOrd := "DataEmissao"
            ElseIf aTpXML[nY,1] == "CTE" .Or. aTpXML[nY,1] == "CTO"
                If !Empty(Self:dDataIni)
                    cExp    := " and Emissao ge '" + cDataIni + "'"
                Endif                
                cExpOrd := "Emissao"

                cCnpjTom    := GetAdvFVal("DHW","DHW_CGC",xFilial("DHW") + aCodFil[nI],2)
                If !Empty(cCnpjTom)
                    cExp += " and CpfCnpjTomador eq '" + AllTrim(cCnpjTom) + "'"
                Endif
            Endif

            If Self:nDocReq > 0
                cExp += " &$top=" + AllTrim(Str(Self:nDocReq))
            Endif        

            cIdMsg      := "" 
            oRestPost 	:= FwRest():New(Self:cApiTra) 
            
            cResource   := aTpXML[nY,2] + "?$filter=CodigoFilial eq '" + aCodFil[nI] + "' and IntegracaoERP eq 'Pendente'" + cExp + " &$orderby=" + cExpOrd + " desc"
            cResource   := StrTran(cResource," ","%20")

            Self:LogMessage("","API: " + aTpXML[nY,2]) 

            cFiltro     := "CodigoFilial eq '" + aCodFil[nI] + "' and IntegracaoERP eq 'Pendente'" + cExp
            
            If Self:GetNewReceipt(aTpXML[nY,1],cFiltro) 
                oJsonResp := JsonObject():New()  
                oRestPost:SetPath(cResource)

                If oRestPost:Post(Self:aHeaderOut)  
                    cTextJson := oRestPost:GetResult() 
                    oJsonResp:FromJson(cTextJson)
                    cIdMsg := oJsonResp:GetJsonObject("receipt")  

                    If !Empty(cIdMsg)  
                        aAdd(aIdCodFil,{aCodFil[nI],aTpXML[nY,1],cIdMsg,cFiltro})
                        Self:LogMessage("","Novo recibo: " + cIdMsg + " - " + aTpXML[nY,1] + " - " + aCodFil[nI])
                    Endif
                Else
                    cTextJson := oRestPost:GetResult()
                    Self:cLastError := oRestPost:GetLastError()
                    Self:lAPIError := .T.
                    
                    Self:LogMessage(cTextJson, "Erro ao solicitar novo recibo: " + oRestPost:GetLastError())
                EndIf
            Endif
        Next nY
    Next nI

    If Len(aIdCodFil) > 0 .And. Self:lDHY
        Self:LogMessage("","Grava Ids de exportação dos XML")
        Self:PutIdDHY(aIdCodFil)
    Endif

    //-- Limpa objetos da memória
    If oRestPost <> Nil
        FreeObj(oRestPost)
    EndIf
    If oJsonResp <> Nil
        FreeObj(oJsonResp)
    EndIf

    FwFreeArray(aIdCodFil)

Return

/*/{Protheus.doc} GetNewReceipt
Valida se recibo ja foi lido para gerar novo

@param  cTpXML     Tipo XML
@param  cResource  String requisição
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetNewReceipt(cTpXML,cResource) Class COMTransmite

Local cQry      := ""
Local cQryStat  := ""
Local cAliTmp   := ""
Local lRet      := .T.

If Self:lDHYFil
    cAliTmp := GetNextAlias()

    If oNewDHW == nil 
        oNewDHW := FWPreparedStatement():New()  

        cQry := " SELECT DHY_ID FROM " + RetSqlName("DHY")
        cQry += " WHERE DHY_FILTRO = ?"
        cQry += " AND DHY_TPXML = ?"
        cQry += " AND DHY_STATUS = ?"
        cQry += " AND D_E_L_E_T_ = ?"
        cQry := ChangeQuery(cQry)

        oNewDHW:SetQuery(cQry)
    EndIf 
    oNewDHW:SetString(1,cResource)
    oNewDHW:SetString(2,cTpXML)
    oNewDHW:SetString(3,'0')
    oNewDHW:SetString(4,Space(1))

    cQryStat := oNewDHW:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)

    If (cAliTmp)->(!EOF())
        Self:LogMessage(,"NewReceipt: NÃO - Recibo ja existente para o filtro: " + cResource)
        lRet := .F.
    Else
        Self:LogMessage(,"NewReceipt: SIM - Solicitara novo recibo ao Transmite para o filtro: " + cResource)
    Endif

    (cAliTmp)->(DbCloseArea())
Endif

Return lRet

/*/{Protheus.doc} PutIdDHY
Grava Ids não importados

@param  aIdCodFil   Id transação
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PutIdDHY(aIdCodFil) Class COMTransmite

    Local nI        := 0
    Local oBulkDHY  := Nil
    Local aFieldDHY := {{"DHY_FILIAL"},{"DHY_CODFIL"},{"DHY_TPXML"},{"DHY_ID"},{"DHY_STATUS"}}
    Local aRegDHY   := {}

    If Self:lPerfTra
        oBulkDHY := FWBulk():New(RetSqlName("DHY"), 1000)
        If Self:lDHYFil
            aAdd(aFieldDHY, {"DHY_DTID"})
            aAdd(aFieldDHY, {"DHY_TENT"})
            aAdd(aFieldDHY, {"DHY_FILTRO"})
        Endif
        oBulkDHY:setFields(aFieldDHY)
    Endif
    
    DbSelectArea("DHY")
    DHY->(DbSetOrder(1))
    For nI := 1 To Len(aIdCodFil)
        If !DHY->(dbSeek(xFilial("DHY") + PadR(aIdCodFil[nI,1],Self:nTamCod) + PadR(aIdCodFil[nI,2],Self:nTamTp) + PadR(aIdCodFil[nI,3],Self:nTamId)))
            If Self:lPerfTra
                aRegDHY := {} 

                aAdd(aRegDHY,xFilial("DHY"))    //DHY_FILIAL
                aAdd(aRegDHY,aIdCodFil[nI,1])   //DHY_CODFIL
                aAdd(aRegDHY,aIdCodFil[nI,2])   //DHY_TPXML
                aAdd(aRegDHY,aIdCodFil[nI,3])   //DHY_ID
                aAdd(aRegDHY,"0")               //DHY_STATUS

                If Self:lDHYFil
                    aAdd(aRegDHY,dDataBase)       //DHY_DTID
                    aAdd(aRegDHY,0)               //DHY_TENT
                    aAdd(aRegDHY,aIdCodFil[nI,4]) //DHY_FILTRO
                Endif

                oBulkDHY:addData(aRegDHY)
            Else
                If RecLock("DHY",.T.)
                    DHY->DHY_FILIAL := xFilial("DHY")
                    DHY->DHY_CODFIL := aIdCodFil[nI,1]
                    DHY->DHY_TPXML  := aIdCodFil[nI,2]
                    DHY->DHY_ID     := aIdCodFil[nI,3]
                    DHY->DHY_STATUS := "0"

                    If Self:lDHYFil
                        DHY->DHY_DTID   := dDataBase
                        DHY->DHY_TENT   := 0
                        DHY->DHY_FILTRO := aIdCodFil[nI,4]
                    Endif
                    
                    DHY->(MsUnlock())
                Endif
            Endif
            Self:LogMessage("","Gravado Ids: " + aIdCodFil[nI,3] + " - " + aIdCodFil[nI,2] + " - " + aIdCodFil[nI,1])
        Endif
    Next nI

    If Self:lPerfTra
        Self:LogMessage("","Gravando DHY (Bulk)")   
        oBulkDHY:Close()

        Self:LogMessage("","Erro Bulk: " + oBulkDHY:GetError())
        oBulkDHY:Destroy()

        FreeObj(oBulkDHY)
    Endif

    FwFreeArray(aFieldDHY)
    FwFreeArray(aRegDHY)

Return

/*/{Protheus.doc} GetIdDHY
Busca Ids não importados

@param  aCodFil Codigo Filial (DHW_CODFIL)
@param  aTpXML  Tipo XML (NFE/NFS/CTE/CTO)
@param  aRet    Recibos a serem lidos
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetIdDHY(aRet,aCodFil,aTpXML) Class COMTransmite

    Local cQry      := ""
    Local cAliTmp   := ""
    Local cQryStat  := ""
    Local nPos      := 0
    Local nI        := 0
    Local aTpXMLQry := {}
    Local cApi      := ""

    If Self:lDHY
        For nI := 1 To Len(aTpXML)
            aAdd(aTpXMLQry,aTpXML[nI,1])
        Next nI

        cAliTmp := GetNextAlias()

        If oFindDHY == nil 
            oFindDHY := FWPreparedStatement():New()

            cQry := " SELECT DHY_CODFIL, DHY_TPXML, DHY_ID FROM " + RetSqlName("DHY")
            cQry += " WHERE DHY_CODFIL IN (?)"
            cQry += " AND DHY_TPXML IN (?)"
            cQry += " AND DHY_STATUS = ?"
            cQry += " AND D_E_L_E_T_ = ?" 
                        
            oFindDHY:SetQuery(cQry) 
        EndIf 
        
        oFindDHY:SetIn(1,aCodFil)
        oFindDHY:SetIn(2,aTpXMLQry)
        oFindDHY:SetString(3,'0')
        oFindDHY:SetString(4,Space(1))

        cQryStat := oFindDHY:GetFixQuery()
        MpSysOpenQuery(cQryStat,cAliTmp)

        Self:LogMessage("","GetIdDHY:Query: " + cQryStat)
        While (cAliTmp)->(!EOF())
            Self:LogMessage("","Recibos a serem lidos da Filial|Tipo XML: " + (cAliTmp)->DHY_CODFIL + "|" + (cAliTmp)->DHY_TPXML + "|" + (cAliTmp)->DHY_ID)

            nPos := aScan(aTpXML,{|x| AllTrim(x[1]) == AllTrim((cAliTmp)->DHY_TPXML)})
            If nPos > 0
                cApi := aTpXML[nPos,3] 
            Endif

            aAdd(aRet,{(cAliTmp)->DHY_CODFIL,(cAliTmp)->DHY_TPXML,(cAliTmp)->DHY_ID,cApi})
            (cAliTmp)->(DbSkip()) 
        Enddo
        (cAliTmp)->(DbCloseArea())
    Endif

    FwFreeArray(aTpXMLQry)

Return

/*/{Protheus.doc} GetZIP
	Decodifica BASE64 e gera arquivo ZIP

@param  cMsg    Base64
@param  cTpXML  Tipo documento (NFE/CTE/NFS)
@param  cIdZip  Id arquivo ZIP

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetZIP(cMsg,cTpXML,cIdZip) Class COMTransmite
	
	Local cArq		:= ""
	Local cFileZip	:= ""

    cArq := Self:cMVXMLTRA + "descompacta_"+Lower(cTpXML)+"_"+cIdZip+".zip"
    
    Self:LogMessage("","Decode arquivo: " + cArq)
	cFileZip	:= Decode64( cMsg , cArq , .T.)
  
Return cArq

/*/{Protheus.doc} GetXML
	Busca XMLs pelo Transmite e/ou pela pasta IN

@param  nOpc    1 = Descompacta Base64 / 2 = Pasta IN
@param  cRecibo Recibo sendo lido

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetXML(cZip,cRecibo) Class COMTransmite
	
	Local aFiles	:= {}
    Local nI		:= 0
    Local lRet      := .F.

    Self:LogMessage("","Descompactando XMLs")
    FUnZip(cZip,Self:cMVXMLTRA)

    Self:FindXML(Self:cMVXMLTRA, @aFiles)

    If Len(aFiles) > 0
        lRet := .T.
        Self:LogMessage("","Lendo XMLs do Transmite")
        For nI := 1 To Len(aFiles)
            Self:LogMessage("","FindXML:GetXML:aFiles: " + aFiles[nI,1])
        Next nI

        Self:LogMessage("","Gravando XMLs")
        Self:PostXMLCKO(aFiles,"TR",cRecibo)

        Self:LogMessage("","Apagando arquivos da IN/TRANSMITE")
        Self:Cleanup("DEL",aFiles,cZip)
    Endif

    FwFreeArray(aFiles)

Return lRet

/*/{Protheus.doc} PutStatusDHY
Atualiza status do ID lido

@param  cCodFil     Codigo Filial (DHW_CODFIL)
@param  cTpXML      Tipo XML (NFE/NFS/CTE)
@param  cId         Id da transação
@param  nStatus     1-Ok / 2-Erro
@param  xMessage    Message de retorno
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PutStatusDHY(cCodFil,cTpXML,cId,nStatus,xMessage) Class COMTransmite

    Default xMessage := ""

    If Self:lDHY
        DbSelectArea("DHY")
        DHY->(DbSetOrder(1)) 
        If DHY->(dbSeek(xFilial("DHY") + PadR(cCodFil,Self:nTamCod) + PadR(cTpXML,Self:nTamTp) + Padr(cId,Self:nTamId)))
            If RecLock("DHY",.F.)
                DHY->DHY_STATUS := AllTrim(Str(nStatus))
                If Self:lDHYFil
                    DHY->DHY_TENT := DHY->DHY_TENT + 1

                    If Empty(DHY->DHY_DTID)
                        DHY->DHY_DTID := dDataBase
                    Endif
                Endif

                If Self:lDHYDHZMes
                    DHY->DHY_MESSAG := xMessage
                Endif

                DHY->(MsUnlock())
            Endif
        Endif
    Endif

Return

/*/{Protheus.doc} PutHistDHZ
	Grava Id gerados na DHZ como historico

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PutHistDHZ(aReadId) Class COMTransmite

    Local cQry      := ""
    Local cQryStat  := ""
    Local cAliTmp   := ""
    Local aFilDHY   := {}
    Local aTpXDHY   := {}
    Local aIdDHY    := {}
    Local nI        := 0
    Local nPos      := 0
    Local nOrder    := 1
    Local oUpdDHZ   := Nil
    Local oDelDHY   := Nil
    Local oBulkDHZ  := Nil
    Local aFieldDHZ := {{"DHZ_FILIAL"},{"DHZ_CODFIL"},{"DHZ_TPXML"},{"DHZ_ID"},{"DHZ_STATUS"}}
    Local aRegDHZ   := {}

    Default aReadId := {}

    If Self:lPerfTra
        oBulkDHZ := FWBulk():New(RetSqlName("DHZ"), 1000)
        
        If Self:lDHYFil .And. Self:lDHZFil
            aAdd(aFieldDHZ, {"DHZ_FILTRO"})
            aAdd(aFieldDHZ, {"DHZ_TENT"})
            aAdd(aFieldDHZ, {"DHZ_DTID"})
            aAdd(aFieldDHZ, {"DHZ_DTLID"})
        Endif

        If Self:lDHYDHZMes
            aAdd(aFieldDHZ, {"DHZ_MESSAG"})
        Endif
        oBulkDHZ:setFields(aFieldDHZ)
    Endif

    If Len(aReadId) > 0
        For nI := 1 To Len(aReadId)
            nPos := aScan(aFilDHY,{|x| AllTrim(x) == AllTrim(aReadId[nI,1])})
            If nPos == 0
                aAdd(aFilDHY,AllTrim(aReadId[nI,1]))
            Endif

            nPos := aScan(aTpXDHY,{|x| AllTrim(x) == AllTrim(aReadId[nI,2])})
            If nPos == 0
                aAdd(aTpXDHY,AllTrim(aReadId[nI,2]))
            Endif

            nPos := aScan(aIdDHY,{|x| AllTrim(x) == AllTrim(aReadId[nI,3])})
            If nPos == 0
                aAdd(aIdDHY,AllTrim(aReadId[nI,3]))
            Endif
        Next nI
    Endif

    Self:LogMessage("","Backup DHY / DHZ")
    If Self:lDHZ .And. Self:lHistDHY
        cAliTmp := GetNextAlias()

        oUpdDHZ := FWPreparedStatement():New()

        cQry := " SELECT DHY_CODFIL, DHY_TPXML, DHY_ID, DHY_STATUS"
        If Self:lDHYFil .And. Self:lDHZFil
            cQry += " , DHY_FILTRO, DHY_DTID, DHY_TENT"
        EndIf
        If Self:lDHYDHZMes
            cQry += " , DHY_MESSAG"
        EndIf
        cQry += " DHY_FILTRO, DHY_DTID, DHY_TENT, DHY_MESSAG"
        cQry += " FROM " + RetSqlName("DHY")
        cQry += " WHERE D_E_L_E_T_ = ?"
        cQry += " AND DHY_STATUS <> ?"
        
        If Len(aReadId) > 0
            cQry += " AND DHY_CODFIL IN (?)"
            cQry += " AND DHY_TPXML IN (?)"
            cQry += " AND DHY_ID IN (?)"
        Endif

        oUpdDHZ:SetQuery(cQry)

        oUpdDHZ:SetString(nOrder++,Space(1))
        oUpdDHZ:SetString(nOrder++,'0')

        If Len(aReadId) > 0
            oUpdDHZ:SetIn(nOrder++,aFilDHY)
            oUpdDHZ:SetIn(nOrder++,aTpXDHY)
            oUpdDHZ:SetIn(nOrder++,aIdDHY)
        Endif

        cQryStat := oUpdDHZ:GetFixQuery()
        MpSysOpenQuery(cQryStat,cAliTmp)

        DbSelectArea("DHZ")
        DHZ->(DbSetOrder(1))

        While (cAliTmp)->(!EOF()) 
            If !DHZ->(DbSeek(xFilial("DHZ") + PadR((cAliTmp)->DHY_CODFIL,Self:nTamCod) + PadR((cAliTmp)->DHY_TPXML,Self:nTamTp) + PadR((cAliTmp)->DHY_ID,Self:nTamId)))
                If Self:lPerfTra
                    aRegDHZ := {} 

                    aAdd(aRegDHZ,xFilial("DHZ"))        //DHZ_FILIAL
                    aAdd(aRegDHZ,(cAliTmp)->DHY_CODFIL) //DHZ_CODFIL
                    aAdd(aRegDHZ,(cAliTmp)->DHY_TPXML)  //DHZ_TPXML
                    aAdd(aRegDHZ,(cAliTmp)->DHY_ID)     //DHZ_ID
                    aAdd(aRegDHZ,(cAliTmp)->DHY_STATUS) //DHZ_STATUS

                    If Self:lDHYFil .And. Self:lDHZFil
                        aAdd(aRegDHZ,(cAliTmp)->DHY_FILTRO)     //DHZ_FILTRO
                        aAdd(aRegDHZ,(cAliTmp)->DHY_TENT)       //DHZ_TENT
                        aAdd(aRegDHZ,StoD((cAliTmp)->DHY_DTID)) //DHZ_DTID
                        aAdd(aRegDHZ,dDataBase)                 //DHZ_DTLID
                    Endif

                    If Self:lDHYDHZMes
                        aAdd(aRegDHZ,(cAliTmp)->DHY_MESSAG)     //DHZ_MESSAG
                    Endif

                    oBulkDHZ:addData(aRegDHZ)
                Else
                    If DHZ->(RecLock("DHZ",.T.))
                        DHZ->DHZ_FILIAL := xFilial("DHZ")
                        DHZ->DHZ_CODFIL := (cAliTmp)->DHY_CODFIL
                        DHZ->DHZ_TPXML  := (cAliTmp)->DHY_TPXML
                        DHZ->DHZ_ID     := (cAliTmp)->DHY_ID
                        DHZ->DHZ_STATUS := (cAliTmp)->DHY_STATUS

                        If Self:lDHYFil .And. Self:lDHZFil
                            DHZ->DHZ_FILTRO := (cAliTmp)->DHY_FILTRO
                            DHZ->DHZ_TENT   := (cAliTmp)->DHY_TENT
                            DHZ->DHZ_DTID   := StoD((cAliTmp)->DHY_DTID)
                            DHZ->DHZ_DTLID  := dDataBase
                        Endif

                        If Self:lDHYDHZMes
                            DHZ->DHZ_MESSAG  := (cAliTmp)->DHY_MESSAG
                        Endif

                        DHZ->(MsUnlock())
                    Endif
                Endif
            Endif
            (cAliTmp)->(DbSkip())
        Enddo

        If Self:lPerfTra 
            Self:LogMessage("","Gravando DHZ (Bulk)")   
            oBulkDHZ:Close()

            Self:LogMessage("","Erro Bulk: " + oBulkDHZ:GetError())
            oBulkDHZ:Destroy()

            FreeObj(oBulkDHZ) 
        Endif

        (cAliTmp)->(DbCloseArea())  
    Endif

    If Self:lDHYFil
        Self:LogMessage("","Apaga Ids ja lidos ou com erro")
        oDelDHY := FWPreparedStatement():New()

        cQry := " DELETE FROM " + RetSqlName("DHY")
        cQry += " WHERE D_E_L_E_T_ = ?"
        cQry += " AND (DHY_STATUS <> ? OR (DHY_STATUS = ? AND DHY_DTID < ?))"

        If Len(aReadId) > 0
            cQry += " AND DHY_CODFIL IN (?)"
            cQry += " AND DHY_TPXML IN (?)"
            cQry += " AND DHY_ID IN (?)"
        Endif 

        oDelDHY:SetQuery(cQry)
        nOrder := 1   

        oDelDHY:SetString(nOrder++,Space(1))
        oDelDHY:SetString(nOrder++,'0')
        oDelDHY:SetString(nOrder++,'0')
        oDelDHY:SetString(nOrder++,DtoS(dDatabase-5))

        If Len(aReadId) > 0
            oDelDHY:SetIn(nOrder++,aFilDHY)
            oDelDHY:SetIn(nOrder++,aTpXDHY)
            oDelDHY:SetIn(nOrder++,aIdDHY)
        Endif

        cQryStat := oDelDHY:GetFixQuery()

        TcSqlExec(cQryStat)
    Endif

    FreeObj(oUpdDHZ)
    FreeObj(oDelDHY)
    FwFreeArray(aFilDHY)
    FwFreeArray(aTpXDHY)
    FwFreeArray(aIdDHY)
    FwFreeArray(aFieldDHZ)
    FwFreeArray(aRegDHZ)

Return

/*/{Protheus.doc} UpdStatus
	Atualiza status Transmite

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method UpdStatus() Class COMTransmite

Local cQry          := ""
Local cQryStat      := ""
Local cAliTmp       := ""
Local aDoc          := {}
Local cChvXML       := ""
Local cDocXML       := ""
Local cSerXML       := ""
Local cNomXML       := ""
Local oAStaInteg    := Nil
Local oAStaExpor    := Nil
Local oAtuChvDoc    := Nil
Local aCKODados     := {}
Local aCKOFlag      := {}
Local aCKOSTran     := {}
Local lCkoChvDoc    := Self:lCkoRepro .And. Self:lCkoTra
Local aEdiCOM       := {}
Local nParam        := 0
Local nTamChv       := Len(CKO->CKO_CHVDOC)

If "NFE" $ Self:cMVDOCIMP
    aAdd(aEdiCOM,"109")
Endif

If "NFS" $ Self:cMVDOCIMP
    aAdd(aEdiCOM,"319")
Endif

If "CTE" $ Self:cMVDOCIMP
    aAdd(aEdiCOM,"214")
Endif

If "CTO" $ Self:cMVDOCIMP
    aAdd(aEdiCOM,"273")  
Endif

//Atualizar documento sem chave documento
If lCkoChvDoc
    aCKOFlag    := {"0","1","2"}
    nParam      := 1
    cAliTmp     := GetNextAlias()
    oAtuChvDoc  := FWPreparedStatement():New()

    cQry := " SELECT R_E_C_N_O_ RECNO, CKO_STRAN, CKO_ARQUIV "
    cQry += " FROM " + RetSqlName("CKO") + " CKO "
    cQry += " WHERE D_E_L_E_T_ = ?"
    cQry += " AND CKO_CHVDOC = ?"
    cQry += " AND CKO_FLAG IN (?)"
    
    If !Empty(Self:dDataIni)
        cQry += " AND CKO_DT_IMP >= ?"
    Endif
    
    If Len(aEdiCOM) > 0
        cQry += " AND CKO_CODEDI in (?)"
    Endif

    cQry := ChangeQuery(cQry)

    oAtuChvDoc:SetQuery(cQry)

    oAtuChvDoc:SetString(nParam++,Space(1))
    oAtuChvDoc:SetString(nParam++,Space(nTamChv))
    oAtuChvDoc:SetIn(nParam++,aCKOFlag)

    If !Empty(Self:dDataIni)
        oAtuChvDoc:SetString(nParam++,DtoS(Self:dDataIni))
    Endif

    If Len(aEdiCOM) > 0
        oAtuChvDoc:SetIn(nParam++,aEdiCOM)
    Endif

    cQryStat := oAtuChvDoc:GetFixQuery()
    MpSysOpenQuery(cQryStat,cAliTmp)

    CKO->(DbSetOrder(1))
    While (cAliTmp)->(!EOF())
        If CKO->(dbSeek((cAliTmp)->CKO_ARQUIV))
            aCKODados := Self:GetDadosXML(CKO->CKO_XMLRET)
            If Len(aCKODados) > 0
                cChvXML	:= aCKODados[1]
                cDocXML	:= aCKODados[2]
                cSerXML	:= aCKODados[3]
                cNomXML	:= aCKODados[4]
            Endif

            If !Empty(cChvXML) .Or. !Empty(cDocXML)
                If RecLock("CKO",.F.)
                    CKO->CKO_CHVDOC := cChvXML
                    CKO->CKO_DOC    := cDocXML
                    CKO->CKO_SERIE  := cSerXML
                    CKO->CKO_NOMFOR := cNomXML
                    If Empty((cAliTmp)->CKO_STRAN)
                        CKO->CKO_STRAN  := "1"
                    Endif
                    CKO->(MsUnlock())
                Endif
            Endif
        Endif
        (cAliTmp)->(DbSkip())
    Enddo

    (cAliTmp)->(dbCloseArea())

    oAtuChvDoc:Destroy()
    FreeObj(oAtuChvDoc)

Endif

//Atualização para status (Pendente = 1 para Exportada = 2)
Self:UpdDocStatus(1)

//Atualização para status (Exportada = 2 para Integrada = 3)  Pré-Nota
nParam      := 1
cAliTmp     := GetNextAlias() 
oAStaInteg  := FWPreparedStatement():New()

cQry := " SELECT CKO.CKO_ARQUIV, CKO.R_E_C_N_O_ RECNO FROM " + RetSqlName("CKO") + " CKO"

cQry += " JOIN " + RetSqlName("SDS") + " SDS" 
cQry += " ON  SDS.DS_ARQUIVO = CKO.CKO_ARQUIV " 
cQry += " AND SDS.DS_STATUS  = ? " 
cQry += " AND SDS.D_E_L_E_T_ = ? " 

cQry += " JOIN " + RetSqlName("SF1") + " SF1" 
cQry += " ON  SF1.F1_DOC     = SDS.DS_DOC " 
cQry += " AND SF1.F1_SERIE   = SDS.DS_SERIE " 
cQry += " AND SF1.F1_FORNECE = SDS.DS_FORNEC" 
cQry += " AND SF1.F1_LOJA    = SDS.DS_LOJA" 
cQry += " AND SF1.F1_FORNECE = SDS.DS_FORNEC" 
cQry += " AND SF1.F1_STATUS  = ?"   //Pré-Nota
cQry += " AND SF1.D_E_L_E_T_ = ?" 

cQry += " WHERE CKO.D_E_L_E_T_ = ?"
cQry += " AND CKO.CKO_CHVDOC <> ?"
cQry += " AND CKO_STRAN <> ?"

If !Empty(Self:dDataIni)
    cQry += " AND CKO_DT_IMP >= ?"
Endif

If Len(aEdiCOM) > 0
    cQry += " AND CKO_CODEDI in (?)"
Endif

cQry := ChangeQuery(cQry)

oAStaInteg:SetQuery(cQry)

oAStaInteg:SetString(nParam++,"P")
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(nTamChv))
oAStaInteg:SetString(nParam++,"3")

If !Empty(Self:dDataIni)
    oAStaInteg:SetString(nParam++,DtoS(Self:dDataIni))
Endif

If Len(aEdiCOM) > 0
    oAStaInteg:SetIn(nParam++,aEdiCOM)
Endif

cQryStat := oAStaInteg:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliTmp)

While (cAliTmp)->(!EOF())
    aAdd(aDoc,(cAliTmp)->CKO_ARQUIV)
    If CKO->(dbSeek((cAliTmp)->CKO_ARQUIV))
        If RecLock("CKO",.F.)
            CKO->CKO_STRAN  := "2"
            CKO->(MsUnlock())
        Endif
    Endif
    (cAliTmp)->(DbSkip())
Enddo

(cAliTmp)->(DbCloseArea())
oAStaInteg:Destroy()
FreeObj(oAStaInteg)

If Len(aDoc) > 0
    Self:UpdDocStatus(2,aDoc)
Endif

//Atualização para status (Exportada = 2 para Classificada = 4)  Documento classificado
nParam      := 1
cAliTmp     := GetNextAlias()
oAStaInteg  := FWPreparedStatement():New()
aDoc        := {}

cQry := " SELECT CKO.CKO_ARQUIV, CKO.R_E_C_N_O_ RECNO FROM " + RetSqlName("CKO") + " CKO"

cQry += " JOIN " + RetSqlName("SDS") + " SDS" 
cQry += " ON  SDS.DS_ARQUIVO = CKO.CKO_ARQUIV " 
cQry += " AND SDS.DS_STATUS  = ? " 
cQry += " AND SDS.D_E_L_E_T_ = ? " 
cQry += " JOIN " + RetSqlName("SF1") + " SF1" 
cQry += " ON  SF1.F1_DOC     = SDS.DS_DOC " 
cQry += " AND SF1.F1_SERIE   = SDS.DS_SERIE " 
cQry += " AND SF1.F1_FORNECE = SDS.DS_FORNEC" 
cQry += " AND SF1.F1_LOJA    = SDS.DS_LOJA" 
cQry += " AND SF1.F1_FORNECE = SDS.DS_FORNEC" 
cQry += " AND (SF1.F1_STATUS  = ? OR (SF1.F1_STATUS  = ? AND EXISTS ( SELECT 1 FROM " + RetSqlName("SD1") + " SD1"  //Documento Classificado
cQry +=                                                               " WHERE SD1.D1_FILIAL  = SF1.F1_FILIAL"       //Documento Classificado
cQry +=                                                               "   AND SD1.D1_DOC     = SF1.F1_DOC"          //Documento Classificado
cQry +=                                                               "   AND SD1.D1_SERIE   = SF1.F1_SERIE"        //Documento Classificado
cQry +=                                                               "   AND SD1.D1_FORNECE = SF1.F1_FORNECE"      //Documento Classificado
cQry +=                                                               "   AND SD1.D1_LOJA    = SF1.F1_LOJA"         //Documento Classificado
cQry +=                                                               "   AND SD1.D1_TES    <> ?"                   //Documento Classificado
cQry +=                                                               "   AND SD1.D_E_L_E_T_ = ? )))"               //Documento Classificado
cQry += " AND SF1.D_E_L_E_T_ = ?" 
cQry += " WHERE CKO.D_E_L_E_T_ = ?"
cQry += " AND CKO.CKO_CHVDOC <> ?"
cQry += " AND CKO_STRAN <> ?"

If !Empty(Self:dDataIni)
    cQry += " AND CKO_DT_IMP >= ?"
Endif

If Len(aEdiCOM) > 0
    cQry += " AND CKO_CODEDI in (?)"
Endif

cQry := ChangeQuery(cQry)

oAStaInteg:SetQuery(cQry)

oAStaInteg:SetString(nParam++,"P")
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,"A")
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(Len(SD1->D1_TES)))
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(1))
oAStaInteg:SetString(nParam++,Space(nTamChv))
oAStaInteg:SetString(nParam++,"4")

If !Empty(Self:dDataIni)
    oAStaInteg:SetString(nParam++,DtoS(Self:dDataIni))
Endif

If Len(aEdiCOM) > 0
    oAStaInteg:SetIn(nParam++,aEdiCOM)
Endif

cQryStat := oAStaInteg:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliTmp)

While (cAliTmp)->(!EOF())
    aAdd(aDoc,(cAliTmp)->CKO_ARQUIV)
    If CKO->(dbSeek((cAliTmp)->CKO_ARQUIV))
        If RecLock("CKO",.F.)
            CKO->CKO_STRAN  := "4"
            CKO->(MsUnlock())
        Endif
    Endif
    (cAliTmp)->(DbSkip())
Enddo

(cAliTmp)->(DbCloseArea())
oAStaInteg:Destroy()
FreeObj(oAStaInteg)

If Len(aDoc) > 0
    Self:UpdDocStatus(4,aDoc)
Endif

//Atualização para status (Integrada = 3 para Exportada = 2 ou classificada = 4 para Exportada = 2), documento que foram excluidos da SF1 ou SDS e não retornou status
nParam      := 1
aCKOSTran   := {"3","4"}
cAliTmp     := GetNextAlias()
oAStaExpor  := FWPreparedStatement():New()
aDoc        := {}

cQry := " SELECT CKO.CKO_ARQUIV, (CASE WHEN SDS.DS_ARQUIVO IS NULL THEN 0 ELSE 1 END) DS_EXISTE, SDS.DS_STATUS FROM " + RetSqlName("CKO") + " CKO"
cQry += " LEFT JOIN " + RetSqlName("SDS") + " SDS" 
cQry += " ON  SDS.DS_ARQUIVO = CKO.CKO_ARQUIV"
cQry += " AND SDS.D_E_L_E_T_ = ?" 
cQry += " WHERE CKO.D_E_L_E_T_ = ?"
cQry += " AND CKO.CKO_CHVDOC <> ?"
cQry += " AND CKO.CKO_ARQUIV <> ?"
cQry += " AND CKO.CKO_STRAN in (?)"

If !Empty(Self:dDataIni)
    cQry += " AND CKO_DT_IMP >= ?"
Endif

If Len(aEdiCOM) > 0
    cQry += " AND CKO_CODEDI in (?)"
Endif

cQry += " AND CKO.CKO_EMPPRO = ?"

oAStaExpor:SetQuery(cQry)

oAStaExpor:SetString(nParam++,Space(1))
oAStaExpor:SetString(nParam++,Space(1))
oAStaExpor:SetString(nParam++,Space(nTamChv))
oAStaExpor:SetString(nParam++,Space(Len(CKO->CKO_ARQUIV)))
oAStaExpor:SetIn(nParam++,aCKOSTran)

If !Empty(Self:dDataIni)
    oAStaExpor:SetString(nParam++,DtoS(Self:dDataIni))
Endif

If Len(aEdiCOM) > 0
    oAStaExpor:SetIn(nParam++,aEdiCOM)
Endif

oAStaExpor:SetString(nParam++,cEmpAnt)

cQryStat := oAStaExpor:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliTmp)

While (cAliTmp)->(!EOF())
    If (cAliTmp)->DS_EXISTE == 0 .Or. (cAliTmp)->DS_STATUS <> "P"
        aAdd(aDoc,(cAliTmp)->CKO_ARQUIV)

        If CKO->(dbSeek((cAliTmp)->CKO_ARQUIV)) .And. CKO->CKO_STRAN == "4"
            If RecLock("CKO",.F.)
                CKO->CKO_STRAN  := "3"
                CKO->(MsUnlock())
            Endif
        Endif
    EndIf
    (cAliTmp)->(DbSkip())
Enddo

(cAliTmp)->(DbCloseArea())
oAStaExpor:Destroy()
FreeObj(oAStaExpor)

If Len(aDoc) > 0
    Self:UpdDocStatus(3,aDoc)
Endif

FwFreeArray(aDoc)
FwFreeArray(aCKODados)
FwFreeArray(aCKOSTran)
FwFreeArray(aCKOFlag)
FwFreeArray(aEdiCOM)

Return

/*/{Protheus.doc} UpdDocStatus
	Informa transmite que documento foi importado

@param  nOpc 1-CKO / 2-DOC (F1/D1)
@param  aDoc Documentos a serem atualizados

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method UpdDocStatus(nOpc,aDoc) Class COMTransmite

    Local cJsonUpd  := ""
    Local cJsonIni  := ""
    Local cJsonFim  := ""
    Local cJsonNFE  := ""
    Local cJsonNFS  := ""
    Local cJsonCTE  := ""
    Local aAux      := {}
    Local aDocRead  := {}
    Local aJsonDoc  := {}
    Local aTpDoc    := {}
    Local nI        := 0
    Local nX        := 0
    Local nDefDocs  := Self:nDocReq
    Local nDocs     := 0
    Local nTotDoc   := 0
    Local nCountDoc := 0
    Local nPosDoc	:= 0
    Local nQtdDocs  := 0

    If "NFE" $ Self:cMVDOCIMP
        aAdd(aTpDoc,"NFE")
    Endif
    If "NFS" $ Self:cMVDOCIMP
        aAdd(aTpDoc,"NFS")
    Endif
    If "CTE" $ Self:cMVDOCIMP
        aAdd(aTpDoc,"CTE")
    Endif
    If "CTO" $ Self:cMVDOCIMP
        aAdd(aTpDoc,"CTO")
    Endif
    
    If Self:lCkoTra 
        Self:LogMessage("","Busca documentos a serem atualizados no Transmite")

        If nOpc == 1
            Self:GetDocUpdTra(nOpc,@aDocRead)
            nQtdDocs := Len(aDocRead)
        Elseif nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 4
            If Len(aDoc) > 0
                nQtdDocs := Len(aDoc)
                nTotDoc := Len(aDoc)

                While nTotDoc > 0
                    nDocs := If(nTotDoc < nDefDocs, nTotDoc, nDefDocs)
                
                    For nI := 1 To nDocs
                        aAdd(aAux,aDoc[nCountDoc+nI]) 
                        nPosDoc += 1
                    Next nI
                    Self:GetDocUpdTra(nOpc,@aDocRead,aAux)
                    nCountDoc += nPosDoc
                    nPosDoc := 0
                    nTotDoc -= nDocs
                    aAux := {}
                Enddo
            Endif
        Endif  

        Self:LogMessage("","Atualizando Status integracao [" + Iif(nOpc == 1 .Or. nOpc == 3,"Exportada",Iif(nOpc == 4,"Classificada","Integrada")) + "] no Transmite de: " + Alltrim(Str(nQtdDocs)) + " documentos NFe/NFs/CTe/CTeOS")
        If Len(aDocRead) > 0
            For nI := 1 To Len(aTpDoc)
                aAux := {}

                For nX := 1 To Len(aDocRead)
                    If aDocRead[nX,1] == aTpDoc[nI]
                        aAdd(aAux,aDocRead[nX])
                    Endif
                Next nX

                If Len(aAux) > 0
                    nCountDoc   := 0
                    nQtdDocs    := Len(aAux)
                    nTotDoc     := Len(aAux)

                    cJsonIni := '{'
                    If nOpc == 1 .Or. nOpc == 3
                        cJsonIni += '"StatusIntegracao":"Exportada",'
                    Elseif nOpc == 2
                        cJsonIni += '"StatusIntegracao":"Integrada",'
                    Elseif nOpc == 4
                        cJsonIni += '"StatusIntegracao":"Classificada",'                        
                    Endif

                    If aAux[1,1] == "NFE"
                        cJsonIni += '"documentos": ['
                    ElseIf aAux[1,1] == "NFS"
                        cJsonIni += '"chavesNfse": ['
                    ElseIf aAux[1,1] $ "CTE|CTO"
                        cJsonIni += '"chavesCte": ['
                    Endif

                    cJsonFim := ']'
                    If aAux[1,1] == "NFE"
                        cJsonFim += ', "ator": "Destinatario"'
                    Endif
                    cJsonFim += '}'

                    While nTotDoc > 0
                        nDocs := If(nTotDoc < nDefDocs, nTotDoc, nDefDocs)
                        
                        cJsonNFE  := ""
                        cJsonNFS  := ""
                        cJsonCTE  := ""
                        aJsonDoc  := {}

                        For nX := 1 To nDocs
                            If aAux[nCountDoc+nX,1] == "NFE" 
                                If !Empty(cJsonNFE)
                                    cJsonNFE += ','
                                Endif
                                cJsonNFE += '{'
                                cJsonNFE += '"Chave":"' + AllTrim(aAux[nCountDoc+nX,2]) + '",'
                                cJsonNFE += '"DataLancamentoERP":"' + iif(nOpc == 4,AllTrim(aAux[nCountDoc+nX,3]),"") + '"'
                                cJsonNFE += '}'

                                aAdd(aJsonDoc,AllTrim(aAux[nCountDoc+nX,2]))
                                nPosDoc += 1
                            ElseIf aAux[nCountDoc+nX,1] == "NFS"
                                If !Empty(cJsonNFS)
                                    cJsonNFS += ','
                                Endif
                                cJsonNFS += '{'
                                cJsonNFS += '"DataEmissao":"' + aAux[nCountDoc+nX,2] + '",'
                                cJsonNFS += '"Nfse":"' + AllTrim(aAux[nCountDoc+nX,3]) + '",'
                                cJsonNFS += '"CnpjCpfPrestador":"' + aAux[nCountDoc+nX,4] + '"'
                                cJsonNFS += '}'

                                aAdd(aJsonDoc,AllTrim(aAux[nCountDoc+nX,2]+"|"+aAux[nCountDoc+nX,4]+"|"+aAux[nCountDoc+nX,3]))
                                nPosDoc += 1
                            ElseIf aAux[nCountDoc+nX,1] == "CTE" .Or. aAux[nCountDoc+nX,1] == "CTO"
                                If !Empty(cJsonCTE)
                                    cJsonCTE += ','
                                Endif
                                cJsonCTE += '"' + AllTrim(aAux[nCountDoc+nX,2]) + '"'
                                aAdd(aJsonDoc,AllTrim(aAux[nCountDoc+nX,2]))
                                nPosDoc += 1
                            Endif

                        Next nX

                        If aAux[1,1] == "NFE"
                            cJsonUpd := cJsonIni + cJsonNFE + cJsonFim
                        ElseIf aAux[1,1] == "NFS"
                            cJsonUpd := cJsonIni + cJsonNFS + cJsonFim
                        ElseIf aAux[1,1] $ "CTE|CTO"
                            cJsonUpd := cJsonIni + cJsonCTE + cJsonFim
                        Endif

                        Self:PostStatus(cJsonUpd,aAux[1,1],nOpc,aJsonDoc)
                                            
                        nCountDoc += nPosDoc
                        nPosDoc := 0
                        nTotDoc -= nDocs
                    Enddo
                Endif
            Next nI
        Endif
    Endif

    FwFreeArray(aDocRead)
    FwFreeArray(aAux)
    FwFreeArray(aJsonDoc)
    FwFreeArray(aTpDoc)

Return

/*/{Protheus.doc} GetDocUpdTra
QUery para filtrar documentos a serem atualizados

@param  cTpXML     Tipo XML
@param  cResource  String requisição
    
@author rodrigo.mpontes
@since 14/01/2022
/*/

Method GetDocUpdTra(nOpc,aDocRead,aDoc) Class COMTransmite

Local cAliasImp := GetNextAlias()
Local oQryDoc   := Nil
Local cQryStat  := ""
Local aAux      := {}
Local aEdiCOM   := {}
Local nParam1   := 0
Local nParam2   := 0
Local nParam3   := 0

Default aDoc    := {}

If "NFE" $ Self:cMVDOCIMP
	aAdd(aEdiCOM,"109")
Endif
If "NFS" $ Self:cMVDOCIMP
	aAdd(aEdiCOM,"319")
Endif
If "CTE" $ Self:cMVDOCIMP
	aAdd(aEdiCOM,"214")
Endif
If "CTO" $ Self:cMVDOCIMP
	aAdd(aEdiCOM,"273")
Endif

oQryDoc := FWPreparedStatement():New()  

cQry := " SELECT CKO_CHVDOC, CKO_CODEDI, CKO_EMPPRO,CKO_FILPRO, CKO_STRAN, CKO_DT_IMP, R_E_C_N_O_ RECNO"
cQry += " FROM " + RetSqlName("CKO")
cQry += " WHERE CKO_CHVDOC <> ' '"
cQry += " AND CKO_STRAN = ?"
cQry += " AND D_E_L_E_T_ = ' '"

If Len(aDoc) > 0
    cQry += " AND CKO_ARQUIV IN (?)"
    nParam1 := 2
Endif

If Len(aEdiCOM) > 0
    cQry += " AND CKO_CODEDI IN (?)"
    If nParam1 == 2
        nParam2 := 3
    Else
        nParam2 := 2
    Endif
Endif

If !Empty(Self:dDataIni)
    cQry += " AND CKO_DT_IMP >= ?"
    If nParam2 == 2
        nParam3 := 3
    Elseif nParam2 == 3
        nParam3 := 4
    Endif
Endif

cQry += " ORDER BY CKO_DT_IMP DESC"

oQryDoc:SetQuery(cQry)
oQryDoc:SetString(1,AllTrim(Str(nOpc)))

If Len(aDoc) > 0
    oQryDoc:SetIn(nParam1,aDoc)
Endif

If Len(aEdiCOM) > 0
    oQryDoc:SetIn(nParam2,aEdiCOM) 
Endif

If !Empty(Self:dDataIni)
    oQryDoc:SetString(nParam3,DtoS(Self:dDataIni)) 
Endif

cQryStat := oQryDoc:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

While (cAliasImp)->(!EOF())
    CKO->(DbGoto((cAliasImp)->RECNO))

    If "|" $ (cAliasImp)->CKO_CHVDOC
        aAux := Separa((cAliasImp)->CKO_CHVDOC,"|")
    Endif

    If Len(aAux) > 0
        If Self:lCpoNewDoc .And. Len(AllTrim(CKO->CKO_NFELET)) > Self:nTamMaxDoc
            aAdd(aDocRead,{"NFS",aAux[1],AllTrim(CKO->CKO_NFELET),aAux[2]}) //NFS
            Self:LogMessage(,"GetDocUpdTra:NFS:CHAVE|DT|RECNO " + aAux[1]+"|"+AllTrim(CKO->CKO_NFELET)+"|"+aAux[2]+"|"+DtoC(StoD((cAliasImp)->CKO_DT_IMP))+"|"+AllTrim(Str((cAliasImp)->RECNO)))
        Else
            aAdd(aDocRead,{"NFS",aAux[1],aAux[3],aAux[2]}) //NFS
            Self:LogMessage(,"GetDocUpdTra:NFS:CHAVE|DT|RECNO " + aAux[1]+"|"+aAux[3]+"|"+aAux[2]+"|"+DtoC(StoD((cAliasImp)->CKO_DT_IMP))+"|"+AllTrim(Str((cAliasImp)->RECNO)))
        Endif
    Else
        If (cAliasImp)->CKO_CODEDI == "109" //NFE
              aAdd(aDocRead,{"NFE",;
                         (cAliasImp)->CKO_CHVDOC,;
                         GetDataLanc((cAliasImp)->CKO_CHVDOC,(cAliasImp)->CKO_FILPRO),;
                         GetCodFil((cAliasImp)->CKO_EMPPRO,(cAliasImp)->CKO_FILPRO)})

            Self:LogMessage(,"GetDocUpdTra:NFE:CHAVE|DT|RECNO " + (cAliasImp)->CKO_CHVDOC+"|"+GetCodFil((cAliasImp)->CKO_EMPPRO,(cAliasImp)->CKO_FILPRO)+"|"+DtoC(StoD((cAliasImp)->CKO_DT_IMP))+"|"+AllTrim(Str((cAliasImp)->RECNO)))
        ElseIf (cAliasImp)->CKO_CODEDI == "214" //CTE
            aAdd(aDocRead,{"CTE",(cAliasImp)->CKO_CHVDOC})
            Self:LogMessage(,"GetDocUpdTra:CTE:CHAVE|DT|RECNO " + (cAliasImp)->CKO_CHVDOC+"|"+DtoC(StoD((cAliasImp)->CKO_DT_IMP))+"|"+AllTrim(Str((cAliasImp)->RECNO)))
        ElseIf (cAliasImp)->CKO_CODEDI == "273" //CTEOS
            aAdd(aDocRead,{"CTO",(cAliasImp)->CKO_CHVDOC})
            Self:LogMessage(,"GetDocUpdTra:CTO:CHAVE|DT|RECNO " + (cAliasImp)->CKO_CHVDOC+"|"+DtoC(StoD((cAliasImp)->CKO_DT_IMP))+"|"+AllTrim(Str((cAliasImp)->RECNO)))
        Endif
    Endif
    aAux := {}
    (cAliasImp)->(DbSkip())
Enddo

(cAliasImp)->(DbCloseArea())

//-- Limpa objetos da memória
oQryDoc:Destroy()
FreeObj(oQryDoc)

FwFreeArray(aAux)
FwFreeArray(aEdiCOM)

Return

/*/{Protheus.doc} PostStatus
	Post no Transmite com documentos

@param  cJsonBody   Body com documentos a serem atualizados
@param  cTpXML      Tipo XML (NFE/NFS/CTE/CTEOS)
@param  nOpc        1-CKO / 2-DOC (F1/D1) / 3-F1 volta CKO
@param  aJsonDoc    Os documentos a serem atualizados CKO

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method PostStatus(cJsonBody,cTpXML,nOpc,aJsonDoc) Class COMTransmite

    Local cResource := ""
    Local cTextJson := ""
    Local cAliasImp := ""
    Local cQryStat  := ""
    Local cQry      := ""
    Local cMessage  := ""
    Local oRestPost := Nil
    Local oJsonResp := Nil
    Local aArea     := {}
    Local xMessage  := Nil
    
    If cTpXML == "NFE"
        cResource   := Self:cApiSetExpNFE
    Elseif cTpXML == "NFS"
        cResource   := Self:cApiSetExpNFS
    Elseif cTpXML == "CTE"
        cResource   := Self:cApiSetExpCTE 
    Elseif cTpXML == "CTO"
        cResource   := Self:cApiSetExpCTO
    Endif

    cAliasImp := GetNextAlias()

    Self:LogMessage("","PostStatus:cJsonBody: " + cJsonBody)
    Self:LogMessage("","PostStatus:nOpc: " + AllTrim(Str(nOpc))) 

    If oFind2CKO == nil 
        oFind2CKO := FWPreparedStatement():New()

        cQry := " SELECT CKO_ARQUIV, R_E_C_N_O_ RECNO, CKO_CHVDOC"
        cQry += " FROM " + RetSqlName("CKO")
        cQry += " WHERE CKO_CHVDOC IN (?)"
        cQry += " AND D_E_L_E_T_ = ?"
        cQry := ChangeQuery(cQry)

        oFind2CKO:SetQuery(cQry) 
    EndIf 
    oFind2CKO:SetIn(1,aJsonDoc) 
    oFind2CKO:SetString(2,Space(1))

    cQryStat := oFind2CKO:GetFixQuery() 
    MpSysOpenQuery(cQryStat,cAliasImp)

    Self:LogMessage("PostStatus:Query: " + cQryStat,"")

    aArea := GetArea()

    If (cAliasImp)->(!EOF())
        
        oRestPost := FwRest():New(Self:cApiTra) 
        oRestPost:SetPath(cResource)
        oRestPost:SetPostParams(cJsonBody)
        oRestPost:Post(Self:aHeaderOut)

        oJsonResp := JsonObject():New() 
        cTextJson := oRestPost:GetResult()
        oJsonResp:FromJson(cTextJson)

        xMessage  := oJsonResp:GetJsonObject("message")
        cMessage  := Iif(ValType(xMessage) == "C",xMessage,oRestPost:oResponseH:cStatusCode + " - " + oRestPost:oResponseH:cReason)

        Self:LogMessage("","oRestPost:Post:T:cMessage: " + cMessage )
        Self:LogMessage("PostStatus:Post:T:GetResult: " + Iif(ValType(cTextJson) == "C",cTextJson,""),"")

        If oRestPost:GetHTTPCode() == "200" 
            While (cAliasImp)->(!EOF())
                If CKO->(DbSeek((cAliasImp)->CKO_ARQUIV))
                    If RecLock("CKO",.F.)
                        CKO->CKO_STRAN := Iif(nOpc==1 .Or. nOpc == 3,"2",Iif(nOpc==4,"4","3"))
                        If Self:lCkoTra
                            CKO->CKO_ERRTRA := ""
                        Endif
                        CKO->(MsUnlock())
                        Self:LogMessage(,"Documento atualizado no Transmite e Compras: " + CKO->CKO_ARQUIV + "|" + CKO->CKO_CHVDOC + "|" + AllTrim(Str((cAliasImp)->RECNO)))
                    Endif
                Endif
                (cAliasImp)->(DbSkip())
            Enddo
        ElseIf oRestPost:GetHTTPCode() == "206" 
            If ValType(oJsonResp["documentosAtualizados"]) == 'A'
                Self:UpdDocCKO(oJsonResp["documentosAtualizados"],"A",cTpXML,nOpc)
            Endif

            If ValType(oJsonResp["documentosNaoAtualizados"]) == 'A'
                Self:UpdDocCKO(oJsonResp["documentosNaoAtualizados"],"N",cTpXML,nOpc)
            Endif
        Else
            Self:cLastError := oRestPost:GetLastError()
            Self:lAPIError := .T. 

            If Self:lCkoTra
                While (cAliasImp)->(!EOF())
                    If CKO->(DbSeek((cAliasImp)->CKO_ARQUIV))
                        Self:LogMessage("Atualizando:CKO_ERRTRA","oRestPost:Post:T:CKO:Doc|Serie|Recno: " + CKO->CKO_DOC + "|" + CKO->CKO_SERIE + "|" + AllTrim(Str((cAliasImp)->RECNO)))

                        If RecLock("CKO",.F.)
                            CKO->CKO_ERRTRA := cMessage
                        Endif
                        CKO->(MsUnlock())
                    Endif
                    (cAliasImp)->(DbSkip())
                Enddo
            Endif

            Self:LogMessage(cTextJson, oRestPost:GetLastError())
        Endif
    Endif

    (cAliasImp)->(DbCloseArea())
    
    RestArea(aArea)

    //-- Limpa objetos da memória
    If oRestPost <> Nil
        FreeObj(oRestPost)
    EndIf
    If oJsonResp <> Nil
        FreeObj(oJsonResp)
    EndIf
    
    FwFreeArray(aArea)
    FwFreeArray(aJsonDoc)

Return

/*/{Protheus.doc} UpdDocCKO
	Atualiza status CKO

@author rodrigo.mpontes
@since 14/01/2022
/*/

Method UpdDocCKO(aDocs,cOpc,cTpXML,nOpc) Class COMTransmite

    Local nI        := 0 
    Local cChvDoc   := ""
    Local cAliChv   := ""
    Local cQryStat  := ""
    Local cQry      := ""

    CKO->(DbSetOrder(1))

    For nI := 1 To Len(aDocs)
        If cTpXML $ "NFE|CTE|CTO"
            cChvDoc := aDocs[nI]["chave"]
        Else
            cChvDoc := SubStr(aDocs[nI]["dataEmissao"]+"|"+aDocs[nI]["cnpjCpfPrestador"]+"|"+aDocs[nI]["nfse"],1,Self:nTamChv)
        Endif
        Self:LogMessage("COMTRANSMITE:UpdDocCKO:cChvDoc",cChvDoc) 

        cAliChv := GetNextAlias()

        If oChave == nil
            oChave := FWPreparedStatement():New()

            cQry := " SELECT CKO_ARQUIV"
            cQry += " FROM " + RetSqlName("CKO")
            cQry += " WHERE CKO_CHVDOC = ?"
            cQry += " AND D_E_L_E_T_ = ?"
            cQry := ChangeQuery(cQry)

            oChave:SetQuery(cQry) 
        Endif

        oChave:SetString(1,cChvDoc)
        oChave:SetString(2,Space(1))
        
        cQryStat := oChave:GetFixQuery()
        MpSysOpenQuery(cQryStat,cAliChv)
        Self:LogMessage("COMTRANSMITE:UpdDocCKO:cQryStat",cQryStat)

        If (cAliChv)->(!EOF())
            If CKO->(DbSeek((cAliChv)->CKO_ARQUIV))
                If RecLock("CKO",.F.)
                    If cOpc == "A"
                        CKO->CKO_STRAN := Iif(nOpc==1 .Or. nOpc == 3,"2",Iif(nOpc==4,"4","3"))
                        Self:LogMessage("COMTRANSMITE:UpdDocCKO:CKO_STRAN",CKO->CKO_STRAN)
                    Elseif cOpc == "N"
                        cMens   := aDocs[nI]["mensagem"]
                        CKO->CKO_ERRTRA := cMens
                        Self:LogMessage("COMTRANSMITE:UpdDocCKO:NaoAtualizado",cMens)
                    Endif
                    CKO->(MsUnlock())
                Endif
            Endif
        Endif

        (cAliChv)->(DbCloseArea())
    Next nI

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrepProcIds
Tratamento para leitura de recibo multi thread

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Method PrepProcIds(nNumProc,nTotRegs,cRaizNome) Class COMTransmite

Local aProcs 		:= Array(nNumProc)
Local nX		 	:= 0
Local cDirSem  		:= "\Semaforo\"
Local cNomeArq		:= ""
Local cMarca  		:= ""
Local nRegAProc		:= 0 // Registros a processar
Local nRegJProc		:= 0 // Total de registros já processados 
Local cVarStatus	:= ""

//Realiza o calculos das quantidades de registros que cada thread irá processar
For nX := 1 to Len(aProcs) 
	cNomeArq 	:= cDirSem + cRaizNome +cEmpAnt + cFilAnt +cValtoChar(nX) + cValtoChar(INT(Seconds())) + '.lck'
	cMarca		:= GetMark()
	nRegAProc	:= IIf( nX == 1 , 1 , aProcs[nX-1,7]+1 )
	nRegJProc	+= IIf( nX == Len(aProcs), nTotRegs-nRegJProc, Int(nTotRegs / nNumProc) )
	cVarStatus  :="cCOMTRA"+cEmpAnt+cFilAnt+StrZero(nX,2)+cMarca
	PutGlbValue(cVarStatus,"0")
	GlbUnLock()
	aProcs[nX]	:= {cNomeArq,cMarca,nRegAProc,cVarStatus,nRegAProc,nRegJProc,nRegJProc}
Next nX

Return aProcs

//-------------------------------------------------------------------
/*/{Protheus.doc} JOBCOMTRA
JOB para leitura de recibo multi thread

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Function JOBCOMTRA(cEmpX,cFilX,cMarca,cFileLck,cVarStatus,cXUserId,cXUserName,cXAcesso,cXUsuario,nCodIni,nCodFim,aIdCodFil,cToken)

Local nHandle	 := 0
Local aReadId    := {}
Local nI         := 0
Local oObjJOB    := Nil
Local cInicio    := ""
Local cFim       := ""

Default cToken   := ""

//Abre o arquivo de Lock parao controle externo das threads
nHandle := COMTraLock(cFileLck)

// STATUS 1 - Iniciando execucao do Job
PutGlbValue(cVarStatus, "1" )
GlbUnLock()

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilX,,,,"COMXCOL",) //RpcSetEnv - Abertura do ambiente em rotinas automáticas ( [ cRpcEmp ] [ cRpcFil ] [ cEnvUser ] [ cEnvPass ] [ cEnvMod ] [ cFunName ] [ aTables ] [ lShowFinal ] [ lAbend ] [ lOpenSX ] [ lConnect ]

// STATUS 2 - Conexao efetuada com sucesso
PutGlbValue(cVarStatus, "2" )
GlbUnLock() 

If lAuthToken
	totvs.framework.users.rpc.authByToken(cToken)
Else
	__cUserId := cXUserId
EndIf

cUserName := cXUserName
cAcesso   := cXAcesso
cUsuario  := cXUsuario

cInicio := Time()

//Realiza o processamento
For nI := nCodIni To nCodFim
    Aadd(aReadId,aIdCodFil[nI])
Next nI

If Len(aReadId) > 0
    oObjJOB := ComTransmite():New() 
    If oObjJOB:TokenTotvsTransmite()
        oObjJOB:nNumProc := 1
        oObjJOB:ReadRecibo(aReadId)

        oObjJOB:LogMessage("","Apaga Id/Historico") 
        oObjJOB:PutHistDHZ(aReadId)

        oObjJOB:LogMessage("","Apaga pasta com numero da Thread")
        oObjJOB:Cleanup("DELP")
        oObjJOB:Cleanup("DELL")
    Endif
    FreeObj(oObjJOB)
Endif

FwFreeArray(aReadId)

PutGlbValue(cVarStatus, "3" )  
GlbUnLock()

COMTRAUnLock(nHandle)

cFim := Time()

FWLogMsg('WARN',, 'COMTransmite', FunName(), '', '01', CRLF + ' COMTransmite:MSG:JOB: Starting: ' + cInicio, 0, 0, {})
FWLogMsg('WARN',, 'COMTransmite', FunName(), '', '01', CRLF + ' COMTransmite:MSG:JOB: Finished: ' + cFim, 0, 0, {})
FWLogMsg('WARN',, 'COMTransmite', FunName(), '', '01', CRLF + ' COMTransmite:MSG:JOB: Tempo: ' + Elaptime(cInicio,cFim), 0, 0, {})

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} COMTraLock
Lock arquivo controle multi thread

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function COMTraLock(cFile)

Local nHJob := 0

If !File(cFile)
	nHJob := FCREATE(cFile)
EndIf

Return nHJob

//-------------------------------------------------------------------
/*/{Protheus.doc} COMTRAUnLock
UnLock arquivo controle multi thread

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Static Function COMTRAUnLock(nHandle)

FWRITE(nHandle,"OK")
FCLOSE(nHandle)
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NewNFSDoc
Numero NFS quando é maior que 9 digitos

@param cDocXML      Numero do documento no XML
@param oFullXML     XML
@param cPrw         CKO-Gravação da CKO / COL-Leitura gerando SDS/SDT
@param cNameFile    Nome do arquivo sendo importado

@Return aRet        Array com informações da nova numeração do documento
                    [1] Numero Antigo (XML)
                    [2] Serie Antigo (XML)
                    [3] Novo numero DOC
                    [4] Serie (Parametro MV_SNFSNEW = TRA)
                    [5] Codigo Verificação

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Method NewNFSDoc(cDocXML,oFullXML,cPrw,cNameFile) Class COMTransmite  

Local cOldDoc		:= ""
Local cNewDoc		:= ""
Local cCodNfe       := ""
Local aRet			:= {}
Local aAux          := {}
Local oXML			:= Nil 

If Self:lCpoNewDoc .And. Len(cDocXML) > Self:nTamMaxDoc
	If cPrw == "CKO"
        If ValType(XmlChildEx(oFullXML,"_PROCTRANSMITENFSE")) == "O"
        	oXML := oFullXML:_PROCTRANSMITENFSE:_TRANSMITE:_RETTRANSMITENFSE
        Elseif ValType(XmlChildEx(oFullXML,"_PROCNEOGRIDNFSE")) == "O"
            oXML := oFullXML:_PROCNEOGRIDNFSE:_NEOGRID:_RETNEOGRIDNFSE
        Endif
	Elseif cPrw == "COL"
        If ValType(XmlChildEx(oFullXML,"_TRANSMITE")) == "O"
		    oXML := oFullXML:_TRANSMITE:_RETTRANSMITENFSE
        Elseif ValType(XmlChildEx(oFullXML,"_NEOGRID")) == "O"
            oXML := oFullXML:_NEOGRID:_RETNEOGRIDNFSE
        Endif

        aAux := GetAdvFVal("CKO",{"CKO_DOC","CKO_NFELET"},cNameFile,1)
	Endif

    If (cPRW == "CKO") .Or. ; 
        (cPRW == "COL") .And. (Empty(aAux[1]) .Or. Empty(aAux[2]))

    	cNewDoc 	:= Self:NewNumDoc()
		
		If ValType(XmlChildEx(oXML,"_NNFSE")) == "O"
			cOldDoc := oXML:_NNFSE:TEXT
		Endif
    Else
        If Len(aAux) > 0
            cNewDoc := aAux[1]
            cOldDoc := aAux[2]
        Endif
    Endif

    If ValType(XmlChildEx(oXML,"_CVERIFICANFSE")) == "O"
        cCodNfe := oXML:_CVERIFICANFSE:TEXT
    Endif

    If !Empty(cNewDoc) .And. !Empty(cOldDoc) .And. !Empty(cCodNfe)
        aAdd(aRet,cNewDoc)
        aAdd(aRet,cOldDoc)
        aAdd(aRet,cCodNFe)
    Endif
Endif

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NewNumDoc
Numero NFS (F1_DOC)

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Method NewNumDoc() Class COMTransmite

Local cNewNumDoc    := ""
Local cAliasCKO	    := GetNextAlias()
Local cAliasSF1	    := GetNextAlias()
Local cQry		    := ""
Local cQryStat      := ""
Local cNumSeq	    := ""
Local cSubQry       := "SUBSTRING" 
Local nCIniDoc      := 0
Local nFIniDoc      := 0
Local nIniDoc       := 0
Local nOrder        := 1
Local aEspNFS       := {"NFS","NFSE","NFSC","NFST"}
Local oNFSCKO       := Nil
Local oNFSSF1       := Nil

If AllTrim(Upper(TCGetDB())) $ "ORACLE" 
    cSubQry := "SUBSTR"
Endif

oNFSCKO := FWPreparedStatement():New()

cQry := " SELECT CKO_DOC"
cQry += " FROM " + RetSqlName("CKO")
cQry += " WHERE CKO_CODEDI = ?"
cQry += " AND " + cSubQry + "(CKO_DOC,1,1) = ?"
cQry += " AND CKO_NFELET <> ?"
cQry += " AND D_E_L_E_T_ = ?"
cQry += " ORDER BY CKO_DOC ASC"
oNFSCKO:SetQuery(cQry) 

oNFSCKO:SetString(nOrder++,"319")
oNFSCKO:SetString(nOrder++,"T")
oNFSCKO:SetString(nOrder++,Space(1))
oNFSCKO:SetString(nOrder++,Space(1))

cQryStat := oNFSCKO:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasCKO) 

Self:LogMessage("","NewNumDoc:Query:CKO: " + cQryStat) 
While (cAliasCKO)->(!EOF())
    cNumSeq := SubStr((cAliasCKO)->CKO_DOC,2)
    
    If Val(cNumSeq) > nCIniDoc
        nCIniDoc := Val(cNumSeq)
    Endif

    (cAliasCKO)->(DbSkip())
Enddo

(cAliasCKO)->(DbCloseArea())

Self:LogMessage("","NewNumDoc:nCIniDoc: " + AllTrim(Str(nCIniDoc)))
If nCIniDoc == 0
    nCIniDoc := 1
Else
    nCIniDoc += 1
Endif

oNFSSF1 := FWPreparedStatement():New()
nOrder := 1

cQry := " SELECT F1_DOC"
cQry += " FROM " + RetSqlName("SF1")
cQry += " WHERE " + cSubQry + "(F1_DOC,1,1) = ?"
cQry += " AND F1_ESPECIE in (?)"
cQry += " AND F1_NFELETR <> ?" 
cQry += " AND D_E_L_E_T_ = ?"
cQry += " ORDER BY F1_DOC ASC"
oNFSSF1:SetQuery(cQry) 

oNFSSF1:SetString(nOrder++,"T")
oNFSSF1:SetIn(nOrder++,aEspNFS)
oNFSSF1:SetString(nOrder++,Space(1))
oNFSSF1:SetString(nOrder++,Space(1))

cQryStat := oNFSSF1:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasSF1) 

Self:LogMessage("","NewNumDoc:Query:SF1: " + cQryStat) 
While (cAliasSF1)->(!EOF())
    cNumSeq := SubStr((cAliasSF1)->F1_DOC,2)
    
    If Val(cNumSeq) > nFIniDoc
        nFIniDoc := Val(cNumSeq)
    Endif

    (cAliasSF1)->(DbSkip())
Enddo

(cAliasSF1)->(DbCloseArea())

Self:LogMessage("","NewNumDoc:nFIniDoc: " + AllTrim(Str(nFIniDoc)))
If nFIniDoc == 0
    nFIniDoc := 1
Else
    nFIniDoc += 1
Endif

nIniDoc := Max(nCIniDoc,nFIniDoc)

cNewNumDoc := "T" + StrZero(nIniDoc,Self:nTamMaxDoc-1)
Self:LogMessage("","NewNumDoc:cNewNumDoc: " + cNewNumDoc)

Return cNewNumDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} IPToolConsult
Ferramenta de Auxilio - Consultar Recibo

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Method IPToolConsult(cRecibo,cTpXML) Class COMTransmite

Local aIPToolRet    := {}
Local aRetRecTab    := {}
Local lConsultRec   := .F.
Local cIpToolCFil   := ""
Local cApi          := ""
Local nI            := 0

//Busca recibo na DHZ
aRetRecTab := Self:IPToolRecTab("DHZ",cRecibo,cTpXML)
If aRetRecTab[1]
    aAdd(aIPToolRet,aRetRecTab[2])
    lConsultRec := .T.
    cIpToolCFil := aRetRecTab[3]
Else
    aAdd(aIPToolRet,aRetRecTab[2])

    //Busca na DHY
    aRetRecTab := Self:IPToolRecTab("DHY",cRecibo,cTpXML)
    If aRetRecTab[1]
        lConsultRec   := .T.
        cIpToolCFil := aRetRecTab[3]
    Endif
    aAdd(aIPToolRet,aRetRecTab[2])
Endif

If lConsultRec
    If "NFE" $ cTpXML
        cApi := Self:cApiUrlZipNFE
    Endif

    If "NFS" $ cTpXML
        cApi := Self:cApiUrlZipNFS
    Endif

    If "CTE" $ cTpXML
        cApi := Self:cApiUrlZipCTE
    Endif

    If "CTO" $ cTpXML
        cApi := Self:cApiUrlZipCTO
    Endif

    If !Empty(cApi)
        aRetRecTab := {}
        If Self:TokenTotvsTransmite()
            Self:ReadRecibo({{cIpToolCFil,cTpXML,cRecibo,cApi}},"IPTool",@aRetRecTab)	 
            If Len(aRetRecTab) > 0
                aAdd(aIPToolRet,CRLF)
                For nI := 1 To Len(aRetRecTab)
                    aAdd(aIPToolRet,aRetRecTab[nI])
                Next nI
            Endif
        Endif
    Endif

    If Self:lCKORecibo //Busca documentos importados na CKO
        aRetRecTab := {}
        Self:IPToolDocCKO(cRecibo,@aRetRecTab)
        If Len(aRetRecTab) > 0
            aAdd(aIPToolRet,CRLF)
            For nI := 1 To Len(aRetRecTab)
                aAdd(aIPToolRet,aRetRecTab[nI])
            Next nI
        Endif
    Endif
Endif

FwFreeArray(aRetRecTab)

Return aIPToolRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IPToolRecTab
Ferramenta de Auxilio - Consultar Recibo
Busca recibo nas tabelas DHZ e DHY

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Method IPToolRecTab(cTab,cRecibo,cTpXML) Class COMTransmite

Local cAliasImp := GetNextAlias()
Local oQryRec   := Nil
Local cQryStat  := ""
Local cCpo1		:= cTab + "_ID"
Local cCpo2		:= cTab + "_CODFIL"
Local cCpo3		:= cTab + "_TPXML"
Local cCpo4		:= cTab + "_STATUS"
Local cCpo5		:= cTab + "_FILTRO"
Local nOrder    := 1
Local cMsgRet   := ""
Local cCodFil   := ""
Local lFind     := .F.

oQryRec := FWPreparedStatement():New()  

cQry := " SELECT ?, ?, ?, ?, ?
cQry += " FROM " + RetSqlName(cTab)
cQry += " WHERE ? = ?"
cQry += " AND ? = ?"
cQry += " AND D_E_L_E_T_ = ?"

oQryRec:SetQuery(cQry)

oQryRec:SetNumeric(nOrder++,cCpo1)
oQryRec:SetNumeric(nOrder++,cCpo2)
oQryRec:SetNumeric(nOrder++,cCpo3)
oQryRec:SetNumeric(nOrder++,cCpo4)
oQryRec:SetNumeric(nOrder++,cCpo5)
oQryRec:SetNumeric(nOrder++,cCpo3)
oQryRec:SetString(nOrder++,cTpXML)
oQryRec:SetNumeric(nOrder++,cCpo1)
oQryRec:SetString(nOrder++,cRecibo)
oQryRec:SetString(nOrder++,Space(1))

cQryStat := oQryRec:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

If (cAliasImp)->(!EOF())
    lFind   := .T.
    cCodFil := (cAliasImp)->&(cCpo2)
	cMsgRet := "Recibo: " + cRecibo + " encontrado na tabela: " + cTab + CRLF + CRLF
	cMsgRet += "Tipo XML: " + (cAliasImp)->&(cCpo3) + ", CodFilial: " + (cAliasImp)->&(cCpo2) + " e Status: " + (cAliasImp)->&(cCpo4) + CRLF + CRLF
	cMsgRet += "Filtro: " + (cAliasImp)->&(cCpo5) + CRLF + CRLF
Else
	cMsgRet := "Recibo: " + cRecibo + " não encontrado na tabela: " + cTab + CRLF + CRLF
Endif

(cAliasImp)->(DbCloseArea())

FreeObj(oQryRec)

Return {lFind,cMsgRet,cCodFil}

//-------------------------------------------------------------------
/*/{Protheus.doc} IPToolDocCKO
Ferramenta de Auxilio - Retorna documentos a partir de um recibo
ou chave documento

@author	rodrigo.mpontes
@since 19/08/2023
/*/
//------------------------------------------------------------------- 

Method IPToolDocCKO(cRecibo,aRetRecTab,cChvDoc) Class COMTransmite

Local cAliasImp     := GetNextAlias()
Local oQryDocCKO   := Nil
Local cQryStat      := ""
Local nOrder        := 1
Local cMsgRet       := ""
Local nQtdDocs      := 0
Local cStatusTrans  := ""

Default cChvDoc := ""

oQryDocCKO := FWPreparedStatement():New()  

cQry := " SELECT CKO_DOC, CKO_SERIE, CKO_STRAN, CKO_CHVDOC"

If Self:lCpoNewDoc
    cQry += "    , CKO_NFELET"
Endif

cQry += " FROM " + RetSqlName("CKO")

If Empty(cChvDoc)
    cQry += " WHERE CKO_RECIBO = ?"
Else
    cQry += " WHERE CKO_CHVDOC = ?"
Endif

cQry += " AND D_E_L_E_T_ = ?"

oQryDocCKO:SetQuery(cQry)

If Empty(cChvDoc)
    oQryDocCKO:SetString(nOrder++,cRecibo)
Else
    oQryDocCKO:SetString(nOrder++,cChvDoc)
Endif
oQryDocCKO:SetString(nOrder++,Space(1))
 
cQryStat := oQryDocCKO:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasImp)

If Empty(cChvDoc)
    aAdd(aRetRecTab,"")
Endif

cMsgRet := CRLF + CRLF + "Contador | Documento | Serie | Status Transmite | Chave Documento"

If Self:lCpoNewDoc 
    cMsgRet += " | Documento Eletronico (NFSe)"
Endif

aAdd(aRetRecTab,cMsgRet + CRLF) //Cabeçalho

While (cAliasImp)->(!EOF())
    nQtdDocs++

    If (cAliasImp)->CKO_STRAN == "1"
        cStatusTrans := "Pendente"
    Elseif (cAliasImp)->CKO_STRAN == "2"
        cStatusTrans := "Exportada"
    Elseif (cAliasImp)->CKO_STRAN == "3"
        cStatusTrans := "Integrada"
    Elseif (cAliasImp)->CKO_STRAN == "4"
        cStatusTrans := "Classificada"
    Endif

    cMsgRet := StrZero(nQtdDocs,3) + " | " + PadR((cAliasImp)->CKO_DOC,Self:nTamMaxDoc) + " | " + PadR((cAliasImp)->CKO_SERIE,Self:nTamSer) + ;
               " | " + PadR(cStatusTrans,12) + " | " + PadR((cAliasImp)->CKO_CHVDOC,Self:nTamChv)
    If Self:lCpoNewDoc
        cMsgRet += " | " + PadR((cAliasImp)->CKO_NFELET,Self:nTamNFSe)
    Endif

    aAdd(aRetRecTab,CRLF + cMsgRet)
    (cAliasImp)->(DbSkip())
Enddo

(cAliasImp)->(DbCloseArea())

If nQtdDocs > 0
    If Empty(cChvDoc)
        aRetRecTab[1] := StrZero(nQtdDocs,3) + " documentos importados a partir do recibo: " + PadR(cRecibo,Self:nTamRec) 
    Endif
Else
    aRetRecTab := {} 
Endif

FreeObj(oQryDocCKO)

Return

/*/{Protheus.doc} UpdGFEStatus
	Atualiza status Transmite de documentos GFE

@author Jefferson Hita
@since 25/02/2025
/*/
Method UpdGFEStatus() Class COMTransmite
    Local nI         := 0
    Local nPos       := 0
    Local cQry       := ""
    Local cQryStat   := ""
    Local cAliTmp    := ""
    Local aDocs      := {}
    Local oAtuChvDoc := Nil
    Local aCKODados  := {}
    Local aCKOFlag   := {}
    Local aCKOSTran  := {}
    Local lCkoChvDoc := Self:lCkoRepro .And. Self:lCkoTra
    Local aEdiCOM    := {} 
    
    If lCkoChvDoc   //Atualizar documento sem chave documento
        aCKOFlag    := {"0","1","2"}
        cAliTmp     := GetNextAlias()
        oAtuChvDoc  := FWPreparedStatement():New()

        cQry := " SELECT R_E_C_N_O_ RECNO, CKO_STRAN, CKO_ARQUIV "
        cQry += " FROM " + RetSqlName("CKO") + " CKO "
        cQry += " WHERE D_E_L_E_T_ = ' '"
        cQry += " AND CKO_CODEDI = '214'"
        cQry += " AND CKO_FLAG IN (?)"

        If !Empty(Self:dDataIni)
            cQry += " AND CKO_DT_IMP >= ?"
        EndIf

        cQry := ChangeQuery(cQry)
        oAtuChvDoc:SetQuery(cQry)

        //oAtuChvDoc:SetString(1, CKO->CKO_CHVDOC)
        oAtuChvDoc:SetIn(1, aCKOFlag)
        If !Empty(Self:dDataIni)
            oAtuChvDoc:SetString(2, DtoS(Self:dDataIni))
        EndIf

        cQryStat := oAtuChvDoc:GetFixQuery()
        MpSysOpenQuery(cQryStat, cAliTmp)

        While (cAliTmp)->(!EOF())
            If CKO->(dbSeek((cAliTmp)->CKO_ARQUIV))
                aCKODados := Self:GetDadosXML(CKO->CKO_XMLRET)
                If Len(aCKODados) > 0

                    // Fazer a busca da GW3 (tem um trecho em que busca a numeração do docto no XML para a CKO - linhas +- 2100)
                    cAliasGW3 := GetNextAlias()
                    cQry := "SELECT GW3.GW3_NRDF, GW3.GW3_CTE, GW3.GW3_SITFIS, GW3.GW3_SITREC, GW3.R_E_C_N_O_ AS Recnum"
                    cQry += " FROM " + RetSqlName("GW3") + " GW3"
                    cQry += " INNER JOIN " + RetSqlName("GW4") + " GW4"
                    cQry += " ON GW4.GW4_FILIAL = GW3.GW3_FILIAL"
                    cQry += " AND GW4.GW4_EMISDF = GW3.GW3_EMISDF"
                    cQry += " AND GW4.GW4_CDESP = GW3.GW3_CDESP"
                    cQry += " AND GW4.GW4_NRDC = ?"
                    cQry += " AND GW4.GW4_SERDC = ?"
                    cQry += " AND GW4.GW4_DTEMIS = GW3.GW3_DTEMIS"
                    cQry += " AND GW4.D_E_L_E_T_ = ' '"
                    cQry += " WHERE GW3.GW3_CTE = ?"
                    cQry += " AND GW3.D_E_L_E_T_ = ' '"

                    cQry := ChangeQuery(cQry)
                    oQry := FWExecStatement():New(cQry)

                    oQry:SetString(1, aCKODados[2])
                    oQry:SetString(2, aCKODados[3])
                    oQry:SetString(3, aCKODados[1])

                    cAliasGW3 := oQry:OpenAlias()
                    If (cAliasGW3)->(!EoF()) 

                        If (cAliasGW3)->GW3_SITFIS != '4' .And. (cAliasGW3)->GW3_SITREC != '4'
                            nPos := aScan(aDocs,{|x,y| x[1] == 2})
                            If nPos > 0
                                aAdd(aDocs[nPos][2], (cAliTmp)->CKO_ARQUIV)
                            Else
                                aAdd(aDocs, {2, {(cAliTmp)->CKO_ARQUIV}})
                            EndIf
                        Else

                            // Se estiver atualizada em algum deles, então buscar SF1 pela GW3, verificar se é melhor usar chave do cte
                            cAliasSF1 := GetNextAlias()
                            cQry := "SELECT SF1.R_E_C_N_O_ AS RECNUM"
                            cQry += " FROM " + RetSqlName("SF1") + " SF1"
                            cQry += " WHERE SF1.F1_CHVNFE = ?"
                            cQry += " AND SF1.F1_DOC = ?"
                            cQry += " AND SF1.F1_STATUS = 'A'"
                            cQry += " AND SF1.D_E_L_E_T_ = ' '"

                            cQry := ChangeQuery(cQry)
                            oQry := FWExecStatement():New(cQry)

                            oQry:SetString(1, Alltrim((cAliasGW3)->GW3_CTE))
                            oQry:SetString(2, Alltrim((cAliasGW3)->GW3_NRDF))

                            cAliasSF1 := oQry:OpenAlias()

                            // Valida se NF classificada (F1_STATUS = A), retorna classificada - 4, senão 3 integrada.
                            If (cAliasSF1)->(!EoF())
                                nPos := aScan(aDocs,{|x| x[1] == 4})
                                If nPos > 0
                                    aAdd(aDocs[nPos][2], (cAliTmp)->CKO_ARQUIV)
                                Else
                                    aAdd(aDocs, {4, {(cAliTmp)->CKO_ARQUIV}})
                                EndIf
                            Else
                                nPos := aScan(aDocs,{|x| x[1] == 3})
                                If nPos > 0
                                    aAdd(aDocs[nPos][2], (cAliTmp)->CKO_ARQUIV)
                                Else
                                    aAdd(aDocs, {3, {(cAliTmp)->CKO_ARQUIV}})
                                EndIf
                            EndIf
                            (cAliasSF1)->(dbCloseArea())
                        EndIf
                    EndIf
                    (cAliasGW3)->(dbCloseArea())

                EndIf
            EndIf
            (cAliTmp)->(DbSkip())
        EndDo

        (cAliTmp)->(dbCloseArea())

        For nI := 1 To Len(aDocs)
            Self:UpdDocStatus(aDocs[nI][1], aDocs[nI][2])
        Next

        oAtuChvDoc:Destroy()
        FreeObj(oAtuChvDoc)
    EndIf
    
    FwFreeArray(aDocs)
    FwFreeArray(aCKODados)
    FwFreeArray(aCKOSTran)
    FwFreeArray(aCKOFlag)
    FwFreeArray(aEdiCOM)
Return

/*/{Protheus.doc} LogSegPlan
	Log Segundo Plano

@author Rodrigo Pontes
@since 25/02/2025
/*/
Method LogSegPlan() Class COMTransmite

Local cCLogAgend := ""

//Caminho geração do log em segundo plano
cCLogAgend := Self:cDirTransmite + "logimptratool" + Self:cBarra
    
If !ExistDir(cCLogAgend)
    MakeDir(cCLogAgend)
Endif

Return cCLogAgend

/*/{Protheus.doc} IPToolUpdStatus
	Atualiza Status - Ferramenta de Auxilio

@author Rodrigo Pontes
@since 25/02/2025
/*/
Method IPToolUpdStatus(cChvDoc) Class COMTransmite

Local cQry          := ""
Local cQryStat      := ""
Local cAliTmp       := ""
Local cMsgNoYes     := ""
Local nOrder        := 1
Local oIpToolUpdSta := Nil

cAliTmp         := GetNextAlias()
oIpToolUpdSta   := FWPreparedStatement():New()

cQry := " SELECT DS_DOC, DS_SERIE, DS_FORNEC, DS_LOJA, CKO_CHVDOC "
cQry += " FROM " + RetSqlName("SDS") + " DS"
cQry += " JOIN " + RetSqlName("CKO") + " CKO ON CKO.CKO_ARQUIV = DS.DS_ARQUIVO AND CKO.CKO_CHVDOC = ? AND CKO.D_E_L_E_T_ = ? " 
cQry += " WHERE DS.D_E_L_E_T_ = ?"

oIpToolUpdSta:SetQuery(cQry)

oIpToolUpdSta:SetString(nOrder++, cChvDoc)
oIpToolUpdSta:SetString(nOrder++, Space(1))
oIpToolUpdSta:SetString(nOrder++, Space(1))

cQryStat := oIpToolUpdSta:GetFixQuery()
MpSysOpenQuery(cQryStat, cAliTmp)

If (cAliTmp)->(!EOF())
    cMsgNoYes := "Você deseja reenviar a atualização de status para o documento: " + CRLF + ;
				 "Documento: " + AllTrim((cAliTmp)->DS_DOC) + CRLF + ; //"Documento: "
				 "Serie: " + AllTrim((cAliTmp)->DS_SERIE) + CRLF + ; //"Serie: "
				 "Fornecedor/Cliente: " + AllTrim((cAliTmp)->DS_FORNEC) + CRLF + ; //"Fornecedor: "
				 "Loja: " + AllTrim((cAliTmp)->DS_LOJA) + CRLF + ; //"Loja: "
				 "Chave: " + AllTrim((cAliTmp)->CKO_CHVDOC) + CRLF + ; //"Chave: "
				 " ?"
    If MsgYesNo(cMsgNoYes)
        Self:UpdCKOStran(cChvDoc) //Atualiza CKO_STRAN para '1' - Pendente para atualizar novamente
        Self:UpdStatus() //Atualiza Status Transmite
    Endif
Endif

(cAliTmp)->(DbCloseArea())

FreeObj(oIpToolUpdSta)

Return

/*/{Protheus.doc} UpdCKOStran
	Atualiza Status - Ferramenta de Auxilio

@author Rodrigo Pontes
@since 25/02/2025
/*/
Method UpdCKOStran(cChvDoc) Class COMTransmite

Local cUpd          := ""
Local nOrder        := 1
Local oToolStran    := FWPreparedStatement():New()

cUpd := "UPDATE " + RetSqlName("CKO") + " SET CKO_STRAN = ? WHERE CKO_CHVDOC = ? AND D_E_L_E_T_ = ? "

oToolStran:SetQuery(cUpd)

oToolStran:SetString(nOrder++,"1")
oToolStran:SetString(nOrder++,cChvDoc)
oToolStran:SetString(nOrder++,Space(1))

cUpd := oToolStran:GetFixQuery()

TcSqlExec(cUpd)

FreeObj(oToolStran)

Return

/*/{Protheus.doc} IPToolCheckChv
	Consulta status - Ferramenta de Auxilio

@author Rodrigo Pontes
@since 25/02/2025
/*/
Method IPToolCheckChv(cChvDoc) Class COMTransmite

Local aIPToolRet    := {}
Local aRetRecTab    := {}
Local nI            := 0

//Consulta chave na CKO
Self:IPToolDocCKO("",@aRetRecTab,cChvDoc)

If Len(aRetRecTab) > 0
    For nI := 1 To Len(aRetRecTab)
        aAdd(aIPToolRet,aRetRecTab[nI])
    Next nI
Endif

Return aIPToolRet

/*/{Protheus.doc} GetImpXTra
	Validar se integração com TOTVS Transmite esta ativa

@author Rodrigo Pontes
@since 25/02/2025
/*/
Method GetImpXTra() Class COMTransmite

Local lRet      := .F.

If Self:lImpXml .And. !Empty(Self:cMVXMLCID) .And. !Empty(Self:cMVXMLCSEC) .And. !Empty(Self:cMVAPITran) .And. Self:TokenTotvsTransmite()
    lRet := .T.
Endif

Return lRet

