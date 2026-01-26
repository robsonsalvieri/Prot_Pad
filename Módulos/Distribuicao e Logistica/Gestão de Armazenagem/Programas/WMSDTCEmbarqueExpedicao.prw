#Include "Totvs.ch" 
#Include "WMSDTCEmbarqueExpedicao.ch"

//---------------------------------------------
/*/{Protheus.doc} WMSCLS0063
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 13/12/2018
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0063()
Return Nil
//---------------------------------------------
/*/{Protheus.doc} WMSDTCEmbarqueExpedicao
(long_description)
@author    SQUAD WMS/OMS Protheus
@since     12/12/2018
@version   1.0
/*/
//---------------------------------------------
CLASS WMSDTCEmbarqueExpedicao FROM LongNameClass
	DATA oEndereco
	DATA cEmbarque
	DATA cStatus
	DATA dDatGer
	DATA cHorGer
	DATA cCodUsu
	DATA cTransp
	DATA nRecno
	DATA cErro
	DATA lD0XTransp
	
	METHOD New() CONSTRUCTOR
	METHOD ClearData()
	METHOD Destroy()
	METHOD GoToD0X(nRecno)
	METHOD LoadData(nIndex)
	METHOD RecordD0X()
	METHOD UpdateD0X()
	METHOD ExcludeD0X()
	METHOD GetRecno()
	METHOD GetErro()
	
	METHOD SetEmbarq(Embarque)
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEndereco)
	METHOD SetStatus(cStatus)
	METHOD SetDatGer(dDatGer)
	METHOD SetHorGer(cHorGer)
	METHOD SetCodUsu(cCodUsu)
	METHOD SetTransp(cTransp)
	
	METHOD GetEmbarq()
	METHOD GetArmazem()
	METHOD GetEnder()
	METHOD GetStatus()
	METHOD GetDatGer()
	METHOD GetHorGer()
	METHOD GetCodUsu()
	METHOD GetTransp()
	
	METHOD FindEmbExp()
	METHOD LoadEmbExp()
	METHOD UpdStatus()
	METHOD EstEmbarque()
	METHOD CanEstEmb()
	METHOD CanExcEmb()
ENDCLASS
//-----------------------------------------
/*/{Protheus.doc} New
Metodo construtor
@author    Squad WMS/OMS Protheus
@since     12/12/2018
@version   1.0
/*/
//-----------------------------------------
METHOD New() CLASS WMSDTCEmbarqueExpedicao
	Self:cEmbarque  := PadR("",TamSx3("D0X_EMBARQ")[1])
	Self:cCodUsu    := PadR("",TamSx3("D0X_CODUSU")[1])
	Self:lD0XTransp := D0X->(ColumnPos("D0X_TRANSP")) > 0
	If Self:lD0XTransp
		Self:cTransp    := PadR("",TamSx3("D0X_TRANSP")[1])
	EndIf 
	
	Self:ClearData()
Return
//-----------------------------------------
/*/{Protheus.doc} ClearData
Inicializa os campos
@author    Squad WMS/OMS Protheus
@since     12/12/2018
@version   1.0
/*/
//-----------------------------------------
METHOD ClearData() CLASS WMSDTCEmbarqueExpedicao
	Self:cEmbarque := PadR("", Len(Self:cEmbarque))
	Self:cCodUsu   := PadR("", Len(Self:cCodUsu))
	If Self:lD0XTransp
		Self:cTransp   := PadR("", Len(Self:cTransp))
	EndIf
	Self:cStatus   := '1'
	Self:dDatGer   := dDatabase
	Self:cHorGer   := Time()
	Self:cErro     := ""
	Self:nRecno    := 0
Return
//-----------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto da memória
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD Destroy() CLASS WMSDTCEmbarqueExpedicao
	/*Mantido para compatibilidade*/
Return
//----------------------------------------
/*/{Protheus.doc} GoTD0X
Posicionamento para atualização das propriedades.
@author amanda.vieira
@since 15/06/2020
@version 1.0
@param nRecno, numérico, recno da tabela D0X
/*/
//----------------------------------------
METHOD GoToD0X(nRecno) CLASS WMSDTCEmbarqueExpedicao
	Self:nRecno := nRecno
Return Self:LoadData(0)
//-----------------------------------------
/*/{Protheus.doc} LoadData
Carregamento dos dados D0X
@author alexsander.correa
@since 13/12/2018
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-----------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCEmbarqueExpedicao
Local lRet        := .T.
Local aAreaAnt   := GetArea()
Local aAreaD0X    := D0X->(GetArea())
Local cAliasD0X   := GetNextAlias()
Local cSelect     := ""

Default nIndex := 1
	Do Case
		Case nIndex == 0
			If Empty(Self:nRecno)
				lRet := .F.
			EndIf
		Case nIndex == 1 // D0X_FILIAL_D0X_EMBARQ
			If Empty(Self:cEmbarque)
				lRet := .F.
			EndIf
		Otherwise
			lRet := .F.
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		cSelect := "%"
		If Self:lD0XTransp
			cSelect += ",D0X_TRANSP"
		EndIf
		cSelect += "%"
		

		cAliasD0X := GetNextAlias()
		Do Case
			Case nIndex == 0
				BeginSql Alias cAliasD0X
					SELECT D0X.D0X_EMBARQ,
							D0X.D0X_STATUS,
							D0X.D0X_DATGER,
							D0X.D0X_HORGER,
							D0X.D0X_CODUSU,
							D0X.R_E_C_N_O_ RECNOD0X
							%Exp:cSelect%
					 FROM %Table:D0X% D0X
					WHERE D0X.D0X_FILIAL = %xFilial:D0X%
					  AND D0X.R_E_C_N_O_ = %Exp:AllTrim(Str(Self:nRecno))%
					  AND D0X.%NotDel%
				EndSql
			Case nIndex == 1
				BeginSql Alias cAliasD0X
					SELECT D0X.D0X_EMBARQ,
							D0X.D0X_STATUS,
							D0X.D0X_DATGER,
							D0X.D0X_HORGER,
							D0X.D0X_CODUSU,
							D0X.R_E_C_N_O_ RECNOD0X
							%Exp:cSelect%
					 FROM %Table:D0X% D0X
					WHERE D0X.D0X_FILIAL = %xFilial:D0X%
					  AND D0X.D0X_EMBARQ = %Exp:Self:cEmbarque%
					  AND D0X.%NotDel%
				EndSql
		EndCase
		TcSetField(cAliasD0X,'D0X_DATGER','D')
		If (lRet := (cAliasD0X)->(!Eof()))
			// Dados adicionais
			Self:cEmbarque := (cAliasD0X)->D0X_EMBARQ
			Self:cStatus   := (cAliasD0X)->D0X_STATUS
			If Self:lD0XTransp
				Self:cTransp   := (cAliasD0X)->D0X_TRANSP
			EndIf
			Self:dDatGer   := (cAliasD0X)->D0X_DATGER
			Self:cHorGer   := (cAliasD0X)->D0X_HORGER
			Self:cCodUsu   := (cAliasD0X)->D0X_CODUSU
			Self:nRecno    := (cAliasD0X)->RECNOD0X
		EndIf
		(cAliasD0X)->(dbCloseArea())
	EndIf
	RestArea(aAreaD0X)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------------
/*/{Protheus.doc} RecordD0X
Criação da capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD RecordD0X() CLASS WMSDTCEmbarqueExpedicao
Local lRet     := .T.
	Self:cEmbarque := GetSX8Num('D0X','D0X_EMBARQ'); IIf(__lSX8,ConfirmSX8(),)
	Self:cStatus   := "1"
	Self:dDatGer   := dDataBase
	Self:cHorGer   := Time()
	Self:cCodUsu   := __cUserID
	// Grava D1
	D0X->(dbSetOrder(1))
	If !D0X->(dbSeek(xFilial("D0X")+Self:cEmbarque))
		RecLock('D0X', .T.)
		D0X->D0X_FILIAL := xFilial("D0X")
		D0X->D0X_EMBARQ := Self:cEmbarque
		D0X->D0X_STATUS := Self:cStatus
		D0X->D0X_DATGER := Self:dDatGer
		D0X->D0X_HORGER := Self:cHorGer
		D0X->D0X_CODUSU := Self:cCodUsu
		If Self:lD0XTransp
			D0X->D0X_TRANSP := Self:cTransp
		EndIf 
		D0X->(MsUnLock())
		// Grava recno
		Self:nRecno := D0X->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0002 // Chave duplicada! 
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} UpdateD0X
Atualiza da capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD UpdateD0X() CLASS WMSDTCEmbarqueExpedicao
Local lRet    := .T.
	// Grava D1
	If !Empty(Self:GetRecno())
		D0X->(dbGoTo( Self:GetRecno() ))
		Self:cStatus := Self:UpdStatus()
		RecLock('D0X', .F.)
		D0X->D0X_STATUS := Self:cStatus
		If Self:lD0XTransp
			D0X->D0X_TRANSP := Self:cTransp
		EndIf
		D0X->(MsUnLock())
		// Grava recno
		Self:nRecno := D0X->(Recno())
	Else
		lRet := .F.
		Self:cErro := STR0003 // Dados não encontrados!
	EndIf
Return lRet
//-----------------------------------------
/*/{Protheus.doc} ExcludeD0X
Exclui a capa do embarque
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD ExcludeD0X() CLASS WMSDTCEmbarqueExpedicao
Local lRet := .T.
	D0X->(dbGoTo( Self:GetRecno() ))
	// Excluindo a capa do embarque de expedição
	RecLock('D0X', .F.)
	D0X->(dbDelete())
	D0X->(MsUnlock())
Return lRet
//-----------------------------------------
/*/{Protheus.doc} UpdStatus
Avalia situação do embarque de expedição
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD UpdStatus() CLASS WMSDTCEmbarqueExpedicao
Local aTamSx3   := TamSx3("D0Z_QTDEMB")
Local aAreaAnt  := GetArea()
Local cAliasD0Z := GetNextAlias()
Local cStatus   := "1"
	// ----------nAcao-----------
	// Totalizador dos itens da conferencia
	BeginSql Alias cAliasD0Z
		SELECT SUM(D0Z.D0Z_QTDORI) D0Z_QTDORI,
			SUM(D0Z.D0Z_QTDEMB) D0Z_QTDEMB
		FROM %Table:D0Z% D0Z
		WHERE D0Z.D0Z_FILIAL = %xFilial:D0Z%
		AND D0Z.D0Z_EMBARQ = %Exp:Self:cEmbarque%
		AND D0Z.%NotDel%
	EndSql
	TcSetField(cAliasD0Z,'D0Z_QTDORI','N',aTamSX3[1],aTamSX3[2])
	TcSetField(cAliasD0Z,'D0Z_QTDEMB','N',aTamSX3[1],aTamSX3[2])
	If (cAliasD0Z)->(!Eof())
		If QtdComp((cAliasD0Z)->D0Z_QTDEMB) == 0
			cStatus := "1"
		ElseIf QtdComp((cAliasD0Z)->D0Z_QTDORI) == QtdComp((cAliasD0Z)->D0Z_QTDEMB)
			cStatus := "3"
		Else
			cStatus := "2"
		EndIf
	EndIf
	(cAliasD0Z)->(dbCloseArea())
	RestArea(aAreaAnt)
Return cStatus
//-----------------------------------------
// Setter
//-----------------------------------------
METHOD SetEmbarq(cEmbarque) CLASS WMSDTCEmbarqueExpedicao
	Self:cEmbarque := PadR(cEmbarque, Len(Self:cEmbarque))
Return

METHOD SetStatus(cStatus) CLASS WMSDTCEmbarqueExpedicao
	Self:cStatus := PadR(cStatus, Len(Self:cStatus))
Return

METHOD SetDatGer(dDatGer) CLASS WMSDTCEmbarqueExpedicao
	Self:dDatGer := PadR(dDatGer, Len(Self:dDatGer))
Return

METHOD SetHorGer(cHorGer) CLASS WMSDTCEmbarqueExpedicao
	Self:cHorGer := cHorGer
Return

METHOD SetCodUsu(cCodUsu) CLASS WMSDTCEmbarqueExpedicao
	Self:cCodUsu := PadR(cCodUsu, Len(Self:cCodUsu))
Return
METHOD SetTransp(cTransp) CLASS WMSDTCEmbarqueExpedicao
	Self:cTransp := cTransp
Return
//-----------------------------------------
// Getter
//-----------------------------------------
METHOD GetEmbarq() CLASS WMSDTCEmbarqueExpedicao
Return Self:cEmbarque

METHOD GetStatus() CLASS WMSDTCEmbarqueExpedicao
Return Self:cStatus

METHOD GetDatGer() CLASS WMSDTCEmbarqueExpedicao
Return Self:dDatGer

METHOD GetHorGer() CLASS WMSDTCEmbarqueExpedicao
Return Self:cHorGet

METHOD GetCodUsu() CLASS WMSDTCEmbarqueExpedicao
Return Self:cCodUsu

METHOD GetTransp() CLASS WMSDTCEmbarqueExpedicao
Return Self:cTransp

METHOD GetRecno() CLASS WMSDTCEmbarqueExpedicao
Return Self:nRecno

METHOD GetErro() CLASS WMSDTCEmbarqueExpedicao
Return Self:cErro
//-----------------------------------------
/*/{Protheus.doc} FindEmbExp
Busca embarque de expedição
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
/*/
//-----------------------------------------
METHOD FindEmbExp() CLASS WMSDTCEmbarqueExpedicao
Local lRet      := .T.
Local cAliasD0X := GetNextAlias()
	BeginSql Alias cAliasD0X
		SELECT D0X.D0X_STATUS
		FROM %Table:D0X% D0X
		WHERE D0X.D0X_FILIAL = %xFilial:D0X%
		AND D0X.D0X_EMBARQ = %Exp:Self:cEmbarque%
		AND D0X.%NotDel%
	EndSql
	If (cAliasD0X)->(Eof())
		Self:cErro := WmsFmtMsg(STR0004,{{"[VAR01]",Self:cEmbarque}}) // Embarque de expedição [VAR01] não cadastrado.
		lRet := .F.
	ElseIf !((cAliasD0X)->D0X_STATUS $ '1|2')
		Self:cErro := WmsFmtMsg(STR0006,{{"[VAR01]",Self:cEmbarque}}) // Embarque de expedição [VAR01] encerrado!
		lRet := .F.
	EndIf
	(cAliasD0X)->(dbCloseArea())
Return lRet
//-----------------------------------------
/*/{Protheus.doc} LoadEmbExp
Busca embarque de expedição pendentes
@author Squad WMS/OMS Protheus
@since 13/12/2018
@version 1.0
@param aEmbarque, array, array de embarques pendentes
/*/
//-----------------------------------------
METHOD LoadEmbExp() CLASS WMSDTCEmbarqueExpedicao
Local cAliasD0X := GetNextAlias()
	aEmbarque := {}
	BeginSql Alias cAliasD0X
		SELECT D0X.D0X_EMBARQ,
				D0X.D0X_DATGER
		FROM %Table:D0X% D0X
		WHERE D0X_FILIAL = %xFilial:D0X%
		AND D0X_STATUS IN ('1','2')
		AND D0X.%NotDel%
	EndSql
	TCSetField(cAliasD0X,'DCW_DATGER','D',)
	Do While !(cAliasD0X)->( Eof() )
		Aadd(aEmbarque,{(cAliasD0X)->D0X_EMBARQ,(cAliasD0X)->D0X_DATGER})
		(cAliasD0X)->( DBSkip() )
	EndDo
	(cAliasD0X)->( DBCloseArea() )
Return aEmbarque
/*/{Protheus.doc} CanExcEmb
Verifica se embarque pode ser excluído
@author amanda.vieira
@since 15/06/2020
@return lRet, lógico, se retorno igual à true indica que o embarque pode ser excluído
/*/
METHOD CanExcEmb() CLASS WMSDTCEmbarqueExpedicao
Local lRet := .T.
	If !(Self:cStatus == "1")
		Self:cErro := STR0007 //Status do embarque não permite exclusão. Primeiro realize os estornos.
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} CanEstEmb
Verifica se embarque pode ser estornado
@author amanda.vieira
@since 15/06/2020
@return lRet, lógico, se retorno igual à true indica que o embarque pode ser estornado
/*/
METHOD CanEstEmb() CLASS WMSDTCEmbarqueExpedicao
Local lRet := .T.
	If (Self:cStatus == "1")
		Self:cErro := STR0008 //O embarque já encontra-se estornado.
		lRet := .F.
	EndIf
Return lRet
/*/{Protheus.doc} EstEmbarque
Estorna toda a quantidade embarcada do embarque posicionado no objeto
@author amanda.vieira
@since 15/06/2020
@return lRet, lógico, se retorno igual à true indica que o embarque foi estornado
/*/
METHOD EstEmbarque() CLASS WMSDTCEmbarqueExpedicao
Local cAliasD0Z   := GetNextAlias()
Local oEstEmbItem := Nil
Local lRet        := .T.
	If (lRet := Self:CanEstEmb())
		oEstEmbItem := WMSDTCEmbarqueExpedicaoItens():New()
		//Descarta os produtos 'pai' da query, pois estes serão alterados nos updates dos filhos
		BeginSql Alias cAliasD0Z
			SELECT R_E_C_N_O_ RECNOD0Z
			  FROM %Table:D0Z% D0ZA
			 WHERE D0ZA.D0Z_FILIAL = %xFilial:D0Z%
			   AND D0ZA.D0Z_EMBARQ = %Exp:Self:cEmbarque%
			   AND D0ZA.D0Z_STATUS <> '1'
			   AND NOT EXISTS (SELECT 1
								 FROM %Table:D0Z% D0ZB
								 WHERE D0ZB.D0Z_FILIAL = D0ZA.D0Z_FILIAL
								   AND D0ZB.D0Z_EMBARQ = D0ZA.D0Z_EMBARQ
								   AND D0ZB.D0Z_PRDORI = D0ZA.D0Z_PRODUT
								   AND D0ZB.D0Z_PRDORI <> D0ZB.D0Z_PRODUT
								   AND D0ZB.D0Z_STATUS <> '1'
								   AND D0ZB.%NotDel%)
			   AND D0ZA.%NotDel%
		EndSql
		While (cAliasD0Z)->(!EoF())
			oEstEmbItem:GoToD0Z((cAliasD0Z)->RECNOD0Z)
			If !(lRet := oEstEmbItem:EstEmbItem())
				Self:cErro := oEstEmbItem:GetErro()
			EndIf
			(cAliasD0Z)->(DbSkip())
		EndDo
		FreeObj(oEstEmbItem)
	EndIf
	(cAliasD0Z)->(DbCloseArea())

Return lRet
