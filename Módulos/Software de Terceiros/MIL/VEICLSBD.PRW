////////////////
// versao 04 //
////////////////

#include "protheus.ch"
#include "VEICLSBD.ch"

Function VEICLSBD()
Return

/*/{Protheus.doc} DMSB_DpePecas
	Classe que terá metodos para tratamento e geração de um arquivo DPE ou dealer parts extract
	que é o arquivo parts data, com as informações diárias do cliente

	@author       Vinicius Gati
	@since        30/03/2017
	@description  Utiliza array de arrays para salvar, recuperar e executar operacoes com dados complexos.
/*/
Class DMSB_DpePecas
	Data aData
	Data oTempTable
	Data cTableName
	Data oSqlHlp

	METHOD New() CONSTRUCTOR
	METHOD GetPecas()
	METHOD ColetaItensDia()
	METHOD Drop()
	Method TableName()
	Method CriaSBZFaltantes()
	Method CriaSB5Faltantes()
	Method AtuSBZPrimeiraEntrada()
	Method AtuSB5PrimeiraEntrada()
	Method AtuSBZUltimaVenda()
	Method AtuSB5UltimaVenda()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD New() Class DMSB_DpePecas
	Local cCreate := ""
	// Local oRpm := OFJDRpmConfig():New()
	::oSqlHlp := DMS_SqlHelper():New()
	// ::cTableName := 'DPM_DPE_PARTS'

	// if oRpm:lNovaConfiguracao
		::cTableName := 'RPM_DPE_PARTS' // novo nome para novos dados etc...
	// endif

	cCreate += "CREATE TABLE "+::cTableName+ "( "
	cCreate += "  DATAGER VARCHAR(8), "
	cCreate += "  FILIAL VARCHAR("+STR(FWSizeFilial())+"), "
	cCreate += "  PRODUTO VARCHAR("+STR(tamsx3("B1_COD")[1])+"), "
	cCreate += "  ARMAZEM VARCHAR("+STR(tamsx3("NNR_CODIGO")[1])+"), "
	cCreate += "  LOCACAO VARCHAR("+STR(tamsx3('BE_LOCALIZ')[1])+")"
	cCreate += ")"

	if ! ::oSqlHlp:ExistTable( ::cTableName )
		TcSqlExec(cCreate)
		TcSqlExec("CREATE INDEX idx_1 ON "+::cTableName+" (DATAGER, FILIAL , PRODUTO)")
		TcSqlExec("CREATE UNIQUE INDEX idx_2 ON "+::cTableName+" (DATAGER, FILIAL , PRODUTO, ARMAZEM)")
	endIf
Return SELF

/*/{Protheus.doc} GetPecas
	Retorna um array com todas as peças para geração do DPE na data informada

	@author Vinicius Gati
	@since 30/03/2017
/*/

METHOD GetPecas(dData) CLASS DMSB_DpePecas
	Local oSqlHlp := DMS_SqlHelper():New()
	Local cQuery  := ''
	cQuery += " SELECT * "
	cQuery += "   FROM " + self:cTableName
	cQuery += "  WHERE DATA = '" + DTOS(dData) + "' "
Return oSqlHlp:GetSelectArray(cQuery, 3)

/*/{Protheus.doc} Drop
	Dropa a tabela temporaria criada

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD Drop() Class DMSB_DpePecas
Return TcSqlExec("DROP TABLE "+self:cTableName) > 0

/*/{Protheus.doc} ColetaItensDia
	Cria registro dos itens na tabela temporária para uso posterior

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD ColetaItensDia(oLogger) Class DMSB_DpePecas
	Local cSQL        := ""
	Local oSqlHlp     := DMS_SqlHelper():New()
	Local oUtil       := DMS_Util():New()
	Local oDpm        := OFJDRpmConfig():New()
	Local oArrHlp     := DMS_ArrayHelper():New()
	Local cBckFil     := cFilAnt
	Local nIdx        := 1
	Local aFilis      := oDpm:GetFiliais()
	Local lSBZ        := SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
	Local lBZ_LOCALI2 := ( lSBZ .and. SBZ->(FieldPos("BZ_LOCALI2")) > 0 )
	Local cInLocais   := "(B1_LOCPAD)"
	Local dDtLItens   := ""
	DEFAULT oLogger := DMS_Logger():New("VEICLSBD_"    +dtos(ddatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")
	Private dData36At := Nil
	dData36At         := oUtil:RemoveMeses(dDataBase, 12)
	dData36At         := oUtil:RemoveMeses(dData36At, 12) // 24
	dData36At         := oUtil:RemoveMeses(dData36At, 12) // 36

	// limpeza para que a tabela não fique gigante
	TcSqlExec("DELETE FROM " + self:cTableName + " WHERE DATAGER < '"+DTOS(dDatabase-30)+"' ")


	aArms := oDpm:GetFilArms()
	oArrHlp:Merge(aFilis, aArms)

	for nIdx := 1 to LEN(aFilis)
		cFilAnt := aFilis[nIdx, 1]
		cSegmento := aFilis[nIdx, 3]


		// inserindo dados dos itens direct shipment primeiro caso tenha o campo na base
		if SB5->(FieldPos("B5_ISDSHIP")) > 0
		 	cSQL := ""
		 	cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B5_COD "
		 	cSQL += "   FROM " + RetSqlName('SB5') + " SB5 "
			if oDpm:lNovaConfiguracao
			 	cSQL += "   JOIN " + RetSqlName('SB1') + " SB1 ON B1_FILIAL = '"+xFilial('SB1')+"' AND B1_COD = B5_COD AND SB1.D_E_L_E_T_ = ' ' "
			 	cSQL += "   JOIN " + RetSqlName('SB2') + " SB2 ON B2_FILIAL = '"+xFilial('SB2')+"' AND B2_COD = B5_COD AND B2_LOCAL in "+cInLocais+" AND SB2.D_E_L_E_T_ = ' ' "
			endif
		 	cSQL += "  WHERE B5_FILIAL  = '"+xFilial('SB5')+"'"
		 	cSQL += "    AND B5_ISDSHIP = '1' "
		 	cSQL += "    AND SB5.D_E_L_E_T_ = ' ' "
		 	cSQL += "    AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName+" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B5_COD AND DATAGER = '"+DTOS(dDataBase)+"')"
		 	nOk := TcSqlExec("INSERT INTO " + self:cTableName + "(DATAGER, FILIAL, PRODUTO)" + cSQL)
		endif

		if oDpm:lNovaConfiguracao
			aArms := oDpm:oNovaConfiguracao:Armazens(cSegmento, cFilAnt)
			aArms := oArrHlp:Map(aArms, { |jArm| jArm["CODIGO_ARMAZEM"] })
			cInLocais := "('" + oArrHlp:Join(aArms, "','") + "')"
		endif

		// resto dos itens, dpm normal
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD, B2_LOCAL "
		cSQL += "   FROM " + oSqlHlp:NoLock('SB1')
		cSQL += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM  = '1' AND SBM.D_E_L_E_T_ = ' '
		cSQL += "   JOIN " + oSqlHlp:NoLock('SB2') + " ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "
		if oDpm:lNovaConfiguracao
			cSQL += " AND B2_LOCAL in "+cInLocais
		endif
		if !oDpm:lNovaConfiguracao
			cSQL += "   JOIN " + oSqlHlp:NoLock('NNR') + " ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' '
			cSQL += " AND NNR_VDADMS = '1' "
		endif
		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"' "
		cSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cSQL += "    AND B1_COD IN ("
		cSQL += "               SELECT BB1.B1_COD"
		cSQL += "					FROM "+oSqlHlp:NoLock('VS1')
		cSQL += "					JOIN "+oSqlHlp:NoLock('VS3')       +" ON VS3.VS3_FILIAL = '"+xFilial('VS3')+"' AND VS1.VS1_NUMORC = VS3.VS3_NUMORC AND VS1_DATORC BETWEEN '" + DTOS(dData36At-1) + "' AND '" + DTOS(dDatabase+1) + "' AND VS3.D_E_L_E_T_ = ' ' "
		cSQL += "                   JOIN "+oSqlHlp:NoLock('SBM', 'BBM')+" ON BBM.BM_FILIAL  = '"+xFilial('SBM')+"' AND BBM.BM_GRUPO   = VS3.VS3_GRUITE AND BBM.BM_VAIDPM = '1'            AND BBM.D_E_L_E_T_ = ' ' "
		cSQL += "					JOIN "+oSqlHlp:NoLock('SB1', 'BB1')+" ON BB1.B1_FILIAL  = '"+xFilial('SB1')+"' AND BB1.B1_GRUPO   = VS3.VS3_GRUITE AND BB1.B1_CODITE = VS3.VS3_CODITE AND BB1.D_E_L_E_T_ = ' ' "
		cSQL += "					WHERE VS1_FILIAL = '"+xFilial('VS1')+"' "
		cSQL += "					  AND VS3_QTDITE > 0  "
		cSQL += "					  AND VS1.D_E_L_E_T_ = ' ' "
		cSQL += "				GROUP BY BB1.B1_COD "
		cSQL += "   ) "
		cSQL += "   AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName +" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND ARMAZEM = B2_LOCAL AND DATAGER = '"+DTOS(dDataBase)+"') "
		oLogger:Log({"TIMESTAMP", "Coletando itens Q1 : da filial "+cFilAnt+ " Query: " + cSQL})
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + " (DATAGER, FILIAL, PRODUTO, ARMAZEM) " + cSQL)
		oLogger:Log({"TIMESTAMP", "Finalizado"})
		if nOk < 0 .or. ExistBlock('VBD01')
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		end

		// resto dos itens, dpm normal
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD, B2_LOCAL "
		cSQL += "   FROM " + oSqlHlp:NoLock('SB1')
		cSQL += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM  = '1' AND SBM.D_E_L_E_T_ = ' '
		cSQL += "   JOIN " + oSqlHlp:NoLock('SB2') + " ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "
		if oDpm:lNovaConfiguracao
			cSQL += " AND B2_LOCAL in "+cInLocais
		endif
		if !oDpm:lNovaConfiguracao
			cSQL += "   JOIN " + RetSqlName('NNR') + " NNR ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' '
			cSQL += " AND NNR_VDADMS = '1' "
		endif
		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"' "
		cSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cSQL += "    AND B1_GRUPO IN " + oDpm:GetInGroups()
		cSQL += "    AND B1_COD IN ("
		cSQL += "        SELECT VB8CH.VB8_PRODUT FROM "+oSqlHlp:NoLock('VB8', 'VB8CH')+" WHERE VB8CH.VB8_FILIAL = '"+xFilial('VB8')+"' AND VB8CH.VB8_PRODUT = B1_COD AND ("+oSqlHlp:Concat({'VB8CH.VB8_ANO', 'VB8CH.VB8_MES', 'VB8CH.VB8_DIA'})+") BETWEEN '" + DTOS(dData36At-1) + "' AND '" + DTOS(dDatabase+1) + "' AND VB8CH.D_E_L_E_T_ = ' ' "
		cSQL += "   ) "
		cSQL += "   AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName +" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND ARMAZEM = B2_LOCAL AND DATAGER = '"+DTOS(dDataBase)+"') "
		oLogger:Log({"TIMESTAMP", "Coletando itens Q2 : da filial "+cFilAnt+ " Query: " + cSQL})
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + " (DATAGER, FILIAL, PRODUTO, ARMAZEM) " + cSQL)
		oLogger:Log({"TIMESTAMP", "Finalizado"})
		if nOk < 0 .or. ExistBlock('VBD02')
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		end

		// resto dos itens, dpm normal
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD, B2_LOCAL "
		cSQL += "   FROM " + oSqlHlp:NoLock('SB1')
		cSQL += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM  = '1' AND SBM.D_E_L_E_T_ = ' '
		cSQL += "   JOIN " + oSqlHlp:NoLock('SB2') + " ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "
		if oDpm:lNovaConfiguracao
			cSQL += " AND B2_LOCAL in "+cInLocais
		endif
		if !oDpm:lNovaConfiguracao
			cSQL += "   JOIN " + RetSqlName('NNR') + " NNR ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' '
			cSQL += " AND NNR_VDADMS = '1' "
		endif
		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"' "
		cSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cSQL += "    AND B1_COD IN ("
		cSQL += "        SELECT B9_COD     FROM "+oSqlHlp:NoLock('SB9')+" WHERE B9_FILIAL = '"+xFilial('SB9')+"' AND B9_COD = B1_CODITE AND B9_QINI > 0 AND SB9.D_E_L_E_T_ = ' ' "
		cSQL += "   ) "
		cSQL += "   AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName +" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND ARMAZEM = B2_LOCAL AND DATAGER = '"+DTOS(dDataBase)+"') "
		oLogger:Log({"TIMESTAMP", "Coletando itens Q3 : da filial "+cFilAnt})
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + " (DATAGER, FILIAL, PRODUTO, ARMAZEM) " + cSQL)
		oLogger:Log({"TIMESTAMP", "Finalizado"})
		if nOk < 0 .or. ExistBlock('VBD03')
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		end

		// resto dos itens, dpm normal
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD, B2_LOCAL "
		cSQL += "   FROM " + oSqlHlp:NoLock('SB1')
		cSQL += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM  = '1' AND SBM.D_E_L_E_T_ = ' '
		cSQL += "   JOIN " + oSqlHlp:NoLock('SB2') + " ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "
		if oDpm:lNovaConfiguracao
			cSQL += " AND B2_LOCAL in "+cInLocais
		endif
		if !oDpm:lNovaConfiguracao
			cSQL += "   JOIN " + RetSqlName('NNR') + " NNR ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' '
			cSQL += " AND NNR_VDADMS = '1' "
		endif
		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"' "
		cSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cSQL += "    AND B1_COD IN ("
		cSQL += "        SELECT B2_COD     FROM "+oSqlHlp:NoLock('SB2')+" WHERE B2_FILIAL = '"+xFilial('SB2')+"' AND B2_COD = B1_CODITE AND B2_QATU > 0 AND SB2.D_E_L_E_T_ = ' ' "
		cSQL += "   ) "
		cSQL += "   AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName +" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND ARMAZEM = B2_LOCAL AND DATAGER = '"+DTOS(dDataBase)+"') "
		oLogger:Log({"TIMESTAMP", "Coletando itens Q4 : da filial "+cFilAnt})
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + " (DATAGER, FILIAL, PRODUTO, ARMAZEM) " + cSQL)
		oLogger:Log({"TIMESTAMP", "Finalizado"})
		if nOk < 0 .or. ExistBlock('VBD04')
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		end

		// resto dos itens, dpm normal
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD, B2_LOCAL "
		cSQL += "   FROM " + oSqlHlp:NoLock('SB1')
		cSQL += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM  = '1' AND SBM.D_E_L_E_T_ = ' '
		cSQL += "   JOIN " + oSqlHlp:NoLock('SB2') + " ON SB2.B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD AND SB2.D_E_L_E_T_ = ' ' "
		if oDpm:lNovaConfiguracao
			cSQL += " AND B2_LOCAL in "+cInLocais
		endif
		if !oDpm:lNovaConfiguracao
			cSQL += "   JOIN " + RetSqlName('NNR') + " NNR ON NNR.NNR_FILIAL = '"+xFilial('NNR')+"' AND NNR_CODIGO = B2_LOCAL AND NNR.D_E_L_E_T_ = ' '
			cSQL += " AND NNR_VDADMS = '1' "
		endif
		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"' "
		cSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cSQL += "    AND B1_COD IN ("
		cSQL += "        SELECT C7_PRODUTO FROM "+oSqlHlp:NoLock('SC7')+" WHERE C7_FILIAL = '"+xFilial('SC7')+"' AND C7_PRODUTO = B1_COD AND C7_PEDFAB != ' ' AND SC7.D_E_L_E_T_ = ' ' "
		cSQL += "   ) "
		cSQL += "   AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName +" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND ARMAZEM = B2_LOCAL AND DATAGER = '"+DTOS(dDataBase)+"') "
		oLogger:Log({"TIMESTAMP", "Coletando itens Q5 : da filial "+cFilAnt})
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + " (DATAGER, FILIAL, PRODUTO, ARMAZEM) " + cSQL)
		oLogger:Log({"TIMESTAMP", "Finalizado"})
		if nOk < 0 .or. ExistBlock('VBD05')
			MSGSTOP("Erro de sql detectado: " + TCSQLError())
		end

		// registros originados a partir de uma importação de lista de preço
		cSQL := ""
		cSQL += " SELECT '"+DTOS(dDataBase)+"' ,'"+xFilial('VS3')+"', B1_COD "
		cSQL += "   FROM " + RetSqlName('SB1') + " SB1 "
		cSQL += "   JOIN " + oSqlHlp:NoLock('SBM') + " ON BM_FILIAL = '"+xFilial('SBM')+"' AND SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.BM_VAIDPM  = '1' AND SBM.D_E_L_E_T_ = ' '

		if GetNewPar("MV_MIL0054","SBZ") == "SBZ"
			cSQL += " JOIN " + RetSqlName('SBZ') + " BZ ON BZ_FILIAL = '" + xFilial("SBZ") + "' AND BZ.BZ_COD = B1_COD AND BZ.BZ_PRIENT <> ' ' AND BZ.D_E_L_E_T_ = ' ' "
		else
			cSQL += " JOIN " + RetSqlName('SB5') + " B5 ON B5_FILIAL = '" + xFilial("SB5") + "' AND B5.B5_COD = B1_COD AND B5.B5_DTADDED <> ' ' AND B5.D_E_L_E_T_ = ' ' "
		endif

		//Busca a ultima data da importação de lista de preços
		dDtLItens := FM_SQL("SELECT MAX(VQL_DATAF) FROM " +RetSQLName("VQL") + " WHERE VQL_AGROUP = 'OFINJD01' AND VQL_TIPO = 'LOG_EXECUCAO' AND VQL_DATAF <> ' ' AND D_E_L_E_T_ = ' ' ")

		cSQL += "  WHERE B1_FILIAL  = '"+xFilial('SB1')+"'"
		cSQL += "    AND SB1.B1_DTREFP1 >= '" + dDtLItens + "'"
		cSQL += "    AND SB1.D_E_L_E_T_ = ' ' "
		cSQL += "    AND NOT EXISTS (SELECT PRODUTO FROM "+self:cTableName+" WHERE FILIAL = '"+xFilial('VS3')+"' AND PRODUTO = B1_COD AND DATAGER = '"+DTOS(dDataBase)+"')"
		nOk := TcSqlExec("INSERT INTO " + self:cTableName + "(DATAGER, FILIAL, PRODUTO)" + cSQL)

		if lSBZ .AND. lBZ_LOCALI2
			if tcGetDb() == "ORACLE"
				cSQL := " UPDATE "+self:cTableName+" T1 "
				cSQL += "    SET LOCACAO = ( "
				cSQL += "         SELECT T2.BZ_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SBZ')+" T2 "
				cSQL += "          WHERE T2.BZ_FILIAL   = '"+xFilial('SBZ')+"' "
				cSQL += "            AND T2.BZ_COD      = T1.PRODUTO "
				cSQL += "            AND T2.BZ_LOCALI2 != ' ' "
				cSQL += "            AND T2.D_E_L_E_T_  = ' ' "
				cSQL += " ) "
				cSQL += " WHERE T1.FILIAL  = '"+xFilial('VS3')+"' "
				cSQL += "   AND T1.LOCACAO is null "
				cSQL += "   AND EXISTS ( "
				cSQL += "       SELECT T3.BZ_LOCALI2 "
				cSQL += "         FROM "+RetSqlName('SBZ')+" T3 "
				cSQL += "          WHERE T3.BZ_FILIAL   = '"+xFilial('SBZ')+"' "
				cSQL += "            AND T3.BZ_COD      = T1.PRODUTO "
				cSQL += "            AND T3.BZ_LOCALI2 != ' ' "
				cSQL += "            AND T3.D_E_L_E_T_  = ' ' "
				cSQL += "   ) "
			else
				cSQL := " UPDATE "+self:cTableName
				cSQL += "    SET LOCACAO = TMP.BZ_LOCALI2 "
				cSQL += "   FROM (SELECT BZ_FILIAL, BZ_COD, BZ_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SBZ')+" BZ"
				cSQL += "          WHERE BZ.BZ_FILIAL  = '"+xFilial('SBZ')+"' "
				cSQL += "            AND BZ.BZ_LOCALI2 != ' ' "
				cSQL += "            AND BZ.D_E_L_E_T_ = ' ') TMP "
				cSQL += "  WHERE "+self:cTableName+".FILIAL    = '"+xFilial('VS3')+"' "
				cSQL += "    AND TMP.BZ_FILIAL                 = '"+xFilial('SBZ')+"' "
				cSQL += "    AND "+self:cTableName+".PRODUTO   = TMP.BZ_COD "
				cSQL += "    AND "+self:cTableName+".LOCACAO   is null "
			endif
			if tcSqlExec(cSQL) < 0 .or. ExistBlock('VBD06')
				MSGSTOP("Erro de sql detectado: " + TCSQLError())
				conout(TCSQLError())
			endif
		end

		if SB5->(FieldPos('B5_LOCALI2')) > 0
			if tcGetDb() == "ORACLE"
				cSQL := " UPDATE "+self:cTableName+" T1 "
				cSQL += "    SET LOCACAO = ( "
				cSQL += "         SELECT T2.B5_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SB5')+" T2 "
				cSQL += "          WHERE T2.B5_FILIAL   = '"+xFilial('SB5')+"' "
				cSQL += "            AND T2.B5_COD      = T1.PRODUTO "
				cSQL += "            AND T2.B5_LOCALI2 != ' ' "
				cSQL += "            AND T2.D_E_L_E_T_  = ' ' "
				cSQL += " ) "
				cSQL += " WHERE T1.FILIAL  = '"+xFilial('VS3')+"' "
				cSQL += "   AND T1.LOCACAO is null "
				cSQL += "   AND EXISTS ( "
				cSQL += "       SELECT T3.B5_LOCALI2 "
				cSQL += "         FROM "+RetSqlName('SB5')+" T3 "
				cSQL += "          WHERE T3.B5_FILIAL   = '"+xFilial('SB5')+"' "
				cSQL += "            AND T3.B5_COD      = T1.PRODUTO "
				cSQL += "            AND T3.B5_LOCALI2 != ' ' "
				cSQL += "            AND T3.D_E_L_E_T_  = ' ' "
				cSQL += "   ) "
			else
				cSQL := " UPDATE "+self:cTableName
				cSQL += "    SET LOCACAO = TMP.B5_LOCALI2 "
				cSQL += "   FROM (SELECT B5_FILIAL, B5_COD, B5_LOCALI2 "
				cSQL += "           FROM "+RetSqlName('SB5')
				cSQL += "          WHERE B5_FILIAL  = '"+xFilial('SB5')+"' "
				cSQL += "            AND B5_LOCALI2 != ' ' "
				cSQL += "            AND D_E_L_E_T_ = ' ') TMP "
				cSQL += "  WHERE "+self:cTableName+".FILIAL    = '"+xFilial('VS3')+"' "
				cSQL += "    AND TMP.B5_FILIAL                 = '"+xFilial('SB5')+"' "
				cSQL += "    AND "+self:cTableName+".PRODUTO   = TMP.B5_COD "
				cSQL += "    AND "+self:cTableName+".LOCACAO   is null "
			endif
			if tcSqlExec(cSQL) < 0 .or. ExistBlock('VBD07')
				MSGSTOP("Erro de sql detectado: " + TCSQLError())
				conout(TCSQLError())
			endif
			// evita os nulos
			tcSqlExec("UPDATE "+self:cTableName+ " SET LOCACAO = ' ' WHERE LOCACAO is null")
		endif
	next

	cFilAnt := cBckFil
Return .T.

/*/{Protheus.doc} TableName
	Retorna nome da tabela temporaria criada

	@author Vinicius Gati
	@since 30/03/2017
/*/
METHOD TableName() CLASS DMSB_DpePecas
Return self:cTableName

/*/{Protheus.doc} CriaSBZFaltantes
	Cria SBZ para itens que ainda não tem

	@type method
	@author Vinicius Gati
	@since 20/08/2024
/*/
Method CriaSBZFaltantes() Class DMSB_DpePecas
	local cAl := GetNextAlias()
	local cQuery := ""
	cQuery := "SELECT B1_COD FROM " + ::oSqlHlp:NoLock("SB1")
	cQuery += " WHERE D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND"
	cQuery += " B1_COD NOT IN ( SELECT BZ_COD FROM " + ::oSqlHlp:NoLock("SBZ") + " WHERE BZ_COD = SB1.B1_COD AND BZ_FILIAL = '"+xFilial("SBZ")+"' AND D_E_L_E_T_ = ' ' ) "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
	While !(cAl)->(Eof())
		DbSelectArea("SBZ")
		Reclock("SBZ",.t.)
		SBZ->BZ_FILIAL := xFilial("SBZ")
		SBZ->BZ_COD := (cAl)->(B1_COD)
		msunlock()
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
Return
	
/*/{Protheus.doc} CriaSB5Faltantes
	Cria SB5 para itens que ainda não tem

	@type method
	@author Vinicius Gati
	@since 20/08/2024
/*/
Method CriaSB5Faltantes() Class DMSB_DpePecas
	local cAl := GetNextAlias()
	local cQuery := ""
	cQuery := "SELECT B1_COD FROM " + ::oSqlHlp:NoLock("SB1")
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND"
	cQuery += "   NOT EXISTS ( SELECT B5_COD FROM "+ ::oSqlHlp:NoLock("SB5")+" WHERE B5_COD = SB1.B1_COD AND B5_FILIAL = '"+xFilial("SB5")+"' AND SB5.D_E_L_E_T_ = ' ' ) "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAl , .F. , .T. )
	While !(cAl)->(Eof())
		DbSelectArea("SB5")
		Reclock("SB5", .t.)
		SB5->B5_FILIAL := xFilial("SB5")
		SB5->B5_COD    := (cAl)->(B1_COD)
		msunlock()
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSBZPrimeiraEntrada
	Atualiza a data da primeira entrada na SBZ com base nos dados de SBZ, SB9 e SD1.
	
	@type    method
	@author  Daniel
	@since   21/07/2025
/*/
//-------------------------------------------------------------------
Method AtuSBZPrimeiraEntrada(oLogger) Class DMSB_DpePecas
	Local nI 		 := 1
	Local cUpdate	 := ""
	Local cSubQuery  := ""
	Local cBkpFilial := ""
	Local cPreTbl    := IIf(ALLTRIM(TcGetDb()) <> "ORACLE", " AS ", "")
	Local oDpm       := OFJDRpmConfig():New()
	Local aFilis     := oDpm:GetFiliais()
	Default oLogger  := DMS_Logger():New("VEICLSBD_"+ dtos(ddatabase)+"_"+ SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) +".LOG")

	oLogger:Log({"TIMESTAMP", STR0003}) // "Atualizando data de primeira entrada na SBZ"
	cBkpFilial := cFilant

	For nI := 1 to len(aFilis)
		cFilant := aFilis[nI, 1]

		cSubQuery := " 	SELECT COD, MIN(DTADDED) AS MenorData "
		cSubQuery += " 	FROM ( "
							// Origem 1: SBZ
		cSubQuery += " 		SELECT BZ_FILIAL, BZ_COD AS COD, MIN(BZ_PRIENT) AS DTADDED "
		cSubQuery += " 		FROM "+RetSQLName('SBZ')+" SBZ "
		cSubQuery += " 		WHERE SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		GROUP BY BZ_FILIAL, BZ_COD "

							// Origem 2: SB9
		cSubQuery += " 		UNION "
		cSubQuery += " 		SELECT B9_FILIAL, B9_COD AS COD, MIN(B9_DATA) AS DTADDED "
		cSubQuery += " 		FROM "+RetSQLName('SB9')+" SB9 "
		cSubQuery += " 		WHERE B9_FILIAL = '"+xFilial('SB9')+"' AND SB9.D_E_L_E_T_ = ' ' AND B9_DATA <> ' ' AND B9_QINI > 0 "
		cSubQuery += " 		GROUP BY B9_FILIAL, B9_COD "

							// Origem 3: SD1
		cSubQuery += " 		UNION "
		cSubQuery += " 		SELECT D1_FILIAL, D1_COD AS COD, MIN(SD1.D1_DTDIGIT) AS DTADDED "
		cSubQuery += " 		FROM "+RetSQLName('SD1')+" SD1 "
		cSubQuery += " 		JOIN "+RetSQLName('SF4')+" SF4 "
		cSubQuery += " 			ON SF4.F4_FILIAL = '"+xFilial('SF4')+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV IN ('01', '03') AND SF4.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DTDIGIT <= '"+DToS(dDataBase)+"' AND SD1.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		GROUP BY D1_FILIAL, D1_COD "
		cSubQuery += " 	) "+ cPreTbl +" TodasDatas "
		cSubQuery += " 	WHERE DTADDED <> ' ' "
		cSubQuery += " 	GROUP BY COD "

		If TCGetDB() == "ORACLE"
			cUpdate := "MERGE INTO "+ RetSqlName('SBZ') +" SBZ "
			cUpdate += "USING ( "
			cUpdate += cSubQuery
			cUpdate += ") Sub "
			cUpdate += "ON (SBZ.BZ_COD = Sub.COD AND SBZ.BZ_FILIAL = '"+ xFilial('SBZ') +"' AND SBZ.D_E_L_E_T_ = ' ') "
			cUpdate += "WHEN MATCHED THEN "
			cUpdate += "UPDATE SET SBZ.BZ_ULTVDA = Sub.ULTVDA "
		Else
			cUpdate := " UPDATE "+RetSQLName('SBZ') 
			cUpdate += " SET BZ_PRIENT = Sub.MenorData "
			cUpdate += " FROM "+RetSQLName('SBZ')+" SBZ "
			cUpdate += " INNER JOIN ( "
			cUpdate += cSubQuery
			cUpdate += " ) AS Sub ON Sub.COD = SBZ.BZ_COD "
			cUpdate += " WHERE SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' "
			cUpdate += "   AND SBZ.D_E_L_E_T_ = ' ' " 
		Endif

		If TCSqlExec(cUpdate) < 0
			conout(STR0001 + cFilant +" | "+ STR0002 + TCSQLError()) //"Filial: " // "Não foi possível atualizar as datas:"
			oLogger:Log({"TIMESTAMP", STR0001 + cFilant +" | "+ STR0002 + TCSQLError()}) // "Não foi possível atualizar as datas:"
		Endif	
	Next

	cFilant := cBkpFilial
	oLogger:Log({"TIMESTAMP", STR0005}) // "Fim da atualizacao de primeira entrada na SBZ"
	conout(STR0005) // "Fim da atualizacao de primeira entrada na SBZ"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSB5PrimeiraEntrada
	Atualiza a data da primeira entrada na SB5 com base nos dados de SB5, SB9 e SD1.
	
	@type    method
	@author  Daniel
	@since   21/07/2025
/*/
//-------------------------------------------------------------------
Method AtuSB5PrimeiraEntrada(oLogger) Class DMSB_DpePecas
	Local nI 		 := 1
	Local cUpdate	 := ""
	Local cSubQuery  := ""
	Local cBkpFilial := ""
	Local cPreTbl    := IIf(ALLTRIM(TcGetDb()) <> "ORACLE", " AS ", "")
	Local oDpm       := OFJDRpmConfig():New()
	Local aFilis     := oDpm:GetFiliais()
	Default oLogger  := DMS_Logger():New("VEICLSBD_"+ dtos(ddatabase)+"_"+ SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) +".LOG")

	oLogger:Log({"TIMESTAMP", STR0004}) // "Atualizando data de primeira entrada na SB5"
	cBkpFilial := cFilant

	For nI := 1 to len(aFilis)
		cFilant := aFilis[nI, 1]

		cSubQuery := " 	SELECT COD, MIN(DTADDED) AS MenorData "
		cSubQuery += " 	FROM ( "
							// Origem 1: SB5
		cSubQuery += " 		SELECT B5_FILIAL, B5_COD AS COD, MIN(B5_PRIENT) AS DTADDED "
		cSubQuery += " 		FROM "+RetSQLName('SB5')+" SB5 "
		cSubQuery += " 		WHERE SB5.B5_FILIAL = '"+xFilial('SB5')+"' AND SB5.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		GROUP BY B5_FILIAL, B5_COD "

							// Origem 2: SB9
		cSubQuery += " 		UNION "
		cSubQuery += " 		SELECT B9_FILIAL, B9_COD AS COD, MIN(B9_DATA) AS DTADDED "
		cSubQuery += " 		FROM "+RetSQLName('SB9')+" SB9 "
		cSubQuery += " 		WHERE B9_FILIAL = '"+xFilial('SB9')+"' AND SB9.D_E_L_E_T_ = ' ' AND B9_DATA <> ' ' AND B9_QINI > 0 "
		cSubQuery += " 		GROUP BY B9_FILIAL, B9_COD "

							// Origem 3: SD1
		cSubQuery += " 		UNION "
		cSubQuery += " 		SELECT D1_FILIAL, D1_COD AS COD, MIN(SD1.D1_DTDIGIT) AS DTADDED "
		cSubQuery += " 		FROM "+RetSQLName('SD1')+" SD1 "
		cSubQuery += " 		JOIN "+RetSQLName('SF4')+" SF4 "
		cSubQuery += " 			ON SF4.F4_FILIAL = '"+xFilial('SF4')+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_OPEMOV IN ('01', '03') AND SF4.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		WHERE SD1.D1_FILIAL = '"+xFilial('SD1')+"' AND SD1.D1_DTDIGIT <= '"+DToS(dDataBase)+"' AND SD1.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		GROUP BY D1_FILIAL, D1_COD "
		cSubQuery += " 	) "+ cPreTbl +" TodasDatas "
		cSubQuery += " 	WHERE DTADDED <> ' ' "
		cSubQuery += " 	GROUP BY COD "

		If TCGetDB() == "ORACLE"
			cUpdate := "MERGE INTO "+ RetSqlName('SB5') +" SB5 "
			cUpdate += "USING ( "
			cUpdate += cSubQuery
			cUpdate += ") Sub "
			cUpdate += "ON (SB5.B5_COD = Sub.COD AND SB5.B5_FILIAL = '"+ xFilial('SB5') +"' AND SB5.D_E_L_E_T_ = ' ') "
			cUpdate += "WHEN MATCHED THEN "
			cUpdate += "UPDATE SET SB5.B5_ULTVDA = Sub.ULTVDA "
		Else
			cUpdate := " UPDATE "+RetSQLName('SB5') 
			cUpdate += " SET B5_PRIENT = Sub.MenorData "
			cUpdate += " FROM "+RetSQLName('SB5')+" SB5 "
			cUpdate += " INNER JOIN ( "
			cUpdate += cSubQuery
			cUpdate += " ) AS Sub ON Sub.COD = SB5.B5_COD "
			cUpdate += " WHERE SB5.B5_FILIAL = '"+xFilial('SB5')+"' "
			cUpdate += "   AND SB5.D_E_L_E_T_ = ' ' " 
		Endif


		If TCSqlExec(cUpdate) < 0
			conout(STR0001 + cFilant +" | "+ STR0002 + TCSQLError()) // "Não foi possível atualizar as datas:"
			oLogger:Log({"TIMESTAMP", STR0001 + cFilant +" | "+ STR0002 + TCSQLError()}) // "Não foi possível atualizar as datas:"
		Endif	
	Next

	cFilant := cBkpFilial
	oLogger:Log({"TIMESTAMP", STR0006}) // "Fim da atualizacao de primeira entrada na SB5"
	conout(STR0006) // "Fim da atualizacao de primeira entrada na SB5"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSBZUltimaVenda
	Atualiza data da ultima venda na SBZ com base na SBZ, SD2 e VB8 description

	@type    method
	@author  Daniel
	@since   25/07/2025
/*/
//-------------------------------------------------------------------
Method AtuSBZUltimaVenda(oLogger) Class DMSB_DpePecas
	Local nI      := 1
	Local cUpdate := ""
	Local cSubQuery  := ""
	Local cBkpFilial := ""
	Local cPreTbl    := IIf(ALLTRIM(TcGetDb()) <> "ORACLE", " AS ", "")
	Local aFilis     := oDpm:GetFiliais()	
	Local oDpm       := OFJDRpmConfig():New()
	Local oSqlHlp    := DMS_SqlHelper():New()
	Default oLogger  := DMS_Logger():New("VEICLSBD_"+ dtos(ddatabase)+"_"+ SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) +".LOG")

	oLogger:Log({"TIMESTAMP", STR0007}) // "Atualizando data da ultima venda na SBZ"
	cBkpFilial := cFilant

	For nI := 1 to len(aFilis)
		cFilant := aFilis[nI, 1]
		
		cSubQuery := " 	SELECT COD, MAX(ULTVDA) AS UltimaVenda "
		cSubQuery += " 	FROM ( "
							// Origem 1: SBZ 
		cSubQuery += " 		SELECT BZ_FILIAL, BZ_COD AS COD, MAX(BZ_ULTVDA) ULTVDA "
		cSubQuery += " 		FROM "+RetSqlName('SBZ')+" SBZ "
		cSubQuery += " 		WHERE SBZ.BZ_FILIAL = '" +xFilial('SBZ')+ "' AND SBZ.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		GROUP BY BZ_FILIAL, BZ_COD "
							// Origem 2: SD2 
		cSubQuery += "			UNION "
		cSubQuery += "			SELECT D2_FILIAL, D2_COD AS COD, MAX(SD2.D2_EMISSAO) AS ULTVDA "
		cSubQuery += "			FROM  "+ RetSqlName('SD2') +" SD2 "
		cSubQuery += "			JOIN  "+ RetSQLName('SF4') +" SF4 ON SF4.F4_FILIAL = '"+ xFilial('SF4') +"'  AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV IN ('05') AND SF4.D_E_L_E_T_ = ' ' "
		cSubQuery += "			WHERE D2_FILIAL = '"+ xFilial('SD2') +"' AND D2_EMISSAO <= '"+ DToS(dDataBase) +"' AND SD2.D_E_L_E_T_ = ' ' "
		cSubQuery += "			GROUP BY D2_FILIAL, D2_COD "
							// Origem 3: VB8 
		cSubQuery += " 		UNION "
		cSubQuery += " 		SELECT VB8_FILIAL, VB8_PRODUT AS COD, MAX("+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})+") AS ULTVDA "
		cSubQuery += " 		FROM "+ RetSqlName('VB8') +" VB8 "
		cSubQuery += " 		WHERE VB8_FILIAL = '"+ xFilial('VB8') +"' 
		cSubQuery += " 			AND "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})+" < '"+DToS(dDataBase)+"' 
		cSubQuery += " 			AND ( VB8_VDAB > 0 OR VB8_VDAO > 0 OR VB8_VDAI > 0 ) AND VB8.D_E_L_E_T_ = ' '  "
		cSubQuery += " 		GROUP BY VB8_FILIAL, VB8_PRODUT "
		cSubQuery += " 	) "+ cPreTbl +" TodasUltimasVendas "
		cSubQuery += " 	WHERE ULTVDA <> ' ' "
		cSubQuery += " 	GROUP BY COD "

		If TCGetDB() == "ORACLE"
			cUpdate := "MERGE INTO "+ RetSqlName('SBZ') +" SBZ "
			cUpdate += "USING ( "
			cUpdate += cSubQuery
			cUpdate += ") Sub "
			cUpdate += "ON (SBZ.BZ_COD = Sub.COD AND SBZ.BZ_FILIAL = '01' AND SBZ.D_E_L_E_T_ = ' ') "
			cUpdate += "WHEN MATCHED THEN "
			cUpdate += "UPDATE SET SBZ.BZ_ULTVDA = Sub.ULTVDA "
		Else
			cUpdate := " UPDATE " + RetSQLName('SBZ')
			cUpdate += " SET BZ_ULTVDA = Sub.UltimaVenda "
			cUpdate += " FROM " + RetSQLName('SBZ') + " SBZ" 
			cUpdate += " INNER JOIN ( "
			cUpdate += cSubQuery
			cUpdate += " 	) as Sub ON Sub.COD = SBZ.BZ_COD  "
			cUpdate += " WHERE BZ_FILIAL = '"+ xFilial('SBZ') +"'  "
			cUpdate += " AND SBZ.D_E_L_E_T_ = ' ' "
		Endif	

		If TCSqlExec(cUpdate) < 0
			conout(STR0001 + cFilant +" | "+ STR0002 + TCSQLError()) // "Não foi possível atualizar as datas:"
			oLogger:Log({"TIMESTAMP", STR0001 + cFilant +" | "+ STR0002 + TCSQLError()}) // "Não foi possível atualizar as datas:"
		Endif
	Next 
	
	cFilant := cBkpFilial
	oLogger:Log({"TIMESTAMP", STR0009}) // "Fim da atualizacao da ultima venda na SBZ"
	conout(STR0009) // "Fim da atualizacao da ultima venda na SBZ"
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSB5UltimaVenda
	Atualiza data da ultima venda na SB5 com base na SB5, SD2 e VB8 description

	@type    method
	@author  Daniel
	@since   25/07/2025
/*/
//-------------------------------------------------------------------
Method AtuSB5UltimaVenda(oLogger) Class DMSB_DpePecas
	Local nI      := 1
	Local cUpdate := ""
	Local cSubQuery  := ""
	Local cBkpFilial := ""
	Local cPreTbl    := IIf(ALLTRIM(TcGetDb()) <> "ORACLE", " AS ", "")
	Local oDpm       := OFJDRpmConfig():New()
	Local aFilis     := oDpm:GetFiliais()	
	Default oLogger  := DMS_Logger():New("VEICLSBD_"+ dtos(ddatabase)+"_"+ SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) +".LOG")

	oLogger:Log({"TIMESTAMP", STR0008}) // "Atualizando data da ultima venda na SB5"
	cBkpFilial := cFilant

	For nI := 1 to len(aFilis)
		cFilant := aFilis[nI, 1]
		
		cSubQuery := " 	SELECT COD, MAX(ULTVDA) AS UltimaVenda "
		cSubQuery += " 	FROM ( "
							// Origem 1: SB5 
		cSubQuery += " 		SELECT B5_FILIAL, B5_COD AS COD, MAX(B5_ULTVDA) ULTVDA "
		cSubQuery += " 		FROM "+RetSqlName('SB5')+" SB5 "
		cSubQuery += " 		WHERE SB5.B5_FILIAL = '" +xFilial('SB5')+ "' AND SB5.D_E_L_E_T_ = ' ' "
		cSubQuery += " 		GROUP BY B5_FILIAL, B5_COD "
							// Origem 2: SD2 
		cSubQuery += "			UNION "
		cSubQuery += "			SELECT D2_FILIAL, D2_COD AS COD, MAX(SD2.D2_EMISSAO) AS ULTVDA "
		cSubQuery += "			FROM  "+ RetSqlName('SD2') +" SD2 "
		cSubQuery += "			JOIN  "+ RetSQLName('SF4') +" SF4 ON SF4.F4_FILIAL = '"+ xFilial('SF4') +"'  AND SF4.F4_CODIGO = SD2.D2_TES AND SF4.F4_OPEMOV IN ('05') AND SF4.D_E_L_E_T_ = ' ' "
		cSubQuery += "			WHERE D2_FILIAL = '"+ xFilial('SD2') +"' AND D2_EMISSAO <= '"+ DToS(dDataBase) +"' AND SD2.D_E_L_E_T_ = ' ' "
		cSubQuery += "			GROUP BY D2_FILIAL, D2_COD "
							// Origem 3: VB8 
		cSubQuery += " 		UNION "
		cSubQuery += " 		SELECT VB8_FILIAL, VB8_PRODUT AS COD, MAX("+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})+") AS ULTVDA "
		cSubQuery += " 		FROM "+ RetSqlName('VB8') +" VB8 "
		cSubQuery += " 		WHERE VB8_FILIAL = '"+ xFilial('VB8') +"' 
		cSubQuery += " 			AND "+oSqlHlp:Concat({'VB8_ANO', 'VB8_MES', 'VB8_DIA'})+" < '"+DToS(dDataBase)+"' 
		cSubQuery += " 			AND ( VB8_VDAB > 0 OR VB8_VDAO > 0 OR VB8_VDAI > 0 ) AND VB8.D_E_L_E_T_ = ' '  "
		cSubQuery += " 		GROUP BY VB8_FILIAL, VB8_PRODUT "
		cSubQuery += " 	) "+ cPreTbl +" TodasUltimasVendas "
		cSubQuery += " 	WHERE ULTVDA <> ' ' "
		cSubQuery += " 	GROUP BY COD "

		If TCGetDB() == "ORACLE"
			cUpdate := "MERGE INTO "+ RetSQLName('SB5') +" SB5 "
			cUpdate += "USING ( "
			cUpdate += cSubQuery
			cUpdate += ") Sub "
			cUpdate += "ON (SB5.B5_COD = Sub.COD AND SB5.B5_FILIAL = '01' AND SB5.D_E_L_E_T_ = ' ') "
			cUpdate += "WHEN MATCHED THEN "
			cUpdate += "UPDATE SET SB5.B5_ULTVDA = Sub.ULTVDA "
		Else
			cUpdate := " UPDATE " + RetSQLName('SB5')
			cUpdate += " SET B5_ULTVDA = Sub.UltimaVenda "
			cUpdate += " FROM " + RetSQLName('SB5') + " SB5" 
			cUpdate += " INNER JOIN ( "
			cUpdate += cSubQuery
			cUpdate += " 	) as Sub ON Sub.COD = SB5.B5_COD  "
			cUpdate += " WHERE B5_FILIAL = '"+ xFilial('SB5') +"'  "
			cUpdate += " AND SB5.D_E_L_E_T_ = ' ' "
		Endif	

		If TCSqlExec(cUpdate) < 0
			conout(STR0001 + cFilant +" | "+ STR0002 + TCSQLError()) // "Não foi possível atualizar as datas:"
			oLogger:Log({"TIMESTAMP", STR0001 + cFilant +" | "+ STR0002 + TCSQLError()}) // "Não foi possível atualizar as datas:"
		Endif	
	Next 
	
	cFilant := cBkpFilial
	oLogger:Log({"TIMESTAMP", STR0010}) // "Fim da atualizacao da ultima venda na SB5"
	conout(STR0010) // "Fim da atualizacao da ultima venda na SB5"
Return

/*/{Protheus.doc} DMSB_DirectShipment

	@author       Vinicius Gati
	@since        07/04/2017
	@description  Classe responsavel por atualizar e coletar itens de direct shipment
/*/
Class DMSB_DirectShipment
	Data aData
	Data oTempTable
	Data cTableName

	METHOD New() CONSTRUCTOR
	METHOD GetPecas()
	METHOD AtualizarPecas()
EndClass

/*/{Protheus.doc} New
	Construtor simples

	@author Vinicius Gati
	@since  30/03/2017
/*/
METHOD New() Class DMSB_DirectShipment
Return SELF

/*/{Protheus.doc} GetPecas

	@author Vinicius Gati
	@since  30/03/2017
	@description Busca a lista de peças direct shipment na web
/*/
METHOD GetPecas() Class DMSB_DirectShipment
	Local aCodigos   := {}
	Local sPostRet   := ""
	Local cHeaderGet := ""
	Local nIdx       := 1
	Local oObj       := Nil

	sPostRet := HttpGet("http://www.itmil.com.br/john_deere/direct_shipment.php", , , , @cHeaderGet)
	if ! empty(sPostRet)
		If FWJsonDeserialize(sPostRet,@oObj)
			for nIdx := 1 to LEN(oObj:pecas)
				AADD(aCodigos, oObj:pecas[nIdx])
			next
		end
	else
		ConOut("Não foi possivel acessar o servidor, sem acesso a internet?")
	end
Return aCodigos

/*/{Protheus.doc} AtualizarPecas

	@author Vinicius Gati
	@since  30/03/2017
	@description 
		Altera B5_ISDSHIP = 1 pelo preenchimento da tabela SA5 - Amarração Produto x Fornecedor, 
		segundo JD pelo fornecedor já irá resolver tanto JDM quanto DSH
		o campo DKE_FJDJDM indica se o fornecedor deve ser considerado JDM ou DSH

	@type method
/*/
METHOD AtualizarPecas() Class DMSB_DirectShipment
	local aArea  := getArea()
	local cAlias := getNextAlias()

	if !(FWAliasInDic("DKE") .and. DKE->(FieldPos("DKE_FJDJDM")) > 0)
		return .f.
	endif

	SB5->( dbSetOrder(1) )

	beginSql alias cAlias
		select A5_PRODUTO, B5_ISDSHIP, SB5.R_E_C_N_O_ RECSB5
		from %table:SA5% SA5
		inner join %table:DKE% DKE on  DKE_FILIAL = %xFilial:DKE% and DKE_COD = A5_FORNECE and DKE_LOJA = A5_LOJA 
		                               and DKE_FJDJDM = '1'       and DKE.%notdel%
		left  join %table:SB5% SB5 on  B5_FILIAL  = %xFilial:SB5% and B5_COD  = A5_PRODUTO and SB5.%notdel%
		where A5_FILIAL = %xFilial:SA5%
		and  SA5.%notdel%
		group by A5_PRODUTO, B5_ISDSHIP, SB5.R_E_C_N_O_
	endSql

	while ! (cAlias)->( eof() )
		if (cAlias)->RECSB5 == 0 .and. ! SB5->( dbSeek( xFilial("SB5") + (cAlias)->A5_PRODUTO ) )
			recLock( "SB5", .T. )
			SB5->B5_FILIAL  := xFilial("SB5")
			SB5->B5_COD     := (cAlias)->A5_PRODUTO
			SB5->B5_ISDSHIP := "1"
			msUnlock()
		elseif (cAlias)->B5_ISDSHIP != "1"
			SB5->( dbGoto( (cAlias)->RECSB5 ) )
			recLock( "SB5", .F. )
			SB5->B5_ISDSHIP := "1"
			msUnlock()
		endif
		(cAlias)->( dbSkip() )
	endDo
	(cAlias)->( dbCloseArea() )
	restArea( aArea )
return nil
 