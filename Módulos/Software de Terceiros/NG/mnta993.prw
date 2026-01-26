#INCLUDE "mnta990.ch"
#INCLUDE "PROTHEUS.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA993
Browse de Eventos

@sample
MNTA993(cAlias,nRecno,nOpcxx)

@author Cauê Girardi Petri
@since 14/08/2024
/*/
//---------------------------------------------------------------------
Function MNTA993(cAlias,nRecno,nOpcxx)
	Local aArea 	:= GetArea()
	Local cOldProg	:= FunName()
	Local aOldRot 	:= aClone(aRotina)
	Local cOldCad 	:= cCadastro
	Local aOldDel 	:= aClone(aCHKDEL)

	Private lTTQDATA := .T.

	aRotina := MenuDef()

	SetFunName( 'MNTA993' )

	cCadastro := OemtoAnsi(STR0191) //"Eventos"
	aCHKDEL := {{"TTQ->TTQ_CODIGO","TT1", 5} }

	//---------------------------------------------------------------------
	// Endereca a funcao de BROWSE
	//---------------------------------------------------------------------
	dbSelectArea("TTQ")
	dbSetOrder(1)
	mBrowse( 6, 1,22,75,"TTQ")

	cCadastro := cOldCad
	aCHKDEL   := aClone(aOldDel)
	aRotina   := aClone(aOldRot)
	RestArea(aArea)

	SetFunName( cOldProg )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna menu funcional da rotina

@author Cauê Girardi Petri
@since 14/08/2024
@return aReturn, Array, Array com os botões da rotina.
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

Local aReturn := { { STR0002, "AxPesqui" , 0, 1},;  //"Pesquisar"
			 	   { STR0003, "NGCAD01"  , 0, 2},;  //"Visualizar"
			 	   { STR0004, "NGCAD01"  , 0, 3},;  //"Incluir"
			       { STR0005, "MNTCADTTQ", 0, 4},;  //"Alterar"
			       { STR0006, "NGCAD01"  , 0, 5, 3}}//"Excluir"

Return aReturn
