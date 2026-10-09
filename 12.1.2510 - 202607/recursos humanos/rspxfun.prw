#include "Protheus.ch"
#include "rspxfun.ch"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠цддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.                      Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё FNC  Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁCecilia Car.Ё06/08/14ЁTQENRXЁIncluido o fonte da 11 para a 12 e efetua-Ё╠╠
╠╠Ё            Ё        Ё      Ёda a limpeza.                             Ё╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё RSPLoadExec	ЁAutorЁ  Igor Franzoi     Ё Data Ё29/06/2009Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁFuncao executada a cada rotina (menu) chamado pelo RSP		Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRSPLoadExec													Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico													Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  Ё															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function RSPLoadExec()

If FindFunction("SPFLoadExec()")
	SPFLoadExec()
EndIf

Return (Nil)


/*/
зддддддддддбддддддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁValidArqRsp   Ё Autor ЁGustavo M.            Ё Data Ё20/04/2012Ё
цддддддддддеддддддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida o Relacionamentos dos Arquivos do SIGARSP               Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁValidArqRsp( lShowHelp )                           			   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ                                         					   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet -> Se todos os Arquivos Estao com o Relacionamento CorretoЁ
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	       Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerica                                                       Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function ValidArqRsp( lShowHelp )
Return( RspRelationFile( lShowHelp ) )

/*/
зддддддддддбдддддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁPonRelationFileЁ Autor ЁGustavo M.           Ё Data Ё20/04/2012Ё
цддддддддддедддддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida o Relacionamentos dos Arquivos do SIGARSP     		   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁRspRelationFile( void )                            			   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ                                         					   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁRetorno   ЁlRet -> Se todos os Arquivos Estao com o Relacionamento CorretoЁ
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                      	       Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁUso       ЁGenerica                                                       Ё
юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Function RspRelationFile( )

Local lRetModo		:= .F.
Local cTabela		:= ""
/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Coloca o Ponteiro do Mouse em Estado de Espera               Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
CursorWait()

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Consiste o Modo de Acesso dos Arquivos                       Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
Begin Sequence    
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQL"),.T.,.F.))
		cTabela:="SQL" 
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQM"),.T.,.F.)) 
		cTabela:="SQM"  
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF  
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQI"),.T.,.F.))  
		cTabela:="SQI" 
		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
	IF ( lRetModo := IF (xFilial("SQG")<>xFilial("SQR"),.T.,.F.))  
   		cTabela:="SQR"    
   		Help(,,"RSPACESSO",,STR0001,1,0,,,,,,{STR0002}) //O compartilhamento entre as tabelas SQG, SQL, SQM, SQI e SQR deve ser igual.
		Break
	EndIF
End Sequence

/*/
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Restaura o Ponteiro do Mouse                                 Ё
дддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/
	
CursorArrow()


Return( lRetModo )

/*/{Protheus.doc} RspUsaModulo()
	(long_description)
	@type  Function
	@author Emerson Grassi Rocha
	@since 24/04/2025
	@version version
/*/
Function RspUsaModulo()

Local lRet 		:= .T.
Local lRspLib 	:= SuperGetMV("MV_RSPLIB",.T.,"") == "LIBRSP25" //Verifica se libera mСdulo
Local nSQG		:= 0
Local nSQD		:= 0
Local cUrl 		:= "https://produtos.totvs.com/ficha-tecnica/tudo-sobre-o-totvs-rh-atracao-de-talentos/"

If cPaisLoc == "BRA"

	dbSelectArea("SQG") //Curriculo
	nSQG := SQG->(RecCount())

	dbSelectArea("SQD") //Agenda
	nSQD := SQD->(RecCount())

	If nSQG <= 12 .And. nSQD <= 12 .And. !lRspLib

		nOp := Aviso( 	"AtenГЦo", "Prezado usuАrio, nЦo foi possivel abrir o mСdulo SIGARSP. Entre em contato com o seu Executivo de conta." + chr(13) + chr(13) +;
						"A SoluГЦo TOTVS AtraГЦo de Talentos (ATS) simplifica o processo de Recrutamento e SeleГЦo, promovendo a diversidade e acessibilidade tanto para empresas quanto para as pessoas candidatas." + chr(13) + chr(13) + cUrl,;
						{OemToAnsi("Link documentaГЦo"), OemToAnsi("Fechar")})

		If nOp == 1
			shellExecute("Open",cUrl, "", "", 1)
		EndIf
		
		lRet := .F.
	EndIf
EndIf
Return lRet
