#INCLUDE "PROTHEUS.CH" 

//-----------------------------------------------------
/*/	Altera Informações de frete do romaneio e nota fiscal do SIGAGFE
@author João Leonardo Schmidt
@version 12.1.20
@since 27/02/2018
/*/
//------------------------------------------------------
Function AtuInfoFrt(nRecSF2,aCampos)
	Local lRet       := .T.
	Local lNumProp   := SuperGetMv("MV_EMITMP",.F.,'1') == "1" .And. SuperGetMv("MV_INTGFE2",.F.,"2") == "1"
	Local lIntGFE    := SuperGetMv("MV_INTGFE",,.F.)
	Local oModel     := Nil
	Local cCdtERP    := aCampos[1][3]
	Local cCdVeic    := aCampos[2][4]
	Local cAliasQry  := Nil
	Local cAliasGW1  := Nil
	Local cAliasGU3  := Nil
	Local cCdTpDc    := ""
	Local cEmisDc    := ""
	Local cDoc       := ""
	Local cSerie     := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cTipo      := ""
	Local cMessage   := ""
	Local nI         := 0
	Local nF         := 0
	Local cFilRom    := ""
	Local cAuxCpo    := " "

	If lIntGFE
		If !Empty(cCdtERP)
			If lNumProp 
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT GU3.GU3_CDEMIT
					FROM %Table:GU3% GU3
					WHERE GU3.GU3_FILIAL = %xFilial:GU3%
					AND GU3.GU3_CDTERP = %Exp:cCdtERP%
					AND GU3.%NotDel%
				EndSql
				cTransp := (cAliasQry)->GU3_CDEMIT
				(cAliasQry)->(dbCloseArea())
				aCampos[1][3] := cTransp
			Else
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT SA4.A4_CGC
					FROM %Table:SA4% SA4
					WHERE SA4.A4_FILIAL = %xFilial:SA4%
					AND SA4.A4_COD = %Exp:cCdtERP%
					AND SA4.%NotDel%
				EndSql
				cTransp := (cAliasQry)->A4_CGC
				(cAliasQry)->(dbCloseArea())
				aCampos[1][3] := cTransp

				If !Empty(cTransp)
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT 1
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_IDFED = %Exp:cTransp%
						AND GU3.GU3_TRANSP = '1'
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(Eof())
						cTransp := ""
					EndIf
					(cAliasGU3)->(dbCloseArea())
				EndIf
			EndIf

			If Empty(cTransp)
				lRet     := .F.
				cMessage := "Transportador não está integrado com o Gestão de Frete Embarcador. Você deve realizar a integração antes de continuar a alteração."
			EndIf
		EndIf
		If lRet
			If !Empty(cCdVeic)
				lChancge := .T.
				cAliasQry := GetNextAlias()
				BeginSql Alias cAliasQry
					SELECT 1
					FROM %Table:GU8% GU8
					WHERE GU8.GU8_FILIAL = %xFilial:GU8%
					AND GU8.GU8_CDVEIC = %Exp:cCdVeic%
					AND GU8.%NotDel%
				EndSql
				If (cAliasQry)->(Eof())
					lRet     := .F.
					cMessage := "Veículo não está integrado com o Gestão de Frete Embarcador. Você deve realizar a integração antes de continuar a alteração."
				EndIf
				(cAliasQry)->(dbCloseArea())
			EndIf
		EndIf
		If lRet
			SF2->(dbGoTo(nRecSF2))
			
			cDoc     := AllTrim(SF2->F2_DOC) + Space( TamSx3("GW1_CDTPDC")[1] -( Len( AllTrim(SF2->F2_DOC))))
			cSerie   := AllTrim(SF2->F2_SERIE) + Space( TamSx3("GW1_SERDC")[1] -(Len( AllTrim(SF2->F2_SERIE))))
			cCliente := AllTrim(SF2->F2_CLIENTE) + Space( TamSx3("F2_CLIENTE")[1] - (Len( AllTrim(SF2->F2_CLIENTE))))
			cLoja    := AllTrim(SF2->F2_LOJA) + Space( TamSx3("F2_LOJA")[1] - (Len( AllTrim(SF2->F2_LOJA))))
			cTipo    := AllTrim(SF2->F2_TIPO) + Space( TamSx3("F2_TIPO")[1] - (Len( AllTrim(SF2->F2_TIPO))))

			cCdTpDc := Posicione("SX5",1,xFilial("SX5")+"MQ"+AllTrim(cTipo)+"S","X5_DESCRI")
			
			If Empty(cCdTpDc)
				cCdTpDc := Posicione("SX5",1,xFilial("SX5")+"MQ"+AllTrim(cTipo),"X5_DESCRI")
			EndIf
			
			cCdTpDc := PadR(cCdTpDc,TamSx3("GW1_CDTPDC")[1])
			cEmisDc := GFEM011COD(,,,.T.,xFilial("SF2"))
			
			If GFXCP1212210('GW1_FILROM')
				cAuxCpo := ", GW1.GW1_FILROM"
			EndIf
			cAuxCpo := "%"+cAuxCpo+"%"

			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1.GW1_FILIAL
					 , GW1.GW1_NRROM
					 , GW1.GW1_CDTPDC
					 , GW1.GW1_EMISDC
					 , GW1.GW1_SERDC
					 , GW1.GW1_NRDC
					 %Exp:cAuxCpo%
				FROM %Table:GW1% GW1
				WHERE GW1.GW1_FILIAL = %xFilial:GW1%
				AND GW1.GW1_CDTPDC = %Exp:cCdTpDc%
				AND GW1.GW1_EMISDC = %Exp:cEmisDc%
				AND GW1.GW1_SERDC = %Exp:cSerie%
				AND GW1.GW1_NRDC = %Exp:cDoc%
				AND GW1.%NotDel%
			EndSql
			If (cAliasGW1)->(!Eof())
				If !Empty((cAliasGW1)->GW1_NRROM)
					
					If GFXCP1212210('GW1_FILROM') .And. !Empty((cAliasGW1)->GW1_FILROM)
						cFilRom := (cAliasGW1)->GW1_FILROM
					Else
						cFilRom := (cAliasGW1)->GW1_FILIAL
					EndIf

					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT GWN.R_E_C_N_O_ RECNOGWN
						FROM %Table:GWN% GWN
						WHERE GWN.GWN_FILIAL = %Exp:cFilRom%
						AND GWN.GWN_NRROM = %Exp:(cAliasGW1)->GW1_NRROM%
						AND GWN.%NotDel%
					EndSql
					If (cAliasQry)->(!Eof())
						GWN->(dbGoTo((cAliasQry)->RECNOGWN))
						
						oModel := FWLoadModel("GFEA050")
						oModel:SetOperation( 4 )
						If oModel:Activate()
							nF := Len(aCampos)
							For nI := 1 To nF
								If aCampos[nI][1] == 1
									oModel:LoadValue('GFEA050_GWN', aCampos[nI][2], aCampos[nI][3] )
								Else
									If oModel:SetValue('GFEA050_GWN', aCampos[nI][2], aCampos[nI][3] ) == .F.
										lRet     := .F.
										cMessage := oModel:GetErrorMessage()[6]
										Exit
									EndIf
								EndIf
							Next nI

							If lRet
								If oModel:VldData() .And. oModel:GetModel("GFEA050_GWN"):VldData()
									oModel:CommitData()
								Else
									lRet     := .F.
									cMessage := oModel:GetErrorMessage()[6]
								EndIf
								oModel:Deactivate()
							EndIf
						Else
							lRet     := .F.
							cMessage := oModel:GetErrorMessage()[6]
						EndIf
					EndIf
					(cAliasQry)->(dbCloseArea())
				Else
					cAliasQry := GetNextAlias()
					BeginSql Alias cAliasQry
						SELECT GWU.R_E_C_N_O_ RECNOGWU
						FROM %Table:GWU% GWU
						WHERE GWU.GWU_FILIAL = %Exp:(cAliasGW1)->GW1_FILIAL%
						AND GWU.GWU_CDTPDC = %Exp:(cAliasGW1)->GW1_CDTPDC%
						AND GWU.GWU_EMISDC = %Exp:(cAliasGW1)->GW1_EMISDC%
						AND GWU.GWU_SERDC = %Exp:(cAliasGW1)->GW1_SERDC%
						AND GWU.GWU_NRDC = %Exp:(cAliasGW1)->GW1_NRDC%
						AND GWU.GWU_SEQ = '01'
						AND GWU.%NotDel%
					EndSql
					If (cAliasQry)->(!Eof())
						GWU->(dbGoTo((cAliasQry)->RECNOGWU))
						RecLock("GWU",.F.)
							GWU->GWU_CDTRP  := aCampos[1][3]
							GWU->GWU_CDTPVC := aCampos[2][3]
						GWU->(MsUnlock())
					EndIf
					(cAliasQry)->(dbCloseArea())
				EndIf
			EndIf
		EndIf
	EndIf
Return {lRet,cMessage}
//-----------------------------------------------------
/*/	Geração código de emitente GFE
@author Leonardo Ribas Jimenez Hernandez
@version 12.1.21
@since 05/06/2018
/*/
//------------------------------------------------------
Function GFECodEmit(cCodEmit, cCodEst, cCGC, cIdTrans)
Local cCod := ""
	
	If (cCodEst == "EX" .Or. Empty(cCodEst)) .And. Empty(cCGC)
		If !Empty(cIdTrans)
			cCod := cIdTrans
		Else
			cCod := cCodEmit
		EndIf 
	Else
		cCod := cCGC
	EndIf
Return AllTrim(cCod)
