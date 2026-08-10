#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE001()
Calculo da Temperatura Media. 
Adapta豫o da fun豫o TDCEE003
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
@return nMedTp
/*/
//-------------------------------------------------------------------
Function DCLEE003()
Local cArea	:= Alias()
Local nRec		:= Recno()
Local cInd		:= IndexOrd()
Local nMedTp	:= M->DH7_TEMP
Local nMedia	:= 0

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

SetPrvt("CAREA,NREC,CIND,NMEDTP,NMEDIA,")

If SuperGetMv("MV_DCLNEW",.F.,.F.)

	If M->DH7_TEMP1 > 0
		nMedia := nMedia + 1
	EndIf
	
	If M->DH7_TEMP2 > 0
		nMedia := nMedia + 1
	EndIf
	
	If M->DH7_TEMP3 > 0
		nMedia := nMedia + 1
	Endif
	
	nMedTp := (M->DH7_TEMP1 + M->DH7_TEMP2 + M->DH7_TEMP3 ) / nMedia
	
	DbSelectArea(cArea)
	DbSetOrder(cInd)
	Dbgoto(nRec)
EndIf

Return(nMedTp)
