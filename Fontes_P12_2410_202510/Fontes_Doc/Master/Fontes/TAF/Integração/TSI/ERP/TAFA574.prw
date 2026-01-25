#INCLUDE "TOTVS.CH" 
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

/*
	Posição do array aRegT013AP conforme o layout do TAF do registro T013AP.
*/
#Define NAPREGISTR	01	// REGISTRO
#Define NAPCODTRIB	02	// COD_TRIB
#Define NAPBS		03	// BASE
#Define NAPBSQTD	04	// BASE_QUANT
#Define NAPBSNT		05	// BASE_NT
#Define NAPVLR		06	// VALOR
#Define NAPVLRTRIB	07	// VLR_TRIBUTAVEL
#Define NAPVLRISEN	08	// VLR_ISENTO
#Define NAPVLROUTR	09	// VLR_OUTROS
#Define NAPVLRNT	10	// VALOR_NT
#Define NAPCST		11	// CST
#Define NAPCFOP		12	// CFOP
#Define NAPALIQ		13	// ALIQUOTA
#Define NAPCODLST	14	// COD_LST
#Define NAPVLROPER	15	// VL_OPER
#Define NAPVLRSCRE	16	// VL_SCRED
#Define TRIBICMSST	17	// TRIBICMSST

/* 
	Posição do array a_RgT015AE conforme o layout do TAF do registro T015AE.
*/
#Define NAEREGISTR	01	// REGISTRO
#Define NAECODTRIB	02	// COD_TRIB
#Define NAECST		03	// CST
#Define NAEMODBC	04	// MODBC
#Define NAEMVA		05	// MVA
#Define NAEPRREDBS	06	// PERC_RED_BC
#Define NAEBS		07	// BASE
#Define NAEBSQTD	08	// BASE_QUANT
#Define NAEBSNT		09	// BASE_NT
#Define NAEALIQ		10	// ALIQUOTA
#Define NAEALIQQTD	11	// ALIQUOTA_QUANT
#Define NAEVLR		12	// VALOR
#Define NAEVLRTRIB	13	// VLR_TRIBUTAVEL
#Define NAECODENQ	14	// COD_ENQ
#Define NAEVLRISEN	15	// VLR_ISENTO
#Define NAEVLROUTR	16	// VLR_OUTROS
#Define NAEVLRNT	17	// VALOR_NT
#Define NAEBSICMUF	18	// VL_BC_ICMS_UF
#Define NAEVLICMUF	19	// VL_ICMS_UF
#Define NAECODANT	20	// COD_ANT
#Define NAEMTDSICM	21	// MT_DES_ICMS
#Define NAEVLRSCRE	22	// VL_SCRED
#Define NAEMTINCID	23	// MOT_INCIDENCIA
#Define NAEVLCONTR	24	// VLSCONTR
#Define NAEVLRADIC	25	// VLRADIC
#Define NAEVLRNPAG	26	// VLRNPAG
#Define NAEVLRCE15	27	// VLRCE15
#Define NAEVLRCE20	28	// VLRCE20
#Define NAEVLRCE25	29	// VLRCE25
#Define NAEVRDICPG	30	// VLRADICNPAG

static cTagJs     := "invoice"
static cTagT015   := "fiscalDocumentItems"
static cTagT015AI := "transportComplement"
static cTagT015AK := "indicativeOfSuspensionByJudicialProcess"
static cTag13AP   := "valuesByTax"
static cTag15AE   := "valuesByTaxPerItem"
static cTag013AA  := "complementaryInformationByTaxDocument"
static cTag013AI  := "ticketsByInvoice"
static cMVEstado  := GetNewPar("MV_ESTADO" , '' )
static cUFIPM     := GetNewPar("MV_UFIPM" , .F.) //ICMS/IPI participacao municipios
static lIntTms    := GetNewPar("MV_INTTMS" , .F.)
static lTmsUfPg   := GetNewPar("MV_TMSUFPG", .T.)
static cUFRESpd   := GetNewPar( 'MV_UFRESPD' , '' )
static cOpSemF    := GetNewPar( 'MV_OPSEMF' , '' )
static nTmNumIte  := GetSx3Cache( 'C30_NUMITE' , 'X3_TAMANHO' )
static nTmIndPro  := GetSx3Cache( 'C1G_INDPRO' , 'X3_TAMANHO' )
static nTmNmPro   := GetSx3Cache( 'C1G_NUMPRO' , 'X3_TAMANHO' )
static nTmVers    := GetSx3Cache( 'C1G_VERSAO' , 'X3_TAMANHO' )
static lINDISEN   := SFT->(FieldPos("FT_INDISEN")) > 0
static lTableCDG  := TcCanOpen(RetSqlName( 'CDG' )) .and. ExistStamp(,,"CDG")
static lTableCDT  := TcCanOpen(RetSqlName( 'CDT' )) .and. ExistStamp(,,"CDT") //!(CDT->(Eof()) .And. CDT->(Bof())) // Verifica se a tabelas DT6 existe na base.
static lTableDT6  := TcCanOpen(RetSqlName( 'DT6' )) //!(DT6->(Eof()) .And. DT6->(Bof())) // Verifica se a tabelas DT6 existe na base.
static lTableSON  := TcCanOpen(RetSqlName( 'SON' ))
static lTableCDC  := TcCanOpen(RetSqlName( 'CDC' )) //Protejo o fonte pois a tabela CDC pode não existir na base do cliente.
static lTableDHR  := TcCanOpen(RetSqlName( 'DHR' ))
static lTableFKX  := TcCanOpen(RetSqlName( 'FKX' ))
Static lDtCpIss   := C20->(FieldPos("C20_DTCPIS")) > 0
Static lChkSON    := ChkFile("SON",.F.)

Static oHashC07   := HMNew()
Static oHashC09   := HMNew()
Static oHashC01   := HMNew()
Static oHashC02   := HMNew()
Static oHashC0U   := HMNew()
Static oHashC1H   := HMNew()
Static oHashC0X   := HMNew()
Static oHashT9C   := HMNew()
Static oHashC1L   := HMNew()
Static oHashC0Y   := HMNew()
Static oHashC1N   := HMNew()
Static oHashC03   := HMNew()
Static oHashC1J   := HMNew()
Static oHashC0B   := HMNew()
Static oHashC8C   := HMNew()
Static oHashLF0   := HMNew()
Static oHashC3S   := HMNew()
Static oHashC1G   := HMNew()
Static oHashC0J   := HMNew()
Static oHashCHY   := HMNew()
Static oHashC3Q   := HMNew()
Static oHashDUY   := HMNew()
Static oHashV3O   := HMNew()

static __oStatCDA   := nil
static __oStatEnt	:= nil
static __oStatSai   := nil
static __oStatCDT   := nil
static _lAtuStamp	:= TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")

/*/{Protheus.doc} TSINFISCAL
	( Classe que contém query com preparedstatament de Nota Fiscal para posterior integração )
    @type Class
	@author Henrique Pereira 
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/
Class TSINFISCAL
    Data cFinalQuery as String
    Data oStatement  as Object
	Data aJSonDoc	 as array
	Data cRefStamp   as String  //Ultimo stamp da V80 que foi recebido no construtor new()
	Data cAlias      as String  //Alias que será usado na query principal
	Data cUpStamp    as String  //Maior stamp que foi processado pelo Ws034Proc (ver WSTAF034.PRW)
	Data nSizeMax    as numeric //Qtd Limite Lote
	Data nQtNotas    as numeric //Contador registro ( para controle de lote, limpado a cada 500)
	Data nProcReg    as numeric //Contador acumulado
	DATA nQtFTF3	 as numeric
	Data cDbType 	 as String
	Data lRegCDG     as logical
	Data lRegCDT     as logical
	Data cQryFTF3	 as String
    Data oTabTemp    as Object
    Method New() Constructor
	Method HasTMS()
	Method LoadQuery()
	Method GetQry()
    Method TempTable()
	Method ChkTableJoin()
	Method UseTmpF3FT()
	Method ExtrJsonProc()
	Method CallWs034Proc()
	Method CleanTmpFTF3()
	Method GetHashCahed()
	Method Create() Constructor
EndClass

 /*/{Protheus.doc} New
	(Método construtor )
	@author Henrique Pereira
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/
Method New(cSourceBr,cRefStamp) Class TSINFISCAL
	self:cRefStamp 	 := cRefStamp
	self:cUpStamp  	 := '' //Proteção para evitar problemas quando não tem nada para integrar
	self:nSizeMax  	 := 500
	self:nQtNotas  	 := 0
	self:nProcReg  	 := 0
	self:cDbType   	 := Upper(Alltrim(TCGetDB()))
	self:oTabTemp  	 := Nil
	self:nQtFTF3   	 := 0
	self:cQryFTF3  	 := ''
	self:lRegCDT 	 := .F.
	self:lRegCDG 	 := .F.
	if lTableCDT
		self:lRegCDT := self:ChkTableJoin("CDT")
	endif
	if lTableCDG
		self:lRegCDG := self:ChkTableJoin("CDG")
	endif
    self:LoadQuery()
    //self:TempTable()
Return Nil

/*/{Protheus.doc} Create
	(Método construtor para chamadas via API)
	@author Karen Yoshie|José Felipe
	@since 02/01/2022
	@return Nil, nulo, não tem retorno.
/*/
Method Create() Class TSINFISCAL
	self:nSizeMax   := 250
	self:nQtNotas   := 0
	self:nProcReg   := 0
Return self

 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatemen, por hora ainda com '?'
    nos parâmetros variáveis
	@author Henrique Pereira
	@since 16/09/2020
	@return Nil, nulo, não tem retorno.
/*/
Method LoadQuery() Class TSINFISCAL

Local cQuery	:= ""
Local cConcat 	:= ""
Local cDbType 	:= Upper(Alltrim(TCGetDB()))
Local cCoalesce := xFunExpSql( "COALESCE" )
Local cUltStmp  := ::cRefStamp
Local cConvSFT	:= ""
Local cConvSF3	:= ""
Local nTmStmp   := 0
Local aBind     := {}

if "ORACLE" $ cDbType //Tratamento para retirar os milesimos apenas no oracle ":000"
	nTmStmp := Len( Alltrim(cUltStmp) )
	cUltStmp := SubSTr( Alltrim(cUltStmp),1, nTmStmp-4 )
	cUltStmp := cUltStmp + ".999"
endif

//Converte o conteúdo do campo conforme o banco de dados usado.
if cDbType $ 'MSSQL/MSSQL7'
	cConvSFT := ' CONVERT(VARCHAR(23), SFT.S_T_A_M_P_, 21) '	
	cMaxStamp:= " (SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND (SELECT CONVERT(varchar(23), MAX(TABLE.S_T_A_M_P_), 21) "	
	cConvSF3 := ' CONVERT(VARCHAR(23), SF3.S_T_A_M_P_, 21) '
elseif cDbType $ 'ORACLE'
	cConvSFT  := " SFT.S_T_A_M_P_ "
	cConvSF3  := " SF3.S_T_A_M_P_ "	
	cMaxStamp := " (SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND (SELECT MAX(TABLE.S_T_A_M_P_) "
elseif cDbType $ "POSTGRES"
	cConvSFT := ' cast(SFT.S_T_A_M_P_ AS character(23)) '
	cConvSF3 := ' cast(SF3.S_T_A_M_P_ AS character(23)) '	
	cMaxStamp := " (SFT.FT_FILIAL = '" + xFilial("SFT") + "' AND (SELECT cast( MAX(TABLE.S_T_A_M_P_) as character(23)) "
endif

// VerIfica o tipo de concatenação para o banco
If "MSSQL" $ cDbType
	cConcat := "+"
Else
	cConcat := "||"
EndIf

cQuery := " SELECT DISTINCT "
cQuery += "SFT.SFTRECNO RECNOSFT "
cQuery += ",SFT.FT_FILIAL FILIAL "
cQuery += ",SFT.FT_TIPOMOV TIPOMOV "
cQuery += ",SFT.FT_NFISCAL NFISCAL "
cQuery += ",SFT.FT_SERIE SERIE "
cQuery += ",SFT.FT_CLIEFOR CLIEFOR "
cQuery += ",SFT.FT_LOJA LOJA "
cQuery += ",SFT.SFTDELETE DELSFT "
cQuery += ",SFT.FT_ITEM ITEM "
cQuery += ",SFT.FT_IDTRIB IDTRIB "
cQuery += "," + cCoalesce + " (SF2.F2_NFCUPOM, ?) NFCUPOM "
aadd( aBind, { space(1), .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPO = ? AND SFT.FT_CODISS <> ? AND SFT.FT_NFELETR <> ? THEN SFT.FT_NFELETR ELSE SFT.FT_NFISCAL END NUM_DOC "
aadd( aBind, { "S"	   , .F. } )
aadd( aBind, { space(1), .F. } )
aadd( aBind, { space(1), .F. } )

cQuery += ",SFT.FT_NFISCAL FTNFISCAL " //invoice
cQuery += ",SFT.FT_NFELETR FTNFELETR " //electronicInvoice

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) THEN 'F'" + cConcat +" SFT.FT_CLIEFOR " + cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += "WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) THEN 'C'" + cConcat +" SFT.FT_CLIEFOR " + cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += "WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) THEN 'C'" + cConcat +" SFT.FT_CLIEFOR " + cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += "WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) THEN 'F'" + cConcat +" SFT.FT_CLIEFOR " + cConcat +"RTRIM(SFT.FT_LOJA) "
cQuery += "END COD_PART "
aadd( aBind, { "E", .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "E", .F. } )
aadd( aBind, { { 'B', 'D' }, .F. } )
aadd( aBind, { "S", .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "S", .F. } )
aadd( aBind, { { 'B', 'D' }, .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.R_E_C_N_O_ ELSE SF2.R_E_C_N_O_ END RECCABEC "
cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SD1.R_E_C_N_O_ ELSE SD2.R_E_C_N_O_ END RECITENS "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "E", .F. } )

cQuery += "," + cCoalesce + "(SA1.R_E_C_N_O_,?) RECSA1 "
cQuery += "," + cCoalesce + "(SA2.R_E_C_N_O_,?) RECSA2 "
cQuery += "," + cCoalesce + "(SF4.R_E_C_N_O_,?) RECSF4 "
aadd( aBind, { 0, .F. } )
aadd( aBind, { 0, .F. } )
aadd( aBind, { 0, .F. } )

cQuery += ",SB1.R_E_C_N_O_ RECSB1 "

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN ? ELSE ? END IND_OPER " // indicador de operação de entrada ou saída
aadd( aBind, { "E", .F. } )
aadd( aBind, { "0", .F. } )
aadd( aBind, { "1", .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPO = ? THEN ? WHEN SFT.FT_TIPO = ? THEN ? "
cQuery += "WHEN SFT.FT_TIPO = ? THEN ? WHEN SFT.FT_TIPO = ? THEN ? "
cQuery += "WHEN SFT.FT_TIPO = ? THEN ? WHEN SFT.FT_TIPO = ? THEN ? ELSE ? END TIPO_DOC "
aadd( aBind, { "D" , .F. } )
aadd( aBind, { "01", .F. } )
aadd( aBind, { "I" , .F. } )
aadd( aBind, { "02", .F. } )
aadd( aBind, { "P" , .F. } )
aadd( aBind, { "03", .F. } )
aadd( aBind, { "C" , .F. } )
aadd( aBind, { "04", .F. } )
aadd( aBind, { "B" , .F. } )
aadd( aBind, { "05", .F. } )
aadd( aBind, { "S" , .F. } )
aadd( aBind, { "06", .F. } )
aadd( aBind, { "00", .F. } )

cQuery += ",CASE WHEN SFT.FT_FORMUL = ? OR ( SFT.FT_FORMUL = ? AND SFT.FT_TIPOMOV = ? ) THEN ? ELSE ? END IND_EMIT "
aadd( aBind, { "S"	   , .F. } )
aadd( aBind, { space(1), .F. } )
aadd( aBind, { "S"	   , .F. } )
aadd( aBind, { "0"	   , .F. } )
aadd( aBind, { "1"	   , .F. } )

cQuery += ",CAST( CASE WHEN (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) THEN ? "
cQuery += "WHEN (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) THEN ? ELSE ? END as char(3)) FOR_CLI "
aadd( aBind, { "E"						, .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "SA2"					, .F. } )
aadd( aBind, { "S"		   				, .F. } )
aadd( aBind, { { 'B', 'D' }				, .F. } )
aadd( aBind, { "SA2"	   				, .F. } )
aadd( aBind, { "SA1"	   				, .F. } )

cQuery += ",SA2.A2_CALCIRF CALC_IRF "
cQuery += ",SFT.FT_EMISSAO DT_DOC "
cQuery += ",SFT.FT_CHVNFE CHV_DOC_E "

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_VALBRUT WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_VALBRUT END VL_DOC "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_DESCONT WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_DESCONT END VL_DESC "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",SFT.FT_ESPECIE COD_MOD "

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_CODISS = ? AND SFT.FT_TIPO <> ? THEN SF1.F1_VALMERC "
cQuery += "WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_CODISS = ? AND SFT.FT_TIPO <> ? THEN SF2.F2_VALMERC END VL_MERC "
aadd( aBind, { "E"		, .F. } )
aadd( aBind, { space(1)	, .F. } )
aadd( aBind, { "S"		, .F. } )
aadd( aBind, { "S"		, .F. } )
aadd( aBind, { space(1)	, .F. } )
aadd( aBind, { "S"		, .F. } )

cQuery += ",SFT.FT_ENTRADA DT_E_S "

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_DESPESA WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_DESPESA END VL_DA "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_TPFRETE ELSE ? END TPFRETE "
aadd( aBind, { "S"		, .F. } )
aadd( aBind, { space(1)	, .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_SEGURO WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_SEGURO END VL_SEG "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_SEGURO + SF1.F1_DESPESA + SF1.F1_FRETE "
cQuery += "WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_SEGURO + SF2.F2_DESPESA + SF2.F2_FRETE END VL_OUT_DESP "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_FRETE WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_FRETE END VL_FRT "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",SFT.FT_DESCICM + SFT.FT_DESCZFR VL_ABAT_NT "

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO = ? AND SFT.FT_CODISS <> ? THEN SF1.F1_VALMERC "
cQuery += "WHEN SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO = ? AND SFT.FT_CODISS <> ? THEN SF2.F2_VALMERC END VL_SERV "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )
aadd( aBind, { space(1), .F. } )
aadd( aBind, { "S", .F. } )
aadd( aBind, { "S", .F. } )
aadd( aBind, { space(1), .F. } )

//Adicionado extração do campo _MENNOTA para utilização na função compInfoByTax
//Integração do layout T013AA Informações complementares por documentos fiscais.
cQuery += ", CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_MENNOTA WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_MENNOTA END MENNOTA "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",SFT.FT_DTCANC DT_CANC "

//Doc Entrada com formulario proprio = nao ou vazio, ao ser excluido apaga registro SFT, nao preenche DT Cancelamento, 
//o tratamento abaixo se faz necessario para que na gravacao, exclua o modelo da C20 e filhos ( C30,C2F,C35... )
//O OBSERV eh preenchido com NF CANCELADA se DT_CANC esta preenchido, nessa situacao devera atualizar a nota no TAF p/ situacao cancelada
//Demais casos a OBSERV eh preenchido com vazio se DT_CANC vazio ( nada acontece ).
cQuery += ",CASE WHEN SFT.FT_DTCANC = ? AND SFT.FT_FORMUL = ? AND SFT.FT_TIPOMOV = ? AND SFT.SFTDELETE = ? THEN ? ELSE SFT.FT_OBSERV END OBSERV "
aadd( aBind, { space(1)		, .F. } )
aadd( aBind, { space(1)		, .F. } )
aadd( aBind, { "E"			, .F. } )
aadd( aBind, { "*"			, .F. } )
aadd( aBind, { "NF EXCLUIDA", .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_MODAL END MODAL_TRANSP "
aadd( aBind, { "E"			, .F. } )

cQuery += ",SFT.FT_ESTADO UF_ORIGEM "
cQuery += ",SFT.FT_PRODUTO PRODUTO "

cQuery += ",SFTSTAMP STAMP " //ja foi convertido para os bancos no insert into

cQuery += ",CAST( CASE WHEN (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) THEN SF1.F1_PREFIXO "
cQuery += "WHEN (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) THEN SF2.F2_PREFIXO END as char(3)) INDPAG "
aadd( aBind, { "E"						, .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "S"						, .F. } )
aadd( aBind, { { 'B', 'D' }				, .F. } )

cQuery += ",CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_ESTPRES WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_ESTPRES END ESTPRES "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ", CASE WHEN SFT.FT_TIPOMOV = ? THEN SF1.F1_INCISS WHEN SFT.FT_TIPOMOV = ? THEN SF2.F2_MUNPRES END MUNPRES "
aadd( aBind, { "E", .F. } )
aadd( aBind, { "S", .F. } )

cQuery += ",SFT.FT_TIPO TIPO "
cQuery += ",SFT.FT_FORMUL FORMUL "
cQuery += ",SF4.F4_TRFICM TRFICM "
cQuery += ",SF4.F4_ESTCRED ESTCRED "
cQuery += ",SFT.FT_ESTCRED FTESTCRED "
cQuery += ",SFT.FT_CFOP CFOP "
cQuery += ",F2Q.F2Q_TPSERV F2QTPSERV "
cQuery += ",PROD.CDN_TPSERV PRODTPSERV "
cQuery += ",PROD.CDN_CODLST PRODCODLST "
cQuery += ",ISS.CDN_TPSERV ISSTPSERV "
cQuery += ",ISS.CDN_CODLST ISSCODLST "

if lDtCpIss
	cQuery += "," + cCoalesce + "(SF1.F1_DTCPISS,?) F1DTCPISS "
	aadd( aBind, { space(1), .F. } )
endif

If lIntTms .And. lTableDT6
	cQuery += ",DT6.DT6_CDRORI DT6CDRORI, DT6.DT6_CLIDES DT6CLIDES, DT6.DT6_LOJDES DT6LOJDES "
	cQuery += ",DT6.DT6_CLIREM DT6CLIREM, DT6.DT6_LOJREM DT6LOJREM, DT6.DT6_CDRCAL DT6CDRCAL "
	cQuery += ",DT6.DT6_DEVFRE, " + cCoalesce + "(DT6.R_E_C_N_O_,?) RECDT6 "
	aadd( aBind, { 0, .F. } )
Else
	cQuery += ",? DT6CDRORI, ? DT6CLIDES, ? DT6LOJDES, ? DT6CLIREM, ? DT6LOJREM, ? DT6CDRCAL, ? DT6_DEVFRE, ? RECDT6 "
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { 0	   , .F. } )
EndIf

if self:lRegCDT
	//Subquery para retornar o maior stamp da tabela CDT Informações complementares por documentos fiscais.
	cQuery += ", ( SELECT "
	If cDbType $ "MSSQL/MSSQL7"
		cQuery += " CONVERT(VARCHAR(23), MAX(CDTTOT.S_T_A_M_P_), 21) "
	Elseif cDbType $ "ORACLE"
		cQuery += " cast(to_char( MAX(CDTTOT.S_T_A_M_P_),'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) " 
	Elseif cDbType $ "POSTGRES"
		cQuery += " cast(to_char( MAX(CDTTOT.S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
	Endif
	cQuery += "FROM " + RetSqlName("CDT") + " CDTTOT " //CDT_FILIAL, CDT_TPMOV, CDT_DOC, CDT_SERIE, CDT_CLIFOR, CDT_LOJA, CDT_IFCOMP, R_E_C_N_O_, D_E_L_E_T_
	cQuery += "WHERE CDTTOT.CDT_FILIAL = SFT.FT_FILIAL " 
	cQuery += "AND CDTTOT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cQuery += "AND CDTTOT.CDT_DOC = SFT.FT_NFISCAL "
	cQuery += "AND CDTTOT.CDT_SERIE = SFT.FT_SERIE "
	cQuery += "AND CDTTOT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cQuery += "AND CDTTOT.CDT_LOJA = SFT.FT_LOJA "
	cQuery += "AND CDTTOT.CDT_IFCOMP <> ? ) CDTSTAMP " 
	aadd( aBind, { space(1), .F. } )

	//Retirei o Delete pois
	// quero que seja integrado novamente o documento fiscal e seus filhos e netos caso uma
	// informação complementar atribuida ao documento fiscal seja excluída.
	//cQuery += "   AND CDTTOT.D_E_L_E_T_ ' ' ) CDTSTAMP "

	cQuery += ", ( SELECT DISTINCT( CDT.CDT_INDFRT ) FROM "
	cQuery += RetSqlName("CDT") + " CDT "  //CDT_FILIAL, CDT_TPMOV, CDT_DOC, CDT_SERIE, CDT_CLIFOR, CDT_LOJA, CDT_IFCOMP, R_E_C_N_O_, D_E_L_E_T_
	cQuery += "WHERE CDT.CDT_FILIAL = ? "
	cQuery += "AND CDT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cQuery += "AND CDT.CDT_DOC = SFT.FT_NFISCAL "
	cQuery += "AND CDT.CDT_SERIE = SFT.FT_SERIE "
	cQuery += "AND CDT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cQuery += "AND CDT.CDT_LOJA = SFT.FT_LOJA "
	cQuery += "AND CDT.D_E_L_E_T_ = ? ) CDT_INDFRT "
	aadd( aBind, { xFilial("CDT"), .F. } )
	aadd( aBind, { space(1)		 , .F. } )

	cQuery += "," + cCoalesce + "( ( SELECT MAX( CDT.R_E_C_N_O_ ) FROM "
	cQuery += RetSqlName("CDT") + " CDT " //CDT_FILIAL, CDT_TPMOV, CDT_DOC, CDT_SERIE, CDT_CLIFOR, CDT_LOJA, CDT_IFCOMP, R_E_C_N_O_, D_E_L_E_T_
	cQuery += "WHERE CDT.CDT_FILIAL = ? "
	cQuery += "AND CDT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cQuery += "AND CDT.CDT_DOC = SFT.FT_NFISCAL "
	cQuery += "AND CDT.CDT_SERIE = SFT.FT_SERIE "
	cQuery += "AND CDT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cQuery += "AND CDT.CDT_LOJA = SFT.FT_LOJA "
	cQuery += "AND CDT.D_E_L_E_T_ = ? ),?) RECCDT "
	aadd( aBind, { xFilial("CDT"), .F. } )
	aadd( aBind, { space(1)		 , .F. } )
	aadd( aBind, { 0			 , .F. } )
else
	cQuery += ", ? CDT_INDFRT, ? RECCDT "
	aadd( aBind, { space(1), .F. } )
	aadd( aBind, { 0	   , .F. } )
endif

//---------------------------------------------------------------------------------------------------------------------
// Caso tenha, busco o numero da fatura para utilizar no T013AI (ticketsByInvoice)
// Retirado 19/03/2025 pois o TAF não considera a tabela C29 em nenhuma das obrigacoes.
// Com esse trecho retirado (SE1\SE2), a query que estava sendo executado em 6 horas na JadLog, abaixou para 7 minutos.
// Caso necessite do NUMFAT, verificar historico no TFS para recuparar a query e suas amarracoes.
//---------------------------------------------------------------------------------------------------------------------

if self:lRegCDG
	//SUBQUERY INDICATIVO DE SUSPENSAO PROCESSOS ADMINISTRATIVOS E JUDICIAIS
	//Existe a possibilidade de retornar registros provenientes da SFT, portanto a subquery ira retornar o stamp maximo da CDG.
	//O complemento lançado no Fiscal para processos referenciados nao eh o responsavel por gerar escrituracao na SFT / SF3.
	cQuery += ", ( SELECT "
	If cDbType $ "MSSQL/MSSQL7"
		cQuery += " CONVERT(VARCHAR(23), MAX(CDG.S_T_A_M_P_), 21) "
	Elseif cDbType $ "ORACLE"
		cQuery += " cast(to_char( MAX(CDG.S_T_A_M_P_),'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23)) " 
	Elseif cDbType $ "POSTGRES"
		cQuery += " cast(to_char( MAX(CDG.S_T_A_M_P_),'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) "
	Endif
	cQuery += " FROM " + RetSqlName("CDG") + " CDG " //CDG_FILIAL, CDG_TPMOV, CDG_DOC, CDG_SERIE, CDG_CLIFOR, CDG_LOJA, CDG_ITEM, R_E_C_N_O_, D_E_L_E_T_
	cQuery += "WHERE CDG.CDG_FILIAL = SFT.FT_FILIAL AND CDG.CDG_TPMOV = SFT.FT_TIPOMOV AND CDG.CDG_DOC = SFT.FT_NFISCAL AND CDG.CDG_SERIE = SFT.FT_SERIE "
	//cQuery += "AND CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA AND CDG.CDG_ITEM = SFT.FT_ITEM ) CDGSTAMP "
	cQuery += "AND CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA ) CDGSTAMP "
	//Importante o filtro do FT_ITEM com CDG_ITEM com FT_ITEM nao eh necessario pois aqui retorna o maior stamp da nota completa.
	//Importante o filtro do D_E_L_E_T_ deverá ser retirado, a query devera retornar o maior stamp independente se foi incluido ou excluido

	cQuery += ", " + cCoalesce + "( ( SELECT MIN( CDG.R_E_C_N_O_ ) FROM "
	cQuery += RetSqlName("CDG") + " CDG "
	cQuery += "WHERE CDG.CDG_FILIAL = SFT.FT_FILIAL AND CDG.CDG_TPMOV = SFT.FT_TIPOMOV AND CDG.CDG_DOC = SFT.FT_NFISCAL AND CDG.CDG_SERIE = SFT.FT_SERIE "
	cQuery += "AND CDG.CDG_CLIFOR = SFT.FT_CLIEFOR AND CDG.CDG_LOJA = SFT.FT_LOJA "
	cQuery += "AND CDG.D_E_L_E_T_ = ? ),?) RECCDG "
	aadd( aBind, { space(1)	, .F. } )
	aadd( aBind, { 0		, .F. } )
endif

If lTableDHR
	cQuery += " , DHR.DHR_NATREN NATREN "
	cQuery += " , DHR.R_E_C_N_O_ RECDHR "
EndIf

if lTableSON
	cQuery += " , SON.ON_CNO CNO "
	cQuery += " , SON.ON_TPINSCR TPINSCR "
Endif

self:UseTmpF3FT(cConvSF3,cConvSFT,cUltStmp,cMaxStamp)
if self:oTabTemp <> Nil .and. !Empty(self:oTabTemp:GetRealName())
	cQuery += " FROM " + self:oTabTemp:GetRealName() + " SFT "
endif

//SF1 - Cabecalho Entrada ( necessario devido codigo da transportadora )
cQuery += "LEFT JOIN "
cQuery += RetSqlName("SF1") + " SF1 ON " //F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SF1.F1_FILIAL = ? "
cQuery += "AND SF1.F1_DOC = SFT.FT_NFISCAL "
cQuery += "AND SF1.F1_SERIE = SFT.FT_SERIE "
cQuery += "AND SF1.F1_FORNECE = SFT.FT_CLIEFOR "
cQuery += "AND SF1.F1_LOJA = SFT.FT_LOJA "
cQuery += "AND SF1.F1_ESPECIE = SFT.FT_ESPECIE "
cQuery += "AND SFT.FT_TIPOMOV = ? "
cQuery += "AND SF1.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SF1"), .F. } )
aadd( aBind, { "E"		 	 , .F. } )
aadd( aBind, { space(1)		 , .F. } )

//SD1 - Itens nota de entrada
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "SD1" ) + " SD1 ON " //D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SD1.D1_FILIAL = ? "
cQuery += "AND SD1.D1_DOC = SFT.FT_NFISCAL "
cQuery += "AND SD1.D1_SERIE = SFT.FT_SERIE "
cQuery += "AND SD1.D1_FORNECE = SFT.FT_CLIEFOR "
cQuery += "AND SD1.D1_LOJA = SFT.FT_LOJA "
cQuery += "AND SD1.D1_COD = SFT.FT_PRODUTO "
cQuery += "AND SD1.D1_ITEM = SFT.FT_ITEM "
cQuery += "AND SD1.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SD1"), .F. } )
aadd( aBind, { space(1)		 , .F. } )

//SA2 - Fornecedores
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "SA2" ) + " SA2 ON " //A2_FILIAL, A2_COD, A2_LOJA, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SA2.A2_FILIAL = ? "
cQuery += "AND SA2.A2_COD = SFT.FT_CLIEFOR "
cQuery += "AND SA2.A2_LOJA = SFT.FT_LOJA "
cQuery += "AND ((SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) ) "
cQuery += "OR (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?) ) ) "
cQuery += "AND SA2.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SA2")			, .F. } )
aadd( aBind, { "E"		 				, .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "S"		 				, .F. } )
aadd( aBind, { { 'B', 'D' }				, .F. } )
aadd( aBind, { space(1)					, .F. } )

//SF2 - Cabecalho Saida ( necessario devido codigo da transportadora )
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "SF2" ) + " SF2 ON " //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SF2.F2_FILIAL = ? "
cQuery += "AND SF2.F2_DOC = SFT.FT_NFISCAL "
cQuery += "AND SF2.F2_SERIE = SFT.FT_SERIE "
cQuery += "AND SF2.F2_CLIENTE = SFT.FT_CLIEFOR "
cQuery += "AND SF2.F2_LOJA = SFT.FT_LOJA "
cQuery += "AND SFT.FT_TIPOMOV = ? "
cQuery += "AND SF2.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SF2"), .F. } )
aadd( aBind, { "S"		 	 , .F. } )
aadd( aBind, { space(1)		 , .F. } )

//SD2 - Itens nota de saída
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "SD2" ) + " SD2 ON " //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SD2.D2_FILIAL = ? "
cQuery += "AND SD2.D2_DOC = SFT.FT_NFISCAL "
cQuery += "AND SD2.D2_SERIE = SFT.FT_SERIE "
cQuery += "AND SD2.D2_CLIENTE = SFT.FT_CLIEFOR "
cQuery += "AND SD2.D2_LOJA = SFT.FT_LOJA "
cQuery += "AND SD2.D2_COD = SFT.FT_PRODUTO "
cQuery += "AND SD2.D2_ITEM = SFT.FT_ITEM "
cQuery += "AND SD2.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SD2"), .F. } )
aadd( aBind, { space(1)		 , .F. } )

//SA1 - Clientes
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "SA1" ) + " SA1 ON " //A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SA1.A1_FILIAL = ? "
cQuery += "AND SA1.A1_COD = SFT.FT_CLIEFOR "
cQuery += "AND SA1.A1_LOJA = SFT.FT_LOJA "
cQuery += "AND ((SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?)) "
cQuery += "OR (SFT.FT_TIPOMOV = ? AND SFT.FT_TIPO IN (?))) "
cQuery += "AND SA1.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SA1")			, .F. } )
aadd( aBind, { "S"		 				, .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "E"		 				, .F. } )
aadd( aBind, { { 'B', 'D' }				, .F. } )
aadd( aBind, { space(1)					, .F. } )

//SB1 - Produtos
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "SB1" ) + " SB1 ON " //B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SB1.B1_FILIAL = ? "
cQuery += "AND SB1.B1_COD = SFT.FT_PRODUTO "
cQuery += "AND SB1.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SB1"), .F. } )
aadd( aBind, { space(1)		 , .F. } )

//SF4 - TES
cQuery += "INNER JOIN "
cQuery += RetSqlName("SF4") + " SF4 ON " //F4_FILIAL, F4_CODIGO, R_E_C_N_O_, D_E_L_E_T_
cQuery += "SF4.F4_FILIAL = ? "
cQuery += "AND SF4.F4_CODIGO = SFT.FT_TES "
cQuery += "AND SF4.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("SF4"), .F. } )
aadd( aBind, { space(1)		 , .F. } )

//F2Q - Complemento Fiscal
cQuery += "LEFT JOIN "
cQuery += RetSqlName( "F2Q" ) + " F2Q ON " //F2Q_FILIAL, F2Q_PRODUT, R_E_C_N_O_, D_E_L_E_T_
cQuery += "F2Q.F2Q_FILIAL = ? "
cQuery += "AND F2Q.F2Q_PRODUT = SFT.FT_PRODUTO "
cQuery += "AND F2Q.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("F2Q"), .F. } )
aadd( aBind, { space(1)		 , .F. } )

//CDN - Cod. ISS
cQuery += "LEFT JOIN "
cQuery += RetSqlName("CDN") + " PROD ON " //CDN_FILIAL, CDN_CODISS, CDN_PROD, R_E_C_N_O_, D_E_L_E_T_
cQuery += "PROD.CDN_FILIAL = ? "
cQuery += "AND PROD.CDN_CODISS = SFT.FT_CODISS "
cQuery += "AND PROD.CDN_PROD = SFT.FT_PRODUTO "
cQuery += "AND PROD.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("CDN"), .F. } )
aadd( aBind, { space(1)		 , .F. } )

//CDN - Cod. ISS
cQuery += "LEFT JOIN "
cQuery += RetSqlName("CDN") + " ISS ON " //CDN_FILIAL, CDN_CODISS, CDN_PROD, R_E_C_N_O_, D_E_L_E_T_
cQuery += "ISS.CDN_FILIAL = ? "
cQuery += "AND ISS.CDN_CODISS = SFT.FT_CODISS "
cQuery += "AND ISS.CDN_PROD = ? "
cQuery += "AND ISS.D_E_L_E_T_ = ? "
aadd( aBind, { xFilial("CDN"), .F. } )
aadd( aBind, { space(1)		 , .F. } )
aadd( aBind, { space(1)		 , .F. } )

If lIntTms .And. lTableDT6
	//Documentos de Transporte
	cQuery += "LEFT JOIN "
	cQuery += RetSqlName("DT6") + " DT6 ON " //DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE, R_E_C_N_O_, D_E_L_E_T_
	cQuery += "DT6.DT6_FILIAL = ? "
	cQuery += "AND DT6.DT6_FILDOC = SFT.FT_FILIAL "
	cQuery += "AND DT6.DT6_DOC = SFT.FT_NFISCAL "
	cQuery += "AND DT6.DT6_SERIE = SFT.FT_SERIE "
	cQuery += "AND DT6.D_E_L_E_T_ = ? "
	aadd( aBind, { xFilial("DT6"), .F. } )
	aadd( aBind, { space(1)		 , .F. } )
EndIf

If lTableDHR
	//NF x Natureza de Rendimento
	cQuery += "LEFT JOIN "
	cQuery += RetSqlName("DHR") + " DHR ON " //DHR_FILIAL, DHR_DOC, DHR_SERIE, DHR_FORNEC, DHR_LOJA, DHR_ITEM, DHR_NATREN, R_E_C_D_E_L_
	cQuery += "DHR.DHR_FILIAL = ? "
	cQuery += "AND DHR.DHR_DOC = SFT.FT_NFISCAL "
	cQuery += "AND DHR.DHR_SERIE = SFT.FT_SERIE "
	cQuery += "AND DHR.DHR_FORNEC = SFT.FT_CLIEFOR "
	cQuery += "AND DHR.DHR_LOJA = SFT.FT_LOJA "
	cQuery += "AND DHR.DHR_ITEM = SFT.FT_ITEM "
	cQuery += "AND DHR.D_E_L_E_T_ = ? "
	aadd( aBind, { xFilial("DHR"), .F. } )
	aadd( aBind, { space(1)		 , .F. } )
EndIf

If lChkSON
	dbSelectArea("SON")
	// CNO - Cadastro Nacional de Obras
	cQuery += "LEFT JOIN " 
	cQuery += RetSqlName( "SON" ) + " SON ON " //ON_FILIAL, ON_CODIGO, R_E_C_N_O_, D_E_L_E_T_

	cQuery += "SON.ON_FILIAL = ? "
	cQuery += "AND (SON.ON_CODIGO = CASE WHEN ( SFT.FT_TIPOMOV = ? ) THEN SF2.F2_CNO "
	cQuery += "WHEN ( SFT.FT_TIPOMOV = ? ) THEN SD1.D1_CNO END "
	cQuery += "AND SON.D_E_L_E_T_ = ? ) "
	aadd( aBind, { xFilial("SON"), .F. } )
	aadd( aBind, { "S"		 	 , .F. } )
	aadd( aBind, { "E"		 	 , .F. } )
	aadd( aBind, { space(1)		 , .F. } )
Endif

cQuery += "ORDER BY FILIAL, TIPOMOV, SERIE, NUM_DOC, COD_PART, COD_MOD, DT_DOC, DT_E_S, STAMP, ITEM "

self:oStatement := FwExecStatement():New( cQuery )
TafSetPrepare(self:oStatement,@aBind)
self:cFinalQuery := self:oStatement:GetFixQuery()

Return Nil

 /*/{Protheus.doc} TempTable
 Execucao da query
	@author Denis Souza / Karen
	@since 09/12/2021
	@return Nil, nulo, não tem retorno.
/*/
Method TempTable() Class TSINFISCAL

//Se existir registro na SFT ou se existir ao menos 1 registro superior a data de corte na CDG E CDT
if self:nQtFTF3 > 0 .Or. self:lRegCDT .Or. self:lRegCDG
	Self:cAlias := getNextAlias()
	TAFConOut("TSILOG000034: " + alltrim(cEmpAnt + "|" + cFilAnt) + " Execucao query extração notas [ Início " + TIME() + " ]" + self:GetQry(), 1, .t., "TSI" )
	//Executa a query da temporaria com as demais tabelas do join
	self:oStatement:OpenAlias( Self:cAlias )
	TafConout( "TSILOG000027 - Processando query de extracao de Notas Fiscais " + alltrim(cEmpAnt+"|"+cFilAnt) + "[ Início " + TIME() + " ]" ,1,.t.,"TSI")
	//chamada da extração, geração json, processamento e posteriormente fecha a temporaria.
	self:ExtrJsonProc()
else
	TafConout( "TSILOG000027A: [ Não existem lançamentos na SF3\SFT\CDT\CDG com a última data de corte " + TIME() + " ] " + self:cQryFTF3, 1, .t., "TSI")
endif

Return Nil

/*/{Protheus.doc} GetQry
	(Método responsável por retornar a propriedade self:cFinalQuery
	@author Henrique Pereira / Denis Souza
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method GetQry() Class TSINFISCAL
return self:cFinalQuery

 /*/{Protheus.doc} GetJsn
Gerar o json completo por nota x itens
	@author Denis Souza / Karen
	@since 09/12/2021
	@return Nil, nulo, não tem retorno.
/*/
Method ExtrJsonProc() Class TSINFISCAL

Local oJObjRet   := nil
Local cChaveSFT  := ""
Local cEspecie   := ""
Local cCodSit    := ""
Local cOpcCanc   := ""
Local aPartDoc   :={}
Local aRegT013AP :={}
Local aClasFis   :={}
Local nLen       := 0
Local lFirstItem := .T.
Local lNextNota  := .F. // Variavel utilizada para controlar montagem do array otherTaxObligationsAdjustmentsAndInformation -> antigo T013AM
Local cIndFrt    := ''
Local cIndPagto  := ''
Local cUltStamp  := ''
Local cStamp     := ''
Local lExit      := .F.
Local lAchouDT6  := .F.
Local lCdOri     := .F.
Local cEstDUY    := ""
Local cNotaUF    := ""
Local aAreaSA1   := {}
Local aPartREM   := {}
Local cUFRem     := ""
Local aPartDES   := {}
Local cUFDes     := {}
Local nSomaItem  := 0
Local cGetDUY    := ""
Local lSeekDUY 	 := .F.
Local nRecnoCDG  := 0
Local nRecnoDHR  := 0
Local nTmOobjRet := 0
Local cDtContPJ  := Alltrim( GetNewPar("MV_VENCIRF","V") ) // Movimentos de pessoa jurídica
Local cDtContPF  := Alltrim( GetNewPar("MV_VCTIRPF","V") ) // Movimentos de pessoa física
Local cTipo      := ''
Local cLocPres   := ''
Local nVlAbatMat := 0

Local lERP       := .T.
Local oModel     := Nil
Local oMldC20    := Nil
Local oMldC30    := Nil
Local oMldC35    := Nil
Local oMldC39    := Nil
Local oMldT9Q    := Nil
Local oMldC2F    := Nil
Local oMldC2D    := Nil
Local oMldC21    := Nil
Local aObjRet    := {}

oModel  := FwLoadModel( "TAFA062" ) //Carrego modelo fora do laco
oMldC20 := oModel:GetModel( 'MODEL_C20' )
oMldC30 := oModel:GetModel( 'MODEL_C30' )
oMldC35 := oModel:GetModel( 'MODEL_C35' )
oMldC39 := oModel:GetModel( 'MODEL_C39' )
oMldT9Q := oModel:GetModel( 'MODEL_T9Q' )
oMldC2F := oModel:GetModel( 'MODEL_C2F' )
oMldC2D := oModel:GetModel( 'MODEL_C2D' )
oMldC21 := oModel:GetModel( 'MODEL_C21' )

DbSelectArea("V5R")
V5R->(DbSetOrder(1)) //V5R_FILIAL, V5R_CODFIL, V5R_ALIAS, V5R_REGKEY

DbSelectArea("C20")
C20->(DbSetOrder(5)) //C20_FILIAL, C20_INDOPE, C20_CODMOD, C20_SERIE, C20_SUBSER, C20_NUMDOC, C20_DTDOC, C20_CODPAR, C20_CODSIT, C20_PROCID

(self:cAlias)->(dbGoTop())

If ( self:cAlias )->( !EOF( ) )
	lFirstItem := .T.
	lNextNota  := .T.
	cUltStamp  := ''

	// Função para posicionar nas tabelas referente ao cabeçalho
	fPosTabCab( ( self:cAlias )->TIPOMOV, ( self:cAlias )->FOR_CLI, ( self:cAlias )->RECCABEC, ( self:cAlias )->RECSA1, ( self:cAlias )->RECSA2 )

	cChaveSFT := (self:cAlias)->(FILIAL + TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD + DT_DOC + DT_E_S + DELSFT)

	// Variáveis T013AP - TRIBUTOS CAPA DOCUMENTO FISCAL
	cEspecie   := AModNot( AllTrim( ( self:cAlias )->COD_MOD ) )
	aPartDoc   := TafPartic( ( self:cAlias )->FOR_CLI )
	aRegT013AP := { }

	/*Notas fiscais de transportes vindas do TMS sempre deverah haver um DT6 correspondente, 
	caso nao haja, saltar para a proxima nota. Instrucoes passadas pela equipe do TMS.*/
	if lIntTms .And. cValToChar((self:cAlias)->RECDT6) == "0" .And. (self:cAlias)->TIPOMOV == "S" .And. cEspecie $ "|07|08|09|10|11|26|27|57" .And. Empty((self:cAlias)->DT_CANC)
		//Tafconout('DbSkip '+(self:cAlias)->NUM_DOC+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
		(self:cAlias)->(DbSkip()) 
		lExit := .T.
	endif

	if !lExit
		//Tafconout('Processando NF '+(self:cAlias)->NUM_DOC+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")

		oJObjRet := JsonObject( ):New( )
		oJObjRet[cTagJs] := { }
		nSomaItem := 0
		While !(self:cAlias)->(Eof()) .And. cChaveSFT == (self:cAlias)->(FILIAL + TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD + DT_DOC + DT_E_S + DELSFT)
			aRegT015AE := { }

			//Posiciona tabela de itens
			fPosTabItm( ( self:cAlias )->TIPOMOV, ( self:cAlias )->RECNOSFT, ( self:cAlias )->RECITENS, ( self:cAlias )->RECSF4, ( self:cAlias )->RECSB1 )

			cTipo := SFT->FT_TIPO	//S(serviço)

			//Monta a capa do documento somentete uma vez, esse laço é para montagem dos itens que vem logo apos esse "if".
			If lFirstItem

				/*-------------------------------
				| Contador por cabecalho de nota |
				--------------------------------*/
				self:nQtNotas++
				lFirstItem := .F.

				IndFrete(self:cAlias,@cIndFrt,@cCodSit,@cOpcCanc,cEspecie)
				cIndPagto := '9'
				
				aAdd( oJObjRet[cTagJs],JsonObject():New())
				nLen := Len(oJObjRet[cTagJs])		

				cNotaUF := Alltrim( ( self:cAlias )->UF_ORIGEM )

				/*
				Regra1) Necessario considerar a UF do cálculo no TMS.
				As regras com os campos de Remetente e Destinatário não definem as UFs que foram pagos o ICMS, 
				causando divergência na operação. O TMS possui um campo para definir esta operação 
				DT6_CDRCAL ( Codigo Regiao Calculo ). Através deste campo, precisamos fazer um seek na DUY
				e pegar o conteúdo do DUY_EST para esta região. Caso o DUY_EST seja igual ao MV_ESTADO, 
				iremos fazer a mesma busca, porém com a região informada no DT6_CDRORI ( Codigo Regiao Origem )

				Regra2) Tratamento de UF na nota referente ao TMS, o cliente possui um lançamento de nota fiscal de transporte,
				onde o transporte eh de responsabilidade do pagador do frete (FOB), mas o tratamento de UF
				nao deve levar em consideracao o Estado do pagador do frete e sim o do destinatario da mercadoria.
				No Protheus a opcao eh configuravel atraves do parametro MV_TMSUFPG com conteúdo F - Destinatário da Mercadoria.
				*/

				lAchouDT6 := cValToChar(( self:cAlias )->RECDT6) != "0"
				If lAchouDT6 .And. lIntTms .And. lTableDT6 .And. ( self:cAlias )->TIPOMOV == "S"
					lCdOri   := .F.
					cEstDUY  := ""
					aAreaSA1 := {}
					aPartREM := {}
					cUFRem := ""
					aPartDES := {}
					cUFDes := {}

					if !Empty(( self:cAlias )->DT6CDRCAL) .Or. !Empty(( self:cAlias )->DT6CDRORI) //Regra1
						If Select("DUY") == 0
							DbSelectArea("DUY")
						EndIf
						
						if Upper(Alltrim( DUY->(IndexKey()))) <> "DUY_FILIAL+DUY_GRPVEN"
							DUY->(DbSetOrder(1)) //DUY_FILIAL, DUY_GRPVEN
						endif
						cGetDUY := ""
						lSeekDUY := GetDUY(xFilial('DUY') + ( self:cAlias )->DT6CDRCAL, @cGetDUY)
						If lSeekDUY
							if Upper(Alltrim(cGetDUY)) == Upper(Alltrim(cMVEstado))
								lCdOri := .T.
							else
								cEstDUY := Upper(Alltrim(cGetDUY))
							endif
						else
							lCdOri := .T.
						endif

						if lCdOri
							cGetDUY := ""
							lSeekDUY := GetDUY(xFilial('DUY') + ( self:cAlias )->DT6CDRORI, @cGetDUY) 
							if lSeekDUY
								if Upper(Alltrim(cGetDUY)) <> Upper(Alltrim(cMVEstado))
									cEstDUY := Upper(Alltrim(cGetDUY))
								endif
							endif
						endif
						if !Empty( cEstDUY )
							cNotaUF := cEstDUY
						endif
					endif

					if Empty(cEstDUY) .And. !lTmsUfPg //Regra2
						aAreaSA1 := SA1->( GetArea() )
						if Upper(Alltrim( SA1->(IndexKey()))) <> "A1_FILIAL+A1_COD+A1_LOJA"
							SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA
						endif

						If SA1->(MsSeek(xFilial("SA1")+( self:cAlias )->(DT6CLIREM+DT6LOJREM)))
							aPartREM := TafPartic("SA1")
							if Valtype( aPartREM ) == "A" .And. Len( aPartREM ) >= 2
								cUFRem := aPartREM[2] //estado
							endif
						EndIf

						If SA1->(MsSeek(xFilial("SA1")+( self:cAlias )->(DT6CLIDES+DT6LOJDES)))
							aPartDES := TafPartic("SA1")
							if Valtype( aPartDES ) == "A" .And. Len( aPartDES ) >= 2
								cUFDes := aPartDES[2] //estado
							endif
						EndIf
						RestArea(aAreaSA1)
						if SubStr(Alltrim( ( self:cAlias )->CFOP),1,1)=="6"
							if Upper(Alltrim(cUFDes)) <> Upper(Alltrim(cMVEstado))
								cNotaUF := cUFDes //Destinatario
							else
								cNotaUF := cUFRem //Remetente
							endif
						endif
					endif
				endif

				nVlAbatMat := 0
				cLocPres   := ''
				//Protecao das chamadas AbatMat e LocPrestac para serem executadas somente se o documento que estiver sendo processado for documento de serviço
				if cTipo == 'S' .Or. alltrim((self:cAlias)->TIPO_DOC) == '6' //posicionado na SFT ou vindo da query
					nVlAbatMat := toNumeric(abatMat(self:cAlias))
					cLocPres   := Alltrim(LocPrestac(self:cAlias))
				endif

				oJObjRet[cTagJs][nLen]["operationType"] 				:= alltrim((self:cAlias)->IND_OPER)    					// 2 - IND_OPER
				oJObjRet[cTagJs][nLen]["documentType" ] 				:= alltrim((self:cAlias)->TIPO_DOC)    					// 3 - TIPO_DOC -> De/Para na query -> FDeParaTAF( )
				oJObjRet[cTagJs][nLen]["taxDocumentIssuer" ] 			:= alltrim((self:cAlias)->IND_EMIT)    					// 4 - IND_EMIT -> De/Para na query
				oJObjRet[cTagJs][nLen]["participatingCode" ] 			:= alltrim((self:cAlias)->COD_PART)  					// 5 - COD_PART
				oJObjRet[cTagJs][nLen]["identificationSituation" ] 		:= cCodSit    	                    					// 6 - COD_SIT  SPEDSITDOC( ) 
				oJObjRet[cTagJs][nLen]["taxDocumentSeries" ] 			:= alltrim((self:cAlias)->SERIE)     					// 7 - SER 
				oJObjRet[cTagJs][nLen]["taxDocumentNumber" ] 			:= alltrim((self:cAlias)->NUM_DOC)     					// 9 - NUM_DOC 
				oJObjRet[cTagJs][nLen]["fiscalDocumentDate" ] 			:= dtoc(sTod((self:cAlias)->DT_DOC))      				// 10 - DT_DOC 
				oJObjRet[cTagJs][nLen]["electronicKeyDocument" ] 		:= alltrim((self:cAlias)->CHV_DOC_E)   					// 11 - CHV_DOC_E
				oJObjRet[cTagJs][nLen]["documentValue" ] 				:= toNumeric((self:cAlias)->VL_DOC)  	  				// 12 - VL_DOC 
				oJObjRet[cTagJs][nLen]["typeOfPayment" ] 				:= alltrim(cIndPagto)    								// 13 - IND_PGTO
				oJObjRet[cTagJs][nLen]["discountAmount" ] 				:= toNumeric((self:cAlias)->VL_DESC)     				// 14 - VL_DESC
				oJObjRet[cTagJs][nLen]["modelIdentificationCode"]		:= cEspecie					     						// 15 - COD_MOD -> AModNot( )
				oJObjRet[cTagJs][nLen]["finalDocumentNumber"]			:= alltrim((self:cAlias)->NUM_DOC) 						// 16 - NUM_DOC_FIN
				oJObjRet[cTagJs][nLen]["valueOfGoods"]					:= toNumeric((self:cAlias)->VL_MERC) 					// 18 - VL_MERC
				oJObjRet[cTagJs][nLen]["taxDocumentEntryAndExitDate"]	:= dtoc(sTod((self:cAlias)->DT_E_S)) 					// 19 - DT_E_S
				oJObjRet[cTagJs][nLen]["amountOfAccessoryExpenses"]		:= toNumeric((self:cAlias)->VL_DA) 						// 20 - VL_DA 
				oJObjRet[cTagJs][nLen]["shippingIndicator"]				:= alltrim(cIndFrt)										// 25 - IND_FRT
				oJObjRet[cTagJs][nLen]["insuranceAmount"]				:= toNumeric((self:cAlias)->VL_SEG)						// 26 - VL_SEG
				oJObjRet[cTagJs][nLen]["otherExpenses"]					:= toNumeric((self:cAlias)->VL_OUT_DESP) 				// 27 - VL_OUT_DESP
				oJObjRet[cTagJs][nLen]["freight"]						:= toNumeric((self:cAlias)->VL_FRT) 					// 28 - VL_FRT
				oJObjRet[cTagJs][nLen]["untaxedAllowanceAmount"]		:= toNumeric((self:cAlias)->VL_ABAT_NT) 				// 30 - VL_ABAT_NT
				oJObjRet[cTagJs][nLen]["AIDFNumber"]					:= Taf558Aidf( (self:cAlias)->NUM_DOC, (self:cAlias)->SERIE ) // 31 - NUM_AUT
				oJObjRet[cTagJs][nLen]["valueOfServices"]				:= toNumeric((self:cAlias)->VL_SERV) 					// 38 - VL_SERV
				oJObjRet[cTagJs][nLen]["invoiceCancellationDate"]		:= alltrim((self:cAlias)->DT_CANC) 						// 56 - DT_CANC
				oJObjRet[cTagJs][nLen]["placeOfDelivery"]				:= cLocPres												// 62 - LOC_PRESTACAO				 
				oJObjRet[cTagJs][nLen]["valueReducedISSMaterials"]		:= nVlAbatMat											// 63 - VL_DED_ISS_MAT
				oJObjRet[cTagJs][nLen]["federativeUnitOrigin"]		    := cNotaUF   											// 69 - UF_ORIGEM
				oJObjRet[cTagJs][nLen]["opCancelation"]				 	:= cOpcCanc												//Tag Generica para saber se atualiza ou deleta nota no TAF
				oJObjRet[cTagJs][nLen]["stamp"] 						:= (self:cAlias)->STAMP           						// 9 - STAMP
				oJObjRet[cTagJs][nLen]["paymentIndicator"] 				:= (self:cAlias)->INDPAG             					// 100 - Indicador de pagamento
				oJObjRet[cTagJs][nLen]["couponFieldContent"]			:= (self:cAlias)->NFCUPOM             					// 101 - NFCUPOM / Indica se a nota fiscal vem de um cupom fiscal
				if lTableSON
					oJObjRet[cTagJs][nLen]["registrationType"] 				:= alltrim( (self:cAlias)->TPINSCR )					// 70 -TP_INSCRICAO
					oJObjRet[cTagJs][nLen]["cnoNumber"] 					:= alltrim( (self:cAlias)->CNO )						// 65 -NR_INSC_ESTAB
				endif
				If AllTrim(cDtContPF) $ 'C' .Or. AllTrim(cDtContPJ) $ 'C'
					oJObjRet[cTagJs][nLen]["accountingDate"]			:= dtoc(sTod((self:cAlias)->DT_E_S)) 					// 74 - Dt. Contabilização
				Endif

				if lDtCpIss
					oJObjRet[cTagJs][nLen]["competenceIss"]				:= dtoc(sTod((self:cAlias)->F1DTCPISS))					//Data Competencia ISS
				endif

				oJObjRet[cTagJs][nLen]["clieFor"] 				    	:= (self:cAlias)->CLIEFOR //Nao existe no Hash, utilizado apenas na alteracao fake da SFT ( V5R x C20 )
				oJObjRet[cTagJs][nLen]["loja"] 				    		:= (self:cAlias)->LOJA    //Nao existe no Hash, utilizado apenas na alteracao fake da SFT ( V5R x C20 )

				/* Nao existe no Hash, as tags abaixo serao utilizadas para controle do RPS, que foi integrado no TAF sem FT_NFELETR preenchido e posteriormente foi transmitido
				no faturamento, nesse momento eh preenchido o FT_NFELETR com uma numeracao diferente do FT_NFISCAL, nesse caso o RPS devera ser excluido no TAF, 
				pois sera integrado uma nova nota com a numeracao do FT_NFELETR, ver trecho: { Controle para inativar o RPS } no WSTAF034 */
				oJObjRet[cTagJs][nLen]["especie"]			 := Upper(Alltrim((self:cAlias)->COD_MOD))
				oJObjRet[cTagJs][nLen]["electronicInvoice"]  := Alltrim((self:cAlias)->FTNFELETR)
				oJObjRet[cTagJs][nLen]["invoice"] 		     := Alltrim((self:cAlias)->FTNFISCAL)

				oJObjRet[cTagJs][nLen][cTagT015] := { } //para o primeiro item da nota cria o array no json
			
				//Gera json complementaryInfoText layout T013AA
				if self:lRegCDT .And. !Empty((self:cAlias)->CDTSTAMP) .And. Alltrim(cEspecie) $ "01|1B|04|55"
					oJObjRet[cTagJs][nLen][cTag013AA] := { }
					compInfoByTax( self:cAlias, @oJObjRet, nLen )
				Endif

				//Gera json tickets layout T013AI (ticketsByInvoice)
				// Retirado 19/03/2025 pois o TAF não considera a tabela C29 em nenhuma das obrigacoes.
				// Com esse trecho retirado (SE1\SE2), a query que estava sendo executado em 6 horas na JadLog, abaixou para 7 minutos.
				// Caso necessite do NUMFAT, verificar historico no TFS para recuparar a query e suas amarracoes.
			EndIf
			// NF EXCLUIDA não alimenta Itens, nao passa do loop para baixo, para nao inserir o fiscalDocumentItems e fazer processamento desnecessario
			If Upper( Alltrim( (self:cAlias)->(OBSERV) ) ) == 'NF EXCLUIDA' 
				if TsiCompStamp( AllTrim((self:cAlias)->STAMP), cStamp )
					cStamp := AllTrim((self:cAlias)->STAMP)
				endif
				( self:cAlias )->( DbSkip( ) )
				//Abaixo de todos os DbSkips, inserir a regra para comparar chave
				if !(self:cAlias)->(Eof()) .And. cChaveSFT <> (self:cAlias)->( FILIAL + TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD + DT_DOC + DT_E_S + DELSFT)
					//Sempre adiciona oJObjRet no aObjRet quando houver skip...
					aadd( aObjRet , oJObjRet )
					//STEP 1 - Nesse IF iremos processar apenas se atingir o limite de X NF
					If self:nQtNotas == self:nSizeMax
						self:CallWs034Proc( .F.,lERP,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21,@aObjRet,@oJObjRet )
					endif
					//Abaixo atualiza a chave e todos os campos de atribuicao que consta dentro do laco de repeticao while...
					cChaveSFT  := (self:cAlias)->( FILIAL + TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD + DT_DOC + DT_E_S + DELSFT)
					lFirstItem := .T. //importante que seja .t. para inserir a nova chave a ser processada no oJObjRet
					nSomaItem  := 0
					cEspecie   := AModNot( AllTrim( ( self:cAlias )->COD_MOD ) )
					aPartDoc   := TafPartic( ( self:cAlias )->FOR_CLI )
					aRegT013AP := { }
				//Atualiza o stamp antes do loop
				elseif (self:cAlias)->(Eof())
					if TsiCompStamp( cStamp, cUltStamp ) 
						cUltStamp := cStamp
					endif
				endif
				//o loop aqui eh pq a nota eh excluida e nao precisa montar os filhos apenas o cabecalho
				Loop
			EndIf

			//gera array otherTaxObligationsAdjustmentsAndInformation -> antigo T013M
			Taf574CDA( self:cAlias, @oJObjRet, nLen, lNextNota )

			lNextNota := .F.

			aClasFis := SPDRetCCST( "SFT", .T., cEspecie, "SF4", "SB1", aPartDoc[02] )

			If Len( AllTrim( aClasFis[1] ) ) == 3 // Sempre que for tamanho 3 , o imposto é ICMS
				aClasFis[1] := SubStr( aClasFis[1], 2, 2 )
			EndIf

			/*
				Utiliando a função FBusTribNf no extrator anterior ( EXTFISXTAF ),
				o array aRegT015AE é alimentado/acumulado de acordo com os itens da nota que são pecorridos ( dbsKip ), 
				e ao passar para a próxima nota, o array é descarregado em txt/banco.

				Para o TSI, o array aRegT015AE é alimentado e descarregado em json no mesmo momento em que o item é pecorrido, 
				ou seja, o array não é mais acumulado, por isso é passado o valor "1" no 5o parametro.
			*/
			nRecnoCDG := 0
			If self:lRegCDG
				nRecnoCDG := (self:cAlias)->RECCDG
			EndIf
			nRecnoDHR := 0
			If lTableDHR
				nRecnoDHR := (self:cAlias)->RECDHR
			EndIf	
			If Empty(AllTrim((self:cAlias)->IDTRIB))
				FBusTribNf( cEspecie, aPartDoc, @aRegT013AP, @aRegT015AE, 1,,,,,,, @aClasFis, nRecnoCDG,,,,,, nRecnoDHR)
			Else
				//Caso exista IDTRIB na SFT, será enviado como parâmetro para que seja feita a busca na tabela F2D (Impostos calculados pelo configurador de tributos FISA170)
				FBusTribNf( cEspecie, aPartDoc, @aRegT013AP, @aRegT015AE, 1,,,,,,, @aClasFis, nRecnoCDG, (self:cAlias)->FILIAL, Alltrim((self:cAlias)->IDTRIB),,,,nRecnoDHR)
			Endif

			//T015 - Cadastro dos Itens dos Documentos Fiscais
			nSomaItem++
			//Tafconout('Adicionando itens para NF '+(self:cAlias)->NUM_DOC+"- Thread " + cValtoChar(ThreadId()),1,.t.,"TSI")
			fiscalDocumentItems( @self, self:cAlias, @oJObjRet, nLen, aRegT015AE, nSomaItem ) //inseri o item da nota

			//Comparo o ultimo stamp gravado com o atual e atualizao a variavel caso seja verdadeiro.
			if self:lRegCDG //controle para saber se o stamp do complemento da nota processo judicial eh superior ao da SFT T0015Ak
				if !FindFunction('TsiCompStamp')
					cStamp := iif( Alltrim((self:cAlias)->STAMP) >= Alltrim((self:cAlias)->CDGSTAMP) , Alltrim((self:cAlias)->STAMP), Alltrim((self:cAlias)->CDGSTAMP) )
				else
					cStamp := iif( TsiCompStamp(AllTrim((self:cAlias)->STAMP),  Alltrim((self:cAlias)->CDGSTAMP)) , AllTrim((self:cAlias)->STAMP),  Alltrim((self:cAlias)->CDGSTAMP) )
				Endif
			else
				cStamp := Alltrim((self:cAlias)->STAMP)
			endif

			//Controle para saber se o stamp da informação complementar (CDT) T013AA é superior ao armazezado na varável cStamp
			if self:lRegCDT
				if !FindFunction('TsiCompStamp')
					cStamp := iif( AllTrim((self:cAlias)->CDTSTAMP) > cStamp , AllTrim((self:cAlias)->CDTSTAMP), cStamp )
				else
					cStamp := iif( TsiCompStamp(AllTrim((self:cAlias)->CDTSTAMP), cStamp) , AllTrim((self:cAlias)->CDTSTAMP), cStamp )
				Endif
			endif

			if iif(FindFunction('TsiCompStamp'),TsiCompStamp(cStamp, cUltStamp),cStamp > cUltStamp)
				cUltStamp := cStamp
			endif
			( self:cAlias )->( DbSkip( ) )
			//Abaixo de todos os DbSkips, inserir a regra para comparar chave
			if !(self:cAlias)->(Eof()) .And. cChaveSFT <> (self:cAlias)->(FILIAL + TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD + DT_DOC + DT_E_S + DELSFT)
				//Atualiza o aRegT013AP quando houver mudanca de chave e a proxima nao for de exclusao
				valueByTax( @oJObjRet[cTagJs][nLen], aRegT013AP )
				//Sempre adiciona oJObjRet no aObjRet quando houver skip...
				aadd( aObjRet , oJObjRet )
				//STEP 1 Gravacao - Nesse IF iremos processar apenas se atingir o limite de X NF
				If self:nQtNotas == self:nSizeMax
					self:CallWs034Proc( .F.,lERP,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21,@aObjRet,@oJObjRet )
				endif
				//Atualiza chave e todos os campos de atribuicao dentro do laco de repeticao
				cChaveSFT  := ( self:cAlias )->(FILIAL + TIPOMOV + SERIE + NUM_DOC + COD_PART + COD_MOD + DT_DOC + DT_E_S + DELSFT)
				lFirstItem := .T.
				nSomaItem  := 0
				cEspecie   := AModNot( AllTrim( ( self:cAlias )->COD_MOD ) )
				aPartDoc   := TafPartic( ( self:cAlias )->FOR_CLI )
				aRegT013AP := { }
			endif
		EndDo

		// gera array valueByTax -> Antigo T013AP
		valueByTax( @oJObjRet[cTagJs][nLen], aRegT013AP )

		//Gravo no stamp do cabecalho o maior stamp encontrado entre os intens do documento fiscal
		oJObjRet[cTagJs][ len(oJObjRet[cTagJs]) ]['stamp'] := cUltStamp

		//STEP 2 Gravacao - Nesse IF após o WHILE, iremos processar as NF que existirem no aObjRet. Não é preciso comparar total de registros pois já terminou a laço na tabela
		//Se houver alguma invoice no oJObjRet adiciona no aObjRet para processar o restante do lote
		nTmOobjRet := len(oJObjRet["invoice"])

		if nTmOobjRet >= 1
			self:CallWs034Proc( .T.,lERP,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21,@aObjRet,@oJObjRet )
		endif
	endif
endif

if Select( self:cAlias ) > 0 .And. (self:cAlias)->(EOF())
	(self:cAlias)->(DbCloseArea())
endif

self:CleanTmpFTF3()

Return Nil

/*/{Protheus.doc} GetHashCahed
	Retorno Hash static que está no fonte TAFA574 para ser utilizado no WS034Proc
	@since 03/08/2022
	@return Nil, nulo, não tem retorno.
/*/

Method GetHashCahed(cAlias) Class TSINFISCAL

Return &('oHash'+cAlias)

/*/{Protheus.doc} Taf558Aidf
	Regraas para AIDF
	@since 05/10/2020
	@return Nil, nulo, não tem retorno.
/*/

static function Taf558Aidf(cNum, cSerie)

Local cDisp := ""
Local aAidf := {}

	// Utilizo a funcao do MATXMAG para retornar o dispositivo AIDF do documento
	aAidf := RetAidf( cNum, cSerie )
	
	If !Empty(aAidf[1])
		Do Case
		Case Alltrim(aAidf[2]) == "1"
			cDisp :="04"
		Case Alltrim(aAidf[2]) == "2"
			cDisp :="03"
		Case Alltrim(aAidf[2]) == "3"
			cDisp :="00"
		Case Alltrim(aAidf[2]) == "4"
			cDisp :="05"
		Case Alltrim(aAidf[2]) == "6"
			cDisp :="02"
		Case Alltrim(aAidf[2]) == "7"
			cDisp :="01"
		EndCase
	EndIf

Return cDisp

 /*/{Protheus.doc} LocPrestac
	(Function responsável por retornar o local de prestação de serviço:
    Regra:
    Notas de entrada: Se o serviço for configurado como “EP” (B1_MEPLES = 1 ou Branco), 
    ou seja, ISS devido no estabelecimento do prestador, o ISS será considerado devido 
    no município do fornecedor do documento (A2_COD_MUN).
    Se o serviço for configurado como “LES” (B1_MEPLES = 2), ou seja, ISS devido 
    no local de execução do serviço, primeiramente serão avaliados os campos F1_ESTPRES e 
    F1_INCISS, que podem ser informados no momento da digitação do documento de entrada. 
    Se estes campos estiverem preenchidos, o ISS será considerado devido no município ali definido. 
    Caso contrário, o ISS será considerado devido no município do SIGAMAT (M0_CODMUN).

    Notas de saída: Se o serviço for configurado como “EP” (B1_MEPLES = 1 ou Branco), ou seja, ISS devido no 
    estabelecimento do prestador, o ISS será considerado devido no município do SIGAMAT (M0_CODMUN).
    Se o serviço for configurado como “LES” (B1_MEPLES = 2), ou seja, ISS devido no local de execução do serviço, 
    primeiramente serão avaliados os campos F2_ESTPRES e F2_MUNPRES, preenchidos através dos campos C5_ESTPRES e C5_MUNPRES 
    no pedido de venda. Se estes campos estiverem prenchidos o ISS será considerado devido no município ali definido. 
    Caso contrário o ISS será considerado devido no município do cliente de faturamento (A1_COD_MUN).
    
	@author Henrique Pereira
	@since 11/09/2020  
	@return Nil, nulo, não tem retorno.
/*/

static function LocPrestac(cAlias)
Local cLocPRest :=	''
Local aAreaSA2	:=	SA2->(GetArea()) 
Local aAreaSB1	:=	SB1->(GetArea())

SA2->(DbSetOrder(1))
SB1->(DbSetOrder(1))

	If (cAlias)->TIPOMOV == 'E' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If SB1->(MsSeek(xFilial('SB1')+(cAlias)->PRODUTO))
			If SB1->B1_MEPLES = '1' .or. empty(SB1->B1_MEPLES)			
				if SA2->(MsSeek(xFilial('SA2')+(cAlias)->CLIEFOR+(cAlias)->LOJA))
					cLocPRest := SA2->A2_EST + SA2->A2_COD_MUN //SP + 13801 ---> C20_CODLOC = C07_ID (003881) C07_UF = (000027)	C07_CODIGO (13801)
				endif
			elseIf SB1->B1_MEPLES = '2'
				if !empty((cAlias)->ESTPRES) .and. !empty((cAlias)->MUNPRES)
					cLocPRest := (cAlias)->ESTPRES + (cAlias)->MUNPRES //F1_ESTPRES(UF Prestacao Tm 2) + F1_INCISS(Mun. Incid. Tm 5)
				else
					cLocPRest := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {'M0_CODMUN'} )[1][2]
				endif
			endif
		endif
 
	elseIf (cAlias)->TIPOMOV == 'S' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If SB1->(MsSeek(xFilial('SB1')+(cAlias)->PRODUTO))
			If SB1->B1_MEPLES = '1' .or. empty(SB1->B1_MEPLES)	
				cLocPRest := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {'M0_CODMUN'} )[1][2]  				
			elseIf SB1->B1_MEPLES = '2' 

				if !empty((cAlias)->ESTPRES) .and. !empty((cAlias)->MUNPRES)
					if SA1->(MsSeek(xFilial('SA1')+(cAlias)->CLIEFOR+(cAlias)->LOJA))
						cLocPRest := SA1->A1_COD_MUN
					endif
				else 
					cLocPRest := (cAlias)->MUNPRES
				endif

			endif
		endif

	endif

restarea(aAreaSA2)
restarea(aAreaSB1)

return cLocPRest

 /*/{Protheus.doc} abatMat
	(Static Function responsável retornar o valor de abatimento 
	@author Henrique Pereira
	@since 11/09/2020  
	@return Nil, nulo, não tem retorno.
/*/

static function abatMat(cAlias)
Local nValAbat 	:=	0
Local cQuery	:=	''
Local cAlaisEnt	:=  getNextAlias()
Local cAlaisSai	:=  getNextAlias()
    
	If (cAlias)->TIPOMOV == 'E' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If __oStatSai == nil

			cQuery += " SELECT SUM(SD1.D1_ABATMAT) ABATMAT FROM "
			cQuery += RetSqlName("SD1") + " SD1 "
			cQuery += " 	WHERE SD1.D1_FILIAL = ? "
			cQuery += " 	AND SD1.D1_DOC      = ? " 
			cQuery += " 	AND SD1.D1_SERIE    = ? "
			cQuery += " 	AND SD1.D1_FORNECE  = ? "
			cQuery += " 	AND SD1.D1_LOJA     = ? "
			cQuery += " 	AND SD1.D1_COD      = ? "
			cQuery += " 	AND SD1.D1_ITEM     = ? "
			cQuery += " 	AND SD1.D_E_L_E_T_  = ? "
			
			__oStatSai := FWPreparedStatement():New()
			__oStatSai:SetQuery(cQuery)
			
		Endif

		__oStatSai:SetString(1,xFilial('SD1'))
		__oStatSai:SetString(2,(cAlias)->NUM_DOC)
		__oStatSai:SetString(3,(cAlias)->SERIE)
		__oStatSai:SetString(4,(cAlias)->CLIEFOR)
		__oStatSai:SetString(5,(cAlias)->LOJA)
		__oStatSai:SetString(6,(cAlias)->PRODUTO)
		__oStatSai:SetString(7,(cAlias)->ITEM) 
		__oStatSai:SetString(8,' ')

		dbUseArea(.T., "TOPCONN", TCGenQry(, , __oStatSai:GetFixQuery()), cAlaisSai, .F., .T.)
		nValAbat := (cAlaisSai)->ABATMAT

		(cAlaisSai)->(DbCloseArea())
	
    elseIf (cAlias)->TIPOMOV == 'S' .and. !((cAlias)->TIPO $ ( 'B', 'D' ))

		If __oStatEnt == nil

			cQuery += " SELECT SUM(SD2.D2_ABATMAT) ABATMAT FROM "
			cQuery += RetSqlName("SD2") + " SD2 "
			cQuery += " 	WHERE SD2.D2_FILIAL = ? "
			cQuery += " 	AND SD2.D2_DOC      = ? " 
			cQuery += " 	AND SD2.D2_SERIE    = ? "
			cQuery += " 	AND SD2.D2_CLIENTE  = ? "
			cQuery += " 	AND SD2.D2_LOJA     = ? "
			cQuery += " 	AND SD2.D2_COD      = ? "
			cQuery += " 	AND SD2.D2_ITEM     = ? "
			cQuery += " 	AND SD2.D_E_L_E_T_  = ? "
			
			__oStatEnt := FWPreparedStatement():New()
			__oStatEnt:SetQuery(cQuery)
		Endif 

		__oStatEnt:SetString(1,xFilial('SD2'))
		__oStatEnt:SetString(2,(cAlias)->NUM_DOC)
		__oStatEnt:SetString(3,(cAlias)->SERIE)
		__oStatEnt:SetString(4,(cAlias)->CLIEFOR)
		__oStatEnt:SetString(5,(cAlias)->LOJA)
		__oStatEnt:SetString(6,(cAlias)->PRODUTO)
		__oStatEnt:SetString(7,(cAlias)->ITEM) 
		__oStatEnt:SetString(8,' ')

		dbUseArea(.T., "TOPCONN", TCGenQry(, , __oStatEnt:GetFixQuery()), cAlaisEnt, .F., .T.)
		nValAbat := (cAlaisEnt)->ABATMAT
		(cAlaisEnt)->(DbCloseArea())

	endif

return nValAbat

 /*/{Protheus.doc} Taf574CDA
	Executa a query em CDA e monta o json
	@author Henrique Pereira
	@since 11/09/2020  
	@return Nil, nulo, não tem retorno.
/*/

static function Taf574CDA(cAliasSFT, oJObjRet, nLen, lNextNota )
	
	Local cAlaisCDA  as character
	Local cQuery     as character
	Local cFormul    as character
	Local cProduto	 as character
	Local cCodSubIte as character
	Local cChave     as character
	Local cIsNull    as character
	Local nLenCDA    as numeric

	
	cAlaisCDA	:= getNextAlias()
	cFormul		:= Iif(Empty((cAliasSFT)->FORMUL),Iif((cAliasSFT)->TIPOMOV == "S","S"," "),(cAliasSFT)->FORMUL)
	cProduto	:= (cAliasSFT)->PRODUTO
	cCodSubIte	:=	''
	cChave		:=	''
	nLenCDA		:= 0
	cIsNull		:=  ''
	cBD 		:= TcGetDb()

	If cBD $ "ORACLE"
		cIsNull := "NVL"
	ElseIf  cBD $ "POSTGRES"
		cIsNull := "COALESCE" 
	Else
		cIsNull := "ISNULL"
	EndIf

	If __oStatCDA == nil

		cQuery := " SELECT "
		cQuery += "		CDA.CDA_FILIAL FILIAL, "
		cQuery += " 	CDA.CDA_CODLAN CODLAN, "
		cQuery += 		cIsNull + " (CCE.CCE_DESCR, ' ') DESCRI_IFCOM, "
		cQuery += " 	CDA.CDA_ALIQ ALIQ, "
		cQuery += " 	SUM(CDA.CDA_BASE) BASE, "
		cQuery += " 	SUM(CDA.CDA_VALOR) VALOR "
		cQuery += " FROM " + RetSqlName("CDA") + " CDA " 
		cQuery += " LEFT JOIN " + RetSqlName("CCE") + " CCE "
		cQuery += " 	ON CDA.CDA_IFCOMP = CCE.CCE_COD AND CCE.CCE_FILIAL = '" + xFilial( "CCE" ) + "' AND CCE.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE CDA.CDA_FILIAL  = ? "
		cQuery += " 	AND CDA.CDA_TPMOVI  = ? " 
		cQuery += " 	AND CDA.CDA_ESPECI  = ? "
		cQuery += " 	AND CDA.CDA_FORMUL  = ? "
		cQuery += " 	AND CDA.CDA_NUMERO  = ? "
		cQuery += " 	AND CDA.CDA_CLIFOR  = ? "
		cQuery += " 	AND CDA.CDA_LOJA 	= ? "
		cQuery += " 	AND CDA.CDA_TPLANC	= ? "
		cQuery += " 	AND CDA.CDA_NUMITE	= ? "			
		cQuery += " 	AND CDA.D_E_L_E_T_  = ? "
		cQuery += " GROUP BY CDA.CDA_FILIAL, CDA.CDA_CODLAN, " + cIsNull + " (CCE.CCE_DESCR, ' ') , CDA.CDA_ALIQ  "

		__oStatCDA 	:= FWPreparedStatement():New()
		__oStatCDA:SetQuery(cQuery)

	Endif
	
	__oStatCDA:SetString(1,xFilial('CDA'))
	__oStatCDA:SetString(2,(cAliasSFT)->TIPOMOV)
	__oStatCDA:SetString(3,(cAliasSFT)->COD_MOD)
	__oStatCDA:SetString(4,cFormul)
	__oStatCDA:SetString(5,(cAliasSFT)->NFISCAL)
	__oStatCDA:SetString(6,(cAliasSFT)->CLIEFOR )
	__oStatCDA:SetString(7,(cAliasSFT)->LOJA) 
	__oStatCDA:SetString(8,"2")
	__oStatCDA:SetString(9,(cAliasSFT)->ITEM) 	
	__oStatCDA:SetString(10,' ')

	dbUseArea(.T., "TOPCONN", TCGenQry(, , __oStatCDA:GetFixQuery()), cAlaisCDA, .F., .T.)

	if (cAlaisCDA)->(!EOF())

		if lNextNota .Or. ValType(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"]) == "U"
			oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"] := {}
		EndIf
		(cAlaisCDA)->(!DbGoTop())	
		While  (cAlaisCDA)->(!EOF()) // Pode se ter mais de um código de lançamento amarrado a TES do item, por isso exite a necessidade do laço while
			
			cCodSubIte	:=	Taf574SI(cAliasSFT)

			cChave := (cAlaisCDA)->CODLAN+cProduto+cCodSubIte+cvaltochar((cAlaisCDA)->ALIQ)

			If ValType(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"]) <> "U"

				nLenCDA := aScan(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"],{|x|x["adjustmentCode"]+x["product"]+x["subitemCode"];
				+cValToChar(x["aliquot"])==cChave})

			Endif

			If nLenCDA == 0 
			
				//if cChave <> (cAlaisCDA)->FILIAL+(cAlaisCDA)->CODLAN+cProduto+cCodSubIte+cvaltochar((cAlaisCDA)->ALIQ)	
			
				aAdd( oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"],JsonObject():New())
				nLenCDA := Len(oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"])
																																						// Campos da Planilha Layout TAF - T013AM												
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["adjustmentCode"]		:=	(cAlaisCDA)->CODLAN 		//02-COD_AJ                                                    
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["settingDescription"]	:=	(cAlaisCDA)->DESCRI_IFCOM	//03-DESCR_COMPL_AJ
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["product"]				:=	cProduto					//04-COD_ITEM
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["basisOfCalculation"]	:=	(cAlaisCDA)->BASE			//05-VL_BC_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["aliquot"]				:=	(cAlaisCDA)->ALIQ			//06-ALIQ_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["value"]				:=	(cAlaisCDA)->VALOR  		//07-VL_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["subitemCode"]			:=	cCodSubIte					//09-COD_SUBITEM
			
			else
			
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["basisOfCalculation"]	+=	(cAlaisCDA)->BASE			//05-VL_BC_ICMS
				oJObjRet[cTagJs][nLen]["otherTaxObligationsAdjustmentsAndInformation"][nLenCDA]["value"]				+=	(cAlaisCDA)->VALOR			//07-VL_ICMS
			
			endif
			
			(cAlaisCDA)->(DbSkip())

		enddo

	endif

	( cAlaisCDA )->( DBCloseArea( ) )

return 

/*/{Protheus.doc} Taf574SI()
	Função responsavel por realizar o tratamento dos códigos de SubItem pra notas fiscais
	que devem ser enviados para o TAF

	@author Henrique Pereira
	@since 05/10/2020
/*/

Static Function Taf574SI(cAliasSFT)

	Local cRet		:= ''

	/*
	TRATAMENTO PARA O ESTADO DE MINAS GERAIS 
	Atende a regra de geração da DAPI/MG
	*/
	If cMVEstado == "MG"

			/*
			Caso o campo da TES esteja como '1' apenas verifico se a operação em questão é
			de entrada ou saída para definir qual o código de Subitem que devo mandar
			para o TAF
			*/

			If (cAliasSFT)->TRFICM == "1"  
				If (cAliasSFT)->IND_OPER == "0"  // entrada 
					cRet := "00066"
				Else
					cRet := "00073"
				EndIf
			EndIf

			// F4_ESTCRED
			If  (cAliasSFT)->ESTCRED > 0 // SF4
				cRet := "00090"
			EndIf

			// FT_ESTCRED
			If (cAliasSFT)->IND_OPER == "0" .and. (cAliasSFT)->FTESTCRED > 0
				cRet := "00095" 
			EndIf
	ElseIf cMVEstado == "SP"
		// Relaciona o código do subitem referente a CFOP enviada na chamada da Função, para atender a GIA-SP
		If (cAliasSFT)->CFOP $ "5601|1605"
			cRet := "00219"
		ElseIf (cAliasSFT)->CFOP $ "1601|1602"
			cRet := "00730"
		ElseIf (cAliasSFT)->CFOP == "5602"
			cRet := "00218"
		ElseIf (cAliasSFT)->CFOP == "5605"
			cRet := "00729"
		ElseIf (cAliasSFT)->CFOP $ "5603|6603" 
			cRet := "00210"
		ElseIf (cAliasSFT)->CFOP $ "5603|6603"
			cRet := "00701"
		EndIf
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} valueByTax
Função responsável por elaborar json do registro T013AP - Cadastro de tributos por documento fiscal

@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  aRegT013AP -> array com as inforrmações e valores de tributos da nota fiscal

@author Wesley Pinheiro
@since 14/10/2020

/*/
//-------------------------------------------------------------------
static function valueByTax( oJObjRet, aRegT013AP )

	Local nI       := 0
	Local nLen13AP := 0
	Local nTam13AP := Len( aRegT013AP )

	If nTam13AP > 0

		oJObjRet[cTag13AP] := { }

		for nI:= 1 to nTam13AP

			aAdd( oJObjRet[cTag13AP], JsonObject( ):New( ) )
			nLen13AP := Len( oJObjRet[cTag13AP] )

			oJObjRet[cTag13AP][nLen13AP]["taxCode"]                 := aRegT013AP[nI][NAPCODTRIB] // 02 - COD_TRIB       -> C2F_CODTRI  
			oJObjRet[cTag13AP][nLen13AP]["calculationBase"]	        := aRegT013AP[nI][NAPBS]      // 03 - BASE           -> C2F_BASE 
			oJObjRet[cTag13AP][nLen13AP]["calculationBaseAmount"]   := aRegT013AP[nI][NAPBSQTD]   // 04 - BASE_QUANT     -> C2F_BASEQT
			oJObjRet[cTag13AP][nLen13AP]["calculationBaseNotTaxed"] := aRegT013AP[nI][NAPBSNT]    // 05 - BASE_NT        -> C2F_BASENT
			oJObjRet[cTag13AP][nLen13AP]["taxValue"]                := aRegT013AP[nI][NAPVLR]     // 06 - VALOR          -> C2F_VALOR			
			oJObjRet[cTag13AP][nLen13AP]["taxBaseValue"]            := aRegT013AP[nI][NAPVLRTRIB] // 07 - VLR_TRIBUTAVEL -> C2F_VLRPAU
			oJObjRet[cTag13AP][nLen13AP]["exemptValue"]             := aRegT013AP[nI][NAPVLRISEN] // 08 - VLR_ISENTO     -> C2F_VLISEN
			oJObjRet[cTag13AP][nLen13AP]["otherValue"]              := aRegT013AP[nI][NAPVLROUTR] // 09 - VLR_OUTROS     -> C2F_VLOUTR
			oJObjRet[cTag13AP][nLen13AP]["nonTaxedValue"]           := aRegT013AP[nI][NAPVLRNT]   // 10 - VALOR_NT       -> C2F_VLNT
			oJObjRet[cTag13AP][nLen13AP]["cst"]                     := aRegT013AP[nI][NAPCST]     // 11 - CST            -> C2F_CST
			oJObjRet[cTag13AP][nLen13AP]["cfop"]                    := aRegT013AP[nI][NAPCFOP]    // 12 - CFOP           -> C2F_CFOP
			oJObjRet[cTag13AP][nLen13AP]["taxRate"]                 := aRegT013AP[nI][NAPALIQ]    // 13 - ALIQUOTA       -> C2F_ALIQ
			oJObjRet[cTag13AP][nLen13AP]["serviceCode"]             := aRegT013AP[nI][NAPCODLST]  // 14 - COD_LST        -> C2F_CODSER
			oJObjRet[cTag13AP][nLen13AP]["operationValue"]          := aRegT013AP[nI][NAPVLROPER] // 15 - VL_OPER        -> C2F_VLOPE
			oJObjRet[cTag13AP][nLen13AP]["valueWithoutCredit"]      := aRegT013AP[nI][NAPVLRSCRE] // 16 - VL_SCRED       -> C2F_VLSCRE
			oJObjRet[cTag13AP][nLen13AP]["previousICMSSTvalue"]     := aRegT013AP[nI][TRIBICMSST] // 17 - ICMNDES        -> C2F_ICMNDES

		next nI

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} fiscalDocumentItems
Função responsável por elaborar json do registro T015

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )

@author Denis Naves
@since 19/10/2020

/*/
//-------------------------------------------------------------------
static function fiscalDocumentItems( oTsiNFis, cAlias, oJObjRet, nLen, aRegT015AE, nSomaItem )
 
	Local cCodIss  	 := SFT->FT_CODISS //Caso não encontre registro na CDN, utilizar FT_CODISS
	Local nLen15   	 := 0
	Local nVlItem  	 := 0
	Local cCfop    	 := ""
	Local cTpServ  	 := ""
	Local cDipam   	 := ""
	Local cClasFis	 := ''
	Local cTpRepasse := ""
	Local cIndDTerc  := ""
	Default oTsiNFis := Nil
	Default cAlias   := ""
	Default nLen	 := 1

	cIndDTerc        := ""

	//Quando CFOP estiver com 3 dígitos, converter para o CFOP 5949 (Saídas) ou 1949 (Entradas)
	if Len(AllTrim(SFT->FT_CFOP)) <= 3 .And. !Empty(SFT->FT_TIPOMOV)
		If SFT->FT_TIPOMOV == "S"
			cCfop := '5949'
		Else
			cCfop := '1949'
		EndIf
	else
		cCfop := SFT->FT_CFOP
	endif

	//Se nota complementar, FT_TOTAL
	if alltrim((cAlias)->TIPO_DOC)  $ "02|03|04"
 		nVlItem := SFT->FT_TOTAL
 	else //Para notas normais usar FT_PRCUNIT
 		if Empty(SFT->FT_PRCUNIT)
			nVlItem := SFT->FT_TOTAL
		else
			nVlItem := SFT->FT_PRCUNIT
		endif
	endif

	//Priorizo o tipo de serviço da reinf que esta no cadastro do produto.
	cTpServ := (cAlias)->F2QTPSERV

	if !Empty( (cAlias)->PRODCODLST ) //CDN + FT_CODISS + FT_PRODUTO
		cCodIss := AllTrim((cAlias)->PRODCODLST)
		if empty(cTpServ)
			cTpServ := (cAlias)->PRODTPSERV
		endif
	elseif !Empty( (cAlias)->ISSCODLST ) //CDN + FT_CODISS
		cCodIss := AllTrim((cAlias)->ISSCODLST)
		if empty(cTpServ)
			cTpServ := (cAlias)->ISSTPSERV
		endif
	EndIf
	// Tiro todos os pontos que estiverem no cadastro. Sem pontos (Exemplo: 06.01 deve enviar 0601). 
	cCodIss := alltrim((StrTran(cCodIss,".","")))

	if !Empty(cTpServ); cTpServ := '1' + StrZero(Val(cTpServ),08); endif

	//Se UF do parametro MV_UFCODIPM = UF do MV_ESTADO Buscar na tabela F09 o código IPM gravado no campo F09_CODIPM
	If !Empty( cMVEstado ) .and. (cMVEstado $ cUFIPM )
		cDipam := Alltrim( Posicione( "F09", 1, xFilial( "F09" ) + SFT->FT_TES + cMVEstado, "F09_CODIPM" ) )
	EndIf

	If SFT->FT_TIPOMOV == 'E'
		cTpRepasse := AllTrim(SD1->D1_TPREPAS)
	ElseIf SFT->FT_TIPOMOV == 'S'
		cTpRepasse := Alltrim(SD2->D2_TPREPAS)
	EndIf

	//Verifico indicativo de 13º salário
	If lTableDHR
		If !Empty((cAlias)->NATREN)
			If lTableFKX
				cIndDTerc := Posicione("FKX", 1, xFilial("FKX") + (cAlias)->NATREN, "FKX_DECSAL")
			Else
				cIndDTerc := ''
			EndIf
		Else
			cIndDTerc := ''
		EndIf
	EndIf

	//Formatando a informação de origem do produto.
	if empty(left(SFT->FT_CLASFIS,1))
		cClasFis := '0'
	else
		cClasFis := left(SFT->FT_CLASFIS,1)	
	endif

	aAdd( oJObjRet[cTagJs][nLen][cTagT015], JsonObject( ):New( ) )
	nLen15 := Len( oJObjRet[cTagJs][nLen][cTagT015] )

	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemNumber"]			    := StrZero(nSomaItem,nTmNumIte) 		        //2 NUM_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemCode"]			    := SFT->FT_PRODUTO								//3 COD_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemTotalValue"]		    := SFT->FT_TOTAL								//5 VL_TOT_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["discountValue"]		    := SFT->FT_DESCONT								//6 VL_DESC
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemAmount"]              := SFT->FT_QUANT								//11 QTD
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["unitOfMeasurement"]	    := SB1->B1_UM									//12 UNID
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["cfopIndicator"]		    := cCfop										//13 CFOP
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["operationNature"]	        := SF4->F4_CODIGO								//14 COD_NAT
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["originIdentCode"]		    := cClasFis										//28 ORIGEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["physicalMovement"]		:= iif(alltrim(SF4->F4_MOVFIS) == 'S','0','1')	//29 IND_MOV
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemValue"]		        := nVlItem										//31 VL_ITEM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["serviceCode"]			    := cCodIss										//32 COD_LST
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["accountingValue"]         := SFT->FT_VALCONT								//35 VLR_CONTABIL
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemAdditions"]		    := SFT->(FT_SEGURO+FT_DESPESA+FT_FRETE)			//37 VL_ACRE
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["acessoryExpense"]		    := SFT->FT_DESPESA								//38 VL_DA
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["cityServiceCode"]		    := AllTrim(SFT->FT_CODISS)						//40 COD_SERV_MUN
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["typeOfTransfer"]		    := cTpRepasse									//42 TPREPASSE
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["serviceType"]			    := cTpServ 										//43 TIP_SERV
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["dipamCode"]			    := Iif(cMVEstado=="MG",UPPER(cDipam),cDipam)	//44 COD_DIPAM
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["socialSecurityExemption"] := Iif(lINDISEN,SFT->FT_INDISEN,"")				//45 IND_ISENCAO_PREVID
	oJObjRet[cTagJs][nLen][cTagT015][nLen15]["itemDiscrimination"]      := SB1->B1_DESC  				                //48 DESC_ITEM

	If lTableDHR
		oJObjRet[cTagJs][nLen][cTagT015][nLen15]["natureOfIncome"]          := AllTrim((cAlias)->NATREN)               		//46 NATUREZA_RENDIMENTO
		oJObjRet[cTagJs][nLen][cTagT015][nLen15]["indicator13Salary"]       := cIndDTerc                    				//47 IND_DEC_TERC
	EndIf
	
	valTaxPerItm( @oJObjRet[cTagJs][nLen][cTagT015][nLen15], aRegT015AE )

	if !Empty( (cAlias)->DT6CLIDES ) .Or. !Empty( (cAlias)->DT6CDRORI ) //T015AI - Complemento do documento fiscal - Transportes
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI] := { } //para cada item da nota cria o array no json
		transportComplement( cAlias, oJObjRet, nLen, nLen15 )
	endif

	//T015AK - Indicativo de suspensão para os processos administrativos e judiciais
	if oTsiNFis:lRegCDG .OR. lTableDHR
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] := { } //para cada item da nota cria o array no json
		SuspByJudProcess( cAlias, @oJObjRet, nLen, nLen15, oTsiNFis )
	endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} transportComplement
Função responsável por elaborar json do registro T015AI
Complemento do documento fiscal - Transportes
59.Serviço de Transporte (Mod. 07)

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )
@param  nLen15     -> posicao do item

@author Denis Naves
@since 19/10/2020

/*/
//-------------------------------------------------------------------
Static Function transportComplement( cAlias, oJObjRet, nLen, nLen15 )

	Local nLen15AI	 := 0
	Local cCodEstOrg := ""
	Local cCodMunOrg := ""
	Local cCodMunDes := ""
	Local cCodEstDes := ""

	alGetSA1 := SA1->(GetArea())

	//Para origem ja esta posicionado na SA1 correspondente
	cCodEstOrg := ExtTmsMun( (cAlias)->DT6CDRORI/*, .T., .T. */)  //TMSCodMun -> Livros Fiscais/SPEDXFUN.PRW

	If Len(cCodEstOrg) > 5
		If Upper( SubStr( cCodEstOrg, 1, 2 ) ) != "EX"
			cCodMunOrg := SubStr(cCodEstOrg,3,5)
		Else
			cCodMunOrg := "9999999"
		EndIf
		cCodEstOrg := SubStr(cCodEstOrg,1,2)
	EndIf

	//Necessario reposicionar para o destino pois TMSCodMun trabalha com cursores da SA1
	If SA1->(MsSeek(xFilial("SA1")+(cAlias)->(DT6CLIDES+DT6LOJDES) )) 
		cCodEstDes := ExtTmsMun( (cAlias)->DT6CDRCAL/*, .T., .T. */)
		If Len( cCodEstDes ) > 5
			If Upper( SubStr( cCodEstDes, 1, 2 ) ) != "EX"
				cCodMunDes := SubStr( cCodEstDes, 3, 5 )
			Else
				cCodMunDes := "9999999"
			EndIf
			cCodEstDes := SubStr( cCodEstDes, 1, 2 )
		EndIf
	EndIf

	aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI], JsonObject( ):New( ) )
	nLen15AI := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI] )

	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["originFUCode"]	  := cCodEstOrg //2 UF_MUN_ORIG
	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["originCityCode"]  := cCodMunOrg //3 COD_MUN_ORIG
	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["destinyFUCode"]	  := cCodEstDes //4 UF_MUN_DEST
	oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AI][nLen15AI]["destinyCityCode"] := cCodMunDes //5 COD_MUN_DEST

	RestArea(alGetSA1)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} compInfoByTax
Função responsável por elaborar json do registro T013AA
Informações complementares de documentos fiscais

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )

MV_SPDIFC - Impressao do campo TXT_COMPL do Reg. C110
0 = CCE_DESCR
1 ou 3 = CDT_DCCOMP Se campo existir e não vazio
      	            Senão CDC_DCCOMP
2 = Se Entrada F1_MENNOTA
    Se Saída   F2_MENNOTA

@author Rafael de Paula Leme
@since 21/10/2021

/*/
//-------------------------------------------------------------------
Static Function compInfoByTax( cAlias, oJObjRet, nLen )

	Local nLen13AA  As numeric
	Local nSPDIFC   As numeric
	Local cSelect	As character
	Local cFrom		As character
	Local cWhere	As character
	Local cAliasCDT As character
	Local cTxtCompl As character
	
	cAliasCDT := getNextAlias()       
	nSPDIFC   := GetMV( "MV_SPDIFC" )
	nLen13AA  := 0
	cTxtCompl := ''

	DbSelectArea( "CDT" )
	 
	cSelect := "% CDT.CDT_IFCOMP IFCOMP"

	//Protejo o fonte pois o campo CDT_DCCOMP pode não existir na base do cliente.
	if FieldPos("CDT_DCCOMP") > 0
		cSelect += ", CDT.CDT_DCCOMP DCCOMP"
	endif

	cSelect += " %"

	cFrom := "% " + RetSqlName("CDT") + " CDT" + " %" //Informações complementares de documentos fiscais

	cWhere  := "% CDT.CDT_FILIAL = '"    + (cAlias)->FILIAL + "' "  // SFT.FT_FILIAL
	cWhere  += " AND CDT.CDT_TPMOV = '"  + (cAlias)->TIPOMOV + "' " // SFT.FT_TIPOMOV
	cWhere  += " AND CDT.CDT_DOC = '"    + (cAlias)->NFISCAL + "' "	// SFT.FT_NFISCAL
	cWhere  += " AND CDT.CDT_SERIE = '"  + (cAlias)->SERIE +   "' "	// SFT.FT_SERIE
	cWhere  += " AND CDT.CDT_CLIFOR = '" + (cAlias)->CLIEFOR + "' " // SFT.FT_CLIEFOR
	cWhere  += " AND CDT.CDT_LOJA = '"   + (cAlias)->LOJA +    "' "	// SFT.FT_LOJA
	cWhere  += " AND CDT.D_E_L_E_T_ = ' ' %"

	BeginSql Alias cAliasCDT
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE %Exp:cWhere%
	EndSql

	While (cAliasCDT)->(!EOF())

		aAdd( oJObjRet[cTagJs][nLen][cTag013AA], JsonObject( ):New( ) ) 
		nLen13AA := Len( oJObjRet[cTagJs][nLen][cTag013AA] )
		
		// Abaixo repito o envio do campo CDT_IFCOMP pois o mesmo deve preencher dois campos na tabela de destino C21.
		// Por se tratar de um controle interno, não visível ao cliente, foi decidido fazer dessa forma, ao invés de tratar isso no fonte WSTAF034.
		// Para as APIs PUT e POST do layout T013 não será necessário informar as duas tags com o mesmo valor.
		oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoCode"] := (cAliasCDT)->IFCOMP // CDT_IFCOMP -> C21_CODINF
		oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["auxiliaryCode"]         := (cAliasCDT)->IFCOMP  // CDT_IFCOMP -> C21_CDINFO

		cTxtCompl := Alltrim(Posicione("CCE", 1, xFilial("CCE") + (cAliasCDT)->IFCOMP, "CCE_DESCR"))	

		if nSPDIFC == 0
			oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := cTxtCompl // CCE_DESCR -> C21_DESCRI
		elseif nSPDIFC == 1 .or. nSPDIFC == 3
			if FieldPos("CDT_DCCOMP") > 0 .and. !empty((cAliasCDT)->DCCOMP)
				oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := Alltrim((cAliasCDT)->DCCOMP) // CDT_DCCOMP -> C21_DESCRI
			elseif lTableCDC
				oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := Alltrim(Posicione("CDC", 1, xFilial("CDC") + (cAlias)->TIPOMOV + (cAlias)->NFISCAL + (cAlias)->SERIE + (cAlias)->CLIEFOR + (cAlias)->LOJA, "CDC_DCCOMP")) // CDC_DCCOMP -> C21_DESCRI	
			else
				oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := ' '
			endif
		elseif nSPDIFC == 2
			oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := Alltrim((cAlias)->MENNOTA) // _MENNOTA -> C21_DESCRI
		else
			oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoText"] := ' '
		endif

		oJObjRet[cTagJs][nLen][cTag013AA][nLen13AA]["complementaryInfoDesc"] := cTxtCompl // CCE_DESCRI -> C21_DCODIN
			
		(cAliasCDT)->(DbSkip())

	EndDo
	
	( cAliasCDT )->( DBCloseArea( ) )

	( "CDT" )->( DBCloseArea() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SuspByJudProcess
Função responsável por elaborar json do registro T015AK

Mod 09 SIGAFIS Complemento do documento fiscal - Processos Referenciados
Mod 84 SIGATAF 60.Indicativo de Suspensao Processos Administrativos e Judiciais

@param  cAlias     -> Alias da query corrente
@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais 
@param  nLen       -> indice atual do objeto json ( oJObjRet )
@param  nLen15     -> posicao do item

@author Denis Naves
@since 21/10/2021

/*/
//-------------------------------------------------------------------
Static Function SuspByJudProcess( cAlias, oJObjRet, nLen, nLen15, oTsiNFis )

Local nLen15AK   As numeric
Local cAliasQry  As char
Local cSelect	 As char
Local cFrom		 As char
Local cInJoin	 As char
Local cWhere	 As char
Local cCodTrib	 As char
Local cVersao    As char
Local cCalcIr    As char

Default cAlias 	 := ''
Default oJObjRet := Nil
Default nLen 	 := 0
Default nLen15 	 := 0
Default oTsiNFis := Nil

nLen15AK  := 0
cAliasQry := ''
cCalcIr   := ''
cCodTrib  := ''

If oTsiNFis:lRegCDG .AND. !Empty( (cAlias)->CDGSTAMP )

	cAliasQry := GetNextAlias()

	cSelect := "% CCF.CCF_TIPO, CCF.CCF_NUMERO, CCF.CCF_INDSUS, CCF.CCF_TRIB, CDG.CDG_VALOR %"
	cFrom   := "% " + RetSqlName("CDG") + " CDG" + " %" //Processos refer. no documento

	cInJoin := "% " + RetSqlName("CCF") + " CCF ON " //Processos referenciados
	cInJoin += " CCF.CCF_FILIAL = CDG.CDG_FILIAL AND CCF.CCF_NUMERO = CDG.CDG_PROCES AND CCF.CCF_TIPO = CDG.CDG_TPPROC "
	cInJoin += " AND CCF.CCF_IDITEM = CDG.CDG_ITPROC AND CCF.D_E_L_E_T_= ' ' %"

	//Sempre sera refeito o processo por completo, porem aqui deve ser por cada item da nota.
	cWhere := "%"
	cWhere += " CDG.CDG_FILIAL = '" + (cAlias)->FILIAL + "' "		 // SFT.FT_FILIAL
	cWhere += " AND CDG.CDG_TPMOV = '" + (cAlias)->TIPOMOV + "' " 	 // SFT.FT_TIPOMOV
	cWhere += " AND CDG.CDG_DOC = '" + (cAlias)->NFISCAL + "' "		 // SFT.FT_NFISCAL
	cWhere += " AND CDG.CDG_SERIE = '" + (cAlias)->SERIE + "' "		 // SFT.FT_SERIE
	cWhere += " AND CDG.CDG_CLIFOR = '" + (cAlias)->CLIEFOR + "' "	 // SFT.FT_CLIEFOR
	cWhere += " AND CDG.CDG_LOJA = '" + (cAlias)->LOJA + "' "		 // SFT.FT_LOJA
	cWhere += " AND CDG.CDG_ITEM = '" + (cAlias)->ITEM + "' "		 // SFT.FT_ITEM
	cWhere += " AND CDG.D_E_L_E_T_ = ' ' "
	cWhere += "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		INNER JOIN %Exp:cInJoin%
		WHERE %Exp:cWhere%
		ORDER BY CCF.CCF_TIPO, CCF.CCF_NUMERO, CCF.CCF_INDSUS
	EndSql

	While (cAliasQry)->( !Eof() )
		//DE x PARA (C3S TAF)
		If (cAliasQry)->CCF_TRIB $ "1|2" 	//1=Contribuição previdenciária (INSS) ou 2=Contribuição previdenciária especial (INSS)
			cCodTrib := "13" 	 	//PREVIDENCIA
		ElseIf (cAliasQry)->CCF_TRIB == "3" //3=FUNRURAL
			cCodTrib := "24"		//GILRAT (GRAU DE INCIDÊNCIA DE INCAPACIDADE LABORATIVA DECORRENTE DOS RISCOS AMBIENTAIS DO TRABALHO)
		ElseIf (cAliasQry)->CCF_TRIB == "4" //4=SENAR
			cCodTrib := "25"		//SENAR
		ElseIf (cAliasQry)->CCF_TRIB == "5" //5=CPRB
			cCodTrib := "23"		//CPRB (IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA)
		ElseIf (cAliasQry)->CCF_TRIB == "6" //6=ICMS
			cCodTrib := "02"		//ICMS (IMPOSTO SOBRE A CIRCULACAO DE MERCADORIAS E SERVICOS)
		ElseIf (cAliasQry)->CCF_TRIB == "7" //7=PIS
			cCodTrib := "06"		//PIS/PASEP (PROGRAMA DE INTEGRACAO SOCIAL - PROGRAMA DE FORMACAO DO PATRIMONIO DO SERVIDOR PUBLICO)
		ElseIf (cAliasQry)->CCF_TRIB == "8" //8=COFINS
			cCodTrib := "07"		//COFINS (CONTRIBUICAO PARA O FINANCIAMENTO DA SEGURIDADE SOCIAL)
		ElseIf (cAliasQry)->CCF_TRIB == "9" //9=IR
			cCodTrib := "12"		//12 IR (IMPOSTO DE RENDA EMISSÃO)
		ElseIf (cAliasQry)->CCF_TRIB == "A" //A=CSLL
			cCodTrib := "18"		//CSLL (CONTRIBUICAO SOCIAL SOBRE O LUCRO LIQUIDO)
		EndIf

		aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
		nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

		//typeOfProcess -> T9Q_TPPROC (Pertence(" 12") ) 1=Processo sobre a contribuição previdenciária principal;2=Processo sobre a contribuição previdenciária adicional
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess" ]          := iif((cAliasQry)->CCF_TRIB $ "1|2",(cAliasQry)->CCF_TRIB,' ') //02 TP_PROC
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber" ]          := (cAliasQry)->CCF_NUMERO                                      //03 NUM_PROC
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->CCF_INDSUS                                      //05 COD_SUS
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->CDG_VALOR 						                                      //06 VAL_SUS
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib				                                      //07 COD_TRIB
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := 0                                                            //08 BASE_SUSPENSA
		//Vide extrator fiscal, manter zerado por enquanto. Sera alimentado com a DHR (implementado pelo SIGACOM para o REINF 2.0)
		cVersao := GetVerProc("C1G", (PadR((cAliasQry)->CCF_TIPO,nTmIndPro)+PadR((cAliasQry)->CCF_NUMERO,nTmNmPro) ), 4 )                                         //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
		oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"] := PadR( cVersao, nTmVers )

		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->( DBCloseArea() )

EndIf

If lTableDHR .AND. (cAlias)->TIPOMOV == 'E'

	cAliasQry := GetNextAlias()

	cSelect := "% DHR.DHR_PSIR, DHR.DHR_ISIR, DHR.DHR_TSIR, DHR.DHR_PSPIS, DHR.DHR_ISPIS, DHR.DHR_TSPIS, DHR.DHR_PSCOF, DHR.DHR_ISCOF, DHR.DHR_TSCOF, DHR.DHR_PSCSL, DHR.DHR_ISCSL, DHR.DHR_TSCSL, DHR.DHR_BASEIR, "
	cSelect += " DHR.DHR_VLRIR, DHR.DHR_BASUIR, DHR.DHR_VLRSIR, DHR.DHR_BANFIR, DHR.DHR_VLNFIR, DHR.DHR_BASPIS, DHR.DHR_VLRPIS, DHR.DHR_BSUPIS, DHR.DHR_VLSPIS, DHR.DHR_BNFPIS, DHR.DHR_VNFPIS, DHR.DHR_BASCOF, "
	cSelect += " DHR.DHR_VLRCOF, DHR.DHR_BSUCOF, DHR.DHR_VLSCOF, DHR.DHR_BNFCOF, DHR.DHR_VNFCOF, DHR.DHR_BASCSL, DHR.DHR_VLRCSL, DHR.DHR_BSUCSL, DHR.DHR_VLSCSL, DHR.DHR_BNFCSL, DHR.DHR_VNFCSL %"

	cFrom   := "% " + RetSqlName("DHR") + " DHR" + " %"

	cWhere := "% DHR.DHR_FILIAL =    '" + (cAlias)->FILIAL  + "' "
	cWhere += " AND DHR.DHR_DOC =    '" + (cAlias)->NFISCAL + "' "
	cWhere += " AND DHR.DHR_SERIE =  '" + (cAlias)->SERIE   + "' "	
	cWhere += " AND DHR.DHR_FORNEC = '" + (cAlias)->CLIEFOR + "' "
	cWhere += " AND DHR.DHR_LOJA =   '" + (cAlias)->LOJA    + "' "	
	cWhere += " AND DHR.DHR_ITEM =   '" + (cAlias)->ITEM    + "' "
	cWhere += " AND DHR.D_E_L_E_T_ = ' ' %"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE %Exp:cWhere%
	EndSql

	While (cAliasQry)->( !Eof() )

		//IR
		If  (cAliasQry)->(DHR_BASUIR+DHR_VLRSIR) > 0
			
			cCalcIr := SA2->A2_CALCIRF
			
			If cCalcIr <> '2'
				cCodTrib := '12'
			ElseIf cCalcIr == '2'
				cCodTrib := '28'
			EndIf

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSIR   //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISIR   //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLRSIR //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BASUIR //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSIR,nTmIndPro)+PadR((cAliasQry)->DHR_PSIR,nTmNmPro) ), 4 )      //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		Endif

		//PIS
		If (cAliasQry)->(DHR_BSUPIS+DHR_VLSPIS) > 0

			cCodTrib := '10'

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSPIS  //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISPIS  //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLSPIS //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BSUPIS //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSPIS,nTmIndPro)+PadR((cAliasQry)->DHR_PSPIS,nTmNmPro) ), 4 )    //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		EndIf

		//COFINS
		IF (cAliasQry)->(DHR_BSUCOF+DHR_VLSCOF) > 0
			
			cCodTrib := '11'

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSCOF  //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISCOF  //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLSCOF //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BSUCOF //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSCOF,nTmIndPro)+PadR((cAliasQry)->DHR_PSCOF,nTmNmPro) ), 4 )    //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		EndIf
		
		//CSLL
		IF (cAliasQry)->(DHR_BSUCSL+DHR_BSUCSL) > 0
			
			cCodTrib := '18'

			aAdd( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK], JsonObject( ):New( ) )
			nLen15AK := Len( oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK] )

			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["typeOfProcess"]           := ''                      //02 TP_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["processNumber"]           := (cAliasQry)->DHR_PSCSL  //03 NUM_PROC
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["suspensionCode"]          := (cAliasQry)->DHR_ISCSL  //05 COD_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["retentionValue"]          := (cAliasQry)->DHR_VLSCSL //06 VAL_SUS
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["tributeCode"   ]          := cCodTrib                //07 COD_TRIB
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["baseValueOfSuspendedTax"] := (cAliasQry)->DHR_BSUCSL //08 BASE_SUSPENSA
			cVersao := GetVerProc("C1G", (PadR((cAliasQry)->DHR_TSCSL,nTmIndPro)+PadR((cAliasQry)->DHR_PSCSL,nTmNmPro) ), 4 )    //C1G_FILIAL, C1G_INDPRO, C1G_NUMPRO
			oJObjRet[cTagJs][nLen][cTagT015][nLen15][cTagT015AK][nLen15AK]["versionSuspensionCode"]   := PadR( cVersao, nTmVers )

		EndIf

		(cAliasQry)->( DbSkip() )

	EndDo

	(cAliasQry)->( DBCloseArea() )
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} valTaxPerItm
Função responsável por elaborar json do registro T015AE - Cadastro de tributos por item de documento

@param  oJObjRet   -> Objeto que será utilizado para gerar o json de extração das notas fiscais
@param  aRegT013AP -> array com as inforrmações e valores de tributos da nota fiscal

@author Wesley Pinheiro
@since 14/10/2020

/*/
//-------------------------------------------------------------------
static function valTaxPerItm( oJObjRet, aRegT015AE )

	Local nI       := 0
	Local nLen15AE := 0
	Local nTam15AE := Len( aRegT015AE )

	If nTam15AE > 0

		oJObjRet[cTag15AE] := { }

		for nI:= 1 to nTam15AE

			aAdd( oJObjRet[cTag15AE], JsonObject( ):New( ) )
			nLen15AE := Len( oJObjRet[cTag15AE] )

			oJObjRet[cTag15AE][nLen15AE]["taxCode"]                         := aRegT015AE[nI][2][1][NAECODTRIB] // 02 - COD_TRIB    -> C35_CODTRI  
			oJObjRet[cTag15AE][nLen15AE]["cst"]                             := aRegT015AE[nI][2][1][NAECST]     // 03 - CST         -> C35_CST
			oJObjRet[cTag15AE][nLen15AE]["mva"]                             := aRegT015AE[nI][2][1][NAEMVA]     // 05 - MVA         -> C35_MVA
			oJObjRet[cTag15AE][nLen15AE]["calculationBase"]	                := aRegT015AE[nI][2][1][NAEBS]      // 07 - BASE        -> C35_BASE
			oJObjRet[cTag15AE][nLen15AE]["calculationBaseNotTaxed"]         := aRegT015AE[nI][2][1][NAEBSNT]    // 09 - BASE_NT     -> C35_BASENT
			oJObjRet[cTag15AE][nLen15AE]["taxRate"]                         := aRegT015AE[nI][2][1][NAEALIQ]    // 10 - ALIQUOTA    -> C35_ALIQ
			oJObjRet[cTag15AE][nLen15AE]["taxValue"]                        := aRegT015AE[nI][2][1][NAEVLR]     // 12 - VALOR       -> C35_VALOR
			oJObjRet[cTag15AE][nLen15AE]["exemptValue"]                     := aRegT015AE[nI][2][1][NAEVLRISEN] // 15 - VLR_ISENTO  -> C35_VLISEN
			oJObjRet[cTag15AE][nLen15AE]["otherValue"]                      := aRegT015AE[nI][2][1][NAEVLROUTR] // 16 - VLR_OUTROS  -> C35_VLOUTR
			oJObjRet[cTag15AE][nLen15AE]["nonTaxedValue"]                   := aRegT015AE[nI][2][1][NAEVLRNT]   // 17 - VALOR_NT    -> C35_VLNT
			oJObjRet[cTag15AE][nLen15AE]["valueWithoutCredit"]              := aRegT015AE[nI][2][1][NAEVLRSCRE] // 22 - VL_SCRED    -> C35_VLSCRE
			oJObjRet[cTag15AE][nLen15AE]["subContractServiceValue"]         := aRegT015AE[nI][2][1][NAEVLCONTR] // 24 - VLSCONTR    -> C35_VLSCON	
			oJObjRet[cTag15AE][nLen15AE]["addRetentionAmount"]              := aRegT015AE[nI][2][1][NAEVLRADIC] // 25 - VLRADIC     -> C35_VLRADI
			oJObjRet[cTag15AE][nLen15AE]["UnpaidRetentionAmount"]           := aRegT015AE[nI][2][1][NAEVLRNPAG] // 26 - VLRNPAG     -> C35_VLRNPG
			oJObjRet[cTag15AE][nLen15AE]["serviceValueSpecialCondition15A"] := aRegT015AE[nI][2][1][NAEVLRCE15] // 27 - VLRCE15     -> C35_VLCE15
			oJObjRet[cTag15AE][nLen15AE]["serviceValueSpecialCondition20A"] := aRegT015AE[nI][2][1][NAEVLRCE20] // 28 - VLRCE20     -> C35_VLCE20
			oJObjRet[cTag15AE][nLen15AE]["serviceValueSpecialCondition25A"] := aRegT015AE[nI][2][1][NAEVLRCE25] // 29 - VLRCE25     -> C35_VLCE25
			oJObjRet[cTag15AE][nLen15AE]["addUnpaidRetentionAmount"]        := aRegT015AE[nI][2][1][NAEVRDICPG] // 30 - VLRADICNPAG -> C35_VLRANP

		next nI

	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} toNumeric
Transforma  possíveis caracteres em numérico

@author Henrique Pereira
@since 12/111/2020

/*/
//-------------------------------------------------------------------
static function toNumeric(xConteud) 
Local nRet as numeric
nRet	:=	0 

Default xConteud := ''

	if ValType( xConteud ) == "C" 
		nRet :=	val(xConteud)
	else
		nRet := xConteud
	endif

return nRet


//-----------------------------------------------------------------------------
/*/{Protheus.doc} IndFrete()
Função responsável por tratar das informações do frete do documento fiscal

@author Carlos Eduardo (Boy)
@since 
/*///--------------------------------------------------------------------------
Static Function IndFrete(cAlias,cIndFrt,cCodSit,cOpcCanc,cEspecie)
Local lRet 		:= .t.

Local cCpoFrete := iif( (cAlias)->TIPOMOV == 'E', 'F1_FRETE','F2_FRETE')
Local cFrete 	:= ''

Default cEspecie := ""

// Adaptando o código de frete de acordo com o layout do extrator fiscal
cFrete := (cAlias)->CDT_INDFRT
cCpoSimpN := iif((cAlias)->FOR_CLI == 'SA1','SA1->A1_SIMPNAC','SA2->A2_SIMPNAC')
cCodSit := SPEDSitDoc(,'SFT',(cAlias)->FOR_CLI,cCpoSimpN,,,(cMVEstado $ cUFRESpd),.F.,,,'SF4')

if lIntTMS .And. cValToChar((cAlias)->RECDT6) != "0" .And.(cAlias)->TIPOMOV == "S" .And. cEspecie $ "|07|08|09|10|11|26|27|57"
	If !empty(cOpSemF) .And. alltrim((cAlias)->FT_CFOP) $ cOpSemF
		cFrete := "9"
	ElseIf (cAlias)->DT6_DEVFRE $ "1"
		cFrete := '0'	// Por conta do emitente = CIf = 1
	ElseIf (cAlias)->DT6_DEVFRE $ "2"
		cFrete := '1' 	// Por conta do destinatario = FOB = 2
	Else
		cFrete := '2'	// Apesar do sistema gravar 2=FOB, o devedor do frete pode ser o consignatario, espachante ou outros.
	EndIf		
else
	If empty(cFrete)
		If !empty(cOpSemF) .And. alltrim(SFT->FT_CFOP) $ cOpSemF
			cFrete := "9"
		Else
			// Utilizo a informacao configurada nos pedidos de venda/campra
			cFrete := SPEDSitFrt("SFT",IIf((cAlias)->TIPOMOV == "S","SD2","SD1"),.T.,IIf((cAlias)->TIPOMOV == "S","SF2","SF1"),cCpoFrete,,.F.,)		
		EndIf
	EndIf

	If cValToChar((cAlias)->RECCDT) != "0"
		If Alltrim(cFrete) == "1"	// 0 - Por conta do emitente
			cFrete := "0"
		ElseIf Alltrim(cFrete)=="2"	// 1 - Por conta do destinatário/remetente
			cFrete := "1" 
		ElseIf Alltrim(cFrete)=="0"	// 2 - Por conta de terceiros
			cFrete := "2"
		EndIf
	EndIf
endif	
	
// Adaptando o código de frete de acordo com o layout do extrator fiscal
If cCodSit $ "02#03"
	cIndFrt := ""
ElseIf AllTrim(cFrete) == "0"
	cIndFrt := "1"
ElseIf AllTrim(cFrete) == "1"
	cIndFrt := "2"
ElseIf AllTrim(cFrete) == "2"
	cIndFrt := "0"
Else
	cIndFrt := cFrete
EndIf	

//Regra de Exclusão ou Cancelamento de Nota no Protheus
if cCodSit == '02' 
	cOpcCanc := '4'  //alteracao da situação da nota
elseif Upper( Alltrim( (cAlias)->(OBSERV) ) ) == 'NF EXCLUIDA'
	cCodSit := '02'
	cOpcCanc := '5'  //excluido
else
	cOpcCanc := '' 
endif

//Caso nao exista conteudo eh necessario enviar um default pois eh um campo obrigatorio para integração do documento no TAF.
if Empty(cIndFrt)
	cIndFrt := "9" //sem ocorrencia de transporte
endif

return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} IndPagto()
Função responsável por tratar das informações do pagamento  do cdocumento fiscal

@author Carlos Eduardo (Boy)
@since 14/10/2020
/*///--------------------------------------------------------------------------
Static Function IndPagto()
Local cRet := ''
Local aCmpSFT := array(28)
Local aParcTit := {}

//Para utilizar a funcao Padrao do Protheus SpedProSE2/SE1 deve-se passar o Array aCmpSFT na estrutura conforme foi montada
aCmpSFT[01] := SFT->FT_NFISCAL
aCmpSFT[02] := SFT->FT_SERIE	
aCmpSFT[03] := SFT->FT_CLIEFOR
aCmpSFT[04] := SFT->FT_LOJA	
//aCmpSFT[27] ---> Prefixo, podendo vir da SF1 ou SF2 
//aCmpSFT[28] ---> Duplicata, podendo vir da SF1 ou SF2

//Busca a Quantidade de Parcelas da NF
If SFT->FT_TIPOMOV == 'E'
	aCmpSFT[27] := SF1->F1_PREFIXO
	aCmpSFT[28]	:= SF1->F1_DUPL
	aParcTit := SpedProSE2(aCmpSFT,.t.)
Else
	aCmpSFT[27] := SF2->F2_PREFIXO
	aCmpSFT[28] := SF2->F2_DUPL
	aParcTit :=	SpedProSE1(aCmpSFT,.t.)					
EndIf

// Tratamento para gerar a condicao de pagamento da NF
If empty(aParcTit)
	cRet := '2'		//Sem Pagamento
ElseIf Len( aParcTit) == 1 .And. SFT->FT_EMISSAO == aParcTit[1][7]
	cRet := '0'		//A Vista
Else
	cRet := '1'		//A Prazo
EndIf

return cRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} DestroyObj()
Função responsável por destruir os objetos

@author José Felipe|Karen Honda
@since 05/07/2021
/*///--------------------------------------------------------------------------
Static Function DestroyObj()

	If __oStatCDA <> Nil
		__oStatCDA:Destroy()
		__oStatCDA := Nil
	Endif

	If __oStatSai <> Nil
		__oStatSai:Destroy()
		__oStatSai := Nil
	Endif

	If __oStatEnt <> Nil
		__oStatEnt:Destroy()
		__oStatEnt := Nil
	Endif

	If __oStatCDT <> Nil
		__oStatCDT:Destroy()
		__oStatCDT := Nil
	Endif

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetDUY()
Busca a chave FILIAL + DUY_GRPVEN na tabela DUY e retorna a DUY_EST 
e armazena no hash para posterior consulta sem necessidade de fazer dbseek
@author Karen Honda
@since 19/08/2022
/*/ 
//-----------------------------------------------------------------------
Static Function GetDUY( cChave, cGetDUY )
Local   lRet := .F.
Default cChave := ''
Default cGetDUY := ''

if ValType(oHashDUY) == "O"
    HMGet( oHashDUY, cChave, @cGetDUY )
    if Empty(cGetDUY)
		If Select("DUY") == 0
			DbSelectArea("DUY")
			DBSetOrder(1)
		EndIf

		If DUY->( DBSeek(cChave) )
        	cGetDUY := DUY->DUY_EST
        	SetHashKey(oHashDUY, cChave, cGetDUY) 
			lRet := .T.	
		EndIf
	else
		lRet := .T.		
    Endif
endif

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ChkTableJoin()
Verifica se a tabela possui registro com stamp superior para utilizar no join

@author Denis Souza
@since 29/07/2024
/*/
//-----------------------------------------------------------------------
Method ChkTableJoin(cTb) Class TSINFISCAL

Local cAliasQTD := ''
Local cQuery 	:= ''
Local lFindReg  := .F.
Local cConv 	:= ''

Default cTb   	:= '' 

//Converte o conteúdo do campo conforme o banco de dados usado.
if self:cDbType $ 'MSSQL/MSSQL7'
	cConv := 'CONVERT(VARCHAR(23), ' + cTb + '.S_T_A_M_P_, 21) '
elseif self:cDbType $ 'ORACLE'
	cConv := cTb + '.S_T_A_M_P_'
elseif self:cDbType $ "POSTGRES"
	cConv := 'cast('+ cTb + '.S_T_A_M_P_ AS character(23)) ' //default "POSTGRES"
endif

cQuery := "SELECT COUNT(*) QTD FROM " + RetSqlName(cTb) + " " + cTb + " WHERE "

if "ORACLE" $ self:cDbType
	cQuery += cConv + " > TO_TIMESTAMP('" + strtran(self:cRefStamp, ",", "." ) + "','dd.mm.yyyy hh24:mi:ss.ff') "
else
	cQuery += cConv + " > '" + self:cRefStamp + "' "
Endif
cQuery += "AND " + cTb + "." + cTb + "_FILIAL = '" + xFilial(cTb) + "' "
cQuery += "AND " + cTb + ".D_E_L_E_T_ = ' ' "

cAliasQTD := MPSysOpenQuery( cQuery )
(cAliasQTD)->(DbGoTop())
If (cAliasQTD)->(!Eof()) .And. (cAliasQTD)->QTD > 0
	lFindReg := .T.
EndIf
(cAliasQTD)->(DbCloseArea())

Return lFindReg

//-----------------------------------------------------------------------
/*/{Protheus.doc} UseTmpF3FT()
Montagem da temporaria para filtrar a FT/F3 para posteriormente fazer join
com as demais tabelas.

@author Denis Souza
@since 29/07/2024
/*/
//-----------------------------------------------------------------------
Method UseTmpF3FT(cConvSF3,cConvSFT,cUltStmp,cMaxStamp)  Class TSINFISCAL

local cInto     := ''
local cFields   := ''
local cCount    := ''
local cInsert   := ''
local cAliasQTD := ''
local aStru     := {}
local aBind		:= {}
local cTmp 	    := GetNextAlias()
local cMaxCDG   := ""
local cMaxCDT   := ""
Local cReinxGis := SuperGetMv( "MV_TAFRXG", .F., "" )
local oPrepare	as object
local oPrepare2	as object

default cConvSF3   := ''
default cConvSFT   := ''
default cUltStmp   := ''
default cMaxStamp  := ''

//Campos de relacionamento e filtros
aadd(aStru,{'FT_FILIAL' , GetSx3Cache('FT_FILIAL' ,'X3_TIPO'), GetSx3Cache('FT_FILIAL' ,'X3_TAMANHO'), GetSx3Cache('FT_FILIAL' ,'X3_DECIMAL')})
aadd(aStru,{'FT_TIPOMOV', GetSx3Cache('FT_TIPOMOV','X3_TIPO'), GetSx3Cache('FT_TIPOMOV','X3_TAMANHO'), GetSx3Cache('FT_TIPOMOV','X3_DECIMAL')})
aadd(aStru,{'FT_SERIE'	, GetSx3Cache('FT_SERIE'  ,'X3_TIPO'), GetSx3Cache('FT_SERIE'  ,'X3_TAMANHO'), GetSx3Cache('FT_SERIE'  ,'X3_DECIMAL')})
aadd(aStru,{'FT_NFISCAL', GetSx3Cache('FT_NFISCAL','X3_TIPO'), GetSx3Cache('FT_NFISCAL','X3_TAMANHO'), GetSx3Cache('FT_NFISCAL','X3_DECIMAL')})
aadd(aStru,{'FT_CLIEFOR', GetSx3Cache('FT_CLIEFOR','X3_TIPO'), GetSx3Cache('FT_CLIEFOR','X3_TAMANHO'), GetSx3Cache('FT_CLIEFOR','X3_DECIMAL')})
aadd(aStru,{'FT_LOJA'	, GetSx3Cache('FT_LOJA'   ,'X3_TIPO'), GetSx3Cache('FT_LOJA'   ,'X3_TAMANHO'), GetSx3Cache('FT_LOJA'   ,'X3_DECIMAL')})
aadd(aStru,{'FT_ITEM'	, GetSx3Cache('FT_ITEM'	  ,'X3_TIPO'), GetSx3Cache('FT_ITEM'   ,'X3_TAMANHO'), GetSx3Cache('FT_ITEM'   ,'X3_DECIMAL')})
aadd(aStru,{'FT_PRODUTO', GetSx3Cache('FT_PRODUTO','X3_TIPO'), GetSx3Cache('FT_PRODUTO','X3_TAMANHO'), GetSx3Cache('FT_PRODUTO','X3_DECIMAL')})
aadd(aStru,{'FT_ESPECIE', GetSx3Cache('FT_ESPECIE','X3_TIPO'), GetSx3Cache('FT_ESPECIE','X3_TAMANHO'), GetSx3Cache('FT_ESPECIE','X3_DECIMAL')})
aadd(aStru,{'FT_EMISSAO', GetSx3Cache('FT_EMISSAO','X3_TIPO'), GetSx3Cache('FT_EMISSAO','X3_TAMANHO'), GetSx3Cache('FT_EMISSAO','X3_DECIMAL')})
aadd(aStru,{'FT_ENTRADA', GetSx3Cache('FT_ENTRADA','X3_TIPO'), GetSx3Cache('FT_ENTRADA','X3_TAMANHO'), GetSx3Cache('FT_ENTRADA','X3_DECIMAL')})
aadd(aStru,{'SFTSTAMP'	, 'C', 23, 0 }) //oracle {22/07/24 21:58:22,666000000} {22.07.2024 21:58:22.666}
aadd(aStru,{'FT_TIPO'	, GetSx3Cache('FT_TIPO'	  ,'X3_TIPO'), GetSx3Cache('FT_TIPO'   ,'X3_TAMANHO'), GetSx3Cache('FT_TIPO'   ,'X3_DECIMAL')})
aadd(aStru,{'FT_TES'	, GetSx3Cache('FT_TES'	  ,'X3_TIPO'), GetSx3Cache('FT_TES'    ,'X3_TAMANHO'), GetSx3Cache('FT_TES'    ,'X3_DECIMAL')})
aadd(aStru,{'FT_CODISS'	, GetSx3Cache('FT_CODISS' ,'X3_TIPO'), GetSx3Cache('FT_CODISS' ,'X3_TAMANHO'), GetSx3Cache('FT_CODISS' ,'X3_DECIMAL')})
aadd(aStru,{'SFTDELETE' , 'C', 1, 0 }) //nao foi possivel utilizar D_E_L_E_T_ pois ja eh criado automaticamente junto com o R_E_C_N_O_ e R_E_C_D_E_L
aadd(aStru,{'FT_FORMUL'	, GetSx3Cache('FT_FORMUL' ,'X3_TIPO'), GetSx3Cache('FT_FORMUL' ,'X3_TAMANHO'), GetSx3Cache('FT_FORMUL' ,'X3_DECIMAL')})
aadd(aStru,{'SFTRECNO'  , 'N', 15, 0 }) //nao foi possivel utilizar R_E_C_N_O_ pois ja eh criado automaticamente junto com o D_E_L_E_T_ e R_E_C_D_E_L
aadd(aStru,{'FT_IDTRIB'	, GetSx3Cache('FT_IDTRIB' ,'X3_TIPO'), GetSx3Cache('FT_IDTRIB' ,'X3_TAMANHO'), GetSx3Cache('FT_IDTRIB' ,'X3_DECIMAL')})
aadd(aStru,{'FT_NFELETR', GetSx3Cache('FT_NFELETR','X3_TIPO'), GetSx3Cache('FT_NFELETR','X3_TAMANHO'), GetSx3Cache('FT_NFELETR','X3_DECIMAL')})
aadd(aStru,{'FT_CHVNFE' , GetSx3Cache('FT_CHVNFE' ,'X3_TIPO'), GetSx3Cache('FT_CHVNFE' ,'X3_TAMANHO'), GetSx3Cache('FT_CHVNFE' ,'X3_DECIMAL')})
aadd(aStru,{'FT_DESCICM', GetSx3Cache('FT_DESCICM','X3_TIPO'), GetSx3Cache('FT_DESCICM','X3_TAMANHO'), GetSx3Cache('FT_DESCICM','X3_DECIMAL')})
aadd(aStru,{'FT_DESCZFR', GetSx3Cache('FT_DESCZFR','X3_TIPO'), GetSx3Cache('FT_DESCZFR','X3_TAMANHO'), GetSx3Cache('FT_DESCZFR','X3_DECIMAL')})
aadd(aStru,{'FT_DTCANC' , GetSx3Cache('FT_DTCANC' ,'X3_TIPO'), GetSx3Cache('FT_DTCANC' ,'X3_TAMANHO'), GetSx3Cache('FT_DTCANC' ,'X3_DECIMAL')})
aadd(aStru,{'FT_OBSERV' , GetSx3Cache('FT_OBSERV' ,'X3_TIPO'), GetSx3Cache('FT_OBSERV' ,'X3_TAMANHO'), GetSx3Cache('FT_OBSERV' ,'X3_DECIMAL')})
aadd(aStru,{'FT_ESTADO' , GetSx3Cache('FT_ESTADO' ,'X3_TIPO'), GetSx3Cache('FT_ESTADO' ,'X3_TAMANHO'), GetSx3Cache('FT_ESTADO' ,'X3_DECIMAL')})
aadd(aStru,{'FT_ESTCRED', GetSx3Cache('FT_ESTCRED','X3_TIPO'), GetSx3Cache('FT_ESTCRED','X3_TAMANHO'), GetSx3Cache('FT_ESTCRED','X3_DECIMAL')})
aadd(aStru,{'FT_CFOP'	, GetSx3Cache('FT_CFOP'	  ,'X3_TIPO'), GetSx3Cache('FT_CFOP'   ,'X3_TAMANHO'), GetSx3Cache('FT_CFOP'   ,'X3_DECIMAL')})
aadd(aStru,{'FT_BASEINS', GetSx3Cache('FT_BASEINS','X3_TIPO'), GetSx3Cache('FT_BASEINS','X3_TAMANHO'), GetSx3Cache('FT_BASEINS','X3_DECIMAL')})
aadd(aStru,{'FT_BASEIRR', GetSx3Cache('FT_BASEIRR','X3_TIPO'), GetSx3Cache('FT_BASEIRR','X3_TAMANHO'), GetSx3Cache('FT_BASEIRR','X3_DECIMAL')})
aadd(aStru,{'FT_BRETPIS', GetSx3Cache('FT_BRETPIS','X3_TIPO'), GetSx3Cache('FT_BRETPIS','X3_TAMANHO'), GetSx3Cache('FT_BRETPIS','X3_DECIMAL')})
aadd(aStru,{'FT_BRETCOF', GetSx3Cache('FT_BRETCOF','X3_TIPO'), GetSx3Cache('FT_BRETCOF','X3_TAMANHO'), GetSx3Cache('FT_BRETCOF','X3_DECIMAL')})
aadd(aStru,{'FT_BRETCSL', GetSx3Cache('FT_BRETCSL','X3_TIPO'), GetSx3Cache('FT_BRETCSL','X3_TAMANHO'), GetSx3Cache('FT_BRETCSL','X3_DECIMAL')})
aadd(aStru,{'FT_BSSENAR', GetSx3Cache('FT_BSSENAR','X3_TIPO'), GetSx3Cache('FT_BSSENAR','X3_TAMANHO'), GetSx3Cache('FT_BSSENAR','X3_DECIMAL')})

self:oTabTemp := FWTemporaryTable():New(cTmp)
self:oTabTemp:SetFields(aStru)

//Indice para ordenacao (Prefixo(E) ou (F) + FT_CLIEFOR + FT_LOJA = CODPAR )
self:oTabTemp:AddIndex("1", {"FT_FILIAL","FT_TIPOMOV","FT_SERIE","FT_NFISCAL","FT_CLIEFOR","FT_LOJA","FT_ESPECIE","FT_EMISSAO","FT_ENTRADA","SFTSTAMP","FT_ITEM"} )

//SF1
self:oTabTemp:AddIndex("2", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_ESPECIE","FT_TIPOMOV","SFTDELETE"} )

//SF2
self:oTabTemp:AddIndex("3", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_TIPOMOV","SFTDELETE"} )

//SA1/SA2
self:oTabTemp:AddIndex("4", {"FT_FILIAL","FT_CLIEFOR","FT_LOJA","FT_TIPOMOV","FT_TIPO","SFTDELETE"} )

//SD1/SD2
self:oTabTemp:AddIndex("5", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_PRODUTO","FT_ITEM","SFTDELETE"} )

//SB1 / F2Q - Complemento Fiscal
self:oTabTemp:AddIndex("6", {"FT_FILIAL","FT_PRODUTO","SFTDELETE"} )

//SF4 - TES
self:oTabTemp:AddIndex("7", {"FT_FILIAL","FT_TES","SFTDELETE"} )

//CDN - Cod. ISS
self:oTabTemp:AddIndex("8", {"FT_FILIAL","FT_CODISS","FT_PRODUTO","SFTDELETE"} )

//DT6
self:oTabTemp:AddIndex("9", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","SFTDELETE"} )

//DHR (NF x Natureza de Rendimento)
self:oTabTemp:AddIndex("10", {"FT_FILIAL","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_ITEM","SFTDELETE"} )

//SON
self:oTabTemp:AddIndex("11", {"FT_FILIAL","FT_TIPOMOV","SFTDELETE"} )

self:oTabTemp:Create()

cInsert := "FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,FT_ITEM,FT_PRODUTO,FT_ESPECIE,FT_EMISSAO,FT_ENTRADA,SFTSTAMP,"
cInsert += "FT_TIPO,FT_TES,FT_CODISS,SFTDELETE,FT_FORMUL,SFTRECNO,FT_IDTRIB,FT_NFELETR,FT_CHVNFE,FT_DESCICM,FT_DESCZFR,"
cInsert += "FT_DTCANC,FT_OBSERV,FT_ESTADO,FT_ESTCRED,FT_CFOP,FT_BASEINS,FT_BASEIRR,FT_BRETPIS,FT_BRETCOF,FT_BRETCSL,FT_BSSENAR"

cFields := "SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_PRODUTO,"
cFields += "SFT.FT_ESPECIE,SFT.FT_EMISSAO,SFT.FT_ENTRADA,"

If self:cDbType $ "MSSQL/MSSQL7"
    cFields += "CONVERT(VARCHAR(23), SFT.S_T_A_M_P_, 21) SFTSTAMP, "
Elseif self:cDbType $ "ORACLE"
    cFields += "(cast(to_char(SFT.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23))) SFTSTAMP, " 
Elseif self:cDbType $ "POSTGRES"
    cFields += " cast(to_char(SFT.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23)) SFTSTAMP, "
Endif

cFields += "SFT.FT_TIPO,SFT.FT_TES,SFT.FT_CODISS,SFT.D_E_L_E_T_ SFTDELETE,SFT.FT_FORMUL,"
cFields += "SFT.R_E_C_N_O_ SFTRECNO,SFT.FT_IDTRIB,SFT.FT_NFELETR,SFT.FT_CHVNFE,SFT.FT_DESCICM,SFT.FT_DESCZFR,"
cFields += "SFT.FT_DTCANC,SFT.FT_OBSERV,SFT.FT_ESTADO,SFT.FT_ESTCRED,SFT.FT_CFOP,"
cFields += "SFT.FT_BASEINS,SFT.FT_BASEIRR,SFT.FT_BRETPIS,SFT.FT_BRETCOF,SFT.FT_BRETCSL,SFT.FT_BSSENAR"

cInto := " INSERT INTO ? ( ? ) "
aAdd(aBind, {self:oTabTemp:GetRealName(),.T.})
aAdd(aBind, {cInsert,.T.})
self:cQryFTF3 := "SELECT DISTINCT " +  cFields + " FROM " + RetSqlName("SFT") + " SFT INNER JOIN " + RetSqlName("SF3") + " SF3 ON "
self:cQryFTF3 += "SF3.F3_FILIAL = SFT.FT_FILIAL "
self:cQryFTF3 += "AND SF3.F3_NFISCAL = SFT.FT_NFISCAL "
self:cQryFTF3 += "AND SF3.F3_SERIE = SFT.FT_SERIE "
self:cQryFTF3 += "AND SF3.F3_CLIEFOR = SFT.FT_CLIEFOR "
self:cQryFTF3 += "AND SF3.F3_LOJA = SFT.FT_LOJA "
self:cQryFTF3 += "AND SF3.F3_IDENTFT = SFT.FT_IDENTF3 "
self:cQryFTF3 += "AND SF3.F3_ENTRADA = SFT.FT_ENTRADA "
self:cQryFTF3 += "AND SF3.F3_ESPECIE = SFT.FT_ESPECIE "
self:cQryFTF3 += "AND (SF3.F3_ESPECIE <> ? AND SF3.F3_ESPECIE IS NOT NULL) "
aAdd(aBind, {Space(1),.F.})
self:cQryFTF3 += "AND (SF3.D_E_L_E_T_ = ? OR (SF3.D_E_L_E_T_ = ? AND SF3.F3_FORMUL = ? AND SF3.F3_DTCANC = ? )) "
aAdd(aBind, {Space(1),.F.})
aAdd(aBind, {'*',.F.})
aAdd(aBind, {Space(1),.F.})
aAdd(aBind, {Space(1),.F.})

self:cQryFTF3 += "AND SF3.S_T_A_M_P_ IS NOT NULL "
if "ORACLE" $ self:cDbType
	self:cQryFTF3 += "AND ? > TO_TIMESTAMP( ? ,'dd.mm.yyyy hh24:mi:ss.ff') " //'dd.mm.yyyy hh24:mi:ss.ff'
else
	self:cQryFTF3 += "AND ? > ? "
endif
aAdd(aBind, {cConvSF3, .T.} )
aAdd(aBind, {cUltStmp, .F.} )

self:cQryFTF3 += "WHERE "
self:cQryFTF3 += "SFT.FT_FILIAL = ? "
aAdd(aBind, {xFilial("SFT"),.F.} )
self:cQryFTF3 += "AND SFT.FT_ESPECIE <> ? AND SFT.FT_ESPECIE IS NOT NULL "
aAdd(aBind, {Space(1),.F.})
self:cQryFTF3 += "AND (SFT.D_E_L_E_T_ = ? OR (SFT.D_E_L_E_T_ = ? AND SFT.FT_TIPOMOV = ? AND SFT.FT_FORMUL = ? )) "
aAdd(aBind, {Space(1),.F.})
aAdd(aBind, {'*',.F.})
aAdd(aBind, {'E',.F.})
aAdd(aBind, {Space(1),.F.})

If "REINF" $ UPPER(cReinxGis)
    self:cQryFTF3 += "AND ( "
    self:cQryFTF3 += " (SFT.FT_BASEINS > 0 "
    self:cQryFTF3 += "   OR SFT.FT_BASEIRR > 0 "
    self:cQryFTF3 += "   OR SFT.FT_BRETPIS > 0 "
    self:cQryFTF3 += "   OR SFT.FT_BRETCOF > 0 "
    self:cQryFTF3 += "   OR SFT.FT_BRETCSL > 0 "
    self:cQryFTF3 += "   OR SFT.FT_BASEFUN > 0 "
    self:cQryFTF3 += "   OR SFT.FT_BSSENAR > 0 "
    self:cQryFTF3 += " ) "
	If !("GISS" $ UPPER(cReinxGis) .and. "REINF" $ UPPER(cReinxGis))
    	self:cQryFTF3 += " ) "
	Endif
Endif

If "GISS" $ UPPER(cReinxGis)
	If "GISS" $ UPPER(cReinxGis) .and. "REINF" $ UPPER(cReinxGis)
    	self:cQryFTF3 += "OR "
	Else
		self:cQryFTF3 += "AND ( "
	Endif
    self:cQryFTF3 += " (SFT.FT_TIPO = 'S' "
    self:cQryFTF3 += "	AND SFT.FT_CODISS IS NOT NULL "
    self:cQryFTF3 += "	AND (SFT.FT_BASEICM > 0 "
	self:cQryFTF3 += "	OR SFT.FT_ISENICM > 0 "
	self:cQryFTF3 += "	OR SFT.FT_OUTRICM > 0 ) "
    self:cQryFTF3 += " )) "
Endif

self:cQryFTF3 += "AND SFT.S_T_A_M_P_ IS NOT NULL "
if "ORACLE" $ self:cDbType
	self:cQryFTF3 += "AND ? > TO_TIMESTAMP( ? ,'dd.mm.yyyy hh24:mi:ss.ff') " //'dd.mm.yyyy hh24:mi:ss.ff'
else
	self:cQryFTF3 += "AND ? > ? "
endif
aAdd(aBind, {cConvSFT,.T.}) 
aAdd(aBind, {cUltStmp,.F.})

//Passa a comparar tambem o complemento do processo referenciado do ERP com o TAF, caso exista CDG superior a C20,
//deverá ira trazer o registro e inserir na temporaria, consequentemente a subquery posterior,
//ira indicar se existe processos vinculados a nota.
if self:lRegCDG
	cMaxCDG := strtran(cMaxStamp,'TABLE','CDGTOT')
	cMaxCDG += " FROM "+RetSqlName("CDG")+" CDGTOT "	
	cMaxCDG += "WHERE CDGTOT.CDG_FILIAL = SFT.FT_FILIAL "
	cMaxCDG += "AND CDGTOT.CDG_TPMOV = SFT.FT_TIPOMOV "
	cMaxCDG += "AND CDGTOT.CDG_DOC = SFT.FT_NFISCAL "
	cMaxCDG += "AND CDGTOT.CDG_SERIE = SFT.FT_SERIE "
	cMaxCDG += "AND CDGTOT.CDG_CLIFOR = SFT.FT_CLIEFOR "
	cMaxCDG += "AND CDGTOT.CDG_LOJA = SFT.FT_LOJA)" //Verifica a amarracao independente se foi excluido
	//Necessario para ser integrado novamente o documento fiscal e seus filhos e netos caso uma
	//informação complementar atribuida ao documento fiscal seja excluída.

	self:cQryFTF3 += "OR "
	if "ORACLE" $ self:cDbType
		self:cQryFTF3 += " ? > TO_TIMESTAMP( ? ,'dd.mm.yyyy hh24:mi:ss.ff')) "
	else
		self:cQryFTF3 += " ? > ? ) "
	Endif
	aAdd(aBind,{cMaxCDG ,.T.})
	aAdd(aBind,{cUltStmp,.F.})
endif

// Compara com o campo C20.STAMP o maior Stamp da tabela CDT retornado na subquery.
// Isso precisa ser feito pois pode ser adicionado uma informação complementar a um documento fiscal sem que o stamp da tabela SFT sejá atualizado,
// ficando assim o Stamp da tabela CDT maior que o Stamp da tabela SFT.
if self:lRegCDT
	cMaxCDT := strtran(cMaxStamp,'TABLE','CDTTOT')
	cMaxCDT += " FROM "+RetSqlName("CDT")+" CDTTOT "
	cMaxCDT += "WHERE CDTTOT.CDT_FILIAL = SFT.FT_FILIAL "
	cMaxCDT += "AND CDTTOT.CDT_TPMOV = SFT.FT_TIPOMOV "
	cMaxCDT += "AND CDTTOT.CDT_DOC = SFT.FT_NFISCAL "
	cMaxCDT += "AND CDTTOT.CDT_SERIE = SFT.FT_SERIE "
	cMaxCDT += "AND CDTTOT.CDT_CLIFOR = SFT.FT_CLIEFOR "
	cMaxCDT += "AND CDTTOT.CDT_LOJA = SFT.FT_LOJA "
	cMaxCDT += "AND CDTTOT.CDT_IFCOMP <> '" + space(1) + "' )" //Nao foi possivel passar o Bind, pois a cMaxCDT ja eh bindada.
	//Verifica a amarracao independente se foi excluido, necessario para ser integrado novamente o documento fiscal e seus filhos e netos caso uma
	//informação complementar atribuida ao documento fiscal seja excluída.

	self:cQryFTF3 += "OR "
	if "ORACLE" $ self:cDbType
		self:cQryFTF3 += " ? > TO_TIMESTAMP( ? ,'dd.mm.yyyy hh24:mi:ss.ff')) "
	else
		self:cQryFTF3 += " ? > ? ) "
	Endif
	aAdd(aBind,{cMaxCDT	,.T.})
	aAdd(aBind,{cUltStmp,.F.})
endif

self:cQryFTF3 += "ORDER BY FT_FILIAL,FT_TIPOMOV,FT_SERIE,FT_NFISCAL,FT_CLIEFOR,FT_LOJA,FT_ESPECIE,FT_EMISSAO,FT_ENTRADA,SFTSTAMP,FT_ITEM "
self:cQryFTF3 := ChangeQuery(self:cQryFTF3)
cInto += self:cQryFTF3

TAFConOut("TSILOG000033A " + alltrim(cEmpAnt+"|"+cFilAnt) + " Antes Insercao em Lote Filtro na SFT\SF3. " + TIME(), 1, .t., "TSI" )

oPrepare := FwExecStatement():New( cInto )
TafSetPrepare(oPrepare, @aBind)
cInto := oPrepare:getFixQuery()
TcSqlExec( cInto )

TAFConOut("TSILOG000033A " + alltrim(cEmpAnt+"|"+cFilAnt) + " Depois Insercao em Lote Filtro na SFT\SF3. " + cInto + " - " + TIME(), 1, .t., "TSI" )

cAliasQTD := GetNextAlias()
aBind	  := {}
cCount	  := 'SELECT COUNT(FT_NFISCAL) QTDSFT FROM ? '
aAdd(aBind,{self:oTabTemp:GetRealName(),.T.} )

oPrepare2 := FwExecStatement():New( cCount )
TafSetPrepare(oPrepare2, @aBind)
oPrepare2:OpenAlias( cAliasQTD )

If (cAliasQTD)->(!Eof())
	self:nQtFTF3 := (cAliasQTD)->QTDSFT
	TAFConOut("TSILOG000033A " + alltrim(cEmpAnt+"|"+cFilAnt) + " Quantidade Registros SFT ---> " + CVALTOCHAR((cAliasQTD)->QTDSFT) + " - " + TIME(), 1, .t., "TSI" )
EndIf
(cAliasQTD)->(DbCloseArea())

aSize(aStru,0)
aStru := {}

if oPrepare != Nil
	FwFreeObj(oPrepare)
	oPrepare := nil
endif
if oPrepare2 != Nil
	FwFreeObj(oPrepare2)
	oPrepare2 := nil
endif

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} CleanTmpFTF3()
Apaga e destroy a temporaria

@author Denis Souza
@since 29/07/2024
/*/
//-----------------------------------------------------------------------
Method CleanTmpFTF3() Class TSINFISCAL

if self:oTabTemp <> Nil .and. !Empty(self:oTabTemp:GetRealName())
    self:oTabTemp:Delete()
    self:oTabTemp := Nil
    freeobj(self:oTabTemp)
endif

Return Nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} CallWs034Proc()
Chamada do WsProc para processar o lote

@author Denis Souza
@since 29/07/2024
/*/
//-----------------------------------------------------------------------
Method CallWs034Proc(lUltLote,lERP,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21,aObjRet,oJObjRet) Class TSINFISCAL

Local cStamp as character

Default lUltLote := .F.
Default lERP	 := .F.
Default oModel   := Nil
Default oMldC20	 := Nil
Default oMldC30  := Nil
Default oMldC35  := Nil 
Default oMldC39  := Nil
Default oMldT9Q  := Nil
Default oMldC2F  := Nil
Default oMldC2D  := Nil
Default oMldC21  := Nil
Default aObjRet  := {}
Default oJObjRet := Nil

cStamp := ""

if lUltLote //se for ultimo lote limpa e adiciona o restante do oJObjRet
	aSIZE( aObjRet , 0 )
	aObjRet := { }
	aadd( aObjRet , oJObjRet )
endif

TAFConOut("TSILOG000028A - Processando lote de " + cvaltochar(self:nQtNotas) + " notas ao TAF - " + alltrim(cEmpAnt+"|"+cFilAnt) + " - " + TIME(), 1, .t., "TSI" )

If FwLibVersion() >= "20201009" .and. TCGetBuild() >= "20181212"
	cStamp := TSIFiscalDocument(oJObjRet)

	if _lAtuStamp .And. !Empty( cStamp ) //Momento de atualizar o ult stamp processado nesse lote.
		TSIAtuStamp("C20", cStamp )
	endif
Else
	Ws034Proc(nil,lERP,@aObjRet,@Self,oModel,oMldC20,oMldC30,oMldC35,oMldC39,oMldT9Q,oMldC2F,oMldC2D,oMldC21)

	if _lAtuStamp .And. !Empty( self:cUpStamp ) //Momento de atualizar o ult stamp processado nesse lote.
		TSIAtuStamp("C20", self:cUpStamp )
	endif
EndIf

aSIZE( aObjRet , 0 )
aObjRet := { }
FreeObj(oJObjRet)
oJObjRet := NIL

if !lUltLote
	oJObjRet := JsonObject( ):New( )
	oJObjRet[cTagJs] := { }
endif

self:nProcReg += self:nQtNotas

TAFConOut("TSILOG000029A - Total Processado: " + cvaltochar(self:nProcReg) + " notas ao TAF - " + alltrim(cEmpAnt+"|"+cFilAnt) + " - " + TIME(), 1, .t., "TSI" )

//Atualiza Contador de qtd de notas após insercao de lote
self:nQtNotas := 0

Return Nil
