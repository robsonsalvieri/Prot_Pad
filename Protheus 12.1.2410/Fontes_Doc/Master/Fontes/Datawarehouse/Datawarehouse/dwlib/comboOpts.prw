// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Lib
// Fonte  : comboOpts - Prepara lista de opções para combos
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 29.09.06 | 0548-Alan Candido | Versão 3
// 09.12.08 | 0548-Alan Candido | FNC 00000149278/811 (8.11) e 00000149278/912 (9.12)
//          |                   | Implementação de opções para suporte ao ranking por
//          |                   | nivel de drill-down
// 05.05.09 | 0548-Alan Candido | FNC 00000009956/2009
//          |                   | Implementação de opção de banco do tipo ODBC
// --------------------------------------------------------------------------------------

#include "dwincs.ch"
#include "dwComboOpts.ch"

function dwComboOptions(anComboNum, acType, lActive)  
	local aComboList := nil
	
	default acType 	:= TYPE_TABLE   	
	default lActive := .F.	//Retorna apenas asopções ativas. 
	
	do case
		case anComboNum == ADVPL_FIELD_TYPES
			aComboList := fieldTypeList()
		case anComboNum == PERIODICIDADE_SCHD
			aComboList := perioSched()
		case anComboNum == TIPO_CONEXAO
			aComboList := tipoConexao()
		case anComboNum == TIPO_BANCO
			aComboList:= tipoBanco()
		case anComboNum == ADVPL_EXT_FIELD_TYPES
			aComboList := fieldeXTTypeList()
		case anComboNum == AGG_LIST_FOR_APPLET
			aComboList := aggListForApplet()
		case anComboNum == RNK_PROCESSOS
			aComboList := rankProcessos(acType)
		case anComboNum == FILE_TYPES
			aComboList := fileTypes(lActive)
		case anComboNum == RPTINV_OPTIONS
			aComboList:= rptOptns()
		case anComboNum == DW_ICONES
	   		aComboList := dwIcones()
		case anComboNum == RNK_STYLE
	   		aComboList := rnkStyle(acType)
		case anComboNum == RNK_STYLE_PARC
	   		aComboList := rnkStyleParc(acType)
	endcase				

return aComboList

static function fieldTypeList()	// ADVPL_FIELD_TYPES
return { {STR0001, "C"}, {STR0002, "N"}, {STR0003, "D"}, {STR0004, "L"}, {STR0005, "M"} } //###"Caracter"###"Numerico"###"Fecha"###"Logico"###"Memo"

static function perioSched() // PERIODICIDADE_SCHD
return { { STR0006, "1"}, {STR0007, "2"}, {STR0008, "3"} } //###"Diario"###"Semanal"###"Mensal"

static function tipoConexao() // TIPO_CONEXAO
return { { "TCP/IP", "TCPIP"}, { "APPC", "APPC" }, { "NPipe", "NPIPE" } }

static function tipoBanco() // TIPO_BANCO
  local aRet := { { "Sql Server", "MSSQL"    }, { "Oracle"  , "ORACLE"   }, { "Sybase"   , "SYBASE" }, ;
                  { "Informix"  , "INFORMIX" }, { "Postgres", "POSTGRES" }, { "MySQL"    , "MYSQL"  }, ;
                  { "DB2"       , "DB2"      }, { "MS ADO"  , "MSADO"    }, { "DB2/AS400", "DB2/AS400" } }
#ifdef VER_P10
  aAdd(aRet, { "ODBC", "ODBC"} )
#endif  

return aRet				 

static function fieldExtTypeList() // ADVPL_EXT_FIELD_TYPES
	local aAux := {}
	
	aAdd(aAux, { STR0009, "?" }) //###"(não suportado)"
	aEval(fieldTypeList(), { |x| aAdd(aAux, x) })
		
return aAux
				 
static function aggListForApplet() // AGG_LIST_FOR_APPLET
	local aRet := {}
	
	aAdd(aRet, { dwStr(AGG_SUM)         , STR0010, "ic_agreg_sum.gif" }) 			//###"Soma"
	aAdd(aRet, { dwStr(AGG_COUNT)       , STR0011, "ic_agreg_count.gif" })			//###"Contagem"
	aAdd(aRet, { dwStr(AGG_DIST)        , STR0012, "ic_agreg_distinct.gif" }) 		//###"Distinção"
	aAdd(aRet, { dwStr(AGG_AVG)         , STR0013, "ic_agreg_average.gif" })		//###"Média"
	aAdd(aRet, { dwStr(AGG_MIN)         , STR0014, "ic_agreg_min.gif" })			//###"Minimo"
	aAdd(aRet, { dwStr(AGG_MAX)         , STR0015, "ic_agreg_max.gif" })			//###"Máximo"
	aAdd(aRet, { dwStr(AGG_PAR)         , STR0016, "ic_agreg_part.gif" })			//###"Participação"
	aAdd(aRet, { dwStr(AGG_PARTOT)      , STR0017, "ic_agreg_total_part.gif" })		//###"Participação Total"
	aAdd(aRet, { dwStr(AGG_PARGLOB)     , STR0018, "ic_agreg_global_part.gif" })		//###"Participação Global"
	aAdd(aRet, { dwStr(AGG_MEDINT)      , STR0019, "ic_agreg_intern_average.gif" })	//###"Média Interna"
	aAdd(aRet, { dwStr(AGG_ACUM)        , STR0020, "ic_agreg_acum.gif" })			//###"Acumulado"
	aAdd(aRet, { dwStr(AGG_ACUMPERC)    , STR0021, "ic_agreg_acum_perc.gif" })		//###"Acumulado(%)"  
	aAdd(aRet, { dwStr(AGG_ACUMHIST)    , STR0022, "ic_agreg_acum_hist.gif" })		//###"Acumulado Hist." 
	aAdd(aRet, { dwStr(AGG_ACUMHISTPERC), STR0023, "ic_agreg_acum_hist_perc.gif" })	//###"Acumulado (%) Hist."

return aRet

static function rankProcessos(acType)	// RNK_PROCESSOS
	local aReturn := {}
	default acType := TYPE_TABLE 
	aReturn := { {STR0024, RNK_MAIORES}, {STR0025, RNK_MENORES}, {STR0026, RNK_PARETO}  } //###"n Majores"###"n Menores"###"Pareto(%)"

return aReturn
 

static function fileTypes(lActive)
	local aRet := {}              
	
	Default lActive := .F. 							//Retorna apenas as opções ativas.    

	aAdd(aRet, {".txt", STR0028, FT_TXT})			//###"Texto"
	aAdd(aRet, {".txt", STR0029, FT_SDF})			//###"Texto SDF"  
	aAdd(aRet, {".htm", STR0030, FT_HTM})			//###"HyperText"  
	aAdd(aRet, {".xls", STR0031, FT_EXCEL})			//###"Excel 95/97"
	aAdd(aRet, {".jpg", STR0032, FT_GRAPH_JPEG})	//###"Imagem JPEG"
	aAdd(aRet, {".xml", STR0033, FT_EXCEL_XML})		//###"Excel 2000 ou superior"
	aAdd(aRet, {".csv", STR0034, FT_CSV})			//###"Texto(CSV)"    
	
	If !(lActive)
		aAdd(aRet, {".xls", STR0035, FT_DIRECT_EXCEL})	//###"Excel(integração)"
    EndIf
return aRet   


static function rptOptns()
	local aRet := {}
	
	aAdd(aRet, {STR0036, RPTINVAL_NONE})		//###"Não gerar"
	aAdd(aRet, {STR0037, RPTINVAL_KEYSONLY})	//###"Somente chaves, max. 500"
	aAdd(aRet, {STR0038, RPTINVAL_FULL})		//###"Completo, max. 500"
	aAdd(aRet, {STR0039, RPTINVAL_KEYSONLY_SL})	//###"Somente chaves, sem limite"
	aAdd(aRet, {STR0040, RPTINVAL_FULL_SL}) 	//###"Completo, sem limite"
	
return aRet

static function dwIcones()
	local aRet := {}
	
	aAdd(aRet, {STR0041, "dw_new.gif"}) 	//###"Padrão"
	aAdd(aRet, {STR0042, "dw_fab.gif"})		//###"Produção"
	aAdd(aRet, {STR0043, "dw_fin.gif"})		//###"Financeiro"
	aAdd(aRet, {STR0044, "dw_rh.gif"})		//###"R.H."
	aAdd(aRet, {STR0045, "dw_ven.gif"})		//###"Comercial"
	
return aRet

static function rnkStyle(acType)
	local aRet := {}

  if acType == TYPE_TABLE
		aAdd(aRet, {STR0041, RNK_STY_PADRAO}) 	//"Padrão"
		aAdd(aRet, {STR0027, RNK_STY_CURVA_ABC}) 	//"Curva ABC"
		aAdd(aRet, {STR0046, RNK_STY_LEVEL}) 	//"Por nível"
		aAdd(aRet, {STR0047, RNK_STY_CLEAR}) 	//"(sem definição)"
	else
		aAdd(aRet, {STR0041, RNK_STY_PADRAO}) 	//###"Padrão"
		aAdd(aRet, {STR0046, RNK_STY_LEVEL}) 	//"Por nível"
		aAdd(aRet, {STR0047, RNK_STY_CLEAR}) 	//"(sem definição)"
	endif
		
return aRet

static function rnkStyleParc(acType)
	local aRet := {}

  if acType == TYPE_TABLE
  	aAdd(aRet, {STR0041, RNK_STY_PADRAO}) 	//###"Padrão"
  	aAdd(aRet, {STR0027, RNK_STY_CURVA_ABC}) 	//###"Curva ABC"
		aAdd(aRet, {STR0047, RNK_STY_CLEAR}) 	//"(sem definição)"
  else
  	aAdd(aRet, {STR0041, RNK_STY_PADRAO}) 	//###"Padrão"
		aAdd(aRet, {STR0047, RNK_STY_CLEAR}) 	//"(sem definição)"
  endif
  
return aRet