#INCLUDE 'TECA190B.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA190B

   Rotina para mesa operacional - chama a rotina que constrói com mensagem para o usuário aguardar

@sample TECA190B
@since	29/04/2014
@version P12
/*/
//------------------------------------------------------------------------------
Function TECA190B()

 TECA190D() // Nova mesa Operacional

Return

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At19ShowCk
	Mostra painel com dados do check-in\out (Chamada function TECA190d)

/*/
//--------------------------------------------------------------------------------------------------------------------
Function At19ShowCk(cCodABB,cFilABB)

Local aArea      := GetArea()
Local aSaveLines := FWSaveRows()
Local oModel     := FwLoadModel('TECA190C')
Local cTemp      := ""
Local cQuery     := ""
Local oExec      := Nil
Local aButtons   := {	{.F.,Nil},;			//- Copiar
						{.F.,Nil},;			//- Recortar
						{.F.,Nil},;			//- Colar
						{.F.,Nil},;			//- Calculadora
						{.F.,Nil},;			//- Spool
						{.F.,Nil},;			//- Imprimir
						{.F.,STR0065},;		//- Confirmar
						{.T.,STR0066},;		//- Cancelar
						{.F.,Nil},;			//- WalkThrough
						{.F.,Nil},;			//- Ambiente
						{.F.,Nil},;			//- Mashup
						{.F.,Nil},;			//- Help
						{.F.,Nil},;			//- Formulário HTML
						{.F.,Nil} }			//- ECM

Default cFilABB := XFilial("ABB") 

ABB->(dbSetOrder(8)) //ABB_FILIAL+ABB_CODIGO
If ABB->(DbSeek(cFilABB+ cCodABB))

	cQuery := "SELECT 1 "
	cQuery +=	" FROM ? T48 "
	cQuery +=	" WHERE "
	cQuery +=	" T48.T48_FILIAL = ? AND "
	cQuery +=	" T48.T48_CODABB = ? AND "
	cQuery +=	" T48.T48_TIPO IN ('1','3') AND "
	cQuery +=	" T48.D_E_L_E_T_= ' '"

	cQuery := ChangeQuery(cQuery)
	oExec := FwExecStatement():New(cQuery)

	oExec:SetUnsafe( 1, RetSqlName("T48") )
	oExec:SetString( 2, xFilial("T48") )
	oExec:SetString( 3, cCodABB )

 	cTemp := oExec:OpenAlias()

	If (cTemp)->(!Eof())
		oModel:Activate()
		FWExecView( STR0057,"TECA190C", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. } ,, 20, aButtons, /*bCancel*/ ) //Dados Check-in\Out
	Else
		MsgAlert(STR0058) //Não foi efetuado check-in\out via mobile para este registro
	EndIf
EndIf

(cTemp)->(DbCloseArea())
oExec:Destroy()
FwFreeObj(oExec)

FWRestRows( aSaveLines )
RestArea(aArea)

Return
