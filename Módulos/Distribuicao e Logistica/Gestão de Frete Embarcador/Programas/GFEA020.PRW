#INCLUDE "GFEA020.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include 'fileio.ch'
 
 
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GFEA020 teste tfs 2015  ³ Autor ³ Luiz Fernando Soares  ³ Data ³ 21.10.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cadastro de Cidades				                      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FRMA020()	                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 			 ³        ³XXXXXX³	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//-------------------------------------------------------------------
Function GFEA020()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GU7")							// Alias da tabela utilizada
oBrowse:SetMenuDef("GFEA020")				    // Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)	// Descrição do browse //"Cadastro de Cidades"
oBrowse:Activate()                                       

Return(Nil)

//-------------------------------------------------------------------//
//-------------------------Funcao MenuDEF----------------------------//
//-------------------------------------------------------------------//
Static Function MenuDef()
Local aRotina := {}
//-------------------------------------------------------
// Adiciona botões do browse
//-------------------------------------------------------
    AAdd(aRotina, {STR0002                , 'AxPesqui'       , 0, 1 , 0, .F. /*Habilita Menu Funcional*/}) // Pesquisar
    AAdd(aRotina, {STR0003                , 'GFEC020(.F.)'   , 0, 2 , 0, .F. /*Habilita Menu Funcional*/}) // 

	// Integração - Retira botães Incluir, Ecluir e Copiar quando for integrago com o ERP

	If SuperGetMv("MV_CADERP",.F.,"2") $ "2N"
		AAdd(aRotina, {STR0004                , 'VIEWDEF.GFEA020'   , 0, 3 , 0, .F. /*Habilita Menu Funcional*/})
	EndIf
	
	AAdd(aRotina, {STR0005                , 'VIEWDEF.GFEA020'   , 0, 4 , 0, .F. /*Habilita Menu Funcional*/})
	
	If SuperGetMv("MV_CADERP",.F.,"2") $ "2N"
		AAdd(aRotina, {STR0006                , 'VIEWDEF.GFEA020'   , 0, 5 , 0, .F. /*Habilita Menu Funcional*/}) //"Excluir"
		AAdd(aRotina, {STR0007                , 'VIEWDEF.GFEA020'   , 0, 9 , 0, .F. /*Habilita Menu Funcional*/}) //"Copiar"
	EndIf
	AAdd(aRotina, {STR0008                , 'VIEWDEF.GFEA020'   , 0, 8 , 0, .F. /*Habilita Menu Funcional*/}) //"Imprimir"
Return aRotina

//-------------------------------------------------------------------//
//-------------------------Funcao ModelDEF----------------------------//
//-------------------------------------------------------------------//
Static Function ModelDef()

Local oModel
Local oStructGU7 := FWFormStruct(1,"GU7")
Local oStructGXM := FWFormStruct(1,"GXM")

oStructGXM:RemoveField('GXM_NRCID')

oModel := MPFormModel():New("GFEA020", /**/, { |oX| GFEA020POS( oX ) }, /**/, /**/, /*bCancel*/)

oModel:AddFields("GFEA020_GU7", , oStructGU7)
oModel:AddGrid("GFEA020_GXM","GFEA020_GU7",oStructGXM)
oModel:SetRelation( 'GFEA020_GXM', { { 'GXM_FILIAL', 'xFilial("GXM")' }, { 'GXM_NRCID','GU7_NRCID' } }, GXM->( IndexKey( 1 ) ) )
oModel:SetPrimaryKey({"GU7_FILIAL", "GU7_NRCID"})
oModel:GetModel("GFEA020_GXM"):SetDelAllLine(.T.)
oModel:SetOptional("GFEA020_GXM", .T. )
oModel:GetModel("GFEA020_GXM"):SetUniqueLine({"GXM_CDTIPO"})

oModel:SetVldActivate ( { |oX| GFEA020DEL( oX ) } )

Return oModel

//-------------------------------------------------------------------//
//-------------------------Funcao ViewDef----------------------------//
//-------------------------------------------------------------------//
Static Function ViewDef()

Local oModel := FWLoadModel("GFEA020")
Local oView 
Local oStructGU7 := FWFormStruct(2,"GU7")
Local oStructGXM := FWFormStruct(2,"GXM")

// Integração - Desabilita campos
If SuperGetMV('MV_CADERP',,'1') $ "1S"
	oStructGU7:SetProperty("GU7_NRCID",  MVC_VIEW_CANCHANGE ,.F.)
	oStructGU7:SetProperty("GU7_NMCID",  MVC_VIEW_CANCHANGE ,.F.)
	oStructGU7:SetProperty("GU7_CDUF",   MVC_VIEW_CANCHANGE ,.F.)
EndIf
// FIM - Integração	

oStructGXM:RemoveField('GXM_NRCID')

oView := FWFormView():New()
// Objeto do model a se associar a view.
oView:SetModel(oModel)
oView:AddField( "GFEA020_GU7" , oStructGU7, 'GFEA020_GU7' )
oView:AddGrid( "GFEA020_GXM" , oStructGXM, 'GFEA020_GXM' )

oView:CreateHorizontalBox( "SUPERIOR" , 30 )
oView:CreateHorizontalBox( "INFERIOR" , 70 )

oView:CreateFolder("IDFOLDER","INFERIOR")
oView:AddSheet("IDFOLDER","IDSHEET01","%ISS por Tipo de Ocorrência") //"Exceções"

oView:CreateHorizontalBox( "DETAILEXE"  , 100,,,"IDFOLDER","IDSHEET01" )
// Associa um View a um box
oView:SetOwnerView( "GFEA020_GU7" , "SUPERIOR" )  
oView:SetOwnerView( "GFEA020_GXM" , "DETAILEXE" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA020DEL
Rotina para realizar as validacoes no momento da exclusao.
Uso Geral.

@param 	oModel	    Recebi o oMOdel principal

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
function GFEA020DEL (oModel)
Local lRet    := .T.
local nOpc    := (oModel:GetOperation())

if nOpc == 5 
    dbSelectArea("GUA")
    dbSetOrder(2)
    If MsSeek(xFilial("GUA")+GU7->GU7_NRCID)
    	Help( ,, 'HELP',, STR0011, 1, 0,) //"Cidade está relacionada com região. Não é possivel excluir"
    	lRet := .F.
	endif
endif

Return(lRet)        

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA020POS
Rotina para Validar os registros antes da gravacao no banco.
Uso Geral.

@param 	oModel	    Recebi o oMOdel principal

@author Luiz Fernando Soares
@since 21/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA020POS (oModel)
	Local lRet    := .T.
	local nOpc    := (oModel:GetOperation())
	Local aAreaGU7  := GU7->(getArea())
	Local nNrCid	:= 0	// Código da cidade

	If GFEWSFUNLG() .And. FunName() != "GFEA020"
   	   Help( ,, 'HELP', '', 'Não é possível receber cadastro do Protheus quando ERP for Datasul.', 1, 0)
       lRet := .F.
    EndIf
	
	If nOpc == 3 .Or. nOpc == 4
		// Integração
		// Se o código do país estiver em branco, busca o código no cadastro  
		If AllTrim(FwFldGet("GU7_CDPAIS")) == "0".OR.Empty(FwFldGet("GU7_CDPAIS"))
			dbSelectArea("SYA")
			dbSetOrder(2)
			dbGoTop()
		   	If dbSeek(xFilial("SYA")+PadR(UPPER(ALLTRIM(FwFldGet("GU7_NMPAIS"))), 25))
				oModel:LoadValue( 'GFEA020_GU7', 'GU7_CDPAIS', PADR(ALLTRIM(SYA->YA_CODGI), 03, " "))
			EndIf
		EndIf
		
		
		// Atribui o código da cidade, quando não for informado, pelo nome e uf da cidade
		If AllTrim(FwFldGet("GU7_NRCID")) == "0".OR.Empty(FwFldGet("GU7_NRCID"))
			// Verifica se existe uma cidade com o nome e uf, caso não exista, cria um novo código
			dbSelectArea("GU7")
			dbSetOrder(3)
			If !dbSeek(PADR(UPPER(M->GU7_NMCID),50, " ") + PADR(UPPER(M->GU7_CDUF),2, " "))
				// Busca o próximo código disponível da cidade
				dbSelectArea("GU7")
				dbSetOrder(1)
				dbGoTop()
				dbSeek(xFilial("GU7"))
				dbGoTop()
				While !Eof()
					IF Val(ALLTRIM(GU7->GU7_NRCID)) > nNrCid
						nNrCid := Val(ALLTRIM(GU7->GU7_NRCID))
					EndIf
					dbSelectArea("GU7")
					dbSkip()
				EndDo           
				nNrCid++
				
				RestArea(aAreaGU7)
				oModel:LoadValue( 'GFEA020_GU7', 'GU7_NRCID', PadL(Alltrim(Str(nNrCid)), TamSX3("GU7_NRCID")[1], "0"))
			EndIf
		EndIf
		// FIM - Integração
	EndIf

	
	If nOpc == 3 
		If AllTrim(FwFldGet("GU7_NRCID")) == "0".OR.Empty(FWFldGet( 'GU7_NRCID' ))
			Help( ,, 'HELP',, STR0009, 1, 0,) //"Cidade deve ser diferente de 0"
			lRet := .F.
		Endif
		
		If AllTrim(FwFldGet("GU7_CDPAIS")) == "0".OR.Empty(FwFldGet("GU7_CDPAIS"))
			Help( ,, 'HELP',, STR0010, 1, 0,) //"O País deve ser informado"
			lRet := .F.
		EndIf		
	Endif                                             
	
	
	If nOpc == 3 .Or. nOpc == 4
	    
		If oModel:GetValue( 'GFEA020_GU7', 'GU7_CEPFIM' ) < oModel:GetValue( 'GFEA020_GU7', 'GU7_CEPINI' )
			Help( ,, 'HELP',, STR0012, 1, 0,) //"CEP Final deve ser maior que CEP Inicial"

			lRet := .F.
		EndIf

		If "'" $ AllTrim(FwFldGet("GU7_NMCID")) 
			cNomCid := StrTran(M->GU7_NMCID,"'"," ",1)
			oModel:LoadValue( 'GFEA020_GU7', 'GU7_NMCID', cNomCid)
			If  !IsBlind() .And. !FwIsInCallStack("GFEM011") .And. !FwIsInCallStack("OMSM011")
				Alert( "O apóstrofo foi removido do nome da cidade") //"Não permite apóstrofe no nome da cidade"
			EndIf
		EndIf 
	Endif
	
Return(lRet)

//--------------------------------------

Function GFEA020SIG()
Local cCid := AllTrim(FwFldGet("GU7_NMCID"))
Local cUF  := AllTrim(FwFldGet("GU7_CDUF"))
Local cSig := ""
Local aAux
Local nTam
Local nCont

If !Empty(cCid) .And. !Empty(cUF)
	
	cSig += cUF
	
	aAux := GFEA020FMT(cCid)
	
	If Empty(aAux)
		cSig := ""
	ElseIf Len(aAux) == 1
		cSig += SubStr(aAux[1],1,3)
	Else
		cSig += SubStr(aAux[1],1,1)
		
		nTam := TamSX3("GU7_SIGLA")[1] - Len(cSig)
		
		For nCont := 2 To Len(aAux)
			If Len(aAux[nCont]) >= nTam
				cSig += SubStr(aAux[nCont],1,nTam)
				Exit
			EndIf
		Next nCont

	EndIf

EndIf

Return cSig

//---------------------------------------

Static Function GFEA020FMT(cCid)
Local nCont
Local cL := ""
Local cAux := ""

For nCont := 1 To Len(cCid)

	If IsAlpha((cL := SubStr(cCid,nCOnt,1))) .Or. (cL := SubStr(cCid,nCOnt,1)) == " "
		cAux += cL
	EndIf

Next nCont

Return If(Empty(cAux), {}, StrTokArr(cAux," "))

/*
=========================================================================================================
// {Protheus.doc} IntegDef
// TODO Chamada da Rotina de Integração de Mensagem Unica 
@author Hercilio Henning Neto
@since 18/07/2017
@version 1.000
@param cXml     : Xml definido de acordo com o XSD da mensagem de envio/recebimento.
@param nType    : numeric / Informa o tipo de Mensagem tratada: 0=Response;1=Envio;
@param cTypeMsg : Informa qual o tipo de mensagem que será processada se é uma: Business Message, Receipt Message, WhoIs Message 
@type function
=========================================================================================================
*/
Static Function IntegDef(cXml,nType,cTypeMsg)
Local  aResult := {}
       aResult := GFEI020(cXml,nType,cTypeMsg)
Return aResult
