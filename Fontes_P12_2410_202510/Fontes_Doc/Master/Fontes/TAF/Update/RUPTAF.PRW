#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/* ******************************************** ATENÇÃO ********************************************

SEMPRE QUE HOUVER MANUTENÇÃO NO RUP_TAF, DEVE SER AVALIADO A NECESSIDADE DE ADAPTAR O PROGRAMA
UPDTAF.PRW, POIS EXISTE DEPENDENCIA ENTRE OS FONTES. PONTOS QUE DEVEM SER AVALIADOS:
	-> Ao criar nova função no RUP_TAF, esta deve ser informada no array aFuncSx do UPDTAF
	-> As funções do RUP_TAF devem ser todas STATIC, pois o UPDTAF faz a chamada através de STATICCALL
	-> Todo release que houver mudança no RUP_TAF, a função checkEnvUpddistr() no UPDTAF deve ser revisada
	pois ela possui as regras que informam ao usuário a necessidade de aplicação do UPDDISTR dos pacotes
	segregados do TAF ( pacotes gerados sem marca e expedidos independentemente do release incremental )

************************************************ ATENÇÃO ********************************************  */

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_TAF

Esta rotina tem como objetivo realizar a criação do RUP do TAF, ou seja, manutenir as informações
de dicionário de dados que não são contempladas no UPDDISTR

@Param  cVersion   = Versão do Protheus. Ex. '12'
		cMode      = Modo de Execução
		cRelStart  = Release Corrente do Cliente
		cRelFinish = Release que está sendo aplicada
		cLocaliz   = Pais do Dicionário

@Author  Rodrigo Aguilar
@Since   09/04/2015
@Version 1.0

@Return ( Nil )
 
/*/
//--------------------------------------------------------------------------------------------------
Function RUP_TAF( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local lDicInDB 	:= MPDicInDB()
		
	//Execução por Grupo de Empresas
	If cMode == "1"
		//Realiza a chamada da função refente aos campos ( SX3 )
		FAtuTafSX3( cRelStart, cRelFinish,lDicInDB )

		//Realiza a chamada da função refente aos Parâmetros ( SX6 )
		FAtuTAFSX6( cRelStart, cRelFinish, lDicInDB )

		//Realiza a chamada da função refente aos gatilhos ( SX7 )
		FAtuTafSX7( cRelStart, cRelFinish,lDicInDB )

		//Realiza a chamada da função refente as pastas e agrupamentos de campos ( SXA )
		FAtuTafSXA( cRelStart, cRelFinish,lDicInDB )
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX3

Realiza a atualização do dicionário de dados SX3( Campos )

@Param	  cRelStart  - Versão do Release origem Ex: 033
@Param	  cRelFinish - Versão do Release destino Ex: 2210
@Param	  lDicInDB   - .T. Se dicionario no banco
@Param	  lUPDTAF    - Se for chamado pelo UPDTAF
@Param	  cRelease   - Versão do Release selecionado no UPDTAF Ex: 2210
@Param	  aUpdTask   - Array com o log de atualizações do UPDTAF

@Return	( Nil )

@Author Felipe C. Seolin
@Since 11/06/2015
@Version 1.0
/*/
//---------------------------------------------------------------------
Function FAtuTafSX3( cRelStart, cRelFinish, lDicInDB, lUPDTAF, cRelease, aUpdTask )

	Local aAreaSX3	as array
	Local aBrwN		as array
	Local aBrwS		as array
	Local aVisA	    as array
	Local aVisV		as array
	Local aTrigg	as array
	Local nI		as numeric
	Local cQuery	as character
	
	Default cRelStart   :=  ""
	Default cRelFinish  :=  ""
	Default lDicInDB 	:=  .F.
	Default lUPDTAF     :=  .F.
	Default cRelease    :=  ""
	Default aUpdTask    :=  {}

	aAreaSX3	:=	SX3->( GetArea() )
	aBrwN		:= {}
	aBrwS		:= {}
	aVisA		:= {}
	aVisV		:= {}
	aTrigg		:= {}
	nI			:= 0
	cQuery		:= ""

	SX3->( DBSetOrder( 2 ) )

	If ( !lUPDTAF .and. cRelStart < "033" .and. cRelFinish >= "033" ) .or. ( lUPDTAF .and. cRelease == "033" )

		If SX3->( MsSeek( "CM6_CODCID" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_CODCID") //Array para adicionar todo browse = N
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			Endif
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_CODCID' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DCODCID" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_DCODCID")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )				
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DCODCID' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DIASAF" ) )
			If lDicInDB 
				aAdd(aBrwN,"CM6_DIASAF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DIASAF' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_IDPROF" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_IDPROF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_IDPROF' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DIDPRO" ) )
			If lDicInDB 
				AAdd(aBrwN,"CM6_DIDPRO")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )				
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DIDPRO' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_STATUS" ) )
			If lDicInDB 
				aAdd(aBrwN,"CM6_STATUS")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )				
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_STATUS' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_FMOTAF" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_FMOTAF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_FMOTAF' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DFMOTA" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_DFMOTA")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )				
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DFMOTA' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_OBSFIM" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_OBSFIM")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_OBSFIM' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_STAFIM" ) )
			If lDicInDB
				aAdd(aBrwN,"CM6_STAFIM")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )			
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_STAFIM' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "CM6_DFUNC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"S"
				SX3->X3_INIBRW	:=	'Posicione("C9V",1,xFilial("C9V",CM6->CM6_FILIAL)+CM6->CM6_FUNC,"C9V_NOME")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DFUNC' , "X3_BROWSE" , "S"  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CM6_DFUNC' , "X3_INIBRW" , 'Posicione("C9V",1,xFilial("C9V",CM6->CM6_FILIAL)+CM6->CM6_FUNC,"C9V_NOME")' } )
		EndIf

		If SX3->( MsSeek( "T1V_NIS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T1V_NIS' , "X3_VISUAL" , "A"  } )			
		EndIf

		If SX3->( MsSeek( "T1U_NIS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T1U_NIS' , "X3_VISUAL" , "A"  } )						
		EndIf

		If SX3->( MsSeek( "CMF_NRPROC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := ""
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMF_NRPROC", "X3_F3", "REMOVIDO" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMF_NRPROC", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CMF_NRLEIJ" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_CBOX := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CMF_NRLEIJ' , "X3_CBOX", ''  } )
		EndIf

		If SX3->( MsSeek( "CUP_DNPRJE" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := 'Iif(!INCLUI,Posicione("C1G",8,xFilial("C1G")+CUP->CUP_NPROJE+"1","C1G_TPPROC+' + "'"  + ' - ' + "'" + '+C1G_NUMPRO"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt, "SX3", 'CUP_DNPRJE', "X3_RELACAO", 'Iif(!INCLUI,Posicione("C1G",8,xFilial("C1G")+CUP->CUP_NPROJE+"1","C1G_TPPROC+' + "'"  + ' - ' + "'" + '+C1G_NUMPRO"),"")' } )
		EndIf

		If SX3->( MsSeek( "CUP_MOTCON" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Hipot. Legal"
				SX3->X3_DESCRIC	:=	"Hipotese Legal Contrat."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_MOTCON' , "X3_TITULO"  , "Hipot. Legal"  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_MOTCON' , "X3_DESCRIC" , "Hipotese Legal Contrat."  } )
		EndIf

		If SX3->( MsSeek( "CUP_TPINTT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Tp.Insc.Est."
				SX3->X3_DESCRIC	:=	"Tipo Insc. Estab. Vincul."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_TPINTT' , "X3_TITULO"  , "Tp.Insc.Est."  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_TPINTT' , "X3_DESCRIC" , "Tipo Insc. Estab. Vincul."  } )
		EndIf

		If SX3->( MsSeek( "CUP_NRINTT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Nr.Insc.Est."
				SX3->X3_DESCRIC	:=	"Núm. Inscr. Estab. Vincul"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_NRINTT' , "X3_TITULO"  , "Nr.Insc.Est."  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUP_NRINTT' , "X3_DESCRIC" , "Núm. Inscr. Estab. Vincul"  } )
		EndIf

		If SX3->( MsSeek( "T0X_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'TafGeraID("TAF")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0X_ID' , "X3_RELACAO" , 'TafGeraID("TAF")'  } )
		EndIf

		If SX3->( MsSeek( "CMK_DCODRU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'Iif(!INCLUI.and.!Empty(CMK->CMK_CODRUB),Posicione("C8R",1,xFilial("C8R")+CMK->CMK_CODRUB,"RTRIM(C8R_CODRUB)+' + "'"  + '–'   + "'" + '+C8R_DESRUB"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CMK_DCODRU' , "X3_RELACAO" , 'Iif(!INCLUI.and.!Empty(CMK->CMK_CODRUB),Posicione("C8R",1,xFilial("C8R")+CMK->CMK_CODRUB,"RTRIM(C8R_CODRUB)+' + "'"  + '–'   + "'" + '+C8R_DESRUB"),"")'  } )
		EndIf

		If SX3->( MsSeek(  "T71_CODIGO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL	:=	"A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T71_CODIGO' , "X3_VISUAL" , "A"  } )
		EndIf

		If SX3->( MsSeek(  "T71_DESCRI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL	:=	"A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T71_DESCRI' , "X3_VISUAL" , "A"  } )
		EndIf

		If SX3->( MsSeek(  "T71_CONV" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL	:=	"A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T71_CONV' , "X3_VISUAL" , "A"  } )
		EndIf

		If SX3->( MsSeek(  "C4X_DESIPM" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO :=	'IF(!INCLUI.AND.!EMPTY(C4X->C4X_CODIPM),POSICIONE("LF0",1,xFilial("LF0")+C4X->C4X_CODIPM,"LF0_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4X_DESIPM' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C4X->C4X_CODIPM),POSICIONE("LF0",1,xFilial("LF0")+C4X->C4X_CODIPM,"LF0_DESCRI"),"")'  } )
		EndIf

		If SX3->( MsSeek( "T20_QTDMOV" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"Qtd.Mov. Ori"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T20_QTDMOV' , "X3_TITULO" , "Qtd.Mov. Ori"  } )
		EndIf

		If SX3->( MsSeek( "C4I_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C4I->C4I_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C4I->C4I_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C4I_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C4I->C4I_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C4I->C4I_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C58_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C58->C58_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C58->C58_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C58_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C58->C58_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C58->C58_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C5M_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C5M->C5M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C5M->C5M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5M_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C5M->C5M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C5M->C5M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C6M_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C6M->C6M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C6M->C6M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C6M_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C6M->C6M_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C6M->C6M_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C7J_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C7J->C7J_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7J->C7J_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7J_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C7J->C7J_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7J->C7J_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C7K_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C7K->C7K_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7K->C7K_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C7K_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C7K->C7K_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C7K->C7K_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CA9_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CA9->CA9_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CA9->CA9_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CA9_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CA9->CA9_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CA9->CA9_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CAA_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CAA->CAA_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CAA->CAA_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAA_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CAA->CAA_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CAA->CAA_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CAD_DCTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CAD->CAD_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAD->CAD_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAD_DCTA' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CAD->CAD_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAD->CAD_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CAF_DCTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CAF->CAF_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAF->CAF_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CAF_DCTA' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CAF->CAF_CTA),POSICIONE("C1O",3,xFilial("C1O")+CAF->CAF_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CEQ_DCTA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CEQ->CEQ_CTA),POSICIONE("C1O",3,xFilial("C1O")+CEQ->CEQ_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CEQ_DCTA' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CEQ->CEQ_CTA),POSICIONE("C1O",3,xFilial("C1O")+CEQ->CEQ_CTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "CHB_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(CHB->CHB_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CHB->CHB_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CHB_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(CHB->CHB_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+CHB->CHB_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "C3B_DCODPA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+C3B->C3B_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_CODPAR' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+C3B->C3B_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")' } )
		EndIf

		If SX3->( MsSeek( "T31_NOME" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(T31->T31_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+T31->T31_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T31_CODPAR' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(T31->T31_CODPAR),POSICIONE("C1H",5,xFilial("C1H")+T31->T31_CODPAR,' + '"TRIM(C1H_CODPAR)+' + "' - '" + '+C1H_NOME"),"")' } )
		EndIf

		If SX3->( MsSeek( "C3B_DCODCT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C3B->C3B_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C3B_DCODCT' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(C3B->C3B_CODCTA),POSICIONE("C1O",3,xFilial("C1O")+C3B->C3B_CODCTA,' + '"TRIM(C1O_CODIGO)+' + "' - '" + '+C1O_DESCRI"),"")' } )
		EndIf

		//Reinf R-2030
		If SX3->( MsSeek( "C9B_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_FILIAL", "X3_PICTURE" , "@!" } )
		EndIf

		If SX3->( MsSeek( "C9B_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_RELACAO := 'TAFGeraID( "TAF" )'
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ID", "X3_RELACAO" , 'TAFGeraID( "TAF" )' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ID", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "C9B_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9B_INDAPU" ) )
			If lDicInDB
				aAdd(aBrwN,"C9B_INDAPU" )
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_INDAPU", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "C9B_PERAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Per Apuração"
				SX3->X3_DESCRIC := "Período de Apuração"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PERAPU", "X3_TITULO" , "Per Apuração" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PERAPU", "X3_DESCRIC" , "Período de Apuração" } )
		EndIf

		If SX3->( MsSeek( "C9B_VERANT" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Ant"
				SX3->X3_DESCRIC := "Id Versão Anterior Reg"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERANT", "X3_TITULO" , "Id Ver Ant" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_VERANT", "X3_DESCRIC" , "Id Versão Anterior Reg" } )
		EndIf

		If SX3->( MsSeek( "C9B_STATUS" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Status"
				SX3->X3_DESCRIC := "Status do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_STATUS", "X3_TITULO" , "Status" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_STATUS", "X3_DESCRIC" , "Status do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9B_PROTUL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo"
				SX3->X3_DESCRIC := "Recibo da Transmissão"
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTUL", "X3_TITULO" , "Recibo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTUL", "X3_DESCRIC" , "Recibo da Transmissão" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTUL", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "C9B_PROTPN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo Ant"
				SX3->X3_DESCRIC := "Recibo Trans Anterior"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTPN", "X3_TITULO" , "Recibo Ant" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_PROTPN", "X3_DESCRIC" , "Recibo Trans Anterior" } )
		EndIf

		If SX3->( MsSeek( "C9B_EVENTO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Evento"
				SX3->X3_DESCRIC := "Identificação do Evento"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_EVENTO", "X3_TITULO" , "Id Evento" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_EVENTO", "X3_DESCRIC" , "Identificação do Evento" } )
		EndIf

		If SX3->( MsSeek( "C9B_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Reg Ativo"
				SX3->X3_DESCRIC := "Registro Ativo"
				SX3->X3_PICTURE := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ATIVO", "X3_TITULO" , "Reg Ativo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ATIVO", "X3_DESCRIC" , "Registro Ativo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9B_ATIVO", "X3_PICTURE" , "" } )
		EndIf

		If SX3->(MsSeek("C9B_NRINSC"))
			If lDicInDB 
				aAdd(aBrwS,"C9B_NRINSC")
			ElseIf RecLock("SX3", .F.)
				SX3->X3_BROWSE := "S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", "C9B_NRINSC", "X3_BROWSE" , "S"})
		EndIf

		If SX3->( MsSeek( "C9G_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->X3_BROWSE := "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_FILIAL", "X3_PICTURE" , "@!" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_FILIAL", "X3_BROWSE" , "S" } )
		EndIf

		If SX3->( MsSeek( "C9G_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_ID", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9G_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9G_CNPJOR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "CNPJ Repasse"
				SX3->X3_DESCRIC := "CNPJ Emp Repasse Recursos"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_CNPJOR", "X3_TITULO" , "CNPJ Repasse" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_CNPJOR", "X3_DESCRIC" , "CNPJ Emp Repasse Recursos" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_CNPJOR", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9G_VLREPA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Vlr Brut Rec"
				SX3->X3_DESCRIC := "Valor Bruto Recebido"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VLREPA", "X3_TITULO" , "Vlr Brut Rec" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9G_VLREPA", "X3_DESCRIC" , "Valor Bruto Recebido" } )
		EndIf

		If SX3->( MsSeek( "C9H_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->X3_BROWSE := "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_FILIAL", "X3_PICTURE" , "@!" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_FILIAL", "X3_BROWSE" , "S" } )
		EndIf

		If SX3->( MsSeek( "C9H_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_ID", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9H_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9H_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		//Reinf R-2040
		If SX3->( MsSeek( "C9I_FILIAL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_PICTURE := "@!"
				SX3->X3_BROWSE := "S"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_FILIAL", "X3_PICTURE" , "@!" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_FILIAL", "X3_BROWSE" , "S" } )
		EndIf

		If SX3->( MsSeek( "C9I_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_ID", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9I_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VERSAO", "X3_TITULO" , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "C9I_CNPJAD" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "CNPJ Ass Des"
				SX3->X3_DESCRIC := "CNPJ Associação Desp"
				SX3->X3_VISUAL := "V"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_CNPJAD", "X3_TITULO" , "CNPJ Ass Des" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_CNPJAD", "X3_DESCRIC" , "CNPJ Associação Desp" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_CNPJAD", "X3_VISUAL" , "V" } )
		EndIf

		If SX3->( MsSeek( "C9I_VLREPA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Vlr Brut Rep"
				SX3->X3_DESCRIC := "Valor Bruto Repassado"
				SX3->X3_VISUAL := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VLREPA", "X3_TITULO" , "Vlr Brut Rep" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VLREPA", "X3_DESCRIC" , "Valor Bruto Repassado" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "C9I_VLREPA", "X3_VISUAL" , "A" } )
		EndIf

		//Reinf R-2020
		If SX3->( MsSeek( "CMN_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_DESCRIC := "Identificador do Registro"
				SX3->X3_RELACAO := 'TAFGeraID( "TAF" )'
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ID", "X3_DESCRIC" , "Identificador do Registro" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ID", "X3_RELACAO" , 'TAFGeraID( "TAF" )' } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ID", "X3_BROWSE" , "N" } )
		EndIf

		If SX3->( MsSeek( "CMN_VERSAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Id Ver Reg"
				SX3->X3_DESCRIC := "Id da Versão do Registro"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_VERSAO", "X3_TITULO"  , "Id Ver Reg" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_VERSAO", "X3_DESCRIC" , "Id da Versão do Registro" } )
		EndIf

		If SX3->( MsSeek( "CMN_PERAPU" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Per Apuração"
				SX3->X3_DESCRIC := "Período da Apuração"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PERAPU", "X3_TITULO"  , "Per Apuração" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PERAPU", "X3_DESCRIC" , "Período da Apuração" } )
		EndIf

		If SX3->( MsSeek( "CMN_INDAPU" ) )
			If lDicInDB
				aAdd(aBrwN,"CMN_INDAPU")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_INDAPU", "X3_BROWSE"  , "N" } )
		EndIf

		If SX3->( MsSeek( "CMN_PROTUL" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo"
				SX3->X3_DESCRIC := "Recibo da Transmissão"
				SX3->X3_BROWSE := "N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTUL", "X3_TITULO"  , "Recibo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTUL", "X3_DESCRIC" , "Recibo da Transmissão" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTUL", "X3_BROWSE"  , "N" } )
		EndIf

		If SX3->( MsSeek( "CMN_PROTPN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Recibo Ant"
				SX3->X3_DESCRIC := "Recibo Trans Anterior"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTPN", "X3_TITULO"  , "Recibo Ant" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_PROTPN", "X3_DESCRIC" , "Recibo Trans Anterior" } )
		EndIf

		If SX3->( MsSeek( "CMN_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Reg Ativo"
				SX3->X3_DESCRIC := "Registro Ativo"
				SX3->X3_PICTURE := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ATIVO", "X3_TITULO" , "Reg Ativo" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_ATIVO", "X3_DESCRIC" , "Registro Ativo" } )
		EndIf

		If SX3->( MsSeek( "CRO_NUMDOC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Núm NF"
				SX3->X3_DESCRIC := "Número da Nota Fiscal"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CRO_NUMDOC", "X3_TITULO"  , "Num NF" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CRO_NUMDOC", "X3_DESCRIC" , "Número da Nota Fiscal" } )
		EndIf

		If SX3->( MsSeek( "T94_EXCLUI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO := "Ativo ?"
				SX3->X3_DESCRIC := "TAG com Controle Ativo"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T94_EXCLUI", "X3_TITULO"  , "Ativo ?" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T94_EXCLUI", "X3_DESCRIC" , "TAG com Controle Ativo" } )
		EndIf

		If SX3->( MsSeek(  "T93_PADRAO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO  := "Comp. Padrão"
				SX3->X3_DESCRIC := "Comportamento Padrao Tags"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T93_PADRAO", "X3_TITULO"  , "Comp. Padrão" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T93_PADRAO", "X3_DESCRIC" , "Comportamento Padrao Tags" } )
		EndIf

		If SX3->( MsSeek(  "T93_ATIVO" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := "2"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T93_ATIVO' , "X3_RELACAO" , '"2"'  } )
		EndIf

		If SX3->( MsSeek(  "C99_DESCRI" ) )
			If lDicInDB
				aAdd(aBrwN,"C99_DESCRI")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C99_DESCRI' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "C20_DESOBR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:=	'IIF(!INCLUI .AND. !EMPTY(C20->C20_IDOBR),POSICIONE("T9C",1,XFILIAL("T9C")+C20->C20_IDOBR,"T9C_DSCOBR"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C20_DESOBR' , "X3_RELACAO" , 'IIF(!INCLUI .AND. !EMPTY(C20->C20_IDOBR),POSICIONE("T9C",1,XFILIAL("T9C")+C20->C20_IDOBR,"T9C_DSCOBR"),"")'  } )
		EndIf

		If SX3->( MsSeek( "C1G_TPPROC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_CBOX	:= "1=Judicial;2=Administrativo;3=Número de Benefício (NB) do INSS;4=Processo FAP"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", 'C1G_TPPROC', "X3_CBOX" , "1=Judicial;2=Administrativo;3=Número de Benefício (NB) do INSS;4=Processo FAP" } )
		EndIf

		If SX3->( MsSeek( "V0L_PERAPU" ) ) .And. SX3->X3_BROWSE	<>	"N"
			If lDicInDB
				aAdd(aBrwN,"V0L_PERAPU")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'V0L_PERAPU' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek(  "C1H_PPES" ) )
			If !lDicInDB
				aAdd(aBrwN,"C1H_PPES")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C1H_PPES' , "X3_BROWSE" , "N"  } )
		Endif

		If SX3->( MsSeek( "T9F_ID" ) ) .And. SX3->X3_BROWSE	<>	"N"
			If lDicInDB
				aAdd(aBrwN,"T9F_ID")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T9F_ID' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->( MsSeek( "CUF_IDGRP" ) ) .And. SX3->X3_BROWSE	<>	"N"
			If lDicInDB
				aAdd(aBrwN,"CUF_IDGRP")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_BROWSE	:=	"N"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'CUF_IDGRP' , "X3_BROWSE" , "N"  } )
		EndIf

		If SX3->(MsSeek("V0W_TPEVEN")) .And. SX3->X3_BROWSE	<>	"S"
			If lDicInDB
				aAdd(aBrwS,"V0W_TPEVEN")
			ElseIf RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())			
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0W_TPEVEN', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0W_DTPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If lDicInDB
				aAdd(aBrwS,"V0W_DTPROC")
			ElseIf RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0W_DTPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0W_HRPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If lDicInDB
				aAdd(aBrwS,"V0W_HRPROC")
			ElseIf RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0W_HRPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0C_DTPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If lDicInDB
				aAdd(aBrwS,"V0C_DTPROC")
			ElseIf RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())			
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0C_DTPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->(MsSeek("V0C_HRPROC")) .And. SX3->X3_BROWSE	<>	"S"
			If lDicInDB
				aAdd(aBrwS,"V0C_HRPROC")
			ElseIf RecLock("SX3", .F.)
				SX3->X3_BROWSE	:=	"S"
				SX3->(MsUnlock())
			EndIf
			aAdd(aUpdTask, {cEmpAnt, "SX3", 'V0C_HRPROC', "X3_BROWSE", "S"})
		EndIf

		If SX3->( MsSeek( "T0C_DCODRE" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := 'IF(!INCLUI.AND.!EMPTY(T0C->T0C_IDCODR),POSICIONE("C6R",3, XFILIAL("C6R")+T0C->T0C_IDCODR,' + '"C6R_CODIGO+' + "' - '" + '+C6R_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0C_DCODRE' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(T0C->T0C_IDCODR),POSICIONE("C6R",3, XFILIAL("C6R")+T0C->T0C_IDCODR,"C6R_CODIGO +'-'+C6R_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "T0D_DCODRE" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO := 'IF(!INCLUI.AND.!EMPTY(T0D->T0D_CODREC),POSICIONE("C6R",1, XFILIAL("C6R")+T0D->T0D_CODREC,' + '"C6R_CODIGO+' + "' - '" + '+C6R_DESCRI"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0D_DCODRE' , "X3_RELACAO" , 'IF(!INCLUI.AND.!EMPTY(T0D->T0D_CODREC),POSICIONE("C6R",3, XFILIAL("C6R")+T0D->T0D_CODREC,"C6R_CODIGO +'-'+C6R_DESCRI"),"")' } )
		EndIf

		If SX3->( MsSeek( "T0C_IDCODR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := 'C6R'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0C_IDCODR' , 'X3_F3' , 'C6R' } )
		EndIf

		If SX3->( MsSeek( "T0D_IDCODR" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_F3 := 'C6R'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T0D_IDCODR' , 'X3_F3' , 'C6R' } )
		EndIf

		//eSocial - Inclusão/Alteração manual de múltiplos vínculos
		If SX3->( MsSeek( "C91_CPF" ) )
			If lDicInDB
				aAdd(aVisA,"C91_CPF")
				aAdd(aBrwS,"C91_CPF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->X3_BROWSE	:= "S"
				SX3->( MsUnlock() )			
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_CPF' , "X3_VISUAL", 'A'  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_CPF' , "X3_BROWSE", 'S'  } )
		EndIf

		If SX3->( MsSeek( "C9K_CODLOT" ) )
			If lDicInDB
				aAdd(aVisA,"C9K_CODLOT")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_CODLOT' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9K_TPINSC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->X3_CBOX	:= "1=CNPJ;2=CPF;3=CAEPF;4=CNO"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_TPINSC' , "X3_VISUAL", 'A'  } )
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_TPINSC' , "X3_CBOX", '1=CNPJ;2=CPF;3=CAEPF;4=CNO'  } )
		EndIf

		If SX3->( MsSeek( "C9K_NRINSC" ) )
			If lDicInDB
				aAdd(aVisA,"C9K_NRINSC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9K_NRINSC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9L_DTRABA" ) )
			If lDicInDB
				aAdd(aVisA,"C9L_DTRABA")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9L_DTRABA' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9M_RUBRIC" ) )
			If lDicInDB
				aAdd(aVisA,"C9M_RUBRIC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9M_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9M_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"C9M_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9M_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9P_CODLOT" ) )
			If lDicInDB
				aAdd(aVisA,"C9P_CODLOT")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9P_CODLOT' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9P_TPINSC" ) )
			If lDicInDB
				aAdd(aVisA,"C9P_TPINSC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9P_TPINSC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9P_NRINSC" ) )
			If lDicInDB
				aAdd(aVisA,"C9P_NRINSC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9P_NRINSC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9R_RUBRIC" ) )
			If lDicInDB
				aAdd(aVisA,"C9R_RUBRIC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9R_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C9R_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"C9R_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := "A"
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C9R_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C91_NOME" ) )
			If lDicInDB
				aAdd(aVisA,"C91_NOME")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_NOME' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C91_NASCTO" ) )
			If lDicInDB
				aAdd(aVisA,"C91_NASCTO")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C91_NASCTO' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T3P_CPF" ) )
			If lDicInDB
				aAdd(aVisA,"T3P_CPF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T3P_CPF' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T3P_NOMER" ) )
			If lDicInDB
				aAdd(aVisA,"T3P_NOMER")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T3P_NOMER' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE2_RUBRIC" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE2_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE2_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"LE2_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE2_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE4_RUBRIC" ) )
			If lDicInDB
				aAdd(aVisA,"LE4_RUBRIC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE4_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "LE4_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"LE4_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'LE4_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T5Y_RUBRIC" ) )
			If lDicInDB
				aAdd(aVisA,"T5Y_RUBRIC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T5Y_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T5Y_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"T5Y_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T5Y_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6Q_RUBRIC" ) )
			If lDicInDB
				aAdd(aVisA,"T6Q_RUBRIC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6Q_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6Q_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"T6Q_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6Q_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6R_RUBRIC" ) )
			If lDicInDB
				aAdd(aVisA,"T6R_RUBRIC")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6R_RUBRIC' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "T6R_IDTABR" ) )
			If lDicInDB
				aAdd(aVisA,"T6R_IDTABR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'A'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T6R_IDTABR' , "X3_VISUAL", 'A'  } )
		EndIf

		If SX3->( MsSeek( "C29_VLRLIQ" ) ) .and. SX3->X3_VISUAL == 'A'
			If lDicInDB
				aAdd(aVisV,"C29_VLRLIQ")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_VISUAL  := 'V'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C29_VLRLIQ' , "X3_VISUAL", 'V'  } )
		EndIf

		If SX3->( MsSeek( "C0R_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'GetSx8Num("C0R","C0R_ID",,6)' //C0R_FILIAL, C0R_ID, R_E_C_N_O_, D_E_L_E_T_
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C0R_ID' , "X3_RELACAO" , 'GetSx8Num("C0R","C0R_ID",,6)' } )
		EndIf

		If SX3->( MsSeek( "C5M_ID" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'GetSx8Num("C5M","C5M_ID",,3)' //C5M_FILIAL, C5M_ID, R_E_C_N_O_, D_E_L_E_T_
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'C5M_ID' , "X3_RELACAO" , 'GetSx8Num("C5M","C5M_ID",,3)' } )
		EndIf

		If SX3->( MsSeek( "V5S_FILIAL" ) )
			If lDicInDB
				aAdd(aTrigg,"V5S_FILIAL")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "V5S_FILIAL", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CA4_FILIAL" ) )
			If lDicInDB
				aAdd(aTrigg,"CA4_FILIAL")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CA4_FILIAL", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CMN_TPNUOB" ) )
			If RecLock( "SX3", .F. )
			    SX3->X3_F3 := ""
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_TPNUOB", "X3_F3", "REMOVIDO" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_TPNUOB", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "T95_TPNUOB" ) )
			If RecLock( "SX3", .F. )
			    SX3->X3_F3 := ""
				SX3->X3_TRIGGER := ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T95_TPNUOB", "X3_F3", "REMOVIDO" } )
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T95_TPNUOB", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "T95_CODPAR" ) )
			If lDicInDB
				aAdd(aTrigg,"T95_CODPAR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T95_CODPAR", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "T96_CHVNF" ) )
			If lDicInDB
				aAdd(aTrigg,"T96_CHVNF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "T96_CHVNF", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CMN_CODPAR" ) )
			If lDicInDB
				aAdd(aTrigg,"CMN_CODPAR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_CODPAR", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CMN_TPNUOB" ) )
			If lDicInDB
				aAdd(aTrigg,"CMN_TPNUOB")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CMN_TPNUOB", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CRO_CHVNF" ) )
			If lDicInDB
				aAdd(aTrigg,"CRO_CHVNF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "CRO_CHVNF", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "V5S_CODPAR" ) )
			If lDicInDB
				aAdd(aTrigg,"V5S_CODPAR")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "V5S_CODPAR", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "V5V_CHVNF" ) )
			If lDicInDB
				aAdd(aTrigg,"V5V_CHVNF")
			ElseIf RecLock( "SX3", .F. )
				SX3->X3_TRIGGER	:= ""
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask, { cEmpAnt, "SX3", "V5V_CHVNF", "X3_TRIGGER", "REMOVIDO" } )
		EndIf

		If SX3->( MsSeek( "CM0_DCODSI" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")'
				SX3->( MsUnlock() )
				aAdd( aUpdTask , { cEmpAnt, "SX3", "CM0_CODSIT", "X3_RELACAO", 'IiF(!INCLUI .and. !EMPTY(CM0->CM0_CODSIT),Posicione("C8L",1,xFilial("C8L")+CM0->CM0_CODSIT, "C8L_CODIGO+' + "' - '" + '+C8L_DESCRI" ),"")' } )
			EndIf
		EndIf

		If SX3->( MsSeek( "T3P_NOMEV" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'IiF(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")'
				SX3->( MsUnlock() )
				aAdd( aUpdTask , { cEmpAnt, "SX3", "T3P_NOMEV", "X3_RELACAO", 'IIf(!INCLUI, TafGetNome(T3P->T3P_FILIAL,T3P->T3P_BENEFI,T3P->T3P_NOMER,"T3P","T3P"), "")' })
			EndIf
		EndIf

		If SX3->( MsSeek( "T3P_NOME  " ) )
			If RecLock( "SX3", .F. )
				SX3->X3_RELACAO	:= 'IIF(!INCLUI .AND. !EMPTY(T3P->T3P_BENEFI),TAFNMTRAB(XFILIAL("C9V"),M->T3P_BENEFI,"S1210"),"")'
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T3P_NOME' , "X3_RELACAO" , 'IIF(!INCLUI .AND. !EMPTY(T3P->T3P_BENEFI),TAFNMTRAB(XFILIAL("C9V"),M->T3P_BENEFI,"S1210"),"")' } )
		EndIf

		If SX3->(MsSeek("V72_DFUNC"))
			If RecLock("SX3", .F.)
				SX3->X3_RELACAO	:= 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'
				SX3->X3_INIBRW	:= 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'
				SX3->(MsUnlock())
			EndIf
			AAdd(aUpdTask, {cEmpAnt, "SX3", "V72_DFUNC", "X3_RELACAO"	, 'IIF(!INCLUI .AND. !EMPTY(V72->V72_FUNC), TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231"),"")'})
			AAdd(aUpdTask, {cEmpAnt, "SX3", "V72_DFUNC", "X3_INIBRW"	, 'TAFNMTRAB(XFILIAL("V72"),V72->V72_FUNC,"S2231")'})
		EndIf

		If SX3->(MsSeek("CUO_PAGDIV"))
			If RecLock("SX3", .F.)
				SX3->X3_TITULO 	:= "Pag. Per Apu"
				SX3->X3_DESCRIC := "Info. Pagto. Per. Apur."
				SX3->(MsUnlock())
			EndIf
			AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_TITULO"	, "Pag. Per Apu"			})
			AAdd(aUpdTask, {cEmpAnt, "SX3", "CUO_PAGDIV", "X3_DESCRIC"	, "Info. Pagto. Per. Apur."	})
		EndIf	

		If SX3->( MsSeek( "T2G_CPFTRA" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"CPF Trab."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T2G_CPFTRA' , "X3_TITULO" , "CPF Trab."  } )
		EndIf	

		If SX3->( MsSeek( "T2G_CPFBEN" ) )
			If RecLock( "SX3", .F. )
				SX3->X3_TITULO	:=	"CPF Ben."
				SX3->( MsUnlock() )
			EndIf
			aAdd( aUpdTask , { cEmpAnt , "SX3" , 'T2G_CPFBEN' , "X3_TITULO" , "CPF Ben."  } )
		EndIf

	EndIf
	
	If ( !lUPDTAF .and. cRelStart < "2210" .and. cRelFinish >= "2210" ) .or. ( lUPDTAF .and. cRelease == "2210" )

		If SX3->(MsSeek('C20_CHVNF')) 
			//Protejo com a verificação do tamanho do campo, se foi alterado para comportar o retorno de 36 caracteres da função FWUUID(). Tamanho anterior: 15
			If SX3->X3_TAMANHO >= 36 
				If RecLock('SX3', .f.)
					SX3->X3_RELACAO	:= 'FWUUID("C20")'
					SX3->(MsUnlock())
				EndIf
				AAdd(aUpdTask, {cEmpAnt, 'SX3', 'C20_CHVNF', 'X3_RELACAO', 'FWUUID("C20")'})
			EndIf	
		EndIf

		If SX3->( MsSeek( "V4K_VLREAJ" ) )
			If AllTrim(Posicione("SX3", 2, "V4K_VLREAJ", "X3_TITULO")) != "Vlr Bruto"
				If RecLock( "SX3", .F. )
					SX3->X3_TITULO	:=	"Vlr Bruto"
					SX3->X3_DESCRIC	:=	"Valor Bruto"
					SX3->( MsUnlock() )
				EndIf
				aAdd( aUpdTask , { cEmpAnt , "SX3" , 'V4K_VLREAJ' , "X3_TITULO"  , "Vlr Bruto"  	} )
				aAdd( aUpdTask , { cEmpAnt , "SX3" , 'V4K_VLREAJ' , "X3_DESCRIC" , "Valor Bruto"  	} )			
			EndIf
		EndIf
	EndIf
	
	If lDicInDB 
		//Atualiza X3_BROWSE para N
		If Len(aBrwN) > 0
			cQuery :=  " UPDATE " + MPSysSqlName( "SX3" ) + " SET X3_BROWSE = 'N' WHERE X3_CAMPO IN ("
			For nI := 1 to Len( aBrwN )
				cQuery += "'" + aBrwN[nI] + "',"
			Next nI
			cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )
			cQuery += ") AND D_E_L_E_T_ = ' '"			
			TCSQLEXEC( cQuery )	
		EndIf	

		//Atualiza X3_BROWSE para S
		If Len(aBrwS) > 0
			cQuery :=  " UPDATE " + MPSysSqlName( "SX3" ) + " SET X3_BROWSE = 'S' WHERE X3_CAMPO IN ("
			For nI := 1 to Len(aBrwS)
				cQuery += "'" + aBrwS[nI] + "'," 
			Next nI	
			cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )
			cQuery += ") AND D_E_L_E_T_ = ' '"
			TCSQLEXEC( cQuery )	
		EndIf

		//Atualiza X3_VISUAL para A
		If Len(aVisA) > 0
			cQuery := " UPDATE " + MPSysSqlName( "SX3" ) + " SET X3_VISUAL = 'A' WHERE X3_CAMPO IN ("
			For nI := 1 to Len(aVisA)
				cQuery += "'" + aVisA[nI] + "'," 
			Next nI
			cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )		
			cQuery += ") AND D_E_L_E_T_ = ' '"	
			TCSQLEXEC( cQuery )	
		EndIf

		//Atualiza X3_VISUAL para V
		If Len(aVisV) > 0
			cQuery := " UPDATE " + MPSysSqlName( "SX3" ) + " SET X3_VISUAL = 'V' WHERE X3_CAMPO IN ("
			For nI := 1 to Len(aVisV)
				cQuery += "'" + aVisV[nI] + "',"
			Next nI
			cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )
			cQuery += ") AND D_E_L_E_T_ = ' '"			
			TCSQLEXEC( cQuery )	
		EndIf

		//Atualiza X3_TRIGGER para ""
		If Len(aTrigg) > 0
			cQuery := " UPDATE " + MPSysSqlName( "SX3" ) + " SET X3_TRIGGER = '' WHERE X3_CAMPO IN ("
			For nI := 1 to Len(aTrigg)
				cQuery += "'" + aTrigg[nI] + "'," 
			Next nI
			cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )
			cQuery += ") AND D_E_L_E_T_ = ' '"			
			TCSQLEXEC( cQuery )	
		EndIf
	EndIf
	RestArea(aAreaSX3)

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} FAtuTAFSX6
@type			function
@description	Realiza a atualização do Dicionário de Dados SX6 ( Parâmetros ).
@author			Felipe C. Seolin
@since			13/09/2024
@param			cRelStart	-	Versão da Release Origem. Exemplo: 2210
@param			cRelFinish	-	Versão da Release Destino. Exemplo: 2410
@param			lDicInDB	-	Informa se ambiente está com Dicionário no Banco
@param			lUPDTAF		-	Indica se foi chamado pelo UPDTAF
@param			cRelease	-	Versão da Release selecionada no UPDTAF. Exemplo: 2310
@param			aUpdTask	-	Array com o log de atualizações para exibição no UPDTAF
/*/
//---------------------------------------------------------------------
Function FAtuTAFSX6( cRelStart, cRelFinish, lDicInDB, lUPDTAF, cRelease, aUpdTask )

Local cQuery		as character
Local cNextAlias	as character
Local aAreaSX6		as array
Local lUpdate		as logical

Default cRelStart	:=	""
Default cRelFinish	:=	""
Default lDicInDB	:=	.F.
Default lUPDTAF		:=	.F.
Default cRelease	:=	""
Default aUpdTask	:=	{}

aAreaSX6	:=	SX6->( GetArea() )
lUpdate		:=	.F.

SX6->( DBSetOrder( 1 ) )

If ( !lUPDTAF .and. cRelStart < "2410" .and. cRelFinish >= "2310" ) .or. ( lUPDTAF .and. cRelease == "2410" )

	cQuery := "SELECT SX6.R_E_C_N_O_ RECNO "
	cQuery += "FROM " + RetSqlName( "SX6" ) + " SX6 "
	cQuery += "WHERE SX6.X6_VAR = 'MV_TAFISCH' "
	cQuery += "  AND SX6.X6_TIPO = 'L' "
	cQuery += "  AND SX6.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery )
	cNextAlias := GetNextAlias()
	TCQuery cQuery New Alias (cNextAlias)
	( cNextAlias )->( DBGoTop() )

	While ( cNextAlias )->( !Eof() )
		SX6->( DBGoTo( ( cNextAlias )->RECNO ) )

		If RecLock( "SX6", .F. )
			lUpdate := .T.

			SX6->X6_TIPO	:= "C"
			SX6->X6_CONTEUD	:= ""
			SX6->X6_CONTSPA	:= ""
			SX6->X6_CONTENG	:= ""
			SX6->X6_DESCRIC	:= "Integração Livros Fiscais X TAF via Smart Schedule"
			SX6->X6_DSCSPA	:= "Define si la integración del TAF será vía schedule"
			SX6->X6_DSCENG	:= "TAF Records x TAF integration via Smart Schedule"
			SX6->X6_DESC1	:= "0=Desabilitado;1=Habilitado;"
			SX6->X6_DSCSPA1	:= "0=Inhabilitado;1=Habilitado;"
			SX6->X6_DSCENG1	:= "0=Disabled;1=Enabled;"
			SX6->X6_DEFPOR	:= ""
			SX6->X6_DEFSPA	:= ""
			SX6->X6_DEFENG	:= ""
			SX6->( MsUnlock() )
		EndIf

		( cNextAlias )->( DBSkip() )
	EndDo

	If lUpdate
		aAdd( aUpdTask, { cEmpAnt, "SX6", "MV_TAFISCH", "X6_TIPO", "C" } )
	EndIf

	( cNextAlias )->( DBCloseArea() )
EndIf

RestArea( aAreaSX6 )

Return()

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSX7
Realiza a atualização do Dicionário de Dados SX7( Gatilhos )

@Param	  cRelStart  - Versão do Release origem Ex: 033
@Param	  cRelFinish - Versão do Release destino Ex: 2210
@Param	  lDicInDB   - .T. Se dicionario no banco
@Param	  lUPDTAF    - Se for chamado pelo UPDTAF
@Param	  cRelease   - Versão do Release selecionado no UPDTAF Ex: 2210
@Param	  aUpdTask   - Array com o log de atualizações do UPDTAF

@Author  Rodrigo Aguilar
@Since   09/04/2015
@Version 1.0

@Return ( Nil )

/*/
//--------------------------------------------------------------------------------------------------
Function FAtuTafSX7( cRelStart, cRelFinish, lDicInDB, lUPDTAF, cRelease, aUpdTask )

	Local aAreaSX7	as array
	Local lFind     as logical
	Local nI		as numeric
	Local aDel		as array
	Local cQuery	as character

	Default cRelStart   :=  ""
	Default cRelFinish  :=  ""
	Default lDicInDB 	:=  .F.
	Default lUPDTAF     :=  .F.
	Default cRelease    :=  ""
	Default aUpdTask    :=  {}

	aAreaSX7	:= SX7->( GetArea() )
	lFind		:= .F.
	nI			:= 0
	aDel		:= {}
	cQuery		:= ""

	//Seta Ordem de Pesquisa
	SX7->( dbSetOrder( 1 ) )

	If ( !lUPDTAF .and. cRelStart < "033" .and. cRelFinish >= "033" ) .or. ( lUPDTAF .and. cRelease == "033" )

		If SX7->( MsSeek( "T95_CODPAR" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "T95_CODPAR" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf  RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "T95_CODPAR", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "T96_CHVNF" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "T96_CHVNF" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "T96_CHVNF", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CMN_CODPAR" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CMN_CODPAR" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CMN_CODPAR", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CMN_TPNUOB" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CMN_TPNUOB" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CMN_TPNUOB", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CRO_CHVNF" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CRO_CHVNF" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CRO_CHVNF", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "V5S_CODPAR" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "V5S_CODPAR" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "V5S_CODPAR", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "V5V_CHVNF" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "V5V_CHVNF" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "V5V_CHVNF", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "V5S_FILIAL" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "V5S_FILIAL" .And. Upper(Alltrim(SX7->X7_TIPO)) == "X" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "V5S_FILIAL", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If SX7->( MsSeek( "CA4_FILIAL" ) )
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CA4_FILIAL" .And. Upper(Alltrim(SX7->X7_TIPO)) == "X" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CA4_FILIAL", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf

		If ( SX7->(MsSeek(PadR("CM9_FUNC",10) + "002"))) 
			While SX7->( !Eof() ) .And. Alltrim(SX7->X7_CAMPO) == "CM9_FUNC" .And. Upper(Alltrim(SX7->X7_TIPO)) == "P" .And. SX7->X7_PROPRI <> "U"
				If lDicInDB
					aAdd( aDel, SX7->(RECNO()) )
				ElseIf RecLock( "SX7", .F. )
					SX7->( DBDelete() )
					SX7->( MsUnlock() )
				EndIf
				aAdd( aUpdTask, { cEmpAnt, "SX7", "CM9_FUNC", SX7->X7_SEQUENC, "DELETADO" } )
				SX7->( DBSkip() )
			EndDo
		EndIf	
	EndIf

	//Deleta SX7 
	If lDicInDB 
		If Len(aDel) > 0
			cQuery := " UPDATE " + MPSysSqlName( "SX7" ) + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE R_E_C_N_O_ IN ("
			For nI := 1 to Len(aDel)
				cQuery += " " + cValToChar(aDel[nI]) + ","
			Next nI
			cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )
			cQuery += ") AND D_E_L_E_T_ = ' '"	
			TCSQLEXEC( cQuery )
		EndIf
	EndIf

	//Restaura a Area Original
	RestArea( aAreaSX7 )

Return ( nil )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FAtuTafSXA
Realiza a atualização do Dicionário de Dados SXA( Pastas e Agrupamentos de campos )

@Param	  cRelStart  - Versão do Release origem Ex: 033
@Param	  cRelFinish - Versão do Release destino Ex: 2210
@Param	  lDicInDB   - .T. Se dicionario no banco
@Param	  lUPDTAF    - Se for chamado pelo UPDTAF
@Param	  cRelease   - Versão do Release selecionado no UPDTAF Ex: 2210
@Param	  aUpdTask   - Array com o log de atualizações do UPDTAF

@Author  Denis R. de Oliveira
@Since   23/11/2017
@Version 1.0

@Return ( Nil )

/*/
//--------------------------------------------------------------------------------------------------
Function FAtuTafSXA( cRelStart, cRelFinish, lDicInDB, lUPDTAF, cRelease, aUpdTask )

	Local aAreaSXA	as array
	Local lRec		as logical
	Local aAlias	as array
	Local nX 		as numeric
	Local nI		as numeric
	Local cQuery	as character
	Local aDel		as array

	Default cRelStart   :=  ""
	Default cRelFinish  :=  ""
	Default lDicInDB 	:=  .F.
	Default lUPDTAF     :=  .F.
	Default cRelease    :=  ""
	Default aUpdTask    :=  {}

	aAreaSXA	:=	SXA->( GetArea() )
	lRec		:=	.T.
	aAlias		:= {}
	nX	 		:= 1
	nI			:= 0
	aDel		:= {}

	If ( !lUPDTAF .and. cRelStart < "2210" .and. cRelFinish >= "2210" ) .or. ( lUPDTAF .and. cRelease == "2210" )

		aAlias := {"T62"}

	EndIf

	If !Empty(aAlias)

		SXA->(dbSetOrder(1))

		For nX := 1 to Len(aAlias) 
			If SXA->(dbSeek(aAlias[nX]))

				While SXA->( !Eof() ) .and. SXA->XA_ALIAS == aAlias[nX]
					If lDicInDB
						aAdd( aDel, SXA->(RECNO()) )
					ElseIf RecLock( "SXA", .F. )
						SXA->( DBDelete() )
						SXA->( MsUnlock() )
					EndIf 
					aAdd( aUpdTask , { cEmpAnt ,"SXA" , aAlias[nX] ,  , "DELETADAS PASTAS DA " + aAlias[nX]  } )
					SXA->( DBSkip() )
				EndDo
			EndIf
		Next

		//Deleta SXA
		If lDicInDB  
			If Len(aDel) > 0
				cQuery := " UPDATE " + MPSysSqlName( "SXA" ) + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE R_E_C_N_O_ IN ("
				For nI := 1 to Len(aDel)
					cQuery += " " + cValToChar(aDel[nI]) + "," 
				Next nI
				cQuery := SubStr( cQuery, 1, Len( cQuery ) - 1 )
				cQuery += ") AND D_E_L_E_T_ = ' '"	
				TCSQLEXEC( cQuery )
			EndIf
		EndIf

	EndIf

	RestArea( aAreaSXA )

Return Nil
