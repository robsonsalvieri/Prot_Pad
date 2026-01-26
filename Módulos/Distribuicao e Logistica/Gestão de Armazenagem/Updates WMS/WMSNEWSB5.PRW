#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} WMSNEWSB5
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  17/09/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function WMSNEWSB5( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local  	cTitulo   := "ATUALIZAÇÃO SERVIÇOS WMS "
Local 	cDesc1    := "Esta rotina tem como função de possibilitar marcar os produtos que controlarão WMS."
Local 	cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local 	cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local 	cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local 	cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

	TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top

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

		If Len( aMarcadas ) > 0
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Carregando", "Aguarde...", .F. )
			oProcess:Activate()
			If lAuto
				MsgStop( "Atualização concluída.", "WMSNEWSB5" )
				dbCloseAll()
			Else
				Final( "Atualização concluída.", "WMSNEWSB5" )
			EndIf
		Else
			MsgStop( "Nenhuma empresa foi selecionada! A atualização não será realizada.", "WMSNEWSB5" )
		EndIf
	EndIf

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  17/09/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local aInfo     := {}
Local cAux      := ""
Local cFile     := ""
Local cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cTexto    := ""
Local lOpen     := .F.
Local lRet      := .T.
Local nI        := 0
Local nJ        := 0
Local nPos      := 0
Local oDlg      := NIL
Local oFont     := NIL
Local oMemo     := NIL
Local aAllGroup := {}
Local aAllFil   := {}

If MyOpenSm0(.T.)

	aAllGroup := FWAllGrpCompany()

	For nI := 1 To Len( aAllGroup )

		If aScan( aMarcadas, aAllGroup[nI] ) <= 0
			Loop
		EndIf

		If !( lOpen := MyOpenSM0(.F.,aAllGroup[nI]) )
			MsgStop( "Atualização da empresa " + aAllGroup[nI] + " não efetuada." )
			Exit
		EndIf

		aAllFil := FWAllFilial(/*cCompany*/,/*cUnitBusiness*/,aAllGroup[nI],/*lOnlyCode*/.F.)

		For nJ := 1 To Len ( aAllFil )

			RpcSetType( 3 )
			RpcSetEnv( aAllGroup[nI], aAllFil[nJ] )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG ATUALIZAÇÃO PRODUTOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + FWGrpCompany() + "/" + FWGrpName() + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			oProcess:IncRegua1( " Abrindo tela para seleção." )

			MontaSB5()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nJ

	Next nI
	
	If !lAuto

		cTexto := LeLog()

		Define Font oFont Name "Mono AS" Size 5, 12

		Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

		Activate MsDialog oDlg Center

	EndIf

Else
	lRet := .F.
EndIf

Return lRet

//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()
//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local aRet      := {}
Local aVetor    := {}
Local cMascEmp  := "??"
Local cVar      := ""
Local lChk      := .F.
Local lOk       := .F.
Local lTeveMarc := .F.
Local oNo       := LoadBitmap( GetResources(), "LBNO" )
Local oOk       := LoadBitmap( GetResources(), "LBOK" )
Local oDlg, oChkMar, oLbx, oMascEmp, oSay
Local oButDMar, oButInv, oButMarc, oButOk, oButCanc
Local aMarcadas := {}
Local aAllGroup := {}
Local nI        := 0

If !MyOpenSM0(.T.)
	Return aRet
EndIf

aAllGroup := FWAllGrpCompany()

For nI := 1 To Len( aAllGroup )
	aAdd(  aVetor, { .F., aAllGroup[nI], "", FWGrpName(aAllGroup[nI]), "" } )
Next nI

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"
oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip :=  oDlg:cTitle
oLbx:lHScroll := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

Return  aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local nI := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, aVetor[nI][2] )
	EndIf
Next nI

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  17/09/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared,cGrpCompany)
Local lOpen := .F.
Local nLoop := 0

	For nLoop := 1 To 20

		If lShared
			OpenSM0(cGrpCompany)
		Else
			OpenSM0Excl(cGrpCompany)
		EndIf

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			Exit
		EndIf

		Sleep( 500 )

	Next nLoop

	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela de empresas (SM0)" + Iif(lShared,"."," de forma exclusiva."))
	EndIf

Return lOpen

//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  17/09/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet
//--------------------------------------------------------------------
/*/{Protheus.doc} MontaSB5	
Monta tela para exibição dos produtos

@author Amanda Rosa Vieira
@since  27/07/2016
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MontaSB5()
local cAliasSB5  := ""
Local aFieldsSB5 := {}
Local aStruct    := {}
Local nCont      := 0
Local nAlt       := (GetScreenRes()[2])
Local oPnlSB5    := Nil
Local oDlg       := Nil
Local nOpc       := 0
Local bOk        := {|| nOpc := 1,oDlg:End() }	
Local bCancel    := {|| nOpc := 0,oDlg:End() }    
	
	//Trata a altura da janela de acordo com a resolução
	If nAlt > 1000
		nAlt -= (nAlt - 900) * 80/100
	ElseIf nAlt < 900
		nAlt += (900 - nAlt) * 90/100
	EndIf
	
	//Array principal com os campos
	aFieldsSB5 := {{""                 ,"B5_OK"   ,"C",01                    ,0,"@!"},; 
					 {"Filial"           ,"B1_FILIAL","C",TamSX3("B1_FILIAL")[1],0,"@!"},; 
					 {"Código Produto"   ,"B5_COD"   ,"C",TamSX3("B1_COD")[1]   ,0,"@!"},;
					 {"Descrição Produto","B5_DESC"  ,"C",TamSX3("B1_DESC")[1]  ,0,"@!"}}
	
	For nCont := 2 to Len(aFieldsSB5)
		aADD(aStruct,{ aFieldsSB5[nCont][1],;
						aFieldsSB5[nCont][2],;
						aFieldsSB5[nCont][3],;
						aFieldsSB5[nCont][4],;
						aFieldsSB5[nCont][5],;
						aFieldsSB5[nCont][6]})
	Next nCont
	
	Define MsDialog oDlg Title "Seleção de Produtos Para Controle WMS" From 500,120 To nAlt,800 Of oMainWnd Color CLR_BLACK,RGB(225,225,225) Pixel 
	oDlg:lEscClose := .F.
	
	oPnlSB5 := tPanel():New(00,00,,oDlg,,,,,,30,40,.F.,.F.)
	oPnlSB5:Align := CONTROL_ALIGN_ALLCLIENT
	
	CriaSB5(aFieldsSB5,@cAliasSB5) // Cria a tabela, para a utilização do alias
	LoadSB5(@cAliasSB5,aFieldsSB5) //Carrega as informações para a tabela temporária
	
	oMarkSB5 := FWMarkBrowse():New()
	oMarkSB5:SetTemporary(.T.)
	oMarkSB5:SetOwner(oPnlSB5)
	oMarkSB5:SetAlias(cAliasSB5)					
	oMarkSB5:SetDescription("Seleção de Produtos Para Controle WMS")	   
	oMarkSB5:SetFieldMark("B5_OK")
	oMarkSB5:SetFields(aStruct)
	oMarkSB5:SetAllMark({|| MarcaRegistro(cAliasSB5,oMarkSB5) })
	oMarkSB5:SetMenuDef("")	
	oMarkSB5:Activate()
	
	ACTIVATE DIALOG oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) CENTERED
	If nOpc == 1 .And. MsgYesNo( "Confirma o controle WMS para os produtos marcados?","WMS - Controle WMS Produtos")
		GravCtrlWMS(cAliasSB5,oMarkSB5)
	EndIf
Return
//--------------------------------------------------------------------
/*/{Protheus.doc} GravCtrlWMS	
Grava controle WMS para os registros marcados
 
@author Amanda Rosa Vieira
@since  27/07/2016
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function GravCtrlWMS(cAliasSB5,oMarkSB5)

	(cAliasSB5)->(dbGoTop())
	dbSelectArea(cAliasSB5)
	
	dbSelectArea('SB5')
	SB5->(dbSetOrder(1)) //B5_FILIAL+B5_COD
	
	While (cAliasSB5)->(!EoF())
		If ((cAliasSB5)->B5_OK  == oMarkSB5:Mark())
			If SB5->(dbSeek(xFilial('SB5')+(cAliasSB5)->B5_COD))
				RecLock("SB5",.F.)
				SB5->B5_CTRWMS := '1'
				SB5->(MsUnLock())
				AutoGrLog( "Produto atualizado: "+(cAliasSB5)->B5_COD)
			EndIf
		EndIf
		(cAliasSB5)->(dbSkip())
	EndDo	
Return 
//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaRegistro	
Marcação de Todos os Registros quando clicado no header

@author Amanda Rosa Vieira
@since  27/07/2016
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaRegistro(cMarkAll,oBrwMkAll)
	dbSelectArea(cMarkAll)
	(cMarkAll)->(dbGoTop())
	While (cMarkAll)->(!Eof())
		If((cMarkAll)->B5_OK <> oBrwMkAll:Mark())	
			(cMarkAll)->B5_OK := oBrwMkAll:Mark()
		ElseIf ((cMarkAll)->B5_OK  == oBrwMkAll:Mark())
			(cMarkAll)->B5_OK := " "
		EndIf
		(cMarkAll)->(DbSkip())
	EndDo
	oBrwMkAll:Refresh(.T.)
Return
//--------------------------------------------------------------------
/*/{Protheus.doc} LoadSB5	
Carrega documentos de carga com origem transferência para a tela de desfazer recebimento.

@author Amanda Rosa Vieira
@since  27/07/2016
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LoadSB5(cAliasSB5,aFieldsSB5)
Local cQuery    := ""
Local cAliasQry := ""
Local nCont     := 0

	 //-------------------------------------------------------------------
    // Limpa tabela temporária
    //-------------------------------------------------------------------
    dbSelectArea(cAliasSB5)
    (cAliasSB5)->( dbSetOrder(1) )
    ZAP
    
	cQuery := " SELECT  SB1.B1_FILIAL,"
	cQuery += "         SB1.B1_COD,"
	cQuery += "         SB1.B1_DESC" 
	cQuery += "   FROM "+RetSqlName('SB1')+" SB1" 
	cQuery += "  INNER JOIN "+RetSqlName('SB5')+" SB5"
	cQuery += "     ON SB5.B5_FILIAL   = '"+xFilial('SB5')+"'"
	cQuery += "    AND SB5.B5_COD      = SB1.B1_COD"
	cQuery += "    AND SB5.D_E_L_E_T_  = ' '"
	cQuery += "  WHERE SB1.B1_FILIAL   = '"+xFilial('SB1')+"'" 
	cQuery += "    AND (SB1.B1_LOCALIZ = 'S' OR SB1.B1_LOCALIZ = '1')"
	cQuery += "    AND SB1.D_E_L_E_T_  = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
	While (cAliasQry)->(!Eof())   
	   	
		RecLock((cAliasSB5),.T.)
		For nCont := 2 to Len(aFieldsSB5)
			If aFieldsSB5[nCont][2] == "B1_FILIAL"
				(cAliasSB5)->&(aFieldsSB5[nCont][2])  := (cAliasQry)->B1_FILIAL
			ElseIf aFieldsSB5[nCont][2] == "B5_COD"
				(cAliasSB5)->&(aFieldsSB5[nCont][2])  := (cAliasQry)->B1_COD
			ElseIf aFieldsSB5[nCont][2] == "B5_DESC"
				(cAliasSB5)->&(aFieldsSB5[nCont][2])  := (cAliasQry)->B1_DESC
			EndIf
		Next nCont
		MsUnlock()
		
	    (cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
Return 
//--------------------------------------------------------------------
/*/{Protheus.doc} CriaSB5
Cria struct para tabela temporária.

@author Amanda Rosa Vieira
@since  27/07/2016
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function CriaSB5(aFieldsSB5,cAliasSB5)
Local aStruct := {}
Local nCont   := 0
   
    //busca no aCampos as propriedades para criar as colunas
	For nCont := 1 to Len(aFieldsSB5) 
		aADD(aStruct,{aFieldsSB5[nCont][2], aFieldsSB5[nCont][3], aFieldsSB5[nCont][4], aFieldsSB5[nCont][5]})
	Next nCont 
	
	CriaTabTmp(aStruct,{'B1_FILIAL','B5_COD','B5_DESC'},'cAliasSB5')
	
	cAliasSB5 := 'cAliasSB5'
Return 