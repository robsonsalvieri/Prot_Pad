#include "TOTVS.CH"
#include "OFCNHA07.ch"
#INCLUDE 'FILEIO.CH'

static cPathEnv := IIF(IsSrvUnix(), '/enviados/', '\enviados\')
static nRemote  := GetRemoteType() As Numeric

class OFCNHA08
    method new() constructor
    method getfiles()
    method sendfiles()
    method RetResult()
    method Connect() /*cconConnect*/
    method Login() /*cconLogin*/
    method ConnectPwd() /*cconConnectPwd*/
    method Dir() /*cconDir*/
    method Get() /*cconGet*/
    method Commit() /*cconCommit*/
    method Logout() /*cconLogout*/
    method Post() /*cconPost*/
    method FilesIn()
    method FilesOut()

    data oWSDL          
    data lOK            
    data aOperations    
    data cResp
    data cTicket
    data cServiceID
    data cMarket
    data cApplic
    data cBrand
    data cSincom
    data cCertSys
    data cLoginID
    data cUser
    data cPass
    data oConfig
    data cDirTypes
    data cFileGroup
    data cStatus
    data cDateStart
    data cDateEnd
    data cDateFormat
    data cFileInfos
    data cFileId
    data cCompress
    data cDocAppl
    data cDocType
    data cEncoding
    data cWsdlConn
    data cWsdlAuth
    data cLocConn
    data cLocAuth
    data cDirDown
    data cDirUp
    data cDealerCode
    data cDocId
endClass

method new() class OFCNHA08
    Self:oWSDL          := tWSDLManager():New()
    Self:oWSDL:lVerbose := .T.

    Self:oConfig        := OFCNHPrimConfig():New(.T.)

    Self:lOK            := .F. 
    Self:aOperations    := {}
    Self:cResp          := ''
    Self:cTicket        := ''
    Self:cServiceID     := ''
    Self:cMarket        := ''
    Self:cApplic        := 'PRIM'
    Self:cBrand         := '00'
    Self:cSincom        := ''
    Self:cCertSys       := 'CNH'
    Self:cLoginID       := ''
    Self:cUser          := ''
    Self:cPass          := ''
    Self:cDirTypes      := 'downloadable'
    Self:cFileGroup     := ''
    Self:cStatus        := ''
    Self:cDateStart     := transform( DtoS(Self:oConfig:oConfig['INICIO_CCON']), "@R 9999/99/99") + " 00:00:00"
    Self:cDateEnd       := ''
    Self:cDateFormat    := 'YYYY/MM/DD HH24:MI:SS'
    Self:cFileInfos     := ''
    Self:cFileId        := ''
    Self:cCompress      := ''
    Self:cDocAppl       := ''
    Self:cDocType       := ''
    Self:cEncoding      := 'asciihex'

    IF Self:oConfig:oConfig['AMBIENTE'] == 'TEST'
        Self:cWsdlConn      := 'https://stg-ccon.cnh.com/ccon/cconWsConnect.php?wsdl'
        Self:cWsdlAuth      := 'https://stg-ccon.cnh.com/ccon/cconWsAut.php?wsdl'
        Self:cLocConn       := 'https://stg-ccon.cnh.com/ccon/cconWsConnect.php'
        Self:cLocAuth       := 'https://stg-ccon.cnh.com/ccon/cconWsAut.php'
    ELSE
        Self:cWsdlConn      := 'https://ccon.cnh.com/ccon/cconWsConnect.php?wsdl'
        Self:cWsdlAuth      := 'https://ccon.cnh.com/ccon/cconWsAut.php?wsdl'
        Self:cLocConn       := 'https://ccon.cnh.com/ccon/cconWsConnect.php'
        Self:cLocAuth       := 'https://ccon.cnh.com/ccon/cconWsAut.php'
    EndIF

    Self:cDealerCode:= AllTrim(Self:oConfig:cDealerCode)
    Self:cDirDown   := '/cnh/' + Self:cDealerCode + Self:oConfig:oConfig['DIR_IN']
    Self:cDirUp     := '/cnh/' + Self:cDealerCode + Self:oConfig:oConfig['DIR_OUT']
    Self:cDocId     := ''
return self


/*/{Protheus.doc} getFiles
Rotina que realiza o download dos arquivos da CNH
@type function
@author Cristiam Rossi
@since 12/02/2025
/*/
method getFiles() class OFCNHA08

local   nFiles

private cMsgLog     := ""
private lDebug      := alltrim(Self:oConfig:oConfig["LOGS"]) == "1"

    if lDebug
		cMsgLog += "--------------------" + CRLF
		cMsgLog += "    " + STR0011 + CRLF//Dados
		cMsgLog += "--------------------" + CRLF
        cMsgLog += STR0012 + Self:cDealerCode + CRLF//"Dealer code: "
        cMsgLog += STR0013 + Self:cDirDown + CRLF + CRLF//"Pasta entrada: "
    endif

    IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
        MsgRun(STR0035, 'CNH', {|| Self:FilesIn()})//'Download de Arquivos cCon'
    ELSE
        IF Self:Connect()
            IF Self:Login()
                Self:Dir()
                Self:Logout()
            EndIF
        EndIF      
    EndIF

	cAgroup := "PRIM"
	cTipo   := "DOWNLOAD FILES"
	cDados  := cMsgLog + STR0017 + CRLF//"Retorno:"
	OA060004C_log( cAgroup, cTipo, cDados )
return nFiles

/*/{Protheus.doc} FilesIn
Apoio pra interface do usuário
@type function
@version 1.0  
@author rodri
@since 03/12/2025
/*/
method FilesIn() class OFCNHA08
    IF Self:Connect()
        IF Self:Login()
            Self:Dir()
            Self:Logout()
        EndIF
    EndIF      
Return

/*/{Protheus.doc} FilesOut
Apoio pra interface do usuário
@type function
@version 1.0  
@author rodri
@since 03/12/2025
/*/
method FilesOut() class OFCNHA08
    IF Self:Connect()
        IF Self:Login()
            Self:Post()
            Self:Logout()
        EndIF        
    EndIF      
Return

/*/{Protheus.doc} sendFiles
Envia arquivos pendentes
@type function
@author Cristiam Rossi
@since 13/02/2025
/*/
method sendFiles() class OFCNHA08
    Local cAgroup       := ""
    Local cTipo         := ""
    Local cDados        := ""
    private cMsgLog     := ""
    private lDebug      := alltrim(Self:oConfig:oConfig["LOGS"]) == "1"

    if lDebug
		cMsgLog += "--------------------" + CRLF
		cMsgLog += "    " + STR0011 + CRLF//"Dados"
		cMsgLog += "--------------------" + CRLF
        cMsgLog += STR0012 + Self:cDealerCode + CRLF//"Dealer code: "
        cMsgLog += STR0025 + Self:cDirUp + CRLF + CRLF//"Pasta saida: "
    endif

    IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
        MsgRun(STR0036, 'CNH', {|| Self:FilesOut()})//'Upload de Arquivos cCon'
    ELSE
        IF Self:Connect()
            IF Self:Login()
                Self:Post()
                Self:Logout()
            EndIF        
        EndIF      
    EndIF

    cAgroup := "PRIM"
	cTipo   := "UPLOAD FILES"
	cDados  := cMsgLog
	OA060004C_log( cAgroup, cTipo, cDados )
return nil

/*/{Protheus.doc} OFCNHA08::RetResult
Retorna e valida a resposta dos metodos
@type method
@version 1.0  
@author Rodrigo dos Santos Brandão
@since 04/11/2025
/*/
Method RetResult() Class OFCNHA08
    Local cRet          := Self:cResp
    
    Local aElementos    := {}
    
    Local nPos          := 0
    Local nI            := 0

    Local lOK       := .F.
    Local lLoginID  := .F.
    Local lService  := .F.
    Local lRenew    := .F.
    Local lFileInfos:= .F.

    cRet := strTran(cRet, CHR(9), '')

    aElementos := StrTokArr(cRet, CRLF)

    lRenew      := ascan(aElementos,{|x| x == 'CurrentPassword:'}) > 0
    lLoginID    := ascan(aElementos,{|x| x == 'LoginId:'}) > 0
    lService    := ascan(aElementos,{|x| x == 'ServiceId:'}) > 0
    lFileInfos  := ascan(aElementos,{|x| x == 'FileInfos:'}) > 0
    nPos        := ascan(aElementos,{|x| x == 'Return:'})

    IF nPos > 0 .AND. lRenew
        Self:cTicket    := aElementos[++nPos]
        Self:cServiceID := aElementos[++nPos]
        Self:cPass      := aElementos[++nPos]
  
        lOK := aElementos[++nPos] == '0'
        IF lOK
            ::oConfig:cPASS := self:cPass

			for nI := 1 to len( ::oConfig:oConfig["SENHAS"] )
				if alltrim(::oConfig:oConfig["SENHAS"][nI]["DEALERCODE"]) == alltrim(::oConfig:cDealerCode)
					::oConfig:oConfig["SENHAS"][nI]["SENHA"] := self:cPass
					exit
				endif
			next

			::oConfig:saveConfig(::oConfig:oConfig)
            Return .T.
        ELSE
            IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                FMX_HELP("RetResult",STR0037 + ' - ' + STR0038)//'Usuário Bloqueado - Entrar em contato com a Equipe CNH'
                Return .F.
            ELSE
                QOUT(STR0037+ ' - ' + STR0038 + '-RetResult')//'Usuário Bloqueado - Entrar em contato com a Equipe CNH'
                Return .F.
            EndIF
        EndIF
        Return lOK
    EndIF

    IF nPos > 0 .AND. lService
        Self:cTicket    := aElementos[++nPos]
        Self:cServiceID := aElementos[++nPos]

        IF nPos == Len(aElementos)
            IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                FMX_HELP("RetResult",STR0039)//Sem conexão
                Return .F.
            ELSE
                QOUT(STR0039 + ' - RetResult')//"Sem conexão"
                Return .F.
            EndIF
        ELSE
            lOK := aElementos[++nPos] == '0'
        EndIF
        IF aElementos[nPos] == '-1'
            IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                FMX_HELP("RetResult",STR0037 + ' - ' + STR0038)//'Usuário Bloqueado - Entrar em contato com a Equipe CNH'
                Return .F.
            ELSE
                QOUT(STR0037 + ' - ' + STR0038+ '- RetResult')//'Usuário Bloqueado - Entrar em contato com a Equipe CNH'
                Return .F.
            EndIF
        ELSEIF aElementos[nPos] == '-2'
            lOK := Self:ConnectPwd()
        EndIF
        Return lOK
    EndIF

    IF nPos > 0 .AND. lLoginID
        Self:cTicket    := aElementos[++nPos]
        Self:cLoginID   := aElementos[++nPos]
        
        lOK := aElementos[++nPos] == '0'
        IF aElementos[nPos] == '-2'
            lOK := Self:ConnectPwd()
        EndIF
        Return lOK
    EndIF

    IF nPos > 0 .AND. lFileInfos
        Self:cTicket    := aElementos[++nPos]
        Self:cFileInfos := aElementos[++nPos]

        lOK := aElementos[++nPos] == '0'
        IF aElementos[nPos] == '-2'
            lOK := Self:ConnectPwd()
        EndIF
        Return lOK
    EndIF
Return lOK

/*/{Protheus.doc} OFCNHA08::ConnectPwd
Realiza a troca de senha para conexao
@type method
@version 1.0  
@author Rodrigo dos Santos brandão
@since 04/11/2025
/*/
Method ConnectPwd() Class OFCNHA08
    Local lOK := .F.

    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlConn)
    IF !Self:lOk
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)           
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('CONNECTPWD ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconconnectpwd'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF//"List Operation Error: "
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('CONNECTPWD ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF    

    Self:lOK := Self:oWSDL:SetOperation('cconConnectPwd')

    Self:lOK := Self:oWSDL:SetFirst('User', Self:cUser)
    Self:lOK := Self:oWSDL:SetFirst('Password', Self:cPass)
    Self:lOK := Self:oWSDL:SetFirst('CertificationSystem', Self:cCertSys)

    Self:oWSDL:cLocation := Self:cLocConn
    Self:oWSDL:bNoCheckPeerCert := .T.

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 + "cconConnectPwd"  + CRLF//"Enviar"-"Operação: "
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0043 + CRLF//Request:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	endif

    Self:lOK := Self:oWSDL:SendSoapMsg()
    IF !Self:lOK
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)            
            Return .F.
        ELSE
            QOUT('CONNECTPWD SendSoapMsg ERROR ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 + "cconConnectPwd"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0044 + CRLF//Return:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapResponse()) + CRLF + CRLF
	endif

    Self:cResp := Self:oWSDL:GetParsedResponse()
    IF !Self:RetResult()
        Return .F.
    EndIF
Return lOK

/*/{Protheus.doc} OFCNHA08::Connect
Realiza a conexao ao CCON
@type method
@version 1.0  
@author Rodrigo dos Santos Brandão
@since 04/11/2025
/*/
Method Connect() Class OFCNHA08
    Local lOK   := .F.
    
    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlConn)
    IF !Self:lOk
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5) 
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('CONNECT ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconconnect'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF//"List Operation Error: "
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('CONNECT ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF    
    
    Self:lOK := Self:oWSDL:SetOperation('cconConnect') 

    Self:cUser  := Self:oConfig:cUser
    Self:cPass  := Self:oConfig:cPass
    Self:lOK := Self:oWSDL:SetFirst('User', Self:cUser)
    Self:lOK := Self:oWSDL:SetFirst('Password', Self:cPass)
    Self:lOK := Self:oWSDL:SetFirst('CertificationSystem', Self:cCertSys)

    Self:oWSDL:cLocation := Self:cLocConn
    Self:oWSDL:bNoCheckPeerCert := .T.

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 + "cconConnect"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0043 + CRLF//Request:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	endif

    Self:lOK := Self:oWSDL:SendSoapMsg()

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 + "cconConnect"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0044 + CRLF//Return:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapResponse()) + CRLF + CRLF
	endif
    
    IF !Self:lOK
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('CONNECT SendoSoapMsg ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:cResp := Self:oWSDL:GetParsedResponse()
    lOK := Self:RetResult()
Return lOK

/*/{Protheus.doc} OFCNHA08::Login
Realiza a autenticacao com base nas credenciais
@type method
@version 1.0  
@author Rodrigo dos Santos Brandão
@since 04/11/2025
/*/
Method Login() Class OFCNHA08
    Local lOK   := .F.
    
    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
    IF !Self:lOk 
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('LOGIN ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconlogin'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF//"List Operation Error: "
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('LOGIN ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF    

    Self:lOK := Self:oWSDL:SetOperation('cconLogin')

    Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
    Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
    Self:lOK := Self:oWSDL:SetFirst('Market', Self:oConfig:cMarket)
    Self:lOK := Self:oWSDL:SetFirst('Application', Self:cApplic)
    Self:lOK := Self:oWSDL:SetFirst('Brand', Self:cBrand)
    Self:lOK := Self:oWSDL:SetFirst('Sincom', Self:oConfig:cDealerCode)
    Self:lOK := Self:oWSDL:SetFirst('CertificationSystem', Self:cCertSys)

    Self:oWSDL:cLocation := Self:cLocAuth
    Self:oWSDL:bNoCheckPeerCert := .T.

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconLogin"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0043 + CRLF//Request:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	endif

    Self:lOK := Self:oWSDL:SendSoapMsg()
    IF !Self:lOK
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('LOGIN SendoSoapMsg ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconLogin"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0044 + CRLF//Return:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapResponse()) + CRLF + CRLF
	endif

    Self:cResp := Self:oWSDL:GetParsedResponse()
    lOK := Self:RetResult()
Return lOK

/*/{Protheus.doc} OFCNHA08::Dir
Faz a leitura do diretorio para obter arquivos
@type method
@version 1.0  
@author Rodrigo dos Santos
@since 04/11/2025
@param cFileName, character, nome do arquivo
/*/
Method Dir(cFileName) Class OFCNHA08
    Local lOK   := .F.
    
    Local cErros    := ''
    Local cAvisos   := ''
    Local cFName    := ''
    Local cFId      := ''
    Local cComp     := ''
    
    Local aFiles := {}

    Local nI     := 0
    Local nFTam  := 0

    private oXmlRet   := NIL

    DEFAULT cFileName   := '*'
    
    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
    IF !Self:lOk 
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('DIR ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='ccondir'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('DIR ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF    

    Self:lOK := Self:oWSDL:SetOperation('cconDir')

    Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
    Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
    Self:lOK := Self:oWSDL:SetFirst('LoginId', Self:cLoginID)
    Self:lOK := Self:oWSDL:SetFirst('DirTypes', Self:cDirTypes)
    Self:lOK := Self:oWSDL:SetFirst('FileGroup', Self:cFileGroup)
    Self:lOK := Self:oWSDL:SetFirst('FileName', cFileName)
    Self:lOK := Self:oWSDL:SetFirst('Status', Self:cStatus)
    Self:lOK := Self:oWSDL:SetFirst('DateStart', Self:cDateStart)
    Self:lOK := Self:oWSDL:SetFirst('DateEnd', Self:cDateEnd)
    Self:lOK := Self:oWSDL:SetFirst('DateFormat', Self:cDateFormat)
    
    Self:oWSDL:cLocation := Self:cLocAuth
    Self:oWSDL:bNoCheckPeerCert := .T.

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 + "cconDir"      + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0043 + CRLF//Request:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	endif

    Self:lOK := Self:oWSDL:SendSoapMsg()
    IF !Self:lOK
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('DIR SendSoapMsg ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:cResp := Self:oWSDL:GetSoapResponse()

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 + "cconDir"      + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0044 + CRLF//Return:
		cMsgLog += OA060006C_prettyXML(Self:cResp) + CRLF + CRLF
	endif

    oXMLRet := XmlParser(Self:cResp, "_", @cErros, @cAvisos)

    IF !Empty(cAvisos)
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("Dir",STR0045 + cAvisos)//"Aviso(s) ao converter em objeto: "
            Return .F.
        ELSE
            QOUT('DIR '+ STR0046 + cAvisos)
            Return .F.
        EndIF
    EndIF

    aFiles := iif( valType(oXMLRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONDIRRESPONSE:_FILEINFOS:_ITEM)=="O", { oXMLRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONDIRRESPONSE:_FILEINFOS:_ITEM }, oXMLRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONDIRRESPONSE:_FILEINFOS:_ITEM )

    if type( "oXMLRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONDIRRESPONSE:_RETURN:TEXT" ) == "C" .and. oXMLRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONDIRRESPONSE:_RETURN:TEXT == "0"
        aFiles := {}
    elseif ValType(aFiles) != 'A'
        if lDebug
            cMsgLog += "aFiles -"+ STR0047  + CRLF      //Falha para obter o total de arquivos para download
        endif
        lOK := .F.
        Return lOK
    EndIF 

    if lDebug
        cMsgLog += STR0019 + cValToChar( len(aFiles) ) + CRLF      //"Arquivos a serem baixados: "
    endif
    
    For nI := 1 to Len(aFiles)
        cFName  := "BR13_"+aFiles[nI]:_C_CUSTOMER:TEXT+"_"+aFiles[nI]:_C_FILE_NAME:TEXT+"_"+aFiles[nI]:_C_FILE_ID:TEXT
        cFId    := aFiles[nI]:_C_FILE_ID:TEXT
        cComp   := aFiles[nI]:_C_COMPRESS:TEXT
        nFTam   := Val(aFiles[nI]:_N_SIZE:TEXT)

        Self:Get(cFName, cFId, cComp, nFTam)
    Next

Return lOK

/*/{Protheus.doc} OFCNHA08::Get
Obtem os arquivos
@type method
@version 1.0  
@author Rodrigo dos Santos
@since 04/11/2025
@param cArqName, character, Nome do arquivo
@param cArqId, character, ID
@param cFormato, character, formato
@param nArqTam, numeric, tamanho
/*/
Method Get(cArqName, cArqId, cFormato, nArqTam) Class OFCNHA08
    Local lFileOK := .F.

    Local nX        := 0
    local nSize     := nArqTam * 2
    Local nChunks   := nSize / 999999

    Local cRet      := ''
    Local cBufXml   := ''
    Local cAvisos   := ''
    Local cErros    := ''
    Local cArqZip   := ''
    Local cDirTemp  := ''

    Local oXmlRet   := NIL
    Local lDebugMil := ExistBlock("DEBUGMIL")
   
    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
    IF !Self:lOk 
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('GET ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconget'}) == 0
        if type("lDebug") == "L" .and. lDebug
            cMsgLog += STR0040 + Self:oWSDL:cError + CRLF//"List Operation Error: "
	    endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('GET ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF       

    Self:lOK := Self:oWSDL:SetOperation('cconGet')

    if nChunks < 1
		nChunks := 1
	endif

    For nX := 1 To nChunks
        if nChunks == 1 // pedaco unico
			cLen := STR(nSize)
		else
			cLen := '999999'
			if nX == nChunks
				nLastChunkSize := nSize - ((nChunks-1)*999999)
				cLen := STR(nLastChunkSize)
			endif
		endif

        Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
        Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
        Self:lOK := Self:oWSDL:SetFirst('LoginId', Self:cLoginID)
        Self:lOK := Self:oWSDL:SetFirst('DocId', cArqId )
        Self:lOK := Self:oWSDL:SetFirst('DocAppl', Self:cDocAppl)
        Self:lOK := Self:oWSDL:SetFirst('DocType', Self:cDocType)
        Self:lOK := Self:oWSDL:SetFirst('Compress', cFormato)
        Self:lOK := Self:oWSDL:SetFirst('Encoding', Self:cEncoding)
        Self:lOK := Self:oWSDL:SetFirst('Operation', IIF(nX == 1, 'start', 'next'))
        Self:lOK := Self:oWSDL:SetFirst('ChunkLength', ALLTRIM(cLen))
        
        Self:oWSDL:cLocation := Self:cLocAuth
        Self:oWSDL:bNoCheckPeerCert := .T.

        if type("lDebug") == "L" .and. lDebug
            cMsgLog += "------------------------------------------" + CRLF
            cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconGet"  + CRLF
            cMsgLog += "------------------------------------------" + CRLF
            cMsgLog += STR0043 + CRLF//Request:
            cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	    endif

        Self:lOK := Self:oWSDL:SendSoapMsg()
        IF !Self:lOK .or. ( lDebugMil .and. execBlock("DebugMil", .F., .F., { "SendSoapMsg1" }) )
            IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
                Return .F.
            ELSE
                QOUT('GET SendSoapMsg ERROR: ' + Self:oWSDL:cError)
                Return .F.
            EndIF
        EndIF

        cRet := Self:oWSDL:GetSoapResponse()

        if type("lDebug") == "L" .and. lDebug
            cMsgLog += "------------------------------------------" + CRLF
            cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconGet"  + CRLF
            cMsgLog += "------------------------------------------" + CRLF
            cMsgLog += STR0044 + CRLF//Return:
            cMsgLog += OA060006C_prettyXML(cRet) + CRLF + CRLF
	    endif        

        oXmlRet := XmlParser(cRet, "_", @cErros, @cAvisos)

        IF !Empty(cAvisos)
            IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                FMX_HELP("Get",STR0045 + cAvisos)
                Return .F.
            ELSE
                QOUT('GET '+ STR0046 + cAvisos)
                Return .F.
            EndIF
        EndIF

        cBufXml := oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONGETRESPONSE:_BUFFER:TEXT

        cArqZip += OFXFA021C_Hex2Str(cBufXml)    
    Next

    memowrite(Self:cDirDown + cArqName + ".gz", cArqZip)

    IF SubStr(Self:cDirDown, Len(Self:cDirDown), 1) $ "/\"
        cDirTemp := Left(Self:cDirDown, Len(Self:cDirDown)-1)
    EndIF

	lGzDecomp := GzDecomp( Self:cDirDown + cArqName + ".gz", cDirTemp, .T. )
	if lGzDecomp
		fRename( Self:cDirDown + cArqName, Self:cDirDown + cArqName + ".dat" )
		fErase( Self:cDirDown + cArqName + ".gz" )
		lFileOK := .T.

        Self:Commit(cArqId)
	endif
Return lFileOK

/*/{Protheus.doc} OFCNHA08::Commit
Realiza o commit para confirmar a operacao
@type method
@version 1.0  
@author Rodrigo dos Santos Brandao
@since 04/11/2025
@param cArqId, character, id
/*/
Method Commit(cArqId) Class OFCNHA08    
    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
    IF !Self:lOk 
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('COMMIT ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconcommit'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF//"List Operation Error: "
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('COMMIT ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF       

    Self:lOK := Self:oWSDL:SetOperation('cconCommit')    

    Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
    Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
    Self:lOK := Self:oWSDL:SetFirst('LoginId', Self:cLoginID)
    Self:lOK := Self:oWSDL:SetFirst('DocId', cArqId )
        
    Self:oWSDL:cLocation := Self:cLocAuth
    Self:oWSDL:bNoCheckPeerCert := .T.

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconCommit"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0043 + CRLF//Request:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	endif

    Self:lOK := Self:oWSDL:SendSoapMsg()
    IF !Self:lOK
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('COMMIT SendSoapMsg ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconCommit"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0044 + CRLF//Return:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapResponse()) + CRLF + CRLF
	endif
Return Self:lOK

/*/{Protheus.doc} OFCNHA08::Logout
Realiza o logout
@type method
@version 1.0  
@author Rodrigo dos Santos Brandao
@since 06/11/2025
/*/
method Logout() class OFCNHA08    
    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
    IF !Self:lOk 
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('LOGOUT ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconlogout'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF//"List Operation Error: "
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('LOGOUT ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF    

    Self:lOK := Self:oWSDL:SetOperation('cconLogout') 

    Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
    Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
    Self:lOK := Self:oWSDL:SetFirst('LoginId', Self:cLoginID)

    Self:oWSDL:cLocation := Self:cLocAuth
    Self:oWSDL:bNoCheckPeerCert := .T.

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconLogout"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0043 + CRLF//Request:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	endif

    Self:lOK := Self:oWSDL:SendSoapMsg()
    IF !Self:lOK
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('LOGOUT SendSoapMsg ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconLogout"  + CRLF
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0044 + CRLF//Return:
		cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapResponse()) + CRLF + CRLF
	endif
return Self:lOK

/*/{Protheus.doc} OFCNHA08::Post
Realiza o envio de arquivos
@type method
@version 1.0  
@author Rodrigo dos Santos Brandao
@since 06/11/2025
/*/
method Post() class OFCNHA08
    Local aArqs := {}
    Local aContent := {}

    Local nX        := 0
    Local nX1       := 1
    Local nI        := 0
    Local nChunks   := 0
    Local nHandle   := 0   
    Local nIntChunks:= 0
    Local nChunksSend := 0
    Local nTamTxt   := 0
    Local nCurrent  := 0

    Local cRet      := ''
    Local cAvisos   := ''
    Local cErros    := ''
    Local cDocUp    := 'PRIM'
    Local cTypeUp   := 'PRIM2'
    Local cFullPath := ''
    Local cFileName := ''
    Local cOnlyName := ''
    Local cData     := ''
    Local cBufTxt   := ''
    Local cRetHex   := ''
    Local cByteHex  := ''
    Local cDestMark := ''
    Local cDestUser := ''
    Local cBuffer   := ''
    Local lDebugMil := ExistBlock("DEBUGMIL")
    Local cFirstDocId := ""

    private oXmlRet   := NIL  

    Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
    IF !Self:lOk 
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ParseURL() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('POST ParseURL ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF

    Self:aOperations := Self:oWSDL:ListOperations()
    IF Len(Self:aOperations) == 0 .AND. aScan(Self:aOperations,{|It|Lower(It[1])=='cconpost'}) == 0
        if type("lDebug") == "L" .and. lDebug
	        cMsgLog += STR0040 + Self:oWSDL:cError + CRLF
        endif
        IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
            FMX_HELP("ListOperations() ERROR", Self:oWSDL:cError)
            Return .F.
        ELSE
            QOUT('POST ListOperations ERROR: ' + Self:oWSDL:cError)
            Return .F.
        EndIF
    EndIF       

    Self:lOK := Self:oWSDL:SetOperation('cconPost')

    aArqs := Directory(Self:cDirUp + '*.dat',, NIL, .T.)
    FWMakeDir(Self:cDirUp + STR0048)

    cFullPath := Lower(GetSrvProfString('Rootpath', '')) + StrTran(Self:cDirUp, '/', '\')

    IF IsSrvUnix()
        cFullPath := StrTran(cFullPath, '\', '/')
    EndIF

    For nI := 1 To Len(aArqs)
        Self:lOk := Self:oWSDL:ParseURL(Self:cWsdlAuth)
        Self:lOK := Self:oWSDL:SetOperation('cconPost')

        cFileName := Lower(aArqs[nI][1])
        cOnlyName := Left(cFileName, RAT(".", cFileName )-1)
        nCurrent  := 0
        cData     := ""
        aContent  := {}
        cBuffer   := ""
        cFirstDocId := ""

        GzCompress(Self:cDirUp + cFileName, Self:cDirUp + cOnlyName + '.gzip')

        nHandle := fOpen(Self:cDirUp + cOnlyName + '.gzip')

        nTamTxt := FSEEK( nHandle, 0, FS_END )
	    FSEEK( nHandle, 0 )

	    While nCurrent < nTamTxt
		    nCurrent += FREAD( nHandle, @cBufTxt, 4096 )
		    cData += cBufTxt
	    EndDo

	    fClose(nHandle)
	    fErase(Self:cDirUp + cOnlyName + '.gzip')

        cRetHex := Lower(OFXFA019C_Str2Hex(cData))

        cByteHex := ''
        For nX := 1 to Len(cRetHex)
            cByteHex += substr(cRetHex, nX, 1)
            if len(cByteHex) == 2
                AADD(aContent, cByteHex)
                cByteHex := ''
            endif
        Next

        nBytes      := Len(aContent)
	    nChunks     := nBytes / 1000000
	    nIntChunks  := int(nChunks)

        Self:cDocId := ''

	    for nX1 := 1 to nBytes
		    cOperation := iif( nChunks < 1, 'end:0', iif( nX1 == 1 .AND. nChunks > 1, 'start', iif( nX1 > 1 .AND. nChunksSend <= nIntChunks, 'next', 'end' ) ) )

		    cBuffer += alltrim(aContent[nX1])
		    if len(cBuffer) >= 2000000

                Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
                Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
                Self:lOK := Self:oWSDL:SetFirst('LoginId', Self:cLoginID)
                Self:lOK := Self:oWSDL:SetFirst('DocId', Self:cDocId )
                Self:lOK := Self:oWSDL:SetFirst('DocAppl', cDocUp)
                Self:lOK := Self:oWSDL:SetFirst('DocType', cTypeUp)
                Self:lOK := Self:oWSDL:SetFirst('Compress', Self:cCompress)
                Self:lOK := Self:oWSDL:SetFirst('Encoding', Self:cEncoding)
                Self:lOK := Self:oWSDL:SetFirst('Operation', iif(nChunksSend == 0, cOperation:='start',cOperation ))
                Self:lOK := Self:oWSDL:SetFirst('ChunkLength', cValToChar( len(cBuffer) ) )
                Self:lOK := Self:oWSDL:SetFirst('Buffer', cBuffer)
                Self:lOK := Self:oWSDL:SetFirst('DestMarket', cDestMark)
                Self:lOK := Self:oWSDL:SetFirst('DestApplic', cDocUp)
                Self:lOK := Self:oWSDL:SetFirst('DestUser', cDestUser)

                Self:oWSDL:cLocation := Self:cLocAuth
                Self:oWSDL:bNoCheckPeerCert := .T.

                if type("lDebug") == "L" .and. lDebug
		            cMsgLog += "------------------------------------------" + CRLF
                    cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconPost"     + CRLF
                    cMsgLog += "------------------------------------------" + CRLF
                    cMsgLog += STR0043 + CRLF//Request:
                    cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	            endif

                Self:lOK := Self:oWSDL:SendSoapMsg()
                IF !Self:lOK .or. ( lDebugMil .and. execBlock("DebugMil", .F., .F., { "SendSoapMsg1" }) )
                    IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                        FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
                        Return .F.
                    ELSE
                        QOUT('POST SendSoapMsg ERROR: ' + Self:oWSDL:cError)
                        Return .F.
                    EndIF
                EndIF

                cRet := Self:oWSDL:GetSoapResponse()   

                if type("lDebug") == "L" .and. lDebug
                    cMsgLog += "------------------------------------------" + CRLF
                    cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconPost"     + CRLF
                    cMsgLog += "------------------------------------------" + CRLF
                    cMsgLog += STR0044 + CRLF//Return:
                    cMsgLog += OA060006C_prettyXML(cRet) + CRLF + CRLF
	            endif  

                oXmlRet := XmlParser(cRet, "_", @cErros, @cAvisos)

                IF !Empty(cAvisos) .or. ( lDebugMil .and. execBlock("DebugMil", .F., .F., { "cAvisos1" }) )
                    IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                        FMX_HELP("Post",STR0045 + cAvisos)                        
                        Return .F.
                    ELSE
                        QOUT(STR0046 + cAvisos)
                        Return .F.
                    EndIF
                EndIF   
                Self:cDocId := iif( type("oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONPOSTRESPONSE:_DOCID:TEXT") == "C" .and. oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONPOSTRESPONSE:_DOCID:TEXT != "-1", oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONPOSTRESPONSE:_DOCID:TEXT, "" )
                if empty( cFirstDocId )
                    cFirstDocId := Self:cDocId
                endif

			    nChunksSend ++
			    cBuffer := ''
		    endif
	    next

        if Len(cBuffer) > 0

            Self:lOK := Self:oWSDL:SetFirst('Ticket', Self:cTicket)
            Self:lOK := Self:oWSDL:SetFirst('ServiceId', Self:cServiceID)
            Self:lOK := Self:oWSDL:SetFirst('LoginId', Self:cLoginID)
            Self:lOK := Self:oWSDL:SetFirst('DocId', Self:cDocId )
            Self:lOK := Self:oWSDL:SetFirst('DocAppl', cDocUp)
            Self:lOK := Self:oWSDL:SetFirst('DocType', cTypeUp)
            Self:lOK := Self:oWSDL:SetFirst('Compress', Self:cCompress)
            Self:lOK := Self:oWSDL:SetFirst('Encoding', Self:cEncoding)
//            Self:lOK := Self:oWSDL:SetFirst('Operation', iif( nChunksSend == 0, 'start', 'end:0' ) )
            Self:lOK := Self:oWSDL:SetFirst('Operation', iif( nChunksSend == 0, 'start', 'end' ) )
            Self:lOK := Self:oWSDL:SetFirst('ChunkLength', cValToChar( len(cBuffer) ) )
            Self:lOK := Self:oWSDL:SetFirst('Buffer', cBuffer)
            Self:lOK := Self:oWSDL:SetFirst('DestMarket', cDestMark)
            Self:lOK := Self:oWSDL:SetFirst('DestApplic', cDocUp)
            Self:lOK := Self:oWSDL:SetFirst('DestUser', cDestUser)

            Self:oWSDL:cLocation := Self:cLocAuth
            Self:oWSDL:bNoCheckPeerCert := .T.

            if type("lDebug") == "L" .and. lDebug
                cMsgLog += "------------------------------------------" + CRLF
                cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconPost"     + CRLF
                cMsgLog += "------------------------------------------" + CRLF
                cMsgLog += STR0043 + CRLF//Request:
                cMsgLog += OA060006C_prettyXML(Self:oWSDL:GetSoapMsg()) + CRLF + CRLF
	        endif

            Self:lOK := Self:oWSDL:SendSoapMsg()
            IF !Self:lOK .or. ( lDebugMil .and. execBlock("DebugMil", .F., .F., { "SendSoapMsg2" }) )
                IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                    FMX_HELP("SendSoapMsg() ERROR", Self:oWSDL:cError)
                    Return .F.
                ELSE
                    QOUT('POST SendSoapMsg ERROR: ' + Self:oWSDL:cError)
                    Return .F.
                EndIF
            EndIF

            cRet := Self:oWSDL:GetSoapResponse()   

            if type("lDebug") == "L" .and. lDebug
		        cMsgLog += "------------------------------------------" + CRLF
		        cMsgLog += "     " + STR0041 + " - " + STR0042 +"cconPost"     + CRLF
                cMsgLog += "------------------------------------------" + CRLF
                cMsgLog += STR0044 + CRLF//Return:
                cMsgLog += OA060006C_prettyXML(cRet) + CRLF + CRLF
	        endif  

            oXmlRet := XmlParser(cRet, "_", @cErros, @cAvisos)

            IF !Empty(cAvisos) .or. ( lDebugMil .and. execBlock("DebugMil", .F., .F., { "cAvisos2" }) )
                IF (nRemote == 1 .OR. nRemote == 2 .OR. nRemote == 5)
                    FMX_HELP("Post",STR0045 + cAvisos)
                    Return .F.
                ELSE
                    QOUT(STR0046 + cAvisos)
                    Return .F.
                EndIF
            EndIF

            Self:cDocId := iif( type("oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONPOSTRESPONSE:_DOCID:TEXT") == "C" .and. oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONPOSTRESPONSE:_DOCID:TEXT != "-1", oXmlRet:_SOAP_ENV_ENVELOPE:_SOAP_ENV_BODY:_NS1_CCONPOSTRESPONSE:_DOCID:TEXT, "" )
            Self:lOK    := ! empty( Self:cDocId )

            if empty( cFirstDocId )
                cFirstDocId := Self:cDocId
            endif
        endif

        IF Self:lOK
            Self:Commit( cFirstDocId )
            
            __CopyFile(Self:cDirUp + cOnlyName + '.dat', Self:cDirUp + cPathEnv + cOnlyName + '.dat',,,.F.)
            
            fErase(Self:cDirUp + cOnlyName + '.dat')
            if lDebug
                cMsgLog += "          " + STR0030 + CRLF + CRLF
            endif
        EndIF

    Next   
return
