#INCLUDE "rwmake.ch"   

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLEE001()
Calculo de  Volume de Agua no Tanque.   
Adapta豫o da fun豫o TDCEE001
@author Antonio Cordeiro
@since 01/07/2002
@version 1.0
@return _volume
/*/
//-------------------------------------------------------------------
Function DCLEE001()   

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
//?identificando as variaveis publicas do sistema utilizadas no codigo ?
//?Incluido pelo assistente de conversao do AP5 IDE                    ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
Local cFaixa  := AllTrim(SuperGetMV('MV_FXARQ',.F.,'I'))
Local aAreaDHG := DHG->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

SetPrvt("_CALIAS,_CINDEX,_NRECNO,_CONTA,_VOLUME,")

_cAlias := Alias()
_cIndex := IndexOrd()
_nRecno := Recno()
_Conta  := 0
_volume := 0

If SuperGetMv("MV_DCLNEW",.F.,.F.)

	dbSelectArea("DHG")
	DHG->(dbSetOrder(1))
	DHG->(dbSeek(xFilial() + M->DH7_TANQUE,.F.))
	
	While !eof() .And. DHG->DHG_FILIAL == xFilial() .And. DHG->DHG_TANQUE == M->DH7_TANQUE
		
	   If int(M->DH7_ALTAGU) >= DHG->DHG_CMINI .And. int(M->DH7_ALTAGU) <= DHG->DHG_CMFIM
	
	      	IF cFaixa=='F'
				_conta:= DHG->DHG_CMFIM - M->DH7_ALTAGU
			Else
				_conta:= M->DH7_ALTAGU - DHG->DHG_CMINI
			Endif
	      
			
			If _conta > 0
	         IF cFaixa == 'F'
	         	_volume:= Int(DHG->DHG_ACUM - NoRound(DHG->DHG_FATOR * _conta))
	         Else
	         	_volume:= Int(DHG->DHG_ACUM + NoRound(DHG->DHG_FATOR * _conta))	
	         EndIf
			else
	         _volume:= Int(DHG->DHG_ACUM)
			endif
			Exit
		Endif
		
		
	   DbSelectArea("DHG")
		DbSkip()
	Enddo
	
	dbSelectArea(_cAlias)
	dbSetOrder(_cIndex)
	dbGoTo(_nRecno)
	
	RestArea(aAreaDHG)
	
EndIf

Return(_Volume)

