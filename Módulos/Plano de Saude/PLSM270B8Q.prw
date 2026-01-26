#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'

#define ORACLE      substr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE" 
#define POSTGRES    Alltrim(Upper(TCGetDb())) =="POSTGRES"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef - MVC

@author    timoteo.bega
@since     01/05/2017
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruB8Q := FWFormStruct( 1, 'B8Q', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
	
oModel := MPFormModel():New( 'MODELB8Q' )
oModel:AddFields( 'MODEL_B8Q',,oStruB8Q )	
oModel:SetDescription( "Monitoramento Guias TISS" )
oModel:GetModel( 'MODEL_B8Q' ):SetDescription( ".:: Monitoramento Vlr. Preestabelecido ::." ) 
oModel:SetPrimaryKey( { "B8Q_FILIAL","B8Q_SUSEP","B8Q_CMPLOT","B8Q_NUMLOT","B8Q_IDEPRE","B8Q_CPFCNP","B8O_IDCOPR" } )

return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
ViewDef - MVC

@author    timoteo.bega
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FWLoadModel( 'PLSM270B8Q' )
	
oView := FWFormView():New()
oView:SetModel( oModel )

return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270B8Q
Gravacao da tabela B8Q - CONTRATO PREESTABELECIDO MONIT

@author    timoteo.bega
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Function PLSM270B8Q(cAliSql,cSusep,cCmpLot,cNumLot,aCodCont,aContrat)

Local cChave 	:= ""
Local cIdePre 	:= ""
Local cCpfCnp 	:= ""
Local cIDCOPR 	:= ""
Local aCampos 	:= {}
local aLote		:= {}		
Local lRet		:= .F.
Local cSqlBGQ 	:= ""
local nContrat	:= 0
local nPosCont	:= 0
local cCodRda	:= ""
local nVLRCON 	:= 0
local cSqlTop 	:= ""
local cOracle 	:= ""
local cLimit  	:= ""

Default cAliSql := ""
Default cSusep 	:= ""
Default cCmpLot := ""
Default cNumLot := ""
default aCodCont:= ""
default aContrat:= {}

If !Empty(cSusep)
	cIdePre := Iif(Len(AllTrim((cAliSql)->BAU_CPFCGC))==14,"1","2")
	cCpfCnp := (cAliSql)->BAU_CPFCGC
	cIDCOPR := (cAliSql)->B8O_IDCOPR
//	nVLRCON := (cAliSql)->B8O_VLRCON
	cCDMNPR := ""
	cCNES := (cAliSql)->BAU_CNES
	cRGOPIN := ""
	cTPRGMN := ""
EndIf

if empty(aCodCont)
	cSqlBGQ += " Select SUM(BGQ_VALOR) VALOR from " + RetSqlName("BGQ") + " BGQ "
	cSqlBGQ += " where "
	cSqlBGQ += " BGQ.D_E_L_E_T_ = ' ' AND "
	cSqlBGQ += " BGQ.BGQ_FILIAL = '" + xfilial("BGQ") + "' AND "
	cSqlBGQ += " BGQ.BGQ_CODIGO = '" + (cAliSql)->BAU_CODIGO + "' AND "
	cSqlBGQ += " BGQ.BGQ_IDCOPR = '" + (cAliSql)->B8O_IDCOPR + "' AND "
	cSqlBGQ += " BGQ.BGQ_ANO = '" + substr(cCmpLot,1,4) + "' AND "
	cSqlBGQ += " BGQ.BGQ_MES = '" + substr(cCmpLot,5,2) + "' "
else
	cIDCOPR := aCodCont[1]
	cIdePre := iif(Len(AllTrim(aCodCont[2]))==14,"1","2")
	cCNES 	:= aCodCont[3]
	cCodRda := aCodCont[4]
	cCpfCnp := aCodCont[2]

	iif(ORACLE,	cOracle:=" AND ROWNUM = 1 ", iif(POSTGRES, cLimit:=" LIMIT 1", cSqlTop:=" TOP(1) "))

	cSqlBGQ += " Select " + cSqlTop + " BGQ_ANO, BGQ_MES, SUM(BGQ_VALOR) VALOR from " + RetSqlName("BGQ") + " BGQ "
	cSqlBGQ += " where "
	cSqlBGQ += " BGQ.D_E_L_E_T_ = ' ' AND "
	cSqlBGQ += " BGQ.BGQ_FILIAL = '" + xfilial("BGQ") + "' AND "
	cSqlBGQ += " BGQ.BGQ_CODIGO = '" + cCodRda + "' AND "
	cSqlBGQ += " BGQ.BGQ_IDCOPR = '" + cIDCOPR + "' "
	cSqlBGQ += cOracle
	cSqlBGQ += " GROUP BY BGQ_ANO, BGQ_MES "
	cSqlBGQ += " ORDER BY BGQ_ANO DESC, BGQ_MES DESC "
	cSqlBGQ += cLimit

endif

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBGQ),"PLBGQB8Q",.F.,.T.)
if !(PLBGQB8Q->(eoF()))
	nVLRCON := PLBGQB8Q->VALOR
endif
PLBGQB8Q->(dbcloseArea())

if nVLRCON > 0
	
	//B8Q_FILIAL+B8Q_SUSEP+B8Q_CMPLOT+B8Q_NUMLOT+B8Q_IDEPRE+B8Q_CPFCNP+B8Q_IDCOPR
	cChave := xFilial('B8O')+cSusep+cCmpLot+cNumLot+cIdePre+cCpfCnp+cIDCOPR
	If !B8Q->( dbSeek( cChave ) )//Inclusao

		//Gero o Lote aqui, para evitar o lote gerado e excluído, gerando sujeira na base.
		If empty(cNumLot) .and. PlprocLote( @aLote,1, cCmpLot, 4 )
			cNumLot := aLote[1]
		EndIf

		aAdd( aCampos,{ "B8Q_FILIAL",		xFilial( "B8Q" )	} )	// Filial
		aAdd( aCampos,{ "B8Q_SUSEP",		cSusep				} )	// Operadora
		aadd( aCampos,{ "B8Q_CMPLOT",		cCmpLot 			} )	// Competencia lote
		aadd( aCampos,{ "B8Q_NUMLOT",		cNumLot 			} )	// Numero de lote
		aAdd( aCampos,{ "B8Q_IDEPRE",		cIdePre				} )	// identificacao do prestador
		aAdd( aCampos,{ "B8Q_CPFCNP",		cCpfCnp				} )	// cpf / cnpf
		aAdd( aCampos,{ "B8Q_IDCOPR",		cIDCOPR				} )	// numero do contrato
		aAdd( aCampos,{ "B8Q_VLRCON",		nVLRCON				} )	// valor do contrato
		aAdd( aCampos,{ "B8Q_CDMNPR",		cCDMNPR				} )	// codigo do municipio
		aAdd( aCampos,{ "B8Q_CNES",			cCNES				} )	// cnes
		aAdd( aCampos,{ "B8Q_RGOPIN",		cRGOPIN				} )	// numero do registro da operadora intermediaria
		aAdd( aCampos,{ "B8Q_TPRGMN",		cTPRGMN				} )	// tipo de registro
		aAdd( aCampos,{ "B8Q_STATUS",		'1'					} )	// status
		
		lRet := gravaMonit( 3,aCampos,'MODEL_B8Q','PLSM270B8Q' )

	Else

		aAdd( aCampos,{ "B8Q_VLRCON",		nVLRCON				} )	// valor do contrato
		aAdd( aCampos,{ "B8Q_CDMNPR",		cCDMNPR				} )	// codigo do municipio
		aAdd( aCampos,{ "B8Q_CNES",		cCNES					} )	// cnes
		aAdd( aCampos,{ "B8Q_RGOPIN",		cRGOPIN				} )	// numero do registro da operadora intermediaria
		aAdd( aCampos,{ "B8Q_TPRGMN",		cTPRGMN				} )	// tipo de registro
		
		lRet := gravaMonit( 4,aCampos,'MODEL_B8Q','PLSM270B8Q' )

	EndIf 
endif

Return lRet
