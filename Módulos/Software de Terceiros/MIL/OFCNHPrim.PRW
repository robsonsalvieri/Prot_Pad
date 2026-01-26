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
Method GeraArquivo(aCodVBB) Class OFCNHPrim
local nX         := 1
local cQuery     := ""
local cInCodVbb  := "('" + self:oArrHelper:Join(aCodVBB, "','") + "')"
local cDep       := ''
local cPath      := lower( "/CNH/" + ::oCfg:cDealerCode + alltrim( ::oCfg:oConfig["DIR_OUT"] ) )
Private oLogger  := DMS_Logger():New("PRIM02_ARQ_"+DTOS(dDatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".LOG")

	oLogger:Log({"TIMESTAMP", STR0001})		//#'Iniciando geração do arquivo em disco'

	cQuery := "SELECT VBB_CODIGO, VBB_LOCCNH, VBB_CODPRG "
	cQuery += " FROM " + retsqlname('VBB')
	cQuery += " WHERE VBB_FILIAL = '"+xFilial('VBB')+"' AND VBB_CODIGO IN "+cInCodVbb+" AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VBB_CODPRG" // VBB_LOCCNH"
	aDados := self:oSqlHlp:GetSelectArray(cQuery, 2)		// ordena por armazem D01, F01 e N01
	for nX := 1 to LEN(aDados)
		if ! Empty(cDep) .AND. cDep != aDados[nX, 2]
			AADD(self:aFile, self:CriaSeparador())
		endif
		self:GeraDados(aDados[nX, 1], oLogger)
		cDep := aDados[nX, 2]
	next

	oFile := FwFileWriter():New(cPath + "PRIM2_"+xFilial('VS3')+"_"+DTOS(dDatabase)+"_"+SUBS(time(),1,2) + SUBS(time(),4,2) + SUBS(time(),7,2) + ".DAT", .T.)
	oFile:Create()
	oFile:Close()
	oFile:Open(FO_WRITE)
	For nX:= 1 to Len(self:aFile)
		oFile:write(self:aFile[nX])
	Next
	oFile:Close()

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

	oLogger:Log({"TIMESTAMP", '    |> '+STR0002})		//#Iniciando geração dos dados de estoque
	// Gera estoque
	cQuery := "select VBC.R_E_C_N_O_ recno_vbc, VBB.R_E_C_N_O_ recno_vbb, *"
	cQuery += " from "+ retSqlName("VBB")+ " VBB "
	cQuery += " left join "+ retSqlName("VBC")+ " VBC "
	cQuery += 	" on VBC_FILIAL = VBB_FILIAL and VBC_CODVBB = VBB_CODIGO and VBC.D_E_L_E_T_=?"
	cQuery += " where VBB_FILIAL=?"
	cQuery += " and   VBB_CODIGO=?"
	cQuery += " and   VBB_IDENTI=?"
	cQuery += " and   VBB.D_E_L_E_T_=?"
	cQuery += " order by VBB_FILIAL, VBC_CODVBB, VBC_CODIGO"
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

	//Gera vendas - PEÇAS
	cVBBAtu := ''
	aBind := {}
	cQuery := "select VBD.R_E_C_N_O_ recno_vbd, VBB.R_E_C_N_O_ recno_vbb, *"
	cQuery += " from "+ retSqlName("VBB") + " VBB "
	cQuery += " left join "+ retSqlName("VBD") + " VBD "
//	cQuery += " on VBD_FILIAL=VBB_FILIAL and VBD_CODVBB=VBB_CODIGO and VBD.D_E_L_E_T_=?"
	cQuery += " on VBD_FILIAL=VBB_FILIAL and VBD_CODVBB=VBB_CODIGO and VBD_CANALV <> ? and VBD.D_E_L_E_T_=?"
	cQuery += " where VBB_FILIAL=?"
	cQuery += " and   VBB_CODIGO=?"
	cQuery += " and   VBB_IDENTI=?"
	cQuery += " and   VBB.D_E_L_E_T_=?"
	cQuery += " order by VBB_FILIAL, VBD_CODVBB, VBD_CODIGO"
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

	//Gera vendas - SERVIÇOS
	aBind := {}
	cQuery := "select VBD.R_E_C_N_O_ recno_vbd, VBB.R_E_C_N_O_ recno_vbb, *"
	cQuery += " from "+ retSqlName("VBB") + " VBB "
	cQuery += " join "+ retSqlName("VBD") + " VBD "
	cQuery += " on VBD_FILIAL=VBB_FILIAL and VBD_CODVBB=VBB_CODIGO and VBD_CANALV=? and VBD.D_E_L_E_T_=?"
	cQuery += " where VBB_FILIAL=?"
	cQuery += " and   VBB_CODIGO=?"
	cQuery += " and   VBB_IDENTI=?"
	cQuery += " and   VBB.D_E_L_E_T_=?"
	cQuery += " order by VBB_FILIAL, VBD_CODVBB, VBD_CODIGO"
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
//static  nSeq     := 1

	cLin := "T"
	cLin += (cAl)->VBB_IDENTI
	if lEstoque .and. ! Empty((cAl)->VBB_DATP01)
		cLin += self:Formata( (cAl)->VBB_DATP01, 14)
	else
		cLin += (cAl)->VBB_DATA2 + (cAl)->VBB_HORA2
	endif
	cLin += (cAl)->VBB_DATA + (cAl)->VBB_HORA
	cLin += "01" // fixo
	cLin += (cAl)->VBB_CODMER
	cLin += self:Formata((cAl)->VBB_CODUNI, 7,, .F.)
	cLin += (cAl)->VBB_LOCCNH
	cLin += " " // sempre em branco segundo apostila
	cLin += self:Formata( int((cAl)->VBB_FILEQU*1000), 15,, .T.)
	cLin += (cAl)->VBB_CATTRA
//	cLin += self:Formata(nSeq++, 7,, .T.)
	cLin += (cAl)->VBB_CODPRG
	cLin += self:Formata((cAl)->VBB_NUMREG, 8,, .T.)
	if lEstoque
		cLin += "040" // fixo segundo apostila
		cLin += Space(9)
	else
		cLin += Space(10)
	endif
	cLin1 := LEFT(cLin, 200)
	cLin2 := Substr(cLin, 201, Len(cLin) - 200 )

	cQuery := "UPDATE " + retsqlname('VBB')
	cQuery += " SET VBB_NUMRE1=?,"
	cQuery += " VBB_NUMRE2=?"
	cQuery += " WHERE R_E_C_N_O_=?"
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
//local nQtdBack := (cAl)->( iif( VBC_BACKOR > VBC_QTDEST, VBC_BACKOR - VBC_QTDEST, 0 ) )
local nQtdBack := (cAl)->VBC_BACKOR
local cQuery

	if (cAl)->( VBC_QTDEST + VBC_QTDENC + VBC_QTDRES ) + nQtdBack > 0 .or. ::CodGerExcepcional() == (cAl)->VBB_CATTRA
		cLin += 'L'
		cLin += 'ST'
		cLin += self:Formata( cCodFab, 20,, .F.)
		cLin += ' '
		cLin += self:Formata((cAl)->VBC_QTDEST, 12,3, .T.)
		cLin += ' '
		cLin += self:Formata((cAl)->VBC_QTDENC, 12,3, .T.)
		cLin += ' '
		cLin += self:Formata(nQtdBack, 12,3, .T.)
		cLin += self:Formata( iif( empty((cAl)->VBC_ULTSAI ), "19900101", (cAl)->VBC_ULTSAI ),  8,, .F.)
		cLin += self:Formata((cAl)->VBC_ULTENT,  8,, .F.)
		cLin += self:Formata((cAl)->VBC_LOCCAO,  8,, .F.)
		cLin += self:Formata((cAl)->VBC_CUSMED, 10,2, .T.)
		cLin += IIF((cAl)->VBC_ESTOCA == 'S', '0', '9')
		cLin += self:Formata((cAl)->VBC_ESTMIN, 12,3, .T.)
		cLin += self:Formata((cAl)->VBC_QTDRES, 12,3, .T.)
		cLin += self:Formata((cAl)->VBC_FUTRES, 12,3, .T.)
		cLin += self:Formata((cAl)->VBC_DESPRO, 25)
		cLin += self:Formata((cAl)->VBC_CODFOR, 10,, .F.)
		cLin += (cAl)->VBC_FORNAM
		cLin += Space(142)
		cLin1 := LEFT(cLin, 200)
		cLin2 := Substr(cLin, 201, Len(cLin) - 200 )
		cLin += CRLF

		cQuery := "UPDATE " + retsqlname('VBC')
		cQuery += " SET VBC_NUMRE1=?,"
		cQuery += " VBC_NUMRE2=?"
		cQuery += " WHERE R_E_C_N_O_=?"
		OFCNHA015C_ExecQuery( @cQuery, { { 'C', cLin1 }, { 'C', cLin2 }, { 'N', (cAl)->recno_vbc } } )
	endif
Return cLin

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

		if isServ
			cNumOri := "M" + subStr( (cAl)->VBD_NUMORI, 2, 7 ) + (cAl)->VBD_TIPTEM + right((cAl)->VBD_SQCANC,1)
		else
			cNumOri := subStr( (cAl)->VBD_NUMORI, 2, 7 ) + (cAl)->VBD_TIPTEM + right((cAl)->VBD_SQCANC,1) + iif( (cAl)->VBD_INDDEV == 'S', "D", " " )
		endif

		cLin += 'L'
		cLin += 'SE'
//		cLin += self:Formata((cAl)->VBD_CODCLI + (cAl)->VBD_LOJCLI, 8)
		cLin += self:Formata((cAl)->VBD_CDCLI2, 8)
		cLin += self:Formata(self:oCfg:cDealerCode, 8)
		cLin += self:Formata((cAl)->VBD_NOMCLI, 20)
		cLin += self:Formata((cAl)->VBD_ENDCLI, 50)
		cLin += self:Formata((cAl)->VBD_CLICEP,  5)
		cLin += self:Formata((cAl)->VBD_CLCNPJ, 11)
		cLin += cNumOri
		cLin += self:Formata((cAl)->VBD_LINVEN,  4)
		cLin += self:Formata(cNumNf, 13,,.t.)
		cLin += self:Formata(cNumNf, 13,,.t.)
		cLin += self:Formata((cAl)->VBD_DATORI,  8)
		cLin += self:Formata((cAl)->VBD_DATNFI,  8)
		cLin += self:Formata((cAl)->VBD_DATNFI,  8) // data remessa = nota
		cLin += self:Formata((cAl)->VBD_CANALV,  1)
		cLin += self:Formata((cAl)->VBD_CODGAR,  1)
		cLin += self:Formata((cAl)->VBD_SUBCAN,  2)
		cLin += self:Formata((cAl)->VBD_PRODUT, 20)
		cLin += ' '
		cLin += self:Formata((cAl)->VBD_QTDPED, 12, 3)
		cLin += ' '
		cLin += self:Formata( IIF( empty( (cAl)->VBD_DATNFI ), 0, (cAl)->VBD_QTDFAT ), 12, 3)
		cLin += " "
		cLin += self:Formata( IIF( empty( (cAl)->VBD_NUMNFI ), 0, (cAl)->VBD_QTDFAT ), 12, 3)
		cLin += self:Formata((cAl)->VBD_HORMOB,  7)
		cLin += (cAl)->VBD_TIPDEM
		if isServ											// Serviço
			cLin += "0"
			cLin += IIF( (cAl)->VBD_INDCAN == 'N' , ' ', 'Y' ) // em branco quando não é cancelamento
			cLin += self:Formata((cAl)->VBD_VALVDA, 10, 2)
			cLin += self:Formata( 0, 10, 2 )
		else												// Peças
			cLin += IIF( (cAl)->VBD_INDDEV == 'N' , '0', '1' ) // 0 ou 1
			cLin += IIF( (cAl)->VBD_INDCAN == 'N' , ' ', 'Y' ) // em branco quando não é cancelamento
			cLin += self:Formata((cAl)->VBD_VALVDA, 10, 2)
			cLin += self:Formata((cAl)->VBD_CUSMED, 10, 2)
		endif
		cLin += '040'
		cLin += self:Formata((cAl)->VBD_CHASSI, 17)
		cLin += self:Formata((cAl)->VBD_HORKIL,  6)
		cLin += self:Formata((cAl)->VBD_FABRIC, 12)
		cLin += self:Formata((cAl)->VBD_MODELO, 12)
		cLin += self:Formata((cAl)->VBD_MOTCOM,  9)
		cLin += Space(6)
		cLin1 := LEFT(cLin, 200)
		cLin2 := Substr(cLin, 201, Len(cLin) - 200 )
		VBD->( dbGoto( (cAl)->recno_vbd ) )
		reclock("VBD", .F.)
		VBD->VBD_NUMRE1 := cLin1
		VBD->VBD_NUMRE2 := cLin2
		msUnlock()
		cLin += CRLF
	endif
Return cLin


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
Return self:aDados // dados de criacao de arquivo

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

		cFile := OFCNHA0101_Processo( oPrim:aDados )

		alert( cFile )
	endif
return nil
