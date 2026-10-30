#include "protheus.ch"
#include "PLSMGER.CH"


Function PLSVIGOPE()
Local cFil
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina    := {  { "Visualizar", 'AxVisual'  , 0 ,K_Visualizar, 0 , NIL},;
       				     { "Incluir"   , 'PLSVIGInc' , 0 ,K_Incluir   , 0 , NIL},; 
       				     { "Alterar"  , 'PLSVIGAlt'  , 0 ,K_Alterar   , 0 , NIL},; 
                         { "Excluir"  , 'PLSVIGExc'  , 0 ,K_Excluir   , 0 , NIL} } 
PRIVATE cAlias     := "BHP"
PRIVATE cCadastro
PRIVATE cCodInt := PLSINTPAD()
cCadastro  := PLSRetTit(cAlias)

cFil := "BHP_FILIAL = '"+xFilial("BHP")+"' AND BHP_CODOPE = '"+BA0->(BA0_CODIDE+BA0_CODINT)+"' AND D_E_L_E_T_ = ' '"
DbSelectArea(cAlias)
BHP->(DbSetOrder(1))
BHP->(mBrowse(06,01,22,75,cAlias,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,.F.,nil,,cFil))
DbSelectArea(cAlias)

Return .T.

Function PLSVIGInc(cAlias,nReg,nOpc)

Return AxInclui(cAlias,nReg,nOpc,,,,"PLSVIGOK(.T.)")

Function PLSVIGAlt(cAlias,nReg,nOpc)

Return AxAltera(cAlias,nReg,nOpc,,,,,"PLSVIGOK(.F.)")

Function PLSVIGExc(cAlias,nReg,nOpc)

Return AxDeleta(cAlias,nReg,nOpc)


Function PLSVIGOK(lIncl)
	Local lRet		:= .T.
	LOCAL cSql 		:= ""
	Default lIncl   := .F.

	cSql := " SELECT BHP_CODOPE FROM "+RetSqlName("BHP")+" "
	csql += " 	WHERE BHP_FILIAL = '"+xFilial("BHP")+"' "
	cSQL += "     AND BHP_CODOPE = '"+IIF(lIncl,M->BHP_CODOPE,BHP->BHP_CODOPE)+"' " 
	cSql += " 	  AND BHP_VIGDE <= '"+IIF(lIncl,DtoS(M->BHP_VIGATE),DtoS(BHP->BHP_VIGATE))+"' "
	cSql += "     AND ( BHP_VIGATE = ' ' OR BHP_VIGATE >= '" + IIF(lIncl,DtoS(M->BHP_VIGDE),DtoS(BHP->BHP_VIGDE)) + "') "
	iiF (!lIncl,cSql += "     AND R_E_C_N_O_ <> '" + cValToChar(BHP->(RECNO())) + "' ","")
	cSql += "     AND D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),"TRBBHP",.T.,.T.)	

	If !TRBBHP->( Eof() ) 
		lRet := .F.
	EndIf

	IIF(SELECT("TRBBHP")>0,TRBBHP->( dbCloseArea() ),"")

	If !lRet
		Aviso( "Atenção", "Já existe uma vigência cadastrada para esta Operadora que conflita com a vigência informada.", { "Ok" }, 2 )
	EndIf

Return(lRet)
