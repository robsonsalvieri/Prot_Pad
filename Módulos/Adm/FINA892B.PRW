#Include "Protheus.ch"
#Include "FwLibVersion.ch"

/*/{Protheus.doc}Token
    Modelagem da classe Token
    
    @author Sivaldo Oliveira
    @since  09/11/2022
/*/
Class Token
    //Atributos da classe
    Data lGerouTk   As Logical
    Data lTkAtivo   As Logical
    Data cUrlBase   As Char
    Data cToken     As Char
    Data cClientId  As Char 
    Data cCliSecret As Char
    Data cUsuario   As Char
    Data cPassword  As Char    
    Data cPath      As Char
    Data cBody      As Char
    Data cTimeExp   As Char      
    Data cUniTime   As Char
    Data cAppKey    As Char
    Data cErro      As Char
    Data dDataExp   As Date
    Data aHeader    As Array
    
    Method New() CONSTRUCTOR
    
    //Setters
    Method SetGerouTk()
    Method SetTkAtivo()
    Method SetUrlBase()
    Method SetToken()
    Method SetClienId()
    Method SetCliSecr()
    Method SetUsuario()
    Method SetSenha()
    Method SetPath()
    Method SetBody()    
    Method SetTimeExp()
    Method SetUniTime()
    Method SetAppKey()
    Method SetErro()
    Method SetDataExp()
    Method SetHeader()
    
    //Getters
    Method GetGerouTk()
    Method GetTkAtivo()
    Method GetUrlBase()
    Method GetToken()
    Method GetClienId()
    Method GetCliSecr()
    Method GetUsuario()
    Method GetSenha()
    Method GetPath()
    Method GetBody()    
    Method GetTimeExp()
    Method GetUniTime()
    Method GetAppKey()
    Method GetErro()
    Method GetDataExp()
    Method GetHeader()
EndClass

/*/{Protheus.doc}New
    Método construtor da classe (Token)

    @Param cUrlBase, Char,  Url Base (HostName) 
    @Param cPath,    Char,  Recurso (EndPoint)
    @Param cBody,    Char,  Corpo da requisição
    @Param aHeader,  Array, Cabechalo da requisição

    @author Sivaldo Oliveira
    @since  09/11/2022
/*/
Method New(cUrlBase As Char, cPath As Char, cAppKey As Char, cBody As Char, aHeader, cUniTime As Char) class Token
    //Parâmetros de entrada
    Default cUrlBase := ""
    Default cPath    := ""
    Default cAppKey  := cAppKey    
    Default cBody    := ""
    Default aHeader  := {}
    Default cUniTime := "S"    
    
    //Inicializa alguns atributos da classe.
    Self:lGerouTk := .F.
    Self:lTkAtivo := .F.
    Self:cToken   := ""
    Self:SetUrlBase(cUrlBase)
    Self:SetPath(cPath)
    Self:SetBody(cBody)
    Self:SetHeader(aHeader)
    Self:SetUniTime(cUniTime)
    Self:SetAppKey(cAppKey)
Return Nil

//Setters
Method SetGerouTk(lGerouTk As Logical) Class Token
    Default lGerouTk := .F.
    Self:lGerouTk := lGerouTk
Return Nil

Method SetTkAtivo() Class Token
    Local cTimeExp   As Char
    Local cTimeAtual As Char
    Local dDtaExp    As Date
    Local dDtaAtual  As Date
    
    If Self:GetGerouTk()    
        //Inicializa variáveis
        cTimeExp   := Self:GetTimeExp()
        cTimeAtual := Time()
        dDtaExp    := Self:GetDataExp() 
        dDtaAtual  := Date()
        
        Self:lTkAtivo := !((dDtaAtual > dDtaExp) .Or. (dDtaAtual == dDtaExp .And. cTimeAtual > cTimeExp))
    EndIf
Return Nil

Method SetUrlBase(cUrlBase As Char) Class Token
    Default cUrlBase := ""
    Self:cUrlBase := cUrlBase 
Return Nil

Method SetToken(cToken As Char) Class Token
    Default cToken := ""
    Self:cToken := cToken
Return Nil

Method SetClienId(cClientId As Char) Class Token
    Default cClientId := ""
    Self:cClientId := cClientId
Return

Method SetCliSecr(cCliSecret As Char) Class Token
    Default cCliSecret := ""
    Self:cCliSecret := cCliSecret
Return Nil

Method SetUsuario(cUsuario As Char) Class Token
    Default cUsuario := cUsuario
    Self:cUsuario = cUsuario  
Return Nil

Method SetSenha(cPassword As Char) Class Token
    Default cPassword := ""
    Self:cPassword := cPassword    
Return Nil

Method SetPath(cPath As Char) Class Token
    Default cPath := ""
    Self:cPath := cPath
Return Nil

Method SetBody(cBody As Char) Class Token
    Default cBody := ""
    Self:cBody := cBody
Return Nil   

Method SetTimeExp(cTimeExp As Char) Class Token
    Default cTimeExp := ""
    Self:cTimeExp := cTimeExp
Return Nil

Method SetUniTime(cUniTime As Char) Class Token
    Default cUniTime = ""
    
    cUniTime := AllTrim(cUniTime)
    
    If !cUniTime $ "H|M|S"
        cUniTime := "S"
    EndIf
    
    Self:cUniTime := cUniTime
Return Nil

Method SetAppKey(cAppKey As Char) Class Token
    Default cAppKey := ""
    Self:cAppKey := cAppKey
Return Nil

Method SetErro(cErro As Char) Class Token
    Default cErro := ""
    Self:cErro := cErro
Return Nil

Method SetDataExp(nTimeExp As Numeric) Class Token
    Local cTempo    As Char
    Local cTimeExp  As Char
    Local cUniTime  As Char
    Local nDias     As Numeric
    Local nHoras    As Numeric
    Local nMinutos  As Numeric
    Local dDataExp  As Date
    
    //Parâmetros de entrada do método.
    Default nTimeExp := 3600
    
    //Inicializa variáveis
    cTempo    := ""
    cTimeExp  := ""
    cUniTime  := ""
    nDias     := 0
    nHoras    := 0
    nMinutos  := nTimeExp
    dDataExp  := CToD("")
    
    If nTimeExp > 0 
        cUniTime  := Self:GetUniTime()        
        
        If cUniTime == "H"
            nMinutos  := (nTimeExp * 60)
        ElseIf cUniTime == "S" 
            nMinutos  := (nTimeExp / 60)
        EndIf
        
        cTempo := IncTime(Time(), Nil, nMinutos)
        nHoras := Val(SubStr(cTempo, 1, 2))
        
        While nHoras >= 24
            nHoras -= 24
            nDias++
        EndDo
        
        cTimeExp := (StrZero(nHoras, 2) + SubStr(cTempo, 3, Len(cTempo))) 
        dDataExp := (Date() + nDias)
    EndIf
    
    Self:SetTimeExp(cTimeExp)
    Self:dDataExp := dDataExp 
Return Nil    

Method SetHeader(aHeader As Array) Class Token
    Default aHeader := {}
    Self:aHeader := AClone(aHeader)
Return Nil    

//Getters
Method GetGerouTk() Class Token
Return Self:lGerouTk

Method GetTkAtivo() Class Token
Return Self:lTkAtivo

Method GetUrlBase() Class Token
Return Self:cUrlBase

Method GetToken(cChaAcesTk As Char, cChavExpTk As Char) class Token
    Local cResult  As Char
    Local cToken   As Char
    Local nTimeExp As Numeric
    Local oRest    As Object
    Local oJSON    As Object
    
    //Parâmetros de entrada.
    Default cChaAcesTk := "access_token"
    Default cChavExpTk := "expires_in" 
    
    //Inicializa variáveis
    cResult  := ""
    cToken   := ""
    nTimeExp := 0
    oRest    := Nil
    oJSON    := Nil
    
    If (!Self:GetGerouTk() .Or. !Self:GetTkAtivo())        
        oRest := FwRest():New(Self:GetUrlBase())
        oRest:SetPath(Self:GetPath() + Self:GetAppKey())
        oRest:SetPostParams(Self:GetBody())
        Self:SetGerouTk(oRest:Post(Self:GetHeader()))
        
        If Self:GetGerouTk()
            oJSON   := JSONObject():new()
            cResult := oJSON:FromJSON(oRest:GetResult())
            Self:SetGerouTk(ValType(cResult) == "U")
            
            If Self:GetGerouTk()
                cToken   := oJSON[cChaAcesTk]
                nTimeExp := oJSON[cChavExpTk]
            EndIf
            
            FreeObj(oJSON)
        EndIf
        
        Self:SetToken(cToken)
        Self:SetDataExp(nTimeExp)
        Self:SetTkAtivo()
        
        If !Self:GetGerouTk()
            Self:SetErro(oRest:GetLastError())
        EndIf
        
        FreeObj(oRest)
    EndIf
Return Self:cToken

Method GetClienId() Class Token
Return Self:cClientId

Method GetCliSecr() Class Token
Return Self:cCliSecret

Method GetUsuario() Class Token
Return Self:cUsuario

Method GetSenha() Class Token   
Return Self:cPassword

Method GetPath() Class Token
Return Self:cPath

Method GetBody() Class Token
Return Self:cBody   

Method GetTimeExp() Class Token
Return Self:cTimeExp

Method GetUniTime(cUniTime As Char) Class Token
Return Self:cUniTime

Method GetAppKey() Class Token
Return Self:cAppKey

Method GetErro() Class Token
Return Self:cErro

Method GetDataExp() Class Token
Return Self:dDataExp

Method GetHeader() Class Token
Return Self:aHeader
