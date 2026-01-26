#IFDEF SPANISH
	  #define STR0001 "¡Cliente no encontrado!"
	  #define STR0002 "Aviso"
	  #define STR0003 "¡RFC de Cliente no encontrado!"
#ELSE
   #IFDEF ENGLISH
      #define STR0001 "Customer not found!"
      #define STR0002 "Warning"
      #define STR0003 "CNPJ/CPF of Customer not found!"
   #ELSE
      #define STR0001 "Cliente nao encontrado!"
      #define STR0002 "Aviso"
      #define STR0003 "CNPJ/CPF de Cliente nao encontrado!" 
   #ENDIF
#ENDIF
