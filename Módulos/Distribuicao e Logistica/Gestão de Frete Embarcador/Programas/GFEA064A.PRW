#INCLUDE 'GFEA064A.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'AP5MAIL.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA064A
Rotina para aprovação de tabelas de frete de vínculo.

@author Octávio Augusto Felippe de Macedo
@since 19/01/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Function GFEA064A(cEmiDe, cEmiAte, cTabDe, cTabAte)
Private oVBrowse

Default cEmiDe  := ""
Default cEmiAte := "999999999"
Default cTabDe  := ""
Default cTabAte := "999999"

oVBrowse := FWMBrowse():New()
oVBrowse:SetAlias("GVA")
oVBrowse:SetMenuDef("GFEA064A")
oVBrowse:SetDescription(STR0001)

oVBrowse:AddLegend("GVA_SITVIN=='1'", "BLUE" , STR0002)
oVBrowse:AddLegend("GVA_SITVIN=='2'", "GREEN", STR0003)

oVBrowse:SetFilterDefault("GVA_CDEMIT >= '"+cEmiDe+"' .And. GVA_CDEMIT <= '"+cEmiAte+"' .And. GVA_NRTAB >= '"+cTabDe+"' .And. GVA_NRTAB <= '"+cTabAte+ ;
						 "' .And. GVA_TPTAB == '2' .And. GVA_ENVAPR == '1'")

oVBrowse:Activate()       

Return(Nil)

//-------------------------------------------------------------------     

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "AxPesqui"        OPERATION 1  ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GFEC061" OPERATION 2  ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION "GFEA64AAPR()"    OPERATION 10 ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION "GFEA64AREP()"    OPERATION 11 ACCESS 0

Return aRotina

//-------------------------------------------------------------------

//Função para aprovar a tabela de vínculo                     
Function GFEA64AAPR()   
Local dDataApro := DDATABASE
Local cTime := TIME()

dbSelectArea("GUX")
GUX->( dbSetOrder(1) )
If !GUX->( dbSeek(xFilial("GUX") + RetCodUsr()) )
	Help( ,, 'HELP',, STR0009, 1, 0)
	Return .F.
EndIf

If GVA->GVA_SITVIN == "2"
   	Help( ,, 'HELP',, STR0010, 1, 0)
   	Return .F.
EndIf

If GVA->GVA_ENVAPR != "1"
	Help( ,, 'HELP',, STR0025, 1, 0)
	Return .F.
EndIf
		
RecLock("GVA",.F.)
	GVA->GVA_SITVIN := "2"
	GVA->GVA_DTAPR  := dDataApro
	GVA->GVA_HRAPR  := cTime
	GVA->GVA_USUAPR := cUserName
MsUnLock("GVA")		

MsgInfo(STR0011,STR0012) 
	
Return .T.

//-------------------------------------------------------------------

//Função para informar o motivo da reprovação
Function GFEA64AREP()                  
Local oDlg                                                                
Local oGet
Local cMovRep   

If !Empty(GVA->GVA_MTVRPR) .And. GVA->GVA_ENVAPR == "2"
	Help( ,, 'HELP',, STR0013, 1, 0)	
	Return .F.
EndIf

dbSelectArea("GUX")            
GUX->( dbSetOrder(1) )
If !GUX->( dbSeek(xFilial("GUX") + RetCodUsr()) )
	Help( ,, 'HELP',, STR0009, 1, 0)	
	Return .F.
EndIf

If GVA->GVA_SITVIN == "2"
   	Help( ,, 'HELP',, STR0010, 1, 0)	
   	Return .F.
Else		
	DEFINE MSDIALOG oDlg TITLE STR0014 From 4,0 To 16,60 OF oMainWnd
	@ 4, 006  SAY STR0015 SIZE 70,7 PIXEL OF oDlg

	oTMultiget1 := TMultiget():New(13,06,{|u| If(Pcount()>0,cMovRep:=u,cMovRep)},oDlg,225,60,,,,,,.T.)     
	oTMultiget1:EnableVScroll( .T. )
	oTMultiget1:GoEnd()
	
	oButtonOK   := tButton():New(75, 5, STR0016 , oDlg, {|| If(GFEA64AOK(cMovRep), oDlg:End(), NIL)}, 25, 10,,,, .T.)
	oButtonCanc := tButton():New(75, 35, STR0017 , oDlg, {||(oDlg:End())}, 25, 10,,,, .T.)
	
	ACTIVATE MSDIALOG oDlg CENTERED	
EndIf   	

Return .T.
  
//-------------------------------------------------------------------

//Função para reprovar a tabela de vínculo
Static Function GFEA64AOK(cMovRep)   
Local cMensagem  := STR0018 + GVA->GVA_NRTAB +"("+GVA->GVA_DSTAB+")"+ STR0019 + GVA->GVA_CDEMIT + STR0020 + cUserName + STR0021
Local cAssunto   := STR0022

	If !Empty(cMovRep)	
		If GFEEnvMail(GFEA64AUSR(),cAssunto,cMensagem,.F.)
			RecLock("GVA",.F.)
				GVA->GVA_MTVRPR := cMovRep
				GVA->GVA_ENVAPR := "2"
			MsUnLock("GVA")
			
			MsgInfo(STR0027,"")
		Else
			Help( ,, 'HELP',, STR0026, 1, 0,)
			Return .F.
		EndIf		
	Else
		Help( ,, 'HELP',, STR0023, 1, 0,)
		Return .F.
	EndIf   
	
Return .T.     

//-------------------------------------------------------------------

//Função para gerar os destinatários dos e-mails
Static Function GFEA64AUSR()
Local cPara 

dbSelectArea("GUX")
GUX->( dbSetOrder(1) )
GUX->( dbSeek(xFilial("GUX")) )
While !GUX->( Eof() ) .And. xFilial("GUX") == GUX->GUX_FILIAL
	If !Empty(GUX->GUX_EMAUSR)                      
		If Empty(cPara)
			cPara := Alltrim(GUX->GUX_EMAUSR)
		Else
			cPara += ";" + Alltrim(GUX->GUX_EMAUSR)
		EndIf
	EndIf
	dbSelectArea("GUX")
	GUX->( dbSkip() )
EndDo           

Return cPara     
