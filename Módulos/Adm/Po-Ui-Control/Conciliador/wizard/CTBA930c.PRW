#INCLUDE "CTBA930C.ch"
#INCLUDE "protheus.ch"
#INCLUDE "apwizard.ch"

/*{Protheus.doc} PopUUID
Cria o SDF para inclusão dos capos UUID

@author: TOTVS
@since 06/08/2021 
@version 1.0
*/
Function CTBA930c()  
Local aSM0		:= {}
Local aHeader   := {}
Local aCols930c := {}
Local lWizFinal := .F.
Local lBack 	:= .F.
Local cMens		:=	STR0001 + CRLF +;  //"Essa rotina fará o preenchimento dos campos _MSUID para utilização na rotina de conciliação."
					STR0002 + CRLF +;  //"Informe o intervalo de datas para gravar o conteúdo dos campos de ID criados anteriormente."
					STR0003 + CRLF +;  //"Atenção - Informe apenas o período que realmente deseja utilizar no conciliador."
					STR0004  //"O tempo de processamento é proporcional ao tamanho do período escolhido."
Local lVldDic := .F.

Private oWizard
Private lContinua  := .T.
Private lCriouSDF  := .F.
Private cListTab   := ""
Private dDatAte    := Date()
Private dDatDe	   := FirstDay(MonthSub(dDatAte,1))
Private oGetWizard

Rptstatus({|| lVldDic := C930IniDad(aHeader,aCols930c,aSM0) },STR0006, STR0005) //"Preparando os dados para o wizard..." //"Aguarde..."

If lVldDic
	//Painel 1 - Tela inicial do Wizard
	oWizard := APWizard():New(STR0007/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0008/*<chMsg>*/, ""/*<cTitle>*/, ; //"Preenchimento dos campos _MSUID"
	cMens, ;
	{|| !Empty(dDatDe) .And. !Empty(dDatAte)} /*<bNext>*/ ,;
	{||.T.}/*<bFinish>*/,;
	.T./*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	//Painel 2 - Definição das Novas Entidades
	oWizard:NewPanel(STR0007/*<chTitle>*/,; //"Conciliador - Wizard de Configuração"
	STR0008/*<chMsg>*/,; //"Preenchimento dos campos _MSUID"
	{||lBack := .T.}/*<bBack>*/,;
	{||.F.} /*<bNext>*/ ,;
	{|| lWizFinal := (C930VldSel(aCols930c) .And. CVldDatSel(aCols930c)) }/*<bFinish>*/,;
	.T./*<.lPanel.>*/ ,;
	{|| aCols930c := IIf(lBack, aCols930c, C930MARK(aHeader,aCols930c,aSM0))}/*<bExecute>*/) //Montagem da tela


	oWizard:Activate( .T./*<.lCenter.>*/,;
	{|| .T.}/*<bValid>*/,;
	{|| C930GetDat()}/*<bInit>*/,;
	{||.T.}/*<bWhen>*/)

	If lWizFinal	
		WizGrvUUID(aSM0, aCols930c)	
	EndIf
EndIf

Return .T.

/*{Protheus.doc} WizGrvUUID
Grava o UUID nos campos do aCols.

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizGrvUUID(aSM0,aCols)
Local nI := 0
Local cEmpFor := ""
Local cEmpAux := cEmpAnt
Local cFilAux := cFilAnt

DEFAULT aSM0 := {}

For nI := 1 to Len(aCols)	
	If aCols[nI,1]
		cEmpFor := Left(aCols[nI,2],2)
		If cEmpFor <> cEmpAnt
			If (nPos := aScan(aSM0,{|x| x[1]==cEmpFor})) > 0
				C930SelEmp(aSM0[nPos,1],aSM0[nPos,2])
			EndIf
		EndIf		
		RptStatus({|| WizGrvID(aCols[nI,3],aCols[nI,4],aCols[nI,5])},STR0009, STR0010+AllTrim(aCols[nI,4])) //"Processando..." //"Gravando o conteúdo nos campos de ID: "
	EndIf
Next nI

C930MsgBox(STR0018) //"Processo de atualização finalizado"

If cEmpAnt <> cEmpAux
	C930SelEmp(cEmpAux,cFilAux)
EndIf

Return 

/*{Protheus.doc} WizGrvID
Grava o UUID nos campos do aCols.

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function WizGrvID(ctabela,cCpoUUID,cCpoDat)
Local cSQL := ""
Local cAliasQry := GetNextAlias()
Local nCount := 0
Local lFormatUID := If(AllTrim(Upper(TCGetDB())) == "ORACLE", .F., .T.) 

cSQL := " SELECT R_E_C_N_O_ REC "
cSQL += " FROM "+RetSQLName(cTabela)
cSQL += " WHERE "+cCpoUUID+" IS NULL AND "
cSQL += cCpoDat+" BETWEEN '"+DtoS(dDatDe)+"' AND '"+DtoS(dDatAte)+"' AND "
cSQL += " D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),cAliasQry,.T.,.T.)

nCount := Contar(cAliasQry,"!Eof()")
SetRegua(nCount)

(cAliasQry)->(dbGoTop())

While !(cAliasQry)->(Eof())
	(cTabela)->(dbGoTo((cAliasQry)->REC))

	IncRegua()
	
	RecLock(ctabela,.F.)
		&(ctabela+"->"+cCpoUUID) := FWUUIDV4(lFormatUID)
	(ctabela)->(MsUnlock())

	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

Return

/*{Protheus.doc} CT930SXB
Consulta padrão do SX3

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Function CT930SXB(aCols, oBrowseQLB)    
    Local aArea := GetArea()
   	Local nJanLarg := 0400
    Local nJanAltu := 0300    
	Local cRetorno := .F.
	Local cAlias := ""

	Private oMsNew 
    Private oDlgEspe
	Private aHeadAux := {}
    Private aColsAux := {}       
    
	If oBrowseQLB <> NIL
		cAlias := aCols[oBrowseQLB:nAt,3]

		//Monta dados do Grid
		C930MGrid(aHeadAux, aColsAux,cAlias)
		
		DEFINE MSDIALOG oDlgEspe TITLE STR0011 FROM 000, 000  TO nJanAltu, nJanLarg PIXEL //"Campos Data"
			
			oMsNew := MsNewGetDados():New(005,005,(nJanAltu/2)-31,(nJanLarg/2)-6,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue()",,"",,,999,,,,oDlgEspe,aHeadAux,aColsAux)
			oMsNew:lActive := .F.
			oMsNew:oBrowse:blDblClick := {|| cRetorno := C930BOK()}
			
			@ (nJanAltu/2)-19, (nJanLarg/2)-((50*1)+06) BUTTON oBtnConf PROMPT STR0012 SIZE 50, 013 OF oDlgEspe ACTION(cRetorno := C930BOK()) PIXEL //"Confirmar"
			@ (nJanAltu/2)-19, (nJanLarg/2)-((50*2)+09) BUTTON oBtnLimp PROMPT STR0013  SIZE 50, 013 OF oDlgEspe ACTION(cRetorno := C930BCAN()) PIXEL //"Cancelar"
			
			oMsNew:oBrowse:SetFocus()
		ACTIVATE MSDIALOG oDlgEspe CENTERED
		
		If !Empty(cRetorno)
			aCols[oBrowseQLB:nAt,5] := cRetorno
		EndIf
		
		RestArea(aArea)
	EndIf
Return
 
 /*{Protheus.doc} C930BOK
Botão confirma da consulta padrão 

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930BOK()
Local cRetorno := ""
    cRetorno := oMsNew:aCols[oMsNew:nAt][1]     
    oDlgEspe:End()
Return cRetorno
 
/*{Protheus.doc} C930BCAN
Botão calcelar da consulta padrão 

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930BCAN()
Local cRetorno := ""
    cRetorno := Space(10)
    oDlgEspe:End()
Return cRetorno

/*{Protheus.doc} C930MGrid
Monta os dados da Grid

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function C930MGrid(aHeadAux, aColsAux, cAlias)
Local aFldStruct := {}
Local nI := 0

DEFAULT aHeadAux := {}
DEFAULT aColsAux := {}
DEFAULT cAlias := ""

aAdd(aHeadAux, {STR0014	,"TMP_CAMPO","",20,0,".T.",".T.","C", "",""} ) //"Campo"
aAdd(aHeadAux, {STR0015,"TMP_NOME"	,"",20,0,".T.",".T.","C", "",""} ) //"Título"
aAdd(aHeadAux, {STR0016	,"TMP_TIPO"	,"",01,0,".T.",".T.","C", "",""} ) //"Tipo"

If !Empty(cAlias)
	aFldStruct := FWSX3Util():GetListFieldsStruct(cAlias,.F.)
	For nI := 1 to Len(aFldStruct)
		If aFldStruct[nI,2] == "D"
			aAdd(aColsAux, {aFldStruct[nI,1],;
							FWX3Titulo(aFldStruct[nI,1]),;
							aFldStruct[nI,2],;							
							.F.})
		EndIf	
	Next nI	
	aSort(aColsAux,,,{|x,y| y[1]>x[1]})	
EndIf

Return 

/*{Protheus.doc} CVldDatSel
Valida se os campos data foram informados

@author: TOTVS
@since 06/08/2021
@version 1.0
*/
Static Function CVldDatSel(aCols)
Local lRet := .T.
Local nI   := 0

DEFAULT aCols := {}

For nI := 1 to Len(aCols)
	If aCols[nI,1] .And. Empty(aCols[nI,5])
		lRet := .F.
		C930MsgBox(STR0017)//'É obrigatório preencher o campo "Campo Dt." para os registros selecionados.'
		Exit
	EndIf
Next
Return lRet
