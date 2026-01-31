#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMBROWSE.CH'
#INCLUDE 'FWMVCDEF.CH'  
#INCLUDE 'PLSPLANPRO.CH'  

/*/{Protheus.doc} 

@since 30/07/2020
@version P12
/*/

function PLSPLANPRO(cCodRDA, cCodInt,cCodLoc, cCodEsp, cCodSubEsp,cLocalEsp) 
local aArea     	:= GetArea()
local oDlgWnd		:= nil 
local oPnlInf	:= nil
local oGridBBI		:= nil
local oGridBE9		:= nil 
local aSize     := MsAdvSize(.f.)
local aInfo		:= {}
local aObjects	:= {}
local aPosObj	:= {}
local aRelac	:= {}
local fieldBE9  := BE9->(FieldPos("BE9_SEQUEN")) > 0
local fieldBBI  := BBI->(FieldPos("BBI_SEQUEN")) > 0
local cFiltro   := "@(BBI_FILIAL = '" + xFilial("BBI") + "' AND BBI_CODINT = '" + cCodInt + "' AND BBI_CODIGO ='" + cCodRDA + "' "+;
					"AND BBI_CODLOC = '" + cCodLoc + "' AND BBI_CODESP = '" + cCodEsp + "' AND BBI_CODSUB = '" + cCodSubEsp + "')"

private cCodInt := Plsintpad()
private cCamLEtxt := cLocalEsp
private cPVLocBBI := cCodLoc
private cPVEspBBI := cCodEsp
private cPVEspSBBI := cCodSubEsp
private cRdaBAUB := cCodRDA

aObjects 	:= {	{ 100, 50, .T., .T. },;
					{ 100, 50, .T., .T. } }

aInfo		:= { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }
aPosObj	:= MsObjSize( aInfo, aObjects, .T. )

// Janela principal
oDlgWnd := msDialog():New( aSize[7], 0, aSize[6], aSize[5], "Planos x Procedimentos", , , , , , , , , .T. )

oFwLayer := FwLayer():New()
oFwLayer:Init(oDlgWnd,.F.)

//Cria o Layer Superior
oFWLayer:addLine("UP_BRW", 50, .F.)

//Cria o Layer Inferior
oFWLayer:addLine("DOWN_BKY", 50, .F.) 

//Definição dos Painéis
oPnlSup	:= oFWLayer:GetLinePanel( "UP_BRW" )
oPnlInf	:= oFWLayer:GetLinePanel( "DOWN_BKY" )
aRotina := {}                          

//Grid da tabela de Planos - BBI
oGridBBI := FWmBrowse():New()
oGridBBI:setOwner(oPnlSup)
oGridBBI:setProfileID('0')
oGridBBI:setAlias("BBI") 
oGridBBI:setDescription(STR0001) //'Plano de Saúde - Informações'
oGridBBI:setMenuDef('PLSBBIPLA')
oGridBBI:disableDetails()  
oGridBBI:disableReport()                 
oGridBBI:setFilterDefault(cFiltro)

oGridBBI:activate()
                          

//Grid da tabela de Procedimentos - BE9															 
oGridBE9 := FWmBrowse():New()
oGridBE9:setOwner(oPnlInf)
oGridBE9:setProfileID('1')
oGridBE9:setAlias("BE9")
oGridBE9:setDescription(STR0002)//Procedimentos
oGridBE9:setMenuDef('PLSBE9PRO')
oGridBE9:disableDetails()  
oGridBE9:disableReport() 

oGridBE9:activate()


aRelac := {	{ "BE9_FILIAL", 'xFilial("BE9")' }, ;
		  { "BE9_CODIGO", "BBI_CODIGO" }, ;
		  { "BE9_CODINT", "BBI_CODINT" }, ;
		  { "BE9_CODLOC", "BBI_CODLOC" }, ;
		  { "BE9_CODESP", "BBI_CODESP" }, ;	
		  { "BE9_CODSUB", "BBI_CODSUB" }, ;
		  { "BE9_CODGRU", "BBI_CODGRU" }, ;
		  { "BE9_CODPLA", "BBI_CODPRO" } }

if fieldBE9 .and. fieldBBI
	aadd(aRelac, {"BE9_SEQUEN","BBI_SEQUEN"})
endif 


//Relacao dos Browses 									 
OGridRelac := FWBrwRelation():new()       
OGridRelac:addRelation( oGridBBI, oGridBE9, aRelac)      
                           
OGridRelac:Activate()

//³ Ativando componentes de tela											 
oDlgWnd:lCentered := .T.
oDlgWnd:bRClicked := {||}
oDlgWnd:Activate()       

restArea(aArea)                   														 

return nil
