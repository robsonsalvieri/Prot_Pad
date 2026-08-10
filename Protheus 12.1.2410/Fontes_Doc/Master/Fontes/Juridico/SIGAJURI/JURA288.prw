#include "Protheus.ch"
#include "FwMVCDef.ch"
#include "jura288.ch"

Static nValid := 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} JURA288
Fonte responsavel pelo cadastro e manutenção da Gestão de relatórios Totvs Legal
( Função de referência no X2_SYSOBJ da Tabela O17. )

@since 07/01/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Function JURA288()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //'Gestão de relatórios'
oBrowse:SetAlias( "O17" )
oBrowse:SetLocate()
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@author 
@since 07/01/2021
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrO17	:= FWFormStruct(1,'O17')

oModel := MPFormModel():New('JURA288', /*bPreValidacao*/,  /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('O17MASTER',/*cOwner*/,oStrO17,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0001)//'Gestão de relatórios'

oModel:GetModel('O17MASTER'):SetDescription(STR0001)	//'Gestão de relatórios' 

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@since 13/05/2024
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA288')
Local oStrO17 := FWFormStruct(2, 'O17')

	oView:SetModel(oModel)
	oView:AddField('VIEW_O17' ,oStrO17, 'O17MASTER')
	oView:CreateHorizontalBox('BOX', 100)
	oView:SetOwnerView('VIEW_O17','BOX')
Return oView

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288GestRel
Função responsavel para manipular o registro
@since 07/01/2021
@version 1.0
@param oJsonRel, json, Objeto json contendo os dados para serem inseridos ou atualizados
@return nRecno, return_description
/*/
//------------------------------------------------------------------------------
Function J288GestRel(oJsonRel)
Local aArea      := GetArea()
Local lInsert    := .T.
Local lOk        := .T.
Local nO17Perc   := 0
Local lTpChave   := .F.

Default oJsonRel := J288JsonRel()
	DbSelectArea('O17')

	lTpChave := O17->(FieldPos("O17_TIPO")) > 0 .And. O17->(FieldPos("O17_CHAVE")) > 0

	If oJsonRel['O17RECNO'] <> 0
		lInsert := .F.
		O17->(DbGoTo(oJsonRel['O17RECNO']))
		lOk := O17->(Recno()) == oJsonRel['O17RECNO']
	Endif

	If lOk
		MataThread(oJsonRel)

		nO17Perc := Iif(VALTYPE(oJsonRel['O17_PERC']) == 'N', oJsonRel['O17_PERC'], val(oJsonRel['O17_PERC']))

		RecLock('O17',lInsert)
			
		O17->O17_FILIAL := oJsonRel['O17_FILIAL']
		O17->O17_CODIGO := oJsonRel['O17_CODIGO']
		O17->O17_CODUSR := oJsonRel['O17_CODUSR']
		O17->O17_FILE   := oJsonRel['O17_FILE']  
		O17->O17_MIN    := oJsonRel['O17_MIN']   
		O17->O17_MAX    := oJsonRel['O17_MAX']   
		O17->O17_PERC   := Round( Iif( nO17Perc > 100 , 100, nO17Perc), 0)
		If lInsert .OR. O17->O17_STATUS <> "3" 
			O17->O17_DESC   := oJsonRel['O17_DESC'] 
			O17->O17_STATUS := oJsonRel['O17_STATUS']
		EndIf
		O17->O17_DATA   := Date()
		O17->O17_HORA   := Time()
		O17->O17_URLDWN := oJsonRel['O17_URLDWN']
		O17->O17_URLREQ := oJsonRel['O17_URLREQ']
		O17->O17_BODY   := oJsonRel['O17_BODY']  

		If (lTpChave)
			O17->O17_TIPO  := oJsonRel['O17_TIPO']
			O17->O17_CHAVE := oJsonRel['O17_CHAVE']
		EndIf

		O17->(MsUnLock())
		
		oJsonRel['O17RECNO'] := O17->(Recno())

		If __lSX8
			ConfirmSX8()
		Else
			RollBackSX8()
		EndIf

	Endif

	RestArea(aArea)

Return oJsonRel

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288JsonRel
@since 07/01/2021
@version 1.0
@return oJsonRel, objeto json com as propriedades básicas
/*/
//------------------------------------------------------------------------------
Function J288JsonRel()
Local oJsonRel := JsonObject():New()

	oJsonRel['O17_FILIAL'] := FWxFilial('O17')
	oJsonRel['O17_CODIGO'] := GetSxeNum('O17','O17_CODIGO')
	oJsonRel['O17_CODUSR'] := __CUSERID
	oJsonRel['O17_FILE']   := ""        
	oJsonRel['O17_DESC']   := STR0002   // "Preparando o arquivo"
	oJsonRel['O17_MIN']    := 0         
	oJsonRel['O17_MAX']    := 0         
	oJsonRel['O17_PERC']   := 0         // Min / Max * 100
	oJsonRel['O17_STATUS'] := '0'       // 0 = Em andamento, 1 = Erro, 2 = Concluído, 3 = Cancelado
	oJsonRel['O17_URLDWN'] := ''
	oJsonRel['O17_URLREQ'] := ''
	oJsonRel['O17_BODY']   := ''
	oJsonRel['O17_TIPO']   := '1'
	oJsonRel['O17_CHAVE']  := ''
	oJsonRel['O17RECNO']   := 0

Return oJsonRel

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288ChkRel
Função responsável por filtrar registros com erro ou cancelados pelo usuário

@since 16/08/2021
/*/
//------------------------------------------------------------------------------
Function J288ChkRel()

Local aArea   := GetArea()
Local cAlias  := GetNextAlias()
Local oJson   := JsonObject():new()
Local cQuery  := ""

	cQuery := " SELECT R_E_C_N_O_ O17RECNO, "
	cQuery +=        " O17_STATUS O17_STATUS "
	cQuery += " FROM "+ RetSqlName("O17") + " O17 "
	cQuery += " WHERE O17.O17_FILIAL = '" + xFilial("O17") + "' "
	cQuery +=     " AND O17.O17_STATUS NOT IN ('2')"
	cQuery +=     " AND O17.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	DbSelectArea("O17")
	While !(cAlias)->(EOF())
		O17->( dbGoTo((cAlias)->O17RECNO) )

		If O17->O17_STATUS <> '2' .And. !Empty(O17->O17_BODY)
			oJson:fromJson(O17->O17_BODY)
			If ValType(oJson["cIdThredExec"]) <> "U" .and. !Empty(oJson["cIdThredExec"])
				If LockByName(oJson["cIdThredExec"], .T., .T.)
					O17->(RecLock("O17", .F.))
					
					If (cAlias)->O17_STATUS == '3'
						O17->O17_DESC := STR0003 // "Geração cancelada pelo usuário"
					Else
						O17->O17_STATUS := '1' // erro
						O17->O17_DESC := STR0004 // "Erro na geração do arquivo"
					EndIf
					O17->O17_PERC := 100
					O17->(MsUnlock())
					UnLockByName(oJson["cIdThredExec"], .T., .T.)
				EndIf
			Endif

		EndIf
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())
	O17->(DbCloseArea())
	RestArea(aArea)

Return

//------------------------------------------------------------------------------
/* /{Protheus.doc} MataThread
Função responsavel por encerrar a thread de execução do relatório

@since 28/03/2021
@version 1.0
@param oJsonRel, json, Objeto json contendo os dados para serem inseridos ou atualizados
@return .T.
/*/
//------------------------------------------------------------------------------
Static Function MataThread(oJsonRel)
Local cQuery     := ""

	If nValid >= oJsonRel["O17_MAX"] * 0.05
		nValid := 0
		If oJsonRel['O17RECNO'] > 0
			cQuery := "SELECT O17_STATUS FROM " + retSqlName("O17") 
			cQuery += " WHERE R_E_C_N_O_ = '" + cValToChar(oJsonRel['O17RECNO']) + "'"

			If oJsonRel["O17_STATUS"] == "3" .OR. JurSQL(cQuery, {"O17_STATUS"})[1][1] == "3"
				KILLAPP( .T. )
			EndIf
		EndIf
	Else
		nValid ++
	End
Return .T.

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288CalcPerc(nMin, nMax)
Calcula o Percentual do Progresso do Relatório

@since 28/03/2021
@version 1.0
@param nMin - Valor minimo
@param nMax - Valor maximo
@return - Valor percentual
/*/
//------------------------------------------------------------------------------
Function J288CalcPerc(nMin, nMax)
Local nPercRet := 0

	If nMax > 0
		nPercRet := Round( nMin / nMax * 100, 0)

		if nPercRet > 100
			nPercRet := 100	
		EndIf
	EndIf
Return nPercRet


//------------------------------------------------------------------------------
/* /{Protheus.doc} J288VerGstRel(cChave)
Verifica se a Chave existe no Gestão de Relatórios e se está em andamento

@since 09/05/2024
@version 1.0
@param cChave - Chave de identificação

@return - Se o registro existe e está em andamento
/*/
//------------------------------------------------------------------------------
Function J288InProc(cChave, lLike)
Local oQuery  := Nil
Local lRet    := .F.
Local aParams := {}
Local cQuery  := ""
Local cAlias  := ""

Default lLike := .F.

	cQuery := " SELECT COUNT(*) QTD"
	cQuery +=   " FROM " + RetSqlName("O17") + " O17"
	cQuery +=  " WHERE D_E_L_E_T_ = ' '"
	cQuery +=    " AND O17_STATUS = '0'"
	If lLike 
		cQuery += " AND O17_FILE LIKE ?"
		aAdd(aParams, {"C", cChave + "%" })
	Else
		cQuery += " AND O17_FILE = ?"
		aAdd(aParams, {"C", cChave })
	Endif

	oQuery  := FWPreparedStatement():New(cQuery)
	oQuery  := JQueryPSPr(oQuery, aParams)
	cQuery  := oQuery:GetFixQuery()
	
	cAlias := GetNextAlias()
	MpSysOpenQuery(cQuery,cAlias)
	
	lRet := (cAlias)->(QTD) > 0
Return lRet 

//------------------------------------------------------------------------------
/* /{Protheus.doc} J288CBox()
Responsável pelas opções de combo box do campo O17_TIPO

@return cOpcoes   - Indica a lista de opções
/*/
//------------------------------------------------------------------------------
Function J288CBox()
local cOpcoes := ""

	cOpcoes += "1=" + STR0005 + ";" //Relatório
	cOpcoes += "2=" + STR0006 + ";" //Auditoria

Return cOpcoes

//-------------------------------------------------------------------
/*/{Protheus.doc} J204VlTpAq( cTipArq )
Responsável pela validação no preenchimento do campo O17_TIPO

@param  cTipArq - Indica o tipo de arquivo
                    1=Relatório
                    2=Auditoria
                  
@return lRet    - Indica se o valor é válido
/*/
//-------------------------------------------------------------------
Function J288VlTipo( cTipArq )   
Return Empty( cTipArq ).Or.Pertence("12")

//-------------------------------------------------------------------
/*/{Protheus.doc} J288GtRec( nRecno )
Responsável por obter o registro do Gestão de Relatórios da O17 a partir do Recno

@param  nRecno - Recno do registro a ser obtido
                  
@return oJsonRel - Objeto Json contendo os dados do registro
/*/
//-------------------------------------------------------------------
Function J288GtRec( nRecno )
Local oJsonRel := JsonObject():New()
Local lTpChave := .F.

	DbSelectArea("O17")
	lTpChave := O17->(FieldPos("O17_TIPO")) > 0 .And. O17->(FieldPos("O17_CHAVE")) > 0
	O17->(DbGoTo(nRecno))

	oJsonRel['O17_FILIAL'] := O17->O17_FILIAL
	oJsonRel['O17_CODIGO'] := O17->O17_CODIGO
	oJsonRel['O17_CODUSR'] := O17->O17_CODUSR
	oJsonRel['O17_FILE']   := O17->O17_FILE
	oJsonRel['O17_DESC']   := O17->O17_DESC
	oJsonRel['O17_MIN']    := O17->O17_MIN
	oJsonRel['O17_MAX']    := O17->O17_MAX
	oJsonRel['O17_PERC']   := O17->O17_PERC
	oJsonRel['O17_STATUS'] := O17->O17_STATUS
	oJsonRel['O17_URLDWN'] := O17->O17_URLDWN
	oJsonRel['O17_URLREQ'] := O17->O17_URLREQ
	oJsonRel['O17_BODY']   := O17->O17_BODY
	If lTpChave
		oJsonRel['O17_TIPO']  := O17->O17_TIPO
		oJsonRel['O17_CHAVE'] := O17->O17_CHAVE
	EndIf
	oJsonRel['O17RECNO']   := nRecno

	O17->(dbCloseArea())

Return oJsonRel
