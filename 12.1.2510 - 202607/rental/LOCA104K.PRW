#INCLUDE "LOCA104K.CH"
#INCLUDE "TOTVS.CH"
#include "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#Include "TBICONN.CH"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} LOCA104K
Retorno de produtos FIFO
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Function LOCA104K()
	Processa({|| LOCA104K1() }, STR0004) //"Aguarde... Localizando os itens a serem devolvidos."
Return .T.


/*/{Protheus.doc} LOCA104K1
Retorno de produtos FIFO
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Function LOCA104K1()
Local oModel := FwModelActive()
Local oGrid  := oModel:GetModel("GRID")
Local nX
Local nY
Local cGrpand
Local cProduto
Local aTemp := {}
Local nQuant
Local nDevol
Local aProduto
Local lRet := .F.
Local bLinePro := {|| LOCA104K2() }
Local oOk := LOADBITMAP( GETRESOURCES(), "LBOK")
Local oNo := LOADBITMAP( GETRESOURCES(), "LBNO")
Local oPesqEv
Local cPesq := space(30)

Private oDlgSel
Private oLstPro

	// Neste caso estamos localizando apenas o tipo 1 do BM_XACESS
	If SBM->(fieldpos("BM_XACESS")) > 0
		cGrpand := LOCA00189()
	Else
		cGrpand := supergetmv("MV_LOCX014",.F.,"")
	EndIf

	ProcRegua(oGrid:Length())

	For nX := 1 to oGrid:Length()
		IncProc( STR0002 + alltrim(str(nX)) + STR0003 + alltrim( str( oGrid:Length() ) ) ) //"Processo: "###" de: "
		SysRefresh()
		oGrid:GoLine(nX)
		If !oGrid:IsDeleted()
		
			cProduto := oGrid:GetValue("FPA_PRODUT")
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+cProduto))

			If alltrim(SB1->B1_GRUPO) $ alltrim(CGRPAND)

				nQuant := oGrid:GetValue("FPA_QUANT")
				nDevol := oGrid:GetValue("QTDNEW")
				aadd(aTemp,{.F., cProduto, SB1->B1_DESC, nQuant, nDevol })

			EndIf

		EndIf
	Next

    If len(aTemp) > 0

        aProduto := {}
        For nX := 1 to len(aTemp)
            lTem := .F.
            For nY := 1 to len(aProduto)
                If aProduto[nY,2] == aTemp[nX,2]
                    lTem := .T.
                    Exit
                EndIf
            Next
            If !lTem
                aadd(aProduto,{.F., aTemp[nX,2], aTemp[nX,3], aTemp[nX,4], aTemp[nX,5], 0 })
            Else
                aProduto[nY,4] += aTemp[nX,4]
                aProduto[nY,5] += aTemp[nX,5]
            EndIf
        Next

		For nX := 1 to len(aProduto)
			aProduto[nX,6] := aProduto[nX,4] - aProduto[nX,5]
		Next

        DEFINE MSDIALOG oDlgSel TITLE STR0001 FROM 0,0 TO 400,790 PIXEL //"Retorno de locação FIFO"

		@ 010,005 MsGet oPesqEv Var cPesq Size 339,009 pixel of oDlgSel
		@ 009,347 Button STR0012 Size 043,012 pixel of oDlgSel Action LOCA104K3(cPesq) //Pesquisar

		@ 25,05 LISTBOX oLstPro FIELDS HEADER "", STR0005, STR0013, STR0006, STR0007 SIZE 387,150 OF oDlgSel PIXEL // "Produto"###"Descrição"###"Enviado"###"Retornado"

		oLstPro:bLDblClick := bLinePro

		oLstPro:SetArray(aProduto)
		oLstPro:bLine := {|| { If( aProduto[oLstPro:nAt,01],oOk,oNo),;
								   aProduto[oLstPro:nAt,02],;
								   aProduto[oLstPro:nAt,03],;
								   aProduto[oLstPro:nAt,04],;
								   aProduto[oLstPro:nAt,05]}}
		oLstPro:Refresh()

		@ 180,003 Button STR0008 Size 046,012 PIXEL OF oDlgSel Action LOCA104K4() //"Informar"
        @ 180,050 Button STR0011 Size 046,012 PIXEL OF oDlgSel Action LOCA104K6(oLstPro:aArray) //"Imprimir"
		@ 180,097 Button STR0009 Size 046,012 PIXEL OF oDlgSel Action (lRet := .F., oDlgSel:End()) //"Cancelar"
        @ 180,144 Button STR0010 Size 046,012 PIXEL OF oDlgSel Action (lRet := .T., oDlgSel:End()) //"Confirmar"


		ACTIVATE MSDIALOG oDlgSel CENTERED

        If lRet
			For nX := 1 to len(aProduto)
				If aProduto[nX,1]
					For nY := 1 to oGrid:Length()
						oGrid:GoLine(nY)
						If !oGrid:IsDeleted()
							If oGrid:GetValue("FPA_PRODUT") == aProduto[nX][2]
								If oGrid:GetValue("FPA_QUANT") > 0

									If aProduto[nX,5] > 0
										oGrid:SetValue("MARK", .T.)
										
										If aProduto[nX,5] <= oGrid:GetValue("FPA_QUANT")
											oGrid:SetValue("QTDNEW", aProduto[nX,5]  )	
											aProduto[nX,5] := 0
										Else
											oGrid:SetValue("QTDNEW", oGrid:GetValue("FPA_QUANT"))	
											aProduto[nX,5] := aProduto[nX,5] - oGrid:GetValue("FPA_QUANT")
										EndIf
										
									EndIf

								EndIf
							EndIf
						EndIf

					Next
				EndIF
			Next
			FWAlertInfo(STR0023, STR0024) //"Processo concluído com sucesso."###"Retorno FIFO."
        EndIf

    EndIf

	oGrid:GoLine(1)

Return

/*/{Protheus.doc} LOCA104K2
Controle na marcação dos registros na listbox
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Static Function LOCA104K2
	oLstPro:aArray[oLstPro:NAT][1] := !oLstPro:aArray[oLstPro:NAT][1]

	If oLstPro:aArray[oLstPro:NAT][1]
		If oLstPro:aArray[oLstPro:NAT][5] == 0
			oLstPro:aArray[oLstPro:NAT][5] := oLstPro:aArray[oLstPro:NAT][4]
		EndIf
	Else
		oLstPro:aArray[oLstPro:NAT][5] := 0
	EndIf

	oLstPro:Refresh()
Return 

/*/{Protheus.doc} LOCA104K3
Rotina para pesquisar por palavra chave na listbox
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Static Function LOCA104K3(cPesq)
Local nX
Local nY
Local nTamArray	:= len(oLstPro:aArray)
Local lAchou := .F.
Local nPont1 := 0
Local nPont2 := 0

	If empty(cPesq)
		MsgAlert(STR0014,STR0015) // "Favor informar o que deseja pesquisar " ##### "Atenção!"
		oLstPro:nAt := 1
		oLstPro:Refresh()
	Else
		For nX := 1 to nTamArray
			For nY := 1 to 5
				If upper(alltrim(cPesq)) $ upper(alltrim(oLstPro:aArray[nX,nY])) .and. !lAchou .and. nX >= oLstPro:nAt
					lAchou := .T.
					nPont1 := nX 
				EndIf
				If upper(alltrim(cPesq)) $ upper(alltrim(oLstPro:aArray[nX,nY])) .and. !lAchou .and. nPont1 == 0
					lAchou := .T.
					nPont2 := nX // da primeira linha em diante
				EndIf
			Next nY
		Next nx

		If !lAchou
			MsgAlert(STR0016,STR0015) // "Não localizado." ####  "Atenção!"
			oLstPro:nAt := 1
			oLstPro:Refresh()
		Else
			If nPont1 > 0 // a preferencia da pesquisa é da linha posicionada para baixo
				oLstPro:nAt := nPont1
				oLstPro:Refresh()
			Else
				If nPont2 > 0 // se não localizar da linha posicionada, pesquisar desde a primeira linha
					oLstPro:nAt := nPont2
					oLstPro:Refresh()
				EndIF
			EndIF
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} LOCA104K4
Informar a quantidade a ser devolvida
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Static Function LOCA104K4
Local oVar1 
Local oVar2
Local oVar3
Local oVar4
Local cProduto := oLstPro:aArray[oLstPro:NAT][2]
Local cDesc := oLstPro:aArray[oLstPro:NAT][3]

Private nPendente := oLstPro:aArray[oLstPro:NAT][4]
Private nDevol := oLstPro:aArray[oLstPro:NAT][5]
Private oDlgInf

	DEFINE MSDIALOG oDlgInf TITLE STR0017 FROM 0,0 TO 200,590 PIXEL //"Informe a quantidade a ser devolvida."

	//@ 05,30 MSGET oVar1 var cProduto SIZE 45,8 PIXEL OF oDlgInf PICTURE "@E 999999,999.99"  WHEN FWHEN(.F.)
	
	@ 32,05 SAY STR0018 SIZE 80,8 PIXEL OF oDlgInf //"Produto: "
	@ 30,35 MSGET oVar1 var cProduto SIZE 100,8 PIXEL OF oDlgInf WHEN .F.

	@ 44,05 SAY STR0019 SIZE 80,8 PIXEL OF oDlgInf //"Descrição: "
	@ 42,35 MSGET oVar2 var cDesc SIZE 160,8 PIXEL OF oDlgInf WHEN .F.

	@ 56,05 SAY STR0020 SIZE 80,8 PIXEL OF oDlgInf //"A retornar: "
	@ 54,35 MSGET oVar3 var nPendente SIZE 70,8 PIXEL OF oDlgInf PICTURE "@E 999,999,999.99" WHEN .F.

	@ 68,05 SAY STR0021 SIZE 80,8 PIXEL OF oDlgInf //"Devolver: "
	@ 66,35 MSGET oVar4 var nDevol SIZE 70,8 PIXEL OF oDlgInf PICTURE "@E 999,999,999.99" 

	ACTIVATE MSDIALOG oDlgInf CENTERED ON INIT ENCHOICEBAR(oDlgInf, {|| If(LOCA104K5(),oDlgInf:END(),.F.)} , {|| oDlgInf:END()} , , )

Return

/*/{Protheus.doc} LOCA104K5
Validação das informações lançadas
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Static Function LOCA104K5
Local lRet := .T.
	If nPendente < nDevol
		MsgAlert(STR0022,STR0015) //"A quantidade informada é maior do que a devida. "###"Atenção!"
		lRet := .F.
	Else
		oLstPro:aArray[oLstPro:NAT][5] := nDevol
		oLstPro:aArray[oLstPro:NAT][1] := .T.
	EndIf
Return lRet


/*/{Protheus.doc} LOCA104K6
Impressão
@type function
@author Frank Zwarg Fuga
@since 29/04/2026
/*/
Function LOCA104K6(aProdutox)
Local oReport   
Local oSection  

    oReport := TReport():New("LOCA104K6", STR0025, , {|oRpt| PrintReport(oRpt, aProdutox)}, STR0025) //"Relatório de itens a serem devolvidos"

    oReport:SetLandscape(.F.)  // Retrato

    oSection := TRSection():New(oReport, STR0026) // "Produtos"

    TRCell():New(oSection, "CODPROD", ,STR0027, , 10) //"Código"
    TRCell():New(oSection, "DESPROD", ,STR0028, , 40) //"Descrição"
    TRCell():New(oSection, "QTDDEV", ,STR0029, , 15) //"Qtd. a devolver"
    TRCell():New(oSection, "QTDINF" , ,STR0030, , 15) //"Qtd. Informada"

    oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} PrintReport
Impressão do corpo do relatório
@type function
@author Frank Zwarg Fuga
@since 06/05/2026
/*/
Static Function PrintReport(oReport, aProdutox)
Local oSection 
Local nI 

    oSection := oReport:Section(STR0026) //"Produtos"

    oSection:Init()

    For nI := 1 To Len(aProdutox)
        oSection:Cell("CODPROD"):SetValue(aProdutox[nI][2])
        oSection:Cell("DESPROD"):SetValue(aProdutox[nI][3])
        oSection:Cell("QTDDEV") :SetValue(aProdutox[nI][4])
        oSection:Cell("QTDINF") :SetValue(aProdutox[nI][5])
        oSection:PrintLine()
    Next nI

    oSection:Finish()

Return Nil
