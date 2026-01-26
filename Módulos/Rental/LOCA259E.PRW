#Include "LOCA259E.CH"
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
Local oStrFQT  := FWFormStruct( 1, 'FQT', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local cGrupos  := LOCA00189()
Local cGrpACes := {}

cGrpAces := "('"+ StrTran( cGrupos, ";", "','" ) +"')"

oModel := MPFormModel():New( 'LOCA259E', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'MASTER', /*cOwner*/, oStrFQT, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel := Loca529EMD(oModel)
oModel:SetRelation( 'FQ5BEM', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","FQT_DEMAND"}, {"FQ5_STATUS" , "1"}}, FQ5->( IndexKey( 22 ) ) )
oModel:SetRelation( 'FQ5QTD', { { 'FQ5_FILIAL', 'xFilial("FQ5")' } ,{"FQ5_DEMAND","FQT_DEMAND"}, {"FQ5_STATUS" , "1"}}, FQ5->( IndexKey( 22 ) ) )
oModel:GetModel("RESUMO"):bLoad :=   {|oMdl| Local259ELG(oMdl,FQT->FQT_DEMAND) }

oModel:SetPrimaryKey({"FQT_FILIAL","FQT_DEMAND"})
oModel:GetModel( 'MASTER' ):SetDescription( STR0025 )  //"Demanda"

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

oView := Loca529EVI(oView, oModel)
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
/*/{Protheus.doc} Local259ELG
Retorna o array de dados usdado para carga do Model de REsumoa dos itens com bens
@type function
@version 25.10 
@author Alexandre Circenis
@since 4/1/2025
@param oGrid, object, Grid que será carregado
@param cDemanda, character, Demanda em processamento
@return variant, Array com os dados
/*/
Function Local259ELG(oGrid, cDemanda)
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
cQuery += " and Exists ( SELECT T9_CODESTO FROM "+RetSqlName("ST9")+ " ST9"
cQuery += "  WHERE T9_FILIAL = '"+xFilial("ST9")+"'"
cQuery += "  and T9_CODESTO = FQ5_XPROD "
cQuery += "  and ST9.D_E_L_E_T_ = ' ' )"
Aadd( aBindParam, cDemanda)
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

if !(ST9TRB->(EOF()))
	nDisp += ST9TRB->CONTAGEM 
endif

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
Function Loca259EPR(oModel)
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
Local cTitulo := STR0067 //"A.S. Separadas"
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
		cTitulo := STR0068 + cMV_LOC248 + ": " + ALLTRIM(FQT->FQT_PROJET) //"Referente ao aceite da(s) AS(s) - "###"MV_LOCX248"###"PROJETO"
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
		
			nAceitas++
			RecLock("FQT", .F.)
			FQT->FQT_SEPARA := FQT->FQT_SEPARA + FQ5->FQ5_XQTD
			FQT->FQT_PENDEN := FQT->FQT_PENDEN - FQ5->FQ5_XQTD
			msUnlock()

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
				cMsg += STR0069 + ALLTRIM(FQ5->FQ5_AS) + ", " + cMV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente a separação da AS número "
				cMsg += STR0070+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0071+ALLTRIM(FQ5->FQ5_DESTIN)+STR0072+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF //"Data INI/FIM: "
			endif
		else
			nRejeita++
		endif

	endif

next
// Trocar e/ou separar o Grid de Maquinas
aAlteradas := oGrid:GetLinesChanged(MODEL_GRID_LINECHANGED_ALL)

For nX := 1 to Len(aAlteradas)

	oGrid:Goline(aAlteradas[ nX])
	
	FQ5->(dbGoTo(oGrid:GetDataID()))
	
	// Se quantidade separa for diferente da quantidade origem realizar o fracionamento	
	if !Empty(oGrid:GetValue('QTDNEW')) .and. oGrid:GetValue('QTDNEW') <> oGrid:GetValue('FQ5_XQTD')
		// Realizar p Fracionamento da A.S.
		Loca259BFR(FQ5->(Recno()), oGrid)
		// Incrementar o itens
		RecLock("FQT", .F.)
		FQT->FQT_ITENS := FQT->FQT_ITENS + 1
		msUnlock()

	endif

	FQ5->(dbGoTo(oGrid:GetDataID()))

	if oGrid:GetValue('MARK') // Marcado realizar a separação "ACEITE"

		LOCA05908("LOTE")

		if FQ5->FQ5_STATUS = '6'
		
			RecLock("FQ5", .F.)
			FQ5->FQ5_STDEMA := '2'
			FQ5->(msUnlock())
		
			nAceitas++
			RecLock("FQT", .F.)
			FQT->FQT_SEPARA := FQT->FQT_SEPARA + FQ5->FQ5_XQTD
			FQT->FQT_PENDEN := FQT->FQT_PENDEN - FQ5->FQ5_XQTD
			msUnlock()
		
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
				cMsg += STR0069 + ALLTRIM(FQ5->FQ5_AS) + ", " + cMV_LOC248 + " " + ALLTRIM(FQ5->FQ5_SOT) + CRLF //"Referente a separação da AS número "
				cMsg += STR0070+DTOC(FQ5->FQ5_DATINI)+" - "+DTOC(FQ5->FQ5_DATINI)+STR0071+ALLTRIM(FQ5->FQ5_DESTIN)+STR0072+ALLTRIM(FQ5->FQ5_NOMCLI)+"" + CRLF + CRLF //"Data INI/FIM: "
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
//IF NTOTMIN > 0
//	MSGINFO(STR0073 +ALLTRIM(STR(NTOTMIN))+STR0075 , STR0074)   //"Foram geradas "
//ENDIF

if nAceitas > 0
	Aviso(cTitulo, STR0076+Alltrim(Transform( nAceitas, "@E 9,999,999"))+; //"Foram separadas "
	 STR0079+Alltrim(Transform( nRejeita, "@E 9,999,999"))+STR0077, {STR0078}) //" A.S."
endif

RestArea(aArea)

RETURN .T.

/*/{Protheus.doc} Loca05927
Filtro usado na consulta padrão ST9002
@type function
@version  25.10
@author Alexandre Circenis
@since 4/3/2025
@return variant, Se o produto for o mesmo da linha do grid e o bem for diferente
/*/
Function Loca05927()
Local lRet 

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
LOCAL AAREA    := GETAREA()
LOCAL AAREAZA5 := FP4->(GETAREA())
LOCAL AAREAZLG := FPO->(GETAREA())
LOCAL AAREAST9 := ST9->(GETAREA())
LOCAL AAREADTQ := FQ5->(GETAREA())
LOCAL AAREASHB := SHB->(GETAREA())
Local _LC111TEQ := EXISTBLOCK("LC111TEQ")
Local cBemOld  := FQ5->FQ5_GUINDA // Bem Anterior
Local cTmpStat := '00'
//Local lMvLocBac	:= SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC

BEGIN TRANSACTION
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

IF _LC111TEQ //EXISTBLOCK("LC111TEQ") 										// --> PONTO DE ENTRADA NO FINAL DA ATUALIZAÇÃO DE TROCA DE EQUIPAMENTO DA AS.
	EXECBLOCK("LC111TEQ",.T.,.T.,{FwFldGet("GRUANEW")})
ENDIF

END TRANSACTION

RESTAREA(AAREASHB)
RESTAREA(AAREADTQ)
RESTAREA(AAREAST9)
RESTAREA(AAREAZLG)
RESTAREA(AAREAZA5)
RESTAREA(AAREA)

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
	@ 00, 05 Radio oRadio VAR nRadio ITEMS STR0084,STR0085 3D SIZE 100,10 OF oPanel PIXEL			//"Marcar todos os títulos"###"Desmarcar todos os títulos"
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

oGrid		:= oModel:GetModel(cGrid)

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

/*/{Protheus.doc} LOCA259CQ
Quando o item for marcado a quantidade da empenhada na demanda
sera acrescida da quantidade da AS para todos os produto identicos 
da demanda
@type function
@version 25.10  
@author Alexandre Circenis
@since 4/1/2025
@return variant, .T. confirmando o processo
/*/
FUNCTION LOCA259CQ()
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("FQ5QTD")
Local cProduto := oGrid:GetValue("FQ5_XPROD")
Local nQtd     := if( M->MARK, 1 , -1)* oGrid:GetValue("FQ5_XQTD")
Local nX 
Local aSaveLines := FWSaveRows()
Local oView := FwViewActive()

for nX := 1 to oGrid:Length()

	oGrid:GoLine(nX)
	if cProduto = oGrid:GetValue("FQ5_XPROD")
//		oGrid:SetValue('EMPDEM', oGrid:GetValue('EMPDEM')+ nQtd)
	endif

next nX

FwRestRows(aSaveLines)

oView:Refresh()

Return .T.

/*/{Protheus.doc} Loca259ESP
Analisa os itens do Romaneio para veridicar se só há itens separados
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
/*/{Protheus.doc} Loca529EMD
Função que define a parte generica do Model de Separação
@type function
@version 12.10
@author Alexandre Circenis
@since 5/15/2025
@param oModel, object, Model origem
@return variant, Model modificado
/*/
Function Loca529EMD(oModel)
Local oStrFQ5B := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStrFQ5Q := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
local oStrMaq   as object
Local cGrupos  := LOCA00189()
Local cGrpACes := {}

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
oStrFQ5Q:SetProperty("MARK",MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID,"LOCA259CQ()" ))

oModel:AddGrid( 'RESUMO', 'MASTER', oStrMaq, /*bLinePre*/ , /*bLinePost */, /*bPre */, /*bLinePost */, )
oModel:AddGrid( 'FQ5BEM', 'MASTER', oStrFQ5B, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| Loca259ELG( oMdl, "M")}/*bCarga*/ )
oModel:AddGrid( 'FQ5QTD', 'MASTER', oStrFQ5Q, /*bPreValidacao*/, /*bPosValidacao*/, /*{|oMdl| Loca259ELG( oMdl, "Q")}/*bCarga*/ )


oModel:GetModel( 'FQ5BEM'):SetLoadFilter( , " EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ')" ) 
oModel:GetModel( 'FQ5QTD'):SetLoadFilter( , " NOT EXISTS ( SELECT T9_CODESTO FROM "+ RetSqlName("ST9") + " ST9 WHERE T9_FILIAL = '"+xFilial("ST9")+"' and T9_CODESTO = FQ5_XPROD and ST9.D_E_L_E_T_ = ' ' )" ) 

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0024 ) //STR0024
// Adiciona a descricao do Componente do Modelo de Dados

oModel:GetModel( 'RESUMO' ):SetDescription( STR0026 )  //"Resumo"
oModel:GetModel( 'FQ5BEM' ):SetDescription( STR0094 )  //"Bens"
oModel:GetModel( 'FQ5QTD' ):SetDescription( STR0027 )  //"Quantificados"
 
oModel:GetModel( 'MASTER' ):SetOnlyView(.T.)

oModel:GetModel( 'RESUMO' ):SetNoInsertLine( .T. ) 
oModel:GetModel( 'FQ5BEM' ):SetNoInsertLine( .T. ) 
oModel:GetModel( 'FQ5QTD' ):SetNoInsertLine( .T. )

oModel:GetModel( 'RESUMO' ):SetNoDeleteLine( .T. ) 
oModel:GetModel( 'FQ5BEM' ):SetNoDeleteLine( .T. ) 
oModel:GetModel( 'FQ5QTD' ):SetNoDeleteLine( .T. )

// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oFW | oModel:GetValue( 'FQ5BEM', 'MARK' ) }*/,,STR0028,{|oModel| Loca259BCO(oModel:GetModel("FQ5BEM"))},10 ) //STR0028
oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_XQTD', 'QTD', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0029,,10,2 ) //STR0029
oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_QTD2  ', 'QTD2U', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0095,,10,2 ) //'Qtd 2 Unid'
oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0030,,13,5 ) //STR0030
oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,STR0031,,13,5 ) //STR0031
oModel:AddCalc( 'RODAPE1', 'MASTER', 'FQ5BEM', 'FQ5_M3', 'VOLUME', 'SUM', { | oModel | oModel:GetValue( 'FQ5BEM', 'MARK' ) },,'m3',,13,5 )

// Adiciona ao modelo uma estrutura de formulário de campos calculados
// AddCalc(cId, cOwner , cIdForm , cIdField , cIdCalc, cOperation, bCond
oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'MARK', 'QTDITEM', 'FORMULA', /*{ | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) }*/,,STR0028,{|oModel| Loca259BCO(oModel:GetModel("FQ5QTD"))},10 ) //STR0028
oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_XQTD', 'QTD', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0029,,10,2 ) //STR0029
oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_QTD2  ', 'QTD2U', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0095,,10,2 ) //'Qtd 2 Unid'
oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_PESLIQ', 'PLIQ', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0030,,13,5 ) //STR0030
oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_PESBRU', 'PBRUTO', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,STR0031,,13,5 ) //STR0031
oModel:AddCalc( 'RODAPE2', 'MASTER', 'FQ5QTD', 'FQ5_M3', 'VOLUME', 'SUM', { | oModel | oModel:GetValue( 'FQ5QTD', 'MARK' ) },,'m3',,13,5 )


oModel:GetModel('RESUMO'):SetOptional(.T.)
oModel:GetModel('FQ5BEM'):SetOptional(.T.)
oModel:GetModel('FQ5QTD'):SetOptional(.T.)

// Os submodelos a seguir não serão gravados
oModel:SetOnlyQuery('MASTER', .T. )
oModel:SetOnlyQuery('RESUMO',  .T.)
oModel:SetOnlyQuery('FQ5BEM', .T.)
oModel:SetOnlyQuery('FQ5QTD', .T.)

Return oModel
/*/{Protheus.doc} Loca529EVI
Define a parte generica da view de separação
@type function
@version  25.10
@author Alexandre Circenis
@since 5/15/2025
@param oView, object, View original
@param oModel, object, Model original
@return variant, return_View modificado
/*/
Function Loca529EVI(oView, oModel)

Local oStrFQ5B	:= FWFormStruct(2,'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_GUINDA "})
Local oStrFQ5Q	:= FWFormStruct(2,'FQ5', {|cCampo| cCampo $ "FQ5_AS     FQ5_XPROD  FQ5_XQTD   FQ5_QTD2   "})
Local oStrMaq   AS object 
Local cPictQtd  := X3Picture("FQ5_QTD")
Local oCalc1  	:= FWCalcStruct(oModel:GetModel('RODAPE1'))
Local oCalc2  	:= FWCalcStruct(oModel:GetModel('RODAPE2'))

oStrMaq := FWFormViewStruct():New()

oStrMaq:AddField("ITEM", '01 ', 'Item', 'Item', {}, "G", "@!" ,/*bPictVar*/,/*cLookUp*/, .F./*lCanChange*/,"1"/*cFolder*/)
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

oView:AddGrid("VIEWMAQ",oStrMaq,"RESUMO")
oView:AddGrid("VIEWFQ5B" ,oStrFQ5B,"FQ5BEM")
oView:AddGrid("VIEWFQ5Q" ,oStrFQ5Q,"FQ5QTD")

oView:AddOtherObject("btnMarcaDesm1", {|oPanel,oView| LOCA259EBT(oPanel, "FQ5BEM")})
oView:AddOtherObject("btnMarcaDesm2", {|oPanel,oView| LOCA259EBT(oPanel, "FQ5QTD")})

oView:AddField( 'VIEW_CALC1', oCalc1, 'RODAPE1' )
oView:AddField( 'VIEW_CALC2', oCalc2, 'RODAPE2' )

oView:addIncrementField("VIEWMAQ","ITEM")
	
oView:SetViewProperty( "VIEW_CALC1", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 85} )
oView:SetViewProperty( "VIEW_CALC2", "SETLAYOUT", { FF_LAYOUT_HORZ_DESCR_TOP , 6, 85} )	
//
oView:SetOwnerView('VIEW_MASTER', 'CAB') 
oView:SetOwnerView('VIEWFQ5Q', 'BOXFQ5Q')
oView:SetOwnerView('VIEWMAQ', 'BOXRESU')
oView:SetOwnerView('VIEWFQ5B', 'BOXFQ5B')
oView:SetOwnerView('VIEW_CALC1', 'RODAPE01')
oView:SetOwnerView('VIEW_CALC2', 'RODAPE02')
oView:SetOwnerView("btnMarcaDesm1", 'BOTAO01')
oView:SetOwnerView("btnMarcaDesm2", 'BOTAO02')

oView:SetOnlyView("VIEW_MASTER")
//Definindo que não irá usar o "Salvar e Criar Novo"
oView:SetCloseOnOk({|| .T.})
oView:EnableControlBar(.T.)
oView:SetProgressBar(.T.)
oView:setUpdateMessage(STR0066,STR0065) //"Processo finalizado com sucesso"
oView:SetViewProperty("*", "GRIDSEEK", {.T.})
oView:SetViewProperty("*", "GRIDFILTER", {.T.})

Return oView
