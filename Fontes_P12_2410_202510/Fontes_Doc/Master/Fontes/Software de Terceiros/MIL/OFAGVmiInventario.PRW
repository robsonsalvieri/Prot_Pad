#include "protheus.ch"

function OFAGVmiInventario()
return .t.

/*/{Protheus.doc} mil_ver()
		Versao do fonte modelo novo

		@author Vinicius Gati
		@since  23/03/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "1"

/*/{Protheus.doc} OFAGVmiInventario
	Interface DMS - 1 da definição do VMI

	{
		"data": {
			"dealerLegalNumber": "99.999.999/0001-99",
			"extractionDateTime": "2016-11-23T10:45:00+03:00",
			"part": {
				"partNumber": "1444437P",
				"availableQuantity": 20,
			}
		}
	}

	@author Vinicius Gati
	@since 12/06/2017
/*/
Class OFAGVmiInventario from OFAGVmiBase
	Data oVmiJson
	Data oSqlHlp
	Data oDPM
	Data cIntName

	Method New() CONSTRUCTOR
	Method GetDadosPeca()
	Method Trigger()
EndClass

Method New() Class OFAGVmiInventario
	_Super:New()
	AADD(::aMapValid, {"data:dealerLegalNumber"                     , "Obri"})
	AADD(::aMapValid, {"data:part"                                  , "Obri"})
	AADD(::aMapValid, {"data:part:partNumber"                       , "Obri"})
	AADD(::aMapValid, {"data:part:availableQuantity"                , "Obri"})
	::cIntName := "DMS-1"
	::oSqlHlp  := DMS_SqlHelper():New()
	::oDPM     := DMS_DPM():New()
return self

/*/{Protheus.doc} Trigger
	Gera cabecalho do json, manda buscar os dados das peças grava json e retorna numero de controle, todas as classes vmi de interface terão esse método

	@author Vinicius Gati
	@since 16/06/2017
	@param oParams, DMS_DataContainer , Traz os dados basicos para criar uma requisição de interface, neste caso peças
/*/
Method Trigger(oParams) class OFAGVmiInventario
	Local lCargaIni := oParams:GetBool('INICIALIZACAO', .F.)
	Local cControle := ""
	Local cSQL      := ""
	Local nCntFor   := 0
	local oArHlp    := DMS_ArrayHelper():New()
	Local oJson     := DMS_DataContainer():New()
	Local aPecas    := oParams:GetValue("PECAS")
	Local aPecasOk  := {}
	Local oVmiPars  := OFAGVmiParametros():New()
	Local cGrupos   := oVmiPars:todosGrupos() // Retorna TODOS os Grupos (Originais e Paralelos) para serem utilizados nas Querys
	Local aArquiv   := oParams:GetValue("ARQUIVOS",{})

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB2") , xFilial("SB2") }) // 02 = SB2
		If NNR->(FieldPos("NNR_VDADMS")) > 0
			aAdd(aArquiv,{ self:oSqlHlp:NoLock("NNR") , xFilial("NNR") }) // 03 = NNR
		Else
			aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		EndIf
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	if lCargaIni
		aPecasOk := aClone(aPecas) // Carga Inicial ja faz checagem dos Itens
	Else
		For nCntFor := 1 to len(aPecas)
			cSQL := " SELECT COUNT(*) "
			cSQL += "   FROM "+aArquiv[01,1] // SB1
			cSQL += "  WHERE B1_FILIAL = '"+aArquiv[01,2]+"' "
			cSQL += "    AND B1_COD    = '"+aPecas[nCntFor]+"' "
			cSQL += "    AND B1_GRUPO IN ("+cGrupos+")"
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			If FM_SQL(cSQL) > 0
				aAdd(aPecasOk,aPecas[nCntFor])
			EndIf
		Next
		SA1->(dbGoTo(self:oFilHlp:GetCliente(cFilAnt)))
	EndIf

	If len(aPecasOk) > 0

		For nCntFor := 1 to len(aPecasOk)
			oJson := DMS_DataContainer():New()
			oJson:SetValue("dealerLegalNumber", self:fmtDoc(self:oVmiParametros:DocMatriz()))
			oJson:SetValue("extractionDateTime", FWTIMESTAMP(5))
			oJson:SetValue("part", self:GetDadosPeca({aPecasOk[nCntFor]},lCargaIni,aArquiv))
			cControle := self:oVmiJson:Persist( self:cIntName , oParams , {oJson} , oParams:GetValue('NUMCONTROLE') , lCargaIni )
		Next
	
	EndIf

Return cControle

/*/{Protheus.doc} GetDadosPeca
	Metodo que vai gerar os nós de pecas com dados necessários para atender <br>
	a interface inventario passadas por parametro

	@author Vinicius Gati
	@since 16/06/2017
	@param aPec, Array , Array Com b1_cods
/*/
Method GetDadosPeca(aPec,lCargaIni,aArquiv) class OFAGVmiInventario
	local cSQL := ""
	Default lCargaIni := .f.
	Default aArquiv   := {}

	If len(aArquiv) == 0
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB1") , xFilial("SB1") }) // 01 = SB1
		aAdd(aArquiv,{ self:oSqlHlp:NoLock("SB2") , xFilial("SB2") }) // 02 = SB2
		If NNR->(FieldPos("NNR_VDADMS")) > 0
			aAdd(aArquiv,{ self:oSqlHlp:NoLock("NNR") , xFilial("NNR") }) // 03 = NNR
		Else
			aAdd(aArquiv,{ ""                         , ""             }) // 03 = NNR
		EndIf
		aAdd(aArquiv,{ ""                         , ""             }) // 04 = SF4
		aAdd(aArquiv,{ ""                         , ""             }) // 05 = SD1
		aAdd(aArquiv,{ ""                         , ""             }) // 06 = VS1
		aAdd(aArquiv,{ ""                         , ""             }) // 07 = VS3
		aAdd(aArquiv,{ ""                         , ""             }) // 08 = VO1
		aAdd(aArquiv,{ ""                         , ""             }) // 09 = VO2
		aAdd(aArquiv,{ ""                         , ""             }) // 10 = VO3
		aAdd(aArquiv,{ ""                         , ""             }) // 11 = SD2
		aAdd(aArquiv,{ ""                         , ""             }) // 12 = SD3
	EndIf

	cSQL += "SELECT SB1.B1_COD partNumber,"
	cSQL += " QUANT availableQuantity "
	cSQL += " FROM "+aArquiv[01,1] // SB1
	cSQL += " JOIN ("
	cSQL += 		" SELECT B2_COD, COALESCE(SUM(SB2.B2_QATU),0) QUANT"
	cSQL += 		" FROM "+aArquiv[02,1] // SB2
	if !Empty(aArquiv[03,1]) // Tem NNR_VDADMS
		cSQL += " JOIN "+aArquiv[03,1]+" ON NNR.NNR_FILIAL = '"+aArquiv[03,2]+"' AND NNR.NNR_CODIGO = SB2.B2_LOCAL AND NNR.NNR_VDADMS = '1' AND NNR.D_E_L_E_T_ = ' ' "
	else
		cSQL += " JOIN "+aArquiv[01,1]+" ON B1_FILIAL = '"+aArquiv[01,2]+"' AND B1_COD = B2_COD AND B1_LOCPAD = B2_LOCAL AND SB1.D_E_L_E_T_ = ' ' "
	endif
	cSQL += " WHERE SB2.B2_FILIAL = '"+aArquiv[02,2]+"' "
	cSQL += " AND SB2.D_E_L_E_T_ = ' ' "
	cSQL += " GROUP BY B2_COD"
	cSQL += " ) SUBB2 ON B1_COD = B2_COD "

	cSQL += " WHERE B1_FILIAL = '"+aArquiv[01,2]+"' "
	If len(aPec) == 1
		cSQL += "   AND B1_COD = '"+aPec[1]+"' "
	Else
		cInPec := "'" + self:oArHlp:Join(aPec, "','") + "'"
		cSQL += "   AND B1_COD IN ("+cInPec+") "
	EndIf
	cSQL += "   AND SB1.D_E_L_E_T_ = ' ' "

	
	
	
	aDados := self:oSqlHlp:GetSelect({;
		{'campos', {'partNumber','availableQuantity'}},;
		{'query', cSQL} ;
	})
	If len(aDados) == 0
		oDadAux := DMS_DataContainer():New()
		aAdd(oDadAux:aData,{"partNumber",aPec[1]})
		aAdd(oDadAux:aData,{"availableQuantity",0})
		aAdd(aDados,oDadAux)
	EndIf

Return aDados[1] // Não tem envio de vários para inventario ainda
