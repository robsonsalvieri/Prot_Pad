#INCLUDE 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGrvMHX
Função responsavel por realizar a gravação e exclusão dos dados nas tabelmas MHJ e MHK

@param   	aMHJ - Dados para a gravação da tabela
@param   	aMHK - Dados para a gravação da tabela
@param   	cChvDel - Chave para deletar os registros
@author  	Varejo
@version 	P12
@since   	25/06/2018
@return  		
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STDGrvMHX(aMHJ,aMHK,cChvDel)
Local nI :=  0
local nX :=  0

If !Empty(cChvDel)
	DbSelectArea("MHJ")
	MHJ->(DbSetOrder(1))//MHJ_FILIAL+MHJ_PRXTIT+MHJ_NUMTIT+MHJ_PARTIT                                                                                                                     
	If MHJ->( DbSeek( cChvDel ))
		Begin Transaction

			RecLock("MHJ",.F.)
			MHJ->(DbDelete())
			MHJ->(MsUnlock())
			//Exclui MHK_LOTE atrelada a MHJ_LOTE (A exclusão sera chamada para cada titulo)
			DbSelectArea("MHK")
			MHK->(DbSetOrder(1)) //MHK_FILIAL+MHK_LOTE+MHK_BANCO+MHK_DATMOV+MHK_NUMMOV                                                                                                              
			
			If MHK->(DbSeek( xFilial("MHK") + MHJ->MHJ_LOTE))
				While MHK->(!Eof()) .AND. xFilial("MHK") + MHK->MHK_LOTE == xFilial("MHJ") + MHJ->MHJ_LOTE
					RecLock("MHK",.F.)
					MHK->(DbDelete())
					MHK->(MsUnlock())
					MHK->(DbSkip())
				End
			Endif

		End Transaction
	EndIf	
Else

	Begin Transaction

		If !Empty(aMHJ) .AND. !Empty(aMHK) 
			For nX := 1 To Len(aMHJ)
				RecLock("MHJ",.T.)
				For nI := 1 To Len(aMHJ[nX]) 
					REPLACE MHJ->&( aMHJ[nX][nI][1] )	WITH aMHJ[nX][nI][2]
				Next nI
				MHJ->(MsUnlock())
			Next nX
		
			For nX := 1 To Len(aMHK)
				RecLock("MHK",.T.)
				For nI := 1 To Len(aMHK[nX]) 
					REPLACE MHK->&( aMHK[nX][nI][1] )	WITH aMHK[nX][nI][2]
				Next nI
				MHK->(MsUnlock())
			Next nX
			
		Else
			LjGrvLog("STDGrvMHX" ,"Dados para a gravação das tabelas MHJ e MHK não foram informados.")	
		EndIf

	End Transaction

Endif

Return