#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATXDEF.CH"


STATIC lA103Rat :=  fisFindFunc("A103GRatIr")
STATIC lDedSimpAt := .F.
STATIC nItRetDel := 0

/*
MaFisIR -Alexandre Lemes -06/11/2012
Calculo do IR pessoa Fisica e Juridica
*/
Function FISXIR(aNfCab, aNFItem, nItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, cExecuta, lIRRFSemDu,dVencReal,lVisual,aUltPesq,lReproc,aCodR,nPosCodR)

Local aIRprg    := {}
Local cPessoa	:= Iif(Len(Alltrim(aNfCab[NF_CNPJ]))< 14,"F","J")
Local cWhere    := ""
Local cCliFor   := aNfCab[NF_CODCLIFOR]
Local cLoja     := aNfCab[NF_LOJA]
Local nAliquota	:= aNfCab[NF_ALIQIR]
Local nSomaIRF  := 0
Local nX        := 0
Local nDebDep   := 0
Local nSldDep   := 0
Local lUsaTbPrg := .F.
Local lVldBseIR := .T.
Local lCtrAuto  := fisGetParam('MV_CTRAUTO',.f.) .And. aNfCab[NF_TIPONF] == "C" .And. aNfCab[NF_TPCOMP] == "F" .And. !Empty(aNfCab[NF_NATUREZA])
Local lTribGen 	:= aNfCab[NF_CHKTRIBLEG] .AND. ChkTribLeg(aNFItem, nItem, TRIB_ID_IR)
Local nPosTgIR	:= 0
Local nVlDed	:= 0
Local afilial := xFisQryFIL()

DEFAULT dVencReal := dDataBase
DEFAULT cExecuta  := "BSE|ALQ|VLR"
DEFAULT lVisual	  := .F.
Default aCodR     := {}
Default nPosCodR  := 0

// verifico se é calculo pela tabela progressiva
if ( (aNfCab[NF_IRPROG] == "1" .or. cPessoa == "F") .and. !aNFCab[NF_TPCLIFOR] == "X" ) // APENAS PARA IRPF, TIPO X NAO DEVE ENTRAR 
	// se o calculo do IRRF não for na baixa do título verifico se está configurada a dedução simplificada
	if aNfCab[NF_MODIRF] <> "2"
		// se for calculo pela tabela progressiva, verifico se está configurada para
		// dedução simplificada
		if fisFindFunc("FVerMP1171")
			// função do financeiro que verifica o campo do fornecedor e os parâmetros
			// da dedução simplificada
			lDedSimpAt := FVerMP1171(cCliFor, cLoja)
		else
			lDedSimpAt := fisGetParam('MV_FMP1171',.F.)
		endif
	else
		lDedSimpAt := .F.
	endIf
endif


IF !lTribGen //Recebe cálculo do configurador

	//Define BASE do IRRF - IT_BASEIRR
	If "BSE" $ cExecuta

		aNfItem[nItem][IT_BASEIRR] := 0
		aNfItem[nItem][IT_BASIRORI] := 0

		If fisExtPE('MAFISBIR')
			lVldBseIR := ExecBlock( "MAFISBIR",.F.,.F.,{aNfItem[nItem,IT_TES],aNfItem[nItem,IT_PRODUTO],aNfCab[NF_CLIFOR],aNfCab[NF_OPERNF],aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA]})
		EndIf

		If lVldBseIR .And. (aNFItem[nItem][IT_TS][TS_DUPLIC] == "S" .Or. lIRRFSemDu) .And. !Empty(aInfNat[NT_CODIGO]) .And. ( aInfNat[NT_CALCIRF] == "S" .Or. fisGetParam('MV_IRSEMNT',.F.) )

			If aNfItem[nItem][IT_PRD][SB_IRRF] == "S" .Or. lCtrAuto .Or. (aNfCab[NF_OPIRRF] == "EP" .And. aNfCab[NF_RECIRRF] == "1" .And. !fisGetParam('MV_RETEMPU',.F.))
				//O parametro MV_CTRAUTO define se para notas fiscais de complemento de frete deve ser considerado as informacoes
				//de IRRF e INSS (calculo e reducao) da natureza ou do cad de produtos. .T.= Natureza - .F.= Produto (DEFAULT)
				//MV_RETEMPU Define a forma de calculo de retenção para empresas publicas, caso esteja = .T. passará a validar informações dos campos de retenção do cadastro de produtos e não mais do cadastro de clientes. 
				aNfItem[nItem][IT_REDIR] := aNfItem[nItem][IT_PRD][SB_REDIRRF]

				If (Empty(aNfItem[nItem][IT_REDIR]) .And. !Empty(aNfCab[NF_NATUREZA]))
					If aInfNat[NT_BASEIRF] > 0
						aNfItem[nItem][IT_REDIR] := aInfNat[NT_BASEIRF]
					ElseIf aInfNat[NT_IRRFCAR] == "S" .And. aInfNat[NT_BASEIRC] > 0
						aNfItem[nItem][IT_REDIR] := aInfNat[NT_BASEIRC]
					EndIf
				EndIf

				If lCtrAuto .Or. ( Empty(aNfItem[nItem][IT_REDIR]) .And. !Empty(aNfCab[NF_NATUREZA]) )
					aNfItem[nItem][IT_REDIR] := aInfNat[NT_BASEIRF]
				EndIf

				aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_TOTAL]

				If aNFItem[nItem][IT_TS][TS_DESCOND] == "1"	//Incluir o valor do desconto na base de IRRF
					aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_BASEIRR] +aNfItem[nItem][IT_DESCONTO]
				EndIf

				//Indica se o valor do IPI deve compor a base de calculo do PIS/COFINS de ST.
				//1=Sim (Compoe) e 2=Nao(Nao Compoe)
				If aNFItem[nItem][IT_TS][TS_IPIPC]=="2"
					aNfItem[nItem][IT_BASEIRR] -= aNfItem[nItem][IT_VALIPI]
				Endif

				//Verifica se o valor do ICMS Solidario esta agregado ao valor total
				If !(aNFItem[nItem][IT_TS][TS_INCSOL]$"A,N,D")
					aNfItem[nItem][IT_BASEIRR] -= aNfItem[nItem][IT_VALSOL]
				Endif

				//Agrega o Valor do ICMS Retido - Somente para Empresa Publica
				If aNFItem[nItem][IT_TS][TS_DBSTIRR] == "1" .And. (aNFCab[NF_OPIRRF] == "EP" .Or. (fisGetParam('MV_ISPPUBL',"") == "1" .And. aNfCab[NF_OPERNF] == "E"))
					aNfItem[nItem][IT_BASEIRR] += aNfItem[nItem][IT_VALSOL]
				Endif

				aNfItem[nItem][IT_BASEIRR] := aNfItem[nItem][IT_BASEIRR] * IIf( aNfItem[nItem][IT_REDIR] > 0 , aNfItem[nItem][IT_REDIR] / 100 , 1 )

				//guardo a base do item antes das deduções
				aNfItem[nItem][IT_BASIRORI] := aNfItem[nItem][IT_BASEIRR]

				if lDedSimpAt .and. !Empty(aNFItem[nItem][IT_TS][TS_CODIGO])
					if nSomaIRF == 0
						aEval(aNfItem,{|x| nSomaIRF += IIf(!x[IT_DELETED],x[IT_BASEIRR],0)})
					endif
					xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],Iif(lVisual,.F.,.T.),aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],dVencReal,cPessoa,aUltPesq,aCodR,nPosCodR)
					nVlDed := procDedSim(aNfCab, aNFitem, nItem,  fisGetParam('MV_TMSVDEP',0), aNFCab[NF_NUMDEP], fisGetParam('MV_FVL1171',528), aUltPesq)
					nSomaIRF := 0
				endif


				//O INSS devera ser deduzido da base do IR e nao do valor dos
				//servicos. Portanto, quando ha reducao na base de calculo, primeiro
				//efetua-se a reducao e depois a deducao do INSS.
				//Porém, pode ter sido configurada a dedução simplificada. Nestes casos
				//será considerada a dedução simplificada.

				// se está ativado dedução simplificada e deve aplicar
				if lDedSimpAt .and. (aNfItem[nItem][IT_APLIDEDS] .or. aNFCab[NF_ITDEDDIF] == nItem)
					nBsIrDed := nVlDed
				elseif ( fisGetParam('MV_INSIRF','2')=="1")
					nBsIrDed := aNfItem[nItem][IT_BASEIRR]-aNfItem[nItem][IT_VALINS]
				else 
					nBsIrDed := aNfItem[nItem][IT_BASEIRR]
				endif


				If (aNfCab[NF_IRPROG] == "1" .or. cPessoa == "F")
					aNfItem[nItem][IT_BASEIRR] := nBsIrDed
				Endif

				// Verificar se Fornecedor eh Pessoa Fisica
				// - Se Nao possui tratamento de base redutora IRPF
				// 	* Para este caso, nao calcular ou gravar o IRPF
				// - Se possui tratamento de base redutora IRPF
				// 	* Para este caso, nao zero a base de IRPF
				//Se nao possui tratamento de base redutora de IRRF

				// Chamado TQMMO9 - Comentado trecho abaixo para que a base do IR nao seja zerada quando o calculo for na baixa (aNfCab[NF_MODIRF] == "2").
				// Se a base for zerada neste ponto, o calculo da retenção na baixa do titulo no financeiro sera feito pelo valor total da nota/titulo
				// e se houver itens que não calculam IR na NF o valor sera calculado incorretamente, pois o valor destes itens nao deve compor a base.


				//Calculo da Base do IR com desconto de DEPENDENTES por item Chamado SCHLLN 29/12/2009
				If  aNfCab[NF_TPCLIFOR] == "F" .And. aNfItem[nItem][IT_BASEIRR] > 0 .And. cPessoa == "F"  .And. aNfCab[NF_NUMDEP] > 0 .And. fisExtCmp('12.1.2310', .T.,'SD1','D1_SLDDEP') .and. (!lDedSimpAt .or. (!aNfItem[nItem][IT_APLIDEDS] .and. aNFCab[NF_ITDEDDIF] <> nItem))

					dbSelectArea("SD1")
					nSldDep  := ( fisGetParam('MV_TMSVDEP',0) * aNfCab[NF_NUMDEP])

					cWhere := ""
					If fisGetParam('MV_ACMIRPF','1') == "2" //1 = Emissao 2= Vencimento Real 3=Data Contabilizacao
						cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND%"
					ElseIf fisGetParam('MV_ACMIRPF','1') == "1"
						cWhere += "%SE2.E2_EMISSAO  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND%"
					Else
						cWhere += "%SE2.E2_EMIS1  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND%"
					EndIf

					BeginSql Alias "MaTbDepPF"
						SELECT	SUM(D1_SLDDEP) SLDDEP
						FROM %Table:SE2% SE2,%Table:SF1% SF1,%Table:SD1% SD1
						WHERE
						%Exp:aFilial[1]%
						SE2.E2_FORNECE = %Exp:cCliFor% AND
						SE2.E2_LOJA    = %Exp:cLoja% AND
						%Exp:aFilial[4]%
						SE2.E2_PREFIXO = SF1.F1_PREFIXO AND
						SE2.E2_NUM     = SF1.F1_DOC AND
						SE2.E2_FORNECE = SF1.F1_FORNECE AND
						SE2.E2_LOJA    = SF1.F1_LOJA AND
						SE2.E2_EMISSAO = SF1.F1_EMISSAO AND
						SF1.F1_FILIAL  = SD1.D1_FILIAL AND
						SF1.F1_SERIE   = SD1.D1_SERIE AND
						SF1.F1_DOC     = SD1.D1_DOC AND
						SF1.F1_FORNECE = SD1.D1_FORNECE AND
						SF1.F1_LOJA    = SD1.D1_LOJA AND
						%exp:cWhere%
						SD1.D1_SLDDEP > 0  AND						
						%Exp:aFilial[2]%
						SE2.%notdel% AND
						SF1.%notdel% AND
						SD1.%notdel%
					EndSql

					dbSelectArea("MaTbDepPF")
					While !(MaTbDepPF->(Eof()))
						nDebDep  += SLDDEP
						MaTbDepPF->(dbSkip())
					EndDo
					MaTbDepPF->(dbCloseArea())
					If !lReproc
						If GdFieldPos("D1_SLDDEP") > 0  // Alemes refazer, retirar acols Chamado SCHLLN 29/12/2009
							nSldDep:=nSldDep-nDebDep
							aCols[nItem][GdFieldPos("D1_SLDDEP")]:= 0
							If aNfItem[nItem][IT_BASEIRR]>0
								For nX :=1 To Len(aCols)
									If !aCols[nX][Len(aCols[nX])]//Somente linhas nao deletadas
										nSldDep -= aCols[nX][GdFieldPos("D1_SLDDEP")]
									Endif
								Next nX
								If nSldDep > 0
									If aNfItem[nItem][IT_BASEIRR] > nSldDep
										aNfItem[nItem][IT_BASEIRR] -= nSldDep
										If GdFieldPos("D1_SLDDEP") > 0
											aCols[nItem][GdFieldPos("D1_SLDDEP")]:= nSldDep
										EndIf
									Else
										aCols[nItem][GdFieldPos("D1_SLDDEP")]:= aNfItem[nItem][IT_BASEIRR]
										aNfItem[nItem][IT_BASEIRR] := 0
									Endif
								Endif
							Endif
						EndIf
					else
						If nSldDep > 0
							If aNfItem[nItem][IT_BASEIRR] > nSldDep
								aNfItem[nItem][IT_BASEIRR] -= nSldDep
							Else
								aNfItem[nItem][IT_BASEIRR] := 0
							Endif
						Endif
					endif 
				Endif
			EndIf
		EndIf
	EndIf

	//Define ALIQUOTA IRRF - IT_ALIQIRR
	If "ALQ" $ cExecuta
		If !Empty(aNfCab[NF_NATUREZA]) .And. aNfCab[NF_MODIRF] <> "3"
			If aNfCab[NF_CLIFOR] == "C"
				Do Case
					Case aNfCab[NF_ALIQIR] > 0
						If fisGetParam('MV_IRSEMNT',.F.) // Parametro = .T. deixa gerar o IR mesmo que a natureza esteja para NAO calcular
							nAliquota := aNfCab[NF_ALIQIR]
						Else
							If aInfNat[NT_CALCIRF] == "S"
								nAliquota := aNfCab[NF_ALIQIR]
							EndIf
						EndIf
					Case aInfNat[NT_CALCIRF] == "S" .And. (Len(AllTrim(aNFCAB[NF_CNPJ])) == 14 .Or. aNfCab[NF_MODIRF] == "2" )
						nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , fisGetParam('MV_ALIQIRF',0) )
					Case aInfNat[NT_CALCIRF] == "S" .And. Len(AllTrim(aNFCAB[NF_CNPJ])) <> 14
						If aNfCab[NF_MODIRF] == "4" .Or. ( aNFCab[NF_TPCLIFOR] == "X" .And. aNFCab[NF_PESSOA] == "J" )   //aNfCab[NF_MODIRF] == "4" --> Empresa Individual
							nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , fisGetParam('MV_ALIQIRF',0) )
						Else
							lUsaTbPrg := .T.
						EndIf
				EndCase
			Else
				If aInfNat[NT_CALCIRF] == "S" .And. aNfItem[nItem][IT_BASEIRR] > 0
					If aNfCab[NF_MODIRF] <> "2" .And. !aNFCab[NF_TPCLIFOR] == "X" .And. cPessoa == "F"
						//--Empresa Individual OU para atender ao disposto no MAFON - 2016 - alíquotas que não fazem parte da tabela progressiva
						If aNfCab[NF_MODIRF] == "4" .OR. (cPessoa == "F" .And. aInfNat[NT_PERCIRF] > 0 .And. aNfCab[NF_IRPROG] == "2")
							nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , fisGetParam('MV_ALIQIRF',0) )
						Else
							lUsaTbPrg := .T.
						EndIf
					ElseIf aNfCab[NF_IRPROG] == "1" .And. cPessoa == "J"
						lUsaTbPrg := .T.
					Else
						// Verificar se Fornecedor utiliza MP232
						// Para este caso, nao calcular ou gravar o IRPF
						If fisExtCmp('12.1.2310', .T.,'SA2','A2_CALCIRF') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_VRETIRF') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_PRETIRF') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_VRETIRF') .And. ;
							fisExtCmp('12.1.2310', .T.,'SE5','E5_PRETIRF') .And. aNfCab[NF_MODIRF] == "2"
							nAliquota := 0
						Else
							nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , fisGetParam('MV_ALIQIRF',0) )
						EndIf
					EndIf
				EndIf
			EndIf		
			If lUsaTbPrg
				aEval(aNfItem,{|x| nSomaIRF += IIf(!x[IT_DELETED],x[IT_BASEIRR],0)})		
				aIRprg := xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],Iif(lVisual,.F.,.T.),aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],dVencReal,cPessoa,aUltPesq,aCodR,nPosCodR)
				nAliquota := aIRprg[2]
			EndIf

			// Verificar se Fornecedor pessoa juridica realiza calculo do IRR no momento da baixa.
			If aInfNat[NT_CALCIRF] == "S" .And. (cPessoa == "J" .OR. aNFCab[NF_TPCLIFOR] == "X") .And. aNfCab[NF_MODIRF] == "2"
				nAliquota := IIf( aInfNat[NT_PERCIRF] > 0 , aInfNat[NT_PERCIRF] , fisGetParam('MV_ALIQIRF',0) )
			EndIf
		EndIf

		aNfItem[nItem][IT_ALIQIRR]	:= nAliquota

	EndIf
	//Estou verificando novamente cExecuta, pois preciso da alíquota do IR pronta para que eu possa incluir na base de cálculo, ao invés de fazer uma chamada recursiva, adicionei este complemento da base de cálculo
	If "BSE" $ cExecuta .AND.  aNfItem[nItem][IT_BASEIRR] > 0 .AND. xFisGIR(nItem, aNFItem, aNfCab, "IRRF") //Verifica se deverá considerar GrossUp do IRRF
		//Esta opção significa que deverá incluir o valor do IR na base de cálculo
		aNfItem[nItem][IT_BASEIRR]	:= aNfItem[nItem][IT_VALMERC] / ( 1 - ( aNfItem[nItem][IT_ALIQIRR] / 100 ) )
	EndIF
	//Define VALOR do IRRF - IT_VALIRR
	If "VLR" $ cExecuta 

		aNfItem[nItem][IT_VALIRR] := 0

		If aNfItem[nItem][IT_ALIQIRR] <> 0 .And. aNfItem[nItem][IT_BASEIRR] > 0 .And. ( (cPessoa == "F" .And. aNfCab[NF_IRPROG] <> "2") .Or. aNfCab[NF_IRPROG] == "1" ) .And. ;
			(aNfCab[NF_CLIFOR] == "F" .Or. ( aNfCab[NF_CLIFOR] == "C" .And. aNfCab[NF_ALIQIR] == 0 ) .Or. aNfCab[NF_IRPROG] == "1" )
			lUsaTbPrg := .T.
		EndIf

		If (aNfCab[NF_CLIFOR] == "C" .And. aNFCab[NF_TPCLIFOR] == "X" .And. aNFCab[NF_PESSOA] == "J" ) .Or. ;
			(aNfCab[NF_CLIFOR] == "F" .And. aNfCab[NF_IRPROG] <> "1" .And.   aNFCab[NF_TPCLIFOR] == "X" ) //retenção de IR para operação de importação [artigos  706 e 719 do Decreto n3000, de março de 1999 (http://www.receita.fazenda.gov.br/Legislacao/rir/Livro3.htm)
			lUsaTbPrg := .F.
		EndIf

		If lUsaTbPrg
			If nSomaIRF == 0
				aEval(aNfItem,{|x| nSomaIRF += IIf(!x[IT_DELETED],x[IT_BASEIRR],0)})
				aIRprg := xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc,aNfItem[nItem][IT_BASEIRR],nSomaIRF-aNfItem[nItem][IT_BASEIRR],.T.,aNfCab[NF_CODCLIFOR],aNfCab[NF_LOJA],dVencReal,cPessoa,aUltPesq,aCodR,nPosCodR)
			EndIf
			If aNfCab[NF_MODIRF] <> "2"
				For nX := 1 To Len(aNFItem)
					If aNFItem[nX][IT_BASEIRR] > 0 //Somente atualiza a aliquota de IR para os itens que possuem Base de Cálculo
						aNFItem[nX][IT_ALIQIRR] := aIRprg[2]
						aNfItem[nX][IT_VALIRR]  := Max((aNFItem[nX][IT_BASEIRR] * (aNFItem[nX][IT_ALIQIRR] / 100)) - ((aNFItem[nX][IT_BASEIRR] / nSomaIRF) * aIRprg[3]),0)
					EndIf
				Next nX
				//TODO verificar como fazer RatRes e It2Cab
				If aIRprg[1] > 0
					MaFisRatRes("IT_VALIRR",aIRprg[1],aIRprg[2],"IT_ALIQIRR","IT_BASEIRR",nItem)
					MaIt2Cab(nItem)
				else
					MaIt2Cab(nItem)		
				EndIf
			Else
				If aNfItem[nItem][IT_BASEIRR] - aIRprg[4] > 0
					If fisExtCmp('12.1.2310', .T.,'SA2','A2_CALCIRF') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_VRETIRF') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_PRETIRF') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_VRETIRF') .And. ;
						fisExtCmp('12.1.2310', .T.,'SE5','E5_PRETIRF') .And. aNfCab[NF_MODIRF] == "2" // Se Fornecedor utiliza MP232 NAO calcular ou gravar IRPF
						aNfItem[nItem][IT_VALIRR] := 0
					Else
						aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_BASEIRR] * aNfItem[nItem][IT_ALIQIRR] /100
					Endif
				Else
					aNfItem[nItem][IT_VALIRR] := 0
				EndIf
			EndIf
		Else
			aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_BASEIRR] * aNfItem[nItem][IT_ALIQIRR] / 100
		EndIf

		MaItArred(nItem, {"IT_VALIRR"})

	EndIf
Else
    IF (nPosTgIR := aScan(aNfItem[nItem][IT_TRIBGEN],{|x| Alltrim(x[12])==TRIB_ID_IR})) >0

        aNfItem[nItem][IT_VALIRR] := aNfItem[nItem][IT_TRIBGEN][nPosTgIR][TG_IT_VALOR]
        aNfItem[nItem][IT_BASEIRR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIR][TG_IT_BASE]
        aNfItem[nItem][IT_ALIQIRR]:= aNfItem[nItem][IT_TRIBGEN][nPosTgIR][TG_IT_ALIQUOTA]

    Endif

Endif

Return

/*/
MaTbIrfPF-Eduardo/Edson   -31.01.2004
Inicializa o Calculo das operacoes Fiscais
Retorno   ExpA: [1] Valor do IRPF
[2] Aliquota do IRPF
[3] Dedução  do IRPF
Parametros ExpN1 : Valor do IRPF
ExpN2 : Valor acumulado do IRPF
*/
Function xFisIRFPF(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, nBaseIRF, nTotIrf, lSE2, cFornece, cLoja, dVencReal, cPessoa, aUltPesq,aCodR,nPosCodR)

Local aArea     := GetArea()
Local aTabela   := {}
Local aFilCnpj	:= Iif(cPessoa == "F",MatFilCalc(.F.),{})
Local cAddWhere := ""
Local cBuffer   := ""
Local nX        := 0
Local nBase     := 0
Local nAliq     := 0
Local nValor    := 0
Local nDed      := 0
Local nIsento   := 0
Local nTotBaseIR:= 0
Local nTotInss	:= 0
Local nTotIrrf	:= 0
Local nVenctoPF := fisGetParam('MV_ACMIRPF','1')
Local nVenctoPJ := fisGetParam('MV_ACMIRPJ','1')   //1 = Emissao    2= Vencimento Real	3=Data Contabilizacao
Local lContrRet := fisExtCmp('12.1.2310', .T.,'SE2','E2_VRETPIS') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_VRETCOF') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_VRETCSL') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_PRETPIS') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_PRETCOF') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_PRETCSL')
Local lPCCBaixa := fisGetParam('MV_BX10925','2') == "1" .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_VRETPIS') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_VRETCOF') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_VRETCSL') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_PRETPIS') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_PRETCOF') .And. fisExtCmp('12.1.2310', .T.,'SE5','E5_PRETCSL') .And. fisExtCmp('12.1.2310', .T.,'SE2','E2_SEQBX') .And. fisExtCmp('12.1.2310', .T.,'SFQ','FQ_SEQDES')
Local dDataEmi	:=	dDataBase
Local cFilQrySE2 := ""
Local aNfProc := {}
Local oRatIRF := If(lA103Rat,A103GRatIr(),NIL)
Local cIdOrig := ""
Local cCdRetIRRt := fisGetParam("MV_RETIRRT","3208")

Local nTotTit := 0
Local nSldDep := 0
Local nBsIrDedLe := 0 // variável que guardará a base do IR acumulada com dedução legal
Local nSumItINS := 0
Local nSumItBsIr := 0

Local cWhere    := ""
Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
Local cSepProv  := If("|"$MVPROVIS,"|",",")
Local cSepRec   := If("|"$MVPAGANT,"|",",")
Local afilial := xFisQryFIL()
Local cJoinE2ED		:= "%" + FWJoinFilial("SE2","SED") + "%"

DEFAULT nTotIrf   := 0
DEFAULT lSE2      := .F.
DEFAULT dVencReal := dDataBase
DEFAULT aCodR     := {}
DEFAULT nPosCodR  := 0

//dDataEmi para respeitar os parametros MV_ACMIRPF e  MV_ACMIRPJ
If Type("dDEmissao") == "D" .And. !Empty(dDEmissao)
	dDataEmi	:=	dDEmissao
Endif

If FWModeAccess( "SE2" , 3 ) == "C"
	cFilOri := "E2_FILORIG"
Else
	cFilOri := "E2_FILIAL"
EndIf

// Calcula o valor do IRF ocorrido no mes
If lSE2 .And. ( !(aUltPesq[1] == dDataBase .And. aUltPesq[2] == cFornece .And. aUltPesq[3] == cLoja))

	//Define o fornecedor e loja que seram utilizados para criação 
	//da estrutura do rateio de aluguel
	If !Empty(oRatIRF)
		oRatIRF:SetForLoja(cFornece, cLoja)
	EndIf

	cWhere := ""
	If cPessoa == "F" .Or. aNfCab[NF_IRPROG] == "1"
		If nVenctoPF == "2"
			//Se for no mesmo mês uso a DataBase senão uso a Data do Vencimento Real
			If Dtos(FirstDay(dVencReal))<= Dtos(dDataBase) .And. Dtos(LastDay(dVencReal))>= Dtos(dDataBase)
				cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
			Else
				cWhere += "%SE2.E2_VENCREA  BETWEEN '"+Dtos(FirstDay(dVencReal))+"' AND '"+Dtos(LastDay(dVencReal))+"' AND "
			EndIf
		ElseIf nVenctoPF == "1"
			cWhere += "%SE2.E2_EMISSAO  BETWEEN '"+Dtos(FirstDay(dDataEmi))+"' AND '"+Dtos(LastDay(dDataEmi))+"' AND "
		Else
			cWhere += "%SE2.E2_EMIS1  BETWEEN '"+Dtos(FirstDay(dDataBase))+"' AND '"+Dtos(LastDay(dDataBase))+"' AND "
		EndIf
	Else
		If nVenctoPJ == "2"
			If Dtos(dDataBase)==Dtos(dVencReal)
				cWhere += "%SE2.E2_VENCREA  = '" + Dtos(dDataBase) + "' AND "
			Else
				cWhere += "%SE2.E2_VENCREA  = '" + Dtos(dVencReal) + "' AND "	//Totaliza pelo vencimento real
			EndIf
		ElseIf nVenctoPJ == "1"
			cWhere += "%SE2.E2_EMISSAO  = '" + Dtos(dDataEmi) + "' AND "
		Else
			cWhere += "%SE2.E2_EMIS1  = '" + Dtos(dDataBase) + "' AND "
		EndIf
	EndIf
	cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")+" AND "
	cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MV_CPNEG,cSepNeg)+" AND "
	cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVPROVIS,cSepProv)+" AND "
	cWhere += "SE2.E2_TIPO NOT IN "+FormatIn(MVPAGANT,cSepRec)+" AND "
	cWhere += "SE2.E2_FATURA NOT IN ('NOTFAT') "
	If fisExtPE('MACALIRRF')
		cAddWhere := ExecBlock("MACALIRRF",.F.,.F., {cWhere} )
		If ValType(cAddWhere) == "C" .And. !Empty(cAddWhere)
			cWhere += " AND " + cAddWhere
		EndIf
	EndIf
	cWhere += "%"
	BeginSql Alias "MaTbIrfPF"
		SELECT E2_FILIAL,E2_VALOR,E2_IRRF,E2_BASEIRF,E2_INSS,E2_ISS,E2_SEST,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,
		E2_TIPO,E2_NUM,E2_PREFIXO,E2_FORNECE,E2_LOJA,E2_ORIGEM,E2_FATURA,E2_FILORIG,E2_PARCELA,ED_BASEIRF
		FROM %Table:SE2% SE2
		INNER JOIN %Table:SED% SED ON %exp:cJoinE2ED% AND SE2.E2_NATUREZ = SED.ED_CODIGO
		WHERE
		%exp:aFilial[1]%
		SE2.E2_FORNECE = %Exp:cFornece% AND
		SE2.E2_LOJA = %Exp:cLoja% AND
		SE2.%notdel% AND
		%exp:cWhere% AND
		SED.ED_CALCIRF = 'S' AND
		SED.ED_CODIGO = SE2.E2_NATUREZ AND
		SE2.%notdel% AND
		SED.%notdel%
	EndSql

	dbSelectArea("MaTbIrfPF")

	While !(MaTbIrfPF->(Eof()))
		If 	MaTbIrfPF->(E2_TIPO) == MVNOTAFIS .And. Alltrim(MaTbIrfPF->(E2_ORIGEM)) == "MATA100"

			cFilQrySE2 := Iif(cFilOri == "E2_FILIAL",MaTbIrfPF->E2_FILIAL,MaTbIrfPF->E2_FILORIG)

			If cPessoa == "F"
				aFilial[2] := "%SF1.F1_FILIAL = '" + cFilQrySE2 + "' AND%"
				If (nX := aScan(aFilCnpj,{|x| x[2] == cFilQrySE2})) == 0 .Or. ;
					Substr(aFilCnpj[nX,4],1,8) <> Substr(SM0->M0_CGC,1,8)
					dbSkip()
					Loop
				EndIf
			EndIf
		
			// Validacao para que os valores de uma NF que tenha mais de uma parcela nao sejam acumulados indevidamente.
			// Nestes casos a query na SE2 retorna mais de uma linha, porem soh preciso dos dados da SD1 uma vez...então
			// soh executo a query na SD1 uma vez.
			If aScan(aNfProc, {|x| x[1]+x[2]+x[3]+x[4]+x[5] == cFilQrySE2 + MaTbIrfPF->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)}) == 0

				BeginSql Alias "TMPSD1"
					SELECT SUM(D1_BASEIRR) BASEIRR, SUM(D1_VALINS) VALINS, SUM(D1_SLDDEP) SLDDEP
					FROM %Table:SD1% SD1, %Table:SF1% SF1
					WHERE
					%Exp:aFilial[2]%
					SF1.F1_DOC = %Exp:MaTbIrfPF->(E2_NUM)% AND
					SF1.F1_PREFIXO = %Exp:MaTbIrfPF->(E2_PREFIXO)% AND
					SF1.F1_FORNECE = %Exp:MaTbIrfPF->(E2_FORNECE)% AND
					SF1.F1_LOJA = %Exp:MaTbIrfPF->(E2_LOJA)% AND
					SF1.%notdel% AND
					SD1.D1_FILIAL = SF1.F1_FILIAL AND
					SD1.D1_DOC = SF1.F1_DOC AND
					SD1.D1_SERIE = SF1.F1_SERIE AND
					SD1.D1_FORNECE = SF1.F1_FORNECE AND
					SD1.D1_LOJA = SF1.F1_LOJA AND
					SD1.%notdel%
				EndSql

				nTotBaseIR	+= BASEIRR
				nSldDep	   	+= SLDDEP
				dbCloseArea()

				aAdd(aNfProc, {cFilQrySE2, MaTbIrfPF->(E2_NUM), MaTbIrfPF->(E2_PREFIXO), MaTbIrfPF->(E2_FORNECE), MaTbIrfPF->(E2_LOJA)})

			EndIf
		// So executa para titulos avulsos
		// Nesse caso o valor da BASEIRF não pode ser somado com o IR novamente, por que dessa forma não bate com os mesmo calculos realizado no tirulo avulso no financeiro
		Else
			If fisGetParam('MV_INSIRF','2')=="1"
				nTotBaseIR	+= (E2_BASEIRF - E2_INSS) + E2_ISS
			Else
				nTotBaseIR +=  E2_BASEIRF + E2_ISS
			EndIf
			
		EndIf
		dbSelectArea("MaTbIrfPF")
		nTotTit += E2_VALOR + E2_IRRF + E2_INSS + E2_ISS + E2_SEST
		If lContrRet .And. !lPccBaixa .And. (E2_PRETPIS == " " .And. E2_PRETCOF == " " .And. E2_PRETCSL == " ")
			nTotBaseIR	+= E2_VRETPIS+E2_VRETCOF+E2_VRETCSL
			nTotTit		+= E2_VRETPIS+E2_VRETCOF+E2_VRETCSL
		Endif

		//Se a natureza tiver redução na base, recalcula o valor do titulo reduzindo a base para IR
		if (ED_BASEIRF > 0)
			nTotTit = nTotTit * (ED_BASEIRF / 100)
		endif

		nTotInss += E2_INSS
		nTotIrrf += E2_IRRF

		//Verifica o valor de IR Retido por CPF
		//Rateio de IR Aluguel
		If !Empty(oRatIRF)
			cIdOrig := oRatIRF:GetIdDoc(E2_FILIAL + "|" + E2_PREFIXO + "|" + E2_NUM + "|" + E2_PARCELA + "|" + E2_TIPO + "|" + E2_FORNECE + "|" + E2_LOJA)
			oRatIRF:GetIRRetido(cIdOrig)
		EndIf

		dbSkip()
	EndDo
	MaTbIrfPF->(dbCloseArea())
	dbSelectArea("SA2")

	//MV_INSIRF == "1" Ja grava o valor da BASE do IRFF no E2_BSEIRF/D1_BASEIRR descontando o valor do INSS nao sendo necessario tratar o parametro nesta funcao para somar ou subtrair o INSS da base do IR
	aUltPesq:= {dDataBase, cFornece, cLoja, nTotBaseIR ,nTotIRRF, nTotTit, nTotInss, nSldDep}

EndIf

nBaseIRF += aUltPesq[4]

if !Empty(aNfItem)
	// soma o INSS de todos os itens não deletados
	aEval(aNfItem,{ |x| nSumItINS += IIf(!x[IT_DELETED],x[IT_VALINS],0)})
	// soma a base do IR original de todos os itens
	aEval(aNfItem,{ |x| nSumItBsIr += IIf(!x[IT_DELETED],x[IT_BASIRORI],0)})

	nBsIrDedLe := (aUltPesq[6] + nSumItBsIr) - (aUltPesq[7] + aUltPesq[8] + nSumItINS)
	// preciso pegar o INSS da nota atual e somar no nTotInss
endif

//Tratamento para o rateio de IR Aluguel
//Define a base do IRPF que sera aplicada no calculo
If !Empty(oRatIRF)
	oRatIRF:SetBaseIr(nBsIrDedLe, (aUltPesq[6] + nSumItBsIr))
EndIf

// Aplica a tabela progressiva
If File("SIGAADV.IRF")
	FT_FUse("SIGAADV.IRF")
	FT_FGotop()
	While ( !FT_FEof() )
		cBuffer := FT_FReadLn()
		aadd(aTabela,{Val(SubStr(cBuffer,1,15)),Val(SubStr(cBuffer,17,6)),Val(SubStr(cBuffer,24,15))})
		FT_FSkip()
	EndDo
	FT_FUse()

	For nX := 1 To Len(aTabela)
		nBase := aTabela[nX,1]
		nAliq := aTabela[nX,2]
		nDed  := aTabela[nX,3]
		If nAliq == 0
			nIsento := nBase
		EndIf

		If nBaseIRF+nTotIrf <= aTabela[nX][1]
			Exit
		EndIf
	Next nX
	nValor := NoRound(((nBaseIRF+nTotIrf)*nAliq/100),3)-nDed-aUltPesq[5]
	nValor := Max(nValor,0)
EndIf

if !Empty(aCodR) .and. nPosCodR > 0 .and. Alltrim(aCodR[nPosCodr,4]) == "IRR"
	If aCodR[nPosCodR,3] == 1 .and. Alltrim(aCodR[nPosCodR,2]) $ cCdRetIRRt
		If !Empty(oRatIRF) .and. !Empty(oRatIRF:aRatIRF) .And. Len(oRatIRF:aRatIrf) > 1
			nValor := oRatIRF:CalcRatIr()
			nAliq := 0 
		EndIf
	EndIf
endif

RestArea(aArea)

Return({nValor,nAliq,nDed,nIsento})

//-------------------------------------------------------------------
/*/{Protheus.doc} xFisGIR()
Verifica se deverá realizar o GrossUp do Imposto de Renda

@return   lRet 	   - Retorna se deverá ou não fazer o GrossUp do IRRF

@author Erick Gonçalves Dias
@since 17/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function xFisGIR(nItem, aNFItem, aNfCab, cOpcao)
Local lRet		:= .F.
Local lGrossUp	:= .F.
Default cOpcao	:= ""

/*Opções do NF_GROSSIR
0 = Sem Gross
1 = Imp. Serv. IRRF
2 = Imp. Serv. IRRF + CIDE
3 = Imp. Serv. IRRF + Valor do Serviço
*/

If cOpcao $ "ISS/VALCONT/" .AND. aNfCab[NF_GROSSIR] == "3"
	//Usuário configurou para que realize o GrossUP do IRRF também na base do ISS, por este motivo o valor do serviço é alterado, bem como valor contábil e valor da duplicata
	lGrossUp	:= .T.

ElseIf cOpcao == "DUP" .AND. aNfCab[NF_GROSSIR] $ "3|2|1" .And. aNfCab[NF_MODIRF] == "2"
	// A adição do valor de IRRF no valor do título deve ocorrer somente quando houver dedução do IRRF na baixa do título.
	lGrossUp	:= .T.

ElseIF cOpcao == "CIDE" .AND. aNfCab[NF_GROSSIR] $ "3|2"
	//Usuário configurou para que realize o GrossUP do IRRF também na base da CIDE
	lGrossUp	:= .T.
ElseIF cOpcao $ "IRRF/PISCOFIMP" .AND. aNfCab[NF_GROSSIR] $ "1/2/3"
	//Usuário configurou para que realize o GrossUP do IRRF, qualquer uma das opções fará gross up na base do IRRF e PIS e COFINS Importação
	lGrossUp	:= .T.
EndIF

//Verifica se é uma operação de serviço tomado do exterior
IF lGrossUp 							       .And. ;
   !Empty(aNfItem[nItem][IT_CODISS]) 		   .And. ;
   aNfItem[nItem][IT_ALIQIRR] 			> 0	   .And. ;
   aNFCab[NF_OPERNF] 					== "E" .And. ;
   aNFCab[NF_CLIFOR] 					== "F" .And. ;
   aNFCab[NF_TPCLIFOR] 					== "X" .And. ;
   Substr(aNfItem[nItem][IT_CF],1,1)	== "3" .And. ;
   aNFItem[nItem][IT_TS][TS_ISS] 		== "S"

	lRet := .T. //Deverá realizr o GrossUp

EndIF

Return lRet

/*MaRecIR - Cleber Stenio   -07.01.2009
  Descri‡…oRecalcula o Valor do IR qdo alterado a condicao de Pagamento
   do Titulo no MATA103X.*/
Function FISRECIR(aNfCab, aNFItem, aPos, aInfNat, aPE, aSX6, aDic, aFunc, dVencReal,aUltPesq,lIRRFSemDu,aCodR,nPosCodR)

Local nX  		:= 0
Local nAliquota := 0
Local lTabProg 	:= .F.
Local cPessoa	:= Iif(Len(Alltrim(aNfCab[NF_CNPJ]))< 14,"F","J")

DEFAULT dVencReal := dDataBase
Default aCodR := {}
Default nPosCodR := 0

aUltPesq := {ctod(""),"","",0,0}

aEval(aNfItem,{|x| nAliquota += IIf(!x[IT_DELETED],x[IT_ALIQIRR],0)}) // Para impedir o recalculo o IRRF quando o mesmo for informado Manualmente na NFE

IF ( cPessoa == "F" .Or. aNfCab[NF_IRPROG] == "1" ) .And. (aNfCab[NF_CLIFOR] == "F" .Or. ( aNfCab[NF_CLIFOR] == "C" .And. aNfCab[NF_ALIQIR] == 0 ) .Or. aNfCab[NF_IRPROG] == "1" )
	lTabProg := .T.
EndIf

If nAliquota > 0

	For nX := 1 To Len(aNFItem)
		IF aNFItem[nX][IT_BASEIRR] > 0
			FISXIR(aNfCab, aNFItem, nX, aPos, aInfNat, aPE, aSX6, aDic, aFunc, "VLR", lIRRFSemDu, dVencReal, , aUltPesq,,aCodR,nPosCodR)
			MaItArred(nX)
		EndIf
	Next nX

	MaIt2Cab()

ElseIf lTabProg

	For nX := 1 To Len(aNFItem)	
		IF aNFItem[nX][IT_BASEIRR] > 0	
			FISXIR(aNfCab, aNFItem, nX, aPos, aInfNat, aPE, aSX6, aDic, aFunc, "ALQ|VLR", lIRRFSemDu, dVencReal, , aUltPesq,,aCodR,nPosCodR)
			MaItArred(nX)
		EndIf
	Next nX

	MaIt2Cab()

EndIf

Return


/*/{Protheus.doc} IRConvRf
(Função responsavel por converter alteração de referencia legado em referencia do configurador)

@author Rafael Oliveira
@since 02/12/2020
@version 12.1.31

@param:	
aNFItem-> Array com dados item da nota
nItem  -> Item que esta sendo processado	
ccampo -> Campo que esta sendo alterado	
/*/
Function IRConvRf(aNfItem,nItem,ccampo)
Local cCampoConv := ""

IF cCampo == "IT_VALIRR"
    cCampoConv := "TG_IT_VALOR"		
Elseif cCampo == "IT_BASEIRR"	
    cCampoConv := "TG_IT_BASE"				
Elseif cCampo == "IT_ALIQIRR"
    cCampoConv := "TG_IT_ALIQUOTA"				
Endif

Return cCampoConv


/*/{Protheus.doc} procDedSim -> processa Dedução simplificada
	(Responsável por processar o calculo do simplificado)
	@type  Function
	@author anedino.santos
	@since 02/08/2023
	@version 12.1.2210
	@param aNfCab, array, vetor de dados do cabeçalho da NF
	@param aNfItem, array, vetor de dados dos itens da NF
	@param nItem, numeric, item corrente
	@param nValDep, numeric, valor unitário por dependente
	@param nNumDep, numeric, quantidade de dependentes do fornecedor
	@param nDedSimpli, numeric, valor da dedução simplificada configurada no sistema
	@param aUltPesq, array, vetor com os dados totais das últimas NFs
	@return nBsIrDed, numeric, base do IRRF com dedução
/*/
Function procDedSim(aNfCab, aNfItem, nItem, nValDep, nNumDep, nDedSimpli, aUltPesq)
	Local nSomaItINS:= 0
	Local lDedSimAnt:= .F.
	Local nDedAtu	:= 0
	Local nTotTit	:= aUltPesq[6]
	Local nInssAcum	:= aUltPesq[7]
	Local nSldDep	:= aUltPesq[8]
	Local nTotDedAnt:= nSldDep + nInssAcum
	Local nTotDedAtu:= nValDep * nNumDep + nInssAcum
	Local nBsIrDed	:= aNfItem[nItem][IT_BASEIRR]
	Local nI := 0

	// reseto a referência para os casos de recalculo
	aNfItem[nItem][IT_APLIDEDS] := .F.

	if  nItRetDel == nItem
		aEval(aNfItem,{ |x| nSomaItINS += IIf(!x[IT_DELETED],x[IT_VALINS],0)})
		nItRetDel := 0
	else
		aEval(aNfItem,{ |x| nSomaItINS += IIf(!x[IT_DELETED] .and. val(x[IT_ITEM]) <= nItem,x[IT_VALINS],0)})
	endif

	nTotDedAtu += nSomaItINS	//Soma as deduções legais das NF anteriores com a NF atual

	// Se houve valor calculado anteriormente para esse fornecedor, verifico se
	// foi aplicada a dedução simplificada nesses calculos
	if nTotTit > 0 .and. (nTotDedAnt <= nDedSimpli)
		lDedSimAnt := .T.
	endif

	// acumulo a parcela da dedução simplificada
	for nI := 1 to len(aNFitem)
		if aNfItem[nI][IT_APLIDEDS]
			nDedAtu += aNfItem[nI][IT_DEDSIRR]
		endif
	next nI

	// se não for a primeira NF do fornecedor preciso entender se já foi aplicada
	// dedução simplificada nas NFs antereiores e se na atual ainda será mantida
	// a dedução simplificada.
	// Se a dedução legal atual (nTotDedAtu) for menor ou igual a dedução simplificada (nDedSimpli), significa que permanece a dedução simplificada, pois abaterá mais na base do IR pela dedução simplificada, logo pagará um valor menor de IR.
	if lDedSimAnt .and. (nTotDedAtu <= nDedSimpli)
		if !aNfItem[nItem][IT_DELETED]

			aNFCab[NF_VALDEDS] += aNfItem[nItem][IT_DEDSIRR]
			aNfItem[nItem][IT_DEDSIRR] := 0

			// se o valor da dedução simplificada não foi inicializado
			// inicializo ele nesse momento
			if !aNFCab[NF_INIDEDS]
				iniDedSimp(MAX(nDedSimpli - nTotTit,0), aNFCab)
			endif

			apliDedS(aNFCab, aNfItem, nItem, @nBsIrDed)

		else
			// caso o item esteja deletado nesse momento, reseto a referência
			// da dedução simplificada para que ha mafisdel seja recalculado o IR
			// de todos os itens
			aNFCab[NF_VALDEDS] := MAX(nDedSimpli - nTotTit,0)
			resetDedS(aNfItem)
		endif

	elseif nTotTit == 0 .and. (nTotDedAtu <= nDedSimpli)// é a primeira NF do período(nTotTit == 0) e se a dedução legal atual (nTotDedAtu) for menor ou igual a dedução simplificada (nDedSimpli), significa que permanece a dedução simplificada, pois abaterá mais na base do IR pela dedução simplificada, logo pagará um valor menor de IR.

		// se o item não está deletado
		if !aNfItem[nItem][IT_DELETED]

			aNFCab[NF_VALDEDS] += aNfItem[nItem][IT_DEDSIRR]
			aNfItem[nItem][IT_DEDSIRR] := 0

			// se o valor da dedução simplificada não foi inicializado
			// inicializo ele nesse momento
			if !aNFCab[NF_INIDEDS]
				iniDedSimp(nDedSimpli, aNFCab)
			endif

			apliDedS(aNFCab, aNfItem, nItem, @nBsIrDed)
		else
			aNFCab[NF_VALDEDS] := nDedSimpli
			resetDedS(aNfItem)
		endif
	// se houve dedução simplificada na cumulatividade das NFs anteriormente
	// verifico se a soma das deduções legais são maiores que o valor da dedução simplificada
	// se for, preciso tratar a diferença no item atual
	// Se a dedução legal atual (nTotDedAtu) for maior que a dedução simplificada (nDedSimpli), significa que permanece a dedução legal, pois abaterá mais na base do IR pela dedução legal, logo pagará um valor menor de IR.
	elseif (lDedSimAnt .or. nDedAtu > 0) .and. nTotDedAtu > nDedSimpli
		// se o item não está deletado e não houve o tratamento da diferença das deduções legais
		// pela dedução simplificada, aplico a diferença no item atual.
		if lDedSimAnt
			nDedAtu += nDedSimpli - MAX(nDedSimpli - nTotTit,0)
		endif

		if !aNfItem[nItem][IT_DELETED] .and. (aNFCab[NF_ITDEDDIF] == 0  .or. aNFCab[NF_ITDEDDIF] == nItem)
			nDif := nTotDedAtu - nDedAtu
			nBsIrDed := aNfItem[nItem][IT_BASEIRR] - nDif
			aNFCab[NF_ITDEDDIF] := nItem
		endif
	endif
	// indica se o IR foi calculado pelo simplificado nessa nota
	aNFCab[NF_IRCALSIM] := aNfItem[nItem][IT_APLIDEDS] .and. Empty(aNFCab[NF_ITDEDDIF])

Return nBsIrDed


/*/{Protheus.doc} RecalIR
	(Essa função é responsável por efetuar o recalculo do IR de todos os itens 
	da NF)
	@type  Function
	@author anedino.santos
	@since 09/08/2023
	@version 12.1.2210
	@param aNFCab, array, vetor com dados do cabeçalho da NF
	@param aNfItem, array, vetor com dados dos itens da NF
	@param nItem, numeric, item corrente
	@param dVencReal, date, data do vencimento real
	@return Nil
/*/
Function RecalIR(aNFCab, aNfItem, nItem, dVencReal)
	Local nI			:= 0

	Default dVencReal	:= dDataBase
	// por conta de recalcular todos os itens eu reseto a referência que guarda
	// qual item sofreu a diferença entre as deduções legais e a dedução simplificada
	aNFCab[NF_ITDEDDIF] := 0
	for nI := 1 to len(aNfItem)
		if !aNfItem[nI][IT_DELETED]
			MaFisIR(nI,,dVencReal)
			MaFisLF(nI)
		endif
	next nI
	MaIt2Cab(nItem)
Return Nil


/*/{Protheus.doc} iniDedSimp
	Essa função é responsável por inicializar a dedução simplificada
	@type  Function
	@author anedino.santos
	@since 09/08/2023
	@version 12.1.2210
	@param nDedApli, numeric, valor da dedução simplificada a ser ativado
	@param aNFCab, array, vetor com dados dos itens da NF
	@return Nil
/*/
function iniDedSimp(nDedApli, aNFCab)
	aNFCab[NF_VALDEDS] := nDedApli
	aNFCab[NF_INIDEDS] := .T.
return


/*/{Protheus.doc} resetDedS
	(Essa função é responsável por resetar a dedução simplificada aplicada nos
	itens da NF)
	@type  Function
	@author anedino.santos
	@since 09/08/2023
	@version 12.1.2210
	@param aNfItem, array, vetor com dados dos itens da NF
	@return Nil
/*/
function resetDedS(aNfItem)
	local nI := 0

	for nI := 1 to len(aNfItem)
		aNfItem[nI][IT_DEDSIRR] := 0
	next nI

return


/*/{Protheus.doc} apliDedS
	(Essa função é responsável por aplicar a dedução simplificada)
	@type  Function
	@author anedino.santos
	@since 09/08/2023
	@version 12.1.2210
	@param aNFCab, array, vetor com dados da NF
	@param aNfItem, array, vetor com dados dos itens da NF
	@param nItem, numeric, item corrente da NF
	@param nBsIrDed, numeric, base do IR que pode sofrer dedução - esse parâmetro deve ser passado por ponteiro (@)
	@return Nil
/*/
function apliDedS(aNFCab, aNfItem, nItem, nBsIrDed)
	// se há valor da dedução simplificada a ser consumido
	if aNFCab[NF_VALDEDS] > 0
		// retiro da dedução simplificada a base do item (a base do item está cheia nesse momento)
		aNFCab[NF_VALDEDS] := aNFCab[NF_VALDEDS] - aNfItem[nItem][IT_BASEIRR]

		// se ao tirar da dedução simplificada ainda sobrou valor, quer dizer
		// que a base do item foi toda consumida. Assim, zero a base do item
		if aNFCab[NF_VALDEDS] >= 0
			aNfItem[nItem][IT_DEDSIRR] := nBsIrDed
			nBsIrDed := 0
		else// caso o valor da dedução seja negativo, quer dizer que a base do item
			// consumiu toda a dedução simplificada e ainda restou valor na base
			// assim, o valor negativo que ficou na referência é a nova base do item
			// para não ficar negativo uso a função ABS
			aNfItem[nItem][IT_DEDSIRR] := aNFCab[NF_VALDEDS] + nBsIrDed
			nBsIrDed := ABS(aNFCab[NF_VALDEDS])
			// zero o valor de dedução simplificada pois foi todo consumido
			aNFCab[NF_VALDEDS] := 0
		endif
		// confirmo que ainda está sendo utilizada a dedução simplificada
		aNfItem[nItem][IT_APLIDEDS] := .T.

	else
		// se o valor da dedução simplificada não for maior que zero
		// quer dizer que já foi consumida por completo
		// mantenho a base do item
		nBsIrDed := aNfItem[nItem][IT_BASEIRR]
		// confirmo que ainda está sendo utilizada a dedução simplificada
		aNfItem[nItem][IT_APLIDEDS] := .T.
	endif
return


/*/{Protheus.doc} setIRStatic
	(Atribui um conteúdo a uma variavel estática do fonte FISXIR)
	@type  Function
	@author anedino.santos
	@since 26/12/2023
	@version 12.1.2310
	@param cVarStatic, character, nome da variável estática
	@param xValor, variant, valor a ser atribuído a variável estática
	@return NIL, NIL, sem retorno
/*/
Function setIRStatic(cVarStatic, xValor)
	&cVarStatic := xValor
Return NIL

/*/{Protheus.doc} xFisIRFIL
	Retorna as filiais que devem ser filtradas de acordo com o parâmetro MV_AGLIMPJ.
	Se houver necessidade de adicionar novas tabelas, lembrar de adicionar um elemento no aRet.
	@type  Function
	@author Victor Cardoso
	@since 14/06/2024
	@version 12.1.2310
	@return aRet - Array com a query a ser usada no decorrer do programa, as tabelas são separadas por elementos.
			aRet[1] - SE2
			aRet[2] - SD1
			aRet[3] - SED
			aRet[4] - SF1
/*/
Function xFisQryFIL()

	Local aRet      := {"%%","%%","%%","%%"}
	Local cAGLIMPJ  := fisGetParam('MV_AGLIMPJ',"1")
	Local aFilIRPF  := {}
	Local nA 		:= 0
	Local cQrySD1   := ""
	Local cQrySE2   := ""
	Local cQrySF1   := ""
	Local cQrySED   := ""
	Local lModSEDC   := If(FWModeAccess("SED") == "C", .T.,.F.)

	If cAGLIMPJ == '1'
		aRet := { "%SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND%",;
				  "%SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND%",;
				  "%SED.ED_FILIAL = '"+xFilial("SED")+"' AND%",;
				  "%SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND%"}
	Elseif cAGLIMPJ $ '2/3'
		//Retorna o código das filiais que possuem a mesma raiz cnpj ou cnpj iguais
		aFilIRPF := xCodFil(cAGLIMPJ)
		If (lModSEDC)
			cQrySED += "SED.ED_FILIAL = '" + xFilial("SED") + "' "
		EndIf
		FOR nA := 1 To Len(aFilIRPF)
			cQrySE2 += "SE2.E2_FILIAL = '" + xFilial("SE2",aFilIRPF[nA]) + IIF(nA <> Len(aFilIRPF),"' OR ","' ")
			cQrySD1 += "SD1.D1_FILIAL = '" + xFilial("SD1",aFilIRPF[nA]) + IIF(nA <> Len(aFilIRPF),"' OR ","' ")
			If (!lModSEDC)
				cQrySED += "SED.ED_FILIAL = '" + xFilial("SED",aFilIRPF[nA]) + IIF(nA <> Len(aFilIRPF),"' OR ","' ")
			EndIf
			cQrySF1 += "SF1.F1_FILIAL = '" + xFilial("SF1",aFilIRPF[nA]) + IIF(nA <> Len(aFilIRPF),"' OR ","' ")
		NEXT nA
		aRet := IIF(Len(aFilIRPF) > 0,;
				{"%("+cQrySE2+") AND%","%("+cQrySD1+") AND%","%("+cQrySED+") AND%","%("+cQrySF1+") AND%"},;
				{ "%SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND%",;
				  "%SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND%",;
				  "%SED.ED_FILIAL = '"+xFilial("SED")+"' AND%",;
				  "%SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND%"};
				)
	EndIf

return(aRet)



/*/{Protheus.doc} xCodFil
	Retorna os códigos das filiais SM0 conforme parâmetro MV_AGLIMPJ
	@type  Static Function
	@author anedino.santos
	@since 04/07/2024
	@version 12.1.2310
	@param cAglImpJ, character, conteúdo do parâmetro MV_AGLIMPJ
	@return aCodFil, array, contém os códigos das filias filtradas pelo MV_AGLIMPJ
	@example
	(
		xCodFil("3")
	)
	@see (links_or_references)
/*/
Static Function xCodFil(cAglImpJ)
	Local aCodFil := {}
	Local cCnpj := ""
	Local nInc := 0
	Local aSM0 := {}
	Local nEmp := 1
	Local cEmpAtu := cEmpAnt
	Local lGestao := .F.
	Local aArea := GetArea()

	Default cAglImpJ := '1'


	if cAglImpJ == '1'
		aAdd( aCodFil,  cFilAnt)
	else
		aSM0 := FWLoadSM0()
		lGestao := FWSizeFilial() > 2 // indica se usa gestão corporativa
		
		If cAglImpJ == '3'
			// deixo apenas os 8 primeiros digitos do CNPJ
			cCnpj := Substr(FWSM0Util():GetSM0Data(,, { "M0_CGC" } )[1,2],1,8)
		else 
			cCnpj := FWSM0Util():GetSM0Data(,, { "M0_CGC" } )[1,2]
		endif

		For nInc := 1 To Len( aSM0 )
			If aSM0[nInc][nEmp] == cEmpAtu .or. !lGestao
				If cAglImpJ == "3" .and. Substr(aSM0[nInc][18],1,8) == cCnpj
					aAdd( aCodFil, aSM0[nInc][2] )
				ElseIf cAglImpJ == "2" .and. aSM0[nInc][18] == cCnPj
					aAdd( aCodFil, aSM0[nInc][2] )
				Endif
			EndIf
		Next
	endif

	RestArea(aArea)
Return aCodFil
