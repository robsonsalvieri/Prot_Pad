#INCLUDE "BADEFINITION.CH"

NEW ENTITY PROCESSO

//-------------------------------------------------------------------
/*/{Protheus.doc} BAProcesso
Visualiza as informacoes dos Processos da area Juridica.

@author  Andreia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Class BAProcesso from BAEntity
	Method Setup( ) CONSTRUCTOR
	Method BuildQuery( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Setup
Construtor padrao.

@author  Andreia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method Setup( ) Class BAProcesso
	_Super:Setup("Processos", DIMENSION, "NSZ")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQuery
Constroi a query da entidade.

@return aQuery, array, Retorna as consultas da entidade por empresa.

@author  Andreia Lima
@since   23/02/2018
/*/
//-------------------------------------------------------------------
Method BuildQuery( ) Class BAProcesso
	Local cQuery := ""
	
	cQuery := " SELECT <<KEY_COMPANY>> AS BK_EMPRESA, "                                     +;
       		  "        <<KEY_FILIAL_NSZ_FILIAL>> AS BK_FILIAL, "                            +;
              "        <<KEY_SA1_A1_FILIAL+NSZ_CCLIEN+NSZ_LCLIEN>> AS BK_CLIENTE, "         +; //Cliente
              "        <<KEY_SA2_A2_FILIAL+NUQ_CCORRE+NUQ_LCORRE>> AS BK_CREDENCIADO, "     +; //Credenciado
   			  "        <<KEY_NQQ_NQQ_FILIAL+NUQ_CDECIS>> AS BK_DECISAO, "                   +; //Decisao
   			  "        <<KEY_NQU_NQU_FILIAL+NUQ_CTIPAC>> AS BK_TIPO_ACAO, "                 +; //Tipo de acao
              "        <<KEY_NQ6_NQ6_FILIAL+NUQ_CCOMAR>> AS BK_COMARCA, "                   +; //Comarca
              "        <<KEY_NQC_NQC_FILIAL+NUQ_CLOC2N>> AS BK_FORO_TRIBUNAL, "             +; //Foro\Tribunal
              "        <<KEY_NQE_NQE_FILIAL+NUQ_CLOC3N>> AS BK_VARA_CAMARA, "               +; //Vara\Camara
              "        <<KEY_SQ3_Q3_FILIAL+NT9_CCRGDP>> AS BK_CARGO, "                      +; //Cargo Parte Contraria
              "        <<KEY_SRJ_RJ_FILIAL+NT9_CFUNDP>> AS BK_FUNCAO, "                     +; //Funcao Parte Contraria
              "        <<KEY_NS7_NS7_FILIAL+NT9_CLTDP>> AS BK_LOCAL_TRABALHO, "             +; //Local de Trabalho Parte Contr�ria
              "        <<KEY_NSZ_NSZ_FILIAL+NSZ_COD>> AS BK_PROCESSO_JUR, "                 +; //Codigo Interno
			  "        <<KEY_NRB_NRB_FILIAL+NSZ_CAREAJ>> AS BK_AREA_JURIDICA, "             +; //area juridica
			  "        <<KEY_NYB_NYB_FILIAL+NSZ_TIPOAS>> AS BK_ASSUNTO_JURIDICO, "          +; //assunto juridico
			  "        <<KEY_NQ4_NQ4_FILIAL+NSZ_COBJET>> AS BK_OBJETO_JURIDICO, "           +; //objeto juridico
              "        NSZ_NUMCAS AS NUMCASO, "                                             +; //Numero do caso
              "        NSZ_USUENC AS USUENCERRAMENTO, "                                     +; //Usuario encerramento
              "        NSZ_SITUAC AS STATUSPROCESSO, "                                      +; //Status Processo
              "        NSZ_DTENCE AS DTENCERRAMENTO, "                                      +; //Data de encerramento
              "        NUQ_DTDIST AS DTDISTRIBUICAO, "                                      +; //Data Distribuicao
              "        NUQ_DTDECI AS DTDECISAO, "                                           +; //Data Decisao
              "        NT9_CODENT AS CODENTIDADE, "                                         +; //Parte Contraria
              "        NUQ_NUMPRO AS NUMPRO, "                                              +; //Numero do Processo
              "        TRIM(NSZ_PATIVO ) + '/' + TRIM(NSZ_PPASSI) AS ENVOLVIDOSPRINCIPAL, "  +; //Envolvidos Principais
              "        <<CODE_INSTANCE>> AS INSTANCIA, " +;
              "        <<KEY_MOEDA_NSZ_CMOCAU>> AS BK_MOEDA " +;
              "   FROM <<NSZ_COMPANY>> NSZ " +; 
              "   LEFT JOIN <<SA1_COMPANY>> SA1 " +; //Cliente
              "     ON A1_COD = NSZ_CCLIEN " +;
              "    AND A1_LOJA = NSZ_LCLIEN " +;
              "    AND A1_FILIAL = <<SUBSTR_SA1_NSZ_FILIAL>> " +;
              "    AND SA1.D_E_L_E_T_ = ' ' " +;          
              "   LEFT JOIN <<NRB_COMPANY>> NRB " + ; 
              "     ON (NRB_FILIAL = <<SUBSTR_NRB_NSZ_FILIAL>> " + ;
              "    AND NRB_COD = NSZ_CAREAJ " + ;
              "    AND NRB.D_E_L_E_T_ = ' ' ) " + ; 
              "   LEFT JOIN <<NYB_COMPANY>> NYB " + ; 
              "     ON (NYB_FILIAL = <<SUBSTR_NYB_NSZ_FILIAL>> " + ;
              "    AND NYB_COD = NSZ_TIPOAS " + ;
              "    AND NYB.D_E_L_E_T_ = ' ' ) " + ; 
              "   LEFT JOIN <<NUQ_COMPANY>> NUQ " +; //Instancia
              "     ON NUQ_CAJURI = NSZ_COD " +; 
              "    AND NUQ_FILIAL = <<SUBSTR_NUQ_NSZ_FILIAL>> " +; 
              "    AND NUQ_INSATU = '1' " +;  
              "    AND NUQ.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<SA2_COMPANY>> SA2 " +; //Credenciado 
              "     ON A2_FILIAL = <<SUBSTR_SA2_NSZ_FILIAL>> " +;
              "    AND A2_COD = NUQ_CCORRE " +;
              "    AND A2_LOJA = NUQ_LCORRE " +; 
              "    AND A2_MJURIDI = '1' " +;
              "    AND SA2.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<NQQ_COMPANY>> NQQ " +; //Decisao
              "     ON NQQ_COD = NUQ_CDECIS " +;
              "    AND NQQ_FILIAL = <<SUBSTR_NQQ_NSZ_FILIAL>> " +;
              "    AND NQQ.D_E_L_E_T_ = ' ' " +;  
              "   LEFT JOIN <<NQU_COMPANY>> NQU " +; //Tipo de acao
              "     ON NQU_COD = NUQ_CTIPAC " +;
              "    AND NQU_FILIAL = <<SUBSTR_NQU_NSZ_FILIAL>> " +;
              "    AND NQU.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<NQ6_COMPANY>> NQ6 " +; //Comarca 
              "     ON NQ6_COD = NUQ_CTIPAC " +;
              "    AND NQ6_FILIAL = <<SUBSTR_NQ6_NSZ_FILIAL>> " +;
              "    AND NQ6.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<NQ4_COMPANY>> NQ4 " +; //objeto juridico
              "     ON NQ4_COD = NSZ_COBJET " +;
              "    AND NQ4_FILIAL = <<SUBSTR_NQ4_NSZ_FILIAL>> " +;
              "    AND NQ4.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<NQC_COMPANY>> NQC " +; //Foro\Tribunal
              "     ON NQC_COD = NUQ_CLOC2N " +;
              "    AND NQC_INSTAN = NUQ_INSATU " +;
              "    AND NQC_FILIAL = <<SUBSTR_NQC_NSZ_FILIAL>> " +;
              "    AND NQC.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<NQE_COMPANY>> NQE " +; //Vara
              "     ON NQE_COD = NUQ_CLOC3N " +; 
              "    AND NQE_FILIAL = <<SUBSTR_NQE_NSZ_FILIAL>> " +;
              "    AND NQE.D_E_L_E_T_ = ' ' " +; 
              "   LEFT JOIN <<NT9_COMPANY>> NT9 " +; //Envolvidos 
              "     ON NT9_CAJURI = NSZ_COD " +; 
              "    AND NT9_FILIAL = <<SUBSTR_NT9_NSZ_FILIAL>> " +;  
              "    AND NT9_TIPOCL = '2' " +; 
              "    AND NT9_PRINCI = '1' " +; 
              "    AND (NT9_TIPOEN = '1' OR NT9_TIPOEN = '2') " +; 
              "    AND NT9.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<SQ3_COMPANY>> SQ3 " +; //Cargo
              "     ON Q3_CARGO = NT9_CCRGDP " +;
              "    AND Q3_FILIAL = <<SUBSTR_SQ3_NSZ_FILIAL>> " +;
              "    AND SQ3.D_E_L_E_T_ = ' ' " +;
              "   LEFT JOIN <<SRJ_COMPANY>> SRJ " +; //Funcao 
              "     ON RJ_FUNCAO = NT9_CFUNDP " +;
              "    AND RJ_FILIAL = <<SUBSTR_SRJ_NSZ_FILIAL>> " +;
              "    AND SRJ.D_E_L_E_T_ = ' ' " +; 
              "   LEFT JOIN <<NS7_COMPANY>> NS7 " +; //Local de trabalho
              "     ON NS7_COD = NT9_CLTDP " +;
              "    AND NS7_FILIAL = <<SUBSTR_NS7_NSZ_FILIAL>> " +;
              "    AND NS7.D_E_L_E_T_ = ' ' " +;  
              "  WHERE NSZ.D_E_L_E_T_ = ' ' " +;
              "    <<AND_XFILIAL_NSZ_FILIAL>>"
 Return cQuery
