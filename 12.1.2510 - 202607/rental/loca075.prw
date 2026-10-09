#INCLUDE "loca075.ch"
#INCLUDE "PROTHEUS.CH"
#Include "topconn.ch"
#Include "ap5mail.ch"
#INCLUDE 'FWMVCDEF.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOCA075   ºAutor  ³Frank Z Fuga        º Data ³  30/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Integracao / processos antigo INTPROG.PRW                  º±±
±±º          ³ produtizado em 25/11/21                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function LOCA075

LOCAL   oBrowse

PRIVATE AROTINA   := MenuDef()
PRIVATE CSTRING   := "FQ5"
Private cCadastro := STR0001

DBSELECTAREA(CSTRING)
DBSETORDER(1)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cString)
oBrowse:SetDescription(cCadastro)

oBrowse:Activate()

Return

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002  ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0003  ACTION 'VIEWDEF.LOCA075' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004  ACTION 'VIEWDEF.LOCA075' OPERATION 4 ACCESS 0 //"Programacao"
ADD OPTION aRotina TITLE STR0005  ACTION "LOCA075003"      OPERATION 4 ACCESS 0 //Inclui matricula de funcionario

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruFQ5 := FWFormStruct( 1, 'FQ5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFPU := FWFormStruct( 1, 'FPU', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruFPV := FWFormStruct( 1, 'FPV', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

oStruFPU:SetProperty("FPU_CODCLI", MODEL_FIELD_INIT, {||FQ5->FQ5_CODCLI } )
oStruFPU:SetProperty("FPU_LOJCLI", MODEL_FIELD_INIT, {||FQ5->FQ5_LOJA } )
oStruFPU:SetProperty("FPU_DESIST", MODEL_FIELD_WHEN, {|| LOCA075012() } )

oModel := MPFormModel():New('LOCA075', /*bPreValidacao*/, {|oModel| LOCA075013(oModel)}/*bPosValidacao*/,{|oModel| LOCA075014(oModel)}/*bCommit*/ , /*bCancel*/ )

oModel:AddFields( 'FQ5MASTER', /*cOwner*/, oStruFQ5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'FPUDETAIL', 'FQ5MASTER', oStruFPU,/*bLinePre*/, {|oModel| LOCA075008( oModel)},/*bPre*/,/*bPost*/,/*bLoad*/)
oModel:AddGrid( 'FPVDETAIL', 'FPUDETAIL', oStruFPV)//,/*bLinePre*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)

// Frank em 01/04/25 manter neste formato de variável por questões internas.
cRelac := "oModel:SetRelation('FPUDETAIL',{{'FPU_FILIAL','XFilial("
cRelac += '"FPU")'
cRelac += "'},{'FPU_AS','FQ5_AS'},{'FPU_OBRA','FQ5_OBRA'},{'FPU_PROJ','FQ5_SOT'}},FPU->(IndexKey(2)))"
&(cRelac)

// Frank em 01/04/25 manter neste formato de variável por questões internas.
cRelac := "oModel:SetRelation('FPVDETAIL',{{'FPV_FILIAL','XFilial("
cRelac += '"FPV")'
cRelac += "'},{'FPV_AS','FQ5_AS'},{'FPV_OBRA','FQ5_OBRA'},{'FPV_PROJ','FQ5_SOT'},{'FPV_MAT','FPU_MAT'},{'FPV_CONTRO','FPU_CONTRO'}},FPV->(IndexKey(4)))"
&(cRelac)

oModel:SetPrimaryKey({})

oModel:SetDescription( 'Modelo de Dados de Programação' )
oModel:GetModel( 'FQ5MASTER' ):SetDescription( 'Dados de AS' )
oModel:GetModel( 'FPUDETAIL' ):SetDescription( 'Dados de Integração' )
oModel:GetModel( 'FPVDETAIL' ):SetDescription( 'Dados de Processo' )
oModel:GetModel('FPVDETAIL'):SetOptional(.T.)

//oModel:GetModel('FQ5MASTER'):SetOnlyView(.T.)
//oModel:GetModel( 'FPUDETAIL' ):SetUniqueLine( { 'FPU_MAT','FPU_DTINI','FPU_DTFIN'} )
//oModel:GetModel( 'FPVDETAIL' ):SetUniqueLine( { 'FPV_CODPRO' } )

Return oModel

//-------------------------------------------------------------------

Static Function ViewDef()

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'LOCA075' )
// Cria a estrutura a ser usada na View
Local oStruFQ5 := FWFormStruct( 2, 'FQ5', {|cCampo| Alltrim(cCampo) $ 'FQ5_SOT|FQ5_OBRA|FQ5_AS' })
Local oStruFPU := FWFormStruct( 2, 'FPU', {|cCampo| Alltrim(cCampo) $ 'FPU_MAT|FPU_NOME|FPU_DTINI|FPU_DTFIN|FPU_QTDDIA|FPU_DTLIM|FPU_VALID|FPU_DTVALI|FPU_CRACHA|FPU_DESIST|FPU_OBS|FPU_CONTRO|FPU_CODCLI|FPU_LOJCLI' },/*lViewUsado*/ )
//Local oStruFPV := FWFormStruct( 2, 'FPV', {|cCampo| Alltrim(cCampo) $ 'FPV_MAT|FPV_CODPRO|FPV_DESCRI|FPV_OBS|FPV_DTPREV|FPV_DTREAL|FPV_CONTRO|FPV_DATVLD' },/*lViewUsado*/ )
Local oStruFPV := FWFormStruct( 2, 'FPV', {|cCampo| Alltrim(cCampo) $ 'FPV_CODPRO|FPV_DESCRI|FPV_OBS|FPV_DTPREV|FPV_DTREAL|FPV_CONTRO|FPV_DATVLD' },/*lViewUsado*/ )

//Local oStruFPG := FWFormStruct( 2, 'FPG', { |cCampo| COMP11STRU(cCampo) } )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FQ5', oStruFQ5, "FQ5MASTER" )
oView:AddGrid( "VIEW_FPU", oStruFPU, "FPUDETAIL")
oView:AddGrid( "VIEW_FPV", oStruFPV, "FPVDETAIL")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CABECA' , 20 )
oView:CreateHorizontalBox( 'FOLDERS' , 80 )

// Criando as Pastas
oView:CreateFolder( 'PASTAS', 'FOLDERS')
oView:addSheet( 'PASTAS', "ABA_INTEGRA", "Integração", /*<bAction >*/ )
oView:addSheet( 'PASTAS', "ABA_PROCESS" , "Processo", /*<bAction >*/ )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'INTEGRA'  , 100,,, 'PASTAS', 'ABA_INTEGRA' )
oView:CreateHorizontalBox( 'PROCESS'  , 100,,, 'PASTAS', 'ABA_PROCESS' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FQ5', 'CABECA' )
oView:SetOwnerView( 'VIEW_FPU', 'INTEGRA' )
oView:SetOwnerView( 'VIEW_FPV', 'PROCESS' )

oView:SetVldFolder({|cFolderID, nOldSheet, nSelSheet| LOCA075011(cFolderID, nOldSheet, nSelSheet, oView)})

Return oView


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  LINOK   ºAutor  ³M&S Consultoria     º Data ³  30/06/07   º±±
±±ºPrograma  ³  LOCA075008   ºAutor  ³M&S Consultoria     º Data ³  30/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Linok do Grid FPU                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function LOCA075008(oModelFPU)

Local lRet			:= .T.
Local cErros		:= STR0047 //"Verifique os campos Matrícula, Data Início e Data Final "

	//verifica matricula
	If Empty(oModelFPU:GetValue("FPU_MAT"))
		lRet := .F.
    	FwAlertError(cErros, STR0048) // "Inconsistência de dados"
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA075007
@description	Validação da Tabela FPU
@author			José Eulálio
@since     		13/10/2022
/*/
//-------------------------------------------------------------------
Function LOCA075007(cCampo) // Trocar para LOCA075007

Local oModel    := FWModelActive()
Local oModelFPU := oModel:GetModel("FPUDETAIL")
Local dDtIni 	:= oModelFPU:GetValue('FPU_DTINI')
Local dDtFim 	:= oModelFPU:GetValue('FPU_DTFIN')
Local cMat 		:= oModelFPU:GetValue('FPU_MAT')
Local cErro		:= ""
Local lRet 		:= .T.
Local nFx

If cCampo == "FPU_MAT"

	lRet := ExistCpo("SRA")

	cMat := M->FPU_MAT

	If lRet

		If Empty(oModelFPU:GetValue("FPU_CONTRO"))

			For nfx := 01 to oModelFPU:Length()

				cNumContro := strzero(nfx,2)

				If ! oModelFPU:SeekLine({{"FPU_MAT", cMat},{"FPU_CONTRO", cNumContro}},.T.,.F.)

					Exit

				Endif

			Next nfx

			oModelFPU:SetValue("FPU_CONTRO", cNumContro)

		Endif
	endif

ElseIf cCampo == "FPU_DTINI" //verifica se data inicial foi preenchida
	dDtIni := &(ReadVar())
	If !Empty(dDtIni) .And. Empty(cMat)
		cErro := STR0039 //"Matrícula não foi preenchida."
	ElseIf dDtIni > dDtFim .And. !Empty(dDtFim)
		cErro := STR0041 //"Data Inicial maior que a Data Final."
	EndIf
ElseIf cCampo == "FPU_DTFIN"
	dDtFim := &(ReadVar())
	If !Empty(dDtFim) .And. Empty(cMat)
		cErro := STR0039 //"Matrícula não foi preenchida."
	ElseIf !Empty(dDtFim) .And. Empty(dDtIni)
		cErro := STR0040 //"Data Inical não foi preenchida."
	ElseIf dDtFim < dDtIni
		cErro := STR0044 //"Data Final menor que a Data Inicial."
	EndIf
EndIf
/*
If lRet
	For nX := 1 To Len(oDlgFro:ACOLS)
		If nX <> oDlgFro:nAt
			//verifica periodos
			If cMat == oDlgFro:ACOLS[nX][nPosMat]
				If cCampo == "FPU_DTINI"
					dDtIni := &(ReadVar())
					If dDtIni == oDlgFro:ACOLS[nX][nPosDtIni]
						cErro := STR0042 + CValToChar(nX) + " (" + Lower(Extenso(nX,.T.)) + " )." //"Data já informada na linha "
						Exit
					ElseIf 	( dDtIni < oDlgFro:ACOLS[nX][nPosDtIni] .And. dDtFim > oDlgFro:ACOLS[nX][nPosDtIni] ) .Or. ;
							( dDtIni > oDlgFro:ACOLS[nX][nPosDtIni] .And. dDtIni < oDlgFro:ACOLS[nX][nPosDtFin] )
						cErro := STR0043 + CValToChar(nX) + " (" + Lower(Extenso(nX,.T.)) + ")." //"O período informado coincide com a linha "
						Exit
					EndIf
				ElseIf cCampo == "FPU_DTFIN"
					dDtFim := &(ReadVar())
					If dDtFim == oDlgFro:ACOLS[nX][nPosDtFin] .And. dDtFim == oDlgFro:ACOLS[nX][nPosDtIni]
						cErro := STR0042 + CValToChar(nX) + "(" + Lower(Extenso(nX,.T.)) + ")." //"Data já informada na linha "
						Exit
					ElseIf 	(dDtFim > oDlgFro:ACOLS[nX][nPosDtIni] .And. dDtFim < oDlgFro:ACOLS[nX][nPosDtFin] ) .Or. ;
							(dDtIni < oDlgFro:ACOLS[nX][nPosDtIni] .And. dDtFim > oDlgFro:ACOLS[nX][nPosDtIni] )
						cErro := STR0043 + CValToChar(nX) + " (" + Lower(Extenso(nX,.T.)) + ")." //"O período informado coincide com a linha "
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX
EndIf
*/
If !Empty(cErro)
	lRet := .F.
	Help(NIL, NIL, "LOCA075_01", NIL, cErro, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0045}) //"Preencha os campos Dt.Ini.Integ [FPU_DTINI] e Dt.Fim Integ [FPU_DTFIN] com valores válidos"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOCA075010
@description	Validação da Tabela FPV
@author			José Eulálio
@since     		09/11/2022
@type Function
/*/
//-------------------------------------------------------------------
Function LOCA075010(cCampo) // Trocar para LOCA075010(cCampo)
	Local lRet		:= .T.
	Local xValCampo

	If cCampo == "FPV_CODPRO"
		xValCampo := &(ReadVar())
		If !Empty(xValCampo)
			lRet := ExistCpo("FPT",xValCampo,2) //FPT_FILIAL+FPT_COD
		EndIf
	EndIf

Return lRet

/* Validação para troca de Folder*/

Static Function LOCA075011(cFolderID, nOldSheet, nSelSheet,oView)

	Local lRet := .T.
	Local oModel		:= oView:GetModel()
	Local oModelFPU := oModel:GetModel("FPUDETAIL")
	Local oModelFPV := oModel:GetModel("FPVDETAIL")

	if nOldSheet <> nSelSheet

		if nOldSheet = 1 // Integração

			lRet := oModelFPU:VldData(.F.)
//		if lRet .and. Empty(oModelFPU:GetValue("FPU_MAT"))
//			lRet := .F.
//			Help(NIL, NIL, "LOCA075_02", NIL, "Matrícula não foi preenchida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Preencha a Matricula do Funcionario antes de trocar de ABA"}) //"Preencha os campos Dt.Ini.Integ [FPU_DTINI] e Dt.Fim Integ [FPU_DTFIN] com valores válidos"
//
//		endif

		else

			lRet := oModelFPV:VldData(.F.)

		Endif

	endif

REturn lRet

Static Function LOCA075012()

	Local oModel    := FWModelActive()
	Local oModelFPU := oModel:GetModel("FPUDETAIL")

	lRet := oModelFPU:GetValue("FPU_DESIST") = '2' .or. oModelFPU:IsFieldUpdated("FPU_DESIST")

Return lRet


//-----------------------------------------------------------------------------
// 		TUDO OK
//-----------------------------------------------------------------------------

STATIC FUNCTION LOCA075013(oModel)

	Local nK
	Local nG
	Local nH
	Local nI
	Local nJ
	Local nX
	Local lRet := .T.
	Local oModelFPU := oModel:GetModel("FPUDETAIL")
	Local oModelFPV := oModel:GetModel("FPVDETAIL")



	cProj  := FQ5->FQ5_SOT
	CoBRA  := FQ5->FQ5_OBRA
	nAs    := FQ5->FQ5_AS//
	CMAT   :=  oModelFPU:GetValue("FPU_MAT")
	CNOME  := Posicione("SRA",1,xFilial("FPU")+CMAT,"RA_NOME")
	aGravaZM0 := {}
	cChaveDel := ""
	nDel := 0



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacoes solicitadas na ETG15³
	//³Claudio Miranda                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FOR nK:= 1 TO oModelFPU:Length()

		oModelFPU:GoLine(nK)

		if !oModelFPU:IsDeleted(nK)

//			if oModelFPU:IsFieldUpdated("FPU_DESIST", nK) .and. !oModelFPU:IsInserted(nK) // Trocou a Desistencia em linha não incluida
//				If oModelFPU:GetValue("FPU_DESIST", nK) != '1'
//					MsgStop(STR0017+ ODLGFRO:ACOLS[nK][1] +STR0018+ Alltrim(str(nPosint)) +STR0019,STR0020) //"A matricula "###", referente a linha "###" da integração, ja estava definida como desistencia, portanto não poderá ser alterada. Por favor altere o status da desistencia para prosseguir"###"Mensagem 201"
//					Return
//				Endif
//			Endif

			// Valida se há alguma data de inicio maior que a data final
			If !Empty(oModelFPU:GetValue("FPU_DTFIN", nK))
				If oModelFPU:GetValue("FPU_DTINI", nK) > oModelFPU:GetValue("FPU_DTFIN", nK)
					Help( ,,STR0023,, STR0021+ oModelFPU:GetValue("FPU_MAT", nK) +STR0022+Alltrim(str(nK)), 1, 0 )
					//MsgStop(STR0021+ oModelFPU:GetValue("FPU_MAT", nK) +STR0022+Alltrim(str(nK)),STR0023)  //"A data de inicio não pode ser maior que a data final da integraçao. Por favor corrija a matricula "###", linha "###"Mensagem 204"
					lRet := .F.
					Exit
				Endif
			Endif
		endif
	Next nk

	oModelFPU:GoLine(1) // Volta para primeira linha


	FOR nX:=1 TO oModelFPU:Length()
		oModelFPU:GoLine(nX)
		CMAT:= oModelFPU:GetValue("FPU_MAT", nx)
		nDifer := 1

		If lRet .and. !oModelFPU:IsDeleted(nX)    //ODLGFRO:ACOLS[nX][12] = .F.      //Verifica se o registro da integracao esta deletado

			If oModelFPU:GetValue("FPU_DESIST") != "1"  //Verifica se e desistencia
				//*** NAO HOUVE DESISTENCIA
				If !Empty(oModelFPU:GetValue("FPU_DTINI")) // Data de Inicio Preenchida

					If !Empty(oModelFPU:GetValue("FPU_DTFIN")) // Data Final Preenchida

						If oModelFPU:GetValue("FPU_DTINI") <= oModelFPU:GetValue("FPU_DTFIN") // Inico Menor ou Igual ao FInal
							// Validar o Model de Processos para a Matricula Posicionada a Integração
							For nG := 1 to oModelFPV:Length()  // Varrer o model posicionado
								oModelFPv:GoLine(nG)
								If !oModelFPV:IsDeleted(nG) //Verifica se o registro nao esta deletado
									//
									If !Empty(oModelFPV:GetValue("FPV_CODPRO"))

										If Empty(oModelFPV:GetValue("FPV_DTPREV")) .or. !Empty(oModelFPV:GetValue("FPV_DTREAL"))

											If !Empty(oModelFPV:GetValue("FPV_DTPREV")) .and. Empty(oModelFPV:GetValue("FPV_DTREAL"))
											/*	If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
													Help( ,,STR0054,,STR0053 + oModelFPV:GetValue("FPV_MAT") + STR0051 +oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
													//MsgStop(STR0053 + aGrv[x][1][2][nG][1] + STR0051 + aGrv[x][1][2][nG][2], STR0054) //"A data realizada nao foi preenchida. Matricula: " ### ", Processo: " ### "Mensagem 2"
													lRet := .F.
												Endif  Não Faz sentido */
											Elseif Empty(oModelFPV:GetValue("FPV_DTPREV")) .and. Empty(oModelFPV:GetValue("FPV_DTREAL"))
												If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
													Help( ,,STR0055,,STR0053 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
													//MsgStop(STR0053 + aGrv[x][1][2][nG][1] + STR0051 + aGrv[x][1][2][nG][2], STR0055) // "A data realizada nao foi preenchida. Matricula: " ### ", Processo: " ### "Mensagem 3"
													lRet := .F.
												Endif
											Else
												If oModelFPV:GetValue("FPV_DTREAL") < oModelFPU:GetValue("FPU_DTINI") .OR. oModelFPV:GetValue("FPV_DTREAL") > oModelFPU:GetValue("FPU_DTFIN") //Verifica se a data prevista do processo e maior que a data inicio da integracao
													Help( ,,STR0052,,STR0050 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPU:GetValue("FPU_CONTRO"), 1, 0 )
													//MsgStop(STR0050 + aGrv[x][1][2][nG][1] + STR0051 + aGrv[x][1][2][nG][2], STR0052) // "A data realizada esta fora do periodo de integração. Matricula: " ### ", Processo: " ### "Mensagem 4"
													lRet := .F.
												Endif
											Endif
										Endif
									Else
										Help( ,,"Mensagem 13",,STR0056 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 + alltrim(str(nX)), 1, 0 )
										//MsgStop(STR0056 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 + alltrim(str(nX)),"Mensagem 13") // "Ao menos um processo deve estar preenchido para o encerramento da integraçao. Matricula: " ### // " Linha "
										lRet := .F.
									Endif


								Endif
							Next


						/*Else
							Help( ,,"Mensagem 12",,STR0059 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)), 1, 0 )
							//MsgStop(STR0059 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)),"Mensagem 12") // "A data inicio da integração nao pode ser maior que a data final.  Matricula: " ### " Linha "
							lRet := .F.*/
						Endif
					Else

						For nH := 1 to oModelFPV:Length()  // Varrer o model posicionado
							oModelFPV:GoLine(nH)
							If !oModelFPV:IsDeleted(nH) //Verifica se o registro nao esta deletado
								//						If aGrv[x][1][2][nH][7] = ODLGFRO:ACOLS[nX][11]
								If !Empty(oModelFPV:GetValue("FPV_DTREAL"))
									If oModelFPV:GetValue("FPV_DTREAL") < oModelFPU:GetValue("FPU_DTINI", nX)
										If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
											Help( ,,"Mensagem 5",,STR0050 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
											//MsgStop(STR0050 + aGrv[x][1][2][nH][1] + STR0051 + aGrv[x][1][2][nH][2],"Mensagem 5") //"A data realizada esta fora do periodo de integração. Matricula: "
											lRet := .F.
										Endif
									Endif


								Endif

							Endif
						Next
						//Endif
					Endif

				Else
					//*** Data inicial em branco (Integração)
					If !empty(oModelFPU:GetValue("FPU_DTFIN",nX)) /*
						Help( ,,"Mensagem 6",,(STR0060 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)), 1, 0 ))
						//MsgStop(STR0060 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)),"Mensagem 6") // "A data de inicio da integração nao foi preenchida. Matricula: " ### " Linha "
						lRet := .F. */
					Else

						For nI := 1 to oModelFPV:Length()  // Varrer o model posicionado
							oModelFPV:GoLine(nI)
							If !oModelFPV:IsDeleted(nI)	 //Verifica se o registro nao esta deletado
								//						If aGrv[x][1][2][nI][7] = OModelFPU:GetValue("FPU_CONTRO", nx)
								If !Empty(oModelFPV:GetValue("FPV_DTPREV")) .and. !Empty(oModelFPV:GetValue("FPV_DTREAL"))
									If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
										Help( ,,"Mensagem 7",,STR0061 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
										//MsgStop(STR0061 + aGrv[x][1][2][nI][1] + STR0051 + aGrv[x][1][2][nI][2],"Mensagem 7") // "A data de inicio e fim da integração nao foram preenchidas. Matricula: " ###
										lRet := .F.
									Endif
								Elseif Empty(oModelFPV:GetValue("FPV_DTPREV")) .and. !Empty(oModelFPV:GetValue("FPV_DTREAL"))
									If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
										Help( ,,"Mensagem 8",,STR0061 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
										//MsgStop(STR0061 + aGrv[x][1][2][nI][1] + STR0051 + aGrv[x][1][2][nI][2],"Mensagem 8") // "A data de inicio e fim da integração nao foram preenchidas. Matricula: " ###
										lRet := .F.
									Endif
								Endif

							Endif
						Next

					Endif
				Endif
			Else
				//*** HOUVE DESISTENCIA
				If !empty(oModelFPU:GetValue("FPU_DTINI",nX))

					If !empty(oModelFPU:GetValue("FPU_DTFIN",nX))
						If oModelFPU:GetValue("FPU_DTINI",nX) <= oModelFPU:GetValue("FPU_DTFIN",nX)

							For nJ := 1 to oModelFPV:Length()  //Le o array aGRV e traz os processos de acordo com a matricula
								oModelFPV:GoLine(nJ)
								If !oModelFPV:IsDeleted(nJ)//Verifica se o registro nao esta deletado
									//							If aGrv[x][1][2][nJ][7] = ODLGFRO:ACOLS[nX][11]
									If !Empty(oModelFPV:GetValue("FPV_DTPREV")) .and. !Empty(oModelFPV:GetValue("FPV_DTREAL"))
										If oModelFPV:GetValue("FPV_DTREAL") < oModelFPU:GetValue("FPU_DTINI",nX) .OR. oModelFPV:GetValue("FPV_DTREAL") > oModelFPU:GetValue("FPU_DTFIN",nX) //Verifica se a data prevista do processo e maior que a data inicio da integracao

											If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
												Help( ,,"Mensagem A",,STR0050 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
												//MsgStop(STR0050 + aGrv[x][1][2][nJ][1] + STR0051 + aGrv[x][1][2][nJ][2],"Mensagem A") // "A data realizada esta fora do periodo de integração. Matricula: "
												lRet := .F.
											Endif
										endif
									Else
										If !Empty(oModelFPV:GetValue("FPV_DTREAL"))
											If !Empty(oModelFPV:GetValue("FPV_CODPRO"))

												If oModelFPV:GetValue("FPV_DTREAL") < oModelFPU:GetValue("FPU_DTINI",nX) .OR. oModelFPV:GetValue("FPV_DTREAL") > oModelFPU:GetValue("FPU_DTFIN",nX) //Verifica se a data prevista do processo e maior que a data inicio da integracao
													If !Empty(oModelFPV:GetValue("FPV_CODPRO"))
														Help( ,,"Mensagem B",,STR0050 + oModelFPV:GetValue("FPV_MAT") + STR0051 + oModelFPV:GetValue("FPV_CODPRO"), 1, 0 )
														//MsgStop(STR0050 + aGrv[x][1][2][nJ][1] + STR0051 + aGrv[x][1][2][nJ][2],"Mensagem B") // "A data realizada esta fora do periodo de integração. Matricula: "
														lRet := .F.
													Endif
												Endif
											Endif
										Endif
									endif
								Endif
							Next

					/*	Else
							Help(, ,"Mensagem F",,STR0059 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)), 1, 0 )
							//MsgStop(STR0059 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)),"Mensagem F") // // "A data inicio da integração nao pode ser maior que a data final.  Matricula: " ### " Linha "
							lRet := .F. */
						Endif
					Else
						// Se nao ha data Final
						Help(, ,"Mensagem C",,STR0062 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)), 1, 0 )
						//	MsgStop(STR0062 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)),"Mensagem C") // "A data final da integração deve ser preenchida. Matricula: " ### " Linha "
						lRet := .F.
					Endif
				/*Else
					//*** Data inicial em branco (Integração)
					Help(, ,"Mensagem D",,STR0063 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)), 1, 0 )
					//	MsgStop(STR0063 + oModelFPU:GetValue("FPU_MAT", nx)+ STR0057 +Alltrim(str(nX)),"Mensagem D") // "A data inicial da integração deve ser preenchida. Matricula: " ###" Linha "
					lRet := .F. */
				Endif
			endif
		endif
	NEXT

RETURN lRet


/* Gravação do Model */

Static Function LOCA075014(oModel)
	Local lRet := .F.
	Local oModelFPU := oModel:GetModel("FPUDETAIL")
	Local nReg
	Local nDes
	Local nDif
	Local cDesist

	Begin Transaction

		lRet := FwFormCommit(oModel)

		if lRet

			for nReg := 1 to oModelFPU:Length()

				oModelFPU:GoLine(nReg)
				if !oModelFPU:IsDeleted()
					cDesist := oModelFpu:GetValue("FPU_DESIST")

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Validacao das datas para gravação na tabela ZLO ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !Empty(oModelFpu:GetValue("FPU_DTINI"))
						If cDesist != "1"
							If !Empty(oModelFpu:GetValue("FPU_DTFIN"))
								If oModelFpu:GetValue("FPU_DTFIN") < oModelFpu:GetValue("FPU_DTLIM")  //Se a Data Fim da integraçao for menor que a data limite
									nDif := (oModelFpu:GetValue("FPU_DTFIN") +1)  -  oModelFpu:GetValue("FPU_DTINI")
									nDes := oModelFpu:GetValue("FPU_DTLIM")   -  oModelFpu:GetValue("FPU_DTFIN")
								Elseif oModelFpu:GetValue("FPU_DTFIN") = oModelFpu:GetValue("FPU_DTLIM") //Se a Data Fim da integraçao for igual a data limite
									nDif := (oModelFpu:GetValue("FPU_DTLIM") +1)  -  oModelFpu:GetValue("FPU_DTINI")
									nDes := 0
								Else //Se a Data Fim da integraçao for Maior que a data limite
									nDif :=  (oModelFpu:GetValue("FPU_DTFIN") +1)  -  oModelFpu:GetValue("FPU_DTINI")
									nDes := 0
								End
							Else
								//	If oModelFpu:GetValue("FPU_DTLIM") <  oModelFpu:GetValue("FPU_DTINI")
								//		nDif := 0
								//		nDes := 0
								//	Else
								//		nDif := (oModelFpu:GetValue("FPU_DTLIM") +1) -  oModelFpu:GetValue("FPU_DTINI")
								//		nDes := 0
								//	Endif
							End
						Else
							nDif := (oModelFpu:GetValue("FPU_DTFIN") +1)  -  oModelFpu:GetValue("FPU_DTINI")
							nDes := oModelFpu:GetValue("FPU_DTLIM")  -  oModelFpu:GetValue("FPU_DTFIN")
						Endif

						IF nDif = 0 .and. nDes = 0
							//	MsgAlert(STR0037 + cmat +STR0024+Alltrim(str(nX)),STR0036)    //"Atençao 1" //"O processo de integraçao esta atrasado para a matricula: " //" Linha "
							CadZLO(nDif,nDes,cDesist,oModelFpu:GetValue("FPU_DTINI"),oModelFpu:GetValue("FPU_DTFIN"),oModelFpu:GetValue("FPU_DTLIM"),oModelFpu:GetValue("FPU_CONTRO"),oModelFpu:GetValue("FPU_MAT"))
						else
							CadZLO(nDif,nDes,cDesist,oModelFpu:GetValue("FPU_DTINI"),oModelFpu:GetValue("FPU_DTFIN"),oModelFpu:GetValue("FPU_DTLIM"),oModelFpu:GetValue("FPU_CONTRO"),oModelFpu:GetValue("FPU_MAT"))
						endif
					Else
						CadZLO(0,0,cDesist,oModelFpu:GetValue("FPU_DTINI"),oModelFpu:GetValue("FPU_DTFIN"),oModelFpu:GetValue("FPU_DTLIM"),oModelFpu:GetValue("FPU_CONTRO"),oModelFpu:GetValue("FPU_MAT"))
					Endif

				endif

			next nReg
		endif

	End Transaction

Return lRet



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CADZLO    ºAutor  ³M&S Consultoria     º Data ³  30/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CadZLO (nReg,nDes,cDesist,cdatini,cdatfim,cdatlimite,ccontro, cMatric)//(nReg,nDes,cDesist,oDlgFro:aCols[nX][3],oDlgFro:aCols[nX][4])
Local n, nY
Private cALIAS   	:= "FPQ"
Private lINCLUI  	:= .F.
Private cData    	:= cdatini
Private cDtqini		:= FQ5->FQ5_DATINI
Private cDtqFim		:= FQ5->FQ5_DATFIM
Private cFolMes		:= GETMV("MV_FOLMES")
Private cDataFol  	:= Substr(DTOS(cData),1,6)
Private cProjeto 	:= FQ5->FQ5_SOT
Private cAs			:= FQ5->FQ5_AS
Private cObra		:= FQ5->FQ5_OBRA
Private cdataini	:= cdatini
Private cdatafim	:= cdatfim
Private cdatalimite	:= cdatlimite
Private cControl	:= ccontro
Private cMat        := cMatric

	FOR N:= 1 TO nREG

		If N > 1
			cData := cData + 1
			cDataFol := Substr(DTOS(cData),1,6)
		Endif

		IF cDataFol >= cFolmes

			cChave := cmat+DTOS(cDATA)

			DbSelectArea("FPQ")
			dbsetorder(1)
			If DbSeek(xFilial("FPQ")+cChave+ccontrol)
				lINCLUI:= .F. //Altera
			Else
				If DbSeek(xFilial("FPQ")+cChave)
					lINCLUI:= .F. //Altera
				Else
					lINCLUI:= .T. //Inclui
				Endif
			Endif

			If lINCLUI = .F.
				If FPQ->FPQ_TIPINC = "A"
					RECLOCK("FPQ", .F.)
					FPQ->FPQ_FILIAL		:= xFilial("FPQ")
					FPQ->FPQ_MAT		:= cMat
					FPQ->FPQ_DATA		:= cData
					//FPQ->FPQ_STATUS  	:= "000005"
					FPQ->FPQ_STATUS  	:= "INTEGR"
					FPQ->FPQ_VT			:= "N"
					FPQ->FPQ_AS			:= cAS
					FPQ->FPQ_PROJET		:= cProjeto
					FPQ->FPQ_OBRA		:= cObra
					FPQ->FPQ_DESC		:= ""
					FPQ->FPQ_HORAS		:= 0
					//FPQ->FPQ_OBS		:= ""
					FPQ->FPQ_OBS        := STR0046 // "LANCAMENTO GERADO AUTOMATICAMENTE"
					FPQ->FPQ_USERGI		:= ""
					FPQ->FPQ_USERGA		:= ""
					FPQ->FPQ_FIND		:= ""
					FPQ->FPQ_FILAUX		:= ""
					FPQ->FPQ_AGENDA		:= "2"
					FPQ->FPQ_SERVIC		:= ""
					FPQ->FPQ_HRINI		:= ""
					FPQ->FPQ_HRFIN		:= ""
					//FPQ->FPQ_FILMAT		:= "  "
					FPQ->FPQ_FILMAT		:= xFilial("SRA")
					FPQ->FPQ_TIPINC		:= "A"
					FPQ->FPQ_CONTRO		:= ccontrol
					MSUNLOCK("FPQ")
					dbCommitAll()
				End
			Else
				RECLOCK("FPQ", .T.)
				FPQ->FPQ_FILIAL		:= xFilial("FPQ")
				FPQ->FPQ_MAT		:= cMat
				FPQ->FPQ_DATA		:= cData
				//FPQ->FPQ_STATUS		:= "000005"
				FPQ->FPQ_STATUS  	:= "INTEGR"
				FPQ->FPQ_VT			:= "N"
				FPQ->FPQ_AS			:= cAS
				FPQ->FPQ_PROJET		:= cProjeto
				FPQ->FPQ_OBRA		:= cObra
				FPQ->FPQ_DESC		:= ""
				FPQ->FPQ_HORAS		:= 0
				//FPQ->FPQ_OBS		:= ""
				FPQ->FPQ_OBS        := STR0046 // "LANCAMENTO GERADO AUTOMATICAMENTE"
				FPQ->FPQ_USERGI		:= ""
				FPQ->FPQ_USERGA		:= ""
				FPQ->FPQ_FIND		:= ""
				FPQ->FPQ_FILAUX		:= ""
				FPQ->FPQ_AGENDA		:= "2"
				FPQ->FPQ_SERVIC		:= ""
				FPQ->FPQ_HRINI		:= ""
				FPQ->FPQ_HRFIN		:= ""
				//FPQ->FPQ_FILMAT		:= "  "
				FPQ->FPQ_FILMAT		:= xFilial("SRA")
				FPQ->FPQ_TIPINC		:= "A"
				FPQ->FPQ_CONTRO		:= ccontrol
				MSUNLOCK("FPQ")
				dbCommitAll()
			End
		Endif
	NEXT

	If nDes > 0  //tratamento para os dias de diferenca entre data fim e data limite
		cDataLim   := cdatlimite + 1
		cChaveObra := cmat+DTOS(cDataLim)

		DbSelectArea("FPQ")
		dbsetorder(1)
		If cDesist != "1"   //Verifica se houve desistencia
			If DbSeek(xFilial("FPQ")+cChaveObra+ccontrol)  //Verifica se o registro ja existe uma dia depois da data limite
				If FPQ_AS+FPQ_PROJET+FPQ_OBRA+ALLTRIM(FPQ_STATUS) == cAS+cProjeto+cObra+"000004"  //Verifica se o registro pertence a mesma OBRA/PROJETO
					For nY:= 1 TO nDes
						cData := cData + 1
						cChave := cmat+DTOS(cDATA)

						IF cDataFol >= cFolmes
							DbSelectArea("FPQ")
							dbsetorder(1)
							If DbSeek(xFilial("FPQ")+cChave+ccontrol)  //Reposiciona no registro
								lINCLUI:= .F. //Altera
							Else
								If DbSeek(xFilial("FPQ")+cChave)
									lINCLUI:= .F. //Altera
								Else
									lINCLUI:= .T. //Inclui
								Endif
							Endif

							If cData >= cDTQINI .and. cData <= cDTQFIM  //So altera oa registros que estiverem dentro do Range
								If lINCLUI = .F.  //Verifica se alteraçao
									If FPQ->FPQ_TIPINC = "A"  //Verifica se e inclusao Manual ou automatica  - Se for Manual Pula
										If FPQ_AS+FPQ_PROJET+FPQ_OBRA == cAS+cProjeto+cObra
											RECLOCK("FPQ", .F.)
											FPQ->FPQ_FILIAL  	:= xFilial("FPQ")
											FPQ->FPQ_MAT  	 	:= cMat
											FPQ->FPQ_DATA  	 	:= cData
											FPQ->FPQ_STATUS  	:= "000004"
											FPQ->FPQ_VT 	 	:= "N"
											FPQ->FPQ_AS  	 	:= cAS
											FPQ->FPQ_PROJET  	:= cProjeto
											FPQ->FPQ_OBRA  	 	:= cObra
											FPQ->FPQ_DESC  	 	:= ""
											FPQ->FPQ_HORAS   	:= 0
											//FPQ->FPQ_OBS     	:= ""
											FPQ->FPQ_OBS        := STR0046 // "LANCAMENTO GERADO AUTOMATICAMENTE"
											FPQ->FPQ_USERGI  	:= ""
											FPQ->FPQ_USERGA  	:= ""
											FPQ->FPQ_FIND  	 	:= ""
											FPQ->FPQ_FILAUX  	:= ""
											FPQ->FPQ_AGENDA  	:= "2"
											FPQ->FPQ_SERVIC  	:= ""
											FPQ->FPQ_HRINI   	:= ""
											FPQ->FPQ_HRFIN   	:= ""
											//FPQ->FPQ_FILMAT		:= "  "
											FPQ->FPQ_FILMAT		:= xFilial("SRA")
											FPQ->FPQ_TIPINC  	:= "A"
											FPQ->FPQ_CONTRO		:= ccontrol
											MSUNLOCK("FPQ")
											dbCommitAll()
										Endif
									End
								Else
									//Inclusao de registro inexistente
									RECLOCK("FPQ", .T.)
									FPQ->FPQ_FILIAL  := xFilial("FPQ")
									FPQ->FPQ_MAT  	 := cMat
									FPQ->FPQ_DATA  	 := cData
									FPQ->FPQ_STATUS  := "000004"
									FPQ->FPQ_VT 	 := "N"
									FPQ->FPQ_AS  	 := cAS
									FPQ->FPQ_PROJET  := cProjeto
									FPQ->FPQ_OBRA  	 := cObra
									FPQ->FPQ_DESC  	 := ""
									FPQ->FPQ_HORAS   := 0
									//FPQ->FPQ_OBS     := ""
									FPQ->FPQ_OBS     := STR0046 // "LANCAMENTO GERADO AUTOMATICAMENTE"
									FPQ->FPQ_USERGI  := ""
									FPQ->FPQ_USERGA  := ""
									FPQ->FPQ_FIND  	 := ""
									FPQ->FPQ_FILAUX  := ""
									FPQ->FPQ_AGENDA  := "2"
									FPQ->FPQ_SERVIC  := ""
									FPQ->FPQ_HRINI   := ""
									FPQ->FPQ_HRFIN   := ""
									//FPQ->FPQ_FILMAT		:= "  "
									FPQ->FPQ_FILMAT		:= xFilial("SRA")
									FPQ->FPQ_TIPINC  := "A"
									FPQ->FPQ_CONTRO		:= ccontrol
									MSUNLOCK("FPQ")
									dbCommitAll()
								End
							Else
								//Se estiver fora da data do Projeto DTQ, deleta os registros
								DbSelectArea("FPQ")
								dbsetorder(1)
								If DbSeek(xFilial("FPQ")+cChave+ccontrol)  //Reposiciona no registro
									If FPQ_AS+FPQ_PROJET+FPQ_OBRA == cAS+cProjeto+cObra
										If FPQ_TIPINC = "A"
											RecLock("FPQ",.F.)
											dbDelete()
											MsUnlock("FPQ")
										Endif
									Endif
								Else
									If DbSeek(xFilial("FPQ")+cChave)
										If FPQ_AS+FPQ_PROJET+FPQ_OBRA == cAS+cProjeto+cObra
											If FPQ_TIPINC = "A"
												RecLock("FPQ",.F.)
												dbDelete()
												MsUnlock("FPQ")
											Endif
										Endif
									Endif
								Endif
							Endif
						Endif
					Next
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Deleta registros a mais quando nao ha OBRA depois da data limite³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Deleta()
				End
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Deleta registros a mais quando nao ha mais registros depois da data limite³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Deleta()
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Deleta registros a mais quando houve desistencia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Deleta()
		Endif
	Else
		Deleta()
	Endif
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Deleta   ºAutor  ³M&S Consultoria     º Data ³  30/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deleta registros de integraçao que nao estão dentro do     º±±
±±º          ³ periodo de integracao                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Deleta()

Local lGeraZlo := .F.
Local lApagaInt	:= .F.
Local aBindParam := {}
Local cQuery
	DbSelectArea("FPQ")
	DbSetOrder(1)
	// Validações
	If !Empty(cdataini) .and. Empty(cdatafim) .and. Empty(cdatalimite) //Data Inicio preenchida      1
		lGeraZlo := .F.
		lApagaInt	:= .T.
	Elseif Empty(cdataini) .and. !Empty(cdatafim) .and. Empty(cdatalimite) //Data Fim preenchida     2
		lGeraZlo := .F.
		lApagaInt	:= .T.
	Elseif Empty(cdataini) .and. Empty(cdatafim) .and. !Empty(cdatalimite) //Data Limite preenchida     3
		lGeraZlo := .F.
		lApagaInt	:= .T.
	Elseif !Empty(cdataini) .and. !Empty(cdatafim) .and. Empty(cdatalimite) //Data Inicio e Fim preenchidas   4
		lGeraZlo := .T.
		lApagaInt	:= .T.
	Elseif !Empty(cdataini) .and. !Empty(cdatafim) .and. !Empty(cdatalimite) //Todas as Datas preenchidas     5
		lGeraZlo := .T.
		lApagaInt	:= .T.
	Elseif !Empty(cdataini) .and. Empty(cdatafim) .and. !Empty(cdatalimite) //Data Inicio e Limite preenchidas			7
		If cdataini < cdatalimite
			lGeraZlo := .T.
			lApagaInt	:= .T.
		Else
			lGeraZlo := .F.
			lApagaInt	:= .T.
		Endif
	Endif

	If 	lApagaInt   // Deleta os registros
		cQuery := " Select * FROM  " + RetSqlName("FPQ") + " FPQ"
		cQuery += " WHERE FPQ_FILIAL = '"+xFilial("FPQ")+"'"
		cQuery += " AND FPQ_AS = ? "  // '"+cAs+"'"
		cQuery += " AND FPQ_PROJET = ? " //'"+cProjeto+"'"
		cQuery += " AND FPQ_OBRA = ? "// '"+cObra+"'"
		cQuery += " AND FPQ_STATUS = 'INTEGR'"
		cQuery += " AND FPQ_MAT = ? " //'"+cMat+"'"
		cQuery += " AND (FPQ_CONTRO = ? OR FPQ_CONTRO = '')" // '"+cControl+"'"
		If !Empty(cdatafim) .and. !Empty(cdataini)
			cQuery += " AND FPQ_DATA NOT BETWEEN ?  AND ?  " // '"+DtoS(cdataini)+"' '"+DtoS(cdatafim)+"'
		Elseif !Empty(cdatalimite) .and. !Empty(cdataini)
			cQuery += " AND FPQ_DATA NOT BETWEEN ?  AND ? " // '"+DtoS(cdataini)+"' '"+DtoS(cdatalimite)+"'
		Endif
		cQuery += " AND D_E_L_E_T_ = ''"
		cQuery += " ORDER BY FPQ_DATA"
		cQuery := ChangeQuery(cQuery)
		aBindParam := {cAs, cProjeto, cObra, cMat, cControl }
		If !Empty(cdatafim) .and. !Empty(cdataini)
			Aadd(aBindParam , DtoS(cdataini))
			Aadd(aBindParam , DtoS(cdatafim))
		Elseif !Empty(cdatalimite) .and. !Empty(cdataini)
			Aadd( aBindParam , DtoS(cdataini) )
			Aadd( aBindParam , DtoS(cdatalimite))
		endif
		 MPSysOpenQuery(cQuery,"TRBZLO",,,aBindParam)
		//MsAguarde( { || dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TRBZLO",.T.,.T.)},STR0038) //"Aguarde... Processando Dados..."

		DbSelectArea("TRBZLO")
		While !Eof()
			cChaveDel := TRBZLO->FPQ_MAT+TRBZLO->FPQ_DATA
			DbSelectArea("FPQ")
			dbsetorder(1)
			If DbSeek(xFilial("FPQ")+cChaveDel+ccontrol)
				If FPQ_AS+FPQ_PROJET+FPQ_OBRA+ALLTRIM(FPQ_STATUS) == TRBZLO->FPQ_AS+TRBZLO->FPQ_PROJET+TRBZLO->FPQ_OBRA+alltrim(TRBZLO->FPQ_STATUS)
					If FPQ_TIPINC = "A"
						RecLock("FPQ",.F.)
						dbDelete()
						MsUnlock("FPQ")
					Endif
				End
			Endif
			TRBZLO->(dbSkip())
		End

		TRBZLO->(DbCloseArea())
	Endif

Return


//-------------------------------------------------------------
Function LOCA075003 //fIncMat() Informar a matricula do funcionario.
Local cCod		:= Space(6)

    DEFINE MSDIALOG oDlgUser TITLE STR0027 FROM 000,000 TO 120,300 PIXEL OF oMainWnd //"Funcionário"

	@ 010,010 SAY STR0028 OF oDlgUser PIXEL 		 //"Informe a matricula do funcionario."
	@ 030,010 MSGET cCod F3 "SRAINT" SIZE 80,010 OF oDlgUser PIXEL
	@ 030,100 BUTTON STR0029 SIZE 35,14 PIXEL OF oDlgUser Action (Processa({|| GravaZM0(cCod) })) //"Confirmar"

	ACTIVATE MSDIALOG oDlgUser CENTERED

Return

Static Function GravaZM0(cCod)
Local cNome 	:= ""
Local aArea		:= GetArea()
Local aAreaSRA	:= SRA->(GetArea())
Local aAreaZM0	:= FPU->(GetArea())

   	DbSelectArea("SRA")
   	DbSetOrder(1)
   	If DbSeek(xFilial("SRA")+cCod)
   		cNome := SRA->RA_NOME
   	EndIf


	DbSelectArea("FPU")
	FPU->(DBSETORDER(1))

	IF !FPU->(DBSEEK(XFILIAL("FPU")+FQ5->FQ5_AS+cCod))

		RecLock("FPU", .T.)
		FPU->FPU_FILIAL := xFilial("FPU")
		FPU->FPU_AS 	:= FQ5->FQ5_AS
		FPU->FPU_OBRA 	:= FQ5->FQ5_OBRA
		FPU->FPU_PROJ 	:= FQ5->FQ5_SOT
		FPU->FPU_MAT 	:= cCod
		FPU->FPU_NOME 	:= cNome
		FPU->FPU_DTLIM  := FQ5->FQ5_DATINI
		FPU->FPU_DESIST := "2"
		FPU->FPU_CONTRO := "01"
		FPU->FPU_CODCLI := FQ5->FQ5_CODCLI
		FPU->FPU_LOJCLI := FQ5->FQ5_LOJA
		MsUnlock()

	ELSE

		MsgAlert(STR0035) //"AS / MATRÍCULA JÁ EXISTENTE !!"

	ENDIF

    oDlgUser:End()

	RestArea(aAreaZM0)
	RestArea(aAreaSRA)
	RestArea(aArea)
Return
