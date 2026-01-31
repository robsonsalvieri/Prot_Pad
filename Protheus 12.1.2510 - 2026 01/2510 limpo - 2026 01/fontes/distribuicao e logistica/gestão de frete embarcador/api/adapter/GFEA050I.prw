#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

Function GFE050QRY(cId, aParam)
	Local oResponse as object
	Local lRetDados := .f.
	Local lMsgErro 	:= ''
	Local aRet 		:= {}

	If !Empty(cId)
		cWhere := "%"
		cWhere += "AND GWN.GWN_FILIAL+GWN.GWN_NRROM = " + xFilial("GWN")+cId
		cWhere += "%"
	Else
		If Len(aParam) > 0 .AND. !Empty(aParam[1])
			cWhere := "%"

			cWhere += "AND GWN.GWN_SIT IN ('" + StrTran(aParam[1],'|',"','") + "')"
			cWhere += "%"
		Else
			cWhere := "% AND 1 = 1%"
		EndIf
	EndIf

	oResponse := JsonObject():New()
	cAliasQry := GetNextAlias()

	If Len(aParam) > 1
		BeginSql Alias cAliasQry
			SELECT *
			FROM %table:GWN% GWN
			WHERE GWN.%notDel%
			%Exp:cWhere%
			ORDER BY GWN.GWN_FILIAL, GWN.GWN_NRROM
			OFFSET %exp:aParam[2]% ROWS FETCH NEXT %exp:aParam[3]% ROWS ONLY
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT *
			FROM %table:GWN% GWN
			WHERE GWN.%notDel%
			%Exp:cWhere%
			ORDER BY GWN.GWN_FILIAL, GWN.GWN_NRROM
		EndSql
	EndIf

	oResponse["hasNext"] := .t.
	oResponse["items"]   := {}

	If (cAliasQry)->(!Eof())
		While (cAliasQry)->(!Eof())

			oRomaneio := JsonObject():New()

			oRomaneio["BranchId"]       		 := (cAliasQry)->GWN_FILIAL
			oRomaneio["ManifestNumber"]			 := (cAliasQry)->GWN_NRROM
			oRomaneio["OperType"]       		 := (cAliasQry)->GWN_CDTPOP
			oRomaneio["FreightClas"]       		 := (cAliasQry)->GWN_CDCLFR
			oRomaneio["Carrier"]       			 := (cAliasQry)->GWN_CDTRP
			oRomaneio["Driver"]       			 := (cAliasQry)->GWN_CDMTR
			oRomaneio["Driver2"]       			 := (cAliasQry)->GWN_CDMTR2
			oRomaneio["VehicleType"]       		 := (cAliasQry)->GWN_CDTPVC
			oRomaneio["FrontLicencePlate"]       := (cAliasQry)->GWN_PLACAD
			oRomaneio["RearLicencePlate"]        := (cAliasQry)->GWN_PLACAT
			oRomaneio["IntermediateLicPlate"]    := (cAliasQry)->GWN_PLACAM
			oRomaneio["Situation"]       		 := (cAliasQry)->GWN_SIT
			oRomaneio["ManifestCreationDate"]    := (cAliasQry)->GWN_DTIMPL
			oRomaneio["CreationHour"]       	 := (cAliasQry)->GWN_HRIMPL
			oRomaneio["CalculationStatus"]       := (cAliasQry)->GWN_CALC
			oRomaneio["CalculationDate"]         := (cAliasQry)->GWN_DTCALC
			oRomaneio["CalculationHour"]         := (cAliasQry)->GWN_HRCALC
			oRomaneio["User"]      				 := (cAliasQry)->GWN_USUIMP
			oRomaneio["Source"]       			 := (cAliasQry)->GWN_ORI
			oRomaneio["OutflowInflowDt"]         := (cAliasQry)->GWN_DTSAI
			oRomaneio["OutflowInflowHr"]         := (cAliasQry)->GWN_HRSAI
			oRomaneio["Route"]      			 := (cAliasQry)->GWN_DISTAN
			oRomaneio["DestinyCity"]       	     := (cAliasQry)->GWN_NRCIDD
			oRomaneio["DestinPostalCode"]        := (cAliasQry)->GWN_CEPD
			oRomaneio["ReturnDate"]     		 := (cAliasQry)->GWN_DTRET
			oRomaneio["ReturnTime"]     		 := (cAliasQry)->GWN_HRRET
			oRomaneio["DepartureOdometerReadin"] := (cAliasQry)->GWN_HODSAI
			oRomaneio["ReturnOdometerReading"]   := (cAliasQry)->GWN_HODRET
			oRomaneio["TracingCode"]       		 := (cAliasQry)->GWN_RASTR
			oRomaneio["TollVoucher"]       		 := (cAliasQry)->GWN_VALEP
			oRomaneio["TollAmount"]       		 := (cAliasQry)->GWN_VPVAL
			oRomaneio["SerialNumber"]      		 := (cAliasQry)->GWN_LACRE
			oRomaneio["TripNumber"]       		 := (cAliasQry)->GWN_VIAGEM

			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT *
				FROM %table:GW1% GW1
				WHERE GW1.%notDel%
				AND GW1.GW1_FILIAL = %Exp:(cAliasQry)->GWN_FILIAL%
				AND GW1.GW1_NRROM  = %Exp:(cAliasQry)->GWN_NRROM%
				ORDER BY GW1.GW1_NRDC
			EndSql
			If (cAliasGW1)->(!Eof())
				oRomaneio["CargoDocuments"] := {}
				While (cAliasGW1)->(!Eof())
					oCargoDoc := JsonObject():New()
					oCargoDoc["DocType"]    := (cAliasGW1)->GW1_CDTPDC
					oCargoDoc["IssuerCode"] := (cAliasGW1)->GW1_EMISDC
					oCargoDoc["IssueDate"]  := (cAliasGW1)->GW1_DTEMIS
					oCargoDoc["Series"]     := (cAliasGW1)->GW1_SERDC
					oCargoDoc["Number"]     := (cAliasGW1)->GW1_NRDC
					oCargoDoc["ElectronicValidationKey"] := (cAliasGW1)->GW1_DANFE

					Aadd(oRomaneio['CargoDocuments'], oCargoDoc)

					(cAliasGW1)->(dbSkip())
				End
			EndIf
			(cAliasGW1)->(dbCloseArea())

			AADD(oResponse["items"], oRomaneio)

			lRetDados := .t.

			(cAliasQry)->(dbSkip())
		End
	Else
		lMsgErro := "Nao fo(ram) encontrado(s) romaneio(s)."
	EndIf

	(cAliasQry)->(DbCloseArea())

	If lRetDados
		aRet := {lRetDados,,oResponse:ToJson()}
	Else
		aRet := {lRetDados, 404, lMsgErro}
	EndIf

Return aRet

Function GFE050IGRV(lAlteracao,oContent,aNames)
	Local oModelGWN	 := Nil
	Local nIndLines  := 0
	Local nX		 := 0
	Local nI		 := 0
	Local aGWN 		 := {}
	Local aGW1 		 := {}
	Local aDocsCarg  := {}
	Local nCont 	 := 0
	Local lRet 		 := .T.
	Local cFilGWN 	 := ''
	Local nLenCDTPDC := TamSx3("GW1_CDTPDC")[1]
	Local nLenEMISDC := TamSx3("GW1_EMISDC")[1]
	Local nLenSERSDC := TamSx3("GW1_SERDC")[1]
	Local nLenNRSDC  := TamSx3("GW1_NRDC")[1]
	Local aRet 		 := {.T.,,}
	
	Private aDocFil := {} // Documentos de carga Filtrados
	Private aDocSel := {} // Documentos de Carga Selecionados

	AADD(aGWN,{"ManifestNumber","GWN_NRROM"})
	AADD(aGWN,{"OperType","GWN_CDTPOP"})
	AADD(aGWN,{"FreightClas","GWN_CDCLFR"})
	AADD(aGWN,{"Carrier","GWN_CDTRP"})
	AADD(aGWN,{"Driver","GWN_CDMTR"})
	AADD(aGWN,{"Driver2","GWN_CDMTR2"})
	AADD(aGWN,{"VehicleType","GWN_CDTPVC"})
	AADD(aGWN,{"FrontLicencePlate","GWN_PLACAD"})
	AADD(aGWN,{"RearLicencePlate","GWN_PLACAT"})
	AADD(aGWN,{"IntermediateLicPlate","GWN_PLACAM"})
	AADD(aGWN,{"Situation","GWN_SIT"})
	AADD(aGWN,{"ManifestCreationDate","GWN_DTIMPL"})
	AADD(aGWN,{"CreationHour","GWN_HRIMPL"})
	AADD(aGWN,{"CalculationStatus","GWN_CALC"})
	AADD(aGWN,{"CalculationDate","GWN_DTCALC"})
	AADD(aGWN,{"CalculationHour","GWN_HRCALC"})
	AADD(aGWN,{"User","GWN_USUIMP"})
	AADD(aGWN,{"Source","GWN_ORI"})
	AADD(aGWN,{"OutflowInflowDt","GWN_DTSAI"})
	AADD(aGWN,{"OutflowInflowHr","GWN_HRSAI"})
	AADD(aGWN,{"Route","GWN_DISTAN"})
	AADD(aGWN,{"DestinyCity","GWN_NRCIDD"})
	AADD(aGWN,{"DestinPostalCode","GWN_CEPD"})
	AADD(aGWN,{"Notes","GWN_OBS"})
	AADD(aGWN,{"ReturnDate","GWN_DTRET"})
	AADD(aGWN,{"ReturnTime","GWN_HRRET"})
	AADD(aGWN,{"DepartureOdometerReadin","GWN_HODSAI"})
	AADD(aGWN,{"ReturnOdometerReading","GWN_HODRET"})
	AADD(aGWN,{"TracingCode","GWN_RASTR"})
	AADD(aGWN,{"TollVoucher","GWN_VALEP"})
	AADD(aGWN,{"TollAmount","GWN_VPVAL"})
	AADD(aGWN,{"SerialNumber","GWN_LACRE"})
	AADD(aGWN,{"TripNumber","GWN_VIAGEM"})

	AADD(aGW1,{"ManifestNumber","GW1_NRROM"})
	AADD(aGW1,{"DocType","GW1_CDTPDC"})
	AADD(aGW1,{"IssuerCode","GW1_EMISDC"})
	AADD(aGW1,{"IssueDate","GW1_DTEMIS"})
	AADD(aGW1,{"InvoiceSerie","GW1_SERDC"})
	AADD(aGW1,{"Number","GW1_NRDC"})
	AADD(aGW1,{"Series","GW1_SERDC"})
	AADD(aGW1,{"ElectronicValidationKey","GW1_DANFE"})

	oModelGWN := FWLoadModel("GFEA050")

	If lAlteracao
		nScan2 := aScan(aNames,{|x| Upper(x) == Upper('ManifestNumber')})

		GWN->(dbSetOrder(1))
		If nScan2 > 0 .And. GWN->(dbSeek(xFilial("GWN") + oContent[aNames[nScan2]]))
			aRet := {.T.,200,"Romaneio " + GWN->GWN_NRROM + " alterado com sucesso."}
			oModelGWN:SetOperation( 4 )
		Else
			aRet := {.F., 404, "Romaneio informado para alteração nao existe no banco de dados!" }
		EndIf
	Else
		oModelGWN:SetOperation( 3 )
	EndIf

	If aRet[1]
		oModelGWN:Activate()

		If oModelGWN:IsActive()
			aDocsCarg := Array(Len(oContent["CargoDocuments"]),1000,2)

        	For nIndLines := 1 To Len(aNames)
				If !lAlteracao .AND. aNames[nIndLines] == "CargoDocuments" .And. !Empty(oContent["CargoDocuments"])
					oModelGWN:SetValue( 'GFEA050_GWN', "GWN_SIT", '2')
				
					For nI := 1 to Len(oContent["CargoDocuments"])
						aNamesDocs := oContent["CargoDocuments"][nI]:getNames()

						For nX := 1 to Len(aNamesDocs)
							nScan := aScan(aGW1,{|x|Upper(x[1]) == Upper(aNamesDocs[nX])})
							
							If nScan > 0
								nCont++
							
								If aGW1[nScan][2] == "GW1_DTEMIS"
									dData := STOD(StrTran(oContent["CargoDocuments"][nI][aNamesDocs[nX]],'-',''))
									aDocsCarg[nI][nCont][1] := aGW1[nScan][2]
									aDocsCarg[nI][nCont][2] := dData
								Else
									aDocsCarg[nI][nCont][1] := aGW1[nScan][2]
									aDocsCarg[nI][nCont][2] := oContent["CargoDocuments"][nI][aNamesDocs[nX]]
								EndIf
							EndIf
				  		Next
					Next
				Else
					nScan 	:= aScan(aGWN,{|x| Upper(x[1]) == Upper(aNames[nIndLines])})
					cFilGWN := xFilial("GWN")

					If nScan > 0
						If aGWN[nScan][2] == "GWN_DTIMPL" .OR. aGWN[nScan][2] == "GWN_DTCALC" .OR.;
					   	   aGWN[nScan][2] == "GWN_DTSAI"  .OR. aGWN[nScan][2] == "GWN_DTRET"
							
							dData := STOD(StrTran(oContent[aNames[nIndLines]],'-',''))
							lRet := oModelGWN:SetValue( 'GFEA050_GWN', aGWN[nScan][2], dData)
						ElseIf !lAlteracao .AND. aGWN[nScan][2] == 'GWN_ORI'
							lRet := oModelGWN:SetValue( 'GFEA050_GWN', "GWN_ORI", '3')
						ElseIf !lAlteracao .AND. aGWN[nScan][2] == 'GWN_SIT'
							lRet := oModelGWN:SetValue( 'GFEA050_GWN', "GWN_SIT", '1')
						Else
							lRet := oModelGWN:SetValue( 'GFEA050_GWN', aGWN[nScan][2], oContent[aNames[nIndLines]])
						EndIf

						If !lRet
							aRet := {.F., 401, aGWN[nScan][1] + " - " + oModelGWN:GetErrorMessage()[6] }
						EndIf
					EndIf
				EndIf
        	Next nIndLines

			If aRet[1]
				If oModelGWN:VldData()
					If oModelGWN:CommitData()
						If !lAlteracao .AND. Len(aDocsCarg) > 0
							aRet := {.T.,200,"Romaneio " + GWN->GWN_NRROM + " incluído com sucesso."}

							For nX := 1 to Len(aDocsCarg)
								cGW1DANFE  := aScan(aDocsCarg[nX],{|x|x[1] == "GW1_DANFE"})
								cGW1CDTPDC := aScan(aDocsCarg[nX],{|x|x[1] == "GW1_CDTPDC"})
								cGW1EMISDC := aScan(aDocsCarg[nX],{|x|x[1] == "GW1_EMISDC"})
								cGW1SERDC  := aScan(aDocsCarg[nX],{|x|x[1] == "GW1_SERDC"})
								cGW1NRDC   := aScan(aDocsCarg[nX],{|x|x[1] == "GW1_NRDC"})

								If !Empty(cGW1DANFE)
									cChave := aDocsCarg[nX][cGW1DANFE][2]
								
									GW1->(dbSetOrder(12)) //Danfe + Filial
									If !Empty(cChave) .And. !(GW1->(dbSeek(cChave)))
										cChave := cFilGWN
										cChave += GW1->GW1_CDTPDC
										cChave += GW1->GW1_EMISDC
										cChave += GW1->GW1_SERDC
										cChave += GW1->GW1_NRDC

										GW1->(dbSetOrder(1))
									EndIf
								ElseIf !Empty(cGW1CDTPDC) .AND. !Empty(cGW1EMISDC) .AND. !Empty(cGW1SERDC) .AND. !Empty(cGW1NRDC)
									cChave := cFilGWN
									cChave += aDocsCarg[nX][cGW1CDTPDC][2]+Space(nLenCDTPDC-Len(aDocsCarg[nX][cGW1CDTPDC][2]))
									cChave += aDocsCarg[nX][cGW1EMISDC][2]+Space(nLenEMISDC-Len(aDocsCarg[nX][cGW1EMISDC][2]))
									cChave += aDocsCarg[nX][cGW1SERDC][2] +Space(nLenSERSDC-Len(aDocsCarg[nX][cGW1SERDC][2]))
									cChave += aDocsCarg[nX][cGW1NRDC][2]  +Space(nLenNRSDC -Len(aDocsCarg[nX][cGW1NRDC][2]))

									GW1->(dbSetOrder(1))
								Else
									cChave := ''
								EndIf
							
								If !Empty(cChave)
									If GW1->(dbSeek(cChave))
										AADD(aDocFil,{.T.,;
													  GW1->GW1_FILIAL,;
													  GW1->GW1_SERDC,;
													  GW1->GW1_NRDC,;
													  GW1->GW1_CDTPDC,;
													  GW1->GW1_TPFRET,;
													  GW1->GW1_EMISDC,;
													  '',; //(cGW1)->NMEMIS
													  GW1->GW1_CDREM,;
													  '',; //(cGW1)->NMREM
													  GW1->GW1_CDDEST,;
													  '',; //(cGW1)->NMDEST
													  GW1->GW1_NRREG,;
													  '',; //GW1->GW1_NRCID,;
													  GW1->GW1_DTEMIS,;
													  GW1->GW1_DTSAI,;
													  '',; //GW1->GW1_CIDDES,;
													  '',; //GW1->GW1_UFDEST,;
													  GW1->GW1_QTVOL })
									
										lRet := GFEA50AOK(.T.)
									Else
										aRet := {.F., 404, "Nao foi encontrado o documento de carga na base de dados." }
									EndIf
								EndIf
							Next nX
						EndIf
					EndIf
				Else
					// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
					aErro := oModelGWN:GetErrorMessage()

					aRet := {.F., 400, aErro[6]}
				EndIf
			EndIf

			oModelGWN:Deactivate()
			oModelGWN:Destroy()
		EndIf
	EndIf

Return aRet
