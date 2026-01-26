#Include "loca229i.ch"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"

/*/{PROTHEUS.DOC} LOCA229I
ROTINA PARA GERAR PEDIDO DE VENDA E NOTA FISCAL DE REMESSA
COM BASE NA NOVA GESTÂO DE DEMANDA
@TYPE FUNCTION
@AUTHOR Alexandre Circenis
@SINCE 16/06/2025
@VERSION P12
/*/
FUNCTION LOCA229I()
	Local aArea := GetArea()

	Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
	Local _cAviso2 := ""
	Local _lAvisoVlr
	Local lTemSt20 := .F. // Não tem status 20 cadastrado

	PRIVATE _LTUDOOK   := .F.
	PRIVATE cAviso     := ""
	PRIVATE cProjet    := FQU->FQU_PROJET
	PRIVATE _CFILAUX   // FRANK 07/10/2020 - FILIAL PARA GERACAO DA NOTA DE REMESSA SEM SER VIA ROMANEIO
	PRIVATE aFPYTransf := {} // Deve ser private e serão utilizadas no LOCM006
	PRIVATE aFPZTransf := {} // Deve ser private e serão utilizadas no LOCM006
	Private aBlqRemessa // Array com bloqueios de documento


	If !lMvLocBac .and. SC5->(fieldpos("C5_XTIPFAT")) == 0
		Help(Nil,	Nil,"Rental: "+alltrim(upper(Procname())),; //
		Nil,STR0001,1,0,Nil,Nil,Nil,Nil,Nil,; // //"Inconsistência nos dados."
		{STR0002})  // //"MV_LOCBAC falso e o Campo C5_XTIPFAT não existe"
		RETURN .F.
	EndIf

	If GetMV("MV_GERABLQ",,"N") == "N"
		Help(Nil,	Nil,"Rental: "+alltrim(upper(Procname())),; //
		Nil,STR0001,1,0,Nil,Nil,Nil,Nil,Nil,; // //"Inconsistência nos dados."
		{STR0003}) //
		RETURN .F.
	EndIf

	// --> VALIDA SE EXISTE MESMO O CLIENTE PADRÃO DO PROJETO.
	SA1->(dbSetOrder(1))
	IF SA1->( dbSeek(xFilial("SA1") + FQU->FQU_CLIENT + FQU->FQU_LOJA) )
		IF SA1->A1_RISCO == "E"
			cAviso := STR0004 + CRLF + CRLF + STR0005 //###
			RETURN
		ENDIF
	ENDIF

	if FQU->FQU_STATUS = '6' // tem itens no romaneio remessa não poderá ser gerada
		MsgAlert(STR0006, STR0007) //"Romaneio já teve pedido/nota gerados. Não é possivel continuar!"
		RestArea(aArea)
		REturn .T.
	endif

// O Romaneio deve ter itens
	FQV->(dbSetOrder(1))
	if !FQV->(dbSeek(xFilial("FQV")+FQU->FQU_NUM)) // tem itens no romaneio remessa não poderá ser gerada
		MsgAlert(STR0009, STR0008) //"Romaneio Vazio"
		RestArea(aArea)
		REturn .T.
	endif

	while !FQV->(Eof()) .and. FQV->(FQV_FILIAL + FQV_NUM) = xFilial("FQV")+FQU->FQU_NUM
		if FQV->FQV_STATUS = '1'
			MsgAlert(STR0010, STR0011) //"Há itens pendentes de separação. Emissão da remessa não poderá ser realizada!"
			RestArea(aArea)
			Return .T.
		endif
		FQV->(dbSkip())
	enddo

	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0")+FQU->FQU_PROJET))
	aBlqRemessa := Loca010B(FQU->FQU_PROJET)
	if !Empty( aBlqRemessa) // tem possivel bloqueio
		if aScan(aBlqRemessa, {|x| Empty(x[1])}) >0  .or. aScan(aBlqRemessa, {|x| x[1]= FQU->FQU_OBRA})>0 // Contrato ou Obra Bloqueada
			MSgAlert(STR0012) //
			Return .T.
		endif
	endif

// Verificar se algum produto do romaneio está com o preco zerado.
	FQV->(dbSetOrder(1))
	FQV->(dbSeek(xFilial("FQV")+FQU->FQU_NUM))
	While !FQV->(Eof()) .and. FQV->FQV_FILIAL = xFilial("FQV") .and. FQV->FQV_NUM == FQU->FQU_NUM

		// Frank em 02/07/2021 mudança do aviso do valor zerado, antes atendia apenas o FPA_PRVUCI, agora
		// valido também o cadastro de produtos e cadastro de bens
		FPA->(dbSetOrder(3))
		FPA->(dbSeek(xFIlial("FPA")+ FQV->FQV_AS))
		_lAvisoVlr := .T.
		If FPA->FPA_PRCUNI > 0
			_lAvisoVlr := .F.
		EndIF


		SB1->(dbSetOrder(1))
		If SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
			If SB1->B1_PRV1 > 0
				_lAvisoVlr := .F.
			EndIF
		EndIF

		If !empty(FPA->FPA_GRUA)
			ST9->(dbSetOrder(1))
			If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
				If ST9->T9_VALCPA > 0
					_lAvisoVlr := .F.
				EndIF
			EndIF
		EndIF

		If _lAvisoVlr
			If !empty(_cAviso2)
				_cAviso2 += "; "
			ENDIF
			_cAviso2 += alltrim(FQV->FQV_PROD)
		EndIF

		FQV->(dbSkip())
	EndDo

	If !empty(_cAviso2)
		MsgAlert(STR0013+_cAviso2,STR0014) //###
		Return .F.
	EndIF

	// --> VERIFICA SE EXISTE O STATUS '20' CADASTRADO - MESMA VALIDAÇÃO DO SF2460I.PRW
	aAreaATU := GetArea()
	aAreaST9 := ST9->(GetArea())
	aAreaTQY := TQY->(GetArea())

	dbSelectArea("ST9")														// --> TABELA...: BEM
	dbSetOrder(1) 															// --> INDICE 01: T9_FILIAL + T9_CODBEM

	dbSelectArea("TQY")														// --> TABELA...: STATUS DO BEM
	dbSetOrder(1) 															// --> INDICE 01: TQY_FILIAL + TQY_STATUS

	IF ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
		aAreaFQD := FQD->(GetArea("FQD"))
		FQD->(dbSetOrder(2)) //"FQD_FILIAL+FQD_STATQY"
		IF FQD->(dbSeek(xFilial("FQD")+ST9->T9_STATUS)) .and. !empty(ST9->T9_STATUS)
			FQD->(dbGoTop())
			WHILE FQD->(!EOF())
				IF FQD->FQD_STAREN == "20" 									// STATUS DE GERAR CONTRATO
					lTemSt20 := .T.
				ENDIF
				FQD->(dbSkip())
			ENDDO
			IF ! lTemSt20
				MSGALERT(STR0016, STR0015)  //"Status BEM: Não foi encontrado o '###' 20 no cadastro de '###'!"###"Favor realizar o cadastro do mesmo para prosseguir."###
				FQD->(RestArea(aAreaFQD))
				RETURN
			ENDIF
		ENDIF
		FQD->(RestArea(aAreaFQD))
	EndIF

	RestArea(aAreaTQY)
	RestArea(aAreaST9)
	RestArea(aAreaATU)
// Prepera os dados de remessa
	ItensPed( )

	RestArea(aArea)
// Apresenta a tela do romaneio agurdando a confirmação da emissao da remessa
	oView := FWLoadView("LOCA229B")
	oView:AddUserButton(STR0017,"OK",{|oView| Loca229IRM(oView) },STR0018,,,.T.) //"Gerar Remessa"
	oView:EnableControlBar(.T.)

	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
		{.F.,Nil},{.T.,NIL},{.T.,STR0019},{.F.,Nil},{.F.,Nil},; //"CANCELAR"
		{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oExecView := FWViewExec():New()
	oExecView:setView(oView)
	oExecView:setTitle(STR0017) //"Gerar Remessa"
//oExecView:setSource("LOCA229B")
	oExecView:setModal(.F.)
	oExecView:SetButtons(aButtons)
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.T.)

RETURN

/*/{Protheus.doc} LOCA229IRM
Processo de emissão da remessa para o 
@type function
@version  25.10
@author Alexandre Circenis
@since 6/25/2025
@param oView, object, View de origem 
@return variant, Retorna .f. para fechar a janela
/*/
FUNCTION LOCA229IRM(oView)
	Local lPedidos := .T. // Todos os itens do romaneio geram pedidos
	Local aArea := GetArea()
	Local aAreaFQ5 := FQ5->(GetArea())

	cAviso := ""
	oView:ButtonCancelAction()
	GERPED()

	if !Empty(cAviso)
		Aviso("Rental: "+alltrim(upper(Procname())),; //
		cAviso , {"Ok"}) 
	endif
		
	// Verificar se algum produto do romaneio está sem pedido gerado.
	FQV->(dbSetOrder(1))
	FQV->(dbSeek(xFilial("FQV")+FQV->FQV_NUM))
	While !FQV->(Eof()) .and. FQV->FQV_FILIAL = xFilial("FQV") .and. FQV->FQV_NUM == FQU->FQU_NUM

		if Empty(FQV->FQV_PEDIDO)
			lPedidos := .F.
		else
			dbSelectArea("FQ5")
			dbSetOrder(9) // Por A.S.
			if FQ5->(dbSeek(xFilial("FQ5")+FQV->FQV_AS))
				RecLock("FQ5", .F.)
				FQ5->FQ5_STDEMA := "5"
				msUnlock()
			endif	
		endif

		FQV->(dbSkip())
	EndDo

	if lPedidos
		RecLock("FQU", .F.)
		FQU->FQU_STATUS := '6'
		MsUnLock()
	endif

RestArea(aAreaFQ5)
RestArea(aArea)

RETURN .F.


/*/{Protheus.doc} GERPED
Gera os pedidos de venda para a remessa do romaneio posicionado
@type function
@version  25.10
@author Alexandre Circenis
@since 6/25/2025
/*/
STATIC FUNCTION GERPED()
	Local aAreaSC5   := SC5->(GetArea())
	Local aAreaSC6   := SC6->(GetArea())
	Local aAreaDA3   := DA3->(GetArea())
	Local aAreaSA1	 := SA1->(GetArea())
	Local aAreaSF4	 := SF4->(GetArea())
	Local aAreaSE4   := SE4->(GetArea())
	Local aCamposSC5 := {}
	Local aCamposSC6 := {}
	Local cTesrf     := SUPERGETMV("MV_LOCX084"  ,.F.,"509")
	Local cTeslf     := SUPERGETMV("MV_LOCX083",.F.,"503")
	Local cSerie     := SUPERGETMV("MV_LOCX201",.F.,"001")
	Local cNaturez   := SUPERGETMV("MV_LOCX066",.F.,"300000")
	Local cDescri    := ""

	Local cItem      := Criavar("C6_ITEM")
	Local _LCVAL     := SUPERGETMV("MV_LOCX051",.F.,.T.)
	Local nQtd       := 0
	Local NY         := 0
	Local _NV        := 0

	Local cFilNew  := cFilAnt // FRANK Z FUGA EM 07/10/2020 - VARIAVEL PARA TROCA DA FILIAL NA EMISSÃO DA NFS
	Local _CFILTMP
	Local lCliCjTran:= .F.
	Local cCmpUsr	:= SuperGetMv("MV_CMPUSR",.F.,"")
	Local _MV_GERNFS := SUPERGETMV("MV_GERNFS",,.T.) .and. cPaisLoc = 'BRA'
	Local _GERREMTES := EXISTBLOCK("GERREMTES")
	Local _MV_LOC299 := GetMV("MV_LOCX299",,"")
	Local _MV_LOCALIZ := getmv("MV_LOCALIZ",,"S")
	Local _GERREFLOG := EXISTBLOCK("GERREFLOG")
	Local _MV_LOC248 := SUPERGETMV("MV_LOCX248",.F.,"Projeto") //
	Local _GERREMFIM := EXISTBLOCK("GERREMFIM")
	Local lloca10z   := EXISTBLOCK("LOCA10Z")
	Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
	Local aItemFPZ	:= {}
	Local xTemp
	Local nPonteiro := 0
	Local aFPZOld   := {}
	Local nQtdItens := 0
	Local nMaxItens := 300
	Local nParc1	:= 100
	Local nValTot	:= 0
	Local cDtFim	:= ""
	Local cCondPag	:= ""
	Local cTesOld
	Local lGERREMC5 := EXISTBLOCK("GERREMC5")
	Local cTESSC6   := ""

	Private _CPEDIDO	:= ""
	Private _CNOTA		:= ""
	Private	LNFREMLB    := SUPERGETMV("MV_LOCX216",.F.,.T.) 	// PARÂMETRO PARA ATIVAR O LISTBOX QUE PERMITE SELECIONAR OS ITENS PARA REMESSA
	Private	LNFREMBE	:= SUPERGETMV("MV_LOCX215",.F.,.F.)
	Private	_CDESTIN 	:= SUPERGETMV("MV_LOCX059",.F.,"")		// LISTA DOS E-MAILS QUE RECEBERÃO A SOLICITAÇÃO DE TRANSMISSÃO DA DANFE
	Private	LMSERROAUTO := .F.
	Private cProjeto	:= SUPERGETMV("MV_LOCX248",.F.,STR0020) //
	Private lCliObra	:= SUPERGETMV("MV_LOCX204",.F.,.T.)
	Private cNumSC5     := ""
	Private _lPassa     := .F.
	Private _cNumSer	:= ""
	Private aFPZ		:= {}
	Private aFPY		:= {}

	LNFREMBE := .T. // FIXO POR FRANK PARA FUNCIONAMENTO DA TROCA DE FILIAIS 07/10/2020

	_LTUDOOK := .F.

	_lPassa := .F.

	lAtuxMigCl := FPA->(FieldPos("FPA_XMIGCL")) .and. FPA->(FieldPos("FPA_XMIGLJ"))

	If lloca10z
		EXECBLOCK("LOCA10Z",.T.,.T.,{})
	EndIF

	//Begin Transaction
	cFilOld := cFilAnt

	dbSelectArea("FP1")
	FP1->(DBSETORDER(1))
	FP1->(MSSEEK( XFILIAL("FP1") + FQU->FQU_PROJET+ FQU->FQU_OBRA))
	WHILE ! FQVTMP->(EOF())

		cFilNew:=  FQVTMP->XX_FILIAL
		nQtdItens := 0
		aPeso := { 0, 0}
		aCamposSC5 := {}

		while !FQVTMP->(EOF()) .and. cFilNew== FQVTMP->XX_FILIAL  .and. nQtdItens < nMaxItens//  Quebra por Filial
			// Posicionar nna Tabelas
			FQV->(dbGoto(FQVTMP->FQVRECNO))
			FPA->(dbGoto(FQVTMP->FPARECNO))
			FQ5->(dbGoto(FQVTMP->FQ5RECNO))
			ST9->(dbGoto(FQVTMP->ST9RECNO))
			SB1->(dbGoto(FQVTMP->SB1RECNO))

			IF ST9->T9_VALCPA  > 0
				nValProd := NOROUND(ST9->T9_VALCPA  ,2)
			ELSE
				IF Sb1->B1_PRV1 > 0
					nValProd := NOROUND(SB1->B1_PRV1,2)
				ELSE
					nValProd := 0
				ENDIF
			ENDIF

			if Empty(ST9->T9_NOME)
				cDescri := SB1->B1_DESC
			else
				cDescri := ST9->T9_NOME
			endif

			IF nValProd <= 0
				cAviso := "O item " +"'"+ ALLTRIM(FPA->FPA_PRODUT) +"'"+ STR0022 + CRLF + STR0021 //"O ITEM '"###"' ESTÁ COM O VALOR ZERADO."###"FAVOR VERIFICAR O CADASTRO DE PRODUTO (B1_PRV1) OU CADASTRO DO BEM (T9_VALCPA), SE FOR O CASO! "
				RETURN
			ENDIF

			//soma para garantir menos de 300 itens por pedido
			nQtdItens++
			lCliCjTran := .F. //Retorna para valor padrão
			// Quando o parametro MV_GERNFS for .F. temos que verificar se o pedido já foi gerado para não permitir duplicidade
			// Se houver um pedido de vendas com mesmo numero do contrato C5_XPROJET sem gerar NFS e C5_XTIPFAT = "R"
			// Se a AS for correspondente ao C6_XAS ignorar o registro
			If !_MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
				_lProcX := .T.
				_cFilTMP := xFilial("SC5")
				If !empty(FPA->FPA_FILEMI)
					_cFilTMP := FPA->FPA_FILEMI
				EndIF

			EndIF

			if lCliObra
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1") + FQU->FQU_CLIDES + FQU->FQU_LOJDES  ))
			ELSE
				SA1->(dbSetOrder(1))
				SA1->(dbSeek(xFilial("SA1") + FQU->FQU_CLIENT + FQU->FQU_LOJA ))
			ENDIF

			// --> CRIA ARRAY PARA O CABEÇALHO.
			IF LEN(aCamposSC5) == 0

				// Frank em 05/05/22 - indica se usa tabela de preços para a geração do SC5
				// é obrigatório somente quando a condição de pagamento esta amarrada com uma tabela de precos
				_lUsaTab := .F.
				If !empty(FPA->FPA_CODTAB)
					DA0->(dbSetOrder(1))
					If DA0->(dbSeek(xFilial("DA0")+FPA->FPA_CODTAB))
						If !empty(DA0->DA0_CONDPG)
							_lUsaTab := .T.
						EndIf
					EndIf
				EndIF

				aCamposSC5 := {}

				Aadd(aCamposSC5     , {"C5_FILIAL"  , cFilNew           , XA1ORDEM("C5_FILIAL"	) } ) // FRANK EM 07/10/2020
				Aadd(aCamposSC5     , {"C5_NUM"     , cNumSC5             , XA1ORDEM("C5_NUM")     } )
				Aadd(aCamposSC5     , {"C5_TIPO"    , "N"                 , XA1ORDEM("C5_TIPO")    } )
				IF lCliObra
					Aadd(aCamposSC5 , {"C5_CLIENTE"	, FQU->FQU_CLIDES     , XA1ORDEM("C5_CLIENTE") } )
					Aadd(aCamposSC5 , {"C5_LOJACLI"	, FQU->FQU_LOJDES     , XA1ORDEM("C5_LOJACLI") } )
				ELSE
					Aadd(aCamposSC5 , {"C5_CLIENTE" , FQU->FQU_CLIENT     , XA1ORDEM("C5_CLIENTE") } )
					Aadd(aCamposSC5 , {"C5_LOJACLI" , FQU->FQU_LOJA	      , XA1ORDEM("C5_LOJACLI") } )
				ENDIF
				Aadd(aCamposSC5     , {"C5_CLIENT"   , SA1->A1_COD	      , XA1ORDEM("C5_CLIENT")  } )
				Aadd(aCamposSC5     , {"C5_LOJAENT"  , SA1->A1_LOJA	      , XA1ORDEM("C5_LOJAENT") } )
				Aadd(aCamposSC5     , {"C5_TIPOCLI"  , SA1->A1_TIPO	      , XA1ORDEM("C5_TIPOCLI") } )
				Aadd(aCamposSC5     , {"C5_DESC1"    , 0			      , XA1ORDEM("C5_DESC1")   } )
				Aadd(aCamposSC5     , {"C5_DESC2"    , 0	              , XA1ORDEM("C5_DESC2")   } )
				Aadd(aCamposSC5     , {"C5_DESC3"    , 0		          , XA1ORDEM("C5_DESC3")   } )
				Aadd(aCamposSC5     , {"C5_DESC4"    , 0		          , XA1ORDEM("C5_DESC4")   } )
				Aadd(aCamposSC5     , {"C5_TPCARGA"  , "1"			      , XA1ORDEM("C5_TPCARGA") } )
				If _lUsaTab
					Aadd(aCamposSC5     , {"C5_TABELA"   , FPA->FPA_CODTAB , XA1ORDEM("C5_TABELA") } )
				EndIf
				cDtFim 		:= FPA->FPA_DTFIM
				cCondPag 	:= FPA->FPA_CONPAG
				Aadd(aCamposSC5     , {"C5_CONDPAG"  , FPA->FPA_CONPAG , XA1ORDEM("C5_CONDPAG") } )
				Aadd(aCamposSC5     , {"C5_NATUREZ"  , cNaturez           , XA1ORDEM("C5_NATUREZ") } )
				//endif
				// [inicio] José Eulálio - 01/06/2022 - SIGALOC94-156 - Campo de volume e peso na C6.

				Aadd(aCamposSC5     , {"C5_PESOL"	, aPeso[1]		    , XA1ORDEM("C5_PESOL"  ) } )
				Aadd(aCamposSC5     , {"C5_PBRUTO"	, aPeso[2]		    , XA1ORDEM("C5_PBRUTO" ) } )
				If !Empty(FQU->FQU_VOLUME)
					Aadd(aCamposSC5     , {"C5_VOLUME1"	, FQU->FQU_VOLUME	    , XA1ORDEM("C5_VOLUME1" ) } )
				Else
					Aadd(aCamposSC5     , {"C5_VOLUME1"	, 1	    , XA1ORDEM("C5_VOLUME1" ) } )
				EndIf
				If !Empty(FQU->FQU_MENNF)
					Aadd(aCamposSC5     , {"C5_MENNOTA" , FQU->FQU_MENNF      , XA1ORDEM("C5_MENNOTA") } )
				EndIf
				If !Empty(cCmpUsr)
					If SC5->(ColumnPos(cCmpUsr)) > 0
						Aadd(aCamposSC5     , {cCmpUsr , FQU->FQU_MENNOT      , XA1ORDEM(cCmpUsr) } )
					EndIf
				EndIf
				// [inicio] José Eulálio - 02/06/2022 - SIGALOC94-345 - #27421 - Campo de obrigatoriedade Tipo de Transporte (lei)
				If !Empty(FQU->FQU_TPFRET)
					Aadd(aCamposSC5     , {"C5_TPFRETE" ,FQU->FQU_TPFRET      , XA1ORDEM("C5_TPFRETE") } )
				EndIf
				If !Empty(FQU->FQU_CODTRA)
					Aadd(aCamposSC5     , {"C5_TRANSP" , FQU->FQU_CODTRA      , XA1ORDEM("C5_TRANSP") } )
				EndIf

				If !Empty(FQU->FQU_ESPECI)
					Aadd(aCamposSC5     , {"C5_ESPECI1"  , FQ2->FQ2_ESPECI    , XA1ORDEM("C5_ESPECI1") } ) //"MAQUINA"
				Else
					Aadd(aCamposSC5     , {"C5_ESPECI1"  , "MAQUINA"          , XA1ORDEM("C5_ESPECI1") } ) //"MAQUINA" //
				EndIf
				// [final] José Eulálio - 02/06/2022 - SIGALOC94-345 - #27421 - Campo de obrigatoriedade Tipo de Transporte (lei)
				// DSERLOCA-3759 - Circenis- Campos Mercado Internacional
//				if cPaisLoc = "ARG" // Argentina
//					Aadd(aCamposSC5 , {"C5_DOCGER"  , '2'		      , XA1ORDEM("C5_DOCGER") } ) // 2 =  Remito
//				endif

				IF ! Empty(FQU->FQU_VEICUL)
					Aadd( aCamposSC5, {"C5_VEICULO"	, FQU->FQU_VEICUL, XA1ORDEM("C5_VEICULO") } )
				ENDIF
				//Cabeçalho da Tabela de Pedido de Venda x Locação
				// no caso de alterar a estrutura do array precisa alterar também o locm006
				aFPY := {}
				Aadd(aFPY, {"FPY_FILIAL"	, cFilNew			,	NIL })
				Aadd(aFPY, {"FPY_PEDVEN"	, cNumSC5			,	NIL })
				Aadd(aFPY, {"FPY_PROJET"	, FQU->FQU_PROJET	,	NIL })
				Aadd(aFPY, {"FPY_OBRA"	    , FQU->FQU_OBRA 	,	NIL })
				Aadd(aFPY, {"FPY_CLIENT"	, FQU->FQU_CLIENT 	,	NIL })
				Aadd(aFPY, {"FPY_LOJA"	    , FQU->FQU_LOJA 	,	NIL })
				Aadd(aFPY, {"FPY_CLIFAT"	, FQU->FQU_CLIDES 	,	NIL })
				Aadd(aFPY, {"FPY_LOJFAT"	, FQU->FQU_LOJDES	,	NIL })
				Aadd(aFPY, {"FPY_DATA"	    , dDataBase      	,	NIL })
				Aadd(aFPY, {"FPY_TIPFAT"	, "R"				,	NIL })
				Aadd(aFPY, {"FPY_STATUS "	, "1"				,	NIL }) //1=Pedido Ativo;2=Pedido Cancelado
				Aadd(aFPY, {"FPY_ROMAN"     , FQU->FQU_NUM	    ,	NIL })

				aFPYTransf := aFPY
			EndIf

			aItens := {}

			cItem := SOMA1(cItem)
			cItem := IIF(LEN(cItem)==1 , "0"+cItem , cItem)
			// --> CRIA ARRAY PARA OS ITENS
			Aadd(aItens,{"C6_FILIAL"	, cFilNew                         , XA1ORDEM("C6_FILIAL")}) 	// FILIAL - FRANK 07/10/2020
			Aadd(aItens,{"C6_ITEM"		, cItem                             , XA1ORDEM("C6_ITEM"   )}) 					// ITENS
			Aadd(aItens,{"C6_NUM"		, cNumSC5                           , XA1ORDEM("C6_NUM"    )}) 					// NUMERO DO PEDIDO
			Aadd(aItens,{"C6_PRODUTO"	, FPA->FPA_PRODUT				, XA1ORDEM("C6_PRODUTO")}) 					// MATERIAL
			Aadd(aItens,{"C6_UM"		, SB1->B1_UM                     , XA1ORDEM("C6_UM"     )}) 					// UNIDADE DE MEDIDA
			Aadd(aItens,{"C6_DESCRI"	, cDescri                          , XA1ORDEM("C6_DESCRI" )}) 					// DESCRIÇÃO DO PRODUTO
			// Frank em 27/12/2022 chamado 618
			// Inicio [618]
			cTesOld := CTESLF
			If FPA->(FIELDPOS( "FPA_TESREM" )) > 0
				If !empty(FPA->FPA_TESREM)
					cTeslf:= FPA->FPA_TESREM
				EndIF
			EndIF
			// Fim [618]
			IF _GERREMTES //EXISTBLOCK("GERREMTES") 						// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
				cTeslf:= EXECBLOCK("GERREMTES",.T.,.T.,{CTESLF})
			ENDIF
			Aadd(aItens,{"C6_TES"		, cTeslf                          , XA1ORDEM("C6_TES"    )}) 					// TES
			cTESSC6 := CTESLF
			cTeslf:= cTesOld
			Aadd(aItens,{"C6_ENTREG"	, dDataBase 						, XA1ORDEM("C6_ENTREG" )}) 					// DATA DA ENTREGA
//			Aadd(aItens,{"C6_DESCONT"	, 0                                 , XA1ORDEM("C6_DESCONT")}) 					// PERCENTUAL DE DESCONTO
//			Aadd(aItens,{"C6_COMIS1"	, 0                                 , XA1ORDEM("C6_COMIS1" )}) 					// COMISSAO VENDEDOR
			IF lCliObra
				Aadd(aItens,{"C6_CLI"	, SA1->A1_COD                       , XA1ORDEM("C6_CLI"    )}) 					// CLIENTE
				Aadd(aItens,{"C6_LOJA"	, SA1->A1_LOJA                      , XA1ORDEM("C6_LOJA"   )}) 					// LOJA DO CLIENTE
			ELSE
				Aadd(aItens,{"C6_CLI"	, FP0->FP0_CLI                      , XA1ORDEM("C6_CLI"    )}) 					// CLIENTE
				Aadd(aItens,{"C6_LOJA"	, FP0->FP0_LOJA                     , XA1ORDEM("C6_LOJA"   )}) 					// LOJA DO CLIENTE
			ENDIF

			//IF nValProd <= 0
			//	cAviso := "O item " +"'"+ ALLTRIM(FPA->FPA_PRODUT) +"'"+ STR0022 + CRLF + STR0021 //"O ITEM '"###"' ESTÁ COM O VALOR ZERADO."###"FAVOR VERIFICAR O CADASTRO DE PRODUTO (B1_PRV1) OU CADASTRO DO BEM (T9_VALCPA), SE FOR O CASO! "
			//	RETURN
			//ENDIF

			// --> CASO PERTENÇA AO GRUPO QUE É CADASTRADO NO PARÂMETRO PERMITE A OPÇÃO DE SELECIONAR O ARMAZÉM COM SALDO
			nQtd := FQV->FQV_QTD

			Aadd(aItens,{"C6_QTDVEN"	, nQtd					, XA1ORDEM("C6_QTDVEN"	)}) // QUANTIDADE
			Aadd(aItens,{"C6_PRCVEN"	, nValProd				, XA1ORDEM("C6_PRCVEN"	)}) // PRECO DE VENDA / VALOR FRETE
			Aadd(aItens,{"C6_PRUNIT"	, nValProd				, XA1ORDEM("C6_PRUNIT"	)}) // PRECO UNITÁRIO / VALOR FRETE
			Aadd(aItens,{"C6_VALOR"	    , nValProd * nQtd		, XA1ORDEM("C6_VALOR"	)}) // VALOR TOTAL DO ITEM
			IF _MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
				Aadd(aItens,{"C6_QTDLIB"	, nQtd					, XA1ORDEM("C6_QTDLIB"	)}) // QUANTIDADE LIBERADA
			EndIF

			If empty(FPA->FPA_LOCAL)
				Aadd(aItens,{"C6_LOCAL"		, SB1->B1_LOCPAD		, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
			Else
				Aadd(aItens,{"C6_LOCAL"		, FPA->FPA_LOCAL		, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
			EndIF

			IF LEN(ALLTRIM(TRANSFORM(nValProd*nQtd,GETSX3CACHE("C6_VALOR","X3_PICTURE")))) > GETSX3CACHE("C6_VALOR","X3_TAMANHO")
				cAviso := STR0024 + CVALTOCHAR(LEN(ALLTRIM(TRANSFORM(nValProd*nQtd,GETSX3CACHE("C6_VALOR","X3_PICTURE"))))) + STR0025 + ALLTRIM(TRANSFORM(nValProd*nQtd,GETSX3CACHE("C6_VALOR","X3_PICTURE"))) + "." //"O TAMANHO DOS CAMPOS DE VALORES DO PEDIDO DE VENDA SÃO INFERIORES A "###". NÃO SENDO POSSÍVEL GERAR O PEDIDO DE VENDA COM VALOR "
				FQVTMP->(DBCLOSEAREA())
				RestArea(aAreaSC5)
				RestArea(aAreaSC6)
				RestArea(aAreaDA3)
				RestArea(aAreaSA1)
				RETURN
			ENDIF

			// Integração do SIGALOC com o RM
			// Frank Zwarg Fuga em 16/09/21
			If  !empty(_MV_LOC299) // !empty(GetMV("MV_LOCX299",,""))
				Aadd(aItens,{"C6_CC"	, FPA->FPA_CUSTO		, XA1ORDEM("C6_CC"	)}) // CENTRO DE CENTRO ZAG
			EndIf

			IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
				Aadd(aItens,{"C6_CLVL"		, FPA->FPA_AS		, XA1ORDEM("C6_CLVL"	)})  // CLASSE DE VALOR
			ENDIF

			// Controle do endereçamento - Frank 28/07/2021
			// [ inicio - controle de endereçamento ]
			// https://tdn.totvs.com/display/public/PROT/PEST06504+-+Atividade+do+controle+de+numero+de+serie
			_cNumSer := FPA->FPA_GRUA

			// Identificação do local padrão de estoque
			If empty(FPA->FPA_LOCAL) // não informado na locação o local de estoque
				// utilizar o default informado no cadastro de produtos
				_cLocaPad := SB1->B1_LOCPAD
			Else
				_cLocaPad := FPA->FPA_LOCAL
			EndIF

			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+CTESLF))

			If _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "N" .and. !empty(_cNumSer) .and. SF4->F4_ESTOQUE == "S"
				// Neste caso levaremos apenas para o SC6 o número de série da FPA.
				// Não precisa encontrar o endereçamento na SBF.
				//IF SC6->(FIELDPOS("C6_NUMSERI")) > 0
				//	Aadd(aItens,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)})
				//ENDIF

			ElseIf _MV_LOCALIZ == "S" .and. SB1->B1_LOCALIZ == "S" .and. SF4->F4_ESTOQUE == "S"
				If empty(_cNumSer)
					// Neste caso não foi informado o número de série
					// Então vamos encontrar o local de endereçamento na SBF pelo produto/local que tenha o saldo necessário e levar o
					// endereçamento para a SC6
					SBF->(dbSetOrder(2))
					If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
						//MsgAlert("Não foi localizado na tabela de endereçamento o produto: "+alltrim(FPA->FPA_PRODUT)+" no local de estoque: "+_cLocaPAd,"Atenção !") //######"Atenção!"
						If !_MV_GERNFS
							MsgAlert(STR0028+alltrim(FPA->FPA_PRODUT)+STR0026+_cLocaPAd+STR0027,STR0014) //#########
						Else
							MsgAlert(STR0028+alltrim(FPA->FPA_PRODUT)+STR0026+_cLocaPAd,STR0014) //######
							aCamposSC5 := {}
							aCamposSC6 := {}
							aItens     := {}
							RestArea(aAreaSC5)
							RestArea(aAreaSC6)
							RestArea(aAreaDA3)
							RestArea(aAreaSA1)
							_LTUDOOK := .F.
							cAviso := STR0029 //
							Return .F.
						EndIf
					Else
						_cLocaEnd := ""
						// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
						//verifica somente se TES controla estoque, solicitação do Lui em 09/11/2021 - CHAMADO #27587
						SF4->(dbSetOrder(1))
						If SF4->( MSSEEK(xFilial("SF4") + CTESLF, .F. ) ) .And. SF4->F4_ESTOQUE == "S"
							While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_Local == _cLocaPad
								If SBF->BF_QUANT - SBF->BF_EMPENHO >= nQtd	 //.Or. !_MV_GERNFS  //SIGALOC94-958 - 21/07/2023 - Jose Eulalio - Somente verificar estoque quando MV_GERNFS = .T.
									_cLocaEnd := SBF->BF_LOCALIZ
									exit
								EndIF
								SBF->(dbSkip())
							EndDo
							If empty(_cLocaEnd)
								If !_MV_GERNFS
									MsgAlert(STR0030+FPA->FPA_PRODUT+STR0027,STR0014) //#########
								Else
									MsgAlert(STR0030+FPA->FPA_PRODUT,STR0031)  //###
									aCamposSC5 := {}
									aCamposSC6 := {}
									aItens     := {}
									RestArea(aAreaSC5)
									RestArea(aAreaSC6)
									RestArea(aAreaDA3)
									RestArea(aAreaSA1)
									_LTUDOOK := .F.
									cAviso := STR0029 //
									Return .F.
								EndIF
							EndIF
						EndIf
						RestArea(aAreaSF4)

						Aadd(aItens,{"C6_LOCALIZ"	,_cLocaEnd  , XA1ORDEM("C6_LOCALIZ"	)})
					EndIF
				Else
					// Neste caso foi informado o número de série
					// Então vamos encontrar o local de endereçamento na SBF produto/local/NS que tenha o saldo necessário e levar
					// o endereçamento para a SC6
					// levar em consideração a mensagem de que existem saldos parciais que atendem o todo avisar e não deixar gerar o pv
					SBF->(dbSetOrder(2))
					If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
						If !_MV_GERNFS
							MsgAlert(STR0028+alltrim(FPA->FPA_PRODUT)+STR0026+_cLocaPAd+STR0027,STR0014) //#########"Atenção!"
						Else
							MsgAlert(STR0028+alltrim(FPA->FPA_PRODUT)+STR0026+_cLocaPAd,STR0014) //######"Atenção!"
							aCamposSC5 := {}
							aCamposSC6 := {}
							aItens     := {}
							RestArea(aAreaSC5)
							RestArea(aAreaSC6)
							RestArea(aAreaDA3)
							RestArea(aAreaSA1)
							_LTUDOOK := .F.
							cAviso := STR0029 //
							Return .F.
						EndIf
					Else
						_cLocaEnd := ""
						// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
						//verifica somente se TES controla estoque, solicitação do Lui em 09/11/2021 - CHAMADO #27587
						SF4->(dbSetOrder(1))
						If SF4->( MSSEEK(xFilial("SF4") + CTESLF, .F. ) ) .And. SF4->F4_ESTOQUE == "S"
							While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_Local == _cLocaPad
								//If !empty(SBF->BF_NUMSERI) // Em 25/05/2023 Lui solicitou para retirar essa regra para ser definida posteriormente
								//If alltrim(SBF->BF_NUMSERI) == alltrim(_cNumSer)
								If LOCA01002(FPA->FPA_PRODUT,_cNumSer)
									If SBF->BF_QUANT - SBF->BF_EMPENHO < nQtd	//.Or. !_MV_GERNFS //SIGALOC94-958 - 21/07/2023 - Jose Eulalio - Somente verificar estoque quando MV_GERNFS = .T.
										_cLocaEnd := "" //SBF->BF_LOCALIZ
									else
										_cLocaEnd := SBF->BF_LOCALIZ
										exit
									EndIF
								EndIF
								SBF->(dbSkip())
							EndDo
							If empty(_cLocaEnd)
								If !_MV_GERNFS
									MsgAlert(STR0030+FPA->FPA_PRODUT,STR0031) //###
								Else
									MsgAlert(STR0030+FPA->FPA_PRODUT,STR0031) //###
									aCamposSC5 := {}
									aCamposSC6 := {}
									aItens     := {}
									RestArea(aAreaSC5)
									RestArea(aAreaSC6)
									RestArea(aAreaDA3)
									RestArea(aAreaSA1)
									_LTUDOOK := .F.
									cAviso := STR0029 //
									Return .F.
								EndIf
							EndIF
						EndIf
						RestArea(aAreaSF4)
						IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 .and. (LOCA01002(FPA->FPA_PRODUT,_cNumSer) .or. _MV_LOCALIZ == "N")
							Aadd(aItens,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)})
						ENDIF

						Aadd(aItens,{"C6_LOCALIZ"	,_cLocaEnd  , XA1ORDEM("C6_LOCALIZ"	)})
					EndIf
				EndIF
			ElseIf _MV_LOCALIZ == "N" .and. SB1->B1_LOCALIZ == "S" .and. SF4->F4_ESTOQUE == "S"
				// Neste caso independente de ser infomado o NS
				// Vamos encontrar o local de endereçamento pelo produto/armazem na SBF que tenha o saldo necessário e levar o
				// endereçamento para a SC6
				// não levaremos o número de série para a sc6.

				SBF->(dbSetOrder(2))
				If !SBF->(dbSeek(xFilial("SBF")+FPA->FPA_PRODUT+_cLocaPAd))
					If !_MV_GERNFS
						MsgAlert(STR0028+alltrim(FPA->FPA_PRODUT)+STR0026+_cLocaPAd,STR0014) //######"Atenção!"
					Else
						MsgAlert(STR0028+alltrim(FPA->FPA_PRODUT)+STR0026+_cLocaPAd,STR0014) //######"Atenção!"
						aCamposSC5 := {}
						aCamposSC6 := {}
						aItens     := {}
						RestArea(aAreaSC5)
						RestArea(aAreaSC6)
						RestArea(aAreaDA3)
						RestArea(aAreaSA1)
						_LTUDOOK := .F.
						cAviso := STR0029 //
						Return .F.
					EndIf
				Else
					_cLocaEnd := ""
					// Tental localizar um endereço que atenda na totalidade a quantidade da FPA
					//verifica somente se TES controla estoque, solicitação do Lui em 09/11/2021 - CHAMADO #27587
					SF4->(dbSetOrder(1))
					If SF4->( MSSEEK(xFilial("SF4") + CTESLF, .F. ) ) .And. SF4->F4_ESTOQUE == "S"
						While !SBF->(Eof()) .and. SBF->BF_PRODUTO == FPA->FPA_PRODUT .and. SBF->BF_Local == _cLocaPad
							If SBF->BF_QUANT - SBF->BF_EMPENHO >= nQtd //.Or. !_MV_GERNFS  //SIGALOC94-958 - 21/07/2023 - Jose Eulalio - Somente verificar estoque quando MV_GERNFS = .T.
								_cLocaEnd := SBF->BF_LOCALIZ
								exit
							EndIF
							SBF->(dbSkip())
						EndDo
						If empty(_cLocaEnd)
							If !_MV_GERNFS
								MsgAlert(STR0030+FPA->FPA_PRODUT,STR0031) //###
							Else
								MsgAlert(STR0030+FPA->FPA_PRODUT,STR0031) //###
								aCamposSC5 := {}
								aCamposSC6 := {}
								aItens     := {}
								RestArea(aAreaSC5)
								RestArea(aAreaSC6)
								RestArea(aAreaDA3)
								RestArea(aAreaSA1)
								_LTUDOOK := .F.
								cAviso := STR0029 //
								Return .F.
							EndIF
						EndIF
					EndIf
					RestArea(aAreaSF4)
					IF SC6->(FIELDPOS("C6_NUMSERI")) > 0 .and. (LOCA01002(FPA->FPA_PRODUT,_cNumSer) .or. _MV_LOCALIZ == "N")
						Aadd(aItens,{"C6_NUMSERI"	,_cNumSer       , XA1ORDEM("C6_NUMSERI"	)})
					ENDIF
					Aadd(aItens,{"C6_LOCALIZ"	,_cLocaEnd  , XA1ORDEM("C6_LOCALIZ"	)})

				EndIF

			EndIF
			// Fim controle de enderecamento

			IF SC6->(FIELDPOS("C6_FROTA")) > 0 //.and. (LOCA01002(FPA->FPA_PRODUT,_cNumSer) .or. _MV_LOCALIZ == "N")
				Aadd(aItens,{"C6_FROTA"	,_cNumSer       , XA1ORDEM("C6_FROTA"	)})
			ENDIF

			// [inicio] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
			If SC6->(ColumnPos("C6_OBSCCMP")) > 0 .And. SC6->(ColumnPos("C6_OBSCONT")) > 0 .And. SC6->(ColumnPos("C6_OBSFISC")) > 0 .And. SC6->(ColumnPos("C6_OBSFCMP")) > 0
				Aadd(aItens,{"C6_OBSCCMP"		, FQV->FQV_OBSCON	, XA1ORDEM("C6_OBSCCMP"	)})  // TITULO OBS CONTRIBUINTE
				Aadd(aItens,{"C6_OBSCONT"		, FQV->FQV_OBSCCM		, XA1ORDEM("C6_OBSCONT"	)})  // OBS CONTRIBUINTE
				Aadd(aItens,{"C6_OBSFCMP"		, FQV->FQV_OBSFCM		, XA1ORDEM("C6_OBSFCMP"	)})  // TITULO OBS FISCO
				Aadd(aItens,{"C6_OBSFISC"		, FQV->FQV_OBSFIS		, XA1ORDEM("C6_OBSFISC"	)})  // OBS FISCO
			EndIf
			// Acumula peso
			aPeso[1] += FQ5->FQ5_PESLIQ
			aPeso[2] += FQ5->FQ5_PESBRU
			nPonteiro ++
			// [final] José Eulálio - 02/06/2022 - #27421 Campos (lei) de obs do Romaneio para PV (remessa)
			Aadd(aCamposSC6, aItens )


			IF _GERREFLOG //EXISTBLOCK("GERREFLOG") 						// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
				EXECBLOCK("GERREFLOG",.T.,.T.,{FPA->FPA_GRUA, nValProd, FPA->FPA_PRODUT})
			ENDIF

			//soma total do pedido
			nValTot	  += FPA->FPA_VRHOR

			//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
			If lMvLocBac
				// no caso de alterar a estrutura do array precisa alterar também o locm006
				xTemp := ""
				For nY:=1 to len(aItens)
					If alltrim(aItens[nY][1]) == "C6_FILIAL"
						xTemp := aItens[nY][2]
					EndIF
				Next
				Aadd(aItemFPZ, {"FPZ_FILIAL"	, xTemp		,	NIL })
				xTemp := ""
				For nY:=1 to len(aItens)
					If alltrim(aItens[nY][1]) == "C6_NUM"
						xTemp := aItens[nY][2]
					EndIF
				Next
				Aadd(aItemFPZ, {"FPZ_PEDVEN"	, xTemp		        , 	NIL })
				Aadd(aItemFPZ, {"FPZ_PROJET"	, cProjet 			,	NIL })

				xTemp := ""
				For nY:=1 to len(aItens)
					If alltrim(aItens[nY][1]) == "C6_ITEM"
						xTemp := aItens[nY][2]
					EndIF
				Next
				Aadd(aItemFPZ, {"FPZ_ITEM"		, xTemp 		 ,	NIL })
				Aadd(aItemFPZ, {"FPZ_AS"		, FPA->FPA_AS	 , 	NIL })
				Aadd(aItemFPZ, {"FPZ_ROMAN"	    , FQV->FQV_NUM   ,	NIL })
				Aadd(aItemFPZ, {"FPZ_EXTRA"		, "N"			 ,	NIL })
				Aadd(aItemFPZ, {"FPZ_FROTA"		, FPA->FPA_GRUA	 ,	NIL })
				//Aadd(aItemFPZ, {"FPZ_PERLOC"	, _cPerloc			,	NIL })
				Aadd(aItemFPZ, {"FPZ_CCUSTO"	, FPA->FPA_CUSTO ,	NIL })
				Aadd(aItemFPZ, {"FPZ_DTPED"     , dDatabase   	    ,	NIL })
				Aadd(aItemFPZ, {"FPZ_ITMFPZ"    , xTemp   	        ,	NIL })
				Aadd(aItemFPZ, {"FPZ_QUANT "    , nQtd	   	        ,	NIL })
				Aadd(aItemFPZ, {"FPZ_VALUNI"    , nValProd  	    ,	NIL })
				Aadd(aItemFPZ, {"FPZ_TES"       , cTESSC6  	        ,	NIL })
				Aadd(aItemFPZ, {"FPZ_TOTAL"     , nValProd  * nQtd	    ,	NIL })
				Aadd(aItemFPZ, {"FPZ_PROD"      , FPA->FPA_PRODUT   	    ,	NIL })
				Aadd(aItemFPZ, {"FPZ_VIAGEM"    , FPA->FPA_VIAGEM   	    ,	NIL })
				IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
					Aadd(aItemFPZ, {"FPZ_CLVL"     , FPA->FPA_AS   	    ,	NIL })
				endif
				Aadd(aItemFPZ, {"FPZ_OBRA"     , FPA->FPA_OBRA  	    ,	NIL })


				Aadd(aFPZ,Aclone(aItemFPZ))
				aItemFPZ := {}

			EndIf

			FQVTMP->(dbSkip())

		enddo

		nParc1 	  := 100

		aFPZTransf := aFPZ

		// --> CASO TENHA ALGUM VEÍCULO INSERE NO CABEÇALHO DO PEDIDO.


		//SIGALOC94-838 - 17/07/2023 -  Jose Eulalio - Condição de Pagamenteo tipo 9
		SE4->(dbSetOrder(1))
		If SE4->( MSSEEK(xFilial("SE4") + cCondPag, .F. ) ) .And. SE4->E4_TIPO == "9"
			If AllTrim(SE4->E4_COND) == "0"
				nParc1 := nValTot
			EndIf
			cDtFim := IIF(cDtFim < dDataBase, dDataBase, cDtFim)
			Aadd(aCamposSC5     , {"C5_PARC1"  , nParc1	 , XA1ORDEM("C5_PARC1") } )
			Aadd(aCamposSC5     , {"C5_DATA1"  , cDtFim	 , XA1ORDEM("C5_DATA1") } )
			nValTot	  := 0
		EndIf

		Aadd(aCamposSC5     , {"C5_PESOL"	, aPeso[1]		    , XA1ORDEM("C5_PESOL"  ) } )
		Aadd(aCamposSC5     , {"C5_PBRUTO"	, aPeso[2]		    , XA1ORDEM("C5_PBRUTO" ) } )

		IF  lGERREMC5 //EXISTBLOCK("GERREMC5")
			//aCamposSC5 := U_GERREMC5( aCamposSC5 )
			aCamposSC5 := EXECBLOCK("GERREMC5" , .T. , .T. , {aCamposSC5})
		ENDIF

		// --> ORDENA O ARRAY DO CABEÇALHO DE ACORDO COM A ORDEM DO CAMPO
		ASORT(aCamposSC5,,,{|X,Y| X[3]<Y[3]})
		// --> TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADRÃO DO EXECAUTO
		FOR _NV := 1 TO LEN(aCamposSC5)
			aCamposSC5[_NV][3] := NIL
		NEXT _NV

		// --> ACERTO DO ARRAY DE ITENS
		FOR NY := 1 TO LEN(aCamposSC6)
			// ORDENA O ARRAY DO CABEÇALHO DE ACORDO COM A ORDEM DO CAMPO
			ASORT(aCamposSC6[NY],,,{|X,Y| X[3]<Y[3]})
			// TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADRÃO DO EXECAUTO
			FOR _NV := 1 TO LEN(aCamposSC6[NY])
				aCamposSC6[NY][_NV][3] := NIL
			NEXT _NV
		NEXT NY

		// --> TRATATIVAS PARA A GERAÇÃO DO PEDIDO DE VENDA.
		cFilOld  := cFilAnt
		cFilAnt := cFilNew
		cNumSC5 := XSC5NUM()
		_NPNUMC5 := ASCAN(ACAMPOSSC5   ,{|X| ALLTRIM(X[1])=="C5_NUM"})
		aCamposSC5[_NPNUMC5][2] := cNumSC5

		IF ! Empty(cNumSC5)
			// --> GRAVA USANDO O EXECAUTO
			PROCESSA({|| EXECPV(aCamposSC5,aCamposSC6,LNFREMBE) }, STR0035 + cNumSC5, STR0034, .T.)  //###
			IF Empty(_CPEDIDO)
				cAviso := STR0036 + _MV_LOC248 + " "+ALLTRIM(cProjet)+" !" + CRLF //"NÃO FOI POSSÍVEL GERAR O PEDIDO DE VENDA PARA O "###"PROJETO"
				//DISARMTRANSACTION()
				LOOP
			ELSE
				cAviso   := STR0037+_CPEDIDO+"]."  //
			ENDIF

			// --> GERA A NOTA
			IF cPaisLoc = "BRA" .and. _MV_GERNFS //SUPERGETMV("MV_GERNFS",,.T.)
				PROCESSA({|| GRAVANFS( _CPEDIDO,cTesrf,CTESLF,cSerie ) } , STR0038 + _CPEDIDO , STR0034 , .T.)  //###
				IF Empty( _CNOTA )
					cAviso := STR0039+_CPEDIDO+"]"  //"NÃO FOI POSSÍVEL FATURAR O PEDIDO DE REMESSA ["
					//	DISARMTRANSACTION()
				ELSE

					IF _GERREMFIM //EXISTBLOCK("GERREMFIM") 		// --> PONTO DE ENTRADA NO FINAL DA GERAÇÃO DA NOTA FISCAL DE REMESSA.
						EXECBLOCK("GERREMFIM",.T.,.T.,{_CNOTA,_CPEDIDO,aCamposSC5,aCamposSC6})
					ENDIF
					_LTUDOOK := .T.
					cAviso   := STR0037+_CPEDIDO+"]." +CRLF + STR0040+_CNOTA+"] !"  //###
				ENDIF
			ENDIF
		ENDIF

		aFPZTransf := aFPZOld

		//	END TRANSACTION
		cFilAnt := cFilOld

		aCamposSC5 := {}
		aCamposSC6 := {}
		aItens     := {}
		aFPZ     	:= {}
		aFPy     	:= {}
		aItemFPZ   	:= {}

	ENDDO

	//End Transaction

	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaDA3)
	RestArea(aAreaSA1)
	RestArea(aAreaSE4)

RETURN

/*/{Protheus.doc} XSC5NUM
Retorna o proximo numero de pedido de venda
@type function
@version  25.10
@author Alexandre Circenis
@since 6/25/2025
@return variant, Numero de pedido valido
/*/
STATIC FUNCTION XSC5NUM()
	cNumSC5	:= GETSXENUM("SC5","C5_NUM")
	WHILE .T.
		IF SC5->( dbSeek(xFilial("SC5") + cNumSC5) )
			CONFIRMSX8()
			cNumSC5 := GETSXENUM("SC5","C5_NUM")
			LOOP
		ELSE
			EXIT
		ENDIF
	ENDDO

	ROLLBACKSXE()

RETURN cNumSC5

/*/{Protheus.doc} ItensPed
Gera a consulta com todos os itens do romaneio em numero de pedido
@type function
@version 25.10 
@author Alexandre Circenis
@since 6/25/2025
@return variant, Return .T. se tiverem itens 
/*/
STATIC FUNCTION ItensPed( )

	Local LRET 		 := .F.
	Local cQuery	 := ""

	Local aBindParam := {}

	cQuery     := " SELECT CASE WHEN FPA.FPA_FILEMI <> ' ' THEN FPA.FPA_FILEMI ELSE FPA.FPA_FILIAL END XX_FILIAL, FQV.R_E_C_N_O_ FQVRECNO,"
	cQuery     += "        FPA.R_E_C_N_O_ FPARECNO, FQ5.R_E_C_N_O_ FQ5RECNO, COALESCE( ST9.R_E_C_N_O_, 0) ST9RECNO, SB1.R_E_C_N_O_ SB1RECNO"
	cQuery     += " FROM "+RETSQLNAME("FQV")+" FQV "
	cQuery     += "        INNER JOIN "+RETSQLNAME("FPA")+" FPA ON  FPA.FPA_FILIAL  = FQV.FQV_FILIAL  AND FPA.FPA_AS = FQV.FQV_AS "
	cQuery     += "                                             AND  FPA.D_E_L_E_T_ =  '' "
	cQuery     += "        INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_COD     = FQV.FQV_PROD       AND  SB1.D_E_L_E_T_ = '' "
	cQuery     += "                                             AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "  // SIGALOC94-763 - 05/06/2023 - Jose Eulalio - Adicionado Filial para atender Compartilhamento de Tabelas em Clientes com mais de uma filial
	cQuery     += "        INNER JOIN "+RETSQLNAME("FQ5")+" FQ5 ON  FQ5.FQ5_FILIAL = '" + xFilial("FQ5") + "' AND FQ5.FQ5_AS     = FQV.FQV_AS "
	cQuery     += "                                             AND FQ5.FQ5_GUINDA = FPA_GRUA             AND  FQ5.D_E_L_E_T_ =  '' "
	cQuery     += "        LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 ON  ST9.T9_CODBEM  = FQV.FQV_CODBEM        AND  ST9.T9_CODBEM  <> '' "
	cQuery     += "                                             AND ST9.D_E_L_E_T_ = '' "
	cQuery     += "                                             AND ST9.T9_FILIAL = '" + xFilial("ST9") + "' "  // SIGALOC94-763 - 05/06/2023 - Jose Eulalio - Adicionado Filial para atender Compartilhamento de Tabelas em Clientes com mais de uma filial
	cQuery     += " WHERE  FQV.FQV_FILIAL =  '"+XFILIAL("FQV")+"' "
	cQuery     += "   AND  FQV.FQV_NUM =  ? "
	cQuery     += "   AND  FQV.FQV_PEDIDO = ' '" // nâo pode ter pedido gerado
	aadd(aBindParam, FQU->FQU_NUM) // Emitir o pedido do romaneio posicionado
	cQuery     += "   AND  FQV.D_E_L_E_T_ =  '' "
	cQuery     += " ORDER BY XX_FILIAL, FQV.FQV_ITEM "

	cQuery := CHANGEQUERY(cQuery)

	MPSysOpenQuery(cQuery,"FQVTMP",,,aBindParam)
	//TcQuery cQuery NEW ALIAS "FQVTMP"

	FQVTMP->(DBGOTOP())

	lRet := !FQVTMP->(EOF())

RETURN lRet

/*/{Protheus.doc} XA1ORDEM
Retorna o valor do X3_ORDEm de um campo
@type function
@version 25.10 
@author Alexandre Circenis
@since 6/25/2025
@param CCAMPO, character, Nomeo do campo procurado
@return variant, Valor do X3_ORDEM
/*/
STATIC FUNCTION XA1ORDEM(CCAMPO)

	Local aAreaSX3 := (LOCXCONV(1))->(GETAREA())

	(LOCXCONV(1))->(DBSETORDER(2))
	(LOCXCONV(1))->(DBSEEK(CCAMPO))
	CRET := &(LOCXCONV(4))

	RESTAREA(aAreaSX3)

RETURN CRET

/*/{Protheus.doc} EXECPV
Gera o pedido de vendas para o romaneio
@type function
@version 25.10
@author Alexandre Circenis
@since 6/25/2025
@param _ACABEC, variant, Array com o valores da SC5
@param _AITENS, variant, Array com os valores da SC6
@param LNFREMBE, logical, Obsoleto
/*/
STATIC FUNCTION EXECPV(_ACABEC , _AITENS , LNFREMBE)
	IF LEN(_ACABEC) > 0 .AND. LEN(_AITENS) > 0
		INCPROC(STR0041) //

		//SetRotInteg("MATA410") // integracao rm
		If !empty(GetMV("MV_LOCX299",,""))
			SetRotInteg("MATA410")
		EndIf
		MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABEC , _AITENS , 3)
		IF LMSERROAUTO
			MOSTRAERRO()
			ROLLBACKSX8()
			//Valida se está enviando Localização e Numero de Serie e se a ordem dos campos está correta
			MsgNumSeri(_AITENS)
			RETURN .F.
		ELSE
			_CPEDIDO := CNUMSC5
			CONFIRMSX8()
			IF RECLOCK("SC5",.F.)
				SC5->C5_ORIGEM := "LOCA010"
				SC5->(MSUNLOCK())
			ENDIF

		ENDIF
	ELSE
		MSGSTOP(STR0042 , STR0015)  //###
		RETURN .F.
	ENDIF

RETURN


/*/{Protheus.doc} GRAVANFS
Gera a nota fiscal para o pedido do romaneio
@type function
@version  25.10
@author Alexandre Circenis
@since 6/25/2025
@param _CPEDIDO, variant, Numro do pedido base para a emissão da nota
@param CTESRF, character, Obsoleto
@param CTESLF, character, Obsoleto
@param CSERIE, character, Serie utilizada para gerar a nota
/*/
STATIC FUNCTION GRAVANFS( _CPEDIDO , CTESRF , CTESLF , CSERIE )
	Local aAreaANT  := GETAREA()
	Local aAreaSC5  := SC5->(GETAREA())
	Local aAreaSC6  := SC6->(GETAREA())
	Local aAreaSC9  := SC9->(GETAREA())
	Local aAreaSE4  := SE4->(GETAREA())
	Local aAreaSB1  := SB1->(GETAREA())
	Local aAreaSB2  := SB2->(GETAREA())
	Local aAreaSF4  := SF4->(GETAREA())
	Local APVLNFS   := {}
	Local CROT      := ""
	Local cQuery
	Local CALIASQRY := GETNEXTALIAS()
	Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
//Local AITENS  := {}

	CROT := PROCNAME()

	PERGUNTE("MT460A",.F.)

	SC5->( DBSETORDER(1) ) //C5_FILIAL + C5_NUM
	SC6->( DBSETORDER(1) ) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	SC9->( DBSETORDER(1) ) //C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

	cQuery   := " SELECT DISTINCT C5_NUM "
	cQuery   += " FROM "+RETSQLNAME("SC5")+" SC5 (NOLOCK) "
	//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas

	cQuery   += "        JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM "
	cQuery   += "		INNER JOIN  " + RETSQLNAME("FPZ") + " FPZ (NOLOCK) "
	cQuery   += "			ON 	FPZ_FILIAL = C6_FILIAL  AND "
	cQuery   += "				FPZ_PEDVEN = C6_NUM "
	cQuery   += " WHERE FPZ_FILIAL  =  ? "
	cQuery   += "   AND FPZ_PROJET =  ? "
	cQuery   += "	AND	FPZ_PEDVEN = ? "
	cQuery   += "   AND  C6_NOTA    =  '' "
	cQuery   += "   AND  C6_BLOQUEI =  '' "
	cQuery   += "   AND  SC5.D_E_L_E_T_ = '' "
	cQuery   += "   AND  SC6.D_E_L_E_T_ = '' "
	If lMvLocBac
		cQuery   += "   AND  FPZ.D_E_L_E_T_ = '' "
	EndIf
	//CONOUT("[GERNFREM.PRW] # cQuery(1): " + cQuery)
	cQuery := CHANGEQUERY(cQuery)
	aBindParam := {XFILIAL("SC5"), cProjet, SC5->C5_NUM }

	//DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,cQuery),CALIASQRY, .F., .T.)
	CALIASQRY := MPSysOpenQuery(cQuery,,,,aBindParam)

	WHILE ! (CALIASQRY)->( EOF() )
		_CPEDIDO := (CALIASQRY)->C5_NUM
		IF SC5->( MSSEEK(XFILIAL("SC5") + _CPEDIDO, .F. ) )
			IF SC9->( DBSEEK( XFILIAL("SC9")+_CPEDIDO ) )
				WHILE !SC9->(EOF()) .AND. SC9->C9_PEDIDO == _CPEDIDO
					IF SC6->( DBSEEK( XFILIAL("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO ) )

						SE4->(DBSETORDER(1))
						SE4->( MSSEEK(XFILIAL("SE4") + SC5->C5_CONDPAG, .F. ) )

						// --> POSICIONA NO PRODUTO
						SB1->(DBSETORDER(1))
						SB1->( MSSEEK(XFILIAL("SB1") + SC6->C6_PRODUTO, .F. ) )

						// --> POSICIONA NO SALDO EM ESTOQUE
						SB2->(DBSETORDER(1))
						SB2->( MSSEEK(XFILIAL("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL, .F. ) )

						// --> POSICIONA NO TES
						CTES := SC6->C6_TES
						SF4->(DBSETORDER(1))
						SF4->( MSSEEK(XFILIAL("SF4") + CTES, .F. ) )

						_NPRCVEN := SC9->C9_PRCVEN

						// --> MONTA ARRAY PARA GERAR A NOTA FISCAL
						AADD( APVLNFS , { SC9->C9_PEDIDO   , ;
							SC9->C9_ITEM     , ;
							SC9->C9_SEQUEN   , ;
							SC9->C9_QTDLIB   , ;
							_NPRCVEN         , ;
							SC9->C9_PRODUTO  , ;
							.F.              , ;
							SC9->( RECNO() ) , ;
							SC5->( RECNO() ) , ;
							SC6->( RECNO() ) , ;
							SE4->( RECNO() ) , ;
							SB1->( RECNO() ) , ;
							SB2->( RECNO() ) , ;
							SF4->( RECNO() ) } )
					ENDIF
					SC9->(DBSKIP())
				ENDDO
			ENDIF
		ENDIF
		(CALIASQRY)->(DBSKIP())
	ENDDO
	(CALIASQRY)->(DBCLOSEAREA())

	DBSELECTAREA("SC9")

	IF ! EMPTY(APVLNFS)
		//CONOUT("Gerando Nota Fiscal de Saída") //"GERANDO NOTA FISCAL DE SAIDA"
		_CNOTA := MAPVLNFS(APVLNFS , CSERIE , .F. , .F. , .F. , .T. , .F. , 0 , 0 , .T. , .F.)
		//CONOUT("Nota Fiscal: "+_CNOTA) //
		// ADCIONAR UMA BUSCA PARA VERIFICAR SE O PEDIDO EXISTE EM ALGUMA NOTA DA TABELA, CASO DESPOSICIONE....
		
	ENDIF

	IF SF2->(FIELDPOS("F2_IT_ROMA")) > 0
		IF RECLOCK("SF2",.F.)
			SF2->F2_IT_ROMA := FQU->FQU_NUM	// RECEBE NUMERO DO ROMANEIO.
			SF2->(MSUNLOCK())
		ENDIF
	ENDIF

	// --> RETORNA AS AREAS ORIGINAIS
	RESTAREA( aAreaSF4 )
	RESTAREA( aAreaSB2 )
	RESTAREA( aAreaSB1 )
	RESTAREA( aAreaSE4 )
	RESTAREA( aAreaSC9 )
	RESTAREA( aAreaSC6 )
	RESTAREA( aAreaSC5 )
	RESTAREA( aAreaANT )

RETURN


//------------------------------------------------------------------------------
/*/{Protheus.doc} MsgNumSeri
Valida se está enviando Localização e Numero de Serie e se a ordem dos campos está correta
@author Jose Eulalio
@since 18/07/2023
/*/
//------------------------------------------------------------------------------
Static Function MsgNumSeri(_AITENS)
Local nPosNumSer	:= 0
Local nPosLocali	:= 0
Local nX			:= 0

	//roda itens para verificar se estão preenchidos e a ordem
	For nX := 1 To Len(_AITENS)
		//pega a posição a cada linha, pois não necessariamente estarão em todos os itens
		nPosNumSer := Ascan(_AITENS[nX],{|X| AllTrim(X[1])=="C6_NUMSERI"})
		nPosLocali := Ascan(_AITENS[nX],{|X| AllTrim(X[1])=="C6_LOCALIZ"})
		//verifica se enviou os dois
		If nPosNumSer > 0 .And. nPosLocali > 0
			//verifica se os dois foram preenchidos
			If !Empty(_AITENS[nX][nPosNumSer][2]) .And. !Empty(_AITENS[nX][nPosLocali][2])
				//verifica se o Localiz está maior que o NumSeri, se estiver menor apresenta mensagem
				If XA1ORDEM("C6_LOCALIZ") <  XA1ORDEM("C6_NUMSERI")
					Help(NIL, NIL, "LOCA010_04", NIL, "Essa emissão de NF contém Série e Endereçamento, porém os campos estão em ordem incorreta.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Para bom funcionamento altere a ordem do campo C6_LOCALIZ de forma que o campo fique a frente (ordem maior) do campo C6_NUMSERI."}) // ### 
				EndIf
			EndIf
		EndIf
	Next nX

Return
