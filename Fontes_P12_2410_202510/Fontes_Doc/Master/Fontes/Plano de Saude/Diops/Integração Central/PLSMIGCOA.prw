#include 'protheus.ch'
#include 'FWMVCDEF.CH'
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMIGCOA.

Funcao de importacao do COBERTURA ASSISTENCIAL do PLS para a Central de Obrigações


@author Roger C.
@since 14/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMIGCOA(cTrimestre, cAno, cAuto)

	Local lRet	 := .T.
	local aDados := {}
	Local nVez	 := 0
	Local lAuto  := .F.
	Local nQtdDatImp := 0
	Local cErrMsg := ""
	Local aDataImp := {}

	If !Empty(cAuto) .AND. cAuto == '.T.'
		lAuto := .T.
	Else
		lAuto := .F.
	EndIf

	aDados := PLDCOBASSI(.F.,cTrimestre,cAno, lAuto)

	If !Empty(aDados) .AND. aDados[1]

		// Posiciona Operadora
		BA0->(dbSetOrder(1))
		BA0->(dbSeek(xFilial('BA0')+PlsIntPad()))

		// Chama função que informa a Central de Obrigações que enviaremos o COBERTURA ASSISTENCIAL
		// quadroIniEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
		If qdrPlsIniEnvDiops( '9', BA0->BA0_SUSEP, cAno, cTrimestre, .T. )

			For nVez := 1 to Len( aDados[2] )

				// chamada da funcao de inclusão do COBERTURA ASSISTENCIAL - a função quadroIniEnvDiops() limpou os registros do periodo, se existiam
				If !Empty(Subs(aDados[2,nVez,1],1,4))
					If IncCobAssi(MODEL_OPERATION_INSERT,aDados[2,nVez])
						nQtdDatImp++
					Else
						aAdd( aErroDIOPS, '9' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
						lRet	:= .F.
					EndIf
				Else
					cErrMsg := 'Produto não preenchido no quadro Cobertura Assistencial.'
					aAdd( aErroDIOPS, '9' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
					lRet	:= .F.

				EndIf

				// Destruir o objeto
				DelClassIntf()

			Next

			// Função que informa a Central de Obrigações que o quadro do COBERTURA ASSISTENCIAL foi enviado.
			// quadroFimEnvDiops( cQuadro, cCodOpe, cAno, cRefere )
			qdrPlsFimEnvDiops( '9', BA0->BA0_SUSEP, cAno, cTrimestre )

		Else
			cErrMsg := 'Não foi possível inicializar o quadro Cobertura Assistencial.'
			aAdd( aErroDIOPS, '9' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
			lRet	:= .F.
		EndIf
	Else
		cErrMsg := 'Não foram encontrados dados para exportação do quadro Cobertura Assistencial.'
		aAdd( aErroDIOPS, '9' )	// Variavel Private proveniente do fonte PLSDIOPSPL.prw
		lRet	:= .F.
	EndIf

	Aadd(aDataImp,{lRet,nQtdDatImp,cErrMsg})

Return aDataImp


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IncCobAssi

Funcao inclui COBERTURA ASSISTENCIAL no nucleo de informacoes e obrigacoes

@param nOpcMVC	3-Incluir, 4-Alterar

@return lRet	Indica se concluiu .T. ou nao .F. a operacao

@author Roger C
@since 16/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function IncCobAssi(nOpcMVC, aDados)
	Local lRet := .F.
	Default nOpcMVC	:= MODEL_OPERATION_INSERT
	Default aDados	:= {}

	If !Empty(aDados)

		oModel:= FWLoadModel( 'PLSMVCCOAS' )
		oModel:SetOperation( nOpcMVC )
		oModel:Activate()
		oModel:SetValue( 'B8IMASTER', 'B8I_FILIAL'	, xFilial('B8I') )
		oModel:SetValue( 'B8IMASTER', 'B8I_CODOPE'	, BA0->BA0_SUSEP )
		oModel:SetValue( 'B8IMASTER', 'B8I_CODOBR'	, "000" )
		oModel:SetValue( 'B8IMASTER', 'B8I_ANOCMP'	, MV_PAR02 )
		oModel:SetValue( 'B8IMASTER', 'B8I_CDCOMP'	, "000" )
		oModel:SetValue( 'B8IMASTER', 'B8I_REFERE'	, StrZero(Val(MV_PAR01),2) )
		oModel:SetValue( 'B8IMASTER', 'B8I_PLANO'	, Subs(aDados[1],1,4) )
		oModel:SetValue( 'B8IMASTER', 'B8I_ORIGEM'	, Subs(aDados[1],5,1) )
		oModel:SetValue( 'B8IMASTER', 'B8I_CONSUL'	, aDados[2] )
		oModel:SetValue( 'B8IMASTER', 'B8I_EXAMES'	, aDados[3] )
		oModel:SetValue( 'B8IMASTER', 'B8I_TERAPI'	, aDados[4] )
		oModel:SetValue( 'B8IMASTER', 'B8I_INTERN'	, aDados[5] )
		oModel:SetValue( 'B8IMASTER', 'B8I_OUTROS'	, aDados[6] )
		oModel:SetValue( 'B8IMASTER', 'B8I_DEMAIS'	, aDados[7] )
		oModel:SetValue( 'B8IMASTER', 'B8I_STATUS'	, "1" )

		If oModel:VldData()
			oModel:CommitData()
			lRet := .T.
		Else
			aErro := oModel:GetErrorMessage()
		EndIf

		oModel:DeActivate()
		oModel:Destroy()
		FreeObj(oModel)
		oModel := Nil

	EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLDCOBASSI
Dados da DIOPS da movimentação de Cobertura Assitencial

@author  Rodrigo Morgon
@version P12
@since   03/02/2017
@param   aDados, array, dados considerados para gerar o CSV

@return  nil, resultado da função é o .CSV gerado na pasta do server.
/*/
//-------------------------------------------------------------------
function PLDCOBASSI(lDadosCSV,cTrimestre,cAno)
	local cQuery		:= ""
	local aDados 		:= {}
	Local nTotReg		:= 0
	Local dDataIni		:= Ctod('')
	Local dDataFim		:= Ctod('')
	Local cArqTmp		:= GetNextAlias()
	Local cPlano		:= ''
	Local cOrigem		:= ''
	Local nColEvto		:= 0
	Local cTpEvto		:= ''
	Local nPos			:= 0
	Local nPos2			:= 0
	Local cCorrCed       := GETNEWPAR("MV_PLSTPIN", 'OPE')

	Default lDadosCSV	:= .F.
	Default cTrimestre	:= ""
	Default cAno		:= ""

	dDataIni	:= CtoD('01/'+StrZero(Val(cTrimestre),2)+'/'+cAno)
	dDataFim	:= LastDay(STOD(Alltrim(cAno)+Alltrim(StrZero(Val(cTrimestre)*3,2))+'01'))

	// Monta Temporário
	cQuery	:= "SELECT SUM(BD7_VLRPAG) AS VALOR, BI3_APOSRG, BI3_NATJCO, BD7_TIPGUI, BD7_OPEUSR, BT5_INTERC, BAU_RECPRO, BD7_TPEVCT, BAU_TIPPRE,BD6_OPEORI  "
	cQuery	+= "FROM " + RetSqlName("BD7") + " BD7 "

	//Produto Saúde
	cQuery	+= "INNER JOIN "+RetSqlName("BI3")+" BI3 "
	cQuery	+= "ON BI3_FILIAL	= '" + xFilial("BI3") + "' "
	cQuery	+= "AND BI3_CODIGO = BD7.BD7_CODPLA "
	cQuery	+= "AND BI3.D_E_L_E_T_ = ' ' "

	//Rede de Atendimento
	cQuery	+= "INNER JOIN "+RetSqlName("BAU")+" BAU "
	cQuery	+= "ON BAU_FILIAL	= '" + xFilial("BAU") + "' "
	cQuery	+= "AND BAU_CODIGO = BD7.BD7_CODRDA "
	cQuery	+= "AND BAU.D_E_L_E_T_ = ' ' "

	//Contrato
	cQuery	+= "LEFT JOIN "+RetSqlName("BT5")+" BT5 "
	cQuery	+= "ON BT5_FILIAL	= '" + xFilial("BT5") + "' "
	cQuery	+= "AND BT5_CODINT = BD7.BD7_OPEUSR "
	cQuery	+= "AND BT5_CODIGO = BD7.BD7_CODEMP "
	cQuery	+= "AND BT5_NUMCON = BD7.BD7_CONEMP "
	cQuery	+= "AND BT5_VERSAO = BD7.BD7_VERCON "
	cQuery	+= "AND BT5.D_E_L_E_T_ = ' ' "

	//BD6
	cQuery	+= "LEFT JOIN "+RetSqlName("BD6")+" BD6 "
	cQuery	+= " ON BD6_FILIAL	= '" + xFilial("BT5") + "' "
	cQuery	+= "AND BD6_CODOPE = BD7.BD7_OPEUSR "
	cQuery	+= "AND BD6_CODEMP = BD7.BD7_CODEMP "
	cQuery	+= "AND BD6_CONEMP = BD7.BD7_CONEMP "
	cQuery	+= "AND BD6_VERCON = BD7.BD7_VERCON "
	cQuery	+= "AND BD6_CODLDP = BD7.BD7_CODLDP "
	cQuery	+= "AND BD6_CODPEG = BD7.BD7_CODPEG "
	cQuery	+= "AND BD6_NUMERO = BD7.BD7_NUMERO "
	cQuery	+= "AND BD6_CODPAD = BD7.BD7_CODPAD "
	cQuery	+= "AND BD6_CODPRO = BD7.BD7_CODPRO "
	cQuery	+= "AND BD6.D_E_L_E_T_ = ' ' "

	//Rastreamento Contábil
	cQuery	+= "INNER JOIN "+RetSqlName("CV3")+" CV3 "
	cQuery	+= "ON CV3_FILIAL	= '" + xFilial("CV3") + "' "
	cQuery	+= "AND CV3.CV3_TABORI = 'BD7' "
	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
		cQuery	+= "AND NVL(CAST(CV3_RECORI as int),0) = BD7.R_E_C_N_O_  "
	Else
		cQuery	+= "AND CONVERT(Int,CV3_RECORI) = BD7.R_E_C_N_O_ "
	EndIf
	cQuery	+= "AND CV3.D_E_L_E_T_ 	= '' "

	//Lançamentos Contábeis
	cQuery += "INNER JOIN "+RetSqlName("CT2")+" CT2 "
	cQuery += "ON CT2_FILIAL 	= '" + xFilial("CT2") + "' "
	If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
		cQuery	+= "AND CT2.R_E_C_N_O_ = NVL(CAST(CV3_RECDES as int),0)  "
	Else
		cQuery	+= "AND CT2.R_E_C_N_O_ = CONVERT(Int,CV3_RECDES)  "
	EndIf
	cQuery	+= "AND CT2.D_E_L_E_T_ = ' ' "

	cQuery += "WHERE BD7_FILIAL	= '" + xFilial("BD7") + "' "
	cQuery	+= "AND BD7.BD7_DTDIGI BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "
	cQuery	+= "AND BD7_SITUAC = '1' "
	cQuery	+= "AND BD7_FASE = '4' "
	cQuery	+= "AND BD7.D_E_L_E_T_ = ' ' "

	cQuery	+= "GROUP BY BI3_APOSRG, BI3_NATJCO, BD7_TIPGUI, BD7_OPEUSR, BT5_INTERC, BAU_RECPRO, BD7_TPEVCT, BAU_TIPPRE, BD6_OPEORI"
	cQuery	+= "ORDER BY BI3_APOSRG, BI3_NATJCO, BD7_TIPGUI, BD7_OPEUSR, BT5_INTERC, BAU_RECPRO, BD7_TPEVCT "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQuery)),cArqTmp,.T.,.F.)

	(cArqTmp)->( DbEval( {|| nTotReg++ } ) )

	//Monta régua dos meses
	ProcRegua(nTotReg)

	If nTotReg > 0

		(cArqTmp)->(dbGoTop())
		While !(cArqTmp)->(Eof())

			IncProc()

			cNatJCo	:= (cArqTmp)->BI3_NATJCO
			/*
		-> TAG: <plano>
		BD7_CODPLA -> BI3_APOSRG (0-ANTES LEI/1-APOS LEI/2-ADAPTADO) BI3_NATJCO (2=Fisica;3=Empresarial;4=Adesao;5=Beneficente)
		""IFAL"" = Carteira de Planos Individuais/Familiares antes da Lei
		""IFPL"" = Carteira de Planos Individuais/Familiares pós Lei
		""PLAL"" = Planos Coletivos por Adesão antes da Lei
		""PLAP"" = Planos Coletivos por Adesão Pós Lei
		""PCEA"" = Planos Coletivos Empresariais antes da Lei
		""PCEL"" = Planos Coletivos Empresariais pós Lei
		""CRAS"" = Cobertura Assistencial com Preço Pré Estabelecido - Corresponsabilidade Assumida (quando minha Operadora atende beneficiário de outra Operadora)"
			*/
			If (cArqTmp)->BD6_OPEORI <> PlsIntPad() .And. Alltrim(cCorrCed) == Alltrim((cArqTmp)->BAU_TIPPRE)
				cPlano	:= 'CRAS'

			Else
				// Planos Não Regulamentados
				If (cArqTmp)->BI3_APOSRG == '0'
					Do Case
						// Plano Individual e Familiar
						Case cNatJCo == '2'
							cPlano	:= 'IFAL'

							// Plano Coletivo Empresarial
						Case cNatJCo == '3'
							cPlano	:= 'PCEA'

							// Plano Coletivo por Adesão
						Case cNatJCo == '4'
							cPlano	:= 'PLAL'

							// Ignora se não tem Classificação corretamente preenchida
						OtherWise
							cPlano	:= '    '

					EndCase

					// Planos Regulamentados
				Else
					Do Case
						// Plano Individual e Familiar
						Case cNatJCo == '2'
							cPlano	:= 'IFPL'

							// Plano Coletivo Empresarial
						Case cNatJCo == '3'
							cPlano	:= 'PCEL'

							// Plano Coletivo por Adesão
						Case cNatJCo == '4'
							cPlano	:= 'PLAP'

							// Ignora se não tem Classificação corretamente preenchida
						OtherWise
							cPlano	:= '    '

					EndCase

				EndIf
			Endif

			cTpEvto	:= (cArqTmp)->BD7_TPEVCT
			/*
		Tipo de Evento
		BD7_TPEVCT
		0 = Consulta			=> 01 - Consultas
		1 = Exames				=> 02/03 - Exames
		2 = Terapias			=> 04/05 - Terapias
		3 = Internações			=> 06-11 - Internações
		4 = Outros Atendimentos	=> 12 - Outros Atendimento
		5 = Demais Despesas		=> 13 - Demais Despesas
		???						=> 14 - Odonto
			*/
			// SERÁ NECESSÁRIO VERIFICAR TRATAMENTO ODONTO COM ALEX QUANDO ELE RETORNAR DE FÉRIAS - 15/05/18
			Do Case
				// Consulta
				Case cTpEvto == '01'
					nColEvto := 2
					// Exame
				Case cTpEvto $ '02/03'
					nColEvto := 3
					// Terapias
				Case cTpEvto $ '04/05'
					nColEvto := 4
					// Internações
				Case cTpEvto $ '06/07/08/09/10/11'
					nColEvto := 5
					// Outros Atendimentos
				Case cTpEvto == '12'
					nColEvto := 6

					// Demais Despesas
				OtherWise
					//			Case cTpEvto == '13'  --> enquanto não definir caso do Tipo de Evento = 14
					nColEvto := 7
			EndCase


			cOrigem	:= ''
			/*
		"-> TAG: <origem>
		Tipo de Prestador
		5 = Atendimentos em Corresponsabilidade	=> BD7_OPEUSR <> PlsIntPad() => Somente a partir de 2018
		2 = Reembolso				=> BD7->BD7_TIPGUI == REEMBOLSO
		3 = Intercâmbio Eventual	=> BT5->BT5_INTERC == '1'
		0 = Rede Própria			=> BAU_RECPRO = '1'
		1 = Rede Contratada			=> BAU_RECPRO = '0'
		4 = Outras Formas Pagamento	=> ELSE?
		6 = Corresponsabilidade Cedida
			*/
			If Alltrim(cCorrCed) == Alltrim((cArqTmp)->BAU_TIPPRE) .And. (cArqTmp)->BD6_OPEORI == PlsIntPad()
				// Corresponsabilidade Cedida - Quando outra Operadora atende meu beneficiário.
				cOrigem	:= '6'
			Endif

			If Empty(cOrigem)
				// Reembolso
				If	(cArqTmp)->BD7_TIPGUI == '04'
					cOrigem	:= '1'

					// Intercâmbio
				ElseIf (cArqTmp)->BT5_INTERC == '1'
					cOrigem	:= '3'

					// Rede Própria
				ElseIf (cArqTmp)->BAU_RECPRO == '1'
					cOrigem	:= '0'

					// Rede Contratada
				ElseIf (cArqTmp)->BAU_RECPRO == '0'
					cOrigem	:= '1'

				EndIf

			EndIf

			nPos	:= 0
			nPos2	:= 0
			nValor	:= (cArqTmp)->VALOR

			// Se já houver registro, procura para posicionar
			If Len(aDados) > 0
				nPos := Ascan(aDados,{|x| x[1] == cPlano+cOrigem })
				If nPos == 0
					lCria := .T.
				Else
					aDados[nPos,nColEvto] += nValor
					lCria := .F.
				EndIf

				// Se não há registro, cria diretamente
			Else
				lCria := .T.
			EndIf

			If lCria .and. nValor > 0
				aAdd( aDados, { cPlano+cOrigem, IIf(nColEvto==2,nValor,0), IIf(nColEvto==3,nValor,0), IIf(nColEvto==4,nValor,0), IIf(nColEvto==5,nValor,0), IIf(nColEvto==6,nValor,0), IIf(nColEvto==7,nValor,0) } )
			EndIf
			(cArqTmp)->(dbSkip())

		EndDo

	Else
		(cArqTmp)->(dbCloseArea())

	EndIf

Return( { (Len(aDados)>0), aDados } )
