 
//#INCLUDE "GFEXFUNS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
Static aCacheSX3 := {}
Static nLenSX3Cache := 0

/*----------------------------------------------------------------------------------
Funções para suavização
----------------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------------
Função para verificar se o campo existe no dicionário e é usado
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXCPUSO
Função para verificar se o campo existe no dicionário e é usado
@author siegklenes.beulke
@since 23/05/2017
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCPUSO(cCampo)
Return X3Usado(cCampo)

/*/{Protheus.doc} GFXCP12116
Função para verificar se o campo existe
@author leonardo.jimenez
@since 13/04/2017
@version 1.0
@param cAlias, cCampo
@return 
@example
@see 
/*/
Function GFXCP12116(cAlias,cCampo,lVerUso)
Return GFXCP12117(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12117
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author siegklenes.beulke
@since 24/04/2017
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCP12117(cCampo,lVerUso)
Return GFXCP12118(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12117
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author elynton.bazzo
@since 24/04/2017
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCP12118(cCampo,lVerUso)
Return GFXCP12121(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12121
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author elynton.bazzo
@since 24/04/2017
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCP12121(cCampo,lVerUso)
Return GFXCP12123(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12123
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Leonardo Ribas Jimenez Hernandez
@since 24/08/2018
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCP12123(cCampo,lVerUso)
Return GFXCP12125(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12125
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Fabiane Schulze
@since 30/05/2019
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCP12125(cCampo,lVerUso)
Return GFXCP12127(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12127
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Fabiane Schulze
@since 28/06/2019
@version 1.0
@param cCampo
@return 
@example
@see 
/*/
Function GFXCP12127(cCampo,lVerUso)
Return GFXCP12130(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12130
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Jefferson Hita
@since 17/02/2020
@version 1.0
@param cCampo
@return
@example
@see 
/*/
Function GFXCP12130(cCampo,lVerUso)
Return GFXCP12131(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12130
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Jefferson Hita
@since 17/02/2020
@version 1.0
@param cCampo
@return
@example
@see 
/*/
Function GFXCP12131(cCampo,lVerUso)
Return GFXCP12133(cCampo,lVerUso)


/*/{Protheus.doc} GFXCP12133
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function GFXCP12133(cCampo,lVerUso)
Return GFXCP12137(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP12137
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Jefferson Hita
@since 23/06/2021
@version 1.0
@param cCampo
@return
@example
@see 
/*/
Function GFXCP12137(cCampo,lVerUso)
Return GFXCP1212210(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP1212210
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Matheus de Souza
@since 05/07/2022
@version 1.0
@param cCampo
@return
@example
@see 
/*/

Function GFXCP1212210(cCampo,lVerUso)
Return GFXCP1212410(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP1212410
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author João Leonardo Schmidt
@since 08/08/2023
@version 1.0
@param cCampo
@return
@example
@see 
/*/

Function GFXCP1212410(cCampo,lVerUso)
Return GFXCP2510(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP2510 (1212510)
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author Philippe R Bretas
@since 21/11/2024
@version 1.0
@param cCampo
@return
@example
@see 
/*/

Function GFXCP2510(cCampo,lVerUso)
Return GFXCP2610(cCampo,lVerUso)

/*/{Protheus.doc} GFXCP2610 (1212610)
Função para verificar se o campo existe NA BASE ou está usado no dicionário
@author João Leonardo Schmidt
@since 17/06/2025
@version 1.0
@param cCampo
@return
@example
@see 
/*/

Function GFXCP2610(cCampo,lVerUso)
	Local cAlias
	Local nPos
	Default lVerUso := .T.
	
	// Quando a função for chamada no MenuDef, os Alias ainda não existem.
	// Estamos colocando esta proteção para evitar erro ao montar o menu na tela inicial do protheus
	if Select("SX2") == 0
		Return .F.
	EndIf

	If lVerUso
		Return GFXCPUSO(cCampo)
	EndIf

	cAlias := SubStr(cCampo,1,At("_",cCampo)-1)

	If Len(cAlias) == 2
		cAlias := "S" + cAlias
	EndIf
	If (nPos := aScan(aCacheSX3,{|x| x[1] == cCampo})) == 0
		aAdd(aCacheSX3,{cCampo,(cAlias)->(FieldPos(cCampo)) > 0})
		nLenSX3Cache++
		Return aCacheSX3[nLenSX3Cache,2]
	EndIf
Return aCacheSX3[nPos,2]

/*----------------------------------------------------------------------------------
Função para verificar se a consulta padrão existe
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXXB12116
Função para verificar se a consulta padrão existe
@author leonardo.jimenez
@since 17/04/2017
@version 1.0
@param cConsulta
@return 
@example
@see 
/*/
Function GFXXB12116(cConsulta)
Return GFXXB12117(cConsulta)

/*/{Protheus.doc} GFXXB12117
Função para verificar se a consulta padrão existe
@author leonardo.jimenez
@since 17/04/2017
@version 1.0
@param cConsulta
@return 
@example
@see 
/*/
Function GFXXB12117(cConsulta)
	Local lRet := .F.
  
	If SXB->(msSeek(cConsulta))
		lRet := .T.
	EndIf
Return lRet

/*----------------------------------------------------------------------------------
Função para verificar se o alias existe
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXTB12117
Função para verificar se o alias existe
@author leonardo.jimenez
@since 10/05/2017
@version 1.0
@param cAlias
@return 
@example
@see 
/*/
Function GFXTB12117(cAlias)
Return GFXTB12127(cAlias)

/*/{Protheus.doc} GFXTB12127
Função para verificar se o alias existe. Release 12.1.27
@author Jefferson Hita
@since 06/02/2020
@version 1.0
@param cAlias
@return 
@example
@see 
/*/
Function GFXTB12127(cAlias)
Return GFXTB12130(cAlias)

/*/{Protheus.doc} GFXTB12130
Função para verificar se o alias existe
@author Squad GFE
@since 15/06/2020
@version 1.0
@param cAlias
@return 
@example
@see 
/*/
Function GFXTB12130(cAlias)
Return GFXTB12133(cAlias)

/*/{Protheus.doc} GFXTB12133
Função para verificar se o alias existe
@author Squad GFE
@since 25/05/2021
@version 1.0
@param cAlias
@return 
@example
@see 
/*/
Function GFXTB12133(cAlias)
Return GFXTB1212210(cAlias)

/*/{Protheus.doc} GFXTB1212210
Função para verificar se o alias existe
@author Squad GFE
@since 28/09/2022
@version 1.0
@param cAlias
@return 
@example
@see 
/*/
Function GFXTB1212210(cAlias)
	// Quando a função for chamada no MenuDef, os Alias ainda não existem.
	// Estamos colocando esta proteção para evitar erro ao montar o menu na tela inicial do protheus
	if Select("SX2") > 0
		SX2->(dbSetOrder(1))
	Else
		Return .F.
	EndIf
Return SX2->(MsSeek(cAlias))

/*----------------------------------------------------------------------------------
Função para verificar se o parâmetro existe
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXPR12116
Função para verificar se o parâmetro existe
@author siegklenes.beulke
@since 23/05/2017
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12116(cParametro)
Return GFXPR12117(cParametro)

/*/{Protheus.doc} GFXPR12117
Função para verificar se o parâmetro existe
@author siegklenes.beulke
@since 23/05/2017
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12117(cParametro)
Return GFXPR12118(cParametro)

/*/{Protheus.doc} GFXPR12118
Função para verificar se o parâmetro existe (SX6)
@since 07/07/2017
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12118(cParametro)
Return GFXPR12121(cParametro)

/*/{Protheus.doc} GFXPR12121
Função para verificar se o parâmetro existe
@author siegklenes.beulke
@since 23/05/2017
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12121(cParametro)
Return GFXPR12127(cParametro)

/*/{Protheus.doc} GFXPR12127
Função para verificar se o parâmetro existe
@author Fabiane Schulze
@since 29/06/2019
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12127(cParametro)
Return GFXPR12130(cParametro)

/*/{Protheus.doc} GFXPR12130
Função para verificar se o parâmetro existe
@author Jefferson Hita
@since 14/04/2020
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12130(cParametro)
Return GFXPR12131(cParametro)

/*/{Protheus.doc} GFXPR12131
Função para verificar se o parâmetro existe
@author Jefferson Hita
@since 14/04/2020
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12131(cParametro)
Return GFXPR12133(cParametro)

/*/{Protheus.doc} GFXPR12133
Função para verificar se o parâmetro existe
@author Jefferson Hita
@since 14/04/2020
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12133(cParametro)
Return GFXPR12137(cParametro)

/*/{Protheus.doc} GFXPR12137
	Função para verificar se o parâmetro existe
@author Alexsander Correa
@since 28/10/2020
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR12137(cParametro)
Return GFXPR1212310(cParametro)

/*/{Protheus.doc} GFXPR1212310
	Função para verificar se o parâmetro existe
@author Matheus de Souza
@since 02/08/2022
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXPR1212310(cParametro)
Return GFXPR1212410(cParametro)

/*/{Protheus.doc} GFXPR1212410
	Função para verificar se o parâmetro existe
@author Philippe Bretas
@since 28/06/2024
@version 1.0
@param cParametro
@return 
@example
@see 
/*/


Function GFXPR1212410(cParametro)
Return GFXPR1212510(cParametro)


/*/{Protheus.doc} GFXPR1212510
	Função para verificar se o parâmetro existe
@author Philippe Bretas
@since 21/11/2024
@version 1.0
@param cParametro
@return 
@example
@see 
/*/

Function GFXPR1212510(cParametro)
	Local cFilSpace := Space( FwSizeFilial() )
Return SX6->(msSeek(cFilSpace + cParametro)) .Or. SX6->(msSeek(xFilial("SX6") + cParametro))

/*----------------------------------------------------------------------------------
Função responsável por retornar se o campo é Real
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXRL12123
Função responsável por retornar se o campo é Real
@author João Leonardo Schmidt
@since 23/04/2019
@version 1.0
@param cAlias - Nome da tabela na qual deve ser executada a busca do campo
@param cCampo - Campo a ser verificado se é real
@return lRet - Caso seja verdadeiro, indica que o campo é real, caso seja falso, o campo pode não existir ou ser virtual, utilizar em conjunto com a verificação de existência do campo
/*/
Function GFXRL12123(cAlias,cCampo)
Return GFXRL1212410(cAlias,cCampo)

/*/{Protheus.doc} GFXRL1212410
Função responsável por retornar se o campo é Real
@author Philippe Rocca Bretas
@since 21/11/2024
@version 1.0
@param cAlias - Nome da tabela na qual deve ser executada a busca do campo
@param cCampo - Campo a ser verificado se é real
@return lRet - Caso seja verdadeiro, indica que o campo é real, caso seja falso, o campo pode não existir ou ser virtual, utilizar em conjunto com a verificação de existência do campo
/*/

Function GFXRL1212410(cAlias,cCampo)
Return GFXRL1212510(cAlias,cCampo)

/*/{Protheus.doc} GFXRL1212510
Função responsável por retornar se o campo é Real
@author Philippe Rocca Bretas
@since 21/11/2024
@version 1.0
@param cAlias - Nome da tabela na qual deve ser executada a busca do campo
@param cCampo - Campo a ser verificado se é real
@return lRet - Caso seja verdadeiro, indica que o campo é real, caso seja falso, o campo pode não existir ou ser virtual, utilizar em conjunto com a verificação de existência do campo
/*/

Function GFXRL1212510(cAlias,cCampo)
	Local lRet    := .T.
	Local aFields := FWSX3Util():GetAllFields(cAlias,.F.)
	
	If AScan(aFields,cCampo) == 0
		lRet := .F.
	EndIf
Return lRet

/*----------------------------------------------------------------------------------
Função para verificar se o pergunte existe NA BASE
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXPE12125
Função para verificar se o pergunte existe NA BASE
@author Leonardo Ribas Jimenez Hernandez
@since 05/06/2019
@version 1.0
@param cPergunte
@return 
@example
@see 
/*/
Function GFXPE12125(cPergunte)
	Local lRet := .F.
	
	cPergunte := PadR(AllTrim(cPergunte), 10)
	SX1->(dbSetOrder(1))

	If SX1->(DbSeek(cPergunte))
		lRet := .T.
	EndIf
Return lRet

/*----------------------------------------------------------------------------------
Função para verificar se a função existe
----------------------------------------------------------------------------------*/

/*/{Protheus.doc} GFXFU12123
Função para verificar se a função existe
@author Jefferson Hita
@since 16/12/2019
@version 1.0
@param cParametro
@return 
@example
@see 
/*/
Function GFXFU12123(cParametro)
	Local lRetFunc := FindFunction( cParametro )
Return lRetFunc
//-------------------------------------------------------------------
/*/{Protheus.doc} GfeDark
Função responsavel por retornar se o tema dark esta ativo.

@version 1.0
@author Matheus de Souza
@since 11/06/2024
/*/
//-------------------------------------------------------------------
Function GfeDark()
    local lIsDark := .F.
    local cTheme  := ""
   
    cTheme := totvs.framework.css.getNewWebAppTheme()
    lIsDark := iif(!empty(cTheme) .and. cTheme == "DARK", .T., .F.) //Valida se o tema ativo é o dark
Return lIsDark
