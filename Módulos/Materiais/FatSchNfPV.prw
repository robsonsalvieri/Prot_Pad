#include "protheus.ch"
#include "fatschnfpv.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} FatSchNFPV
  @sample		FatSchNfPV
  @author		Squad CRM & Faturamento
  @since		17/12/2024
  @version	    1.0
*/
//-------------------------------------------------------------------
Function FatSchNFPV()

	Local nIDJob 		:= 0
	Local nParam		:= 1
	Local lMostraCtb	:= ""
	Local lAglutCtb		:= ""
	Local lCtbOnLine	:= ""
	Local lCtbCusto		:= ""
	Local lReajusta		:= ""
	Local nCalAcrs		:= ""
	Local nArredPrcLis	:= ""
	Local nFatMin		:= ""
	Local lAtuSA7		:= ""
	Local lECF			:= ""
	Local cTranspDe		:= ""
	Local cTranspAt		:= ""
	Local cAliasSC9 	:= ""
	Local cQrySC9   	:= ""
	Local cTamBLEST     := Space(FWSX3Util():GetFieldStruct("C9_BLEST")[3])
    Local cTamBLCRED    := Space(FWSX3Util():GetFieldStruct("C9_BLCRED")[3])
	Local cSerieMV		:= RTrim(SuperGetMV("MV_SERSCHD", .F., ""))

    FWLogMsg("INFO",, "FATSCHNFPV",,,, STR0005)

	nIDJob := Randomize(0, 100000)

	// Verifica se possui serie definida no parametro MV_SERSCHD
	If !Empty(cSerieMV)

		Pergunte("MT460A",.F.)

		lMostraCtb   := MV_PAR01 == 1
		lAglutCtb    := MV_PAR02 == 1
		lCtbOnLine   := MV_PAR03 == 1
		lCtbCusto    := MV_PAR04 == 1
		lReajusta    := MV_PAR05 == 1
		nCalAcrs     := MV_PAR07
		nArredPrcLis := MV_PAR08
		nFatMin      := MV_PAR12
		cTranspDe 	 := MV_PAR13
		cTranspAt 	 := MV_PAR14
		lAtuSA7      := MV_PAR15 == 1
		lECF         := MV_PAR16 == 2

		FWLogMsg("INFO",, "FATSCHNFPV",,,, STR0001 + FwCodFil())

		// Verifica os Pedidos que possuem itens liberados
		cQrySC9 := " SELECT C9_FILIAL, C9_PEDIDO, SC5.R_E_C_N_O_ SC5RECNO "
		cQrySC9 += " 	FROM ? SC9 "
		cQrySC9 += " INNER JOIN ? SC5 "
		cQrySC9 += " 	ON  SC5.C5_FILIAL 	= C9_FILIAL "
		cQrySC9 += " 	AND SC5.C5_NUM 		= C9_PEDIDO "
		cQrySC9 += "    AND SC5.C5_TRANSP  >= ? "
		cQrySC9 += "    AND SC5.C5_TRANSP  <= ? "
		cQrySC9 += " 	AND SC5.D_E_L_E_T_ 	= ? "
		cQrySC9 += " WHERE SC9.C9_FILIAL 	= ? "
		cQrySC9 += " 	AND SC9.C9_BLCRED 	= ? "
		cQrySC9 += " 	AND SC9.C9_BLEST 	= ? "
		cQrySC9 += " 	AND SC9.C9_BLWMS    = ? "
		cQrySC9 += " 	AND SC9.D_E_L_E_T_ 	= ? "
		cQrySC9 += " GROUP BY C9_FILIAL, C9_PEDIDO, SC5.R_E_C_N_O_ "
		cQrySC9 += " ORDER BY C9_FILIAL, C9_PEDIDO "

		oQuery := FwExecStatement():New(ChangeQuery(cQrySC9))
		oQuery:SetUnsafe(nParam++, RetSqlName("SC9") )
		oQuery:SetUnsafe(nParam++, RetSqlName("SC5") )
		oQuery:SetString(nParam++, cTranspDe )
		oQuery:SetString(nParam++, cTranspAt )
		oQuery:SetString(nParam++, ' ' )
		oQuery:SetString(nParam++, FwxFilial("SC9") )
		oQuery:SetString(nParam++, ' ' )
		oQuery:SetString(nParam++, cTamBLCRED )
		oQuery:SetString(nParam++, cTamBLEST )
		oQuery:SetString(nParam++, ' ' )

		cAliasSC9 := oQuery:OpenAlias()

		dbSelectArea(cAliasSC9)

		(cAliasSC9)->(dbGoTop())

		While (cAliasSC9)->(!Eof())

			FWLogMsg("INFO",, "FATSCHNFPV",,,, STR0002 + (cAliasSC9)->C9_PEDIDO)

			FtJobNFs("SC9", cSerieMV, lMostraCtb, lAglutCtb, lCtbOnLine, lCtbCusto, lReajusta, nCalAcrs, nArredPrcLis, nFatMin, lAtuSA7, lECF, (cAliasSC9)->C9_PEDIDO, nIdJob)

			dbSelectArea(cAliasSC9)
			(cAliasSC9)->(dbSkip())

		EndDo

		dbSelectArea(cAliasSC9)
		(cAliasSC9)->(dbCloseArea())

		oQuery:Destroy()

	Else

		FWLogMsg("WARN",, "FATSCHNFPV",,,, STR0003)

	EndIf

    FWLogMsg("INFO",, "FATSCHNFPV",,,, STR0004)

Return

//----------------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
	Realiza o tratamento do Pergunte via Schedule, não considerando	o conteúdo da tabela SXD

	@type		function
	@sample 	Scheddef()
	@Return		Array,	Parametros da rotina
    @author		Squad CRM & Faturamento
    @since		17/12/2024
    @version	1.0
/*/
//----------------------------------------------------------------------------
Static Function Scheddef() as Array

    Local aParam as Array

	aParam := { "P",;	//	Tipo R para relatorio P para processo
		"MT460A",;		//	Pergunte do relatorio, caso nao use passar ParamDef
		Nil,;			//	Alias
		Nil,;			//	Array de ordens
		Nil}			//	Título

Return aParam
