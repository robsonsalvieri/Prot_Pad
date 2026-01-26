#include "TOTVS.ch"    
#include "TOPCONN.CH"
#include "LOCA248.CH" 
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

/*/{PROTHEUS.DOC} LOCA248A
ITUP BUSINESS - TOTVS RENTAL
MEDICAO - VISUALIZAR O PROJETO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 26/07/2024
/*/
Function LOCA248A()
Local oModel
Local oFQK
Local cProjeto
Local aArea := GetArea()
Private lImplemento := .F.

    If FindFunction( "LOCA224B1" )
        If LOCA224B1("FQG_FILIAL", "FQG")
			lImplemento := .T.
		EndIf
	EndIf
    
    oModel := FWModelActive()
	oFQK   := oModel:GetModel("FQKMASTER")
    cProjeto := oFQK:GetValue("FQK_PROJET")

    If !empty(cProjeto)
        FP0->(dbSetOrder(1))
        FP0->(dbSeek(xFilial("FP0")+cProjeto))
        LOCA00110(cProjeto)
    Else
        Help( ,, "LOCA248-LOCA248A",, STR0024, 1, 0,,,,,,{STR0025}) //"Projeto não localizado"###"Verifique no movimento da medição se o campo Projeto está preenchido"
    EndIf
    restarea(aArea)

Return 


/*/{PROTHEUS.DOC} ExeC248
ITUP BUSINESS - TOTVS RENTAL
MEDICAO - CHAMADA DO AROTINA DO LOCA248
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 26/07/2024
/*/

Function ExeC248(nOpc)
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} 
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())

	lAltera := .F.
	lInclui := .F.
	lVisual := .F.
	lExclui := .F.

    If nOpc == 2
		lvisual := .T.
		// Recalcular os totais.
		LOCA248A6X()
        FWExecView(STR0004+" - "+STR0012,'LOCA248', MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons ) //"Medição"
    Elseif nOpc == 4

		If FQK->FQK_SITUAC <> "1"
			Help( ,, "LOCA248A-EXEC248",, STR0002, 1, 0,,,,,,{STR0093}) //"Inconsistência nos dados."###"A situação da medição não possibilita a manutenção."
			Return .F. 
		EndIF

		// Recalcular os totais.
		LOCA248A6X()
		lAltera := .T.
		lInclui := .F.

        FWExecView(STR0004+" - "+STR0014,'LOCA248', MODEL_OPERATION_UPDATE, , { || .T. }, , ,aButtons ) //"Medição"###"Manutenção"

    Elseif nOpc == 3
		
		lInclui := .T.
		lAltera := .F.
       	FWExecView(STR0004+" - "+STR0013,'LOCA248', MODEL_OPERATION_INSERT, , { || .T. }, , ,aButtons ) //"Medição"###"Incluir"

    EndIf

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))

Return  


/*/{PROTHEUS.DOC} LOCA04816
ITUP BUSINESS - TOTVS RENTAL
@AUTHOR Frank Zwarg Fuga em 30/07/2024
Altera a situação da medição
@TYPE FUNCTION
/*/
Function LOCA24816
Local oDialog
Local aSitua  := { STR0104,STR0105,STR0106,STR0107 } //"1=Digitado"###"2=Em aprovação"###"5-Não aprovado"###"6=Cancelado"
Local oSitua
Local oButOk
Local oButClose
Local nAction := 0
Local cAlias := GetNextAlias()
Local cAliasTrb := GetNextAlias()
Local aArea := FQK->(GetArea())
Local cProjet
Local lLC35PCAN := ExistBlock("LC35PCAN")
Local lLC248P1 := ExistBlock("LC248P1")
Local cQuery
Local aBindParam := {}
Local cCod := ""
Local cMedSeq := ""
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local cAs
Local cMedSeqx
Local cProjetx
Local _MV_LOC278 := SuperGetMV("MV_LOCX278",.F.,.F.)

Private CSITUA

	if !(FQK->FQK_SITUAC $ "1/2/5")
        Help( ,, "LOCA248-LOCA24816",, STR0002, 1, 0,,,,,,{STR0027}) //"Inconsistência nos dados."###"Só pode mudar a situação de medições 'DIGITADA', ou 'CONFIRMADA'."
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	//REGTOMEMORY("FQK",.T.) //CABECALHO MEDICAO

	cSitua := FQK->FQK_SITUAC

	Define MSDialog oDialog from 0,0 to 130,205 title STR0028 PIXEL //"Selecione a situação"
	@ 06,02 Say STR0029 Size 50,8 Pixel of oDialog //"Situação"
	@ 04,40 ComboBox oSitua var cSitua items aSitua valid Pertence("1256") Size 65,8 Pixel of oDialog

	@ 52,18 Button oButOk prompt STR0030 size 40,10 action (nAction := 1, oDialog:END()) of oDialog pixel //"Confirmar"
	@ 52,64 Button oButClose prompt STR0031 size 40,10 action (nAction := 0, oDialog:END()) of oDialog pixel //"Cancelar"
	Activate MsDialog oDialog Centered

	If nAction == 0
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))
		Return
	EndIf

	If lLC248P1
		If !ExecBlock("LC248P1",.T.,.T.,{})
			FQK->(RestArea(aAreaFQK))
			FQL->(RestArea(aAreaFQL))
			Return
		EndIF
	EndIf

	// Frank Zwarg Fuga em 20/09/2021
	// Só pode ser cancelada a última medição ativa.
	// Este controle tem haver com o retorno da numeração do bem.
	If cSitua == "6"

		cAs := FQK->FQK_AS
		cMedSeqx := FQK->FQK_MEDSEQ
		cProjetx := FQK->FQK_PROJET

		// Não permitir cancelar se houver uma medição posterior
		If FQK->FQK_TPMED == "A"
			FQK->(dbSetOrder(2))
			FQK->(dbSeek(xFilial("FQK")+cAs))
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
				If FQK->FQK_MEDSEQ > cMedSeqx .and. FQK->FQK_SITUAC <> "6"
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
					Help( ,, "LOCA248-LOCA24816",, STR0002, 1, 0,,,,,,{STR0117}) //"Inconsistência nos dados."###"A data final não pode ser editada, pois existe uma medição posterior."
					Return .F.
				EndIf
				FQK->(dbSkip())
			EndDo
		Else
			FQK->(dbSetOrder(6)) 
			FQK->(dbSeek(xFilial("FQK")+cProjetx))
			While !FQK->(Eof()) .and. FQK->FQK_FILIAL == xFilial("FQK") .and. FQK->FQK_PROJET == cProjetx
				If FQK->FQK_MEDSEQ > cMedSeqx .and. FQK->FQK_SITUAC <> "6"
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
					Help( ,, "LOCA248-LOCA24816",, STR0002, 1, 0,,,,,,{STR0117}) //"Inconsistência nos dados."###"A data final não pode ser editada, pois existe uma medição posterior."
					Return .F.
				EndIF
				FQK->(dbSkip())
			EndDo
		EndIF
		FQK->(RestArea(aAreaFQK))
		FQL->(RestArea(aAreaFQL))

		cAlistTrb := GetNextAlias()
		cProjet := FQK->FQK_PROJET
		//If select("CALIASTRB") > 0
		//	(CALIASTRB)->(dbCloseArea())
		//EndIf
		cQuery := " SELECT FQK_TPMED FROM "+RetSQLName("FQK")
		cQuery += " WHERE FQK_PROJET = ? AND "
        aadd(aBindParam,cProjet)
		cQuery += " FQK_SITUAC <> '6' AND D_E_L_E_T_='' AND FQK_COD > ? "
        aadd(aBindParam,FQK->FQK_COD)
		cQuery := CHANGEQUERY(cQuery)
        MPSysOpenQuery(cQuery,CALIASTRB,,,aBindParam)

		If !(CALIASTRB)->(EOF())
            Help( ,, "LOCA248-LOCA24816",, STR0002, 1, 0,,,,,,{STR0032}) //"Inconsistência nos dados."###"Só pode ser cancelada a última medição."
			FQK->(RestArea(aAreaFQK))
			FQL->(RestArea(aAreaFQL))
			RestArea(aArea)
			Return .F.
		EndIf

		(CALIASTRB)->(DBCLOSEAREA())

		RestArea(aArea)

	EndIf

    aBindParam := {}
    cQuery := "SELECT R_E_C_N_O_ REC FROM "+RetSQLName("FQK")+" "
    cQuery += "WHERE D_E_L_E_T_= ''	AND FQK_FILIAL = '"+xFilial("FQK")+"' "
    cQuery += "AND FQK_COD = ? "
    aadd(aBindParam,FQK->FQK_COD)
	cQuery := CHANGEQUERY(cQuery)
    MPSysOpenQuery(cQuery,CALIAS,,,aBindParam)

	dbSelectArea(CALIAS)

	While (CALIAS)->(!EOF())
		FQK->(DBGOTO((CALIAS)->REC))
		FQK->(RecLock("FQK",.F.))
		FQK->FQK_SITUAC := cSitua
		If cSitua == "6" //.AND. FQK->FQK_TIPO $ "C/F"
			FQK->FQK_VALTOT := 0
			FQK->FQK_VALSER := 0
			cCod := FQK->FQK_COD
			cMedSeq := FQK->FQK_MEDSEQ
			FQK->FQK_MEDSEQ := SPACE(LEN(FQK->FQK_MEDSEQ))
		EndIf
		FQK->(MsUnlock())
		(CALIAS)->(dbSkip())
	EndDo
	(CALIAS)->(dbCloseArea())  

	If cSitua == "6"
		FQL->(DBSETORDER(5))  

		If FQL->(DBSEEK(FQK->FQK_FILIAL + cCod + cMedSeq ))
			While FQL->(!Eof()) .AND. FQL->FQL_FILIAL == FQK->FQK_FILIAL .AND. FQL->FQL_COD == cCod .AND. FQL->FQL_ORDEM == cMedSeq
				// VERIFICA SE TEM MINUTA VINCULADA A MEDIÇÃO, CASO HOUVER, VOLTA O STATUS PARA BAIXADO E LIMPA O NUMERO DA MEDIÇÃO
				FPF->(DBSETORDER(3)) //FPF_FILIAL + FPF_PROJETO
				FPF->(dbSeek(xFilial("FPF") + cProjet))
				While !FPF->(Eof()) .and. FPF->(FPF_FILIAL+FPF_PROJET) == xFilial("FPF")+cProjet
					If FPF->FPF_STATUS == "6" .and. FPF->FPF_NROMED == cCod
						FPF->(RecLock("FPF", .F.))
						FPF->FPF_STATUS := "3"
						FPF->FPF_NROMED := ""
						FPF->FPF_MEDSEQ := ""
						FPF->(MsUnlock())
					EndIf
					FPF->(dbSkip())
				EndDo

				FQL->(RecLock("FQL",.F.))
				FQL->FQL_QTDHR  := 0
				FQL->FQL_QTDHR2 := 0
				FQL->FQL_VLRTOT := 0
				FQL->FQL_HRPARA := "09:00"
				If FQL->(FieldPos("FQL_MINUTA")) > 0
					FQL->FQL_MINUTA := ""
				EndIf
				FQL->(MsUnlock())

				FQL->(dbSkip())
			EndDo

			// Tratar o cancelamento dos provisórios
			If _MV_LOC278
				LOCA248AP(.T., .F., cMedSeq)
			EndIf
		EndIf

		If lLC35PCAN
			ExecBlock("LC35PCAN",.T.,.T.,{FQK->FQK_AS})
		EndIf

	EndIf

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))
	RestArea(aArea)
Return


/*/{PROTHEUS.DOC} RETARRAUTO
ITUP BUSINESS - TOTVS RENTAL
Retorna as informações do SX3
Frank Z Fuga em 31/07/2024
/*/
Static Function RETARRAUTO(cAlias)
Local aArea := GetArea()  
Local aAuto := {}
Local nX
Local aFields

	aFields := FWSX3Util():GetListFieldsStruct( cAlias , .F.)
	For nX := 1 To Len( aFields )
		cCampo := GetSx3Cache(alltrim(aFields[nX][01]),"X3_CAMPO")
		cVirtual := GetSx3Cache(alltrim(aFields[nX][01]),"X3_CONTEXT")
		If (x3Uso(GetSx3Cache(alltrim(aFields[nX][01]),"X3_USADO")) .and. cVirtual <> "V") .or. PREFIXOCPO(cAlias)+"_FILIAL" == ALLTRIM(cCampo)
			aadd(aAuto, { alltrim(cCampo), (cAlias)->&(alltrim(cCampo)), NIL} )
		EndIf
	Next nX
	
	RestArea(aArea)

Return(aAuto)

/*/{PROTHEUS.DOC} LOCA04815
ITUP BUSINESS - TOTVS RENTAL
Inicializador padrão dos campos da FQL
Frank Z Fuga em 31/07/2024
/*/

Function LOCA24815(cCampo)
Local xRet
Local cFilAux  := xFilial("FQ5")
Local cTpSegm  := ""
Local aAreaFQ5 := FQ5->(GetArea())
Local aAreaFP4 := FP4->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local xProjet
Local xObra
Local xViagem
Local xAs

	If INCLUI
		xProjet	:= space(len(FQK->FQK_PROJET))
		xObra	:= space(len(FQK->FQK_OBRA))
		xViagem	:= space(len(FQK->FQK_VIAGEM))
		xAs		:= space(len(FQK->FQK_AS))
	Else
		xProjet	:= FQK->FQK_PROJET
		xObra	:= FQK->FQK_OBRA
		xViagem	:= FQK->FQK_VIAGEM
		xAs		:= FQK->FQK_AS
	EndIf

	FQ5->(dbSetOrder(1))	
	IF FQ5->(dbSeek(xFilial("FQ5")+xViagem))
		cFilAux := FQ5->FQ5_FILORI
		cTpSegM := FQ5->FQ5_TPAS
	ENDIF
	FQ5->(RestArea(aAreaFQ5))

	If cCampo == "FQL_VENDA"
		xRet := cFilAux 
	Else
		xRet := Iif(left(cCampo,6)== "FQL_MA", cFilAux, 0)
		If cTpSegM == "G"			// SEGMENTO GUINDASTES
			FP4->(dbSetOrder(3))	// FP4_FILIAL + FP4_AS + FP4_VIAGEM
			If FP4->(dbSeek(cFilAux+XAS+XVIAGEM))
				If left(cCampo,6)== "FQL_MA"
					If cCampo == "FQL_MAQUIN"
						XRET := FP4->FP4_FLMAQ
					EndIf
					If cCampo == "FQL_MAO"
						XRET := FP4->FP4_FLMO
					EndIf
				EndIf
			EndIf
			FP4->(RestArea(aAreaFP4))
		ElseIf cTpSegM == "U"		// SEGMENTO GRUAS
			FPA->(dbSetOrder(2))	// FPA_FILIAL + FPA_PROJET + FPA_OBRA + FPA_AS + FPA_VIAGEM
			If FPA->(dbSeek(cFilAux+XPROJET+XOBRA+XAS+XVIAGEM))
				If left(cCampo,6)== "FQL_MA"
					If cCampo == "FQL_MAQUIN"
						xRet := FPA->FPA_FLMAQ
					EndIf
					If cCampo == "FQL_MAO"
						xREt := FPA->FPA_FLMO
					EndIf
				EndIf
			EndIf
			FPA->(RestArea(aAreaFPA))
		EndIf
	EndIf

Return xRet

/*/{PROTHEUS.DOC} LOCA248B
ITUP BUSINESS - TOTVS RENTAL
Posterior a gravação da medicao
Frank Z Fuga
05/08/2024
/*/
Function LOCA248B(oModel) 
Local lRet 
Local aArea := GetArea()
Local cSeq
Local cCod
Local cTpMed
Local cErro := ""
Local oModelFPF := oModel:GetModel("FPFDETAIL")
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nI
Local _MV_LOC278 := SuperGetMV("MV_LOCX278",.F.,.F.)
Local nX
Local nPonteiro
Local cAs

	lRet := FWFormCommit(oModel)
	If lRet

		If lInclui
			FQK->(ConfirmSX8())
		EndIF

		FQK->(ConfirmSX8())
		FPA->(dbSetOrder(3))
		FPA->(dbSeek(xFilial("FPA")+FQK->FQK_AS))
		FQK->(RecLock("FQK",.F.))
		FQK->FQK_OBRA	:= FPA->FPA_OBRA
		FQK->FQK_VIAGEM := FPA->FPA_VIAGEM
		FQK->FQK_ENCEAS := "1" // não encerra a AS
		//FQK->FQK_CCUSTO	:= FPA->FPA_CUSTO
		//FQK->FQK_TIPO	:= "F"
		FQK->(MsUnlock())

		cCod := FQK->FQK_COD
		cSeq := FQK->FQK_MEDSEQ
		cTpMed := FQK->FQK_TPMED

		// Tratamento das minutas
		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted()
				cAs := oModelFQL:GetValue("FQL_AS")
				FPA->(dbSetOrder(3))
				If FPA->(dbSeek(xFilial("FPA")+cAs))
					If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
						If !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM) .and. !empty(cAs)
							FPF->(dbSeek(xFilial("FPF")+cAs))
							While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == cAs
								If (FPF->FPF_STATUS == "3" .and. lInclui .and. empty(FPF->FPF_NROMED)) .or. ((FPF->FPF_STATUS == "3" .or. FPF->FPF_STATUS == "6") .and. !lInclui)
									If FPF->FPF_DATA <= M->FQK_DTFIM
										If !empty(FPF->FPF_MEDSEQ) .and. !empty(FPF->FPF_NROMED)
											If FPF->FPF_MEDSEQ <> FQK->FQK_MEDSEQ .or. FPF->FPF_NROMED <> FQK->FQK_COD .or. file("\SYSTEM\LOC248AE.TXT")
												FPF->(dbSkip())
												Loop
											EndIf
										EndIF

										If FPF->FPF_TURNO == oModelFQL:GetValue("FQL_TURNO")
											FPF->(RecLock("FPF",.F.))
											FPF->FPF_STATUS := "6" // minuta medida
											FPF->FPF_NROMED := FQK->FQK_COD
											FPF->FPF_MEDSEQ := FQK->FQK_MEDSEQ
											FPF->FPF_FILTRO := ""
											FPF->(MsUnlock())
										EndIf


									EndIf
								EndIf
								FPF->(dbSkip())
							EndDo
						EndIf
					EndIf
				EndIF
			EndIf
		Next
		oModelFQL:GoLine(nPonteiro)
		
		
		FQL->(dbSetOrder(5))
		FQL->(dbSeek(xFilial("FQL")+cCod+cSeq))
		While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_COD+FQL_ORDEM) == xFilial("FQL")+cCod+cSeq
			If FQL->FQL_BASE == "C"
				If FQK->FQK_INTCON == "S"
					If !NGTRETCON(FQL->FQL_FROTA,M->FQK_DTFIM,FQL->FQL_KMFIM,time(),1,,,"A",xFilial("ST9"))
						cErro += alltrim(FQL->FQL_FROTA)+" "
					EndIF
				EndIF
			EndIf

			FQL->(dbSkip())
		EndDo

		/*For nI := 1 to oModelFPF:Length()
			oModelFPF:GoLine(nI)
			If !oModelFPF:IsDeleted()
				FPF->(dbSetOrder(2))
				If FPF->(dbSeek(xFilial("FPF")+oModelFPF:GetValue("FPF_MINUTA")))
					FPF->(RecLock("FPF",.F.))
					FPF->FPF_STATUS := "6" // minuta medida
					FPF->FPF_NROMED := FQK->FQK_COD
					FPF->FPF_MEDSEQ := FQK->FQK_MEDSEQ
					FPF->(MsUnlock())
				EndIf
			EndIF
		Next*/

		// Tratamento para os títulos provisórios
		If _MV_LOC278
			LOCA248AP()
		EndIf

		If !empty(cErro)
			Help( ,, "LOCA248-LOCA248B",, STR0002, 1, 0,,,,,,{STR0083+cErro}) //"Inconsistência nos dados."###"Não foi possível alterar o contador no manutenção de ativos dos seguintes bens: "
		EndIf

	EndIf
	RestArea(aArea)
Return lRet


/*/{PROTHEUS.DOC} LOCA248C
ITUP BUSINESS - TOTVS RENTAL
Cancelamento do formulário da medição
Frank Z Fuga
05/08/2024
/*/

Function LOCA248C
Local lLC248P2 := ExistBlock("LC248P2")
Local lRet := .T.

	If lLC248P2
		lRet := ExecBlock("LC248P2",.T.,.T.,{})
	EndIf

	If lRet
		FQK->(RollBackSX8())
	EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA248D
ITUP BUSINESS - TOTVS RENTAL
Validação do grupo
Frank Z Fuga
06/08/2024
/*/
Function LOCA248D
Local aAreaFPA := GETAREA()
Local lRet := .T.
Local cAgente
Local cLoja
Local cNome
Local cCondPag
Local cDescPag
Local nValServ
Local cProjeto := M->FQK_PROJET
Local lLocaliza := .F.
Local cRetExtra := ""

	FPA->(dbSetOrder(1))
	If !FPA->(dbSeek(xFilial("FPA")+cProjeto)) .or. empty(cProjeto)
		Help( ,, "LOCA248-LOCA248D",, STR0002, 1, 0,,,,,,{STR0058}) //"Inconsistência nos dados."###"O projeto informado não foi localizado"
		lRet := .F.
	EndIF

	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0") + cProjeto))

	cAgente	:= FP0->FP0_CLI
	cLoja	:= FP0->FP0_LOJA

	cNome := Posicione("SA1",1,xFilial("SA1")+cAgente+cLoja ,"A1_NOME")

	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA")+cProjeto))

	cCondPag := FQ5->FQ5_CONDPG
	cDescPag := Posicione("SE4",1,xFilial("SE4")+cCondPag,"E4_DESCRI")

	nValServ := 0
	nTotHrre := 0

	M->FQK_CLIENT := cAgente
	M->FQK_LOJA := cLoja
	M->FQK_NOMAGE := cNome
	M->FQK_VALSER := nValServ
	LOCA248LIB()
	M->FQK_TPFRAN := FP0->FP0_TPFRAN

	If lRet
		LOCA248E()
	EndIf

	If M->FQK_TPMED == "G" .and. lRet

		FPA->(dbSetOrder(1))	// Frank Fuga melhorias em 22/11/21
		FPA->(dbSeek(xFilial("FPA")+cProjeto)) // Frank Fuga melhorias em 22/11/21

		While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET) == xFilial("FPA")+cProjeto
			If FPA->FPA_GRUPOM == M->FQK_GRPMD .and. !empty(FPA->FPA_AS)
				lLocaliza := .T.
			EndIF
			If FPA->FPA_VLHREX == 0 .and. FP0->FP0_TPFRAN == "G"
				If empty(cRetExtra)
					cRetExtra := STR0143 //"A medição compartilhada exige que o campo 'R$ Hrs Extra' do orçamento esteja preenchido. Itens do orçamento com o campo zerado: "
				EndIf
				cRetExtra += FPA->FPA_SEQGRU+" "
			EndIf
			FPA->(dbSkip())
		EndDo
		If !lLocaliza
			lRet := .F.
			Help( ,, "LOCA248-LOCA248D",, STR0002, 1, 0,,,,,,{STR0061}) //"Inconsistência nos dados."###"Grupo informado não localizado no projeto"
		EndIf
		If !empty(cRetExtra)
			Help( ,, "LOCA248-LOCA248D",, STR0002, 1, 0,,,,,,{cRetExtra}) //"Inconsistência nos dados."###cRetExtra
			RestArea(aAreaFPA)
			Return .F.
		EndIf
	EndIf

	// Atualiza a sequencia para o tipo de medição em grupo
	LOCA248SEQ()

	If lRet

		If M->FQK_TPMED <> "A" .AND. M->FQK_SEQ > "001"
			lEditDt := .F.
		EndIf

		FPA->(dbSeek(xFilial("FPA")+cProjeto))

		cCondPag := FPA->FPA_CONPAG
		cDescPag := Posicione("SE4",1,xFilial("SE4")+cCondPag,"E4_DESCRI")
		
		If empty(FWFldGet("FQK_CONDPA"))
			FWFldPut("FQK_CONDPA",cCondPag)
		EndIf
		
		// Inicio Item 225 = Circenis 16/01/22
		if Empty(M->FQK_PMEDI) 
			M->FQK_PMEDI := Posicione("FP0",1, xFilial("FP0")+cProjeto , "FP0_PMEDIC")
		endif

		// Alimenta a grid quando for por grupo.
		LOCA248H()

	EndIf

	LOCA248BLQ()

	RestArea(aAreaFPA)

Return(lRet)


/*/{PROTHEUS.DOC} LOCA248E
ITUP BUSINESS - TOTVS RENTAL
Conta a quantidade de medições 
Frank Z Fuga
06/08/2024
/*/
Function LOCA248E()
Local aArea	:= GETAREA()
Local cQuery
Local cAliasTRB := GETNEXTALIAS()
Local cProjeto := FQK->FQK_PROJET
Local cGrupo := M->FQK_GRPMD
Local aBindParam := {}
Local nI
Local cAs
Local nTemp
Local cCod
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cgrpand

	If SBM->(FieldPos("BM_XACESS")) > 0
		cgrpand := LOCA00189()
	Else
		cgrpand := SuperGetMV("MV_LOCX014",.F.,"")
	EndIf

	If LINCLUI

		cQuery := " SELECT FQK_MEDSEQ , FQK_DTFIM , FQK_SITUAC , FQK_DESDTP "
		cQuery += " FROM "+RETSQLNAME("FQK")
		cQuery += " WHERE  FQK_FILIAL='"+xFilial('FQK')+"'"
		If M->FQK_TPMED == "G"
			cQuery += "   AND  FQK_PROJET = ? AND FQK_GRPMD = ? "
			aadd(aBindParam,cProjeto)
			aadd(aBindParam,cGrupo)
		EndIf
		cQuery += " AND D_E_L_E_T_=''"
		cQuery += " ORDER BY R_E_C_N_O_ DESC"
		cQuery := CHANGEQUERY(cQuery)
		MPSysOpenQuery(cQuery,CALIASTRB,,,aBindParam)

		While !(cAliasTRB)->(Eof())
			IF (cAliasTRB)->FQK_SITUAC != "6"
				//M->FQK_SEQ := soma1( Iif(empty((cAliasTRB)->FQK_MEDSEQ),"001",(cAliasTRB)->FQK_MEDSEQ) )

				// CONDIÇÃO FEITA PARA INCLUIR MEDIÇÕES ADICIONAIS.
				If (cAliasTRB)->FQK_DTFIM == (cAliasTRB)->FQK_DESDTP
					M->FQK_DTINIC := Iif(empty((cAliasTRB)->FQK_DTFIM), ctod("  /  /  "), stod((cAliasTRB)->FQK_DTFIM))
				Else
					M->FQK_DTINIC := Iif(empty((cAliasTRB)->FQK_DTFIM), ctod("  /  /  "), stod((cAliasTRB)->FQK_DTFIM)+1)
					dControl := M->FQK_DTINIC // para uso postetior na validação da data inicial
				EndIf
				Exit
			EndIF
			(cAliasTRB)->(dbSkip())
		EndDo
		(cAliasTRB)->(dbCloseArea())

		If M->FQK_MEDSEQ > "001"
			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted()
					cAs := oModelFQL:GetValue("FQL_AS")
					FPA->(dbSetOrder(3))
					FPA->(dbSeek(xFilial("FPA")+cAs))
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

					If !ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND) .and. oModelFQL:GetValue("FQL_BASE") $ "HDO"

						nTemp := 0
						cCod := ""

						FQL->(dbSetOrder(6))
						FQL->(dbSeek(xFilial("FQL")+cAs))

						While !FQL->(Eof()) .and. FQL->FQL_AS == cAs

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

							FQL->(dbSkip())
						EndDo

						If nTemp > 0
							LOCA248LIB()
							If oModelFQL:GetValue("FQL_TPAS") <> "M"
								If oModelFQL:GetValue("FQL_TPAS") <> "M"
									oModelFQL:SetValue("FQL_KMINI", nTemp )
								EndIf
							EndIf
						EndIF

					EndIf
				EndIf
			Next
		EndIf

		RestArea(AAREA)

	EndIF

	LOCA248BLQ()

Return .T.

/*/{PROTHEUS.DOC} LOCA248F
ITUP BUSINESS - TOTVS RENTAL
Cadastro dos períodos da medição
Frank Z Fuga
07/08/2024
/*/
Function LOCA248F
	FQJ->(dbSetOrder(1))
	AxCadastro("FQJ",STR0060) // "Período das medições"
Return .T.


/*/{PROTHEUS.DOC} LOCA24808
ITUP BUSINESS - TOTVS RENTAL
Calculo dos totais da medicao
Frank Z Fuga
07/08/2024
/*/
Function LOCA24808(PCAMPO)  
Local nPercent := 0
Local nCalc1 := 0
Local lRet   := .T.   
Local cTPServ
Local nSeguroX := 0
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cAs := oModelFQL:GetValue("FQL_AS")
Local cViagem
Local cErro := ""
Local nTemp1
Local nTemp2
Local nMinDia := 0
Local nPerISS
Local cTpSegur
Local cTpIss
Local nValIss
Local nValTotMed
Local nPonteiro  
Local nExcede
Local nFranq
Local nLanc
Local nI
Local nCalc
Local lExped := .F.
Local cProjeto
Local cGrupoMed
Local oView := FWViewActive() 
Local nKm
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local aAreaFPA := FPA->(GetArea())

	// Para minuta não permitir o preenchimento do FQL_KMINI e FQL_KMFIM
	If PCAMPO == "FQL_KMFIM" .or. PCAMPO == "FQL_KMINI"
		FPA->(dbSetOrder(3))
		If FPA->(dbSeek(xFilial("FPA")+cAs))
			// Identificação que é uma minuta
			If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
				Help( ,, "LOCA24808",, STR0002, 1, 0,,,,,,{STR0135}) //"Inconsistência nos dados."###"Medição de minuta não permite a edição da quantidade inicial e final."
				FPA->(RestArea(aAreaFPA))
				Return .F.
			EndIf
		EndIf
		FPA->(RestArea(aAreaFPA))
	EndIf

	If PCAMPO == "FQL_KMFIM"

		// Verificar se existem medicoes posteriores
		If M->FQK_TPMED == "A"
			FQK->(dbSetOrder(2))
			FQK->(dbSeek(xFilial("FQK")+M->FQK_AS))
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+M->FQK_AS
				If FQK->FQK_MEDSEQ > M->FQK_MEDSEQ .and. FQK->FQK_SITUAC <> "6"
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
					Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0116}) //"Inconsistência nos dados."###"O campo não pode ser editada, pois existe uma medição posterior."
					LOCA248BLQ()
					Return .F.
				EndIf
				FQK->(dbSkip())
			EndDo
		Else
			FQK->(dbSetOrder(6))
			FQK->(dbSeek(xFilial("FQK")+M->FQK_PROJET))
			While !FQK->(Eof()) .and. FQK->FQK_FILIAL == xFilial("FQK") .and. FQK->FQK_PROJET == M->FQK_PROJET
				If FQK->FQK_MEDSEQ > M->FQK_MEDSEQ .and. FQK->FQK_SITUAC <> "6" 
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
					Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0116}) //"Inconsistência nos dados."###"O campo não pode ser editada, pois existe uma medição posterior."
					LOCA248BLQ()
					Return .F.
				EndIF
				FQK->(dbSkip())
			EndDo
		EndIF



		If empty(oModelFQL:GetValue("FQL_DTSAID"))

			// Verificar em medições anteriores
			lExped := .F.
			If M->FQK_TPMED == "A"
				cAs := M->FQK_AS
				FQK->(dbSetOrder(2))
				FQK->(dbSeek(xFilial("FQK")+cAs))
				While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
					If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
						FQL->(dbSetOrder(6))
						If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
							If !empty(FQL->FQL_DTSAID)
								lExped := .T.
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
									lExped := .T.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
					FQL->(dbSkip())
				EndDo
			EndIF

			If !lExped
				Help( ,, "LOCA248-LOCA24808",, STR0002, 1, 0,,,,,,{STR0108}) //"Inconsistência nos dados."###"A data de expedição ainda não foi preenchida."
				LOCA248BLQ()
				Return .F.
			EndIf
		EndIf
	EndIf

	If PCAMPO == "FQL_QTDHR" .or. PCAMPO == "FQL_KMFIM"

		If M->FQK_TPMED == "G" .and. M->FQK_TPFRAN == "G"
			nPonteiro := oModelFQL:GetLine()
			nExcede := 0
			nFranq := 0
			nLanc := 0  
			nCalc := 0
			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
					If oModelFQL:GetValue("FQL_QTDHR") > 0
						nExcede += oModelFQL:GetValue("FQL_QTDHR") 
					Else
						If oModelFQL:GetValue("FQL_VLRFRA") - (oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI"))  > 0
							nExcede -= oModelFQL:GetValue("FQL_VLRFRA") - (oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI") + oModelFQL:GetValue("FQL_COMPLE"))
						EndIF
					EndIf
					nFranq += oModelFQL:GetValue("FQL_FRKM")
					nLanc += oModelFQL:GetValue("FQL_KMFIM")
					If oModelFQL:GetValue("FQL_VLRFRA") < (oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI") + oModelFQL:GetValue("FQL_COMPLE"))
						nCalc += oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI") + oModelFQL:GetValue("FQL_COMPLE")
					EndIF
				EndIf  
			Next
			If nLanc > nFranq
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
						nTot1 := oModelFQL:GetValue("FQL_QTDHR")
						If nTot1 > 0
							nKm := oModelFQL:GetValue("FQL_KMFIM") - oModelFQL:GetValue("FQL_KMINI") + oModelFQL:GetValue("FQL_COMPLE")
							If oModelFQL:GetValue("FQL_VLRFRA") < nKm //.and. nKm > 0 //oModelFQL:GetValue("FQL_QTDKM")
								LOCA248LIB()
								//oModelFQL:SetValue("FQL_QTDHR2",(nExcede*oModelFQL:GetValue("FQL_KMFIM"))/nCalc)
								If (nExcede*nkm)/nCalc > 0
									oModelFQL:SetValue("FQL_QTDHR2",(nExcede*nkm)/nCalc)
								Else
									oModelFQL:SetValue("FQL_QTDHR2",0)
								EndIF
							Else
								LOCA248LIB()
								oModelFQL:SetValue("FQL_QTDHR2",0)
							EndIf
						EndIf
					EndIf  
				Next
			Else
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If !oModelFQL:IsDeleted() 
						LOCA248LIB()
						oModelFQL:SetValue("FQL_QTDHR2",0)
					EndIf
				Next
			Endif

			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
					LOCA248LIB()
					oModelFQL:SetValue("FQL_VLTOHR", oModelFQL:GetValue("FQL_VALHOR") * oModelFQL:GetValue("FQL_QTDHR2")   )
				EndIF
			Next


			oModelFQL:GoLine(nPonteiro)
			oView:Refresh()
		EndIf
		lRet := .T.
	EndIf

	If alltrim(upper(ReadVar())) == "M->FQL_PERMO" .or. alltrim(upper(ReadVar())) == "M->FQL_PERMAQ"
		If oModelFQL:GetValue("FQL_PERMO") + oModelFQL:GetValue("FQL_PERMAQ") > 100
			Help( ,, "LOCA248-LOCA248C3",, STR0002, 1, 0,,,,,,{STR0084}) //"Inconsistência nos dados."###"O percentual de mão de obra + máquina não pode ultrapassar os 100%"
			lRet := .F.
		EndIF
	EndIf
	
	M->FQL_DTMEDI := IIF(PCAMPO=="FQL_DTMEDI" , M->&(PCAMPO) , oModelFQL:GetValue("FQL_DTMEDI"))
	M->FQL_FROTA  := IIF(PCAMPO=="FQL_FROTA"  , M->&(PCAMPO) , oModelFQL:GetValue("FQL_FROTA"))
	M->FQL_BASE   := IIF(PCAMPO=="FQL_BASE"   , M->&(PCAMPO) , oModelFQL:GetValue("FQL_BASE"))
	M->FQL_VALHOR := IIF(PCAMPO=="FQL_VALHOR" , M->&(PCAMPO) , oModelFQL:GetValue("FQL_VALHOR"))

	If PCAMPO == "FQL_PERMO" .and. alltrim(ReadVar()) == "FQL_PERMO"
		M->FQL_PERMO := M->&(PCAMPO)
	Else
		M->FQL_PERMO := oModelFQL:GetValue("FQL_PERMO")
	EndIF

	If lRet .and. PCAMPO == "FQL_DTMEDI"
		If !FCHKCONTAB(M->FQL_DTMEDI) 
			lRet := .F.
		EndIf
	EndIf

	// cAs é validado no FCHKCONTAB
	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+cAs))
	cViagem := FPA->FPA_VIAGEM

	If lRet .and. PCAMPO == "FQL_FROTA"	
		If !Empty(M->FQL_FROTA) .and. M->FQL_FROTA != POSICIONE("FQ5",1,XFILIAL("FQ5")+cViagem,"FQ5_GUINDA") 
			cErro := STR0067 //"O bem está diferente do informado na AS."
			lRet := .F.
		EndIf
		If lRet 
			If !(ST9->(dbSeek(xFilial("ST9")+M->FQL_FROTA)))
				lRet := .F.
				cErro := STR0068 //"Bem não localizado no registro do manutenção de ativos."
			EndIf
		EndIf
	EndIf

	If lRet 
		// Gatilho para a quantidade total FQL_QTDKM
		cAs := oModelFQL:GetValue("FQL_AS")

		// Atualiza vlr.seguro e valor base do seguro
		If oModelFQL:GetValue("FQL_VLBSEG") > 0 // valor base do seguro
			nTemp1 := oModelFQL:GetValue("FQL_VLBSEG")
			nTemp2 := oModelFQL:GetValue("FQL_PERSEG")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALSEG", (nTemp1 * nTemp2)/100  )
		EndIf
		If  oModelFQL:GetLine() > 1 
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALSEG", 0  )
		EndIF

		// valor total de horas e valor base hora
		If M->FQK_TPMED == "G" .and. M->FQK_TPFRAN == "G"
			nMinDia := oModelFQL:GetValue("FQL_QTDHR2") 
		Else
			nMinDia := oModelFQL:GetValue("FQL_QTDHR") 
		EndIf
		nTemp1 := oModelFQL:GetValue("FQL_VALHOR")
		nTemp2 := nMinDia
		LOCA248LIB()
		oModelFQL:SetValue("FQL_VLTOHR", nTemp1 * nTemp2  )

		nPerISS := oModelFQL:GetValue("FQL_PERISS") 
		cTpSegur := oModelFQL:GetValue("FQL_TIPO")

		If cTpSegur == "I" .or. cTpSegur == "C"	
			If oModelFQL:GetValue("FQL_BASE") == "K"
				nCalc1 := (oModelFQL:GetValue("FQL_QTDKM") * oModelFQL:GetValue("FQL_VALHOR")) + ;
				oModelFQL:GetValue("FQL_VLRMOB") + oModelFQL:GetValue("FQL_VLRDES") + ;
				oModelFQL:GetValue("FQL_ANCORA") + oModelFQL:GetValue("FQL_TELESC") + ;
				oModelFQL:GetValue("FQL_MONTAG") + oModelFQL:GetValue("FQL_DESMON") + ;
				oModelFQL:GetValue("FQL_TRSPES") + oModelFQL:GetValue("FQL_ACESSO")
			Else
				nCalc1 := oModelFQL:GetValue("FQL_VLTOHR") + ;
				oModelFQL:GetValue("FQL_VLRMOB") + oModelFQL:GetValue("FQL_VLRDES") + ;
				oModelFQL:GetValue("FQL_ANCORA") + oModelFQL:GetValue("FQL_TELESC") + ;
				oModelFQL:GetValue("FQL_MONTAG") + oModelFQL:GetValue("FQL_DESMON") + ;
				oModelFQL:GetValue("FQL_TRSPES") + oModelFQL:GetValue("FQL_ACESSO")
			EndIf 
		Else
			If oModelFQL:GetValue("FQL_BASE") == "K"
				nCalc1 := (oModelFQL:GetValue("FQL_QTDKM") * oModelFQL:GetValue("FQL_VALHOR")) + ;
				oModelFQL:GetValue("FQL_VLRMOB") + oModelFQL:GetValue("FQL_VLRDES") + ;
				oModelFQL:GetValue("FQL_ANCORA") + oModelFQL:GetValue("FQL_TELESC") + ;
				oModelFQL:GetValue("FQL_MONTAG") + oModelFQL:GetValue("FQL_DESMON") + ;
				oModelFQL:GetValue("FQL_TRSPES") + oModelFQL:GetValue("FQL_VALSEG") + ;
				oModelFQL:GetValue("FQL_ACESSO") + oModelFQL:GetValue("FQL_PERMO")
			Else
				nCalc1 := oModelFQL:GetValue("FQL_VLTOHR") + ;
				oModelFQL:GetValue("FQL_VLRMOB") + oModelFQL:GetValue("FQL_VLRDES") + ;
				oModelFQL:GetValue("FQL_ANCORA") + oModelFQL:GetValue("FQL_TELESC") + ;
				oModelFQL:GetValue("FQL_MONTAG") + oModelFQL:GetValue("FQL_DESMON") + ;
				oModelFQL:GetValue("FQL_TRSPES") + oModelFQL:GetValue("FQL_VALSEG") + ;
				oModelFQL:GetValue("FQL_ACESSO") 
			EndIF
		EndIf

		nCalc1 := nCalc1 - oModelFQL:GetValue("FQL_DESC")
		nCalc1 := nCalc1 + oModelFQL:GetValue("FQL_ACRES")

		cTpServ := ""
		FP0->(dbSetOrder(1))
		If FP0->(dbSeek(xFilial("FP0")+M->FQK_PROJET))
			cTpServ := FP0->FP0_TIPOSE
		EndIF

		cTpIss := oModelFQL:GetValue("FQL_TPISS")
		
		nSeguroX := 0
		if pCampo == "FQL_VALSEG" .and. alltrim(ReadVar()) == "M->FQL_VALSEG"
			nSeguroX := &(ReadVar())
		Else
			nSeguroX := oModelFQL:GetValue("FQL_VALSEG")
		EndIF
		nValIss := LOCA00158( nCalc1 - nSeguroX, nPerIss, cTpIss)
		
		// DSERLOCA-2235 Frank Fuga em 24/01/24
		nPercent := 0
		If PCAMPO == "FQL_PERMO"
			nPercent := M->FQL_PERMO
		else
			nPercent := oModelFQL:GetValue("FQL_PERMO")
		EndIf

		If oModelFQL:GetValue("FQL_TPISS") == "I" .or. oModelFQL:GetValue("FQL_TPISS") == "X"
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VLRTOT", nCalc1 )
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALISS", ((nCalc1-nSeguroX) * nPerISS) / 100 )
			// valor total da mão de obra
			nTemp1 := oModelFQL:GetValue("FQL_VLRTOT")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VLTOTM", (nPercent * nTemp1)/100  )
		Else
			// valor total
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALISS", nValISS )
			nTemp1 := oModelFQL:GetValue("FQL_VALISS")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VLRTOT", nCalc1 + nTemp1 )
			// valor total da mão de obra
			nTemp1 := oModelFQL:GetValue("FQL_VLRTOT")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VLTOTM", (nPercent * nTemp1)/100 )
		EndIf


		// cálculo de rateio por filial
		nValTotMed := oModelFQL:GetValue("FQL_VLRTOT") 

		// cálculo do valor comercial
		// FQL_PERVND não listado como campo válido da FQL
		//nTemp1 := oModelFQL:GetValue("FQL_PERVND")
		//oModelFQL:SetValue("FQL_VLVND", (nValTotMed * nTemp1)/100 )

		// cálculo do valor a filial do bem/máquina
		nTemp1 := oModelFQL:GetValue("FQL_PERMAQ")
		LOCA248LIB()
		oModelFQL:SetValue("FQL_VLMAQ", (nValTotMed * nTemp1)/100 )

		// cálculo valor da filial do operador
		// Exclui o campo FQL_PERMAO
		//nTemp1 := oModelFQL:GetValue("FQL_PERMAO")
		//oModelFQL:SetValue("FQL_VLMAO", (nValTotMed * nTemp1)/100 )

	EndIf

	LOCA248BLQ()

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))
		
Return lRet

/*/{PROTHEUS.DOC} LOCA24803
ITUP BUSINESS - TOTVS RENTAL
Validação dos campos FQL_HORAI E FQL_HORAF
Frank Z Fuga
07/08/2024
/*/

Function LOCA24803(_HORCAL)
Return .T.

/*/{PROTHEUS.DOC} LOCA24813
ITUP BUSINESS - TOTVS RENTAL
Tratamento do x3_when tabela FQL
Frank Z Fuga
07/08/2024
/*/

FUNCTION LOCA24813()
Local lRet := .T.
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cErro := ""

	If oModelFQL:GetValue("FQL_LIBER") == "1" 
		cErro := STR0069 //"O item da medição não pode ser alterado, pois já foi liberado"
		lRet := .F.
	EndIf

	If !lRet
		Help( ,, "LOCA248-LOCA24813",, STR0002, 1, 0,,,,,,{cErro}) //"Inconsistência nos dados."
	EndIf

return lRet

/*/{PROTHEUS.DOC} LOCA24814
ITUP BUSINESS - TOTVS RENTAL
Tratamento do x3_when tabela FQL
Frank Z Fuga
07/08/2024
/*/

FUNCTION LOCA24814()
return .T.

/*/{PROTHEUS.DOC} LOCA248H
ITUP BUSINESS - TOTVS RENTAL
Criar as linhas na grid
Frank Z Fuga
12/08/2024
/*/  

FUNCTION LOCA248H()
Local xRet
	If !empty(M->FQK_DTINIC) .and. !empty(M->FQK_DTFIM)
		Processa({|| xRet := LOCA248H3()},STR0086) // "Aguarde... localizando os dados"
	EndIF
Return .T. //xRet

/*/{PROTHEUS.DOC} LOCA248H3
ITUP BUSINESS - TOTVS RENTAL
Criar as linhas na grid
Frank Z Fuga
12/08/2024
/*/

FUNCTION LOCA248H3()
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local oView := FWViewActive() 
Local cGrupo 
Local aArea := GetArea()
Local nI
Local lExist
Local lEdita 
Local lTem
Local cgrpand
Local nPonteiro
Local aAreaFPA

Private cNatureza := ""

	ProcRegua(0)

	cGrupo := M->FQK_GRPMD

	If alltrim(ReadVar()) == "M->FQK_GRPMD"
		cGrupo := &(ReadVar())
	EndIf

	If SBM->(FieldPos("BM_XACESS")) > 0
		cgrpand := LOCA00189()
	Else
		cgrpand := SuperGetMV("MV_LOCX014",.F.,"")
	EndIf

	IncProc()

	If lInclui
		oModelFQL:ClearData()
	EndIf

	// Posicionar na FP0 para efeito do gatilho do campo FQK_PROJET
	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0")+M->FQK_PROJET))

	If M->FQK_TPMED == "G"

		// Geração dos itens para locações

		FPA->(dbSetOrder(1))
		FPA->(dbSeek(xFilial("FPA")+M->FQK_PROJET))
		While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET) == xFilial("FPA")+M->FQK_PROJET

			IncProc()
			SysRefresh()
			
			aAreaFPA := FPA->(GetArea()) // Circenis alguma função troca o indice da FPA 
			
			// Medição somente para AS gerada
			If empty(FPA->FPA_AS)
				FPA->(dbSkip())
				Loop
			EndIf

			If FPA->FPA_TIPOSE == "M"
				FPA->(dbSkip())
				Loop
			EndIF

			If FPA->FPA_GRUPOM <> M->FQK_GRPMD
				FPA->(dbSkip())
				Loop
			EndIf

			// A AS precisar estar aprovada
			FQ5->(dbSetOrder(9))
			FQ5->(dbSeek(xFilial("FQ5")+FPA->FPA_AS))
			If FQ5->FQ5_STATUS <> "6"
				FPA->(dbSkip())
				Loop
			EndIf

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))

			// Se for de acessório não trazer a AS
			If ALLTRIM(SB1->B1_GRUPO) $ Alltrim(cGrupo) //ALLTRIM(CGRPAND)
				FPA->(dbSkip())
				Loop
			EndIf

			// Verificar se esta AS foi usada em alguma medicao ativa do tipo AS
			lTem := .F.
			FQK->(dbSetOrder(2))
			FQK->(dbSeek(xFilial("FQK")+FPA->FPA_AS))
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+M->FQK_AS
				If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6"
					lTem := .T.
					exit
				EndIf
				FQK->(dbSkip())
			EndDo
			If lTem
				FPA->(dbSkip())
				Loop
			EndIf

			If empty(cNatureza)
				cNatureza := FPA->FPA_NATURE
			EndIf

			// Verificar se o item já existe no grid
			lExist := .F.
			nPonteiro := oModelFQL:GetLine()
			For nI := 1 to oModelFQL:Length()
				oModelFQL:GoLine(nI)
				If oModelFQL:GetValue("FQL_GRPMD") == cGrupo .and. !oModelFQL:IsDeleted()
					If FPA->FPA_AS == oModelFQL:GetValue("FQL_AS") 
						lExist := .T.
					EndIF
				EndIF
			Next
			oModelFQL:GoLine(nPonteiro)

			If !lExist 
				lEdita := .F.
				nPonteiro := oModelFQL:GetLine()
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_AS"))
						lEdita := .T.
						Exit
					EndIF
				Next
				oModelFQL:GoLine(nPonteiro)
				
				If LOCA248C4() // valida se o movimento pode popular a grid
					If lEdita 
						LOCA248AG(nI,"G")
					Else
						oModelFQL:AddLine()
						LOCA248AG(nI,"G")
					EndIf
				EndIf

			EndIf

			RestArea(aAreaFPA)// Circenis retorno ao estado anterior para fazer o laço corretamente 
			FPA->(dbSkip())
		EndDo

		oModelFQL:GoLine(1)

		//25/09/25 - DSERLOCA-8649 - Frank Fuga - Preenchimento da data de expedição
		LOCA248B9()
		oModelFQL:GoLine(1)

		oView:Refresh()

	Else // M->FQK_TPMED == "A"

		// Verificar se esta AS foi usada em alguma medicao ativa do tipo grupo
		lTem := .F.
		FQK->(dbSetOrder(2))
		FQK->(dbSeek(xFilial("FQK")+M->FQK_AS))
		While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+M->FQK_AS
			IncProc()
			If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6"
				lTem := .T.
				exit
			EndIf
			FQK->(dbSkip())
		EndDo
		If lTem
			Help( ,, "LOCA248-LOCA248H",, STR0002, 1, 0,,,,,,{STR0064}) //"Inconsistência nos dados."###"Conflito entre movimentos de Grupo x AS"
			Return .F.
		EndIf  

		FPA->(dbSetOrder(3))
		If FPA->(dbSeek(xFilial("FPA")+M->FQK_AS))
			IncProc()
			// A AS precisar estar aprovada
			FQ5->(dbSetOrder(9))
			FQ5->(dbSeek(xFilial("FQ5")+FPA->FPA_AS))
			If FQ5->FQ5_STATUS == "6" .and. FPA->FPA_TIPOSE <> "M"
				If empty(cNatureza)
					cNatureza := FPA->FPA_NATURE
				EndIf

				// Verificar se o item já existe no grid
				lExist := .F.
				For nI := 1 to oModelFQL:Length()
					oModelFQL:GoLine(nI)
					If oModelFQL:GetValue("FQL_AS") == M->FQK_AS .and. !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
						lExist := .T.
					EndIF
				Next

				If !lExist
					lEdita := .F.
					For nI := 1 to oModelFQL:Length()
						oModelFQL:GoLine(nI)
						If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_AS"))
							lEdita := .T.
							Exit
						EndIF
					Next

					If LOCA248C4() // valida se o movimento pode popular a grid
						If lEdita
							LOCA248AG(nI,"A")
						Else
							oModelFQL:AddLine()
							LOCA248AG(nI,"A")
						EndIf
					EndIf

				EndIf

			EndIf
		EndIf

	EndIf

	// Tratamento para os bens reservas
	LOCA248BC(.F.)  
	IncProc()
	
	oModelFQL:GoLine(1)
	If empty(cNatureza)
		M->FQK_NATUR := cNatureza
	EndIf

	// Tratamento para as minutas
	LOCA248BM()
	IncProc()

	// Tratamento para o preenchimento da data de envio e retorno
	LOCA248B9()  
	IncProc()

	// Tratamento para o preenchimento com base nas medições anteriores
	//LOCA248B91()
	IncProc()

	// Tratamento para excluir as linhas que já tiveram nota de devolucao
	LOCA248BG()

	// Tratamento para Mão de Obra - Inicio Circenis
	LOCA248MO( .F.)

	//25/09/25 - DSERLOCA-8649 - Frank Fuga - Preenchimento da data de expedição
	LOCA248B9()
	oModelFQL:GoLine(1)

	IncProc()
	// Fim - Circenis
	oModelFQL:GoLine(1)
	oView:Refresh("FQLDETAIL")

	IncProc()

	RestArea(aArea)
Return If(M->FQK_TPMED == "G", cNatureza, .T.)

/*/{PROTHEUS.DOC} LOCA248AG
ITUP BUSINESS - TOTVS RENTAL
Preencher as linhas na grid quando for do tipo Grupo
Frank Z Fuga
12/08/2024
/*/

Function LOCA248AG(nI,cTipo,cMao)      //GridPrenche(nI,cTipo)
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
//Local cTes := SuperGetMv("MV_LOCX186",,"") 

Default cMao := "L"

	oModelFQL:GoLine(nI)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_AS", FPA->FPA_AS)
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
	
	If oModelFQL:GetValue("FQL_BASE") $ "HCOD"
		If cMao == "L"
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALHOR", FPA->FPA_VLHREX)
		ElseIf cMao == "M"
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALHOR", FPA->FPA_PRCUNI)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_TPAS", "M")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_TURNO", "")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_KMINI", 0)
		ElseIf cMao == "T"
			LOCA248LIB()
			oModelFQL:SetValue("FQL_VALHOR", FPE->FPE_VROPER)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_TPAS", "M")
			LOCA248LIB()
			oModelFQL:SetValue("FQL_TURNO", FPE->FPE_TURNO)
			LOCA248LIB()
			oModelFQL:SetValue("FQL_KMINI", 0)
		EndIf
	EndIf

	If empty(FWFldGet("FQK_CONDPA"))
		FWFldPut("FQK_CONDPA",FPA->FPA_CONPAG)
	EndIf

	cNatureza := FPA->FPA_NATURE

	If empty(FWFldGet("FQK_NATUR")) .and. VALTYPE(cNatureza) == "C"
		FWFldPut("FQK_NATUR",cNatureza)
	EndIf

	LOCA248BLQ()

Return 

/*/{PROTHEUS.DOC} LOCA248I
ITUP BUSINESS - TOTVS RENTAL
Uso no gatilho do campo FQL_AS
Frank Z Fuga
13/08/2024
/*/

Function LOCA248I()
Local aAreaFPA := FPA->(GetArea())
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local lSeguro := .T.
Local cProjeto
Local cGrupoMed 
Local cAs
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local nMob := 0
Local nDes := 0

	cAs := oModelFQL:GetValue("FQL_AS")
	
	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+cAs))

	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0")+FPA->FPA_PROJET))

	LOCA248LIB()
	oModelFQL:SetValue("FQL_FROTA", FPA->FPA_GRUA)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_DESCEQ", Posicione("ST9",1,xFilial("ST9")+FPA->FPA_GRUA,"T9_NOME"))
	LOCA248LIB()
	oModelFQL:SetValue("FQL_CCUSTO", FPA->FPA_CUSTO)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_FRKM", FPA->FPA_HRFRAQ)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_OBRA", FPA->FPA_OBRA)
	if FPA->FPA_TIPOSE <> "M"
		LOCA248LIB()
		oModelFQL:SetValue("FQL_TURNO", Posicione("FPE",2,xFilial("FPE")+FPA->FPA_PROJET+FPA->FPA_OBRA+FPA->FPA_SEQGRU,"FPE_TURNO"))
	else
		LOCA248LIB()
		oModelFQL:SetValue("FQL_VALHOR", FPA->FPA_VRHOR)
	endif
	LOCA248LIB()
	oModelFQL:SetValue("FQL_MINDIA", FPA->FPA_MINDIA)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_PROD", FPA->FPA_PRODUT)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_DTMEDI", dDataBase)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_GRPMD", FPA->FPA_GRUPOM)

	// Validacao para indentifica se registramos o seguro, não pode haver em medições antetiores itens faturados
	lSeguro := .T.
	If M->FQK_TPMED == "A"
		cAs := M->FQK_AS
		FQK->(dbSetOrder(2))
		FQK->(dbSeek(xFilial("FQK")+cAs))
		While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
			If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" //.and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ

				FQL->(dbSetOrder(6))
				If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
					nMob += FQL->FQL_VLRMOB
					nDes += FQL->FQL_VLRDES
				EndIf

				If !empty(FQK->FQK_FILPV)
					lSeguro := .F.
				EndIf
			EndIf
			FQK->(dbSkip()) 
		EndDo
	Else
		// Em grupo a FPA já está posicionada neste momento
		cProjeto := FPA->FPA_PROJET
		cGrupoMed := M->FQK_GRPMD
		cAs := FPA->FPA_AS
		FQL->(dbSetOrder(6))
		FQL->(dbSeek(xFilial("FQL")+cAs))
		While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
			FQK->(dbSetOrder(1))
			If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
				If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" //.and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
					If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed

						nMob += FQL->FQL_VLRMOB
						nDes += FQL->FQL_VLRDES

						If !empty(FQK->FQK_FILPV)
							lSeguro := .F.
						EndIf
					EndIf
				EndIf
			EndIf
			FQL->(dbSkip())
		EndDo
	EndIF

	LOCA248LIB()
	oModelFQL:SetValue("FQL_TPISS", FPA->FPA_TPISS)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_PERISS", FPA->FPA_PERISS)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_VALISS", FPA->FPA_VRISS)
	
	nMob := FPA->FPA_VRMOB - nMob
	nDes := FPA->FPA_VRDES - nDes

	If nMob < 0
		nMob := 0
	EndIf
	If nDes < 0
		nDes := 0
	EndIf
	
	LOCA248LIB()
	oModelFQL:SetValue("FQL_VLRMOB", nMob)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_VLRDES", nDes)
		
	If lSeguro
		LOCA248LIB()
		oModelFQL:SetValue("FQL_TIPO", FPA->FPA_TPSEGU) 
		LOCA248LIB()
		oModelFQL:SetValue("FQL_VLBSEG", FPA->FPA_VRCARG)  
		LOCA248LIB()
		oModelFQL:SetValue("FQL_VALSEG", FPA->FPA_VRSEGU )
		LOCA248LIB()
		oModelFQL:SetValue("FQL_PERSEG", FPA->FPA_PERSEG)
	EndIf

	LOCA248LIB()
	oModelFQL:SetValue("FQL_PERMAQ", 0)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_PERMO", FPA->FPA_PERMAO)
	LOCA248LIB()
	oModelFQL:SetValue("FQL_PERMAQ", 100-FPA->FPA_PERMAO)

	FPA->(RestArea(aAreaFPA))
	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))
	RestArea(aArea)

	LOCA248BLQ()

Return cAs

/*/{PROTHEUS.DOC} LOCA24806
ITUP BUSINESS - TOTVS RENTAL
Validacao dos campos
Frank Z Fuga
13/08/2024
/*/
Function LOCA24806
Return .T.

/*/{PROTHEUS.DOC} LOCA24807
ITUP BUSINESS - TOTVS RENTAL
Usado na consulta padrão FPAGRP
Frank Z Fuga
13/08/2024
/*/
Function LOCA24807(lGrupo)
Local lRet := .T.
Local cgrpand
Default lGrupo := .F.

	If !lGrupo 
		// Posicionar na FPA
		FPA->(dbSetOrder(3))
		FPA->(dbSeek(xFilial("FPA")+FQ5->FQ5_AS))
	EndIf

	If SBM->(FieldPos("BM_XACESS")) > 0
		cgrpand := LOCA00189()
	Else
		cgrpand := SuperGetMV("MV_LOCX014",.F.,"")
	EndIf

	If empty(FPA->FPA_AS)
		lRet := .F.
	EndIf
	If empty(FPA->FPA_GRUPOM) .and. lGrupo
		lRet := .F.
	EndIf
	If FPA->FPA_PROJET <> M->FQK_PROJET
		lRet := .F.
	EndIf

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+FPA->FPA_PRODUT))
	
	// Se for de acessório não trazer a AS
	If ALLTRIM(SB1->B1_GRUPO) $ ALLTRIM(CGRPAND)
		lRet := .F.
	EndIf

	// Mão de obra está dentro da regra do B1_GRUPO negativado acima
	If SB1->B1_TIPO == "MO" .and. FPA->FPA_PROJET == M->FQK_PROJET
		lRet := .T.
	EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA248J
ITUP BUSINESS - TOTVS RENTAL
Validacao da AS - FQL_AS
Frank Z Fuga
13/08/2024
/*/
Function LOCA248J(cCampo)
Local lRet := .T.
Local aArea := GetArea()
Local cAs
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local lAntigo := .F.

	cCampo := alltrim(cCampo)

	If cCampo == "FQK_AS"
		cAs := M->FQK_AS
	Else
		cAs := oModelFQL:GetValue("FQL_AS")
	EndIf

	If !empty(cAs)

		FQ5->(dbSetOrder(9))
		FQ5->(dbSeek(xFilial("FQ5")+cAs))
		If FQ5->FQ5_STATUS <> "6" .or. FQ5->FQ5_SOT <> M->FQK_PROJET
			Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0062}) //"Inconsistência nos dados."###"AS inválida"
			lRet := .F.
		EndIf

		// Se a AS foi utilizada na medicao sem ser o projeto MVC
		FPN->(dbSetOrder(2))
		If FPN->(dbSeek(xFilial("FPN")+cAs))
			While !FPN->(Eof()) .and. FPN->(FPN_FILIAL+FPN_AS) == xFilial("FPN")+cAs
				If FPN->FPN_SITUAC <> "6" .and. empty(FPN->FPN_NUMPV)
					lRet := .F.
					lAntigo := .T.
				EndIf
				FPN->(dbSkip())
			EndDo
		EndIf

		If !lRet .and. lAntigo
			Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0114}) //"Inconsistência nos dados."###"Esta AS foi utilizada no sistema antigo de medições, operação bloqueada."
		EndIf

	EndIf

	RestArea(aArea)
Return lRet

/*/{PROTHEUS.DOC} LOCA248A1
ITUP BUSINESS - TOTVS RENTAL
Validação das datas inicial e final
Frank Z Fuga
13/08/2024
/*/
Function LOCA248A1()
Local dVar := &(ReadVar())
Local lRet := .T.
Local aArea := GetArea()
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local cAs
Local lValFPA
Local cErroFPA := ""

	// Validação da data final
	// Não pode permitir alterar se houver uma medição com sequencia maior
	If alltrim(ReadVar()) == "M->FQK_DTFIM"
		If M->FQK_TPMED == "A"
			FQK->(dbSetOrder(2))
			FQK->(dbSeek(xFilial("FQK")+M->FQK_AS))
			While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+M->FQK_AS
				If FQK->FQK_MEDSEQ > M->FQK_MEDSEQ .and. FQK->FQK_SITUAC <> "6"
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
					RestArea(aArea)
					Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0115}) //"Inconsistência nos dados."###"A data final não pode ser editada, pois existe uma medição posterior."
					Return .F.
				EndIf
				FQK->(dbSkip())
			EndDo
		Else
			FQK->(dbSetOrder(6))
			FQK->(dbSeek(xFilial("FQK")+M->FQK_PROJET))
			While !FQK->(Eof()) .and. FQK->FQK_FILIAL == xFilial("FQK") .and. FQK->FQK_PROJET == M->FQK_PROJET
				If FQK->FQK_MEDSEQ > M->FQK_MEDSEQ .and. FQK->FQK_SITUAC <> "6" 
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
					RestArea(aArea)
					Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0115}) //"Inconsistência nos dados."###"A data final não pode ser editada, pois existe uma medição posterior."
					Return .F.
				EndIF
				FQK->(dbSkip())
			EndDo

			/* DSERLOCA-7445 
			Frank em 11/07/25
			Validar em todas as linhas da FPA deste grupo os bens.
			Se o status do bem for em branco identifica que é uma minuta.
			Sendo uma minuta, temos que verificar se existem registros de minutas baixadas <= a data fim
			Se existir, temos que validar os campos da FPA se estão devidamente preenchidos
			*/
			FPA->(dbSetOrder(1))
			FPA->(dbSeek(xFilial("FPA")+M->FQK_PROJET))
			While !FPA->(Eof()) .and. FPA->FPA_PROJET == M->FQK_PROJET
				If FPA->FPA_GRUPOM == M->FQK_GRPMD
					If !empty(FPA->FPA_GRUA)
						ST9->(dbSetOrder(1))
						If ST9->(dbSeek(xFilial("ST9")+FPA->FPA_GRUA))
							If empty(ST9->T9_STATUS) // em branco indica ser uma minuta

								lValFPA := .F.
								cAs := FPA->FPA_AS
								FPF->(dbSetOrder(4))
								FPF->(dbSeek(xFilial("FPF")+cAs))
								While !FPF->(Eof()) .and. FPF->FPF_FILIAL == xFilial("FPF") .and. FPF->FPF_AS == cAs
									If FPF->FPF_STATUS == "3" 
										If FPF->FPF_DATA <= M->FQK_DTFIM
											lValFPA := .T.
											Exit
										EndIf
									EndIf
									FPF->(dbSkip())
								EndDo

								If lValFPA
									If FPA->FPA_TPBASE <> "H"
										If empty(cErroFPA)
											cErroFPA += STR0141+"<p>AS - "+alltrim(FPA->FPA_AS)+"<br>" //Existe uma não conformidade no(s) registro(s) do contrato. Verifique o preenchimento dos campos “base de cálculo” e “tipo de franquia”.  Deseja continuar ?
										EndIf
										cErroFPA += STR0139+"<br>" //"Base de cálculo <> Horas"
									EndIf
									If FPA->FPA_TIPOCA <> "H"
										If empty(cErroFPA)
											cErroFPA += STR0141+"<p>AS - "+alltrim(FPA->FPA_AS)+"<br>" //Existe uma não conformidade no(s) registro(s) do contrato. Verifique o preenchimento dos campos “base de cálculo” e “tipo de franquia”.  Deseja continuar ?
										EndIf
										cErroFPA += STR0140+"<br>" //"Tipo de franquia <> Horas"
									EndIf
								EndIf

							EndIf
						EndIF
					EndIf
				EndIf
				FPA->(dbSkip())
			EndDo

		EndIF
	EndIF

	If !empty(cErroFPA)
		If !MsgYesNo(cErroFPA,"Rental") //"Existe uma falha no registro do contrato, verifique o preenchimento da base de cálculo e do tipo de franquia."
			FQK->(RestArea(aAreaFQK))
			FQL->(RestArea(aAreaFQL))
			FPA->(RestArea(aAreaFPA))
			RestArea(aArea)
			Help( ,, "LOCA248",, STR0002, 1, 0,,,,,,{STR0142}) //"Inconsistência nos dados."###"Ajuste o contrato."
			Return .F.
		EndIf
	EndIf

	If !empty(M->FQK_PMEDI)
		FQJ->(dbSetOrder(1))
		FQJ->(dbSeek(xFilial("FQJ")+M->FQK_PMEDI))

		If empty(dVar)
			lRet := .F.
		EndIf

	EndIf

	If !lRet
		Help( ,, "LOCA248-LOCA248J",, STR0002, 1, 0,,,,,,{STR0063}) //"Inconsistência nos dados."###"O dia informado não é correspondente com o período da medição"
	EndIf

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))
	FPA->(RestArea(aAreaFPA))
	RestArea(aArea)

Return lRet


/*/{PROTHEUS.DOC} FCHKCONTAB
ITUP BUSINESS - TOTVS RENTAL
Validação da data da medição
Frank Z Fuga
20/08/2024
/*/

Static Function FCHKCONTAB(dMedicao)
Local lRet := .T. 
Local aArea := GetArea() 
Local dDatIni := ctod("")
Local dDatFim := ctod("")
Local lVldTmp := SUPERGETMV("MV_LOCX222",.F.,.T.) 
Local cErro := ""
Local aAreaFQ5
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cAs := oModelFQL:GetValue("FQL_AS")
Local cViagem

	If empty(cAs)
		lRet := .F.
		cErro := STR0062 // AS inválida
	EndIf

	If lRet 
		If !LOCA02003(dMedicao) // Verifica a data do período financeiro
			lRet := .F.
		EndIF
	EndIf

	If lVldTmp .and. lRet
		aAreaFQ5 := FQ5->(GetArea())
		FPA->(dbSetOrder(3))
		FPA->(dbSeek(xFilial("FPA")+cAs))
		cViagem := FPA->FPA_VIAGEM
		FQ5->(dbSetOrder(9))	
		FQ5->(dbSeek(xFilial("FQ5")+cAs+cViagem))
		
		While !FQ5->(Eof()) .and. FQ5->FQ5_FILIAL==xFilial("FQ5") .and. FQ5->FQ5_AS == cAs .and. FQ5->FQ5_VIAGEM == cViagem
			dDatIni	:= FQ5->FQ5_DATINI 
			dDatFim	:= FQ5->FQ5_DATFIM 
			FQ5->(dbSkip()) 
		EndDo
		FQ5->(RestArea(aAreaFQ5)) 
		
		If (dMedicao < dDatIni .or. dMedicao > dDatFim) 
			cErro := STR0066 //"Data da medição fora do período da AS."
			lRet := .F. 
		EndIf
	EndIf

	RestArea(aArea)

	If !lRet .and. !empty(cErro) 
		Help( ,, "LOCA248-FCHKCONTAB",, STR0002, 1, 0,,,,,,{cErro}) //"Inconsistência nos dados."
	EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA248A8
ITUP BUSINESS - TOTVS RENTAL
Validação se o projeto pode ser medido
Frank Z Fuga
20/08/2024  
/*/

Function LOCA248A8
Local lRet := .T.

	FP0->(dbSetOrder(1))
	If FP0->(dbSeek(xFilial("FP0")+M->FQK_PROJET))
		If empty(FP0->FP0_TPFRAN)
			Help( ,, "LOCA248A-LOCA248A8",, STR0002, 1, 0,,,,,,{STR0095}) //"Inconsistência nos dados."###"O campo tipo de consumo de franquia no cadastro do projeto não foi preenchido."
			lRet := .F.
		EndIF
	EndIf

Return lRet  


/*/{PROTHEUS.DOC} LOCA248B91
ITUP BUSINESS - TOTVS RENTAL
Preencher as informações com base na medicao anterior se existir
Somente para itens que não sejam minutas e que não sejam carro reserva
Frank Z Fuga
20/08/2024  
/*/
Function LOCA248B91
Local nI
Local nPonteiro
Local lTem := .F. // Existe medição anterior valida
Local cSeq := ""
Local cCod := ""
Local cAs
Local aAs := {}
Local nX
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local nKm
Local aAreaFQK := FQK->(GetArea())
Local aAreaFQL := FQL->(GetArea())
Local cFrota
Local dData := ctod("")
Local nPeriodo := 0
Local lForca := .F.
Local cBemRes
Local cTpHora
Local dRefere

	If lInclui .or. FWIsInCallStack("LOCA248C5") // atualizar o saldo inicial se for inclusao, ou atualizar 

		nPonteiro := oModelFQL:GetLine()
		For nI := 1 to oModelFQL:Length()
			IncProc()
			oModelFQL:GoLine(nI)
			If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES")) .and. !empty(oModelFQL:GetValue("FQL_AS"))
				cAs := oModelFQL:GetValue("FQL_AS")

				FPA->(dbSetOrder(3))
				FPA->(dbSeek(xFilial("FPA")+cAs))

				// Nao processar minutas
				If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
					FQL->(dbSkip())
					Loop
				EndIf

				// Para medicoes > 001
				// Se o bem não estava na medicao anterior forcar o valor inicial, para o tipo contador
				lForca := .F.
				If oModelFQL:GetValue("FQL_BASE") == "C" .and. M->FQK_MEDSEQ > "001"
					lForca := .T.
					cBemRes := oModelFQL:GetValue("FQL_BEMRES")
					If M->FQK_TPMED == "A"
						FQL->(dbSetOrder(6))
						FQL->(dbSeek(xFilial("FQL")+cAs))
						While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS) == xFilial("FQL")+cAs
							FQK->(dbSetOrder(1))
							FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
							If FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
								If FQL->FQL_AS == cAs .and. FQL->FQL_BEMRES == cBemRes
									lForca := .F.
									Exit
								EndIf
							EndIF
							FQL->(dbSkip())
						EndDo
					Else
						FQK->(dbSetOrder(6))
						FQK->(dbSeek(xFilial("FQK")+M->FQK_PROJET))
						While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_PROJET) == xFilial("FQK")+M->FQK_PROJET
							If FQK->FQK_SITUAC <> "6" .and. FQK->FQK_GRPMD == M->FQK_GRPMD .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
								FQL->(dbSetOrder(5))
								FQL->(dbSeek(xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)))
								While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_COD+FQL_ORDEM) == xFilial("FQL")+FQK->(FQK_COD+FQK_MEDSEQ)
									If FQL->FQL_AS == cAs .and. FQL->FQL_BEMRES == cBemRes
										lForca := .F.
										Exit
									EndIf
									FQL->(dbSkip())
								EndDo
							EndIF
							FQK->(dbSkip())
							If !lForca
								Exit
							EndIf
						EndDo
					EndIF
					FQK->(RestArea(aAreaFQK))
					FQL->(RestArea(aAreaFQL))
				EndIF

				// Nova regra para os tipos Contador
				// Frank Fuga em 10/03/2025 - ISSUE 5636
				If oModelFQL:GetValue("FQL_BASE") == "C"

					// Tratamento para o Km Inicial
					dRefere := oModelFQL:GetValue("FQL_DTSAID")
					If M->FQK_MEDSEQ == "001" .and. empty(dRefere)
						dRefere := M->FQK_DTINIC
					EndIf  
					If !empty(dRefere)
						cFrota := oModelFQL:GetValue("FQL_FROTA")
						STP->(dbSetOrder(5))
						STP->(dbSeek(xFilial("STP")+cFrota))
						dData := ctod("") 
						nPeriodo := 0
						While !STP->(Eof()) .and. STP->(TP_FILIAL+TP_CODBEM) == xFilial("STP") + cFrota
							If STP->TP_DTLEITU > dData .and. STP->TP_DTLEITU <= dRefere //M->FQK_DTFIM
								dData := STP->TP_DTLEITU
							EndIf
							STP->(dbSkip())
						EndDo  

						// Tratamento para pegar a posicao do contador da maior data do período encontrado
						// Frank em 10/03/2025 - ISSUE 5636
						If !empty(dData)
							STP->(dbSeek(xFilial("STP")+cFrota))
							cTpHora := ""
							While !STP->(Eof()) .and. STP->(TP_FILIAL+TP_CODBEM) == xFilial("STP") + cFrota
								If STP->TP_DTLEITU == dData
									If STP->TP_HORA > cTpHora
										cTpHora := STP->TP_HORA
										nPeriodo := STP->TP_POSCONT
									EndIf
								EndIf
								STP->(dbSkip())
							EndDo

							LOCA248LIB()
							If oModelFQL:GetValue("FQL_KMINI") == 0
								If oModelFQL:GetValue("FQL_TPAS") <> "M"
									oModelFQL:SetValue("FQL_KMINI",nPeriodo)
								EndIF
							EndIf
						EndIf
					EndIf

					// Tratamento para o KM Final
					dRefere := M->FQK_DTFIM
					If !empty(oModelFQL:GetValue("FQL_DTENT"))
						dRefere := oModelFQL:GetValue("FQL_DTENT")
					EndIf
					If !empty(dRefere)

						cFrota := oModelFQL:GetValue("FQL_FROTA")
						STP->(dbSetOrder(5))
						STP->(dbSeek(xFilial("STP")+cFrota))
						dData := ctod("") 
						nPeriodo := 0
						While !STP->(Eof()) .and. STP->(TP_FILIAL+TP_CODBEM) == xFilial("STP") + cFrota
							If STP->TP_DTLEITU > dData .and. STP->TP_DTLEITU <= dRefere 
								dData := STP->TP_DTLEITU
							EndIf
							STP->(dbSkip())
						EndDo  

						// Tratamento para pegar a posicao do contador da maior data do período encontrado
						// Frank em 10/03/2025 - ISSUE 5636
						If !empty(dData)
							STP->(dbSeek(xFilial("STP")+cFrota))
							cTpHora := ""
							While !STP->(Eof()) .and. STP->(TP_FILIAL+TP_CODBEM) == xFilial("STP") + cFrota
								If STP->TP_DTLEITU == dData
									If STP->TP_HORA > cTpHora
										cTpHora := STP->TP_HORA
										nPeriodo := STP->TP_POSCONT
									EndIf
								EndIf
								STP->(dbSkip())
							EndDo

							LOCA248LIB()
							If oModelFQL:GetValue("FQL_KMFIM") == 0
								If oModelFQL:GetValue("FQL_TPAS") <> "M"
									oModelFQL:SetValue("FQL_KMFIM",nPeriodo)
								EndIF
							EndIf

						EndIf

					EndIf

				EndIf

				lTem := .F.
				nKm := 0
				FQL->(dbSetOrder(6))
				If FQL->(dbSeek(xFilial("FQL")+cAs))
					cSeq := ""
					While !FQL->(Eof()) .and. FQL->(FQL_FILIAL+FQL_AS) == xFilial("FQL")+cAs
						FQK->(dbSetOrder(1))
						FQK->(dbSeek(xFilial("FQK")+FQL->FQL_COD+FQL->FQL_ORDEM))
						If FQK->FQK_SITUAC <> "6" .and. FQK->FQK_TPMED == M->FQK_TPMED
							If FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
								If cSeq < FQK->FQK_MEDSEQ
									cSeq := FQK->FQK_MEDSEQ
									cCod := FQK->FQK_COD
									nKm := FQL->FQL_KMFIM
									lTem := .T.
								EndIf
							EndIF
						EndIF
						FQL->(dbSkip())
					EndDo
				EndIf

				If lTem
					FQL->(dbSeek(xfilial("FQL")+cAs+cCod+cSeq))
					aadd(aAs,{cAs,nKm})
				EndIf

			EndIF
		Next
		oModelFQL:GoLine(nPonteiro)

		If len(aAs) > 0

			// Campos que serão atualizados com base na medição anterior
			// FQL_KMINI

			nPonteiro := oModelFQL:GetLine()
			For nI := 1 to oModelFQL:Length()
				IncProc()
				oModelFQL:GoLine(nI)
				If !oModelFQL:IsDeleted() .and. empty(oModelFQL:GetValue("FQL_BEMRES"))
					For nX := 1 to len(aAs)
						If oModelFQL:GetValue("FQL_AS") == aAs[nX,1]
							LOCA248LIB()
							If oModelFQL:GetValue("FQL_KMINI") == 0
								If oModelFQL:GetValue("FQL_TPAS") <> "M"
									oModelFQL:SetValue("FQL_KMINI",aAs[nX,2])
								EndIF
							EndIF
						EndIf
					Next
				EndIF
			Next
			oModelFQL:GoLine(nPonteiro)
		EndIf
	EndIf

	LOCA248BLQ()

	FQK->(RestArea(aAreaFQK))
	FQL->(RestArea(aAreaFQL))

Return

/*/{PROTHEUS.DOC} LOCA248B92
ITUP BUSINESS - TOTVS RENTAL
Validação dos campos MOB e DESMOB
Frank Z Fuga
20/08/2024  
/*/
Function LOCA248B92(PCAMPO)
Local lRet := .T.
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")
Local cAs := oModelFQL:GetValue("FQL_AS")
Local aAreaFPA := FPA->(GetArea())
Local nMob := 0
Local nDes := 0
Local cProjeto
Local cGrupoMed

	FPA->(dbSetOrder(3))
	FPA->(dbSeek(xFilial("FPA")+cAs))

	If M->FQK_TPMED == "A"
		cAs := M->FQK_AS
		FQK->(dbSetOrder(2))
		FQK->(dbSeek(xFilial("FQK")+cAs))
		While !FQK->(Eof()) .and. FQK->(FQK_FILIAL+FQK_AS) == xFilial("FQK")+cAs
			If FQK->FQK_TPMED == "A" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
				FQL->(dbSetOrder(6))
				If FQL->(dbSeek(xFilial("FQL")+cAs+FQK->(FQK_COD+FQK_MEDSEQ)))
					nMob += FQL->FQL_VLRMOB
					nDes += FQL->FQL_VLRDES
				EndIf
			EndIf
			FQK->(dbSkip()) 
		EndDo
	Else
		// Em grupo a FPA já está posicionada neste momento
		cProjeto := FPA->FPA_PROJET
		cGrupoMed := M->FQK_GRPMD
		cAs := FPA->FPA_AS
		FQL->(dbSetOrder(6))
		FQL->(dbSeek(xFilial("FQL")+cAs))
		While !FQL->(Eof()) .and. FQL->FQL_AS == cAs
			FQK->(dbSetOrder(1))
			If FQK->(dbSeek(xFilial("FQK")+FQL->(FQL_COD+FQL_ORDEM)))
				If FQK->FQK_TPMED == "G" .and. FQK->FQK_SITUAC <> "6" .and. FQK->FQK_MEDSEQ < M->FQK_MEDSEQ
					If FQK->(FQK_PROJET+FQK_GRPMD) == cProjeto+cGrupoMed
						nMob += FQL->FQL_VLRMOB
						nDes += FQL->FQL_VLRDES  
					EndIf
				EndIf
			EndIf
			FQL->(dbSkip())
		EndDo
	EndIF

	If PCAMPO == "FQL_VLRMOB"
		If M->FQL_VLRMOB + nMob > FPA->FPA_VRMOB
			lRet := .F.
		EndIf
	EndIf

	If PCAMPO == "FQL_VLRDES"
		If M->FQL_VLRDES + nDes > FPA->FPA_VRDES
			lRet := .F.
		EndIf
	EndIf

	If !lRet
		Help( ,, "LOCA248A-LOCA248B92",, STR0002, 1, 0,,,,,,{STR0109}) //"Inconsistência nos dados."###"O valor informado ultrapassa o especificado no projeto."
	EndIf

	FPA->(RestArea(aAreaFPA))

Return lRet

/*/{PROTHEUS.DOC} LOCA248001
ITUP BUSINESS - TOTVS RENTAL
Validação para o LOCA001
Frank Z Fuga
29/10/2024  
/*/
Function LOCA248001(lValTudo)
/*
Local lRet := .T.
Local nX
Local nPosFranqu := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_HRFRAQ"})
Local nPosBasFra := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_BASFRA"})
Local nPosTipoca := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TIPOCA"})
Local nPosTpBase := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TPBASE"})
Local nPosTipoSe := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TIPOSE"})
Local nPosProdut := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})
Local nPosGrupo := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GRUPOM"})
Local nPosMindia := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_MINDIA"})
Local nPosMinMes := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_MINMES"})
Local nPosConPag := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_CONPAG"})
Local nPosObra := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBRA"})
Local nPosSeqGui := ascan(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
Local lMedicao := .T.
Local cErro := ""
Local cgrpand
Local cProduto
Local aBase := {}
Local nY
Local cGrupo
Local cBase
Local lErro
Local aCompart := {}
Local cTipo
Local cTipFat
Local cConPag
Local cMsg

Default lValTudo := .F.
Default lTipFat  := .F.
Default lGat1    := .F.

	return .t.

	If SBM->(FieldPos("BM_XACESS")) > 0
		cgrpand := LOCA00189()
	Else
		cgrpand := SuperGetMV("MV_LOCX014",.F.,"")
	EndIf

    If FindFunction( "LOCA224B1" )
        If !LOCA224B1("FQK_FILIAL", "FQK") .or. file("\SYSTEM\248E2.TXT")
			lMedicao := .F.
		EndIf
        If !LOCA224B1("FP0_TPFRAN", "FP0") .or. file("\SYSTEM\248E3.TXT")
			lMedicao := .F.
		EndIf
	Else
		lMedicao := .F.  
	EndIf

	// Realizar as validações abaixo somente se a nova medição estiver instalada e o Tipo de Franquia estiver preenchido
	If !empty(M->FP0_TPFRAN) .and. lMedicao
		
		// A validação é executada ao salvar ou confirmar um orçamento (loca001)
		If lValTudo // tudo ok do loca001
			
			For nX := 1 to len(ODLGPLA:ACOLS)

				If ODLGPLA:aCols[nX][len(ODLGPLA:aHeader)+1]
					Loop
				EndIf

				cMsg := alltrim(M->FP0_PROJET)+"-"+alltrim(ODLGPLA:ACOLS[nX][nPosObra])+"-"+alltrim(ODLGPLA:ACOLS[nX][nPosSeqGui])
				
				// Se houver o valor da franquia forçar o preenchimento da base e do tipo da franquia
				If !empty(ODLGPLA:ACOLS[nX][nPosFranqu])
					If empty(ODLGPLA:ACOLS[nX][nPosBasFra]) .or. empty(ODLGPLA:ACOLS[nX][nPosTipoca])
						cErro := STR0118+" "+STR0124+cMsg //"Os campos Tp.Franquia e Base Franq. são obrigatórios."###"Projeto-Obra-Sequência: "
					EndIf					
				EndIf

				// Regras especificas para o tipo de faturamento Medicao e Minuta
				If M->FP0_TIPFAT == "M"
					If ODLGPLA:ACOLS[nX][nPosTpBase] == "H" .and. ODLGPLA:ACOLS[nX][nPosTipoca] == "H"
						If ODLGPLA:ACOLS[nX][nPosFranqu] > 0 .or. ODLGPLA:ACOLS[nX][nPosBasFra] <> ""
							cErro := STR0123+" "+STR0124+cMsg //"Movimentos de minuta não pode ser informado a base e nem a franquia."###"Projeto-Obra-Sequência: "
						EndIf	
					EndIF
				EndIF

				aadd(aBase,{ODLGPLA:ACOLS[nX][nPosGrupo],ODLGPLA:ACOLS[nX][nPosTpBase],ODLGPLA:ACOLS[nX][nPosConPag]})

				If M->FP0_TPFRAN == "G"
					aadd(aCompart,{ODLGPLA:ACOLS[nX][nPosBasFra],ODLGPLA:ACOLS[nX][nPosTipoca],M->FP0_TIPFAT})
				EndIF

				If ODLGPLA:ACOLS[nX][nPosTipoca] <> "H" .and. (!empty(ODLGPLA:ACOLS[nX][nPosMindia]) .or. !empty(ODLGPLA:ACOLS[nX][nPosMinMes]))
					cErro := STR0125+" "+STR0124+cMsg //"Tipo de franquia por hora, não permite o preenchimento do mínimo de horas por dia e mês"###"Projeto-Obra-Sequência: "
				EndIf

				cProduto := ODLGPLA:ACOLS[nX][nPosProdut]

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+cProduto))

				If alltrim(SB1->B1_GRUPO) $ alltrim(CGRPAND) .and. ODLGPLA:ACOLS[nX][nPosTipoSe] <> "M"
					If !empty(ODLGPLA:ACOLS[nX][nPosFranqu])
						cErro := STR0126+" "+STR0124+cMsg //"Movimentos de acessórios não permite indicar a franquia"###"Projeto-Obra-Sequência: "
					EndIf
					If !empty(ODLGPLA:ACOLS[nX][nPosBasFra])
						cErro := STR0127+" "+STR0124+cMsg //"Movimentos de acessórios não permite indicar a base da franquia"###"Projeto-Obra-Sequência: "
					EndIf
					If !empty(ODLGPLA:ACOLS[nX][nPosTipoca])
						cErro := STR0128+" "+STR0124+cMsg //"Movimentos de acessórios não permite indicar o tipo da franquia"###"Projeto-Obra-Sequência: "
					EndIf
					If !empty(ODLGPLA:ACOLS[nX][nPosGrupo])
						cErro := STR0129+" "+STR0124+cMsg //"Movimentos de acessórios não permite indicar o grupo da medição"###"Projeto-Obra-Sequência: "
					EndIf
				EndIF

				If ODLGPLA:ACOLS[nX][nPosTipoSe] == "M" .and. ODLGPLA:ACOLS[nX][nPosTipoca] == "C"
					cErro := STR0130+" "+STR0124+cMsg //"Movimentos de mão de obra não aceita o tipo de franquia contador"###"Projeto-Obra-Sequência: "
				EndIF

			Next

			lErro := .F.
			For nX := 1 to len(aBase)
				cGrupo := aBase[nX,1]
				cBase := aBase[nX,2]
				For nY := 1 to len(aBase)
					If aBase[nY,1] == cGrupo .and. aBase[nY,2] <> cBase
						cErro := STR0131 //"Não é permitido bases de cálculos diferentes para o mesmo grupo de medição"
						lErro := .T.
						Exit
					EndIF
				Next
				If lErro 
					Exit
				EndIf
			Next

			lErro := .F.
			For nX := 1 to len(aCompart)
				cBase := aCompart[nX,1]
				cTipo := aCompart[nX,2]
				cTipFat := aCompart[nX,3]
				For nY := 1 to len(aCompart)
					If aCompart[nY,1] <> cBase .or. aCompart[nY,2] <> cTipo .or. aCompart[nY,3] <> cTipFat
						cErro := STR0132 //"Em medições do tipo compartilhada não pode haver base, tipo de franquia e tipo de faturamento diferentes."
						lErro := .T.
						Exit
					EndIF
				Next
				If lErro 
					Exit
				EndIf
			Next

			lErro := .F.
			For nX := 1 to len(aBase)
				cGrupo := aBase[nX,1]
				cConPag := aBase[nX,3]
				For nY := 1 to len(aBase)
					If aBase[nY,1] == cGrupo .and. aBase[nY,3] <> cConPag
						cErro := STR0133 //"Não é permitido condição de pagamento diferente para o mesmo grupo de medição"
						lErro := .T.
						Exit
					EndIF
				Next
				If lErro 
					Exit
				EndIf
			Next

		EndIf

		If !empty(cErro)
			MsgAlert(cErro,STR0038) //"Atenção!"
			lRet := .F.
		EndIF

	EndIf
*/
Return lRet

/*/{PROTHEUS.DOC} LOCA248SEQ
ITUP BUSINESS - TOTVS RENTAL
Encontrar a próxima numeração da medição
Frank Z Fuga
29/10/2024  
/*/

Function LOCA248SEQ
Local cAs := ""
Local cSeq := ""
Local cSequencia := ""
Local oView := FWViewActive() 
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")

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
					EndIf
				EndIf
				FQK->(dbSkip())
			EndDo
		EndIf

		cSequencia := SOMA1( cSeq )

		//M->FQK_MEDSEQ := cSequencia
		FWFldPut("FQK_MEDSEQ",cSequencia)
		oView:Refresh()

	EndIf

Return .T.

/*/{Protheus.doc} LOCA248AP
Geração dos títulos provisórios
@type function
@author Frank Zwarg Fuga
@since 04/08/2025
cMedSeq é recebido no momento do cancelamento
/*/
function LOCA248AP(lForcaDel, lForcaInc, cMedSeq, lcancela)
Local lRet 			:= .T.
Local cParc 		:= Criavar("E1_PARCELA")
Local cQuery
Local aBindParam	:= {}
Local cNumTit		:= ""
Local cCliente      := ""
Local cLoja 		:= ""
Local cProjeto		:= ""
Local cAs			:= ""
Local cObra			:= ""
Local cNatureza		:= M->FQK_NATUR
Local dVenc
Local dNewData
Local aVetSE1 		:= {}
//Local cCampo		:= ""
//Local _MV_MOEDA 	:= 1
Local dOld
Local lErroExec 	:= .F.

Private lMsErroAuto

Default lForcaDel	:= .F.
Default lForcaInc 	:= .F.
Default cMedSeq     := ""
Default lCancela    := .F.

	If empty(cNatureza)
		cNatureza := SuperGetMV("MV_LOCX065")
	EndIf

	If valtype(M->FQK_PROJET) <> "C" // no cancelamento as variaveis não são criadas
		M->FQK_PROJET := FQK->FQK_PROJET
		M->FQK_MEDSEQ := FQK->FQK_MEDSEQ
		M->FQK_DTFIM  := FQK->FQK_DTFIM
		M->FQK_VLRTOT := FQK->FQK_VLRTOT
		If FQK->FQK_SITUAC == "6"
			lCancela := .T.
			M->FQK_MEDSEQ := cMedSeq
		EndIf
	EndIf

	If (lAltera .or. lExclui .or. lForcaDel) .and. !lForcaInc
		cAs   		:= M->FQK_PROJET+"-"+M->FQK_MEDSEQ
		cProjeto	:= M->FQK_PROJET
		FQB->(dbSetOrder(1))
		FQB->(dbSeek(xFilial("FQB")+cProjeto+cAs))
		While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET+alltrim(FQB_AS)) == xFilial("FQB")+cProjeto+alltrim(cAs)
			SE1->(dbSetOrder(1))
			If SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
				aVetSE1 := {}
				aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
				aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
				aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
				aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
				aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
				aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
				aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
				aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
				aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
				aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
				aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
				aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
				aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
				aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
				lMsErroAuto := .F.
				MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)
				//If lMsErroAuto 
					//MostraErro()
					//DisarmTransaction()
					//lErroExec := .t.
				//EndIf
			EndIf
			FQB->(RecLock("FQB"),.F.)
			FQB->(dbDelete())
			FQB->(MsUnlock())
			FQB->(dbSkip())
		EndDo
		
		If !lCancela // quando cancela não precisa criar novamente o provisório
			LOCA248AP(.F.,.T.)
		EndIf

	EndIf
	If (lInclui .or. lForcaInc) .and. !lForcaDel
		If M->FQK_VLRTOT > 0
			FP0->(dbSetOrder(1))
			FP0->(dbSeek(xFilial("FP0")+M->FQK_PROJET))

			cCliente	:= FP0->FP0_CLI
			cLoja	 	:= FP0->FP0_LOJA
			cAs   		:= M->FQK_PROJET+"-"+M->FQK_MEDSEQ
			cProjeto	:= M->FQK_PROJET
			cObra 		:= "   "
			cParc 		:= StrZero(0,Len(cParc))
			cParc 		:= StrZero((Val(cParc)+1),TamSx3("E1_PARCELA")[1])

			cQuery := " SELECT MAX(E1_NUM) REG "
			cQuery += " FROM " + RETSQLNAME("SE1") + " SE1 "
			cQuery += " WHERE SE1.E1_FILIAL = ? "
			cQuery += " AND SE1.E1_PREFIXO = 'REN' "
			cQuery += " AND SE1.D_E_L_E_T_ = '' "
			If Select("TRBVLD") > 0
				TRBVLD->( dbCloseArea() )
			EndIf
			cQuery := ChangeQuery(cQuery)
			aBindParam := { xFilial("SE1") }
			MPSysOpenQuery(cQuery,"TRBVLD",,,aBindParam)
			cNumTit := TRBVLD->REG
			If empty(cNumTit)
				cNumTit := "000000001"
			Else
				cNumTit := soma1(cNumTit)
			EndIF
			TRBVLD->(DBCLOSEAREA())

			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

			aVetSE1 := {}
			aAdd(aVetSE1, {"E1_FILIAL",  xFilial("SE1"), Nil})
			aAdd(aVetSE1, {"E1_NUM",     cNumTit,        Nil})
			aAdd(aVetSE1, {"E1_PREFIXO", "REN",          Nil})
			aAdd(aVetSE1, {"E1_PARCELA", cParc, 		 Nil})
			aAdd(aVetSE1, {"E1_TIPO",    "PR",           Nil})
			aAdd(aVetSE1, {"E1_NATUREZ", cNatureza,      Nil})
			aAdd(aVetSE1, {"E1_CLIENTE", cCliente,    	 Nil})
			aAdd(aVetSE1, {"E1_LOJA",    cLoja,    		 Nil})
			aAdd(aVetSE1, {"E1_NOMCLI",  SA1->A1_NREDUZ, Nil})

			dVenc := M->FQK_DTFIM
			dNewData := DataValida(dVenc, .T.)

			// Tentar encontrar a data valida dentro do mês levando dias a menos
			If dVenc <> dNewData .and. month(dNewData) <> month(dVenc)
				dNewData := DataValida(dVenc, .F.)
			EndIF

			aAdd(aVetSE1, {"E1_EMISSAO", dNewData,       Nil})
			aAdd(aVetSE1, {"E1_VENCTO",  dNewData,       Nil})
			aAdd(aVetSE1, {"E1_VENCREA", dNewData,       Nil})
			aAdd(aVetSE1, {"E1_VALOR",   M->FQK_VLRTOT,  Nil})
			aAdd(aVetSE1, {"E1_HIST",    "RENTAL: "+cAs, Nil})
			aAdd(aVetSE1, {"E1_MOEDA",   FP0->FP0_MOEDA, Nil})

			/*If FP0->FP0_MOEDA <> _MV_MOEDA
				SM2->(dbSetOrder(1))
				SM2->(dbSeek(dtos(dNewData)))
				cCampo := "SM2->M2_TXMOED"+alltrim(str(FP0->FP0_MOEDA))
				aAdd(aVetSE1, {"E1_TXMOEDA",   &(cCampo),   Nil})
			EndIF*/

			dOld      := dDataBase
			dDataBase := dNewData

			SED->(dbSetOrder(1))
			SED->(dbSeek(xFilial("SED")+cNatureza))

			lMsErroAuto := .F.
			MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

			If lMsErroAuto 
				SE1->(DbSetOrder(1))
				If !SE1->(DbSeek(xFilial("SE1")+"REN"+cNumTit+cParc+"PR"))
					MostraErro()
					DisarmTransaction()
					lErroExec := .T.
				EndIF
			EndIf

			If !lErroExec
				FQB->(RecLock("FQB",.T.))
				FQB->FQB_FILIAL := xFilial("FQB")
				FQB->FQB_PROJET := cProjeto
				FQB->FQB_OBRA   := cObra
				FQB->FQB_SEQGRU := "   "
				FQB->FQB_AS     := cAs
				FQB->FQB_PR     := SE1->E1_NUM
				FQB->FQB_PREF   := SE1->E1_PREFIXO
				FQB->FQB_PARC   := SE1->E1_PARCELA
				FQB->FQB_PERIOD := M->FQK_DTFIM
				FQB->(MsUnlock())
			EndIf

			dDataBase := dOld
		EndIf

	EndIf

Return lRet


