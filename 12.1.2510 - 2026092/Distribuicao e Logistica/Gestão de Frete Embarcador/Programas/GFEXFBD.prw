#INCLUDE 'PROTHEUS.CH'
 
//---------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} GFEXFBD
//TODO Função principal para fonte ser listado nos fontes do TDS
@author André Luis W
@since 02/04/18
@version 1.0
/*///------------------------------------------------------------------------------------------------
function GFEXFBD()
	/* **********************************
		AS VARIAVEIS UTILIZADAS NESTE FONTE DEVE SER 
		DECLARADAS COMO PRIVATE NO FONTE CHAMADOR
	   ********************************** */
return


CLASS GFEXFBTempTable FROM LongNameClass
    
	DATA aStructTable
	DATA aStructIndice
	DATA cTableName
	
	METHOD New() CONSTRUCTOR
	METHOD Destroy(oObject)
	METHOD ClearData()
	
	METHOD setTableStruct(aStructTable)
	METHOD setIndiceStruct(aStructIndice)
	METHOD setTableName(cTableName)

	METHOD getTableStruct()
	METHOD getIndiceStruct()
	METHOD getTableName()

	METHOD setAgrupadoresCarga()		//GetStrAgr
	METHOD setDocumentoCarga() 			//GetStrDoc
	METHOD setGrupoEntrega() 			//GetStrGrup
	METHOD setUnidadeCalculo() 			//GetStrUNC
	METHOD setTabelaCalculoFrete() 		//GetStrTCF
	METHOD setTrechoCarga() 			//GetStrTRE
	METHOD setItensCarga() 				//GetStrITE
	METHOD setComponenteCalculoFrete() 	//GetStrCCF
	METHOD setLocalUnidadeCalculo() 	//GetStrENT
	METHOD setSelecaoTabelaFrete() 		//GetStrSTF
	METHOD setSimulacaoFrete() 			//GetStrSIM
	METHOD setCalculoPedagio() 			//GetStrPED
	
	METHOD CriaTempTable()

ENDCLASS

METHOD New() Class GFEXFBTempTable
	Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFEXFBTempTable
	FreeObj(oObject)
Return

METHOD ClearData() Class GFEXFBTempTable
	Self:aStructTable	:= {}
	Self:aStructIndice	:= {}
	Self:cTableName		:= ''
Return

METHOD setTableStruct(aStructTable) CLASS GFEXFBTempTable
   Self:aStructTable := aStructTable
Return

METHOD setIndiceStruct(aStructIndice) CLASS GFEXFBTempTable
   Self:aStructIndice := aStructIndice
Return

METHOD setTableName(cTableName) CLASS GFEXFBTempTable
   Self:cTableName := cTableName
Return

METHOD getTableStruct() CLASS GFEXFBTempTable
Return Self:aStructTable

METHOD getIndiceStruct() CLASS GFEXFBTempTable
Return Self:aStructIndice

METHOD getTableName() CLASS GFEXFBTempTable
Return Self:cTableName

METHOD setAgrupadoresCarga() Class GFEXFBTempTable //GetStrAgr

	Self:setTableStruct({	{"NRAGRU","C",10 ,0},; //Numero do Agrupador
							{"CDTRP" ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Transportador
							{"CDTPVC","C",10 ,0},; //Tipo de Veiculo
							{"CDCLFR","C",04 ,0},; //Classificacao de Frete
							{"CDTPOP","C",10 ,0},; //Tipo de Operacao
							{"DISTAN","N",TamSX3("GWN_DISTAN")[1] ,TamSX3("GWN_DISTAN")[2]},; //Distancia Percorrida
							{"NRCIDD","C",TamSx3("GWN_NRCIDD")[1] ,0},; //Cidade Destino
							{"CEPD"  ,"C",08 ,0},;  //CEP Destino
							{"ERRO"  ,"C",1 ,0}})//Parametro criado para verificação de erro no momento da montagem do cálculo do romaneio

	Self:setIndiceStruct({"NRAGRU"})

Return

METHOD setDocumentoCarga() Class GFEXFBTempTable //GetStrDoc

	Self:setTableStruct({	{"EMISDC","C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente do Documento
							{"SERDC" ,"C",TamSX3("GW1_SERDC")[1] ,0},; //Serie do Documento
							{"NRDC"  ,"C",TamSX3("GW1_NRDC")[1] ,0},; //Numero do Documento
							{"CDTPDC","C",TamSX3("GW1_CDTPDC")[1] ,0},; //Tipo do Documento
							{"CDREM" ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Remetente do Documento
							{"CDDEST","C",TamSX3("GU3_CDEMIT")[1] ,0},; //Destinatario do Documento
							{"ENTEND","C",50 ,0},; //Endereco de Entrega
							{"ENTBAI","C",50 ,0},; //Bairro de entrega
							{"ENTNRC","C",50 ,0},; //Cidade de Entrega
							{"ENTCEP","C",08 ,0},; //CEP de Entrega
							{"NRREG" ,"C",06 ,0},; //Região de destino
							{"TPFRET","C",01 ,0},; //Tipo de Frete
							{"ICMSDC","C",01 ,0},; //ICMS?
							{"USO"   ,"C",01 ,0},; //Finalidade da mercadoria
							{"CARREG","C",12 ,0},; //Número do carregamento
							{"NRAGRU","C",10 ,0},; //Numero do Agrupador
							{"QTUNIT","N",TamSX3("GW8_QTDE")[1],TamSX3("GW8_QTDE")[2]}})  //Quantidade de Unitizadores

	Self:setIndiceStruct({"NRAGRU","CDTPDC+EMISDC+SERDC+NRDC"})
Return

METHOD setGrupoEntrega() Class GFEXFBTempTable //GetStrGrup

	Self:setTableStruct({{"NRGRUP","C",06 ,0},; //Numero do grupo subdividido
						{"EMISDC","C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente do Documento
						{"SERDC" ,"C",TamSX3("GW1_SERDC")[1] ,0},; //Serie do Documento
						{"NRDC"  ,"C",TamSX3("GW1_NRDC")[1] ,0},; //Numero do Documento
						{"CDTPDC","C",TamSX3("GW1_CDTPDC")[1] ,0},; //Tipo do Documento
						{"CDREM" ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Remetente do Documento
						{"CDDEST","C",TamSX3("GU3_CDEMIT")[1] ,0},; //Destinatario do Documento
						{"ENTEND","C",50 ,0},; //Endereco de Entrega
						{"ENTBAI","C",50 ,0},; //Bairro de entrega
						{"ENTNRC","C",50 ,0},; //Cidade de Entrega
						{"ENTCEP","C",08 ,0},; //CEP de Entrega
						{"NRREG" ,"C",06 ,0},; //Região de destino
						{"TPFRET","C",01 ,0},; //Tipo de Frete
						{"USO"   ,"C",01 ,0},; //Finalidade da mercadoria
						{"CARREG","C",12 ,0},; //Número do carregamento
						{"NRAGRU","C",10 ,0},; //Numero do Agrupador
						{"QTUNIT","N",TamSX3("GW8_QTDE")[1],TamSX3("GW8_QTDE")[2]}})  //Quantidade de Unitizadores

	Self:setIndiceStruct({ "NRAGRU+CDREM+CDDEST+CDTPDC+TPFRET+NRREG+USO+CARREG+ENTNRC+ENTBAI+ENTEND",;
						"CDTPDC+EMISDC+SERDC+NRDC",;
						"NRGRUP",;
						"NRAGRU+CDREM+CDDEST+ENTNRC+ENTBAI+ENTEND"})

Return

METHOD setUnidadeCalculo() Class GFEXFBTempTable //GetStrUNC

	Self:setTableStruct({{"NRCALC", "C", 06, 0},; //Numero da Unidade de Calculo
						{"NRLCENT","C",06 ,0},; // Local Entrega
						{"TIPO"  , "C", 01, 0},; //Tipo (1=Normal, 6=Redespacho)
						{"FINALI", "C", 01, 0},; //Finalidade (1=CTRC, 2=NFS, 3=Contrato)
						{"DTPREN", "D", 08, 0},; //Data Previsão de Entrega
						{"HRPREN", "C", 05, 0},; //Hora Previsao de Entrega
						{"TPTRIB", "C", 01, 0},;
						{"BASICM", "N", TamSX3("GWF_BASICM")[1], TamSX3("GWF_BASICM")[2]},;
						{"PCICMS", "N", TamSX3("GWF_PCICMS")[1], TamSX3("GWF_PCICMS")[2]},;
						{"VLICMS", "N", TamSX3("GWF_VLICMS")[1], TamSX3("GWF_VLICMS")[2]},;
						{"ICMRET", "N", TamSX3("GWF_ICMRET")[1], TamSX3("GWF_ICMRET")[2]},; // Valor de ICMS retido, quando tributacao presumida
						{"BASISS", "N", TamSX3("GWF_BASISS")[1], TamSX3("GWF_BASISS")[2]},;
						{"PCISS" , "N", TamSX3("GWF_PCISS" )[1], TamSX3("GWF_PCISS" )[2]},;
						{"VLISS" , "N", TamSX3("GWF_VLISS" )[1], TamSX3("GWF_VLISS" )[2]},;
						{"BAPICO", "N", TamSX3("GWF_BAPICO")[1], TamSX3("GWF_BAPICO")[2]},;
						{"VLPIS" , "N", TamSX3("GWF_VLPIS" )[1], TamSX3("GWF_VLPIS" )[2]},;
						{"VLCOFI", "N", TamSX3("GWF_VLCOFI")[1], TamSX3("GWF_VLCOFI")[2]},;
						{"PCREIC", "N", TamSX3("GWF_PCREIC")[1], TamSX3("GWF_PCREIC")[2]},; // Percentual de redução de ICMS
						{"VALTAB", "L", 01, 0},; // Tabela esta valida
						{"NRAGRU", "C", 10, 0},; // Numero do agrupador
						{"IDFRVI", "C", 01, 0},; // Indica se o calculo foi gerado por frete viagem
						{"SEQTRE", "C", 02, 0},; // Trecho ao qual o calculo está relacionado
						{"CALBAS", "C", 06, 0},; // Calculo base (usado na simulacao)
						{"ADICIS", "C", 01, 0},;
						{"CHVGWU", "C", 160, 0},;	// Chave da tabela de Trechos (GWU)
						{"GRURAT", "C", 20, 0}}) // Será utilizado para determinar um separador de grupo para rateio

	Self:setIndiceStruct({"NRCALC","NRAGRU+NRCALC","NRAGRU+SEQTRE+NRCALC","NRLCENT"})

Return

METHOD setTabelaCalculoFrete() Class GFEXFBTempTable //GetStrTCF

	Self:setTableStruct({{"NRCALC","C",06 ,0},; //Numero do Calculo
						{"CDCLFR"   ,"C",04 ,0},; //Classificacao de Frete
						{"CDTPOP"   ,"C",10 ,0},; //Tipo de Operacao
						{"SEQ"      ,"C",04 ,0},; //Sequencia
						{"DTVIGE"   ,"D",08 ,0},; //Data de Vigencia
						{"ITEM"     ,"C",16 ,0},; //Item
						{"CDTRP"    ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Transportador do agrupamento
						{"NRTAB"    ,"C",06 ,0},; //Numero da Tabela
						{"NRNEG"    ,"C",06 ,0},; //Numero da Negociacao
						{"CDFXTV"   ,"C",04 ,0},; //Seq. Faixa
						{"CDTPVC"   ,"C",10 ,0},; //Tipo de Veiculo
						{"NRROTA"   ,"C",04 ,0},; //Rota
						{"QTCALC"   ,"N",TamSX3("GW8_QTDE"  )[1],TamSX3("GW8_QTDE"  )[2]},; //Quantidade para calculo
						{"QTDE"     ,"N",TamSX3("GW8_QTDE"  )[1],TamSX3("GW8_QTDE"  )[2]},; //Quantidade do Item
						{"PESOR"    ,"N",TamSX3("GW8_PESOR" )[1],TamSX3("GW8_PESOR" )[2]},; //Peso do Item
						{"PESCUB"   ,"N",TamSX3("GW8_PESOC" )[1],TamSX3("GW8_PESOC" )[2]},; //Peso Cubado
						{"QTDALT"   ,"N",TamSX3("GW8_QTDALT")[1],TamSX3("GW8_QTDALT")[2]},; //Quantidade/Peso Alternativo
						{"VALOR"    ,"N",TamSX3("GW8_VALOR" )[1],TamSX3("GW8_VALOR" )[2]},; //Valor do Item
						{"VOLUME"   ,"N",TamSX3("GW8_VOLUME")[1],TamSX3("GW8_VOLUME")[2]},; //Volume ocupado (m3)
						{"NRGRUP"   ,"C",06 ,0},; //Numero do grupo subdividido
						{"CDEMIT"   ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente para calculo dos componentes especificos
						{"PEDROM"   ,"C",01 ,0},; //Indica a forma de aplicacao do pedagio
						{"PESPED"   ,"C",01 ,0},; //Indica o peso que será usado para calculo do pedagio, quando a aplicacao for por romaneio
						{"PRAZO"    ,"N",06 ,0},;  //Prazo para entrega em horas
						{"DELETADO"   ,"C",01 ,0},; // REGISTRO DELETADO
						{"PERCOUT"  ,"N",18, 15},;
						{"PESORORG" ,"N",TamSX3("GW8_PESOR" )[1],TamSX3("GW8_PESOR" )[2]},;
						{"PESCUBORG","N",TamSX3("GW8_PESOC" )[1],TamSX3("GW8_PESOC" )[2]},;
						{"VALORORG" ,"N",TamSX3("GW8_VALOR" )[1],TamSX3("GW8_VALOR" )[2]},;
						{"VOLUMEORG","N",TamSX3("GW8_VOLUME")[1],TamSX3("GW8_VOLUME")[2]},;
						{"QTDEORG"  ,"N",TamSX3("GW8_QTDE"  )[1],TamSX3("GW8_QTDE"  )[2]},;
						{"VALLIQ"   ,"N",TamSX3("GW8_VALOR" )[1],TamSX3("GW8_VALOR" )[2]} ; //Valor LIQUIDO GW8_VALLIQ
						})

	Self:setIndiceStruct({"NRCALC+CDCLFR+CDTPOP+SEQ","NRGRUP"})
	
Return

METHOD setTrechoCarga() Class GFEXFBTempTable //GetStrTRE

	Self:setTableStruct({{"EMISDC","C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente do Documento
						{"SERDC"   ,"C",TamSX3("GW1_SERDC")[1] ,0},; //Serie do Documento
						{"NRDC"    ,"C",TamSX3("GW1_NRDC")[1] ,0},; //Numero do Documento
						{"CDTPDC"  ,"C",TamSX3("GW1_CDTPDC")[1] ,0},; //Tipo do Documento
						{"SEQ"     ,"C",02 ,0},; //Sequencia do Trecho
						{"CDTRP"   ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Transportador do Trecho
						{"NRCIDD"  ,"C",TamSx3("GWU_NRCIDD")[1] ,0},; //Cidade Destino
						{"CDTPVC"  ,"C",10 ,0},; //Tipo de Veiculo do Trecho
						{"PAGAR"   ,"C",01 ,0},; //Trecho pago?
						{"NRCIDO"  ,"C",TamSx3("GWU_NRCIDD")[1] ,0},; //GWU_NRCIDO
						{"CEPO"    ,"C",08 ,0},; //GWU_CEPO  
						{"CEPD"    ,"C",08 ,0},; //GWU_CEPD  
						{"CDCLFR"  ,"C",TamSx3("GWN_CDCLFR")[1] ,0},; //GWU_CDCLFR
						{"CDTPOP"  ,"C",TamSx3("GWN_CDTPOP")[1] ,0},; //GWU_CDTPOP
						{"ORIGEM"  ,"C",TamSx3("GU3_NRCID")[1] ,0},; //Origem [Campo interno] - #interno
						{"DESTIN"  ,"C",TamSx3("GU3_NRCID")[1] ,0},; //Destino [Campo interno] - #interno
						{"NRGRUP"  ,"C",06 ,0},; //Numero do grupo subdividido  - #interno
						{"NRCALC"  ,"C",06 ,0}}) //Numero da Unidade de Calculo  - #interno
	Self:setIndiceStruct({"NRCALC","CDTPDC+EMISDC+SERDC+NRDC+SEQ","NRGRUP+SEQ+ORIGEM+DESTIN","NRGRUP+NRDC+SEQ+ORIGEM+DESTIN"})

Return
/*----------------------------------------------------------------------------
----------------------------------------------------------------------------*/
METHOD setItensCarga() Class GFEXFBTempTable //GetStrITE

	Self:setTableStruct({{"EMISDC","C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente do Documento
						{"SERDC" ,"C",TamSX3("GW1_SERDC")[1] ,0},; //Serie do Documento
						{"NRDC"	 ,"C",TamSX3("GW1_NRDC")[1] ,0},; //Numero do Documento
						{"CDTPDC","C",TamSX3("GW1_CDTPDC")[1] ,0},; //Tipo do Documento
						{"ITEM"  ,"C",16 ,0},; //Item
						{"CDCLFR","C",04 ,0},; //Classificacao de Frete
						{"TPITEM","C",04 ,0},; //Tipo de Item
						{"QTDE"  ,"N",13 ,5},; //Quantidade do Item
						{"PESOR" ,"N",TamSX3("GW8_PESOR" )[1], TamSX3("GW8_PESOR" )[2]},; //Peso do Item
						{"PESOC" ,"N",TamSX3("GW8_PESOC" )[1], TamSX3("GW8_PESOC" )[2]},; //Peso Cubado
						{"QTDALT","N",TamSX3("GW8_QTDALT")[1], TamSX3("GW8_QTDALT")[2]},; //Quantidade/Peso Alternativo
						{"VALOR" ,"N",TamSX3("GW8_VALOR" )[1], TamSX3("GW8_VALOR" )[2]},; //Valor do Item
						{"VOLUME","N",TamSX3("GW8_VOLUME")[1], TamSX3("GW8_VOLUME")[2]},; //Volume ocupado (m3)
						{"TRIBP" ,"C",01 ,0},; // Frete tributado PIS/COFINS
						{"VALLIQ" ,"N",TamSX3("GW8_VALOR" )[1], TamSX3("GW8_VALOR" )[2]},;//VALOR LIQUIDO GW8_VALLIQ
						{"NRGRUP","C",06 ,0}})  //Numero do grupo subdividido - #interno

	Self:setIndiceStruct({"CDTPDC+EMISDC+SERDC+NRDC+ITEM","NRGRUP+CDCLFR+ITEM"})

Return

METHOD setComponenteCalculoFrete() Class GFEXFBTempTable //GetStrCCF
	Self:setTableStruct({{"NRCALC","C",06 ,0},; // Emitente do Documento
						{"CDCLFR","C",04 ,0},; // Classificacao de Frete
						{"CDTPOP","C",10 ,0},; // Tipo de Operacao
						{"SEQ"   ,"C",04 ,0},; // Seq
						{"CDCOMP","C",20 ,0},; // Componente
						{"CATVAL","C",01 ,0},; // Categoria
						{"QTDE"  ,"N",TamSX3("GWI_QTCALC")[1], TamSX3("GWI_QTCALC")[2]},; // Quantidade Calculo
						{"VALOR" ,"N",TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},; // Valor Frete
						{"TOTFRE","C",01 ,0},; // Considera total de frete?
						{"BASIMP","C",01, 0},; // Base para calculo de ICMS/ISS?
						{"BAPICO","C",01, 0},; // Base para calculo de PIS/COFINS?
						{"FREMIN","C",01, 0},; // Considera na comparação com o frete mínimo?
						{"IDMIN" ,"C",01, 0},; // Indica se o campo recebeu o valor de frete minimo
						{"VLFRMI","N",TamSX3("GWI_VLFRET")[1], TamSX3("GWI_VLFRET")[2]},;  // Valor de frete mínimo, que será somado ao valor de frete calculado
						{"DELETADO","C",01, 0},; // Indica se o registro está deletado do array (Exclusão Lógica)
						{"NRLCENT","C",06,0},; // Local Entrega, quanto componente for entrega
						{"CPEMIT","C",01, 0}})  // Indica se o componente de frete é da Tarifa ou do Emitente
		
	Self:setIndiceStruct({"NRCALC+CDCLFR+CDTPOP+CDCOMP","NRCALC+CDCOMP","NRCALC+CDCLFR+CDTPOP+SEQ"})

Return

METHOD setLocalUnidadeCalculo() Class GFEXFBTempTable //GetStrENT
	Local nTamGu3EMT := TamSX3("GU3_CDEMIT")[1]
	Local nTamGU3COD := TamSX3("GU3_NRCID")[1]
	
	Self:setTableStruct({;//{"NRAGRU","C",10 ,0},; //Numero do Agrupador
						{"NRLCENT","C",06 ,0},; // Local Entrega
						{"CDTRP" ,"C",nTamGu3EMT ,0},; // Transportador
						{"SEQTRE","C",02 ,0},; // Sequencia do Trecho
						{"ORIGEM","C",nTamGU3COD ,0},; // Cidade de Origem
						{"DESTIN","C",nTamGU3COD ,0},; // Cidade de Destino
						{"CDREM" ,"C",nTamGu3EMT ,0},; // Remetente
						{"CDDEST","C",nTamGu3EMT ,0},;// Destinatário
						{"ENTNRC","C",7 ,0},; //Cidade de Entrega
						{"ENTEND","C",50 ,0},; //Endereco de Entrega
						{"ENTBAI","C",50 ,0},; //Bairro de entrega
						{"CDCOMP","C",20 ,0},; // Componente
						{"CDCLFR","C",04 ,0},; // Classificacao de Frete
						{"CDTPOP","C",10 ,0},; // Tipo de Operacao
						{"QTDCOMP","N",03 ,0},;	// Quantidade de Componentes Entrega compartilhado.
						{"QTDENTR","N",03 ,0}})	// Quantidade de UNIDADES Entrega compartilhado.

	Self:setIndiceStruct({"NRLCENT+CDCOMP","CDTRP+SEQTRE+ORIGEM+DESTIN+CDREM+CDDEST","CDTRP+SEQTRE+ORIGEM+DESTIN+CDREM+CDDEST+CDCOMP+CDCLFR+CDTPOP"})
Return

METHOD setSelecaoTabelaFrete() Class GFEXFBTempTable //GetStrSTF

	Self:setTableStruct({{"NRROM"  ,"C",08 ,0},; //Numero do Romaneio
						{"DOCS"   ,"C",34 ,0},; //Documentos de Carga
						{"CDTRP"  ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Codigo do Transportador (Base ou Vinculo)
						{"NRTAB"  ,"C",06 ,0},; //Numero da Tabela (Base ou Vinculo)
						{"NRNEG"  ,"C",06 ,0},; //Negociacao (Base ou Vinculo)
						{"NRCALC" ,"C",06 ,0},; //Numero do Calculo
						{"CDCLFR" ,"C",04 ,0},; //Classificacao de Frete
						{"CDTPOP" ,"C",10 ,0},; //Tipo Operacao
						{"CDFXTV" ,"C",04 ,0},; //Seq. Faixa
						{"CDTPVC" ,"C",10 ,0},; //Tipo de Veiculo
						{"NRROTA" ,"C",04 ,0},; //Rota
						{"DESROT" ,"C",155,0},; //Descricao da Rota
						{"DTVALI" ,"D",08 ,0},; //Data Vigencia Inicio
						{"DTVALF" ,"D",08 ,0},; //Data Vigencia Fim
						{"VLFRT"  ,"N",11 ,2},; //Valor Frete
						{"PRAZO"  ,"N",06 ,0},; //Prazo Entrega
						{"TPTAB"  ,"C",01 ,0},; //Tipo Tabela (1=Normal; 2=Vinculo)
						{"EMIVIN" ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente Vinculo (Original)
						{"TABVIN" ,"C",06 ,0},; //Tabela Vinculo (Original)
						{"NRTAB1" ,"C",06 ,0},; //Não usado. Mantido por compatibilidade.
						{"ATRFAI" ,"C",02 ,0},; //Atributo da Faixa
						{"QTKGM3" ,"N",12 ,5},; //K3/M3 - Fator de Cubagem
						{"UNIFAI" ,"C",TamSX3("GV9_UNIFAI")[1] ,0},; //Unidade da Faixa
						{"TPLOTA" ,"C",01 ,0},; //Tipo Lotacao
						{"TPVCFX" ,"C",13 ,0},; //Grava se foi selecionada uma faixa ou um tipo de veiculo, usado na Simulação do Calculo de frete
						{"DEMCID" ,"L",01 ,0},; //Indica se rota eh demais cidades
						{"QTFAIXA","N",TamSX3("GV7_QTFXFI")[1] ,5},; //Quantidade usada para determinação da faixa, usada como quantidade para calculo quando a rota eh selecionada
						{"CONTPZ" ,"C",01 ,0},; //Indica a forma de contagem do prazo, dias corridos, uteis ou horas
						{"QTCOTA" ,"N",03 ,0},; //Cota Do tipo de Veículo, para validação
						{"VLALUG" ,"N",09 ,2},; //Valor da locação do tipo Veículo, para validação
						{"FRQKM"  ,"N",06 ,0},;  //Franquia em km, para validação
						{"VLKMEX" ,"N",07 ,3},;  //Valor excedente da franquia, para validação
						{"TPROTA" ,"N",04 ,0}})

	Self:setIndiceStruct({"NRROM+NRTAB+NRNEG+NRROTA","NRCALC+CDCLFR+CDTPOP","EMIVIN+TABVIN+NRNEG+NRROTA"})

Return

METHOD setSimulacaoFrete() Class GFEXFBTempTable //GetStrSIM

	Self:setTableStruct({{"NRROM"  ,"C",08 ,0},; //Numero do Romaneio
						{"DOCS"   ,"C",34 ,0},; //Documentos de Carga
						{"CDTRP"  ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Codigo do Transportador (Base ou Vinculo)
						{"NRTAB"  ,"C",06 ,0},; //Numero da Tabela (Base ou Vinculo)
						{"NRNEG"  ,"C",06 ,0},; //Negociacao (Base ou Vinculo)
						{"NRCALC" ,"C",06 ,0},; //Numero do Calculo
						{"CDCLFR" ,"C",04 ,0},; //Classificacao de Frete
						{"CDTPOP" ,"C",10 ,0},; //Tipo Operacao
						{"CDFXTV" ,"C",04 ,0},; //Seq. Faixa
						{"CDTPVC" ,"C",10 ,0},; //Tipo de Veiculo
						{"NRROTA" ,"C",04 ,0},; //Rota
						{"DESROT" ,"C",155,0},; //Descricao da Rota
						{"DTVALI" ,"D",08 ,0},; //Data Vigencia Inicio
						{"DTVALF" ,"D",08 ,0},; //Data Vigencia Fim
						{"VLFRT"  ,"N",11 ,2},; //Valor Frete
						{"PRAZO"  ,"N",06 ,0},; //Prazo Entrega
						{"TPTAB"  ,"C",01 ,0},; //Tipo Tabela (1=Normal; 2=Vinculo)
						{"EMIVIN" ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Emitente Vinculo (Original)
						{"TABVIN" ,"C",06 ,0},; //Tabela Vinculo (Original)
						{"NRTAB1" ,"C",06 ,0},; //Não usado. Mantido por compatibilidade
						{"ATRFAI" ,"C",02 ,0},; //Atributo da Faixa
						{"QTKGM3" ,"N",12 ,5},; //K3/M3 - Fator de Cubagem
						{"UNIFAI" ,"C",TamSX3("GV9_UNIFAI")[1] ,0},; //Unidade da Faixa
						{"TPLOTA" ,"C",01 ,0},; //Tipo Lotacao
						{"DEMCID" ,"L",01 ,0},; //Indica se rota eh demais cidades
						{"QTFAIXA","N",TamSX3("GV7_QTFXFI")[1] ,5},; //Quantidade usada para determinação da faixa, usada como quantidade para calculo quando a rota eh selecionada
						{"TPVCFX" ,"C",13 ,0},; //Grava se foi selecionada uma faixa ou um tipo de veiculo, usado na Simulação do Calculo de frete
						{"SELEC"  ,"C",01 ,0},; //Indica se a tabela foi calcula com sucesso
						{"VALROT" ,"C",03 ,0},; //Indica se rota foi validada com sucesso
						{"VALFAI" ,"C",03 ,0},; //Indica se faixa foi validada com sucesso
						{"VALTPVC","C",03 ,0},; //Indica se o Tipo de Veiculo foi validado com sucesso
						{"VALDATA","C",03 ,0},; //Indica se Data de vigencia foi validada com sucesso
						{"ROTSEL" ,"C",01 ,0}}) //Rota Selecionada(1=Sim,2=Não)

	Self:setIndiceStruct({"NRROM+NRTAB+NRNEG+NRCALC+NRROTA+SELEC","NRCALC+CDCLFR+CDTPOP+EMIVIN+TABVIN+NRNEG+NRROTA"})

Return

METHOD setCalculoPedagio() Class GFEXFBTempTable //GetStrPED

	Self:setTableStruct({{"NRCALC" ,"C",06 ,0},; //Numero do Calculo
						{"CDCLFR" ,"C",04 ,0},; //Classificacao de Frete
						{"CDTPOP" ,"C",10 ,0},; //Tipo Operacao
						{"CDTRP"  ,"C",TamSX3("GU3_CDEMIT")[1] ,0},; //Codigo do Transportador (Base ou Vinculo)
						{"NRTAB"  ,"C",06 ,0},; //Numero da Tabela (Base ou Vinculo)
						{"NRNEG"  ,"C",06 ,0},; //Negociacao (Base ou Vinculo)
						{"TPLOTA" ,"C",01 ,0},; //Tipo de lotação
						{"CDFXTV" ,"C",04 ,0},; //Seq. Faixa
						{"CDTPVC" ,"C",10 ,0},; //Tipo de Veiculo
						{"NRROTA" ,"C",04 ,0},; //Rota
						{"ATRFAI" ,"C",02 ,0},; //Atributo da Faixa
						{"UNIFAI" ,"C",TamSX3("GV9_UNIFAI")[1] ,0},; //Unidade de medida da faixa
						{"UNICAL" ,"C",TamSX3("GV7_UNICAL")[1] ,0},; //Unidade de medida para calculo
						{"QTDE"   ,"N",TamSX3("GW8_QTDE"  )[1], TamSX3("GW8_QTDE"  )[2]},; //Quantidade do Item
						{"PESOR"  ,"N",TamSX3("GW8_PESOR" )[1], TamSX3("GW8_PESOR" )[2]},; //Peso do Item
						{"PESCUB" ,"N",TamSX3("GW8_PESOC" )[1], TamSX3("GW8_PESOC" )[2]},; //Peso Cubado
						{"QTDALT" ,"N",TamSX3("GW8_QTDALT")[1], TamSX3("GW8_QTDALT")[2]},; //Quantidade/Peso Alternativo
						{"VALOR"  ,"N",TamSX3("GW8_VALOR" )[1], TamSX3("GW8_VALOR" )[2]},; //Valor do Item
						{"VOLUME" ,"N",TamSX3("GW8_VOLUME")[1], TamSX3("GW8_VOLUME")[2]},; //Volume ocupado (m3)
						{"VLPED"  ,"N",TamSX3("GW8_VALOR" )[1], TamSX3("GW8_VALOR" )[2]},;
						{"QTCALC" ,"N",TamSX3("GW8_QTDE"  )[1], TamSX3("GW8_QTDE"  )[2]},; //Quantidade usada para determinação da faixa, usada como quantidade para calculo quando a rota eh selecionada
						{"CDCOMP" ,"C",20 ,0},;
						{"VALLIQ" ,"N",TamSX3("GW8_VALOR" )[1], TamSX3("GW8_VALOR" )[2]} ; //Valor LIQUIDO GW8_VALLIQ
						})
	Self:setIndiceStruct({"NRCALC+CDCLFR+CDTPOP"})
Return


METHOD CriaTempTable()		Class GFEXFBTempTable

	self:setTableName(GFECriaTab({self:getTableStruct(),self:getIndiceStruct()}))
	
Return
