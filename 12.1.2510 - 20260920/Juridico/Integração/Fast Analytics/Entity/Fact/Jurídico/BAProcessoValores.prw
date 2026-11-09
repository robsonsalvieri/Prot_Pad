#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROCVALORES

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProcessoValores
Visualiza as informações dos Processos da área Jurídica.

@author  Andréia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAProcessoValores from BAEntity
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
Method Setup( ) Class BAProcessoValores
	_Super:Setup("ProcessosValores", FACT, "NSZ")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constrói a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andréia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAProcessoValores
	Local cQuery := ""
	
	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, " +;
       		  "        <<KEY_FILIAL_NSZ_FILIAL>> AS BK_FILIAL, " +;
              "        <<KEY_NSZ_NSZ_FILIAL+NSZ_COD>> AS BK_PROCESSO_JUR, " +;  //Código Interno
              "        NSZ_DTCAUS AS DTCAUSA, " +; //Data Valor Envolvido
			  "        NSZ_VLCAUS AS VLCAUSA, " +; //Valor Causa
              "        NSZ_VACAUS AS VLCAUSAATUALIZADO, " +; //Valor Causa Atualizado
              "        NSZ_DTENVO AS DTENVIO, " +; //Data Valor Envolvido
              "        NSZ_VLENVO AS VLENVOLVIDO, " +; //Valor envolvido
              "        NSZ_VAENVO AS VLENVOLVIDOATUALIZADO, " +; //Valor envolvido atualizado
              "        NSZ_VLFINA AS VLFINAL, " +; //Valor final
              "        NSZ_VAFINA AS VLFINALATUALIZADO, " +; //Valor final atualizado
              "        <<CODE_INSTANCE>> AS INSTANCIA " +;
              "   FROM <<NSZ_COMPANY>> NSZ " +; 
              "  WHERE NSZ.D_E_L_E_T_ = ' ' " +;
              "    <<AND_XFILIAL_NSZ_FILIAL>>"
 Return cQuery
