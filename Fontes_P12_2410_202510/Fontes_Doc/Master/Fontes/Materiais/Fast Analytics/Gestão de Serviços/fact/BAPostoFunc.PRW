#INCLUDE "BADEFINITION.CH"

NEW ENTITY POSTOFUNC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAPostoFunc
Visualiza as informacoes de Posto X Funcionarios.

@author  Andreia Lima
@since   22/03/2018
/*/
//-------------------------------------------------------------------
Class BAPostoFunc from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Andreia Lima
@since   22/03/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAPostoFunc
	_Super:Setup("PostoFuncionario", FACT, "ABB")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna a consulta da entidade por empresa.

@author  Andreia Lima
@since   22/03/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAPostoFunc
	Local cQuery := ""
	
	cQuery := "SELECT DISTINCT "+;
              " <<KEY_COMPANY>> AS BK_EMPRESA,"+; 
              " <<KEY_FILIAL_ABB_FILIAL>> AS BK_FILIAL,"+;
              " <<KEY_AA1_AA1_FILIAL+ABB_CODTEC>> AS BK_ATENDENTE,"+;
              " <<KEY_TFF_TFF_FILIAL+TFF_COD>> AS BK_RH_ORCAMENTO,"+;
              " <<KEY_ABS_ABS_FILIAL+TFF_LOCAL>> AS BK_LOCAL_ATENDIMENTO,"+;
              " <<KEY_AD1_AD1_FILIAL+AD1_NROPOR>> AS BK_OPORTUNIDADE,"+;
              " <<KEY_ADY_ADY_FILIAL+ADY_PROPOS+ADY_PREVIS>> BK_PROPOSTA,"+;
              " <<KEY_CN9_CN9_FILIAL+CN9_NUMERO+CN9_REVISA>> AS BK_CONTRATO,"+;
              " <<KEY_SB1_B1_FILIAL+TFF_PRODUT>> AS BK_ITEM,"+;
              " <<KEY_SQ3_Q3_FILIAL+TFF_CARGO>> AS BK_CARGO,"+;
              " <<KEY_SR6_R6_FILIAL+TFF_TURNO>> AS BK_TURNO,"+;
              " <<KEY_TDW_TDW_FILIAL+TFF_ESCALA>> AS BK_ESCALA,"+;
              " <<KEY_AC0_AC0_FILIAL+TFF_CALEND>> AS BK_CALENDARIO,"+;
              " CN9_NUMERO,"+;
              " '1' AS QUANT,"+;
              " ABB_DTINI AS DATA_INICIO,"+;
              " ABB_DTFIM AS DATA_FIM,"+;
              " ABB_HRINI AS HORA_INICIO,"+;
              " ABB_HRFIM AS HORA_FIM,"+;
              " <<DATEDIFF(DD, ABB_DTINI, ABB_DTFIM)>> AS QUANTIDADE_DIAS, "+; 
              " <<CODE_INSTANCE>> AS INSTANCIA " + ;
              "  FROM <<ABB_COMPANY>> ABB "+;      //Agenda de atendentes
              " INNER JOIN <<AA1_COMPANY>> AA1 "+; //Atendentes
              "    ON AA1_CODTEC = ABB_CODTEC "+;
              "   AND AA1_FILIAL = <<SUBSTR_AA1_ABB_FILIAL>> "+;
              "   AND AA1.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<ABQ_COMPANY>> ABQ "+; //Conferencia de alocacao de recursos
              "    ON (ABQ_CONTRT || ABQ_ITEM || ABQ_ORIGEM) = ABB_IDCFAL "+; 
              "   AND ABQ_FILIAL = <<SUBSTR_ABQ_ABB_FILIAL>> "+;   
              "   AND ABQ.D_E_L_E_T_ = ' ' "+;
              " INNER JOIN <<TFF_COMPANY>> TFF "+; //Recursos Humanos
              "    ON TFF_COD = ABQ_CODTFF "+; 
              "   AND TFF_CONTRT = ABQ_CONTRT "+;
              "   AND TFF_FILIAL = <<SUBSTR_TFF_ABQ_FILTFF>> "+;
              "   AND TFF.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<TFL_COMPANY>> TFL "+; //Orcamento de servicos x proposta
              "    ON TFL_CODIGO = TFF_CODPAI "+;
              "   AND TFL_FILIAL = <<SUBSTR_TFL_TFF_FILIAL>> "+; 
              "   AND TFL.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<TFJ_COMPANY>> TFJ "+; //Orcamento de servicos
              "    ON TFJ_CODIGO = TFL_CODPAI "+; 
              "   AND TFJ_FILIAL = <<SUBSTR_TFJ_TFL_FILIAL>> "+;
              "   AND TFJ.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<ADY_COMPANY>> ADY "+; //Proposta comercial
              "    ON ADY_PROPOS = TFJ_PROPOS "+;
              "   AND ADY_PREVIS = TFJ_PREVIS "+;
              "   AND ADY_FILIAL = <<SUBSTR_ADY_TFJ_FILIAL>> "+;
              "   AND ADY.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<AD1_COMPANY>> AD1 "+; //Oportunidade de venda
              "    ON AD1_NROPOR = ADY_OPORTU "+; 
              "   AND AD1_FILIAL = <<SUBSTR_AD1_ADY_FILIAL>> "+; 
              "   AND AD1.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<ABS_COMPANY>> ABS "+; //Locais de atendimento
              "    ON ABS_LOCAL = TFF_LOCAL "+;
              "   AND ABS_FILIAL = <<SUBSTR_ABS_TFF_FILIAL>> "+;
              "   AND ABS.D_E_L_E_T_ = ' ' "+;    
              " INNER JOIN <<SB1_COMPANY>> SB1 "+; //Produto\Item 
              "    ON B1_COD = TFF_PRODUT "+;
              "   AND B1_FILIAL = <<SUBSTR_SB1_TFF_FILIAL>> "+; 
              "   AND SB1.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<CN9_COMPANY>> CN9 "+; //Contratos
              "    ON CN9_NUMERO = TFJ_CONTRT "+; 
              "   AND CN9_REVISA = TFJ_CONREV "+; 
              "   AND CN9_FILIAL = <<SUBSTR_CN9_TFJ_FILIAL>> "+;
              "   AND CN9_REVATU = ' ' "+; 
              "   AND CN9.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<SRJ_COMPANY>> SRJP "+; //Funcoes
              "    ON SRJP.RJ_FUNCAO = TFF_FUNCAO "+;
              "   AND SRJP.RJ_FILIAL = <<ALIAS_SRJP>><<SUBSTR_SRJ_TFF_FILIAL>> "+;
              "   AND SRJP.D_E_L_E_T_ = ' ' "+; 
              " INNER JOIN <<SRJ_COMPANY>> SRJF "+; //Funcoes
              "    ON SRJF.RJ_FUNCAO = AA1_FUNCAO "+; 
              "   AND SRJF.RJ_FILIAL = <<ALIAS_SRJF>><<SUBSTR_SRJ_AA1_FILIAL>> "+; 
              "   AND SRJF.D_E_L_E_T_ = ' ' "+; 
              "  LEFT JOIN <<SQ3_COMPANY>> SQ3 "+;  //Cargos
              "    ON Q3_CARGO = TFF_CARGO "+; 
              "   AND Q3_FILIAL = <<SUBSTR_SQ3_TFF_FILIAL>> "+; 
              "   AND SQ3.D_E_L_E_T_ = ' ' "+; 
              "  LEFT JOIN <<TDW_COMPANY>> TDW "+;  //Escala
              "    ON TDW_COD = TFF_ESCALA "+; 
              "   AND TDW_FILIAL = <<SUBSTR_TDW_TFF_FILIAL>> "+; 
              "   AND TDW.D_E_L_E_T_ = ' ' "+; 
              "  LEFT JOIN <<AC0_COMPANY>> AC0 "+;  //Cadastro de feriado
              "    ON AC0_CODIGO = TFF_CALEND "+; 
              "   AND AC0_FILIAL = <<SUBSTR_AC0_TFF_FILIAL>> "+; 
              "   AND AC0.D_E_L_E_T_ = ' ' "+; 
              "  LEFT JOIN <<SR6_COMPANY>> SR6 "+;  //Turnos de trabalho
              "    ON R6_TURNO = TFF_TURNO "+; 
              "   AND R6_FILIAL = <<SUBSTR_SR6_TFF_FILIAL>> "+; 
              "   AND SR6.D_E_L_E_T_ = ' ' "+; 
              " WHERE ABB_ATIVO = '1' "+;
              "   AND ABB_DTINI BETWEEN <<START_DATE>> AND <<FINAL_DATE>> " + ;
              "   AND ABB.D_E_L_E_T_ = ' ' " +;
              "   <<AND_XFILIAL_ABB_FILIAL>>"
Return cQuery	