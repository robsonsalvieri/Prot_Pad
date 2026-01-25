#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001

Função extratora de dados.

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
User Function GFES001()
Local oDlg       := Nil
Local oGroup     := Nil
Local oExtrator  := Nil
Local oPanel     := Nil
Local aRadio     := {}
Local cDirSel    := ""
Local cDiretorio := "\SYSTEM\"
//Documento de carga
//Local cGW1Fil    := Space(TamSx3("GW1_FILIAL")[1])
Local cCdTpDc    := Space(TamSx3("GW1_CDTPDC")[1])  
Local cEmiss     := Space(TamSx3("GW1_EMISDC")[1])
Local cSerDc     := Space(TamSx3("GW1_SERDC")[1])
Local cNrDoc     := Space(TamSx3("GW1_NRDC")[1])
//Documento de frete
Local cCdEsp     := Space(TamSx3("GW3_CDESP")[1]) 
Local cEmisDf    := Space(TamSx3("GW3_EMISDF")[1])  
Local cSerDf     := Space(TamSx3("GW3_SERDF")[1])
Local cNrDf      := Space(TamSx3("GW3_NRDF")[1])  
Local dDtEmiDf   := Ctod(Space(8))
//Romaneio
Local cNrRom     := Space(TamSx3("GWN_NRROM")[1])  
//Fatura
Local cEmissFat  := Space(TamSx3("GW6_EMIFAT")[1])  
Local cSerFat    := Space(TamSx3("GW6_SERFAT")[1])
Local cNrFat     := Space(TamSx3("GW6_NRFAT")[1])  
Local dDtEmiFat  := Ctod(Space(8))
Local oExpParam  := Nil
Local lExpParam  := .T.
//Lote de Provisâo
Local cCodLot    := Space(TamSx3("GXE_CODLOT")[1])
//Tabela de Frete
Local cEmissDe	 := Space(TamSx3("GVA_CDEMIT")[1])
Local cEmissAte	 := Space(TamSx3("GVA_CDEMIT")[1])
Local cNrTabFDe	 := Space(TamSx3("GVA_NRTAB")[1])
Local cNrTabFAte := Space(TamSx3("GVA_NRTAB")[1])
Local cNrNegDe	 := Space(TamSx3("GV9_NRNEG")[1])
Local cNrNegAte	 := Space(TamSx3("GV9_NRNEG")[1])

Private oPanelCarg := Nil
Private oPanelDocF := Nil
Private oPanelRoma := Nil
Private oPanelFat  := Nil
Private oPanelTabF := Nil
Private nRadio     := 1
Private lAbriuSM0  := .F.
Private lTabFrComp := .F. 
Private oTabFrComp := Nil

//Variável que controla o número de faturas que aparecerão no log, caso nRadio == 4 (Fatura)
Private nControlFat := 0

// Abertura de ambiente só pode ser executada se o programa não for acessado pelo GFE/Protheus
If Select("SM0") <= 0 
	OpenSM0()

	dbSelectArea( "SM0" )
	dbGoTop()
	
	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
	lClearEnv := .T.
	lAbriuSM0 := .T.	
End

//Define a tela
DEFINE MsDialog oDlg TITLE "Extrator de Informação" FROM 200,200 TO 437,770 PIXEL

//Agrupador "Extrator"
oGroup    := tGroup():New( 4  ,  6 , 84 , 280 ,            , oDlg   ,, CLR_BLACK , .T. )
oExtrator := tGroup():New( 5  , 10 , 62 , 110 , "Extrator" , oGroup ,, CLR_BLACK , .T. )

//Painel dos botões
oPanel := tPanel():New(105,0,,oDlg,,,,,RGB( 215, 215, 215 ),300,14,.F.,.F.)

//Criação dos paineis, conforme eles são alterados entre si ele vão se sobrepondo durante execução
oPanelCarg := tPanel():New(7,134,,oGroup,,,,,CLR_WHITE,140,55,.F.,.F.)
oPanelDocF := tPanel():New(7,134,,oGroup,,,,,CLR_WHITE,140,70,.F.,.F.)
oPanelRoma := tPanel():New(7,134,,oGroup,,,,,CLR_WHITE,140,55,.F.,.F.)
oPanelFat  := tPanel():New(7,134,,oGroup,,,,,CLR_WHITE,140,70,.F.,.F.)
oPanelTabF := tPanel():New(7,115,,oGroup,,,,,CLR_WHITE,164,70,.F.,.F.)

//Radio com as opões da tela
@ 14,18 RADIO aRadio VAR nRadio ITEMS "Documento de Carga" , "Documente de Frete" , "Romaneio", "Fatura", "Tabela de Frete" OF oExtrator ON CHANGE { || CampoInvi() } SIZE 110,10 PIXEL

//Cria os campos da seleção do documento de carga

@ 02  , 05 Say "Número: " Of oPanelCarg COLOR CLR_BLACK Pixel
@ 00  , 44 MsGet cNrDoc    When .T. SIZE 56,7               PIXEL OF oPanelCarg F3 "GFEGW4" HasButton

@ 16  , 05 Say "Tipo Docto.: " Of oPanelCarg COLOR CLR_BLACK Pixel
@ 14  , 44 MsGet cCdTpDc   When .T. SIZE 8,7  Picture "@!"  PIXEL OF oPanelCarg

@ 30  , 05 Say "Série: " Of oPanelCarg COLOR CLR_BLACK Pixel
@ 28  , 44 MsGet cSerDc    When .T. SIZE 8,7  Picture "@!"  PIXEL OF oPanelCarg

@ 44  , 05 Say "Emitente: " Of oPanelCarg COLOR CLR_BLACK Pixel
@ 43  , 44 MsGet cEmiss    When .T. SIZE 51,7 Picture "@!"  PIXEL OF oPanelCarg

//Cria os campos da seleção do Documento de Frete
@ 02  , 05 Say "Espécie: " Of oPanelDocF COLOR CLR_BLACK Pixel
@ 00  , 44 MsGet cCdEsp   When .T. SIZE 10,7 Picture "@!" PIXEL OF oPanelDocF

@ 16  , 05 Say "Emissor: " Of oPanelDocF COLOR CLR_BLACK Pixel
@ 14  , 44 MsGet cEmisDf   When .T. SIZE 48,7 Picture "@!" PIXEL OF oPanelDocF F3 "GU3" HasButton

@ 30  , 05 Say "Série: " Of oPanelDocF COLOR CLR_BLACK Pixel
@ 28  , 44 MsGet cSerDf   When .T. SIZE 10,7 Picture "@!" PIXEL OF oPanelDocF

@ 44  , 05 Say "Número: " Of oPanelDocF COLOR CLR_BLACK Pixel
@ 42  , 44 MsGet cNrDf   When .T. SIZE 56,7 Picture "@!" PIXEL OF oPanelDocF

@ 58  , 05 Say "Data Emissão: " Of oPanelDocF COLOR CLR_BLACK Pixel
@ 56  , 44 MsGet dDtEmiDf   When .T. SIZE 50,7 Picture "@!" PIXEL OF oPanelDocF HasButton

//Cria os campos da seleção do Romaneio de Carga
@ 02  , 05 Say "Romaneio: " Of oPanelRoma COLOR CLR_BLACK Pixel
@ 00  , 44 MsGet cNrRom   When .T. SIZE 26,7 Picture "@!" PIXEL OF oPanelRoma F3 "GWN" HasButton

//Cria os campos da seleção da Fatura                
@ 02  , 05 Say "Emissor: " Of oPanelFat COLOR CLR_BLACK Pixel
@ 00  , 44 MsGet cEmissFat   When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelFat F3 "GU3" HasButton
@ 16  , 05 Say "Série: " Of oPanelFat COLOR CLR_BLACK Pixel
@ 14  , 44 MsGet cSerFat   When .T. SIZE 10,7 Picture "@!" PIXEL OF oPanelFat   
@ 30  , 05 Say "Nr Fatura: " Of oPanelFat COLOR CLR_BLACK Pixel
@ 28  , 44 MsGet cNrFat   When .T. SIZE 56,7 Picture "@!" PIXEL OF oPanelFat   
@ 44  , 05 Say "Dt Emissão: " Of oPanelFat COLOR CLR_BLACK Pixel
@ 42  , 44 MsGet dDtEmiFat   When .T. SIZE 50,7 Picture "@!" PIXEL OF oPanelFat HasButton

//Cria os campos da seleção da Tabela de Frete
@ 02  , 01 Say "Emissor de: " Of oPanelTabF COLOR CLR_BLACK Pixel
@ 00  , 39 MsGet cEmissDe   When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelTabF F3 "GU3" HasButton
@ 02  , 95 Say "até: " Of oPanelTabF COLOR CLR_BLACK Pixel
@ 00  , 105 MsGet cEmissAte  When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelTabF F3 "GU3" HasButton
@ 16  , 01 Say "Nr Tabela de: " Of oPanelTabF COLOR CLR_BLACK Pixel
@ 14  , 39 MsGet cNrTabFDe  When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelTabF
@ 16  , 95 Say "até: " Of oPanelTabF COLOR CLR_BLACK Pixel
@ 14  , 105 MsGet cNrTabFAte When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelTabF    
@ 30  , 01 Say "Nr Negoc. de: " Of oPanelTabF COLOR CLR_BLACK Pixel
@ 28  , 39 MsGet cNrNegDe   When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelTabF
@ 30  , 95 Say "até: " Of oPanelTabF COLOR CLR_BLACK Pixel
@ 28  , 105 MsGet cNrNegAte   When .T. SIZE 51,7 Picture "@!" PIXEL OF oPanelTabF    

//Checkbox para indicar a exportação da tabela de frete completa e não somente
//as negociações, rotas, tarifas, etc, utilizadas no cálculo do documento
@ 64  , 18 CHECKBOX oTabFrComp VAR lTabFrComp WHEN .T. PROMPT "Exportar Tabela de Frete Completa" SIZE 100, 012 OF oGroup PIXEL

//Checkbox para indicar a exportação dos parâmetros juntamente com o documento selecionado
@ 72  , 18 CHECKBOX oExpParam VAR lExpParam WHEN .F. PROMPT "Exportar Parâmetros do Sistema" SIZE 100, 012 OF oGroup PIXEL

//Diretorio de exportação
@ 89 , 10  Say "Diretório:"  COLOR CLR_BLACK Pixel of oGroup SIZE 40,8
@ 87 , 35  Get   oGet     Var cDiretorio SIZE 200,7 Pixel OF oGroup
oButtonOK := tButton():New( 87 , 238 ,"Browse",oDlg,{|| cDirSel := cGetFile ( '*.*' , "Diretórios", 1, , .F., GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_LOCALFLOPPY), Iif(!Empty(cDirSel), cDiretorio := cDirSel, "") },25,10,,,,.T.) //"Browser" ### "Diretórios"
oGet:bChange   := {||}

ShowDC()

//Define os botões da tela
@ 02 , 170 BUTTON "Ok"       SIZE 50,10 Pixel OF oPanel ACTION {|| Iif( Processo( cCdTpDc , cEmiss , cSerDc , cNrDoc , cNrRom , cCdEsp , cEmisDf , cSerDf , cNrDf , dDtEmiDf , cEmissFat, cSerFat, cNrFat, dDtEmiFat, cDiretorio, lExpParam, cEmissDe, cEmissAte, cNrTabFDe, cNrTabFAte, cNrNegDe, cNrNegAte, cCodLot) == .T. , oDlg:End() , Nil )}    
@ 02 , 230 BUTTON "Cancelar" SIZE 50,10 Pixel OF oPanel ACTION {|| oDlg:End() }
CursorArrow()

ACTIVATE MSDIALOG oDlg CENTERED

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CampoInvi

Função do radio-set para validação de qual campo ira aparecer em tela


@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CampoInvi()

	Do Case
		//Documento de carga
		Case nRadio == 1
			ShowDC()
		//Documento de frete
		Case nRadio == 2
			ShowDF()
		//Romaneio
		Case nRadio == 3
			ShowRom()
		//Fatura
		Case nRadio == 4
			ShowFat()
		//Tabela de Frete
		Case nRadio == 5
			ShowTabF()
	EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowDC

Função que mostra apenas os campos do documento de carga na faixa de seleção

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ShowDC()
	oPanelCarg:Show()
	oPanelDocF:Hide()
	oPanelRoma:Hide()
	oPanelFat:Hide()
	oPaneltabF:Hide()
	
	// oTabFrComp:Enable()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowDF

Função que mostra apenas os campos do documento de frete na faixa de seleção

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ShowDF()
	oPanelCarg:Hide()
	oPanelDocF:Show()
	oPanelRoma:Hide()
	oPanelFat:Hide()
	oPanelTabF:Hide()
	
	// oTabFrComp:Enable()	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowDF

Função que mostra apenas os campos do romaneio na faixa de seleção

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ShowRom()
	oPanelCarg:Hide()
	oPanelDocF:Hide()
	oPanelRoma:Show()
	oPanelFat:Hide()
	oPanelTabF:Hide()
	
	// oTabFrComp:Enable()
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ShowFat
Função que mostra apenas os campos da fatura na faixa de seleção
@author  Amanda Rosa Vieira
@since   22/04/15
@version 1.0
/*/
//-------------------------------------------------------------------    
Static Function ShowFat()              
	oPanelCarg:Hide()   
	oPanelDocF:Hide()
	oPanelRoma:Hide()	
	oPanelFat:Show()
	oPanelTabF:Hide()
	
	// oTabFrComp:Enable()
Return


/*/{Protheus.doc} ShowTabF
Função que mostra apenas os campos da tabela de frete na faixa de seleção
@author silvana.torres
@since 24/04/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ShowTabF()              
	oPanelCarg:Hide()   
	oPanelDocF:Hide()
	oPanelRoma:Hide()	
	oPanelFat:Hide()
	oPanelTabF:Show()
	
	// oTabFrComp:Disable()
	// lTabFrComp := .T.
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Processo

Função com todo o processamento do sistema

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Processo( cCdTpDc , cEmiss , cSerDc , cNrDoc , cNrRom , cCdEsp , cEmisDf , cSerDf , cNrDf , dDtEmiDf , cEmissFat, cSerFat, cNrFat, dDtEmiFat, cDiretorio, lExpParam, cEmissDe, cEmissAte, cNrTabFDe, cNrTabFAte, cNrNegDe, cNrNegAte, cCodLot )
	Local cFileName := ""

	Private lRet     := .T.
	Private oProcess := Nil
	Private oArquivo := Nil

	If Empty(cDiretorio)
		MsgStop("É obrigatório informar um diretório para exportação!")
		lRet := .F.
	Else
		Do Case
			Case nRadio == 1 //Documento de Carga
				cFileName := cDiretorio + "EXPORTACAO_DC_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
				oArquivo  := GFELog():New(cFileName, "Exportação de Documento de Carga", "2", .F., .F.)

				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "° Origem: Documento de Carga" )
				oArquivo:Add( "°  - Tipo Docto. : " + cCdTpDc )
				oArquivo:Add( "°  - Emitente    : " + cEmiss )
				oArquivo:Add( "°  - Série       : " + cSerDc )
				oArquivo:Add( "°  - Número      : " + cNrDoc )
				oArquivo:Add( "°" )
				oArquivo:Add( "° Data da Exportação: " )
				oArquivo:Add( "°  - Data : " + DtoC(Date()) )
				oArquivo:Add( "°  - Hora : " + Time() )
				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "°" )

				Processa( { || GFES001GW1( xFilial("GW1"), cCdTpDc , cEmiss , cSerDc , cNrDoc, .F. ,!lAbriuSM0) },"Exportação de Documento de Carga")

			Case nRadio == 2 //Documento de Frete
				cFileName := cDiretorio + "EXPORTACAO_DF_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
				oArquivo  := GFELog():New(cFileName, "Exportação de Documento de Frete", "2", .F., .F.)

				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "° Origem: Documento de Frete" )
				oArquivo:Add( "°  - Especie      : " + cCdEsp )
				oArquivo:Add( "°  - Emissor      : " + cEmisDf )
				oArquivo:Add( "°  - Série        : " + cSerDf )
				oArquivo:Add( "°  - Número       : " + cNrDf )
				oArquivo:Add( "°  - Data Emissão : " + Dtoc(dDtEmiDf) )
				oArquivo:Add( "°" )
				oArquivo:Add( "° Data da Exportação: " )
				oArquivo:Add( "°  - Data : " + DtoC(Date()) )
				oArquivo:Add( "°  - Hora : " + Time() )
				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "°" )

				Processa( { || GFES001DF( cCdEsp , cEmisDf , cSerDf , cNrDf , dDtEmiDf ) },"Exportação de Documento de Frete")

			Case nRadio == 3 //Romaneio
				cFileName := cDiretorio + "EXPORTACAO_ROM_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
				oArquivo  := GFELog():New(cFileName, "Exportação de Romaneio de Carga", "2", .F., .F.)

				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "° Origem: Romaneio" )
				oArquivo:Add( "°  - Número : " + cNrRom )
				oArquivo:Add( "°" )
				oArquivo:Add( "° Data da Exportação: " )
				oArquivo:Add( "°  - Data : " + DtoC(Date()) )
				oArquivo:Add( "°  - Hora : " + Time() )
				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "°" )

				Processa( { || GFES001ROM( cNrRom ) },"Exportação de Romaneio de Carga")

			Case nRadio == 4 //Fatura
				cFileName := cDiretorio + "EXPORTACAO_FAT_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
				oArquivo  := GFELog():New(cFileName, "Exportação de Fatura de Frete", "2", .F., .F.)

				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "° Origem: Fatura" )
				oArquivo:Add( "°  - Emissor    : " + cEmissFat )
				oArquivo:Add( "°  - Série      : " + cSerFat )
				oArquivo:Add( "°  - Nr Fatura  : " + cNrFat )
				oArquivo:Add( "°  - Dt Emissão : " + Dtoc(dDtEmiFat) )
				oArquivo:Add( "°" )
				oArquivo:Add( "° Data da Exportação: " )
				oArquivo:Add( "°  - Data : " + DtoC(Date()) )
				oArquivo:Add( "°  - Hora : " + Time() )
				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "°" )

				oProcess  := MsNewProcess():New( { || GFES001FAT( cEmissFat, cSerFat, cNrFat, dDtEmiFat ) }, "Exportação de Fatura de Frete", "Iniciando processo..." )
				oProcess:Activate()
				
			Case nRadio == 5 //Tabela de Frete
				If empty(cEmissAte)
					cEmissAte := "ZZZZZZZZZZZZZZ"
				EndIf

				If empty(cNrTabFAte)
					cNrTabFAte := "999999"
				EndIf

				If empty(cNrNegAte)
					cNrNegAte := "999999"
				EndIf

				cFileName := cDiretorio + "EXPORTACAO_TABF_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
				oArquivo  := GFELog():New(cFileName, "Exportação de Tabela de Frete", "2", .F., .F.)

				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "° Origem: Tabela de Frete" )
				oArquivo:Add( "°  - Emissor de      : " + cEmissDe  + " até " + cEmissAte )
				oArquivo:Add( "°  - Tabela de       : " + cNrTabFDe + " até " + cNrTabFAte )
				oArquivo:Add( "°  - Nr Negociação de: " + cNrNegDe  + " até " + cNrNegAte )
				oArquivo:Add( "°" )
				oArquivo:Add( "° Data da Exportação: " )
				oArquivo:Add( "°  - Data : " + DtoC(Date()) )
				oArquivo:Add( "°  - Hora : " + Time() )
				oArquivo:Add( Replicate ("=", 60) )
				oArquivo:Add( "°" )

				oProcess  := MsNewProcess():New( { || GFES001TbF(cEmissDe, cEmissAte, cNrTabFDe, cNrTabFAte, cNrNegDe, cNrNegAte) }, "Exportação de Fatura de Frete", "Iniciando processo..." )
				oProcess:Activate()
				
		EndCase

		oArquivo:Save()

		If lExpParam
			cFileName := cDiretorio + "EXPORTACAO_PAR_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
			oArquivo  := GFELog():New(cFileName, "Exportação de Parâmetros do Sistema", "2", .F., .F.)

			oArquivo:Add( Replicate ("=", 60) )
			oArquivo:Add( "° Origem: Parâmetros do Sistema" )
			oArquivo:Add( "°" )
			oArquivo:Add( "° Data da Exportação: " )
			oArquivo:Add( "°  - Data : " + DtoC(Date()) )
			oArquivo:Add( "°  - Hora : " + Time() )
			oArquivo:Add( Replicate ("=", 60) )
			oArquivo:Add( "°" )

			Processa( { || GFES001PAR() },"Exportação de Parâmetros do Sistema")

			oArquivo:Save()
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001DF

Busca os documentos de frete conforme a seleção da tela

@Param cCdEsp   - Codigo da especie
@Param cEmisDf  - Emissor do documento de frete
@Param cSerDf   - Serie do documento de frete
@Param cNrDf    - Numero do documento de frete
@Param dDtEmiDf - Data de emissão

@author  Jorge Matos Valcanaia
@since   27/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001DF( cCdEsp , cEmisDf , cSerDf , cNrDf , dDtEmiDf )
	Local cSeekGW4  := ""
	Local nDocCarga := 0

	dbSelectArea("GW3")
	GW3->( dbSetOrder(1) )
	If GW3->( dbSeek( FWxFilial( "GW3" ) + PadR( cCdEsp , TamSx3("GW3_CDESP")[1] ) + PadR( cEmisDf , TamSx3("GW3_EMISDF")[1] ) + PadR( cSerDf , TamSx3("GW3_SERDF")[1] ) + PadR( cNrDf , TamSx3("GW3_NRDF")[1] ) + Dtos( dDtEmiDf ) ) )

		GW4->( DbSetOrder(1) )
		If GW4->( dbSeek( cSeekGW4 := GW3->GW3_FILIAL + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF + Dtos( GW3->GW3_DTEMIS ) ) )

			//Conta a quantidade de documentos de carga vinculados ao documento de frete
			GW4->(DbEval( { || nDocCarga++ } , { || cSeekGW4 == GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DtoS(GW4->GW4_DTEMIS) } , { || GW4->(!Eof()) } ))

			//Deve reposicionar a tabela GW4
			GW4->( DbSeek( cSeekGW4 ) )

			ProcRegua(nDocCarga)

			//Percorre a tabela
			While !GW4->( Eof() ) .And. cSeekGW4 == GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DtoS(GW4->GW4_DTEMIS)
				IncProc("Exportando...")

				//Documentos dos documentos de frete
				GFES001GW1( GW4->GW4_FILIAL, GW4->GW4_TPDC , GW4->GW4_EMISDC , GW4->GW4_SERDC , GW4->GW4_NRDC, .F. )

				GW4->( dbSkip() )
			EndDo
		Else
			Alert("Não existe relacionamento do Documento de Frete com Documento de Carga!!!")
			lRet := .F.
		EndIf
	Else
		Alert("Documento de Frete informado não existe!!!")
		lRet := .F.
	EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001ROM

Busca os romaneios para chegar nos documentos de carga

@Param cNrRom   - Número documento de carga

@author  Jorge Matos Valcanaia
@since   27/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001ROM( cNrRom )
	Local cAliasGW1 := ""
	Local cWhere    := ""
	Local nDocCarga := 0

	dbSelectArea( "GWN" )
	GWN->( DbSetOrder(1) )
	If GWN->( dbSeek( FWxFilial( "GWN" ) + cNrRom ) )
		If GFXCP1212210('GW1_FILROM')
			cWhere := "GW1.GW1_FILROM = '" + GWN->GWN_FILIAL + "'"
		Else
			cWhere := "GW1.GW1_FILIAL = '" + GWN->GWN_FILIAL + "'"
		EndIf
		cWhere := "%" + cWhere + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1_FILIAL, GW1_CDTPDC, GW1_EMISDC, GW1_SERDC, GW1_NRDC, GW1.R_E_C_N_O_ AS GW1RECNO
			FROM %table:GW1% GW1
			WHERE %Exp:cWhere%
			AND GW1.GW1_NRROM = %Exp:GWN->GWN_NRROM%
			AND GW1.%NotDel%
			ORDER BY GW1.GW1_FILIAL,GW1.GW1_NRDC
		EndSql

		//Conta a quantidade de documentos de carga vinculados ao romaneio
		If (cAliasGW1)->(!EoF())
			Count To nDocCarga
		EndIf

		//Deve reposicionar a tabela GW1
		(cAliasGW1)->(DbGotoP())

		ProcRegua(nDocCarga)

		While !(cAliasGW1)->(Eof())
			GW1->(dbGoTo((cAliasGW1)->GW1RECNO))

			IncProc("Exportando...")

			//Documento do romaneio
			GFES001GW1( GW1->GW1_FILIAL, GW1->GW1_CDTPDC, GW1->GW1_EMISDC, GW1->GW1_SERDC, GW1->GW1_NRDC, .F.)

			(cAliasGW1)->(dbSkip())
		EndDo	
		(cAliasGW1)->(dbCloseArea())

	Else
		Alert("Romaneio informado não existe!!!")
		lRet := .F.
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001FAT
Busca os informações da tabela de fatura
@Param cEmissFat - Emissor
@Param cSerFat   - Série
@Param cNrFat    - Número da Fatura
@Param dDtEmiFat - Data de Emissão
@author  Amanda Rosa Vieira
@since  22/04/15
@version 1.0
/*/
//-------------------------------------------------------------------      
Static Function GFES001FAT( cEmissFat, cSerFat, cNrFat, dDtEmiFat ) 
	Local cSeekGW3  := ""
	Local cSeekGW4  := ""
	Local nDocFrete := 0
	Local nDocCarga := 0
	Local nI        := 1
	Local nJ        := 1

	GW6->( DbSetOrder(1) ) //GW6_FILIAL+GW6_EMIFAT+GW6_SERFAT+GW6_NRFAT+GW6_DTEMIS
	If GW6->( DbSeek( FWxFilial( "GW6" ) + PadR(cEmissFat, TamSx3("GW6_EMIFAT")[1]) + PadR(cSerFat, TamSx3("GW6_SERFAT")[1]) + PadR(cNrFat, TamSx3("GW6_NRFAT")[1]) + DtoS(dDtEmiFat) ) )

		// Função que busca rateio contábil de fatura
		GFES001GW7(GW6->GW6_FILIAL, GW6->GW6_EMIFAT, GW6->GW6_SERFAT, GW6->GW6_NRFAT,GW6->GW6_DTEMIS)

		GW3->( DbSetOrder(8) ) //GW3_FILFAT+GW3_EMIFAT+GW3_SERFAT+GW3_NRFAT+DTOS(GW3_DTEMFA)
		If GW3->( DbSeek( cSeekGW3 := GW6->GW6_FILIAL + GW6->GW6_EMIFAT + GW6->GW6_SERFAT + GW6->GW6_NRFAT + Dtos(GW6->GW6_DTEMIS) ) )

			//Conta a quantidade de documentos de frete vinculados à fatura
			GW3->(DbEval( { || nDocFrete++ } , { || cSeekGW3 == GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DtoS(GW3->GW3_DTEMFA) } , {|| GW3->(!Eof())} ))

			//Deve reposicionar a tabela GW3
			GW3->( DbSeek( cSeekGW3 ) )

			oProcess:setRegua1(nDocFrete)

			While !GW3->( Eof() ) .And. ( cSeekGW3 == GW3->GW3_FILFAT+GW3->GW3_EMIFAT+GW3->GW3_SERFAT+GW3->GW3_NRFAT+DtoS(GW3->GW3_DTEMFA) )

				oProcess:incRegua1("Exportando doc. de frete - fatura ("+AllTrim(Str(nI++))+"/"+AllTrim(Str(nDocFrete))+")")

				GW4->( DbSetOrder(1) )
				If GW4->( DbSeek( cSeekGW4 := GW3->GW3_FILFAT + GW3->GW3_EMISDF + GW3->GW3_CDESP + GW3->GW3_SERDF + GW3->GW3_NRDF + DtoS( GW3->GW3_DTEMIS ) ) )

					//Conta a quantidade de documentos de carga vinculados ao documento de frete

					//Deve reposicionar a tabela GW4
					GW4->( DbSeek( cSeekGW4 ) )

					oProcess:setRegua2(nDocCarga)

					//Percorre a tabela
					While !GW4->( Eof() ) .And. cSeekGW4 == GW4->GW4_FILIAL+GW4->GW4_EMISDF+GW4->GW4_CDESP+GW4->GW4_SERDF+GW4->GW4_NRDF+DtoS(GW4->GW4_DTEMIS)
						oProcess:incRegua2("Exportando doc. de carga - doc. de frete (" + AllTrim(Str(nJ++)) + "/" + AllTrim(Str(nDocCarga)) + ")")

						//Documentos de carga dos documentos de frete
						GFES001GW1( GW4->GW4_FILIAL, GW4->GW4_TPDC , GW4->GW4_EMISDC , GW4->GW4_SERDC , GW4->GW4_NRDC, .F. )

						// Evita que exporte mais de uma vez a fatura no caso de haver mais de um doc de frete.
						If (nControlFat == 0)
							nControlFat += 1
						EndIf

						GW4->( dbSkip() )
					EndDo
					nDocCarga := 0
					nJ        := 1
				Else
					Alert("Não existe relacionamento do Documento de Frete com Documento de Carga!!!")
					lRet := .F.
				EndIf

				GW3->( dbSkip() )
			EndDo
		EndIf
	Else
		Alert("Fatura informada não existe!!!")   
		lRet := .F.
	EndIf 

Return 

/*/{Protheus.doc} GFES001TbF
Busca os informações da tabela de frete
@author silvana.torres
@since 24/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cEmissDe, characters, descricao
@param cEmissAte, characters, descricao
@param cNrTabFDe, characters, descricao
@param cNrTabFAte, characters, descricao
@param cNrNegDe, characters, descricao
@param cNrNegAte, characters, descricao
@type function
/*/
Static Function GFES001TbF( cEmissDe, cEmissAte, cNrTabFDe, cNrTabFAte, cNrNegDe, cNrNegAte )
	Local cQuery	 := ""
	Local cAliasTabF := GetNextAlias()

	If Select(cAliasTabF) > 0
        (cAliasTabF)->(DBCloseArea())
    EndIf

    cQuery := " SELECT GVA.GVA_FILIAL, "
    cQuery += "		   GVA.GVA_CDEMIT, "
    cQuery += "		   GVA.GVA_NRTAB 	"
    cQuery += "   FROM " + RetSqlName("GVA") +" GVA"
    cQuery += "  WHERE GVA.D_E_L_E_T_ = ' ' "
    cQuery += "    AND GVA.GVA_FILIAL = '" + FWxFilial("GVA") + "'"
    cQuery += "    AND GVA.GVA_CDEMIT >= '" + PADR(cEmissDe,TamSX3("GVA_CDEMIT")[1])  + "'"
    cQuery += "    AND GVA.GVA_CDEMIT <= '" + PADR(cEmissAte,TamSX3("GVA_CDEMIT")[1]) + "'"
    cQuery += "    AND GVA.GVA_NRTAB >= '" + PADR(cNrTabFDe,TamSX3("GVA_NRTAB")[1])  + "'"
    cQuery += "    AND GVA.GVA_NRTAB <= '" + PADR(cNrTabFAte,TamSX3("GVA_NRTAB")[1]) + "'"

    DBUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasTabF,.T.,.T.)

    (cAliasTabF)->(DBGoTop())

    If !(cAliasTabF)->(EoF())
    	While !(cAliasTabF)->(EoF())
    		oProcess:incRegua1("Exportando tabelas de frete")

    		G001GVATbF((cAliasTabF)->(GVA_CDEMIT), (cAliasTabF)->(GVA_NRTAB), cNrNegDe, cNrNegAte)

			(cAliasTabF)->(DBSkip())
	    End
	Else
		Alert("Nenhuma tabela de frete encontrada!!!")
		lRet := .F.
	EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW1

Busca os informações da tabela de documento de carga

@Param cNrDoc      - Número documento de carga
@Param cEmiss      - Emissor do documento de carga
@Param cCdTpDc     - Codigo do tipo do documento de carga
@Param dDtEmiss    - Data de emissão do documento de carga
@Param lCallForGWJ - Verifica se o programa está sendo chamado pelo GFES001GWJ(pré-faturas)
@Param lProcess    - Indica se utiliza barra de progressão (só deve ser utilizada na exportação de documento de carga)

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW1( cGW1Fil, cCdTpDc , cEmiss , cSerDc , cNrDoc, lCallForGWJ, lProcess )
	Local aAreaGW1 := GW1->( GetArea() )
	Local aAreaGW4 := GW4->( GetArea() )
	Local aStructGW1
	Local bIncProc := {|| }

	Default lProcess := .F.

	If lProcess
		ProcRegua(12) //São doze funções chamadas neste processo
		bIncProc := { || IncProc("Exportando...") }
	EndIf

	//Seta a tabela
	dbSelectArea("GW1")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW1 := DBStruct (  )
	//Seta o indice utilizado
	GW1->( dbSetOrder(1) )
	//Posiciona no registro que foi digitado na tela
	If GW1->( dbSeek( PadR(cGW1Fil, TamSx3("GW1_FILIAL")[1]) + PadR(cCdTpDc, TamSx3("GW1_CDTPDC")[1]) + PadR(cEmiss, TamSx3("GW1_EMISDC")[1]) + PadR(cSerDc, TamSx3("GW1_SERDC")[1]) + PadR(cNrDoc, TamSx3("GW1_NRDC")[1]) ) )

		oArquivo:Add( "GW1_CHAVIN |" + Space(3) + "| " + "GW1_FILIAL: " + GW1->GW1_FILIAL +;
											     " | " + "GW1_CDTPDC: " + GW1->GW1_CDTPDC +;
											     " | " + "GW1_EMISDC: " + GW1->GW1_EMISDC +;
											     " | " + "GW1_SERDC: "  + GW1->GW1_SERDC  +;
											     " | " + "GW1_NRDC: "   + GW1->GW1_NRDC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW1 , "GW1" )

		//Exporta os movimentos contabeis do documento
		GFES001GWM( GW1->GW1_FILIAL, GW1->GW1_CDTPDC , GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC )
		Eval(bIncProc)

		//Tipo de Documento
		GFES001GV5( GW1->GW1_CDTPDC )
		Eval(bIncProc)

		//Ocorrencias
		GFES001GWL( GW1->GW1_FILIAL, GW1->GW1_NRDC , GW1->GW1_FILIAL , GW1->GW1_EMISDC , GW1->GW1_SERDC )
		Eval(bIncProc)

		//Documento de carga x Documento de fret
		If !(lCallForGWJ)
			GFES001GW4( GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC , GW1->GW1_CDTPDC, GW1->GW1_FILIAL ) 
			Eval(bIncProc)
		EndIf

		//Relatório de movimentação de frete
		If GFXTB1212210("GX0")
			GFES001GX0( GW1->GW1_FILIAL, GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC , GW1->GW1_CDTPDC ) 
		EndIf

		//Busca o emitente do documento de carga
		GFES001GU3( GW1->GW1_EMISDC )
		Eval(bIncProc)

		//Busca o remetente do documento de carga
		GFES001GU3( GW1->GW1_CDREM  )
		Eval(bIncProc) 

		//Busca o destinatario do documento de carga
		GFES001GU3( GW1->GW1_CDDEST )
		Eval(bIncProc)

		//Unitilizadores
		GFES001GWB( GW1->GW1_FILIAL, GW1->GW1_CDTPDC , GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC )
		Eval(bIncProc)

		//Documento de Carga x Cálculo de Frete
		GFES001GWH( GW1->GW1_FILIAL, GW1->GW1_CDTPDC , GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC )
		Eval(bIncProc)

		//Itens Documento de Carga
		GFES001GW8( GW1->GW1_FILIAL, GW1->GW1_CDTPDC , GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC )
		Eval(bIncProc)

		//Trecho Documento de Carga
		GFES001GWU( GW1->GW1_FILIAL, GW1->GW1_CDTPDC , GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC )
		Eval(bIncProc)

		//Romaneio de Carga
		If GFXCP1212210('GW1_FILROM')
			GFES001GWN( GW1->GW1_FILROM, GW1->GW1_NRROM )
		Else
			GFES001GWN( GW1->GW1_FILIAL, GW1->GW1_NRROM )
		EndIf

		Eval(bIncProc)

	Else
		Alert("Não foi encontrado nenhum documento com os dados informados!!!")
		lRet := .F.
	EndIf

	RestArea( aAreaGW4 )
	RestArea( aAreaGW1 )
Return

/*/{Protheus.doc} G001GVATbF
Busca os informações da tabela de frete
@author silvana.torres
@since 25/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cEmisTabF, characters, emitente
@param cNrTab, characters, número da tabela de frete 
@param cNrNegDe, characters, número inicial da faixa de negociação 
@param cNrNegAte, characters, número final da faixa de negociação
@type function
/*/
Static Function G001GVATbF(cEmisTabF, cNrTab, cNrNegDe, cNrNegAte)
	Local aStructGVA

	GVA->(dbSelectArea("GVA"))
	aStructGVA := GVA->(DBStruct())
	GVA->(dbSetOrder(1)) //GVA_FILIAL+GVA_CDEMIT+GVA_NRTAB
	If GVA->(dbSeek(FWxFilial("GVA") + cEmisTabF + cNrTab))

		oArquivo:Add( "GVA_CHAVIN |" + Space(3) + "| " + "GVA_FILIAL: " + GVA->GVA_FILIAL +;
											 	 " | " + "GVA_CDEMIT: " + GVA->GVA_CDEMIT +;
											 	 " | " + "GVA_NRTAB: "  + GVA->GVA_NRTAB )

		//Envia dados para serem gravados no txt
		EnvDados(aStructGVA, "GVA")

		//Negociação tabela de frete
		G001GV9TbF(GVA->GVA_FILIAL, GVA->GVA_CDEMIT , GVA->GVA_NRTAB, cNrNegDe, cNrNegAte)

	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWM

Busca todos os rateios contabeis relacionados ao documento de carga

@Param cCdTpDc - Codigo do tipo de documento de carga
@Param cEmisDc - Emitente do documento de carga
@Param cSerDc  - Serie do documento de carga
@Param cNrDc   - Numero do documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWM( cGW1Fil, cCdTpDc , cEmisDc , cSerDc , cNrDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GWM")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWM := DBStruct (  )
	//Seta o indice utilizado
	GWM->( dbSetOrder(2) )
	//Posiciona no registro de acordo com os parametros
	GWM->( dbSeek( cGW1Fil + cCdTpDc + cEmisDc + cSerDc + cNrDc ) )
	//Percorre toda tabela enquanto o mesmo estiver dentro da faixa de seleção do dbseek
	While GWM->( !Eof() ) .And. GWM->GWM_FILIAL == cGW1Fil ;
						  .And. GWM->GWM_CDTPDC == cCdTpDc ;
						  .And. GWM->GWM_EMISDC == cEmisDc ;
						  .And. GWM->GWM_SERDC == cSerDc ;
						  .And. GWM->GWM_NRDC == cNrDc

		oArquivo:Add("GWM_CHAVIN |" + Space(3) + "| " + "GWM_FILIAL: " + GWM->GWM_FILIAL 		 +;
											    " | " + "GWM_TPDOC: "  + GWM->GWM_TPDOC  		 +;
											    " | " + "GWM_CDESP: "  + GWM->GWM_CDESP  		 +;
											    " | " + "GWM_CDTRP: "  + GWM->GWM_CDTRP  		 +;
											    " | " + "GWM_SERDOC: " + GWM->GWM_SERDOC 		 +;
											    " | " + "GWM_NRDOC: "  + GWM->GWM_NRDOC  		 +;
											    " | " + "GWM_DTEMIS: " + Dtos( GWM->GWM_DTEMIS ) +;
											    " | " + "GWM_CDTPDC: " + GWM->GWM_CDTPDC 		 +;
											 	" | " + "GWM_EMISDC: " + GWM->GWM_EMISDC 		 +;
											 	" | " + "GWM_SERDC: "  + GWM->GWM_SERDC 		 +;
											 	" | " + "GWM_NRDC: "   + GWM->GWM_NRDC 		 	 +;
											 	" | " + "GWM_SEQGW8 : "+ GWM->GWM_SEQGW8  	 	 +;
											 	" | " + "GWM_GRPCTB: " + GWM->GWM_GRPCTB )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWM , "GWM" )

		//Conta INSS Autonomo
		If !Empty( GWM->GWM_CTINAU )
			GFES001GUE( GWM->GWM_CTINAU )
		EndIf 

		//Conta INSS Embarcador
		If !Empty( GWM->GWM_CTINEM )
			GFES001GUE( GWM->GWM_CTINEM )
		EndIf 

		//Conta IRRF
		If !Empty( GWM->GWM_CTIRRF )
			GFES001GUE( GWM->GWM_CTIRRF )
		EndIf 

		//Conta Sest/Senat
		If !Empty( GWM->GWM_CTSEST )
			GFES001GUE( GWM->GWM_CTSEST )
		EndIf 

		//Conta ISS
		If !Empty( GWM->GWM_CTISS  )
			GFES001GUE( GWM->GWM_CTISS )
		EndIf 

		//Conta ICMS
		If !Empty( GWM->GWM_CTICMS )
			GFES001GUE( GWM->GWM_CTICMS )
		EndIf 

		//Conta PIS
		If !Empty( GWM->GWM_CTPIS  )
			GFES001GUE( GWM->GWM_CTPIS )
		EndIf 

		//Conta Cofins
		If !Empty( GWM->GWM_CTCOFI )
			GFES001GUE( GWM->GWM_CTCOFI )
		EndIf 

		//Conta Frete
		If !Empty( GWM->GWM_CTFRET )
			GFES001GUE( GWM->GWM_CTFRET )
		EndIf 

		//Grupos Conta Contabil
		GFES001GUF( GWM->GWM_GRP1 , GWM->GWM_GRP2 , GWM->GWM_GRP3 , GWM->GWM_GRP4 , GWM->GWM_GRP5 , GWM->GWM_GRP6 , GWM->GWM_GRP7 )

		//Movimentos contabeis
		GFES001GWA( GWM->GWM_FILIAL, GWM->GWM_TPDOC, GWM->GWM_CDESP, GWM->GWM_CDTRP, GWM->GWM_SERDOC, GWM->GWM_NRDOC, GWM->GWM_DTEMIS )

		//Contas Contabeis por Filial
		GFES001GUS( GWM->GWM_FILIAL )

		//Pula para proximo registro da tabela
		GWM->( dbSkip() )
	EndDo

	//Restaura a area da tabela GW1
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUE

Busca as contas contabeis

@Param cCtaCtb - Codigo da conta contabil

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUE( cCtaCtb )
	Local aAreaGWM := GWM->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GUE")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUE := DBStruct (  )
	//Seta o indice utilizado
	GUE->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUE->( dbSeek( FWxFilial("GUE") + cCtaCtb ) )

		oArquivo:Add( "GUE_CHAVIN |" + Space(3) + "| " + "GUE_FILIAL: " + "xx" +;
											 " | " + "GUE_CTACTB: " + GUE->GUE_CTACTB )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUE , "GUE" )

		Endif

	//Restaura a area da tabela GWM
	RestArea( aAreaGWM )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUF

Busca as CONTAS X GRUPOS CONTABEIS

@Param cGrupo1 - Grupo Contabil 1
@Param cGrupo2 - Grupo Contabil 2
@Param cGrupo3 - Grupo Contabil 3
@Param cGrupo4 - Grupo Contabil 4
@Param cGrupo5 - Grupo Contabil 5
@Param cGrupo6 - Grupo Contabil 6
@Param cGrupo7 - Grupo Contabil 7

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUF( cGrupo1 , cGrupo2 , cGrupo3 , cGrupo4 , cGrupo5 , cGrupo6 , cGrupo7 )
	Local aAreaGWM := GWM->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GUF")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUF := DBStruct (  )
	//Seta o indice utilizado
	GUF->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUF->( dbSeek( FWxFilial("GUF") + cGrupo1 + cGrupo2 + cGrupo3 + cGrupo4 + cGrupo5 + cGrupo6 + cGrupo7 ) )

		oArquivo:Add( "GUF_CHAVIN |" + Space(3) + "| " + "GUF_FILIAL: " + "xx" +;
											 " | " + "GUF_GRP1: "   + GUF->GUF_GRP1   +;
											 " | " + "GUF_GRP2: "   + GUF->GUF_GRP2   +;
											 " | " + "GUF_GRP3: "   + GUF->GUF_GRP3   +;
											 " | " + "GUF_GRP4: "   + GUF->GUF_GRP4   +;
											 " | " + "GUF_GRP5: "   + GUF->GUF_GRP5   +;
											 " | " + "GUF_GRP6: "   + GUF->GUF_GRP6   +;
											 " | " + "GUF_GRP7: "   + GUF->GUF_GRP7 )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUF , "GUF" )

	Endif

	//Restaura a area da tabela GWM
	RestArea( aAreaGWM )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWA

Busca o MOVIMENTO CONTABIL

@Param cTpDoc   - Tipo documento
@Param cCdEsp   - Especie documento de frete
@Param cCdTrp   - Emissor documento
@Param cSerDoc  - Serie
@Param cNrDoc   - Numero documento
@Param dDtEmiss - Data de emissao

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWA( cCodFil, cTpDoc, cCdEsp, cCdTrp, cSerDoc, cNrDoc, dDtEmiss )
	Local aAreaGWM := GWM->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GWA")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWA := DBStruct (  )
	//Seta o indice utilizado
	GWA->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GWA->( dbSeek( cCodFil + cTpDoc + cCdEsp + cCdTrp + cSerDoc + cNrDoc + Dtos( dDtEmiss ) ) )
	While !GWA->( Eof() ) .And. GWA->GWA_FILIAL == cCodFil ;
						  .And. GWA->GWA_TPDOC == cTpDoc ;
						  .And. GWA->GWA_CDESP == cCdEsp ;
						  .And. GWA->GWA_CDEMIT == cCdTrp ;
						  .And. GWA->GWA_SERIE == cSerDoc ;
						  .And. GWA->GWA_NRDOC == cNrDoc ;
						  .And. GWA->GWA_DTEMIS == dDtEmiss

		oArquivo:Add( "GWA_CHAVIN |" + Space(3) + "| " + "GWA_FILIAL: " + GWA->GWA_FILIAL 		+;
											 	 " | " + "GWA_TPDOC: "  + GWA->GWA_TPDOC        +;
											 	 " | " + "GWA_CDESP: "  + GWA->GWA_CDESP        +;
											 	 " | " + "GWA_CDEMIT: " + GWA->GWA_CDEMIT       +;
											 	 " | " + "GWA_SERIE: "  + GWA->GWA_SERIE        +;
											 	 " | " + "GWA_NRDOC: "  + GWA->GWA_NRDOC        +;
											 	 " | " + "GWA_DTEMIS: " + DTOS(GWA->GWA_DTEMIS) +;
											 	 " | " + "GWA_CDTRAN: " + GWA->GWA_CDTRAN       +;
											 	 " | " + "GWA_SEQ: "    + GWA->GWA_SEQ )
		
		//Envia dados para serem gravados no txt
		EnvDados( aStructGWA , "GWA" )

			//Pula para proximo registro da tabela
		GWA->( dbSkip() )
	EndDo


	GWA->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GWA->( dbSeek( cCodFil + cTpDoc + cCdEsp + cCdTrp + cSerDoc + cNrDoc + Dtos( dDtEmiss ) ) )
	While !GWA->( Eof() ) .And. GWA->GWA_FILIAL == cCodFil ;
						  .And. GWA->GWA_TPDOC  == cTpDoc ;
						  .And. GWA->GWA_CDESP  == cCdEsp ;
						  .And. GWA->GWA_CDEMIT == cCdTrp ;
						  .And. GWA->GWA_SERIE  == cSerDoc ;
						  .And. GWA->GWA_NRDOC  == cNrDoc ;
						  .And. GWA->GWA_DTEMIS == dDtEmiss

		//Tabela Lote de Provisão
		If !Empty(GWA->GWA_CODLOT) .And. cTpDoc == "1"
			GFES001GXE(GWA->GWA_CODLOT, GWA->GWA_FILIAL, GWA->GWA_NRDOC)
		EndIf 
		GWA->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWM
	RestArea( aAreaGWM )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUS

CONTAS CONTABEIS X FILIAIS

@Param cFilCtb - Filial Provisão/Contabilização

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUS( cFilCtb )
	Local aAreaGWM := GWM->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GUS")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUS := DBStruct (  )
	//Seta o indice utilizado
	GUS->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUS->( dbSeek( FWxFilial("GUS") + cFilCtb ) )

		oArquivo:Add( "GUS_CHAVIN |" + Space(3) + "| " + "GUS_FILIAL: " + "xx" +;
											 " | " + "GUS_FILCTB: " + GUS->GUS_FILCTB )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUS , "GUS" )

	Endif

	//Restaura a area da tabela GWM
	RestArea( aAreaGWM )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV5

TIPOS DE DOCUMENTOS DE CARGA

@Param cCdTpDc - Tipo documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV5( cCdTpDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GV5")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV5 := DBStruct (  )
	//Seta o indice utilizado
	GV5->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GV5->( dbSeek( FWxFilial("GV5") + cCdTpDc ) )

		oArquivo:Add( "GV5_CHAVIN |" + Space(3) + "| " + "GV5_FILIAL: " + "xx" +;
											 " | " + "GV5_CDTPDC: " + GV5->GV5_CDTPDC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV5 , "GV5" )

	Endif

	//Restaura a area da tabela GW1
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWL

OCORRENCIA X DOCTO CARGA

@Param cNrDc   - Numero documento
@Param cFilDc  - Filial documento
@Param cEmitDc - Emitente documento
@Param cSerDc  - Serie documento

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWL( cGW1Fil, cNrDc , cFilDc , cEmitDc , cSerDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GWL")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWL := DBStruct (  )
	//Seta o indice utilizado
	GWL->( dbSetOrder(2) )
	//Posiciona no registro de acordo com os parametros
	GWL->( dbSeek( cGW1Fil + cNrDc + cFilDc + cEmitDc + cSerDc ) )
	While !GWL->( Eof() ) .And. GWL->GWL_FILIAL == cGW1Fil ;
						  .And. GWL->GWL_NRDC == cNrDc ;
						  .And. GWL->GWL_FILDC == cFilDc ;
						  .And. GWL->GWL_EMITDC == cEmitDc ;
						  .And. GWL->GWL_SERDC == cSerDc

		oArquivo:Add( "GWL_CHAVIN |" + Space(3) + "| " + "GWL_FILIAL: " + GWL->GWL_FILIAL +;
											 	 " | " + "GWL_NROCO: "  + GWL->GWL_NROCO  +;
											 	 " | " + "GWL_FILDC: "  + GWL->GWL_FILDC  +;
											 	 " | " + "GWL_EMITDC: " + GWL->GWL_EMITDC +;
											 	 " | " + "GWL_SERDC: "  + GWL->GWL_SERDC  +;
											 	 " | " + "GWL_NRDC: "   + GWL->GWL_NRDC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWL , "GWL" )

		//Ocorrencias
		GFES001GWD( GWL->GWL_FILIAL, GWL->GWL_NROCO )

		//Pula para proximo registro da tabela
		GWL->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWM
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWD

OCORRENCIAS

@Param cNrOco - Numero ocorrencia

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWD( cCodFil, cNrOco )
	Local aAreaGWL := GWL->( GetArea() ) //Guarda a Area da tabela GWL

	//Seta a tabela
	dbSelectArea("GWD")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWD := DBStruct (  )
	//Seta o indice utilizado
	GWD->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GWD->( dbSeek( cCodFil + cNrOco ) )

		oArquivo:Add( "GWD_CHAVIN |" + Space(3) + "| " + "GWD_FILIAL: " + GWD->GWD_FILIAL +;
											     " | " + "GWD_NROCO: "  + GWD->GWD_NROCO )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWD , "GWD" )

		//Motivo ocorrencia
		GFES001GU6( GWD->GWD_CDMOT )
	Endif

	//Restaura a area da tabela GWL
	RestArea( aAreaGWL )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU6

MOTIVO DA OCORRENCIA

@Param cCdMot - Codigo do motivo

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU6( cCdMot )
	Local aAreaGWD := GWD->( GetArea() ) //Guarda a Area da tabela GWD

	//Seta a tabela
	dbSelectArea("GU6")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU6 := DBStruct (  )
	//Seta o indice utilizado
	GU6->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GU6->( dbSeek( FWxFilial("GU6") + cCdMot ) )

		oArquivo:Add( "GU6_CHAVIN |" + Space(3) + "| " + "GU6_FILIAL: " + "xx" +;
											 " | " + "GU6_CDMOT: "  + GU6->GU6_CDMOT )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGU6 , "GU6" )

		//Tipo x Motivo x Ocorrencia
		GFES001GU4( GU6->GU6_CDMOT )

	Endif

	//Restaura a area da tabela GWD
	RestArea( aAreaGWD )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU4

TIPO X MOTIVO OCORRENCIA

@Param cCdMot - Codigo motivo da ocorrencia

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU4( cCdMot )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GW1

	//Seta a tabela
	dbSelectArea("GU4")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU4 := DBStruct (  )
	//Seta o indice utilizado
	GU4->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GU4->( dbSeek( FWxFilial("GU4") + cCdMot ) )
	While !GU4->( Eof() ) .And.;
		FWxFilial("GU4")  == GU4->GU4_FILIAL .And.;
		GU4->GU4_CDMOT  == cCdMot

		oArquivo:Add( "GU4_CHAVIN |" + Space(3) + "| " + "GU4_FILIAL: " + "xx" +;
											 " | " + "GU4_CDMOT: "  + GU4->GU4_CDMOT  +;
											 " | " + "GU4_CDTIPO: " + GU4->GU4_CDTIPO )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGU4 , "GU4" )

		//Tipo Ocorrencia
		GFES001GU5( GU4->GU4_CDTIPO )

			//Pula para proximo registro da tabela
		GU4->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWM
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU5

TIPO DA OCORRENCIA

@Param cCdTipo - Tipo Ocorrencia

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU5( cCdTipo )
	Local aAreaGU4 := GU4->( GetArea() ) //Guarda a Area da tabela GU4

	//Seta a tabela
	dbSelectArea("GU5")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU5 := DBStruct (  )
	//Seta o indice utilizado
	GU5->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GU5->( dbSeek( FWxFilial("GU5") + cCdTipo ) )

		oArquivo:Add( "GU5_CHAVIN |" + Space(3) + "| " + "GU5_FILIAL: " + "xx" +;
											 " | " + "GU5_CDTIPO: " + GU5->GU5_CDTIPO )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGU5 , "GU5" )

	Endif

	//Restaura a area da tabela GU4
	RestArea( aAreaGU4 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU5

DOCTOS CARGA DOS DOCTOS FRETE

@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga
@Param cTpDc   - Tipo do documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW4( cEmisDc , cSerDc , cNrDc , cTpDc, cGW1Fil )
	Local aAreaGW4 := GW4->( GetArea() ) //Guarda a Area da tabela GW4

	//Seta a tabela
	dbSelectArea("GW4")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW4 := DBStruct (  )
	//Seta o indice utilizado
	GW4->( dbSetOrder(2) )
	//Posiciona no registro de acordo com os parametros
	GW4->( dbSeek( cGW1Fil + cEmisDc + cSerDc + cNrDc + cTpDc ) )
	While !GW4->( Eof() ) .And. GW4->GW4_FILIAL == cGW1Fil ;
						  .And. GW4->GW4_EMISDC == cEmisDc ;
						  .And. GW4->GW4_SERDC == cSerDc ;
						  .And. GW4->GW4_NRDC == cNrDc ;
						  .And. GW4->GW4_TPDC == cTpDc

		oArquivo:Add( "GW4_CHAVIN |" + Space(3) + "| " + "GW4_FILIAL: " + GW4->GW4_FILIAL   	+;
											 	 " | " + "GW4_EMISDF: " + GW4->GW4_EMISDF       +;
											 	 " | " + "GW4_CDESP: "  + GW4->GW4_CDESP        +;
											 	 " | " + "GW4_SERDF: "  + GW4->GW4_SERDF        +;
											 	 " | " + "GW4_NRDF: "   + GW4->GW4_NRDF         +;
											 	 " | " + "GW4_DTEMIS: " + DTOS(GW4->GW4_DTEMIS) +;
											 	 " | " + "GW4_EMISDC: " + GW4->GW4_EMISDC       +;
											 	 " | " + "GW4_SERDC: "  + GW4->GW4_SERDC        +;
											 	 " | " + "GW4_NRDC: "   + GW4->GW4_NRDC         +;
											 	 " | " + "GW4_TPDC: "   + GW4->GW4_TPDC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW4 , "GW4" )

		//Documento de Frete
		GFES001GW3( GW4->GW4_FILIAL, GW4->GW4_CDESP , GW4->GW4_EMISDF , GW4->GW4_SERDF , GW4->GW4_NRDF , GW4->GW4_DTEMIS )

		GW4->( dbSkip() )
	EndDo

	//Restaura a area da tabela GW4
	RestArea( aAreaGW4 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW3

DOCUMENTOS DE FRETE

@Param cCdEsp   - Especie documento de frete
@Param cEmisDf  - Emissor documento de frete
@Param cSerDf   - Serie documento de frete
@Param cNrDf    - Numero do documento de frete
@Param dDtEmiss - Data de emissão do documento de frete

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW3( cCodFil, cCdEsp , cEmisDf , cSerDf , cNrDf , dDtEmiss )
	Local aAreaGW3 := GW3->( GetArea() ) //Guarda a Area da tabela GW3

	//Seta a tabela
	dbSelectArea("GW3")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW3 := DBStruct (  )
	//Seta o indice utilizado
	GW3->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GW3->( dbSeek( cCodFil + cCdEsp + cEmisDf + cSerDf + cNrDf + Dtos( dDtEmiss ) ) )

		oArquivo:Add( "GW3_CHAVIN |" + Space(3) + "| " + "GW3_FILIAL: " + GW3->GW3_FILIAL +;
											 	 " | " + "GW3_CDESP: "  + GW3->GW3_CDESP  +;
											 	 " | " + "GW3_EMISDF: " + GW3->GW3_EMISDF +;
											 	 " | " + "GW3_SERDF: "  + GW3->GW3_SERDF  +;
											 	 " | " + "GW3_NRDF: "   + GW3->GW3_NRDF   +;
											 	 " | " + "GW3_DTEMIS: " + DTOS(GW3->GW3_DTEMIS) )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW3 , "GW3" )

		//Especie Documento de Frete
		GFES001GVT( GW3->GW3_CDESP )

		//Fatura frete
		GFES001GW6( GW3->GW3_FILIAL, GW3->GW3_EMIFAT , GW3->GW3_SERFAT , GW3->GW3_NRFAT )

	Endif

	//Restaura a area da tabela GW3
	RestArea( aAreaGW3 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GVT

ESPECIES DE DOCUMENTO DE FRETE

@Param cCdEsp - Especie documento de frete

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GVT( cCdEsp )
	Local aAreaGW3 := GW3->( GetArea() ) //Guarda a Area da tabela GVT

	//Seta a tabela
	dbSelectArea("GVT")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGVT := DBStruct (  )
	//Seta o indice utilizado
	GVT->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GVT->( dbSeek( FWxFilial("GVT") + cCdEsp ) )

		oArquivo:Add( "GVT_CHAVIN |" + Space(3) + "| " + "GVT_FILIAL: " + "xx" +;
											 " | " + "GVT_CDESP: "  + GVT->GVT_CDESP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGVT , "GVT" )

	Endif

	//Restaura a area da tabela GVT
	RestArea( aAreaGW3 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU3

EMITENTES DE TRANSPORTE

@Param cCdEmit - Codigo do emitente

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU3( cCdEmit )
	Local aArea 	:= GetArea()
	Local aStructGU3
	Local aAuxEmit  := NIL
	Local nI        := 0

	//Seta a tabela
	GU3->(dbSelectArea("GU3"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU3 := GU3->(DBStruct())
	//Seta o indice utilizado
	GU3->(dbSetOrder(1))
	// Busca emitentes com mesma raiz de CNPJ
	cCdEmit  := StrTran(GFEGetEmRz(cCdEmit),"'","")
	aAuxEmit := Strtokarr(cCdEmit,",")
	
	For nI := 1 To Len(aAuxEmit)
		//Posiciona no registro de acordo com os parametros
		If GU3->(dbSeek(FWxFilial("GU3") + aAuxEmit[ni]))
			oArquivo:Add( "GU3_CHAVIN |" + Space(3) + "| " + "GU3_FILIAL: " + "xx" +;
													 " | " + "GU3_CDEMIT: " + GU3->GU3_CDEMIT )

			//Envia dados para serem gravados no txt
			EnvDados( aStructGU3 , "GU3" )

			If !Empty( GU3->GU3_NRCID )
				//Cidade
				GFES001GU7( GU3->GU3_NRCID )
			Endif
		EndIf
	Next nI

	RestArea( aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW6

FATURA DE FRETE

@Param cEmiFat - Emissor fatura
@Param cSerFat - Serie da fatura
@Param cNrFat  - Numero da fatura

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW6( cCodFil, cEmiFat , cSerFat , cNrFat )
	Local aAreaGW6 := GW6->( GetArea() ) //Guarda a Area da tabela GW6

	//Seta a tabela
	dbSelectArea("GW6")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW6 := DBStruct (  )
	//Seta o indice utilizado
	GW6->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If (GW6->( dbSeek( cCodFil + cEmiFat + cSerFat + cNrFat ) )	.And. nControlFat == 0)

		oArquivo:Add( "GW6_CHAVIN |" + Space(3) + "| " + "GW6_FILIAL: " + GW6->GW6_FILIAL +;
											 	 " | " + "GW6_EMIFAT: " + GW6->GW6_EMIFAT +;
											 	 " | " + "GW6_SERFAT: " + GW6->GW6_SERFAT +;
											 	 " | " + "GW6_NRFAT: "  + GW6->GW6_NRFAT )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW6 , "GW6" )

	Endif

	//Pré-fatura
	GFES001GWJ( GW6->GW6_FILIAL , GW6->GW6_EMIFAT , GW6->GW6_SERFAT , GW6->GW6_NRFAT , /*cFilPre*/ , /*cNrPref*/ , 7 )

	//Restaura a area da tabela GW6
	RestArea( aAreaGW6 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWJ

PRE-FATURAS DE FRETE

@Param cFilFat - Filial fatura
@Param cEmiFat - Emitente fatura
@Param cSerFat - Serie fatura
@Param cNrFat  - Numero fatura
@Param cFilPre - Filial pre fatura
@Param cNrPref - Numero da pre fatura
@Param cIndex  - Index utilizado na pesquisa

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWJ( cFilFat , cEmiFat , cSerFat , cNrFat , cFilPre , cNrPref , cIndex )
	//Local aAreaGW6 := GW6->( GetArea() ) //Guarda a Area da tabela GWJ
	Local aAreaGWJ := GWJ->( GetArea() ) //Guarda a Area da tabela GWJ
	Local aAreaGWF := GWF->( GetArea() ) //Guarda a Area da tabela GWF
	Local aAreaGWH := GWH->( GetArea() ) //Guarda a Area da tabela GWH
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GW1
	Local aNrDoc := {}
	Local aStructGWJ
	Local aStructGW1	                      

	//Seta a tabela
	dbSelectArea("GWJ")
	dbSelectArea("GWF")   // Cálculo de Frete
	GWF->( dbSetOrder(3))
	dbSelectArea("GWH")   // Doc do Cálculo de Frete 
	GWH->( dbSetOrder(1))
	dbSelectArea("GW1")   
	GW1->( dbSetOrder(1)) //Documento de Carga
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWJ := GWJ->(DBStruct ( ))	 

	Do Case
		//Utiliza o primeiro indice da tabela GWJ
		Case cIndex == 1
			//Seta o indice utilizado
			GWJ->( dbSetOrder(1) )

			//Posiciona no registro de acordo com os parametros
			If GWJ->( dbSeek( cFilPre + cNrPref ) )

				oArquivo:Add( "GWJ_CHAVIN |" + Space(3) + "| " + "GWJ_FILIAL: " + GWJ->GWJ_FILIAL +;
													 	 " | " + "GWJ_NRPF: "   + GWJ->GWJ_NRPF )

				CriaGWJ( aStructGWJ )

			Endif
		//Utiliza o segundo indice da tabela GWJ
		Case cIndex == 7

			//Seta o indice utilizado
			GWJ->( dbSetOrder(7) )

			//Posiciona no registro de acordo com os parametros
			If GWJ->( dbSeek( cFilFat + cEmiFat + cSerFat + cNrFat ) )	.And. !Empty(cFilFat + cEmiFat + cSerFat + cNrFat)
				While !(GWJ->(Eof())) .And.	GWJ->GWJ_FILIAL == cFilFat ;
									  .And. GWJ->GWJ_EMIFAT == cEmiFat ;
									  .And. GWJ->GWJ_SERFAT == cSerFat ;
									  .And. GWJ->GWJ_NRFAT  == cNrFat    

					oArquivo:Add( "GWJ_CHAVIN |" + Space(3) + "| " + "GWJ_FILIAL: " + GWJ->GWJ_FILIAL +;
														 	 " | " + "GWJ_NRPF: "   + GWJ->GWJ_NRPF )
					CriaGWJ( aStructGWJ )

					GFES001GWK(GWJ->GWJ_FILIAL, GWJ->GWJ_NRPF) // Rateios da pré-fatura.

					aStructGW1 := GW1->(DBStruct ( ))	
					If GWF->(dbSeek(GWJ->GWJ_FILIAL + GWJ->GWJ_NRPF ))
						While !GWF->(Eof()) .And. GWF->GWF_FILIAL == GWJ->GWJ_FILIAL .And. GWF->GWF_NRPREF == GWJ->GWJ_NRPF
							If GWH->(dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC ))
								While !GWH->(Eof()) .And. GWH->GWH_FILIAL == GWF->GWF_FILIAL .And. GWH->GWH_NRCALC == GWF->GWF_NRCALC
									If GW1->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC))
										While !GW1->(Eof()) .And. GW1->GW1_FILIAL == GWH->GWH_FILIAL .And. GW1->GW1_CDTPDC == GWH->GWH_CDTPDC .And. GW1->GW1_EMISDC == GWH->GWH_EMISDC  .And. GW1->GW1_SERDC == GWH->GWH_SERDC .And. GW1->GW1_NRDC == GWH->GWH_NRDC
											If AScan(aNrDoc,{|x| x == GW1->GW1_NRDC}) == 0 //Verifica se o doc já  não foi exportado.
												GFES001GW1( GW1->GW1_FILIAL, GW1->GW1_CDTPDC , GW1->GW1_EMISDC , GW1->GW1_SERDC , GW1->GW1_NRDC, .T. ) 
												AAdd(aNrDoc,GW1->GW1_NRDC)									
											EndIf
											GW1->( dbSkip())
										EndDo
									EndIf
									GWH->( dbSkip())
								EndDo
							EndIf
							GWF->( dbSkip())
						EndDo
					EndIf
					
					GWJ->( dbSkip() )
				EndDo
			Endif
	EndCase

	//Restaura a area da tabela GWJ
	RestArea( aAreaGWJ )
	RestArea( aAreaGWF )
	RestArea( aAreaGWH )
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaGWJ

Envia o Struct da tabela GWJ para a função EnvDados()

@Param aStructGWJ - estrutura da tabela GWJ

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriaGWJ( aStructGWJ )
	EnvDados( aStructGWJ , "GWJ" )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWK

RATEIO CONTÁBIL PRÉ-FATURA

@Param cNrPF - Codigo documento de carga

@author  Amanda Rosa Vieira
@since  28/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWK(cCodFil, cNrPf)
	Local aStructGWK  
	Local aAreaGWK := GWK->( GetArea() ) //Guarda a Area da tabela GWK

	dbSelectArea("GWK")   // Cálculo de Frete
	GWK->( dbSetOrder(1))
	
	aStructGWK := GWK->(DBStruct ( ))	 

	If GWK->( dbSeek( cCodFil + cNrPf))
		While !(GWK->(Eof())) .And. GWK->GWK_FILIAL == cCodFil .And. GWK->GWK_NRPF == cNrPf
			oArquivo:Add( "GWK_CHAVIN |" + Space(3) + "| " + "GWK_FILIAL: " + GWK->GWK_FILIAL +;
													 " | " + "GWK_NRPF: "   + GWK->GWK_NRPF +;
													 " | " + "GWK_SEQ: "   + GWK->GWK_SEQ )
			EnvDados( aStructGWK , "GWK" )	
			aStructGWK := GWK->(DBStruct ( ))	
		
			GWK->( dbSkip())
		EndDo
	EndIf
	RestArea( aAreaGWK )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWB

UNITIZADORES DO DOCTO DE CARGA

@Param cCdTpDc - Codigo documento de carga
@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWB( cGW1Fil, cCdTpDc , cEmisDc , cSerDc , cNrDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GWB

	//Seta a tabela
	dbSelectArea("GWB")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWB := DBStruct (  )
	//Seta o indice utilizado
	GWB->( dbSetOrder(2) )
	//Posiciona no registro de acordo com os parametros
	GWB->( dbSeek( cGW1Fil + cCdTpDc + cEmisDc + cSerDc + cNrDc ) )
	While !GWB->( Eof() ) .And. GWB->GWB_FILIAL == cGW1Fil ;
						  .And. GWB->GWB_CDTPDC == cCdTpDc ;
						  .And. GWB->GWB_EMISDC == cEmisDc ;
						  .And. GWB->GWB_SERDC == cSerDc ;
						  .And. GWB->GWB_NRDC == cNrDc

		oArquivo:Add( "GWB_CHAVIN |" + Space(3) + "| " + "GWB_FILIAL: " + GWB->GWB_FILIAL +;
											     " | " + "GWB_NRDC: "   + GWB->GWB_NRDC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWB , "GWB" )

		GWB->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWB
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWH

DOCUMENTO DO CALCULO DE FRETE

@Param cGW1Fil - Codigo da filial do documento de carga
@Param cCdTpDc - Codigo documento de carga
@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWH( cGW1Fil, cCdTpDc , cEmisDc , cSerDc , cNrDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GWH
	Local aAreaGWH := GWH->( GetArea() ) //Guarda a Area da tabela GWH 

	//Seta a tabela
	dbSelectArea("GWH")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWH := DBStruct (  )
	//Seta o indice utilizado
	GWH->( dbSetOrder(2) )
	//Posiciona no registro de acordo com os parametros
	GWH->( dbSeek( cGW1Fil + cCdTpDc + cEmisDc + cSerDc + cNrDc ) )
	While !GWH->( Eof() ) .And. GWH->GWH_FILIAL == cGW1Fil ;
						  .And. GWH->GWH_CDTPDC == cCdTpDc ;
						  .And. GWH->GWH_EMISDC == cEmisDc ;
						  .And. GWH->GWH_SERDC == cSerDc ;
						  .And. GWH->GWH_NRDC   == cNrDc

		oArquivo:Add( "GWH_CHAVIN |" + Space(3) + "| " + "GWH_FILIAL: " + GWH->GWH_FILIAL +;
											     " | " + "GWH_NRCALC: " + GWH->GWH_NRCALC +;
											     " | " + "GWH_CDTPDC: " + GWH->GWH_CDTPDC +;
											     " | " + "GWH_EMISDC: " + GWH->GWH_EMISDC +;
											     " | " + "GWH_SERDC: "  + GWH->GWH_SERDC  +;
											     " | " + "GWH_NRDC: "   + GWH->GWH_NRDC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWH , "GWH" )

		//Cálculos
		GFES001GWF( GWH->GWH_FILIAL, GWH->GWH_NRCALC )

		GWH->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWH
	RestArea( aAreaGW1 )
	RestArea( aAreaGWH )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWF

CALCULO DE FRETE

@Param cGW1Fil - Filial do calculo de frete
@Param cNrCalc - Numero calculo de frete

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWF( cGW1Fil, cNrCalc )
 	Local aAreaGWF := GWF->( GetArea() ) //Guarda a Area da tabela GWF    

	//Seta a tabela
	dbSelectArea("GWF")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWF := DBStruct (  )
	//Seta o indice utilizado
	GWF->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GWF->( dbSeek( cGW1Fil + cNrCalc ) )
	While !GWF->( Eof() ) .And. GWF->GWF_FILIAL == cGW1Fil ;
						  .And. GWF->GWF_NRCALC == cNrCalc

		oArquivo:Add( "GWF_CHAVIN |" + Space(3) + "| " + "GWF_FILIAL: " + GWF->GWF_FILIAL +;
											     " | " + "GWF_NRCALC: " + GWF->GWF_NRCALC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWF , "GWF" )

		If !Empty(GWF->GWF_FILPRE) .And. !Empty(GWF->GWF_NRPREF) .And. (nRadio != 4)
			//Pré-fatura
			GFES001GWJ( /*cFilFat*/ , /*cEmiFat*/ , /*cSerFat*/ , /*cNrFat*/ , GWF->GWF_FILPRE , GWF->GWF_NRPREF , 1 )
		Endif

		//ALIQUOTAS DE ICMS POR UF
		GFES001GUT(GWF->GWF_CIDORI)

		//Contrato
		GFES001GW2( GWF->GWF_FILIAL, GWF->GWF_NRCONT )

		//Componente cálculo
		GFES001GWI( GWF->GWF_FILIAL, GWF->GWF_NRCALC )

		//Tabela x Cálculo de Frete
		GFES001GWG( GWF->GWF_FILIAL, GWF->GWF_NRCALC )	

		GWF->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWF
	RestArea( aAreaGWF )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW8

UNITIZADORES DO DOCTO DE CARGA

@Param cGW1Fil - Filial do documento de carga
@Param cCdTpDc - Codigo documento de carga
@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW8( cGW1Fil, cCdTpDc , cEmisDc , cSerDc , cNrDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GW8

	//Seta a tabela
	dbSelectArea("GW8")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW8 := DBStruct (  )
	//Seta o indice utilizado
	GW8->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GW8->( dbSeek( cGW1Fil + cCdTpDc + cEmisDc + cSerDc + cNrDc ) )
	While !GW8->( Eof() ) .And. GW8->GW8_FILIAL == cGW1Fil ;
						  .And. GW8->GW8_CDTPDC == cCdTpDc ;
						  .And. GW8->GW8_EMISDC == cEmisDc ;
						  .And. GW8->GW8_SERDC == cSerDc ;
						  .And. GW8->GW8_NRDC   == cNrDc

		oArquivo:Add( "GW8_CHAVIN |" + Space(3) + "| " + "GW8_FILIAL: " + GW8->GW8_FILIAL +;
											 	 " | " + "GW8_CDTPDC: " + GW8->GW8_CDTPDC +;
											 	 " | " + "GW8_EMISDC: " + GW8->GW8_EMISDC +;
											 	 " | " + "GW8_SERDC: "  + GW8->GW8_SERDC  +;
											 	 " | " + "GW8_NRDC: "   + GW8->GW8_NRDC   +;
											 	 " | " + "GW8_ITEM: "   + GW8->GW8_ITEM )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW8 , "GW8" )

		//Classificação de frete
		GFES001GUB( GW8->GW8_CDCLFR )

		GW8->( dbSkip() )
	EndDo

	//Restaura a area da tabela GW8
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUB

CLASSIFICACOES DE FRETE

@Param cCdClFr - Codigo classificação de frete

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUB( cCdClFr )
	Local aArea 	:= GetArea()
	Local aStructGUB	

	//Seta a tabela
	GUB->(dbSelectArea("GUB"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUB := GUB->(DBStruct())
	//Seta o indice utilizado
	GUB->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	If GUB->(dbSeek(FWxFilial("GUB") + cCdClFr))

		oArquivo:Add( "GUB_CHAVIN |" + Space(3) + "| " + "GUB_FILIAL: " + "xx" +;
											 	 " | " + "GUB_CDCLFR: " + GUB->GUB_CDCLFR )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUB , "GUB" )

	Endif

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUT

ALIQUOTAS DE ICMS POR UF

@Param cUf - Codigo UF da aliquota

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUT(cUfOri)
	Local aAreaGUT := GUT->( GetArea() ) //Guarda a Area da tabela GUT

	cUFOrigem  := Posicione("GU7",1,FWxFilial("GU7")+cUfOri,"GU7_CDUF")
	//Seta a tabela
	dbSelectArea("GUT")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUT := DBStruct (  )
	//Seta o indice utilizado
	GUT->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUT->( dbSeek( FWxFilial("GUT") + cUFOrigem ) )

		oArquivo:Add( "GUT_CHAVIN |" + Space(3) + "| " + "GUT_FILIAL: " + "xx" +;
											     " | " + "GUT_UF: "     + GUT->GUT_UF )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUT , "GUT" )

		//EXCECOES DE TRIBUTACAO DE ICMS
		GFES001GUR()

	Endif

	//Restaura a area da tabela GUT
	RestArea( aAreaGUT )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUR

EXCECOES DE TRIBUTACAO DE ICMS

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUR()
	Local aAreaGW1 		:= GW1->( GetArea() ) //Guarda a Area da tabela GUR
	Local cTpItens		:= ""
	Local cCdClFr		:= ""
	Local cDestin		:= ""
	Local cConTrp		:= ""
	Local cRgTrbTrp		:= ""
	Local cConRem		:= ""
	Local cRgTriRem		:= ""
	Local cConDest		:= ""
	Local cRgTriDest	:= ""
	Local cUFOrigem		:= ""
	Local cUFDestino	:= ""
	Local cCdtpop		:= ""

	If !Empty(GW1->GW1_ENTNRC) .And. GW1->GW1_ENTNRC != PadR("0",50)
		cDestin := GW1->GW1_ENTNRC
	Else
		cDestin := Posicione("GU3",1,FWxFilial("GU3")+GW1->GW1_CDDEST,"GU3_NRCID")
	Endif

	//Seta a tabela
	dbSelectArea("GW8")
	//Seta o indice utilizado
	GW8->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GW8->( dbSeek( FWxFilial("GW8") + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC ) )
		cTpItens := GW8->GW8_TPITEM
		cCdClFr  := GW8->GW8_CDCLFR
		If Empty(cTpItens)
			cTpItens := "*"
		EndIf
	Endif
	
	dbSelectArea("GU3")
	GU3->( dbSetOrder(1) )
	If GU3->( dbSeek( FWxFilial( "Filial" ) + GWF->GWF_TRANSP ) )
		cConTrp   := GU3_CONICM
		cRgTrbTrp := GU3_TPTRIB
	Endif

	If GU3->( dbSeek( FWxFilial( "Filial" ) + GW1->GW1_CDREM ) )
		cConRem   := GU3_CONICM
		cRgTriRem := GU3_TPTRIB
	Endif

	If GU3->( dbSeek( FWxFilial( "Filial" ) + GW1->GW1_CDDEST ) )
		cConDest   := GU3_CONICM
		cRgTriDest := GU3_TPTRIB
	Endif

	cUFOrigem  := Posicione("GU7",1,FWxFilial("GU7")+GWF->GWF_CIDORI,"GU7_CDUF")
	cUFDestino := Posicione("GU7",1,FWxFilial("GU7")+GWF->GWF_CIDDES,"GU7_CDUF")
	cCdtpop    := Posicione("GWN",1,FWxFilial("GWN")+GW1->GW1_NRROM,"GWN_CDTPOP")
	//Seta a tabela
	dbSelectArea("GUR")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUR := DBStruct (  )
	//Seta o indice utilizado
	GUR->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUR->( dbSeek( FWxFilial("GUR") + cUFOrigem + cUFDestino + cTpItens + cCdtpop + cCdClFr + cConTrp + cRgTrbTrp + cConRem + cRgTriRem + cConDest + cRgTriDest + GW1->GW1_USO ) )
			oArquivo:Add( "GUR_CHAVIN |" + Space(3) + "| " + "GUR_FILIAL: " + "xx" +;
												" | " + "GUR_UF: "     + GUR->GUR_UF     +;
												" | " + "GUR_UFDEST: " + GUR->GUR_UFDEST +;
												" | " + "GUR_TPITEM: " + GUR->GUR_TPITEM +;
												" | " + "GUR_CDTPOP: " + GUR->GUR_CDTPOP +;
												" | " + "GUR_TPCLFR: " + GUR->GUR_TPCLFR +;
												" | " + "GUR_TRIBT: "  + GUR->GUR_TRIBT  +;
												" | " + "GUR_TRTRAN: " + GUR->GUR_TRTRAN +;
												" | " + "GUR_TRIBR: "  + GUR->GUR_TRIBR  +;
												" | " + "GUR_TRREM: "  + GUR->GUR_TRREM  +;
												" | " + "GUR_TRIBD: "  + GUR->GUR_TRIBD  +;
												" | " + "GUR_TRDEST: " + GUR->GUR_TRDEST +;
												" | " + "GUR_USO: "    + GUR->GUR_USO)

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUR , "GUR" )

		//Tipo Item
		GFES001GUQ( GUR->GUR_TPITEM )

	Endif

	//Restaura a area da tabela GUR
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUQ

TIPOS DE ITENS

@Param cTpItem - Codigo do tipo do item

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUQ( cTpItem )
	Local aAreaGUR := GUR->( GetArea() ) //Guarda a Area da tabela GUQ

	//Seta a tabela
	dbSelectArea("GUQ")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUQ := DBStruct (  )
	//Seta o indice utilizado
	GUQ->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUQ->( dbSeek( FWxFilial("GUQ") + cTpItem ) )

		oArquivo:Add( "GUQ_CHAVIN |" + Space(3) + "| " + "GUQ_FILIAL: " + "xx" +;
											  " | " + "GUQ_TPITEM: " + GUQ->GUQ_TPITEM )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUQ , "GUQ" )

	Endif

	//Restaura a area da tabela GUQ
	RestArea( aAreaGUR )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWU

TRECHOS DO ITINERARIO

@Param cGW1Fil - Filial do documento de carga
@Param cCdTpDc - Codigo documento de carga
@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWU( cGW1Fil, cCdTpDc , cEmisDc , cSerDc , cNrDc )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GWU

	//Seta a tabela
	dbSelectArea("GWU")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWU := DBStruct (  )
	//Seta o indice utilizado
	GWU->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GWU->( dbSeek( cGW1Fil + cCdTpDc + cEmisDc + cSerDc + cNrDc ) )
	While !GWU->( Eof() ) .And. GWU->GWU_FILIAL == cGW1Fil ;
						  .And. GWU->GWU_CDTPDC == cCdTpDc ;
						  .And. GWU->GWU_EMISDC == cEmisDc ;
						  .And. GWU->GWU_SERDC == cSerDc ;
						  .And. GWU->GWU_NRDC == cNrDc

		oArquivo:Add( "GWU_CHAVIN |" + Space(3) + "| " + "GWU_FILIAL: " + GWU->GWU_FILIAL +;
											 	 " | " + "GWU_CDTPDC: " + GWU->GWU_CDTPDC +;
											 	 " | " + "GWU_EMISDC: " + GWU->GWU_EMISDC +;
											 	 " | " + "GWU_SERDC: "  + GWU->GWU_SERDC  +;
											 	 " | " + "GWU_NRDC: "   + GWU->GWU_NRDC   +;
											 	 " | " + "GWU_SEQ: "    + GWU->GWU_SEQ )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWU , "GWU" )

		GFES001GU3( GWU->GWU_CDTRP )

		GWU->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWU
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWN

ROMANEIOS DE CARGA

@Param cGW1Fil - Filial do romaneio
@Param cNrRom - Codigo do romaneio

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWN( cGW1Fil, cNrRom )
	Local aAreaGW1 := GW1->( GetArea() ) //Guarda a Area da tabela GWN

	//Seta a tabela
	dbSelectArea("GWN")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWN := DBStruct (  )
	//Seta o indice utilizado
	GWN->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GWN->( dbSeek( cGW1Fil + cNrRom ) )

		oArquivo:Add( "GWN_CHAVIN |" + Space(3) + "| " + "GWN_FILIAL: " + GWN->GWN_FILIAL +;
											 	 " | " + "GWN_NRROM: "  + GWN->GWN_NRROM )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWN , "GWN" )

		//Motoristas
		If !Empty( GWN->GWN_CDMTR )
			//Motoristas
			GFES001GUU( GWN->GWN_CDMTR  )
		EndIf

		If !Empty( GWN->GWN_CDMTR2 )
			//Motoristas
			GFES001GUU( GWN->GWN_CDMTR2 )
		EndIf

		//Veiculos
		If !Empty( GWN->GWN_PLACAD )
			//Veiculos
			GFES001GU8( GWN->GWN_PLACAD )
		EndIf

		If !Empty( GWN->GWN_PLACAM )
			//Veiculos
			GFES001GU8( GWN->GWN_PLACAM )
		EndIf

		If !Empty( GWN->GWN_PLACAT )
			//Veiculos
			GFES001GU8( GWN->GWN_PLACAT )
		EndIf
	EndIf

	//Restaura a area da tabela GWN
	RestArea( aAreaGW1 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUU

MOTORISTAS E AJUDANTES

@Param cCdMtr - Codigo do motorista

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUU( cCdMtr )
	Local aAreaGWN := GWN->( GetArea() ) //Guarda a Area da tabela GUU

	//Seta a tabela
	dbSelectArea("GUU")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUU := DBStruct (  )
	//Seta o indice utilizado
	GUU->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GUU->( dbSeek( FWxFilial("GUU") + cCdMtr ) )

		oArquivo:Add( "GUU_CHAVIN |" + Space(3) + "| " + "GUU_FILIAL: " + "xx" +;
											 " | " + "GUU_CDMTR: "  + GUU->GUU_CDMTR )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUU , "GUU" )

	Endif

	//Restaura a area da tabela GUU
	RestArea( aAreaGWN )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU8

VEICULOS

@Param cPlaca - Placa do veiculo

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU8( cPlaca )
	Local aAreaGWN := GWN->( GetArea() ) //Guarda a Area da tabela GU8

	//Seta a tabela
	dbSelectArea("GU8")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU8 := DBStruct (  )
	//Seta o indice utilizado
	GU8->( dbSetOrder(2) )
	//Posiciona no registro de acordo com os parametros
	If GU8->( dbSeek( FWxFilial("GU8") + cPlaca ) )

		oArquivo:Add( "GU8_CHAVIN |" + Space(3) + "| " + "GU8_FILIAL: " + "xx" +;
											 " | " + "GU8_CDVEIC: " + GU8->GU8_CDVEIC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGU8 , "GU8" )

	Endif

	//Restaura a area da tabela GU8
	RestArea( aAreaGWN )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW2

CONTRATOS COM AUTONOMOS

@Param cGW1Fil - Filial do contrato
@Param cNrCont - Numero do contrato

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW2( cGW1Fil, cNrCont )
	Local aAreaGWF := GWF->( GetArea() ) //Guarda a Area da tabela GW2

	//Seta a tabela
	dbSelectArea("GW2")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW2 := DBStruct (  )
	//Seta o indice utilizado
	GW2->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GW2->( dbSeek( cGW1Fil + cNrCont ) )
	While !GW2->( Eof() ) .And. GW2->GW2_FILIAL == cGW1Fil ;
						  .And. GW2->GW2_NRCONT == cNrCont

		oArquivo:Add( "GW2_CHAVIN |" + Space(3) + "| " + "GW2_FILIAL: " + GW2->GW2_FILIAL +;
											 	 " | " + "GW2_NRCONT: " + GW2->GW2_NRCONT )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW2 , "GW2" )

		//Adicionais contrato
		GFES001GW5( GW2->GW2_FILIAL, GW2->GW2_NRCONT )

		GW2->( dbSkip() )
	EndDo

	//Restaura a area da tabela GW2
	RestArea( aAreaGWF )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW5

VL ADIC CONTRATO

@Param cGW1Fil - Filial do contrato
@Param cNrCont - Numero do contrato

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GW5( cGW1Fil, cNrCont )
	Local aAreaGW2 := GW2->( GetArea() ) //Guarda a Area da tabela GW5

	//Seta a tabela
	dbSelectArea("GW5")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGW5 := DBStruct (  )
	//Seta o indice utilizado
	GW5->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GW5->( dbSeek( cGW1Fil + cNrCont ) )
	While !GW5->( Eof() ) .And. GW5->GW5_FILIAL == cGW1Fil ;
						  .And. GW5->GW5_NRCONT == cNrCont

		oArquivo:Add( "GW5_CHAVIN |" + Space(3) + "| " + "GW5_FILIAL: " + GW5->GW5_FILIAL +;
											 	 " | " + "GW5_NRCONT: " + GW5->GW5_NRCONT +;
											 	 " | " + "GW5_CDVLAD: " + GW5->GW5_CDVLAD )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGW5 , "GW5" )

		GW5->( dbSkip() )
	EndDo

	//Restaura a area da tabela GW5
	RestArea( aAreaGW2 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWI

COMPONENTE DO CALCULO DE FRETE

@Param cGW1Fil - Filial do calculo
@Param cNrCalc - Numero do calculo

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWI( cGW1Fil, cNrCalc )
	Local aAreaGWF := GWF->( GetArea() ) //Guarda a Area da tabela GWI

	//Seta a tabela
	dbSelectArea("GWI")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWI := DBStruct (  )
	//Seta o indice utilizado
	GWI->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GWI->( dbSeek( cGW1Fil + cNrCalc ) )
	While !GWI->( Eof() ) .And. GWI->GWI_FILIAL == cGW1Fil ;
						  .And. GWI->GWI_NRCALC == cNrCalc

		oArquivo:Add( "GWI_CHAVIN |" + Space(3) + "| " + "GWI_FILIAL: " + GWI->GWI_FILIAL +;
											 	 " | " + "GWI_NRCALC: " + GWI->GWI_NRCALC +;
											 	 " | " + "GWI_CDCLFR: " + GWI->GWI_CDCLFR +;
											 	 " | " + "GWI_CDTPOP: " + GWI->GWI_CDTPOP +;
											 	 " | " + "GWI_CDCOMP: " + GWI->GWI_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWI , "GWI" )

		//Componente frete
		GFES001GV2( GWI->GWI_CDCOMP )

		GWI->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWI
	RestArea( aAreaGWF )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GWG

TABELA DO CALCULO DE FRETE

@Param cGW1Fil - Filial do calculo
@Param cNrCalc - Numero do calculo

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GWG( cGW1Fil, cNrCalc )
	Local aAreaGWF := GWF->( GetArea() ) //Guarda a Area da tabela GWG
	Local cCDEMIT , c_NRTAB
	
	Private c_FilTab := ""

	//Seta a tabela
	dbSelectArea("GWG")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGWG := DBStruct (  )
	//Seta o indice utilizado
	GWG->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GWG->( dbSeek( cGW1Fil + cNrCalc ) )
	While !GWG->( Eof() ) .And. GWG->GWG_FILIAL == cGW1Fil ;
						  .And. GWG->GWG_NRCALC == cNrCalc

		oArquivo:Add( "GWG_CHAVIN |" + Space(3) + "| " + "GWG_FILIAL: " + GWG->GWG_FILIAL +;
											     " | " + "GWG_NRCALC: " + GWG->GWG_NRCALC +;
											     " | " + "GWG_CDCLFR: " + GWG->GWG_CDCLFR +;
											     " | " + "GWG_CDTPOP: " + GWG->GWG_CDTPOP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGWG , "GWG" )

		c_FilTab := GWG->GWG_FILIAL
		cCDEMIT  := GWG->GWG_CDEMIT
		c_NRTAB  := GWG->GWG_NRTAB

		dbSelectArea("GVA")
		GVA->( dbSetOrder(1) )
		GVA->( dbSeek( FWxFilial("GVA") + GWG->GWG_CDEMIT + GWG->GWG_NRTAB ) )
		If (GVA->GVA_TPTAB == "2") //Tabela de Vinculo
			//Tabela de Frete
			GFES001GVA( cCDEMIT , c_NRTAB )

			cCDEMIT := GVA->GVA_EMIVIN
			c_NRTAB := GVA->GVA_TABVIN
		EndIf

		//Tabela de Frete
		GFES001GVA( cCDEMIT , c_NRTAB )

		//Negociação tabela de frete
		GFES001GV9( cCDEMIT , c_NRTAB , GWG->GWG_NRNEG )

		//Faixa tipo veiculo tabela de frete
		GFES001GV7( cCDEMIT , c_NRTAB , GWG->GWG_NRNEG , GWG->GWG_CDFXTV )

		//Tarifa Tabela de Frete
		GFES001GV6( cCDEMIT , c_NRTAB , GWG->GWG_NRNEG , GWG->GWG_CDFXTV )

		//Componente Tarifa tabela de frete
		GFES001GV1( cCDEMIT , c_NRTAB , GWG->GWG_NRNEG , GWG->GWG_CDFXTV , GWG->GWG_NRROTA )

		GFES001GV8( cCDEMIT , c_NRTAB , GWG->GWG_NRNEG , GWG->GWG_NRROTA )

		GWG->( dbSkip() )
	EndDo

	//Restaura a area da tabela GWG
	RestArea( aAreaGWF )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV9

NEGOCIACAO TABELA DE FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV9( cCdEmit , cNrTab , cNrNeg )
	Local aAreaGWG := GWG->( GetArea() ) //Guarda a Area da tabela GV9
	Local cSeekGV9 := ""
	
	c_FilTab := Iif(FWModeAccess("GV9",1) == "C", FWxFilial("GV9"), c_FilTab)
	cSeekGV9 := c_FilTab + cCdEmit + cNrTab + Iif(lTabFrComp,"",cNrNeg)

	//Seta a tabela
	dbSelectArea("GV9")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV9 := DBStruct (  )
	//Seta o indice utilizado
	GV9->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GV9->( dbSeek( cSeekGV9 ) )
	While !GV9->( Eof() ) .And.;
		cSeekGV9 == GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB+Iif(lTabFrComp,"",GV9->GV9_NRNEG)

		oArquivo:Add( "GV9_CHAVIN |" + Space(3) + "| " + "GV9_FILIAL: " + "xx" +;
											 " | " + "GV9_CDEMIT: " + GV9->GV9_CDEMIT +;
											 " | " + "GV9_NRTAB: "  + GV9->GV9_NRTAB  +;
											 " | " + "GV9_NRNEG: "  + GV9->GV9_NRNEG )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV9 , "GV9" )

		//Componente tabela de frete
		GFES001GUY( GV9->GV9_FILIAL, GV9->GV9_CDEMIT , GV9->GV9_NRTAB , GV9->GV9_NRNEG )

		//Faixa Entrega tabela de frete
		GFES001GUZ( GV9->GV9_FILIAL, GV9->GV9_CDEMIT , GV9->GV9_NRTAB , GV9->GV9_NRNEG )

		//Tipo de Operação
		GFES001GV4( GV9->GV9_CDTPOP )

		GV9->( dbSkip() )
	EndDo

	//Restaura a area da tabela GV9
	RestArea( aAreaGWG )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} G001GV9TbF
NEGOCIACAO TABELA DE FRETE
@author silvana.torres
@since 25/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cCdEmit, characters, Codigo do emitente
@param cNrTab, characters, Numero da tabela de frete
@param cNrNegDe, characters, Número inicial da faixa da neogicação de frete
@param cNrNegAte, characters, Número final da faixa da neogicação de frete
@type function
/*/
Static Function G001GV9TbF( cCodFil, cCdEmit , cNrTab, cNrNegDe, cNrNegAte)
	Local aArea 	:= GetArea() 
	Local cSeekGV9 	:= cCodFil + cCdEmit + cNrTab

	GV9->(dbSelectArea("GV9"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV9 := GV9->(DBStruct())
	//Seta o indice utilizado
	GV9->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	GV9->(dbSeek(cSeekGV9))
	While !GV9->(Eof()) .And. cSeekGV9 == GV9->GV9_FILIAL+GV9->GV9_CDEMIT+GV9->GV9_NRTAB

		If GV9->GV9_NRNEG >= cNrNegDe .AND. GV9->GV9_NRNEG <= cNrNegAte

			oArquivo:Add( "GV9_CHAVIN |" + Space(3) + "| " + "GV9_FILIAL: " + GV9->GV9_FILIAL +;
												 	 " | " + "GV9_CDEMIT: " + GV9->GV9_CDEMIT +;
												 	 " | " + "GV9_NRTAB: "  + GV9->GV9_NRTAB  +;
												 	 " | " + "GV9_NRNEG: "  + GV9->GV9_NRNEG )

			//Envia dados para serem gravados no txt
			EnvDados( aStructGV9 , "GV9" )

			//Componente tabela de frete
			GFES001GUY( GV9->GV9_FILIAL, GV9->GV9_CDEMIT , GV9->GV9_NRTAB , GV9->GV9_NRNEG )
	
			//Rota da tabela de frete
			G001GV8TbF( GV9->GV9_FILIAL, GV9->GV9_CDEMIT , GV9->GV9_NRTAB , GV9->GV9_NRNEG )
			
			//Faixa Entrega tabela de frete
			GFES001GUZ( GV9->GV9_FILIAL, GV9->GV9_CDEMIT , GV9->GV9_NRTAB , GV9->GV9_NRNEG )
			
			//Região X Regiões
			GFES001GVR( GV9->GV9_NRNEG )
	
			//Tipo de Operação
			GFES001GV4( GV9->GV9_CDTPOP )
			
			//Faixa tipo veiculo tabela de frete
			G001GV7TbF(GV9->GV9_CDEMIT, GV9->GV9_NRTAB, GV9->GV9_NRNEG)
			
			//Tarifa da Tabela de Frete
			G001GV6TbF(GV9->GV9_CDEMIT, GV9->GV9_NRTAB, GV9->GV9_NRNEG)
			
			//Componente Tarifa tabela de frete
			G001GV1TbF( GV9->GV9_CDEMIT, GV9->GV9_NRTAB, GV9->GV9_NRNEG)
			
			//Destinatário
			GFES001GU3(GV9->GV9_CDEMIT)
			
			//Classificação de frete
			GFES001GUB(GV9->GV9_CDCLFR)
		End

		GV9->( dbSkip() )
	EndDo

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV2

COMPONENTE DE FRETE

@Param cCdComp - Codigo do componente

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV2( cCdComp )
	Local aAreaGWI := GWI->( GetArea() ) //Guarda a Area da tabela GV2

	//Seta a tabela
	dbSelectArea("GV2")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV2 := DBStruct (  )
	//Seta o indice utilizado
	GV2->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GV2->( dbSeek( FWxFilial("GV2") + cCdComp ) )

		oArquivo:Add( "GV2_CHAVIN |" + Space(3) + "| " + "GV2_FILIAL: " + "xx" +;
											 " | " + "GV2_CDCOMP: " + GV2->GV2_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV2 , "GV2" )

	Endif

	//Restaura a area da tabela GV2
	RestArea( aAreaGWI )
Return

/*/{Protheus.doc} G001GV2TbF
COMPONENTE DE FRETE

@author silvana.torres
@since 26/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cCdComp, characters, Codigo do componente
@type function
/*/
Static Function G001GV2TbF(cCdComp)
	Local aArea 	:= GetArea()
	Local aStructGV2	

	GV2->(dbSelectArea("GV2"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV2 := GV2->(DBStruct())
	GV2->(dbSetOrder(1))
	If GV2->(dbSeek(FWxFilial("GV2") + cCdComp))

		oArquivo:Add( "GV2_CHAVIN |" + Space(3) + "| " + "GV2_FILIAL: " + "xx" +;
											 	 " | " + "GV2_CDCOMP: " + GV2->GV2_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV2 , "GV2" )

	Endif

	RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUY

COMPONENTE TABELA FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUY( cCodFil, cCdEmit , cNrTab , cNrNeg )
	Local aAreaGV9 := GV9->( GetArea() ) //Guarda a Area da tabela GUY

	//Seta a tabela
	dbSelectArea("GUY")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUY := DBStruct (  )
	//Seta o indice utilizado
	GUY->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GUY->( dbSeek( cCodFil + cCdEmit + cNrTab + cNrNeg ) )
	While !GUY->( Eof() ) .And. GUY->GUY_FILIAL == cCodFil ;
						  .And. GUY->GUY_CDEMIT == cCdEmit ;
						  .And. GUY->GUY_NRTAB == cNrTab ;
						  .And. GUY->GUY_NRNEG == cNrNeg

		oArquivo:Add( "GUY_CHAVIN |" + Space(3) + "| " + "GUY_FILIAL: " + GUY->GUY_FILIAL +;
											 	 " | " + "GUY_CDEMIT: " + GUY->GUY_CDEMIT +;
											 	 " | " + "GUY_NRTAB: "  + GUY->GUY_NRTAB  +;
											 	 " | " + "GUY_NRNEG: "  + GUY->GUY_NRNEG  +;
											 	 " | " + "GUY_CDCOMP: " + GUY->GUY_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUY , "GUY" )

		GUY->( dbSkip() )
	EndDo

	//Restaura a area da tabela GUY
	RestArea( aAreaGV9 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUZ

FAIXA ENTREGA TAB FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUZ( cCodFil, cCdEmit , cNrTab , cNrNeg )
	Local aAreaGV9 	:= GV9->( GetArea() ) //Guarda a Area da tabela GUZ
	Local aStructGUZ

	//Seta a tabela
	GUZ->(dbSelectArea("GUZ"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUZ := GUZ->(DBStruct())
	//Seta o indice utilizado
	GUZ->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	GUZ->(dbSeek( cCodFil + cCdEmit + cNrTab + cNrNeg))
	While !GUZ->( Eof() ) .And. GUZ->GUZ_FILIAL = cCodFil ;
						  .And. GUZ->GUZ_CDEMIT == cCdEmit ;
						  .And. GUZ->GUZ_NRTAB == cNrTab ;
						  .And. GUZ->GUZ_NRNEG == cNrNeg

		oArquivo:Add( "GUZ_CHAVIN |" + Space(3) + "| " + "GUZ_FILIAL: " + GUZ->GUZ_FILIAL +;
											 	 " | " + "GUZ_CDEMIT: " + GUZ->GUZ_CDEMIT +;
											 	 " | " + "GUZ_NRTAB: "  + GUZ->GUZ_NRTAB  +;
											 	 " | " + "GUZ_NRNEG: "  + GUZ->GUZ_NRNEG  +;
											 	 " | " + "GUZ_SEQFAI: " + GUZ->GUZ_SEQFAI )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUZ , "GUZ" )

		GUZ->( dbSkip() )
	EndDo

	//Restaura a area da tabela GUZ
	RestArea( aAreaGV9 )
Return

/*/{Protheus.doc} GFES001GVR
Região X Regiões

@author silvana.torres
@since 26/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cNrNeg, characters, Numero da negociação
@type function
/*/
Static Function GFES001GVR(cNrNeg)
	Local aAreaGV9 := GV9->(GetArea())
	Local aStructGVR

	GVR->(dbSelectArea("GVR"))
	
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGVR := GVR->(DBStruct())
	
	GVR->(dbSetOrder(1))//GVR_FILIAL+GVR_NRREG+GVR_NRREGR
	GVR->(dbSeek(FWxFilial("GVR") + cNrNeg))
	While !GVR->( Eof() ) .And.;
		FWxFilial("GVR")  == GVR->GVR_FILIAL .And. GVR->GVR_NRNEG  == cNrNeg

		oArquivo:Add( "GVR_CHAVIN |" + Space(3) + "| " + "GVR_FILIAL: " + "xx" +;
											 	 " | " + "GVR_NRREG: "  + GVR->GVR_NRREG +;
											 	 " | " + "GVR_NRREGR: " + GVR->GVR_NRREGR)

		//Envia dados para serem gravados no txt
		EnvDados( aStructGVR , "GVR" )

		GVR->( dbSkip() )
	EndDo
	
	RestArea( aAreaGV9 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV4

TIPOS DE OPERACAO

@Param cCdTpOp - Tipo de operação

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV4( cCdTpOp )
	Local aAreaGV9 := GV9->( GetArea() ) //Guarda a Area da tabela GV4
	Local aStructGV4

	//Seta a tabela
	GV4->(dbSelectArea("GV4"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV4 := GV4->(DBStruct())
	//Seta o indice utilizado
	GV4->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	If GV4->(dbSeek(FWxFilial("GV4") + cCdTpOp))

		oArquivo:Add( "GV4_CHAVIN |" + Space(3) + "| " + "GV4_FILIAL: " + "xx" +;
											 	 " | " + "GV4_CDTPOP: " + GV4->GV4_CDTPOP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV4 , "GV4" )

	Endif

	//Restaura a area da tabela GV4
	RestArea( aAreaGV9 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV7

FAIXA/TP VEIC TAB FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação da tabela de frete
@Param cCdFxTv - Seguencia da faixa

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV7( cCdEmit , cNrTab , cNrNeg , cCdFxTv )
	Local aAreaGWG := GWG->( GetArea() ) //Guarda a Area da tabela GV7
	Local cSeekGV7 := ""

	c_FilTab := Iif(FWModeAccess("GV7",1) == "C", FWxFilial("GV7"), c_FilTab)
	cSeekGV7 := c_FilTab + cCdEmit + cNrTab + Iif(lTabFrComp,"",cNrNeg+cCdFxTv)

	//Seta a tabela
	dbSelectArea("GV7")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV7 := DBStruct (  )
	//Seta o indice utilizado
	GV7->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GV7->( dbSeek( cSeekGV7 ) )
	While !GV7->(Eof()) .And.;
		cSeekGV7 == GV7->GV7_FILIAL+GV7->GV7_CDEMIT+GV7->GV7_NRTAB+Iif(lTabFrComp,"",GV7->GV7_NRNEG+GV7->GV7_CDFXTV)

		oArquivo:Add( "GV7_CHAVIN |" + Space(3) + "| " + "GV7_FILIAL: " + "xx" +;
											 " | " + "GV7_CDEMIT: " + GV7->GV7_CDEMIT +;
											 " | " + "GV7_NRTAB: "  + GV7->GV7_NRTAB  +;
											 " | " + "GV7_NRNEG: "  + GV7->GV7_NRNEG  +;
											 " | " + "GV7_CDFXTV: " + GV7->GV7_CDFXTV )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV7 , "GV7" )

		If !Empty( GV7->GV7_CDTPVC )
			//Tipo Véiculo
			GFES001GV3( GV7->GV7_CDTPVC )
		EndIf

		GV7->(DbSkip())
	EndDo

	//Restaura a area da tabela GV7
	RestArea( aAreaGWG )
Return

/*/{Protheus.doc} G001GV7TbF
FAIXA/TP VEIC TAB FRETE

@author silvana.torres
@since 26/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cCdEmit, characters, Codigo do emitente
@param cNrTab, characters, Numero da tabela de frete
@param cNrNeg, characters, Numero da negociação da tabela de frete
@type function
/*/
Static Function G001GV7TbF( cCdEmit, cNrTab, cNrNeg)
	Local aArea 		:= GetArea()
	Local cSeekGV7 		:= FWxFilial("GV7") + cCdEmit + cNrTab + cNrNeg
	Local aStructGV7

	GV7->(dbSelectArea("GV7"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV7 := GV7->(DBStruct())
	GV7->(dbSetOrder(1))
	GV7->(dbSeek(cSeekGV7))
	While !GV7->(Eof()) .And. cSeekGV7 == GV7->GV7_FILIAL+GV7->GV7_CDEMIT+GV7->GV7_NRTAB+GV7->GV7_NRNEG

		oArquivo:Add( "GV7_CHAVIN |" + Space(3) + "| " + "GV7_FILIAL: " + "xx" +;
											 	 " | " + "GV7_CDEMIT: " + GV7->GV7_CDEMIT +;
											 	 " | " + "GV7_NRTAB: "  + GV7->GV7_NRTAB  +;
											 	 " | " + "GV7_NRNEG: "  + GV7->GV7_NRNEG  +;
											 	 " | " + "GV7_CDFXTV: " + GV7->GV7_CDFXTV )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV7 , "GV7" )

		If !Empty( GV7->GV7_CDTPVC )
			//Tipo Véiculo
			GFES001GV3( GV7->GV7_CDTPVC )
		EndIf

		GV7->(DbSkip())
	EndDo

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV3

TIPOS DE VEICULO

@Param cCdTpVc - Codigo do tipo do veiculo

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV3( cCdTpVc )
	Local aAreaGV7 := GV7->( GetArea() ) //Guarda a Area da tabela GV3
	Local aStructGV3

	//Seta a tabela
	GV3->(dbSelectArea("GV3"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV3 := GV3->(DBStruct())
	//Seta o indice utilizado
	GV3->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GV3->( dbSeek( FWxFilial("GV3") + cCdTpVc ) )

		oArquivo:Add( "GV3_CHAVIN |" + Space(3) + "| " + "GV3_FILIAL: " + "xx" +;
											 " | " + "GV3_CDTPVC: " + GV3->GV3_CDTPVC )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV3 , "GV3" )

	Endif

	//Restaura a area da tabela GV3
	RestArea( aAreaGV7 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GVA

TABELA DE FRETE

@Param cEmisDc - Emissor documento
@Param cNrTab  - Numero da tabela de frete

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GVA( cEmisDc , cNrTab )
	Local aAreaGWG := GWG->( GetArea() ) //Guarda a Area da tabela GVA

	c_FilTab := Iif(FWModeAccess("GVA",1) == "C", FWxFilial("GVA"), c_FilTab)

	//Seta a tabela
	dbSelectArea("GVA")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGVA := DBStruct (  )
	//Seta o indice utilizado
	GVA->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GVA->( dbSeek( c_FilTab + cEmisDc + cNrTab ) )

		oArquivo:Add( "GVA_CHAVIN |" + Space(3) + "| " + "GVA_FILIAL: " + "xx" +;
											 " | " + "GVA_CDEMIT: " + GVA->GVA_CDEMIT +;
											 " | " + "GVA_NRTAB: "  + GVA->GVA_NRTAB )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGVA , "GVA" )

		//Componente Tabela Vinculo
		GFES001GVB( GVA->GVA_CDEMIT , GVA->GVA_NRTAB )

	Endif

	//Restaura a area da tabela GVA
	RestArea( aAreaGWG )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GVB

COMPONENTE TABELA VINCULO

@Param cEmisDc - Emissor documento
@Param cNrTab  - Numero da tabela de frete

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GVB( cCdEmit , cNrTab )
	Local aAreaGVA := GVA->( GetArea() ) //Guarda a Area da tabela GVB

	//Seta a tabela
	dbSelectArea("GVB")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGVB := DBStruct (  )
	//Seta o indice utilizado
	GVB->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GVB->( dbSeek( FWxFilial("GVB") + cCdEmit + cNrTab ) )
	While !GVB->( Eof() ) .And.;
		FWxFilial("GVB")  == GVB->GVB_FILIAL .And.;
		GVB->GVB_CDEMIT == cCdEmit         .And.;
		GVB->GVB_NRTAB  == cNrTab

		oArquivo:Add( "GVB_CHAVIN |" + Space(3) + "| " + "GVB_FILIAL: " + "xx" +;
											 " | " + "GVB_CDEMIT: " + GVB->GVB_CDEMIT +;
											 " | " + "GVB_NRTAB: "  + GVB->GVB_NRTAB  +;
											 " | " + "GVB_CDCOMP: " + GVB->GVB_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGVB , "GVB" )

		GVB->( dbSkip() )
	EndDo

	//Restaura a area da tabela GVB
	RestArea( aAreaGVA )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV6

TARIFA DA TABELA DE FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação da tabela de frete
@Param cCdFxTv - Seguencia da faixa

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV6( cCdEmit , cNrTab , cNrNeg , cCdFxTv )
	Local aArea 	:= GetArea()
	Local cSeekGV6 	:= ""
	
	c_FilTab := Iif(FWModeAccess("GV6",1) == "C", FWxFilial("GV6"), c_FilTab)
	cSeekGV6 := c_FilTab + cCdEmit + cNrTab + Iif(lTabFrComp,"",cNrNeg+cCdFxTv)

	//Seta a tabela
	GV6->(dbSelectArea("GV6"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV6 := GV6->(DBStruct())
	//Seta o indice utilizado
	GV6->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	GV6->(dbSeek( cSeekGV6))
	While !GV6->( Eof() ) .And.;
		cSeekGV6  == GV6->GV6_FILIAL+GV6->GV6_CDEMIT+GV6->GV6_NRTAB+Iif(lTabFrComp,"",GV6->GV6_NRNEG+GV6->GV6_CDFXTV)

		oArquivo:Add( "GV6_CHAVIN |" + Space(3) + "| " + "GV6_FILIAL: " + "xx" +;
											 	 " | " + "GV6_CDEMIT: " + GV6->GV6_CDEMIT +;
											 	 " | " + "GV6_NRTAB: "  + GV6->GV6_NRTAB  +;
											 	 " | " + "GV6_NRNEG: "  + GV6->GV6_NRNEG  +;
											 	 " | " + "GV6_CDFXTV: " + GV6->GV6_CDFXTV +;
											 	 " | " + "GV6_NRROTA: " + GV6->GV6_NRROTA )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV6 , "GV6" )

		//Componente tarifa tabela de frete
		GFES001GUC( GV6->GV6_CDEMIT , GV6->GV6_NRTAB , GV6->GV6_NRNEG , GV6->GV6_CDFXTV )

		GV6->( dbSkip() )
	EndDo

	RestArea(aArea)
Return

/*/{Protheus.doc} G001GV6TbF
TARIFA DA TABELA DE FRETE

@author silvana.torres
@since 26/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cCdEmit, characters, Codigo do emitente
@param cNrTab, characters, Numero da tabela de frete
@param cNrNeg, characters, Numero da negociação da tabela de frete
@type function
/*/
Static Function G001GV6TbF(cCdEmit, cNrTab, cNrNeg)
	Local aArea 	:= GetArea()
	Local cSeekGV6 	:= FWxFilial("GV6") + cCdEmit + cNrTab + cNrNeg
	local aStructGV6

	GV6->(dbSelectArea("GV6"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV6 := GV6->(DBStruct())
	GV6->(dbSetOrder(1))
	GV6->(dbSeek(cSeekGV6))
	While !GV6->( Eof() ) .And. cSeekGV6  == GV6->GV6_FILIAL+GV6->GV6_CDEMIT+GV6->GV6_NRTAB+GV6->GV6_NRNEG

		oArquivo:Add( "GV6_CHAVIN |" + Space(3) + "| " + "GV6_FILIAL: " + "xx" +;
											 	 " | " + "GV6_CDEMIT: " + GV6->GV6_CDEMIT +;
											 	 " | " + "GV6_NRTAB: "  + GV6->GV6_NRTAB  +;
											 	 " | " + "GV6_NRNEG: "  + GV6->GV6_NRNEG  +;
											 	 " | " + "GV6_CDFXTV: " + GV6->GV6_CDFXTV +;
											 	 " | " + "GV6_NRROTA: " + GV6->GV6_NRROTA )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV6 , "GV6" )

		//Componente tarifa tabela de frete
		GFES001GUC(GV6->GV6_CDEMIT , GV6->GV6_NRTAB , GV6->GV6_NRNEG , GV6->GV6_CDFXTV)

		GV6->( dbSkip() )
	EndDo

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV1

COMPONENTE TARIFA TAB FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação da tabela de frete
@Param cCdFxTv - Seguencia da faixa
@Param cNrRota - Numero da rota

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV1( cCdEmit , cNrTab , cNrNeg , cCdFxTv , cNrRota )
	Local aAreaGWG := GWG->( GetArea() ) //Guarda a Area da tabela GV1
	Local cSeekGV1 := ""
	
	c_FilTab := Iif(FWModeAccess("GV1",1) == "C", FWxFilial("GV1"), c_FilTab)
	cSeekGV1 := c_FilTab + cCdEmit + cNrTab + Iif(lTabFrComp,"",cNrNeg+cCdFxTv+cNrRota)

	//Seta a tabela
	dbSelectArea("GV1")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV1 := DBStruct (  )
	//Seta o indice utilizado
	GV1->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GV1->( dbSeek( cSeekGV1 ) )
	While !GV1->( Eof() ) .And.;
		cSeekGV1  == GV1->GV1_FILIAL+GV1->GV1_CDEMIT+GV1->GV1_NRTAB+Iif(lTabFrComp,"",GV1->GV1_NRNEG+GV1->GV1_CDFXTV+GV1->GV1_NRROTA)

		oArquivo:Add( "GV1_CHAVIN |" + Space(3) + "| " + "GV1_FILIAL: " + "xx" +;
											 " | " + "GV1_CDEMIT: " + GV1->GV1_CDEMIT +;
											 " | " + "GV1_NRTAB: "  + GV1->GV1_NRTAB  +;
											 " | " + "GV1_NRNEG: "  + GV1->GV1_NRNEG  +;
											 " | " + "GV1_CDFXTV: " + GV1->GV1_CDFXTV +;
											 " | " + "GV1_NRROTA: " + GV1->GV1_NRROTA +;
											 " | " + "GV1_CDCOMP: " + GV1->GV1_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV1 , "GV1" )

		GV1->( dbSkip() )
	EndDo

	//Restaura a area da tabela GV1
	RestArea( aAreaGWG )
Return

/*/{Protheus.doc} G001GV1TbF
COMPONENTE TARIFA TAB FRETE

@author silvana.torres
@since 26/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cCdEmit, characters, Codigo do emitente
@param cNrTab, characters, Numero da tabela de frete
@param cNrNeg, characters, Numero da negociação da tabela de frete
@type function
/*/
Static Function G001GV1TbF( cCdEmit , cNrTab , cNrNeg)
	Local aArea 	:= GetArea()
	Local cSeekGV1 	:= FWxFilial("GV1") + cCdEmit + cNrTab + cNrNeg
	Local aStructGV1

	GV1->(dbSelectArea("GV1"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV1 := GV1->(DBStruct())
	GV1->(dbSetOrder(1))
	GV1->(dbSeek(cSeekGV1))
	
	While !GV1->( Eof() ) .And.;
		cSeekGV1  == GV1->GV1_FILIAL+GV1->GV1_CDEMIT+GV1->GV1_NRTAB+GV1->GV1_NRNEG

		oArquivo:Add( "GV1_CHAVIN |" + Space(3) + "| " + "GV1_FILIAL: " + "xx" +;
											 	 " | " + "GV1_CDEMIT: " + GV1->GV1_CDEMIT +;
											 	 " | " + "GV1_NRTAB: "  + GV1->GV1_NRTAB  +;
											 	 " | " + "GV1_NRNEG: "  + GV1->GV1_NRNEG  +;
											 	 " | " + "GV1_CDFXTV: " + GV1->GV1_CDFXTV +;
											 	 " | " + "GV1_NRROTA: " + GV1->GV1_NRROTA +;
											 	 " | " + "GV1_CDCOMP: " + GV1->GV1_CDCOMP )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV1 , "GV1" )
		
		//Componente
		G001GV2TbF(GV1->GV1_CDCOMP)

		GV1->( dbSkip() )
	EndDo

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GV8

ROTA DA TABELA DE FRETE

@Param cCdEmit - Codigo do emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação da tabela de frete
@Param cNrRota - Numero da rota

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GV8( cCdEmit , cNrTab , cNrNeg , cNrRota )
	Local aAreaGWG := GWG->( GetArea() ) //Guarda a Area da tabela GV8
	Local cSeekGV8 := ""

	c_FilTab := Iif(FWModeAccess("GV8",1) == "C", FWxFilial("GV8"), c_FilTab)
	cSeekGV8 := c_FilTab + cCdEmit + cNrTab + Iif(lTabFrComp,"",cNrNeg+cNrRota)

	//Seta a tabela
	dbSelectArea("GV8")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV8 := DBStruct (  )
	//Seta o indice utilizado
	GV8->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GV8->( dbSeek( cSeekGV8 ) )
	While !GV8->( Eof() ) .And.;
		cSeekGV8 == GV8->GV8_FILIAL+GV8->GV8_CDEMIT+GV8->GV8_NRTAB+Iif(lTabFrComp,"",GV8->GV8_NRNEG+GV8->GV8_NRROTA)

		oArquivo:Add( "GV8_CHAVIN |" + Space(3) + "| " + "GV8_FILIAL: " + "xx" +;
											 " | " + "GV8_CDEMIT: " + GV8->GV8_CDEMIT +;
											 " | " + "GV8_NRTAB: "  + GV8->GV8_NRTAB  +;
											 " | " + "GV8_NRNEG: "  + GV8->GV8_NRNEG  +;
											 " | " + "GV8_NRROTA: " + GV8->GV8_NRROTA )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV8 , "GV8" )

		If !Empty( GV8->GV8_NRCIOR )
			//Cidade
			GFES001GU7( GV8->GV8_NRCIOR )
		EndIf

		If !Empty( GV8->GV8_NRCIDS )
			//Cidade
			GFES001GU7( GV8->GV8_NRCIDS )
		EndIf

		If !Empty( GV8->GV8_NRREOR )
			//Regiao
			GFES001GU9( GV8->GV8_NRREOR )
		EndIf

		If !Empty( GV8->GV8_NRREDS )
			//Regiao
			GFES001GU9( GV8->GV8_NRREDS )
		EndIf

		GV8->( dbSkip() )
	EndDo

	//Restaura a area da tabela GV8
	RestArea( aAreaGWG )
Return

/*/{Protheus.doc} G001GV8TbF
ROTA DA TABELA DE FRETE
@author silvana.torres
@since 25/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cCdEmit, characters, Codigo do emitente
@param cNrTab, characters, Numero da tabela de frete
@param cNrNeg, characters, Numero da negociação da tabela de frete
@type function
/*/
Static Function G001GV8TbF( cCodFil, cCdEmit , cNrTab , cNrNeg)
	Local aArea 	:= GetArea()
	Local cSeekGV8 	:= cCodFil + cCdEmit + cNrTab + cNrNeg
	Local aStructGV8	

	GV8->(dbSelectArea("GV8"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGV8 := GV8->(DBStruct())
	GV8->(dbSetOrder(1))
	GV8->(dbSeek(cSeekGV8))
	While !GV8->( Eof() ) .And. cSeekGV8 == GV8->GV8_FILIAL+GV8->GV8_CDEMIT+GV8->GV8_NRTAB+GV8->GV8_NRNEG

		oArquivo:Add( "GV8_CHAVIN |" + Space(3) + "| " + "GV8_FILIAL: " + GV8->GV8_FILIAL +;
											 	 " | " + "GV8_CDEMIT: " + GV8->GV8_CDEMIT +;
											 	 " | " + "GV8_NRTAB: "  + GV8->GV8_NRTAB  +;
											 	 " | " + "GV8_NRNEG: "  + GV8->GV8_NRNEG  +;
											 	 " | " + "GV8_NRROTA: " + GV8->GV8_NRROTA )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGV8 , "GV8" )

		If !Empty( GV8->GV8_NRCIOR )
			//Cidade
			GFES001GU7( GV8->GV8_NRCIOR )
		EndIf

		If !Empty( GV8->GV8_NRCIDS )
			//Cidade
			GFES001GU7( GV8->GV8_NRCIDS )
		EndIf

		If !Empty( GV8->GV8_NRREOR )
			//Regiao
			GFES001GU9( GV8->GV8_NRREOR )
		EndIf

		If !Empty( GV8->GV8_NRREDS )
			//Regiao
			GFES001GU9( GV8->GV8_NRREDS )
		EndIf

		GV8->( dbSkip() )
	EndDo

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU7

CIDADES

@Param cNrCid - Número da cidade

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU7( cNrCid )
	Local aArea := GetArea()

	//Seta a tabela
	GU7->(dbSelectArea("GU7"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU7 := GU7->(DBStruct())
	//Seta o indice utilizado
	GU7->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	If GU7->(dbSeek( FWxFilial("GU7") + cNrCid))

		oArquivo:Add( "GU7_CHAVIN |" + Space(3) + "| " + "GU7_FILIAL: " + "xx" +;
											 	 " | " + "GU7_NRCID: "  + GU7->GU7_NRCID )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGU7 , "GU7" )

	Endif

	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GU9

REGIOES

@Param cNrReg - Numero da região

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GU9( cNrReg )
	Local aArea 		:= GetArea()
	Local aStructGU9	

	//Seta a tabela
	GU9->(dbSelectArea("GU9"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGU9 := GU9->(DBStruct())
	//Seta o indice utilizado
	GU9->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	If GU9->(dbSeek(FWxFilial("GU9") + cNrReg))

		oArquivo:Add( "GU9_CHAVIN |" + Space(3) + "| " + "GU9_FILIAL: " + "xx" +;
											 	 " | " + "GU9_NRREG: "  + GU9->GU9_NRREG )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGU9 , "GU9" )

		//Região x Cidade
		GFES001GUA( GU9->GU9_NRREG )

		//Região x Faixa de CEP
		GFES001GUL( GU9->GU9_NRREG )

	EndIf

	RestArea( aArea )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUA

REGIAO X CIDADE

@Param cNrReg - Numero da região

@author  Guilherme Alexandre Metzger
@since   06/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUA( cNrReg )
	Local aAreaGU9 := GU9->( GetArea() ) //Guarda a Area da tabela GU9

	//Seta a tabela
	dbSelectArea("GUA")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUA := DBStruct (  )
	//Seta o indice utilizado
	GUA->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GUA->( dbSeek( FWxFilial("GUA") + cNrReg ) )

	While GUA->(!Eof()) .And.;
			GUA->GUA_FILIAL == FWxFilial("GUA") .And.;
			GUA->GUA_NRREG == cNrReg

		oArquivo:Add( "GUA_CHAVIN |" + Space(3) + "| " + "GUA_FILIAL: " + "xx" +;
														 " | " + "GUA_NRREG: "  + GUA->GUA_NRREG  +;
														 " | " + "GUA_NRCID: "  + GUA->GUA_NRCID )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUA , "GUA" )

		GUA->(DbSkip())
	EndDo

	//Restaura a area da tabela GU9
	RestArea( aAreaGU9 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUL

REGIAO X FAIXA DE CEP

@Param cNrReg - Numero da região

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUL( cNrReg )
	Local aAreaGU9 	:= GU9->( GetArea() ) //Guarda a Area da tabela GUL
	Local aStructGUL

	//Seta a tabela
	dbSelectArea("GUL")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUL := DBStruct (  )
	//Seta o indice utilizado
	GUL->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GUL->( dbSeek( FWxFilial("GUL") + cNrReg ) )

	While GUL->(!Eof()) .And.;
			GUL->GUL_FILIAL == FWxFilial('GUL') .And.;
			GUL->GUL_NRREG == cNrReg

		oArquivo:Add( "GUL_CHAVIN |" + Space(3) + "| " + "GUL_FILIAL: " + "xx" +;
														 " | " + "GUL_NRREG: "  + GUL->GUL_NRREG  +;
														 " | " + "GUL_CEPINI: " + GUL->GUL_CEPINI )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUL , "GUL" )

		GUL->(DbSkip()) 
	EndDo

	//Restaura a area da tabela GUL
	RestArea( aAreaGU9 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GUC

COMPONENTE TARIFA X EMITENTE

@Param cCdEmit - Codigo emitente
@Param cNrTab  - Numero da tabela de frete
@Param cNrNeg  - Numero da negociação
@Param cCdFxTv - Codigo faixa

@author  Jorge Matos Valcanaia
@since   21/09/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GUC( cCdEmit , cNrTab , cNrNeg , cCdFxTv )
	Local aAreaGV6 	:= GV6->( GetArea() ) //Guarda a Area da tabela GUC
	Local aStructGUC	

	//Seta a tabela
	GUC->(dbSelectArea("GUC"))
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGUC := GUC->(DBStruct())
	//Seta o indice utilizado
	GUC->(dbSetOrder(1))
	//Posiciona no registro de acordo com os parametros
	If GUC->(dbSeek(FWxFilial("GUC") + cCdEmit + cNrTab + cNrNeg + cCdFxTv))

		oArquivo:Add( "GUC_CHAVIN |" + Space(3) + "| " + "GUC_FILIAL: " + "xx" +;
											 	 " | " + "GUC_CDEMIT: " + GUC->GUC_CDEMIT +;
											 	 " | " + "GUC_NRTAB: "  + GUC->GUC_NRTAB  +;
											 	 " | " + "GUC_NRNEG: "  + GUC->GUC_NRNEG  +;
											 	 " | " + "GUC_CDFXTV: " + GUC->GUC_CDFXTV +;
											 	 " | " + "GUC_NRROTA: " + GUC->GUC_NRROTA +;
											 	 " | " + "GUC_CDCOMP: " + GUC->GUC_CDCOMP +;
											 	 " | " + "GUC_EMICOM: " + GUC->GUC_EMICOM )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGUC , "GUC" )

	Endif

	//Restaura a area da tabela GUC
	RestArea( aAreaGV6 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GW7

Busca todos os rateios contabeis relacionados ao documento de carga

@Param cEmisFat - Emissor da Fatura
@Param cSerFat  - Serie da Fatura
@Param cNrFat   - Nr Fatura da Fatura
@Param dDtFat   - Dt Emissao da Fatura

@author  Amanda Rosa Vieira
@since  06/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------         
Static Function GFES001GW7( cCodFil, cEmisFat , cSerFat , cNrFat, dDtFat)
	Local aAreaGW7 := GW7->( GetArea() ) //Guarda a Area da tabela GW7                      
	
	GW7->( dbSetOrder(1) )  
	dbSelectArea("GW7") 
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt	
	aStructGW7 := DBStruct (  )	   
	
	//Posiciona no registro de acordo com os parametros 
	If (GW7->( dbSeek( cCodFil + cEmisFat + cSerFat + cNrFat + Dtos(dDtFat) ) ) )

		While !(GW7->(Eof())) .And. GW7->GW7_FILIAL == cCodFil ;
							  .And. GW7->GW7_EMIFAT == cEmisFat ;
							  .And. GW7->GW7_SERFAT == cSerFat ;
							  .And. GW7->GW7_NRFAT == cNrFat ;
							  .And. GW7->GW7_DTEMIS == dDtFat

			oArquivo:Add( "GW7_CHAVIN |" + Space(3) + "| " + "GW7_FILIAL: " + GW7->GW7_FILIAL +;
												 	 " | " + "GW7_EMIFAT: " + GW7->GW7_EMIFAT +;
												 	 " | " + "GW7_SERFAT: " + GW7->GW7_SERFAT +;
												 	 " | " + "GW7_NRFAT: " + GW7->GW7_NRFAT +;
												 	 " | " + "GW7_DTEMIS: " + Dtos(GW7->GW7_DTEMIS) +;
												 	 " | " + "GW7_SEQ: " + GW7->GW7_SEQ )

			//Envia dados para serem gravados no txt
			EnvDados( aStructGW7 , "GW7" )

			GW7->( dbSkip() )
		EndDo
	EndIf

	//Restaura a area da tabela GW7
	RestArea( aAreaGW7 )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GXE

Busca lote de provisão

@Param cCodLot - Código de Lote

@author  Gustavo Balieiro Felipe
@since  22/11/2022
@version 1.0
/*/
//-------------------------------------------------------------------         
Static Function GFES001GXE( cCodLot, cFilCal, cNrCal )
	Local aAreaGXE := GXE->( GetArea() ) //Guarda a Area da tabela GXE

	//Seta a tabela
	dbSelectArea("GXE")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGXE := DBStruct (  )
	//Seta o indice utilizado
	GXE->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GXE->( dbSeek( FWxFilial("GXE") + cCodLot ) )

		oArquivo:Add( "GXE_CHAVIN |" + Space(3) + "| " + "GXE_FILIAL: " + GXE->GXE_FILIAL +;
											     " | " + "GXE_CODLOT: " + GXE->GXE_CODLOT)

		//Envia dados para serem gravados no txt
		EnvDados( aStructGXE , "GXE" )

		// CALCULO DE FRETE 
		GFES001GXD(cCodLot, cFilCal, cNrCal)

		//LANÇAMENTOS DE PROVISAO 
		GFES001GXF(GXE->GXE_CODLOT)

	Endif

	//Restaura a area da tabela GXE
	RestArea( aAreaGXE )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GXD

RELATÓRIO DE MOVIMENTAÇÃO DE FRETE

@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga
@Param cTpDc   - Tipo do documento de carga

@author  Matheus de Souza
@since   30/12/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GXD(cCodLot, cFilCal, cNrCal)
	Local aAreaGXD := GXD->( GetArea() ) //Guarda a Area da tabela GXD

	//Seta a tabela
	dbSelectArea("GXD")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGXD := DBStruct (  )
	//Seta o indice utilizado
	GXD->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GXD->(dbSeek(FWxFilial("GXD") + cCodLot + cFilCal + cNrCal))

		oArquivo:Add( "GXD_CHAVIN |" + Space(3) + "| " + "GXD_FILIAL: "  + GXD->GXD_FILIAL   +;
												 " | " + "GXD_CODLOT: "  + GXD->GXD_CODLOT   +;
												 " | " + "GXD_FILCAL: "  + GXD->GXD_FILCAL   +;
												 " | " + "GXD_NRCALC:  " + GXD->GXD_NRCALC    )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGXD , "GXD" )
	EndIf
	//Restaura a area da tabela GXD
	RestArea( aAreaGXD )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GXF

RELATÓRIO DE MOVIMENTAÇÃO DE FRETE

@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga
@Param cTpDc   - Tipo do documento de carga

@author  Matheus de Souza
@since   30/12/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GXF(cCodLot)
	Local aAreaGXF := GXF->( GetArea() ) //Guarda a Area da tabela GXF

	//Seta a tabela
	dbSelectArea("GXF")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGXF := DBStruct (  )
	//Seta o indice utilizado
	GXF->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	If GXF->( dbSeek( FWxFilial("GXF") + cCodLot ) )
		oArquivo:Add( "GXF_CHAVIN |" + Space(3) + "| " + "GXF_FILIAL: " + "xx"                     +;
												 " | " + "GXF_CODLOT: " + GXF->GXF_CODLOT          +;
												 " | " + "GXF_SEQ: "    + cValToChar(GXF->GXF_SEQ) +;
												 " | " + "GXF_DATA: "   + Dtos(GXF->GXF_DATA)      +;												 
												 " | " + "GXF_CONTA: "  + GXF->GXF_CONTA            )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGXF , "GXF" )
	EndIf

	//Restaura a area da tabela GXF
	RestArea( aAreaGXF )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001GX0

RELATÓRIO DE MOVIMENTAÇÃO DE FRETE

@Param cEmisDc - Emissor documento de carga
@Param cSerDc  - Serie documento de carga
@Param cNrDc   - Numero do documento de carga
@Param cTpDc   - Tipo do documento de carga

@author  Matheus de Souza
@since   16/12/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFES001GX0( cGW1Fil, cEmisDc , cSerDc , cNrDc , cTpDc )
	Local aAreaGX0 := GX0->( GetArea() ) //Guarda a Area da tabela GX0

	//Seta a tabela
	dbSelectArea("GX0")
	//Guarda a estrutura da tabela para ser utilizada na gravação do txt
	aStructGX0 := DBStruct (  )
	//Seta o indice utilizado
	GX0->( dbSetOrder(1) )
	//Posiciona no registro de acordo com os parametros
	GX0->( dbSeek( cGW1Fil + cTpDc + cEmisDc + cSerDc + cNrDc ) )
	While !GX0->( Eof() ) .And. GX0->GX0_FILIAL == cGW1Fil ;
						  .And. GX0->GX0_EMISDC == cEmisDc ;
						  .And. GX0->GX0_SERDC == cSerDc ;
						  .And. GX0->GX0_NRDC == cNrDc ;
						  .And. GX0->GX0_CDTPDC == cTpDc

		oArquivo:Add( "GX0_CHAVIN |" + Space(3) + "| " + "GX0_FILIAL: " + GX0->GX0_FILIAL   +;
												 " | " + "GX0_CDTPDC: " + GX0->GX0_CDTPDC   +;
												 " | " + "GX0_EMISDC: " + GX0->GX0_EMISDC   +;
												 " | " + "GX0_SERDC: "  + GX0->GX0_SERDC    +;
												 " | " + "GX0_NRDC: "   + GX0->GX0_NRDC     +;
												 " | " + "GX0_DTEMIS: " + DTOS(GX0->GX0_DTEMIS)+;
												 " | " + "GX0_SEQ: "    + GX0->GX0_SEQ      +;
												 " | " + "GX0_TPFRET: " + GX0->GX0_TPFRET   )

		//Envia dados para serem gravados no txt
		EnvDados( aStructGX0 , "GX0" )

		//Pula para proximo registro da tabela
		GX0->( dbSkip() )
	EndDo

	//Restaura a area da tabela GX0
	RestArea( aAreaGX0 )
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GFES001PAR
Função para extração dos parâmetros do Sistema

@author  Matheus de Souza
@since   19/12/2022
/*/
//-------------------------------------------------------------------
Static Function GFES001PAR()
	Local aAuxParam  := S001ListPar()
	Local cCodFil    := FWCodFil()
	Local nI   	 	 := 0
	Local cValPar 	 := ""
	Local cPar 		 := ""
	Local cDesc		 := ""
	Local cTipo      := ""

	oArquivo:Add( PadR("FILIAL",8) + " | " + PadR("PARÂMETRO",10) + " | "  + PadR("TIPO",4) + " | " + PadR(AllTrim("DESCRIÇÃO"),100)+" | "+ PadR(AllTrim("VALOR"),18) )
	oArquivo:Add( Replicate ( "=" , 157 ))

	nCount := Len(aAuxParam)
	For nI:= 1 To nCount
		cPar  	:= aAuxParam[nI][1]
		cTipo 	:= aAuxParam[nI][2]
		cDesc 	:= aAuxParam[nI][3]
		cValPar := S002RetPar(cPar)
		
		//Grava informações do parâmetro no log
		oArquivo:Add( cCodFil + " | " + PadR(AllTrim(cPar),10) + " | " + PadR(AllTrim(cTipo),4) + " | " + PadR(AllTrim(cDesc),100)+" | "+ PadR(AllTrim(cValPar),30) )
	Next nI

	MsgInfo("Exportação finalizada!")

Return

/*----------------------------------------------------------------------------
Função que envia os dados do struct para o txt
----------------------------------------------------------------------------*/
Static Function EnvDados( aStruct , cAlias )
Local nI := 0

	For nI := 1 to Len(aStruct)
		//Tratamento com o tipo de campo, já que na hora de exportar para o txt todos devem estar como caracter
		Do Case
			//Caracter
			Case aStruct[nI][2] == "C"
				oArquivo:Add( PadR( aStruct[nI][1] , 10 ) + " | " + aStruct[nI][2] +  " | " +  AllTrim((cAlias)->&( aStruct[nI][1] ) ) )
			 //Numerico
			Case aStruct[nI][2] == "N"
				oArquivo:Add( PadR( aStruct[nI][1] , 10 ) + " | " + aStruct[nI][2] +  " | " +  AllTrim(Str( (cAlias)->&(aStruct[nI][1] ) ) ) )
			 //Data
			Case aStruct[nI][2] == "D"
				oArquivo:Add( PadR( aStruct[nI][1] , 10 ) + " | " + aStruct[nI][2] +  " | " +  AllTrim(Dtos( (cAlias)->&(aStruct[nI][1] ) ) ) )
		EndCase
	Next nI

	oArquivo:Add( Replicate ( "-" , 40 ) )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} S001ListPar

Função lista apenas os parametros GFE para extrasão dos parâmetros do Sistema 

@author  Matheus de Souza
@since  18/12/2022
@version 1.0
/*/
//-------------------------------------------------------------------      
Static Function S001ListPar()
	Local aAuxParam := {}
	
	Aadd(aAuxParam, {"MV_GFEFBPR"   ,"C",    "Produto"})
	Aadd(aAuxParam, {"MV_TPEST"     ,"C",    "Tipo Estorno Provisão"})
	Aadd(aAuxParam, {"MV_ERPGFE"    ,"C",    "ERP Integrado"})
	Aadd(aAuxParam, {"MV_TPGRP1"    ,"C",    "Grupo Contábil 1"})
	Aadd(aAuxParam, {"MV_TPGRP2"    ,"C",    "Grupo Contábil 2"})
	Aadd(aAuxParam, {"MV_TPGRP3"    ,"C",    "Grupo Contábil 3"})
	Aadd(aAuxParam, {"MV_TPGRP4"    ,"C",    "Grupo Contábil 4"})
	Aadd(aAuxParam, {"MV_TPGRP5"    ,"C",    "Grupo Contábil 5"})
	Aadd(aAuxParam, {"MV_TPGRP6"    ,"C",    "Grupo Contábil 6"})
	Aadd(aAuxParam, {"MV_TPGRP7"    ,"C",    "Grupo Contábil 7"})
	Aadd(aAuxParam, {"MV_DTULFE"    ,"D",    "Data do Último Fechamento"})
	Aadd(aAuxParam, {"MV_TPGERA"    ,"C",    "Tipo de Geração Contábil"})
	Aadd(aAuxParam, {"MV_ESCTAB"    ,"C",    "Critério de seleção"})
	Aadd(aAuxParam, {"MV_CRIRAT"    ,"C",    "Critério de Rateio"})
	Aadd(aAuxParam, {"MV_CRIRAT2"   ,"C",    "Critério de Rateio Frete Mín Romaneio"})
	Aadd(aAuxParam, {"MV_CRIRAT3"   ,"C",    "Valor usado Rateio/Frete Minimo por Romaneio"})
	Aadd(aAuxParam, {"MV_UMPESO"    ,"C",    "Unidade de Medida para Quilogramas"})
	Aadd(aAuxParam, {"MV_GFECRIC"   ,"C",    "ICMS Frete"})
	Aadd(aAuxParam, {"MV_GFEGVR"    ,"C",    "Realizar a busca de tabelas de frete considerando a tabela GVR (Região x Regiões)?"})
	Aadd(aAuxParam, {"MV_GFEGUL"    ,"C",    "Realizar a busca de tabelas de frete considerando a tabela GUL (Região x Faixa de CEP)?"})
	Aadd(aAuxParam, {"MV_GFEVIN"    ,"C",    "Realizar a busca de tabelas de frete considerando tabelas de tipo vínculo?"})
	Aadd(aAuxParam, {"MV_GFEQBR"    ,"N",    "% Máx Quebra Peso"})
	Aadd(aAuxParam, {"MV_GFEIND"    ,"C",    "Descontar Indenizações"})
	Aadd(aAuxParam, {"MV_CRDPAR"    ,"C",    "Descontar Indenizações"})
	Aadd(aAuxParam, {"MV_GFEPC"     ,"C",    "PIS/COFINS Frete"})
	Aadd(aAuxParam, {"MV_PCPIS"     ,"N",    "Alíquota PIS"})
	Aadd(aAuxParam, {"MV_PCCOFI"    ,"N",    "Alíquota COFINS"})
	Aadd(aAuxParam, {"MV_PISDIF"    ,"N",    "Alíquota PIS Diferenciada"})
	Aadd(aAuxParam, {"MV_COFIDIF"   ,"N",    "Alíquota COFINS Diferenciada"})
	Aadd(aAuxParam, {"MV_ISSBAPI"   ,"C",    "ISS no PIS/COFINS"})
	Aadd(aAuxParam, {"MV_ICMBAPI"   ,"C",    "ICMS Ret no PIS/Cofins"})
	Aadd(aAuxParam, {"MV_DIMRET"    ,"C",    "Imp Retido Componente"})
	Aadd(aAuxParam, {"MV_DRTLOG"    ,"C",    "Diretório LOG"})
	Aadd(aAuxParam, {"MV_LOGCALC"   ,"C",    "Gera log de cálculo?"})
	Aadd(aAuxParam, {"MV_CALDEV"    ,"C",    "Valor Devolução" })
	Aadd(aAuxParam, {"MV_CALREN"    ,"C",    "Valor Reentrega"})
	Aadd(aAuxParam, {"MV_CALSER"    ,"C",    "Valor Serviço"})
	Aadd(aAuxParam, {"MV_TIPREG"    ,"C",    "Regionalização" })
	Aadd(aAuxParam, {"MV_GFETAB1"   ,"C",    "Estrutura de Tabelas de Frete"})
	Aadd(aAuxParam, {"MV_APRTAB"    ,"C",    "Controle de Aprovação"})
	Aadd(aAuxParam, {"MV_PFENTR"    ,"C",    "Registro de Entrega"})
	Aadd(aAuxParam, {"MV_OBNENT"    ,"C",    "Cálculo Normal"})
	Aadd(aAuxParam, {"MV_OBREDE"    ,"C",    "Cálculo Redespacho"})
	Aadd(aAuxParam, {"MV_OBCOMP"    ,"C",    "Cálculo Complementar"})
	Aadd(aAuxParam, {"MV_OBREEN"    ,"C",    "Cálculo Reentrega"})
	Aadd(aAuxParam, {"MV_OBDEV"     ,"C",    "Cálculo Devolução"})
	Aadd(aAuxParam, {"MV_OBSERV"    ,"C",    "Cálculo Serviços"})
	Aadd(aAuxParam, {"MV_CFOFR1"    ,"C",    "CFOP ICMS Estadual"})
	Aadd(aAuxParam, {"MV_CFOFR2"    ,"C",    "CFOP ICMS Interestadual"})
	Aadd(aAuxParam, {"MV_CFOFR3"    ,"C",    "CFOP ISS Mesmo Município"})
	Aadd(aAuxParam, {"MV_CFOFR4"    ,"C",    "CFOP ISS Outro Município"})
	Aadd(aAuxParam, {"MV_GFEVLDT"   ,"C",    "Identificação Única Doc Fret"})
	Aadd(aAuxParam, {"MV_VLCNPJ"    ,"C",    "Transportador Doc Frete"})
	Aadd(aAuxParam, {"MV_GFEVLFT"   ,"C",    "Identificação Única Fatura"})
	Aadd(aAuxParam, {"MV_DCOUT"     ,"C",    "Confere Dados da Carga?"})
	Aadd(aAuxParam, {"MV_DCABE"     ,"C",    "Valor Detalhado"})
	Aadd(aAuxParam, {"MV_DCTOT"     ,"C",    "Valor Total"})
	Aadd(aAuxParam, {"MV_DCVAL"     ,"N",    "Diferença Máxima de Valor"})
	Aadd(aAuxParam, {"MV_DCPERC"    ,"N",    "Diferença Máxima de Percentual"})
	Aadd(aAuxParam, {"MV_DCNEG"     ,"C",    "Diferença Menor"})
	Aadd(aAuxParam, {"MV_CFCONPG"   ,"C",    "Data Vencimento"})
	Aadd(aAuxParam, {"MV_CFAGRUP"   ,"C",    "Agrupamento"})
	Aadd(aAuxParam, {"MV_CFVLFAT"   ,"C",    "Valor"})
	Aadd(aAuxParam, {"MV_CFVLVAR"   ,"N",    "Diferença Máxima de Valor"})
	Aadd(aAuxParam, {"MV_CFPCVAR"   ,"N",    "Diferença Máxima de Percentual"})
	Aadd(aAuxParam, {"MV_GFEDCFA"   ,"C",    "Controle de Compensação de Divergências"})
	Aadd(aAuxParam, {"MV_AUDINF"    ,"C",    "Auditoria Frete Combinado"})
	Aadd(aAuxParam, {"MV_GFE011"    ,"C",    "Auditoria Documentos Complementares"})
	Aadd(aAuxParam, {"MV_GFE012"    ,"C",    "Condição Agendamento Doc Carga"})
	Aadd(aAuxParam, {"MV_PFOBRIG"   ,"C",    "PF Obrigatória"})
	Aadd(aAuxParam, {"MV_APUIRF"    ,"C",    "Apuração IRRF/INSS"})
	Aadd(aAuxParam, {"MV_GFE016"    ,"C",    "Data de Referência para apuração IRRF"})
	Aadd(aAuxParam, {"MV_BASIRF"    ,"N",    "% Base IRRF"})
	Aadd(aAuxParam, {"MV_DEDINS"    ,"C",    "INSS Base IRRF" })
	Aadd(aAuxParam, {"MV_DEDSES"    ,"C",    "SEST/SENAT Base IRRF"})
	Aadd(aAuxParam, {"MV_MINIRF"    ,"N",    "Valor Mínimo IRRF"})
	Aadd(aAuxParam, {"MV_BASINS"    ,"N",    "% Base INSS"})
	Aadd(aAuxParam, {"MV_PCINAU"    ,"N",    "% INSS Autônomo"})
	Aadd(aAuxParam, {"MV_VLMXRE"    ,"N",    "Valor Máximo de INSS"})
	Aadd(aAuxParam, {"MV_PCINEM"    ,"N",    "% INSS Embarcador"})
	Aadd(aAuxParam, {"MV_PCSEST"    ,"N",    "% SEST"})
	Aadd(aAuxParam, {"MV_PCSENA"    ,"N",    "% SENAT"})
	Aadd(aAuxParam, {"MV_ESPDF1"    ,"C",    "Espécie CTR"})
	Aadd(aAuxParam, {"MV_ESPDF3"    ,"C",    "Espécie CT-e"})
	Aadd(aAuxParam, {"MV_ESPDF2"    ,"C",    "Espécie NFST"})
	Aadd(aAuxParam, {"MV_CADERP"    ,"C",    "Origem dos Cadastros"})
	Aadd(aAuxParam, {"MV_GFEEDIL"   ,"C",    "Tipo de Geração de Log"})
	Aadd(aAuxParam, {"MV_CDCLFR"    ,"C",    "Classificação de Frete Padrão"})
	Aadd(aAuxParam, {"MV_EAIURL"    ,"C",    "Url EAI"})
	Aadd(aAuxParam, {"MV_EAIPORT"   ,"C",    "Porta EAI"})
	Aadd(aAuxParam, {"MV_CADOMS"    ,"C",    "Origem dos Cadastros OMS"})
	Aadd(aAuxParam, {"MV_PRITDF"    ,"C",    "Código Produto Registro de Entrada"})
	Aadd(aAuxParam, {"MV_ESCPED"    ,"C",    "Pedágio com TES Própria"})
	Aadd(aAuxParam, {"MV_TPOPEMB"   ,"C",    "Tipo de Operação Padrão"})
	Aadd(aAuxParam, {"MV_DSESPF"    ,"C",    "Espécie Fatura"})
	Aadd(aAuxParam, {"MV_DSEPRO"    ,"C",    "Espécie Provisão"})
	Aadd(aAuxParam, {"MV_DSESCT"    ,"C",    "Espécie Fatura Avulsa"})
	Aadd(aAuxParam, {"MV_DSOFIT"    ,"C",    "Código Item Documento Fiscal"})
	Aadd(aAuxParam, {"MV_DSOFDT"    ,"C",    "Data Transação Documento Fiscal"})
	Aadd(aAuxParam, {"MV_DSICCD"    ,"C",    "Imposto ICMS Retido"  })
	Aadd(aAuxParam, {"MV_DSICCL"    ,"C",    "Classificação ICMS Retido"})
	Aadd(aAuxParam, {"MV_DSISCD"    ,"C",    "Imposto ISS Retido"})
	Aadd(aAuxParam, {"MV_DSISCL"    ,"C",    "Classificação ISS Retido" })
	Aadd(aAuxParam, {"MV_MATREX"    ,"C",    "Matriz de Tradução Externa"})
	Aadd(aAuxParam, {"MV_DSESCO"    ,"C",    "Espécie Contrato"})
	Aadd(aAuxParam, {"MV_DSIRCD"    ,"C",    "Imposto IRRF"})
	Aadd(aAuxParam, {"MV_DSIRCL"    ,"C",    "Classificação IRRF"})
	Aadd(aAuxParam, {"MV_DSIACD"    ,"C",    "Imposto INSS Autônomo" })
	Aadd(aAuxParam, {"MV_DSIACL"    ,"C",    "Classificação INSS Autônomo"})
	Aadd(aAuxParam, {"MV_DSINCD"    ,"C",    "Código Imposto INSS Embarcador"})
	Aadd(aAuxParam, {"MV_DSINCL"    ,"C",    "Classificação Imposto INSS Embarc."})
	Aadd(aAuxParam, {"MV_ADINEM"    ,"C",    "Adc. INSS Embarc. RE"})
	Aadd(aAuxParam, {"MV_DSSSCD"    ,"C",    "Código Imposto SEST/SENAT"})
	Aadd(aAuxParam, {"MV_DSSSCL"    ,"C",    "Classificação Imposto SEST/SENAT"})
	Aadd(aAuxParam, {"MV_XMLDIR"    ,"C",    "Diretorio do XML Totvs Colaboração"})
	Aadd(aAuxParam, {"MV_GFEI19"    ,"C",    "Contrato com RH"})
	Aadd(aAuxParam, {"MV_GFEI20"    ,"C",    "Data Integração Faturamento"})
	Aadd(aAuxParam, {"MV_GFEBI01"   ,"C",    "Freight Expenses Fact"})
	Aadd(aAuxParam, {"MV_GFEBI02"   ,"C",    "Freight Occurrence Fact"})
	Aadd(aAuxParam, {"MV_GFEBI03"   ,"C",    "Freight LeadTime Fact"})
	Aadd(aAuxParam, {"MV_EMPBI"     ,"C",    "Empresa BI"})
	Aadd(aAuxParam, {"MV_FILBI"     ,"C",    "Filial BI"})
	Aadd(aAuxParam, {"MV_GFEI10"    ,"C",    "Nota Fiscal de Entrada"})
	Aadd(aAuxParam, {"MV_GFEI11"    ,"C",    "Nota Fiscal de Saída"})
	Aadd(aAuxParam, {"MV_GFEI12"    ,"C",    "Carga"})
	Aadd(aAuxParam, {"MV_GFEI13"    ,"C",    "Doc. Frete com Fiscal"})
	Aadd(aAuxParam, {"MV_GFEI14"    ,"C",    "Doc. Frete com Custo"})
	Aadd(aAuxParam, {"MV_GFEI15"    ,"C",    "Pré-fatura com Financeiro"})
	Aadd(aAuxParam, {"MV_GFEI16"    ,"C",    "Fatura com Financeiro"})
	Aadd(aAuxParam, {"MV_GFEI23"    ,"C",    "Fiscal Pré-requisito para Atualizar Fatura com Financ."})
	Aadd(aAuxParam, {"MV_GFEI17"    ,"C",    "Contrato com Financeiro"})
	Aadd(aAuxParam, {"MV_GFEI18"    ,"C",    "Contrato com Custo" })
	Aadd(aAuxParam, {"MV_DSDTAP"    ,"C",    "Data Integração Financeiro"})
	Aadd(aAuxParam, {"MV_DSDTRE"    ,"C",    "Data Integração Recebimento"})
	Aadd(aAuxParam, {"MV_GFE002"    ,"C",    "Integração por Item de Transporte"})
	Aadd(aAuxParam, {"MV_WSGFE"     ,"C",    "URL do WebService"})
	Aadd(aAuxParam, {"MV_WSINST"    ,"C",    "Nome da instância"})
	Aadd(aAuxParam, {"MV_FATGFE"    ,"C",    "Nota Fiscal Interrompida" })
	Aadd(aAuxParam, {"MV_PROVCON"   ,"C",    "Provisão Contábil"})
	Aadd(aAuxParam, {"MV_NTFGFE"    ,"C",    "Natureza da Fatura de Frete"})
	Aadd(aAuxParam, {"MV_GFEVLIT"   ,"C",    "Valor do Item"})
	Aadd(aAuxParam, {"MV_CPDGFE"    ,"C",    "Condição de Pagamento do Documento de Frete"})
	Aadd(aAuxParam, {"MV_CDTPOP"    ,"C",    "Código de Operação da Carga"})
	Aadd(aAuxParam, {"MV_INTGFE"    ,"L",    "Integracao com o TOTVS GFE"})
	Aadd(aAuxParam, {"MV_INTGFE2"   ,"C",    "Integracao Direta com TOTVS GFE"})
	Aadd(aAuxParam, {"MV_GFELIM1"   ,"N",    "Valor Máximo Frete Romaneio"})
	Aadd(aAuxParam, {"MV_GFELAC1"   ,"C",    "Ação Frete Romaneio Excedido"})
	Aadd(aAuxParam, {"MV_GFELIM2"   ,"N",    "Valor Máximo Frete Cálculo"})
	Aadd(aAuxParam, {"MV_GFELAC2"   ,"C",    "Ação Frete Cálculo Excedido" })
	Aadd(aAuxParam, {"MV_GFELIM3"   ,"N",    "% Max Frete/Valor Carga"})
	Aadd(aAuxParam, {"MV_GFELAC3"   ,"C",    "Ação % Frete/Valor Excedido"})
	Aadd(aAuxParam, {"MV_GFELIM4"   ,"N",    "Val Max Frete/Peso Carga (Ton)"})
	Aadd(aAuxParam, {"MV_GFELAC4"   ,"C",    "Ação Val Frete/Peso Excedido"})
	Aadd(aAuxParam, {"MV_GFELAC5"   ,"C",    "Ação ao Exceder o Limite do Contrato"})
	Aadd(aAuxParam, {"MV_GFEAJDF"   ,"C",    "Ajuste Cálculo com Documento Frete e/ou Lote de Provisão"})
	Aadd(aAuxParam, {"MV_GFE005"    ,"C",    "Documento de Carga vinculado Documento de Frete"})
	Aadd(aAuxParam, {"MV_GFEOVP"    ,"C",    "Operadora Vale Pedágio" })
	Aadd(aAuxParam, {"MV_EMITMP"    ,"C",    "Código do Emitente"})
	Aadd(aAuxParam, {"MV_ESCTBAT"   ,"C",    "Critério de seleção Cálculo Automático"})
	Aadd(aAuxParam, {"MV_ICMSST"    ,"C",    "ICMS ST"})
	Aadd(aAuxParam, {"MV_TMSGFE"    ,"L",    "Redespachos"})
	Aadd(aAuxParam, {"MV_MOTCAN"    ,"C",    "Motivo Cancelamento Agendamento"})
	Aadd(aAuxParam, {"MV_GFEPVE"    ,"C",    "Permite incluir veículo na portaria?"})
	Aadd(aAuxParam, {"MV_GFECPL"    ,"C",    "Código do veículo"})
	Aadd(aAuxParam, {"MV_GFEPMT"    ,"C",    "Permite incluir motorista na portaria?"})
	Aadd(aAuxParam, {"MV_GFEMVPE"   ,"C",    "Ação Mov Pendente"})
	Aadd(aAuxParam, {"MV_GFEPP01"   ,"N",    "% Tolerância PBT"})
	Aadd(aAuxParam, {"MV_GFEPP02"   ,"N",    "% Tolerância Peso Mínimo Doc Carga"})
	Aadd(aAuxParam, {"MV_GFEPP03"   ,"N",    "% Tolerância Peso Máximo Doc Carga"})
	Aadd(aAuxParam, {"MV_GFEPP04"   ,"L",    "Permite relacionar mais de 1 romaneio nas movimentações"})
	Aadd(aAuxParam, {"MV_DSCTB"     ,"C",    "Contabilização Frete de Vendas"})
	Aadd(aAuxParam, {"MV_ATUCTRC"   ,"C",    "Nota de Rateio no Fiscal"})
	Aadd(aAuxParam, {"MV_TMS2GFE"   ,"C",    "Ocorrências"})
	Aadd(aAuxParam, {"MV_GFEI22"    ,"C",    "Atualização Automática"})
	Aadd(aAuxParam, {"MV_TMS3GFE"   ,"C",    "Viagens"})
	Aadd(aAuxParam, {"MV_REGOCO"    ,"C",    "Ocorrência Entrega"})
	Aadd(aAuxParam, {"MV_CDTIPOE"   ,"C",    "Código Ocorrência Entrega"})
	Aadd(aAuxParam, {"MV_EMIPRO"    ,"C",    "Emitente Estimativa"})
	Aadd(aAuxParam, {"MV_TABPRO"    ,"C",    "Tabela Estimativa"})
	Aadd(aAuxParam, {"MV_NEGPRO"    ,"C",    "Negociação Estimativa"})
	Aadd(aAuxParam, {"MV_LOGCONT"   ,"C",    "Gerar log de contabilização"})
	Aadd(aAuxParam, {"MV_PICOTR"    ,"C",    "PIS/COFINS Transferências"})
	Aadd(aAuxParam, {"MV_PDGPIS"    ,"C",    "Pedágio PIS/COFINS"})
	Aadd(aAuxParam, {"MV_GFEPF1"    ,"C",    "Condição para associar Pré-fatura"})
	Aadd(aAuxParam, {"MV_SERVTO"    ,"C",    "Serviço por Tipo de Ocorrência"})
	Aadd(aAuxParam, {"MV_DSESIM"    ,"L",    "Permite Eliminação Cálculo Simulado"})
	Aadd(aAuxParam, {"MV_CHVNFE"    ,"L",    "Consulta chave do CTE no Portal SEFAZ"})
	Aadd(aAuxParam, {"MV_GFECVFA"   ,"C",    "Calendário Vencimento Fatura Avulsa" })
	Aadd(aAuxParam, {"MV_ALQIRRF"   ,"N",    "Aliquota IRRF"})
	Aadd(aAuxParam, {"MV_IRFPRED"   ,"N",    "% Redução Base Calc. IRRF"})
	Aadd(aAuxParam, {"MV_GFEROTR"   ,"C",    "Dt liberação Romaneio e Transportador obrigatórios"})
	Aadd(aAuxParam, {"MV_ESPDF4"    ,"C",    "Espécie Doc Frete Subcontratação" })
	Aadd(aAuxParam, {"MV_AMBCTEC"   ,"C",    "Ambiente Neogrid para recebimento CT-e"})
	Aadd(aAuxParam, {"MV_AMBICOL"   ,"C",    "Ambiente Neogrid para recebimento NF-e" })
	Aadd(aAuxParam, {"MV_CONFALL"   ,"C",    "Confirma todos os documentos Colaboração?" })
	Aadd(aAuxParam, {"MV_DOCSCOL"   ,"C",    "Tipos de documentos que o TSS deve transmitir"})
	Aadd(aAuxParam, {"MV_NRETCOL"   ,"N",    "Quantidade de registros por importação do TSS"})
	Aadd(aAuxParam, {"MV_USERCOL"   ,"C",    "Usuário Totvs Colaboração"})
	Aadd(aAuxParam, {"MV_PASSCOL"   ,"C",    "Senha TOTVS Colaboração"})
	Aadd(aAuxParam, {"MV_SPEDCOL"   ,"C",    "Utiliza Totvs Colaboração?"})
	Aadd(aAuxParam, {"MV_SPEDURL"   ,"C",    "URL de comunicação com TSS"})
	Aadd(aAuxParam, {"MV_GFETRP"    ,"C",    "Doc Carga x Romaneio"})
	Aadd(aAuxParam, {"MV_RECPRZ"    ,"C",    "Recalcula Prazos"})
	Aadd(aAuxParam, {"MV_CRIVAL"    ,"L",    "Valida critério com os itens do Doc. Carga"})
	Aadd(aAuxParam, {"MV_GFEOCO"    ,"C",    "Data retroativa para ocorrência entrega."})
	Aadd(aAuxParam, {"MV_GFEIDTE"   ,"L",    "Registrar Entrega"	})
	Aadd(aAuxParam, {"MV_GFEOPC"    ,"C",    "Grava Peso Cubado Calculado?"})
	Aadd(aAuxParam, {"MV_TCNEW"     ,"C",    "Tipos de documento transmitidos via TOTVS Colaboração 2.0"})
	Aadd(aAuxParam, {"MV_VERCTE"    ,"C",    "Versão do CTe para TOTVS Colaboração 2.0"})
	Aadd(aAuxParam, {"MV_NGOUT"     ,"C",    "Diretório de saída TOTVS Colaboração 2.0"})
	Aadd(aAuxParam, {"MV_NGINN"     ,"C",    "Diretório de entrada TOTVS Colaboração 2.0"})
	Aadd(aAuxParam, {"MV_GFETOTC"   ,"N",    "Tempo de espera para processar retorno da consulta via TOTVS Colaboração 2.0"})
	Aadd(aAuxParam, {"MV_TREENTR"   ,"C",    "Local de entrega"})
	Aadd(aAuxParam, {"MV_ACGRRAT"   ,"C",    "Ação para item sem Rateio Contábil"})
	Aadd(aAuxParam, {"MV_MTNRERP"   ,"C",    "Mantém Numeração Embarque ERP?"})
	Aadd(aAuxParam, {"MV_NGLIDOS"   ,"C",    "Diretório de arquivos lidos Totvs Colaboração 2.0"})
	Aadd(aAuxParam, {"MV_DSINTTV"   ,"C",    "Integração Tipo de Veículo?"})
	Aadd(aAuxParam, {"MV_RENTNP"    ,"C",    "Registrar Entrega de Documentos de Carga"})
	Aadd(aAuxParam, {"MV_NRPF"      ,"C",    "Numeração Título Provisão"})
	Aadd(aAuxParam, {"MV_TREDESP"   ,"C",    "Redespachantes"})
	Aadd(aAuxParam, {"MV_SITEDC"    ,"C",    "Situação Doc. Carga com Ocorrência Entrega"})
	Aadd(aAuxParam, {"MV_NFEENV"    ,"C",    "Envio XML NFe"})
	Aadd(aAuxParam, {"MV_NFEDIR"    ,"C",    "Diretório XML NFe"})
	Aadd(aAuxParam, {"MV_PLROADE"   ,"C",    "Permite liberar romaneio com data anterior a data de emissão doc carga"})
	Aadd(aAuxParam, {"MV_APRCOP"    ,"C",    "Envio automático para aprovação após Registro Comparativo"})
	Aadd(aAuxParam, {"MV_TESGFE"    ,"C",    "TES Doc. Frete"})
	Aadd(aAuxParam, {"MV_SIGFE"     ,"C",    "Solicita Info Integração"})
	Aadd(aAuxParam, {"MV_GFEISS"    ,"C",    "Utilizar Imposto ISS"})
	Aadd(aAuxParam, {"MV_GFEIRRF"   ,"C",    "Utilizar Imposto IRRF"})
	Aadd(aAuxParam, {"MV_GFEINSS"   ,"C",    "Utilizar Imposto INSS/SEST"})
	Aadd(aAuxParam, {"MV_DFMLA"     ,"C",    "Aprovação de Documentos de Frete via MLA"})
	Aadd(aAuxParam, {"MV_FTMLA"     ,"C",    "Aprovação de Faturas via MLA"})
	Aadd(aAuxParam, {"MV_TFMLA"     ,"C",    "Integração MLA"})
	Aadd(aAuxParam, {"MV_DTROMV"    ,"C",    "Data de liberação do romaneio na partida da viagem"})
	Aadd(aAuxParam, {"MV_LOCTVEI"   ,"C",    "Tipo Veículo Informado"})
	Aadd(aAuxParam, {"MV_GFE006"    ,"C",    "Tipo de Veículo para Cálculo"})
	Aadd(aAuxParam, {"MV_GFEVPRT"   ,"C",    "Valida protocolo/assinatura do CTe?"})
	Aadd(aAuxParam, {"MV_IMPPRO"    ,"C",    "Ação"})
	Aadd(aAuxParam, {"MV_TPEST"     ,"C",    "Tipo Estorno Provisão"})
	Aadd(aAuxParam, {"MV_PEPRONO"   ,"N",    "Período Saldo Prov. Normal (Meses)"})
	Aadd(aAuxParam, {"MV_PEPROES"   ,"N",    "Período Saldo Prov. Estimativa (Meses)"})
	Aadd(aAuxParam, {"MV_PEPROAD"   ,"N",    "Período Saldo Prov. Adicional (Meses)"	})
	Aadd(aAuxParam, {"MV_GFETROT"   ,"C",    "Rotas coincidentes"})
	Aadd(aAuxParam, {"MV_GFEI21"    ,"C",    "Custos de Transporte"})
	Aadd(aAuxParam, {"MV_DESGFE1"   ,"C",    "Despesa de Frete para Doc. Frete Normal"})
	Aadd(aAuxParam, {"MV_DESGFE2"   ,"C",    "Despesa de Frete para Doc. Frete Compl. Valor"})
	Aadd(aAuxParam, {"MV_DESGFE3"   ,"C",    "Despesa de Frete para Doc. Frete Compl. Imposto"})
	Aadd(aAuxParam, {"MV_DESGFE4"   ,"C",    "Despesa de Frete para Doc. Frete Reentrega"})
	Aadd(aAuxParam, {"MV_DESGFE5"   ,"C",    "Despesa de Frete para Doc. Frete Devolução"})
	Aadd(aAuxParam, {"MV_DESGFE6"   ,"C",    "Despesa de Frete para Doc. Frete de Redespacho"})
	Aadd(aAuxParam, {"MV_DESGFE7"   ,"C",    "Despesa de Frete para Doc. Frete de Serviço"})
	Aadd(aAuxParam, {"MV_GFELPR"    ,"C",    "Habilita a geração de log antes da integração com o ERP Protheus?"})
	Aadd(aAuxParam, {"MV_GFE001"    ,"C",    "Ação sobre Documentos de Carga origem ERP"})
	Aadd(aAuxParam, {"MV_INTTAB"    ,"C",    "Integração Tabela de Frete para Consulta Datasul"})
	Aadd(aAuxParam, {"MV_INTFRE"    ,"C",    "Integra as informações de Frete na Nota Fiscal ERP Datasul"})
	Aadd(aAuxParam, {"MV_ICMSPA"    ,"C",    "Calcula ICMS de Pauta"})
	Aadd(aAuxParam, {"MV_GFEFBTE"   ,"C",    "Tipo Espécie"})
	Aadd(aAuxParam, {"MV_GFEFBRA"   ,"C",    "Rastreamento"})
	Aadd(aAuxParam, {"MV_GFEFBLT"   ,"C",    "Lotação"})
	Aadd(aAuxParam, {"MV_GFEFBTP"   ,"C",    "Tipo Preço"})

Return aAuxParam

Function S002RetPar(cParam)
	Local cValParam := AllTrim(cValToChar(SuperGetMV(cParam,.F.,"Parâmetro não existe")))

	If Empty(cValParam)
		cValParam := "Parâmetro em branco"
	EndIf
Return cValParam
