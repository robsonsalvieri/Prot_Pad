#INCLUDE "UpdContigencia.ch"
#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ compsx   บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de update dos dicionแrios para compatibiliza็ใo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ compsx     - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UPDPOS( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAวรO DE DICIONมRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como fun็ใo fazer  a atualiza็ใo  dos dicionแrios do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja nใo podem haver outros"
Local   cDesc3    := "usuแrios  ou  jobs utilizando  o sistema.  ษ extremamente recomendav้l  que  se  fa็a um"
Local   cDesc4    := "BACKUP  dos DICIONมRIOS  e da  BASE DE DADOS antes desta atualiza็ใo, para que caso "
Local   cDesc5    := "ocorra eventuais falhas, esse backup seja ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk
	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualiza็ใo dos dicionแrios ?", cTitulo ) //"Confirma a atualiza็ใo dos dicionแrios ?"
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. ) //"Atualizando"###"Aguarde, atualizando ..."
			oProcess:Activate()

		If lAuto
			If lOk
				MsgStop( STR0010, STR0011 ) //"Atualiza็ใo Realizada."###"COMPSX"
				dbCloseAll()
			Else
				MsgStop( STR0012, STR0011 ) //"Atualiza็ใo nใo Realizada."###"COMPSX"
				dbCloseAll()
			EndIf
		Else
			If lOk
				u_STPopula() // Popula MEX
				MsgAlert("Base Populada")
				Final( STR0013 ) //"Atualiza็ใo Concluํda."
			Else
				Final( STR0012 ) //"Atualiza็ใo nใo Realizada."
			EndIf
		EndIf

		Else
			MsgStop( STR0012, STR0011 ) //"Atualiza็ใo nใo Realizada."###"COMPSX"

		EndIf

	Else
		MsgStop( STR0012, STR0011 ) //"Atualiza็ใo nใo Realizada."###"COMPSX"

	EndIf

EndIf



Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSTProc  บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da grava็ใo dos arquivos           ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSTProc    - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := STR0014 + STR0015 //"Arquivos Texto"###"(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( STR0016 + aRecnoSM0[nI][2] + STR0017 ) //"Atualiza็ใo da empresa "###" nใo efetuada."
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += STR0018 + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF //"Empresa : "

			oProcess:SetRegua1( 8 )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX2         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			oProcess:IncRegua1( STR0019 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de arquivos"
			FSAtuSX2( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX3         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			FSAtuSX3( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SIX         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oProcess:IncRegua1( STR0020 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de ํndices"
			FSAtuSIX( @cTexto )

			oProcess:IncRegua1( STR0021 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de dados"
			oProcess:IncRegua2( STR0022 ) //"Atualizando campos/ํndices"

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( STR0023 + aArqUpd[nX] + STR0024, STR0025 ) //"Ocorreu um erro desconhecido durante a atualiza็ใo da tabela : "###". Verifique a integridade do dicionแrio e da tabela."###"ATENวรO"
					cTexto += STR0026 + aArqUpd[nX] + CRLF //"Ocorreu um erro desconhecido durante a atualiza็ใo da estrutura da tabela : "
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX6         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oProcess:IncRegua1( STR0027 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de parโmetros"
			//FSAtuSX6( @cTexto )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX1         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//oProcess:IncRegua1( STR0028 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de perguntas"
			//FSAtuSX1( @cTexto )

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += STR0029 + CRLF //"LOG DA ATUALIZACAO DOS DICIONมRIOS"
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += STR0030 + CRLF //" Dados Ambiente"
			cAux += " --------------------"  + CRLF
			cAux += STR0031 + cEmpAnt + "/" + cFilAnt  + CRLF //" Empresa / Filial...: "
			cAux += STR0032 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF //" Nome Empresa.......: "
			cAux += STR0033 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF //" Nome Filial........: "
			cAux += STR0034 + DtoC( dDataBase )  + CRLF //" DataBase...........: "
			cAux += STR0035 + DtoC( Date() )  + " / " + Time()  + CRLF //" Data / Hora Inicio.: "
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += STR0036 + GetVersao(.T.)  + CRLF //" Versao.............: "
			cAux += STR0037 + __cUserId + " " +  cUserName + CRLF //" Usuario TOTVS .....: "
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += STR0038 + CRLF //" Dados Thread"
				cAux += " --------------------"  + CRLF
				cAux += STR0039 + aInfo[nPos][1] + CRLF //" Usuario da Rede....: "
				cAux += STR0040 + aInfo[nPos][2] + CRLF //" Estacao............: "
				cAux += STR0041 + aInfo[nPos][5] + CRLF //" Programa Inicial...: "
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += STR0042 + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF //" Conexao............: "
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += STR0043 + DtoC( Date() ) + " / " + Time()  + CRLF //" Data / Hora Final.: "
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title STR0044 From 3, 0 to 340, 417 Pixel //"Atualizacao concluida."

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX2 บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX2 - Arquivos      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX2   - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

cTexto  += STR0045 + " SX2" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODOEMP", "X2_MODOUN", "X2_MODULO" }

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )



//
// Tabela MES
//
aAdd( aSX2, { ;
	'MES'																		, ; //X2_CHAVE
	cPath																		, ; //X2_PATH
	'MES'+cEmpr																	, ; //X2_ARQUIVO
	"CabCont"											   						, ; //X2_NOME 		//'Or็amento (Log SIAC)'
	"CabCont"											  						, ; //X2_NOMESPA 	//'Or็amento (Log SIAC)'
	"CabCont"											   						, ; //X2_NOMEENG 	//'Or็amento (Log SIAC)'
	0																			, ; //X2_DELET
	'E'																			, ; //X2_MODO
	''																			, ; //X2_TTS
	''																			, ; //X2_ROTINA
	''																			, ; //X2_PYME
	'MES_FILIAL+MES_SEQ+MES_ESTACA+MES_TIPO'								, ; //X2_UNICO
	'E'																			, ; //X2_MODOEMP
	'E'																			, ; //X2_MODOUN
	0																			} ) //X2_MODULO


//
// Tabela MET
//
aAdd( aSX2, { ;
	'MET'																		, ; //X2_CHAVE
	cPath																		, ; //X2_PATH
	'MET'+cEmpr																	, ; //X2_ARQUIVO
	"ItCont"											   						, ; //X2_NOME 		//'Or็amento (Log SIAC)'
	"ItCont"											  						, ; //X2_NOMESPA 	//'Or็amento (Log SIAC)'
	"ItCont"											   						, ; //X2_NOMEENG 	//'Or็amento (Log SIAC)'
	0																			, ; //X2_DELET
	'E'																			, ; //X2_MODO
	''																			, ; //X2_TTS
	''																			, ; //X2_ROTINA
	''																			, ; //X2_PYME
	'MET_FILIAL+MET_PROCES'														, ; //X2_UNICO
	'E'																			, ; //X2_MODOEMP
	'E'																			, ; //X2_MODOUN
	0																			} ) //X2_MODULO


//
// Tabela MEX
//
aAdd( aSX2, { ;
	'MEX'																		, ; //X2_CHAVE
	cPath																		, ; //X2_PATH
	'MEX' + cEmpr																, ; //X2_ARQUIVO
	"Wizard"											   						, ; //X2_NOME 		
	"Wizard"											  						, ; //X2_NOMESPA 	
	"Wizard"											   						, ; //X2_NOMEENG 	
	0																			, ; //X2_DELET
	'C'																			, ; //X2_MODO
	''																			, ; //X2_TTS
	''																			, ; //X2_ROTINA
	''																			, ; //X2_PYME
	'MEX_FILIAL+MEX_ID'														, ; //X2_UNICO
	'C'																			, ; //X2_MODOEMP
	'C'																			, ; //X2_MODOUN
	0																			} ) //X2_MODULO
	
//
// Tabela MBR - Atualizado apenas a Chave Unica, adicionado campo PDV
//
aAdd( aSX2, { ;
	'MBR'																		, ; //X2_CHAVE
	""																		, ; //X2_PATH
	""																, ; //X2_ARQUIVO
	""											   						, ; //X2_NOME 		
	""											  						, ; //X2_NOMESPA 	
	""											   						, ; //X2_NOMEENG 	
	0																			, ; //X2_DELET
	''																			, ; //X2_MODO
	''																			, ; //X2_TTS
	''																			, ; //X2_ROTINA
	''																			, ; //X2_PYME
	'MBR_FILIAL+MBR_MOTIVO+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM+MBR_PDV'	, ; //X2_UNICO
	''																			, ; //X2_MODOEMP
	''																			, ; //X2_MODOUN
	0																			} ) //X2_MODULO



//
// Atualizando dicionแrio	
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( STR0048 ) //"Atualizando Arquivos (SX2)..."

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			cTexto += STR0049 + aSX2[nI][1] + CRLF //"Foi incluํda a tabela "
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				cTexto += STR0050 + aSX2[nI][1] + CRLF //"Foi alterada chave unica da tabela "
			Else
				cTexto += STR0051 + aSX2[nI][1] + CRLF //"Foi criada   chave unica da tabela "
			EndIf
		EndIf

	EndIf

Next nI

cTexto += CRLF + STR0052 + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX3 บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX3 - Campos        ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX3   - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )

cTexto  += STR0045 + " SX3" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }


// ---------------------------------------------------------------------------------------------------
// MES
// ---------------------------------------------------------------------------------------------------

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'01'																		, ; //X3_ORDEM
	'MES_FILIAL'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	FWSIZEFILIAL()															, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"FILIAL"																	, ; //X3_TITULO		// 'CRO'
	"FILIAL"																	, ; //X3_TITSPA		// 'CRO'
	"FILIAL"																	, ; //X3_TITENG		// 'CRO'
	"FILIAL"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"FILIAL"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"FILIAL"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	'033'																		, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'02'																		, ; //X3_ORDEM
	'MES_SEQ'																	, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"SEQ"																		, ; //X3_TITULO		// 'CRO'
	"SEQ"																		, ; //X3_TITSPA		// 'CRO'
	"SEQ"																		, ; //X3_TITENG		// 'CRO'
	"SEQ"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"SEQ"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"SEQ"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'03'																		, ; //X3_ORDEM
	'MES_ESTACA'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"ESTACAO"																	, ; //X3_TITULO		// 'CRO'
	"ESTACAO"																	, ; //X3_TITSPA		// 'CRO'
	"ESTACAO"																	, ; //X3_TITENG		// 'CRO'
	"ESTACAO"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"ESTACAO"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"ESTACAO"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME
	
	aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'03'																		, ; //X3_ORDEM
	'MES_ESTACA'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"ESTACAO"																	, ; //X3_TITULO		// 'CRO'
	"ESTACAO"																	, ; //X3_TITSPA		// 'CRO'
	"ESTACAO"																	, ; //X3_TITENG		// 'CRO'
	"ESTACAO"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"ESTACAO"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"ESTACAO"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'04'																		, ; //X3_ORDEM
	'MES_PROCES'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	30																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"PROCES"																	, ; //X3_TITULO		// 'CRO'
	"PROCES"																	, ; //X3_TITSPA		// 'CRO'
	"PROCES"																	, ; //X3_TITENG		// 'CRO'
	"PROCES"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"PROCES"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"PROCES"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'05'																		, ; //X3_ORDEM
	'MES_DATA'																	, ; //X3_CAMPO
	'D'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"DATA"																		, ; //X3_TITULO		// 'CRO'
	"DATA"																		, ; //X3_TITSPA		// 'CRO'
	"DATA"																		, ; //X3_TITENG		// 'CRO'
	"DATA"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"DATA"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"DATA"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME
	
aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'06'																		, ; //X3_ORDEM
	'MES_HORA'																	, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"HORA"																		, ; //X3_TITULO		// 'CRO'
	"HORA"																		, ; //X3_TITSPA		// 'CRO'
	"HORA"																		, ; //X3_TITENG		// 'CRO'
	"HORA"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"HORA"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"HORA"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'07'																		, ; //X3_ORDEM
	'MES_SITUA'																	, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	2																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"SITUA"																		, ; //X3_TITULO		// 'CRO'
	"SITUA"																		, ; //X3_TITSPA		// 'CRO'
	"SITUA"																		, ; //X3_TITENG		// 'CRO'
	"SITUA"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"SITUA"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"SITUA"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'08'																		, ; //X3_ORDEM
	'MES_PARAMS'																, ; //X3_CAMPO
	'M'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"PARAMS"																	, ; //X3_TITULO		// 'CRO'
	"PARAMS"																	, ; //X3_TITSPA		// 'CRO'
	"PARAMS"																	, ; //X3_TITENG		// 'CRO'
	"PARAMS"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"PARAMS"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"PARAMS"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'09'																		, ; //X3_ORDEM
	'MES_RETOK'																	, ; //X3_CAMPO
	'M'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"RETOK"																		, ; //X3_TITULO		// 'CRO'
	"RETOK"																		, ; //X3_TITSPA		// 'CRO'
	"RETOK"																		, ; //X3_TITENG		// 'CRO'
	"RETOK"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"RETOK"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"RETOK"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'10'																		, ; //X3_ORDEM
	'MES_TIPO'																	, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	2																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"TIPO"																		, ; //X3_TITULO		// 'CRO'
	"TIPO"																		, ; //X3_TITSPA		// 'CRO'
	"TIPO"																		, ; //X3_TITENG		// 'CRO'
	"TIPO"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"TIPO"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"TIPO"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'11'																		, ; //X3_ORDEM
	'MES_FILORI'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	FWSIZEFILIAL()															, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"FILIAL ORIGEM"															, ; //X3_TITULO		
	"FILIAL ORIGEM"															, ; //X3_TITSPA		
	"FILIAL ORIGEM"															, ; //X3_TITENG		
	"FILIAL ORIGEM"															, ; //X3_DESCRIC 	
	"FILIAL ORIGEM"															, ; //X3_DESCSPA 
	"FILIAL ORIGEM"															, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	'033'																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MES'																		, ; //X3_ARQUIVO
	'12'																		, ; //X3_ORDEM
	'MES_KEYORI'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	50																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"CHAVE DE  ORIGEM"														, ; //X3_TITULO		
	"CHAVE DE  ORIGEM"														, ; //X3_TITSPA		
	"CHAVE DE  ORIGEM"														, ; //X3_TITENG		
	"CHAVE DE  ORIGEM"														, ; //X3_DESCRIC 	
	"CHAVE DE  ORIGEM"														, ; //X3_DESCSPA 
	"CHAVE DE  ORIGEM"														, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

// ---------------------------------------------------------------------------------------------------
// MET
// ---------------------------------------------------------------------------------------------------

aAdd( aSX3, { ;
	'MET'																		, ; //X3_ARQUIVO
	'01'																		, ; //X3_ORDEM
	'MET_FILIAL'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	FWSIZEFILIAL()															, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"FILIAL"																	, ; //X3_TITULO		// 'CRO'
	"FILIAL"																	, ; //X3_TITSPA		// 'CRO'
	"FILIAL"																	, ; //X3_TITENG		// 'CRO'
	"FILIAL"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"FILIAL"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"FILIAL"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	'033'																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MET'																		, ; //X3_ARQUIVO
	'02'																		, ; //X3_ORDEM
	'MET_PROCES'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	30																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"PROCES"																	, ; //X3_TITULO		// 'CRO'
	"PROCES"																	, ; //X3_TITSPA		// 'CRO'
	"PROCES"																	, ; //X3_TITENG		// 'CRO'
	"PROCES"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"PROCES"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"PROCES"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MET'																		, ; //X3_ARQUIVO
	'03'																		, ; //X3_ORDEM
	'MET_DESCRI'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	100																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"DESCRI"																	, ; //X3_TITULO		// 'CRO'
	"DESCRI"																	, ; //X3_TITSPA		// 'CRO'
	"DESCRI"																	, ; //X3_TITENG		// 'CRO'
	"DESCRI"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"DESCRI"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"DESCRI"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MET'																		, ; //X3_ARQUIVO
	'04'																		, ; //X3_ORDEM
	'MET_PRIORI'																, ; //X3_CAMPO
	'N'																			, ; //X3_TIPO
	4																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"PRIORI"																	, ; //X3_TITULO		// 'CRO'
	"PRIORI"																	, ; //X3_TITSPA		// 'CRO'
	"PRIORI"																	, ; //X3_TITENG		// 'CRO'
	"PRIORI"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"PRIORI"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"PRIORI"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


// ---------------------------------------------------------------------------------------------------
// MEX
// ---------------------------------------------------------------------------------------------------

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'01'																		, ; //X3_ORDEM
	'MEX_FILIAL'																, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	FWSIZEFILIAL()															, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"FILIAL"																	, ; //X3_TITULO		// 'CRO'
	"FILIAL"																	, ; //X3_TITSPA		// 'CRO'
	"FILIAL"																	, ; //X3_TITENG		// 'CRO'
	"FILIAL"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"FILIAL"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"FILIAL"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	'033'																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'02'																		, ; //X3_ORDEM
	'MEX_ID'																   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Id"																		, ; //X3_TITULO		// 'CRO'
	"Id"																		, ; //X3_TITSPA		// 'CRO'
	"Id"																		, ; //X3_TITENG		// 'CRO'
	"Id"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Id"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Id"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME
	
aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'03'																		, ; //X3_ORDEM
	'MEX_FATHER'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Father"																	, ; //X3_TITULO		// 'CRO'
	"Father"																	, ; //X3_TITSPA		// 'CRO'
	"Father"																	, ; //X3_TITENG		// 'CRO'
	"Father"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Father"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Father"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'04'																		, ; //X3_ORDEM
	'MEX_TITLE'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Title"																	, ; //X3_TITULO		// 'CRO'
	"Title"																	, ; //X3_TITSPA		// 'CRO'
	"Title"																	, ; //X3_TITENG		// 'CRO'
	"Title"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Title"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Title"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'05'																		, ; //X3_ORDEM
	'MEX_DESC'																   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	70																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Desc"																		, ; //X3_TITULO		// 'CRO'
	"Desc"																		, ; //X3_TITSPA		// 'CRO'
	"Desc"																		, ; //X3_TITENG		// 'CRO'
	"Desc"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Desc"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Desc"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'06'																		, ; //X3_ORDEM
	'MEX_SOURCE'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Source"																		, ; //X3_TITULO		// 'CRO'
	"Source"																		, ; //X3_TITSPA		// 'CRO'
	"Source"																		, ; //X3_TITENG		// 'CRO'
	"Source"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Source"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Source"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'07'																		, ; //X3_ORDEM
	'MEX_MVIEW'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Micro view"																, ; //X3_TITULO		// 'CRO'
	"Micro view"																, ; //X3_TITSPA		// 'CRO'
	"Micro view"																, ; //X3_TITENG		// 'CRO'
	"Micro view"																, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Micro view"																, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Micro view"																, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'08'																		, ; //X3_ORDEM
	'MEX_OPER'																   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	1																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Oper"																		, ; //X3_TITULO		// 'CRO'
	"Oper"																		, ; //X3_TITSPA		// 'CRO'
	"Oper"																		, ; //X3_TITENG		// 'CRO'
	"Oper"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Oper"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Oper"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'09'																		, ; //X3_ORDEM
	'MEX_BCKOPR'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	1																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Bck Opr"																	, ; //X3_TITULO		// 'CRO'
	"Bck Opr"																	, ; //X3_TITSPA		// 'CRO'
	"Bck Opr"																	, ; //X3_TITENG		// 'CRO'
	"Bck Opr"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Bck Opr"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Bck Opr"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'10'																		, ; //X3_ORDEM
	'MEX_LOAD'																   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	100																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Load"																		, ; //X3_TITULO		// 'CRO'
	"Load"																		, ; //X3_TITSPA		// 'CRO'
	"Load"																		, ; //X3_TITENG		// 'CRO'
	"Load"																		, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Load"																		, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Load"																		, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'11'																		, ; //X3_ORDEM
	'MEX_ACTION'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	100																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Action"																	, ; //X3_TITULO		// 'CRO'
	"Action"																	, ; //X3_TITSPA		// 'CRO'
	"Action"																	, ; //X3_TITENG		// 'CRO'
	"Action"																	, ; //X3_DESCRIC 	// 'Contador Reinicio Op.'
	"Action"																	, ; //X3_DESCSPA 	// 'Contador Reinicio Op.'
	"Action"																	, ; //X3_DESCENG 	// 'Contador Reinicio Op.'
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'12'																		, ; //X3_ORDEM
	'MEX_ORDER'															   , ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	3																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Order"																	, ; //X3_TITULO		
	"Order"																	, ; //X3_TITSPA		
	"Order"																	, ; //X3_TITENG		
	"Order"																	, ; //X3_DESCRIC 	
	"Order"																	, ; //X3_DESCSPA 	
	"Order"																	, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'S'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'13'																		, ; //X3_ORDEM
	'MEX_PANEL'															   , ; //X3_CAMPO
	'L'																			, ; //X3_TIPO
	1																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Panel"																	, ; //X3_TITULO		
	"Panel"																	, ; //X3_TITSPA		
	"Panel"																	, ; //X3_TITENG		
	"Panel"																	, ; //X3_DESCRIC 	
	"Panel"																	, ; //X3_DESCSPA 	
	"Panel"																	, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'14'																		, ; //X3_ORDEM
	'MEX_LMENU'															   , ; //X3_CAMPO
	'L'																			, ; //X3_TIPO
	1																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Last Menu"																, ; //X3_TITULO		
	"Last Menu"																, ; //X3_TITSPA		
	"Last Menu"																, ; //X3_TITENG		
	"Last Menu"																, ; //X3_DESCRIC 	
	"Last Menu"																, ; //X3_DESCSPA 	
	"Last Menu"																, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME


aAdd( aSX3, { ;
	'MEX'																		, ; //X3_ARQUIVO
	'15'																		, ; //X3_ORDEM
	'MEX_SKIP'															   		, ; //X3_CAMPO
	'L'																			, ; //X3_TIPO
	1																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Pular"																	, ; //X3_TITULO		
	"Pular"																	, ; //X3_TITSPA		
	"Pular"																	, ; //X3_TITENG		
	"Pular"																	, ; //X3_DESCRIC 	
	"Pular"																	, ; //X3_DESCSPA 	
	"Pular"																	, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

// ---------------------------------------------------------------------------------------------------
// SL2
// ---------------------------------------------------------------------------------------------------
aAdd( aSX3, { ;
	'SL2'																		, ; //X3_ARQUIVO
	'ZZ'																		, ; //X3_ORDEM
	'L2_MESREC'														   		, ; //X3_CAMPO
	'N'																			, ; //X3_TIPO
	16																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Recno da tabela MES"													, ; //X3_TITULO		
	"Recno da tabela MES"													, ; //X3_TITSPA		
	"Recno da tabela MES"													, ; //X3_TITENG		
	"Recno da tabela MES"													, ; //X3_DESCRIC 	
	"Recno da tabela MES"													, ; //X3_DESCSPA 	
	"Recno da tabela MES"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

// ---------------------------------------------------------------------------------------------------
// SLR (Equivalencia da SL2)
// ---------------------------------------------------------------------------------------------------
aAdd( aSX3, { ;
	'SLR'																		, ; //X3_ARQUIVO
	'ZZ'																		, ; //X3_ORDEM
	'LR_MESREC'														   		, ; //X3_CAMPO
	'N'																			, ; //X3_TIPO
	16																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Recno da tabela MES"													, ; //X3_TITULO		
	"Recno da tabela MES"													, ; //X3_TITSPA		
	"Recno da tabela MES"													, ; //X3_TITENG		
	"Recno da tabela MES"													, ; //X3_DESCRIC 	
	"Recno da tabela MES"													, ; //X3_DESCSPA 	
	"Recno da tabela MES"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

	
// ---------------------------------------------------------------------------------------------------
// SLX LOG de cancelamento
// ---------------------------------------------------------------------------------------------------
aAdd( aSX3, { ;
	'SLX'																		, ; //X3_ARQUIVO
	'19'																		, ; //X3_ORDEM
	'LX_SITUA'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	2																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Situa็ใo"																	, ; //X3_TITULO		
	"Situa็ใo"																	, ; //X3_TITSPA		
	"Situa็ใo"																, ; //X3_TITENG		
	"Situa็ใo do registro"													, ; //X3_DESCRIC 	
	"Situa็ใo do registro"													, ; //X3_DESCSPA 	
	"Situa็ใo do registro"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME	

// ---------------------------------------------------------------------------------------------------
// SLI - MONITORAMENTO DAS ESTACOES
// ---------------------------------------------------------------------------------------------------
aAdd( aSX3, { ;
	'SLI'																		, ; //X3_ARQUIVO
	'ZZ'																		, ; //X3_ORDEM
	'LI_ALIAS'														   			, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"ALIAS"																		, ; //X3_TITULO		
	"ALIAS"																		, ; //X3_TITSPA		
	"ALIAS"																		, ; //X3_TITENG		
	"ALIAS"																		, ; //X3_DESCRIC 	
	"ALIAS"																		, ; //X3_DESCSPA 	
	"ALIAS"																		, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME		

aAdd( aSX3, { ;
	'SLI'																		, ; //X3_ARQUIVO
	'ZZ'																		, ; //X3_ORDEM
	'LI_UPREC'														   			, ; //X3_CAMPO
	'N'																			, ; //X3_TIPO
	16																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Recno"																		, ; //X3_TITULO		
	"Recno"																		, ; //X3_TITSPA		
	"Recno"																		, ; //X3_TITENG		
	"Recno"																		, ; //X3_DESCRIC 	
	"Recno"																		, ; //X3_DESCSPA 	
	"Recno"																		, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

aAdd( aSX3, { ;
	'SLI'																		, ; //X3_ARQUIVO
	'ZZ'																		, ; //X3_ORDEM
	'LI_FUNC'														   			, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	20																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Fun็ใo"																		, ; //X3_TITULO		
	"Fun็ใo"																		, ; //X3_TITSPA		
	"Fun็ใo"																		, ; //X3_TITENG		
	"Fun็ใo"																		, ; //X3_DESCRIC 	
	"Fun็ใo"																		, ; //X3_DESCSPA 	
	"Fun็ใo"																		, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	''																			, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME 
	
// ---------------------------------------------------------------------------------------------------
// MDU - Motivo de Desconto
// ---------------------------------------------------------------------------------------------------
aAdd( aSX3, { ;
	'MDU'																		, ; //X3_ARQUIVO
	'10'																		, ; //X3_ORDEM
	'MDU_OPERAD'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	3																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Operador"																	, ; //X3_TITULO		
	"Operador"																	, ; //X3_TITSPA		
	"Operador"																, ; //X3_TITENG		
	"Codigo do operador"													, ; //X3_DESCRIC 	
	"Codigo do operador"													, ; //X3_DESCSPA 	
	"Codigo do operador"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV																				, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME 
	
aAdd( aSX3, { ;
	'MDU'																		, ; //X3_ARQUIVO
	'11'																		, ; //X3_ORDEM
	'MDU_SITUA'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	2																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Situa็ใo"																	, ; //X3_TITULO		
	"Situa็ใo"																	, ; //X3_TITSPA		
	"Situa็ใo"																, ; //X3_TITENG		
	"Situa็ใo do Registro"													, ; //X3_DESCRIC 	
	"Situa็ใo do Registro"													, ; //X3_DESCSPA 	
	"Situa็ใo do Registro"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV	
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME

/*/
	MBR - Motivo de Venda Perdida	
/*/
aAdd( aSX3, { ;
	'MBR'																		, ; //X3_ARQUIVO
	'22'																		, ; //X3_ORDEM
	'MBR_SITUA'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	2																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Situa็ใo"																	, ; //X3_TITULO		
	"Situa็ใo"																	, ; //X3_TITSPA		
	"Situa็ใo"																, ; //X3_TITENG		
	"Situa็ใo do Registro"													, ; //X3_DESCRIC 	
	"Situa็ใo do Registro"													, ; //X3_DESCSPA 	
	"Situa็ใo do Registro"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME
	
aAdd( aSX3, { ;
	'MBR'																		, ; //X3_ARQUIVO
	'23'																		, ; //X3_ORDEM
	'MBR_PDV'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	10																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Numero PDV"																	, ; //X3_TITULO		
	"Numero PDV"																	, ; //X3_TITSPA		
	"Numero PDV"																, ; //X3_TITENG		
	"Numero do PDV"													, ; //X3_DESCRIC 	
	"Numero do PDV"													, ; //X3_DESCSPA 	
	"Numero do PDV"													, ; //X3_DESCENG 	
	'@!'																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	''																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'V'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME					

aAdd( aSX3, { ;
	'MBR'																		, ; //X3_ARQUIVO
	'24'																		, ; //X3_ORDEM
	'MBR_ORIGEM'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	8																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Origem"																	, ; //X3_TITULO		
	"Origem"																	, ; //X3_TITSPA		
	"Origem"																, ; //X3_TITENG		
	"M๓dulo de Origem"													, ; //X3_DESCRIC 	
	"M๓dulo de Origem"													, ; //X3_DESCSPA 	
	"M๓dulo de Origem"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME 
	
aAdd( aSX3, { ;
	'MBR'																		, ; //X3_ARQUIVO
	'26'																		, ; //X3_ORDEM
	'MBR_ESTACA'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	3																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Cod. Estacao"																	, ; //X3_TITULO		
	"Cod. Estacao"																	, ; //X3_TITSPA		
	"Cod. Estacao"																, ; //X3_TITENG		
	"C๓digo da Esta็ใo"													, ; //X3_DESCRIC 	
	"C๓digo da Esta็ใo"													, ; //X3_DESCSPA 	
	"C๓digo da Esta็ใo"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME	

/*/
	Regra de Desconto --> Desconto na pr๓xima venda
/*/	
aAdd( aSX3, { ;
	'MEI'																		, ; //X3_ARQUIVO
	'25'																		, ; //X3_ORDEM
	'MEI_DESCPR'														   		, ; //X3_CAMPO
	'C'																			, ; //X3_TIPO
	1																			, ; //X3_TAMANHO
	0																			, ; //X3_DECIMAL
	"Proxima Vend"																	, ; //X3_TITULO		
	"Proxima Vend"																	, ; //X3_TITSPA		
	"Proxima Vend"																, ; //X3_TITENG		
	"Desconto Proxima Venda"													, ; //X3_DESCRIC 	
	"Desconto Proxima Venda"													, ; //X3_DESCSPA 	
	"Desconto Proxima Venda"													, ; //X3_DESCENG 	
	''																			, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€ "															, ; //X3_USADO
	'"1"'																		, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	"1=Nao;2=Sim"																, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME
	
/*/
	Permissao do caixa --> Mแximo de desconto do total separado no Mแximo do Item
/*/	
aAdd( aSX3, { ;
	'SLF'																		, ; //X3_ARQUIVO
	'13'																		, ; //X3_ORDEM
	'LF_TOTDESP'														   		, ; //X3_CAMPO
	'N'																			, ; //X3_TIPO
	7																			, ; //X3_TAMANHO
	2																			, ; //X3_DECIMAL
	"Perc Total"																	, ; //X3_TITULO		
	"Perc Total"																	, ; //X3_TITSPA		
	"Perc Total"																, ; //X3_TITENG		
	"Perc Max. Desc. Total"													, ; //X3_DESCRIC 	
	"Perc Max. Desc. Total"													, ; //X3_DESCSPA 	
	"Perc Max. Desc. Total"												, ; //X3_DESCENG 	
	'@E 9,999.99'																, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME
	
aAdd( aSX3, { ;
	'SLF'																		, ; //X3_ARQUIVO
	'14'																		, ; //X3_ORDEM
	'LF_TOTDESV'														   		, ; //X3_CAMPO
	'N'																			, ; //X3_TIPO
	11																			, ; //X3_TAMANHO
	4																			, ; //X3_DECIMAL
	"Desc. Tot. V"																	, ; //X3_TITULO		
	"Desc. Tot. V"																	, ; //X3_TITSPA		
	"Desc. Tot. V"																, ; //X3_TITENG		
	"Valor Max. Desc. Total"													, ; //X3_DESCRIC 	
	"Valor Max. Desc. Total"													, ; //X3_DESCSPA 	
	"Valor Max. Desc. Total"												, ; //X3_DESCENG 	
	'@E 999,999.9999'																, ; //X3_PICTURE
	''																			, ; //X3_VALID
	"€€€€€€€€€€€€€€"															, ; //X3_USADO
	''																			, ; //X3_RELACAO
	''																			, ; //X3_F3
	0																			, ; //X3_NIVEL
	Chr(254) + Chr(192)															, ; //X3_RESERV
	''																			, ; //X3_CHECK
	''																			, ; //X3_TRIGGER
	'U'																			, ; //X3_PROPRI
	'N'																			, ; //X3_BROWSE
	'A'																			, ; //X3_VISUAL
	'R'																			, ; //X3_CONTEXT
	''																			, ; //X3_OBRIGAT
	''																			, ; //X3_VLDUSER
	''																			, ; //X3_CBOX
	''																			, ; //X3_CBOXSPA
	''																			, ; //X3_CBOXENG
	''																			, ; //X3_PICTVAR
	''																			, ; //X3_WHEN
	''																			, ; //X3_INIBRW
	''																			, ; //X3_GRPSXG
	''																			, ; //X3_FOLDER
	''																			} ) //X3_PYME	
	
		
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------
//
// Atualizando dicionario
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += STR0070 + aSX3[nI][nPosCpo] + STR0071 //"O tamanho do campo "###" nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
				cTexto += STR0072 + SX3->X3_GRPSXG + "]" + CRLF + CRLF //"   por pertencer ao grupo de campos ["
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += STR0073 + aSX3[nI][nPosCpo] + CRLF //"Criado o campo "

	Else

		//
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		//
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto +=  STR0070 + aSX3[nI][nPosCpo] + STR0071 //"O tamanho do campo "###" nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
					cTexto +=  STR0072 + SX3->X3_GRPSXG + "]" + CRLF + CRLF //"   por pertencer ao grupo de campos ["
				EndIf
			EndIf
		EndIf

		//
		// Verifica todos os campos
		//
		For nJ := 1 To Len( aSX3[nI] )

			//
			// Se o campo estiver diferente da estrutura
			//
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"

				cMsg := STR0074 + aSX3[nI][nPosCpo] + STR0075 + SX3->( FieldName( nJ ) ) + ; //"O campo "###" estแ com o "
				STR0076 + CRLF + ; //" com o conte๚do"
				"[" + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
				STR0077 + CRLF + ; //"que serแ substituido pelo NOVO conte๚do"
				"[" + RTrim( AllToChar( aSX3[nI][nJ] ) ) + "]" + CRLF + ;
				STR0078 //"Deseja substituir ? "

				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( STR0001, cMsg, { STR0079, STR0080, STR0081, STR0082 }, 3, STR0083 ) //"ATUALIZAวรO DE DICIONมRIOS E TABELAS"###"Sim"###"Nใo"###"Sim p/Todos"###"Nใo p/Todos"###"Diferen็a de conte๚do - SX3"
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := MsgNoYes( STR0084 + CRLF + STR0085 ) //"Foi selecionada a op็ใo de REALIZAR TODAS altera็๕es no SX3 e NรO MOSTRAR mais a tela de aviso."###"Confirma a a็ใo [Sim p/Todos] ?"
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := MsgNoYes( STR0086 + CRLF + STR0087 ) //"Foi selecionada a op็ใo de NรO REALIZAR nenhuma altera็ใo no SX3 que esteja diferente da base e NรO MOSTRAR mais a tela de aviso."###"Confirma esta a็ใo [Nใo p/Todos]?"
					EndIf

				EndIf

				If nOpcA == 1
					cTexto += STR0088 + aSX3[nI][nPosCpo] + CRLF //"Alterado o campo "
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + STR0089 + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF //" de ["
					cTexto += STR0090 + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF //"            para ["

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf

			EndIf

		Next

	EndIf

	oProcess:IncRegua2( STR0091 ) //"Atualizando Campos de Tabelas (SX3)..."

Next nI

AtuLK9()	// Atualizacao de tamanho de campo da LK9
cTexto += CRLF + STR0052 + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSIX บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SIX - Indices       ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSIX   - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += STR0045 + " SIX" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }


//
// Atualizando dicionแrio
//
             

//
// Tabela MBK
//
aAdd( aSIX, { ;
	'MES'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MES_FILIAL+MES_SEQ+MES_ESTACA+MES_TIPO'							, ; //CHAVE
	'MES_FILIAL+MES_SEQ+MES_ESTACA+MES_TIPO'							, ; //DESCRICAO	// 'No Or็amento'
	'MES_FILIAL+MES_SEQ+MES_ESTACA+MES_TIPO'							, ; //DESCSPA	// 'No Or็amento'
	'MES_FILIAL+MES_SEQ+MES_ESTACA+MES_TIPO'							, ; //DESCENG	// 'No Or็amento'
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

//
// Tabela MET
//
aAdd( aSIX, { ;
	'MET'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MET_FILIAL+MET_PROCES'												, ; //CHAVE
	'MET_FILIAL+MET_PROCES'												, ; //DESCRICAO	
	'MET_FILIAL+MET_PROCES'												, ; //DESCSPA	
	'MET_FILIAL+MET_PROCES'												, ; //DESCENG	
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ


//
// Tabela SLX
//
aAdd( aSIX, { ;
	'SLX'																	, ; //INDICE
	'3'																		, ; //ORDEM
	'LX_FILIAL+LX_SITUA'													, ; //CHAVE
	'LX_FILIAL+LX_SITUA'													, ; //DESCRICAO	
	'LX_FILIAL+LX_SITUA'													, ; //DESCSPA	
	'LX_FILIAL+LX_SITUA'													, ; //DESCENG	
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ	

//
// Tabela SLI
//
aAdd( aSIX, { ;
	'SLI'																	, ; //INDICE
	'2'																		, ; //ORDEM
	'LI_FILIAL+LI_TIPO'													, ; //CHAVE
	'LI_FILIAL+LI_TIPO'													, ; //DESCRICAO	
	'LI_FILIAL+LI_TIPO'													, ; //DESCSPA	
	'LI_FILIAL+LI_TIPO'													, ; //DESCENG	
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ	
	
//
// Tabela MEX
//
aAdd( aSIX, { ;
	'MEX'																	, ; //INDICE
	'1'																		, ; //ORDEM
	'MEX_FILIAL+MEX_ID'													, ; //CHAVE
	'Filial + Id'															, ; //DESCRICAO	
	'Filial + Id'															, ; //DESCSPA	
	'Filial + Id'															, ; //DESCENG	
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'N'																		} ) //SHOWPESQ

oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( "SIX", .T. )
		lDelInd := .F.
		cTexto += STR0100 + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF //"อndice criado "
	Else
		lAlt := .F.
		RecLock( "SIX", .F. )
	EndIf

	If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
		aAdd( aArqUpd, aSIX[nI][1] )

		If lAlt
			lDelInd := .T. // Se for alteracao precisa apagar o indice do banco
			cTexto += STR0101 + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF //"อndice alterado "
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( STR0102 ) //"Atualizando ํndices..."

Next nI

cTexto += CRLF + STR0052 + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX6 บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX6 - Parโmetros    ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX6   - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

cTexto  += STR0045 + " SX6" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }

/*/
	Parโmetro Motivo de Desconto via Regra de Desconto
/*/
aAdd( aSX6, { ;
	'  '																	, ; //X6_FIL
	'MV_LJMDRD'																, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	"Motivo de Desconto Via Regra de Desconto"								, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	''																		, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	''																	, ; //X6_CONTEUD
	''																	, ; //X6_CONTSPA
	''																	, ; //X6_CONTENG
	'U'																		, ; //X6_PROPRI
	''																		} ) //X6_PYME

//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lContinua := .F.
	lReclock  := .F.

	If !SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lContinua := .T.
		lReclock  := .T.
		cTexto += STR0108 + aSX6[nI][1] + aSX6[nI][2] + STR0109 + AllTrim( aSX6[nI][13] ) + "]"+ CRLF //"Foi incluํdo o parโmetro "###" Conte๚do ["
	Else
		lContinua := .T.
		lReclock  := .F.
		If !StrTran( SX6->X6_CONTEUD, " ", "" ) == StrTran( aSX6[nI][13], " ", "" )

			cMsg := STR0110 + aSX6[nI][2] + STR0111 + CRLF + ; //"O parโmetro "###" estแ com o conte๚do"
			"[" + RTrim( StrTran( SX6->X6_CONTEUD, " ", "" ) ) + "]" + CRLF + ;
			STR0112 + CRLF + ; //", que ้ serแ substituido pelo NOVO conte๚do "
			"[" + RTrim( StrTran( aSX6[nI][13]   , " ", "" ) ) + "]" + CRLF + ;
			STR0078 //"Deseja substituir ? "

			If      lTodosSim
				nOpcA := 1
			ElseIf  lTodosNao
				nOpcA := 2
			Else
				nOpcA := Aviso( STR0001, cMsg, { STR0079, STR0080, STR0081, STR0082 }, 3, STR0113 ) //"ATUALIZAวรO DE DICIONมRIOS E TABELAS"###"Sim"###"Nใo"###"Sim p/Todos"###"Nใo p/Todos"###"Diferen็a de conte๚do - SX6"
				lTodosSim := ( nOpcA == 3 )
				lTodosNao := ( nOpcA == 4 )

				If lTodosSim
					nOpcA := 1
					lTodosSim := MsgNoYes( STR0114 + CRLF + STR0085 ) //"Foi selecionada a op็ใo de REALIZAR TODAS altera็๕es no SX6 e NรO MOSTRAR mais a tela de aviso."###"Confirma a a็ใo [Sim p/Todos] ?"
				EndIf

				If lTodosNao
					nOpcA := 2
					lTodosNao := MsgNoYes( STR0115 + CRLF + STR0087 ) //"Foi selecionada a op็ใo de NรO REALIZAR nenhuma altera็ใo no SX6 que esteja diferente da base e NรO MOSTRAR mais a tela de aviso."###"Confirma esta a็ใo [Nใo p/Todos]?"
				EndIf

			EndIf

			lContinua := ( nOpcA == 1 )

			If lContinua
				cTexto += STR0116 + aSX6[nI][1] + aSX6[nI][2] + STR0089 + ; //"Foi alterado o parโmetro "###" de ["
				AllTrim( SX6->X6_CONTEUD ) + "]" + STR0117 + AllTrim( aSX6[nI][13] ) + "]" + CRLF //" para ["
			EndIf

		Else
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf

		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
	EndIf

	oProcess:IncRegua2( STR0118 ) //"Atualizando Arquivos (SX6)..."

Next nI

cTexto += CRLF + STR0052 + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAtuSX1 บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX1 - Perguntas     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAtuSX1   - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAtuSX1( cTexto )
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

cTexto  += STR0119 + cAlias + CRLF + CRLF //"Inicio Atualizacao "

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }


//
// Perguntas PLUPROD
//
aAdd( aSX1, { ;
	'PLUPROD'																, ; //X1_GRUPO
	'01'																	, ; //X1_ORDEM
	STR0120																	, ; //X1_PERGUNT //'Do Produto'
	''																		, ; //X1_PERSPA
	''																		, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	15																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	'ExistCpo("SB1") .and. NaoVazio()'										, ; //X1_VALID
	'MV_PAR01'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'0000012'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SB1'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'PLUPROD'																, ; //X1_GRUPO
	'02'																	, ; //X1_ORDEM
	STR0121																	, ; //X1_PERGUNT //'Ate Produto'
	''																		, ; //X1_PERSPA
	''																		, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'C'																		, ; //X1_TIPO
	15																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	0																		, ; //X1_PRESEL
	'G'																		, ; //X1_GSC
	'ExistCpo("SB1") .and. NaoVazio()'										, ; //X1_VALID
	'MV_PAR02'																, ; //X1_VAR01
	''																		, ; //X1_DEF01
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	'0000012'																, ; //X1_CNT01
	''																		, ; //X1_VAR02
	''																		, ; //X1_DEF02
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	'SB1'																	, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL

aAdd( aSX1, { ;
	'PLUPROD'																, ; //X1_GRUPO
	'03'																	, ; //X1_ORDEM
	STR0122																	, ; //X1_PERGUNT //'Importar'
	''																		, ; //X1_PERSPA
	''																		, ; //X1_PERENG
	'MV_CH0'																, ; //X1_VARIAVL
	'N'																		, ; //X1_TIPO
	1																		, ; //X1_TAMANHO
	0																		, ; //X1_DECIMAL
	2																		, ; //X1_PRESEL
	'C'																		, ; //X1_GSC
	''																		, ; //X1_VALID
	'MV_PAR03'																, ; //X1_VAR01
	STR0123																	, ; //X1_DEF01 //'Produto'
	''																		, ; //X1_DEFSPA1
	''																		, ; //X1_DEFENG1
	''																		, ; //X1_CNT01
	''																		, ; //X1_VAR02
	STR0124																	, ; //X1_DEF02 //'Preco'
	''																		, ; //X1_DEFSPA2
	''																		, ; //X1_DEFENG2
	''																		, ; //X1_CNT02
	''																		, ; //X1_VAR03
	''																		, ; //X1_DEF03
	''																		, ; //X1_DEFSPA3
	''																		, ; //X1_DEFENG3
	''																		, ; //X1_CNT03
	''																		, ; //X1_VAR04
	''																		, ; //X1_DEF04
	''																		, ; //X1_DEFSPA4
	''																		, ; //X1_DEFENG4
	''																		, ; //X1_CNT04
	''																		, ; //X1_VAR05
	''																		, ; //X1_DEF05
	''																		, ; //X1_DEFSPA5
	''																		, ; //X1_DEFENG5
	''																		, ; //X1_CNT05
	''																		, ; //X1_F3
	''																		, ; //X1_PYME
	''																		, ; //X1_GRPSXG
	''																		, ; //X1_HELP
	''																		, ; //X1_PICTURE
	''																		} ) //X1_IDFIL




//
// Atualizando dicionแrio
//
oProcess:SetRegua2( Len( aSX1 ) )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

	oProcess:IncRegua2( STR0125 ) //"Atualizando perguntas..."

	If !SX1->( dbSeek( PadR( aSX1[nI][1], nTam1 ) + PadR( aSX1[nI][2], nTam2 ) ) )
		cTexto +=  STR0126  + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF //"Pergunta Criada. Grupo/Ordem "
		RecLock( "SX1", .T. )
	Else
		cTexto +=  STR0127 + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF //"Pergunta Alterada. Grupo/Ordem "
		RecLock( "SX1", .F. )
	EndIf

	For nJ := 1 To Len( aSX1[nI] )
		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
			SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
		EndIf
	Next nJ

	MsUnLock()

Next nI

cTexto += CRLF + STR0052 + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณESCEMPRESAบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Generica para escolha de Empresa, montado pelo SM0_ บฑฑ
ฑฑบ          ณ Retorna vetor contendo as selecoes feitas.                 บฑฑ
ฑฑบ          ณ Se nao For marcada nenhuma o vetor volta vazio.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EscEmpresa()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Parametro  nTipo                           ณ
//ณ 1  - Monta com Todas Empresas/Filiais      ณ
//ณ 2  - Monta so com Empresas                 ณ
//ณ 3  - Monta so com Filiais de uma Empresa   ณ
//ณ                                            ณ
//ณ Parametro  aMarcadas                       ณ
//ณ Vetor com Empresas/Filiais pre marcadas    ณ
//ณ                                            ณ
//ณ Parametro  cEmpSel                         ณ
//ณ Empresa que sera usada para montar selecao ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := STR0128 //"Tela para M๚ltiplas Sele็๕es de Empresas/Filiais"

oDlg:cTitle   := STR0129 //"Selecione a(s) Empresa(s) para Atualiza็ใo"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", STR0130 Size 178, 095 Of oDlg Pixel //"Empresa"
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt STR0131   Message  Size 40, 007 Pixel Of oDlg; //"Todos"
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt STR0132  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Inverter"
Message STR0133 Of oDlg //"Inverter Sele็ใo"

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt STR0130 Size  40, 08 Of oDlg Pixel //"Empresa"
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message STR0134  Of oDlg //"Mแscara Empresa ( ?? )"
@ 123, 50 Button oButMarc Prompt STR0135    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Marcar"
Message STR0136    Of oDlg //"Marcar usando mแscara ( ?? )"
@ 123, 80 Button oButDMar Prompt STR0137 Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Desmarcar"
Message STR0138 Of oDlg //"Desmarcar usando mแscara ( ?? )"

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop STR0139  Enable Of oDlg //"Confirma a Sele็ใo"
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop STR0140 Enable Of oDlg //"Abandona a Sele็ใo"
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณMARCATODOSบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar para marcar/desmarcar todos os itens do    บฑฑ
ฑฑบ          ณ ListBox ativo                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณINVSELECAOบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar para inverter selecao do ListBox Ativo     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณRETSELECAOบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Auxiliar que monta o retorno com as selecoes        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ MARCAMAS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao para marcar/desmarcar usando mascaras               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบRotina    ณ VERTODOS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar para verificar se estao todos marcardos    บฑฑ
ฑฑบ          ณ ou nao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ MyOpenSM0บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento abertura do SM0 modo exclusivo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ MyOpenSM0  - Gerado por COMPADIC / Upd. V.4.10.4 EFS       ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( STR0141 + ; //"Nใo foi possํvel a abertura da tabela "
	IIf( lShared, STR0142, STR0143 ), STR0025 ) //"de empresas (SM0)."###"de empresas (SM0) de forma exclusiva."###"ATENวรO"
EndIf

Return lOpen


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ AtuLK9	บ Autor ณ TOTVS Protheus     บ Data ณ  12/06/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Atualiza o tamanho do campo LK9_DOC                 		  ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ Integracao Protheus x SIAC								  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtuLK9()
	DbSelectArea("SX3")
	dbSetOrder(2)
	If SX3->(DbSeek("LK9_DOC"))
		RecLock("SX3", .F.)
		SX3->X3_TAMANHO := 9
		MsUnlock()
		X31UpdTable("MES")
		X31UpdTable("MEX")
		X31UpdTable("MET")
		X31UpdTable("SL2")
	Else
		Alert("Campo LK9_DOC nใo encontrado! Verifique se o template Drogaria estแ aplicado.")
	EndIf	
Return 


Static Function RetSqlName(cPar)
Return cPar + "990"



