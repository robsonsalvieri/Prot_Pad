#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CenMonStat
Descricao: Status dos campos de cabeçalho

@author José Paulo
@since 03/08/2020
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CenMonStat()
	Local cStatus:= "1=Pendente Validação;2=Pronto para o Envio;3=Criticado;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado;7=Pendente Geração do Arquivo;8=Arquivo Gerado"

Return cStatus
