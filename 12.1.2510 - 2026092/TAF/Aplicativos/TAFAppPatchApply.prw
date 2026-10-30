#include 'Protheus.ch'
#include 'apwizard.ch'
#include 'fileIO.ch'
#include "fwbrowse.ch"    
#include 'shell.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFCheckConn
@author  Fabio V Santana
@since   27/10/2017
@version 1
/*/
//-------------------------------------------------------------------
Function TAFCheckConn(cUrl as character)

Local cHeaderRet  as character
Local cPage       as character
Local cStatus     as character
Local cResponse   as character
Local aHeader     as array
Local oHttp       as object
Local lRet        as logical

Default cUrl := ""

cHeaderRet  := ""
cPage       := ""
cStatus     := ""
cResponse   := "200"
aHeader     := {"Content-Type: application/json"}
oHttp       := FWHttpHeaderResponse():New()
lRet        := .F.

//--Faz get na API
cPage := HttpGet(cUrl,,,aHeader,@cHeaderRet) 

//-- Verifica se houve response.
If !Empty(cHeaderRet)
	oHttp:Activate(cHeaderRet)
	//-- Captura o Status do request
	cStatus := oHttp:getStatusCode()
	If ValType(cStatus) == "C"
		If Alltrim(cStatus) == Alltrim(cResponse)
			lRet := .T.
		EndIF
	EndIF
Else
	lRet := .F.
EndIf

//-- Libera a memoria do Objeto
oHttp:GetReason()

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFOnStart
@author  Fabio V Santana
@since   27/10/2017
@version 1
/*/
//-------------------------------------------------------------------
Function TAFOnStart(lApaga as logical)

Local cIniFile as character
Local cOldJobs as character

Default lApaga := .F.

cIniFile :=	getAdv97()
cOldJobs := ""

If lApaga
	DeleteKeyIni( 'OnStart', 'JOBS', cIniFile )
Else
	//verifica a necessidade de incluir HTTPJOB na chave JOBS da seção [OnStart]
	if !( 'HTTPJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile ) )
		
		//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
		cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile )
		cOldJobs += iif( !empty( cOldJobs ) , ',HTTPJOB' , 'HTTPJOB' )
		
		writePProString( 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile )
		
		//crio a chave de RefreshRate apenas se não existir
		if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile ) )
			writePProString( 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile )
		endif
		
	endif
	
	//verifica a necessidade de incluir TAF_CFGJOB na chave JOBS da seção [OnStart]
	if !( 'TAF_CFGJOB' $ getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile ) )
		
		//guardo os jobs já configurados no ambiente e adiciono o HTTPJOB
		cOldJobs := getPvProfString( 'OnStart' , 'JOBS' , '' , cIniFile )
		cOldJobs += iif( !empty( cOldJobs ) , ',TAF_CFGJOB' , 'TAF_CFGJOB' )
		
		writePProString( 'OnStart' , 'JOBS' 		, cOldJobs 		, cIniFile )
		
		//crio a chave de RefreshRate apenas se não existir
		if empty( getPvProfString( 'OnStart' , 'RefreshRate' , '' 	, cIniFile ) )
			writePProString( 'OnStart' , 'RefreshRate' 	, '120'		, cIniFile )
		endif
	
	endif
EndIf

Return
