#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³SCANC     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Preparacao do meio-magnetico para o SCANC                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Scanc(aFilsCalc)
	Local cFilOrig := cFilAnt as character
	Local nForFilial := 0 as numeric
	Local nTamFils := 0 as numeric
	
	Static oQryEnt := nil as object
	Static oQrySai := nil as object
	Static oTamSX3 := nil as object
	Static oSX3Cache := nil as object
	Static oSX6Cache := nil as object

	Default aFilsCalc := { { .T., cFilAnt } }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros utilizados SX6                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	MV_SCANC01 / _aTotal[52] - Campo do B5 que contem o codigo do produto - tabela 4.1 do manual
	MV_SCANC02 / _aTotal[53] - Campo do B5 que contem a sigla do produto - tabela 4.2 do manual
	MV_SCANC03 / _aTotal[54] - Campo do A1 que contem a categoria do estabelecimento - campo 12 do registro tipo 20 do manual
	MV_SCANC04 / _aTotal[55] - Campo do A2 que contem a categoria do estabelecimento - campo 12 do registro tipo 20 do manual
	MV_SCANC05 / _aTotal[56] - Campo do A2 que contem a IE ST do Fornecedor - campo 04 do registro tipo 20 do manual
	MV_SCANC06               - Contem as Inscricoes Estaduais que o contribuinte porventura possuir
	MV_SCANC07 / _aTotal[57] - Contem o percentual de Gasolina Tipo A
	MV_SCANC08 / _aTotal[58] - Contem as UF's que nao adotam o PMPF
	MV_SCANC09 / _aTotal[59] - Contem os Cfop's que nao serao considerados no Registro Tipo 40 - Nota Fiscal
	MV_SCANC11 / _aTotal[61] - Codigo de produtos para Alcool Etilico Anidro , pois conforme Capitulo IV do Ato Cotepe 03/99
	MV_SCANCQT / _aTotal[62] - Indica se o peso liquido definido na tabela de produto será considerado na composição da qtdade
	MV_SCANC12  / _aTotal[63] - Contem o percentual de Diesel
	*/

	getTamSX3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera arquivos temporarios                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GeraTemp()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 10 - Identificacao do Estabelecimento Informante          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegTp10()

	nTamFils := Len(aFilsCalc)

	For nForFilial := 1 to nTamFils
		If aFilsCalc[nForFilial, 1]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro Tipo 20 - Fornecedores / Clientes                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegTp20()
		EndIf
	Next

	For nForFilial := 1 to nTamFils
		If aFilsCalc[nForFilial, 1]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]

			//A cada filial, atualizo os parametros e se os campos existem, pois ha customizacao de campos e pode haver uma para cada filial
			getParamSX6() //Necessario chamar os parametros primeiro, pois ha parametros que especificam campos
			getFieldPos() //Necessario ter os parametros para validar se os campos dos parametros existem

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Registro Tipo 40 - Notas Fiscais Entrada/Saida                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RegTp40(aFilsCalc)
		EndIf
	Next

	If oQryEnt != Nil
		oQryEnt:Destroy()
		oQryEnt := Nil
	EndIf

	If oQrySai != Nil
		oQrySai:Destroy()
		oQrySai := Nil
	EndIf

	FreeObj(oTamSX3)
	FreeObj(oSX3Cache)
	FreeObj(oSX6Cache)

	cFilAnt := cFilOrig
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

	Local aStru		:= {}
	Local cArq		:= ""
	Local cArq1		:= ""
	Local cArq2		:= ""
	Local nTamFil 	:= FWSizeFilial()
	Local nRazsoc	:= Len(Alltrim(aFisFill(SM0->M0_NOMECOM,60)))
	Local nUfIest 	:= Len(Alltrim(GetNewPar("MV_SCANC06","")))
	Local oTempR40	:= Nil
	Local oTempR45	:= Nil
	Local oTempR47	:= Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 10 - Identificacao do Estabelecimento Informante          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aStru,{"TIPO"		,"C",002,0})
	AADD(aStru,{"CNPJ"		,"C",014,0})
	AADD(aStru,{"IE"		,"C",014,0})
	AADD(aStru,{"UF"		,"C",002,0})
	If nRazsoc < 60
		AADD(aStru,{"RAZSOC"	,"C",nRazsoc,0})
	Else
		AADD(aStru,{"RAZSOC"	,"C",060,0})
	Endif
	If nUfIest > 0
		AADD(aStru,{"UFIEST"	,"C",600,0})
	Else
		AADD(aStru,{"UFIEST"	,"C",001,0})	
	Endif

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"R10")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 10 - Inscricoes Estaduais Substitutas do Contribuinte     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"CODIGO"	,"C",002,0})
	AADD(aStru,{"CODFIL"	,"C",nTamFil,0})
	AADD(aStru,{"UF"		,"C",002,0})
	AADD(aStru,{"IE"		,"C",014,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"RST")
	IndRegua("RST",cArq,"CODIGO+CODFIL")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 20 - Fornecedor                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq1	:= ""
	cArq2	:= ""
	AADD(aStru,{"TIPO"		,"C",002,0})
	AADD(aStru,{"CNPJ"		,"C",014,0})
	AADD(aStru,{"CODIGO"	,"C",oTamSX3["A2_COD"],0})
	AADD(aStru,{"LOJA"		,"C",oTamSX3["A2_LOJA"],0})
	AADD(aStru,{"IE"		,"C",014,0})
	AADD(aStru,{"IE_ST"		,"C",014,0})
	AADD(aStru,{"RAZSOC"	,"C",060,0})
	AADD(aStru,{"ENDERECO"	,"C",060,0})
	AADD(aStru,{"BAIRRO"	,"C",030,0})
	AADD(aStru,{"MUNICIPIO"	,"C",035,0})
	AADD(aStru,{"UF"		,"C",002,0})
	AADD(aStru,{"CEP"		,"C",008,0})
	AADD(aStru,{"EMAIL"		,"C",060,0})
	AADD(aStru,{"CATEGORIA"	,"C",003,0})

	cArq1 := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq1,"F20")
	IndRegua("F20",cArq1,"CNPJ+CODIGO+LOJA")
	dbClearIndex()

	cArq2 := CriaTrab(Nil,.F.)
	IndRegua("F20",cArq2,"CNPJ+IE+IE_ST")
	dbClearIndex()

	dbSelectArea("F20")
	dbSetIndex(cArq1+OrdBagExt())
	dbSetIndex(cArq2+OrdBagExt())
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 20 - Cliente                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"TIPO"		,"C",002,0})
	AADD(aStru,{"CNPJ"		,"C",014,0})
	AADD(aStru,{"CODIGO"	,"C",oTamSX3["A1_COD"],0})
	AADD(aStru,{"LOJA"		,"C",oTamSX3["A1_LOJA"],0})
	AADD(aStru,{"IE"		,"C",014,0})
	AADD(aStru,{"IE_ST"		,"C",014,0})
	AADD(aStru,{"RAZSOC"	,"C",060,0})
	AADD(aStru,{"ENDERECO"	,"C",060,0})
	AADD(aStru,{"BAIRRO"	,"C",030,0})
	AADD(aStru,{"MUNICIPIO"	,"C",035,0})
	AADD(aStru,{"UF"		,"C",002,0})
	AADD(aStru,{"CEP"		,"C",008,0})
	AADD(aStru,{"EMAIL"		,"C",060,0})
	AADD(aStru,{"CATEGORIA"	,"C",003,0})

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"C20")
	IndRegua("C20",cArq,"CNPJ+CODIGO+LOJA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 40 - Notas Fiscais                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"CHAVE"			,"C",030,0})
	AADD(aStru,{"TIPO"			,"C",002,0})
	AADD(aStru,{"MES_ANO"		,"C",006,0})
	AADD(aStru,{"CNPJ"			,"C",014,0})
	AADD(aStru,{"IE"			,"C",014,0})
	AADD(aStru,{"UF"			,"C",002,0})
	AADD(aStru,{"DTEMIS"		,"C",008,0})
	AADD(aStru,{"MODELO"		,"C",002,0})
	AADD(aStru,{"SERIE"			,"C",003,0})
	AADD(aStru,{"NUMERO"		,"C",oTamSX3["F2_DOC"],0})
	AADD(aStru,{"CFOP"			,"C",004,0})
	AADD(aStru,{"TPFRETE"		,"C",001,0})
	AADD(aStru,{"CNPJ_CPF"		,"C",014,0})
	AADD(aStru,{"UFTRANSP"		,"C",002,0})
	AADD(aStru,{"PLACA1"		,"C",007,0})
	AADD(aStru,{"PLACA2"		,"C",007,0})
	AADD(aStru,{"PLACA3"		,"C",007,0})
	AADD(aStru,{"CODPROD"		,"C",005,0})
	AADD(aStru,{"QTDE"			,"N",013,3})
	AADD(aStru,{"VALOR"			,"N",013,2})
	AADD(aStru,{"QTDE_GAS_A"	,"N",013,3})
	AADD(aStru,{"BC_ICMS_ST"	,"C",001,0})
	AADD(aStru,{"BC_ST"			,"N",013,2})
	AADD(aStru,{"ICMS"			,"N",013,2})
	AADD(aStru,{"UFE"			,"C",002,0})

	oTempR40    := FWTemporaryTable():New("R40")
	oTempR40:SetFields( aStru )
	oTempR40:AddIndex("01", {"CHAVE"} )
	oTempR40:Create()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Registro Tipo 60 - Notas Fiscais                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	aadd(aStru,{"DESC_PRD" ,"C", 50, 0})					//Descricao produto
	aadd(aStru,{"CODIGO"   ,"C", oTamSX3["B1_COD"],0})
	aadd(aStru,{"UM"       ,"C", 02, 0})
	aadd(aStru,{"SITUACA"  ,"C", 01, 0})
	aadd(aStru,{"QUANT"    ,"N", 19, 3})
	aadd(aStru,{"CUSTO"    ,"N", 19, 3})
	aadd(aStru,{"CNPJ"     ,"C", 14, 0})
	aadd(aStru,{"INSCR"    ,"C", oTamSX3["A2_INSCR"],0})
	aadd(aStru,{"UF"       ,"C", 02, 0})
	aadd(aStru,{"NOME"     ,"C", 40, 0})
	aadd(aStru,{"CODNOME"  ,"C", 06, 0})
	aadd(aStru,{"TIPO"     ,"C", oTamSX3["B1_TIPO"],0})		//Campo com o tipo do produto
	aadd(aStru,{"COD_SCANC","C", 03, 0})					//COD SCANC

	cArq := CriaTrab(aStru)
	dbUseArea(.T.,__LocalDriver,cArq,"R99")
	IndRegua("R99",cArq,"COD_SCANC")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Registro Tipo 45 - TRIBUTAÇÃO MONOFÁSICA Nota Fiscal Óleo Diesel e Biodiesel
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"CHAVE"			,"C",050,0})
	AADD(aStru,{"TIPO"			,"C",002,0})					// 01 - Tipo de registro
	AADD(aStru,{"MES_ANO"		,"C",006,0})					// 02 - Mes ano Apuração
	AADD(aStru,{"CNPJ"			,"C",014,0})					// 03 - CNPJ
	AADD(aStru,{"IE"			,"C",014,0})					// 04 - Inscricao Estadual
	AADD(aStru,{"UF"			,"C",002,0})					// 05 - UF
	AADD(aStru,{"DTEMIS"		,"C",008,0})					// 06 - Data emissao/recebimento
	AADD(aStru,{"MODELO"		,"C",002,0})					// 07 - Modelo
	AADD(aStru,{"SERIE"			,"C",003,0})					// 08 - Serie
	AADD(aStru,{"NUMERO"		,"C",oTamSX3["F2_DOC"],0})		// 09 - Documento
	AADD(aStru,{"CFOP"			,"C",004,0})					// 10 - CFOP
	AADD(aStru,{"TPFRETE"		,"C",001,0})					// 11 - Tipo de Frete
	AADD(aStru,{"CNPJ_CPF"		,"C",014,0})					// 12 - CNPJ/CPF Transportador
	AADD(aStru,{"UFTRANSP"		,"C",002,0})					// 13 - UF Transportador
	AADD(aStru,{"PLACA1"		,"C",007,0})					// 14 - Primeira Placa 
	AADD(aStru,{"PLACA2"		,"C",007,0})					// 15 - Segunda Placa
	AADD(aStru,{"PLACA3"		,"C",007,0})					// 16 - Terceira Placa
	AADD(aStru,{"CODPROD"		,"C",009,0})					// 17 - Codigo do Produto
	AADD(aStru,{"QTDETOT"		,"N",013,3})					// 18 - Qtde Total 
	AADD(aStru,{"QTDDIESELA"	,"N",013,3})					// 19 - Quantidade de Óleo Diesel A
	AADD(aStru,{"QTDB100"		,"N",013,3})					// 20 - Quantidade de Biodiesel (B100)
	AADD(aStru,{"ALIQADREM"		,"N",008,4})					// 21 - Alíquota Ad Rem
	AADD(aStru,{"ICMDIESELA"	,"N",013,3})					// 22 - Valor do ICMS sobre o Óleo Diesel A
	AADD(aStru,{"VLICMSB100"	,"N",013,3})					// 23 - Valor do ICMS sobre o Biodiesel (B100)
	AADD(aStru,{"ICMSNOTA"		,"C",001,0})					// 24 - Informação do ICMS na Nota Fiscal
	AADD(aStru,{"UFCONSUMO"		,"C",002,0})					// 25 - UF de Consumo
	AADD(aStru,{"CONJUNTOS"		,"C",200,0})					/* Reúne os campos 26, 27 e 28 
																	26 - Origem do Produto
																	27 - UF de Origem do Produto
																	28 - Percentual dea UF de Origem*/

	oTempR45    := FWTemporaryTable():New("R45")
	oTempR45:SetFields( aStru )
	oTempR45:AddIndex("01", {"NUMERO", "SERIE", "CODPROD"} )
	oTempR45:Create()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//Registro Tipo 47 – TRIBUTAÇÃO MONOFÁSICA Nota Fiscal GLP/GLGN
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aStru	:= {}
	cArq	:= ""
	AADD(aStru,{"CHAVE"			,"C",050,0})
	AADD(aStru,{"TIPO"			,"C",002,0})					// 01 - Tipo de registro
	AADD(aStru,{"MES_ANO"		,"C",006,0})					// 02 - Mes ano Apuração
	AADD(aStru,{"CNPJ"			,"C",014,0})					// 03 - CNPJ
	AADD(aStru,{"IE"			,"C",014,0})					// 04 - Inscricao Estadual
	AADD(aStru,{"UF"			,"C",002,0})					// 05 - UF
	AADD(aStru,{"DTEMIS"		,"C",008,0})					// 06 - Data emissao/recebimento
	AADD(aStru,{"MODELO"		,"C",002,0})					// 07 - Modelo
	AADD(aStru,{"SERIE"			,"C",003,0})					// 08 - Serie
	AADD(aStru,{"NUMERO"		,"C",oTamSX3["F2_DOC"],0})		// 09 - Documento
	AADD(aStru,{"CFOP"			,"C",004,0})					// 10 - CFOP
	AADD(aStru,{"TPFRETE"		,"C",001,0})					// 11 - Tipo de Frete
	AADD(aStru,{"CNPJ_CPF"		,"C",014,0})					// 12 - CNPJ/CPF Transportador
	AADD(aStru,{"UFTRANSP"		,"C",002,0})					// 13 - UF Transportador
	AADD(aStru,{"PLACA1"		,"C",007,0})					// 14 - Primeira Placa 
	AADD(aStru,{"PLACA2"		,"C",007,0})					// 15 - Segunda Placa
	AADD(aStru,{"PLACA3"		,"C",007,0})					// 16 - Terceira Placa
	AADD(aStru,{"CODPROD"		,"C",009,0})					// 17 - Codigo do Produto
	AADD(aStru,{"QTDETOT"		,"N",013,3})					// 18 - Qtde Total (KG) 
	AADD(aStru,{"PERCGLP"		,"N",008,4})					// 19 - Proporção GLP (%) 
	AADD(aStru,{"PERCGLGN"		,"N",008,4})					// 20 - Proporção GLGNn (%)
	AADD(aStru,{"PERCGLGNI"		,"N",008,4})					// 21 - Proporção GLGNi (%)
	AADD(aStru,{"ALIQADREM"		,"N",008,4})					// 22 - Alíquota Ad Rem
	AADD(aStru,{"VICMGLP"		,"N",013,2})					// 23 - Valor do ICMS sobre o GLP
	AADD(aStru,{"VICMGLGN"		,"N",013,2})					// 24 - Valor do ICMS sobre o GLGNn (Nacional)
	AADD(aStru,{"VICMGLGNI"		,"N",013,2})					// 25 - Valor do ICMS sobre o GLGNi (Importado)
	AADD(aStru,{"ICMSNOTA"		,"C",001,0})					// 26 - Informação do ICMS na Nota Fiscal
	AADD(aStru,{"UFCONSUMO"		,"C",002,0})					// 27 - UF de Consumo
	AADD(aStru,{"CONJUNTOS"		,"C",200,0})					// Reúne os campos 28, 29 e 30

	oTempR47    := FWTemporaryTable():New("R47")
	oTempR47:SetFields( aStru )
	oTempR47:AddIndex("01", {"NUMERO", "SERIE", "CODPROD"} )
	oTempR47:Create()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegTp10    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 10 - Identificacao do Estab. do Informante     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegTp10()

Local cReg	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temp das IE ST do Contribuinte - Registro Tipo 10          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraIEST()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravando dados do Contribuinte - Registro Tipo 10                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("R10")
RecLock("R10",.T.)
R10->TIPO	:= "10"
R10->CNPJ	:= aRetDig(SM0->M0_CGC,.F.)
R10->IE		:= aFisFill(aRetDig(SM0->M0_INSC,.T.,SM0->M0_ESTENT),14)
R10->UF		:= aFisFill(SM0->M0_ESTENT,2) 
R10->RAZSOC	:= aFisFill(SM0->M0_NOMECOM,60)
MsUnLock()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravando IE ST do Contribuinte - Registro Tipo 10                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RST")
dbSetOrder(1) //CODIGO+CODFIL
If dbSeek(SM0->M0_CODIGO+SM0->M0_CODFIL)
	While !Eof() .And. Alltrim(RST->CODIGO+RST->CODFIL) == Alltrim(SM0->M0_CODIGO+SM0->M0_CODFIL)
		cReg+=',"'+RST->UF+'","'+RST->IE+'"'
		dbSelectArea("RST")
		dbSkip()
	Enddo
	dbSelectArea("R10")
	dbGoTop()
	RecLock("R10",.F.)
	R10->UFIEST := cReg
	MsUnLock()
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraIEST   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivo temporaria das IE ST do Contribuinte            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraIEST()

Local cIESt	:= Alltrim(GetNewPar("MV_SCANC06",""))
Local nI	:= 0
Local nPos	:= 0
Local nTamFil := FWSizeFilial()

If Len(cIESt) > 0
	For nI := 1 To Len(cIESt)
		nPos := At("/",cIESt)
		If !(nPos>0) .And. Empty(cIESt)
			Exit
		Endif
		If  nPos > 0
			cReg := Substr(cIESt,1,nPos-1)
		Else
			cReg := Alltrim(Substr(cIESt,1))
		Endif
		cIESt := IIf(nPos>0,Substr(cIESt,nPos+1),"")
		dbSelectArea("RST")
		RecLock("RST",.T.)
		RST->CODIGO	:= Substr(cReg,1,2)
		RST->CODFIL	:= Substr(cReg,3,nTamFil)
		RST->UF		:= Upper(Substr(cReg,3+nTamFil,2))
		RST->IE		:= Substr(cReg,5+nTamFil)
		MsUnlock()
	Next
Endif

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RegTp20    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Registro Tipo 20 - Fornecedores / Clientes                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RegTp20()

Local aArea		:= GetArea()
Local cCNPJ		:= ""
Local cIE		:= ""
Local cCodigo	:= ""
Local cLoja		:= ""
Local cSCANC01	:= GetNewPar("MV_SCANC01","")
Local cSCANC03	:= GetNewPar("MV_SCANC03","")
Local cSCANC04	:= GetNewPar("MV_SCANC04","")
Local cSCANC05	:= GetNewPar("MV_SCANC05","")
Local lSCANC01	:= SB5->(FieldPos(cSCANC01))>0
Local lSCANC03	:= SA1->(FieldPos(cSCANC03))>0
Local lSCANC04	:= SA2->(FieldPos(cSCANC04))>0
Local lSCANC05	:= SA2->(FieldPos(cSCANC05))>0

dbSelectArea('SA1')
SA1->(dbSetOrder(1))
dbSelectArea('SA2')
SA2->(dbSetOrder(1))
dbSelectArea('SB5')
SB5->(dbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³F20 - Cadastro de Fornecedores                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lSCANC01 //Verifica se existe o campo Ref. Tab. 41
	dbSelectArea("SD1")
	dbSetOrder(6)
	dbSeek(xFilial("SD1")+Dtos(mv_par01),.T.)
	While !Eof() .And. SD1->D1_FILIAL==xFilial("SD1") .And. SD1->D1_DTDIGIT>=mv_par01 .And. SD1->D1_DTDIGIT<=mv_par02
		If !(SD1->D1_TIPO$"DB")
			If SB5->(dbSeek(xFilial("SB5")+SD1->D1_COD))
				If Alltrim(SB5->&(cSCANC01)) $ _aTotal[50] + _aTotal[45] + _aTotal[46]	//Verifica se consta na relacao de Produtos
					If SA2->(dbSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA))
						cCNPJ := aFisFill(aRetDig(SA2->A2_CGC,.F.),14)
						If !Empty(cCNPJ)
							cCodigo	:= SD1->D1_FORNECE
							cLoja	:= SD1->D1_LOJA
							If !F20->(dbSeek(cCNPJ+cCodigo+cLoja))
								dbSelectArea("F20")
								RecLock("F20",.T.)
								F20->TIPO		:= "20"
								F20->CNPJ		:= cCNPJ 
								F20->CODIGO		:= cCodigo
								F20->LOJA		:= cLoja
								F20->IE			:= aFisFill(aRetDig(SA2->A2_INSCR,.T.,SA2->A2_EST),14)
								F20->IE_ST		:= IIf(lSCANC05,aFisFill(IIF(UPPER(aRetDig(SA2->&(cSCANC05),.T.,SA2->A2_EST))$" ISENTO",aFISFill("",14),aRetDig(SA2->&(cSCANC05),.T.,SA2->A2_EST)),14),"") // Issue DSERFIS1-26464 , onde quando utilizo o campo A2_IEST no parametro MV_SCANC05 devo validar oara que caso o campo A2_INSCR OU A2_IEST estiverem em BRANCO ou ISENTO, deverá gerar em BRANCO com 14 posições.
								F20->RAZSOC		:= aFisFill(SA2->A2_NOME,60)
								F20->ENDERECO	:= aFisFill(SA2->A2_END,60)
								F20->BAIRRO		:= aFisFill(SA2->A2_BAIRRO,30)
								F20->MUNICIPIO	:= aFisFill(SA2->A2_MUN,35)
								F20->UF			:= aFisFill(SA2->A2_EST,2)
								F20->CEP		:= aFisFill(SA2->A2_CEP,8)
								F20->EMAIL		:= aFisFill(SA2->A2_EMAIL,60)
								F20->CATEGORIA	:= IIf(lSCANC04,aFisFill(SA2->&(cSCANC04),3),"")
								MsUnlock()					
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif	
		dbSelectArea("SD1")
		dbSkip()
	Enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³C20 - Cadastro de Clientes                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD2")
	dbSetOrder(5)
	dbSeek(xFilial("SD2")+Dtos(mv_par01),.T.)
	While !Eof() .And. SD2->D2_FILIAL==xFilial("SD2") .And. SD2->D2_EMISSAO>=mv_par01 .And. SD2->D2_EMISSAO<=mv_par02
		If !(SD2->D2_TIPO$"DB")
			If SB5->(dbSeek(xFilial("SB5")+SD2->D2_COD))
				If Alltrim(SB5->&(cSCANC01)) $ _aTotal[50] + _aTotal[45] + _aTotal[46]	//Verifica se consta na relacao de Produtos
					If SA1->(dbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA))
						cCNPJ	:= aFisFill(aRetDig(SA1->A1_CGC,.F.),14)
						cIE		:= aFisFill(aRetDig(SA1->A1_INSCR,.T.,SA1->A1_EST),14)
						If !Empty(cCNPJ)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica se existe no Cadastro de Fornecedor                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If FindFor(cCNPJ,cIE)
								cCodigo	:= SD2->D2_CLIENTE
								cLoja	:= SD2->D2_LOJA
								If !C20->(dbSeek(cCNPJ+cCodigo+cLoja))
									dbSelectArea("C20")
									RecLock("C20",.T.)
									C20->TIPO		:= "20"
									C20->CNPJ		:= cCNPJ
									C20->CODIGO		:= cCodigo
									C20->LOJA		:= cLoja
									C20->IE			:= cIE
									C20->IE_ST		:= ""
									C20->RAZSOC		:= aFisFill(SA1->A1_NOME,60)
									C20->ENDERECO	:= aFisFill(SA1->A1_END,60)
									C20->BAIRRO		:= aFisFill(SA1->A1_BAIRRO,30)
									C20->MUNICIPIO	:= aFisFill(SA1->A1_MUN,35)
									C20->UF			:= aFisFill(SA1->A1_EST,2)
									C20->CEP		:= aFisFill(SA1->A1_CEP,8)
									C20->EMAIL		:= ""
									C20->CATEGORIA	:= IIf(lSCANC03,aFisFill(SA1->&(cSCANC03),3),"")
									MsUnlock()					
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif	
		dbSelectArea("SD2")
		dbSkip()
	Enddo
Endif
RestArea(aArea)
Return Nil

/*/{Protheus.doc} RegTp40
Registro Tipo 40 - Notas Fiscai
@type function
@version  
@author rodrigo.ccandido
@since 7/12/2023
@param aFilsCalc, array, param_description
@return variant, return_description
/*/
Static Function RegTp40(aFilsCalc)

	Local aArea		:= GetArea() as array
	Local cSeek		:= "" as character
	Local cCodProd	:= "" as character
	Local cA4CGC	:= "" as character
	Local cA4EST	:= "" as character
	Local cSCANC01 	:= oSX6Cache["MV_SCANC01"] as character
	Local nPercDie 	:= oSX6Cache["MV_SCANC12"] as numeric
	Local nPerGasC 	:= oSX6Cache["MV_SCANC13"] as numeric
	Local nPerDisB 	:= oSX6Cache["MV_SCANC14"] as numeric
	Local cFiltTes 	:= oSX6Cache["MV_SCANC15"] as character
	Local cGasA    	:= oSX6Cache["MV_PROGASA"] as character
	Local cGasC    	:= oSX6Cache["MV_PROGASC"] as character
	Local cDisB    	:= oSX6Cache["MV_PRODIB"] as character
	Local cDiesel  	:= oSX6Cache["MV_PRODIE"] as character
	//Placa entradas
	Local cScanep2 	:= oSX6Cache["MV_SCANEP2"] as character // placa 2
	Local cScanep3 	:= oSX6Cache["MV_SCANEP3"] as character // placa 3
	//Placa saidas
	Local cScansp1 	:= oSX6Cache["MV_SCANSP1"] as character // placa 1
	Local cScansp2 	:= oSX6Cache["MV_SCANSP2"] as character // placa 2
	Local cScansp3 	:= oSX6Cache["MV_SCANSP3"] as character // placa 3

	Local lScanep2 	:= oSX3Cache[cScanep2] as logical
	Local lScanep3 	:= oSX3Cache[cScanep3] as logical
	Local lScansp1 	:= oSX3Cache[cScansp1] as logical
	Local lScansp2 	:= oSX3Cache[cScansp2] as logical
	Local lScansp3 	:= oSX3Cache[cScansp3] as logical
	Local LC5PLACA 	:= oSX3Cache["C5_PLACA1"] .And. oSX3Cache["C5_PLACA2"] as logical

	Local lDevBen	:= .F. as logical
	Local cQuery	:= "" as character
	Local cAliasTRB	:= "" as character
	Local lReg40 	:= .F. as logical
	Local lReg45 	:= .F. as logical
	Local lReg47	:= .F. as logical

	Default aFilsCalc:= { { .T., cFilAnt } }

	If !(oSX3Cache[cSCANC01] .AND. ValType(SB5->&(cSCANC01)) == "C")
		Return Nil
	EndIf

	If oQryEnt == nil
		//Processa Notas Fiscais de Entrada
		cQuery := " SELECT SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_COD, SD1.D1_ITEM, SD1.D1_TIPO, SD1.D1_DTDIGIT, "
		cQuery += 	" SD1.D1_QUANT, SD1.D1_TOTAL, SD1.D1_VALICM, SD1.D1_ICMSRET, SD1.D1_ICMSDIF, SD1.D1_EMISSAO, SD1.D1_CF, SD1.D1_CLASFIS, "
		cQuery += 	" SD1.D1_BASNDES, SD1.D1_BRICMS, SD1.D1_ICMNDES, SD1.D1_PICM, "
		cQuery += 	" SF1.F1_ESPECIE, SF1.F1_TRANSP, SF1.F1_FRETE, SF1.F1_TIPO, SF1.F1_VEICUL1, SF1.F1_VEICUL2, SF1.F1_VEICUL3, SF1.F1_PLACA, SF1.F1_ORIGLAN, "
		cQuery += 	" SA4.A4_CGC, SA4.A4_EST, "
		cQuery += 	" SB1.B1_PESO, "
		cQuery += 	" SA2.A2_INSCR, SA2.A2_CGC, SA2.A2_EST, SA1.A1_INSCR, SA1.A1_CGC, SA1.A1_EST, "
		cQuery += 	" ? " //01
		cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
		cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 "
		cQuery += 	" ON SF1.F1_FILIAL = SD1.D1_FILIAL "
		cQuery += 		" AND SF1.F1_DOC = SD1.D1_DOC "
		cQuery += 		" AND SF1.F1_SERIE = SD1.D1_SERIE "
		cQuery += 		" AND SF1.F1_FORNECE = SD1.D1_FORNECE "
		cQuery += 		" AND SF1.F1_LOJA = SD1.D1_LOJA "
		cQuery += 		" AND SF1.D_E_L_E_T_ = ? "	//02
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += 	" ON SB1.B1_FILIAL = ? " //03
		cQuery += 		" AND SB1.B1_COD = SD1.D1_COD "
		cQuery += 		" AND SB1.D_E_L_E_T_ = ? " //04
		cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 "
		cQuery += 	" ON SB5.B5_FILIAL = ? " 
		cQuery += 		" AND SB5.B5_COD = SB1.B1_COD " //05
		cQuery += 		" AND SB5.? IN (?) "  //06 e 07
		cQuery += 		" AND SB5.D_E_L_E_T_ = ? " //08
		cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 " 
		cQuery += 	" ON SA2.A2_FILIAL = ? " //09
		cQuery += 		" AND SA2.A2_COD = SF1.F1_FORNECE "
		cQuery += 		" AND SA2.A2_LOJA = SF1.F1_LOJA "
		cQuery += 		" AND SF1.F1_TIPO IN (?) " //10
		cQuery += 		" AND SA2.D_E_L_E_T_ = ? " //11
		cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 " 
		cQuery += 	" ON SA1.A1_FILIAL = ? " //12
		cQuery += 		" AND SA1.A1_COD = SF1.F1_FORNECE "
		cQuery += 		" AND SA1.A1_LOJA = SF1.F1_LOJA "
		cQuery += 		" AND SF1.F1_TIPO IN (?) " //13
		cQuery += 		" AND SA1.D_E_L_E_T_ = ? " //13
		cQuery += " LEFT JOIN " + RetSqlName("SA4") + " SA4 "
		cQuery += 	" ON SA4.A4_FILIAL = ? " //15
		cQuery += 		" AND SA4.A4_COD = SF1.F1_TRANSP "
		cQuery += 		" AND SA4.D_E_L_E_T_ = ? " //16
		cQuery += " WHERE SD1.D1_FILIAL IN (?) " //17
		cQuery += 	" AND SD1.D1_DTDIGIT BETWEEN ? AND ? " //18 e 19
		cQuery += 	" AND SD1.D1_CF NOT IN (?) " //20
		cQuery += 	" AND SD1.D1_TES NOT IN (?) " //21
		cQuery += 	" AND SD1.D_E_L_E_T_ = ? " //22

		oQryEnt := FwExecStatement():New(ChangeQuery(cQuery))
	EndIf

	oQryEnt:setUnsafe(01, cSCANC01)
	oQryEnt:setString(02, " ")
	oQryEnt:setString(03, xFilial("SB1"))
	oQryEnt:setString(04, " ")
	oQryEnt:setString(05, xFilial("SB5"))
	oQryEnt:setUnsafe(06, cSCANC01)
	oQryEnt:setIn(07, StrTokArr(_aTotal[50] + _aTotal[45] + _aTotal[46], "/"))
	oQryEnt:setString(08, " ")
	oQryEnt:setString(09, xFilial("SA2"))
	oQryEnt:setIn(10, {'N','C', 'P', 'I'})
	oQryEnt:setString(11, " ")
	oQryEnt:setString(12, xFilial("SA1"))
	oQryEnt:setIn(13, {'B','D'})
	oQryEnt:setString(14, " ")
	oQryEnt:setString(15, xFilial("SA4"))
	oQryEnt:setString(16, " ")
	oQryEnt:setIn(17, StrTokArr(RetFilial("SD1", lAglFil, aFilsCalc),"/"))
	oQryEnt:SetDate(18, mv_par01)
	oQryEnt:SetDate(19, mv_par02)
	oQryEnt:setIn(20, StrTokArr(_aTotal[59],"/"))
	oQryEnt:setIn(21, StrTokArr(cFiltTes,"/"))
	oQryEnt:setString(22, " ")

	cAliasTRB := oQryEnt:OpenAlias()

	While !(cAliasTRB)->(Eof())
		
		cA4CGC := ""
		cA4EST := ""
		lReg40 := Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[50]
		lReg45 := Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[45]
		lReg47 := Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[46]

		If lReg40

			lDevBen := (cAliasTRB)->D1_TIPO $ "DB"					//Devolucao ou Beneficiamento

			If !Empty((cAliasTRB)->F1_TRANSP)
				cA4CGC := aRetDig((cAliasTRB)->A4_CGC,.F.)
				cA4EST := (cAliasTRB)->A4_EST
			EndIf

			cCodProd := StrZero(Val((cAliasTRB)->&(cSCANC01)),5)

			If Empty(_aTotal[61]) .Or.;	//Gero quando o parametro nao estiver configurado, ou
				(AllTrim((cAliasTRB)->D1_COD) $ _aTotal[61] .And. Left((cAliasTRB)->D1_CF, 1) > "1") .Or.;	//quando estiver configurado, o produto pertencer ao parametro e for uma operacao interestadual ou internacional, ou
				!AllTrim((cAliasTRB)->D1_COD) $ _aTotal[61]	//quando o produto nao pertencer no parametro.

				cSeek := "E"+cCodProd+(cAliasTRB)->D1_DOC+(cAliasTRB)->D1_SERIE+(cAliasTRB)->D1_FORNECE+(cAliasTRB)->D1_LOJA
				If R40->(!DbSeek(cSeek))
					RecLock("R40",.T.)
					R40->CHAVE		:= cSeek
					R40->TIPO		:= "40"
					R40->MES_ANO	:= StrZero(Month(mv_par01),2)+StrZero(Year(mv_par01),4)
					
					If lDevBen
						R40->CNPJ	:= (cAliasTRB)->A1_CGC
						R40->IE		:= AllTrim(aRetDig((cAliasTRB)->A1_INSCR,.T.,(cAliasTRB)->A1_EST))
						R40->UF		:= (cAliasTRB)->A1_EST
					Else
						R40->CNPJ	:= (cAliasTRB)->A2_CGC
						R40->IE		:= AllTrim(aRetDig((cAliasTRB)->A2_INSCR,.T.,(cAliasTRB)->A2_EST))
						R40->UF		:= (cAliasTRB)->A2_EST
					EndIf

					R40->DTEMIS		:= (cAliasTRB)->D1_DTDIGIT
					R40->MODELO		:= aModNot((cAliasTRB)->F1_ESPECIE)
					R40->SERIE		:= (cAliasTRB)->D1_SERIE
					R40->NUMERO		:= (cAliasTRB)->D1_DOC
					R40->CFOP		:= (cAliasTRB)->D1_CF
					R40->TPFRETE 	:= "1"

					If Empty((cAliasTRB)->F1_FRETE) .And. (cAliasTRB)->F1_ORIGLAN == "F " .And. (cAliasTRB)->F1_TIPO == "C" //NF Conhecimento Frete
						R40->TPFRETE	:= "2"
					EndIf
					R40->CNPJ_CPF	:= cA4CGC	
					R40->UFTRANSP	:= cA4EST	

					//Placa de Veiculo 1,2 e 3 - tratamento para DLC
					If !Empty(cScanep2) 
						If !Empty((cAliasTRB)->F1_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F1_VEICUL1))
							R40->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
							If lScanep2
								R40->PLACA2 := Alltrim(StrTran(DA3->&(cScanep2),"-","")) 
							EndIf
							If lScanep3
								R40->PLACA3 := Alltrim(StrTran(DA3->&(cScanep3),"-","")) 
							EndIf
						EndIf
					EndIf
					//Placa de Veiculo 1- tratamento padrão 
					If Empty(R40->PLACA1)
						If !Empty((cAliasTRB)->F1_PLACA) // Verifica se foi utilizado campo D1_PLACA ou F1_VEICUL1 para compor placa 1
							R40->PLACA1 := Alltrim(StrTran((cAliasTRB)->F1_PLACA,"-","")) 
						Elseif !Empty((cAliasTRB)->F1_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F1_VEICUL1))
							R40->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
						EndIf
						//Placa de Veiculo 2
						If !Empty((cAliasTRB)->F1_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F1_VEICUL2))
							R40->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
						EndIf
						//Placa de Veiculo 3
						If !Empty((cAliasTRB)->F1_VEICUL3) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F1_VEICUL3))
							R40->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
						EndIf
					EndIf
					R40->CODPROD	:= cCodProd
					R40->BC_ICMS_ST	:= IIf((cAliasTRB)->D1_BRICMS > 0 ,"1","0")
				Else
					RecLock("R40",.F.)
				Endif
				
				R40->QTDE		+= (cAliasTRB)->D1_QUANT * IIf(_aTotal[62] .And. !Empty((cAliasTRB)->B1_PESO),(cAliasTRB)->B1_PESO,1)
				R40->VALOR		+= (cAliasTRB)->D1_TOTAL
				
				If Alltrim((cAliasTRB)->&(cSCANC01)) $ cGasA
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D1_QUANT/100)*_aTotal[57])
				ElseIf Alltrim((cAliasTRB)->&(cSCANC01))$cDiesel
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D1_QUANT/100)*nPercDie)
				ElseIf Alltrim((cAliasTRB)->&(cSCANC01))$cGasC
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D1_QUANT/100)*nPerGasC)
				ElseIf Alltrim((cAliasTRB)->&(cSCANC01))$cDisB
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D1_QUANT/100)*nPerDisB)
				Else
					R40->QTDE_GAS_A	+= 0
				EndIf

				If ((cAliasTRB)->D1_BASNDES + (cAliasTRB)->D1_BRICMS) > 0
					R40->BC_ST += IIf(Alltrim((cAliasTRB)->&(cSCANC01))$_aTotal[49] .And. (cAliasTRB)->D1_BASNDES == 0 ,(cAliasTRB)->D1_BRICMS,(cAliasTRB)->D1_BASNDES)
				Else
					R40->BC_ST += (cAliasTRB)->D1_TOTAL
				EndIf

				R40->ICMS += IIf(Alltrim((cAliasTRB)->&(cSCANC01))$_aTotal[49] .And. (cAliasTRB)->D1_ICMNDES == 0 ,((cAliasTRB)->D1_VALICM+(cAliasTRB)->D1_ICMSRET),(cAliasTRB)->D1_ICMNDES)
				R40->(MsUnlock())
			EndIf

		ElseIf SubStr((cAliasTRB)->D1_CLASFIS,2,2) $ "02/15/53/61" .AND. (lReg45 .OR. lReg47)
			
			If lReg45
				//Tipo 45 - Nota Fiscal Tributação Monofásica Óleo Diesel e Biodiesel (à partir de 01/04/2023)
				RegTp45("1", cAliasTRB)
			
			ElseIf lReg47
				// Tipo 47 – TRIBUTAÇÃO MONOFÁSICA Nota Fiscal GLP/GLGN
				RegTp47("1", cAliasTRB)
			EndIf

		EndIf

		(cAliasTRB)->(dbSkip())
	EndDo

	(cAliasTRB)->(dbCloseArea())

	If oQrySai == nil
		//Processa Notas Fiscais de Saida
		cQuery := " SELECT SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_COD, SD2.D2_ITEM, SD2.D2_TIPO, SD2.D2_PEDIDO, "
		cQuery += " SD2.D2_QUANT, SD2.D2_TOTAL, SD2.D2_VALICM, SD2.D2_ICMSRET, SD2.D2_EMISSAO, SD2.D2_CF, SD2.D2_CLASFIS, SD2.D2_BRICMS, SD2.D2_EST, SD2.D2_PICM, "
		cQuery += " SF2.F2_ESPECIE, SF2.F2_TRANSP, SF2.F2_FRETE, SF2.F2_TIPO, SF2.F2_VEICUL1, SF2.F2_VEICUL2, SF2.F2_VEICUL3, "
		cQuery += " SA4.A4_CGC, SA4.A4_EST, "
		cQuery += " SB1.B1_PESO, "
		cQuery += " SA2.A2_INSCR, SA2.A2_CGC, SA2.A2_EST, "
		cQuery += " SA1.A1_INSCR, SA1.A1_CGC, SA1.A1_EST, "
		cQuery += " ? " //01
		cQuery += " FROM " + RetSqlName("SD2") + " SD2 "
		cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 "
		cQuery += 	" ON SF2.F2_FILIAL = SD2.D2_FILIAL " 
		cQuery += 		" AND SF2.F2_DOC = SD2.D2_DOC "
		cQuery += 		" AND SF2.F2_SERIE = SD2.D2_SERIE "
		cQuery += 		" AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
		cQuery += 		" AND SF2.F2_LOJA = SD2.D2_LOJA "
		cQuery += 		" AND SF2.D_E_L_E_T_ = ? " //02
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += 	" ON SB1.B1_FILIAL = ? " //03
		cQuery += 		" AND SB1.B1_COD = SD2.D2_COD "
		cQuery += 		" AND SB1.D_E_L_E_T_ = ? " //04
		cQuery += " INNER JOIN " + RetSqlName("SB5") + " SB5 "
		cQuery += 	" ON SB5.B5_FILIAL = ? " //05 
		cQuery += 		" AND SB5.B5_COD = SB1.B1_COD "
		cQuery += 		" AND SB5.? IN (?) " //06 e 07
		cQuery += 		" AND SB5.D_E_L_E_T_ = ? " //08
		cQuery += " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
		cQuery += 	" ON SA2.A2_FILIAL = ? " //09
		cQuery += 		" AND SA2.A2_COD = SF2.F2_CLIENTE "
		cQuery += 		" AND SA2.A2_LOJA = SF2.F2_LOJA "
		cQuery += 		" AND SF2.F2_TIPO IN (?) " //10
		cQuery += 		" AND SA2.D_E_L_E_T_ = ? " //11
		cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 "
		cQuery += 	" ON SA1.A1_FILIAL = ? " //12
		cQuery += 		" AND SA1.A1_COD = SF2.F2_CLIENTE "
		cQuery += 		" AND SA1.A1_LOJA = SF2.F2_LOJA "
		cQuery += 		" AND SF2.F2_TIPO IN (?) " //13
		cQuery += 		" AND SA1.D_E_L_E_T_ = ? " //14
		cQuery += " LEFT JOIN " + RetSqlName("SA4") + " SA4 "
		cQuery += 	" ON SA4.A4_FILIAL = ? " //15
		cQuery += 		" AND SA4.A4_COD = SF2.F2_TRANSP "
		cQuery += 		" AND SA4.D_E_L_E_T_ = ? " //16
		cQuery += " WHERE SD2.D2_FILIAL IN (?) " //17
		cQuery += 	" AND SD2.D2_EMISSAO BETWEEN ? AND ? " //18 e 19
		cQuery += 	" AND SD2.D2_CF NOT IN (?) " //20
		cQuery += 	" AND SD2.D2_TES NOT IN (?) " //21
		cQuery += 	" AND SD2.D_E_L_E_T_ = ? " //22
		
		oQrySai := FwExecStatement():New(ChangeQuery(cQuery))
	EndIf

	oQrySai:setUnsafe(01, cSCANC01)
	oQrySai:setString(02, " ")
	oQrySai:setString(03, xFilial("SB1"))
	oQrySai:setString(04, " ")
	oQrySai:setString(05, xFilial("SB5"))
	oQrySai:setUnsafe(06, cSCANC01)
	oQrySai:setIn(07, StrTokArr(_aTotal[50]+_aTotal[45]+_aTotal[46],"/"))
	oQrySai:setString(08, " ")
	oQrySai:setString(09, xFilial("SA2"))
	oQrySai:setIn(10, {'B','D'})
	oQrySai:setString(11, " ")
	oQrySai:setString(12, xFilial("SA1"))
	oQrySai:setIn(13, {'N','C', 'P', 'I'})
	oQrySai:setString(14, " ")
	oQrySai:setString(15, xFilial("SA4"))
	oQrySai:setString(16, " ")
	oQrySai:setIn(17, StrTokArr(RetFilial("SD2", lAglFil, aFilsCalc),"/"))
	oQrySai:SetDate(18, mv_par01)
	oQrySai:SetDate(19, mv_par02)
	oQrySai:setIn(20, StrTokArr(_aTotal[59],"/"))
	oQrySai:setIn(21, StrTokArr(cFiltTes,"/"))
	oQrySai:setString(22, " ")

	cAliasTRB := oQrySai:OpenAlias()
	
	//Posicionamento das Tabelas
	SC5->(DbSetOrder(1))

	While !(cAliasTRB)->(Eof())

		cA4CGC := ""
		cA4EST := ""
		lReg40 := Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[50]
		lReg45 := Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[45]
		lReg47 := Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[46]

		If lReg40

			lDevBen := (cAliasTRB)->D2_TIPO $ "DB"					//Devolucao ou Beneficiamento

			If !Empty((cAliasTRB)->F2_TRANSP)
				cA4CGC := aRetDig((cAliasTRB)->A4_CGC,.F.)
				cA4EST := (cAliasTRB)->A4_EST
			EndIf

			cCodProd := StrZero(Val((cAliasTRB)->&(cSCANC01)),5)

			If Empty(_aTotal[61]) .Or.;	//Gero quando o parametro nao estiver configurado, ou
				(AllTrim((cAliasTRB)->D2_COD) $ _aTotal[61] .And. Left((cAliasTRB)->D2_CF, 1) > "5") .Or.;	//quando estiver configurado, o produto pertencer ao parametro e for uma operacao interestadual ou internacional, ou
				!AllTrim((cAliasTRB)->D2_COD) $ _aTotal[61]	//quando o produto nao pertencer no parametro.

				cSeek := "S"+cCodProd+(cAliasTRB)->D2_DOC+(cAliasTRB)->D2_SERIE+(cAliasTRB)->D2_CLIENTE+(cAliasTRB)->D2_LOJA
				If R40->(!dbSeek(cSeek))
					RecLock("R40",.T.)
					R40->CHAVE		:= cSeek
					R40->TIPO		:= "40"
					R40->MES_ANO	:= StrZero(Month(mv_par01),2)+StrZero(Year(mv_par01),4)
					
					If lDevBen
						R40->CNPJ	:= (cAliasTRB)->A2_CGC
						R40->IE		:= aRetDig((cAliasTRB)->A2_INSCR,.T.,(cAliasTRB)->A2_EST)
						R40->UF		:= (cAliasTRB)->A2_EST
					Else
						R40->CNPJ	:= (cAliasTRB)->A1_CGC
						R40->IE		:= aRetDig((cAliasTRB)->A1_INSCR,.T.,(cAliasTRB)->A1_EST)
						R40->UF		:= (cAliasTRB)->A1_EST
					EndIf

					R40->DTEMIS		:= (cAliasTRB)->D2_EMISSAO
					R40->MODELO		:= aModNot((cAliasTRB)->F2_ESPECIE)
					R40->SERIE		:= (cAliasTRB)->D2_SERIE
					R40->NUMERO		:= (cAliasTRB)->D2_DOC
					R40->CFOP		:= Alltrim((cAliasTRB)->D2_CF)
					
					If !Empty((cAliasTRB)->F2_FRETE)
						R40->TPFRETE := '1'
					Else
						R40->TPFRETE := '2'
					EndIf

					R40->CNPJ_CPF	:= cA4CGC	//Transportadora
					R40->UFTRANSP	:= cA4EST	//Transportadora

					If SC5->(MsSeek(xFilial("SC5")+Alltrim((cAliasTRB)->D2_PEDIDO)))
						//Placa de Veiculo 1,2 e 3 - tratamento para DLC
						If !Empty(cScansp1) .And. lScansp1 .And. !Empty(SC5->&(cScansp1))
							R40->PLACA1 := Alltrim(StrTran(SC5->&(cScansp1),"-","")) //tira hífen
							If !Empty(cScansp2) .And. lScansp2 .And. !Empty(SC5->&(cScansp2))
								R40->PLACA2 := Alltrim(StrTran(SC5->&(cScansp2),"-","")) //tira hífen
							Endif
							If !Empty(cScansp3) .And. lScansp3 .And. !Empty(SC5->&(cScansp3))
								R40->PLACA3 := Alltrim(StrTran(SC5->&(cScansp3),"-","")) //tira hífen
							Endif
						Endif
						If Empty(R40->PLACA1) .And. Empty(cScansp1)
							//Tratamento para DLC com campos Padroes de placa SC5 e veiculo SF2
							If LC5PLACA
								If !Empty(SC5->C5_PLACA1)
									R40->PLACA1 := Alltrim(StrTran(SC5->C5_PLACA1,"-","")) //tira hífen(SC5->C5_PLACA1)
								Endif
								If !Empty(SC5->C5_PLACA2)
									R40->PLACA2 := Alltrim(StrTran(SC5->C5_PLACA2,"-","")) //tira hífen(SC5->C5_PLACA2)
								Endif
							Endif
						Endif
						//Placa de Veiculo 1 processo padrao sem DLC
						If Empty(R40->PLACA1) .And. !Empty((cAliasTRB)->F2_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL1))
							R40->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
						Endif
						//Placa de Veiculo 2
						If Empty(R40->PLACA2) .And. !Empty((cAliasTRB)->F2_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL2))
							R40->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
						Endif
						//Placa de Veiculo 3
						If Empty(R40->PLACA3) .And. !Empty((cAliasTRB)->F2_VEICUL3) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL3))
							R40->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) //tira hífen(DA3->DA3_PLACA)
						Endif
					Endif
					R40->CODPROD	:= cCodProd
					R40->BC_ICMS_ST	:= Iif((cAliasTRB)->D2_BRICMS > 0,"1","0")
				Else
					RecLock("R40",.F.)
				Endif
				
				If _aTotal[62] .And. !Empty((cAliasTRB)->B1_PESO)
					R40->QTDE += (cAliasTRB)->D2_QUANT * (cAliasTRB)->B1_PESO
				Else
					R40->QTDE += (cAliasTRB)->D2_QUANT
				EndIf

				R40->VALOR += (cAliasTRB)->D2_TOTAL

				If Alltrim((cAliasTRB)->&(cSCANC01)) $ cGasA
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D2_QUANT/100)*_aTotal[57])
				ElseIf Alltrim((cAliasTRB)->&(cSCANC01)) $ cDiesel
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D2_QUANT/100)*nPercDie)
				ElseIf Alltrim((cAliasTRB)->&(cSCANC01)) $ cGasC
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D2_QUANT/100)*nPerGasC)
				ElseIf Alltrim((cAliasTRB)->&(cSCANC01)) $ cDisB
					R40->QTDE_GAS_A	+= (((cAliasTRB)->D2_QUANT/100)*nPerDisB)
				Else
					R40->QTDE_GAS_A	+= 0
				Endif

				If (Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[49] .And. (cAliasTRB)->D2_EST $ _aTotal[58]) .Or. (Alltrim((cAliasTRB)->&(cSCANC01)) $ _aTotal[60])
					R40->BC_ST	+= Iif((cAliasTRB)->D2_BRICMS > 0 ,(cAliasTRB)->D2_BRICMS, iif(Alltrim((cAliasTRB)->&(cSCANC01))$_aTotal[47] .And. SubStr((cAliasTRB)->D2_CF,1,1)=='6' ,(cAliasTRB)->D2_TOTAL,0))
				Endif
				
				//-- Sigla da Unidade da Federacao de efetivo consumo
				If R40->CFOP $ "6667"
					If SC5->(MsSeek(xFilial("SC5")+Alltrim((cAliasTRB)->D2_PEDIDO)))
						//-- Campo obrigatorio para CFOP 6667
						R40->UFE := aFisFill(SC5->C5_ESTPRES,2)
					EndIf
					If Empty(R40->UFE)
						R40->UFE := aFisFill((cAliasTRB)->A1_EST,2)
					Endif
				Endif

				R40->(MsUnlock())
			EndIf

		ElseIf SubStr((cAliasTRB)->D2_CLASFIS,2,2) $ "02/15/53/61" .AND. (lReg45 .OR. lReg47)
			
			If lReg45
				//Tipo 45 - Nota Fiscal Tributação Monofásica Óleo Diesel e Biodiesel (à partir de 01/04/2023)
				RegTp45("2", cAliasTRB)
				
			ElseIf lReg47
				// Tipo 47 – TRIBUTAÇÃO MONOFÁSICA Nota Fiscal GLP/GLGN
				RegTp47("2", cAliasTRB)
			EndIf
			
		EndIf

		(cAliasTRB)->(dbSkip())
	Enddo

	(cAliasTRB)->(dbCloseArea())

	RestArea(aArea)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FindFor    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o Cliente ja esta cadastrado na Tab. Fornecedor  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FindFor(cCNPJ,cIE)

Local aArea	:= GetArea()
Local lRet	:= .T.

If !Empty(cCNPJ) .And. !Empty(cIE)	//CNPJ+IE 
	dbSelectArea("F20")
	dbSetOrder(2)
	If F20->(dbSeek(cCNPJ+cIE))
		lRet := .F.
	Endif
Endif
RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Aglut60    ³ Autor ³Rodrigo Trefft         ³ Data ³ 26.11.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Aglutina quantidades do registro 60 - SCANC                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Aglut60(aFilsCalc)
	Local cCodSCANC	:= GetNewPar("MV_SCANC02","")
	Local lCodSCANC	:= SB5->(FieldPos((cCodSCANC)))>0
	Local cChv		:= ''
	Local nForFilial:= 0
	Local cFilOrig	:= cFilAnt
	Default aFilsCalc:= { { .T., cFilAnt } }

	For nForFilial := 1 to Len(aFilsCalc)
		If aFilsCalc[nForFilial, 1]
			cFilAnt := aFilsCalc[ nForFilial, 2 ]		
			dbSelectArea("R74")
			R74->(dbGoTop())
			
			Do While !R74->(Eof())
				dbSelectArea("SB5")
				dbSetOrder(1)
				If SB5->(dbSeek(xFilial("SB5")+R74->CODPRD)) .And. lCodSCANC
					cChv := Alltrim(SB5->&(cCodSCANC))
					If !R99->(dbSeek(cChv))
						RecLock("R99",.T.)
						R99->DESC_PRD := R74->DESC_PRD
						R99->CODIGO   := R74->CODPRD
						R99->UM       := R74->UM
						R99->SITUACA  := R74->SITUACA
						R99->QUANT    := R74->QUANT
						R99->CUSTO    := R74->CUSTO
						R99->CNPJ     := R74->CNPJ
						R99->INSCR    := R74->INSCR
						R99->UF       := R74->UF
						R99->NOME     := R74->NOME
						R99->CODNOME  := R74->CODNOME
						R99->TIPO     := R74->TIPO
						R99->COD_SCANC:= cChv
					Else
						RecLock("R99",.F.)
						R99->QUANT +=  R74->QUANT
					EndIF
				EndIf
				MsUnLock()
				R74->(dbSkip())
			Enddo
		EndIf
	Next nForFilial

	cFilAnt := cFilOrig	
Return (.T.)

/*/{Protheus.doc} RegTp45
Registro Tipo 45 - Nota Fiscal Tributação Monofásica Óleo Diesel e Biodiesel (à partir de 01/04/2023)
@type function
@version 12.1.2210 
@author rodrigo.ccandido
@since 5/17/2023
@param cEntSai, character, param_description
@return variant, return_description
/*/
Static Function RegTp45(cEntSai, cAliasTRB)

	Local cSCANC01 	:= oSX6Cache["MV_SCANC01"] as character

	// placas das entradas
	Local cScanep2 	:= oSX6Cache["MV_SCANEP2"] as character // placa 2
	Local cScanep3 	:= oSX6Cache["MV_SCANEP3"] as character // placa 3
	Local lScanep2 	:= oSX3Cache[cScanep2] as logical
	Local lScanep3 	:= oSX3Cache[cScanep3] as logical

	//Placa saidas
	Local cScansp1 	:= oSX6Cache["MV_SCANSP1"] as character // placa 1
	Local cScansp2 	:= oSX6Cache["MV_SCANSP2"] as character // placa 2
	Local cScansp3 	:= oSX6Cache["MV_SCANSP3"] as character // placa 3

	Local lInclui	:= .T. as logical
	Local cChaveCD6	:= "" as character
	Local cSeek		:= "" as character
	Local cTipoICMS	:= "1" as character // 0 - ICMS cobrado em operação anterior 1 - ICMS cobrado na operação
	
	Local cAlsSF 	:= "F"+cEntSai as character	//Determina o Alias para as Tabelas SF1/SF2
	Local cAlsSD	:= "D"+cEntSai as character	//Determina o Alias para as Tabelas SD1/SD2
	Local cAlsSA	:= "" as character
	
	Local cDoc		:= "" as character
	Local cSerie	:= "" as character
	Local cCodProd	:= "" as character
	Local cTipoES	:= "" as character
	Local cCliFor 	:= "" as character
	Local cLoja   	:= "" as character
	Local cTransp 	:= "" as character
	Local cA4Cgc 	:= "" as character
	Local cA4Est 	:= "" as character
	Local cCST	 	:= "" as character
	
	Local lScansp1 	:= oSX3Cache[cScansp1] as logical
	Local lScansp2 	:= oSX3Cache[cScansp2] as logical
	Local lScansp3 	:= oSX3Cache[cScansp3] as logical
	Local lC5Placa 	:= oSX3Cache["C5_PLACA1"] .And. oSX3Cache["C5_PLACA2"] as logical

	// campos
	Local cCmpDoc 	:= "" as character
	Local cCmpSer 	:= "" as character
	Local cCmpItem 	:= "" as character
	Local cCmpProd 	:= "" as character
	Local cCmpQtde 	:= "" as character
	Local cCmpDtDig := "" as character
	Local cCmpEspec := "" as character
	Local cCmpCF 	:= "" as character
	Local cCmpTrp 	:= "" as character
	Local cCmpFrete := "" as character
	Local cCmpTipo 	:= "" as character
	Local cCmpVeic1 := "" as character
	Local cCmpVeic2 := "" as character
	Local cCmpVeic3 := "" as character
	Local cCmpPlaca := "" as character
	Local cCmpCgc 	:= "" as character
	Local cCmpIE  	:= "" as character
	Local cCmpEst 	:= "" as character
	Local cCmpVlIcm	:= "" as character
	Local cCmpAlqIcm:= "" as character
	Local cCNPJ		:= "" as character
	Local nICMNDES	:= 0 as numeric

	//Determina o Alias para as Tabelas SA1/SA2
	If cEntSai == "1"
		If !((cAliasTRB)->D1_TIPO $ "BD")
			cAlsSA := "A2"
		Else
			cAlsSA := "A1"
		EndIf
		cTipoES := "E"
		cCliFor := (cAliasTRB)->D1_FORNECE
		cLoja   := (cAliasTRB)->D1_LOJA
	Else
		If (cAliasTRB)->D2_TIPO $ "BD"
			cAlsSA := "A2"
		Else
			cAlsSA := "A1"
		EndIf
		cTipoES := "S"
		cCliFor := (cAliasTRB)->D2_CLIENTE
		cLoja   := (cAliasTRB)->D2_LOJA
	EndIf

	cCmpDoc 	:= cAlsSD+"_DOC"
	cCmpSer 	:= cAlsSD+"_SERIE"
	cCmpItem 	:= cAlsSD+"_ITEM"
	cCmpProd 	:= cAlsSD+"_COD"
	cCmpQtde 	:= cAlsSD+"_QUANT"
	cCmpVlIcm 	:= cAlsSD+"_VALICM"
	cCmpAlqIcm	:= cAlsSD+"_PICM"
	cCmpIcmst 	:= cAlsSD+"_ICMSRET"
	if cEntSai == "1"
		cCmpIcmDes  := cAlsSD+"_ICMNDES"
	EndIf
	cCmpDtDig 	:= cAlsSD+"_EMISSAO"
	cCmpCF 		:= cAlsSD+"_CF"
	cCmpCST		:= cAlsSD+"_CLASFIS"

	cCmpEspec 	:= cAlsSF+"_ESPECIE"
	cCmpTrp 	:= cAlsSF+"_TRANSP"
	cCmpFrete 	:= cAlsSF+"_FRETE"
	cCmpTipo 	:= cAlsSF+"_TIPO"
	cCmpVeic1 	:= cAlsSF+"_VEICUL1"
	cCmpVeic2 	:= cAlsSF+"_VEICUL2"
	cCmpVeic3 	:= cAlsSF+"_VEICUL3"
	cCmpPlaca 	:= cAlsSF+"_PLACA"

	cCmpCgc 	:= cAlsSA+"_CGC"
	cCmpIE  	:= cAlsSA+"_INSCR"
	cCmpEst 	:= cAlsSA+"_EST"
	
	cDoc 	  := (cAliasTRB)->(&(cCmpDoc))
	cSerie 	  := (cAliasTRB)->(&(cCmpSer))
	cCST	  := SubStr((cAliasTRB)->(&(cCmpCST)),2,2)
	cTransp   := (cAliasTRB)->(&(cCmpTrp))
	cVeiculo  := (cAliasTRB)->(&(cCmpVeic1))
	cVeiculo2 := (cAliasTRB)->(&(cCmpVeic2))
	cVeiculo3 := (cAliasTRB)->(&(cCmpVeic3))
	
	If !Empty(cTransp)
		cA4Cgc := aRetDig((cAliasTRB)->A4_CGC,.F.)
		cA4Est := (cAliasTRB)->A4_EST
	EndIf

	cCodProd := StrZero(Val((cAliasTRB)->&(cSCANC01)),9)
	cSeek 	 := cDoc + cSerie + cCodProd
	lInclui	 := !R45->(MsSeek(cSeek))

	RecLock("R45",lInclui)

		cCNPJ := validCNPJ((cAliasTRB)->(&(cCmpEst)), oTamSX3[cCmpCgc], Alltrim((cAliasTRB)->(&(cCmpCgc))))

		R45->TIPO		:= "45" 																	// 01 - Tipo de registro
		R45->MES_ANO	:= StrZero(Month(MV_PAR01),2)+StrZero(Year(MV_PAR01),4)						// 02 - Mês/Ano Apuração
		R45->CNPJ		:= cCNPJ																	// 03 - CNPJ
		R45->IE			:= Alltrim(aRetDig((cAliasTRB)->(&(cCmpIE)),.T.,(cAliasTRB)->(&(cCmpEst))))	// 04 - Inscrição Estadual
		R45->UF			:= (cAliasTRB)->(&(cCmpEst))												// 05 - UF
		R45->DTEMIS		:= (cAliasTRB)->(&(cCmpDtDig))												// 06 - Data de emissão /recebimento
		R45->MODELO		:= aModNot((cAliasTRB)->(&(cCmpEspec)))										// 07 - Modelo
		R45->SERIE		:= Alltrim((cAliasTRB)->(&(cCmpSer)))										// 08 - Serie
		R45->NUMERO		:= Alltrim((cAliasTRB)->(&(cCmpDoc)))										// 09 - Numero
		R45->CFOP		:= Alltrim((cAliasTRB)->(&(cCmpCF)))										// 10 - CFOP
		R45->TPFRETE 	:= GetSitFrt(cTipoES) 														// 11 - Tipo Frete
		R45->CNPJ_CPF	:= cA4Cgc																	// 12 - CNPJ / CPF Transportador
		R45->UFTRANSP	:= cA4Est																	// 13 - UF Transportador
		
		If cEntSai == "1"

			cPlaca := (cAliasTRB)->(&(cCmpPlaca))

			If !Empty(cVeiculo) .AND. DA3->(MsSeek(xFilial("DA3")+cVeiculo))
				R45->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 							// 14 - Primeira Placa
			Else
				R45->PLACA1 := Alltrim(StrTran(cPlaca,"-",""))
			EndIf
				
			If !Empty(cVeiculo2) .AND. DA3->(MsSeek(xFilial("DA3")+cVeiculo2))
				If lScanep2 .AND. !Empty(cScanep2) 
					R45->PLACA2 := Alltrim(StrTran(DA3->&(cScanep2),"-",""))
				Else
					R45->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 						// 15 - Segunda Placa
				EndIf
			Else
				R45->PLACA2 := Alltrim(StrTran(cPlaca,"-",""))
			EndIf
			
			If !Empty(cVeiculo3) .AND. DA3->(MsSeek(xFilial("DA3")+cVeiculo3))
				If lScanep3 .AND. !Empty(cScanep3) 
					R45->PLACA3 := Alltrim(StrTran(DA3->&(cScanep3),"-",""))
				Else
					R45->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 						// 16 - Terceira Placa
				EndIf
			Else
				R45->PLACA3 := Alltrim(StrTran(cPlaca,"-",""))
			EndIf
		
		Else
				
			SC5->(DbSetOrder(1))
			If SC5->(MsSeek(xFilial("SC5")+Alltrim((cAliasTRB)->D2_PEDIDO)))
				//Placa de Veiculo 1,2 e 3 - tratamento para DLC
				If !Empty(cScansp1) .And. lScansp1 .And. !Empty(SC5->&(cScansp1))
					R45->PLACA1 := Alltrim(StrTran(SC5->&(cScansp1),"-","")) 
					If !Empty(cScansp2) .And. lScansp2 .And. !Empty(SC5->&(cScansp2))
						R45->PLACA2 := Alltrim(StrTran(SC5->&(cScansp2),"-","")) 
					Endif
					If !Empty(cScansp3) .And. lScansp3 .And. !Empty(SC5->&(cScansp3))
						R45->PLACA3 := Alltrim(StrTran(SC5->&(cScansp3),"-","")) 
					Endif
				Endif
				If Empty(R45->PLACA1) .And. Empty(cScansp1)
					//Tratamento para DLC com campos Padroes de placa SC5 e veiculo SF2
					If lC5Placa
						If !Empty(SC5->C5_PLACA1)
							R45->PLACA1 := Alltrim(StrTran(SC5->C5_PLACA1,"-","")) 
						Endif
						If !Empty(SC5->C5_PLACA2)
							R45->PLACA2 := Alltrim(StrTran(SC5->C5_PLACA2,"-","")) 
						Endif
					Endif
				Endif
				//Placa de Veiculo 1 processo padrao sem DLC
				If Empty(R45->PLACA1) .And. !Empty((cAliasTRB)->F2_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL1))
					R45->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
				Endif
				//Placa de Veiculo 2
				If Empty(R45->PLACA2) .And. !Empty((cAliasTRB)->F2_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL2))
					R45->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
				Endif
				//Placa de Veiculo 3
				If Empty(R45->PLACA3) .And. !Empty((cAliasTRB)->F2_VEICUL3) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL3))
					R45->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
				EndIf
			EndIf

		EndIf

		R45->CODPROD := cCodProd																// 17 - Código do Produto
		R45->QTDETOT += (cAliasTRB)->(&(cCmpQtde))												// 18 - Quantidade Total do Produto

		cChaveCD6 := cTipoES + cSerie + cDoc + cCliFor + cLoja + PadR((cAliasTRB)->(&(cCmpItem)),oTamSX3["CD6_ITEM"]) + (cAliasTRB)->(&(cCmpProd))
		
		//Se for saída o conteúdo deve ser zero, caso contrário pega o conteúdo do campo D1_ICMNDES
		if cEntSai == "1"
			nICMNDES := (cAliasTRB)->(&(cCmpIcmDes))
		Endif

		R45->CONJUNTOS := AllTrim(R45->CONJUNTOS) + GetRegsCD6(cChaveCD6, cCodProd, "45", (cAliasTRB)->(&(cCmpQtde)), (cAliasTRB)->(&(cCmpVlIcm)),(cAliasTRB)->(&(cCmpIcmst)),cEntSai,cCST,nICMNDES,(cAliasTRB)->(&(cCmpAlqIcm)))

		If cCST $ "02/15"
			cTipoICMS := "1"		// 1 - ICMS cobrado na operação
		ElseIf cCst $ "53" 
			If (cAliasTRB)->D1_ICMSDIF > 0 .and. (cAliasTRB)->D1_VALICM <> (cAliasTRB)->D1_ICMSDIF	// Diferimento Parcial
				cTipoICMS := "1"	// 1 - ICMS cobrado na operação
			Else
				cTipoICMS := "0"	// 0 - ICMS cobrado em operação anterior
			EndIf
		Else	
			cTipoICMS := "0"		// 0 - ICMS cobrado em operação anterior
		EndIf
		
		R45->ICMSNOTA := cTipoICMS															// 24 - Informação do ICMS na Nota Fiscal. 0 - ICMS cobrado em operação anterior 1 - ICMS cobrado na operação.

	R45->(MsUnlock())

Return

/*/{Protheus.doc} GetRegsCD6
Busca os registros da CD6 - Complemento de Combustiveis para compor os campos 25, 26, 27 e 28
@type function
@version  12.1.2210
@author rodrigo.ccandido
@since 5/17/2023
@param cChaveCD6, character, param_description
@param cCodProd, character, param_description
@return variant, return_description
/*/
Static Function GetRegsCD6(cChaveCD6, cCodProd, cRegistro, nQtdNF, nValIcm, nValIcmST, cEntSai, cCST, nICMNDES, nAliqIcm)

	Local aArea 		:= GetArea()
	Local cDieselA		:= "420102004,420102005,420105001,420301002,420201001,420201003,"
	Local cDieselB		:= "820101012,820101013,820101033,820101034,"
	Local cBiodiesel	:= "820101001"
	Local cGasolinaA    := "320101001,320101002,320201001"
	Local cGasolinaC    := "320102001,320102002,320102003,320102005"
	Local cGasolinaE    := "320301002"
	Local cGasolinaR    := "320103003,320103001"	
	Local cGasolinaO    := "320301001,320103002"
	Local cEtanolA		:= "810102001,810102004,810102003"
	Local cRet  		:= ""
	Local cUfOrig 		:= ""
	Local cIndImp 		:= ""
	Local cPorig 		:= ""
	Local nAdRem 		:= 0
	Local nVlIcmDiselA 	:= 0
	Local nQtDiselA 	:= 0
	Local nVlIcmB100 	:= 0
	Local nQtdB100 		:= 0
	Local nSupostaB100 	:= 0
	Local nIcmsB100		:= 0
	Local nIcmPart1     := 0
	Local nIcmPart2     := 0
	Local nPbio		    := 0
	Local nQtGasolinaA  := 0
	Local nQtEtanol     := 0
	Local nVlIcmGasolA  := 0
	Local nVlIcmEtanol  := 0
	Local nQtGasolinaC 	:= 0
	Local nVlIcmGasolC  := 0
	Local cItemNF  		:= ""

	//CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD+CD6_PLACA+CD6_TANQUE
	CD6->(DbSetOrder(1)) 
	If CD6->(MsSeek(xFilial("CD6") + cChaveCD6))
		
		// regra para compor os campos dependentes da CD6 do registro 45
		If cRegistro == "45"
			
			R45->UFCONSUMO := CD6->CD6_UFCONS							// 25 - UF de Consumo

			While CD6->(CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD) == xFilial("CD6") + cChaveCD6

				nPbio := CD6->CD6_PBIO/100
				nAdRem := CD6->CD6_VALIQ                           		// 21 - Alíquota Ad Rem

				If Empty(nAdRem)
					if cCodProd $ cDieselA + cDieselB + cBiodiesel
						nAdRem 	 := 0.9456
					Else
						nAdRem 	 := 1.2200
					Endif
				EndIf

				nAdRem := validAliqAdRem(CD6->CD6_BCCIDE, CD6->CD6_VALIQ, CD6->CD6_VCIDE, nAdRem, nAliqIcm)	// 21 - Alíquota Ad Rem
				
				// Percentual de Biodiesel aplicado na mistura
				If Empty(nPbio)
					if cCodProd $ cDieselA + cDieselB + cBiodiesel
						nPbio := 0.12 // por padrão é 12%
					ElseIf cCodProd $ cGasolinaA + cGasolinaC + cGasolinaE + cGasolinaR + cGasolinaO + cEtanolA
						nPbio := 0.27 // por padrão é  27%
					Endif
				EndIf
				
				nQtDiselA	 := 0
				nQtdB100  	 := 0
				nVlIcmDiselA := 0
				nVlIcmB100   := 0
				nQtGasolinaA := 0
				nQtEtanol    := 0
				nVlIcmFGasoA := 0
				NVlIcmEtanol := 0
				nQtGasolinaC := 0
				nVlIcmGasolC := 0

				// controla o item da nota processado para não somar duplicado, pois não há mais ITEM na query principal para somar os lotes (rastreabilidade), no entanto, é possivel cadastrar mais de uma CD6 para o mesmo item da nota
				If cItemNF <> CD6->CD6_ITEM

					cItemNF := CD6->CD6_ITEM

					nIcmPart1	:= nAdRem * 0.3333 								// 1 terço da aliquota 0.3333
					nIcmPart2	:= nAdRem * 0.6667 								// Quant. Restante tirando o  B100 2/3 0.6667

					// Produto DIESEL A (puro)
					If	cCodProd $ cDieselA
						
						nQtDiselA 		:= nQtdNF								// Qtde de Diesel A utilizado
						If cCodProd $ ("420201001,420201003")
							nQtdB100 := 0 										// Para Diesel Maritimo , a quantidade de B100 é zero por ser também um produto puro e nao ter previsao de mistura.
						Else
							nQtdB100 := (nQtDiselA / (1-nPbio)) * nPbio			// Qtde de Biodiesel B100 a compor a mistura futura
						EndIf 			                
						
						If	cEntSai == "1" // Entrada 

							nVlIcmDiselA 	:= nValIcm
							If cCST =="61"
								nVlIcmB100	:= nICMNDES
							Else
								If cCodProd $ ("420201001,420201003")
									nVlIcmB100 := nQtdB100	* nIcmPart1 		// Para Diesel Maritimo não tenho valor de B100 por ser puro.
								Else
									nVlIcmB100 	:= nValIcmST
								EndIf
							EndIf

						Else

							nVlIcmDiselA 	:= nQtDiselA * nAdRem 				// ICMS do Diesel A Puro (qtd * adrem)
							nVlIcmB100 		:= nQtdB100	* nIcmPart1				// Qtde de Biodiesel B100 * 1/3 da aliquota da mistura
						
						Endif

					// Produto DIESEL B (misturado)
					ElseIf	cCodProd $ cDieselB

						nQtDiselA 		:= (nQtdNF - (nQtdNF * (nPbio)))		// Qtde de Diesel A utilizado na mistura
						nQtdB100 		:= nQtdNF * nPbio						// Qtde de Biodiesel utilizado na mistura

						If 	cEntSai == "1" // Entrada 
							if cCST <> "61"
								nVlIcmDiselA 	:= nValIcm
								nVlIcmB100 		:= nValIcmST
							Else
								nVlIcmB100 		:= (nQtdNF*nAdRem)*nPbio		// Qtde de Biodiesel utilizado na mistura, esse valor para operações CST 61 vem calculado na Nota calculos com base no valor informado no D1_ICMSNDES	
								nVlIcmDiselA 	:= nICMNDES-nVlIcmB100			// Qtde de Diesel A utilizado na mistura , esse valor é informar no campo D1_ICMSNDES
								      
							Endif
						Else
							
							nVlIcmDiselA 	:= nQtDiselA * nAdRem				// Vlr ICMS correspondente a Qtde de Diesel A utilizada na mistura * alíquota adrem

							nSupostaB100	:= (nQtDiselA / (1-nPbio)) * nPbio	// Quant. Suposta B100 1/3 // Quantidade suposta de B100 -> 88% de diesel A mutiplicado pelo percentual 12%
							nIcmsB100 		:= nSupostaB100 * nIcmPart1			// 1/3 da aliquota multiplico na quantidade de B100
								
							// Valor ICMS Retido Diesel A + B100
							nVlIcmB100 		:= (nQtdB100 * nIcmPart2) + nIcmsB100

						Endif

					// Produto BIODIESEL B100
					ElseIf	cCodProd $ cBiodiesel

						nQtDiselA 		:= 0
						nVlIcmDiselA 	:= 0
						nQtdB100 		:= nQtdNF

						If 	cEntSai == "1" // Entrada
							nVlIcmB100 	:= nValIcm
						Else
							nVlIcmB100 	:= nQtdNF * nIcmPart2
						Endif

					// Produto GASOLINA A (pura)
					ElseIf cCodProd $ cGasolinaA+cGasolinaE+cGasolinaR+cGasolinaO

						/*Informar a Quantidade de Gasolina A (com 3 decimais) ? se produto puro, repetir a quantidade do campo 18; se produto misturado, informar a quantidade na mistura*/
							
						nQtGasolinaA 	:= nQtdNF									// Qtde do Produto Gasolina A
						nVlIcmGasolA 	:= nQtdNF * nAdRem							// Valor do ICMS sobre a Gasolina A
						nQtEtanol 		:= (nQtdNF / (1-nPbio)) * nPbio	            // Qtde suposta do Etanol na mistura
						nVlIcmEtanol 	:= ((nQtdNF /(1-(nPbio)))*nAdRem)*(nPbio)	// Valor do Etanol na Mistura

					// Produto GASOLINA C (misturada)
					Elseif cCodProd $ cGasolinaC
							
						nQtGasolinaC 	:= (nQtdNF - (nQtdNF * (nPbio)))			// Qtde do Produto Gasolina A na mistura
						nVlIcmGasolC 	:= nQtGasolinaC * nAdRem					// Valor do ICMS sobre a Gasolina A contida na mistura. (Com 2 decimais)
						nQtEtanol 		:= (nQtdNF * (nPbio))						// Qtde do Etanol na mistura
						nVlIcmEtanol 	:= nQtEtanol *nAdRem						// Valor do Etanol na Mistura

					// Produto ETANOL (puro)
					Elseif cCodProd $ cEtanolA		// Produto Etanol

						/*Informar a Quantidade de Etanol Anidro (com 3 decimais) ? se produto puro, repetir a quantidade do campo 18; se produto misturado,informar a quantidade na mistura*/							
						
						nQtGasolinaA 	:= 0		// Para o Etanol não a Qtde de mistura com Gasolina porque o Etanol é Puro
						nVlIcmGasolA 	:= 0		// Por não ter % de Mistura de Gasolina com o Etanol não há projeção de valor de ICMS na Gasolina
						nQtEtanol 		:= nQtdNF	// Qtde de Etanol
						nVlIcmEtanol 	:= 0		// Calculo pela memória de Calculo => (nQtdNF*nPbio) * nAdRem

					Endif

				
					If  cCodProd $ cDieselA + cDieselB + cBiodiesel
						
						R45->QTDDIESELA	+= nQtDiselA							// 19 - Quantidade de Óleo Diesel A
						R45->QTDB100 	+= nQtdB100  							// 20 - Quantidade de Biodiesel (B100)
						R45->ALIQADREM  := nAdRem                               // 21 - Alíquota Ad Rem
						R45->ICMDIESELA	+= nVlIcmDiselA							// 22 - Valor do ICMS sobre o Óleo Diesel A
						R45->VLICMSB100	+= nVlIcmB100 							// 23 - Valor do ICMS sobre o Biodiesel (B100)

					ElseIf cCodProd $ cGasolinaA + cGasolinaE + cGasolinaR + cGasolinaO + cEtanolA
						
						R45->QTDDIESELA	+= nQtGasolinaA							// 19 - Quantidade de Gasolina A
						R45->QTDB100 	+= nQtEtanol  							// 20 - Quantidade de Etanol 
						R45->ALIQADREM  := nAdRem                               // 21 - Alíquota Ad Rem
						R45->ICMDIESELA	+= nVlIcmGasolA							// 22 - Valor do ICMS sobre o Óleo Gasolina A
						R45->VLICMSB100	+= nVlIcmEtanol							// 23 - Valor do ICMS sobre o Etanol


					ElseIf cCodProd $ cGasolinaC
						
						R45->QTDDIESELA	+= nQtGasolinaC							// 19 - Quantidade de Gasolina A
						R45->QTDB100 	+= nQtEtanol  							// 20 - Quantidade de Etanol 
						R45->ALIQADREM  := nAdRem                               // 21 - Alíquota Ad Rem
						R45->ICMDIESELA	+= nVlIcmGasolC							// 22 - Valor do ICMS sobre o Óleo Gasolina A
						R45->VLICMSB100	+= nVlIcmEtanol							// 23 - Valor do ICMS sobre o Etanol

					EndIf

					// R45->PLACA3 := Iif( empty(R45->PLACA3),CD6->CD6_PLACA,R45->PLACA3)

				EndIf
				
				/*26, 27, 28 – Origem (Nacional ou Importado), UF de Origem e Percentual por UF de Origem:
				Obrigatório o preenchimento para os produtos B100 Puro e Óleo Diesel B. Refere-se à UF de
				Origem do B100 Puro ou contido na mistura do Óleo Diesel B*/
				// se diesel B ou B100 - deve-se ter o percentual e uf de origem
				If cCodProd $ cBiodiesel+cDieselB + cEtanolA + cGasolinaC + cGasolinaR + cGasolinaO + cGasolinaE  .AND. !Empty(CD6->CD6_UFORIG)
					
					cIndImp := ""										// 26 - Origem do Produto
					cUfOrig := CD6->CD6_UFORIG  						// 27 - UF de Origem do Produto
					cPorig 	:= "000.00"									// 28 - Percentual da UF de Origem

					If !Empty(CD6->CD6_INDIMP)
						cIndImp := CD6->CD6_INDIMP
					EndIf

					If !Empty(CD6->CD6_PORIG)
						cPorig := PadL(AllTrim(Transform((CD6->CD6_PORIG),"@R 999.99")),6,"0")
					EndIf

					cRet += ',"' + cIndImp + '"'
					cRet += ',"' + cUfOrig + '"'
					cRet += ',' + cPorig
				EndIf

				CD6->(DbSkip())
			EndDo
			
		// regra para compor os campos dependentes da CD6 do registro 47
		ElseIf cRegistro == "47"
			
			R47->PERCGLP	+= CD6->CD6_PGLP							// 19 - Proporção GLP (%)
			R47->PERCGLGN	+= CD6->CD6_PGNN							// 20 - Proporção GLGNn (%)
			R47->PERCGLGNI	+= CD6->CD6_PGNI							// 21 - Proporção GLGNi (%)
			R47->ALIQADREM  := CD6->CD6_VALIQ							// 22 - Alíquota Ad Rem
			R47->UFCONSUMO  := CD6->CD6_UFCONS							// 27 - UF de Consumo
			
			While CD6->(CD6_FILIAL+CD6_TPMOV+CD6_SERIE+CD6_DOC+CD6_CLIFOR+CD6_LOJA+CD6_ITEM+CD6_COD) == xFilial("CD6") + cChaveCD6 .AND. ;
					!Empty(CD6->CD6_UFORIG)

				cIndImp := ""
				cUfOrig := CD6->CD6_UFORIG
				cPorig 	:= "000.00"

				If !Empty(CD6->CD6_INDIMP)
					cIndImp := CD6->CD6_INDIMP
				EndIf
				
				If !Empty(CD6->CD6_PORIG)
					cPorig := PadL(AllTrim(Transform((CD6->CD6_PORIG),"@R 999.99")),6,"0")
				EndIf

				cRet += ',"' + cIndImp + '"' 							// 28 - Origem do Produto
				cRet += ',"' + cUfOrig + '"'							// 29 - UF de Origem do Produto
				cRet += ',' + cPorig									// 30 - Percentual dea UF de Origem

				CD6->(DbSkip())
			EndDo

		EndIf
	EndIf

	RestArea(aArea)

Return AllTrim(cRet)

/*/{Protheus.doc} GetSitFrt
Retorna a situação do frete convertido para o arquivo
@type function
@version  12.1.2210
@author rodrigo.ccandido
@since 5/17/2023
@param cEntSai, character, param_description
@param cChvSC7, character, param_description
@param cChvSC5, character, param_description
@return variant, return_description
/*/
Function GetSitFrt(cEntSai, cChvSC7, cChvSC5)

	Local aArea		:= GetArea()
	Local cOpcao    := ""
	Local cSitFrt   := ""
	Local cCmpTpFrt := ""
	Local cTpFrete	:= ""
	Local cAlsSF 	:= "SF1"

	Default cEntSai := "E"
	Default cChvSC7 := ""
	Default cChvSC5 := ""

	If cEntSai == "S"
		cAlsSF := "SF2"
	EndIf

	cCmpTpFrt	:= SubStr(cAlsSF,2,2)+"_TPFRETE"
	cOpcao 		:= (cAlsSF)->(&(cCmpTpFrt)) 

	//C-CIF - Por conta do emitente
	If cOpcao == "C"
		cSitFrt := "0"

	//F-FOB - Por conta do destinatario
	ElseIf cOpcao == "F"
		cSitFrt := "1"

	//T-Por Conta Terceiros
	ElseIf cOpcao == "T"
		cSitFrt := "2"

	//S-Sem Frete
	ElseIf cOpcao == "S"
		cSitFrt  := "9"

	//R = Por conta remetente
	ElseIf cOpcao == "R"
		cSitFrt := "3"

	//D = Por conta destinatário
	ElseIf cOpcao == "D"
		cSitFrt := "4"

	//Se nao encontrar na SF1 pega a informacao da SC7
	ElseIf cEntSai == "E" .AND. !Empty(cChvSC7) .And. SC7->(MsSeek(cChvSC7))
		
		cTpFrete := Alltrim(SC7->C7_TPFRETE)

	//Se nao encontrar na SF2 pega a informacao da SC5
	ElseIf cEntSai == "S" .AND. !Empty(cChvSC5) .And. SC5->(MsSeek(cChvSC5))
		
		cTpFrete := Alltrim(SC5->C5_TPFRETE)
	
	EndIf

	If Empty(cSitFrt)

		//Sem Frete
		If Empty(cTpFrete)
			cSitFrt := "9"

		//Por conta do emitente
		ElseIf cTpFrete == "C"
			cSitFrt := "0"

		//Por conta do destinatario
		ElseIf cTpFrete == "F"
			cSitFrt := "1"

		//Por conta de terceiros
		ElseIf cTpFrete == "T"
			cSitFrt := "2"

		//R = Por conta remetente
		ElseIf cTpFrete == "R"
			cSitFrt := "3"

		//D = Por conta destinatário
		ElseIf cTpFrete == "D"
			cSitFrt := "4"
		EndIf
	
	EndIf
	
	RestArea(aArea)

Return cSitFrt

/*/{Protheus.doc} RegTp47
Registro Tipo 47 – TRIBUTAÇÃO MONOFÁSICA Nota Fiscal GLP/GLGN
@type function
@version  12.1.2210
@author rodrigo.ccandido
@since 7/12/2023
@param cEntSai, character, param_description
@param cAliasTRB, character, param_description
@return variant, return_description
/*/
Static Function RegTp47(cEntSai, cAliasTRB)

	Local cSCANC01 	:= SuperGetMv("MV_SCANC01",,"")

	// placas das entradas
	Local cScanep2 	:= Alltrim(SuperGetMV("MV_SCANEP2",,"")) // placa 2
	Local cScanep3 	:= Alltrim(SuperGetMV("MV_SCANEP3",,"")) // placa 3
	Local lScanep2 	:= DA3->(FieldPos(cScanep2)) > 0
	Local lScanep3 	:= DA3->(FieldPos(cScanep3)) > 0

	//Placa saidas
	Local cScansp1 	:= Alltrim(SuperGetMV("MV_SCANSP1",,"")) // placa 1
	Local cScansp2 	:= Alltrim(SuperGetMV("MV_SCANSP2",,"")) // placa 2
	Local cScansp3 	:= Alltrim(SuperGetMV("MV_SCANSP3",,"")) // placa 3

	Local lInclui	:= .T.
	Local cChaveCD6	:= ""
	Local cCodProd	:= ""
	Local cSeek		:= ""
	Local cTipoICMS	:= "1" // 0 - ICMS cobrado em operação anterior 1 - ICMS cobrado na operação

	Local cAlsSF 	:= "F"+cEntSai	//Determina o Alias para as Tabelas SF1/SF2
	Local cAlsSD	:= "D"+cEntSai	//Determina o Alias para as Tabelas SD1/SD2
	Local cAlsSA	:= ""

	Local cTipoES	:= ""
	Local cCliFor 	:= ""
	Local cLoja   	:= ""
	Local nVlrIcm  	:= ""
	Local cA4CGC 	:= ""
	Local cA4EST 	:= ""
	Local cCST	 	:= ""

	Local lScansp1 	:= SC5->(FieldPos(cScansp1))>0
	Local lScansp2 	:= SC5->(FieldPos(cScansp2))>0
	Local lScansp3 	:= SC5->(FieldPos(cScansp3))>0
	Local lC5Placa 	:= SC5->(FieldPos("C5_PLACA1"))>0 .And. SC5->(FieldPos("C5_PLACA2"))>0

	// campos
	Local cCmpDoc 	:= ""
	Local cCmpSer 	:= ""
	Local cCmpItem 	:= ""
	Local cCmpProd 	:= ""
	Local cCmpQtde 	:= ""
	Local cCmpDtDig := ""
	Local cCmpEspec := ""
	Local cCmpCF 	:= ""
	Local cCmpTrp 	:= ""
	Local cCmpFrete := ""
	Local cCmpTipo 	:= ""
	Local cCmpVeic1 := ""
	Local cCmpVeic2 := ""
	Local cCmpVeic3 := ""
	Local cCmpPlaca := ""
	Local cCmpCgc 	:= ""
	Local cCmpIE  	:= ""
	Local cCmpEst 	:= ""
	Local cCmpVlIcm	:= ""
	
	//Determina o Alias para as Tabelas SA1/SA2
	If cEntSai == "1"
		If !((cAliasTRB)->D1_TIPO $ "BD")
			cAlsSA := "A2"
		Else
			cAlsSA := "A1"
		EndIf
		cTipoES := "E"
		cCliFor := (cAliasTRB)->D1_FORNECE
		cLoja   := (cAliasTRB)->D1_LOJA
	Else
		If (cAliasTRB)->D2_TIPO $ "BD"
			cAlsSA := "A2"
		Else
			cAlsSA := "A1"
		EndIf
		cTipoES := "S"
		cCliFor := (cAliasTRB)->D2_CLIENTE
		cLoja   := (cAliasTRB)->D2_LOJA
	EndIf

	cCmpDoc 	:= cAlsSD+"_DOC"
	cCmpSer 	:= cAlsSD+"_SERIE"
	cCmpItem 	:= cAlsSD+"_ITEM"
	cCmpProd 	:= cAlsSD+"_COD"
	cCmpQtde 	:= cAlsSD+"_QUANT"
	cCmpVlIcm 	:= cAlsSD+"_VALICM"
	cCmpDtDig 	:= cAlsSD+"_EMISSAO"
	cCmpCF 		:= cAlsSD+"_CF"
	cCmpCST		:= cAlsSD+"_CLASFIS"

	cCmpEspec 	:= cAlsSF+"_ESPECIE"
	cCmpTrp 	:= cAlsSF+"_TRANSP"
	cCmpFrete 	:= cAlsSF+"_FRETE"
	cCmpTipo 	:= cAlsSF+"_TIPO"
	cCmpVeic1 	:= cAlsSF+"_VEICUL1"
	cCmpVeic2 	:= cAlsSF+"_VEICUL2"
	cCmpVeic3 	:= cAlsSF+"_VEICUL3"
	cCmpPlaca 	:= cAlsSF+"_PLACA"

	cCmpCgc 	:= cAlsSA+"_CGC"
	cCmpIE  	:= cAlsSA+"_INSCR"
	cCmpEst 	:= cAlsSA+"_EST"
	
	cDoc 		:= (cAliasTRB)->(&(cCmpDoc))
	cSerie 		:= (cAliasTRB)->(&(cCmpSer))
		
	cCST	  := SubStr((cAliasTRB)->(&(cCmpCST)),2,2)
	cTransp   := (cAliasTRB)->(&(cCmpTrp))
	cVeiculo  := (cAliasTRB)->(&(cCmpVeic1))
	cVeiculo2 := (cAliasTRB)->(&(cCmpVeic2))
	cVeiculo3 := (cAliasTRB)->(&(cCmpVeic3))

	If !Empty(cTransp)
		cA4Cgc := aRetDig((cAliasTRB)->A4_CGC,.F.)
		cA4Est := (cAliasTRB)->A4_EST
	EndIf

	cCodProd := StrZero(Val((cAliasTRB)->&(cSCANC01)),9)
	cSeek 	 := cDoc + cSerie + cCodProd
	lInclui  := !R47->(DbSeek(cSeek))

	RecLock("R47",lInclui)
		R47->TIPO		:= "47" 																	// 01 - Tipo de registro
		R47->MES_ANO	:= StrZero(Month(MV_PAR01),2)+StrZero(Year(MV_PAR01),4)						// 02 - Mês/Ano Apuração
		R47->CNPJ		:= Alltrim((cAliasTRB)->(&(cCmpCgc)))										// 03 - CNPJ
		R47->IE			:= Alltrim(aRetDig((cAliasTRB)->(&(cCmpIE)),.T.,(cAliasTRB)->(&(cCmpEst))))	// 04 - Inscrição Estadual
		R47->UF			:= (cAliasTRB)->(&(cCmpEst))												// 05 - UF
		R47->DTEMIS		:= (cAliasTRB)->(&(cCmpDtDig))												// 06 - Data de emissão /recebimento
		R47->MODELO		:= aModNot((cAliasTRB)->(&(cCmpEspec)))										// 07 - Modelo
		R47->SERIE		:= Alltrim((cAliasTRB)->(&(cCmpSer)))										// 08 - Serie
		R47->NUMERO		:= Alltrim((cAliasTRB)->(&(cCmpDoc)))										// 09 - Numero
		R47->CFOP		:= Alltrim((cAliasTRB)->(&(cCmpCF)))										// 10 - CFOP
		R47->TPFRETE 	:= GetSitFrt(cTipoES) 														// 11 - Tipo Frete
		R47->CNPJ_CPF	:= cA4CGC																	// 12 - CNPJ / CPF Transportador
		R47->UFTRANSP	:= cA4EST																	// 13 - UF Transportador
		
		If cEntSai == "1"
			
			cPlaca := (cAliasTRB)->(&(cCmpPlaca))

			If !Empty(cVeiculo) .AND. DA3->(MsSeek(xFilial("DA3")+cVeiculo))
				R47->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 							// 14 - Primeira Placa
			Else
				R47->PLACA1 := Alltrim(StrTran(cPlaca,"-",""))
			EndIf
			
			If !Empty(cVeiculo2) .AND. DA3->(MsSeek(xFilial("DA3")+cVeiculo2))
				If lScanep2 .AND. !Empty(cScanep2) 
					R47->PLACA2 := Alltrim(StrTran(DA3->&(cScanep2),"-",""))
				Else
					R47->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 						// 15 - Segunda Placa
				EndIf
			Else
				R47->PLACA2 := Alltrim(StrTran(cPlaca,"-",""))
			EndIf
			
			If !Empty(cVeiculo3) .AND. DA3->(MsSeek(xFilial("DA3")+cVeiculo3))
				If lScanep3 .AND. !Empty(cScanep3) 
					R47->PLACA3 := Alltrim(StrTran(DA3->&(cScanep3),"-",""))
				Else
					R47->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 						// 16 - Terceira Placa
				EndIf
			Else
				R47->PLACA3 := Alltrim(StrTran(cPlaca,"-",""))
			EndIf

		Else

			SC5->(DbSetOrder(1))
			If SC5->(MsSeek(xFilial("SC5")+Alltrim((cAliasTRB)->D2_PEDIDO)))
				//Placa de Veiculo 1,2 e 3 - tratamento para DLC
				If !Empty(cScansp1) .And. lScansp1 .And. !Empty(SC5->&(cScansp1))
					R47->PLACA1 := Alltrim(StrTran(SC5->&(cScansp1),"-","")) 
					If !Empty(cScansp2) .And. lScansp2 .And. !Empty(SC5->&(cScansp2))
						R47->PLACA2 := Alltrim(StrTran(SC5->&(cScansp2),"-","")) 
					Endif
					If !Empty(cScansp3) .And. lScansp3 .And. !Empty(SC5->&(cScansp3))
						R47->PLACA3 := Alltrim(StrTran(SC5->&(cScansp3),"-","")) 
					Endif
				Endif
				If Empty(R47->PLACA1) .And. Empty(cScansp1)
					//Tratamento para DLC com campos Padroes de placa SC5 e veiculo SF2
					If lC5Placa
						If !Empty(SC5->C5_PLACA1)
							R47->PLACA1 := Alltrim(StrTran(SC5->C5_PLACA1,"-","")) 
						Endif
						If !Empty(SC5->C5_PLACA2)
							R47->PLACA2 := Alltrim(StrTran(SC5->C5_PLACA2,"-","")) 
						Endif
					Endif
				Endif
				//Placa de Veiculo 1 processo padrao sem DLC
				If Empty(R47->PLACA1) .And. !Empty((cAliasTRB)->F2_VEICUL1) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL1))
					R47->PLACA1 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
				Endif
				//Placa de Veiculo 2
				If Empty(R47->PLACA2) .And. !Empty((cAliasTRB)->F2_VEICUL2) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL2))
					R47->PLACA2 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
				Endif
				//Placa de Veiculo 3
				If Empty(R47->PLACA3) .And. !Empty((cAliasTRB)->F2_VEICUL3) .And. DA3->(MsSeek(xFilial("DA3")+(cAliasTRB)->F2_VEICUL3))
					R47->PLACA3 := Alltrim(StrTran(DA3->DA3_PLACA,"-","")) 
				EndIf
			EndIf

		EndIf

		R47->CODPROD 	:= cCodProd															// 17 - Código do Produto
		R47->QTDETOT 	:= (cAliasTRB)->(&(cCmpQtde))										// 18 - Quantidade Total (KG) 

		cChaveCD6 		:= cTipoES + cSerie + cDoc + cCliFor + cLoja + PadR((cAliasTRB)->(&(cCmpItem)),TamSx3("CD6_ITEM")[1]) + (cAliasTRB)->(&(cCmpProd))
		R47->CONJUNTOS 	:= AllTrim(R47->CONJUNTOS) + GetRegsCD6(cChaveCD6, cCodProd, "47", 0, 0, 0, cEntSai, cCST)
		
		nVlrIcm := (cAliasTRB)->(&(cCmpVlIcm))
		R47->VICMGLP	+= ((nVlrIcm/100) * R47->PERCGLP) 									// 23 - Valor do ICMS sobre o GLP
		R47->VICMGLGN	+= ((nVlrIcm/100) * R47->PERCGLGN)									// 24 - Valor do ICMS sobre o GLGNn (Nacional)
		R47->VICMGLGNI	+= ((nVlrIcm/100) * R47->PERCGLGNI)									// 25 - Valor do ICMS sobre o GLGNi (Importado)
		
		If cCST $ "02/15"
			cTipoICMS := "1"  // 1 - ICMS cobrado na operação
		Else
			cTipoICMS := "0" // 0 - ICMS cobrado em operação anterior
		EndIf

		R47->ICMSNOTA := cTipoICMS															// 26 - Informação do ICMS na Nota Fiscal. 0 - ICMS cobrado em operação anterior 1 - ICMS cobrado na operação.
		
	R47->(MsUnlock())

Return

/*/{Protheus.doc} RetFilial
Retorna as filiais da tabela em uma unica string para a query
@type function
@version  12.1.2210
@author rodrigo.ccandido
@since 7/11/2023
@param cAliasTab, character, param_description
@param lAglFil, logical, param_description
@param aFilsCalc, array, param_description
@return variant, return_description
/*/
Static Function RetFilial(cAliasTab, lAglFil, aFilsCalc)

	Local cRet := ""
	Local nFil := 0
	Local nQtd := 0

	If lAglFil
		
		nQtd := Len(aFilsCalc)
		
		For nFil := 1 To nQtd

			If aFilsCalc[nFil][1]
				
				If !Empty(cRet)
					cRet += "/"
				EndIf

				cRet += FWxFilial(cAliasTab,aFilsCalc[nFil][2]) 

			EndIf

		Next nFil
	
	Else
		cRet := FWxFilial(cAliasTab)
	EndIf

	If !Empty(cRet) .AND. !("/" $ cRet)
		cRet += "/"
	EndIf

Return cRet

/*/{Protheus.doc} TabelaAnp
	(long_description)
	@type  Function
	@author Ricardo Henrique de Mello Lima
	@since 09/09/2024
	@version 12.1.2310
	@return aResult, Array, Array com a Tabela ANP separada por tipo de combustivel
	1 - Diesel Tipo A
	2 - Diesel Tipo B
	3 - Biodiesel
	4 - Gasolina Tipo A
	5 - Gasolina Tipo C
	6 - Gasolina Tipo E
	7 - Gasolina Tipo R
	8 - Gasolina Tipo O
	9 - Etanol Tipo A
	/*/
Function TabelaAnp()

	Local aResult := {} 

	Local cDieselA   := "420102004,420102005,420105001,420301002,420201001,420201003" 
	Local cDieselB   := "820101012,820101013,820101033,820101034" 
	Local cBiodiesel := "820101001" 
	Local cGasolinaA := "320101001,320101002,320201001" 
	Local cGasolinaC := "320102001,320102002,320102003,320102005" 
	Local cGasolinaE := "320301002" 
	Local cGasolinaR := "320103003,320103001" 
	Local cGasolinaO := "320301001,320103002" 
	Local cEtanolA   := "810102001,810102004,810102003" 

	aAdd(aResult, StrTokArr(cDieselA  ,","))
	aAdd(aResult, StrTokArr(cDieselB  ,","))
	aAdd(aResult, StrTokArr(cBiodiesel,","))
	aAdd(aResult, StrTokArr(cGasolinaA,","))
	aAdd(aResult, StrTokArr(cGasolinaC,","))
	aAdd(aResult, StrTokArr(cGasolinaE,","))
	aAdd(aResult, StrTokArr(cGasolinaR,","))
	aAdd(aResult, StrTokArr(cGasolinaO,","))
	aAdd(aResult, StrTokArr(cEtanolA  ,","))

Return aResult

/*/{Protheus.doc} validCNPJ()
    Valida se o CNPJ do cliente é do exterior ou não
	@param 		cEst, character, Estado do participante
	@param 		nTamCGC, Tamanho do campo A1_CGC ou A2_CGC
	@param 		cCNPJ, character, CNPJ do A1_CGC ou A2_CGC
	@return		cCNPJRet, character, retorna a aliquota da SD1/SD2 caso os campos do complementos do CIDE estiverem preenchidas, caso contrario retorna a variavel nAdRem sem modificações
	@type		Static Function
	@author 	Matheus Bispo
    @since 		11/02/2024
    @version 	12.1.2410
/*/
Static Function validCNPJ(cEst, nTamCGC, cCNPJ)
	Local cCNPJRet := cCNPJ as character

	If oSX6Cache["MV_ESTADO"] == "PE" .And. cEst == "EX"
		cCNPJRet := StrZero(0, nTamCGC)
	EndIf
	
Return cCNPJRet

/*/{Protheus.doc} validAliqAdRem()
    Valida se pega a alíquota do complemento de combustivel (CD6) ou da nota (SD1)
	Caso o valor da base de cálculo do CIDE esteja com informação
	@param 		nBaseCide, campo CD6_BCCIDE base de calculo do CIDE
	@param 		nAliqCide, campo CD6_VALIQ aliuota do CIDE
	@param 		nValCide, campo CD6_VCIDE valor o CIDE
	@param 		nAdRem, numeric, aliquota calculada do Ad Rem
	@param 		nAliqIcm, numeric, aliquota da tabela SD1/SD2 (D1_PICM/D2_PICM)
	@return		nVal, numeric, retorna a aliquota da SD1/SD2 caso os campos do complementos do CIDE estiverem preenchidas, caso contrario retorna a variavel nAdRem sem modificações
	@type		Static Function
	@author 	Matheus Bispo
    @since 		11/02/2024
    @version 	12.1.2410
/*/
Static Function validAliqAdRem(nBaseCide, nAliqCide, nValCide, nAdRem, nAliqIcm)
	Local nVal := nAdRem as numeric

	//Se os campos relacionados ao CIDE estiverem preenchidos, pego a aliquota da SD1/SD2
	If !Empty(nBaseCide) .And. !Empty(nAliqCide) .And. !Empty(nValCide) .And. !Empty(nAliqIcm)
		nVal := nAliqIcm
	EndIf
	
Return nVal

/*/{Protheus.doc} getParamSX6()
    Cria uma variável Json para fazer cache de Parâmetros SX6
	@param 		nil, nil, não há
	@return		nil, nil, não há
	@type		Static Function
	@author 	Matheus Bispo
    @since 		11/02/2024
    @version 	12.1.2410
/*/
Static Function getParamSX6()
	FreeObj(oSX6Cache)
	oSX6Cache := JsonObject():new()

	oSX6Cache["MV_ESTADO"] := Alltrim(GetNewPar("MV_ESTADO", ""))
	oSX6Cache["MV_SCANC01"] := Alltrim(GetNewPar("MV_SCANC01", ""))
	oSX6Cache["MV_SCANC12"] := Val(cValToChar(GetNewPar("MV_SCANC12", ""))) //Este parâmetro foi criado como character, porém no fonte tem uma função númerica, avaliar a possibilidade de alterar o tipo dele via pacote de dicionário (ATUSX)
	oSX6Cache["MV_SCANC13"] := GetNewPar("MV_SCANC13", 0)
	oSX6Cache["MV_SCANC14"] := GetNewPar("MV_SCANC14", 0)
	oSX6Cache["MV_SCANC15"] := Alltrim(GetNewPar("MV_SCANC15", ""))
	oSX6Cache["MV_PROGASA"] := Alltrim(GetNewPar("MV_PROGASA", ""))
	oSX6Cache["MV_PROGASC"] := Alltrim(GetNewPar("MV_PROGASC", ""))
	oSX6Cache["MV_PRODIB"] := Alltrim(GetNewPar("MV_PRODIB", ""))
	oSX6Cache["MV_PRODIE"] := Alltrim(GetNewPar("MV_PRODIE", ""))
	oSX6Cache["MV_SCANEP2"] := Alltrim(GetNewPar("MV_SCANEP2", ""))
	oSX6Cache["MV_SCANEP3"] := Alltrim(GetNewPar("MV_SCANEP3", ""))
	oSX6Cache["MV_SCANSP1"] := Alltrim(GetNewPar("MV_SCANSP1", ""))
	oSX6Cache["MV_SCANSP2"] := Alltrim(GetNewPar("MV_SCANSP2", ""))
	oSX6Cache["MV_SCANSP3"] := Alltrim(GetNewPar("MV_SCANSP3", ""))
Return

/*/{Protheus.doc} getFieldPos()
    Cria uma variável Json para fazer cache se o campo SX3 existe na base de dados
	@param 		nil, nil, não há
	@return		nil, nil, não há
	@type		Static Function
	@author 	Matheus Bispo
    @since 		11/02/2024
    @version 	12.1.2410
/*/
Static Function getFieldPos()
	FreeObj(oSX3Cache)
	oSX3Cache := JsonObject():new()

	oSX3Cache[oSX6Cache["MV_SCANEP2"]] := DA3->(FieldPos(oSX6Cache["MV_SCANEP2"])) > 0
	oSX3Cache[oSX6Cache["MV_SCANEP3"]] := DA3->(FieldPos(oSX6Cache["MV_SCANEP3"])) > 0
	oSX3Cache[oSX6Cache["MV_SCANSP1"]] := SC5->(FieldPos(oSX6Cache["MV_SCANSP1"])) > 0
	oSX3Cache[oSX6Cache["MV_SCANSP2"]] := SC5->(FieldPos(oSX6Cache["MV_SCANSP2"])) > 0
	oSX3Cache[oSX6Cache["MV_SCANSP3"]] := SC5->(FieldPos(oSX6Cache["MV_SCANSP3"])) > 0
	oSX3Cache["C5_PLACA1"] := SC5->(FieldPos("C5_PLACA1")) > 0
	oSX3Cache["C5_PLACA2"] := SC5->(FieldPos("C5_PLACA2")) > 0
	oSX3Cache[oSX6Cache["MV_SCANC01"]] := SB5->(FieldPos(oSX6Cache["MV_SCANC01"])) > 0
Return

/*/{Protheus.doc} getTamSX3()
    Cria uma variável Json para fazer cache do tamanho do campo SX3 (TamSX3)
	@param 		nil, nil, não há
	@return		nil, nil, não há
	@type		Static Function
	@author 	Matheus Bispo
    @since 		11/02/2024
    @version 	12.1.2410
/*/
Static Function getTamSX3()
	FreeObj(oTamSX3)
	oTamSX3 := JsonObject():new()

	oTamSX3["A2_COD"] := FwSX3Util():GetFieldStruct("A2_COD")[3]
	oTamSX3["A2_LOJA"] := FwSX3Util():GetFieldStruct("A2_LOJA")[3]
	oTamSX3["A2_INSCR"] := FwSX3Util():GetFieldStruct("A2_INSCR")[3]
	oTamSX3["A2_CGC"] := FwSX3Util():GetFieldStruct("A2_CGC")[3]
	oTamSX3["A1_COD"] := FwSX3Util():GetFieldStruct("A1_COD")[3]
	oTamSX3["A1_LOJA"] := FwSX3Util():GetFieldStruct("A1_LOJA")[3]
	oTamSX3["A1_CGC"] := FwSX3Util():GetFieldStruct("A1_CGC")[3]
	oTamSX3["F2_DOC"] := FwSX3Util():GetFieldStruct("F2_DOC")[3]
	oTamSX3["B1_COD"] := FwSX3Util():GetFieldStruct("B1_COD")[3]
	oTamSX3["B1_TIPO"] := FwSX3Util():GetFieldStruct("B1_TIPO")[3]
	oTamSX3["CD6_ITEM"] := FwSX3Util():GetFieldStruct("CD6_ITEM")[3]
Return
