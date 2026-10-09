#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_AGR.CH"

/*{Protheus.doc}
Função de compatibilização do release incremental.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA
@type function
@version P12 
@author Agroindustria
@since 23/08/2023
*/
Function RUP_AGR( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )	
	If cMode == '1' 
		If cRelStart < "2310" .and. cRelFinish >= "2310"
			RUPSX72310()	//Contem alteracoes das releases 12.1.2310 - SX7
			RUPSX92310()    //Contem alteracoes das releases 12.1.2310 - SX7 
		EndIf		
	Endif
Return  Nil


/*{Protheus.doc} RUPSX72310
Função de compatibilização do release incremental.
Função chamada apartir da rotina RUP_AGR
NÃO REALIZAMOS A EXPEDICAO DE DICIONARIO POR ISSO OS AJUSTES ANTES DA EXPEDIÇÃO DA RELEASE SERAO TRATADOS NO RUP
@type function
@version P12 
@author Agroindustria
@since 23/08/2023
*/
Function RUPSX72310()
Local _aArea  := GetArea()

	//NP9 - LOTES DE SEMENTE	
	DbSelectArea("SX7")
    SX7->(dbSetOrder(1)) 
	
    If SX7->(DbSeek("NP9_PROD")) //não existe, é legado v11, caso existir deletaR
        While AllTrim(SX7->(X7_CAMPO)) == "NP9_PROD"  .AND. AllTrim(SX7->(X7_PROPRI)) == "S"
            RecLock("SX7",.F.)
            SX7->(dbdelete())
        	SX7->(MsUnlock())
            SX7->(dbSkip())
        EndDo
    EndIf

	// Alterar gatilho 	
	DbSelectArea("SX7")
	DbSetOrder(1)
	If SX7->(dbSeek('NJM_CODCTR'))		
		While SX7->(!EOF()) .AND. AllTrim(SX7->(X7_CAMPO)) == 'NJM_CODCTR'
			If SX7->X7_REGRA = "N9A->N9A_ITEM" .AND. AllTrim(SX7->(X7_PROPRI)) == "S" 
				RecLock("SX7", .F. )
				Replace X7_REGRA With "OG250RFSX7()"
				SX7->(MsUnlock())
				SX7->(dbSkip())
			endif
			If SX7->X7_REGRA = "N9A->N9A_SEQPRI" .AND. AllTrim(SX7->(X7_PROPRI)) == "S" .and. !SX7->X7_SEEK == 'N'
				RecLock("SX7", .F. )
				Replace X7_SEEK With "N"
				Replace X7_ALIAS With ""
				Replace X7_ORDEM With 0
				Replace X7_CHAVE With ""
				SX7->(MsUnlock())
				SX7->(dbSkip())
			endif
			SX7->(dbSkip())	
		EndDo
	endif

	RestArea(_aArea)
	aSize(_aArea,0)
	_aArea := nil 
Return  Nil



/*{Protheus.doc} RUPSX72310
Função de compatibilização do release incremental.
Função chamada apartir da rotina RUP_AGR
NÃO REALIZAMOS A EXPEDICAO DE DICIONARIO POR ISSO OS AJUSTES ANTES DA EXPEDIÇÃO DA RELEASE SERAO TRATADOS NO RUP
@type function
@version P12 
@author Agroindustria
@since 23/08/2023
*/
Static Function RUPSX92310()
Local _aArea  := GetArea()

	DbSelectArea("SX9")
    SX9->(dbSetOrder(2)) 	
    If SX9->(DbSeek("DXIDXL"))
        While SX9->(!Eof()) .And. SX9->(X9_CDOM + X9_DOM) == "DXIDXL"
            If ALLTRIM(SX9->X9_EXPCDOM) == "DXI_FILIAL+DXI_FARDAO" .AND. ALLTRIM(SX9->X9_EXPDOM) == "DXL_FILIAL+DXL_CODIGO" .and. !SX9->X9_ENABLE == 'N'
                RecLock("SX9",.F.)
                SX9->X9_ENABLE :='N'
                SX9->(MsUnlock())
            ElseIf ALLTRIM(SX9->X9_EXPCDOM) == "DXI_FARDAO" .AND. ALLTRIM(SX9->X9_EXPDOM) == "DXL_CODIGO" .and. !SX9->X9_ENABLE == 'N'
                RecLock("SX9",.F.)
                SX9->X9_ENABLE :='N'
                SX9->(MsUnlock())
            EndIf
            SX9->(dbSkip())
        EndDo
    EndIf

	RestArea(_aArea)
	aSize(_aArea,0)
	_aArea := nil 
Return 

