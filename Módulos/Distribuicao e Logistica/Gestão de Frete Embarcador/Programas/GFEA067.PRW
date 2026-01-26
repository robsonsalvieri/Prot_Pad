#INCLUDE "GFEA067.ch"
#INCLUDE "PROTHEUS.CH"
 
/*/--------------------------------------------------------------------------------------------------
{Protheus.doc} GFEA067
Envio de Integração Fiscal/Apropriação de Custos por Lote/Custo de transporte com SIGATMS
Generico.

@sample 
GFER067()

@author Israel Possoli
@since 08/04/2010
@version 1.0
--------------------------------------------------------------------------------------------------/ */

Function GFEA067()
	Local lSelecao 		:= .F.	// Verifica se o Documento de Frete será considerado na seleção. (Apenas Fatura)
	Local lSelecaoDF	:= .F.	// Verifica se algum Documento de Frete entrou na seleção. (Apenas Fatura)
	Local lSucesso 		:= .F.
	Local lmsgerro		:=  .T.
	Local lErro 		:= .F.
	Local lIntDocF    	:= SuperGetMv('MV_DSCTB',, '1') == "2" .And. SuperGetMv('MV_ERPGFE',, '1') == "1"  // Tipo de contabilização
	Local nIntegrados 	:= 0
	Local nVlMov		:= 0

	Local cTipoIntegr	// 1=Fiscal, 2=Apropriação de Despesas, 3=Custo de transporte
	Local cTipoDoc		// 1=Documento de Frete, 2=Fatura
	Local cAcao			// 1=Atualizar, 2=Atu Rejeitados, 3=Desatualizar
	Local cFilialIni
	Local cFilialFim
	Local cTranspIni
	Local cTranspFim
	Local cCodEspIni
	Local cCodEspFim
	Local cSerieIni
	Local cSerieFim
	Local cNumeroIni
	Local cNumeroFim
	Local dDtEmisIni
	Local dDtEmisFim
	Local dDtEntrIni
	Local dDtEntrFim
	Local dDtTransac
	Local cParData 		:= SuperGetMV('MV_DSDTRE',,'1') // Contabilização Frete de Vendas
	Local cSitFin
	Local cSitRec
	Local cSitCus
	Local cSitFinFat // Situação financeira fatura
	Local aAreaAntGW3
	Local aRet 			:= {}
	Local cERPGFE     	:= SuperGetMv("MV_ERPGFE", .F., "2")
	Local cMV_DSOFDT	:= SuperGetMv("MV_DSOFDT",.F.,"1")
	Local cFilAtu		:= ""

	Private GFEResult 	:= GFEViewProc():New()
	Private cAliasGW3
	Private cAliasGW6
	Private cMsgErro 	:= ""
	Private Inclui  //Usada para evitar erro de variável não declarada na integração de custo de frete com TMS (TMSA070);

	// Validação dos parâmetros
	If Empty(SuperGetMv('MV_DTULFE',,''))
		Help( ,, 'Help',, "Data do último fechamento não parametrizada. Verificar o parâmetro MV_DTULFE", 1, 0 )
		Return Nil
	EndIf

	//
	If Empty(SuperGetMv('MV_DSOFDT',,''))
		Help( ,, 'Help',, "Data de Transação do Documento Fiscal não parametrizada. Verificar o parâmetro MV_DSOFDT.", 1, 0 )
	EndIf

	If !Pergunte("GFEA067")
		Return Nil
	EndIf

	cTipoIntegr	:= MV_PAR01
	cTipoDoc	:= MV_PAR02
	cAcao		:= MV_PAR03
	cFilialIni	:= MV_PAR04
	cFilialFim	:= MV_PAR05
	cTranspIni 	:= MV_PAR06
	cTranspFim 	:= MV_PAR07
	cCodEspIni 	:= MV_PAR08
	cCodEspFim	:= MV_PAR09
	cSerieIni	:= MV_PAR10
	cSerieFim	:= MV_PAR11
	cNumeroIni 	:= MV_PAR12
	cNumeroFim	:= MV_PAR13
	dDtEmisIni	:= MV_PAR14
	dDtEmisFim	:= MV_PAR15
	dDtEntrIni	:= MV_PAR16
	dDtEntrFim	:= MV_PAR17
	
	If cERPGFE == "1"
		dDtTransac := MV_PAR18
	else 
		dDtTransac := ddatabase
	Endif
	// Valida a data de transação do parâmetro caso o parâmetro 'MV_DSOFDT' seja pela data informada
	If Empty(dDtTransac)
		If SuperGetMv("MV_DSOFDT",,"1") == "3" .and. cTipoIntegr == 1 .and. cERPGFE == "1"
			Help( ,, 'Help',,	"É necessário informar a Data de Transação. O parâmetro 'Data Transação Documento Fiscal' está parametrizado para usar a data informada para integrar os documentos de frete. Informe a Data de Transação ou altere a forma como a data será atribuída nos parâmetros do modulo aba 'Integrações Datasul'.", 1, 0 )
			Return Nil
		ElseIf cParData == "3" .and. cTipoIntegr == 2 .and. cERPGFE == "1"
			Help( ,, 'Help',, "É necessário informar a Data de Transação. O parâmetro 'Data Integração Recebimento' está parametrizado para usar a data informada para integrar os documentos de frete. Informe a Data de Transação ou altere a forma como a data será atribuída nos parâmetros do modulo aba 'Integrações Datasul'.", 1, 0 )
			Return Nil
		ElseIf cERPGFE != "1"
			dDtTransac := ddatabase
		EndIf	
	EndIf

	If cValToChar(cAcao) $ "1;2"
		Inclui := .T.
	Else
		Inclui := .F.
	EndIf
	
	// Define o filtro da Situação Fiscal ou Recebimento
	If cTipoIntegr == 1
		If cAcao == 1
			cSitFin := "1"
		EndIf

		If cAcao == 2
			cSitFin := "3"
		EndIf

		If cAcao == 3
			cSitFin := "4"
		EndIf
			
	ElseIf cTipoIntegr == 2			
		If cAcao == 1
			cSitRec := "1"
		EndIf

		If cAcao == 2
			cSitRec := "3"
		EndIf

		If cAcao == 3
			cSitRec := "4"
		EndIf
	ElseIf cTipoIntegr == 3 
		If !GFEA065CTA()
			Help( ,, 'Help',, "Sistema configurado para não integrar valores de custo de transporte com SIGATMS.", 1, 0 )
			Return Nil
		Else
			If cAcao == 1
				cSitCus := "1', '3', '4"
			ElseIf cAcao == 2
				cSitCus := "3"
			ElseIf cAcao == 3
				cSitCus := "2"
			EndIf
		EndIf
	EndIf
	
	/* ----------------------------------------------------------------
		Documento de Frete
	   ---------------------------------------------------------------- */
	If cTipoDoc == 1
		cAliasGW3 := GetNextAlias()
		cQuery := " SELECT GW3.* FROM "+RetSQLName("GW3")+" GW3 WHERE"
		cQuery += " 	GW3.GW3_FILIAL >= '" + cFilialIni       + "' AND GW3.GW3_FILIAL <= '" + cFilialFim       + "' AND "
		cQuery += " 	GW3.GW3_EMISDF >= '" + cTranspIni       + "' AND GW3.GW3_EMISDF <= '" + cTranspFim       + "' AND "
		cQuery += " 	GW3.GW3_CDESP  >= '" + cCodEspIni       + "' AND GW3.GW3_CDESP  <= '" + cCodEspFim       + "' AND "
		cQuery += " 	GW3.GW3_SERDF  >= '" + cSerieIni        + "' AND GW3.GW3_SERDF  <= '" + cSerieFim        + "' AND "
		cQuery += " 	GW3.GW3_NRDF   >= '" + cNumeroIni       + "' AND GW3.GW3_NRDF   <= '" + cNumeroFim       + "' AND "
		cQuery += " 	GW3.GW3_DTENT  >= '" + DTOS(dDtEntrIni) + "' AND GW3.GW3_DTENT  <= '" + DTOS(dDtEntrFim) + "' AND "
		cQuery += " 	GW3.GW3_DTEMIS >= '" + DTOS(dDtEmisIni) + "' AND GW3.GW3_DTEMIS <= '" + DTOS(dDtEmisFim) + "' AND "
		cQuery += " 	(GW3.GW3_SIT   = '3' OR GW3.GW3_SIT   = '4')  AND "
		If cTipoIntegr == 1
			cQuery += " 	GW3.GW3_SITFIS = '" + cSitFin + "' AND "
		ElseIf cTipoIntegr == 2
			cQuery += " 	GW3.GW3_SITREC = '" + cSitRec + "' AND "
		ElseIf cTipoIntegr == 3
			cQuery += " 	GW3.GW3_SITCUS IN ('" + cSitCus + "') AND "
		EndIf
		cQuery += "     GW3.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW3, .F., .T.)
		
		dbSelectArea((cAliasGW3))
		(cAliasGW3)->( dbGoTop() )
	
		If (cAliasGW3)->( Eof() )
			Help( ,, 'Help',, "Não foram encontrados documentos de frete para a faixa informada.", 1, 0 )
			(cAliasGW3)->( dbCloseArea() )
			Return Nil
		EndIf

		While !(cAliasGW3)->( Eof() )
		    lSucesso := .F.
		    lmsgerro := .T.
		    cMsgErro := ""
			
			dbSelectArea("GW3")
			GW3->( dbSetOrder(1) )
			If GW3->( dbSeek((cAliasGW3)->GW3_FILIAL + (cAliasGW3)->GW3_CDESP + (cAliasGW3)->GW3_EMISDF + (cAliasGW3)->GW3_SERDF + (cAliasGW3)->GW3_NRDF + (cAliasGW3)->GW3_DTEMIS) )		
				cFilAtu := cFilAnt
				cFilAnt := GW3->GW3_FILIAL
				If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
					cFilAnt := GW3->GW3_FILTOM
				EndIf
				
				//Este comando dbSelectArea("GW3"), esta sendo usado para posicionar a tabela GW3 na função GFEA065In, chamada abaixo.//
				If cTipoIntegr == 2		
					If cParData == "1" 			//Data Corrente 
					 	dDtTransac := DDATABASE
					ElseIf cParData == "2" 		//Data Criação 
							dDtTransac:= GW3->GW3_DTENT 
					ElseIf cParData == "3" 		//Informada Usuário 
						If Empty(dDtTransac)
							cMsgErro := "É necessário informar a Data de Transação para o documento."
							lMsgErro := .F.						
						EndIf
					ElseIf cParData == "4" 		//Financeiro
						dbSelectArea("GW6") 		
						dbSetOrder(1)
						If dbSeek(GW3->GW3_FILFAT+ GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT + DTOS(GW3->GW3_DTEMFA))
							cSitFinFat := GW6->GW6_SITFIN
							dDtTransac := GW6->GW6_DTFIN
							If cSitFinFat != "4"
								cMsgErro := "A Fatura de Frete não foi atualizada no financeiro."
								lMsgErro := .F.							
							EndIf
						Else 
							cMsgErro := "O parâmetro Data Integração Recebimento esta configurado para assumir a data do Financeiro, porém não existe Fatura de Frete atualizada com o Financeiro para este Documento de Frete."
							lMsgErro := .F.	
						EndIf	
					EndIf
				EndIf
				If Empty(dDtTransac)
					cMsgErro := "É necessário informar a Data de Transação para o documento."
					lMsgErro := .F.
				EndIf
				//Para integração de custo de frete com SIGATMS, lIntDocF nunca será verdadeiro, pois serve só para Datasul.
				If lIntDocF
					nVlMov := 0 //Somatória dos valores dos lançamentos contábeis do documento de frete
					
					dbSelectArea("GWA")
					GWA->(dbSetOrder(1))//GWA_FILIAL+GWA_TPDOC+GWA_CDESP+GWA_CDEMIT+GWA_SERIE+GWA_NRDOC+DTOS(GWA_DTEMIS)
			
					If GWA->(dbSeek((cAliasGW3)->GW3_FILIAL+"2" +(cAliasGW3)->GW3_CDESP+(cAliasGW3)->GW3_EMISDF+(cAliasGW3)->GW3_SERDF+(cAliasGW3)->GW3_NRDF+ (cAliasGW3)->GW3_DTEMIS))
						While GWA->(!Eof()) .AND. GWA->GWA_FILIAL == (cAliasGW3)->GW3_FILIAL;
						.AND. GWA->GWA_TPDOC  == "2"; // Docto Frete
						.AND. GWA->GWA_CDESP  == (cAliasGW3)->GW3_CDESP;
						.AND. GWA->GWA_CDEMIT == (cAliasGW3)->GW3_EMISDF;
						.AND. GWA->GWA_SERIE  == (cAliasGW3)->GW3_SERDF;
						.AND. GWA->GWA_NRDOC  == (cAliasGW3)->GW3_NRDF; 
						.AND. DTOS(GWA->GWA_DTEMIS) == (cAliasGW3)->GW3_DTEMIS
				
							nVlMov += GWA->GWA_VLMOV
						
							GWA->(DbSkip())
						EndDo
					EndIf

					If	nVlMov != (cAliasGW3)->GW3_VLDF
						cMsgErro :=  "No modo de integração fiscal pelo Recebimento, o valor do documento "+(cAliasGW3)->GW3_NRDF+"/"+(cAliasGW3)->GW3_SERDF+": "+ cValToChar((cAliasGW3)->GW3_VLDF) +" deve ser igual ao total dos rateios contábeis: "+ cValToChar(nVlMov) //"Somente Documentos de Frete Aprov.Sistema ou Aprov.Usuario podem ser integrados"
						lMsgErro := .F.
					EndIf
				EndIf

			   	If lMsgErro
				   	If cTipoIntegr == 1
				   		lSucesso := FiscalDoctoFrete(dDtTransac, cAcao)
						If lSucesso .And. cERPGFE == "1" .And. GFXCP1212410("GW3_DSOFDT") .And. GFXRL1212410("GW3","GW3_DSOFDT")
							If cAcao == 1 .And. Empty(GW3->GW3_DSOFDT)
								RecLock("GW3", .F.)
									GW3->GW3_DSOFDT := cMV_DSOFDT
								GW3->( MsUnlock() )
							ElseIf cAcao == 3 .And. !Empty(GW3->GW3_DSOFDT)
								RecLock("GW3", .F.)
									GW3->GW3_DSOFDT := " "
								GW3->( MsUnlock() )
							EndIf
						EndIf
					ElseIf cTipoIntegr == 2
						lSucesso := RecDoctoFrete(dDtTransac, cAcao)
					ElseIf cTipoIntegr == 3
						aRet := GFEA065CTP("E") //Elimina se for pra desatualizar e também para atualizar, removendo registros antigos
						lSucesso := aRet[1]
						cMsgErro := aRet[2]
						
						If lSucesso //Se não houve erro na eliminação, recria-se dependendo da ação 
							If cValToChar(cAcao) $ "1;2"
								aRet := GFEA065CTP("IL")
								lSucesso := aRet[1]
								cMsgErro := aRet[2]
							EndIf
						EndIf
				   	EndIf
				EndIf
				
			   	If lSucesso
			   		nIntegrados++
			   	  	GFEResult:Add("# " + cValToChar(nIntegrados) +" - Filial: " + (cAliasGW3)->GW3_FILIAL + ", Série: " + (cAliasGW3)->GW3_SERDF + ", Número: " + (cAliasGW3)->GW3_NRDF + ", Transportador: " + (cAliasGW3)->GW3_EMISDF)
				Else
					lErro := .T.
				   	GFEResult:AddDetail("Filial: " + (cAliasGW3)->GW3_FILIAL + ", Série: " + (cAliasGW3)->GW3_SERDF + ", Número: " + (cAliasGW3)->GW3_NRDF + ", Transportador: " + (cAliasGW3)->GW3_EMISDF)
				   	GFEResult:AddDetail("** " + cMsgErro, 1)
				EndIf

			EndIf

			cFilAnt := cFilAtu

			dbSelectArea((cAliasGW3))
			(cAliasGW3)->( dbSkip() )
		EndDo
		(cAliasGW3)->( dbCloseArea() )
	EndIf

	/* ----------------------------------------------------------------
		Fatura
	   ---------------------------------------------------------------- */
	If cTipoDoc == 2
		cAliasGW6 := GetNextAlias()
		cQuery := " SELECT GW6.* FROM "+RetSQLName("GW6")+" GW6 WHERE"
		cQuery += " 	GW6.GW6_FILIAL >= '" + cFilialIni       + "' AND GW6.GW6_FILIAL <= '" + cFilialFim       + "' AND "
		cQuery += " 	GW6.GW6_EMIFAT >= '" + cTranspIni       + "' AND GW6.GW6_EMIFAT <= '" + cTranspFim       + "' AND "
		cQuery += " 	GW6.GW6_SERFAT >= '" + cSerieIni        + "' AND GW6.GW6_SERFAT <= '" + cSerieFim        + "' AND "
		cQuery += " 	GW6.GW6_NRFAT  >= '" + cNumeroIni       + "' AND GW6.GW6_NRFAT   <= '" + cNumeroFim       + "' AND "
		cQuery += " 	GW6.GW6_DTEMIS >= '" + DTOS(dDtEmisIni) + "' AND GW6.GW6_DTEMIS <= '" + DTOS(dDtEmisFim) + "' AND "
		cQuery += "     GW6.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasGW6, .F., .T.)

		dbSelectArea((cAliasGW6))
		(cAliasGW6)->( dbGoTop() )

		If (cAliasGW6)->( Eof() )
			Help( ,, 'Help',, "Não foram encontrados faturas para a faixa informada.", 1, 0 )
			(cAliasGW6)->( dbCloseArea() )
			Return Nil
		EndIf

		While !(cAliasGW6)->( Eof() )
		    GFEResult:Add("Fatura => Filial: " + (cAliasGW6)->GW6_FILIAL + ", Série: " + (cAliasGW6)->GW6_SERFAT + ", Número: " + (cAliasGW6)->GW6_NRFAT + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)

		    dbSelectArea("GW3")
		    dbSetOrder(8)
		    If dbSeek((cAliasGW6)->GW6_FILIAL + (cAliasGW6)->GW6_EMIFAT + (cAliasGW6)->GW6_SERFAT + (cAliasGW6)->GW6_NRFAT + (cAliasGW6)->GW6_DTEMIS)
		    	lSelecaoDF := .F.
			    While !GW3->( Eof() ) .AND. ;
			    	   GW3->GW3_FILFAT == (cAliasGW6)->GW6_FILIAL 		.AND. ;
			    	   GW3->GW3_EMIFAT == (cAliasGW6)->GW6_EMIFAT 		.AND. ;
			    	   GW3->GW3_SERFAT == (cAliasGW6)->GW6_SERFAT 		.AND. ;
			    	   GW3->GW3_NRFAT  == (cAliasGW6)->GW6_NRFAT  		.AND. ;
			    	   GW3->GW3_DTEMFA == STOD((cAliasGW6)->GW6_DTEMIS)
					
					aAreaAntGW3 := GETAREA()
					
					cFilAtu := cFilAnt
					cFilAnt := GW3->GW3_FILIAL
					If GFXCP12137('GW3_FILTOM') .AND. !Empty(GW3->GW3_FILTOM)
						cFilAnt := GW3->GW3_FILTOM
					EndIf

					// Verifica se a situação do documento de frete está como bloqueado
					If GW3->GW3_SIT != "2" .And. GW3->GW3_SIT != "5" 
						lSelecao := .F.
						cMsgErro := ""

						// Verifica a situação da integração (Fiscal ou Apropriação de Despesa)
						If cTipoIntegr == 1
							lSelecao := GW3->GW3_SITFIS == cSitFin
						ElseIf cTipoIntegr == 2
							lSelecao := GW3->GW3_SITREC == cSitRec
						ElseIf cTipoIntegr == 3
							lSelecao := (cAcao == 1 .And. GW3->GW3_SITCUS $ '1;4') .Or.;
										(cAcao == 2 .And. GW3->GW3_SITCUS == "3") .Or.;
										(cAcao == 3 .And. GW3->GW3_SITCUS == "2")
						EndIf

						If lSelecao
							lSelecaoDF := .T.
							dbSelectArea("GW6")
							dbSetOrder(1)
							If dbSeek((cAliasGW6)->GW6_FILIAL + (cAliasGW6)->GW6_EMIFAT + (cAliasGW6)->GW6_SERFAT + (cAliasGW6)->GW6_NRFAT + (cAliasGW6)->GW6_DTEMIS)
								// Fiscal
								If cTipoIntegr == 1
									lSucesso := FiscalFatura(dDtTransac, cAcao)
								// Recebimento
								ElseIf cTipoIntegr == 2
									lSucesso := RecFatura(dDtTransac, cAcao)
								ElseIf cTipoIntegr == 3
									aRet := GFEA065CTP("E") //Elimina se for pra desatualizar e também para atualizar, removendo registros antigos
									lSucesso := aRet[1]
									cMsgErro := aRet[2]
							
									If lSucesso //Se não houve erro na eliminação, recria-se dependendo da ação 
										If cValToChar(cAcao) $ "1;2"
											aRet := GFEA065CTP("IL")
											lSucesso := aRet[1]
											cMsgErro := aRet[2]
										EndIf
									EndIf
								EndIf
								// Verifica o retorno das funções de integração
								If lSucesso
									nIntegrados++
									GFEResult:Add("Docto Frete => Filial: " + GW3->GW3_FILIAL + ", Série: " + GW3->GW3_SERDF + ", Número: " + GW3->GW3_NRDF + ", Transportador: " + GW3->GW3_EMISDF, 2)
								Else
									lErro := .T.
									GFEResult:AddDetail("Documento de Frete => Filial: " + GW3->GW3_FILIAL + ", Série: " + GW3->GW3_SERDF + ", Número: " + GW3->GW3_NRDF + ", Transportador: " + GW3->GW3_EMISDF)
									GFEResult:AddDetail("** " + cMsgErro, 1)
								EndIf
							EndIf
						EndIf
					Else
						GFEResult:AddDetail("Documento de Frete => Filial: " + GW3->GW3_FILIAL + ", Série: " + GW3->GW3_SERDF + ", Número: " + GW3->GW3_NRDF + ", Transportador: " + GW3->GW3_EMISDF)
						GFEResult:AddDetail("** " + "Não é permitido realizar integrações de Documentos de Frete que não estão aprovados, realize a aprovação do documento de frete, antes de realizar a integração."	, 1)
						lErro := .T.
					EndIf

					cFilAnt := cFilAtu

					RESTAREA(aAreaAntGW3)

					GW3->( dbSkip() )
			    EndDo

			    If !lSelecaoDF
			    	lErro := .T.
			    	GFEResult:AddDetail("Fatura => Filial: " + (cAliasGW6)->GW6_FILIAL + ", Série: " + (cAliasGW6)->GW6_SERFAT + ", Número: " + (cAliasGW6)->GW6_NRFAT + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)
			    	GFEResult:AddDetail("** Nenhum Documento de Frete encontrado para a ação selecionada.", 1)
			    EndIf
			Else
				lErro := .T.
				GFEResult:AddDetail("Fatura => Filial: " + (cAliasGW6)->GW6_FILIAL + ", Série: " + (cAliasGW6)->GW6_SERFAT + ", Número: " + (cAliasGW6)->GW6_NRFAT + ", Transportador: " + (cAliasGW6)->GW6_EMIFAT)
				GFEResult:AddDetail("** Não há Documentos de Frete relacionado a esta fatura.", 1)
			EndIf

		    dbSelectArea((cAliasGW6))
			(cAliasGW6)->( dbSkip() )
		EndDo
		(cAliasGW6)->( dbCloseArea() )
	EndIf

	GFEResult:Add()

	// Verifica se algum documento de frete foi integrado
	If nIntegrados == 0
		GFEResult:Add("Nenhum Documento de Frete Integrado.")
	EndIf

	If lErro
		GFEResult:Add()
		GFEResult:Add("Ocorreram erros durante a integração. Clique no botão 'Erros' para mais informações.")
	EndIf

	GFEResult:Show("Integração de Documentos de Frete", IF(cTipoDoc == 1, "Docto Fretes Integrados", "Docto Fretes das Faturas Integrados"), "Erros")

Return

/* --------------------------------------------------------------------------------------------------
{Protheus.doc} FiscalDoctoFrete
Validações de envio de Integração Fiscal dos Documentos de Frete por Lote
Generico.

@parametros
dDataInf = Data informada
cAcao (1=Atualização, 2=Atualização de Rejeitadas, 3=Desatualização)

@author Israel Alcantara Possoli
@since 08/04/09
@version 1.0
-------------------------------------------------------------------------------------------------- */
Static Function FiscalDoctoFrete(dDataInf, cAcao)
	Local dDataFis := dDataInf // Data de atribuição do campo GW3_DTDIS
	Local aRet

	// Desatualizar
	If cAcao == 3
	
		If !VldFatFin("Doc.Frete")		   
		   Return .F.
		EndIf

		If Empty((cAliasGW3)->GW3_DTFIS) .Or. SToD( (cAliasGW3)->GW3_DTFIS ) > SuperGetMv("MV_DTULFE",,"20000101")
			aRet := GFEA065In("5", dDataFis, "1","1") // Pendente Desatualização, Data, Fiscal
			If !aRet[1]
				cMsgErro := "** Erro ao desatualizar Documento de Frete para o Fiscal: " + aRet[2][6]
				Return .F.
			EndIf
		Else
			cMsgErro := "** Data Fiscal em branco ou maior que a data do último fechamento (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf
	Else
		// Data de Entrada (1)
		If SuperGetMv("MV_DSOFDT",,"1") == "1" .and. SUPERGETMV("MV_ERPGFE",.F.,"2") == "1"
			// A Fatura de Frete não foi enviada
			If Empty((cAliasGW3)->GW3_DTENT)
				cMsgErro := "Data de Entrada não informada."
				Return .F.
			EndIf

			// Data de envio da Fatura de Frete deve ser posterior a data do último fechamento: (Parâmetro MV_DTULFE)
			If (cAliasGW3)->GW3_DTENT <= DTOS(SuperGetMv("MV_DTULFE",,"20000101"))
				cMsgErro := "Data de Entrada '" + cValToChar((cAliasGW3)->GW3_DTENT) + "' deve ser posterior a data do último fechamento."
				Return .F.
			EndIf

			dDataFis := STOD((cAliasGW3)->GW3_DTENT)
		EndIf


		// Data Financeira (2)
		If SuperGetMv("MV_DSOFDT",,"1") == "2" .and. SUPERGETMV("MV_ERPGFE",.F.,"2") == "1"
			dbSelectArea("GW6")
			dbSetOrder(1)
			If dbSeek((cAliasGW3)->GW3_FILFAT + (cAliasGW3)->GW3_EMIFAT + (cAliasGW3)->GW3_SERFAT + (cAliasGW3)->GW3_NRFAT + (cAliasGW3)->GW3_DTEMFA)
				// A Fatura de Frete não foi enviada (quando a data de envio para o financeiro estiver em branco)
				If Empty(GW6->GW6_DTFIN)
					cMsgErro := "Data de envio ao financeiro da fatura em branco. Filial: " + (cAliasGW3)->GW3_FILFAT + ", Emissor: " + (cAliasGW3)->GW3_EMIFAT + ", Série: " + (cAliasGW3)->GW3_SERFAT + ", Nr: " + (cAliasGW3)->GW3_NRFAT
					Return .F.
				EndIf

				If GW6->GW6_DTFIN <= SuperGetMv("MV_DTULFE",,"20000101")
					cMsgErro := "Data de envio ao financeiro da fatura deve ser posterior a data do último fechamento. Filial: " + (cAliasGW3)->GW3_FILFAT + ", Emissor: " + (cAliasGW3)->GW3_EMIFAT + ", Série: " + (cAliasGW3)->GW3_SERFAT + ", Nr: " + (cAliasGW3)->GW3_NRFAT
					//Help( ,, 'Help',, "Data de envio da Fatura de Frete deve ser posterior a data do último fechamento: " + DTOC(SuperGetMv("MV_DTULFE",,"20000101")) + " (Parâmetro MV_DTULFE)", 1, 0 )
					Return .F.
				EndIf
			Else
				If (cAliasGW3)->GW3_TPDF != "3"
					//Help( ,, 'Help',, "Não há Fatura de Frete relacionado a este Documento de Frete", 1, 0 )
					cMsgErro := "Não há Fatura relacionada ao Documento de Frete"
					Return .F.
				EndIf
			EndIf

			If (cAliasGW3)->GW3_TPDF == "3"
				dDataFis := Date()
			Else
				dDataFis := GW6->GW6_DTFIN
			EndIf
		EndIf

		// Data Informada (3)
		If SuperGetMv("MV_DSOFDT",,"1") == "3" .and. SUPERGETMV("MV_ERPGFE",.F.,"2") == "1"
			If Empty(dDataInf)
				dDataInf := Date()
			EndIf

			// Data de transação deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)
			If dDataInf <= SuperGetMv("MV_DTULFE",,"20000101")
				cMsgErro := "Data de transação '" + DTOS(dDataInf) + "' deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)"
				Return .F.
			EndIf
		EndIf

		// Data Corrente (4)
		If SuperGetMv("MV_DSOFDT",,"1") == "4" .and. SUPERGETMV("MV_ERPGFE",.F.,"2") == "1"
			// Data de transação deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)
			If Date() <= SuperGetMv("MV_DTULFE",,"20000101")
				cMsgErro := "Data de transação '" + DTOS(dDataInf) + "' deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)"
				Return .F.
			EndIf

			dDataFis := Date()
		EndIf

		If SUPERGETMV("MV_ERPGFE",.F.,"2") != "1"
			dDataFis := ddatabase
		EndIf

		aRet := GFEA065In("2", dDataFis, "1","1") // Pendente, Data, Fiscal

		If !aRet[1]
			cMsgErro := "** Erro ao enviar o Documento de Frete para o Fiscal: " + aRet[2][6]
			Return .F.
		EndIf

	EndIf

Return .T.


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RecDoctoFrete()
Integração com EMS - Apropriação de Custos por Lote
Generico

@sample
GFEA067AD(dDataInf)

@author Israel Possoli
@since 30/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function RecDoctoFrete(dDataInf, cAcao)
	Local aRet

	If cAcao == 3	
		If !VldFatFin("Doc.Frete")		   
		   Return .F.
		EndIf
		
		If STOD( (cAliasGW3)->GW3_DTREC ) > SuperGetMv("MV_DTULFE",,"20000101")
			GFEA065In("5", dDataInf, "2","1") // Pendente Desatualização, Data, Custos
		EndIf
	Else
		If Empty(dDataInf)
			dDataInf := Date()
		EndIf

		// Data de transação deve ser posterior a data do último fechamento: (Parâmetro MV_DTULFE)
		If dDataInf <= SuperGetMv("MV_DTULFE",,"20000101")
			cMsgErro := "Data de transação '" + DTOS(dDataInf) + "' deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf

		aRet := GFEA065In("2", dDataInf, "2","1") // Pendente, Data, Custos

		If !aRet[1]
			cMsgErro := "** Erro ao enviar o Documento de Frete para Apropriação de Despesas: " + aRet[2][6]
			Return .F.
		EndIf
	EndIf
Return .T.

/* --------------------------------------------------------------------------------------------------
{Protheus.doc} FiscalFatura
Validações de envio de Integração Fiscal dos Documentos de Frete por Faturas
Generico.

@parametros
dDataInf = Data informada
cAcao (1=Atualização, 2=Atualização de Rejeitadas, 3=Desatualização)

@author Israel Alcantara Possoli
@since 08/04/09
@version 1.0
-------------------------------------------------------------------------------------------------- */
Static Function FiscalFatura(dDataInf, cAcao)
	Local dDataFis
	Local aRet
	Local nERPInt := SUPERGETMV("MV_ERPGFE",.F.,"2")
	
	// Desatualizar(3)
	If cAcao == 3
	    If !VldFatFin("Fatura")		   
		   Return .F.
		EndIf
		
		If !Empty(GW3->GW3_DTFIS) .And. GW3->GW3_DTFIS > SuperGetMv("MV_DTULFE",,"20000101")
			aRet := GFEA065In("5", dDataFis, "1","1") // Pendente Desatualização, Data, Fiscal
			If !aRet[1]
				cMsgErro := "** Erro ao desatualizar Documento de Frete para o Fiscal: " + aRet[2][6]
				Return .F.
			EndIf
		Else
			cMsgErro := "** Data Fiscal em branco ou menor que a data do último fechamento (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf
				
	// Atualizar(1) ou Atualizar Rejeitados(2) 
	Else
		If Empty(dDataInf) 
			// Data de Entrada (1)
			If SuperGetMv("MV_DSOFDT",,"1") == "1" .and. nERPInt = "1" 
				// A Fatura de Frete não foi enviada
				If Empty(GW3->GW3_DTENT)
					cMsgErro := "Data de Entrada não informada."
					Return .F.
				EndIf

				// Data de envio da Fatura de Frete deve ser posterior a data do último fechamento: (Parâmetro MV_DTULFE)
				If GW3->GW3_DTENT <= SuperGetMv("MV_DTULFE",,"20000101")
					cMsgErro := "Data de Entrada '" + cValToChar(GW3->GW3_DTENT) + "' deve ser posterior a data do último fechamento."
					Return .F.
				EndIf

				dDataFis := GW3->GW3_DTENT
			// Data Financeira (2)
			ElseIf SuperGetMv("MV_DSOFDT",,"1") == "2" .and. nERPInt = "1" 
				If (cAliasGW6)->GW6_SITFIN != "4"
					cMsgErro := "A Fatura deve estar atualizada no Financeiro para enviar os Documentos de Frete relacionados para o Fiscal."
					Return .F.
				EndIf
			
				dDataFis := STOD((cAliasGW6)->GW6_DTFIN)
			EndIf
		Else
    		If nERPInt = "1"  
    			dDataFis := dDataInf
    		else 
    		  dDataFis := dDatabase	
    		EndIf
		EndIf
		
		// Data de transação deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)
		If dDataFis <= SuperGetMv("MV_DTULFE",,"20000101")
			cMsgErro := "Data de transação '" + DTOS(dDataFis) + "' deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf

		// A data de atualização do fiscal não pode ser nula.
		If Empty(dDataFis)
			cMsgErro := "Data de transação em branco."
			Return .F.
		EndIf

		// Atualiza situação do registro com base na execução da integração
		// Datasul
		If nERPInt = "1" 
			RecLock("GW3", .F.)
				GW3->GW3_SITFIS := "2"
				GW3->GW3_MOTFIS := ""
				GW3->GW3_DTFIS  := dDataFis
			GW3->( MsUnlock() )
		// Protheus ou Outros
		Else
			GFEA065In("2", dDataFis, "3","1")
		EndIf

	EndIf

Return .T.


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RecFatura()
Integração com EMS - Apropriação de Custos por Lote
Generico

@sample
GFEA067AD(dDataInf)

@author Israel Possoli
@since 30/04/2010
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function RecFatura(dDataInf, cAcao)
	Local nERPInt 	:= SuperGetMv("MV_ERPGFE")
	Local dDataRec
	Local aRetInt	:= {}
		
	// Desatualizar(3)
	If cAcao == 3
		
		If !VldFatFin("Fatura")		   
		   Return .F.
		EndIf
		
		If !Empty(GW3->GW3_DTREC) .And. GW3->GW3_DTREC > SuperGetMv("MV_DTULFE",,"20000101")
			aRet := GFEA065In("5", dDataRec, "2","1") // Pendente Desatualização, Data, Fiscal
			
			If !aRet[1]
				cMsgErro := "** Erro ao desatualizar Documento de Frete para o Recebimento: " + aRet[2][6]
				Return .F.
			EndIf
		Else
			cMsgErro := "** Data Recebimento em branco ou menor que a data do último fechamento (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf
	// Atualizar(1) ou Atualizar Rejeitados(2)	
	Else	
		// Verifica a Data Informada em tela, caso a mesma esteja em branco utiliza o parâmetro
		If Empty(dDataInf)
			// Data Corrente (1)
			If SuperGetMV('MV_DSDTRE',,'1') == "1"
				dDataRec := DATE()
			// Data Criação (2)
			ElseIf SuperGetMV('MV_DSDTRE',,'1') == "2"
				dDataRec := GW3->GW3_DTEMIS
			// Data Financeira (4)
			ElseIf SuperGetMV('MV_DSDTRE',,'1') == "4"
				If (cAliasGW6)->GW6_SITFIN != "4"
					cMsgErro := "A Fatura deve estar atualizada no Financeiro para enviar os Documentos de Frete relacionados para o Recebimento."
					Return .F.
				EndIf
			
				dDataRec := STOD((cAliasGW6)->GW6_DTFIN)	 			
			EndIf
		// Senão utiliza a Data Informada, caso o parâmetro seja Data Informada (3) também será utilizada esta opção
		Else
			dDataRec := dDataInf
		EndIf		
		
		// Data de transação deve ser posterior a data do último fechamento: (Parâmetro MV_DTULFE)
		If dDataRec <= SuperGetMv("MV_DTULFE",,"20000101")
			cMsgErro := "Data de transação '" + DTOS(dDataRec) + "' deve ser posterior a data do último fechamento (Parâmetro MV_DTULFE)"
			Return .F.
		EndIf
	
		// A data de atualização do recebimento não pode ser nula.
		If Empty(dDataRec)
			cMsgErro := "Data de transação em branco."
		EndIf

		// Atualiza situação do registro com base na execução da integração
		// Datasul
		If nERPInt = "1" 
			RecLock("GW3", .F.)
				GW3->GW3_SITREC := "2"
				GW3->GW3_MOTREC := ""
				GW3->GW3_DTREC  := dDataRec	
			GW3->( MsUnlock() )
		// Protheus ou Outros
		Else
			aRetInt := GFEA065In("2", dDataRec, "3","1")

			If !aRetInt[1]
				cMsgErro := aRetInt[2][6]
				Return .F.
			EndIf
		EndIf
		
	EndIf
Return .T.
//-------------------------------------

Static Function VldFatFin(cDocto)
Local cIntFisc  := SuperGetMv("MV_GFEI23",.F.,"2")

If cIntFisc == "1"
	IF cDocto == "Fatura"
	 	GW6->( dbSetOrder(1) )
	    If GW6->( dbSeek( GW3->GW3_FILFAT + GW3->GW3_EMIFAT + GW3->GW3_SERFAT + GW3->GW3_NRFAT +  DToS(GW3->GW3_DTEMFA)) )
	       If GW6->GW6_SITFIN == "2" .OR. GW6->GW6_SITFIN == "4"
	       		cMsgErro := "Documento de Frete vinculado à uma Fatura atualizada ou pendente de atualização no Financeiro." ;
	       		           + "Quando o Parâmetro 'Fiscal Pré-requisito para Atualizar Fatura com Financ.' está ativado, não é possível desatualizar o documento do Fiscal/Recebimento se ele estiver em uma fatura atualizada no financeiro."       			
	        	 
	      	  	 Return .F.       	   	
	        EndIf
	    EndIf	 
	 Else
	 	GW6->( dbSetOrder(1) )
	    If GW6->( dbSeek( (cAliasGW3)->GW3_FILFAT + (cAliasGW3)->GW3_EMIFAT + (cAliasGW3)->GW3_SERFAT + (cAliasGW3)->GW3_NRFAT + (cAliasGW3)->GW3_DTEMFA))
	       If GW6->GW6_SITFIN == "2" .OR. GW6->GW6_SITFIN == "4"
	       		cMsgErro := "Documento de Frete vinculado à uma Fatura atualizada ou pendente de atualização no Financeiro." ;
	       		           + "Quando o Parâmetro 'Fiscal Pré-requisito para Atualizar Fatura com Financ.' está ativado, não é possível desatualizar o documento do Fiscal/Recebimento se ele estiver em uma fatura atualizada no financeiro."       			
	        	 
	      	  	 Return .F.       	   	
	       EndIf
	    EndIf
	 EndIf	    
	
EndIf
Return .T.

/*
Static Function SchedDef()
	Local aParam
	Local aOrd := {}

	aParam := {;
				"R"                                ,;  // Tipo: R para relatorio P para processo
				PadR("GFEA067", Len(SX1->X1_GRUPO)),;  // Pergunte do relatorio, caso nao use passar "PARAMDEF"
				"GW3"                              ,;  // Alias
				aOrd                               ,;  // Array de ordens
			  }

Return aParam
*/
