#Include 'Protheus.ch'

#Define	DF_SX3_CPO				1
#Define	DF_SX3_CONTEUDO			2

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_FAT()
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
@sample		RUP_FAT("12", "2", "003", "005", "BRA")
@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução		- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"
@return		Nil
@author		Serviços & CRM
@since		06/08/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_FAT( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

If (cVersion == "12" .And. cRelFinish $ "2210|2310|2410")
    clearNotificationType(cRelStart)
EndIf

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} clearNotificationType
	Função utilizada limpar o conteúdo do campo A1S_TIPO na carga inicial, devido a 
    não ser possível limpar o conteúdo do mesmo por pacote de dicionário
	@type       Function
	@author     Squad CRM/Faturamento
	@since      13/08/2024
	@version    12.1.2410
/*/
//-------------------------------------------------------------------------------------
Static Function clearNotificationType(cRelStart)
    
    Local aArea     as array
    Local aAreaSX3	as array

    aArea    :=	FwGetArea()
    aAreaSX3 :=	SX3->(FwGetArea())
    
    SX3->(DBSetOrder(2))

    If SX3->(MsSeek("A1S_TIPO") .And. !Empty(SX3->X3_CBOX))
		If RecLock("SX3", .F.)
            SX3->X3_VALID   :=	""
            SX3->X3_CBOX    :=	""
            SX3->X3_CBOXSPA :=	""
            SX3->X3_CBOXENG :=	""
			SX3->(MsUnlock())
	    EndIf
	EndIf

    RestArea(aArea)
    RestArea(aAreaSX3)
    FwFreeObj(aArea)
    FwFreeObj(aAreaSX3)

Return Nil
