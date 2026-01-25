#INCLUDE "loca055.ch" 
#INCLUDE "PROTHEUS.CH"                                                                                                                     
#INCLUDE "RWMAKE.CH"

/*/{PROTHEUS.DOC} LOCA055.PRW
ITUP BUSINESS - TOTVS RENTAL
ATIVAÇÃO DO CADASTRO DE FUNCIONÁRIOS PARA O TIME SHEET
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.  
/*/

FUNCTION LOCA055()
LOCAL   _AAREA64  := GETAREA() 
PRIVATE ACORES    := {{'RA_TSHEET=="S"' , "BR_VERDE"   } , ;
				      {'RA_TSHEET<>"S"' , "BR_VERMELHO"} } 
PRIVATE CCADASTRO := STR0001 //"CAMPOS PARA O TIME SHEET"
PRIVATE AROTINA   := {}
PRIVATE ACAMPOS   := {{STR0006  , "RA_MAT    "  , ""} , ; //"CODIGO   "
	           		  {STR0007  , "RA_NOME   "  , ""} , ; //"NOME     "
		              {STR0008  , "RA_CODFUNC"  , ""} , ; //"FUNÇÃO   "
		              {STR0009  , "RA_TSHEET "  , ""} , ; //"LOCAÇÃO? "
        		      {STR0011  , "RA_FOLGA  "  , ""} } //, ; //"FOLGA?   "

	aRotina := menudef(aRotina)

	DBSELECTAREA("SRA")
	DBSETORDER(1)

	MBROWSE(6,1,22,75,"SRA",ACAMPOS,,,,,ACORES)

	RESTAREA(_AAREA64)

RETURN  



// ======================================================================= \\
FUNCTION LOCA05501()
// ======================================================================= \\
// --> CHAMADA: MENU - "LEGENDA"

	BRWLEGENDA(CCADASTRO,STR0012,{{"BR_VERDE"	   , STR0013    },; //"LEGENDA"###"CONTROLA LOCAÇÃO"
                                {"BR_VERMELHO" , STR0014}})  //"NÃO CONTROLA LOCAÇÃO"

RETURN .T.



// ======================================================================= \\
FUNCTION LOCA05502(POPC)
// ======================================================================= \\
// --> CHAMADA: MENU - "VISUALIZAR" (2)  &  "ALTERAR" (4) 
LOCAL _NOPC			:= POPC
LOCAL _CUSER		:= RETCODUSR(SUBS(CUSUARIO,7,15))  //RETORNA O CÓDIGO DO USUÁRIO
LOCAL _LALTERA		:= IIF(_NOPC==4,.T.,.F.)
LOCAL APARAMBOX     := {}
LOCAL ARET 		    := {} 

PRIVATE LCANCEL     := .F.
PRIVATE _CFILMAT	:= SRA->RA_FILIAL
PRIVATE _CMAT		:= SRA->RA_MAT
PRIVATE _CNOME		:= SRA->RA_NOME
PRIVATE _CCODFUNC	:= SRA->RA_CODFUNC
//PRIVATE _CDESFUNC	:= POSICIONE("SRJ" , 1 , SRA->RA_FILIAL+SRA->RA_CODFUNC , "RJ_DESC") 
PRIVATE _CDESFUNC	:= POSICIONE("SRJ" , 1 , FwxFilial("SRJ")+SRA->RA_CODFUNC , "RJ_DESC") //ifranzoi - 08/07/2021
PRIVATE _NINI       := IIF(SRA->RA_TSHEET == "S" , 1 , 2) 
PRIVATE _CTSHEET	:= SRA->RA_TSHEET
//PRIVATE _NDSHEET	:= SRA->RA_DSHEET
PRIVATE _NDSHEET	:= 0 // 06/10/2022 - Jose Eulalio - Retirada do campo customizado RA_DSHEET
PRIVATE _CFOLGA		:= SRA->RA_FOLGA
PRIVATE _CVT		:= 0 // removido da 94 SRA->RA_VT

	_CCC 		:= LOCA004CC(_CUSER,"LOCA053")
	_CTPSERV 	:= LOCA004CC(_CUSER,"LOCT053B")

	IF ALLTRIM(SRA->RA_CC) $ _CCC .OR. "ALL" $ UPPER(ALLTRIM(_CCC+_CTPSERV))
		AADD(APARAMBOX,{1,STR0015           , _CFILMAT  , "@!", "", "", ".F.", 50, .T.}) 			// TIPO CARACTERE //"FILIAL"
		AADD(APARAMBOX,{1,STR0016        , _CMAT     , "@!", "", "", ".F.", 50, .T.}) 			// TIPO CARACTERE //"MATRÍCULA"
		AADD(APARAMBOX,{1,STR0017             , _CNOME    , "@!", "", "", ".F.", 80, .T.}) 			// TIPO CARACTERE //"NOME"
		AADD(APARAMBOX,{1,STR0018      , _CCODFUNC , "@!", "", "", ".F.", 50, .T.}) 			// TIPO CARACTERE //"COD. FUNÇÃO"
		AADD(APARAMBOX,{1,STR0019     , _CDESFUNC , "@!", "", "", ".F.", 80, .T.}) 			// TIPO CARACTERE //"DESC. FUNÇÃO"
		AADD(APARAMBOX,{2,STR0013 , _NINI     , {STR0020,STR0021} , 40 , "_LALTERA" , .T.}) 	// COMBO  //"CONTROLA LOCAÇÃO"###"SIM"###"NÃO"
			
		IF PARAMBOX(APARAMBOX,STR0022,@ARET,,,,,,,,.F.)  //"PARÂMETROS"
			IF VALTYPE(ARET[6]) == "C"
				IF     ALLTRIM(UPPER(ARET[6])) == STR0020 //"SIM"
					ARET[6] := "S"
				ELSEIF ALLTRIM(UPPER(ARET[6])) == STR0021 //"NÃO"
					ARET[6] := "N"
				ENDIF
			ELSEIF VALTYPE(ARET[6]) == "N"
				IF     ARET[6] == 1
					ARET[6] := "S"
				ELSEIF ARET[6] == 2
					ARET[6] := "N"
				ENDIF
			ENDIF   
			IF _LALTERA
				SRA->(DBSETORDER(1))
				IF SRA->(DBSEEK( ARET[1] + ARET[2] ))
					SRA->(RECLOCK("SRA",.F.))
					SRA->RA_TSHEET := ARET[6]
					SRA->(MSUNLOCK()) 
				ENDIF 
			ENDIF 
		ENDIF 
	ELSE
		MSGALERT(STR0023 + ALLTRIM(_CCC) + STR0024 + ALLTRIM(_CTPSERV) + ".",STR0025)  //"ATENÇÃO: VOCÊ NÃO TEM ACESSO A ESTE FUNCIONÁRIO. VOCÊ POSSUI ACESSO AOS CENTROS DE CUSTO "###", E AOS SEGMENTOS "###"GPO - LOCT064.PRW"
	ENDIF

RETURN

// Rotina para montagem do arotina
// Frank Fuga em 21/11/23 - card 1291
Static Function menudef(aRotina)
	AROTINA := {{STR0002 , "AXPESQUI   " , 0 , 1} , ; //"PESQUISAR "
	{STR0003 , "LOCA05502(2)" , 0 , 2} , ; //"VISUALIZAR"
	{STR0004 , "LOCA05502(4)" , 0 , 3} , ; //"ALTERAR   "
	{STR0005 , "LOCA05501()" , 0 , 4} } //"LEGENDA   "
Return aRotina
