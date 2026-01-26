#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STBITEMREGISTRY.CH"

Static lSaleActive	:= .F.
Static lCpoImpEnt	:=	SL2->(ColumnPos("L2_TOTFED")) > 0 .AND. ;
							SL2->(ColumnPos("L2_TOTEST")) > 0 .AND. ;
							SL2->(ColumnPos("L2_TOTMUN")) > 0 // Verifica a existencia do campo de Total de Imposto NCM/NBS


// Situacoes do _SITUA - SL1 ou SL2
//-------------------------------------------------------------------
/*
"  " - Base Errada, Registro Ignorado.
"00" - Venda Efetuada com Sucesso
"01" - Abertura do Cupom Nao Impressa
"02" - Impresso a Abertura do Cupom
"03" - Item Nao Impresso
"04" - Impresso o Item
"05" - Solicitado o Cancelamento do Item
"06" - Item Cancelado
"07" - Solicitado o Cancelamento do Cupom
"08" - Cupom Cancelado
"09" - Encerrado SL1 (Nao gerado SL4)
"10" - Encerrado a Venda
Pode nao ter sido impresso o cupom
"TX" - Foi Enviado ao Server
"RX" - Foi Recebido Pelo Server
"OK" - Foi Processado no Server
*/
//Enviar um OK ao Client que foi Processado
//-------------------------------------------------------------------


//-------------------------------------------------------------------
/*{Protheus.doc} STBSaveSaleBasket
Salva Cabecalho da venda na cesta de vendas
@param
@author  Varejo
@version P11.8
@since   26/09/2012
@return  lRet - Retorna se Salvou Item
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSaveSaleBasket()
Local lRet			:= .T.																					// Retorno		
Local lUsaFecha		:= SuperGetMV("MV_LJCONFF",.T.,.F.) 													// Utilizar conf. de fechamento
Local cTransNat		:= SuperGetMV("MV_LJTRNAT",.F.,"")														// Natureza financeira da transferencia
Local lUsaTransf	:= SuperGetMV("MV_LJTRANS",.T.,.F.) .AND. !Empty(cTransNat) .AND. lUsaFecha				// Utiliza Transferencia de caixa
Local cStation 		:= STFGetStation("CODIGO")																// Estacao atual
Local lEmitNfce		:= LjEmitNFCe()			 	// Sinaliza se utiliza NFC-e
Local cNumSerieSAT	:= STFGetStat("SERSAT") 	// Retorna a série do equipamento
Local lUseSat		:= STFGetCfg("lUseSAT",.F.) //Usa SAT?
Local aPrgInfo		:= {}
Local lNovoNum		:= .F.
Local aCartCRD		:= IIF(ExistFunc('STDFindCart'),STDFindCart(),{}) //Carrega informacoes do cartão utilizado no SIGACRD 
Local oCliModel 	:=  STDGCliModel()							// Model com as informacoes do cliente

/*/
	OBS:
	"L1_CLIENTE" , "L1_LOJA" , "L1_VEND" sao carregados na abertura do sistema e
	Alterados na funcao de selecao de clientes nao precisam ser atualizados aqui
/*/	 

//Starta o Tempo de atendimento
If SL1->(ColumnPos("L1_TIMEATE")) > 0
	STDSPBasket( "SL1" , "L1_TIMEATE"		, Seconds()							)
EndIf
	
STDSPBasket( "SL1" , "L1_EMISSAO"			, dDataBase							)
STDSPBasket( "SL1" , "L1_DTLIM"				, dDataBase							)
STDSPBasket( "SL1" , "L1_EMISNF"			, dDataBase							)
STDSPBasket( "SL1" , "L1_ESTACAO"			, cStation 							)
STDSPBasket( "SL1" , "L1_SITUA"				, "01"									) // "01" - Abertura do Cupom Nao Impressa 
STDSPBasket( "SL1" , "L1_TRCXGER"			, lUsaTransf    						)
STDSPBasket( "SL1" , "L1_TREFETI"			, .F.    								)

If lEmitNfce
	STDSPBasket( "SL1" , "L1_TPORC"			, "E"    								)
EndIf

If STFGetCfg("lUseSAT",.F.) .AND. SL1->(ColumnPos("L1_SERSAT")) > 0
    STDSPBasket( "SL1" , "L1_SERSAT"         , cNumSerieSAT                  ) 
EndIf 

/* Segue o padrao do FrontLoja, na L1_TABELA grava o valor que esta no parametro MV_TABPAD
   Ja na L2_TABELA nao grava, pois no FrontLoja gravava antes o valor da BI_TABELA, onde ambos os
   campos sao do tamanho 1 */
If !Empty(oCliModel:GetValue("SA1MASTER","A1_TABELA"))
	STDSPBasket( "SL1" , "L1_TABELA"			, oCliModel:GetValue("SA1MASTER","A1_TABELA")	)
Else
	STDSPBasket( "SL1" , "L1_TABELA"			, AllTrim(SuperGetMv("MV_TABPAD"))	)
Endif 

If STFGetCfg("lMultCoin") // Se usa Multimoeda
	STDSPBasket( "SL1" , "L1_MOEDA"			, STBGetCurrency()    			   ) 
	STDSPBasket( "SL1" , "L1_TXMOEDA"		, 1 					    			)
EndIf

STDSPBasket( "SL1" , "L1_NUMMOV"				, AllTrim(STDNumMov())	)

STDSPBasket( "SL1"	,	"L1_CGCCART"	,	iif(Len(aCartCrd)>=1,aCartCRD[1],""))		//Cartão do SIGACRD

If !STFGetCfg("lUseECF") 

	If !lUseSat
		aPrgInfo :=  GetAPOInfo("STBPAYMENT.PRW")
		lNovoNum :=  aPrgInfo[4] >= Ctod("16/01/2018")
	EndIf
	
	If lEmitNfce .AND. (lUseSat .OR. !lNovoNum)
		STDSPBasket( "SL1" , "L1_DOC"			, STDGPBasket( "SL1" , "L1_NUM" )		)
	Else
		STDSPBasket( "SL1" , "L1_DOC"			, "NFCE"		)
	EndIf
EndIf
// Informar ao server o  Status Atual do Check-Out.
// Add funcao de totais na venda
STFSLICreate( AllTrim(cStation)							, 	"CON"								,	"V|"	+ 	Alltrim(STDGPBasket("SL1","L1_PDV")) 						+ ;
				"|" 	+ AllTrim(STDGPBasket("SL1","L1_DOC"))	+	"|"		+	AllTrim( STR(STDGPBasket( "SL1" , "L1_VLRTOT" ))	)								+ ;
				"|"		+ AllTrim(Str(0))		, 	"SOBREPOE") // Total de Itens da Venda 


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSaveItBasket
Salva Item na cesta de vendas

@param   aInfoItem		Array contendo as informacoes do Produto
@param   nItemLine		Linha do Item
@author  Varejo
@version P11.8
@since   26/09/2012
@return  lRet				Retorna se atualizou cesta
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSaveItBasket( aInfoItem , nItemLine, cIdItRel, lItImpRDPT )

Local lRet			:= .T.												// Retorno da funcao
Local aSaveLines	:= FWSaveRows()										// aSaveLines
Local aMostruario	:= {"N",""}											// Array de Mostruario
Local lCAT83		:= SF4->(ColumnPos("F4_CODLAN")) > 0 .AND. SL2->(ColumnPos("L2_CODLAN")) > 0 .AND. ExistFunc("FISA023") .AND. SuperGetMV("MV_CAT8309",,.F.) // Verifica CAT/83 
Local lLjcFid		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()	// Indica se a recarga de cartao fidelidade esta ativa
Local cItemSitTrib	:= ""													// Situacao tributaria do item
Local lEmitNfce		:= LjEmitNFCe() // Sinaliza se utiliza NFC-e
Local lLjNfPafEcf	:= STBIsPaf()
Local lL2Modbc		:= SL2->(ColumnPos( "L2_MODBC" )) > 0			//Verifica se possui campo utilizado para otimizar processo da NFCe
Local lL2CEST		:= IIF((lEmitNfce .Or. lLjNfPafEcf) .AND. SL2->(ColumnPos( "L2_CEST"  )) > 0, .T.,.F.)
Local cModBC		:= ""
Local aCodVps		:= IIF(ExistFunc("STBGetCodVP"), STBGetCodVP(), {} ) //array codigo dos vale presentes
Local nCount		:= 0				//contador
Local aModBC		:= {}
Local lSaveOrc		:= IIF( ValType(STFGetCfg( "lSaveOrc" , .F. )) == "L" , STFGetCfg( "lSaveOrc" , .F. )  , .F. )   //Salva venda como orcamento 
Local lL2FECP		:= SL2->(ColumnPos("L2_ALQFECP") > 0 .AND. ColumnPos("L2_VALFECP") > 0)
Local lL2FECPST     := SL2->(ColumnPos("L2_ALQFCST") > 0 .AND. ColumnPos("L2_VFECPST") > 0)
Local lDate			:= .T.
Local oModelCesta	:= STDGPBModel()			//Model da cesta de produtos
Local cLF_MOTICMS	:= ""
Local lUseSat		:= STFGetCfg("lUseSAT",.F.) //Usa SAT?
Local lExistGetTriSat 	:= lUseSat .AND. (ExistFunc("LjGetTriSat") .AND. ExistFunc("LjSetTriSat"))	//Armazenamento para XML SAT
Local aSATTrib		:= {}										//Tributação produto SAT

Default aInfoItem 		:= {}									// Array do Item
Default nItemLine 		:= 0									// Linha do Item na Venda
Default cIdItRel 		:= ""									// ID do Item relacionado
Default lItImpRDPT		:= .F.									// Item importado com desconto da Regra de Desconto por produto no Total

// Salva Item na cesta de vendas
If (DATE() <> dDataBase)
	lDate := .F.
Endif

If nItemLine > 0 .AND. lDate

	If nItemLine > 1
		/*/
			Para o primeiro item nao realizar addline, pois o grid já traz linha em branco
		/*/
		STDPBAddLine("SL2")
	EndIf
	
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_FILIAL"				, xFilial("SL2")								, nItemLine	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_NUM"					, STDGPBasket("SL1","L1_NUM")				, nItemLine  	) ,)

	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_DOC"					, AllTrim(STDGPBasket("SL1","L1_DOC"))	, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_SERIE"					, AllTrim(STDGPBasket("SL1","L1_SERIE"))	, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_PDV"					, STDGPBasket("SL1","L1_PDV")				, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_EMISSAO"				, STDGPBasket("SL1","L1_EMISSAO")			, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VEND"					, STDGPBasket("SL1","L1_VEND")				, nItemLine  	) ,)
	
	If nItemLine <= 99
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_ITEM"                             , StrZero(nItemLine,TamSx3("L2_ITEM")[1]), nItemLine  ) ,)
	Else
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_ITEM"                             , STBPegaIT(nItemLine), nItemLine  ) ,)
	EndIf

	If lRet .AND. SL2->(ColumnPos("L2_IDITREL")) > 0
		lRet := STDSPBasket( "SL2" , "L2_IDITREL", cIdItRel, nItemLine )
	Endif

	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_PRODUTO"				, aInfoItem[ITEM_CODIGO] 					, nItemLine  	) ,)
	
	If lLjNfPafEcf .And. !Empty(Alltrim(STBTaxRet(nItemLine,"IT_CEST"))) .And. !Empty(AllTrim(aInfoItem[ITEM_POSIPI]))
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_DESCRI",;
		 	"#" + AllTrim(STBTaxRet(nItemLine,"IT_CEST")) + "#" + AllTrim(aInfoItem[ITEM_POSIPI]) + "#" + AllTrim(aInfoItem[ITEM_DESCRICAO]), nItemLine) ,)
	Else
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_DESCRI"				, aInfoItem[ITEM_DESCRICAO] 				, nItemLine  	) ,)
	EndIf
	
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_UM"						, aInfoItem[ITEM_UNID_MEDIDA] 				, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_LOCAL"					, aInfoItem[ITEM_ARMAZEMPAD] 				, nItemLine  	)  ,)	
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_CODBAR"					, aInfoItem[ITEM_CODBAR]                 , nItemLine  	)  ,)	 	
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_ORIGEM"					, aInfoItem[ITEM_ORIGEM] 				, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_CODISS"					, aInfoItem[ITEM_CODISS] 				, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_POSIPI"					, aInfoItem[ITEM_POSIPI] 				, nItemLine  	) ,)
	
	If lUseSat
		STBTaxAlt("IT_VALICM", LjArredSat(STBTaxRet(nItemLine,"IT_ALIQICM")/100 * STBTaxRet(nItemLine,"IT_BASEICM"),TamSX3("L2_VALICM")[2]),nItemLine)
		If !Empty(STBTaxRet(nItemLine,"IT_ALIQPS2"))
			STBTaxAlt("IT_VALPS2", LjArredSat(STBTaxRet(nItemLine,"IT_ALIQPS2")/100 * STBTaxRet(nItemLine,"IT_BASEPS2"),TamSX3("L2_VALPS2")[2]),nItemLine)
		Endif 
		If !Empty(STBTaxRet(nItemLine,"IT_ALIQCF2"))
			STBTaxAlt("IT_VALCF2", LjArredSat(STBTaxRet(nItemLine,"IT_ALIQCF2")/100 * STBTaxRet(nItemLine,"IT_BASECF2"),TamSX3("L2_VALCF2")[2]),nItemLine)
		Endif 
	Endif 	
	
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VALICM"					, STBTaxRet(nItemLine,"IT_VALICM")		, nItemLine  	)  ,)	
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_BASEICM"				, STBTaxRet(nItemLine,"IT_BASEICM")		, nItemLine  	) ,)

	oModelCesta := oModelCesta:GetModel("SL2DETAIL")
	If ExistFunc("STBGetTblPr") .AND. !Empty(STBGetTblPr())  .AND. oModelCesta:HasField("L2_CODTAB")
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_CODTAB"				, STBGetTblPr()		, nItemLine  	) ,)
	EndIf
	
	If Len(aCodVps) > 0 .AND. IIF(ExistFunc("STDIsVP"),STDIsVP(aInfoItem[ITEM_CODIGO]),.F.) 
		FOR nCount := 1 To Len(aCodVps)
			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VALEPRE", aCodVps[nCount]	, nItemLine  	) ,) //Codigo do vale presente
		NEXT nCount
	EndIf	

	If lExistGetTriSat
		//TRIBUTACAO SAT
		aSATTrib		:= LjGetTriSat()

		STBItSatTr(@aSATTrib, nItemLine, "IT_BASEPS2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_ALIQPS2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_BASECF2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_ALIQCF2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_PAUTPIS")
		STBItSatTr(@aSATTrib, nItemLine, "IT_PAUTCOF")
		STBItSatTr(@aSATTrib, nItemLine, "IT_CEST")

		//Grava os impostos no Array de tributações do SAT
		LjSetTriSat(aSATTrib)
	EndIf	

	//Regra utilizada no MatxFis para verificar a modalidade da base de calculo
	If lEmitNfce
		aModBc := STBTaxRet(nItemLine,"IT_SPED")
		If lL2Modbc
			If Len(aModBc) > 0
				cModBC := aModBc[1][6]
			EndIf
	
			IIf(lRet , lRet := STDSPBasket( "SL2", "L2_MODBC", cModBC, nItemLine ) ,)
		EndIf
	
		If SL2->(ColumnPos( "L2_DESCICM" )) > 0 .And. SL2->(ColumnPos( "L2_MOTDICM" )) > 0
			/* 
			-- Validação conforme a MatxFis --
						
			Conforme o link https://centraldeatendimento.totvs.com/hc/pt-br/articles/360025687693
									-MP-NFE-934-Rejeição-Não-informado-valor-do-ICMS-desonerado-ou-o-Motivo-de-desoneração
			
			o campo D2_DESCICM será gravado dependendo da forma 
			que a TES é configurada e na NF-e o valor da TAG vICMSDeson é enviada 
			pois a tabela CD2 é gravada nesse momento
			
			Porem para a NFC-e, envio somente usamos o campo L2_DESCICM com isso
			o campo deve ser gravado a partir somente de qualquer configuração de TES
			
			Por isso o campo D2_DESCICM não teve sua gravação alterada no LOJXFUNC		
			*/
			cLF_MOTICMS := Alltrim(STBTaxRet(nItemLine,"LF_MOTICMS"))
			If !Empty(cLF_MOTICMS) .And. (Len(aModBC) > 0)
				IIf( lRet, lRet := STDSPBasket( "SL2", "L2_DESCICM", aModBc[1][26] , nItemLine ), ) 
				IIf( lRet, lRet := STDSPBasket( "SL2", "L2_MOTDICM", cLF_MOTICMS , nItemLine ), )
			EndIf 
		EndIf
	EndIf
	
	If lRet .AND. lL2CEST
		lRet := STDSPBasket( "SL2", "L2_CEST", AllTrim(STBTaxRet(nItemLine,"IT_CEST")), nItemLine )
	EndIf
	
	If lL2FECP
		IIf( lRet, lRet := STDSPBasket( "SL2", "L2_VALFECP", STBTaxRet(nItemLine,"IT_VALFECP") , nItemLine ), ) 
		IIf( lRet, lRet := STDSPBasket( "SL2", "L2_ALQFECP", STBTaxRet(nItemLine,"IT_ALIQFECP"), nItemLine ), ) 
	EndIf
	
	If lL2FECPST
        IIf( lRet, lRet := STDSPBasket( "SL2", "L2_VFECPST", STBTaxRet(nItemLine,"IT_VFECPST") , nItemLine ), ) 
        IIf( lRet, lRet := STDSPBasket( "SL2", "L2_ALQFCST", STBTaxRet(nItemLine,"IT_ALFCST")  , nItemLine ), ) 
    EndIf

	If lRet .And. lLjNfPafEcf
		If SL2->(ColumnPos("L2_IAT")) > 0
			lRet := STDSPBasket( "SL2" , "L2_IAT", IIf( STBRuleArred() == "R", "A", "T" ) , nItemLine)
		EndIf
		
		If lRet .And. SL2->(ColumnPos("L2_IPPT")) > 0
			lRet := STDSPBasket( "SL2" , "L2_IPPT",  AllTrim(aInfoItem[ITEM_IPPT]) , nItemLine)
		EndIf

		If lRet .And. SL2->(ColumnPos("L2_DECQTD")) > 0
			lRet := STDSPBasket( "SL2" , "L2_DECQTD",  TamSX3("L2_QUANT")[2]  , nItemLine)
		EndIf
		
		If lRet .And. SL2->(ColumnPos("L2_DECVLU")) > 0
			lRet := STDSPBasket( "SL2" , "L2_DECVLU",  TamSX3("L2_VRUNIT")[2]  , nItemLine)
		EndIf
		
		lRet := lRet .And. STDSPBasket( "SL2" , "L2_CONTDOC",  STDGPBasket( "SL1" , "L1_CONTDOC" )  , nItemLine)
	EndIf

	//Serie do PDV
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_SERPDV"	, STFGetStat("SERPDV"), nItemLine) ,)
	
	/*/
		Atualiza valores MATXFIS
	/*/
	If lRet
		STBRefshItBasket( nItemLine, aInfoItem, lItImpRDPT)
	EndIf	
	
	If lRet .AND. lCAT83
		// grava o campo da tabela CDZ gravado na TES q serve para apuracao do Credito pelo FISCO
		lRet := STDSPBasket( "SL2" , "L2_CODLAN"					, STBGetTESInfo( "F4_CODLAN" , AllTrim(STBTaxRet(nItemLine,"IT_TES"))    )	  , nItemLine  	) 
	EndIf

	// Ajusta situacao tributaria para gravacao   
	If lRet
		cItemSitTrib := STBTaxSit(nItemLine) 
		lRet := STDSPBasket( "SL2" , "L2_SITTRIB"					, STBStAdjust( cItemSitTrib )    						, nItemLine  	)
	EndIf	

	/*/
		Mostruário Saldão
	/*/
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VDMOST"				, aMostruario[1]    						, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VDOBS"					, aMostruario[2]    						, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_ITEMSD1"				, "000000"									, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VENDIDO"				, "S"										, nItemLine  	) ,)
	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_GRADE"					, "N"            						, nItemLine  	) ,)

	//Recarga do cartao fidelidade processada:   //TODO: precisa ser Imprementado	: Leandro
	If lLjcFid
		If FA271aGrcf()
			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_PRODUTO"					, "cCodProd"          						, nItemLine  	) ,)
			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_NUMCFID"					, LaFunhGet(1)         						, nItemLine  	) ,)
			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_DTSDFID"					, LaFunhGet(2)         						, nItemLine  	) ,)
			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_DTSDFID"					, LaFunhGet(3)         						, nItemLine  	) ,)

			If Ca280CkWs ()
				//W - Via WebService(LJCCARFID)
				IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_PROCFID"					, "W"         						, nItemLine  	) ,)
				Fa271aSpfw (.T.)
			Else
				//B - Via processo batch (LJGRVBATCH)
				IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_PROCFID"					, "B"         						, nItemLine  	) ,)
				Fa271aSpfw (.F.)
			EndIf
		EndIf
	EndIf

	IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_SITUA"					, "04"    , nItemLine  	)   ,) 	// "04" - Impresso o Item

	// Atualizar dados no cabecalho - SL1
	IIf(lRet , lRet := STDSPBasket( "SL1" , "L1_SITUA"					, "04" ) 	 ,)	// "04" - Impresso o Item

	// Salva venda como orcamento 
	If lSaveOrc
		   	   	
		If !SuperGetMv("MV_LJCNVDA",, .F.)
			IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_TABELA" 	, Padr( AllTrim(SuperGetMv("MV_TABPAD")) , SL2->(TamSx3("L2_TABELA")[1])) , nItemLine ) ,)
		EndIf
		
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_ENTREGA" 	, "2" , nItemLine ) ,)
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VENDIDO" 	, "" , nItemLine ) ,)
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_DOC" 		, "" , nItemLine ) ,)
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_SERIE" 	, "" , nItemLine ) ,)
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_PDV" 		, "" , nItemLine ) ,)
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_SITUA" 	, "" , nItemLine ) ,)
	EndIf

Else
	If !lDate
		STFMessage("ItemRegistered","STOP",STR0002)//"A data do sistema esta diferente da data do sistema operacional. Atenção! Favor efetuar o logoff do sistema"
	Endif
	lRet := .F.
EndIf

//--------------------------------------
// Restaura Rows, Atualiza View
//--------------------------------------
FWRestRows( aSaveLines ) 

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSearchPrice
Busca o preco do produto para exibi-lo na tela.

@param  cItemCode	, caractere, Código do Item
@param  cCliCode	, caractere, Código do Cliente
@param  cCliLoja	, caractere, Código da Loja

@author  Varejo
@version P11.8
@since   26/09/2012
@return  nPrice , numérico, Preco do item
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSearchPrice(cItemCode , cCliCode, cCliLoja )

Local aFindItem 	:= {}			// Array da bisca de itens
Local nPrice		:= 0			// PReco

Default  cItemCode 	:= ""
Default  cCliCode 	:= "" 
Default  cCliLoja 	:= ""



aFindItem	:= STWFindItem( cItemCode ) 
		
// Encontrou o item?
If aFindItem[ITEM_ENCONTRADO]	
	
	/*/
		2 - Busca preco do item caso nao tenha sido informada por parametro 
	/*/
	If nPrice <= 0

		nPrice 	:= STWFormPr( 	aFindItem[ITEM_CODIGO], cCliCode, /*filial*/, cCliLoja,/*nMoeda*/, STBGetQuant() )

		//	Se a tabela de preço utilizada esta fora de vigência
		If nPrice == -999		// Verifica se tabela de preço esta dentro da vigencia
			LjGrvLog(aFindItem[ITEM_CODIGO],"STBSearchPrice | Item não poderá ser registrado, motivo: Tabela de preço fora de vigência.")
			lRet := .F.
			STFMessage("ItemRegistered","STOP", STR0003 + CHR(13)+CHR(10) + STR0004) //"Tabela de preço fora de vigência."  "Verifique o código da tabela contido no parâmetro MV_TABPAD"
		
		ElseIf nPrice <= 0	//Se nao achou preco
			lRet := .F.
			STFMessage("ItemRegistered","STOP",STR0001) //"Preço não encontrado"
			STFShowMessage("ItemRegistered")
		EndIf
												
	EndIf	
	
EndIf

Return nPrice


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSearchPrice
Busca o preco do produto para exibi-lo na tela.

@param   nItemLine		Linha do Item
@author  Varejo
@version P11.8
@since   26/09/2012
@return  lRet - Retorna se encontrou o preco
@obs
@sample
/*/ 
//-------------------------------------------------------------------
Function STBRefshItBasket( nItemLine, aInfoItem, lRgDescVrj )
Local lRet						:= .T.		// Retorno função
Local aTesImpInf				:= {}		// Array de Aliquotas de Imposto por TES
Local cIndImp					:= 0		// Posição do imposto variável
Local nX						:= 0		// Contador de for
Local aAlqLeiTr					:= {0,0,0,0,}												//array utilizado para pegar as aliquotas das lei dos impostos
Local cMvFisCTrb				:= SuperGetMV("MV_FISCTRB",,"1")	// Informar metodo de consulta do percentual de carga tributaria.Informe 1 para tratamento legado ou 2 aliquotas da Nota Fiscal e CGA/CGB.                 
Local cMvFisAlCT				:= SuperGetMV("MV_FISALCT",,"3")	// Informar qual o metodo de composicao da carga tributaria quando MV_FISCTRB = 2.                      
Local nIt_Total					:= 0		// valor total somado ao acrescimo, já que a MATXFIS nao retorna o valor do acrescimo somado ao IT_TOTAL
Local nFrtSegDes                := 0        // O valor do Frete Seguro e Despesa tem que ser subitraido do valor do item
Local nItAcresci				:= 0 		// Valor do acréscimo financeiro para a condição de pagamento
Local nItDedICMS				:= 0 		// Valor da desoneração do icms
Local lUseSat					:= STFGetCfg("lUseSAT",.F.)  //Usa SAT?
Local lExistGetTriSat 			:= lUseSat .AND. (ExistFunc("LjGetTriSat") .AND. ExistFunc("LjSetTriSat"))	//Armazenamento para XML SAT
Local aSATTrib					:= {}										//Tributação produto SAT
Local lCfgTrib                  as logical //Verifica se Configurador de Tributos esta habilitado
Local jCfgTaxes                 as json //Configurador de Tributos
Local aAgregTot                 as array

Default nItemLine 				:= 0
Default aInfoItem 				:= {}
Default lRgDescVrj 				:= .F.

lCfgTrib  := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.)
jCfgTaxes := JsonObject():New()

If nItemLine <= STDPBLength("SL2")
	lRet := .T.
EndIf

If lRet	
	If  SL2->(ColumnPos( "L2_DESCICM" )) > 0 	
		nItDedICMS :=  STBTaxRet(nItemLine,"IT_DEDICM")  
	EndIf
	nItAcresci	:= STBTaxRet(nItemLine, "IT_ACRESCI")
	nFrtSegDes 	:= STBTaxRet(nItemLine,"IT_FRETE") + STBTaxRet(nItemLine,"IT_SEGURO") + STBTaxRet(nItemLine,"IT_DESPESA") 
	nIt_Total 	:= STBTaxRet(nItemLine, "IT_TOTAL") - nFrtSegDes + nItDedICMS

	If lCfgTrib
		aAgregTot := LjCfgSetTot("", nItemLine)
		nIt_Total -= aAgregTot[1]
		nIt_Total += aAgregTot[2]
	EndIf		
	
	jCfgTaxes := If(lCfgTrib, STBGetTax("000022", nItemLine), JsonObject():New()) //Configurador de Tributos - Id IPI = 000022
			
	If Len(jCfgTaxes) > 0
		If STBVerTotTax("000022", 1)
			nIt_Total -= STBTaxRet(nItemLine,"IT_VALIPI")
		EndIf
	Else //Legado TES		
		nIt_Total -= STBTaxRet(nItemLine,"IT_VALIPI")
	EndIf

	// Quando ICM solidário NÃO agrega valor no total, não deve subtrair		
	jCfgTaxes := If(lCfgTrib, STBGetTax("000056", nItemLine), JsonObject():New()) //Configurador de Tributos - Id ICMS-ST = 000056

	If Len(jCfgTaxes) > 0
		If STBVerTotTax("000056", 1)
			nIt_Total -= STBTaxRet(nItemLine, "IT_VALSOL") // Subtrai valor do ICMS ST
		EndIf		
	ElseIf AllTrim(STBGetTESInfo( "F4_INCSOL" , AllTrim(STBTaxRet(nItemLine,"IT_TES")))) <> "N" //Legado TES 
		nIt_Total -= STBTaxRet(nItemLine, "IT_VALSOL") // Subtrai valor do ICMS ST
	Endif 

	STDSPBasket( "SL2" , "L2_QUANT"					, STBTaxRet(nItemLine,"IT_QUANT"						)		, nItemLine  	)
	
	If Empty(STBTaxRet(nItemLine,"IT_DESCONTO")) .AND. Empty(nItAcresci) .AND. Empty(STBTaxRet(nItemLine,"IT_DESCTOT"))
		STDSPBasket( "SL2" , "L2_VRUNIT"			, STBTaxRet(nItemLine,"IT_PRCUNI"), nItemLine)
	Else 
		STDSPBasket( "SL2" , "L2_VRUNIT"			, nIt_Total / STBTaxRet(nItemLine,"IT_QUANT"), nItemLine)
	EndIf 
	
	STDSPBasket( "SL2" , "L2_VLRITEM"				, nIt_Total													, nItemLine  	)

	STDSPBasket( "SL2" , "L2_DESCPRO"				, STBTaxRet(nItemLine,"IT_DESCTOT"					)			, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALDESC"				, STBTaxRet(nItemLine,"IT_DESCONTO"					)		, nItemLine  	) // Valor do Desconto	
	STDSPBasket( "SL2" , "L2_DESC"					, STBDiscConvert( STBTaxRet(nItemLine,"IT_DESCONTO") , "V" , STBTaxRet(nItemLine,"IT_VALMERC") )[2]		, nItemLine  	) // Percentual de desconto

	If lRgDescVrj
		STDSPBasket( "SL2" , "L2_VLDRGDV"				, STBTaxRet(nItemLine,"IT_DESCONTO"					)		, nItemLine  	) // Valor do Desconto	
	EndIf

	STDSPBasket( "SL2" , "L2_TES"					, AllTrim(STBTaxRet(nItemLine,"IT_TES"			  ))		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_CF"					, AllTrim(STBTaxRet(nItemLine,"IT_CF"				  ))		, nItemLine  	) // Codigo Fiscal de Operacao
	STDSPBasket( "SL2" , "L2_VALACRS"				, nItAcresci													, nItemLine  	) //Acréscimo financeiro
	
	//Impostos		
	STDSPBasket( "SL2" , "L2_VALIPI"				, STBTaxRet(nItemLine,"IT_VALIPI"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALISS"				, STBTaxRet(nItemLine,"IT_VALISS"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_ALIQISS"				, STBTaxRet(nItemLine,"IT_ALIQISS"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_BASEISS"				, STBTaxRet(nItemLine,"IT_BASEISS"						)		, nItemLine  	)	
	STDSPBasket( "SL2" , "L2_PRCTAB"				, STBTaxRet(nItemLine,"IT_PRCUNI"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALPIS"				, STBTaxRet(nItemLine,"IT_VALPIS"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALCOFI"				, STBTaxRet(nItemLine,"IT_VALCOF"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALCSLL"				, STBTaxRet(nItemLine,"IT_VALCSL"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_BASEPS2"				, STBTaxRet(nItemLine,"IT_BASEPS2"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALPS2"				, STBTaxRet(nItemLine,"IT_VALPS2" 						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_ALIQPS2"				, STBTaxRet(nItemLine,"IT_ALIQPS2"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_BASECF2"				, STBTaxRet(nItemLine,"IT_BASECF2"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_VALCF2"				, STBTaxRet(nItemLine,"IT_VALCF2" 						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_ALIQCF2"				, STBTaxRet(nItemLine,"IT_ALIQCF2"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_BRICMS"				, STBTaxRet(nItemLine,"IT_BASESOL"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_ICMSRET"				, STBTaxRet(nItemLine,"IT_VALSOL"						)		, nItemLine  	)
	STDSPBasket( "SL2" , "L2_BASEICM"				, STBTaxRet(nItemLine,"IT_BASEICM"						)		, nItemLine		)
	STDSPBasket( "SL2" , "L2_VALICM" 				, STBTaxRet(nItemLine,"IT_VALICM"						)		, nItemLine		)
			

	If lExistGetTriSat
		//TRIBUTACAO SAT
		aSATTrib		:= LjGetTriSat()

		STBItSatTr(@aSATTrib, nItemLine, "IT_BASEPS2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_ALIQPS2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_BASECF2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_ALIQCF2")
		STBItSatTr(@aSATTrib, nItemLine, "IT_PAUTPIS")
		STBItSatTr(@aSATTrib, nItemLine, "IT_PAUTCOF")
		STBItSatTr(@aSATTrib, nItemLine, "IT_CEST")

		//Array de tributações do SAT
		LjSetTriSat(aSATTrib)
	EndIf	

	//valores de impostos por ente tributario da lei dos impostos, na atribuicao de total na venda
	If ValType( aInfoItem ) == "A" 
		
		If Len(aInfoItem) == 0 	//caso não esteja preenchido, passara aqui. Estara vazio quando vem chamado do total da venda (F7)
			//busca as informacoes do item para passar a funcao de lei dos impostos
			aInfoItem	:= STWFindItem( STDGPBasket( "SL2" , "L2_PRODUTO" , nItemLine ) )
			If ExistFunc("STBLImpItem") .And. (Len(aInfoItem) >= 23)
				aAlqLeiTr := STBLImpItem(aInfoItem[ITEM_POSIPI]  ,aInfoItem[ITEM_EX_NCM] ,aInfoItem[ITEM_CODISS], aInfoItem[ITEM_CODIGO]  )
				
				If Len(aAlqLeiTr) == 4 .OR. !(cMvFisAlCT == "3" .AND. cMvFisCTrb == "2")
    			    //carrega as aliquotas
                  aInfoItem[ITEM_TOTIMP] := aAlqLeiTr[1] 
                  aInfoItem[ITEM_TOTFED] := aAlqLeiTr[2] 
                  aInfoItem[ITEM_TOTEST] := aAlqLeiTr[3]
                  aInfoItem[ITEM_TOTMUN] := aAlqLeiTr[4] 
				ElseIf Len(aAlqLeiTr) == 8
    				//carrega os valores
    				aInfoItem[ITEM_TOTIMP] := aAlqLeiTr[5] 
    				aInfoItem[ITEM_TOTFED] := aAlqLeiTr[6] 
    				aInfoItem[ITEM_TOTEST] := aAlqLeiTr[7]
    				aInfoItem[ITEM_TOTMUN] := aAlqLeiTr[8]    			
    			EndIf	
			EndIf
		EndIF		
		
       If aInfoItem[ITEM_TOTIMP] > 0 // se tem algum indice de lei dos impostos carregado, faz os calculos
          If Len(aAlqLeiTr) == 4 .OR. !(cMvFisAlCT == "3" .AND. cMvFisCTrb == "2")
               nItTotal := STBTaxRet(nItemLine,"IT_TOTAL")
               STDSPBasket( "SL2" , "L2_TOTIMP"             , STBRound((nItTotal * aInfoItem[ITEM_TOTIMP])/100)    , nItemLine    )
                
               //Lei dos impostos por Ente Tributario   
               If lCpoImpEnt .AND. Len(aInfoItem) >=23 //garantir que o define ITEM_TOTFED exista
                   STDSPBasket( "SL2" , "L2_TOTFED"         , STBRound((nItTotal * aInfoItem[ITEM_TOTFED])/100)    , nItemLine    )
                   STDSPBasket( "SL2" , "L2_TOTEST"         , STBRound((nItTotal * aInfoItem[ITEM_TOTEST])/100)    , nItemLine    )
                   STDSPBasket( "SL2" , "L2_TOTMUN"         , STBRound((nItTotal * aInfoItem[ITEM_TOTMUN])/100)    , nItemLine    )
               EndIf             
           ElseIf Len(aAlqLeiTr) == 8               
               STDSPBasket( "SL2" , "L2_TOTIMP"			, aInfoItem[ITEM_TOTIMP], nItemLine  	)           		
               //Lei dos impostos por Ente Tributario	
               If lCpoImpEnt .AND. Len(aInfoItem) >=23 //garantir que o define ITEM_TOTFED exista
                   STDSPBasket( "SL2" , "L2_TOTFED"		, aInfoItem[ITEM_TOTFED], nItemLine  	)
                   STDSPBasket( "SL2" , "L2_TOTEST"		, aInfoItem[ITEM_TOTEST], nItemLine  	)
                   STDSPBasket( "SL2" , "L2_TOTMUN"		, aInfoItem[ITEM_TOTMUN], nItemLine  	)
               EndIf           
           EndIf    
       EndIf	
	EndIf
	
	// Controle de impostos IVA
	aTesImpInf  := TesImpInf( AllTrim(STBTaxRet(nItemLine,"IT_TES" )))
	
	/* Estrutura do aTesImpInf
		[n][1]-> Codigo do Imposto
		[n][2]-> Campo no SD1 ou SD2 onde e gravado o valor  imposto
		[n][3]-> Se o valor do imposto incide na Nota
		[n][4]-> Se o valor do imposto incide na Duplicata
		[n][5]-> Se o valor do imposto deve ser Creditado
		[n][6]-> Campo no SF1 ou SF2 onde e gravado o valor  imposto
		[n][7]-> Campo no SD1 ou SD2 onde e gravada a base  do imposto
		[n][8]-> Campo no SF1 ou SF2 onde e gravada a base  do imposto
		[n][9]-> Aliquota do imposto
	*/
	
	If	Len(aTesImpInf) > 0
	
		For nX  := 1 To Len(aTesImpInf)
		
			//Guarda posicao do imposto corrente
			cIndImp := Substr("L2_"+Substr(aTesImpInf[nX][2],4,7),Len("L2_"+Substr(aTesImpInf[nX][2],4,7)),1)
		
			STDSPBasket( "SL2" , "L2_BASIMP"+cIndImp				, STBTaxRet( nItemLine,"IT_BASEIV"+	cIndImp	)	, nItemLine  	)
			STDSPBasket( "SL2" , "L2_VALIMP"+cIndImp				, STBTaxRet( nItemLine,"IT_VALIV"+		cIndImp	)	, nItemLine  	)
			STDSPBasket( "SL2" , "L2_ALQIMP"+cIndImp				, STBTaxRet( nItemLine,"IT_ALIQIV"+	cIndImp	)	, nItemLine  	)
		
		Next nX
	
	EndIf

EndIf

STBSetDefQuant()	// Seta quantidade padrao apos o registro de item
STBDefItDiscount()	// Seta desconto padrao apos registro de item

FreeObj(jCfgTaxes)
jCfgTaxes := Nil

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STBDataBar
Faz a leitura a interpretacao do codigo de barras
GS1 Data Bar
@param   Codigo Capturado pelo leitor
@author  Varejo
@version P11.8
@since   08/10/2013
@return  aReturn - Retorna codbar e data validade
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBDataBar(cCodDtaBar) 

Local cSymbolId := ""	// Simbolo identificador do tipo de cod bar
Local cAI		:= ""   // Application Identifiers
Local aReturn	:= {}   // Retorno da funcao em 2 dimensoes
Local cCodBar	:= ""   // Codigo de barras no padrao EAN 13
Local dDtValid	:= ""   // Data de validade do produto

DEFAULT cCodDtaBar := ""

//Separa os simbolos do databar, verifique o documento 
//Databar_GS1_General_Specifications_v13_Identificador_de_Simbologia.pdf (deve ser solicitado a GS1)
cSymbolId  	:= Substr(cCodDtaBar,1,3) 
cCodDtaBar 	:= Substr(cCodDtaBar,4,Len(cCodDtaBar)) 
cCodBar 		:= cCodDtaBar

If UPPER(cSymbolId) == "[E0" 	//GS1 DataBar

	While Len(cCodDtaBar) > 0
		cAI 	:= Substr(cCodDtaBar,1,2)

		If cAI == "01" 				// Tradicional EAN 13
			cCodBar		:= Substr(cCodDtaBar,4,13)
			cCodDtaBar  := Substr(cCodDtaBar,17,Len(cCodDtaBar))// Remove o trecho capiturado
			
		ElseIf cAI == "17"			// Data de Validade YYMMDD
			dDtValid	:=  STOD("20"+Substr(cCodDtaBar,3,6) )
			cCodDtaBar  := Substr(cCodDtaBar,9,Len(cCodDtaBar))	// Remove o trecho capiturado
		Else
			//Para esse primeiro modelo nao foram desenvolvidos todos os codigos AIs
			cCodDtaBar  := ""
		EndIf
	End
Else
	cCodBar 	:= cSymbolId + cCodDtaBar   // Caso nao encontre retorna o mesmo cod
EndIf

AAdd( aReturn, { cCodBar  }) // Tradicional EAN 13
AAdd( aReturn, { dDtValid }) // Data de Validade

Return(aReturn)


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSaleAct
Funcao responsavel em verificar se uma venda esta em andamento ou nao
@param   lActive
@author  Varejo
@version P11.8
@since   08/10/2013
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSaleAct(lActive)
Default lActive := .F.
lSaleActive := lActive
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} STBGetAct
Funcao para retornar o valor da lSaleActive
@param   
@author  Varejo
@version P11.8
@since   08/10/2013
@return  lSaleActive
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBGetAct()
Return lSaleActive 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBPegaIT
Transforma o Numero Item Para 2 Bytes.
@param   
@author  Varejo
@version P11.8
@since   08/10/2013
@return  lSaleActive
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBPegaIT(uItem)

Local nX          := 0                         // Contador de For
Local nY          := 0                         // Contador de For
Local aTemp       := {}                        // Array temporario
Local nTamSd2It   := TamSX3("D2_ITEM")[1] //Tamanho do campo D2_ITEM
Local aItems := {} //Guarda o item para verificar o L2_ITEM

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se o campo for caracter transformar em maiusculo por segurança³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(uItem) == "C"
   uItem := Upper( Right(uItem, nTamSd2It) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o Array Somente uma Vez³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aItems) == 0                
      aTemp := {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
      For nX := Asc("A") To Asc("Z")
            AAdd(aTemp, Chr(nX))
      Next
      For nX := 1 To 99
            AAdd(aItems, StrZero(nX,2,0))
      Next

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³Tratamento para o MV_SOMAOLD³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If SuperGetMV("MV_SOMAOLD",NIL,.F.)
            For nX := Asc("A") To Asc("Z")
                  For nY := 1 To Len(aTemp)
                        AAdd(aItems, Chr(nX)+aTemp[nY])
                  Next
            Next
    Else
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³Tratamento para quando o MV_SOMAOLD for falso³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            For nX := Asc("A") To Asc("Z")
                  AAdd(aItems, "9" + chr(nX))
            Next

            For nX := Asc("A") To Asc("Z")
                  For nY := 1 To Len(aTemp)
                        AAdd(aItems, Chr(nX)+aTemp[nY])
                  Next
            Next
    
    EndIf
EndIf
If ValType(uItem) == "N"
      uRet := aItems[uItem]
ElseIf ValType(uItem) == "C"
      uRet := AScan(aItems, uItem)
EndIf

Return(uRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} STBSumItem
Soma o item registrado.
@param   lItemFisc - Item Fiscal
@param	  nItemLine - Numero do Item
@author  Varejo
@version P11.8
@since   15/12/2014
@return  nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBSumItem(lItemFisc, nItemLine)
Local nItem := 0 //Numero do Contador
Local cItem := "" //Codigo do Item

Default lItemFisc 	:= .T.
Default nItemLine := 0

If lItemFisc
	nItem :=  STDGPBasket("SL1","L1_TOTFISC")+1   
	STDSPBasket("SL1","L1_TOTFISC", nItem)	
	cItem := STBPegaIT(nItem) 	 
	STDSPBasket("SL2", "L2_ITFISC",cItem, nItemLine)
	
Else
	nItem :=  STDGPBasket("SL1","L1_TOTNFIS")+1
	STDSPBasket("SL1","L1_TOTNFIS", nItem)	
	cItem := STBPegaIT(nItem)  
	STDSPBasket("SL2", "L2_ITNFISC", cItem, nItemLine)
EndIf         		 

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} STBLImpItem
Lei dos impostos para o cupom 
@param   lItemFisc - Item Fiscal
@author  Varejo
@version P11.8
@since   27/04/2015
@return  nil
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBLImpItem(cPOSIPI,cEX_NCM,cCODISS,cCODIGO)

Local 			xB1ImpNcm		:= Nil								// variavel que controla o retorno da função AlqLei2741
Local 			lAlqLei2741	:=  FindFunction("AlqLei2741")		// Funcao desenvolvida pelo fiscal para tratar a lei dos impostos 	
Local 			aAlqLeiTr		:= {}								// array com valores da  aliquota retornado pela função fiscal (Lei transparência) 1-Aliq Total|2-Aliq Federal|3-Aliq Estadual|4-Aliq Municipal
Local			lCpoTotImp		:= (SL2->(ColumnPos("L2_TOTIMP")) > 0) .And. (SB1->(ColumnPos("B1_IMPNCM")) > 0)
Local         nIMPNCM 		:= 0
Local			cB1CodISS		:= ""
Local 			aArea		:= {}

xB1ImpNcm := 0 

// nova funcionalidade disponibilizada pelo Fiscal
If lAlqLei2741 
	xB1ImpNcm := 0 
	aArea	:=	GetArea()
	 
	xB1ImpNcm := AlqLei2741(cPOSIPI          ,cEX_NCM           ,cCODISS                      ,SA1->A1_EST, ;
	                        SA1->A1_COD_MUN  ,cCODIGO           ,1 /*Ref Item prod Matxfis*/  ," "        , ;
	                        /*cLoteCtl*/     ,/*cMvFisCTrb */   ,/*cMvFisAlCT*/               ,/*lMvFisFRas*/)	
	                        
	RestArea(aArea)	
Else
	
	If lCpoTotImp    
		nIMPNCM 	:= RetFldProd(SB1->B1_COD,"B1_IMPNCM")
		xB1ImpNcm 	:= Iif(Empty(nIMPNCM ), SB1->B1_IMPNCM, nIMPNCM ) 
	EndIf		
					
	If Findfunction("Lj7BuscaImp")
		If xB1ImpNcm ==0 .AND. !Empty(SB1->B1_POSIPI)
			cB1CodISS	:= RetFldProd(SB1->B1_COD,"B1_CODISS")
			cB1CodISS 	:= Iif(Empty(cB1CodISS), SB1->B1_CODISS, cB1CodISS)
			xB1ImpNcm	:= Lj7BuscaImp(SB1->B1_POSIPI,!Empty(cB1CodISS),.F.)
		EndIf		
	EndIF
	
EndIf

If ValType(xB1ImpNcm) == "N"
	aAlqLeiTr := {xB1ImpNcm,0,0,0}
ElseIf Len(xB1ImpNcm) == 2
	aAlqLeiTr := {xB1ImpNcm[1],0,0,0,xB1ImpNcm[2],0,0,0}
Else	
	aAlqLeiTr := aClone(xB1ImpNcm)
EndIf

Return aAlqLeiTr 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBAjustIT
Essa função tem o objetivo realizar os ajustes nos itens:
ajuste no ICMS ao aplicar o desconto.

@param
@author  Rene Julian
@version P12117
@since   31/10/2018
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBAjusICM()
Local nI		:= 0
Local lRet		:= .T.

For nI := 1 To STDPBLength("SL2")

	If !STDPBIsDeleted( "SL2", nI )
		
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_BASEICM"	, STBTaxRet(nI ,"IT_BASEICM")	, nI	)	,)
		IIf(lRet , lRet := STDSPBasket( "SL2" , "L2_VALICM"		, STBTaxRet(nI ,"IT_VALICM")	, nI	)	,)
		IIf( lRet, lRet := STDSPBasket( "SL2" , "L2_VALFECP"	, STBTaxRet(nI,"IT_VALFECP") 	, nI	)	,) 	    

	EndIf	
			
Next nI

If lRet 
	LjGrvLog(SL1->L1_NUM ,"STBAjusICM - Ajustado da base e valor do ICMS")
Else
	LjGrvLog(SL1->L1_NUM ,"STBAjusICM - Não foi possivel o Ajustate da base e valor do ICMS")
EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} STBItSatTr
Essa função tem o objetivo armazenar base de cálculo e valor dos
 impostos Pis, Cofins, CST, etc...

@author  Marisa Cruz
@version P12.1.27
@since   02/04/2020

@param	aSatTrib, Array		, Referência criada para impostos PIS/COFINS/CST etc e transmitido pelo XML do SAT
@param	nItem	, Numérico	, número do item do TOTVS PDV
@param 	cCpo	, Carácter	, qual campo do MATXFIS deverá ser lido
@return  nil

@obs
@sample
/*/
//-------------------------------------------------------------------
Function STBItSatTr(aSatTrib, nItem, cCpo)

Local	nPos		:= 0

Default aSatTrib	:= {}			//Parâmetro de Referência
Default nItem	 	:= 0
Default cCpo		:= ""

nPos := aScan(aSATTrib, {|x| x[1] == nItem .And. x[2] == cCpo } )
If nPos > 0 .AND. Len(aSatTrib[nPos]) > 3
	aSatTrib[nPos][3] := STBTaxRet(nItem, cCpo)		//Valor do imposto
	If Len(aSatTrib[nPos]) >= 4 .AND. aSatTrib[nPos][4] <= 0
	 	aSatTrib[nPos][4] := nItem
	EndIf
Else
	aAdd(aSATTrib, {nItem,cCpo,STBTaxRet(nItem, cCpo),nItem})
EndIf

Return nil
