#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TMSAI88.CH"

#DEFINE DEFALIAS {"DN6","DN2","DN3","DNB"}

/*{Protheus.doc} TMSAI88
Exporta/Importa os layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88()
(examples)
@see (links_or_references)
*/
Function TMSAI88(nAcao)
Local aVetLay   := {}
Local cDir      := Space(255)
Local cCodFon   := Space(TamSX3("DN6_CODIGO")[1])
Local lImpLocal := .T.

Private cAcao := ""

Default nAcao := 0	//-- 1=Exportação # 2=Importação

	If nAcao == 1	//-- Exportação
		cAcao := STR0002
	Else	//-- Importação
		cAcao := STR0003
	EndIf

	If TMSAI88Wiz(nAcao,@cDir,@cCodFon,@lImpLocal)
		If nAcao == 1	//-- Exportação
			FwMsgRun(,{|| aVetLay := TMSAI88Sel(cCodFon)},STR0007,STR0009)	//-- Processando # Selecionando registros
			FwMsgRun(,{|| TMSAI88Grv(AllTrim(cDir),Aclone(aVetLay))},STR0007,STR0008)	//-- Processando # Gravando arquivo
		Else	//-- Importação
			FwMsgRun(,{|| TMSAI88Imp(AllTrim(cDir),cCodFon,lImpLocal)},STR0007,STR0012)	//-- Processando # Importando layouts
		EndIf
	EndIf

Return

/*{Protheus.doc} TMSAI88Sel
Seleciona registros para a exportação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88Sel()
(examples)
@see (links_or_references)
*/
Function TMSAI88Sel(cCodFon)
Local aLayout   := {}
Local aAliasLay := DEFALIAS
Local aStruc    := {}
Local aRegistro := {}
Local nAlias    := 0
Local aAreas    := {}
Local cCampoCod := ""

	AEval(aAliasLay,{|xAlias| AAdd(aAreas, (xAlias)->(GetArea()) ) })
	AAdd(aAreas, GetArea() )

	For nAlias := 1 To Len(aAliasLay)
		If aAliasLay[nAlias] == "DN6"
			cCampoCod := "_CODIGO"
		Else
			cCampoCod := "_CODFON"
		EndIf
		AAdd(aLayout,{aAliasLay[nAlias],{},{}})
		aStruc := (aAliasLay[nAlias])->(DbStruct())
		AEval(aStruc,{|x| AAdd(aLayout[nAlias][2], X[1] ) })
		(aAliasLay[nAlias])->(DbSetOrder(1))
		(aAliasLay[nAlias])->(MsSeek(xFilial(aAliasLay[nAlias])+cCodFon))
		Do While !(aAliasLay[nAlias])->(Eof()) .And. (aAliasLay[nAlias])->(FieldGet(FieldPos(aAliasLay[nAlias]+"_FILIAL"))+FieldGet(FieldPos(aAliasLay[nAlias]+cCampoCod))) == xFilial(aAliasLay[nAlias])+cCodFon
			aRegistro := {}
			(aAliasLay[nAlias])->(AEval(aLayout[nAlias][2], {|xCampo| AAdd(aRegistro, FieldGet(FieldPos(xCampo)) ) } ))
			AAdd(aLayout[nAlias][3], AClone(aRegistro) )
			(aAliasLay[nAlias])->(DbSkip())
		EndDo
	Next

	AEval(aAreas, {|x,y| RestArea(x), FwFreeArray(x)} )
	FwFreeArray(aAreas)
	FwFreeArray(aAliasLay)
	FwFreeArray(aStruc)
	FwFreeArray(aRegistro)
	
Return aClone(aLayout)

/*{Protheus.doc} TMSAI88Grv
Grava vetor com os layouts
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2022
@version P12
@example TMSAI88Grv()
(examples)
@see (links_or_references)
*/
Function TMSAI88Grv(cDirArq,aVetGrv)

	Default cDirArq := ""
	Default aVetGrv := {}

	If !Empty(aVetGrv)
		__VSave(aVetGrv,cDirArq)
	EndIf

Return

/*{Protheus.doc} TMSAI88Exc
Exclui registros do mesmo código de fonte
@author Valdemar Roberto Mognon
@since 29/07/2022
*/
Function TMSAI88Exc(cCodFon,aVetImp)
Local aArea  := GetArea()
Local nAlias := 0

Default cCodFon := ""

	For nAlias := 1 To Len(aVetImp)
		(aVetImp[nAlias][1])->(DbSetOrder(1))
		Do While (aVetImp[nAlias][1])->(DbSeek(xFilial(aVetImp[nAlias][1])+cCodFon))
			RecLock(aVetImp[nAlias][1],.F.)
			(aVetImp[nAlias][1])->(DbDelete())
			MsUnlock()
		EndDo
	Next

	RestArea(aArea)
	FwFreeArray(aArea)

Return

/*{Protheus.doc} TMSAI88Imp
Executa a importação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88Imp()
(examples)
@see (links_or_references)
*/
Function TMSAI88Imp(cDirArq,cCodFon,lImpLocal)

Local aArea   := GetArea()
Local aVetImp := {}
Local nAlias  := 0
Local nReg    := 0
Local nCampo  := 0
Local cTemp   := ""

	If !Empty(cCodFon) .And. (!lImpLocal .Or. !Empty(cDirArq))
		Begin Transaction
		If !lImpLocal
			cDirArq := "\templay.lay"
			cTemp   := HttpGet("http://manifest.engpro.totvs.com.br/" + cCodFon + ".lay")
//			cTemp   := HttpGet("http://localhost/files/" + cCodFon + ".html")  //-- Utilizado para testes locais
			FErase(cDirArq)
			MemoWrite(cDirArq,cTemp)
		EndIf
		aVetImp := __VRestore(cDirArq)
		If !lImpLocal
			FErase(cDirArq)
		EndIf
		//Exclui todos os registros antes de incluir novamente.
		TMSAI88Exc(cCodFon,aVetImp)
		//Faz loop de inclusão de registros
		For nAlias := 1 To Len(aVetImp)
			For nReg := 1 To Len(aVetImp[nAlias][3])
				RecLock(aVetImp[nAlias][1],.T.)
				For nCampo := 1 To Len(aVetImp[nAlias][2])
					If "_FILIAL" $ aVetImp[nAlias][2][nCampo]
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( aVetImp[nAlias][1]+"_FILIAL" ), xFilial(aVetImp[nAlias][1]) ) )
					ElseIf "_CODFON" $ aVetImp[nAlias][2][nCampo]
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( aVetImp[nAlias][1]+"_CODFON" ), cCodFon ) )
					ElseIf "DN6_CODIGO" $ aVetImp[nAlias][2][nCampo]
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( "DN6_CODIGO" ), cCodFon ) )
					Else
						(aVetImp[nAlias][1])->( FieldPut( FieldPos( aVetImp[nAlias][2][nCampo] ), aVetImp[nAlias][3][nReg][nCampo] ) )
					EndIf
				Next
				MsUnLock()
			Next
		Next
		End Transaction
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
	FwFreeArray(aVetImp)

Return

/*{Protheus.doc} TMSAI88A
Acionamento do fonte de exportação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88A()
(examples)
@see (links_or_references)
*/
Function TMSAI88A()

TMSAI88(1)

Return

/*{Protheus.doc} TMSAI88B
Acionamento do fonte de importação dos layouts de integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 27/07/2022
@version P12
@example TMSAI88B()
(examples)
@see (links_or_references)
*/
Function TMSAI88B()

TMSAI88(2)

Return

/*{Protheus.doc} TMSAI88Vld
Valida a existência do arquivo na pasta e layouts com o código fonte
@type Function
@author Valdemar Roberto Mognon
@since 28/07/2022
@version P12
@example TMSAI88Vld()
(examples)
@see (links_or_references)
*/
Function TMSAI88Vld(nAcao,cDirArq,cCodFon,lYesNo)
Local lRet    := .T.
Local aAreas  := {DN2->(GetArea()),GetArea()}
Local cPasta  := ""

Default nAcao   := 0
Default cDirArq := ""
Default cCodFon := ""
Default lYesNo  := .T.

	If nAcao == 1 .Or. nAcao == 2
		cDirArq := AllTrim(cDirArq)
		cPasta  := Left(cDirArq,RAt("\",cDirArq)-1)
		If Upper(Right(cDirArq,4)) != ".LAY"
			Help("",1,"TMSAI8804")	//-- Extensão incorreta. Informe um nome de arquivo com extensão de layout (.lay)
			lRet := .F.
		ElseIf !File(cPasta) //-- Verifica se a pasta existe
			Help("",1,"TMSAI8803")	//-- Pasta inexistente # Selecione uma pasta que exista
			lRet := .F.
		ElseIf nAcao == 1	//-- Verifica se o arquivo já existe
			If File(cDirArq)
				If lYesNo .And. !MsgNoYes(STR0004 + STR0005 + STR0006)	//-- Arquivo já existe na pasta e será substituido. # Deseja continuar?
					lRet := .F.
				EndIf
			EndIf
		ElseIf nAcao == 2	//-- Verifica se o arquivo não existe
			If !File(cDirArq)
				Help("",1,"TMSAI8802")	//-- Arquivo LayColEnt.Lay não localizado nesta pasta. # Selecione a pasta que contenha o arquivo LayColEnt.Lay.
				lRet := .F.
			EndIf
		EndIf
	ElseIf nAcao == 3	//-- Verifica se existem registros com o código fonte selecionado
		DN2->(DbSetOrder(1))
		If DN2->(DbSeek(xFilial("DN2") + cCodFon))
			If !MsgNoYes(STR0010 + cCodFon + ". " + STR0006)	//-- Existem layouts com o código fonte # cCodFon. # Deseja continuar?
				lRet := .F.
			EndIf
		EndIf
	EndIf

	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSAI88Wiz
Função Wizard de Entrada
@author Carlos Alberto Gomes Junior
@since 02/08/2022
*/
Function TMSAI88Wiz(nAcao,cDir,cCodFon,lImpLocal)

Local oWizard As Object
Local oList   As Object
Local oGet01  As Object
Local oGet02  As Object
Local oFont     := TFont():New('Courier new',,-18,.T.)
Local cText     := ""
Local lRet      := .F.
Local aLayOut   := {{.F.,"",""}}
Local cMess     := ""
Local nLinScr   := 0
Local nLinBut   := 0

DEFAULT lImpLocal := .T.

Private oBmpOk   := LoadBitmap(GetResources(), "LBOK")
Private oBmpNo   := LoadBitmap(GetResources(), "LBNO")

	cText += STR0013 + cAcao
	cText += STR0014 + CRLF
	cText += STR0015 + CRLF + CRLF + CRLF
	cText += STR0016

	If nAcao == 1
		cMess := STR0025
		nLinScr := 26
		nLinBut := 66
	ElseIf nAcao == 2
		cMess := STR0026
		nLinScr := 66
		nLinBut := 146
	EndIf

	//Inicialização objeto Wizard
	DEFINE WIZARD oWizard TITLE STR0018 ;
		HEADER cAcao + STR0017;
		MESSAGE STR0027 + cAcao + STR0028 TEXT cText ;
		NEXT {|| .T. } FINISH {|| .T. } PANEL

	//Segundo painel do Wizard (após o primeiro avançar)
	CREATE PANEL oWizard HEADER cAcao + STR0017 ;
		MESSAGE cMess ;
		BACK {|| .T. } NEXT {|| .T. } FINISH {|| ( lRet := ( !lImpLocal .Or. ( TMSAI88Vld(nAcao,cDir) .And. ExistCpo("DN6",cCodFon) ) ) .And. Iif(nAcao == 1,.T.,TMSAI88Vld(3,,cCodFon)) ) } PANEL

	//Criação dos dados dentro do painel
	If nAcao == 2
		aLayOut := TMSAI88Net()
		If Len(aLayOut) > 0
			oList := TWBrowse():New(002,002,299,60,,{" ",STR0029,STR0030},,oWizard:GetPanel(2),,,,,,,,,,,,.F.,,.T.,,.F.,,,) //-- "Documento","Serie","Emissão","Cliente","Loja","Nome"
			oList:SetArray(aLayOut)
			oList:bLine := {|| { Iif( aLayOut[oList:nAt][1], oBmpOk, oBmpNo ), aLayOut[oList:nAt][2],aLayOut[oList:nAt][3] } }
			oList:blDblClick := {|| lImpLocal := !MudaMarca(oList,aLayOut,@cDir,@cCodFon), oGet02:CtrlRefresh(), oGet01:CtrlRefresh(), oGet02:SetFocus(), oGet01:SetFocus() }
		Else
			TSay():New( 20, 02, {|| STR0031 },oWizard:GetPanel(2),,oFont,,,,.T.,CLR_RED,CLR_WHITE)
		EndIf
	EndIf
	TSay():New( nLinScr     , 02, {|| STR0019 },oWizard:GetPanel(2),,,,,,.T.)
	oGet01 := TGet():New( nLinScr + 08, 02, bSETGET(cDir),oWizard:GetPanel(2),180,10,, {|| Empty(cDir) .Or. TMSAI88Vld(nAcao,cDir,,.F.) },,,, .T.,, .T.,, .T., {|| lImpLocal }, .F., .F.,, .F., .F., "", cDir ,,,,.T.)
	TBtnBmp2():New( nLinBut, 370, 25, 25, "BMPVISUAL", , , , {|| cDir := cGetFile("Layout|*.Lay|" + STR0020 + "|*.*|",STR0021, 0, STR0022, .F., GETF_LOCALHARD+GETF_ONLYSERVER),cDir := PadR(cDir,255," ")} , oWizard:GetPanel(2), STR0023, {|| .T. }, )
	TSay():New( nLinScr + 25, 02, {|| STR0024 },oWizard:GetPanel(2),,,,,,.T.)
	oGet02 := TGet():New( nLinScr + 33, 02, bSETGET(cCodFon),oWizard:GetPanel(2),40,10,, {|| Empty(cCodFon) .Or. ExistCpo("DN6",cCodFon) },,,, .T.,, .T.,, .T., {|| lImpLocal }, .F., .F.,, .F., .F., "DN6", cCodFon ,,,,.T.)

	ACTIVATE WIZARD oWizard CENTER

	FWFreeObj(oWizard)
	FWFreeObj(oList)
	FWFreeObj(oBmpOk)
	FWFreeObj(oBmpNo)
	FWFreeObj(oFont)
	FWFreeObj(oGet01)
	FWFreeObj(oGet02)

Return lRet

/*{Protheus.doc} TMSAI88Net
Carregamento online de lista de layouts.
@author Carlos Alberto Gomes Junior
@since 02/02/2023
*/
Static Function TMSAI88Net
Local aRet   := {}
Local cTemp  := ""
Local aTemp1 := {}
Local aTemp2 := {}
Local n      := 0

	cTemp := AllTrim( HttpGet("http://manifest.engpro.totvs.com.br/integracoes.lay") )
	//cTemp := AllTrim( HttpGet("http://localhost/files/integracoes.html") )   //-- Utilizado para testes locais
	If !Empty(cTemp) .And. "#LISTA LAYOUT#" $ cTemp
		cTemp  := StrTran(cTemp,"#LISTA LAYOUT#"+CRLF,"")
		aTemp1 := StrTokArr(cTemp,CRLF)
		For n := 1 To Len(aTemp1)
			If !Empty(aTemp1[n])
				aTemp2 := StrTokArr(aTemp1[n],",")
				If Len(aTemp2) == 2
					AAdd(aRet,{.F.,aTemp2[1],aTemp2[2]})
				EndIf
			EndIf
		Next
	EndIf

	FwFreeArray(aTemp1)
	FwFreeArray(aTemp2)

Return aRet

/*{Protheus.doc} MudaMarca
Atualiza marca do TWBrowse
@author Carlos Alberto Gomes Junior
@since 17/01/2023
*/
Static Function MudaMarca(oList,aLayOut,cDir,cCodFon)

	If !aLayOut[oList:nAt][1]
		AEval(aLayOut,{|x,y| aLayOut[y][1] := .F. })
	EndIf
	aLayOut[oList:nAt][1] := !aLayOut[oList:nAt][1]
	If aLayOut[oList:nAt][1]
		cCodFon := aLayOut[oList:nAt][2]
	Else
		cCodFon := Space(TamSX3("DN6_CODIGO")[1])
	EndIf
	cDir := Space(255)
	oList:Refresh()

Return aLayOut[oList:nAt][1]
