#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"



/*/{Protheus.doc} GFEA104
	
@author siegklenes.beulke
@since 15/01/2014
@version 1.0 

@description

Realiza a integração do financeiro dos lotes de provisão com o ERP

/*/

Function GFEA104()
	Private GFEResult := GFEViewProc():New()
	Private nCountErro := 0
	If Pergunte("GFEA104",.T.)
		Processa({|| IntegraTodos()},"Integrando...", "")
		GFEResult:Show("Integração", "Lotes de Provisão", "Informações", "Um ou mais Lotes de Provisão possuem alertas ou não foram integrados. Clique em 'Informações' para mais detalhes.")
	EndIf
Return

Static Function IntegraTodos()
	Local cMsg := ""
	Local lIntGFE := SuperGetMv("MV_INTGFE",.F.,.F.)
	Local cIntGFE2 := SuperGetMv("MV_INTGFE2",.F.,"2")
	Local cERPGFE := SuperGetMV("MV_ERPGFE",,"2")
	Local nContaLot := 0
	dbSelectArea("GXE")
	GXE->(dbSetOrder(1))
	
	GXE->(dbGoTop())
	If !GXE->(Eof())
		ProcRegua(GXE->(RecCount())+1)
	EndIf
	
	While !GXE->(Eof())
		If (GXE->GXE_FILIAL >= MV_PAR01 .Or. Empty(MV_PAR01));
			.And. (GXE->GXE_FILIAL <= MV_PAR02 .Or. Empty(MV_PAR02));
			.And. GXE->GXE_SIT $ If (MV_PAR08 == 1,"1;3", "4");
			.And. (GXE->GXE_PERIOD == MV_PAR03 .Or. Empty(StrTran(MV_PAR03,"/","")));
			.And. (GXE->GXE_CODLOT >= MV_PAR04 .Or. Empty(MV_PAR04));
			.And. (GXE->GXE_CODLOT <= MV_PAR05 .Or. Empty(MV_PAR05));
			.And. (GXE->GXE_CDEMIT >= MV_PAR06 .Or. Empty(MV_PAR06));
			.And. (GXE->GXE_CDEMIT <= MV_PAR07 .Or. Empty(MV_PAR07))
			IncProc("Filial "+ GXE->GXE_FILIAL +", lote " + AllTrim(GXE->GXE_CODLOT) + "")
			nContaLot++
			cMsg := ""
			If MV_PAR08 == 1
				cMsg := GFE096ILO("2")
			Else
				cMsg := GFE096ILO("5")
			EndIf
			If Empty(cMsg)
				If lIntGFE == .T. .And. cIntGFE2 $ "1S" .And. cERPGFE == "2"
					GFEResult:Add("Lote " + AllTrim(GXE->GXE_CODLOT) + " integrado com sucesso.")
				Else
					GFEResult:Add("Lote " + AllTrim(GXE->GXE_CODLOT) + " enviado ao ERP.")
				EndIf
			Else
				If nCountErro > 0
					GFEResult:AddErro(Replicate("-",50))
					GFEResult:AddErro("")
				EndIF
				GFEResult:AddErro("Falha ao integrar o Lote " + AllTrim(GXE->GXE_CODLOT) + ". Informações:")
				GFEResult:AddErro(cMsg)
				nCountErro++
			EndIf
		EndIf
		GXE->(dbSkip())
	EndDo
	If nContaLot == 0
		GFEResult:Add("Não foram localizados Lotes de Provisão dentro dos parâmetros informados")
	EndIf
Return