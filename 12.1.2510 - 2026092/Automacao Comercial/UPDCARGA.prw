#INCLUDE "PROTHEUS.CH"
#INCLUDE "UPDCARGA.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

Static lSM0Open := .F.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Programa ณ UPDCARGA บ Autor ณ TOTVS Protheus     บ Data ณ  14/11/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de update dos dicionแrios para compatibiliza็ใo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ UPDCARGA   - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function UPDCARGA( cEmpAmb, cFilAmb )
Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := STR0001 //"FACILITADOR PARA CAMPOS DA CARGA"     
Local   cDesc1    := STR0002 //"Este processo deve ser executado em modo EXCLUSIVO, ou seja nใo podem haver outros"
Local   cDesc2    := STR0003 //"usuแrios  ou  jobs utilizando  o sistema.  ษ extremamente recomendแvel  que  se  fa็a um"
Local   cDesc3    := STR0004 //"BACKUP  dos DICIONมRIOS  e da  BASE DE DADOS antes desta atualiza็ใo, para que caso "
Local   cDesc4    := STR0005 //"Confirma a atualiza็ใo dos dicionแrios ?"
Local   cDesc5    := STR0006 //"ocorra eventuais falhas, esse backup seja ser restaurado." #13
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
		If lAuto .OR. MsgNoYes( STR0006, cTitulo ) //"Confirma a atualiza็ใo dos dicionแrios ?"
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, STR0007, STR0012, .F. ) //"Atualizando"###"Aguarde, atualizando ..."
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( STR0008, "UPDCARGA" ) //"Atualiza็ใo Realizada."
					dbCloseAll()
				Else
					MsgStop( STR0010, "UPDCARGA" ) //"Atualiza็ใo nใo Realizada."
					dbCloseAll()
				EndIf
			Else
				If lOk
					Final( STR0009 ) //"Atualiza็ใo Concluํda."
				Else
					Final( STR0010 ) //"Atualiza็ใo nใo Realizada."
				EndIf
			EndIf

		Else
			MsgStop( STR0010, "UPDCARGA" ) //"Atualiza็ใo nใo Realizada."
		EndIf

	Else
		MsgStop( STR0010, "UPDCARGA" ) //"Atualiza็ใo nใo Realizada."
	EndIf

EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Programa ณ FSTProc  บ Autor ณ TOTVS Protheus     บ Data ณ  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da grava็ใo dos arquivos           ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSTProc    - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := STR0011 + "(*.TXT)|*.txt|" //"Arquivos Texto"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL
Local   cArquivo  := ""   

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
				MsgStop( STR0013 + aRecnoSM0[nI][2] + STR0014 ) //"Atualiza็ใo da empresa "###" nใo efetuada."
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL ,,,"FRT" )
			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += STR0015 + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF //"Empresa : "

			oProcess:SetRegua1( 8 )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o dicionแrio SX3         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
			LjAjsCarga( @cTexto, @cArquivo )		

			oProcess:IncRegua1( STR0018 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionแrio de dados"
			oProcess:IncRegua2( STR0019 ) //"Atualizando campos/ํndices"

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If ExistFunc(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf			

			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)

			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += STR0026 + CRLF //"LOG DA ATUALIZACAO DOS DICIONมRIOS"
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += STR0027 + CRLF //" Dados Ambiente"
			cAux += " --------------------"  + CRLF
			cAux += STR0028 + cEmpAnt + "/" + cFilAnt  + CRLF //" Empresa / Filial...: "
			cAux += STR0029 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF //" Nome Empresa.......: "
			cAux += STR0030 + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF //" Nome Filial........: "
			cAux += STR0031 + DtoC( dDataBase )  + CRLF //" DataBase...........: "
			cAux += STR0032 + DtoC( Date() )  + " / " + Time()  + CRLF //" Data / Hora Inicio.: "
			cAux += STR0033 + GetEnvServer()  + CRLF //" Environment........: "
			cAux += STR0034 + GetSrvProfString( "StartPath", "" )  + CRLF //" StartPath..........: "
			cAux += STR0035 + GetSrvProfString( "RootPath" , "" )  + CRLF //" RootPath...........: "
			cAux += STR0036 + GetVersao(.T.)  + CRLF //" Versao.............: "
			cAux += STR0037 + __cUserId + " " +  cUserName + CRLF //" Usuario TOTVS .....: "
			cAux += STR0038 + GetComputerName() + CRLF //" Computer Name......: "

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += STR0039 + CRLF //" Dados Thread"
				cAux += " --------------------"  + CRLF
				cAux += STR0040 + aInfo[nPos][1] + CRLF //" Usuario da Rede....: "
				cAux += STR0041 + aInfo[nPos][2] + CRLF //" Estacao............: "
				cAux += STR0042 + aInfo[nPos][5] + CRLF //" Programa Inicial...: "
				cAux += STR0033 + aInfo[nPos][6] + CRLF //" Environment........: "
				cAux += STR0043 + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF //" Conexao............: "
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF

			cTexto := cAux + cTexto + CRLF

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += STR0044 + DtoC( Date() ) + " / " + Time()  + CRLF //" Data / Hora Final.: "
			cTexto += Replicate( "-", 128 ) + CRLF

			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title STR0045 From 3, 0 to 340, 417 Pixel //"Atualizacao concluida."

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

If lret 
	FwAlertSuccess( STR0110 + cArquivo + STR0111 , "" ) // Foi gerado o aquivo  // , ้ necessแrio executar o UpdDistr para ajustar os campos.
EndIf 

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Programa ณ LjAjsCarga บ Autor ณ TOTVS Protheus   บ Data ณ  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX3 - Campos        ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ LjAjsCarga - Ajuste para novo Metodo/Upd. V.4.10.4 EFS     ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
 
Static Function LjAjsCarga( cTexto , cArquivo )  
Local aEstrut   := {}
Local aSX3M     := {}
Local aSX3H     := {}
Local aTabelasLJ:= {}
Local aTabTplDRO:= {}
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local nI        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nCountTabLJ := 0
Local lCfgTrib  := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.) //Verifica se Configurador de Tributos esta habilitado
Local oX31    	:= Nil
Local cCodPrj   := ""
Local cPath  	:= "\systemload\"
local nSetAlias := 0
local nSetField := 0
local nSetType  := 0
local nSetSize  := 0
local nDecimal  := 0									
local nSetTitle  := 0
local nSTitleSpa := 0
local nSTitleEng := 0
local nDescri    := 0
local nDescriSpa  := 0
local nDescriEng  := 0
local nSetPicture := 0
local nSetValid   := 0
local nSetIniPad  := 0
local nSetF3      := 0
local nSetLevel   := 0
local ncBrowse 	  := 0
local nSetBox     := 0
local ncReserv    := 0
local nSetObriga  := 0
local nSetUsed    := 0
local nSetBoxSpa  := 0
local nSetBoxEng  := 0
local nSetWhen    := 0
local nSetGroup   := 0
local ncFolder    := 0 


cTexto  += STR0046 + " SX3" + CRLF + CRLF //"Inicio da Atualizacao"

aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }

//
//Adiciona campos MSEXP e HREXP para as tabelas padroes do Loja
//
aTabelasLJ := {	"SB1", "SB0", "SLH", "SBZ", "SM2", "SA1", "SA3", "SA6", "SAE", "SAF",;
				"SBI", "SB2", "SE4", "SED", "SF4", "SF7", "SFB", "SFC", "SFE", "SFF",;
				"SFP", "SFH", "SFZ", "SLF", "SLG", "SLK", "SFM", "ACO", "ACP", "DA0",;
				"DA1", "ACQ", "ACR", "SL6", "SL8", "SLD", "SL7", "SUG", "SUH", "SU1",;
				"MDE", "MBS", "MBT", "MEN", "MEK", "MEI", "MEJ", "MB2", "MB3", "MB4",;
				"MB5", "MB6", "MB7", "MB8", "CLK", "MEU", "MEV", "CC2", "AI0", "MBF",;
				"MBL", "MG7", "MG8", "MGB", "MGC", "MHI", "MHW", "F3K", "CDY", "CC6",;
				"CC7", "CC8", "CCE", "CE0" }

//Configurador de Tributos
If lCfgTrib
	aAdd(aTabelasLJ, "CIN")
	aAdd(aTabelasLJ, "CIO")	
	aAdd(aTabelasLJ, "CIQ")
	aAdd(aTabelasLJ, "CIR")
	aAdd(aTabelasLJ, "CIS")
	aAdd(aTabelasLJ, "CIT")
	aAdd(aTabelasLJ, "CIU")
	aAdd(aTabelasLJ, "CIV")
	aAdd(aTabelasLJ, "CIX")
	aAdd(aTabelasLJ, "CIY")
	aAdd(aTabelasLJ, "CJ0")
	aAdd(aTabelasLJ, "CJ1")
	aAdd(aTabelasLJ, "CJ2")
	aAdd(aTabelasLJ, "CJ4")
	aAdd(aTabelasLJ, "CJ5")
	aAdd(aTabelasLJ, "CJ6")
	aAdd(aTabelasLJ, "CJ7")
	aAdd(aTabelasLJ, "CJ8")
	aAdd(aTabelasLJ, "CJ9")
	aAdd(aTabelasLJ, "CJA")
	aAdd(aTabelasLJ, "CJL")
	aAdd(aTabelasLJ, "F20")
	aAdd(aTabelasLJ, "F21")
	aAdd(aTabelasLJ, "F22")
	aAdd(aTabelasLJ, "F23")
	aAdd(aTabelasLJ, "F24")
	aAdd(aTabelasLJ, "F25")
	aAdd(aTabelasLJ, "F26")
	aAdd(aTabelasLJ, "F27")
	aAdd(aTabelasLJ, "F28")
	aAdd(aTabelasLJ, "F29")
	aAdd(aTabelasLJ, "F2A")
	aAdd(aTabelasLJ, "F2B")
	aAdd(aTabelasLJ, "F2C")
	aAdd(aTabelasLJ, "F2E")
	aAdd(aTabelasLJ, "F2F")
EndIf

If ExistFunc("LjIsDro") .And. LjIsDro()
	aTabTplDRO :=	{"MHA", "MHB", "MHC", "MHD", "MHE", "MHF", "MHG",; 
					"LIP", "LK9", "LEO", "LFX", "LHU", "LJU", "LJG",;
					"LHV", "LIO", "LJ2", "LHH", "LHG", "LKA", "LKB",;
					"LKD", "LFW", "LHF", "SLZ", "MA6"}
	
	For nI := 1 to Len(aTabTplDRO)
        Aadd(aTabelasLJ,aTabTplDRO[nI])
    Next nI
EndIf

For nCountTabLJ := 1 to Len(aTabelasLJ)
	FSAddMSEXP(@aSX3M, aTabelasLJ[nCountTabLJ]) //adiciona campo MSEXP na tabela
	FSAddHREXP(@aSX3H, aTabelasLJ[nCountTabLJ]) //adiciona campo HREXP na tabela
Next nCountTabLJ

//
// Atualizando dicionแrio
//

nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3M,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )
aSort( aSX3H,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oX31 := MPX31Field():New(STR0075)   //Atualizando Campos de Tabelas (SX3)...

DbSelectArea( "SX3" )
SX3->(DbSetOrder(2))
cAliasAtu := ""

oProcess:SetRegua2( Len( aSX3M ) )

nSetAlias   := aScan(aEstrut,{|x|x=="X3_ARQUIVO"})  
nSetField   := aScan(aEstrut,{|x|x=="X3_CAMPO"})   
nSetType    := aScan(aEstrut,{|x|x=="X3_TIPO"})  
nSetSize    := aScan(aEstrut,{|x|x=="X3_TAMANHO"})    
nDecimal    := aScan(aEstrut,{|x|x=="X3_DECIMAL"}) 								
nSetTitle   := aScan(aEstrut,{|x|x=="X3_TITULO"})  
nSTitleSpa  := aScan(aEstrut,{|x|x=="X3_TITSPA"})  
nSTitleEng  := aScan(aEstrut,{|x|x=="X3_TITENG"})  
nDescri     := aScan(aEstrut,{|x|x=="X3_DESCRIC"}) 
nDescriSpa  := aScan(aEstrut,{|x|x=="X3_DESCSPA"})  
nDescriEng  := aScan(aEstrut,{|x|x=="X3_DESCENG"}) 
nSetPicture := aScan(aEstrut,{|x|x=="X3_PICTURE"})   
nSetValid   := aScan(aEstrut,{|x|x=="X3_VALID"}) 
nSetIniPad  := aScan(aEstrut,{|x|x=="X3_RELACAO"})
nSetF3      := aScan(aEstrut,{|x|x=="X3_F3"}) 
nSetLevel   := aScan(aEstrut,{|x|x=="X3_NIVEL"})
ncBrowse 	:= aScan(aEstrut,{|x|x=="X3_BROWSE"}) 
nSetBox     := aScan(aEstrut,{|x|x=="X3_CBOX"})   
ncReserv    := aScan(aEstrut,{|x|x=="X3_RESERV"}) 
nSetObriga  := aScan(aEstrut,{|x|x=="X3_OBRIGAT"})
nSetUsed    := aScan(aEstrut,{|x|x=="X3_USADO"}) 
nSetBoxSpa  := aScan(aEstrut,{|x|x=="X3_CBOXSPA"})  
nSetBoxEng  := aScan(aEstrut,{|x|x=="X3_CBOXENG"})  
nSetWhen    := aScan(aEstrut,{|x|x=="X3_WHEN"}) 
nSetGroup   := aScan(aEstrut,{|x|x=="X3_GRPSXG"})  
ncFolder    := aScan(aEstrut,{|x|x=="X3_FOLDER"}) 

For nI := 1 To Len( aSX3M )
	If !SX3->(DbSeek(aSX3M[nI][nSetField] ))
		oX31:CreateReserv(4)
		oX31:SetAlias( aSX3M[nI][ nSetAlias ] )
		oX31:SetField( aSX3M[nI][ nSetField ] ) 
		
		If oX31:VldData()
			oX31:CommitData()				
		EndIf

		cTexto += STR0056 + aSX3M[nI][nPosCpo] + CRLF //"Criado o campo "
	EndIf 	

	oProcess:IncRegua2( STR0075 ) //"Atualizando Campos de Tabelas (SX3)..."
Next nI

oProcess:SetRegua2( Len( aSX3H ) )

For nI := 1 To Len( aSX3H )

	//
	// Busca ultima ocorrencia do alias
	//
	If ( aSX3H[nI][nPosArq] <> cAliasAtu )
		cSeqAtu   := "00"
		cAliasAtu := aSX3H[nI][nPosArq]

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
	
	Conout("Insercao - campo:" + aSX3H[nI][ aScan(aEstrut,{|x|x=="X3_CAMPO"}) ] )
	
	oX31:SetAlias( aSX3H[nI][ nSetAlias ] )
	oX31:SetField( aSX3H[nI][ nSetField ] ) 
	oX31:SetType( aSX3H[nI][ nSetType ] )
	oX31:SetSize(aSX3H[nI][ nSetSize ] , aSX3H[nI][ nDecimal ] )
	oX31:cOrder := cSeqAtu										//X3_ORDEM	
	oX31:SetTitle( aSX3H[nI][ nSetTitle ] )
	oX31:SetTitleSpa( aSX3H[nI][ nSTitleSpa ] )
	oX31:SetTitleEng( aSX3H[nI][ nSTitleEng ] )
	oX31:cDescri    := aSX3H[nI][ nDescri ]
	oX31:cDescriSpa := aSX3H[nI][ nDescriSpa ] 
	oX31:cDescriEng := aSX3H[nI][ nDescriEng ]
	oX31:SetPicture( aSX3H[nI][ nSetPicture ] ) 
	oX31:SetValid( aSX3H[nI][ nSetValid ])
	oX31:SetIniPad( aSX3H[nI][ nSetIniPad ])			
	oX31:SetF3( aSX3H[nI][ nSetF3 ])
	oX31:SetLevel( aSX3H[nI][ nSetLevel ])
	oX31:cBrowse 	:= aSX3H[nI][ ncBrowse ]
	oX31:SetBox( aSX3H[nI][nSetBox ] ) 
	oX31:cReserv    := aSX3H[nI][ ncReserv ]		
	oX31:SetObrigat( aSX3H[nI][ nSetObriga ] )
	oX31:SetUsed( aSX3H[nI][ nSetUsed ]  )
	oX31:SetBoxSpa( aSX3H[nI][ nSetBoxSpa ] )
	oX31:SetBoxEng( aSX3H[nI][ nSetBoxEng ] )
	oX31:SetWhen( aSX3H[nI][ nSetWhen ] )
	oX31:SetGroup( aSX3H[nI][ nSetGroup ] )
	oX31:cFolder    := aSX3H[nI][ ncFolder ]
	oX31:SetOverWrite(.T.) 
	
	If oX31:VldData()
		oX31:CommitData()	
	EndIf
	
	cTexto += STR0056 + aSX3H[nI][nPosCpo] + CRLF //"Criado o campo "	

	oProcess:IncRegua2( STR0075 ) //"Atualizando Campos de Tabelas (SX3)..."

Next nI

//-- Gera SDF para aplica็ใo via UPDDISTR

cCodPrj := oX31:oPrjResult:cCodProj
FWGnFlByTp(cCodPrj, cPath)
cArquivo := "sdf" +	Lower(cPaisLoc) + ".txt"
If File(cPath + cArquivo )
	cTexto += CRLF
	cTexto += STR0106+CRLF  //"Arquivo SDF exportado com sucesso para a pasta systemload."
	cTexto += STR0107+CRLF  //"Ao finalizar o Assistente de cria็ใo de Moedas, os proximo passos:"+CRLF
	cTexto += STR0108+CRLF //"-Executar a fun็ใo UPDDISTR para atualiza็ใo do dicionario de dados!"+CRLF
	cTexto += CRLF
	cTexto += STR0109+CRLF //"Pressione o botใo 'OK' para concluir o processamento!"+CRLF 	
EndIf

cTexto += CRLF + STR0051 + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF //"Final da Atualizacao"

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบRotina    ณESCEMPRESAบAutor  ณ Ernani Forastieri  บ Data ณ  27/09/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao Generica para escolha de Empresa, montado pelo SM0_ บฑฑ
ฑฑบ          ณ Retorna vetor contendo as selecoes feitas.                 บฑฑ
ฑฑบ          ณ Se nao For marcada nenhuma o vetor volta vazio.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
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

oDlg:cToolTip := STR0086 //"Tela para M๚ltiplas Sele็๕es de Empresas/Filiais"

oDlg:cTitle   := STR0087 //"Selecione a(s) Empresa(s) para Atualiza็ใo"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", STR0088 Size 178, 095 Of oDlg Pixel //"Empresa"
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt STR0089   Message  Size 40, 007 Pixel Of oDlg; //"Todos"###"Marca / Desmarca Todos" // STR0090
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt STR0091  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Inverter"
Message STR0092 Of oDlg //"Inverter Sele็ใo"

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt STR0088 Size  40, 08 Of oDlg Pixel //"Empresa"
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message STR0093  Of oDlg //"Mแscara Empresa ( ?? )"
@ 123, 50 Button oButMarc Prompt STR0094    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Marcar"
Message STR0095    Of oDlg //"Marcar usando mแscara ( ?? )"
@ 123, 80 Button oButDMar Prompt STR0102 Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Desmarcar"
Message STR0096 Of oDlg //"Desmarcar usando mแscara ( ?? )"

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop STR0097  Enable Of oDlg //"Confirma a Sele็ใo"
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop STR0098 Enable Of oDlg //"Abandona a Sele็ใo"
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

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบRotina    ณ VERTODOS บAutor  ณ Ernani Forastieri  บ Data ณ  20/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao auxiliar para verificar se estao todos marcardos    บฑฑ
ฑฑบ          ณ ou nao                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบ Programa ณ MyOpenSM0บ Autor ณ TOTVS Protheus     บ Data ณ  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento abertura do SM0 modo exclusivo     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.10.4 EFS       ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

OpenSM0()

If !lSM0Open
	dbSelectArea( "SM0" )
    SM0->(dbGoTop())
    RpcSetType( 3 )
    RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL ,,, "FRT") //Uso essa fun็ใo para setar o cEmpAnt/cFilAnt
    lSM0Open := .T.
EndIf

For nLoop := 1 To 20
	dbSelectArea( "SM0" )
	If !Empty( Select( "SM0" ) ) .And. SoftLock("SM0")
		MsUnLockAll()
		lOpen := .T.
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( STR0099 + ; //"Nใo foi possํvel a abertura da tabela "
	IIf( lShared, STR0100, STR0101 ), STR0022 ) //"de empresas (SM0)."###"de empresas (SM0) de forma exclusiva."###"ATENวรO"
EndIf

Return lOpen

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบProgramaณ FSAddMSEXP บ Autor ณ TOTVS Protheus     บ Data ณ  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX2 - Arquivos      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAddMSEXP   -      										  ณฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FSAddMSEXP( aSX3, cAlias )
Local cPrefixo := If(SubStr(cAlias,1,1) == "S", SubStr(cAlias,2,3), cAlias)

aAdd( aSX3, { ;
	cAlias																	, ; //X3_ARQUIVO
	'K2'																	, ; //X3_ORDEM
	cPrefixo + '_MSEXP'														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Ident.Exp.'															, ; //X3_TITULO
	'Ident.Exp.'															, ; //X3_TITSPA
	'Ident.Exp.'															, ; //X3_TITENG
	'Ident.Exp.Dados'														, ; //X3_DESCRIC
	'Ident.Exp.Dados'														, ; //X3_DESCSPA
	'Ident.Exp.Dados'														, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	9																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'L'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ FSAddHREXP บ Autor ณ TOTVS Protheus     บ Data ณ  03/08/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Funcao de processamento da gravacao do SX2 - Arquivos      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ FSAddHREXP   -      ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FSAddHREXP( aSX3, cAlias )

Local cPrefixo := If(SubStr(cAlias,1,1) == "S", SubStr(cAlias,2,3), cAlias)

aAdd( aSX3, { ;
	cAlias																	, ; //X3_ARQUIVO
	'K3'																	, ; //X3_ORDEM
	cPrefixo + '_HREXP'																, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	8																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Hora Exp'																, ; //X3_TITULO
	'Hora Exp'																, ; //X3_TITSPA
	'Hora Exp'																, ; //X3_TITENG
	'Hora da Exportacao'													, ; //X3_DESCRIC
	'Hora da Exportacao'													, ; //X3_DESCSPA
	'Hora da Exportacao'													, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Chr(254) + Chr(192)														, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		} ) //X3_PYME

Return

/////////////////////////////////////////////////////////////////////////////

