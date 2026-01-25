#INCLUDE "PROTHEUS.CH"
#INCLUDE "FATA600B.CH"

#DEFINE NTASKAPR 7 //Prox. Tarefa - Aprovacao
#DEFINE NTASKREP 8 //Prox. Tarefa - Reprovacao

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft600Aprv

Aprovacao/Reprovacao de orcamentos

@sample  Ft600Aprv(lAprova,oDlg) 
@Param   lAprova - Aprova ou Reprova o Orçamento
@return  Nil

@author  Serviços/CRM
@since   26/05/2015
@version P12
/*/
//-----------------------------------------------------------------------------------------
Function Ft600Aprv(lAprova,oDlg)

Local aArea		:= GetArea()
Local cAlias	:= "SCJ"
Local nOpc		:= 2
Local nRec		:= 0

DbSelectArea("SCJ")
DbSetOrder(4) //CJ_FILIAL+CJ_PROPOST
DbSeek(xFilial("SCJ")+M->ADY_PROPOS)

nRec := SCJ->(Recno())

If lAprova
	A502Libera(cAlias,nRec,nOpc)
	Aviso(STR0006,STR0007,{STR0009},1)//Proposta Aprovada
Else 
	A502Desapr(cAlias,nRec,nOpc)
	Aviso(STR0006,STR0008,{STR0009},1)//Proposta Reprovada
EndIf

RestArea(aArea)

Return Nil

