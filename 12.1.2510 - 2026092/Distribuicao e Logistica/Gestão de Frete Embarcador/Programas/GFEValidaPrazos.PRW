#INCLUDE "PROTHEUS.CH" 

Function GFEValidaPrazos()
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEValidaPrazos
Classe de Funções Relacionadas a tabela de Prazos (GUN)
Esta tabela também é responsável pela Distânica, Quebra e Frete Referência
Generica

@author João Leonardo Schmidt
@since 02/04/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------

CLASS GFEValidaPrazos FROM LongNameClass
	DATA dDataDe
	DATA dDataAte
	DATA cCdRem
	DATA nNrCiOr
	DATA nNrReOr
	DATA cCdDest
	DATA nNrCiDs
	DATA nNrReDs
	DATA cTpTab
	DATA cTpRef
	DATA cSolMod
	DATA cCdTrp
	
	DATA lStatus
	DATA cMensagem
	
	METHOD New() CONSTRUCTOR
	METHOD Validar()
	METHOD Destroy(oObject)
	METHOD ClearData()

	METHOD setDataDe(dDataDe)
	METHOD setDataAte(dDataAte)
	METHOD setCdRem(cCdRem)
	METHOD setNrCiOr(nNrCiOr)
	METHOD setNrReOr(nNrReOr)
	METHOD setCdDest(cCdDest)
	METHOD setNrCiDs(nNrCiDs)
	METHOD setNrReDs(nNrReDs)   
	METHOD setStatus(lStatus)
	METHOD setMensagem(cMensagem)
	METHOD setTpTab(cTpTab)
	METHOD setTpRef(cTpRef)
	METHOD setSolMod(cSolMod)
	METHOD setCdTrp(cCdTrp)
	
	METHOD getDataDe()
	METHOD getDataAte()
	METHOD getCdRem()
	METHOD getNrCiOr()
	METHOD getNrReOr() 
	METHOD getCdDest()
	METHOD getNrCiDs()
	METHOD getNrReDs()  
	METHOD getStatus()
	METHOD getMensagem()
	METHOD getTpTab()
	METHOD getTpRef()
	METHOD getSolMod()
	METHOD getCdTrp()
ENDCLASS

METHOD New() Class GFEValidaPrazos
	Self:ClearData()
Return

METHOD ClearData() Class GFEValidaPrazos
	Self:setDataDe("")
	Self:setDataAte("")
	Self:setCdRem("")
	Self:setNrCiOr(0)
	Self:setNrReOr(0)
	Self:setCdDest("")
	Self:setNrCiDs(0)
	Self:setNrReDs(0)
	Self:setStatus(.F.)
	Self:setMensagem("")
	Self:setTpTab("")
	Self:setTpRef("")
	Self:setSolMod("")
	Self:setCdTrp("")
Return

METHOD Destroy(oObject) CLASS GFEValidaPrazos
	FreeObj(oObject)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Validar - GFEValidaPrazos
Realiza a validação dos dados a serem inseridos na tabela GUN

@author João Leonardo Schmidt
@since 02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Validar() Class GFEValidaPrazos
	Local nCount := 0

	// Validação da Data de Validade
	If (Self:getDataDe() > Self:getDataAte())
		Self:setStatus(.F.)
    	Self:setMensagem("A data de validade final precisa ser maior que a inicial.")
    	Return		
	EndIf 
		
	// Validação da Origem
	nCount := 0
	nCount := If(!Empty(Self:getCdRem()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getNrCiOr()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getNrReOr()), nCount + 1, nCount)
	
	If nCount == 0
		Self:setStatus(.F.)
    	Self:setMensagem("É necessário informar uma Origem.")
    	Return
	EndIf
	
	If nCount > 1
		Self:setStatus(.F.)
    	Self:setMensagem("Só é permitido informar um tipo de Origem: Remetente, Cidade ou Região.")
    	Return
	EndIf
		
	// Validação do Destino
	nCount := 0
	nCount := If(!Empty(Self:getCdDest()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getNrCiDs()), nCount + 1, nCount)
	nCount := If(!Empty(Self:getNrReDs()), nCount + 1, nCount)
	
	If nCount == 0
		Self:setStatus(.F.)
    	Self:setMensagem("É necessário informar um Destino.")
    	Return
	EndIf
	
	If nCount > 1
		Self:setStatus(.F.)
    	Self:setMensagem("Só é permitido informar um tipo de Destino: Destinatário, Cidade ou Região.")
    	Return
	EndIf
	
	If !Empty(Self:getTpTab()) .And. Self:getTpTab() == "4"
		If (Self:getTpRef() == "1" .Or. Self:getTpRef() == "2" .Or. Self:getSolMod() == "2") .And. Empty(Self:getCdTrp())
			Self:setStatus(.F.)
	    	Self:setMensagem("Para as cotações em que o tipo da requisição é cotação ou previsão ou o modo de solicitação da requisição é por Workflow, é obrigatório informar o Transportador.")
	    	Return
		EndIf
	EndIf
	
	Self:setStatus(.T.)
	Self:setMensagem("")
Return

//-----------------------------------
// Setters
//-----------------------------------
METHOD setDataDe(dDataDe) CLASS GFEValidaPrazos
   Self:dDataDe := dDataDe
Return

METHOD setDataAte(dDataAte) CLASS GFEValidaPrazos
   Self:dDataAte := dDataAte
Return

METHOD setCdRem(cCdRem) CLASS GFEValidaPrazos
   Self:cCdRem := cCdRem
Return

METHOD setNrCiOr(nNrCiOr) CLASS GFEValidaPrazos
   Self:nNrCiOr := nNrCiOr
Return

METHOD setNrReOr(nNrReOr) CLASS GFEValidaPrazos
   Self:nNrReOr := nNrReOr
Return

METHOD setCdDest(cCdDest) CLASS GFEValidaPrazos
   Self:cCdDest := cCdDest
Return

METHOD setNrCiDs(nNrCiDs) CLASS GFEValidaPrazos
   Self:nNrCiDs := nNrCiDs
Return

METHOD setNrReDs(nNrReDs) CLASS GFEValidaPrazos
   Self:nNrReDs := nNrReDs
Return

METHOD setStatus(lStatus) CLASS GFEValidaPrazos
   Self:lStatus := lStatus
Return

METHOD setMensagem(cMensagem) CLASS GFEValidaPrazos
   Self:cMensagem := cMensagem
Return

METHOD setTpTab(cTpTab) CLASS GFEValidaPrazos
	Self:cTpTab := cTpTab
Return	

METHOD setTpRef(cTpRef) CLASS GFEValidaPrazos
	Self:cTpRef	:= cTpRef
Return

METHOD setSolMod(cSolMod) CLASS GFEValidaPrazos
	Self:cSolMod := cSolMod
Return

METHOD setCdTrp(cCdTrp) CLASS GFEValidaPrazos
	Self:cCdTrp := cCdTrp
Return

//-----------------------------------
// Getters
//-----------------------------------

METHOD getDataDe() CLASS GFEValidaPrazos
Return Self:dDataDe

METHOD getDataAte() CLASS GFEValidaPrazos
Return Self:dDataAte

METHOD getCdRem() CLASS GFEValidaPrazos
Return Self:cCdRem

METHOD getNrCiOr() CLASS GFEValidaPrazos
Return Self:nNrCiOr

METHOD getNrReOr() CLASS GFEValidaPrazos
Return Self:nNrReOr

METHOD getCdDest() CLASS GFEValidaPrazos
Return Self:cCdDest

METHOD getNrCiDs() CLASS GFEValidaPrazos
Return Self:nNrCiDs

METHOD getNrReDs() CLASS GFEValidaPrazos
Return Self:nNrReDs

METHOD getStatus() CLASS GFEValidaPrazos
Return Self:lStatus

METHOD getMensagem() CLASS GFEValidaPrazos
Return Self:cMensagem

METHOD getTpTab() CLASS GFEValidaPrazos
Return Self:cTpTab

METHOD getTpRef() CLASS GFEValidaPrazos
Return Self:cTpRef

METHOD getSolMod() CLASS GFEValidaPrazos
Return Self:cSolMod

METHOD getCdTrp() CLASS GFEValidaPrazos
Return Self:cCdTrp