#include "totvs.ch"
#include "fileio.ch"
#include "ofcnhprim.ch"

/*/{Protheus.doc} OFCNHPrim
	Classe principal de controle do PRIM
	@type function
	@author Vinicius Gati
	@since 16/01/2018
/*/
Class OFCNHPrim
	Data oCanalVenda
	Data oSubCanal
	Data aDados
	Data oArrHelper
	Data oSqlHlp
	Data aFile
	Data oCfg

	METHOD New() CONSTRUCTOR
	Method CodArqEst()
	Method CodArqVen()
	Method CodDev()
	Method CodNaoDev()
	Method CodCanc()
	Method CodNaoCanc()
	Method CodVendNor()
	Method CodVendAnor()
	Method SubCanalPadrao()
	Method CodGerNormal()
	Method CodGerExcepcional()
	Method PRIMPadrao()
	Method ProcessaPRIM1()
	Method ProcessaLinha()
	Method GeraArquivo()
	Method GeraDados()
	Method Formata()
	Method CriaHeader()
	Method CriaSeparador()
	Method CriaLinhaEstoque()
	Method CriaLinhaVenda()
	Method getDemanda()
	Method removeAcentos()
ENDCLASS

Method New( oConf ) Class OFCNHPrim
default oConf := OFCNHPrimConfig():New(.T.)

	::oCanalVenda  := OFCNHPrimCanalVenda():New()
	::oSubCanal    := OFCNHPrimSubCanalVenda():New()
	::aDados       := {}
	::oArrHelper   := DMS_ArrayHelper():New()
	::oSqlHlp      := DMS_SqlHelper():New()
	::aFile        := {}
	::oCfg         := oConf
Return SELF

/*/{Protheus.doc} CodDev
	Valor padrao campo de devolucao no PRIM2
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodDev() Class OFCNHPrim
Return 'S'

/*/{Protheus.doc} CodNaoDev
	Valor padrao campo de nao devolucao no PRIM2
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodNaoDev() Class OFCNHPrim
Return 'N'

/*/{Protheus.doc} CodCanc
	Valor padrao campo de cancelamento no PRIM2
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodCanc() Class OFCNHPrim
Return 'Y'

/*/{Protheus.doc} CodNaoCanc
	Valor padrao campo de naio cancelamento no PRIM2
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodNaoCanc() Class OFCNHPrim
Return 'N'

/*/{Protheus.doc} CodVendNor
	Valor padrao campo de tipo demanda normal no PRIM2
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodVendNor() Class OFCNHPrim
Return '0'

/*/{Protheus.doc} CodVendAnor
	Valor padrao campo de tipo demanda anormal/excepcional no PRIM2
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodVendAnor() Class OFCNHPrim
Return '1'

/*/{Protheus.doc} CodArqEst
	Codigo identificador de linha do arquivo prim2 para estoque
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodArqEst() Class OFCNHPrim
Return 'E'

/*/{Protheus.doc} CodArqVen
	Codigo identificador de linha do arquivo prim2 para venda
	@type function
	@author Vinicius Gati
	@since 27/02/2018
/*/
Method CodArqVen() Class OFCNHPrim
Return 'V'

/*/{Protheus.doc} SubCanalPadrao
	Subcanal padrao quando o client não tiver no cadastro
	@type function
	@author Vinicius Gati
	@since 10/04/2018
/*/
Method SubCanalPadrao() Class OFCNHPrim
Return "C1"

/*/{Protheus.doc} CodGerNormal
	Código padrão da geracao Normal
	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method CodGerNormal() Class OFCNHPrim
Return 'G'

/*/{Protheus.doc} CodGerExcepcional
	Código padrão da geracao Excepcional
	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method CodGerExcepcional() Class OFCNHPrim
Return 'E'

/*/{Protheus.doc} PRIMPadrao
	Retorna dados de um PRIM gerado automaticamente no dia
	@type function
	@author Vinicius Gati
	@since 01/03/2018
/*/
Method PRIMPadrao( cParamFil ) Class OFCNHPrim
local cCodGer    := ::CodGerNormal() // ::CodGerExcepcional()
local aWareHouse := { "N01", "D01", "F01" }
local nI

	::aDados     := {}
	for nI := 1 to len( aWareHouse )
		aAdd( ::aDados, { cParamFil, aWareHouse[nI], dDatabase, dDatabase, .T. /*gera estoque*/, dDatabase, cCodGer, .T. /*gera venda*/, '', '', '', '' } )
	next
return ::aDados


/*/{Protheus.doc} GeraArquivo
	Gera o arquivo prim2 de acordo com os cabecalhos e retorna o local do arquivo completo
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method GeraArquivo(aCodVBB, cTpPrim ) Class OFCNHPrim
local nX         := 1
local cQuery     := ""
local cInCodVbb  := "('" + self:oArrHelper:Join(aCodVBB, "','") + "')"
local cDep       := ''
local cPath      := lower( "/CNH/" + ::oCfg:cDealerCode + alltrim( ::oCfg:oConfig["DIR_OUT"] ) )

	oLogger:Log({"TIMESTAMP", STR0001})		//#'Iniciando geração do arquivo em disco'

	cQuery := "SELECT VBB_CODIGO, VBB_LOCCNH, VBB_CODPRG " + CRLF
	cQuery += " FROM " + retsqlname('VBB') + CRLF
	cQuery += " WHERE VBB_FILIAL = '"+xFilial('VBB')+"' AND VBB_CODIGO IN "+cInCodVbb+" AND D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " ORDER BY VBB_LOCCNH, VBB_CODPRG, VBB_TIPGER" + CRLF
	aDados := self:oSqlHlp:GetSelectArray(cQuery, 2)		// ordena por armazem D01, F01 e N01
	for nX := 1 to LEN(aDados)
		if ! Empty(cDep) .AND. cDep != aDados[nX, 2]
			AADD(self:aFile, self:CriaSeparador())
		endif
		self:GeraDados(aDados[nX, 1], oLogger)
		cDep := aDados[nX, 2]
	next

	oFile := FwFileWriter():New(cPath + cTpPrim + "_"+xFilial('VS3')+"_"+DTOS(dDatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".DAT", .T.)
	oFile:Create()
	oFile:Close()
	oFile:Open(FO_WRITE)
	For nX:= 1 to Len(self:aFile)
		oFile:write(self:aFile[nX])
	Next
	oFile:Close()
	iif (IsSrvUnix(),CHMOD( cPath + oFile:getFileName() , 7677,,.f. ),CHMOD( cPath + oFile:getFileName() , 2,,.f. ))

Return oFile:getFileName()

/*/{Protheus.doc} GeraDados
	Busca e adiciona os dados corretos no arquivo
	@type function
	@author Vinicius Gati
	@since 24/04/2018
/*/
Method GeraDados(cCodVbb, oLogger, isLast) Class OFCNHPrim
local cAl        := GetNextAlias()
local cVBBAtu    := ''
local cQuery
local aBind      := {}

	oLogger:Log({"TIMESTAMP", '    |> '+ STR0005 })		//#Gravando estoque
	// Gera estoque
	cQuery := "select VBC.R_E_C_N_O_ recno_vbc, VBB.R_E_C_N_O_ recno_vbb, *" + CRLF
	cQuery += " from "+ retSqlName("VBB")+ " VBB " + CRLF
	cQuery += " left join "+ retSqlName("VBC")+ " VBC " + CRLF
	cQuery += 	" on VBC_FILIAL = VBB_FILIAL and VBC_CODVBB = VBB_CODIGO and VBC.D_E_L_E_T_=?" + CRLF
	cQuery += " where VBB_FILIAL=?" + CRLF
	cQuery += " and   VBB_CODIGO=?" + CRLF
	cQuery += " and   VBB_IDENTI=?" + CRLF
	cQuery += " and   VBB.D_E_L_E_T_=?" + CRLF
	cQuery += " order by VBB_FILIAL, VBB_LOCCNH, VBC_CODVBB, VBC_CODIGO" + CRLF
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("VBB") } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', 'ST' } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		if Empty(cVBBAtu) .OR. (cAl)->VBB_CODIGO != cVBBAtu
			cVBBAtu := (cAl)->VBB_CODIGO
			AADD(self:aFile, self:CriaHeader(cAl))
		endif
		cAux := self:CriaLinhaEstoque(cAl)
		if ! empty( cAux )
			AADD(self:aFile, cAux )
		endif

		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP", '    |> '+STR0003})		//#Finalizado

	oLogger:Log({"TIMESTAMP", '    |> '+ STR0006 })//Gravando Vendas de Peças
	//Gera vendas - PEÇAS
	cVBBAtu := ''
	aBind := {}
	cQuery := "select VBD.R_E_C_N_O_ recno_vbd, VBB.R_E_C_N_O_ recno_vbb, *" + CRLF
	cQuery += " from "+ retSqlName("VBB") + " VBB " + CRLF
	cQuery += " left join "+ retSqlName("VBD") + " VBD " + CRLF
	cQuery += " on VBD_FILIAL=VBB_FILIAL and VBD_CODVBB=VBB_CODIGO and VBD_CANALV <> ? and VBD.D_E_L_E_T_=?" + CRLF
	cQuery += " where VBB_FILIAL=?" + CRLF
	cQuery += " and   VBB_CODIGO=?" + CRLF
	cQuery += " and   VBB_IDENTI=?" + CRLF
	cQuery += " and   VBB.D_E_L_E_T_=?" + CRLF
	cQuery += " order by VBB_FILIAL, VBB_LOCCNH, VBD_CODVBB, VBD_CODIGO" + CRLF
	aAdd( aBind, { 'C', ::oCanalVenda:CanalServicos() } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("VBB") } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', 'SE' } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		if Empty(cVBBAtu) .OR. (cAl)->VBB_CODIGO != cVBBAtu
			cVBBAtu := (cAl)->VBB_CODIGO
			AADD(self:aFile, self:CriaHeader(cAl))
		endif
		cAux := self:CriaLinhaVenda(cAl)
		if ! empty( cAux )
			AADD(self:aFile, cAux)
		endif

		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP", '    |> '+STR0003})		//#Finalizado

	oLogger:Log({"TIMESTAMP", '    |> '+ STR0007 })//"Gravando Vendas de Serviços"
	//Gera vendas - SERVIÇOS
	aBind := {}
	cQuery := "select VBD.R_E_C_N_O_ recno_vbd, VBB.R_E_C_N_O_ recno_vbb, *" + CRLF
	cQuery += " from "+ retSqlName("VBB") + " VBB " + CRLF
	cQuery += " join "+ retSqlName("VBD") + " VBD " + CRLF
	cQuery += " on VBD_FILIAL=VBB_FILIAL and VBD_CODVBB=VBB_CODIGO and VBD_CANALV=? and VBD.D_E_L_E_T_=?" + CRLF
	cQuery += " where VBB_FILIAL=?" + CRLF
	cQuery += " and   VBB_CODIGO=?" + CRLF
	cQuery += " and   VBB_IDENTI=?" + CRLF
	cQuery += " and   VBB.D_E_L_E_T_=?" + CRLF
	cQuery += " order by VBB_FILIAL, VBB_LOCCNH, VBD_CODVBB, VBD_CODIGO" + CRLF
	aAdd( aBind, { 'C', ::oCanalVenda:CanalServicos() } )
	aAdd( aBind, { 'C', ' ' } )
	aAdd( aBind, { 'C', xFilial("VBB") } )
	aAdd( aBind, { 'C', cCodVBB } )
	aAdd( aBind, { 'C', 'SE' } )
	aAdd( aBind, { 'C', ' ' } )
	OFCNHA015C_ExecQuery( @cQuery, aBind, cAl )
	While ! (cAl)->(Eof())
		cAux := self:CriaLinhaVenda(cAl)
		if ! empty( cAux )
			AADD(self:aFile, cAux)
		endif
		(cAl)->(DBSkip())
	enddo
	(cAl)->(DBCloseArea())
	oLogger:Log({"TIMESTAMP", '    |> '+STR0003})		//#Finalizado
Return .t.

/*/{Protheus.doc} Formata
	Formatara os dados de acordo com o tamanho necesário para envio no arquivo
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method Formata(uVal, nSize, nDec, lZeroEsq) Class OFCNHPrim
local cValorFmt  := ""
local nFalta     := 0
local cCompleta  := ''
default lZeroEsq := .F.
default nDec     := 0

	if ValType(uVal) == "C"
		cValorFmt := STRTRAN(uVal, "'", "")
		cValorFmt := STRTRAN(uVal, '"', "")
	elseif ValType(uVal) == "N"
		lZeroEsq  := .T. // padrão numerico sempre completar com zero a esquerda
		cValorFmt := strZero( uVal, nSize, nDec )
		cValorFmt := strTran( cValorFmt, ".", "" )
	elseif ValType(uVal) == "D"
		cValorFmt := DTOS(uVal)
	endif

	if LEN(cValorFmt) < nSize
		nFalta    := nSize - LEN(cValorFmt)
		cCompleta := Space(nFalta)
		if lZeroEsq
			cCompleta := STRTRAN(cCompleta, ' ', '0')
			cValorFmt := cCompleta + cValorFmt
		else
			cValorFmt :=  cValorFmt + cCompleta
		end
	else
		cValorFmt := padR(cValorFmt, nSize)
	endif
Return cValorFmt

/*/{Protheus.doc} CriaHeader
	Cria header do prim2 por via de um VBB
	@type function
	@author Vinicius Gati
	@param cAl, alias usado para coletar os dados para o header
	@param cSeq, Sequencia de cabecalhos enviado
	@since 05/03/2018
/*/
Method CriaHeader(cAl) Class OFCNHPrim
local   cLin1    := ""
local   cLin2    := ""
local   cLin     := ""
local   lEstoque := (cAl)->VBB_IDENTI == "ST"
local   cQuery
																									// Seq  Tam   Descrição				
	cLin := "T"																						// 01 - 001 - Registro de Cabeçalho
	cLin += (cAl)->VBB_IDENTI																		// 02 - 002 - ST=Estoque e SE=Venda
//	if lEstoque .and. ! Empty((cAl)->VBB_DATP01)
//		cLin += self:Formata( (cAl)->VBB_DATP01, 14)													// 03 - 014 - Data/hora inicio extração
//	else
		cLin += (cAl)->VBB_DATA2 + (cAl)->VBB_HORA2														// 03 - 014 - Data/hora inicio extração
//	endif
	cLin += (cAl)->VBB_DATA + (cAl)->VBB_HORA														// 04 - 014 - Data/hora termino extração
	cLin += "01" // fixo																			// 05 - 002 - Código corporativo - fixo
	cLin += (cAl)->VBB_CODMER																		// 06 - 004 - Código Mercado: BR11=Construção e BR13=Agrícula
	cLin += self:Formata((cAl)->VBB_CODUNI, 7,, .F.)												// 07 - 007 - Código Unidade do Concessionário
	cLin += (cAl)->VBB_LOCCNH																		// 08 - 003 - Código Armazém CNH: F01=Gerenciados; D01=Venda Direta e N01=Não Gerenciados
	cLin += " " // sempre em branco segundo apostila												// 09 - 001 - Sinal de quantidade de venda
	cLin += self:Formata( int((cAl)->VBB_FILEQU*1000), 15,, .T.)									// 10 - 015 - Quantidade do arquivo
	cLin += (cAl)->VBB_CATTRA																		// 11 - 001 - Categoria transmissão: G=PRIM2 e E=PRIM1
	cLin += (cAl)->VBB_CODPRG																		// 12 - 007 - Número progressivo da transmissão
	cLin += self:Formata((cAl)->VBB_NUMREG, 8,, .T.)												// 13 - 008 - Número do registro, soma das vendas
	if lEstoque
		cLin += "040" // fixo segundo apostila									Estoque					// 14 - 003 - Código da Moeda
		cLin += Space(9)																				// 15 - 009 - campo livre
	else																//		Venda
		cLin += Space(10)																				// 14 - 010 - campo livre
	endif
	cLin1 := LEFT(cLin, 200)
	cLin2 := Substr(cLin, 201, Len(cLin) - 200 )

	cQuery := "UPDATE " + retsqlname('VBB') + CRLF
	cQuery += " SET VBB_NUMRE1=?," + CRLF
	cQuery += " VBB_NUMRE2=?" + CRLF
	cQuery += " WHERE R_E_C_N_O_=?" + CRLF
	OFCNHA015C_ExecQuery( @cQuery, { { 'C', cLin1 }, { 'C', cLin2 }, { 'N', (cAl)->recno_vbb } } )
Return cLin + CRLF

/*/{Protheus.doc} CriaLinhaEstoque
	Cria linha de estoque para arquivo prim2
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method CriaLinhaEstoque(cAl) Class OFCNHPrim
local cLin    := ""
local cLin1   := ""
local cLin2   := ''
local cCodFab := alltrim( posicione( "SB1",1, xFilial("SB1") + (cAl)->VBC_PRODUT , "B1_CODFAB" ) )
//local nQtdBack := (cAl)->( iif( VBC_BACKOR > 0 , VBC_BACKOR - (VBC_QTDEST+VBC_QTDRES), 0 ) )// DEVO SOMAR A RESERVA À QUANTIDADE EM ESTOQUE PARA OBTER A QUANTIDADE PENDENTE PARA BACKORDER?
local cQuery

//	if (cAl)->( VBC_QTDEST + VBC_QTDENC + VBC_QTDRES ) + nQtdBack > 0 .or. ::CodGerExcepcional() == (cAl)->VBB_CATTRA
	if ! empty( cCodFab )
																												// Seq  Tam   Descrição				
		cLin += 'L'																								// 01 - 001 - Identificação de linha de registro 
		cLin += 'ST'																							// 02 - 002 - Identificação do registro ST=Estoque
		cLin += self:Formata( cCodFab, 20,, .F.)																// 03 - 020 - Código do item - partnumber
		cLin += ' '																								// 04 - 001 - Sinal de quantidade
		cLin += self:Formata((cAl)->VBC_QTDEST, 12,3, .T.)														// 05 - 012 - Quantidade em Estoque
		cLin += ' '																								// 06 - 001 - Sinal de quantidade
		cLin += self:Formata((cAl)->VBC_QTDENC, 12,3, .T.)														// 07 - 012 - Quantidade Encomendada
		cLin += ' '																								// 08 - 001 - Sinal de quantidade
		cLin += self:Formata((cAl)->VBC_BACKOR, 12,3, .T.)														// 09 - 012 - Quantidade Pendente - BackOrder
		cLin += self:Formata( iif( empty((cAl)->VBC_ULTSAI ), "19900101", (cAl)->VBC_ULTSAI ),  8,, .F.)		// 10 - 008 - Ultima saída
		cLin += self:Formata( iif( empty((cAl)->VBC_ULTENT ), "19900101", (cAl)->VBC_ULTENT ),  8,, .F.)		// 11 - 008 - Ultima entrada
		cLin += self:Formata((cAl)->VBC_LOCCAO,  8,, .F.)														// 12 - 008 - Localização do item (BZ_LOCALIZ ou B5_LOCALI2)
		cLin += self:Formata((cAl)->VBC_CUSMED, 10,2, .T.)														// 13 - 010 - Custo médio
		cLin += IIF((cAl)->VBC_ESTOCA == 'S', '0', '9')															// 14 - 001 - Indicador estocagem: 0=Permite; 9=Não permite
		cLin += self:Formata((cAl)->VBC_ESTMIN, 12,3, .T.)														// 15 - 012 - Quantidade estoque mínimo
		cLin += self:Formata((cAl)->VBC_QTDRES, 12,3, .T.)														// 16 - 012 - Quantidade reservada
		cLin += self:Formata((cAl)->VBC_FUTRES, 12,3, .T.)														// 17 - 012 - Quantidade reserva futura
		cLin += self:Formata((cAl)->VBC_DESPRO, 25)																// 18 - 025 - Descrição do item
		cLin += self:Formata((cAl)->VBC_CODFOR, 10,, .F.)														// 19 - 010 - Código do fornecedor
		cLin += (cAl)->VBC_FORNAM																				// 20 - 020 - Nome do fornecedor
		cLin += Space(142)																						// 21 - 142 - Campo livre
		cLin1 := LEFT(cLin, 200)
		cLin2 := Substr(cLin, 201, Len(cLin) - 200 )
		cLin += CRLF

		cQuery := "UPDATE " + retsqlname('VBC') + CRLF
		cQuery += " SET VBC_NUMRE1=?," + CRLF
		cQuery += " VBC_NUMRE2=?" + CRLF
		cQuery += " WHERE R_E_C_N_O_=?" + CRLF
		OFCNHA015C_ExecQuery( @cQuery, { { 'C', cLin1 }, { 'C', cLin2 }, { 'N', (cAl)->recno_vbc } } )
	endif
Return self:removeAcentos(cLin)

/*/{Protheus.doc} CriaLinhaVenda
	Cria linha de venda
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method CriaLinhaVenda(cAl) Class OFCNHPrim
local cLin := cLin1 := cLin2 := ''
local cNumNf  := padR((cAl)->VBD_NUMNFI,9) + padR((cAl)->VBD_SERORI,3)
local isServ  := (cAl)->VBD_CANALV == ::oCanalVenda:CanalServicos()
local cNumOri

	if ! empty( (cAl)->VBD_CODCLI )

		if (cAl)->VBD_NUMSEQ $ "AJ.EST/VD_OUT"
			cNumOri := padR(cNumNf, 13)
		elseif isServ
			cNumOri := "M" + subStr( (cAl)->VBD_NUMORI, 2, 7 ) + (cAl)->VBD_TIPTEM + right((cAl)->VBD_SQCANC,1)
		else
			cNumOri := subStr( (cAl)->VBD_NUMORI, 2, 7 ) + (cAl)->VBD_TIPTEM + right((cAl)->VBD_SQCANC,1) + iif( (cAl)->VBD_INDDEV == 'S', "D", " " )
		endif

		if alltrim( (cAl)->VBD_NUMNFI ) == "INTERNO"
			cNumNf := cNumOri
		endif
																									// Seq  Tam   Descrição				
		cLin += 'L'																					// 01 - 001 - L = Registro
		cLin += 'SE'																				// 02 - 002 - SE = Registro Venda
		cLin += self:Formata((cAl)->VBD_CDCLI2, 8)													// 03 - 008 - Código cliente na ordem de venda
		cLin += self:Formata(self:oCfg:cDealerCode, 8)												// 04 - 008 - Código concessionário
		cLin += self:Formata((cAl)->VBD_NOMCLI, 20)													// 05 - 020 - Nome cliente
		cLin += self:Formata((cAl)->VBD_ENDCLI, 50)													// 06 - 050 - Enderço cliente
		cLin += self:Formata((cAl)->VBD_CLICEP,  5)													// 07 - 005 - CEP cliente
		cLin += self:Formata((cAl)->VBD_CLCNPJ, 11)													// 08 - 011 - CNPJ 99.999.999/_999-__
		cLin += cNumOri																				// 09 - 013 - Número da ordem de venda
		cLin += self:Formata((cAl)->VBD_LINVEN,  4)													// 10 - 004 - Número do item da venda
		cLin += self:Formata(cNumNf, 13)															// 11 - 013 - Número NF remessa
		cLin += self:Formata(cNumNf, 13)															// 12 - 013 - Número NF venda
		cLin += self:Formata((cAl)->VBD_DATORI,  8)													// 13 - 008 - Data pedido
		cLin += self:Formata((cAl)->VBD_DATNFI,  8)													// 14 - 008 - Data NF remessa
		cLin += self:Formata((cAl)->VBD_DATNFI,  8)													// 15 - 008 - Data NF venda
		cLin += self:Formata((cAl)->VBD_CANALV,  1)													// 16 - 001 - Canal venda: A,B,C,D,G,3,4,V
		cLin += self:Formata((cAl)->VBD_CODGAR,  1)													// 17 - 001 - Garantia: A,D,Z
		cLin += self:Formata((cAl)->VBD_SUBCAN,  2)													// 18 - 002 - Sub canal de vendas
		cLin += self:Formata((cAl)->VBD_PRODUT, 20)													// 19 - 020 - Código produto
		cLin += iif( (cAl)->VBD_NUMSEQ == "AJ.EST", '-', ' ' )										// 20 - 001 - Sinal quantidade pedido
		cLin += self:Formata((cAl)->VBD_QTDPED, 12, 3)												// 21 - 003 - Quantidade pedido
		cLin += iif( (cAl)->VBD_NUMSEQ == "AJ.EST", '-', ' ' )										// 22 - 001 - Sinal quantidade remessa
		cLin += self:Formata( IIF( empty( (cAl)->VBD_DATNFI ), 0, (cAl)->VBD_QTDFAT ), 12, 3)		// 23 - 012 - Quantidade remessa
		cLin += iif( (cAl)->VBD_NUMSEQ == "AJ.EST", '-', ' ' )										// 24 - 001 - Sinal quantidade faturada
		cLin += self:Formata( IIF( empty( (cAl)->VBD_NUMNFI ), 0, (cAl)->VBD_QTDFAT ), 12, 3)		// 25 - 012 - Quantidade faturada
		cLin += self:Formata((cAl)->VBD_HORMOB,  7)													// 26 - 007 - Horas de mão de obra
		cLin += (cAl)->VBD_TIPDEM																	// 27 - 001 - Indicador demanda excepcional
		if isServ														// Serviço
			cLin += "0"																					// 28 - 001 - Flag retorno
			cLin += IIF( (cAl)->VBD_INDCAN == 'N' , ' ', 'Y' )											// 29 - 001 - Indicador de cancelamento
			cLin += self:Formata(iif( (cAl)->VBD_VALVDA<0, 0, (cAl)->VBD_VALVDA ), 10, 2)				// 30 - 010 - Valor dos serviços
			cLin += self:Formata( 0, 10, 2 )															// 31 - 010 - Custo médio
		else															// Peças
			cLin += IIF( (cAl)->VBD_INDDEV == 'N' , '0', '1' )											// 28 - 001 - Indicador de devolução
			cLin += IIF( (cAl)->VBD_INDCAN == 'N' , ' ', 'Y' )											// 29 - 001 - Indicador de cancelamento
			cLin += self:Formata(iif( (cAl)->VBD_VALVDA<0, 0, (cAl)->VBD_VALVDA ), 10, 2)				// 30 - 010 - Preço de venda
			cLin += self:Formata(iif( (cAl)->VBD_CUSMED<0, 0, (cAl)->VBD_CUSMED ), 10, 2)				// 31 - 010 - Custo médio
		endif
		cLin += '040'																				// 32 - 003 - Código da moeda
		cLin += self:Formata((cAl)->VBD_CHASSI, 17)													// 33 - 017 - Número identificação veículo
		cLin += self:Formata((cAl)->VBD_HORKIL,  6)													// 34 - 006 - Kilometragem
		cLin += self:Formata((cAl)->VBD_FABRIC, 12)													// 35 - 012 - Fabricante
		cLin += self:Formata((cAl)->VBD_MODELO, 12)													// 36 - 012 - Modelo
		cLin += self:Formata((cAl)->VBD_MOTCOM,  9)													// 37 - 009 - Motivo da compra
		cLin += Space(6)																			// 38 - 006 - Campo livre
		cLin1 := LEFT(cLin, 200)
		cLin2 := Substr(cLin, 201, Len(cLin) - 200 )
		VBD->( dbGoto( (cAl)->recno_vbd ) )
		reclock("VBD", .F.)
		VBD->VBD_NUMRE1 := cLin1
		VBD->VBD_NUMRE2 := cLin2
		msUnlock()
		cLin += CRLF
	endif
Return self:removeAcentos(cLin)


/*/{Protheus.doc} CriaSeparador
	Cria separador para arquivo PRIM02 conforme apostila
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method CriaSeparador() Class OFCNHPrim
Return 'X' + CRLF


/*/{Protheus.doc} ProcessaPRIM1
	Vai ler o arquivo, logar a importação, criar e retornar blocos do que deve<br>
	ser feito de geração
	@type function
	@author Vinicius Gati
	@since 01/03/2018
/*/
Method ProcessaPRIM1(oLogger, cFile) Class OFCNHPrim
default oLogger := DMS_Logger():New()

	oFile := FWFileReader():New(cFile)
	if oFile:Open()
		while oFile:HasLine()
			cLinha := oFile:GetLine()
			self:ProcessaLinha(cLinha)
		end
		oFile:Close()
	endif

	cTblLogCod := oLogger:LogToTable({;
		{'VQL_AGROUP'     , 'PRIM'                                              },;
		{'VQL_TIPO'       , 'PRIM01'                                            },;
		{'VQL_DADOS'      , 'PRIM01 ' +STR0004+' ['+cFile+']' } ;		//#importado com sucesso
	})
	oLogger:CloseOpened(cTblLogCod)
Return self:aDados

/*/{Protheus.doc} ProcessaLinha
	Processa linha de dados do arquivo prim01 e retorna o que deve ser feito <br>
	em blocos para serem executados após importacao
	@type function
	@author Vinicius Gati
	@since 01/03/2018
/*/
Method ProcessaLinha(cLinhaDados) Class OFCNHPrim
local dDtDe, dDtAte, dDtEstoque
local cDealer
local cArm
local cNumProgr := ''
local cDtDe := '', cDtAte := '', cDtEst := ''

	if Empty(cLinhaDados)
		return .F.
	endif

	lEnvEst    := ! Empty( SUBSTR(cLinhaDados, 56, 02) )
	lEnvVda    := ! Empty( SUBSTR(cLinhaDados, 25, 02) )

	cDealer    := SUBSTR(cLinhaDados, 08, 07)
	cArm       := SUBSTR(cLinhaDados, 15, 03)
	cNumProgr  := SUBSTR(cLinhaDados, 18, 07)

	cDtDe   := SUBSTR(cLinhaDados, 27, 14)
	cDtAte  := SUBSTR(cLinhaDados, 41, 14)
	cDtEst  := SUBSTR(cLinhaDados, 57, 14)

	if SUBSTR(cLinhaDados, 27, 08) == '00010101'
		dDtAte := date()-730 // periodo maximo
	else
		dDtDe  := STOD(SUBSTR(cLinhaDados, 27, 08)) // somente data , sem hora minutos segundos que seria 14
	endif
	dDtAte     := STOD(SUBSTR(cLinhaDados, 41, 08)) // somente data , sem hora minutos segundos que seria 14
	if SUBSTR(cLinhaDados, 57, 08) == '00010101'
		dDtEstoque := date()-730 // periodo maximo
	else
		dDtEstoque := STOD(SUBSTR(cLinhaDados, 57, 08))
	endif

	AADD(::aDados, { ::oCfg:CorpToFil(cDealer), cArm, dDtDe, dDtAte, lEnvEst, dDtEstoque, ::CodGerExcepcional(), lEnvVda, cDtDe, cDtAte, cDtEst, cNumProgr })
Return .T.


/*/{Protheus.doc} getDemanda
	Retorna Identificador de Demanda Excepcional - item 24 linha de vendas
	@type function
	@author Cristiam Rossi
	@since 06/06/2025
/*/
method getDemanda( cCodSit ) class OFCNHPrim
local   cRetorno := "0"		// 0=Demanda não excepcional;1=Demanda Excepcional
default cCodSit := ""

	if ! empty( cCodSit ) .and. posicione("V09",1,xFilial("V09")+cCodSit,"V09_LEVDEM") == "0"
		cRetorno := "1"
	endif

return cRetorno


/*/{Protheus.doc} removeAcentos
	remove acentos e caracteres especiais
	@type function
	@author Cristiam Rossi
	@since 09/09/2025
/*/
method removeAcentos( cEntrada ) class OFCNHPrim
local   cSaida
local   cCaracteres := "!@#$%&()_+="
local   cPor        := " "
local   nI
local   cChr
default cEntrada    := ""

	cSaida := FMX_RmvAcent( cEntrada )

	for nI := 1 to len( cCaracteres )
		cChr := subStr( cCaracteres, nI, 1 )
		cSaida := strTran( cSaida, cChr, cPor )
	next

return cSaida


/*/{Protheus.doc} OFCNHPrim1
	Rotina que simula geração do PRIM2 por data (solicitação do PRIM1)
	@type function
	@author Cristiam Rossi
	@since 06/06/2025
/*/
function OFCNHPrim1()
local aParamBox  := {}
local aRet       := {}
local aSimNao    := { "0=Não", "1=Sim" }
local oPrim      := OFCNHPrim():new()
local cCodGer    := oPrim:CodGerExcepcional()
local cFile      := ""

	aAdd( aParamBox, { 1, "Filial"      , cFilAnt,"","","SM0","",35,.T.})
	aAdd( aParamBox, { 9, "WareHouse"   , 200, 40, .T.})
	aAdd( aParamBox, { 5, "N01 - Direct Shipment", .F., 90, "", .F. } )
	aAdd( aParamBox, { 5, "D01 - Não gerenciado" , .F., 90, "", .F. } )
	aAdd( aParamBox, { 5, "F01 - Gerenciado"     , .F., 90, "", .F. } )
	aAdd( aParamBox, { 1, "Data Inicial", CtoD(" /  /  "), "", "", "", "",70, .T. } )
	aAdd( aParamBox, { 1, "Data Final"  , CtoD(" /  /  "), "", "", "", "",70, .T. } )
	aAdd( aParamBox, { 2, "Estoque"     , aSimNao[2], aSimNao, 70, "", .F. } )
	aAdd( aParamBox, { 2, "Venda"       , aSimNao[2], aSimNao, 70, "", .F. } )

	if paramBox( aParamBox, "PRIM1 manual", aRet )
		oPrim:aDados := {}

		if aRet[3]
			aAdd( oPrim:aDados, { aRet[1], "N01", aRet[6], aRet[7], alltrim(aRet[8])=="1" /*gera estoque*/, dDatabase, cCodGer, alltrim(aRet[9])=="1" /*gera venda*/, '', '', '', '' } )
		endif
		if aRet[4]
			aAdd( oPrim:aDados, { aRet[1], "D01", aRet[6], aRet[7], alltrim(aRet[8])=="1" /*gera estoque*/, dDatabase, cCodGer, alltrim(aRet[9])=="1" /*gera venda*/, '', '', '', '' } )
		endif
		if aRet[5]
			aAdd( oPrim:aDados, { aRet[1], "F01", aRet[6], aRet[7], alltrim(aRet[8])=="1" /*gera estoque*/, dDatabase, cCodGer, alltrim(aRet[9])=="1" /*gera venda*/, '', '', '', '' } )
		endif

		cFile := OFCNHA0101_Processo( oPrim:aDados, "PRIM01" )

		alert( cFile )
	endif
return nil
