#include "TOTVS.ch"      
#include "TOPCONN.CH"
#include "LOCA248.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

/*/{PROTHEUS.DOC} LOCA248C6X
ITUP BUSINESS - TOTVS RENTAL
Armazena o conteúdo anterior da FQL_DTENT e FQL_DTSAID
Frank Z Fuga
03/10/2024
/*/

Function LOCA248C6X(cCampo)
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local lRet := .T.

	xConteud := oModelFQL:GetValue(cCampo)

Return lRet


/*/{PROTHEUS.DOC} LOCA248C6
ITUP BUSINESS - TOTVS RENTAL
Retorna se pode alterar o campo quando o carro for reserva
Frank Z Fuga
16/09/2024
/*/

Function LOCA248C6(cCampo)
//Local oModel := FWModelActive()
//Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local lRet := .T.

	// xConteud foi criada no LOCA248 como private e é alimentada no LOCA248C6X
	/*
	If !empty(oModelFQL:GetValue("FQL_BEMRES"))
		If xConteud <> oModelFQL:GetValue(cCampo) 
			lRet := .F.
		EndIf
	EndIf
	If !lRet
		Help( ,, "LOCA248-LOCA248C6",, STR0002, 1, 0,,,,,,{STR0091}) //"Inconsistência nos dados."###"O movimento de bem reserva não faculta a alteração das datas de expedição e devolução."
	EndIf
	*/

Return lRet

/*/{PROTHEUS.DOC} LOCA248C5
ITUP BUSINESS - TOTVS RENTAL
Atualizar a grid
Frank Z Fuga
03/09/2024
/*/

Function LOCA248C5
	Processa({||LOCA248C5X()},STR0086) // "Aguarde... Atualizando os dados"
Return

/*/{PROTHEUS.DOC} LOCA248C5X
ITUP BUSINESS - TOTVS RENTAL
Atualizar a grid
Frank Z Fuga
03/09/2024
/*/

Function LOCA248C5X
Local lRet := .T.
Local dIni := M->FQK_DTINIC
Local dFim := M->FQK_DTFIM
Local oView := FWViewActive() 
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nI
Local aOld := {}
Local aTemp := {}
Local nX
Local cCampo
Local cAs
Local cBemRes
Local nPosAs
Local nPosBem
Local cTpAs
Local nPosTpAs
Local cMinuta
Local nPosMinu
Local cOs
Local nPosOs
Local cFrota
Local nPosFrota
local nY

	If (!lInclui .and. !lAltera) 
		lRet := .F.
	EndIf

	If lAltera .and. lRet
		If !empty(FQK->FQK_NUMPV)
			Help( ,, "LOCA248B-LOCA248C5",, STR0002, 1, 0,,,,,,{STR0120}) //"Inconsistência nos dados."###"Opção não disponível quando já foi gerado o pedido de vendas."
			lRet := .F.
		EndIf
	EndIf

	If FQK->FQK_SITUAC <> "1" .and. FQK->FQK_SITUAC <> " "  .and. lRet
		Help( ,, "LOCA248B-LOCA248C5",, STR0002, 1, 0,,,,,,{STR0122}) //"Inconsistência nos dados."###"A situação da medição precisa estar em digitação."
		lRet := .F.
	EndIF

	If lRet
		lRet := MsgYesNo(STR0121,STR0038)  // "Confirma a atualização dos dados?"###"Atenção!"
	EndIF

	If !empty(dIni) .and. !empty(dFim) .and. lRet

		ProcRegua(0)

		For nI := 1 to oModelFQL:Length()
			IncProc()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()
				aTemp := {}
				For nX := 1 to len(omodelfql:aheader)
					cCampo := omodelfql:aheader[nX,2]
					aadd(aTemp,{cCampo, oModelFQL:GetValue(cCampo)})
				Next
				Aadd(aOld,Aclone(aTemp))
			EndIF
		Next

		If lInclui
			oModelFQL:ClearData()
		EndIF
		If lAltera
			For nI := 1 to oModelFQL:Length()
				IncProc()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted()
					oModelFQL:DeleteLine()
				EndIF
			Next
		EndIF

		LOCA248H()
		IncProc()
		LOCA248B8("FQK_DTFIM","FQK_DTFIM")
		IncProc()
		LOCA248BA()
		IncProc()
		LOCA248BE()
		IncProc()

		// Recuperar as digitações anteriores
		For nX := 1 to len(omodelfql:aheader)
			IncProc()
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_AS"
				nPosAs := nX
			EndIf
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_BEMRES"
				nPosBem := nX
			EndIf
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_TPAS"
				nPosTpAs := nX
			EndIf
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_MINUTA"
				nPosMinu := nX
			EndIf
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_OS"
				nPosOS := nX
			EndIf
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_FROTA"
				nPosFrota := nX
			EndIf
		Next
		For nY := 1 to len(aold)
			IncProc()
			cAs := aOld[nY,nPosAs,2]
			cBemRes := aOld[nY,nPosBem,2]
			cTpAs := aOld[nY,nPosTpAs,2]
			cMinuta:= aOld[nY,nPosMinu,2]
			cOs:= aOld[nY,nPosOs,2]
			cFrota:= aOld[nY,nPosFrota,2]

			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted()
					If cAs == oModelFQL:GetValue("FQL_AS") .and. cBemRes == oModelFQL:GetValue("FQL_BEMRES")
						If cTpAs == oModelFQL:GetValue("FQL_TPAS") .and. cMinuta == oModelFQL:GetValue("FQL_MINUTA")
							If cOs == oModelFQL:GetValue("FQL_OS") .and. cFrota == oModelFQL:GetValue("FQL_FROTA")
								For nX := 1 to len(aOld[nY])
									cCampo := alltrim(aOld[nY,nX,1])
									If cCampo <> "FQL_FILIAL" .and. cCampo <> "FQL_VALHOR"
										LOCA248LIB()
										oModelFQL:SetValue(cCampo,aOld[nY,nX,2])
									EndIF
								Next
								Exit
							EndIF
						EndIF
					EndIf
				EndIF
			Next
			LOCA248BLQ()

		Next

		// Calcular os totais
		CALCMIN()
		LOCA248A6("FQL_QTDHR")

		oModelFQL:GoLine(1)
		oView:Refresh()
		IncProc()
		
	EndIF

Return lRet

/*/{PROTHEUS.DOC} LOCA248C4
ITUP BUSINESS - TOTVS RENTAL
Valida se o movimento pode gerar a grid
Frank Z Fuga
03/09/2024
/*/

Function LOCA248C4
Local lRet := .F.
Local lNota := .F.
Local dIni := M->FQK_DTINIC
Local dFim := M->FQK_DTFIM
Local cTipoSai := GetMV("MV_LOCX311",,"DT.INICIO")
//Local cAs
//Local cProjeto
//Local cGrupoMed
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
	
	If cTipoSai <> "DT.INICIO"
		lNota := .T.
	EndIf

	If FPA->FPA_TIPOSE == "M"
		lRet := .T.
	Else
		If lNota
			If empty(dIni) .or. empty(dFim)
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			lRet := .T.
		EndIf
	EndIf
		
	RestArea(aAreaFQK)
	RestArea(aAreaFQL)

Return lRet

/*/{PROTHEUS.DOC} LOCA248C3
ITUP BUSINESS - TOTVS RENTAL
Validação do campo FQK_DTINI
Frank Z Fuga
02/09/2024
/*/

Function LOCA248C3 
Local lRet := .T.
Local dData := FWFldGet("FQK_DTINIC") //M->FQK_DTINIC

	If M->FQK_MEDSEQ > "001" .and. dData <> dControl
		Help( ,, "LOCA248-LOCA248C3",, STR0002, 1, 0,,,,,,{STR0113}) //"Inconsistência nos dados."###"A data inicial não pode ser modificada."
		Return .F.
	EndIf

	If !empty(FWFldGet("FQK_PMEDI")) .and. !empty(dData)

		FQJ->(dbSetOrder(1))
		FQJ->(dbSeek(xFilial("FQJ")+M->FQK_PMEDI))

		If day(dData) <> val(FQJ->FQJ_PERDE)  
			Help( ,, "LOCA248-LOCA248C3",, STR0002, 1, 0,,,,,,{STR0081}) //"Inconsistência nos dados."###"O dia inicial não confere com o período da medição selecionado."
			lRet := .F.
		EndIF

	EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA248BA
ITUP BUSINESS - TOTVS RENTAL
Calculo da franquia, além de chamada interna
Frank Z Fuga
23/08/2024
/*/
Function LOCA248BA
Local nFranquia := 0
Local xRet
Local cCampo := alltrim(upper(ReadVar()))
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local dIni
Local dFim
Local nFator
Local nFrkm
Local aCalc
Local nMeses
Local ndias
Local dDatas // data saida
Local dDatae // data entrada
Local nX
Local nPosCol

	// Calculo da franquia
	nFranquia := 0

	dDatas := ctod("")
	If readvar() == "M->FQL_DTSAID"
		For nX := 1 to len(omodelfql:aheader)
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_DTSAID"
				nPosCol := nX
				Exit
			EndIf
		Next

		dDatas := omodelfql:ADATAMODEL[oModelFQL:GetLine()][1][1][nPosCol]
	EndIf
	dDatae := ctod("")
	If readvar() == "M->FQL_DTENT"
		For nX := 1 to len(omodelfql:aheader)
			If alltrim(omodelfql:aheader[nX,2]) == "FQL_DTENT"
				nPosCol := nX
				Exit
			EndIf
		Next

		dDatae := omodelfql:ADATAMODEL[oModelFQL:GetLine()][1][1][nPosCol]
	EndIf
	
	// Data inicial
	If !empty(dDatas) // FQL_DTSAID
		dIni := dDatas
	Else
		If !empty(oModelFQL:GetValue("FQL_DTSAID"))
			dIni := oModelFQL:GetValue("FQL_DTSAID")
		Else
			dIni := M->FQK_DTINIC
		EndIf
	EndIF

	// Data final
	If !empty(dDatae)
		dFim := dDatae
	Else
		If !empty(oModelFQL:GetValue("FQL_DTENT"))
			dFim := oModelFQL:GetValue("FQL_DTENT")
		Else
			dFim := M->FQK_DTFIM
		EndIf
	EndIF

	//nFator := 0

	nFator := dFim - dIni + 1
	nFrkm := oModelFQL:GetValue("FQL_FRKM")

	If oModelFQL:GetValue("FQL_BFRANQ") == "M"
		nFator := 0
		If !empty(dIni) .and. !empty(dfim) .and. dFim >= dIni

			aCalc := DateDiffYMD(dIni,dFim)
			// Sempre somar 1 dia nos dias calculados
			// aplicar na tabela do lui
			aCalc[3] := aCalc[3] + 1
			nMeses := aCalc[1] * 12
			nMeses += aCalc[2]
			nDias := aCalc[3] // dividir pelo mes final

			If month(dfim) == 2
				If nDias >= 28 
					nMeses += 1
					nDias := 0
				Else
					nDias := nDias / 30
				EndIF
			Else
				If nDias >= 30
					nMeses += 1
					nDias := 0
				Else
					nDias := nDias / 30
				EndIf

			EndIF

			nFranquia := nMeses * nFrkm
			nFranquia += nDias * nFrkm

		Else

			nFranquia := 0

		EndIF
	Else
		nFranquia := nFator * nFrkm 
	EndIF

	If nFranquia < 0
		nFranquia := 0
	EndIf

	LOCA248LIB()
	oModelFQL:SetValue("FQL_VLRFRA",nFranquia)

	// Tratativa do retorno para efeito dos gatilhos
	If cCampo == "M->FQK_DTINIC"
		xRet := M->FQK_DTINIC
	ElseIf cCampo == "M->FQK_DTFIM"
		xRet := M->FQK_DTFIM
	ElseIf cCampo == "M->FQL_DTENT"
		xRet := dDatae // oModelFQL:GetValue("FQL_DTENT")
	ElseIf cCampo == "M->FQL_DTFIM"
		xRet := oModelFQL:GetValue("FQL_DTFIM")
	ElseIf cCampo == "M->FQL_BFRANQ"
		xRet := oModelFQL:GetValue("FQL_BFRANQ")
	ElseIf cCampo == "M->FQL_FRKM"
		xRet := oModelFQL:GetValue("FQL_FRKM")
	ElseIf cCampo == "M->FQL_DTSAID"
		xRet := dDatas //oModelFQL:GetValue("FQL_DTSAID")	
	EndIf

	LOCA248BLQ()

Return xRet

/*/{PROTHEUS.DOC} LOCA248BB
ITUP BUSINESS - TOTVS RENTAL
Parâmetros para as datas de entrada e saída
Frank Z Fuga
26/08/2024
/*/
Function LOCA248BB
Local aPerg := {}
Local cMV312 := GetMv("MV_LOCX312",,"1-SOL.RETIRADA")
Local cMV311 := GetMv("MV_LOCX311",,"1-DT.INICIO")
Local aRet := {}
	SETKEY(VK_F12 , NIL)
	aadd(aPerg,{2,STR0077 + " MV_LOCX312",Iif(cMV312=="SOL.RETIRADA",1,2),{"1-SOL.RETIRADA","2-DT.NFE"},120,".T.",.T.,".T."}) //"Devolução"
	aadd(aPerg,{2,STR0078 + " MV_LOCX311",Iif(cMV311=="DT.INICIO",1,2),{"1-DT.INICIO","2-DT.NF REMESS"},120,".T.",.T.,".T."}) //"Expedição"

	If ParamBox(aPerg,STR0076,aRet,,,,,,,"LOCA248BB",.T.,.T.) // "Identificação das datas de devolução e expedição."
		If valtype(aRet[1])=="C"
			aRet[1] := val(substr(aRet[1],1,1))
		EndIF
		If valtype(aRet[2])=="C"
			aRet[2] := val(substr(aRet[2],1,1))
		EndIF
		If valtype(aRet[1])=="N" .and. valtype(aRet[2])=="N"
			PUTMV("MV_LOCX312", Iif(aRet[1]==1,"SOL.RETIRADA","DT.NFE"))
			PUTMV("MV_LOCX311", Iif(aRet[2]==1,"DT.INICIO","DT.NF REMESS"))
		EndIf
		SETKEY(VK_F12 , {|| LOCA248BB() })

		MsgAlert(STR0097,STR0038) // "Atenção"###"Por favor, encerre a rotina de medição e entre novamente no sistema para receber os parâmetros atualizados."  

	Else
		SETKEY(VK_F12 , {|| LOCA248BB() })
	EndIf

Return .T.

/*/{PROTHEUS.DOC} LOCA248BC
ITUP BUSINESS - TOTVS RENTAL
Tratamento dos bens reservas
Valid dos campor FQK_DTINIC, FQK_DTFIM
Também chamado da rotina LOCA248H (que carrega as linhas da grid FQL)
Frank Z Fuga
27/08/2024
/*/
Function LOCA248BC(lValid)
Local lRet := .T.
Local nI
Local dIni 
Local dFim 
Local cCampo
Local nMov := 0
Local nX
Local cAs
Local lExiste
Local aFQF := {}
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local aAgrupa := {}
Local nY
Local lproc
Local lCria
Local nPonteiro
Local nPont2
Local oView := FWViewActive() 
Local aStruct := FWSX3Util():GetListFieldsStruct( "FQL", .F.)
Local nP
Local lBloqueia
Local cSequencia
//Local nPeriodo
//Local dData
//Local cFrota
Local lIni
Local cProjeto
Local cGrupo
Local dSaida
Local dEntra
Local cGrupoMed 
Local nKmFim
Local nFim := 0
Local dEnt := 0
Local lRetorno := .F.
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQLX := FQL->(GetArea())
Local aAreaFQL

Default lValid := .T.

	// Trazer primeiro os carros reservas da medição anterior
	// ------------------------------------------------------
	If lInclui
		cAs := ""
		cProjeto := ""
		cGrupo := ""
		If M->FQK_TPMED == "A"
			cAs := M->FQK_AS
		Else
			cProjeto := M->FQK_PROJET
			cGrupo := M->FQK_GRPMD
		EndIf

		FQL->(dbSetOrder(5))
		FQL->(dbSeek(xFilial("FQL")))
		While !FQL->(Eof()) .and. FQL->FQL_FILIAL == xFilial("FQL")

			IncProc()

			// Não tratar mão de obra na rotina de carro reserva
			If FQL->FQL_TPAS == "M"
				FQL->(dbSkip())
				Loop
			EndIF

			FQK->(dbSetOrder(1))
			FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))

			If !empty(cProjeto) // Medição por projeto
				If FQK->FQK_PROJET <> cProjeto .or. FQK->FQK_GRPMD <> cGrupo
					FQL->(dbSkip())
					Loop
				EndIF
			Else
				If FQK->FQK_AS <> cAs
					FQL->(dbSkip())
					Loop
				EndIF
			EndIF

			If FQK->FQK_SITUAC == "6"
				FQL->(dbSkip())
				Loop
			EndIF

			// se o bem reserva já teve retorno ignorar
			If !empty(FQL->FQL_DTENT)
				FQL->(dbSkip())
				Loop
			EndIf

			If !empty(FQL->FQL_BEMRES)

				nPonteiro := oModelFQL:GetLine()
				lBloqueia := .F.
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If !oModelFQL:IsDeleted()
						If FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES")
							lBloqueia := .T.
						EndIf
					EndIf
				Next
				oModelFQL:GoLine(nPonteiro)
				If lBloqueia
					FQL->(dbSkip())
					Loop
				EndIf

				aAreaFQL := FQL->(GetArea())

				If !empty(oModelFQL:GetValue("FQL_AS"))
					oModelFQL:AddLine()
					oModelFQL:GoLine( oModelFQL:Length() )
					oModelFQL:LoadValue("FQL_AS",FQL->FQL_AS)
				EndIF

				For nP := 1 to len(aStruct)
					If x3Usado( aStruct[nP][01] ) .and. GetSx3Cache(aStruct[nP][01],"X3_CONTEXT") == "R"
						cCampo := alltrim(aStruct[nP][01])
						If !empty( &("FQL->"+cCampo) )
							If cCampo <> "FQL_ITEM"
								If cCampo <> "FQL_ORDEM"
									LOCA248LIB()
									oModelFQL:SetValue(cCampo,&("FQL->"+cCampo))
								Else
									LOCA248LIB()
									oModelFQL:SetValue(cCampo,M->FQK_MEDSEQ)
								EndIf
							EndIf
						EndIF
					EndIf
				Next
				LOCA248LIB()
				oModelFQL:SetValue("FQL_FRKM",0)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_QTDKM",0)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_HORTOT",0)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_VALHOR",0)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_QTDHR",0)
				LOCA248LIB()
				oModelFQL:LoadValue("FQL_BEMRES",FQL->FQL_BEMRES)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_DTMEDI",dDataBase)

				// Carro reserva sempre será 100% máquina e 0 mão de obra
				LOCA248LIB()
				oModelFQL:SetValue("FQL_PERMO",0)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_PERMAQ",100)

				// Buscar a data do envio e do retorno com base nas medicoes anteriores
				// ----------------------------------------------------------------------
				dSaida := ctod("")
				dEntra := ctod("")
				// Validar se foi preenchido em alguma medicao anterior
				If M->FQK_TPMED == "A" .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
					cAs := M->FQK_AS
					FQK->(dbSetOrder(2))
					FQK->(dbSeek(xFilial("FQK")+cAs))
					While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
						If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
							FQL->(dbSetOrder(6))
							If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
								While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS+FQL_COD+FQL_ORDEM) == xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)
									If FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES") .and. FQL->FQL_TPAS <> "M"
										If !empty(FQL->FQL_DTSAID)
											dSaida := FQL->FQL_DTSAID
										EndIf
										If !empty(FQL->FQL_DTENT)
											dEntra := FQL->FQL_DTENT
										EndIf
									EndIf
									FQL->(dbSkip())
								EndDo
							EndIf
						EndIf
						FQK->(dbSkip()) 
					EndDo
				EndIF
				If M->FQK_TPMED == "G" .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
					// Em grupo a FPA já está posicionada neste momento
					cProjeto := M->FQK_PROJET
					cGrupoMed := M->FQK_GRPMD
					cAs := oModelFQL:GetValue("FQL_AS")
					FQL->(dbSetOrder(6))
					FQL->(dbSeek(xFilial("FQL")+cAs))
					While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
						FQK->(dbSetOrder(1))
						If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
							If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
								If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed
									If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
										While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS+FQL_COD+FQL_ORDEM) == xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)
											If FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES") .and. FQL->FQL_TPAS <> "M"
												If !empty(FQL->FQL_DTSAID)
													dSaida := FQL->FQL_DTSAID
												EndIf
												If !empty(FQL->FQL_DTENT)
													dEntra := FQL->FQL_DTENT
												EndIf
											EndIf
											FQL->(dbSkip())
										EndDo
									EndIf
								EndIf
							EndIf
						EndIf
						FQL->(dbSkip())
					EndDo
				EndIF
				If empty(oModelFQL:GetValue("FQL_DTSAID")) .and. !empty(dSaida) .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
					If dSaida >= M->FQK_DTINIC .and. dSaida <= M->FQK_DTFIM
						LOCA248LIB()
						oModelFQL:SetValue("FQL_DTSAID",dSaida)
					EndIF
				EndIF
				If empty(oModelFQL:GetValue("FQL_DTENT")) .and. !empty(dEntra) .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
					If dEntra >= M->FQK_DTINIC .and. dEntra <= M->FQK_DTFIM
						LOCA248LIB()
						oModelFQL:SetValue("FQL_DTENT",dEntra)
					EndIF
				EndIF

				FQL->(RestArea(aAreaFQL))
	
			EndIf  
			FQL->(dbSkip())
		EndDo
	EndIf
	// ------------------------------------------------------
	
	If lValid 
		cCampo := alltrim(upper(ReadVar()))
	EndIF

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		IncProc()
		oModelFQL:GoLine(nI)

		If !oModelFQL:IsDeleted() .and. !empty(oModelFQL:GetValue("FQL_AS"))

			If oModelFQL:GetValue("FQL_TPAS") == "M"
				Loop
			EndIF

			dIni := M->FQK_DTINIC
			dFim := M->FQK_DTFIM

			If lValid
				If cCampo == "M->FQK_DTINIC" 
					dIni := &(ReadVar())
				EndIf
				If cCampo == "M->FQK_DTFIM" 
					dFim := &(ReadVar())
				EndIf
			EndIF

			cAs := oModelFQL:GetValue("FQL_AS")

			// Tratamento para deletar as linhas que não estão mais válidas por haver a nota de entrada
			If !empty(oModelFQL:GetValue("FQL_DTENT")) .and. !empty(dIni)
				If oModelFQL:GetValue("FQL_DTENT") < dIni
					LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
					oModelFQL:DeleteLine()
				EndIF
			EndIf

			// Para validar os itens reservas, faz-se necessário haver a data inicial e final para procurar na FQF
			// Passo 1: se houver um item na grid que esteja fora do período perguntar se deseja estornar
			// Passo 2: se estiver no período validar se o movimento fica somente o de entrada, saída, ou os 2
			// Passo 3: se não localizar criar o movimento na grid
			// nMov 3 = Incluir, 4 = Alterar, ou 5 = Excluir

			lExiste := .F.
			If !empty(dIni) .and. !empty(dFim) .and. empty(oModelFQL:GetValue("FQL_BEMRES")) .and. !empty(cAs)
				FQF->(dbSetOrder(4))
				FQF->(dbSeek(xFilial("FQF")+cAs))
				While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_AS) == xFilial("FQF")+cAs
					If FQF->FQF_DTINI >= dIni .and. FQF->FQF_DTINI <= dFim
						aadd(aFQF,{FQF->FQF_COD, FQF->FQF_AS, FQF->FQF_STATUS, FQF->FQF_SUBST, FQF->FQF_DTINI, FQF->FQF_CONRES})
						lExiste := .T.
					EndIf
					FQF->(dbSkip())
				EndDo

				// Tratamento 1 - estorno
				// se alterou o período e existe algum registro de bem reserva na grid que não tenha relação com a FQF
				// excluir, ou bloquear a alteração do período
				If !lExiste // movimento na FQF
					nPont2 := oModelFQL:GetLine()
					For nX := 1 to oModelFQL:Length()
						oModelFQL:GoLine(nX)
						If !oModelFQL:IsDeleted() .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
							//nMov := 5
						EndIf
					Next
					oModelFQL:GoLine(nPont2)
				EndIf

				oModelFQL:GoLine(nI)

			EndIf
		EndIf


		// Tratamento para o KmINI
		// Se já houve uma medicao anterior pegar do KMFIM
		// Se a data da expedição estiver em branco pegar da final
		If empty(oModelFQL:GetValue("FQL_DTSAID")) .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
			// Buscar a data do envio e do retorno com base nas medicoes anteriores
			// ----------------------------------------------------------------------
			nKmFim := 0
			// Validar se foi preenchido em alguma medicao anterior
			If M->FQK_TPMED == "A" .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
				cAs := M->FQK_AS
				FQK->(dbSetOrder(2))
				FQK->(dbSeek(xFilial("FQK")+cAs))
				While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
					If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
						FQL->(dbSetOrder(6))
						If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
							While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS+FQL_COD+FQL_ORDEM) == xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)
								If FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES") .and. !empty(FQL->FQL_KMFIM) .and. FQL->FQL_TPAS <> "M"
									nKmFim := FQL->FQL_KMFIM
								EndIf
								FQL->(dbSkip())
							EndDo
						EndIf
					EndIf
					FQK->(dbSkip()) 
				EndDo
			EndIF
			If M->FQK_TPMED == "G" .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
				// Em grupo a FPA já está posicionada neste momento
				cProjeto := M->FQK_PROJET
				cGrupoMed := M->FQK_GRPMD
				cAs := oModelFQL:GetValue("FQL_AS")
				FQL->(dbSetOrder(6))
				FQL->(dbSeek(xFilial("FQL")+cAs))
				While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
					FQK->(dbSetOrder(1))
					If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
						If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
							If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed
								If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
									While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS+FQL_COD+FQL_ORDEM) == xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)
										If FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES") .and. !empty(FQL->FQL_KMFIM) .and. FQL->FQL_TPAS <> "M"
											nKmFim := FQL->FQL_KMFIM
										EndIf
										FQL->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf
					FQL->(dbSkip())
				EndDo
			EndIF

			LOCA248LIB()
			If oModelFQL:GetValue("FQL_TPAS") <> "M"
				oModelFQL:SetValue("FQL_KMINI", nKmFim )
			EndIf

			// Zerar o KMFIM quando for sem o retorno
			If !empty(oModelFQL:GetValue("FQL_BEMRES")) .and. empty(oModelFQL:GetValue("FQL_DTENT"))
				LOCA248LIB()
				oModelFQL:SetValue("FQL_KMFIM",0)
			EndIF

		EndIf

	Next
	oModelFQL:GoLine(nPonteiro)

	// aFQF = registro das ocorrências de carros reservas
	// ordenado pela sequencia dos movimentos
	aFQF := ASORT(aFQF,,,{|X,Y| X[1] < Y[1] })
	If len(aFQF) > 0 .and. nMov <> 5

		// Esta separado por AS, agora basta agrupar saídas com as entradas
		aAgrupa := {}
		For nX := 1 to len(aFQF)
			IncProc()
			// Tipo de movimento do bem reserva
			FQE->(dbSetOrder(2))
			FQE->(dbSeek(xFilial("FQE")+aFQF[nX,3]+aFQF[nX,4]))
			If FQE->FQE_TIPO == "1" 
				// Entrada
				lProc := .F.
				For nY := 1 to len(aAgrupa)
					If aAgrupa[nY,1] < aFQF[nX,1] .and. empty(aAgrupa[nY,5]) //5 = registro da entrada
						aAgrupa[nY,5] := aFQF[nX,1]
						aAgrupa[nY,6] := "SE" // saida e entrada
						//aAgrupa[nY,7] -> AS, já foi instanciada no movimento de saída
						aAgrupa[nY,8] := aFQF[nX,5]
						lProc := .T.
						aAgrupa[nY,10] := aFQF[nX,1]
						aAgrupa[nY,12] := aFQF[nX,6]
					EndIf
				Next
				If !lproc // não localizou um registro de saída
					aadd(aAgrupa,{aFQF[nX,1], aFQF[nX,2], nX, "", "", "E", aFQF[nX,2],aFQF[nX,5],ctod(""),"",aFQF[nX,6],0}) // somente entrada
					aAgrupa[nY,10] := aFQF[nX,1]
				EndIf
			Else
				// saída
				// Todo registro de saída é um registro novo no agrupador
				//            Codigo,       AS,         nagrupador, controle, FQF de Entrada correspondente, tipo movimento
				    aadd(aAgrupa,{aFQF[nX,1], aFQF[nX,2], nX, "", "", "S", aFQF[nX,2],ctod("")  ,aFQF[nX,5],"",aFQF[nX,6],0}) // saida
					aAgrupa[len(aAgrupa),10] := aFQF[nX,1]
			EndIf
		Next

		nFim := 0
		dEnt := ctod("")
		For nX := 1 to len(aAgrupa)
			IncProc()
			lCria := .T.
			nPonteiro := oModelFQL:GetLine()
			For nY := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nY)
				If !oModelFQL:IsDeleted() 
					If oModelFQL:GetValue("FQL_BEMRES") == aAgrupa[nX,1] .or. oModelFQL:GetValue("FQL_BEMRES") == aAgrupa[nX,10]
						lCria := .F.
						nPonteiro := nY
					EndIF
				EndIF
			Next
			oModelFQL:GoLine(nPonteiro)

			If lCria
				// Validar se o registro a ser criado é de entrada
				// Sendo de entrada, posicionar na FQF no registro correspondente a saida
				// Validar se o registro da FQL é de saida e bate com o registro da FQF
				// Batendo os registro não vamos criar novamente, para nao haver duplicidade
				FQF->(dbSetOrder(1))
				FQF->(dbSeek(xFilial("FQF")+aAgrupa[nX,1]))
				cSequencia := FQF->FQF_SEQ
				cSaida := ""
				FQF->(dbSetOrder(2))
				FQF->(dbSeek(xFilial("FQF")+cSequencia))
				While !FQF->(Eof()) .and. FQF->FQF_SEQ == cSequencia
					If FQF->FQF_COD <> aAgrupa[nX,1]
						cSaida := FQF->FQF_COD
					EndIF

					FQE->(dbSetOrder(2))
					FQE->(dbSeek(xFilial("FQE")+FQF->FQF_STATUS+FQF->FQF_SUBST))
					If FQE->FQE_TIPO == "1" 
						nFim := FQF->FQF_CONRES
						dEnt := FQF->FQF_DTINI
					EndIF

					FQF->(dbSkip())
				EndDo
				If !empty(cSaida)
					nPonteiro := oModelFQL:GetLine()
					For nY := 1 to oModelFQL:Length()
						oModelFQL:GoLine(nY)
						If !oModelFQL:IsDeleted() 
							If oModelFQL:GetValue("FQL_BEMRES") == cSaida
								lCria := .F.
								nPonteiro := nY
							EndIF
						EndIF
					Next
					oModelFQL:GoLine(nPonteiro)
				EndIF
			EndIF

			FPA->(dbSetOrder(3))
			FPA->(dbSeek(xFilial("FPA")+aAgrupa[nX,7]))

			FQF->(dbSetOrder(1))
			FQF->(dbSeek(xFilial("FQF")+aAgrupa[nX,1]))

			nI := oModelFQL:Length()
			oModelFQL:GoLine(nI)

			If lCria
				oModelFQL:AddLine()
				oModelFQL:GoLine(oModelFQL:Length())
				LOCA248AG(oModelFQL:Length(),M->FQK_TPMED)
				LOCA248LIB()
				oModelFQL:SetValue("FQL_DTMEDI",dDataBase)
			Else
				oModelFQL:GoLine(nPonteiro)
			EndIF
			
			// Complemento geral
			LOCA248LIB()
			oModelFQL:SetValue("FQL_BEMRES", aAgrupa[nX,1])
			//oModelFQL:SetValue("FQL_AS", aAgrupa[nX,2])
			LOCA248LIB()
			oModelFQL:SetValue("FQL_FROTA", FQF->FQF_BEMRES)

			lIni := .F.

			//25/09/25 - DSERLOCA-8649 - Frank Fuga - Preenchimento da data de expedição
			//LOCA248B9()
			//oModelFQL:GoLine(1)

			If nFim > 0

				// Verificar em medições anteriores
				lRetorno := .F.
				If M->FQK_TPMED == "A"
					cAs := M->FQK_AS
					FQK->(dbSetOrder(2))
					FQK->(dbSeek(xFilial("FQK")+cAs))
					While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
						If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
							FQL->(dbSetOrder(6))
							If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ))) 
								If !empty(FQL->FQL_DTENT) .and. FQL->FQL_TPAS <> "M"
									lRetorno := .T.
									Exit
								EndIf
							EndIf
						EndIf
						FQK->(dbSkip()) 
					EndDo
				Else
					// Em grupo a FPA já está posicionada neste momento
					cProjeto := M->FQK_PROJET
					cGrupoMed := M->FQK_GRPMD
					cAs := oModelFQL:GetValue("FQL_AS")
					FQL->(dbSetOrder(6))
					FQL->(dbSeek(xFilial("FQL")+cAs))
					While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
						FQK->(dbSetOrder(1))
						If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
							If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
								If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed
									If !empty(FQL->FQL_DTENT) .and. FQL->FQL_TPAS <> "M"
										lRetorno := .T.
										Exit
									EndIf
								EndIf
							EndIf
						EndIf
						FQL->(dbSkip())
					EndDo
				EndIF
				if lRetorno .or. !empty(oModelFQL:GetValue("FQL_DTENT"))
					//LOCA248LIB()
					//oModelFQL:SetValue("FQL_KMFIM", nFim)
					//LOCA248LIB()
					//oModelFQL:SetValue("FQL_DTENT", dEnt)
				EndIf

			EndIf

			// Tratamento para zerar os campos do bem reserva
			LOCA248LIB()
			oModelFQL:SetValue("FQL_FRKM",0)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_QTDKM",0)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_HORTOT",0)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALHOR",0)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_QTDHR",0)

			// Carro reserva sempre será 100% máquina e 0 mão de obra
			LOCA248LIB()
			oModelFQL:SetValue("FQL_PERMO",0)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_PERMAQ",100)
			
		Next

	EndIf


	// Tratativa final da data de retorno e kmfim
	nPonteiro := oModelFQL:GetLine()
	For nY := 1 to oModelFQL:Length()
		IncProc()
		nFim := 0
		dEnt := ctod("")
		oModelFQL:GoLine(nY)
		If !oModelFQL:IsDeleted() .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
			FQF->(dbSetOrder(1))
			FQF->(dbSeek(xFilial("FQF")+oModelFQL:GetValue("FQL_BEMRES")))
			FQE->(dbSetOrder(2))
			FQE->(dbSeek(xFilial("FQE")+FQF->FQF_STATUS+FQF->FQF_SUBST))
			If FQE->FQE_TIPO == "1" // entrada
				If FQF->FQF_DTINI >= M->FQK_DTINIC .and. FQF->FQF_DTINI <= M->FQK_DTFIM
					nFim := FQF->FQF_CONRES
					dEnt := FQF->FQF_DTINI
				EndIf
			Else // saida
				cSequencia := FQF->FQF_SEQ
				FQF->(dbSetOrder(2))
				If FQF->(dbSeek(xFilial("FQF")+cSequencia))
					LOCA248LIB()
					oModelFQL:SetValue("FQL_DTSAID", FQF->FQF_DTINI)
					If oModelFQL:GetValue("FQL_TPAS") <> "M"
						oModelFQL:SetValue("FQL_KMINI", FQF->FQF_CONRES)
					EndIf
				EndIf
				While !FQF->(Eof()) .and. FQF->(FQF_FILIAL+FQF_SEQ) == xFilial("FQF")+cSequencia
					If FQF->FQF_COD <> oModelFQL:GetValue("FQL_BEMRES")
						If FQF->FQF_DTINI >= M->FQK_DTINIC .and. FQF->FQF_DTINI <= M->FQK_DTFIM
							nFim := FQF->FQF_CONRES
							dEnt := FQF->FQF_DTINI
						EndIf
					EndIf
					FQF->(dbSkip())
				EndDo
			EndIF
			If nFim > 0
				LOCA248LIB()
				If oModelFQL:GetValue("FQL_TPAS") <> "M"
					oModelFQL:SetValue("FQL_KMFIM", nFim)
				EndIf
				LOCA248LIB()
				oModelFQL:SetValue("FQL_DTENT", dEnt)
			EndIF
		EndIf
	Next
	oModelFQL:GoLine(nPonteiro)

	oModelFQL:GoLine(1)
	oView:Refresh()

	LOCA248BLQ()

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQLX))

Return lRet

/*/{PROTHEUS.DOC} LOCA248B5
ITUP BUSINESS - TOTVS RENTAL
Gatilhos dos campos FQL_KMINI, FQL_KMFIM, FQL_COMPLE
Frank Z Fuga
28/08/2024
/*/

Function LOCA248B5
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nRet := 0
Local nComple
Local cBemOri
Local nI
Local nPonteiro 
Local cCampo := alltrim(upper(ReadVar()))
Local cAs := oModelFQL:GetValue("FQL_AS")
Local nFim
Local nIni
Local oView := FWViewActive() 

	// Somente para bem reserva
	If (cCampo == "M->FQL_KMINI" .or. cCampo == "M->FQL_KMFIM") .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))

		nFim := oModelFQL:GetValue("FQL_KMFIM")
		nIni := oModelFQL:GetValue("FQL_KMINI")

		// Depois de calculado FQL_COMPLE, localizar o bem origem que não é o reserva e acrescentar
		FQF->(dbSetOrder(1))
		FQF->(dbSeek(xFilial("FQF")+oModelFQL:GetValue("FQL_BEMRES")))
		cBemOri := FQF->FQF_CODBEM
		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nI)
			If oModelFQL:GetValue("FQL_FROTA") == cBemOri .and. oModelFQL:GetValue("FQL_AS") == cAs
				nComple := nFim - nIni
				If nComple > 0
					LOCA248LIB()
					oModelFQL:SetValue("FQL_COMPLE",nComple)
				Else
					LOCA248LIB()
					oModelFQL:SetValue("FQL_COMPLE",0)
				EndIf
				Exit
			EndIf
		Next
		oModelFQL:GoLine(nPonteiro)

		nRet := oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI")
		//oModelFQL:SetValue("FQL_QTDKM", nCalc )

	Else
		
		nRet := oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI") + oModelFQL:GetValue("FQL_COMPLE")
		//oModelFQL:SetValue("FQL_QTDKM", nCalc )

	EndIf

	If nRet < 0
		nRet := 0
	EndIf

	LOCA248BLQ()
	
	oView:Refresh("FQLDETAIL")
	oView:GetViewObj("FQLDETAIL")[3]:oControl:oOwner:aControls[21]:SetFocus()
	

Return nRet


/*/{PROTHEUS.DOC} LOCA248C1
ITUP BUSINESS - TOTVS RENTAL
Gatilhos do campo FQJ_PERDE
Frank Z Fuga
02/09/2024
/*/

Function LOCA248C1
Local cPerAte := "  "
	If val(M->FQJ_PERDE) == 1
		cPerAte := "31"
	ElseIf val(M->FQJ_PERDE) > 1
		cPerAte := strzero(val(M->FQJ_PERDE)-1,2,0)
	EndIf
Return cPerAte

/*/{PROTHEUS.DOC} LOCA248C2
ITUP BUSINESS - TOTVS RENTAL
Gatilhos do campo FQK_PMEDI
Frank Z Fuga
02/09/2024
/*/

Function LOCA248C2
Local aArea := GetArea()
Local nX
Local dData := M->FQK_DTINIC

	If !empty(M->FQK_PMEDI) .and. !empty(dData)

		FQJ->(dbSetOrder(1))
		FQJ->(dbSeek(xFilial("FQJ")+M->FQK_PMEDI))

		nMes := month(dData)
		nAno := Year(dData)

		// unica condição que não vira o Mês
		// Qtd.Mes == 1
		// dia inicial == 1
		If day(dData) == 1 .and. FQJ->FQJ_QTDMES == 1 .and. val(FQJ->FQJ_PERDE) == 1
			dData := LastDate(dData)
		Else
			For nX := 1 to FQJ->FQJ_QTDMES
				nMes ++
				If nMes == 13
					nMes := 1
					nAno ++
				EndIf
			Next
			If val(FQJ->FQJ_PERATE) == 29
				If day( lastday( ctod( "01" + "/" + str(nMes) + "/" + str(nAno) ) ) ) == 28
					dData := ctod( "28" + "/" + str(nMes) + "/" + str(nAno) )
				Else
					dData := ctod( "29" + "/" + str(nMes) + "/" + str(nAno) )
				EndIf
			ElseIf val(FQJ->FQJ_PERATE) == 30
				If day( lastday( ctod( "01" + "/" + str(nMes) + "/" + str(nAno) ) ) ) == 28
					dData := ctod( "28" + "/" + str(nMes) + "/" + str(nAno) )
				ElseIf day( lastday( ctod( "01" + "/" + str(nMes) + "/" + str(nAno) ) ) ) == 29
					dData := ctod( "29" + "/" + str(nMes) + "/" + str(nAno) )
				Else
					dData := ctod( "30" + "/" + str(nMes) + "/" + str(nAno) )
				EndIf
			ElseIf val(FQJ->FQJ_PERATE) == 31
				If day( lastday( ctod( "01" + "/" + str(nMes) + "/" + str(nAno) ) ) ) == 28
					dData := ctod( "28" + "/" + str(nMes) + "/" + str(nAno) )
				ElseIf day( lastday( ctod( "01" + "/" + str(nMes) + "/" + str(nAno) ) ) ) == 29
					dData := ctod( "29" + "/" + str(nMes) + "/" + str(nAno) )
				ElseIf day( lastday( ctod( "01" + "/" + str(nMes) + "/" + str(nAno) ) ) ) == 30
					dData := ctod( "30" + "/" + str(nMes) + "/" + str(nAno) )
				Else
					dData := ctod( "31" + "/" + str(nMes) + "/" + str(nAno) )
				EndIf
			Else 
				dData := ctod( FQJ->FQJ_PERATE + "/" + str(nMes) + "/" + str(nAno) )
			EndIf

		EndIf
	Else

		dData := ctod("")
	
	EndIf

	RestArea(aArea)
Return dData


/*/{PROTHEUS.DOC} LOCA248B9
ITUP BUSINESS - TOTVS RENTAL
FQL_DTENT e FQL_DTSAID
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B9
Local nI
Local cAs
Local cTipoEnt := SuperGetMV("MV_LOCX312",,"SOL.RETIRADA")
Local cTipoSai := SuperGetMV("MV_LOCX311",,"DT.INICIO")
Local dEntrada := ctod("")
Local dSaida := ctod("")
Local cProjeto
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nPonteiro
Local aAreaFPA
//Local lNota := GetMv("MV_LOCX067",,.T.)

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		
		//25/09/25 - DSERLOCA-8649 - Frank Fuga - Preenchimento da data de expedição
		cAS := oModelFQL:GetValue("FQL_AS")
		
		If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES")) .and. !empty(cAs)
			//cAS := oModelFQL:GetValue("FQL_AS")
			FPA->(dbSetOrder(3))
			FPA->(dbSeek(xFilial("FPA")+cAS))
			cProjeto := FPA->FPA_PROJET

			aAreaFPA := FPA->(GetArea())
			If lInclui .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
				LOCA248LIB()
				oModelFQL:SetValue("FQL_DTENT",ctod(""))
				LOCA248LIB()
				oModelFQL:SetValue("FQL_DTSAID",ctod(""))
			EndIf
			FPA->(RestArea(aAreaFPA))
			
			If cTipoEnt == "SOL.RETIRADA"
				If FPA->FPA_DTSCRT >= M->FQK_DTINIC .and. FPA->FPA_DTSCRT <= M->FQK_DTFIM
					LOCA248LIB()
					oModelFQL:SetValue("FQL_DTENT",FPA->FPA_DTSCRT)
				EndIF
			EndIf
			If cTipoSai == "DT.INICIO" 
				If LOCA248BD(FPA->FPA_DTINI)
					If FPA->FPA_DTINI >= M->FQK_DTINIC .and. FPA->FPA_DTINI <= M->FQK_DTFIM
						LOCA248LIB()
						oModelFQL:SetValue("FQL_DTSAID",FPA->FPA_DTINI)
					EndIf
				EndIf
			EndIf

			//If lNota
			If cTipoEnt == "DT.NFE"
				dEntrada := FPA->FPA_DNFRET
				If dEntrada >= M->FQK_DTINIC .and. dEntrada <= M->FQK_DTFIM
					LOCA248LIB()
					oModelFQL:SetValue("FQL_DTENT",dEntrada)
				EndIf
			EndIf
			If cTipoSai == "DT.NF REMESS"
				dSaida := FPA->FPA_DNFREM
				// Posicionar na FPY e ver se TIPFAT == "R" // remessa
				If LOCA248BD(dSaida)
					If dSaida >= M->FQK_DTINIC .and. dSaida <= M->FQK_DTFIM
						LOCA248LIB()
						oModelFQL:SetValue("FQL_DTSAID",dSaida)
					EndIf
				EndIf
			EndIf
			//EndIF
				
		EndIf
	Next
	oModelFQL:GoLine(nPonteiro)

	// Cálculo da franquia
	LOCA248BA()

	LOCA248BLQ()

Return .T.

/*/{PROTHEUS.DOC} LOCA24809
ITUP BUSINESS - TOTVS RENTAL
Totais da medição
Frank Z Fuga
20/08/2024
/*/

Function LOCA24809
Return


/*/{PROTHEUS.DOC} LOCA248B1
ITUP BUSINESS - TOTVS RENTAL
Uso no SXB FQ5FQK e valid do campo FQK_AS
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B1(cAs,lVal)
Local cgrpand
Local lRet := .T.
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cErro
Local lAvisa := .F.
Local nX
Local nPonteiro
Default cAs := FQ5->FQ5_AS
Default lVal := .F.

	If SBM->(FieldPos("BM_XACESS")) > 0
		cgrpand := LOCA00189()
	Else
		cgrpand := SuperGetMV("MV_LOCX014",.F.,"")
	EndIf
	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+cAs))
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

	// Se for de acessório não trazer a AS
	If ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND)
		lRet := .F.
	EndIf

	// Mesmo estando dentro do grupo de produtos se for mão de obra aceitar
	If SB1->B1_TIPO == "MO"
		lRet := .T.
	EndIf

	If lVal // Chamada no valid do campo
		nPonteiro := oModelFQL:GetLine()
		For nX := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nX)
			If !oModelFQL:IsDeleted()		
				If !empty(oModelFQL:GetValue("FQL_AS"))
					If oModelFQL:GetValue("FQL_AS") <> cAs
						lAvisa := .T.
						lRet := .F.
						cErro := STR0072 //"Delete primeiro a linha dos itens para a troca da AS"
					EndIf
					Exit
				EndIf
			EndIF
		Next
		oModelFQL:GoLine(nPonteiro)
		If lAvisa
			Help( ,, "LOCA248-LOCA248B1",, STR0002, 1, 0,,,,,,{cErro}) //"Inconsistência nos dados."
		EndIf
	EndIf

Return lRet


/*/{PROTHEUS.DOC} LOCA248B2
ITUP BUSINESS - TOTVS RENTAL
Validacao para o tipo AS para nao permitir duas linhas na grid
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B2(oModel)
Local lRet := .T.
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nI
Local nTotLinha := 0
Local lErroAS := .F.
Local aAs := {}
Local nX
Local lTem
Local nTotMin := 0
Local lMinuta := .F. 
Local cAs
Local cTurno
Local cHrPara := "00:00"
Local cTemp
Local nQtdHr := 0
Local nTemp := 0
Local nTemp2 := 0
Local lExist := .F.
Local cItem
Local nPonteiro
Local cTipoSai := SuperGetMV("MV_LOCX311",,"DT.INICIO")
Local lBlqRem := .F.
Local cProjeto
Local cGrupoMed 
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local lItens := .F.

	// Validar se existem itens válidos
	nPonteiro := oModelFQL:GetLine() 
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()
			If !empty(oModelFQL:GetValue("FQL_AS") )
				lItens := .T.

				If oModelFQL:GetValue("FQL_KMFIM") < oModelFQL:GetValue("FQL_KMINI")
					Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0112+alltrim(oModelFQL:GetValue("FQL_ITEM"))}) //"Inconsistência nos dados."###"A quantidade final está menor do que a quantidade inicial. Item: "
					Return .F.
				EndIF

			EndIf
		EndIf
	Next
	oModelFQL:GoLine(nPonteiro)

	If !lItens
		Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0110}) //"Inconsistência nos dados."###"Não foram lançados itens válidos para a gravação da medição."
		Return .F.
	EndIF

	// Validar o período financeiro
	nPonteiro := oModelFQL:GetLine() 
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()
			If !LOCA02003( oModelFQL:GetValue("FQL_DTMEDI") )
				oModelFQL:GoLine(nPonteiro)
				Return .F.
			EndIf
		EndIF
	Next
	oModelFQL:GoLine(nPonteiro)


	// Validar se a remessa foi inserida
	If cTipoSai <> "DT.INICIO" // Exige a remessa
		lBlqRem := .F.
		nPonteiro := oModelFQL:GetLine() 
		For nI := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()
				If empty(oModelFQL:GetValue("FQL_DTSAID"))
					lBlqRem := .T.
					// Validar se foi preenchido em alguma medicao anterior
					If M->FQK_TPMED == "A" 
						cAs := M->FQK_AS
						FQK->(dbSetOrder(2))
						FQK->(dbSeek(xFilial("FQK")+cAs))
						While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
							If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
								FQL->(dbSetOrder(6))
								If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
									If !empty(FQL->FQL_DTSAID)
										lBlqRem := .F.
										Exit
									EndIf
								EndIf
							EndIf
							FQK->(dbSkip()) 
						EndDo
					Else
						// Em grupo a FPA já está posicionada neste momento
						cProjeto := M->FQK_PROJET
						cGrupoMed := M->FQK_GRPMD
						cAs := oModelFQL:GetValue("FQL_AS")
						FQL->(dbSetOrder(6))
						FQL->(dbSeek(xFilial("FQL")+cAs))
						While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
							FQK->(dbSetOrder(1))
							If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
								If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
									If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed
										If !empty(FQL->FQL_DTSAID)
											lBlqRem := .F.
											Exit
										EndIf  
									EndIf
								EndIf
							EndIf
							FQL->(dbSkip())
						EndDo
					EndIF

				EndIf
			EndIf
		Next
	EndIf
	oModelFQL:GoLine(nPonteiro)
	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))

	If lBlqRem
		Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0108}) //"Inconsistência nos dados."###"A data de expedição ainda não foi preenchida."
		Return .F.
	EndIf

	// Se a Medicao for do tipo AS, não pode haver mais de uma linha ativa
	// para validar, coloque uma medicao do tipo AS, indique uma AS na FQK, delete a linha e insira uma outra AS diferente na FQK
	// tire a deleção da primeira linha do grid
	If M->FQK_TPMED == "A"
		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()
				If oModelFQL:GetValue("FQL_AS") <> M->FQK_AS
					lErroAS := .T.
				EndIf
				If empty(oModelFQL:GetValue("FQL_BEMRES"))
					nTotLinha ++
				EndIF
			EndIF
		Next
		oModelFQL:GoLine(nPonteiro)
		If nTotLinha > 1 
			//Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0071}) //"Inconsistência nos dados."###"Não pode haver mais de uma linha nos itens para o tipo de medição por AS"
			//lRet := .F.
		EndIF
		If lErroAS
			Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0073}) //"Inconsistência nos dados."###"A AS do item não confere com a AS do cabeçalho"
			lRet := .F.
		EndIF
	Elseif M->FQK_TPMED == "G"
		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()
				cAs := oModelFQL:GetValue("FQL_AS")
				FPA->(dbSetOrder(3))
				FPA->(dbSeek(xFilial("FPA")+cAs))
				If FPA->FPA_GRUPOM <> M->FQK_GRPMD
					lRet := .F.
					Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0074}) //"Inconsistência nos dados."###"A AS não pertence ao grupo informado."
					Exit
				EndIf
				lTem := .F.
				For nX := 1 to len(aAs)
					If aAs[nX,1] == cAs .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
						lTem := .T.
						Exit
					EndIf
				Next
				If !lTem .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
					aadd(aAs,{cAs})
				EndIf
				If lTem
					//lRet := .F.
					//Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0075}) //"Inconsistência nos dados."###"Existem AS repetidas nos itens"
					//Exit
				EndIf
			EndIF
		Next
		oModelFQL:GoLine(nPonteiro)

	EndIF

	// Card 4049 - somente para minuta
	// Após a somatória do campo [Mínimo Mês (FPA_XXXX) - Somatória de Hrs parada (FQF_HRPARA)]
	// no cabeçalho da medição deverá validar se o total de horas real (FQL_QTDHR) é superior ao 
	// mínimo esperado se não tiver apresentar um alerta com a mensagem que a medição está abaixo do mínimo 
	// sem bloqueio.

	aAs := {}
	lExist := .F.
	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()

			// Validacao dos percentuais
			If oModelFQL:GetValue("FQL_PERMO") + oModelFQL:GetValue("FQL_PERMAQ") <> 100
				cItem := oModelFQL:GetValue("FQL_ITEM")
				Help( ,, "LOCA248-LOCA248B2",, STR0002, 1, 0,,,,,,{STR0089+cItem}) //"Inconsistência nos dados."###"A somatória do % de mão de obra + % de máquina não totalizam 100%. Item: "
				Return .F.
			EndIf

			cAs := oModelFQL:GetValue("FQL_AS")
			cTurno := oModelFQL:GetValue("FQL_TURNO")
			FPA->(dbSetOrder(3))
			If FPA->(dbSeek(xFilial("FPA")+cAs))
				If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
					lMinuta := .T.
				EndIf

				lExist := .F.
				For nX := 1 to len(aAs)
					If aAs[nX,1] == cAs
						lExist := .T.
						Exit
					EndIf
				Next
				If !lExist
					aadd(aAs,{cAs})
					nTotMin += FPA->FPA_MINMES
				EndIf

				nQtdHr += oModelFQL:GetValue("FQL_QTDHR")

				nTemp2 := 0

				FPF->(dbSetOrder(4))
				FPF->(dbSeek(xFilial("FPF")+aAs[nX,1]))
				While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == aAs[nX,1]

					If lAltera
						If FPF->FPF_NROMED <> M->FQK_COD
							FPF->(dbSkip())
							Loop
						EndIf
					EndIf

					If FPF->FPF_STATUS == "3" .or. (lAltera .and. FPF->FPF_STATUS == "6")
						If FPF->FPF_DATA <= M->FQK_DTFIM
							If FPF->FPF_TURNO == cTurno
								cTemp := FPF->FPF_HRPARA
								If empty(cTemp)
									cTemp := "00:00"
								Else
									cTemp := substr(cTemp,1,2)+":"+substr(cTemp,3,2)
								EndIF
								nTemp2 += SomaHoras( cHrPara, cTemp )   
							EndIF
						EndIF
					EndIF
					FPF->(dbSkip())
				EndDo

			EndIF
		EndIF
	Next
	oModelFQL:GoLine(nPonteiro)
	If lMinuta
		nTemp := nTotMin - nTemp2
		If nTemp > nQtdHr
			MsgAlert(STR0099+alltrim(str(nQtdHr))+STR0100+alltrim(str(nTemp))+STR0101+alltrim(str(nTemp-nQtdHr))+STR0102,STR0002) //"O mínimo de Horas mês é de: "###" hr(s) e sua medição contém: "###" hr(s) sendo assim, esta faltando: "###" hrs para completar o mínimo."
		EndIf
	EndIF

	// Refazer os itens - antes mesmo da gravação
	nPonteiro := oModelFQL:GetLine() 
	cItem := "000"
	lErroCtb := .F.
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()
			cItem := soma1(cItem)
			oModelFQL:LoadValue("FQL_ITEM",cItem)
		EndIF
	Next
	oModelFQL:GoLine(nPonteiro)

Return lRet


/*/{PROTHEUS.DOC} LOCA248B3
ITUP BUSINESS - TOTVS RENTAL
Indica os campos que estarão disponíveis para edição
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B3(cCampo)
Local lRet := .F.
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")

	If cCampo == "FQK_AS" .and. lInclui
		lRet := .T.
	EndIf
	If cCampo == "FQK_GRPMD" .and. lInclui
		lRet := .T.
	EndIf
	If cCampo == "FQL_KMINI"
		If oModelFQL:GetValue("FQL_BASE") $ "HDO" .and. !LOCA248B4()
			lRet := .T.
		EndIf
	EndIf
	If cCampo == "FQL_KMFIM"
		If oModelFQL:GetValue("FQL_BASE") $ "HDO" .and. !LOCA248B4()
			lRet := .T.
		EndIf
	EndIf
Return lRet


/*/{PROTHEUS.DOC} LOCA248B4
ITUP BUSINESS - TOTVS RENTAL
Verifica se o item posicionado pertence a uma minuta
.T. = Minuta
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B4
Local lRet := .F.
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cBem := oModelFQL:GetValue("FQL_FROTA")
Local aArea := GetArea()

	ST9->(dbSetOrder(1))
	If ST9->(dbSeek(xFilial("ST9")+cBem))
		If empty(ST9->T9_STATUS)
			lRet := .T. // é uma minuta
		EndIF
	EndIF

	RestArea(aArea)
Return lRet

/*/{PROTHEUS.DOC} LOCA248B6
ITUP BUSINESS - TOTVS RENTAL
Calcula o FQL_HORTOT
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B6
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nRet := oModelFQL:GetValue("FQL_QTDKM")
Return nRet

/*/{PROTHEUS.DOC} LOCA248B7
ITUP BUSINESS - TOTVS RENTAL
Calcula o FQL_HORTOT
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B7
Local oModel := FWModelActive()
Local nRet := 0
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nRet1 := oModelFQL:GetValue("FQL_VLRFRA")
Local nRet2 := oModelFQL:GetValue("FQL_HORTOT")
Local nI
Local nTot := 0
Local nTot1 := 0
Local nPonteiro

	// Variavel para o calculo da medicao por grupo
	aCalcGrp := {} // variavel private criada no inicio do LOCA248, será usada na função LOCA24808

	nRet := nRet2 - nRet1
	If nRet < 0
		nRet := 0
	EndIf

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted() 
			nTot += oModelFQL:GetValue("FQL_QTDKM")
				
			// por calcular dentro do gatilho pego o nret que representa o calculo da linha em questão
			If nI <> nPonteiro
				nTot1 += oModelFQL:GetValue("FQL_QTDHR")
				aadd(aCalcGrp,{oModelFQL:GetValue("FQL_QTDHR")})
			Else
				nTot1 += nRet
				aadd(aCalcGrp,{nRet})
			EndIF

		EndIf  
	Next
	oModelFQL:GoLine(nPonteiro)

	//FWFldPut("FQK_QTDTOT", nTot)
	//FWFldPut("FQK_VREXCE", nTot1)

Return round(nRet, tamsx3("FQL_QTDHR")[2])

/*/{PROTHEUS.DOC} LOCA248B8
ITUP BUSINESS - TOTVS RENTAL
Calculo do FQL_KMFIM
Frank Z Fuga
21/08/2024
/*/
Function LOCA248B8(cOrigem,cDestino)
Local xRet := 0
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local dEntra
Local dSai
Local nMinDia
//Local nI
//Local cFrota
//Local nAnterior
//Local nPeriodo
//Local nInicial
//Local nPonteiro
//Local dTemp := ctod("")

	If !empty(oModelFQL:GetValue("FQL_BEMRES"))
		If cDestino == "FQL_KMFIM"
			LOCA248BLQ()
			Return oModelFQL:GetValue("FQL_KMFIM")
		EndIf
		If cDestino == "FQL_DTINIC"
			LOCA248BLQ()
			Return oModelFQL:GetValue("FQL_DTINIC")
		EndIf
		//If cDestino == "FQL_DTFIM"
		//	Return oModelFQL:GetValue("FQL_DTFIM")
		//EndIf
		If cDestino == "FQL_FROTA"
			LOCA248BLQ()
			Return oModelFQL:GetValue("FQL_FROTA")
		EndIf
	EndIF

	xRet := oModelFQL:GetValue("FQL_KMFIM")
	
	If oModelFQL:GetValue("FQL_BASE") == "H"
		dEntra := oModelFQL:GetValue("FQL_DTENT")
		dSai := oModelFQL:GetValue("FQL_DTSAID")

		If empty(dEntra)
			dEntra := M->FQK_DTFIM
		EndIf
		If empty(dSai)
			dSai := M->FQK_DTINIC
		EndIf		

		nMinDia := oModelFQL:GetValue("FQL_MINDIA")
		If !empty(dSai) .and. !empty(dEntra)
			xRet := nMinDia * ( dSai - dEntra)
		EndIf

		If xRet < 0
			xRet := 0
		EndIf

	EndIf
	If oModelFQL:GetValue("FQL_BASE") == "D"
		dEntra := oModelFQL:GetValue("FQL_DTENT")
		dSai := oModelFQL:GetValue("FQL_DTSAID")

		If empty(dEntra)
			dEntra := M->FQK_DTFIM
		EndIf
		If empty(dSai)
			dSai := M->FQK_DTINIC
		EndIf		

		If !empty(dSai) .and. !empty(dEntra)
			xRet := dSai - dEntra
		EndIf

		If xRet < 0
			xRet := 0
		EndIf

	EndIf


	// Localiza o km inicial  
	LOCA248B91()


	If alltrim(ReadVar()) == "M->FQK_DTINC"
		xRet := M->FQK_DTINC
	EndIf
	If alltrim(ReadVar()) == "M->FQK_DTFIM"
		xRet := M->FQK_DTFIM
	EndIf
	If alltrim(ReadVar()) == "M->FQL_FROTA"
		xRet := oModelFQL:GetValue("FQL_FROTA")
	EndIf

	LOCA248BLQ()

Return xRet


/*/{PROTHEUS.DOC} LOCA248A2
ITUP BUSINESS - TOTVS RENTAL
Validação da FQJ - nao permitir alterar a quantidade de meses no caso de ja ter sido usado em uma medicao
Frank Z Fuga
13/08/2024
/*/
Function LOCA248A2()
Local lRet := .T.
Local cQuery
Local aBindParam := {}
	If Altera
		If select("TRBFQJ") > 0
			TRBFQJ->(dbCloseArea())
		EndIf
		cQuery := " SELECT COUNT(*) AS TOT "
		cQuery += " FROM " + RETSQLNAME("FQK") + " FQK "
		cQuery += " WHERE FQK.D_E_L_E_T_ = '' AND FQK.FQK_PMEDI = ? "
		Aadd( aBindParam, FQJ->FQJ_CODIGO )
		cQuery := CHANGEQUERY(cQuery)
		MPSysOpenQuery(cQuery,"TRBFQJ",,,aBindParam)
		If TRBFQJ->TOT > 0
			lRet := .F.
		EndIf
		TRBFQJ->(dbCloseArea())
		/*
		cQuery := " SELECT COUNT(*) AS TOT "
		cQuery += " FROM " + RETSQLNAME("FPA") + " FPA "
		cQuery += " WHERE FPA.D_E_L_E_T_ = '' AND FPA.FPA_PMEDI = ? "
		Aadd( aBindParam, FQJ->FQJ_CODIGO )
		cQuery := CHANGEQUERY(cQuery)
		MPSysOpenQuery(cQuery,"TRBFQJ",,,aBindParam)
		If TRBFQJ->TOT > 0
			lRet := .F.
		EndIf
		TRBFQJ->(dbCloseArea())
		*/
		If !lRet
			Help( ,, "LOCA248-LOCA248A2",, STR0002, 1, 0,,,,,,{STR0065}) //"Inconsistência nos dados."###"Esta condição já foi utilizada, portanto não pode ser alterada."
		EndIF
	EndIf
Return lRet

/*/{PROTHEUS.DOC} LOCA248A3
ITUP BUSINESS - TOTVS RENTAL
Identificar a próxima sequencia (SX7 - FQK_AS e FQK_GRPMD)
Frank Z Fuga
16/08/2024
/*/
Function LOCA248A3()
Local aArea	:= getarea()
//Local cQuery
//Local cAliasTRB := GetNextAlias()
Local cSequencia := M->FQK_MEDSEQ
//Local aBindParam
Local nTemp
Local cCod
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nI
Local cgrpand
Local cAs
Local nReg
Local cSeq
Local dIni := ctod("")
Local dFim := ctod("")
Local cPer := ""

	If SBM->(FieldPos("BM_XACESS")) > 0
		cgrpand := LOCA00189()
	Else
		cgrpand := SuperGetMV("MV_LOCX014",.F.,"")
	EndIf

	If lInclui

		// Tratamento para avaliar se existe uma sequencia anterior
		If M->FQK_TPMED == "A"
			cAs := M->FQK_AS //oModelFQL:GetValue("FQL_AS")
			FQK->(dbSetOrder(2))
			FQK->(dbSeek(xFilial("FQK")+cAs))  
			cSeq := "000"
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
				If cSeq < FQK->FQK_MEDSEQ .and. FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6"
					cSeq := FQK->FQK_MEDSEQ
					dIni := FQK->FQK_DTFIM + 1
					dControl := dIni // para uso postetior na validação da data inicial
					dFim := dIni + (FQK->FQK_DTFIM - FQK->FQK_DTINIC)
					cPer := FQK->FQK_PMEDI
				EndIf
				FQK->(dbSkip())
			EndDo
		Else
			// Criar um indice futuramente por projeto
			cAs := oModelFQL:GetValue("FQL_AS")
			FQK->(dbSetOrder(6))
			FQK->(dbSeek(xFilial("FQK")+M->FQK_PROJET))
			cSeq := "000"
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL) == xFilial("FQK") .and. FQK->FQK_PROJET == M->FQK_PROJET
				If FQK->FQK_TPMED == "G" .and. FQK->FQK_GRPMD == M->FQK_GRPMD .and. FQK->FQK_SITUAC <> "6"
					If cSeq < FQK->FQK_MEDSEQ 
						cSeq := FQK->FQK_MEDSEQ
						dIni := FQK->FQK_DTFIM + 1
						dControl := dIni  // para uso postetior na validação da data inicial
						dFim := dIni + (FQK->FQK_DTFIM - FQK->FQK_DTINIC)
						cPer := FQK->FQK_PMEDI
					EndIf
				EndIf
				FQK->(dbSkip())
			EndDo
		EndIf

		//cSequencia := SOMA1( cSeq )

		If !empty(cPer)
			FWFldPut("FQK_PMEDI", cPer)
		EndIF

		If !empty(dIni) .and. !empty(dFim)
			FWFldPut("FQK_DTINIC", dIni)
		EndIf

		RestArea(aArea)

		// Sequencia feita na função LOCA248SEQ
		//M->FQK_MEDSEQ := cSequencia 
		cSequencia := M->FQK_MEDSEQ

		If M->FQK_MEDSEQ > "001"
			nReg := FQK->(Recno())
			nPonteiro := oModelFQL:GetLine()
			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted()

					// pelo fato da sequencia ser alterada depois de popular os dados vamos atualizar a FQL_ORDEM
					LOCA248LIB()
					oModelFQL:SetValue("FQL_ORDEM", cSequencia)

					cAs := oModelFQL:GetValue("FQL_AS")
					FPA->(dbSetOrder(3))
					FPA->(dbSeek(xFilial("FPA")+cAs))
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

					If !ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND)// .and. oModelFQL:GetValue("FQL_BASE") $ "HDO"

						nTemp := 0
						cCod := ""

						FQL->(dbSetOrder(6))
						FQL->(dbSeek(xFilial("FQL")+cAs))

						While !FQL->(Eof()) .and. FQL->FQL_FILIAL == xFilial("FQL") .and. FQL->FQL_AS == cAs

							FQK->(dbSetOrder(1))
							FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
							If FQK->FQK_SITUAC == "6" .or. FQK->FQK_MEDSEQ <> FQL->FQL_ORDEM
								FQL->(dbSkip())
								Loop
							EndIf

							If FQL->FQL_AS == cAs .and. FQL->FQL_BASE $ "HDO" 

								FPA->(dbSetOrder(3))
								FPA->(dbSeek(xFilial("FPA")+cAs))
								SB1->(dbSetOrder(1))
								SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

								If !alltrim(SB1->B1_GRUPO) $ alltrim(CGRPAND) .and. FQL->FQL_COD > cCod
									nTemp := FQL->FQL_KMFIM
									cCod := FQL->FQL_COD
								EndIf

							EndIf
							// Desativado para a segunda em diante
							/*
							If FQL->FQL_AS == cAs .and. FQL->FQL_BASE $ "C" 
								FPA->(dbSetOrder(3))
								FPA->(dbSeek(xFilial("FPA")+cAs))
								SB1->(dbSetOrder(1))
								SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

								If !alltrim(SB1->B1_GRUPO) $ alltrim(CGRPAND) .and. FQL->FQL_COD > cCod
									ST9->(dbSetOrder(1))
									If ST9->(dbSeek(xFilial("ST9")+FQL->FQL_FROTA))
										nTemp := ST9->T9_POSCONT
									EndIF
									cCod := FQL->FQL_COD
								EndIf
							EndIf  
							*/
							
							FQL->(dbSkip())
						EndDo

						If nTemp > 0
							//oModelFQL:SetValue("FQL_KMINI", nTemp+1)
							LOCA248LIB()
							If oModelFQL:GetValue("FQL_TPAS") <> "M"
								oModelFQL:SetValue("FQL_KMINI", nTemp)
							EndIf
							//oModelFQL:GetStruct():SetProperty("FQL_KMINI", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
						EndIF

						// Card 4132
						LOCA248LIB()
						oModelFQL:SetValue("FQL_KMFIM", 0)

					EndIf
				EndIf
			Next
			oModelFQL:GoLine(nPonteiro)
			FQK->(dbGoto(nReg))
		EndIf

		// Tratamento para excluir as linhas que já tiveram nota de devolucao
		LOCA248BG()

	EndIf

	If oModelFQL:GetValue("FQL_BASE") == "H"
		//oModelFQL:GetStruct():SetProperty("FQL_KMFIM", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
	EndIF

	// Bloquear a data de expedição se a sequencia for > 001
	If cSequencia > "001" // bloquear os campos se já foi utilizado em outra medicao trocar aqui
	//	oModelFQL:GetStruct():SetProperty("FQL_DTSAID", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
	//	oModelFQL:GetStruct():SetProperty("FQL_DTENT", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
	EndIF

	LOCA248BLQ()

Return cSequencia

/*/{PROTHEUS.DOC} LOCA248A4
ITUP BUSINESS - TOTVS RENTAL
Calculos do desconto e acrescimo no gatilho
Frank Z Fuga
16/08/2024
/*/
Function LOCA248A4(cCampo)
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nValor := oModelFQL:GetValue("FQL_VLRTOT")
Local nTemp
Local nTemp1
Local nI
Local nTotDes := 0
Local nTotAcr := 0
Local nPonteiro  

	// % do desconto
	If cCampo == "FQL_PERD"
		nTemp := oModelFQL:GetValue("FQL_PERD")
		LOCA248LIB()
		oModelFQL:SetValue("FQL_DESC",(nValor * nTemp) / 100)
	EndIf

	// Valor do desconto
	If cCampo == "FQL_DESC"
		nTemp := oModelFQL:GetValue("FQL_DESC")
		nTemp1 := nValor - nTemp
		LOCA248LIB()
		oModelFQL:SetValue("FQL_PERD",(nTemp/nvalor) * 100)
	EndIf

	// % do acréscimo
	If cCampo == "FQL_PERA"
		nTemp := oModelFQL:GetValue("FQL_PERA")
		LOCA248LIB()
		oModelFQL:SetValue("FQL_ACRES",(nValor * nTemp) / 100)
	EndIf

	// Valor do acréscimo
	If cCampo == "FQL_ACRES"
		nTemp := oModelFQL:GetValue("FQL_ACRES")
		nTemp1 := nValor - nTemp
		LOCA248LIB()
		oModelFQL:SetValue("FQL_PERA",(nTemp/nvalor) * 100)
	EndIf

	If cCampo == "TOTAL"
		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()	
				nTotDes += oModelFQL:GetValue("FQL_DESC")
				nTotAcr += oModelFQL:GetValue("FQL_ACRES")
			EndIf
		Next
		oModelFQL:GoLine(nPonteiro)

		FWFldPut("FQK_VLRDES", nTotDes)
		FWFldPut("FQK_VLRACR", nTotAcr)

		LOCA248BLQ()

		Return &(ReadVar())
	
	Else

		// Recalcula o valor total
		LOCA24808()

	EndIf

	LOCA248BLQ()

Return .T.

/*/{PROTHEUS.DOC} LOCA248A5
ITUP BUSINESS - TOTVS RENTAL
Gatilho do campo FQL_DUBASE
Frank Z Fuga
16/08/2024
/*/

Function LOCA248A5
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nAtual := oModelFQL:GetValue("FQL_QTDHR")
Local nCalc := oModelFQL:GetValue("FQL_DUBASE")
Local nRet1 := oModelFQL:GetValue("FQL_VLRFRA")
Local nRet2 := oModelFQL:GetValue("FQL_HORTOT")
Local nResult := 0
Local nTotdub := 0
Local nPonteiro
Local nI

	nAtual := nRet2 - nRet1
	nResult := nAtual + nCalc

	If nResult < 0
		nResult := 0
	EndIf

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()	
			nTotdub += oModelFQL:GetValue("FQL_DUBASE")
		EndIf
	Next
	oModelFQL:GoLine(nPonteiro)

	FWFldPut("FQK_DUBASE", nTotdub)

Return round(nResult, tamsx3("FQL_QTDHR")[2])

/*/{PROTHEUS.DOC} LOCA248A6
ITUP BUSINESS - TOTVS RENTAL
Alimenta os totalizadores no cabeçalho
O que alterar aqui deve ser replicado na função LOCA248A6X()
Frank Z Fuga
20/09/2024
/*/

Function LOCA248A6(cCampo)
Local nRet := 0
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nPonteiro
Local nQtdHR := 0
Local nVlrTot := 0
Local nExtra := 0
Local nFrete := 0
Local nMaq := 0
Local nMao := 0
Local nHorTot := 0
Local nFranq := 0
Local nQtdKm := 0
Local nI
Local nVlToHR := 0
Local nValSeg := 0
Local nValIss := 0
Local nValServ := 0
Local nSegIncr := 0
Local nValAcre := 0
Local nTot := 0
Local nMinMes := 0
Local oView := FWViewActive() 
Local aAreaFPA := FPA->(GetArea())

	If lVisual
		oModel:nOperation := 4
	EndIf
	
	oView:refresh()

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()	

			FPA->(dbSetOrder(3))
			FPA->(dbSeek(xFilial("FPA")+oModelFQL:GetValue("FQL_AS")))

			nQtdHR += oModelFQL:GetValue("FQL_QTDHR")
			nVlrTot += oModelFQL:GetValue("FQL_VLRTOT")
			nExtra += oModelFQL:GetValue("FQL_TRSPES")
			nExtra += oModelFQL:GetValue("FQL_ANCORA")
			nExtra += oModelFQL:GetValue("FQL_TELESC")
			nExtra += oModelFQL:GetValue("FQL_MONTAG")
			nExtra += oModelFQL:GetValue("FQL_DESMON")
			nExtra += oModelFQL:GetValue("FQL_ACESSO")
			nFrete += oModelFQL:GetValue("FQL_VLRMOB")
			nFrete += oModelFQL:GetValue("FQL_VLRDES")
			nMaq += oModelFQL:GetValue("FQL_VLMAQ")
			nMao += oModelFQL:GetValue("FQL_VLTOTM")
			nHorTot += oModelFQL:GetValue("FQL_HORTOT")
			nFranq += oModelFQL:GetValue("FQL_VLRFRA")
			nQtdKm += oModelFQL:GetValue("FQL_QTDKM")
			nVlToHR += oModelFQL:GetValue("FQL_VLTOHR")
			nValSeg += oModelFQL:GetValue("FQL_VALSEG")
			nValIss += oModelFQL:GetValue("FQL_VALISS")
			nValAcre += oModelFQL:GetValue("FQL_ACRES")
			nMinMes += FPA->FPA_MINMES

			If oModelFQL:GetValue("FQL_TPISS") == "I" .or. oModelFQL:GetValue("FQL_TPISS") == "X"
				nValServ += oModelFQL:GetValue("FQL_VLRTOT")
			Else
				nValServ += oModelFQL:GetValue("FQL_VLRTOT") - oModelFQL:GetValue("FQL_VALISS") 
			EndIF

			If oModelFQL:GetValue("FQL_TIPO") == "N" .or. oModelFQL:GetValue("FQL_TIPO") == " "
				nSegIncr += oModelFQL:GetValue("FQL_VALSEG")
			EndIF


		EndIf
	Next
	oModelFQL:GoLine(nPonteiro)

	FWFldPut("FQK_QTDHR", nQtdHR)
	FWFldPut("FQK_VLRTOT", nVlrTot)
	FWFldPut("FQK_VREXTR", nExtra)
	FWFldPut("FQK_VLRMOB", nFrete)
	FWFldPut("FQK_VLMAQ", nMaq)
	FWFldPut("FQK_VLTOTM", nMao)
	FWFldPut("FQK_QTDTOT", nHorTot)
	FWFldPut("FQK_VLRFRA", nFranq)
	FWFldPut("FQK_QTDKM", nQtdKm)
	FWFldPut("FQK_VALTOT", nVlToHR)
	FWFldPut("FQK_VALSEG", nValSeg)
	FWFldPut("FQK_VLAISS", nValIss)
	FWFldPut("FQK_MINMES", nMinMes)

	M->FQK_QTDHR 	:= nQtdHR
	M->FQK_VLRTOT	:= nVlrTot
	M->FQK_VREXTR	:= nExtra
	M->FQK_VLRMOB	:= nFrete
	M->FQK_VLMAQ	:= nMaq
	M->FQK_VLTOTM	:= nMao
	M->FQK_QTDTOT	:= nHorTot
	M->FQK_VLRFRA	:= nFranq
	M->FQK_QTDKM	:= nQtdKm
	M->FQK_VALTOT	:= nVlToHR
	M->FQK_VALSEG	:= nValSeg
	M->FQK_VLAISS	:= nValIss
	M->FQK_MINMES	:= nMinMes

	nTot := (nValServ + nValAcre - nSegIncr)	
	FWFldPut("FQK_VALSER", nTot )
	M->FQK_VALSER := nTot

	nRet := oModelFQL:GetValue(cCampo)
	oView:Refresh()

	If lVisual
		oModel:nOperation := 2
	EndIf

	FPA->(RestArea(aAreaFPA))

Return nRet

/*/{PROTHEUS.DOC} LOCA248A6X
ITUP BUSINESS - TOTVS RENTAL
Alimenta os totalizadores no cabeçalho
O que alterar aqui deve ser replicado na função LOCA248A6()
Frank Z Fuga
20/09/2024
/*/

Function LOCA248A6X()
Local nQtdHR := 0
Local nVlrTot := 0
Local nExtra := 0
Local nFrete := 0
Local nMaq := 0
Local nMao := 0
Local nHorTot := 0
Local nFranq := 0
Local nQtdKm := 0
Local nVlToHR := 0
Local nValSeg := 0
Local nValIss := 0
Local nValServ := 0
Local nSegIncr := 0
Local nValAcre := 0
Local nTot := 0
Local lCalc := .F.
Local nMinMes := 0

	FQL->(dbSetOrder(5))
	FQL->(dbSeek(xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)))

	While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_COD+FQL_ORDEM) == xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)

		lCalc := .T.

		FPA->(dbSetOrder(3))
		FPA->(dbSeek(xFilial("FPA")+FQL->FQL_AS))

		nQtdHR += FQL->FQL_QTDHR
		nVlrTot += FQL->FQL_VLRTOT
		nExtra += FQL->FQL_TRSPES
		nExtra += FQL->FQL_ANCORA
		nExtra += FQL->FQL_TELESC
		nExtra += FQL->FQL_MONTAG
		nExtra += FQL->FQL_DESMON
		nExtra += FQL->FQL_ACESSO
		nFrete += FQL->FQL_VLRMOB
		nFrete += FQL->FQL_VLRDES
		nMaq += FQL->FQL_VLMAQ
		nMao += FQL->FQL_VLTOTM
		nHorTot += FQL->FQL_HORTOT
		nFranq += FQL->FQL_VLRFRA
		nQtdKm += FQL->FQL_QTDKM
		nVlToHR += FQL->FQL_VLTOHR
		nValSeg += FQL->FQL_VALSEG
		nValIss += FQL->FQL_VALISS
		nValAcre += FQL->FQL_ACRES
		nMinMes += FPA->FPA_MINMES

		If FQL->FQL_TPISS == "I" .or. FQL->FQL_TPISS == "X"
			nValServ += FQL->FQL_VLRTOT
		Else
			nValServ += FQL->FQL_VLRTOT - FQL->FQL_VALISS 
		EndIF

		If FQL->FQL_TIPO == "N" .or. FQL->FQL_TIPO == " "
			nSegIncr += FQL->FQL_VALSEG
		EndIF

		FQL->(dbSkip())
	EndDo

	If lCalc 
		FQK->(RecLock("FQK"),.F.)
		FQK->FQK_QTDHR := nQtdHR
		FQK->FQK_VLRTOT := nVlrTot
		FQK->FQK_VREXTR := nExtra
		FQK->FQK_VLRMOB := nFrete
		FQK->FQK_VLMAQ := nMaq
		FQK->FQK_VLTOTM := nMao
		FQK->FQK_QTDTOT := nHorTot
		FQK->FQK_VLRFRA := nFranq
		FQK->FQK_QTDKM := nQtdKm
		FQK->FQK_VALTOT := nVlToHR
		FQK->FQK_VALSEG := nValSeg
		FQK->FQK_VLAISS := nValIss
		FQK->FQK_MINMES := nMinMes

		nTot := (nValServ + nValAcre - nSegIncr)	
		FQK->FQK_VALSER := nTot 
		FQK->(MsUnlock())
	EndIf

Return 




/*/{PROTHEUS.DOC} LOCA248A7
ITUP BUSINESS - TOTVS RENTAL
Alimenta a grid das minutas
Frank Z Fuga
24/09/2024
/*/

Function LOCA248A7(cMarca)
	Processa({||LOCA248A7P(cMarca)},STR0086) // "Aguarde... localizando os dados"
Return

/*/{PROTHEUS.DOC} LOCA248A7P
ITUP BUSINESS - TOTVS RENTAL
Alimenta a grid das minutas
Frank Z Fuga
24/09/2024
/*/

Function LOCA248A7P(cMarca)
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local oModelFPF := oModel:GetModel("FPFDETAIL")
Local oView := FWViewActive() 
Local nI
Local nPonteiro 
Local cAs
Local nX
Local aStruct := {}
Local lEdita := .F. // Se for .T. é para incluir
Local aMinuta := {}
Local aCampos := {}
Local nY
Local aManter := {}
Local aAs := {}
Local lMinuta := .F.
Local aLimpar := {}
Local lExist := .F.

	If lVisual
		oModel:nOperation := 2
	EndIf

	ProcRegua(0)

	If empty(M->FQK_DTINIC)
		Help( ,, "LOCA248-LOCA248A7P",, STR0002, 1, 0,,,,,,{STR0087}) //"Inconsistência nos dados."###"Falta informar a data inicial para o preenchimento da aba minuta."
		Return 
	Else
		If empty(M->FQK_DTFIM)
			M->FQK_DTFIM := M->FQK_DTINIC
		EndIf
	EndIf

	If !empty(oModelFQL:GetValue("FQL_AS")) 
		aadd(aAs,{oModelFQL:GetValue("FQL_AS"),oModelFQL:GetValue("FQL_TURNO")})
	EndIf

	If len(aAs) > 0
		cAs := aAs[1,1] // o primeiro registro já dá base para saber se é de minuta
		FPA->(dbSetOrder(3))
		If FPA->(dbSeek(xFilial("FPA")+cAs))
			If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
				lMinuta := .T.
			EndIf
		EndIF
	EndIf

	IncProc()
	SysRefresh()

	If lMinuta

		If lAltera .or. lVisual
			
			If M->FQK_DTINIC <> FQK->FQK_DTINIC .or. M->FQK_DTFIM <> FQK->FQK_DTFIM
				nPonteiro := oModelFPF:GetLine()
				For nI := 1 to oModelFPF:Length()
					oModelFPF:GoLine(nI)
					If !oModelFPF:IsDeleted()
						LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
						oModelFPF:DeleteLine()
					EndIF
				Next
				oModelFPF:GoLine(nPonteiro)
			EndIF

		EndIF


		aStruct := {} 
		aStruct := FWSX3Util():GetListFieldsStruct( "FPF" , .T.)
		For nX := 1 to len(aStruct)
			IncProc()
			SysRefresh()
			cCampo := GetSx3Cache(alltrim(aStruct[nX][01]),"X3_CAMPO")

			cVirtual := GetSx3Cache(alltrim(aStruct[nX][01]),"X3_CONTEXT")
			If (x3Uso(GetSx3Cache(alltrim(aStruct[nX][01]),"X3_USADO")) .and. cVirtual <> "V") 
				aadd(aCampos,{cCampo})
			EndIF
		Next  

		cAs := oModelFQL:GetValue("FQL_AS")
		
		If !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM) .and. !empty(cAs)
			FPF->(dbSetOrder(4))
			FPF->(dbSeek(xFilial("FPF")+cAs))
			While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == cAs
				FPF->(RecLock("FPF",.F.))
				FPF->FPF_FILTRO := ""
				FPF->(MsUnlock())
				FPF->(dbSkip())
			EndDo
			FPF->(dbSeek(xFilial("FPF")+cAs))
			While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == cAs
				IncProc()
				SysRefresh()
				If FPF->FPF_TURNO == oModelFQL:GetValue("FQL_TURNO")

					If (FPF->FPF_STATUS == "3" .and. (lInclui.or.lVisual) .and. empty(FPF->FPF_NROMED)) .or. ((FPF->FPF_STATUS == "3" .or. FPF->FPF_STATUS == "6") .and. !lInclui)
						//If FPF->FPF_DATA >= M->FQK_DTINIC .and. FPF->FPF_DATA <= M->FQK_DTFIM
						// Tratamento para a issue DSERLOCA-7574 - Frank em 17/07/25
						If FPF->FPF_DATA <= M->FQK_DTFIM

							If !empty(FPF->FPF_MEDSEQ) .and. !empty(FPF->FPF_NROMED)
								If FPF->FPF_MEDSEQ <> FQK->FQK_MEDSEQ .or. FPF->FPF_NROMED <> FQK->FQK_COD
									FPF->(dbSkip())
									Loop
								EndIf
							EndIF

							lExist := .F.
							nPonteiro := oModelFPF:GetLine()
							For nI := 1 to oModelFPF:Length()
								oModelFPF:GoLine(nI)
								If !oModelFPF:IsDeleted()
									If oModelFPF:GetValue("FPF_MINUTA") == FPF->FPF_MINUTA
										lExist := .T.
										exit
									EndIF
								EndIF
							Next
							oModelFPF:GoLine(nPonteiro)

							If !lExist
								aadd(aMinuta,{cAs,FPF->FPF_MINUTA,FPF->(Recno()), FPF->FPF_TURNO })
								FPF->(RecLock("FPF",.F.))
								FPF->FPF_FILTRO := cMarca
								FPF->(MsUnlock())
							EndIf

						EndIf
					EndIf
				EndIf
				FPF->(dbSkip())   
			EndDo
		EndIF  

		//If lInclui .or. lAltera

			For nX:=1 to len(aMinuta)
				IncProc()
				SysRefresh()
				FPF->(dbGoto(aMinuta[nX,3]))
				
				lEdita := .F. // Default para incluir uma linha nas minutas
				nPonteiro := oModelFPF:GetLine()
				For nI := 1 to oModelFPF:Length()
					oModelFPF:GoLine(nI)
					If !oModelFPF:IsDeleted()	
						If oModelFQL:GetValue("FQL_MINUTA") == aMinuta[nX,2]
							lEdita := .T.
						EndIF
						If empty(oModelFPF:GetValue("FPF_MINUTA"))
							lEdita := .T.
							Exit
						EndIF
					EndIF
				Next
				If !lEdita // Apenas atualizar a linha
					oModelFPF:AddLine()
					oModelFPF:GoLine(oModelFPF:Length())
				EndIf
				For nY := 1 to len(aCampos)
					LOCA248LIB()
					oModelFPF:LoadValue( aCampos[nY,1], &("FPF->"+aCampos[nY,1]) )
				Next

				oModelFPF:LoadValue( "FPF_NROMED", M->FQK_COD )
				oModelFPF:LoadValue( "FPF_MEDSEQ", M->FQK_MEDSEQ )

				// Regras do 4049
				aManter := {}
				aLimpar := {}

				oModelFPF:GoLine(nPonteiro)
			Next
		//EndIf

		oModelFPF:GoLine(1)
		oView:Refresh()

		IncProc()
		SysRefresh()

		// Calcular os totais
		CALCMIN()
		LOCA248A6("FQL_QTDHR")

	EndIf

	LOCA248BLQ()

	IncProc()
	SysRefresh()

	If lVisual
		oModel:nOperation := 1
	EndIf

Return

/*/{PROTHEUS.DOC} LOCA248BM
ITUP BUSINESS - TOTVS RENTAL
Tratamento para as minutas ao preencher a data final do cabeçalho FQK_DTFIM
Frank Z Fuga
24/09/2024
/*/
Function LOCA248BM()
	Processa({||LOCA248BM2()},STR0086) // "Aguarde... localizando os dados"
Return

/*/{PROTHEUS.DOC} LOCA248BM
ITUP BUSINESS - TOTVS RENTAL
Tratamento para as minutas ao preencher a data final do cabeçalho FQK_DTFIM
Frank Z Fuga
24/09/2024
/*/
Function LOCA248BM2()
Local lMinuta := .F.
Local nI
Local cAs
Local nPonteiro
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local oModelFPF := oModel:GetModel("FPFDETAIL")
Local oView := FWViewActive() 
Local aAs := {}
Local aItens := {}
Local nX
Local cTurno := {}
Local lTem := .F.
Local nY
Local lExist
Local cHoras
Local cTemp
//Local aTemp1 := {}
//Local aTemp2 := {}
//Local lExist := .F.

	ProcRegua(0)

	// se for inclusao
	// Verificar se é uma minuta
	// Guardar as AS
	// Limpar itens
	// Verificar AS x Turnos
	// Gerar os grids

	//If lInclui .and. !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM) 
	If !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM) 
		FPA->(dbSetOrder(3))
		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			IncProc()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()	

				//If oModelFQL:GetValue("FQL_TPAS") == "M"
				//	Loop
				//EndIf

				If !empty(oModelFQL:GetValue("FQL_AS"))
					cAs := oModelFQL:GetValue("FQL_AS")
					If FPA->(dbSeek(xFilial("FPA")+cAs))
						If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
							lMinuta := .T.
							Exit
						EndIf
					EndIf	
				EndIf
			EndIf
		Next
		oModelFQL:GoLine(nPonteiro)

		If lMinuta

			nPonteiro := oModelFQL:GetLine()
			For nI := 1 to oModelFQL:Length()
				IncProc()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted()	

					//If oModelFQL:GetValue("FQL_TPAS") == "M"
					//	Loop
					//EndIf

					If empty(oModelFQL:GetValue("FQL_BEMRES"))
						lTem := .F.
						For nY := 1 to len(aAs)
							IncProc()
							If aAs[nY,1] == oModelFQL:GetValue("FQL_AS")
								lTem := .T.
								Exit
							EndIf
						Next
						If !lTem
							aadd(aAs,{oModelFQL:GetValue("FQL_AS")})
						EndIf
					EndIf
				EndIf
			Next
			oModelFQL:GoLine(nPonteiro)

			// Refazer o grid de itens e da medição
			If lInclui //.or. lAltera
				oModelFQL:ClearData()
				oModelFPF:ClearData()
			EndIf

			If lAltera

				nPonteiro := oModelFPF:GetLine()
				For nI := 1 to oModelFPF:Length()
					oModelFPF:GoLine(nI)
					If !oModelFPF:IsDeleted()
						LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
						oModelFPF:DeleteLine()
					EndIF
				Next
				oModelFPF:GoLine(nPonteiro)

				nPonteiro := oModelFQL:GetLine()
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If !oModelFQL:IsDeleted()
						LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
						oModelFQL:DeleteLine()
					EndIF
				Next
				oModelFQL:GoLine(nPonteiro)

			EndIf
			
			oView:Refresh()

			aItens := {}
			For nX := 1 to len(aAs)			
				IncProc()
				FPF->(dbSetOrder(4))
				FPF->(dbSeek(xFilial("FPF")+aAs[nX,1]))
				cTurno := ""
				While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == aAs[nX,1]

					If lAltera
						If FPF->FPF_NROMED <> M->FQK_COD
							FPF->(dbSkip())
							Loop
						EndIf
					EndIf

					If FPF->FPF_STATUS == "3" .or. (lAltera .and. FPF->FPF_STATUS == "6")
						If FPF->FPF_DATA <= M->FQK_DTFIM

							lExist := .F.
							For nY := 1 to len(aItens)
								If aItens[nY,1] == FPF->FPF_AS .and. aItens[nY,2] == FPF->FPF_TURNO
									lExist := .T.  
									Exit
								EndIf
							Next
							If !lExist
								aadd(aItens,{FPF->FPF_AS, FPF->FPF_TURNO, ""})
							EndIf

						EndIf
					EndIf
					FPF->(dbSkip())
				EndDo
			Next

			If len(aItens) == 0 
				MSgAlert(STR0098,STR0038) //"Não foram localizadas minutas para o período informado."###"Atenção!"
			EndIf

			aItens := aSort(aItens,,,{|x,y| x[1]+x[2] < y[1]+y[2]})

			if lInclui
				For nX := 1 to len(aItens)
					IncProc()
					If nX == 1
						// posicao, as, turno
						LOCA248BM1(nX,aItens[nX,1],aItens[nX,2])
					Else
						oModelFQL:AddLine()
						LOCA248BM1(nX,aItens[nX,1],aItens[nX,2])
					EndIf
				Next
			Else
				// na alteração verificar se por questão da alteração do período existe um novo item
				For nX := 1 to len(aItens)
					IncProc()
					nPonteiro := oModelFQL:GetLine()
					lExist := .F.
					For nI := 1 to oModelFQL:Length()
						IncProc()
						oModelFQL:GoLine(nI)
						If !oModelFQL:IsDeleted()	

							//If oModelFQL:GetValue("FQL_TPAS") == "M"
							//	Loop
							//EndIf

							If oModelFQL:GetValue("FQL_AS")	== aItens[nX,1]	.and. oModelFQL:GetValue("FQL_TURNO") == aItens[nX,2]
								lExist := .T.
							EndIf
						EndIf
					Next
					If !lExist
						aItens[nX,3] := "X"
					EndIf
					oModelFQL:GoLine(nPonteiro)
				Next  

				// Na alteração se existir um item novo por questão da alteração do período incluir aqui
				For nX := 1 to len(aItens)
					If aItens[nX,3] == "X"
						oModelFQL:AddLine()
						LOCA248BM1(oModelFQL:Length(),aItens[nX,1],aItens[nX,2])
					EndIf
				Next

			EndIf

			// Calculo das horas paradas
			nPonteiro := oModelFQL:GetLine()
			For nI := 1 to oModelFQL:Length()
				IncProc()
				cHoras := "00:00"
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted()	

					//If oModelFQL:GetValue("FQL_TPAS") == "M"
					//	Loop
					//EndIf

					cAs := oModelFQL:GetValue("FQL_AS")
					If !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM) .and. !empty(cAs)
						cHoras := "00:00"
						FPF->(dbSetOrder(4))
						FPF->(dbSeek(xFilial("FPF")+cAs))
						While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == cAs
							IncProc()
							If FPF->FPF_TURNO == oModelFQL:GetValue("FQL_TURNO")

								If lAltera
									If FPF->FPF_NROMED <> M->FQK_COD
										FPF->(dbSkip())
										Loop
									EndIf
								EndIf

								If FPF->FPF_STATUS == "3" .or. (lAltera .and. FPF->FPF_STATUS == "6")

									If FPF->FPF_DATA <= M->FQK_DTFIM
										If empty(FPF->FPF_HRPARA)
											cTemp := "00:00"
										Else
											cTemp := substr(FPF->FPF_HRPARA,1,2)+":"+substr(FPF->FPF_HRPARA,3,2)
										EndIf
										cHoras := strzero(SomaHoras(cHoras, cTemp),6,2)
										cHoras := StrTran(cHoras,".",":")
									EndIf
								EndIf
							EndIf
							FPF->(dbSkip())
						EndDo
						LOCA248LIB()
						oModelFQL:SetValue("FQL_HRPARA",cHoras)
					EndIf
				EndIf
			Next
			oModelFQL:GoLine(nPonteiro)

			// Calcular os totais
			CALCMIN()

			oModelFQL:GoLine(1)

			oView:Refresh()
			IncProc()

		EndIf
	EndIf

	LOCA248BLQ()

Return


/*/{PROTHEUS.DOC} LOCA248BM1
ITUP BUSINESS - TOTVS RENTAL
Preencher as linhas na grid quando for do tipo Grupo
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BM1(nX, cAs, cTurno) 
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
//Local cTes := SuperGetMv("MV_LOCX186",,"") 

	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+cAs))

	oModelFQL:GoLine(nX)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_AS", cAs)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_TURNO", cTurno)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_GRPMD", FPA->FPA_GRUPOM)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_COD", M->FQK_COD)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_ORDEM", M->FQK_MEDSEQ)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_BASE", FPA->FPA_TIPOCA)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_BFRANQ", FPA->FPA_BASFRA)
	//LOCA248LIB()
	//oModelFQL:SetValue("FQL_TES", cTes)

	LOCA248BLQ()

Return 

/*/{PROTHEUS.DOC} CALCMIN
ITUP BUSINESS - TOTVS RENTAL
Calcular os itens pelas minutas associadas
Frank Z Fuga
12/08/2024
/*/

Static function CALCMIN()
Local nI
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cAs
Local cTurno
Local cHortot := "00:00"
Local nHorTot := 0
Local cQtdHr := "00:00"
Local nQtdHr := 0
Local cHrPara := "00:00"
Local nHrPara := 0
Local nValor := 0
Local cTemp1
Local lTem := .F.
Local nPonteiro := oModelFQL:GetLine()

	For nI := 1 to oModelFQL:Length()
		IncProc()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()	
			cAs := oModelFQL:GetValue("FQL_AS")
			cTurno := oModelFQL:GetValue("FQL_TURNO") 

			// Calcular pelas minutas

			cHortot := "00:00"
			nHorTot := 0
			cQtdHr := "00:00"
			nQtdHr := 0
			cHrPara := "00:00"
			nHrPara := 0
			nValor := 0

			FPF->(dbSetOrder(4))
			FPF->(dbSeek(xFilial("FPF")+cAs))
			While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == cAs
				IncProc()

				If lAltera .or. lVisual
					If FPF->FPF_NROMED <> M->FQK_COD .and. !empty(FPF->FPF_NROMED) //.and. FWIsInCallStack("LOCA24818"))
						FPF->(dbSkip())
						Loop
					EndIf
				EndIf

				//If FPF->FPF_STATUS == "3" .or. (lAltera .or. lVisual .and. (FPF->FPF_STATUS == "6" ))
				If (FPF->FPF_STATUS == "3" .and. (lInclui.or.lVisual) .and. empty(FPF->FPF_NROMED)) .or. ((FPF->FPF_STATUS == "3" .or. FPF->FPF_STATUS == "6") .and. !lInclui)
					If FPF->FPF_DATA <= M->FQK_DTFIM
						If FPF->FPF_TURNO == cTurno
							// Colocar o cálculo dos totais
							If empty(FPF->FPF_HTB)
								cTemp1 := "00:00"
							Else
								cTemp1 := substr(FPF->FPF_HTB,1,2)+":"+substr(FPF->FPF_HTB,3,2)
							EndIF
							nHortot += SomaHoras(cHorTot, cTemp1)
							If empty(FPF->FPF_HTR)
								cTemp1 := "00:00"
							Else
								cTemp1 := substr(FPF->FPF_HTR,1,2)+":"+substr(FPF->FPF_HTR,3,2)
							EndIF
							nQtdHR += SomaHoras(cQtdHr,cTemp1)
							If empty(FPF->FPF_HRPARA)
								cTemp1 := "00:00"
							Else
								cTemp1 := substr(FPF->FPF_HRPARA,1,2)+":"+substr(FPF->FPF_HRPARA,3,2)
							EndIF
							nHrPara := SomaHoras(cHrPara,FPF->FPF_HRPARA)
						EndIF
					EndIf
				EndIf
				FPF->(dbSkip())
			EndDo

			nValor := 0
			FPA->(dbSetOrder(3))
			FPA->(dbSeek(xFilial("FPA")+cAs))
			FPE->(dbSetOrder(2))
			FPE->(dbSeek(xFilial("FPE")+FPA->FPA_PROJET))
			lTem := .F.
			While !FPE->(Eof()) .and. FPE->(FPE_FILIAL+FPE_PROJET) == xFilial("FPE")+FPA->FPA_PROJET
				If FPE->FPE_OBRA == FPA->FPA_OBRA .and. FPE->FPE_SEQGUI == FPA->FPA_SEQGRU
					If FPE->FPE_TURNO == cTurno
						lTem := .T.
						nValor := FPE->FPE_VROPER
						Exit
					EndIF
				EndIF
				FPE->(dbSkip())
			EndDo

			If !lTem
				nValor := FPA->FPA_VRHOR
			EndIF			

			LOCA248LIB()
			oModelFQL:SetValue("FQL_HORTOT", nHorTot) 
			LOCA248LIB()
			oModelFQL:SetValue("FQL_QTDHR" , nQtdHR) 
			LOCA248LIB()
			oModelFQL:SetValue("FQL_HRPARA", nHrPara) 
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALHOR", nValor) 

		EndIF
	Next

	oModelFQL:GoLine(nPonteiro)

	LOCA248BLQ()

Return

/*/{PROTHEUS.DOC} LOCA248BM4
ITUP BUSINESS - TOTVS RENTAL
Validação do campo FQL_DTSAID
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BM4() 
Local lRet := .T.
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")

	If !empty(oModelFQL:GetValue("FQL_DTSAID"))
		If oModelFQL:GetValue("FQL_DTSAID") < M->FQK_DTINIC .or. oModelFQL:GetValue("FQL_DTSAID") > M->FQK_DTFIM //.and. empty(oModelFQL:GetValue("FQL_BEMRES"))
			If !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM)
				lRet := .F.
				Help( ,, "LOCA248-LOCA248BM4",, STR0002, 1, 0,,,,,,{STR0090}) //"Inconsistência nos dados."###"A data da expedição deve estar compreendida entre a data inicial e final da medição."
			EndIf
		EndIF
	EndIf

Return lRet


/*/{PROTHEUS.DOC} LOCA248BD
ITUP BUSINESS - TOTVS RENTAL
Identifica se a data da expedição terá inicializador padrão
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BD(dData) 
Local lRet := .T.
Local cMedicao
Local cSeq
Local cAs
Local aAreaFQK := FQK->(GetArea())
LOCAl aAreaFQL := FQL->(GetArea())
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cTipoSai := SuperGetMV("MV_LOCX311",,"DT.INICIO")

	/*
	1 - só trazer se em uma medição anterior não houve a data da expecição usada
	2 - se não foi utilizada em uma medição anterior, só trazer se a data da remessa estiver contida no período inicial e final
	*/

	cMedicao := M->FQK_COD
	cSeq := M->FQK_MEDSEQ
	cAs := oModelFQL:GetValue("FQL_AS")

	If cTipoSai <> "DT.INICIO" 
		FQL->(dbSetOrder(6))
		FQL->(dbSeek(xFilial("FQL")+cAs))
		While !FQL->(Eof()) .and. FQL->FQL_FILIAL == xFilial("FQL") .and. FQL->FQL_AS == cAs
			If FQL->FQL_AS == cAs .and. !empty(FQL->FQL_DTSAID) .and. FQL->FQL_ORDEM < cSeq
				lRet := .F.
				Exit
			EndIf
			FQL->(dbSkip())
		EndDo
	EndIf

	If lRet
		If dData < M->FQK_DTINIC .or. dData > M->FQK_DTFIM .or. empty(M->FQK_DTINIC) .or. empty(M->FQK_DTFIM)
			lRet := .F.
		EndIf
	EndIf


	If empty(dData)
		lRet := .T.
	EndIf

	RestArea(aAreaFQL)
	RestArea(aAreaFQK)

Return lRet


/*/{PROTHEUS.DOC} LOCA248BE
ITUP BUSINESS - TOTVS RENTAL
Forcar os gatilhos do campo FQL_FRKM
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BE
	Processa({|| xRet := LOCA248BEX()},STR0152) // "Aguarde... Avaliando a franquia"
Return


/*/{PROTHEUS.DOC} LOCA248BEX
ITUP BUSINESS - TOTVS RENTAL
Forcar os gatilhos do campo FQL_FRKM
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BEX
Local nPonteiro
Local nI
Local oView := FWViewActive() 
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nOld 

	ProcRegua(oModelFQL:Length())

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()

		IncProc(STR0145+alltrim(str(nI))+STR0146+alltrim(str(oModelFQL:Length()))) //"Processo: "###" de: "
		SysRefresh()

		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()
			nOld := oModelFQL:GetValue("FQL_FRKM")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_FRKM",  0 )
			LOCA248LIB()
			oModelFQL:SetValue("FQL_FRKM",  nOld )
		EndIF
	Next
	oModelFQL:GoLine(nPonteiro)
	oView:Refresh()

	LOCA248BLQ()

Return 

/*/{PROTHEUS.DOC} LOCA248BF
ITUP BUSINESS - TOTVS RENTAL
Validacao da FQL_DTSAID e FQL_DTENT
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BF(cCampo)
Local lRet := .T.
Local cAs
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")

	If M->FQK_MEDSEQ > "001"  

		// A linha que estou digitando se estiver em uma medição anterior não permitir
		cAs := oModelFQL:GetValue("FQL_AS")

		FQL->(dbSetOrder(6))
		FQL->(dbSeek(xFilial("FQL")+cAs))
		While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS) == xFilial("FQL")+cAs

			FQK->(dbSetOrder(1))
			FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
			If FQK->FQK_SITUAC == "6"
				FQL->(dbSkip())
				Loop
			EndIf

			If cCampo == "FQL_DTSAID"
				If !empty(FQL->FQL_DTSAID) .and. FQL->FQL_ORDEM < M->FQK_MEDSEQ .and. FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES") 
					lRet := .F.
					Exit
				EndIf
			EndIF
			If cCampo == "FQL_DTENT"
				If !empty(FQL->FQL_DTENT) .and. FQL->FQL_ORDEM < M->FQK_MEDSEQ .and. FQL->FQL_BEMRES == oModelFQL:GetValue("FQL_BEMRES") 
					lRet := .F.
					Exit
				EndIf
			EndIF
			FQL->(dbSkip())
		EndDo

	EndIF

	If !lRet
		Help( ,, "LOCA248-LOCA248BF",, STR0002, 1, 0,,,,,,{STR0103}) //"Inconsistência nos dados."###"Já foi lançada a data em uma medição anterior."
	EndIF

Return lRet 


/*/{PROTHEUS.DOC} LOCA248BG 
ITUP BUSINESS - TOTVS RENTAL
Deleta as linhas que tiveram retornos em medicoes anteriores
Frank Z Fuga
12/08/2024
/*/

Function LOCA248BG()
Local nPonteiro
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nI
Local cProjeto
Local cGrupoMed
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local cAs
Local lDeletar := .F.

	nPonteiro := oModelFQL:GetLine()
	For nI := 1 to oModelFQL:Length()
		oModelFQL:GoLine(nI)
		If !oModelFQL:IsDeleted()

			// Deletar as linhas que a expedição não esteja dentro do período da medicao
			If (oModelFQL:GetValue("FQL_DTSAID") < M->FQK_DTINIC .or. oModelFQL:GetValue("FQL_DTSAID") > M->FQK_DTFIM) .and. !empty(oModelFQL:GetValue("FQL_DTSAID"))
				LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
				oModelFQL:DeleteLine()
				Loop
			EndIf

			// Deletar as linhas que a expedição não esteja dentro do período da medicao
			If !empty(oModelFQL:GetValue("FQL_DTENT")) .and. oModelFQL:GetValue("FQL_DTENT") < M->FQK_DTINIC
				LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
				oModelFQL:DeleteLine()
				Loop
			EndIf

			If M->FQK_TPMED == "A"
				lDeletar := .F.
				cAs := M->FQK_AS
				FQK->(dbSetOrder(2))
				FQK->(dbSeek(xFilial("FQK")+cAs))
				While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
					If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
						FQL->(dbSetOrder(6))
						If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
							While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS+FQL_COD+FQL_ORDEM) == xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)
								If !empty(FQL->FQL_DTENT) .and. oModelFQL:GetValue("FQL_BEMRES") == FQL->FQL_BEMRES
									lDeletar := .T.
								Else
									If !empty(FQL->FQL_DTENT) .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
										FQF->(dbSetOrder(1))
										FQF->(dbSeek(xFilial("FQF")+oModelFQL:GetValue("FQL_BEMRES")))
										cSequencia := FQF->FQF_SEQ
										cSaida := ""
										FQF->(dbSetOrder(2))
										FQF->(dbSeek(xFilial("FQF")+cSequencia))
										While !FQF->(Eof()) .and. FQF->FQF_SEQ == cSequencia
											If FQF->FQF_COD <> oModelFQL:GetValue("FQL_BEMRES")
												cSaida := FQF->FQF_COD
											EndIF
											FQF->(dbSkip())
										EndDo
										If cSaida == FQL->FQL_BEMRES
											lDeletar := .T.
										EndIF
									EndIF
								EndIf
								FQL->(dbSkip())
							EndDo
						EndIf
					EndIf
					FQK->(dbSkip()) 
				EndDo
				If lDeletar
					LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
					oModelFQL:DeleteLine()								
				EndIF
			Else
				// Em grupo a FPA já está posicionada neste momento
				cProjeto := FPA->FPA_PROJET
				cGrupoMed := M->FQK_GRPMD
				cAs :=  oModelFQL:GetValue("FQL_AS") 
				FQL->(dbSetOrder(6))
				FQL->(dbSeek(xFilial("FQL")+cAs))
				lDeletar := .F.
				While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
					FQK->(dbSetOrder(1))
					If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
						If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
							If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed
								If !empty(FQL->FQL_DTENT) .and. oModelFQL:GetValue("FQL_BEMRES") == FQL->FQL_BEMRES
									lDeletar := .T.
								Else
									If !empty(FQL->FQL_DTENT) .and. !empty(oModelFQL:GetValue("FQL_BEMRES"))
										FQF->(dbSetOrder(1))
										FQF->(dbSeek(xFilial("FQF")+oModelFQL:GetValue("FQL_BEMRES")))
										cSequencia := FQF->FQF_SEQ
										cSaida := ""
										FQF->(dbSetOrder(2))
										FQF->(dbSeek(xFilial("FQF")+cSequencia))
										While !FQF->(Eof()) .and. FQF->FQF_SEQ == cSequencia
											If FQF->FQF_COD <> oModelFQL:GetValue("FQL_BEMRES")
												cSaida := FQF->FQF_COD
											EndIF
											FQF->(dbSkip())
										EndDo
										If cSaida == FQL->FQL_BEMRES
											lDeletar := .T.
										EndIF
									EndIF
								EndIf
							EndIf
						EndIf
					EndIf
					FQL->(dbSkip())
				EndDo
				If lDeletar
					LOCA248DEL() // Tratamento para o campo FQL_COMPLE X Bem reserva
					oModelFQL:DeleteLine()								
				EndIF
			EndIF

		EndIf
	Next
	oModelFQL:GoLine(nPonteiro)

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))

Return .T.

/*/{PROTHEUS.DOC} LOCA248LIB
ITUP BUSINESS - TOTVS RENTAL
Libera os campos para digitação
Frank Z Fuga
29/10/2024
/*/

Function LOCA248LIB()
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local oModelFQK := oModel:GetModel("FQKMASTER")
Local nX
Local cCampo

	For nX := 1 to len(aBlqFQK)
		cCampo := aBlqFQK[nX,1]
		oModelFQK:GetStruct():SetProperty(cCampo, MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
	Next

	For nX := 1 to len(aBlqFQL)
		cCampo := aBlqFQL[nX,1]
		oModelFQL:GetStruct():SetProperty(cCampo, MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
	Next

Return .T.

/*/{PROTHEUS.DOC} LOCA248BLQ
ITUP BUSINESS - TOTVS RENTAL
Bloqueia os campos para digitação
Frank Z Fuga
29/10/2024
/*/

Function LOCA248BLQ()
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local oModelFQK := oModel:GetModel("FQKMASTER")
Local nX

	For nX := 1 to len(aBlqFQK)
		cCampo := aBlqFQK[nX,1]
		oModelFQK:GetStruct():SetProperty(cCampo, MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , aBlqFQK[nX,2]))
	Next

	For nX := 1 to len(aBlqFQL)
		cCampo := aBlqFQL[nX,1]
		oModelFQL:GetStruct():SetProperty(cCampo, MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , aBlqFQL[nX,2]))
	Next

Return .T.


/*/{PROTHEUS.DOC} LOCA248DEL
ITUP BUSINESS - TOTVS RENTAL
Limpar o campo FQL_COMPLE ao deletar uma linha
Frank Z Fuga
29/10/2024
/*/

Function LOCA248DEL()
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nPonteiro
Local nY
Local cAs

	If !empty(oModelFQL:GetValue("FQL_BEMRES"))
		cAs := oModelFQL:GetValue("FQL_AS")
		nPonteiro := oModelFQL:GetLine()
		For nY := 1 to oModelFQL:Length()
			IncProc()
			oModelFQL:GoLine(nY)
			If !oModelFQL:IsDeleted()
				If empty(oModelFQL:GetValue("FQL_BEMRES")) .and. oModelFQL:GetValue("FQL_AS") == cAs
					LOCA248LIB()
					oModelFQL:SetValue("FQL_COMPLE",0)
				EndIf
			EndIF
		Next
		oModelFQL:GoLine(nPonteiro)
	EndIf

	LOCA248BLQ()

Return .T.


