#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
/* Funções relacionadas a Integração */


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEINTSGWJ()
Altera a situação da pré-fatura através do model

@sample
GFEINTSGWJ()

@author Israel Alcantara Possoli
@since 23/08/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEINTSGWJ(cSit, rRecNo)
	Local oModel := FWLoadModel("GFEA055")
	Local aAreaGWJ := GWJ->(GetArea())
	Default rRecNo = 0
	
	If rRecNo != 0
		dbSelectArea("GWJ")
		dbGoTo(rRecNo)
		If rRecNo != GWJ->(RecNo())
			Return .F.
		EndIf
	EndIf
	
	oModel:SetOperation(4)
	oModel:Activate()
	oModel:LoadValue("GFEA055_GWJ", 'GWJ_SITFIN', cSit)
	If oModel:VldData()
		oModel:CommitData()
	EndIf
	oModel:Deactivate()
	
	RestArea(aAreaGWJ)
	
Return .T.


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEINTSGW6()
Altera a situação da Fatura através do model

@sample
GFEINTSGW6()

@author Israel Alcantara Possoli
@since 30/08/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEINTSGW6(cSit, rRecNo)
	Local oModelGW6 := FWLoadModel("GFEA070")
	Local aAreaGW6 := GW6->(GetArea())
	Default rRecNo = 0
	
	If rRecNo != 0
		dbSelectArea("GW6")
		dbGoTo(rRecNo)
		If rRecNo != GW6->(RecNo())
			Return .F.
		EndIf
	EndIf
	
	oModelGW6:SetOperation(4)
	oModelGW6:Activate()
	oModelGW6:LoadValue("GFEA070_GW6", "GW6_SITFIN", cSit)
	If oModelGW6:VldData()
		oModelGW6:CommitData()
	EndIf
	oModelGW6:Deactivate()
	
	RestArea(aAreaGW6)
	
Return .T.


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEINTSGW2()
Altera a situação da Contrato através do model

@sample
GFEINTSGW2()

@author Israel Alcantara Possoli
@since 01/09/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEINTSGW2(cSit, rRecNo)
	Local oModelGW2 := FWLoadModel("GFEA100")
	Local aAreaGW2 := GW2->(GetArea())
	Default rRecNo = 0
	
	If rRecNo != 0
		dbSelectArea("GW2")
		dbGoTo(rRecNo)
		If rRecNo != GW2->(RecNo())
			Return .F.
		EndIf
	EndIf
	
	oModelGW2:SetOperation(4)
	oModelGW2:Activate()
	oModelGW2:LoadValue("GFEA100_GW2", "GW2_SITFIN", cSit)
	If oModelGW2:VldData()
		oModelGW2:CommitData()
	EndIf
	oModelGW2:Deactivate()
	
	RestArea(aAreaGW2)
	
Return .T.


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA055XML()
Função de retorno da situação da pré-fatura.
Atualiza a situação da pré-fatura no GFE.                                                                                                                           
Se ela foi rejeitada no ERP, grava o motivo no campo MOTFIN

@sample
GFEA055XML( cXML )

@author Israel Possoli
@since 19/08/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA055XML( cXML )
	Local 	cError   := ''
	Local 	cWarning := ''
	Local 	oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local   cMsgRej 
	
	If !Empty( cError )
		Return NIL
	EndIf
    
	cNrFat   := PadR(oXML:_GFEA055:_GFEA055_GWJ:_GWJ_NRPF:_VALUE:TEXT  , TamSX3("GWJ_NRPF")[1]  )
	cSitFin  := PadR(oXML:_GFEA055:_GFEA055_GWJ:_GWJ_SITFIN:_VALUE:TEXT, TamSX3("GWJ_SITFIN")[1])
    cMsgRej  := AllTrim(oXML:_GFEA055:_GFEA055_GWJ:_GWJ_MOTFIN:_VALUE:TEXT)
    
    dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	If GWJ->( dbSeek( xFilial("GWJ") + cNrFat) )
	
		If GWJ->GWJ_SITFIN == "2"		
		
			RecLock( "GWJ", .F.)
				GWJ->GWJ_SITFIN := cSitFin
				GWJ->GWJ_MOTFIN := cMsgRej
			MsUnLock("GWJ")
		
		EndIf
		
	EndIf
	
Return NIL

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA055DFI()
Função de retorno da desatualização da pré-fatura no financeiro

@sample
GFEA055DFI( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
------------------------------------------------------------------------------------------------*/

Function GFEA055DFI( cXML )
	Local cError   := ""
	Local cWarning := ""
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	
	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrPFat  := PadR(oXML:_GFEA055:_GFEA055_GWJ:_GWJ_NRPF:_VALUE:TEXT  , TamSX3("GWJ_NRPF")[1]  )
	cSitFin  := PadR(oXML:_GFEA055:_GFEA055_GWJ:_GWJ_SITFIN:_VALUE:TEXT, TamSX3("GWJ_SITFIN")[1])
	cMotFin  := AllTrim(oXML:_GFEA055:_GFEA055_GWJ:_GWJ_MOTFIN:_VALUE:TEXT)
    
    dbSelectArea("GWJ")
	GWJ->( dbSetOrder(1) )
	If GWJ->( dbSeek(xFilial("GWJ") + cNrPFat) )
		
		If GWJ->GWJ_SITFIN == "5"
		
			RecLock("GWJ", .F.)
				GWJ->GWJ_SITFIN := cSitFin
				GWJ->GWJ_MOTFIN := cMotFin
			MsUnLock("GWJ")
		
		EndIf
		
	EndIf
	
Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA070XML()
Função utilizada pela integração via XML
Altera a situação do campo SITFIN conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro

@sample
GFEA070XML( cXML )

@author Israel Possoli
@since 10/11/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEA070XML( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cMsgRej 
	
	If !Empty( cError )
		Return NIL
	EndIf
	
	cEmiFat := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_EMIFAT:_VALUE:TEXT, TamSX3("GW6_EMIFAT")[1])
	cSerFat := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_SERFAT:_VALUE:TEXT, TamSX3("GW6_SERFAT")[1])
	cNrFat  := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_NRFAT:_VALUE:TEXT , TamSX3("GW6_NRFAT" )[1])
	cSitFin := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_SITFIN:_VALUE:TEXT, TamSX3("GW6_SITFIN")[1])
	cDtEmis := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_DTEMIS:_VALUE:TEXT, TamSX3("GW6_DTEMIS")[1])
    cMsgRej := AllTrim(oXML:_GFEA070:_GFEA070_GW6:_GW6_MOTFIN:_VALUE:TEXT)
    
    // Adicionada duas buscas, pois, foi implementado a busca pela chave iteira (incluido a data de emissão),
    // Anteriormente utilizava apenas até o número, com isso, se o cliente não atualizou o dicionário funcionará igualmente.
    dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	If GW6->( dbSeek(xFilial("GW6") + cEmiFat + cSerFat + cNrFat + cDtEmis) ) .Or. GW6->( dbSeek(xFilial("GW6") + cEmiFat + cSerFat + cNrFat) )
		
		If GW6->GW6_SITFIN == "2"
		
			RecLock("GW6", .F.)
				GW6->GW6_SITFIN := cSitFin
				GW6->GW6_MOTFIN := cMsgRej
			MsUnLock("GW6")
		
		EndIf
		
	EndIf
	
Return Nil

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA070DFI()
Função de retorno da desatualização da fatura no financeiro

@sample
GFEA070DFI( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
------------------------------------------------------------------------------------------------*/

Function GFEA070DFI( cXML )
	Local cError   := ""
	Local cWarning := ""
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cEmiFat
	Local cSerFat
	Local cNrFat
	Local cSitFin
	Local cMotFin
	
	If !Empty( cError )
		Return NIL
	EndIf
	
	cEmiFat := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_EMIFAT:_VALUE:TEXT, TamSX3("GW6_EMIFAT")[1])
	cSerFat := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_SERFAT:_VALUE:TEXT, TamSX3("GW6_SERFAT")[1])
	cNrFat  := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_NRFAT:_VALUE:TEXT , TamSX3("GW6_NRFAT" )[1])
	cSitFin := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_SITFIN:_VALUE:TEXT, TamSX3("GW6_SITFIN")[1])
	cDtEmis := PadR(oXML:_GFEA070:_GFEA070_GW6:_GW6_DTEMIS:_VALUE:TEXT, TamSX3("GW6_DTEMIS")[1])
	cMotFin := AllTrim(oXML:_GFEA070:_GFEA070_GW6:_GW6_MOTFIN:_VALUE:TEXT)
	
	// Adicionada duas buscas, pois, foi implementado a busca pela chave iteira (incluido a data de emissão),
    // Anteriormente utilizava apenas até o número, com isso, se o cliente não atualizou o dicionário funcionará igualmente.
    dbSelectArea("GW6")
	GW6->( dbSetOrder(1) )
	If GW6->( dbSeek(xFilial("GW6") + cEmiFat + cSerFat + cNrFat + cDtEmis) ) .Or. GW6->( dbSeek(xFilial("GW6") + cEmiFat + cSerFat + cNrFat) )

		If GW6->GW6_SITFIN == "5"
		
			RecLock("GW6", .F.)			
				GW6->GW6_SITFIN := cSitFin
				GW6->GW6_MOTFIN := cMotFin	
			MsUnLock("GW6")
			
		EndIf

	EndIf
	
Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA100XFI()
Função utilizada pela integração via XML
Altera a situação do campo GW2_SITFIN conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro

@sample
GFEA100XFI( cXML )

@author Israel Possoli
@since 10/11/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA100XFI( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)

	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrCont := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_NRCONT:_VALUE:TEXT, TamSX3("GW2_NRCONT")[1])
	cSitFin := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_SITFIN:_VALUE:TEXT, TamSX3("GW2_SITFIN")[1])
    cMsgRej := AllTrim(oXML:_GFEA100:_GFEA100_GW2:_GW2_MOTFIN:_VALUE:TEXT)

	GW2->( dbSetOrder(1) )
	If GW2->(dbSeek(xFilial("GW2") +  cNrCont) )
		
		If GW2->GW2_SITFIN == "2"
		
			RecLock("GW2", .F.)
				GW2->GW2_SITFIN := cSitFin
				GW2->GW2_MOTFIN := cMsgRej
			MsUnLock("GW2")
			
		EndIf
		
	EndIf
Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA100XRH()
Função utilizada pela integração via XML
Altera a situação do campo SITFIN conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro


@sample
GFEA100XRH( cXML )

@author Israel Possoli
@since 10/11/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA100XRH( cXML )
	Local 	cError   := ''
	Local 	cWarning := ''
	Local 	oXML     := XmlParser(cXML, '_', @cError, @cWarning)

	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrCont := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_NRCONT:_VALUE:TEXT, TamSX3("GW2_NRCONT")[1])
	cSitRh 	:= PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_SITRH:_VALUE:TEXT , TamSX3("GW2_SITRH")[1] )
	cMsgRej := AllTrim(oXML:_GFEA100:_GFEA100_GW2:_GW2_MOTRH:_VALUE:TEXT)
	
	GW2->( dbSetOrder(1) )
	If GW2->(dbSeek(xFilial("GW2") +  cNrCont) )	
		
		If GW2->GW2_SITRH == "2"
		
			RecLock("GW2", .F.)
				GW2->GW2_SITRH := cSitRh
				GW2->GW2_MOTRH := cMsgRej //Rejeitado integração
			MsUnLock("GW2")
			
		EndIf
		
	EndIf

Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA100XRE()
Função utilizada pela integração via XML
Altera a situação do campo SITREC conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro


@sample
GFEA100XRE( cXML )

@author Felipe R Mendes
@since 04/08/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------

Function GFEA100XRE( cXML )
	Local 	cError   := ''
	Local 	cWarning := ''
	Local 	oXML     := XmlParser(cXML, '_', @cError, @cWarning)

	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrCont := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_NRCONT:_VALUE:TEXT, TamSX3("GW2_NRCONT")[1])
	cSitRec	:= PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_SITREC:_VALUE:TEXT, TamSX3("GW2_SITREC")[1])
	cMsgRej := AllTrim(oXML:_GFEA100:_GFEA100_GW2:_GW2_MOTREC:_VALUE:TEXT)
	
	GW2->( dbSetOrder(1) )
	If GW2->(dbSeek(xFilial("GW2") +  cNrCont) )
		
		If GW2->GW2_SITREC == "2"
		
			RecLock("GW2", .F.)
				GW2->GW2_SITREC := cSitRec
				GW2->GW2_MOTREC := cMsgRej
			MsUnLock("GW2")
		
		EndIf
		
	EndIf

Return NIL

/*---------------------------------------------------------------------------
{Protheus.doc} GFEA100DFI()
Função de retorno da desatualização do contrato no financeiro

@sample
GFEA100DFI( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
---------------------------------------------------------------------------*/

Function GFEA100DFI( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cNrCont
	Local cSitFin
	Local cMsgRej

	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrCont := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_NRCONT:_VALUE:TEXT, TamSX3("GW2_NRCONT")[1])
	cSitFin	:= PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_SITFIN:_VALUE:TEXT, TamSX3("GW2_SITFIN")[1])
	cMsgRej := AllTrim(oXML:_GFEA100:_GFEA100_GW2:_GW2_MOTFIN:_VALUE:TEXT)
	
	dbSelectArea("GW2")
	GW2->( dbSetOrder(1) )
	If GW2->( dbSeek(xFilial("GW2") + cNrCont) )
	
		If GW2->GW2_SITFIN == "5"
		
			RecLock("GW2", .F.)
				GW2->GW2_SITFIN := cSitFin
				GW2->GW2_MOTFIN := cMsgRej
			MsUnLock("GW2")
			
		EndIf
		
	EndIf

Return NIL

/*---------------------------------------------------------------------------
{Protheus.doc} GFEA100DRH()
Função de retorno da desatualização do contrato no recursos humanos

@sample
GFEA100DRH( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
---------------------------------------------------------------------------*/

Function GFEA100DRH( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cNrCont
	Local cSitRH
	Local cMsgRej

	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrCont := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_NRCONT:_VALUE:TEXT, TamSX3("GW2_NRCONT")[1])
	cSitRH	:= PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_SITRH:_VALUE:TEXT , TamSX3("GW2_SITRH")[1] )
	cMsgRej := AllTrim(oXML:_GFEA100:_GFEA100_GW2:_GW2_MOTRH:_VALUE:TEXT)
	
	dbSelectArea("GW2")
	GW2->( dbSetOrder(1) )
	If GW2->( dbSeek(xFilial("GW2") + cNrCont) )
	
		If GW2->GW2_SITRH == "5"
		
			RecLock("GW2", .F.)
				GW2->GW2_SITRH := cSitRH
				GW2->GW2_MOTRH := cMsgRej
			MsUnLock("GW2")
			
		EndIf
		
	EndIf

Return NIL 

/*---------------------------------------------------------------------------
{Protheus.doc} GFEA100DRE()
Função de retorno da desatualização do contrato no recebimento

@sample
GFEA100DRE( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
---------------------------------------------------------------------------*/

Function GFEA100DRE( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cNrCont
	Local cSitRec
	Local cMsgRej

	If !Empty( cError )
		Return NIL
	EndIf
	
	cNrCont := PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_NRCONT:_VALUE:TEXT, TamSX3("GW2_NRCONT")[1])
	cSitRec	:= PadR(oXML:_GFEA100:_GFEA100_GW2:_GW2_SITREC:_VALUE:TEXT, TamSX3("GW2_SITREC")[1])
	cMsgRej := AllTrim(oXML:_GFEA100:_GFEA100_GW2:_GW2_MOTREC:_VALUE:TEXT)
	
	dbSelectArea("GW2")
	GW2->( dbSetOrder(1) )
	If GW2->( dbSeek(xFilial("GW2") + cNrCont) )
	
		If GW2->GW2_SITREC == "5"
		
			RecLock("GW2", .F.)
				GW2->GW2_SITREC := cSitRec
				GW2->GW2_MOTREC := cMsgRej
			MsUnLock("GW2")
			
		EndIf
		
	EndIf

Return NIL

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065XFI()
Função utilizada pela integração via XML
Altera a situação do campo GW3_SITFIS conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro


@sample
GFEA065XFI( cXML )

@author Israel Possoli
@since 10/11/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA065XFI( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	
	If !Empty( cError )
		Return NIL
	EndIf
	
	cCdEsp	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_CDESP:_VALUE:TEXT , TamSX3("GW3_CDESP" )[1])
	cEmisDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_EMISDF:_VALUE:TEXT, TamSX3("GW3_EMISDF")[1])
	cSerDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SERDF:_VALUE:TEXT , TamSX3("GW3_SERDF" )[1])
	cNrDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_NRDF:_VALUE:TEXT  , TamSX3("GW3_NRDF"  )[1])
	cDtEmis	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_DTEMIS:_VALUE:TEXT, TamSX3("GW3_DTEMIS")[1])
	cSitFis := AllTrim(oXML:_GFEA065:_GFEA065_GW3:_GW3_SITFIS:_VALUE:TEXT)
	cMsgRej := AllTrim(oXML:_GFEA065:_GFEA065_GW3:_GW3_MOTFIS:_VALUE:TEXT)
	
	dbSelectArea("GW3")
	GW3->( dbSetOrder(1) )
	If GW3->( dbSeek(xFilial("GW3") + cCdEsp + cEmisDf + cSerDf + cNrDf + cDtEmis) )
		
		If GW3->GW3_SITFIS == "2"
		
			RecLock("GW3", .F.)
				GW3->GW3_SITFIS := cSitFis
				GW3->GW3_MOTFIS := cMsgRej
			MsUnLock("GW3")
		
		EndIf
		
	EndIf
	
Return Nil

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEA065XRE()
Função utilizada pela integração via XML
Altera a situação do campo GW3_SITREC conforme o valor vindo do XML, 
é necessário utilzar este método para evitar as validações do model que só devem ser executadas quando o usuário alterar o registro

@sample
GFEA065XRE( cXML )

@author Israel Possoli
@since 10/11/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFEA065XRE( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)

	If !Empty( cError )
		Return NIL
	EndIf
	
	cCdEsp	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_CDESP:_VALUE:TEXT , TamSX3("GW3_CDESP")[1] )
	cEmisDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_EMISDF:_VALUE:TEXT, TamSX3("GW3_EMISDF")[1])
	cSerDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SERDF:_VALUE:TEXT , TamSX3("GW3_SERDF")[1] )
	cNrDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_NRDF:_VALUE:TEXT  , TamSX3("GW3_NRDF")[1]  )
	cDtEmis	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_DTEMIS:_VALUE:TEXT, TamSX3("GW3_DTEMIS")[1])
	cSitRec := PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SITREC:_VALUE:TEXT, TamSX3("GW3_SITREC")[1])
	cMsgRej := AllTrim(oXML:_GFEA065:_GFEA065_GW3:_GW3_MOTREC:_VALUE:TEXT)

	GW3->( dbSetOrder(1) )
	If GW3->( dbSeek(xFilial("GW3") + cCdEsp + cEmisDf + cSerDf + cNrDf + cDtEmis) )
		
		If GW3->GW3_SITREC == "2"
		
			RecLock("GW3", .F.)
				GW3->GW3_SITREC := cSitRec
				GW3->GW3_MOTREC := cMsgRej
			MsUnLock("GW3")
			
		EndIf
		
	EndIf		
	
Return NIL

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA065DFS()
Função de retorno da desatualização do documento de frete no fiscal

@sample
GFEA065DFS( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
------------------------------------------------------------------------------------------------*/

Function GFEA065DFS( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cCdEsp
	Local cEmisDf
	Local cSerDf
	Local cNrDf
	Local cDtEmis
	Local cSitFis
	Local cMsgRej
	
	If !Empty( cError )
		Return NIL
	EndIf
	
	cCdEsp	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_CDESP:_VALUE:TEXT , TamSX3("GW3_CDESP")[1] )
	cEmisDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_EMISDF:_VALUE:TEXT, TamSX3("GW3_EMISDF")[1])
	cSerDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SERDF:_VALUE:TEXT , TamSX3("GW3_SERDF")[1] )
	cNrDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_NRDF:_VALUE:TEXT  , TamSX3("GW3_NRDF")[1]  )
	cDtEmis	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_DTEMIS:_VALUE:TEXT, TamSX3("GW3_DTEMIS")[1])
	cSitFis := PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SITFIS:_VALUE:TEXT, TamSX3("GW3_SITFIS")[1])
	cMsgRej := AllTrim(oXML:_GFEA065:_GFEA065_GW3:_GW3_MOTFIS:_VALUE:TEXT)

	dbSelectArea("GW3")
	GW3->( dbSetOrder(1) )
	If GW3->( dbSeek(xFilial("GW3") + cCdEsp + cEmisDf + cSerDf + cNrDf + cDtEmis) )
		
		If GW3->GW3_SITFIS == "5"
		
			RecLock("GW3", .F.)
				GW3->GW3_SITFIS := cSitFis
				GW3->GW3_MOTFIS := cMsgRej
			MsUnLock("GW3")
			
		EndIf
		
	EndIf		
	
Return NIL

/*---------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA065DRE()
Função de retorno da desatualização do documento de frete no recebimento

@sample
GFEA065DRE( cXML )

@author Octávio Augusto Felippe de Macedo
@since 22/12/2011
@version 1.0
------------------------------------------------------------------------------------------------*/

Function GFEA065DRE( cXML )
	Local cError   := ''
	Local cWarning := ''
	Local oXML     := XmlParser(cXML, '_', @cError, @cWarning)
	Local cCdEsp
	Local cEmisDf
	Local cSerDf
	Local cNrDf
	Local cDtEmis
	Local cSitRec
	Local cMsgRej
	
	If !Empty( cError )
		Return NIL
	EndIf

	cCdEsp	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_CDESP:_VALUE:TEXT , TamSX3("GW3_CDESP")[1] )
	cEmisDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_EMISDF:_VALUE:TEXT, TamSX3("GW3_EMISDF")[1])
	cSerDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SERDF:_VALUE:TEXT , TamSX3("GW3_SERDF")[1] )
	cNrDf	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_NRDF:_VALUE:TEXT  , TamSX3("GW3_NRDF")[1]  )
	cDtEmis	:= PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_DTEMIS:_VALUE:TEXT, TamSX3("GW3_DTEMIS")[1])
	cSitRec := PadR(oXML:_GFEA065:_GFEA065_GW3:_GW3_SITREC:_VALUE:TEXT, TamSX3("GW3_SITREC")[1])
	cMsgRej := AllTrim(oXML:_GFEA065:_GFEA065_GW3:_GW3_MOTREC:_VALUE:TEXT)

	dbSelectArea("GW3")
	GW3->( dbSetOrder(1) )
	If GW3->( dbSeek(xFilial("GW3") + cCdEsp + cEmisDf + cSerDf + cNrDf + cDtEmis) )
		
		If GW3->GW3_SITREC == "5"
		
			RecLock("GW3", .F.)
				GW3->GW3_SITREC := cSitRec
				GW3->GW3_MOTREC := cMsgRej
			MsUnLock("GW3")
			
		EndIf
		
	EndIf		
	
Return NIL
