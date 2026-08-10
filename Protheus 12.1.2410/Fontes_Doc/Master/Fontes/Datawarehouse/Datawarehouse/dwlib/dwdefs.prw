// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : DWDefs - Rotinas de apoio a DWDefs.ch
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 20.06.01 | 0548-Alan Candido |
// --------------------------------------------------------------------------------------

/*
--------------------------------------------------------------------------------------
Executa HTMLBegin (inicializa tHtmPage)
Arg: aoHtmPage -> objeto, tHtmPage já inicializada
	  anProcID -> numérico, ID de processo
Ret: oRet -> objeto, tHtmPage inicializada
--------------------------------------------------------------------------------------
*/                                 
function DWHtmBegin(aoHtmPage, anProcID)
	local oRet := aoHtmPage

	if valType(oRet) == "O"
		oRet:flAutoFooter := .f.
	endif

return oRet

/*
--------------------------------------------------------------------------------------
Executa HTMLSession (indica a sessão de tHtmPage)
Arg: @alInit -> lógico, indica se já houve ou não inicialização
	  aoSession -> objeto, sessão a ser identificada como corrente
Ret: 
--------------------------------------------------------------------------------------
*/                                 
function DWHtmSession(alInit, aoSession)

	if alInit
		clearVarSetGet("_HTMLLines")
	endif	

	varSetGet("_HTMLLines", { |x| iif(valtype(x)=="U", aoSession, NIL)})
	alInit := .t.

return 

/*
--------------------------------------------------------------------------------------
Verifica se a conexão ainda é valida
Arg:
Ret: logico
--------------------------------------------------------------------------------------
*/                                 
function DWHttpQuit()
	local lRet := .t.
                                              
	if DWKillApp() .or. (DWisWebEx() .and. !HttpIsConnected())
		break
	endif

return lRet
