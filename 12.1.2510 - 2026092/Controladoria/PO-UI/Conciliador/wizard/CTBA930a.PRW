#Include "CTBA930A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "apwizard.ch"

Static lC930YesAll 
Static _lCTBA940j := NIL 

/*{Protheus.doc} CTBA930a 
Importa os arquivos Json para cadastrar a tabela QLB

@author: TOTVS
@since 06/08/2021 
@version 1.0
*/
Function CTBA930a() 
Local aSM0		:= {}
Local aHeader   := {}
Local lWizFinal := .F.
Local lBack		:= .F.
Local aCols930a := {}
Local cMens		:=	STR0001 + CRLF +; //"Essa rotina fará a importação das configurações de Match."
					STR0023 + CRLF +; //"Clique no botão Avançar para selecionar o diretório onde contidos os arquivos de configuração em formato json (tc_config)."
					STR0015 		  //"Verifique se todos os arquivos estão atualizados." 

Private oWizard
Private lContinua  := .T.
Private lCriouSDF  := .F.
Private cListTab   := ""
Private oGetWizard
Private cPathSave  := ""
Private lPathVld   := .T.

_lCTBA940j := If(_lCTBA940j == Nil, FindFunction("CTBA940J") .And. QLB->(FieldPos("QLB_VERSAO"))>0, _lCTBA940j)

If _lCTBA940j
	C930MsgBox(STR0029) //"Opção desabilitada! Configurações atualizadas automaticamente ao acessar o conciliador, campo QLB_VERSAO encontrado no ambiente"
Else
	//Inicialização de dados que era feita aqui, agora será feita na validação de dados da tela inicial do wizard abaixo.
	//Para que o usuário antes possa selecionar o diretório onde estarão contidos os arquivos .json
	//Rptstatus({|| lVldDic := C930IniDad(aHeader,aCols930a,aCols930a) },STR0003, STR0004) //"Aguarde..."

	//Painel 1 - Tela inicial do Wizard
	oWizard := APWizard():New(STR0005/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0001/*<chMsg>*/, ""/*<cTitle>*/, ; //"Essa rotina fará a importação das configurações de Match."
	cMens, ;
	{|| IIF( C930SelDir(aHeader, aCols930a, aSM0), .T., .F. ) .And. (!Empty(aCols930a) .And. !Empty(cPathSave)) /* .T. */ } /*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	//Painel 2 - Definição das Novas Entidades
	oWizard:NewPanel(STR0005/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0001/*<chMsg>*/,; //"Essa rotina fará a importação das configurações de Match."
	{|| lBack := .T.}/*<bBack>*/,;
	{||.F.} /*<bNext>*/ ,;
	{|| lWizFinal := C930VldSel(aCols930a) }/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| aCols930a := IIf(lBack, aCols930a, C930MARK(aHeader,aCols930a,aSM0))}/*<bExecute>*/) //Montagem da tela


	oWizard:Activate( .T./*<.lCenter.>*/,;
	{|| .T.}/*<bValid>*/,;
	{|| }/*<bInit>*/,;
	{||.T.}/*<bWhen>*/)

	If lWizFinal	
		WizGrvQLB(aSM0, aCols930a, cPathSave)	
	EndIf
EndIf

Return .T.

/*{Protheus.doc} WizGrvQLB
Grava a QLB com o json selecionado.

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizGrvQLB(aSM0, aCols, cPathSave)
Local nI := 0
Local cEmpFor := ""
Local cEmpAux := ""
Local cFilAux := ""
Local lContinua := .T.

cEmpAux := cEmpAnt
cFilAux := cFilAnt

lC930YesAll := nil

For nI := 1 to Len(aCols)
	If aCols[nI,1]
		cEmpFor := Left(aCols[nI,2],2)
		If cEmpFor <> cEmpAnt
			If (nPos := aScan(aSM0,{|x| x[1]==cEmpFor})) > 0
				lContinua := C930SelEmp(aSM0[nPos,1],aSM0[nPos,2])
			EndIf
		EndIf		
		If lContinua
			RptStatus({|| WizSetQLB(aCols[nI,5], cPathSave)},STR0007, STR0008+cEmpAnt) //"Aguarde"
		EndIf
	EndIf
Next

C930MsgBox(STR0014) //"Processo de atualização finalizado"

If cEmpAux <> cEmpAnt	
	C930SelEmp(cEmpAux,cFilAux)
EndIf

Return

/*{Protheus.doc} WizGrvQLB
Faz a abertura do arquivo e retorna o conteúdo

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizSetQLB(cArqJson, cPathSave)
Local nPos := 0
Local jStructQLB := JsonObject():New()
Local uRet 
Local cCaminho	 := cPathSave

Local lJaExisteQLB := .F.
Local lContinua := .T.

DEFAULT cArqJson := ""

nPos := At(".",cArqJson)
cArqJson := C930ReadF(cCaminho+Left(cArqJson,nPos+4))
If !Empty(cArqJson)
	uRet := jStructQLB:FromJson(cArqJson)
	If uRet == nil
		QLB->(dbSetOrder(1))
		lJaExisteQLB := (QLB->(dbSeek(xFilial("QLB")+jStructQLB["codcfg"])))
		
		If lJaExisteQLB
			If lC930YesAll == nil 
				lC930YesAll := .F.
				If MsgYesNo(STR0017+CHR(10)+CHR(13)+; //"Algumas configurações já existem na tabela QLB."
						 STR0018+CHR(10)+CHR(13)+; //"Sim - Sobrescreve todos."
						 STR0019, STR0009) //"Atenção" ### "Não - Prgunta a cada arquivo repetido."
					lC930YesAll := .T.				
				EndIf
			EndIf
			
			If !lC930YesAll .And. !MsgYesNo(STR0010+jStructQLB["codcfg"]+STR0011+cEmpAnt+STR0012, STR0009) //"Atenção"
				lContinua := .F.
			EndIf
		EndIf

		If jStructQLB["union"] <> nil .And. QLB->(FieldPos("QLB_TABGRP")) == 0	
			C930MsgBox(STR0020+jStructQLB["codcfg"]+STR0021+CRLF+STR0022) //"A configuração "###" não será importada."###"É necessário criar o campo QLB_TABGRP."
			lContinua := .F.
		EndIf

		If lContinua			
			RecLock("QLB", !lJaExisteQLB)
				QLB->QLB_FILIAL := xFilial("QLB")
				QLB->QLB_CODCFG := jStructQLB["codcfg"]
				QLB->QLB_DESCFG := jStructQLB["descfg"]
				QLB->QLB_TABORI := jStructQLB["tabori"]
				QLB->QLB_TABDES := jStructQLB["tabdes"]
				QLB->QLB_FIELDS := ValidFields(jStructQLB["fields"]):toJson()
				QLB->QLB_FILTER := jStructQLB["filter"]:toJson()
				QLB->QLB_CIDORI := jStructQLB["cidori"]
				QLB->QLB_CIDDES := jStructQLB["ciddes"]
				QLB->QLB_DESCOR := jStructQLB["descor"]
				QLB->QLB_DESCDE := jStructQLB["descde"]
				QLB->QLB_REGMAT := jStructQLB["regmat"]:toJson()
				QLB->QLB_TOTAL  := jStructQLB["total"]:toJson()
				If jStructQLB["union"] <> nil 
					QLB->QLB_TABGRP  := jStructQLB["union"]:toJson()					
				EndIf
			QLB->(MsUnlock())
		EndIf
		
	EndIf
EndIf

Return

/*{Protheus.doc} C930ReadF
Faz a abertura do arquivo e retorna o conteúdo

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function C930ReadF(cFile)
Local cBuffer := ''
Local nH , nTam

nH := Fopen(cFile)
IF nH != -1
	nTam := fSeek(nH,0,2)
	fSeek(nH,0)
	cBuffer := space(nTam)
	fRead(nH,@cBuffer,nTam)
	fClose(nH)
Else
	C930MsgBox(STR0013+cFile+STR0016+cValToChar(Ferror()) ) //"Falha na abertura do arquivo [" "] - FERROR "
Endif
Return cBuffer

/*/{Protheus.doc} C930SelDir
	Função que ira chamar a inicialização de dados do wizard, permitindo ao usuário selecionar o diretorio de preferencia.
	@type Static Function
	@author user
	@since 07/11/2022
	@version 12.1.2210
	/*/
Static Function C930SelDir(aHeader,aCols930a,aSM0)

Local lVldDic := .T.

lPathVld := .T.
cPathSave := ""

Rptstatus({|| lVldDic := C930IniDad(aHeader,aCols930a,aSM0) },STR0003, STR0004)

Return lVldDic

/*{Protheus.doc} ValidFields
Validacao da existência de campos para adicionar na QLB

@author: TOTVS
@since 06/03/2023
@version 1.0
*/
Static Function ValidFields(jFields)
Local nI := 0 as Numeric
Local nx := 0 as Numeric
Local jReturn := JsonObject():new() as Json
Local aFields := {} as Array
Local aReturn := {} as Array

If jFields <> Nil .And. ValType(jFields) == "J"
	aFields := jFields:GetNames()
	If aFields <> Nil .And. ValType(aFields) == "A"
		For nI := 1 To Len(aFields)			
			If jFields[aFields[nI]] <> Nil				
				aReturn := {}
				For nX := 1 To Len(jFields[aFields[nI]])
					If ValType(jFields[aFields[nI]][nX]) == "C" .And. Len(FWSX3Util():GetFieldStruct(jFields[aFields[nI]][nX])) > 0
						aAdd(aReturn, jFields[aFields[nI]][nX])
					EndIf
				Next nX
				jReturn[aFields[nI]] := aClone(aReturn)
			EndIf
		Next nI
	EndIf	
EndIf

FwFreeArray(aFields)
FwFreeArray(aReturn)
Return jReturn
