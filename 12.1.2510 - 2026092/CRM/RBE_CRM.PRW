#INCLUDE 'PROTHEUS.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} RBE_CRM
Funcoes de compatibilizacao e/ou conversaoo de dados para as tabelas do sistema.

@sample RBE_CRM("12", "1", "2410", "2410", "BRA")

@param cVersion - Versao do Protheus
@param cMode - Modo de execucao - "1" = Por grupo de empresas / "2" = Por grupo de empresas + filial (filial completa)
@param cRelStart - Release de partida - (Este seria o Release no qual o cliente estao)
@param cRelFinish - Release de chegada - (Este seria o Release ao final da atualizacao)
@param cLocaliz - Localizacao (pais) - Ex. "BRA"

@return lRet

@author CRM/FAT
@since 06/05/2024
@version P12
/*/
//-------------------------------------------------------------------
Function RBE_CRM(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Local   lRet        := .F.
Default cVersion    := ''
Default cMode       := ''
Default cRelStart   := ''
Default cRelFinish  := ''
Default cLocaliz    := ''

    If cMode == '1'  // Nivel do grupo de empresas
            //--------------------------------------------------------------
            //- Avalia ajuste do grupo de campos 175 Nome do Cliente
	        //- Avalia ajuste do grupo de campos 176 Nome do Contato
            //- Será avaliado da release de saída cliente para qualquer
            //- release final.
            //--------------------------------------------------------------
        If cRelStart < '2410' .AND. cRelFinish >= '2410'
            lRet := totvs.pt.engineering.update.preprocess.RBESXG( '175', cRelStart, cRelFinish)
		    If lRet
		        lRet := totvs.pt.engineering.update.preprocess.RBESXG( '176', cRelStart, cRelFinish)
		    EndIf
        EndIf
   
     EndIf

Return lRet
