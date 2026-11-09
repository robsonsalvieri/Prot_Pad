#include "Protheus.ch"

/*/{Protheus.doc} LOCSV027
Função utilizada para execução do objeto de negócio Previsto x Realizado
@type Função
@author Frank Zwarg Fuga
@since 14/04/2026
/*/

Function LOCSV027()  
Local lRet   := .F.

    If GetRpoRelease() > "12.1.2210" 

       	If !findClass("totvs.protheus.rental.manutencao.integratedprovider.previstorealizado") .or. file("\SYSTEM\LOCSV027.TXT") //Comentario adicionado para passagem do DSERLOCA-10105 20/02/2026
    		Return .F.
    	EndIf

        lRet := LOCSV027A()

    EndIf

Return lRet

/*/{Protheus.doc} LOCSV027A
Função utilizada para execução do objeto de negócio Previsto x Realizado
@type Função
@author Frank Zwarg Fuga
@since 14/04/2026
/*/

Function LOCSV027A()
Local oSmartView as object
Local cQuery := ""
Local nX
Local lRet
Local lcval := SUPERGETMV("MV_LOCX051",.F.,.T.)
Local cSitua
Local cCodCli
Local cLoja
Local cNome
Local cNreduz
Local cCidade
Local cEstado
Local cEnde
Local cRepres
Local nPrevBrut
Local nRealBrut
Local nPrevImp
Local nRealImp
Local nPrevLiq
Local nRealLiq
Local nPrevCus
Local aGrupo
Local aBindParam
Local lTem
Local nPrevMar
Local nRealMar
Local nRealCus
Local cTemp
Local aNotas
Local nPrevPer
Local nRealPer
Local nSeq
Local cArqLock	:= "LOCSV027"
Local lBlq
Local cExecuta

    if FP6->(fieldpos("FP6_GRP")) == 0 .or. FP7->(fieldpos("FP7_GRP")) == 0
        MsgAlert("O dicionário de dados não está atualizado, faltam os campos FP6_GRP, ou FP7_GRP","Atenção!")
        Return .F.
    EndIf

	//DSERLOCA-13194 - Leonardo Pacheco Fuga - 18/08/2026
    if FP6->(fieldpos("FP6_PRODUT")) == 0 .or. FP7->(fieldpos("FP7_PRODUT")) == 0
        MsgAlert("O dicionário de dados não está atualizado, faltam os campos FP6_PRODUT, ou FP7_PRODUT","Atenção!")
        Return .F.
    EndIf   

    If !lcval
        MsgAlert("O parâmetro MV_LOCX051 para habilitar as classes de valor não está ativo","Atenção!")
        Return .F.
    EndIf

	If !LockByName( CARQLOCK, .F., .F. )
		lBlq := .T.
		For nX := 1 to 5
			Sleep(5000)
			If LockByName( CARQLOCK, .F., .F. )
				lBlq := .F.
				Exit
			EndIf
		Next
		If lBlq
			MsgAlert("Este relatório utiliza recursos de cálculo que exigem uso exclusivo; aguarde a conclusão da outra execução em andamento.","Bloqueio de uso devido à concorrência de acesso por outro usuário.")
			Return .F.
		EndIF
	EndIF

	LOCACLOSE("LOC026B")

    cDrop   := "DROP TABLE " + "PREVREL3"
    cExecuta := "TCSQLExec(cDrop)"
	&(cExecuta)

    cCreate := "CREATE TABLE PREVREL3 ("  + ;
	           "ORDEMX NUMERIC(3, 0) NULL, "+;
	           "CONTRATO VARCHAR("+alltrim(str(TamSx3("FP0_PROJET")[1]))+") NULL, "+;
	           "SITUACAO VARCHAR(20) NULL, "+;
	           "CODCLI VARCHAR("+alltrim(str(TamSx3("A1_COD")[1]))+") NULL, "+;
	           "LOJCLI VARCHAR("+alltrim(str(TamSx3("A1_LOJA")[1]))+") NULL, "+;
	           "NOMCLI VARCHAR("+alltrim(str(TamSx3("A1_NOME")[1]))+") NULL, "+;
	           "PEDCLI VARCHAR("+alltrim(str(TamSx3("C5_NUM")[1]))+") NULL, "+;
	           "DTIMP VARCHAR(08) NULL, "+;
	           "NRPED VARCHAR(20) NULL, "+;
	           "ABRCLI VARCHAR("+alltrim(str(TamSx3("A1_NREDUZ")[1]))+") NULL, "+;
	           "REPRES VARCHAR(50) NULL, "+;
	           "PEDFIN VARCHAR(100) NULL, "+;
	           "CIDCLI VARCHAR("+alltrim(str(TamSx3("A1_MUN")[1]))+") NULL, "+;
	           "ESTCLI VARCHAR("+alltrim(str(TamSx3("A1_ESTADO")[1]))+") NULL, "+;
	           "PAICLI VARCHAR("+alltrim(str(TamSx3("A1_PAIS")[1]))+") NULL, "+;
	           "ENDCLI VARCHAR("+alltrim(str(TamSx3("A1_END")[1]))+") NULL, "+;
	           "TITULO VARCHAR(30) NULL, "+;
	           "ORCVLR NUMERIC("+alltrim(str(TamSx3("FPZ_QUANT")[1]))+","+alltrim(str(TamSx3("FPZ_QUANT")[2]))+") NULL, "+;
	           "REAVLR NUMERIC("+alltrim(str(TamSx3("FPZ_QUANT")[1]))+","+alltrim(str(TamSx3("FPZ_QUANT")[2]))+") NULL, "+;
               ")"

    cExecuta := "TCSQLExec(cCreate)"
	If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027A.TXT")
        MsgStop("Erro ao criar tabela temporária.", "Erro.")
		Return .F.
    EndIf

	cSitua := ""
	cCodCli := FP0->FP0_CLI
	cLoja := FP0->FP0_LOJA
	cNome := ""
	cNreduz := ""
	cCidade := ""
	cEstado := ""
	cEnde := ""
	cRepres := FP0->FP0_NOMECO
	nPrevBrut := 0 // receita bruta - previsão
	nRealBrut := 0 // receita bruta - realizado
	nPrevImp := 0
	nRealImp := 0
	aGrupo := {}
	nPrevCus := 0
	nPrevMar := 0
	nRealMar := 0
	cTemp := ""
	aNotas := {}
	nPrevPer := 0
	nRealPer := 0

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+FP0->(FP0_CLI+FP0_LOJA)))
		cNome := SA1->A1_NOME
		cNreduz := SA1->A1_NREDUZ
		cCidade := SA1->A1_MUN
		cEstado := SA1->A1_ESTADO
		cEnde := SA1->A1_END
	EndIf

	If FP0_STATUS=="1" .AND. !EMPTY(ALLTRIM(GETADVFVAL("FQ5", "FQ5_SOT",XFILIAL("FQ5") + FP0_FILIAL + FP0_PROJET,21,"")))
		cSitua := "Dig. com contrato"
	ElseIf FP0_STATUS=="1"
		cSitua := "Em elaboracao"
	ElseIf FP0_STATUS=="2"
		cSitua := "Em aprovacao"
	ElseIf FP0_STATUS=="3"
		cSitua := "Aprovado"
	ElseIf FP0_STATUS=="4"
		cSitua := "Não aprovado"
	ElseIf FP0_STATUS=="5"
		cSitua := "Fechado"
	ElseIf FP0_STATUS=="6"
		cSitua := "Indisponivel"
	ElseIf FP0_STATUS=="7"
		cSitua := "Rejeitado"
	ElseIf FP0_STATUS=="8"
		cSitua := "Faturado"
	ElseIf FP0_STATUS=="A"
		cSitua := "Revisado"
	ElseIf FP0_STATUS=="B"
		cSitua := "Excluido"
	ElseIf FP0_STATUS=="C"
		cSitua := "Perdido"
	Else
		cSitua := "Não definido"
	EndIf

	// Cabeçalho do relatório
	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
	While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET) == xFilial("FPA")+FP0->FP0_PROJET
	
		// Valor bruto previsto
		nPrevBrut += FPA->FPA_VLBRUT

		// Valor de impostos previstos
		nPrevImp += FPA->FPA_VRISS

		// Custo direto previsto = campo total da base de cálculo
		FP6->(dbSetOrder(1))
		FP6->(dbSeek(xFilial("FP6")+FP0->FP0_PROJET))
		While !FP6->(eof()) .and. FP6->FP6_FILIAL == xFilial("FP6") .and. FP6->FP6_PROJET == FP0->FP0_PROJET
			If FP6->(FP6_PROJET+FP6_OBRA+FP6_SEQGUI) == FPA->(FPA_PROJET+FPA_OBRA+FPA_SEQGRU)
				nPrevCus += FP6->FP6_VALOR
			EndIf
			FP6->(dbSkip())
		EndDo


		// Valor bruto realizado
		If !empty(FPA->FPA_AS)
			FPZ->(dbSetOrder(2))
			FPZ->(dbSeek(xFilial("FPZ")+FPA->FPA_AS))
			While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+FPA->FPA_AS
				FPY->(dbSetOrder(1))
				FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
				If alltrim(FPY->FPY_STATUS) <> "2"
					If FPY->FPY_TIPFAT <> "R"
						SC6->(dbSetOrder(1))
						If SC6->(dbSeek(xFilial("SC6")+FPZ->FPZ_PEDVEN+FPZ->FPZ_ITEM))
							// Valor bruto realizado
							nRealBrut += SC6->C6_VALOR
						EndIF
					EndIF
				EndIf
				SC5->(dbSetOrder(1))
				If SC5->(dbSeek(xFilial("SC5")+FPY->FPY_PEDVEN))
					If !empty(SC5->C5_NOTA)

						lTem := .F.
						For nX := 1 to len(aNotas)
							If aNotas[nX,1] == SC5->(C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI)
								lTem := .T.
							EndIf
						Next

						If !lTem
							SF2->(dbSetOrder(1))
							If SF2->(dbSeek(xFilial("SF2")+SC5->(C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI)))
								// Valor de impostos realizados
								nRealImp += SF2->F2_VALICM
								nRealImp += SF2->F2_VALIPI
								nRealImp += SF2->F2_VALPIS
								nRealImp += SF2->F2_VALCOFI
								nRealImp += SF2->F2_VALISS
								nRealImp += SF2->F2_VALCSLL
								nRealImp += SF2->F2_VALIRRF
								nRealImp += SF2->F2_VALINSS
							EndIF
							aadd(aNotas,{SC5->(C5_NOTA+C5_SERIE+C5_CLIENTE+C5_LOJACLI)})
						EndIF
					EndIf
				EndIf
				FPZ->(dbSkip())
			EndDo
		EndIf

		FPA->(dbSkip())
	EndDo

	// Receita liquida realizado
	nRealLiq := nRealBrut - nRealImp

	// Valor previsto liquido
	nPrevLiq := nPrevBrut - nPrevImp

	// Margem bruta prevista
	nPrevMar := nPrevLiq - nPrevCus

	// Valor previsto realizado
	nPrevRea := nRealBrut - nRealImp

	// Valores variados com base na FP6
	FP6->(dbSetOrder(1))
	FP6->(dbSeek(xFilial("FP6")+FP0->FP0_PROJET))
	While !FP6->(eof()) .and. FP6->FP6_FILIAL == xFilial("FP6") .and. FP6->FP6_PROJET == FP0->FP0_PROJET
		lTem := .F.

		FPA->(dbSetOrder(1))
		If FPA->(dbSeek(xFilial("FPA")+FP6->(FP6_PROJET+FP6_OBRA+FP6_SEQGUI)))

			// Variados previsto
			lTem := .F.
			For nX := 1 to len(aGrupo)
				If aGrupo[nX,1] == FP6->FP6_GRP
					lTem := .T.
					Exit
				EndIf
			Next
			If !lTem
				aadd(aGrupo,{If(empty(FP6->FP6_GRP),"Outros",FP6->FP6_GRP), FP6->FP6_VALOR, FPA->FPA_AS, 0, FP6->FP6_PRODUT })
			Else
				aGrupo[nX,2] += FP6->FP6_VALOR
			EndIf
			
		EndIF

		FP6->(dbSkip())
	EndDo

	// Variados realizado
	For nX := 1 to len(aGrupo)

		If !empty(aGrupo[nX,3]) // AS

			aBindParam := {}
			cQuery := "	SELECT STJ.R_E_C_N_O_ REG FROM " + RETSQLNAME('STJ')+ " STJ "
			cQuery += " WHERE STJ.D_E_L_E_T_ = ' ' "
			cQuery += " AND STJ.TJ_AS = ? "
			aBindParam := {aGrupo[nX,3]}
			cQuery := CHANGEQUERY(cQuery)
			MPSysOpenQuery(cQuery,"TRAB",,,aBindParam)

			While !TRAB->(Eof())
				STJ->(dbGoto(TRAB->REG))
				STL->(dbSetOrder(1))
				If STL->(dbSeek(xFilial("STL")+STJ->TJ_ORDEM))
					While !STL->(Eof()) .and. STL->(TL_FILIAL+TL_ORDEM) == xFilial("STL")+STJ->TJ_ORDEM
						If alltrim(STL->TL_CODIGO) == alltrim(aGrupo[nX,5])//DSERLOCA-12034 - Dennis Calabrez - 18/05/2026 - Retirada a validação do campo TL_NUMSC
							aGrupo[nX,4] += STL->TL_CUSTO
						EndIf
						STL->(dbSkip())
					EndDo
				EndIf
				TRAB->(dbSkip())
			EndDo

		EndIf
	Next

	// buscar o variados realizados pelo SC7
	If lcval 
		For nX := 1 to len(aGrupo)
			cTemp := substr(aGrupo[nX,3],1,TamSx3("C7_CLVL")[1])
			aBindParam := {}
			cQuery := "	SELECT SC7.R_E_C_N_O_ REG FROM " + RETSQLNAME('SC7')+ " SC7 "
			cQuery += " WHERE D_E_L_E_T_ = ' ' AND C7_OP = ' ' "//DSERLOCA-12034 - Dennis Calabrez - 18/05/2026 - Adicionado o campo C7_OP, tem que estar vazio
			cQuery += " AND C7_FILIAL = '" + ALLTRIM(xFilial("SC7")) + "' "//DSERLOCA-12034 - Dennis Calabrez - 18/05/2026 - Adicionado o campo C7_FILIAL
			//cQuery += " AND "+"substr(C7_CLVL,1,"+alltrim(str(TamSx3("C7_CLVL")[1]))+") = ? "
			cComplete := "cQuery += 'AND '+'substring(C7_CLVL,1,'+alltrim(str(TamSx3('C7_CLVL')[1]))+') = ?' "
			&(cComplete)
			aadd(aBindParam,cTemp)
			cQuery += " AND C7_PRODUTO = ? "
			aadd(aBindParam,aGrupo[nX,5])
			cQuery := CHANGEQUERY(cQuery)
			MPSysOpenQuery(cQuery,"TRAB",,,aBindParam)

			While !TRAB->(Eof())
				SC7->(dbGoto(TRAB->REG))
				aGrupo[nX,4] += SC7->C7_TOTAL
				TRAB->(dbSkip())
			EndDo
		Next
	EndIf

	// Margem bruta - realizado
	//É a receita líquida real – custo real dos grupos.
	nRealCus := 0
	For nX := 1 to len(aGrupo)
		nRealCus += aGrupo[nX,4]
	Next
	nRealMar := nRealLiq - nRealCus

	// Percentual previsto
	nPrevPer := (nPrevMar / nPrevBrut) * 100

	// Percentual realizado
	nRealPer := (nRealMar / nRealBrut) * 100

	cSQL := "INSERT INTO PREVREL3 "
    cSql += "(ORDEMX, CONTRATO, SITUACAO, CODCLI, LOJCLI, NOMCLI, PEDCLI, DTIMP, NRPED, ABRCLI, REPRES, PEDFIN, CIDCLI, ESTCLI, PAICLI, ENDCLI, TITULO, ORCVLR, REAVLR )"
    cSql += " VALUES "
	cSql += "("
	cSql += str(1) + ","
	cSql += "'"+FP0->FP0_PROJET+"',"
	cSql += "'"+cSitua+"'," 
	cSql += "'"+cCodCli+"'," 
	cSql += "'"+cLoja+"',"
	cSql += "'"+cNome+"'," 
	cSql += "''," 
	cSql += "''," 
	cSql += "''," 
	cSql += "'"+cNreduz+"'," 
	cSql += "'"+cRepres+"'," 
	cSql += "''," 
	cSql += "'"+cCidade+"'," 
	cSql += "'"+cEstado+"'," 
	cSql += "''," 
	cSql += "'"+cEnde+"'," 
	cSql += "'Receita Bruta'," 
	cSql += str(nPrevBrut) + "," 
	cSql += str(nRealBrut) 
	cSql += ")"

	cExecuta := "TCSQLExec(cSql)"
	If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027B.TXT")
        MsgStop("Erro ao criar tabela temporária.", "Erro.")
		Return .F.
    EndIf

	cSQL := "INSERT INTO PREVREL3 "
    cSql += "(ORDEMX, CONTRATO, SITUACAO, CODCLI, LOJCLI, NOMCLI, PEDCLI, DTIMP, NRPED, ABRCLI, REPRES, PEDFIN, CIDCLI, ESTCLI, PAICLI, ENDCLI, TITULO, ORCVLR, REAVLR )"
    cSql += " VALUES "
	cSql += "("
	cSql += str(2) + ","
	cSql += "'"+FP0->FP0_PROJET+"',"
	cSql += "'"+cSitua+"'," 
	cSql += "'"+cCodCli+"'," 
	cSql += "'"+cLoja+"',"
	cSql += "'"+cNome+"'," 
	cSql += "''," 
	cSql += "''," 
	cSql += "''," 
	cSql += "'"+cNreduz+"'," 
	cSql += "'"+cRepres+"'," 
	cSql += "''," 
	cSql += "'"+cCidade+"'," 
	cSql += "'"+cEstado+"'," 
	cSql += "''," 
	cSql += "'"+cEnde+"'," 
	cSql += "'Impostos'," 
	cSql += str(nPrevImp) + "," 
	cSql += str(nRealImp) 
	cSql += ")"

	cExecuta := "TCSQLExec(cSql)"
	If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027C.TXT")
        MsgStop("Erro ao criar tabela temporária.", "Erro.")
		Return .F.
    EndIf
			
	cSQL := "INSERT INTO PREVREL3 "
    cSql += "(ORDEMX, CONTRATO, SITUACAO, CODCLI, LOJCLI, NOMCLI, PEDCLI, DTIMP, NRPED, ABRCLI, REPRES, PEDFIN, CIDCLI, ESTCLI, PAICLI, ENDCLI, TITULO, ORCVLR, REAVLR )"
    cSql += " VALUES "
	cSql += "("
	cSql += str(3) + ","
	cSql += "'"+FP0->FP0_PROJET+"',"
	cSql += "'"+cSitua+"'," 
	cSql += "'"+cCodCli+"'," 
	cSql += "'"+cLoja+"',"
	cSql += "'"+cNome+"'," 
	cSql += "''," 
	cSql += "''," 
	cSql += "''," 
	cSql += "'"+cNreduz+"'," 
	cSql += "'"+cRepres+"'," 
	cSql += "''," 
	cSql += "'"+cCidade+"'," 
	cSql += "'"+cEstado+"'," 
	cSql += "''," 
	cSql += "'"+cEnde+"'," 
	cSql += "'Receita Liquida'," 
	cSql += str(nPrevLiq) + "," 
	cSql += str(nRealLiq) 
	cSql += ")"

	cExecuta := "TCSQLExec(cSql)"
	If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027D.TXT")
        MsgStop("Erro ao criar tabela temporária.", "Erro.")
		Return .F.
    EndIf

	// Aqui entra os modelos localizados na base
	nSeq := 3
	For nX := 1 to len(aGrupo)
		nSeq ++

		cSQL := "INSERT INTO PREVREL3 "
		cSql += "(ORDEMX, CONTRATO, SITUACAO, CODCLI, LOJCLI, NOMCLI, PEDCLI, DTIMP, NRPED, ABRCLI, REPRES, PEDFIN, CIDCLI, ESTCLI, PAICLI, ENDCLI, TITULO, ORCVLR, REAVLR )"
		cSql += " VALUES "
		cSql += "("
		cSql += str(nSeq) + ","
		cSql += "'"+FP0->FP0_PROJET+"',"
		cSql += "'"+cSitua+"'," 
		cSql += "'"+cCodCli+"'," 
		cSql += "'"+cLoja+"',"
		cSql += "'"+cNome+"'," 
		cSql += "''," 
		cSql += "''," 
		cSql += "''," 
		cSql += "'"+cNreduz+"'," 
		cSql += "'"+cRepres+"'," 
		cSql += "''," 
		cSql += "'"+cCidade+"'," 
		cSql += "'"+cEstado+"'," 
		cSql += "''," 
		cSql += "'"+cEnde+"'," 
		cSql += "'"+aGrupo[nX,1]+"'," 
		cSql += str(aGrupo[nX,2]) + "," 
		cSql += str(aGrupo[nX,4]) 
		cSql += ")"

		cExecuta := "TCSQLExec(cSql)"
		If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027E.TXT") 
        	MsgStop("Erro ao criar tabela temporária.", "Erro.")
			Return .F.
    	EndIf

	Next

	nSeq ++

	cSQL := "INSERT INTO PREVREL3 "
    cSql += "(ORDEMX, CONTRATO, SITUACAO, CODCLI, LOJCLI, NOMCLI, PEDCLI, DTIMP, NRPED, ABRCLI, REPRES, PEDFIN, CIDCLI, ESTCLI, PAICLI, ENDCLI, TITULO, ORCVLR, REAVLR )"
    cSql += " VALUES "
	cSql += "("
	cSql += str(nSeq) + ","
	cSql += "'"+FP0->FP0_PROJET+"',"
	cSql += "'"+cSitua+"'," 
	cSql += "'"+cCodCli+"'," 
	cSql += "'"+cLoja+"',"
	cSql += "'"+cNome+"'," 
	cSql += "''," 
	cSql += "''," 
	cSql += "''," 
	cSql += "'"+cNreduz+"'," 
	cSql += "'"+cRepres+"'," 
	cSql += "''," 
	cSql += "'"+cCidade+"'," 
	cSql += "'"+cEstado+"'," 
	cSql += "''," 
	cSql += "'"+cEnde+"'," 
	cSql += "'Margem bruta'," 
	cSql += str(nPrevMar) + "," 
	cSql += str(nRealMar) 
	cSql += ")"

	cExecuta := "TCSQLExec(cSql)"
	If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027F.TXT")
        MsgStop("Erro ao criar tabela temporária.", "Erro.")
		Return .F.
    EndIf

	nSeq ++

	cSQL := "INSERT INTO PREVREL3 "
    cSql += "(ORDEMX, CONTRATO, SITUACAO, CODCLI, LOJCLI, NOMCLI, PEDCLI, DTIMP, NRPED, ABRCLI, REPRES, PEDFIN, CIDCLI, ESTCLI, PAICLI, ENDCLI, TITULO, ORCVLR, REAVLR )"
    cSql += " VALUES "
	cSql += "("
	cSql += str(nSeq) + ","
	cSql += "'"+FP0->FP0_PROJET+"',"
	cSql += "'"+cSitua+"'," 
	cSql += "'"+cCodCli+"'," 
	cSql += "'"+cLoja+"',"
	cSql += "'"+cNome+"'," 
	cSql += "''," 
	cSql += "''," 
	cSql += "''," 
	cSql += "'"+cNreduz+"'," 
	cSql += "'"+cRepres+"'," 
	cSql += "''," 
	cSql += "'"+cCidade+"'," 
	cSql += "'"+cEstado+"'," 
	cSql += "''," 
	cSql += "'"+cEnde+"'," 
	cSql += "'Percentual previsto'," 
	cSql += str(nPrevPer) + "," 
	cSql += str(nRealPer) 
	cSql += ")"

	cExecuta := "TCSQLExec(cSql)"
	If &(cExecuta) < 0 .or. file("\SYSTEM\LOCSV027G.TXT")
        MsgStop("Erro ao criar tabela temporária.", "Erro.")
		Return .F.
    EndIf

    oSmartView := totvs.protheus.rental.manutencao.integratedprovider.previstorealizado():new()	

	lRet := (oSmartView:printprevxreal(FP0->FP0_PROJET))

	cDrop   := "DROP TABLE " + "PREVREL3"
    cExecuta := "TCSQLExec(cDrop)"
	&(cExecuta)

	UnLockByName( CARQLOCK, .F., .F. )

Return lRet
