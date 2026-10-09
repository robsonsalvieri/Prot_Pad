#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM949.CH"

#DEFINE CRLF	CHR(13) + CHR(10)

Static oSX3
Static lCargSQ3

/*/{Protheus.doc} GPEM949
Programa MVC para geração de arquivo TXT de afastamentos - Bolsa Qualificação Profissional.

Estrutura da tela:
1) Filtro: filial/cc/data inicial/final.
2) Aplicação em massa: processo, carga horária e percentual.
3) Grid editável: seleção por linha + manutenção antes da geração.

@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Function GPEM949()
	Local   lTemRVQ   := ChkFile("RVQ")
	Local   cMsgNoYes := ""
	
	DEFAULT lCargSQ3  := SuperGetMv("MV_CARGSQ3",,.F.)
	
	Private aEstabele := {}
	Private oQryFilt  := Nil

	If !lTemRVQ
		If !IsBlind()
			cMsgNoYes := OemToAnsi(STR0001) + CRLF + CRLF //"A tabela RVQ não foi encontrada no dicionário."
			cMsgNoYes += OemToAnsi(STR0002) //"Aplique o dicionário da expedição contínua do RH antes de utilizar esse programa."
			FWAlertWarning(cMsgNoYes, OemToAnsi(STR0003)) //"Bolsa Qualificação Profissional"
		EndIf
		Return
	EndIf

	FWExecView(OemToAnsi(STR0004), "GPEM949", MODEL_OPERATION_UPDATE, , {|| .T. }) //"Geração do arquivo"

Return

/*/{Protheus.doc} ModelDef
Definição do modelo MVC (cabeçalho e grid).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function ModelDef()
	Local oModel		:= MPFormModel():New("GPEM949", NIL, NIL, {|oMdl| CommitMdl(oMdl) })
	Local oStructCab	:= StruCab()
	Local oStructDet	:= StruDet()

	oModel:SetDescription(OemToAnsi(STR0003)) //"Bolsa Qualificação Profissional"

	oModel:AddFields("GP949_MCAB", NIL, oStructCab, NIL, NIL, {|oMdl| CargaCab(oMdl) })
	oModel:GetModel("GP949_MCAB"):SetDescription(OemToAnsi(STR0005)) //"Filtros e Aplicação"

	oModel:AddGrid("GP949_MDET", "GP949_MCAB", oStructDet, NIL, {|oGrid|fVlGP949Ln(oGrid)}, NIL, NIL, {|oMdl| CargaDet(oMdl) })
	oModel:GetModel("GP949_MDET"):SetDescription(OemToAnsi(STR0006)) //"Registros para geração"
	oModel:GetModel("GP949_MDET"):SetOptional(.T.)
	oModel:GetModel("GP949_MDET"):SetNoInsertLine(.F.)
	oModel:GetModel("GP949_MDET"):SetNoDeleteLine(.F.)
	oModel:GetModel("GP949_MDET"):SetNoUpdateLine(.F.)

	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição da view MVC (interface visual com folder, grid e botões).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function ViewDef()
	Local oView		:= FWFormView():New()
	Local oModel	:= FWLoadModel("GPEM949")
	Local oFilView	:= ViewFilt()
	Local oAplView	:= ViewAplic()
	Local oDetView	:= ViewDet()

	oView:SetModel(oModel)
	oView:AddField("GP949_VFIL", oFilView, "GP949_MCAB")
	oView:AddField("GP949_VAPL", oAplView, "GP949_MCAB")
	oView:AddGrid("GP949_VDET", oDetView, "GP949_MDET")
	oView:AddOtherObject("GP949_BF", {|oPanel| BtnFiltr(oPanel, oView) })
	oView:AddOtherObject("GP949_BA", {|oPanel| BtnAplic(oPanel, oView) })

	oView:CreateHorizontalBox("BOX_TOP", 40)
	oView:CreateHorizontalBox("BOX_GRID", 60)

	oView:CreateFolder("FOLDER_GP9", "BOX_TOP")
	oView:AddSheet("FOLDER_GP9", "ABA_FIL", OemToAnsi(STR0018)) //"Filtros"
	oView:AddSheet("FOLDER_GP9", "ABA_APL", OemToAnsi(STR0019)) //"Preenchimento em lote"

	oView:CreateHorizontalBox("FIL_CAMP", 72,,, "FOLDER_GP9", "ABA_FIL")
	oView:CreateHorizontalBox("FIL_BUTN", 28,,, "FOLDER_GP9", "ABA_FIL")

	oView:CreateHorizontalBox("APL_CAMP", 60,,, "FOLDER_GP9", "ABA_APL")
	oView:CreateHorizontalBox("APL_BUTN", 40,,, "FOLDER_GP9", "ABA_APL")

	oView:SetOwnerView("GP949_VFIL", "FIL_CAMP")
	oView:SetOwnerView("GP949_BF", "FIL_BUTN")
	oView:SetOwnerView("GP949_VAPL", "APL_CAMP")
	oView:SetOwnerView("GP949_BA", "APL_BUTN")
	oView:SetOwnerView("GP949_VDET", "BOX_GRID")

	oView:EnableTitleView("GP949_VDET", OemToAnsi(STR0021)) //"Funcionários"

	oView:AddUserButton(OemToAnsi(STR0022), "INVSEL", {|oMdl| InvSel(oMdl) }, OemToAnsi(STR0023), NIL, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW }) //"Inverter Seleção" //"Inverte marcação da coluna Sel no grid"
	oView:AddUserButton(OemToAnsi(STR0024), "GERAARQ", {|oMdl| GerarArq(oMdl) }, OemToAnsi(STR0025), NIL, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE, MODEL_OPERATION_VIEW }) //"Gerar arquivo" //"Gera TXT com linhas selecionadas"

	oView:SetCloseOnOk({ || .T. })

Return oView

/*/{Protheus.doc} BtnFiltr
Cria botão Filtrar no box de filtros.
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function BtnFiltr(oPanel, oView)
	@ 03, 05 BUTTON OemToAnsi(STR0046) SIZE 120, 16 PIXEL OF oPanel ACTION Filtrar(oView:GetModel()) //" >> FILTRAR AGORA << "
Return

/*/{Protheus.doc} BtnAplic
Cria botão Aplicar a todos no box de aplicação em massa.
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function BtnAplic(oPanel, oView)
	@ 03, 05 BUTTON OemToAnsi(STR0047) SIZE 140, 16 PIXEL OF oPanel ACTION AplTodos(oView:GetModel()) //" >> APLICAR AOS SELECIONADOS << "
Return

/*/{Protheus.doc} StruCab
Estrutura de modelo do cabeçalho (filtro + aplicação em massa).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function StruCab()
	Local oStru := FWFormModelStruct():New()
	Local bVazio := {|| .T.}

	DEFAULT oSX3 := fSX3Load()

	oStru:AddField(OemToAnsi(STR0007), OemToAnsi(STR0007), "CAB_FILDE", "C", TamSX3("RA_FILIAL")[1], 0, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Filial de"
	oStru:AddField(OemToAnsi(STR0008), OemToAnsi(STR0008), "CAB_FILATE", "C", TamSX3("RA_FILIAL")[1], 0, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Filial até"
	oStru:AddField(OemToAnsi(STR0009), OemToAnsi(STR0009), "CAB_CCDE", "C", TamSX3("RA_CC")[1], 0, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Centro de custo de"
	oStru:AddField(OemToAnsi(STR0010), OemToAnsi(STR0010), "CAB_CCATE", "C", TamSX3("RA_CC")[1], 0, bVazio, bVazio, {}, .F., , NIL, NIL, .F.) //"Centro de custo até"
	oStru:AddField(OemToAnsi(STR0011), OemToAnsi(STR0011), "CAB_DTAINI", "D", 8, 0, bVazio, bVazio, {}, .F., 			 , NIL, NIL, .F.) //"Início Afastamento De"
	oStru:AddField(OemToAnsi(STR0012), OemToAnsi(STR0012), "CAB_DTAFIM", "D", 8, 0, bVazio, bVazio, {}, .F., {|| Date() }, NIL, NIL, .F.) //"Início Afastamento Até"

	oStru:AddField(oSX3["PROC"]["TIT"] , oSX3["PROC"]["DESC"]  , "CAB_PROC" , oSX3["PROC"]["TIP"] , oSX3["PROC"]["LEN"] , oSX3["PROC"]["DEC"] , bVazio                                        , bVazio, {}, .F.,         , NIL, NIL, .F.)
	oStru:AddField(oSX3["CARGA"]["TIT"], oSX3["CARGA"]["DESC"] , "CAB_CARGA", oSX3["CARGA"]["TIP"], oSX3["CARGA"]["LEN"], oSX3["CARGA"]["DEC"], bVazio                                         , bVazio, {}, .F., {|| 0 }, NIL, NIL, .F.)
	oStru:AddField(oSX3["PERC"]["TIT"] , oSX3["PERC"]["DESC"]  , "CAB_PERC" , oSX3["PERC"]["TIP"] , oSX3["PERC"]["LEN"] , oSX3["PERC"]["DEC"] , {|oCab| VldPerc(oCab:GetValue("CAB_PERC")) }, bVazio, {}, .F., {|| 0 }, NIL, NIL, .F.)

Return oStru

/*/{Protheus.doc} ViewFilt
Estrutura de view dos filtros (filial, centro de custo e datas de afastamento).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function ViewFilt()
	Local oStru := FWFormViewStruct():New()

	oStru:AddField("CAB_FILDE" , "01", OemToAnsi(STR0007), OemToAnsi(STR0007), NIL, "C", "@!", NIL, "XM0", .T., "", "", {}, 0, "", .F.) //"Filial de"
	oStru:AddField("CAB_FILATE", "02", OemToAnsi(STR0008), OemToAnsi(STR0008), NIL, "C", "@!", NIL, "XM0", .T., "", "", {}, 0, "", .F.) //"Filial até"
	oStru:AddField("CAB_CCDE"  , "03", OemToAnsi(STR0009), OemToAnsi(STR0009), NIL, "C", "@!", NIL, "CTT", .T., "", "", {}, 0, "", .F.) //"Centro de custo de"
	oStru:AddField("CAB_CCATE" , "04", OemToAnsi(STR0010), OemToAnsi(STR0010), NIL, "C", "@!", NIL, "CTT", .T., "", "", {}, 0, "", .F.) //"Centro de custo até"
	oStru:AddField("CAB_DTAINI", "05", OemToAnsi(STR0011), OemToAnsi(STR0011), NIL, "D", "", NIL, "", .T., "", "", {}, 0, "", .F.) //"Início Afastamento De"
	oStru:AddField("CAB_DTAFIM", "06", OemToAnsi(STR0012), OemToAnsi(STR0012), NIL, "D", "", NIL, "", .T., "", "", {}, 0, "", .F.) //"Início Afastamento Até"

Return oStru

/*/{Protheus.doc} ViewAplic
Estrutura de view da aplicação em massa (processo, carga horária e percentual).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function ViewAplic()
	Local oStru := FWFormViewStruct():New()

	DEFAULT oSX3 := fSX3Load()

	oStru:AddField("CAB_PROC" , "01", oSX3["PROC"]["TIT"] , oSX3["PROC"]["DESC"] , NIL, oSX3["PROC"]["TIP"] , "@!"             , NIL, oSX3["PROC"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("CAB_CARGA", "02", oSX3["CARGA"]["TIT"], oSX3["CARGA"]["DESC"], NIL, oSX3["CARGA"]["TIP"], "@E 9999999999"  , NIL, oSX3["CARGA"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("CAB_PERC" , "03", oSX3["PERC"]["TIT"] , oSX3["PERC"]["DESC"] , NIL, oSX3["PERC"]["TIP"] , "@E 999"         , NIL, oSX3["PERC"]["F3"] , .T., "", "", {}, 0, "", .F.)

Return oStru

/*/{Protheus.doc} StruDet
Estrutura de modelo do grid (todos os campos do Registro 01 do layout Codefat).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function StruDet()
	Local oStru  := FWFormModelStruct():New()
	Local bVazio := {|| .T.}

	DEFAULT oSX3 := fSX3Load() // Obtém informações para definição dinâmica de campos de filial e matrícula (tamanho, título, descrição, tipo, picture, etc)

	//FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
	oStru:AddField(OemToAnsi(STR0048)  , OemToAnsi(STR0026)           , "DET_SEL"   , "L"          , 1                    , 0, bVazio                     , bVazio, {}, .F., {|| .F. }       , NIL, NIL, .F.) //"Sel" //"Selecionar linha"
	oStru:AddField(oSX3["FIL"]["TIT"] , oSX3["FIL"]["DESC"]          , "DET_FILIAL", oSX3["FIL"]["TIP"], TamSX3("RA_FILIAL")[1], 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["MAT"]["TIT"] , oSX3["MAT"]["DESC"]          , "DET_MAT"   , oSX3["MAT"]["TIP"], TamSX3("RA_MAT")[1]   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["NOME"]["TIT"], oSX3["NOME"]["DESC"]         , "DET_NOME"  , oSX3["NOME"]["TIP"], 40                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["MAE"]["TIT"] , oSX3["MAE"]["DESC"]          , "DET_MAE"   , oSX3["MAE"]["TIP"], 40                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["LOGRAD"]["TIT"], oSX3["LOGRAD"]["DESC"]     , "DET_LOGRAD", oSX3["LOGRAD"]["TIP"], 40                 , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["NUMERO"]["TIT"], oSX3["NUMERO"]["DESC"]     , "DET_NUMERO", oSX3["NUMERO"]["TIP"], 5                  , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["BAIRRO"]["TIT"], oSX3["BAIRRO"]["DESC"]     , "DET_BAIRRO", oSX3["BAIRRO"]["TIP"], 60                 , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["COMPL"]["TIT"], oSX3["COMPL"]["DESC"]       , "DET_COMPL" , oSX3["COMPL"]["TIP"], 12                  , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["DDD"]["TIT"] , oSX3["DDD"]["DESC"]          , "DET_DDD"   , oSX3["DDD"]["TIP"], 2                    , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["TELEFO"]["TIT"], oSX3["TELEFO"]["DESC"]     , "DET_TELEFO", oSX3["TELEFO"]["TIP"], 9                  , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["CEP"]["TIT"] , oSX3["CEP"]["DESC"]          , "DET_CEP"   , oSX3["CEP"]["TIP"], 8                    , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["CTPS"]["TIT"], oSX3["CTPS"]["DESC"]         , "DET_CTPS"  , oSX3["CTPS"]["TIP"], 8                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["SERCP"]["TIT"], oSX3["SERCP"]["DESC"]       , "DET_SERCP" , oSX3["SERCP"]["TIP"], 5                  , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["UFCP"]["TIT"], oSX3["UFCP"]["DESC"]         , "DET_UFCP"  , oSX3["UFCP"]["TIP"], 2                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["CPF"]["TIT"] , oSX3["CPF"]["DESC"]          , "DET_CPF"   , oSX3["CPF"]["TIP"], 11                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["NASC"]["TIT"], oSX3["NASC"]["DESC"]         , "DET_NASC"  , oSX3["NASC"]["TIP"], 8                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["SEXO"]["TIT"], oSX3["SEXO"]["DESC"]         , "DET_SEXO"  , oSX3["SEXO"]["TIP"], 1                   , 0, bVazio                     , bVazio, {OemToAnsi(STR0049),OemToAnsi(STR0050)}, .F.,                 , NIL, NIL, .F.) //"M=Masculino" //"F=Feminino"
	oStru:AddField(oSX3["GRAINS"]["TIT"], oSX3["GRAINS"]["DESC"]     , "DET_GRAINS", oSX3["GRAINS"]["TIP"], 2                 , 0, bVazio                     , bVazio, oSX3["GRAINS"]["CBOX"], .F., , NIL, NIL, .F.)
	oStru:AddField(oSX3["ADMISS"]["TIT"], oSX3["ADMISS"]["DESC"]     , "DET_ADMISS", oSX3["ADMISS"]["TIP"], 8                 , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["DTINI"]["TIT"], oSX3["DTINI"]["DESC"]       , "DET_DTAINI", oSX3["DTINI"]["TIP"], 8                 , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField(oSX3["DTFIM"]["TIT"], oSX3["DTFIM"]["DESC"]       , "DET_DTAFIM", oSX3["DTFIM"]["TIP"], 8                 , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.)
	oStru:AddField("Mês Últ. Sal."    , OemToAnsi(STR0027)            , "DET_MESSAL1", "C"          , 2                    , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.) //"Mês último salário"
	oStru:AddField("Vlr. Últ. Sal."   , OemToAnsi(STR0028)            , "DET_VLRSAL1", "N"         , 10                   , 2, bVazio                     , bVazio, {}, .F., {|| 0 }         , NIL, NIL, .F.) //"Valor último salário"
	oStru:AddField("Mês Penúlt. Sal.", OemToAnsi(STR0029)            , "DET_MESSAL2", "C"         , 2                    , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.) //"Mês penúltimo salário"
	oStru:AddField("Vlr. Penúlt. Sal.", OemToAnsi(STR0030)           , "DET_VLRSAL2", "N"         , 10                   , 2, bVazio                     , bVazio, {}, .F., {|| 0 }         , NIL, NIL, .F.) //"Valor penúltimo salário"
	oStru:AddField("Mês Antepenúlt." , OemToAnsi(STR0031)            , "DET_MESSAL3", "C"         , 2                    , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.) //"Mês antepenúltimo salário"
	oStru:AddField("Vlr. Antepenúlt.", OemToAnsi(STR0032)           , "DET_VLRSAL3", "N"         , 10                   , 2, bVazio                     , bVazio, {}, .F., {|| 0 }         , NIL, NIL, .F.) //"Valor antepenúltimo salário"
	oStru:AddField(oSX3["CBO"]["TIT"] , oSX3["CBO"]["DESC"]          , "DET_CBO"   , oSX3["CBO"]["TIP"], oSX3["CBO"]["LEN"]   , oSX3["CBO"]["DEC"], bVazio, bVazio, {}, .F.,       , NIL, NIL, .F.)
	oStru:AddField(oSX3["PROC"]["TIT"], oSX3["PROC"]["DESC"]        , "DET_PROC"  , oSX3["PROC"]["TIP"], oSX3["PROC"]["LEN"]  , oSX3["PROC"]["DEC"], bVazio, bVazio, {}, .F.,               , NIL, NIL, .F.)
	oStru:AddField(oSX3["CARGA"]["TIT"], oSX3["CARGA"]["DESC"]     , "DET_CARGA" , oSX3["CARGA"]["TIP"], oSX3["CARGA"]["LEN"], oSX3["CARGA"]["DEC"], bVazio, bVazio, {}, .F., {|| 0 }       , NIL, NIL, .F.)
	oStru:AddField(oSX3["PERC"]["TIT"], oSX3["PERC"]["DESC"]       , "DET_PERC"  , oSX3["PERC"]["TIP"], oSX3["PERC"]["LEN"]  , oSX3["PERC"]["DEC"], {|| VldPerc(M->DET_PERC) }, bVazio, {}, .F., {|| 0 }, NIL, NIL, .F.)
	oStru:AddField(oSX3["BCOD"]["TIT"], oSX3["BCOD"]["DESC"]       , "DET_BCOD"  , oSX3["BCOD"]["TIP"], oSX3["BCOD"]["LEN"]  , oSX3["BCOD"]["DEC"], bVazio, bVazio, {}, .F., {|| Space(3) }  , NIL, NIL, .F.)
	oStru:AddField(oSX3["TPCTA"]["TIT"], oSX3["TPCTA"]["DESC"]    , "DET_TPCTA" , oSX3["TPCTA"]["TIP"], oSX3["TPCTA"]["LEN"], oSX3["TPCTA"]["DEC"], bVazio, bVazio, {" ",OemToAnsi(STR0059),OemToAnsi(STR0060)}, .F., , NIL, NIL, .F.)
	oStru:AddField(oSX3["AGENC"]["TIT"], oSX3["AGENC"]["DESC"]    , "DET_AGENC" , oSX3["AGENC"]["TIP"], oSX3["AGENC"]["LEN"], oSX3["AGENC"]["DEC"], bVazio, bVazio, {}, .F., {|| Space(4) }  , NIL, NIL, .F.)
	oStru:AddField(oSX3["DVAGC"]["TIT"], oSX3["DVAGC"]["DESC"]    , "DET_DVAGC" , oSX3["DVAGC"]["TIP"], oSX3["DVAGC"]["LEN"], oSX3["DVAGC"]["DEC"], bVazio, bVazio, {}, .F., {|| Space(1) }  , NIL, NIL, .F.)
	oStru:AddField(oSX3["NUMCTA"]["TIT"], oSX3["NUMCTA"]["DESC"] , "DET_NUMCTA", oSX3["NUMCTA"]["TIP"], oSX3["NUMCTA"]["LEN"], oSX3["NUMCTA"]["DEC"], bVazio, bVazio, {}, .F., {|| Space(12) }, NIL, NIL, .F.)
	oStru:AddField(oSX3["DVCTA"]["TIT"], oSX3["DVCTA"]["DESC"]    , "DET_DVCTA" , oSX3["DVCTA"]["TIP"], oSX3["DVCTA"]["LEN"], oSX3["DVCTA"]["DEC"], bVazio, bVazio, {}, .F., {|| Space(1) }  , NIL, NIL, .F.)
	oStru:AddField(OemToAnsi(STR0051), OemToAnsi(STR0051)            , "DET_CAEPF" , "C"          , 14                   , 0, bVazio                     , bVazio, {}, .F.,                 , NIL, NIL, .F.) //"CAEPF"

Return oStru

/*/{Protheus.doc} ViewDet
Estrutura de view do grid (colunas visíveis e editáveis).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function ViewDet()
	Local oStru := FWFormViewStruct():New()

	DEFAULT oSX3 := fSX3Load()

	//FWFORMVIEWSTRUCT():AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

	// Seleção e identificação
	oStru:AddField("DET_SEL"   , "01", OemToAnsi(STR0048)  , OemToAnsi(STR0020)        , NIL, "L"                , "@"                , NIL, oSX3["FIL"]["F3"], .T., "", "", {}, 0, "", .F.) //"Sel" //"Selecionar"
	oStru:AddField("DET_FILIAL", "02", oSX3["FIL"]["TIT"]   , oSX3["FIL"]["DESC"]          , NIL, oSX3["FIL"]["TIP"] , oSX3["FIL"]["PIC"]    , NIL, oSX3["FIL"]["F3"], .F., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_MAT"   , "03", oSX3["MAT"]["TIT"]   , oSX3["MAT"]["DESC"]          , NIL, oSX3["MAT"]["TIP"] , oSX3["MAT"]["PIC"]    , NIL, oSX3["MAT"]["F3"], .F., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_NOME"  , "04", oSX3["NOME"]["TIT"]  , oSX3["NOME"]["DESC"]         , NIL, oSX3["NOME"]["TIP"], "@!"               , NIL, oSX3["NOME"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_CPF"   , "05", oSX3["CPF"]["TIT"]   , oSX3["CPF"]["DESC"]          , NIL, oSX3["CPF"]["TIP"] , "@R 999.999.999-99", NIL, oSX3["CPF"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_NASC"  , "06", oSX3["NASC"]["TIT"]  , oSX3["NASC"]["DESC"]         , NIL, oSX3["NASC"]["TIP"], ""                 , NIL, oSX3["NASC"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_SEXO"  , "07", oSX3["SEXO"]["TIT"]  , oSX3["SEXO"]["DESC"]         , NIL, oSX3["SEXO"]["TIP"], "@!"               , NIL, oSX3["SEXO"]["F3"], .T., "", "", {OemToAnsi(STR0049),OemToAnsi(STR0050)}, 0, "", .F.) //"M=Masculino" //"F=Feminino"

	// Bolsa Qualificação
	oStru:AddField("DET_PROC"  , "08", oSX3["PROC"]["TIT"]  , oSX3["PROC"]["DESC"]       , NIL, oSX3["PROC"]["TIP"]  , "@!"             , NIL, oSX3["PROC"]["F3"]  , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_CARGA" , "09", oSX3["CARGA"]["TIT"] , oSX3["CARGA"]["DESC"]     , NIL, oSX3["CARGA"]["TIP"] , "@E 9999999999"  , NIL, oSX3["CARGA"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_PERC"  , "10", oSX3["PERC"]["TIT"]  , oSX3["PERC"]["DESC"]       , NIL, oSX3["PERC"]["TIP"]  , "@E 999"         , NIL, oSX3["PERC"]["F3"]  , .T., "", "", {}, 0, "", .F.)

	// Dados complementares
	oStru:AddField("DET_MAE"   , "11", oSX3["MAE"]["TIT"]    , oSX3["MAE"]["DESC"]           , NIL, oSX3["MAE"]["TIP"]   , "@!"               , NIL, oSX3["MAE"]["F3"]   , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_GRAINS", "12", oSX3["GRAINS"]["TIT"] , oSX3["GRAINS"]["DESC"]        , NIL, oSX3["GRAINS"]["TIP"], "@!"               , NIL, oSX3["GRAINS"]["F3"], .T., "", "", oSX3["GRAINS"]["CBOX"], 0, "", .F.)
	oStru:AddField("DET_CEP"   , "13", oSX3["CEP"]["TIT"]    , oSX3["CEP"]["DESC"]           , NIL, oSX3["CEP"]["TIP"]   , "@R 99999-999"     , NIL, oSX3["CEP"]["F3"]   , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_LOGRAD", "14", oSX3["LOGRAD"]["TIT"] , oSX3["LOGRAD"]["DESC"]        , NIL, oSX3["LOGRAD"]["TIP"], "@!"               , NIL, oSX3["LOGRAD"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_NUMERO", "15", oSX3["NUMERO"]["TIT"] , oSX3["NUMERO"]["DESC"]        , NIL, oSX3["NUMERO"]["TIP"], "@!"               , NIL, oSX3["NUMERO"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_BAIRRO", "16", oSX3["BAIRRO"]["TIT"] , oSX3["BAIRRO"]["DESC"]        , NIL, oSX3["BAIRRO"]["TIP"], "@!"               , NIL, oSX3["BAIRRO"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_COMPL" , "17", oSX3["COMPL"]["TIT"]  , oSX3["COMPL"]["DESC"]         , NIL, oSX3["COMPL"]["TIP"] , "@!"               , NIL, oSX3["COMPL"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_DDD"   , "18", oSX3["DDD"]["TIT"]    , oSX3["DDD"]["DESC"]           , NIL, oSX3["DDD"]["TIP"]   , "@R 99"            , NIL, oSX3["DDD"]["F3"]   , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_TELEFO", "19", oSX3["TELEFO"]["TIT"] , oSX3["TELEFO"]["DESC"]        , NIL, oSX3["TELEFO"]["TIP"], "@R 999999999"     , NIL, oSX3["TELEFO"]["F3"], .T., "", "", {}, 0, "", .F.)

	// Documentos
	oStru:AddField("DET_CTPS"  , "20", oSX3["CTPS"]["TIT"]   , oSX3["CTPS"]["DESC"]          , NIL, oSX3["CTPS"]["TIP"] , "@R 99999999"      , NIL, oSX3["CTPS"]["F3"]  , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_SERCP" , "21", oSX3["SERCP"]["TIT"]  , oSX3["SERCP"]["DESC"]         , NIL, oSX3["SERCP"]["TIP"], "@R 99999"         , NIL, oSX3["SERCP"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_UFCP"  , "22", oSX3["UFCP"]["TIT"]   , oSX3["UFCP"]["DESC"]          , NIL, oSX3["UFCP"]["TIP"] , "@!"               , NIL, oSX3["UFCP"]["F3"]  , .T., "", "", {}, 0, "", .F.)

	// Dados profissionais
	oStru:AddField("DET_ADMISS", "23", oSX3["ADMISS"]["TIT"], oSX3["ADMISS"]["DESC"]        , NIL, oSX3["ADMISS"]["TIP"], ""                 , NIL, oSX3["ADMISS"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_CBO"   , "24", oSX3["CBO"]["TIT"]   , oSX3["CBO"]["DESC"]           , NIL, oSX3["CBO"]["TIP"]   , "@R 999999"      , NIL, oSX3["CBO"]["F3"]   , .T., "", "", {}, 0, "", .F.)

	// Afastamento
	oStru:AddField("DET_DTAINI", "25", oSX3["DTINI"]["TIT"] , oSX3["DTINI"]["DESC"]          , NIL, oSX3["DTINI"]["TIP"] , ""                 , NIL, oSX3["DTINI"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_DTAFIM", "26", oSX3["DTFIM"]["TIT"] , oSX3["DTFIM"]["DESC"]          , NIL, oSX3["DTFIM"]["TIP"] , ""                 , NIL, oSX3["DTFIM"]["F3"] , .T., "", "", {}, 0, "", .F.)

	// Salários
	oStru:AddField("DET_MESSAL1", "27", "Mês Últ. Sal"      , OemToAnsi(STR0027)            , NIL, "C"                , "@!"               , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"Mês último salário"
	oStru:AddField("DET_VLRSAL1", "28", "Vlr Últ. Sal"      , OemToAnsi(STR0028)            , NIL, "N"                , "@E 999,999.99"    , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"Valor último salário"
	oStru:AddField("DET_MESSAL2", "29", "Mês Pen. Sal"      , OemToAnsi(STR0029)            , NIL, "C"                , "@!"               , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"Mês penúltimo salário"
	oStru:AddField("DET_VLRSAL2", "30", "Vlr Pen. Sal"      , OemToAnsi(STR0030)            , NIL, "N"                , "@E 999,999.99"    , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"Valor penúltimo salário"
	oStru:AddField("DET_MESSAL3", "31", "Mês Ant. Sal"      , OemToAnsi(STR0031)            , NIL, "C"                , "@!"               , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"Mês antepenúltimo salário"
	oStru:AddField("DET_VLRSAL3", "32", "Vlr Ant. Sal"      , OemToAnsi(STR0032)            , NIL, "N"                , "@E 999,999.99"    , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"Valor antepenúltimo salário"

	// Dados bancários
	oStru:AddField("DET_BCOD"  , "33", oSX3["BCOD"]["TIT"]  , oSX3["BCOD"]["DESC"]       , NIL, oSX3["BCOD"]["TIP"]  , "@R 999"         , NIL, oSX3["BCOD"]["F3"]  , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_TPCTA" , "34", oSX3["TPCTA"]["TIT"] , oSX3["TPCTA"]["DESC"]     , NIL, oSX3["TPCTA"]["TIP"] , "@!"             , NIL, oSX3["TPCTA"]["F3"] , .T., "", "", {" ",OemToAnsi(STR0059),OemToAnsi(STR0060)}, 0, "", .F.)
	oStru:AddField("DET_AGENC" , "35", oSX3["AGENC"]["TIT"] , oSX3["AGENC"]["DESC"]     , NIL, oSX3["AGENC"]["TIP"] , "@R 9999"        , NIL, oSX3["AGENC"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_DVAGC" , "36", oSX3["DVAGC"]["TIT"] , oSX3["DVAGC"]["DESC"]     , NIL, oSX3["DVAGC"]["TIP"] , "@!"             , NIL, oSX3["DVAGC"]["F3"] , .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_NUMCTA", "37", oSX3["NUMCTA"]["TIT"], oSX3["NUMCTA"]["DESC"]    , NIL, oSX3["NUMCTA"]["TIP"], "@R 999999999999", NIL, oSX3["NUMCTA"]["F3"], .T., "", "", {}, 0, "", .F.)
	oStru:AddField("DET_DVCTA" , "38", oSX3["DVCTA"]["TIT"] , oSX3["DVCTA"]["DESC"]     , NIL, oSX3["DVCTA"]["TIP"] , "@!"             , NIL, oSX3["DVCTA"]["F3"] , .T., "", "", {}, 0, "", .F.)

	//Outros
	oStru:AddField("DET_CAEPF", "39", OemToAnsi(STR0051), OemToAnsi(STR0051)           , NIL, "C"                , "@!"               , NIL, ""             , .T., "", "", {}, 0, "", .F.) //"CAEPF"

Return oStru

/*/{Protheus.doc} CargaCab
Bloco de carga do cabeçalho (valores iniciais dos filtros e aplicação em massa).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function CargaCab(oModel)
	Local nTamFil	:= TamSX3("RA_FILIAL")[1]
	Local nTamCC	:= TamSX3("RA_CC")[1]
	Local aRet		:= {}

	Default oModel	:= Nil
	Default oSX3	:= fSX3Load()

	aRet := {;
		Space(nTamFil),; // CAB_FILDE (C)
		Replicate("Z", nTamFil),; // CAB_FILATE (C)
		Space(nTamCC),; // CAB_CCDE (C)
		Replicate("Z", nTamCC),; // CAB_CCATE (C)
		Stod(""),; // CAB_DTAINI
		Date(),; // CAB_DTAFIM
		Space(oSX3["PROC"]["LEN"]),; // CAB_PROC (C)
		0,; // CAB_CARGA (N)
		0; // CAB_PERC (N)
	}

Return aRet

/*/{Protheus.doc} CargaDet
Bloco de carga do grid (retorna vazio, dados carregados via botão Filtrar).
@author martins.marcio
@since 09/03/2026
@version 1.0
/*/
Static Function CargaDet(oModel)
Return {}

/*/{Protheus.doc} Filtrar
Carrega o grid com funcionários afastados (R8_TPEFD=27) conforme filtros informados.
@author martins.marcio
@since 09/03/2026
@version 1.0
@param oModel, Object, Modelo MVC ativo
@return lOk, Logical, .T. se carga bem-sucedida
/*/
Static Function Filtrar(oModel)
	Local cTitulo  := OemToAnsi(STR0044) //"Processando carga de afastamentos"
	Local cDesc    := OemToAnsi(STR0045) //"Carregando dados, aguarde..."
	Local oProcess := Nil
	Local lRet     := .F.

	Default oModel := Nil

	oProcess := MsNewProcess():New({|lEnd| lRet := ProcFilt(oProcess, oModel, @lEnd) }, cTitulo, cDesc, .T.)
	oProcess:Activate()

Return lRet

/*/{Protheus.doc} ProcFilt
Executa a carga do filtro com barra de progresso.
@author martins.marcio
@since 10/03/2026
@version 1.0
@param oProcess, Object, Objeto de progresso
@param oModel, Object, Modelo MVC ativo
@param lEnd, Logical, Controle de cancelamento do processamento
@return lOk, Logical, .T. se carga bem-sucedida
/*/
Static Function ProcFilt(oProcess, oModel, lEnd)
	Local oCab       := oModel:GetModel("GP949_MCAB")
	Local oDet       := oModel:GetModel("GP949_MDET")
	Local oView      := FWViewActive()
	Local cFilDe     := AllTrim(oCab:GetValue("CAB_FILDE"))
	Local cFilAte    := AllTrim(oCab:GetValue("CAB_FILATE"))
	Local cCcDe      := AllTrim(oCab:GetValue("CAB_CCDE"))
	Local cCcAte     := AllTrim(oCab:GetValue("CAB_CCATE"))
	Local dIni       := oCab:GetValue("CAB_DTAINI")
	Local dFim       := oCab:GetValue("CAB_DTAFIM")
	Local nLin       := 0
	Local lOk        := .T.
	Local nLinAnt    := 0
	Local nPosLin    := 0
	Local nIncluidos := 0
	Local cAliasFunc := ""
	Local aUltSal    := {}
	Local nPosEst    := 0
	Local cCaepf     := ""
	Local nTotReg    := 0
	Local cLastFil   := ""

	Default lCargSQ3 := SuperGetMv("MV_CARGSQ3",,.F.)
	Default oProcess := Nil
	Default oModel   := Nil
	Default lEnd     := .F.

	cFilDe  := IIf(Empty(cFilDe),Replicate(" ", TamSX3("RA_FILIAL")[1]), cFilDe)
	cFilAte := IIf(Empty(cFilAte),Replicate("Z", TamSX3("RA_FILIAL")[1]), cFilAte)
	cCCDe   := IIf(Empty(cCcDe),Replicate(" ", TamSX3("RA_CC")[1]), cCcDe)
	cCcAte  := IIf(Empty(cCcAte),Replicate("Z", TamSX3("RA_CC")[1]), cCcAte)

	If !Empty(dIni) .And. !Empty(dFim) .And. dFim < dIni
		Help(" ",1,"DATA2INVAL")
		Return .F.
	EndIf

	// Limpa o grid marcando linhas anteriores como deletadas
	// e recarrega o resultado sempre com AddLine().
	nLinAnt := oDet:Length()
	oDet:SetNoDeleteLine(.F.)
	For nLin := nLinAnt To 1 Step -1
		oDet:GoLine(nLin)
		oDet:DeleteLine()
	Next nLin
	oDet:SetNoDeleteLine(.T.)

	cAliasFunc := fGetFunc(cFilDe, cFilAte, cCcDe, cCcAte, dIni, dFim)
	aEstabele  := fGM23SM0(.T., .F., "", .T.)

	DbSelectArea("SRA")
	SRA->(DbGoTop())
	DbSelectArea(cAliasFunc)
	(cAliasFunc)->(DbGoTop())
	Count To nTotReg
	(cAliasFunc)->(DbGoTop())

	If ValType(oProcess) == "O"
		oProcess:SetRegua1(Max(nTotReg, 1))
	EndIf

	While !(cAliasFunc)->(Eof()) .And. !lEnd

		SRA->(DbGoTo((cAliasFunc)->RA_RECNO))

		nPosLin++
		If ValType(oProcess) == "O"
			oProcess:IncRegua1(OemToAnsi(STR0043) + AllTrim(SRA->RA_MAT) + " [" + AllTrim(Str(nPosLin)) + "/" + AllTrim(Str(nTotReg)) + "]") //"Carregando funcionário "
		EndIf

		If nPosLin <= nLinAnt
			oDet:GoLine(nPosLin)
			oDet:UnDeleteLine()
		Else
			oDet:SetNoInsertLine(.F.)
			If !oDet:AddLine(.T.)
				// FWAlertError("Falha ao incluir linha no grid. Posição: " + AllTrim(Str(nPosLin)) + " / Length: " + AllTrim(Str(oDet:Length())), "Filtro")
				// Exit
			EndIf
			oDet:GoLine(oDet:Length())
		EndIf

		oDet:SetValue("DET_SEL", .T.)
		oDet:SetValue("DET_FILIAL", SRA->RA_FILIAL)
		oDet:SetValue("DET_MAT", SRA->RA_MAT)
		oDet:SetValue("DET_NOME", PadR(Left(AllTrim(SRA->RA_NOMECMP), 40), 40))
		oDet:SetValue("DET_MAE", PadR(Left(AllTrim(SRA->RA_MAE), 40), 40))
		oDet:SetValue("DET_LOGRAD", PadR(Left(AllTrim(SRA->RA_LOGRDSC), 40), 40))
		oDet:SetValue("DET_NUMERO", PadR(AllTrim(SRA->RA_LOGRNUM), 5))
		oDet:SetValue("DET_BAIRRO", PadR(Left(AllTrim(SRA->RA_BAIRRO), 60), 60))
		oDet:SetValue("DET_COMPL", PadR(Left(AllTrim(SRA->RA_COMPLEM), 12), 12))
		oDet:SetValue("DET_DDD", PadR(AllTrim(SRA->RA_DDDFONE), 2))
		oDet:SetValue("DET_TELEFO", PadL(Right(fSoNumeros(SRA->RA_TELEFON), 9), 9, "0"))
		oDet:SetValue("DET_CEP", StrTran(StrTran(SRA->RA_CEP, "-", ""), ".", ""))
		oDet:SetValue("DET_CTPS", PadR(AllTrim(SRA->RA_NUMCP), 8))
		oDet:SetValue("DET_SERCP", PadR(AllTrim(SRA->RA_SERCP), 5))

		// Mantém valor original da RA_UFCP para mapear/normalizar somente na geração do arquivo
		oDet:SetValue("DET_UFCP", AllTrim(SRA->RA_UFCP))
		oDet:SetValue("DET_CPF", StrTran(StrTran(StrTran(SRA->RA_CIC, ".", ""), "-", ""), "/", ""))
		oDet:SetValue("DET_NASC", SRA->RA_NASC)
		// Mantém valor original da RA_SEXO para mapear somente na geração do arquivo
		oDet:SetValue("DET_SEXO", AllTrim(SRA->RA_SEXO))
		oDet:SetValue("DET_GRAINS", SRA->RA_GRINRAI)
		oDet:SetValue("DET_ADMISS", SRA->RA_ADMISSA)
		oDet:SetValue("DET_DTAINI", StoD((cAliasFunc)->R8_DATAINI))
		oDet:SetValue("DET_DTAFIM", StoD((cAliasFunc)->R8_DATAFIM))

		// Últimos 3 salários tomando a data inicial do afastamento como referência
		aUltSal := fUlt3Sal(oDet:GetValue("DET_DTAINI"), SRA->RA_ADMISSA)
		oDet:SetValue("DET_MESSAL1", aUltSal[1])
		oDet:SetValue("DET_VLRSAL1", aUltSal[2])
		oDet:SetValue("DET_MESSAL2", aUltSal[3])
		oDet:SetValue("DET_VLRSAL2", aUltSal[4])
		oDet:SetValue("DET_MESSAL3", aUltSal[5])
		oDet:SetValue("DET_VLRSAL3", aUltSal[6])
		oDet:SetValue("DET_CBO", IIf(lCargSQ3, ;
			PadL(AllTrim(Posicione("SQ3", 1, xFilial("SQ3") + SRA->RA_CARGO, "Q3_CBO")), 6, "0"), ;
			PadL(AllTrim(Posicione("SRJ", 1, xFilial("SRJ") + SRA->RA_CODFUNC, "RJ_CODCBO")), 6, "0") ))
		// Dados da bolsa e bancários obtidos da tabela RVQ (chave: filial + matrícula + data de afastamento).
		// Os campos bancários são preenchidos a partir da RVQ (conta específica para o benefício),
		// conforme exigência do Banco Central que impede o uso da conta salário (SRA).
		oDet:SetValue("DET_PROC"  , AllTrim((cAliasFunc)->RVQ_NPROC ))
		oDet:SetValue("DET_CARGA" , (cAliasFunc)->RVQ_CARGHO)
		oDet:SetValue("DET_PERC"  , (cAliasFunc)->RVQ_PERCEN)
		oDet:SetValue("DET_BCOD"  , AllTrim((cAliasFunc)->RVQ_CODBAN))
		oDet:SetValue("DET_TPCTA" , AllTrim((cAliasFunc)->RVQ_TIPCTA))
		oDet:SetValue("DET_AGENC" , AllTrim((cAliasFunc)->RVQ_AGENCI))
		oDet:SetValue("DET_DVAGC" , AllTrim((cAliasFunc)->RVQ_DVAGEN))
		oDet:SetValue("DET_NUMCTA", AllTrim((cAliasFunc)->RVQ_NUMCTA))
		oDet:SetValue("DET_DVCTA" , AllTrim((cAliasFunc)->RVQ_DVCONT))

		// CAEPF
		If Empty(cLastFil) .Or. cLastFil != SRA->RA_FILIAL
			nPosEst := aScan(aEstabele, {|x| AllTrim(x[1]) == AllTrim(SRA->RA_FILIAL)})
			cCaepf  := ""
			If nPosEst > 0 .And. Len(aEstabele[nPosEst]) >= 3 .And. aEstabele[nPosEst][3] == "3"
				cCaepf := AllTrim(aEstabele[nPosEst][2])
				cCaepf := StrTran(StrTran(StrTran(cCaepf, ".", ""), "/", ""), "-", "")
			EndIf
		EndIf
		cLastFil := SRA->RA_FILIAL
		oDet:SetValue("DET_CAEPF", PadR(Left(cCaepf, 14), 14))

		nIncluidos ++
		lOk := .T.

		(cAliasFunc)->(DbSkip())
	EndDo

	If SELECT(cAliasFunc) > 0
		(cAliasFunc)->(dbCloseArea())
	EndIf

	lOk := (lOk .And. !lEnd)

	If nIncluidos > 0
		oDet:GoLine(1)
		If ValType(oView) == "O"
			oView:Refresh("GP949_VDET")
		EndIf
		FWAlertInfo(OemToAnsi(STR0052) + AllTrim(Str(nIncluidos)), OemToAnsi(STR0053)) //"Total de registros carregados: " //"Filtro"
	Else
		FWAlertInfo(OemToAnsi(STR0054), OemToAnsi(STR0053)) //"Nenhum registro encontrado para os filtros informados." //"Filtro"
	EndIf

Return lOk

/*/{Protheus.doc} AplTodos
Replica os campos informados no cabeçalho (processo, carga, percentual) para todas as linhas não deletadas do grid.
@author martins.marcio
@since 09/03/2026
@version 1.0
@param oModel, Object, Modelo MVC ativo
@return lOk, Logical, .T. se aplicação bem-sucedida
/*/
Static Function AplTodos(oModel)
	Local oCab	:= oModel:GetModel("GP949_MCAB")
	Local oDet	:= oModel:GetModel("GP949_MDET")
	Local oView	:= FWViewActive()
	Local nLin	:= 0
	Local nAtu	:= 0
	Local cProc	:= oCab:GetValue("CAB_PROC")
	Local nCarga:= oCab:GetValue("CAB_CARGA")
	Local nPerc	:= oCab:GetValue("CAB_PERC")
	Local lOk	:= .T.

	If oDet:Length() == 0 .Or. (oDet:Length() == 1 .And. Empty(oDet:GetValue("DET_MAT")))
		FWAlertInfo(OemToAnsi(STR0033), OemToAnsi(STR0034)) //"Não há registros no grid para aplicar." //"Aplicar a todos"
		Return .F.
	EndIf

	For nLin := 1 To oDet:Length()
		oDet:GoLine(nLin)
		If oDet:IsDeleted() .Or. !oDet:GetValue("DET_SEL")
			Loop
		EndIf

		lOk := lOk .And. oDet:SetValue("DET_PROC", cProc)
		lOk := lOk .And. oDet:SetValue("DET_CARGA", nCarga)
		lOk := lOk .And. oDet:SetValue("DET_PERC", nPerc)
		nAtu++
	Next nLin

	If nAtu > 0 .And. ValType(oView) == "O"
		oDet:GoLine(1)
		oView:Refresh("GP949_VDET")
	EndIf

	FWAlertInfo(OemToAnsi(STR0035) + AllTrim(Str(nAtu)) + OemToAnsi(STR0036), OemToAnsi(STR0034)) //"Campos aplicados em " //" registro(s)." //"Aplicar a todos"
Return lOk

/*/{Protheus.doc} InvSel
Inverte a seleção (DET_SEL) de todas as linhas não deletadas do grid.
@author martins.marcio
@since 10/03/2026
@version 1.0
@param oModel, Object, Modelo MVC ativo
@return lRet, Logical, .T. se executado
/*/
Static Function InvSel(oModel)
	Local oDet	:= oModel:GetModel("GP949_MDET")
	Local oView	:= FWViewActive()
	Local nLin	:= 0
	Local nAtu	:= 0
	Local lRet	:= .T.

	If oDet:Length() == 0 .Or. (oDet:Length() == 1 .And. Empty(oDet:GetValue("DET_MAT")))
		FWAlertInfo(OemToAnsi(STR0037), OemToAnsi(STR0022)) //"Não há registros no grid para inverter seleção." //"Inverter Seleção"
		Return .F.
	EndIf

	For nLin := 1 To oDet:Length()
		oDet:GoLine(nLin)
		If oDet:IsDeleted()
			Loop
		EndIf

		lRet := lRet .And. oDet:SetValue("DET_SEL", !oDet:GetValue("DET_SEL"))
		nAtu++
	Next nLin

	If nAtu > 0 .And. ValType(oView) == "O"
		oDet:GoLine(1)
		oView:Refresh("GP949_VDET")
	EndIf

Return lRet

/*/{Protheus.doc} GerarArq
Gera arquivo TXT com as linhas selecionadas no grid (formato Codefat Bolsa Qualificação).
@author martins.marcio
@since 09/03/2026
@version 1.0
@param oModel, Object, Modelo MVC ativo
@return lRet, Logical, .T. se geração bem-sucedida
/*/
Static Function GerarArq(oModel)
	Local oDet       := oModel:GetModel("GP949_MDET")
	Local nLin       := 0
	Local cConteudo  := ""
	Local cLinha     := ""
	Local nSel       := 0
	Local cArq       := ""
	Local cCNPJ      := ""
	Local cTipoIdent := SPACE(1)
	Local nTotReg    := 0
	Local nPos       := 0
	Local nHandle	 := 0

	If oDet:Length() == 0 .Or. (oDet:Length() == 1 .And. Empty(oDet:GetValue("DET_MAT")))
		FWAlertInfo(OemToAnsi(STR0038), OemToAnsi(STR0024)) //"Não há registros para geração." //"Gerar arquivo"
		Return .F.
	EndIf

	// Obtém CNPJ/CEI/CPF/CAEPF e tipo já formatados pela função
	nPos := aScan(aEstabele, {|x| AllTrim(x[1]) == AllTrim(cFilAnt)})
	If nPos > 0 .And. Len(aEstabele[nPos]) >= 2
		cCNPJ := AllTrim(aEstabele[nPos][2])
		cCNPJ := StrTran(StrTran(StrTran(cCNPJ, ".", ""), "/", ""), "-", "")
		If Len(aEstabele[nPos]) >= 3
			cTipoIdent := aEstabele[nPos][3] // (1=CNPJ, 3=CAEPF, 4=CEI)
			cTipoIdent := IIf(cTipoIdent == "4", "2", cTipoIdent) // Se o tipo for 4 (CEI), ajusta para 2 conforme layout Codefat
		EndIf
	EndIf
	cCNPJ := PadR(cCNPJ, 14, " ")

	// Registro 00 - Header (450 caracteres)
	cConteudo := "00"                    // Tipo Registro (2)
	cConteudo += cTipoIdent              // Tipo Identificador (1)
	cConteudo += cCNPJ                   // Identificador Empresa (14)
	cConteudo += "001"                   // Versão Layout (3)
	cConteudo += Space(430)              // Filler (430)
	cConteudo += CRLF

	// Registros 01 - Detalhes
	For nLin := 1 To oDet:Length()
		oDet:GoLine(nLin)
		If oDet:IsDeleted() .Or. !oDet:GetValue("DET_SEL")
			Loop
		EndIf
		If !fVlGP949Ln(oDet)
			Return .F.
		EndIf
		cLinha := fMontReg01(oDet)
		cConteudo += cLinha + CRLF
		nSel++
	Next nLin

	If nSel == 0
		FWAlertInfo(OemToAnsi(STR0039), OemToAnsi(STR0024)) //"Selecione ao menos um registro (coluna 'Sel')." //"Gerar arquivo"
		Return .F.
	EndIf

	// Total de registros de detalhe (sem header e trailer)
	nTotReg := nSel

	// Registro 99 - Trailer (450 caracteres)
	cLinha := "99"                       // Tipo Registro (2)
	cLinha += PadL(AllTrim(Str(nTotReg)), 5, "0") // Quantidade de registros (5)
	cLinha += Space(443)                 // Filler (443)
	cConteudo += cLinha

	cArq := cGetFile(OemToAnsi(STR0057), OemToAnsi(STR0058), 1, "C:\TEMP\BOLSAQUALIF_" + DtoS(Date()) + ".SD", .F., GETF_LOCALHARD + GETF_LOCALFLOPPY + GETF_NETWORKDRIVE, .T., .T.) //"Arquivo SD|*.SD" //"Selecione local para salvar"
	If Empty(cArq)
		Return .F.
	EndIf
	nHandle := FCREATE(cArq, , , .F.)
	If nHandle >= 0
		FWrite(nHandle, cConteudo)
		FClose(nHandle)
		FWAlertInfo(OemToAnsi(STR0040) + CRLF + ; //"Arquivo gerado com sucesso!"
					OemToAnsi(STR0041) + AllTrim(Str(nSel)) + CRLF + ; //"Registros: "
					OemToAnsi(STR0042) + cArq, OemToAnsi(STR0024)) //"Arquivo: " //"Gerar arquivo"
	EndIf
Return .T.

/*/{Protheus.doc} fMontaReg01
Monta linha do Registro 01 (Detalhe) no formato Codefat (450 caracteres).
@author martins.marcio
@since 09/03/2026
@version 1.0
@param oDet, Object, Modelo do grid
@return cLinha, Char, Linha formatada com 450 caracteres
/*/
Static Function fMontReg01(oDet)
	Local cLinha  := ""
	Local cData   := ""
	Local nValor  := 0
	Local cCPFNum := ""
	Local cCTPS   := ""
	Local cSerie  := ""

	// Base CPF (somente números) para regras de CTPS/Série e campo CPF
	cCPFNum := fSoNumeros(AllTrim(oDet:GetValue("DET_CPF")))

	// Tipo Registro (2)
	cLinha := "01"

	// Nome Trabalhador (40)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_NOME")), 40), 40, " ")

	// Nome da Mãe (40)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_MAE")), 40), 40, " ")

	// Logradouro (40)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_LOGRAD")), 40), 40, " ")

	// Número (5)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_NUMERO")), 5), 5, " ")

	// Bairro (60)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_BAIRRO")), 60), 60, " ")

	// Complemento (12)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_COMPL")), 12), 12, " ")

	// DDD (2)
	cLinha += PadR(AllTrim(oDet:GetValue("DET_DDD")), 2, " ")

	// Telefone (9)
	cLinha += PadL(AllTrim(oDet:GetValue("DET_TELEFO")), 9, "0")

	// CEP (8)
	cLinha += PadR(AllTrim(oDet:GetValue("DET_CEP")), 8, "0")

	// Filler (11)
	cLinha += Space(11)

	// CTPS (15) opcionais
	cCTPS	:= fSoNumeros(AllTrim(oDet:GetValue("DET_CTPS")))
	cSerie	:= fSoNumeros(AllTrim(oDet:GetValue("DET_SERCP")))
	cData	:= Upper(AllTrim(oDet:GetValue("DET_UFCP")))
	cData	:= IIf(!Empty(cData), fUfValida(cData), cData)// Mapeamento/normalização somente na geração do arquivo.
	If Empty(cData) .And. Empty(cCTPS) .And. Empty(cSerie)
		cLinha += Space(15)
	Else
		// CTPS (8) - apenas números, com zeros à esquerda
		// Se não informado (Carteira Digital), usar os 8 primeiros dígitos do CPF
		cCTPS := IIf(Empty(cCTPS), Left(cCPFNum, 8), cCTPS)
		cLinha += PadL(Left(cCTPS, 8), 8, "0")

		// Série CTPS (5) - apenas números, com zeros à esquerda
		// Se não informado (Carteira Digital), usar 0 + 4 últimos dígitos do CPF
		cSerie := IIf(Empty(cSerie), "0" + Right(PadL(cCPFNum, 4, "0"), 4), cSerie)
		cLinha += PadL(Left(cSerie, 5), 5, "0")

		// UF CTPS (2)
		cLinha += PadR(Left(cData, 2), 2, " ")
	EndIf

	// CPF (11)
	cLinha += PadL(Left(cCPFNum, 11), 11, "0")

	// Data Nascimento (8 - DDMMAAAA)
	cData := DtoC(oDet:GetValue("DET_NASC"))
	cData := StrTran(cData, "/", "")
	cLinha += PadL(cData, 8, "0")

	// Sexo (1) - mapeamento Protheus -> Layout somente na geração
	cData := Upper(AllTrim(oDet:GetValue("DET_SEXO")))
	cData := IIf(cData == "M", "1", IIf(cData == "F", "2", cData))
	cLinha += PadR(Left(cData, 1), 1, " ")

	// Grau Instrução (2) - conversão Protheus -> Codefat somente na geração
	cLinha += PadL(AllTrim(fGrauInst(oDet:GetValue("DET_GRAINS"))), 2, "0")

	// Data Admissão (8 - DDMMAAAA)
	cData := DtoC(oDet:GetValue("DET_ADMISS"))
	cData := StrTran(cData, "/", "")
	cLinha += PadL(cData, 8, "0")

	// Data Início Afastamento (8 - DDMMAAAA)
	cData := DtoC(oDet:GetValue("DET_DTAINI"))
	cData := StrTran(cData, "/", "")
	cLinha += PadL(cData, 8, "0")

	// Data Fim Afastamento (8 - DDMMAAAA)
	cData := DtoC(oDet:GetValue("DET_DTAFIM"))
	cData := StrTran(cData, "/", "")
	cLinha += PadL(cData, 8, "0")

	// Mês Último Salário (2)
	cLinha += PadL(AllTrim(oDet:GetValue("DET_MESSAL1")), 2, "0")

	// Valor Último Salário (10 - sem vírgula, com centavos)
	nValor := oDet:GetValue("DET_VLRSAL1") * 100
	cLinha += PadL(AllTrim(Str(Int(nValor))), 10, "0")

	// Mês Penúltimo Salário (2)
	cLinha += PadL(AllTrim(oDet:GetValue("DET_MESSAL2")), 2, "0")

	// Valor Penúltimo Salário (10)
	nValor := oDet:GetValue("DET_VLRSAL2") * 100
	cLinha += PadL(AllTrim(Str(Int(nValor))), 10, "0")

	// Mês Antepenúltimo Salário (2)
	cLinha += PadL(AllTrim(oDet:GetValue("DET_MESSAL3")), 2, "0")

	// Valor Antepenúltimo Salário (10)
	nValor := oDet:GetValue("DET_VLRSAL3") * 100
	cLinha += PadL(AllTrim(Str(Int(nValor))), 10, "0")

	// CBO (6)
	cLinha += PadL(AllTrim(oDet:GetValue("DET_CBO")), 6, "0")

	// Número Processo (23)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_PROC")), 23), 23, " ")

	// Carga Horária (10 - sem vírgula, sem decimais)
	nValor := oDet:GetValue("DET_CARGA")
	cLinha += PadL(AllTrim(Str(Int(nValor))), 10, "0")

	// Percentual (3 - sem decimais)
	nValor := oDet:GetValue("DET_PERC")
	cLinha += PadL(AllTrim(Str(Int(nValor))), 3, "0")

	// Dados Bancários (22 - opcionais)
	If Empty( oDet:GetValue("DET_BCOD") + oDet:GetValue("DET_TPCTA") + oDet:GetValue("DET_AGENC") + oDet:GetValue("DET_NUMCTA") + oDet:GetValue("DET_DVCTA") )
		cLinha += Space(22)
	Else
		cLinha += PadL(Left(AllTrim(oDet:GetValue("DET_BCOD"  )),  3),  3, "0") // Cód.Banco Febraban (3)
		cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_TPCTA" )),  1),  1, " ") // Tipo conta: 0=CC 1=Poupança (1)
		cLinha += PadL(Left(AllTrim(oDet:GetValue("DET_AGENC" )),  4),  4, "0") // Agência (4)
		cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_DVAGC" )),  1),  1, " ") // DV Agência (1)
		cLinha += PadL(Left(AllTrim(oDet:GetValue("DET_NUMCTA")), 12), 12, "0") // Conta (12)
		cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_DVCTA" )),  1),  1, "0") // DV Conta (1)
	EndIf

	// CAEPF (14)
	cLinha += PadR(Left(AllTrim(oDet:GetValue("DET_CAEPF")), 14), 14, " ")

	// Filler (46)
	cLinha += Space(46)

Return cLinha

/*/{Protheus.doc} VldPerc
Validação de percentual (0 a 100).
@author martins.marcio
@since 09/03/2026
@version 1.0
@return lRet, Logical, .T. se percentual válido
/*/
Static Function VldPerc(nPerc)
	Local lRet := .T.
	Default nPerc := 0

	nPerc := IIf(ValType(nPerc) != "N", Val(AllTrim(cValToChar(nPerc))), nPerc)
	lRet := (nPerc >= 0 .And. nPerc <= 100)

Return lRet

/*/{Protheus.doc} CommitMdl
Commit do modelo (sem persistência em tabelas).
@author martins.marcio
@since 09/03/2026
@version 1.0
@param oModel, Object, Modelo MVC ativo
@return lRet, Logical, Sempre .T.
/*/
Static Function CommitMdl(oModel)
	Local oDet      := Nil
	Local nLin      := 0
	Local nGrv      := 0
	Local cFilTrab  := ""
	Local cMat      := ""
	Local dDtIni    := StoD("")
	Local cChvRVQ   := ""
	Local lRet      := .T.
	Local cMsg      := ""

	Default oSX3 := fSX3Load()
	Default oModel := Nil

	oDet := oModel:GetModel("GP949_MDET")

	DbSelectArea("RVQ")
	RVQ->(DbSetOrder(1)) // RVQ_FILIAL + RVQ_MAT + DTOS(RVQ_DATA)

	Begin Transaction
		For nLin := 1 To oDet:Length()
			oDet:GoLine(nLin)

			If !oDet:IsDeleted() .And. !(Empty(oDet:GetValue("DET_MAT")))
				cFilTrab := oDet:GetValue("DET_FILIAL")
				cMat     := oDet:GetValue("DET_MAT")
				dDtIni   := oDet:GetValue("DET_DTAINI")

				cChvRVQ := xFilial("RVQ", cFilTrab) + PadR(cMat, oSX3["MAT"]["LEN"]) + DtoS(dDtIni)

				If RVQ->(DbSeek(cChvRVQ))
					RecLock("RVQ", .F.)
				Else
					RecLock("RVQ", .T.)
					RVQ->RVQ_FILIAL := xFilial("RVQ", cFilTrab)
					RVQ->RVQ_MAT    := cMat
					RVQ->RVQ_DATA   := dDtIni
				EndIf

				RVQ->RVQ_NPROC  := oDet:GetValue("DET_PROC")
				RVQ->RVQ_CARGHO := oDet:GetValue("DET_CARGA")
				RVQ->RVQ_PERCEN := oDet:GetValue("DET_PERC")
				RVQ->RVQ_CODBAN := oDet:GetValue("DET_BCOD")
				RVQ->RVQ_TIPCTA := oDet:GetValue("DET_TPCTA")
				RVQ->RVQ_AGENCI := oDet:GetValue("DET_AGENC")
				RVQ->RVQ_DVAGEN := oDet:GetValue("DET_DVAGC")
				RVQ->RVQ_NUMCTA := oDet:GetValue("DET_NUMCTA")
				RVQ->RVQ_DVCONT := oDet:GetValue("DET_DVCTA")

				RVQ->(MsUnlock())
				nGrv++
			EndIf

		Next nLin
	End Transaction

	If lRet .And. !IsBlind()
		cMsg := OemToAnsi(STR0055) + AllTrim(Str(nGrv)) //"Gravação concluída. Registros gravados: "
		FWAlertInfo(cMsg, OemToAnsi(STR0056)) //"Gravação"
	EndIf

Return lRet

/*/{Protheus.doc} fSX3Load
Carrega o cache SX3 utilizado nas estruturas de modelo/view.
@author martins.marcio
@since 11/03/2026
@version 1.0
@return oSX3, Object, JsonObject com metadados dos campos SRA
/*/
Static Function fSX3Load()
	
	DEFAULT lCargSQ3  := SuperGetMv("MV_CARGSQ3",,.F.)
	
	oSX3 := IIf(ValType(oSX3) != "O", JsonObject():New(), oSX3)

	// Identificação e dados pessoais
	oSX3["FIL"]      := fSX3Meta("RA_FILIAL")
	oSX3["MAT"]      := fSX3Meta("RA_MAT")
	oSX3["NOME"]     := fSX3Meta("RA_NOMECMP")
	oSX3["MAE"]      := fSX3Meta("RA_MAE")
	oSX3["CPF"]      := fSX3Meta("RA_CIC")
	oSX3["NASC"]     := fSX3Meta("RA_NASC")
	oSX3["SEXO"]     := fSX3Meta("RA_SEXO")

	// Endereço
	oSX3["CEP"]      := fSX3Meta("RA_CEP")
	oSX3["LOGRAD"]   := fSX3Meta("RA_LOGRDSC")
	oSX3["NUMERO"]   := fSX3Meta("RA_LOGRNUM")
	oSX3["BAIRRO"]   := fSX3Meta("RA_BAIRRO")
	oSX3["COMPL"]    := fSX3Meta("RA_COMPLEM")

	// Contato
	oSX3["DDD"]      := fSX3Meta("RA_DDDFONE")
	oSX3["TELEFO"]   := fSX3Meta("RA_TELEFON")

	// Documentos
	oSX3["CTPS"]     := fSX3Meta("RA_NUMCP")
	oSX3["SERCP"]    := fSX3Meta("RA_SERCP")
	oSX3["UFCP"]     := fSX3Meta("RA_UFCP")

	// Dados profissionais
	oSX3["ADMISS"]   := fSX3Meta("RA_ADMISSA")
	oSX3["GRAINS"]   := fSX3Meta("RA_GRINRAI")
	oSX3["GRAINS"]["CBOX"] := fSX5Tab26()
	oSX3["CBO"]      := fSX3Meta(IIf(lCargSQ3, "Q3_CBO", "RJ_CODCBO"))
	oSX3["DTINI"]    := fSX3Meta("R8_DATAINI")
	oSX3["DTFIM"]    := fSX3Meta("R8_DATAFIM")
	oSX3["CC"]       := fSX3Meta("RA_CC")

	// Dados de bolsa qualificação (RVQ)
	oSX3["PROC"]     := fSX3Meta("RVQ_NPROC")
	oSX3["CARGA"]    := fSX3Meta("RVQ_CARGHO")
	oSX3["PERC"]     := fSX3Meta("RVQ_PERCEN")
	oSX3["BCOD"]     := fSX3Meta("RVQ_CODBAN")
	oSX3["TPCTA"]    := fSX3Meta("RVQ_TIPCTA")
	oSX3["AGENC"]    := fSX3Meta("RVQ_AGENCI")
	oSX3["DVAGC"]    := fSX3Meta("RVQ_DVAGEN")
	oSX3["NUMCTA"]   := fSX3Meta("RVQ_NUMCTA")
	oSX3["DVCTA"]    := fSX3Meta("RVQ_DVCONT")

Return oSX3

/*/{Protheus.doc} fSX3Meta
Obtém metadados de campo na SX3 (título, descrição, tipo, tamanho, máscara e F3).
@author martins.marcio
@since 11/03/2026
@version 1.0
@param cField, Character, Nome do campo SX3 (ex.: RA_FILIAL)
@return oRet, Object, JsonObject com chaves TIT, DESC, TIP, PIC, F3
/*/
Static Function fSX3Meta(cField)
	Local oRet   := JsonObject():New()
	Local aTam   := {}

	Default cField      := ""

	oRet["TIT"]  := ""
	oRet["DESC"] := ""
	oRet["TIP"]  := ""
	oRet["LEN"]  := 0
	oRet["DEC"]  := 0
	oRet["PIC"]  := ""
	oRet["F3"]   := ""

	If FWSX3Util():SeekX3File(cField) .And. Select("SX3") > 0
		aTam := TamSX3(cField)
		oRet["TIT"]  := AllTrim(SX3->X3_TITULO)
		oRet["DESC"] := AllTrim(SX3->X3_DESCRIC)
		oRet["TIP"]  := Upper(AllTrim(SX3->X3_TIPO))
		oRet["LEN"]  := IIf(Len(aTam) >= 1, aTam[1], oRet["LEN"])
		oRet["DEC"]  := IIf(Len(aTam) >= 2, aTam[2], oRet["DEC"])
		oRet["PIC"]  := AllTrim(SX3->X3_PICTURE)
		oRet["F3"]   := AllTrim(SX3->X3_F3)
	EndIf

Return oRet

/*/{Protheus.doc} fGetFunc
Executa query na SR8 + SRA para buscar funcionários com afastamento tipo 27 (Bolsa Qualificação).
@author martins.marcio
@since 09/03/2026
@version 1.0
@param oQry, Object, Objeto FwExecStatement (NIL na primeira chamada, reutilizado nas demais)
@param cFilDe, Char, Filial de (filtro inicial)
@param cFilAte, Char, Filial até (filtro final)
@param cCcDe, Char, Centro de custo de (filtro inicial)
@param cCcAte, Char, Centro de custo até (filtro final)
@param dIni, Date, Data inicial De
@param dIniAte, Date, Data inicial Até
@return cAliasReg, Char, Alias com os registros encontrados
/*/
Static Function fGetFunc(cFilDe, cFilAte, cCcDe, cCcAte, dIni, dIniAte)
	Local cQuery    := ""
	Local cAliasReg := GetNextAlias()

	Default cFilDe  := ""
	Default cFilAte := Replicate("Z", TamSX3("RA_FILIAL")[1])
	Default cCcDe   := ""
	Default cCcAte  := Replicate("Z", TamSX3("RA_CC")[1])
	Default dIni    := Date()
	Default dIniAte    := Date()

	If oQryFilt == Nil
		// Fallback com ' ' (espaço) para campos C pois Oracle trata '' (vazio) como NULL,
		cQuery := "SELECT SR8.R8_DATAINI, SR8.R8_DATAFIM, SRA.R_E_C_N_O_ RA_RECNO, SR8.R_E_C_N_O_ SR8_RECNO, "
		cQuery += "       COALESCE(RVQ.RVQ_NPROC,  ' ') RVQ_NPROC,  "
		cQuery += "       COALESCE(RVQ.RVQ_CARGHO, 0)   RVQ_CARGHO, "
		cQuery += "       COALESCE(RVQ.RVQ_PERCEN, 0)   RVQ_PERCEN, "
		cQuery += "       COALESCE(RVQ.RVQ_CODBAN, ' ') RVQ_CODBAN, "
		cQuery += "       COALESCE(RVQ.RVQ_TIPCTA, ' ') RVQ_TIPCTA, "
		cQuery += "       COALESCE(RVQ.RVQ_AGENCI, ' ') RVQ_AGENCI, "
		cQuery += "       COALESCE(RVQ.RVQ_DVAGEN, ' ') RVQ_DVAGEN, "
		cQuery += "       COALESCE(RVQ.RVQ_NUMCTA, ' ') RVQ_NUMCTA, "
		cQuery += "       COALESCE(RVQ.RVQ_DVCONT, ' ') RVQ_DVCONT "
		cQuery += "FROM "   + RetSqlName("SR8") + " SR8 "
		cQuery += "LEFT JOIN " + RetSqlName("SRA") + " SRA "
		cQuery +=     "ON SRA.RA_FILIAL = SR8.R8_FILIAL "
		cQuery +=    "AND SRA.RA_MAT    = SR8.R8_MAT "
		cQuery += "LEFT JOIN " + RetSqlName("RVQ") + " RVQ "
		cQuery +=     "ON RVQ.RVQ_FILIAL = SR8.R8_FILIAL "
		cQuery +=    "AND RVQ.RVQ_MAT    = SR8.R8_MAT "
		cQuery +=    "AND RVQ.RVQ_DATA   = SR8.R8_DATAINI "
		cQuery +=    "AND RVQ.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE SRA.RA_FILIAL BETWEEN ? AND ? "
		cQuery += "AND SRA.RA_CC       BETWEEN ? AND ? "
		cQuery += "AND SR8.R8_DATAINI  BETWEEN ? AND ? "
		cQuery += "AND SR8.R8_TPEFD    = ? "
		cQuery += "AND SR8.D_E_L_E_T_  = ? "
		cQuery += "AND SRA.D_E_L_E_T_  = ? "
		cQuery += "ORDER BY SRA.RA_FILIAL, SRA.RA_MAT"

		cQuery := ChangeQuery(cQuery)
		oQryFilt := FwExecStatement():New(cQuery)
	EndIf

	oQryFilt:SetString(1, cFilDe)   // RA_FILIAL >=
	oQryFilt:SetString(2, cFilAte)  // RA_FILIAL <=
	oQryFilt:SetString(3, cCcDe)    // RA_CC >=
	oQryFilt:SetString(4, cCcAte)   // RA_CC <=
	oQryFilt:SetDate(5, dIni)       // SR8.R8_DATAINI >=
	oQryFilt:SetDate(6, dIniAte)    // SR8.R8_DATAINI <=
	oQryFilt:SetString(7, "27")     // R8_TPEFD = Bolsa Qualificação
	oQryFilt:SetString(8, " ")      // SR8 não deletado
	oQryFilt:SetString(9, " ")      // SRA não deletado
	cAliasReg := oQryFilt:OpenAlias()

Return cAliasReg

/*/{Protheus.doc} fGrauInst
Converte o grau de instrução do Protheus (RA_GRINRAI) para o código Codefat.
@author martins.marcio
@since 09/03/2026
@version 1.0
@param cGrauProt, Char, Grau de instrução do Protheus (RA_GRINRAI)
@return cRet, Char, Código Codefat (01 a 12)
/*/
Static Function fGrauInst(cGrauProt)
	Local cRet := SPACE(2)

	Default cGrauProt :=  SPACE(2)

	// Mapeamento Protheus -> Codefat (manual Bolsa Qualificação)
	Do Case
		Case cGrauProt == "10" // Analfabeto (Protheus)
			cRet := "01" // Analfabeto (Codefat)
		Case cGrauProt == "20" // Até 4ª série incompleta (Protheus)
			cRet := "02" // 5º Ano incompleto do ensino fundamental (Codefat)
		Case cGrauProt == "25" // 4ª série completa do 1º grau (Protheus)
			cRet := "03" // 5º Ano do ensino fundamental (Codefat)
		Case cGrauProt == "30" // 1º grau (ginásio) incompleto (Protheus)
			cRet := "04" // Do 6º ao 9º ano do ensino fundamental incompleto (Codefat)
		Case cGrauProt == "35" // 1º grau (ginásio) completo (Protheus)
			cRet := "05" // Fundamental completo (Codefat)
		Case cGrauProt == "40" // 2º grau (colegial) incompleto (Protheus)
			cRet := "06" // Ensino médio incompleto (Codefat)
		Case cGrauProt == "45" // 2º grau (colegial) completo (Protheus)
			cRet := "07" // Ensino médio completo (Codefat)
		Case cGrauProt == "50" // Superior incompleto (Protheus)
			cRet := "08" // Superior incompleto (Codefat)
		Case cGrauProt == "55" // Superior completo (Protheus)
			cRet := "09" // Superior completo (Codefat)
		Case cGrauProt == "85" // Pós-graduação/Especialização (Protheus)
			cRet := "10" // Especialização (Codefat)
		Case cGrauProt == "65" // Mestrado completo (Protheus)
			cRet := "11" // Mestrado (Codefat)
		Case cGrauProt $ "75|95" // Doutorado completo / Pós-doutorado (Protheus) Obs.: no layout não há código específico para pós-doutorado;
			cRet := "12" // Doutorado (Codefat)
	EndCase

Return cRet

/*/{Protheus.doc} fSX5Tab26
Retorna as opções da tabela 26 da SX5 no formato aceito pelo MVC.
@author martins.marcio
@since 12/03/2026
@version 1.0
@return aRet, Array, Ex.: {"10=ANALFABETO","95=POS-DOUTORADO"}
/*/
Static Function fSX5Tab26()
	Local aRet     := {}
	Local aArea    := GetArea()
	Local aAreaSX5 := SX5->(GetArea())
	Local cSeek    := xFilial("SX5") + "26"
	Local cDescr   := ""

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))

	If SX5->(DbSeek(cSeek))
		While !SX5->(Eof()) .And. SX5->X5_FILIAL + SX5->X5_TABELA == cSeek
			cDescr := Upper(AllTrim(SX5->X5_DESCRI))
			AAdd(aRet, AllTrim(SX5->X5_CHAVE) + "=" + cDescr)
			SX5->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSX5)
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fUfValida
Valida e normaliza UF (sigla de estado).
Retorna vazio quando não for uma UF brasileira válida.
@author  martins.marcio
@since   10/03/2026
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fUfValida(cUF)
	Local cRet := ""
	Local cChv := ""

	Default cUF := ""

	cRet := Upper(AllTrim(cUF))
	If !Empty(cRet)
		// Valida UF na SX5 tabela 12 (UF)
		cChv := Posicione("SX5", 1, xFilial("SX5") + "12" + cRet, "X5_CHAVE")
		cRet := If(Empty(AllTrim(cChv)), "", cRet)
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} function fSoNumeros
Função que filtra apenas os números de uma string.
@author  martins.marcio
@since   07/11/2025
@version 12.1.2410
/*/
//-------------------------------------------------------------------
Static Function fSoNumeros(cTexto)
	Local cRet     := ""
	Local nY       := 0
	Local cCharY   := ""
	Local cDigitos := "0123456789"  // Conjunto de caracteres aceitos

	Default cTexto := ""

	If ValType(cTexto) == "C"
		For nY := 1 To Len(cTexto)
			cCharY := SubStr(cTexto, nY, 1)
			If cCharY $ cDigitos
				cRet += cCharY
			EndIf
		Next nY
	EndIf

Return cRet

/*/{Protheus.doc} fUlt3Sal
Busca os 3 últimos salários considerando a data de referência (início do afastamento).
Usa as competências imediatamente anteriores à data de referência.
@author martins.marcio
@since 10/03/2026
@version 1.0
@param dRef, Date, Data de referência (DET_DTAINI)
@param dAdmiss, Date, Data de admissão
@return aRet, Array, {Mes1, Val1, Mes2, Val2, Mes3, Val3}
/*/
Static Function fUlt3Sal(dRef, dAdmiss)
	Local aRet      := {"", 0, "", 0, "", 0}
	Local cVbBusca  := ""
	Local dDtUltSal := STOD("")
	Local dDtPenSal := STOD("")
	Local dDtAntSal := STOD("")
	Local nValUlt   := 0
	Local nValPen   := 0
	Local nValAnt   := 0

	Default dRef    := Date()
	Default dAdmiss := STOD("")

	// Verba padrão de salário (código folha 318)
	cVbBusca := IIf(FindFunction("FGETCODFOL"), FGETCODFOL("0318"), "")

	If !Empty(cVbBusca)
		// Competências de referência: mês anterior, penúltimo e antepenúltimo ao início do afastamento
		dDtUltSal := MonthSub(dRef, 1)
		dDtPenSal := MonthSub(dDtUltSal, 1)
		dDtAntSal := MonthSub(dDtPenSal, 1)

		// Não considera competências anteriores à admissão
		If !Empty(dAdmiss)
			dDtUltSal := IIf(MesAno(dDtUltSal) < MesAno(dAdmiss), STOD(""), dDtUltSal)
			dDtPenSal := IIf(MesAno(dDtPenSal) < MesAno(dAdmiss), STOD(""), dDtPenSal)
			dDtAntSal := IIf(MesAno(dDtAntSal) < MesAno(dAdmiss), STOD(""), dDtAntSal)
		EndIf

		If !Empty(dDtUltSal)
			nValUlt := fBuscaAcm(cVbBusca,,dDtUltSal,dDtUltSal,"V")
		EndIf

		If !Empty(dDtPenSal)
			nValPen := fBuscaAcm(cVbBusca,,dDtPenSal,dDtPenSal,"V")
		EndIf

		If !Empty(dDtAntSal)
			nValAnt := fBuscaAcm(cVbBusca,,dDtAntSal,dDtAntSal,"V")
		EndIf

		aRet[1] := IIf(Empty(dDtUltSal), "", StrZero(Month(dDtUltSal), 2))
		aRet[2] := nValUlt
		aRet[3] := IIf(Empty(dDtPenSal), "", StrZero(Month(dDtPenSal), 2))
		aRet[4] := nValPen
		aRet[5] := IIf(Empty(dDtAntSal), "", StrZero(Month(dDtAntSal), 2))
		aRet[6] := nValAnt
	EndIf

Return aRet

/*/{Protheus.doc} fVlGP949Ln
Linha OK da grid
@author isabel.noguti
@since 20/03/2026
@version 1.0
/*/
Static Function fVlGP949Ln(oGrid)
	Local lRet		:= .T.
	Local cTpC		:= ""
	Local cBco		:= ""
	Local cAgc		:= ""
	Local cCta		:= ""
	Local cDVc		:= ""
	Local ctpsNo	:= ""
	Local ctpsSe	:= ""
	Local ctpsUF	:= ""
	Local cMsg		:= ""
	Local cTitErr	:= STR0061	//"Dados da"

	If !IsInCallStack("Filtrar") .And. !oGrid:IsDeleted()
		ctpsNo := oGrid:GetValue("DET_CTPS")
		ctpsSe := oGrid:GetValue("DET_SERCP")
		ctpsUF := oGrid:GetValue("DET_UFCP")

		If !Empty(ctpsNo+ctpsSe+ctpsUF) .And. (Empty(ctpsNo) .Or. Empty(ctpsSe) .Or. Empty(ctpsUF))
			cTitErr += STR0062	//" CTPS"
			cMsg := STR0063 + CRLF + CRLF	//"Para os dados da CTPS, caso informado Número, Série ou UF, devem ser informados os demais campos. "
		EndIf

		cTpC := oGrid:GetValue("DET_TPCTA")
		cBco := oGrid:GetValue("DET_BCOD")
		cAgc := oGrid:GetValue("DET_AGENC")
		cCta := oGrid:GetValue("DET_NUMCTA")
		cDVc := oGrid:GetValue("DET_DVCTA")

		If !Empty(cTpC+cBco+cAgc+cCta+cDVc) .And. (Empty(cTpC) .Or. Empty(cBco) .Or. Empty(cAgc) .Or. Empty(cCta) .Or. Empty(cDVc))
			cTitErr += If(!Empty(cMsg), " e ", " ") + STR0064	//"conta bancária"
			cMsg += STR0065	//"Caso o trabalhador não possua conta, os campos de Banco, Agência, Tipo, Número e DV da Conta devem estar em branco."
		EndIf

		If !Empty(cMsg)
			lRet := .F.
			cTitErr += STR0066	//" incompletos"
			Help( , , OemtoAnsi(cTitErr), , OemtoAnsi(cMsg), 1, 0,,,,,, {STR0067 + cValtoChar(oGrid:GetLine())} )// "Dados ## incompletos. Verifique os dados da linha x"
		EndIf
	EndIf

Return lRet
