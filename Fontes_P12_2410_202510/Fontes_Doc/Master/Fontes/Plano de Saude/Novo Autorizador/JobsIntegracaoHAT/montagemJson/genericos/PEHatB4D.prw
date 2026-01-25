#INCLUDE "TOTVS.CH"
#INCLUDE "hatActions.ch"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PEHatB4D
    Classe abstrata para execução de comandos
    @type  Class
    @author Lucas Nonato
    @since 01/2023
/*/
Class PEHatB4D From PEHatGener

	Method New()
    Method retDadJson()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe B4D
    @type  Class
    @author Lucas Nonato
    @since 01/2022
/*/
//------------------------------------------------------------------------------------------
Method New() Class PEHatB4D

    Default cPedido := ''
    
    _Super:New()
    self:cNodePrinc := 'items'
    self:aNodeKey   := {'batchNumber','healthProviderId'}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} retDadJson

@author  Lucas Nonato
@version P12
@since 	 01/2023
/*/
//-------------------------------------------------------------------
Method retDadJson() Class PEHatB4D

local lRet      := .F.
local aRet      := {}
local cSql      := ''

cSql := " SELECT BXX_PLSHAT,BXX_CODRDA,B4D_DCDPEG,B4D_TOTACA,B4D_STATUS "
cSql += " FROM " + RetsqlName("B4D") + " B4D "
cSql += " INNER JOIN " + RetsqlName("BXX") + " BXX "
cSql += " ON B4D_FILIAL = '" + xFilial("B4D") + "' "
cSql += " AND B4D_PROTOC = '" + self:cChaveBNV + "' "
cSql += " AND B4D.D_E_L_E_T_ = ' ' "
cSql += " WHERE BXX_FILIAL = '" + xFilial("BXX") + "' "
cSql += " AND BXX_PROGLO = B4D_PROTOC "
cSql += " AND BXX_PLSHAT <> ' ' "
cSql += " AND BXX.D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),'TMPBXX',.F.,.T.)

if !TMPBXX->(eof())
	lRet := .t.
 
	aadd(aRet,{'batchNumber', 		'BXX_PLSHAT', TMPBXX->BXX_PLSHAT, .f.})
	aadd(aRet,{'healthProviderId', 	'BXX_CODRDA', TMPBXX->BXX_CODRDA, .f.})
	aadd(aRet,{'statusTiss', 		'BCI_STTISS', iif(empty(TMPBXX->B4D_DCDPEG) .and. TMPBXX->B4D_STATUS $ '24','4','2'), .f.})
	aadd(aRet,{'newBatchNumber',	'B4D_DCDPEG', TMPBXX->B4D_DCDPEG, .t.})
	aadd(aRet,{'value',				'BCI_VLRGUI', TMPBXX->B4D_TOTACA, .t.})
	
endif			 
TMPBXX->(dbclosearea())


Return {lRet,aRet}