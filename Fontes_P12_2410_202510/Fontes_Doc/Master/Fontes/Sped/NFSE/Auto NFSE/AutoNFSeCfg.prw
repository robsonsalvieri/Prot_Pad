#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"   
#INCLUDE "AUTONFSECFG.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} aNfseCfg 
Interface de configuração do auto NFSe

@author Henrique Brugugnoli
@since 04/12/2012
@version 1.0 

/*/ 
//-------------------------------------------------------------- 
function aNfseCfg()   

local oDlg

if !( openNfseCfg() )
	alert(STR0001)
	return
endif                      

DEFINE MSDIALOG oDlg TITLE "" FROM 0,0 TO oMainWnd:NCLIENTHEIGHT-80,oMainWnd:NCLIENTWIDTH-30 STYLE WS_POPUP PIXEL OF oMainWnd

oDlg:lEscClose:= .F.

createConfigBrowse( oDlg )    

ACTIVATE MSDIALOG oDlg CENTERED 

return

//--------------------------------------------------------------
/*/{Protheus.doc} createConfigBrowse
Cria browse de configuracoes

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function createConfigBrowse( oDlg )  

local aConfig		:= {} 

local oBrowse
local oFWBrwColumn 
local oButton

aConfig := getConfiguracao() 

DEFINE FWFORMBROWSE oBrowse DATA ARRAY ARRAY aConfig NO REPORT OF oDlg

	ADD COLUMN oColumn DATA {|| aConfig[oBrowse:At(),1] } TITLE STR0002	SIZE 006 OF oBrowse
	ADD COLUMN oColumn DATA {|| aConfig[oBrowse:At(),2] } TITLE STR0003	SIZE 040 OF oBrowse  
	
	ADD BUTTON oButton TITLE STR0004	ACTION {|| oDlg:end() } OF oBrowse
	ADD BUTTON oButton TITLE STR0005 	ACTION {|| configurar( 3, oDlg, aConfig, "" ), aConfig := getConfiguracao(), BrowseSetArray( oBrowse, aConfig ) } OF oBrowse
	ADD BUTTON oButton TITLE STR0006 	ACTION {|| if(!empty(aConfig),( configurar( 4, oDlg, aConfig, aConfig[oBrowse:At(),1] ), aConfig := getConfiguracao(), BrowseSetArray( oBrowse, aConfig ) ),msgInfo( STR0008 ) ) } OF oBrowse
	ADD BUTTON oButton TITLE STR0007 	ACTION {|| if(!empty(aConfig),( configurar( 5, oDlg, aConfig, aConfig[oBrowse:At(),1] ), aConfig := getConfiguracao(), BrowseSetArray( oBrowse, aConfig ) ),msgInfo( STR0009 ) ) } OF oBrowse
	
ACTIVATE FWFORMBROWSE oBrowse

return

//--------------------------------------------------------------
/*/{Protheus.doc} getConfiguracao
Retorna as configuracoes

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
static function getConfiguracao()

local aConfig	:= {}

NFSECFG->(dbGoTop())

while NFSECFG->(!eof())

	nPos := ascan(aConfig,{|x| x[1] == NFSECFG->ID })
	
	if ( nPos == 0 )
		aAdd(aConfig,{  NFSECFG->ID,;
						  NFSECFG->DESCRICAO,;
					   	{{"0",{}, NFSECFG->LOTE, NFSECFG->THREAD},;
					   	 {"0",{}, NFSECFG->LOTE, NFSECFG->THREAD},;
						 {"0",{}, NFSECFG->LOTE, NFSECFG->THREAD},;
						 {"0",{}, NFSECFG->LOTE, NFSECFG->THREAD}} })
		
		nPos := len(aConfig)
	endif
	
	aConfig[nPos][3][val(allTrim(NFSECFG->PROCESSO))][1] := NFSECFG->ATIVO
	
	aAdd(aConfig[nPos][3][val(allTrim(NFSECFG->PROCESSO))][2],{NFSECFG->EMPRESA,NFSECFG->FILIAL,NFSECFG->SERIE})
	
	aConfig[nPos][3][val(allTrim(NFSECFG->PROCESSO))][3] := NFSECFG->LOTE
	aConfig[nPos][3][val(allTrim(NFSECFG->PROCESSO))][4] := NFSECFG->THREAD

	NFSECFG->(dbSkip())
end

return aConfig 

//--------------------------------------------------------------
/*/{Protheus.doc} configurar
Configura

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//-------------------------------------------------------------- 
static function configurar( nOpcao, oOwner, aConfig, cID )    

local oDlg  
local oPanelForm
local oPanelFormM
local oPanelFormC
local oPanelFormT    
local oBrw1
local oBrw2
local oBrw3

local lWhen 		:= .F.

local nX    
local nOption		:= 1
local nPos
local nTreads := Val(GetPvProfString("AUTO_NFSE","MAXTHREAD","20", GetAdv97() ))

if ( nOpcao == 2 )
	cOpcao := STR0010
elseif ( nOpcao == 3 )
	cOpcao := STR0005   
	lWhen  := .T.
elseif ( nOpcao == 4 )
	cOpcao := STR0006
	lWhen  := .T.
elseif ( nOpcao == 5 )
	cOpcao := STR0007
	lWhen  := .F.
else
	alert( "Opção " + allTrim(str(nOpcao)) + " não existe." )
	return
endif

DEFINE MSDIALOG oDlg TITLE STR0011 + cOpcao FROM 0,0 TO 700,520 PIXEL OF oOwner

oDlg:lEscClose:= .F.

@ 000, 000 MSPANEL oPanelBrw OF oDlg SIZE 000, 000
oPanelBrw:Align 	:= CONTROL_ALIGN_ALLCLIENT
oPanelBrw:nWidth	:= oDlg:nWidth

@ 000, 000 MSPANEL oPanelBtn OF oDlg SIZE 000, 022
oPanelBtn:Align 	:= CONTROL_ALIGN_BOTTOM  
oPanelBtn:nWidth	:= oDlg:nWidth

@ 000, 000 MSPANEL oPanelTit OF oPanelBrw SIZE 000, 000
oPanelTit:nHeight		:= 040
oPanelTit:nWidth		:= oPanelBrw:nWidth 

@ 000, 000 MSPANEL oPanelGeral OF oPanelBrw SIZE 000, 000
oPanelGeral:nTop		:= oPanelTit:nHeight
oPanelGeral:nHeight		:= 040
oPanelGeral:nWidth		:= oPanelBrw:nWidth

@ 000, 000 MSPANEL oPanelTit2 OF oPanelBrw SIZE 000, 000
oPanelTit2:nTop			:= oPanelTit:nHeight + oPanelGeral:nHeight
oPanelTit2:nHeight		:= 040
oPanelTit2:nWidth		:= oPanelBrw:nWidth

@ 000, 000 MSPANEL oPanelProc OF oPanelBrw SIZE 000, 000
oPanelProc:nTop			:= oPanelTit:nHeight + oPanelGeral:nHeight + oPanelTit2:nHeight
oPanelProc:nHeight		:= oDlg:nHeight - ( oPanelTit:nHeight + oPanelGeral:nHeight + oPanelTit2:nHeight )
oPanelProc:nWidth		:= oPanelBrw:nWidth
                                           
setTitleText( oPanelTit, STR0012 )
setTitleText( oPanelTit2, STR0013 ) 

DEFINE FONT oFont BOLD   

aBkpConfig := aClone(aConfig)

if ( nOpcao == 3 )
	
	aIds := {}

	for nX := 1 to len(aConfig)
		aAdd(aIds,aConfig[nX][1])
	next nX                      
	
	if ( !empty(aIds) )
		ASort( aIds,,, {|X,Y| X < Y })
		
		cId := strZero( val( aIds[len(aIds)] ) + 1, 3 )
	else
		cId := "001"
	endif

	aAdd(aConfig,{ cId,space(40),{{"0",{}, 0, 0},{"0",{}, 0, 0},{"0",{}, 0, 0},{"0",{}, 0, 0}} })
	nPos := len(aConfig)
else 
    
	if ( cID == NIL .or. empty(cID) )
		alert("Selecione alguma configuração")
		return
	endif
	
	nPos := ascan(aConfig,{|x| x[1] == cID })
	
endif

//Geral
@ 005,010 SAY STR0014 SIZE 270,010 FONT oFont PIXEL OF oPanelGeral
@ 003,078 GET oNome VAR aConfig[nPos][2] WHEN lWhen OF oPanelGeral SIZE 50, 010 PIXEL 
@ 005,133 SAY STR0015 SIZE 270,010 FONT oFont PIXEL OF oPanelGeral
@ 003,215 GET oThead VAR nTreads WHEN lWhen PICTURE "@E 999" OF oPanelGeral SIZE 15, 010 PIXEL

//Processos

@ 000, 000 FOLDER oFolder OF oPanelProc ITEMS STR0016,STR0017,STR0018,STR0019 PIXEL OPTION nOption SIZE 000,000
oFolder:align := CONTROL_ALIGN_ALLCLIENT        

oFolder:aDialogs[1]:nHeight	:= oPanelProc:nHeight - 15
oFolder:aDialogs[1]:nWidth	:= oPanelProc:nWidth 

oFolder:aDialogs[2]:nHeight	:= oPanelProc:nHeight - 15
oFolder:aDialogs[2]:nWidth	:= oPanelProc:nWidth 

oFolder:aDialogs[3]:nHeight	:= oPanelProc:nHeight - 15
oFolder:aDialogs[3]:nWidth	:= oPanelProc:nWidth 

oFolder:aDialogs[4]:nHeight	:= oPanelProc:nHeight - 15
oFolder:aDialogs[4]:nWidth	:= oPanelProc:nWidth 

formTransmissao   ( oFolder:aDialogs[1], aConfig, nPos, nOpcao, lWhen, oDlg )
formMonitoramento ( oFolder:aDialogs[2], aConfig, nPos, nOpcao, lWhen, oDlg )
formCancelamento  ( oFolder:aDialogs[3], aConfig, nPos, nOpcao, lWhen, oDlg )
formTodosProcessos( oFolder:aDialogs[4], aConfig, nPos, nOpcao, lWhen, oDlg )      

@ 003, 180 BUTTON oBtn2 PROMPT STR0020 SIZE 035,013 ACTION ( if(configOk( aConfig, nPos , nTreads ), if(gravaConfig( aConfig, cID, nPos, nOpcao, @nTreads ),oDlg:end(),),) ) OF oPanelBtn PIXEL
@ 003, 220 BUTTON oBtn1 PROMPT STR0021 SIZE 035,013 ACTION ( oDlg:end() ) OF oPanelBtn PIXEL  

ACTIVATE MSDIALOG oDlg CENTERED 

return  

//--------------------------------------------------------------
/*/{Protheus.doc} configOk
Verifica se todas as informacoes estao preenchidas

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function configOk( aConfig, nPos , nTreads )

local nX   

local lConfigProc	:= .F.
Default nTreads := 20

if ( empty(nTreads) )
	alert("Deve ser informado o número de theads a ser usado na configuração.")
return .F.
		
elseif (nTreads > 998 )
	alert("Número maximo de theads atingido..")
return .F.

elseif (nTreads < 1 )
	alert("Número minimo de theads atingido..")
return .F.
endif 

if ( empty(aConfig[nPos][2]) )
	alert("Deve ser informado o nome da configuração.")
	return .F.
endif 

for nX := 1 to len(aConfig[nPos][3])

	if ( aConfig[nPos][3][nX][1] == "1" )  
	
		lConfigProc := .T.                     
		
		if ( nX == 1 )
			cProcesso := STR0016
		elseif ( nX == 2 ) 
			cProcesso := STR0017
		elseif ( nX == 3 )
			cProcesso := STR0018
		elseif ( nX == 4 )
			cProcesso := STR0022
		else
			cProcesso := ""	
		endif		
		
		if empty(aConfig[nPos][3][nX][2])      		
			alert("Deve ser informado as empresas, filias e séries que o processo de "+cProcesso+" irá utilizar.")
			return .F.
		elseif aConfig[nPos][3][nX][3] == 0
			alert("O campo lote do processo "+cProcesso+" deve ser informado.")
			return .F. 
		elseif aConfig[nPos][3][nX][4] == 0
			alert("O campo processos do processo "+cProcesso+" deve ser informado.")
			return .F.
		endif         
		
	elseif ( !lConfigProc )
		lConfigProc := .F.
	endif

next nX  

if ( !lConfigProc )
	alert("Deve ser configurado ao menos um processo.")
	return .F.
endif

return .T.

//--------------------------------------------------------------
/*/{Protheus.doc} gravaConfig
Faz a gravacao da configuracao

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function gravaConfig( aConfig, cID, nPos, nOpcao , nTreads )
    
local nY
local nZ   

local lGrava	:= .T.


if nTreads > 0
	WritePProString('AUTO_NFSE','MAXTHREAD', cValToChar(nTreads), GetAdv97())
EndIf


if ( nOpcao == 3 .and. existConfig( aConfig, cID, nPos ) )	 

	for nY := 1 to len(aConfig[nPos][3])       
		
		for nZ := 1 to len(aConfig[nPos][3][nY][2])

			if Empty(aConfig[nPos][3][nY][2][nZ][1])
				LOOP
			Else
			recLock("NFSECFG",.T.)
			NFSECFG->ID			:= aConfig[nPos][1]
			NFSECFG->EMPRESA	:= aConfig[nPos][3][nY][2][nZ][1]
			NFSECFG->FILIAL		:= aConfig[nPos][3][nY][2][nZ][2]
			NFSECFG->SERIE		:= aConfig[nPos][3][nY][2][nZ][3]
			NFSECFG->PROCESSO	:= allTrim(str(nY))
			NFSECFG->LOTE		:= aConfig[nPos][3][nY][3]
			NFSECFG->THREAD		:= aConfig[nPos][3][nY][4]
			NFSECFG->DESCRICAO	:= aConfig[nPos][2]
			NFSECFG->ATIVO		:= aConfig[nPos][3][nY][1]
			NFSECFG->(msUnLock())  
			EndIf
		next nZ
	
	next nY

elseif ( nOpcao == 4 .and. existConfig( aConfig, cID, nPos ) )

	NFSECFG->(dbGoTop())
	
	while NFSECFG->(!eof())
	
		if ( NFSECFG->ID == cID )
			recLock("NFSECFG",.F.)
			NFSECFG->(dbDelete())
			NFSECFG->(msUnLock()) 
		endif
	
		NFSECFG->(dbSkip())
	end    
	
	for nY := 1 to len(aConfig[nPos][3])       
		
		for nZ := 1 to len(aConfig[nPos][3][nY][2])

			if Empty(aConfig[nPos][3][nY][2][nZ][1]) 
				LOOP
			Else
			recLock("NFSECFG",.T.)
			NFSECFG->ID			:= aConfig[nPos][1]
			NFSECFG->EMPRESA	:= aConfig[nPos][3][nY][2][nZ][1]
			NFSECFG->FILIAL		:= aConfig[nPos][3][nY][2][nZ][2]
			NFSECFG->SERIE		:= aConfig[nPos][3][nY][2][nZ][3]
			NFSECFG->PROCESSO	:= allTrim(str(nY))
			NFSECFG->LOTE		:= aConfig[nPos][3][nY][3]
			NFSECFG->THREAD		:= aConfig[nPos][3][nY][4]
			NFSECFG->DESCRICAO	:= aConfig[nPos][2]
			NFSECFG->ATIVO		:= aConfig[nPos][3][nY][1]
			NFSECFG->(msUnLock())  
			EndIf  
			
		next nZ
	
	next nY	

elseif ( nOpcao == 5 )
	
	NFSECFG->(dbGoTop())
	
	while NFSECFG->(!eof())
	
		if ( NFSECFG->ID == cID )			
			recLock("NFSECFG",.F.)
			NFSECFG->(dbDelete())
			NFSECFG->(msUnLock())
		endif
	
		NFSECFG->(dbSkip())
	end
	
else
	lGrava := .F.
endif

return lGrava

//--------------------------------------------------------------
/*/{Protheus.doc} existConfig
Verifica se a configuracao que esta sendo grava ja existe

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function existConfig( aConfig, cID, nPos )

local lExist	:= .T.  

NFSECFG->(dbGoTop())

while NFSECFG->(!eof())

	if ( cID == NFSECFG->ID )
		NFSECFG->(dbSkip())
		loop
	else
	
		if ( aConfig[nPos][3][val(allTrim(NFSECFG->PROCESSO))][1] == "1" )
		
			aEmpresa := aConfig[nPos][3][val(allTrim(NFSECFG->PROCESSO))][2]
		
			nFind := ascan(aEmpresa,{|x| allTrim(x[1]) == allTrim(NFSECFG->EMPRESA) .and. allTrim(x[2]) == allTrim(NFSECFG->FILIAL) .and. allTrim(x[3]) == allTrim(NFSECFG->SERIE) })
			
			if ( nFind > 0 )
				alert("A configuração '"+ allTrim(aConfig[nPos][2]) +"' feita já existe para a configuração '"+allTrim(NFSECFG->DESCRICAO)+"'." )
				lExist := .F.
				exit
			else
				lExist := .T.
			endif
			
		endif
	
	endif

	NFSECFG->(dbSkip())
end

return lExist

//--------------------------------------------------------------
/*/{Protheus.doc} formTransmissao
Formulario de transmissao

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function formTransmissao( oPForm, aConfig, nPos, nOpcao, lWhen, oDlg )  

local aEmpresa	:= {}   

local oBrowse

@ 005,010 SAY STR0023 SIZE 270,010 FONT oFont PIXEL OF oPForm
@ 004,045 COMBOBOX oAtivo VAR aConfig[nPos][3][1][1] ITEMS {STR0026 ,STR0027} WHEN lWhen SIZE 040, 010 OF oPForm PIXEL
oAtivo:nAt := val(aConfig[nPos][3][1][1]) + 1

@ 025,010 SAY STR0024 SIZE 270,010 FONT oFont PIXEL OF oPForm
@ 024,045 GET oLote VAR aConfig[nPos][3][1][3] WHEN lWhen PICTURE "@E 999" OF oPForm SIZE 020, 010 PIXEL 

@ 045,010 SAY STR0025 SIZE 270,010 FONT oFont PIXEL OF oPForm
@ 044,045 GET oThread VAR aConfig[nPos][3][1][4] WHEN lWhen PICTURE "@E 9" OF oPForm SIZE 020, 010 PIXEL 

@ 000, 000 MSPANEL oPanelEmp OF oPForm SIZE 000, 000 //COLORS CLR_YELLOW,CLR_GRAY
oPanelEmp:nHeight		:= oPForm:nHeight - 190
oPanelEmp:nWidth		:= oPForm:nWidth - 15
oPanelEmp:nTop			:= 120
oPanelEmp:nLeft			:= 5  

aEmpresa := aConfig[nPos][3][1][2]

DEFINE FWFORMBROWSE oBrowse DATA ARRAY ARRAY aEmpresa NO REPORT OF oPanelEmp

	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),1],) } TITLE STR0028		SIZE 010 OF oBrowse
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),2],) } TITLE STR0029		SIZE 010 OF oBrowse  
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),3],) } TITLE STR0030		SIZE 010 OF oBrowse  
	
	if ( nOpcao == 3 .or. nOpcao == 4 )
		ADD BUTTON oButton TITLE STR0005 	ACTION {|| configEmpresa( 3, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 1, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0006 	ACTION {|| configEmpresa( 4, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 1, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0007 	ACTION {|| configEmpresa( 5, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 1, nPos ) } OF oBrowse
	endif		
	
ACTIVATE FWFORMBROWSE oBrowse

return  
//--------------------------------------------------------------
/*/{Protheus.doc} formMonitoramento
Formulario de monitoramento

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function formMonitoramento( oPFormM, aConfig, nPos, nOpcao, lWhen, oDlg )  

local aEmpresa	:= {}

local oBrowse

@ 005,010 SAY STR0023 SIZE 270,010 FONT oFont PIXEL OF oPFormM
@ 004,045 COMBOBOX oAtivo VAR aConfig[nPos][3][2][1] WHEN lWhen ITEMS {STR0026, STR0027} SIZE 040, 010 OF oPFormM PIXEL
oAtivo:nAt := val(aConfig[nPos][3][2][1]) + 1

@ 025,010 SAY STR0024 SIZE 270,010 FONT oFont PIXEL OF oPFormM
@ 024,045 GET oLote VAR aConfig[nPos][3][2][3] WHEN lWhen PICTURE "@E 999" OF oPFormM SIZE 020, 010 PIXEL 

@ 045,010 SAY STR0025 SIZE 270,010 FONT oFont PIXEL OF oPFormM
@ 044,045 GET oThread VAR aConfig[nPos][3][2][4] WHEN lWhen PICTURE "@E 9" OF oPFormM SIZE 020, 010 PIXEL 

@ 000, 000 MSPANEL oPEmp OF oPFormM SIZE 000, 000 //COLORS CLR_YELLOW,CLR_GRAY
oPEmp:nHeight		:= oPFormM:nHeight - 190
oPEmp:nWidth		:= oPFormM:nWidth - 15
oPEmp:nTop			:= 120
oPEmp:nLeft			:= 5  

aEmpresa := aConfig[nPos][3][2][2]

DEFINE FWFORMBROWSE oBrowse DATA ARRAY ARRAY aEmpresa NO REPORT OF oPEmp

	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),1],) } TITLE STR0028	SIZE 010 OF oBrowse
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),2],) } TITLE STR0029		SIZE 010 OF oBrowse
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),3],) } TITLE STR0030		SIZE 010 OF oBrowse
	
	if ( nOpcao == 3 .or. nOpcao == 4 )
		ADD BUTTON oButton TITLE STR0005 	ACTION {|| configEmpresa( 3, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 2, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0006 	ACTION {|| configEmpresa( 4, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 2, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0007 	ACTION {|| configEmpresa( 5, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 2, nPos ) } OF oBrowse
	endif
	// refresh oBrowse		
	oBrowse:Refresh(.T.)	 
ACTIVATE FWFORMBROWSE oBrowse

return 

//--------------------------------------------------------------
/*/{Protheus.doc} formCancelamento
Formulario de cancelamento

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function formCancelamento( oPFormC, aConfig, nPos, nOpcao, lWhen, oDlg )  

local aEmpresa	:= {}

local oBrowse

@ 005,010 SAY STR0023 SIZE 270,010 FONT oFont PIXEL OF oPFormC
@ 004,045 COMBOBOX oAtivo VAR aConfig[nPos][3][3][1] WHEN lWhen ITEMS {STR0026, STR0027} SIZE 040, 010 OF oPFormC PIXEL
oAtivo:nAt := val(aConfig[nPos][3][3][1]) + 1

@ 025,010 SAY STR0024 SIZE 270,010 FONT oFont PIXEL OF oPFormC
@ 024,045 GET oLote VAR aConfig[nPos][3][3][3] WHEN lWhen PICTURE "@E 999" OF oPFormC SIZE 020, 010 PIXEL 

@ 045,010 SAY STR0025 SIZE 270,010 FONT oFont PIXEL OF oPFormC
@ 044,045 GET oThread VAR aConfig[nPos][3][3][4] WHEN lWhen PICTURE "@E 9" OF oPFormC SIZE 020, 010 PIXEL 

@ 000, 000 MSPANEL oPEmp2 OF oPFormC SIZE 000, 000 //COLORS CLR_YELLOW,CLR_GRAY
oPEmp2:nHeight		:= oPFormC:nHeight - 190
oPEmp2:nWidth		:= oPFormC:nWidth - 15
oPEmp2:nTop			:= 120
oPEmp2:nLeft		:= 5  

aEmpresa := aConfig[nPos][3][3][2]

DEFINE FWFORMBROWSE oBrowse DATA ARRAY ARRAY aEmpresa NO REPORT OF oPEmp2

	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),1],) } TITLE STR0028	SIZE 010 OF oBrowse
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),2],) } TITLE STR0029	SIZE 010 OF oBrowse  
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),3],) } TITLE STR0030	SIZE 010 OF oBrowse  
	
	if ( nOpcao == 3 .or. nOpcao == 4 )
		ADD BUTTON oButton TITLE STR0005 	ACTION {|| configEmpresa( 3, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 3, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0006 	ACTION {|| configEmpresa( 4, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 3, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0007 	ACTION {|| configEmpresa( 5, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 3, nPos ) } OF oBrowse
	endif		
	// refresh oBrowse		
	oBrowse:Refresh(.T.)	 	
ACTIVATE FWFORMBROWSE oBrowse

return 

//--------------------------------------------------------------
/*/{Protheus.doc} formMonitoramento
Formulario de monitoramento

@author Henrique Brugugnoli
@since 05/12/2012
@version 1.0 

/*/
//--------------------------------------------------------------
static function formTodosProcessos( oPFormT, aConfig, nPos, nOpcao, lWhen, oDlg )  

local aEmpresa	:= {}   

local oBrowse

@ 005,010 SAY STR0023 SIZE 270,010 FONT oFont PIXEL OF oPFormT
@ 004,045 COMBOBOX oAtivo VAR aConfig[nPos][3][4][1] ITEMS {STR0026, STR0027} WHEN lWhen SIZE 040, 010 OF oPFormT PIXEL
oAtivo:nAt := val(aConfig[nPos][3][4][1]) + 1

@ 025,010 SAY STR0024 SIZE 270,010 FONT oFont PIXEL OF oPFormT
@ 024,045 GET oLote VAR aConfig[nPos][3][4][3] WHEN lWhen PICTURE "@E 999" OF oPFormT SIZE 020, 010 PIXEL 

@ 045,010 SAY STR0025 SIZE 270,010 FONT oFont PIXEL OF oPFormT
@ 044,045 GET oThread VAR aConfig[nPos][3][4][4] WHEN lWhen PICTURE "@E 9" OF oPFormT SIZE 020, 010 PIXEL 

@ 000, 000 MSPANEL oPanelEmp OF oPFormT SIZE 000, 000 //COLORS CLR_YELLOW,CLR_GRAY
oPanelEmp:nHeight		:= oPFormT:nHeight - 190
oPanelEmp:nWidth		:= oPFormT:nWidth - 15
oPanelEmp:nTop			:= 120
oPanelEmp:nLeft			:= 5  

aEmpresa := aConfig[nPos][3][4][2]

DEFINE FWFORMBROWSE oBrowse DATA ARRAY ARRAY aEmpresa NO REPORT OF oPanelEmp

	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),1],) } TITLE STR0028	SIZE 010 OF oBrowse
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),2],) } TITLE STR0029		SIZE 010 OF oBrowse  
	ADD COLUMN oColumn DATA {|| Iif(Len(aEmpresa) > 0, aEmpresa[oBrowse:At(),3],) } TITLE STR0030		SIZE 010 OF oBrowse  
	
	if ( nOpcao == 3 .or. nOpcao == 4 )
		ADD BUTTON oButton TITLE STR0005 	ACTION {|| configEmpresa( 3, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 4, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0006 	ACTION {|| configEmpresa( 4, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 4, nPos ) } OF oBrowse
		ADD BUTTON oButton TITLE STR0007 	ACTION {|| configEmpresa( 5, oDlg, if(!empty(aEmpresa),aEmpresa[oBrowse:At()],{}), aEmpresa, oBrowse:At(), oBrowse, aConfig, 4, nPos ) } OF oBrowse
	endif		
	
ACTIVATE FWFORMBROWSE oBrowse
	// refresh oBrowse		
	oBrowse:Refresh(.T.)	 
return  

//--------------------------------------------------------------
/*/{Protheus.doc} configurar
Configura

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//-------------------------------------------------------------- 
static function configEmpresa( nOpcao, oOwner, aEmpresa, aEmpresas, nPos, oBrowse, aConfigs, nProc, nPosCfg )  

local aConfig := aConfigs 
local nX 
local oDlg
local lAchou := .F.    

local cTMP	:= ""

if ( nOpcao == 3 )
	cOpcao := STR0005
	lWhen  := .T.
elseif ( nOpcao == 4 )
	cOpcao := STR0006
	lWhen  := .T.
elseif ( nOpcao == 5 )
	cOpcao := STR0007
	lWhen  := .F.
else
	alert( "Opção " + allTrim(str(nOpcao)) + " não existe." )
	return
endif

DEFINE MSDIALOG oDlg TITLE STR0031 + cOpcao FROM 0,0 TO 200,250 PIXEL OF oOwner

oDlg:lEscClose:= .F.

@ 000, 000 MSPANEL oPanelBrw OF oDlg SIZE 000, 000
oPanelBrw:Align 	:= CONTROL_ALIGN_ALLCLIENT
oPanelBrw:nWidth	:= oDlg:nWidth

@ 000, 000 MSPANEL oPanelBtn OF oDlg SIZE 000, 022
oPanelBtn:Align 	:= CONTROL_ALIGN_BOTTOM  
oPanelBtn:nWidth	:= oDlg:nWidth

DEFINE FONT oFont BOLD    

//aBkpEmpresas := aClone(aEmpresas)
                        
if ( nOpcao == 3 )

		for nX := 1 To len(aEmpresas) 		
			 if ( Empty(aEmpresas[nX][1]) .or. Empty(aEmpresas[nX][2]) .or. Empty(aEmpresas[nX][3]) )
			  lAchou := .T. 
			 endif			
		next		
		
		if !lAchou
			aAdd(aEmpresas,{space(4),space(4),space(4)})
		endif
	
	nPos := len(aEmpresas)

else

	if ( empty(aEmpresas) )
		alert("Deve ser selcionado um registro para executar esta opção.")
		return
	endif
	
endif   

aEmpresas[nPos][1] 	:= padr(aEmpresas[nPos][1],30)
aEmpresas[nPos][2] 	:= padr(aEmpresas[nPos][2],30)
aEmpresas[nPos][3]	:= padr(aEmpresas[nPos][3],3)

@ 005,010 SAY STR0028 SIZE 270,010 FONT oFont PIXEL OF oPanelBrw
@ 003,038 GET oEmpresa VAR aEmpresas[nPos][1] WHEN lWhen OF oPanelBrw SIZE 030, 010 PIXEL
oEmpresa:bF3 := {|| aEmpresas[nPos][1] := FWPesqSM0("M0_CODIGO"), oEmpresa:refresh() }

@ 025,010 SAY STR0029 SIZE 270,010 FONT oFont PIXEL OF oPanelBrw
@ 023,038 GET oFilial VAR aEmpresas[nPos][2] WHEN lWhen OF oPanelBrw SIZE 030, 010 PIXEL  
oFilial:bF3 := {|| aEmpresas[nPos][2] := FWPesqSM0("M0_CODFIL",aEmpresas[nPos][1]), oFilial:refresh() } 

@ 045,010 SAY STR0030 SIZE 270,010 FONT oFont PIXEL OF oPanelBrw
@ 043,038 GET oSerie VAR aEmpresas[nPos][3] WHEN lWhen OF oPanelBrw SIZE 030, 010 PIXEL  

aBkpEmpresas := aClone(aEmpresas)

@ 003, 045 BUTTON oBtn2 PROMPT STR0020 SIZE 035,013 ACTION ( if(validEmpresa( @aEmpresas, nPos, nOpcao, @aConfig, nProc, nPosCfg ),(oDlg:end(),BrowseSetArray( oBrowse, @aEmpresas ) ),.T.) ) OF oPanelBtn PIXEL
if  nOpcao <> 4 
	@ 003, 085 BUTTON oBtn1 PROMPT STR0021 SIZE 035,013 ACTION ( cancelaEmpresa( @aEmpresas, @aBkpEmpresas, aConfig,nPosCfg, nProc , @nPos , nOpcao ),BrowseSetArray( oBrowse, @aEmpresas ), oDlg:end() ) OF oPanelBtn PIXEL  
endif
ACTIVATE MSDIALOG oDlg CENTERED 

return                                                          
         
//--------------------------------------------------------------
/*/{Protheus.doc} cancelaEmpresa
Cancela o cadastro de empresa + filial e serie

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
static function cancelaEmpresa( aEmpresas, aBkpEmpresas, aConfig, nPosCfg, nProc , nPos , nOpcao)

//if len (aConfig[nPosCfg][3][nProc][2]) > 0
//	Adel(aConfig[nPosCfg][3][nProc][2],nPos)
//	Asize(aConfig[nPosCfg][3][nProc][2],Len(aConfig[nPosCfg][3][nProc][2])-1)
//endif

aBkpEmpresas[nPos][1]:= space(4)
aBkpEmpresas[nPos][2]:= space(4)
aBkpEmpresas[nPos][3]:= space(4)
aEmpresas := aClone(aBkpEmpresas)

If len (aBkpEmpresas) > 1	.And. nOpcao == 3
Adel(aEmpresas,nPos)
Asize(aEmpresas,Len(aEmpresas)-1)
	if nPos > 1
		nPos--
	endIF
EndIf



return

//--------------------------------------------------------------
/*/{Protheus.doc} validEmpresa
Valida se ja nao foi incluida a mesma empresa + filial e serie

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
static function validEmpresa( aEmpresas, nPos , nOpcao, aConfig, nProc, nPosCfg )

local nX
local nY
	local nProcesso := 0
local nCount	:= 0  

local lValid	:= .T.  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida Array em tela de empresa/filial/serie se estão preenchidos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if ( empty(aEmpresas[nPos][1]) .or. empty(aEmpresas[nPos][2]) .or. empty(aEmpresas[nPos][3]) ) .And. nOpcao <> 5
		alert("Todos os campos devem ser preenchidos.")
		lValid := .F.
	endif

//-Excluir
	if ( nOpcao == 5 )
		aBkpEmpresas[nPos][1]:= space(4)
		aBkpEmpresas[nPos][2]:= space(4)
		aBkpEmpresas[nPos][3]:= space(4)
		
		//Proteção do MBrowse para array Nil
		aConfig[nPosCfg][3][nProc][2] := aclone(aBkpEmpresas)
		
		if nPos == 1
			Adel(aEmpresas,nPos)
			Asize(aEmpresas,Len(aEmpresas))
			aEmpresas := aClone(aBkpEmpresas)
			return .T.
		elseif len(aEmpresas) == 1
			Adel(aEmpresas,nPos)
			Asize(aEmpresas,Len(aEmpresas))
			aEmpresas := aClone(aBkpEmpresas)
			return .T.
		else
			Adel(aEmpresas,nPos)
			Asize(aEmpresas,Len(aEmpresas)-1)
			aEmpresas := aClone(aBkpEmpresas)
			return .T.
		endif
	
		if len(aEmpresas) > 1
			BrowseSetArray( oBrowse, aArray )
		Endif
	
	endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida Array em tela de empresa/filial/serie iguais no arquivo já gravado
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nProc <> 4 .And. ( lValid )
		for nX := 1 to len(aEmpresas)
		
			if ( alltrim(aEmpresas[nX][1]) == alltrim(aEmpresas[nPos][1]) .and. alltrim(aEmpresas[nX][2]) == alltrim(aEmpresas[nPos][2]) .and. alltrim(aEmpresas[nX][3]) == alltrim(aEmpresas[nPos][3]) )
				nCount ++
			endif
			
			if ( nCount > 1 )
				lValid := .F.
				alert("Você ja possui essa Empresa, Filial e Série cadastrados para este processo.")
				exit
			endif
		
		next nX
	
		if ( lValid )
	
			for nX := 1 to len(aConfig)
		
				if ( nX == len(aConfig) )
					exit
				endif
			
				nCount := 0
			
				for nY := 1 to len(aConfig[nX][3][nProc][2])
		
					if (  Alltrim (aConfig[nX][3][nProc][2][nY][1]) ==  Alltrim (aEmpresas[nPos][1]) .and.  Alltrim (aConfig[nX][3][nProc][2][nY][2]) ==  Alltrim (aEmpresas[nPos][2]) .and.  Alltrim (aConfig[nX][3][nProc][2][nY][3]) ==  Alltrim (aEmpresas[nPos][3]) )
						nCount ++
					endif
				
					if ( nCount == 1 )
						lValid := .F.
						alert("Você ja possui essa Empresa, Filial e Série cadastrados para este processo em outra configuração.")
						exit
					endif
			
				next nY
			
				if ( !lValid )
					exit
				endif
		
			next nX
	
		endif
	Endif


	if ( lValid )
		nX := 1
		if nProc == 4
			for nProcesso := 1 to 4
			
				if ( nX == len(aEmpresas)  .and. (nProcesso == nProc ))// Primeiro registro no Array a empresas
					exit
				endif
			
			
				if ( len(aConfig[1][3][nProcesso][2]) > 0 )
		//-----------------------------------------------------------------											
					if nProcesso <> nProc
						nCount := 0
						for nY := 1 to len(aConfig[1][3][nProcesso][2])
												
							if ( Alltrim (aConfig[1][3][nProcesso][2][nY][1]) == Alltrim (aEmpresas[nPos][1]) .and. Alltrim (aConfig[1][3][nProcesso][2][nY][2]) == Alltrim (aEmpresas[nPos][2]) .and. Alltrim (aConfig[1][3][nProcesso][2][nY][3]) == Alltrim (aEmpresas[nPos][3]) )
								nCount ++
							endif
										
							if ( nCount > 0 )
								lValid := .F.
								alert("Você ja possui essa Empresa, Filial e Série cadastrados para este processo em outra configuração.")
								exit
							endif
						next nY
							
					elseif nProcesso == nProc
												
						for nX := 1 to len(aEmpresas)
	
								if ( alltrim(aEmpresas[nX][1]) == alltrim(aEmpresas[nPos][1]) .and. alltrim(aEmpresas[nX][2]) == alltrim(aEmpresas[nPos][2]) .and. alltrim(aEmpresas[nX][3]) == alltrim(aEmpresas[nPos][3]) )
									nCount ++
								endif
										
								if ( nCount > 1 )
									lValid := .F.
									alert("Você ja possui essa Empresa, Filial e Série cadastrados para este processo.")
									exit
								endif
								
						next nX
						
						if ( lValid )
							nCount := 0
							for nY := 1 to len(aConfig[1][3][nProcesso][2])
										
								if ( nX == len(aConfig[1][3][nProcesso][2]) .and. (nProcesso == nProc ))// Primeiro registro no Array a empresas
									exit
								endif
										
																													
								if ( Alltrim (aConfig[1][3][nProcesso][2][nY][1]) == Alltrim (aEmpresas[nPos][1]) .and. Alltrim (aConfig[1][3][nProcesso][2][nY][2]) == Alltrim (aEmpresas[nPos][2]) .and. Alltrim (aConfig[1][3][nProcesso][2][nY][3]) == Alltrim (aEmpresas[nPos][3]) )
									nCount ++
								endif
											
								if ( nCount > 0 )
									lValid := .F.
									alert("Você ja possui essa Empresa, Filial e Série cadastrados para este processo em outra configuração.")
									exit
								endif
							next nY
						endif
					endif
		//-----------------------------------------------------------------						
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valida a existencia de duplicidade de configuração
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					if ( !lValid )
						exit
					endif
				endif
					
			next nProcesso
		endif
	endif

	if ( lValid )
		aConfig[nPosCfg][3][nProc][2] := aclone(aEmpresas)
	else
		aBkpEmpresas[nPos][1]:= space(4)
		aBkpEmpresas[nPos][2]:= space(4)
		aBkpEmpresas[nPos][3]:= space(4)
		aEmpresas := aClone(aBkpEmpresas)
	endif


return lValid

//--------------------------------------------------------------
/*/{Protheus.doc} OpenNfseCfg
Funcao de abertura/geracao da tabela de configuracao NFSECFG

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
Function OpenNfseCfg()

Local cFileName		:= "NFSECFG"
Local cStartPath	:= GetSrvProfString("Startpath","")
Local cFile			:= cStartPath + cFileName + GetDbExtension()//cStartPath + cFileName + ".dbf"
Local cIndex		:= cStartPath + cFileName + RetIndExt()//cStartPath + cFileName + ".cdx"

If !File( cFile ) 

	If File( cIndex )

		if( FErase( cIndex ) < 0 )
			autoNfseMsg( "Erro na Exclusao do indice   " + alltrim(str(ferror())) + " )" )
			return .F.
		endif		
			
	Endif

	GeraNfseCfg( cFileName, .T., .T. )
	
elseif !File( cIndex )

	GeraNfseCfg( cFileName, .F., .T. )
	
Endif

Return( LeNfseCfg( cFileName ) )

//--------------------------------------------------------------
/*/{Protheus.doc} LeNfseCfg
Funcao de leitura da tabela de configuracao NFSECFG

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
Static Function LeNfseCfg( cFileName )

Local lRetorno	:= .T.
   
If !( Select( cFileName ) > 0 )

	dbUseArea( .T., DBSETDRIVER(), cFileName, cFileName, .T., .F. ) 

Endif

If Select( cFileName ) > 0 //.and. TCCanOpen("NFSECFG","NFSECFG")

	dbSelectArea( cFileName )
	dbSetIndex( cFileName )
	dbSetOrder(1)

Else

	lRetorno := .F.

Endif

Return( lRetorno )

//--------------------------------------------------------------
/*/{Protheus.doc} GeraNfseCfg
Funcao de geracao da tabela de configuracao NFSECFG

@param lCreatFile		Cria tabela
@param lCreatIndex		Cria indice

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
Static Function GeraNfseCfg( cFileName, lCreatFile, lCreatIndex )

Local aStruct	:= tableStruct()
Local aIndex	:= indexStruct()

Default lCreatFile	:= .F.
Default lCreatIndex	:= .F.

If lCreatFile
	dbCreate( cFileName, aStruct, DBSETDRIVER())
	autoNfseMsg( "Criando arquivo -> Function GeraNFseCfg" )
Endif

dbUseArea( .T., DBSETDRIVER(), cFileName, cFileName, .F., .F. ) 

If lCreatIndex        

	dbCreateIndex( cFileName, aIndex[1,1], { || aIndex[1,1] } ,.F. ) 
	
	(cFileName)->(dbCloseArea())
	dbUseArea( .T., DBSETDRIVER(), cFileName, cFileName, .T., .F. ) 
	autoNfseMsg( "Criando indice -> Function GeraNFseCfg" )
	
Endif

Return { aStruct, aIndex }

//--------------------------------------------------------------
/*/{Protheus.doc} tableStruct
Retorna a estrutura da tabela

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
static function tableStruct()

Local aStruct	:= {	{"ID"		,"C"	,003,0},;		//ID do processo
						{"EMPRESA"	,"C"	,030,0},;		//Codigo da empresa
						{"FILIAL"	,"C"	,030,0},;		//Filial da empresa
						{"SERIE"	,"C"	,003,0},;		//Serie da NFS-e 
						{"PROCESSO"	,"C"	,001,0},;		//Codigo do processo: 1-Transmissao, 2-Monitoramento ou 3-Cancelamento
						{"LOTE"		,"N"	,003,0},;		//Quantidade de NFS-e's por Lote
						{"THREAD"	,"N"	,002,0},;		//Quantidade de threads por processo 
						{"DESCRICAO","C"	,040,0},;		//Quantidade de threads por processo 
						{"ATIVO"	,"C"	,001,0} }		//Status da ativacao: 1-Ativado ou 0-Desativado

return aStruct

//--------------------------------------------------------------
/*/{Protheus.doc} indexStruct
Retorna a estrutura dos indices

@param lCreatFile		Cria tabela
@param lCreatIndex		Cria indice

@author Sergio S. Fuzinaka
@since 27/11/2011
@version 1.0 

/*/
//--------------------------------------------------------------
static function indexStruct()

Local aIndex	:= { {"ID+PROCESSO+EMPRESA+FILIAL+SERIE"} }

return aIndex

//-------------------------------------------------------------------
/*/{Protheus.doc} setTitleText
Funcao que atribui texto ao título da visualização do documento

@param	oOwner	Objeto de tela pai
@param	cText	Texto que será atribuido

@author Henrique Brugugnoli
@since 21/10/2011
@version 11.6
/*/
//-------------------------------------------------------------------
Function setTitleText( oOwner, cText )

Local oPanelLine                       

DEFAULT cText	:= ""

DEFINE FONT oFont NAME STR0032 BOLD SIZE 0, 18 //BOLD
@ 004,002 SAY oSay PROMPT cText OF oOwner SIZE 300,300 PIXEL COLOR RGB(103, 103, 103) FONT oFont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseSetArray
Atribui um novo Array para o browse.

@param oBrowse		Objeto do browser
@param aArray		Array do Browse que esta declarado local
@param aArrayData	Array com os novos dados do browse

@author  Henrique Brugugnoli
@since   17/10/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BrowseSetArray( oBrowse, aArray ) 

		oBrowse:SetArray(aArray)                      	
		//Ativa e atualiza o browse
		oBrowse:Refresh(.T.)	  

Return
