#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"
#INCLUDE "FWMVCDEF.CH"

STATIC aTabProg    := {}
STATIC aTabDep     := {}
STATIC aPesqF2D    := {}
STATIC aPesqSD1    := {}
STATIC aPesqF0R    := {}
STATIC PVALORI     := Iif(fisFindFunc("xFisTpForm"), xFisTpForm("0"), "")
STATIC PINDCALC    := Iif(fisFindFunc("xFisTpForm"), xFisTpForm("9"), "")
STATIC LSEMREDUCAO := .F.
STATIC lAliqSemRed := .F.
STATIC lAliascj3   := fisExtTab( '12.1.2310' , .T., "CJ3")
STATIC lAliasCIN   := fisExtTab( '12.1.2310' , .T., "CIN")
STATIC jPrepared   := nil
STATIC __aPrepared := {}
STATIC aPesqEstr   := {} //Ultima aquisição com estrutura de produto
STATIC jOpAntes    := nil
STATIC jOpDepois   := nil
STATIC jTributo    := nil
STATIC nTamCINCod  := If(lAliasCIN, FisTamSX3( 'CIN' , 'CIN_CODIGO' )[1], 0)
Static cDB         := Upper(TCGetDB())
STATIC jTrbRef     := nil
STATIC jRefLeg     := nil
STATIC jTribAddDat := nil
STATIC lFpACMAX    := fisExtCmp( '12.1.2410' , .T., 'F2B' , 'F2B_ACMAX' ) .and. fisExtCmp( '12.1.2410' , .T., 'F2B' , 'F2B_ACMIN' )
STATIC lCmpRedAliq := fisExtCmp('12.1.2510', .T., 'F28', 'F28_REDALI') .and. fisExtCmp('12.1.2510', .T., 'CJ3', 'CJ3_PREDAL') .and.;
	fisExtCmp('12.1.2510', .T., 'CJ3', 'CJ3_ALIQOR')
STATIC lCmpCCT	   := fisExtCmp('12.1.2510', .T., 'CJ2', 'CJ2_CCT') .and. fisExtCmp('12.1.2510', .T., 'CJ3', 'CJ3_CCT')
STATIC lCmpNPIMemo := fisExtCmp( '12.1.2410' , .T., 'CIN' , 'CIN_FNPI_M' )
STATIC lDadosAd    := AliasIndic("CK2") .And. AliasIndic("CK3") .And. AliasIndic("CK4")
STATIC lNrLivro    := fisExtCmp('12.1.2510', .T., 'CJ2' , 'CJ2_NLIVRO') .and. fisExtCmp('12.1.2510', .T., 'CJ3' , 'CJ3_NLIVRO')
STATIC lIncideDev  := fisExtCmp('12.1.2510', .T., 'CJ2' , 'CJ2_INCDEV') .and. fisExtCmp('12.1.2510', .T., 'CJ2' , 'CJ2_INCRBS')
STATIC lIndOp      := fisExtCmp('12.1.2510', .T., 'CJ2' , 'CJ2_INDOP')
STATIC lTotNfDev   := fisExtCmp('12.1.2510', .T., 'CJ2' , 'CJ2_DSTONF')
STATIC jCacheCIN   := nil
STATIC aTabAdic    := {}
STATIC lCI6Enabled := fisExtTab('12.1.2610', .T., 'CI6') .And. fisExtTab('12.1.2610', .T., 'CI7')
STATIC lFaixaEsp := AliasIndic("CI2") .And. CIQ->(FieldPos("CIQ_DEDSIR") > 0)
STATIC oSE2Fin := JsonObject():New()
STATIC jMapProc    := nil
STATIC jCtxCache   := Nil          // Contexto de cache centralizado: EMPRESA/FILIAL/RULES_STAMP
STATIC jCacheTokens := nil         // Cache de fórmulas tokenizadas - evita StrTokArr repetido (ganho 7+ segundos)
STATIC jTribIndex := nil           // Cache hash index de tributos por sigla - lookup O(1) ao invés de aScan O(n)
STATIC jNPIResultCache := Nil      // Cache L1 unificado NPI - operandos simples e tributos em cascata
STATIC lSkipNPIResultCache := .F.  // Controle pontual para ignorar cache result-final em comparações MAIOR/MENOR
STATIC jTidTribs := JsonObject():New()  // Cache O(1): IDTRIB -> SIGLA (suporte TID em fórmulas)
STATIC jCacheNrmTid := Nil         // Cache O(1): operando T:<DET>:<ID> -> operando normalizado (VAL:SIGLA etc.)
STATIC jFISLtgIx    := Nil         // Mapa IDTRIB legado (AllTrim) -> posicao em ListTrbLeg; usado por FisPosTLeg
STATIC aFISLtgBase  := Nil         // Cache do retorno de ListTrbLeg; inicializado na primeira chamada a FISGetLtgBase

//-----------------------------------------------------------------------------------------------------------------------
//Este fonte tem objetivo de concentrar todas as funções e regras do configurador de tributos
//com objetivo de centralizar o código do configurador, evitando assim eventuais problemas de concorrência de fontes
//Somente funções que são envolvidas com o configurador deverão ser adicionadas nestes fonte.
//Este fonte é dependente da MATXFIS, IMPXFIS e MATXDEF
//-----------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisTrbGen()
Função que fará o enquadramento das regras de tributos géricos, procurando
pelos perfis de operação, produto/origem, operação e origem/destino.
Esta função também fará os cálculos dos tributos genéricos, e todas as informações
das regras e valores serão atualizados diretamente no aNfItem.

@param aNfCab     - Array com as informações cabeçalho da nota fiscal
@param aNfItem    - Array com toda as informações do item da nota fiscal
@param nItem      - Número do item da nota fiscal
@param cCampo     - Campo processado na Recall
@param cExecuta   - Campo com propriedade do tributo genérico que deverá ser processada, BSE, VLR ou ALQ
@param cTrib      - Tributo genérico que deverá ser processado
@param aPos       - Array com cache dos fieldpos
@param aDic       - Array com cache de aliasindic
@param nTGITRef   - Tamanho do array ItemRef dos tributos genéricos
@param jMapForm   - JsonObject com cache de operandos e fórmulas (O(1) lookup via HasProperty)
@param jDepTrib   - JsonObject com mapeamento de dependências entre tributos (estrutura dois níveis)
@param aDepVlOrig - Array com dependências de valores originais
@param aFunc      - Array com funções customizadas
@param aUltPesqF2D - Array com cache de pesquisas F2D

Performance: Utiliza JsonObject para cache O(1) ao invés de arrays O(n).
Otimização crítica: FindOper reduzido de 10M+ chamadas aScan para HasProperty.

@author Erick Gonçalves Dias
@since 26/06/2018
@version 12.1.17

Revisão: Migração de arrays para JsonObject (aMapForm?jMapForm, aDepTrib?jDepTrib)
@author revisão: Rafael Oliveira
@since revisão: 30/12/2025
@version revisão: 12.1.2510
/*/
//-------------------------------------------------------------------
Function FisTribGen(aNfCab, aNfItem, nItem, cCampo, cExecuta, cTrib, aPos, aDic, nTGITRef, jMapForm, jDepTrib, aDepVlOrig, aFunc, aUltPesqF2D)

	Local cAliasQry		:= ""
	Local cCodProd		:= aNfItem[nItem][IT_PRODUTO]
	Local cPart			:= aNfCab[NF_CODCLIFOR]
	Local cLoja			:= aNfCab[NF_LOJA]
	Local cTipoPart		:= Iif( aNfCab[NF_CLIFOR] == "C", "2" , "1" )
	Local cOrigProd		:= SubStr( aNfItem[nItem][IT_CLASFIS] , 1 , 1 )
	Local cUfOrigem		:= aNFCab[NF_UFORIGEM]
	Local cUfDestino	:= aNfCab[NF_UFDEST]
	Local cCfop			:= aNfItem[nItem][IT_CF]
	Local cTpOper		:= aNfItem[nItem][IT_TPOPER]
	Local cNcm 			:= aNfItem[nItem][IT_POSIPI]
	Local c1UM 			:= aNfItem[nItem][IT_B1UM]
	Local c2UM 			:= aNfItem[nItem][IT_B1SEGUM]
	Local cCodIss		:= aNfItem[nItem][IT_CODISS]
	Local cCodCest		:= aNfItem[nItem][IT_CEST]
	Local cExNcm		:= aNfItem[nItem][IT_PRD][SB_EX_NCM]
	Local nTrbGen		:= 0
	Local jTaxOper 		:= JsonObject():New()
	Local cUfServ		:= ""
	Local cMunServ		:= ""
	Local jVldTribs		:= JsonObject():New() // Otimização: Cache de tributos válidos

	Default cExecuta    := ""
	Default cTrib		:= ""
	Default jMapForm	:= JsonObject():New()
	Default jDepTrib	:= JsonObject():New()

//Atribuo o array das pesquisas com cache das notas
	aPesqF2D	:= aUltPesqF2D

	cCampo	:= Alltrim(cCampo)

// Verifica se a flag para cálculo dos tributos genéricos foi passada como ".T.". Esta flag é passada via MaFisIni e serve para indicar que
// a rotina consumidora está preparada para gravar, visualizar e excluir os tributos genéricos. Esta proteção serve para evitar que os tributos
// sejam calculados e não sejam gravados/visualizados devido à ausência da chamada dos componentes específicos criados para este fim.
	If aNfCab[NF_CALCTG]

	/*
	Considero as referências IT_RECORI pois é quando alterou o recno da nota original.
	Considero o IT_QUANT pois influencia diretamente na devolução, seja parcial ou integral.
	Refaço a query quando se altera a quantidade, pois preciso do valor original como base para refazer a proporcionalidade,
	caso contrário conseguria fazer a proporcionalidade correta somente da primeira vez.
	Verificou também se cCampo está vazio, pois no caso da planilha financeira e no faturamento a recall é chamada sem campo específico
	Verifico também se o RECORI está preenchido e se o tipo da nota é devolução ou beneficiamento
	*/
		If cCampo <> "IT_TRIBGEN" .AND. (aNFCab[NF_TIPONF] $ "DB" .or. IdentNfCR(aNfCab[NF_TIPONF], aNfCab[NF_CLIFOR])) .And. !Empty(aNFItem[nItem][IT_RECORI])
			IF Alltrim(cCampo) == "IT_RECORI" .OR. Alltrim(cCampo) == "IT_QUANT" .OR. cCampo == "IT_" .OR. Empty(cCampo)
				//Chama função que fará o tratamento das devoluções dos tributos genéricos
				FisDevTrbGen(aNfCab, @aNfItem, nItem, aPos, aDic, cCampo, nTGITRef, jMapForm, aDepVlOrig, aFunc)

				// Aplica politica de tributo para documentos com origem (CI6/CI7)
				If lCI6Enabled
					FisApplyRelPol(aNfCab, @aNfItem, nItem, jMapForm)
				EndIf

				If fisExtTab('12.1.2310', .T., 'CJ2')
					For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
						//Atualiza referências do livro
						FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, .T., .F.,.T.)
					Next nTrbGen
				Endif
			EndIF
		Else
			//-------------------------------------------------------------------------
			// MEMOIZAÇÃO: Inicializa caches no início do processamento normal (não-devolução)
			// O cache é válido apenas durante esta execução - será limpo ao final
			//-------------------------------------------------------------------------
			InitMemoCalc()

			/*Verifico se a Recall foi chamada na alteração de código de produto, código do participante, loja do participanta, uf de origem,
			UF de destino,código de TES e CFOP. Porém estou verificando também se cCampo está vazia, pois o processamento do faturamente chama somente 1
			vez a Recall, e não chama com alteração de campos específico, já que o envio de informações para MATXFIS é feito via load.
			Se estas condições forem atendidas a query será feira e todas as referências dos tributos genéricos também serão refeitos.*/
			If cCampo == "IT_PRODUTO" .OR. cCampo == "NF_CODCLIFOR" .OR. cCampo == "NF_LOJA"   .OR. cCampo == "NF_UFORIGEM" .OR. ;
			cCampo == "NF_UFDEST"  .OR. cCampo == "IT_CF"        .OR. cCampo == "IT_TES"    .OR. cCampo == "NF_DTEMISS"  .OR. ;
			cCampo == "NF_NATUREZA" .OR. cCampo == "IT_CLASFIS"   .OR. cCampo == "IT_TPOPER" .OR. cCampo == "IT_CODISS"  .OR. ;
			cCampo == "IT_POSIPI" .OR. cCampo == "IT_CEST" .OR. Empty(cCampo) .OR. cCampo=="NF_CODMUN";

				//Verifica primeiro se todos os campos "chaves" estão preenchidos antes de prosseguir com a query.
				If !Empty(cCodProd)  .AND. !Empty(cPart)      .AND. !Empty(cLoja)  .AND. !Empty(cTipoPart) .AND. ;
				!Empty(cUfOrigem) .AND. !Empty(cUfDestino) .AND. !Empty(cCfop)

					//Zero toda a estrutura dos tributos genéricos, já que as regras e perfis serão enquadrados novamente e tudo será refeito.
					aNfItem[nItem][IT_TRIBGEN]	:= Nil
					aNfItem[nItem][IT_TRIBGEN]	:= {}
					aNfItem[nItem][IT_TG_IDTRIB_IDX] := JsonObject():New()

					//Somente fará a query se o participante estiver contido em ao menos 1 perfil.
					If aNfCab[NF_PERF_PART]
							//Obtem UF e municípios do serviço
						DefMunServ(aNFCab, @cUfServ, @cMunServ, aNfItem[nItem][IT_PRD][SB_MEPLES] == "2")
						jTaxOper["codProduto"]		:= cCodProd
						jTaxOper["ncm"]				:= cNcm
						jTaxOper["um1"]				:= c1UM
						jTaxOper["um2"]				:= c2UM
						jTaxOper["origemProduto"]	:= cOrigProd
						jTaxOper["codParticipante"]	:= cPart
						jTaxOper["lojaParticipante"]:= cLoja
						jTaxOper["tipoParticipante"]:= cTipoPart
						jTaxOper["ufOrigem"]		:= cUfOrigem
						jTaxOper["ufDestino"]		:= cUfDestino
						jTaxOper["cfop"]			:= cCfop
						jTaxOper["dataOper"]		:= aNfCab[NF_DTEMISS]
						jTaxOper["tipoOper"]		:= cTpOper
						jTaxOper["codISS"]			:= cCodIss
						jTaxOper["ufServico"]		:= cUfServ
						jTaxOper["municipioServico"]:= cMunServ
						jTaxOper["codCest"]			:= cCodCest
						jTaxOper["exTarifario"]		:= cExNcm
						//Se todos os campos "chaves" estão preenchidos, chamaremos a função para realizar a query.
						cAliasQry	:= QryTribGen(jTaxOper,,aNfCab[NF_F2B_TESTE])

						// Otimização: Monta lista de tributos válidos para evitar mapeamento desnecessário no AddTrbGen -> MapOperForm
						BldValTrib(cAliasQry, @jVldTribs)

						FwFreeObj(jTaxOper)
						jTaxOper := Nil

						Do While !(cAliasQry)->(Eof())
							//Chama função para adicionar nova estrutura do tributo genérico, populando todas as referências das regras cadastradas
							//As informações serão atualizadas no próprio aNfItem
							nTrbGen	:= AddTrbGen(@aNfItem,nItem, cAliasQry, nTGITRef,aNfCab, aPos, aDic, jMapForm, jDepTrib, aDepVlOrig, .F., jVldTribs)
							//Preciso verificar se o tributo já consta no array do SaveDec, se já existe não precisa adicionar, se não existe ai será criado.
							TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)
							(cAliasQry)->(DbSKip())
						Enddo

						//Libera o objeto de tributos válidos
						FwFreeObj(jVldTribs)
						jVldTribs := Nil

						//Chama função que interpretará as regras de base de cálculo e alíquota e valor
						//As informações serão atualizadas no próprio aNfItem
						For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
							//Chama função que interpretará as regras de base de cálculo, alíquota e valor. Os valores serão atualizados no próprio aNfItem
							FisCalcTG(@aNFItem, nItem, nTrbGen,,aNfCab, jMapForm,,aFunc)
						Next nTrbGen

						If fisExtTab('12.1.2310', .T., 'CJ2')
							For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
								//Atualiza referências do livro
								FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, .T.)
							Next nTrbGen
						Endif

						//Fecha o Alias antes de sair da função
						dbSelectArea(cAliasQry)
						dbCloseArea()


					EndIF

				EndIF

			ElseIf Alltrim(cCampo) == "IT_TRIBGEN"

				//Aqui fará recálculo de um tributo específico. Ele precisa existir no IT_TRIBGEN, caso contrário não fará nenhuma ação.
				If !Empty(cTrib) .AND. (nTrbGen	:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cTrib)})) > 0
					//Aqui chamo a função para recalcular o tributo genérico específico, conforme passado no cTrib, bem como a propriedade passada no cExecuta

					//Se a regra de alíquota estiver configurada para obter alíquota por meio de tabela progressiva, então preciso aqui refazer alíquota também, para enquadrar novamente na tabela progressiva
					cExecuta += Iif(!Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]) .And. !("|ALQ" $ cExecuta) ,"|ALQ","")
					FisCalcTG(@aNFItem, nItem, nTrbGen, cExecuta,aNfCab, jMapForm, .T.,aFunc)

					If fisExtTab('12.1.2310', .T., 'CJ2')
						//Aqui atualizarei as referências do livro, se houver
						FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, .T.)
					Endif

				EndIf

			ElseIf Alltrim(cCampo) == "DEP"

				//Aqui fará recálculo de um tributo específico. Ele precisa existir no IT_TRIBGEN, caso contrário não fará nenhuma ação.
				If !Empty(cTrib) .AND. (nTrbGen	:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cTrib)})) > 0

					If fisExtTab('12.1.2310', .T., 'CJ2')
						//Aqui atualizarei as referências do livro, se houver
						FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, .T.)
					Endif

					If cExecuta == "TG_IT_BASE"

						//Obtem o operando do valor, já que a base foi alterada, o valor também será alterado e preciso refletir isso nos tributos dependentes do valor
						CalcDep(jDepTrib, aNfItem, nItem, aNfCab, jMapForm, aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR], "BSE",aFunc)

						//Realiza o cálculo dos tributos que são dependentes do operando alterado
						CalcDep(jDepTrib, aNfItem,nItem,aNfCab,jMapForm, aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR],"VLR",aFunc)



					ElseIf cExecuta == "TG_IT_VALOR" .OR. cExecuta == "TG_IT_ALIQUOTA"

						//Obtem o operando do valor, já que a base foi alterada, o valor também será alterado e preciso refletir isso nos tributos dependentes do valor
						CalcDep(jDepTrib, aNfItem,nItem,aNfCab,jMapForm, aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR], "VLR",aFunc)

					EndIF

				EndIf


			Else

				//--------------------------------------------------------------
				//Se não houver fórmulas fará o cálculo de todos os tributos
				//--------------------------------------------------------------
				If !(ValType(jMapForm) == "J" .And. Len(jMapForm:GetNames()) > 0)

					/*Aqui significa que não houve alteração dos campos chaves dos perfis, nem das regras e não é alteração do IT_TRIBGEN , logo a query não será refeita
					porém todos os cálculo dos tributos genéricos serão refeitos.*/
					For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
						//Chama função que interpretará as regras de base de cálculo, alíquota e valor. Os valores serão atualizados no próprio aNfItem
						FisCalcTG(@aNFItem, nItem, nTrbGen,,aNfCab, jMapForm,,aFunc)
					Next nTrbGen

				Else

					/*Aqui significa que não houve alteração dos campos chaves dos perfis, nem das regras e não é alteração do IT_TRIBGEN , logo a query não será refeita
					porém todos os cálculo dos tributos genéricos serão refeitos.*/
					If LeJson(aNfCab,cCampo,aNfItem,nItem) //faço um de-para das referencias com os operandos
						For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
							//Chama função que interpretará as regras de base de cálculo, alíquota e valor. Os valores serão atualizados no próprio aNfItem
							FisCalcTG(@aNFItem, nItem, nTrbGen, Iif(!Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]), "BSE|VLR|ALQ", "BSE|VLR|") ,aNfCab, jMapForm,,aFunc)
						Next nTrbGen
					Endif
					//------------------------------------------------------------------------------------------------------------
					//Se já fórmulas, então somente fará o cálculo dos tributos que são dependentes do campo alterado na nota!!!!
					//TODO Problema, quando alterado operando primario que esta contido em ou operando primario, não estava refazendo calculo, causando divergencia de valor
					//------------------------------------------------------------------------------------------------------------

					//Obter operando através do cCampo
					/*
					cOperando	:= REFxOPER(cCampo)
					If !Empty(cOperando)

						//Obter a posição do operando no array de dependencia
						nPosOper	:=  AScan(aDepVlOrig, { |x| Alltrim(x[1]) == Alltrim(cOperando)})

						//Se encontrou operando continua
						If nPosOper > 0

							//Laço em todos os tributos dependentes deste operando
							For nX := 1 to Len(aDepVlOrig[nPosOper][2])

								//Obtem a posição do tributo genérico
								nTrbGen	:= aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(aDepVlOrig[nPosOper][2][nX])})

								//Se encontrou a posição do tributo no AnfItem continua
								IF nTrbGen > 0

									//----------------------------------------------------------
									//Recalculo o tributo que é dependente do valor de origem
									//----------------------------------------------------------
									FisCalcTG(@aNFItem, nItem, nTrbGen, Iif(!Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]), "BSE|VLR|ALQ", "BSE|VLR|") ,aNfCab, jMapForm,,aFunc)
								EndIF

							Next nX
						EndIF

					EndIF
					*/

		EndIF

	EndIF

	//-------------------------------------------------------------------------
	// MEMOIZAÇÃO: Limpa todos os caches ao final do processamento (ciclo unificado)
	//-------------------------------------------------------------------------
	EndMemoCalc()
EndIF

If lFpACMAX
	//Valida se os tributos genéricos possuem limite minimo e máximo com referência a outros tributos
	ValidaTGLimite(aNfItem, nItem, aNfCab)

	//Remove os tributos marcados para exclusão
	RemoveTrbGen(aNfCab, aNfItem, nItem)
Endif

//Tratamento para os dados adicionais do tributo
If lDadosAd
	AddDataJson(aNfItem[nItem])
	SetAddRefs(aNfItem[nItem], QryCK3())
	SetAddRefs(aNfItem[nItem], QryCK4())
EndIf
EndIf

Return

/*/{Protheus.doc} QryTribGen
	Função que fará query de enquadramento de regras tributárias, buscando as regras
	considerando o contexto da operação.
O retorno desta função será o alias com o resultado da query.

	@type  Function
@author Erick Gonçalves Dias
@since 26/06/2018
@version 12.1.17

	@updater anedino.santos
	@updateIn 04/12/2025

	@param jTaxOper, json, possui todos os dados da operação *obrigatório
	@param cFields, character, string com todos os campos que devem ser retornados no select (os campos devem ser de acordo com as tabelas usadas na query) *opcional
	@param lF2BTeste, logical, indica se deve ser considerado regras em fase de teste na busca *opcional

	@return cAlias, character, alias da query processada

	@example
		jTaxOper["codProduto"] := "PA00001"
		jTaxOper["ncm"] := "1806.32.10"
		jTaxOper["um1"] := "UN"
		jTaxOper["um2"] := "CX"
		jTaxOper["origemProduto"] := "0"
		jTaxOper["codParticipante"] := "SP0002"
		jTaxOper["lojaParticipante"] := "02"
		jTaxOper["tipoParticipante"] := "C"
		jTaxOper["ufOrigem"] := "SP"
		jTaxOper["ufDestino"] := "SP"
		jTaxOper["cfop"] := "5101"
		jTaxOper["dataOper"] := dDataBase
		jTaxOper["tipoOper"] := "01"
		jTaxOper["codISS"] := ""
		jTaxOper["ufServico"] := ""
		jTaxOper["municipioServico"] := ""
		jTaxOper["codCest"] := ""
		jTaxOper["exTarifario"] := ""

		cFields := "CJ2.CJ2_CST CST, F2E.F2E_IDTRIB IDTRIB"

		lF2BTeste := .T.

		QryTribGen(jTaxOper, cFields, lF2BTeste)
/*/
Function QryTribGen(jTaxOper, cFields, lF2BTeste)

	Local cSelect    := ""
	Local cFrom      := ""
	Local cWhere     := ""
	Local cAliasQry  := ""
	Local cMes       := StrZero(Month(jTaxOper["dataOper"]),2)
	Local cAno       := StrZero(Year(jTaxOper["dataOper"]),4)
	Local cTodosPart := PadR("TODOS", TamSX3("F22_CLIFOR")[1])
	Local cTodosLoj  := Replicate("Z", TamSx3("F22_LOJA")[1])
	Local lCIUCEST   := fisExtCmp('12.1.2310', .T., 'CIU' , 'CIU_CEST' )
	Local lF2BStatus := fisExtCmp('12.1.2410', .T., 'F2B' , 'F2B_STATUS' )
	Local lExNcm 	 := fisExtCmp('12.1.2510', .T., 'CIU' , 'CIU_EX_NCM' )
	Local aInsert    := {}
	Local nX         := 0
	Local cMD5       := ""

	default cFields  := ""
	default lF2BTeste := .F.

	//---------------------------------------------------------------------------------
	//IMPORTANTE - OS NOMES DOS CAMPOS DEVEM SER IGUAIS DA QUERY DA FUNÇÃO FisLoadTG()
	//---------------------------------------------------------------------------------

	if !Empty(cFields)
		cSelect := cFields
	else
		//Seção dos campos do cadastro do tributo F2B, tributo e descrição
		cSelect += "F2B.F2B_REGRA TRIBUTO_SIGLA, F2B.F2B_DESC TRIBUTO_DESCRICAO, F2B.F2B_ID TRIBUTO_ID, F2B.F2B_PERFOP TRIBUTO_PERFOP,  F2B.F2B_RFIN REGRA_FIN, F2E.F2E_IDTRIB IDTRIB, F2E.F2E_DESC DESCTRIB, "

		//Verifica se o campo existe antes de adicionar na query
		If fisExtCmp('12.1.2310', .T.,'F2B','F2B_RND')
			cSelect += " F2B.F2B_RND TRIBUTO_RND, "
		EndIf

		//Verifica se o campo existe antes de adicionar na query
		If fisExtCmp('12.1.2410', .T.,'F2B','F2B_RDBASE')
			cSelect += " F2B.F2B_RDBASE RDBASE, "
		EndIf

	//Verifica se o campo existe antes de adicionar na query
	If fisExtCmp('12.1.2410', .T.,'F2B','F2B_STATUS')
		cSelect += " F2B.F2B_STATUS STATUS, "
	EndIf	

	//Verifica se o campo existe antes de adicionar na query
	If fisExtCmp('12.1.2510', .T.,'F2D','F2D_DEDSIM')
		cSelect += " 0 DED_SIMP, "
	EndIf

	//Seção dos campos da regra de base de cálculo
	cSelect += "F27.F27_CODIGO BASE_COD   , F27.F27_VALORI BASE_VALORI , F27.F27_DESCON BASE_DESCON, F27.F27_FRETE  BASE_FRETE, "
	cSelect += "F27.F27_SEGURO BASE_SEGURO, F27.F27_DESPE  BASE_DESPE  , F27.F27_ICMDES BASE_ICMDES, F27.F27_ICMRET BASE_ICMRET,  "
	cSelect += "F27.F27_REDBAS BASE_REDBAS, F27.F27_TPRED  BASE_TPRED  , F27.F27_UM     BASE_UM    , F27.F27_ID     BASE_ID, "

	//Seção dos campos da regra de base de cálculo auxiliar
	cSelect += "F27AUX.F27_CODIGO BS_A_COD   , F27AUX.F27_VALORI BS_A_VALORI , F27AUX.F27_DESCON BS_A_DESCON, F27AUX.F27_FRETE  BS_A_FRETE, "
	cSelect += "F27AUX.F27_SEGURO BS_A_SEGURO, F27AUX.F27_DESPE  BS_A_DESPE  , F27AUX.F27_ICMDES BS_A_ICMDES, F27AUX.F27_ICMRET BS_A_ICMRET,  "
	cSelect += "F27AUX.F27_REDBAS BS_A_REDBAS, F27AUX.F27_TPRED  BS_A_TPRED  , F27AUX.F27_UM     BS_A_UM    , F27AUX.F27_ID     BS_A_ID, "

		//Seção dos campos da regra de alíquota
		cSelect += "F28.F28_CODIGO ALQ_CODIGO , F28.F28_VALORI ALQ_VALORI, F28.F28_TPALIQ ALQ_TPALIQ, F28.F28_ALIQ ALQ_ALIQ, "
		cSelect += "F28.F28_URF    ALQ_URF    , F28.F28_UFRPER ALQ_UFRPER, F28.F28_ID     ALQ_ID, "

		If lCmpRedAliq
			cSelect += " F28.F28_REDALI ALQ_REDALI, "
		Endif

		IF fisExtTab('12.1.2310', .T., 'CIN')
			cSelect += " F2B.F2B_DEDPRO TABPRO, F2B.F2B_DEDDEP DEDDEP, F2B.F2B_RGGUIA RGUIA,  "
			cSelect += " F2B.F2B_TRBMAJ TRIBUTO_MAJ, "
			cSelect += " F2B.F2B_VLRMIN VLRMIN, F2B.F2B_VLRMAX VLRMAX, F2B.F2B_OPRMIN OPRLIM_MIN, F2B.F2B_OPRMAX OPRLIM_MAX, "

			If lFpACMAX
				cSelect += "F2B.F2B_ACMAX ACMAX, F2B.F2B_ACMIN ACMIN, "
			EndIf
		EndIF

		//Seção com campos da Unidade Referencial Fiscal
		cSelect += "F2A.F2A_VALOR URF_VALOR,"

		//Campos para que na seção de query eu tenha os campos base de cálculo, alíquota e valor
		cSelect += "0 BASE_CALCULO, 0 BASE_QTDE, 0 ALIQUOTA, 0 VALOR, 0 DED_DEP"

	//Adiciono os campos da fórmula na seção do select caso a tabela CIN exista.
	IF fisExtTab('12.1.2310', .T., 'CIN')
		
		cSelect += QryForNPI(lCmpNPIMemo, .F.)
		cSelect += ", CINBAS.CIN_ID BAS_FOR_ID ,  CINBAS.CIN_CODIGO BAS_FOR_COD "
		cSelect += ", CINBASAUX.CIN_ID BS_A_FOR_ID , CINBASAUX.CIN_CODIGO BS_A_FOR_COD "
		cSelect += ", CINALQ.CIN_ID ALQ_FOR_ID ,  CINALQ.CIN_CODIGO ALQ_FOR_COD "
		cSelect += ", CINVAL.CIN_ID VAL_FOR_ID ,  CINVAL.CIN_CODIGO VAL_FOR_COD "
		cSelect += ", CINISE.CIN_ID ISE_FOR_ID ,  CINISE.CIN_CODIGO ISE_FOR_COD "
		cSelect += ", CINOUT.CIN_ID OUT_FOR_ID ,  CINOUT.CIN_CODIGO OUT_FOR_COD "
		cSelect += ", MVA.CIU_MARGEM MVA, MVA.CIU_MVAAUX MVA_AUX "
		cSelect += ", PAUTA.CIU_VLPAUT PAUTA "
		cSelect += ", MAJ.CIU_MAJORA MAJ, MAJ.CIU_MJAUX IND_AUX_MAJ "

			If fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')
				cSelect += ", ALIQTRB.CIU_ALIQTR ALIQTRB "
			EndIf

		cSelect += ", ALQ_SERV.CIY_ALIQ ALQ_SERVICO"
		cSelect += ", ALQ_LEICOMP.CIT_ALIQ ALQ_SERV_LEICOMP"
		cSelect += ChkCINMemo(.F.)
	EndIF

		//Adiciona campos na seção de select da query com campos de escrituração
		IF fisExtTab('12.1.2310', .T., 'CJ2')
			cSelect += ", CJ2.CJ2_ID ESCR_ID,  CJ2.CJ2_INCIDE INCIDE,  CJ2.CJ2_STOTNF TOTNF ,  CJ2.CJ2_PERDIF PERCDIF, CJ2.CJ2_CST CST, CJ2.CJ2_CSTCAB CSTCAB "
			cSelect += ", CJ2.CJ2_IREDBS INC_RED "

			//Verifica se o campo existe antes de adicionar na query
			If lCmpCCT
				cSelect += " , CJ2.CJ2_CCT CCT "
			EndIf

			If lNrLivro
				cSelect += ", CJ2.CJ2_NLIVRO NLIVRO "
			EndIf

			If lIndOp
				cSelect += ", CJ2.CJ2_INDOP INDOP "
			EndIf

			If lTotNfDev
				cSelect += ", CJ2.CJ2_DSTONF TOTNF_DEV "
			Endif

		EndIF
	endif



	//From será executado na tabela F2B - Regras dos tributos x Operação
	cFrom   += " ? F2B "
	Aadd(aInsert, {'U', RetSQLName("F2B")})

	//Join com o cadastro de Tributo F2E
	cFrom += "JOIN ? F2E ON (F2E.F2E_FILIAL = ? AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F2E")})
	Aadd(aInsert, {'C', xFilial("F2E")})

	//Join com o perfil de origem e destino
	cFrom += "JOIN ? F21 ON (F21.F21_FILIAL = ? AND F21.F21_CODIGO = F2B.F2B_PEROD AND F21.F21_UFORI = ? AND F21.F21_UFDEST = ? AND F21.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F21")})
	Aadd(aInsert, {'C', xFilial("F21")})
	Aadd(aInsert, {'C', jTaxOper["ufOrigem"]})
	Aadd(aInsert, {'C', jTaxOper["ufDestino"]})

	//Join com o perfil de participante
	cFrom += "JOIN ? F22 ON (F22.F22_FILIAL = ? AND F22.F22_CODIGO = F2B.F2B_PERFPA AND F22.F22_TPPART = ? AND ((F22.F22_CLIFOR = ? AND F22.F22_LOJA = ?) OR (F22.F22_CLIFOR = ? AND F22.F22_LOJA = ?)) AND F22.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F22")})
	Aadd(aInsert, {'C', xFilial("F22")})
	Aadd(aInsert, {'C', jTaxOper["tipoParticipante"]})
	Aadd(aInsert, {'C', jTaxOper["codParticipante"]})
	Aadd(aInsert, {'C', jTaxOper["lojaParticipante"]})
	Aadd(aInsert, {'C', cTodosPart})
	Aadd(aInsert, {'C', cTodosLoj})

	//Join com o perfil de operação
	cFrom += "JOIN ? F23 ON (F23.F23_FILIAL = ? AND F23.F23_CODIGO = F2B.F2B_PERFOP AND F23.F23_CFOP = ? AND F23.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F23")})
	Aadd(aInsert, {'C', xFilial("F23")})
	Aadd(aInsert, {'C', jTaxOper["cfop"]})

	If !Empty(jTaxOper["tipoOper"])
		//Join com o perfil de operação considerando o tipo de operação
		cFrom += "JOIN ? F26 ON (F26.F26_FILIAL = ? AND F26.F26_CODIGO = F2B.F2B_PERFOP AND (F26.F26_TPOPER = ? OR F26.F26_TPOPER= 'TODOS') AND F26.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("F26")})
		Aadd(aInsert, {'C', xFilial("F26")})
		Aadd(aInsert, {'C', jTaxOper["tipoOper"]})
	EndIF

	If fisExtTab('12.1.2310', .T., 'CIN') .And. !Empty(jTaxOper["codISS"])
		//Join com o perfil de operação considerando o código de ISS
		cFrom += "JOIN ? CIO ON (CIO.CIO_FILIAL = ? AND CIO.CIO_CODIGO = F2B.F2B_PERFOP AND (CIO.CIO_CODISS = ? OR CIO.CIO_CODISS = 'TODOS') AND CIO.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIO")})
		Aadd(aInsert, {'C', xFilial("CIO")})
		Aadd(aInsert, {'C', jTaxOper["codISS"]})
	EndIF

	//Join com o perfil de produto
	cFrom += "JOIN ? F24 ON (F24.F24_FILIAL = ? AND F24.F24_CODIGO = F2B.F2B_PERFPR AND (F24.F24_CDPROD = ? OR F24.F24_CDPROD = 'TODOS' ) AND F24.D_E_L_E_T_ = ' ') "
	Aadd(aInsert,{ 'U', RetSQLName("F24")})
	Aadd(aInsert,{ 'C', xFilial("F24")})
	Aadd(aInsert,{ 'C', jTaxOper["codProduto"]})

	If !Empty(jTaxOper["origemProduto"])
		//Join com o perfil de origem de produto. Origem do produto somente será obrigatória se estiver informada.
		cFrom += "JOIN ? F25 ON (F25.F25_FILIAL = ? AND F25.F25_CODIGO = F2B.F2B_PERFPR AND F25.F25_ORIGEM = ? AND F25.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("F25")})
		Aadd(aInsert, {'C', xFilial("F25")})
		Aadd(aInsert, {'C', jTaxOper["origemProduto"]})
	EndIF

	//Join com a regra de base de cálculo. Traz sempre a regra vigênte considerando o campo F27_ALTERA = 2
	cFrom += "JOIN ? F27 ON (F27.F27_FILIAL = ? AND F27.F27_CODIGO = F2B.F2B_RBASE AND F27.F27_ALTERA = '2' AND F27.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F27")})
	Aadd(aInsert, {'C', xFilial("F27")})

	//Join com a regra de base de cálculo auxiliar. Traz sempre a regra vigênte considerando o campo F27_ALTERA = 2
	cFrom += "LEFT JOIN ? F27AUX ON (F27AUX.F27_FILIAL = ? AND F27AUX.F27_CODIGO = F2B.F2B_RBASES AND F27AUX.F27_ALTERA = ? AND F27AUX.D_E_L_E_T_ = ?) "
	Aadd(aInsert, {'U', RetSQLName("F27")})
	Aadd(aInsert, {'C', xFilial("F27")})
	Aadd(aInsert, {'C', "2"})
	Aadd(aInsert, {'C', " "})

	//Join com a regra de alíquota. Traz sempre a regra vigênte considerando o campo F28_ALTERA = 2
	cFrom += "JOIN ? F28 ON (F28.F28_FILIAL = ? AND F28.F28_CODIGO = F2B.F2B_RALIQ AND F28.F28_ALTERA = '2' AND F28.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F28")})
	Aadd(aInsert, {'C', xFilial("F28")})

	//LEFT Join com a tabela com URF. Esta tabela é LEFT pelo motivo de nem todas as alíquotas semre por URF.
	cFrom += "LEFT JOIN ? F2A ON (F2A.F2A_FILIAL = ? AND F2A.F2A_URF = F28.F28_URF AND F2A.F2A_ANO = ? AND F2A.F2A_MES = ?  AND F2A.D_E_L_E_T_ = ' ') "
	Aadd(aInsert, {'U', RetSQLName("F2A")})
	Aadd(aInsert, {'C', xFilial("F2A")})
	Aadd(aInsert, {'C', cAno})
	Aadd(aInsert, {'C', cMes})

	//----------------------------------------------------------------------------------------------------------------------------------------
	//Se a tabela CIN de fórmulas existir, então farei left join para carregar as fórmulas das regras de base de cálculo, alíquota e tributo
	//----------------------------------------------------------------------------------------------------------------------------------------
	IF fisExtTab('12.1.2310', .T., 'CIN')
		//Fòrmula da base
		cFrom += "LEFT JOIN ? CINBAS ON (CINBAS.CIN_FILIAL = ? AND CINBAS.CIN_IREGRA = F2B.F2B_ID AND CINBAS.CIN_TREGRA = '6 ' AND CINBAS.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIN")})
		Aadd(aInsert, {'C', xFilial("CIN")})

		//Fórmula da base auxiliar
		cFrom += "LEFT JOIN ? CINBASAUX ON (CINBASAUX.CIN_FILIAL = ? AND CINBASAUX.CIN_TREGRA = ? AND CINBASAUX.CIN_REGRA = F2B.F2B_RBASES AND CINBASAUX.CIN_ALTERA = ? AND CINBASAUX.D_E_L_E_T_ = ?) "
		Aadd(aInsert, {'U', RetSQLName("CIN")})
		Aadd(aInsert, {'C', xFilial("CIN")})
		Aadd(aInsert, {'C', "1"})
		Aadd(aInsert, {'C', "0"})
		Aadd(aInsert, {'C', " "})

		//Fórmula da alíquota
		cFrom += "LEFT JOIN ? CINALQ ON (CINALQ.CIN_FILIAL = ? AND CINALQ.CIN_IREGRA = F2B.F2B_ID AND CINALQ.CIN_TREGRA = '7 ' AND CINALQ.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIN")})
		Aadd(aInsert, {'C', xFilial("CIN")})

		//Fórmula do valor.
		cFrom += "LEFT JOIN ? CINVAL ON (CINVAL.CIN_FILIAL = ? AND CINVAL.CIN_IREGRA = F2B.F2B_ID AND CINVAL.CIN_TREGRA = '8 ' AND CINVAL.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIN")})
		Aadd(aInsert, {'C', xFilial("CIN")})

		//Fórmula de Isento
		cFrom += "LEFT JOIN ? CINISE ON (CINISE.CIN_FILIAL = ? AND CINISE.CIN_IREGRA = F2B.F2B_ID AND CINISE.CIN_TREGRA = '11' AND CINISE.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIN")})
		Aadd(aInsert, {'C', xFilial("CIN")})

		//Fórmula de Outros
		cFrom += "LEFT JOIN ? CINOUT ON (CINOUT.CIN_FILIAL = ? AND CINOUT.CIN_IREGRA = F2B.F2B_ID AND CINOUT.CIN_TREGRA = '12' AND CINOUT.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIN")})
		Aadd(aInsert, {'C', xFilial("CIN")})

		//JOIN CIUxCITxCIS
		//Join com MVA
		cFrom += "LEFT JOIN ? MVA ON (MVA.CIU_FILIAL = ? AND MVA.CIU_TIPO = ? AND MVA.CIU_NCM = ? AND MVA.CIU_TRIB = F2E.F2E_TRIB AND (MVA.CIU_UFORI = ? OR MVA.CIU_UFORI = ?) AND (MVA.CIU_UFDEST = ? OR  MVA.CIU_UFDEST = ?) AND ? >= MVA.CIU_VIGINI AND ( ? <= MVA.CIU_VIGFIM OR MVA.CIU_VIGFIM = ? ) AND  (MVA.CIU_ORIGEM = ? OR MVA.CIU_ORIGEM = ?) "
		Aadd(aInsert, {'U', RetSQLName("CIU")})
		Aadd(aInsert, {'C', xFilial("CIU")})
		Aadd(aInsert, {'C', '1'})
		Aadd(aInsert, {'C', jTaxOper["ncm"]})
		Aadd(aInsert, {'C', jTaxOper["ufOrigem"]})
		Aadd(aInsert, {'C', '**'})
		Aadd(aInsert, {'C', jTaxOper["ufDestino"]})
		Aadd(aInsert, {'C', '**'})
		Aadd(aInsert, {'D', jTaxOper["dataOper"]})
		Aadd(aInsert, {'D', jTaxOper["dataOper"]})
		Aadd(aInsert, {'D', CtoD('  /  /    ')})
		Aadd(aInsert, {'C', jTaxOper["origemProduto"]})
		Aadd(aInsert, {'C', '*'})

		If lCIUCEST
			cFrom += "AND (MVA.CIU_CEST = ? OR MVA.CIU_CEST = ?) "
			Aadd(aInsert, {'C', jTaxOper["codCest"]})
			Aadd(aInsert, {'C', ' '})
		EndIf

		if lExNcm
			cFrom += qryExNcm("MVA.", @aInsert, jTaxOper["exTarifario"])
		endIf

		cFrom += "AND MVA.D_E_L_E_T_ = ?) "
		Aadd(aInsert, {'C', ' '})

		//Join com Pauta
		cFrom += "LEFT JOIN ? PAUTA ON (PAUTA.CIU_FILIAL = ? AND PAUTA.CIU_TIPO = ? AND PAUTA.CIU_NCM = ? AND PAUTA.CIU_TRIB = F2E.F2E_TRIB AND (PAUTA.CIU_UFORI = ? OR PAUTA.CIU_UFORI = ?) AND (PAUTA.CIU_UFDEST = ? OR  PAUTA.CIU_UFDEST = ?) AND ? >= PAUTA.CIU_VIGINI AND ( ? <= PAUTA.CIU_VIGFIM OR PAUTA.CIU_VIGFIM = ?) AND (PAUTA.CIU_UM = ? OR  PAUTA.CIU_UM = ? OR PAUTA.CIU_UM = ?) AND PAUTA.CIU_ORIGEM IN (?, ?, ?)  "
		Aadd(aInsert, { 'U', RetSQLName("CIU")})
		Aadd(aInsert, { 'C', xFilial("CIU")})
		Aadd(aInsert, {'C', '2'})
		Aadd(aInsert, { 'C', jTaxOper["ncm"]})
		Aadd(aInsert, { 'C', jTaxOper["ufOrigem"]})
		Aadd(aInsert, {'C', '**'})
		Aadd(aInsert, { 'C', jTaxOper["ufDestino"]})
		Aadd(aInsert, {'C', '**'})
		Aadd(aInsert, { 'D', jTaxOper["dataOper"]})
		Aadd(aInsert, { 'D', jTaxOper["dataOper"]})
		Aadd(aInsert, {'D', CtoD('  /  /    ')})
		Aadd(aInsert, { 'C', jTaxOper["um1"]})
		Aadd(aInsert, { 'C', jTaxOper["um2"]})
		Aadd(aInsert, { 'C', '**'})
		Aadd(aInsert, {'C', jTaxOper["origemProduto"]})
		Aadd(aInsert, {'C', '*'})
		Aadd(aInsert, {'C', ' '})

		If lCIUCEST
			cFrom += "AND (PAUTA.CIU_CEST = ? OR PAUTA.CIU_CEST = ?) "
			Aadd(aInsert, {'C', jTaxOper["codCest"]})
			Aadd(aInsert, {'C', ' '})
		EndIf

		if lExNcm
			cFrom += qryExNcm("PAUTA.", @aInsert, jTaxOper["exTarifario"])
		endIf

		cFrom += "AND PAUTA.D_E_L_E_T_ = ?) "
		Aadd(aInsert,{ 'C', ' '})


		//Join com Majoracao
		cFrom += "LEFT JOIN ? MAJ ON (MAJ.CIU_FILIAL = ? AND MAJ.CIU_TIPO = ? AND MAJ.CIU_NCM = ? AND MAJ.CIU_TRIB = F2E.F2E_TRIB AND (MAJ.CIU_UFORI = ? OR MAJ.CIU_UFORI = ?) AND (MAJ.CIU_UFDEST = ? OR  MAJ.CIU_UFDEST = ?) AND ? >= MAJ.CIU_VIGINI AND ( ? <= MAJ.CIU_VIGFIM OR MAJ.CIU_VIGFIM = ? ) AND MAJ.CIU_ORIGEM IN (?, ?, ?) "
		Aadd(aInsert, {'U', RetSQLName("CIU")})
		Aadd(aInsert, {'C', xFilial("CIU")})
		Aadd(aInsert, {'C', '3'})
		Aadd(aInsert, {'C', jTaxOper["ncm"]})
		Aadd(aInsert, {'C', jTaxOper["ufOrigem"]})
		Aadd(aInsert, {'C', '**'})
		Aadd(aInsert, {'C', jTaxOper["ufDestino"]})
		Aadd(aInsert, {'C', '**'})
		Aadd(aInsert, {'D', jTaxOper["dataOper"]})
		Aadd(aInsert, {'D', jTaxOper["dataOper"]})
		Aadd(aInsert, {'D', CtoD('  /  /    ')})
		Aadd(aInsert, {'C', jTaxOper["origemProduto"]})
		Aadd(aInsert, {'C', '*'})
		Aadd(aInsert, {'C', ' '})

		If lCIUCEST
			cFrom +=  "AND (MAJ.CIU_CEST = ? OR MAJ.CIU_CEST = ?) "
			Aadd(aInsert, {'C', jTaxOper["codCest"]})
			Aadd(aInsert, {'C', ' '})
		EndIf

		if lExNcm
			cFrom += qryExNcm("MAJ.", @aInsert, jTaxOper["exTarifario"])
		endIf

		cFrom +=  "AND MAJ.D_E_L_E_T_ = ?) "
		aAdd(aInsert, {'C', ' '})

		//Join com Aliquota por Tributo
		If fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')

			cFrom += "LEFT JOIN ? ALIQTRB ON (ALIQTRB.CIU_FILIAL = ? AND ALIQTRB.CIU_TIPO = ? AND ALIQTRB.CIU_NCM = ? AND ALIQTRB.CIU_TRIB = F2E.F2E_TRIB AND (ALIQTRB.CIU_UFORI = ? OR ALIQTRB.CIU_UFORI = ?) AND (ALIQTRB.CIU_UFDEST = ? OR  ALIQTRB.CIU_UFDEST = ?) AND ? >= ALIQTRB.CIU_VIGINI AND ( ? <= ALIQTRB.CIU_VIGFIM OR ALIQTRB.CIU_VIGFIM = ? ) AND ALIQTRB.CIU_ORIGEM IN (?, ?, ?) "
			Aadd(aInsert, {'U', RetSQLName("CIU")})
			Aadd(aInsert, {'C', xFilial("CIU")})
			Aadd(aInsert, {'C', '4'})
			Aadd(aInsert, {'C', jTaxOper["ncm"]})
			Aadd(aInsert, {'C', jTaxOper["ufOrigem"]})
			Aadd(aInsert, {'C', '**'})
			Aadd(aInsert, {'C', jTaxOper["ufDestino"]})
			Aadd(aInsert, {'C', '**'})
			Aadd(aInsert, {'D', jTaxOper["dataOper"]})
			Aadd(aInsert, {'D', jTaxOper["dataOper"]})
			Aadd(aInsert, {'D', CtoD('  /  /    ')})
			Aadd(aInsert, {'C', jTaxOper["origemProduto"]})
			Aadd(aInsert, {'C', '*'})
			Aadd(aInsert, {'C', ' '})

			If lCIUCEST
				cFrom +=  "AND (ALIQTRB.CIU_CEST = ? OR ALIQTRB.CIU_CEST = ?) "
				Aadd(aInsert, {'C', jTaxOper["codCest"]})
				Aadd(aInsert, {'C', ' '})
			EndIf

			if lExNcm
				cFrom += qryExNcm("ALIQTRB.", @aInsert, jTaxOper["exTarifario"])
			endIf

			cFrom +=  "AND ALIQTRB.D_E_L_E_T_ = ?) "
			Aadd(aInsert, {'C', ' '})

		Endif

		//Join com alíquota do serviço
		cFrom += "LEFT JOIN ? ALQ_SERV ON (ALQ_SERV.CIY_FILIAL = ? AND ALQ_SERV.CIY_UF = ? AND ALQ_SERV.CIY_CODMUN = ? AND ALQ_SERV.CIY_TRIB = F2E.F2E_TRIB AND ALQ_SERV.CIY_CODISS = ? AND ALQ_SERV.D_E_L_E_T_ = ' ') "
		Aadd(aInsert,{ 'U', RetSQLName("CIY")})
		Aadd(aInsert,{ 'C', xFilial("CIY")})
		Aadd(aInsert,{ 'C', jTaxOper["ufServico"]})
		Aadd(aInsert,{ 'C', jTaxOper["municipioServico"]})
		Aadd(aInsert,{ 'C', jTaxOper["codISS"]})

		cFrom += "LEFT JOIN ? ALQ_LEICOMP ON (ALQ_LEICOMP.CIT_FILIAL = ? AND ALQ_LEICOMP.CIT_TRIB = F2E.F2E_TRIB AND ALQ_LEICOMP.CIT_TIPO = '2' AND ALQ_LEICOMP.CIT_CODISS = ? AND  ALQ_LEICOMP.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, {'U', RetSQLName("CIT")})
		Aadd(aInsert, {'C', xFilial("CIT")})
		Aadd(aInsert, {'C', jTaxOper["codISS"]})

		//Join com tabela de escrituração
		IF fisExtTab('12.1.2310', .T., 'CJ2')
			cFrom += "LEFT JOIN ? CJ2 ON CJ2.CJ2_FILIAL = ? AND CJ2.CJ2_CODIGO  = F2B.F2B_CODESC AND CJ2.CJ2_ALTERA = '2' AND CJ2.D_E_L_E_T_ = ' ' "
			Aadd(aInsert, {'U', RetSQLName("CJ2")})
			Aadd(aInsert, {'C', xFilial("CJ2")})
		Endif

	EndIf

	//Seção do Where, considerando a vigência do tributo.
	cWhere  += "F2B.F2B_FILIAL = ? AND "
	Aadd(aInsert, {'C', xFilial("F2B")})

	cWhere  += " ? >= F2B.F2B_VIGINI AND ( ? <= F2B.F2B_VIGFIM OR F2B.F2B_VIGFIM = ' ' ) AND "
	Aadd(aInsert, {'D', jTaxOper["dataOper"]})
	Aadd(aInsert, {'D', jTaxOper["dataOper"]})


	//Se a tabela CIN existe preciso trazer somente F2B atual
	IF fisExtTab('12.1.2310', .T., 'CIN')
		cWhere  += " F2B.F2B_ALTERA <> '1' AND "
	EndIF

	//Se existe o campo F2B_STATUS e não for executar regras de teste, então traz somente os tributos em produção.
	//Quando for solicitado para executar regras de teste, então traz todos os tributos, não aplicando o filtro de status.
	If lF2BStatus .and. !lF2BTeste
		cWhere  += " F2B.F2B_STATUS <> '1' AND "
	Endif

	cWhere  += "F2B.D_E_L_E_T_ = ' '"

	cQuery := " SELECT " + cSelect + " FROM " + cFrom + " WHERE " + cWhere
	cMD5 := MD5(cQuery)

	//Verifica se a query já foi preparada, se não foi prepara a query e adiciona na lista de querys preparadas.
	If Valtype(jPrepared) <> 'J'
		jPrepared := JsonObject():new()
	EndIf

	If Valtype(jPrepared[cMD5]) <> 'O'
		jPrepared[cMD5] := FwExecStatement():New(ChangeQuery(cQuery))
	EndIf

	//Adiciona filtro
	nLen := Len(aInsert)
	For nX := 1 to nLen
		If aInsert[nX][1] == 'C'
			jPrepared[cMD5]:SetString(nX, aInsert[nX][2])
		Elseif aInsert[nX][1] == 'U'
			jPrepared[cMD5]:SetUnsafe(nX, aInsert[nX][2])
		Elseif aInsert[nX][1] == 'D'
			jPrepared[cMD5]:SetDate(nX, aInsert[nX][2])
		EndIf
	Next nX

	cAliasQry := jPrepared[cMD5]:OpenAlias()

	aInsert := aSize(aInsert,0)

Return cAliasQry


//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCINMemo()
Realiza tratativa dos campos MEMO da CIN para cada tipo de banco de dados

@param lLoad, Logical, Indica se está sendo realizado o carregamento da NF-e ou o cálculo dos tributos
@return cSelect  - String com o select da query para campos memo tratado por banco.

@author Squad Fiscal
@since 22/05/2024
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ChkCINMemo(lLoad)
	Local cSelect := ""
	Local cBasAuxFor := ", ' ' BS_A_FORMULA"

	IF "ORACLE" $ cDB
		cSelect += ", UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINBAS.CIN_FORMUL, 2000, 1)) BAS_FORMULA"

		If ( !lLoad )
			cBasAuxFor := ", UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINBASAUX.CIN_FORMUL, 2000, 1)) BS_A_FORMULA"
		EndIf

		cSelect += cBasAuxFor
		cSelect += ", UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINALQ.CIN_FORMUL, 2000, 1)) ALQ_FORMULA"
		cSelect += ", UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINVAL.CIN_FORMUL, 2000, 1)) VAL_FORMULA"
	ELSEIF "POSTGRES" $ cDB
		cSelect += ", encode(CINBAS.CIN_FORMUL, 'escape') BAS_FORMULA"

		If ( !lLoad )
			cBasAuxFor := ", encode(CINBASAUX.CIN_FORMUL, 'escape') BS_A_FORMULA"
		EndIf

		cSelect += cBasAuxFor
		cSelect += ", encode(CINALQ.CIN_FORMUL, 'escape') ALQ_FORMULA"
		cSelect += ", encode(CINVAL.CIN_FORMUL, 'escape') VAL_FORMULA"
	ELSE
		cSelect += ", CAST(CINBAS.CIN_FORMUL AS VARCHAR(2000)) BAS_FORMULA"

		If ( !lLoad )
			cBasAuxFor := ", CAST(CINBASAUX.CIN_FORMUL AS VARCHAR(2000)) BS_A_FORMULA"
		EndIf

		cSelect += cBasAuxFor		
		cSelect += ", CAST(CINALQ.CIN_FORMUL AS VARCHAR(2000)) ALQ_FORMULA"
		cSelect += ", CAST(CINVAL.CIN_FORMUL AS VARCHAR(2000)) VAL_FORMULA"
	ENDIF

Return cSelect

/*/{Protheus.doc} QryForNPI

	Função que retorna os campos de formúla em NPI VARCHAR ou MEMO, aplicando a tratativa conforme o banco de dados utilizado.
	@type  Static Function
	@author Camila.Pires
	@since 17/12/2025
	@version 12.1.2510
	@param lCmpNPIMemo, Logical, Indica se os campos de fórmula devem ser retornados como MEMO (True) ou VARCHAR (False)
	@param lLoad, Logical, Indica se está sendo realizado o carregamento da NF-e ou o cálculo dos tributos
	@return cSelect, String, String com o select da query para campos de fórmula tratado por banco.	
/*/
Static Function QryForNPI(lCmpNPIMemo, lLoad)

	Local cSelect := ""

	If lCmpNPIMemo
		cSelect := QryForMemo(cDB, lLoad)
	Else
		cSelect := QryForChar(lLoad)
	Endif

Return cSelect

/*/{Protheus.doc} QryForChar

	Função que retorna os campos de formúla em NPI VARCHAR

	@type  Static Function
	@author Julia.Mota
	@since 17/12/2025
	@version 12.1.2510
	@param lLoad, Logical, Indica se está sendo realizado o carregamento da NF-e ou o cálculo dos tributos	
	@return cSelect, String, String com o select da query para campos de fórmula	
/*/
Static Function QryForChar(lLoad)

	Local cSelect := ""
	Local cBasAuxFor := ""

	cSelect := ", CINBAS.CIN_FNPI BAS_FOR " 

	cBasAuxFor := ", CINBASAUX.CIN_FNPI BS_A_FOR "
	If ( lLoad )
		cBasAuxFor := ", ' ' BS_A_FOR "
	EndIf

	cSelect += cBasAuxFor
	cSelect += ", CINALQ.CIN_FNPI ALQ_FOR "

	cSelect += ", CINVAL.CIN_FNPI VAL_FOR "
	cSelect += ", CINISE.CIN_FNPI ISE_FOR "
	cSelect += ", CINOUT.CIN_FNPI OUT_FOR "
	
Return cSelect

/*/{Protheus.doc} QryForMemo

	Função que retorna os campos de formúla em NPI MEMO, aplicando a tratativa conforme o banco de dados utilizado.

	@type  Static Function
	@author Julia.Mota
	@since 17/12/2025
	@version 12.1.2510
	@param cDB, String, Tipo do banco de dados utilizado
	@param lLoad, Logical, Indica se está sendo realizado o carregamento da NF-e ou o cálculo dos tributos
	@return cSelect, String, String com o select da query para campos de fórmula tratado por banco.	
/*/
Static Function QryForMemo(cDB, lLoad)

	Local cSelect := ""

	If "ORACLE" $ cDB
		// Oracle: Campos MEMO podem ser BLOB ou CLOB
		// UTL_RAW.CAST_TO_VARCHAR2() é NECESSÁRIO para conversão segura de BLOB
		// Converte BLOB ? RAW ? VARCHAR2 de forma apropriada
		cSelect += ", CASE WHEN LENGTH(CINBAS.CIN_FNPI) < 240 THEN CINBAS.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINBAS.CIN_FNPI) > 240 AND (CINBAS.CIN_FNPI_M IS NULL OR DBMS_LOB.GETLENGTH(CINBAS.CIN_FNPI_M) = 0) THEN CINBAS.CIN_FNPI"
		cSelect += " ELSE UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINBAS.CIN_FNPI_M, 2000, 1)) END BAS_FOR"

		if (lLoad)
			cSelect += ", ' ' BS_A_FOR "
		else
			cSelect += ", CASE WHEN LENGTH(CINBASAUX.CIN_FNPI) < 240 THEN CINBASAUX.CIN_FNPI"
			cSelect += " WHEN LENGTH(CINBASAUX.CIN_FNPI) > 240 AND (CINBASAUX.CIN_FNPI_M IS NULL OR DBMS_LOB.GETLENGTH(CINBASAUX.CIN_FNPI_M) = 0) THEN CINBASAUX.CIN_FNPI"
			cSelect += " ELSE UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINBASAUX.CIN_FNPI_M, 2000, 1)) END BS_A_FOR"
		endif

		cSelect += ", CASE WHEN LENGTH(CINALQ.CIN_FNPI) < 240 THEN CINALQ.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINALQ.CIN_FNPI) > 240 AND (CINALQ.CIN_FNPI_M IS NULL OR DBMS_LOB.GETLENGTH(CINALQ.CIN_FNPI_M) = 0) THEN CINALQ.CIN_FNPI"
		cSelect += " ELSE UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINALQ.CIN_FNPI_M, 2000, 1)) END ALQ_FOR"

		cSelect += ", CASE WHEN LENGTH(CINVAL.CIN_FNPI) < 240 THEN CINVAL.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINVAL.CIN_FNPI) > 240 AND (CINVAL.CIN_FNPI_M IS NULL OR DBMS_LOB.GETLENGTH(CINVAL.CIN_FNPI_M) = 0) THEN CINVAL.CIN_FNPI"
		cSelect += " ELSE UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINVAL.CIN_FNPI_M, 2000, 1)) END VAL_FOR"

		cSelect += ", CASE WHEN LENGTH(CINISE.CIN_FNPI) < 240 THEN CINISE.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINISE.CIN_FNPI) > 240 AND (CINISE.CIN_FNPI_M IS NULL OR DBMS_LOB.GETLENGTH(CINISE.CIN_FNPI_M) = 0) THEN CINISE.CIN_FNPI"
		cSelect += " ELSE UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINISE.CIN_FNPI_M, 2000, 1)) END ISE_FOR"

		cSelect += ", CASE WHEN LENGTH(CINOUT.CIN_FNPI) < 240 THEN CINOUT.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINOUT.CIN_FNPI) > 240 AND (CINOUT.CIN_FNPI_M IS NULL OR DBMS_LOB.GETLENGTH(CINOUT.CIN_FNPI_M) = 0) THEN CINOUT.CIN_FNPI"
		cSelect += " ELSE UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(CINOUT.CIN_FNPI_M, 2000, 1)) END OUT_FOR"

	ElseIF "POSTGRES" $ cDB
		// PostgreSQL 15+: Campos MEMO são BYTEA no Protheus
		// encode() converte BYTEA para TEXT com escape de caracteres especiais
		cSelect += ", CASE WHEN LENGTH(CINBAS.CIN_FNPI) < 240 THEN CINBAS.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINBAS.CIN_FNPI) > 240 AND (CINBAS.CIN_FNPI_M IS NULL OR OCTET_LENGTH(CINBAS.CIN_FNPI_M) = 0) THEN CINBAS.CIN_FNPI"
		cSelect += " ELSE encode(CINBAS.CIN_FNPI_M, 'escape') END BAS_FOR"

		If (lLoad)
			cSelect += ", ' ' BS_A_FOR "
		else
			cSelect += ", CASE WHEN LENGTH(CINBASAUX.CIN_FNPI) < 240 THEN CINBASAUX.CIN_FNPI"
			cSelect += " WHEN LENGTH(CINBASAUX.CIN_FNPI) > 240 AND (CINBASAUX.CIN_FNPI_M IS NULL OR OCTET_LENGTH(CINBASAUX.CIN_FNPI_M) = 0) THEN CINBASAUX.CIN_FNPI"
			cSelect += " ELSE encode(CINBASAUX.CIN_FNPI_M, 'escape') END BS_A_FOR"
		endif

		cSelect += ", CASE WHEN LENGTH(CINALQ.CIN_FNPI) < 240 THEN CINALQ.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINALQ.CIN_FNPI) > 240 AND (CINALQ.CIN_FNPI_M IS NULL OR OCTET_LENGTH(CINALQ.CIN_FNPI_M) = 0) THEN CINALQ.CIN_FNPI"
		cSelect += " ELSE encode(CINALQ.CIN_FNPI_M, 'escape') END ALQ_FOR"

		cSelect += ", CASE WHEN LENGTH(CINVAL.CIN_FNPI) < 240 THEN CINVAL.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINVAL.CIN_FNPI) > 240 AND (CINVAL.CIN_FNPI_M IS NULL OR OCTET_LENGTH(CINVAL.CIN_FNPI_M) = 0) THEN CINVAL.CIN_FNPI"
		cSelect += " ELSE encode(CINVAL.CIN_FNPI_M, 'escape') END VAL_FOR"

		cSelect += ", CASE WHEN LENGTH(CINISE.CIN_FNPI) < 240 THEN CINISE.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINISE.CIN_FNPI) > 240 AND (CINISE.CIN_FNPI_M IS NULL OR OCTET_LENGTH(CINISE.CIN_FNPI_M) = 0) THEN CINISE.CIN_FNPI"
		cSelect += " ELSE encode(CINISE.CIN_FNPI_M, 'escape') END ISE_FOR"

		cSelect += ", CASE WHEN LENGTH(CINOUT.CIN_FNPI) < 240 THEN CINOUT.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINOUT.CIN_FNPI) > 240 AND (CINOUT.CIN_FNPI_M IS NULL OR OCTET_LENGTH(CINOUT.CIN_FNPI_M) = 0) THEN CINOUT.CIN_FNPI"
		cSelect += " ELSE encode(CINOUT.CIN_FNPI_M, 'escape') END OUT_FOR"
	
	ElseIF "SQLITE" $ cDB
		// SQLite: Campos MEMO são tratados como TEXT nativamente
		// SQLite usa LENGTH() ao invés de LEN() e não tem DATALENGTH()
		// CAST simples para TEXT funciona adequadamente
		cSelect += ", CASE WHEN LENGTH(CINBAS.CIN_FNPI) < 240 THEN CINBAS.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINBAS.CIN_FNPI) > 240 AND (CINBAS.CIN_FNPI_M IS NULL OR LENGTH(CINBAS.CIN_FNPI_M) = 0) THEN CINBAS.CIN_FNPI"
		cSelect += " ELSE CAST(CINBAS.CIN_FNPI_M AS TEXT) END BAS_FOR"

		If (lLoad)
			cSelect += ", ' ' BS_A_FOR "
		else
			cSelect += ", CASE WHEN LENGTH(CINBASAUX.CIN_FNPI) < 240 THEN CINBASAUX.CIN_FNPI"
			cSelect += " WHEN LENGTH(CINBASAUX.CIN_FNPI) > 240 AND (CINBASAUX.CIN_FNPI_M IS NULL OR LENGTH(CINBASAUX.CIN_FNPI_M) = 0) THEN CINBASAUX.CIN_FNPI"
			cSelect += " ELSE CAST(CINBASAUX.CIN_FNPI_M AS TEXT) END BS_A_FOR"
		Endif

		cSelect += ", CASE WHEN LENGTH(CINALQ.CIN_FNPI) < 240 THEN CINALQ.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINALQ.CIN_FNPI) > 240 AND (CINALQ.CIN_FNPI_M IS NULL OR LENGTH(CINALQ.CIN_FNPI_M) = 0) THEN CINALQ.CIN_FNPI"
		cSelect += " ELSE CAST(CINALQ.CIN_FNPI_M AS TEXT) END ALQ_FOR"

		cSelect += ", CASE WHEN LENGTH(CINVAL.CIN_FNPI) < 240 THEN CINVAL.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINVAL.CIN_FNPI) > 240 AND (CINVAL.CIN_FNPI_M IS NULL OR LENGTH(CINVAL.CIN_FNPI_M) = 0) THEN CINVAL.CIN_FNPI"
		cSelect += " ELSE CAST(CINVAL.CIN_FNPI_M AS TEXT) END VAL_FOR"

		cSelect += ", CASE WHEN LENGTH(CINISE.CIN_FNPI) < 240 THEN CINISE.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINISE.CIN_FNPI) > 240 AND (CINISE.CIN_FNPI_M IS NULL OR LENGTH(CINISE.CIN_FNPI_M) = 0) THEN CINISE.CIN_FNPI"
		cSelect += " ELSE CAST(CINISE.CIN_FNPI_M AS TEXT) END ISE_FOR"

		cSelect += ", CASE WHEN LENGTH(CINOUT.CIN_FNPI) < 240 THEN CINOUT.CIN_FNPI"
		cSelect += " WHEN LENGTH(CINOUT.CIN_FNPI) > 240 AND (CINOUT.CIN_FNPI_M IS NULL OR LENGTH(CINOUT.CIN_FNPI_M) = 0) THEN CINOUT.CIN_FNPI"
		cSelect += " ELSE CAST(CINOUT.CIN_FNPI_M AS TEXT) END OUT_FOR"
	
	Else
		// SQL Server 2014+: Valida tamanho antes de decidir qual campo usar
		// CAST direto VARCHAR(MAX) -> VARCHAR sem necessidade de VARBINARY intermediário
		cSelect += ", CASE WHEN LEN(CINBAS.CIN_FNPI) < 240 THEN CINBAS.CIN_FNPI"
		cSelect += " WHEN LEN(CINBAS.CIN_FNPI) > 240 AND (CINBAS.CIN_FNPI_M IS NULL OR DATALENGTH(CINBAS.CIN_FNPI_M) = 0) THEN CINBAS.CIN_FNPI"
		cSelect += " ELSE CAST(CINBAS.CIN_FNPI_M AS VARCHAR(2000)) END BAS_FOR"

		If (lLoad)
			cSelect += ", ' ' BS_A_FOR "
		else
			cSelect += ", CASE WHEN LEN(CINBASAUX.CIN_FNPI) < 240 THEN CINBASAUX.CIN_FNPI"
			cSelect += " WHEN LEN(CINBASAUX.CIN_FNPI) > 240 AND (CINBASAUX.CIN_FNPI_M IS NULL OR DATALENGTH(CINBASAUX.CIN_FNPI_M) = 0) THEN CINBASAUX.CIN_FNPI"
			cSelect += " ELSE CAST(CINBASAUX.CIN_FNPI_M AS VARCHAR(2000)) END BS_A_FOR"
		Endif

		cSelect += ", CASE WHEN LEN(CINALQ.CIN_FNPI) < 240 THEN CINALQ.CIN_FNPI"
		cSelect += " WHEN LEN(CINALQ.CIN_FNPI) > 240 AND (CINALQ.CIN_FNPI_M IS NULL OR DATALENGTH(CINALQ.CIN_FNPI_M) = 0) THEN CINALQ.CIN_FNPI"
		cSelect += " ELSE CAST(CINALQ.CIN_FNPI_M AS VARCHAR(2000)) END ALQ_FOR"

		cSelect += ", CASE WHEN LEN(CINVAL.CIN_FNPI) < 240 THEN CINVAL.CIN_FNPI"
		cSelect += " WHEN LEN(CINVAL.CIN_FNPI) > 240 AND (CINVAL.CIN_FNPI_M IS NULL OR DATALENGTH(CINVAL.CIN_FNPI_M) = 0) THEN CINVAL.CIN_FNPI"
		cSelect += " ELSE CAST(CINVAL.CIN_FNPI_M AS VARCHAR(2000)) END VAL_FOR"

		cSelect += ", CASE WHEN LEN(CINISE.CIN_FNPI) < 240 THEN CINISE.CIN_FNPI"
		cSelect += " WHEN LEN(CINISE.CIN_FNPI) > 240 AND (CINISE.CIN_FNPI_M IS NULL OR DATALENGTH(CINISE.CIN_FNPI_M) = 0) THEN CINISE.CIN_FNPI"
		cSelect += " ELSE CAST(CINISE.CIN_FNPI_M AS VARCHAR(2000)) END ISE_FOR"

		cSelect += ", CASE WHEN LEN(CINOUT.CIN_FNPI) < 240 THEN CINOUT.CIN_FNPI"
		cSelect += " WHEN LEN(CINOUT.CIN_FNPI) > 240 AND (CINOUT.CIN_FNPI_M IS NULL OR DATALENGTH(CINOUT.CIN_FNPI_M) = 0) THEN CINOUT.CIN_FNPI"
		cSelect += " ELSE CAST(CINOUT.CIN_FNPI_M AS VARCHAR(2000)) END OUT_FOR"

	EndIF

Return cSelect
//-------------------------------------------------------------------
/*/{Protheus.doc} AddTrbGen()
Função que tem como objetivo a criação da estrutur básicaa de referências do
tributo genérico, criando os arrays e populando com as informações
das regras de base de cálculo, alíquota e regra financeira dos
tributos genéricos.
Os valores de base de cálculo, alíquota e valor do tributo não serão
preenchidos nesta função, serão interpretados por outra função.

@param aNfItem    - Array com todas as informações do item
@param nItem      - Número do item da nota processado
@param cAliasQry  - Alias com todas as informações cadastrais das regras e tributos genéricos
@param nTGITRef   - Tamanho do array ItemRef dos tributos genéricos
@param aNFCab     - Array com informações do cabeçalho da nota fiscal
@param aPos       - Array com cache de fieldpos
@param aDic    	  - Array com cache das tabelas
@param jMapForm 	  - HashMap com o mapeamento dos operandos e formulas
@param jDepTrib   - Array com os valores dos tributos que impactam no cálculo do tributo genérico
@param aDepVlOrig - Array com os valores de base de cálculo que impactam no cálculo do tributo genérico
@param lLoad      - Indica se está sendo realizado o carregamento da NF-e ou o cálculo dos tributos
@param cIdDevol   - ID da devolução, quando for o caso
@param jVldTribs  - JsonObject com os tributos válidos para o cálculo

@return nTrbGen  - Posição do novo tributo genérico na referência IT_TRIBGEN

@author Erick Gonçalves Dias
@since 27/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AddTrbGen(aNfItem, nItem, cAliasQry, nTGITRef, aNFCab, aPos, aDic, jMapForm, jDepTrib, aDepVlOrig, lLoad, jVldTribs)

	local nTrbGen    := 0
	local nAlqTrb    := 0
	Local nAliqRed   := 0
	Local nLFAliqRed := 0
	Local nLFAliqOri := 0
	local cCCT		 := ""
	local cCST		 := ""
	local cCSTDev	 := ""
	local cNLivro	 := ""
	Local cIndOp	 := ""
	Local nDedSimp	 := 0
	Local cTotNfDev  := ""	
	Local cStoNf     := ""
	Local lTgVlZero	 := .F.

	Default aDepVlOrig	:= {}
	Default jDepTrib 	:= JsonObject():New()
	Default lLoad		:= .F.
	Default jVldTribs	:= JsonObject():New()

//Adiciona estrutura básica do tributo genérico na referência IT_TRIBGEN
	aadd(aNfItem[nItem][IT_TRIBGEN],Array(NMAX_IT_TG))

//Obtem a posição do tributo genérico adicionado
	nTrbGen := Len(aNfItem[nItem][IT_TRIBGEN])

	if fisExtTab('12.1.2310', .T., 'CIN')
		dbSelectArea("CIN")
		dbSetOrder(1) //F2D_FILIAL+F2D_IDREL
	EndIF

	//-------------------------------------------
	//Preenche as referências do tributo genérico
	//-------------------------------------------
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_REGRA]					:= (cAliasQry)->TRIBUTO_ID
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA]					:= (cAliasQry)->TRIBUTO_SIGLA
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DESCRICAO]				:= (cAliasQry)->TRIBUTO_DESCRICAO
	if fisExtCmp('12.1.2410', .T.,'F2B','F2B_STATUS')
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_STATUS]				:= (cAliasQry)->STATUS
	endif
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]					:= (cAliasQry)->ALIQUOTA
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]					:= (cAliasQry)->VALOR
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS]				:= Array(NMAXTGBAS)
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ]				:= Array(NMAXTGALQ)
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_FIN]				:= (cAliasQry)->REGRA_FIN
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]						:= Iif((cAliasQry)->BASE_QTDE > 0,(cAliasQry)->BASE_QTDE, (cAliasQry)->BASE_CALCULO)

	// Atribui o valor inicial do campo TRIBUTO_RND
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_RND] 						:= (cAliasQry)->TRIBUTO_RND // 1=Arredonda;2=Trunca;3=Arredonda ABNT
	
	If Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_RND])
    	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_RND] 					:= '1' // Valor padrão para arredondar, caso o campo esteja vazio
	EndIf

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC]					:= {Array(nTGITRef), Array(nTGITRef)}
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB]					:= (cAliasQry)->IDTRIB
	If ValType(aNfItem[nItem][IT_TG_IDTRIB_IDX]) == "J" .And. !Empty(AllTrim((cAliasQry)->IDTRIB))
		If !aNfItem[nItem][IT_TG_IDTRIB_IDX]:HasProperty(AllTrim((cAliasQry)->IDTRIB))
			aNfItem[nItem][IT_TG_IDTRIB_IDX][AllTrim((cAliasQry)->IDTRIB)] := nTrbGen
		EndIf
	EndIf
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D]					:= FWUUIDV4(.T.) //Inicializa o ID da F2D
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]					:= 0
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ACAO_MAX]					:= '1' //Ação máxima do tributo
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ACAO_MIN]					:= '2' //Ação mínima do tributo
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DELETED_TRIB] 			:= .F. //Indica se o tributo foi excluído
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO]					:= .F. //Utilizar valor zero na base ou alíquota
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ULT_AQUI]					:= .F. //Operador Lógico que Define se usou Operando de Ultima Aquisição
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ESTR_ULT_AQUI]			:= .F. //Operador Lógico que Define se usou Operando de Ultima Aquisição Estrutura de Produto
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LOAD]                     := lLoad //Indica se está realizando load dos valores já gravados
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DESC_IDTRIB]				:= (cAliasQry)->DESCTRIB //Descrição do tributo "legado" (F2E)
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FORMULA_VAL]             	:= '' //Composição da Formula convertida CIN_FORMUL para o valor
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPINTEG]             	    := .F. //Indica se a fórmula do valor possui operando de integração

	If (cAliasQry)->(FieldPos("VAL_FORMULA")) > 0
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FORMULA_VAL]             	:= (cAliasQry)->VAL_FORMULA //Composição da Formula convertida CIN_FORMUL para o valor
	Endif

//Cria nível das referências com regras de escrituração - Tabela CJ2
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR]			:= Array(NMAXRE)
//Cria nível das referêcias do livro - tabela CJ3
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF]					:= Array(NMAXTGLF)
//Cria nível das referências do perfil de operação
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PERFOP]				:= Array(NMAXOP)

//Preenche as referências do perfil de operação
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PERFOP][OP_COD]					:= (cAliasQry)->TRIBUTO_PERFOP
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PERFOP][OP_DADO_ADICIONAL]		:= Array(NMAXPOADDDATA)

//Inicializa as referencias de regras de escrituração
	ProcEscrTG(aNfItem, nItem, nTrbGen, "", 0, ;
		0, 0, 0, 0, 0, ;
		0, 0, 0, 0, 0, ;
		0, 0, "", 0 , 0, 0, 0, "" , "", "")

//Preenche as referências do livro do TG
	IF fisExtTab('12.1.2310', .T., 'CJ2')

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_GUIA]   		:= (cAliasQry)->RGUIA //Código da Regra de Guia

		If lCmpCCT
			cCCT := (cAliasQry)->CCT
		Endif

		If lNrLivro
			cNLivro := (cAliasQry)->NLIVRO
		EndIf

		If lIndOp
			cIndOp := (cAliasQry)->INDOP
		EndIf

		cCST := (cAliasQry)->CST
		cStoNf := (cAliasQry)->TOTNF

		//Verifica se está realizar load dos valores já gravados antes de preencher os valores
		If lLoad

			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D]	:= (cAliasQry)->IDF2D  //ID da F2D

			cCSTDev := (cAliasQry)->LCST

			If lTotNfDev
				cTotNfDev := (cAliasQry)->TOTNF_DEV
			EndIf

			If lIncideDev
				aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE_DEV]    	:= (cAliasQry)->INCIDE_DEV
				aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED_DEV] 	:= (cAliasQry)->INCIDE_PARC_RED_DEV
			Endif

			// Se for devolução e o campo CJ2_DSTONF for preenchido, o valor do mesmo deve ser considerado no lugar do CJ2_STONF ...
			If lTotNfDev .and. !Empty(cTotNfDev) .and. aNfCab[NF_TIPONF] $ "D|B" .and. (cTotNfDev != (cAliasQry)->TOTNF)
				cStoNf := cTotNfDev
			Endif

			if !empty(cCCT) .and. !empty((cAliasQry)->RCST) .and. aNfCab[NF_TIPONF] $ "D|B" //Se tiver CCT e CJ3_CST, significa que é devolução vinda do cClassTrib
				cCST := (cAliasQry)->RCST
				cCSTDev := (cAliasQry)->RCST
			endIf

			If fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')
				nAlqTrb := (cAliasQry)->ALIQTRB
			Endif

			If lCmpRedAliq
				nLFAliqRed := (cAliasQry)->LALQ_REDALI
				nLFAliqOri := (cAliasQry)->LALQ_ORI
			Endif

			//Ao processar visualização/carregar os valores já gravados, as referêcias do livro estarão preenchidas com valores da query
			ProcEscrTG(aNfItem            , nItem                 , nTrbGen               , cCSTDev      		   , (cAliasQry)->LVALTRIB  , ;
				(cAliasQry)->LISENTO  , (cAliasQry)->LOUTROS  , (cAliasQry)->LNTRIB   , (cAliasQry)->LDIFERIDO , (cAliasQry)->LMAJORADO , ;
				(cAliasQry)->LPERCMAJ , (cAliasQry)->LPERCDIF , (cAliasQry)->LPERCRED , (cAliasQry)->LPAUTA    , (cAliasQry)->LMVA      , ;
				(cAliasQry)->LAUXMVA  , (cAliasQry)->LAUXMAJ  , (cAliasQry)->LCSTCAB  , (cAliasQry)->LBASORI   , nAlqTrb, ;
				nLFAliqRed, nLFAliqOri, cCCT , cNLivro, cIndOp )
		EndIf
	EndIF

//Adiciono a fórmula do valor
	IF fisExtTab('12.1.2310', .T., 'CIN')

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MVA] 		:= (cAliasQry)->MVA			//MVA
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MVA] 	:= (cAliasQry)->MVA_AUX		//Indice auxiliar do MVA
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PAUTA] 	:= (cAliasQry)->PAUTA		//Pauta
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MAJ] 		:= (cAliasQry)->MAJ			//Percentual de majoração
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MAJ] 	:= (cAliasQry)->IND_AUX_MAJ	//Indice auxiliar do percentual de majorção
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ] 	:= (cAliasQry)->TRIBUTO_MAJ	//Código do tributo que majora tributo atual

		If fisExtCmp('12.1.2310', .T.,'CIU','CIU_ALIQTR')
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQTR] 	:= (cAliasQry)->ALIQTRB		//Aliquota do tributo por NCM
		Endif

		If fisExtCmp('12.1.2410', .T.,'F2B','F2B_RDBASE')
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REDBASEAUX] 	:= (cAliasQry)->RDBASE		//Aliquota do tributo por NCM
		Endif

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]	:= (cAliasQry)->DED_DEP
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALQ_SERV]	:= (cAliasQry)->ALQ_SERVICO //Aliquota do municipio de execução
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALQ_SERV_LEI_COMPL]:= (cAliasQry)->ALQ_SERV_LEICOMP //Alíquota de serviço da lei complemetar

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MAX]	:= (cAliasQry)->OPRLIM_MAX
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MIN]	:= (cAliasQry)->OPRLIM_MIN
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_MAX]	:= (cAliasQry)->VLRMAX
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_MIN]	:= (cAliasQry)->VLRMIN

		If lFpACMAX
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ACAO_MAX]	:= (cAliasQry)->ACMAX //Ação para valor máximo
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ACAO_MIN]	:= (cAliasQry)->ACMIN //Ação para valor mínimo
		EndIf

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI] 		:= (cAliasQry)->VAL_FOR	 //Fórmula NPI do valor
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_ISE_NPI] 	:= (cAliasQry)->ISE_FOR	 //Fórmula NPI de Isento
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_OUT_NPI] 	:= (cAliasQry)->OUT_FOR	 //Fórmula NPI de Outros

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_NPI] 		:= (cAliasQry)->VAL_FOR_ID		//ID da fórmula da tabela CIN
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR] 		:= (cAliasQry)->VAL_FOR_COD		//Código da fórmula do valor do tributo
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TAB_PROG]	    := (cAliasQry)->TABPRO  //Código da regra de tabela progressiva
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_DED_DEP]:= (cAliasQry)->DEDDEP  //Código da regra dedução dependentes

		If fisExtCmp('12.1.2510', .T.,'F2D','F2D_DEDSIM')
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_SIM_VAL]  := (cAliasQry)->DED_SIMP // Valor de dedução simplificada
		EndIf

		//-------------------------------------------------------
		//Preenche as referêcias com as regras da base de cálculo
		//-------------------------------------------------------
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID]		:= (cAliasQry)->BASE_ID
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD]	:= (cAliasQry)->BASE_COD
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI]	:= (cAliasQry)->BASE_VALORI
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON]	:= (cAliasQry)->BASE_DESCON
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE]	:= (cAliasQry)->BASE_FRETE
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO]	:= (cAliasQry)->BASE_SEGURO
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP]	:= (cAliasQry)->BASE_DESPE
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES]:= (cAliasQry)->BASE_ICMDES
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST]	:= (cAliasQry)->BASE_ICMRET
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO]:= (cAliasQry)->BASE_REDBAS
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED]	:= (cAliasQry)->BASE_TPRED
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]		:= (cAliasQry)->BASE_UM

		//-------------------------------------------------
		//Adiciono a fórmula da base de cálculo
		//-------------------------------------------------
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FOR_NPI] := (cAliasQry)->BAS_FOR //Fórmula NPI
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID_NPI]  := (cAliasQry)->BAS_FOR_ID //ID da fórmula da tabela CIN
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR] := (cAliasQry)->BAS_FOR_COD //Código da fórmula
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FORMULA] := ""
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_OPINTEG] := .F. //Indica se a fórmula da base possui operando de integração

		If (cAliasQry)->(FieldPos("BAS_FORMULA")) > 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FORMULA] := (cAliasQry)->BAS_FORMULA	//Formula que compoe a base Tabela CIN
		Endif

		//----------------------------------------------------------------
		//Preenche as referêcias com as regras da base de cálculo auxiliar
		//----------------------------------------------------------------
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ID]		:= (cAliasQry)->BS_A_ID
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_COD]	:= (cAliasQry)->BS_A_COD
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_VLORI]	:= (cAliasQry)->BS_A_VALORI
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_DESCON]	:= (cAliasQry)->BS_A_DESCON
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FRETE]	:= (cAliasQry)->BS_A_FRETE
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_SEGURO]	:= (cAliasQry)->BS_A_SEGURO
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_DESP]	:= (cAliasQry)->BS_A_DESPE
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ICMSDES]:= (cAliasQry)->BS_A_ICMDES
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ICMSST]	:= (cAliasQry)->BS_A_ICMRET
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_REDUCAO]:= (cAliasQry)->BS_A_REDBAS
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_TPRED]	:= (cAliasQry)->BS_A_TPRED
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_UM]		:= (cAliasQry)->BS_A_UM

		//-------------------------------------------------
		//Adiciono a fórmula da base de cálculo auxiliar
		//-------------------------------------------------
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FOR_NPI] := (cAliasQry)->BS_A_FOR //Fórmula NPI
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ID_NPI]  := (cAliasQry)->BS_A_FOR_ID //ID da fórmula da tabela CIN
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_COD_FOR] := (cAliasQry)->BS_A_FOR_COD //Código da fórmula
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FORMULA] := ""
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_OPINTEG] := .F. //Indica se a fórmula da base possui operando de integração
			
		If (cAliasQry)->(FieldPos("BS_A_FORMULA")) > 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FORMULA] := (cAliasQry)->BS_A_FORMULA	//Formula que compoe a base Tabela CIN
		Endif

		//-------------------------------------------------
		//Preenche as referências com as regras de alíquota
		//-------------------------------------------------
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID]		:= (cAliasQry)->ALQ_ID
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_COD]	:= (cAliasQry)->ALQ_CODIGO
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI]	:= (cAliasQry)->ALQ_VALORI
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ]	:= (cAliasQry)->ALQ_TPALIQ
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ALIQ]	:= (cAliasQry)->ALQ_ALIQ
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_CODURF]	:= (cAliasQry)->ALQ_URF
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_PERURF]	:= (cAliasQry)->ALQ_UFRPER
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VALURF]	:= (cAliasQry)->URF_VALOR

		If lCmpRedAliq
			nAliqRed := (cAliasQry)->ALQ_REDALI
		Endif
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_REDUCAO] := nAliqRed
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_OPINTEG] := .F. //Indica se a fórmula da alíquota possui operando de integração

		//-------------------------------------------------
		//Adiciono as informações da fórmula de cálculo de alíquota
		//-------------------------------------------------
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_FOR_NPI] := (cAliasQry)->ALQ_FOR		//Fórmula NPI
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID_NPI]  := (cAliasQry)->ALQ_FOR_ID		//ID da fórmula da tabela CIN
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_COD_FOR] := (cAliasQry)->ALQ_FOR_COD	//Código da fórmula
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_FORMULA] := '' // Formula
		If (cAliasQry)->(FieldPos("ALQ_FORMULA")) > 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_FORMULA] := (cAliasQry)->ALQ_FORMULA // Formula
		Endif

		//-------------------------------------------------
		//Preenche as referências com as regras de escrituração
		//-------------------------------------------------

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID]             := (cAliasQry)->ESCR_ID
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE]         := (cAliasQry)->INCIDE
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]          := cStoNf
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_PERCDIF]        := (cAliasQry)->PERCDIF
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CST]            := Alltrim(cCST)
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CSTCAB]         := (cAliasQry)->CSTCAB
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED]   := (cAliasQry)->INC_RED //Incidencia parcela reduzida
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CCT]            := cCCT
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_DADO_ADICIONAL] := Array(NMAXREADDATA)
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_NLIVRO]         := cNLivro
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INDOP]          := cIndOp //Indicador de Operação

		// Em casos de reprocessamento e incidencia = 8 (integração), serão analisados os valores já gravados no TG_IT_LF para determinar a incidencia.
		IncOpIntgr(aNfItem, nItem, nTrbGen)
		//-------------------------------------------------
		// Regra de base de cálculo
		//Realizo o mapeamento dos operandos e suas fórmulas.
		MapOperForm(jMapForm, (cAliasQry)->BAS_FOR_COD, (cAliasQry)->BAS_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @jDepTrib, jVldTribs, @lTgVlZero)

		//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
		//O array `aDepVlOrig` **NÃO é utilizado em produção**. Todo o código que o utilizava **está comentado**
		//Foi substituído junto com a função REFxOPER(), que agora utiliza a função LeJson() para ler os operandos.
		//MapValOrig((cAliasQry)->BAS_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

		//-------------------------------------------------
		// Regra de alíquota
		//Realizo o mapeamento dos operandos e suas fórmulas.
		MapOperForm(jMapForm, (cAliasQry)->ALQ_FOR_COD, (cAliasQry)->ALQ_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @jDepTrib, jVldTribs, @lTgVlZero)

		//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
		//O array `aDepVlOrig` **NÃO é utilizado em produção**. Todo o código que o utilizava **está comentado**
		//Foi substituído junto com a função REFxOPER(), que agora utiliza a função LeJson() para ler os operandos.
		//MapValOrig((cAliasQry)->ALQ_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

		//-------------------------------------------------
		// Regra de cálculo do valor
		//Realizo o mapeamento dos operandos e suas fórmulas.
		MapOperForm(jMapForm, (cAliasQry)->VAL_FOR_COD, (cAliasQry)->VAL_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @jDepTrib, jVldTribs, @lTgVlZero)

		//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
		//O array `aDepVlOrig` **NÃO é utilizado em produção**. Todo o código que o utilizava **está comentado**
		//Foi substituído junto com a função REFxOPER(), que agora utiliza a função LeJson() para ler os operandos.
		//MapValOrig((cAliasQry)->VAL_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

		//-------------------------------------------------
		// Regra de cálculo do valor de Isento
		//Realizo o mapeamento dos operandos e suas fórmulas.
		MapOperForm(jMapForm, (cAliasQry)->ISE_FOR_COD, (cAliasQry)->ISE_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @jDepTrib, jVldTribs, @lTgVlZero)

		//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
		//O array `aDepVlOrig` **NÃO é utilizado em produção**. Todo o código que o utilizava **está comentado**
		//Foi substituído junto com a função REFxOPER(), que agora utiliza a função
		//MapValOrig((cAliasQry)->ISE_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

		//-------------------------------------------------
		// Regra de cálculo do valor de Outros
		//Realizo o mapeamento dos operandos e suas fórmulas.
		MapOperForm(jMapForm, (cAliasQry)->OUT_FOR_COD, (cAliasQry)->OUT_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), @jDepTrib, jVldTribs, @lTgVlZero)

		//Realiza o mapeamento dos tributos que dependem dos valores de origem como frete, desconto etc
		//O array `aDepVlOrig` **NÃO é utilizado em produção**. Todo o código que o utilizava **está comentado**
		//Foi substituído junto com a função REFxOPER(), que agora utiliza a função LeJson() para ler os operandos.
		//MapValOrig((cAliasQry)->OUT_FOR, Alltrim((cAliasQry)->TRIBUTO_SIGLA), aDepVlOrig)

		If lLoad
			DevTrbOperZero(aNfCab, aNfItem, nItem, nTrbGen, lTgVlZero)
		EndIf

		//Faz aqui o mapeamento da tabela progressiva com regra da tabela F2B
		IF !Empty((cAliasQry)->TABPRO)
			LoadTabPrg( (cAliasQry)->TABPRO , aTabProg, @nDedSimp)
		EndIF

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_SIM_CAD] := nDedSimp

		//Aqui faço o mapeamento da regra de dedução por dependentes
		IF !Empty((cAliasQry)->DEDDEP)
			LoadDedDep((cAliasQry)->DEDDEP, aTabDep)
		EndIF

	EndIF

//--------------------------------------------------------------------------
//Inicializo com zeros o controle do ItemDec do item dos tributos genéricos
//--------------------------------------------------------------------------
	aFill(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1],0)
	aFill(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2],0)

	// Crio uma cópia da regra de base para que caso utilize a regra de base auxiliar, não perca os dados da regra de base original
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS_BKP] := AClone(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS])

	// Modo da política CI6/CI7 para documentos com origem (ARCH-002)
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MODO_CI7] := ""
	
	If lLoad .And. lCI6Enabled .AND. (cAliasQry)->(FieldPos("MODO_CI7")) > 0
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MODO_CI7] := (cAliasQry)->MODO_CI7
	EndIf

Return nTrbGen

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCalcTG()
Função responsável por interpretar as regras e efetuar o cálculo dos
tributos genéricos conforme cadastrados.

@param aNfItem - Array com toda as informações do item da nota fiscal
@param nItem   - Número do item da nota fiscal
@param nTrbGen - Posição do tributo genério na referência IT_TRIBGEN
@param cExecuta - Indica as opções de base, alíquota e valor que deverão ser calculadas.
@param aNFCab   - Array com informações do cabeçalho da nota fiscal
@param jMapForm 	  - HashMap com o mapeamento dos operandos e formulas

@author joao.pellegrini
@since 27/06/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisCalcTG(aNFItem, nItem, nTrbGen, cExecuta, aNFCab,jMapForm, lEdicao, aFunc)

	DEFAULT cExecuta := "BSE|ALQ|VLR"
	Default lEdicao	:= .F.

//--------------------------------------------------------------------
//Adiciono nova posição para controle do SaveDec do tributo genérico
//--------------------------------------------------------------------
//Preciso verificar se o tributo já consta no array do SaveDec, se já existe não precisa adicoonar, se não existe ai será criado.
	TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)

//Aqui verifico se o tributo possuir fórmula...Sem fórmula calculará da forma legada na primeira onda...com fórmula executará as funções de NPI
	If Empty( aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI] )

		//-------
		//Legado
		//-------
		FisCalcLeg(aNFItem, nItem, nTrbGen, cExecuta, aNFCab)

	ElseIF fisFindFunc('XFISTPFORM')

		//-------
		//Fórmula
		//-------
		FisCalcForm(aNFItem, nItem, nTrbGen, cExecuta, aNFCab,jMapForm, lEdicao)

	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisLoadTG()
Função responsável por buscar os valores dos tributos genéricos gravados
na CD2, para carregar estes valores e adicionar nas referências do IT_TRBGEN

@param aNfItem   - Array Com todas informações do aNfItem
@param nItem     - Número do item atual
@param cIdDevol  - ID da tabela F2D para as notas de devoluções
@param nTGITRef  - Posição do Id do tributo genérico que deverá ser carregado
@param aNfCab    - Array Com todas informações do aNfCab
@param aPos      - Array com o cache de fieldpos
@param aDic    	 - Array com cache das tabelas
@param jMapForm 	  - HashMap com o mapeamento dos operandos e formulas

@author Erick Gonçalves Dias
@since 03/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisLoadTG(aNfItem, nItem, cIdDevol, nTGITRef, aNFCab, aPos, aDic, jMapForm, lReproc)

	Local cSelect		:= ""
	Local cFrom	    	:= ""
	Local cWhere		:= ""
	Local cAliasQry		:= ""
	Local cIdTrbGen		:= ""
	Local cQuery	 	:= ""
	Local cMD5			:= ""
	Local nLen 			:= 0
	Local aInsert		:= {}
	Local nX 			:= 0
	Local jVldTribs		:= JsonObject():New()
	Local cTpNota		:= ""
	Default cIdDevol	:= ""

	cTpNota := aNFCab[NF_TIPONF]

//---------------------------------------------------------------------------------
//IMPORTANTE - OS NOMES DOS CAMPOS DEVEM SER IGUAIS DA QUERY DA FUNÇÃO QryTribGen()
//---------------------------------------------------------------------------------

//Para as devoluções deverá considerar o ID do cIdDevol, para os demais cas
	cIdTrbGen	:= Iif(!Empty(cIdDevol),cIdDevol,aNfItem[nItem][IT_ID_LOAD_TRBGEN])

//Zero o controle de SaveDEc dos tributos genéricos caso já tenha sido criado
	aNFCab[NF_SAVEDEC_TG]	:= {}

//-------------------------------------------------------------------------
	// MEMOIZAÇÃO: Inicializa caches para esta execução de FisLoadTG
	// Cenário 1: Chamada via FisTribGen ? cache já foi inicializado ? reinicializa (ok)
	// Cenário 2: Chamada direta via matxfis/xFisLoadTG ? inicializa novo cache
	// Em ambos os casos, o cache é limpo ao final da função
	//-------------------------------------------------------------------------
	InitMemoCalc()

//Somente farei a query se o ID estiver preenchido.
	If !Empty(cIdTrbGen)

		//Seção dos campos da tabela F2D.
		cSelect := "F2D.F2D_TRIB  TRIBUTO_SIGLA, F2D.F2D_BASE  BASE_CALCULO, F2D.F2D_BASQTD BASE_QTDE , F2D.F2D_ALIQ   ALIQUOTA, "
		cSelect += "F2D.F2D_VALOR VALOR , F2D.F2D_IDCAD TRIBUTO_ID  ,F2D.F2D_ID IDF2D ,F2B.F2B_DESC TRIBUTO_DESCRICAO, F2B.F2B_PERFOP TRIBUTO_PERFOP, F2D_VALURF URF_VALOR, "
		cSelect += "F2D.F2D_RFIN REGRA_FIN, F2E.F2E_IDTRIB IDTRIB, F2E.F2E_DESC DESCTRIB, "

		//Verifica se o campo existe antes de adicionar na query
		If fisExtCmp('12.1.2310', .T.,'F2B','F2B_RND')
			cSelect += " F2B.F2B_RND TRIBUTO_RND, "
		EndIf

		//Verifica se o campo existe antes de adicionar na query
		If fisExtCmp('12.1.2510', .T.,'F2D','F2D_DEDSIM')
			cSelect += " F2D.F2D_DEDSIM DED_SIMP, "
		EndIf

		//Seção dos campos da regra de base de cálculo
		cSelect += "F27.F27_CODIGO BASE_COD   , F27.F27_VALORI BASE_VALORI , F27.F27_DESCON BASE_DESCON, F27.F27_FRETE  BASE_FRETE, "
		cSelect += "F27.F27_SEGURO BASE_SEGURO, F27.F27_DESPE  BASE_DESPE  , F27.F27_ICMDES BASE_ICMDES, F27.F27_ICMRET BASE_ICMRET,  "
		cSelect += "F27.F27_REDBAS BASE_REDBAS, F27.F27_TPRED  BASE_TPRED  , F27.F27_UM     BASE_UM    , F27.F27_ID     BASE_ID, "

		//Seção dos campos da regra de base de cálculo auxiliar
		cSelect += "' ' BS_A_COD   , ' ' BS_A_VALORI , ' ' BS_A_DESCON, ' ' BS_A_FRETE, "
		cSelect += "' ' BS_A_SEGURO, ' ' BS_A_DESPE  , ' ' BS_A_ICMDES, ' ' BS_A_ICMRET,  "
		cSelect += "0   BS_A_REDBAS, ' ' BS_A_TPRED  , ' ' BS_A_UM    , ' ' BS_A_ID, "
		
		//Seção dos campos da regra de alíquota
		cSelect += "F28.F28_CODIGO ALQ_CODIGO , F28.F28_VALORI ALQ_VALORI, F28.F28_TPALIQ ALQ_TPALIQ, F28.F28_ALIQ ALQ_ALIQ, "
		cSelect += "F28.F28_URF    ALQ_URF    , F28.F28_UFRPER ALQ_UFRPER, F28.F28_ID     ALQ_ID"

		If lCmpRedAliq
			cSelect += ", F28.F28_REDALI ALQ_REDALI "
		Endif

		//Verifica se tabela CIN existe para buscar os campos novos
		IF fisExtTab('12.1.2310', .T., 'CIN')
			cSelect += " ,F2B.F2B_DEDPRO TABPRO, F2B.F2B_DEDDEP DEDDEP, F2B.F2B_RGGUIA RGUIA,  "
			cSelect += " F2B.F2B_VLRMIN VLRMIN, F2B.F2B_VLRMAX VLRMAX, F2B.F2B_OPRMIN OPRLIM_MIN, F2B.F2B_OPRMAX OPRLIM_MAX,"

			If lFpACMAX
				cSelect += " F2B.F2B_ACMAX ACMAX, F2B.F2B_ACMIN ACMIN, "
			EndIf

			cSelect += " F2D.F2D_MVA MVA , F2D.F2D_AUXMVA MVA_AUX, "
			cSelect += " F2D.F2D_PAUTA PAUTA, "
			cSelect += " F2D.F2D_MAJORA MAJ, F2D.F2D_AUXMAJ IND_AUX_MAJ, F2D.F2D_TRBMAJ TRIBUTO_MAJ, "

			If fisExtCmp('12.1.2310', .T.,'F2D','F2D_ALIQTR')
				cSelect += " F2D.F2D_ALIQTR ALIQTRB,"
			EndIf

			If fisExtCmp('12.1.2410', .T.,'F2B','F2B_RDBASE')
				cSelect += " F2B.F2B_RDBASE RDBASE,"
			EndIf

			If fisExtCmp('12.1.2410', .T.,'F2B','F2B_STATUS')
				cSelect += " F2B.F2B_STATUS STATUS,"
			EndIf

			cSelect += " F2D.F2D_DEDDEP DED_DEP,"
			cSelect += " F2D.F2D_ALIQ ALQ_SERVICO, F2D.F2D_ALIQ ALQ_SERV_LEICOMP "

			cSelect += QryForNPI(lCmpNPIMemo, .T.)
			cSelect += ",  CINBAS.CIN_ID BAS_FOR_ID ,  CINBAS.CIN_CODIGO BAS_FOR_COD "
			cSelect += ",  ' ' BS_A_FOR_ID         ,  ' ' BS_A_FOR_COD "
			cSelect += ",  CINALQ.CIN_ID ALQ_FOR_ID ,  CINALQ.CIN_CODIGO ALQ_FOR_COD "
			cSelect += ",  CINVAL.CIN_ID VAL_FOR_ID ,  CINVAL.CIN_CODIGO VAL_FOR_COD "
			cSelect += ",  CINISE.CIN_ID ISE_FOR_ID ,  CINISE.CIN_CODIGO ISE_FOR_COD "
			cSelect += ",  CINOUT.CIN_ID OUT_FOR_ID ,  CINOUT.CIN_CODIGO OUT_FOR_COD "
			cSelect += ChkCINMemo(.T.)
		EndIF

		//Adiciona campos na seção de select da query com campos de escrituração
		IF fisExtTab('12.1.2310', .T., 'CJ2')
			cSelect += ", CJ2.CJ2_ID ESCR_ID, CJ2.CJ2_INCIDE INCIDE,  CJ2.CJ2_STOTNF TOTNF ,  CJ2.CJ2_PERDIF PERCDIF,  CJ2.CJ2_CSTCAB CSTCAB "
			cSelect += ", CJ2.CJ2_IREDBS INC_RED, CJ2.CJ2_CSTDEV CST_DEV"
			cSelect += ", CJ3.CJ3_CST RCST " //preencho caso seja devolucao da reforma tributaria (cClassTrib)

			If !Empty(cIdDevol)
				cSelect += ", CJ2.CJ2_CSTDEV CST "
				cSelect += ", CJ2.CJ2_CSTDEV LCST "
			Else
				cSelect += ", CJ2.CJ2_CST CST "
				cSelect += ", CJ3.CJ3_CST LCST "
			EndIf

			If lNrLivro
				cSelect += ", CJ2.CJ2_NLIVRO NLIVRO "
			EndIf

			If lIncideDev
				cSelect += ", CJ2.CJ2_INCDEV INCIDE_DEV, CJ2.CJ2_INCRBS INCIDE_PARC_RED_DEV "
			EndIf

			If lTotNfDev
				cSelect += ", CJ2.CJ2_DSTONF TOTNF_DEV "
			EndIf

			//Campos do livro
			cSelect += ", CJ3.CJ3_VLTRIB LVALTRIB  ,  CJ3.CJ3_VLISEN LISENTO   , CJ3.CJ3_VLOUTR LOUTROS "
			cSelect += ", CJ3.CJ3_VLNTRI LNTRIB  ,  CJ3.CJ3_VLDIFE LDIFERIDO ,  CJ3.CJ3_VLMAJO LMAJORADO , CJ3.CJ3_PEMAJO LPERCMAJ "
			cSelect += ", CJ3.CJ3_PEDIFE LPERCDIF,  CJ3.CJ3_PEREDU LPERCRED  ,  CJ3.CJ3_PAUTA LPAUTA     , CJ3.CJ3_MVA LMVA "
			cSelect += ", CJ3.CJ3_AUXMVA LAUXMVA ,  CJ3.CJ3_AUXMAJ LAUXMAJ	 ,  CJ3.CJ3_CSTCAB LCSTCAB "
			cSelect += ", CJ3.CJ3_BASORI LBASORI "

			If fisExtCmp('12.1.2310', .T.,'CJ3','CJ3_ALIQTR')
				cSelect += ", CJ3.CJ3_ALIQTR LALIQNCM "
			EndIf

			If lCmpRedAliq
				cSelect += ", CJ3.CJ3_PREDAL LALQ_REDALI "
				cSelect += ", CJ3.CJ3_ALIQOR LALQ_ORI "
			EndIf

			If lCmpCCT
				cSelect += ", CJ2.CJ2_CCT CCT "
			EndIf

			If lIndOp
				cSelect += ", CJ2.CJ2_INDOP INDOP "
			EndIf

		EndIF

		// Modo da política CI6/CI7 pré-carregado por JOIN (ARCH-002 — elimina FisCI6GetModo do caminho crítico)
		If !Empty(cIdDevol) .And. lCI6Enabled
			cSelect += ", CI7EX.CI7_MODO MODO_CI7 "
		EndIf

		//From na tabela F2D
		cFrom   += RetSQLName("F2D") + " F2D "

		//Join com a tabela de tributo F2B. Aqui está LEFT JOIN somente por precaução, se fosse INNER JOIN o tributo não seria carregado caso a F2B tivesse sido deletada indevidamente.
		//De qualquer forma o usuário não consegue deletar devido o relacionamento na X9 entre as tabelas F2D e F2B.
		cFrom += "LEFT JOIN " + RetSQLName("F2B") + " F2B " + " ON (F2B.F2B_FILIAL = ? AND F2B.F2B_ID = F2D.F2D_IDCAD AND F2B.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("F2B"))

		//Join com o cadastro de Tributo F2E
		cFrom += "LEFT JOIN " + RetSQLName("F2E") + " F2E " + " ON (F2E.F2E_FILIAL = ? AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("F2E"))

		//Join com a regra de base de cálculo utilizada no cálculo do tributo genérico
		cFrom += "LEFT JOIN " + RetSQLName("F27") + " F27 " + " ON (F27.F27_FILIAL = ? AND F27.F27_ID = F2D.F2D_IDBASE AND F27.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("F27"))

		//Join com a regra de alíquota utilizada no cálculo do tributo genérico
		cFrom += "LEFT JOIN " + RetSQLName("F28") + " F28 " + " ON (F28.F28_FILIAL = ? AND F28.F28_ID = F2D.F2D_IDALIQ AND F28.D_E_L_E_T_ = ' ') "
		Aadd(aInsert, xFilial("F28"))

		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		//Se a tabela CIN de fórmulas existir, então farei left join para carregar as fórmulas das regras de base de cálculo, alíquota e tributo que foram gravadas na F2D
		//----------------------------------------------------------------------------------------------------------------------------------------------------------------
		IF fisExtTab('12.1.2310', .T., 'CIN')
			//Fòrmula da base
			cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINBAS " + " ON (CINBAS.CIN_FILIAL = ? AND CINBAS.CIN_ID = F2D.F2D_IFBAS AND CINBAS.D_E_L_E_T_ = ' ') "
			Aadd(aInsert, xFilial("CIN"))

			//Fórmula da alíquota
			cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINALQ " + " ON (CINALQ.CIN_FILIAL = ? AND CINALQ.CIN_ID = F2D.F2D_IFALQ AND CINALQ.D_E_L_E_T_ = ' ') "
			Aadd(aInsert, xFilial("CIN"))

			//Fórmula do valor.
			cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINVAL " + " ON (CINVAL.CIN_FILIAL = ? AND CINVAL.CIN_ID = F2D.F2D_IFVAL AND CINVAL.D_E_L_E_T_ = ' ') "
			Aadd(aInsert, xFilial("CIN"))

			//Fórmula de Isento
			cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINISE " + " ON (CINISE.CIN_FILIAL = ? AND CINISE.CIN_IREGRA = F2B.F2B_ID AND CINISE.CIN_TREGRA = '11' AND CINISE.D_E_L_E_T_ = ' ') "
			Aadd(aInsert, xFilial("CIN"))

			//Fórmula de Outros
			cFrom += "LEFT JOIN " + RetSQLName("CIN") + " CINOUT " + " ON (CINOUT.CIN_FILIAL = ? AND CINOUT.CIN_IREGRA = F2B.F2B_ID AND CINOUT.CIN_TREGRA = '12' AND CINOUT.D_E_L_E_T_ = ' ') "
			Aadd(aInsert, xFilial("CIN"))
		EndIf

		//Join com a regra de escrituração
		IF fisExtTab('12.1.2310', .T., 'CJ2')
			cFrom += "LEFT JOIN " + RetSQLName("CJ3") + " CJ3 " + " ON CJ3.CJ3_FILIAL = ? AND CJ3.CJ3_IDF2D   = F2D.F2D_ID AND CJ3.CJ3_IDTGEN = F2D.F2D_IDREL AND CJ3.D_E_L_E_T_ = ' ' "
			Aadd(aInsert, xFilial("CJ3"))
			cFrom += "LEFT JOIN " + RetSQLName("CJ2") + " CJ2 " + " ON CJ2.CJ2_FILIAL = ? AND CJ2.CJ2_CODIGO  = F2B.F2B_CODESC AND " + Iif(lReproc, " CJ2.CJ2_ALTERA = '2' " ," CJ2.CJ2_ID = CJ3.CJ3_IDRESC ") + " AND CJ2.D_E_L_E_T_ = ' ' "
			Aadd(aInsert, xFilial("CJ2"))
		Endif

		// JOIN política CI6/CI7 — pré-carga em FisLoadTG elimina queries por item em FisApplyRelPol (ARCH-002)
		// Cada F2D gera no máximo 1 linha (CI6 único por FILIAL+CODIGO+TIPOPF+TPNOTA; CI7EX únicos por vigência ativa)
		If !Empty(cIdDevol) .And. lCI6Enabled
			cFrom += "LEFT JOIN " + RetSqlName("CI6") + " CI6POL ON CI6POL.CI6_FILIAL = ? "
			cFrom += " AND CI6POL.CI6_CODIGO = F2B.F2B_PERFOP "
			cFrom += " AND CI6POL.CI6_TIPOPF = ? "
			cFrom += " AND CI6POL.CI6_TPNOTA = ? "
			cFrom += " AND CI6POL.D_E_L_E_T_ = ? "
			Aadd(aInsert, xFilial("CI6"))
			Aadd(aInsert, '03')
			Aadd(aInsert, cTpNota)
			Aadd(aInsert, " ")

			cFrom += "LEFT JOIN " + RetSqlName("CI7") + " CI7EX ON CI7EX.CI7_FILIAL = ? "
			cFrom += " AND CI7EX.CI7_IDCI6 = CI6POL.CI6_ID "
			cFrom += " AND ( CI7EX.CI7_TRIB = F2E.F2E_TRIB OR CI7EX.CI7_TRIB = 'TODOS' ) "
			cFrom += " AND CI7EX.CI7_VIGINI <= ? "
			cFrom += " AND ( CI7EX.CI7_VIGFIM = ? OR CI7EX.CI7_VIGFIM >= ? ) "
			cFrom += " AND CI7EX.D_E_L_E_T_ = ? "
			Aadd(aInsert, xFilial("CI7"))
			Aadd(aInsert, DToS(dDatabase))
			Aadd(aInsert, " ")
			Aadd(aInsert, DToS(dDatabase))
			Aadd(aInsert, " ")
		EndIf

		//Condição do where da query para trazer as informações do ID em questão.
		cWhere  += "F2D.F2D_IDREL =  ?  AND "
		Aadd(aInsert, cIdTrbGen)
		cWhere  += "F2D.D_E_L_E_T_ = ' '"


		cQuery := " SELECT " + cSelect + " FROM " + cFrom + " WHERE " + cWhere
		cMD5 := MD5(cQuery)

		//Verifica se a query já foi preparada, se não foi prepara a query e adiciona na lista de querys preparadas.
		If Valtype(jPrepared) <> 'J'
			jPrepared := JsonObject():new()
		EndIf

		If Valtype(jPrepared[cMD5]) <> 'O'
			jPrepared[cMD5] := FwExecStatement():New(ChangeQuery(cQuery))
		EndIf

		//Adiciona filtro
		nLen := Len(aInsert)
		For nX := 1 to nLen
			jPrepared[cMD5]:SetString(nX, aInsert[nX])
		Next

		aInsert := aSize(aInsert,0)

		cAliasQry := jPrepared[cMD5]:OpenAlias()

		// Otimização: Monta lista de tributos válidos
		BldValTrib(cAliasQry, @jVldTribs)

		//Processa todos os tributos genéricos gravados na F2D
		Do While !(cAliasQry)->(Eof())

			//Adiciona na referência IT_TRIBGEN as informações do tributo genérico considerando as informações da F2D.
			AddTrbGen(@aNfItem, nItem, cAliasQry,nTGITRef,aNFCab,aPos, aDic, jMapForm,,,.T., jVldTribs)
			(cAliasQry)->(DbSKip())
		Enddo

		//Libera o objeto de tributos válidos
		FwFreeObj(jVldTribs)
		jVldTribs := Nil

		//Fecha o Alias antes de sair da função
		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbCloseArea ())

	EndIF

	//-------------------------------------------------------------------------
	// MEMOIZAÇÃO: Limpa todos os caches ao final de FisLoadTG (ciclo unificado)
	//-------------------------------------------------------------------------
	EndMemoCalc()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGrbTrbGen()
Função responsável por realizar a gravação dos tributos genéricos na tabela F2D.
A gravação irá considerar as informações contidas na referência do aNfItem IT_TRBGEN

@param aNfItem - Array com todas as informações do item da nota fiscal
@param nItem - Número do item a ser processado por esta função.
@param cAlias - Alias da tabela do item que terá gravado o ID do tributo genérico.
@param aDic   - Array com cache das tabelas

@return cRet - Retornar o ID utilizado na gravação dos tributos na F2D, para que os fontes
consumidores possam gravar este ID em suas respectivas tabelas de itens, como a SD1 e SD2.

@author Erick Gonçalves Dias
@since 09/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisGrvTrbGen(aNfItem, nItem, cAlias, aDic)

	Local nTrbGen 	:= 0
	Local nTrbMaj   := 0
	Local cRet		:= ""

	dbSelectArea("F2D")

//Percorre o array e gravará F2B para todos os tributos genéricos calculados
	For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

		If (aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] > 0 .Or. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] > 0) .OR. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP] > 0;
				.Or. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO]

			RecLock("F2D",.T.)

			F2D->F2D_FILIAL	:=	xFilial("F2D")
			F2D->F2D_ID		:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D]
			F2D->F2D_IDREL	:=	aNfItem[nItem][IT_ID_TRBGEN]
			F2D->F2D_TABELA	:=	cAlias
			F2D->F2D_RFIN	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_FIN]
			F2D->F2D_TRIB  	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA]
			F2D->F2D_ALIQ  	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
			F2D->F2D_VALOR 	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
			F2D->F2D_IDCAD 	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_REGRA]
			F2D->F2D_IDBASE :=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID]
			F2D->F2D_IDALIQ :=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID]
			F2D->F2D_VALURF	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VALURF]

			//Tratamento para base de cálculo em quantidade
			If aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '02'
				//Base de cálculo em quantidade
				F2D->F2D_BASQTD	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
			Else
				//Base de cálculo normal com valor
				F2D->F2D_BASE  	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
			EndIF

			//Se a tabela CIN existir então gravará os campos dos IDs das fórmulas na F2D
			IF fisExtTab('12.1.2310', .T., 'CIN')
				F2D->F2D_IFBAS	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID_NPI]
				F2D->F2D_IFALQ	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ID_NPI]
				F2D->F2D_IFVAL	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_NPI]

				//Gravo também os campos com os índices de cálculos utilizados/enquadrados.
				F2D->F2D_MVA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MVA]
				F2D->F2D_AUXMVA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MVA]
				F2D->F2D_PAUTA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PAUTA]
				F2D->F2D_MAJORA	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MAJ]
				F2D->F2D_AUXMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MAJ]

				If fisExtCmp('12.1.2310', .T.,'F2D','F2D_ALIQTR')
					F2D->F2D_ALIQTR	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQTR]
				Endif

				//Grava os campos de valor majorado e alíquota majorada. Para isso  verificarei o tributo na referência TG_IT_TRB_MAJ
				//Posicionar o tributo, se encontrar grava os valores
				If(nTrbMaj 	:= GetPosTrib(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ] , aNfItem, nItem)) > 0
					F2D->F2D_TRBMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ]
					F2D->F2D_VALMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbMaj][TG_IT_VALOR]
					F2D->F2D_ALQMAJ	:= aNfItem[nItem][IT_TRIBGEN][nTrbMaj][TG_IT_ALIQUOTA]
				EndIF

				F2D->F2D_DEDDEP	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]

				F2D->F2D_IDTGEN	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB]

			EndIF

			If fisExtCmp('12.1.2510', .T., 'F2D', 'F2D_DEDSIM')
				F2D->F2D_DEDSIM := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_SIM_VAL]
			EndIf

			cRet	:= aNfItem[nItem][IT_ID_TRBGEN]

			F2D->(MsUnLock())

		EndIF

	Next nTrbGen

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisGrvCJ3()

Função que fará gravação da tabela CJ3, livro Fiscal dos tributos genéricos

@param aNFItem 		- Array com informações do aNfItem
@param nItem 		- Número do item a ser verificado
@param nTrbGen 	    - Posição do tributo

@return cIdEscrit - ID da escrituração

@author Erick Gonçalves Dias
@since 13/08/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisGrvCJ3(aNfItem, nItem, nTrbGen)

	Local cIdEscrit	:= FWUUIDV4(.T.)

	If !Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID])
		RecLock("CJ3",.T.)

		CJ3->CJ3_FILIAL	:=	xFilial("CJ3")
		CJ3->CJ3_IDESCR	:=	cIdEscrit //ID da própria tabela
		CJ3->CJ3_IDF2D	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ID_F2D] //ID de relacionamento com F2D
		CJ3->CJ3_IDRESC :=  aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID] //ID de relacionamento com regra de escrituração

		//Darei preferência para o ID do IT_ID_LOAD_TRBGEN, pois trata-se ~de manter o ID já gravado, como no caso de reprocessamento
		IF !Empty(aNfItem[nItem][IT_ID_LOAD_TRBGEN])
			CJ3->CJ3_IDTGEN	:=	 aNfItem[nItem][IT_ID_LOAD_TRBGEN] //ID dos tributos genéricos do item
		Else
			CJ3->CJ3_IDTGEN	:=	 aNfItem[nItem][IT_ID_TRBGEN] //ID dos tributos genéricos do item
		EndIf

		CJ3->CJ3_TRIB	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA] //CST do tributo
		CJ3->CJ3_CSTCAB	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CSTCAB]
		CJ3->CJ3_CST	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CST]
		CJ3->CJ3_VLTRIB	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_VALTRIB]
		CJ3->CJ3_VLISEN	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ISENTO]
		CJ3->CJ3_VLOUTR	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_OUTROS]
		CJ3->CJ3_VLNTRI	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_NAO_TRIBUTADO]
		CJ3->CJ3_VLDIFE	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]
		CJ3->CJ3_VLMAJO	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MAJORADO]
		CJ3->CJ3_PEMAJO	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_MAJORACAO]
		CJ3->CJ3_PEDIFE	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_DIFERIDO]
		CJ3->CJ3_PEREDU	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_REDUCAO]
		CJ3->CJ3_PAUTA	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PAUTA]
		CJ3->CJ3_MVA	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MVA]
		CJ3->CJ3_AUXMVA	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MVA]
		CJ3->CJ3_AUXMAJ	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MAJORACAO]

		If fisExtCmp('12.1.2310', .T.,'CJ3','CJ3_ALIQTR')
			CJ3->CJ3_ALIQTR	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALIQTR]
		Endif

		CJ3->CJ3_BASORI	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]

		If lCmpRedAliq
			CJ3->CJ3_PREDAL	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALQ_REDALI]
			CJ3->CJ3_ALIQOR :=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALQ_ORI]
		Endif

		If lCmpCCT
			CJ3->CJ3_CCT	:=	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CCT]
		Endif

		If lNrLivro
			CJ3->CJ3_NLIVRO := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_NLIVRO]
		EndIf

		If lIndOp
			CJ3->CJ3_INDOP := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_INDOP]
		EndIf

		CJ3->(MsUnLock())

	EndIf

Return cIdEscrit

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelTrbGen
	Função responsável por adicionar a data de exclusão do registro na tabela F2D.
	Esta tabela nunca será efetivamente deletada pois caso o documento de origem
	seja cancelado/excluído perderia-se a relação entre as tabelas.
	Update - anedino.santos - agora a função abre exceção para de fato deletar
	registros, pois	há ocasiões em que se faz necessário. DSERFISE-8594 (28/02/2024)

	@param cIdTribGen, character, ID para buscar as informações que serão deletadas
	@param lException, logical, exceção para delete efetivo do registro

	@author Erick Gonçalves Dias
	@since 10/07/2018
	@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisDelTrbGen(cIdTrbGen, lException)

	Local cIdSFT := "" as character
	default lException := .F.

	dbSelectArea("F2D")
	dbSetOrder(2) //AL+F2D_IDREL

	If !Empty(cIdTrbGen)
		//Busca por tributos considerando o Id
		If F2D->(MsSeek(xFilial("F2D")+cIdTrbGen))
			//Laço para excluir todos os tributos genéricos do ID em questão
			While !F2D->(Eof()) .And. xFilial("F2D")+cIdTrbGen == F2D->F2D_FILIAL+F2D->F2D_IDREL
				RecLock("F2D",.F.)
				F2D->F2D_DTEXCL := dDataBase
				// há casos em que se faz necessário excluir o registro.
				// na maioria das vezes é quando os livros fiscais SFT/SF3 são deletados
				cIdSFT := FtMaFisTG(cIdTrbGen)
				if lException .and. Empty(cIdSFT)
					F2D->(dbDelete())
				endif
				MsUnLock()
				F2D->(FkCommit())
				F2D->(dbSkip())
			EndDo
		EndIF

		//Verifica se tabela de livro dos tributos genéricos existe, e atualizará a data de exclusão
		FisXDelCJ3(cIdTrbGen, "1", lException, cIdSFT)
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisChkTG()
Função responsável por efetuar algumas validações para utilização dos
tributos genéricos.

@param cAlias - Alias da tabela no qual será gravado o ID de relacionamento
com a tabela F2D.
@para cCampo - Campo no qual será gravado o ID de relacionamento com a
tabela F2D.

@author Erick Gonçalves Dias
@since 10/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisChkTG(cAlias, cCampo)

	Local lRet := cPaisLoc == "BRA" .And. fisExtTab('12.1.2310', .T., "F2D") .And. !Empty(cAlias) .And. AliasinDic(cAlias) .AND. (cAlias)->(FieldPos(cCampo)) > 0 .AND. ;
		fisFindFunc("MaFisTG") .AND. fisFindFunc("FisRetTG") .AND. fisFindFunc("FisF2F") .And. fisFindFunc("FisTitTG") .AND. ;
		!Empty(MaFisScan("NF_TRIBGEN",.F.))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDevTrbGen()
Função responsável por tratar as devoluções de venda e de compra dos tributos
genéricos.
Esta função utilizará o RECORI da SD1/SD2 para buscar o ID do tributo genérico,
fará a carga dos valores e proporcionalizará considerando a quantidade da nota
original com a nota de devolução.

@param aNfCab   - Array com as informações cabeçalho da nota fiscal
@param aNfItem  - Array com toda as informações do item da nota fiscal
@param nItem    - Número do item da nota fiscal
@param aPos    - Array com cache dos fieldpos
@param aDic    - Array com cache de aliasindic
@param cCampo  - String com o campo alterado na pilha da recall
@param nTGITRef - Tamanho do array ItemRef dos tributos genéricos

@author Erick Gonçalves Dias
@since 11/07/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisDevTrbGen(aNfCab, aNfItem, nItem, aPos, aDic, cCampo,nTGITRef, jMapForm, aDepVlOrig, aFunc)

	Local cIdTrbGen := ""
	Local nTrbGen	:= 0
	Local nQtdeOri	:= 0
	Local lCBSIBSDEV    := .F. as logical
	Local lDevolucao  := .F.
	Local cFilOrig    := "" // Filial de origem da nota (D2_FILIAL / D1_FILIAL) — DSERFISE-16530
	Local cFilBkp     := "" // Backup incondicional de cFilAnt antes de FisLoadTG

//Verifica se é devolução de compra ou venda, posiciona no item original e busca o ID do tribGEN e quantidade
	If aNFCab[NF_CLIFOR] == "C" .AND. fisExtCmp('12.1.2310', .T.,'SD2','D2_IDTRIB')
		//Devolução de Venda
		dbSelectArea("SD2")
		MsGoto(aNFItem[nItem][IT_RECORI])
		cIdTrbGen	:= SD2->D2_IDTRIB
		nQtdeOri	:= SD2->D2_QUANT
		cFilOrig	:= Alltrim(SD2->D2_FILIAL)
		lDevolucao	:= .T.
	ElseIF fisExtCmp('12.1.2310', .T.,'SD1','D1_IDTRIB')
		//Devolução de Compra
		dbSelectArea("SD1")
		MsGoto(aNFItem[nItem][IT_RECORI])
		cIdTrbGen	:= SD1->D1_IDTRIB
		nQtdeOri	:= SD1->D1_QUANT
		cFilOrig	:= Alltrim(SD1->D1_FILIAL)
		lDevolucao	:= .T.
	EndIF

//Zero toda a estrutura dos tributos genéricos, já que os valores serão todos carregados da nota fiscal de origem
	aNfItem[nItem][IT_TRIBGEN]	:= Nil
	aNfItem[nItem][IT_TRIBGEN]	:= {}
	aNfItem[nItem][IT_TG_IDTRIB_IDX] := JsonObject():New()

//Verifico se o ID está preenchido e se a tabela existe antes de fazer carga dos tributos genéricos da nota original
	IF !Empty(cIdTrbGen) .AND. fisExtTab('12.1.2310', .T., 'F2D')
		//Somente farei a query se houver quantidade devolvida ou, no caso de devolução
		//financeira (ex.: complemento de preço), se houver valor total no item.
		If aNfItem[nItem][IT_QUANT] > 0 .Or. (aNfCab[NF_TIPONF] == "D" .And. aNfItem[nItem][IT_TOTAL] > 0)
			cFilBkp := cFilAnt // Salva contexto de filial atual
			// Devolucao entre filiais: usa filial de origem se diferente da corrente (DSERFISE-16530)
			If !Empty(cFilOrig) .AND. cFilOrig <> Alltrim(cFilAnt)
				cFilAnt := PadR(cFilOrig, FisTamSX3("SD2","D2_FILIAL")[1])
			EndIf
			//Função que faz query na F2D parra buscar os valores dos tributos genéricos da nota original
			FisLoadTG(@aNfItem, nItem, cIdTrbGen, nTGITRef, aNFCab, aPos, aDic, jMapForm, .F.)
			// Restaura contexto de filial (incondicional — cFilBkp contem sempre o valor original)
			cFilAnt := cFilBkp
		EndIF
	EndIF

//Percorre o os tributos genéricos carregados para aplicar a proporcionalidade caso seja devolução parcial.
//Para devolução integral não há necessidade de fazer proporcionalidade
	If nQtdeOri > 0 .And. nQtdeOri <> aNfItem[nItem][IT_QUANT]
		For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

			//--------------------------------------------------------------------
			//Adiciono nova posição para controle do SaveDec do tributo genérico
			//--------------------------------------------------------------------
			//Preciso verificar se o tributo já consta no array do SaveDec, se já existe não precisa adicoonar, se não existe ai será criado.
			TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)

			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] := (aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]) / nQtdeOri
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]  := (aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE])  / nQtdeOri
			
			// Proporcionaliza tambam a base original para devolucao parcial, calculos com reducao de base em FisLivroTG
			If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI] > 0
				aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI] := (aNfItem[nItem][IT_QUANT] * aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]) / nQtdeOri
			EndIf
		Next nTrbGen
	EndIF

	// Percorro o Array IT_TRIBGEN a procura do ID IBS e CBS 000060 000062 caso encontre não faz nada
	// caso contrario executa o FisDevEnqIBSCBS
	// O CBS e IBS no Perfil de Escrituracao com cClastrib 4100130 que diz que no documento de Compra quando nao form mencionado o IBS e CBS
	// para fazer a devolucao do documento deve-se informar o CBS e IBS ZERADO amparado pela Lei Complementar nº 214/2025

	if lDevolucao
		if !Empty(aNfItem[nItem][IT_TRIBGEN])
			for nTrbGen := 1 to Len(aNfItem[nItem][IT_TRIBGEN])
				if aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB] == TRIB_ID_IBS_EST .OR. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB] == TRIB_ID_CBS_FED
					lCBSIBSDEV := .T.
					exit
				endif
			next
		endif

		if !lCBSIBSDEV
			FisDevEnqIBSCBS(aNfCab, aNfItem, nItem, aPos, aDic, cCampo,nTGITRef, jMapForm, aDepVlOrig, aFunc)			
		endif
	endif
	// Fim do enquadramento da Devolucão CBS IBS Isento 
Return

/*/{Protheus.doc} FisRetTG()
@description Função responsável por retornar os tributos genéricos passíveis de retenção

@param dDataOper   - Data da operação, para enquadrar somente as regras vigentes
@return   aRet     - Array com os tributos que possuem regras de retenções vigentes

@author erick.dias
/*/
Function FisRetTG(dDataOper)

	Local aRet	:= {}
	Local cSelect	:= ""
	Local cFrom	    := ""
	Local cWhere	:= ""
	Local cAliasQry	:= ""
	Local lFinFkkVIg	:= fisFindFunc("FinFKKVig")

	IF lFinFkkVIg
		//Seção dos campos do cadastro do tributo F2B, tributo e descrição
		cSelect += "F2B.F2B_REGRA TRIBUTO_SIGLA, F2B.F2B_DESC TRIBUTO_DESCRICAO, F2B.F2B_RFIN  "

		//From será executado na tabela F2B - Regras dos tributos x Operação
		cFrom   += RetSQLName("F2B") + " F2B "

		//Seção do Where, considerando a vigência do tributo.
		cWhere  += "F2B.F2B_FILIAL = " + ValToSQL( xFilial("F2B") ) + " AND "
		cWhere  += ValToSql(dDataOper) + " >= F2B.F2B_VIGINI AND ( " + ValToSql(dDataOper) + " <= F2B.F2B_VIGFIM OR F2B.F2B_VIGFIM = ' ' ) AND F2B.F2B_RFIN <> ' ' AND "

		IF lAliasCIN
			cWhere  += "F2B.F2B_ALTERA <> '1' AND "
		EndIf

		cWhere  += "F2B.D_E_L_E_T_ = ' '"

		//Concatenará o % e executará a query.
		cSelect := "%" + cSelect + "%"
		cFrom   := "%" + cFrom   + "%"
		cWhere  := "%" + cWhere  + "%"

		cAliasQry := GetNextAlias()

		BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

		EndSQL

		//Adiciona no array sigla e descrição dos tributos retornados
		Do While !(cAliasQry)->(Eof())

			//A função posiciona na FKK corrente, considerando o código da FKK e dataOper, retornando o RECNO.
			//Somente avaliará a FKK
			If FinFKKVig((cAliasQry)->F2B_RFIN, dDataOper) > 0 .AND. !Empty(FKK->FKK_CODFKO)
				aAdd(aRet,{(cAliasQry)->TRIBUTO_SIGLA,(cAliasQry)->TRIBUTO_DESCRICAO} )
			EndIF

			(cAliasQry)->(DbSKip())
		Enddo

		//Fecha o Alias antes de sair da função
		dbSelectArea(cAliasQry)
		dbCloseArea()

	EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisGetURF

Função que retornará o valor atual da URF, considerando o período
e código da URF.

@param dDate     - Data da operação, para poder enquadrar a URF vigênte
@param cCodURF   - Código da URF configurada na regra de alíquota
@param nPercURF  - Percentual da URF configurada na regra de alíquota

@return nUrfAtual  - Valor da URF conforme os parâmetros de entradas

@author Erick Dias
@since 06/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FisGetURF(dDate, cCodURF, nPercURF)

	Local nUrfAtual		:= 0
	Default nPercURF	:= 100

	IF fisExtTab('12.1.2310', .T., "F2A")
		F2A->(dbSetOrder(1))
		If !Empty(dDate) .AND. !Empty(cCodURF) .AND. F2A->(MsSeek(xFilial("F2A") + padr(cCodURF,6) + Str(Year(dDate),4) + Strzero(Month(dDate),2)))

			nUrfAtual	:= F2A->F2A_VALOR
			If nPercURF > 0
				nUrfAtual	:= nUrfAtual * (nPercURF / 100)
			EndIF

		EndIF
	EndIf

Return nUrfAtual

/*/{Protheus.doc} FisHdrTG()
@description Função responsável por montar o aHeader do folder
dos tributos genéricos.
@author erick.dias
/*/
Function FisHdrTG()

	Local aHdrTrbGen    := {}

	aAdd(aHdrTrbGen,;
		{"Item",;
		"ITEM",;
		"@!",;
		4,;
		0,;
		"",;
		"",;
		"C",;
		"",;
		"R",;
		"",;
		"",;
		""})

	aAdd(aHdrTrbGen,;
		{"Sigla",;
		"F2D_TRIB",;
		PesqPict("F2D","F2D_TRIB"),;
		TamSX3("F2D_TRIB")[1] + 5 ,;
		TamSX3("F2D_TRIB")[2],;
		"",;
		"",;
		"C",;
		"",;
		"R",;
		"",;
		"",;
		""})

	aAdd(aHdrTrbGen,;
		{"Descrição",;
		"F2D_DESC",;
		"@!",;
		50,;
		0,;
		"",;
		"",;
		"C",;
		"",;
		"R",;
		"",;
		"",;
		""})

	aAdd(aHdrTrbGen,;
		{"Base de Cálculo",;
		"F2D_BASE",;
		PesqPict("F2D","F2D_BASE"),;
		TamSx3("F2D_BASE")[1],;
		TamSX3("F2D_BASE")[2],;
		"!Empty(GdFieldGet('F2D_TRIB',,.T.)) .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('F2D_BASE',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_IT_BASE'}, Val(GdFieldGet('ITEM',,.T.)))",;
		"",;
		"N",;
		"",;
		"R",;
		"",;
		"",;
		""})

	aAdd(aHdrTrbGen,;
		{"Alíquota",;
		"F2D_ALIQ",;
		PesqPict("F2D","F2D_ALIQ"),;
		TamSx3("F2D_ALIQ")[1],;
		TamSX3("F2D_ALIQ")[2],;
		"!Empty(GdFieldGet('F2D_TRIB',,.T.)) .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('F2D_ALIQ',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_IT_ALIQUOTA'}, Val(GdFieldGet('ITEM',,.T.)))",;
		"",;
		"N",;
		"",;
		"R",;
		"",;
		"",;
		""})

	aAdd(aHdrTrbGen,;
		{"Valor",;
		"F2D_VALOR",;
		PesqPict("F2D","F2D_VALOR"),;
		TamSx3("F2D_VALOR")[1],;
		TamSX3("F2D_VALOR")[2],;
		"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('F2D_VALOR',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_IT_VALOR'},Val(GdFieldGet('ITEM',,.T.)))",;
		"",;
		"N",;
		"",;
		"R",;
		"",;
		"",;
		""})

//Colunas dos campos de escrituração no livro dos tributos genéricos
	if fisExtTab('12.1.2310', .T., "CJ3")

		aAdd(aHdrTrbGen,;
			{"Código da Situação Tributária",;
			"CJ3_CST",;
			PesqPict("CJ3","CJ3_CST"),;
			TamSx3("CJ3_CST")[1],;
			TamSX3("CJ3_CST")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_CST',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_CST'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"C",;
			"",;
			"R",;
			"",;
			"",;
			""})

		aAdd(aHdrTrbGen,;
			{"Valor Tributado",;
			"CJ3_VLTRIB",;
			PesqPict("CJ3","CJ3_VLTRIB"),;
			TamSx3("CJ3_VLTRIB")[1],;
			TamSX3("CJ3_VLTRIB")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLTRIB',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_VALTRIB'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"N",;
			"",;
			"R",;
			"",;
			"",;
			""})

		aAdd(aHdrTrbGen,;
			{"Isento",;
			"CJ3_VLISEN",;
			PesqPict("CJ3","CJ3_VLISEN"),;
			TamSx3("CJ3_VLISEN")[1],;
			TamSX3("CJ3_VLISEN")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLISEN',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_ISENTO'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"N",;
			"",;
			"R",;
			"",;
			"",;
			""})

		aAdd(aHdrTrbGen,;
			{"Outros",;
			"CJ3_VLOUTR",;
			PesqPict("CJ3","CJ3_VLOUTR"),;
			TamSx3("CJ3_VLOUTR")[1],;
			TamSX3("CJ3_VLOUTR")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLOUTR',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_OUTROS'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"N",;
			"",;
			"R",;
			"",;
			"",;
			""})

		aAdd(aHdrTrbGen,;
			{"Não Tributado",;
			"CJ3_VLNTRI",;
			PesqPict("CJ3","CJ3_VLNTRI"),;
			TamSx3("CJ3_VLNTRI")[1],;
			TamSX3("CJ3_VLNTRI")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLNTRI',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_NAO_TRIBUTADO'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"N",;
			"",;
			"R",;
			"",;
			"",;
			""})

		aAdd(aHdrTrbGen,;
			{"Valor Diferido",;
			"CJ3_VLDIFE",;
			PesqPict("CJ3","CJ3_VLDIFE"),;
			TamSx3("CJ3_VLDIFE")[1],;
			TamSX3("CJ3_VLDIFE")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLDIFE',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_DIFERIDO'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"N",;
			"",;
			"R",;
			"",;
			"",;
			""})

		aAdd(aHdrTrbGen,;
			{"Valor Majorado",;
			"CJ3_VLMAJO",;
			PesqPict("CJ3","CJ3_VLMAJO"),;
			TamSx3("CJ3_VLMAJO")[1],;
			TamSX3("CJ3_VLMAJO")[2],;
			"!Empty(GdFieldGet('F2D_TRIB',,.T.))  .AND. Positivo() .And. MaFisTGRef('IT_TRIBGEN',GdFieldGet('CJ3_VLMAJO',,.T.),{GdFieldGet('F2D_TRIB',,.T.),'TG_LF_MAJORADO'},Val(GdFieldGet('ITEM',,.T.)))",;
			"",;
			"N",;
			"",;
			"R",;
			"",;
			"",;
			""})

	EndIf

Return aHdrTrbGen

//-------------------------------------------------------------------
/*/{Protheus.doc} FisF2F

Funcao responsável por componentizar a gravação da tabela F2F.

@param cOper      - Operação, indica se é inclusão ou exclusão do título
@param cIdNF      - ID de relacionamento com o documento fiscal, este ID é fundamental para vincular o título com a nota
@param cTabela    - Esta parâmetro identifica a tabela de origem da movimentação que gerou este título
@param aTGCalcRec - Lista dos tributos genéricos calculados que deverão ter títulos gerados.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FisF2F(cOper, cIdNF, cTabela, aTGCalcRec)

	Local nX := 0
	Local cChvF2F := ""

	DEFAULT aTGCalcRec := {}

	If fisExtTab('12.1.2310', .T., "F2F") .And. !Empty(cIdNF)

		dbSelectArea("F2F")
		F2F->(dbSetOrder(1))

		// Inclusao
		If cOper == "I"

			For nX := 1 to Len(aTGCalcRec)
				// Verifico se tem ID FK7 gerado pelo financeiro, o que
				// significa que o título em questão foi gerado.
				If !Empty(aTGCalcRec[nX, 4])
					RecLock("F2F", .T.)
					F2F->F2F_FILIAL := xFilial("F2F")
					F2F->F2F_IDNF := cIdNF
					F2F->F2F_TABELA := cTabela
					F2F->F2F_IDFK7 := aTGCalcRec[nX, 4]
					F2F->F2F_IDF2B := aTGCalcRec[nX, 5]
					F2F->(MsUnlock())
				EndIf
			Next nX

			// Exclusao
		ElseIf cOper == "E"

			cChvF2F := xFilial("F2F") + cIdNF + cTabela

			If F2F->(MsSeek(cChvF2F))
				While !F2F->(EoF()) .And. F2F->(F2F_FILIAL + F2F_IDNF + F2F_TABELA) == cChvF2F
					RecLock("F2F",.F.)
					F2F->(dbDelete())
					MsUnLock()
					F2F->(FkCommit())
					F2F->(dbSkip())
				EndDo
			EndIf

		EndIf

		F2F->(dbCloseArea())

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisTitTG
	Funcao responsavel por retornar o numero do titulo de tributo generico
	a ser gerado.

	Atualizacao: Implementacao de ciclo de validacao para garantir que letras sejam tratadas na utilizacao do Soma1

	@author joao.pellegrini
	@since 08/10/2018
	@version 11.80

	@author Edinei Cruz
	@return character, cNumero gerado para o titulo TG
	@version 12.1.2510
/*/
//-------------------------------------------------------------------
Function FisTitTG()

    Local cNumero := ""
    Local cPrefix := ""
    Local cSuffix := ""
    Local aRetSX5 := {} as array

    aRetSX5 := FwGetSX5( "53" ,"TG" )
    If len(aRetSX5) > 0
        cNumero := aRetSX5[1][4]
        cPrefix := SubStr(cNumero, 1, 2)
        cSuffix := SubStr(cNumero, 3)
        cSuffix := Soma1(cSuffix)
        cNumero := cPrefix + cSuffix
        FwPutSX5( ,"53" ,"TG" ,cNumero ,cNumero ,cNumero )
    EndIf
Return cNumero

//-------------------------------------------------------------------
/*/{Protheus.doc} FISFK7E1E2

Função responsável por converter uma chave FK7 para uma chave de SE1/SE2.

@param cChaveFK7 - Chave Fk7 do título
@param cTabela   - Indica se deverá considerar SE1 ou SE2 no momento de converter a chave Fk7

@return cChvSE   - Chave do título já convertida

@author joao.pellegrini
@since 10/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FISFK7E1E2(cChaveFK7, cTabela)

	Local aChvSE := {}
	Local cChvSE := ""
	Local aTamSE2 := {TamSX3("E2_FILIAL")[1], TamSX3("E2_PREFIXO")[1], TamSX3("E2_NUM")[1], TamSX3("E2_PARCELA")[1], TamSX3("E2_TIPO")[1], TamSX3("E2_FORNECE")[1], TamSX3("E2_LOJA")[1]}
	Local aTamSE1 := {TamSX3("E1_FILIAL")[1], TamSX3("E1_PREFIXO")[1], TamSX3("E1_NUM")[1], TamSX3("E1_PARCELA")[1], TamSX3("E1_TIPO")[1], TamSX3("E1_CLIENTE")[1], TamSX3("E1_LOJA")[1]}

	aChvSE := StrToKarr(cChaveFK7, "|")

	If Len(aChvSE) >= 7

		cChvSE := (PadR(aChvSE[1], IIf(cTabela == "SE1", aTamSE1[1], aTamSE2[1])) +;
			PadR(aChvSE[2], IIf(cTabela == "SE1", aTamSE1[2], aTamSE2[2])) +;
			PadR(aChvSE[3], IIf(cTabela == "SE1", aTamSE1[3], aTamSE2[3])) +;
			PadR(aChvSE[4], IIf(cTabela == "SE1", aTamSE1[4], aTamSE2[4])) +;
			PadR(aChvSE[5], IIf(cTabela == "SE1", aTamSE1[5], aTamSE2[5])) +;
			PadR(aChvSE[6], IIf(cTabela == "SE1", aTamSE1[6], aTamSE2[6])) +;
			PadR(aChvSE[7], IIf(cTabela == "SE1", aTamSE1[7], aTamSE2[7])))

	EndIf

Return cChvSE

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelTit

Função responsável por retornar o número do título de tributo genérico
a ser gerado.

@param cIdNF    - ID da nota fiscal que está sendo excluída
@param cTabela  - Tabela de origem da movimentação que gerou o título
@param cOrigem  - Rotina que gerou o título
@param nOpcao   - Opção para identificar tabela SE1 ou SE2
@param cNumTit  - Número do título a ser processado nesta função

@return lRet  - Indica se o título pode ou não ser excluido.

@author joao.pellegrini
@since 08/10/2018
@version 11.80
/*/
//-------------------------------------------------------------------
Function FisDelTit(cIdNF, cTabela, cOrigem, nOpcao, cNumTit)

	Local lRet := .T.
	Local cChvF2F := ""
	Local cChvSE := ""
	Local cMensagem	:= ""
	Local aRecnoExcl := {}
	Local nX := 0
	Local aArea := GetArea()

	Default cNumTit	:= ""

	dbSelectarea("F2F")
	F2F->(dbSetOrder(1))

	dbSelectarea("FK7")
	FK7->(dbSetOrder(1))

	dbSelectarea("SE2")
	SE2->(dbSetOrder(1))

	dbSelectarea("SE1")
	SE1->(dbSetOrder(1))

	cChvF2F := xFilial("F2F") + cIdNF + cTabela

	If !Empty(cIdNF) .And. F2F->(MsSeek(cChvF2F))

		// Laço na F2F para posicionar a FK7 com o campo F2F_IDFK7
		While !F2F->(Eof()) .And. F2F->(F2F_FILIAL + F2F_IDNF + F2F_TABELA) == cChvF2F

			cChvSE := ""
			cAlsSE := ""

			// Se encontrou na FK7 vou usar os campos FK7_ALIAS e FK7_CHAVE para chegar no título
			// gerado na SE1 ou SE2 conforme o caso.
			If FK7->(MsSeek(xFilial("FK7") + F2F->F2F_IDFK7))

				cAlsSE := FK7->FK7_ALIAS
				// Converte o conteúdo do campo FK7_CHAVE para poder localizar a SE1/SE2.
				cChvSE := FISFK7E1E2(FK7->FK7_CHAVE, cAlsSE)

				// Verifica se há algum título vinculado que não possa ser excluido pois sofreu algum tipo de baixa ou movimentação no financeiro.
				// Se houver paro o laço e já retorno .F. pois o documento em questão não pode ser excluído.
				If (cAlsSE)->(MsSeek(cChvSE))
					If nOpcao == 1
						If cAlsSE == "SE1"
							If !(lRet := FaCanDelCR("SE1", cOrigem, .F.))
								cNumTit := SE1->E1_NUM + "/" + SE1->E1_PREFIXO
							EndIF
						ElseIf cAlsSE == "SE2"
							IF !(lRet := FaCanDelCP("SE2", cOrigem, .F.))
								cNumTit := SE2->E2_NUM + "/" + SE2->E2_PREFIXO
							EndIF
						EndIf

						If !lRet
							cMensagem := "Não Será possível excluir o documento. Verifique o título " + cNumTit //
							Help(" ",1,"NAOEXCNF","NAOEXCNF",cMensagem,1,0,,,,,,{"Verifique a existência de borderôs, baixas totais, parciais ou outras movimentações financeiras envolvendo este título."}) //
							Exit
						EndIf
					Else
						aAdd(aRecnoExcl, {cAlsSE, (cAlsSE)->(RecNo())})
					EndIf
				EndIf

			EndIf

			F2F->(dbSkip())

		EndDo

		// Exclusão dos títulos...
		If lRet .And. nOpcao == 2
			For nX := 1 to Len(aRecnoExcl)
				If aRecnoExcl[nX, 1] == "SE1
					SE1->(dbGoTo(aRecnoExcl[nX, 2]))
					If fisFindFunc("FinGrvEx")
						FinGrvEx("R") // Gravar o histórico.
					EndIf
					RecLock("SE1",.F.)
					SE1->(dbDelete())
					FaAvalSE1(2)
					FaAvalSE1(3)
					MsUnLock()
				ElseIf aRecnoExcl[nX, 1] == "SE2
					SE2->(dbGoTo(aRecnoExcl[nX, 2]))
					If fisFindFunc("FinGrvEx")
						FinGrvEx("P") // Gravar o histórico.
					EndIf
					RecLock("SE2",.F.)
					SE2->(dbDelete())
					FaAvalSE2(2)
					FaAvalSE2(3)
					MsUnLock()
				EndIf
			Next nX
		EndIf

	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisRetGen

Função que percorre-rá todos tributos genéricos verificando
se ele é passível de retenção

@param aTGCalc - Obtém tributos genéricos calculados pelo motor Fiscal
@param aTGRet - Obtém tributos genéricos passíveis de retenção
@param lFinFkk - Variável que indica que a tabela Fkk do financeiro poderá ser utilizada
@param aTGCalcRet - Array para tributos passíveis de retenção
@param aTGCalcRec - Array para tributos de recolhimento
@param dEmissao - Data de emissao do Documento Fiscal

@author Renato Rezende
@since 28/11/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function FisRetGen(aTGCalc,aTGRet,lFinFkk,aTGCalcRet,aTGCalcRec,dEmissao, cNumNf, cSerie)

	Local cNumTitTG	:= ""
	Local cHistRec	:= ""
	Local nContTg	:= 0
	Local LDESCMAJ 	:= .F.
	Default cNumNf	:= SF2->F2_DOC
	Default cSerie	:= SF2->F2_SERIE

//Obtém todos os tributos genéricos calculados pelo motor Fiscal
	aTGCalc := MaFisRet(,"NF_TRIBGEN")

//Obtém todos os tributos genéricos passíveis de retenção
	aTGRet	:= xFisRetTG(dEmissao)

	For nContTg := 1 to Len(aTGCalc)

		//procuro pelo tributo genérico calculado na lista dos tributos passíveis de retenção
		nPosTgRet	:=  AScan(aTGRet, { |x| Alltrim(x[1]) == Alltrim(aTGCalc[nContTg][1])})

		// Se o tributo consta na lista dos passíveis de retenção, adiciona no aTGCalcRet.
		// Caso contrário, trata-se de um recolhimento e os valores serão adicionados no aTGCalcRec.
		If nPosTgRet > 0
			If lFinFkk
				//Se o tributo está previsto a ter retenção, então será adicionado no array aTGCalcRet para ser rateado entre as parcelas.
				aAdd(aTGCalcRet,{aTGCalc[nContTg][1],; //Sigla do Tributo
				aTGCalc[nContTg][2],;//Base de Cálculo Tributo
				aTGCalc[nContTg][3],;//Valor do Tributo
				aTGCalc[nContTg][4],;//Código da Regra FKK
				FinParcFKK(aTGCalc[nContTg][4]),;//Indica se retem integralmente na primeira parcela
				aTGCalc[nContTg][3],;//Saldo restante do tributo, é iniciado com o próprio valor do tributo
				aTGCalc[nContTg][2],;//Saldo restante da base de cálculo, que é iniciado com o próprio valor do tributo
				aTGCalc[nContTg][5],;//ID da regra Fiscal da tabela F2B
				aTGCalc[nContTg][6],;//Código da URF
				aTGCalc[nContTg][7]})//Percentual aplicável ao valor da URF
			EndIf
		ElseIf !Empty(aTGCalc[nContTg][4])
			// Se o tributo não é uma retenção, ou seja, é um recolhimento, adiciono no array aTGCalcRec para que os títulos
			// sejam gerados posteriormente.
			cNumTitTG := xFisTitTG()
			//TODO na onda 2 retirar a referência para F2_DOC e F2_SERIE, de forma que receba por parâmetro estas informações
			cHistRec := AllTrim(aTGCalc[nContTg][1]) + " - NF: " + AllTrim(cNumNf) + " / " + AllTrim(cSerie)

			//Aqui verifico na regra de guia se deseja subtrair o valor majorado no momento de gerar guia e título.
			If fisExtTab('12.1.2310', .T., "CJ4")
				lDesCMaj := !Empty(aTGCalc[nContTg][9]) .AND. CJ4->(MsSeek(xFilial("CJ4") + aTGCalc[nContTg][9] )) .AND. CJ4->CJ4_MODO == "1" .And. CJ4->CJ4_MAJSEP == "1"
			EndIF

			aAdd(aTGCalcRec, {aTGCalc[nContTg][4],; // Código da Regra FKK
			aTGCalc[nContTg][3] - Iif(lDesCMaj, aTGCalc[nContTg][10],0) ,; // Valor do tributo. Aqui pode ser subtraído a parcela majorada se estiver configurado na regra de guia
			cNumTitTG,; // Número do título a ser gerado
			'',; // ID FK7 do título gerado -> Só usar como retorno.
			aTGCalc[nContTg][5],;//ID da regra Fiscal da tabela F2B
			cHistRec,; // Histórico para gravar no título
			aTGCalc[nContTg][1]}) //Sigla do Tributo
		EndIf

	Next nContTg

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FisTGVldVal
Valida se o tributo na posicao informada em IT_TRIBGEN possui valor calculado.
Considera base > 0, valor > 0, flag zero intencional (TG_IT_VL_ZERO) ou
flag de carga de banco (TG_IT_LOAD).
Funcao auxiliar estatica interna — use FisBuscaLeg para acesso externo.

@type   Static Function
@param  aNFItem   - Array de itens da NF (aNFItem)
@param  nItem     - Indice do item a verificar (1-based)
@param  nPos      - Posicao em IT_TRIBGEN a validar
@return Logical   - .T. se o tributo possui valor calculado; .F. caso contrario

@author Edinei Cruz
@since 20/05/2026
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function FisTGVldVal(aNFItem, nItem, nPos)
	Local lRet as logical
	lRet := .F.
	If nPos > 0 .And. nPos <= Len(aNFItem[nItem][IT_TRIBGEN])
		If aNFItem[nItem][IT_TRIBGEN][nPos][TG_IT_BASE]    > 0 .Or.;
		   aNFItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR]   > 0 .Or.;
		   aNFItem[nItem][IT_TRIBGEN][nPos][TG_IT_VL_ZERO] .Or.;
		   aNFItem[nItem][IT_TRIBGEN][nPos][TG_IT_LOAD]
			lRet := .T.
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisPosTLeg
Localiza a posicao de um tributo legado em IT_TRIBGEN.
Funcao auxiliar estatica interna — use FisBuscaLeg para acesso externo.

@type   Static Function
@param  aNFItem    - Array de itens da NF (aNFItem)
@param  nItem      - Indice do item a verificar (1-based)
@param  cIdtribLeg - ID do tributo legado a localizar (ex: "000021")
@return Numeric    - Posicao em IT_TRIBGEN (> 0) ou 0 se nao encontrado

@author Edinei Cruz
@since 20/05/2026
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function FisPosTLeg(aNFItem, nItem, cIdtribLeg)
	Local cKey     as character
	Local nPosScan as numeric
	Local lHashOK  as logical
	cKey     := AllTrim(cIdtribLeg)
	nPosScan := 0
	lHashOK  := ValType(aNFItem[nItem][IT_TG_IDTRIB_IDX]) == "J"
	If Empty(cKey)
		Return 0
	EndIf
	If lHashOK .And. aNFItem[nItem][IT_TG_IDTRIB_IDX]:HasProperty(cKey)
		nPosScan := aNFItem[nItem][IT_TG_IDTRIB_IDX][cKey]
		// Valida se a posicao no indice ainda aponta para o IDTRIB correto
		If nPosScan > 0 .And. Len(aNFItem[nItem][IT_TRIBGEN]) > 0 .And. AllTrim(aNFItem[nItem][IT_TRIBGEN][nPosScan][TG_IT_IDTRIB]) == cKey
			Return nPosScan
		EndIf
		nPosScan := 0
	EndIf
Return nPosScan

//-------------------------------------------------------------------
/*/{Protheus.doc} FisBuscaLeg
Combina localizacao e validacao de tributo legado em IT_TRIBGEN.
Retorna a posicao se o tributo foi encontrado com valor calculado;
retorna 0 se nao encontrado ou sem valor.

@type   Function
@param  aNFItem    - Array de itens da NF (aNFItem)
@param  nItem      - Indice do item a verificar (1-based)
@param  cIdtribLeg - ID do tributo legado (ex: "000021")
@return Numeric    - Posicao em IT_TRIBGEN (> 0) se tributo tem valor;
                     0 se nao encontrado ou sem valor calculado

@author Edinei Cruz
@since 20/05/2026
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function FisBuscaLeg(aNFItem, nItem, cIdtribLeg)
	Local nPos as numeric
	nPos := FisPosTLeg(aNFItem, nItem, cIdtribLeg)
	If nPos > 0
		If !FisTGVldVal(aNFItem, nItem, nPos)
			nPos := 0
		EndIf
	EndIf
Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTribLeg
Verifica se o tributo generico com ID de tributo legado informado
foi calculado no item da NF.

@type   Function
@param  aNFItem    - Array de itens da NF (aNFItem)
@param  nItem      - Indice do item a verificar (1-based)
@param  cIdtribLeg - ID do tributo legado a verificar (ex: "000021")
@return Logical    - .T. se o tributo foi calculado com valor; .F. caso contrario

@author Erick Dias
@since 03/12/2019
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Function ChkTribLeg(aNFItem, nItem, cIdtribLeg)
Return FisBuscaLeg(aNFItem, nItem, cIdtribLeg) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} FISGetLtgBase

Retorna a lista base de tributos legados de ListTrbLeg.

O array retornado nao deve ser modificado diretamente;
use AClone para obter uma copia mutavel.

@type   Static Function
@return Array - Template base com todos os IDs de tributos legados e flag .F.

@author Edinei Cruz
@since 21/05/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function FISGetLtgBase()

	If ValType(aFISLtgBase) != "A"
		aFISLtgBase := ListTrbLeg()
	EndIf

Return aFISLtgBase

//-------------------------------------------------------------------
/*/{Protheus.doc} FISGetLtIx

Retorna o mapa de IDTRIB legado para posicao em ListTrbLeg.
O mapa e construido na primeira chamada e reaproveitado nas seguintes.

@type   Static Function
@return JsonObject - mapa IDTRIB legado (AllTrim) -> posicao numerica em ListTrbLeg

@author Edinei Cruz
@since 21/05/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function FISGetLtIx()
	Local nX    := 0
	Local aBase := {}

	If ValType(jFISLtgIx) != "J"
		jFISLtgIx := JsonObject():New()
		aBase     := ListTrbLeg()

		For nX := 1 To Len(aBase)
			jFISLtgIx[AllTrim(aBase[nX][1])] := nX
		Next nX
	EndIf

Return jFISLtgIx

//-------------------------------------------------------------------
/*/{Protheus.doc} ListTribLeg

Função que retorna lista dos tributos legados que estão
previstos/contemplados nos tributos genéricos

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function ListTrbLeg()

	Local aTrib			:= {{TRIB_ID_AFRMM      , .F.},;
		{TRIB_ID_FABOV      , .F.},;
		{TRIB_ID_FACS       , .F.},;
		{TRIB_ID_FAMAD      , .F.},;
		{TRIB_ID_FASEMT     , .F.},;
		{TRIB_ID_FETHAB     , .F.},;
		{TRIB_ID_FUNDERSUL  , .F.},;
		{TRIB_ID_FUNDESA    , .F.},;
		{TRIB_ID_IMAMT      , .F.},;
		{TRIB_ID_SEST       , .F.},;
		{TRIB_ID_TPDP       , .F.},;
		{TRIB_ID_IPI	    , .F.},;
		{TRIB_ID_CIDE		, .F.},;
		{TRIB_ID_SENAR	    , .F.},;
		{TRIB_ID_CPRB	    , .F.},;
		{TRIB_ID_FEEF	    , .F.},;
		{TRIB_ID_FUNRUR	    , .F.},;
		{TRIB_ID_CSLL	    , .F.},;
		{TRIB_ID_PROTEG	    , .F.},;
		{TRIB_ID_FUMIPQ	    , .F.},;
		{TRIB_ID_INSS		, .F.},;
		{TRIB_ID_IR		    , .F.},;
		{TRIB_ID_II		    , .F.},;
		{TRIB_ID_PIS	    , .F.},;
		{TRIB_ID_COF	    , .F.},;
		{TRIB_ID_ISS	    , .F.},;
		{TRIB_ID_ICMS	    , .F.},;
		{TRIB_ID_PRES_ICMS  , .F.},;
		{TRIB_ID_PRES_ST    , .F.},;
		{TRIB_ID_PRODEPE    , .F.},;
		{TRIB_ID_PRES_CARGA , .F.},;
		{TRIB_ID_SECP15     , .F.},;
		{TRIB_ID_SECP20     , .F.},;
		{TRIB_ID_SECP25     , .F.},;
		{TRIB_ID_INSSPT     , .F.},;
		{TRIB_ID_DIFAL      , .F.},;
		{TRIB_ID_CMP        , .F.},;
		{TRIB_ID_ANTEC      , .F.},;
		{TRIB_ID_FECPIC     , .F.},;
		{TRIB_ID_FCPST      , .F.},;
		{TRIB_ID_FCPCMP     , .F.},;
		{TRIB_ID_COFRET     , .F.},;
		{TRIB_ID_COFST      , .F.},;
		{TRIB_ID_PISRET     , .F.},;
		{TRIB_ID_PISST      , .F.},;
		{TRIB_ID_ISSBI      , .F.},;
		{TRIB_ID_PISMAJ     , .F.},;
		{TRIB_ID_COFMAJ     , .F.},;
		{TRIB_ID_DEDUCAO    , .F.},;
		{TRIB_ID_FRTAUT		, .F.},;
		{TRIB_ID_ICMDES		, .F.},;
		{TRIB_ID_DZFPIS		, .F.},;
		{TRIB_ID_DZFCOF		, .F.},;
		{TRIB_ID_ESTICM		, .F.},;
		{TRIB_ID_ICMSST		, .F.},;
		{TRIB_ID_FRTEMB		, .F.},;
		{TRIB_ID_CRDOUT		, .F.},;
		{TRIB_ID_STMONO		, .F.};
		}

Return aTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} ListTLegTG

Funcao que retorna lista dos tributos legados que tambem
foram calculados na lista dos tributos genericos.

Implementacao Fase 2 (DSERFISE-17061): passagem unica sobre IT_TRIBGEN
com indice reverso O(1) (FISGetLtIx). Substitui o loop anterior de 58
chamadas a ChkTribLeg por varredura linear em IT_TRIBGEN (tipicamente
5-10 elementos por item). Reducao estimada de ~112M para ~10-20M
iteracoes no cenario de referencia.

O array retornado e uma copia independente do template base (AClone);
callers em matxfis.prx apenas leem aTrib[nX][2] — nunca escrevem.

@param aNFItem - Array com informacoes do aNfItem
@param nItem   - Numero do item a ser verificado
@return Array  - Lista de tributos legados com flag de calculado em TG

@author Erick Dias
@since 04/12/2019
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Function ListTLegTG(aNFItem, nItem)

	Local nX      := 0
	Local nPosLeg := 0
	Local cIdTrib := ""
	Local aTrib   := AClone(FISGetLtgBase())
	Local aSeen   := Array(Len(aTrib))
	Local aTribGn := {}
	Local jLegIx  := FISGetLtIx()

	If nItem <= 0 .Or. Len(aNFItem) < nItem .Or. ValType(aNFItem[nItem][IT_TRIBGEN]) != "A"
		Return aTrib
	EndIf

	AFill(aSeen, .F.)

	aTribGn := aNFItem[nItem][IT_TRIBGEN]

	For nX := 1 To Len(aTribGn)
		cIdTrib := AllTrim(aTribGn[nX][TG_IT_IDTRIB])

		If !Empty(cIdTrib) .And. jLegIx:HasProperty(cIdTrib)
			nPosLeg := jLegIx[cIdTrib]

			If !aSeen[nPosLeg]
				aSeen[nPosLeg] := .T.
				aTrib[nPosLeg][2] := FisTGVldVal(aNFItem, nItem, nX)
			EndIf
		EndIf
	Next nX

Return aTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCalcTLeg

Função que retorna lista dos tributos legados que precisam ser recalculados
após enquadramento/cálculo dos tributos genéricos.

Esta função receberá array com lista de tributos legados que tinha tributo genérico
calculado antes do cálculo do tributo genérico, e também uma lsita de de tributos
legados que tinha tributo genérico calculado depois do cálculo do tributo genérico.

@param aTrbAntes 	- Lista dos tributos legado que tinha tributo genérico calculado antes do cálculo do TG
@param aTrbDepois	- Lista dos tributos legado que tinha tributo genérico calculado depois do cálculo do TG

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function ChkCalcTLeg(aTrbAntes, aTrbDepois)

	Local nX			:= 0
	Local aTrib			:= ListTrbLeg()

//Verifico primeiro se os arrays estão com tamanhos corretos, todos precisam ter a mesma dimensão e quantidade
	If Len(aTrib) == Len(aTrbAntes) .AND. Len(aTrib) == Len(aTrbDepois)

		//Uma vez garantido que os arrays possuem o mesmo tamanho percorro o aTrib
		For nX:= 1 to Len(aTrib)

			//Verifico se o tributo legado foi calculado em algum tribugo genérico antes ou se o tributo legado foi calculado agora em algum tribugo genérico
			//Em abos os casos indico que o tributo legado precisa ser recalculado, seja para ser zerado e evitando a duplicidade, ou seja devido o motivo
			//de desemquadrar algum tributo genérico e refazer o tributo legado
			IF aTrbAntes[nX][2] .OR. aTrbDepois[nX][2]
				//Coluna 2 preserva o comportamento atual de "precisa sincronizar".
				//Coluna 3 guarda o estado anterior e a coluna 4 o estado atual do TG.
				aTrib[nX] := { aTrib[nX][1], .T., aTrbAntes[nX][2], aTrbDepois[nX][2] }
			EndIF

		Next nX

	EndIF

Return aTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} FisTgArred

Função que fará tratamento do arredondamento dos valores dos tributos genéricos.
Esta função foi construída com base na função MaItArred, seguindo a mesma linha de
raciocínio, porém escalando para N tributos genéricos.
Esta função será chamada no final da MaItArred, ela foi criada para separar os fontes
do configurador e não onerar o tamanho da MATXFIS.

@param aNFCab 	- Array com informações do cabeçalho da nota
@param aNfItem	- Array com informações do item da nota
@param aSX6	    - Array com informações dos parâmetros
@param aTGITRef	- Arrays com as referências dos tributos genéricos 
@param aRefs	- Array com os campos específicos que foram solicitados para serem arredondados na chamada da MaItArred
@param nDec	    - Número da precisão de decimal, no caso do Brasil é com dias casas decimais
@param nx	    - Número do item posicionado
@param lSobra	- INdica se o sistema está configurado para controlar a Sobra(MV_SOBRA)

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function FisTgArred(aNFCab, aNfItem, aSX6, aTGITRef, aRefs, nDec, nx, lSobra)

	Local nZ			:= 0
	Local nY			:= 0
	Local nTrbGen		:= 0
	Local nPosTribTg 	:= 0
	Local nCampoTG		:= 0
	Local nUmCentavo 	:= 0
	Local nMeioCentavo 	:= 0
	Local nPosTgDel		:= 0
	Local nValor		:= 0	
	Local nRndPrec		:= 0
	Local nDifItem		:= 0
	Local nDifItDel		:= 0
	Local nPrecissao := fisGetParam('MV_RNDPREC',10)

//Variáveis abaixo para facilitar a leitura do código
	nUmCentavo		:= (1/10**nDec) //Corresponde a 1 centavo
	nMeioCentavo	:= (50/(10**(nDec + 2))) //Corresponde a meio centavo
	nRndPrec  		:= IIf( nPrecissao < 3 , 10 , nPrecissao ) // Precisao para o arredondamento

//Percorre lista dos tributos enquadrados e calculados
	For nTrbGen:= 1 to Len(aNfItem[nx][IT_TRIBGEN])

		//Neste laço percorro os campos do tributo genérico(Base, Alíquota, Valor) que estão com flag para tratar arredondamento e sobra
		For nY:= 1 to Len(aTGITRef)

			If aRefs == Nil .Or. aScan( aRefs, aTGITRef[nY][1] ) <> 0

				If lSobra

					nDifItDel := 0 // Zerando variável que acumula a diferença dos itens deletados para controlar a sobra
					//Laço nos itens procurando itens deletados
					For nZ := 1 To Len(aNfItem)

						//Verifica se o item está deletado
						If aNfItem[nZ][IT_DELETED]

							//Verifica se no item deletado existe este tributo calculado
 							If (nPosTgDel	:= aScan(aNfItem[nZ][IT_TRIBGEN], {|x| Alltrim(x[TG_IT_SIGLA]) == Alltrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})) > 0

								If aNfItem[nZ][IT_TRIBGEN][nPosTgDel][TG_IT_ITEMDEC][1][nY] > 0
									nDifItDel += aNfItem[nZ][IT_TRIBGEN][nPosTgDel][TG_IT_ITEMDEC][1][nY]
									nDifItDel -= nUmCentavo
								Else
									nDifItDel += aNfItem[nZ][IT_TRIBGEN][nPosTgDel][TG_IT_ITEMDEC][2][nY]
								EndIf

							EndIF

						EndIf
					Next nZ
				EndIF

				//Verifica se este campo deve fazer tratamento de arredondamento e sobra
				If aTGITRef[nY][4]

					//Zerando variave que controla sobra após a terceira casa decimal
					nDifItem	:= 0

					//Obtem a posição do campo que será processado
					nCampoTG	:= aTGITRef[nY][2]

					//Obtem o valor bruto calculado, com todas as decimais e sobras
					nValor := aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG]

					//Verifica se existe valor do tributo para ser processado
					If nValor <> 0

						While Int(nValor) <> Int(NoRound(NoRound(nValor,nRndPrec),nDec,nDifItem,10)) .And. nRndPrec > 2
							nRndPrec -= 1
						Enddo

						//Trunca o valor e guarda a diferença a partir da segunda casa decimal na variável nDifItem
						aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG]  := NoRound(NoRound(nValor,nRndPrec),nDec,@nDifItem,10)

						//Verifica se existe valor a partir da terceira casa decimal, ou seja, se existe algum valor de sobra
						If nDifItem <> 0 .AND. ;
								(nPosTribTg	:= aScan(aNFCab[NF_SAVEDEC_TG], {|x| Alltrim(x[1]) == Alltrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})) > 0 //Aqui verifico e busco posição do tributo no SaveDec que está no aNfCab

							//Acumulo no SaveDec o valor do ItemDec [1]
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]

							//Agora posso zerar o ItemDec [1], pois já teve seu valor acumulado no SaveDec
							aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]	:= 0

							//-----------------------------------------------------------
							//Verifica se o tributo não está configurado para arredondar
							//-----------------------------------------------------------
							If aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND] == '2' // Trunca o valor sem arredondar
								//Aqui o tributo não está configurado para arredondars

								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] 			-= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= nDifItem
								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			+= nDifItem

								//Verifica se controla a sobra e se o valor da sobra acumulado é suficiente para descarregar no item
								If lSobra .And. ( aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] - nDifItDel ) >= nMeioCentavo

									aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY] 	:= nUmCentavo - nDifItem
									aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= 0
									//Atualiza o SaveDec retirando 1 centavo, pois logo abaixo será adicionado 1 centavo no valor
									aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			-= nUmCentavo
									//Aqui adiciona 1 centavo no tributo, pois já acumulou sobra suficiente
									aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] 				+= nUmCentavo

								EndIF

								//----------------------------------------------------------------------------------------------------------------------
								//Verifica se o tributo está configurado para arredondar, se existe valor de sobra e se o valor do tributo foi calculado
								//----------------------------------------------------------------------------------------------------------------------
							ElseIF aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND] == '1' .And. nDifItem > 0 // Arredonda o valor
								//Aqui o tributo está configurado para arredondar
								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] 			-= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= nDifItem
								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			+= nDifItem

								//Verifica se controla a sobra e se o valor da sobra acumulado é suficiente para descarregar no item

								If ( aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] - nDifItDel ) >= nMeioCentavo

									aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY] 	:= nUmCentavo - nDifItem
									aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY] 	:= 0

									//Atualiza o SaveDec retirando 1 centavo, pois logo abaixo será adicionado 1 centavo no valor
									aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG]			-= nUmCentavo

									//Aqui adiciona 1 centavo no tributo, pois já acumulou sobra suficiente
									aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] 				+= nUmCentavo

								EndIf

							ElseIf aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND] == '3' // Aplica a lógica ABNT estrita							

								aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] := CalcABNT(nValor, nDec)
							EndIf

							//Caso o controle de sobra esteja desabilitado, o savedec e itemdec serão zerados
							If !lSobra
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]	:= 0
								aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]	:= 0
								aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] 			:= 0
							Endif

						EndIF

					EndIF

				EndIf
			EndIF
		Next nY

	Next nTrbGen

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TGAjuArred

Função que fará tratamento do arredondamento dos valores dos tributos genéricos.
Esta função foi construída com base na função MaItArred, seguindo a mesma linha de
raciocínio, porém escalando para N tributos genéricos.
Esta função será chamada no final da MaItArred, ela foi criada para separar os fontes
do configurador e não onerar o tamanho da MATXFIS.

@param aNFCab 	- Array com informações do cabeçalho da nota
@param aNfItem	- Array com informações do item da nota
@param aTGITRef	- Arrays com as referências dos tributos genéricos
@param nx	    - Número do item posicionado
@param cCampo	- Referência a ser atualizada

@author Erick Dias
@since 04/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Function TGAjuArred(aNFCab, aNfItem, aTGITRef, nx, cCampo)

	Local nTrbGen		:= 0
	Local nPosTribTg	:= 0
	Local nY			:= 0
	Local nCampoTG		:= 0

//Percorre lista dos tributos enquadrados e calculados para realizar correções de arredondamento
	For nTrbGen:= 1 to Len(aNfItem[nx][IT_TRIBGEN])

		//Aqui verifico e busco posição do tributo no SaveDec que está no aNfCab
		nPosTribTg	:= aScan(aNFCab[NF_SAVEDEC_TG], {|x| Alltrim(x[1]) == Alltrim(aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])})

		If nPosTribTg > 0

			//Rodo os campos de base, alíquota e valor do tributo genérico
			For nY:= 1 to Len(aTGITRef)

				//Verifica se o campo faz controle de arredondamento
				If aTGITRef[nY][4]

					nCampoTG	:= aTGITRef[nY][2]

					//Aqui verifica se o tributo está configurador para truncar
					If aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_RND] == '2' // Trunca o valor sem arredondar

						aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
						aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]

						aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]
						aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]

					Else
						//Aqui verifica se o tributo está configurado para arredondar
						aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
						aNfItem[nX][IT_TRIBGEN][nTrbGen][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]

						If !(!Empty(cCampo) .And. cCampo == aTGITRef[nY][1])
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]
							aNFCab[NF_SAVEDEC_TG][nPosTribTg][2][nCampoTG] -= aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]
						EndIf

					EndiF
					aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][1][nY]:= 0
					aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_ITEMDEC][2][nY]:= 0

				EndIF

			NExt nY

		EndIF

	Next nTrbGen

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TgSaveDec

Função que adiciona-rá uma nova posição para controle do SaveDec do tributo genérico,
caso o tributo não conste no Array.

@param aNFCab 		- Array com informações do cabeçalho da nota
@param aNfItem		- Array com informações do item da nota
@param nItem		- Número do item posicionado
@param nTrbGen		- Número do tributo genérico posicionado

@author Erick Dias
@since 09/12/2019
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function TgSaveDec(aNFCab, aNfItem, nItem, nTrbGen)

//--------------------------------------------------------------------
//Adiciono nova posição para controle do SaveDec do tributo genérico
//--------------------------------------------------------------------
//Preciso verificar se o tributo já consta no array do SaveDec, se já existe não precisa adicionar, se não existe ai será criado.
	If aScan(aNFCab[NF_SAVEDEC_TG], {|x| Alltrim(x[1]) == Alltrim(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA])}) == 0
		aadd(aNFCab[NF_SAVEDEC_TG],{aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_SIGLA], Array(NMAX_IT_TG)})
		aFill(aNFCab[NF_SAVEDEC_TG] [Len(aNFCab[NF_SAVEDEC_TG])][2],0)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisExecNPI

Função que processa a fórmula NPI, e retorna o valor da fórmula
conforme a fórmula enviada para esta função.

Aqui apenas será executado a fórmula, não terá validação de sintaxe

Se por algu motivo o operando não for encontrado, não existir o valor
padrão será zero.

@param cFormula - Fórmula NPI a ser processada
@param aNFItem - Array com todas as informações do item
@param nItem - Número do item processado
@param jMapForm - Objeto hashmap com mapeamento dos operandos e fórmulas

@return - valor obtido através da fórmula indicada

@author Erick Dias
@since 17/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function xFisExecNPI(cFormula, aNFItem, nItem, jMapForm, lEdicao, lMemo, nPosTrbProc, cDetTrbPri, aNfCab, lIsRootNPI)

	Local nResultado	:= 0
	Local nCont			:= 0
	Local nContPilha	:= 0
	Local nTrbGen		:= 0
	Local nBaseOri		:= 0	
	Local nPercRedAlq	:= 0  // v12.1.2510: Percentual redução alíquota
	Local nAliqOri		:= 0  // v12.1.2510: Alíquota original
	Local aFormula		:= {}
	Local aPilha		:= {}
	Local cTributo		:= ""
	Local cFormTemp		:= ""
	Local cDetTrib		:= ""
	Local cRet			:= ""
	Local cCacheKey		:= ""
	Local cIdTribAtu	:= ""
	Local cSigla		:= ""
	Local cToken		:= ""
	Local lUseSemRed	:= .F.
	Default lEdicao    := .F.
	Default lMemo      := .F.
	Default cDetTrbPri := ""
	Default lIsRootNPI := .T.
	cIdTribAtu := GetCurTrbId(aNfItem, nItem, nPosTrbProc)

	// CACHE L1: Resultados recursivos (Memoização)
	// jNPIResultCache já foi criado por InitMemoCalc() no início do fluxo
	// Evita recálculo de tributos dependentes já processados
	// lIsRootNPI = .F. em chamadas recursivas internas (NPIxREF) para evitar
	// colisão de chave: subfórmulas como A:ALQ001 não devem gravar TRIB14|ALQ|1

	// Constrói a chave de cache antecipadamente (Centralized Key Builder)
	If !lEdicao .And. lIsRootNPI .And. nPosTrbProc > 0 .And. !Empty(cDetTrbPri)
		cSigla := AllTrim(aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA])
		lUseSemRed := (LSEMREDUCAO .Or. lAliqSemRed) // Captura contexto de redução
		cCacheKey := NPIBuildResultCacheKey(cSigla, cDetTrbPri, nItem, lUseSemRed)
	EndIf

	// Tenta cache de result-final (retorno antecipado se encontrar)
	If !lSkipNPIResultCache .And. NPITryResultCache(lEdicao, cCacheKey, @nResultado)
		Return nResultado
	EndIf

// Cache de tokens para evitar StrTokArr repetido
// StrTokArr era executado 50.000+ vezes em tributos em cascata (~7 segundos)
// Com cache: O(1) lookup via HasProperty, zero parsing após 1ª execução
	aFormula	:= GetTknForm(cFormula)

//-------------------------------------------------
//Laço para percorrer todos os elementos da fórmula
//-------------------------------------------------
	For nCont := 1 to len( aFormula )

		//--------------------------
		//Verifica se é um operador
		//--------------------------
		If aFormula[nCont] $ "+-*/"

			//-----------------------------------------------------------------------------------
			//Se for operador então fará o cálculo com os dois últimos operandos do topo da pilha
			//Pega o tamanho da pilha
			//Proteção caso a pilha não tenha elementos suficiente para executar e não ocasionar error log
			//------------------------------------------------------------------------------------
			IF (nContPilha	:= Len( aPilha )) > 1

				//----------------------------------------------------------------
				//Realiza o cálculo considerndo os dois operandos do topo da pilha
				//----------------------------------------------------------------
				Do Case
				Case aFormula[nCont] == '/'
					nResultado	:= 	aPilha[nContPilha-1] / aPilha[nContPilha]

				Case aFormula[nCont] == '*'
					nResultado	:= 	aPilha[nContPilha-1] * aPilha[nContPilha]

				Case aFormula[nCont] == '+'
					nResultado	:= 	aPilha[nContPilha-1] + aPilha[nContPilha]

				Case aFormula[nCont] == '-'
					nResultado	:= 	aPilha[nContPilha-1] - aPilha[nContPilha]
				EndCase

				//------------------------------------------------
				//Remove do Array os dois últimos operandos (POP)
				//------------------------------------------------
				ASize( aPilha, nContPilha - 2 )

				//---------------------------------------------
				//Adiciona o resultado no topo da pilha (PUSH)
				//---------------------------------------------
				aadd( aPilha, nResultado )

			EndiF

		Else
			cToken			:= ResOperPriTrb(NrmTidOper(AllTrim(aFormula[nCont])), cIdTribAtu, aNfItem, nItem)
			cTributo		:= ""
			cFormTemp		:= ""
			cDetTrib		:= ""
			cRet			:= ""
			nResultado		:= 0

			//Para os operandos de tributos preciso verificar se o tributo foi enquadrado antes de prosseguir
			If IsOperTrib(cToken)
				//Regra do tributo, preciso buscar no aNfItem
				//Busca posição no aNfItem
				cTributo	:= GetTribOper(cToken)

				//Obtem o número do item no aNfItem
				IF (nTrbGen 	:= GetPosTrib(cTributo , aNfItem, nItem)) > 0 .And. FindOper(jMapForm, cToken, @cFormTemp)
					//Aqui estou chamando a função de forma recursiva para resolver o operando composto.
					//Se o opernado contidos na fórmula aqui for T_, então buscarei da referência ao invés de recalcular....

					//Obtenho o detalhe do opernado, se é base, alíquota ou valor.
					cDetTrib	:= Left(cToken,3)

					// Short-circuit: verifica cache L1 por token
					/*If NPITryTokenCache(lEdicao, cTributo, cDetTrib, nItem, @nResultado)
						aadd(aPilha, nResultado)
						Loop
					EndIf*/

					//Se for edição e memoize então busco valor já calculado na referência
					If lEdicao .And. lMemo
						//Devo buscar o valor
						nResultado	:= RetValTrib(cDetTrib, aNFItem,nItem,nTrbGen)
					Else
						//Verifica se fórmula possuir operando MAIOR ou MENOR para ser executado.
						If "MAIOR" $ cFormTemp .Or. "MENOR" $ cFormTemp
							If "MAIOR" $ cFormTemp
								//Chama função que verifica qual operando possui maior valor, e retorna operando a seguir
								cRet := ExecMaxMin(cFormTemp, aNFItem, nItem, jMapForm, nTrbGen, cDetTrib, aNfCab, "MAIOR" )
							Else
								//Chama função que verifica qual operando possui menor valor, e retorna operando a seguir
								cRet := ExecMaxMin(cFormTemp, aNFItem, nItem, jMapForm, nTrbGen, cDetTrib, aNfCab, "MENOR")
							EndIf

							//Se função retorno operando, então cFormTemp será substituído se seguirá fluxo com menor operando
							If !Empty(cRet)
								cFormTemp := cRet

								If cDetTrib == "BAS"
									// Restaura os valores das regras de base e regra de base auxiliar
									aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS] := AClone(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS_BKP]) 
									
									If "B:" $ cFormTemp .And. Substr(cFormTemp,3) != aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD]
										DefBaseAux(aNfItem, nItem, nTrbGen)
									EndIf
								EndIf
							EndIF
						EndIF

						// Se for um operando de valor, que já vai receber de uma referencia como valor final da formula, força passar na base e aliquota somente para preencher as referencias do aNfItem
						If IsOperGen( cFormTemp , cDetTrib , Alltrim(aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FORMULA_VAL]) )
							cFormTemp := "BAS:" + cTributo + " " + "ALQ:" + cTributo + " " + cFormTemp
						EndIf

						//Atribuir o valor, ou base ou alíquota para referência correspondente e, chamar MaItArred().

						//Devo calcular o valor
						nResultado	:= xFisExecNPI(cFormTemp, aNFItem, nItem, jMapForm, lEdicao, lEdicao, nTrbGen, cDetTrib, aNfCab)

						//Verifico qual referência devo atualizar do tributo dependente
						If cDetTrib == "BAS"

							//Atualiza a referência da base de cálculo
							aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] := nResultado

							//Faz arredondamento  da base de cálculo dos tributos genéricos
							MaItArred(nItem, { "TG_IT_BASE" } )

							nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]

							//Conout(cTributo + " " +  cDetTrib + " TG_IT_BASE")

							//Verifico se tem redução de base de cálculo
							IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] > 0

								//Aqui indico que a base de cálculo será refeita sem a redução
								LSEMREDUCAO	:= .T.

								//Efetuo novamente o cálculo para obter a base de cálculo original
								nBaseOri:= xFisExecNPI(cFormTemp, aNFItem, nItem, jMapForm, lEdicao, lEdicao, nTrbGen, cDetTrib, aNfCab)

								//Preencho a referência do livro com base de cálculo Original
								ProcEscrTG(aNfItem, nItem, nTrbGen, "", 0, ;
									0, 0, 0, 0, 0, ;
									0, 0, 0, 0, 0, ;
									0, 0, "", nBaseOri,0, 0, 0,"","", "")

								//Aqui retorno o flag para opção de cálculo normal
								LSEMREDUCAO	:= .F.
								nBaseOri	:= 0

							EndIF

						ElseIF cDetTrib == "ALQ"
							//Atualiza a referência da base de alíquota
							aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] := nResultado

							//Faz arredondamento  da base de cálculo dos tributos genéricos
							MaItArred(nItem, { "TG_IT_ALIQUOTA" } )

							nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]

							IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ] <> '2' .AND.  EMPTY(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_CODURF])
								//Se o próximo operando for de soma ou subtração, não poderei dividir por 100, estará somando alíquota.
								IF nCont + 1 <= len(aFormula) .And. !aFormula[nCont+1] $ "+-"
									nResultado := nResultado / 100
								EndIf
							Endif

							IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_REDUCAO] > 0

								nPercRedAlq := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_REDUCAO] / 100

								If nPercRedAlq >= 1
									// Redução 100%: recalcula com flag lAliqSemRed=.T.
									lAliqSemRed := .T.
									nAliqOri := xFisExecNPI(cFormTemp, aNFItem, nItem, jMapForm, ;
														lEdicao, lEdicao, nTrbGen, cDetTrib, aNfCab)
									lAliqSemRed := .F.
								Else
									// Redução < 100%: usa fórmula matemática
									nAliqOri := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / (1 - nPercRedAlq)
								EndIf

								//Preencho a referência do livro com alíquota Original
								ProcEscrTG(aNfItem, nItem, nTrbGen, "", 0, ;
									0, 0, 0, 0, 0, ;
									0, 0, 0, 0, 0, ;
									0, 0, "", 0,0,;
									0, nAliqOri,"","", "")

								nAliqOri := 0
							EndIF

						//Conout(cTributo + " " + cDetTrib + " TG_IT_ALIQUOTA")

						ElseIF cDetTrib == "VAL"

							nResultado	:= VlrLimite(aNFItem, nItem, nTrbGen, nResultado, nPosTrbProc, cDetTrbPri, aNfCab)

							//Atualiza a referência do valor
							aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] := nResultado

							MaItArred(nItem, { "TG_IT_VALOR" } )

							nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

							//Aqui chamo função para execução das regras de escrituração do livro dos tributos genéricos, caso possua uma regra vinculada ao tributo
							FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, lEdicao)

							//Conout(cTributo +  " " + cDetTrib + " TG_IT_VALOR")
						EndIF


					EndIF
				EndIF

			Else
				// Cache L1 contextual por item + tributo
				// Tenta cache L1 usando função componentizada
				If NPICacheTryGet(cToken, nItem, nPosTrbProc, @nResultado, LSEMREDUCAO .Or. lAliqSemRed)
					aadd(aPilha, nResultado)
					Loop  // Cache hit L1: pula resto do processamento para este operando
				EndIf

				//Aqui executarei o operando para obter o valor de retorno
				nResultado	:= NPIxREF(cToken, aNFItem, nItem, jMapForm, lEdicao, nPosTrbProc, cDetTrbPri, aNfCab)

				//--------------------------------------------------------------------------
				//Verifica se aFormula[nCont] é dedução por participante, então atualizerei
				//--------------------------------------------------------------------------
				IF cToken == PINDCALC + "DED_DEPENDENTES" .AND. Len(aPilha) >= 1 .and. Valtype(aPilha[1]) == "N"
					//-------------------------------------------------
					//Verifico se tem valor a deduzir por participante
					//-------------------------------------------------
					//Se a base de cálculo for maior que o valor de dedução, então será utilizada integralmente
					If aPilha[1] > nResultado
						//Pode seguir normalemnte e atribuirá na referência
						aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_DED_DEP]	:= nResultado
					Else
						//Se o valor de dedução for maior que a base, entao a base será zerada e a dedução será o próprio valor da base
						nResultado := aPilha[1]
						aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_DED_DEP]	:= nResultado
					EndIF

				EndIF

				// Armazena resultado em cache L1 contextual
				// para uso em próximos acessos do mesmo tributo/item.
				NPICacheStore(cToken, nItem, nPosTrbProc, nResultado, LSEMREDUCAO .Or. lAliqSemRed)

			Endif

			aadd(aPilha, nResultado)

		EndIF

	Next nCont

	aFormula	:= nil
	aPilha		:= nil


	// Armazena resultado no cache antes de retornar
	If !lSkipNPIResultCache .and. !lEdicao .and. !Empty(cCacheKey)
		NPIStoreResultCache(cCacheKey, nResultado)
	EndIf

Return Max(0,nResultado) //Por padrão não poderá ter valores negativos.

//-------------------------------------------------------------------
/*/{Protheus.doc} NPICacheBuildKey

Constroi chave de cache L1 unificado sempre contextual por item + tributo.

Formato base:
	- "operando@item@tributo"
	- Exemplo: "O:BASE_ICMS@1@5"

Formato com escrita sem redução:
	- "operando@item@tributo@SEMRED"
	- Exemplo: "O:BASE_ICMS@1@5@SEMRED"

Sufixo @SEMRED diferencia valores calculados COM vs SEM redução fiscal.
Essencial para: LSEMREDUCAO=.T., lAliqSemRed=.T., flags de recalculação.

@type Static Function
@author Rafael Oliveira
@since 02/02/2026
@version 12.1.2510

Revised: L1 cache consolidado
@author Rafael Oliveira
@since 04/02/2026

@param cOperando, Character, Operando NPI
@param nItem, Numeric, Número do item
@param nPosTrbProc, Numeric, Posição do tributo
@param lSemRed, Logical, Se .T. adiciona sufixo @SEMRED à chave (default .F.)

@return Character, Chave de cache formatada
/*/
//-------------------------------------------------------------------
Static Function NPICacheBuildKey(cOperando, nItem, nPosTrbProc, lSemRed)
	Local cKey := ""

	Default lSemRed := .F.

	cKey := cOperando + "@" + cValToChar(nItem) + "@" + cValToChar(nPosTrbProc)

	// Diferencia valores COM vs SEM redução (escrituração fiscal)
	If lSemRed
		cKey += "@SEMRED"
	EndIf

Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} NPICacheTryGet

Tenta recuperar valor do cache L1 contextual por item + tributo.
Se encontrar, retorna .T. e preenche nResultado por referência.
Se não encontrar, retorna .F.

@type Static Function
@author Rafael Oliveira
@since 02/02/2026
@version 12.1.2510

@param cOperando, Character, Operando NPI
@param nItem, Numeric, Número do item
@param nPosTrbProc, Numeric, Posição do tributo em processamento
@param nResultado, Numeric, Resultado (passado por referência)
@param lSemRed, Logical, Se .T. considera chave @SEMRED

@return Logical, .T. se encontrou no cache, .F. caso contrário
/*/
//-------------------------------------------------------------------
Static Function NPICacheTryGet(cOperando, nItem, nPosTrbProc, nResultado, lSemRed)
	Local lFound := .F.
	Local cKey := ""

	Default lSemRed := .F.

	cKey := NPICacheBuildKey(cOperando, nItem, nPosTrbProc, lSemRed)

	If ValType(jNPIResultCache) == "J" .And. jNPIResultCache:HasProperty(cKey)
		nResultado := jNPIResultCache[cKey]
		lFound := .T.
	EndIf

Return lFound

//-------------------------------------------------------------------
/*/{Protheus.doc} NPICacheStore

Armazena valor no cache L1 contextual por item + tributo.

@type Static Function
@author Rafael Oliveira
@since 02/02/2026
@version 12.1.2510

@param cOperando, Character, Operando NPI
@param nItem, Numeric, Número do item
@param nPosTrbProc, Numeric, Posição do tributo em processamento
@param nResultado, Numeric, Valor a ser armazenado
@param lSemRed, Logical, Se .T. grava chave @SEMRED

@return Nil
/*/
//-------------------------------------------------------------------
Static Function NPICacheStore(cOperando, nItem, nPosTrbProc, nResultado, lSemRed)
	Local cKey := ""

	Default lSemRed := .F.

	cKey := NPICacheBuildKey(cOperando, nItem, nPosTrbProc, lSemRed)

	If ValType(jNPIResultCache) == "J"
		jNPIResultCache[cKey] := nResultado
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} NPIBuildResultCacheKey

Constrói chave de cache L1 para resultado final de tributo.
Formato: SIGLA|DETALHE|ITEM[|SEMRED]

@type Static Function
@author Rafael Oliveira
@since 04/02/2026
@version 12.1.2510

@param cSigla, Character, Sigla do tributo (ex: ICMS)
@param cDetTrbPri, Character, Detalhe (BAS/ALQ/VAL)
@param nItem, Numeric, Número do item
@param lSemRed, Logical, Se .T. adiciona sufixo |SEMRED

@return Character, Chave formatada
/*/
//-------------------------------------------------------------------
Static Function NPIBuildResultCacheKey(cSigla, cDetTrbPri, nItem, lSemRed)
	Local cKey := cSigla + "|" + cDetTrbPri + "|" + cValToChar(nItem)

	// Adiciona sufixo se estiver em contexto "sem redução"
	If lSemRed
		cKey += "|SEMRED"
	EndIf
Return cKey

//-------------------------------------------------------------------
/*/{Protheus.doc} NPITryResultCache

Tenta recuperar resultado do cache L1 result-final.
Usado no início de xFisExecNPI para retorno antecipado.

@type Static Function
@author Rafael Oliveira
@since 04/02/2026
@version 12.1.2510

@param lEdicao, Logical, Se .T. ignora cache (modo edição)
@param cCacheKey, Character, Chave de cache pré-construída
@param nResultado, Numeric, Resultado (preenchido por referência se encontrar)

@return Logical, .T. se encontrou no cache (nResultado preenchido), .F. caso contrário
/*/
//-------------------------------------------------------------------
Static Function NPITryResultCache(lEdicao, cCacheKey, nResultado)
	Local lFound := .F.

	// Apenas usa cache quando não está em modo edição e tem chave
	If !lEdicao .And. !Empty(cCacheKey)
		If ValType(jNPIResultCache) == "J" .And. jNPIResultCache:HasProperty(cCacheKey)
			nResultado := jNPIResultCache[cCacheKey]
			lFound := .T.
		EndIf
	EndIf

Return lFound

//-------------------------------------------------------------------
/*/{Protheus.doc} NPITryTokenCache

Tenta recuperar valor do cache L1 por token (short-circuit).
Usado dentro do loop IsOperTrib para evitar reprocessamento de tokens repetidos.

@type Static Function
@author Rafael Oliveira
@since 04/02/2026
@version 12.1.2510

@param lEdicao, Logical, Se .T. ignora cache (modo edição)
@param cTributo, Character, Sigla do tributo (ex: VAL001)
@param cDetTrib, Character, Detalhe (BAS/ALQ/VAL)
@param nItem, Numeric, Número do item
@param nResultado, Numeric, Resultado (preenchido por referência se encontrar)

@return Logical, .T. se encontrou no cache (nResultado preenchido), .F. caso contrário
/*/
//-------------------------------------------------------------------
/*Static Function NPITryTokenCache(lEdicao, cTributo, cDetTrib, nItem, nResultado)
	Local lFound := .F.
	Local lUseSemRed := .F.
	Local cCacheKeyTok := ""

	// Apenas usa cache quando não está em modo edição
	If !lEdicao
		lUseSemRed := (LSEMREDUCAO .Or. lAliqSemRed)
		cCacheKeyTok := NPIBuildResultCacheKey(cTributo, cDetTrib, nItem, lUseSemRed)

		If ValType(jNPIResultCache) == "J" .And. jNPIResultCache:HasProperty(cCacheKeyTok)
			nResultado := jNPIResultCache[cCacheKeyTok]
			lFound := .T.
		EndIf
	EndIf

Return lFound*/

//-------------------------------------------------------------------
/*/{Protheus.doc} NPIStoreResultCache

Armazena resultado no cache L1 result-final.
Usado no final de xFisExecNPI após cálculo completo.

@type Static Function
@author Rafael Oliveira
@since 04/02/2026
@version 12.1.2510

@param lEdicao, Logical, Se .T. ignora cache (modo edição)
@param cCacheKey, Character, Chave do cache (SIGLA|DET|ITEM)
@param nResultado, Numeric, Valor a ser armazenado

@return Nil
/*/
//-------------------------------------------------------------------
Static Function NPIStoreResultCache(cCacheKey, nResultado)

	// Apenas armazena quando não está em modo edição
	If ValType(jNPIResultCache) == "J"
		jNPIResultCache[cCacheKey] := Max(0, nResultado)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOperGen

Função que verifica se é um operando que vai ter o total da formula vindo de alguma referencia

@param cFormTemp - Formula atual a ser processada
@param cDetTrib - Detalhe do tributo
@param cFormVal - fórmula NPI da regra de calculo

@return - .T. se for um operando com valor por referencia, .F. caso contrário

@author Douglas Dourado
@since 26/03/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function IsOperGen(cFormTemp , cDetTrib , cFormVal )
	Local cOperGen := "O:VALOR_INTEGRACAO" // Caso tenha mais operandos que vão retornar o valor total da formula, adicionar nessa variavel "O:VALOR_INTEGRACAO|O:OPER_FUTURO|etc" ...
Return cFormTemp $ cOperGen .and. cDetTrib == "VAL" .And. (cOperGen $ cFormVal)

//-------------------------------------------------------------------
/*/{Protheus.doc} NPIxREF

Função que realiza o de - para dos valores de operandos da fórmula com a
referencia correspondente.
Verifica se operando é composto e executa a fórmula dos próximos níveis também

@param cOperando - Operndo da fórmula
@param aNFItem - Array com todas as informações do item
@param nItem - Número do item processado
@param cTpOperando - Tipo de operação: 1 - base 2 - Aliquota 3 - Tributo 4 - URF 5 - Operadores primários

@return valor do operando.

@author Erick Dias
@since 17/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function NPIxREF(cOperando, aNFItem, nItem,jMapForm, lEdicao, nPosTrbProc, cDetTrbPri, aNfCab)

	Local nRet 			:= 0
	Local cFormTemp 	:= ""
	Local cIdTribAtu	:= ""
	Local cOperNorm		:= ""
	Local nRecnoOri		:= 0
	Local cTipNF		:= ""
	Local cTpCliFor		:= ""
	Local cMemoKey		:= ""
	Local lUseSemRed	:= .F.

	Default lEdicao 	:= .F.

//Se operando estiver vazio retorno 0
	If Empty(cOperando)
		Return nRet
	EndIf

	cIdTribAtu := GetCurTrbId(aNfItem, nItem, nPosTrbProc)
	cOperNorm := ResOperPriTrb(NrmTidOper(cOperando), cIdTribAtu, aNfItem, nItem)

	// Verifica se valor já foi calculado para este item
	// Cache L1 unificado: usa sufixo @SEMRED quando flags de recálculo ativos
	// Chave compartilhada: operando@item (ex: O:VAL_MERCADORIA@1)
	// Chave específica:    operando@item@tributo (ex: VAL:ICMS@1@5)
	// Chave sem redução:   operando@item@SEMRED (ex: O:VAL_MERCADORIA@1@SEMRED)
	If !lEdicao
		// Determina tipo de chave baseado no operando e flags de recalculação
		lUseSemRed := (LSEMREDUCAO .Or. lAliqSemRed)
		cMemoKey := NPICacheBuildKey(cOperNorm, nItem, nPosTrbProc, lUseSemRed)

		// Tenta L1 unificado (independente de flag)
		If ValType(jNPIResultCache) == "J" .And. jNPIResultCache:HasProperty(cMemoKey)
			Return jNPIResultCache[cMemoKey]
		EndIf
	EndIf

// Função que verifica se o prefixo é referênciado
	If IsPrefRef(cOperNorm)

		nRecnoOri	:= aNFItem[nItem][IT_RECORI]
		cTipNF		:= aNFCab[NF_TIPONF]
		cTpCliFor	:= aNFCab[NF_CLIFOR]

		If !Empty(nRecnoOri)

			nRet := VldPrefRef(cOperNorm, nRecnoOri, cTipNF, cTpCliFor)

		EndIf

// Se o primeiro dígito for número, significa que não é fórmula e sim valor fixo, então já retorno o valor diretamente
	ElseIf IsDigit(cOperNorm)
		nRet	:= Val(StrTran(cOperNorm, ",", "."))

//Aqui trata-se de um operando cadastrado na CIN, é u operando composto, por este motivo preciso chamar a função recursivamente para obter o valor
//Busco a fórmula no hashmap
//Verifica se a fórmula do operando foi encontrado no hashmap antes de continuar
	ElseIf IsOperComposto(cOperNorm) .Or. IsOperTrib(cOperNorm)
		If FindOper(jMapForm, cOperNorm, @cFormTemp)
			//Aqui estou chamando a função de forma recursiva para resolver o operando composto.
			nRet	:= xFisExecNPI(cFormTemp, aNFItem, nItem, jMapForm, lEdicao,, nPosTrbProc, cDetTrbPri, aNfCab, .F.)
		EndIF

	Else
		//Retorna o valor correspondente dos Operadores Primários
		nRet := ValOperPri(cOperNorm, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab, jMapForm)

	EndIF

	//-------------------------------------------------------------------------
	// MEMOIZAÇÃO: Armazena valor calculado em L1 unificado
	// Chave inclui sufixo @SEMRED se flags de recálculo estão ativos
	//-------------------------------------------------------------------------
	If !lEdicao .And. !Empty(cMemoKey) .And. ValType(jNPIResultCache) == "J"
		jNPIResultCache[cMemoKey] := nRet
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NrmOperPriTrb

Normaliza operandos primários tributários (O:) para operandos de tributo
(VAL:/BAS:/ALQ:) com base no mapeamento por IDTRIB -> SIGLA.

Exemplo:
- O:VAL_ICMS -> VAL:ICMS

Esta função não valida presença do tributo no item. Essa validação
é responsabilidade da função ResOperPriTrb().

@param cOperando - Operando a normalizar

@return cRet - Operando normalizado por TID/sigla ou original

@author Equipe Fiscal
@since 19/02/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function NrmOperPriTrb(cOperando)
	Local cRet      := AllTrim(cOperando)
	Local cDetTrib  := ""
	Local cIdTrib   := ""
	Local cSigla    := ""
	Local cOperNorm := ""
	Local cCacheKey := ""

	If Left(cRet, 2) != "O:"
		Return cRet
	EndIf

	cCacheKey := "PRI:" + cRet

	// Cache hit O(1)
	If ValType(jCacheNrmTid) == "J" .And. jCacheNrmTid:HasProperty(cCacheKey)
		Return jCacheNrmTid[cCacheKey]
	EndIf

	If MapOperPriTid(cRet, @cDetTrib, @cIdTrib)

		cSigla := GetSiglaTid(cIdTrib)
		If !Empty(cSigla)
				cOperNorm := cDetTrib + ":" + cSigla
				cRet := cOperNorm
		EndIf
	EndIf

	// Armazena resultado no cache (normalizado ou original)
	If ValType(jCacheNrmTid) == "J"
		jCacheNrmTid[cCacheKey] := cRet
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCurTrbId

Obtém o IDTRIB do tributo atualmente em processamento.

@param aNfItem     - Array com informações dos itens
@param nItem       - Item em processamento
@param nPosTrbProc - Posição do tributo em processamento

@return cIdTrib - IDTRIB do tributo em processamento
/*/
//-------------------------------------------------------------------
Static Function GetCurTrbId(aNfItem, nItem, nPosTrbProc)
	Local cIdTrib := ""

	If nPosTrbProc > 0
		cIdTrib := AllTrim(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_IDTRIB])
	EndIf

Return cIdTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMapTrbId

Obtém o IDTRIB do tributo dono da fórmula em mapeamento.

@param cTributo  - Sigla do tributo atual
@param jVldTribs - JsonObject sigla -> IDTRIB

@return cIdTrib - IDTRIB do tributo dono da fórmula
/*/
//-------------------------------------------------------------------
Static Function GetMapTrbId(cTributo, jVldTribs)
	Local cIdTrib := ""
	Local cSigla  := AllTrim(cTributo)

	If !Empty(cSigla) .And. ValType(jVldTribs) == "J" .And. jVldTribs:HasProperty(cSigla)
		cIdTrib := AllTrim(jVldTribs[cSigla])
	EndIf

Return cIdTrib

//-------------------------------------------------------------------
/*/{Protheus.doc} IsSelfOperPriTrb

Valida se um operando primário tributário referencia o mesmo IDTRIB
do tributo em processamento.

@param cOperando  - Operando primário (O:...)
@param cIdTribAtu - IDTRIB atual

@return lRet - .T. quando o operando referencia o mesmo tributo
/*/
//-------------------------------------------------------------------
Static Function IsSelfOperPriTrb(cOperando, cIdTribAtu)
	Local lRet     := .F.
	Local cDetTrib := ""
	Local cIdTrib  := ""

	If Left(cOperando, 2) == "O:" .And. !Empty(cIdTribAtu)
		If MapOperPriTid(cOperando, @cDetTrib, @cIdTrib)
			lRet := cIdTrib == AllTrim(cIdTribAtu)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ResMapPriTrb

Resolve operandos primários tributários apenas para a etapa de mapeamento,
preservando operandos auto-referenciados no formato legado O:.

@param cOperando  - Operando a resolver
@param cIdTribAtu - IDTRIB do tributo dono da fórmula

@return cRet - Operando resolvido para mapeamento
/*/
//-------------------------------------------------------------------
Static Function ResMapPriTrb(cOperando, cIdTribAtu)
	Local cRet := AllTrim(cOperando)

	If Left(cRet, 2) != "O:"
		Return cRet
	EndIf

	If !IsSelfOperPriTrb(cRet, cIdTribAtu)
		cRet := NrmOperPriTrb(cRet)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ResOperPriTrb

Resolve operando primário tributário para execução, respeitando contexto do item.

Regra:
- Converte O: -> VAL:/BAS:/ALQ: apenas se o tributo convertido estiver
  efetivamente presente no item (GetPosTrib > 0).
- Caso contrário, mantém operando original para preservar fallback legado.

@param cOperando  - Operando a resolver
@param cIdTribAtu - IDTRIB do tributo em processamento
@param aNfItem    - Array com informações dos itens
@param nItem      - Item em processamento

@return cRet - Operando resolvido para execução

@author Equipe Fiscal
@since 19/02/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function ResOperPriTrb(cOperando, cIdTribAtu, aNfItem, nItem)
	Local cRet := AllTrim(cOperando)
	Local cOperNorm := ""
	Local cSigla := ""

	If Left(cRet, 2) != "O:"
		Return cRet
	EndIf

	If IsSelfOperPriTrb(cRet, cIdTribAtu)
		Return cRet
	EndIf

	cOperNorm := NrmOperPriTrb(cRet)
	If IsOperTrib(cOperNorm)
		cSigla := GetTribOper(cOperNorm)
		If GetPosTrib(cSigla, aNfItem, nItem) > 0
			cRet := cOperNorm
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MapOperPriTid

Mapeia operandos primários tributários para detalhe e IDTRIB padrão.

@param cOperando - Operando primário (O:...)
@param cDetTrib  - Retorno por referência: BAS/ALQ/VAL
@param cIdTrib   - Retorno por referência: IDTRIB

@return lRet - .T. se houver mapeamento, .F. caso contrário

@author Equipe Fiscal
@since 19/02/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function MapOperPriTid(cOperando, cDetTrib, cIdTrib)
	Local lRet := .T.

	Default cDetTrib := ""
	Default cIdTrib  := ""

	Do Case
	Case cOperando == PVALORI + "VAL_ICMS"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_ICMS

	/*Case cOperando == PVALORI + "VAL_ICM_TRIBUTADO"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_ICMS*/

	Case cOperando == PVALORI + "BASE_ICMS"
		cDetTrib := "BAS"
		cIdTrib  := TRIB_ID_ICMS

	Case cOperando == PVALORI + "ALQ_ICMS"
		cDetTrib := "ALQ"
		cIdTrib  := TRIB_ID_ICMS

	Case cOperando == PVALORI + "VAL_DIFAL"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_DIFAL

	Case cOperando == PVALORI + "VAL_FECP"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_FECPIC

	Case cOperando == PVALORI + "VAL_FCPDIF"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_FCPCMP

	Case cOperando == PVALORI + "VAL_PS2"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_PIS

	Case cOperando == PVALORI + "VAL_CF2"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_COF

	Case cOperando == PVALORI + "VAL_II"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_II

	Case cOperando == PVALORI + "ICMS_RETIDO"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_ICMSST

	Case cOperando == PVALORI + "ALQ_ICMSST"
		cDetTrib := "ALQ"
		cIdTrib  := TRIB_ID_ICMSST

	/*Case cOperando == PVALORI + "VAL_IPI_TRIBUTADO"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_IPI*/

	Case cOperando == PVALORI + "VAL_ISS"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_ISS

	/*Case cOperando == PVALORI + "VAL_ISS_TRIBUTADO"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_ISS*/

	Case cOperando == PVALORI + "ALQ_CPRB"
		cDetTrib := "ALQ"
		cIdTrib  := TRIB_ID_CPRB

	Case cOperando == PVALORI + "VAL_CPRB"
		cDetTrib := "VAL"
		cIdTrib  := TRIB_ID_CPRB

	Otherwise
		lRet := .F.
	EndCase	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValOperPri

Função que recebe operando primário e retorna seu respectivo valor
contino no aNfItem

@param cOperando   - Operando que será procurado na CIN
@param aNFItem     - Array com todas as informações dos intens
@param nItem       - Número do item processado

@return - nRet - Valor do operando solicitadp

@author Erick Dias
@since 19/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------\
Static Function ValOperPri(cOperando, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab, jMapForm)

	Local nRet	:= 0
	Local nPos 	:= 0
	Local nVal  := 0
	Local nPosUltAqui	:= 0
	Local nPosUltAqEstr := 0
	Local cUmMed	:= aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_BAS][TG_BAS_UM]
	Local dDataIni := CTOD("//")
	Local nBaseAtual := 0
	Local nBaseBrtAcum := 0

//Primeiro verifico se é operando primario/valor de origem
	If SubString(cOperando,1,2) == xFisTpForm("0")
		//--------------------------------------------------------------------------------------------
		//Abaixo faço o de-para dos operandos primários com as referencias correspondentes da MATXFIS
		//--------------------------------------------------------------------------------------------
		If cOperando ==  PVALORI + "VAL_MERCADORIA"
			nRet	:= aNFItem[nItem][IT_VALMERC]

		ElseIf cOperando == PVALORI + "QUANTIDADE"
			//Obtenho a quantidade utilizando função auxiliar, que analisará se na regra foi especificada alguma unidade de medida
			nRet := GetQtdItem(aNFItem, nItem, cUmMed)

		ElseIf cOperando == PVALORI + "VAL_CONTABIL"
			nRet	:= aNfItem[nItem][IT_LIVRO][LF_VALCONT]

		ElseIf cOperando == PVALORI + "VAL_CRED_PRESU"
			nRet	:= aNfItem[nItem][IT_LIVRO][LF_CRDPRES]

		ElseIf cOperando == PVALORI + "BASE_ICMS"
			nRet	:= aNfItem[nItem][IT_BASEICM]

		ElseIf cOperando == PVALORI + "BASE_ORIG_ICMS"
			nRet	:= aNfItem[nItem][IT_BICMORI]

		ElseIf cOperando == PVALORI + "VAL_ICMS"
			nRet	:= aNfItem[nItem][IT_VALICM]

		ElseIf cOperando == PVALORI + "VAL_ICM_TRIBUTADO" .And. ! aNfItem[nItem][IT_LIVRO][LF_TIPO] == "S"
			nRet	:= aNfItem[nItem][IT_LIVRO][LF_VALICM]

		ElseIf cOperando == PVALORI + "VAL_IPI_TRIBUTADO"
			nRet	:= aNfItem[nItem][IT_LIVRO][LF_VALIPI]

		ElseIf cOperando == PVALORI + "VAL_PS2"
			nRet	:= aNfItem[nItem][IT_VALPS2]

		ElseIf cOperando == PVALORI + "VAL_CF2"
			nRet	:= aNfItem[nItem][IT_VALCF2]

		ElseIf cOperando == PVALORI + "VAL_DIFAL"
			nRet	:= aNfItem[nItem][IT_DIFAL]

		ElseIf cOperando == PVALORI + "VAL_II"
			nRet	:= aNfItem[nItem][IT_VALII]

		ElseIf cOperando == PVALORI + "VAL_FECP"
			nRet	:= aNfItem[nItem][IT_VALFECP]

		ElseIf cOperando == PVALORI + "VAL_FCPDIF"
			nRet	:= aNfItem[nItem][IT_VFCPDIF]

		ElseIf cOperando == PVALORI + "VAL_ISS"
			nRet	:= aNfItem[nItem][IT_VALISS]

		ElseIf cOperando == PVALORI + "VAL_ISS_TRIBUTADO" .And. aNfItem[nItem][IT_LIVRO][LF_TIPO] == "S"
			nRet	:= aNfItem[nItem][IT_LIVRO][LF_VALICM]

		ElseIf cOperando == PVALORI + "FRETE"
			nRet	:= aNfItem[nItem][IT_FRETE]

		ElseIf cOperando == PVALORI + "VAL_DUPLICATA"
			nRet	:= aNfItem[nItem][IT_BASEDUP]

		ElseIf cOperando == PVALORI + "TOTAL_ITEM"
			nRet	:= aNfItem[nItem][IT_TOTAL]

		ElseIf cOperando == PVALORI + "ALQ_ICMS" .AND. aNfItem[nItem][IT_BASEICM] > 0
			nRet	:= aNfItem[nItem][IT_ALIQICM]

		ElseIf cOperando == PVALORI + "ALQ_CREDPRESU" .AND. aNfItem[nItem,IT_LIVRO,LF_CRDPRES] > 0
			nRet	:= aNFItem[nItem][IT_TS][TS_CRDPRES]

		ElseIf cOperando == PVALORI + "ALQ_ICMSST" .AND. aNfItem[nItem][IT_BASESOL] > 0
			nRet	:= aNFItem[nItem][IT_ALIQSOL]

		ElseIf cOperando == PVALORI + "DESCONTO"
			nRet	:= (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT])

		ElseIf cOperando == PVALORI + "SEGURO"
			nRet	:= aNfItem[nItem][IT_SEGURO]

		ElseIf cOperando == PVALORI + "DESPESAS"
			nRet	:= aNfItem[nItem][IT_DESPESA]

		ElseIf cOperando == PVALORI + "VAL_FRETE_PAUTA"
			nRet	:= aNfItem[nItem][IT_VLR_FRT]

		ElseIf cOperando == PVALORI + "ICMS_DESONERADO"
			nRet	:= aNfItem[nItem][IT_DEDICM]

		ElseIf cOperando == PVALORI + "DESC_ICMS_ZF"
			nRet	:= aNfItem[nItem][IT_DESCZF] - (aNfItem[nItem][IT_DESCZFPIS] + aNfItem[nItem][IT_DESCZFCOF])

		ElseIf cOperando == PVALORI + "DESC_PIS_ZF"
			nRet	:= aNfItem[nItem][IT_DESCZFPIS]

		ElseIf cOperando == PVALORI + "DESC_COF_ZF"
			nRet	:= aNfItem[nItem][IT_DESCZFCOF]

		ElseIf cOperando == PVALORI + "DESC_TOTAL_ZF"
			nRet	:= aNfItem[nItem][IT_DESCZF]

		ElseIf cOperando == PVALORI + "BASE_INTEGRACAO"

			nRet 	:= GetTaxRef( 'BSE' , aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][12] , aNfItem[nItem] )
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_BAS][TG_BAS_OPINTEG] := .T.
			aNfItem[nItem][IT_NORECAL] := "S"

		ElseIf cOperando == PVALORI + "ALIQUOTA_INTEGRACAO"

			nRet 	:= GetTaxRef( 'ALQ' , aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][12] , aNfItem[nItem] )
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ALQ][TG_ALQ_OPINTEG] := .T.
			aNfItem[nItem][IT_NORECAL] := "S"

		ElseIf cOperando == PVALORI + "VALOR_INTEGRACAO"

			nRet 	:= GetTaxRef( 'VAL' , aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][12] , aNfItem[nItem] )
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_OPINTEG] := .T.
			aNfItem[nItem][IT_NORECAL] := "S"
			TeleInteg("O:VALOR_INTEGRACAO")

		ElseIf cOperando == PVALORI + "ICMS_RETIDO"
			nRet	:= aNfItem[nItem][IT_VALSOL]

		ElseIf cOperando == PVALORI + "DEDUCAO_SUBEMPREITADA"
			nRet	:= aNfItem[nItem][IT_ABVLISS]

		ElseIf cOperando == PVALORI + "DEDUCAO_MATERIAIS"
			nRet	:= aNfItem[nItem][IT_ABMATISS]

		ElseIf cOperando == PVALORI + "DEDUCAO_INSS_SUB"
			nRet	:= aNfItem[nItem][IT_ABSCINS]

		ElseIf cOperando == PVALORI + "DEDUCAO_INSS"
			nRet	:= aNfItem[nItem][IT_ABVLINSS]

		ElseIf cOperando == PVALORI + "BASE_IPI_TRANSFERENCIA"
			nRet	:= aNfItem[nItem][IT_PRCCF]

		ElseIf cOperando == PVALORI + "VAL_MANUAL_MAX"
			nRet 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_VL_MAX]

		ElseIf cOperando == PVALORI + "VAL_MANUAL_MIN"
			nRet 	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_VL_MIN]

		ElseIf cOperando == PVALORI + "ALQ_SIMPLES_NACIONAL_ISS"
			If Len(aNfCab[NF_ALIQSN])>0
				If !Empty(AllTrim(aNfItem[nItem][IT_PRD][SB_B1GRUPO]))
					nPos := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_GRUPO]) == AllTrim(aNfItem[nItem][IT_PRD][SB_B1GRUPO])})

				ElseIf !Empty(AllTrim(aNfItem[nItem][IT_CODISS]))
					nPos := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_CODISS]) == AllTrim(aNfItem[nItem][IT_CODISS])})

				EndIf
				If nPos > 0
					nRet := aNfCab[NF_ALIQSN][nPos][SN_ALIQ]
				EndIf
			EndIf

		ElseIf cOperando == PVALORI + "ALQ_SIMPLES_NACIONAL_ICMS"
			If Len(aNfCab[NF_ALIQSN])>0 .And. !Empty(AllTrim(aNfItem[nItem][IT_CF]))
				nPos := aScan(aNfCab[NF_ALIQSN], {|x| AllTrim(x[SN_CFOP]) == AllTrim(aNfItem[nItem][IT_CF])})

				If nPos > 0
					nRet := aNfCab[NF_ALIQSN][nPos][SN_ALIQ]
				EndIf
			EndIf

		ElseIf cOperando == PVALORI + "CUSTO_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_CUSTO,		#02
				nRet	:= aPesqSD1[nPosUltAqui][2]
			EndIF

		ElseIf cOperando == PVALORI + "DESCONTO_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VALDESC,	#03
				nRet	:=  aPesqSD1[nPosUltAqui][3]
			EndIF

		ElseIf cOperando == PVALORI + "MVA_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_MARGEM,  	#04
				nRet	:= 1 + (aPesqSD1[nPosUltAqui][4]/ 100)
			EndIF

		ElseIf cOperando == PVALORI + "QUANTIDADE_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_QUANT,		#05
				nRet	:= aPesqSD1[nPosUltAqui][5]
				//Atualiza a referência
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
			EndIF

		ElseIf cOperando == PVALORI + "VLR_UNITARIO_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VUNIT,  	#06
				nRet	:= aPesqSD1[nPosUltAqui][6]
			EndIF
		ElseIf cOperando == PVALORI + "VLR_ANTECIPACAO_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VALANTI, 	#07
				nRet	:= aPesqSD1[nPosUltAqui][7]
			EndIF
		ElseIf cOperando == PVALORI + "ICMS_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VALICM,  	#08
				nRet	:= aPesqSD1[nPosUltAqui][8]
				//Atualiza a referência
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
			EndIF
		ElseIf cOperando == PVALORI + "IND_AUXILIAR_FECP_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_FCPAUX,;	#09
				nRet	:= aPesqSD1[nPosUltAqui][9]
			EndIF

		ElseIf cOperando == PVALORI + "BASE_ICMSST_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BRICMS, 	#10
				nRet	:= aPesqSD1[nPosUltAqui][10]
			EndIF

		ElseIf cOperando == PVALORI + "ALQ_ICMSST_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ALIQSOL, 	#11
				nRet	:= aPesqSD1[nPosUltAqui][11]
			EndIF

		ElseIf cOperando == PVALORI + "VLR_ICMSST_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ICMSRET, 	#12
				nRet	:= aPesqSD1[nPosUltAqui][12]
			EndIF

		ElseIf cOperando == PVALORI + "BASE_FECP_ST_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BSFCPST,;	#13
				nRet	:= aPesqSD1[nPosUltAqui][13]
			EndIF

		ElseIf cOperando == PVALORI + "ALQ_FECP_ST_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ALFCPST,	#14
				nRet	:= aPesqSD1[nPosUltAqui][14]
			EndIF

		ElseIf cOperando == PVALORI + "VLR_FECP_ST_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VFECPST, 	#15
				nRet	:= aPesqSD1[nPosUltAqui][15]
			EndIF
		ElseIf cOperando == PVALORI + "BASE_ICMSST_REC_ANT_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BASNDES, 	#16
				nRet	:= aPesqSD1[nPosUltAqui][16]
			EndIF

		ElseIf cOperando == PVALORI + "ALQ_ICMSST_REC_ANT_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ALQNDES,;	#17
				nRet	:= aPesqSD1[nPosUltAqui][17]
			EndIF

		ElseIf cOperando == PVALORI + "VLR_ICMSST_REC_ANT_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_ICMNDES,	#18
				nRet	:= aPesqSD1[nPosUltAqui][18]
			EndIF

		ElseIf cOperando == PVALORI + "BASE_FECP_REC_ANT_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BFCPANT, 	#19
				nRet	:= aPesqSD1[nPosUltAqui][19]
			EndIF

		ElseIf cOperando == PVALORI + "ALQ_FECP_REC_ANT_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_AFCPANT, 	#20
				nRet	:= aPesqSD1[nPosUltAqui][20]
			EndIF

		ElseIf cOperando == PVALORI + "VLR_FECP_REC_ANT_ULT_AQUI"

			//Posiciona a última aquisição para obter o valor do custo
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_VFCPANT		#21
				nRet	:= aPesqSD1[nPosUltAqui][21]
			EndIF

		ElseIf cOperando == PVALORI + "BASE_ICMS_ULT_AQUI"

			//Posiciona a última aquisição para obter a base do icms
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_BASEICM		#22
				nRet	:= aPesqSD1[nPosUltAqui][22]
				//Atualiza a referência
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
			EndIF

		ElseIf cOperando == PVALORI + "ALQ_ICMS_ULT_AQUI"

			//Posiciona a última aquisição para obter a alíquota do icms
			If (nPosUltAqui	:= GetUltAqui(aNfItem[nItem][IT_PRODUTO]) ) > 0
				//(cAliasQry)->D1_PICM		#23
				nRet	:= aPesqSD1[nPosUltAqui][23]
				//Atualiza a referência
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ULT_AQUI] := .T.
			EndIF

		ElseIf cOperando == PVALORI + "BASE_ICMSST_REC_ANT"
			//Base do ICMS-ST Recolhido Anteriormente. Esse operando será carregado somente no documento de entrada quando o campo relacionado for preenchido manualmente.
			nRet := aNfItem[nItem][IT_BASNDES]

		ElseIf cOperando == PVALORI + "ALQ_ICMSST_REC_ANT"
			//Alíquota do ICMS-ST Recolhido Anteriormente. Esse operando será carregado somente no documento de entrada quando o campo relacionado for preenchido manualmente.
			nRet := aNfItem[nItem][IT_ALQNDES]

		ElseIf cOperando == PVALORI + "VLR_ICMSST_REC_ANT"
			//Valor do ICMS-ST Recolhido Anteriormente. Esse operando será carregado somente no documento de entrada quando o campo relacionado for preenchido manualmente.
			nRet := aNfItem[nItem][IT_ICMNDES]

		ElseIf cOperando == PVALORI + "BASE_FECP_REC_ANT"
			//Base do FECP Recolhido Anteriormente. Esse operando será carregado somente no documento de entrada quando o campo relacionado for preenchido manualmente.
			nRet := aNfItem[nItem][IT_BFCPANT]

		ElseIf cOperando == PVALORI + "ALQ_FECP_REC_ANT"
			//Alíquota do FECP Recolhido Anteriormente. Esse operando será carregado somente no documento de entrada quando o campo relacionado for preenchido manualmente.
			nRet := aNfItem[nItem][IT_AFCPANT]

		ElseIf cOperando == PVALORI + "VLR_FECP_REC_ANT"
			//Base do FECP Recolhido Anteriormente. Esse operando será carregado somente no documento de entrada quando o campo relacionado for preenchido manualmente.
			nRet := aNfItem[nItem][IT_VFCPANT]

		ElseIf cOperando == PVALORI + "ZERO"
			nRet := 0
			//Referência para informar que o tributo tem alíquota ou base configurado na formula com valor zero
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_VL_ZERO] := .T.

		Elseif cOperando == PVALORI + "ALQ_CPRB"

			nRet := aNfItem[nItem][IT_PRD][SB_CG1_ALIQ]

		Elseif cOperando == PVALORI + "VLR_ICMS_ULT_AQUI_ESTRUTURA"

			//Posiciona a última aquisição verificando os componentes do produto para obter o valor do ICMS.
			If (nPosUltAqEstr	:= GetCompUltAq(aNfItem[nItem][IT_PRODUTO],aNfCab,aNfItem,nItem,,,,,,1)) > 0
				nRet	:= aPesqEstr[nPosUltAqEstr][2]//ainda preciso definir a posição do retorno da query
				//Atualiza Referencia
				aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ESTR_ULT_AQUI] := .T.
			EndIF

		Elseif cOperando == PVALORI + "BASE_IPI_RASTRO_ORIG"

			nRet := RetIPIRastro(aNfItem[nItem][IT_LOTE],aNfItem[nItem][IT_SUBLOTE],aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT])

			//Valor do pedágio que pode ser agregado a base de impostos conforme o comportamento legado do campo F4_AGRPEDG
		ElseIf cOperando == PVALORI + "VLR_PEDAGIO"
			nRet := aNfItem[nItem][IT_VALPEDG]

		ElseIf cOperando == PVALORI + "VLR_COMISSAO_VENDA_VEICULO"
			nRet := aNfItem[nItem][IT_COMISVEI]

		ElseIf cOperando == PVALORI + "VLR_PRECO_SUGERIDO_VENDA_VEI"
			nRet := aNfItem[nItem][IT_PRCSUGE]

		ElseIf cOperando == PVALORI + "VAL_CPRB"
			nRet := aNfItem[nItem][IT_VALCPB]

		EndIf

//Se não verifico se é operador de índice de cálculo
	ElseIf SubString(cOperando,1,2) == xFisTpForm("9")
		//Se a origem da execução deste operando pertencer a uma fórmula de alíquota, então não dividirei por 100.
		//Se pertencer a fórmula de base de cálculo ou valor, então dividirei por 100.
		//Verifica operandos dos índices de cálculos
		If cOperando == PINDCALC + "MVA"
			IF aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_MVA] > 0
				nRet	:= 1 + (aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_MVA] / 100)
			EndIF

		ElseIf cOperando == PINDCALC + "INDICE_AUXILIAR_MVA"
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_AUX_MVA] / Iif(cDetTrbPri == "ALQ", 1, 100 )

		ElseIf cOperando == PINDCALC + "MAJORACAO"
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_MAJ] / Iif(cDetTrbPri == "ALQ", 1, 100 )

		ElseIf cOperando == PINDCALC + "INDICE_AUXILIAR_MAJORACAO"
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_AUX_MAJ] / Iif(cDetTrbPri == "ALQ", 1, 100 )

		ElseIf cOperando == PINDCALC + "PAUTA"
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_PAUTA]

		ElseIf cOperando == PINDCALC + "ALIQ_NCM"
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALIQTR]

		ElseIf cOperando == PINDCALC + "ALQ_SERVICO"

			//Primiro adiciono alíqutoa padrão da lei complementar
			nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALQ_SERV_LEI_COMPL] / Iif(cDetTrbPri == "ALQ", 1, 100 )

			//Verifico se alíquota do município do prestador está preenchida, se estiver ela sobreescreverar alíquota padrão
			IF aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALQ_SERV] > 0
				nRet	:= aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_ALQ_SERV] / Iif(cDetTrbPri == "ALQ", 1, 100 )
			EndIF

		ElseIf cOperando == PINDCALC + "ALIQ_TAB_PROGRESSIVA"

			//Se encontrou a tabela progressiva correspondente
			IF AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG] )}) > 0
				nRet	:= PosTabPrg(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG], aNFItem, nItem, nPosTrbProc, aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_BASE] )[1]
			EndIF

		ElseIf cOperando == PINDCALC + "DED_TAB_PROGRESSIVA"

			//Se encontrou a tabela progressiva correspondente
			IF AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG] )}) > 0
				nRet	:= PosTabPrg( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG] , aNFItem, nItem, nPosTrbProc, aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_BASE])[2]
			EndIF

		ElseIf cOperando == PINDCALC + "DED_DEPENDENTES"

			IF (nPos := AScan(aTabDep, { |x| Alltrim(x[1]) == Alltrim( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_DED_DEP] )})) > 0
				//Obtem o valor possível de dedução por participante
				nSldDep  := aTabDep[nPos][2] * aNfCab[NF_NUMDEP]

				//Se houver valor para dedução seguirá o fluxo
				If nSldDep > 0

					dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))

					//Busca informações das deduções já utilizadas para o participante e no dia
					//E aqui irei subtrair o valor de dedução já utilizada caso houver
					nSldDep -= ValNfAnt(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA], aNfCab[NF_OPERNF], aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA], dDataIni, aNfCab[NF_DTEMISS], "DEDDEP", aTabDep[nPos][3])

					nSldDep -= ValDepOutItem(aNfItem, nItem, aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_SIGLA])

					//Retorna o valor de dedução
					nRet	:= nSldDep

				EndIF

			EndIF

		ElseIf cOperando == PINDCALC + "REND_TRIB_OUTROS_ITENS"
			// Totaliza os rendimentos tributáveis dos outros itens
			nRet := FisTotRefTrb( aNfItem, TRIB_ID_RENDTRIB , nItem, TG_IT_VALOR )

		ElseIf cOperando == PINDCALC + "REND_TRIB_MEN" // Rendimento Tributável Mensal Acumulado

			dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))

			nRet := FisSE2Acum(cFilAnt , aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA] , dDataBase , "P" , "1" , "BASE" , "IRF" , dDataIni , aNfCab[NF_DTEMISS] , .T. , aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_FIN] )

		ElseIf cOperando == PINDCALC + "BASE_INSS_TRIB_MEN" // Base de cálculo do INSS mensal acumulado

			dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))

			nRet := FisSE2Acum(cFilAnt , aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA] , dDataBase , "P" , "1" , "BASE" , "INSS" , dDataIni , aNfCab[NF_DTEMISS] , .F. , aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_FIN] )

		ElseIf cOperando == PINDCALC + "INSS_TRIB_MEN" // Valor do INSS mensal acumulado

			dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))

			nRet := FisSE2Acum(cFilAnt , aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA] , dDataBase , "P" , "1" , "VALOR" , "INSS" , dDataIni , aNfCab[NF_DTEMISS] , .F. , aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_FIN] )

		ElseIf cOperando == PINDCALC + "INSS_OUTROS_ITENS"
			// Totaliza o INSS dos outros itens
			nRet := FisTotRefTrb( aNfItem, TRIB_ID_INSS , nItem, TG_IT_VALOR )

		ElseIf cOperando == PINDCALC + "IRRF_TRIB_MEN"

			dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))

			nRet := FisSE2Acum(cFilAnt , aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA] , dDataBase , "P" , "1" , "VALOR" , "IRF" , dDataIni , aNfCab[NF_DTEMISS] , .T. , aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_FIN] )

		ElseIf cOperando == PINDCALC + "PROP_REND_TRIB"

			// verifico se foi calculado o tributo RENDME (rendimento tributável) para implementar o valor
			if (nPos := aScan(aNfItem[nItem][IT_TRIBGEN],{ |aTrib| AllTrim(aTrib[TG_IT_IDTRIB]) == TRIB_ID_RENDTRIB })) > 0
				If ( ValType(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR]) == "N" .And. aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR] == 0 )
					// executa a fórmula de cálculo do valor do tributo e preenche os valores do tributo em IT_TRIBGEN
					xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_COD_FOR],;
								aNFItem, nItem, jMapForm, Nil, Nil, nPos, Nil, aNfCab)
				EndIf
			Endif
			// Retorna a proporção do rendimento tributável do item atual com relação ao rendimento tributável dos outros itens
			nRet := FisPropRefTrib( aNfItem, nItem, TRIB_ID_RENDTRIB, TG_IT_VALOR )

		ElseIf cOperando == PINDCALC + "DED_SIMPL"

			nRet := aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_DED_SIM_CAD] // Valor preenchido ao carregar a tabela progressiva (CIQ_DEDSIR)
			aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_DED_SIM_VAL] := nRet

		ElseIf cOperando == PINDCALC + "DED_ADIC_TAB_PROG"

			dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))
			// faz a base acumulada conforme o rendimento tributável das notas anteriores
			nBaseBrtAcum := FisSE2Acum(cFilAnt , aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA] , dDataBase , "P" , "1" , "BASE" , "IRF" , dDataIni , aNfCab[NF_DTEMISS] , .T. , aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_FIN] )

			// verifico se foi calculado o tributo RENDME (rendimento tributável) para implementar o valor
			if (nPos := aScan(aNfItem[nItem][IT_TRIBGEN],{ |aTrib| AllTrim(aTrib[TG_IT_IDTRIB]) == TRIB_ID_RENDTRIB })) > 0
				// caso o RENDME não tenha sido calculado preciso forçar o cálculo aqui para evitar problemas quando for definir qual fator usar
				If ( ValType(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR]) == "N" .And. aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR] == 0 )
					// executa a fórmula de cálculo do valor do tributo e preenche os valores do tributo em IT_TRIBGEN
					xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_COD_FOR],;
								aNFItem, nItem, jMapForm, Nil, Nil, nPos, Nil, aNfCab)
				EndIf
				nVal  := aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR]
			Endif

			// Total do rendimento tributável da nota atual e notas anteriores
			nBaseAtual := (nVal + nBaseBrtAcum +  FisTotRefTrb( aNfItem, TRIB_ID_RENDTRIB , nItem, TG_IT_VALOR ) )

			// Busca o valor max. reducao que se enquadra na tabela progressiva adicional (CI2)
			nRet	:= PosTabAdic(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG], nBaseAtual )[2]

		ElseIf cOperando == PINDCALC + "FATOR_DED_ADIC_TAB_PROG"

			dDataIni := CtoD("01/"+StrZero(Month(aNfCab[NF_DTEMISS]),2)+"/"+Str(Year(aNfCab[NF_DTEMISS])))
			// faz a base acumulada conforme o rendimento tributável das notas anteriores
			nBaseBrtAcum := FisSE2Acum(cFilAnt , aNfCab[NF_CODCLIFOR], aNfCab[NF_LOJA] , dDataBase , "P" , "1" , "BASE" , "IRF" , dDataIni , aNfCab[NF_DTEMISS] , .T. , aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_FIN] )

			// verifico se foi calculado o tributo RENDME (rendimento tributável) para implementar o valor
			If (nPos := aScan(aNfItem[nItem][IT_TRIBGEN],{ |aTrib| AllTrim(aTrib[TG_IT_IDTRIB]) == TRIB_ID_RENDTRIB })) > 0
				// caso o RENDME não tenha sido calculado preciso forçar o cálculo aqui para evitar problemas quando for definir qual fator usar
				If ( ValType(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR]) == "N" .And. aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR] == 0 )
					// executa a fórmula de cálculo do valor do tributo e preenche os valores do tributo em IT_TRIBGEN
					xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_COD_FOR],;
								aNFItem, nItem, jMapForm, Nil, Nil, nPos, Nil, aNfCab)
				EndIf
				nVal  := aNfItem[nItem][IT_TRIBGEN][nPos][TG_IT_VALOR]
			Endif

			// Total do rendimento tributável da nota atual e notas anteriores
			nBaseAtual := (nVal + nBaseBrtAcum +  FisTotRefTrb( aNfItem, TRIB_ID_RENDTRIB , nItem, TG_IT_VALOR ) )

			// Busca o fator se enquadra na tabela progressiva adicional (CI2)
			nRet	:= PosTabAdic(aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_TAB_PROG], nBaseAtual )[1]

		ElseIf cOperando == PINDCALC + "PERC_REDUCAO_BASE"
		/*
		Aqui retornarei o percentual de redução de base de cálculo
		Aqui para faciliar a conta farei a conversão. EXemplo:		

		Percentual de redução de 10%
		1 - (10 / 100) -> 1 - 0,1 -> 0,9
		O retorno será 0,9, que corresponde a parcela a ser tributada.
		Realizo isso aqui para não pedir ao usuário digitar o percentual invertido.
		*/
					IF LSEMREDUCAO
						nRet	:= 1
					Else
						nRet	:= 1 - (aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] / 100)
					EndIF
				ElseIf cOperando == PINDCALC + "PERC_REDUCAO_ALIQ"
		/*
		Aqui retornarei o percentual de redução de alíquota
		Aqui para faciliar a conta farei a conversão. EXemplo:

		Percentual de redução de 10%
		1 - (10 / 100) -> 1 - 0,1 -> 0,9
		O retorno será 0,9, que corresponde a parcela a ser tributada.
		Realizo isso aqui para não pedir ao usuário digitar o percentual invertido.
		*/
					IF lAliqSemRed
						nRet	:= 1
					Else
						nRet	:= 1 - (aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ALQ][TG_ALQ_REDUCAO] / 100)
					EndIF
				ElseIf cOperando == PINDCALC + "INDICE_AUXILIAR_FCA"
					nRet	:= LoadFCA(aNfCab, aNFItem, nItem) //Indicadores Econômicos FCA

				ElseIf cOperando == PINDCALC + "PERC_DIFERIMENTO" // Percentual de diferimento contido na regra de escrituração VALOR_DIFERIMENTO

					If aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ESCR][RE_PERCDIF] == 100
						nRet := 1
					ElseIf aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ESCR][RE_PERCDIF] > 0
						nRet	:= 1 - (aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ESCR][RE_PERCDIF]/100)
					Else
						nRet	:= 0
					Endif

				EndIF

			ELSEIF SubString(cOperando,1,2) == xFisTpForm("4")  //Valida se Operando é URF
				nRet := aNFItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REGRA_ALQ][TG_ALQ_VALURF]
			EndIF

			Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} REFxOPER

Função que faz o De - Para da referência com operando

@param cCampo   - Referência da MATXFIS

@author Erick Dias
@since 03/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
/* Conforme o problema relatado na issue DSERFISE-5574 foi implementado a função CargOper e LerJson
portanto a função abaixo ficou obsoleta.

Static Function REFxOPER(cCampo)

Local cRet	:= ""
Local cPrefixo	:= xFisTpForm("0")

If cCampo == "IT_FRETE"
	cRet := cPrefixo + "FRETE"

ElseIf cCampo == "IT_VALMERC"
	cRet := cPrefixo + "VAL_MERCADORIA"

ElseIf cCampo == "IT_BASEICM"
	cRet := cPrefixo + "BASE_ICMS"

ElseIf cCampo == "IT_BICMORI"
	cRet := cPrefixo + "BASE_ORIG_ICMS"

ElseIf cCampo == "IT_VALICM"
	cRet := cPrefixo + "VAL_ICMS"

ElseIf cCampo == "IT_BASEDUP"
	cRet := cPrefixo + "VAL_DUPLICATA"

ElseIf cCampo == "IT_TOTAL"
	cRet := cPrefixo + "TOTAL_ITEM"

ElseIf cCampo == "IT_ALIQICM"
	cRet := cPrefixo + "ALQ_ICMS"

ElseIf cCampo == "IT_ALIQSOL"
	cRet := cPrefixo + "ALQ_ICMSST"

ElseIf cCampo == "IT_SEGURO"
	cRet := cPrefixo + "SEGURO"

ElseIf cCampo == "IT_DESPESA"
	cRet := cPrefixo + "DESPESAS"

ElseIf cCampo == "IT_DEDICM"
	cRet := cPrefixo + "ICMS_DESONERADO"

ElseIf cCampo == "IT_VALSOL"
	cRet := cPrefixo + "ICMS_RETIDO"

ElseIf cCampo == "IT_QUANT"
	cRet := cPrefixo + "QUANTIDADE"

ElseIf cCampo == "IT_DESCONTO" .OR. cCampo == "IT_QIT_DESCTOTUANT"
	cRet := cPrefixo + "DESCONTO"

ElseIf cCampo == "IT_ABVLISS"
	cRet	:= cPrefixo + "DEDUCAO_SUBEMPREITADA"

ElseIf cCampo == "IT_ABMATISS"
	cRet	:= cPrefixo + "DEDUCAO_MATERIAIS"

ElseIf cCampo == "IT_ABSCINS"
	cRet	:= cPrefixo + "DEDUCAO_INSS_SUB"

ElseIf cCampo == "IT_ABVLINSS"
	cRet	:= cPrefixo + "DEDUCAO_INSS"

ElseIf cCampo == "IT_PRCCF"
	cRet	:= cPrefixo + "BASE_IPI_TRANSFERENCIA"

ElseIf cCampo == "LF_VALCONT"
	cRet	:= cPrefixo + "VAL_CONTABIL"
EndIF

Return cRet
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQtdItem

Função auxiliar que retorna a quantidade do item, em função da unidade de
medida informada na regra de base de alíquota, claro além de realizar a
conversão da segunda unidade de medida se necessário.

@param aNFItem - Array com todas as informações do item
@param nItem - Número do item processado
@param cUmMed - Unidade de medida especificada se houver

@return Valor da quantidade

@author Erick Dias
@since 17/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetQtdItem(aNFItem, nItem, cUmMed)

	Local nRet	  := 0

	Default cUmMed  := ""

//Verifica se foi informada uma unidade de medida específica para o cálculo.
	If !Empty(cUmMed)
		// Se a primeira unidade do produto já for a unidade cadastrada a base será
		// a própria quantidade informada. Não é necessário converter. Caso contrário
		// preciso efetuar a conversão conforme o fator de conversão informado no produto
		If cUmMed == Iif(!Empty(aNfItem[nItem][IT_B1UM]), aNfItem[nItem][IT_B1UM], "")
			nRet := aNFItem[nItem][IT_QUANT]
		ElseIf cUmMed == Iif(!Empty(aNfItem[nItem][IT_B1SEGUM]), aNfItem[nItem][IT_B1SEGUM], "")
			nRet := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
		EndIf
	Else
		//Se não houver nenhuma unidade de medida especificada então retornará a própria quantidade
		nRet := aNFItem[nItem][IT_QUANT]
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MapOperForm

Função que realiza o mapeamento dos operandos com suas devidas fórmulas.
Recebe o JsonObject, operando atual e sua fórmula.
Esta função verifica se operando está no cache, se não estiver,
adiciona o operando e todas as suas dependências, ou seja,
todas as outras fórmulas que estão contidas dentro da fórmula atual, independente
do nível de dependência, já que o processamento é recursivo.

Performance: Usa JsonObject:HasProperty() para lookup O(1) ao invés de aScan O(n).

@param jMapForm   - JsonObject com cache de operandos e fórmulas NPI
@param cOperando  - Operando atual a ser mapeado
@param cFormula   - Fórmula NPI do operando
@param cTributo   - Tributo relacionado (para mapeamento de dependências)
@param jDepTrib   - JsonObject com dependências entre tributos (estrutura dois níveis)
@param jVldTribs  - JsonObject com tributos qualificados para mapeamento

@author Erick Dias
@since 18/02/2020
@version 12.1.30

Revisão: Migração de array para JsonObject (aMapForm?jMapForm, aDepTrib?jDepTrib)
@author revisão: Rafael Oliveira
@since revisão: 30/12/2025
@version revisão: 12.1.2510
*/
//-------------------------------------------------------------------
Static Function MapOperForm(jMapForm, cOperando, cFormula, cTributo, jDepTrib, jVldTribs, lTribZero)

	Local nCont			:= 0
	Local aFormula		:= {}
	Local cIdTribAtu	:= ""
	Local cFormTemp		:= ""
	Local cOperTrim     := ""
	Local cFormProc		:= ""
	Local cMapKey      := ""

	// Se fórmula estiver vazia então não seguirei com o processamento!
	If Empty(cFormula)
		Return
	EndIf

	cFormula := AllTrim(cFormula)
	cIdTribAtu := GetMapTrbId(cTributo, jVldTribs)
	cOperando := ResMapPriTrb(NrmTidOper(AllTrim(cOperando)), cIdTribAtu)

	// Usa GetTknForm para tokenização com cache MD5
	// Reaproveita jCacheTokens evitando StrTokArr repetido
	aFormula := GetTknForm(cFormula)

	// Adiciona operando e fórmula no cache JsonObject - O(1)
	AddOperando(jMapForm, cOperando, cFormula)

//-------------------------------------------------
//Laço para percorrer todos os elementos da fórmula
//-------------------------------------------------
	For nCont := 1 to len( aFormula )

		cFormProc := AllTrim(aFormula[nCont])

		// Se for operador, ignora
		If cFormProc $ "+-*/()"
			Loop
		EndIf

		cFormProc := ResMapPriTrb(NrmTidOper(cFormProc), cIdTribAtu)

			//-----------------------------------------------------------------------------------------------------
			//Aqui verifico se operando é de preferência de referência para não realizar o mapeamento das dependências deste operando
			//-----------------------------------------------------------------------------------------------------

		If !(IsPrefRef(cFormProc))

			//-----------------------------------------------------------------------------------------------------
			//Aqui verifico se operando é de tributo para pode realizr o mapeamento das dependências deste operando
			//Aqui realizo o mapeamento das dependencias dos tributos
			//-----------------------------------------------------------------------------------------------------

			If IsOperTrib(cFormProc)
				// Otimização: Valida se tributo é qualificado para mapeamento
				If !ValTrbMap(cFormProc, jVldTribs)
					Loop
				EndIf

				MapDepTrib(cFormProc, cTributo, jDepTrib)
			ElseIf IsOperZero(cFormProc) // Valida se é o Operando O:ZERO para mapear a formula de zero
				lTribZero := .T.
			EndIF

			// Evita loop infinito em fórmulas recursivas sem impedir
			// o registro de novas dependências para outros tributos.
			If !Empty(cFormProc) .And. Valtype(jMapProc) == "J"
				cMapKey := MapCtxKey(cTributo, cFormProc)

				If jMapProc:HasProperty(cMapKey)
					Loop
				EndIf

				jMapProc[cMapKey] := .T.
			Endif

			//Verifico se operando é composto, para eu verificar na CIN
			//Operadores, números ou operadores primários não precisam ser adicionados no hashmap
			//Verifico também se operando ainda não está no hashmap, pois se já estiver não preciso processar
			If ((IsOperComposto(cFormProc) .Or. IsOperTrib(cFormProc)))
				cFormTemp  := ""
				cOperTrim  := cFormProc

				If !FindOper(jMapForm, cOperTrim, @cFormTemp)

					cFormTemp := GetFormCIN(cOperTrim)
				Endif

				If !Empty(cFormTemp)
					//Chamada novamente da função de forma recursiva
					MapOperForm(jMapForm, cOperTrim, cFormTemp, cTributo, jDepTrib, jVldTribs,@lTribZero)
				EndIF
			ElseIf IsOperZero(cFormProc) //valida se é Operando O:ZERO para mapear a formula de zero
				lTribZero := .T.
			EndIF

		EndIf

	Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MapCtxKey

Monta chave contextual do mapeamento recursivo por tributo dono da fórmula.

@param cTributo  - Sigla do tributo dono da fórmula
@param cOperando - Operando/fórmula em expansão

@return cKey - Chave contextual de processamento
/*/
//-------------------------------------------------------------------
Static Function MapCtxKey(cTributo, cOperando)
Return AllTrim(cTributo) + "@" + AllTrim(cOperando)

//-------------------------------------------------------------------
/*/{Protheus.doc} AddOperando

Adiciona operando no cache de operandos vs fórmulas.
Verifica se operando existe no JsonObject usando HasProperty() O(1).
Se existir, não precisa processar nada (evita duplicação).
Caso não exista, adiciona ao cache.

Performance: Substituiu aScan O(n) por HasProperty O(1).

@param jMapForm  - JsonObject com cache operandos x fórmulas NPI
@param cOperando - Operando que deverá ser adicionado
@param cForNPI   - Fórmula NPI do operando

@author Erick Dias
@since 18/02/2020
@version 12.1.30

Revisão: Migração de array aMapForm para JsonObject jMapForm
@author revisão: Rafael Oliveira
@since revisão: 30/12/2025
@version revisão: 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function AddOperando(jMapForm, cOperando, cForNPI)

	// Somente realizo operação se operando for enviado para função
	If Empty(cOperando) .Or. Empty(cForNPI)
		Return
	EndIf

	// Verifica se operando já existe no JsonObject - O(1) lookup
	If !jMapForm:HasProperty(cOperando)
		// Operando não existe, adiciona ao cache
		jMapForm[cOperando] := cForNPI
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FindOper

Função que verifica se determinada chave existe no cache de operandos.
Usa HasProperty() para busca O(1) ao invés de aScan O(n).

Performance crítica: Esta função era chamada 10.799.307 vezes (256 segundos).
Redução: aScan O(n) ? HasProperty O(1) = ganho de ~10.000x.

@param jMap   - JsonObject com cache de operandos x fórmulas NPI
@param cChave - Chave (operando) a ser procurada
@param cRet   - Conteúdo da chave (fórmula NPI) caso esteja no cache

@return Logical - .T. se encontrou a chave no cache, .F. caso contrário

@author Erick Dias
@since 18/02/2020
@version 12.1.30

Revisão: Migração de aScan O(n) para HasProperty O(1)
@author revisão: Rafael Oliveira
@since revisão: 30/12/2025
@version revisão: 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function FindOper(jMap, cChave, cRet)

	Default cRet := ""

	// Busca O(1) via HasProperty - 10.000x mais rápido que aScan O(n)
	If jMap:HasProperty(cChave)
		cRet := jMap[cChave]
		Return .T.
	EndIf

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} InitMemoCalc

Inicializa/limpa o cache de memoização de operandos calculados.
Deve ser chamado no INÍCIO de cada execução de FisTribGen.

O cache só é válido durante UMA execução de cálculo - quando usuário
altera valores (quantidade, valor mercadoria, etc), FisTribGen é chamado
novamente e o cache deve ser reiniciado para evitar valores desatualizados.

Otimização: Evita recálculo de operandos repetidos na mesma execução.
Exemplo: O:VAL_MERCADORIA usado em 3 tributos diferentes é calculado 1x.

IMPORTANTE: Cache NÃO é usado quando flags LSEMREDUCAO/lAliqSemRed ativos,
pois são recálculos específicos para escrituração fiscal com valores originais.

@author Rafael Oliveira
@since 29/01/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function InitMemoCalc()

	// Cria novos caches para esta execução (ciclo de vida específico)
	jCacheTokens := JsonObject():New()
	jTribIndex := JsonObject():New()  // Hash index por nItem@sigla -> posição
	jNPIResultCache := JsonObject():New()  // Cache L1 unificado (operandos + tributos + sem redução)
	jCacheNrmTid := JsonObject():New()     // Cache de normalização de operandos TID -> sigla

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMemoCalcWb
	Retorna handle de caixa-branca com referencias diretas aos caches de
	memoizacao ativos. Uso exclusivo em testes AdvPR.

	Deve ser chamado APOS InitMemoCalc() para que as referencias sejam validas.
	Em ADVPL, JsonObject e passado por referencia: mutacoes no handle
	refletem diretamente nos statics internos sem poluir a funcao de producao.

	Fluxo esperado em testes:
	  StaticCall(CONFXFIS, InitMemoCalc)
	  jWb := StaticCall(CONFXFIS, GetMemoCalcWb)
	  jWb["nrmTid"]["chave"] := "valor"
	  cRet := StaticCall(CONFXFIS, NrmTidOper, ...)
	  StaticCall(CONFXFIS, EndMemoCalc)

	@return jHandle, JsonObject, com as seguintes chaves:
	  "tokens"    -> jCacheTokens    (tokens de formulas)
	  "tribIndex" -> jTribIndex      (hash index por sigla)
	  "npiCache"  -> jNPIResultCache (resultados NPI)
	  "nrmTid"    -> jCacheNrmTid    (normalizacao TID -> sigla)	  
	  "tidTribs"  -> jTidTribs       (mapa IDTRIB -> SIGLA)

	@author Squad Fiscal
	@since 04/03/2026
	@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function GetMemoCalcWb()
	Local jHandle := JsonObject():New()

	jHandle["tokens"]    := jCacheTokens
	jHandle["tribIndex"] := jTribIndex
	jHandle["npiCache"]  := jNPIResultCache
	jHandle["nrmTid"]    := jCacheNrmTid	
	jHandle["tidTribs"]  := jTidTribs

Return jHandle

//-------------------------------------------------------------------
/*/{Protheus.doc} EndMemoCalc

Função que finaliza e limpa os caches de memoização.
Deve ser chamada ao final de cada escopo de processamento (FisTribGen ELSE, FisLoadTG)
para garantir que não haja vazamento de memória e que caches obsoletos não contaminem
a próxima execução.

@author Rafael Oliveira
@since 29/01/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function EndMemoCalc()

	// Libera cache de tokens
	If ValType(jCacheTokens) == "J"
		FwFreeObj(jCacheTokens)
		jCacheTokens := Nil
	EndIf

	// Libera hash index de tributos
	If ValType(jTribIndex) == "J"
		FwFreeObj(jTribIndex)
		jTribIndex := Nil
	EndIf

	// Libera cache unificado de resultados NPI
	If ValType(jNPIResultCache) == "J"
		FwFreeObj(jNPIResultCache)
		jNPIResultCache := Nil
	EndIf

	// Libera cache de normalização de TID
	If ValType(jCacheNrmTid) == "J"
		FwFreeObj(jCacheNrmTid)
		jCacheNrmTid := Nil
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BldValTrib

Função que monta um JsonObject contendo a lista de tributos
válidos (qualificados) a partir de um alias de query.

Otimização de performance: Permite curto-circuitar o processamento
de fórmulas que referenciam tributos não enquadrados via MapOperForm.

@param cAlias - Alias contendo os tributos (campo TRIBUTO_SIGLA)
@param jVldTribs - JsonObject com tributos válidos (chave: sigla, valor: .T.)
@return jVldTribs - JsonObject com tributos válidos (chave: sigla, valor: .T.)

@author Rafael Oliveira
@since 19/01/2026
@version 12.1.2510
*/
//-------------------------------------------------------------------
Static Function BldValTrib(cAlias, jVldTribs)
	Local cCodigo := ""
	Local cSigla  := ""
	Local cIdTrib := ""

	// Reinicializa cache IDTRIB->SIGLA para o ciclo atual
	If ValType(jTidTribs) == "J"
		FwFreeObj(jTidTribs)
	EndIf
	jTidTribs := JsonObject():New()

	// Itera alias para monta lista de tributos qualificados
	Do While !(cAlias)->(Eof())
		If Empty((cAlias)->VAL_FOR_COD)
			(cAlias)->(DbSkip())
			Loop
		Endif

		cCodigo := GetTribOper(AllTrim((cAlias)->VAL_FOR_COD))
		cSigla  := AllTrim(cCodigo)
		cIdTrib := AllTrim((cAlias)->IDTRIB)

		jVldTribs[cSigla] := cIdTrib

		If !Empty(cSigla) .And. !Empty(cIdTrib)
			jTidTribs[cIdTrib] := cSigla
		EndIf

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbGoTop())


Return jVldTribs

//-------------------------------------------------------------------
/*/{Protheus.doc} ValTrbMap

Função que valida se um tributo referenciado em operando
está qualificado para a operação em andamento.

Utilizada em MapOperForm para curto-circuitar processamento
de tributos não enquadrados (VAL:XXX onde XXX não está em jVldTribs).

@param cOperando - Operando a ser validado (ex: VAL:ICMS, BAS:PIS)
@param jVldTribs - JsonObject contendo tributos válidos
@return lValido - .T. se tributo é válido ou jVldTribs está vazio, .F. caso contrário

@author Rafael Oliveira
@since 19/01/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function ValTrbMap(cOperando, jVldTribs)

	Local lValido := .T.
	Local cTrbRef := ""

	// Se jVldTribs foi informado, valida se tributo existe
	If Substring(cOperando, 1, 4) $ "VAL:"
		cTrbRef := GetTribOper(AllTrim(cOperando))
		// Se o tributo não é válido para esta operação, retorna .F.
		// Isso evita lookup desnecessário na tabela CIN e recursividade inútil
		lValido := jVldTribs:HasProperty(cTrbRef)
	EndIf

Return lValido

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFormCIN

Função que posiciona a CIN considerando o operando enviado
e retorna a fórmula NPI.

Performance: Utiliza cache em memória (jCacheCIN) para evitar
consultas repetidas na tabela CIN.

@param cOperando   - Operando que será procurado na CIN
@return - cRet - Fórmula NPI do operando enviado na função
@author Erick Dias
@since 18/02/2020
@version 12.1.30

Revisão: Posicionar a CIN considerando o operando enviado
e retornar a fórmula NPI, priorizando o novo campo CNI_FNPI_M
@author revisão:  Nilson César
@since revisão:   04/07/2025
@version revisão: 12.1.2410

Revisão: Implementação de cache para otimização de performance
@author revisão:  Rafael Oliveira
@since revisão:   23/12/2025
@version revisão: 12.1.2510
/*/
//-------------------------------------------------------------------
Static function GetFormCIN(cOperando)

	Local xReturn    := ''
	Local cOperTrim  := ''

	//Verifico se operando está preenchido antes de continuar
	If Empty(cOperando)
		Return ''
	EndIF

	// Inicializo o cache se ainda n?o foi inicializado (lazy loading)
	If ValType(jCacheCIN) != 'J'
		InitCacheCIN()
	EndIf


	// Normalizo o operando para busca no cache (SEM prefixo empresa/filial)
	cOperTrim := AllTrim(cOperando)

	// Busco primeiro no cache
	If jCacheCIN:HasProperty(cOperTrim)
		xReturn := jCacheCIN[cOperTrim]
		Return xReturn
	EndIf

	// Se não encontrei no cache, busco na tabela CIN
	If CIN->(MsSeek(xFilial('CIN') + Padr(cOperando, nTamCINCod) + "0" ))
		// Se encontrou o campo memo, retorno ele
		If lCmpNPIMemo
			xReturn := CIN->CIN_FNPI_M
		Endif

		// Se o campo memo estiver vazio, verifico o campo varchar
		If Empty(xReturn)
			If Len(AllTrim(CIN->CIN_FNPI)) >= 230
				// Formula pode estar truncada, converte em tempo de execução
				xReturn := xFisSYard(CIN->CIN_FORMUL)
			Else
				// Formula é segura para uso
				xReturn := CIN->CIN_FNPI
			EndIf
		EndIf

		// Armazeno no cache para próximas consultas (mesmo que vazio!)
		If !Empty(cOperTrim)
			jCacheCIN[cOperTrim] := Alltrim(xReturn)
		EndIf
	EndIF

Return xReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPosTrib

Retorna a posição do tributo no array com base no operando (sigla)

OTIMIZAÇÃO v12.1.2510: Usa hash index jTribIndex para lookup O(1)
ao invés de aScan O(n). Em cenários com 30 tributos cascata,
reduz de ~18.000 comparações para ~30 lookups.

@param cOperando   - Sigla do tributo que preciso verificar se está no enquadrado
@param aNfItem     - Array dos itens da nota
@param nItem       - Número do item processado

@return Retorna a posição do tributo no aNfItem

@author Erick Dias
@since 21/02/2020
@version 12.1.30

Revisão: Hash index para lookup O(1)
@author revisão: Rafael Oliveira
@since revisão: 31/01/2026
@version revisão: 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function GetPosTrib(cOperando, aNfItem, nItem)
	Local cKey as character
	Local cSigla as character
	Local nPos as numeric
	Local lTribIndex := ValType(jTribIndex) == "J"

	// Se não veio operando nenhum, então não conseguirei analisar
	IF Empty(cOperando)
		Return 0
	EndIF

	cSigla := AllTrim(cOperando)

	// OTIMIZAÇÃO v12.1.2510: Tenta usar hash index O(1)
	If lTribIndex
		// Chave: nItem@sigla (ex: "1@ICMS")
		cKey := cValToChar(nItem) + "@" + cSigla

		// Se já existe no índice, retorna posição O(1)
		If jTribIndex:HasProperty(cKey)
			Return jTribIndex[cKey]
		EndIf

	EndIf

	// Cache miss: busca aScan tradicional e cacheia resultado
	nPos := aScan(aNfItem[nItem][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_SIGLA]) == cSigla})
	If nPos > 0 .and. lTribIndex
		jTribIndex[cKey] := nPos  // Cacheia para próxima consulta
	EndIf

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} MapDepTrib

Função que monta o mapeamento de dependências entre tributos genéricos.
Este mapeamento auxilia no momento de alterações de base, alíquota e valores
dos tributos que incidem na base ou no valor de outros tributos.

Estrutura dois níveis com JsonObject:
- jDepTrib[cOperando][cTributo] := .T.
- Busca O(1) para verificar dependências via HasProperty()

Performance: Substituiu aScan O(n) duplo por HasProperty O(1).

@param cOperando - Código do operando (tributo fonte)
@param cTrib     - Tributo dependente deste operando
@param jDepTrib  - JsonObject com mapeamento de dependências (estrutura dois níveis)

@author Erick Dias
@since 28/02/2020
@version 12.1.30

Revisão: Migração de array aDepTrib para JsonObject jDepTrib (dois níveis)
@author revisão: Rafael Oliveira
@since revisão: 30/12/2025
@version revisão: 12.1.2510

@param cTrib    - Tributo dependentendeste operandos
@param jDepTrib  - Array com o mapeamento

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function MapDepTrib(cOperando, cTrib, jDepTrib)

	Local cOperNorm := AllTrim(cOperando)
	Local cTribNorm := AllTrim(cTrib)
	Local jTribList := Nil

	// Evita auto-dependência (tributo não depende de si mesmo)
	If GetTribOper(cOperNorm) == cTribNorm
		Return
	EndIf

	// Estrutura dois níveis: jDepTrib[cOperando][cTributo] := .T.
	// Busca O(1) para verificar dependências

	// Primeiro nível: verifica se operando já existe
	If !jDepTrib:HasProperty(cOperNorm)
		// Operando novo - cria segundo nível (JsonObject para tributos)
		jDepTrib[cOperNorm] := JsonObject():New()
	EndIf

	// Segundo nível: adiciona tributo ao operando (marca como .T.)
	jTribList := jDepTrib[cOperNorm]
	If !jTribList:HasProperty(cTribNorm)
		jTribList[cTribNorm] := .T.
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValTrib

Função auxiliar que retorna o valor do tributo, utilizada para considerar
o valor já calculado na referência, para considerar eventuais alterações realizadas pelo usuário

@param cDetTrib  - Sufixo do tributo
@param aNFItem   - Array com as informações do item da nota
@param nItem     - Número do item processadp
@param nTrbGen   - Posição do tributo genérico

@return - Valor calculado do tributo

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function RetValTrib(cDetTrib, aNFItem,nItem,nTrbGen)

	Local nResultado	:= 0
//Devo buscar o valor
	If cDetTrib == "BAS"
		nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
	ElseIf cDetTrib == "ALQ"
		nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
		//Verifica se valor obtido é percentual
		IF aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ] <> '2'
			nResultado := nResultado / 100
		Endif
	ElseIf cDetTrib == "VAL"
		//Quando não houver escrituração retorna valor calculado do tributo
		IF !Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_ID])
			nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_VALTRIB]
		Else
			nResultado	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
		Endif
	ElseIf cDetTrib == "ISE"
		nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ISENTO]
	ElseIf cDetTrib == "OUT"
		nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_OUTROS]
	ElseIf cDetTrib == "DIF"
		nResultado	:= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]
	EndIF

Return nResultado

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOperTrib

Função que identifica se opernado é de tributo

@param cOperando  - Operando a ser analizado

@return - .T. caso o operano seja de tributo

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function IsOperTrib(cOperando)
Return Substring(cOperando, 1, 4) $ "ALQ:|BAS:|VAL:|ISE:|OUT:|DIF:"

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOperComposto

Função que verifica se o tributo é composto, regra de base, alíquota tributo etc

@param cOperando  - Operando a ser analizado

@return - .T. caso o operano composto

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function IsOperComposto(cOperando)
Return Substring(cOperando,1,2) $ "B:|A:"

//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} GetTknForm

Retorna array de tokens de uma fórmula NPI, utilizando cache para
evitar parsing repetido de StrTokArr.

OTIMIZAÇÃO CRÍTICA: StrTokArr era executado 50.000+ vezes em tributos
em cascata, consumindo ~7 segundos só em parsing de strings.

Com cache: Após 1ª execução, retorna tokens em O(1) via HasProperty.

SEGURANÇA: Usa MD5 como chave de cache ao invés da fórmula literal.
Isso evita problemas com campos MEMO grandes (>1000 chars) que causariam:
- Truncamento de chaves JSON
- Colisões entre fórmulas diferentes
- Consumo excessivo de memória
MD5 garante chave de 32 chars fixos com baixíssima chance de colisão.

@param cFormula - Fórmula NPI a ser tokenizada

@return aTokens - Array de tokens da fórmula

@author Rafael Oliveira
@since 31/01/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function GetTknForm(cFormula)
	Local cKey := ""
	Local cFormNorm := ""
	Local aTokens := {}

	// Normaliza a fórmula
	cFormNorm := AllTrim(cFormula)

	// Se vazia, retorna array vazio
	If Empty(cFormNorm)
		Return aTokens
	EndIf

	// Usa MD5 como chave de cache para evitar problemas com MEMO grandes
	// MD5 retorna 32 chars fixos, evitando truncamento e colisões
	cKey := MD5(cFormNorm, 1)

	// Inicializa cache lazy se necessário
	If ValType(jCacheTokens) != "J"
		jCacheTokens := JsonObject():New()
	EndIf

	// Verifica se já temos os tokens no cache O(1)
	If jCacheTokens:HasProperty(cKey)
		// Clone do array para evitar modificação do cache
		Return AClone(jCacheTokens[cKey])
	EndIf

	// Cache miss: tokeniza a fórmula normalizada (não o hash)
	aTokens := StrTokArr(cFormNorm, " ")

	// Armazena no cache usando MD5 como chave
	jCacheTokens[cKey] := AClone(aTokens)

Return aTokens

//-------------------------------------------------------------------
/*/{Protheus.doc} IsPrefRef

Função que verifica se o tributo é referenciado

@param cOperando  - Operando a ser analizado

@return - .T. caso o prefixo seja do tributo referenciado

@author Erich Buttner
@since 22/03/2024
@version 12.1.2210, 12.1.2310
/*/
//-------------------------------------------------------------------

Static Function IsPrefRef(cOperando)
Return Substring(cOperando,1,4) $ "ORI:" .OR. Substring(cOperando,1,6) $ "T:ORI:"

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSiglaTid

Retorna a sigla do tributo a partir do IDTRIB (TID), usando cache O(1).

@param cIdTrib  - IDTRIB no formato "000056"
@return cSigla  - Sigla do tributo (ex: ICMSST) ou vazio

@author Rafael Oliveira
@since 13/02/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function GetSiglaTid(cIdTrib)
	Local cSigla := ""

	If ValType(jTidTribs) == "J" .And. jTidTribs:HasProperty(AllTrim(cIdTrib))
		cSigla := AllTrim(jTidTribs[AllTrim(cIdTrib)])
	EndIf

Return cSigla

//-------------------------------------------------------------------
/*/{Protheus.doc} NrmTidOper

Normaliza operandos com TID para manter compatibilidade com engine atual.

Conversões suportadas:
- T:ORI:VAL:000056 -> VAL:SIGLA
- T:ORI:BAS:000056 -> BAS:SIGLA
- T:ORI:ALQ:000056 -> ALQ:SIGLA
- T:ORI:ISE:000056 -> ISE:SIGLA
- T:ORI:OUT:000056 -> OUT:SIGLA
- T:ORI:DIF:000056 -> DIF:SIGLA
- T:ORI:VAL:000056 -> VAL:SIGLA

@param cOperando - Operando a normalizar
@return cRet     - Operando normalizado

@author Rafael Oliveira
@since 13/02/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function NrmTidOper(cOperando)
	Local cRet      := AllTrim(cOperando)	
	Local cDet      := ""
	Local cIdTrib   := ""
	Local cSigla    := ""
	Local aTokens   := {}	

	// Verifica se operando tem prefixo T:, caso contrário retorna como está (não é do tipo TID)
	If Left(cRet, 2) != "T:"
		Return cRet
	EndIf

	//Caso seja T:ORI:XXX, retorno sem normalizar, pois é referência direta ao operando do tributo de origem, e não deve ser convertido para sigla
	If left(cRet, 6) == "T:ORI:"
		Return cRet
	EndIf

	// Cache hit O(1): retorna resultado já normalizado	
	If jCacheNrmTid:HasProperty(cRet)
		Return jCacheNrmTid[cRet]
	EndIf

	//Separa os tokens - Formato esperado: T:<DET>:<ID>	
	// Exemplo: T:VAL:000056, T:BAS:000056, T:ALQ:000056, T:ISE:000056, T:OUT:000056, T:DIF:000056
	// Exemplo: T:VAL:000056 -> ["T", "VAL", "000056"]
	aTokens := StrTokArr(cRet, ":")
	cIdTrib := aTokens[3]
	cDet := aTokens[2]


	cSigla := GetSiglaTid(cIdTrib)
	If !Empty(cSigla)
		
			cRet := cDet + ":" + cSigla
	Else
		// Se TID não possuir sigla mapeada, retorna zero para manter
		// comportamento numérico esperado na execução da fórmula.
		cRet := "0"
	EndIf

	// Armazena no cache
	jCacheNrmTid[AllTrim(cOperando)] := cRet
	Asize(aTokens, 0)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTribOper

Função que retorna o tibuto do operando de tributo

@param cOperando  - Operando a ser analizado

@return - cTribFor - Tributo do operando

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function GetTribOper(cOperando)
	Local cOperNorm := NrmTidOper(cOperando)
Return Right(cOperNorm, Len(cOperNorm) - 4 )

//-------------------------------------------------------------------
/*/{Protheus.doc} CalcDep

Função que faz o cálculo dos tirbutos dependentes

@param jDepTrib   - Array com mapeamento das dependencias
@param cOperando  - Operando que deverá ser verificado suas dependencias
@param aNfItem    - Array com as informações do item da nota
@param nItem      - Número do item da nota
@param aNfCab     - Array com as informações do cabeçalho da nota
@param jMapForm     - Hashmap com o mapeamento das fórmulas e operandois

@author Erick Dias
@since 28/02/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function CalcDep(jDepTrib, aNfItem, nItem, aNfCab, jMapForm, cOperando, cExecuta, aFunc)

	Local cOperNorm := AllTrim(cOperando)
	Local jTribList := Nil
	Local aTributos := {}
	Local nY        := 0
	Local nPosTrib  := 0
	Local cAddExec  := ""

	// Verifica se operando tem dependências - O(1) lookup
	If !jDepTrib:HasProperty(cOperNorm)
		Return
	EndIf

	// Obtém lista de tributos dependentes deste operando
	jTribList := jDepTrib[cOperNorm]
	aTributos := jTribList:GetNames() // Obtém array com nomes das propriedades

	// Laço para realizar o cálculo de todos os tributos dependentes
	For nY := 1 To Len(aTributos)
		cAddExec := ""

		// Posiciona o item e refaz cálculo
		nPosTrib := GetPosTrib(aTributos[nY], aNfItem, nItem)

		// Se não tiver recalculo de BASE e se for um tributo com formula...
		If nPosTrib > 0
			If !("BSE" $ cExecuta) .And. !Empty(cOperNorm) .And. !Empty(aNfItem[nItem][IT_TRIBGEN][nPosTrib][TG_IT_FOR_NPI])
				// Verifica se a regra de base do dependente possui vínculo com o operando do tributo "pai"
				If RedoBaseDep(jMapForm, cOperNorm, aNfItem, nItem, nPosTrib) > 0
					cAddExec += "|BSE"
				EndIf
			EndIf

			FisCalcTG(@aNfItem, nItem, nPosTrib, cExecuta + cAddExec, aNfCab, jMapForm, .T., aFunc)
		EndIf

	Next nY

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RedoBaseDep

Procura se a regra de base do tributo dependente usa o operando o tributo pai, se sim, necessita o recalculo da base do dependente

@param jMapForm    - JsonObject com o mapeamento das fórmulas e operandos
@param cOperando  - Operando que deverá ser verificado suas dependencias
@param aNfItem    - Array com as informações do item da nota
@param nItem      - Número do item da nota
@param nPosTrib   - Posicao do Tributo Generico

@author Douglas Dourado
@since 20/08/2024
@version 12.1.2310
/*/
//-------------------------------------------------------------------
Static Function RedoBaseDep(jMapForm, cOperando, aNfItem, nItem, nPosTrib)

	Local cFormBase  := AllTrim(aNfItem[nItem][IT_TRIBGEN][nPosTrib][TG_IT_REGRA_BAS][TG_BAS_FOR_NPI])
	Local cIdTribAtu := GetCurTrbId(aNfItem, nItem, nPosTrib)
	Local jTrail     := JsonObject():New()
	Local nRet       := 0

	// Se não houver fórmula base, não precisa recalcular
	If !Empty(cFormBase)
		If HasDepFrm(jMapForm, cFormBase, cOperando, cIdTribAtu, jTrail)
			nRet := 1
		EndIf
	Endif

	FwFreeObj(jTrail)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} HasDepFrm

Verifica recursivamente se a fórmula base do tributo dependente referencia
o operando do tributo pai, considerando normalização de O: e T:.

@param jMapForm   - JsonObject de operandos x fórmulas
@param cFormBase  - Operando base do tributo dependente
@param cOperando  - Operando do tributo pai
@param cIdTribAtu - IDTRIB do tributo dependente
@param jTrail     - JsonObject para evitar ciclos

@return lRet - .T. quando a fórmula depende do operando informado
/*/
//-------------------------------------------------------------------
Static Function HasDepFrm(jMapForm, cFormBase, cOperando, cIdTribAtu, jTrail)
	Local cFormKey := ResMapPriTrb(NrmTidOper(AllTrim(cFormBase)), cIdTribAtu)
	Local cOperRef := ResMapPriTrb(NrmTidOper(AllTrim(cOperando)), cIdTribAtu)
	Local cTrailKy := cIdTribAtu + "@" + cFormKey + "@" + cOperRef
	Local cFormula := ""
	Local aTokens  := {}
	Local cToken   := ""
	Local nPos     := 0

	If jTrail:HasProperty(cTrailKy)
		Return .F.
	EndIf

	jTrail[cTrailKy] := .T.

	If !FindOper(jMapForm, cFormKey, @cFormula)
		Return .F.
	EndIf

	aTokens := GetTknForm(cFormula)

	For nPos := 1 To Len(aTokens)
		cToken := AllTrim(aTokens[nPos])

		If Empty(cToken) .Or. cToken $ "+-*/()"
			Loop
		EndIf

		cToken := ResMapPriTrb(NrmTidOper(cToken), cIdTribAtu)

		If cToken == cOperRef
			Return .T.
		EndIf

		If (IsOperComposto(cToken) .Or. IsOperTrib(cToken)) .And. ;
				HasDepFrm(jMapForm, cToken, cOperRef, cIdTribAtu, jTrail)
			Return .T.
	EndIf
Next nPos

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} MapValOrig

Função que realiza o mapeamento dos tributos dependentes dos operandos
primários/valores de origem, tais como frete, desconto, seguro etc.

Este mapeamento é imporante no momento que o usuario altera algum valor,
precisamos saber qual tributo exatamente deverá ser alterado, para não
peder eventuais alterações manuais realizada pel usuário

@param cFormula   - Fórmula a ser analizada
@param cTributo  - Tributo a ser analisado
@param aDepVlOrig   - Array com mapeamento atual

@author Erick Dias
@since 03/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function MapValOrig(cFormula, cTributo, aDepVlOrig)

	Local nX			:= 0
	Local aFormula		:= {}
	Local cFormTemp		:= ""

//Se fórmula estiver vazia então não seguirei com o processamento!
	If Empty(cFormula)
		Return
	EndIf

//Converte em array a fórmula para falicitar a iteração
	aFormula	:= StrTokArr(alltrim(cFormula)," ")

//-------------------------------------------------
//Laço para percorrer todos os elementos da fórmula
//-------------------------------------------------
	For nX := 1 to len(aFormula)

		//Verifica se operando é composto, ou seja, formado por outrar fórmula
		If IsOperComposto(aFormula[nX]) .Or. IsOperTrib(aFormula[nX])
			//Chamarei novamente a função

			//Obtenho a fórmula dele para ser analisada
			cFormTemp	:= GetFormCIN(aFormula[nX])

			//Se tem fórmula continuo
			If !Empty(cFormTemp)
				//Chamo novamente a função de forma recursiva para analisar próximo nível de operandos
				MapValOrig(cFormTemp, cTributo, aDepVlOrig)
			EndIf

			//Se não for operando composto, não for operador e não for número estático, então é um operando primário
		Elseif !IsDigit(aFormula[nX]) .And. !SubString(aFormula[nX], 1,2)  $ "/*-+" .ANd. Alltrim(aFormula[nX]) <> "MAIOR"

			//Aqui faço o mapeamento, do tributo com operando primário
			DepValOrig(aDepVlOrig, aFormula[nX], cTributo)

		EndIF

	Next nX

	asize(aFormula,0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DepValOrig

Função que atualiza o array de dependências dos operandos priários

Este mapeamento é imporante no momento que o usuario altera algum valor,
precisamos saber qual tributo exatamente deverá ser alterado, para não
peder eventuais alterações manuais realizada pel usuário

@param aDepVlOrig   - Array com mapeamento atual
@param cOperOrig   - Operador de valor de origem/primário
@param cTributo  - Tributo a ser analisado


@author Erick Dias
@since 03/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function DepValOrig(aDepVlOrig, cOperOrig, cTributo)

	Local nX := 0

//Primeiro procuro no array de dependência se o operando existe
	If(nX := aScan(aDepVlOrig,{|x| AllTrim(x[1]) == Alltrim(cOperOrig)})) > 0
		//Aqui o operando já está incluído, precisa verificar se para este tributo também

		//Procuro o tributo relacionado com o operando
		IF aScan(aDepVlOrig[nX][2],{|x| Alltrim(x) == Alltrim(cTributo)}) == 0

			//Operando já foi adicionado no mapeamento, porém só não estava vinculado com este tributo
			aAdd(aDepVlOrig[nX][2], cTributo)

		EndIF

	Else
		//Aqui não tem operando de valor de origem no mapeamento, será adicionado
		aAdd(aDepVlOrig, {cOperOrig, {cTributo}})

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCalcLeg

Função que faz cálculo dos tributos da onda 1 do configurador, sem
utilização de fórmulas

@param aNFItem   - Array com mapeamento atual
@param nItem     - Operador de valor de origem/primário
@param nTrbGen   - Tributo a ser analisado
@param cExecuta  - Tributo a ser analisado
@param aNFCab    - Tributo a ser analisado

@author Erick Dias
@since 05/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisCalcLeg(aNFItem, nItem, nTrbGen, cExecuta, aNFCab)

	Local nBase 	:= 0
	Local nAliquota := 0
	Local nValor 	:= 0
	Local cPrUm 	:= ""
	Local cSgUm 	:= ""

// Não reduzir a base quando o valor de origem for a quantidade.
	Local lReduzBase := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] <> '02' .And. aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] > 0

	DEFAULT cExecuta := "BSE|ALQ|VLR"

//--------------------------------------------------------------------
//Adiciono nova posição para controle do SaveDec do tributo genérico
//--------------------------------------------------------------------
//Preciso verificar se o tributo já consta no array do SaveDec, se já existe não precisa adicoonar, se não existe ai será criado.
	TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)

//---------------------------------------
// Definição da base de cálculo
//---------------------------------------
	If "BSE" $ cExecuta

		Do Case

			// 01 - Valor da mercadoria
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '01'

			nBase := aNFItem[nItem][IT_VALMERC]

			// 02 - Quantidade
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '02'

			// Se for informada uma unidade de medida específica para o cálculo
			If !Empty(aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM])

				// Obtenho a primeira e a segunda unidade de medida informadas no produto
				cPrUm := Iif(!Empty(aNfItem[nItem][IT_B1UM]), aNfItem[nItem][IT_B1UM], "")
				cSgUm := Iif(!Empty(aNfItem[nItem][IT_B1SEGUM]), aNfItem[nItem][IT_B1SEGUM], "")

				// Se a primeira unidade do produto já for a unidade cadastrada a base será
				// a própria quantidade informada. Não é necessário converter. Caso contrário
				// preciso efetuar a conversão conforme o fator de conversão informado no produto
				If cPrUm == aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]
					nBase := aNFItem[nItem][IT_QUANT]
				ElseIf cSgUm == aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]
					nBase := ConvUm(aNfItem[nItem][IT_PRODUTO],aNfItem[nItem][IT_QUANT],0,2)
				EndIf

			Else
				nBase := aNFItem[nItem][IT_QUANT]
			EndIf

			// 03 - Valor Contábil
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '03'

			nBase := aNfItem[nItem][IT_LIVRO][LF_VALCONT]

			// 04 - Valor do Crédito Presumido - OBRIGATORIO usar o genérico!
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '04'

			nBase := aNfItem[nItem][IT_LIVRO][LF_CRDPRES]

			// 05 - Base do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '05'

			nBase := aNfItem[nItem][IT_BASEICM]

			// 06 - Base "original" do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '06'

			nBase := aNfItem[nItem][IT_BICMORI]

			// 07 - Valor do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '07'

			nBase := aNfItem[nItem][IT_VALICM]

			// 08 - Valor do Frete
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '08'

			nBase := aNfItem[nItem][IT_FRETE]

			// 09 - Valor da Duplicata
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '09'

			nBase := aNfItem[nItem][IT_BASEDUP]

			// 10 - Valor total do item
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI] == '10'

			nBase := aNfItem[nItem][IT_TOTAL]

		EndCase

		// Verifica configuração para aplicar a redução de base antes das deduções/adições...
		If lReduzBase .And. aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED] == '1'
			nBase := (nBase * (1 - (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] / 100)))
		EndIf

	/*

	Regra geral das adições subtrações:

	1 - Sem ação
	2 - Subtrai
	3 - Soma

	*/

		// Desconto

		Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON] == '2'
			nBase -= (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT])
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON] == '3'
			nBase += (aNfItem[nItem][IT_DESCONTO] + aNfItem[nItem][IT_DESCTOT])
		EndCase

		// Frete

		Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE] == '2'
			nBase -= aNfItem[nItem][IT_FRETE]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE] == '3'
			nBase += aNfItem[nItem][IT_FRETE]
		EndCase

		// Seguro

		Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO] == '2'
			nBase -= aNfItem[nItem][IT_SEGURO]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO] == '3'
			nBase += aNfItem[nItem][IT_SEGURO]
		EndCase

		// Despesas

		Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP] == '2'
			nBase -= aNfItem[nItem][IT_DESPESA]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP] == '3'
			nBase += aNfItem[nItem][IT_DESPESA]
		EndCase

		// ICMS Desonerado

		Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES] == '2'
			nBase -= aNfItem[nItem][IT_DEDICM]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES] == '3'
			nBase += aNfItem[nItem][IT_DEDICM]
		EndCase

		// ICMS-ST

		Do Case
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST] == '2'
			nBase -= aNfItem[nItem][IT_VALSOL]
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST] == '3'
			nBase += aNfItem[nItem][IT_VALSOL]
		EndCase


		// Verifica configuração para aplicar a redução de base após as deduções/adições
		If lReduzBase .And. aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED] == '2'
			nBase := (nBase * (1 - (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] / 100)))
		EndIf

		// Atribuindo base "final" na referência de base do tributo.
		aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] := nBase

	EndIf

//---------------------------------------
// Definição da alíquota
//---------------------------------------
	If "ALQ" $ cExecuta

		Do Case

			// 01 - Alíquota do ICMS
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '01' .AND. aNfItem[nItem][IT_BASEICM] > 0

			nAliquota := aNfItem[nItem][IT_ALIQICM]

			// 02 - Alíquota do Crédito Presumido
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '02' .AND. aNfItem[nItem,IT_LIVRO,LF_CRDPRES] > 0

			nAliquota := aNFItem[nItem][IT_TS][TS_CRDPRES]

			// 03 - Alíquota do ICMS-ST
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '03' .AND. aNfItem[nItem][IT_BASESOL] > 0

			nAliquota := aNFItem[nItem][IT_ALIQSOL]

			// 04 - Alíquota Informada Manualmente
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '04'

			nAliquota := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_ALIQ]

			// 05 - Unidade de Referência Fiscal
		Case aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '05'

			nAliquota := (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VALURF] * (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_PERURF] / 100))

		EndCase


		aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] := nAliquota

	EndIf

//---------------------------------------
// Definição do valor
//---------------------------------------
	If "VLR" $ cExecuta

		If aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '04'
			// Divido por 100 caso a alíquota informada for do tipo 1 - percentual
			If aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ] == '1'
				nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / 100)
			Else
				nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
			EndIf
		ElseIf aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_VLORI] == '05'
			nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]
		Else
			nValor := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] * (aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / 100)
		EndIf

		aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] := nValor

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisCalcForm

Função que faz cálculo dos tributos por meio das fórmulas NPI

@param aNFItem   - Array com mapeamento atual
@param nItem     - Operador de valor de origem/primário
@param nTrbGen   - Tributo a ser analisado
@param cExecuta  - Tributo a ser analisado
@param aNFCab    - Tributo a ser analisado
@param jMapForm  - Mapeamento das fórmulas da CIN
@param lEdicao    - Indica se está realizando alteração em alguma propriedade específica do tributo

@author Erick Dias
@since 05/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Function FisCalcForm(aNFItem, nItem, nTrbGen, cExecuta, aNFCab, jMapForm, lEdicao)

Local lMemoise := NIL

//Se for para processar todas as propriedades do tributo, então farei de uma vez por meiuo da função xFisExecNPI, que já atualizará o valor base e alíquota.
	If cExecuta == "BSE|ALQ|VLR" .AND. !Empty( aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI] )

		//Verifica se a unidade de medida se enquadra antes de executar
		If BaseEnq(aNFItem, nItem, nTrbGen)

			xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR], aNFItem, nItem, jMapForm, .F.,, nTrbGen,, aNfCab)

		EndIF

	Else

		lMemoise := lEdicao
		//Caso seja alguma edição e que necessite calcular somente algumas propriedades do tributo, então chamarei separado.
		//---------------------------------------
		// Definição da base de cálculo
		//---------------------------------------
		If "BSE" $ cExecuta .And. BaseEnq(aNFItem, nItem, nTrbGen) //Verifica se a unidade de medida se enquadra antes de executar

			//Aqui executo a fórmula  NPI
			xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR], aNFItem, nItem, jMapForm, lEdicao, lMemoise, nTrbGen,, aNfCab)

		EndIf

		//---------------------------------------
		// Definição da alíquota
		//---------------------------------------
		If "ALQ" $ cExecuta

			//-----------------------------------------------------------------
			//Se houver fórmua então realizará o cálculopor meio da fórmula NPI
			//-----------------------------------------------------------------
			xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_COD_FOR], aNFItem, nItem, jMapForm, lEdicao, lMemoise, nTrbGen,, aNfCab)

		EndIf

		//---------------------------------------
		// Definição do valor
		//---------------------------------------
		If "VLR" $ cExecuta

			//-----------------------------------------------------------------
			//Se houver fórmua então realizará o cálculopor meio da fórmula NPI
			//-----------------------------------------------------------------
			xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_COD_FOR], aNFItem, nItem, jMapForm, lEdicao, lMemoise, nTrbGen,, aNfCab)

		EndIf

	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BaseEnq

Função que verifica se a regra de base de cálculo se enquadra com a unidade
do item da nota

@param aNFItem   - Array com mapeamento atual
@param nItem     - Operador de valor de origem/primário
@param nTrbGen   - Tributo a ser analisado

@author Erick Dias
@since 05/03/2020
@version 12.1.30
/*/
//-------------------------------------------------------------------
Static Function BaseEnq(aNFItem, nItem, nTrbGen)


	Local lRet	:= Empty(aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]) .Or. ;
		aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM] == Iif(!Empty(aNfItem[nItem][IT_B1UM])   , aNfItem[nItem][IT_B1UM]   , "") .Or. ;
		aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM] == Iif(!Empty(aNfItem[nItem][IT_B1SEGUM]), aNfItem[nItem][IT_B1SEGUM], "")
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecMaxMin

Função que receberá uma fórmula no padrão MAIOR(A, B) ou MENOR(A, B)
Esta função executará os dois operandos, e vai comparar qual
tem o valor maior. O operando que tiver maior valor será
retornado para que chamou esta função.

@param cFormula   - Fórmula a ser executada

@author Erick Dias
@since 03/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ExecMaxMin(cFormula, aNFItem, nItem, jMapForm, nPosTrbProc, cDetTrib, aNfCab, cTipo)

	Local aFormula	:= {}
	Local cOperando1:= ""
	Local cOperando2:= ""
	Local nVal1 	:= 0
	Local nVal2 	:= 0

	Local lSkipCacheBkp := lSkipNPIResultCache
//Verifica se a fórmula está preenchida antes de seguir
	If Empty(cFormula)
		Return ""
	EndIF

//Converte a fórmula
	aFormula	:= StrTokArr(alltrim(cFormula)," ")

//Verifica se a fórmula está no padrão correto antes de seguir.
	If Len(aFormula) < 4
		Return ""
	EndIF

//(MAIOR A , B) // Estrutura de como estará a fórmula
//(MENOR A , B) // Estrutura de como estará a fórmula

//Obtendo os opernados
	cOperando1 := aFormula[2]
	cOperando2 := aFormula[4]

//Executando as fórmulas
	lSkipNPIResultCache := .T.
	nVal1      := xFisExecNPI(cOperando1, aNFItem, nItem, jMapForm, .F., .F., nPosTrbProc, cDetTrib, aNfCab)
	nVal2      := xFisExecNPI(cOperando2, aNFItem, nItem, jMapForm, .F., .F., nPosTrbProc, cDetTrib, aNfCab)
	lSkipNPIResultCache := lSkipCacheBkp
// Caso o campo F2B_RDBASE foi preenchido, entao aplico o percentual no total da base auxiliar ...
	If fisExtCmp('12.1.2410', .T.,'F2B','F2B_RDBASE') .and. aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REDBASEAUX] > 0 .and. aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REDBASEAUX] < 100
		nVal2 := nVal2 * ( aNfItem[nItem][IT_TRIBGEN][nPosTrbProc][TG_IT_REDBASEAUX]/100 )
	EndIf

//Se valor1 for maior, retorna o opernado 1, caso contrário retonar o 2
	If cTipo == "MAIOR"
		If nVal1 > nVal2
			return cOperando1
		EndIf
	Else
		//MENOR
		If nVal1 < nVal2
			return cOperando1
		EndIf
	EndIf

Return cOperando2

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadTabPrg

Função que faz cache das informações da tabela progressiva, para que seja evitado
acesso ao banco de dados durante todo o cálculo

@param cCodTab   - Operando a ser verificado
@param aTabProg   - Array com o cahce
@param nDedSimp   - Valor da dedução simplificada do IRPF

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function LoadTabPrg(cCodTab, aTabProg, nDedSimp)

	Local nPos := 0

//Se código estiver vazio encerra
	If Empty(cCodTab)
		Return
	EndIF

//Se código já foi cacheado também encerra
	If ( nPos := AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cCodTab)}) ) > 0
		nDedSimp := aTabProg[nPos][Len(aTabProg[nPos])]
		Return
	EndIF

	CIQ->(dbSetOrder(1)) //CIQ_FILIAL+CIQ_CODIGO
	CIR->(dbSetOrder(3)) //CIR_FILIAL+CIR_IDCAB

	If CIQ->(MsSeek(xFilial("CIQ") + cCodTab)) .And. !Empty(CIQ->CIQ_ID) .And. CIR->(MsSeek(xFilial("CIR") + CIQ->CIQ_ID))

		Do While !CIR->(EOF()) .AND. CIQ->CIQ_ID == CIR->CIR_IDCAB
			//Aqui estou posicionado nos itens da tabela
			//Estrutura do Array
		/*
		-Código da tabela
		-Valor Inicial
		-Valor Final
		-Valor da Alíquota
		-Valor da Dedução
		*/

			//Obtenho a posição caso já esteja preenchido
			nPos:= AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cCodTab)})

			//Adiciono se não existir
			IF nPos == 0
				aAdd(aTabProg,{cCodTab} )
				nPos := Len(aTabProg)
			EndIF

			//Adiciono valores no array.
			aAdd(aTabProg[nPos],{CIR->CIR_VALINI, CIR->CIR_VALFIM, CIR->CIR_ALIQ, CIR->CIR_VALDED} )

			CIR->(DbSKip())
		EndDo

		If lFaixaEsp // Se tiver a tabela da faixa especial, carrega tambem os dados da mesma 

			If CIQ->CIQ_DEDSIR > 0
				nDedSimp := CIQ->CIQ_DEDSIR
			EndIf

			//Obtenho a posição caso já esteja preenchido
			If ( nPos := AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cCodTab)}) ) > 0
				aAdd(aTabProg[nPos],nDedSimp)
			EndIf

			DbSelectArea("CI2")			
			CI2->(dbSetOrder(2)) //CI2_FILIAL+CI2_IDCAB 
			CI2->(MsSeek(xFilial("CI2") + CIQ->CIQ_ID))
			
			Do While !CI2->(EOF()) .AND. CIQ->CIQ_ID == CI2->CI2_IDCAB
				aAdd(aTabAdic,{CI2->CI2_RENDIN, CI2->CI2_RENDFI, CI2->CI2_FATOR , CI2->CI2_REDMAX} )
				CI2->(DbSKip())
			EndDo

			CI2->(DbCloseArea())
		EndIf

	EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} PosTabPrg

Função auxiliar para buscar informações da tabela progressiva no cache

@param cOperando   	- Operando a ser verificado
@param aNFItem   	- Array com informações do item da nota
@param nItem   		- Número do item da nota fical
@param nPosTrbProc  - Posicção do tributo genérico que está sendo processado
@param nValorRef    - Valor de referência a ser comparado com faixas da tabela progressiva

@return Array  - Alíquota e valor da dedução caso se enquadre na tabela

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function PosTabPrg(cOperando, aNFItem, nItem, nPosTrbProc, nValorRef)

	Local nPos 			:= AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cOperando)})
	Local nX   			:= 0
//Posições para facilitar leitura do array
	Local nPosValIni	:= 1
	Local nPosValFim	:= 2
	Local nPosAliq		:= 3
	Local nPosDeduc		:= 4

//Verifico se a tabela está no cache
	IF nPos > 0

		//Encontrou a tabela progressiva correspondente
		For nX := 2 To Len(aTabProg[nPos]) - 1 // a última posição do aTabProg[nPos] é o valor da dedução simplificada, por isso deve ser ignorada neste loop

			//Verifico se valor da base de cálculo está contida na faixa entre os valores mínimo e máximo
			IF nValorRef >= aTabProg[nPos][nX][nPosValIni] .And. nValorRef <= aTabProg[nPos][nX][nPosValFim]
				//O valor foi enquadrado
				Return {aTabProg[nPos][nX][nPosAliq], aTabProg[nPos][nX][nPosDeduc]}
				Exit
			EndIF

		Next nX

	EndIF

//Retornarei zero caso não enquadre na tabela.
Return {0,0}

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDedDep

Função que faz cache das informações da tabela progressiva, para que seja evitado
acesso ao banco de dados durante todo o cálculo

@param cCodTab   - Operando a ser verificado
@param aTabProg   - Array com o cahce

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function LoadDedDep(cCodTab, aTabDep)

//Se código estiver vazio encerra
	If Empty(cCodTab)
		Return
	EndIF

//Se código já foi cacheado também encerra
	If AScan(aTabDep, { |x| Alltrim(x[1]) == Alltrim(cCodTab)}) > 0
		Return
	EndIF

	CIV->(dbSetOrder(4)) //CIV_FILIAL+CIV_CODDEP+CIV_ALTERA

	If CIV->(MsSeek(xFilial("CIV") + PADR(cCodTab, 6) + "2"))

		//Aqui estou posicionado nos itens da tabela
		//Estrutura do Array
	/*
	-Código da tabela
	-VAlor da dedução por dependente
	*/

		//Adiciono valores no array.
		aAdd(aTabDep,{CIV->CIV_CODDEP, CIV->CIV_VALDEP, CIV->CIV_TPDATA} )

	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValNfAnt

Função que buscará informações e valores de notas anteriores, considerando
o participante e range de datas.

@param cRegraTrib   - Código da regra do tributo
@param cTpNF      - Tipo do doumento fiscal, nota de entrada, saída
@param cCodPart   - Código do participante
@param cLojaPart  - Loja do participante
@param dDtIni     - Data inicial do range
@param dDtFim     - Data final do range
@param cTpData	  - Tipo da data que será filtrado no financeiro

@return aRet      - Array com os valores retornado

@author Erick Dias
@since 14/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ValNfAnt(cRegraTrib, cTpNF, cCodPart, cLojaPart, dDtIni, dDtFim, cCampoRet, cTpData)
	Local nRet		:= 0
	Local nX		:= 0
	Local cAliasQry := GetNextAlias()
	Local cSelect	:= ""
	Local cFrom		:= ""
	Local cWhere	:= ""
	Local cTabela 	:= Iif(cTpNF == "E", "SD1", "SD2")
	Local cAliasCpo	:= Iif(cTpNF == "E", "SE2.E2", "SE1.E1")
	Local cJoinFin	:= ""
	Local cTabOrg := "F2D"
	Local cPrexCpo:= "F2D"

	Default cTpData:= ""

//Se estas infomrações não estiverem preenchidas retornarei zero!
	If Empty(cRegraTrib) .OR. Empty(cTpNF) .Or. Empty(cCodPart) .Or. Empty(cLojaPart) .Or. Empty(cCampoRet)
		Return 0
	EndIF

	// Caso seja um busca na SD1/SD2, alterado o que irá ser colocado no select dinamicamente
	If cCampoRet == "TOTAL" // D1_TOTAL ou D2_TOTAL
		cTabOrg := cTabela
		cPrexCpo:= SUBSTR(cTabela,2,2)
	EndIF

//Verifico se já realizei a busca no array com cache das consultas SQL
/*
Estrutura do array
1-Tributo
2-Campo F2D
3-Tipo(Entrada/saída)
4-Codigo participante
5-Loja participante
6-Data ini
7-Data fim
8-Valor
*/
	nX := aScan(aPesqF2D,{|x| x[1] == cRegraTrib .And. ;
		x[2] == cCampoRet .And. ;
		x[3] == cTpNF .And. ;
		x[4] == cCodPart .And. ;
		x[5] == cLojaPart .And. ;
		x[6] == dDtIni .And. ;
		x[7] == dDtFim })

//Verifica se query está no cache. Se estiver basta retornar os valores
	IF nX > 0
		//Aqui apenas retorno o valor
		Return	aPesqF2D[nX][8]
	Else

		//Aqui farei a consulta pela primeira vez e armazenarei no array de cache
		cSelect := "SUM( "+cTabOrg+"."+cPrexCpo+"_" + cCampoRet + " ) VALOR"

		//From na tabela F2D
		cFrom   += RetSQLName("F2D") + " F2D "

		IF cTpNF == "E" //Entrada, farei JOIN com SD1
			//JOIN SD1/SF1
			cFrom += "JOIN " + RetSQLName("SD1") + " SD1 " + " ON (SD1.D1_FILIAL = " + ValToSQL(xFilial("SD1")) + " AND SD1.D1_IDTRIB = F2D.F2D_IDREL AND SD1.D1_FORNECE = " + ValToSQL(cCodPart) + " AND SD1.D1_LOJA = " + ValToSQL(cLojaPart) + " AND SD1.D1_EMISSAO BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDtFim) + " AND SD1.D_E_L_E_T_ = ' ') "
			cFrom += "JOIN " + RetSQLName("SF1") + " SF1 " + " ON (SF1.F1_FILIAL = " + ValToSQL(xFilial("SF1")) + " AND SF1.F1_DOC = SD1.D1_DOC AND SF1.F1_SERIE = SD1.D1_SERIE AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA AND SF1.D_E_L_E_T_ = ' ') "
		ElseIF cTpNF == "S" //Saída, farei JOIN com SD2
			//JOIN SD2/SF2
			cFrom += "JOIN " + RetSQLName("SD2") + " SD2 " + " ON (SD2.D2_FILIAL = " + ValToSQL(xFilial("SD2")) + " AND SD2.D2_IDTRIB = F2D.F2D_IDREL AND SD2.D2_CLIENTE = " + ValToSQL(cCodPart) + " AND SD2.D2_LOJA = " + ValToSQL(cLojaPart) + " AND SD2.D2_EMISSAO BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDtFim) + " AND SD2.D_E_L_E_T_ = ' ') "
			cFrom += "JOIN " + RetSQLName("SF2") + " SF2 " + " ON (SF2.F2_FILIAL = " + ValToSQL(xFilial("SF2")) + " AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_CLIENTE = SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA AND SF2.D_E_L_E_T_ = ' ') "
		EndIF

		//Pesquisar no financeiro os títulos das notas fiscais
		If !Empty(cTpData) .AND. cTpData <> '4'

			//Adicionar o filtro de qual data será considerada no filtro
			If cTpData == "2" //1= Emissao; 2= Vencimento Real; 3=Data Contabilizacao
				cJoinFin += cAliasCpo + "_VENCREA  BETWEEN "+ ValToSql(FirstDay(dDataBase)) + " AND "+ValToSql(LastDay(dDataBase)) + " AND "+ Left(cAliasCpo,4) + "D_E_L_E_T_ = ' ' "
			ElseIf cTpData == "1"
				cJoinFin += cAliasCpo + "_EMISSAO  BETWEEN "+ ValToSql(FirstDay(dDataBase)) + " AND "+ValToSql(LastDay(dDataBase)) + " AND "+ Left(cAliasCpo,4) + "D_E_L_E_T_ = ' ' "
			Else
				cJoinFin += cAliasCpo + "_EMIS1  BETWEEN "+ ValToSql(FirstDay(dDataBase)) + " AND "+ValToSql(LastDay(dDataBase)) + " AND "+ Left(cAliasCpo,4) + "D_E_L_E_T_ = ' ' "
			EndIf

			IF cTpNF == "E" //Entrada, farei JOIN com SE2
				//JOIN SE2
				cFrom += "JOIN " + RetSQLName("SE2") + " SE2 " + " ON (SE2.E2_FILIAL = " + ValToSQL(xFilial("SE2")) + " AND SE2.E2_FORNECE = SF1.F1_FORNECE AND SE2.E2_LOJA = SF1.F1_LOJA AND SE2.E2_PREFIXO = SF1.F1_PREFIXO AND SE2.E2_NUM = SF1.F1_DOC AND " + cJoinFin + ") "
			ElseIf cTpNF == "S" //Saída, farei JOIN com SE1
				//JOIN SE1
				cFrom += "JOIN " + RetSQLName("SE1") + " SE1 " + " ON (SE1.E1_FILIAL = " + ValToSQL(xFilial("SE1")) + " AND SE1.E1_CLIENTE = SF2.F2_CLIENTE AND SE1.E1_LOJA = SF2.F2_LOJA AND SE1.E1_PREFIXO = SF2.F2_PREFIXO AND SE1.E1_NUM = SF2.F2_DOC AND " + cJoinFin + ") "
			EndIf
		EndIf

		//
		cWhere  += " F2D.F2D_FILIAL = " + ValToSQL(xFilial("F2D"))  + " AND "
		cWhere  += " F2D.F2D_TRIB = "   + ValToSQL(cRegraTrib)      + " AND "
		cWhere  += " F2D.F2D_TABELA = " + ValToSQL(cTabela)         + " AND "
		cWhere  += " F2D.F2D_DTEXCL = ' ' AND "
		cWhere  += " F2D.D_E_L_E_T_ = ' '"

		//Concatenará o % e executará a query.
		cSelect := "%" + cSelect + "%"
		cFrom   := "%" + cFrom   + "%"
		cWhere  := "%" + cWhere  + "%"

		BeginSQL Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

		EndSQL

		//Laço no resultado da query
		Do While !(cAliasQry)->(Eof())

			//Obtenho o valor já somado pela query
			nRet	:= (cAliasQry)->VALOR

			(cAliasQry)->(DbSKip())
		Enddo

		//Fecha o Alias antes de sair da função
		dbSelectArea(cAliasQry)
		dbCloseArea()

		//Aqui adiciono pesquisa no cache para não ser refeito posteriormente
		aAdd(aPesqF2D,{cRegraTrib, cCampoRet, cTpNF, cCodPart,cLojaPart, dDtIni, dDtFim, nRet  } )

	EndIF

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValDepOutItem

Função auxiliar que buscará valores de dedução de dependentes já utilizados
nos demais itens do documento fiscal

@param aNfItem   - Array com informações dos itens
@param nItem     - Item que está sendo processado
@param cTrib     - Tributo que está sendo processado

@return nRet      - Somatório do valor somado de todos os itens, exceto item atual

@author Erick Dias
@since 15/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ValDepOutItem(aNfItem, nItem, cTrib)

	Local nX		:= 0
	Local nTrbGen	:= 0
	Local nRet 		:= 0

//Laço nos itens
	For nX :=1 To Len(aNfItem)

		//Somente linhas nao deletadas e não pode ser o mesmo item
		If !aNfItem[nX][IT_DELETED] .AND. nItem <> nX

			//Vejo se o tributo existe no item, e obtenho a posição dele, já que não necessáriamente será a mesma para todos os itens
			IF (nTrbGen	:= aScan(aNfItem[nX][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cTrib)})) > 0
				//Acumulo o valor de dedução já utilizado nos demais itens
				nRet += aNfItem[nX][IT_TRIBGEN][nTrbGen][TG_IT_DED_DEP]
			EndIF

		Endif
	Next nX

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DefMunServ

Função que retorna o código de município com 7 dígitos do estabelecimento do
prestador de serviço, e do local de execução de serviço.

@param aNFCab   - Array com informações dos itens
@param cUfEP   - UF do município do estabelecimento do prestador
@param cMumEP   - Município do estabelecimento do prestador (5 dígitos)
@param cUFLES   - UF da execução do serviço
@param cMunLES   - Município da execução do serviço (5 dígitos)

@author Erick Dias
@since 21/07/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function DefMunServ(aNFCab, cUfServ, cMumServ, lLES)

	Local cCodMunM0	:= Iif(Len(Alltrim(SM0->M0_CODMUN))==5, Alltrim(SM0->M0_CODMUN), Substr(Alltrim(SM0->M0_CODMUN),3,5) )

	If lLES //Local de execução do serviço
		//UF e município do local de execução do serviço
		cUfServ		:= aNFCab[NF_UFPREISS]
		cMumServ	:= aNFCab[NF_CODMUN]
	Else
		//UF e municípios do estabelecimento do prestador
		cUfServ	:= aNFCab[NF_UFORIGEM]
		cMumServ	:= IIf( aNfCab[NF_OPERNF] == "S" , cCodMunM0 , aNFCab[NF_CODMUN] ) //Saída utiliza próprio município, entrada utiliza do participante
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcEscrTG

Função auxiliar para facilitar o preenchimento das referências do livro dos tributos genéricos.

@author Erick Dias
@since 21/0/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ProcEscrTG(aNfItem, nItem, nTrbGen, cCst, vValTrib, ;
		nIsento, nOutros, nNaotrib, nDiferido, nMajorado, ;
		nPerMaj, nPerDif, nPerRed, nPauta, nMva, ;
		nAuxMva, nAuxMaj, cTabCst, nBaseOri , nAliTrb,;
		nAliqRed, nAliqOri, cCCT, cNLivro, cIndOper)

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CSTCAB]			:= cTabCst
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CST]			:= cCst
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_VALTRIB]		:= vValTrib
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ISENTO]			:= nIsento
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_OUTROS]			:= nOutros
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_NAO_TRIBUTADO]	:= nNaotrib
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]		:= nDiferido
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MAJORADO]		:= nMajorado
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_MAJORACAO]	:= nPerMaj
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_DIFERIDO]	:= nPerDif
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_REDUCAO]	:= nPerRed
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PAUTA]			:= nPauta
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_MVA]			:= nMva
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MVA]		:= nAuxMva
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_AUX_MAJORACAO]	:= nAuxMaj
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]	    := nBaseOri
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALIQTR]	    	:= nAliTrb
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALQ_REDALI]		:= nAliqRed
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALQ_ORI]		:= nAliqOri
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_CCT]	    	:= cCCT
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_NLIVRO]	    	:= cNLivro
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_INDOP] 		    := cIndOper

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisLivroTG

Função que terá as regras de definições da escrturação do livro dos
tributos genéricos.
Aqui serão realizadas as decisões para quais colunas os valores deverão ser gravados

//TODO arredondamento dos valores do livro

@param aNfItem   - Array com informações dos itens
@param nItem     - Item que está sendo processado
@param nTrbGen   - Tributo que está sendo processado
@param aNfCab    - Array com informações do cabeçalho da nota
@param jMapForm  - Array com mapeamento das fórmulas
@param lEdicao   - Indica se está em modo de edição
@param lReproc   - Indica se está sendo reprocessado
@param lDevolucao - Indica se está sendo processado uma devolução

@author Erick Dias
@since 21/0/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, lEdicao, lReproc, lDevolucao)

	Local nIsento    := 0
	Local nTribut    := 0
	Local nOutros    := 0
	Local lCacheInit := .F.  // Flag para cleanup condicional - defensive init ownership pattern
	Local cCst       := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CST]
	Local cTabCst    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CSTCAB]
	Local cIncide    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE]
	Local nPercDif   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_PERCDIF]
	Local nDiferido  := 0
	Local nNaotrib   := 0 //pendente
	Local nMajorado  := 0
	Local nPerMaj    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MAJ]
	Local nPerRed    := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO]
	Local nPauta     := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_PAUTA]
	Local nMva       := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MVA]
	Local nAuxMva    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MVA]
	Local nAuxMaj    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_AUX_MAJ]
	Local nAliqTr    := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQTR]
	Local nTrbMaj    := 0
	Local nParcRed   := 0 //pendente
	Local cIncideRed := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED]
	Local nBaseOri   := 0
	Local nDifTrib   := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
	Local nAliqRed   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_REDUCAO]
	Local nAliqOri   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_ALQ_ORI]
	Local cCCT	  	 := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_CCT]
	Local cNLivro 	 := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_NLIVRO]
	Local cIndOper   := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INDOP]

	Default lReproc	:= .F.
	Default lDevolucao := .F.

	If lDevolucao .and. lIncideDev
		If !Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE_DEV])
			cIncide	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INCIDE_DEV]
		Endif
		If !Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED_DEV])
			cIncideRed	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_INC_PARC_RED_DEV]
		Endif
	Endif


	//Inicializa cache L1 unificado se não existe
	If ValType(jNPIResultCache) != 'J'
		InitMemoCalc()
		lCacheInit := .T.
	EndIf

//----------
//Tributado
//----------
	If cIncide $ "1|4|5|7" //Tributado

		//Aqui iniciamos o valor tributado com o resultado da fórmula NPI
		nTribut	:= nDifTrib

		//Aqui posiciono no tributo que efetuou a majoração, para obter o valor majorado
		If(nTrbMaj 	:= GetPosTrib(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_TRB_MAJ] , aNfItem, nItem)) > 0
			nMajorado	:= aNfItem[nItem][IT_TRIBGEN][nTrbMaj][TG_IT_LF][TG_LF_VALTRIB] //Considero o valor tributado aqui
		EndIF
	EndIf
//----------
//ISENTO
//----------
	IF cIncide $ "2|4|6|7" //Isento

		//Verifico se a fórmula está preenchida aqui
		If Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_ISE_NPI])
			//Se a fórmula estiver vazia, então por padrão será adotado a base de cálculo
			nIsento	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] //elaborar fórmula, por enquanto será a base de calculo
		Else
			//Aqui a fórmula será executada
			nIsento	:= xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_ISE_NPI], aNFItem, nItem, jMapForm, lEdicao,.T., nTrbGen,, aNfCab)
		EndIF
	EndIf
//----------
//OUTROS
//----------
	If cIncide $ "3|5|6|7" //Outros

		//Verifico se a fórmula está preenchida aqui
		If Empty(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_OUT_NPI])
			//Se a fórmula estiver vazia, então por padrão será adotado a base de cálculo
			nOutros	:= aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] //elaborar fórmula, por enquanto será a base de calculo
		Else
			//Aqui a fórmula será executada
			nOutros	:= xFisExecNPI(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_OUT_NPI], aNFItem, nItem, jMapForm, lEdicao,.T., nTrbGen,, aNfCab)
		EndIF

	EndIf
    
    //Aqui preciso verificar se exste diferimento, observando se percentual de diferimento é maior que zero
	IF lReproc //Quando for reprocessamento, não será necessário calcular novamente, devendo apenas carregar os valores
		nPercDif  := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_PERC_DIFERIDO]
		nDiferido := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_DIFERIDO]
	Else
		If nPercDif == 100
			//Obtem o valor a ser diferido
			nDiferido:= nDifTrib
		ElseIf nPercDif > 0
			nDiferido := FisCalcDifer(aNFCab, aNFItem, nItem, nTrbGen, nPercDif, nDifTrib, lEdicao, nAliqTr) 
		EndIf
	Endif

//-------------------------------------------
//Verifico se tem redução de base de cálculo
//-------------------------------------------
	IF nPerRed > 0

		//Por padrão será adotado coluna outras
		cIncideRed	:= Iif(Empty(cIncideRed), "2", cIncideRed)

		//Aqui para evitar erros de arredondamento, farei a diferença entre a base de cálculo sem percentual de dedução pelo parceça não reduzida
		nBaseOri	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LF][TG_LF_BASE_ORI]

		//Obtenho a parcela reduzida.
		nParcRed	:= nBaseOri - aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]

		//Se a parcela reduzida for maior que zero então verifico a incidência da redu
		IF nParcRed > 0

			If cIncideRed == "1" //Isento
				nIsento += nParcRed

			ElseIF cIncideRed == "2" //Outros
				nOutros += nParcRed
			EndIF

		EndIF

	EndIf

//-------------------------------------------------------------
//Aqui atualizo as referências do livro dos tributos genéricos
//Somente se possuir opção de incidência definida, caso contrário não
//preencherá as referências do livro!
//-------------------------------------------------------------
	If !Empty(cIncide) .and. !ReprIntegr(aNfItem, nItem, nTrbGen)
		ProcEscrTG(aNfItem, nItem, nTrbGen, cCst, nTribut, ;
			nIsento, nOutros, nNaotrib, nDiferido, nMajorado, ;
			nPerMaj, nPercDif, nPerRed, nPauta, nMva, ;
			nAuxMva, nAuxMaj, cTabCst, nBaseOri , nAliqTr, nAliqRed, nAliqOri, cCCT , cNLivro, cIndOper)
	EndIF


// CLEANUP CONDICIONAL: Só limpa se FisLivroTG inicializou o cache (ownership pattern)
// Se FisTribGen/FisLoadTG inicializou, deixa eles gerenciarem o ciclo completo
	If lCacheInit
		EndMemoCalc()
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FisXDelCJ3
	Função que faz a exclusão dos dados da tabela CL3. Aqui a hipótese para exclusão
	é via reprocessamento, já que ao excluir/cancelar uma nota fiscal, apenas
	preenchemos a data de exclusão/cancelamento.
	Update - anedino.santos - agora a função abre exceção para de fato deletar
	registros, pois	há ocasiões em que se faz necessário. DSERFISE-8594 (28/02/2024)

	@param cIdTrbGen, character, ID para buscar as informações que serão deletadas
	@param nOpcao, numeric, opção de exclusão
	@param lException, logical, exceção para delete efetivo do registro

	@author Erick Dias
	@since 21/0/2020
	@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisXDelCJ3(cIdTrbGen, nOpcao, lException, cIdSFT)

	default lException := .F.

//Verifica se tabela de livro dos tributos genéricos existe
	If lAliascj3 .and. !Empty(cIdTrbGen) .And. !Empty(nOpcao)

		dbSelectArea("CJ3")
		dbSetOrder(2)

		//Procura pelos tributos para serem alterados como excluídos
		IF CJ3->(MsSeek(xFilial("CJ3")+cIdTrbGen))

			//Laço para excluir a escrituração do tributo genérico
			While !CJ3->(Eof()) .And. xFilial("CJ3") == CJ3->CJ3_FILIAL .And. cIdTrbGen == CJ3->CJ3_IDTGEN

				RecLock("CJ3",.F.)

				If nOpcao == "1"//Exclusão/cancelamento da nota, apenas atualizo a data de exclusão
					CJ3->CJ3_DTEXCL := dDataBase
					// há casos em que se faz necessário excluir o registro.
					// na maioria das vezes é quando os livros fiscais SFT/SF3 são deletados
					if lException .And. Empty(cIdSFT)
						CJ3->(dbDelete())
					endif
				ElseIf nOpcao == "2"//Exclusão da CJ3(Reprocessamento)
					CJ3->(dbDelete())
				EndIf

				MsUnLock()
				CJ3->(FkCommit())
				CJ3->(dbSkip())

			EndDo

		EndIF

	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FisSumTG

Função que faz a soma do valor de cada tributo por item no total
da nota fiscal.

@author Renato Rezende
@since 28/08/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisSumTG(aNfItem, nItem)

	Local nTrbGen	:= 0
	Local nValBDupl	:= 0
	Local lGeraDupl := aNfItem[nItem][IT_TS][TS_DUPLIC] == "S"

//Percorro todos os tributos genéricos do item para carregar os valores
	For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

		//Tributo genérico tratamento de escrituração do valor total da nota
		//Soma total da NF
		If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '5|6|9'
			aNfItem[nItem][IT_TOTAL] += aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

			//Subtrai do total da NF
		ElseIf aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '2|3'
			aNfItem[nItem][IT_TOTAL] -= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
		EndIf

		//Tratamento para duplicata, so atualiza se na TES estiver para calcular duplicata
		If lGeraDupl
			//Tratamento para Base da Duplicata
			//Soma total da base da duplicata
			If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '6|7'
				nValBDupl += aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

				//Subtrai do total da base da duplicata
			ElseIf aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '3|4'
				nValBDupl -= aNFitem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]

				//Gross up no total da Duplicata
			ElseIf aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '8'
				aNfItem[nItem][IT_BASEDUP] := aNfItem[nItem][IT_BASEDUP] / ( 1 - ( aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] / 100 ) )
			EndIf
		EndIf

	Next nTrbGen

//Não é feito a soma ou a subtração da base da duplicata porque é preciso primeiro fazer o Gross up e depois essa operação
//Base da Duplicata
	If nValBDupl <> 0
		aNfItem[nItem][IT_BASEDUP] += nValBDupl
	EndIf

//Tratamento para evitar valor negativo
	aNfItem[nItem][IT_BASEDUP]:= Max(aNfItem[nItem][IT_BASEDUP],0)
	aNfItem[nItem][IT_TOTAL]:= Max(aNfItem[nItem][IT_TOTAL],0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTgTot

Função que verifica se existe ao menos algum tributo que altera o valor
total da nota ou o valor da duplicata. Se existir então retorna verdadeiro

@author Erick Dias
@since 09/03/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function ChkTgTot(aNfItem, nItem)

	Local nTrbGen	:= 0

//Percorro todos os tributos genéricos do item para carregar os valores
	For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])

		//Tributo genérico tratamento de escrituração do valor total da nota ou duplicata
		//Soma ou subtrai total da NF ou da duplicata
		If aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ESCR][RE_TOTNF]	$ '2|3|4|5|6|7|9'
			//Se houver ao menos alguma regra que necessidade de alterar valor total ou da duplicata então já retorno verdadeiro
			Return .T.
		EndIf

	Next nTrbGen

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} xRefTotLf

Função para verifica se foi alterado o total, ou a base da duplicata,
ou o valor contábil para refazer os tributos dependentes das referências

@author Renato Rezende
@since 04/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function xRefTotLf(aNfCab, aNfItem, nItem, aPos, aDic, aTGITRef, jMapForm, jDepTrib, aDepVlOrig, aFunc, aUltPesqF2D, dVencReal, nTot )

	Local nTotTg	:= 0
	Local nTotBD	:= 0

	Default nTot	:= 0

//Verifico se algum tributo genérico precisa alterar valor total ou de duplicata
	If ChkTgTot(aNfItem, nItem)

		nTotTg	:= aNfItem[nItem][IT_TOTAL]
		nTotBD	:= aNfItem[nItem][IT_BASEDUP]

		//Garantindo a soma no valor total de todos os tributos
		MaFisVTot(nItem)

		//Refaz o Livro
		MaFisLF(nItem)

		//Verifica se o total da nota foi alterado após passar na vTot e na LF
		//Somente farei se o TG alterou o valor total ou se outro tributo alterou o valor total.
		If nTotTg <> aNfItem[nItem][IT_TOTAL] .Or. (nTot > 0 .And. nTot <> aNfItem[nItem][IT_TOTAL])
			xFisTrbGen(aNfCab, @aNfItem, nItem, "IT_TOTAL",,, aPos, aDic, Len(aTGITRef), jMapForm, jDepTrib, aDepVlOrig,aFunc, aUltPesqF2D)
			xFisTrbGen(aNfCab, @aNfItem, nItem, "LF_VALCONT",,, aPos, aDic, Len(aTGITRef), jMapForm, jDepTrib, aDepVlOrig,aFunc, aUltPesqF2D)

			//Chama funções do legado para atualizar tributos legado que dependem do Total, caso algum tributp genérico tenha aterado
			MaFisCOFINS(nItem,"CF3")
			MaFisPIS(nItem,"PS3")
			MaFisFMPEQ(nItem)
			MaFisINSS(nItem,"BSE|VLR")
			MaFisIR(nItem,,dVencReal)
			MaFisISS(nItem)
			MaFisSENAR(nItem)
			MaFisSEST(nItem)
		EndIf

		//Verifica se o total da base da duplicata da nota foi alterado após passar na vTot e na LF
		If nTotBD <> aNfItem[nItem][IT_BASEDUP]
			xFisTrbGen(aNfCab, @aNfItem, nItem, "IT_BASEDUP",,, aPos, aDic, Len(aTGITRef), jMapForm, jDepTrib, aDepVlOrig,aFunc, aUltPesqF2D)

			//Chama funções do legado para atualizar tributos legado que dependem do BASEDUP, caso algum tributp genérico tenha aterado
			MaFisCIDE(nItem)
			MaFisCOFINS(nItem,"CF2")
			MaFisPIS(nItem,"PS2")
			MaFisCSLL(nItem)
			MaFisISS(nItem)
		EndIf

	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisAddGNRE

Função que efetua a gravação da GNRE para os tributos genéricos.
Aqui buscaremos os valores calculados pelo configurador
e faremos a geração da SF6 conforme regras cadastradas pelo usuário nas
regras de GNRE do configuradr.

@param nRecnoNF - recno da nota fiscal
@param cAlias - alias da nota fiscal.

@author Erick Dias
@since 21/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function xFisAddGNRE(nRecnoNF, cAlias, aTGCalcRec)

	Local cDoc 	  	:= ""
	Local cSerie  	:= ""
	Local cPart	  	:= ""
	Local cLoja	  	:= ""
	Local cOperNF	:= ""
	Local cSDoc		:= ""
	Local cNumGNRE 	:= ""
	Local cTributo  := ""
	Local cTipoDoc 	:= ""
	Local cIdNf     := ""
	Local cTipoImp	:= "D" //Tributos genéricos
	Local cEstNF 	:= ""
	Local cEst 		:= ""
	Local cEstOri 	:= ""
	Local cEstDest	:= ""
	Local cTipoNF	:= ""
	Local cInscPart := ""
	Local cInsc 	:= ""
	Local cCNPJPart	:= ""
	Local cCNPJ		:= ""
	Local cModelo	:= ""
	Local cCodrec	:= ""
	Local cDetalhe	:= ""
	Local cRef		:= ""
	Local cCobRec	:= ""
	Local cMvEstado := GetNewPar("MV_ESTADO","")
	Local dDtArrec  := dDataBase
	Local aTGCalc	:= {}
	Local aCodrec	:= {"","",""}
	Local nMes		:= 0
	Local nAno		:= 0
	Local nValor 	:= 0
	Local nX		:= 0
	Local nPosTrib  := 0
	Local oModel	:= Nil
	Local dDtPadrao	:= DataValida( LastDay( dDataBase ) + 1, .T.) //Inicio com padrão do primeiro dia útil do próximo mês
	Local dDtVenc	:= CTOD("//")
	Local lCodrec	:= fisFindFunc("CodRec")
	Local cIDTOTVS	:= ""

//Somente prosseguirei com o recno da nota e o alias preenchidos!
	If Empty(nRecnoNF) .Or. Empty(cAlias)
		Return
	EndIF

//Se o campo não existir não processarei geração das guias
	IF !SF6->(FieldPos("F6_IDNF")) > 0
		Return
	EndIF

//Verifico se o alias é algum que está previsto nesta função, caso contrário não continuara
	IF cAlias <> "SF2" .AND. cAlias <> "SF1"
		Return
	EndIF

//Aqui verifico se existe a referência e se ela está preenchida antes de continuar
	If Empty(MaFisScan("NF_TRIBGEN",.F.))
		Return
	EndIf

//Posiciono aqui a tabela para obter informações
	dbSelectArea(cAlias)
	MsGoto(nRecnoNF)

//A partir daqui podemos obter as informações necessárias da nota para gerar a GNRE
//Por enquanto a rotina apenas trata as informações:
//-Nota de Saída
//-Nota de Entrada
	IF cAlias == "SF2"
		cDoc 	 := SF2->F2_DOC
		cSerie 	 := SF2->F2_SERIE
		cPart 	 := SF2->F2_CLIENTE
		cLoja 	 := SF2->F2_LOJA
		cEstNF 	 := SF2->F2_EST
		cTipoDoc := SF2->F2_TIPO
		cIdNf	 := SF2->F2_IDNF
		cTipoNf  := SF2->F2_TIPO
		cEstOri  := SF2->F2_UFORIG
		cEstDest := SF2->F2_UFDEST
		cOperNF  := "2" //Saída
		cModelo	 := AllTrim(SF2->F2_ESPECIE)
		nMes     := Month(SF2->F2_EMISSAO)
		nAno     := Year(SF2->F2_EMISSAO)

		If SA1->(MsSeek(xFilial("SA1")+cPart+cLoja))
			cInscPart := SA1->A1_INSCR
			cCNPJ := SA1->A1_CGC
		EndIf

	ElseIF cAlias == "SF1"
		cDoc   	 := SF1->F1_DOC
		cSerie 	 := SF1->F1_SERIE
		cPart  	 := SF1->F1_FORNECE
		cLoja  	 := SF1->F1_LOJA
		cEstNF   := SF1->F1_EST
		cTipoDoc := SF1->F1_TIPO
		cIdNf	 := SF1->F1_IDNF
		cTipoNf  := SF1->F1_TIPO
		cEstOri  := Iif(Empty(SF1->F1_UFORITR), SF1->F1_EST , SF1->F1_UFORITR)
		cModelo	 := AModNot(Alltrim(SF1->F1_ESPECIE))
		cEstDest := SF1->F1_ESTDES
		cOperNF  := "1" //Entrada
		nMes 	 := Month(SF1->F1_EMISSAO)
		nAno 	 := Year(SF1->F1_EMISSAO)

		If SA2->(MsSeek(xFilial("SA2")+cPart+cLoja))
			cInscPart := SA2->A2_INSCR
			cCNPJ := SA2->A2_CGC
		EndIf

	EndIF

//Para o tipo de devolução não gerarei GNRE
	If cTipoNf == "D"
		Return
	EndIf

//Tratamento para obter o SDOC
	If SerieNfId("SF6",3,"F6_SERIE") == "F6_SDOC"
		cSDoc	:=	SubStr(cSerie,1,3)
	EndIf

//Obtenho o cálculo dos tibutos genéricos
	aTGCalc := MaFisRet(,"NF_TRIBGEN")

//Laço nos tributos genérico para verificar se possui regra de geração de GNRE
	For nX := 1 to Len(aTGCalc)

		//Obtem o tributo
		cTributo	:= aTGCalc[nX][1]
		cIDTOTVS	:= aTGCalc[nX][TG_NF_IDTRIB]

		IF !EMPTY( cIDTOTVS )
			cTipoImp := RelTipoGNRE( cIDTOTVS)
		Endif

		nValor	:= aTGCalc[nX][3]
		If Len(aTGCalc[nX]) >= 10 .And. CJ4->CJ4_MAJSEP == "1"
			nValor	:= nValor -  aTGCalc[nX][10]
		EndIf

		//Primeiro vejo se tem regra de guia vinculada
		//Se tem regra de guia vinculada, preciso então posicionar para certificar se a nota se enquadra na configuração da regra
		If Len(aTGCalc[nX]) >=9 .And. EnqNFGNRE(aTGCalc[nX][9], cEstNF, cOperNF) .And. nValor > 0

			//Irei verificar se este tributo já gerou título de recolhimento, se sim, então vou considerar o mesmo número, caso contrário pegarei próximo número
			If (nPosTrib	:=  AScan(aTGCalcRec, { |x| Len(x) >=7 .AND. Alltrim(x[7]) == Alltrim(cTributo)})) > 0
				//Estou utilizando mesmo número utilizado no título de recolhimento
				cNumGNRE	:= aTGCalcRec[nPosTrib][3]
			Else
				//O tributo não gerou título, logo precisarei buscar o próximo número sequencial da SX5.
				cNumGNRE	:= FisTitTG()
			EndIf

			//-------------------------------
			//Definição do vencimento da Guia
			//-------------------------------
			dDtVenc := xFisDtGnre(dDtPadrao)

			//-----------------------
			//Definição da UF da Guia
			//-----------------------
			cEst	:= cEstNF
			If CJ4->CJ4_UF == "1"
				//UF do MV_ESTADO
				cEst	:= cMvEstado

			ElseIf CJ4->CJ4_UF == "2"
				//UF Origem
				cEst	:= cEstOri

			ElseIf CJ4->CJ4_UF == "3"
				//UF Destino
				cEst	:= cEstDest

			ElseIf CJ4->CJ4_UF == "4"
				//UF da Nota Fiscal
				cEst	:= cEstNF

			EndIF

			//------------------
			//Definição do CNPJ
			//------------------
			If CJ4->CJ4_CNPJ == "1"
				//CNPJ Participante
				cCNPJ	:= cCNPJPart
			EndIF

			//--------------------------------
			//Definição da Inscrição Estadual
			//--------------------------------
			If CJ4->CJ4_IEGUIA == "1"
				//Participante
				cInsc	:= cInscPart

			ElseIf CJ4->CJ4_IEGUIA == "2"
				//SIgamat
				cInsc := SM0->M0_INSC

			ElseIf CJ4->CJ4_IEGUIA == "3"
				//IE do Estado
				cInsc := IESubTrib(cEstDest,.T.)
			EndIF

			//Chamo função responsavel por definir dados referente a Código de Receita
			IF lCodrec
				aCodrec  := CodRec(cTributo, cEst, cModelo)
			Endif
			cCodrec  := aCodrec[1]
			cDetalhe := aCodrec[2]
			cRef	 := aCodrec[3]
			cCobRec	 := aCodrec[4]


			//Aqui tenho em mãos todas as informações para gerar a Guia:
			oModel    := FWLoadModel('MATA960')
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()

			//Para essa operação é preciso especificar qual o modelo que queremos inserir o valor
			oModel:SetValue("MATA960MOD","F6_NUMERO"  , cNumGNRE)
			oModel:SetValue("MATA960MOD","F6_TIPOIMP" , cTipoImp)
			oModel:SetValue("MATA960MOD","F6_VALOR"   , nValor)
			oModel:SetValue("MATA960MOD","F6_DTARREC" , dDtArrec)
			oModel:SetValue("MATA960MOD","F6_DOC"     , cDoc)
			oModel:SetValue("MATA960MOD","F6_SERIE"   , cSerie)
			oModel:SetValue("MATA960MOD","F6_CLIFOR"  , cPart)
			oModel:SetValue("MATA960MOD","F6_LOJA"    , cLoja)
			oModel:SetValue("MATA960MOD","F6_OPERNF"  , cOperNF)
			oModel:SetValue("MATA960MOD","F6_MESREF"  , nMes)
			oModel:SetValue("MATA960MOD","F6_ANOREF"  , nAno)
			oModel:SetValue("MATA960MOD","F6_TIPODOC" , cTipoDoc)
			oModel:SetValue("MATA960MOD","F6_TRIB"    , cTributo)
			oModel:SetValue("MATA960MOD","F6_IDNF"    , cIdNf)
			oModel:SetValue("MATA960MOD","F6_EST"     , cEst)
			oModel:SetValue("MATA960MOD","F6_DTVENC"  , Iif(Empty(dDtVenc), dDtPadrao,dDtVenc ) )
			oModel:SetValue("MATA960MOD","F6_DTPAGTO" , dDtVenc)
			oModel:SetValue("MATA960MOD","F6_INSC"    , cInsc)
			oModel:SetValue("MATA960MOD","F6_CNPJ"    , cCNPJ)
			oModel:SetValue("MATA960MOD","F6_CODREC"  , cCodrec)
			oModel:SetValue("MATA960MOD","F6_DETRECE" , cDetalhe)
			oModel:SetValue("MATA960MOD","F6_REF"  	  , cRef)
			oModel:SetValue("MATA960MOD","F6_COBREC"  , cCobRec)
			If !Empty(cSDoc)
				oModel:SetValue("MATA960MOD","F6_SDOC"    , cSDoc)
			EndIF

			//Verifica se deseja visualizar/alterar a Guia gerada
			//Aqui posso verifica a CJ4 pois a função EnqNFGNRE() já posicionou esta tabela
			IF CJ4->CJ4_VTELA == "1" .AND. !IsBlind()
				FWExecView( cTributo ,"MATA960", MODEL_OPERATION_INSERT, , { ||.T. } ,{ || .T.},,,,,,oModel )
			Else
				If oModel:VldData()
					oModel:CommitData()

				Else
					//Aqui exibo erro, pois ocorreu algum erro de validação do modelo
					VarInfo("",oModel:GetErrorMessage())
				EndIf
			EndIF

			//Desativo e destruo o objeto aqui
			oModel:DeActivate()
			oModel:Destroy()

			//Aqui realizamos a Gravação da CDC, caso esteja configurada na regra de Guia.
			IF !EMPTY(CJ4->CJ4_INFCOM )
				GrvCDC( Iif(cOperNF == "1", "E", "S") , cDoc, cSerie, cPart, cLoja, cNumGNRE, cEstNF, CJ4->CJ4_INFCOM)
			EndIf

		EndIf

	Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} EnqNFGNRE

Função que fará enquadramento da regra de geração de GNRE por nota fiscal.
Aqui será verificado se a guia deve ou não ser gerada em função das inforações
da nota fiscal.

@param cCodRegra - Código da regra de guia
@param cEst - Estado da nota fiscal
@param cOperNF - Operação da NF (1- Entrada; 2- Saída)

@return lRet - Retorna verdadeiro se a GNRE deve ser gerada.

CJ4_MODO 1=Nota Fiscal;2=Apuração
CJ4_ORIDES 1=Somente Interestadual;2=Somente Municipal;3=Indiferente
CJ4_IMPEXP 1=Somente Importação;2=Somente Exportação;3=Indiferente
CJ4_IE 1=Possui IE;2=Não Possui IE;3=Indiferente
CJ4_VTELA 1=Sim;2=Não

@author Erick Dias
@since 22/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function EnqNFGNRE(cCodRegra, cEst, cOperNF)

	Local lRet 		:= .F.
	Local cMvEstado := GetNewPar("MV_ESTADO","")

//Primeiro posiciono e verifico se a regra de guia é para nota fiscal
	If !Empty(cCodRegra) .AND. CJ4->(MsSeek(xFilial("CJ4") + cCodRegra )) .AND. CJ4->CJ4_MODO == "1"

		//------------------------------------
		//Verificação de interno/interestadual
		//------------------------------------
		lRet	:= .F.
		If CJ4->CJ4_ORIDES == "1"
			//Aqui somente operações interestaduais
			lRet	:= cMvEstado <> cEst

		ElseIf CJ4->CJ4_ORIDES == "2"
			//Aqui somente operações internas
			lRet	:= cMvEstado == cEst

		ElseIf CJ4->CJ4_ORIDES == "3" .OR. Empty(CJ4->CJ4_ORIDES)
			//Indiferente, este campo não influenciará
			lRet	:= .T.
		EndIF

		//---------------------------------
		//Verificação inscrito/não inscrito
		//---------------------------------
		If lRet

			If CJ4->CJ4_IE == "1"
				//Aqui para os estados que o contribuinte É inscrito
				lRet	:=  !Empty( IESubTrib( Iif(cOperNF == "1",cMvEstado, cEst )) )

			ElseIf CJ4->CJ4_IE == "2"
				//Aqui para os estados que o contribuinte NÃO É inscrito
				lRet	:=  Empty( IESubTrib( Iif(cOperNF == "1",cMvEstado, cEst )) )

			ElseIf CJ4->CJ4_IE == "3" .OR. Empty(CJ4->CJ4_IE)
				//Indiferente, este campo não influenciará
				lRet	:= .T.
			EndIF

		EndIF

		//-------------------------------------
		//Verificação de importação/exportação
		//-------------------------------------
		If lRet

			If (CJ4->CJ4_IMPEXP == "1" .AND. cOperNF == "1") .Or. (CJ4->CJ4_IMPEXP == "2" .AND. cOperNF == "2")
				//Aqui somente importação/exportação, UF destino deve ser EX
				lRet	:= cEst	== "EX"

			ElseIf CJ4->CJ4_IMPEXP == "3"  .OR. Empty(CJ4->CJ4_IMPEXP)
				//Indiferente, este campo não influenciará
				lRet	:= .T.
			EndIF

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelSF6NF

Função que irá deletar as guias geradas por nota fiscal dos tributos
calculados pelo confiutador de tributos.  A função receberá o ID da nota
que será excluída, e deletará todas as guias da nota em questão.

@param cIdNF - Id da nota fiscal

@author Erick Dias
@since 22/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function FisDelSF6NF(cIdNF)

	Local cChvSF6	:= xFilial("SF6") + cIdNF
	Local oModel	:= nil

//Verifico se o ID está devidamente preenchido
	If !Empty(cIdNF)

		dbSelectArea("SF6")
		SF6->(dbSetOrder(8)) //F6_FILIAL + F6_IDNF

		DbSelectArea("CDC")
		CDC->(DbSetOrder(1))//Indice CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF

		//Laço nas guias que tiverem este ID, serão deletadas!
		If SF6->(MsSeek( cChvSF6 ))
			While !SF6->(EoF()) .And. SF6->(F6_FILIAL + F6_IDNF) == cChvSF6

				//Aqui deleto as informações do complemento da CDC antes de deletar a SF6.
				If CDC->(dbSeek( xFilial("CDC")+ Iif(SF6->F6_OPERNF == "1", "E", "S") + SF6->F6_DOC + SF6->F6_SERIE + SF6->F6_CLIFOR + SF6->F6_LOJA + SF6->F6_NUMERO + SF6->F6_EST ))
					RecLock("CDC", .F.)
					CDC->(dbDelete())
					CDC->(MsUnLock())
				Endif

				//Prossigo com a deleção da SF6.
				oModel := FWLoadModel("MATA960")
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()

				If oModel:VldData()
					lRet := FWFormCommit( oModel )
				EndIf

				oModel:Deactivate()
				SF6->(dbSkip())
			EndDo
		EndIf

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCDC

Função que fará gravação da tabela CDC no momento de geração da SF6, caso
tenha uma regra configurada para gravar o complemento.

@author Erick Dias
@since 23/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function GrvCDC(cTpMov, cDoc, cSerie, cPart, cLoja, cGuia, cUF, cCodInfComp)

//Verifico se para a nota em questão já não gravou CDC.

	dbSelectArea("CDC")
	CDC->(DbSetOrder(1))//CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
	If !DbSeek( xFilial("CDC") + cTpMov + cDoc + cSerie + cPart + cLoja + cGuia + cUF )
		RecLock("CDC",.T.)
		CDC_FILIAL := xFilial("CDC")
		CDC_TPMOV  := cTpMov
		CDC_DOC    := cDoc
		SerieNfId("CDC",1,"CDC_SERIE",,,,cSerie)
		CDC_CLIFOR := cPart
		CDC_LOJA   := cLoja
		CDC_GUIA   := cGuia
		CDC_UF     := cUF
		CDC_IFCOMP := cCodInfComp
		CDC->(MsUnlock())
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ObtemData

Função auxiliar para realizar a soma de dias úteis na data de vencimento
da Guia

@param nQtdeDia - Quantidade de dias a ser somado
@param dDataRef - Data atual de referência

@return dDataRef - data válida

@author Erick Dias
@since 24/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function ObtemData(nQtdeDia,dDataRef)

//Se não houver dias a serem somados, retorno o mesmo dia.
	IF nQtdeDia == 0
		Return dDataRef
	EndIf

//Laço para obter o dia válido
	While nQtdeDia > 0

		//Verifico próximo dia
		dDataRef +=1

		//Verifico se a data é válida
		IF DataValida(dDataRef,.T.) == dDataRef
			//Somo 1 dia e diminuo 1 dia do contador
			nQtdeDia -=1
		EndIF

	EndDo

Return dDataRef

//-------------------------------------------------------------------
/*/{Protheus.doc} DiaFixoSub

Função auxiliar para obter o dia util fixo do mês subsequente

@param nDia - Dia

@return dDtVenc - data válida

@author Erick Dias
@since 24/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Static Function DiaFixoSub(nDia, nOpc)

	Local dDtVenc	:= nil
	Local dDtProximo	:= MonthSum(dDatabase, 1)

//Se o dia for maior que próximo mês, por padrão vai considerar primeiro dia último do próximo mês
	IF nDia > Day(LastDay(dDtProximo))
		Return DataValida(LastDay(dDtProximo) + 1, .T.)
	EndIF

//Aqui é dia fixo do mês Subsequente
	dDtVenc	:= CToD( cvaltochar(nDia) + "/" + StrZero(Month( dDatabase) ,2)  + "/" + StrZero(Year( dDatabase) ,4)  )

//Somo mais 1 mês na data atual
	dDtVenc	:= MonthSum(dDtVenc, 1)
//Pego próxima data válida no mês subsequente
	dDtvenc := DataValida(dDtVenc, .T.)

Return dDtVenc

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisDtGnre

Função auxiliar para encapsular a regra de vencimento da CJ4

@author Erick Dias
@since 25/09/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function xFisDtGnre(dDtPadrao)
	Local dDtVenc	:= CTOD("//")
	Local nAno      := 0
	Local nMes 		:= 0

//-------------------------------
//Definição do vencimento da Guia
//-------------------------------
	IF CJ4->CJ4_CFVENC == "1"

		//Aqui é opção de somar dias úteis
		dDtVenc := ObtemData(CJ4->CJ4_QTDDIA, dDatabase)

	ElseIF CJ4->CJ4_CFVENC == "2"

		//Dia fixo maior que o número de dias do mês, exemplo dia 31 no mês de novembro...ou 30 de fevereiro...
		If CJ4->CJ4_DTFIXA > Day(LastDay(dDatabase))
			//Retorna primeiro dia útil do próximo mês
			dDtVenc 	:= dDtPadrao
		Else
			//Aqui é dia fixo do mês atual
			dDtVenc := DataValida(CToD( cvaltochar(CJ4->CJ4_DTFIXA) + "/" + StrZero(Month(dDatabase),2) + "/" + StrZero(Year(dDatabase),4) ), .T.)

			//Verifica se a data é inferior a data atual...nesse caso gerarei para próximo mês
			If dDtVenc < dDatabase
				//Por padrõa adotará aqui o dia fixo do mês Subsequente
				dDtVenc	:= DiaFixoSub(CJ4->CJ4_DTFIXA)
			EndIF

		EndIF

	ElseIF CJ4->CJ4_CFVENC == "3"
		//Aqui é dia fixo do mês Subsequente
		dDtVenc	:= DiaFixoSub(CJ4->CJ4_DTFIXA)
	ElseIf CJ4->CJ4_CFVENC == "4"
		//Repito o tratamento para o mês subsequente com data fixa já que deve ser gerado apenas um mês para frente
		If CJ4->CJ4_MESFIX == 1
			//Aqui é dia fixo do mês Subsequente
			dDtVenc	:= DiaFixoSub(CJ4->CJ4_DTFIXA)
		Else
			//Tratamento para quando a geração da guia for para o ano seguinte
			If Month(dDatabase) + CJ4->CJ4_MESFIX > 12
				nAno := StrZero(Year(dDatabase) + 1, 4)
				nMes := StrZero(Month(dDatabase) + CJ4->CJ4_MESFIX - 12, 2)
			Else
				nAno := StrZero(Year(dDatabase), 4)
				nMes := StrZero(Month(dDatabase) + CJ4->CJ4_MESFIX, 2)
			EndIf
			//Aqui é dia fixo para a quantia de meses a frente selecionada
			dDtVenc := DataValida(CToD( cvaltochar(CJ4->CJ4_DTFIXA) + "/" + nMes + "/" + nAno ), .T.)
		EndIf
	ElseIf Empty(CJ4->CJ4_CFVENC) .Or. CJ4->CJ4_CFVENC == "5"
		dDtVenc := dDatabase
	EndIf

Return dDtVenc


//-------------------------------------------------------------------
/*/{Protheus.doc} GetUltAqui

Função auxiliar para encapsular a regra de vencimento da CJ4

@param - código do produto a ser verificado

@author Erick Dias
@since 02/10/20
@version 12.1.31
/*/
//-------------------------------------------------------------------
Function GetUltAqui(cCodProd,aNfCab,aNfItem,nItem,nTrbGen,cDocSai,cSerie,cCliFor,cLoja,nCaso)

	Local cSelect	:= ""
	Local cFrom		:= ""
	Local cJoin		:= ""
	Local cWhere	:= ""
	Local cQuery    := ""
	Local cTpDb		:= tcgetdb()
	Local cAliasQry	:= ""
	Local nX		:= 0
	Local nIcmsUnit := 0
	Local nIcmsEst  := 0
	Local aUltAq 	:= {}
	Local aBind		:= {}
	Local nQuantSai	:= 0
	Local nItemSai	:= 0

	Default cCodProd := ""
	Default dDtEmiss  := ""

//Verifico se código está preenchido
	If Empty(cCodProd)
		Return 0
	EndIF

//Verifica se query está no cache. Se estiver basta retornar os valores
	If (nX := aScan(aPesqSD1,{|x| x[1] == cCodProd})) > 0 .and. Alltrim(cDocSai) = ""

		//Aqui apenas retorno a posição do produto, pois  query já foi feita para este produto.
		Return nX

	Else

		//DO contrário preciusarei fazer query para buscar a última aquisição
		cAliasQry := GetNextAlias()

		If cTpDb $ "ORACLE/POSTGRES/MYSQL"
			cSelect += "SELECT  "
		Else
			cSelect += "SELECT TOP 1 "
		Endif

		cSelect	+= " SD1.D1_CUSTO,	    SD1.D1_VALDESC, "
		cSelect	+= " SD1.D1_QUANT,  	SD1.D1_MARGEM, "
		cSelect += " SD1.D1_VUNIT, 		SD1.D1_VALANTI, "
		cSelect += " SD1.D1_BRICMS, 	SD1.D1_ICMSRET, "
		cSelect += " SD1.D1_ALIQSOL, 	SD1.D1_BASNDES, "
		cSelect += " SD1.D1_ICMNDES, 	SD1.D1_ALQNDES, "
		cSelect += " SD1.D1_FCPAUX , 	SD1.D1_VALICM,  "
		cSelect += " SD1.D1_VFCPANT, 	SD1.D1_BFCPANT, "
		cSelect += " SD1.D1_AFCPANT, 	SD1.D1_VFECPST, "
		cSelect += " SD1.D1_BSFCPST, 	SD1.D1_ALFCPST, "
		cSelect += " SD1.D1_BASEICM, 	SD1.D1_PICM,	"
		cSelect += " SD1.D1_DOC, 	    SD1.D1_SERIE,	"
		cSelect += " SD1.D1_FORNECE, 	SD1.D1_LOJA,	"
		cSelect += " SD1.D1_DTDIGIT, 	SD1.D1_LOTECTL,	"
		cSelect += " SD1.D1_UM, 	    SD1.D1_SEGUM,      SD1.D1_QTSEGUM "

		cFrom   += "FROM " + RetSQLName("SD1") + " SD1 "

		cJoin	+= "INNER JOIN " + RetSQLName("SF1") + " SF1 ON "
		cJoin	+= "SF1.F1_FILIAL = SD1.D1_FILIAL AND "
		cJoin	+= "SF1.F1_DOC = SD1.D1_DOC AND "
		cJoin	+= "SF1.F1_SERIE = SD1.D1_SERIE AND "
		cJoin	+= "SF1.F1_FORNECE = SD1.D1_FORNECE AND "
		cJoin	+= "SF1.F1_LOJA = SD1.D1_LOJA AND "
		cJoin	+= "SF1.F1_DTDIGIT = SD1.D1_DTDIGIT AND "
		cJoin	+= "SF1.F1_STATUS <> ? AND " //1
		cJoin	+= "SF1.D_E_L_E_T_ = ? " //2

		cWhere  += " WHERE SD1.D1_FILIAL  = ? AND " //3
		cWhere  += "SD1.D1_COD     = ? AND " //4
		cWhere  += "SD1.D1_NFORI   = ? AND " //5
		cWhere  += "SD1.D1_SERIORI = ? AND " //6
		cWhere  += "SD1.D1_TIPO = ? AND " //7
		cWhere  += "SD1.D_E_L_E_T_ = ? " //8

		cWhere  += " ORDER BY SD1.D1_DTDIGIT DESC, SD1.D1_NUMSEQ DESC "

		If cTpDb == "ORACLE"
			cWhere  += " FETCH FIRST 1 ROWS ONLY "

		ElseIF (cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL")
			cWhere  += " LIMIT 1 "

		EndIf

		cQuery := cSelect + cFrom + cJoin + cWhere

		aadd(aBind, ' ') //1 - F1_STATUS
		aadd(aBind, ' ') //2 - DELETE
		aadd(aBind, xFilial("SD1")) //3 - D1_FILIAL
		aadd(aBind, cCodProd) //4 - D1_COD
		aadd(aBind, ' ') //5 - D1_NFORI
		aadd(aBind, ' ') //6 - D1_SERIORI
		aadd(aBind, 'N') //7 - D1_TIPO
		aadd(aBind, ' ') //8 - DELETE

		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliasQry,.T.,.F.)

		//Laco da query e obtem os valores da última aquisição.
		(cAliasQry)->(DBGoTop())
		IF !(cAliasQry)->(Eof())

			//Preencho o array com a informação da última entrada
			If Alltrim(cDocSai) = ""
				aAdd(aPesqSD1,{	cCodProd,;
					(cAliasQry)->D1_CUSTO,  (cAliasQry)->D1_VALDESC, (cAliasQry)->D1_MARGEM,  (cAliasQry)->D1_QUANT,;
					(cAliasQry)->D1_VUNIT,  (cAliasQry)->D1_VALANTI, (cAliasQry)->D1_VALICM,  (cAliasQry)->D1_FCPAUX,;
					(cAliasQry)->D1_BRICMS, (cAliasQry)->D1_ALIQSOL, (cAliasQry)->D1_ICMSRET, (cAliasQry)->D1_BSFCPST,;
					(cAliasQry)->D1_ALFCPST,(cAliasQry)->D1_VFECPST, (cAliasQry)->D1_BASNDES, (cAliasQry)->D1_ALQNDES,;
					(cAliasQry)->D1_ICMNDES,(cAliasQry)->D1_BFCPANT, (cAliasQry)->D1_AFCPANT, (cAliasQry)->D1_VFCPANT,;
					(cAliasQry)->D1_BASEICM, (cAliasQry)->D1_PICM })
				nX	:= Len(aPesqSD1)
			Endif

			if !Empty(cDocSai) .and. nCaso == 1

				nQuantSai:= aNfItem[nItem][IT_QUANT]
				nItemSai := aNfItem[nItem][IT_ITEM]
				nIcmsEst := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]
				nIcmsUnit:= ((cAliasQry)->D1_VALICM / (cAliasQry)->D1_QUANT)


				Aadd(aUltAq,{(cAliasQry)->D1_DOC,;     //1
				(cAliasQry)->D1_SERIE,;   //2
				cCodProd,;   //3
				(cAliasQry)->D1_FORNECE,;   //4
				(cAliasQry)->D1_LOJA ,;   //5
				(cAliasQry)->D1_DTDIGIT,;   //6
				Alltrim((cAliasQry)->D1_LOTECTL),;   //7
				(cAliasQry)->D1_UM,;   //8
				(cAliasQry)->D1_SEGUM,;   //9
				(cAliasQry)->D1_QTSEGUM,;   //10
				"",;   //11
				0,;   //12
				"",;   //13
				nIcmsUnit,;   //14
				nIcmsEst})    //15

				GravaCJM(aUltAq, cCodProd, nQuantSai,nItemSai,aNfCab[NF_DTEMISS],cDocSai,cSerie, cCliFor ,cLoja)

			Endif

		EndIF

		//Fecho area.
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbCloseArea())

	EndIF

Return nX


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFCA

Função responsavel por indice referente a Indicadores Econômicos FCA

@param aNfCab	 - Cabeçalho da nota
@param aNFItem	 - Itens da nota
@param nItem	 - Item em procesamento


@author Rfaael Oliveira
@since 02/10/2020
@version 12.1.31
/*/
//-------------------------------------------------------------------

Static function LoadFCA(aNfCab, aNFItem, nItem)

	Local nIndice  := 0
	Local aAreaSD2 := {}
	Local nX	   := 0

//Verifico se já realizei a busca no array com cache
/*
Estrutura do array
1-Estado destino
2-Mes operação
3-Ano da Operação
4-RECNO Origem
5-Valor
*/

	nX := aScan(aPesqF0R,{|x| x[1] == aNFCab[NF_UFDEST] .And. ;
		x[2] == Month(aNfCab[NF_DTEMISS]) .And. ;
		x[3] == Year(aNfCab[NF_DTEMISS]) .And. ;
		x[4] == aNFItem[nItem][IT_RECORI]})


//Verifica se query está no cache. Se estiver basta retornar os valores
	IF nX > 0

		//Aqui apenas retorno o valor
		Return	aPesqF0R[nX][5]

		// Processa somente se existir nota de Origem e indice da nota atual
	Elseif !Empty(aNFItem[nItem][IT_RECORI]) .and. aNfItem[nItem][IT_INDICE] <> 0


		//Guarda Area da SD2
		aAreaSD2   := SD2->(GetArea())

		//Se possiciona na nota de origem
		DbSelectArea("SD2")
		MsGoto(aNFItem[nItem][IT_RECORI])

		IF Month(SD2->D2_EMISSAO)  <>  Month(aNfCab[NF_DTEMISS]) .Or. Year(SD2->D2_EMISSAO)  <>  Year(aNfCab[NF_DTEMISS])

			//Localiza indice do periodo da nota de Origem
			F0R->(dbSetOrder(1)) //F0R_FILIAL+F0R_UF+F0R_PERIOD
			If F0R->(MsSeek(xFilial("F0R")+aNFCab[NF_UFDEST]+AnoMes(SD2->D2_EMISSAO)))
				nIndice := aNFCab[NF_INDICE]/F0R->F0R_INDICE
			EndIf
		Endif

		//Restaura a area da SD2
		RestArea(aAreaSD2)
	Endif

//Aqui adiciono pesquisa no cache para não ser refeito posteriormente
	aAdd(aPesqF0R,{aNFCab[NF_UFDEST], Month(aNfCab[NF_DTEMISS]), Year(aNfCab[NF_DTEMISS]), aNFItem[nItem][IT_RECORI], nIndice  } )

Return nIndice

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkCfgTrib

Verifica se a guia que está sendo gerada para um tributo consta na lista do Configurador de Tributos.

@param cOrigem	 - Rotina de Origem - MATA103 ou MATA460A
@param cImp  	 - Código do imposto
@param nTitICMS	 - Valor do título de ICMS
@param nTitST	 - Valor do título de ICMS-ST
@param lFECP	 - Identifica se a guia a ser gerada é de FECP Complementar
@param lDifAl	 - Identifica se a guia a ser gerada é de Difal
@param cItemNF	 - Identifica a posicao do item na nota

@author leandro.faggyas
@since 09/04/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ChkCfgTrib(cOrigem, cImp, nTitICMS, nTitST, lFECP, lDifAl,cItemNF)
	Local nValGuia  := 0
	Local aTribGen  := {}
	Local cIdTrib   := ""
	Local lTribGen  := .F.
	Local nPosTrib  := 0

	Default cOrigem  := ""
	Default cImp     := ""
	Default nTitICMS := 0
	Default nTitST   := 0
	Default lFECP    := .F.
	Default lDifAl   := .F.
	Default cItemNF  := ""

	DbSelectArea("F2B")
	F2B->(DbSetOrder(1)) //F2B_FILIAL, F2B_REGRA, F2B_VIGINI, F2B_VIGFIM, F2B_ALTERA
	DbSelectArea("F2E")
	F2E->(DbSetOrder(2)) //F2E_FILIAL, F2E_TRIB
	DbSelectArea("CJ4")
	CJ4->(DbSetOrder(1)) //CJ4_FILIAL, CJ4_CODIGO

	aTribGen := MaFisRet(,"NF_TRIBGEN")

	Do Case
	Case cImp=="IC" .And. nTitICMS > 0
		cIdTrib  := "000021" //ICMS
	Case cImp=="IC" .And. nTitST > 0
		If lFECP
			If cOrigem == "MATA103"
				cIdTrib  := "000041" //FCPST
				nValGuia := nTitST
			Else
				cIdTrib  := "000042" //FCPCMP
				nValGuia := SF3->F3_VFCPDIF
			EndIf
		ElseIf lDifAl
			cIdTrib  := "000037" //DIFAL
			nValGuia := IIF(cOrigem == "MATA103",nTitST,SF3->F3_DIFAL)
		Else
			cIdTrib  := "000056" //ICMSST
			nValGuia := IIF(cOrigem == "MATA103",SF1->F1_ICMSRET,SF2->F2_ICMSRET)
		EndIf
	Case cImp=="IP" .Or. cImp=="SI"
		cIdTrib  := "000022" //IPI
	Case cImp=="IS"
		cIdTrib  := "000020" //ISS
	Case cImp=="FD"
		cIdTrib  := "000010" //FUNDERSUL
	Case cImp=="SE"
		cIdTrib  := "000013" //SEST/SENAT
	Case cImp=="SN"
		cIdTrib  := "000003" //SENAR
	Case cImp=="PR"
		cIdTrib  := "000027" //PROTEGE
	Case cImp=="FEEF"
		cIdTrib  := "000025" //FEEF
	EndCase

	nPosTrib := aScan(aTribGen, {|x| x[TG_NF_IDTRIB] = cIdTrib })
	If nPosTrib > 0
		If cIdTrib == "000021"	//ICMS
			nValGuia := MaFisRet(,"NF_VALICM")
			If aTribGen[nPosTrib,TG_NF_VALOR] <> nValGuia  //Verifico se o valor das guias de recolhimento será calculado integralmente através do configurador
				nTitICMS := Abs(aTribGen[nPosTrib,TG_NF_VALOR] - nValGuia )
			Else
				lTribGen := .T.
			EndIf

		ElseIf cIdTrib $ "000037|000041|000042|000056" //DIFAL/FCPST/FCPCMP/ICMSST
			If !Empty(cItemNF)
				lTribGen := ChkTGItem( cIdTrib, DecodSoma1(cItemNF)  )
			Else
				If aTribGen[nPosTrib,TG_NF_VALOR] <> nValGuia //Verifico se o valor das guias de recolhimento será calculado integralmente através do configurador
					nTitST   := Abs(aTribGen[nPosTrib,TG_NF_VALOR] - nValGuia)
				Else
					lTribGen := .T.
				EndIf
			EndIf
		Else
			lTribGen := .T.
		EndIf
	EndIf

Return lTribGen

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkTGItem

Verifica se determinado imposto genérico está sendo calculado para determinado item.

@param cIdTrib	 - ID do Tributo segundo o campo F2E_IDTRIB
@param nItem  	 - Numero do item a ser pesquisado.

@author leandro.faggyas
@since 29/04/2021
@version 12.1.33
/*/
//-------------------------------------------------------------------
Function ChkTGItem( cIdTrib, nItem  )
	Local lRet      := .F.
	Local aTgItem   := {}
	Local nPosIt    := 0

	Default cIdTrib := ""
	Default nItem   := 0

	If nItem > 0
		aTgItem := MaFisRet(nItem,"IT_TRIBGEN")
	EndIf

	If Len(aTgItem) > 0 .And. !Empty(cIdTrib)
		nPosIt := aScan(aTgItem, {|x| x[TG_IT_IDTRIB] == cIdTrib} )
		If nPosIt > 0
			lRet := aTgItem[nPosIt,TG_IT_VALOR] > 0
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VlrLimite
	Função que verifica a limitação de valores do tributo
	@type  Function
	@author Erich Buttnwer
	@since 29/04/2021
	@version version
	@param aNFItem - Array de item do tributo
	 	   nItem - Posição do item do produto
		   nTrbGen - Posição do tributo calculado
		   nResultado - Valor calculado do tributo
	@return
		   nResultado
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function VlrLimite(aNFItem, nItem, nTrbGen, nResultado, nPosTrbProc, cDetTrbPri, aNfCab)

	Local cOprMax 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MAX]
	Local cOprMin 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_OPR_MIN]
	Local cAcaoMax  := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ACAO_MAX]
	Local cAcaoMin  := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ACAO_MIN]
	Local nVlrOpMax	:= 0
	Local nVlrOpMin	:= 0

	cOprMax := Iif(AllTrim(cOprMax) == "O:VAL_MANUAL",AllTrim(cOprMax)+"_MAX",AllTrim(cOprMax) )
	cOprMin := Iif(AllTrim(cOprMin) == "O:VAL_MANUAL",AllTrim(cOprMin)+"_MIN",AllTrim(cOprMin) )

	If !Empty(AllTrim(cOprMax)) .Or. !Empty(AllTrim(cOprMin))

		If !IsOperTrib(cOprMax)
			nVlrOpMax := ValOperPri(cOprMax, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab )
		Endif

		If !IsOperTrib(cOprMin)
			nVlrOpMin := ValOperPri(cOprMin, aNFItem, nItem, nPosTrbProc, cDetTrbPri, aNfCab )
		Endif

		//Define Flag de delete o tributo para falso para nova validação
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DELETED_TRIB] := .F.

		If nVlrOpMax > 0 .And. nResultado > nVlrOpMax

			nResultado := ProcMaxAcao(aNfItem, nItem, nTrbGen, nVlrOpMax, cAcaoMax)

		ElseIf nVlrOpMin > 0 .And. nResultado < nVlrOpMin

			nResultado := ProcAcaoMin(aNfItem, nItem, nTrbGen, nVlrOpMin, cAcaoMin)

		EndIf

	EndIf

Return nResultado

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompUltAq

Função que retorna os valores referentes a ultima aquisição quando o produto
de venda possui componentes na SG1

@param - código do produto e quantidade a ser verificado

@author Alexandre Esteves, Bruce Mello
@since 15/07/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------
Function GetCompUltAq(cCodProd,aNfCab,aNfItem,nItem,nTrbGen,cDocSai,cSerie, cCliFor ,cLoja, nCaso)


	Local cSelect	:= ""
	Local cFrom		:= ""
	Local cWhere	:= ""
	Local cQuery    := ""
	Local cTpDb		:= tcgetdb()
	Local cAliascJM	:= ""
	Local cPrdIntAnt := ""
	Local nX		:= 0
	Local aBind     := {}
	Local nTotalEst	:= 0
	Local nIcmsEst  := 0
	Local nIcmsUnit := 0
	Local aFillEstr	:= {}
	Local aFindComp	:= {}
	Local nZ 		:= 0
	Local nQuantSai	:= 0
	Local nItemSai	:= 0

	Default cCodProd := ""
	Default cDocSai	 := ""
	Default cSerie   := ""
	Default cCliFor  := ""
	Default cLoja 	 := ""

	nQuantSai := aNfItem[nItem][IT_QUANT]
	nItemSai  := aNfItem[nItem][IT_ITEM]

//Verifica se query está no cache. Se estiver basta retornar os valores
	If (nX := aScan(aPesqEstr,{|x| x[1] == cCodProd .and. x[3] == nQuantSai })) > 0 .and. Alltrim(cDocSai) = ""

		//Aqui apenas retorno a posição do produto, pois  query já foi feita para este produto
		Return nX

	Elseif nCaso == 1

		cAliascJM := getNextAlias()

		cSelect := "SELECT SG1A.G1_COD, "
		If cTpDb == "ORACLE"
			cSelect += "NVL(SG1B.G1_COMP,SG1A.G1_COMP) AS G1_PRCOMP, NVL(SG1B.G1_COD,'')AS G1_PRDINT, SG1A.G1_QUANT * NVL(SG1B.G1_QUANT,1) AS G1_QTESTR, "
		ElseIf cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL"
			cSelect += "COALESCE(SG1B.G1_COMP,SG1A.G1_COMP) G1_PRCOMP, COALESCE(SG1B.G1_COD,'') G1_PRDINT, SG1A.G1_QUANT * COALESCE(SG1B.G1_QUANT,1) G1_QTESTR, "
		Else
			cSelect += "ISNULL(SG1B.G1_COMP,SG1A.G1_COMP)AS G1_PRCOMP, ISNULL(SG1B.G1_COD,'')AS G1_PRDINT, SG1A.G1_QUANT * ISNULL(SG1B.G1_QUANT,1) AS G1_QTESTR, "
		EndIf

		cSelect += "D1.D1_DOC, D1.D1_SERIE, D1.D1_QUANT, D1.D1_VALICM, D1.D1_LOTECTL, D1.D1_DTDIGIT, D1.D1_UM, D1.D1_SEGUM, D1.D1_QTSEGUM, D1.D1_FORNECE, D1.D1_LOJA  "

		cFrom   := "FROM " + RetSqlName("SG1") + " SG1A "
		cFrom   += "LEFT JOIN " + RetSqlName("SG1") + " SG1B ON (SG1A.G1_COMP = SG1B.G1_COD AND SG1B.G1_FILIAL = ? AND SG1B.G1_FIM >= ? AND SG1B.D_E_L_E_T_ = ' ' ) "
		if cTpDb == "ORACLE"
			cFrom   += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON (D1.D1_FILIAL = ? AND  D1.D1_DTDIGIT <= ? AND D1.D1_COD = NVL(SG1B.G1_COMP,SG1A.G1_COMP) AND D1.D_E_L_E_T_ =' ' AND "
			cFrom  += " D1.D1_DOC =(SELECT SD1.D1_DOC FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D1_FILIAL = ? AND SD1.D1_COD = NVL(SG1B.G1_COMP,SG1A.G1_COMP) ORDER BY SD1.D1_DOC DESC FETCH FIRST 1 ROWS ONLY)) "
		elseif cTpDb == "POSTGRES" .OR. cTpDb == "MYSQL"
			cFrom   += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON (D1.D1_FILIAL = ? AND D1.D1_DTDIGIT <= ? AND D1.D1_COD = COALESCE(SG1B.G1_COMP,SG1A.G1_COMP) AND D1.D_E_L_E_T_ =' ' AND "
			cFrom  += " D1.D1_DOC =(SELECT SD1.D1_DOC FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D1_FILIAL = ? AND SD1.D1_COD = COALESCE(SG1B.G1_COMP,SG1A.G1_COMP) ORDER BY SD1.D1_DOC DESC LIMIT 1)) "
		else
			cFrom   += "LEFT JOIN " + RetSqlName("SD1") + " D1 ON (D1.D1_FILIAL = ? AND D1.D1_DTDIGIT <= ? AND D1.D1_COD = ISNULL(SG1B.G1_COMP,SG1A.G1_COMP) AND D1.D_E_L_E_T_ =' ' AND "
			cFrom  += " D1_DOC =(SELECT TOP 1 SD1.D1_DOC FROM " + RetSqlName("SD1") + " SD1 WHERE SD1.D1_FILIAL = ? AND SD1.D1_COD = ISNULL(SG1B.G1_COMP,SG1A.G1_COMP) ORDER BY SD1.D1_DOC DESC)) "
		endif
		cWhere  := " WHERE SG1A.G1_FILIAL = ? "
		cWhere  += " AND SG1A.G1_COD = ? "
		cWhere  += " AND SG1A.G1_FIM >= ? "
		cWhere  += " AND SG1A.D_E_L_E_T_ = ' ' "

		cQuery := cSelect +  cFrom +  cWhere

		aadd(aBind, xFilial("SG1"))
		aadd(aBind, DTOS(dDataBase))
		aadd(aBind, xFilial("SD1"))
		aadd(aBind, DTOS(dDataBase))
		aadd(aBind, xFilial("SD1"))
		aadd(aBind, xFilial("SG1"))
		aadd(aBind, cCodProd)
		aadd(aBind, DTOS(dDataBase))

		dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliascJM,.T.,.F.)

		//nivel 1 e nivel 2 a query principal resolve, a partir do nivel 3 temos q olhar recursivamente os niveis para encontrar a ultima entrada
		//Cuidado com relação as quantidades q podem aumentar de forma exponencial !!!!

		(cAliascJM)->(DBGoTop())
		While (cAliascJM)->(!EOF())

			If !Empty((cAliascJM)->D1_DOC)

				nIcmsEst := (((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT) * (cAliascJM)->G1_QTESTR ) * nQuantSai
				nIcmsUnit:= ((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT)

				Aadd(aFillEstr,{(cAliascJM)->D1_DOC,;     //1
				(cAliascJM)->D1_SERIE,;   //2
				(cAliascJM)->G1_PRCOMP,;   //3
				(cAliascJM)->D1_FORNECE,;   //4
				(cAliascJM)->D1_LOJA ,;   //5
				(cAliascJM)->D1_DTDIGIT,;   //6
				Alltrim((cAliascJM)->D1_LOTECTL),;   //7
				(cAliascJM)->D1_UM,;   //8
				(cAliascJM)->D1_SEGUM,;   //9
				(cAliascJM)->D1_QTSEGUM,;   //10
				(cAliascJM)->G1_PRCOMP,;   //11
				(cAliascJM)->G1_QTESTR,;   //12
				(cAliascJM)->G1_PRDINT,;   //13
				nIcmsUnit,;   //14
				nIcmsEst})     //15


				nTotalEst += nIcmsEst

			Else
				If Alltrim(cPrdIntAnt) <> Alltrim((cAliascJM)->G1_PRDINT)
					Aadd(aFindComp,{(cAliascJM)->G1_PRDINT})
					cPrdIntAnt := Alltrim((cAliascJM)->G1_PRDINT)
				Endif
			Endif

			(cAliascJM)->(DbSkip())
		Enddo

		dbSelectArea(cAliascJM)
		(cAliascJM)->(dbCloseArea())

		If Len(aFindComp) > 0

			For nZ := 1 to 97 //Já foram tratados 2 Niveis na primeira execução, daqui em diante é tratado o restante dos niveis.

				If nZ > Len(aFindComp)
					Exit

				Else

					aBind := {}
					cAliasCjm := GetNextAlias()
					cPrdIntAnt := ""

					aadd(aBind, xFilial("SG1"))
					aadd(aBind, DTOS(dDataBase))
					aadd(aBind, xFilial("SD1"))
					aadd(aBind, DTOS(dDataBase))
					aadd(aBind, xFilial("SD1"))
					aadd(aBind, xFilial("SG1"))
					aadd(aBind, alltrim(aFindComp[nZ][1]))
					aadd(aBind, DTOS(dDataBase))

					dbUseArea(.T.,"TOPCONN",TcGenQry2(,,cQuery,aBind),cAliascJM,.T.,.F.)
					(cAliascJM)->(DBGoTop())

					While (cAliascJM)->(!EOF())

						If !Empty((cAliascJM)->D1_DOC) .and. !Empty((cAliascJM)->G1_PRDINT)
							nIcmsEst := (((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT) * (cAliascJM)->G1_QTESTR ) * nQuantSai
							nIcmsUnit:= ((cAliascJM)->D1_VALICM / (cAliascJM)->D1_QUANT)

							Aadd(aFillEstr,{(cAliascJM)->D1_DOC,;     //1
							(cAliascJM)->D1_SERIE,;   //2
							(cAliascJM)->G1_PRCOMP,;   //3
							(cAliascJM)->D1_FORNECE,;   //4
							(cAliascJM)->D1_LOJA ,;   //5
							(cAliascJM)->D1_DTDIGIT,;   //6
							Alltrim((cAliascJM)->D1_LOTECTL),;   //7
							(cAliascJM)->D1_UM,;   //8
							(cAliascJM)->D1_SEGUM,;   //9
							(cAliascJM)->D1_QTSEGUM,;   //10
							(cAliascJM)->G1_PRCOMP,;   //11
							(cAliascJM)->G1_QTESTR,;   //12
							(cAliascJM)->G1_PRDINT,;   //13
							nIcmsUnit,;   //14
							nIcmsEst})     //15

							nTotalEst += nIcmsEst
						Else
							If Alltrim(cPrdIntAnt) <> Alltrim((cAliascJM)->G1_PRDINT)
								Aadd(aFindComp,{(cAliascJM)->G1_PRDINT})
								cPrdIntAnt := Alltrim((cAliascJM)->G1_PRDINT)
							Endif

						Endif

						(cAliascJM)->(DbSkip())

					Enddo

					dbSelectArea(cAliascJM)
					(cAliascJM)->(dbCloseArea())
				Endif

			Next nZ

		Endif

		aAdd(aPesqEstr,{cCodProd,nTotalEst,nQuantSai})
		nX	:= Len(aPesqEstr)

		if !Empty(cDocSai) .and. Len(aFillEstr) > 0
			GravaCJM(aFillEstr, cCodProd, nQuantSai,nItemSai,aNfCab[NF_DTEMISS],cDocSai,cSerie, cCliFor ,cLoja)
		Endif

	EndIF

Return nX

//-------------------------------------------------------------------
/*/{Protheus.doc} FisDelCjm

Função para Realizar a exclusão dos registros na tabela CJM quando a
nota de saida for (SD2,SFT) for excluida.

@param - código do produto e quantidade a ser verificado

@author Alexandre Esteves, Bruce Mello
@since 22/07/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------

Function FisDelCjm(cDocSai,cSerie, cCliFor ,cLoja)

	Local cChavEx := ""

	Default cDocSai := ""
	Default cSerie  := ""
	Default cClifor := ""
	Default cLoja	:= ""

	If !Empty(cDocSai)
		cChavEx := cDocSai+cSerie+cCliFor+cLoja
		dbSelectArea("CJM")
		CJM->(dbSetOrder(1))
		//CJM_FILIAL+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA+CJM_ITEFIM+CJM_PRDFIM+CJM_PRCOMP
		If CJM->(MsSeek(xFilial("CJM")+cChavEx))
			While !CJM->(Eof()) .And. xFilial("CJM")+cChavEx == CJM->(CJM_FILIAL+CJM_DOCSAI+CJM_SERSAI+CJM_CLIFOR+CJM_LOJA)
				If Reclock("CJM", .F.)
					CJM->(DbDelete())
					CJM->(MsUnlock())
					CJM->(FkCommit())
				Endif
				CJM->(DbSkip())
			Enddo
		Endif
	Endif

Return

/*/{Protheus.doc} aStructFields
  Função que obtém os campos da SX3 e os transforma em uma estrutura necessária para passar no oBulk:setFields.
  @type Static Function
  @author Rafael P. Gonçalves / Luiz Felipe da Silva Oliveira
  @since 27/09/2024
  @version version
  @param aFields - Array com os campos da SX3
  @return aStruct - Estrutura necessária para passar no oBulk:setFields
  @see (links_or_references)
/*/
Static Function aStructFields(cTable as string, aFields as array)

	Local aStruct := {} as array
	Local nI      := 0 	as Integer
	Local cField  := "" as Character
	Local aTamSX3 as array
	Local nLen    := Len(aFields) as Integer

	For nI := 1 To nLen
		cField    := aFields[nI]
		aTamSX3   := FisTamSX3(cTable, cField)
		//Adicionando campos que serão usados na tabela temporária
		//[1] - Campo
		//[2] - Tipo
		//[3] - Tamanho
		//[4] - Decimais
		aAdd(aStruct,{cField, aTamSX3[3], aTamSX3[1], aTamSX3[2]})
	Next nI

	FwFreeArray(aTamSX3)

Return (aStruct)

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaCJM

Função para Realizar a gravação dos registros na tabela CJM quando a
nota de saida for (SD2,SFT) for incluida via Mata460.

@author Alexandre Esteves, Bruce Mello
@since 09/08/2022
@version 12.1.2210
/*/
//-------------------------------------------------------------------

Static Function GravaCJM(aFillEstr, cCodProd, nQuantSai,nitem,dDtEmiss,cDocSai,cSerie, cCliFor ,cLoja)

	Local cFilCjm 			:= ""
	Local cMsg					:= ""
	Local lRet 					:= .T.
	Local nX 						:= 0
	Local oBulk 				:= Nil
	Local lCanUseBulk		:= .F.
	Local nDecQTSEGU		:= FisTamSX3('CJM',"CJM_QTSEGU")[2] as Integer
	Local nDecQTDSAI		:= FisTamSX3('CJM',"CJM_QTDSAI")[2] as Integer
	Local nDecICMEST		:= FisTamSX3('CJM',"CJM_ICMEST")[2] as Integer
	Local nDecQTESTR		:= FisTamSX3('CJM',"CJM_QTESTR")[2] as Integer
	Local nDecICMUNT		:= FisTamSX3('CJM',"CJM_ICMUNT")[2] as Integer
	Local aStruct				:= aStructFields("CJM", {	"CJM_FILIAL",;	//1
	"CJM_DOCORI",;	//2
	"CJM_SERORI",;	//3
	"CJM_PRDORI",;	//4
	"CJM_DTORIG",;	//5
	"CJM_LOTORI",;	//6
	"CJM_UM",;			//7
	"CJM_SEGUM",;		//8
	"CJM_QTSEGU",;	//9
	"CJM_DOCSAI",;	//10
	"CJM_SERSAI",;	//11
	"CJM_QTDSAI",;	//12
	"CJM_CLIFOR",;	//13
	"CJM_LOJA",;		//14
	"CJM_ICMEST",;	//15
	"CJM_PERIOD",;	//16
	"CJM_PRDFIM",;	//17
	"CJM_PRCOMP",;	//18
	"CJM_QTESTR",;	//19
	"CJM_FORNEC",;	//20
	"CJM_LOJAEN",;	//21
	"CJM_ITEFIM",;	//22
	"CJM_PRDINT",;	//23
	"CJM_ICMUNT",;	//24
	"CJM_DTSAI";		//25
	}) as array

	Default cCodProd 		:= ""
	Default cDocSai  		:= ""
	Default cSerie   		:= ""
	Default cClifor  		:= ""
	Default cLoja	 			:= ""
	Default nQuantSai		:= 0
	Default nItem 			:= 0
	Default aFillEstr 	:= {}

	cFilCjm	:= xFilial("CJM")
	oBulk	:= FwBulk():New(RetSqlName("CJM"),850)
	lCanUseBulk := FwBulk():CanBulk()
	if lCanUseBulk

		oBulk:SetFields(aStruct)

		For nX := 1 to Len(aFillEstr)

			If aFillEstr[nX][15] > 0

				lRet := oBulk:addData({ cFilCjm      						,; //1-CJM_FILIAL
				aFillEstr[nX][1]       							,; //2-CJM_DOCORI
				aFillEstr[nx][2]       							,; //3-CJM_SERORI
				aFillEstr[nx][3]    								,; //4-CJM_PRDORI
				STOD(aFillEstr[nx][6]) 							,; //5-CJM_DTORIG
				Alltrim(aFillEstr[nx][7])						,; //6-CJM_LOTORI
				aFillEstr[nx][8] 										,; //7-CJM_UM
				aFillEstr[nx][9]         						,; //8-CJM_SEGUM
				Round(aFillEstr[nx][10],nDecQTSEGU)	,; //9-CJM_QTSEGU
				cDocSai  														,; //10-CJM_DOCSAI
				cSerie    													,; //11-CJM_SERSAI
				Round(nQuantSai,nDecQTDSAI)					,; //12-CJM_QTDSAI
				cClifor      												,; //13-CJM_CLIFOR
				cLoja   														,; //14-CJM_LOJA
				Round(aFillEstr[nx][15],nDecICMEST)	,; //15-CJM_ICMEST
				LEFT(DTOS(dDtEmiss),6) 							,; //16-CJM_PERIOD
				Alltrim(cCodProd) 									,; //17-CJM_PRDFIM
				aFillEstr[nx][11]										,; //18-CJM_PRCOMP
				Round(aFillEstr[nx][12],nDecQTESTR)	,; //19-CJM_QTESTR
				aFillEstr[nx][4]   									,; //20-CJM_FORNEC
				aFillEstr[nx][5] 										,; //21-CJM_LOJAEN
				nitem  															,; //22-CJM_ITEFIM
				aFillEstr[nx][13]    								,; //23-CJM_PRDINT
				Round(aFillEstr[nx][14],nDecICMUNT)	,; //24-CJM_ICMUNT
				DTOS(dDtEmiss)})											 //25-CJM_DTSAI

				cMsg := Iif(lRet, "", oBulk:getError())
			Endif
		Next

		//Se os dados estiverem corretos, faz o Close do FwBulk para inserir possíveis registros não inseridos e finalizar o bulk.
		If lRet
			lRet := oBulk:Close()
			cMsg := Iif(lRet, "", oBulk:getError())
		EndIf

		//Limpa objeto do FwBulk para reutilizar com outra tabela.
		oBulk:Destroy()
		oBulk := nil
		FwFreeObj(oBulk)
	endIf

Return

/*/{Protheus.doc} CargOPER

    Esta função carrega os operandos do configurador em um JSON

    @param

    @author Julia Mota, Rafael Oliveira
    @since 17/11/2022
    @version 12.1.2210

/*/

Function CargOper(aNfCab,cCampo,aNfItem,nItem, lde)


	If ValidCfg(aNfCab,cCampo,aNfItem,nItem) //Valido se tem calculo no configurador

		IF lde
			jOpAntes  := JsonObject():new()//fiz esta atribuição para jOpAntes  nao ficar como nil, caso contrario ao executar a função Ler ocorreria errorlog e também para que ocorra o preenchimento correto do jTributo
			jTributo := jOpAntes
		else
						jOpDepois := JsonObject():new()
			jTributo := jOpDepois
		Endif


		jTributo["IT_FRETE"]           := aNfItem[nItem][IT_FRETE]
		jTributo["IT_VALMERC"]         := aNfItem[nItem][IT_VALMERC]
		jTributo["IT_BASEICM"]         := aNfItem[nItem][IT_BASEICM]
		jTributo["IT_BICMORI"]         := aNfItem[nItem][IT_BICMORI]
		jTributo["IT_VALICM"]          := aNfItem[nItem][IT_VALICM]
		jTributo["IT_BASEDUP"]         := aNfItem[nItem][IT_BASEDUP]
		jTributo["IT_TOTAL"]           := aNfItem[nItem][IT_TOTAL]
		jTributo["IT_ALIQICM"]         := aNfItem[nItem][IT_ALIQICM]
		jTributo["IT_ALIQSOL"]         := aNfItem[nItem][IT_ALIQSOL]
		jTributo["IT_SEGURO"]          := aNfItem[nItem][IT_SEGURO]
		jTributo["IT_DEDICM"]          := aNfItem[nItem][IT_DEDICM]
		jTributo["IT_VALSOL"]          := aNfItem[nItem][IT_VALSOL]
		jTributo["IT_QUANT"]           := aNfItem[nItem][IT_QUANT]
		jTributo["IT_ABVLISS"]         := aNfItem[nItem][IT_ABVLISS]
		jTributo["IT_ABMATISS"]        := aNfItem[nItem][IT_ABMATISS]
		jTributo["IT_ABSCINS"]         := aNfItem[nItem][IT_ABSCINS]
		jTributo["IT_ABVLINSS"]        := aNfItem[nItem][IT_ABVLINSS]
		jTributo["IT_PRCCF"]           := aNfItem[nItem][IT_PRCCF]
		jTributo["LF_VALCONT"]         := aNfItem[nItem][IT_LIVRO][LF_VALCONT]
		jTributo["IT_DESCONTO"]        := aNfItem[nItem][IT_DESCONTO]
	Endif

Return jTributo


/*/{Protheus.doc} LeJson

    Esta função lê os jsons da função CargOper e faz a comparação dos mesmos

    @author Julia Mota, Rafael Oliveira
    @since 18/11/2022
    @version 12.1.2210
/*/

Static Function LeJson(aNfCab,cCampo,aNfItem,nItem) //essa função le os dados do json
	Local aPropriedades := {}
	Local lret := .F.
	Local nX := 0

	IF (valtype(jOpAntes ) == 'J')
		aPropriedades := jOpAntes :GetNames()//Recupera propriedades do jOpAntes  colocando-as no array apropriedades
		CargOper(aNfCab,cCampo,aNfItem,nItem, .F.) //CHAMO A CARGA DE NOVO PARA PREENCHER O jOpDepois

			For nX := 1 to len(aPropriedades)
			IF jOpAntes [aPropriedades[nX]] == jOpDepois[aPropriedades[nX]]
					lret := .T.
					exit
				Endif
			NEXT
	Endif

	FREEOBJ( jOpAntes )
	FREEOBJ( jOpDepois )
	ASIZE( aPropriedades, 0 )

Return lret

/*/{Protheus.doc} RelTipoGNRE
	Função responsvel por relacionar e converter o ID TOTVS do tributo para o tipo de tributo da GNRE
	Obs.: Caso essa função seja alterada, o caso de teste unitário automatizado deve ser atualizado.

	@type  Static Function
	@author pereira.weslley
	@since 26/10/2023
	@version 12.1.2310
	@param cIDTOTVS, caracter, ID do tributo no Protheus
	@return cRet, caracter, Tipo de guia da GNRE para tributos legados

/*/
Static Function RelTipoGNRE(cIDTOTVS)
	Local cRet := ""

	Do CASE
	Case cIDTOTVS == "000001" .Or. cIDTOTVS == "000002" //FUNRURAL
		cRet := "4"
	Case cIDTOTVS == "000003" //SENAR
		cRet := "9"
	Case cIDTOTVS == "000010" //FUNDERSUL
		cRet := "6"
	Case cIDTOTVS == "000020" //ISS
		cRet := "2"
	Case cIDTOTVS == "000021" //ICMS
		cRet := "1"
	Case cIDTOTVS == "000056" //ICMS SUBSTITUIÇÃO TRIBUTÁRIA
		cRet := "3"
	Case cIDTOTVS == "000037" //DIFAL
		cRet := "B"
	Otherwise
		cRet := "D" //Tributo Genérico.
	Endcase

Return cRet

/*/{Protheus.doc} VldPrefRef
	Função responsável por retornar o valor dos tributos referenciados amarrados nas formulas
	@type  Static Function
	@author Erich Buttner
	@since 22/03/2024
	@version version
	@param cOperando - operando contido na formula das regras de base, Aliquota e de Calculo
	@param nRecnoOri - Recno da nota fiscal de Origem
	@param cTipMov - tipo do movimento E - Entrada / S - Saida
	@param cTpOper - Tipo de operação
	@return Retorna o Item do tributo referenciado
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function VldPrefRef(cOperando, nRecnoOri, cTipNF, cTpCliFor)
	Local cOperRef	:= AllTrim(cOperando)
	Local cTrbOper	:= ""
	Local cTpTrb	:= "VAL"
	Local cModoBus	:= "TRIB"
	Local aOperTok	:= {}
	Local lOperVal	:= .F.
	Local nRet		:= 0
	Local nValor	:= 0
	Local nRecAnt	:= 0
	Local cIdTrbNF 	:= ""

	//	Formato legado: ORI:VAL:ICMS01 / ORI:BAS:ICMS01 / ORI:ALQ:ICMS01
	//	Formato TID novo: T:ORI:VAL:000021 / T:ORI:BAS:000021 / T:ORI:ALQ:000021
	aOperTok := StrTokArr(cOperRef, ":")

	If Len(aOperTok) >= 3 .And. Upper(aOperTok[1]) == "T" .And. Upper(aOperTok[2]) == "ORI"

		// Novo: T:ORI:<TIPO>:000021
		cModoBus := "ID"
		cTrbOper := "ID:" + AllTrim(aOperTok[4])
		lOperVal := .T.
		cTpTrb   := AllTrim(aOperTok[3])
		
	EndIf

	// Legado: ORI:<TIPO>:ICMS01
	If !lOperVal
		cTrbOper := "TRB:" + AllTrim(aOperTok[3])
		lOperVal := .T.
		cTpTrb   := AllTrim(aOperTok[2])
	EndIf

	If cTipNF $ "N" .And. cTpCliFor == "C"

		cIdTrbNF := SD2->D2_IDTRIB

		If (nRecAnt := SD2->(Recno())) <> nRecnoOri
			DbGoTo(nRecnoOri)
			cIdTrbNF := SD2->D2_IDTRIB
			DbGoTo(nRecAnt)
		EndIf

	ElseIf cTipNF $ "NC" .And. cTpCliFor == "F"

		cIdTrbNF := SD1->D1_IDTRIB

		If (nRecAnt := SD1->(Recno())) <> nRecnoOri
			DbGoTo(nRecnoOri)
			cIdTrbNF := SD1->D1_IDTRIB
			DbGoTo(nRecAnt)
		EndIf

	EndIf

	If !Empty(cIdTrbNF)

		If PesqRef(@nValor, cTpTrb, cIdTrbNF, cTrbOper)
			nRet := nValor
		Else
			QryPrefRef(cTrbOper, cTpTrb, cIdTrbNF, cModoBus)
			PesqRef(@nValor, cTpTrb, cIdTrbNF, cTrbOper)
			nRet := nValor
		EndIf

	EndIf

Return nRet

/*/{Protheus.doc} QryPrefRef
	Função responsável por retornar o valor dos tributos referenciados amarrados nas formulas
	@type  Static Function
	@author Erich Buttner
	@since 22/03/2024
	@version version
	@param cTrbOper - Código do tributo no formato legado (TRB:ICMS01) ou novo (ID:000021)
	@param cTpTrb - Tipo do valor a ser retornado (VAL, BAS, ALQ, etc)
	@param cIdTrbNF - ID do tributo na nota fiscal
	@param cModoBus - Modo de busca para o tributo, pode ser por ID ou por código do tributo
	
	@return Nenhum, mas preenche a variável global nValor que é retornada na função VldPrefRef
	
/*/
Static Function QryPrefRef(cTrbOper, cTpTrb, cIdTrbNF, cModoBus)
	Local cQry 		:= ""
	Local cMD5		:= ""
	Local cAliasCJ3	:= ""
	Local cTrbBus	:= ""
	Local cIdBus	:= ""	

	Default cModoBus := "TRIB"

	If Upper(cModoBus) == "ID"
		cIdBus  := StrTran(cTrbOper, "ID:", "")
	Else
		cTrbBus := StrTran(cTrbOper, "TRB:", "")
	EndIf

	// Monta query com nomes de tabelas resolvidos (SEM setUnsafe)
	cQry := " SELECT F2D.F2D_BASE BASE, F2D.F2D_ALIQ ALIQ, CJ3.CJ3_VLTRIB LVALTRIB, CJ3.CJ3_VLISEN LISENTO, "
	cQry += " CJ3.CJ3_VLOUTR LOUTROS, CJ3.CJ3_VLNTRI LNTRIB, CJ3.CJ3_VLDIFE LDIFERIDO, CJ3.CJ3_VLMAJO LMAJORADO,"
	cQry += " CJ3.CJ3_PEMAJO LPERCMAJ, CJ3.CJ3_PEDIFE LPERCDIF, CJ3.CJ3_PEREDU LPERCRED, CJ3.CJ3_PAUTA LPAUTA, CJ3.CJ3_MVA LMVA, "
	cQry += " CJ3.CJ3_AUXMVA LAUXMVA, CJ3.CJ3_AUXMAJ LAUXMAJ, CJ3.CJ3_CSTCAB LCSTCAB, CJ3.CJ3_BASORI LBASORI "	
	cQry += " FROM " + RetSqlName("F2D") + " F2D "
	cQry += " INNER JOIN " + RetSqlName("CJ3") + " CJ3 ON CJ3.CJ3_FILIAL = ? AND CJ3.CJ3_IDF2D = F2D.F2D_ID AND CJ3.D_E_L_E_T_ = ' ' "

	If Upper(cModoBus) == "ID"
		cQry += " INNER JOIN " + RetSqlName("F2B") + " F2B ON F2B.F2B_FILIAL = ? AND F2B.F2B_ID = F2D.F2D_IDCAD AND F2B.D_E_L_E_T_ = ' ' "
		cQry += " INNER JOIN " + RetSqlName("F2E") + " F2E ON F2E.F2E_FILIAL = ? AND F2E.F2E_TRIB = F2B.F2B_TRIB AND F2E.D_E_L_E_T_ = ' ' "
		cQry += " WHERE F2D.F2D_FILIAL = ? "
		cQry += " AND F2D.F2D_IDREL = ? "
		cQry += " AND F2E.F2E_IDTRIB = ? "
	Else
		cQry += " WHERE F2D.F2D_FILIAL = ? "
		cQry += " AND F2D.F2D_IDREL = ? "
		cQry += " AND F2D.F2D_TRIB = ? "
	EndIf

	cQry += " AND F2D.D_E_L_E_T_ = ' ' "

	cMD5 := MD5(cQry)
	If (nPosPrepared := Ascan(__aPrepared,{|x| x[2] == cMD5})) == 0
		Aadd(__aPrepared,{FWExecStatement():New(),cMD5})
		nPosPrepared := Len(__aPrepared)
		__aPrepared[nPosPrepared][1]:SetQuery(ChangeQuery(cQry))
	EndIf

	If Upper(cModoBus) == "ID"
		__aPrepared[nPosPrepared][1]:setString(1, xFilial("CJ3"))
		__aPrepared[nPosPrepared][1]:setString(2, xFilial("F2B"))
		__aPrepared[nPosPrepared][1]:setString(3, xFilial("F2E"))
		__aPrepared[nPosPrepared][1]:setString(4, xFilial("F2D"))
		__aPrepared[nPosPrepared][1]:SetString(5, cIdTrbNF)
		__aPrepared[nPosPrepared][1]:setString(6, cIdBus)
	Else
		__aPrepared[nPosPrepared][1]:setString(1, xFilial("CJ3"))
		__aPrepared[nPosPrepared][1]:setString(2, xFilial("F2D"))
		__aPrepared[nPosPrepared][1]:SetString(3, cIdTrbNF)
		__aPrepared[nPosPrepared][1]:setString(4, cTrbBus)
	EndIf

	cAliasCJ3 := __aPrepared[nPosPrepared][1]:OpenAlias()

	IF ValType(jTrbRef) != "J"
		jTrbRef := JsonObject():new()
	EndIF

	jTrbRef[cIdTrbNF+cTrbOper] := {}

	While (cAliasCJ3)->(!Eof())

		jSonTrbRef := JsonObject():new()

		jSonTrbRef["BAS"] := (cAliasCJ3)->BASE
		jSonTrbRef["ALQ"] := (cAliasCJ3)->ALIQ
		jSonTrbRef["VAL"] := (cAliasCJ3)->LVALTRIB
		jSonTrbRef["ISE"] := (cAliasCJ3)->LISENTO
		jSonTrbRef["OUT"] := (cAliasCJ3)->LOUTROS
		jSonTrbRef["DIF"] := (cAliasCJ3)->LDIFERIDO

		Aadd(jTrbRef[cIdTrbNF+cTrbOper], jSonTrbRef)

		FreeObj(jSonTrbRef)

		(cAliasCJ3)->(DbSkip())

	EndDo

	(cAliasCJ3)->(DbCloseArea())

	If Empty(jTrbRef[cIdTrbNF+cTrbOper])
		jSonTrbRef := JsonObject():new()

		jSonTrbRef["BAS"] := 0
		jSonTrbRef["ALQ"] := 0
		jSonTrbRef["VAL"] := 0
		jSonTrbRef["ISE"] := 0
		jSonTrbRef["OUT"] := 0
		jSonTrbRef["DIF"] := 0

		Aadd(jTrbRef[cIdTrbNF+cTrbOper], jSonTrbRef)

		FreeObj(jSonTrbRef)

	EndIf


Return

/*/{Protheus.doc} PesqRef
	Função que pesquisa se o tributo ja foi processado pela query, esta pesquisa será dentro do json jTrbRef
	@type  Static Function
	@author Erich Buttner
	@since 26/03/2024
	@version 12.1.2210, 12.1.2310
	@param oJson - objeto onde será alocado as informações do tributo
	@param cChave - chave do tributo
	@return lRet - caso tributo ja esteja gravado no objeto irá retornar .T. caso contrario .F.
/*/
Static Function PesqRef(nValor, cTpTrb, cIdTrbNF, cTrbOper)
	Local lRet	 := .F.
	Local jRet := Nil
	Local cChave := cIdTrbNF+cTrbOper


	If Valtype(jTrbRef) == "J"

		jRet := jTrbRef[cChave]
		IF !Empty(jRet)
			nValor := jRet[1][cTpTrb]
			lRet := .T.
		Endif
	Else
		jTrbRef := JsonObject():new()
		lRet := .F.
	Endif

Return lRet

/* {Protheus.doc} GetTaxRef
	Recebe Tipo, ID TOTVS, busca/monta a relação de referencias, e entao retorna o valor de BASE, ALIQ ou VALOR de um tributo com base na sua referencia no legado (TES)
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@param cType - (Character) Tipo do tributo (BSE, ALQ OU VAL)
	@param cIdTotvs - (Character) ID do tributo no Protheus
	@param aNfItem - (Array) de itens da MATXFIS já posicionado no item que está sendo processado
	@return nRetVal - Retorna o valor do tributo de BASE, ALIQ ou VALOR do tributo
*/
Static Function GetTaxRef( cType , cIdTotvs , aNfItem )
	Local xAPosLeg
	Local nRetVal := 0
	Local cRefOrg := fOrigRef( cIdTotvs , cType ) // Se referencia esta dentro do livro fiscal (IT_LIVRO), na TES (IT_TS) ou em nivel de item

	xAPosLeg := GetPosRef( cType , cIdTotvs )

	If !Empty(xAPosLeg)
		nRetVal := RetValByPos( xAPosLeg , aNfItem , cRefOrg )
	EndIf

Return nRetVal

/* {Protheus.doc} RetValByPos
	Recebe a posicao da referencia, e retorna o Valor da referencia (TES) no aNfItem, tratando se a referencia informada é um array ou não
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@param nAPosLeg - (Character or Number) Posicao do tributo no legado (TES) (Ex: "1,2" (Array) ou 1 (Number))
	@param aNfItem - (Array) de itens da MATXFIS já posicionado no item que está sendo processado
	@param cIdTotvs - (Character) ID do tributo no Protheus (Ex: "000001")
	@return nRetVal - Retorna o valor de BASE, ALIQ ou VALOR do tributo
*/
Static Function RetValByPos(nAPosLeg , aNfItem, cOrigRef)
	Local aPosRef := {}
	Local nRetVal := 0

	If valtype(nAPosLeg) == 'C' .AND. "," $ nAPosLeg

		aPosRef := StrTokArr2( nAPosLeg , "," )

		If Len(aPosRef)==2
			nRetVal := aNfItem[ Val(aPosRef[1]) ][ Val(aPosRef[2]) ]
		EndIf

	Else
		If cOrigRef == "IT_LIVRO" // Se for livro fiscal, busca o valor no array de referencias do livro fiscal
			nRetVal := aNfItem[IT_LIVRO][nAPosLeg]
		ElseIf cOrigRef == "IT_TS" // Busca o valor no array de referencias da TES
			nRetVal := aNfItem[IT_TS][nAPosLeg]
		Else
			nRetVal := aNfItem[nAPosLeg]
		EndIf
	EndIf

	aSize(aPosRef, 0)
	aPosRef := nil

Return nRetVal

/* {Protheus.doc} fOrigRef
	Retorna  a referencia do tributo no legado (TES) ou livro fiscal (IT_LIVRO) baseado no ID do tributo e tipo (BSE, ALQ ou VAL)
	@type  Static Function
	@author Douglas Dourado
	@since 24/06/2025
	@version 12.1.2410
	@param cIdTotvs - (Character) ID do tributo legado no Protheus (ex: "000001")
	@param cType - (Character) "BSE", "ALQ" OU "VAL"
	@return cRet (Character) - Retorna a referencia do tributo no legado (TES) ou livro fiscal (IT_LIVRO) ou item
*/
Static Function fOrigRef( cIdTotvs , cType )
	Local aTribLiv := { TRIB_ID_PRES_ICMS, TRIB_ID_PRES_ST, TRIB_ID_PRODEPE, TRIB_ID_PRES_CARGA }// Array de tributos que cujas referencias de base/aliq/valor são referentes a livro fiscal
	Local cRet := ""

	// Verifica se o ID do tributo é referente a livro fiscal
	If aScan(aTribLiv, cIdTotvs) > 0
		cRet := "IT_LIVRO"
	EndIf

	If cIdTotvs == TRIB_ID_PRES_ICMS .AND. cType == "ALQ"
		cRet := "IT_TS" // Se for Cred. Presumido ICMS e tipo ALQ, a referencia está na TES (IT_TS)
	EndIf

Return cRet

/* {Protheus.doc} GetPosRef
	Retorna a POSIÇÂO da BASE, ALIQ ou VALOR de um tributo com base na sua referencia (aNfItem) do legado (TES)
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@param cType - (Character) "BSE", "ALQ" OU "VAL"
	@param cIdTotvs - (Character) ID do tributo legado no Protheus (ex: "000001")
	@return nARet (Character ou Number) - Retorna a posicao da referencia do tributo no legado (TES)
*/
Static Function GetPosRef( cType , cIdTotvs )
	Local nARet

	// Verifico se já está em cache o objeto JSON com as referencias do legado, senao chamo o InitializeCache() para criar o objeto e armazenar em cache
	if (valType(jRefLeg) == "U")
		InitializeCache()
	EndIf

	// Verifico se o objeto jRefLeg (Em Cache/Static) se possui a propriedade cIdTotvs (ID do tributo no Protheus)
	If jRefLeg:hasProperty(cIdTotvs)
		If jRefLeg[cIdTotvs]:hasProperty(cType)
			nARet := jRefLeg[cIdTotvs][cType]
		EndIf
	EndIf

Return nARet

/* {Protheus.doc} InitializeCache
	Inicializa o cache (jRefLeg) que contem as relação entre referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR)
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@return nil
*/
Static Function InitializeCache()
	Local cJSON := ''

	cJSON := GetTaxList()

	If !Empty(cJSON)
		jRefLeg := JsonObject():new() // Static/Cached object
		jRefLeg:FromJson( cJSON )
	EndIf

Return

/* {Protheus.doc} GetTaxList
	Retorna uma string com um JSON com as referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR)
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@return nil
*/
Static Function GetTaxList()
Return BuildTaxJSON( GetTaxRefList() )

/* {Protheus.doc} BuildTaxJSON
	Recebe um array com as referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR) e monta uma string JSON com essas informacoes
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@param aRefList - (Array) Com as referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR)
	@return cJSON (Character) - Retorna uma string com um JSON com as referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR)
*/
Static Function BuildTaxJSON( aRefList )
	Local nI := 0
	Local cJSON := '{'

	For nI := 1 To Len(aRefList)
		cJSON += '"' + cValToChar(aRefList[nI][1]) +;
			'" :{ "BSE" : ' + FormatRef( aRefList[nI][2] ) +;
			' , "ALQ" : ' + FormatRef( aRefList[nI][3] ) +;
			' , "VAL" : ' + FormatRef( aRefList[nI][4] ) +;
			' , "PTA" : ' + FormatRef( aRefList[nI][5] ) +;
			' , "BSE2" : '+ FormatRef( aRefList[nI][6] ) +;
			' },'
	Next nI

	If Len(aRefList) > 0
		cJSON := SubStr( cJSON, 1, len(cJSON)-1 ) // Retira a ultima virgula
	EndIf

	cJSON +=  '}'

Return cJSON

/* {Protheus.doc} FormatRef
	Formata a referencia com base no seu tipo, se é um array ou não, e retorna o valor formatado, pronto para ser inserido no JSON
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@param Ref - (Array or Number) Referencia do legado (TES)
	@return cRet (Character) - Retorna o valor formatado da referencia, pronto para ser inserido no JSON
*/
Static Function FormatRef( Ref )
	Local cRet := ''

	If valtype(Ref) == 'A'
		cRet := '"' + ArrToNum(Ref) + '"'
	Else
		cRet := cValToChar(Ref)
	EndIf

Return cRet

/* {Protheus.doc} ArrToNum
	Recebe uma referencia que é um array e retorna o valor formatado, pronto para ser inserido no JSON
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@param aNumbers - (Array)
	@return cRet (Character) - Retorna o valor formatado da referencia, pronto para ser inserido no JSON
*/
Static Function ArrToNum( aNumbers )
	Local cRet := ''
	Local nI := 0

	For nI := 1 To Len(aNumbers)
		cRet += cValToChar(aNumbers[nI]) + ','
	Next

	If Len(cRet) > 0
		cRet := SubStr( cRet, 1, len(cRet)-1 ) // Retira a ultima virgula
	EndIf

Return cRet

/* {Protheus.doc} GetTaxRefList
	Retorna um array com as referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR)
	@type  Static Function
	@author Douglas Dourado
	@since 02/04/2025
	@version 12.1.2310 12.1.2410
	@return aList (Array) - Array com as referencias do legado (TES) e suas respectivas posicoes (BASE, ALIQ e VALOR)
*/
Static Function GetTaxRefList()
	Local aList := {}

	// Posições das referencias do legado: 1 = Id Totvs do Tributo / 2 = Base / 3 = Aliquota / 4 = Valor / 5 = Pauta / 6 = Base 2
	aadd(aList,{ TRIB_ID_FECPIC , IT_BASFECP, IT_ALIQFECP , IT_VALFECP , 0 , 0 })
	aadd(aList,{ TRIB_ID_FCPST , IT_BSFCPST, IT_ALFCST , IT_VFECPST , 0 , 0 })
	aadd(aList,{ TRIB_ID_FCPCMP , IT_BSFCCMP, IT_ALFCCMP , IT_VFCPDIF , 0 , 0 })
	aadd(aList,{ TRIB_ID_COF , IT_BASECF2, IT_ALIQCF2 , IT_VALCF2 , IT_PAUTCOF , 0 })
	aadd(aList,{ TRIB_ID_COFRET , IT_BASECOF, IT_ALIQCOF , IT_VALCOF , 0 , 0 })
	aadd(aList,{ TRIB_ID_COFST , IT_VALCF3, IT_BASECF3 , IT_ALIQCF3 , 0 , 0 })
	aadd(aList,{ TRIB_ID_PIS , IT_BASEPS2, IT_ALIQPS2 , IT_VALPS2 , IT_PAUTPIS , 0 })
	aadd(aList,{ TRIB_ID_PISRET , IT_BASEPIS, IT_ALIQPIS , IT_VALPIS , 0 , 0 })
	aadd(aList,{ TRIB_ID_PISST , IT_BASEPS3, IT_ALIQPS3 , IT_VALPS3 , 0 , 0 })
	aadd(aList,{ TRIB_ID_PISMAJ , 0, IT_ALQPMAJ , IT_VALPMAJ , 0 , 0 })
	aadd(aList,{ TRIB_ID_ISSBI , IT_BASECPM, IT_ALQCPM , IT_VALCPM , 0 , 0 })
	aadd(aList,{ TRIB_ID_COFMAJ , 0, IT_ALQCMAJ , IT_VALCMAJ , 0 , 0 })
	aadd(aList,{ TRIB_ID_DEDUCAO , 0, 0 , {IT_DEDICM} , 0 , 0 })
	aadd(aList,{ TRIB_ID_FRTAUT , {IT_BASEICA}, 0 , {IT_VALICA} , 0 , 0 })
	aadd(aList,{ TRIB_ID_ICMDES , 0, 0 , IT_DESCZF , 0 , 0 })
	aadd(aList,{ TRIB_ID_DZFPIS , 0, 0 , IT_DESCZFPIS , 0 , 0 })
	aadd(aList,{ TRIB_ID_DZFCOF , 0, 0 , IT_DESCZFCOF , 0 , 0 })
	aadd(aList,{ TRIB_ID_ESTICM , 0, 0 , IT_ESTCRED , 0 , 0 })
	aadd(aList,{ TRIB_ID_ICMSST , {IT_BASESOL}, {IT_ALIQSOL} , {IT_VALSOL} , 0 , 0 })
	aadd(aList,{ TRIB_ID_FRTEMB , IT_BASETST, IT_ALIQTST , IT_VALTST , 0 , 0 })
	aadd(aList,{ TRIB_ID_CRDOUT , 0, 0 , IT_CROUTSP , 0 , 0 })
	aadd(aList,{ TRIB_ID_STMONO , 0, 0 , 0 , 0 , 0 })
	aadd(aList,{ TRIB_ID_ISS , {IT_BASEISS}, {IT_ALIQISS} , {IT_VALISS} , 0 , 0 })
	aadd(aList,{ TRIB_ID_ICMS , {IT_BASEICM}, IT_ALIQICM , {IT_VALICM} , 0 , 0 })
	aadd(aList,{ TRIB_ID_IPI , {IT_BASEIPI}, IT_ALIQIPI , {IT_VALIPI} , 0 , 0 })
	aadd(aList,{ TRIB_ID_CIDE , IT_BASECID, IT_ALQCIDE , IT_VALCIDE , 0 , 0 })
	aadd(aList,{ TRIB_ID_CPRB , IT_BASECPB, IT_ALIQCPB , IT_VALCPB , 0 , 0 })
	aadd(aList,{ TRIB_ID_FEEF , IT_BASFEEF, IT_ALQFEEF , IT_VALFEEF , 0 , 0 })
	aadd(aList,{ TRIB_ID_CSLL , IT_BASECSL, IT_ALIQCSL , IT_VALCSL , 0 , 0 })
	aadd(aList,{ TRIB_ID_PROTEG , IT_BASEPRO, IT_ALIQPRO , IT_VALPRO , 0 , 0 })
	aadd(aList,{ TRIB_ID_FUMIPQ , IT_BASEFMP, IT_ALQFMP , IT_VALFMP , 0 , 0 })
	aadd(aList,{ TRIB_ID_PRES_ICMS , LF_BASECPR, TS_CRDPRES , LF_CRDPRES , 0 , 0 })
	aadd(aList,{ TRIB_ID_PRES_ST , 0, 0 , LF_CRPRST , 0 , 0 })
	aadd(aList,{ TRIB_ID_PRODEPE , 0, 0 , IT_CPPRODE , 0 , 0 })
	aadd(aList,{ TRIB_ID_PRES_CARGA , 0, 0 , LF_CRDPCTR , 0 , 0 })
	aadd(aList,{ TRIB_ID_SECP15 , {IT_BSCP15}, {IT_ALCP15} , {IT_VLCP15} , 0 , {IT_SECP15} })
	aadd(aList,{ TRIB_ID_SECP20 , {IT_BSCP20}, {IT_ALCP20} , {IT_VLCP20} , 0 , {IT_SECP20} })
	aadd(aList,{ TRIB_ID_SECP25 , {IT_BSCP25}, {IT_ALCP25} , {IT_VLCP25} , 0 , {IT_SECP25} })
	aadd(aList,{ TRIB_ID_INSSPT , IT_BASEINP, IT_PERCINP , IT_VALINP , 0 , 0 })
	aadd(aList,{ TRIB_ID_DIFAL , {IT_BASEDES}, {IT_ALIQCMP} , IT_DIFAL , 0 , 0 })
	aadd(aList,{ TRIB_ID_CMP , {IT_BASEDES}, {IT_ALIQCMP} , {IT_VALCMP} , 0 , 0 })
	aadd(aList,{ TRIB_ID_ANTEC , {IT_BASEDES}, IT_ALANTICMS , IT_VALANTI , 0 , 0 })
	aadd(aList,{ TRIB_ID_FUNRUR , IT_BASEFUN, IT_PERFUN , IT_FUNRURAL , 0 , 0 })
	aadd(aList,{ TRIB_ID_SENAR , IT_BSSENAR, IT_ALSENAR , IT_VLSENAR , 0 , 0 })
	aadd(aList,{ TRIB_ID_AFRMM , IT_BASEAFRMM, IT_ALIQAFRMM , IT_VALAFRMM , 0 , 0 })
	aadd(aList,{ TRIB_ID_FABOV , IT_BASEFAB, IT_ALIQFAB , IT_VALFAB , 0 , 0 })
	aadd(aList,{ TRIB_ID_FACS , IT_BASEFAC, IT_ALIQFAC , IT_VALFAC , 0 , 0 })
	aadd(aList,{ TRIB_ID_FAMAD , IT_BASEFMD, IT_ALQFMD , IT_VALFMD , 0 , 0 })
	aadd(aList,{ TRIB_ID_FASEMT , IT_BASFASE, IT_ALIFASE , IT_VALFASE , 0 , 0 })
	aadd(aList,{ TRIB_ID_FETHAB , IT_BASEFET, IT_ALIQFET , IT_VALFET , 0 , 0 })
	aadd(aList,{ TRIB_ID_FUNDERSUL , IT_VALFDS, 0 , 0 , 0 , 0 })
	aadd(aList,{ TRIB_ID_FUNDESA , IT_BASFUND, IT_ALIFUND , IT_VALFUND , 0 , 0 })
	aadd(aList,{ TRIB_ID_IMAMT , IT_BASIMA, IT_ALIIMA , IT_VALIMA , 0 , 0 })
	aadd(aList,{ TRIB_ID_SEST , {IT_BASESES}, {IT_ALIQSES} , {IT_VALSES} , 0 , 0 })
	aadd(aList,{ TRIB_ID_TPDP , {IT_BASTPDP}, {IT_ALITPDP} , {IT_VALTPDP} , 0 , 0 })
	aadd(aList,{ TRIB_ID_II , 0, {IT_ALIQII} , {IT_VALII} , 0 , 0 })
	aadd(aList,{ TRIB_ID_IR , {IT_BASEIRR}, {IT_ALIQIRR} , {IT_VALIRR} , 0 , 0 })
	aadd(aList,{ TRIB_ID_INSS , {IT_BASEINS}, {IT_ALIQINS} , {IT_VALINS} , 0 , 0 })

Return aList

/* {Protheus.doc} TeleInteg
	Envia Telemetria de quando o operando de integracao (O:VALOR_INTEGRACAO) é utilizado para o configurador de tributos
	@type  Static Function
	@author Douglas Dourado
	@since 08/04/2025
	@version 12.1.2310 12.1.2410
	@return Nil
*/
Static Function TeleInteg(cOper)	
	FWCustomMetrics():setMetric("Operandos de Integração utilizados pelo configurador de tributos", "totvs-fiscal-tributos-configurador_integra", cOper, , , "CONFXFIS")	
Return

/*/{Protheus.doc} RemoveTrbGen
	Função responsável por remover os tributos genéricos marcados para exclusão

	@type  Static Function
	@author Rafael Oliveira
	@since 14/05/2025
	@version 12.1.2410
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function RemoveTrbGen(aNfCab, aNfItem, nItem)
	Local aTributos := aNfItem[nItem][IT_TRIBGEN]
	Local nTrbGen := 0

	If ValType(aTributos) == "A" .AND. !Empty(aTributos)

		For nTrbGen := Len(aTributos) To 1 STEP -1

			// Verifica flag para remover o tributo genérico marcado para exclusão
			If aTributos[nTrbGen][TG_IT_DELETED_TRIB]
				// zera base e Valor do tributo genérico
				Mafisalt("IT_TRIBGEN", 0, nItem,,,,,,,{aNFItem[nItem][IT_TRIBGEN][TG_IT_SIGLA],"TG_IT_BASE"} )
				//Mafisalt("IT_TRIBGEN", 0, nItem,,,,,,,{aNFItem[nItem][IT_TRIBGEN][TG_IT_SIGLA],"TG_IT_VALOR"} )

				// Remove o tributo do cabeçalho
				If cPaisLoc == "BRA"
					DelFisSomaIt(aNfCab, aNfItem, nItem)
				Endif

				// Remove o tributo do item
				DelTgItem(aTributos, nTrbGen)

			Endif
		Next

	Endif

Return .T.


/*/{Protheus.doc} DelTgItem
	Função responsável por remover o tributo genérico do item

	@type  Static Function
	@author user
	@since 14/05/2025
	@version version
	@param aTributos, array, Array de tributos
	@param nTrbGen, number, Posição do tributo genérico a ser removido
	@return nil, nil, Retorna nil
/*/
Static Function DelTgItem(aTributos, nTrbGen)

	//Limpa o array antes de remover o tributo
	aSize(aTributos[nTrbGen], 0)

	//Remove o tributo do array
	aDel( aTributos, nTrbGen )

	//Ajusta o tamanho do array
	aSize( aTributos, Len(aTributos)-1)

Return

/*/{Protheus.doc} ValidaTGLimite
	Função responsável por validar o limite de valores do tributo por outros tributos
	
	@type  Static Function
	@author Rafael Oliveira
	@since 15/05/2025
	@version 12.1.2410
	@param aNfItem, array, Array de itens da MATXFIS
	@param nItem, number, Item que está sendo processado
	@param aNfCab, array, Array de cabeçalho da MATXFIS
	@return nil, nil, Retorna nil
	@history 06/03/2026, joao.manoel, Adicionando a variavel lNoCabec e setar o valor dela para .T. quando chamar a Mafisalt não afetar os dados cabeçano do array aNfCab
/*/
Static Function ValidaTGLimite(aNfItem, nItem, aNfCab)

	Local aTribGen   := aNfItem[nItem][IT_TRIBGEN]
	Local cAcaoMax   := ""
	Local cAcaoMin   := ""
	Local cOprMax    := ""
	Local cOprMin    := ""
	Local cRefTrGen  := ""
	Local cSigTrGen  := ""
	Local nPosTrbGen := 0
	Local nResultado := 0
	Local nTrbGen    := 0
	Local nValAtual  := 0
	Local nVlrTGMax  := 0
	Local nVlrTGMin  := 0
	Local lNoCabec	 := .F.

	If !Empty(aTribGen)

		For nTrbGen := Len(aTribGen) To 1 STEP -1

			If !aTribGen[nTrbGen][TG_IT_DELETED_TRIB]

				cOprMax   := aTribGen[nTrbGen][TG_IT_OPR_MAX]
				cOprMin   := aTribGen[nTrbGen][TG_IT_OPR_MIN]
				cAcaoMax  := aTribGen[nTrbGen][TG_IT_ACAO_MAX]
				cAcaoMin  := aTribGen[nTrbGen][TG_IT_ACAO_MIN]
				nValAtual := aTribGen[nTrbGen][TG_IT_VALOR]

				If !Empty(AllTrim(cOprMax)) .And. IsOperTrib(cOprMax) .and. nValAtual > 0
					cSigTrGen	:= Alltrim(SubStr(cOprMax, 5, len(cOprMax)))
					cRefTrGen	:= Alltrim(SubStr(cOprMax, 1, 3))

					If (nPosTrbGen := aScan(aTribGen,{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cSigTrGen)})) > 0

						nVlrTGMax := RetValTrib(cRefTrGen, aNfItem, nItem, nPosTrbGen)

						If nVlrTGMax > 0 .and. nValAtual > nVlrTGMax

							nResultado 	:= ProcMaxAcao(aNfItem, nItem, nTrbGen, nVlrTGMax, cAcaoMax)
							lNoCabec	:= .T.

							//Ajusta o valor do tributo genérico para o limite máximo
							Mafisalt("IT_TRIBGEN", nResultado, nItem,lNoCabec,,,,,,{aTribGen[nTrbGen][TG_IT_SIGLA],"TG_IT_VALOR"} )
						Endif
					Endif


				ElseIF !Empty(AllTrim(cOprMin)) .And. IsOperTrib(cOprMin) .and. nValAtual > 0

					cSigTrGen	:= Alltrim(SubStr(cOprMin, 5, len(cOprMin)))
					cRefTrGen	:= Alltrim(SubStr(cOprMin, 1, 3))

					If (nPosTrbGen := aScan(aTribGen,{|x| AllTrim(x[TG_IT_SIGLA]) == Alltrim(cSigTrGen)})) > 0

						nVlrTGMin := RetValTrib(cRefTrGen, aNfItem, nItem, nPosTrbGen)

						IF nVlrTGMin > 0 .And. nValAtual < nVlrTGMin

							nResultado := ProcAcaoMin(aNfItem, nItem, nTrbGen, nVlrTGMin, cAcaoMin)
							lNoCabec	:= .T.
							//Ajusta o valor do tributo genérico para o limite mínimo
							Mafisalt("IT_TRIBGEN", nResultado, nItem,lNoCabec,,,,,,{aTribGen[nTrbGen][TG_IT_SIGLA],"TG_IT_VALOR"} )
						Endif

					Endif

				Endif

			Endif
		Next nTrbGen
	Endif

Return

/*/{Protheus.doc} ProcMaxAcao
	Função responsável por definir a ação a ser tomada quando o valor do tributo ultrapassa o limite máximo
	@type  Function
	@author Rafael Oliveira
	@since 15/05/2025
	@version 12.1.2410
	@param aNfItem, array, Array de itens da MATXFIS
	@param nItem, number, Item que está sendo processado
	@param nTrbGen, number, Posição do tributo genérico
	@param nVlrOpMax, number, Valor máximo do tributo
	@param cAcaoMax, string, Ação a ser tomada quando o valor do tributo ultrapassa o limite máximo
	@return nResultado, number, Retorna o resultado do tributo
	/*/
Static Function ProcMaxAcao(aNfItem, nItem, nTrbGen, nVlrOpMax, cAcaoMax)
	Local nResultado := 0

	// Verifica a ação a ser tomada quando o valor do tributo ultrapassa o limite máximo:

	// Se estiver vazio ou for igual a 1, ajusta o valor do tributo para o limite máximo
	IF Empty(cAcaoMax) .Or. cAcaoMax == "1"

		//Se não for, coloco o valor do tributo igual a zero
		nResultado := nVlrOpMax

		// Se a ação for 2, zera o valor do tributo
	Elseif cAcaoMax == "2"

		//Se não for, coloco o valor do tributo igual a zero
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO] := .T.

		// Se a ação for 3, zera o valor do tributo e marca para exclusão
	Elseif cAcaoMax == "3"

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DELETED_TRIB] := .T. //marca para exclusão

	EndIf

Return nResultado

/*/{Protheus.doc} ProcAcaoMin
	Função responsável por definir a ação a ser tomada quando o valor do tributo ultrapassa o limite mínimo
	@type  Static Function
	@author Rafael Oliveira
	@since 15/05/2025
	@version 12.1.2410
	@param aNfItem, array, Array de itens da MATXFIS
	@param nItem, number, Item que está sendo processado
	@param nTrbGen, number, Posição do tributo genérico
	@param nVlrOpMax, number, Valor máximo do tributo
	@param cAcaoMax, string, Ação a ser tomada quando o valor do tributo ultrapassa o limite máximo
	@return nResultado, number, Retorna o resultado do tributo
/*/
Static Function ProcAcaoMin(aNfItem, nItem, nTrbGen, nVlrOpMin, cAcaoMin)
	Local nResultado := 0
	// Verifica a ação a ser tomada quando o valor do tributo ultrapassa o limite mínimo:

	// Se estiver igual a 1, ajusta o valor do tributo para o limite mínimo
	IF cAcaoMin == "1"

		nResultado := nVlrOpMin

		// Se estiver vazio ou for igual a 2, zera o valor do tributo
	Elseif Empty(cAcaoMin) .Or.  cAcaoMin == "2"

		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO] := .T.

	Elseif cAcaoMin == "3"
		// Se a ação for 3, zera o valor do tributo e marca para exclusão
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DELETED_TRIB] := .T. //Remove o tributo

	Endif

Return nResultado

/*/{Protheus.doc} AddDataJson
    (Função responsável por popular o Json Statico (cache) com os códigos dos dados adicionais dos tributos genéricos)
    @type  Static Function
    @author rhuan.carvalho
    @since 24/08/2025
    @version 1.0
    @param aNfItem, array, Array do item da nota fiscal posicionado
    @return nil, nil, Não retorna valor, apenas popula o objeto estático jTribAddDat
    @example
        // Exemplo de uso:
        // AddDataJson(aNfItem[nItem])
        // Após execução, o objeto jTribAddDat estará preenchido com os códigos CJ2_ID e F20_CODIGO dos tributos genéricos
    @see SetAddRefs, QryCK3, QryCK4
*/
Static Function AddDataJson(aNfItem)
	Local jAddDataCod := Nil
	Local nTrib := 0
	Local aItTribGen := aNfItem[IT_TRIBGEN]

	jTribAddDat := JsonObject():new()

	For nTrib := 1 To Len(aItTribGen)
		jAddDataCod := JsonObject():new()
		jAddDataCod['CJ2_ID'] := aItTribGen[nTrib][TG_IT_REGRA_ESCR][1]
		jAddDataCod['F20_CODIGO'] := aItTribGen[nTrib][TG_IT_PERFOP][OP_COD]

		jTribAddDat[aNfItem[IT_TRIBGEN][nTrib][1]] := jAddDataCod
	Next nTrib

Return

/*/{Protheus.doc} QryCK3
    (Função responsável por executar a query na tabela CK3 (dados adicionais de regra de escrituração) e retornar o alias com os dados adicionais dos tributos genéricos)
    @type  Static Function
    @author rhuan.carvalho
    @since 24/08/2025
    @version 1.0
    @param tabela, character, Nome da tabela de dados adicionais (CK3)
    @return jAddData, JsonObject, Retorna um objeto JSON com os dados adicionais encontrados na CK3
    @example
        // Exemplo de uso:
        // Local jAddData := QryCK3()
        // If jAddData:hasProperty("codigo")
        //     // Processar dados adicionais
        // EndIf
    @see AddDatCods, SetAddRefs
*/
Static Function QryCK3()
	Local cAlias     := ""
	Local cQuery     := ""
	Local cSpace     := ' '
	Local nInterator := 1
	Local oPrepared  := Nil
	Local jContent   := JsonObject():new()
	Local jAddData   := JsonObject():new()

	DbSelectArea("CK3")

    cQuery := " SELECT CK3_IDCJ2 CK3IDCJ2, CK3_CODIGO CK3CODIGO ,CK3_CONTEU CK3CONTEU "
    cQuery += " FROM ? "
    cQuery += " WHERE CK3_FILIAL = ? AND CK3_IDCJ2 IN (?)"
    cQuery += " AND D_E_L_E_T_ = ?"
    cQuery += " ORDER BY CK3IDCJ2"

    oPrepared := FWExecStatement():New()
    oPrepared:SetQuery(cQuery)

    // From
    oPrepared:setUnSafe(nInterator++, RetSqlName("CK3"))

    // Where
    oPrepared:setString(nInterator++, xFilial("CK3"))
    oPrepared:setIn(nInterator++, AddDatCods("CK3")) // Pega os códigos dos dados adicionais de regra de escrituração dos tributos genéricos que estão no jTribAddDat Statico (cache)
    oPrepared:setString(nInterator++, cSpace)

    cAlias := oPrepared:OpenAlias()

	While (cAlias) -> (!EOF())
		If !jContent:hasProperty(Alltrim((cAlias)->CK3CODIGO))
			jContent[Alltrim((cAlias)->CK3CODIGO)] := AllTrim((cAlias)->CK3CONTEU)

			jAddData[AllTrim((cAlias)->CK3IDCJ2)] := jContent
		Else
			jContent := JsonObject():new()
			jContent[Alltrim((cAlias)->CK3CODIGO)] := AllTrim((cAlias)->CK3CONTEU)
			jAddData[AllTrim((cAlias)->CK3IDCJ2)] := jContent
		Endif

		(cAlias)->(DbSKip())
	EndDo

	(cAlias)->(DbCloseArea())

	FwFreeObj(oPrepared)

Return jAddData

/*/{Protheus.doc} QryCK4
    (Função responsável por executar a query na tabela CK4 (dados adicionais de perfil de operação) e retornar o alias com os dados adicionais dos tributos genéricos)
    @type  Static Function
    @author rhuan.carvalho
    @since 24/08/2025
    @version 1.0
    @param tabela, character, Nome da tabela de dados adicionais (CK4)
    @return jAddData, JsonObject, Retorna um objeto JSON com os dados adicionais encontrados na CK4
    @example
        // Exemplo de uso:
        // Local jAddData := QryCK4()
        // If jAddData:hasProperty("codigo")
        //     // Processar dados adicionais
        // EndIf
    @see AddDatCods, SetAddRefs
*/
Static Function QryCK4()
	Local cAlias     := ""
	Local cQuery     := ""
	Local cSpace     := ' '
	Local nInterator := 1
	Local oPrepared  := Nil
	Local jContent   := JsonObject():new()
	Local jAddData   := JsonObject():new()

	DbSelectArea("CK4")

    cQuery := " SELECT CK4_CODF20 CK4CODF20, CK4_CODIGO CK4CODIGO ,CK4_CONTEU CK4CONTEU "
    cQuery += " FROM ? "
    cQuery += " WHERE CK4_FILIAL = ? AND CK4_CODF20 IN (?)"
    cQuery += " AND D_E_L_E_T_ = ?"
    cQuery += " ORDER BY CK4CODF20"

    oPrepared := FWExecStatement():New()
    oPrepared:SetQuery(cQuery)

    // From
    oPrepared:setUnSafe(nInterator++, RetSqlName("CK4"))

    // Where
    oPrepared:setString(nInterator++, xFilial("CK4"))
    oPrepared:setIn(nInterator++, AddDatCods("CK4"))
    oPrepared:setString(nInterator++, cSpace)

    cAlias := oPrepared:OpenAlias()

	While (cAlias) -> (!EOF())
		If !jContent:hasProperty(Alltrim((cAlias)->CK4CODIGO))
			jContent[AllTrim((cAlias)->CK4CODIGO)] := Alltrim((cAlias)->CK4CONTEU)

			jAddData[AllTrim((cAlias)->CK4CODF20)] := jContent
		Else
			jContent := JsonObject():new()
			jContent[Alltrim((cAlias)->CK4CODIGO)] := Alltrim((cAlias)->CK4CONTEU)
			jAddData[AllTrim((cAlias)->CK4CODF20)] := jContent
		Endif

		(cAlias)->(DbSKip())
	EndDo

	(cAlias)->(DbCloseArea())

	FwFreeObj(oPrepared)

Return jAddData

/*/{Protheus.doc} AddDatCods
    (Função responsável por retornar os códigos dos dados adicionais dos tributos genéricos que estão no jTribAddDat Statico (cache))
    @type  Static Function
    @author rhuan.carvalho
    @since 25/08/2025
    @version 1.0
    @param tabela, character, Nome da tabela de dados adicionais ("CK3" ou "CK4")
    @return aContent, array, Array com os códigos dos dados adicionais dos tributos genéricos presentes no cache
    @example
        // Exemplo de uso:
        // Local aCodigos := AddDatCods("CK3")
        // // Retorna os códigos CJ2_ID dos tributos genéricos
        // Local aCodigos := AddDatCods("CK4")
        // // Retorna os códigos F20_CODIGO dos tributos genéricos
    @see QryCK3, QryCK4, SetAddRefs
*/
Static Function AddDatCods(tabela)
	Local aContent := {}
	Local aTrib    := jTribAddDat:GetNames()
	Local nI       := 0

	If tabela == "CK3"
		For nI := 1 To Len(aTrib)
			aadd(aContent, jTribAddDat[aTrib[nI]][ 'CJ2_ID' ])
		Next nI
	ElseIf tabela == "CK4"
		For nI := 1 To Len(aTrib)
			aadd(aContent, jTribAddDat[aTrib[nI]][ 'F20_CODIGO' ])
		Next nI
	Endif

Return ArrayUnique(aContent) // Remove valores duplicados

/*/{Protheus.doc} ArrayUnique
    (Função responsável por remover valores duplicados de um array)
    @type  Function
    @author rhuan.carvalho
    @since 25/08/2025
    @version 1.0
    @param aArray, array, Array que terá os valores duplicados removidos
    @return aRet, array, Array sem valores duplicados
    @example
        // Exemplo de uso:
        // Local aOriginal := {"A", "B", "A", "C", "B"}
        // Local aUnicos := ArrayUnique(aOriginal)
        // // aUnicos = {"A", "B", "C"}
    @see AddDatCods
*/
Function ArrayUnique(aArray)
    Local aRet   := {}
    Local nI     := 0
    Local nJ     := 0
    Local lFound := .F.

    For nI := 1 To Len(aArray)
        lFound := .F.
        For nJ := 1 To Len(aRet)
            If aRet[nJ] == aArray[nI]
                lFound := .T.
                Exit
            EndIf
        Next nJ
        If !lFound
            aAdd(aRet, aArray[nI])
        EndIf
    Next nI
Return aRet

/*/{Protheus.doc} SetAddRefs
    (Função responsável por popular as referências dos dados adicionais dos tributos genéricos no aNfItem)
    @type  Static Function
    @author rhuan.carvalho
    @since 25/08/2025
    @version 1.0
    @param aNfItem, array, Array do item da nota fiscal posicionado
    @param jAddData, JsonObject, Objeto JSON com os dados adicionais dos tributos genéricos
    @return nil, nil, Não retorna valor, apenas atualiza as referências dos dados adicionais no aNfItem
    @example
        // Exemplo de uso:
        // SetAddRefs(aNfItem[nItem], QryCK3())
        // SetAddRefs(aNfItem[nItem], QryCK4())
        // Após execução, os campos de dados adicionais estarão preenchidos nas referências do tributo genérico
    @see AddDataJson, QryCK3, QryCK4
*/
Static Function SetAddRefs(aNfItem, jAddData)
	Local aTribGen    := jTribAddDat:GetNames()
	Local nTrib       := 0
	Local cCJ2_ID     := ""
	Local cF20_CODIGO := ""

    For nTrib := 1 To Len(aTribGen)
        cCJ2_ID     := jTribAddDat[aTribGen[nTrib]]["CJ2_ID"]
        cF20_CODIGO := jTribAddDat[aTribGen[nTrib]]["F20_CODIGO"]

        // Dados adicionais de regra de escrituração (CK3)
        If !Empty(cCJ2_ID) .And. jAddData:hasProperty(cCJ2_ID)
			If jAddData[cCJ2_ID]:hasProperty("MOTDESICMS")
            aNfItem[IT_TRIBGEN][nTrib][TG_IT_REGRA_ESCR][RE_DADO_ADICIONAL][MOTDESICMS] := jAddData[cCJ2_ID]["MOTDESICMS"]
			EndIf
			If jAddData[cCJ2_ID]:hasProperty("DESCICMS")
				aNfItem[IT_TRIBGEN][nTrib][TG_IT_REGRA_ESCR][RE_DADO_ADICIONAL][DESCICMS]   := jAddData[cCJ2_ID]["DESCICMS"]
			EndIf
			If jAddData[cCJ2_ID]:hasProperty("AJUPISCOF")
				aNfItem[IT_TRIBGEN][nTrib][TG_IT_REGRA_ESCR][RE_DADO_ADICIONAL][AJUPISCOF]   := jAddData[cCJ2_ID]["AJUPISCOF"]
			EndIf
        EndIf

        // Dados adicionais de perfil de operação (CK4)
        If !Empty(cF20_CODIGO) .And. jAddData:hasProperty(cF20_CODIGO)
			If jAddData[cF20_CODIGO]:hasProperty("ICMSSTNFSA")
			   	aNfItem[IT_TRIBGEN][nTrib][TG_IT_PERFOP][OP_DADO_ADICIONAL][ICMSSTNFSA] := jAddData[cF20_CODIGO]["ICMSSTNFSA"]
			EndIf
			If jAddData[cF20_CODIGO]:hasProperty("INDNATFRET")
            	aNfItem[IT_TRIBGEN][nTrib][TG_IT_PERFOP][OP_DADO_ADICIONAL][INDNATFRET] := jAddData[cF20_CODIGO]["INDNATFRET"]
			EndIf
			If jAddData[cF20_CODIGO]:hasProperty("REGIMESPEC")
            	aNfItem[IT_TRIBGEN][nTrib][TG_IT_PERFOP][OP_DADO_ADICIONAL][REGIMESPEC] := jAddData[cF20_CODIGO]["REGIMESPEC"]
			EndIf
        EndIf
    Next nTrib

	aSize(aTribGen, 0)
Return

/*/{Protheus.doc} FtMaFisTG
	Funcao responsavel por verificar se existe registro na SFT para tomar decisao se
	de fato devemnos excluir as tabelas F2D e CJ3
	@type  Static Function
	@author Ricrado Henrique de Mello Lima
	@since 29/08/2025
	@version 12.1.2410
	@param cIdTrbGen , character , id do tributo na F2D
	@return aDadosFT, array = 1 FT_IDTRIB, 2 FT_OBSERV
/*/
Static Function FtMaFisTG(cIdTrbGen as character)

	Local oQuerySFT := nil as object
	Local cQuerySFT := "" as character
	Local cDelete := " " as character
	Local cIdSFT := "" as character

	default cIdTrbGen := ""

	cQuerySFT := " SELECT "
	cQuerySFT += " 	SFT.FT_IDTRIB"
	cQuerySFT += " FROM "
	cQuerySFT += "    "+RetSqlName("SFT")+" SFT"
	cQuerySFT += " WHERE "
	cQuerySFT += "    SFT.FT_FILIAL = ?"
	cQuerySFT += "    AND SFT.FT_IDTRIB = ?"
	cQuerySFT += "    AND SFT.D_E_L_E_T_ = ?"

	oQuerySFT := FWExecStatement():New()
	oQuerySFT:SetQuery(cQuerySFT)
	oQuerySFT:SetString(1,FWXFilial("SFT"))
	oQuerySFT:SetString(2,cIdTrbGen)
	oQuerySFT:SetString(3,cDelete)

	cIdSFT := oQuerySFT:ExecScalar("FT_IDTRIB")

	oQuerySFT:Destroy()
	FreeObj(oQuerySFT)

Return cIdSFT

/*/{Protheus.doc} qryExNcm()
    Faz a condicao da query do QryTribGen para o Ex-tarifario que esta na Regra de NCM
	@param 		cNameAlias, character, alias da tabela na QryTribGen
	@param 		cExNcm, character, codigo do ex-tarifario (CIU_EX_NCM)
	@param 		aInsert, array, bind do objeto da query
	@return		cWhere, character, where da query relacionado ao ex-tarifario
	@type		Static Function
	@author 	Matheus Bispo
    @since 		26/08/2025
    @version 	12.1.2510
/*/
Static Function qryExNcm(cNameAlias, aInsert, cExNcm)
	Local cWhere := "AND (" +cNameAlias+ "CIU_EX_NCM = ? OR " +cNameAlias+ "CIU_EX_NCM = ?) "

	if !empty(cExNcm)
		Aadd(aInsert, {'C', cExNcm})
		Aadd(aInsert, {'C', " "})
	else
		Aadd(aInsert, {'C', " "})
		Aadd(aInsert, {'C', "**"})
	endIf

Return cWhere

/*/{Protheus.doc} TaxOpJson
Função responsável por processar o recebimento dos tributos através do execauto.
Percorre um array de itens buscando dados de tributos em formato JSON e os
processa através da classe TaxOperandIntegrator.

@type  Function
@author rhuan.carvalho
@since 14/10/2025
@version 12.1.2410
@param ArrayItens, array, Array multidimensional contendo itens com dados fiscais.
       Cada item pode conter subitens onde o primeiro elemento é "TRIBUTOS"
       e o segundo elemento é um objeto JSON com os dados do tributo.
@return lRet, boolean, boleano que indica sucesso (.T.) ou falha (.F.) no processamento
        pelo TaxOperandIntegrator, ou vazio se não encontrar tributos válidos.
@example
    Local aItens := {}
    Local cResultado := ""

    // Exemplo de estrutura esperada do array
    aItens := {;
        {;
            {"'...'", "..."},;
            {"TRIBUTOS", jTributoJSON};
        };
    }

    cResultado := TaxOpJson(aItens)
@see TaxOperandIntegrator, ProcessItemTaxJson
/*/
Function TaxOpJson(ArrayItens)
	Local nLin       := 0
	Local nx         := 0
	Local jTrib      := Nil
	Local oProcess   := Nil
	Local oRetorno   := Nil
	Local lFindClass := FindClass("totvs.protheus.backoffice.fiscal.taxoperandintegrator.TaxOperandIntegrator")
	Local lRet       := .F.
	Local cRet       := ""
	Local cMsg	 := ""

	If lFindClass
		oProcess := totvs.protheus.backoffice.fiscal.taxoperandintegrator.TaxOperandIntegrator():New()
		For nLin := 1 To Len(ArrayItens)

			For nX := 1 To Len(ArrayItens[nLin])
				If ArrayItens[nLin][nX][1] == "TRIBUTOS" .and. valtype(ArrayItens[nLin][nX][2]) == "J"
					jTrib                   := JsonObject():New()
					jTrib[cValToChar(nLin)] := ArrayItens[nLin][nX][2]
					cRet                    := oProcess:ProcessItemTaxJson(jTrib)
					FwFreeObj(jTrib)
					oRetorno := JsonObject():New()
					oRetorno:FromJson(cRet)
					If oRetorno:hasProperty("warning")
						cMsg := oRetorno["warning"]
						FWLogMsg("WARN", /*cTransactionId*/, "InfoClass", /*cCategory*/, /*cStep*/, /*cMsgId*/, cMsg, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
						FreeObj(oRetorno)
						FwFreeObj(oProcess)
						return lRet
					EndIf
				EndIf
			Next nX

		Next nLin
		If !oRetorno == Nil
			cMsg := oRetorno["success"]
			FWLogMsg("INFO", /*cTransactionId*/, "InfoClass", /*cCategory*/, /*cStep*/, /*cMsgId*/, cMsg, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)
			lRet := .T.
			FreeObj(oRetorno)
		EndIf
		FwFreeObj(oProcess)
	EndIf

Return lRet

/*/{Protheus.doc} IncOpIntgr
    Função responsável por ajustar a incidência tributária baseada nos valores de escrituração
    do livro fiscal quando o tipo de incidência é "8" (automático baseado em valores) e
    o tributo está sendo carregado de dados já gravados. A função analisa os valores de
    tributado, isento e outros para determinar automaticamente qual deve ser a incidência
    correta do tributo genérico.

    @type  Function
    @author rhuan.carvalho
    @since 05/11/2025
    @version 12.1.2410
    @param aNfItem, array, Array com informações dos itens da nota fiscal
    @param nItem, numeric, Número do item da nota fiscal sendo processado
    @param nPosTrb, numeric, Posição do tributo genérico no array IT_TRIBGEN
    @return cIncOp, character, Código da incidência ajustada ("1" a "7") baseada nos valores encontrados
    @example
        Local cIncidencia := ""
        cIncidencia := IncOpIntgr(aNfItem, 1, 1)
        // Retorna: "1" = Tributado, "2" = Isento, "3" = Outros, "4" = Tributado+Isento,
        //          "5" = Tributado+Outros, "6" = Isento+Outros, "7" = Todos
    @see FisLivroTG, FisLoadTG
/*/
Function IncOpIntgr(aNfItem, nItem, nPosTrb)
	Local cIncOp     := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_INCIDE]
	Local lLoad      := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LOAD]
	Local cCst       := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LF][TG_LF_CST]
	Local cCstCab    := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LF][TG_LF_CSTCAB]
	Local cCct       := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LF][TG_LF_CCT]
	Local nTributado := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LF][TG_LF_VALTRIB]
	Local nIsento    := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LF][TG_LF_ISENTO]
	Local nOutros    := aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_LF][TG_LF_OUTROS]
	Local nSumEsc    := 0

	If cIncOp == "8" .and. lLoad

		If nTributado > 0
			nSumEsc += 1
		endIf
		If nIsento > 0
			nSumEsc += 2
		Endif
		If nOutros > 0
			nSumEsc += 4
		Endif

		Do Case
		Case nSumEsc == 7  // todos os três
			cIncOp := "7"
		Case nSumEsc == 6  // isento + outros
			cIncOp := "6"
		Case nSumEsc == 5  // tributado + outros
			cIncOp := "5"
		Case nSumEsc == 3  // tributado + isento
			cIncOp := "4"
		Case nSumEsc == 4  // apenas outros
			cIncOp := "3"
		Case nSumEsc == 2  // apenas isento
			cIncOp := "2"
		Case nSumEsc == 1  // apenas tributado
			cIncOp := "1"
		EndCase
		// Atualiza o valor do campo RE_INCIDE, RE_CST, RE_CSTCAB e RE_CCT para a escrituração dos livros seguir de acordo com o histórico
		If !Empty(cIncOp)
			aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_INCIDE]     := cIncOp
			aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_CST]        := cCst
			aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_CSTCAB]     := cCstCab
			aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ESCR][RE_CCT]        := cCct

			// Habilito a flag de Operando de integração na alíquota por conta de ter sido incidencia = 8
			aNfItem[nItem][IT_TRIBGEN][nPosTrb][TG_IT_REGRA_ALQ][TG_ALQ_OPINTEG] := .T.
		EndIf

	EndIf

return

/*/{Protheus.doc} ReprIntegr
    Função responsável por verificar se o tributo genérico está em modo de reprocessamento
    com operando de integração. A função valida se o tributo possui fórmula de valor com
    operando de integração (O:VALOR_INTEGRACAO) e se está sendo carregado de dados já
    gravados, indicando que não deve reprocessar as referências do livro fiscal para
    evitar sobrescrever valores já integrados.

    @type  Static Function
    @author rhuan.carvalho
    @since 10/11/2025
    @version 12.1.2410
    @param aNfItem, array, Array com informações dos itens da nota fiscal
    @param nItem, numeric, Número do item da nota fiscal sendo processado
    @param nTrbGen, numeric, Posição do tributo genérico no array IT_TRIBGEN
    @return lIntegr, logical, .T. se está em modo de reprocessamento com integração, .F. caso contrário
    @example
        Local lSubscreve := ReprIntegr(aNfItem, 1, 1, .T.)
        If lSubscreve
            // Não reprocessar referências do livro - manter valores integrados
        Else
            // Subescrever normalmente as referências do livro
        EndIf
    @see FisLivroTG, IncOpIntgr, xFisExecNPI
/*/
Static Function ReprIntegr(aNfItem, nItem, nTrbGen)
	Local cFormul   := AllTrim(aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_FOR_NPI])
	Local lOpIntAli := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_OPINTEG]
	Local lLoad     := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_LOAD]
	Local lIntegr   := .F.

	If lLoad .and. lOpIntAli .and. !Empty(cFormul) .and. "O:VALOR_INTEGRACAO" $ cFormul
		lIntegr := .T.
	EndIf

Return lIntegr


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckCINStamp

Função que verifica a existência do campo S_T_A_M_P_ na tabela CIN
e retorna o valor máximo do timestamp por parâmetro de referência.

Utiliza Mafiscache para verificar existência do campo apenas uma vez,
evitando múltiplas chamadas ao FWSX3Util.

@param cStampValue - Parâmetro por referência que receberá o valor do MAX(S_T_A_M_P_)
@return Logical - .T. se campo existe E possui valor preenchido, .F. caso contrário

@author Rafael Oliveira
@since 05/01/2026
@version 12.1.2510
/*/
//-------------------------------------------------------------------

/*Static Function CheckCINStamp(cStampValue)
	Local lFieldExists := .F.
	Local oStmt        := Nil
	Local cQuery       := ""
	Local cMaxStamp    := ""

	// Inicializa parâmetro de saída
	cStampValue := ""

	// Verifica existência do campo usando cache (executa apenas 1 vez por empresa/filial)
	lFieldExists := Mafiscache("CIN_STAMP_EXISTS",, {|| FWSX3Util():SeekX3File("S_T_A_M_P_")}, .T.)

	// Se campo não existe, retorna .F.
	If !lFieldExists
		Return .F.
	EndIf

	// Campo existe - busca valor máximo do S_T_A_M_P_
	cQuery := "SELECT MAX(S_T_A_M_P_) AS MAX_STAMP "
	cQuery += "FROM " + RetSqlName("CIN") + " CIN "
	cQuery += "WHERE CIN.CIN_FILIAL = ? "
	cQuery += "  AND CIN.D_E_L_E_T_ = ' '"

	oStmt := FWExecStatement():New(cQuery)
	oStmt:SetString(1, Mafiscache("CIN_STAMP_EXISTS",, {|| xFilial("CIN")}, .T.))

	// Executa scalar para obter valor único
	cMaxStamp := oStmt:ExecScalar("MAX_STAMP")

	// Libera recursos
	oStmt:Destroy()
	FreeObj(oStmt)
	oStmt := Nil

	// Se retornou NULL ou vazio, campo existe mas não tem dados
	If Empty(cMaxStamp)
		Return .F.
	EndIf

	// Preenche parâmetro de saída e retorna sucesso
	cStampValue := AllTrim(cMaxStamp)

Return .T.
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} InitCacheCIN

Função que inicializa o cache da tabela CIN, fazendo pré-carga dos 
operandos (CIN_TREGRA = '0 ') e índices (CIN_TREGRA = '9 ').
Utiliza JsonObject para armazenar o cache em memória.

Como os opérandos devem ser simples, vou ler apenas o campo CIN_FNPI (VARCHAR), evitando
leitura do campo MEMO (CIN_FNPI_M) que é mais custoso e neste caso não é necessário.

Controla contexto de empresa/filial e timestamp (S_T_A_M_P_) para invalidação automática
do cache quando houver mudança.

@return Logical - .T. se inicializado com sucesso

@author Rafael Oliveira
@since 23/12/2025
@version 12.1.2510
/*/
//-------------------------------------------------------------------
Static Function InitCacheCIN()
	Local cAliasQry   := ""
	Local lRet        := .T.
	Local cFormula    := ""
	Local cCodigo     := ""
	Local oStmt       := Nil
	Local cQuery      := ""

	// Inicializa o JsonObject para armazenar cache de fórmulas CIN
	jCacheCIN := JsonObject():New()

	// Monto a query para pré-carga dos operandos e índices
	cQuery := "SELECT CIN_CODIGO, CIN_FNPI "
	cQuery += "FROM " + RetSqlName("CIN") + " CIN "
	cQuery += "WHERE "
	cQuery += "    CIN.CIN_FILIAL = ? "
	cQuery += "    AND CIN.CIN_TREGRA IN ( '0', '9' ) "
	cQuery += "    AND CIN.CIN_ALTERA = ? "
	cQuery += "    AND CIN.D_E_L_E_T_ = ? "
	cQuery += "ORDER BY CIN_CODIGO"

	// Crio o prepared statement
	oStmt := FWExecStatement():New(cQuery)
	oStmt:SetString(1, xFilial("CIN"))
	oStmt:SetString(2, '0')
	oStmt:SetString(3, ' ')

	// Executo a query
	cAliasQry := oStmt:OpenAlias()

	// Populo o cache (SEM prefixo empresa/filial na chave)
	While !(cAliasQry)->(Eof())
		cCodigo  := AllTrim((cAliasQry)->CIN_CODIGO)
		cFormula := (cAliasQry)->CIN_FNPI

		// Adiciono no cache
		jCacheCIN[cCodigo] := Alltrim(cFormula)

		(cAliasQry)->(DbSkip())
	EndDo

	// Fecho o alias
	(cAliasQry)->(DbCloseArea())

	// Libero o objeto do statement
	oStmt:Destroy()
	FreeObj(oStmt)
	oStmt := Nil

Return lRet

/*
{Protheus.doc} PosTabAdic
Função responsável por localizar a posição correta na tabela adicional progressiva
de acordo com o valor de referência informado.
@author douglas.dourado
@param cOperando, character, Código do operando da tabela progressiva
@param nValorRef, numeric, Valor de referência para localizar a faixa correta na tabela
@return aRet, array, Array com dois elementos: {Fator, Dedução} encontrados na tabela adicional progressiva
@since 12/01/2026
@version 12.1.2510
*/
Static Function PosTabAdic(cOperando, nValorRef)

	Local nPos 			:= AScan(aTabProg, { |x| Alltrim(x[1]) == Alltrim(cOperando)})
	Local nX   			:= 0
	Local nPosValIni	:= 1
	Local nPosValFim	:= 2
	Local nPosFator		:= 3
	Local nPosDeduc		:= 4

	//Verifico se a tabela progressiva está no cache, e se a tabela adicional tem valores preenchidos (aTabAdic)
	If nPos > 0 .and. !Empty(aTabAdic)
		For nX := 1 To Len(aTabAdic)
			//Verifico se valor da base de cálculo está contida na faixa entre os valores mínimo e máximo
			If nValorRef >= aTabAdic[nX][nPosValIni] .And. nValorRef <= aTabAdic[nX][nPosValFim]
				Return {aTabAdic[nX][nPosFator], aTabAdic[nX][nPosDeduc]}
			EndIF
		Next nX
	EndIf

Return {0,0} //Retornarei zero caso não enquadre na tabela.


/*
{Protheus.doc} DefBaseAux
Função responsável por definir a base de cálculo auxiliar do tributo genérico
@param aNfItem, array, Array com informações dos itens da nota fiscal
@param nItem, numeric, Número do item da nota fiscal que está sendo processado
@param nTrbGen, numeric, Posição do tributo genérico no array IT_TRIBGEN
@author Juliano Fernandes
@since 20/01/2026
@version 12.1.2510
*/
Static Function DefBaseAux(aNfItem, nItem, nTrbGen)

	Local cId 		:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ID]
	Local cCod 		:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_COD]
	Local cVlOri 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_VLORI]
	Local cDescon 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_DESCON]
	Local cFrete 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FRETE]
	Local cSeguro 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_SEGURO]
	Local cDesp 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_DESP]
	Local cIcmsDes	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ICMSDES]
	Local cIcmsSt 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ICMSST]
	Local nReducao 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_REDUCAO]
	Local cTpRed 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_TPRED]
	Local cUm 		:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_UM]

	Local cForNpi 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FOR_NPI]
	Local cIdNpi 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_ID_NPI]
	Local cCodFor 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_COD_FOR]
	Local cFormula 	:= aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_AUX_FORMULA]

	Local nDedSimp 	:= 0

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID]		 := cId
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD]	 := cCod
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_VLORI]	 := cVlOri
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESCON]	 := cDescon
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FRETE]	 := cFrete
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_SEGURO]	 := cSeguro
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_DESP]	 := cDesp
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSDES] := cIcmsDes
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ICMSST]	 := cIcmsSt
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_REDUCAO] := nReducao
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_TPRED]	 := cTpRed
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_UM]		 := cUm

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FOR_NPI] := cForNpi
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_ID_NPI]  := cIdNpi
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_COD_FOR] := cCodFor
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_FORMULA] := cFormula
	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_BAS][TG_BAS_OPINTEG] := ( PVALORI + "BASE_INTEGRACAO" $ cForNpi )

	If ( PINDCALC + "DED_SIMPL" $ cForNpi )
		nDedSimp := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_SIM_CAD]
	EndIf

	aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DED_SIM_VAL] := nDedSimp

Return

/*/{Protheus.doc} FisSE2Acum
(Função responsável por retornar o valor acumulado em titulos de um fornecedor/cliente em uma determinado periodo.
@author Douglas Dourado
@since 06/02/2026
@version 12.1.2510

@param:	
cFil - Código da filial de processamento, sempre a filial completa
cFornece - Código do fornecedor/cliente
cLoja - Código da loja
dRef - Data de referência do processamento
cCarteira - Código da carteira
cFatoGerador - Fato gerador do tributo, 1 = Emissão, 2 = Caixa
cTpRet - Tipo de retorno solicitado: "BASE" para base de cálculo ou "VALOR" para valor do tributo
cTrib - Sigla do tributo gerado na FK4, Ex: INSS, ISS, IRF
dIni - Data inicial para filtro/seleção dos movimentos do imposto gerado
dFim - Data final para filtro/seleção dos movimentos do imposto gerado
lIRMensal - Indicador se o cálculo é para IR mensal via tabela progressiva (.T. ou .F.)

@return   nRet  - Retorna o valor acumulado conforme o tipo solicitado

/*/
Function FisSE2Acum( cFil , cFornece , cLoja , dRef , cCarteira , cFatoGerador , cTpRet , cTrib,  dIni , dFim , lIRMensal, cCodRegraFin)
	Local nRet := 0
	Local lCache := .F.
	Local jRetorno

	If !fisFindFunc("TribByForn")
		Return nRet
	EndIf

	// Valida se pode usar cache comparando os atributos
	If oSE2Fin:HasProperty("tituloSE2")
		If oSE2Fin["tituloSE2"]["filialOrigem"] == cFil .And. ;
		   oSE2Fin["tituloSE2"]["clieforn"] == cFornece .And. ;
		   oSE2Fin["tituloSE2"]["loja"] == cLoja .And. ;
		   oSE2Fin["tituloSE2"]["dataRef"] == dRef .And. ;
		   oSE2Fin["tituloSE2"]["carteira"] == cCarteira .And. ;
		   oSE2Fin["tituloSE2"]["fatoGerador"] == cFatoGerador .And. ;
		   oSE2Fin["tituloSE2"]["tributo"] == cTrib .And. ;
		   oSE2Fin["tituloSE2"]["irpfMensal"] == lIRMensal .And. ;
		   oSE2Fin["tituloSE2"]["dataInicial"] == dIni .And. ;
		   oSE2Fin["tituloSE2"]["dataFinal"] == dFim .And. ;
		   oSE2Fin:HasProperty("jRetorno")
			// Pode usar cache
			lCache := .T.
		EndIf
	EndIf

	// Se não pode usar cache, executa a TribByForn() do Financeiro ...
	If !lCache
		oSE2Fin["tituloSE2"] := JsonObject():New()     
		oSE2Fin["tituloSE2"]["filialOrigem"] := cFil
		oSE2Fin["tituloSE2"]["clieforn"]     := cFornece
		oSE2Fin["tituloSE2"]["loja"]         := cLoja
		oSE2Fin["tituloSE2"]["dataRef"]      := dRef
		oSE2Fin["tituloSE2"]["carteira"]     := cCarteira
		oSE2Fin["tituloSE2"]["fatoGerador"]  := cFatoGerador
		oSE2Fin["tituloSE2"]["tributo"]      := cTrib
		oSE2Fin["tituloSE2"]["irpfMensal"]   := lIRMensal	
		oSE2Fin["tituloSE2"]["dataInicial"]  := dIni
		oSE2Fin["tituloSE2"]["dataFinal"]    := dFim
		oSE2Fin["tituloSE2"]["operacao"]     := 3
		oSE2Fin["tituloSE2"]["codRegraFin"]  := cCodRegraFin

		jRetorno := TribByForn(oSE2Fin)

		// Armazena o retorno no cache
		If Valtype(jRetorno) == "J" .And. jRetorno:HasProperty("baseTributo") .And. jRetorno:HasProperty("valorTributo")
			oSE2Fin["jRetorno"] := jRetorno
		EndIf
	Else
		// Usa o retorno do cache
		If oSE2Fin:HasProperty("jRetorno")
			jRetorno := oSE2Fin["jRetorno"]
		EndIf
	EndIf

	// Processa o retorno
	If Valtype(jRetorno) == "J"
		If cTpRet == "BASE"
			If jRetorno:HasProperty("baseTributo")
				nRet := jRetorno["baseTributo"]
			EndIf
		ElseIf cTpRet == "VALOR"
			If jRetorno:HasProperty("valorTributo")
				nRet := jRetorno["valorTributo"]
			EndIf
		EndIf
	EndIf

Return nRet


/*/{Protheus.doc} FisTotRefTrb

	FisTotRefTrb -> Totaliza referência por tributo

	Esta função tem como objetivo retornar os valores acumulados de base ou valor
	de um tributo genérico desconsiderando o item da nota fiscal que está sendo
	processado no momento.

	Ela garante que o retorno será apenas dos tributos genéricos calculados sem
	retornar valores de tributos calculados pelo legado.

	Exemplo: supondo que está sendo lançada uma nota fiscal e já dois itens foram
	inseridos, quando o usuário inserir o terceiro item serão totalizados os valores
	do tributo dos itens anteriores.

	@type  Function
	@author anedino.santos / douglas.dourado
	@since 30/01/2026
	@version 12.1.2510
	@param aNFItem, array, matriz com os dados dos itens da nota fiscal carregados pela MATXFIS
	@param cIdTOTVS, character, identificador que determina um tributo "real". Uma regra do configurador de tributos pode ter um tributo "real" ou não.
	@param nItemAtual, numeric, item da nota fiscal que está sendo processado no momento
	@param nRef, numeric, referência a ser considerada na somatória de valores dos itens. Valores aceitos: TG_IT_BASE e TG_IT_VALOR

	@return nRet, numeric, valor total da referência conforme os itens da nota fiscal exceto o item que está sendo processado.
	@example
		nRet := FisTotRefTrb( aNfItem, "000019" , 1, TG_IT_VALOR ) // retorna o valor total de INSS calculado até o momento para os itens anteriores
/*/
Function FisTotRefTrb( aNfItem, cIdTOTVS , nItemAtual, nRef )
    Local nTotalRef   	:= 0
    Local nItem  		:= 0
	Local nPosTributo   := 0
	Local nTotalItens 	:= Len(aNfItem)

	// Se só há 1 item, não há outros para somar
	If nTotalItens <= 1
		Return nTotalRef
	Endif

	For nItem := 1 to nTotalItens
		// Pula item atual e itens deletados
		If nItem == nItemAtual .Or. aNfItem[nItem][IT_DELETED] .or. Len(aNfItem[nItem][IT_TRIBGEN]) == 0
			Loop
		EndIf
	
		// Busca o tributo específico
		nPosTributo := aScan( aNfItem[nItem][IT_TRIBGEN], {|x| AllTrim(x[TG_IT_IDTRIB]) == cIdTOTVS } )
		// Totaliza referência
		If nPosTributo > 0
			nTotalRef += aNfItem[nItem][IT_TRIBGEN][nPosTributo][nRef]
		EndIf
	Next nItem

Return nTotalRef


/*/{Protheus.doc} FisPropRefTrib -> proporcional da referência do tributo

	Calcula o percetual de proporção do valor de TG_IT_VALOR ou de TG_IT_BASE do
	tributo conforme os itens da nota fiscal.

	@type  Function
	@author douglas.dourado / anedino.santos
	@since 16/01/2026
	@version 12.1.2510
	@param aNfItem, array, Array com informações dos itens da nota fiscal
	@param nItem, numeric, Número do item da nota fiscal que está sendo processado
	@return nPerc, numeric, Percentual do rendimento tributável do item em relação ao total do rendimento tributável dos outros itens
/*/
Function FisPropRefTrib( aNfItem, nItem, cIdTOTVS, nRefencia )
	Local nPerc := 1.0
	Local nValTotal := 0
	Local nValItem := 0
	Local nPos := 0

	default cIdTOTVS := ""

	nValTotal := FisTotRefTrb( aNfItem, cIdTOTVS , nItem, nRefencia )

	If (nPos := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| AllTrim(x[TG_IT_IDTRIB]) == cIdTOTVS })) > 0
		nValItem  := aNfItem[nItem][IT_TRIBGEN][nPos][nRefencia]
	EndIf

	If nValTotal > 0 .and. nValItem > 0
		nPerc := ( nValItem / ( nValTotal + nValItem ) )
	EndIf

Return nPerc


/*/{Protheus.doc} FisRendTrb -> Fiscal Rendimento Tributável

	Retorna o rendimento tributável da nota fiscal.
	Essa função a princípio irá verificar se há no array NF_TRIBGEN o tributo
	RENDME e retornará seu valor calculado. Portanto é preciso que a matxfis esteja
	devidamente inicializada e em processamento para obter o retorno.

	O conceito de rendimento tributável está ligado principalmente com o IRRF
	autônomo pois se trata do valor a ser considerado na base de cálculo sem
	as deduções comuns ao IRRF (dedução simplificada ou deduções legais)

	@TODO: quando houver uma outra forma de retornar o rendimento tributável essa
	função deverá ser atualizada para buscar corretamente o valor.

	@type  Function
	@author anedino.santos
	@since 04/02/2026
	@version 12.1.2510

	@return nRendTrib, numeric, valor do rendimento tributável da nota fiscal
/*/
Function FisRendTrb()
	Local aNFTribGen := MaFisRet(,"NF_TRIBGEN")
	Local nRendTrib := 0
	Local nPos := 0

	if (nPos := aScan( aNFTribGen, { |aTrib| AllTrim( aTrib[TG_NF_IDTRIB]) == TRIB_ID_RENDTRIB} ) ) > 0
		nRendTrib := aNFTribGen[nPos][TG_NF_VALOR]
	endif

	FwFreeArray(aNFTribGen)

Return nRendTrib

/*/{Protheus.doc} ReloadRendTribCache -> Recarrega cache do rendimento tributável
	
	Recarrega o cache do rendimento tributável, forçando nova consulta ao financeiro
	na próxima chamada da função FisSE2Acum().

	@author douglas.dourado
	@since 09/02/2026
	@version 12.1.2510

*/
Function ReloadRendTribCache()
	FwFreeObj(oSE2Fin)
	oSE2Fin := JsonObject():New()
Return
/*/{Protheus.doc} InitJMap
	Funcao responsavel por inicializar o jMapProc que ira armazenar os processos ja verificados
	para nao precisar ficar buscando na base de dados toda hora.
	@type  Static Function
	@author Rafael Oliveira
	@since 20/01/2026
	@version 12.1.2510	
	@return .T.	
/*/
Static Function InitJMap()	

	If ValType(jMapProc) == "J"
		FwFreeObj(jMapProc)
		jMapProc := Nil
	EndIf

	jMapProc := JsonObject():New()
Return .T.

/*/{Protheus.doc} FisDevEnqIBSCBS
		
	Essa Funcao tem como objetivo fazer o enquadramento na operacao de devolucao de compras, apenas dos triubutos Tributo IBS / CBS - Isento 
	
	Conforme Regra UB12-10 que permite a omissão do grupo de IBS/CBS. 
	Caso esse grupo seja informado, devem ser utilizados o CST 410 e a cClassTrib 410031, com valores de IBS e CBS iguais a zero.
	
	"Conclui-se então que a legislação e a Nota Técnica 2025.002-RTC oferecem um tratamento claro para o período de transição. 
	A regra UB12-10 protege o contribuinte ao permitir que devoluções, em 2026, de operações realizadas em 2025 sejam emitidas sem a obrigatoriedade de informar IBS e CBS. 
	Alternativamente, quando houver a necessidade de preenchimento, o uso do cClassTrib 410031, com valores zerados e CST 410, 
	garante a correta caracterização da não incidência, preservando o princípio do espelhamento tributário e evitando impactos indevidos no novo sistema de tributos."
	Parecer Consultoria de Seguimentos
	https://tdn.totvs.com/pages/releaseview.action?pageId=1027812024

	*** IMPORTANTE ***

	Não é o Ideal termos implementações no configurador de tributos fazendo filtros dentro dó código (cClassTrib) 
	Hoje cClassTrib não é parametro de filtro no Motor de Calculo caso tenhamos mais casos como este, antes da implementação
	devemos discutir como time se vamos fazer a implementacao da regra ou vamos voltar a discussão de trazer o cClassTrib
	para parametro de filtro no Configurador de Tributos e ou outra metodologia que atenda as exigencias técnicas e 
	matenha o configurador de tributos 100% configuravel sem que tenha regras de negocios implementadas no código que o motor fiscal
	não trate como filtro.

	@type  Static Function
	@author Ricardo Henrique de Mello Lima
	@since 30/01/2026
	@version 102.1.2510
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
		Uma empresa adquiriu mercadorias em dezembro de 2025 e realizou a devolução em janeiro de 2026. 
		A nota fiscal de origem, emitida em 15/12/2025, foi registrada no regime anterior à Reforma Tributária, 
		com valor do produto de R$ 5.000,00, destaque de ICMS de 18% (R$ 900,00) e sem incidência de IBS ou CBS.
	(examples)
	@see (links_or_references)
	https://tdn.totvs.com/pages/releaseview.action?pageId=1027812024

/*/
Static Function FisDevEnqIBSCBS(aNfCab, aNfItem, nItem, aPos, aDic, cCampo,nTGITRef, jMapForm, aDepVlOrig, aFunc)

	Local nTrbGen	:= 0
	Local cCodProd	  := aNfItem[nItem][IT_PRODUTO]
	Local cPart		  := aNfCab[NF_CODCLIFOR]
	Local cLoja		  := aNfCab[NF_LOJA]
	Local cTipoPart	  := Iif( aNfCab[NF_CLIFOR] == "C", "2" , "1" )
	Local cOrigProd	  := SubStr( aNfItem[nItem][IT_CLASFIS] , 1 , 1 )
	Local cUfOrigem	  := aNFCab[NF_UFORIGEM] as character
	Local cUfDestino  := aNfCab[NF_UFDEST] as character
	Local cCfop		  := aNfItem[nItem][IT_CF] as character
	Local cTpOper	  := aNfItem[nItem][IT_TPOPER] as character
	Local cNcm 		  := aNfItem[nItem][IT_POSIPI] as character
	Local c1UM 		  := aNfItem[nItem][IT_B1UM] as character
	Local c2UM 		  := aNfItem[nItem][IT_B1SEGUM] as character
	Local cCodIss	  := aNfItem[nItem][IT_CODISS] as character
	Local cCodCest	  := aNfItem[nItem][IT_CEST] as character
	Local cExNcm	  := aNfItem[nItem][IT_PRD][SB_EX_NCM] as character	
	Local jTaxOper 	  := JsonObject():New() as json
	Local jVldTribs	  := JsonObject():New() as json
	Local cUfServ	  := "" as character
	Local cMunServ	  := "" as character
	Local cAliasQry   := "" as character
	Local cClasTrib	  := "410031"

	Default jMapForm	:= JsonObject():New()
	Default jDepTrib	:= JsonObject():New() 
	Default aDepVlOrig	:= {} 
	

	If aNfCab[NF_PERF_PART]
	
		DefMunServ(aNFCab, @cUfServ, @cMunServ, aNfItem[nItem][IT_PRD][SB_MEPLES] == "2")
		jTaxOper["codProduto"]		:= cCodProd
		jTaxOper["ncm"]				:= cNcm
		jTaxOper["um1"]				:= c1UM
		jTaxOper["um2"]				:= c2UM
		jTaxOper["origemProduto"]	:= cOrigProd
		jTaxOper["codParticipante"]	:= cPart
		jTaxOper["lojaParticipante"]:= cLoja
		jTaxOper["tipoParticipante"]:= cTipoPart
		jTaxOper["ufOrigem"]		:= cUfOrigem
		jTaxOper["ufDestino"]		:= cUfDestino
		jTaxOper["cfop"]			:= cCfop
		jTaxOper["dataOper"]		:= aNfCab[NF_DTEMISS]
		jTaxOper["tipoOper"]		:= cTpOper
		jTaxOper["codISS"]			:= cCodIss
		jTaxOper["ufServico"]		:= cUfServ
		jTaxOper["municipioServico"]:= cMunServ
		jTaxOper["codCest"]			:= cCodCest
		jTaxOper["exTarifario"]		:= cExNcm
		
		cAliasQry	:= QryTribGen(jTaxOper,,aNfCab[NF_F2B_TESTE])
		
		BldValTrib(cAliasQry, @jVldTribs)
		FwFreeObj(jTaxOper)
		jTaxOper := Nil
		
		Do While !(cAliasQry)->(Eof())
			if (cAliasQry)->(CST+CCT) == cClasTrib
				nTrbGen	:= AddTrbGen(@aNfItem,nItem, cAliasQry, nTGITRef,aNfCab, aPos, aDic, jMapForm, jDepTrib, aDepVlOrig, .F., jVldTribs)
				TgSaveDec(@aNFCab, @aNfItem, nItem, nTrbGen)
			endif
			(cAliasQry)->(DbSKip())
		Enddo
		
		FwFreeObj(jVldTribs)
		jVldTribs := Nil					
		
		For nTrbGen := 1 to Len(aNfItem[nItem][IT_TRIBGEN])
			if aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB] == TRIB_ID_IBS_EST .OR. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB] == TRIB_ID_CBS_FED
				FisCalcTG(@aNFItem, nItem, nTrbGen,,aNfCab, jMapForm,,aFunc)					
			endif
		Next 
		
		If fisExtTab('12.1.2310', .T., 'CJ2')
			For nTrbGen:= 1 to Len(aNfItem[nItem][IT_TRIBGEN])
				if aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB] == TRIB_ID_IBS_EST .OR. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_IDTRIB] == TRIB_ID_CBS_FED
					FisLivroTG(aNfItem, nItem, nTrbGen, aNfCab, jMapForm, .T.)
				endif
			Next 
		Endif
		
		dbSelectArea(cAliasQry)
		dbCloseArea()		
	EndIF
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CalcABNT
	Realiza o arredondamento conforme regras da ABNT NBR 5891
	Regras:
	2.1 - < 5: Mantém
	2.2 - > 5: Sobe
	2.3 - = 5 (Ímpar): Sobe
	2.4 - = 5 (Par): Mantém
	@type Function
	@author Renato Rezende
	@since 31/01/2026
	@version 12.1.2510
	@param nValor, numeric, Valor a ser arredondado pela regra ABNT
    @param nCasas, numeric, Número da precisão de decimal
	@return nRet / nFator
/*/
//-------------------------------------------------------------------
Function CalcABNT(nValor, nCasas)
    Local nFator   := 10 ^ nCasas
    Local nDesloc  := nValor * nFator
    Local nInteiro := Int(nDesloc)
    Local nResto   := nDesloc - nInteiro
    Local nUltimo  := 0
    Local nRet     := 0
    
    // Correção de precisão flutuante (Ex: 0.4999999 vira 0.5)
    nResto := Round(nResto, 8) 

    If nResto < 0.5
        // Regra 2.1
        nRet := nInteiro
    ElseIf nResto > 0.5
        // Regra 2.2
        nRet := nInteiro + 1
    Else 
        // Resto é exatamente 0.5
        nUltimo := nInteiro % 10 // Pega último digito da parte inteira
        
        If (nUltimo % 2) != 0 
            // Regra 2.3: É impar, sobe
            nRet := nInteiro + 1
        Else 
            // Regra 2.4: É par, mantém
            nRet := nInteiro
        EndIf
    EndIf

Return nRet / nFator

/*/{Protheus.doc} GetRlsStmp
	Obtém o maior timestamp (DTALT+HRALT) das tabelas F27, F28 e F2B.
	Usado para detectar mudanças nas regras de cálculo e invalidar caches.

	@type  Static Function
	@author Rafael Oliveira
	@since 30/01/2026
	@version 12.1.2510
	@return cStamp, Character, Timestamp no formato YYYYMMDDHH:MM:SS ou vazio se erro
	
	@see NeedReload, MngFmCache
/*/
Static Function GetRlsStmp()
	Local oStmt     := Nil
	Local cAlias    := GetNextAlias()
	Local cStamp    := ""
	Local cQuery    := ""
	Local cDtAlt    := ""
	Local cHrAlt    := ""

	// Busca o maior timestamp entre F27, F28 e F2B usando SELECT aninhado + ROW_NUMBER().
	// O resultado permanece equivalente à versão anterior que comparava DTALT+HRALT,
	// porque a ordenação por DTALT DESC e HRALT DESC preserva o mesmo critério
	// lexicográfico para campos de tamanho fixo (data + hora).
	// Mantém ChangeQuery() para a camada de compatibilidade multi-banco do Protheus.
	cQuery := "SELECT DTALT, HRALT FROM ("
	cQuery += "  SELECT DTALT, HRALT, "
	cQuery += "         ROW_NUMBER() OVER (ORDER BY DTALT DESC, HRALT DESC) AS RN "
	cQuery += "  FROM ("
	cQuery += "    SELECT F27_DTALT AS DTALT, F27_HRALT AS HRALT FROM " + RetSqlName("F27") + " F27 "
	cQuery += "    WHERE F27.F27_FILIAL = ? "
	cQuery += "      AND F27.F27_ALTERA = '1' "
	cQuery += "      AND F27.D_E_L_E_T_ = ' ' "
	cQuery += "    UNION ALL "
	cQuery += "    SELECT F28_DTALT AS DTALT, F28_HRALT AS HRALT FROM " + RetSqlName("F28") + " F28 "
	cQuery += "    WHERE F28.F28_FILIAL = ? "
	cQuery += "      AND F28.F28_ALTERA = '1' "
	cQuery += "      AND F28.D_E_L_E_T_ = ' ' "
	cQuery += "    UNION ALL "
	cQuery += "    SELECT F2B_DTALT AS DTALT, F2B_HRALT AS HRALT FROM " + RetSqlName("F2B") + " F2B "
	cQuery += "    WHERE F2B.F2B_FILIAL = ? "
	cQuery += "      AND F2B.F2B_ALTERA = '1' "
	cQuery += "      AND F2B.D_E_L_E_T_ = ' ' "
	cQuery += "  ) TIMESTAMPS "
	cQuery += ") TIMESTAMPS_RANKED "
	cQuery += "WHERE RN = 1 "
	cQuery := ChangeQuery(cQuery)

	// Prepared statement
	oStmt := FWExecStatement():New(cQuery)
	oStmt:SetString(1, xFilial("F27"))
	oStmt:SetString(2, xFilial("F28"))
	oStmt:SetString(3, xFilial("F2B"))

	cAlias := oStmt:OpenAlias()

	If !(cAlias)->(Eof())
		cDtAlt := AllTrim((cAlias)->DTALT)
		cHrAlt := AllTrim((cAlias)->HRALT)

		// Monta o timestamp no ADVPL para manter o mesmo formato de retorno da função.
		If !Empty(cDtAlt) .And. !Empty(cHrAlt)
			cStamp := cDtAlt + cHrAlt
		EndIf
	EndIf

	(cAlias)->(DbCloseArea())
	oStmt:Destroy()
	FreeObj(oStmt)

Return cStamp

/*/{Protheus.doc} NeedReload
	Verifica se os caches de fórmulas (jMapForm, jDepTrib, jCacheCIN, jMapProc)
	precisam ser recarregados baseado em mudança de empresa/filial ou timestamp de regras.

	Esta função é exportada para ser chamada pelo matxfis.prx para decidir
	se deve preservar ou liberar os caches entre processamentos de notas.

	@type  Function
	@author Rafael Oliveira
	@since 30/01/2026
	@version 12.1.2510
	@param jCtxWb, JsonObject, Opcional para teste caixa-branca (override do contexto CACHE_EMP/CACHE_FIL/RULES_STAMP)
	@param cEmpWb, Character, Opcional para teste caixa-branca (override da empresa atual)
	@param cFilWb, Character, Opcional para teste caixa-branca (override da filial atual)
	@param cStampWb, Character, Opcional para teste caixa-branca (override do timestamp consolidado)
	@return lNeedReload, Logical, .T. se precisa recarregar, .F. se cache ainda valido
	@example
		If NeedReload()
			// Libera caches para recriar
			FwFreeObj(jMapForm)
		Else
			// Mantém caches existentes
		EndIf
	@see GetRlsStmp, MngFmCache
/*/
Function NeedReload(jCtxWb, cEmpWb, cFilWb, cStampWb)
	Local cNovoStamp := ""
	Local cCtxEmp := ""
	Local cCtxFil := ""
	Local cCtxStamp := ""
	Local cEmpRef := cEmpAnt
	Local cFilRef := cFilAnt
	Local jCtxRef := jCtxCache
	Local lHasCtxWb := (PCount() >= 1 .And. ValType(jCtxWb) == "J")
	Local lHasEmpWb := (PCount() >= 2 .And. ValType(cEmpWb) == "C")
	Local lHasFilWb := (PCount() >= 3 .And. ValType(cFilWb) == "C")
	Local lHasStampWb := (PCount() >= 4 .And. ValType(cStampWb) == "C")

	If lHasCtxWb
		jCtxRef := jCtxWb
	EndIf

	If lHasEmpWb
		cEmpRef := cEmpWb
	EndIf

	If lHasFilWb
		cFilRef := cFilWb
	EndIf

	// 1. Contexto nao inicializado = primeira execucao
	If ValType(jCtxRef) != "J"
		Return .T.
	EndIf

	If !jCtxRef:HasProperty("CACHE_EMP") .Or. !jCtxRef:HasProperty("CACHE_FIL")
		Return .T.
	EndIf

	cCtxEmp := jCtxRef["CACHE_EMP"]
	cCtxFil := jCtxRef["CACHE_FIL"]

	If ValType(cCtxEmp) != "C" .Or. ValType(cCtxFil) != "C"
		Return .T.
	EndIf

	// 2. Valida mudanca de empresa ou filial
	If cCtxEmp != cEmpRef .Or. cCtxFil != cFilRef
		Return .T.
	EndIf

	// 3. Valida timestamp de regras F27/F28/F2B
	If lHasStampWb
		cNovoStamp := cStampWb
	Else
		cNovoStamp := GetRlsStmp()
	EndIf

	If Empty(cNovoStamp)
		Return .T.
	EndIf

	If !jCtxRef:HasProperty("RULES_STAMP")
		Return .T.
	EndIf

	cCtxStamp := jCtxRef["RULES_STAMP"]
	If ValType(cCtxStamp) != "C"
		Return .T.
	EndIf

	If cNovoStamp != cCtxStamp
		Return .T.
	EndIf

Return .F.

/*/{Protheus.doc} MngFmCache
	Gerencia TODAS as caches de fórmulas de forma centralizada e atômica:
	- Valida contexto via NeedReload() (empresa/filial/timestamp de regras F27/F28/F2B)
	- Limpa e recria caches se necessário: jCacheCIN, jMapProc, jMapForm, jDepTrib, aDepVlOrig
	- Garante existência das caches (reutiliza se válidas ou recria se limpou)

	Função ÚNICA que substitui ClrFmCache() + EnsureFmCh().
	Operação atômica: validação ? limpeza ? garantia de existência.

	@type  Function
	@author Rafael Oliveira
	@since 30/01/2026
	@version 12.1.2510
	@param jMapForm, JsonObject, Cache de mapeamento de fórmulas (passado por referência)
	@param jDepTrib, JsonObject, Cache de dependências de tributos (passado por referência)
	@param aDepVlOrig, Array, Array de dependências de valores originais (passado por referência)
	@return lReloaded, Logical, .T. se caches foram recarregadas, .F. se preservadas
	@example
		// No MaFisEnd() - valida e limpa condicionalmente
		MngFmCache(@jMapForm, @jDepTrib, @aDepVlOrig)

		// No MaFisIni() - valida, limpa se necessário e garante existência
		MngFmCache(@jMapForm, @jDepTrib, @aDepVlOrig)
	@see NeedReload, GetRlsStmp
/*/
Function MngFmCache(jMapForm, jDepTrib, aDepVlOrig)
	Local lReloaded := .F.
	Local cNovoStamp := ""

	// Valida se precisa recarregar (empresa/filial/timestamp de regras)
	If NeedReload()
		// Atualiza contexto centralizado ANTES de limpar caches
		If ValType(jCtxCache) != "J"
			jCtxCache := JsonObject():New()
		EndIf
		jCtxCache["CACHE_EMP"] := cEmpAnt
		jCtxCache["CACHE_FIL"] := cFilAnt
		cNovoStamp := GetRlsStmp()
		If !Empty(cNovoStamp)
			jCtxCache["RULES_STAMP"] := cNovoStamp
		EndIf

		// 1. Limpa cache CIN (fórmulas NPI da tabela CIN)
		If ValType(jCacheCIN) == "J"
			FwFreeObj(jCacheCIN)
			jCacheCIN := Nil
		EndIf

		// 2. Reinicializa jMapProc (processos verificados)
		If ValType(jMapProc) == "J"
			FwFreeObj(jMapProc)
			jMapProc := Nil
		EndIf

		// 3. Limpa caches de fórmulas (matxfis)
		If ValType(jMapForm) == "J"
			FwFreeObj(jMapForm)
			jMapForm := nil
		EndIf

		If ValType(jDepTrib) == "J"
			FwFreeObj(jDepTrib)
			jDepTrib := nil
		EndIf

		If ValType(aDepVlOrig) == "A"
			Asize(aDepVlOrig, 0)
			aDepVlOrig := nil
		EndIf

		lReloaded := .T.
	EndIf

	// 4. Garante existência das caches (recria se limpou ou reutiliza se preservou)
	If jMapForm == nil
		jMapForm := JsonObject():New()
	EndIf

	If jDepTrib == nil
		jDepTrib := JsonObject():New()
	EndIf

	If aDepVlOrig == nil
		aDepVlOrig := {}
	EndIf

	If jCacheCIN == nil
		// Inicializa cache CIN (pré-carrega operandos e índices)
		InitCacheCIN()
	EndIf

	If jMapProc == nil
		jMapProc := JsonObject():New()
	EndIf

Return lReloaded

/*{Protheus.doc} IsOperZero
	Verifica se o operando é "O:ZERO".

	@type  Static Function
	@author Flavio Mateus de Souza
	@since 15/04/2026
	@version 102.1.2510
	@param nValor, Character, Valor do campo de operação a ser verificado
	@return lIsZero, Logical, .T. se é operação "O:ZERO", .F. caso contrário
/*/

Static Function IsOperZero(cValor)
Return cValor == "O:ZERO"

/*/{Protheus.doc} FisCalcDifer()
Função responsável por obter e retornar o valor do diferimento do tributo configurado na regra de escrituração associada,
com base no valor atualizado do tributo.
	@param aNfCab, array, Array de cabeçalho da MATXFIS
	@param aNFItem, array, matriz com os dados dos itens da nota fiscal carregados pela MATXFIS
	@param nItem, numeric, numero do item de referência posicionado no aNFItem
	@param nTrbGen, numeric, posição do tributo genério na referência IT_TRIBGEN
	@param nPercDif, numeric, percentual do diferimento configurado na regra de escituração do tributo
	@param nDifTrib, numeric, valor do tributo atualizado.
	@param lEdicao, logical, Indica se e uma alteracao onde os valores já voram calcualdo e estão armazenados nas referências.
	@param nAliqTr, numeric, aliquota do tributo
@author Desenvolvimento escrita.
@since 27/04/2026
@version 12.1.2510
/*/
Static Function FisCalcDifer(aNFCab, aNFItem, nItem, nTrbGen, nPercDif, nDifTrib, lEdicao, nAliqTr) As Numeric

	Local nDifer  := 0  As Numeric
	Local cTpAliq := "" As Character
	Local nBase   := 0  As Numeric
	Local nALiq   := 0  As Numeric
	Local nValTrib:= 0  As Numeric
	Local lVlTribAlt := .F. As Logical
	Default lEdicao := .F.

	// Percentual: formula direta BASE x (ALIQ/100) x (PERCDIF/100)
	// Evita o arredondamento intermediario de TG_IT_VALOR (MaItArred)
	// TG_IT_BASE ja reflete pauta via formula NPI quando nPauta > 0
	nBase := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]
	nAliq := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA]

	cTpAliq := aNFItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_REGRA_ALQ][TG_ALQ_TPALIQ]
	
    // Apura primeiramente o valor do tributo cheio
	If Empty(cTpAliq) .Or. cTpAliq == '1'
		nValTrib := nBase * (nAliq / 100)
	Else
		nValTrib := nBase * nAliq
	EndIf

	nDifer := nValTrib * (nPercDif / 100)

    //Quando há diferimento parcial e a aliquota do tributo não é obtida
	//por ncm (nAliqTr = 0), nDifTrib chega com valor do tributo calculado
	//deduzido do percentual do tributo diferido, não caracterizando uma  
	//alteração manual do valor do tributo.
	If nAliqTr == 0
		lVlTribAlt := Round(nValTrib,2) <> Round(nDifTrib + nDifer,2)
	ElseIf nDifTrib > 0
		lVlTribAlt := Round(nValTrib,2) <> Round(nDifTrib,2)
	EndIf

	//Edicao manual: preserva o valor editado pelo usuario sem recalcular
	If lEdicao .And. lVlTribAlt
		nDifer := nDifTrib * (nPercDif / 100)
	EndIf
	
Return nDifer

//-------------------------------------------------------------------
/*/{Protheus.doc} FisApplyRelPol

Aplica a politica de tributo para documentos com origem (CI6/CI7).
Chamada apos FisDevTrbGen() no fluxo de FisTribGen.

Para cada tributo em IT_TRIBGEN, le o modo pre-carregado em TG_IT_MODO_CI7
(populado por FisLoadTG via JOIN em CI6/CI7) e aplica:
  Modo "1" (Zerar):  base, aliquota e valor = 0; TG_IT_VL_ZERO = .T.
  Modo "2" (Omitir): marca TG_IT_DELETED_TRIB = .T. e chama RemoveTrbGen
                     para remover o tributo fisicamente do IT_TRIBGEN.
  Demais modos: reservados.

@param aNfCab   - Array com informacoes do cabecalho da nota
@param aNfItem  - Array (por referencia) com itens da nota
@param nItem    - Indice do item atual
@param jMapForm - JsonObject com mapeamento do formulario (reservado para modos futuros)

@author Squad Fiscal
@since 18/05/2026
@version 12.1.2610
/*/
//-------------------------------------------------------------------
Static Function FisApplyRelPol(aNfCab, aNfItem, nItem, jMapForm)

	Local nTrbGen  := 0
	Local nTotTG   := 0
	Local cModo    := ""
	Local lRemoveTrb := .F.

	nTotTG := Len(aNfItem[nItem][IT_TRIBGEN])

	// ARCH-002: modo CI6/CI7 pre-carregado em TG_IT_MODO_CI7 por FisLoadTG — sem I/O neste loop
	For nTrbGen := 1 To nTotTG
		cModo := aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_MODO_CI7]

		If cModo == "1"
			// Zerar: mantem tributo no IT_TRIBGEN com base/aliquota/valor = 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE]     := 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_ALIQUOTA] := 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR]    := 0
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO]  := .T.
		ElseIf cModo == "2"
			// Omitir: remove o tributo do IT_TRIBGEN (marcado para exclusao fisicamente por RemoveTrbGen)
			aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_DELETED_TRIB] := .T.
			lRemoveTrb := .T.			
		//Else
			// Demais modos: reservados
		EndIf

	Next nTrbGen

	If lRemoveTrb
		RemoveTrbGen(aNfCab, aNfItem, nItem)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DevTrbOperZero
    Marca o tributo genérico do item como valor zero (TG_IT_VL_ZERO)
    quando o tag de valor zero estiver ativo ou quando, em operação
    de devolução (tipo D ou B), o tributo não possuir valor nem base.
    @type  Static Function
    @author Ricardo
    @since 09/06/2026
    @version 12.1.2510
    @param aNfCab, Array, Cabeçalho da nota fiscal
    @param aNfItem, Array, Itens da nota fiscal
    @param nItem, Numeric, Posição do item em aNfItem
    @param nTrbGen, Numeric, Posição do tributo genérico no item
    @param lTgVlZero, Logical, Indica se o tag de valor zero está ativo
    @return Nil, N/A, Sem retorno
/*/
//-------------------------------------------------------------------
Static Function DevTrbOperZero(aNfCab as array, aNfItem as array, nItem as numeric, nTrbGen as numeric, lTgVlZero as logical)
	
	Local lDevolucao := .F. as logical
	Local lZeraTrib  := .F. as logical
	
	lDevolucao := aNfCab[NF_TIPONF] $ "D/B"
	
	lZeraTrib := lTgVlZero .Or. (lDevolucao .And. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VALOR] == 0 .And. aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_BASE] == 0)
	If lZeraTrib
		aNfItem[nItem][IT_TRIBGEN][nTrbGen][TG_IT_VL_ZERO] := .T.
	EndIf
Return
