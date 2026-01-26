#Include "LOCA229E.CH"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH "

/*/{Protheus.doc} MODELDEF
Define o model da Separação de A.S.
@type function
@version  25.10
@author Alexandre Circenis
@since 4/1/2025
@return variant, Modelo de dados
/*/
STATIC FUNCTION MODELDEF()
Local oModel   
Local oStrFQU  := FWFormStruct( 1, 'FQU', /*bAvalCampo*/,/*lViewUsado*/ )
Local cGrupos  := LOCA00189()
Local cGrpACes := {}

cGrpAces := "('"+ StrTran( cGrupos, ";", "','" ) +"')"

oModel := MPFormModel():New( 'LOCA259E', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'MASTER', /*cOwner*/, oStrFQU, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel := Loca529EMD(oModel)

oModel:SetRelation( 'FQ5BEM', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_XROMAN","FQU_NUM"}, {"FQ5_STATUS" , "1"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FQ5QTD', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_XROMAN","FQU_NUM"}, {"FQ5_STATUS" , "1"}}, FQ5->( IndexKey( 22 ) ) )

oModel:GetModel( 'FQ5BEM'):SetLoadFilter( , " EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ')" ) 
oModel:GetModel( 'FQ5QTD'):SetLoadFilter( , " NOT EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ' )" ) 
oModel:GetModel("RESUMO"):bLoad :=   {|oMdl| Local229ELG(oMdl,FQU->FQU_NUM) }
// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 )  //"Separação Romaneio"
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'MASTER' ):SetDescription( STR0002 )  //"Demanda" //"Romaneio"
 
oModel:GetModel( 'MASTER' ):SetOnlyView(.T.)

oModel:SetPrimaryKey({"FQU_FILIAL","FQU_NUM"})

Return oModel


//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@type Function 
@author Alexandre Circenis
@since  01/04/2025
@version 25.10
/*/	
Static Function ViewDef()
Local oView := FWFormView():New()
Local oModel := FWLoadModel("LOCA229E")
Local oStrFQU	:= FWFormStruct(2,'FQU', {|cCampo| cCampo $ "FQU_NUM    FQU_PROJET FQU_OBRA   "})

oStrFQU:SetProperty("FQU_NUM", MVC_VIEW_GROUP_NUMBER, "" )
oStrFQU:SetProperty("FQU_PROJET", MVC_VIEW_GROUP_NUMBER, "")
oStrFQU:SetProperty("FQU_OBRA", MVC_VIEW_GROUP_NUMBER, "")
oStrFQU:aGroups := {}

oView:SetModel( oModel )

oView:AddField("VIEW_MASTER",oStrFQU,"MASTER")

oView := Loca529EVI(oView, oModel)
oView:SetViewAction("BUTTONOK", { |oView| Loca229EPR( oView ) } )
RETURN oView

/*/{Protheus.doc} Local229ELG
Retorna o array de dados dados para carga do Model de REsumoa dos itens com bens
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oGrid, object, Grid que será carregado
@param cDemanda, character, Demanda em processamento
@return variant, Array com os dados
/*/
Function Local229ELG(oGrid, cRomaneio)
Local aArea := GetArea()
Local aDados := {}
Local cQuery := ""
Local aBindParam := {}
Local cItem      := '001'
Local aLinha

cQuery += "SELECT FQ5_XPROD, SUM(FQ5_XQTD) FPA_QUANT, FPA_LOCAL"
cQuery += " FROM "+RetSqlName("FQ5")+ " FQ5"
cQuery += " INNER JOIN "+RetSqlName("FPA")+ " FPA"
cQuery += "  ON FPA_FILIAL = '"+xFilial("FPA")+"'"
cQuery += "  and FPA_AS = FQ5_AS "
cQuery += "  and FPA.D_E_L_E_T_ = ' '"
cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
cQuery += " AND FQ5_STATUS = '1'"
cQuery += " and FQ5_XROMAN = ?"
cQuery += " and Exists ( SELECT T9_CODESTO FROM "+RetSqlName("ST9")+ " ST9"
cQuery += "  WHERE T9_FILIAL = '"+xFilial("ST9")+"'"
cQuery += "  and T9_CODESTO = FQ5_XPROD "
cQuery += "  and ST9.D_E_L_E_T_ = ' ' )"
Aadd( aBindParam, cRomaneio)
cQuery += " GROUP BY  FQ5_XPROD, FPA_LOCAL"
cQuery += " ORDER BY  FQ5_XPROD, FPA_LOCAL"

cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,"FQ5TRB",,,aBindParam)

aLinha := {  }
While !(FQ5TRB->(Eof()))

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+FQ5TRB->FQ5_XPROD))

	Aadd(aLinha, cItem )   // Item
	Aadd(aLinha, FQ5TRB->FQ5_XPROD ) // Produto
	Aadd(aLinha, SB1->B1_DESC )  // Descricao
	Aadd(aLinha, SB1->B1_UM )    // Unidade
	Aadd(aLinha, FQ5TRB->FPA_QUANT ) // Quantidade
	Aadd(aLinha, FQ5TRB->FPA_LOCAL ) // Local
	Aadd(aLinha, Loca259EDB(FQ5TRB->FQ5_XPROD) )  // Disponival
	Aadd(aLinha, Loca229EEM(cRomaneio, FQ5TRB->FQ5_XPROD, .T.) ) // Empenhada Demanda
	Aadd(aLinha, Loca229EEM(cRomaneio, FQ5TRB->FQ5_XPROD, .F.) ) // Empenhada Outras demanda
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )
	Aadd(aLinha, 0 )

	Aadd( aDados, { 0 , aLinha })

	FQ5TRB->(dbSkip())
	cItem  := Soma1(cItem)
	aLinha := {}

enddo

FQ5TRB->(dbCloseArea())
RestArea(aArea)

Return aDados


/*/{Protheus.doc} Loca229EEM
REtorna a quantidade de um produto empenhada na demanda ou em outras demandas
@type function
@version 25.10
@author Alexandre Circenis
@since 4/1/2025
@param cRomaneio, character, Romaneio analisado
@param cProduto, character, Produto Analisado
@param lNaDemanda, logical, Emepnhado na Demanda (.T.) ou em outras demandas (.F.)
@return variant, Quantidade empenhada
/*/
FUNCTION Loca229EEM(cRomaneio, cProduto, lNaDemanda)
Local nEmpenhada := 0
Local cQuery := ''
Local aArea := GetArea()
Local aBindParam := {}

cQuery := " SELECT SUM(FQ5_XQTD) EMPENHADA"
cQuery += " FROM "+RetSqlName("FQ5")
cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+ "'"
cQuery += " AND FQ5_XPROD = ?"
Aadd(aBindParam, cProduto)
if lNaDemanda 
	cQuery += " AND FQ5_XROMAN = ?"
else
	cQuery += " AND FQ5_XROMAN <> ?"
endif	
cQuery += " AND FQ5_DEMAND <> ' '"
cQuery += " AND FQ5_STATUS = '6'" // Considerar empenhada as A.S. Separada/Aceita

Aadd(aBindParam, cRomaneio)
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,"FQ5EMP",,,aBindParam)

if !FQ5EMP->(Eof())
	nEmpenhada := FQ5EMP->EMPENHADA
endif

FQ5EMP->(dbCloseArea())
RestArea(aArea)

Return nEmpenhada



/*/{Protheus.doc} Loca229EPR
Realiza o processamento do Model
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oModel, object, Modelo dados processado
@return variant, Indica se a troca foi realizada com sucesso (.T.)
/*/
Function Loca229EPR(oModel)
Local oGridMaq := oModel:GetModel("FQ5BEM")
Local oGrid := oModel:GetModel("FQ5QTD")
Local aAlteradas := {}
Local nX
Local cPara := GETMV("MV_LOCX033",,"")
Local cMsg  := ""
Local cMV_LOC248 := GetMV("MV_LOCX248")
Local _LC111TIT := EXISTBLOCK("LC111TIT")
Local _LC111USR := EXISTBLOCK("LC111USR")
Local nAceitas := 0
Local nRejeita := 0
Local cTitulo := STR0003 //"A.S. Separadas"
Local aRomaneios := {}
Local aArea := GetArea()

PRIVATE _NTPACE	:= 0
PRIVATE cServ   := 'L' // Private usada no aceite da A.S.
//PRIVATE NTOTMIN := 0						// PARA RETORNAR O NUMERO DE MINUTAS CRIADAS
private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)

if !Empty(cPara)
	IF _LC111TIT //EXISTBLOCK("LC111TIT")
		cTitulo := EXECBLOCK("LC111TIT", .T., .T., {_NTPACE, FQT->FQT_PROJET})
	ELSE
		cTitulo := STR0004 + cMV_LOC248 + ": " + ALLTRIM(FQT->FQT_PROJET) //"Referente ao aceite da(s) AS(s) "
	ENDIF

	CMSG := CTITULO + CRLF + CRLF + CMSG + CRLF

	IF _LC111USR // EXISTBLOCK("LC111USR")
		cMsg += EXECBLOCK("LC111USR", .T., .T., {_NTPACE, "A"}) + CRLF + CRLF
	ENDIF

endif

// Trocar e/ou separar o Grid de Maquinas
aAlteradas := oGridMaq:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGridMaq:Goline(aAlteradas[ nX])

	FQ5->(dbGoTo(oGridMaq:GetDataID()))
	
	if !Empty(oGridMaq:GetValue('GRUANEW')) // Tem Novo equipamento definido Realizar a troca

		LOCA259ETR()

	endif

	FQ5->(dbGoTo(oGridMaq:GetDataID()))
	
	if oGridMaq:GetValue('MARK') // Marcado realizar a separação "ACEITE"
		
		LOCA05908("LOTE")

		if FQ5->FQ5_STATUS = '6'
		
			RecLock("FQ5", .F.)
			FQ5->FQ5_STDEMA := '2'
			FQ5->(msUnlock())
		
			// Verificar se está no romaneio e ajustar
			IF !Empty(FQ5->FQ5_XROMAN)
				FQV->(dbSetOrder(2))
				if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
					RecLock("FQV", .F.)
					FQV->FQV_STATUS := FQ5->FQ5_STATUS
					msUnLock()
					if Len(aRomaneios) = 0 .or. aScan(aRomaneios,FQ5->FQ5_XROMAN) = 0
					 Aadd(aRomaneios, FQ5->FQ5_XROMAN)
					endif   
				endif

			endif
		
			if !Empty(cPara)
				cMsg += STR0005 + ALLTRIM(FQ5->FQ5_AS) + ", " + cMV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //STR0005 //"Referente a separação da AS número "
				cMsg += STR0007+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0008+ALLTRIM(FQ5->FQ5_DESTIN)+STR0006+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF //STR0007 //" Cliente: " //"Data INI/FIM: " //" Destino: "
			endif
		else
			nRejeita++
		endif

	endif

next
// Trocar e/ou separar o Grid de Acessorios
aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGrid:Goline(aAlteradas[ nX])
	
	FQ5->(dbGoTo(oGrid:GetDataID()))
	
	// Se quantidade separa for diferente da quantidade origem realizar o fracionamento	
	if !Empty(oGrid:GetValue('QTDNEW')) .and. oGrid:GetValue('QTDNEW') <> oGrid:GetValue('FQ5_XQTD')
		// Realizar p Fracionamento da A.S.
		Loca259BFR(FQ5->(Recno()), oGrid, .T.) 
		
	endif

	FQ5->(dbGoTo(oGrid:GetDataID()))

	if oGrid:GetValue('MARK') // Marcado realizar a separação "ACEITE"

		LOCA05908("LOTE")

		if FQ5->FQ5_STATUS = '6'
			nAceitas++
		
			RecLock("FQ5", .F.)
			FQ5->FQ5_STDEMA := '2'
			FQ5->(msUnlock())
			
			// Verificar se está no romaneio e ajustar
			IF !Empty(FQ5->FQ5_XROMAN)
				FQV->(dbSetOrder(2))
				if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
					RecLock("FQV", .F.)
					FQV->FQV_STATUS := FQ5->FQ5_STATUS
					msUnLock()
					if Len(aRomaneios) = 0 .or. aScan(aRomaneios,FQ5->FQ5_XROMAN) = 0
					 Aadd(aRomaneios, FQ5->FQ5_XROMAN)
					endif   
				endif
			endif

			if !Empty(cPara)
				cMsg += STR0005 + ALLTRIM(FQ5->FQ5_AS) + ", " + cMV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF  //"Referente a separação da AS número "
				cMsg += STR0007+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0008+ALLTRIM(FQ5->FQ5_DESTIN)+STR0009+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF  //" Destino: " //"Cliente: " //"Data INI/FIM: "
			endif
		else
			nRejeita++
		endif

	endif

next

// Processar o romaneios para marcar as separações
For nX := 1 to Len(aRomaneios)
	FQU->(dbSetOrder(1))
	FQU->(dbSeek(xFilial("FQU")+aRomaneios[nX]))
	if Loca259ESP(aRomaneios[nX])
		RecLock("FQU", .F.)
		FQU->FQU_STATUS := '3'
		MsUnlock()
	endif

next nX

if nAceitas > 0
	Aviso(cTitulo, STR0010+Alltrim(Transform( nAceitas, "@E 9,999,999"))+;  //"Foram separadas "
	 STR0012+Alltrim(Transform( nRejeita, "@E 9,999,999"))+STR0011, {"Ok"})  //" A.S." //" e rejeitadas "
endif

RestArea(aArea)

RETURN .T.
