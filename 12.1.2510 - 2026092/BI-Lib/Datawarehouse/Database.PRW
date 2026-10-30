// #####################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : SigaDW
// Fonte  : Database - Gerencia o acesso ao banco de dados do SigaDW
// ---------+------------------+--------------------------------------------------------
// Data     | Auto             | Descricao
// ---------+------------------+--------------------------------------------------------
// 01.06.01 |0548-Alan Candido |
// 24.09.07 |0548-Alan Candido | BOPS 132350 - Implementação do campo "export" em TAB_CONSULTAS
// 14.11.07 |0548-Alan Candido | BOPS 135941 - Adicionado comentário de segurança na função verDBOwner()
// 18.01.08 |0548-Alan Candido | BOPS 139342 - Implementação e adequação de código, 
//          |                  | em função de re-estruturação para compartilhamento de 
//          |                  | código.    
// 23.01.08 |0548-Alan Candido | BOPS 136637 - Compatibilização da query SEL_FACT_INFO para
//          |                  | para o Informix.
// 12.06.08 |0548-Alan Candido | BOPS 147424
//          |                  | Ajuste nas clausulas 'where' para ligação entre tabelas
//          |                  | Tabelas: TAB_USER_PRIV -> TAB_CONSULTAS, TAB_DW, TAB_CUBESLIST
//          |                  |          TAB_DSN -> TAB_DIMENSAO, TAB_CUBESLIST
//          |                  |          TAB_EXPORT -> TAB_DIMENSAO, TAB_CONSTYPE
// 05.08.08 |0548-Alan Candido | BOPS 151312
//          |                  | Ajuste no join da SEL_DSNCONF2 para DB2, Informix e PostGres.
// 05.08.08 |0548-Alan Candido | BOPS 149441
//          |                  | Implementação do campo TAB_SXM->info.
// 08.08.08 |0548-Alan Candido | BOPS 151591
//          |                  | Modificada a query SEL_DSNCONF, para compatibilização com 
//          |                  | MS-SQL 9 (2005)
// 24.09.08 |0548-Alan Candido | BOPS 154692
//          |                  | Correção na SEL_DSNCONF, quando SGDB é oracle
// 25.11.08 |0548-Alan Candido | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                  | Implementação da query SEL_BUILD
// 15.12.08 |0548-Alan Candido | FNC 09025/2008 (8.11) e 09034/2008 (10)
//          |                  | . Adequação de geração de máscara em campos numéricos e datas, 
//          |                  | para respeitar o formato conforme idioma 
//          |                  | (chave RegionalLanguage na sessão do ambiente).
//          |                  | . Implementação do campo TAB_EXPORT->percIsInd.
// 30.12.08 |0548-Alan Candido | FNC 00000011160/2008 (8.11) e 00000011201/2008 (P10)
//          |                  | . Adequação em query de seleção na tabela TAB_EXPORT
//          |                  | . Inicialização da tabela TAB_BUILD antes de executar SEL_BUILD
// -------------------------------------------------------------------------------------
    
#include "dwincs.ch"
#include "Database.ch"
#include "dbinfo.ch"

/*
--------------------------------------------------------------------------------------
Tipo de banco de dados
Arg: 
Ret: lRet -> lógico, indica se a inicialização foi bem suscedida
--------------------------------------------------------------------------------------
*/       
function SGDB()
	local cRet := upper(alltrim(TcGetDB()))

	if left(cRet,1) == '@'
		cRet := substr(cRet, 5)
	endif

return cRet
