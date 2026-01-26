#INCLUDE "BADEFINITION.CH"

NEW ENTITY AUDPROCESSO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAudProcesso
Visualiza as informações dos históricos de Processos da área Jurídica.

@author  Andréia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAAuditProcesso from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrão.

@author  Andréia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAAuditProcesso
	_Super:Setup("AuditoriaProcessos", FACT, "O0F")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andréia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAAuditProcesso
	Local cQuery := ""
	
	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " +;
       		  "        <<KEY_FILIAL_O0F_FILPRO>> AS BK_FILIAL, " +;
	          "        <<KEY_SA1_A1_FILIAL+O0F_CCLIEN+O0F_LCLIEN>> BK_CLIENTE, " +; //Cliente
	          "        <<KEY_CTT_CTT_FILIAL+O0F_CCUSTO>> AS BK_CENTRO_CUSTO, " +; //Centro de Custo
	          "        <<KEY_NRB_NRB_FILIAL+O0F_CAREAJ>> AS BK_AREA_JURIDICA, " +; //Área Jurídica
              "        <<KEY_NRL_NRL_FILIAL+O0F_CSUBAR+NRL_CAREA>> AS BK_SUBAREA, " +; //SubÁrea Jurídica
              "        <<KEY_NQI_NQI_FILIAL+O0F_CMOENC>> AS BK_MOTIVO_ENCERRAMENTO, " +; //Motivo Encerramento
              "        <<KEY_O0E_O0E_FILIAL+O0F_MARCA>> AS BK_MARCA, " +; //Marca
              "        <<KEY_NSZ_O0F_FILPRO+O0F_CAJURI>> AS BK_PROCESSO_JUR, " +;  //Código Interno
              "        O0F_DTPROV AS DTPROVISAO, " +; //Data do Valor da Provisão 	          
 	          "        O0F_VLPROV AS VLPROVAVEL, " +; //Valor Provável
              "        O0F_VAPROV AS VLPROVAVELATUALIZADO, " +; //Valor Provável Atual
	          "        O0F_VLPRPO AS VLPRPOSSIVEL, " +; //Valor Possível
	          "        O0F_VLPPOA AS VLPRPOSSIVELATUALIZADO, " +; //Valor Possível Atual
	 	      "        O0F_VLPRRE AS VLPRREMOTO, " +; //Valor Remoto
	 	      "        O0F_VLPREA AS VLPRREMOTOATUALIZADO, " +; //Valor Remoto Atual
	  	      "        O0F_VCPROV AS VCPROVAVEL, " +; //Valor Correção Provável
	   	      "        O0F_VJPROV AS VJPROVAVEL, " +; //Valor Juros Provável
	    	  "        O0F_DTULAT AS DTULATUALIZACAO, " +; //Data Última Atualização
	     	  "        O0F_SITUAC AS SITUACAO, " +; //Situação do Processo
	      	  "        O0F_DTENCE AS DTENCERRAMENTO, " +; //Data do Encerramento
	      	  "        O0F_DTREAB AS DTREABERTURA, " +; //Data da Reabertura
	          "        O0F_VLFINA AS VLFINAL, " +; //Valor Final
	          "        O0F_VAFINA AS VLFINALATUALIZADO, " + ; //Valor Final Atual
               "        <<CODE_INSTANCE>> AS INSTANCIA " +;
	          "   FROM <<O0F_COMPANY>> O0F " +;
	          "   LEFT JOIN <<SA1_COMPANY>> SA1 " +; //Cliente
              "     ON A1_COD = O0F_CCLIEN " +;
              "    AND A1_LOJA = O0F_LCLIEN " +;
              "    AND A1_FILIAL = <<SUBSTR2_SA1_NSZ_O0F_FILPRO>> " +;
              "    AND SA1.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<CTT_COMPANY>> CTT " +; //Centro de custo  
              "     ON CTT_CUSTO = O0F_CCUSTO " +;
              "    AND CTT_FILIAL = <<SUBSTR2_CTT_NSZ_O0F_FILPRO>> " +;
              "    AND CTT.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<NRB_COMPANY>> NRB " +; //Área
              "     ON NRB_COD = O0F_CAREAJ " +;
              "    AND NRB_FILIAL = <<SUBSTR2_NRB_NSZ_O0F_FILPRO>> " +;
              "    AND NRB.D_E_L_E_T_ = ' ' " +; 
              "   LEFT JOIN <<NRL_COMPANY>> NRL " +; //SubArea
              "     ON NRL_CAREA = NRB_COD " +;
              "    AND NRL_COD = O0F_CSUBAR " +;
              "    AND NRL_FILIAL = <<SUBSTR2_NRL_NSZ_O0F_FILPRO>> " +;
              "    AND NRL.D_E_L_E_T_ = ' ' " +; 
              "   LEFT JOIN <<NQI_COMPANY>> NQI " +; //Motivo encerramento
              "     ON NQI_COD = O0F_CMOENC" +;   
              "    AND NQI_FILIAL = <<SUBSTR2_NQI_NSZ_O0F_FILPRO>> " +;
              "    AND NQI.D_E_L_E_T_ = ' ' " +;  
              "  INNER JOIN <<O0E_COMPANY>> O0E " +; //Marca
              "     ON O0E_MARCA = O0F_MARCA " +;   
              "    AND O0E_FILIAL = <<SUBSTR_O0E_O0F_FILIAL>> " +;
              "    AND O0E.D_E_L_E_T_ = ' ' " +;  
              "  WHERE O0F.D_E_L_E_T_ = ' ' " +;
                   " <<AND_XFILIAL_O0F_FILIAL>> " 

Return cQuery
