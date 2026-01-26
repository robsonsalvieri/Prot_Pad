#INCLUDE "PROTHEUS.CH"

/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceCfg
Retorna o valor da chave GFETrace no appserver.ini que define o nível de log
no console.log

Valores válidos:
	0=Desabilitado
	1=Informações e erros
	2=Apenas Erros
	3=Verbose

@author  Israel Alcantara Possoli
@since   03/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceCfg(cDefault, lForceLoad)
	Local GFETraceTmp
	Default cDefault := ""
	Default lForceLoad := .F.
	
	GFETraceTmp := GetGlbValue("GFE_TRACE_LEVEL")
	
	If Empty(GFETraceTmp) .OR. lForceLoad
		GFETraceTmp := GetPvProfString("General" , "GFETrace" , cDefault , GetAdv97())
		If Empty(GFETraceTmp)
			GFETraceTmp := "0"
		EndIf
		
		PutGlbValue("GFE_TRACE_LEVEL", GFETraceTmp)
		GFEConout("INFO   ", "[GFETrace] Nível do log: " + GFETraceDsc(GFETraceTmp), .F.)
	EndIf
Return (GFETraceTmp)


/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceOn
Habilita em tempo de execução o GFETrace, mesmo que no AppServer.ini 
esteja desabilitado

Valores válidos:
	0=Desabilitado
	1=Informações e erros
	2=Apenas Erros
	3=Verbose

@author  Israel Alcantara Possoli
@since   26/10/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceOn()
	PutGlbValue("GFE_TRACE_LEVEL", "1")
	
	If !IsBlind()
		MsgInfo("GFETrace habilitado")
	EndIf
	
	GFEConout("INFO   ", "[GFETrace] Habilitado", .F.)
Return 


/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceOff
Desabilita em tempo de execução o GFETrace, mesmo que no AppServer.ini 
esteja habilitado 

Valores válidos:
	0=Desabilitado
	1=Informações e erros
	2=Apenas Erros
	3=Verbose

@author  Israel Alcantara Possoli
@since   26/10/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceOff()
	PutGlbValue("GFE_TRACE_LEVEL", "0")
	
	If !IsBlind()
		MsgInfo("GFETrace desabilitado")
	EndIf
	
	GFEConout("INFO   ", "[GFETrace] Desabilitado", .F.)
Return 


/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceDsc
Retorna a descrição do nível de log apresentado no console.log

Níveis:
	0=Desabilitado
	1=Informações e erros
	2=Apenas Erros
	3=Verbose

@author  Israel Alcantara Possoli
@since   26/10/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceDsc(cLevel)
	If cLevel == "0"
		Return "Desabilitado"
	ElseIf cLevel == "1"
		Return "Informações e erros"
	ElseIf cLevel == "2"
		Return "Apenas erros"
	ElseIf cLevel == "3"
		Return "Verbose (Informações, erros e detalhes)"
	EndIf
Return ("Não informado")


/*----------------------------------------------------------------------------
{Protheus.doc} GFETrace
Grava uma mensagem no console.log

@author  Israel Alcantara Possoli
@since   03/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETrace(cLevel, cMsg, lShowAmbiente)
	Default cLevel := ""
	
	If cLevel $ "13"
		GFEConout("INFO", cMsg, lShowAmbiente)
	EndIf
Return


/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceVerbose
Grava uma mensagem detalhada no console.log

@author  Israel Alcantara Possoli
@since   03/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceVerbose(cLevel, cMsg, lShowAmbiente)
	Default cLevel := ""
	
	If cLevel == "3"	
		GFEConout("VERBOSE", cMsg, lShowAmbiente)
	EndIf
Return


/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceErro
Grava uma mensagem de erro no console.log

@author  Israel Alcantara Possoli
@since   03/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceErro(cLevel, cMsg, lShowAmbiente)
	Default cLevel := ""
	
	If cLevel $ "123"
		GFEConout("ERROR", cMsg, lShowAmbiente)
	EndIf
Return


/*----------------------------------------------------------------------------
{Protheus.doc} GFETraceDebug
Grava uma mensagem no console.log

@author  Israel Alcantara Possoli
@since   03/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFETraceDebug(cMsg, lShowAmbiente)
	GFEConout("DEBUG", cMsg, lShowAmbiente)
Return



/*----------------------------------------------------------------------------
GFEConout

@author  Israel Alcantara Possoli
@since   03/07/2015
@version 1.0
----------------------------------------------------------------------------*/
Function GFEConout(cLevel, cMsg, lShowAmbiente)
	Default cLevel := "INFO"
	Default cMsg := ""
	Default lShowAmbiente := .T.
	
	cLevel := PadR(Upper(cLevel), 7)
	
	If lShowAmbiente
		FWLogMsg("INFO", "LAST", "BusinessObject", "GFEX000", "1", "1", ;
		"[" + DtoC(Date()) + " : " + Time() + "] [" + cLevel + "] [Filial: " + cEmpAnt + "/" + cFilAnt + "] " + cMsg,,, )
		//conout("[" + DtoC(Date()) + " : " + Time() + "] [" + cLevel + "] [Filial: " + cEmpAnt + "/" + cFilAnt + "] " + cMsg)
	Else
		FWLogMsg("INFO", "LAST", "BusinessObject", "GFEX000", "1", "1", ;
		"[" + DtoC(Date()) + " : " + Time() + "] [" + cLevel + "] " + cMsg,,,)
		//conout("[" + DtoC(Date()) + " : " + Time() + "] [" + cLevel + "] " + cMsg)
	EndIf
	
Return