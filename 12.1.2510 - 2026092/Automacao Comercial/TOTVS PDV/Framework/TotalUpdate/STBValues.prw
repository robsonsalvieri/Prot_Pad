#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValues
Tratamento dos valores da venda

@param   
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBValues( nDescTot )
Local oTotal	:= STFGetTot() 					// Totalizador
Local lDesTot	:= ExistFunc("STBCDPGDes") .And. STBCDPGDes()
Local nL1_descto:= 0

Default nDescTot:= 0

/*/
	Atualiza totalizador
/*/
STFSetTot( "L1_VLRLIQ"	, oTotal:GetValue("L1_VLRTOT"))
STFSetTot( "L1_VALBRUT"	, oTotal:GetValue("L1_VALMERC") - oTotal:GetValue("L1_DESCONT")	)

If lDesTot
	STFSetTot("L1_DESCFIN", oTotal:GetValue("L1_DESCFIN"))
	
	nL1_descto := STDGPBasket("SL1","L1_DESCTOT")
	STDSPBasket("SL1","L1_DESCTOT", IIf( nL1_descto > 0 , nL1_descto, nDescTot))
	
	/* L1_DESCNF - Não altera a referência de desconto L1_DESCNF pois o desconto
	 inserido aqui será o da Condição de Pagamento na função STBApliDes*/
Else
	/*Porcentagem de Desconto no Total*/
	STFSetTot( "L1_DESCNF"	, STBDiscConvert(oTotal:GetValue("L1_DESCONT"), "V", oTotal:GetValue("L1_VALBRUT"))[2] )
EndIf

/*/
	Atualiza Cesta
/*/
STDSPBasket(	"SL1"	,	"L1_VALMERC"	,	oTotal:GetValue( "L1_VALMERC"	)	)
STDSPBasket(	"SL1"	,	"L1_VLRTOT"	   	,	oTotal:GetValue( "L1_VLRTOT"	)	)
STDSPBasket(	"SL1"	,	"L1_DESCONT"   	,	oTotal:GetValue( "L1_DESCONT"	)	)
STDSPBasket(	"SL1"	,	"L1_DESCNF"   	,	oTotal:GetValue( "L1_DESCNF"	)	)
STDSPBasket(	"SL1"	,	"L1_VLRLIQ"   	,	oTotal:GetValue( "L1_VLRLIQ"	)	)
STDSPBasket(	"SL1"	,	"L1_VALBRUT"   	,	oTotal:GetValue( "L1_VALBRUT"	)	)
STDSPBasket(	"SL1"	,	"L1_JUROS"   	,	oTotal:GetValue( "L1_JUROS"		)	)
STDSPBasket(	"SL1"	,	"L1_BONIF"   	,	oTotal:GetValue( "L1_BONIF"		)	)

If lDesTot
	STDSPBasket(	"SL1"	,	"L1_DESCFIN"	,	oTotal:GetValue( "L1_DESCFIN"	)	)
EndIf

Return Nil