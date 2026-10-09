#INCLUDE "PROTHEUS.CH" 

Function GFEITypeOfDocument()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEITypeOfDocument
Classe de Funções Relacionadas do tipo de documento utilizada nas integração de mensagem unica e API REST Cancelamento de Documento de Carga
Generica

@author Andre Wisnheski
@since 29/03/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------

CLASS GFEITypeOfDocument FROM LongNameClass
    
	DATA cTypeOfDocument
	DATA lStatus
	DATA cMensagem
	DATA nGW1CDTPDC
	DATA lNoTags
	
	METHOD New() CONSTRUCTOR
	METHOD Localizar()
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD setTypeOfDocument(cTypeOfDocument)
	METHOD setGW1CDTPDC(nGW1CDTPDC)
	METHOD setNoTags(lNoTags)
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	
	METHOD getTypeOfDocument()
	METHOD getGW1CDTPDC()
	METHOD getNoTags()
	METHOD getStatus()
	METHOD getMensagem()
ENDCLASS

METHOD New() Class GFEITypeOfDocument
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEITypeOfDocument
	FreeObj(oObject)
Return

METHOD ClearData() Class GFEITypeOfDocument
	Self:cTypeOfDocument	:= ''
	Self:lStatus			:= .F.
	Self:cMensagem			:= ""
	Self:nGW1CDTPDC			:= TamSX3("GW1_CDTPDC")[1]
	Self:lNoTags			:= .F. // Quando montado um XML, é necessário utilizar a função _NoTags
Return

METHOD Localizar() Class GFEITypeOfDocument
	Local cTmp
	Local cQuery
	Local aMQ
	Local nMQ

    If !Empty(self:getTypeOfDocument())
    	aMQ := FWGetSX5("MQ")
    	cTmp := AllTrim(self:getTypeOfDocument())
    	nMQ := aScan(aMQ, { |x| cTmp == AllTrim(x[3]) } )
    	If nMQ > 0
    		self:setTypeOfDocument(PADR(aMQ[nMQ][4],self:getGW1CDTPDC()))
    	Else
    		GV5->(dbSetOrder(1))
	    	If GV5->(dbSeek(xFilial("GV5") + self:getTypeOfDocument()))
	    		self:setTypeOfDocument(PADR(self:getTypeOfDocument(),self:getGW1CDTPDC()))
	    	EndIf
    	EndIf
    EndIf
    
    If Empty(self:getTypeOfDocument())
    	GV5->(dbSetOrder(1))
    	If GV5->(dbSeek(xFilial("GV5") + "NFS"))
    		self:setTypeOfDocument(PADR("NFS",self:getGW1CDTPDC())) 
    	Else
    		cQuery := "SELECT GV5_CDTPDC FROM " + RetSqlName("GV5")
    		cQuery += " WHERE GV5_SENTID = '2' AND D_E_L_E_T_ = ' ' ORDER BY R_E_C_N_O_"
    		
    		cTmp := GetNextAlias()
    		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), cTmp, .F., .T.)
    		(cTmp)->(dbGoTop())
    	
    		self:setTypeOfDocument(PADR((cTmp)->GV5_CDTPDC,self:getGW1CDTPDC()))	
    		
    		(cTmp)->(dbCloseArea())    		
    	EndIf
    EndIf
    
    GV5->(dbSetOrder(1))
    If GV5->(dbSeek(xFilial("GV5") + self:getTypeOfDocument()))
    	IF GV5->GV5_SIT == '2'
    		Self:setStatus(.F.)
    		Self:setMensagem('Tipo de Documento de Carga (' + self:getTypeOfDocument() + ') está inativo (GV5). Ajustar o cadastro para realizar a inclusão do Documento de Carga.')
    		Return
    	Endif
    Else
   		Self:setStatus(.F.)
   		Self:setMensagem('Tipo de Documento de Carga (' + self:getTypeOfDocument() + ') não existe na base de dados (GV5). Ajustar o cadastro para realizar a inclusão do Documento de Carga.')
		Return
    EndIf
    
	Self:setStatus(.T.)
	Self:setMensagem("")
Return 


//-----------------------------------
// Setters
//-----------------------------------
METHOD setTypeOfDocument(cTypeOfDocument) CLASS GFEITypeOfDocument
   Self:cTypeOfDocument := cTypeOfDocument
Return

METHOD setStatus(lStatus) CLASS GFEITypeOfDocument
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFEITypeOfDocument
	if Self:getNoTags()
		Self:cMensagem := _NoTags(cMensagem)
	else
		Self:cMensagem := cMensagem
	EndIf
Return

METHOD setGW1CDTPDC(nGW1CDTPDC) CLASS GFEITypeOfDocument
   Self:nGW1CDTPDC := nGW1CDTPDC
Return

METHOD setNoTags(lNoTags) CLASS GFEITypeOfDocument
   Self:lNoTags := lNoTags
Return

//-----------------------------------
// Getters
//-----------------------------------
METHOD getTypeOfDocument() CLASS GFEITypeOfDocument
Return Self:cTypeOfDocument

METHOD getStatus() CLASS GFEITypeOfDocument
Return Self:lStatus

METHOD getMensagem() CLASS GFEITypeOfDocument
Return Self:cMensagem

METHOD getGW1CDTPDC() CLASS GFEITypeOfDocument
Return Self:nGW1CDTPDC

METHOD getNoTags() CLASS GFEITypeOfDocument
Return Self:lNoTags

