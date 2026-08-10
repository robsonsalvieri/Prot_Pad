#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "LOCA013.CH"

/*/{PROTHEUS.DOC} LOCA013.PRW
ITUP BUSINESS - TOTVS RENTAL
GERACAO DE CONTRATOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA013(_lAviso)
Local AAREAOCR  	:= GETAREA()
Local _LCONVSUS 	:= SUPERGETMV("MV_LOCX205",.F.,.T.)		// CONVERSAO DE PROSPECT PARA CLIENTE
Local lMvLocx051 	:= SUPERGETMV("MV_LOCX051",.F.,.T.)
Local _lPassa
Local lRet 			:= .T.
Local cErro 		:= ""

//Private LVERZBX   := GETMV("MV_LOCX097",,.f.) 					// HABILITA CONTROLE DE MINUTA
Private AASNOVA   	:= {}
Private AASREV	  	:= {}
Private ALINALT   	:= {}
Private _AREGS	  	:= {}
Private lInforma  	:= .F.
Private _lMens    	:= _lAviso
private lImplemento := .F.

Public _LGERAR   := .T.

Default _lAviso   := .T.

	MV_LOCX020 := GETMV("MV_LOCX020")

	If Type("lLocAuto") == "L" .And. ValType(cLocErro) == "C"
		If lLocAuto
			_lPassa := .T.
		Else
			_lPassa := .F.
		EndIF
	Else
		_lPassa := .F.
	EndIF

	// Card 1188 - Frank em 06/10/23
	// Tratativa de status para não aceitar os seguintes casos:
	// Status faturado, Rejeitado, Perdido, Excluído e Indisponível
	If FP0->FP0_STATUS $ "8,7,C,B,6"
		cErro := STR0151 //"Status do orçamento inválido para a geração do contrato."
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro :=cErro +CRLF
		Else
			Help(Nil,	Nil,STR0156+alltrim(upper(Procname())),; //STR0156 //"RENTAL: "
					Nil,STR0128,1,0,Nil,Nil,Nil,Nil,Nil,; //STR0128 //"Inconsistência nos dados."
					{cErro})
		EndIf
		lRet := .F.
	EndIF

	If lRet .and. lMvLocx051
		If !LOCA01314(_lPassa)
			lRet := .F.
		EndIf
	EndIf

	IF LRet .and. !_LCONVSUS
		IF EMPTY(FP0->FP0_CLI) .AND. !EMPTY(FP0->FP0_PROSPE)
			//Ferramenta Migrador de Contratos
			cErro := STR0001 + SUPERGETMV("MV_LOCX248",.F.,STR0002) + STR0003 //"É necessário converter o prospect em cliente e atualizar o "
			If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
				cLocErro := cErro +CRLF //"É necessário converter o prospect em cliente e atualizar o "
			Else
				Help(Nil,	Nil,STR0156+alltrim(upper(Procname())),; //STR0156 //"RENTAL: "
					Nil,STR0128,1,0,Nil,Nil,Nil,Nil,Nil,; //STR0128 //"Inconsistência nos dados."
					{cErro})
			EndIf
			RESTAREA(AAREAOCR)
			lRet := .F.
		ENDIF
	ENDIF

	IF EXISTBLOCK("CLIBLOQ") .AND. (EMPTY(FP0->FP0_PROSPE) .OR. !EMPTY(FP0->FP0_CLI))
		If EXECBLOCK("CLIBLOQ" , .T. , .T. , {FP0->FP0_CLI, FP0->FP0_LOJA, .T.})
			RESTAREA(AAREAOCR)
			lRet := .f.
		ENDIF
	ENDIF

	if lRet .and. !LOCA013F(FP0->FP0_PROJET, _lPassa)
		lRet := .F.
	endif

	if lRet
		PROCESSA({|| lRet := LOCA01301()},"Geração de Contratos") 
	endif

	RESTAREA(AAREAOCR)

	_LGERAR := .F.

RETURN lRet

/*/{PROTHEUS.DOC} LOCA01301
ITUP BUSINESS - TOTVS RENTAL
PROCESSAMENTO DA GERACAO DE CONTRATOS
@TYPE FUNCTION
@since 01/01/2020
@AUTHOR FRANK ZWARG FUGA
/*/
FUNCTION LOCA01301() 		// --> GERA CONTRATO
Local AERROSZBX := {}
Local NALIISS 	:= 0
Local LOK 	    := .F.
Local NRET 		:= 3
Local CREVISA   := ""
Local CNUMSC5   := ""
Local CNATUREZ  := ""
Local _NDESCVEN := 0
Local CQUERY	:= ""
Local cStatGerAs := ""
Local N         := 0
Local _NX       := 0
Local _NT       := 0
Local _nY       := 0
Local _lBloq    := .f.
Local _GRCANVLD := EXISTBLOCK("GRCANVLD")
Local _MV_LOC207 := SUPERGETMV("MV_LOCX207",,.F.)
Local _MV_LOC278 := supergetmv("MV_LOCX278",,.F.)
Local _MV_LOC155 := GETMV("MV_LOCX155",,"")
Local _lPassa    := .F.
Local _lPassa2   := .F.
Local lLOCX305	:= SuperGetMV("MV_LOCX305",.F.,.T.) //Define se aceita geração de contrato sem equipamento
Local lLOCX097	:= SuperGetmv("MV_LOCX097" , .F. , .F.) // Indica quando entrar um conflito se deixa passar - Frank em 10/01/25
Local lPergGerAs:= .F.
Local aGeraAs	:= {}
Local aPergs	:= {}
Local aRet		:= {}
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local _CQUERY
Local lMvLocx307 := SUPERGETMV("MV_LOCX307",.F.,.F.) // Habilita o preenchimento automatico do equipamento.

Local aAloca := {0,0} // Equipamentos Alocados
Local cErro  := ""
Local lAlocada := .F.
Local aAreaFpa := {}
Local lBlqTae := .F.
Local aErros := {}
Local cStatus := ""
Local lControle 
Local dInix
Local dFimx
Local aDatas
Local dDatax
Local aFeriados := RetFeriados()
Local aAreaFPAx
Local nX

Local aFQ5x := {}
Local nHorax := 0
Local aFPFx := {}
Local ny 

Private ODLGOP
Private _CPRODUTO    := SPACE(15)
Private _NPRCEQU     := 0
Private LCLIENTE     := .F.
Private CCONTATO     := ""
Private CCONTRATO    := ""
Private CCRITICA     := ""
Private	LMSERROAUTO  := .F.
Private	LMSHELPAUTO  := .F.
Private LINCBKP      := INCLUI
Private LALTBKP      := ALTERA
Private AROTBKP      := AROTINA
Private CANEXO       := "" 						// AS EM PDF P/ ANEXAR AO E-MAIL.
Private NQUANT       := 0 						// QUANT. HORAS
Private NVALOR       := 0 						// VLR TOTAL
Private CPRODUTO     := GETMV("MV_PRODHOR") 	// VLR TOTAL
Private CTES         := GETMV("MV_LOCX186") 		// VLR TOTAL
Private ACAMPOSSC5   := {}
Private ACAMPOSSC6   := {}
Private AITPED       := {} 						// ITENS PARA GERACAO DO PEDIDO
Private NVLRDES      := 0 						// VALOR DO DESCONTO
Private NQTDHORAS    := 0 						// QTIDADE DE HORAS
Private NVLRTOTAL    := 0 						// VALOR TOTAL
Private NVLRHORU     := 0 						// VALOR POR HORA
Private NHORASDES    := 0 						// HORAS DESCONTADAS
Private NVALMO       := 0
Private ADESCON      := {} 						// ARRAY DE DESCONTO
Private CPRODM       := GETMV("MV_LOCX173")
Private CPRODD       := GETMV("MV_LOCX170")
Private CPRODMONT    := GETMV("MV_LOCX174")
Private CPRODDESMONT := GETMV("MV_LOCX171")
Private CPRODTELE    := GETMV("MV_LOCX175")
Private CPRODANC     := GETMV("MV_LOCX169")
Private CGRPAND		 := SUPERGETMV("MV_LOCX014",.F.,"" )
Private LGERCLI		 := SUPERGETMV("MV_LOCX211",.F.,.F.)
Private CPRODT		 := "999900009" 			// GETMV("MV_LOCX265")
Private CPRODS       := "999900009" 			// AADD(AITPED,{CPRODS,1,NVALMO,NVALMO,FP4->FP4_GUINDA})
Private LRESENTEML	 := .F. 					// ADICIONA AS PARA IMPRESSÃO EM PDF
Private _LERRO       := .T.
Private ALOG         := {}
Private cCadastro    := STR0005 //"Cadastro"
private lImplemento  := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)
Private cRetTae		 := ""
Private lExibeTae    := .T.

	CNATUREZ := GETMV("MV_LOCX117",,"E010201")

	If Type("lLocAuto") == "L" .And. ValType(cLocErro) == "C"
		If lLocAuto
			_lPassa := .T.
		EndIf
	EndIF
	If !( Type("lLocAuto") == "L" )
		_lPassa2 := .T.
	Else
		If !lLocAuto
			_lPassa2 := .T.
		Else
			_lPassa2 := .F.
		EndIF
	EndIF

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CGRPAND := LOCA00189()
	ELSE
		CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
	ENDIF

	// Frank Fuga - converte prospect em cliente 16/02/21
	IF EMPTY( FP0->FP0_CLI ) .and. !empty(FP0->FP0_PROSPE)
		If lGerCli .and. msgYesNo(STR0006,STR0007) //"Confirma a conversão do prospect para cliente?"###"Atenção!"
			ACLIENTE := DADOSCLI()
			LMSHELPAUTO  := .T.
			LJMSGRUN(STR0008,,{||  MSEXECAUTO({|X,Y|MATA030(X,Y)},ACLIENTE,3) } ) //"AGUARDE...INCLUINDO CLIENTE VERIFIQUE DADOS POSTERIORMENTE"
			LMSHELPAUTO  := .F.
			IF LMSERROAUTO
				ROLLBACKSX8()
				MOSTRAERRO()
			ELSE
				CONFIRMSX8()
				RECLOCK("FP0",.F.)
				FP0->FP0_CLI := SA1->A1_COD
				FP0->FP0_LOJA:= SA1->A1_LOJA
				FP0->(MSUNLOCK())
				LCLIENTE := .T.
				WHILE .T.
					NRET := AXALTERA("SA1",SA1->(RECNO()),4,,,,,)
					IF NRET == 1
						EXIT
					ELSE
						MSGINFO(STR0009 , STR0010) //"FAVOR CONFIRMAR A OPERAÇÃO."###"Confirme os dados do cliente."
					ENDIF
				ENDDO
			ENDIF
		EndIF
	EndIf

	IF EMPTY( FP0->FP0_CLI )
		//Ferramenta Migrador de Contratos
		cErro := STR0011+CRLF //"Favor informar o cliente na proposta!"
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := cErro+CRLF
		Else
			MSGALERT(cErro , STR0004) //"FAVOR INFORMAR O CLIENTE NA PROPOSTA!"###"GPO - GRCONTR.PRW"
		EndIf
		RETURN .F.
	ENDIF

	SA1->(dbSetOrder(1))
	IF ! SA1->(MSSEEK(XFILIAL("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))
		//Ferramenta Migrador de Contratos
		cErro := STR0012+FP0->FP0_CLI+"/"+FP0->FP0_LOJA+STR0013 //"Cliente "
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := cErro + CRLF //"Cliente "
		Else
			MSGALERT(cErro, STR0004) //"CLIENTE "###" NÃO ENCONTRADO, VERIFIQUE!"###"GPO - GRCONTR.PRW"
		EndIf
		RETURN .F.
	ELSE
		LCLIENTE := .T.
	ENDIF

	IF SA1->A1_MSBLQL == "1"
		//Ferramenta Migrador de Contratos
		cErro := STR0014 //"Cliente bloqueado"
		If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
			cLocErro := cErro + CRLF //"Cliente bloqueado"
		Else
			MSGALERT(cErro , STR0004) //"CLIENTE BLOQUEADO"###"GPO - GRCONTR.PRW"
		EndIf
		RETURN .F.
	ENDIF

	// Rossana - DSERLOCA-3163 - a tratativa de aprovação está depois da tela de AS Parcial - linha 646
	IF MV_LOCX020
		// Aprova/reprova contrato
		If !LOCA05704(NIL,NIL,NIL,NIL)
			RETURN .F.
		EndIf
	ENDIF

	DBSELECTAREA("SU5")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SU5")+FP0->FP0_CLICON)

	//05/12/2022 - Jose Eulalio -  SIGALOC94-534 - Colocar uma tela de seleção de geração de AS (DTQ)
	If (FP0->FP0_STATUS == "1" .or. FP0->FP0_STATUS == "3") .And. !_lPassa
		lPergGerAs := MsgYesNo(STR0131,STR0007) //"Deseja gerar AS parcial?"
		//Traz Grid para selecionar itens que irão gerar AS
		If lPergGerAs
			lExibeTae := .F.
			aAdd( aPergs ,{1 ,STR0145	,Space(3) 	,"@!"  , "","", ".T." ,6 , .F.}) // "Obra De ?"
			aAdd( aPergs ,{1 ,STR0146  	,"ZZZ"  	,"@!"  , "","", ".T." ,6 , .T.}) // "Obra Ate ?"
			//Pergunta as obras
			If ParamBox(aPergs , STR0147,@aRet,,,,,,,,.F.) //"Informe a Obra"
				MV_PAR01 := aRet[1]
				MV_PAR02 := aRet[2]
				//Pergunte("LOCP013",.T.)
				aGeraAs := SelGeraAs(FP0->FP0_PROJET,MV_PAR01,MV_PAR02,@lPergGerAs)
			Else
				_LGERAR := .F.
			EndIF
			IF !_LGERAR
				RETURN .F.
			ENDIF
		Else
			If !MsgYesNo(STR0150,STR0007) // "Confirma a geração do contrato?"###"Atenção!"
				Return
			EndIF
//          excluida tratativa MV_LOCX097 - DSERLOCA 4419 - Rossana - 09/12/2024
//			if lMvLocx307 .and. !LVERZBX // Preenche as AS e não há controle de minuta 
			if lMvLocx307  // 
				PROCESSA({|| aAloca := LOCA013D()}, STR0159,STR0158) //"Processando" //"Alocação Automatica de Equipamentos"
				lAlocada  := .T.
//				Aviso("Alocacao de Ativos", "Foram alocados Equipamentos em "+Alltrim(Str(aAloca[1]))+ " linhas e "+Alltrim(Str(aAloca[2]))+ " não foram ")
			endif
		EndIf
	EndIf

	IF EXISTBLOCK("GRCTVLD") 											// --> PONTO DE ENTRADA PARA VALIDAR SE PERMITE A GERAÇÃO DE CONTRATO.
		_LGERAR := EXECBLOCK("GRCTVLD",.T.,.T.,{})
		IF !_LGERAR
			RETURN .F.
		ENDIF
	ENDIF

	PROCREGUA(10)
	INCPROC(STR0018  ) //"VERIFICANDO ALOCACAO DOS EQUIPAMENTOS"

	// --> CONSULTA A DISPONIBILIDADE DE FROTA
	DO CASE
	CASE _LGERAR .AND. FP0->FP0_TIPOSE == "L"							// LOCAÇÃO
		FQ5->(DBSETORDER(1))
		FPA->(DBSETORDER(1))
		ST9->(DBSETORDER(1))

		// ISSUE 4589 - Controle de aprovação no TAE - Frank em 30/12/24
		lBlqDoc := .F.

		IF FPA->(DBSEEK(XFILIAL("FPA") + FP0->FP0_PROJET))
			WHILE FPA->(!EOF()) .AND. FPA->FPA_PROJET == FP0->FP0_PROJET
				If lPergGerAs .And. !IsGeraAs(aGeraAs,FP0->FP0_PROJET,FPA->FPA_OBRA,FPA->FPA_SEQGRU) .And. (!(ValType("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"))
					FPA->(DBSKIP())
					LOOP
				EndIf

				// ISSUE 4589 - Integração do TAE - Frank em 30/12/2024
				If !LOCA013T()
					_lGerar := .F.
					lBlqTae := .T.
					FPA->(DBSKIP())
					exit
				EndIf

				// Rossana - DSERLOCA 2167
				If Empty(FPA->FPA_DTENRE)
					MSGALERT(STR0153 + FPA->FPA_OBRA + " - " + FPA->FPA_SEQGRU)  //"Não foi informada a data final de contrato - obra "
					Return .F.
				EndIf

				// DSERLOCA-5063 - Frank Fuga - Retorno da mensagem de conflito de AS
				// -------------------------------------------------------------------------------------------------
				
				/* VALIDACAO 1
				Não pode encontrar na mesma data e horário da minuta
				encavalamento, em AS diferentes da FPA
				*/

				_cQuery := " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME("FPF")+" "
				_cQuery += " WHERE FPF_FILIAL = '"+xFilial("FPF")+"' AND "
				_cQuery += " FPF_STATUS NOT IN ('4','5') AND " // encerrada e cancelada
				_cQuery += " FPF_DATA BETWEEN ? AND ? AND "
				_cQuery += " FPF_FROTA = ? AND "
				//_cQuery += " FPF_HORAI >= ? AND FPF_HORAF <= ? AND "
				_cQuery += " FPF_AS <> ? AND "
				_cQuery += " D_E_L_E_T_ = ' ' "

				IF SELECT("TRBVLD") > 0
					TRBVLD->(DBCLOSEAREA())
				ENDIF
				_CQUERY := CHANGEQUERY(_CQUERY)
				//aBindParam := {Dtos(FPA->FPA_DTINI),Dtos(FPA->FPA_DTFIM),FPA->FPA_GRUA, FPA->FPA_HRINI, FPA->FPA_HRFIM, FPA->FPA_AS}
				aBindParam := {Dtos(FPA->FPA_DTINI),Dtos(FPA->FPA_DTFIM),FPA->FPA_GRUA, FPA->FPA_AS}
				MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)

				// Armazenar todas as horas contidas no contrato em questão
				aFQ5x := {}
				nHorax := val(FPA->FPA_HRINI)
				While nHorax <= val(FPA->FPA_HRFIM)
					aadd(aFQ5x,nHorax)
					nHorax ++
				EndDo

				While !TRBVLD->(EOF())

					FPF->(dbGoto(TRBVLD->REG))

					// ISSUE - DSERLOCA-8717 - Frank em 23/09/25
					// Não validar o conflito no caso de ser uma linha de mão de obra
					If FPA->FPA_TIPOSE == "M" .or. empty(FPA->FPA_GRUA)
						TRBVLD->(dbSkip())
						Loop
					EndIf

					lControle := .T.

					// Armazenar todas as horas contidas no contrato em questão
					aFPFx := {}
					nHorax := val(FPF->FPF_HORAI)
					While nHorax <= val(FPF->FPF_HORAF)
						aadd(aFPFx,nHorax)
						nHorax++
					EndDo

					lControle := .T.
					For nX := 1 to len(aFQ5x)
						For nY := 1 to len(aFPFx)
							If aFQ5x[nX] == aFPFx[nY]
								lControle := .F.
								exit
							EndIf
						Next
						If !lControle
							Exit
						EndIf
					Next
					If !lControle .and. aFPFx[ len(aFPFx) ] == aFQ5x[1]
						lControle := .T.
					EndIf

					cStatus := ""
					If FPF->FPF_STATUS == "1"
						cStatus := STR0176 //"Prevista"
					ElseIf FPF->FPF_STATUS == "2"
						cStatus := STR0177 //"Confirmada"
					ElseIf FPF->FPF_STATUS == "3"
						cStatus := STR0178 //"Baixada"
					ElseIf FPF->FPF_STATUS == "4"
						cStatus := STR0179 //"Encerrada"
					ElseIf FPF->FPF_STATUS == "5"
						cStatus := STR0180 //"Cancelada"
					Else
						cStatus := STR0181 //"Medida"
					EndIf

					If !lControle
						aadd(aErros,{FPF->FPF_DATA,;
										FPA->FPA_HRINI,;
										FPA->FPA_HRFIM,;
										FPF->FPF_MINUTA,;
										FPF->FPF_HORAI,;
										FPF->FPF_HORAF,;
										FPF->FPF_PROJET,;
										FPF->FPF_OBRA,;
										FPF->FPF_AS,;
										FPF->FPF_TURNO,;
										FPF->FPF_FROTA,;
										cStatus,;
										"Conflito Minuta x Locação"})
					EndIf
				
					TRBVLD->(dbSkip())

				EndDo
				TRBVLD->(DBCLOSEAREA())

				/* VALIDACAO 2
				Localizar nas Minutas as válidas que não conflitem com a FPE (Turnos)
				*/

				_cQuery := " SELECT R_E_C_N_O_ REG FROM "+RETSQLNAME("FPF")+" "
				_cQuery += " WHERE FPF_FILIAL = '"+xFilial("FPF")+"' AND "
				_cQuery += " FPF_AS <> ? AND "
				_cQuery += " FPF_FROTA = ? "
				_cQuery += " AND D_E_L_E_T_ = ' ' "

				IF SELECT("TRBVLD") > 0
					TRBVLD->(DBCLOSEAREA())
				ENDIF
				_CQUERY := CHANGEQUERY(_CQUERY)
				aBindParam := {FPA->FPA_AS, FPA->FPA_GRUA}
				MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)

				While !TRBVLD->(EOF())

					FPF->(dbGoto(TRBVLD->REG))

					lControle := .T.

					If FPF->FPF_DATA >= FPA->FPA_DTINI .and. FPF->FPF_DATA <= FPA->FPA_DTFIM
						If FPF->FPF_HORAI > FPA->FPA_HRINI .and. FPF->FPF_HORAI < FPA->FPA_HRFIM
							lControle := .F.
						EndIf
						If FPF->FPF_HORAF > FPA->FPA_HRINI .and. FPF->FPF_HORAF < FPA->FPA_HRFIM
							lControle := .F.
						EndIf
					EndIF

					If lControle

						aDatas := {}

						// Não pode encontrar conflitos com a FPE
						cQuery := " SELECT R_E_C_N_O_ REG1 FROM "+RETSQLNAME("FPE")+" "
						cQuery += " WHERE FPE_FILIAL = '"+xFilial("FPE")+"' AND "
						cQuery += " FPE_FROTA = ? "
						cQuery += " AND D_E_L_E_T_ = ' ' "

						IF SELECT("TRBFPE") > 0
							TRBFPE->(DBCLOSEAREA())
						ENDIF
						cQuery := CHANGEQUERY(cQuery)
						aBindParam := {FPA->FPA_GRUA}
						MPSysOpenQuery(cQuery,"TRBFPE",,,aBindParam)

						While !TRBFPE->(Eof()) 

							FPE->(dbGoto(TRBFPE->REG1))

							cAsx := FPF->FPF_AS
							aAreaFPAx := FPA->(GetArea())

							FPA->(dbSetOrder(1))
							If FPA->(dbSeek(xFilial("FPA")+FPE->(FPE_PROJET+FPE_OBRA+FPE_SEQGUI)))
								If FPA->FPA_AS == cAsx .or. FPA->FPA_TIPOSE == "M" .or. empty(FPA->FPA_GRUA)
									TRBFPE->(dbSkip())
									FPA->(RestArea(aAreaFPAx))
									Loop
								EndIF
								dInix := FPA->FPA_DTINI
								dFimx := FPA->FPA_DTFIM

								If ((FPE->FPE_HRINIT > FPF->FPF_HORAI .and. FPE->FPE_HRINIT < FPF->FPF_HORAF) .AND.;
								   (FPE->FPE_HOFIMT > FPF->FPF_HORAI .and. FPE->FPE_HOFIMT < FPF->FPF_HORAF))

									//Encontrar as datas validas para ver se não conflita com a FPF
									//A=Diurno/Noturno
									//E=Sexta diferenciada
									//S=Sábado
									//F=Domingo/Feriado
									//M=Manual (não precisa validar)
									
									For dDataX := dInix to dFimx
										If FPE->FPE_DIASEM == "A"
											aadd(aDatas,dDatax)
										EndIf
										If FPE->FPE_DIASEM == "E"
											If dow(dDatax) == 6 // sexta
												aadd(aDatas,dDatax)
											EndIf
										EndIf
										If FPE->FPE_DIASEM == "S"
											If dow(dDatax) == 7 // sabado
												aadd(aDatas,dDatax)
											EndIf
										EndIf
										If FPE->FPE_DIASEM == "F"
											If dow(dDatax) == 1 // domingo
												aadd(aDatas,dDatax)
											Else
												// validar se é um feriado
												If AScan(aFeriados,dtos(dDatax)) > 0
													aadd(aDatas,dDatax)
												EndIf
											EndIf
										EndIf
									Next

								EndIf

							EndIf

							cStatus := ""
							If FPF->FPF_STATUS == "1"
								cStatus := STR0176 //"Prevista"
							ElseIf FPF->FPF_STATUS == "2"
								cStatus := STR0177 //"Confirmada"
							ElseIf FPF->FPF_STATUS == "3"
								cStatus := STR0178 //"Baixada"
							ElseIf FPF->FPF_STATUS == "4"
								cStatus := STR0179 //"Encerrada"
							ElseIf FPF->FPF_STATUS == "5"
								cStatus := STR0180 //"Cancelada"
							Else
								cStatus := STR0181 //"Medida"
							EndIf

							For nX := 1 to len(aDatas)
								If aDatas[nx] == FPF->FPF_DATA 
									If FPE->FPE_HRINIT >= FPF->FPF_HORAI .and. FPE->FPE_HOFIMT <= FPF->FPF_HORAF
										aadd(aErros,{aDatas[nx],;
													FPE->FPE_HRINIT,;
													FPE->FPE_HOFIMT,;
													FPF->FPF_MINUTA,;
													FPF->FPF_HORAI,;
													FPF->FPF_HORAF,;
													FPF->FPF_PROJET,;
													FPF->FPF_OBRA,;
													FPF->FPF_AS,;
													FPF->FPF_TURNO,;
													FPF->FPF_FROTA,;
													cStatus,;
													"Conflito Turno x Minuta"})
									EndIf
								EndIf
							Next

							FPA->(RestArea(aAreaFPAx))
							TRBFPE->(dbSkip())
						EndDo
						TRBFPE->(DBCLOSEAREA())
				
					EndIf

					TRBVLD->(dbSkip())

				EndDo

				// não validar conflito de horas no caso de mão de obra - Frank em 15/09/25
				If FPA->FPA_TIPOSE == "M"
					aErros := {}
				EndIf

				If len(aErros) > 0
					LOCA013X(aErros)
				EndIf

				If len(aErros) > 0 .and. lLOCX097  // lLOCX097 habilita o bloqueio da minuta
					Return .F.
				EndIf
				// -------------------------------------------------------------------------------------------------

				IF ! FQ5->(DBSEEK(XFILIAL("FQ5") + FPA->FPA_VIAGEM)) .OR. EMPTY(ALLTRIM(FPA->FPA_AS))
					If SB1->( MSSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT) )
						// LOgica para Locação e Produtos que exisgem equipamento (BEM)
						IF FPA->FPA_TIPOSE == "L" .AND. ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND)		// !(ALLTRIM(GETADVFVAL("SB1", "B1_GRUPO",XFILIAL("SB1")+FPA->FPA_PRODUT,1,"")) $ ALLTRIM(SUPERGETMV("MV_LOCX014",.F.,"")))
							IF !EMPTY(ALLTRIM(FPA->FPA_NFREM))
								FPA->(DBSKIP())
								LOOP
							ENDIF

							if lMvLocx307 .and. !lAlocada
								// Tendo alocação Automatica  não tendo minuto e ainda não alicando

								if  Empty(FPA->FPA_GRUA) .and. lPergGerAs .and. IsGeraAs(aGeraAs,FP0->FP0_PROJET,FPA->FPA_OBRA,FPA->FPA_SEQGRU)
									// Se não há seleção ou está selecinado tentar atribuir GRUA

									cGrua := LOCA013E(FPA->FPA_PRODUT, FP0->FP0_PROJET)
									if !Empty(cGrua)
										RECLOCK("FPA",.F.)
										FPA->FPA_GRUA := cGrua
										FPA->FPA_DESGRU := ALLTRIM(ST9->T9_NOME)
										MsUnlock()
										aAloca[1]++ // Incrementa os numero de Alocações
									else
										aAloca[2]++ // Incrementa o numero de Falhas de Alocação
									endif
								endif
							endif

							If !Empty(FPA->FPA_GRUA)
								IF _GRCANVLD 						// --> PONTO DE ENTRADA ANTES DA ALTERAÇÃO DE STATUS DO BEM.
									If !lMvLocBac
										IF !EXECBLOCK("GRCANVLD",.T.,.T.,{ST9->T9_STATUS,TQY->TQY_STATUS,FPA->FPA_PROJET,"",""})
											FPA->(DBSKIP())
											LOOP
										ENDIF
									else
										IF !EXECBLOCK("GRCANVLD",.T.,.T.,{ST9->T9_STATUS,FQD->FQD_STATQY,FPA->FPA_PROJET,"",""})
											FPA->(DBSKIP())
											LOOP
										ENDIF
									EndIF
								ENDIF
							endif

							if !Empty(FPA->FPA_GRUA)
								DBSELECTAREA("ST9")
								ST9->(DBSETORDER(1))
								ST9->(DBGOTOP())
								IF ST9->(MSSEEK(XFILIAL("ST9") + FPA->FPA_GRUA))

									If !lMvLocBac

										DBSELECTAREA("TQY")
										TQY->(DBSETORDER(1))
										TQY->(DBGOTOP())
										TQY->(DBSEEK(XFILIAL("TQY") + ST9->T9_STATUS))
										DO CASE
										CASE ALLTRIM(ST9->T9_SITBEM) == "I"
											//Ferramenta Migrador de Contratos
											If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
												cLocErro := STR0024 + alltrim(ST9->T9_CODBEM) + " - " + Alltrim(ST9->T9_NOME) + STR0025 + STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU+ CRLF + STR0026 + FPA->FPA_OBRA+CRLF //"O equipamento "
											Else
												MSGALERT(STR0024 + ALLTRIM(ST9->T9_CODBEM) + " - " + ALLTRIM(ST9->T9_NOME) + STR0025 + STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU + CRLF + ; //"O EQUIPAMENTO "###" ESTÁ INATIVO!"
												STR0026 + FPA->FPA_OBRA) //"OBRA:"
											EndIf
											RETURN

										CASE TQY->TQY_STTCTR $ "10#20#30#40#50" .AND. EMPTY(ALLTRIM(FPA->FPA_AS)) .and. !empty(ST9->T9_STATUS)
											_CQUERY := " SELECT COUNT(*) QTDLOC"
											_CQUERY += " FROM " + RETSQLNAME("FPA") + " ZAG "
											_CQUERY +=        " INNER JOIN " + RETSQLNAME("FQ5") + " DTQ"
											_CQUERY +=                   " ON  FQ5_FILORI = FPA_FILIAL"
											_CQUERY +=                   " AND FQ5_AS     = FPA_AS"
											_CQUERY +=                   " AND FQ5_STATUS <> '9'"
											_CQUERY +=                   " AND DTQ.D_E_L_E_T_ = ''"
											_CQUERY +=        " INNER JOIN " + RETSQLNAME("ST9") + " ST9"
											_CQUERY +=                   " ON  T9_CODBEM = FPA_GRUA"
											_CQUERY +=                   " AND ST9.D_E_L_E_T_ = ''"
											_CQUERY +=        " INNER JOIN " + RETSQLNAME("TQY") + " TQY"
											_CQUERY +=                   " ON  TQY_STATUS = T9_STATUS"
											_CQUERY +=                   " AND TQY_STTCTR IN ('10','20','30','40','50')"
											_CQUERY +=                   " AND TQY.D_E_L_E_T_ = ''"
											_CQUERY += " WHERE FPA_GRUA <> ''"
											_CQUERY +=   " AND FPA_GRUA = ? "
											_CQUERY +=   " AND FPA_FILIAL + FPA_PROJET <> ? "
											_CQUERY +=   " AND FPA_NFRET = ''"
											_CQUERY +=   " AND ZAG.D_E_L_E_T_ = ''"
											IF SELECT("TRBVLD") > 0
												TRBVLD->(DBCLOSEAREA())
											ENDIF
											_CQUERY := CHANGEQUERY(_CQUERY)
											aBindParam := {ST9->T9_CODBEM, FPA->FPA_FILIAL + FPA->FPA_PROJET }
											MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)
											//TCQUERY _CQUERY NEW ALIAS "TRBVLD"

											IF TRBVLD->(EOF())
												TRBVLD->(DBCLOSEAREA())
												FPA->(DBSKIP())
												LOOP
											ELSE
												_lBloq := .F.
												If TRBVLD->QTDLOC > 0
													_lBloq := .T.
												EndIf
												TRBVLD->(DBCLOSEAREA())
												If _lBloq
													//Ferramenta Migrador de Contratos
													If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
														cLocErro := STR0024 + alltrim(ST9->T9_CODBEM) + " - " + alltrim(ST9->T9_NOME) + STR0028 + alltrim(TQY->TQY_DESTAT) +  STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU+" !"+CRLF //"O equipamento "
													Else
														MSGALERT(STR0024 + ALLTRIM(ST9->T9_CODBEM) + " - " + ALLTRIM(ST9->T9_NOME) + STR0028 + ALLTRIM(TQY->TQY_DESTAT) + STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU+ " !" , STR0004) //"O EQUIPAMENTO "###" ESTÁ "###"GPO - GRCONTR.PRW"
													EndIf
													RETURN
												EndIf
											ENDIF
										CASE TQY->TQY_STTCTR <> "00"  .and. !empty(ST9->T9_STATUS)
											//Ferramenta Migrador de Contratos
											If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
												cLocErro := STR0024 + ALLTRIM(ST9->T9_CODBEM) + STR0029 + ALLTRIM(FPA->FPA_OBRA) + STR0152+ FPA->FPA_SEQGRU + STR0030 + ALLTRIM(TQY->TQY_DESTAT) + "!"+CRLF //"O equipamento "
											Else
												MSGALERT(STR0024 + ALLTRIM(ST9->T9_CODBEM) + STR0029 + ALLTRIM(FPA->FPA_OBRA) + STR0152+ FPA->FPA_SEQGRU+ STR0030 + ALLTRIM(TQY->TQY_DESTAT) + "!" , STR0004) //"O EQUIPAMENTO "###" LOCALIZADO NA OBRA "###" ESTÁ COM O STATUS "###"GPO - GRCONTR.PRW"
											EndIf
											RETURN

										ENDCASE
									else
										DBSELECTAREA("FQD")
										FQD->(DBSETORDER(2)) //"FQD_FILIAL+FQD_STATQY"
										FQD->(DBGOTOP())
										FQD->(DBSEEK(XFILIAL("FQD") + ST9->T9_STATUS))
										DO CASE
										CASE ALLTRIM(ST9->T9_SITBEM) == "I"
											//Ferramenta Migrador de Contratos
											If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
												cLocErro := STR0024 + alltrim(ST9->T9_CODBEM) + " - " + Alltrim(ST9->T9_NOME) + STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU + STR0025 + CRLF + CRLF + STR0026 + FPA->FPA_OBRA+CRLF //"O equipamento "
											Else
												MSGALERT(STR0024 + ALLTRIM(ST9->T9_CODBEM) + " - " + ALLTRIM(ST9->T9_NOME)+ STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU + STR0025 + CRLF + CRLF + ; //"O EQUIPAMENTO "###" ESTÁ INATIVO!"
												STR0026 + FPA->FPA_OBRA) //"OBRA:"
											EndIf
											RETURN
										CASE FQD->FQD_STAREN $ "10#20#30#40#50" .AND. EMPTY(ALLTRIM(FPA->FPA_AS)) .and. !empty(ST9->T9_STATUS)
											_CQUERY := " SELECT COUNT(*) QTDLOC"
											_CQUERY += " FROM " + RETSQLNAME("FPA") + " ZAG "
											_CQUERY +=        " INNER JOIN " + RETSQLNAME("FQ5") + " DTQ"
											_CQUERY +=                   " ON  FQ5_FILORI = FPA_FILIAL"
											_CQUERY +=                   " AND FQ5_AS     = FPA_AS"
											_CQUERY +=                   " AND FQ5_STATUS <> '9'"
											_CQUERY +=                   " AND DTQ.D_E_L_E_T_ = ''"
											_CQUERY +=        " INNER JOIN " + RETSQLNAME("ST9") + " ST9"
											_CQUERY +=                   " ON  T9_CODBEM = FPA_GRUA"
											_CQUERY +=                   " AND ST9.D_E_L_E_T_ = ''"
											_CQUERY +=        " INNER JOIN " + RETSQLNAME("FQD") + " FQD"
											_CQUERY +=                   " ON  FQD_STATQY = T9_STATUS"
											_CQUERY +=                   " AND FQD_STAREN IN ('10','20','30','40','50')"
											_CQUERY +=                   " AND FQD.D_E_L_E_T_ = ''"
											_CQUERY += " WHERE FPA_GRUA <> ''"
											_CQUERY +=   " AND FPA_GRUA = ? "
											_CQUERY +=   " AND FPA_FILIAL + FPA_PROJET <> ? "
											_CQUERY +=   " AND FPA_NFRET = ''"
											_CQUERY +=   " AND ZAG.D_E_L_E_T_ = ''"
											IF SELECT("TRBVLD") > 0
												TRBVLD->(DBCLOSEAREA())
											ENDIF
											_CQUERY := CHANGEQUERY(_CQUERY)
											aBindParam := {ST9->T9_CODBEM, FPA->FPA_FILIAL + FPA->FPA_PROJET }
											MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)

											IF TRBVLD->QTDLOC == 0
												TRBVLD->(DBCLOSEAREA())
												FPA->(DBSKIP())
												LOOP
											ELSE
												_lBloq := .F.
												If TRBVLD->QTDLOC > 0
													_lBloq := .T.
												EndIf
												TRBVLD->(DBCLOSEAREA())
												If _lBloq
													//Ferramenta Migrador de Contratos
													If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
														cLocErro := STR0024 + alltrim(ST9->T9_CODBEM) + " - " + alltrim(ST9->T9_NOME)+ STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU + STR0028 + alltrim(TQY->TQY_DESTAT) + "!"+CRLF //"O equipamento "
													Else
														MSGALERT(STR0024 + ALLTRIM(ST9->T9_CODBEM) + " - " + ALLTRIM(ST9->T9_NOME)+ STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU + STR0028 + ALLTRIM(TQY->TQY_DESTAT) + "!" , STR0004) //"O EQUIPAMENTO "###" ESTÁ "###"GPO - GRCONTR.PRW"
													EndIf
													RETURN
												EndIf
											ENDIF
										CASE FQD->FQD_STAREN <> "00"  .and. !empty(ST9->T9_STATUS)
											//Ferramenta Migrador de Contratos
											If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
												cLocErro := STR0024 + ALLTRIM(ST9->T9_CODBEM) + STR0029 + ALLTRIM(FPA->FPA_OBRA) + STR0152+ FPA->FPA_SEQGRU+ STR0030 + ALLTRIM(TQY->TQY_DESTAT) + "!"+CRLF //"O equipamento "
											Else
												MSGALERT(STR0024 + ALLTRIM(ST9->T9_CODBEM) + STR0029 + ALLTRIM(FPA->FPA_OBRA)  + STR0152+ FPA->FPA_SEQGRU + STR0030 + ALLTRIM(TQY->TQY_DESTAT) + "!" , STR0004) //"O EQUIPAMENTO "###" LOCALIZADO NA OBRA "###" ESTÁ COM O STATUS "###"GPO - GRCONTR.PRW"
											EndIf
											RETURN
										
										ENDCASE

									EndIF

								ENDIF
							ENDIF
						ENDIF
					ELSE
						//Ferramenta Migrador de Contratos
						cErro := STR0155 + ALLTRIM(FPA->FPA_PRODUT) + STR0026 + FPA->FPA_OBRA + STR0152+ FPA->FPA_SEQGRU + STR0031 //"Obra:"
						If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"

							cLocErro := cErro + CRLF //"O produto"
						Else
							MSGALERT(cErro , STR0004) //"O EQUIPAMENTO "###" NÃO FOI ENCONTRADO!"###"GPO - GRCONTR.PRW" //"O produto"
						EndIf
						RETURN
					ENDIF
				ENDIF
				FPA->(DBSKIP())
			ENDDO

		ENDIF

		If lBlqTae .and. lExibeTae
			Help(Nil,	Nil,STR0004+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0170,1,0,Nil,Nil,Nil,Nil,Nil,; //"O contrato não será gerado por falta de assinatura dos documentos."
			{cRetTae})
		EndIf

		IF FPA->(DBSEEK(XFILIAL("FPA") + FP0->FP0_PROJET))
			WHILE _LGERAR .AND. FPA->(!EOF()) .AND. FPA->FPA_FILIAL == FP0->FP0_FILIAL .AND. FPA->FPA_PROJET == FP0->FP0_PROJET
				IF !EMPTY(ALLTRIM(FPA->FPA_NFRET))
					FPA->(DBSKIP())
					LOOP
				ENDIF

				IF FPA->FPA_TIPOSE $ "MO" .OR. !EMPTY(FPA->FPA_AS)
					_LGERAR := .T.
				ELSE
					CCONDPAG := FPA->FPA_CONPAG							// CONDICAO PAGAMENTO
					NPOS := ASCAN(AITPED, {|X| ALLTRIM(X[1]) == FPA->FPA_PRODUT } )
					NPOS := ASCAN(AITPED, {|X| ALLTRIM(X[1]) == FPA->FPA_PRODUT } )
					IF FPA->FPA_TIPOSE <> 'M' 							// SE FOR MÃO OBRA NÃO GERAR ITEM NO PEDIDO DE VENDA
						IF NPOS == 0
							AADD(AITPED , {FPA->FPA_PRODUT,IIF(FP0->FP0_TIPOSE == 'L',FPA->FPA_PREDIA,FPA->FPA_THORAS),FPA->FPA_VRHOR,IIF(FP0->FP0_TIPOSE == 'P',(FPA->FPA_VRHOR*FPA->FPA_PREDIA),(FPA->FPA_VRHOR*FPA->FPA_THORAS)),FPA->FPA_GRUA, FPA->FPA_OBRA, FPA->FPA_SEQGRU, FPA->FPA_AS, FPA->FPA_CACAMB}) //FPA->FPA_THORAS
						ELSE
							AITPED[NPOS][2] += IIF(FP0->FP0_TIPOSE == 'L',FPA->FPA_PREDIA,FPA->FPA_THORAS)
							AITPED[NPOS][3] := FPA->FPA_VRHOR
							AITPED[NPOS][4] := FPA->FPA_VRHOR * AITPED[NPOS][2]
							AITPED[NPOS][5] := FPA->FPA_GRUA
						ENDIF

					ENDIF
					NALIISS := FPA->FPA_PERISS 							// ALIQUOTA DO ISS
				ENDIF

				//IF ! LOCA05917(FPA->FPA_GRUA , FPA->FPA_AS , DTOS(FPA->FPA_DTINI) , DTOS(FPA->FPA_DTENRE) , , , FPA->FPA_HRINI , FPA->FPA_HRFIM)	// FUNÇÃO DO MAICKON QUE VERIFICA SE TEM CONFLITO DE DATAS
				If !LOCA04819(FPA->FPA_GRUA,DTOS(FPA->FPA_DTINI),DTOS(FPA->FPA_DTENRE),FPA->FPA_HRINI,FPA->FPA_HRFIM,FPA->FPA_AS,.T.) // FUNÇÃO PARA VERIFICAR SE TEM CONFLITO DE DATAS
					lInforma := .T.
					_LGERAR := .T.
				ENDIF
				CTPISS := FPA->FPA_TPISS
				FPA->(DBSKIP())
			ENDDO
		EndIf

	ENDCASE

	If lBlqTae 
		_LGERAR := .F.
	EndIf

	IF _LGERAR .AND. FP0->FP0_TIPOSE == "L" .AND. FP0->FP0_STATUS == "1" .AND. MV_LOCX020

		DBSELECTAREA("SA3")
		SA3->(DBSETORDER(1))
		SA3->(DBSEEK(XFILIAL("SA3") + FP0->FP0_VENDED))

		DBSELECTAREA("FPA")
		FPA->(DBSETORDER(1))
		IF FPA->(DBSEEK(XFILIAL("FPA") + FP0->FP0_PROJET))
			WHILE FPA->(!EOF()) .AND. FPA->FPA_FILIAL == FP0->FP0_FILIAL .AND. FPA->FPA_PROJET == FP0->FP0_PROJET

				IF !EMPTY(ALLTRIM(FPA->FPA_AS))
					DBSELECTAREA("FQ5")
					FQ5->(dbOrderNickName("ITUPFQ500L")) // pelo número da AS
					IF FQ5->(DBSEEK(XFILIAL("FQ5") + FPA->FPA_AS))
						IF FQ5->FQ5_STATUS <> "9"
							FPA->(DBSKIP())
							LOOP
						ENDIF
					ENDIF
				ENDIF

				_NDESCVEN := 0 //SA3->A3_XPDESC
				FPA->(DBSKIP())
			ENDDO
		ENDIF

		IF RECLOCK("FP0",.F.)
			FP0->FP0_STATUS := "3" 		// APROVADO
			FP0->(MSUNLOCK())
		ENDIF
	ENDIF

	LOK := _LGERAR

	IF _LGERAR
		IF LCLIENTE														// PROCESSO DE LIFT
			CCODCLI := FP0->FP0_CLI		//ACLI[1]
			CLOJCLI := FP0->FP0_LOJA	//ACLI[2]
			CREVISA := FP0->FP0_REVISA

			// --> ATUALIZA O STATUS DO PROJETO NO COMERCIAL
			IF FP0->FP0_TIPFAT == "L" .AND. LEN(_AREGS) == 0
				//Ferramenta Migrador de Contratos
				If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
					cLocErro := STR0041+CRLF //"Não existem registros para geração do contrato!"
				Else
					MSGSTOP(STR0041 , STR0004) //"NAO EXISTEM REGISTROS PARA GERAÇÃO DO CONTRATO!"###"GPO - GRCONTR.PRW"
				EndIf
				RETURN(.F.)
			ENDIF

			INCPROC(STR0042) //"ATUALIZANDO STATUS DA PROPOSTA."
			RECLOCK("FP0",.F.)
			//05/12/2022 - Jose Eulalio -  SIGALOC94-534 - Colocar uma tela de seleção de geração de AS (DTQ)
			If lPergGerAs
				cStatGerAs := "5" //finalizado
				For _nY := 1 To Len(aGeraAs)
					If !(aGeraAs[_nY][1])
						//Em 12/12/2022 Lui definiu para gravar como STATUS "5"
						//cStatGerAs := "1" //digitação
						cStatGerAs := "5" //digitação
						Exit
					EndIf
				Next _nY
				FP0->FP0_STATUS := cStatGerAs
			Else
				FP0->FP0_STATUS := "5"
			EndIf								// MUDA STATUS PARA FINALIZADO
			FP0->(MSUNLOCK())

			ST9->(DBSETORDER(1))										// --> INDICE 01: T9_FILIAL  + T9_CODBEM
			FPA->(DBSETORDER(1))										// --> INDICE 01: FPA_FILIAL + FPA_PROJET + FPA_OBRA + FPA_SEQGRU + FPA_CNJ
			FQ5->(DBSETORDER(1))										// --> INDICE 01: FQ5_FILIAL + FQ5_VIAGEM
			TQY->(DBSETORDER(1)) 										// --> INDICE 01: TQY_FILIAL + TQY_STATUS

			IF FPA->(DBSEEK(XFILIAL("FPA") + FP0->FP0_PROJET))
				WHILE FPA->(!EOF()) .AND. FPA->FPA_PROJET == FP0->FP0_PROJET
					//05/12/2022 - Jose Eulalio -  SIGALOC94-534 - Colocar uma tela de seleção de geração de AS (DTQ)
					If lPergGerAs .And. !IsGeraAs(aGeraAs,FP0->FP0_PROJET,FPA->FPA_OBRA,FPA->FPA_SEQGRU) .And. &('!(Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C")')
						FPA->(DBSKIP())
						LOOP
					EndIf

					SB1->( MSSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT) )
					IF FPA->FPA_TIPOSE == "L"  .AND.  ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) 		// !(ALLTRIM(GETADVFVAL("SB1", "B1_GRUPO",XFILIAL("SB1")+FPA->FPA_PRODUT,1,"")) $ ALLTRIM(SUPERGETMV("MV_LOCX014",.F.,"")))
						iF !Empty(FPA->FPA_GRUA)
						IF ST9->(DBSEEK(XFILIAL("ST9") + FPA->FPA_GRUA)) .AND. EMPTY(ALLTRIM(FPA->FPA_NFREM))
							If !empty(ST9->T9_STATUS)

								If !lMvLocBac
									IF TQY->(DBSEEK(XFILIAL("TQY")+ST9->T9_STATUS))
										IF TQY->TQY_STTCTR == "00"
											TQY->(DBGOTOP())
											WHILE TQY->(!EOF())  .AND.  TQY->TQY_STTCTR <> "10" 				// STATUS DE GERAR CONTRATO
												TQY->(DBSKIP())
											ENDDO
											IF TQY->TQY_STTCTR == "10"
												LOCXITU21(ST9->T9_STATUS,TQY->TQY_STATUS,FPA->FPA_PROJET,"","")
												RECLOCK("ST9",.F.)
												ST9->T9_STATUS := TQY->TQY_STATUS
												ST9->(MSUNLOCK())
											ELSE
												MSGALERT(STR0043, STR0004)  //"NÃO FOI ENCONTRADO O STATUS 10 NO CADASTRO. FAVOR REALIZAR O REGISTRO DO MESMO PARA PROSSEGUIR."###"GPO - GRCONTR.PRW"
											ENDIF
										ENDIF
									ENDIF
								else
									IF FQD->(DBSEEK(XFILIAL("FQD")+ST9->T9_STATUS))
										IF FQD->FQD_STAREN == "00"
											FQD->(DBGOTOP())
											WHILE FQD->(!EOF())  .AND.  FQD->FQD_STAREN <> "10" 				// STATUS DE GERAR CONTRATO
												FQD->(DBSKIP())
											ENDDO
											IF FQD->FQD_STAREN == "10"
												LOCXITU21(ST9->T9_STATUS,FQD->FQD_STATQY,FPA->FPA_PROJET,"","")
												RECLOCK("ST9",.F.)
												ST9->T9_STATUS := FQD->FQD_STATQY
												ST9->(MSUNLOCK())
											ELSE
												MSGALERT(STR0043, STR0004)  //"NÃO FOI ENCONTRADO O STATUS 10 NO CADASTRO. FAVOR REALIZAR O REGISTRO DO MESMO PARA PROSSEGUIR."###"GPO - GRCONTR.PRW"
											ENDIF
										ENDIF
									ENDIF
								EndIF

							EndIF
						ENDIF
						endif
						IF !EMPTY(ALLTRIM(FPA->FPA_AS))  .AND.  EMPTY(ALLTRIM(FPA->FPA_NFREM))
							DBSELECTAREA("FQ5")
							FQ5->(DBSETORDER(9))
							IF FQ5->(DBSEEK(XFILIAL("FQ5") + FPA->FPA_AS + FPA->FPA_VIAGEM))
								IF ALLTRIM(FQ5->FQ5_GUINDA) <> ALLTRIM(FPA->FPA_GRUA) .AND. !EMPTY(ALLTRIM(FQ5->FQ5_GUINDA))
									DBSELECTAREA("ST9")
									ST9->(DBSETORDER(1))
									IF ST9->(DBSEEK(XFILIAL("ST9") + FQ5->FQ5_GUINDA))
										If !empty(ST9->T9_STATUS)

											If !lMvLocBac
												IF SELECT("TRBTQY") > 0
													TRBTQY->(DBCLOSEAREA())
												ENDIF
												CQUERY := " SELECT TQY_STATUS "
												CQUERY += " FROM " + RETSQLNAME("TQY") + " TQY "
												CQUERY += " WHERE  TQY.TQY_STTCTR = '00' "
												CQUERY +=   " AND  TQY.D_E_L_E_T_ = '' "
												CQUERY := CHANGEQUERY(CQUERY)
												TCQUERY CQUERY NEW ALIAS "TRBTQY"

												IF ! TRBTQY->(EOF())
													LOCXITU21(ST9->T9_STATUS,TRBTQY->TQY_STATUS,FPA->FPA_PROJET,"","",.T.)
													IF RECLOCK("ST9",.F.)
														ST9->T9_STATUS := TRBTQY->TQY_STATUS
														ST9->(MSUNLOCK())
													ENDIF
													IF RECLOCK("FQ5",.F.)
														FQ5->FQ5_GUINDA := FPA->FPA_GRUA
																FQ5->FQ5_STATUS := "1"
														FQ5->(MSUNLOCK())

														IF _MV_LOC207 //SUPERGETMV("MV_LOCX207",,.F.) // Não Gera Atualizado
															if !LOCA013C(CGRPAND) // !Encontrou algo que não permite aceitar AS Automaticamente
																aAreaFPA := FPA->(GetArea())
																LOCA05908()
																RestArea(aAreaFPA)
															endif
														ENDIF

													ENDIF
												EndIF
												TRBTQY->(DBCLOSEAREA())
											else
												IF SELECT("TRBTQY") > 0
													TRBTQY->(DBCLOSEAREA())
												ENDIF
												CQUERY := " SELECT FQD_STATQY "
												CQUERY += " FROM " + RETSQLNAME("FQD") + " FQD "
												CQUERY += " WHERE  FQD.FQD_STAREN = '00' "
												CQUERY +=   " AND  FQD.D_E_L_E_T_ = '' "
												CQUERY := CHANGEQUERY(CQUERY)
												TCQUERY CQUERY NEW ALIAS "TRBTQY"

												IF ! TRBTQY->(EOF())
													LOCXITU21(ST9->T9_STATUS,TRBTQY->FQD_STATQY,FPA->FPA_PROJET,"","",.T.)
													IF RECLOCK("ST9",.F.)
														ST9->T9_STATUS := TRBTQY->FQD_STATQY
														ST9->(MSUNLOCK())
													ENDIF
													IF RECLOCK("FQ5",.F.)
														FQ5->FQ5_GUINDA := FPA->FPA_GRUA
															FQ5->FQ5_STATUS := "1"
														FQ5->(MSUNLOCK())

														IF _MV_LOC207 //SUPERGETMV("MV_LOCX207",,.F.) // Não Gera Atualizado
															if !LOCA013C(CGRPAND) // !Encontrou algo que não permite aceitar AS Automaticamente
																aAreaFPA := FPA->(GetArea())
																LOCA05908()
																RestArea(aAreaFPA)
															endif
														ENDIF

													ENDIF
												EndIF
												TRBTQY->(DBCLOSEAREA())
											EndIF
										ENDIF

									ENDIF
								ENDIF
							ENDIF
						ENDIF

					ENDIF
					FPA->(DBSKIP())
				ENDDO
			ENDIF

			if lMvLocx307 
				if lLOCX305 // Tem Alocação automatica não tem Minuta e tem aceita sem equipamento
					Aviso(STR0161, STR0160+Alltrim(Str(aAloca[1]))+ STR0163+Alltrim(Str(aAloca[2]))+ STR0162) //"Foram alocados Equipamentos em " //"Alocacao de Ativos" //" não foram " //" linhas e "
				else
					Aviso(STR0161, STR0160+Alltrim(Str(aAloca[1]))+ STR0163+Alltrim(Str(aAloca[2]))+ STR0164) //" linhas e " //" linhas não foram geradas AS por falta de equipamentos disponíveis" //"Alocacao de Ativos" //"Foram alocados Equipamentos em "
				endif
			endif

			//	--> LIBERAR VALOR DO DESCONTO
			IF LEN(ADESCON) > 0
				FOR _NX := 1 TO LEN(ADESCON)
					LOCA042(ADESCON[_NX][1] , CNUMSC5 , ADESCON[_NX][6] , CCODCLI , CLOJCLI , ADESCON[_NX][2] , ADESCON[_NX][7] , "S")
				NEXT _NX
			ENDIF

			CCONTRATO := ALLTRIM(STRTRAN(FP0->FP0_PROJET,"/",""))

			// --> CRIA UM CONTRATO NO TMS PARA ESSA PROPOSTA
			INCPROC(STR0047) //"CRIANDO CLASSE DE VALOR.."
			LOCA01307( ALLTRIM(CODCLVAL(CCONTRATO))+"T" , "1" , SUBSTR(FP0->FP0_CLINOM,1,25) , "" )
			LOCA01307( ALLTRIM(CODCLVAL(CCONTRATO))     , "2" , SUBSTR(FP0->FP0_CLINOM,1,25) , CODCLVAL(ALLTRIM(CCONTRATO))+"T" )

			// --> CRIA UMA AS / VIAGEM NO TMS PARA ESSA PROPOSTA
			INCPROC(STR0048) //"CRIANDO AS A.S. E VIAGENS "
			//LOCA01302( CCONTRATO , CCODCLI , CLOJCLI , FP0->FP0_PROJET )
			LOCA01302( CCONTRATO , CCODCLI , CLOJCLI , FP0->FP0_PROJET, lPergGerAs , aGeraAs, CGRPAND )

			// DSERLOCA-6564 - Frank em 04/07/2025
			// Tratamento da geração do título provisório pelo campo FP0_PROV
			If FP0->(FieldPos("FP0_PROV")) > 0
				If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
					_MV_LOC278 := .T.
				Else
					_MV_LOC278 := .F.
				EndIf
			EndIf
			
			If _MV_LOC278
				INCPROC(STR0123) //"Alocando equipamentos e gerando os titulos provisorios."
			Else
				INCPROC(STR0124) //"Alocando equipamentos."
			EndIf
			SysRefresh()

			// Geracao dos titulos provisorios - Frank 17/03/2021
			If _MV_LOC278 //supergetmv("MV_LOCX278",,.F.)

				// Atualização do campo parcela.
				Processa({|| aRet := LOCA24819()},STR0203)

				If !GerPRx()
					Return .f.
				EndIF

			EndIf

			IF LEN(_AREGS) > 0
				ENVMLIFT(_AREGS)
			ENDIF

			// --> GERA A OCORRENCIA  E A CAMPANHA
			LIMPRI     := .T.	// VAI IMPRIMIR MAIS DE UMA VEZ QUANDO O PROJETO NÃO FOR UNIFICADO
			LUNIFICADO := .T.	// PARA NÃO TRAZER A PERGUNTA DE PESQUISA POR PROJETO NOVAMENTE

			IF FP0->FP0_TIPOSE == "L" // LOCAÇÃO

				DBSELECTAREA("FP1")
				DBSETORDER(3)
				DBSEEK(XFILIAL("FP1")+FP0->FP0_PROJET)

				DBSELECTAREA("FPA")
				DBSETORDER(4)
				DBSEEK(XFILIAL("FPA")+FP0->FP0_PROJET)

				WHILE !FPA->(EOF()) .AND. FP0->FP0_PROJET = FPA->FPA_PROJET
					IF ALLTRIM(FP1->FP1_TEMVIS) $ "S" .AND. ALLTRIM(FPA->FPA_TIPOSE) <> "Z"
						//ATUALIZA SUO//
						CTIPO:="9"
					ELSEIF ALLTRIM(FPA->FPA_TIPOSE) <> "Z"
						CTIPO:="3"
					ELSE
						CTIPO:="6"
					ENDIF

					LIMPRI := .F.

					LUNIFICADO := .F.

					FPA->(DBSKIP())
				ENDDO
			ENDIF
			// FIM GERA OCORRENCIA

			CQUERY := " SELECT * "
			CQUERY += " FROM " + RETSQLNAME("FQ5") + " DTQ"
			CQUERY += " WHERE FQ5_SOT = ? "
			CQUERY += "    AND DTQ.D_E_L_E_T_ = ''"
			IF SELECT("TRBFQ5") > 0
				TRBFQ5->(DBCLOSEAREA())
			ENDIF
			CQUERY := CHANGEQUERY(CQUERY)
			aBindParam := {FP0->FP0_PROJET}
			MPSysOpenQuery(cQuery,"TRBFQ5",,,aBindParam)

			IF ! TRBFQ5->(EOF())
				RECLOCK("FP0",.F.)
				FP0->FP0_DATAS  := DDATABASE		// GRAVO A DATA DA GERAÇÃO DA AS
				FP0->(MSUNLOCK())
				If _lMens
					//Ferramenta Migrador de Contratos
					If _lPassa2 //!( Type("lLocAuto") == "L" .And. lLocAuto)
						MSGINFO(STR0049 , STR0004) //"CONTRATO GERADO COM SUCESSO!"###"GPO - GRCONTR.PRW"
					EndIf
				EndIF
			ELSE
				If _lMens
					//Ferramenta Migrador de Contratos
					If _lPassa //Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C"
						cLocErro := STR0050 + CRLF //"Não existem A.S a serem geradas para esse contrato"
					Else
						MSGINFO(STR0050 , STR0004) //"NÃO EXISTEM A.S A SEREM GERADAS PARA ESSE CONTRATO"###"GPO - GRCONTR.PRW"
					EndIf
				EndIF
				RECLOCK("FP0",.F.)
				FP0->FP0_STATUS  := '1'
				FP0->(MSUNLOCK())
			ENDIF

			// --> DISPARA UM EMAIL PARA O COMERCIAL PARA AVISAR A GERAÇÃO DA AS NO SISTEMA
			CCC	 	:= SPACE(100)
			CCCO 	:= SPACE(100)
			CMSG1   := ""
			CPARA 	:= SPACE(100)
			CTITULO	:= SPACE(100)
			EFROM 	:= ALLTRIM(GETMV("MV_RELFROM")) //ALLTRIM(USRRETNAME(RETCODUSR())) + "<" + ALLTRIM(USRRETMAIL(RETCODUSR())) + ">"
			_CFIL	:= RIGHT(ALLTRIM(FQ5->FQ5_AS),2)
			_CTIPOAS := "AS "
			CPARA := ""

			IF LEN(AASNOVA) > 0 // SE NAO É REVISÃO //.F. // TRATAMENTO ANTERIOR
				FOR N:=1 TO LEN(AASNOVA)
					CANEXO   := ""
					CASFRETES:= ""

					FQ5->(DBGOTO(AASNOVA[N]))
					IF FQ5->FQ5_TPAS <> 'F'
						CMSG    := STR0051 + CHR(13)+CHR(10) //"ESTE EMAIL É PARA INFORMAR QUE FOI GERADA NO SISTEMA A AS:"
						CTITULO := STR0052 + FQ5->FQ5_AS //"GERACAO AS: "
						CMSG    += CTITULO + CRLF
					ELSEIF FQ5->FQ5_TPAS == 'F'
						CMSG    := STR0053 + CHR(13)+CHR(10) //"ESTE EMAIL É PARA INFORMAR QUE FOI GERADA NO SISTEMA A ASF:"
						CTITULO := STR0054 + FQ5->FQ5_AS //"GERACAO ASF: "
						CMSG    += CTITULO + CHR(13) + CHR(10)
						CMSG    += STR0055 + GETASORI(FQ5->FQ5_VIAGEM) + CHR(13) + CHR(10) //"NRO. AS: "
						CASFRETES := FQ5->FQ5_AS
					ENDIF

					DO CASE
						CASE FP0->FP0_TIPOSE == "L"		// AS DE LOCAÇÃO
							// --> POSICIONO NA ZA1-OBRAS
							DBSELECTAREA("FP1")
							DBSETORDER(1)
							DBSEEK(XFILIAL("FP1") + FQ5->FQ5_SOT + FQ5->FQ5_OBRA)

							// --> POSICIONA NA ZAG-GRUAS X PROJETO
							DBSELECTAREA("FPA")
							DBSETORDER(2)
							DBSEEK(XFILIAL("FPA") +  FQ5->FQ5_SOT + FQ5->FQ5_OBRA + FQ5->FQ5_AS +FQ5->FQ5_VIAGEM)
							IF     FQ5->FQ5_TPAS <> 'F'
								CMSG += CHR(13) + CHR(10)
								CMSG += STR0056 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"LOCAL DO SERVIÇO"
								CMSG += STR0012 + FQ5->FQ5_NOMCLI + CHR(13) + CHR(10) //"CLIENTE "
								CMSG += STR0065 + FP1->FP1_NOMORI 	+ CHR(13) + CHR(10) //"OBRA   "
								CMSG += STR0066 + FP1->FP1_MUNORI	+ CHR(13) + CHR(10) //"CIDADE "
								CMSG += STR0067 + FP1->FP1_ESTORI	+ CHR(13) + CHR(10) + CHR(13) + CHR(10) //"ESTADO "
								CMSG += STR0064 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"EQUIPAMENTO"
								CMSG +=  ALLTRIM(FPA->FPA_GRUA) + " - " + ALLTRIM(FPA->FPA_DESGRU)
							ELSEIF FQ5->FQ5_TPAS == "F"
								CPARA  := _MV_LOC155 //GETMV("MV_LOCX155",,"")
								CANEXO := CASFRETES + ".PDF"
								CANEXO := ""
							ENDIF
					ENDCASE

					IF EMPTY(EFROM) .OR. EMPTY(CPARA)
						//	MSGINFO("EMAIL NÃO CADASTRADO, FAVOR VERIFICAR." , "GPO - GRCONTR.PRW")
					ELSE
						IF LEN(CMSG) > 0
							LOCA01313( EFROM, CPARA , CCC, CTITULO, CMSG, CANEXO, CCCO)
						ENDIF
						IF !EMPTY(CANEXO)
							FERASE(CANEXO)
						ENDIF
					ENDIF
				NEXT N
			ELSE
				DBSELECTAREA("FP1")
				DBSETORDER(1)
				DBSEEK(XFILIAL("FP1")+FP0->FP0_PROJET)
				CAUX := ""
				FOR _NT := 1 TO LEN(AASREV)
					CAUX += IIF(!EMPTY(CAUX),', ','') + ALLTRIM(STR(AASREV[_NT],12,0))
				NEXT _NT

				F_ASEMAIL(FP0->FP0_PROJET,FP0->FP0_TIPOSE, CAUX /*CAUX*/)
				CMSG := CMSG1

				IF (EMPTY(EFROM) .OR. EMPTY(CPARA))
					if _lMens
						//MSGINFO(STR0070 , STR0004) //"EMAIL NÃO CADASTRADO, FAVOR VERIFICAR."###"GPO - GRCONTR.PRW"
						//conout(STR0070)
					EndIF
				ELSE
					CMSG    := STR0051 + CHR(13)+CHR(10) //"ESTE EMAIL É PARA INFORMAR QUE FOI GERADA NO SISTEMA A AS:"
					CTITULO := STR0052 + FQ5->FQ5_AS //"GERACAO AS: "
					CMSG    += CTITULO + CHR(13) + CHR(10)
					IF LEN(CMSG) > 0
						LOCA01313(EFROM, CPARA, CCC, CTITULO, CMSG, CANEXO, CCCO)
					ENDIF
					IF !EMPTY(CANEXO)
						FERASE(CANEXO)
					ENDIF
				ENDIF
			ENDIF
		ELSE
			MSGINFO(STR0071 , STR0004) //"VERIFICAR CNPJ/CPF DO CLIENTE"###"GPO - GRCONTR.PRW"
		ENDIF

	ELSE

		IF LEN(AERROSZBX)>0
			IF MSGYESNO(STR0072) //"PROPOSTA NÃO PODE SER CONFIRMADA. DESEJA VISUALIZAR OS ERROS ??"
				LOCA00516(AERROSZBX,STR0073)  //VISUALIZA OS ERROS //"ERROS"
			ENDIF
		ELSE
			If lInforma
				MSGSTOP(STR0074 + " " + STR0129 , STR0004) //"PROPOSTA NÃO PODE SER CONFIRMADA !"###"GPO - GRCONTR.PRW"
			Else
				MSGSTOP(STR0074 , STR0004) //"PROPOSTA NÃO PODE SER CONFIRMADA !"###"GPO - GRCONTR.PRW"
			EndIF
		ENDIF

	ENDIF

	DBSELECTAREA("FP0")

	INCLUI  := LINCBKP
	ALTERA  := LALTBKP
	AROTINA := AROTBKP

RETURN .T.

// ======================================================================= \\
//FUNCTION LOCA01302( CCONTRATO , CCODCLI , CLOJCLI , CPROJETO )
FUNCTION LOCA01302( CCONTRATO , CCODCLI , CLOJCLI , CPROJETO , lPergGerAs , aGeraAs, CGRPAND)
// ======================================================================= \\
Local AAREA      := GETAREA()
Local NSEQGUI	   := 1
Local CSEG   	   := ""		// A ROTINA PRECISA PASSAR CORRETAMENTE PARA TRATARMOS
Local CVIAGEM	   := ""
Local CNRAS	   := ""
Local _LNOFROTA  := .F.
Local _LVLDEQUIP := SUPERGETMV("MV_LOCX257",.F.,.T.)
Local XIT        := 0
Local _GRCONTR_ := EXISTBLOCK( "GRCONTR_" )
Local _MV_LOC207 := SUPERGETMV("MV_LOCX207",,.F.)
Local lFQ5
Local lLOCX305	:= SuperGetMV("MV_LOCX305",.F.,.T.) //Define se aceita geração de contrato sem equipamento
Local lASNova   := .F. // Indica se a AS foi incluida ou não
Local aSavFPA   :={} // Salva a posição da FPA antes do Aceite da AS

Private CORIGEM , CDESTINO , CCONDPAG , CDESCCON , NPERADV
Private AREGSDTQ   := {}
Private NVIAGEM    := 0
private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CGRPAND := LOCA00189()
	ELSE
		CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
	ENDIF

	FP1->(DBSETORDER(1))
	FP1->(DBSEEK(XFILIAL("FP1")+CPROJETO))

	WHILE FP1->(!EOF()) .AND. FP1->FP1_FILIAL+FP1->FP1_PROJET == XFILIAL("FP1")+CPROJETO

		// --> APURA OS SERVICOS DE LOCACAO QUE DEVERAO SER CRIADOS COMO VIAGENS NO DTQ
		NSEQGUI	:= 1

		LOCA01307( ALLTRIM(CODCLVAL(CCONTRATO))+FP1->FP1_OBRA+"T" , "1" , SUBSTR(FP1->FP1_NOMORI,1,25) , CODCLVAL(ALLTRIM(CCONTRATO)) )
		LOCA01307( ALLTRIM(CODCLVAL(CCONTRATO))+FP1->FP1_OBRA     , "1" , SUBSTR(FP1->FP1_NOMORI,1,25) , CODCLVAL(ALLTRIM(CCONTRATO))+FP1->FP1_OBRA+"T" )

		FP4->(DBSETORDER(1))
		FP4->(DBSEEK(XFILIAL("FP4")+CPROJETO+FP1->FP1_OBRA))

		WHILE FP4->(!EOF()) .AND. FP4->FP4_FILIAL+FP4->FP4_PROJET+FP4->FP4_OBRA == XFILIAL("FP4")+CPROJETO+FP1->FP1_OBRA

			// --> ATUALIZA A AGENDA DA FROTA.
			DO CASE
			CASE !EMPTY( FP4->FP4_GUIALO )
				CFROTA := FP4->FP4_GUIALO
			CASE !EMPTY( FP4->FP4_GUINDA )
				CFROTA := FP4->FP4_GUINDA
			OTHERWISE
				CFROTA := FP4->FP4_GUINDA
			ENDCASE

			DO CASE
			CASE  FP4->FP4_TIPOSE == "E"
				CSEG := "20"				// "02"
			CASE  FP4->FP4_TIPOSE $ "M;T"
				CSEG := "22"				// "06"
			CASE FP4->FP4_TIPOSE  == "O"
				CSEG := "29"				// "07"
			ENDCASE

			IF _LVLDEQUIP .AND. FP4->FP4_TIPOSE != "O" .AND. FP4->FP4_TIPOSE != "M" .AND. EMPTY(CFROTA)
				IF EMPTY(FP4->FP4_AS) .OR. LEFT(FP4->FP4_AS, 2) != CSEG
					_LNOFROTA := .T.
				ENDIF
				FP4->(DBSKIP())
				LOOP
			ENDIF

			IF EMPTY(FP4->FP4_AS) .OR. LEFT(FP4->FP4_AS, 2) != CSEG
				CNRAS := GERANUMAS( CSEG , CPROJETO, FP4->FP4_OBRA, NSEQGUI, FP4->FP4_FILIAL  )
			ELSE
				CNRAS := FP4->FP4_AS
			ENDIF

			CEQANT  := FP4->FP4_GUINDA
			NSEQGUI	+= 1
			CTIPOAS := GETTIPOAS(FP4->FP4_GUINDA) //"G"  // LOCACAO GUINDASTE

			CCONDPAG:=FP4->FP4_CONPAG
			CDESCCON:=POSICIONE("SE4",1,XFILIAL("SE4")+CCONDPAG,"E4_DESCRI")
			NPERADV :=0
			CINCADV :=0
			NPERICM :=0
			CINCICM :=0
			CSERVICO:= "2" //GUINDASTE
			NVLRINF := 0

			ADTQ := {}

			DBSELECTAREA("FQ5")
			DBSETORDER(8)
			IF DBSEEK(XFILIAL("FQ5") + CPROJETO + FP1->FP1_OBRA +CNRAS )
				RECLOCK("FQ5",.F.)
				CVIAGEM := FQ5->FQ5_VIAGEM

				AADD(ADTQ , {"FQ5_FILIAL" , FQ5->FQ5_FILIAL})
				AADD(ADTQ , {"FQ5_FILORI" , FQ5->FQ5_FILORI})
				AADD(ADTQ , {"FQ5_VIAGEM" , FQ5->FQ5_VIAGEM})
				AADD(ADTQ , {"FQ5_CONTRA" , FQ5->FQ5_CONTRA})
				AADD(ADTQ , {"FQ5_DATGER" , FQ5->FQ5_DATGER})
				AADD(ADTQ , {"FQ5_HORGER" , FQ5->FQ5_HORGER})

				IF FQ5->FQ5_STATUS == "7"
					AADD(ADTQ, {"FQ5_STATUS","1"})
				ENDIF
			ELSE
				// Frank em 17/10/23 - card 1227
				// coloquei um reforço lógico para evitar a numeracao repetida da viagem,
				// quando ocorria a repetição era gerado linhas em branco a fq5 e depois deletadas
				// e este erro gravava a AS na FPA sem gerar a FQ5.
				While .T.
					CVIAGEM := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
					CONFIRMSX8()
					FQ5->(dbSetOrder(1))
					If !FQ5->(dbSeek(xFilial("FQ5")+CVIAGEM))
						Exit
					EndIF
				Enddo
				RECLOCK("FQ5",.T.)

				AADD(AASNOVA, FQ5->(RECNO()))		// ADICIONA AS PARA IMPRESSÃO EM PDF

				AADD(ADTQ , {"FQ5_FILIAL" , RETFILGRV("FQ5_FILIAL")})
				AADD(ADTQ , {"FQ5_FILORI" , RETFILGRV("FQ5_FILORI")})
				AADD(ADTQ , {"FQ5_VIAGEM" , CVIAGEM})
				AADD(ADTQ , {"FQ5_CONTRA" , CPROJETO})
				AADD(ADTQ , {"FQ5_DATGER" , DDATABASE})
				AADD(ADTQ , {"FQ5_HORGER" , SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)})
				AADD(ADTQ , {"FQ5_STATUS" , "1"})
			ENDIF

			AADD(ADTQ , {"FQ5_ROTA"   , "000001"})
			AADD(ADTQ , {"FQ5_TIPVIA" , "1"})
			AADD(ADTQ , {"FQ5_DATINI" , FP4->FP4_DTINI})
			AADD(ADTQ , {"FQ5_HORINI" , FP4->FP4_HRINI})
			AADD(ADTQ , {"FQ5_DATFIM" , FP4->FP4_DTFIM})
			AADD(ADTQ , {"FQ5_HORFIM" , FP4->FP4_HRFIM})
			AADD(ADTQ , {"FQ5_SERTMS" , "2"})
			AADD(ADTQ , {"FQ5_TIPTRA" , "1"  })
			AADD(ADTQ , {"FQ5_ENCERR" , "1"})
			AADD(ADTQ , {"FQ5_NOMCLI" , FP0->FP0_CLINOM})
			AADD(ADTQ , {"FQ5_ORIGEM" , "EMPRESA"})
			AADD(ADTQ , {"FQ5_DESTIN" , FP1->FP1_MUNORI+FP1->FP1_ESTORI})
			AADD(ADTQ , {"FQ5_CONDPG" , CCONDPAG})
			AADD(ADTQ , {"FQ5_DCOND"  , CDESCCON})
			AADD(ADTQ , {"FQ5_VLRINF" , NVLRINF})
			IF ! FQ5->( FOUND() )					// SE FOR NOVO REGISTRO, INICIA COM STATUS "1"
					AADD(ADTQ , {"FQ5_STATUS","1"})
			ENDIF
			AADD(ADTQ , {"FQ5_SOT"    , CPROJETO})
			AADD(ADTQ , {"FQ5_OBRA"   , FP1->FP1_OBRA})
			AADD(ADTQ , {"FQ5_TPAS"   , CTIPOAS})
			AADD(ADTQ , {"FQ5_AS"     , CNRAS})
			AADD(ADTQ , {"FQ5_GUINDA" , FP4->FP4_GUINDA})
			AADD(ADTQ , {"FQ5_SEQVIA" , FP4->FP4_SEQGUI})
			AADD(ADTQ , {"FQ5_CODCLI" , FP0->FP0_CLI})
			AADD(ADTQ , {"FQ5_LOJA"   , FP0->FP0_LOJA})

			IF _GRCONTR_ //EXISTBLOCK( "GRCONTR_" )
				XRET := EXECBLOCK( "GRCONTR_", .T., .T., { "ANTESDTQ", @ADTQ, "FP4" } )
				IF VALTYPE( XRET ) == "A"
					ADTQ := XRET
				ENDIF
			ENDIF

			IF FQ5->FQ5_STATUS=="7" .OR. FQ5->FQ5_STATUS=="6"
				lFQ5 := .F.
			Else
				lFQ5 := .T.
			EndIF

			LRESENTEML := LOCA01310( ADTQ , FP4->FP4_VIAGEM , Nil , lFQ5 )  // INSERIDO O PARAMETRO 4 (.F.) PARA FORÇAR A ALTERAÇÃO DO STATUS
			IF LRESENTEML

				AADD(AASREV, FQ5->( RECNO() )) 	// ADICIONA AS PARA IMPRESSÃO EM PDF
				FOR XIT := 1 TO LEN(ADTQ)
					FQ5->( FIELDPUT(FIELDPOS(ADTQ[XIT][1]), ADTQ[XIT][2]) )
				NEXT XIT
			ENDIF

			FQ5->(MSUNLOCK())

			RECLOCK("FP4",.F.)
			REPLACE FP4_VIAGEM WITH CVIAGEM
			REPLACE FP4_AS     WITH CNRAS
			REPLACE FP4_DTAS   WITH IIF(EMPTY(FP4_DTAS),DDATABASE,FP4_DTAS)
			FP4->(MSUNLOCK())

			DBSELECTAREA("FP4")

			LOCA01307( ALLTRIM(CNRAS) , "2" , SUBSTR(FP1->FP1_NOMORI,1,20) , CODCLVAL(ALLTRIM(CCONTRATO))+FP1->FP1_OBRA )

			// ATUALIZA APONTADOR DE VIAGEM (CONTROLE DE OCORRÊNCIAS / DIÁRIO DE BORDO)
			LOCA00522( CPROJETO, CVIAGEM, FP0->FP0_DATINC, FP0->FP0_CLI, FP0->FP0_LOJA, FP0->FP0_CLINOM, FP4->FP4_PEDCLI, FP4->FP4_SOLICT, FP4->FP4_GUINDA )

			FP4->(DBSKIP())
		ENDDO

		// APURA OS SERVICOS DE LOCACAO QUE DEVERAO SER CRIADOS COMO VIAGENS NO DTQ
		// ========================================================================
		NSEQGRUA := 1

		FPA->(DBSETORDER(1))
		FPA->(DBSEEK(XFILIAL("FPA")+CPROJETO+FP1->FP1_OBRA))

		WHILE FPA->(!EOF()) .AND. FPA->FPA_FILIAL+FPA->FPA_PROJET+FPA->FPA_OBRA == XFILIAL("FPA")+CPROJETO+FP1->FP1_OBRA

			IF !EMPTY(ALLTRIM(FPA->FPA_NFREM))
				FPA->(DBSKIP())
				LOOP
			ENDIF

			//05/12/2022 - Jose Eulalio -  SIGALOC94-534 - Colocar uma tela de seleção de geração de AS (DTQ)
			If lPergGerAs .And. !IsGeraAs(aGeraAs,FP0->FP0_PROJET,FPA->FPA_OBRA,FPA->FPA_SEQGRU) .And. &('!(Type("lLocAuto") == "L" .And. lLocAuto .And. ValType(cLocErro) == "C")')
				FPA->(DBSKIP())
				LOOP
			EndIf

			SB1->( MSSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT) )

			if Empty(FPA->FPA_GRUA) .and. lLOCX305 = .F. .and. !ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND)
				If FPA->FPA_TIPOSE == "M"
				Else
					FPA->(DBSKIP())
					LOOP
				EndIf
			endif

			CFROTA := FPA->FPA_GRUA

			DO CASE
			CASE  FPA->FPA_TIPOSE $ "L;S"
				CSEG := "30"				// "04"
			CASE  FPA->FPA_TIPOSE $ "M;T"
				CSEG := "32"				// "04"
			CASE  FPA->FPA_TIPOSE == "Z"
				CSEG := "33"				// "04"
			CASE FPA->FPA_TIPOSE  == "O"
				CSEG := "39"				// "04"
			ENDCASE

			// comentado por frank em 14/07/21 para sempre sobrepor a numeração da AS e nao gerar uma nova
			IF EMPTY(FPA->FPA_AS) //.OR. ALLTRIM(GETADVFVAL("FQ5", "FQ5_STATUS",XFILIAL("FQ5")+CPROJETO + FPA->FPA_OBRA + FPA->FPA_AS,8,"")) == "9"
				CNRAS := GERANUMAS( /*"04"*/ CSEG , CPROJETO, FPA->FPA_OBRA, NSEQGRUA, FPA->FPA_FILIAL, FPA->FPA_SEQGRU  )
			ELSE
				CNRAS := FPA->FPA_AS
			ENDIF

			CEQANT  := FPA->FPA_GRUA
			NSEQGRUA+= 1
			CTIPOAS := FP0->FP0_TIPOSE //28.06.2011 MAICKON - INCLUIDA POIS NÃO ESTAVA GERANDO VIAGEM PARA PLATAFORMA

			CCONDPAG:=FPA->FPA_CONPAG
			CDESCCON:=POSICIONE("SE4",1,XFILIAL("SE4")+CCONDPAG,"E4_DESCRI")

			AAM->(DBSETORDER(1))
			AAM->(DBSEEK(XFILIAL("AAM")+CCONTRATO))

			CSERVICO:= "3"//3=GRUA

			ADTQ := {}

			DBSELECTAREA("FQ5")
			DBSETORDER(8)
			IF DBSEEK(XFILIAL("FQ5") + CPROJETO + FPA->FPA_OBRA + CNRAS )
				lASNova := .F.
				RECLOCK("FQ5",.F.)
				CVIAGEM:=FQ5->FQ5_VIAGEM

				AADD(ADTQ , {"FQ5_FILIAL" , FQ5->FQ5_FILIAL})
				AADD(ADTQ , {"FQ5_FILORI" , FQ5->FQ5_FILORI})
				AADD(ADTQ , {"FQ5_VIAGEM" , FQ5->FQ5_VIAGEM})
				AADD(ADTQ , {"FQ5_CONTRA" , FQ5->FQ5_CONTRA})
				AADD(ADTQ , {"FQ5_DATGER" , FQ5->FQ5_DATGER})
				AADD(ADTQ , {"FQ5_HORGER" , FQ5->FQ5_HORGER})

				IF FQ5->FQ5_STATUS == "7" .or. FQ5->FQ5_STATUS == "9" // ajustado por Frank em 14/07/21
					AADD(ADTQ, {"FQ5_STATUS","1"})
				ENDIF

				If FPA->FPA_DTINI <> FQ5->FQ5_DATINI .or. FPA->FPA_DTENRE <> FQ5->FQ5_DATFIM .or. FPA->FPA_QUANT <> FQ5->FQ5_XQTD
					AADD(ADTQ , {"FQ5_STATUS","1"})
				EndIf
			ELSE

				// Frank em 17/10/23 - card 1227
				// coloquei um reforço lógico para evitar a numeracao repetida da viagem,
				// quando ocorria a repetição era gerado linhas em branco a fq5 e depois deletadas
				// e este erro gravava a AS na FPA sem gerar a FQ5.
				While .T.
					CVIAGEM := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
					CONFIRMSX8()
					FQ5->(dbSetOrder(1))
					If !FQ5->(dbSeek(xFilial("FQ5")+CVIAGEM))
						Exit
					EndIF
				Enddo

				RECLOCK("FQ5",.T.)
				lASNova := .T.
				AADD(AASNOVA, FQ5->(RECNO()))		// ADICIONA AS PARA IMPRESSÃO EM PDF

				AADD(ADTQ , {"FQ5_FILIAL" , RETFILGRV("FQ5_FILIAL")})
				AADD(ADTQ , {"FQ5_FILORI" , RETFILGRV("FQ5_FILORI")})
				AADD(ADTQ , {"FQ5_VIAGEM" , CVIAGEM})
				AADD(ADTQ , {"FQ5_CONTRA" , CPROJETO})
				AADD(ADTQ , {"FQ5_DATGER" , DDATABASE})
				AADD(ADTQ , {"FQ5_HORGER" , SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)})
				AADD(ADTQ , {"FQ5_STATUS" , "1"})
			ENDIF

			AADD(ADTQ , {"FQ5_ROTA"   , "000001"})
			AADD(ADTQ , {"FQ5_TIPVIA" , "1"})
			AADD(ADTQ , {"FQ5_DATINI" , FPA->FPA_DTINI})
			AADD(ADTQ , {"FQ5_HORINI" , FPA->FPA_HRINI})
			AADD(ADTQ , {"FQ5_DATFIM" , FPA->FPA_DTENRE})
			AADD(ADTQ , {"FQ5_HORFIM" , FPA->FPA_HRFIM})
			AADD(ADTQ , {"FQ5_SERTMS" , "2"})
			AADD(ADTQ , {"FQ5_TIPTRA" , "1"})
			AADD(ADTQ , {"FQ5_NOMCLI" , FP0->FP0_CLINOM})
			AADD(ADTQ , {"FQ5_ORIGEM" , "EMPRESA"})
			AADD(ADTQ , {"FQ5_DESTIN" , FP1->FP1_MUNORI+FP1->FP1_ESTORI})
			AADD(ADTQ , {"FQ5_CONDPG" , CCONDPAG})
			AADD(ADTQ , {"FQ5_DCOND"  , CDESCCON})
			IF ! FQ5->( FOUND() )					// SE FOR NOVO REGISTRO, INICIA COM STATUS "1"
					AADD(ADTQ , {"FQ5_STATUS","1"})
			ENDIF
			AADD(ADTQ , {"FQ5_SOT"   , CPROJETO})
			AADD(ADTQ , {"FQ5_OBRA"  , FP1->FP1_OBRA})
			AADD(ADTQ , {"FQ5_TPAS"  , CTIPOAS})
			AADD(ADTQ , {"FQ5_AS"    , CNRAS})
			AADD(ADTQ , {"FQ5_GUINDA", FPA->FPA_GRUA})
			AADD(ADTQ , {"FQ5_SEQVIA", FPA->FPA_SEQGRU})
			AADD(ADTQ , {"FQ5_CODCLI", FP0->FP0_CLI})	//NOME DO CLIENTE
			AADD(ADTQ , {"FQ5_LOJA"  , FP0->FP0_LOJA})	//NOME DO CLIENTE
			AADD(ADTQ , {"FQ5_XQTD"  , FPA->FPA_QUANT}) // FRANK ZWARG FUGA - 13/08/2020
			AADD(ADTQ , {"FQ5_XPROD" , FPA->FPA_PRODUT}) // FRANK ZWARG FUGA - 13/08/2020
			IF _GRCONTR_ //EXISTBLOCK( "GRCONTR_" )
				XRET := EXECBLOCK( "GRCONTR_", .T., .T., { "ANTESDTQ", @ADTQ, "FPA" } )
				IF VALTYPE( XRET ) == "A"
					ADTQ := XRET
				ENDIF
			ENDIF

			IF (LRESENTEML := LOCA01310(ADTQ , CVIAGEM))
				IF LRESENTEML
					AADD(AASREV, FQ5->( RECNO() )) 	// ADICIONA AS PARA IMPRESSÃO EM PDF
				ENDIF
				FOR XIT := 1 TO LEN(ADTQ)
					FQ5->&(ADTQ[XIT][1]) := ADTQ[XIT][2]
				NEXT
			ENDIF

			FQ5->(MSUNLOCK())

			LOCA01307( ALLTRIM(CNRAS) , "2" , ALLTRIM(SUBSTR(FP1->FP1_NOMORI,1,20))+STR0075 , CODCLVAL(ALLTRIM(CCONTRATO))+FP1->FP1_OBRA+"T" )  //" - LOCACAO"

			RECLOCK("FPA",.F.)
			REPLACE FPA_VIAGEM WITH CVIAGEM
			REPLACE FPA_AS     WITH CNRAS
			FPA->(MSUNLOCK())

			// Tratamento para inserir o numero da AS no gerenciamento de bens
			// Frank em 01/04/2024
			LOCA013B()

		    IF lASNova .and.  _MV_LOC207 // Gera AS Aceita
				SB1->( MSSEEK(XFILIAL("SB1")+FPA->FPA_PRODUT) )
				if !LOCA013C(CGRPAND) // Não Encontrou algo que não permite aceitar AS Automatica
					aSavFPA := FPA->(GetArea())
					LOCA05908("AUTO")
					RestArea(aSavFPA)
				ENDIF
			endif

			DBSELECTAREA("FPA")

			FPA->(DBSKIP())
		ENDDO

		FP1->(DBSKIP())

	ENDDO

	IF _LNOFROTA
		MSGALERT(STR0076+CRLF+CRLF+STR0077) //"A AS NÃO FOI GERADA."###"PREENCHA O BEM!"
	ELSE
		IF EXISTBLOCK("GRCTLFIM") 										// --> PONTO DE ENTRADA PARA AJUSTES NO FINAL DA GERAÇÃO DE CONTRATO/AS DE LOCAÇÃO.
			EXECBLOCK("GRCTLFIM",.T.,.T.,{AASNOVA})
		ENDIF
	ENDIF

	IF TYPE("_XAAREAZA0") == "U"
		_XAAREAZA0 := FP0->( GETAREA() )
	ENDIF

	FZLWDTQ(CPROJETO) 					// GERAR ASF (AS FILHA) PARA FRETE/TRANSPORTE DE EQUIPAMENTO POR MEIO DA ZLW
	FZUCDTQ(CPROJETO)					// GERAR ASF (AS FILHA) PARA FRETE/TRANSPORTE DE LOCAÇÃO     POR MEIO DA ZUC

	FP0->( RESTAREA( _XAAREAZA0 ) )

	RESTAREA( AAREA )

RETURN

// ======================================================================= \\
STATIC FUNCTION FZLWDTQ(CPROJETO)
	DBSELECTAREA("FP0")
	DBSETORDER(1)
	DBSEEK(XFILIAL("FP0")+CPROJETO)
RETURN NIL

// ======================================================================= \\
STATIC FUNCTION FZUCDTQ(CPROJETO)
Local CLSTANEXOS := ""
Local CFROTA     := ""
Local CNRAS
Local CVIAGEM
Local _ZUCREC
Local XIT
Local _MV_LOC207  := SUPERGETMV("MV_LOCX207",,.F.)
Local _MV_LOC154  := GETMV("MV_LOCX154",,"")
Local _MV_LOC155  := GETMV("MV_LOCX155",,"")
Local _MV_RELFROM := GETMV("MV_RELFROM")

	DBSELECTAREA("FP0")
	DBSETORDER(1)
	DBSEEK(XFILIAL("FP0")+CPROJETO)

	IF FP0->FP0_TIPOSE != "L"		// SE PROJETO NÃO FOR LOCAÇÃO SAI DA ROTINA - 05/08/2016
		RETURN NIL
	ENDIF

	FPA->(DBSETORDER(1))			// FILIAL+PROJET+OBRA+SEQGRU

	DBSELECTAREA("FP1")
	DBSETORDER(1)
	DBSEEK(XFILIAL("FP1")+CPROJETO)

	DBSELECTAREA("FQ7")
	DBSETORDER(2)
	DBSEEK(XFILIAL("FQ7")+CPROJETO , .T.)

	WHILE ! FQ7->(EOF()) .AND. FQ7->FQ7_FILIAL+FQ7->FQ7_PROJET == XFILIAL("FQ7")+CPROJETO

		_ZUCREC := FQ7->(RECNO())

		IF FPA->(DBSEEK(XFILIAL("FPA")+CPROJETO+FQ7->FQ7_OBRA+FQ7->FQ7_SEQGUI))
			CFROTA := FPA->FPA_GRUA
		ENDIF

		IF EMPTY(FQ7->FQ7_X5COD)	// SE O CAMPO CÓDIGO CONJUNTO TRANSPORTADOR EM BRANCO, IGNORA
			FQ7->(DBSKIP())
			LOOP
		ENDIF

		IF EMPTY(FQ7->FQ7_VIAGEM)
			CNRAS := GERANUMAS( /*"05"*/ "31", CPROJETO, FQ7->FQ7_OBRA, FQ7->FQ7_SEQGUI, FQ7->FQ7_FILIAL)
		ELSE
			DBSELECTAREA("FQ5")
			DBSETORDER(1)
			IF DBSEEK( XFILIAL("FQ5") + FQ7->FQ7_VIAGEM)
				CNRAS   := FQ5->FQ5_AS
			ELSE
				MSGSTOP(STR0081+FQ7->FQ7_VIAGEM , STR0004) //"VIAGEM: "###"GPO - GRCONTR.PRW"
				RETURN .F.
			ENDIF
		ENDIF

		ADTQ := {}

		FQ5->(DBSETORDER(9))	// FQ5_FILIAL + FQ5_AS + FQ5_VIAGEM
		IF FQ5->(DBSEEK(XFILIAL("FQ5")+CNRAS , .T.))
			RECLOCK("FQ5",.F.)
			CVIAGEM := FQ5->FQ5_VIAGEM
			AADD(ADTQ , {"FQ5_FILORI" , FQ5->FQ5_FILORI})
			AADD(ADTQ , {"FQ5_CONTRA" , FQ5->FQ5_CONTRA})
			AADD(ADTQ , {"FQ5_DATGER" , FQ5->FQ5_DATGER})
			AADD(ADTQ , {"FQ5_HORGER" , FQ5->FQ5_HORGER})
			IF FQ5->FQ5_STATUS == "7" .or. FQ5->FQ5_STATUS == "9" // Frank se precisar liberar ao dar manutenção basta colocar o status 9 também 14/07/21
				AADD(ADTQ, {"FQ5_STATUS","1"})
			ENDIF
		ELSE

			// Frank em 17/10/23 - card 1227
			// coloquei um reforço lógico para evitar a numeracao repetida da viagem,
			// quando ocorria a repetição era gerado linhas em branco a fq5 e depois deletadas
			// e este erro gravava a AS na FPA sem gerar a FQ5.
			While .T.
				CVIAGEM := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
				CONFIRMSX8()
				FQ5->(dbSetOrder(1))
				If !FQ5->(dbSeek(xFilial("FQ5")+CVIAGEM))
					Exit
				EndIF
			Enddo

			RECLOCK("FQ5",.T.)

			AADD(AASNOVA, FQ5->(RECNO()))			// ADICIONA AS PARA IMPRESSÃO EM PDF
			AADD(ADTQ , {"FQ5_FILORI" , RETFILGRV("FQ5_FILORI")})
			AADD(ADTQ , {"FQ5_CONTRA" , PADR(FP0->FP0_PROJET,LEN(FQ5->FQ5_CONTRA))})
			AADD(ADTQ , {"FQ5_DATGER" , DDATABASE})
			AADD(ADTQ , {"FQ5_HORGER" , SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)})
			AADD(ADTQ , {"FQ5_STATUS" , "1"})
		ENDIF

		AADD(ADTQ , {"FQ5_FILIAL" , RETFILGRV("FQ5_FILIAL")})
		AADD(ADTQ , {"FQ5_TPAS"   , "F"})
		AADD(ADTQ , {"FQ5_AS"     , CNRAS})
		AADD(ADTQ , {"FQ5_VIAGEM" , CVIAGEM})
		AADD(ADTQ , {"FQ5_SOT"    , PADR(CPROJETO,LEN(FQ5->FQ5_SOT)) })
		AADD(ADTQ , {"FQ5_OBRA"   , FQ7->FQ7_OBRA})
		AADD(ADTQ , {"FQ5_NOMCLI" , FP0->FP0_CLINOM})
		AADD(ADTQ , {"FQ5_ORIGEM" , FQ7->FQ7_CIDORI+" "+FQ7->FQ7_UFORI})
		AADD(ADTQ , {"FQ5_DESTIN" , FQ7->FQ7_CIDEST+" "+FQ7->FQ7_UFDEST})
		IF ! FQ5->( FOUND() )						// SE FOR NOVO REGISTRO, INICIA COM STATUS "1"
			IF !_MV_LOC207 //SUPERGETMV("MV_LOCX207",,.F.)
				AADD(ADTQ , {"FQ5_STATUS","1"})
			ELSE
				AADD(ADTQ , {"FQ5_STATUS","6"})
			ENDIF
		ENDIF
		AADD(ADTQ , {"FQ5_ROTA"  ,"000001"})
		AADD(ADTQ , {"FQ5_TIPVIA","1"})
		AADD(ADTQ , {"FQ5_SERTMS","2"})
		AADD(ADTQ , {"FQ5_TIPTRA","1"})
		AADD(ADTQ , {"FQ5_OBSCTB",FQ7->FQ7_OBS})
		AADD(ADTQ , {"FQ5_CODCLI", FP0->FP0_CLI})		// NOME DO CLIENTE
		AADD(ADTQ , {"FQ5_LOJA"  , FP0->FP0_LOJA})		// NOME DO CLIENTE
		AADD(ADTQ , {"FQ5_GUINDA", FQ7->FQ7_X5COD})
		AADD(ADTQ , {"FQ5_DATINI", FPA->FPA_DTINI})
		AADD(ADTQ , {"FQ5_DATFIM", FPA->FPA_DTENRE})
		AADD(ADTQ , {"FQ5_HORINI", FPA->FPA_HRINI})
		AADD(ADTQ , {"FQ5_HORFIM", FPA->FPA_HRFIM})
		//AADD(ADTQ , {"FQ5_XQTD"  , FPA->FPA_QUANT}) // FRANK ZWARG FUGA 13/08/2020
		//AADD(ADTQ , {"FQ5_XPROD" , FPA->FPA_PRODUT})

		IF LOCA01311(ADTQ , CVIAGEM) 					// VERIFICA SE EXISTE DIFERENÇA NA DTQ COM A ZUC - ESSE PROCESSO É REFERENTE A ASF.
			FOR XIT := 1 TO LEN(ADTQ)
				FQ5->( FIELDPUT(FIELDPOS(ADTQ[XIT][1]), ADTQ[XIT][2]) )
			NEXT
		ENDIF

		FQ5->(MSUNLOCK())

		LOCA01307( ALLTRIM(CNRAS) , "2" , ALLTRIM(SUBSTR(FP1->FP1_NOMORI,1,20))+STR0082 , CODCLVAL(ALLTRIM(CCONTRATO))+FP1->FP1_OBRA+"T" )  //" - FRETE"

		FQ7->(DBGOTO(_ZUCREC))

		FQ7->(RECLOCK("FQ7",.F.))
		IF EMPTY(FQ7->FQ7_VIAGEM)
			FQ7->FQ7_VIAGEM	:= CVIAGEM
		ENDIF
		IF EMPTY(FQ7->FQ7_VIAORI)
			FQ7->FQ7_VIAORI	:= IIF(FP0->FP0_TIPOSE=="E" , FP4->FP4_VIAGEM , FPA->FPA_VIAGEM)
		ENDIF
		FQ7->FQ7_ALTERR := DTOS(DDATABASE)
		FQ7->(MSUNLOCK())

		CHECKASG2()
		// --> MANDA E-MAIL REFERENTE A ALTERACAO DO ASF
		//Removido por Frank em 05/04/2022 por questão dos débitos técnicos
		IF EMPTY(FQ7->FQ7_ALTERR) .and. .f.
			CANEXO := CNRAS+".PDF"
			CTITULO	:= STR0078 + CPROJETO //"REVISÃO DE ASF - PROJETO "

			DBSELECTAREA("FP0")
			DBSETORDER(1)
			DBSEEK(XFILIAL("FP0")+FQ5->FQ5_SOT)

			EFROM 	:= ALLTRIM(_MV_RELFROM) //ALLTRIM(USRRETNAME(RETCODUSR())) + "<" + ALLTRIM(USRRETMAIL(RETCODUSR())) + ">"
			IF FP0->FP0_TIPOSE == "E"
				CPARA 	:= _MV_LOC154 //GETMV("MV_LOCX154",,"")
			ELSEIF FP0->FP0_TIPOSE == "U"
				CPARA 	:= _MV_LOC155 //GETMV("MV_LOCX155",,"")
			ENDIF

			CCC	 	:= ""
			CCCO 	:= ""
			CMSG 	:= STR0079+CNRAS+ CHR(13)+CHR(10) //"ESTE EMAIL É PARA INFORMAR QUE NO SISTEMA FOI REVISADA A ASF DE NUMERO: "
			CMSG 	+= STR0080+PADR(CPROJETO,LEN(FQ5->FQ5_SOT))+ CHR(13) + CHR(10) //"PROJETO: "

			IF LEN(CMSG) > 0
				LOCA01313( EFROM, CPARA, CCC, CTITULO, CMSG, CLSTANEXOS, CCCO)	// ROTINA DE ENVIO DE E-MAIL PADRÃO
			ENDIF

			FERASE(CANEXO)		// REMOVE ARQUIVO TEMPORÁRIO DO SERVIDOR
		ENDIF
		FQ7->(DBSKIP())
	ENDDO

RETURN NIL



// ======================================================================= \\
STATIC FUNCTION GERANUMAS( PSRV , PPROJETO, POBRA, PSEQ, PFILIAL, CNEWSEQ)
// ======================================================================= \\
Local AAREA     := GETAREA()
Local AAREADTQ  := FQ5->(GETAREA())
Local LCONTINUA := .T.
Local CSERVICO  := ALLTRIM( PSRV )
Local CPROJETO  := SUBSTR( ALLTRIM( PPROJETO ), 5, 5 )
Local COBRA     := ALLTRIM( POBRA )
Local _CFILIAL  := ALLTRIM( PFILIAL )

Default CNEWSEQ   := ALLTRIM( IIF( VALTYPE(PSEQ) == "N", STRZERO(PSEQ, 3), PSEQ ) )

	IF LEN( CSERVICO ) != 2
		FINAL(STR0083+CSERVICO+STR0084, STR0085) //"SERVICO INFORMADO ["###"] INVALIDO"###"GERANUMAS - GERACAO DE AS"
	ENDIF

	IF LEN( CPROJETO ) != 5
		FINAL(STR0086+CPROJETO+STR0084, STR0085) //"PROJETO INFORMADO ["###"] INVALIDO"###"GERANUMAS - GERACAO DE AS"
	ENDIF

	IF LEN( COBRA ) != 3
		FINAL(STR0087+COBRA+STR0088, STR0085) //"OBRA/VIAGEM INFORMADA ["###"] INVALIDA"###"GERANUMAS - GERACAO DE AS"
	ENDIF

	IF LEN( CNEWSEQ ) != 3
		CNEWSEQ := RIGHT( "000" + CNEWSEQ, 3 )
	ENDIF

	IF EMPTY( _CFILIAL )					 			// CASO NÃO TENHA CONTEÚDO
		_CFILIAL := REPLICATE("0", LEN( CFILANT ) )		// PREENCHE O TAMANHO DO XFILIAL() COM ZEROS
	ENDIF

	FQ5->(DBSETORDER(9))								// FQ5_FILIAL + FQ5_AS + FQ5_VIAGEM
	WHILE LCONTINUA
		CNRAS     := CSERVICO + CPROJETO + COBRA + CNEWSEQ + _CFILIAL
		LCONTINUA := FQ5->(DBSEEK( XFILIAL("FQ5") + CNRAS, .T.))
		CNEWSEQ   := SOMA1(CNEWSEQ)
	ENDDO

	FQ5->(RESTAREA(AAREADTQ))
	RESTAREA( AAREA )

RETURN CNRAS

// ======================================================================= \\
FUNCTION LOCA01303( CFROTA , DINICIO, DFINAL , CVIAGEM , CTIPOAS , LACE)
// ======================================================================= \\
RETURN 			// --> FUNÇÃO DESCONTINUADA - A CRIAÇÃO DA PROGRAMAÇÃO SERÁ NO ACEITE DA AS. FONTE: LOCT111-APONTADOR AS


// ======================================================================= \\
FUNCTION LOCA01304( CFROTA , DINICIO, DFINAL , CVIAGEM , CTIPOAS , LACE)
RETURN 			// --> FUNÇÃO DESCONTINUADA - A CRIAÇÃO DA PROGRAMAÇÃO SERÁ NO ACEITE DA AS. FONTE: LOCT111-APONTADOR AS

// ======================================================================= \\
FUNCTION LOCA01305( CORIG , CDEST )
// ======================================================================= \\
// --> TABELA DE SEGURO / ADVALOREM POR ESTADO  - PRECISA SER REVISADA / VALIDADA
NALIQ := 0.20
RETURN NALIQ

// ======================================================================= \\
FUNCTION LOCA01306( CORIG , CDEST )
// ======================================================================= \\
// --> TABELA DE ICM POR ESTADO    - PRECISA SER REVISADA / VALIDADA
Local NALIQ    := 0
Local AAREAZLN := GETAREA()

	DBSELECTAREA("ZLN")
	DBSETORDER(1)  // XFILIAL ORIGEM + DESTINO
	IF DBSEEK(XFILIAL("ZLN")+CORIG+CDEST)
		NALIQ := ZLN->ZLN_ALIQ
	ELSE
		NALIQ := 12
	ENDIF

	RESTAREA(AAREAZLN)

RETURN NALIQ

// ======================================================================= \\
STATIC FUNCTION DADOSCLI()
Local AAREA    := GETAREA()
Local ACLIENTE := {}
Local CNUMCLI  := GETSXENUM("SA1","A1_COD")
Local CQRY     := ""
Local _nX
Local _lTem
Local _lTem2
Local _aDePara := {}
Local _cTemp1
Local _cTemp2
Local _nCampo
Local _cDe
Local _cPara
Local _cCamposX := ""
Local a1Struct := {}
Local nP

	CQRY += " SELECT US_NOME , US_NREDUZ , US_COD_MUN , US_MUN  , US_END , US_EST   , US_BAIRRO , US_CEP , US_PESSOA, "
	CQRY +=        " US_TEL  , US_CGC    , US_INSCR   , US_VEND , US_FAX , US_EMAIL , US_DDD    , US_DDI, US_PAIS, US.R_E_C_N_O_ REG "
	CQRY += " FROM " + RETSQLNAME("SUS") + " US "
	CQRY +=        " JOIN " + RETSQLNAME("FP0") + " A0 ON FP0_PROSPE = US_COD "
	CQRY += " WHERE FP0_PROSPE = ? AND FP0_PROJET = ? "
	CQRY +=   " AND A0.D_E_L_E_T_ = '' AND US.D_E_L_E_T_ = '' "
	CQRY := CHANGEQUERY(CQRY)
	aBindParam := {FP0->FP0_PROSPE, FP0->FP0_PROJET}
	MPSysOpenQuery(CQRY,"TRB",,,aBindParam)

	SUS->(dbGoto(TRB->REG))

	AADD(ACLIENTE,{"A1_FILIAL"  , XFILIAL("SA1")		 , NIL})
	AADD(ACLIENTE,{"A1_COD"     , CNUMCLI                , NIL})
	AADD(ACLIENTE,{"A1_LOJA"    , "01"   		         , NIL})
	AADD(ACLIENTE,{"A1_NOME"    , TRB->US_NOME		   	 , NIL})
	AADD(ACLIENTE,{"A1_NREDUZ"  , TRB->US_NREDUZ		 , NIL})
	AADD(ACLIENTE,{"A1_END"     , TRB->US_END		     , NIL})
	AADD(ACLIENTE,{"A1_TIPO"    , "F" 					 , NIL})
	AADD(ACLIENTE,{"A1_EST"     , TRB->US_EST		     , NIL})
	//AADD(ACLIENTE,{"A1_COD_MUN" , TRB->CC2_CODMUN		 , NIL})
	AADD(ACLIENTE,{"A1_COD_MUN" , TRB->US_COD_MUN		 , NIL})
	AADD(ACLIENTE,{"A1_MUN"     , TRB->US_MUN			 , NIL})
	AADD(ACLIENTE,{"A1_BAIRRO"  , TRB->US_BAIRRO    	 , NIL})
	AADD(ACLIENTE,{"A1_CEP"     , TRB->US_CEP    		 , NIL})
	AADD(ACLIENTE,{"A1_TEL"     , TRB->US_TEL	         , NIL})
	AADD(ACLIENTE,{"A1_DDD"     , TRB->US_DDD	         , NIL})
	AADD(ACLIENTE,{"A1_DDI"     , TRB->US_DDI            , NIL})
	AADD(ACLIENTE,{"A1_CGC"     , TRB->US_CGC	         , NIL})
	AADD(ACLIENTE,{"A1_MSBLQL"  , "2"		             , NIL})
	AADD(ACLIENTE,{"A1_CONTATO" , FP0->FP0_CLICON     	 , NIL})
	AADD(ACLIENTE,{"A1_VEND"    , FP0->FP0_VENDED  	 	 , NIL})
	AADD(ACLIENTE,{"A1_PESSOA"  , TRB->US_PESSOA         , NIL}) // DSERLOCA - 
	AADD(ACLIENTE,{"A1_FAX"     , TRB->US_FAX   	     , NIL})
	AADD(ACLIENTE,{"A1_EMAIL"   , TRB->US_EMAIL  	     , NIL})
	AADD(ACLIENTE,{"A1_PAIS"    , TRB->US_PAIS  	     , NIL})
	If SA1->(FIELDPOS("A1_ESTATAL")) > 0
		AADD(ACLIENTE,{"A1_ESTATAL" , 'N'                    , NIL})
	EndIF
	//AADD(ACLIENTE,{"A1_SINTEGR" , 'S'                    , NIL})
	If SA1->(FIELDPOS("A1_FICHA")) > 0
		AADD(ACLIENTE,{"A1_FICHA"   , 'N'                    , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_RECEITA")) > 0
		AADD(ACLIENTE,{"A1_RECEITA" , 'N'                    , NIL})
	EndIf
	If SA1->(FIELDPOS("A1_CONTSOC")) > 0
		AADD(ACLIENTE,{"A1_CONTSOC" , 'N'                    , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_ENDCOB")) > 0
		AADD(ACLIENTE,{"A1_ENDCOB"  , substr(TRB->US_END,1,tamsx3("A1_ENDCOB")[1])  , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_BAIRROC")) > 0
		AADD(ACLIENTE,{"A1_BAIRROC" , substr(TRB->US_BAIRRO,1,tamsx3("A1_BAIRROC")[1])         , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_ESTC")) > 0
		AADD(ACLIENTE,{"A1_ESTC"    , TRB->US_EST            , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_MUNC")) > 0
		AADD(ACLIENTE,{"A1_MUNC"    , substr(TRB->US_MUN,1,tamsx3("A1_MUNC")[1])            , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_CEPC")) > 0
		AADD(ACLIENTE,{"A1_CEPC"    , TRB->US_CEP            , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_SEGMENT")) > 0
		AADD(ACLIENTE,{"A1_SEGMENT" , "02"                   , NIL})
	EndIF
	If SA1->(FIELDPOS("A1_MAILCOB")) > 0
		AADD(ACLIENTE,{"A1_MAILCOB" , substr(TRB->US_EMAIL,1,tamsx3("A1_MAILCOB")[1])          , NIL})
	EndIF
	//AADD(ACLIENTE,{"A1_CDRDES" ,  '000001'               , NIL})

	TRB->(DBCLOSEAREA())

	// Encontrar os campos obrigatórios customizados
	// Neste caso é possível fazer a associacao dos campos obrigatórios da SUS com SA1 via parâmetro
	// -----------------------------------------------------------------------------------------------
	_aDePara := {}
	// US_DDD/A1_DDD;US_TEL/A1_TEL; Não pode conter espaços entre os campos
	_cDePara := alltrim(GetMV("MV_LOCX303",.F.,""))
	_cTemp1  := ""
	_cTemp2  := ""
	_nCampo  := 1
	If !empty(_cDePara)
		For _nX:=1 to len(_cDePara)
			If substr(_cDePara,_nX,1) == "/"
				_nCampo ++
			ElseIf substr(_cDePara,_nX,1) == ";" .or. substr(_cDePara,_nX,1) == " "
				_nCampo := 1
				aadd(_aDePara,{_cTemp1,_cTemp2})
				_cTemp1 := ""
				_cTemp2 := ""
			Else
				If _nCampo == 1
					_cTemp1 += substr(_cDePara,_nX,1)
				Else
					_cTemp2 += substr(_cDePara,_nX,1)
				EndIf
			EndIF
		Next
		If !empty(_cTemp1)
			aadd(_aDePara,{_cTemp1,_cTemp2})
		EndIF

		// Frank em 01/04/2024
		a1Struct := FWSX3Util():GetListFieldsStruct( "SA1" , .F.)
		For nP := 1 to len(a1Struct)
			_lTem := .F.
			If x3Obrigat( a1Struct[nP][01] )
				For _nX := 1 to len(aCliente)
					If alltrim(aCliente[_nX][01]) == alltrim(a1Struct[nP][01])
						_lTem := .T.
						Exit
					EndIF
				Next
				If !_lTem
					_lTem2 := .F.
					_cDe := ""
					_cPara := ""
					For _nX:=1 to len(_aDePara)
						If alltrim(_aDePara[_nX][02]) == alltrim(a1Struct[nP][01])
							_lTem2 := .T.
							_cDe   := alltrim(_aDePara[_nX,01]) // SUS
							_cPara := alltrim(_aDePara[_nX,02]) // SA1
							Exit
						EndIF
					Next

					If _lTem2
						AADD(ACLIENTE,{alltrim(a1Struct[nP][01]) , &("SUS->"+_cDe), NIL})
					EndIF
				EndIF
			EndIF
		Next
	EndIF
	// -----------------------------------------------------------------------------------------------
	// No caso de não usar o processo de associar os campos obrigatórios via parâmetro, neste caso
	// vamos preencher da seguinte forma os campos que não tem associação com a SUS:
	// Tipo Caracter ".", se for com x3_cbox pegar o substr(x3_cbox,1,1)
	// Tipo numérico 0.01, se for com x3_cbox pegar o substr(x3_cbox,1,1)
	// Tipo lógico .T.
	// Tipo Memo "."
	If empty(_cDePara)
		a1Struct := FWSX3Util():GetListFieldsStruct( "SA1" , .F.)
		_cCamposX := ""
		For nP := 1 to len(a1Struct)
			_lTem   := .F.
			_lVazio := .F.
			_nPonteiro := 0
			If x3Obrigat( a1Struct[nP][01] )
				For _nX := 1 to len(aCliente)
					If alltrim(aCliente[_nX][01]) == alltrim(a1Struct[nP][01])
						_nPonteiro := _nX
						_lTem := .T.
						If empty(aCliente[_nX][02])
							_lVazio := .T.
						EndIF
						Exit
					EndIF
					If _lVazio .or. !_lTem
						If AT(alltrim(GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_TITULO")),_cCamposX) == 0
							If !empty(_cCamposX)
								_cCamposX += ", "
							EndIf
							_cCamposX += alltrim(GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_TITULO"))
						EndIf
						If GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_TIPO") == "C"
							_xTipo := "."
						ElseIf GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_TIPO") == "N"
							_xTipo := 1
						ElseIf GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_TIPO") == "L"
							_xTipo := .T.
						ElseIf GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_TIPO") == "D"
							_xTipo := dDataBase
						ElSe
							_xTipo := "."
						EndIF
						If !empty(GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_CBOX")) .and. At("=",GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_CBOX")) > 0
							_xTipo := substr(GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_CBOX"),1,At("=",GetSx3Cache(alltrim(a1Struct[nP][01]),"X3_CBOX"))-1)
						EndIF
						If !_lTem
//							AADD(ACLIENTE,{alltrim(a1Struct[nP][01]) , _xTemp, NIL})
						Else
							If _nPonteiro > 0
								aCliente[_nPonteiro][2] := _xTipo
							EndIF
						EndIF
					EndIF
				Next
			EndIf
		Next
	EndIF

	RESTAREA( AAREA )

	If !empty(_cCamposX)
		Help(Nil,	Nil,STR0004+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0127,1,0,Nil,Nil,Nil,Nil,Nil,; //"Os campos descritos aqui precisam ser preenchidos com as informações corretas. Anote e preencha com um conteúdo válido na próxima tela."
			{_cCamposX})
	EndIF

RETURN ACLIENTE

// ======================================================================= \\
FUNCTION LOCA01307(CNPROJET , TP , DESCRI , CCLSUP)
// ======================================================================= \\
// --> GERAR CLASSE DE VALOR POR PROJETO E OBRA
Local AAREA  := GETAREA()
Local DTAEX  := CTOD(SPACE(08))
Local _LCVAL := SUPERGETMV("MV_LOCX051",.F.,.T.)

	IF !_LCVAL
		RETURN
	ENDIF

	CNPROJET := ALLTRIM(STRTRAN(CNPROJET,"-",""))
	CCLSUP   := ALLTRIM(STRTRAN(CCLSUP  ,"-",""))

	DBSELECTAREA("CTH")
	DBSETORDER(1) 								// FILIAL + CTH_CLVL  -->  (CODIGO DA CLASSE DE VALOR )
	IF DBSEEK(XFILIAL("CTH")+CNPROJET)
		IF ALLTRIM(SUBSTR(CTH->CTH_CLVL,1,GETSX3CACHE("CTH_CLVL","X3_TAMANHO"))) == ALLTRIM(SUBSTR(CNPROJET,1,GETSX3CACHE("CTH_CLVL","X3_TAMANHO")))
			DTAEX := CTH_DTEXIS
			RECLOCK("CTH",.F.)
		ELSE
			DTAEX := DDATABASE
			RECLOCK("CTH",.T.)
		ENDIF
	ELSE
		DTAEX := DDATABASE
		RECLOCK("CTH",.T.)
	ENDIF

	REPLACE CTH_FILIAL WITH XFILIAL("CTH")
	REPLACE CTH_CLVL   WITH CNPROJET
	REPLACE CTH_CLASSE WITH TP
	REPLACE CTH_NORMAL WITH "0"
	REPLACE CTH_DESC01 WITH DESCRI
	REPLACE CTH_BLOQ   WITH "2"
	REPLACE CTH_DTEXIS WITH DTAEX
	REPLACE CTH_CLSUP  WITH CCLSUP
	CTH->(MSUNLOCK())

	RESTAREA( AAREA )

RETURN()



// ----------------------------------------------------------------------- \\
STATIC FUNCTION CODCLVAL(CVAR)
// ----------------------------------------------------------------------- \\
Local CRET := SPACE(20)

	IF LEN(ALLTRIM(CVAR)) >11
		IF SUBSTR(ALLTRIM(CVAR),12,1) == "/"
			CRET := SUBSTR(ALLTRIM(CVAR),1,11)
		ELSE
			CRET := SUBSTR(ALLTRIM(CVAR),1,12)
		ENDIF
	ELSE
		CRET := CVAR
	ENDIF

RETURN(CRET)

// ----------------------------------------------------------------------- \\
FUNCTION LOCA01309( CCODBEM )	// TESTA O CAMPOS T9_SITMAN
Local AAREA := GETAREA()
Local LRET  := .T.

	LRET := (POSICIONE("ST9",1,XFILIAL("ST9")+CCODBEM,"T9_SITMAN") == "A")
	IF ! LRET
		MSGALERT(STR0095 , STR0004)  //"STATUS DE MANUTENÇÃO: O CÓDIGO DO BEM [CCODBEM] ESTÁ INATIVO NO SISTEMA!"###"GPO - GRCONTR.PRW"
	ENDIF

	RESTAREA(AAREA)

RETURN LRET

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ F_ASEMAIL º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ DISPARA O E-MAIL QUANDO APRESENTADO ALTERAÇÃO NA AS.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION F_ASEMAIL(CVEJAPROJ,CVEJATPSE,CRECNO)
Local AAREA   := GETAREA()
Local CQUERY  := ""
Local AANEXOS := {}
Local CREVAS	:= 0
Local NI      := 0
Local cTemp   := ""

Default CRECNO	:=	""

	IF SELECT("TRAB") > 0
		TRAB->(DBCLOSEAREA())
	ENDIF

	IF EMPTY(CRECNO)
		RETURN
	ENDIF

	CQUERY := "	SELECT FQ5_AS, FQ5_SOT, FQ5_OBRA, FQ5_VIAGEM, FQ5_DATGER, R_E_C_N_O_ FROM " + RETSQLNAME('FQ5')+ " DTQ"
	CQUERY += " WHERE D_E_L_E_T_ = '' "
	CQUERY += " AND R_E_C_N_O_ IN ( "
	cTemp  := cRECNO+")"
	&("cQuery += cTemp")
	CQUERY := CHANGEQUERY(CQUERY)
	
	MPSysOpenQuery(cQuery,"TRAB")

	CTITULO		:= STR0096 + CVEJAPROJ //" REVISÃO DAS AS´S DO PROJETO/OBRA "
	CMSG1        := ""
	CMSG		:= ""

	WHILE .NOT. TRAB->(EOF())

		// PARA ENVIAR E-MAIL NA REVISÃO
		// PARA SÓ ENVIAR E-MAIL QUANDO FOR NOVA AS
		// VOLTAR A ENVIAR E-MAIL QUANDO FOR REVISÃO
		IF ASCAN(AASNOVA, TRAB->R_E_C_N_O_) == 0 .AND. ASCAN(AASREV, TRAB->R_E_C_N_O_) == 0
			TRAB->(DBSKIP())
			LOOP
		ENDIF

		FQ5->(DBGOTO( TRAB->R_E_C_N_O_ ))
		CANEXO := FQ5->FQ5_AS+".PDF"

		CTITULO		:= STR0097 + ALLTRIM(TRAB->FQ5_SOT) + STR0098 + FP0->FP0_REVISA //"REVISÃO PROJETO "###", REVISÃO "
		CTIT2		:= _CTIPOAS + STR0099 + TRAB->FQ5_AS +STR0100+ STRZERO(CREVAS,3) +STR0101 +  STR0102 + ALLTRIM(TRAB->FQ5_SOT) + STR0100 + FP0->FP0_REVISA + STR0103+FQ5->FQ5_OBRA + SPACE(100) //" NÚMERO "###" REVISÃO "###" DO "###" PROJETO "###" REVISÃO "###" PARA OBRA "
		CMSG1 		+= IIF( LEN(CMSG1) = 0 , STR0104 + CHR(13)+CHR(10) , CHR(13)+CHR(10) ) + CTIT2 + CHR(13) + CHR(10) //"ESTE EMAIL É PARA INFORMAR QUE NO SISTEMA FOI REVISADA AS:"

		DO CASE
		CASE CVEJATPSE $ "E"	// AS DE EQUIPAMENTO
			IF CVEJATPSE == "L"
				// POSICIONO NA ZA6-TRANSPORTES X PROJETO
				/*
				ZA6->(DBSETORDER(1))
				ZA6->(DBSEEK(XFILIAL("ZA6") +  TRAB->FQ5_SOT + TRAB->FQ5_OBRA))
				*/
			ENDIF
			//POSICIONO NA ZA1-OBRAS
			FP1->(DBSETORDER(1))
			FP1->(DBSEEK(XFILIAL("FP1") + TRAB->FQ5_SOT + TRAB->FQ5_OBRA))

			//POSICIONA NA ZA5-GUINDASTES X PROJETO
			FP4->(DBSETORDER(2))
			FP4->(DBSEEK(XFILIAL("FP4") +  TRAB->FQ5_SOT + TRAB->FQ5_OBRA + TRAB->FQ5_AS +TRAB->FQ5_VIAGEM))

			CMSG1	+= CHR(13) + CHR(10)
			CMSG1	+= STR0056 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"LOCAL DO SERVIÇO"
			CMSG	+= STR0012 + FQ5->FQ5_NOMCLI + CHR(13) + CHR(10) //"CLIENTE "
			CMSG1	+= STR0065 + FP1->FP1_NOMORI 												+ CHR(13) + CHR(10) //"OBRA   "
			//CMSG1	+= "CIDADE " + IIF(FP0->FP0_TIPOSE == "L",ZA6->ZA6_MUNDES,FP1->FP1_MUNORI)	+ CHR(13) + CHR(10)
			//CMSG1	+= "ESTADO " + IIF(FP0->FP0_TIPOSE == "L",ZA6->ZA6_ESTDES,FP1->FP1_ESTORI)	+ CHR(13) + CHR(10) + CHR(13) + CHR(10)
			CMSG1	+= STR0064 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"EQUIPAMENTO"
			CMSG1	+=  ALLTRIM(FP4->FP4_GUINDA) + " - " + ALLTRIM(FP4->FP4_DESGUI) + " (" + ALLTRIM(FP4->FP4_CONFIG) + ")" + CHR(13) + CHR(10)

			IF FQ5->FQ5_TPAS == "F"
				CHECKASG()
			ENDIF
			//Removido por Frank em 05/04/2022 por questão dos débitos técnicos
			IF .F.//__COPYFILE(ALLTRIM(GETTEMPPATH())+CANEXO, GETSRVPROFSTRING("STARTPATH","")+CANEXO)
			//	CANEXO := GETSRVPROFSTRING("STARTPATH","")+CANEXO
			//	AADD(AANEXOS, CANEXO)
			ENDIF

		CASE CVEJATPSE $ "L"		// AS DE LOCAÇÃO
			// --> POSICIONO NA ZA1-OBRAS
			FP1->(DBSETORDER(1))
			FP1->(DBSEEK(XFILIAL("FP1") + TRAB->FQ5_SOT + TRAB->FQ5_OBRA))

			// --> POSICIONA NA ZAG-GRUAS X PROJETO
			FPA->(DBSETORDER(2))
			FPA->(DBSEEK(XFILIAL("FPA") +  TRAB->FQ5_SOT + TRAB->FQ5_OBRA + TRAB->FQ5_AS +TRAB->FQ5_VIAGEM))

			CMSG1	+= CHR(13) + CHR(10)
			CMSG1	+= STR0056 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"LOCAL DO SERVIÇO"
			CMSG	+= STR0012 + FQ5->FQ5_NOMCLI + CHR(13) + CHR(10) //"CLIENTE "
			CMSG1	+= STR0065 + FP1->FP1_NOMORI 	+ CHR(13) + CHR(10) //"OBRA   "
			CMSG1	+= STR0066 + FP1->FP1_MUNORI	+ CHR(13) + CHR(10) //"CIDADE "
			CMSG1	+= STR0067 + FP1->FP1_ESTORI	+ CHR(13) + CHR(10) + CHR(13) + CHR(10) //"ESTADO "
			CMSG1	+= STR0064 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"EQUIPAMENTO"
			CMSG1	+=  ALLTRIM(FPA->FPA_GRUA) + " - " + ALLTRIM(FPA->FPA_DESGRU)+ CHR(13) + CHR(10)

			IF FQ5->FQ5_TPAS != "F"
				//U_LOCI045(FQ5->FQ5_AS, CANEXO)
				// FRANK ZWARG FUGA - 08/09/2020 - DESCONTINUADO CONFORME DOCUMENTAÇÃO DO LAVOR
			ELSE
				LOCA030(FQ5->FQ5_AS, CANEXO)
				CHECKASG()
			ENDIF

			//Removido por Frank em 05/04/2022 por questão dos débitos técnicos
			IF .F. //__COPYFILE(ALLTRIM(GETTEMPPATH())+CANEXO, GETSRVPROFSTRING("STARTPATH","")+CANEXO)
				//CANEXO := GETSRVPROFSTRING("STARTPATH","")+CANEXO
				//AADD(AANEXOS, CANEXO)
			ENDIF

		CASE CVEJATPSE $ "F"	//AS DE FRETE    (ASF)
			FP1->(DBSETORDER(1))
			FP1->(DBSEEK(XFILIAL("FP1") + TRAB->FQ5_SOT + TRAB->FQ5_OBRA))

			CMSG1	+= CHR(13) + CHR(10)
			CMSG1	+= STR0056 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"LOCAL DO SERVIÇO"
			CMSG	+= STR0012 + FQ5->FQ5_NOMCLI + CHR(13) + CHR(10) //"CLIENTE "
			CMSG1	+= STR0065 + FP1->FP1_NOMORI 												+ CHR(13) + CHR(10) //"OBRA   "
			CMSG1	+= STR0066 + FP1->FP1_MUNORI	+ CHR(13) + CHR(10) //"CIDADE "
			CMSG1	+= STR0067 + FP1->FP1_ESTORI	+ CHR(13) + CHR(10) + CHR(13) + CHR(10) //"ESTADO "
			CMSG1	+= STR0064 + CHR(13) + CHR(10) + CHR(13) + CHR(10) //"EQUIPAMENTO"

			LOCA030(FQ5->FQ5_AS, CANEXO)

			// Removido por Frank em 05/04/2022 por questão dos débitos técnicos
			IF .F. //__COPYFILE(ALLTRIM(GETTEMPPATH())+CANEXO, GETSRVPROFSTRING("STARTPATH","")+CANEXO)
				//CANEXO := GETSRVPROFSTRING("STARTPATH","")+CANEXO
				//AADD(AANEXOS, CANEXO)
			ENDIF
		ENDCASE

		DBSELECTAREA("TRAB")
		DBSKIP()

	ENDDO

	IF SELECT("TRAB") > 0
		TRAB->(DBCLOSEAREA())
	ENDIF

	RESTAREA(AAREA)

	CANEXO := ""

	FOR NI := 1 TO LEN(AANEXOS)
		//CANEXO += AANEXOS[NI] + IF(NI < LEN(AANEXOS), ", ", "")
	NEXT NI

RETURN NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FALTDTQ   º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ RETORNA .T. SE EXISTIR DIFERENÇA ENTRE AS VARIÁVEIS DE ME- º±±
±±º          ³ MÓRIA E OS DADOS DA AS (TABELA: DTQ)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA01310(ACPOS , XVIAGEM , XALIAS, lFQ5)
Local NIT
Local XEXCLUSAO := "FQ5_STATUS;FQ5_DATGER;FQ5_HORGER"

Default XALIAS  := "FQ5"

	If FQ5->FQ5_STATUS == "9" .and. XALIAS  == "FQ5"
		XEXCLUSAO := "FQ5_DATGER;FQ5_HORGER" // Frank em 14/07/21
	EndIF
	IF EMPTY(XVIAGEM)			// SE NÃO TEM VIAGEM, RETORNA QUE EXISTE ALTERAÇÃO E DEVE SER REGRAVADO
		RETURN .T.
	ENDIF

	IF XALIAS == "FPS"			// É ASF - FRETE
		XEXCLUSAO := "FPS_VALOR"
	ENDIF

	FOR NIT := 1 TO LEN(ACPOS)
		IF ! ALLTRIM(ACPOS[NIT][1]) $ XEXCLUSAO
			IF &(XALIAS)->( FIELDGET(FIELDPOS(ACPOS[NIT][1])) ) != ACPOS[NIT][2]	// VALOR DO CAMPO É DIFERENTE DO VALOR A SER GRAVADO
				RETURN .T.
			ENDIF
		ENDIF
	NEXT NIT

RETURN .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ FALTDTQ2  º AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ RETORNA .T. SE EXISTIR DIFERENÇA ENTRE AS VARIÁVEIS DE ME- º±±
±±º          ³ MÓRIA E OS DADOS DA AS (TABELA: DTQ)                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION LOCA01311(ACPOS, XVIAGEM, XALIAS)
Local NIT
Local XEXCLUSAO := "FQ5_STATUS;FQ5_DATGER;FQ5_HORGER"

Default XALIAS  := "FQ5"

	If FQ5->FQ5_STATUS == "9" .and. XALIAS  == "FQ5"
		XEXCLUSAO := "FQ5_DATGER;FQ5_HORGER" // Frank 14/07/21
	EndIF
	IF EMPTY(XVIAGEM)	// SE NÃO TEM VIAGEM, RETORNA QUE EXISTE ALTERAÇÃO E DEVE SER REGRAVADO
		RETURN .T.
	ENDIF

	IF XALIAS == "FQ7"	// É ASF - FRETE
		XEXCLUSAO := "FQ7_VALOR"
	ENDIF

	FOR NIT := 1 TO LEN(ACPOS)
		IF ! ALLTRIM(ACPOS[NIT][1]) $ XEXCLUSAO
			IF &(XALIAS)->( FIELDGET(FIELDPOS(ACPOS[NIT][1])) ) != ACPOS[NIT][2]	// VALOR DO CAMPO É DIFERENTE DO VALOR A SER GRAVADO
				RETURN .T.
			ENDIF
		ENDIF
	NEXT NIT

RETURN .F.

// ======================================================================= \\
STATIC FUNCTION CHECKASG
Local AAREA		:= GETAREA()
Local ASAVDTQ	:= FQ5->( GETAREA() )
Local LRET		:= .T.
Local NDIAS		:= 0
Local EFROM, CPARA , CCC, CTITULO, CMSG, CCCO 	/*, CLSTANEXOS*/
Local CASF		:= FQ5->FQ5_AS 					// NUMERO DA ASF
Local DDTASF	:= FQ5->FQ5_DATGER 				// DATA DA ASF

Default ALINALT := {}

	IF FQ5->FQ5_TPAS # 'F' .OR. !(ASCAN(ALINALT, {|LINHA| FQ5->FQ5_VIAGEM==LINHA[2]}) > 0 )
		RETURN 										// NAO EH ASF OU NAO FOI LINHA ALTERADA SAI DA ROTINA
	ENDIF

	DBSELECTAREA("FQ5")
	DBSETORDER(1) 									// FQ5_FILIAL + FQ5_VIAGEM
	MSSEEK(XFILIAL('FQ5')+FPS->FPS_VIAORI) 			// POSICIONA ASG
	IF DDTASF < (FQ5->FQ5_DATINI-30) .OR. DDTASF > (FQ5->FQ5_DATFIM+30)
		LRET := .F.
		IF DDTASF < (FQ5->FQ5_DATINI-30)
			NDIAS := DDTASF - FQ5->FQ5_DATINI
		ELSEIF DDTASF > (FQ5->FQ5_DATFIM+30)
			NDIAS := DDTASF - FQ5->FQ5_DATFIM
		ENDIF
	ELSE
		RETURN 										// SE NÃO FEZ A CONTAGEM DE DIAS FORA DO PERÍODO SAI DA ROTINA, POIS
	ENDIF

	// ENVIA E-MAIL DE AVISO QUE A ASF ESTÁ FORA DO PERÍODO DA ASG (FQ5_DATINI -30 DIAS E FQ5_DATFIM +30 DIAS)
	CCC	 	:= ""
	CCCO 	:= ""
	CMSG 	:= STR0105 + CASF + STR0106 + STR(ABS(NDIAS),5,0) + IIF(NDIAS<0,STR0107,STR0108) + CHR(13)+CHR(10) //'ESTE E-MAIL É PARA INFORMAR QUE A ASF "'###'" ESTÁ '###' DIAS ABAIXO DA DATA INICIAL.'###' DIAS ACIMA DA DATA FINAL.'
	CMSG	+= CHR(13)+CHR(10) + STR0109 + FQ5->FQ5_AS + '" :' + CHR(13)+CHR(10) //'DATAS LIMITES DA AS Nº "'
	CMSG	+= STR0110 + DTOC(FQ5->FQ5_DATINI) + CHR(13)+CHR(10) //"DATA INICIAL "
	CMSG	+= STR0111 + DTOC(FQ5->FQ5_DATFIM) + CHR(13)+CHR(10) + CHR(13)+CHR(10) //"DATA FINAL "
	CMSG	+= STR0112 + DTOC(DDTASF) + CHR(13)+CHR(10) //"DATA ASF "
	EFROM 	:= ALLTRIM(GETMV("MV_RELFROM"))//ALLTRIM(USRRETNAME(RETCODUSR())) + "<" + ALLTRIM(USRRETMAIL(RETCODUSR())) + ">"
	CPARA 	:= GETMV("MV_LOCX058",,"")
	CTITULO	:= STR0113 //"ASF COM PERÍODO DIVERGENTE"

	IF LEN(CMSG) > 0
		LOCA01313( EFROM, CPARA, CCC, CTITULO, CMSG, /*CLSTANEXOS*/, CCCO)	// ROTINA DE ENVIO DE E-MAIL PADRÃO
	ENDIF

	FQ5->( RESTAREA(ASAVDTQ) )
	RESTAREA(AAREA)

RETURN LRET

// ======================================================================= \\
STATIC FUNCTION CHECKASG2
Local AAREA		:= GETAREA()
Local ASAVDTQ	:= FQ5->( GETAREA() )
Local LRET		:= .T.
Local NDIAS		:= 0
Local EFROM, CPARA , CCC, CTITULO, CMSG, CCCO 	/*, CLSTANEXOS*/
Local CASF		:= FQ5->FQ5_AS 					// NUMERO DA ASF
Local DDTASF	:= FQ5->FQ5_DATGER 				// DATA DA ASF

Default ALINALT := {}

	IF FQ5->FQ5_TPAS # 'F' .OR. !(ASCAN(ALINALT, {|LINHA| FQ5->FQ5_VIAGEM==LINHA[2]}) > 0 )
		RETURN 										// NAO EH ASF OU NAO FOI LINHA ALTERADA SAI DA ROTINA
	ENDIF

	DBSELECTAREA("FQ5")
	DBSETORDER(1) 									// FQ5_FILIAL + FQ5_VIAGEM
	MSSEEK(XFILIAL('FQ5')+FQ7->FQ7_VIAORI) 			// POSICIONA ASG
	IF DDTASF < (FQ5->FQ5_DATINI-30) .OR. DDTASF > (FQ5->FQ5_DATFIM+30)
		LRET := .F.
		IF DDTASF < (FQ5->FQ5_DATINI-30)
			NDIAS := DDTASF - FQ5->FQ5_DATINI
		ELSEIF DDTASF > (FQ5->FQ5_DATFIM+30)
			NDIAS := DDTASF - FQ5->FQ5_DATFIM
		ENDIF
	ELSE
		RETURN 										// SE NÃO FEZ A CONTAGEM DE DIAS FORA DO PERÍODO SAI DA ROTINA, POIS
	ENDIF

	// ENVIA E-MAIL DE AVISO QUE A ASF ESTÁ FORA DO PERÍODO DA ASG (FQ5_DATINI -30 DIAS E FQ5_DATFIM +30 DIAS)
	CCC	 	:= ""
	CCCO 	:= ""
	CMSG 	:= STR0105 + CASF + STR0106 + STR(ABS(NDIAS),5,0) + IIF(NDIAS<0,STR0107,STR0108) + CHR(13)+CHR(10) //'ESTE E-MAIL É PARA INFORMAR QUE A ASF "'###'" ESTÁ '###' DIAS ABAIXO DA DATA INICIAL.'###' DIAS ACIMA DA DATA FINAL.'
	CMSG	+= CHR(13)+CHR(10) + STR0109 + FQ5->FQ5_AS + " :" + CHR(13)+CHR(10) //'DATAS LIMITES DA AS Nº "'
	CMSG	+= STR0110 + DTOC(FQ5->FQ5_DATINI) + CHR(13)+CHR(10) //"DATA INICIAL "
	CMSG	+= STR0111 + DTOC(FQ5->FQ5_DATFIM) + CHR(13)+CHR(10) + CHR(13)+CHR(10) //"DATA FINAL "
	CMSG	+= STR0112 + DTOC(DDTASF) + CHR(13)+CHR(10) //"DATA ASF "
	EFROM 	:= ALLTRIM(GETMV("MV_RELFROM"))//ALLTRIM(USRRETNAME(RETCODUSR())) + "<" + ALLTRIM(USRRETMAIL(RETCODUSR())) + ">"
	CPARA 	:= GETMV("MV_LOCX058",,"")
	CTITULO	:= STR0113 //"ASF COM PERÍODO DIVERGENTE"

	IF LEN(CMSG) > 0
		LOCA01313( EFROM, CPARA, CCC, CTITULO, CMSG, /*CLSTANEXOS*/, CCCO)	// ROTINA DE ENVIO DE E-MAIL PADRÃO
	ENDIF

	FQ5->( RESTAREA(ASAVDTQ) )
	RESTAREA(AAREA)

RETURN LRET


// ======================================================================= \\
FUNCTION LOCA01312()
	RPCSETTYPE(3)
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO ""
	DBSELECTAREA('FQ5')
	DBSELECTAREA('FPS')
	DBSELECTAREA('FQ7')
	CHECKASG()
	RESET ENVIRONMENT
RETURN

// ======================================================================= \\
STATIC FUNCTION ENVMLIFT(_AREGI)
Local _CHTMP := ""
Local _NI    := 0

	_CHTMP += "<HTML>"
	_CHTMP +=     "<TABLE BORDER=0 WIDTH=800>"
	_CHTMP +=     "    <TR>"
	_CHTMP +=     "    </TR>"
	_CHTMP +=     "</TABLE>"
	_CHTMP +=     "<BR>"
	_CHTMP +=     "<P1>"+STR0114+"</P1>" //"<P1>REMESSA PARA LOCAÇÃO </P1>"
	_CHTMP +=     "<BR>"
	_CHTMP +=     "<BR>"
	_CHTMP +=     "<TABLE BORDER=1 >"
	_CHTMP +=         "<TR>"
	_CHTMP +=             "<TH>"+STR0115+"</TH>" //"<TH>PEDIDO</TH>"
	_CHTMP +=             "<TH>"+STR0116+"</TH>" //"<TH>CLIENTE/LOJA</TH>"
	_CHTMP +=             "<TH>"+STR0117+"</TH>" //"<TH>NOME</TH>"
	_CHTMP +=             "<TH>"+STR0118+"</TH>" //"<TH>DATA</TH>"
	_CHTMP +=             "<TH>"+STR0119+"</TH>" //"<TH>A.S.</TH>"
	FOR _NI := 1 TO LEN(_AREGI)
		DBSELECTAREA("FP0")
		FP0->( DBSETORDER(1) )
		FP0->( DBSEEK( XFILIAL("FP0")+_AREGI[_NI,1] ) )
		DBSELECTAREA("SC5")
		SC5->( DBSETORDER(1) )
		SC5->( DBSEEK( XFILIAL("SC5")+_AREGI[_NI,4] ) )
		_CHTMP +=     "<TR>"
		_CHTMP +=         "<TD>"+SC5->C5_NUM+"</TD>"
		_CHTMP +=         "<TD>"+FP0->FP0_CLI+"-"+FP0->FP0_LOJA+"</TD>"
		_CHTMP +=         "<TD>"+FP0->FP0_CLINOM+"</TD>"
		_CHTMP +=         "<TD>"+DTOC(SC5->C5_EMISSAO)+"</TD>"
		_CHTMP +=         "<TD>"+SC5->C5_AS+"</TD>"
		_CHTMP +=     "</TR>"
	NEXT _NI
	_CHTMP +=     "</TABLE>"
	_CHTMP += "</HTML>"

	EFROM	:= ""
	CCC		:= ""
	CANEXO	:= ""
	CCCO	:= ""
	CTITULO	:= STR0120 //"LIFT - REMESSA PARA LOCAÇÃO"
	CPARA	:= ALLTRIM(GETMV("MV_LOCX233"))

	LOCA05909( EFROM, CPARA , CCC, CTITULO, _CHTMP, CANEXO, CCCO)

RETURN NIL

// ======================================================================= \\
STATIC FUNCTION GETASORI(CVIAGEM)
Local AAREA		:= GETAREA()
Local AAREADTQ	:= FQ5->(GETAREA())
Local CRET		:= ""
Local CQUERY	:= ""

	DBSELECTAREA("FQ5")
	DBSETORDER(1)

	// --> POSICIONA CONJUNTO TRANSPORTADORES
	IF SELECT("TRAB_VIAORI") > 0
		TRAB_VIAORI->(DBCLOSEAREA())
	ENDIF

	/*
	+ CVIAGEM +
	*/

	CQUERY := " SELECT DTQ.R_E_C_N_O_ FQ5_RECNO "
	CQUERY += " FROM " + RETSQLNAME('FPS') + " ZLW"
	CQUERY +=        " JOIN " + RETSQLNAME('FQ5') + " DTQ ON FPS_VIAORI = FQ5_VIAGEM"
	CQUERY += " WHERE ZLW.D_E_L_E_T_ = '' AND DTQ.D_E_L_E_T_ = ''"
	CQUERY +=   " AND FPS_VIAGEM = ? "
	CQUERY := CHANGEQUERY(CQUERY)
	aBindParam := {CVIAGEM}
	MPSysOpenQuery(cQuery,"TRAB_VIAORI",,,aBindParam)
	//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRAB_VIAORI", .F., .T.)

	FQ5->(DBGOTO( TRAB_VIAORI->FQ5_RECNO ))
	CRET := FQ5->FQ5_AS

	IF SELECT("TRAB_VIAORI") > 0
		TRAB_VIAORI->(DBCLOSEAREA())
	ENDIF

	// --> POSICIONA CONJUNTO TRANSPORTADORES
	IF SELECT("TRAB_VIAORI") > 0
		TRAB_VIAORI->(DBCLOSEAREA())
	ENDIF

	/*
	+ CVIAGEM +
	*/

	CQUERY := " SELECT DTQ.R_E_C_N_O_ FQ5_RECNO "
	CQUERY += " FROM " + RETSQLNAME('FQ7') + " ZUC"
	CQUERY +=        " JOIN " + RETSQLNAME('FQ5') + " DTQ ON FQ7_VIAORI = FQ5_VIAGEM"
	CQUERY += " WHERE ZUC.D_E_L_E_T_ = '' AND DTQ.D_E_L_E_T_ = ''"
	CQUERY +=   " AND FQ7_VIAGEM = ? "
	CQUERY := CHANGEQUERY(CQUERY)
	aBindParam := {CVIAGEM}
	MPSysOpenQuery(cQuery,"TRAB_VIAORI",,,aBindParam)
	//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),"TRAB_VIAORI", .F., .T.)

	FQ5->(DBGOTO( TRAB_VIAORI->FQ5_RECNO ))
	CRET := FQ5->FQ5_AS

	IF SELECT("TRAB_VIAORI") > 0
		TRAB_VIAORI->(DBCLOSEAREA())
	ENDIF

	RESTAREA(AAREADTQ)
	RESTAREA(AAREA)

RETURN(CRET)

// ======================================================================= \\
STATIC FUNCTION GETTIPOAS(CFROTA)
Local CRET		:= "E"
Local AAREA		:= GETAREA()
Local AAREAST9	:= ST9->(GETAREA())

	DBSELECTAREA("ST9")
	DBSETORDER(1)
	IF DBSEEK(XFILIAL("ST9")+CFROTA)
		IF ST9->T9_TIPOSE == "T"
			CRET := "T"
		ENDIF
	ENDIF

	RESTAREA(AAREAST9)
	RESTAREA(AAREA)

RETURN(CRET)



// ======================================================================= \\
STATIC FUNCTION CHEKOBRA(CINDICE)
Local LRET		:= .T.
Local AAREA		:= GETAREA()
Local AAREAZA1	:= FP1->(GETAREA())

	DBSELECTAREA("FP1")
	DBSETORDER(1)
	IF !DBSEEK(XFILIAL("FP1")+CINDICE)
		LRET := .F.
	ENDIF

	RESTAREA(AAREAZA1)
	RESTAREA(AAREA)

RETURN(LRET)

// ======================================================================= \\
FUNCTION LOCA01313(_CREMET , _CDEST , _CCC , _CASSUNTO , CBODY , _CANEXO , _CCCO , _LMSG)
Local CSERVER    := ALLTRIM(GETMV("MV_RELSERV"))      	// SERVIDOR PARA ENVIO DE EMAIL
Local CACCOUNT   := ALLTRIM(GETMV("MV_RELACNT")) 		// NOME DA CONTA A SER UTILIZADA
Local CENVIA     := ALLTRIM(GETMV("MV_RELFROM"))    	// EMAIL DE ENVIO
Local CRECEBE    := _CDEST              			  	// EMAIL DO DESTINATÁRIO
Local CPASSWORD  := ALLTRIM(GETMV("MV_RELPSW"))   		// DEFINE A SENHA DA CONTA A SER USADA PARA AUTENTICAÇÃO
Local AFILES     := {}
Local CMENSAGEM  := ""
Local LCONECTOU  := .F.
Local LDISCONECT := .F.

	CMENSAGEM := CBODY

	CONNECT SMTP SERVER CSERVER ACCOUNT CACCOUNT PASSWORD CPASSWORD RESULT LCONECTOU// EFETUA AUTENTICAÇÃO

	MAILAUTH(CACCOUNT, CPASSWORD)
	IF LCONECTOU
		//CONOUT("##GRCONTR.PRW## CONECTADO COM SERVIDOR DE E-MAIL - " + CSERVER)
	ENDIF

	// ARQUIVOS A SEREM ATACHADOS
	AFILES := { _CANEXO }

	SEND MAIL FROM CENVIA ;
	TO CRECEBE ;
	SUBJECT _CASSUNTO ;
	BODY CMENSAGEM ;
	RESULT LENVIADO

	IF LENVIADO
		//CONOUT("##GRCONTR.PRW## ENVIADO E-MAIL - ASSUNTO: ["+ALLTRIM(_CASSUNTO)+"] - PARA: ["+ALLTRIM(_CDEST)+"]")
	ELSE
		CMENSAGEM := ""
		GET MAIL ERROR CMENSAGEM
		//ALERT(CMENSAGEM)
		//conout(CMENSAGEM)
	ENDIF

	DISCONNECT SMTP SERVER RESULT LDISCONECT

	IF LDISCONECT
		//CONOUT("##GRCONTR.PRW## DESCONECTOU DO ENVIO DO ORCAMENTO")
	ENDIF

RETURN

// --------------------------------------------------------------------------
/*/{PROTHEUS.DOC} RETFILGRV
RETORNA A FILIAL QUE VAI SER GRAVADA NO REGISTRO.
@AUTHOR  IT UP BUSINESS
@SINCE   21/04/2019
@type Function
/*/
// --------------------------------------------------------------------------
STATIC FUNCTION RETFILGRV(CCAMPO)
Local CINFRET  := ""
Local LVLDFIL  := SUPERGETMV("MV_LOCX085",.F.,.T.)			// GETMV("MV_LOCX085" , , .F.)
Local CFILPROJ := FP0->FP0_FILIAL

Default CCAMPO := ""

	DO CASE
	CASE ALLTRIM(CCAMPO) == "FQ5_FILIAL"
		IF LVLDFIL
			IF EMPTY(XFILIAL("FQ5"))
				CINFRET := XFILIAL("FQ5")
			ELSE
				CINFRET := CFILPROJ
			ENDIF
		ELSE
			CINFRET     := XFILIAL("FQ5")
		ENDIF
	CASE ALLTRIM(CCAMPO) == "FQ5_FILORI"
		IF LVLDFIL
			CINFRET     := CFILPROJ
		ELSE
			CINFRET     := CFILANT
		ENDIF
	ENDCASE

RETURN CINFRET

// Rotina para geracao dos titulos provisorios
// Frank Zwarg Fuga em 17/03/2021
Static Function GerPRx
	Private oSay
	FWMsgRun(, {|oSay| GerPRx2(oSay) }, STR0201, STR0202) //"Títulos provisórios"###"Gerando a movimentação financeira."
Return .T.

// Rotina para funcionamento com outras funções do Rental
Function LOCA01315(aProvisorio)
Private oSay
Default aProvisorio := {}

	If len(aProvisorio) == 0
		Return .T.
	EndIf

	FWMsgRun(, {|oSay| GerPRx2(oSay, aProvisorio) }, STR0201, STR0202) //"Títulos provisórios"###"Gerando a movimentação financeira."
Return .T.

// Rotina para geracao dos titulos provisorios
// Frank Zwarg Fuga em 17/03/2021
Static Function GerPRx2(oSay, aProvisorio)
Local cTipoGer 		:= "1" // por default manteremos sempre como geração por ciclo
Local aGerar        := {}
Local nX
Local cCliente
Local cLoja
Local cNomeCli
Local dEmissao
Local nValor
Local cHist
Local cCc
Local cCondic
Local aPgto 		:= {}
Local dNewData
Local nY
Local cQuery
Local cNumTit
Local aVetSE1
Local cParc 		:= Criavar("E1_PARCELA")
Local cNatureza 	:= SUPERGETMV("MV_LOCX065" ,.T.,"" )
Local _MV_MOEDA 	:= 1
Local cCampo
Local lLc13Prv 		:= EXISTBLOCK("LC13PRV")
Local dOld
Local lErroExec		:= .F.
Local cObra
Local cSeqGru
Local cAs

Private lMsErroAuto
Default aProvisorio := {}

	If len(aProvisorio) == 0
		Return .T.
	EndIf

	// DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "2"
            cTipoGer := "2"
        EndIf
    EndIf

	// Deletar os provisorios
	For nX := 1 to len(aProvisorio)
		LOCA013DEL(2, FP0->FP0_PROJET, aprovisorio[nX,3])
	Next

	If cTipoGer == "1" // Gerar por ciclo
		For nX := 1 to len(aProvisorio)
			cCliente := aProvisorio[nX,5,2,2]
			cLoja    := aProvisorio[nX,5,3,2]

			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

			cNomeCli := SA1->A1_NREDUZ
			dEmissao := aProvisorio[nX,9]
			nValor   := aProvisorio[nX,2]
			cHist    := "RENTAL: " + aProvisorio[nX,3]
			cCc      := aProvisorio[nX,4]

			cObra	 := aProvisorio[nX,7]
			cSeqGru  := aProvisorio[nX,8]
			cAs		 := aProvisorio[nX,3]

			aadd(aGerar,{cCliente,cLoja,cNomeCli,dEmissao,nValor,cHist,cCc,cObra,cSeqGru,cAs})
		Next
	EndIF

	If cTipoGer == "2" // Gerar por ciclo + cond.pgto
		For nX := 1 to len(aProvisorio)
			cCliente := aProvisorio[nX,5,2,2]
			cLoja    := aProvisorio[nX,5,3,2]

			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

			cNomeCli := SA1->A1_NREDUZ

			dNewData := DataValida(aProvisorio[nX,9], .T.)
			If aProvisorio[nX,9] <> dNewData .and. month(dNewData) <> month(aProvisorio[nX,9])
				dNewData := DataValida(aProvisorio[nX,9], .F.)
			EndIF

			dEmissao := dNewData
			nValor   := aProvisorio[nX,2]
			cHist    := "Rental: " + aProvisorio[nX,3]
			cCc      := aProvisorio[nX,4]
			cCondic  := aProvisorio[nX,6] 

			cObra	 := aProvisorio[nX,7]
			cSeqGru  := aProvisorio[nX,8]
			cAs		 := aProvisorio[nX,3]


			aPgto := Condicao(nValor,cCondic,,dNewData)
			For nY := 1 to len(aPgto)

				dNewData := DataValida(aPgto[nY,1], .T.)
				//If aPgto[nY,1] <> dNewData .and. month(dNewData) <> month(aPgto[nY,1])
				//	dNewData := DataValida(aPgto[nY,1], .F.)
				//EndIF

				aadd(aGerar,{cCliente,cLoja,cNomeCli,dNewData,aPgto[nY,2],cHist,cCc,cObra,cSeqGru,cAs})
			Next
		Next
	EndIF

	// Geracao da numeracao do titulo provisorio
	cParc := StrZero(0,Len(cParc))
	cAs := ""
	For nX := 1 to len(aGerar)
		If cAs <> aGerar[nX,10]
			cQuery := " SELECT MAX(E1_NUM) REG "
			cQuery += " FROM " + RETSQLNAME("SE1") + " SE1 "
			cQuery += " WHERE SE1.E1_FILIAL = ? "
			cQuery += " AND SE1.E1_PREFIXO = 'REN' "
			cQuery += " AND SE1.D_E_L_E_T_ = '' "
			If Select("TRBVLD") > 0
				TRBVLD->(dbCloseArea())
			EndIf
			cQuery := ChangeQuery(cQuery)
			aBindParam := {xFilial("SE1")}
			MPSysOpenQuery(cQuery,"TRBVLD",,,aBindParam)
			cNumTit := TRBVLD->REG
			If empty(cNumTit)
				cNumTit := "000000001"
			Else
				cNumTit := soma1(cNumTit)
			EndIF
			TRBVLD->(DBCLOSEAREA())
			cAs := aGerar[nX,10]
		EndIf

		cParc := StrZero((Val(cParc)+1),Len(cParc))

		aVetSE1 := {}
		aAdd(aVetSE1, {"E1_FILIAL",  xFilial("SE1"), Nil})
		aAdd(aVetSE1, {"E1_NUM",     cNumTit,        Nil})
		aAdd(aVetSE1, {"E1_PREFIXO", "REN",          Nil})
		aAdd(aVetSE1, {"E1_PARCELA", cParc, 		 Nil})
		aAdd(aVetSE1, {"E1_TIPO",    "PR",           Nil})
		aAdd(aVetSE1, {"E1_NATUREZ", cNatureza,      Nil})
		aAdd(aVetSE1, {"E1_CLIENTE", aGerar[nX,1],   Nil})
		aAdd(aVetSE1, {"E1_LOJA",    aGerar[nX,2],   Nil})
		aAdd(aVetSE1, {"E1_NOMCLI",  aGerar[nX,3],   Nil})
		aAdd(aVetSE1, {"E1_EMISSAO", aGerar[nX,4],   Nil})
		aAdd(aVetSE1, {"E1_VENCTO",  aGerar[nX,4],   Nil})
		aAdd(aVetSE1, {"E1_VENCREA", aGerar[nX,4],   Nil})
		aAdd(aVetSE1, {"E1_VALOR",   aGerar[nX,5],   Nil})
		aAdd(aVetSE1, {"E1_HIST",    aGerar[nX,6],   Nil})
		aAdd(aVetSE1, {"E1_MOEDA",   FP0->FP0_MOEDA, Nil})
		aAdd(aVetSE1, {"E1_CCUSTO",  aGerar[nX,7],   Nil})

		If FP0->FP0_MOEDA <> _MV_MOEDA
			SM2->(dbSetOrder(1))
			SM2->(dbSeek(dtos(dNewData)))
			cCampo := "SM2->M2_TXMOED"+alltrim(str(FP0->FP0_MOEDA))
			aAdd(aVetSE1, {"E1_TXMOEDA", &(cCampo),  Nil})
		EndIF

		If lLc13Prv
			aVetSE1 := EXECBLOCK("LC13PRV" , .T. , .T. , {aVetSE1})
		EndIf

		dOld := dDataBase
		dDataBase := aGerar[nX,4]

		SED->(dbSetOrder(1))
		SED->(dbSeek(xFilial("SED")+cNatureza))

		lMsErroAuto := .F.
		lErroExec   := .F.
		MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

		SE1->(dbSetOrder(1))
		If !SE1->(dbSeek(xFilial("SE1")+"REN"+cNumTit+cParc))
			lMsErroAuto := .T.
			DisarmTransaction()
			lErroExec := .t.
		EndIF
		
		If !lErroExec
			FQB->(RecLock("FQB",.T.))
			FQB->FQB_FILIAL := xFilial("FQB")
			FQB->FQB_PROJET := FP0->FP0_PROJET
			FQB->FQB_OBRA   := aGerar[nX,8]
			FQB->FQB_SEQGRU := aGerar[nX,9]
			FQB->FQB_AS     := aGerar[nX,10]
			FQB->FQB_PR     := SE1->E1_NUM
			FQB->FQB_PREF   := SE1->E1_PREFIXO
			FQB->FQB_PARC   := SE1->E1_PARCELA
			FQB->FQB_PERIOD := aGerar[nX,4]
			FQB->(MsUnlock())
		EndIf

		dDataBase := dOld

	Next

Return .T.


// Rotina para geracao dos titulos provisorios
// Frank Zwarg Fuga em 17/03/2021
Static Function GerPRx2old(oSay)
Local _lRet 		:= .t.
Local _aArea 		:= GetArea()
Local _cProj    	:= FP0->FP0_PROJET
Local _dIni
Local _dFim
Local _dFat			:= ctod("")
Local _cFil
Local _nX
Local _dTemp
Local _aPeriodos 	:= {}
Local _cTesFat
Local _cQuery
Local _aVetSE1
Local _cNumTit
Local _cNatureza 	:= SUPERGETMV("MV_LOCX065" ,.T.,"" )  // antes era o mv_locx279
Local _dVenc
Local _dNewData
Local _dOld
Local _lGeraNum
Local _cAsX
Local _nParc 		:= Criavar("E1_PARCELA")
Local _MV_MOEDA 	:= 1
Local cCliFat 		:= ""
Local cLojFat 		:= ""
Local lMvLocBac 	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local aBindParam
Local lErroExec 	:= .f.
Local lLc13Prv 		:= EXISTBLOCK("LC13PRV")
Local cTipoGer 		:= "1" // por default manteremos sempre como geração por ciclo
Local aGerar	 	:= {}
Local aPgto			:= {}
Local nY
Local lPassa

	/* DSERLOCA-6564 - Frank em 04/07/2025
	Sobre a variável cTipoGer
	Se o valor for "1" indica que a geração dos provisórios atende somente o ciclo de faturamento
	Se o valor for "2" além do ciclo de faturamente também levaremos em consideração a condição de pagamento
	*/

	// DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "2"
            cTipoGer := "2"
        EndIf
    EndIf

	_cTesFat	 := SUPERGETMV("MV_LOCX080" ,.T.,"" )

	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA")+_cProj))

	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0")+_cProj))
	FP1->(dbSetOrder(1))
	FP1->(dbSeek(xFilial("FP0") + _cProj + FPA->FPA_OBRA))

	While !FPA->(eof()) .and. FPA->FPA_PROJET == _cProj
		If FPA->FPA_QUANT > 0 .and. !empty(FPA->FPA_AS) .and. FPA->FPA_VRHOR > 0 .and. empty(FPA->FPA_NFRET)
			_dIni  := FPA->FPA_DTINI
			_dFim  := FPA->FPA_DTENRE
			_dFat  := FPA->FPA_DTFIM
			_cFil  := FPA->FPA_FILEMI
			//If empty(FPA->FPA_GERAEM)
				_dTemp := FPA->FPA_DTFIM      //_dTemp := FPA->FPA_DTINI
			//Else
			//	_dTemp := FPA->FPA_GERAEM
			//EndIf
			_nMes  := 0

			// Passo 1 - Verificar os ciclos de faturamento que podem existir neste período
			While _dTemp <= _dFim
				if month(_dTemp) <> _nMes
					_nMes := month(_dTemp)
					//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
					If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT)
						cCliFat := FPA->FPA_CLIFAT
						cLojFat := FPA->FPA_LOJFAT
					ElseIf !Empty(FP1->FP1_CLIDES)
						cCliFat := FP1->FP1_CLIDES
						cLojFat := FP1->FP1_LOJDES
					Else
						cCliFat := FP0->FP0_CLI
						cLojFat := FP0->FP0_LOJA
					EndIf
					//               1       2    3             4              5            6               7               8              9
					//aadd(_aPeriodos,{_dTemp, .T., FP0->FP0_CLI, FP0->FP0_LOJA, FPA->FPA_AS, FPA->FPA_VRHOR, FPA->(Recno()), FPA->FPA_OBRA, FPA->FPA_SEQGRU })
					// Inclusão CC para SE1 - DSERLOCA 4826 - Rossana 09/12/24
					aadd(_aPeriodos,{_dTemp, .T., cCliFat, cLojFat, FPA->FPA_AS, FPA->FPA_VRHOR, FPA->(Recno()), FPA->FPA_OBRA, FPA->FPA_SEQGRU, FPA->FPA_CUSTO, FPA->FPA_CONPAG, _dTemp })
				endif
				_dTemp ++
			EndDo
			For _nX:=1 to len(_aPeriodos) // deixar todos os registros com o dia do próximo faturamento
				If day(lastday(ctod("01/"+str(month(_aPeriodos[_nX,1]))+"/"+str(year(_aPeriodos[_nX,1]))))) < day(_dFat)
					_aPeriodos[_nX,1] := lastday(ctod("01/"+str(month(_aPeriodos[_nX,1]))+"/"+str(year(_aPeriodos[_nX,1]))))
				Else
					_aPeriodos[_nX,1] := ctod(str(day(_dFat))+"/"+str(month(_aPeriodos[_nX,1]))+"/"+str(year(_aPeriodos[_nX,1])))
				EndIF
				// se a data final for maior que o último periodo gera mais uma parcela com vencimento na data final / 				
				If _nX==len(_aPeriodos)
					If _dFim > _aPeriodos[_nX,1]
						aadd(_aPeriodos,{_dFim, .T., cCliFat, cLojFat, FPA->FPA_AS, FPA->FPA_VRHOR, FPA->(Recno()), FPA->FPA_OBRA, FPA->FPA_SEQGRU, FPA->FPA_CUSTO, FPA->FPA_CONPAG, _dFim })
						Exit
					EndIf
				EndIf
			Next

			aBindParam := {}
			// Passo 2 - Verificar para cada ciclo se já foram emitidos faturamento
			If !lMvLocBac
				_cQuery := " SELECT C6_NUM "
				_cQuery += " FROM " + RETSQLNAME("SC6") + " SC6 "
				_cQuery += " WHERE SC6.C6_FILIAL = ? "
				aadd(aBindParam,_cFil)
				_cQuery += " AND SC6.C6_XAS = ? "
				aadd(aBindParam,FPA->FPA_AS)
				_cQuery += " AND SC6.C6_TES = ? "
				aadd(aBindParam,_cTesFat)
				_cQuery += " AND SC6.D_E_L_E_T_ = '' "
			Else
				_cQuery := " SELECT R_E_C_N_O_ REG "
				_cQuery += " FROM " + RETSQLNAME("FPZ") + " FPZ "
				_cQuery += " WHERE FPZ.FPZ_FILIAL = ? AND "
				aadd(aBindParam,_cFil)
				_cQuery += " FPZ.FPZ_AS = ? AND "
				aadd(aBindParam,FPA->FPA_AS)
				_cQuery += " FPZ.D_E_L_E_T_ = '' "
			EndIF
			_cQuery := changequery(_cQuery)
			IF SELECT("TRBVLD") > 0
				TRBVLD->(DBCLOSEAREA())
			ENDIF
			MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)

			While !TRBVLD->(Eof())

				If !lMvLocBac
					For _nX:=1 to len(_aPeriodos)
						If _aPeriodos[_nX,5] == FPA->FPA_AS .and. _aPeriodos[_nX,1] >= FPA->FPA_DTINI .and. _aPeriodos[_nX,1] <= FPA->FPA_DTENRE
							_aPeriodos[_nX,2] := .F.
						EndIf
					Next
				Else
					
					FPZ->(dbGoto(TRBVLD->REG))

					FPY->(dbSetOrder(1))
					If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))

						lPassa := .F.
						If FWIsInCallStack("LOCA24817") .or. FWIsInCallStack("LOCA048") .or. FWIsInCallStack("LOCA013") 
							lPassa := .T.
						Else
							If alltrim(FPY->FPY_STATUS) <> '2' .and. FPY->FPY_TIPFAT <> "R"
								lPassa := .T.
							EndIf
						EndIf
						
						If lPassa
							For _nX:=1 to len(_aPeriodos)
								If _aPeriodos[_nX,12] < FPA->FPA_DTFIM 
									_aPeriodos[_nX,2] := .F.	
								EndIf
							Next
						EndIf

					EndIf

				EndIf
				TRBVLD->(dbSkip())
			EndDo

			TRBVLD->(DBCLOSEAREA())

		EndIF
		FPA->(dbSkip())
	EndDo

	If len(_aPeriodos) > 0

		// Excluir os provisorios
		For _nX := 1 to len(_aPeriodos)

			If !_aPeriodos[_nX,2]
				Loop
			EndIf

			// Verificar se existem outras moedas envolvidas.
			// Frank - 26/08/21
			_dVenc := _aPeriodos[_nX,1]
			_dNewData := DataValida(_dVenc, .T.)
			_lBloqx := .F.
			If FP0->FP0_MOEDA <> _MV_MOEDA
				SM2->(dbSetOrder(1))
				If SM2->(dbSeek(dtos(_dNewData)))
					_cMoedaX := "SM2->M2_MOEDA"+alltrim(str(FP0->FP0_MOEDA))
					If &(_cMoedaX) == 0
						_lBloqX := .T.
					EndIF
				Else
					_lBloqX := .T.
				EndIF
			EndIF

			If _lBloqX
				MsgAlert(STR0121+dtoc(_dNewData),STR0122) //"Atenção não foi localizado no cadastro de moeda a cotação do dia: "###"Título provisório não criado."
				//DisarmTransaction()
				RestArea(_aArea)
				Return .F.
			EndIF

			// Deleta os títulos provisórios
			LOCA013DEL(2, FP0->FP0_PROJET, _aPeriodos[_nX,5])

		Next

		// Incluir os provisorios

		/* DSERLOCA-6564 - Frank em 04/07/2025	
		Estrutura do _aPeriodos
		1  = _dTemp, 
		2  = .T., 
		3  = cCliFat, 
		4  = cLojFat, 
		5  = FPA->FPA_AS, 
		6  = FPA->FPA_VRHOR, 
		7  = FPA->(Recno()), 
		8  = FPA->FPA_OBRA, 
		9  = FPA->FPA_SEQGRU, 
		10 = FPA->FPA_CUSTO
		11 = FPA->FPA_CONPAG
		12 = Data de emissao
		*/
		aGerar := {}
		If len(_aPeriodos) > 0
			For _nX := 1 to len(_aPeriodos)
				
				If !_aPeriodos[_nX,2]
					Loop
				EndIf

				If cTipoGer == "1" // Gerar por ciclo
					aadd(aGerar,{_aPeriodos[_nX,1],;
					             _aPeriodos[_nX,2],;
								 _aPeriodos[_nX,3],;
								 _aPeriodos[_nX,4],;
								 _aPeriodos[_nX,5],;
								 _aPeriodos[_nX,6],;
								 _aPeriodos[_nX,7],;
								 _aPeriodos[_nX,8],;
								 _aPeriodos[_nX,9],;
								 _aPeriodos[_nX,10],;
								 _aPeriodos[_nX,11],;
								 _aPeriodos[_nX,12]})
				Else // Gerar por ciclo + condição de pagamento
					_dVenc := _aPeriodos[_nX,1]
					_dNewData := DataValida(_dVenc, .T.)
					If _dVenc <> _dNewData .and. month(_dNewData) <> month(_dVenc)
						_dNewData := DataValida(_dVenc, .F.)
					EndIF
					aPgto := Condicao(_aPeriodos[_nX,6],_aPeriodos[_nX,11],,_dNewData)
					For nY := 1 to len(aPgto)
						aadd(aGerar,{aPgto[nY,1],;
					                 _aPeriodos[_nX,2],;
								     _aPeriodos[_nX,3],;
								     _aPeriodos[_nX,4],;
								     _aPeriodos[_nX,5],;
								     aPgto[nY,2],;
								     _aPeriodos[_nX,7],;
								     _aPeriodos[_nX,8],;
								     _aPeriodos[_nX,9],;
								     _aPeriodos[_nX,10],;
								     _aPeriodos[_nX,11],;
									 _aPeriodos[_nX,12]})
					Next
				EndIf

			Next
		EndIf

		_lGeraNum := .T.
		_cAsX     := ""
		_nParc    := StrZero(0,Len(_nParc))
		For _nX := 1 to len(aGerar)
			_nParc := StrZero((Val(_nParc)+1),Len(_nParc))

			If !aGerar[_nX,2] .or. aGerar[_nX,6] == 0
				Loop
			EndIf

			// Geracao da numeracao do titulo provisorio
			If _lGeraNum .or. _cAsx <> aGerar[_nX,5]

				_cQuery := " SELECT MAX(E1_NUM) REG "
				_cQuery += " FROM " + RETSQLNAME("SE1") + " SE1 "
				_cQuery += " WHERE SE1.E1_FILIAL = ? "
				_cQuery += " AND SE1.E1_PREFIXO = 'REN' "
				_cQuery += " AND SE1.D_E_L_E_T_ = '' "
				IF SELECT("TRBVLD") > 0
					TRBVLD->(DBCLOSEAREA())
				ENDIF
				_CQUERY := CHANGEQUERY(_CQUERY)
				aBindParam := {_cFil}
				MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)
				//TCQUERY _CQUERY NEW ALIAS "TRBVLD"
				_cNumTit := TRBVLD->REG
				If empty(_cNumTit)
					_cNumTit := "000000001"
				Else
					_cNumTit := soma1(_cNumTit)
				EndIF
				TRBVLD->(DBCLOSEAREA())
				_lGeraNum := .F.
				_cAsx := aGerar[_nX,5]
				_nParc := StrZero(1,Len(_nParc))
			EndIf

			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+aGerar[_nX,3]+aGerar[_nX,4]))

			_aVetSE1 := {}
			aAdd(_aVetSE1, {"E1_FILIAL",  _cFil,  				Nil})
			aAdd(_aVetSE1, {"E1_NUM",     _cNumTit,         	Nil})
			aAdd(_aVetSE1, {"E1_PREFIXO", "REN",            	Nil})
			aAdd(_aVetSE1, {"E1_PARCELA", _nParc, 				Nil})
			aAdd(_aVetSE1, {"E1_TIPO",    "PR",             	Nil})
			aAdd(_aVetSE1, {"E1_NATUREZ", _cNatureza,       	Nil})
			aAdd(_aVetSE1, {"E1_CLIENTE", aGerar[_nX,3],    Nil})
			aAdd(_aVetSE1, {"E1_LOJA",    aGerar[_nX,4],    Nil})
			aAdd(_aVetSE1, {"E1_NOMCLI",  SA1->A1_NREDUZ,     	Nil})

			If cTipoGer == "1"
				_dVenc := aGerar[_nX,1]
				// Tentar encontrar a data valida dentro do mês levando dias a mais
				_dNewData := DataValida(_dVenc, .T.)

				// Tentar encontrar a data valida dentro do mês levando dias a menos
				If _dVenc <> _dNewData .and. month(_dNewData) <> month(_dVenc)
					_dNewData := DataValida(_dVenc, .F.)
				EndIF
			Else
				_dNewData := aGerar[_nX,1]
			EndIf

			aAdd(_aVetSE1, {"E1_EMISSAO", aGerar[_nX,12],   Nil})
			aAdd(_aVetSE1, {"E1_VENCTO",  _dNewData,      	Nil})
			aAdd(_aVetSE1, {"E1_VENCREA", _dNewData,       	Nil})
			aAdd(_aVetSE1, {"E1_VALOR",   aGerar[_nX,6],    Nil})
			aAdd(_aVetSE1, {"E1_HIST",    "RENTAL: "+aGerar[_nX,5],   Nil})
			aAdd(_aVetSE1, {"E1_MOEDA",   FP0->FP0_MOEDA,   Nil})
			aAdd(_aVetSE1, {"E1_CCUSTO",  aGerar[_nX,10],   Nil})

			If FP0->FP0_MOEDA <> _MV_MOEDA
				SM2->(dbSetOrder(1))
				SM2->(dbSeek(dtos(_dNewData)))
				_cCampo := "SM2->M2_TXMOED"+alltrim(str(FP0->FP0_MOEDA))
				aAdd(_aVetSE1, {"E1_TXMOEDA",   &(_Ccampo),   Nil})
			EndIF

			IF  lLc13Prv
				_aVetSE1 := EXECBLOCK("LC13PRV" , .T. , .T. , {_aVetSE1})
			ENDIF

			_dOld     := dDataBase
			dDataBase := _dNewData

			SED->(dbSetOrder(1))
			SED->(dbSeek(xFilial("SED")+_cNatureza))

			lMsErroAuto := .F.
			MSExecAuto({|x,y| FINA040(x,y)}, _aVetSE1, 3)

			If lMsErroAuto 
				SE1->(DbSetOrder(1))
				If !SE1->(DbSeek(_cFil+"REN"+_cNumTit+_nParc+"PR"))
					MostraErro()
					DisarmTransaction()
					lErroExec := .t.
				EndIF
			EndIf

			If !lErroExec
				FQB->(RecLock("FQB",.T.))
				FQB->FQB_FILIAL := _cFil
				FQB->FQB_PROJET := FP0->FP0_PROJET
				FQB->FQB_OBRA   := aGerar[_nX,8]
				FQB->FQB_SEQGRU := aGerar[_nX,9]
				FQB->FQB_AS     := aGerar[_nX,5]
				FQB->FQB_PR     := SE1->E1_NUM
				FQB->FQB_PREF   := SE1->E1_PREFIXO
				FQB->FQB_PARC   := SE1->E1_PARCELA
				FQB->FQB_PERIOD := aGerar[_nX,12]
				FQB->(MsUnlock())
			EndIf

			dDataBase := _dOld
		Next
	EndIF
	RestArea(_aArea)
Return _lRet


// Recuperar a delecao do titulo provisorio quando excluir o faturamento
// Frank em 19/03/21
// Esta posicionada na SC5 e na SC6
Function RECPROV
Local _cAs
Local _cQuery
Local _nReg
Local _aArea := GetArea()
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

	If !lMvLocBac
		_cAs := SC6->C6_XAS
	Else
		_cAs := ""
		FPZ->(dbSetOrder(1))
		FPZ->(dbSeek(xFilial("FPZ")+SC6->C6_NUM))
		While !FPZ->(Eof())
			If FPZ->FPZ_ITEM == SC6->C6_ITEM
				dbSelectArea("FPY")
				FPY->(dbSetOrder(1))
				If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
					If FPY->FPY_STATUS <> "2"
						_cAs := FPZ->FPZ_AS
						exit
					EndIF
				EndIF
			EndIF
			FPZ->(dbSkip())
		EndDo
	EndIF

	_cQuery := " SELECT FPA.R_E_C_N_O_ REG "
	_cQuery += " FROM " + RETSQLNAME("FPA") + " FPA "
	_cQuery += " WHERE FPA.FPA_FILEMI = '"+xFilial("FPA")+"' "
	_cQuery += " AND FPA.FPA_AS = ? "
	_cQuery += " AND FPA.D_E_L_E_T_ = '' "
	IF SELECT("TRBVLD") > 0
		TRBVLD->(DBCLOSEAREA())
	ENDIF
	_CQUERY := CHANGEQUERY(_CQUERY)
	aBindParam := {_cAs}
	MPSysOpenQuery(_cQuery,"TRBVLD",,,aBindParam)
	If !TRBVLD->(Eof())
		_nReg := TRBVLD->REG
	EndIF
	TRBVLD->(DBCLOSEAREA())

	If _nReg > 0
		FPA->(dbGoto(_nReg))
		FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))

		// Passo 1 - deletar todos os provisorios da AS
		FQB->(dbSetOrder(1))
		FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
		While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET+FQB_AS) == xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS
			SE1->(dbSetOrder(1))
			SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
			While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
				_aVetSE1 := {}
				aAdd(_aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
				aAdd(_aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
				aAdd(_aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
				aAdd(_aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
				aAdd(_aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
				aAdd(_aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
				aAdd(_aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
				aAdd(_aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
				aAdd(_aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
				aAdd(_aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
				aAdd(_aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
				aAdd(_aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
				aAdd(_aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
				aAdd(_aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
				aAdd(_aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
				lMsErroAuto := .F.
				MSExecAuto({|x,y| FINA040(x,y)}, _aVetSE1, 5)
				If lMsErroAuto 
					MostraErro()
					DisarmTransaction()
					lErroExec := .t.
				EndIf
				SE1->(dbSkip())
			EndDo
			FQB->(RecLock("FQB",.F.))
			FQB->(dbDelete())
			FQB->(MsUnlock())
			FQB->(dbSkip())
		EndDo

		// Passo 2 - refazer os provisorios
		GerPRx()
	EndIF
	RestArea(_aArea)
Return .T.

// Rotina de geração do contrato e aprovação automática
// Frank Zwarg Fuga
Function LOCA013AUT(_cFilial, _cProjeto, _cObra, _cSeqGru, _lIncl, _lAlt, _aRot, _lAviso)
Local _aArea 	:= GetArea()
Local _aAreaFPA := FPA->(GetArea())
Local _lRet 	:= .T.
Local _cRet 	:= ""
Local cFilOld   := cFilAnt

Private INCLUI	:= _lIncl
Private ALTERA	:= _lAlt
Private _LTEMVINC := SUPERGETMV("MV_LOCX029",.F.,.T.)
//Private LVERZBX
Private AROTINA   := {}
Private CCADASTRO := STR0001 //"Apontador AS"
Private CPERG     := "LOCP010"
Private CSERV	  := ""
Private ACORES
//Private LMINUTA	  := SUPERGETMV("MV_LOCX097",.F.,.T.) //SUPERGETMV("MV_LOCX052",.F.,.T.) trocado a pedido do Lui em 19/08/21 Frank.
Private LROMANEIO := SUPERGETMV("MV_LOCX071",.F.,.T.)
Private LFUNCAS   := SUPERGETMV("MV_LOCX237" ,.F.,.F.)
Private LFILTFIL  := SUPERGETMV("MV_LOCX236",.F.,.T.)

Public DDT1      := CTOD("")
Public DDT2      := CTOD("")
Public CTP1      := ""
Public CFIL1     := ""
Public CFIL2     := ""

Default _cProjeto := ""
Default _cObra := ""
Default _cSeqGru := ""
Default _lIncl := ""
Default _lAlt := ""
Default _aRot := {}
Default _lAviso := .T.

	If empty(_cProjeto) .or. empty(_cObra) .or. empty(_cSeqGru)
		_lRet := .F.
		_cRet += STR0125 //"Falha no envio dos parâmetros."
	EndIf

//	LVERZBX := GETMV("MV_LOCX097",,.f.) 							// --> HABILITA CONTROLE DE MINUTA

	If _lRet
		FPA->(dbSetOrder(8))
		If FPA->(dbSeek(_cFilial+_cProjeto+_cObra+_cSeqGru))

			FP0->(dbSetOrder(1))
			FP0->(dbSeek(xFilial("FP0")+_cProjeto))
			FP1->(dbSetOrder(1))
			FP1->(dbSeek(xFilial("FP0")+_cProjeto+_cObra))
			_nRegFPA := FPA->(Recno())
			_nRegFP0 := FP0->(Recno())
			_nRegFP1 := FP1->(Recno())
			IF LOCA013(_lAviso)
				FPA->(dbGoto(_nRegFPA))
				FP0->(dbGoto(_nRegFP0))
				FP1->(dbGoto(_nRegFP1))
				DBSELECTAREA("FQ5")
				DBSETORDER(8)//PROJETO
				IF DBSEEK(XFILIAL("FQ5")+SUBSTR( _cProjeto, 1, 9))//SE GEROU O CONTRATO
					FP0->(RECLOCK("FP0",.F.))
					FP0->FP0_POSSIB := "100"
					FP0->(MSUNLOCK())

					cTempAS1 := "31"
					cTempAS1 += substr(FPA->FPA_AS,3,8)
					cTempAS2 := substr(FPA->FPA_AS,14,len(FPA->FPA_AS))

					//FQ5->(dbOrderNickName("ITUPFQ5008"))
					//FQ5->(dbSeek(xFilial("FQ5")+FPA->FPA_PROJET+FPA->FPA_OBRA))
					While !FQ5->(Eof()) .and. FQ5->(FQ5_FILIAL+substr(FQ5_SOT,1,9)) == xFilial("FQ5")+SUBSTR( _cProjeto, 1, 9)
						If FQ5->FQ5_AS == FPA->FPA_AS
							// Aprovação da locação
							_nRegFQ5 := FQ5->(Recno())
							LOCA05908(,,.F.)
							DBSETORDER(8)
							FQ5->(dbGoto(_nRegFQ5))
						EndIF
						If substr(FQ5->FQ5_AS,1,10) == cTempAS1 .and. substr(FQ5->FQ5_AS,14,len(FPA->FPA_AS)) == cTempAS2
							// Aprovação das linhas de frete

							FQ5->(RecLock("FQ5",.F.))
							FQ5->FQ5_DTINI	:= dDataBase //DDTINI
							FQ5->FQ5_DTFIM	:= dDataBase //DDTFIM
							FQ5->FQ5_HRINI	:= time() //CHRINI
							FQ5->FQ5_HRFIM	:= time() //CHRFIM
							FQ5->FQ5_TIPAMA	:= "" //CTPAMA
							FQ5->FQ5_PACLIS	:= "" //CPACLIS
							FQ5->FQ5_DTPROG	:= DDATABASE
							FQ5->FQ5_STATUS := "1"
							FQ5->(MsUnlock())

							_nRegFQ5 := FQ5->(Recno())
							LOCA05908(,,.f.)
							DBSETORDER(8)
							FQ5->(dbGoto(_nRegFQ5))

						EndIF
						FQ5->(dbSkip())
					EndDo

				EndIF

			ENDIF

		Else
			_lRet := .F.
			_cRet += STR0126 //"Registro não localizado na tabela de locação. "
		EndIF
	EndIF

	CFILANT := CFILOLD

	FPA->(RestArea(_aAreaFPA))
	RestArea(_aArea)
Return {_lRet, _cRet}


// Rotina para geração do titulo provisorio
// Frank Zwarg Fuga
// Criado por questão de não funcionar mais em pe a chamada das static function
function loca01318
	GerPRx()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SelGeraAs
Traz Grid para selecionar itens que irão gerar AS
@type function
@author			José Eulálio
@since     		08/12/2022
/*/
//-------------------------------------------------------------------
Static Function SelGeraAs(cProjFpa,cObraDe,cObraAte,lPergGerAs)
Local aArea     	:= GetArea()
Local lRet      	:= .F.
Local cPesqEv 		:= Space(50)
Local oOk       	:= LOADBITMAP( GETRESOURCES(), "LBOK")
Local oNo       	:= LOADBITMAP( GETRESOURCES(), "LBNO")
Local bLineFpa		:= {|| bLineFpa(.F.,.F.) }
Local bRet			:= {|| lRet := .T., oDlgFpa:End() }
Local nX			:= 0

Private oDlgFpa
Private oPesqEv
Private oLstFpa
Private aItensFpa   := {}
Private aLstBxOri 	:= {}
Private cCadastro 	:= ""

	AAdd(aItensFpa, { .F., "", "", "", "", "", "", .F. })

	Processa({|| TrazFpa(cProjFpa, cObraDe, cObraAte),  }, STR0138, STR0139, .t.) // "Localizando os itens." ### "Aguarde..."

	//se tiver pelo menos um preenchido ele executa
	If !Empty(aItensFpa[1][2])

		DEFINE MSDIALOG oDlgFpa TITLE STR0132 FROM 268,260 TO 630,896 PIXEL //"Itens do Projeto"

		//ListBox                                                                                                                                                                      312,139
		// 20
		@ 20,03 LISTBOX oLstFpa FIELDS HEADER "", STR0065, STR0133, STR0134, STR0135, STR0136, STR0137, STR0172	 SIZE 312,140 OF oDlgFpa PIXEL // "Obra" ###  "Seq.Gru" ### "Cod.Equip" ### "Nome Equip" ### "Cod. Prod." ### "Descrição" ### 'Bloqueio.Tae'
		oLstFpa:bLDblClick := bLineFpa

		//Processa({|| TrazFpa(oLstFpa, cProjFpa, oOk, oNo, cObraDe, cObraAte),  }, STR0138, STR0139, .t.) // "Localizando os itens." ### "Aguarde..."

		//carrega variavel
		oLstFpa:SetArray(aItensFpa)
		oLstFpa:bLine 	:= {|| { IF(	aItensFpa[oLstFpa:nAt,01],oOk,oNo),;
										aItensFpa[oLstFpa:nAt,02],;
										aItensFpa[oLstFpa:nAt,03],;
										aItensFpa[oLstFpa:nAt,04],;
										aItensFpa[oLstFpa:nAt,05],;
										aItensFpa[oLstFpa:nAt,06],;
										aItensFpa[oLstFpa:nAt,07],;
										aItensFpa[oLstFpa:nAt,08]}}


		oLstFpa:Refresh()
		IncProc()

		aLstBxOri := aClone(oLstFpa:aArray)

	//se tiver pelo menos um preenchido ele executa
	//If !Empty(aItensFpa[1][2])

		//só apresenta pesquisa quando tem mais de um
		If Len(aItensFpa) > 1
			//Texto de pesquisa
			@ 003,002 MsGet oPesqEv Var cPesqEv Size 257,009 COLOR CLR_BLACK PIXEL OF oDlgFpa

			//Interface para selecao de indice e filtro
			@ 003,260 Button STR0140    Size 043,012 PIXEL OF oDlgFpa Action IF(!Empty(oLstFpa:aArray[oLstFpa:nAt][2]),ITPESQEV(oLstFpa,cPesqEv,oOk,oNo),Nil) //"Pesq.Itens"
		EndIf

		//Botoes inferiores
		DEFINE SBUTTON FROM 162,003 TYPE 1	ENABLE OF oDlgFpa Action(Eval(bRet)) //OK

		@ 162,032 Button STR0141    Size 046,012 PIXEL OF oDlgFpa Action (Eval({|| bLineFpa(.T.,.F.) }))  //"(Des)Marca todos"

		@ 162,082 Button STR0142   Size 043,012 PIXEL OF oDlgFpa Action (Eval({|| bLineFpa(.F.,.T.) }))  //"Inverte"

		//Metodos da ListBox
		oLstFpa:SetArray(aItensFpa)
		oLstFpa:bLine 	:= {|| {IF(	aItensFpa[oLstFpa:nAt,01],oOk,oNo),;
									aItensFpa[oLstFpa:nAt,02],;
									aItensFpa[oLstFpa:nAt,03],;
									aItensFpa[oLstFpa:nAt,04],;
									aItensFpa[oLstFpa:nAt,05],;
									aItensFpa[oLstFpa:nAt,06],;
									aItensFpa[oLstFpa:nAt,07],;
									aItensFpa[oLstFpa:nAt,08] }}

		ACTIVATE MSDIALOG oDlgFpa CENTERED

		//altera para falso para só gerar, caso algum item seja marcado e a tela confirmada
		_LGERAR := .F.

		//verifica se pelo menos um item foi marcado
		If lRet
			For nX := 1 To Len(aItensFpa)
				If aItensFpa[nX][1]
					_LGERAR := .T.
				EndIf
			Next nX
		EndIf
	Else
		lPergGerAs := .F.
		//oDlgFpa:End()
	EndIf

	RestArea(aArea)

	// Card 1361 - se não confirmar nenhum dos itens deixar como contrato gerado
	If _lGerar .and. FP0->FP0_STATUS == "1" .and. lRet
		FP0->(RecLock("FP0"),.F.)
		FP0->FP0_STATUS := "5"
		FP0->(MsUnlock())
	EndIF

Return aItensFpa

//-------------------------------------------------------------------
/*/{Protheus.doc} TrazFpa
Retorna os itens que estão aptos a gerar AS
@author			José Eulálio
@since     		08/12/2022
@type Function
/*/
//-------------------------------------------------------------------
//Static Function TrazFpa(oLstFpa, cProjFpa, oOk, oNo, cObraDe, cObraAte)
Static Function TrazFpa(cProjFpa, cObraDe, cObraAte)
Local cQuery    	:= ""
Local cAliasFPA	:= GetNextAlias()

	cRetTae := ""

	ProcRegua(0)

	IncProc()

	cQuery := " SELECT R_E_C_N_O_ RECFPA, FPA_PROJET, FPA_OBRA, FPA_SEQGRU, FPA_GRUA, FPA_DESGRU, FPA_PRODUT "
	cQuery += "   FROM " + RetSqlName("FPA")
	cQuery += " WHERE 	FPA_FILIAL = '" + xFilial("FPA") +"' "
	cQuery += " 	AND D_E_L_E_T_ = ' '  "
	cQuery += " 	AND FPA_PROJET = ? "
	cQuery += " 	AND FPA_OBRA BETWEEN ? AND ? "
	cQuery += " 	AND FPA_AS = ' ' "
	cQuery += " ORDER BY FPA_OBRA, FPA_SEQGRU "

	cQuery := ChangeQuery(cQuery)
	aBindParam := {cProjFpa, cObraDe, cObraAte }
	cAliasFPA := MPSysOpenQuery(cQuery,,,,aBindParam)

	(cAliasFPA)->(dbGoTop())

	aItensFpa := {}

	If (cAliasFPA)->(!Eof())
		While (cAliasFPA)->(!Eof())

			FPA->(dbGoto((cAliasFPA)->RECFPA))

			AAdd(aItensFpa, { 	.F.              															,;
							(cAliasFPA)->FPA_OBRA                                      					,;
							(cAliasFPA)->FPA_SEQGRU                                      				,;
							(cAliasFPA)->FPA_GRUA                                       				,;
							(cAliasFPA)->FPA_DESGRU                                       				,;
							(cAliasFPA)->FPA_PRODUT                                       				,;
							Posicione("SB1" , 1 , xFilial("SB1")+(cAliasFPA)->FPA_PRODUT , "B1_DESC"),;
							Iif(LOCA013T(),.F.,.T.)  }) 

			(cAliasFPA)->(dbSkip())
			IncProc()
		EndDo

		(cAliasFPA)->(dbCloseArea())
	
	EndIf
	
	If len(aItensFpa) == 0
		AAdd(aItensFpa, { .F., "", "", "", "", "", "", .F. })
		//MsgInfo("Não foram localizados registros para o Projeto selecionado.","Sem resultados")
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ITPESQEV
Pesquisa do LISTBOX
@author			José Eulálio
@since     		08/12/2022
@type function
/*/
//-------------------------------------------------------------------
Static Function ITPESQEV(oLstFpa,cPesqEv,oOk,oNo)
Local _nX
Local _nY
Local _lAchou 	:= .F.
Local aLstBxNew	:= {}

	If empty(cPesqEv) .Or. Len(cPesqEv) < 2
		MsgAlert(STR0143,STR0007) // "Favor informar o que deseja pesquisar " ### "Atenção!"
		oLstFpa:setarray(aLstBxOri)
		oLstFpa:bLine 	:= {|| {IF(	aLstBxOri[oLstFpa:nAt,01],oOk,oNo),;
									aLstBxOri[oLstFpa:nAt,02],;
									aLstBxOri[oLstFpa:nAt,03],;
									aLstBxOri[oLstFpa:nAt,04],;
									aLstBxOri[oLstFpa:nAt,05],;
									aLstBxOri[oLstFpa:nAt,06],;
									aLstBxOri[oLstFpa:nAt,07] }}
		oLstFpa:nAt := 1
		oLstFpa:Refresh()
	Else
		For _nX := oLstFpa:nAt+1 To Len(oLstFpa:aArray)
			For _nY := 2 To Len(oLstFpa:aArray[_nX])
				If UPPER(AllTrim(cPesqEv)) $ UPPER(AllTrim(oLstFpa:aArray[_nX,_nY]))
					Aadd(aLstBxNew,oLstFpa:aArray[_nX])
					_lAchou := .T.
					Exit
				EndIf
			Next _nY
		Next _nX
		If _lAchou
			oLstFpa:setarray(aLstBxNew)
			oLstFpa:bLine 	:= {|| {IF(	aLstBxNew[oLstFpa:nAt,01],oOk,oNo),;
										aLstBxNew[oLstFpa:nAt,02],;
										aLstBxNew[oLstFpa:nAt,03],;
										aLstBxNew[oLstFpa:nAt,04],;
										aLstBxNew[oLstFpa:nAt,05],;
										aLstBxNew[oLstFpa:nAt,06],;
										aLstBxNew[oLstFpa:nAt,07]}}
			oLstFpa:nAt := 1
			oLstFpa:Refresh()
		Else
			MsgAlert(STR0144,STR0007) //"Item não localizado." ### "Atenção!"
			oLstFpa:setarray(aLstBxOri)
			oLstFpa:bLine 	:= {|| {IF(	aLstBxOri[oLstFpa:nAt,01],oOk,oNo),;
										aLstBxOri[oLstFpa:nAt,02],;
										aLstBxOri[oLstFpa:nAt,03],;
										aLstBxOri[oLstFpa:nAt,04],;
										aLstBxOri[oLstFpa:nAt,05],;
										aLstBxOri[oLstFpa:nAt,06],;
										aLstBxOri[oLstFpa:nAt,07] }}
			oLstFpa:nAt := 1
			oLstFpa:Refresh()
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} IsGeraAs
	Verifica se o item foi marcado para gerar AS
@author			José Eulálio
@since     		08/12/2022
@type Function
/*/
//-------------------------------------------------------------------
Static Function IsGeraAs(aGeraAs,cProjetFpa,cObraFpa,cSeqGruFpa)
Local lRet 		:= .F.
Local nPosFpa	:= Ascan(aGeraAs,{|x| x[2]+x[3] == cObraFpa + cSeqGruFpa})

	//caso tenha localizado Obra + Seq.Gru, verifica se foi marcado
	If nPosFpa > 0 .And. aGeraAs[nPosFpa][1]
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} bLineFpa
@description	Marca, desmarca ou inverte os itens
@author			José Eulálio
@since     		08/12/2022
/*/
//-------------------------------------------------------------------
Static Function bLineFpa(lTodos,lInverte)
Local nX		:= 1
Local nTam		:= Len(oLstFpa:aArray)
Local lOption	:= .T.
Local bLine
Local cRetTae	:= ""

	//se chamado do dulplo clique inverte só a linha
	If oLstFpa:ColPos == 1 .And. !lTodos .And. !lInverte
		oLstFpa:aArray[OLSTFPA:NAT][1] := !oLstFpa:aArray[OLSTFPA:NAT][1]
		// Valida o bloquei do TAE
		If oLstFpa:aArray[OLSTFPA:NAT][8]
			oLstFpa:aArray[OLSTFPA:NAT][1] := .F.

			FPB->(dbSetOrder(1))
			FPB->(dbSeek(xFilial("FPB")+FP0->FP0_PROJET))
			While !FPB->(Eof()) .and. FPB->(FPB_FILIAL+FPB_PROJET) == xFilial("FPB")+FP0->FP0_PROJET
				If FPB->FPB_VALOBR == "1" // 1 indica se consideramos a obra no grid dos documentos
					If FPB->FPB_OBRA <> oLstFpa:aArray[OLSTFPA:NAT][2]
						FPB->(dbSkip())
						Loop
					EndIF
				EndIf
				FPC->(dbSetOrder(1))
				If FPC->(dbSeek(xFilial("FPC")+FPB->FPB_CODIGO))
					If FPC->FPC_BLGERA == "1"
						If !FPB->FPB_STATUS $ "356"  
							lRet := .F.
							If empty(cRetTae)
								cRetTae += STR0171 //"Obra/Seq.Doc: "
							Else
								cRetTae += ", "
							EndIf
							cRetTae += alltrim(FPB->FPB_OBRA)+"/"+alltrim(FPB->FPB_SEQDOC)
						EndIf
					EndIf
				EndIF
				FPB->(dbSkip())
			EndDo

			Help(Nil,	Nil,STR0004+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0170,1,0,Nil,Nil,Nil,Nil,Nil,; //"O contrato não será gerado por falta de assinatura dos documentos."
			{cRetTae})

		EndIf
	ElseIf lTodos
		//inverte o primeiro e mantém todos com a mesma marcação
		lOption	:= !oLstFpa:aArray[1][1]
		For nX := 1 To nTam
			oLstFpa:aArray[nX][1] := lOption
		Next nX
		oLstFpa:Refresh()
	ElseIf lInverte
		//Roda todos invertendo
		For nX := 1 To nTam
			oLstFpa:aArray[nX][1] := !oLstFpa:aArray[nX][1]
		Next nX
		oLstFpa:Refresh()
	EndIf

	For nX := 1 To nTam
		If oLstFpa:aArray[nX][8] 
			oLstFpa:aArray[nX][1] := .F.
		EndIF
	Next nX
	oLstFpa:Refresh()

Return bLine

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA01314
@description	Verifica se tamanho do campo que recebel Classe Valor comporta a AS (20 caracteres)
@author			José Eulálio
@since     		08/12/2022
/*/
//-------------------------------------------------------------------
Function LOCA01314(lPassa)
Local lRet		:= .T.
Local nTamMax	:= 20
Local cErro     := ""

	If TamSx3("CTH_CLVL")[1] < nTamMax
		cErro := STR0148 //"Ação não permitida. O parâmetro MV_LOCX051 está configurado para gerar Classe de Valor e o Campo CTH_CLVL com tamanho inferior a 20 caracteres."
		if lPassa
			cLocErro :=cErro +CRLF
		else
			Help(	Nil,Nil,"LOCA013_01",Nil,cErro,1,0,Nil,Nil,Nil,Nil,Nil,{STR0149})  //"Ação não permitida. O parâmetro MV_LOCX051 está configurado para gerar Classe de Valor e o Campo CTH_CLVL com tamanho inferior a 20 caracteres." // "Entre em contato com o Administrador para Desativar o Parâmetro ou Alterar o tamanho do Grupo de Campos Classe de Valor (006) para o tamanho de 20 caracteres"
		endif
		lRet := .F.
	EndIf

Return lRet

// Tratamento para completar a FQ4 com o numero da AS
// Fiz este tratamento, pois a função que gera a FQ4 no momento em que é chamada, esta antes da geração da AS
// Frank em 01/04/2024
Function LOCA013B()
Local aArea := GetArea()
Local cQuery
Local aBindParam := {}
Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.)
Local lProc

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
	If FPA->FPA_TIPOSE == "L"  .AND.  ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) .and. !empty(FPA->FPA_GRUA)
		ST9->(dbSetOrder(1))
		If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
			If ST9->T9_STATUS <> ""
				IF SELECT("TRBFQ4") > 0
					TRBFQ4->( DBCLOSEAREA() )
				ENDIF
				CQUERY := " SELECT R_E_C_N_O_ REG"
				CQUERY += " FROM " + RETSQLNAME("FQ4") + " FQ4 "
				CQUERY += " WHERE FQ4.FQ4_CODBEM = ? "
				aadd(aBindParam,alltrim(FPA->FPA_GRUA))
				CQUERY += " AND FQ4.FQ4_AS = '' "
				CQUERY += " AND FQ4.FQ4_PROJET = ? "
				aadd(aBindParam,alltrim(FPA->FPA_PROJET))
				CQUERY += " AND FQ4.FQ4_OBRA = ? "
				aadd(aBindParam,alltrim(FPA->FPA_OBRA))
				CQUERY += " AND FQ4.FQ4_DTINI = ? "
				aadd(aBindParam,dtos(FPA->FPA_DTINI))
				CQUERY += " AND FQ4.FQ4_DTFIM = ? "
				aadd(aBindParam,dtos(FPA->FPA_DTENRE))
				CQUERY += " AND FQ4.D_E_L_E_T_ = ''"
//				IF SELECT("TRBFQ4") > 0
//					TRBFQ4->(DBCLOSEAREA())
//				ENDIF
				CQUERY := CHANGEQUERY(CQUERY)
				MPSysOpenQuery(cQuery,"TRBFQ4",,,aBindParam)
				While !TRBFQ4->(Eof())
					FQ4->(dbGoto(TRBFQ4->REG))

					lProc := .F.
					If lMvLocBac
						FQD->(DBSETORDER(2))
						If FQD->(DBSEEK(XFILIAL("FQD") + FQ4->FQ4_STATUS))
							If FQD->FQD_STAREN == "10"
								lProc := .T.
							EndIf
						EndIf
					Else
						TQY->(DBSETORDER(1))
						If TQY->(DBSEEK(XFILIAL("TQY") + FQ4->FQ4_STATUS))
							If TQY->TQY_STTCTR == "10"
								lProc := .T.
							EndIf
						EndIf
					EndIf

					If lProc
						FQ4->(RecLock("FQ4",.F.))
						FQ4->FQ4_AS := FPA->FPA_AS
						FQ4->(MsUnlock())
						Exit
					EndIf

					TRBFQ4->(dbSkip())
				EndDo
				TRBFQ4->( DBCLOSEAREA() )
			EndIF
		EndIF
	EndIF
	RestArea(aArea)
Return

/*/{Protheus.doc} LOCA013C
Valida se o item da FPA pode gerar AS já aceita
@type function
@version
@author aleci
@since 4/22/2024
@param CGRPAND, character, param_description
@return variant, return_description
/*/
Function LOCA013C(CGRPAND)
Local lRet := .F.
Local lGRCTAAS := EXISTBLOCK("GRCTAAS")

if lGRCTAAS
	lRet := EXECBLOCK("GRCTAAS",.F.,.F., CGRPAND )
ElSe
	IF FPA->FPA_TIPOSE == "L" .AND. ! ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) .and. Empty(FPA->FPA_GRUA)

		lRet := .T.

	endif

endif

Return lRet

/*/{Protheus.doc} LOCA013D
Preencher o equipamento da FPA que não tiverem grua preenchido
@type function
@version 1.0
@author acircenis
@since 7/24/2024 = DSERLOCA-3638
@return variant, retorna mensagem indicando o processamento

/*/
Function LOCA013D()
Local CGRPAND	:= SUPERGETMV("MV_LOCX014",.F.,"" )
Local cQuery 	:= ""
Local aBindParam := {}
Local nAlocou := 0
Local nNaoAlocou := 0
Local cCodBem := ""

ProcRegua(0)

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CGRPAND := LOCA00189()
	ELSE
		CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
	ENDIF

	cQuery += "select FPA.R_E_C_N_O_, B1_GRUPO	"
	cQuery += " from "+RetSQLName("FPA")+" FPA"
	cQuery += " inner join "+RetSQLName("SB1")+" SB1"
	cQuery += " on B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery += " and B1_COD = FPA_PRODUT"
	cQuery += " and SB1.D_E_L_E_T_ = ' '"
	cQuery += " where FPA_FILIAL = '"+xFilial("FPA")+"'"
	cQuery += " and FPA_PROJET = ? "
	Aadd(aBindParam, FP0->FP0_PROJET)
	cQuery += " and FPA_GRUA = '' "
	cQuery += " and FPA_NFREM = '' "
	cQuery += " and FPA_TIPOSE = 'L' "
	cQuery += " and FPA.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY FPA_OBRA, FPA_SEQGRU"

	MPSysOpenQuery(cQuery,"TRBFPA",,,aBindParam)

	while !TRBFPA->(Eof()) // Corre a FPA

		IncProc()

        // Se grupo de produtos não está no parametro que permite deixar a FPA sem equipamento
		if ! ALLTRIM(TRBFPA->B1_GRUPO) $ ALLTRIM(CGRPAND)
			FPA->(dbGoto(TRBFPA->R_E_C_N_O_))
  			// Buscar o bem conforme as regras
			cCodBem := LOCA013E(FPA->FPA_PRODUT, FPA->FPA_PROJET )
			if !Empty(cCodBem) // Se Achou grava na FPA
				ST9->( DBSETORDER(1) )
				ST9->(DBSEEK(XFILIAL("ST9") + cCodBem))
				RecLock("FPA", .F.)
				FPA->FPA_GRUA 	:= cCodBem
				FPA->FPA_DESGRU := ALLTRIM(ST9->T9_NOME)
				MsUnlock()
				nAlocou++
			else
				nNaoAlocou++
			ENDIF

		endif

		TRBFPA->(dbSkip())

	enddo

Return {nAlocou, nNaoAlocou}

/*/{Protheus.doc} LOCA013E
Retorna o codigo do ativo que se tornou disponivel a mais tempo
@type function
@version 1.1
@author Acircenis
@since 8/6/2024
@param cProduto, character, Produto de estoque do ativo buscao
@param cProjeto, character, Projeto usado para não repitir o mesmo ativo no mesmo projeto
@return variant, Codigo do Ativo conforme FIFO
/*/
Function LOCA013E(cProduto, cProjeto)

Local cQuery := ""
Local aArea := GetArea()
//Local LMINUTA	  := SUPERGETMV("MV_LOCX097",.F.,.T.)
Local aBindParam
Local cRet := ""
Local cFiltro := ""

	aBindParam := {}
	cQuery	+= " SELECT DISTINCT T9_CODBEM, CASE
	cQuery	+= "	WHEN FQ4.FQ4_LOG = NULL THEN ST9.T9_DTINSTA
	cQuery	+= "	WHEN SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-12, 4) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-15, 2) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 2) > ST9.T9_DTINSTA THEN SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-12, 4) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-15, 2) + SUBSTRING(FQ4.FQ4_LOG, LEN(FQ4.FQ4_LOG)-18, 2)
	cQuery	+= "	ELSE ST9.T9_DTINSTA END DTMOV
	cQuery  += " FROM "+RetSqlName("ST9")+" ST9"
	cQuery  += " LEFT JOIN "+RetSqlName("FQ4")+ " FQ4"
	cQuery  += " ON FQ4_CODBEM = T9_CODBEM "
	cQuery  += " AND FQ4_SEQ = ( Select  MAX(FQ4_SEQ) FROM "+ RetSqlName("FQ4")+" B WHERE B.FQ4_CODBEM = T9_CODBEM AND B.D_E_L_E_T_ = ' ' )"
	cQuery	+= " WHERE T9_FILIAL = '" + xFilial("ST9") + "' "
	cQuery	+= " AND T9_SITMAN = 'A' "
	cQuery	+= " AND T9_SITBEM = 'A' "
//	If !lMinuta // Card 603 - Frank em 08/11/23
		cQuery	+= " AND T9_STATUS IN ('  ','00')"  //" AND T9_STATUS = '00'" // Rossana - 25/06/24 / DSERLOCA - 3350
//	EndIF
	cQuery  += " AND T9_CODESTO = ? "
	Aadd(aBindParam, cProduto)

	If (ExistBlock("LOCA13A"))
		cFiltro := ExecBlock("LOCA13A",.F.,.F.)
		if Valtype(cFiltro) = 'C' .and. !Empty(cFiltro)
			&("cQuery += cFiltro")
		endif
	EndIf

	cQuery  += " AND ST9.D_E_L_E_T_ = ' '"
	cQuery  += " AND NOT EXISTS ( " // O bem não pode estar no projeto
	cQuery  += "    SELECT FPA_GRUA FROM "+RetSqlName("FPA")+ " FPA"
	cQuery  += "    WHERE FPA_FILIAL = '"+xFilial("FPA")+"'"
	cQuery  += "    AND FPA_PROJET = ?"
	Aadd(aBindParam, cProjeto)
	cQuery  += "    AND FPA_GRUA = T9_CODBEM"
	cQuery  += "    AND FPA.D_E_L_E_T_ = ' ')"
	cQuery  += " ORDER BY DTMOV"


MPSysOpenQuery(cQuery,"TRBST9",,,aBindParam)

While !TRBST9->(Eof()) // Tem Bens para alocar
	if !FindFunction("LOCA224G") .or. !LOCA224G(TRBST9->T9_CODBEM, .F.) // O Bem não está num substatus que impede a locação
	cRet := TRBST9->T9_CODBEM
		exit
endif
	TRBST9->(dbSkip())
enddo

RestArea(aArea)

RETURN cRet

/*/ LOCA00174
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
SINCE 03/12/2020
HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

FUNCTION LOCA013F(CPROJET , lPassa)
Local LRET		:= .T.
Local AAREA		:= GETAREA()
Local AAREAZLE	:= FPM->(GETAREA())
Local CQUERY	:= ""
Local CGETNA    := GETNEXTALIAS()
Local CGRPAND   := ""
Local lLOCX305	:= SuperGetMV("MV_LOCX305",.F.,.T.) //Define se aceita geração de contrato sem equipamento
Local lMvLocx307 := SUPERGETMV("MV_LOCX307",.F.,.F.) // Habilita o preenchimento automatico do equipamento.
Local aBindParam
Local cTemp
Local cErro

	IF SBM->(FIELDPOS("BM_XACESS")) > 0
		CGRPAND := LOCA00189()
	ELSE
		CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
	ENDIF

	IF EXISTBLOCK("LC001VML") 				// --> PONTO DE ENTRADA PARA ALTERAÇÃO DE VALIDAÇÃO NA MANUTENÇÃO DE PROJETOS DE LOCAÇÃO.
		LRET := EXECBLOCK("LC001VML",.T.,.T.,{})
	ELSE

		/*
		+ XFILIAL("FPA") +
		+ CPROJET +
		+ STRTRAN(ALLTRIM(CGRPAND),";","','") +
		+ STRTRAN(ALLTRIM(CGRPAND),";","','") +
		*/

		CQUERY := " SELECT FPA_OBRA, FPA_SEQGRU, B1_GRUPO, FP0_TIPFAT TIPFAT"
		CQUERY += " FROM " + RETSQLNAME("FPA") + " ZAG "
		CQUERY +=        " INNER JOIN " + RETSQLNAME("FP0") + " ZA0 ON  FPA_FILIAL = FP0_FILIAL"
		CQUERY +=                                                 " AND FPA_PROJET = FP0_PROJET"
		CQUERY +=                                                 " AND ZA0.D_E_L_E_T_ = ' ' "
		CQUERY +=        " LEFT JOIN " + RETSQLNAME("SB1") + " SB1 ON  FPA_PRODUT = B1_COD AND B1_FILIAL = '"+xFilial("SB1")+"' "
		CQUERY +=                                                 " AND SB1.D_E_L_E_T_ = ' ' "
		CQUERY += " WHERE  FPA_FILIAL = ? "
		CQUERY += "   AND  FPA_PROJET = ? "
		CQUERY += "   AND ( "
		CQUERY +=         "  FPA_DTINI  = ''"
		CQUERY += "    OR  FPA_DTFIM  = ''"
		CQUERY +=         "  OR FPA_PRODUT = '' "
		if !lLOCX305 .and. !lMvLocx307 // Não Permite gerar sem equipamento e não há alocação automatica verificar se tem GRUA
			CQUERY +=     "  OR (
			cQuery += 			"	FPA_TIPOSE = 'L'"
			CQUERY += 			"   AND B1_GRUPO NOT IN ('
			cTemp  := STRTRAN(ALLTRIM(CGRPAND),";","','")+"')"
			&("cQuery += cTemp")
			CQUERY +=           "   AND FPA_GRUA   = '' "
			cQuery +=      "     )"
			cQuery +=      " OR ( "
			CQUERY += 	   "     FPA_TIPOSE = 'L'"
			CQUERY +=      "     AND B1_GRUPO  IN ('
			&("cQuery += cTemp")
			CQUERY +=      "     AND FPA_QUANT <= 0"
			CQUERY +=      " 	 AND FPA_NFRET = ''
			CQUERY +=      "     )"
		endif

		CQUERY += "     OR FPA_CONPAG = '')"
		CQUERY += "    AND ZAG.D_E_L_E_T_ = ' '"
		CQUERY := CHANGEQUERY(CQUERY)
		aBindParam := {XFILIAL("FPA"), CPROJET}
		CGETNA := MPSysOpenQuery(CQUERY,,,,aBindParam)

		//DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,CQUERY),(CGETNA),.F.,.T.)

		IF (CGETNA)->(!EOF()) .And. !lLOCX305 // Se não estiver permitido contrato sem equipamento
			IF (CGETNA)->B1_GRUPO $ ALLTRIM(CGRPAND) //TIPFAT $ "A#B"

				cErro := STR0167+ (CGETNA)->FPA_OBRA + " / Seq.: " + (CGETNA)->FPA_SEQGRU //"Verifique os campos data e hora inicial/final, produto, quantidade e condição de pagamento. Obra: "
				Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),; //STR0156 //"RENTAL: "
					Nil,STR0128,1,0,Nil,Nil,Nil,Nil,Nil,; //STR0128 //"Inconsistência nos dados."
					{ cErro })

				//Ferramenta Migrador de Contratos
				If lPassa
					cLocErro := cErro +CRLF
				EndIf

			ELSE
				cErro := STR0169 + (cGetNA)->FPA_OBRA + STR0168 + (cGetNA)->FPA_SEQGRU + "." //" / Seq.: " //"Verifique os campos data e hora inicial/final, produto/bem, e condição de pagamento. Obra: "
				Help(Nil,	Nil,"RENTAL: "+alltrim(upper(Procname())),; //STR0156 //"RENTAL: "
					Nil,STR0128,1,0,Nil,Nil,Nil,Nil,Nil,; //STR0128 //"Inconsistência nos dados."
					{cErro}) //"Verifique os campos data e hora inicial/final, produto/bem, e condição de pagamento. Obra: "###" / Seq.: "

				//Ferramenta Migrador de Contratos
				If lPassa
					cLocErro := cErro +CRLF //" / Seq.: "
				EndIf

			ENDIF
			LRET := .F.
		ENDIF
		(CGETNA)->(DBCLOSEAREA())
	endif

	IF LRET .AND. EXISTBLOCK("LC001VCT") 		// --> PONTO DE ENTRADA PARA VALIDAÇÃO DE USUÁRIO ANTES DA GERAÇÃO DO CONTRATO
		LRET := EXECBLOCK("LC001VCT",.T.,.T.,{CPROJET})
	ENDIF

	RESTAREA(AAREAZLE)
	RESTAREA(AAREA)

	aSize(AAREAZLE,0)
	aSize(AAREA,0)

	FwFreeArray(AAREAZLE)
	FwFreeArray(AAREA)

RETURN LRET

/*/{PROTHEUS.DOC} LOCA059B1
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Static Function LOCA059B1(cCampo, cAlias)
Local a1Struct
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet


/*/ LOCA013T
ITUP BUSINESS - TOTVS RENTAL
AUTHOR FRANK ZWARG FUGA
SINCE 30/12/2023
Validação com a integração TAE
/*/

FUNCTION LOCA013T()
Local lRet := .T.

	//cRetTae criado como private na chamada do LOCA013T
	cRetTae := ""

	If LOCA013V("FPB_IDTAE", "FPB") .and. LOCA013V("FPC_BLGERA", "FPC")

		FPB->(dbSetOrder(1))
		FPB->(dbSeek(xFilial("FPB")+FPA->FPA_PROJET))
		While !FPB->(Eof()) .and. FPB->(FPB_FILIAL+FPB_PROJET) == xFilial("FPB")+FPA->FPA_PROJET
			If FPB->FPB_VALOBR == "1" // 1 indica se consideramos a obra no grid dos documentos
				If FPB->FPB_OBRA <> FPA->FPA_OBRA
					FPB->(dbSkip())
					Loop
				EndIF
			EndIf
			FPC->(dbSetOrder(1))
			If FPC->(dbSeek(xFilial("FPC")+FPB->FPB_CODIGO))
				If FPC->FPC_BLGERA == "1"
					If !FPB->FPB_STATUS $ "356"  
						lRet := .F.
						If empty(cRetTae)
							cRetTae += STR0171 //"Obra/seq"
						Else
							cRetTae += ", "
						EndIf
						cRetTae += alltrim(FPB->FPB_OBRA)+"/"+alltrim(FPB->FPB_SEQDOC)
					EndIf
				EndIf
			EndIF
			FPB->(dbSkip())
		EndDo

	EndIf

	If !lRet
		FQ1->(dbSetOrder(1))
		If FQ1->(dbSeek(xFilial("FQ1")+RetCodUsr()+"LOCA013T"))
			lRet := .T.
		EndIF
	EndIf

Return lRet


/*/{PROTHEUS.DOC} LOCA013V
ITUP BUSINESS - TOTVS RENTAL
VALIDA SE UM CAMPO EXISTE NO SX3
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Static Function LOCA013V(cCampo, cAlias)
Local a1Struct
Local nP
Local lRet := .F.
    If !empty(cCampo) .and. !empty(cAlias)
        a1Struct := FWSX3Util():GetListFieldsStruct( cAlias, .F.)
        For nP := 1 to len(a1Struct)
            If upper(alltrim(a1Struct[nP][01])) == upper(alltrim(cCampo))
                lRet := .T.
                exit
            EndIf
        Next
    EndIF
Return lRet

/*/{PROTHEUS.DOC} LOCA013X
ITUP BUSINESS - TOTVS RENTAL
Apresenta os erros de encavalamento das minutas
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 15/05/2024
/*/

Static Function LOCA013X(aErros)
Private oDlgErro
Private oLstErro
Private aItensErro  := {}
Private cCadastro 	:= ""

	aItensErro := aErros

	Define MSDialog oDlgErro title STR0129 from 100,100 to 530,1000 pixel //"Conflito de equipamento."

	// "Data"###"H.Ini.Proj."###"H.Fim.Proj."###"Minuta"###"H.Ini.Minuta"###"H.Fim.Minuta"###"Projeto"###"Obra"###"AS"###"Turno"###"Bem"###"Situação"###"Tipo conflito"
	@ 08,04 LISTBOX oLstErro FIELDS HEADER STR0182, STR0183, STR0184, STR0185, STR0199, STR0200, STR0186, STR0187, STR0188, STR0189, STR0190, STR0191, STR0198 SIZE 444,200 OF oDlgErro PIXEL 

	oLstErro:SetArray(aItensErro)
	oLstErro:bLine 	:= {|| { aItensErro[oLstErro:nAt,01],;
							substr(aItensErro[oLstErro:nAt,02],1,2)+":"+substr(aItensErro[oLstErro:nAt,02],3,2),;
							substr(aItensErro[oLstErro:nAt,03],1,2)+":"+substr(aItensErro[oLstErro:nAt,03],3,2),;
							aItensErro[oLstErro:nAt,04],;
							substr(aItensErro[oLstErro:nAt,05],1,2)+":"+substr(aItensErro[oLstErro:nAt,05],3,2),;
							substr(aItensErro[oLstErro:nAt,06],1,2)+":"+substr(aItensErro[oLstErro:nAt,06],3,2),;
							aItensErro[oLstErro:nAt,07],;
							aItensErro[oLstErro:nAt,08],;
							aItensErro[oLstErro:nAt,09],;
							aItensErro[oLstErro:nAt,10],;
							aItensErro[oLstErro:nAt,11],;
							aItensErro[oLstErro:nAt,12],;
							aItensErro[oLstErro:nAt,13]}}

	oLstErro:Refresh()

	activate MSDialog oDlgErro centered

Return 

/*/{Protheus.doc} LOCA013DEL
Deleta os títulos provisórios
@type function
@author Frank Zwarg Fuga
@since 07/07/2025

cTipo = 1 chave simples apenas pelo código do projeto
cTipo = 2 chave complexa projeto + as

/*/
Function LOCA013DEL(cTipo, cProjeto, cAs, lPeriodo)
Local aAreaFQB := FQB->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local _aVetSE1 := {}
Local lProc    := .F.
Local cExecuta := ""

Default lPeriodo := .F.
	
	FQB->(dbSetOrder(1))
	If cTipo == 2
		FQB->(dbSeek(xFilial("FQB")+cProjeto+cAs)) // Projeto + AS
		If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == cProjeto+cAs
			lProc := .T.
		EndIf
	Else
		FQB->(dbSeek(xFilial("FQB")+cProjeto)) // Projeto
		If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET) == cProjeto
			lProc := .T.
		EndIf
	EndIf

	If cTipo == 1
		cExecuta := "FQB->(FQB_PROJET) == cProjeto"
	Else
		cExecuta := "FQB->(FQB_PROJET+FQB_AS) == cProjeto+cAs"
	EndIf

	While !FQB->(Eof()) .and. &(cExecuta) .and. lProc
		
		If lPeriodo
			//If alltrim(strzero(month(FQB->FQB_PERIOD),2,0))+alltrim(strzero(year(FQB->FQB_PERIOD),4,0)) > alltrim(strzero(month(FPA->FPA_ULTFAT),2,0))+alltrim(strzero(year(FPA->FPA_ULTFAT),4,0))
			If FQB->FQB_PERIOD > FPA->FPA_ULTFAT
				FQB->(dbSkip())
				Loop
			EndIf
		EndIf

		SE1->(dbSetOrder(1))
		SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
		While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
			If SE1->E1_PARCELA == FQB->FQB_PARC
				_aVetSE1 := {}
				aAdd(_aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
				aAdd(_aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
				aAdd(_aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
				aAdd(_aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
				aAdd(_aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
				aAdd(_aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
				aAdd(_aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
				aAdd(_aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
				aAdd(_aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
				aAdd(_aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
				aAdd(_aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
				aAdd(_aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
				aAdd(_aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
				aAdd(_aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
				aAdd(_aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
				lMsErroAuto := .F.
				MSExecAuto({|x,y| FINA040(x,y)}, _aVetSE1, 5)

				If lMsErroAuto 
					MostraErro()
					DisarmTransaction()
					lErroExec := .t.
				EndIf
			EndIf

			SE1->(dbSkip())
		EndDo

		FQB->(RecLock("FQB",.F.))
		FQB->(dbDelete())
		FQB->(MsUnlock())

		FQB->(dbSkip())
	EndDo
	
	FPA->(RestArea(aAreaFPA))
	FQB->(RestArea(aAreaFQB))
Return

Function LOCA013Y

return .t.
