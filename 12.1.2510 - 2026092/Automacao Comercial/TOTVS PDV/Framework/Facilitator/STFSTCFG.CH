#Define _FATHER_NODE 1
#Define _CODE_NODE 2
#Define _DESCRIPTION_NODE 3
#Define _ORDER_NODE 4
#Define _ENVIRONMENT_NODE 5
#Define _VALID_NODE 6
#Define _EDITED_NODE 7
#Define _VALID_FUNCTION 8 
#Define _IS_FATHER 9
#Define _PREDECESSOR_NODE 10
#Define _RECORD_TABLE_ONCE 11 //Grava todos os campos da tabela uma vez   
#Define _INSERT_TABLE 12 //Insere o registro de uma tabela, caso o registro ainda não exista
#Define _COMPS_NODE 15 ////COMPONENTES DO NÓ  - NO CASO DE SER UM PAI 
#Define _POS_RECORDED 13   //Função a ser executada após a gravação do nó 
#Define _WRITE_FUNCTION 14 //Função de gravação
#Define _COMP_NODE	01  
#Define _COMP_ID 02 
#Define _COMP_ENVIRONMENT 03
#Define _COMP_TYPE  04
#Define _COMP_NAME 05
#Define _COMP_TITLE 06
#Define _COMP_F3 07
#Define _COMP_DEFAULT 08
#Define _COMP_TABLE_FILE 09  //NOME DA TABELA OU ARQUIVIO CONFIG
#Define _COMP_INDEX 10
#Define _COMP_KEY 11   //SE FOI CAMPO DÁ UM EVAL 
#Define _COMP_INITYPE 12  
#Define _COMP_VALID 13 //EXPRESSO DE VALIDAÇÃO
#Define _COMP_LEN 14 // Tamanho do componente  -      
#Define _COMP_LIST 15 // lISTA DE vALORES   // 
#Define _COMP_FIELD_TYPE 16//   - TIPO DE CAMPO // Default C
#Define _COMP_CTRL_TYPE 17 //   - Tipo de CONTROLE // Default MsGet ("G") // M - Memo //L List  
#Define _COMP_OLDVALUE 18     // - Valor antigo do controle no caso de rollback dos dados
#Define _COMP_POSICA 19 	//Picture do campo 
#Define _COMP_OBJECT  20	  // - objeto do controle   
#Define _TOTAL_NODES  Len(aData)	      //TOTAL DOS NÓS  
#Define _TOTAL_CAMPOS 18 //TOTAL DE CAMPOS 
#Define _CAMPO  "1"
#Define _PARAMETRO "2"
#Define _ARQUIVO_INI "3"
#Define _ROTINA "4"