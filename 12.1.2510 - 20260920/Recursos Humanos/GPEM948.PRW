#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM948.CH"

#DEFINE CRLF	CHR(13) + CHR(10)

Static oSX3
Static oQrySRA
Static oQrySRD
Static oQrySRR
Static aFuncDet
Static oQrySRH

/*/{Protheus.doc} GPEM948
Programa MVC para identificação de funcionários que podem ter os eventos S-1200/S-1210 inconsistentes,
nos meses com férias e possibilitar o ajuste.
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Function GPEM948()
	
	Local aSays		:= {}
	Local aButtons	:= {}

	aAdd(aSays,OemToAnsi( STR0067 )) //"Esta rotina tem o objetivo de analisar e realizar ajustes nos valores de férias devido a nova"
	aAdd(aSays,OemToAnsi( STR0068 )) //"sistemática do PIS no eSocial. A correção se baseia em criar a verba de identificador de"
	aAdd(aSays,OemToAnsi( STR0069 )) //"cálculo 1987 - Informativa Dedutora Abono PIS nas Férias, evitando duplicidade de"
	aAdd(aSays,OemToAnsi( STR0070 )) //"valores na base de cálculo. "
	aAdd(aSays,OemToAnsi( "" ))
	aAdd(aSays,OemToAnsi( STR0071 ))  //"Para maiores informações sobre configurações e procedimentos a serem realizados,"
	aAdd(aSays,OemToAnsi( STR0072 ))  //"consulte nossa documenação clicando em Abrir. Clique em Ok para continuar."
	aAdd(aButtons, { 14,.T.,{|| ShellExecute( "open", "https://tdn.totvs.com/x/XmvlPw", "", "", 1 ) } } )
	aAdd(aButtons, { 1, .T.,{|| FechaBatch() }} )

	FormBatch( OemToAnsi( STR0073 ) , aSays, aButtons )  //"PIS - Nova Sistemática"

	If !Pergunte("GPM948", .T.)
		//"Faltam Atualizações!"
		//"Para executar esta rotina é preciso que exista o grupo de perguntas 'GPM948'. Por favor, aplique as últimas atualizações de dicionário."
		FWAlertError(OemToAnsi(STR0074), OemToAnsi(STR0075))
		Return
	EndIf

	FWExecView(OemToAnsi(STR0001), "GPEM948", MODEL_OPERATION_UPDATE, , {|| .T. }) //"Avaliação funcionários elegíveis"

Return

/*/{Protheus.doc} ModelDef
Definição do modelo MVC (cabeçalho e grid).
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function ModelDef()
	Local oModel     := MPFormModel():New("GPEM948", NIL, NIL, {|oMdl| CommitMdl(oMdl) })
	Local oStructCab := StruCab()
	Local oStructDet := StruDet()

	oModel:SetDescription(OemToAnsi(STR0002)) //"Inconsistências Abono Salarial/PIS"

	oModel:AddFields("GP948_MCAB", NIL, oStructCab, NIL, NIL, {|oMdl| CargaCab(oMdl) })
	oModel:GetModel("GP948_MCAB"):SetDescription(OemToAnsi(STR0003)) //"Filtros"
	oModel:GetModel("GP948_MCAB"):SetOnlyView(.F.)

	oModel:AddGrid("GP948_MDET", "GP948_MCAB", oStructDet, NIL, NIL, NIL, NIL, {|oMdl| CargaDet(oMdl) })
	oModel:GetModel("GP948_MDET"):SetDescription(OemToAnsi(STR0004)) //"Recomendável gerar novamente os eventos S-1200/S-1210 dos meses de férias"
	oModel:GetModel("GP948_MDET"):SetOptional(.T.)
	oModel:GetModel("GP948_MDET"):SetNoInsertLine(.T.)
	oModel:GetModel("GP948_MDET"):SetNoDeleteLine(.T.)
	oModel:GetModel("GP948_MDET"):SetNoUpdateLine(.F.)
    oModel:GetModel("GP948_MDET"):SetMaxLine(99999)

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da view MVC (interface visual com folder, grid e botões).
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function ViewDef()
	Local oView    := FWFormView():New()
	Local oModel   := FWLoadModel("GPEM948")
	Local oCabView := ViewCab()
	Local oDetView := ViewDet()

	oView:SetModel(oModel)
	oView:AddField("GP948_VCAB", oCabView, "GP948_MCAB")
	oView:AddGrid("GP948_VDET", oDetView, "GP948_MDET")
	oView:AddOtherObject("GP948_BCAR", {|oPanel| BtnCarregar(oPanel, oView) })
	oView:SetViewProperty("GP948_VDET", "GRIDDOUBLECLICK", {{|oForm, cField, nLineGrid, nLineModel| ShowDet(oForm, cField, nLineGrid, nLineModel)}})

	oView:CreateHorizontalBox("BOX_TOP", 20)
	oView:CreateVerticalBox("GP948_CAMP", 72, "BOX_TOP")
	oView:CreateVerticalBox("GP948_BUTN", 28, "BOX_TOP")
	oView:CreateHorizontalBox("BOX_GRID", 80)

	oView:SetOwnerView("GP948_VCAB", "GP948_CAMP")
	oView:SetOwnerView("GP948_BCAR", "GP948_BUTN")
	oView:SetOwnerView("GP948_VDET", "BOX_GRID")

	oView:EnableTitleView("GP948_VDET", OemToAnsi(STR0004)) //"Recomendável gerar novamente os eventos S-1200/S-1210 dos meses de férias"

	oView:AddUserButton(OemToAnsi(STR0013), "MAGIC_BMP", {|| setPergunt() }, OemToAnsi(STR0013), NIL, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW }) //"Parâmetros"
	oView:AddUserButton(OemToAnsi(STR0014), "MAGIC_BMP", {|oMdl| SelTodos(oMdl) }, OemToAnsi(STR0014), NIL, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW }) //"Marcar/Desmarcar todos"

	oView:SetCloseOnOk({ || .T. })

Return oView

/*/{Protheus.doc} BtnCarregar
Cria botões de carregamento e parâmetros no cabeçalho da view.
@author martins.marcio
@since 11/04/2026
@version 1.1
@param oPanel, Object, Painel do cabeçalho
@param oView, Object, View MVC ativa
@return NIL
/*/
Static Function BtnCarregar(oPanel, oView)
	@ 09, 05 BUTTON " >> "+ OemToAnsi(STR0005) +" << " SIZE 180, 16 PIXEL OF oPanel ACTION LoadGrid(oView:GetModel()) //"CARREGAR FUNCIONÁRIOS"
Return

/*/{Protheus.doc} SelTodos
Marca ou desmarca todos os registros não deletados do grid.
@author martins.marcio
@since 27/05/2026
@version 1.0
@param oModel, Object, Modelo MVC ativo
@return lRet, Logical, .T. quando executado com sucesso
/*/
Static Function SelTodos(oModel)
	Local oDet   := oModel:GetModel("GP948_MDET")
	Local oView  := FWViewActive()
	Local nLin   := 0
	Local lMarc  := .T.
	Local lRet   := .T.

	Default oModel := Nil

	If !(oDet:Length() == 0 .Or. (oDet:Length() == 1 .And. Empty(oDet:GetValue("DET_MAT"))))
		For nLin := 1 To oDet:Length()
			oDet:GoLine(nLin)
			If !(oDet:IsDeleted())
				If !oDet:GetValue("DET_SEL")
					lMarc := .F.
					Exit
				EndIf
			EndIf
		Next nLin

		For nLin := 1 To oDet:Length()
			oDet:GoLine(nLin)
			If !(oDet:IsDeleted())
				lRet := lRet .And. oDet:SetValue("DET_SEL", !lMarc)
			EndIf
		Next nLin

		If ValType(oView) == "O"
			oDet:GoLine(1)
			oView:Refresh("GP948_VDET")
		EndIf		
	EndIf

Return lRet

/*/{Protheus.doc} StruCab
Estrutura do cabeçalho (filtros).
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function StruCab()
	Local oStru  := FWFormModelStruct():New()
	Local bVazio := {|| .T.}
	Local cAno   := SubStr(DtoS(Date()), 1, 4)

	oStru:AddField(OemToAnsi(STR0006)	, OemToAnsi(STR0006)	, "CAB_FILIAIS", "C", 200, 0, bVazio, bVazio, {}, .F., {|| xFilial("SRA") }, NIL, NIL, .F.) //"Filiais"
	oStru:AddField(OemToAnsi(STR0007)   , OemToAnsi(STR0007)	, "CAB_ANO"    , "C",   4, 0, bVazio, bVazio, {}, .F., {|| cAno }, NIL, NIL, .F.) //"Ano Base"
	oStru:AddField(OemToAnsi(STR0008)	, OemToAnsi(STR0008)	, "CAB_SALMIN" , "N",  16, 2, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Salário Mín. no Ano Base"
	oStru:AddField(OemToAnsi(STR0009)	, OemToAnsi(STR0009)    , "CAB_TETPIS" , "N",  16, 2, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Teto PIS Considerado (Média 12m)"

Return oStru

/*/{Protheus.doc} ViewCab
Estrutura visual dos filtros.
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function ViewCab()
	Local oStru := FWFormViewStruct():New()

	oStru:AddField("CAB_FILIAIS", "01", OemToAnsi(STR0006)    , OemToAnsi(STR0010) , NIL, "C", "@!", NIL, "", .F., "", "", {}, 0, "", .F.) //"Filiais" //"Filiais separadas por ;"
	oStru:AddField("CAB_ANO"    , "02", OemToAnsi(STR0007)  , OemToAnsi(STR0007)         , NIL, "C", "@!", NIL, "", .F., "", "", {}, 0, "", .F.) //"Ano Base"
	oStru:AddField("CAB_SALMIN" , "03", OemToAnsi(STR0011), OemToAnsi(STR0012)   , NIL, "N", "@E 999,999,999,999.99", NIL, "", .F., "", "", {}, 0, "", .F.) //"Salário Mín. (S004)" //"Salário mínimo"
	oStru:AddField("CAB_TETPIS" , "04", OemToAnsi(STR0009), OemToAnsi(STR0009)   , NIL, "N", "@E 999,999,999,999.99", NIL, "", .T., "", "", {}, 0, "", .F.) //"Teto PIS Considerado (Média 12m)" //"Teto para elegibilidade do abono"
	oStru:SetProperty("CAB_TETPIS", MVC_VIEW_CANCHANGE, .T.)

Return oStru

/*/{Protheus.doc} StruDet
Estrutura do grid de resultado. Utiliza metadados SX3 (retornados por fSX3Load) para
obter títulos, descrições, tipos e formatos de campos exibidos no grid.
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function StruDet()
	Local oStru  := FWFormModelStruct():New()
	Local bVazio := {|| .T.}

	DEFAULT oSX3 := fSX3Load()

	oStru:AddField(OemToAnsi(STR0015), OemToAnsi(STR0016), "DET_SEL"   , "L"                , 1                    , 0, bVazio, bVazio, {}, .F., {|| .F. }, NIL, NIL, .F.) //"Sel." //"Marcar/Desmarcar linha"
	oStru:AddField(oSX3["FIL"]["TIT"], oSX3["FIL"]["DES"], "DET_FILIAL", oSX3["FIL"]["TIP"], oSX3["FIL"]["LEN"], oSX3["FIL"]["DEC"], bVazio, bVazio, {}, .F., , NIL, NIL, .F.)
	oStru:AddField(oSX3["MAT"]["TIT"], oSX3["MAT"]["DES"], "DET_MAT"   , oSX3["MAT"]["TIP"], oSX3["MAT"]["LEN"], oSX3["MAT"]["DEC"], bVazio, bVazio, {}, .F., , NIL, NIL, .F.)
	oStru:AddField(oSX3["NOM"]["TIT"], oSX3["NOM"]["DES"], "DET_NOME"  , oSX3["NOM"]["TIP"], oSX3["NOM"]["LEN"], oSX3["NOM"]["DEC"], bVazio, bVazio, {}, .F., , NIL, NIL, .F.)
	oStru:AddField(oSX3["CPF"]["TIT"], oSX3["CPF"]["DES"], "DET_CPF"   , oSX3["CPF"]["TIP"], oSX3["CPF"]["LEN"], oSX3["CPF"]["DEC"], bVazio, bVazio, {}, .F., , NIL, NIL, .F.)
	oStru:AddField(OemToAnsi(STR0034), OemToAnsi(STR0034), "DET_TOTATU", "N", 16, 2, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Total Rend. Atual"
	oStru:AddField(OemToAnsi(STR0035), OemToAnsi(STR0035), "DET_MEDATU", "N", 16, 2, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Remun. Média Atual"
	oStru:AddField(OemToAnsi(STR0036), OemToAnsi(STR0036), "DET_TOTREN", "N", 16, 2, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Total Rend. a Considerar"
	oStru:AddField(OemToAnsi(STR0037), OemToAnsi(STR0037), "DET_REMMED", "N", 16, 2, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Remun. Média a Considerar"
	oStru:AddField(OemToAnsi(STR0038), OemToAnsi(STR0039), "DET_QTDVNC", "N", 4, 0, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Qtd Vinc." //"Quantidade de vínculos"
	oStru:AddField(OemToAnsi(STR0100), OemToAnsi(STR0101), "DET_DIFREM", "C", 1, 0, bVazio, bVazio, {OemToAnsi(STR0102),OemToAnsi(STR0103)}, .F., , NIL, NIL, .F.) //"Possui diferença?" //"1-Sim / 2-Não"
	oStru:AddField(OemToAnsi(STR0040), OemToAnsi(STR0040), "DET_MESFR", "C", 40, 0, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Mês de Férias"

Return oStru

/*/{Protheus.doc} ViewDet
Estrutura visual do grid de resultado.
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function ViewDet()
	Local oStru := FWFormViewStruct():New()

	DEFAULT oSX3 := fSX3Load()

	oStru:AddField("DET_SEL"   , "01", OemToAnsi(STR0015)            , OemToAnsi(STR0016), NIL, "L", "@", NIL, "", .T., "", "", {}, 0, "", .F.) //"Sel." //"Marcar/Desmarcar linha"
	oStru:AddField("DET_NOME"  , "02", oSX3["NOM"]["TIT"], oSX3["NOM"]["DES"], NIL, oSX3["NOM"]["TIP"], oSX3["NOM"]["PIC"], NIL, oSX3["NOM"]["F3"], .F., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_CPF"   , "03", oSX3["CPF"]["TIT"], oSX3["CPF"]["DES"], NIL, oSX3["CPF"]["TIP"], oSX3["CPF"]["PIC"], NIL, oSX3["CPF"]["F3"], .F., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_TOTATU", "04", OemToAnsi(STR0034), OemToAnsi(STR0034), NIL, "N", "@E 999,999,999,999.99", NIL, "", .F., "", "", {}, 0, "", .F.) //"Total Rend. Atual"
	oStru:AddField("DET_MEDATU", "05", OemToAnsi(STR0035), OemToAnsi(STR0035), NIL, "N", "@E 999,999,999,999.99", NIL, "", .F., "", "", {}, 0, "", .F.) //"Remun. Média Atual"
	oStru:AddField("DET_TOTREN", "06", OemToAnsi(STR0036), OemToAnsi(STR0036), NIL, "N", "@E 999,999,999,999.99", NIL, "", .F., "", "", {}, 0, "", .F.) //"Total Rend. a Considerar"
	oStru:AddField("DET_REMMED", "07", OemToAnsi(STR0037), OemToAnsi(STR0037), NIL, "N", "@E 999,999,999,999.99", NIL, "", .F., "", "", {}, 0, "", .F.) //"Remun. Média a Considerar"
	oStru:AddField("DET_QTDVNC", "08", OemToAnsi(STR0038), OemToAnsi(STR0039), NIL, "N", "9999", NIL, "", .F., "", "", {}, 0, "", .F.) //"Qtd Vinc." //"Quantidade de vínculos"
	oStru:AddField("DET_DIFREM", "09", OemToAnsi(STR0100), OemToAnsi(STR0101), NIL, "C", "@!", NIL, "", .F., "", "", {OemToAnsi(STR0102),OemToAnsi(STR0103)}, 0, "", .F.) //"Possui diferença?" //"1-Sim / 2-Não"
	oStru:AddField("DET_MESFR", "10", OemToAnsi(STR0040), OemToAnsi(STR0040), NIL, "C", "", NIL, "", .F., "", "", {}, 0, "", .F.) //"Mês de Férias"

	oStru:SetProperty("DET_SEL", MVC_VIEW_CANCHANGE, .T.)

Return oStru

/*/{Protheus.doc} CargaCab
Carga inicial do cabeçalho.
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function CargaCab(oModel)
	Local aRet := {}
	Local cFil := ""
	Local cAno := ""
	Local nSalMin := 0
	Local nTetPis := 0

	Default oModel := Nil

	cFil    := AllTrim(MV_PAR01)
	cAno    := AllTrim(cValToChar(MV_PAR02))
	nSalMin := GetSalMin(cAno)
	nTetPis := IIf(ValType(MV_PAR09) == "N" .And. MV_PAR09 > 0, MV_PAR09, (nSalMin * 2))

	aRet := {;
		cFil,;
		cAno,;
		nSalMin,;
		nTetPis;
	}

Return aRet

/*/{Protheus.doc} CargaDet
Carga inicial do grid (vazio).
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function CargaDet(oModel)
	Default oModel := Nil
Return {}

/*/{Protheus.doc} setPergunt
Executa pergunta de parâmetros e atualiza o cabeçalho com novos valores.
Seguindo a mesma lógica da função CargaCab.
@author martins.marcio
@since 27/05/2026
@version 1.1
@param oView, Object, View MVC ativa
@return lRet, Logical, .T. quando os parâmetros são alterados
/*/
Static Function setPergunt(oView)
	Local oCab      := Nil
	Local oViewAtv  := Nil
	Local cFil      := ""
	Local cAno      := ""
	Local nSalMin   := 0
	Local nTetPis   := 0
	Local lRet      := .F.

	Default oView := Nil

	If Pergunte("GPM948", .T.)
		oViewAtv := FWViewActive()
		
		If ValType(oViewAtv) == "O"
			oCab := oViewAtv:GetModel():GetModel("GP948_MCAB")

			cFil    := AllTrim(MV_PAR01)
			cAno    := AllTrim(cValToChar(MV_PAR02))
			nSalMin := GetSalMin(cAno)
			nTetPis := IIf(ValType(MV_PAR09) == "N" .And. MV_PAR09 > 0, MV_PAR09, (nSalMin * 2))

			oCab:LoadValue("CAB_FILIAIS", cFil)
			oCab:LoadValue("CAB_ANO", cAno)
			oCab:LoadValue("CAB_SALMIN", nSalMin)
			oCab:LoadValue("CAB_TETPIS", nTetPis)

			oViewAtv:Refresh("GP948_VCAB")

			lRet := .T.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} LoadGrid
Inicia a carga do grid com barra de progresso. Esta rotina cria um processo
de execução e delega o processamento para ProcLdGrid, exibindo uma régua
de progresso enquanto os dados são carregados.
@author martins.marcio
@since 11/04/2026
@version 1.1
@param oModel, Object, Modelo MVC ativo
@return lRet, Logical, .T. quando o processamento conclui
/*/
Static Function LoadGrid(oModel)
	Local cTitulo  := OemToAnsi(STR0024) //"Processando carga"
	Local cDesc    := OemToAnsi(STR0025) //"Carregando dados, aguarde..."
	Local oProcess := Nil
	Local lRet     := .F.

	Default oModel := Nil

	oProcess := MsNewProcess():New({|lEnd| lRet := ProcLdGrid(oProcess, oModel, @lEnd) }, cTitulo, cDesc, .T.)
	
	oProcess:Activate()

Return lRet

/*/{Protheus.doc} ProcLdGrid
Executa a carga do grid com barra de progresso.
@author martins.marcio
@since 11/04/2026
@version 1.1
@param oProcess, Object, Objeto de progresso
@param oModel, Object, Modelo MVC ativo
@param lEnd, Logical, Controle de cancelamento do processamento
@return lRet, Logical, .T. quando o processamento conclui
/*/
Static Function ProcLdGrid(oProcess, oModel, lEnd)
	Local oCab       := oModel:GetModel("GP948_MCAB")
	Local oDet       := oModel:GetModel("GP948_MDET")
	Local oView      := FWViewActive()
	Local cFiliais   := AllTrim(oCab:GetValue("CAB_FILIAIS"))
	Local cAno       := AllTrim(cValToChar(oCab:GetValue("CAB_ANO")))
	Local nLin       := 0
	Local nCarga     := 0
	Local cMat       := ""
	Local oInfoPIS   := Nil
	Local aMesesFer  := {}
	Local cMesesFer  := ""
	Local nTotRen    := 0
	Local nRemMed    := 0
	Local nTotSRR    := 0
	Local nRemMedSRR := 0
	Local nQtdVnc    := 0
	Local cDifRem    := "2"
	Local cTrab30    := "2"
	Local nTotReg    := 0

	DEFAULT oSX3     := fSX3Load()
	DEFAULT aFuncDet := {}
	DEFAULT oProcess := Nil
	DEFAULT oModel   := Nil
	DEFAULT lEnd     := .F.

	aFuncDet := getFunApto(cAno, cFiliais, oProcess, oCab:GetValue("CAB_TETPIS"))
	nTotReg := Len(aFuncDet)

	If ValType(oProcess) == "O"
		oProcess:SetRegua1(Max(nTotReg, 1))
	EndIf

	oDet:SetNoUpdateLine(.F.)
	oDet:SetNoInsertLine(.F.)
	// Limpa completamente o grid antes de recarregar sem deixar linhas marcadas como deletadas
	oDet:ClearData(.F., .F.)

	For nLin := 1 To nTotReg
		If ValType(oProcess) == "O"
			oProcess:IncRegua1(OemToAnsi(STR0026) + AllTrim(aFuncDet[nLin][2]) + " [" + AllTrim(Str(nLin)) + "/" + AllTrim(Str(nTotReg)) + "]") //"Carregando funcionário "
		EndIf

		oInfoPIS   := aFuncDet[nLin][5]
		aMesesFer  := {}
		cMesesFer  := ""
		nTotRen    := 0
		nRemMed    := 0
		nTotSRR    := 0
		nRemMedSRR := 0
		nQtdVnc    := 0
		cDifRem    := "2"
		cTrab30    := "2"

		If !oDet:AddLine(.T.)
			// Loop
		EndIf
		oDet:GoLine(oDet:Length())

		oDet:SetValue("DET_SEL", .T.)
		If ValType(oInfoPIS) == "J"
			cTrab30    := IIf(ValType(oInfoPIS["TRABALHOU30"]) == "L" .And. oInfoPIS["TRABALHOU30"], "1", "2")
			aMesesFer  := oInfoPIS["MESESFERIAS"]
			nTotRen    := oInfoPIS["VLRTOT"]
			nRemMed    := oInfoPIS["REMMED"]
			nTotSRR    := IIf(ValType(oInfoPIS["VLRTOTGER"]) == "N", oInfoPIS["VLRTOTGER"], 0)
			nRemMedSRR := IIf(ValType(oInfoPIS["REMMEDGER"]) == "N", oInfoPIS["REMMEDGER"], 0)
			nQtdVnc    := Len(oInfoPIS["VINCULOS"])

			If oInfoPIS["REMMEDGER"] <> oInfoPIS["REMMED"]
				cDifRem := "1"
			EndIf
		EndIf

		cMesesFer := FmtMesFer(aMesesFer)

		cMat := aFuncDet[nLin][2]

		oDet:SetValue("DET_FILIAL", aFuncDet[nLin][1])
		oDet:SetValue("DET_MAT", cMat)
		oDet:SetValue("DET_CPF", aFuncDet[nLin][3])
		oDet:SetValue("DET_NOME", aFuncDet[nLin][4])
		oDet:SetValue("DET_TOTREN", nTotRen)
		oDet:SetValue("DET_TOTATU", nTotSRR)
		oDet:SetValue("DET_REMMED", nRemMed)
		oDet:SetValue("DET_MEDATU", nRemMedSRR)
		oDet:SetValue("DET_DIFREM", cDifRem)
		oDet:SetValue("DET_QTDVNC", nQtdVnc)
		oDet:SetValue("DET_MESFR", cMesesFer)
		nCarga++
	Next nLin

	If nTotReg == 0 .And. oDet:Length() == 0
		If oDet:AddLine(.T.)
			oDet:GoLine(oDet:Length())
			oDet:SetValue("DET_SEL", .F.)
		EndIf
	EndIf

	If ValType(oView) == "O"
		If oDet:Length() > 0
			oDet:GoLine(1)
		EndIf
		oView:Refresh("GP948_VDET")
	EndIf

	oDet:SetNoInsertLine(.T.)

	FWAlertInfo(OemToAnsi(STR0029) + cAno + ". Registros carregados: " + AllTrim(Str(nCarga)), OemToAnsi(STR0030)) //"Busca concluída para o ano " //"Buscar"

Return .T.

/*/{Protheus.doc} ShowDet
Exibe os detalhes do funcionário selecionado no grid. Ignora o duplo-clique
quando o campo clicado for DET_SEL (checkbox), permitindo a seleção
natural da linha sem abrir o detalhe. Quando não há detalhes válidos para a
linha selecionada, exibe a mensagem padrão "Sem detalhes disponíveis para a
linha selecionada." via FWAlertInfo.
@author martins.marcio
@since 10/04/2026
@version 1.1
@param oForm, Object, Formulário da view
@param cField, Character, Campo clicado no grid
@param nLineG, Numeric, Linha selecionada no grid
@param nLineM, Numeric, Linha correspondente no model
@return lRet, Logical, .T. quando os detalhes são exibidos
*/
Static Function ShowDet(oForm, cField, nLineG, nLineM)
	Local nPos     := 0
	Local oInfo    := Nil
	Local oInfoDet := Nil
	Local cDet     := ""
	Local aVinc    := {}
	Local nVinc    := 0
	Local aMem     := {}
	Local aMemMes  := {}
	Local aMemTxt  := {}
	Local cMemMes  := ""
	Local nMes     := 0
	Local lRet     := .T.

	Default oForm  := Nil
	Default cField := ""
	Default nLineG := 0
	Default nLineM := 0

	If cField <> "DET_SEL" //DET_SEL só alterna seleção; não abre detalhe
		nPos := IIf(ValType(nLineM) == "N" .And. nLineM > 0, nLineM, IIf(ValType(nLineG) == "N" .And. nLineG > 0, nLineG, 0))

		If ValType(aFuncDet) == "A" .And. nPos > 0 .And. nPos <= Len(aFuncDet)
			oInfo := aFuncDet[nPos][5]

			oInfoDet := JsonObject():New()
			oInfoDet["TRABALHOU30"] := oInfo["TRABALHOU30"]
			oInfoDet["VLRTOT"]      := oInfo["VLRTOT"]
			oInfoDet["VLRTOTSRR"]   := oInfo["VLRTOTSRR"]
			oInfoDet["VLRTOTGER"]   := oInfo["VLRTOTGER"]
			oInfoDet["REMMED"]      := oInfo["REMMED"]
			oInfoDet["REMMEDSRR"]   := oInfo["REMMEDSRR"]
			oInfoDet["REMMEDGER"]   := oInfo["REMMEDGER"]
			oInfoDet["VLRMESSRR"]   := oInfo["VLRMESSRR"]
			oInfoDet["MESESFERIAS"] := oInfo["MESESFERIAS"]
			oInfoDet["CPF"]         := oInfo["CPF"]
			oInfoDet["NOME"]        := oInfo["NOME"]

			aVinc := IIf(ValType(oInfo["VINCULOS"]) == "A", oInfo["VINCULOS"], {})
			For nVinc := 1 To Len(aVinc)
				// aMemCalc está armazenada na posição 9 do vínculo: {filial,mat,dIni,dFim,nVlrRec,aMeses,aVlrRec,aVlrSRR,aMemCalc}
				aMem := IIf(ValType(aVinc[nVinc][9]) == "A", aVinc[nVinc][9], {})
				aMemTxt := {}
				For nMes := 1 To 12
					cMemMes := ""
					aMemMes := IIf(ValType(aMem) == "A" .And. Len(aMem) >= nMes .And. ValType(aMem[nMes]) == "A", aMem[nMes], {})
					// Armazena a memória por mês como ARRAY (lista de tokens) para melhor processamento posterior
					AAdd(aMemTxt, aMemMes)
				Next nMes

				If nVinc == 1
					oInfoDet["VINCULOS"] := {}
				EndIf
					AAdd(oInfoDet["VINCULOS"], { aVinc[nVinc][1], aVinc[nVinc][2], aVinc[nVinc][3], aVinc[nVinc][4], aVinc[nVinc][5], aVinc[nVinc][6], aVinc[nVinc][7], aVinc[nVinc][8], aMemTxt })
			Next nVinc

			cDet := FmtDetPi(oInfoDet)
		EndIf

		If !Empty(cDet)
			GPEM948A( { { cDet, oInfo["CPF"], oInfo["NOME"] } } )
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} CommitMdl
Commit do modelo 
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function CommitMdl(oModel)
	
    Local oDet          := oModel:GetModel("GP948_MDET")
    Local lContinua     := .T.
    Local lRet          := .T.
	Local aFilInTaf		:= {}
	Local aTitle		:= {}
    Local nX            := 0
	Local nCont			:= 0
	Local cTitulo		:= OemToAnsi("Processando Funcionários") //"Processando carga"
	Local cDesc			:= OemToAnsi("Realizando alterações, aguarde...") //"Realizando alterações, aguarde..."
	Local oProgress		:= Nil

    Private aLog        := {}
	Private lMiddleware := Iif( cPaisLoc == 'BRA', fVerMW(), .F. )
	Private jListFils 	:= JsonObject():New()
	Private JListMes	:= JsonObject():New()
	Private aCodFol		:= {}
	Private cVbDed91 := SuperGetMv( "MV_PISIN91", .F., "" )

    Default oModel := Nil

    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
    Fp_CodFol(@aCodFol, xFilial("SRV", cFilAnt), .F., .F.)

    //Verifica se a verba foi cadastrada
    If Len(aCodFol) >= 1987
        lContinua := (!Empty( aCodFol[1987,1] ))
		
		If !lContinua
			lRet := .F.
			//"Não foi localizado o cadastro da verba de Identificador 1987 - Informativa Dedutora Abono PIS nas Férias"
			//"Realize o cadastro de uma verba utilizando este identificador para prosseguir."
			oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0076),OemToAnsi(STR0077))
		EndIf
	EndIf

    //Conta quantos registros serão processados
    If lContinua
        For nX := 1 To oDet:Length()
            oDet:GoLine(nX)
            If oDet:GetValue("DET_SEL")
                nCont++
            EndIf
        Next Nx

		//"Serão processados "
		//" registros. Deseja continuar?"
		//"Confirmação"
        lContinua := MsgYesNo(OemToAnsi(STR0078) + cValToChar(nCont) + OemToAnsi(STR0079), OemToAnsi(STR0080))

        If !lContinua
			//"Cancelado pelo usuário"
			//"Revise os registros selecionados e confirme se os dados estiverem corretos."
            oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0081), OemToAnsi(STR0082))
            lRet := .F.
        EndIf
    EndIf

	If lContinua
		//Se for TAF carrega a lista de filiais
		If !lMiddleware
			fGp23Cons(aFilInTaf)
			jListFils := fCarrFils(aFilInTaf)
		EndIf

		JListMes := fListNomMes()

		Aadd( aLog, {} )

		oProgress := MsNewProcess():New({|lEnd| lRet := fCommitProc(oProgress, oModel, @lEnd, nCont) }, cTitulo, cDesc, .T.)
		oProgress:Activate()

		//"Foram gerados eventos de retificação para os funcionários processados, consulta o log geração e faça a transmissão dos eventos!"
		//"Foram realizados ajustes nos lançamentos de férias (Tabela SRR), consulta o log de processamento, faça a geração do evento S-1200 nos períodos indicados e faça a transmissão!"		
		Iif(!lMiddleware, FWAlertWarning(OemToAnsi(STR0090)), FWAlertWarning(OemToAnsi(STR0091)))

        Aadd( aTitle, OemToAnsi( STR0092 )) //"Funcionários processados" 
        fMakeLog(aLog,aTitle,,,"GPEM948",OemToAnsi( STR0093 ),"M","P",,.F.) //"Log de Ocorrências"
	EndIf

Return lRet

/*/{Protheus.doc} CommitMdl
Commit do modelo 
@author martins.marcio
@since 07/04/2026
@version 1.0
/*/
Static Function fCommitProc(oProgress, oModel, lEnd, nCont)
	
    Local oCab          := oModel:GetModel("GP948_MCAB")
    Local oDet          := oModel:GetModel("GP948_MDET")
    Local oInfo         := Nil
    Local cAno          := oCab:GetValue("CAB_ANO")
    Local cAliasSRH     := GetNextAlias()
    Local lContinua     := .T.
    Local lRet          := .T.
    Local cFilOld       := ""
    Local cVb1870       := ""
    Local cVb1987       := ""
    Local cQuery        := ""
    Local cFilFunc      := ""
    Local cMatFunc      := ""
    Local cDtPesqI      := ""
    Local cDtPesqF      := ""
    Local cNaturezVb    := ""
    Local cTipoCodVb    := ""
    Local cPer          := ""
    Local cSem          := ""
    Local cSeq          := ""
    Local cCenCus       := ""
	Local cFilEnv		:= ""
	Local cPrefixo		:= ""
    Local dDtRef        := CTOD("//")
    Local dDtPag        := CTOD("//")
    Local dData         := CTOD("//")
    Local aMesExtFer    := {}
    Local nX            := 0
    Local nVinc         := 0
	Local nTotVinc		:= 0
    Local nVal1870      := 0
	Local nVal1891      := 0
    Local nVlrId1987    := 0
    Local nVlNat1017    := 0
    Local nVlrDed91    := 0
    Local nNew1870      := 0
	Local nNew1891      := 0
    Local nPosFDet      := 0
	Local nQdtFerRec	:= 0
	Local nItem			:= 0    

    Default oProgress	:= Nil
	Default oModel		:= Nil
	Default lEnd		:= .F.
	Default nCont		:= 0

	If ValType(oProgress) == "O"
		oProgress:SetRegua1(Max(nCont, 1))
	EndIf

    //Processa os registros marcados
    If lContinua

		Aadd( aLog, {} )
		
		DbSelectArea("SRR")
        // Varre os itens para ajustar os funcionários com inconsistência
        For nX := 1 To oDet:Length()
            oDet:GoLine(nX)
            If oDet:GetValue("DET_SEL")

                //Procura o funcionário no array de detalhamento
                cCPFFunc := oDet:GetValue("DET_CPF")
                nPosFDet := aScan(aFuncDet, { |x| x[3] == cCPFFunc })
				nItem++

				If ValType(oProgress) == "O"
					oProgress:IncRegua1(OemToAnsi("Processando Funcionário ") + cCPFFunc + " [" + AllTrim(Str(nItem)) + "/" + AllTrim(Str(nCont)) + "]") //"Carregando funcionário "
				EndIf

                aMesExtFer  := StrTokArr(Replace(Alltrim(oDet:GetValue("DET_MESFR")), ", ", " e "), " e ")
                
                If Len(aMesExtFer) > 0
                    cDtPesqI    := cAno + JListMes[aMesExtFer[1]] + "01"
                    cDtPesqF    := cAno + JListMes[aMesExtFer[Len(aMesExtFer)]] + "31"
                EndIf

                //Carrega o objeto que contém os vinculos
                oInfo		:= aFuncDet[nPosFDet][5]
				nTotVinc	:= Len(oInfo["VINCULOS"])

                aAdd( aLog[1],  OemToAnsi( STR0083 + cCPFFunc + " - " + AllTrim(oDet:GetValue("DET_NOME")))) //"Trabalhador: "

                //Processa cada um dos vínculos do CPF encontrado
                For nVinc := 1 To nTotVinc
                    dDtPag      := CTOD("//")
					cAliasSRH   := GetNextAlias()
                    cFilFunc    := oInfo["VINCULOS"][nVinc][1]
                    cMatFunc    := oInfo["VINCULOS"][nVinc][2]

                    cVb1870 := aCodFol[1870,1] // Informativa dedutora da Base de INSS nas férias
                    cVb1987 := aCodFol[1987,1] // Informativa dedutora do PIS nas férias
                    cVb1891 := aCodFol[1891,1] // Informativa dedutora da Base de INSS nas férias

                    //Carrega o array aCodFol para verificar o cadastro de verbas x Ids de cálculo
                    If xFilial("SRV", cFilFunc) != xFilial("SRV", cFilOld)
                        cFilOld := cFilFunc
                        RstaCodFol()
                        Fp_CodFol(@aCodFol, cFilFunc, .F., .F.)

                        cVb1870 := aCodFol[1870,1] // Informativa dedutora da Base de INSS nas férias
                        cVb1987 := aCodFol[1987,1] // Informativa dedutora do PIS nas férias
						cVb1891 := aCodFol[1891,1] // Informativa dedutora da Base de INSS nas férias
                    EndIf
                    
                    //Procura os dados dos vínculos informados para ajuste nas férias
                    If oQrySRH == Nil
                        cQuery := "SELECT RH_FILIAL, RH_MAT, RH_PROCES, RH_PERIODO, RH_ROTEIR, RH_DTRECIB, RH_DFERIAS, RH_DATAINI, RH_DTRECIB "
                        cQuery += "FROM " + RetSqlName('SRH') + " SRH "
                        cQuery += "WHERE SRH.RH_FILIAL = ? AND "
                        cQuery += 		"SRH.RH_MAT = ? AND "
                        cQuery += 		"SRH.RH_DTRECIB BETWEEN ? AND ? AND "
                        cQuery += 		"SRH.D_E_L_E_T_ = ' ' "
                        cQuery += "ORDER BY RH_FILIAL, RH_MAT, RH_PERIODO, RH_DATAINI "

                        cQuery := ChangeQuery(cQuery)
                        oQrySRH := FwExecStatement():New(cQuery)
                    EndIf

                    oQrySRH:SetString(1, cFilFunc)
                    oQrySRH:SetString(2, cMatFunc)
                    oQrySRH:SetString(3, cDtPesqI)
                    oQrySRH:SetString(4, cDtPesqF)
                    cAliasSRH := oQrySRH:OpenAlias()

                    DbSelectArea(cAliasSRH)
                    (cAliasSRH)->(DbGoTop())
                    
                    If !(cAliasSRH)->(Eof())
                        While !(cAliasSRH)->(Eof())
                            SRR->(DbsetOrder(3))
                            SRR->(dbGoTop())
                            If SRR->(dbSeek((cAliasSRH)->RH_FILIAL + (cAliasSRH)->RH_MAT + "F" + (cAliasSRH)->(RH_DATAINI)))    
                                                
                                //Reinicia variáveis
                                nVal1870    := 0
                                nVlrId1987  := 0
                                nVlNat1017  := 0
                                nNew1870    := 0

                                nVal1891    := 0
                                nVlrDed91  := 0
                                nNew1891    := 0

								Iif(dDtPag == SRR->RR_DATAPAG, nQdtFerRec++, nQdtFerRec := 0)
                                
                                //Carrega variáveis utilizadas na gravação
                                dData   := SRR->RR_DATA
                                cPer    := SRR->RR_PERIODO
                                cSem    := SRR->RR_SEMANA
                                dDtPag  := SRR->RR_DATAPAG
                                cSeq    := SRR->RR_SEQ
                                dDtRef  := SRR->RR_DTREF
                                cCenCus := SRR->RR_CC

								//Verifica se o idDmDev é criado com prefixo
								cPrefixo := fGetPrefixo(cFilFunc, cMatFunc, cPer, cCPFFunc, .F.)

                                While SRR->(!Eof()) .And. (SRR->RR_FILIAL + SRR->RR_MAT + SRR->RR_TIPO3 + DTOS(SRR->RR_DATA)) == ((cAliasSRH)->RH_FILIAL + (cAliasSRH)->RH_MAT + "F" + (cAliasSRH)->RH_DATAINI)

                                    //Identifica o valor da verba de Id 1870.
                                    If SRR->RR_PD == cVb1870
                                        nVal1870 := SRR->RR_VALOR
                                    EndIf

                                    If SRR->RR_PD == cVb1891
                                        nVal1891 := SRR->RR_VALOR
                                    EndIf

                                    cNaturezVb := RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_NATUREZ' )
                                    cTipoCodVb := RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_TIPOCOD' )

                                    //Identifica os valores das naturezas 1016 e 1017.
                                    If !(SRR->RR_PD == cVb1987) .And.  If(!Empty(cVbDed91), !(SRR->RR_PD == cVbDed91), .T.)
                                        If cNaturezVb == "1016" .And. RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_INCCP' ) == "11"
                                            nVlrId1987 += Iif(cTipoCodVb $ "1|3", SRR->RR_VALOR, SRR->RR_VALOR * -1)
                                        ElseIf cNaturezVb == "1016" .And. RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_INCCP' ) == "91"
                                            nVlrDed91 += Iif(cTipoCodVb $ "1|3", SRR->RR_VALOR, SRR->RR_VALOR * -1)
							            ElseIf cNaturezVb == "1017"
                                            nVlNat1017 += Iif(cTipoCodVb $ "1|3", SRR->RR_VALOR, SRR->RR_VALOR * -1)
                                        EndIf
                                    EndIf

                                    //Identifica o valor de natureza 1016 e incidência CP 11 para deduzir na verba de Id 1870.
                                    If SRR->RR_PD <> cVb1870 .And. cNaturezVb <> "1016" .And. RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_INCCP' ) == "11"
                                        nNew1870 += Iif(cTipoCodVb $ "1|3", SRR->RR_VALOR, SRR->RR_VALOR * -1) 
                                    EndIf 

                                    //Identifica o valor de natureza 1016 e incidência CP 11 para deduzir na verba de Id 1891
                                    If SRR->RR_PD <> cVb1891 .And. cNaturezVb <> "1016" .And. RetValSrv( SRR->RR_PD, SRR->RR_FILIAL, 'RV_INCCP' ) == "91"
                                        nNew1891 += Iif(cTipoCodVb $ "1|3", SRR->RR_VALOR, SRR->RR_VALOR * -1) 
                                    EndIf 

                                    SRR->(DbSkip())
                                EndDo

                                If ((nVal1870 == (nVlrId1987 + nNew1870)) .Or. nVal1870 == nNew1870 ) .Or. (!Empty(cVbDed91) .And. (nVal1891 == (nVlrDed91 + nNew1891) .Or. nVal1891 == nNew1891))
                                    Begin Transaction

										If !lMiddleware
											cFilEnv := Iif(jListFils:HasProperty((cAliasSRH)->RH_FILIAL), jListFils[(cAliasSRH)->RH_FILIAL][2], (cAliasSRH)->RH_FILIAL)
											If nTotVinc > 1
												cFilEnv := fVldMatriz(cFilEnv, Substr(cPer, 5, 2) + Substr(cPer, 1, 4))
											EndIf
										EndIf

										If (nVal1870 == (nVlrId1987 + nNew1870)) .Or. nVal1870 == nNew1870 
											
											//Chama a gravação da verba de Id 1987.
											fGravaSRR((cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, cVb1987, dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nVlrId1987)

											//Chama a gravação da verba de Id 1870.
											fGravaSRR((cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, cVb1870, dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nNew1870)

										Endif

										If !Empty(cVbDed91) .And. (nVal1891 == (nVlrDed91 + nNew1891) .Or. nVal1891 == nNew1891)
											
											//Chama a gravação da verba de cVbDed91
											fGravaSRR((cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, cVbDed91, dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nVlrDed91)

											//Chama a gravação da verba de Id 1891
											fGravaSRR((cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, cVb1891, dData, cPer, cSem, dDtPag, cSeq, SRA->RA_PROCES, dDtRef, cCenCus, nNew1891)
										Endif

										//Edita registro S-1200 no TAF para gerar uma retificação
										
										If !lMiddleware
											If !Empty(cVbDed91)
												fEditS1200(cFilEnv, cCPFFunc, AnoMes(dDtPag), {{cVb1870, nNew1870, .F.},{cVb1987, nVlrId1987, .F.},{cVb1891, nNew1891, .F.},{cVbDed91, nVlrDed91, .F.}}, Iif(nQdtFerRec > 0, cValToChar(nQdtFerRec), ""), cPrefixo, dtos(dDtPag), (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, nTotVinc)
											Else
												fEditS1200(cFilEnv, cCPFFunc, AnoMes(dDtPag), {{cVb1870, nNew1870, .F.},{cVb1987, nVlrId1987, .F.}}, Iif(nQdtFerRec > 0, cValToChar(nQdtFerRec), ""), cPrefixo, dtos(dDtPag), (cAliasSRH)->RH_FILIAL, (cAliasSRH)->RH_MAT, nTotVinc)
											Endif
										EndIf

                                    End Transaction
                                Else
                                     aAdd( aLog[1], OemToAnsi(STR0084 + (cAliasSRH)->RH_FILIAL + STR0085 + (cAliasSRH)->RH_MAT + STR0086 + cPer + STR0087)) 
                                     aAdd( aLog[1], OemToAnsi(STR0088 + cVb1870 + STR0089 )) //"O valor da verba " " difere da somatória da verba de Id 1987 e das verbas de natureza diferente de 1016."
                                EndIf
                                
                            EndIf

                            (cAliasSRH)->(dbSkip())
                        EndDo
                    EndIf

                    If Select(cAliasSRH) > 0
                        (cAliasSRH)->(dbCloseArea())
                    EndIf
                Next nVinc

                aAdd( aLog[1], "")
            EndIf
        Next nX

		lEnd := .T.


    EndIf

Return lRet


/*/{Protheus.doc} fSX3Load
Carrega cache SX3 utilizado no grid. Retorna um JsonObject com metadados
para campos SX3 utilizados nas estruturas, incluindo as chaves FIL, MAT,
CPF e NOM, cada uma contendo TIT, DES, TIP, LEN, DEC, PIC e
F3 conforme retornado por fX3Inf.
@author martins.marcio
@since 08/04/2026
@version 1.0
/*/
Static Function fSX3Load()
	oSX3 := IIf(ValType(oSX3) != "O", JsonObject():New(), oSX3)

	oSX3["FIL"] := fX3Inf("RA_FILIAL")
	oSX3["MAT"] := fX3Inf("RA_MAT")
	oSX3["CPF"] := fX3Inf("RA_CIC")
	oSX3["NOM"] := fX3Inf("RA_NOME")

Return oSX3

/*/{Protheus.doc} fX3Inf
Obtém metadados SX3 para uso nas estruturas MVC. Retorna um JsonObject
com as chaves: TIT (título), DES (descrição), TIP (tipo), LEN (tamanho),
DEC (decimais), PIC (picture) e F3 (f3/consulta rápida), além de valores
default quando o campo SX3 não estiver disponível.
@author martins.marcio
@since 08/04/2026
@version 1.0
/*/
Static Function fX3Inf(cCmp)
	Local oRet := JsonObject():New()
	Local aTam := {}

	Default cCmp := ""

	oRet["TIT"] := cCmp
	oRet["DES"] := cCmp
	oRet["TIP"] := "C"
	oRet["LEN"] := 10
	oRet["DEC"] := 0
	oRet["PIC"] := "@!"
	oRet["F3"]  := ""

	If FWSX3Util():SeekX3File(cCmp) .And. Select("SX3") > 0
		aTam := TamSX3(cCmp)
		oRet["TIT"] := AllTrim(SX3->X3_TITULO)
		oRet["DES"] := AllTrim(SX3->X3_DESCRIC)
		oRet["TIP"] := Upper(AllTrim(SX3->X3_TIPO))
		oRet["LEN"] := IIf(Len(aTam) >= 1, aTam[1], oRet["LEN"])
		oRet["DEC"] := IIf(Len(aTam) >= 2, aTam[2], oRet["DEC"])
		oRet["PIC"] := AllTrim(SX3->X3_PICTURE)
		oRet["F3"]  := AllTrim(SX3->X3_F3)
	EndIf

Return oRet

/*/{Protheus.doc} getFunApto
Busca funcionários elegíveis e consolida seus vínculos no período. A rotina
executa uma query em SRA (com join em SRH) para localizar CPFs com
registros de férias no ano informado, filtra pelas filiais informadas,
evita duplicidade por CPF (marca CPFs processados) e, para cada candidato,
invoca LoadVinc. Para candidatos que atendem aos critérios a
função chama fGetVlrTAF (quando aplicável) e fMesFerias e retorna um
array de entries no formato { filial, matricula, cpf, nome, oInfoPIS }.
@author martins.marcio
@since 09/04/2026
@version 1.0
/*/
Static Function getFunApto(cAnoRef, cFilialIn, oProcess, nTetPis)
	Local cQuery    := ""
	Local cAliasSRA := GetNextAlias()
	Local cIniAno   := cAnoRef + "0101"
	Local cFimAno   := cAnoRef + "1231"
	Local aRet      := {}
	Local aCPFProc  := {}
	Local oInfoPIS  := Nil
	Local lRequerAjs := .F.
	Local nTotCand  := 0
	Local nLidos    := 0
	Local nParamIdx := 0
	Local lTodos    := (AllTrim(cValToChar(MV_PAR10)) == "2")
	Local lFiltMat  := !(Empty(MV_PAR03) .And. (Empty(MV_PAR04) .Or. (EMPTY(STRTRAN(UPPER(MV_PAR04),"Z", "")))))
	Local lFiltCPF  := !(Empty(MV_PAR05) .And. (Empty(MV_PAR06) .Or. (EMPTY(STRTRAN(UPPER(MV_PAR06),"Z", "")))))
	Local lFiltCC   := !(Empty(MV_PAR07) .And. (Empty(MV_PAR08) .Or. (EMPTY(STRTRAN(UPPER(MV_PAR08),"Z", "")))))

	Default oProcess := Nil
	Default nTetPis := 0

	cQuery := "SELECT DISTINCT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_CIC, SRA.R_E_C_N_O_ "
	cQuery += "FROM " + RetSqlName("SRA") + " SRA "
	cQuery += "INNER JOIN " + RetSqlName("SRH") + " SRH ON SRH.RH_FILIAL = SRA.RA_FILIAL AND SRH.RH_MAT = SRA.RA_MAT "
	cQuery += "WHERE SRH.RH_DTRECIB BETWEEN ? AND ? "
	cQuery += "AND RA_ADMISSA <= ? "
	cQuery += "AND RA_CIC <> ? "
	cQuery += "AND (RA_DEMISSA = ? OR RA_DEMISSA >= ?) "
	cQuery += "AND SRA.D_E_L_E_T_ = ? "
	cQuery += "AND SRH.D_E_L_E_T_ = ? "
	
	If lFiltMat
		cQuery += "AND SRA.RA_MAT BETWEEN ? AND ? "
	EndIf
	
	If lFiltCPF
		cQuery += "AND SRA.RA_CIC BETWEEN ? AND ? "
	EndIf
	
	If lFiltCC
		cQuery += "AND SRA.RA_CC BETWEEN ? AND ? "
	EndIf
	
	cQuery += "ORDER BY RA_FILIAL, RA_MAT"

	cQuery := ChangeQuery(cQuery)
	oQrySRA := FwExecStatement():New(cQuery)
	
	nParamIdx := 0
	oQrySRA:SetString(++nParamIdx, cIniAno)   // RH_DTRECIB de (AAAAMMDD)
	oQrySRA:SetString(++nParamIdx, cFimAno)   // RH_DTRECIB ate (AAAAMMDD)
	oQrySRA:SetString(++nParamIdx, cFimAno)   // RA_ADMISSA <= cFimAno
	oQrySRA:SetString(++nParamIdx, "")        // RA_CIC <> ''
	oQrySRA:SetString(++nParamIdx, "")        // RA_DEMISSA = ''
	oQrySRA:SetString(++nParamIdx, cIniAno)   // RA_DEMISSA >= cIniAno
	oQrySRA:SetString(++nParamIdx, " ")       // SRA.D_E_L_E_T_
	oQrySRA:SetString(++nParamIdx, " ")       // SRH.D_E_L_E_T_
	
	If lFiltMat
		oQrySRA:SetString(++nParamIdx, MV_PAR03)  // RA_MAT - De
		oQrySRA:SetString(++nParamIdx, MV_PAR04)  // RA_MAT - Ate
	EndIf
	
	If lFiltCPF
		oQrySRA:SetString(++nParamIdx, MV_PAR05)  // RA_CIC - De
		oQrySRA:SetString(++nParamIdx, MV_PAR06)  // RA_CIC - Ate
	EndIf
	
	If lFiltCC
		oQrySRA:SetString(++nParamIdx, MV_PAR07)  // RA_CC - De
		oQrySRA:SetString(++nParamIdx, MV_PAR08)  // RA_CC - Ate
	EndIf
	cAliasSRA := oQrySRA:OpenAlias()

	DbSelectArea(cAliasSRA)
	(cAliasSRA)->(DbGoTop())
	Count To nTotCand
	(cAliasSRA)->(DbGoTop())

	If ValType(oProcess) == "O"
		oProcess:SetRegua1(Max(nTotCand, 1))
	EndIf

	While !(cAliasSRA)->(Eof())
		nLidos++
		If ValType(oProcess) == "O"
			oProcess:IncRegua1(OemToAnsi(STR0033) + AllTrim(Str(nLidos)) + "/" + AllTrim(Str(Max(nTotCand, 1)))) // "Avaliando funcionários elegíveis "
		EndIf

		lRequerAjs := .F.

		//Valida se a filial do registro está entre as filiais selecionadas
		If !Empty(cFilialIn) .And. !(AllTrim((cAliasSRA)->RA_FILIAL) $ cFilialIn)
			(cAliasSRA)->(DbSkip())
			LOOP
		EndIf

		DbSelectArea("SRA")
		SRA->(DbGoTo((cAliasSRA)->R_E_C_N_O_))

		// Se o CPF já foi processado, ignora este registro (evita duplicidade por vínculo)
		If AScan(aCPFProc, {|x| x == SRA->RA_CIC }) > 0
			(cAliasSRA)->(DbSkip())
			LOOP
		EndIf
				
		oInfoPIS := JsonObject():New()
		oInfoPIS["CPF"]         := SRA->RA_CIC
		oInfoPIS["NOME"]        := SRA->RA_NOME
		oInfoPIS["VINCULOS"]    := {}
		oInfoPIS["TRABALHOU30"] := .F.
		oInfoPIS["VLRTOT"]      := 0
		oInfoPIS["VLRTOTSRR"]   := 0
		oInfoPIS["VLRTOTGER"]   := 0
		oInfoPIS["REMMED"]      := 0
		oInfoPIS["REMMEDSRR"]   := 0
		oInfoPIS["REMMEDGER"]   := 0
		oInfoPIS["VLRMESSRD"]   := {}
		oInfoPIS["VLRMESSRR"]   := {}
		oInfoPIS["VLRMESGER"]   := {}
		oInfoPIS["MESESFERIAS"] := {}

		// Obtem remuneração, meses e total de dias trabalhados considerando outros vínculos
		LoadVinc(oInfoPIS, cIniAno, cFimAno)

		If oInfoPIS["REMMED"] > 0
			// Verifica se o funcionário é elegível
			lRequerAjs := oInfoPIS["VLRTOTSRR"] <> 0 .And. oInfoPIS["TRABALHOU30"] .And.;
				(oInfoPIS["REMMEDGER"] > nTetPis .And. oInfoPIS["REMMED"] <= nTetPis)

			If lRequerAjs .Or. lTodos 				
				
				oInfoPIS["MESESFERIAS"] := fMesFerias(SRA->RA_FILIAL, SRA->RA_MAT, cAnoRef)

				aAdd(aRet, { SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_CIC, SRA->RA_NOME, oInfoPIS })
				// marca CPF como processado para evitar carregamento em duplicidade quando passar pelo outro vinculo do mesmo CPF
				AAdd(aCPFProc, SRA->RA_CIC)
			EndIf
		EndIf

		(cAliasSRA)->(DbSkip())
	EndDo

	If SELECT(cAliasSRA) > 0
		(cAliasSRA)->(dbCloseArea())
	EndIf

Return aRet

/*/{Protheus.doc} LoadVinc
Carrega os vínculos do CPF e consolida valores no ano. Para cada vínculo
chama SumSRD para agregar remunerações e retorna o conjunto de vínculos em
oInfoPIS. 
@param oInfoPIS, JsonObject, Objeto com dados do funcionário/CPF
@param cIniAno, Character, Data inicial no formato AAAAMMDD
@param cFimAno, Character, Data final no formato AAAAMMDD
@return lRet, Logical, .T. quando processado
@author martins.marcio
@since 10/04/2026
@version 1.0
/*/
Static Function LoadVinc(oInfoPIS, cIniAno, cFimAno)
	Local lRet      := .T.
	Local aAreaSRA  := SRA->(GetArea())
	Local aVinculos := {}
	Local dDtInicial 
	Local dDtFinal 
	Local nVlrRec    := 0
	Local nVlrRecSRR := 0
	Local nDiasTrab  := 0
	Local nDiaTrTot  := 0
	Local nRemMed    := 0
	Local nRemMedSRR := 0
	Local aMesesTrab := {}
	Local aMesTSRR   := {}
	Local aVlrReceb  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local aVlrSRR    := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local aVlrGER    := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local aMemCalc   := {}
	Local aMemSRR    := {}
	Local nTok       := 0
	Local nVlrTot    := 0
	Local nVlrTotSRR := 0
	Local nVlrTotGER := 0
	Local nMes       := 0

	DEFAULT cIniAno := MV_PAR02 + "0101"
	DEFAULT cFimAno := MV_PAR02 + "1231"

	If !Empty(oInfoPIS["CPF"])	
		DbSelectArea("SRA")
		SRA->(DbSetOrder(20))

		If SRA->(DbSeek(oInfoPIS["CPF"]))
			While !SRA->(Eof()) .And. SRA->RA_CIC == oInfoPIS["CPF"]
				
				If SRA->RA_ADMISSA > STOD(cFimAno) .Or. (!Empty(SRA->RA_DEMISSA) .And. SRA->RA_DEMISSA < STOD(cIniAno))
					// Ignora o vinculo se a admissão for após o período ou a demissão for antes do período
					SRA->(DbSkip())
					Loop 
				EndIf
				
				dDtInicial := MAX(SRA->RA_ADMISSA, STOD(cIniAno))
				dDtFinal   := IIf(Empty(SRA->RA_DEMISSA), STOD(cFimAno), MIN(SRA->RA_DEMISSA, STOD(cFimAno)))
				nDiasTrab := (dDtFinal - dDtInicial) + 1
				nDiaTrTot += nDiasTrab
				
				nVlrRec	:= 0
				aMesesTrab := {}
				aVlrReceb  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
				aMemCalc   := {}
				SumSRD(cIniAno, cFimAno, @nVlrRec, @aMesesTrab, @aVlrReceb, @aMemCalc)

				nVlrRecSRR := 0
				aMesTSRR := {}
				aVlrSRR := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
				aMemSRR := {}
				SumSRR(cIniAno, cFimAno, @nVlrRecSRR, @aMesTSRR, @aVlrSRR, @aMemSRR)

				// Se não houver valor na SRD e SRR, ignora o vinculo
				If Empty(nVlrRec) .And. Empty(nVlrRecSRR)
					SRA->(DbSkip())
					Loop
				EndIf

				If ValType(aMemSRR) == "A" .And. ValType(aMemCalc) == "A"
					For nMes := 1 To 12
						If ValType(aMemSRR[nMes]) == "A" .And. ValType(aMemCalc[nMes]) == "A"
							For nTok := 1 To Len(aMemSRR[nMes])
								AAdd(aMemCalc[nMes], aMemSRR[nMes][nTok])
							Next nTok
						EndIf
					Next nMes
				EndIf
				nVlrTot += nVlrRec
				nVlrTotSRR += nVlrRecSRR
				// Acumula valores por mês de todos os vínculos
				For nMes := 1 To 12
					aVlrGER[nMes] += aVlrReceb[nMes]
					aVlrGER[nMes] += aVlrSRR[nMes]
				Next nMes
				AAdd(aVinculos, { SRA->RA_FILIAL, SRA->RA_MAT, dDtInicial, dDtFinal, nVlrRec, aMesesTrab, aVlrReceb, aVlrSRR, aMemCalc })
				SRA->(DbSkip())
			EndDo
		EndIf
		If Len(aVinculos) > 1
			aSort(aVinculos,,, {|a, b| a[3] < b[3]}) // Ordena por data de admissão (mais antiga primeiro)
		EndIf
		nRemMed := (nVlrTot / 12)
		nRemMedSRR := (nVlrTotSRR / 12)
		nVlrTotGER := nVlrTot + nVlrTotSRR

		oInfoPIS["VINCULOS"]    := aVinculos
		oInfoPIS["VLRTOT"]      := nVlrTot
		oInfoPIS["VLRTOTSRR"]   := nVlrTotSRR
		oInfoPIS["VLRTOTGER"]   := nVlrTotGER
		oInfoPIS["REMMED"]      := nRemMed
		oInfoPIS["REMMEDSRR"]   := nRemMedSRR
		oInfoPIS["REMMEDGER"]   := (nVlrTotGER / 12)
		oInfoPIS["VLRMESSRD"]   := aVlrReceb
		oInfoPIS["VLRMESSRR"]   := aVlrSRR
		oInfoPIS["VLRMESGER"]   := aVlrGER
		oInfoPIS["TRABALHOU30"] := (nDiaTrTot >= 30)
		SRA->(RestArea(aAreaSRA))
	EndIf

Return lRet

/*/{Protheus.doc} SumSRD
Consolida valores da SRD por natureza de rubrica e meses trabalhados. A
rotina utiliza uma lista fixa de naturezas (aNatRubr) definida localmente
para filtrar os registros considerados elegíveis. Preenche por referência o
nVlrRec (valor acumulado), aMesesTrab (meses distintos encontrados),
aVlrReceb (array com valores por mês) e popula a memória de cálculo
aMemCalc com o histórico por mês. Observação: `aVlrReceb` é retornado por
referência como um array de 12 posições.
@author martins.marcio
@since 10/04/2026
@version 1.1
@param cIniAno, Character, Data inicial no formato AAAAMMDD
@param cFimAno, Character, Data final no formato AAAAMMDD
@param nVlrRec, Numeric, Valor acumulado por referência
@param aMesesTrab, Array, Meses trabalhados acumulados
@param aVlrReceb, Array, Valores recebidos por mês (por referência)
@return lRet, Logical, Controle de execução da rotina
/*/
Static Function SumSRD(cIniAno, cFimAno, nVlrRec, aMesesTrab, aVlrReceb, aMemCalc)

	Local lRet      := .F.
	Local cQuery    := ""
	Local aVlrRecL := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} //Array com os valores recebidos por mês para o funcionário
	Local nI        := 0
	Local nVlrAnt   := 0
	Local cTipoCalc := ""
	Local nMesMem   := 0

	Local aNatRubr := { "1000", "1001", "1002", "1003", "1004", "1007", "1010", "1011", "1012", "1016", "1020", "1040", "1050", "1099",;
		"1201", "1202", "1203", "1204", "1205", "1206", "1207", "1208", "1209", "1210", "1211", "1212", "1213", "1214", "1215", "1216", "1217",;
		"1225", "1230", "1299", "1809", "3501", "3505", "3506", "3508", "3509", "3510", "3511", "3520", "4011", "4050", "6000", "6108",;
		"9207", "9208", "9209", "9210", "9211", "9212", "9290", "9291", "9906", "9930" ;
	}
	Local aIncIn := {"11", "91"}

	DEFAULT cIniAno := MV_PAR02 + "0101"
	DEFAULT cFimAno := MV_PAR02 + "1231"
	DEFAULT nVlrRec := 0

	If ValType(aMemCalc) == "A"
		aMemCalc := {}
		For nI := 1 To 12
			AAdd(aMemCalc, {})
		Next nI
	EndIf

	//Verifica remuneração elegível na SRD para o funcionário natureza de rubrica de acordo com a cartilha
	If oQrySRD == Nil
		cQuery := "SELECT SRD.RD_PD, SRD.RD_VALOR, SRD.RD_MES, SRD.RD_ROTEIR, SRV.RV_TIPOCOD, SRV.RV_DESC, SRV.RV_NATUREZ, SRV.RV_INCCP, SRD.R_E_C_N_O_ "
		cQuery += "FROM " + RetSqlName("SRD") + " SRD "
		cQuery += "LEFT OUTER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_FILIAL = ? AND SRV.RV_COD = SRD.RD_PD "
		cQuery += "LEFT OUTER JOIN " + RetSqlName("SRY") + " SRY ON SRY.RY_FILIAL = ? AND SRY.RY_CALCULO = SRD.RD_ROTEIR "
		cQuery += "WHERE SRD.RD_FILIAL = ? "
		cQuery += "AND SRD.RD_MAT = ? "
		cQuery += "AND SRD.RD_DTREF BETWEEN ? AND ? "
		cQuery += "AND SRV.RV_NATUREZ IN (?) "
		cQuery += "AND SRV.RV_INCCP IN (?) "
		cQuery += "AND SRY.RY_TIPO <> ? "
		cQuery += "AND SRD.D_E_L_E_T_ = ? "
		cQuery += "AND SRV.D_E_L_E_T_ = ? "
		cQuery += "AND SRY.D_E_L_E_T_ = ? "

		cQuery := ChangeQuery(cQuery)
		oQrySRD := FwExecStatement():New(cQuery)
	EndIf

	oQrySRD:SetString(1, xFilial("SRV", SRA->RA_FILIAL)) 
	oQrySRD:SetString(2, xFilial("SRY", SRA->RA_FILIAL))
	oQrySRD:SetString(3, SRA->RA_FILIAL)
	oQrySRD:SetString(4, SRA->RA_MAT)
	oQrySRD:SetString(5, cIniAno)
	oQrySRD:SetString(6, cFimAno)
	oQrySRD:setIn(7, aNatRubr)
	oQrySRD:setIn(8, aIncIn)
	oQrySRD:SetString(9, "K")
	oQrySRD:SetString(10, " ")
	oQrySRD:SetString(11, " ")
	oQrySRD:SetString(12, " ")

	cAliasSRD := oQrySRD:OpenAlias()

	DbSelectArea(cAliasSRD)
	(cAliasSRD)->(DbGoTop())
	
	If !(cAliasSRD)->(Eof())
		While !(cAliasSRD)->(Eof())
			nVlrAnt := nVlrRec
			If aScan(aMesesTrab, {|x| x == (cAliasSRD)->RD_MES }) == 0
				aAdd(aMesesTrab, (cAliasSRD)->RD_MES)
			EndIf
			
			If (cAliasSRD)->RV_TIPOCOD $ "2|4" // Desconto ou Base Desconto
				cTipoCalc := "-"
				nVlrRec -= (cAliasSRD)->RD_VALOR
				If Val((cAliasSRD)->RD_MES) >= 1 .And. Val((cAliasSRD)->RD_MES) <= 12
					aVlrRecL[Val((cAliasSRD)->RD_MES)] -= (cAliasSRD)->RD_VALOR
				EndIf
			Else
				cTipoCalc := "+"
				nVlrRec += (cAliasSRD)->RD_VALOR
				If Val((cAliasSRD)->RD_MES) >= 1 .And. Val((cAliasSRD)->RD_MES) <= 12
					aVlrRecL[Val((cAliasSRD)->RD_MES)] += (cAliasSRD)->RD_VALOR
				EndIf
			EndIf

			// Armazena memória do cálculo por mês: aMemCalc[mes] = { {tipo, operador, PD, natureza, valor, desc}, ... }
			nMesMem := Val((cAliasSRD)->RD_MES)
			If nMesMem >= 1 .And. nMesMem <= 12 .And. ValType(aMemCalc) == "A" .And. Len(aMemCalc) >= nMesMem .And. ValType(aMemCalc[nMesMem]) == "A"
				AAdd(aMemCalc[nMesMem], { "SRD", cTipoCalc, AllTrim((cAliasSRD)->RD_PD), AllTrim((cAliasSRD)->RV_NATUREZ), (cAliasSRD)->RD_VALOR, AllTrim((cAliasSRD)->RV_DESC) })
			EndIf

			(cAliasSRD)->(DbSkip())
		EndDo

	EndIf

	If SELECT(cAliasSRD) > 0
		(cAliasSRD)->(dbCloseArea())
	EndIf

	If ValType(aVlrReceb) == "A"
		For nI := 1 To 12
			aVlrReceb[nI] := aVlrRecL[nI]
		Next nI
	EndIf

Return lRet

/*/{Protheus.doc} SumSRR
Consolida valores da SRR por natureza de rubrica com base na data de
pagamento (RR_DATAPAG). A rotina soma os registros do período informado,
preenche o total acumulado, os valores por mês e a memória de cálculo,
seguindo o mesmo padrão da SumSRD.
@author martins.marcio
@since 25/05/2026
@version 1.0
@param cIniAno, Character, Data inicial no formato AAAAMMDD
@param cFimAno, Character, Data final no formato AAAAMMDD
@param nVlrRec, Numeric, Valor acumulado por referência
@param aMesesTrab, Array, Meses de pagamento acumulados
@param aVlrReceb, Array, Valores recebidos por mês (por referência)
@param aMemCalc, Array, Memória de cálculo por mês (por referência)
@return lRet, Logical, Controle de execução da rotina
/*/
Static Function SumSRR(cIniAno, cFimAno, nVlrRec, aMesesTrab, aVlrReceb, aMemCalc)
	Local lRet      := .F.
	Local cQuery    := ""
	Local cAliasSRR := ""
	Local aVlrRecL  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	Local nI        := 0
	Local nVlrAnt   := 0
	Local cTipoCalc := ""
	Local nMesMem   := 0
	Local cMesPag   := ""

	Local aNatRubr 	:= {"1016"}
	Local aIncIn 	:= {"11","91"}

	DEFAULT cIniAno := MV_PAR02 + "0101"
	DEFAULT cFimAno := MV_PAR02 + "1231"
	DEFAULT nVlrRec := 0

	If ValType(aMemCalc) == "A"
		aMemCalc := {}
		For nI := 1 To 12
			AAdd(aMemCalc, {})
		Next nI
	EndIf

	If oQrySRR == Nil
		cQuery := "SELECT SRR.RR_PD, SRR.RR_VALOR, SRR.RR_DATAPAG, SRV.RV_TIPOCOD, SRV.RV_DESC, SRV.RV_NATUREZ, SRV.RV_INCCP, SRR.R_E_C_N_O_ "
		cQuery += "FROM " + RetSqlName("SRR") + " SRR "
		cQuery += "LEFT OUTER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_FILIAL = ? AND SRV.RV_COD = SRR.RR_PD "
		cQuery += "WHERE SRR.RR_FILIAL = ? "
		cQuery += "AND SRR.RR_MAT = ? "
		cQuery += "AND SRR.RR_DATAPAG BETWEEN ? AND ? "
		cQuery += "AND SRV.RV_NATUREZ IN (?) "
		cQuery += "AND SRV.RV_INCCP IN (?) "
		cQuery += "AND SRR.RR_TIPO3 = ? "
		cQuery += "AND SRR.D_E_L_E_T_ = ? "
		cQuery += "AND SRV.D_E_L_E_T_ = ? "
		cQuery := ChangeQuery(cQuery)
		oQrySRR := FwExecStatement():New(cQuery)
	EndIf

	oQrySRR:SetString(1, xFilial("SRV", SRA->RA_FILIAL))
	oQrySRR:SetString(2, SRA->RA_FILIAL)
	oQrySRR:SetString(3, SRA->RA_MAT)
	oQrySRR:SetString(4, cIniAno)
	oQrySRR:SetString(5, cFimAno)
	oQrySRR:setIn(6, aNatRubr)
	oQrySRR:setIn(7, aIncIn)
	oQrySRR:SetString(8, "F")
	oQrySRR:SetString(9, " ")
	oQrySRR:SetString(10, " ")
	cAliasSRR := oQrySRR:OpenAlias()

	DbSelectArea(cAliasSRR)
	(cAliasSRR)->(DbGoTop())

	If !(cAliasSRR)->(Eof())
		While !(cAliasSRR)->(Eof())
			nVlrAnt := nVlrRec
			cMesPag := SubStr((cAliasSRR)->RR_DATAPAG, 5, 2)
			If aScan(aMesesTrab, {|x| x == cMesPag }) == 0
				aAdd(aMesesTrab, cMesPag)
			EndIf

			If (cAliasSRR)->RV_TIPOCOD $ "2|4"
				cTipoCalc := "-"
				nVlrRec -= (cAliasSRR)->RR_VALOR
				If Val(cMesPag) >= 1 .And. Val(cMesPag) <= 12
					aVlrRecL[Val(cMesPag)] -= (cAliasSRR)->RR_VALOR
				EndIf
			Else
				cTipoCalc := "+"
				nVlrRec += (cAliasSRR)->RR_VALOR
				If Val(cMesPag) >= 1 .And. Val(cMesPag) <= 12
					aVlrRecL[Val(cMesPag)] += (cAliasSRR)->RR_VALOR
				EndIf
			EndIf

			nMesMem := Val(cMesPag)
			If nMesMem >= 1 .And. nMesMem <= 12 .And. ValType(aMemCalc) == "A" .And. Len(aMemCalc) >= nMesMem .And. ValType(aMemCalc[nMesMem]) == "A"
				AAdd(aMemCalc[nMesMem], { "SRR", cTipoCalc, AllTrim((cAliasSRR)->RR_PD), AllTrim((cAliasSRR)->RV_NATUREZ), (cAliasSRR)->RR_VALOR, AllTrim((cAliasSRR)->RV_DESC) })
			EndIf

			(cAliasSRR)->(DbSkip())
		EndDo
	EndIf

	If SELECT(cAliasSRR) > 0
		(cAliasSRR)->(dbCloseArea())
	EndIf

	If ValType(aVlrReceb) == "A"
		For nI := 1 To 12
			aVlrReceb[nI] := aVlrRecL[nI]
		Next nI
	EndIf

Return lRet

/*/{Protheus.doc} GetSalMin
Obtém o salário mínimo parametrizado para validações da rotina.
Carrega o valor da tabela S004 (Tabela de Salário Mínimo), (VLSALMIN).
Busca o registro válido para o período informado (Ano).
@author martins.marcio
@since 10/04/2026
@version 1.2
@param cAno, Character, Ano de referência (formato AAAA ex: 2026)
@return nRet, Numeric, Valor do salário mínimo considerado
/*/
Static Function GetSalMin(cAno)
	Local nRet     := 0
	Local aTabS004 := {}
	Local nLinha   := 0

	Default cAno := Year(Date()-2)

	// Carrega a tabela S004 (Tabela de Salário Mínimo)
	fCarrTab(@aTabS004, "S004", Nil)

	If Len(aTabS004) > 0
		//Ordena o array da tabela S004 pelo campo de início de vigência (índice 5)
		aSort(aTabS004,,, {|a, b| a[5] < b[5]}) 
		
		For nLinha := 1 To Len(aTabS004)
			If LEFT(aTabS004[nLinha][5],4) <= cAno .And. cAno <= LEFT(aTabS004[nLinha][6],4)
				nRet := aTabS004[nLinha][7]
				Exit
			EndIf
		Next nLinha
	EndIf

Return nRet

/*/{Protheus.doc} FmtMesFer
Formata lista de meses para apresentação textual abreviada.
@author martins.marcio
@since 10/04/2026
@version 1.0
@param aMeses, Array, Lista de meses
@return cRet, Character, Texto formatado dos meses
/*/
Static Function FmtMesFer(aMeses)
	Local cRet := ""
	Local nI   := 0

	Default aMeses := {}

	If Len(aMeses) > 0

		cRet := MesNom(aMeses[1])
		
		For nI := 2 To Len(aMeses)
			If nI == Len(aMeses)
				cRet += OemToAnsi(STR0054) + MesNom(aMeses[nI]) //" e "
			Else
				cRet += ", " + MesNom(aMeses[nI])
			EndIf
		Next nI
	EndIf

Return cRet

/*/{Protheus.doc} FmtDetPi
Monta o texto de detalhamento de vínculos do funcionário com recebimento mês a mês.
@author martins.marcio
@since 10/04/2026
@version 1.2
@param oInfo, JsonObject, Informações consolidadas do funcionário
@return cRet, Character, Texto formatado para exibição
/*/
Static Function FmtDetPi(oInfo)
	Local cRet   := ""
	Local aVinc  := {}
	Local nVinc  := 0
	Local nMes   := 0
	Local cLinha := ""
	Local nMedSal := 0
	Local nMedSalSRR := 0
	Local nMedSalGER := 0
	Local cCPF := ""
	Local aVlrReceb := {}
	Local aVlrSrr := {}
	Local aMemMesTxt := {}
	Local aMemSrd := {}
	Local aMemSrr := {}
	Local aMesNom := {OemToAnsi(STR0055), OemToAnsi(STR0056), OemToAnsi(STR0057), OemToAnsi(STR0058), OemToAnsi(STR0059), OemToAnsi(STR0060), OemToAnsi(STR0061), OemToAnsi(STR0062), OemToAnsi(STR0063), OemToAnsi(STR0064), OemToAnsi(STR0065), OemToAnsi(STR0066)}
	Local nTok := 0
	Local aTok := {}
	Local cTipo := ""
	Local cOperador := ""
	Local cCodigo := ""
	Local cNatureza := ""
	Local nValor := 0
	Local cValor := ""
	Local cDesc := ""
	Local cLinha2 := ""

	Default oInfo := JsonObject():New()

	cCPF := IIf(ValType(oInfo["CPF"]) == "C", AllTrim(oInfo["CPF"]), "")

	nMedSal := IIf(ValType(oInfo["REMMED"]) == "N", oInfo["REMMED"], 0)
	nMedSalSRR := IIf(ValType(oInfo["REMMEDSRR"]) == "N", oInfo["REMMEDSRR"], 0)
	nMedSalGER := IIf(ValType(oInfo["REMMEDGER"]) == "N", oInfo["REMMEDGER"], 0)

	cRet += OemToAnsi(STR0042) + IIf(oInfo["TRABALHOU30"], OemToAnsi(STR0043), OemToAnsi(STR0044)) + CRLF + CRLF //"Trabalhou 30 dias: " //"SIM" //"NÃO"

	cRet += OemToAnsi(STR0045) + AllTrim(Transform(oInfo["VLRTOT"], "@E 999,999,999,999.99")) + CRLF //"Total Folha (SRD): "
	cRet += OemToAnsi(STR0046) + AllTrim(Transform(IIf(ValType(oInfo["VLRTOTSRR"]) == "N", oInfo["VLRTOTSRR"], 0), "@E 999,999,999,999.99")) + CRLF //"Total Férias (SRR): "
	cRet += OemToAnsi(STR0047) + AllTrim(Transform(IIf(ValType(oInfo["VLRTOTGER"]) == "N", oInfo["VLRTOTGER"], oInfo["VLRTOT"] + IIf(ValType(oInfo["VLRTOTSRR"]) == "N", oInfo["VLRTOTSRR"], 0)), "@E 999,999,999,999.99")) + CRLF + CRLF //"Total SRD+SRR: "
	cRet += OemToAnsi(STR0048) + AllTrim(Transform(nMedSal, "@E 999,999,999,999.99")) + CRLF //"Média 12m SRD: "
	cRet += OemToAnsi(STR0049) + AllTrim(Transform(nMedSalGER, "@E 999,999,999,999.99")) + CRLF + CRLF //"Média 12m SRD+SRR: "

	aVinc := IIf(ValType(oInfo["VINCULOS"]) == "A", oInfo["VINCULOS"], {})
	aVlrSrr := IIf(ValType(oInfo["VLRMESSRR"]) == "A", oInfo["VLRMESSRR"], {})

	For nVinc := 1 To Len(aVinc)
		cRet += "Vínculo " + StrZero(nVinc, 2) + ":" + CRLF
		cLinha := "- " + AllTrim(aVinc[nVinc][1]) + "/" + AllTrim(aVinc[nVinc][2])
		cLinha += OemToAnsi(STR0051) + DtoC(aVinc[nVinc][3]) //" | Início: "
		cLinha += OemToAnsi(STR0052) + DtoC(aVinc[nVinc][4]) + CRLF //" | Fim: "
		cLinha += OemToAnsi(STR0053) + AllTrim(Transform(aVinc[nVinc][5], "@E 999,999,999,999.99")) //" | Rend.: "
		cRet += cLinha + CRLF

		aVlrReceb := IIf(ValType(aVinc[nVinc][7]) == "A", aVinc[nVinc][7], {})
		aVlrSrr := IIf(ValType(aVinc[nVinc][8]) == "A", aVinc[nVinc][8], {})
		aMemMesTxt := IIf(ValType(aVinc[nVinc][9]) == "A", aVinc[nVinc][9], {})
		If Len(aVlrReceb) == 12 .Or. Len(aVlrSrr) == 12
			cRet += CRLF
			For nMes := 1 To 12
				aMemSrd := {}
				aMemSrr := {}
				If (Len(aVlrReceb) >= nMes .And. aVlrReceb[nMes] > 0) .Or. (Len(aVlrSrr) >= nMes .And. aVlrSrr[nMes] > 0) .Or. (Len(aMemMesTxt) >= nMes .And. ValType(aMemMesTxt[nMes]) == "C" .And. !Empty(AllTrim(aMemMesTxt[nMes])))
					cRet += aMesNom[nMes] + ":" + CRLF
					// Constrói as memórias SRD / SRR (já existente)
					If Len(aMemMesTxt) >= nMes .And. ValType(aMemMesTxt[nMes]) == "A"
						For nTok := 1 To Len(aMemMesTxt[nMes])
							aTok := aMemMesTxt[nMes][nTok]
							If ValType(aTok) == "A" .And. Len(aTok) >= 6
								cTipo := Upper(AllTrim(aTok[1]))
								cOperador := AllTrim(aTok[2])
								cCodigo := AllTrim(aTok[3])
								cNatureza := AllTrim(aTok[4])
								nValor := IIf(ValType(aTok[5]) == "N", aTok[5], 0)
								cValor := AllTrim(Transform(Abs(nValor), "@E 999,999,999,999.99"))
								cDesc := AllTrim(IIf(ValType(aTok[6]) == "C", aTok[6], ""))
								cLinha2 := cOperador + " " + cValor + " => " + cCodigo
								If !Empty(cDesc)
									cLinha2 += "-" + cDesc
								EndIf
								If !Empty(cNatureza)
									cLinha2 += " | Natureza " + cNatureza
								EndIf
								If cTipo == "SRD"
									AAdd(aMemSrd, cLinha2)
								ElseIf cTipo == "SRR"
									AAdd(aMemSrr, cLinha2)
								EndIf
							EndIf
						Next nTok
					EndIf

					// Impressão formatada: valor e, em linha seguinte, tokens indentados
					// SRD
					If (Len(aVlrReceb) >= nMes .And. aVlrReceb[nMes] > 0) .Or. Len(aMemSrd) > 0
						cRet += "  " + OemToAnsi(STR0045) //"Total Folha (SRD): "
						If Len(aVlrReceb) >= nMes .And. aVlrReceb[nMes] > 0
							cRet += AllTrim(Transform(aVlrReceb[nMes], "@E 999,999,999,999.99"))
						EndIf
						If Len(aMemSrd) > 0
							For nTok := 1 To Len(aMemSrd)
								cRet += CRLF + Chr(9) + aMemSrd[nTok]
							Next nTok
						EndIf
						cRet += CRLF
					EndIf

					// SRR
					If (Len(aVlrSrr) >= nMes .And. aVlrSrr[nMes] > 0) .Or. Len(aMemSrr) > 0
						cRet += "  " + OemToAnsi(STR0046) //"Total Férias (SRR): "
						If Len(aVlrSrr) >= nMes .And. aVlrSrr[nMes] > 0
							cRet += AllTrim(Transform(aVlrSrr[nMes], "@E 999,999,999,999.99"))
						EndIf
						If Len(aMemSrr) > 0
							For nTok := 1 To Len(aMemSrr)
								cRet += CRLF + Chr(9) + aMemSrr[nTok]
							Next nTok
						EndIf
						cRet += CRLF
					EndIf
				EndIf
			Next nMes
			EndIf

		cRet += CRLF
	Next nVinc
	cRet += CRLF + CRLF + CRLF + CRLF + CRLF + CRLF

Return cRet

/*/{Protheus.doc} fMesFerias
Obtém os meses que houve pagamento de férias, extraindo o mês do campo RH_DTRECIB.
Um mês por registro SRH, evitando duplicatas quando férias atravessam meses.
@author martins.marcio
@since 24/04/2026
@version 2.2
@param cFilSRA, Character, Filial do funcionário
@param cMatSRA, Character, Matrícula do funcionário
@param cAnoRef, Character, Ano de referência no formato AAAA
@return aRet, Array, Lista única dos meses (MM) com férias calculadas
/*/
Static Function fMesFerias(cFilSRA, cMatSRA, cAnoRef)
	Local aRet      := {}
	Local aArea     := GetArea()
	Local cSeekSRH  := ""
	Local cMesFer   := ""
	Local cDtRecib  := ""

	Default cFilSRA := ""
	Default cMatSRA := ""
	Default cAnoRef := ""

	If !Empty(cFilSRA) .And. !Empty(cMatSRA) .And. !Empty(cAnoRef)
		DbSelectArea("SRH")
		SRH->(DbSetOrder(1)) //RH_FILIAL+RH_MAT+DTOS(RH_DATABAS)+DTOS(RH_DATAINI) 
		cSeekSRH := cFilSRA + cMatSRA

		If SRH->(DbSeek(cSeekSRH))
			While !SRH->(Eof()) .And. SRH->RH_FILIAL = cFilSRA .And. SRH->RH_MAT == cMatSRA
				cDtRecib := DtoS(SRH->RH_DTRECIB)

				If SubStr(cDtRecib, 1, 4) == cAnoRef
					cMesFer := SubStr(cDtRecib, 5, 2)
					If AScan(aRet, {|x| x == cMesFer}) == 0
						AAdd(aRet, cMesFer)
					EndIf
				EndIf
				SRH->(DbSkip())
			EndDo
		EndIf

		If Len(aRet) > 1
			aSort(aRet)
		EndIf
	EndIf

	RestArea(aArea)

Return aRet


/*/{Protheus.doc} MesNom
Converte número do mês para sigla.
@author martins.marcio
@since 10/04/2026
@version 1.0
@param cMesFer, Character, Mês numérico (01..12)
@return cRet, Character, Sigla do mês
/*/
Static Function MesNom(cMesFer)
	Local cRet  := ""
	Local cMes2 := ""

	Default cMesFer := ""

	cMes2 := PadL(AllTrim(cValToChar(cMesFer)), 2, "0")
	Do Case
		Case cMes2 == "01"
			cRet := OemToAnsi(STR0055) //"JAN"
		Case cMes2 == "02"
			cRet := OemToAnsi(STR0056) //"FEV"
		Case cMes2 == "03"
			cRet := OemToAnsi(STR0057) //"MAR"
		Case cMes2 == "04"
			cRet := OemToAnsi(STR0058) //"ABR"
		Case cMes2 == "05"
			cRet := OemToAnsi(STR0059) //"MAI"
		Case cMes2 == "06"
			cRet := OemToAnsi(STR0060) //"JUN"
		Case cMes2 == "07"
			cRet := OemToAnsi(STR0061) //"JUL"
		Case cMes2 == "08"
			cRet := OemToAnsi(STR0062) //"AGO"
		Case cMes2 == "09"
			cRet := OemToAnsi(STR0063) //"SET"
		Case cMes2 == "10"
			cRet := OemToAnsi(STR0064) //"OUT"
		Case cMes2 == "11"
			cRet := OemToAnsi(STR0065) //"NOV"
		Case cMes2 == "12"
			cRet := OemToAnsi(STR0066) //"DEZ"
	EndCase

Return cRet


/*/{Protheus.doc} fListNomMes
Converte número do mês para sigla.
@author lidio.oliveira
@since 29/05/2026
@version 1.0
@return jRet, Objeto json com a lista com mes abreviado e númerico
/*/
Static Function fListNomMes()

    Local jRet As Json

    jRet := JsonObject():New()

    jRet["JAN"] := "01"
    jRet["FEV"] := "02"
    jRet["MAR"] := "03"
    jRet["ABR"] := "04"
    jRet["MAI"] := "05"  
    jRet["JUN"] := "06"
    jRet["JUL"] := "07"
    jRet["AGO"] := "08"
    jRet["SET"] := "09"
    jRet["OUT"] := "10"
    jRet["NOV"] := "11"
    jRet["DEZ"] := "12"

Return jRet


/*/{Protheus.doc} fGravaSRR
Função responsável pela gravação das verbas na SRR
@author lidio.oliveira
@since 29/05/2026
@version 1.0
@return jRet, Objeto json com a lista com mes abreviado e númerico
/*/
Static Function fGravaSRR(cCodFil, cCodMat, cPD, dData, cPer, cSem, dDtPag, cSeq, cProc, dDtRef, cCenCus, nValor)

    Local aArea     := GetArea()
    //Local aAreaSRR  := SRR->(GetArea())
    Local lNovo     := .T.

    Default cCodFil := ""
    Default cCodMat := ""
    Default cPD     := ""
    Default dData   := CTOD("//")
    Default cPer    := ""
    Default cSem    := ""
    Default dDtPag  := CTOD("//")
    Default cSeq    := ""
    Default cProc   := "" 
    Default dDtRef  := CTOD("//")
    Default cCenCus := ""
    Default nValor  := 0

    SRR->( dbSetOrder(1) )
    lNovo := SRR->( !dbSeek( cCodFil + cCodMat + "F" + DTOS(dData) + cPD + cCenCus ))

    //Grava a verba de Id 1871
    If nValor > 0
        //Trava o registro na SRR para edição
        If SRR->( RecLock("SRR", lNovo) )
            //Se for inclusão, grava todos campos da SRR
            //Se for alteração, apenas altera o valor do registro
            If lNovo
                SRR->RR_FILIAL  := cCodFil
                SRR->RR_MAT     := cCodMat
                SRR->RR_PD      := cPD
                SRR->RR_TIPO1   := "V"
                SRR->RR_TIPO2   := "C"
                SRR->RR_DATA    := dData
                SRR->RR_TIPO3   := "F"
                SRR->RR_PERIODO := cPer
                SRR->RR_ROTEIR  := "FER"
                SRR->RR_SEMANA  := cSem
                SRR->RR_DATAPAG := dDtPag
                SRR->RR_SEQ     := cSeq
                SRR->RR_PROCES  := cProc
                SRR->RR_DTREF   := dDtRef
                SRR->RR_CC      := cCenCus
            EndIf

            SRR->RR_VALOR   := nValor

            //Adiciona no log de ocorrências
            //              Filial                         "  -  Matrícula: "                    "  -  Período: "                  "  -  Verba: "              "  -  Valor: R$ "
            aAdd( aLog[1], OemToAnsi(STR0084) + cCodFil + OemToAnsi(STR0085) + cCodMat + OemToAnsi(STR0086) + cPer + OemToAnsi(STR0094) + cPD + OemToAnsi(STR0095) + Transform( nValor, "@E 999,999.99" ) + Iif(lNovo, OemToAnsi(STR0096), OemToAnsi(STR0097)) )

            //Libera o registro da SRR
            SRR->( MsUnlock() )
        EndIf
	Else
		If SRR->( dbSeek( cCodFil + cCodMat + "F" + DTOS(dData) + cPD + cCenCus ))
			SRR->( RecLock("SRR",.F.,.T.) )
			SRR->( dbDelete() )
			SRR->( MsUnLock() )

			aAdd( aLog[1], OemToAnsi(STR0084) + cCodFil + OemToAnsi(STR0085) + cCodMat + OemToAnsi(STR0086) + cPer + OemToAnsi(STR0094) + cPD + OemToAnsi(STR0095) + Transform( nValor, "@E 999,999.99" ) + OemToAnsi(STR0104) )
		Endif	
	EndIf

    //RestArea(aAreaSRR)
    RestArea(aArea)

Return

/*/{Protheus.doc} fEditS1200
Função responsável pela gravação do S-1200 no TAF
@author lidio.oliveira
@since 29/05/2026
@version 1.0
@return lRet
/*/
Static Function fEditS1200(cFilEnv, cCPFFunc, cPeriodo, aItens, cQdtFerRec, cPrefixo, cDtPgto, cFilFunc, cMatFunc, nTotVinc)

    Local lRet          := .T.
    Local oModel        := Nil
    Local cBkpFil       := cFilAnt
    Local nT14          := 0
    Local nC9K          := 0
    Local nC9L          := 0
    Local nC9M          := 0
	Local nX			:= 0
	Local lGrava		:= .F.
	Local cIdeDmd		:= ""
	Local cIdCodRub		:= ""
	Local cCodRub		:= ""
	Local cIdTabRub		:= ""
	Local aErro			:= {}

    Default cFilEnv     := ""
    Default cCPFFunc    := ""
    Default cPeriodo    := ""
	Default aItens		:= {}
	Default cQdtFerRec	:= ""
	Default cPrefixo	:= ""
	Default cDtPgto		:= ""
	Default cFilFunc	:= ""
	Default cMatFunc	:= ""
	Default nTotVinc	:= 1

    cFilAnt := cFilEnv
	
	C91->(DbSetOrder(7)) //C91_FILIAL+C91_INDAPU+C91_PERAPU+C91_CPF+C91_NOMEVE+C91_ATIVO
	If C91->(DbSeek(cFilEnv + "1" + cPeriodo + cCPFFunc + "S1200" + "1"))
		oModel  := FWLoadModel('TAFA250')        
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()

		For nT14 := 1 to oModel:GetModel("MODEL_T14"):Length()
			
			oModel:GetModel("MODEL_T14"):GoLine(nT14)
			cIdeDmd := AllTrim(oModel:GetModel("MODEL_T14"):GetValue("T14_IDEDMD"))

			If ("FER" + cQdtFerRec) $ Substr(cIdeDmd, Len(cIdeDmd) - 3, 4) .And. ;
			(nTotVinc == 1 .Or. ((!Empty(cPrefixo) .And. cPrefixo + cDtPgto $ cIdeDmd) .Or. (cFilFunc + cMatFunc $ cIdeDmd)))

				For nC9K := 1 to oModel:GetModel("MODEL_C9K"):Length()

					oModel:GetModel("MODEL_C9K"):GoLine(nC9K)

					For nC9L := 1 to oModel:GetModel("MODEL_C9L"):Length()

						oModel:GetModel("MODEL_C9L"):GoLine(nC9L)

						For nC9M := 1 To oModel:GetModel("MODEL_C9M"):Length()
							oModel:GetModel("MODEL_C9M"):GoLine(nC9M)
							
							cIdTabRub	:= AllTrim(oModel:GetValue("MODEL_C9M","C9M_IDTABR"," "))
							cIdCodRub	:= AllTrim(oModel:GetValue("MODEL_C9M","C9M_CODRUB"," "))
							cCodRub		:= AllTrim(RetValC8R(cIdCodRub, oModel:GetValue("MODEL_C9M","C9M_FILIAL"," "), "C8R_CODRUB"))
							nPosCodRub	:= aScan(aItens, { |x| x[1] == cCodRub})

							If nPosCodRub > 0
								If aItens[nPosCodRub][2] > 0
									oModel:SetValue("MODEL_C9M","C9M_VLRRUB", aItens[nPosCodRub][2])
								Else
									oModel:GetModel("MODEL_C9M"):DeleteLine()
								EndIf
								aItens[nPosCodRub][3]	:= .T.
								lGrava := .T.	
							EndIf
						Next nC9M

						For nX := 1 To Len(aItens)
							If !aItens[nX][3] .And. aItens[nX][2] > 0
								oModel:GetModel("MODEL_C9M"):lValid := .T.
								oModel:GetModel("MODEL_C9M"):AddLine()

								oModel:LoadValue( "MODEL_C9M", "C9M_CODRUB", FGetIdInt( "codRubr", "ideTabRubr", aItens[nX][1], cIdTabRub, .F., , , , , , , , , cPeriodo))
								oModel:LoadValue( "MODEL_C9M", "C9M_QTDRUB", 0 )
								oModel:LoadValue( "MODEL_C9M", "C9M_VLRUNT", 0 )
								oModel:LoadValue( "MODEL_C9M", "C9M_FATORR", 0 )
								oModel:LoadValue( "MODEL_C9M", "C9M_VLRRUB", aItens[nX][2] )
								oModel:LoadValue( "MODEL_C9M", "C9M_IDTABR", cIdTabRub )
								oModel:LoadValue( "MODEL_C9M", "C9M_APURIR", "0" )
								
								lGrava := .T.
							EndIf
						Next nX

					Next nC9L

				Next nC9K

			EndIf

		Next nT14

		If lGrava			
			If oModel:VldData()
				lRet := oModel:CommitData()
				//"Retificação do evento S-1200 do período " " gerado, realize a transmissão!"
				Iif(lRet, aAdd( aLog[1], OemToAnsi(STR0098) + cPeriodo + OemToAnsi(STR0099)), aErro := oModel:GetErrorMessage())
			//Else
				//aErro := oModel:GetErrorMessage()
			EndIf 
		EndIf

		//If Len(aErro) > 0
		//	aAdd(aLog[1], "Houve um erro ao editar o evento S-1200 no período " + cPeriodo + ". Detalhes abaixo: ")
		//	aEval(aErro, {|x| aAdd(aLog[1], x)})
		//EndIf

		oModel:DeActivate()
		oModel:Destroy()
		oModel := NIL
	EndIf

	cFilAnt := cBkpFil

Return lRet
