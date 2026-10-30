#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_WMS
Função de compatibilização do release incremental.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGACTB criar a função RUP_CTB

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author  Guilherme A. Metzgeradmin
@since   19/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static __cEmpWms := ""
Function RUP_WMS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
Local aArea  := GetArea()

	// Os conouts estão colocados com objetivo de facilitar a identificação de quais comandos foram executados.
	// Se no futuro não existir mais necessidade de determinados comandos, os mesmos podem ser eliminados.
	// Importante! Não colocar acentuação.

	// Criamos um padrão para facilitar a localização das funções, onde:
	// WMSU       (Prefixo WMS)
	//     M1     (Modo de Execução)
	//       0001 (Número Sequencial da Função)

	// Só executa as regras WMS se o parâmetro estiver ativo
	If !SuperGetMV("MV_INTWMS",.F.,.F.)
		Return
	EndIf

	conout('[RUP_WMS] Verificando necessidade de atualizacao...')
	conout('[RUP_WMS] Versao: ' + cVersion + ' / Modo: ' + cMode + ' / Release Inicial: ' + cRelStart + ' Release Final:  ' + cRelFinish)

	// Necessidade de alteração única por grupo de empresas
	If cMode == "1"
		conout("[RUP WMS] - cMode: "+cMode+" - Empresa: "+AllTrim(cEmpAnt)+" - Filial: "+AllTrim(cFilAnt))

		If cRelStart < '027' .And. cRelFinish >= '027'
			WMSUM10007()
			WMSUM10008()
		EndIf

	ElseIf cMode == "2"
		conout("[RUP WMS] - cMode: "+cMode+" - Empresa: "+AllTrim(cEmpAnt)+" - Filial: "+AllTrim(cFilAnt))

		If cRelStart < '027' .And. cRelFinish >= '027'
			WMSUM20001()
			WMSUM20002()
			WMSUM20003()
			WMSUM20004()
			WMSUM20005()
			WMSUM20006()
			WMSUM20007()
			WMSUM20008()
		EndIf

		// Salva a empresa anterior para validar as filiais das tabelas
		__cEmpWms := cEmpAnt
	EndIf
	RestArea( aArea )
Return



Static Function WMSUM10007()
Local aAreaAnt := GetArea()
Local cCampo := PadR("D1_COD",Len(SX7->X7_CAMPO))

	conout("[RUP_WMS] Removendo o gatilho do campo dominio D1_COD - sequencia 007.")
	SX7->(DbSetOrder(1)) // X7_CAMPO+X7_SEQUENC
	If SX7->(DbSeek(cCampo+"007")) .And. AllTrim(SX7->X7_CDOMIN) == "D1_TPESTR"
		RecLock("SX7",.F.)
		SX7->(DbDelete())
		SX7->(MsUnlock())
	EndIf
	RestArea(aAreaAnt)
Return

Static Function WMSUM10008()
Local aAreaAnt := GetArea()
	SX1->(DbSetOrder(1)) // X1_GRUPO+X1_ORDEM
	If SX1->(DbSeek(PadR('WMSA320',Len(SX1->X1_GRUPO))+'05')) .And. SX1->X1_TIPO == 'N' .And. 'ATUALIZA' $ Upper(SX1->X1_PERGUNT) .And.;
		SX1->(DbSeek(PadR('WMSA320',Len(SX1->X1_GRUPO))+'06')) .And. SX1->X1_TIPO == 'N' .And. 'ATUALIZA' $ Upper(SX1->X1_PERGUNT)
		conout("[RUP_WMS] Excluindo a pergunta duplicada 'Atualiza Autom. Tela' do grupo de perguntas WMSA320.")
		RecLock('SX1',.F.)
		SX1->(DbDelete())
		SX1->(MsUnlock())
		SX1->(dbCommit())
	EndIf
	RestArea(aAreaAnt)
Return

/*
Força a criação da tabela enquanto não houver programa para inclusão dos registros.
A tabela tem por objetivo informar serviço e endereço de produção e foi criada pelo fato de a tabela 
complemento de produtos (SB5) já possuir 255 campos.
*/
Static Function WMSUM20008()
	If TableInDic('D1A')
		dbSelectArea('D1A')
	EndIf
Return

Static __cModSBE := ""
Static Function WMSUM20001()
Local aValNiv    := {}
Local aAreaAnt   := GetArea() 
Local cFilSBE    := ""
Local cFilDC7    := ""
Local cAliasSBE  := Nil
Local cCodCfgVz  := Space(TamSx3("BE_CODCFG")[1])
Local cCodZonVz  := Space(TamSx3("BE_CODZON")[1])
Local cEstFisVz  := Space(TamSx3("BE_ESTFIS")[1])

	If !TabelaExiste("SBE") .Or. !TabelaExiste("DC7")
		Return
	EndIf

	If Empty(__cModSBE)
		__cModSBE := FWModeAccess("SBE",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModSBE == "C"
		Return
	EndIf

	__cModSBE := FWModeAccess("SBE",3)
	cFilSBE  := FWxFilial("SBE",/*cEmpUDFil*/,FWModeAccess("SBE",1),FWModeAccess("SBE",2),__cModSBE)
	cFilDC7  := FWxFilial("DC7",/*cEmpUDFil*/,FWModeAccess("DC7",1),FWModeAccess("DC7",2),FWModeAccess("DC7",3))

	conout("[RUP_WMS] Ajustando os campos niveis da tabela SBE.")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	cAliasSBE := GetNextAlias()
	BeginSql Alias cAliasSBE
		SELECT SBE.BE_CODCFG,
				SBE.BE_LOCALIZ,
				SBE.R_E_C_N_O_ RECNOSBE
		FROM %Table:SBE% SBE
		WHERE SBE.BE_FILIAL  = %Exp:cFilSBE%
		AND SBE.BE_CODCFG <> %Exp:cCodCfgVz%
		AND SBE.BE_CODZON <> %Exp:cCodZonVz%
		AND SBE.BE_ESTFIS <> %Exp:cEstFisVz%
		AND SBE.BE_VALNV1  = 0
		AND EXISTS (SELECT 1
					FROM %Table:DC7% DC7
					WHERE DC7.DC7_FILIAL  = %Exp:cFilDC7%
					AND DC7.DC7_CODCFG = SBE.BE_CODCFG
					AND DC7.%NotDel% )
		AND SBE.%NotDel%
	EndSql
	Do While !(cAliasSBE)->(Eof())
		aValNiv := WmsCfgEnd((cAliasSBE)->BE_CODCFG, (cAliasSBE)->BE_LOCALIZ)
		If Len(aValNiv) > 0
			SBE->(DbGoTo((cAliasSBE)->RECNOSBE))
			RecLock("SBE",.F.)
			SBE->BE_VALNV1 := Iif(Len(aValNiv)>0,Val(Str(aValNiv[1,1])),0)
			SBE->BE_VALNV2 := Iif(Len(aValNiv)>1,Val(Str(aValNiv[2,1])),0)
			SBE->BE_VALNV3 := Iif(Len(aValNiv)>2,Val(Str(aValNiv[3,1])),0)
			SBE->BE_VALNV4 := Iif(Len(aValNiv)>3,Val(Str(aValNiv[4,1])),0)
			SBE->BE_VALNV5 := Iif(Len(aValNiv)>4,Val(Str(aValNiv[5,1])),0)
			SBE->BE_VALNV6 := Iif(Len(aValNiv)>5,Val(Str(aValNiv[6,1])),0)
			SBE->(MsUnlock())
			SBE->(dbCommit())
		EndIf
		(cAliasSBE)->(dbSkip())
	EndDo
	(cAliasSBE)->(dbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	RestArea(aAreaAnt)
Return

Static __cModDCS  := ""
Static Function WMSUM20002()
Local lErro      := .F.
Local aIdDCF     := {}
Local aAreaAnt   := GetArea()
Local cFilDCS    := ""
Local cFilDCT    := ""
Local cFilDCU    := ""
Local cFilDCV    := ""
Local cFilD0I    := ""
Local cFilSC9    := ""
Local cAliasDCS  := Nil
Local cAliasDCT  := Nil
Local cAliasDCV  := Nil
Local cAliasSC9  := Nil
Local cCodMnt    := ""
Local cCodMntVz  := Space(TamSx3("DCS_CODMNT" )[1])
Local cPrdLtAnt  := ""
Local cItem      := ""
Local nI         := 1

	If !TabelaExiste("DCS")
		Return
	EndIf

	If Empty(__cModDCS)
		__cModDCS := FWModeAccess("DCS",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModDCS == "C"
		Return
	EndIf

	__cModDCS := FWModeAccess("DCS",3)
	cFilDCS  := FWxFilial("DCS",/*cEmpUDFil*/,FWModeAccess("DCS",1),FWModeAccess("DCS",2),__cModDCS)
	cFilDCT  := FWxFilial("DCT",/*cEmpUDFil*/,FWModeAccess("DCT",1),FWModeAccess("DCT",2),FWModeAccess("DCT",3))
	cFilDCU  := FWxFilial("DCU",/*cEmpUDFil*/,FWModeAccess("DCU",1),FWModeAccess("DCU",2),FWModeAccess("DCU",3))
	cFilDCV  := FWxFilial("DCV",/*cEmpUDFil*/,FWModeAccess("DCV",1),FWModeAccess("DCV",2),FWModeAccess("DCV",3))
	cFilD0I  := FWxFilial("D0I",/*cEmpUDFil*/,FWModeAccess("D0I",1),FWModeAccess("D0I",2),FWModeAccess("D0I",3))
	cFilSC9  := FWxFilial("SC9",/*cEmpUDFil*/,FWModeAccess("SC9",1),FWModeAccess("SC9",2),FWModeAccess("SC9",3))

	conout("[RUP_WMS] Atualizacao do processo de montagem de volumes.")
	
	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Início da transação
	Begin Transaction
		conout("[RUP_WMS] Criando a tabela auxiliar DCS")
		conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
		
		// Busca os documentos das montagens dentro de um determinado range
		cAliasDCS := GetNextAlias()
		BeginSql Alias cAliasDCS
			SELECT DCS.R_E_C_N_O_ RECNODCS
			FROM %Table:DCS% DCS
			WHERE DCS.DCS_FILIAL = %Exp:cFilDCS%
			AND DCS.DCS_CODMNT = %Exp:cCodMntVz%
			AND DCS.%NotDel%
		EndSql
		Do While !(cAliasDCS)->(Eof()) .And. !lErro
			// Posiciona no documento da montagem
			DCS->(DbGoTo((cAliasDCS)->RECNODCS))
			// Busca um novo código de montagem
			cCodMnt := GetSX8Num('DCS','DCS_CODMNT')
			Iif(__lSX8,ConfirmSX8(),.T.)
			RecLock('DCS',.F.)
			DCS->DCS_CODMNT := cCodMnt
			DCS->DCS_QTORIG := DCS->DCS_QTSEPA
			DCS->DCS_LIBPED := "6"
			DCS->DCS_MNTEXC := "2"
			DCS->DCS_LIBEST := "2"
			DCS->(MsUnlock())
			DCS->(dbCommit())
			//----------------------------------------------------------------------------
			// Devido a alteração de índice único das tabelas DCT e DCV, será necessário
			// aglutinar os registros de mesmo produto/lote/sublote para que não ocorram
			// erros de chave duplicada.
			//----------------------------------------------------------------------------
			conout("[RUP_WMS] Criando a tabela auxiliar DCT")
			conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
			// Busca os itens do documento na montagem de volumes
			cAliasDCT := GetNextAlias()
			BeginSql Alias cAliasDCT
				SELECT DCT.DCT_CODPRO,
						DCT.DCT_LOTE,
						DCT.DCT_SUBLOT,
						DCT.DCT_QTSEPA,
						DCT.DCT_QTEMBA,
						DCT.DCT_IDDCF,
						DCT.R_E_C_N_O_ RECNODCT
				FROM %Table:DCT% DCT
				WHERE DCT.DCT_FILIAL = %Exp:cFilDCT%
				AND DCT.DCT_CODMNT = %Exp:cCodMntVz%
				AND DCT.DCT_CARGA  = %Exp:DCS->DCS_CARGA%
				AND DCT.DCT_PEDIDO = %Exp:DCS->DCS_PEDIDO%
				AND DCT.%NotDel%
				ORDER BY DCT.DCT_CODPRO,
							DCT.DCT_LOTE,
							DCT.DCT_SUBLOT
			EndSql
			Do While !(cAliasDCT)->(Eof()) .And. !lErro
				// No primeiro loop ou caso seja um produto/lote diferente do anterior, atualiza
				// o código de montagem e guarda as informações para as interações seguintes
				If cPrdLtAnt != (cAliasDCT)->DCT_CODPRO+(cAliasDCT)->DCT_LOTE+(cAliasDCT)->DCT_SUBLOT
					cPrdLtAnt := (cAliasDCT)->DCT_CODPRO+(cAliasDCT)->DCT_LOTE+(cAliasDCT)->DCT_SUBLOT
					cRecnoAnt := (cAliasDCT)->RECNODCT
					// Guarda o ID da DCF para gravar na D0I
					// Mesmo sendo lotes diferentes, podem ter origem na mesma DCF
					If AScan(aIdDCF,(cAliasDCT)->DCT_IDDCF) <= 0
						aAdd(aIdDCF,(cAliasDCT)->DCT_IDDCF)
					EndIf
					// Posiciona no registro correspondente
					DCT->(DbGoTo(cRecnoAnt))
					// Atualiza o código de montagem e demais informações
					RecLock("DCT",.F.)
					DCT->DCT_CODMNT := cCodMnt
					DCT->DCT_PRDORI := (cAliasDCT)->DCT_CODPRO
					DCT->DCT_QTORIG := (cAliasDCT)->DCT_QTSEPA
					DCT->(MsUnlock())
					DCT->(dbCommit())
				Else
					// Guarda o ID da DCF para gravar na D0I
					// Mesmo sendo lotes iguais, podem ter origem em DCFs diferentes
					If AScan(aIdDCF,(cAliasDCT)->DCT_IDDCF) <= 0
						aAdd(aIdDCF,(cAliasDCT)->DCT_IDDCF)
					EndIf
					// Deleta o registro duplicado da DCT
					If TcSQLExec("DELETE FROM "+RetSqlName('DCT')+" WHERE R_E_C_N_O_ = " + Str((cAliasDCT)->RECNODCT)) < 0
						MsgStop("Erro encontrado ao tentar excluir um registro duplicado da tabela DCT:" + CRLF + TcSQLError())
						lErro := .T.
						Exit
					EndIf
					// Posiciona no registro anterior
					DCT->(DbGoTo(cRecnoAnt))
					// Atualiza apenas as quantidades
					RecLock("DCT",.F.)
					DCT->DCT_QTSEPA += (cAliasDCT)->DCT_QTSEPA
					DCT->DCT_QTORIG += (cAliasDCT)->DCT_QTSEPA
					DCT->DCT_QTEMBA += (cAliasDCT)->DCT_QTEMBA
					DCT->(MsUnlock())
					DCT->(dbCommit())
				EndIf
				(cAliasDCT)->(DbSkip())
			EndDo
			(cAliasDCT)->(DbCloseArea())
			cPrdLtAnt := ""
	
			If lErro
				Exit
			EndIf
	
			conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	
			conout("[RUP_WMS] Atualizando tabela DCU")
			conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	
			// Atualiza a montagem de volumes
			cQuery := "UPDATE " + RetSqlName('DCU')
			cQuery +=   " SET DCU_CODMNT = '"+cCodMnt+"'"
			cQuery += " WHERE DCU_FILIAL = '"+cFilDCU+"'"
			cQuery +=   " AND DCU_CODMNT = '"+cCodMntVz+"'"
			cQuery +=   " AND DCU_CARGA  = '"+DCS->DCS_CARGA+"'"
			cQuery +=   " AND DCU_PEDIDO = '"+DCS->DCS_PEDIDO+"'"
			cQuery +=   " AND D_E_L_E_T_ = ' '"
	
			If TcSQLExec(cQuery) < 0
				MsgStop("Erro ao tentar atualizar a tabela DCU:" + CRLF + TcSQLError())
				lErro := .T.
				Exit
			EndIf
	
			conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	
			conout("[RUP_WMS] Criando a tabela auxiliar DCV")
			conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	
			// Atualiza itens da montagem de volumes
			cAliasDCV := GetNextAlias()
			BeginSql Alias cAliasDCV
				SELECT DCV.R_E_C_N_O_ RECNODCV
				FROM %Table:DCV% DCV
				INNER JOIN %Table:DCU% DCU
				ON DCU.DCU_FILIAL =  %Exp:cFilDCU%
				AND DCU.DCU_CARGA  = %Exp:DCS->DCS_CARGA%
				AND DCU.DCU_PEDIDO = %Exp:DCS->DCS_PEDIDO%
				AND DCU.%NotDel%
				WHERE DCV.DCV_FILIAL = %Exp:cFilDCV%
				AND DCV.DCV_CODMNT = %Exp:cCodMntVz%
				AND DCV.DCV_CODVOL = DCU.DCU_CODVOL
				AND DCV.%NotDel%
			EndSql
			SC9->(DbSetOrder(9)) // C9_FILIAL+C9_IDDCF
			Do While !(cAliasDCV)->(Eof())
				// Posiciona no registro correspondente
				DCV->(DbGoTo((cAliasDCV)->RECNODCV))
				// Posiciona na SC9 para pegar o item
				cItem := ""
				cAliasSC9 := GetNextAlias()
				BeginSql Alias cAliasSC9
					SELECT SC9.C9_ITEM
					FROM %Table:SC9% SC9
					WHERE SC9.C9_FILIAL = %Exp:cFilSC9%
					AND SC9.C9_IDDCF = %Exp:DCV->DCV_IDDCF
					AND SC9.%NotDel%%
				EndSql
				If (cAliasSC9)->(!Eof())
					cItem := (cAliasSC9)->C9_ITEM
				EndIf
				(cAliasSC9)->(dbCloseArea())
				// Atualiza com o código de montagem e demais informações
				RecLock("DCV",.F.)
				DCV->DCV_CODMNT := cCodMnt
				DCV->DCV_CARGA  := DCS->DCS_CARGA
				DCV->DCV_PEDIDO := DCS->DCS_PEDIDO
				DCV->DCV_PRDORI := DCV->DCV_CODPRO
				DCV->DCV_ITEM   := cItem
				DCV->(MsUnlock())
				DCV->(dbCommit())
				(cAliasDCV)->(dbSkip())
			EndDo
			(cAliasDCV)->(dbCloseArea())
	
			conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

			// Atualiza a tabela de Montagem de Volumes x OS
			For nI := 1 To Len(aIdDCF)
				RecLock("D0I",.T.)
				D0I->D0I_FILIAL := cFilD0I
				D0I->D0I_CODMNT := cCodMnt
				D0I->D0I_IDDCF  := aIdDCF[nI]
				D0I->(MsUnlock())
				D0I->(dbCommit())
			Next
	
			// Limpa as variáveis de controle
			cPrdLtAnt := ""
			cRecnoAnt := 0
			aIdDCF    := {}
	
			(cAliasDCS)->(dbSkip())
		EndDo
		(cAliasDCS)->(dbCloseArea())
	
		conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	
		// Se ocorreu algum erro desfaz a transação
		If lErro
			DisarmTransaction()
		EndIf
	//Fim da transação
	End Transaction
	
	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	RestArea(aAreaAnt)
Return

Static __cModDC5 := ""
Static Function WMSUM20003()
Local aAreaAnt   := GetArea()
Local cFilDC5    := ""
Local cAliasQry  := Nil
Local aFuncao    := {}
Local cFuncao    := ''

	
	If !TabelaExiste("DC5")
		Return
	EndIf

	If Empty(__cModDC5)
		__cModDC5 := FWModeAccess("DC5",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModDC5 == "C"
		Return
	EndIf
	
	__cModDC5 := FWModeAccess("DC5",3)
	cFilDC5 := FWxFilial("DC5",/*cEmpUDFil*/,FWModeAccess("DC5",1),FWModeAccess("DC5",2),__cModDC5)

	conout("[RUP_WMS] Ajustando tabela DC5 (DC5_OPERAC)")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DC5.R_E_C_N_O_ RECNODC5
		FROM %Table:DC5% DC5
		WHERE DC5.DC5_FILIAL = %Exp:cFilDC5%
		AND DC5.DC5_OPERAC = ' '
		AND DC5.DC5_FUNEXE <> ' '
		AND DC5.%NotDel%
	EndSql
	Do While (cAliasQry)->(!Eof())
		DC5->(dbGoTo((cAliasQry)->RECNODC5))
		aFuncao := FWGetSX5("L6",DC5->DC5_FUNEXE)
		If Len(aFuncao) > 0
			cFuncao := Alltrim(Upper(aFuncao[1,4]))

			RecLock('DC5',.F.)
			Do Case
				Case cFuncao == "DLENDERECA()"
					DC5->DC5_OPERAC := "1" //Endereçamento
				Case cFuncao == "DLCROSSDOC()"
					DC5->DC5_OPERAC := "2" //Endereçamento Crossdocking
				Case cFuncao == "DLAPANHE()" .Or. cFuncao == "DLAPANHEVL()"
					DC5->DC5_OPERAC := "3" //Separação
				Case cFuncao == "DLAPANHEC1()" .Or. cFuncao == "DLAPANHEC2()"
					DC5->DC5_OPERAC := "4"  //Separação Crossdocking
				Case cFuncao == "DLGXABAST()"
					DC5->DC5_OPERAC := "5" //Reabastecimento
				Case cFuncao == "DLCONFENT()"
					DC5->DC5_OPERAC := "6" //Conferência Entrada
				Case cFuncao == "DLCONFSAI()"
					DC5->DC5_OPERAC := "7" //Conferência Saída
				Case cFuncao == "DLDESFRAG()" .Or. cFuncao == "DLTRANSFER()"
					DC5->DC5_OPERAC := "8" //Transferência
				Otherwise
					DC5->DC5_OPERAC := ""
			EndCase
			DC5->(MsUnLock())
			DC5->(dbCommit())
		EndIf

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	RestArea(aAreaAnt)
Return

Static __cModD0K := ""
Static Function WMSUM20004()
Local aAreaAnt   := GetArea()
Local cFilD0K    := ""
Local cFilDCX    := ""
Local cFilSD1    := ""
Local cAliasQry  := Nil

	If !TabelaExiste("D0K") .Or. !TabelaExiste("DCX") .Or. !TabelaExiste("SD1")
		Return
	EndIf

	If Empty(__cModD0K)
		__cModD0K := FWModeAccess("D0K",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0K == "C"
		Return
	EndIf

	__cModD0K := FWModeAccess("D0K",3)
	cFilD0K  := FWxFilial("D0K",/*cEmpUDFil*/,FWModeAccess("D0K",1),FWModeAccess("D0K",2),__cModD0K)
	cFilDCX  := FWxFilial("DCX",/*cEmpUDFil*/,FWModeAccess("DCX",1),FWModeAccess("DCX",2),FWModeAccess("DCX",3))
	cFilSD1  := FWxFilial("SD1",/*cEmpUDFil*/,FWModeAccess("SD1",1),FWModeAccess("SD1",2),FWModeAccess("SD1",3))

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	//Início da transação
	Begin Transaction
		// Busca todos os itens de todos os documentos de entrada que passaram pela
		// Conferência de Recebimento e ainda não tenham sido repassados para a nova
		// tabela (para os casos em que um cliente executar o update mais de uma vez)
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCX.DCX_EMBARQ,
					SD1.D1_DOC,
					SD1.D1_SERIE,
					SD1.D1_FORNECE,
					SD1.D1_LOJA,
					SD1.D1_ITEM,
					SD1.D1_LOCAL,
					SD1.D1_COD,
					SD1.D1_LOTECTL,
					SD1.D1_NUMLOTE,
					SD1.D1_QUANT
			FROM %Table:DCX% DCX
			INNER JOIN %Table:SD1% SD1
			ON SD1.D1_FILIAL = %Exp:cFilSD1%
			AND SD1.D1_DOC = DCX.DCX_DOC
			AND SD1.D1_SERIE = DCX.DCX_SERIE
			AND SD1.D1_FORNECE = DCX.DCX_FORNEC
			AND SD1.D1_LOJA = DCX.DCX_LOJA
			AND SD1.%NotDel%
			WHERE DCX.DCX_FILIAL = %Exp:cFilDCX%
			AND DCX.%NotDel%
			AND NOT EXISTS (SELECT 1
							FROM %Table:D0K% D0K
							WHERE D0K.D0K_FILIAL = %Exp:cFilD0K%
							AND D0K.D0K_EMBARQ = DCX.DCX_EMBARQ
							AND D0K.D0K_DOC = SD1.D1_DOC
							AND D0K.D0K_SERIE = SD1.D1_SERIE
							AND D0K.D0K_FORNEC = SD1.D1_FORNECE
							AND D0K.D0K_LOJA = SD1.D1_LOJA
							AND D0K.D0K_PROD = SD1.D1_COD
							AND D0K.D0K_ITEM = SD1.D1_ITEM
							AND D0K.%NotDel% )
			ORDER BY DCX.DCX_EMBARQ,
						SD1.D1_DOC,
						SD1.D1_SERIE,
						SD1.D1_FORNECE,
						SD1.D1_LOJA,
						SD1.D1_ITEM
		EndSql
		Do While (cAliasQry)->(!Eof())
			RecLock('D0K',.T.)
			D0K->D0K_FILIAL := cFilD0K
			D0K->D0K_EMBARQ := (cAliasQry)->DCX_EMBARQ
			D0K->D0K_DOC    := (cAliasQry)->D1_DOC
			D0K->D0K_SERIE  := (cAliasQry)->D1_SERIE
			D0K->D0K_FORNEC := (cAliasQry)->D1_FORNECE
			D0K->D0K_LOJA   := (cAliasQry)->D1_LOJA
			D0K->D0K_ITEM   := (cAliasQry)->D1_ITEM
			D0K->D0K_LOCAL  := (cAliasQry)->D1_LOCAL
			D0K->D0K_PROD   := (cAliasQry)->D1_COD
			D0K->D0K_LOTE   := (cAliasQry)->D1_LOTECTL
			D0K->D0K_SUBLOT := (cAliasQry)->D1_NUMLOTE
			D0K->D0K_QUANT  := (cAliasQry)->D1_QUANT
			D0K->(MsUnlock())
			D0K->(dbCommit())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	//Fim da transação
	End Transaction
	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	// Restaura Alias
	RestArea(aAreaAnt)
Return

Static __cModD0I := ""
Static Function WMSUM20005()
Local aAreaAnt   := GetArea()
Local cFilD0I    := ""
Local cFilDCS    := ""
Local cFilDCF    := ""
Local cAliasQry  := Nil
Local lDataD0I   := .F.

	If !TabelaExiste("D0I") .Or. !TabelaExiste("DCS") .Or. !TabelaExiste("DCF")
		Return
	EndIf

	If Empty(__cModD0I)
		__cModD0I := FWModeAccess("D0I",3)
	Endif
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0I == "C"
		Return
	EndIf

	__cModD0I := FWModeAccess("D0I",3)
	cFilD0I  := FWxFilial("D0I",/*cEmpUDFil*/,FWModeAccess("D0I",1),FWModeAccess("D0I",2),__cModD0I)
	cFilDCS  := FWxFilial("DCS",/*cEmpUDFil*/,FWModeAccess("DCS",1),FWModeAccess("DCS",2),FWModeAccess("DCS",3))
	cFilDCF  := FWxFilial("DCF",/*cEmpUDFil*/,FWModeAccess("DCF",1),FWModeAccess("DCF",2),FWModeAccess("DCF",3))

	conout("[RUP_WMS] Validando tabela D0I.")
	lDataD0I := RUPDataD0I()
	If !lDataD0I
		conout("[RUP_WMS] Ajustando gravacao da tabela D0I")

		conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

		//Busca todas as DCFs que possuam montagem de volumes
		//e que não possuam registro na tabela auxiliar D0I.
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT DCF.DCF_ID,
					DCS.DCS_CODMNT
			FROM %Table:DCF% DCF
			INNER JOIN %Table:DCS% DCS
			ON DCS_FILIAL = %Exp:cFilDCS%
			AND DCS_CARGA = DCF_CARGA
			AND DCS_PEDIDO = DCF_DOCTO
			AND DCS.%NotDel%
			WHERE DCF_FILIAL = %Exp:cFilDCF%
			AND DCF_ORIGEM = 'SC9'
			AND DCF_STSERV = '3'
			AND DCF.%NotDel%
			AND NOT EXISTS (SELECT D0I_IDDCF
							FROM %Table:D0I% D0I
							WHERE D0I_FILIAL = %Exp:cFilD0I%
							AND D0I_CODMNT = DCS_CODMNT
							AND D0I_IDDCF = DCF_ID
							AND D0I.%NotDel% )
		EndSql
		Do While (cAliasQry)->(!EoF())
			Reclock("D0I",.T.)
			D0I->D0I_FILIAL := cFilD0I
			D0I->D0I_CODMNT := (cAliasQry)->DCS_CODMNT
			D0I->D0I_IDDCF  := (cAliasQry)->DCF_ID
			D0I->(MsUnlock())
			D0I->(dbCommit())
			(cAliasQry)->(dbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	Else
		conout("[RUP_WMS] Tabela D0I Validada.")
	EndIf
	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	RestArea(aAreaAnt)
Return

Static __cModD0H := ""
Static Function WMSUM20006()
Local aAreaAnt   := GetArea()
Local cFilD0H    := ""
Local cFilD01    := ""
Local cFilDCF    := ""
Local cAliasQry  := Nil

	If !TabelaExiste("D0H") .Or. !TabelaExiste("D01") .Or. !TabelaExiste("DCF") 
		Return
	EndIf

	If Empty(__cModD0H)
		__cModD0H := FWModeAccess("D0H",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0H == "C"
		Return
	EndIf

	__cModD0H := FWModeAccess("D0H",3)
	cFilD0H  := FWxFilial("D0H",/*cEmpUDFil*/,FWModeAccess("D0H",1),FWModeAccess("D0H",2),__cModD0H)
	cFilD01  := FWxFilial("D01",/*cEmpUDFil*/,FWModeAccess("D01",1),FWModeAccess("D01",2),FWModeAccess("D01",3))
	cFilDCF  := FWxFilial("DCF",/*cEmpUDFil*/,FWModeAccess("DCF",1),FWModeAccess("DCF",2),FWModeAccess("DCF",3))

	conout("[RUP_WMS] Ajustando gravacao da tabela D0H")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Busca todas as DCFs que possuam conferência de expedição
	//e que não possuam registro na tabela auxiliar D0H.
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_ID,
				D01.D01_CODEXP
		FROM %Table:DCF% DCF
		INNER JOIN %Table:D01% D01
		ON D01_FILIAL = %Exp:cFilD01%
		AND D01_CARGA = DCF_CARGA
		AND D01_PEDIDO = DCF_DOCTO
		AND D01.%NotDel%
		WHERE DCF_FILIAL = %Exp:cFilDCF%
		AND DCF_ORIGEM = 'SC9'
		AND DCF_STSERV = '3'
		AND DCF.%NotDel%
		AND NOT EXISTS (SELECT D0H_IDDCF
						FROM %Table:D0H% D0H
						WHERE D0H_FILIAL = %Exp:cFilD0H%
						AND D0H_CODEXP = D01_CODEXP
						AND D0H_IDDCF = DCF_ID
						AND D0H.%NotDel% )
	EndSql
	Do While (cAliasQry)->(!EoF())
		Reclock("D0H",.T.)
		D0H->D0H_FILIAL := cFilD0H
		D0H->D0H_CODEXP := (cAliasQry)->D01_CODEXP
		D0H->D0H_IDDCF  := (cAliasQry)->DCF_ID
		D0H->(MsUnlock())
		D0H->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	RestArea(aAreaAnt)
Return

Static __cModD0J := ""
Static Function WMSUM20007()
Local aAreaAnt   := GetArea()
Local cFilD0J    := ""
Local cFilD0D    := ""
Local cFilDCF    := ""
Local cAliasQry  := Nil
	
	If !TabelaExiste("D0J") .Or. !TabelaExiste("D0D") .Or. !TabelaExiste("DCF") 
		Return
	EndIf

	If Empty(__cModD0J)
		__cModD0J := FWModeAccess("D0J",3)
	EndIf
	// Se for a mesma empresa anterior e a tabela for compartilhada, não roda novamente
	If __cEmpWms == cEmpAnt .And. __cModD0J == "C"
		Return
	EndIf

	__cModD0J := FWModeAccess("D0J",3)
	cFilD0J  := FWxFilial("D0J",/*cEmpUDFil*/,FWModeAccess("D0J",1),FWModeAccess("D0J",2),__cModD0J)
	cFilD0D  := FWxFilial("D0D",/*cEmpUDFil*/,FWModeAccess("D0D",1),FWModeAccess("D0D",2),FWModeAccess("D0D",3))
	cFilDCF  := FWxFilial("DCF",/*cEmpUDFil*/,FWModeAccess("DCF",1),FWModeAccess("DCF",2),FWModeAccess("DCF",3))

	conout("[RUP_WMS] Ajustando gravacao da tabela D0J")

	conout("[RUP_WMS] Inicio: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))

	//Busca todas as DCFs que possuam distribuição da separação
	//e que não possuam registro na tabela auxiliar D0J.
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT DCF.DCF_ID,
				D0D.D0D_CODDIS
		FROM %Table:DCF% DCF
		INNER JOIN %Table:D0D% D0D
		ON D0D_FILIAL = %Exp:cFilD0D%
		AND D0D_CARGA = DCF_CARGA
		AND D0D_PEDIDO = DCF_DOCTO
		AND D0D.%NotDel%
		WHERE DCF_FILIAL = %Exp:cFilDCF%
		AND DCF_ORIGEM = 'SC9'
		AND DCF_STSERV = '3'
		AND DCF.%NotDel%
		AND NOT EXISTS (SELECT D0J_IDDCF
						FROM %Table:D0J% D0J
						WHERE D0J_FILIAL = %Exp:cFilD0J%
						AND D0J_CODDIS = D0D_CODDIS
						AND D0J_IDDCF = DCF_ID
						AND D0J.%NotDel% )
	EndSql
	Do While (cAliasQry)->(!EoF())
		Reclock("D0J",.T.)
		D0J->D0J_FILIAL := cFilD0J
		D0J->D0J_CODDIS := (cAliasQry)->D0D_CODDIS
		D0J->D0J_IDDCF  := (cAliasQry)->DCF_ID
		D0J->(MsUnlock())
		D0J->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	conout("[RUP_WMS] Final: "+Time()+" - Segundos: "+AllTrim(Str(Seconds())))
	RestArea(aAreaAnt)
Return

Static __aCfgEnd := {}
Static __aAlpha  := {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
Static Function WmsCfgEnd(cCodCfg,cEndereco)
Local aAreaAnt  := GetArea()
Local aRet      := {}
Local aCfgTmp   := Array(2)
Local nCntFor   := 1
Local nPos      := 0
Local nCnt1     := 0
Local nCnt2     := 0
Local cStr1     := ""
Local cStr2     := ""
Local cLetra    := ""
Local cAliasDC7 := Nil
Local cFilDC7   := FWxFilial("DC7",/*cEmpUDFil*/,FWModeAccess("DC7",1),FWModeAccess("DC7",2),FWModeAccess("DC7",3))
Local nTamNiv   := TamSx3('BE_VALNV1')[1]

Default cCodCfg   := CriaVar('DC7_CODCFG', .F.)
Default cEndereco := CriaVar('BE_LOCALIZ', .F.)

	If !TabelaExiste("DC7")
		Return
	EndIf

	//-- Formato do Array aRet:
	//-- aRet[n,1] = Codigo do Endereco separado por Nivel
	//-- aRet[n,2] = Peso do Nivel (Deve ser DESCONSIDERADO para o ultimo Nivel)
	//-- aRet[n,3] = Peso do Lado
	If Len(__aCfgEnd) > 0 .And. (nPos:=AScan(__aCfgEnd, {|x|x[1]==cCodCfg}))>0
		aCfgTmp := __aCfgEnd[nPos]
	Else
		aCfgTmp[1] := cCodCfg
		aCfgTmp[2] := {} //Array vazio
		cAliasDC7 := GetNextAlias()
		BeginSql Alias cAliasDC7
			SELECT DC7.DC7_POSIC,
					DC7.DC7_PESO1,
					DC7.DC7_PESO2
			FROM %Table:DC7% DC7
			WHERE DC7.DC7_FILIAL = %Exp:cFilDC7%
			AND DC7.DC7_CODCFG = %Exp:cCodCfg%
			AND DC7.%NotDel%
			ORDER BY DC7.DC7_SEQUEN,
						DC7.DC7_POSIC,
						DC7.DC7_PESO1,
						DC7.DC7_PESO2
		EndSql
		Do While (cAliasDC7)->(!Eof())
			AAdd(aCfgTmp[2],{(cAliasDC7)->DC7_PESO2, (cAliasDC7)->DC7_PESO1,(cAliasDC7)->DC7_POSIC})
			(cAliasDC7)->(DbSkip())
		EndDo
		(cAliasDC7)->(DbCloseArea())
		AAdd(__aCfgEnd,aCfgTmp)
	EndIf
	For nCnt1 := 1 To Len(aCfgTmp[2])
		cStr1 := AllTrim(Upper(SubStr(cEndereco,nCntFor,aCfgTmp[2,nCnt1,3])))
		cStr2 := ''
		//Transforma a configuração em números seguindo a ordem no ARRAy
		// -> 000 -> '0' = 01 + '0' = 01 + '0' = 01 -> '010101'
		// -> R01 -> 'R' = 28 + '0' = 01 + '1' = 02 -> '280102'
		// -> ZR5 -> 'Z' = 36 + 'R' = 28 + '5' = 06 -> '362806'
		// -> ZZZ -> 'Z' = 36 + 'Z' = 36 + 'Z' = 36 -> '363636'
		For nCnt2 := 1 To Len(cStr1)
			cLetra := SubStr(cStr1, nCnt2, 1)
			nPos   := AScan(__aAlpha, {|x|x==cLetra})
			cStr2  += StrZero(nPos,2)
		Next
		AAdd(aRet, {Val(Substr(cStr2,1,nTamNiv)), aCfgTmp[2,nCnt1,1], aCfgTmp[2,nCnt1,2]})
		nCntFor += aCfgTmp[2,nCnt1,3]
	Next
	If Len(aRet)==0
		conout("[RUP_WMS] Endereco '"+AllTrim(cEndereco)+"' Codigo de Configuracao de Enderecos '"+AllTrim(cCodCfg)+"' nao cadastrado (DC7).")
	EndIf
	RestArea(aAreaAnt)
Return(aRet)

//Valida se tabela existe no banco de dados
Static Function TabelaExiste(cTabela)
Local lExiste := .F.
	DbSelectArea(cTabela)
	lExiste := Select(cTabela) > 0
Return lExiste

Static Function RUPDataD0I()
Local lData := .F.

	DbSelectArea("D0I")
	If D0I->(dbSeek(FWxFilial("D0I")))
		lData := .T.
	EndIf
Return lData



