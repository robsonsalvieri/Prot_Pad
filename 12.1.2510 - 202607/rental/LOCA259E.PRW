#Include "LOCA259E.CH"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"

/*/{Protheus.doc} MODELDEF
Define o model da Separação de A.S.
@type function
@version  25.10
@author Alexandre Circenis
@since 4/1/2025
@return variant, Modelo de dados
/*/
STATIC FUNCTION MODELDEF()
Local oStrFQT  := FWFormStruct( 1, 'FQT', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local cGrupos  := LOCA00189()
Local cGrpACes := {}

cGrpAces := "('"+ StrTran( cGrupos, ";", "','" ) +"')"

oModel := MPFormModel():New( 'LOCA259E', /*bPreValidacao*/, {|oModel| Loca259EVO( oModel)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'MASTER', /*cOwner*/, oStrFQT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel := LOCA259EMD(oModel)
oModel:SetRelation( 'FQ5BEM', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","FQT_DEMAND"}, {"FQ5_STATUS" , "'1'"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FQ5QTD', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","FQT_DEMAND"}, {"FQ5_STATUS" , "'1'"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FQ5PAT', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","FQT_DEMAND"}, {"FQ5_STATUS" , "'1'"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FH2QTD', { { 'FH2_FILIAL', 'xFilial("FH2")' } ,{"FH2_AS","FQ5_AS"}}, FH2->( IndexKey( 1 ) ) )
oModel:GetModel("RESUMO"):bLoad :=   {|oMdl| Loca259ELG(oMdl,FQT->FQT_DEMAND) }
oModel:GetModel("FH2QTD"):bLoad :=   {|oMdl| Loca259ELP(oMdl, oModel) }

oModel:SetPrimaryKey({"FQT_FILIAL","FQT_DEMAND"})
oModel:GetModel( 'MASTER' ):SetDescription( STR0025 )  //"Demanda"
oModel:GetModel("FH2QTD"):SetLPre({|oGrid,nLinha,cAcao| Loca259LPV(oGrid,nLinha,cAcao)})

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
Local oView	:= FWFormView():New()
Local oModel := FWLoadModel("LOCA259E")
Local oStrFQT	:= FWFormStruct(2,'FQT', {|cCampo| cCampo $ "FQT_DEMAND FQT_PROJET FQT_OBRA   "})

oView:SetProgressBar(.T.)

oStrFQT:SetProperty("FQT_DEMAND", MVC_VIEW_GROUP_NUMBER, " " )
oStrFQT:SetProperty("FQT_PROJET", MVC_VIEW_GROUP_NUMBER, " ")
oStrFQT:SetProperty("FQT_OBRA", MVC_VIEW_GROUP_NUMBER, " ")

//
oView:SetModel( oModel )

oView:AddField("VIEW_MASTER",oStrFQt,"MASTER")
	
oView:SetViewProperty( "VIEW_MASTER", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 5 } )

oView := Loca259EVI(oView, oModel)
//
oView:SetOwnerView('VIEW_MASTER', 'CAB') 
oView:SetViewAction("BUTTONOK", { |oView| Loca259EPR( oView ) } )

RETURN oView

/*/{Protheus.doc} Loca259EEM
REtorna a quantidade de um produto empenhada na demanda ou em outras demandas
@type function
@version 25.10
@author Alexandre Circenis
@since 4/1/2025
@param cDemanda, character, Demanda analisada
@param cProduto, character, Produto Analisado
@param lNaDemanda, logical, Emepnhado na Demanda (.T.) ou em outras demandas (.F.)
@return variant, Quantidade empenhada
/*/
FUNCTION Loca259EEM(cDemanda, cProduto, lNaDemanda)
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
	cQuery += " AND FQ5_DEMAND = ?"
else
	cQuery += " AND FQ5_DEMAND <> ?"
	cQuery += " AND FQ5_DEMAND <> ' '"
endif	
cQuery += " AND FQ5_STATUS = '6'" // Considerar empenhada as A.S. Separada/Aceita

Aadd(aBindParam, cDemanda)
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
MPSysOpenQuery(cQuery,"FQ5EMP",,,aBindParam)

if !FQ5EMP->(Eof())
	nEmpenhada := FQ5EMP->EMPENHADA
endif

FQ5EMP->(dbCloseArea())
RestArea(aArea)

Return nEmpenhada

/*/{Protheus.doc} Loca259ELG
Retorna o array de dados usdado para carga do Model de REsumoa dos itens com bens
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oGrid, object, Grid que será carregado
@param cDemanda, character, Demanda em processamento
@return variant, Array com os dados
/*/
Function Loca259ELG(oGrid, cDemanda)
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
	cQuery += " and FQ5_DEMAND = ?"
	Aadd( aBindParam, cDemanda)
	cQuery += " and Exists ( SELECT T9_CODESTO FROM "+RetSqlName("ST9")+ " ST9"
	cQuery += "  WHERE T9_FILIAL = '"+xFilial("ST9")+"'"
	cQuery += "  and T9_CODESTO = FQ5_XPROD "
	cQuery += "  and ST9.D_E_L_E_T_ = ' ' )"
	cQuery += " and  NOT EXISTS ( SELECT B1_COD FROM "+RetSqlName("SB1") + " SB1"  
	cQuery += "   INNER JOIN "+RetSqlName("SBM") + " SBM"  
	cQuery += "   ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3'and SBM.D_E_L_E_T_ = ' '
	cQuery += "   WHERE B1_FILIAL = '"+xFilial("SB1")+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ' )"

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
		Aadd(aLinha, Loca259EDB(FQ5TRB->FQ5_XPROD) )  // Disponivel
		Aadd(aLinha, Loca259EEM(cDemanda, FQ5TRB->FQ5_XPROD, .T.) ) // Empenhada Demanda
		Aadd(aLinha, Loca259EEM(cDemanda, FQ5TRB->FQ5_XPROD, .F.) ) // Empenhada Outras demanda
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
/*/{Protheus.doc} Loca259EDB
Retorna a quantidade de bens disponivies 
@type function
@version 25.10
@author Alexandre Circenis
@since 4/1/2025
@param cProduto, character, Produto de estoque 
@return variant, Quantidade Disponivel
/*/
Function Loca259EDB(cProduto)
Local nDisp := 0
Local aArea := GetArea()
Local cQuery := "" 
Local aBindParam := {}

	cQuery := "SELECT Count(T9_CODESTO) CONTAGEM"
	cQuery += " FROM "+RetSqlName("ST9")+" ST9"
	cQuery += " WHERE T9_FILIAL = '"+xFilial("ST9")+"'"
	cQuery += "  AND T9_CODESTO = ? " // Produto que está sendo locado
	Aadd(aBindParam, cProduto)
	cQuery += "  AND T9_STATUS = '00' " // Status 00 => Bem disponivel
	cQuery += "  AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"ST9TRB",,,aBindParam)

	nDisp += ST9TRB->CONTAGEM 

	ST9TRB->(dbCloseArea())
	RestArea(aArea)

return nDisp

/*/{Protheus.doc} Loca259EPR
Realiza o processamento do Model
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oModel, object, Modelo dados processado
@return variant, Indica se a troca foi realizada com sucesso (.T.)
/*/
Function Loca259EPR(oModel, lRomaneio)
Local oGridMaq := oModel:GetModel("FQ5BEM")
Local oGrid := oModel:GetModel("FQ5QTD")
Local oGridPAT := oModel:GetModel("FQ5PAT")

Local aAlteradas := {}
Local nX
//Local cPara := GETMV("MV_LOCX033",,"")
//Local cMsg  := ""
//Local cMV_LOC248 := GetMV("MV_LOCX248")
//Local lC111Tit := EXISTBLOCK("LC111TIT")
//Local lC111Usr := EXISTBLOCK("LC111USR")
Local nAceitas := 0
Local nRejeita := 0
Local cTitulo := STR0067 //"A.S. Separadas"
Local aRomaneios := {}
Local aArea := GetArea()
Local nY
Local lOk := .T.
Local lEmbFecha
Local aPH2Lst
Local aPH2Item

PRIVATE nTpAce	:= 0
PRIVATE cServ   := 'L' // Private usada no aceite da A.S.
//PRIVATE NTOTMIN := 0						// PARA RETORNAR O NUMERO DE MINUTAS CRIADAS
private lImplemento := LOCA059B1("FQG_FILIAL", "FQG") .and. GETMV("MV_NG1LOC",,.F.)
Private cLocErro    := ""
Private lLocAuto    := .T.

DEFAULT lRomaneio := .F.

	BEGIN TRANSACTION

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
				
				LOCA05908("LOTE", .T.)
				if !Empty(cLocErro)
					Help(" ",1,"LOCA259E_SEP1",, cLocErro,1,0)
					lOk := .F.
					DisarmTransaction()
					BREAK
				endif

				if FQ5->FQ5_STATUS = '6'

					RecLock("FQ5", .F.)
					FQ5->FQ5_STDEMA := '2'
					FQ5->(msUnlock())
				
					nAceitas++

					if !lRomaneio
						RecLock("FQT", .F.)
						FQT->FQT_SEPARA := FQT->FQT_SEPARA + FQ5->FQ5_XQTD
						FQT->FQT_PENDEN := FQT->FQT_PENDEN - FQ5->FQ5_XQTD
						msUnlock()
					endif

					// Verificar se está no romaneio e ajustar
					IF !Empty(FQ5->FQ5_XROMAN)
						lEmbFecha := Posicione("FQU",1, xFilial("FQU")+FQ5->FQ5_XROMAN, "FQU_FCHEMB") == '1'
						FQV->(dbSetOrder(2))
						if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
							RecLock("FQV", .F.)
							FQV->FQV_STATUS := if( lEmbFecha, "4",FQ5->FQ5_STATUS)
							msUnLock()
							if Len(aRomaneios) = 0 .or. aScan(aRomaneios,FQ5->FQ5_XROMAN) = 0
							Aadd(aRomaneios, FQ5->FQ5_XROMAN)
							endif   
						endif

					endif

				else
					nRejeita++
				endif

			endif

		next

		// Trocar e/ou separar o Grid de Maquinas Patrimonial
		aAlteradas := oGridPat:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

		For nX := 1 to Len(aAlteradas)

			oGridPat:Goline(aAlteradas[ nX])
			
			FQ5->(dbGoTo(oGridPat:GetDataID()))
			
			// Se quantidade separa for diferente da quantidade origem realizar o fracionamento	
			if !Empty(oGridPat:GetValue('QTDNEW')) .and. oGridPat:GetValue('QTDNEW') <> oGridPat:GetValue('FQ5_XQTD')
				// Realizar p Fracionamento da A.S.
				Loca259BFR(FQ5->(Recno()), oGridPat, lRomaneio)
				if !lRomaneio
					// Incrementar o itens
					RecLock("FQT", .F.)
					FQT->FQT_ITENS := FQT->FQT_ITENS + 1
					msUnlock()
				endif
			endif

			oGridPat:Goline(aAlteradas[ nX])
			FQ5->(dbGoTo(oGridPat:GetDataID()))

			if !Empty(oGridPat:GetValue('QTDNEW')) // Marcado realizar a separação "ACEITE"

				LOCA05908("LOTE", .T.)
				if !Empty(cLocErro)
					Help(" ",1,"LOCA259E_SEP2",, cLocErro,1,0)
					lOk := .F.
					DisarmTransaction()
					BREAK
				endif

				if FQ5->FQ5_STATUS = '6'
				
					RecLock("FQ5", .F.)
					FQ5->FQ5_STDEMA := '2'
					FQ5->(msUnlock())
				
					nAceitas++
					if !lRomaneio
						RecLock("FQT", .F.)
						FQT->FQT_SEPARA := FQT->FQT_SEPARA + FQ5->FQ5_XQTD
						FQT->FQT_PENDEN := FQT->FQT_PENDEN - FQ5->FQ5_XQTD
						msUnLock()
					endif

					// Verificar se está no romaneio e ajustar
					IF !Empty(FQ5->FQ5_XROMAN)
						FQV->(dbSetOrder(2))
						if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
							lEmbFecha := Posicione("FQU",1, xFilial("FQU")+FQ5->FQ5_XROMAN, "FQU_FCHEMB") == '1'
							RecLock("FQV", .F.)
							FQV->FQV_STATUS := if( lEmbFecha, "4",FQ5->FQ5_STATUS)
							msUnLock()
							if Len(aRomaneios) = 0 .or. aScan(aRomaneios,FQ5->FQ5_XROMAN) = 0
							Aadd(aRomaneios, FQ5->FQ5_XROMAN)
							endif   
						endif
					endif
					/* Não enviamos email
					if !Empty(cPara)
						cMsg += STR0069 + ALLTRIM(FQ5->FQ5_AS) + ", " + cMV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente a separação da AS número "
						cMsg += STR0070+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0071+ALLTRIM(FQ5->FQ5_DESTIN)+STR0072+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF //"Data INI/FIM: "
					endif */
		//		else
		//			nRejeita++
				endif
				FPA->(dbSetOrder(3))
				FPA->(dbSeek(xFilial("FPA")+oGridPat:GetValue("FQ5_AS")))
				// ISSUE: DSERLOCA-12374 - luipazini - 12/06/2026 - Correcao gravacao FH2 para todos itens SBM_XACESS=3
				aPH2Lst := Loca259EGA(2)
				For nY := 1 to Len(aPH2Lst)
					aPH2Item := aPH2Lst[nY]
					if aPH2Item[2] <> oGridPat:GetValue("FQ5_AS") .or. aPH2Item[7]
						Loop
					endif
					ST9->(dbSetOrder(1))
					ST9->(dbSeek(xFilial("ST9")+aPH2Item[6]))
					if FQD->(DBSEEK(XFILIAL("FQD")+ST9->T9_STATUS))
						if FQD->FQD_STAREN == "00"
							FQD->(DBGOTOP())
							while FQD->(!EOF())  .AND.  FQD->FQD_STAREN <> "10" 				// STATUS DE GERAR CONTRATO
								FQD->(DBSKIP())
							enddo
							if FQD->FQD_STAREN == "10"
								LOCXITU21(ST9->T9_STATUS,FQD->FQD_STATQY,FPA->FPA_PROJET,"","")
								RecLock("ST9",.F.)
								ST9->T9_STATUS := FQD->FQD_STATQY
								ST9->(MSUNLOCK())
							endif
						endif
					endif

			//Gravar FH2
					FH2->(RecLock("FH2",.T.))
					FH2->FH2_FILIAL := aPH2Item[1]
					FH2->FH2_AS     := aPH2Item[2]
					FH2->FH2_CONTRA := aPH2Item[3]
					FH2->FH2_OBRA   := aPH2Item[4]
					FH2->FH2_PROD   := aPH2Item[5]
					FH2->FH2_CODBEM := aPH2Item[6]
					FH2->FH2_ROMREM := FQ5->FQ5_XROMAN
					FH2->(MsUnLock())
					
				next nY

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
				Loca259BFR(FQ5->(Recno()), oGrid, lRomaneio)
				if !lRomaneio
					// Incrementar o itens
					RecLock("FQT", .F.)
					FQT->FQT_ITENS := FQT->FQT_ITENS + 1
					msUnLock()
				endif

			endif

			FQ5->(dbGoTo(oGrid:GetDataID()))

			if oGrid:GetValue('MARK') // Marcado realizar a separação "ACEITE"

				LOCA05908("LOTE", .T.)
				if !Empty(cLocErro)
					Help(" ",1,"LOCA259E_SEP3",, cLocErro,1,0)
					lOk := .F.
					DisarmTransaction()
					BREAK
				endif

				if FQ5->FQ5_STATUS = '6'
				
					RecLock("FQ5", .F.)
					FQ5->FQ5_STDEMA := '2'
					FQ5->(msUnlock())
				
					nAceitas++

					if !lRomaneio
						RecLock("FQT", .F.)
						FQT->FQT_SEPARA := FQT->FQT_SEPARA + FQ5->FQ5_XQTD
						FQT->FQT_PENDEN := FQT->FQT_PENDEN - FQ5->FQ5_XQTD
						msUnLock()
					endif
					
					// Verificar se está no romaneio e ajustar
					IF !Empty(FQ5->FQ5_XROMAN)
						FQV->(dbSetOrder(2))
						if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
							lEmbFecha := Posicione("FQU",1, xFilial("FQU")+FQ5->FQ5_XROMAN, "FQU_FCHEMB") == '1'
							RecLock("FQV", .F.)
							FQV->FQV_STATUS := if( lEmbFecha, "4",FQ5->FQ5_STATUS)
							msUnLock()
							if Len(aRomaneios) = 0 .or. aScan(aRomaneios,FQ5->FQ5_XROMAN) = 0
							Aadd(aRomaneios, FQ5->FQ5_XROMAN)
							endif   
						endif
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
			Aviso(cTitulo, STR0076+Alltrim(Transform( nAceitas, "@E 9,999,999"))+; //"Foram separadas "
			STR0079+Alltrim(Transform( nRejeita, "@E 9,999,999"))+STR0077, {STR0078}) //" A.S."
		endif

	END TRANSACTION

	RestArea(aArea)

	if !lOk
		oModel:lUpdateMsg := .F. /// Se tiver erro não apresentar mensagem de sucesso 
	endif

RETURN lOk

/*/{Protheus.doc} Loca05927
Filtro usado na consulta padrão ST9002
@type function
@version  25.10
@author Alexandre Circenis
@since 4/3/2025
@return variant, Se o produto for o mesmo da linha do grid e o bem for diferente
/*/
Function Loca05927()
Local lRet := .T. 

	lRet := ST9->T9_CODESTO = FwFldGet("FQ5_XPROD") .and. ST9->T9_CODBEM <> FwFldGet("FQ5_GUINDA")

return lRet

/*/{Protheus.doc} Loca259EVB
Validação do Campo de Nova Grua
@type function
@version 25.10
@author Alexandre Circenis
@since 4/1/2025
@return variant, Retorna de o codigo é valido ou não
/*/
Function Loca259EVB()
Local lRet := .T.
Local oModel   := FWModelActive()
Local oGrid
Local nLinha
Local nX

	dbSelectarea("ST9")
	dbSetOrder(1)

	if !dbSeek(xFilial("ST9")+M->GRUANEW)
		oModel:SetErrorMessage("","","","","LOCA259E_01",STR0080,)  //"Equipamento não cadastrado."
		lRet := .F.
	elseif ST9->T9_CODESTO <> FwFldGet("FQ5_XPROD")
		oModel:SetErrorMessage("","","","","LOCA259E_02",STR0081,)  //"O produto do Bem informado não o mesmo do contrato."
		lRet := .F.
	elseif ST9->T9_STATUS <> '00' .and. ST9->T9_STATUS <> '  '
		oModel:SetErrorMessage("","","","","LOCA259E_04",STR0082,)  //"O Bem informado não está com status disponivel."
		lRet := .F.

	else // Verificar se há duplicidade 
		oGrid := oModel:GetModel("FQ5BEM")
		nLinha := oGrid:GetLine()

		for nX := 1 to oGrid:Length()
			
			if nLinha <> nx .and. oGrid:GetValue("GRUANEW", nX) = M->GRUANEW
				oModel:SetErrorMessage("","","","","LOCA259E_03",STR0083+Alltrim(Str(nx,9,0)))  //"O Bem informado já foi utilizado na linha: "
				lRet := .F.
				exit
			endif
		next
		
	endif

Return lRet

/*/{Protheus.doc} LOCA259ETR
Realiza a troca de Bens
@type function
@version 25.10
@author Alexandre Circenis
@since 4/1/2025
/*/
FUNCTION LOCA259ETR()
LOCAL aArea    := GETAREA()
LOCAL aAreaZA5 := FP4->(GETAREA())
LOCAL aAreaST9 := ST9->(GETAREA())
LOCAL aAreaDTQ := FQ5->(GETAREA())
LOCAL aAreaSHB := SHB->(GETAREA())
Local cBemOld  := FQ5->FQ5_GUINDA // Bem Anterior
Local cTmpStat := '00'

	ST9->(DbSetOrder(1)) // RETorno ao indice por bem

	FPA->(dbSetOrder(3))
	FPA->( dbSeek( xFilial("FPA") + FQ5->FQ5_AS) )

	// Se for uma troca de Bem devolvemos o bem anterior para disponivel
	if !Empty(cBemOld)  

		// posicionar no novo bem 
		ST9->( DBSEEK( XFILIAL("ST9") + cBemOld ) )
		if !Empty(ST9->T9_STATUS)
			
			cTmpStat := "00"

			FQD->(dbSetOrder(1))
			FQD->(dbGotop())
			While !FQD->(Eof())
				If FQD->FQD_STAREN == "00" .and. !Empty(FQD->FQD_STATQY)
					cTmpStat := FQD->FQD_STATQY
				EndIF
				FQD->(dbSkip())
			EndDo
			FQD->(dbSetOrder(2))
			IF ST9->( DBSEEK( XFILIAL("ST9") + cBemOld) )
				LOCXITU21(ST9->T9_STATUS,cTmpStat,FQ5->FQ5_SOT,"","",.T.)
				RECLOCK("ST9",.F.)
				ST9->T9_STATUS := cTmpStat //"01" - atendimento ao card gerado pelo Rafael em 11/02/21 - Frank Fuga
				ST9->(MSUNLOCK())
			ENDIF
		endif	
	endif
		
	// Passa o novo BEm para o status de Contrato Gerado
	ST9->( DBSEEK( XFILIAL("ST9") +  FwFldGet("GRUANEW")) )
	if Empty(ST9->T9_STATUS)
		cTmpStat := '  '
	else

		FQD->(dbSetOrder(1))
		FQD->(dbGotop())
		While !FQD->(Eof())
			If FQD->FQD_STAREN == "10"
				cTmpStat := FQD->FQD_STATQY
			EndIF
			FQD->(dbSkip())
		EndDo
		FQD->(dbSetOrder(2))
	endif
		
	// ALOCA BEM NOVO
	LOCXITU21(ST9->T9_STATUS,cTmpStat,FQ5->FQ5_SOT,"","")

	RECLOCK("ST9",.F.)
	ST9->T9_STATUS := cTmpStat
	ST9->(MSUNLOCK())

	RECLOCK("FQ5",.F.)
	FQ5->FQ5_GUINDA := FwFldGet("GRUANEW")
	FQ5->(MSUNLOCK())

	IF FP0->FP0_TIPOSE == "L"
		DBSELECTAREA("ST9")
		ST9->( DBSETORDER(1) )
		ST9->(DBSEEK(XFILIAL("ST9") + FwFldGet("GRUANEW")))
		DBSELECTAREA("SHB")
		SHB->( DBSETORDER(1) )
		SHB->(DBSEEK(XFILIAL("SHB") + ST9->T9_CENTRAB))

		RECLOCK("FPA",.F.)
		FPA->FPA_GRUA	:= FwFldGet("GRUANEW")
		FPA->FPA_DESGRU	:= ALLTRIM(ST9->T9_NOME)
		IF SHB->(FIELDPOS("HB_XCCFAT")) > 0 // Avaliar a relevancia disso
			FPA->FPA_CUSTO	:= SHB->HB_XCCFAT
		ENDIF
		FPA->(MSUNLOCK())

	ENDIF

	// Buscar a linha do romaneio a AS que foi alterada
	FQV->(dbSetOrder(2))
	if FQV->(dbSeek(xFilial("FQV")+FQ5->FQ5_AS))
		RecLock("FQV", .F.)
		FQV->FQV_CODBEM := ST9->T9_CODBEM
		FQV->FQV_FAMBEM := ST9->T9_CODFAMI
		MsUnlock()
	endif

	RESTAREA(aAreaSHB)
	RESTAREA(aAreaDTQ)
	RESTAREA(aAreaST9)
	RESTAREA(aAreaZA5)
	RESTAREA(aArea)

RETURN 

/*/{Protheus.doc} LOCA259EBT
Botões de marcar e desmarcar todos
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/
Function LOCA259EBT(oPanel, cGrid)
Local oButton	:= Nil
Local oRadio	:= Nil
Local nRadio	:= 1
Local oModel as object
Local oView  as object

	//Inicializa variáveis
	oModel   	:= FWModelActive()
	oView    	:= FwViewActive()	
	@ 00, 05 Radio oRadio VAR nRadio ITEMS STR0084,STR0085 3D SIZE 100,10 OF oPanel PIXEL			//"Marcar todos"###"Desmarcar todos"
	@ 05, 80 BUTTON oButton PROMPT STR0088  SIZE 40,10 FONT oPanel:oFont ACTION MsgRun(STR0087,STR0086,{|| LOCA259EMA(oView,oModel,nRadio, cGrid)}) OF oPanel PIXEL //"Itens"

Return()
/*/{Protheus.doc} Loca259EMA
Rotina para processar a Marcação e Desmarcação dos itens da Grid
@type function
@version  25.10
@author Alexandre Circenis
@since 4/29/2025
@param oView, object, VIEW do model a ser processado
@param oModel, object, Model que será processado
@param nAcao, numeric, 1 = Marcacao ; 2 = Desmarcação
@param cGrid, character, Nome do grid que será marcado
/*/
Function Loca259EMA(oView,oModel,nAcao, cGrid)
Local nQtdFil   := Len(oView:GetViewObj(cGrid)[3]:GetFilLines())
Local cTextProc := ""

	If nAcao == 1
		cTextProc := STR0089 //"Marcação dos "
	Else
		cTextProc := STR0090 //"Desmarcação dos "
	Endif

	Processa({|| LOCA259EMK(oView, oModel, nAcao,cGrid)}, STR0091 + cTextProc + Alltrim(Str(nQtdFil)) + STR0092 ) //"Processando "

Return

/*/{Protheus.doc} LOCA259EMK
Processa a marcação/desmarcação
@type function
@version  25.10
@author Alexandre Circenis
@since 4/1/2025
@param oView, object,  VIew ativa
@param oModel, object, Model ativo
@param nAcao, numeric, 1 = Marca Todos; 2 = Desmarca todos
@param cGrid, character, Nome do grid que será processado
/*/
Function LOCA259EMK(oView, oModel, nAcao, cGrid)

Local nX	    AS Numeric	
Local lMarca   	AS Logical
Local nQtdTit
Local oGrid		:= oModel:GetModel(cGrid)

	nQtdTit := oGrid:Length()

	ProcRegua(nQtdTit)

	For nX:=1 To nQtdTit
		
		IncProc(STR0093 + Alltrim(Str(nX)))  //"Selecionando item"

		oGrid:GoLine(nX)
		lMarca := oGrid:GetValue("MARK")

		//Verificação para marcação
		If !lMarca .And. nAcao == 1 

			oGrid:SetValue("MARK",!lMarca) 
		
		ElseIf nAcao == 2

			oGrid:SetValue("MARK", .F.) 
		
		Endif		

	Next nX

	oGrid:GoLine(1)
	oView:Refresh() 

Return

/*/{Protheus.doc} Loca259ESP
Analisa os itens do Romaneio para verificar se só há itens separados
@type function
@version 25.10
@author Alexandre Circenis
@since 4/29/2025
@param cRomaneio, character, Romaneio a se analisado
@return variant, .t. se só há itens separados no romaneio
/*/
Function Loca259ESP(cRomaneio)
Local aArea := GetArea()
Local cQuery := "" 
Local aBindParam := {}
Local lRet := .F.
Local nSep := 0
Local nOut := 0

	cQuery += "SELECT FQ5_STATUS, Count(*) QTD"
	cQuery += " FROM "+RetSqlName("FQ5")
	cQuery += " WHERE FQ5_FILIAL = '"+xFilial("FQ5")+"'"
	cQuery += " AND FQ5_XROMAN =  ?"
	Aadd(aBindParam, cRomaneio)
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY FQ5_STATUS"

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"FQ5TRB",,,aBindParam)

	if !(FQ5TRB->(EOF()))
		while !FQ5TRB->(EOF())
			if FQ5TRB->FQ5_STATUS = '6'
				nSep := FQ5TRB->QTD 
			else
				nOut += FQ5TRB->QTD
			endif
			FQ5TRB->(dbSkip())
		enddo

		lRet := ( nSep > 0 .and. nOut = 0)

	endif	
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} LOCA259EMD
Função que define a parte generica do Model de Separação
@type function
@version 12.10
@author Alexandre Circenis
@since 5/15/2025
@param oModel, object, Model origem
@return variant, Model modificado
/*/
Function LOCA259EMD(oModel)
Local oStrFQ5B := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStrFQ5Q := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStrFQ5P := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStrFH2  := FWFormStruct( 1, 'FH2', /*bAvalCampo*/,/*lViewUsado*/ )
local oStrMaq   as object
Local cExistSep :=  ""   

Local cGrupos  := LOCA00189()
Local cGrpACes := {}

	if  FwAliasInDic("FH4")
		cExistSep :=  " AND NOT EXISTS ( SELECT FH4_NUM FROM "+ RetSqlName("FH4") + " FH4 WHERE FH4_FILIAL = '"+xFilial("FH4")+"'"+;
                    " AND FH4_AS = FQ5_AS AND FH4_STATUS = '1' AND FH4.D_E_L_E_T_ = ' ')"
	endif

	cGrpAces := "('"+ StrTran( cGrupos, ";", "','" ) +"')"

	//Estrutura de Grid
	oStrMaq := FWFormModelStruct():New()

	oStrMaq:AddField("Item", ' ', 'ITEM', 'C', 3, 0, , , {}, .F.) //'Desc '
	oStrMaq:AddField(STR0001, ' ', 'FPA_PRODUT', 'C',TamSx3("FPA_PRODUT")[1], 0, , , {}, .F.)  //"Produto"
	oStrMaq:AddField(STR0002, ' ', 'FPA_DESPRO', 'C',TamSx3("FPA_DESPRO")[1], 0, , , {}, .F.)  //"Descricao"
	oStrMaq:AddField(STR0003, ' ', 'B1_UM', 'C',TamSx3("B1_UM")[1], 0, , , {}, .F.) //'Armazem'
	oStrMaq:AddField(STR0004, ' ', 'FPA_QUANT', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0005, ' ', 'FPA_LOCAL', 'C', TamSx3("FPA_LOCAL")[1], 0, , , {}, .F.) //'Qtde Nova'
	oStrMaq:AddField(STR0006, ' ', 'QTDDISP', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0007, STR0008, 'EMPDEM', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0009, STR0010, 'EMPOUT', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0011, ' ', 'PREV07', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0012, ' ', 'PREV15', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0013, ' ', 'PREV30', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrMaq:AddField(STR0014, ' ', 'PREV99', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'

	oStrFQ5B:AddField(STR0015, ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.) //'Separado'
	oStrFQ5B:AddField(STR0016, ' ', 'FPA_DESGRU', 'C', TamSx3("FPA_DESGRU")[1], 0, , , {}, .F.) //'Descricao'
	oStrFQ5B:AddField(STR0017, ' ', 'T9_PLACA', 'C', TamSx3("T9_PLACA")[1], 0, , , {}, .F.) //'Placa'
	oStrFQ5B:AddField(STR0018, ' ', 'GRUANEW', 'C', TamSx3("FPA_GRUA")[1], 0, , , {}, .F.) //'Novo Recurso'
	oStrFQ5B:AddField(STR0016, ' ', 'DESNEW', 'C', TamSx3('FPA_DESGRU')[1], 0, , , {}, .F.) //'Descricao'
	oStrFQ5B:AddField(STR0017, ' ', 'DESPLA', 'C', TamSx3("T9_PLACA")[1], 0, , , {}, .F.) //'Placa'

	oStrFQ5B:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"Loca259EVM('FQ5BEM')" ))
	oStrFQ5B:SetProperty("GRUANEW"   ,MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. Loca259EVB()" ))
	oStrFQ5B:SetProperty('FPA_DESGRU', MODEL_FIELD_INIT,{|| Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,'FPA_DESGRU')} )

	// Adicionando gatilhos
	oStrFQ5B:AddTrigger("GRUANEW","DESNEW",,{|| Posicione("ST9",1, xFilial("ST9")+M->GRUANEW, "T9_NOME")})
	oStrFQ5B:AddTrigger("GRUANEW","DESPLA",,{|| Posicione("ST9",1, xFilial("ST9")+M->GRUANEW, "T9_PLACA")})

	oStrFQ5Q:AddField(STR0015, ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.) //'Separado'
	oStrFQ5Q:AddField(STR0016, ' ', 'B1_DESC', 'C', TamSx3("B1_DESC")[1], 0, , , {}, .F.) //'Descricao'
	oStrFQ5Q:AddField("Qtd 2 unid", ' ', 'QTD2UNI', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0019, ' ', 'FPA_LOCAL', 'C', TamSx3("FPA_LOCAL")[1], 0, , , {}, .F.) //'Qtde Nova'
	oStrFQ5Q:AddField(STR0006, ' ', 'QTDDISP', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0020, ' ', 'QTDNEW', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0007, STR0008, 'EMPDEM', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0009, STR0021, 'EMPOUT', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0022, STR0023, 'QTDDREAL', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0011, ' ', 'PREV07', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0012, ' ', 'PREV15', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0013, ' ', 'PREV30', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5Q:AddField(STR0014, ' ', 'PREV99', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'

	// Inicializadores para Quantidade
	oStrFQ5Q:SetProperty('B1_DESC'   , MODEL_FIELD_INIT,{|| Posicione("SB1",1,xFilial("SB1")+FQ5->FQ5_XPROD,"B1_DESC")} )
	oStrFQ5Q:SetProperty('FPA_LOCAL' , MODEL_FIELD_INIT,{|| Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,"FPA_LOCAL")} )
	oStrFQ5Q:SetProperty('QTDDISP'   , MODEL_FIELD_INIT,{|| Posicione("SB2",1,xFilial("SB2")+FQ5->FQ5_XPROD+Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,"FPA_LOCAL"),"B2_QATU")} )
	oStrFQ5Q:SetProperty('QTDNEW'    , MODEL_FIELD_INIT,{|| 0 } )
	oStrFQ5Q:SetProperty('EMPDEM'    , MODEL_FIELD_INIT,{|| Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .T.)} )
	oStrFQ5Q:SetProperty('EMPOUT'    , MODEL_FIELD_INIT,{|| Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .F.)} )
	oStrFQ5Q:SetProperty('QTDDREAL'  , MODEL_FIELD_INIT,{|| Posicione("SB2",1,xFilial("SB2")+FQ5->FQ5_XPROD+Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,"FPA_LOCAL"),"B2_QATU") ;
									- Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .T.) -  Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .F.)} )
	oStrFQ5Q:SetProperty("QTDNEW",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BVQ('FQ5QTD')" ))
	oStrFQ5Q:SetProperty("FQ5_QTD2",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BV2('FQ5QTD')" ))
    oStrFQ5Q:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "Loca259EVM('FQ5QTD')" ))

	// Adicionando campos as Itens de Patrimonio 

	//oStrFQ5P:AddField(STR0015, ' ', 'MARK', 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD,".F."),,, .T.) //'Separado'
	oStrFQ5P:AddField(STR0016, ' ', 'B1_DESC', 'C', TamSx3("B1_DESC")[1], 0, , , {}, .F.) //'Descricao'
	oStrFQ5P:AddField("Qtd 2 unid", ' ', 'QTD2UNI', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0019, ' ', 'FPA_LOCAL', 'C', TamSx3("FPA_LOCAL")[1], 0, , , {}, .F.) //'Qtde Nova'
	oStrFQ5P:AddField(STR0006, ' ', 'QTDDISP', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0020, ' ', 'QTDNEW', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0007, STR0008, 'EMPDEM', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0009, STR0021, 'EMPOUT', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0022, STR0023, 'QTDDREAL', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0011, ' ', 'PREV07', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0012, ' ', 'PREV15', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0013, ' ', 'PREV30', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'
	oStrFQ5P:AddField(STR0014, ' ', 'PREV99', 'N',TamSx3("FPA_QUANT")[1],TamSx3("FPA_QUANT")[2], , , {}, .F.) //'Desc Equip'

	oStrFQ5P:SetProperty('B1_DESC'   , MODEL_FIELD_INIT,{|| Posicione("SB1",1,xFilial("SB1")+FQ5->FQ5_XPROD,"B1_DESC")} )
	oStrFQ5P:SetProperty('FPA_LOCAL' , MODEL_FIELD_INIT,{|| Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,"FPA_LOCAL")} )
	oStrFQ5P:SetProperty('QTDDISP'   , MODEL_FIELD_INIT,{|| Posicione("SB2",1,xFilial("SB2")+FQ5->FQ5_XPROD+Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,"FPA_LOCAL"),"B2_QATU")} )
	oStrFQ5P:SetProperty('QTDNEW'    , MODEL_FIELD_INIT,{|| 0 } )
	oStrFQ5P:SetProperty('EMPDEM'    , MODEL_FIELD_INIT,{|| Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .T.)} )
	oStrFQ5P:SetProperty('EMPOUT'    , MODEL_FIELD_INIT,{|| Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .F.)} )
	oStrFQ5P:SetProperty('QTDDREAL'  , MODEL_FIELD_INIT,{|| Posicione("SB2",1,xFilial("SB2")+FQ5->FQ5_XPROD+Posicione("FPA",3,xFilial("FPA")+FQ5->FQ5_AS,"FPA_LOCAL"),"B2_QATU") ;
									- Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .T.) -  Loca259EEM(FQT->FQT_DEMAND, FQ5->FQ5_XPROD, .F.)} )
	oStrFQ5P:SetProperty("QTDNEW",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BVQ('FQ5QTD')" ))
	oStrFQ5P:SetProperty("FQ5_QTD2",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259BV2('FQ5QTD')" ))

	oStrFH2:SetProperty('FH2_NOMBEM', MODEL_FIELD_INIT,{|| ""} )

	oModel:AddGrid( 'RESUMO', 'MASTER', oStrMaq, /*bLinePre*/ , /*bLinePost */, /*bPre */, /*bLinePost */, /*Carga*/)
	oModel:AddGrid( 'FQ5BEM', 'MASTER', oStrFQ5B, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| Loca259ELG( oMdl, "M")}/*bCarga*/ )
	oModel:AddGrid( 'FQ5QTD', 'MASTER', oStrFQ5Q, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| Loca259ELG( oMdl, "Q")}/*bCarga*/ )
	oModel:AddGrid( 'FQ5PAT', 'MASTER', oStrFQ5P, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| Loca259ELG( oMdl, "Q")}/*bCarga*/ )
	oModel:AddGrid( 'FH2QTD', 'FQ5PAT', oStrFH2, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| Loca259ELG( oMdl, "Q")}/*bCarga*/ )


	oModel:GetModel( 'FQ5BEM'):SetLoadFilter( , " ( EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' '  AND ( NOT EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' WHERE B1_FILIAL = '"+xFilial("SB1")+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ')))" +cExistSep+")" ) 
	oModel:GetModel( 'FQ5QTD'):SetLoadFilter( , " NOT EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ' )" + ;
		" AND NOT EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' WHERE B1_FILIAL = '"+xFilial("SB1")+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ') " +cExistSep )  // DSERLOCA-11036
	oModel:GetModel( 'FQ5PAT'):SetLoadFilter( , " EXISTS ( SELECT B1_COD FROM "+ RetSqlName("SB1") + " SB1 INNER JOIN "+ RetSqlName("SBM") + " SBM ON BM_FILIAL = '"+xFilial("SBM")+"' and BM_GRUPO = B1_GRUPO and BM_XACESS = '3' and SBM.D_E_L_E_T_ = ' ' WHERE B1_FILIAL = '"+xFilial("SB1")+"' and B1_COD = FQ5_XPROD and SB1.D_E_L_E_T_ = ' ')" +cExistSep ) 

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0024 ) //STR0024
	// Adiciona a descricao do Componente do Modelo de Dados

	oModel:GetModel( 'RESUMO' ):SetDescription( STR0026 )  //"Resumo"
	oModel:GetModel( 'FQ5BEM' ):SetDescription( STR0094 )  //"Bens"
	oModel:GetModel( 'FQ5QTD' ):SetDescription( STR0027 )  //"Quantificados"
	oModel:GetModel( 'FQ5PAT' ):SetDescription( STR0096 ) //"Bens Quantificados"
	oModel:GetModel( 'FH2QTD' ):SetDescription( STR0097 ) //"Bens Separados"

	oModel:GetModel( 'MASTER' ):SetOnlyView(.T.)

	oModel:GetModel( 'RESUMO' ):SetNoInsertLine( .T. ) 
	oModel:GetModel( 'FQ5BEM' ):SetNoInsertLine( .T. ) 
	oModel:GetModel( 'FQ5QTD' ):SetNoInsertLine( .T. )
	oModel:GetModel( 'FQ5PAT' ):SetNoInsertLine( .T. )
	//oModel:GetModel( 'FH2QTD' ):SetNoInsertLine( .T. )

	oModel:GetModel( 'RESUMO' ):SetNoDeleteLine( .T. ) 
	oModel:GetModel( 'FQ5BEM' ):SetNoDeleteLine( .T. ) 
	oModel:GetModel( 'FQ5QTD' ):SetNoDeleteLine( .T. )
	oModel:GetModel( 'FQ5PAT' ):SetNoDeleteLine( .T. )

	// Adiciona ao modelo uma estrutura de formulário de campos calculados
	// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
	// Rodapé Patrimonio unico
	oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oFW | oModel:GetValue( 'FQ5BEM', 'MARK' ) }*/,,STR0028,{|oModel| Loca259BCO(oModel:GetModel("FQ5BEM"))},10 ) //STR0028
	oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_XQTD', 'QTD', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0029,,10,2 ) //STR0029
	oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_QTD2  ', 'QTD2U', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0095,,10,2 ) //'Qtd 2 Unid'
	oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0030,,13,5 ) //STR0030
	oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0031,,13,5 ) //STR0031
	oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_M3', 'VOLUME', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,'m3',,13,5 )
	// Rodapé produto quantificavel
	oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) }*/,,STR0028,{|oModel| Loca259BCO(oModel:GetModel("FQ5QTD"))},10 ) //STR0028
	oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_XQTD', 'QTD', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0029,,10,2 ) //STR0029
	oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_QTD2  ', 'QTD2U', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0095,,10,2 ) //'Qtd 2 Unid'
	oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0030,,13,5 ) //STR0030
	oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0031,,13,5 ) //STR0031
	oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_M3', 'VOLUME', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,'m3',,13,5 )
	// Rodapé Patrimonio Quantificavel
	oModel:AddCalc( 'RODAPE3', 'MASTER', 'FQ5PAT', 'FQ5_XQTD', 'QTDITEM', 'COUNT',,,STR0028,,10 ) //STR0028
	oModel:AddCalc( 'RODAPE3', 'MASTER', 'FQ5PAT', 'QTDNEW', 'QTD', 'SUM', ,,STR0029,,10,2 ) //STR0029
	oModel:AddCalc( 'RODAPE3', 'MASTER', 'FQ5PAT', 'FQ5_QTD2  ', 'QTD2U', 'SUM', ,,STR0095,,10,2 ) //'Qtd 2 Unid'
	oModel:AddCalc( 'RODAPE3', 'MASTER', 'FQ5PAT', 'FQ5_PESLIQ', 'PLIQ', 'SUM', ,,STR0030,,13,5 ) //STR0030
	oModel:AddCalc( 'RODAPE3', 'MASTER', 'FQ5PAT', 'FQ5_PESBRU', 'PBRUTO', 'SUM', ,,STR0031,,13,5 ) //STR0031
	oModel:AddCalc( 'RODAPE3', 'MASTER', 'FQ5PAT', 'FQ5_M3', 'VOLUME', 'SUM', ,,'m3',,13,5 )


	oModel:GetModel('RESUMO'):SetOptional(.T.)
	oModel:GetModel('FQ5BEM'):SetOptional(.T.)
	oModel:GetModel('FQ5QTD'):SetOptional(.T.)
	oModel:GetModel('FQ5PAT'):SetOptional(.T.)
	oModel:GetModel('FH2QTD'):SetOptional(.T.)

	// Os submodelos a seguir não serão gravados
	oModel:SetOnlyQuery('MASTER', .T. )
	oModel:SetOnlyQuery('RESUMO',  .T.)
	oModel:SetOnlyQuery('FQ5BEM', .T.)
	oModel:SetOnlyQuery('FQ5QTD', .T.)
	oModel:SetOnlyQuery('FQ5PAT', .T.)
	oModel:SetOnlyQuery('FH2QTD', .T.)

	oModel:bActivate := {|| Loca259EPAZ()}

Return oModel

/*/{Protheus.doc} Loca259EVI
Define a parte generica da view de separação
@type function
@version  25.10
@author Alexandre Circenis
@since 5/15/2025
@param oView, object, View original
@param oModel, object, Model original
@return variant, return_View modificado
/*/
Function Loca259EVI(oView, oModel)

Local oStrFQ5B	:= FWFormStruct(2,'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_GUINDA "})
Local oStrFQ5P	:= FWFormStruct(2,'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_XPROD  FQ5_XQTD   FQ5_QTD2   "}) // Patrimonio Quantificavel
Local oStrFQ5Q	:= FWFormStruct(2,'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_XPROD  FQ5_XQTD   FQ5_QTD2   "})
Local oStrFH2   := FWFormStruct(2,'FH2', {|cCampo| cCampo $ "FH2_PROD   FH2_CODBEM FH2_NOMBEM   "})
Local oStrMaq   AS object 
Local cPictQtd  := X3Picture("FQ5_QTD")
Local oCalc1  	:= FWCalcStruct(oModel:GetModel('RODAPE1'))
Local oCalc2  	:= FWCalcStruct(oModel:GetModel('RODAPE2'))
Local oCalc3  	:= FWCalcStruct(oModel:GetModel('RODAPE3')) // DSERLOCA-11036

	oStrMaq := FWFormViewStruct():New()

	oStrMaq:AddField("ITEM", '01 ', STR0032, STR0032, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/, .F./*lCanChange*/,"1"/*cFolder*/) //"Item"
	oStrMaq:AddField("FPA_PRODUT", '02 ', STR0033, STR0032, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/, .F./*lCanChange*/,"1"/*cFolder*/) //'Item'
	oStrMaq:AddField("FPA_DESPRO", '03 ', STR0016, STR0032, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Descricao'
	oStrMaq:AddField("FPA_LOCAL", '04 ', STR0034, STR0035, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Armazem'
	oStrMaq:AddField("B1_UM", '05 ', STR0036, STR0032, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Item'
	oStrMaq:AddField("FPA_QUANT", '06 ', STR0037, STR0038, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Qtd'
	oStrMaq:AddField("QTDDISP", '07 ', STR0040, STR0039, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Quantidade Disponivel'
	oStrMaq:AddField("EMPDEM", '08 ', STR0042, STR0041, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Empenhado na demanda'
	oStrMaq:AddField("EMPOUT", '09 ', STR0061, STR0043, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Empenhado em Outras Demandas'
	oStrMaq:AddField("PREV07", '10 ', STR0044, STR0045, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Prev 7 dias'
	oStrMaq:AddField("PREV15", '11 ', STR0046, STR0047, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Prev 15 dias'
	oStrMaq:AddField("PREV30", '12 ', STR0049, STR0048, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Previsao de Retorno em 30 dias'
	oStrMaq:AddField("PREV99", '13 ', STR0051, STR0050, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Previsao de Retorno após 30 dias'

	oStrFQ5B:AddField("MARK", '00', STR0015, STR0052, {}, "CHECK", "!"  ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Separado'
	oStrFQ5B:AddField('FPA_DESGRU', '02',STR0016, STR0053, {}, 'G', "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Descricao'
	oStrFQ5B:AddField('T9_PLACA', '02',STR0017, STR0054, {}, 'G', "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Placa'
	oStrFQ5B:AddField('GRUANEW', '02',STR0018, STR0055, {}, 'G', "@!" ,/*bPictVar*/,"ST9002"/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Novo Recurso'
	oStrFQ5B:AddField('DESNEW', '02',STR0016, STR0056, {}, 'G', "@!" ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Descricao'
	oStrFQ5B:AddField('DESPLA', '02',STR0017, STR0057, {}, 'G', "@!" ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Placa'

	oStrFQ5B:SetProperty("MARK"       , MVC_VIEW_ORDEM, '000')
	oStrFQ5B:SetProperty("FQ5_AS"     , MVC_VIEW_ORDEM, '001')
	oStrFQ5B:SetProperty("FQ5_GUINDA" , MVC_VIEW_ORDEM, '002')
	oStrFQ5B:SetProperty("FPA_DESGRU" , MVC_VIEW_ORDEM, '003')
	oStrFQ5B:SetProperty("T9_PLACA"   , MVC_VIEW_ORDEM, '004')
	oStrFQ5B:SetProperty("GRUANEW"    , MVC_VIEW_ORDEM, '005')
	oStrFQ5B:SetProperty("DESNEW"     , MVC_VIEW_ORDEM, '006')
	oStrFQ5B:SetProperty("DESPLA"     , MVC_VIEW_ORDEM, '007')

	oStrFQ5B:SetProperty("FQ5_AS"     , MVC_VIEW_CANCHANGE, .F.)
	oStrFQ5B:SetProperty("FQ5_GUINDA" , MVC_VIEW_CANCHANGE, .F.)

	oStrFQ5P:SetProperty("FQ5_AS"     , MVC_VIEW_ORDEM, '001')
	oStrFQ5P:SetProperty("FQ5_XPROD"  , MVC_VIEW_ORDEM, '002')
	oStrFQ5P:SetProperty("FQ5_XQTD"   , MVC_VIEW_ORDEM, '004')

	//oStrFQ5P:AddField("MARK", '00', STR0015, STR0052, {}, "CHECK", "!"  ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Separado'
	oStrFQ5P:AddField("B1_DESC"   , '003 ', STR0002, STR0098, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Descricao' //"Descricao" //"Descricao do Produto"
	oStrFQ5P:AddField("QTDNEW"    , '005 ', STR0099, STR0060, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Quantidade Disponivel' //"Quantidade Separada" //"Separada"
	oStrFQ5P:AddField("QTDDISP"   , '006 ', STR0040, STR0039, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Quantidade Disponivel'
	oStrFQ5P:AddField("EMPDEM"    , '007 ', STR0042, STR0041, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Empenhado na demanda'
	oStrFQ5P:AddField("EMPOUT"    , '008 ', STR0061, STR0043, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Empenhado em Outras Demandas'
	oStrFQ5P:AddField("PREV07"    , '009 ', STR0044, STR0045, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Prev 7 dias'
	oStrFQ5P:AddField("PREV15"    , '010 ', STR0046, STR0047, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Prev 15 dias'
	oStrFQ5P:AddField("PREV30"    , '011 ', STR0049, STR0048, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Previsao de Retorno em 30 dias'
	oStrFQ5P:AddField("PREV99"    , '012 ', STR0051, STR0050, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Previsao de Retorno após 30 dias'


	oStrFQ5P:SetProperty("FQ5_AS"    , MVC_VIEW_CANCHANGE, .F.)
	oStrFQ5P:SetProperty("FQ5_XPROD" , MVC_VIEW_CANCHANGE, .F.)
	oStrFQ5P:SetProperty("FQ5_XQTD"  , MVC_VIEW_CANCHANGE, .F.)


	oStrFQ5Q:AddField("MARK", '00', STR0015, STR0052, {}, "CHECK", "!"  ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Separado'
	oStrFQ5Q:AddField('B1_DESC', '02',STR0016, STR0058, {}, 'G', "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Descricao'
	oStrFQ5Q:AddField("FPA_LOCAL", '06 ', STR0034, STR0035, {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Armazem'
	oStrFQ5Q:AddField("QTDDISP", '07 ', STR0040, STR0039, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Quantidade Disponivel'
	oStrFQ5Q:AddField("QTDNEW", '07 ', STR0059, STR0060, {}, "G", cPictQtd ,/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/) //'Qtd Separada'
	oStrFQ5Q:AddField("EMPDEM", '08 ', STR0042, STR0041, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Empenhado na demanda'
	oStrFQ5Q:AddField("EMPOUT", '09 ', STR0061, STR0043, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Empenhado em Outras Demandas'
	oStrFQ5Q:AddField("QTDDREAL", '10 ', STR0023, STR0062, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Disponivel Real'
	oStrFQ5Q:AddField("PREV07", '11 ', STR0044, STR0045, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Prev 7 dias'
	oStrFQ5Q:AddField("PREV15", '12 ', STR0046, STR0047, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Prev 15 dias'
	oStrFQ5Q:AddField("PREV30", '13 ', STR0049, STR0048, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Previsao de Retorno em 30 dias'
	oStrFQ5Q:AddField("PREV99", '14 ', STR0051, STR0050, {}, "G", cPictQtd  ,/*bPictVar*/,/*cLookUp*/,.F./*lCanChange*/,"1"/*cFolder*/) //'Previsao de Retorno após 30 dias'

	oStrFQ5Q:SetProperty("MARK" , MVC_VIEW_ORDEM, '01')
	oStrFQ5Q:SetProperty("FQ5_AS" , MVC_VIEW_ORDEM, '02')
	oStrFQ5Q:SetProperty("FQ5_XPROD"  , MVC_VIEW_ORDEM, '03')
	oStrFQ5Q:SetProperty("B1_DESC"    , MVC_VIEW_ORDEM, '04')
	oStrFQ5Q:SetProperty("FPA_LOCAL"  , MVC_VIEW_ORDEM, '05')
	oStrFQ5Q:SetProperty("FQ5_XQTD"   , MVC_VIEW_ORDEM, '06')
	oStrFQ5Q:SetProperty("FQ5_QTD2"   , MVC_VIEW_ORDEM, '07')
	oStrFQ5Q:SetProperty("QTDDISP"    , MVC_VIEW_ORDEM, '09')
	oStrFQ5Q:SetProperty("QTDNEW" , MVC_VIEW_ORDEM, "10")
	oStrFQ5Q:SetProperty("EMPDEM" , MVC_VIEW_ORDEM, "11")
	oStrFQ5Q:SetProperty("EMPOUT" , MVC_VIEW_ORDEM, "12")
	oStrFQ5Q:SetProperty("QTDDREAL" , MVC_VIEW_ORDEM, "13")
	oStrFQ5Q:SetProperty("PREV07"  , MVC_VIEW_ORDEM, '14')
	oStrFQ5Q:SetProperty("PREV15" , MVC_VIEW_ORDEM, '15')
	oStrFQ5Q:SetProperty("PREV30" , MVC_VIEW_ORDEM, '16')
	oStrFQ5Q:SetProperty("PREV99"  , MVC_VIEW_ORDEM, '17')

	oStrFQ5Q:SetProperty("FQ5_AS"     , MVC_VIEW_CANCHANGE, .F.)
	oStrFQ5Q:SetProperty("FQ5_XPROD" , MVC_VIEW_CANCHANGE, .F.)
	oStrFQ5Q:SetProperty("B1_DESC" , MVC_VIEW_CANCHANGE, .F.)
	oStrFQ5Q:SetProperty("FQ5_XQTD" , MVC_VIEW_CANCHANGE, .F.)

	oView:CreateHorizontalBox( 'CAB', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )

	oView:CreateFolder("PRINCIPAL", "INFERIOR")
	oView:AddSheet( 'PRINCIPAL'   , 'MAQUINAS', STR0063 )   //"A.S. Bem"
	oView:AddSheet( 'PRINCIPAL'   , 'MAQTDE', STR0100 )   //"A.S. Bem Quanti" //"A.S. Bem Quantificavel"
	oView:AddSheet( 'PRINCIPAL'   , 'QTDE'    , STR0064 )   //"A.S. Quant"
	//
	oView:CreateHorizontalBox( 'BOXRESU', 40,,, 'PRINCIPAL', 'MAQUINAS')
	oView:CreateHorizontalBox( 'BOXFQ5B', 40,,, 'PRINCIPAL', 'MAQUINAS' )
	oView:CreateHorizontalBox( 'INFERIOR1', 20,,, 'PRINCIPAL', 'MAQUINAS' )
	oView:CreateVerticalBox( 'RODAPE01', 80, 'INFERIOR1',, 'PRINCIPAL', 'MAQUINAS')
	oView:CreateVerticalBox( 'BOTAO01', 20, 'INFERIOR1',, 'PRINCIPAL', 'MAQUINAS')
	//oView:CreateHorizontalBox( 'RODAPE01', 100,'BOXI01' )
	//oView:CreateHorizontalBox( 'BOTAO01', 100,'BOXI02')

	oView:CreateHorizontalBox( 'BOXFQ5Q', 80,,, 'PRINCIPAL', 'QTDE')
	oView:CreateHorizontalBox( 'INFERIOR2', 20,,, 'PRINCIPAL', 'QTDE')
	oView:CreateVerticalBox( 'RODAPE02', 80, 'INFERIOR2',, 'PRINCIPAL', 'QTDE' )
	oView:CreateVerticalBox( 'BOTAO02', 20, 'INFERIOR2',, 'PRINCIPAL', 'QTDE' )

	oView:CreateHorizontalBox( 'BOXFQ5P', 40,,, 'PRINCIPAL', 'MAQTDE')
	oView:CreateHorizontalBox( 'BOXFH2' , 40,,, 'PRINCIPAL', 'MAQTDE' )
	oView:CreateHorizontalBox( 'INFERIOR3', 20,,, 'PRINCIPAL', 'MAQTDE' )
	oView:CreateVerticalBox( 'RODAPE03', 80, 'INFERIOR3',, 'PRINCIPAL', 'MAQTDE')
	oView:CreateVerticalBox( 'LEITURA', 20, 'INFERIOR3',, 'PRINCIPAL', 'MAQTDE')

	oView:AddGrid("VIEWMAQ"  ,oStrMaq ,"RESUMO")
	oView:AddGrid("VIEWFQ5B" ,oStrFQ5B,"FQ5BEM")
	oView:AddGrid("VIEWFQ5Q" ,oStrFQ5Q,"FQ5QTD")
	oView:AddGrid("VIEWFQ5P" ,oStrFQ5P,"FQ5PAT")
	oView:AddGrid("VIEWFH2"  ,oStrFH2 ,"FH2QTD")

	//oView:AddOtherObject("btnMarcaDesm1", {|oPanel,oView| LOCA259EBT(oPanel, "FQ5BEM")})
	oView:AddOtherObject("LeituraCB1", {|oPanel,oView| LOCA259EBM(oPanel, "FQ5BEM")})
	oView:AddOtherObject("btnMarcaDesm2", {|oPanel,oView| LOCA259EBT(oPanel, "FQ5QTD")})
	oView:AddOtherObject("LeituraCB", {|oPanel,oView| LOCA259ECB(oPanel, "FQ5PAT", "FH2QTD")})

	oView:AddField( 'VIEW_CALC1', oCalc1, 'RODAPE1' )
	oView:AddField( 'VIEW_CALC2', oCalc2, 'RODAPE2' )
	oView:AddField( 'VIEW_CALC3', oCalc3, 'RODAPE3' ) // DSERLOCA-11036

	oView:addIncrementField("VIEWMAQ","ITEM")
		
	oView:SetViewProperty( "VIEW_CALC1", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 60} )
	oView:SetViewProperty( "VIEW_CALC2", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 60} )	
	oView:SetViewProperty( "VIEW_CALC3", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 60} )	

	oView:SetViewProperty("*", 'GRIDROWHEIGHT' ,{20})

	//

	oView:SetOwnerView('VIEW_MASTER', 'CAB') 
	oView:SetOwnerView('VIEWFQ5Q', 'BOXFQ5Q')
	oView:SetOwnerView('VIEWMAQ', 'BOXRESU')
	oView:SetOwnerView('VIEWFQ5B', 'BOXFQ5B')
	oView:SetOwnerView('VIEWFQ5P', 'BOXFQ5P')
	oView:SetOwnerView('VIEWFH2', 'BOXFH2')

	oView:SetOwnerView('VIEW_CALC1', 'RODAPE01')
	oView:SetOwnerView('VIEW_CALC2', 'RODAPE02')
	oView:SetOwnerView('VIEW_CALC3', 'RODAPE03')
	oView:SetOwnerView("LeituraCB1", 'BOTAO01')
	oView:SetOwnerView("btnMarcaDesm2", 'BOTAO02')
	oView:SetOwnerView("LeituraCB", 'LEITURA')

	oView:SetOnlyView("VIEW_MASTER")
	//Definindo que não irá usar o "Salvar e Criar Novo"
	oView:SetCloseOnOk({|| .T.})
	oView:EnableControlBar(.T.)
	oView:SetProgressBar(.T.)
	oView:setUpdateMessage(STR0066,STR0065) //"Processo finalizado com sucesso"
	oView:SetViewProperty("*", "GRIDSEEK", {.T.})
	oView:SetViewProperty("*", "GRIDFILTER", {.T.})

	//DESABILITA FOLDERS QUE NÃO DEVEM APARECER, DEVE APARECER APENAS PESAGEM E CLASSIFICAÇÃO
	//oView:SetAfterViewActivate({|oModel| Loca256EHF(oModel)})

Return oView

/*/{Protheus.doc} LOCA259ECB
Leitura do codigo de Barras 
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/
Function LOCA259ECB(oPanel, cGrid, cDest)
Local oModel as object
Local oView  as object
Local oSayCodBar		:= Nil													//objeto say codigo de barras
Local oGetCodBar		:= Nil													//objeto get codigo de barras
Local oSayEnter         := NIL
Local cGetCodBar		:= Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))
//Inicializa variáveis
	oModel   	:= FWModelActive()
	oView    	:= FwViewActive()	

	//Say Codigo de Barras
	oSayCodBar := tSay():New( 07, 5, {|| STR0101}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10)  //"Código de Barras:"
	//Get Codigo de Barras
	@ 05, 60 GET oGetCodBar VAR cGetCodBar SIZE 80, 10 OF oPanel PIXEL ;
			VALID LOCA259EPC(@cGetCodBar, oGetCodBar, cGrid, cDest) WHEN  !( oModel:GetModel('FQ5PAT'):IsEmpty() .or. Empty( oModel:GetModel('FQ5PAT'):GetValue("FQ5_AS"))) // Grid Quantificavel Vazio

	//oGetCodBar := TGet():New( 05, 60, {|u| If(PCount() > 0, cGetCodBar := u, cGetCodBar)}, oPanel,;								
	//								80, 10, "@!", {|| LOCA259EPC(@cGetCodBar, oGetCodBar, cGrid, cDest)} ,,,,,,.T.,,, {|| .T.})				
	//Say Pressionar Enter 
	oSayEnter  := tSay():New( 15, 5, {|| STR0113}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 15)  //"Código de Barras:"

	oTButton1 := TButton():New( 2000, 2000, "Botão 01",oPanel,{||alert("Botão 01")}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
	//Perda de foco do campo Codigo de Barras
	//oGetCodBar:bLostFocus := {|| IIF(LOCA259EPC(@cGetCodBar, oGetCodBar, cGrid, cDest), .T.,.F.)}
	
Return()

/*/{Protheus.doc} LOCA259EPC
Busca o codigo informado no campo Codigo de Barra
Primeiro busca pelo codigo do Bem na grid
Se não encontrar busca pelo Codigo de Barra cadastrado no Campo B1_CODBAR 
Usadao para preencher o grid 
@type function
@version 25.10
@author Alexandre Circenis
@since 13/11/2025
@param cCodSearch, character, Codigo Contido na campo Codigo de BArra
@param oGetCodBar, object, Objeto do Get do codigo de barra usado para retornar o foco e permitir informar novos codigo
@param cGrid, character, Nome do Grid base da busca
@param cDest, character, Nome do Grid de preenchimento
/*/
Function LOCA259EPC(cCodSearch, oGetCodBar, cGrid, cDest)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local oDest  := oModel:GetModel(cDest)
Local oView := FWViewActive() 
Local aSaveLines := FWSaveRows()
Local cBem   := ""

	if Empty(cCodSearch)
	 	oGetCodBar:SetFocus()
		Return NIL //.T.
	endif

	cBem := Loca259EVC(cCodSearch, cGrid, cDest)

	if Empty(cBem)
//		cCodSearch := Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))
//		oGetCodBar:SetFocus()
//		oGetCodBar:lFocSel := .T.
		Return .T.
	endif

	oDest:SetNoInsertLine(.F.)
	if !Empty(oDest:GetValue("FH2_PROD",1))
		oDest:AddLine()
		oDest:GoLine(oDest:Length())
	endif

	oDest:LoadValue("FH2_FILIAL", xFilial("FH2"))
	oDest:LoadValue("FH2_AS", oGrid:GetValue("FQ5_AS"))
	oDest:LoadValue("FH2_PROD", oGrid:GetValue("FQ5_XPROD"))
	oDest:LoadValue("FH2_CODBEM", cBem)
	oDest:LoadValue("FH2_NOMBEM", Posicione("ST9",1,xFilial("ST9")+cBem, "T9_NOME"))
	oDest:LoadValue("FH2_CONTRA", oGrid:GetValue("FQ5_SOT"))
	oDest:LoadValue("FH2_OBRA", oGrid:GetValue("FQ5_OBRA"))
	oDest:LoadValue("FH2_DESPRO", Posicione("SB1",1,xFilial("SB1")+oGrid:GetValue("FQ5_XPROD"),"B1_DESC"))
	oDest:SetLineModify(oDest:GetLine())
	oDest:SetNoInsertLine(.T.)

	oGrid:LoadValue("QTDNEW", oGrid:GetValue("QTDNEW")+1 )
	// Ajustar os demais campos
	Loca259BGA(0, cGrid)

	FWRestRows( aSaveLines )
	cCodSearch := Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))
	oView:Refresh("VIEWFH2")
	//Atualiza objetos de tela
	//oGetCodBar:SetFocus()
	//oGetCodBar:lFocSel := .T.	
	oGetCodBar:Refresh()
	oGetCodBar:SetFocus()

Return NIL //.T.

/*/{Protheus.doc} Loca259EVC
Valida o codigo do bem informado no campo de código de barras
Deve existir na ST9
Deve ser do mesmo produto do item quantificavel
O bem deve estar disponivel
Não pode estar na lista de bems já informados
Os bens separados não podem ultrapassar a quantidade do informado na FPA
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param cBem, character, Codigo do Bem Bipado
@param cGrid, character, Grid onde está no codigo do produto que será bipado
@param cDest, character, Grid onde será armazenado o bem bipado
@return variant, Se o bem for valido retorna .T.
/*/
Function Loca259EVC(cBem, cGrid, cDest)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local oDest  := oModel:GetModel(cDest)
Local cRet   :=  ""
Local lRet   := .T.

	ST9->(dbSetOrder(1))
	if !ST9->(dbSeek(xFilial("ST9")+Alltrim(cBem))) // Bem
		cBem := Padr(Alltrim(cBem), TamSx3("T9_BARCODE")[1])
		ST9->(dbSetOrder(18))
		if !ST9->(dbSeek(cBem+xFilial("ST9"))) // Codigo de barras da ST9
			lRet := .F.
			Help(" ",1,"LOCA259E_01",, STR0102,1,0)  //"Código não encontrato na tabelas de Bens."
		endif
		ST9->(dbSetOrder(1))
	elseif ST9->T9_CODESTO <> oGrid:GetValue("FQ5_XPROD")  // O produto do bem não é igual ao da Grid
		lRet := .F.
		Help(" ",1,"LOCA259E_02",, STR0103,1,0)   //"O produto associado a bem informado não corresponde ao produto selecionado na grid superior."
	elseif !ST9->T9_STATUS $ LOCA00194() 
		lRet := .F.
		Help(" ",1,"LOCA259E_05",, STR0104,1,0)   //"O bem informado não está com o status disponivel."
	elseif oDest:SeekLine({{"FH2_CODBEM", ST9->T9_CODBEM}},,.F.)
		lRet := .F.
		Help(" ",1,"LOCA259E_03",, STR0105,1,0) //"O bem já está incluido na lista de bem separados"
	elseif !Loca259EVA(ST9->T9_CODBEM)
		lRet := .F.
	elseif oGrid:GetValue("FQ5_XQTD") = oGrid:GetValue("QTDNEW")
		lRet := .F.
		Help(" ",4,"LOCA259E_04",, STR0106,1,0)   //"O numero maximo de itens a serem separados foi atingido"
	endif

	if lRet
		cRet := ST9->T9_CODBEM
	endif

Return cRet

/*/{Protheus.doc} Loca259LPV
Processa o Delete/Undelete de um item da lista dos bens alocados para um item quantificavel
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param oFH2, object, Objeto do tipo grid onde será processada a deleção e recuperação da linha
@param nLinha, numeric, Numero d linha qu está sendo deletada ou recuperada
@param cAcao, character, Acção que está sendo realizada UNDELETE para recuperação e DELETE para deleção da linha
@return variant, Retorna .T. se a acção for bem sucedida
/*/
Function Loca259LPV(oFH2,nLinha,cAcao)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel("FQ5PAT")
Local lRet := .T.
Local cBemLPV
Local cAsLPV

if cACAO = "UNDELETE" // Se está desdeletando varificar se a quantiade separada já foi atingida
	if oGrid:GetValue("FQ5_XQTD") = oGrid:GetValue("QTDNEW")
		lRet := .F.
		Help(" ",4,"LOCA259E_10",, STR0107,1,0)   //"Impossivel retorna a linha para ativa pois o numero de itens separados jï¿½ foi atingido, delete outra linha antes."
	else
		cBemLPV := oFH2:GetValue("FH2_CODBEM", nLinha)
		cAsLPV  := oFH2:GetValue("FH2_AS", nLinha)
		Loca259EGA(4, {cAsLPV, cBemLPV})
		oGrid:LoadValue("QTDNEW", oGrid:GetValue("QTDNEW") + 1)
	endif
elseif cAcao = 'DELETE'
	cBemLPV := oFH2:GetValue("FH2_CODBEM", nLinha)
	cAsLPV  := oFH2:GetValue("FH2_AS", nLinha)
	Loca259EGA(3, {cAsLPV, cBemLPV})
	oGrid:LoadValue("QTDNEW", oGrid:GetValue("QTDNEW") - 1)

endif

	// Ajustar os demais campos
	Loca259BGA(0, "FQ5PAT")

Return lRet

/*/{Protheus.doc} Loca259ELP
Devolve o array com os bens informados para um item quantificavel
Será usada a A.S. posicionar no grid dos bens quantificaveis
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param oMdl, object, Model que será preenchido
@param oModelo, object, Model principal 
@return variant, Retorna array com os dados da FH2 conforme a AS posicionada
/*/
Function Loca259ELP(oMdl, oModel)

Local oGrid   := oModel:GetModel("FQ5PAT")
Local cAS := oGrid:GetValue("FQ5_AS")
Local aArea      := GetArea()
Local cAliasT    := GetNextAlias()
Local aDados     := {}

Local cQuery 	:= ''
Local aParam    := {}

	cQuery += "SELECT FH2.*, T9_NOME FH2_NOMBEM"
	
	cQuery += " FROM " + RetSqlName("FH2") + " FH2 "  // Trazer os Bens ligados a AS
	cQuery += " INNER JOIN " + RetSqlName("ST9") + " ST9 "
	cQuery += "  ON ST9.T9_FILIAL = '" + xFilial("ST9") + "' "
	cQuery += "  AND ST9.T9_CODBEM = FH2.FH2_CODBEM "
	cQuery += "  AND ST9.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE FH2.FH2_FILIAL = '" + xFilial("FH2") + "' "
	cQuery += " AND	FH2.FH2_AS = ? "
	aadd( aParam, cAS )
	cQuery += " AND FH2.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

//-- Executa QUERY
	MPSysOpenQuery(cQuery,cAliasT,,,aParam)

/*
FWLoadByAlias
Função que realiza a carga de um submodelo baseado em um alias existente

@param oObj, character,         Objeto do submodelo (FWFormFieldsModel ou FWFormGridModel)
@param cAlias, character,       Alias para carga .
@param cAliasReal, character,   Alias Real. Utilizado para carga de campos MEMO reais na tabela, se houver e para uso real de inicializadores padrao, 
	                                                           se nao for informado usa a tabela definida na estrutura do objeto.
@param cFieldRecno, character,  Nome do campo que contem o numero do recno. Quando a tabela foi criada a partir de uma query
	                                                           deve ter uma coluna contendo o recno() real do registro. Se o nome desta coluna for R_E_C_N_O_ ou 
	                                                           RECNO ou Alias+RECNO, nao é preciso informar o nome da coluna neste parametro, caso contrario deve-se informar.
@param lCopy, logical,        Apenas para compatibilidade, Nao usar
@param lQuery, Logical,       Indica que o alias foi criado a partir de uma query.
*/

// Como tem o campo R_E_C_N_O_, nao é preciso informar qual o campo contem o Recno() real
	aDados := FWLoadByAlias( oMdl , cAliasT , 'FH2' , Nil , Nil , .t. )

//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )

/*/{Protheus.doc} Loca259EVA
Valida o codigo do bem informado pelo código de Barra para um bem quantificavel
Verifica se o bem já está na lista de bens da demanda ou já foi incluido em outra demanda
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param cBem, character, Código do bem 
@return variant, Informa se o bem é valido ou não
/*/
Function Loca259EVA(cBem)
Local lRet := .T.
Local oModel := FWModelActive()
Local oGrid   := oModel:GetModel("FQ5PAT")
Local oFH2    := oModel:GetModel("FH2QTD")
Local nLinGrid := oGrid:GetLine()
Local cProd   := oGrid:GetValue("FQ5_XPROD")
Local aSaveLines := FwSaveRows()
Local aArea   := GetArea()
Local nLinha
Local aBindParam := {}
Local cQuery :=  ""

For nLinha := 1 To oGrid:Length() // Verificar se o Bem Está associdado ao outro item da demanda
	if nLinha <> nLinGrid .and. oGrid:GetValue("FQ5_XPROD", nLinha) = cProd
		oGrid:GoLine(nLinha)
		if oFH2:SeekLine({{"FH2_CODBEM",cBem}},,.F.)
			lRet := .F.
			Help(" ",1,"LOCA259E_11",, STR0109+Alltrim(oGrid:GetValue("FQ5_AS"))+STR0108,1,0) //" dessa demanda." //"O bem já está incluido na lista de bens separados para A.S. "
			Exit
		endif
	endif
next

if lRet // Verificar se já está associado a outra A.S. e ainda não foi devolvido
	cQuery += "SELECT FH2_CONTRA , FH2_AS"
	cQuery += " FROM "+RetSqlName("FH2")
	cQuery += " WHERE FH2_FILIAL = '"+xFilial("FH2")+ "'"
	cQuery += " AND FH2_CODBEM = ? "
	Aadd( aBindParam , cBem )
	cQuery += " AND FH2_NFRET = ' ' "
	cQuery += " AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,"FH2TRB",,,aBindParam)

	if !FH2TRB->(Eof())
		lRet := .F.
		Help(" ",1,"LOCA259E_12",, STR0111+Alltrim(FH2TRB->FH2_AS)+STR0110+Alltrim(FH2TRB->FH2_CONTRA),1,0) //" do contrato " //"O bem já está incluido na lista de bens da A.S. "
	endif
	FH2TRB->(dbCloseArea())

endif

FwRestRows(aSaveLines)
RestArea(aArea)

Return lRet

/*/{Protheus.doc} Loca259EPAZ
Ao ativar o model zera QTDNEW e os campos dependentes da quantidade
na grid FQ5PAT para garantir que o processo de separacao inicie do zero
@type function
@version 25.10
@author Alexandre Circenis
@since 26/03/2025
@return variant, .T.
/*/
STATIC Function Loca259EPAZ()
Local oModel   := FWModelActive()
Local oGridPat := oModel:GetModel("FQ5PAT")
Local nX

Loca259EGA(0)
	For nX := 1 To oGridPat:Length()
		oGridPat:GoLine(nX)

		oGridPat:LoadValue("QTDNEW"  , 0)
		// Ajustar os demais campos
		Loca259BGA(0, "FQ5PAT")
	Next nX

	If oGridPat:Length() > 0
		oGridPat:GoLine(1)
	EndIf

Return .T.

/*/{Protheus.doc} Loca259EVM
Valida se a linha pode ser marcada
@type function
@version  25.10
@author Alexandre Circenis
@since 27/03/2026
@return variant, Retorno .T. se a linha do grid puder ser alterada
/*/
Function Loca259EVM(cGrid)
Local oModel   := FWModelActive()
Local oGrid := oModel:GetModel(cGrid)
Local lRet := .T.

if cGrid = "FQ5BEM"
	if Empty(FwFldGet('FPA_DESGRU'))
		lRet := .F.
	endif
elseif cGrid = "FQ5QTD"	
	if Empty(oGrid:GetValue("FQ5_XPROD"))
		lRet := .F.
	endif
endif


if !lRet
	Help(" ",1,"LOCA259E_21",,STR0112 ,1,0)  //"Nessa aba, não existem itens a serem separados."
endif

Return lRet

/*/{Protheus.doc} Loca256EHF
Desabilitar o acesso aos folders com grid vazios
@type function
@version 25.10 
@author Alexandre Circenis
@since 06/05/2026
@param oModel, object, Model ode estão os grids que devem ser testados
@return variant, .T. para manter a compatibilidade
/*/
/* REVISITAR ESSA IDEIA NO FUTURO
Function Loca256EHF( oModel )
Local oView	:= FWViewActive()
Local nSelect := 3
Local aFldBloq := {}
Local nX


	If oModel:GetModel('FQ5BEM'):IsEmpty() // Grid de Bem Vazio 
		Aadd( aFldBloq , 1 ) 
		//oView:HideFolder("PRINCIPAL", 1, 2)
	else
		nSelect := 1 // Selecionar a ABA 1
	endif

	If oModel:GetModel('FQ5PAT'):IsEmpty() .or. Empty( oModel:GetModel('FQ5PAT'):GetValue("FQ5_AS")) // Grid Quantificavel Vazio
		Aadd( aFldBloq , 2 ) 
		
		//oView:HideFolder("PRINCIPAL",STR0100 , 2)
	elseif nSelect > 1
		nSelect := 2
	endif

	If oModel:GetModel('FQ5QTD'):IsEmpty() // Grid Acessorios Vazios
		Aadd( aFldBloq , 3 ) 
		
		//oView:HideFolder("PRINCIPAL",STR0064, 2)
	elseif nSelect > 2
		nSelect := 3
	endif

	oView:SelectFolder("PRINCIPAL", nSelect, 2)
	for nX := 1 to Len(aFldBloq)
		oView:HideFolder("PRINCIPAL", aFldBloq[nX], 2)
	next nS
	oView:Refresh()

RETURN .T.
*/

/*/{Protheus.doc} LOCA259EBM
Leitura do codigo de Barras para Bem normal
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@param oPanel, object, Panel da Grid
@param cGrid, character, Nome da Grid que vai ser marcada/desmarcada
/*/
Function LOCA259EBM(oPanel, cGrid)
Local oModel as object
Local oView  as object
Local oSayCodBar		:= Nil													//objeto say codigo de barras
Local oGetCodBar		:= Nil													//objeto get codigo de barras
Local oSayEnter         := NIL
Local cGetCodBar		:= Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))
//Inicializa variáveis
oModel   	:= FWModelActive()
oView    	:= FwViewActive()	

//Say Codigo de Barras
oSayCodBar := tSay():New( 07, 5, {|| STR0101}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 10)  //"Código de Barras:"
//Get Codigo de Barras
@ 05, 60 GET oGetCodBar VAR cGetCodBar SIZE 80, 10 OF oPanel PIXEL ;
			VALID LOCA259EPB(@cGetCodBar, oGetCodBar, cGrid) WHEN  !( oModel:GetModel('FQ5BEM'):IsEmpty())

//Say Pressionar Enter 
oSayEnter  := tSay():New( 15, 5, {|| STR0113}, oPanel,/*pict*/,/*fonte*/,,,, .T., CLR_BLUE,, 50, 15)  //"Código de Barras:"

//Perda de foco do campo Codigo de Barras
//oGetCodBar:bLostFocus := {|| IIF(LOCA259EPB(@cGetCodBar, oGetCodBar, cGrid), .T.,.F.)}
	
Return()


/*/{Protheus.doc} LOCA259EPB
Busca o codigo informado no campo Codigo de Barra para bem quantificavel
Primeiro busca pelo codigo do Bem na grid
Se não encontrar busca pelo Codigo de Barra cadastrado no Campo B1_CODBAR 
@type function
@version 25.10
@author Alexandre Circenis
@since 13/11/2025
@param cCodSearch, character, Codigo Contido na campo Codigo de BArra
@param oGetCodBar, object, Objeto do Get do codigo de barra usado para retornar o foco e permitir informar novos codigo
@param cGrid, character, Nome do Grid base da busca
/*/
Function LOCA259EPB(cCodSearch, oGetCodBar, cGrid)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local oView := FWViewActive() 
Local aSaveLines := FWSaveRows()
Local cBem   := ""

	if Empty(cCodSearch)
		Return .F.
	endif

	cBem := Loca259EVD(cCodSearch, cGrid)

	if Empty(cBem)
		oGetCodBar:SetFocus()
		Return .F.
	endif

	// Verificar se é um bem novo ou a confirmação de um já separado
	if oGrid:SeekLine({{"FQ5_GUINDA", ST9->T9_CODBEM}},,.T.) .and. oGrid:GetValue("MARK") // é um bem que já esta no contrato e veio para separação
		oGrid:SetValue("GRUANEW", ST9->T9_CODBEM)
		oGrid:SetValue("MARK", .T.)
	elseif oGrid:SeekLine({{"FQ5_XPROD", ST9->T9_CODESTO},{"MARK", .F.}},,.T.)
		oGrid:SetValue("GRUANEW", ST9->T9_CODBEM)
		oGrid:SetValue("MARK", .T.)
	else
		Help(" ",1,"LOCA259E_51",, STR0114,1,0)  //"Não há Linha do contrato sem Bem, esse novo item não poderá ser incluido na separação."
		oGetCodBar:SetFocus()
		Return .F.
	endif


	FWRestRows( aSaveLines )
	oView:Refresh()
	//Atualiza objetos de tela
	cCodSearch := Space(Max(TamSx3("T9_CODBEM")[1], TamSx3("T9_BARCODE")[1]))	
	oGetCodBar:Refresh()
	oGetCodBar:SetFocus()

Return .T.

/*/{Protheus.doc} Loca259EVD
Valida o codigo do bem informado no campo de código de barras
Deve existir na ST9
Deve ser do mesmo produto do item quantificavel
O bem deve estar disponivel
Não pode estar na lista de bems já informados
Os bens separados não podem ultrapassar a quantidade do informado na FPA
@type function
@version 25.10
@author Alexandre Circenis
@since 12/12/2025
@param cBem, character, Codigo do Bem Bipado
@param cGrid, character, Grid onde está no codigo do produto que será bipado
@param cDest, character, Grid onde será armazenado o bem bipado
@return variant, Se o bem for valido retorna .T.
/*/
Function Loca259EVD(cBem, cGrid)
Local oModel := FWModelActive()
Local oGrid  := oModel:GetModel(cGrid)
Local cRet   :=  ""
Local lRet   := .T.

	ST9->(dbSetOrder(1))
	if !ST9->(dbSeek(xFilial("ST9")+Alltrim(cBem))) // Bem
		cBem := Padr(Alltrim(cBem), TamSx3("T9_BARCODE")[1])
		ST9->(dbSetOrder(18))
		if !ST9->(dbSeek(cBem+xFilial("ST9"))) // Codigo de barras da ST9
			lRet := .F.
			Help(" ",1,"LOCA259E_31",, STR0102,1,0)  //"Código não encontrato na tabelas de Bens."
		endif
		ST9->(dbSetOrder(1))
	elseif !oGrid:SeekLine({{"FQ5_XPROD",ST9->T9_CODESTO}})  // O produto do bem não está na lista
		lRet := .F.
		Help(" ",1,"LOCA259E_32",, STR0115,1,0)    //"O produto do bem lido não está na lista de separação"
	elseif !ST9->T9_STATUS $ LOCA00194() 
		lRet := .F.
		Help(" ",1,"LOCA259E_35",, STR0104,1,0)   //"O bem informado não está com o status disponivel."
	elseif oGrid:SeekLine({{"GRUANEW", ST9->T9_CODBEM}},,.F.)
		lRet := .F.
		Help(" ",1,"LOCA259E_33",, STR0105,1,0) //"O bem já está incluido na lista de bem separados"

	endif

	if lRet
		cRet := ST9->T9_CODBEM
	endif

Return cRet

/*/{Protheus.doc} Loca259EVO
Validação do model de separação
@type function
@version 25.10
@author Alexandre Circenis
@since 10/06/2026
@param oModel, object, MOdel a ser validado
@return variant, Se modelo OK
/*/
Function Loca259EVO( oModel)
Local lRet := .T.
Local oGridMaq := oModel:GetModel("FQ5BEM")
Local aAlteradas := {}
Local nX

// Validar o grid de Maquinas
aAlteradas := oGridMaq:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGridMaq:Goline(aAlteradas[ nX])
	// Bem marcada para separação mas não tem Bem Informado
	if oGridMaq:GetValue('MARK') .and. Empty(oGridMaq:GetValue('GRUANEW')) .and. Empty(oGridMaq:GetValue('FQ5_GUINDA')) 
		Help(" ",1,"LOCA259E_VLDOK",, STR0117,1,0) //"Há itens marcados para separação sem Bem informado! A separação não será realizada."
		lRet := .F.
		exit
	endif

next

Return lRet
/*/{Protheus.doc} Loca259EGA
Gerencia o acumulador estatico de itens FH2 para garantir a gravacao
de todos os bens bipados para SBM_XACESS=3, independente da navegacao
entre linhas do FQ5PAT (o bLoad recarrega do banco e perderia os itens
em memoria das linhas anteriores sem este acumulador).
Estrutura de cada item: {FH2_FILIAL,FH2_AS,FH2_CONTRA,FH2_OBRA,FH2_PROD,FH2_CODBEM,lDeletado}
@type function
@version 25.10
@author luipazini
@since 12/06/2026
@param nOper, numeric, 0=reset 1=add 2=get 3=marcar deletado 4=marcar ativo
@param xParam, variant, Item array (op 1) ou {cAS,cBem} (op 3/4) ou Nil (op 0/2)
@return variant, Array completo (op 2) ou Nil
/*/
Static Function Loca259EGA(nOper, xParam)
Static aAcc := {}
Local nPos

if nOper == 0
	aAcc := {}
elseif nOper == 1
	Aadd(aAcc, xParam)
elseif nOper == 2
	Return aAcc
elseif nOper == 3
	For nPos := 1 to Len(aAcc)
		if aAcc[nPos][2] == xParam[1] .and. aAcc[nPos][6] == xParam[2]
			aAcc[nPos][7] := .T.
			Exit
		endif
	Next nPos
elseif nOper == 4
	For nPos := 1 to Len(aAcc)
		if aAcc[nPos][2] == xParam[1] .and. aAcc[nPos][6] == xParam[2]
			aAcc[nPos][7] := .F.
			Exit
		endif
	Next nPos
endif

Return Nil
