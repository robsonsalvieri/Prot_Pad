#include "TOTVS.ch"
#include "TOPCONN.CH"
#include "LOCA248.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

/*/{PROTHEUS.DOC} LOCA24804
ITUP BUSINESS - TOTVS RENTAL
Geração do pedido de vendas
Frank Z Fuga em 30/07/2024
/*/
Function LOCA24804
	Processa({|| xRet := LOCA24804C()},STR0147) // Gerando o pedido de vendas
Return .T.

/*/{PROTHEUS.DOC} LOCA24804C
ITUP BUSINESS - TOTVS RENTAL
Geração do pedido de vendas
Frank Z Fuga em 30/07/2024
/*/

Function LOCA24804C
Local aCamposSc5 := {}
Local aItens     := {}
Local aCamposSc6 := {}
Local cTesMaq    := FQK->FQK_TESMAQ
Local cTesMao    := FQK->FQK_TESMAO
Local aItensMed  := {}
Local cVendedor  := ""
Local nComissao  := 0
Local cProdMo := GetMV("MV_LOCX064",,"")
Local cProdMa := GetMV("MV_LOCX063",,"")
Local cItem
Local dDtIni
Local dDtFim
Local nDiasTRB
Local nX
Local cPerloc
Local aItemFPZ := {}
Local aFPY := {}
Local lCVal	:= SuperGetMv("MV_LOCX051",.F.,.T.)
Local aFPZ := {}
Local aAgluRat := {}
Local aItemAGG := {}
Local aAuxRat := {}
Local aAsMaq := {}
Local aAsMao := {}
Local nTemp
Local nItem
Local aExecAuto := {} // Custo extra
Local aPedido := {}
Local cPedido := ""
Local aAs := {}
Local lTem := .F.
Local nItemFPZ  := 0
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local l248CB := ExistBlock("LOC248CB")
Local aRet := {}
Local aAsProv := {}
Local _MV_LOC278 := SuperGetMV("MV_LOCX278",.F.,.F.)
Local cQuery 	 := ''
Local aParam     := {}
Local cAliasT    := GetNextAlias()

Private aFPYTransf := {}  // Deve ser private e serão utilizadas no LOCM006
Private aFPZTransf := {}  // Deve ser private e serão utilizadas no LOCM006
Private _LROMANEIO := .F. // Deve ser private e serão utilizadas no LOCM006
Private LMSERROAUTO := .F.
Private aRetExec := {}  

	ProcRegua(5)

	// Recalcular os totais.
	LOCA248A6X()

	If FQK->FQK_TIPO == "C" 
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	If !empty(FQK->FQK_NUMPV)
		MsgAlert(STR0034,STR0002) //"Inconsistência nos dados."###"Já existe pedido de venda para este serviço"
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	If FQK->FQK_SITUACA != "2"
		MsgAlert(STR0035, STR0002) //"Inconsistência nos dados."###"Não é possível gerar pedido de venda para medições não confirmadas."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	If empty(FQK->FQK_CONDPA)
		MsgAlert(STR0036, STR0002) //"Inconsistência nos dados."###"Falta o preenchimento da condição de pagamento."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIF

	FQL->(dbSetOrder(5)) 
	If !FQL->(dbSeek(xfilial("FQL")+FQK->FQK_COD+FQK->FQK_MEDSEQ))
		MsgAlert(STR0039, STR0002) //"Inconsistência nos dados."###"Não foi localizado os itens da medição."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIF

	// VALIDAÇÃO PARA NÃO PERMITIR A GERAÇÃO DO PV NO CASO DO VALOR ESTAR ZERADO
	If FQK->FQK_VLRTOT == 0 .or. (FQK->FQK_VLMAQ + FQK->FQK_VLTOTM) == 0
		MsgAlert(STR0033,STR0002) //"Inconsistência nos dados."###"O valor total está zerado."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	If empty(cProdMo) .or. empty(cProdMa)
		MsgAlert(STR0092,STR0002) //"Inconsistência nos dados."###"Falta o preenchimento dos parâmetros MV_LOCX063 e MV_LOCX064."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIF

	If empty(cTesMaq) .or. empty(cTesMao)
		MsgAlert(STR0092,STR0002) //"Inconsistência nos dados."###"Falta de preenchimento da TES no cabeçalho da medição."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	IF MsgBox(STR0037 + FQK->FQK_CLIFAT+"/"+FQK->FQK_LOJFAT+"-"+posicione("SA1",1,xFilial("SA1")+FQK->FQK_CLIFAT+FQK->FQK_LOJFAT,"A1_NOME"),STR0038,"YESNO") //"Deseja gerar faturamento para este serviço: Cliente ->"###"Atenção"

		FP0->(dbSetOrder(1))
		FP0->(dbSeek(xFilial("FP0")+FQK->FQK_PROJET))

		SA3->(DBSETORDER(1))
		SA3->(dbSeek(xFilial("SA3")+FP0->FP0_VENDED))

		cVendedor := SA3->A3_COD
		nComissao := SA3->A3_COMIS

		If empty( aCamposSC5 )
			aadd(aCamposSC5,{"C5_TIPO"	  , "N"	    			, NIL })
			aadd(aCamposSC5,{"C5_CLIENTE" , FQK->FQK_CLIFAT     , NIL })
			aadd(aCamposSC5,{"C5_LOJACLI" , FQK->FQK_LOJFAT     , NIL })
			aadd(aCamposSC5,{"C5_TIPOCLI" , POSICIONE("SA1",1,XFILIAL("SA1") + FQK->FQK_CLIFAT + FQK->FQK_LOJFAT ,"A1_TIPO")	, NIL })
			aadd(aCamposSC5,{"C5_TPCARGA" , "1"	                , NIL })
			aadd(aCamposSC5,{"C5_CONDPAG" , FQK->FQK_CONDPA     , NIL })
			aadd(aCamposSC5,{"C5_TPFRETE" , " "		            , NIL }) 
			aadd(aCamposSC5,{"C5_NATUREZ" , FQK->FQK_NATUR      , NIL })
			aadd(aCamposSC5,{"C5_VEND1"   , CVENDEDOR           , NIL })
			aadd(aCamposSC5,{"C5_COMIS1"  , NCOMISSAO           , NIL })
			aadd(aCamposSC5,{"C5_ORIGEM"  , "LOCA248"           , NIL })
			aadd(aCamposSC5,{"C5_MOEDA"   , FP0->FP0_MOEDA      , NIL })

			//If SC5->( FIELDPOS("C5_CLVL") ) > 0
			//	AADD( aCamposSC5, {"C5_CLVL" , FQK->FQK_PROJET , NIL } )
			//EndIf

			aFPY := {}
			Aadd(aFPY, {"FPY_FILIAL", xFilial("SC5")	, NIL })
			Aadd(aFPY, {"FPY_PEDVEN", ""				, NIL })
			Aadd(aFPY, {"FPY_PROJET", FQK->FQK_PROJET	, NIL })
			Aadd(aFPY, {"FPY_TIPFAT", "M"				, NIL })
			Aadd(aFPY, {"FPY_STATUS", "1"				, NIL })

		EndIf

		FQL->(dbSetOrder(5))
		FQL->(dbSeek(xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)))

		aItensMed := {}
		aItemFPZ := {}
		aFPZ := {}
		nItemFPZ := 0
		While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_COD+FQL_ORDEM) == xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)
			nItemFPZ  ++
			aadd(aItensMed,{FQL->(Recno())})

			If FQL->FQL_VLMAQ > 0
				aadd(aAsMaq,{FQL->FQL_AS, FQL->FQL_VLRTOT, FQL->FQL_VLMAQ, cProdMa})
			EndIf

			If FQL->FQL_VLTOTM > 0
				aadd(aAsMao,{FQL->FQL_AS, FQL->FQL_VLRTOT, FQL->FQL_VLTOTM, cProdMo})
			EndIf

			FPA->(dbSetOrder(3))
			FPA->(dbSeek(xFilial("FPA")+FQL->FQL_AS))

			FP1->(dbSetOrder(1))
			FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA) )
			do case
				case FPA->FPA_TPBASE == "M"
					nDiasTRB := 30
				case FPA->FPA_TPBASE == "Q"
					nDiasTRB := 15
				case FPA->FPA_TPBASE == "S"
					nDiasTRB :=  7
				otherwise
					do case
						case FPA->( FIELDPOS("FPA_LOCDIA") ) > 0
							nDiasTRB := FPA->FPA_LOCDIA
						case FPA->( FIELDPOS("FPA_PREDIA") ) > 0
							nDiasTRB := FPA->FPA_PREDIA
						otherwise
							nDiasTRB := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1
					endcase
			endcase

			dDtIni := FQK->FQK_DTINIC
			dDtFim := FQK->FQK_DTFIM

			If !empty(FQL->FQL_DTSAID)
				dDtIni := FQL->FQL_DTSAID
			EndIf
			If !empty(FQL->FQL_DTENT)
				dDtFim := FQL->FQL_DTENT
			EndIf
			
			cPerLoc := dtoc(dDtIni) + " A " + dtoc(dDtFim)

			// Criar a linha do valor de máquina
			If FQL->FQL_VLMAQ > 0
				aItemFPZ := {}
				Aadd(aItemFPZ, {"FPZ_FILIAL" , xFilial("SC6")  , NIL })
				Aadd(aItemFPZ, {"FPZ_PEDVEN" , ""			   , NIL }) 
				Aadd(aItemFPZ, {"FPZ_DTPED"	 , dDataBase	   , NIL })
				Aadd(aItemFPZ, {"FPZ_DTINI"	 , dDtIni, NIL })
				Aadd(aItemFPZ, {"FPZ_PROJET" , FQK->FQK_PROJET , NIL })
				Aadd(aItemFPZ, {"FPZ_PRVFAT" , FPA->FPA_ULTFAT , NIL })
				Aadd(aItemFPZ, {"FPZ_ITEM"   , StrZero(1, TAMSX3("FPZ_ITEM")[1],0),	NIL })
				Aadd(aItemFPZ, {"FPZ_AS"	 , FQL->FQL_AS	   , NIL })
				Aadd(aItemFPZ, {"FPZ_EXTRA"	 , "N"			   , NIL })
				Aadd(aItemFPZ, {"FPZ_FROTA"	 , FQL->FQL_FROTA  , NIL })
				Aadd(aItemFPZ, {"FPZ_PERLOC" , cPerLoc		   , NIL })
				Aadd(aItemFPZ, {"FPZ_CCUSTO" , FQL->FQL_CCUSTO , NIL })
				if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
					Aadd(aItemFPZ, {"FPZ_ITMFPZ" , StrZero(nItemFPZ , TAMSX3("FPZ_ITMFPZ")[1],0), NIL })
					Aadd(aItemFPZ, {"FPZ_QUANT"	 , 1,	NIL })
					Aadd(aItemFPZ, {"FPZ_VALUNI" , FQL->FQL_VLMAQ,	NIL })
					Aadd(aItemFPZ, {"FPZ_PROD"   , FQL->FQL_PROD,	NIL })
					Aadd(aItemFPZ, {"FPZ_VIAGEM" , FPA->FPA_VIAGEM,	NIL })
					Aadd(aItemFPZ, {"FPZ_DIAS"   , DDTFIM - DDTINI + 1,	NIL })
					Aadd(aItemFPZ, {"FPZ_TOTAL"	 , FQL->FQL_VLMAQ,	NIL })
					Aadd(aItemFPZ, {"FPZ_OBRA"	 , FPA->FPA_OBRA,	NIL })
					if lCVal
						Aadd(aItemFPZ, {"FPZ_CLVL" , FQL->FQL_AS,	NIL })
					endif
				endif
				if FPZ->(FIELDPOS("FPZ_MEDICA")) > 0
					Aadd(aItemFPZ, {"FPZ_MEDICA" , FQK->FQK_COD   ,	NIL })
				endif
				Aadd(aFPZ,Aclone(aItemFPZ))
			EndIF

			// Criar a linha do valor de mão de obra
			If FQL->FQL_VLTOTM
				aItemFPZ := {}
				Aadd(aItemFPZ, {"FPZ_FILIAL" , xFilial("SC6")  , NIL })
				Aadd(aItemFPZ, {"FPZ_PEDVEN" , ""			   , NIL })
				Aadd(aItemFPZ, {"FPZ_DTPED"	 , dDataBase	   , NIL })
				Aadd(aItemFPZ, {"FPZ_DTINI"	 , dDtIni, NIL })
				Aadd(aItemFPZ, {"FPZ_PROJET" , FQK->FQK_PROJET , NIL })
				Aadd(aItemFPZ, {"FPZ_PRVFAT" , FPA->FPA_ULTFAT , NIL })
				Aadd(aItemFPZ, {"FPZ_ITEM"   , StrZero(2, TAMSX3("FPZ_ITEM")[1],0),	NIL })
				Aadd(aItemFPZ, {"FPZ_AS"	 , FQL->FQL_AS	   , NIL })
				Aadd(aItemFPZ, {"FPZ_EXTRA"	 , "N"			   , NIL })
				Aadd(aItemFPZ, {"FPZ_FROTA"	 , FQL->FQL_FROTA  , NIL })
				Aadd(aItemFPZ, {"FPZ_PERLOC" , cPerLoc		   , NIL })
				Aadd(aItemFPZ, {"FPZ_CCUSTO" , FQL->FQL_CCUSTO , NIL })
				if FPZ->(FIELDPOS("FPZ_ITMFPZ")) > 0
					Aadd(aItemFPZ, {"FPZ_ITMFPZ" , StrZero(nItemFPZ , TAMSX3("FPZ_ITMFPZ")[1],0), NIL })
					Aadd(aItemFPZ, {"FPZ_QUANT"	 , 1,	NIL })
					Aadd(aItemFPZ, {"FPZ_VALUNI" , FQL->FQL_VLTOTM,	NIL })
					Aadd(aItemFPZ, {"FPZ_PROD"   , FQL->FQL_PROD,	NIL })
					Aadd(aItemFPZ, {"FPZ_VIAGEM" , FPA->FPA_VIAGEM,	NIL })
					Aadd(aItemFPZ, {"FPZ_DIAS"   , DDTFIM - DDTINI + 1,	NIL })
					Aadd(aItemFPZ, {"FPZ_TOTAL"	 , FQL->FQL_VLTOTM,	NIL }) 
					Aadd(aItemFPZ, {"FPZ_OBRA"	 , FPA->FPA_OBRA,	NIL })
					if lCVal
						Aadd(aItemFPZ, {"FPZ_CLVL" , FQL->FQL_AS,	NIL })
					endif
				endif
				if FPZ->(FIELDPOS("FPZ_MEDICA")) > 0
					Aadd(aItemFPZ, {"FPZ_MEDICA" , FQK->FQK_COD   ,	NIL })
				endif
				Aadd(aFPZ,Aclone(aItemFPZ))
			EndIf

			// Tratamento para geração do custo extra
			lTem := .F.
			For nX := 1 to len(aAs)
				If aAs[nX,1] == FQL->FQL_AS
					lTem := .T.
					Exit
				EndIf
			Next
			If !lTem
				aadd(aAs,{FQL->FQL_AS})
			EndIf

			FQL->(dbSkip())
		EndDo

		IncProc()
		SysRefresh()

		aItens := {}
		cItem := replicate("0",TamSx3("C6_ITEM")[1])

		aAgluRat := {}
		aAuxRat := {}

		// Item correspondente ao valor da máquina
		If FQK->FQK_VLMAQ > 0

			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProdMa))
				cItem := Soma1(cItem)
				aItens := {}
				aadd(aItens, {"C6_FILIAL" , xFilial("SC6") , NIL} )
				aadd(aItens, {"C6_ITEM"	  , cItem    	   , NIL} )
				aadd(aItens, {"C6_PRODUTO", cProdMa		   , NIL} )
				aadd(aItens, {"C6_QTDVEN" , 1			   , NIL} )
				aadd(aItens, {"C6_PRCVEN" , FQK->FQK_VLMAQ , NIL} )
				aadd(aItens, {"C6_VALOR"  , FQK->FQK_VLMAQ , NIL} )
				aadd(aItens, {"C6_TES"	  , cTesMaq   	   , NIL} )
				aadd(aItens, {"C6_LOCAL"  , SB1->B1_LOCPAD , NIL} )
				aadd(aItens, {"C6_ENTREG" , dDataBase	   , NIL} )
				aadd(aItens, {"C6_QTDLIB" , 1			   , NIL} )

				aadd(aCamposSC6,aItens)

				If lCVal
					nTemp := 0
					For nX := 1 to len(aAsMaq)
						If aAsMaq[nX,3] > 0 .and. aAsMaq[nX,4] == cProdMa // Rateio por AS e que tenha o valor de máquina
							nTemp += aAsMaq[nX,3]
						EndIf
					Next
					nItem := 0

					aAuxRat := {}
					For nX := 1 to len(aAsMaq)
						If aAsMaq[nX,3] > 0 .and. aAsMaq[nX,4] == cProdMa // Rateio por AS e que tenha o valor de máquina
							aItemAGG := {}
							nItem ++
							Aadd(aItemAGG, {"AGG_FILIAL"	, xFilial("AGG")	, NIL})
							aAdd(aItemAGG, {"AGG_FORNECE"	, FQK->FQK_CLIFAT	, Nil})
							aAdd(aItemAGG, {"AGG_LOJA"		, FQK->FQK_LOJFAT	, Nil})
							aAdd(aItemAGG, {"AGG_ITEMPD"	, cItem				, Nil})
							aAdd(aItemAGG, {"AGG_ITEM"		, strzero(nItem, tamsx3("AGG_ITEM")[1] ,0), Nil})
							Aadd(aItemAGG, {"AGG_PERC"		, (aAsMaq[nX,3]/nTemp)*100, NIL})
							Aadd(aItemAGG, {"AGG_CC"		, ""				, NIL})
							Aadd(aItemAGG, {"AGG_CLVL"		, aAsMaq[nX,1]	  	, NIL})
							Aadd(aItemAGG, {"AGG_CONTA"		, ""				, NIL})
							Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				, NIL})
							//Aadd(aAgluRat, { cItem, {aClone(aItemAGG)} })
							aAdd(aAuxRat, aItemAGG)
						EndIf
					Next
					aadd(aAgluRat, {StrZero(1,2), aAuxRat})
				EndIf

			EndIf
		EndIf

		IncProc()
		SysRefresh()

		// Item correspondente ao valor da mão de obra
		If FQK->FQK_VLTOTM > 0
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProdMo))
				aItens := {}
				cItem := Soma1(cItem)
				aadd(aItens, {"C6_FILIAL" , xFilial("SC6") , NIL} )
				aadd(aItens, {"C6_ITEM"	  , cItem          , NIL} )
				aadd(aItens, {"C6_PRODUTO", cProdMo		   , NIL} )
				aadd(aItens, {"C6_QTDVEN" , 1			   , NIL} )
				aadd(aItens, {"C6_PRCVEN" , FQK->FQK_VLTOTM, NIL} )
				aadd(aItens, {"C6_VALOR"  , FQK->FQK_VLTOTM, NIL} )
				aadd(aItens, {"C6_TES"	  , cTesMao		   , NIL} )
				aadd(aItens, {"C6_LOCAL"  , SB1->B1_LOCPAD , NIL} )
				aadd(aItens, {"C6_ENTREG" , dDataBase	   , NIL} )
				aadd(aItens, {"C6_QTDLIB" , 1			   , NIL} )

				aadd(aCamposSC6,aItens)

				If lCVal
					nTemp := 0
					For nX := 1 to len(aAsMao)
						If aAsMao[nX,3] > 0 .and. aAsMao[nX,4] == cProdMo // Rateio por AS e que tenha o valor de máquina
							nTemp += aAsMao[nX,3]
						EndIf
					Next
					nItem := 0
					aAuxRat := {}
					For nX := 1 to len(aAsMao)
						If aAsMao[nX,3] > 0 .and. aAsMao[nX,4] == cProdMo  // Rateio por AS e que tenha o valor de mão de obra
							nItem ++
							aItemAGG := {}
							Aadd(aItemAGG, {"AGG_FILIAL"	, xFilial("AGG")	, NIL})
							aAdd(aItemAGG, {"AGG_FORNECE"	, FQK->FQK_CLIFAT	, Nil})
							aAdd(aItemAGG, {"AGG_LOJA"		, FQK->FQK_LOJFAT	, Nil})
							aAdd(aItemAGG, {"AGG_ITEMPD"	, cItem				, Nil})
							aAdd(aItemAGG, {"AGG_ITEM"		, strzero(nItem, tamsx3("AGG_ITEM")[1] ,0), Nil})
							Aadd(aItemAGG, {"AGG_PERC"		, (aAsMao[nX,3]/nTemp)*100, NIL})
							Aadd(aItemAGG, {"AGG_CC"		, ""				, NIL})
							Aadd(aItemAGG, {"AGG_CLVL"		, aAsMao[nX,1]	  		, NIL})
							Aadd(aItemAGG, {"AGG_CONTA"		, ""				, NIL})
							Aadd(aItemAGG, {"AGG_ITEMCT"	, ""				, NIL})
							//Aadd(aAgluRat, { cItem, {aClone(aItemAGG)} })
							aAdd(aAuxRat, aItemAGG)
						EndIf
					Next
					aadd(aAgluRat, {StrZero(2,2), aAuxRat})
				EndIf

			EndIf
		EndIf

		IncProc()
		SysRefresh()

		If len(aCamposSC5) > 0 .AND. len(aCamposSC6) > 0

			If l248CB
				aRet := ExecBlock("LOC248CB" , .T. , .T. , {aCamposSC5, aCamposSC6, aAGlurat, lCVal })
				aCamposSC5 	:= aRet[1]
				aCamposSC6 	:= aRet[2]
				aAGlurat	:= aRet[3]
			EndIf

			If !lCVal
				FWMSGRUN(,{|| MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)},aCamposSC5,aCamposSC6,3)},,STR0047 ) //"Aguarde...Gerando o pedido de vendas da medição"
			Else
				//FWMSGRUN(,{|| MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)},aCamposSC5,aCamposSC6,3, aAGlurat)},,STR0047 ) //"Aguarde...Gerando o pedido de vendas da medição"
				FWMSGRUN(,{|| MSExecAuto({|a, b, c, d, e, f| MATA410(a, b, c, d, , , , e, )},aCamposSC5,aCamposSC6,3, .f., aAGlurat)},,STR0047 ) //"Aguarde...Gerando o pedido de vendas da medição"
			EndIF

			IncProc()
			SysRefresh()

			If LMSERROAUTO
				mostraErro()
				RollBackSX8()
			Else
				ConfirmSX8()

				If len(aFPY) > 0
					afpy[2][2] := SC5->C5_NUM
				EndIf
				If len(aFPZ) > 0
					For nX := 1 to len(aFPZ)
						aFPZ[nX,2,2] := SC5->C5_NUM
					Next
				EndIf

				LOCA0822(aFPY,aFPZ,Nil)

				FQK->(RecLock("FQK",.F.))
				FQK->FQK_FILPV	:= cFilAnt
				FQK->FQK_NUMPV  := SC5->C5_NUM
				FQK->FQK_SITUAC := "4"
				FQK->(MsUnlock())

				cQuery := "SELECT FPF_FILIAL, FPF_MINUTA "
				cQuery += " FROM " + RetSqlName("FPF") + " FPF " 
				cQuery += " WHERE FPF.FPF_FILIAL = '" + xFilial("FPF") + "' "
 			    cQuery += " AND FPF.FPF_STATUS = '6'  "
 			    cQuery += " AND FPF.D_E_L_E_T_ = ' ' "
 			    cQuery += " AND FPF.FPF_NROMED = ? "
			    cQuery += " AND FPF.FPF_MEDSEQ = ? "

			    aadd( aParam, FQK->FQK_COD)
		    	aadd( aParam, FQK->FQK_MEDSEQ)

				cQuery := ChangeQuery(cQuery)
				MPSysOpenQuery(cQuery,cAliasT,,,aParam)

				(cAliasT)->(DbGoTop())
				While !(cAliasT)->(Eof())
					FPF->(DbSetOrder(2))
					FPF->(DbSeek((cAliasT)->FPF_FILIAL+(cAliasT)->FPF_MINUTA))
					FPF->(RecLock("FPF",.F.))
					FPF->FPF_STATUS 	 	:= "4"
					FPF->(MsUnlock())
					(cAliasT)->(DbSkip())
				End			

				If Select(cAliasT) > 0
					(cAliasT)->(DbCloseArea())
				EndIf

				aAsProv := {}
				For nX := 1 to Len(aItensMed)
					FQL->(dbGoto(aItensMed[nX,1]))
					aadd(aAsProv,FQL->FQL_AS)
					FQ5->(dbSetOrder(9))
					If FQ5->(dbSeek(xFilial("FQ5")+FQL->FQL_AS))
						FQ5->(RecLock("FQ5",.F.))
						FQ5->FQ5_ZLFTIP := "3"
						FQ5->FQ5_NUMPV  := SC5->C5_NUM
						FQ5->(MsUnlock())
					EndIf
				Next

				aadd(aPedido,{SC5->C5_NUM})

				// Tratamento para geração do custo extra
				aadd(aExecAuto,.T.)
				aadd(aExecAuto,aRetExec)
				aadd(aExecAuto,"      ")
				aadd(aExecAuto,"  ")
				aadd(aExecAuto,"ZZZZZZ")
				aadd(aExecAuto,"ZZ")
				aadd(aExecAuto,"                ")
				aadd(aExecAuto,"ZZZZZZZZZZZZZZZZ")
				aadd(aExecAuto,"                              ")
				aadd(aExecAuto,"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
				aadd(aExecAuto,"   ")
				aadd(aExecAuto,"ZZZ")
				aadd(aExecAuto,ctod("01/01/1900"))
				aadd(aExecAuto,FQK->FQK_DTFIM)
				aadd(aExecAuto,2)
				aadd(aExecAuto,ctod(""))
				aadd(aExecAuto,ctod(""))

				MSEXECAUTO({|A,B,C,D,E,F,G| LOCA021(A,B,C,D,E,F,G)},;
				Nil , FQK->FQK_PROJET , FQK->FQK_PROJET, aAs, .T. , 2 , aExecAuto)

				If len(aRetExec) > 0
					aadd(aPedido,{aRetExec[1][1]})
				EndIf

				cPedido := ""
				For nX := 1 to len(aPedido)
					If !empty(cPedido)
						cPedido += ", "
					EndIf
					cPedido += alltrim(aPedido[nX,1])
				Next

				If len(aAsProv) > 0
					FPA->(dbSetOrder(3))
					If FPA->(dbSeek(xFilial("FPA")+aAsProv[1]))
						FP0->(dbSetOrder(1))
						If FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))
							If _MV_LOC278 .and. FindFunction( "LOCA248AP" )
								LOCA248AP(.T., .F., FQK->FQK_MEDSEQ, .T.)
							EndIf
						EndIF
					EndIf
				EndIf

				MsgInfo(STR0051+alltrim(cPedido), STR0038) //"Pedido(s) gerado(s): "###"Atenção"
			EndIf

		EndIf

	EndIf

	IncProc()
	SysRefresh()

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))

Return

/*/{PROTHEUS.DOC} LOCA24817
ITUP BUSINESS - TOTVS RENTAL
Estornar o PV via medição
Frank Z Fuga em 31/07/2024
/*/
Function LOCA24817
	Processa({|| xRet := LOCA24817C()},STR0148) // Gerando o pedido de vendas
Return

/*/{PROTHEUS.DOC} LOCA24817
ITUP BUSINESS - TOTVS RENTAL
Estornar o PV via medição
Frank Z Fuga em 31/07/2024
/*/
Function LOCA24817C
Local aCabPV := {}
Local aItemSC6 := {}
Local aItemPV := {}
Local cFilBKP := cFilAnt
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local _MV_LOC278 := SuperGetMV("MV_LOCX278",.F.,.F.)
Local cAs := "" // geracao dos titulos provisorios

Private LMSERROAUTO := .F.

	ProcRegua(4)

	SC5->(dbSetOrder(1))

	If !empty(FQK->FQK_NUMPV) .and. !empty(FQK->FQK_FILPV) .and. FQK->FQK_SITUAC == "4"
		If SC5->(MsSeek(FQK->FQK_FILPV+FQK->FQK_NUMPV))
			If empty(SC5->C5_NOTA)
				BEGINTRAN()

				SC5->(RecLock("SC5",.F.))
				SC5->C5_LIBEROK := ""
				SC5->(MsUnlock())

				aCabPV := RETARRAUTO("SC5")

				aItemSC6 := {}
				aItemPV	 := {}
				cCodMed	 := ""

				SC6->(dbSetOrder(1))
				SC6->(MsSeek(SC5->C5_FILIAL+SC5->C5_NUM))

				While !eof() .and. SC6->C6_FILIAL == SC5->C5_FILIAL .and. SC6->C6_NUM == SC5->C5_NUM
					SC6->(RecLock("SC6",.F.))
					SC6->C6_QTDLIB := 0
					SC6->C6_QTDEMP := 0
					SC6->(MsUnlock())

					SC9->(dbSetOrder(1))
					If SC9->(MsSeek(SC6->C6_FILIAL+SC6->C6_NUM+SC6->C6_ITEM))
						SC9->(RecLock("SC9", .F.))
						SC9->C9_QTDLIB := 0
						SC9->(MsUnlock())
					EndIf

					aItemSC6 := RETARRAUTO("SC6")

					aadd(aItemPV,aClone(aItemSC6))

					aItemSC6 := {}
					SC6->(dbSkip())
				EndDo

				IncProc()
				SysRefresh()

				If len(aCabPV) > 0 .and. len(aItemPV) > 0

					cFilAnt := SC5->C5_FILIAL

					MsExecAuto({|X,Y,Z|MATA410(X,Y,Z)}, aCabPV, aItemPV, 5)

					IncProc()
					SysRefresh()

					If LMSERROAUTO
						MostraErro()
						DisarmTransaction()
					Else
						FQK->(RecLock("FQK",.F.))
						FQK->FQK_FILPV  := ""
						FQK->FQK_NUMPV  := ""
						FQK->FQK_SITUAC := "1"
						FQK->(MsUnlock())

						FQL->(dbSetOrder(5))
						FQL->(dbSeek(xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)))

						FQ5->(dbSetOrder(9))
						While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_COD+FQL_ORDEM) == xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)

							If empty(cAs) // geração dos titulos provisorios
								cAs := FQL->FQL_AS
							EndIf

							FQ5->(dbSeek(xFilial("FQ5")+FQL->FQL_AS))
							FQ5->(RecLock("FQ5",.F.))
							FQ5->FQ5_ZLFTIP := ""
							FQ5->FQ5_NUMPV  := ""
							FQ5->(MsUnlock())
							FQL->(dbSkip())
						EndDo

					EndIf
				EndIf

				IncProc()
				SysRefresh()

				// titulos provisorios nova geracao
				If _MV_LOC278 .and. FindFunction( "LOCA248AP" )
					LOCA248AP(.F., .T.)
				EndIf

				EndTran()

				MsUnlockAll()

			Else
				Help( ,, "LOCA248-LOCA24817",, STR0002, 1, 0,,,,,,{STR0054}) //"Inconsistência nos dados."###"Pedido de vendas já faturado"
			EndIf
		Else
			Help( ,, "LOCA248-LOCA24817",, STR0002, 1, 0,,,,,,{STR0055}) //"Inconsistência nos dados."###"Não foi possível encontrar o pedido de vendas desta medição"
		EndIf
	Else
		Help( ,, "LOCA248-LOCA24817",, STR0002, 1, 0,,,,,,{STR0056}) //"Inconsistência nos dados."###"Esta medição não possui pedido de vendas"
	EndIf

	cFilAnt := cFilBKP

	IncProc()
	SysRefresh()

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))

Return

/*/{PROTHEUS.DOC} RETARRAUTO
ITUP BUSINESS - TOTVS RENTAL
Retorna as informações do SX3
Frank Z Fuga em 31/07/2024
/*/
Static Function RETARRAUTO(cAlias)
Local aArea := GetArea()
Local aAuto := {}
Local nX
Local aFields

	aFields := FWSX3Util():GetListFieldsStruct( cAlias , .F.)
	For nX := 1 To Len( aFields )
		cCampo := GetSx3Cache(alltrim(aFields[nX][01]),"X3_CAMPO")
		cVirtual := GetSx3Cache(alltrim(aFields[nX][01]),"X3_CONTEXT")
		If (x3Uso(GetSx3Cache(alltrim(aFields[nX][01]),"X3_USADO")) .and. cVirtual <> "V") .or. PREFIXOCPO(cAlias)+"_FILIAL" == ALLTRIM(cCampo)
			aadd(aAuto, { alltrim(cCampo), (cAlias)->&(alltrim(cCampo)), NIL} )
		EndIf
	Next nX

	RestArea(aArea)

Return(aAuto)

/*/{Protheus.doc} LOCA248MO
Gera os registros de mão de obra
Frank Z Fuga
08/11/24
/*/
Function LOCA248MO()
	Processa({|| LOCA248MO2()},STR0134) // "Aguarde... localizando os registros de mão de obra"
Return .T.

/*/{Protheus.doc} LOCA248MO2
Gera os registros de mão de obra
Frank Z Fuga
08/11/24
/*/
Function LOCA248MO2()
Local aAreaFPA
Local lTem
Local lExist
Local nPonteiro
Local nI 
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local lEdita
//Local cGrupo
Local oView := FWViewActive() 
Local nTotReg := 0
Local nAtuReg := 0

Private cNatureza

	ProcRegua(0)

	If M->FQK_TPMED == "G"

		// Geração dos itens para locações

		FPA->(dbSetOrder(1))
		FPA->(dbSeek(xFilial("FPA")+M->FQK_PROJET))
		While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET) == xFilial("FPA")+M->FQK_PROJET
			nTotReg ++
			FPA->(dbSkip())
		EndDo

		ProcRegua(nTotReg)

		FPA->(dbSetOrder(1))
		FPA->(dbSeek(xFilial("FPA")+M->FQK_PROJET))
		While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET) == xFilial("FPA")+M->FQK_PROJET

			nAtureg ++

			IncProc(STR0145+alltrim(str(nAtuReg))+STR0146+alltrim(str(nTotReg))) //"Processo: "###" de: "
			SysRefresh()
			aAreaFPA := FPA->(GetArea()) // Circenis alguma função troca o indice da FPA 
			
			// Medição somente para AS gerada
			If empty(FPA->FPA_AS)
				FPA->(dbSkip())
				Loop
			EndIf

			If FPA->FPA_TIPOSE <> "M"
				FPA->(dbSkip())
				Loop
			EndIF

			// A AS precisar estar aprovada
			FQ5->(dbSetOrder(9))
			FQ5->(dbSeek(xFilial("FQ5")+FPA->FPA_AS))
			If FQ5->FQ5_STATUS <> "6"
				FPA->(dbSkip())
				Loop
			EndIf

			// Verificar se esta AS foi usada em alguma medicao ativa do tipo AS
			lTem := .F.
			FQK->(dbSetOrder(2))
			FQK->(dbSeek(xFilial("FQK")+FPA->FPA_AS))
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+M->FQK_AS
				If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6"
					lTem := .T.
					exit
				EndIf
				FQK->(dbSkip())  
			EndDo
			If lTem
				FPA->(dbSkip())
				Loop
			EndIf

			If empty(cNatureza)
				cNatureza := FPA->FPA_NATURE
			EndIf

			// Verificar se o item já existe no grid
			lExist := .F.
			/*nPonteiro := oModelFQL:GetLine()
			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
			Next
			oModelFQL:GoLine(nPonteiro)*/

			If !lExist 
				lEdita := .F.
				nPonteiro := oModelFQL:GetLine()
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_AS"))
						lEdita := .T.
						Exit
					EndIF
				Next
				oModelFQL:GoLine(nPonteiro)
				
				If LOCA248C4() // valida se o movimento pode popular a grid
					If lEdita 
						LOCA248AG(nI,"G", "M")
					Else
						oModelFQL:AddLine()
						LOCA248AG(nI,"G", "M")
					EndIf
				EndIf

				// Atualizar com os turnos
				FPE->(dbSetOrder(1))
				FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA)))
				While !FPE->(Eof()) .and. FPE->(FPE_FILIAL+FPE_PROJET+FPE_OBRA) == xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA)
					If FPE->FPE_SEQGUI == FPA->FPA_SEQGRU
						oModelFQL:AddLine()
						LOCA248AG(oModelFQL:Length(),"G", "T")
					EndIF
					FPE->(dbSkip())
				EndDo

			EndIf
			RestArea(aAreaFPA)// Circenis retorno ao estado anterior para fazer o laço corretamente 
			
			FPA->(dbSkip())
		EndDo

		oModelFQL:GoLine(1)
		oView:Refresh()

	Else // M->FQK_TPMED == "A"

		// Verificar se esta AS foi usada em alguma medicao ativa do tipo grupo
		lTem := .F.
		FQK->(dbSetOrder(2))
		FQK->(dbSeek(xFilial("FQK")+M->FQK_AS))
		While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+M->FQK_AS
			IncProc()
			If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6"
				lTem := .T.
				exit
			EndIf
			FQK->(dbSkip())
		EndDo
		If lTem
			Help( ,, "LOCA248-LOCA248H",, STR0002, 1, 0,,,,,,{STR0064}) //"Inconsistência nos dados."###"Conflito entre movimentos de Grupo x AS"
			Return .F.
		EndIf  

		FPA->(dbSetOrder(3))
		If FPA->(dbSeek(xFilial("FPA")+M->FQK_AS))
			IncProc()
			// A AS precisar estar aprovada
			FQ5->(dbSetOrder(9))
			FQ5->(dbSeek(xFilial("FQ5")+FPA->FPA_AS))
			If FQ5->FQ5_STATUS == "6" .and. FPA->FPA_TIPOSE == "M"
				If empty(cNatureza)
					cNatureza := FPA->FPA_NATURE
				EndIf

				// Verificar se o item já existe no grid
				lExist := .F.
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If oModelFQL:GetValue("FQL_AS") == M->FQK_AS .and. !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
						lExist := .T.
					EndIF
				Next

				If !lExist
					lEdita := .F.
					For nI := 1 to oModelFQL:Length()
						oModelFQL:GoLine(nI)
						If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_AS"))
							lEdita := .T.
							Exit
						EndIF
					Next

					If LOCA248C4() // valida se o movimento pode popular a grid
						If lEdita
							LOCA248AG(nI,"A","M")
						Else
							oModelFQL:AddLine()
							LOCA248AG(nI,"A","M")
						EndIf

						// Atualizar com os turnos
						FPE->(dbSetOrder(1))
						FPE->(dbSeek(xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA)))
						While !FPE->(Eof()) .and. FPE->(FPE_FILIAL+FPE_PROJET+FPE_OBRA) == xFilial("FPE")+FPA->(FPA_PROJET+FPA_OBRA)
							If FPE->FPE_SEQGUI == FPA->FPA_SEQGRU
								oModelFQL:AddLine()
								LOCA248AG(oModelFQL:Length(),"G", "T")
							EndIF
							FPE->(dbSkip())
						EndDo

					EndIf

				EndIf

			EndIf
		EndIf

	EndIf


Return .T.
