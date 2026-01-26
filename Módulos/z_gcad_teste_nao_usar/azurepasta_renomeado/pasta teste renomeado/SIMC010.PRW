#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "VKEY.CH"
#DEFINE CRLF 				CHR(10)
#DEFINE OFF_TIME_SLA		"FORA-TEMPO-SLA"			// TEMPO DO CONTRATO SLA NAO CUMPRIDO*
#DEFINE ON_TIME_SLA			"NO-TEMPO-SLA"				// TEMPO DO CONTRATO SLA CUMPRIDO
#DEFINE NOT_CONTRATO_SLA	"SEM-SLA-(NAO_CONTRATADO)"	// CLIENTE NAO POSSUI CONTRATO DE SLA
#DEFINE NOT_EXIST_SLA		"SEM-PROCESSO-SLA"			// CHAMADO SEM ATENDIMENTO
#DEFINE OUT_TIME_SLA		"FORA-HORARIO-SLA"			// ATENDIMENTO FORA DO HORARIO COMERCIAL
#DEFINE TIME_TO_END			"PRAZO-A-VENCER"			// AINDA NAO TERMINOU O TEMPO DE ATENDIMENTO E NAO FOI ALOCADO TAMBEM
#DEFINE REJECT				"REJEITADA"					// FNC REJEITADA PELO N3


// Definicoes para teclas de Funcao
#DEFINE ksACTION_ON				1						// Representa a acao de ativar as teclas de funcao
#DEFINE ksACTION_OFF			2						// Representa a acao de desativar as teclas de funcao
// Definicoes da Funcao MyExtract()
#DEFINE	extCODCLIENTE			1
#DEFINE extCODLOJA				2
#DEFINE extCODEQUIPE			3
#DEFINE extMES					4
#DEFINE extANO					5
#DEFINE extEMAIL				6
// Definicoes para o Array aTimeDif
// ---- Primeiro Elemento
#DEFINE atd_FAIXA1				01
#DEFINE atd_FAIXA2				02
#DEFINE atd_FAIXA3				03
#DEFINE atd_FAIXA4				04
// ---- Segundo Elemento
#DEFINE atd_DATA_INICIO			01
#DEFINE atd_HORA_INICIO			02
#DEFINE atd_DATA_FIM			03
#DEFINE atd_HORA_FIM			04
#DEFINE atd_ANALISTA			05
#DEFINE atd_CALCULO_BLOQUEADO	06
#DEFINE atd_SEGUNDOS_CALCULADOS	07
#DEFINE atd_DATA_TMP			08
#DEFINE atd_HORA_TMP			09
#DEFINE atd_NAO_UTILIZADO_10	10
#DEFINE atd_NAO_UTILIZADO_11	11
#DEFINE atd_ANALISTA_AUTO		12
#DEFINE atd_DATA_ABERTURA		13
#DEFINE atd_HORA_ABERTURA		14
#DEFINE atd_TEMPO_CLIENTE		15
#DEFINE atd_NA_FABRICA			16
#DEFINE atd_ASSOCIOU			17
#DEFINE atd_SEGUNDOS_ATE_LIMITE	18
#DEFINE atd_TEMPO_ATE_LIMITE	19

// Static Variables Declarations
Static _bKeyF10
Static _bKeyF11
// -----------------------------

//aFiltros[INDICE]		:= space(1)
//aFiltros[CONDICAO]		:= space(1)
//aFiltros[ORDEM]			:= space(1)
//aFiltros[QUEBRA]		:= .T.
//aFiltros[AGRUPA]		:= .F.
//aFiltros[NSTATUS]		:= space(1)
//aFiltros[EQUIPEDE]		:= space(2)
//aFiltros[EQUIPEATE]		:= space(2)
//aFiltros[CLIENTE]		:= space(100)
//aFiltros[TECNICO]		:= space(100)
//aFiltros[DATADE]		:= stod( strzero( year(ddatabase),4 ) + strzero( month(ddatabase),4 ) + "01" )
//aFiltros[DATAATE]		:= ddatabase
//aFiltros[AUTOSAVE]		:= .T.
//aFiltros[PESQUISATEXTO]	:= .F.
//aFiltros[QUERY]			:= ""
//aFiltros[PRODUTO]		:= SPACE(20)
//aFiltros[ROTINA]		:= SPACE(20)
//aFiltros[CRITICIDADE]	:= SPACE(20)
//aFiltros[SOLUCAO]		:= SPACE(1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/23/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function SimC010()
Local oDash			:= Dashboard():new()
Private aPointRest	:= {}

oDash:Executa()

Return Nil

//Documenta็ใo cria็ใo dos objetos
//Dashboard()
//DashQry()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class Dashboard
	Data lNew     As Logical HIDDEN
	Data oDlgMain As Object

	Method New()							// Constructor
	Method Executa()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class Dashboard
	::lNew := .F.
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Executa( uAutomatico , dDataIni , dDataFim , cArea , cAnalista ) Class Dashboard
Local cAlias := "ADE"
Local bKeyF10 := SetKey( 121, {|| Faixa3( ) } )			// Tecla de Funcao F10
Local bKeyF11 := SetKey( 122, {|| AjusteQuery( ) } )	// Tecla de Funcao F11
// minutos * ( segundos * mili )
Local nTempo := 5 * (60 * 1000)
Local nSpaco := 40
LOCAL nTamBotao := 38
Local _lPhxF1R1    := GetMV("PS_PHXF1R1",,.F.)

Private	aElapTime	:= {}

lVetorExtr	:= If( Type("lVetorExtr") == "U", .F., lVetorExtr )	// Indica lista de campos especifica para o Extrato

Private lGerado := .f.
Private CANCELAMENTOS := "??????" //"000018" // manipulacao do cliente, nao conta

Private cAssuntArea		:= ""
Private lMostraDebug	:= .T.

Private PRODUTIVO := "??????/??????" //'000005,000011,000025,000033,000034,000036,000037,000038,000002,000039,000019,000016'
Private PRODUCAO  := "??????/??????" //+  ',000010,000021'

Private TPFX1INI := "??????/??????" //"000029/000001/000027/000011/000008/000010"
Private TPFX1FIM := "??????/??????"

Private TPFX2INI := "??????/??????"
Private TPFX2FIM := "??????/??????" //"000016/000024/000021/003000/960001/000011/000038/000036/000010" + PRODUCAO

Private TPFX3INI := "??????/??????" //"000011/" + "000016/" + "000002/"
Private TPFX3FIM := "??????/??????" // "090000/490000/000019/120000"

Private TPFX4INI := "??????/??????" //"000011/" + "000016/" + "000002/"
Private TPFX4FIM := "??????/??????" // "090000/490000/000019/120000"

Private TPFXCLIINI := "??????/??????" //"000016/000002/000024/000021/003000/960001"
Private TPFXCLIFIM := "??????/??????"

Private	aFiltro := If (_lPhxF1R1,;
	{{"Pendente Analista","Pend.Cli.-Aceite","Pend.Cli.-Retorno","FNC Pendentes","Pendencias na Qualidade","Chamados Associado","Estatistica Geral" },;
	{"ADE__ENTPE IN ('10','90')","ADE__ENTPE = '20'","ADE__ENTPE = '70'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""},;
	{"ADE__ENTPE IN ('10','90')","ADE__ENTPE = '20'","ADE__ENTPE = '70'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""}},;
	{{"Pendente Analista","Pendente Cliente","FNC Pendentes","Pendencias na Qualidade","Chamados Associado","Estatistica Geral" },;
	{"ADE__ENTPE IN ('10','90')","ADE__ENTPE = '20'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""},;
	{"ADE__ENTPE IN ('10','90')","","ADE__ENTPE = '20'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""}} )

Private aFiltFaixa := { "Geral" , "Atendimento" , "Especํfico" , "Manuten็ใo" }
Private aFiltClFx  := { "Padrใo" , "Prime - Geral" , "Prime - Atendimento" , "Prime - Manuten็ใo" , "Prime - Especํfico" }
Private cRealUser := if ( empty( UAutomatico) , alltrim(strtran(cUserName,"SIGA","TI")) , "AUTO" )
Private oDlgMain,oBrow,oQuant,oOrdem
Private aCols := {}
Private aFiltros := {}
Private nAgrupaItens := 0
Private aStruTmp := {}
Private oFiltro
Private cCliEmail := ""
Private cUserEmail := ""
Private cCodUser
Private oTimer1
Private lCliInt:= .T. //Considera clientes internos (99)?
Private aAreas := {}
Private aMultQ := {} // { conteudo a agrupar, coluna, valor }
Private cBuildOk := "20131012" 
Private 	aCores := { LoadBitmap( GetResources(), 'ENABLE'),;  // Cores padroes do semaforo
LoadBitmap( GetResources(), 'BR_AMARELO' ) ,;
LoadBitmap( GetResources(), 'DISABLE'    ) ,;
LoadBitmap( GetResources(), 'BR_PRETO'   ) ,;
LoadBitmap( GetResources(), 'BR_MARROM'   ) ,;
LoadBitmap( GetResources(), 'X'   ),;
LoadBitmap( GetResources(),"WFCHK"),;
LoadBitmap( GetResources(),"WFUNCHK")  }
Private  cPathLocal := "c:\filtro_ssim\"  //Caminho dos Cubos
Private  cPathCubosAC  := "\simc010\"  //Caminho dos Cubos

Private INDICE			:= 1
Private CONDICAO		:= 2
Private ORDEM			:= 3
Private QUEBRA			:= 4
Private AGRUPA			:= 5
Private NSTATUS			:= 6
Private EQUIPEDE		:= 7
Private EQUIPEATE		:= 8
Private CLIENTE			:= 9
Private TECNICO			:= 10
Private DATADE			:= 11
Private DATAATE			:= 12
Private AUTOSAVE		:= 14
Private FILTRALINHA		:= 16
Private FILTRACABEC		:= 17
Private PESQUISATEXTO	:= 18
Private QUERY			:= 19
Private PRODUTO			:= 20
Private ROTINA			:= 21
Private CRITICIDADE		:= 22
Private SOLUCAO			:= 23

Private lNewFormat		:= .F.

Private cEmBranco := "* EM BRANCO *"
Private cFiltroOld

Private TMP1ATDE	:= "????:??:??"  // "0001:00:00"

Private F2_ALT_URG	:="????:??:??"  //"0018:00:00"
Private F2_MED		:="????:??:??"  //"0032:00:00"
Private F2_BAIXA	:="????:??:??"  //"0096:00:00"

Private F3_ALT_URG	:="????:??:??"  //"0012:00:00"
Private F3_MED		:="????:??:??"  //"056:00:00"
Private F3_BAIXA	:="????:??:??"  //"160:00:00"

Private F3_FSW_ALT_URG	:="????:??:??"  //"0012:00:00"
Private F3_FSW_MED		:="????:??:??"  //"056:00:00"
Private F3_FSW_BAIXA	:="????:??:??"  //"160:00:00"
Private SLA_FSW			:= "??"			// Equipe de FSW do SLA

Private AREAS_SLA_TOTVS := "??"

Private INTERMEDIARIO_ACESSO := ""
Private FULL_ACESSO := "" //"TI0611;TI0808;TI0911/AUTO"
Private MOSTRATEMPOS := .F.
Private CUSERMAIL := ""
Private CSENHAMAIL := ""
Private CFAZQUERY := ""
//private aCache := {}
Private cTexto1 := Space( 255 )
Private cTexto2 := Space( 255 )

Private aColsx := {}

Private cEmpAntcFilAnt := AllTrim( cEmpAnt ) + AllTrim( cFilAnt )
/*

MsgGet2( "Profile", "Indique o profile a ser usado", @cEmpAntcFilAnt, , , )
If !File(cPathCubosAC+"param" + ALLTRIM(cEmpAntcFilAnt) + ".txt")
	MsgGet2( "Profile", "Profile nao encontrado, confirma a cria็ใo?", @cEmpAntcFilAnt, , , )
end
cEmpAntcFilAnt := alltrim(cEmpAntcFilAnt)
*/

// escolha do perfil de acesso
If !EscolheProf()
	Return Nil
EndIf

Private cPathForm := GetPvProfString( GetEnvServer() , "ROOTPATH" , "" , GetAdv97() ) 

If ( SubStr( cPathForm , -1 ) <> "\" )
	cPathForm += "\"
EndIf	

cPathForm += cPathCubosAC
cPathForm := SubStr(cPathForm,1,2) + StrTran( SubStr(cPathForm,3) , "\\" , "\" )

Private cFileConfig := cPathCubosAC + "param" + cEmpAntcFilAnt + ".txt" //param0101.txt
Private cLocalConfig := cPathLocal + "param" + cEmpAntcFilAnt + ".txt" //param0101.txt

Private cFileAcesso := cPathCubosAC + "acess" + cEmpAntcFilAnt + ".txt" //acess0101.txt
Private cLocalAcesso := cPathLocal + "acess" + cEmpAntcFilAnt + ".txt" //acess0101.txt

private cRanking := cPathCubosAC + "Rank" + cEmpAntcFilAnt + ".txt"

Private lModoAntigo := .T.

Private lMUsers := ( cRealUser $ FULL_ACESSO ) // +"|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|MICHELLE.ROLLI|"

Private cPerfil := ""
Private cPerEmail := ""

private AjustaBase := ""
private CLIBCSNOTFAT := ""

Private nAcerto := 0
Private nCache := 0
Private dDataOldAde := Date()
Private lQueryNew := .T. // nova query
Private cDiasVolta := "60"//Quantos dias a query vai olhar para trแs
Private cTpStatist := "Geral"//| Geral | Manutencao | Especifico(Fabrica) | Atendimento |
Private cFiltCliFx := "Padrใo"//A Padrใo | Prime | Atendimento | Manuten็ใo | Fแbrica | 
Private lUsaZ26Clc := .F. //Se o cแlculo de horas vai olhar para o cadastro de Z26 e ZPD
Private lBetween   := .F.
Private lParaEmail := .F.
Private lNwFiltros := .F.

Private lAgrupaTotais := .F.
Private lMostraSoma := .F.

Private acolslinhas := {}

Private cTemp := "C:\FILTRO_SSIM\"

//CLIENTES COM FAIXAS CONTRATADAS
Private CLIFX1 := ""
Private CLIFX1a := ""
Private CLIFX1b := ""
Private CLIFX1c := ""
Private CLIFX1d := ""

Private CLIFX2 := ""
Private CLIFX2a := ""
Private CLIFX2b := ""
Private CLIFX2c := ""
Private CLIFX2d := ""

Private CLIFX3 := ""
Private CLIFX3a := ""
Private CLIFX3b := ""
Private CLIFX3c := ""
Private CLIFX3d := ""

Private CLIFXF3_FSW := ""
Private CLIFXF3_FSWa := ""
Private CLIFXF3_FSWb := ""
Private CLIFXF3_FSWc := ""
Private CLIFXF3_FSWd := ""

Private CBATIDA1 := "08:00:00"
Private CBATIDA2 := "12:00:00"
Private CBATIDA3 := "13:30:00"
Private CBATIDA4 := "18:00:00"

Private T_Privates := {} // 0000000;000000

Private GRUPOPESQ := "N1/N2/N3/HD/NS"
M->ADE_CODSB1 := space(len(ADE->ADE_CODSB1))
Private aGrupos := {}
//PRIVATE cProduto := len(ADE->ADE_CODSB1)//space(3) //
//PRIVATE cVersao := space(6)
M->ADE__VERSA := space(len(ADE->ADE__VERSA))

Private oproblema,osolucao
Private oSproblema,oSsolucao

Private aTotaisSla := { 0, 0, 0, 0, 0, 0, 0, 0 }
Private oFaixas

Private aAreaAn := {}

Private aCliFx1 := {}
Private aCliFx2 := {}
Private aCliFx3 := {}
Private aCliFx4 := {}

Private cFiltraGrupos := ""
Private cTotalBuff	:= ""
Private lAutomatico := !Empty( uAutomatico )
Private cFilChamado := space(6)

Private lAbreFX3		:= .F.

Private PRODT_SSIM		:= ""
Private PRODC_SSIM		:= ""
Private PRODT_PHOENIX	:= ""
Private PRODC_PHOENIX	:= ""
Private cFileTmp		:= criatrab(,.F.)

//Indica quais as filiais que o dash irแ pesquisar os chamados
Private cMultFilial		:= ""
//lista de clientes nao serao excluidos da TOTVS iniciando com 99
Private cEmpFiltra		:= ""

// se mostra ou nao todo o TXT
Private lMostraTxt	 := .F.

Private REABERTURAS	:= ""
Private REJEICOES	:= ""
Private aCache := {}
Private cCPoMostra := ""

Private nSecMail := 0
Private dDataAtu := date() - 1

Private nInterval1 := 0
Private nInterval2 := 0
Private nInterval3 := 0
private nInterval4 := 0

Private cTextFil2 := ""
/*
Parametro para habilitar o modo query, como a base de testes estแ muito lenta esse parametro serแ de testes
*/
Private lAntigo := .F.
/*
Se abre a faixa 2 com uma manipula็ใo do auto
*/
Private lAbreAuto2 := .f.

//novo obj

Private lTemporario := .F.
Private lEnvEmail   := .F.
Private __oRpo

Private nMaxJob := 3
Private nDivide := 1
Private cMultJob := "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" // usuarios que podem usar jobs
// quantidades de jobs que podem ser cirados pela seguinte metrica
/*
if len(aVetProc) < 50
	nMaxJob := aMaxJob[1]
elseif len(aVetProc) < 100
	nMaxJob := aMaxJob[2]
else
	nMaxJob := aMaxJob[3] // deve cair de 6h para 1h
end
*/
Private aMaxJob := {2,3,6}

// Grupos de Atendimento (Equipes)
SU0->(dbSetOrder(2))
SU0->(dbSeek(MyxFilial("SU0")))

SU0->( ;
dbEval( {|| aadd(aGrupos,{.F.,U0_CODIGO,U0_NOME} ) } , {|| U0_FILIAL == myxfilial("SU0") } ) )
// RAMOS T14667
// ZQE_FILIAL ZQE_CODCLI ZQE_LJCLI ZQE_CONTR ZQE_VERSAO ZQE_SERVIC ZQE_FAMILI ZQE_SLA ZQE_INADIM ZQE_CLICOL ZQE_LJCOL ZQE_ATENDE ZQE_EMPFIL ZQE_MIGRAC ZQE_CLICPF ZQE_TOTHR ZQE_VLRHR ZQE_DESCFA
ZQE->(dbsetorder(1)) // cabec USAR ESSE
// ZQG_FILIAL ZQG_CODCLI ZQG_LOJA ZQG_NUMCTR ZQG_CODVER ZQG_SERVIC ZQG_EMPFIL ZQG_PRODUT ZQG_SITUAC ZQG_DATINI ZQG_DATFIM ZQG_TABSER ZQG_NIVSEV ZQG_DTINEQ ZQG_DTFIEQ
ZQG->(dbsetorder(2)) // itens

MakeDir(cPathCubosAC)

If ! lAutomatico
	makedir("c:\filtro_ssim\")
EndIf
T_PRIVATES := { }
CarregaArea( cFileConfig )
CarregaArea( cFileAcesso )

INTERMEDIARIO_ACESSO += "??????/??????" // "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|"

If Empty( FULL_ACESSO )
	FULL_ACESSO += cRealUser
EndIf

lMUsers := ( cRealUser $ FULL_ACESSO  ) //+"|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|"

//lQueryNew := lMUsers

MYmsgrun("Lendo Profile",,{|| MyProfile(.t.) }  )

LoadObj()

If ! lAutomatico
	DEFINE MSDIALOG oDlgMain TITLE "PLATAFORMA DE ATENDIMENTO DIFERENCIADO (build - "+cBuildOk+") " + cRealUser FROM 0,0 TO oMainWnd:nClientHeight-80,oMainWnd:nClientWidth-80 OF oMainWnd PIXEL
	oTimer1 := TTimer():New(nTempo,{ || oTimer1:DeActivate(),myEmails(.t.,.t.),oTimer1:activate() },oDlgMain)
	
	Private NlINHAini := (oDlgMain:nClientHeight/2)-40
	
	
	nColuna := 5
	Private cProblema := ""
	Private cSolucao := ""
	
	nLargura := ( ( oDlgMain:nClientWidth / 2 ) / 2 ) - 10
	
	@ nLinhaini-110, 5 say oSProblema prompt "Incidente:" Pixel of oDlgMain
	@ nLinhaini-100, 5 get oProblema var cProblema  size nLargura,90 memo READONLY Pixel of oDlgMain
	oProblema:lWordWrap := .T.
	
	@ nLinhaini-110,10+nLargura say oSSolucao prompt "Anแlise:" Pixel of oDlgMain
	@ nLinhaini-100,10+nLargura get oSolucao var cSolucao  size nLargura,90 memo READONLY Pixel of oDlgMain
	oSolucao:lWordWrap := .T.
	
	oProblema:hide()
	oSolucao:hide()
	
	oSProblema:hide()
	oSSolucao:hide()
	
	cUserEmail := myposicione("AA1",1, myxfilial("AA1") + cRealUser,"AA1_EMAIL")
	
	@ NlINHAini,nColuna BUTTON "Help" SIZE nTamBotao,11 Pixel ACTION ( criajanela("Instru็๕es",{|| myhelp() },oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 ) )
	
	IF .T.
		@ NlINHAini,nColuna += nSpaco BUTTON "Pesquisar" SIZE nTamBotao,11 Pixel ACTION ( Pesquisar() )
	END
	
	@ NlINHAinI,nColuna += nSpaco BUTTON "Gerar" SIZE nTamBotao,11 Pixel ACTION ( MudaOrdem(),lGerado:=.t. )
	
	If cRealUser $ INTERMEDIARIO_ACESSO .Or. lMUsers	
		@ NlINHAinI,nColuna += nSpaco BUTTON "Ajustar tempo" SIZE nTamBotao,11 Pixel ACTION ( AdjFat() )
	End
	@ NlINHAini,nColuna += nSpaco BUTTON "Refresh" SIZE nTamBotao,11 Pixel ACTION ( MYmsgrun("Atualizando informa็๕es",,{|| MntTemp(.t.),montabrow(),oBrow:gotop() }  ) )
	//	@ NlINHAini,nColuna += nSpaco BUTTON "Enviar email" SIZE nTamBotao,11 Pixel ACTION ( myEmails() )
	//	@ NlINHAini,nColuna += nSpaco BUTTON "Excel Analitico 	" SIZE nTamBotao,11 Pixel ACTION ( if(lGerado,.t.,MudaOrdem()),lGerado:= .t., MYMSGRUN("gerando temporario",,{|| lAgrupaTotais := .F.,ExportExcel()}) )
	@ NlINHAini,nColuna += nSpaco BUTTON "Gerar excel" SIZE nTamBotao,11 Pixel ACTION ChamaExcel( )
	//AjustaTamanho(oDlgMain) //AjustaTamanho(oDlgMain),

	if cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
		//@ NlINHA,nColuna += nSpaco BUTTON "Excel Sintetico" SIZE nTamBotao,11 Pixel ACTION ( IF(aFiltros[NSTATUS] == "Todos",;	MYMSGRUN("gerando temporario",,{|| ValidaTotais() }),;
		@ NlINHAini,nColuna += nSpaco BUTTON oButMonit PROMPT "Ativar monitor" SIZE nTamBotao,11 Pixel ACTION AtivaMonitor(oTimer1,oButMonit)
	END
	If cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
		//@ NlINHAini,nColuna += nSpaco BUTTON "Excel Sintetico" SIZE nTamBotao,11 Pixel ACTION ExcelSintetico( )
		@ NlINHAini,nColuna += nSpaco BUTTON "&Consultas" SIZE nTamBotao,11 Pixel ACTION ( consultas() )
	end
	@ NlINHAini,nColuna += nSpaco BUTTON "Ranking" SIZE nTamBotao,11 Pixel ACTION myRanking()
	
	If cRealUser $ FULL_ACESSO .or. lMUsers
		@ NlINHAini,nColuna += nSpaco BUTTON "Extrato" SIZE nTamBotao,11 Pixel ACTION MyExtract()
	EndIf
	
	IF lMUsers
		@ NlINHAini,nColuna += nSpaco BUTTON "Configura็๕es" SIZE nTamBotao,11 PIXEL ACTION ( Configura() )
		//@ NlINHAini,nColuna += nSpaco BUTTON "Parametros" SIZE nTamBotao,11 PIXEL ACTION ( MontaAnalista() )
		//@ NlINHAini,nColuna += nSpaco BUTTON "Permiss๕es" SIZE nTamBotao,11 PIXEL ACTION ( MontaAcesso() )
		//@ NlINHAini,nColuna += nSpaco BUTTON "Formulas" SIZE nTamBotao,11 PIXEL ACTION ( MontaForm() )
	END
	
	If cRealUser $ "|RENATO.CAMPOS|LUCILENE|MICHELLE.ROLLI|VIU|"
		@ NlINHAini,nColuna += nSpaco BUTTON "GeraFat" SIZE nTamBotao,11 Pixel ACTION MYMSGRUN("Faturamento",,{|| u_SimExpFat() })
	End
	If cRealUser $ "|RENATO.CAMPOS|LUCILENE|MICHELLE.ROLLI|VIU|"
		@ NlINHAini,nColuna += nSpaco BUTTON "Parametros Utilizados" SIZE nTamBotao,11 Pixel ACTION ( Parametros() )
	End
		
	@ NlINHAini,nColuna += nSpaco BUTTON "Sair" SIZE nTamBotao,11 Pixel ACTION ( 	if ( aFiltros[AUTOSAVE],  MYmsgrun("Lendo Profile",,{|| myprofile() }  ), .f. ), oDlgMain:end() )
	
	@ NlINHAini,nColuna += nSpaco Say oQuant PROMPT "" Pixel //QTDE CHAMADOS: 000000
	
	
	@ NlINHAini+14,5 Say oFaixas PROMPT space(500) Pixel
	
	//ACTIVATE MSDIALOG oDlgMain  on init MYmsgrun("Aguarde, gerando informa็๕es",,{||  mudaordem(.F.) }) CENTERED
	Activate MSDIALOG oDlgMain Centered
	ADE->(DbCloseArea())
	ADF->(DbCloseArea())
Else
	If !Empty(dDataIni)
		aFiltros[DATADE] := dDataIni
	End
	If !Empty(dDataFim)
		aFiltros[DATAATE] := dDataFim
	End
	If !Empty(cArea)
		aFiltros[EQUIPEATE] := cArea
	End
	If !Empty(cAnalista)
		aFiltros[TECNICO] := cAnalista
	End
	aFiltros[NSTATUS] := "Estatistica Geral"	
	MntTemp( )
	lAgrupaTotais := .F.
	ExportExcel( )
End
ferase(cFileTmp)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/29/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaTamanho(ODLG)
Local aControles := ODLG:acontrols
Local x,nMax := 0,nTamLine := 0,nMaxCol := 0,nTamCol
Local nComponentes := len(aControles)
Local nPosL := 0.9
Local nPosc := 0.85
// na maioria das janelas nao serแ suportada.
//ODLG:move(ODLG:nTop,ODLG:nLeft,ODLG:nClientWidth-5,50+(nComponentes*15),,.T.)

ODLG:CoorsUpdate()

AEVAL (aControles, {  | aControles | ;
IF(aControles:nTop <= 150,;
nMax := max(nMax,aControles:nTop),""),;
IF(aControles:nRight <= 255,;
nMaxCol := max(nMaxCol,aControles:nLeft),"")} ) 
 
nTamLine := ( ( ( ODLG:nClientHeight -15 ) / nMax)  * nPosL) //-20 ,76
nTamCol := (ODLG:nClientWidth / nMaxCol)*  nPosc //-40
if nTamLine > 45
	nTamLine := 45
end

AEVAL (aControles, {  | aControles | ;
nLinhaOk	:= 10,;//aControles[x]:nTop
nColunaOk	:= 5,;//aControles[x]:nLeft
if(aControles:nTop > 2,;
nLinhaOk := nTamLine * aControles:nTop,""),;
if(aControles:nLeft > 2,;
nColunaOk := nTamCol * aControles:nLeft,""),;
if(aControles:nTop < 255,;
aControles:move(nLinhaOk,nColunaOk,aControles:nWidth,aControles:nHeight,,.F.),""),;
if(aControles:nWidth == 198 .and. aControles:nHeight == 198,;	// tento colocar na janela toda
aControles:move(20,5,ODLG:nClientWidth-5,ODLG:nClientHeight-50,,.F.),"")})

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RunQuery( cQuery )
Local oError := ErrorBlock( { |o| trataerro(o) } )
Local cTrab := Criatrab(,.f.)
Local aStru := {}
Local lError := .F.,x
//fElapTime()
If BuscaCampos( @cQuery )
	Begin sequence
	If Select( "MYQUERY" ) > 0
		MYQUERY->( dbCloseArea() )
	EndIf
	TcQuery ChangeQuery( cQuery ) New Alias "MYQUERY"
	OpenExcel( cTemp + "Query" , cTrab )
	End sequence
	dbCloseArea()
EndIf
ErrorBlock( oError )
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Consultas()
Local oDlg

//fElapTime()

Private aQuerys := {}
Private oCombo
Private cCombo := ""

If Upper(GetEnvServer()) $ "CUSTOMN2"
	Aeval( Directory(cPathLocal+"*.sql"), { |x| Aadd(aQuerys,Strtran(x[1],".SQL","") ) } )
Else
	Aeval( Directory(cPathCubosAC+"*.sql"), { |x| Aadd(aQuerys,Strtran(x[1],".SQL","") ) } )
EndIf

Define MsDialog oDlg From 0,0 To 300,575 Title "Consultas" Pixel

@ 1,1 Say "Escolha a Consulta" Pixel
@ 2,1 COMBOBOX oCombo Var cCombo Items aQuerys SIZE 275,20 Pixel

If Upper(GetEnvServer()) $ "CUSTOMN2"
	@ 3,1  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION rptstatus( {|| cVar := Memoread(cPathLocal+ccombo+".sql"), RunQuery(cVar) })
Else
	@ 3,1  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION rptstatus( {|| cVar := Memoread(cPathCubosAC+ccombo+".sql"), RunQuery(cVar) })
EndIf

@ 3,2  BUTTON "Excluir" SIZE 40,11 Pixel ACTION ( validexclui(@aQuerys), oCombo:refresh() )
@ 3,3  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )

Activate MSDIALOG oDLG Centered On Init AjustaTamanho(oDLG)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValidExclui( aQuerys )
//fElapTime()
If MsgYesNo("Confirma exclusใo da consulta da consulta " + ccombo )

	If upper(getenvserver()) $ "CUSTOMN2"
		fErase(cPathCubosAC+ccombo+".sql")
	Else
		fErase(cPathCubosAC+ccombo+".sql")
	EndIf

	aQuerys := {}

	If Upper( Getenvserver()) $ "CUSTOMN2"
		aEval( Directory( cPathLocal+"*.sql"), { |x| aadd(aQuerys,strtran(x[1],".SQL","") ) } )
	Else
		aEval( Directory( cPathCubosAC+"*.sql"), { |x| aadd(aQuerys,strtran(x[1],".SQL","") ) } )
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaCampos( cQuery )
Local cPerg := ""
Local cRet := space(50)
Local lOk := .T.
//fElapTime()
While At("##",cQuery) > 0 .And. lOk
	cPerg := SubStr(cQuery,At("##",cQuery))
	cPerg := SubStr(cPerg,1,At("###",cPerg)+2)
	lOk := MsgGet2( "Indique o parametro", "Parametro " + StrTran( cPerg , "#" , "" ), @cRet, , , )
	cQuery := StrTran(cQuery,cPerg,rTrim(cRet))
EndDo

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Trataerro(e)
//fElapTime()
If e:GenCode == 15 // alias nao existe
	ChkFile( e:operation )
	Return .T.
EndIf

Alert(e:ErrorStack)

Break

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function retvetor(lForca)
Local aStru := {}
Local nCount
Local cCpoDef := "CHAMADO/COD.CLIENTE/NOME CLIENTE/STATUS/ANALISTA ALOCADO/ABERTURA/H.ABERTURA/DATA (1o FAIXA)/HORA  (1o FAIXA)";
+"DATA LIMITE (1o FAIXA)/HORA LIMITE (1o FAIXA)/TEMPO  (1o FAIXA)/SITUACAO  (1o FAIXA)/ANALISTA  (1o FAIXA)/DATA (2o FAIXA)";
+"HORA  (2o FAIXA)/DATA LIMITE (2o FAIXA)/HORA LIMITE (2o FAIXA)/TEMPO  (2o FAIXA)/TEMPO CLIENTE (2o FAIXA)/SITUACAO  (2o FAIXA)";
+"ANALISTA  (2o FAIXA)/DATA (3o FAIXA)/HORA  (3o FAIXA)/DATA LIMITE (3o FAIXA)/HORA LIMITE (3o FAIXA)/TEMPO  (3o FAIXA)";
+"SITUACAO  (3o FAIXA)/ANALISTA  (3o FAIXA)/ABERTURA  (3o FAIXA)/ABERTURA HORA (3o FAIXA)/FNC NUM/FNC ASSOCIADA/FNC STATUS";
+"FNC CATEGORIA/FNC REJEITADA/INCIDENTE/ANALISE/GRUPO ATEND./MODULO/CRITIC ROTINA/ROTINA/ULT.MOV FINAL/H.ULT.MOV FINAL /PRODUCAO";
+"PRODUTIVIDADE/EQUIPE/DATA_ATENDE/FNC ETAPA/MINUTOS FX1/MINUTOS FX2/MINUTOS FX3/MINUTOS FX4/TEMPO CORRIDO/SITUACAO CORRIDA"//Daniel
Local cCpGrupos := "NOME CLIENTE/SITUACAO  (1o FAIXA)/ANALISTA  (1o FAIXA)/TEMPO  (2o FAIXA)/TEMPO CLIENTE (2o FAIXA)/SITUACAO  (2o FAIXA)";
+"ANALISTA  (2o FAIXA)/TEMPO  (3o FAIXA)/SITUACAO  (3o FAIXA)/ANALISTA  (3o FAIXA)/FNC NUM/PRODUCAO/PRODUTIVIDADE";
+"GRUPO ATEND./CRITIC ROTINA/EQUIPE"
Local cHTEXID	:= "CHAMADO/STATUS/ANALISTA ALOCADO/EQUIPE/CONTATO CLIENTE/VERSAO/MODULO/ROTINA/CRITIC ROTINA/ABERTURA/H.ABERTURA/"
Local cHTEXFX1	:= "DATA (1o FAIXA)/HORA (1o FAIXA)/DATA LIMITE (1o FAIXA)/HORA LIMITE (1o FAIXA)/TEMPO (1o FAIXA)/SITUACAO (1o FAIXA)/"
Local cHTEXFX2	:= "DATA (2o FAIXA)/HORA (2o FAIXA)/DATA LIMITE (2o FAIXA)/HORA LIMITE (2o FAIXA)/TEMPO (2o FAIXA)/SITUACAO (2o FAIXA)/"
Local cHTEXFX3	:= "FNC NUM/FNC PREVISAO/ABERTURA (3o FAIXA)/ABERTURA HORA (3o FAIXA)/DATA LIMITE (3o FAIXA)/HORA LIMITE (3o FAIXA)/TEMPO (3o FAIXA)/SITUACAO (3o FAIXA)/"
Local cHTEXFX4	:= "DATA (FSW FAIXA)/HORA (FSW FAIXA)/DATA LIMITE (FSW FAIXA)/HORA LIMITE (FSW FAIXA)/TEMPO (FSW FAIXA)/SITUACAO (FSW FAIXA)/"
Local cHTEXOOBS	:= "INCIDENTE/ANALISE/ABERTURA_MES_ANO/Causa/"
Local cHTMLExtr := ( cHTEXID + cHTEXFX1 + cHTEXFX2 + cHTEXFX3 + cHTEXFX4 + cHTEXOOBS )

/*
===================================================================================================
1				2		3	4	5			6		7		8			9	10		11						12			13				14				15
Nome_do_Campo	Tipo	Tam	Dec	Descri็ใo	Usado	Soma	NAO USAR	TP	Origem	envia campo por email	pesquisa	Obrigatorio		Campo Original	Filtro
DESCR_RISC		N		3	0	SEMAFORO	.T.		.F.					N	.F.		.F.						.T.			.T.
===================================================================================================
*/
//fElapTime()

AADD(ASTRU,{"DESCR_RISC","N",3,0,"SEMAFORO"					,.F.,.F.,.T.,"N",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"RISCO"		,"N",4,0,"RISCO"					,.F.,.F.,.F.,"N",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"DTABCOMPAC","C",6,0,"ABERTURA_MES_ANO"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"CHAMADO"	,"C",20,0,"CHAMADO"					,.F.,.F.,.T.,"C",.F.,.T.,.T.,.F.,"ADE_CODIGO",""})
AADD(ASTRU,{"MSTATUS"	,"C",20,0,"STATUS"					,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE__ENTPE",""})
AADD(ASTRU,{"AN_ATUAL"	,"C",20,0,"ANALISTA ALOCADO"		,.F.,.F.,.T.,"C",.T.,.T.,.F.,.F.})

AADD(ASTRU,{"AN_AREA+AN_ATUAL"	,"C",20,0,"AREA E ANALISTA ALOCADO"		,.F.,.F.,.T.,"C",.T.,.T.,.F.,.F.})

AADD(ASTRU,{"FAIXA1_TP+CRITIC_CHM"	,"C",20,0,"FAIXA1 E CRITICIDADE"		,.T.,.F.,.T.,"C",.T.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_TP+CRITIC_CHM"	,"C",20,0,"FAIXA2 E CRITICIDADE"		,.T.,.F.,.T.,"C",.T.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_TP+CRITIC_CHM"	,"C",20,0,"FAIXA3 E CRITICIDADE"		,.T.,.F.,.T.,"C",.T.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_TP+CRITIC_CHM"	,"C",20,0,"FAIXA3FSW E CRITICIDADE"		,.T.,.F.,.T.,"C",.T.,.T.,.F.,.F.})

AADD(ASTRU,{"TP_COMUNIC","C",6,0,"TIPO DE COMUNICACAO"		,.F.,.F.,.F.,"C",.T.,.T.,.F.,.F.,"ADE_TIPO",""})
AADD(ASTRU,{"DT_SLO"	,"C",6,0,"DATA DO SLO (HELP DESK)"	,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.,"ADE_DTEXPI",""})
AADD(ASTRU,{"HR_SLO"	,"C",6,0,"HORA DO SLO (HELP DESK)"	,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.,"ADE_HREXPI",""})
AADD(ASTRU,{"DT_SLOVENC","C",6,0,"SLO VENCIDO (HELP DESK)"	,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.,"ADE_DTEXPI",""})

AADD(ASTRU,{"AN_CODS"	,"C",6,0,"TI's ANALISTAS ATUARAM"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"AN_NOMES"	,"C",20,0,"NOMES ANALISTAS ATUARAM"	,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.})
AADD(ASTRU,{"AN_AREA"	,"C",10,0,"EQUIPE"					,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"AN_ASSUNT"	,"C",10,0,"ASSUNTO"					,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.,"ADE_ASSUNT",""})

AADD(ASTRU,{"CODCLI"	,"C",6,0,"COD.CLIENTE"				,.F.,.F.,.F.,"C",.T.,.T.,.F.,.F.,"ADE_CHAVE",""})
AADD(ASTRU,{"CODPRIV"	,"C",6,0,"CLIENTE PRIVATE"			,.F.,.F.,.F.,"C",.T.,.T.,.F.,.F.})
AADD(ASTRU,{"CLIENTE"	,"C",20,0,"NOME CLIENTE"			,.F.,.F.,.T.,"C",.T.,.T.,.F.,.F.})
AADD(ASTRU,{"CONTATCLI"	,"C",20,0,"CONTATO CLIENTE"			,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.})
AADD(ASTRU,{"VERSAO"	,"C",6,0,"VERSAO"					,.F.,.F.,.F.,"C",.F.,.F.,.T.,.F.,"ADE__VERSA",""})
AADD(ASTRU,{"MODULO"	,"C",10,0,"MODULO"					,.F.,.F.,.F.,"C",.T.,.F.,.T.,.F.,"ADE_CODSB1",""})
AADD(ASTRU,{"ROTINA"	,"C",20,0,"ROTINA"					,.F.,.F.,.F.,"C",.T.,.T.,.T.,.F.,"ADE__ZLCRO",""})
AADD(ASTRU,{"DESCROT"	,"C",20,0,"DESCRICAO ROTINA"		,.F.,.F.,.F.,"C",.T.,.T.,.F.,.F.,"ADE__ZLCRO",""})

AADD(ASTRU,{"FATURA"	,"C",1,0,"FATURA CHAMADO"			,.f.,.F.,.T.,"C",.F.,.T.,.T.,.F.,"ADE_FATURA",""})
AADD(ASTRU,{"TEMPOFAT"	,"C",2,0,"TEMPO FATURAMENTO"		,.f.,.F.,.F.,"C",.F.,.F.,.F.,.F.}) //000:00

AADD(ASTRU,{"CRITIC_CHM","C",40,0,"CRITIC ROTINA"			,.F.,.F.,.F.,"C",.T.,.F.,.T.,.F.,"ADE_SEVCOD",""})
AADD(ASTRU,{"DABERTURA"	,"C",8,0,"ABERTURA"					,.F.,.F.,.F.,"D",.F.,.F.,.T.,.F.,"ADE_DATA",""})
AADD(ASTRU,{"HDABERT"	,"C",8,0,"H.ABERTURA"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

/*
NOVOS CAMPOS PARA CONTROLE DE ANALISTAS
*/
AADD(ASTRU,{"ANA_VALID_FAIXA"	,"C",30,0,"ANALISTA VALIDO NA AREA"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"ANA_UNICO"			,"C",30,0,"ANALISTA UNICO POR CHAMADO",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"FAIXA1_DT"	,"C",8,0,"DATA (1o FAIXA)"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA1_HR"	,"C",8,0,"HORA  (1o FAIXA)"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//data e hora limite
AADD(ASTRU,{"FAIXA1_DTL"	,"C",8,0,"DATA LIMITE (1o FAIXA)",.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA1_HRL"	,"C",8,0,"HORA LIMITE (1o FAIXA)",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//
AADD(ASTRU,{"FAIXA1_TP"	,"C",13,0,"TEMPO  (1o FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA1_TPM","N",13,0,"MINUTOS  (1o FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA1_SIT","C",1,0,"SITUACAO  (1o FAIXA)"		,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA1_NM"	,"C",30,0,"ANALISTA  (1o FAIXA)"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"FAIXA2_DT"	,"C",8,0,"DATA (2o FAIXA)"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_HR"	,"C",8,0,"HORA  (2o FAIXA)"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//data e hora limite
AADD(ASTRU,{"FAIXA2_DTL"	,"C",8,0,"DATA LIMITE (2o FAIXA)",.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_HRL"	,"C",8,0,"HORA LIMITE (2o FAIXA)",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//
AADD(ASTRU,{"FAIXA2_TP"	,"C",13,0,"TEMPO  (2o FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_TPM","N",13,0,"MINUTOS  (2o FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_TPC","C",13,0,"TEMPO CLIENTE (2o FAIXA)",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_SIT","C",1,0,"SITUACAO  (2o FAIXA)"		,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA2_NM"	,"C",30,0,"ANALISTA  (2o FAIXA)"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"FAIXA3_DT"	,"C",8,0,"DATA (3o FAIXA)"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_HR"	,"C",8,0,"HORA  (3o FAIXA)"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//data e hora limite
AADD(ASTRU,{"FAIXA3_DTL"	,"C",8,0,"DATA LIMITE (3o FAIXA)",.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_HRL"	,"C",8,0,"HORA LIMITE (3o FAIXA)",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//
AADD(ASTRU,{"FAIXA3_TP"	,"C",13,0,"TEMPO  (3o FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_TPM","N",13,0,"MINUTOS  (3o FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_SIT","C",1,0,"SITUACAO  (3o FAIXA)"		,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_NM"	,"C",30,0,"ANALISTA  (3o FAIXA)"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_AB"	,"C",8,0,"ABERTURA  (3o FAIXA)"		,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA3_ABH","C",8,0,"ABERTURA HORA (3o FAIXA)"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"FAIXA4_DT"	,"C",8,0,"DATA (FSW FAIXA)"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_HR"	,"C",8,0,"HORA  (FSW FAIXA)"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//data e hora limite
AADD(ASTRU,{"FAIXA4_DTL"	,"C",8,0,"DATA LIMITE (FSW FAIXA)",.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_HRL"	,"C",8,0,"HORA LIMITE (FSW FAIXA)",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
//
AADD(ASTRU,{"FAIXA4_TP"	,"C",13,0,"TEMPO  (FSW FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_TPM","N",13,0,"MINUTOS  (FSW FAIXA)"		,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_SIT","C",1,0,"SITUACAO  (FSW FAIXA)"		,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_NM"	,"C",30,0,"ANALISTA  (FSW FAIXA)"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_AB"	,"C",8,0,"ABERTURA  (FSW FAIXA)"		,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"FAIXA4_ABH","C",8,0,"ABERTURA HORA (FSW FAIXA)"	,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"DT_ULT_ATD","C",8,0,"DATA (ULT ATEND)"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"HR_ULT_ATD","C",8,0,"HORA (ULT ATEND)"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"AN_ULTIMO"	,"C",20,0,"ANALISTA (ULT ATEND)"	,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.})
AADD(ASTRU,{"PRODUCAO"	,"N",2,0,"PRODUCAO"					,.F.,.F.,.F.,"N",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"PRODUTIVID","N",2,0,"PRODUTIVIDADE"			,.F.,.F.,.F.,"N",.F.,.F.,.F.,.F.})
/*novos campos*/
AADD(ASTRU,{"REABERTURAS","N",2,0,"REABERTURAS"				,.F.,.F.,.F.,"N",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"REJEICOES"	,"N",2,0,"REJEICOES"				,.F.,.F.,.F.,"N",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"DT_ULT_MOV","C",8,0,"ULT.MOV FINAL"			,.F.,.F.,.F.,"D",.F.,.F.,.T.,.F.})
AADD(ASTRU,{"H_ULT_MOV"	,"C",8,0,"H.ULT.MOV FINAL"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"ADE_CODREP","C",5,0,"CONT. REPRES."			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_CODREP",""})
AADD(ASTRU,{"ADE_NOMREP","C",5,0,"CONT. REPRES. NOME"		,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_CODREP",""})
AADD(ASTRU,{"ADE_EMAREP","C",5,0,"CONT. REPRES. EMAIL"		,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_CODREP",""})

AADD(ASTRU,{"DIAS_S_MOV","N",5,0,"DIAS S/ MOV"				,.F.,.F.,.F.,"N",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"DIASQABRIU","N",4,0,"DIAS_Q_ABRIU"				,.F.,.F.,.F.,"N",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"GRUPO"		,"C",40,0,"GRUPO ATEND."			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_GRUPO",""})

AADD(ASTRU,{"CODPAIS"	,"C",20,0,"PAIS"					,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE__PAIS",""})
AADD(ASTRU,{"CAUSA"		,"C",40,0,"CAUSA"					,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.,"ADE_CODCAU",""})
AADD(ASTRU,{"OCORRE"	,"C",20,0,"ULT OCORRENCIA"			,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.,"ADF_CODSU9",""})
AADD(ASTRU,{"ACAO"		,"C",20,0,"ULT ACAO"				,.F.,.F.,.F.,"C",.T.,.F.,.F.,.F.,"ADF_CODSUQ",""})
AADD(ASTRU,{"DT_ORIG_AB","C",10,0,"DT ORIG ABERT"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.,"ADE_DATA",""})

AADD(ASTRU,{"TXT_TRUE"	,"C",3,0,"TEXTO"					,.F.,.F.,.F.,"C",.F.,.F.,.T.,.F.})
AADD(ASTRU,{"PROBLEMA"	,"C",140,0,"INCIDENTE"				,.F.,.F.,.F.,"C",.F.,.F.,.T.,.F.})
AADD(ASTRU,{"SOLUCAO"	,"C",140,0,"ANALISE"				,.F.,.F.,.F.,"C",.F.,.F.,.T.,.F.})
AADD(ASTRU,{"RESUMO"	,"C",140,0,"RESUMO"					,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
AADD(ASTRU,{"DESCAB"	,"C",140,0,"DESCRIABERTURA"			,.F.,.F.,.T.,"C",.F.,.T.,.F.,.F.})

AADD(ASTRU,{"FNC"		,"C",20,0,"FNC NUM"					,.F.,.F.,.F.,"C",.F.,.F.,.T.,.F.,"ADE_FNC",""})
AADD(ASTRU,{"FNCASSOC"	,"C",20,0,"FNC ASSOCIADA"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_CHANEX",""})
AADD(ASTRU,{"FNCDTPREV"	,"C",8,0,"FNC PREVISAO"				,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.,"QI2_CONPRE",""})
AADD(ASTRU,{"FNCPRIOR"	,"C",2,0,"FNC PRIORIDADE"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"QI2_PRIORI",""})
AADD(ASTRU,{"FNCSTATUS"	,"C",2,0,"FNC STATUS"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"QI2_STATUS",""})

AADD(ASTRU,{"FNC_ETAPA"	,"C",2,0,"FNC ETAPA"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"QI5_TPACAO",""})//Daniel
AADD(ASTRU,{"MIN_FX1"	,"C",9,0,"MINUTOS FX1"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})//Daniel
AADD(ASTRU,{"MIN_FX2"	,"C",9,0,"MINUTOS FX2"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})//Daniel
AADD(ASTRU,{"MIN_FX3"	,"C",9,0,"MINUTOS FX3"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})//Daniel
AADD(ASTRU,{"MIN_FX4"	,"C",9,0,"MINUTOS FX4"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})//Daniel
AADD(ASTRU,{"TEMPO_COR"	,"C",9,0,"TEMPO CORRIDO"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})//Daniel
AADD(ASTRU,{"SITUAC_COR"	,"C",9,0,"SITUACAO CORRIDA"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})//Daniel

AADD(ASTRU,{"FNCCATEG"	,"C",2,0,"FNC CATEGORIA"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"QI2_CODCAT",""})
AADD(ASTRU,{"FNCREJE"	,"C",2,0,"FNC REJEITADA"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"QI2_STATUS",""})
AADD(ASTRU,{"FNCDIVERGE","C",2,0,"CHAMADO STATUS DIVERGENTE",.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})

AADD(ASTRU,{"DT_AG_INI"	,"C",10,0,"DATA AGENDA INI"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.,"ADE__DTINI",""})
AADD(ASTRU,{"DT_AG_FIM"	,"C",10,0,"DATA AGENDA FIM"			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.,"ADE__DTFIM",""})

AADD(ASTRU,{"FNCREVISAO","C",2,0,"FNC REVISAO"				,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"QI2_REV",""})

AADD(ASTRU,{"EMAIL"		,"C",255,0,"EMAIL"		 			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_EMAIL",""})

AADD(ASTRU,{"FILIAL"	,"C",2,0,"FILIAL"		 			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.,"ADE_FILIAL",""})
AADD(ASTRU,{"DATA_ATENDE","D",8,0,"DATA_ATENDE"	 			,.F.,.F.,.F.,"D",.F.,.F.,.F.,.F.,"ADF_DATA",""})

AADD(ASTRU,{"DEBUG"		,"C",2,0,"DEBUG NAO USAR"			,.F.,.F.,.F.,"C",.F.,.F.,.F.,.F.})
/*
tuchar campo para data da linha, e refazer os calculos baseados nele
*/

SX3->(dbsetorder(2))
ADE->( ;
AEVAL(dbstruct() , {  | aStruOk | ;
SX3->(dbseek(aStruOk[1])),;
if(!Empty(X3Titulo()),;
AADD(ASTRU,{aStruOk[1],aStruOk[2],aStruOk[3],aStruOk[4],upper(X3Titulo()),.F.,.F.,.F.,aStruOk[2],.F.,.F.,.F.,.F.,aStruOk[1],""}),;
AADD(ASTRU,{aStruOk[1],aStruOk[2],aStruOk[3],aStruOk[4],upper(aStruOk[1]),.F.,.F.,.F.,aStruOk[2],.F.,.F.,.F.,.F.,aStruOk[1],""}));
} ) ;
)
ADF->( ;
AEVAL(dbstruct() , {  | aStruOk | ;
SX3->(dbseek(aStruOk[1])),;
if(!Empty(X3Titulo()),;
AADD(ASTRU,{aStruOk[1],aStruOk[2],aStruOk[3],aStruOk[4],upper(X3Titulo()),.F.,.F.,.F.,aStruOk[2],.F.,.F.,.F.,.F.,aStruOk[1],""}),;
AADD(ASTRU,{aStruOk[1],aStruOk[2],aStruOk[3],aStruOk[4],upper(aStruOk[1]),.F.,.F.,.F.,aStruOk[2],.F.,.F.,.F.,.F.,aStruOk[1],""}));
} ) ;
)

For nCount := 1 To Len( aStru )
	aSize(aStru[nCount],15)
	If !Empty( lVetorExtr )
		aStru[nCount,6] := aStru[nCount,5] $ cHTMLExtr
		aStru[nCount,7] := aStru[nCount,5] $ cHTMLExtr
	Else
		If aStru[nCount,5] $ cCpoDef
			aStru[nCount,6] := .T.
		EndIf
		/*INCLUIR A OPวรO DE * NO CAMPO OBRIGATORIO*/
		//aStru[nCount,5] := "*" + aStru[nCount,5]
		If aStru[nCount,5] $ cCpGrupos
			aStru[nCount,7] := .T.
		EndIf
	EndIf
Next nCount

Return aStru

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function montabrow()
Local x
Local nPosAn := ascan(aStruTmp,{|x|x[1] == "DT_ULT_ATD"} ) // ULTIMO ATENDIMENTO
Local nPos := ascan(aStruTmp,{|x|x[1] == "MSTATUS"} ) // STATUS
//fElapTime()
If Empty(acols)
	addblank()
EndIf

If oBrow <> nil
	oBrow:hide()
	oBrow:end()
	oBrow := nil
EndIf

If Proc_Texto()
	oBrow := TwBrowse():New(10,5,(oDlgMain:nClientWidth/2)-15,(oDlgMain:nClientHeight/2)-160, , , , oDlgMain, , , , , , , , , , , , .F.,"ARRAY" ,.T.,,.F.,,)
Else
	oBrow := TwBrowse():New(10,5,(oDlgMain:nClientWidth/2)-15,(oDlgMain:nClientHeight/2)-55, , , , oDlgMain, , , , , , , , , , , , .F.,"ARRAY" ,.T.,,.F.,,)
EndIf

For x:= 1 to len(aStruTmp)
	if aStruTmp[x,6]
		If aStruTmp[x,1] == "DESCR_RISC"
			If Empty(nPos) .Or. Empty(nPosAn)
				oBrow:AddColumn(TCColumn():New( "", &(" {|| validacor(acols[oBrow:nat,"+str(x)+"]) }") ,,,,,,.T.,.F.,,,,.F.,))
			Else
				oBrow:AddColumn(TCColumn():New( "", &(" {|| validacor(acols[oBrow:nat,"+str(x)+"],.t.,acols[oBrow:nat,"+str(nPos)+"],acols[oBrow:nat,"+str(nPosAn)+"]) }") ,,,,,,.T.,.F.,,,,.F.,))
			EndIf
		elseif !( aStruTmp[x,1] $ "PROBLEMA/SOLUCAO/DESCAB/RESUMO/DEBUG" )			
			oBrow:AddColumn(TCColumn():New( aStruTMP[x,5], &(" {|| acols[oBrow:nat,"+str(x)+"] }") ,,,,,,.F.,.F.,,,,.F.,))
		EndIf
	EndIf
Next x

oBrow:SetArray(aCols)
oBrow:Refresh()
oBrow:bChange := {|| ;
cProblema := Retacols("PROBLEMA",oBrow:nAt),;
oProblema:Refresh(),;
cSolucao := Retacols("SOLUCAO",oBrow:nAt),;
oSolucao:Refresh()}

If Proc_Texto()
	oproblema:show()
	osolucao:show()
	
	oSproblema:show()
	oSsolucao:show()
EndIf

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบPrograma  ณMntTemp   บAutor  ณMichel Dantas       บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina que executa o processo de gera็ใo dos dados para o  บฑฑ
ฑฑบ          ณ DashBoard                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntTemp( lAtua , lCriticos , nFaixaCritic )
Local nChamados := 0
Local x
//fElapTime()
Private nQuant := 0
Private nPos
Private aColsTmp := {}
Private nTempo := seconds()
Private nTempo3 := seconds()
Private aRisco	:= {}
Private nMeses := 1
Private lTemLinha := .F.
Private nCount := 10000
Private aChamados := {}
Private  lAtua2 := lAtua
Private  lCriticos2 := lCriticos
Private  nFaixaCritic2 := nFaixaCritic
Private lCalculaSla := .T.
Private cFile := cTemp+"AtuaBase.csv"
Private cFile2 := cTemp+"mostradebug.csv"
Private lCONTA := .f.
Private aIntera:= {}
Private aTimeDif := {} // TEMPOS SLA
Private dDataAdf := CTOD("")
Private CTEXTFIL := ""
Private dUltDtATD := CTOD("")
Private cUltHrATD := ""
Private nContchm := 0
Private oChamado
Private cCliEmail := ""
Private cContatooLD := ""
Private cTextFil2 := ""
Private nOutraArea := 0
Private lSaida := .F.
Private nPassada := 0
Private DATADEOld := aFiltros[DATADE]
Private DATAATEOld := aFiltros[DATAATE]

lAtua := .T.
lCalculaSla := ClclaSla()

If cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" .and. !empty(Ajustabase)
	nHand := myfcreate(cFile,66)
EndIf

If cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" .and. !empty(Ajustabase)
	nHand2 := myfcreate(cFile2,66)
EndIf

aTotaisSla := { 0, 0, 0, 0, 0, 0, 0, 0 }

dbSelectArea("QI2")
dbSetOrder(2)
dbSelectArea("QI3")
dbSetOrder(1)
dbSelectArea("QI5")//Daniel
dbSetOrder(1)//Daniel
dbSelectArea("ADE")

nCount := 0

/*PROCURA OS CHAMADOS A SEREM ADICIONADOS NO VETOR*/

ProcChamados()

nLidos			:= 0
nErroPerneta	:= 0
nRecs			:= 0
nRecTot			:= nCount
nSecs			:= 0
nFalta			:= 0
nTempo2			:= nTempo
nNaoAnalista	:= 0
nOutraFilial	:= 0
nTempo			:= Seconds()
nRecAdf			:= 0

/*
divisao para multiplos processos
*/
MyJobs(aChamados,"u_MntTemp")

/*TOTAIS*/
cOrdem			:= ""
cOrdem2			:= ""
npos2			:= 0
If Empty(lCriticos)
	cOrdem := aFiltros[ORDEM] 
Else
	If nFaixaCritic <= 3 
		cOrdem := "DATA LIMITE ("+str(nFaixaCritic,1)+"o FAIXA)"
		cOrdem2 := "HORA LIMITE ("+str(nFaixaCritic,1)+"o FAIXA)"
	ElseIf nFaixaCritic == 4
		cOrdem := "DATA (ULT ATEND)"
		cOrdem2 := "HORA (ULT ATEND)"
	EndIf
EndIf

If !Empty(cOrdem) .And. Len( aCols ) > 0 //
//	MyText(cTextFil + "Ordenando Vetor principal " + aFiltros[ORDEM])
	aColsTmp := aClone(aCols)
	If ( nPos2 := aScan(aStruTmp,{|x|x[5] == cOrdem2 } ) ) == 0
		If (	nPos := aScan(aStruTmp,{|x|x[5] == cOrdem } )) > 0
			If ValType(aCols[1,npos]) =="D" //aFiltros[ORDEM] $ "ABERTURA"
				aColsTmp := aSort(aCols,,, { |x, y| CTOD(x[npos]) < CTOD(Y[npos]) })
			ElseIf ValType(aCols[1,npos]) =="N"// aFiltros[ORDEM] == "DESCR_RISC"
				aColsTmp := aSort(aCols,,, { |x, y| x[npos] > Y[npos] })
			ElseIf aStruTmp[nPos,9] == "D"
				aColsTmp := aSort(aCols,,, { |x, y| CTOD(x[npos]) < CTOD(Y[npos]) })
			Else
				aColsTmp := aSort(aCols,,, { |x, y| x[npos] < y[npos] })
			EndIf
		EndIf
	Else
		If (nPos := aScan(aStruTmp,{|x|x[5] == cOrdem } )) > 0
			If ValType(aCols[1,npos]) =="D" //aFiltros[ORDEM] $ "ABERTURA"
				aColsTmp := aSort(aCols,,, { |x, y| dtos(CTOD(x[npos]))+x[npos2] < dtos(CTOD(Y[npos]))+y[npos2] })
			ElseIf ValType(aCols[1,npos]) =="N"// aFiltros[ORDEM] == "DESCR_RISC"
				aColsTmp := aSort(aCols,,, { |x, y| x[npos] > Y[npos] })
			ElseIf aStruTmp[nPos,9] == "D"
				aColsTmp := aSort(aCols,,, { |x, y| dtos(CTOD(x[npos]))+x[npos2] < dtos(CTOD(Y[npos]))+y[npos2] })
			Else
				aColsTmp := aSort(aCols,,, { |x, y| x[npos] < y[npos] })
			EndIf	
		EndIf
	EndIf
EndIf

If Len(acols) == 0
	addblank()
EndIf
/*
MyText(cTextFil + "Lista de Chamadas - Ordem: " +aFiltros[ORDEM] + " -  Filtro: " +" - Grupo: contido " + aFiltros[EQUIPEATE]+;
				if( aFiltros[NSTATUS] == "Estatistica Geral", " - data de: " + dtoc(aFiltros[DATADE]) +" ate: "+dtoc(aFiltros[DATAATE]),"")  )
*/				
cMostra := ""
cMostra += "Chamados: " + StrZero(nquant,5) + "    |    "
If Left(dtos(aFiltros[DATADE] ),6) == Left(dtos(aFiltros[DATAATE]),6) .AND. aFiltros[NSTATUS] == "Estatistica Geral" .AND. ( aTotaisSla[2]+ aTotaisSla[4]+ aTotaisSla[6]+ aTotaisSla[8]) > 0
	cMostra += "Ind. da Faixa 1: "
	If aTotaisSla[2] > 0
		cMostra +=  STR (100 - ((aTotaisSla[1]/aTotaisSla[2] )*100),6,2) + "%"
	EndIf
	cMostra +=  "(" + AllTrim(STR(aTotaisSla[1],6)) + "/" + AllTrim(STR(aTotaisSla[2],6)) + ")"	 + "    |    "
	
	cMostra +=  "Ind. da Faixa 2: "
	If aTotaisSla[4] > 0
		cMostra +=  STR (100 - ((aTotaisSla[3]/aTotaisSla[4] )*100),6,2) + "% "
	EndIf
	cMostra +=  "(" + AllTrim(STR(aTotaisSla[3],6)) + "/" + AllTrim(STR(aTotaisSla[4],6)) + ")"	 + "    |    "
	
	cMostra +=  "Ind. da Faixa 3: "
	If aTotaisSla[6] > 0	
		cMostra +=  STR (100 - ((aTotaisSla[5]/aTotaisSla[6] )*100),6,2) + "% "
	EndIf
	cMostra +=  "(" + AllTrim(STR(aTotaisSla[5],6)) + "/" + AllTrim(STR(aTotaisSla[6],6)) + ")"	 + "    |    "
	
	cMostra +=  "Ind. da Faixa 3Fsw: "
	If aTotaisSla[8] > 0	
		cMostra +=  STR (100 - ((aTotaisSla[7]/aTotaisSla[8] )*100),6,2) + "% "
	EndIf
	cMostra +=  "(" + AllTrim(STR(aTotaisSla[7],6)) + "/" + AllTrim(STR(aTotaisSla[8],6)) + ")"	 + "    |    "	
	
	cMostra +=  "Indice Geral: "
	cMostra +=  STR (100 - (((aTotaisSla[1] + aTotaisSla[3]+ aTotaisSla[5]+ aTotaisSla[7]) / (aTotaisSla[2]+ aTotaisSla[4]+ aTotaisSla[6]+ aTotaisSla[8]))*100),6,2) + "% "
	cMostra +=  "(" + AllTrim(STR(aTotaisSla[1] + aTotaisSla[3]+ aTotaisSla[5]+ aTotaisSla[7],6)) + "/" + ALLTRIM(STR(aTotaisSla[2]+ aTotaisSla[4]+ aTotaisSla[6]+ aTotaisSla[8],6)) + " )"
EndIf	

If cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|"
	cMostra += " Tempo Corrido" + ": " + nToTime(seconds()-nTempo)
EndIf

If Type("oFaixas") == "O"
	oFaixas:SetText(cMostra)
EndIf

If cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" .and. !empty(Ajustabase)
	MyfClose(nHand)
EndIf
nAcerto := 0
// ESTAVA CRIANDO VARIOS ERROS POR CAUSA DO LOG DO AJUSTABASE
SomaRank()
// Teoricamente corrigido o erro de envio de email sem linhas de chamados, minha primeira linha sempre deve ter uma data, caso contrario ้ linha em branco.

If !Empty( Select("ADFNEW") )
	dbselectarea("ADFNEW")
	DbCloseArea()
EndIf

If !Empty( Select("ADENEW") )
	dbselectarea("ADENEW")
	DbCloseArea()
EndIf

If !Empty( Select("ADEQRY") )
	dbselectarea("ADEQRY")
	DbCloseArea()
EndIf

dbselectarea("ADE")

If lTemporario

	lAgrupaTotais	:= .F.
	ExportExcel(, ,.f.,,,.t.)
	nAgrupaItens	:= 0
	lAgrupaTotais	:= .t.
	ExcelSintetico( .T. )
//	ExportExcel(, ,.f.,,,.t.)
//	ExportExcel(, ,.T.,,,.t.)
//	ExportExcel(, , .t. )
EndIf

Return lTemLinha

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/15/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//user function testanew()
//cFile+strzero(z,2) ,{cEmpAnt,cFilAnt},aEnvia
//u_MntTemp("MICHEL001",{"00","01"}, {"01SCULCU"})
//return
//{aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx}
User Function MntTemp(cFile ,aEmpFil,aChamados2,Arr)
Local nHand
Local nChamados
Local lJob		:= Empty( Select("SM0") )
Local lSelOk	:= .F.
Local nTotChamados := 0

//fElapTime()

If lJob
	nHand := fCreate(cFile)
	Prepare environment Empresa aEmpFil[1] FILIAL aEmpFil[2]
	Private aChamados := aChamados2

	_lPhxF1R1    := GetMV("PS_PHXF1R1",,.F.)
	Private dDataAdf := CTOD("")
	Private dUltDtATD := CTOD("")
	Private aColsTmp := {}
	Private aRisco	:= {}
	Private aIntera:= {}
	Private aTimeDif := {} // TEMPOS SLA

	Private	aFiltro := if (_lPhxF1R1,;
		{{"Pendente Analista","Pend.Cli.-Aceite","Pend.Cli.-Retorno","FNC Pendentes","Pendencias na Qualidade","Chamados Associado","Estatistica Geral" },;
		{"ADE__ENTPE IN ('10','90')","ADE__ENTPE = '20'","ADE__ENTPE = '70'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""},;
		{"ADE__ENTPE IN ('10','90')","ADE__ENTPE = '20'","ADE__ENTPE = '70'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""}},;
		{{"Pendente Analista","Pendente Cliente","FNC Pendentes","Pendencias na Qualidade","Chamados Associado","Estatistica Geral" },;
		{"ADE__ENTPE IN ('10','90')","ADE__ENTPE = '20'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""},;
		{"ADE__ENTPE IN ('10','90')","","ADE__ENTPE = '20'","ADE__ENTPE = '30'","ADE__ENTPE = '40'","ADE__ENTPE = '60'",""}} )
	Private aCols := {}
	Private aFiltros := {}
	Private aStruTmp := {}
	Private aAreas := {}
	Private aMultQ := {} // { conteudo a agrupar, coluna, valor }
	Private aCores := { LoadBitmap( GetResources(), 'ENABLE'),;  // Cores padroes do semaforo
	LoadBitmap( GetResources(), 'BR_AMARELO' ) ,;
	LoadBitmap( GetResources(), 'DISABLE'    ) ,;
	LoadBitmap( GetResources(), 'BR_PRETO'   ) ,;
	LoadBitmap( GetResources(), 'BR_MARROM'   ) ,;
	LoadBitmap( GetResources(), 'X'   ),;
	LoadBitmap( GetResources(),"WFCHK"),;
	LoadBitmap( GetResources(),"WFUNCHK")  }
	Private T_Privates := {} // 0000000;000000
	Private aTotaisSla := { 0, 0, 0, 0, 0, 0, 0, 0 }
	Private aAreaAn := {}
	
	Private aCliFx1 := {}
	Private aCliFx2 := {}
	Private aCliFx3 := {}
	Private aCliFx4 := {}
	
	Private dDataOldAde := DATE()
	Private aCache := {}
	T_PRIVATES := {}

	QOUT("SIMC010 - Iniciando " + cFile + " " + time() )
	While ! File(cFile+".MEM") .and. ( file(cFile+".PAI") .and. ferase(cFile+".PAI") == -1 ) .AND. !KILLAPP() //.and. (nSleep < 100) // corrigir loop eterno
		sleep(1)
	//	nSleep++
	EndDo
	// DEU CACA
	If ! File(cFile+".MEM")
		qOut("SIMC010 - Deu erro:" + cFile + " " + TIME())
		fclose(nHand)
		ferase(cFile)
		Return
	EndIf

	RESTORE FROM (cFile+".MEM") ADDITIVE

	aAreaAn := {}
	Private aGrupos := {}
	
	Private __oRpo
	
	//acertar os alias, senao da erro no posicionamento das tabelas
	dbSelectArea("QI2")
	dbSetOrder(2)
	dbSelectArea("QI3")
	dbSetOrder(1)
	dbSelectArea("QI5")//Daniel
	dbSetOrder(1)//Daniel
	dbSelectArea("ADE")

	// Grupos de Atendimento (Equipes)
	SU0->(dbSetOrder(2))
	SU0->(dbSeek(myxfilial("SU0")))

	SU0->( ;
	dbEval( {|| aadd(aGrupos,{.F.,U0_CODIGO,U0_NOME} ) } , {|| U0_FILIAL == myxfilial("SU0") } ) )
	// RAMOS T14667
	// ZQE_FILIAL ZQE_CODCLI ZQE_LJCLI ZQE_CONTR ZQE_VERSAO ZQE_SERVIC ZQE_FAMILI ZQE_SLA ZQE_INADIM ZQE_CLICOL ZQE_LJCOL ZQE_ATENDE ZQE_EMPFIL ZQE_MIGRAC ZQE_CLICPF ZQE_TOTHR ZQE_VLRHR ZQE_DESCFA
	ZQE->(dbSetOrder(1)) // cabec USAR ESSE
	// ZQG_FILIAL ZQG_CODCLI ZQG_LOJA ZQG_NUMCTR ZQG_CODVER ZQG_SERVIC ZQG_EMPFIL ZQG_PRODUT ZQG_SITUAC ZQG_DATINI ZQG_DATFIM ZQG_TABSER ZQG_NIVSEV ZQG_DTINEQ ZQG_DTFIEQ
	ZQG->(dbSetOrder(2)) // itens
	
	MakeDir(cPathCubosAC)
	
	T_PRIVATES := {}
	CarregaArea(cFileConfig)
	CarregaArea(cFileAcesso)
	
	INTERMEDIARIO_ACESSO += "??????/??????" // "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|"
	
	//myprofile(.t.)
	
	LoadObj()
	
	//lAtua,lCriticos,nFaixaCritic
	
	//ARR := FT_RESTARR(cFile+"J.arr")
	//FERASE(cFile+"J.arr")

	aStruTmp	:= ARR[1]
	aTotaisSla	:= ARR[2]
	aFiltros	:= ARR[3]
	aFiltrosTmp	:= ARR[4]
	acols		:= ARR[5]
	acolsx		:= ARR[6]

	ChkFile( "ADE",.f. , "ADENEW")
EndIf

lAtua	  		:= lAtua2
lCriticos 		:= lCriticos2
nFaixaCritic	:= nFaixaCritic2

aTotaisSla := { 0, 0, 0, 0, 0, 0 ,0,0}
Private aTmpFunc := {SECONDS(),SECONDS(),SECONDS(),SECONDS(),SECONDS(),SECONDS(),0,0,0}	

nTotChamados := Len( aChamados )

For nChamados := 1 To nTotChamados 
	AddDebug({;
		"AbreFaixa..:",;
		"Item.......:",;
		"Data.......:",;
		"Hora.......:",;
		"Acao.......:",;
		"Equipe.....:",;
		"TempoFX1...:",;
		"TempoFX2...:",;
		"TempoCliente:",;
		"TempoAteLimite:",;
		"AteoLimite:",;
		"TempoFX3:"},.T.)
		
	cAnValid	:= ""	// ULTIMO ANALISTA VALIDO NA LINHA
	aAnUnq		:= {}	// ANALISTA UNICO POR CHAMADO
	lmfabrica	:= .f.
	lLinFabrica	:= .F.
	lConta2		:= .f.
	
	If lJob
		qout("SIMC010 - Processando chamado " + aChamados[nChamados] + " " + alltochar(nChamados) + "/" + alltochar(nTotChamados) )
	EndIf
	mytext("SIMC010 - Processando chamado " + aChamados[nChamados] + " " + alltochar(nChamados) + "/" + alltochar(nTotChamados) )
	
	ADENEW->( dbSeek(aChamados[nChamados] )  )

	If !ADF->(dbSeek(aChamados[nChamados])) // verifica integridade da base e ignora registros invalido
		mydebug("Erro na base sem linha para o chamado " + ADENEW->ADE_CODIGO)
		nErroPerneta++
		loop
	EndIf

	// --------------------------------------------------------------------------------
	// Avalia selecao de Equipe / Analista,	se teve ao menos uma interacao.
	// --------------------------------------------------------------------------------
	lSelOk := .F.
	If ExecPoint("000001") .and. !Empty( ALLTRIM( aFiltros[TECNICO] ) )
		Do While !ADF->( Eof() ) .and. ( ADF->(xFilial("ADF") + ADF_CODIGO) == aChamados[ nChamados ] )
			If	( AllTrim( ADF->ADF_CODSU7 ) <> "AUTO" ) .and.;
				If( Empty( cFiltraGrupos ), ( ADF->ADF_CODSU7 $ aFiltros[TECNICO] ), RetAnArea( AllTrim( ADF->ADF_CODSU7 ), ADF->ADF_DATA ) $ cFiltraGrupos )
				lSelOk := .T.
			EndIf
			ADF->( DBSkip() )
		EndDo
		If lSelOk
			// Continua o processamento
			ADF->( DBSEEK( aChamados[ nChamados ] ) )
		Else
			// Retorna e processa o proximo chamado
			Loop
		EndIf
	EndIf
	// --------------------------------------------------------------------------------

	If substr(aChamados[nChamados],1,2) <> cfilant
		nOutraFilial++
		mydebug("Chamado de outra filial:" + aChamados[nChamados])
	EndIf
	aTmpFunc[2] := seconds()

	//ADENEW->( cTextFil2 := ;
	//" Processo: 2/2 - Calculando e Analisando os dados selecionados:" + CRLF +;
	//" Pelo Cache / Em cache: " 	+ ALLTRIM(transform(nAcerto,"@E 999,999,999"))+ "/" + ALLTRIM(transform(nCache,"@E 999,999,999"))+ CRLF +;
	//" Registros Lidos / Restam: "	+ ALLTRIM(transform(nLidos,"@E 999,999,999,999"))+ "/" + ALLTRIM(transform(nCount--,"@E 999,999,999,999" )) + CRLF +;
	//" Utilizados: "				+ ALLTRIM(transform(nquant,"@E 999,999,999,999")) +  CRLF +;
	//" Sem Integridade: "			+ ALLTRIM(alltochar(nErroPerneta)) + CRLF +;
	//" Transf.Outra Area: "		+ ALLTRIM(alltochar(nOutraArea)) + CRLF +;
	//" Sem atuacao SLA: "			+ ALLTRIM(alltochar(nNaoAnalista)) + CRLF +;
	//" Processando Data: "			+ alltochar(ADE_DATA)  + CRLF +;
	//" Tempo / Estimado: "			+ nToTime(seconds()-nTempo) + " / " + nToTime( nCount * ((seconds()-nTempo)/nLidos) ) + CRLF +;
	//" Tempo total/filtro/adiciona linha :" + nToTime(aTmpFunc[7] += aTmpFunc[2]-aTmpFunc[1]) +" / " + nToTime(aTmpFunc[8] += aTmpFunc[4]-aTmpFunc[3]);
	//+ " / " + nToTime(aTmpFunc[9] += aTmpFunc[6]-aTmpFunc[5]) + CRLF +;
	//" Outra Filial: "				+ transform(nOutraFilial,"@E 999,999,999") )

	aTmpFunc[1] := Seconds()
	
	//	Mytext(cTextFil + CRLF + cTextFil2)
	
	++nLidos

	aIntera			:= { }
	dUltMov			:= Nil
	cOpera			:= ""
	cAreaAnalista	:= ""
	cRetOperaSla	:= ""
	nTotProdutivo	:=0
	nTotProducao	:=0
	
	nReaberturas	:= 0
	nRejeicoes		:= 0

	aTimeDif			:= Array( 4, 19 )
	lFoundtxt			:= .F.
	lFoundtxt2			:= .F.
	lProducao_DT_FIL	:= .F.
	dUltDtMov			:= ddatabase
	cUltHrMov			:= ""
	lCancelado			:= .F.
	lSomaAdf			:= .F.
	cTotFat				:= "00:00"
	aColsx				:= { }

	//Serve para identificar chamados que estao na area de N3 e que foram atendidos 
	//em algum momento pela equipe que esta sendo filtrada o processamento.
	lTemAreaCHM			:= .T.

	// Inicio da leitura dos itens
	lPrimeiro			:= .T.
	cAnalistaAloc		:= ALLTRIM(ADENEW->ADE_OPERAD)
	ddataanalista		:= ADENEW->ADE_DATA
	cMemo				:= ""
	cMemoSol			:= ""
	
	If Proc_Texto()
		cMemo += " ****** EM " + DTOC(ADF->ADF_DATA) + " " + ADF->ADF_HORA + " ****** " + Upper(AllTrim(msmm(ADENEW->ADE_CODINC))) + CRLF
		cMemo += Replicate("-",95) + CRLF
	EndIf

	nConta				:= 1
	lAnalista			:= !lCalculaSla

	If !lCalculaSla
		aTimeDif[1,1] := ADF->ADF_DATA
		aTimeDif[1,2] := ADF->ADF_HORA
		aTimeDif[1,3] := Date()
		aTimeDif[1,4] := Time()
		aTimeDif[1,5] := ""
	EndIf

	aMemoSol			:= {}
	nTotFat				:= 0
	lContou				:= .F.
	lAssociado			:= .f.
	lEstaArea			:= .f.
	lFxCli				:= .f.

	// Novo Objeto de chamado
	oChamado			:= DashChamado():New()
	
	/*VALIDAวรO DAS LINHAS A SEREM PROCESSADAS NO FONTE*/
	// LINHA A LINHA
	aTmpFunc[3]			:= seconds()
	
	// primeiro filtro do chamado
	ProcLinhas( )
	
	aTmpFunc[4]			:= Seconds()
	
	// FIM DA LEITURA DOS ITENS
	// IGNORA CHAMADO CANCELADO  ou nao Utilizado no monitor de chamados para enviar poe email.
	// Ignora chamados sem analista e que estejam encerrados
	If aFiltros[NSTATUS] <> "Pesquisar Ocorrencia" .and.;
		( lCancelado .or. !lContou .or. ( !lAnalista .and. ADENEW->ADE_STATUS == '3' ) )
		nNaoAnalista++
		MyDebug("Sem analista ou cancelado chamado " + ADENEW->ADE_CODIGO )
		loop
	EndIf

	If  lAssociado
		MyDebug("Chamado associado por outra area " + ADENEW->ADE_CODIGO )
	EndIf
	// *********************  filtro dos registro  ********************************
	ADF->(dbgoto(nRecAdf))

	// valida se envia ou nao o email para as faixas em aberto
	// VERIFICA SE O CHAMADO VAI SER MOSTRADO NA LISTA DE CHAMADOS 

	//carrega para o objeto de chamado os valores de tempo
	oChamado:CalcTime( aTimeDif )
	// validar as faixa lfaixa1, lfaixa2, lfaixa3
	
	If aFiltros[NSTATUS] == "Estatistica Geral"
		lEntra:=.F.
		// ้ uma transferencia para uma area que deve ser contato como sla ๚nico
		// o chamado nao foi alocado ainda para a outra area
            // apenas quando ้ chamado 2 areas, caso seja apenas 1 nao deve ser considerado o cabe็alho
            // nao sei como resolver ainda
		// esta dando erro quando tem fnc ou qualquer outra manipulacao caso o chamado sofra

		If  ADENEW->ADE_DATA < aFiltros[DATADE]
			If lProducao_DT_FIL
				MyDebug("a data ้ anterior mas tem producao: " + ADENEW->ADE_CODIGO)
				// Se no foi aberto no periodo selecionado, mas teve producao no periodo selecionado vai entrar.
				lEntra:=.T.
			Endif
		EndIf


		// Se cabe็alho ou qualquer linha da equipe ou qualquer data limite esteja no periodo selecionado, mostra o chamado.		
		// FILTRA A DATA NO FINAL
		If FilDtMes()
			MyDebug("Esta na data filtrada: " + ADENEW->ADE_CODIGO)
			lEntra:=.T.
		Endif

		If !lTemAreaCHM   // Se o chamado teve opera็ใo da area filtrada e ele esta no n3 ele ira entrar 
			lEntra:=.F.
		Endif
		
		//Verifica produtivo e produ็ใo apenas em chamados SLA SP, caso contrario sempre trago os chamados
		
		If (ADENEW->ADE_ASSUNT $ cAssuntArea .and. !Empty(cAssuntArea) ) .and. nTotProducao + nTotProdutivo == 0  //o chamado nao teve producao dentro do filtro estabelecido na est. geral.
			MyDebug("Nใo conta, sem produ็ใo ou produtividade chamado: " + ADENEW->ADE_CODIGO )			
			lEntra:=.F.
		end
		// quando validar se o chamado ้ ou nao da faixa de clientes sla
		If  !lEntra
			loop
		end

	Endif
	
	IF !Empty(lCriticos) .and. Validcritic(aTimeDif, ADENEW->ADE_CODIGO, nFaixaCritic ) // !empty(aTimeDif[1,6])
		loop
	end
	if aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .AND. (!Empty(cTexto1) .OR. !Empty(cTexto2))
		lFoundtxt := cTexto1 $ UPPER(cMemo + cMemoSol)
		lFoundtxt2 := cTexto2 $ UPPER(cMemo + cMemoSol)

		if ! ( (lFoundtxt .or. empty(cTexto1) ).and. ( lFoundtxt2 .or. empty(cTexto2) ))
			loop
		end
	end

	lTemLinha := .T.
	
	/*ADICIONA AS LINHAS DO CHAMADO*/
	aTmpFunc[5] := seconds()	
// ADICIONA EFETIVAMENTE

	addlinha(nChamados)
	if lJob
		multarray({,aTotaisSla,,,acols,acolsx,aTimeDif},cFile,cFile)
		//michel
//		FT_SAVEARR({aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx,aTimeDif},cFile+".ARR")
	//	QOUT("GRAVEI " + cFile+".ARR" )
	//	nSleep := 0
//		While File(cFile+".ARR") .and. ( ferase(cFile+".PAI") == -1 ) .AND. !KILLAPP()// .and. ( nSleep < 100 ) // corrigir loop eterno
//			sleep(1)
	//		nSleep++
//		end
	//	QOUT("LIBEROU " + cFile+".ARR" )	
		// foi para o saco o remote
		if !File(cFile+".PAI")
			qout("SIMC010 - Thread Morta " + cFile + " " + TIME())
			fclose(nHand)
			ferase(cFile)
			exit
		end
		acols := {}
		acolsx := {}
		aTotaisSla := { 0, 0, 0, 0, 0, 0, 0, 0 }
	end

	aTmpFunc[6] := seconds()
	
next
ADENEW->( cTextFil2 := ;
" Processo: 2/2 - Calculando e Analisando os dados selecionados:" + CRLF +;
" Pelo Cache / Em cache: " 		+ AllTrim(Transform(nAcerto,"@E 999,999,999"))+ "/" + AllTrim(Transform(nCache,"@E 999,999,999"))+ CRLF +;
" Registros Lidos / Restam: "	+ AllTrim(Transform(nLidos,"@E 999,999,999,999"))+ "/" + AllTrim(Transform(nCount--,"@E 999,999,999,999" )) + CRLF +;
" Utilizados: "					+ AllTrim(Transform(nquant,"@E 999,999,999,999")) +  CRLF +;
" Sem Integridade: "			+ AllTrim(alltochar(nErroPerneta)) + CRLF +;
" Transf.Outra Area: "			+ AllTrim(alltochar(nOutraArea)) + CRLF +;
" Sem atuacao SLA: "			+ AllTrim(alltochar(nNaoAnalista)) + CRLF +;
" Processando Data: "			+ alltochar(ADE_DATA)  + CRLF +;
" Tempo / Estimado: "			+ nToTime(Seconds()-nTempo) + " / " + nToTime(nFalta) )
MyDebug( cTextFil2 )
If lJob
	qOut("SIMC010 - Fim Normal " + cFile + " " + Time() )
	fClose( nHand )
	fErase( cFile )
EndIf
Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function addblank()
Local x
//fElapTime()

aAdd(aCols,{})

aEval( aStruTmp, {  | aStruTmp |;
If(aStruTmp[2] == "C",aAdd(acols[Len(acols)],space(aStruTmp[3])),""),;
If(aStruTmp[2] == "N",aAdd(acols[Len(acols)],0),""),;
If(aStruTmp[2] == "L",aAdd(acols[Len(acols)],".T."),""),;
If(aStruTmp[2] == "M",aAdd(acols[Len(acols)],""),""),;
If(aStruTmp[2] == "D",aAdd(acols[Len(acols)],stod("")),"")} )

//aadd(acols,array(len(aStruTmp)))
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function addvalor(cCampo,uValor)
Local nPos
//fElapTime()
If ( nPos := aScan(aStruTmp,{|x|x[1] == cCampo} ) ) > 0  .and. nPos <= len( acols[len(acols)] )
	If ValType(uValor) == "D"
		uValor := alltochar(uValor)
	EndIf
	acols[len(acols),nPos] := uValor
Else
	If lMostraDebug .and. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" .and. ! ( cCampo $ cCPoMostra )
		MsgStop("Erro ao adicionar o campo " + alltochar(cCampo) + " - Valor : " + alltochar(uValor) )
		cCPoMostra += cCampo
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/13/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetACols(cCampo,nLinha,uDef)
Local nPos	:= NIL

//fElapTime()
If ( nPos := Ascan(aStruTmp,{|x|x[1] == cCampo} )) >0
	If Empty(nLinha)
		nLinha := Len(aCols)
	EndIf
	uDef  := aCols[nlinha,nPos]
Else
	If lMostraDebug .and. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" .and. ! ( cCampo $ cCpomostra )
		MsgStop("Erro ao retornar o campo " + AllToChar(cCampo) )
		cCpoMostra += cCampo
	EndIf
EndIf

Return uDef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
CRIA E GERA ARQUIVOS WORKFLOW EXCEL ENVIO
				ExportExcel(      ,       ,.f.   ,    ,      ,.t.)
				ExportExcel(      ,       ,.T.   ,    ,      ,.t.)
*/
Static Function ExportExcel(lHtml,cDescri,lTotais,uOld,nFaixa,lNaoCria)
Local cFile
Local aStru2		:= {}
Local x,y,z
Local nMeses		:= 1
Local nLenCols		:= 0
Local nCount //
Local nPosSit2Fx	:= 0
Local nPosSit3Fx	:= 0

Local cFx1Campos :=  "SITUACAO  (1o FAIXA)/DESCRIABERTURA/CHAMADO/CRITIC ROTINA/ROTINA/ANALISTA ALOCADO/ABERTURA/H.ABERTURA/TEMPO  (1o FAIXA)";
			+ "DATA LIMITE (1o FAIXA)/HORA LIMITE (1o FAIXA)/NOME CLIENTE/"
Local cFx2Campos :=  "SITUACAO  (2o FAIXA)/DESCRIABERTURA/CHAMADO/CRITIC ROTINA/ROTINA/ANALISTA ALOCADO/ABERTURA/H.ABERTURA/TEMPO  (2o FAIXA)";
			+ "/TEMPO CLIENTE (2o FAIXA)/DATA LIMITE (2o FAIXA)/HORA LIMITE (2o FAIXA)/NOME CLIENTE"
Local cFx3Campos :=  "SITUACAO  (3o FAIXA)/CHAMADO/CRITIC ROTINA/FNC NUM/FNC REVISAO/ABERTURA  (3o FAIXA)/ABERTURA HORA (3o FAIXA)/";
			+ "DATA LIMITE (3o FAIXA)/HORA LIMITE (3o FAIXA)/TEMPO  (3o FAIXA)/NOME CLIENTE/MODULO/ROTINA/GRUPO ATEND./ANALISTA ALOCADO/DESCRIABERTURA/FNC ETAPA"//Daniel
Local cFx4Campos :=  "DESCRIABERTURA/EQUIPE/CHAMADO/ROTINA/ANALISTA ALOCADO";
			+ "/DATA (ULT ATEND)/HORA (ULT ATEND)/NOME CLIENTE/"

Default nFaixa := 0
//fElapTime()
If Empty(lTotais)
	for x := 1 to len(aStruTmp)
		if if( empty(lHtml),aStruTmp[x,6],.T. )
			if aStruTmp[x,1] == "DESCR_RISC"
				aadd(astru2,aclone(aStruTmp[x]))
				astru2[len(astru2),2] := "C"
				astru2[len(astru2),3] := 15
			else
				aadd(astru2,aclone(aStruTmp[x]))
			EndIf
		EndIf
	Next X
Else
	aadd(astru2,{"MUDA","C",1,0,"",.T.}  )
	aadd(astru2,{"CAMPO","C",70,0,"",.T.}  )
	aadd(astru2,{"CONTEUDO","C",205,0,"",.T.}  )
	if !lAgrupaTotais
		nMeses := contames( dDataOldAde, aFiltros[DATAATE] )
		for x := 1 to nMeses
			cCampoCria := substr(dtos( ( dDataOldAde ) + 31*(x-1) ) , 1 , 6 )

			aadd(astru2,{"D" +  substr(cCampoCria,5,2) + "_" + substr(cCampoCria,1,4)  ,"N",5,0,"",.T.}  )
		next
	else
		nMeses := contames( aFiltros[DATADE] , aFiltros[DATAATE] )
		aadd(astru2,{"ANTERIOR"  ,"N",5,0,"",.T.}  )
		for x := 1 to nMeses
			cCampoCria := substr(dtos( ( aFiltros[DATADE]) + 31*(x-1) ) , 1 , 6 )
			aadd(astru2,{"D" +  substr(cCampoCria,5,2) + "_" + substr(cCampoCria,1,4)  ,"N",5,0,"",.T.}  )
		next
	end
	aadd(astru2,{"TOTAL","N",7,0,"",.T.}  )
	private acols := aclone(aMultQ)
	PRIVATE aStruTmp := astru2
	AgrupaItens()
EndIf

If Empty(lhtml)
	cFile := cTemp + __cUserId

	If Empty(lTotais)
		cFile += "Analitico.csv"
	Else
		cFile += "Sintetico.csv"
	EndIf

	nHand := myfCreate( cFile )
	if nHand > 0
		cMuda := ""
		nValor := "0"
	/*	
		MyText("Iniciando a gera็ใo do temporario " )
	*/	
		cLinha := ""
		IF empty(lTotais)
			for x := 1 to len(aStruTmp)
				if aStruTmp[x,6]
					cLinha += alltochar(aStruTmp[x,5]) + ";"
				end
			next
		ELSE
			for x := 1 to len(aStruTmp)
				cLinha += alltochar(aStruTmp[x,1]) + ";"
			next
		END
		cLinha += CRLF
		myfwrite(nHand,cLinha,,@cTotalBuff)
		for x := 1 to len(acols)
			cLinha := ""	
			nLenCols := len(acols[1]) -2
			/*
			MyText("Iniciando a gera็ใo do temporario Registro " + alltochar(x) )
			*/
			z := 1
			if empty(lTotais)
				Z := 1
			else
				Z := 2
			end
	
			if !empty(lTotais)
				if cMuda <> acols[x,1]
					if nValor == "0"
						nValor := "1"
					else
						nValor := "0"
					end
					cMuda := acols[x,1]
				end
				cLinha += nValor + ";"
			end
			
			IF empty(lTotais) //!lAgrupaTotais
				for y := 1 to len(acols[x])
					if aStruTmp[y,6]
						if aStruTmp[y,1] == "DESCR_RISC"
							cLinha += "RISCO " + if(acols[x,y] <= 1,"BAIXO",if(acols[x,y] <= 2,"MODERADO","ALTO")) + ";"
						elseif VALtype(acols[x,y]) == "C"
							cLin2 := STRTRAN( strtran( STRTRAN(  acols[x,y],CHR(13),""),chr(10), " "),";","")
							cLinha += cLin2 + ";"
						else
							if !lAgrupaTotais .or. z <= 2
								if VALtype(acols[x,y]) == "C"
									cLin2 := STRTRAN( strtran( STRTRAN( acols[x,y],CHR(13),""),chr(10)," " ),";","")  
									cLinha += cLin2 + ";"
								else
									cLinha += alltrim( alltochar(acols[x,y]) ) + ";"
								end
							end
						end
						z++
					end
				next
			ELSE
			/*Erro de type mismatch no excel*/
				cLinha += alltrim(alltochar( acols[x,1] ) ) + ";"
				cLinha += alltrim(alltochar( acols[x,2] ) ) + ";"
			END
			IF lAgrupaTotais
				nPosField := len(aStruTmp)
				aTemp := array(nPosField)
				afill(aTemp,0)
				for nCount := len(aCols[X]) to 3 step -1
					if   aStruTmp[nPosField,2] == "C"
						nPosField := 4
					end
					aTemp[nPosField] := acols[x,nCount]+aTemp[nPosField]
					nPosField--
				next
				for nCount := 4 to len(aTemp)
					cLinha += alltrim(alltochar(aTemp[nCount])) + ";"
				next
			end
			
			cLinha += CRLF
			myfwrite(nHand,cLinha,,@cTotalBuff)
		next
		myfclose(nHand)
	end
	If Empty(lNaoCria)
		OpenExcel( cFile , ,,.T.)
	EndIf
else
	cFile := cTemp + "email.HTML"
	nHand := myfcreate(cFile,66)
	myfwrite(nHand,"<html>" + CRLF,,@cTotalBuff)
	myfwrite(nHand,"<head>" + CRLF,,@cTotalBuff)
	myfwrite(nHand,"<title>"+ALLTRIM(cDescri)+"</title>" + CRLF,,@cTotalBuff)
	myfwrite(nHand,"</head>" + CRLF,,@cTotalBuff)

	myfwrite(nHand,"<p class=MsoNormal><b><span style='font-size:18.0pt;font-family:"+ CRLF,,@cTotalBuff)
	myfwrite(nHand,'"Arial","sans-serif"'+ CRLF,,@cTotalBuff)
	myfwrite(nHand,"'>"+ALLTRIM(cDescri)+"</span></b></p>" + CRLF,,@cTotalBuff)

	myfwrite(nHand,'<table border="1" style="font-size: xx-small" >' + CRLF,,@cTotalBuff)
	myfwrite(nHand," <tr>" + CRLF,,@cTotalBuff)
	z := 1
    
	nTotCampos := 0
	for y := 1 to len(astru2)
		if ;
		( nFaixa == 1 .and. aStruTmp[y,5] $ cFx1Campos ) .or.;
		( nFaixa == 2 .and. aStruTmp[y,5] $ cFx2Campos ) .or.;
		( nFaixa == 3 .and. aStruTmp[y,5] $ cFx3Campos ) .or.;
		( nFaixa == 4 .and. aStruTmp[y,5] $ cFx4Campos ) .or.;
		( nFaixa == 0 .and. aStruTmp[y,5] $ (cFx1Campos+cFx2Campos+cFx3Campos+cFx4Campos) )
			nTotCampos++
		End
	next
	
	
	nContCampo := 1
	aTamCampos := {{ 5,10,5,5,5,5,5,5,5,5,5  ,40},;
					{5,5 ,5,5,5,5,5,5,5,5,5,5,40},;
					{},;
					{}}

	for y := 1 to len(astru2)
		if ;
		( nFaixa == 1 .and. aStruTmp[y,5] $ cFx1Campos ) .or.;
		( nFaixa == 2 .and. aStruTmp[y,5] $ cFx2Campos ) .or.;
		( nFaixa == 3 .and. aStruTmp[y,5] $ cFx3Campos ) .or.;
		( nFaixa == 4 .and. aStruTmp[y,5] $ cFx4Campos ) .or.;
		( nFaixa == 0 .and. aStruTmp[y,5] $ (cFx1Campos+cFx2Campos+cFx3Campos+cFx4Campos) )
			if  !Empty(nFaixa) .and. (nContCampo <= len(aTamCampos[nFaixa]))
				myfwrite(nHand,'<td  bgcolor="#788ea7" width="'+alltochar(aTamCampos[nFaixa,nContCampo] ) +'%">',,@cTotalBuff)
			else
				myfwrite(nHand,'<td  bgcolor="#788ea7" width="'+alltochar(100 / nTotCampos) +'%">',,@cTotalBuff)
			end
			myfwrite(nHand,'<p>',,@cTotalBuff)
			myfwrite(nHand,(alltochar(astru2[y,5] ) ),,@cTotalBuff)
			myfwrite(nHand,"</p>",,@cTotalBuff)
			myfwrite(nHand,"</td>" + CRLF,,@cTotalBuff)
			
			nContCampo++
		End
	next
	myfwrite(nHand," </tr>" + CRLF,,@cTotalBuff)
	
	nPosSit2Fx := AScan(aStruTMP, {|e| e[5] == 'SITUACAO  (2o FAIXA)' })
	nPosSit3Fx := AScan(aStruTMP, {|e| e[5] == 'SITUACAO  (3o FAIXA)' })

	for x := 1 to len(acols)
		
		If		( nFaixa == 2 )		.and.;
				( nPosSit2Fx > 0 )	.and.;
				( aCols[ x ][ nPosSit2Fx ] == NOT_EXIST_SLA )
			//Loop
		ElseIf	( nFaixa == 3 )		.and.;
				( nPosSit3Fx > 0 )	.and.;
				( aCols[ x ][ nPosSit3Fx ] == NOT_EXIST_SLA )
			//Loop
		EndIf
		
		// MyText("Iniciando a gera็ใo do temporario Registro " + alltochar(x) )
		myfwrite(nHand," <tr>" + CRLF,,@cTotalBuff)
		z := 1
		for y := 1 to len(aStruTmp)
			if ;
			( nFaixa == 1 .and. aStruTmp[y,5] $ cFx1Campos ) .or.;
			( nFaixa == 2 .and. aStruTmp[y,5] $ cFx2Campos ) .or.;
			( nFaixa == 3 .and. aStruTmp[y,5] $ cFx3Campos ) .or.;
			( nFaixa == 4 .and. aStruTmp[y,5] $ cFx4Campos ) .or.;
			( nFaixa == 0 .and. aStruTmp[y,5] $ (cFx1Campos+cFx2Campos+cFx3Campos+cFx4Campos) )
					myfwrite(nHand,"<td",,@cTotalBuff)
					if !Empty(alltochar(acols[x,y] ) )
						if aStruTmp[y,1] == "DESCR_RISC"
							myfwrite(nHand," bgcolor=" + if(acols[x,y] <= 1,'"Green"',if(acols[x,y] <= 2,'"Yellow"','"Red"')),,@cTotalBuff)
							myfwrite(nHand,"> RISCO " + if(acols[x,y] <= 1,"BAIXO",if(acols[x,y] <= 2,"MODERADO","ALTO")),,@cTotalBuff)
						else
							myfwrite(nHand,">",,@cTotalBuff)
							myfwrite(nHand,(alltochar(acols[x,y] ) ),,@cTotalBuff)
						end
					else
						myfwrite(nHand,'>.',,@cTotalBuff)
					end
					myfwrite(nHand,"</td>" + CRLF,,@cTotalBuff)
					z++
			end
		next
		myfwrite(nHand," </tr>" + CRLF,,@cTotalBuff)
	next
	
	myfwrite(nHand,"</table>" + CRLF,,@cTotalBuff)
	myfwrite(nHand,"</html>" + CRLF,,@cTotalBuff)
	myfclose(nHand)
end
return cFile

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  mudaordem  บAutor  ณMicrosiga           บ Data ณ  10/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem da tela de paramentos para gerar o Dashboard      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MudaOrdem(oDlg,lNew)
Local lConfirma		:= .F.
Local aOrdem		:= NIL
Local oOrdem		:= NIL
Local cOrdem		:= NIL
Local oFiltro		:= NIL
Local oFilFaixa	:= NIL
Local oFiltClFx	:= NIL
Local cEquipede		:= NIL
Local cEquipeate	:= NIL
Local cCliente		:= NIL
Local cAnalista		:= NIL
Local oQuebra		:= NIL
Local lQuebra		:= NIL
Local dDataInicio	:= NIL
Local dDataFim		:= NIL
Local oAgrupa		:= NIL
Local lAgrupa		:= NIL
Local x				:= NIL
Local cLoja			:= NIL
Local nLinha		:= 1
Local aAreaSel		:= {}
Local cFiltro		:= space(255)
lOCAL cArea			:= ""
Local _lPhxF1R1		:= GetMV("PS_PHXF1R1",,.F.)
Local nHand			:= NIL
Local i				:= 0
Local j				:= 0
Local cMaxBuff		:= ""
Local cElapFile		:= "c:\filtro_ssim\ElapTime.csv"
Local cLinha		:= ""
Local lAbriuTela := .F.

private aFiltrosTmp := aclone(aFiltros)
Private nPesq := 1

// LIMPA AS VARIAVEIS

cFiltraGrupos := ""
aFiltrosTmp[TECNICO] := SPACE(255)

ctexto1 := PAD(ctexto1,255)
ctexto2 := PAD(ctexto2,255)

aFiltrosTmp[EQUIPEATE] := pad(aFiltrosTmp[EQUIPEATE],10000)
aFiltrosTmp[CLIENTE] := pad(aFiltrosTmp[CLIENTE],10000)

cGrupo := space(2)
cCliente := space(10)
cAnalista := space(10)
cloja := space(2)
aOrdem := {{},{}}
for x := 1 to len(aStruTmp)
	aadd(aOrdem[1],aStruTmp[x,5])
	aadd(aOrdem[2],"-"+aStruTmp[x,1])
next
aadd(aAreaSel,"Todos")
for x := 1 to len(aAreas)
	aadd(aAreaSel,aAreas[x,1])
next

cFiltroOld := aFiltrosTmp[EQUIPEATE]
if empty(lNew)
	DEFINE MSDIALOG oDlg FROM 0,0 TO 600+Iif(lNwFiltros,67.5,0),640 Title "Filtragem" PIXEL
end

@ nLinha,1 Say "Metodo:" Pixel of oDlg
@ nLinha,3 COMBOBOX oFiltro  VAR aFiltrosTmp[NSTATUS] Items aFiltro[1] SIZE 80,11 Pixel  of oDlg

cHelp := ""

if _lPhxF1R1 
	@ nLinha,5 get cHelp  size 80,40 memo Pixel WHEN ;
	( Empty( cHelp := ;
	if( oFiltro:nAt == 1,"Filtra os chamados que estใo em analise na TOTVS.","")+; //	if( oFiltro:nAt == 2,"Busca na base de chamados um incidente e analise.","")+;
	if( oFiltro:nAt == 2,"Sใo chamados pendentes com o cliente aguardando aceite.","")+;
	if( oFiltro:nAt == 3,"Sใo chamados pendentes com o cliente aguardando informa็๕es.","")+;
	if( oFiltro:nAt == 4,"Sใo chamados que geraram FNC para a Sustenta็ใo que estao em analise.","")+;
	if( oFiltro:nAt == 5,"Sใo chamados em analise pela area de qualidade.","")+;
	if( oFiltro:nAt == 6,"Sใo chamados que foram associados a outros casos similares.","")+;
	if( oFiltro:nAt == 7,"Realiza o processamento geral de todos os dados para estatisticas.","") ))  of oDlg

Else
	@ nLinha,5 get cHelp  size 80,40 memo Pixel WHEN ;
	( Empty( cHelp := ;
	if( oFiltro:nAt == 1,"Filtra os chamados que estใo em analise na TOTVS.","")+;
	if( oFiltro:nAt == 2,"Busca na base de chamados um incidente e analise.","")+;
	if( oFiltro:nAt == 2,"Sใo chamados pendentes com o cliente aguardando aceite.","")+;
	if( oFiltro:nAt == 3,"Sใo chamados que geraram FNC para a Sustenta็ใo que estao em analise.","")+;
	if( oFiltro:nAt == 4,"Sใo chamados em analise pela area de qualidade.","")+;
	if( oFiltro:nAt == 5,"Sใo chamados que foram associados a outros casos similares.","")+;
	if( oFiltro:nAt == 6,"Realiza o processamento geral de todos os dados para estatisticas.","") )) of oDlg
Endif

oFiltro:nAt := ascan(aFiltro[1],aFiltrosTmp[NSTATUS])

If lNwFiltros
	nLinha += 0.5
	@ nLinha,1 Say "Somente chamados com intera็๕es:" Pixel Of oDlg
	@ nLinha,3 COMBOBOX oFilFaixa Var cTpStatist Items aFiltFaixa SIZE 80,11 Pixel ;
		When ( Iif( oFiltro:nAt <> Iif( _lPhxF1R1 , 7 , 6 ) , ( oFilFaixa:nAt := 1 , oFilFaixa:lActive := .F. ) , oFilFaixa:lActive := .T. ) ) Of oDlg

	++nLinha
	@ nLinha,1 Say "Somente chamados de clientes:" Pixel Of oDlg
	@ nLinha,3 COMBOBOX oFiltClFx Var cFiltCliFx Items aFiltClFx SIZE 80,11 Pixel ;
		When ( Iif( oFiltro:nAt <> Iif( _lPhxF1R1 , 7 , 6 ) , ( oFiltClFx:nAt := 1 , oFiltClFx:lActive := .F. ) , oFiltClFx:lActive := .T. ) ) Of oDlg
Else
	++nLinha
EndIf
@ ++nLinha,1 Say "Grupos" Pixel of oDlg
@ nLinha,3  BUTTON "Grupos" SIZE 40,11 Pixel ACTION ( MudaGrupos(aFiltrosTmp) ) of oDlg
@ nLinha,4 msget cGrupo  PICTURE "@!" size 30,11 VALID IncluiGet(1,@cGrupo,@aFiltrosTmp[EQUIPEATE]) Pixel F3 "SU0" of oDlg
@ nLinha,5 MSGET aFiltrosTmp[EQUIPEATE]  size 80,11 Pixel  of oDlg//F3 "SA1"
@ ++nLinha,1 Say "Clientes" Pixel
@ nLinha,3 msget cCliente  PICTURE "@!" size 40,11 VALID IncluiGet(2,@ccliente,@cloja,@aFiltrosTmp[CLIENTE])  Pixel F3 "SA1" of oDlg
@ 9999,99999 MSGET cLoja Pixel  of oDlg//valid (IncluiGet(2,@ccliente,@cloja,@aFiltrosTmp[CLIENTE]))
@ nLinha,4 msget aFiltrosTmp[CLIENTE]  size 110,11 Pixel  of oDlg//F3 "SA1"
@ ++nLinha,3  CHECKBOX lCliInt PROMPT "Considera clientes internos (TOTVS ex:99401) ?"  SIZE 150,11 Pixel of oDlg
@ ++nLinha,1 Say "Equipe/analista" Pixel picture "@S50" of oDlg
@ nLinha,3 COMBOBOX oArea  VAR cArea Items aAreaSel SIZE 70,11 Pixel on change (  ;
If(	cArea == "Todos",;
	(aFiltrosTmp[TECNICO] := space(255),cFiltraGrupos := ""),;
	(aFiltrosTmp[TECNICO] := ;
		pad(	alltrim(aFiltrosTmp[TECNICO]) +;
				If( !Empty(aFiltrosTmp[TECNICO]),",","") +;
				aAreas[oArea:nat-1,2], 10000 ),;
		cFiltraGrupos += aareas[oArea:nat-1,1] ))) of oDlg
@ nLinha,5 msget cAnalista  PICTURE "@!" size 30,11 when oArea:nat == 1 VALID IncluiGet(3,@cAnalista,@aFiltrosTmp[TECNICO]) Pixel F3 "SU7" of oDlg
@ ++nLinha,1 SAY "Analistas filtrado na equipe (branco para qualquer)" Pixel  of oDlg//F3 "SA1"
@ nLinha,3 msget cFiltraGrupos  size 110,11 when .f. Pixel  of oDlg//F3 "SA1"
@ ++nLinha,1 Say "Filtro selecionado da Equipe/Analista" Pixel picture "@S50" of oDlg
@ nLinha,3 msget aFiltrosTmp[TECNICO]  WHEN oArea:nat == 1   size 170,11 Pixel  of oDlg//F3 "SU0"

aFiltrosTmp[AGRUPA] := .F.

@ ++nLinha,1  SAY REPLICATE("_",110)  Pixel of oDlg
@ ++nLinha,1 Say "Ordem" Pixel of oDlg
@ nLinha,3 COMBOBOX oOrdem VAR aFiltrosTmp[ORDEM] Items AOrdem[1] SIZE 80,11 Pixel of oDlg
oOrdem:nAt := ascan(AOrdem[1],aFiltrosTmp[ORDEM])

if _lPhxF1R1
	@ ++nLinha,1  SAY "Periodo (s๓ em Estatistica Geral)" Pixel of oDlg
	@ nLinha,3  msget aFiltrosTmp[DATADE] when oFiltro:nAt == 7 SIZE 30,11 Pixel  of oDlg//VALID (validdata(aFiltrosTmp[DATADE])) Pixel
	@ nLinha,4  msget aFiltrosTmp[DATAATE] when oFiltro:nAt == 7 SIZE 30,11 Pixel of oDlg
else
	@ ++nLinha,1  SAY "Periodo (s๓ em Estatistica Geral)" Pixel of oDlg
	@ nLinha,3  msget aFiltrosTmp[DATADE] when oFiltro:nAt == 7 SIZE 30,11 Pixel  of oDlg//VALID (validdata(aFiltrosTmp[DATADE])) Pixel
	@ nLinha,4  msget aFiltrosTmp[DATAATE] when oFiltro:nAt == 7 SIZE 30,11 Pixel of oDlg
end	

@ ++nLinha,1  SAY "Inserir o Texto de analise:" Pixel of oDlg
aTextoSol := {"Total","Ultima Anแlise"}
@ nLinha,3 COMBOBOX oAnalise  VAR aFiltrosTmp[SOLUCAO] Items aTextoSol SIZE 60,11  Pixel of oDlg

If lMUsers
	@ ++nLinha,1 Say "Chamado" Pixel of oDlg
	@ nLinha,3  msget cFilChamado SIZE 30,11 Pixel of oDlg
Endif

@ ++nLinha,1  SAY "Perfil" Pixel of oDlg
@ nLinha,2  CHECKBOX aFiltrosTmp[AUTOSAVE] PROMPT "Salvar perfil"  SIZE 70,11 Pixel of oDlg
@ nLinha,3  BUTTON "Campos" ACTION ( mudapos() )  SIZE 40,11 Pixel of oDlg
@ nLinha,4  BUTTON "Salvar" SIZE 40,11 Pixel ACTION ( CRIAJANELA("SALVAR",{|| SaveProf2() },300,640)  )  of oDlg
@ nLinha,5  BUTTON "Carregar" SIZE 40,11 Pixel ACTION ( SelProfile() )  of oDlg
@ nLinha,6  BUTTON "Excluir" SIZE 40,11 Pixel ACTION ( DelProfile() )  of oDlg
@ ++nLinha,1  SAY REPLICATE("_",110)  Pixel of oDlg
@ ++nLinha,1  SAY "Filtro Aplicado:"  Pixel of oDlg
@ nLinha,3  Get cFiltro  size 170,22 MEMO when WhenFiltro(@cFiltro) Pixel of oDlg
@ ++nLinha,1  SAY "" Pixel of oDlg
@ ++nLinha,1  SAY "Outros" Pixel of oDlg
@ nLinha,2  CHECKBOX lTemporario PROMPT 'Gerar excel na pasta "C:\filtro_ssim" automaticamente ao final do processamento' SIZE 255,11 Pixel of oDlg
If lNwFiltros 
	@ ++nLinha,2  CHECKBOX lEnvEmail PROMPT 'Enviar e-mail' SIZE 255,11 Pixel of oDlg
EndIf
@ ++nLinha,1  SAY "A็ใo" Pixel of oDlg
@ nLinha,3  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION ValidConfirm(oDlg,oFiltro,@lConfirma) of oDlg
@ nLinha,4  BUTTON "Cancelar" SIZE 40,11 Pixel ACTION ( oDLG:End() ) of oDlg

if empty(lNew)
	ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
	
	if lConfirma
		if aFiltrosTmp[NSTATUS] == "Pesquisar Ocorrencia"
			aFiltrosTmp[AUTOSAVE] := .F.
		END
		if !Empty(aFiltrosTmp[PRODUTO])
			aFiltrosTmp[PRODUTO] := UPPER(aFiltrosTmp[PRODUTO])
		end
		if !Empty(aFiltrosTmp[ROTINA])
			aFiltrosTmp[ROTINA] := UPPER(aFiltrosTmp[ROTINA])
		end
		if !Empty(aFiltrosTmp[QUEBRA])
			aFiltrosTmp[AGRUPA] := aFiltrosTmp[QUEBRA]
		end
		if !Empty(cTexto1)
			cTexto1 := upper( ALLTRIM(cTexto1) )
		end
		if !Empty(cTexto2)	
			cTexto2 := upper( ALLTRIM(cTexto2) )
		end
		aFiltrosTmp[PRODUTO] := upper(M->ADE_CODSB1)
		
		if Empty(aFiltrosTmp[TECNICO])
			cFiltraGrupos := ""
		end
		
		if aFiltros[AUTOSAVE]
			MYmsgrun("Lendo Profile",,{|| myprofile() }  )
		end
		MYmsgrun("Aguarde, gerando informa็๕es",,{|| MntTemp(),montabrow(),oBrow:gotop()})
		lAbriuTela := .T.
	end
else
	AjustaTamanho(ODLG)
end

nHand := MyFCreate(cElapFile,66,@cMaxBuff)
For i := 1 To Len(aElapTime)
	cLinha := ""
	For j := 1 To Len(aElapTime[i])
		cLinha += aElapTime[i][j]+';'
	Next j
	cLinha := SubStr(cLinha,1,Len(cLinha)-1)+CHR(10)
	MyFWrite(nHand,cLinha,,@cMaxBuff)
Next i	
MyFClose(nHand,@cMaxBuff)
aElapTime := {}

If lAbriuTela .And. lEnvEmail
	ChamaExcel( .F. )
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MyExtractบAutor  ณNorberto M de Melo  บ Data ณ  17/04/2012 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo controlador da gera็ใo do extrato                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyExtract()
Local cTextHtml		:= ""
Local cFileHtml		:= ""
Local nTamFilial	:= TamSx3("ADE_FILIAL" )[1]
Local nTamCodCli	:= TamSx3("A1_COD" )[1]
Local nTamCodLj		:= TamSx3("A1_LOJA")[1]
Local lPlanejada	:= .F.
Local lPtoSlo		:= .F.
Local nI			:= 0
Local cUserFilePar	:= cUserName
Local aButtons		:= {}
Local lQryBkp		:= lQueryNew
Local cDiaVltBkp	:= cDiasVolta
Local lUsaZ26Bck	:= lUsaZ26Clc
Local lBetWenBck	:= lBetween
Local lPrMailBck	:= lParaEmail
Local lNwFiltBck	:= lNwFiltros
Local aMes			:= {"00-Anual","01-Jan","02-Fev","03-Mar","04-Abr","05-Mai","06-Jun","07-Jul","08-Ago","09-Set","10-Out","11-Nov","12-Dez"}
Local nMesSel		:= 0
Local aAno			:= {}
Local aCSV			:= {}
Local i,j			:= 0
//Local oTextFile		:= TFileBin():New()

//fElapTime()

//oTextFile:Create("c:\teste.txt")
//If oTextFile:nHandle >= 0
//	oTextFile:Write( "Olแ Mundo!", Len("Olแ Mundo!") )
//	oTextFile:Close( )
//EndIf

Private aParamFields:= {}
Private aRet		:= {}

Private lVetorExtr := .T.	// Indica Lista de Campos Especifica para o Extrato

AAdd( aAno, StrZero( Year( Date() ) - 1, 4 ) )
AAdd( aAno, StrZero( Year( Date() ), 4 ) )

DBSelectArea("SA1")
DBSelectArea("ADE")

nMesSel := AScan(aMes, {|e| Val( SubStr( e, 1, 2 ) ) == Month(Date()) })
nMesSel := If( nMesSel == 1, 12, nMesSel - 1 )

aAdd(aParamFields, {1,"Filial"        ,Space(nTamFilial)         ,"@!"    ,"U_ValParam('Filial')","SM0","",60,.T.})//"Filial"
aAdd(aParamFields, {1,"Cod. Cliente"  ,Space(nTamCodCli)         ,"@!"    ,"U_ValParam('E-mail')","SA1","",60,.T.})//"Cod. Cliente"
aAdd(aParamFields, {1,"Cod. Loja"     ,Space(nTamCodLj)          ,"@!"    ,"U_ValParam()",""   ,"",60,.F.})	//"Cod. Loja"
aAdd(aParamFields, {1,"Equipe"        ,Space(Len(SU0->U0_CODIGO)),"@!"    ,"U_ValParam()","SU0","",60,.T.})	//"Equipe"
aAdd(aParamFields, {2,"Mes(es)"       ,nMesSel,aMes,70,"ValParam()",.T.})	//"Mes da pesquisa"
aAdd(aParamFields, {2,"Ano"           ,2      ,aAno,70,"ValParam()",.T.})	//"Ano da pesquisa"
aAdd(aParamFields, {1,"E-mail"        ,Space(50)                 ,"@!"    ,"U_ValParam()",""   ,"",80,.F.})	//"E-mail"

If Parambox(aParamFields,"Extrato de Opera็๕es",@aRet,/*bOk*/,aButtons,/*lCentered*/,/*nPosX*/,/*nPosY*/,/*oMainDlg*/,cUserFilePar/*cLoad*/,.T./*lCanSave*/,.T./*lUserSave*/)
	// Preparacao e execucao da consulta
	cPerfil	:= ""
	MYMsgRun("Extrato - Lendo Profile",, {|| MyProFile(/*lLoad*/ .T.)} )
	aFiltros[NSTATUS]		:= 'Estatistica Geral'
	aFiltros[EQUIPEDE] 		:= aRet[extCODEQUIPE]
	aFiltros[EQUIPEATE] 	:= aRet[extCODEQUIPE]
	aFiltros[CLIENTE]		:= aRet[extCODCLIENTE] + aRet[extCODLOJA]
	
	If SubStr( aRet[extMES], 1, 2 ) == "00"
		aFiltros[DATADE]	:= CToD( "01/01/" + aRet[extANO] )
		aFiltros[DATAATE]	:= CToD( "31/12/" + aRet[extANO] )
	Else
		aFiltros[DATADE]	:= CToD( "01/" + SubStr( aRet[extMES], 1, 2 ) + "/" + aRet[extANO] )
		aFiltros[DATAATE]	:= DToC( aFiltros[DATADE] + 32 )
		aFiltros[DATAATE]	:= CToD( "01/" + SubStr( aFiltros[DATAATE], 4 ) ) - 1
	EndIf

	lQueryNew := .F.
	cDiasVolta := "60"
	lUsaZ26Clc := .F.
	lBetween   := .F.
	lParaEmail := .F.
	lNwFiltros := .F.
	MYMsgRun("Extrato - Aguarde, gerando informa็๕es",,{|| MntTemp(),MontaBrow(),oBrow:GoTop()})
	lQueryNew := lQryBkp
	cDiasVolta := cDiaVltBkp
	lUsaZ26Clc := lUsaZ26Bck
	lBetween   := lBetWenBck
	lParaEmail := lPrMailBck
	lNwFiltros := lNwFiltBck	

	ValidaTotais( )
	ExportExcel( .F. ,, .T. ,,, .T. )	// lHtml,cDescri,lTOTAIS,uOld,nFaixa,lNAOCRIACSV
	CarregaArea( "C:\FILTRO_SSIM\" + __cUserId + "SINTETICO.CSV", aCSV )
	
	//Monta o corpo do email
	If !Empty( aCSV ) .AND. ( Len(aCSV) > 1 ) 
		// Transforma tipo C para N dos campos que representam quantidade:
		// Ou seja, da segunda linha e do quarto campo em diante.
		// MUDA	CAMPO	CONTEUDO	ANTERIOR	DMM_YYYY	TOTAL
		For i := 2 To Len( aCSV )
			For j := 4 To Len( aCSV[ i ] )
				If ValType( aCSV[ i ][ j ] ) == 'C'
					aCSV[ i ][ j ] := Val( aCSV[ i ][ j ] )
				EndIf
			Next j
		Next i
			
		cTextHtml := GetHtml( aRet[extCODCLIENTE], aRet[extCODLOJA], "", DToS(aFiltros[DATADE]), DToS(aFiltros[DATAATE]), lPlanejada, .F./*aRet[extTIPOVALOR] == tpPERCENTUAL*/, lPtoSlo, aCSV )
	EndIf

	If !Empty( cTextHtml )
		//Gera HTML - Analitico
		cFileHtml := ExportExcel( .T. )	// lHtml,cDescri,lTotais,uOld,nFaixa,lNaoCriaCSV
		//Envia o E-mail
		MYMsgRun("Extrato - Preparando e_Mail",,{|| SendMail( aRet[extEMAIL], /*cServer*/, /*cEmail*/, /*cDe*/, cTextHtml, cFileHtml )})
	EndIf
EndIf

Return( nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetHTML   บAutor  ณNorberto M de Melo  บ Data ณ  05/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetHTML(cCodCli, cLojaCli, cCodTec, cDtIni, cDtFim, lPlanejada, lPercent, lPtoSlo, aCSV)
Local aArea			:= GetArea()// Guarda a Area Atual
Local aCond			:= {}
Local aTranMStatus	:= {}

Local cHtml 		:= ""		// corpo do e-mail
Local cNomeCli		:= ""		// Nome cliente
Local cNomeTec		:= ""		// Nome analista
Local cCodCliADE	:= ""		// Codigo do cliente para ADE_CHAVE

Default lPlanejada	:= .F.
Default lPercent	:= .F.
Default lPtoSlo		:= .F.

//fElapTime()

ASORT( aCSV ,,, { |x, y| Upper( x[2]+x[3] ) < Upper( y[2]+y[3] ) })

cCodCliADE	:= cCodCli + cLojaCli

DBSelectArea("SA1")
DBSetOrder(1)
If DBSeek(xFilial("SA1") + cCodCli + cLojaCli)
	cNomeCli := AlLtrim(SA1->A1_NOME)
Endif

DBSelectArea("AA1")
DBSetOrder(1)
If DBSeek(xFilial("SA1") + cCodTec)
	cNomeTec := AlLtrim(AA1->AA1_NOMTEC)
EndIf

cHtml := '<html>'
cHtml += '   <head>'
cHtml += '	    <title>Extrato de Atendimento do Cliente - Contrato SLA</title>'
cHtml += '      <style type="text/css">'
cHtml += '      <!--'
cHtml += '      .fontepadrao {'
cHtml += '	        font-family: Verdana, Geneva, sans-serif;'
cHtml += '      }'
cHtml += '      body,td,th {'
cHtml += '	        font-size: 10px;'
cHtml += '      }'
cHtml += '      #TOTAL {'
cHtml += '	        color: #FFF;'
cHtml += '      }'
cHtml += '      #TOTAL {'
cHtml += '	        color: #FFF;'
cHtml += '      }'
cHtml += '      -->'
cHtml += '      </style>'
cHtml += '   </head>'
cHtml += '   <body>'
cHtml += '      <h4 class="fontepadrao"><strong>EXTRATO DE ATENDIMENTO DE CLIENTE</strong></h4>'
cHtml += '      <table width="783" border="1" class="fontepadrao">'
cHtml += '         <tr>'
cHtml += '            <td colspan="2"><em>Posi็ใo em : </em><strong>'+ DtoC(dDataBase) +' เs '+SubStr(Time(),1,5)+' hrs </strong></td>'
cHtml += '         </tr>'
cHtml += '         <tr>'
cHtml += '            <td width="61">Cliente:</td>'
cHtml += '            <td width="706" class="fontepadrao"><font size=2><strong>'+ cCodCli +' - '+ cNomeCli +'</strong></font></td>'
cHtml += '         </tr>'
cHtml += '      </table>'  

cHtml += '         <br>'	// Espaco entre tabelas

cHtml += '      <table width="781" border="1" class="fontepadrao">'
cHtml += '         <tr>'
cHtml += '            <td colspan="2" align="center">Resultado no Perํodo : <strong>'+ DtoC(StoD(cDtIni)) +' เ '+DtoC(StoD(cDtFim))+'</strong></td>'
cHtml += '         </tr>'
cHtml += '      </table>'
cHtml += '      <br>'	// Espaco entre tabelas

aTranMStatus := {;
{"10-OPERADOR TMK","PENDENTE ATENDIMENTO"},;
{"30-OPERADOR QNC","PENDENTE DESENVOLVIMENTO"},;
{"60-ASSOCIADO","ASSOCIADOS (FNC-PRษ-EXISTENTE)"},;
{"20-CLIENTE","PENDENTE CLIENTE - AGUARDANDO ACEITE"},;
{"70-AGUARDANDO CLIENTE","PENDENTE CLIENTE - AGUARDANDO INFORMACOES"},;
{"50-ENCERRADO","ENCERRADOS"};
}

aCond := {;
{ "MSTATUS"   , .T. , "CHAMADOS - STATUS"                  , aTranMStatus },;
{ "CRITIC_CHM", .T. , "CRITICIDADE - CLASSIFICACAO"        , nil          };
}

cHtml += GetTableHTML( "Consolidado do Cliente", aCSV, aCond )
cHtml += '      <br>'	// Espaco entre tabelas

aCond := {;
{ "FAIXA1_SIT", .T. , "FAIXA 1 - SITUACAO"                 , nil          },;
{ "FAIXA2_SIT", .T. , "FAIXA 2 - SITUACAO"                 , nil          },;
{ "FAIXA3_SIT", .T. , "FAIXA 3 - SITUACAO"                 , nil          },;
{ "FAIXA4_SIT", .T. , "FAIXA 4 - SITUACAO"                 , nil          },;
{ "FNC"       , .T. , "NECESSIDADE DE FNC - CLASSIFICACAO" , nil          };
}

cHtml += GetTableHTML( "Severidades", aCSV, aCond )
cHtml += '      <br>'	// Espaco entre tabelas

aCond := {{ "PROCESSOS SLA", .F. , "RESULTADO GERAL DO PERอODO", nil }}
cHtml += GetTableHTML( "Efetividade", aCSV, aCond )
cHtml += '      <br>'	// Espaco entre tabelas

cHtml += '      <table width="781" border="1" class="fontepadrao">'
cHtml += '         <tr bgcolor="#000000">'
cHtml += '            <th>' + 'T O T V S&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;S. A.' + '</th>'
cHtml += '         </tr>'
cHtml += '      </table>'

cHtml += '   </body>'
cHtml += '</html>'

RestArea(aArea) // Restaura a Area Atual
	
Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSendMail  บAutor  ณNorberto M de Melo  บ Data ณ  05/28/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SendMail( cEMailTo, cServer, cEmail, cDe, cMensagem, cAnexo )
Local lOk         := .F.
Local _cLog
//fElapTime()
Private cMailConta  := GETMV("MV_EMCONTA")
Private cMailServer := GETMV("MV_RELSERV")
Private cMailSenha  := GETMV("MV_EMSENHA")

DEFAULT cAnexo		:= ""

CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk

U_SIMMail("Extrato de Atendimento" ,cMensagem,cEmailTo,cAnexo,,@_cLog)
	
If !Empty(_cLog)
	lOk := .F.
	Aviso(_cLog,{"Fechar"},2)
Endif

If lOk
	Alert("Email enviado com sucesso!")
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/30/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ValParam( cKey )
Local lRet := .T.
Local nPos := AScan(aParamFields,{|e| e[2] == cKey })
Local nAux := AScan(aParamFields,{|e| e[2] == "Cod. Cliente" })
//fElapTime()

If nPos > 0
	If		cKey == "E-mail"
		If nAux > 0 .and. !Empty(&("MV_PAR"+StrZero(nAux,2))) .and. !SA1->(EOF())
			&("MV_PAR"+StrZero(nPos,2)) := SA1->A1_EMAIL
		Else
			&("MV_PAR"+StrZero(nPos,2)) := aParamFields[nPos][3]
		EndIf
	ElseIf	cKey == "Filial"
			cMultFilial += ",'"+&("MV_PAR"+StrZero(nPos,2))+"'"
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function myprofile(lLoad)
Local cFile := ""
Local nSalva := 23
//fElapTime()
if !Empty(cPerfil)
	cFile := "c:\filtro_ssim\"+cPerfil+".cfg"
else
	cFile := "c:\filtro_ssim\"+cRealUser+".cfg"
end

if !Empty(lload)
	if !lAutomatico .and. file(cFile)
		__copyfile(cFile,cFileTmp)
		aFiltros := FT_RESTARR(cFileTmp)
		if len(aFiltros) > 12
			aStruTmp := aFiltros[13]
		end
		asize(aFiltros,nSalva)
	Else
		aFiltros := array(nSalva)
		aFiltros[INDICE] 		:= space(1)
		aFiltros[CONDICAO]		:= space(1)
		aFiltros[ORDEM] 		:= space(1)
		aFiltros[QUEBRA]		:= .T.
		aFiltros[AGRUPA]		:= .F.
		aFiltros[NSTATUS]		:= space(1)
		aFiltros[EQUIPEDE] 		:= space(2)
		aFiltros[EQUIPEATE] 	:= space(2)
		aFiltros[CLIENTE]		:= space(100)
		aFiltros[TECNICO]		:= space(100)
		aFiltros[DATADE]		:= stod( strzero( year(ddatabase),4 ) + strzero( month(ddatabase),4 ) + "01" )
		aFiltros[DATAATE]		:= ddatabase
		aFiltros[AUTOSAVE]		:= .T.
		aFiltros[PESQUISATEXTO]	:= .F.
		aFiltros[QUERY]			:= ""
		aFiltros[PRODUTO]		:= SPACE(20)
		aFiltros[ROTINA]		:= SPACE(20)
		aFiltros[CRITICIDADE]	:= SPACE(20)
		aFiltros[SOLUCAO]		:= SPACE(1)
		aStruTmp := RetVetor()
	end
else
	if type("aFiltrosTmp") == "A"
		aFiltros := aclone(aFiltrosTmp)
	end

	asize(aFiltros,nSalva)
	aFiltros[13] := aStruTmp
	FT_SAVEARR(aFiltros,cFileTmp)
	__copyfile(cFileTmp,cfile)
	ferase(cFileTmp)
end
if empty(aFiltros[15])
	aFiltros[15] := { }
	aadd(aFiltros[15], array( 8 ) )
end
if type("aFiltrosTmp") == "A"
	aFiltrosTmp := aclone(aFiltros)
end
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function legenda(cOpc,cLegenda)
Local nPos
Local legenda := {}
//fElapTime()
if empty(cLegenda)
	cLegenda := ""
end
	// LEGENDA INVALIDA
	aadd(legenda,{"","-INVALIDO OU EM BRANCO",""})
	//ENTIDADE PENDENTE  - ADE__ENTPE
	aadd(legenda,{"10","OPERADOR TMK"			,""})
	aadd(legenda,{"20","CLIENTE"				,""})
	aadd(legenda,{"30","OPERADOR QNC"			,""})
	aadd(legenda,{"40","SISTEMA"				,""})
	aadd(legenda,{"50","ENCERRADO"				,""})
	aadd(legenda,{"60","ASSOCIADO"				,""})
	aadd(legenda,{"70","AGUARDANDO CLIENTE"		,""})
	aadd(legenda,{"80","AGUARD APROV ORCAMENTO"	,""})	
	aadd(legenda,{"90","SOLIC DE REJEICAO"		,""})
	
	// PRIORIDADE
	aadd(legenda,{"1","BAIXA"	,"PRIO"})
	aadd(legenda,{"2","MEDIA"	,"PRIO"})
	aadd(legenda,{"3","ALTA"	,"PRIO"})
	aadd(legenda,{"4","CRITICA"	,"PRIO"})
	//STATUS FNC - QI2->QI2_STATUS
	aadd(legenda,{"1","REGISTRADA"		,"STATUS"})
	aadd(legenda,{"2","EM ANALISE"		,"STATUS"})
	aadd(legenda,{"3","PROCEDE"			,"STATUS"})
	aadd(legenda,{"4","NAO PROCEDE"		,"STATUS"})
	aadd(legenda,{"5","CANCELADA"		,"STATUS"})
	//STATUS DO CHAMADO
	aadd(legenda,{"1","EM ABERTO"		,"STATUS_CHAMADO"})
	aadd(legenda,{"2","PENDENTE"		,"STATUS_CHAMADO"})
	aadd(legenda,{"3","ENCERRADO"		,"STATUS_CHAMADO"})
	// SEVERIDADE
	aadd(legenda,{"1","PLANEJADA"	,"SEVCOD"})
	aadd(legenda,{"2","BAIXA"		,"SEVCOD"})
	aadd(legenda,{"3","MEDIA"		,"SEVCOD"})
	aadd(legenda,{"4","ALTA"		,"SEVCOD"})
	aadd(legenda,{"5","CRITICA"		,"SEVCOD"})
	// FATURAMENTO
	aadd(legenda,{"1","SIM"			,"FATURA"})
	aadd(legenda,{"2","NAO"			,"FATURA"})
	aadd(legenda,{"3","EM ANALISE"	,"FATURA"})
	ncache++

npos := ascan(legenda,{|x| x[1] == cOpc .and. x[3] == cLegenda } )
if npos == 0
	npos := 1
end
return copc + "-"+legenda[npos,2]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/29/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IncluiGet(nOpc,cVar1,cVar2,cVar3)
Local nTamVar := 100000
//fElapTime()
if nOpc == 1
	if !empty(cVar1)
		cVar2 := pad(AjustaVirgula(alltrim(cVar2)+","+cVar1,2,",") ,nTamVar)
	end
	cVar1 := space(2)

elseif nOpc == 2
	cVar2 := "00"
	IF !empty(cVar1) .and. !empty(cVar2)
		cVar3 := pad(alltrim(cVar3)+","+PAD(cVar1,6)+cVar2,nTamVar)
	end
	cVar1 := space(6)
	cVar2 := space(2)
elseif nOpc == 3
	if !empty(cVar1)
		cVar2 := pad(alltrim(cVar2)+","+cVar1,nTamVar)
	end
	cVar1 := space(6)
ELSEif nOpc == 4
	if !empty(cVar1)
		cVar1 := upper(cVar1)
		cVar2 := pad(alltrim(cVar2)+";"+MyPosicione("AA1",1,myxfilial("AA1") + cVar1,"AA1_EMAIL"),nTamVar)
	end
	cVar1 := space(10)
ELSEif nOpc == 5
	if !empty(cVar1)
		cVar2 := pad(alltrim(cVar2)+";"+	MyPosicione("SU5",15,myxfilial("SU5") + cVar1,"U5_EMAIL"),nTamVar)
	end
	cVar1 := space(10)
end
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function diftime(aTmDif,nTiraSec,nSeconds)
Local dataini		:= date()
Local horaini		:= seconds()
Local datafim		:= date()
Local horafim		:= seconds()
Local nDataDif		:= 0
Local cDif			:= ""
Local nDiaSemana	:= 1 // 1 - domingo 7 - sabado
Local lSextaFeira	:= .F.
Local lAcertado		:= .F.
Local n8Horas		:= timetosec(CBATIDA1) - 1 //28800 - 1 //08*60*60
Local n12Horas		:= timetosec(CBATIDA2) //43200 //12*60*60
Local n1330Horas	:= timetosec(CBATIDA3) - 1 // 48600  - 1 //13*60*60 + 30*60
Local n18Horas		:= timetosec(CBATIDA4) // 64800 //18*60*60
Local n830Horas		:= 30600 //08*60*60  + 30*60
Local n130Horas		:= 5400  // 1*60*60 + 30*60
Local nSomaHoras	:= 0
//fElapTime()
If !empty(aTmDif[1])
	dataini := aTmDif[1]
end
If !empty(aTmDif[2])
	horaini := timetosec( aTmDif[2] )
end
If !empty(aTmDif[3])
	datafim := aTmDif[3]
end
If !empty(aTmDif[4])
	horafim := timetosec( aTmDif[4] ) 
end

	lSextaFeira := ( dow(dataini) == 6 )
	
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณACERTANDO AS DATAS E HORAS DO INICIO E DO FIMณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
	
	/* ACERTAR O INICIO*/
	
	if 	horaini <= n8Horas
		horaini := n8Horas
		lAcertado := .T.
	end
	
	if 	horaini >= n18Horas
		horaini := n18Horas
		lAcertado := .T.	
	end
	
	if 	horaini >= n12Horas .and. horaini < n1330Horas // 13:30
		horaini := n1330Horas
		lAcertado := .T.	
	end
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณACERTA O FIMณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
	if 	horafim <= n8Horas
		horafim := n8Horas
		lAcertado := .T.	
	end
	
	if 	horafim >= n18Horas
		horafim := n18Horas
		lAcertado := .T.	
	end
	
	if 	horafim >= n12Horas .and. horafim < n1330Horas
		horafim := n1330Horas
		lAcertado := .T.	
	end
	
	// quando forem datas e horarios iguais ้ necessario um ajuste para nao dar fora do horario.
	if alltochar(dataini)+alltochar(horaini) == alltochar(datafim)+alltochar(horafim)
		lAcertado := .T.
		horafim++
	end
	
	/*BEGINDOC
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณACERTA O HORARIO DE ALMOCOณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ENDDOC*/
	// calcular as diferencas de dias alterar para o primeiro como 0
	// e o segundo eh a diferenca
	nDataDif := datafim - dataini
	
	/*
	SE ษ NO MESMO DIA ษ FIM - INICIO
	*/	
	if empty( nDataDif )
		nSomaHoras := horafim - horaini
		/*
		Se o chamado foi acertado e o hoario ้ exatamente as 13:30 ้ porque o chamado foi atendido entre as 12:00 e 13:30
		*/
		if lAcertado .and. ( horaini < n12horas .and. horafim >= n1330horas )
			nSomaHoras -= n130horas
		end
		If ( horaini < n12horas .and. horafim > n1330horas )
			nSomaHoras -= n130horas
		end
		
	else
		/*
		MUDOU OS DIAS
		
		A HORA INICIAL DESCONTO AS 18 PARA ACHAR O TEMPO DO FIM DO DIA
		EX.
		CHAMADO 17:00 - TOTAL 1 HORA
		Sำ PODE SOMAR CASO O DIA NAO SEJA SABADO, DOMINGO OU FERIADO
		*/
		nDiaSemana := dow(dataini)
		if ! ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) ) 
			nSomaHoras += n18Horas - horaini
		end
		
		/*
		PARA O HOARIO DO OUTRO DIA TIRO AS 8 HORAS DO INICIO DO DIA 
		EX.
		CHAMADO 10:00 - TOTAL 2 HORAS
		*/
		nSomaHoras += horafim - n8horas
		
		
		/*
		AJUSTO O HORARIO DO ALMOCO
		SE O CHAMADO INICIA 
		O UNICO CASO QUE NAO TEM HORARIO DO ALMOCO ษ
		CHAMADO 1/1 17:00
				2/1 10:00
				TOTAL 3:00
		EXISTE O CASO DE SABADO, DOMINGO E FERIADO QUE NAO DEVE SER TIRADO TAMBEM
		*/       
		If ( horaini < n12horas ) .and. !( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) ) 
			nSomaHoras -= n130horas		
		EndIf
		
		If 	( horafim > n1330horas ) .and. !( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) ) 
			nSomaHoras -= n130horas		
		EndIf
		
		/*If ! ( horaini > n1330horas .and. horafim < n12horas ) .AND. ! ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) ) 
			nSomaHoras -= n130horas
		end*/
		
		/*
		AJUSTO QUANTOS DIAS FORAM CALCULADOS
		*/
		
		dataini++ // nao conto o proprio dia
		While dataini < datafim
			nDiaSemana := dow(dataini)
			if ! ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) ) 
				nSomaHoras +=n830Horas
			end
			dataini++
		end
	end
	
// verificar
	if !Empty(nTiraSec)
		nSomaHoras -= nTiraSec
	end
	nSeconds := nSomaHoras
	cDif := nToTime(nSomaHoras ) 
	if empty(cDif) .or. "*" $ cDif .or. nSeconds <= 0
		if 	lAcertado
			cDif := "0000:00:00"
		else
			cDif := "0000:00:01" // tenho que demorar pelo menos 1 segundo entre as linhas para nao dar erro nos calculos dos tempos de atendimento
		end
	end
return cDif

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/14/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function criaobj(oDlg,nOpc)
Local cCombo := space(50)
Local cVar := space(50)
Local cVar2 := space(50)
Local cGet := ""
Local nCol :=5
Local cArea := ""
Local _lEditQry	   := GetMV("PS_EDITQRY",,.F.)
//fElapTime()
if file("C:\filtro_ssim\consulta.txt")
	cArea := memoread("C:\filtro_ssim\consulta.txt")
end
if !Empty(carea)
	carea := upper(pad(carea,3))
end
aQuerys := {}
nOpc := if(nOpc==NIL,1,nOpc)
If nOpc == 1
	@ 0, 0  Get oGet var cGet SIZE oDlg:Nclientwidth/2- 2,oDlg:Nclientheight/2 - 35 MEMO HSCROLL pixel
	If !_lEditQry
		oGet:Disable()
	EndIf
	nCol += 30
	@ oDlg:Nclientheight/2.2,nCol  BUTTON "Executa" SIZE 40,11 Pixel ACTION rptstatus( {|| RunQuery(cGet) } )
	@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Abrir" SIZE 40,11 Pixel ACTION ( cGet:=memoread(cgetfile("Select|*.sql")) )
	if upper(getenvserver()) $ "CUSTOMN2"
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Salvar" SIZE 40,11 PIXEL;
		ACTION ( MsgGet2( "Indique o nome da consulta sem caminho e sem a extensao", "Nome do arquivo sem caminho e sem extensao", @cVar, , , ),;
		memowrit(cPathLocal+carea+alltrim(cVar)+".SQL",cGet) )
	else
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Salvar" SIZE 40,11 PIXEL;
		ACTION ( MsgGet2( "Indique o nome da consulta sem caminho e sem a extensao", "Nome do arquivo sem caminho e sem extensao", @cVar, , , ),;
		memowrit(cPathCubosAC+carea+alltrim(cVar)+".SQL",cGet) )
	end
	@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )
elseif nOpc == 2
	@ 10,5 Say "Escolha a Consulta" Pixel
	@ 20,5 COMBOBOX oCombo Var cCombo Items aQuerys SIZE 200,20 Pixel
	if upper(getenvserver()) $ "CUSTOMN2"
		@ oDlg:Nclientheight/2.2,nCol  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION rptstatus( {|| cVar := memoread(cPathLocal+carea+ccombo+".sql"), RunQuery(cVar) })
	else
		@ oDlg:Nclientheight/2.2,nCol  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION rptstatus( {|| cVar := memoread(cPathCubosAC+carea+ccombo+".sql"), RunQuery(cVar) })
	end
	@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )
	@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Importar" SIZE 40,11 Pixel ACTION ( IportExport() )
elseif nOpc == 3
	cGet := memoread(cPathCubosAC+carea+alltrim(eval(oCombo:bsetget))+".sql")
	If !_lEditQry
		oGet:Disable()
	EndIf
	cvar := ccombo
	@ 0, 0  get oGet var cGet SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 25 MEMO HSCROLL pixel
	if upper(getenvserver()) $ "CUSTOMN2"
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Salvar" SIZE 40,11 PIXEL;
		ACTION ( memowrit(cPathLocal+carea+alltrim(cCombo)+".SQL",cGet) )
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Salvar como" SIZE 40,11 Pixel ACTION ( if(MsgGet2( "Indique o nome da consulta sem caminho e sem a extensao",;
		"Nome do arquivo sem caminho e sem extensao", @cCombo, , , ),;
		memowrit(cPathLocal+carea+alltrim(cCombo)+".SQL",cGet),.f.) )
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Apagar" SIZE 40,11 Pixel ACTION ( if(MsgGet2( "Indique o nome da consulta sem caminho e sem a extensao",;
		"Nome do arquivo sem caminho e sem extensao", @ccombo, , , ),;
		ferase(cPathLocal+carea+alltrim(ccombo)+".SQL"),.f.))
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Renomear" SIZE 40,11 PIXEL;
		ACTION ( MsgGet2( "Novo Nome", "Nome do arquivo sem caminho e sem extensao", @cvar, , , ),;
		frename(cPathLocal+carea+alltrim(ccombo)+".SQL",cPathLocal+carea+alltrim(cvar)+".SQL") )
	else
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Salvar" SIZE 40,11 PIXEL;
		ACTION ( memowrit(cPathCubosAC+carea+alltrim(cCombo)+".SQL",cGet) )
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Salvar como" SIZE 40,11 Pixel ACTION ( if(MsgGet2( "Indique o nome da consulta sem caminho e sem a extensao",;
		"Nome do arquivo sem caminho e sem extensao", @cCombo, , , ),;
		memowrit(cPathCubosAC+carea+alltrim(cCombo)+".SQL",cGet),.f.) )
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Apagar" SIZE 40,11 Pixel ACTION ( if(MsgGet2( "Indique o nome da consulta sem caminho e sem a extensao",;
		"Nome do arquivo sem caminho e sem extensao", @ccombo, , , ),;
		ferase(cPathCubosAC+carea+alltrim(ccombo)+".SQL"),.f.))
		@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Renomear" SIZE 40,11 PIXEL;
		ACTION ( MsgGet2( "Novo Nome", "Nome do arquivo sem caminho e sem extensao", @cvar, , , ),;
		frename(cPathCubosAC+carea+alltrim(ccombo)+".SQL",cPathCubosAC+carea+alltrim(cvar)+".SQL") )
	end
	@ oDlg:Nclientheight/2.2,nCol+=45  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oGet:End() )
end
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  12/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjusteQuery()
Local oDlg := Nil

If cRealUser $ CFAZQUERY .And. cFilAnt = '01'
	Private cTemp := "C:\FILTRO_SSIM\"
	Private cTotalBuff := ""

	//fElapTime()
	KeySet( ksACTION_OFF )	// Desativar teclas de funcoes

	Define MsDialog oDlg From 0,0 To 640,480 Title "Consultas" Pixel
	oDlg:nClientHeight	:= 600
	oDlg:nClientWidth	:= 400
	oDlg:ReadClientCoors()

	Activate MsDialog oDlg On Init CriaObj( oDlg, 1 )

	KeySet( ksACTION_ON )	// Reativar teclas de funcoes
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcRisco( aRisco, lSimples )
Local nValor	:= 0

//fElapTime( )

AEval( aRisco, {|x| nValor += x } )

If !Empty( lSimples )
    If ExecPoint( "000002" )
		If nValor <= 80
			nValor := 1
		ElseIf nValor <= 150
			nValor := 2
		Else
			nValor := 3
		EndIf
	Else
		If nValor <= 49
			nValor := 1
		ElseIf nValor <= 64
			nValor := 2
		Else
			nValor := 3
		EndIf
	EndIf
EndIf

Return nValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function Validacor(nPorc,lCritic,uValor1,uValor2)
Local oCor
//fElapTime()
If .f.
	validacor()
End
If nPorc <= 1
	oCor := aCores[1]
ElseIf nPorc <= 2
	oCor := aCores[2]
Else
	oCor := aCores[3]
EndIf
If !Empty(lCritic) .And. ( SubStr(uValor1,1,2) == "10" .and. Empty(uValor2) )
	oCor := aCores[4]
End
Return oCor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  07/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MudaPos()
Local oDlg
Local oBrow
Local lok := .F.
Local lMarca := .T.
Local cPesq := space(255)
Local x
Local lAgrupa := .F.
Local lIntera := .F.
Local nLinha := 1
Local oAgrupa
local nColuna := 0
Local oSay
Local oSay2
Local oFiltro
Local cSCampo := ""
Local oScampo
Local cFiltro := space(255)
Local nScan := 0
Local cCpGrupos := "NOME CLIENTE/SITUACAO  (1o FAIXA)/ANALISTA  (1o FAIXA)/TEMPO  (2o FAIXA)/TEMPO CLIENTE (2o FAIXA)/SITUACAO  (2o FAIXA)";
+"ANALISTA  (2o FAIXA)/TEMPO  (3o FAIXA)/SITUACAO  (3o FAIXA)/ANALISTA  (3o FAIXA)/FNC NUM/PRODUCAO/PRODUTIVIDADE";
+"GRUPO ATEND./CRITIC ROTINA/EQUIPE"
//fElapTime()
private aStrutMp2 := {}
Private aCompVet1 := retvetor()
Private aCompVet2 := aclone(astrutMP)

/*
VETOR USUARIO
*/
// adicionar do usuario
For x := 1 To Len(aCompVet2)
	If aCompVet2[x,6]
		// verificar novos campos de totaliza e agrupa
		If Len(aCompVet2[x]) <> Len(aCompVet1[1])
			aSize(aCompVet2[x],Len(aCompVet1[1]))
			aCompVet2[x,7] := .T.
			aCompVet2[x,8] :=  .T.
			aCompVet2[x,9] :=  "C"
			aCompVet2[x,10] :=  .T.
		EndIf
		aAdd(aStruTmp2, aClone(aCompVet2[x]))
	EndIf
Next X
/*
VETOR PADRAO
Local cCpGrupos := "NOME CLIENTE/SITUACAO  (1o FAIXA)/ANALISTA  (1o FAIXA)/TEMPO  (2o FAIXA)/TEMPO CLIENTE (2o FAIXA)/SITUACAO  (2o FAIXA)";
+"ANALISTA  (2o FAIXA)/TEMPO  (3o FAIXA)/SITUACAO  (3o FAIXA)/ANALISTA  (3o FAIXA)/FNC NUM/PRODUCAO/PRODUTIVIDADE";
+"GRUPO ATEND./CRITIC ROTINA/EQUIPE"

*/
For x := 1 To Len(aCompVet1)
	if ( nScan := aScan( aStruTmp2,{|y| aCompVet1[x,1] == y[1]  } ) ) == 0 // nao tenho no vetor ainda
		aAdd(aStruTmp2, aClone(aCompVet1[x]))
		aStruTmp2[Len(aStruTmp2),6] := .F.
		If aStruTmp2[Len(aStruTmp2),5] $ cCpGrupos
			aStruTmp2[Len(aStruTmp2),7] := .T.
		EndIf
	ElseIf Empty(aStruTmp2[nScan,14])
		aStruTmp2[nScan,14] := aCompVet1[x,14]
		aStruTmp2[nScan,15] := aCompVet1[x,15]
	EndIf
Next X

DEFINE MSDIALOG oDlg FROM 0,0 TO 420,640 TITLE "Escolha as colunas" PIXEL
oBrow := TwBrowse():New(1,1,125,200, , , , oDlg, , , , , , , , , , , , .F.,"ARRAY" ,.T.,,.F.,,)
oBrow:AddColumn(TCColumn():New( "Usa", {|| if(astrutMP2[oBrow:nat,6],acores[7],acores[8]) } ,,,,,,.T.,.F.,,,,.F.,))
if cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
	oBrow:AddColumn(TCColumn():New( "Cab", {|| if(astrutMP2[oBrow:nat,7],acores[7],acores[8]) } ,,,,,,.T.,.F.,,,,.F.,))
	oBrow:bChange := {|| oSay:settext("Campo           : "+astrutMP2[oBrow:nat,5]),;
	 LAgrupa := astrutMP2[oBrow:nat,7],;
	 oAgrupa:refresh(),;
	 lIntera := astrutMP2[oBrow:nat,8],;
	 oFiltro:SETENABLE( !Empty(astrutMP2[oBrow:nat,14]) ),;
	 oFiltro:REFRESH(),;
	 IF(!Empty(astrutMP2[oBrow:nat,14]).and. empty(astrutMP2[oBrow:nat,15]),astrutMP2[oBrow:nat,15]:= space(255),.t.)  }
//	oBrow:bChange := {|| oSay:settext("Campo: "+astrutMP2[oBrow:nat,5])}
else
	oBrow:bChange := {|| oSay:settext("Campo           : "+astrutMP2[oBrow:nat,5]),;
	 lIntera := astrutMP2[oBrow:nat,8],;
	 oFiltro:SETENABLE( !Empty(astrutMP2[oBrow:nat,14]) ),;
	 oFiltro:REFRESH()}
end
oBrow:AddColumn(TCColumn():New( 'Campo', {|| astrutMP2[oBrow:nat,5] } ,,,,,,.F.,.F.,,,,.F.,))
oBrow:bLDblClick := {|| aStruTmp2[oBrow:nat,6] := !aStruTmp2[oBrow:nat,6] }
oBrow:setarray(aStruTmp2)
@ nLinha,2 Say "Sele็ใo campos" Pixel
@ nLinha,4 say "" Pixel //Campos com (*) sใo obrigat๓rios no relat๓rio sint้tico
@ ++nLinha,2 Say oSay  PROMPT  "Campo           : xxxxxxxxxxxxxxxxx" Pixel
@ ++nLinha,2 Say oSay2 PROMPT  "Filtro Especial:" Pixel

@ nLinha,3 Get oFiltro var astrutMP2[oBrow:nat,15] when !Empty(astrutMP2[oBrow:nat,14]) size 90,11 Pixel

nColuna := 1
if cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
	@ ++nLinha,++nColuna  CHECKBOX oAgrupa var lAgrupa Prompt "Totaliza" SIZE 70,11 Pixel ON CHANGE ( lAgrupa := (astrutMP2[oBrow:nat,7] := !astrutMP2[oBrow:nat,7]) ,oBrow:Refresh() )
ELSE
	++nLinha
end
@  nLinha,++nColuna  CHECKBOX lMarca Prompt "Marca/Desmarca todos" SIZE 70,11 Pixel ON CHANGE (aeval( astrutMP2,{|x| x[6] := lMarca } ),oBrow:Refresh() )
@ ++nLinha,2 Say "Pesquisar pela descri็ใo" Pixel
@ nLinha,3 msget cPesq PICTURE "@!" size 50,11 Pixel
@ nLinha,4  BUTTON "Pesquisa"		SIZE 40,11 Pixel ACTION (MyPesq(5,cPesq,oBrow,aStruTmp2),EVAL(oBrow:bChange))
if cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
	nColuna := 2
	@ ++nLinha,2 Say "Totaliza็๕es especificas" Pixel
	@ nLinha,3 msget oScampo Var cSCampo PICTURE "@!" size 90,11 Pixel readonly
	@ ++nLinha,ncoluna  BUTTON "Seleciona"		SIZE 40,11 Pixel ACTION (cSCampo += if(!empty(cSCampo),"+","") + astrutMP2[oBrow:nat,1] ,oScampo:refresh() )
	@ nLinha,++ncoluna  BUTTON "Limpa"		SIZE 40,11 Pixel ACTION (cSCampo := "" ,oScampo:refresh() )
	@ nLinha,++ncoluna  BUTTON "Adicionar"		SIZE 40,11 Pixel ACTION (IF (!eMPTY(cScampo),(aadd(aStruTmp2,{cScampo,"C",255,0,cScampo,.T.,.T.,.F.,"C",.F.,.F.,.F.,.F.}) ,;
	cSCampo := ""),""))
end
@ ++nLinha,2 Say "Escolha a ordem dos campos pelos bot๕es abaixo" Pixel
@ ++nLinha,2  BUTTON "Sobe"		SIZE 40,11 Pixel ACTION reposiciona(oBrow,.t.)
@ nLinha,3  BUTTON "Desce"	SIZE 40,11 Pixel ACTION reposiciona(oBrow,.f.)
if cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
	@ ++nLinha,2  BUTTON "OK"			SIZE 40,11 Pixel ACTION (ValidSelect(astrutMP2,cCpGrupos),lOk := .t.,oDlg:end())
else
	@ ++nLinha,2  BUTTON "OK"			SIZE 40,11 Pixel ACTION (lOk := .t.,oDlg:end())
end
@ nLinha,3  BUTTON "CANCELA"			SIZE 40,11 Pixel ACTION (oDlg:end())
ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
if lok
	aStruTmp := aclone(aStruTmp2)
end
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Reposiciona(oBrow,lSobe)
Local nPosAtu := oBrow:nAt
Local aTmp := aclone(aStrutMp2[nPosAtu])
Local aTmp2
Local nPos := 1
//fElapTime()
If !Empty(lSobe)
	nPos := -1
EndIf
If (oBrow:nAt + nPos >0) .and. (oBrow:nAt + nPos <= len(aStrutMp2))
	oBrow:nAt += nPos
	aTmp2 := aclone(aStrutMp2[oBrow:nAt])
	
	aFill(aStrutMp2,aTmp,oBrow:nAt,1)
	
	aFill(aStrutMp2,aTmp2,nPosAtu,1)
EndIf
oBrow:setarray(aStrutMp2)
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function MudaGrupos(aFiltrosTmp)
Local oDlg
Local oBrow
Local lOk := .F.
Local lMarca := .t.
Local cPesq := space(255)
//fElapTime()
DEFINE MSDIALOG oDlg FROM 0,0 TO 440,640 TITLE "Escolha os grupos" PIXEL
oBrow := TwBrowse():New(1,1,100,200, , , , oDlg, , , , , , , , , , , , .F.,"ARRAY" ,.T.,,.F.,,)
oBrow:AddColumn(TCColumn():New( "Usa", {|| if(aGrupos[oBrow:nat,1],acores[7],acores[8]) } ,,,,,,.T.,.F.,,,,.F.,))
oBrow:AddColumn(TCColumn():New( 'Codigo', {|| aGrupos[oBrow:nat,2] } ,,,,,,.F.,.F.,,,,.F.,))
oBrow:AddColumn(TCColumn():New( 'Descricao', {|| aGrupos[oBrow:nat,3] } ,,,,,,.F.,.F.,,,,.F.,))
oBrow:bLDblClick := {|| aGrupos[oBrow:nat,1] := !aGrupos[oBrow:nat,1] }
oBrow:setarray(aGrupos)
@ 1,2 Say "Marque os grupos ao lado a serem exibidos" Pixel
@ 2,2  CHECKBOX lMarca Prompt "Marca/Desmarca todos" SIZE 70,11 Pixel ON CHANGE (aeval( aGrupos,{|x| x[1] := lMarca } ),oBrow:Refresh() )
@ 3,2 Say "Pesquisar pela descri็ใo" Pixel
@ 4,2 msget cPesq PICTURE "@!" size 50,11 Pixel
@ 4,3  BUTTON "Pesquisa"		SIZE 40,11 Pixel ACTION MyPesq(3,cPesq,oBrow,aGrupos)
@ 5,2  BUTTON "OK"			SIZE 40,11 Pixel ACTION (lOk := .T., oDlg:end())
@ 5,3  BUTTON "CANCELA"			SIZE 40,11 Pixel ACTION (oDlg:end())
@ 1,4 say "" pixel
ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
if lOk
	aFiltrosTmp[EQUIPEATE] := "  "
	aeval(agrupos, {|x| if(x[1], aFiltrosTmp[EQUIPEATE] += ","+x[2],.f.) } )
end
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*ENVIO DE WORKFLOWS - TELA DE CONFIGURAวรO*/
Static Function MyEmails( lAuto, lJa )
Local oDlg		:= NIL
Local lOk		:= .F.
Local aEmail	:= {}
Local cChave	:= "WORKFLOW"
Local nPos		:= 0
Local cFile		:= ""
Local cLog		:= NIL
Local cEmailT	:= space(255)
Local cEmailCli	:= space(255)
Local nLinha	:= 1
Local cPerOld	:= cPerfil
Local n20min	:= 1200 // 20 * 60
local nCount	:= 1
Local cStatus	:= ""
Local nFx		:= NIL

Private cPerfil	:= cPerEmail

//fElapTime()

If (nPos := ascan(aFiltros[15], {|x| X[1] == cChave } ) ) > 0
	aEmail := aclone(aFiltros[15,nPos])
Else
	aEmail := aclone(aFiltros[15,1])
	afill(aEmail,space(255))
	aEmail[1] := cChave
EndIf

//modelo novo
//aEmail[1] chave de pesquisa
//aEmail[2] email fx 1
//aEmail[3] tempo fx 1
//aEmail[4] email fx 2
//aEmail[5] tempo fx 2
//aEmail[6] email fx 3
//aEmail[7] tempo fx 3

aSize(aEmail,10)

if aEmail[02] == NIL .or. valtype(aEmail[02]) <> "C"
	aEmail[02] := space(255)
end
if aEmail[03] == NIL .or. valtype(aEmail[03]) <> "N"
	aEmail[03] := 20
end
if aEmail[04] == NIL .or. valtype(aEmail[04]) <> "C"
	aEmail[04] := space(255)
end
if aEmail[05] == NIL .or. valtype(aEmail[05]) <> "N"
	aEmail[05] := 1440
end
if aEmail[06] == NIL .or. valtype(aEmail[06]) <> "C"
	aEmail[06] := space(255)
end
if aEmail[07] == NIL .or. valtype(aEmail[07]) <> "N"
	aEmail[07] := 1440
end
if aEmail[08] == NIL .or. valtype(aEmail[08]) <> "C"
	aEmail[08] := SPACE(255)
end
if aEmail[09] == NIL .or. valtype(aEmail[09]) <> "N"
	aEmail[09] := 1440
end
if aEmail[10] == NIL .or. valtype(aEmail[10]) <> "C"
	aEmail[10] := SPACE(255)
end

cGrupoOld	:= aFiltros[EQUIPEATE]
cStatus		:= afiltros[NSTATUS]
cClientes	:= aFiltros[CLIENTE]
cTecnicos	:= aFiltros[TECNICO]
cOrdem		:= aFiltros[ORDEM]

If Empty( lAuto )

	DEFINE MSDIALOG oDlg FROM 0,0 TO 550,640 TITLE "Enviar Email" PIXEL
	@   nLinha,01 Say "Ao confirmar a rotina enviarแ imediatamente todos os workflows para os emails definidos e reenviarแ conforme configura็ใo" Pixel
	@   nLinha,10 Say "" PIXEL
	
	@ ++nLinha,01 Say "Grupos para WorkFlow" PIXEL
	@   nLinha,04 MSGet aEmail[8]   SIZE 50,11 Pixel //F3 "SA1" size 150,11	
	@ ++nLinha,01 Say "O reenvio serแ ap๓s o tempo determinado para cada faixa" Pixel

	// >>> 	FAIXA 1 <<< --------------------------------------------------------------------
	@ ++nLinha,01 Say "Emails para recebimento da notifica็ใo da faixa 1" Pixel
	@ ++nLinha,01 Say "Codigo do analista (TI)" Pixel	
	@   nLinha,03 Say "Emails" Pixel		
	IW_Edit(++nLinha,1,cEmailT,,30,11,{|| IncluiGet(4,@cEmailT,@aEmail[2]) },,"AA1",,,{|x| iif(PCount()>0,cEmailT := x,cEmailT ) })
	@   nLinha,03 MSGet aEmail[2]  size 150,11 Pixel //F3 "SU7"
	@ ++nLinha,01 Say "Tempo para reenvio de email (em minutos)" Pixel
	@   nLinha,04 MSGet aEmail[3]   size 50,11 picture "@E 9999 " Pixel //F3 "SA1" size 150,11

	// >>> 	FAIXA 2 <<< --------------------------------------------------------------------
	@ ++nLinha,01 Say "Emails para recebimento da notifica็ใo da faixa 2" Pixel
	@ ++nLinha,01 Say "Codigo do analista (TI)" Pixel	
	@   nLinha,03 Say "Emails" Pixel		
	IW_Edit(++nLinha,1,cEmailT,,30,11,{|| IncluiGet(4,@cEmailT,@aEmail[4]) },,"AA1",,,{|x| iif(PCount()>0,cEmailT := x,cEmailT ) })
	@   nLinha,03 MSGet aEmail[4]  size 150,11 Pixel //F3 "SU7"
	@ ++nLinha,01 Say "Tempo para reenvio de email (em minutos)" Pixel
	@   nLinha,04 MSGet aEmail[5]   size 50,11 picture "@E 9999 " Pixel //F3 "SA1" size 150,11

	// >>> 	FAIXA 3 <<< --------------------------------------------------------------------
	@ ++nLinha,01 Say "Emails para recebimento da notifica็ใo da faixa 3" Pixel
	@ ++nLinha,01 Say "Codigo do analista (TI)" Pixel	
	@   nLinha,03 Say "Emails" Pixel		
	IW_Edit(++nLinha,1,cEmailT,,30,11,{|| IncluiGet(4,@cEmailT,@aEmail[6]) },,"AA1",,,{|x| iif(PCount()>0,cEmailT := x,cEmailT ) })
	@   nLinha,03 MSGet aEmail[6]  size 150,11 Pixel //F3 "SU7"
	@ ++nLinha,01 Say "Tempo para reenvio de email (em minutos)" Pixel
	@   nLinha,04 MSGet aEmail[7]   size 50,11 picture "@E 9999 " Pixel //F3 "SA1" size 150,11

	// >>> tratamento para chamados que estao pendentes com o cliente <<< -------------------
	@ ++nLinha,01 Say "Emails para recebimento pendentes com o cliente" Pixel
	@ ++nLinha,01 Say "Codigo do analista (TI)" Pixel	
	@   nLinha,03 Say "Emails" Pixel		
	IW_Edit(++nLinha,1,cEmailT,,30,11,{|| IncluiGet(4,@cEmailT,@aEmail[10]) },,"AA1",,,{|x| iif(PCount()>0,cEmailT := x,cEmailT ) })
	@   nLinha,03 MSGet aEmail[10]  size 150,11 Pixel //F3 "SU7"
	@ ++nLinha,01 Say "Tempo para reenvio de email (em minutos)" Pixel
	@   nLinha,04 MSGet aEmail[9]   size 50,11 picture "@E 9999 " Pixel //F3 "SA1" size 150,11	

	// >>> BOTOES <<< -----------------------------------------------------------------------
	@ ++nLinha,01  BUTTON "Ativar"   Size 40,11 Pixel ACTION ( lOk := .T., oDlg:End( ) )
	@   nLinha,02  BUTTON "Cancelar" Size 40,11 Pixel ACTION ( oDlg:End( ) )

	ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho( ODLG )

	If lOk
		oTimer1:nInterval := ( min( aEmail[3], min( aEmail[5], aEmail[7] ) ) * 60 ) * 1000
		If Empty( nPos )
			AADD( aFiltros[15], aEmail )
		Else
			aFiltros[15,nPos] := aEmail
		EndIf

		If aFiltros[AUTOSAVE]
			MyMsgRun( "Lendo Profile",, {|| myprofile( )} )
		EndIf

		nInterval1 := 0
		nInterval2 := 0
		nInterval3 := 0
		nInterval4 := 0		
	EndIf
	
	SU5->( DBClearFilter( ) )
Else
	lOk := !lParaEmail .Or. ( lParaEmail .And. TimeToMin( Time() ) <= TimeToMin( CBATIDA4 ) .And. IsDiaUtil( Date() ) )
	nFx := 1
EndIf

aFiltros[EQUIPEATE]	:= ALLTRIM(aEmail[8])
aFiltros[CLIENTE]	:= ""
aFiltros[TECNICO]	:= ""
afiltros[NSTATUS]	:= "Pendente Analista"
aFiltros[ORDEM]		:= "Chamado"
cFilChamado			:= SPACE(06)

IF lOk
	nInterval1 += ( oTimer1:nInterval / 1000 ) / 60
	nInterval2 += ( oTimer1:nInterval / 1000 ) / 60
	nInterval3 += ( oTimer1:nInterval / 1000 ) / 60
	nInterval4 += ( oTimer1:nInterval / 1000 ) / 60	
EndIf

// Envio de WorkFlow para a faixa 1 ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If	( nInterval1 > 0 ) .and.;
	( lOk .and.;
	( Empty( nFx ) .and. !Empty( aEmail[2] ) ) .or.;
	( nInterval1 >= aEmail[3] .and. !Empty( aEmail[2] ) ) )

	// Manda emails para o Tempo1 com chamados que foram abertos e sem manipula็ao
	nInterval1			:= 0
	cPerEmail			:= cPerfil
	lAtua				:= .T.
	aFiltros[QUERY]		:= " ADE__ENTPE = '10' "
	aFiltros[QUERY]		+= " AND ADE_GRUPO IN " +montain( alltrim(aEmail[8]) ) + ""
	afiltros[NSTATUS]	:= "Pendente Analista"
	MYmsgrun("Atualizando informa็๕es - FAIXA 1",,{|| lAtua := MntTemp(,lJa,1),montabrow(),oBrow:gotop() }  )
	cFile				:= ExportExcel( .t., "Faixa 1",, .T., 1 )
	If lAtua
		MYMSGRUN("Enviando Email",,{|| 	EnviaEmail(alltrim(aEmail[2]),"WorkFlow DashBoard - FAIXA 1",cFile) } )
	EndIf
EndIf

// Envio de WorkFlow para a faixa 2 ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If	( nInterval2 > 0 ) .and.;
	( lOk .and.;
	( Empty( nFx ) .and. !Empty( aEmail[4] ) ) .or.;
	( nInterval2 >= aEmail[5] .and. !Empty( aEmail[4] ) ) )

	// Manda emails para o Tempo2 com chamados que foram abertos e sem manipula็ao
	nInterval2			:= 0
	lAtua				:= .T.
	aFiltros[QUERY]		:= " ADE__ENTPE IN ('10','90') "
	aFiltros[QUERY]		+= " AND ADE_GRUPO IN " +montain( alltrim(aEmail[8]) ) + ""
	afiltros[NSTATUS]	:= "Pendente Analista"
	MYmsgrun("Atualizando informa็๕es - FAIXA 2",,{|| lAtua := MntTemp(,lJa,2),montabrow(),oBrow:gotop() }  )
	cFile				:= ExportExcel( .t., "Faixa 2",, .F., 2 )
	If lAtua
		MYMSGRUN("Enviando Email",,{|| 	EnviaEmail(alltrim(aEmail[4]),"WorkFlow DashBoard - FAIXA 2",cFile) } )
	EndIf
EndIf

// Envio de WorkFlow para a faixa 3 ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If	( nInterval3 > 0 ) .and.;
	( lOk .and.;
	( Empty( nFx ) .and. !Empty(aEmail[6]) ) .or.;
	( nInterval3 >= aEmail[7] .and. !Empty(aEmail[6]) ) )

	// Manda emails para o Tempo2 e Tempo3 com chamados que foram abertos e sem manipula็ao
	nInterval3			:= 0
	lAtua				:= .T.
	aFiltros[QUERY]		:= " ADE__ENTPE = '30' "
	aFiltros[QUERY]		+= " AND ADF_GRUPO IN " +montain( alltrim(aEmail[8]) ) + ""
	afiltros[NSTATUS]	:= "FNC Pendentes"
	MYmsgrun("Atualizando informa็๕es - FAIXA 3",,{|| lAtua := MntTemp(,lJa,3),montabrow(),oBrow:gotop() }  )
	cFile				:= ExportExcel( .t., "Faixa 3",, .F., 3 )
	If lAtua
		MYMSGRUN("Enviando Email",,{|| 	EnviaEmail(alltrim(aEmail[6]),"WorkFlow DashBoard - FAIXA 3",cFile) } )
	EndIf
EndIf

// Envio de emails pendentes para clientes ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If	( nInterval4 > 0 ) .and.;
	( lOk .and.;
	( Empty( nFx ) .and. !Empty(aEmail[10]) ) .or.;
	( nInterval4 >= aEmail[9] .and. !Empty(aEmail[10]) ) )

	nInterval4			:= 0
	lAtua				:= .T.
	aFiltros[QUERY]		:= " ADE__ENTPE = '70' "
	aFiltros[QUERY]		+= " AND ADE_GRUPO IN " +montain( alltrim(aEmail[8]) ) + ""
	afiltros[NSTATUS]	:= "Pend.Cli.-Retorno"
	MYmsgrun("Atualizando informa็๕es - Pendente Cliente",,{|| lAtua := MntTemp(,lJa,4),montabrow(),oBrow:gotop() }  )
	cFile				:= ExportExcel( .t., "Pendente Cliente",, .F., 4 )
	If lAtua
		MYMSGRUN("Enviando Email",,{|| 	EnviaEmail(alltrim(aEmail[10]),"WorkFlow DashBoard",cFile) } )
	EndIf
end	

// Voltando filtro para a faixa 1 ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If lOk .AND. !Empty( nInterval1 + nInterval2 + nInterval3 + nInterval4 )
	lAtua				:= .T.
	aFiltros[QUERY]		:= " ADE__ENTPE IN ('10','90') "
	aFiltros[QUERY]		+= " AND ADE_GRUPO IN " +montain( alltrim(aFiltros[EQUIPEATE]) ) + ""
	afiltros[NSTATUS]	:= "Pendente Analista"
	MYmsgrun("Voltando filtro para Faixa 1",,{|| lAtua := MntTemp(),montabrow(),oBrow:gotop() }  )
End

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/18/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function MyPesq(nVet,cPesq,oBrow,aStruTmp2)
Local nPos
//fElapTime()
cPesq := upper(alltrim(cPesq))
if (  nPos := ascan(aStruTmp2, {|x| upper(cpesq) $ upper(alltrim(x[nVet])) },oBrow:nAt+1 ) ) > 0
	oBrow:nAt := nPos
	oBrow:refresh()
else
	msgstop("nao encontrado " + cPesq)
end
return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/02/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem do filtro para a query.                           บฑฑ
ฑฑบ          ณ Filtro principal                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaFilOk( cInFaixa , cInCliFx , nTamCHOrg )
Local x			:= NIL
Local cQuery	:= ""
Local cDistinct := ""
 
//fElapTime(.F.)
aFiltros[QUERY]	:= ""

If aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .Or. aFiltros[NSTATUS] == "Estatistica Geral"
	If lBetween
		If aFiltros[ DATADE ] == aFiltros[ DATAATE ]
			aFiltros[ QUERY ]  += " ADF_DATA = '" + DtoS( aFiltros[ DATADE ] ) + "' "
		Else
			aFiltros[ QUERY ]  += " ADF_DATA BETWEEN '" + DtoS( aFiltros[ DATADE ] ) + "' AND '" + DtoS( aFiltros[ DATAATE ] ) + "' "
		EndIf
		cDistinct          := "DISTINCT "
		aFiltros[ DATADE ] := aFiltros[ DATAATE ] + 1
		lSaida             := .T.
	Else
		If lQueryNew .And. Empty( cFilChamado )
			aFiltros[QUERY] += " ADF_DATA = '" + DtoS(aFiltros[DATADE]) + "' "
		Else
			aFiltros[QUERY] += " ( ADF_DATA >= '" + DtoS(aFiltros[DATADE]) + "' AND "
			aFiltros[QUERY] += " ADF_DATA <='" + DtoS(aFiltros[DATAATE]) +"' ) "
		End
	EndIf
End

// pendentes chamados pela data com o status abaixo
//aFiltros[CONDICAO] += afiltro[2,ascan(afiltro[1],aFiltros[NSTATUS])]

// pendente analista todos analistas + branco/auto
// todos 
If ( nScan := aScan( aFiltro[ 1 ] , aFiltros[NSTATUS] ) ) > 0
	If !Empty( aFiltro[ 3 , nScan ] )
		If Empty( aFiltros[QUERY] )
			aFiltros[QUERY] += aFiltro[ 3 , nScan ]
		Else
			aFiltros[QUERY] += " AND " + aFiltro[ 3 , nScan ]
		EndIf
	EndIf
EndIf

If !Empty(aFiltros[CLIENTE])
	cCli := ConvPrivates(alltrim(aFiltros[CLIENTE]))
	If "," $ cCli .OR. ";" $ cCli
		aFiltros[QUERY] += " AND ADE_CHAVE IN " + montain(alltrim(cCli)) + " "	
	Else
		aFiltros[QUERY] += " AND ADE_CHAVE = '" + alltrim(cCli) + "' "	
	End
EndIf

If !lCliInt
	If lQueryNew 
			aFiltros[QUERY] += " AND ( NOT (ADE_CHAVE >= '99' AND ADE_CHAVE <= '99ZZZZZ' ) OR ( ADE_CHAVE >= '99061' AND ADE_CHAVE <= '99061ZZ') " 
	Else   
			aFiltros[QUERY] += " AND ( SUBSTRING(ADE_CHAVE,1,2) <> '99' OR SUBSTRING(ADE_CHAVE,1,5) = '99061' " 	
	End
	
	If !empty(cEmpFiltra)
			aFiltros[QUERY] +=  "OR ADE_CHAVE IN (" + cEmpFiltra + ") " 
	End       

	aFiltros[QUERY] +=  ") " //AND NOT SUBSTRING(ADE_CHAVE,1,5) <> '99061' ) 
End
	
/*NOS CASOS DOS CHAMADOS TRANSFERIDOS, DEVO OLHAR AMBOS OS CAMPOS*/
/*
Pendente Analista			- APENAS CABEC	- SEMPRE O CHAMADO DEVE ESTAR AQUI
Pesquisar Ocorrencia		- APENAS CABEC	- POIS COLOCO ONDE QUERO PESQUISAR -- nใo existe mais, tiramos em 25/08/2011
OLD - Pendente Cliente	- APENAS CABEC	- O CHAMADO SO PODE FICAR PENDENTO COM O CLIENTE NA AREA
Pend.Cli.-Retorno			- APENAS CABEC	- O CHAMADO SO PODE FICAR PENDENTO COM O CLIENTE NA AREA
Pend.Cli.-Aceite			- APENAS CABEC	- O CHAMADO SO PODE FICAR PENDENTO COM O CLIENTE NA AREA
FNC Pendentes				- LINHAS			- O CHAMADO NAO ESTA NA AREA, POREM JA PASSOU POR AQUI
Pendencias na Qualidade	- LINHAS			- O CHAMADO NAO ESTA NA AREA, POREM JA PASSOU POR AQUI
Chamados Associado		- APENAS CABEC	- O CHAMADO EH DA AREA
Estatistica Geral			- AMBOS			- TENHO QUE VER QUALQUER CHAMADO DA AREA NAO IMPORTA ONDE
*/
If aFiltros[NSTATUS] $ "Pendente Analista/Pendente Cliente/Pend.Cli.-Retorno/Pend.Cli.-Aceite/Chamados Associado/Pesquisar Ocorrencia"
//filtrando no cabe็alho (ADE)
	If "," $ aFiltros[EQUIPEATE] .OR. ";" $ aFiltros[EQUIPEATE]
		aFiltros[QUERY] += " AND ADE_GRUPO IN " +montain(alltrim(aFiltros[EQUIPEATE])) + "  "
	Else
		aFiltros[QUERY] += " AND ADE_GRUPO = '" +alltrim(aFiltros[EQUIPEATE] )+ "'  "
	End
ElseIf aFiltros[NSTATUS] $ "FNC Pendentes/Pendencias na Qualidade"
//filtrando nas linhas (ADF)
	If "," $ aFiltros[EQUIPEATE] .OR. ";" $ aFiltros[EQUIPEATE]
		aFiltros[QUERY] += " AND ADF_CODSU0 IN " +montain(alltrim(aFiltros[EQUIPEATE])) + " " 
	Else
		aFiltros[QUERY] += " AND ADF_CODSU0 = '" +alltrim(aFiltros[EQUIPEATE]) + "' " 	
	End
Else // /Estatistica Geral
//filtrando no cabe็alho (ADE) ou nas linhas (ADF)
	If "," $ aFiltros[EQUIPEATE] .OR. ";" $ aFiltros[EQUIPEATE]
		aFiltros[QUERY] += " AND ( ADE_GRUPO IN " + montain(AllTrim(aFiltros[EQUIPEATE])) + " OR "
		aFiltros[QUERY] += " ADF_CODSU0 IN " + montain(AllTrim(aFiltros[EQUIPEATE])) + " ) "
	Else
		aFiltros[QUERY] += " AND ( ADE_GRUPO = '" + AllTrim(aFiltros[EQUIPEATE]) + "' OR "
		aFiltros[QUERY] += " ADF_CODSU0 = '" + AllTrim(aFiltros[EQUIPEATE]) + "' ) "
	End
End

If !Empty(aFiltros[TECNICO])
	If aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .or. aFiltros[NSTATUS] == "Estatistica Geral"
		If "," $ aFiltros[TECNICO] .OR. ";" $ aFiltros[TECNICO]
			aFiltros[QUERY] += "AND ADF_CODSU7  IN " + montain( alltrim(aFiltros[TECNICO]) )
		Else
			aFiltros[QUERY] += "AND ADF_CODSU7  = '" + alltrim(aFiltros[TECNICO]) + "' "
		EndIf
	Else
		aFiltros[QUERY] += "AND ADE_OPERAD  IN " + montain( alltrim(aFiltros[TECNICO]) + ",AUTO,      " )
	EndIf
	aFiltros[QUERY] += " "
EndIf

For x := 1 to Len( aStruTmp )
	If Len( aStruTmp[ x ] ) == 15
		If !Empty(aStruTmp[x,15])

			If "," $ aStruTmp[x,15] .OR. ";" $ aStruTmp[x,15]
				aFiltros[QUERY] += "AND "+ aStruTmp[x,14] +"  IN " + montain( alltrim( aStruTmp[x,15] ) )
			Else
				aFiltros[QUERY] += "AND "+ aStruTmp[x,14] +"  = '" + alltrim( aStruTmp[x,15] ) + "' "
			EndIf
		EndIf
	EndIf
Next X

// Nao processa chamados que nao possuem cod de abertura adequados
If !Empty(cAssuntArea)

	If "," $ cAssuntArea .OR. ";" $ cAssuntArea
		aFiltros[QUERY] += "AND ( AND ADE_ASSUNT IN " + montain(cAssuntArea) + "  "
	Else
		aFiltros[QUERY] += "AND ( ADE_ASSUNT = '" + cAssuntArea + "'  "
	EndIf			


	If "," $ TPFX1INI .OR. ";" $ TPFX1INI
		aFiltros[QUERY] += "AND  ADF_ITEM='001' AND ADF_CODSUQ IN " + montain(TPFX1INI) + " ) "
	Else
		aFiltros[QUERY] += "AND  ADF_ITEM='001' AND ADF_CODSUQ = '" + TPFX1INI + "' ) "
	EndIf			
EndIf
// este chamado devera ser ignorado
/*NAO DA CERTO COLOCAR NA QUERY PRINCIPAL POIS PARA CADA DIA PODE HAVER */
/*
IF !eMPTY(CANCELAMENTOS)
	if "," $ CANCELAMENTOS .OR. ";" $ CANCELAMENTOS
		aFiltros[QUERY] += "AND NOT ADF_CODSUQ IN " + montain(CANCELAMENTOS) + " "
	else
		aFiltros[QUERY] += "AND NOT ADF_CODSUQ = '" + CANCELAMENTOS + "' "
	end			
end	
*/

If lQueryNew
	cQuery := "SELECT " + cDistinct + "ADE_FILIAL, ADE_CODIGO, ADE_DATA "
Else
	cQuery := "SELECT DISTINCT ADE_FILIAL, ADE_CODIGO, ADE_DATA "
EndIf

cQuery += "FROM " + RETSQLNAME("ADE")+ " ADE"

If "ADF" $ aFiltros[QUERY]
	 cQuery +=  "," + RETSQLNAME("ADF") + " ADF"
EndIf

cQuery += " WHERE "

If !Empty( cFilChamado )
	cQuery += "ADE_CODIGO = '" + cFilChamado + "' AND "
EndIf

If Empty( cMultFilial )
	cQuery += "ADE_FILIAL = '" + myxfilial("ADE") +"' AND "
Else
	cQuery += "ADE_FILIAL IN (" + cMultFilial + ") AND "
EndIf

cQuery += "ADE.D_E_L_E_T_ = ' ' AND "

If "ADF" $ aFiltros[QUERY]
	cQuery += "ADE_CODIGO = ADF_CODIGO AND "
	If empty(cMultFilial)
		cQuery += "ADF_FILIAL = '" +myxfilial("ADF")+ "' AND "
	Else
		cQuery += "ADF_FILIAL IN (" + cMultFilial + ") AND "	
	EndIf
	cQuery += "ADF.D_E_L_E_T_ = ' ' AND "
	cQuery += cInFaixa
EndIf

cQuery += cInCliFx

aFiltros[QUERY] := cQuery + aFiltros[QUERY]
aFiltros[QUERY] += " AND ADE_CHORIG = '" + Space( nTamCHOrg ) + "'"

If lBetween .And. lNwFiltros
	aFiltros[QUERY] += "AND ADE_CODEFE <> '" + Pad( "EFE041" , TamSX3( "ADE_CODEFE" )[ 1 ] ) + "'"
	aFiltros[QUERY] += "AND ADE_CODEFE <> '" + Pad( "EFE028" , TamSX3( "ADE_CODEFE" )[ 1 ] ) + "'"
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EnviaEmail(cPara,cAssunto,cFile,cMensagem)
local lResult
Local cConta	:= alltrim( GetMV( "MV_RELACNT"))
Local cSenha	:= Alltrim( GetMV( "MV_RELPSW" ))
Local cServer	:= Alltrim( GetMV( "MV_RELSERV"))
Local cLog		:= ""
Local cLog2		:= ""
Default cMensagem := ""
//fElapTime()
If Empty( cMensagem )
	U_SIMMail(cAssunto,MemoRead(cFile),cPara,cFile,,@cLog)
Else
	U_SIMMail(cAssunto,cMensagem,cPara,cFile,,@cLog)
EndIf
if !Empty(cLog)
	cLog2 += "erro no padrao:" + cLog + CRLF
	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenha RESULT lResult	
	if !lResult
		GET MAIL ERROR cLog
		cLog2 += "erro no connect sem senha:" + cLog + CRLF
		CONNECT SMTP SERVER cServer ACCOUNT CUSERMAIL PASSWORD CSENHAMAIL RESULT lResult
		if !lResult
			GET MAIL ERROR cLog
			cLog2 += "erro no connect com senha:" + cLog + CRLF
		end
	end
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se o Servidor de EMAIL necessita de Autenticacaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	// verificar como validar os emails
	
	if !lResult //.and. GetMv("MV_RELAUTH")
		//Primeiro tenta fazer a Autenticacao de E-mail utilizando o e-mail completo
		lResult := MailAuth(cConta, cSenha)
		//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer a autenticacao usando apenas o nome de usuario do E-mail
		if !lResult
			GET MAIL ERROR cLog
			cLog2 += "erro no autentica padrao:" + cLog + CRLF
			lResult := MailAuth(CUSERMAIL,CSENHAMAIL)
			if !lResult
				GET MAIL ERROR cLog
				cLog2 += "erro no autentica local:" + cLog + CRLF
			end
		endif
	endif
	
	If lResult
		If Empty( cMensagem )
			SEND MAIL FROM AllTrim(cUserEmail) TO AllTrim(cPara) SUBJECT cAssunto BODY MemoRead(cFile)  ATTACHMENT "\"+CURDIR()+cFile RESULT lResult
		Else
			SEND MAIL FROM AllTrim(cUserEmail) TO AllTrim(cPara) SUBJECT cAssunto BODY cMensagem        ATTACHMENT "\"+CURDIR()+cFile RESULT lResult
		EndIf
		if !lResult
			GET MAIL ERROR cLog
			cLog2 += "erro no enviando:" + cLog + CRLF
		end
		DISCONNECT SMTP SERVER
	Else
		GET MAIL ERROR cLog
		cLog2 += "erro na conexao:" + cLog + CRLF
	EndIf
	if lMostraDebug .and. !Empty(cLog2) .and. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|"
		msgstop(cLog2)
	end
end
Return lResult


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function contames(dMesDe, dMesAte)
Local nMeses := 1
Local AnoMesde := strzero(year(dMesDe),4) + strzero(month(dMesDe),2)
Local AnoMesAte := strzero(year(dMesAte),4) + strzero(month(dMesAte),2)
//fElapTime()
While AnoMesde < AnoMesAte
	nMeses++
	if substr(AnoMesde,5,2) < "12"
		AnoMesde := soma1(AnoMesde)
	else
		AnoMesde := soma1(substr(AnoMesde,1,4)) + "01"
	end
end
Return nMeses

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetAnArea( cAnalista, dData )  //ADF->ADF_CODSU7
Local cArea := ""
Local nArea

//fElapTime()

If ":" $ cAnalista
	cAnalista := SubStr( cAnalista, 1, at(":",cAnalista) - 1 )
EndIf

nArea := ascan( aAreaAn, {|x| AllTrim( cAnalista ) == x[2] .and. dData >= x[3] .and. dData <= x[4] } )
If ( nArea >  0 )
	cArea := aAreaAn[ nArea, 1 ]
EndIf

Return cArea


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  01/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetCliOk( cCliente, dData, nFaixa )
Local	lOk			:= .T.

Default	cCliente	:= ""
Default	dData		:= CToD("")
Default	nFaixa		:= ""
//fElapTime()
if nFaixa == "1" .AND. ascan( aCliFx1,{|x| alltrim(cCliente) == x[1] } )  >  0
	lOk := ascan( aCliFx1,{|x| alltrim(cCliente) == x[1] .and. dData >= x[2] .and. dData <= x[3]} )  >  0
elseif nFaixa == "2" .AND. ascan( aCliFx2,{|x| alltrim(cCliente) == x[1] } )  >  0
	lOk := ascan(aCliFx2,{|x| alltrim(cCliente) == x[1] .and. dData >= x[2] .and. dData <= x[3] } )  >  0
elseif nFaixa == "3" .AND. ascan( aCliFx3,{|x| alltrim(cCliente) == x[1] } )  >  0
	lOk := ascan(aCliFx3,{|x| alltrim(cCliente) == x[1] .and. dData >= x[2] .and. dData <= x[3] } )  >  0
elseif nFaixa == "4" .AND. ascan( aCliFx4,{|x| alltrim(cCliente) == x[1] } )  >  0
	lOk := ascan(aCliFx4,{|x| alltrim(cCliente) == x[1] .and. dData >= x[2] .and. dData <= x[3] } )  >  0	
end

return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function MontaAnalista()
Local x
Local cMemo := ""
Local lOk := .f.
//fElapTime()
if file(cFileConfig)
	cMemo := MemoRead(cFileConfig)
end
/*
if file(cLocalConfig) .and. msgyesno("Carregar Arquivo Local de configura็ใo?")
	cMemo := MemoRead(cLocalConfig)
end
*/

DEFINE MSDIALOG oDlg FROM 0,0 TO oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 TITLE "Configura็๕es" PIXEL
@ 0, 0  get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 MEMO HSCROLL pixel
//oGet:lWordWrap := .T.
NlINHA := (oDlg:nClientHeight/2)-35
nColuna := 10
@ NlINHA,nColuna BUTTON "Salvar" SIZE 50,10 Pixel ACTION ( lOk := .t., ODLG:end() )
@ NlINHA,nColuna+= 60 BUTTON "Cancela" SIZE 50,10 Pixel ACTION ( ODLG:end() )

ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
if lOk
	memowrit(cFileConfig,cMemo)
	if MsgYesno("Salvar copia de configura็ใo Local?")
		memowrit(cLocalConfig,cMemo)
	end
	T_PRIVATES := {}	
	CarregaArea(cFileConfig)
end
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CarregaArea( cFile, aCSV )
Local bError	:= ErrorBlock( { |o| trataerro(o) } )
Local aAux		:= {}	// Matriz Auxiliar de Totalizacao
Local aTMP		:= {}	// Matriz Temporaria
Local i			:= 0	// Contador / Indice de array

//fElapTime()

If cFile == cFileConfig
	aCliFx1 := {}
	aCliFx2 := {}
	aCliFx3 := {}
	aCliFx4 := {}
EndIf

If cFile == cFileAcesso
	aAreas	:= {}
	aAreaAn	:= {}
EndIf

Begin Sequence

If File( cFile )
	__CopyFile( cFile , cFileTmp )

	//	sleep(100)
	// erros de muitos acessos ao arquivo
	ft_FUse( cFileTmp )

	While !ft_feof()
		cLinha := ft_FReadLn()

		If ValType( aCSV ) == "A"
			If SubStr( cLinha, Len( cLinha ), 1 ) == ";"
				cLinha := SubStr( cLinha, 1, Len( cLinha ) - 1 )
			EndIf

			aTMP := StrToArra2( cLinha, ";" )

			AAdd( aCSV, aTMP )
			If "_SIT" $ aTMP[2]
				nPos := AScan( aAux, {|e| e[3] == aTMP[3] } ) 
				If nPos > 0
					For i:= 4 To Len( aTMP )
						If Type( aTMP[i] ) == 'N'
							aAux[nPos][i] := AllTrim( Str( Val( aAux[nPos][i] ) + Val( aTMP[i] ) ) )
						EndIf
					Next i
				Else
					AADD( aAux, AClone( aTMP ) )
				EndIf
			EndIf
			aTMP := {}
		
		ElseIf SubStr( cLinha, 1, 2 ) <> "//" .AND. !Empty( cLinha )
			cLinhaVar	:= SubStr( cLinha, 1, at( "=", cLinha ) - 1 )
			cValor		:= SubStr( cLinha, at( "=", cLinha ) + 1 )
			cLinhaVar	:= AllTrim( cLinhaVar )
			
			// Tenho no parametro
			If upper(substr(cLinhaVar,1,10)) == "T_PRIVATES"
				aadd(T_Privates, strtoarra2(cValor,",",""))
			ElseIf UPPER(substr(cLinhaVar,1,5)) == "AREA_"
				cArea := substr(cLinha,6,at("=",cLinha)-6)
				if ( nPosArea := ascan(aareas, {|x| x[1] == substr(cLinha,6,at("=",cLinha)-6) } ) ) == 0
					//AREA_FRAME_1E2=TI3475,01/01/2009,31/12/2049,HEITOR
					//aAreaAn { {"FRAME_1E2","TI3475",01/01/2009,31/12/2049,"HEITOR" } }
					aadd(aareas,{;
					cArea ,;
					strtoarray( substr(cLinha,at("=",cLinha) + 1) ,",")[2] + ";" } )
				else
					aareas[nPosArea,2] += strtoarray( substr(cLinha,at("=",cLinha) + 1) ,",",cArea)[2]  + ";"
				end
				aadd(aAreaAn, strtoarray( substr(cLinha,at("=",cLinha) + 1), ",",cArea) )
				aAreaAn[len(aAreaAn),3] := ctod( aAreaAn[len(aAreaAn),3] )
				aAreaAn[len(aAreaAn),4] := ctod( aAreaAn[len(aAreaAn),4] )
				
			elseif upper(substr(cLinhaVar,1,9)) == "EXCECAOFX"
				cFaixa := substr(cLinhaVar,10,1) //michel
				//ExcecaoFx2=T1466700,01/01/2000,31/12/2011,RAMOS
				If		cFaixa == "1"
					aadd(aCliFx1, StrToArra2( substr(cLinha,at("=",cLinha) + 1) ,",") )
					
					aCliFx1[len(aCliFx1),2] := ctod( aCliFx1[len(aCliFx1),2] )
					aCliFx1[len(aCliFx1),3] := ctod( aCliFx1[len(aCliFx1),3] )
					
				ElseIf	cFaixa == "2"
					aadd(aCliFx2, strtoarra2( substr(cLinha,at("=",cLinha) + 1) ,",") )
					
					aCliFx2[len(aCliFx2),2] := ctod( aCliFx2[len(aCliFx2),2] )
					aCliFx2[len(aCliFx2),3] := ctod( aCliFx2[len(aCliFx2),3] )
					
				ElseIf	cFaixa == "3"
					aadd(aCliFx3, strtoarra2( substr(cLinha,at("=",cLinha) + 1) ,",") )
					
					aCliFx3[len(aCliFx3),2] := ctod( aCliFx3[len(aCliFx3),2] )
					aCliFx3[len(aCliFx3),3] := ctod( aCliFx3[len(aCliFx3),3] )
					
				elseIf	cFaixa == "4"
					aadd(aCliFx4, strtoarra2( substr(cLinha,at("=",cLinha) + 1) ,",") )
					
					aCliFx4[len(aCliFx4),2] := ctod( aCliFx4[len(aCliFx4),2] )
					aCliFx4[len(aCliFx4),3] := ctod( aCliFx4[len(aCliFx4),3] )
					
				EndIf
				
			ElseIf Upper( SubStr(cLinhaVar,1,4) ) == "SPR"	// Set of Points of Restoration
				aPointRest := StrToArra2( SubStr( cLinha, At( "=", cLinha ) + 1 ) )
			Else
				if "-" $ cLinhaVar
					cLinhaVar := StrTran( cLinhaVar, "-", "_" )
				end
				If cValor $ ".t./.T./.f./.F."
					&(cLinhaVar) := ( cValor $ ".t./.T." )
				Else
					&(cLinhaVar) := cValor
				end
			EndIf
		EndIf
		
		ft_FSkip( )
		
	EndDo

	If ValType( aCSV ) == "A" .and. !Empty( aAux )
		AEval( aAux, {|e| e[2] := "PROCESSOS SLA"} )
		For i := 1 To Len( aAux )
			AAdd( aCSV, aAux[i] )
		Next i
	EndIf

EndIf

ft_FUse()

End Sequence

ErrorBlock( bError )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function validarotina( cRotina )
//fElapTime()
cRotina := alltrim(cRotina)
if cRotina  $  "ROTINA,CUSTOMIZ,ESPECIF, A DEFINIR, RDMAKE"
	cRotina := "CUSTOMIZ"
end
if "ASP-" $ cRotina
	cRotina := "ASP-DATACENTER"
end
return cRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetOpera( cOpera )
Local cAreaValida := ""
local cDiv := ""
//fElapTime()
If !Empty( cOpera )
	cDiv := " : "
EndIf

If	!Empty(ADF->ADF_CODSU7) .AND.;
	ALLTRIM( ADF->ADF_CODSU7 ) <> "AUTO" .AND.;
	ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
	
	cAreaValida := RetAnArea( ALLTRIM( ADF->ADF_CODSU7 ),ADF->ADF_DATA )
	
	If  !ALLTRIM( ADF->ADF_CODSU7 ) $ cOpera
		cOpera += cDiv + ALLTRIM( ADF->ADF_CODSU7 )
	EndIf
	
	If !Empty(cAreaValida)
		cAreaAnalista	:= cAreaValida
	EndIf
	
	If	Empty(cRetOperaSla) .and.;
		!Empty( RetAnArea(ADF->ADF_CODSU7,ADF->ADF_DATA) )
		If ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
			cRetOperaSla := RetNomeOpera(ALLTRIM( ADF->ADF_CODSU7 ))
		EndIf
	EndIf
	
EndIf

If	!Empty(ADENEW->ADE_OPERAD) .AND.;
	ALLTRIM(ADENEW->ADE_OPERAD) <> "AUTO" .AND.;
	ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
	
	If  !ALLTRIM( ADENEW->ADE_OPERAD ) $ cOpera
		cOpera += cDiv + ALLTRIM( ADENEW->ADE_OPERAD )
	EndIf
	
	cAreaValida := RetAnArea( ALLTRIM( ADENEW->ADE_OPERAD ),ADENEW->ADE_DATA )
	
	If !Empty(cAreaValida)
		cAreaAnalista	:= cAreaValida
	EndIf
	
	If Empty(cRetOperaSla) .and.  !Empty( RetAnArea(ADENEW->ADE_OPERAD,ADENEW->ADE_DATA) )
		cRetOperaSla := RetNomeOpera(ALLTRIM( ADENEW->ADE_OPERAD ) )
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function RetNomeOpera(cOpera,lPosiciona,cOld)
Local cNomeOpera	:= ""
Local cCodOpera		:= ""
Local nPosBarra		:= 0

//fElapTime()

if empty(lPosiciona)
	While !Empty(cOpera)
		if ":" $ cOpera
			cCodOpera := substr(cOpera,1,at(" : ",cOpera)-1 )
			cNomeOpera := PAD(upper(alltrim(myPosicione("SU7",1,MyXfilial("SU7")+cCodOpera,"U7_NOME"))), 15) + "/" + cNomeOpera
		else
			cCodOpera := cOpera
			cNomeOpera := upper(alltrim(myPosicione("SU7",1,MyXfilial("SU7")+cCodOpera,"U7_NOME"))) + "/"+ cNomeOpera
		end
		if ":" $ cOpera
			cOpera := strtran(cOpera,cCodOpera+" : ","")
		else
			cOpera := ""
		end
	end
	if (nPosBarra := rat("/",cNomeOpera) ) > 0
		cNomeOpera := substr(cNomeOpera,1,nPosBarra-1)
	end
else
	
	//OPCOES PARA PEGAR O ANALISTA PRIORIDADE
	//1 - LINHA DO CHAMADO
	//2 - O ANALISTA ANTERIOR
	//3 - ANALISTA ALOCADO NO CABEวALHO
	//RetAnArea(cAnalista,dData)
	if ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] //! empty( RetAnArea(cOpera,ADF->ADF_DATA) ) // o analista ้ valido  // == ADF->ADF_CODSU0 //
		cNomeOpera := upper(alltrim(myPosicione("SU7",1,MyXfilial("SU7")+cOpera,"U7_NOME")))
	end
	if empty(cNomeOpera) .and. !Empty(cOld)
		cNomeOpera := cOld
	end
	if empty(cNomeOpera)
		cNomeOpera := upper(alltrim(myPosicione("SU7",1,MyXfilial("SU7")+cAnalistaAloc,"U7_NOME")))
	end
end

Return cNomeOpera


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function validacampo(cNomeCol, cValor)
Local nSec2			:= 0
Local nSecParam		:= 0
Local cTempoAtende	:= ""
Local lFechado		:= .F.
Local cCritic		:= substr( retacols("CRITIC_CHM",,"1"), 1, 1 )
//fElapTime()
if cNomeCol == "FAIXA1_TP"
	lFechado := aTimeDif[1,6]
	cTempoAtende := GetCalcFxs( "TMP1ATDE" )
elseif cNomeCol == "FAIXA2_TP"
	lFechado := aTimeDif[2,6]
	if cCritic $ "5,4"
		cTempoAtende := GetCalcFxs( "F2_ALT_URG" )
	elseif cCritic $ "3"
		cTempoAtende := GetCalcFxs( "F2_MED" )
	elseif cCritic $ "2,1"
		cTempoAtende := GetCalcFxs( "F2_BAIXA" )
	end
elseif cNomeCol == "FAIXA3_TP"
	lFechado := aTimeDif[3,6]
	if cCritic $ "5,4"
		cTempoAtende := GetCalcFxs( "F3_ALT_URG" )
	elseif cCritic $ "3"
		cTempoAtende := GetCalcFxs( "F3_MED" )
	elseif cCritic $ "2"
		cTempoAtende := GetCalcFxs( "F3_BAIXA" )
	elseif cCritic $ "1"
		// fnc de melhoria nao conta tempo de SLA
		cValor := NOT_EXIST_SLA
	end
elseif cNomeCol == "FAIXA4_TP"
	lFechado := aTimeDif[4,6]
	if cCritic $ "5,4"
		cTempoAtende := GetCalcFxs( "F3_FSW_ALT_URG" )
	elseif cCritic $ "3"
		cTempoAtende := GetCalcFxs( "F3_FSW_MED" )
	elseif cCritic $ "2"
		cTempoAtende := GetCalcFxs( "F3_FSW_BAIXA" )
	elseif cCritic $ "1"
		// fnc de melhoria nao conta tempo de SLA
		cValor := NOT_EXIST_SLA
	end
end
if !Empty(cTempoAtende) .and. !Empty(cValor) .and. ! ( cValor $ OFF_TIME_SLA+ON_TIME_SLA+NOT_CONTRATO_SLA+NOT_EXIST_SLA+OUT_TIME_SLA+REJECT )
	if oChamado:ValidCliFaixa(cNomeCol) //ValidCliFaixa(retacols("CODCLI",,""),cNomeCol)
		nSec2 := timetosec( cValor )
		nSecParam := timetosec( cTempoAtende ) 
        
		if cValor == "0000:00:00"
			cValor := OUT_TIME_SLA
		elseif nSec2 <= nSecParam
			cValor := "ATE " + cTempoAtende +"H"// "ATE 9999:99:99H"
			if  (!lFechado .or. (ADENEW->ADE__ENTPE == "70" .and. cNomeCol=="FAIXA2_TP" .and. EMPTY(aTimeDif[3,1]))) .and. ADENEW->ADE__ENTPE<>"50"
				cValor := TIME_TO_END
			end
		else
			cValor := "ACIMA DE " +cTempoAtende + "H"
		end		
	else
		cValor := NOT_CONTRATO_SLA
	end
	
elseif cNomeCol == "FNC"
	cValor2		:= cValor
	cCateg		:= substr(retacols("FNCCATEG",,""),1,6)
	cFncAssoc	:= retacols("FNCASSOC")
	cValor := "NรO GEROU FNC"

	If !empty(cValor2)       
		If substr( retacols("CRITIC_CHM",,"1"), 1, 1 ) == "1"		
			IF cCateg == "CAT017"
				cValor := "GEROU FNC (LEGISLAวรO)-CAT017"
			Else 
				cValor := "GEROU FNC (MELHORIA)"
			EndIf
		Else
			cValor := "GEROU FNC (NC)"
		End
	End

	IF retacols("FNCREJE") == "S" .and. EMPTY(cFncAssoc)
		If substr( retacols("CRITIC_CHM",,"1"), 1, 1 )== "1"		
			IF cCateg == "CAT017"
				cValor := "REJEITOU FNC (LEGISLAวรO)-CAT017"
			Else
				cValor := "REJEITOU FNC(MELHORIA)"
			EndIf
		Else
			cValor := "REJEITOU FNC (NC)"
		EndIf
	EndIf

	If !empty(cValor2) .and. ! EMPTY(cFncAssoc)
		cValor := "FNC ASSOCIADA"
    END

    if !empty(cValor2) .and. ! oChamado:lFaixa1//ValidCliFaixa(retacols("CODCLI",,""),"FAIXA1_TP")
	    cValor := "SEM-SLA" //NOT_CONTRATO_SLA
    end

elseif  cNomeCol == "PRODUCAO"
	cValor := if( !Empty(cValor),"SIM","NAO" )
elseif  cNomeCol == "PRODUTIVID"
	cValor := if( !Empty(cValor),"SIM","NAO" )

elseif  cNomeCol == "REABERTURAS"
	cValor := if( !Empty(cValor),"SIM","NAO" )	

elseif  cNomeCol == "REJEICOES"
	cValor := if( !Empty(cValor),"SIM","NAO" )	


elseif cNomeCol == "DT_SLOVENC"
	if val(cValor) > 0
		cValor := "FORA DO PRAZO"
	else
		cValor := "NO PRAZO"
	end
elseif cNomeCol == "FAIXA2_TPC"	
	cValor := timetosec( cValor ) 
	if EMPTY(cValor)
		cValor := "NAO-EXISTE"
	else
		cValor := "EXISTE"
	end
end
if valtype(cValor) <> "C"
	cValor := alltochar(cValor)
end
Return cValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/26/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function agrupaitens()
Local aAgrupa := {}
Local x,Y
Local cCampo := ""
Local nPos := 0
Local cTexto := "OUTROS ("
local cTexto2 := ") INFERIOR A "
Local nPosCampo
Local nValReal := 0
Local cCampoOld := ""
//fElapTime()
private  aStruTmp := RetVetor()
//OUTROS (ACAO) INFERIOR ม 3
//nAgrupaItens
aCOLS := ASORT(aCOLS,,, { |x, y| x[1] + alltochar( 100000 - x[len(x)]    )  < Y[1] +alltochar( 100000 - y[len(y)] )})
for x := 1 to len(Acols)
	cCampo := Acols[x,1]
	nPosCampo := ascan( aStruTmp, {|x| x[1] == cCampo} )
	IF ValidTp(lMostraSoma,Acols[x])
		IF "+" $ cCampo .or. ( nPosCampo > 0 .AND. aStruTmp[nPosCampo,10] )
			if cCampoOld <> cCampo
				nValReal := ( Acols[x,len(Acols[x])]  * nAgrupaItens ) / 100
				cCampoOld := cCampo
			end
			if Acols[x,len(Acols[x])] > nValReal
				aadd(aAgrupa,ACLONE(Acols[x]))
			else
				if ( nPos := ascan(aAgrupa, { |y| y[2]  ==  cTexto + Acols[x,1] +cTexto2  + " " + ALLTRIM(alltochar(nValReal) ) } ) ) > 0
					FOR Y := 3 TO LEN(aAgrupa[nPos])
						aAgrupa[nPos, y  ] += Acols[x,y]
					NEXT
				else
					aadd( aAgrupa,Acols[x])
					aAgrupa[len(aAgrupa),2] := cTexto + Acols[x,1] +cTexto2  + " " + ALLTRIM( alltochar(nValReal) )
				end
			end
		ELSE
			aadd(aAgrupa,ACLONE(Acols[x]))
		END
	end
next
Acols := aAgrupa
aCOLS := ASORT(aCOLS,,, { |x, y| x[1] + alltochar( 100000 - x[len(x)]    )  < Y[1] +alltochar( 100000 - y[len(y)] )})
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/28/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function TotalDash(dDataIntera)
Local cNomeCol, lSoma
Local cValor
Local x := LEN(ACOLS)
lOCAL nMeses := contames( dDataOldAde, aFiltros[DATAATE] )
Local nMesAtu := contames(dDataOldAde, dDataIntera )
Local nMesInt
Local nPosAgrupa
Local cValor2
Local nValorSoma := 1
//fElapTime()
for nPosAgrupa := 1 to len( aCols[X] )
	nValorSoma := 1
	cNomeCol  := astrutMP[nPosAgrupa,1]
	cNomeCol2 := cNomeCol
	IF ! isitem( cNomeCol  ) //astrutMP[nPosAgrupa,8]
		cValor := aCols[x,nPosAgrupa]
		cValor2 := cValor		
		if "+" $ cNomeCol
			cNomeCol := substr(cNomeCol,1,at("+",cNomeCol)-1)
		end
		
		nMesAtu := contames(dDataOldAde, dDataIntera )
		
		IF cNomeCol $ "FAIXA1_NM,FAIXA2_NM,FAIXA3_NM,FAIXA4_NM,FAIXA1_TP,FAIXA2_TP,FAIXA3_TP,FAIXA4_TP,FAIXA1_SIT,FAIXA2_SIT,FAIXA3_SIT,FAIXA4_SIT" .and.  valtype( retacols("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",x)) == "C"
			nMesAtu := contames(dDataOldAde, CTOD(retacols("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",x)) )
		elseif cNomeCol == "FNC" .and. !EMPTY(cvalor)
			nMesAtu := contames(dDataOldAde, CTOD(retacols("FAIXA3_AB",x)) )
		else
			nMesAtu := contames(dDataOldAde, dDataIntera )
		END
		cValor := validacampo(cNomeCol,cValor)
		lSoma := .T.
		if lSoma
			
			IF cNomeCol $ "FAIXA1_NM,FAIXA2_NM,FAIXA3_NM,FAIXA4_NM,FAIXA1_TP,FAIXA2_TP,FAIXA3_TP,FAIXA4_TP,FAIXA1_SIT,FAIXA2_SIT,FAIXA3_SIT,FAIXA4_SIT" .and.  valtype( retacols("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",x)) == "C"
				nMesAtu := contames(dDataOldAde, CTOD(retacols("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",x)) )
				IF !EMPTY(retacols(cNomeCol,x))
					if CTOD(retacols("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",x))  < aFiltros[DATADE]    .OR.  CTOD(retacols("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",x))  > aFiltros[DATAATE]
						lSoma := .F.
					END
				else
					lSoma := .F.
				END
			END
			if lSoma ;
				.and. cNomeCol $ "FAIXA3_SIT,FAIXA3_TP" ;
				.and. !Empty(retacols("FNCASSOC"))
				
				lSoma := .F.
			END
			
			if lSoma .and. "_TPM" $ cNomeCol
				nValorSoma := val(cValor)
				cValor := "TOTAL"
			end
			if lSoma .and. cNomeCol == "FNC" .and. cvalor <> "NรO GEROU FNC"
				if CTOD(retacols("FAIXA3_AB",x))  < aFiltros[DATADE] .or. CTOD(retacols("FAIXA3_AB",x))  > aFiltros[DATAATE]
					lSoma := .F.
				END
			END
			
			if lSoma .and. cNomeCol == "FNC" .and. cvalor == "NรO GEROU FNC"
				IF !EMPTY(retacols(cNomeCol,x))
					
					if CTOD(retacols("FAIXA1_DT",x))  < aFiltros[DATADE] .or. CTOD(retacols("FAIXA1_DT",x))  > aFiltros[DATAATE]
						lSoma := .F.
					END
				END
			END
			
			if cNomeCol $ "PRODUCAO/PRODUTIVID/REABERTURAS/REJEICOES"
				if "NAO" $ cValor
					lSoma := .F.
				end
			END
			if cNomeCol $ "ANA_UNICO"
				if empty(cValor) .or. CTOD(retacols("DATA_ATENDE",x))  < aFiltros[DATADE] .or. CTOD(retacols("DATA_ATENDE",x))  > aFiltros[DATAATE]
					lSoma := .F.
				end
			END
		end
		if cNomeCol <> cNomeCol2
			cNomeCol := cNomeCol2
			cValor := cValor2
		end
		if lSoma
			if !Empty(astrutMP[nPosAgrupa,7])
				if (nSomaOk := ascan( aMultQ, {|Y| Y[2] == cValor .and. y[1] == cNomeCol } )) > 0
					if nMesAtu+2 <= len( aMultQ[nSomaOk] )
						aMultQ[nSomaOk,nMesAtu + 2] += nValorSoma
					else
						aMultQ[nSomaOk, len( aMultQ[nSomaOk] )-1 ] += nValorSoma
					end
					aMultQ[nSomaOk, len( aMultQ[nSomaOk] ) ] += nValorSoma
				else
					aadd(aMultQ,{})
					asize(aMultQ[len(aMultQ)] , nMeses + 3 )
					afill(aMultQ[len(aMultQ)] ,0)
					
					aMultQ[len(aMultQ),1] := cNomeCol
					aMultQ[len(aMultQ),2] := cValor
					IF nMesAtu <= nMeses
						aMultQ[len(aMultQ),nMesAtu + 2] := nValorSoma
					ELSE
						aMultQ[len(aMultQ),len(aMultQ[len(aMultQ)])-1 ] := nValorSoma
					END
					aMultQ[len(aMultQ),len(aMultQ[len(aMultQ)]) ] += nValorSoma
				end
			end
		end
	end
next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/30/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function myhelp()
Local x
Local cMemo := ""
Local lOk := .f.
//fElapTime()
if file(cPathCubosAC+"helpsim.txt")
	cMemo := memoread(cPathCubosAC+"helpsim.txt")
end

@ 0, 0  get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 MEMO HSCROLL pixel
NlINHA := (oDlg:nClientHeight/2)-35
nColuna := 10
if lMUsers
	@ NlINHA,nColuna BUTTON "Salvar" SIZE 50,10 Pixel ACTION ( memowrit(cPathCubosAC+"helpsim.txt",cMemo), ODLG:end() )
	nColuna+= 60
else
	oGet:lreadonly := .T.
end
@ NlINHA,nColuna BUTTON "Fechar" SIZE 50,10 Pixel ACTION ( ODLG:end() )
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/30/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaTotais( lAuto )
//fElapTime( )
nLinha	:= 0

If Empty( lAuto )
	@ ++nLinha,1  SAY "Configura็๕es para exporta็ใo para o excel"		Pixel
	@ ++nLinha,1  SAY "Indique a porcentagem para agrupar"				Pixel
	@   nLinha,2  msget nAgrupaItens picture "999" size 50,11			Pixel

	lAgrupaTotais := .T.

	@ ++nLinha,1  CHECKBOX lAgrupaTotais PROMPT "Agrupa valores fora do periodo?" SIZE 100,11 Pixel
	@ ++nLinha,1  	BUTTON "OK"			SIZE 40,11 Pixel ACTION ( lConfirma := .T., oDlg:end( ) )
	@   nLinha,2  	BUTTON "CANCELA"	SIZE 40,11 Pixel ACTION ( oDlg:end( ) )
	@ ++nLinha,3  SAY "" Pixel
Else
	nAgrupaItens	:= 0
	lAgrupaTotais	:= .T.
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AtivaMonitor(oTimer,oButMonit)
//fElapTime()
if ! oTimer1:lactive
	if myEmails(,.t.)
		oTimer1:activate()
		oButMonit:settext("Des. monitor")
	end
else
	oTimer1:DeActivate()
	oDlgMain:settext("envio de email desativado")
	oButMonit:settext("Ativar monitor")
end
oButMonit:refresh()
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function myMSGRUN(cTexto,uReserv,bAction)
//fElapTime()
Private oMsg,oMySay
if type("oMainWnd") == "O"
	DEFINE MSDIALOG oMsg TITLE cTexto FROM 0,0 TO 280,( oMainWnd:nClientWidth/2)+100 OF oMainWnd PIXEL
	
	@ 1,1 SAY oMySay PROMPT pad(cTexto,1000)  PIXEL
	
	oMySay:Align := CONTROL_ALIGN_ALLCLIENT
	oMySay:lWordWrap := .T.
	ACTIVATE MSDIALOG oMsg  Centered On Init ( EVAL(bAction), oMsg:end() )
else
	EVAL(bAction)
end
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function myText(cText)

Static loMySay

if .f.
	// desativar funcao
	myText(cText)
end

IF loMySay == Nil
	loMySay := ( TYPE("oMySay") <> "U" )
Endif

If loMySay
	oMySay:settext(alltochar(cText))
	sysrefresh()
EndIf

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
funcao onde vai validar se deve ser contados os chamados em branco ou nao
caso lMostraSoma .t. os campos em branco nao serao mostrados.
*/
static function ValidTp(lMostraSoma,Acols)
Local lOk := .T.
//fElapTime()
if lMostraSoma
	cCampo := Acols[1]
	cValor := Acols[2]
	if "+" $ cCampo .and. ("FAIXA1_TP" $ cCampo .or. "FNC" $ cCampo .or. "FAIXA2_TP" $ cCampo .or. "FAIXA3_TP" $ cCampo .or. "FAIXA4_TP" $ cCampo)
		lOk :=  "ACIMA DE" $ cValor .or. "GEROU" $ cValor
	end
end
return lOk



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/23/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function nToTime(nSeconds)
Local cTime := ""
Local nValTmp := 0
//fElapTime()
if nSeconds <> NIL .and. nSeconds >= 0 // se nao eh negativo
	nValTmp := int( nSeconds / 3600 )
	cTime+= strzero(nValTmp,4)+ ":"// achei as horas
	nSeconds -= ( nValTmp * 3600 )
	nValTmp := int( nSeconds/ 60 )
	cTime += strzero(nValTmp,2) + ":"
	nSeconds-= ( nValTmp * 60 )
	cTime += strzero(nSeconds,2)
end
return cTime
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/25/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function myposicione(cAlias,nOrdem,cChave,cCampo,lAchou)

Local nPos := 0
Local uValor := ""
Local nRec := 0
//fElapTime()
// {cAlias+cChave,uValor}
lAchou := .F.
if empty(cCampo)
	cCampo := ""
end
if empty( nPos := aScan(aCache,{|x| x[1] == cAlias+cChave +cCampo} ) )
	if !Empty(cCampo)
		nRec := (cAlias)->(recno())
		(cAlias)->(dbsetorder(nOrdem))
		if ( lAchou := (cAlias)->(dbseek(cChave) ) )
			uValor := (cAlias)->(&(cCampo))
						// "SA1"+"0101010"+"A1_CODBCS"
			aadd(aCache,{cAlias+cChave+Ccampo,uValor,lAchou} )
			nCache++
		else
			aadd(aCache,{cAlias+cChave+Ccampo,cChave,lAchou} )
			uValor := cChave
		end
		(cAlias)->(dbgoto(nRec))
	else
		nRec := SX5->(recno())
		if ( lAchou := SX5->( DbSeek( myxfilial("SX5")+cAlias +cChave) ) )
			uValor := SX5->X5_DESCRI
			aadd(aCache,{cAlias+cChave+cCampo,uValor,lAchou} )
			nCache++			
		else
			aadd(aCache,{cAlias+cChave+cCampo,cChave,lAchou} )
			uValor := cChave
		end
		SX5->(dbgoto(nRec))
	end
else
	nAcerto++
	uValor := aCache[nPos,2]
	lAchou := aCache[nPos,3]
end
Return uValor

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/25/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyXFilial(cAlias)
Static aCachFil := {}
Local nPos := 0
Local uValor := ""
// {cAlias+cChave,uValor}
//
//fElapTime()
If empty(cAlias)
	cAlias := Alias()
End
If Empty( nPos := aScan(aCachFil,{|x| x[1] == cAlias + "XFILIAL"} ) )
	uValor := xFilial(cAlias)
	aadd(aCachFil,{cAlias + "XFILIAL",uValor} )
Else
	nAcerto++
	uValor := aCachFil[nPos,2]
End
Return uValor
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function SomaAdf(dDataDia)
Local cNomeCol
Local cValor
Local x := LEN(ACOLSx)
lOCAL nMeses := contames( dDataOldAde, aFiltros[DATAATE] )
Local nMesAtu := contames(dDataOldAde, dDataDia )
Local nMesInt
Local nPosAgrupa
Local nValorSoma := 1
Local cValor2
Local z
//fElapTime()
for z := 1 to x
	for nPosAgrupa := 1 to len( aColsx[z] )
		nValorSoma := 1
		MyText("Agrupando informa็๕es coluna:" + alltochar(nPosAgrupa) )
		cNomeCol  := astrutMP[nPosAgrupa,1]
		cNomeCol2 := cNomeCol
		IF isitem( cNomeCol ) //astrutMP[nPosAgrupa,8]
			cValor := aColsx[z,nPosAgrupa]
			cValor2 := cvalor
			if "+" $ cNomeCol
				cNomeCol := substr(cNomeCol,1,at("+",cNomeCol)-1)
			end

			
			dDataDia := CTOD ( retacolsX("DATA_ATENDE",z) )
			
			IF cNomeCol $ "FAIXA1_NM,FAIXA2_NM,FAIXA3_NM,FAIXA4_NM,FAIXA1_TP,FAIXA2_TP,FAIXA3_TP,FAIXA4_TP,FAIXA1_SIT,FAIXA2_SIT,FAIXA3_SIT,FAIXA4_SIT" .and.  valtype( retacolsx("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",z)) == "C"
				nMesAtu := contames(dDataOldAde, CTOD(retacolsx("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",z)) )
			elseif cNomeCol == "FNC"  .and. !EMPTY(cvalor)
				nMesAtu := contames(dDataOldAde, CTOD(retacolsx("FAIXA3_AB",z)) )
			else
				nMesAtu := contames(dDataOldAde, dDataDia )
			END
			cValor := validacampo(cNomeCol,cValor)
			lSoma := .T.
			
			IF cNomeCol $ "FAIXA1_NM,FAIXA2_NM,FAIXA3_NM,FAIXA4_NM,FAIXA1_TP,FAIXA2_TP,FAIXA3_TP,FAIXA4_TP,FAIXA1_SIT,FAIXA2_SIT,FAIXA3_SIT,FAIXA4_SIT"  .and.  valtype( retacolsX("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",z)) == "C"
				nMesAtu := contames(dDataOldAde, CTOD(retacolsX("FAIXA" + SUBSTR(cNomeCol,6,1) +"_DTL",z)) )
				IF !EMPTY(retacolsx(cNomeCol,z))
					IF  (  (  CTOD(retacolsx("FAIXA" + SUBSTR(cNomeCol,6,1) + "_DTL",z))  < aFiltros[DATADE]    .OR.  CTOD(retacolsx("FAIXA" + SUBSTR(cNomeCol,6,1) + "_DTL",z))  > aFiltros[DATAATE] )   )
						lSoma := .F.
					END
				else
					lSoma := .F.
				END
			end
			
			if lSoma .and. cNomeCol $ "FAIXA3_SIT,FAIXA3_TP" .and. !Empty(retacolsx("FNCASSOC",z))
				lSoma := .F.
			END
			if lSoma .and. cNomeCol == "FNC"  .and. cvalor <> "NรO GEROU FNC"
				if CTOD(retacolsx("FAIXA3_AB",z))  < aFiltros[DATADE] .or. CTOD(retacolsx("FAIXA3_AB",z))  > aFiltros[DATAATE]
					lSoma := .F.
				END
			END
			if lSoma .and. cNomeCol == "FNC"  .and. cvalor == "NรO GEROU FNC"
				if CTOD(retacolsx("FAIXA1_DT",z))  < aFiltros[DATADE] .or. CTOD(retacolsx("FAIXA1_DT",z))  > aFiltros[DATAATE]
					lSoma := .F.
				END
			END
			
			if lSoma ;
				.and. cNomeCol $ "FAIXA3_SIT,FAIXA3_TP" ;
				.and. !Empty(retacolsx("FNCASSOC",z))
				
				lSoma := .F.
			END
			
			
			if cNomeCol $ "PRODUCAO/PRODUTIVID/REABERTURAS/REJEICOES"
				if "NAO" $ cValor
					lSoma := .F.
				end
			END

			if cNomeCol $ "ANA_UNICO"
				if empty(cValor) .or. CTOD(retacolsx("DATA_ATENDE",x))  < aFiltros[DATADE] .or. CTOD(retacolsx("DATA_ATENDE",x))  > aFiltros[DATAATE]
					lSoma := .F.
				end
			END


			if lSoma .and. "_TPM" $ cNomeCol
				nValorSoma := val(cValor)
				cValor := "TOTAL"
			end
			if cNomeCol <> cNomeCol2
				cNomeCol := cNomeCol2
				cValor := cValor2
			end
			if lSoma
				if !Empty(astrutMP[nPosAgrupa,7])
					if (nSomaOk := ascan( aMultQ, {|Y| Y[2] == cValor .and. y[1] == cNomeCol } )) > 0
						/*ALTERADO A SOMA TOTAL DOS CHAMADOS - REMOVIDA A COLUNA ANTERIOR PARA AS LINHAS DOS CHAMADOS*/
						if nMesAtu+2 <= len( aMultQ[nSomaOk] )
							aMultQ[nSomaOk,nMesAtu + 2] += nValorSoma
							aMultQ[nSomaOk, len( aMultQ[nSomaOk] ) ] += nValorSoma
						end
					else
						aadd(aMultQ,{})
						asize(aMultQ[len(aMultQ)] , nMeses + 3 )
						afill(aMultQ[len(aMultQ)] ,0)
						
						aMultQ[len(aMultQ),1] := cNomeCol
						aMultQ[len(aMultQ),2] := cValor
						IF nMesAtu <= nMeses
							aMultQ[len(aMultQ),nMesAtu + 2] := nValorSoma
						END
						aMultQ[len(aMultQ),len(aMultQ[len(aMultQ)]) ] += nValorSoma
					end
				end
			end
		end
	next
next
Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function acolsvirtual()
//fElapTime()
addblankX()

ADDValorX("ACAO",ADF->ADF_CODSUQ +"-" + ALLTRIM(myPosicione("SUQ",1,myxfilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC")))
ADDValorX("OCORRE",ADF->ADF_CODSU9 +"-" + ALLTRIM(myPosicione("SU9",2,myxfilial("SU9")+ADF->ADF_CODSU9,"U9_DESC")))

ADDValorX("CRITIC_CHM",legenda(ADENEW->ADE_SEVCOD,"SEVCOD"))

ADDValorX("DT_ULT_MOV", dUltDtMov )
ADDValorX("H_ULT_MOV",cUltHrMov)
cCodCausa := cEmBranco

if empty(cAreaAnalista)
	cAreaAnalista := cEmBranco
end
ADDValorX("AN_AREA",cAreaAnalista)

ADDValorX("AN_NOMES",upper(alltrim(myPosicione("SU7",1,MyXfilial("SU7")+ADF->ADF_CODSU7,"U7_NOME"))) )

ADDValorX("AN_CODS",ADF->ADF_CODSU7)
if empty(cRetOperaSla)
	cRetOperaSla := cEmBranco
end

ADDValorX("PRODUCAO",lProducao)
ADDValorX("PRODUTIVID",lProdutivo)
/*CRIACAO DOS NOVOS CAMPOS*/
ADDValorX("DATA_ATENDE",ADF->ADF_DATA)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function addvalorX(cCampo,uValor,nLinha)
local nPos
//fElapTime()
If empty(nLinha)
	nLinha := len(acolsX)
end

if (nPos := ascan(aStruTmp,{|x|x[1] == cCampo} )) >0 .and. nLinha > 0 .and. nPos <= len( acolsX[nLinha] )
	if valtype(uValor) == "D"
		uValor := alltochar(uValor)
	end
	IF nLinha > 0
		acolsX[nLinha,nPos] := uValor
	END
else
	if lMostraDebug .and. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|" .and. ! ( cCampo $ cCpoMostra)
		msgstop("Erro ao adicionar o campox " + alltochar(cCampo) + " - Valor : " + alltochar(uValor) )
		cCpoMostra += cCampo
	end
end
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPRCA690   บAutor  ณMicrosiga           บ Data ณ  10/23/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function addblankX()
Local x
//fElapTime()
aadd(acolsX,{})
for x := 1 to len(aStruTmp)
	if aStruTmp[x,2] == "C"
		aadd(acolsX[len(acolsX)],space(aStruTmp[x,3]))
	elseif aStruTmp[x,2] == "N"
		aadd(acolsX[len(acolsX)],0)
	elseif aStruTmp[x,2] == "D"
		aadd(acolsX[len(acolsX)],stod(""))
	end
next

return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CampoItem()
//fElapTime()
Return "TXT_TRUE/ACAO/OCORRE/D_TULT_MOV/H_ULT_MOV/AN_NOMES/AN_CODS/PRODUCAO/PRODUTIVID/TEMPOFAT/REABERTURAS/REJEICOES/DATA_ATENDE/ANA_VALID_FAIXA/ANA_UNICO"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/13/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function retacolsX(cCampo,nLinha,uDef)
local nPos
// michel
//fElapTime()
if ( nPos := ascan(aStruTmp,{|x|x[1] == cCampo} )) >0
	if empty(nLinha)
		nLinha := len(aColsX)
	end
	uDef  := acolsX[nlinha,npos]
else
	if lMostraDebug .and. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|" .and. ! ( cCampo $ cCpoMostra )
		msgstop("Erro ao retornar o campo " + alltochar(cCampo) + " - Valor : " + alltochar(uValor) )
		cCpoMostra += cCampo
	end	
end
return uDef
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function criaacols()
Local nColuna := 0
Local aCampo := {}
Local lAcolsX := .T.
Local lValido := .T.
Local aSomaCols := {}
Local nCols
Local x
Local cValor := ""
// EXECUTAR A SUPER COLUNA
//fElapTime()
for nColuna := 1 to len(aStruTmp)
	cCampo := aStruTmp[nColuna,1]
	if isitem( cCampo )
		aStruTmp[nColuna,8] := .t.
	END

	if "+" $ cCampo
		cValor := ""
		aSomaCols := {}
		
		While !Empty(cCampo)
			if 	"+" $ cCampo
				cCampoOk := substr(cCampo,1,at("+",cCampo)-1)
			ELSE
				cCampoOk := cCampo
			END
			if isitem( cCampoOk )
				aCampo := criaacolsx(cCampoOk)
				aStruTmp[nColuna,8] := .t.
				if Empty(cValor)
					if empty(aSomaCols)
						for nCols := 1 to len(aColsx)
							aadd(aSomaCols, "")
						next
					end
				else
					if empty(aSomaCols)
						for nCols := 1 to len(aColsx)
							aadd(aSomaCols, cValor  )
						next
					end
				end
				for nCols := 1 to len(aCampo)
					aSomaCols[nCols ] += aCampo[nCols] + ":"
				next
				if 	"+" $ cCampo
					cCampo := strtran(cCampo,substr( cCampo, 1, at("+",cCampo) ),"" )
				ELSE
					cCampo := ""
				end
				cValor := ""
			else
				if 	"+" $ cCampo
					cValorOld := retacols(cCampoOk, len(acols)  )
					cCampo := strtran(cCampo,substr( cCampo, 1, at("+",cCampo) ),"" )
				else
					cValorOld := retacols(cCampo, len(acols)  )
					cCampo := ""
				end
				cValor += ValidaCampo(cCampoOk,cValorOld)//verifico se ้ uma das colunas com edi็ใo e altero o texto dele
				if !Empty(cCampo)
					cValor += " : "
				end
			end
		end
		if lValido
			if !Empty(cValor)
				addValor(aStruTmp[nColuna,1],cValor)
/*
Quando eh combinado um campo de cabe็alho com cabe็alho 
ocorre erro na cria็ใo de linha por linha
*/
				if !Empty(aColsx)
					addValorx(aStruTmp[nColuna,1],cValor)
				end
			end
			if !Empty ( len(aSomaCols)  )
				for x := 1 to len(aSomaCols)
					addValorX(aStruTmp[nColuna,1],aSomaCols[x]+cValor,x)
				next
			end
		end
	end
next
Return lAcolsx
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function criaacolsx(cCampo)
Local aRet := {}
Local nValor := 0
Local cValor := ""
//fElapTime()
For nValor := 1 to len(aColsx)
	cValor := retacolsx(cCampo, nValor )
	cValor := ValidaCampo(cCampo,cValor)
	aadd(aRet,cValor)
next

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/14/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidSelect(aStru,cCampos)
Local x
//fElapTime()
for x := 1 to len(aStru)
	IF aStru[x,5] $ cCampos
		aStru[x,7] := .T.
	end
next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/30/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function myRanking()
Local x
Local cMemo := ""
Local lOk := .f.
//fElapTime()
if file(cRanking)
	cMemo := memoread(cRanking)
end
DEFINE MSDIALOG oDlg FROM 0,0 TO oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 TITLE "Ranking" PIXEL
@ 0, 0  get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 MEMO HSCROLL pixel
NlINHA := (oDlg:nClientHeight/2)-35
nColuna := 10
	oGet:lreadonly := .T.
@ NlINHA,nColuna BUTTON "Fechar" SIZE 50,10 Pixel ACTION ( ODLG:end() )
ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static function SomaRank()
Local nHand
Local nCount
//ti e usuario + tab + valor + chr(13) e chr(10)
Local cBuff := space(30 + 1 + 10 +2 )
//TI000000         000000
Local aFile := {}
//fElapTime()
cUser := cRealUser + " - " + upper(pad( myPOSICIONE("SU7",1,myxfilial("SU7")+cRealUser,"U7_NOME"),30))
if !file(cRanking)
	fclose(fCreate(cRanking))
end
__copyfile(cRanking,cFileTmp)
ft_fuse(cFileTmp)

While !Ft_feof()
	cBuff := ft_freadln()
	aadd(aFile, { cBuff,val (  substr(cbuff,at(chr(9),cBuff ),11  ) ) }  )
	ft_fskip()
end

ft_fuse()

lFound := .F.
nCount := 1
While !lFound
	
	if nCount > len(aFile)
		cBuff := cUser + chr(9) + chr(9) + alltochar(1)  + chr(9) + " Ultm Exec " + Time() + " - " + dtoc(date())
		aadd(aFile,{ cBuff , 1 } )
		lFound := .t.
	end
	cBuff := aFile[nCount,1]
	if !lFound .and. substr(cBuff,1,len(cUser)) == cUser
		cBuff := cUser +chr(9) + chr(9) + TRANSFORM( val (  substr(cbuff,at(chr(9),cBuff )  ) ) + 1,"9999999999" ) + chr(9) + " Ultm Exec " + Time() + " - " + dtoc(date())
		aFile[nCount,1] := cBuff
		aFile[nCount,2] := val (  substr(cbuff,at(chr(9),cBuff ),11  ) )
		lFound := .t.
	end
	nCount++
end
nHand := myfcreate(cRanking,66)
aFile := asort(aFile,,, {|x,y| x[2] > y[2] } )
for nCount := 1 to len(aFile)
	myfwrite(nHand,aFile[nCount,1] + CRLF ,len(aFile[nCount,1]) +2,@cTotalBuff)
next
myfclose(nHand)
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/26/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsItem(cCampo)
Local cCamposItem	:= CampoItem()
Local lItem			:= .F.
Local cCampoOk		:= ""

//fElapTime()

While !Empty(cCampo) .and. !lItem
	If 	"+" $ cCampo
		cCampoOk := Substr(cCampo,1,at("+",cCampo)-1)
	Else
		cCampoOk := cCampo
	End
	If cCampoOk $ cCamposItem .and. !lItem
		lItem := .T.
	End
	If 	"+" $ cCampo
		cCampo := Strtran(cCampo,Substr( cCampo, 1, at("+",cCampo) ),"" )
	Else
		cCampo := ""
	End
End

Return lItem


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaAcesso()
Local x
Local cMemo := ""
Local lOk := .f.

//fElapTime()

if file(cFileAcesso)
	cMemo := MemoRead(cFileAcesso)
end

DEFINE MSDIALOG oDlg FROM 0,0 TO 440,640 TITLE "Permiss๕es de acesso" PIXEL
@ 0, 0  get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 MEMO HSCROLL pixel
NlINHA := (oDlg:nClientHeight/2)-35
nColuna := 10
@ NlINHA,nColuna BUTTON "Salvar" SIZE 50,10 Pixel ACTION ( lOk := .t., ODLG:end() )
@ NlINHA,nColuna+= 60 BUTTON "Cancelar" SIZE 50,10 Pixel ACTION ( ODLG:end() )
ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
if lOk
	memowrit(cFileAcesso,cMemo)
	if MsgYesno("Salva Copia Local")
		memowrit(cLocalAcesso,cMemo)
	end
	CarregaArea(cFileacesso)
end
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// { { datai sla1, horai sla1, dataf sla1, horaf sla1, analista, previsto sla1 }.....
// TEMPOS SLA
// TEMPO SLA

Static Function CalcTemposSla(aTempos)
Static lClcTmpSla := FindFunction( "u_Calc2TemposSla" )
//fElapTime()

If lNewFormat .And. lClcTmpSla
	u_Calc2TemposSla( aTempos )
Else
	Calc2TemposSla( aTempos )
EndIf

Return Nil

//If lOk
	//aTempos[2,1] := Data Inicio
	//aTempos[2,2] := Hora Fim
	//aTempos[2,3] := Data Fim
	//aTempos[2,4] := Hora Fim
	//aTempos[2,5] := Analista
	//aTempos[2,6] := Ja calculado, bloqueado para calculos
	//aTempos[2,7] := Segundos ja Calculados
	//aTempos[2,8] := Data temp
	//aTempos[2,9] := Hora Temp
	//aTempos[2,13] := Data abertura nao muda
	//aTempos[2,14] := Hora abertura nao muda
	//aTempos[2,15] := tempo do cliente // ainda verificar como vai fazer
	//aTempos[2,16] := foi para a fabrica
	//aTempos[2,17] := ASSOCIOU
	//aTempos[2,18] := segundos antes do limite
	//aTempos[2,19] := soma do tempo at้ o limite
    //lOk := RetCliOk(cCliente,dData,cChFil)
//end

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calculo do tempo na faixa                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Parametros:                                                บฑฑ
ฑฑบ          ณ aArg1 = Vetor com todos os tempos                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Calc2TemposSla( aTempos )
// MICHEL
// compatibilidade
Local lProcessou	:= .F. //( ADF->ADF_CODSU0 == "HM" .OR. ADF->ADF_CODSU0 == "PP" ) // .or. alltrim( ADF->ADF_CODSU7 ) == "AUTO" )

Local lTransN3		:= !Empty(ADF->ADF_FNC) .OR. alltrim(ADF->ADF_CODSUQ)=='000002'
Local lFabrica		:= If( !Empty(aTempos[1,1]) .and. alltrim(ADF->ADF_CODSU9) == "TMK001" .and. !lTransN3, VldFabrica(), .F. )
Local lRetFabrica	:= If( !Empty(aTempos[4,1]) .and. alltrim(ADF->ADF_CODSU9) == "TMK001".and. !lTransN3, VldRetFab(), .F. )
Local lTransN1		:= !lFabrica .AND. !lRetFabrica .AND. !lTransN3 .and. alltrim(ADF->ADF_CODSU9) == "TMK001" 

Local lAssociou		:= ( alltrim(ADF->ADF_CODSU9) == "TMK002" )
Local lAuto			:= ( alltrim(ADF->ADF_CODSU7) == "AUTO" )

Local bFechaFX1	:= {|| .F. }
Local bFechaFX2	:= {|| .F. }
Local bFechaFX4	:= {|| .F. }


//Cabecalho na fabrica e ta marcado como transferencia
//Local lFabrica	:= ( ADENEW->ADE_GRUPO $ SLA_FSW .AND. alltrim(ADF->ADF_CODSU9) == "TMK001" ) //$ ADF->ADF_CODSU0 $  .or. ( alltrim(ADF->ADF_CODSU9) == "TMK001" .and. Empty(ADF->ADF_FNC) ) )
//Local lFoiFabrica	:= ADF->ADF_CODSU0 $ SLA_FSW .or. ADENEW->ADE_GRUPO $ SLA_FSW
//validacao fabrica
Local nSec2			:= 0
Local cItem 		:= ADF->ADF_ITEM
Local lProc2		:= .F.

//fElapTime()
// Local lChmAberto	:= ( ADENEW->ADE__ENTPE $ "10/30/40" )
// tratamentos dividido por faixas, pois a abertura de uma proxima faixa pode ser seguido de um encerramento de uma faixa anterior
// CalcFaixa(aTempos, nFaixaAtual, nFaixa, bAcao, bVldAbre, bVldFecha, bMudaFaixa)

If ExecPoint("000005")
	bFechaFX1 :=	{|| (	( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY( aFiltros[EQUIPEATE] ) ) .and.;
							( ADF->ADF_CODSUQ $ TPFX1FIM .OR. lAssociou )	) .or.;
						( ADF->ADF_CODSU0 = "PP" .and. ADF->ADF_CODSUQ = "000140" ) }
	bFechaFX2 :=	{||	( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .and. ADF->ADF_CODSUQ $ TPFX2FIM ) .or.;
						( ADF->ADF_CODSU0 = "PP" .and. ADF->ADF_CODSUQ = "000140" ) }
	bFechaFX4 :=	{||	( ADF->ADF_CODSUQ $ TPFX4FIM ) .or.;
						( lRetFabrica ) .or.;
						( ADF->ADF_CODSU0 = "PP" .and. ADF->ADF_CODSUQ = "000140" ) }
Else					
	bFechaFX1 :=	{||	( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY( aFiltros[EQUIPEATE] ) ) .and.;
						( ADF->ADF_CODSUQ $ TPFX1FIM .OR. lAssociou ) }
	bFechaFX2 :=	{|| (ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .and. ADF->ADF_CODSUQ $ TPFX2FIM) }
	bFechaFX4 :=	{|| ( ADF->ADF_CODSUQ $ TPFX4FIM ) .or. lRetFabrica }
EndIf					

// PEGANDO INICIO DO TEMPO SEMPRE SE NAO TENHO O INICIO

If	Type( "nFaixaAtual" ) == "N" .and.;
	( nFaixaAtual == 6 ) .and.;
	( ADF->ADF_CODSU9 $ "TMK001" ) .and.;
	( Empty( ADF->ADF_CODSUQ ) .or. ADF->ADF_CODSUQ $ "000011" ) .and.;
	ChkNextADF("HF")
	nFaixaAtual := 2
EndIf

// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Iniciando a faixa 1                                                                           ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	DATA_INICIO EM BRANCO
If     lProcessou := CalcFaixa(aTempos,nFaixaAtual,1,;
					{|| Empty(aTempos[1,1]) },;
					{|| Empty(aTempos[1,1]) } )
//	TRANSFERIDO DO N1
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,1,;
					{|| ( alltrim(ADF->ADF_CODSUQ) $ "000011" .or. lTransN1 .or. lAssociou) .AND. !(ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] ) },;
					{|| Empty(aTempos[1,6]) } )
// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Encerrando a Faixa 1                                                                          ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	(EQUIPE = HF OU EQUIPE = "") E 
//	(CODIGO FAIXA $ CODIGOS_FECHA OU ASSOCIOU)
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,1,;
					bFechaFX1,;
					,;
					{|| Empty(aTempos[1,6]) },;
					{|| nFaixaAtual := 2 } )
//	(EQUIPE = HF OU EQUIPE = "") E 
//	(TRASFERIU PARA FABRICA)
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,1,;
					{|| ( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY( aFiltros[EQUIPEATE] ) ).and. ( lfabrica ) },;
					,;
					{|| Empty(aTempos[1,6]) },;
					{|| nFaixaAtual := 4 } )
//	(EQUIPE = HF OU EQUIPE = "") E 
//	(TRASFERIU PARA IP->N1)
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,1,;
					{|| ( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY(  aFiltros[EQUIPEATE] ) ).and. ( lTransN1 ) },;
					,;
					{|| Empty(aTempos[1,6]) },;
					{|| nFaixaAtual := 6 } )
EndIf

If lProcessou
	lProc2 := .T.
EndIf

// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Iniciando a faixa 2                                                                           ณ
// ฦอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออต
// ณ Sempre inicio se ja processei a Faixa 1.                                                      ณ
// ณ Esse eh a primeira vez que entra.                                                             ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lProcessou := CalcFaixa(aTempos,nFaixaAtual,2,;
				{|| !Empty(aTempos[1,6]) .and. ADF->ADF_CODSUQ $ TPFX2INI },;
				{|| Empty(aTempos[2,1]) .and. empty(aTempos[3,1])  } )
ElseIf lProcessou := CalcFaixa(aTempos,@nFaixaAtual,2,;
				{|| ADF->ADF_CODSU9 $ "TMK001" .AND. ( Empty( ADF->ADF_CODSUQ ) .or. ADF->ADF_CODSUQ $ "000011" ) },;
 				{|| ChkNextADF("HF") } )
Elseif lProcessou := CalcFaixa(aTempos,nFaixaAtual,2,;
				{|| Empty( aTempos[1,12] ) .and. Empty( aTempos[3,1] ) .and.;
					( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY( aFiltros[EQUIPEATE] ) .OR. lAuto ) .and.;
					ADF->ADF_CODSUQ $ TPFX2INI .and. Empty(aTempos[2,17]) },;
				{|| empty(aTempos[3,1]) .and. If( ExecPoint( "000004" ), !lFabrica, .T. ) } )

// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Encerrando a faixa 2                                                                          ณ
// ฦอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออต
// ณ Encerrando a faixa 2 com a Abertura da faixa 3.                                               ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
elseif lProcessou := CalcFaixa(aTempos,nFaixaAtual,2,;
					{|| empty(aTempos[3,1]) .and. ltransN3 .and. empty(aTempos[2,17]) },;
					,;
					{|| !Empty(aTempos[2,1]) },;
					{|| nFaixaAtual := 3 } )
//Quando transferido para outra equipe, paro a faixa 2 e nenhuma outra linha sera considerada, 
//ate que encontre outra transferencia de volta.
elseif lProcessou := CalcFaixa(aTempos,nFaixaAtual,2,;
					{|| ( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY( aFiltros[EQUIPEATE] ) ).and. ( lTransN1 ) },;
					,;
					{|| .T. }, ;
					{|| nFaixaAtual := 6 } )
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,2,;
					{|| ( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .or. EMPTY(  aFiltros[EQUIPEATE] ) ) .and. ( lFabrica ) }, ;
					,;
					{||.T.}, ;
					{|| nFaixaAtual := 4 } )
// Encerramento pelo cliente atrav้s do portal
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,2,;
					bFechaFX2,;
					,;
					{|| !Empty(aTempos[2,1]) .and. empty(aTempos[3,1]) .and. empty(aTempos[2,6]) },;
					{|| nFaixaAtual := 2 } )
EndIf

If lProcessou
	lProc2 := .T.
EndIf
   
// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Iniciando a Faixa 3                                                                           ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if lProcessou := CalcFaixa(aTempos,nFaixaAtual,3,;
				{|| ADF->ADF_CODSUQ $ TPFX3INI .OR. ltransN3 },;
				{|| /*empty(aTempos[3,1]) */ .T.} )
// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Encerrando a faixa 3                                                                          ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
elseif lProcessou := CalcFaixa(aTempos,nFaixaAtual,3,;
				{|| ADF->ADF_CODSUQ $ TPFX3FIM },;
				,;
				{|| empty(aTempos[3,6]) .and. !Empty(aTempos[3,1]) },;
				{|| nFaixaAtual := 3 }  )

elseif lProcessou := CalcFaixa(aTempos,nFaixaAtual,3,;
				{|| ADF->ADF_CODSUQ $ TPFX3FIM .and. lFabrica },;
				,;
				{|| empty(aTempos[3,6]) .and. !Empty(aTempos[3,1]) },;
				{|| nFaixaAtual := 4 }  )
end

If lProcessou
	lProc2 := .T.
EndIf

// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Iniciando a Faixa 3Fsw                                                                        ณ
// ฦอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออต
// ณ Fabrica Faixa 3Fsw                                                                            ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If lProcessou := CalcFaixa(aTempos,nFaixaAtual,4,;
				{|| lFabrica  },; //.or. lFoiFabrica
				{|| .T. } )

// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Encerrando a Faixa 3Fsw                                                                       ณ
// ฦอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออต
// ณ Fabrica Faixa 3Fsw                                                                            ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ElseIf lProcessou := CalcFaixa(aTempos,nFaixaAtual,4,;
				bFechaFX4,;
				,;
				{|| empty(aTempos[4,6]) .and. !Empty(aTempos[4,1]) },;
				{|| nFaixaAtual := If( lRetFabrica , 2 , 4 ) }  )

	CalcFaixa( aTempos , nFaixaAtual , 2 , {|| lRetFabrica } , {|| .T. } )	
EndIf

If lProcessou
	lProc2 := .T.
EndIf

// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Possivel Fabrica                                                                              ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//elseif lProcessou := CalcFaixa(;
//			aTempos,;
//			nFaixaAtual, ;
//			2,;
//			{|| lTransN1 },;//.or. lFoiFabrica
//			{|| !Empty(aTempos[2,1]) },;
//			{|| nFaixaAtual := 4, dDataLinha := ADF->ADF_DATA, cHoraLinha := ADF->ADF_HORA } )
//encerrando normal
//elseif lProcessou := CalcFaixa(;
//						aTempos, ;
//						nFaixaAtual, ;
//						2, ;
//						{|| ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .and. ( ( !ltransN1 .or. !ltransN3) .or. lAssociou) }, ;
//						 ,;
//						{|| !Empty(aTempos[2,1]) .and. empty(aTempos[3,1]) },;
//						{|| nFaixaAtual := 2 } )
                                                                    
// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ FAIXA INEXISTENTE - EM OUTRA EQUIPE                                                           ณ
// ฦอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออต
// ณ Quando chamado devolvido de outra equipe, devera reabrir a faixa 2.                           ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//If lProcessou := CalcFaixa(;
//					aTempos,;
//					nFaixaAtual,;
//					6,;
//					{|| !( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] ).and. ( lTransN1) .and. lfaixa6}, ;
//					,;
//					{||.T.}, ;
//					{|| nFaixaAtual := 2 } )
// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
// ณ Abrindo faixa inexistente                                                                     ณ
// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ElseIf lProcessou := CalcFaixa(;
//					aTempos,;
//					nFaixaAtual,;
//					6,;
//					{|| ( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] ).and. ( lTransN1) }, ;
//					{||.T.},;
//					,;
//					{|| lfaixa6:=.T. } )
//EndIf

//If lProcessou := CalcFaixa(;
//					aTempos,;
//					nFaixaAtual,;
//					2,;
//					{|| !( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] ).and. ( lTransN1) .and. lfaixa6}, ;
//					{||.T.},;
//					,;
//					{|| lFaixa6:=.F.} )
//end

If !lProc2
	AddDebug({;
		alltochar( 0 ) + " NADA",;
		ADF->ADF_ITEM,;
		ADF->ADF_DATA,;
		ADF->ADF_HORA,;
		ADF->ADF_CODSUQ,;
		ADF->ADF_CODSU0,;
		nToTime(aTempos[01,07]),;
		nToTime(aTempos[02,07]),;
		nToTime(aTempos[02,15]),;
		nToTime(aTempos[02,19]),;
		nToTime(aTempos[02,18]),;
		nToTime(aTempos[03,7]);
	})
End

If ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
	dUltDtATD := ADF->ADF_DATA
	cUltHrATD := ADF->ADF_HORA
EndIf

If !( ADF->ADF_CODSU0 $ "HM/PP" )
	dUltDtMov := ADF->ADF_DATA
	cUltHrMov := ADF->ADF_HORA
endif

Return NIL 
/*rotina padrao para calculo de tempos*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula os tempos e valida alteracoes nas faixas.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Parametros:                                                บฑฑ
ฑฑบ          ณ aTempos   := Vetor com todos os tempos.                    บฑฑ
ฑฑบ          ณ nFaixa    := Numero da faixa a ser validada.               บฑฑ
ฑฑบ          ณ bAcao     := Abre ou Fecha uma faixa na condicao indicada. บฑฑ
ฑฑบ          ณ              Ex. Empty( aTempos[1,1] ).                    บฑฑ
ฑฑบ          ณ bVldAbre  := Valida a abertura ex. Empty(aTempos[1,1]).    บฑฑ
ฑฑบ          ณ bVldFecha := Valida o fechamento.                          บฑฑ
ฑฑบ          ณ bMudaFaixa:= Efetua a mudanca de faixa.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcFaixa( aTempos, nFaixaAtual, nFaixa, bAcao, bVldAbre, bVldFecha, bMudaFaixa )
Local lProcessou	:= .F.
Local nSec2			:= 0
Local lAuto			:= ( alltrim(ADF->ADF_CODSU7) == "AUTO" )
Local lAssociou		:= ( alltrim(ADF->ADF_CODSU9) == "TMK002" )

//fElapTime()

If nFaixaAtual == nFaixa
	If !Empty( bAcao ) .and. Eval( bAcao )
		// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		// ณ Abertura das Faixas                                                                   ณ
		// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty( bVldAbre ) .and. Eval( bVldAbre )
		    IF nFaixa <> 6
				If empty(aTempos[nFaixa,1]) .or. nFaixa <> 2 .OR. !Empty(aTempos[nFaixa,6])
					aTempos[nFaixa,1] := ADF->ADF_DATA
					aTempos[nFaixa,2] := ADF->ADF_HORA
					aTempos[nFaixa,12] := lAuto
				EndIf
				If nFaixa == 4
					aTempos[nFaixa,1] := dDataLinha
					aTempos[nFaixa,2] := cHoraLinha
				end
				if empty(aTempos[nFaixa,13])
					aTempos[nFaixa,13] := ADF->ADF_DATA
					aTempos[nFaixa,14] := ADF->ADF_HORA
				end
				if nFaixa == 1 // sempre reabro a faixa 1 at้ o tempo certo
					aTempos[nFaixa,13] := ADF->ADF_DATA
					aTempos[nFaixa,14] := ADF->ADF_HORA
				end			
				
				// apenas para a faixa 2
				if	nFaixa == 2 .and.;
					!Empty(aTempos[nFaixa,3]) .and.;
					!Empty(aTempos[nFaixa,6]) .and.;
					aTempos[nFaixa,18] > 0 
					
 					DifTime({aTempos[nFaixa,3],aTempos[nFaixa,4],aTempos[nFaixa,1],aTempos[nFaixa,2]},,@nSec2)
					If Empty(aTempos[nfaixa,15])
						aTempos[nfaixa,15] := 0
					end
					aTempos[nFaixa,15] += nSec2
				end

				aTempos[nFaixa,3] := date()
				aTempos[nFaixa,4] := time()
				aTempos[nFaixa,5] := RetNomeOpera(ADF->ADF_CODSU7,.T.,aTempos[nFaixa,5])
				aTempos[nFaixa,6] := .F.

				lProcessou := .T.

				If !lAnalista
					lAnalista := ( !Empty(aTempos[nFaixa,5]) .or. aTempos[nFaixa,5] <> "AUTO" )
				EndIf
				
			EndIf
			
			AddDebug({;
			alltochar(nFaixa) + " ABRE",;
			ADF->ADF_ITEM,;
			ADF->ADF_DATA,;
			ADF->ADF_HORA,;
			ADF->ADF_CODSUQ,;
			ADF->ADF_CODSU0,;
			nToTime(aTempos[01,07]),;
			nToTime(aTempos[02,07]),;
			nToTime(aTempos[02,15]),;
			nToTime(aTempos[02,19]),;
			nToTime(aTempos[02,18]),;
			nToTime(aTempos[03,7])})
		EndIf
		
		// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		// ณ ENCERRA AS FAIXAS                                                                     ณ
		// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty( bVldFecha ) .and. Eval( bVldFecha ) 
			If nFaixa <> 6
				aTempos[nFaixa,3] := ADF->ADF_DATA
				aTempos[nFaixa,4] := ADF->ADF_HORA
			    if nFaixa == 1 .or. nFaixa == 2
					aTempos[nFaixa,5] := RetNomeOpera(ADF->ADF_CODSU7,.t.,aTempos[nFaixa,5])
				elseif alltrim(ADF->ADF_CODSU7) <> "AUTO"
					aTempos[nFaixa,5] := upper(alltrim(myPosicione("SU7",1,MyXfilial("SU7")+ADF->ADF_CODSU7,"U7_NOME"))) 
				end
				
				aTempos[nFaixa,6] := .T. // Tenho o tempo certo
				if !lAnalista
					lAnalista := ( !Empty(aTempos[nFaixa,5]) .or. aTempos[nFaixa,5] <> "AUTO" )
				end
			
				aTempos[nFaixa,17] := lAssociou
		
				diftime(aTempos[nFaixa],,@nSec2)		
		
				/*sempre somar pois eh o tempo total da faixa*/
				IF empty(aTempos[nFaixa,7])
					aTempos[nFaixa,7] := 0
				END
		
				aTimeDif[nFaixa,7] += nSec2
		
				/*TIRO O PARCIAL PARA SABER QUANTO O CLIENTE PROCESSOU E SE PODE CONTINUAR*/
				if !Empty(aTempos[nFaixa,18]) .and. aTempos[nFaixa,18] > 0 
					if empty(aTempos[nFaixa,19])
						aTempos[nFaixa,19] := 0
					end
		
					if aTempos[nFaixa,18] - nSec2 >= 0
						// deu zica nessa data
						// procurar como aproximar
						aTempos[nFaixa,19] += nSec2
					else
					// desconto apenas o que der antes do 0
						aTempos[nFaixa,19] += aTempos[2,18]
					end
					aTempos[nFaixa,18] -= nSec2
				end
		
				aTempos[nFaixa,1] := ADF->ADF_DATA
				aTempos[nFaixa,2] := ADF->ADF_HORA
			
				if nFaixa == 1 .and. ADF->ADF_CODSUQ $ "000025/000024" // tratamento especial para faixa 2
					aTempos[2,3] := ADF->ADF_DATA
					aTempos[2,4] := ADF->ADF_HORA; aTempos[2,6] := .T.
				end
								
				aTempos[nFaixa,12] := lAuto
				lProcessou := .T.
			End
		    
			AddDebug({;
			alltochar( nFaixa ) + " FECHA",;
			ADF->ADF_ITEM,;
			ADF->ADF_DATA,;
			ADF->ADF_HORA,;
			ADF->ADF_CODSUQ,;
			ADF->ADF_CODSU0,;
			nToTime(aTempos[01,07]),;
			nToTime(aTempos[02,07]),;
			nToTime(aTempos[02,15]),;
			nToTime(aTempos[02,19]),;
			nToTime(aTempos[02,18]),;
			nToTime(aTempos[03,07])})
		EndIf
		
		/*So mudo as faixas caso seja processada*/
		If !Empty( bMudaFaixa )
			Eval( bMudaFaixa )
		EndIf
	EndIf
EndIf

Return lProcessou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SelProfile()
Local cDirect := "c:\filtro_ssim\"
Local aFiles := {}
Local lOk := .F.
Local cCombo := ""                       
//fElapTime()
aeval( Directory(cDirect + "*.cfg") , { |x| aadd(aFiles,strtran(x[1],".CFG","") ) } )

DEFINE MSDIALOG oDlg FROM 0,0 TO 300,640 TITLE "Consultas" PIXEL
@ 1,1 Say "Carregar a Consulta" Pixel
@ 2,1 COMBOBOX oCombo Var cCombo Items aFiles SIZE 200,20 Pixel
@ 3,1 BUTTON "Confirmar" SIZE 40,11 Pixel ACTION ( lOk := .t., oDLG:End() )
@ 3,2 BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )
Activate MSDIALOG oDLG Centered On Init AjustaTamanho( oDLG )

If lOk
	cPerfil := cCombo
	MYmsgrun( "Lendo Profile" ,, {|| MyProfile( .T. ) } )
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function DelProfile()
Local cDirect := "c:\filtro_ssim\"
Local aFiles := {}
Local lOk := .F.
Local cCombo := ""
//fElapTime()
aeval( Directory(cDirect + "*.cfg") , { |x| aadd(aFiles,strtran(x[1],".CFG","") ) } )

DEFINE MSDIALOG oDlg FROM 0,0 TO 300,640 TITLE "Consultas" PIXEL
@ 1,1 Say "Excluir a Consulta" Pixel
@ 2,1 COMBOBOX oCombo Var cCombo Items aFiles SIZE 200,20 Pixel
@ 3,1  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION ( lOk := .t., oDLG:End() )
@ 3,2  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )
Activate MSDIALOG oDLG Centered On Init AjustaTamanho(oDLG)

if lOk
	lOk := ferase(cDirect+cCombo+".cfg")
	cPerfil := ""
End
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SaveProf2()
Local cDirect := "c:\filtro_ssim\"
Local aFiles := {}
Local lOk := .F.
Local cCombo := ""
//fElapTime()
cCombo := pad(cPerfil,255)

aeval( Directory(cDirect + "*.cfg") , { |x| aadd(aFiles,strtran(x[1],".CFG","") ) } )

@ 1,1 Say "Salvar como" Pixel
@ 2,1 msget oCombo Var cCombo SIZE 200,11 Pixel
@ 3,1  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION ValidSave(cCombo,aFiles,cCombo)
@ 3,2  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidSave(cCombo,aFiles)
Local lOk := ( aScan(aFiles,{|x| alltrim(cCombo) == strtran(x,".CFG","")  } ) == 0 )
//fElapTime()
if !lOk
	lOk := msgyesno("Arquivo ja existe, sobrescrever? " )
End
if lOk
	cPerfil := alltrim(cCombo)
	MYmsgrun("Lendo Profile",,{|| myprofile() }  )
	oDLG:End()
end

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// Criar esquema para reposicionar a janela...
// Criacao de janelas automaticamente.
// Para que a janela funcione corretamente, as funcoes e valida็๕es deverao 
// estar fora da janela principal, criando uma nova funcao.
Static Function CriaJanela( cTitle, bInit, nPos1, nPos2 )
Private oDlg	:= NIL
//fElapTime()

If nPos1 == nil
	nPos1 := 440
	nPos2 := 640
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO nPos1,nPos2 TITLE cTitle PIXEL
ACTIVATE MSDIALOG oDlg CENTER ON INIT ( Eval( bInit ), AjustaTamanho( oDlg ) )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// ",xxx,xxx,xxx,xxx,xxx"
// " '   ','xxxx'  "

static function montain(cIn)
Local cReturn := "('"
cReturn += strtran(cIn,",","','")
cReturn := strtran(cReturn,";","','")
cReturn += "')"
cReturn :=  strtran(cReturn,",''","")
//fElapTime()
Return cReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExcelSintetico( lAuto )
//fElapTime()
Private lConfirma := .F.

If Empty( lAuto )
	If aFiltros[NSTATUS] == "Estatistica Geral"
		Criajanela( "Parametros", {|| ValidaTotais( lAuto ) }, 200, 640 )
		If lConfirma
			MYMSGRUN( "Gerando Temporario" ,, {|| ExportExcel( ,, .T. )} )
		EndIf
	Else
		msgstop( "Escolha o filtro 'Estatistica Geral'" )
	EndIf
Else
	ValidaTotais( lAuto )
	ExportExcel( ,, .T. ,,, .T. )
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function OpenExcel( cFile , cFileTemp , cCabec , lDireto )
Local x
Local oExcel
Local nHand
Local cBuff := ""
Local lOk := !Empty( Alias() )
//fElapTime()
If Empty(lDireto)
	cFile += ".csv"
	nHand := myfcreate(cFile,66)
	If lOk
		If !Empty(cCabec)
			myfwrite(nHand,cCabec + CRLF,,@cTotalBuff)
		Else
			For x := 1 To fCount()
				cBuff += AllTrim( FieldName(x)) + ";"
			Next x
			myfwrite(nHand,cBuff+CRLF,,@cTotalBuff)
		EndIf
	EndIf

	dbGoTop()

	While !Eof()
		cBuff := ""
		For x := 1 To fCount()
	//		cBuff += strtran(ansitooem( alltochar( fieldget(x) )  ),";",",") + ";"
			cBuff += StrTran(oemtoansi( alltrim(alltochar( fieldget(x) ) )  ),";",",") + ";"
		Next x
		cBuff := StrTran(cBuff,chr(13),"")
		cBuff := StrTran(cBuff,chr(10),"")
		cBuff := StrTran(cBuff,"--","")	
		
		myfwrite(nHand,cBuff + CRLF,,@cTotalBuff)
		dbskip()
	EndDo
	myfclose(nHand)
	dbCloseArea()
	fErase(cFileTemp+".dbf")
	fErase(cFileTemp+".dtc")
	fErase(cFileTemp+".fpt")
EndIf

If ShellExecute ("open",cFile,"","",1) == 31 // nao estแ associado, abro no modo antigo automatico
	oExcel:= MsExcel():New()
	oExcel:WorkBooks:Open( cFile) // Abre uma planilha
	oExcel:SetVisible(.T.)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  03/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ValidCliFaixa(cCodCli,cNomeCol,dData)
Local lOk := .T.
Local cClientes := ""
//CLIFX1=0000000,000000

//CLIFX2C1=
//CLIFX2C2=
//CLIFX2C3=

//CLIFX3C1=
//CLIFX3C2=
//CLIFX3C3=

Local cChave := "CLIFX"
Local cChFil := ""
//fElapTime()
If cNomeCol == "FAIXA1_TP"
	cChFil := "1"
	cChave += "1"
ElseIf cNomeCol == "FAIXA2_TP"
	cChFil := "2"
	cChave += "2"
ElseIf cNomeCol == "FAIXA3_TP"
	cChFil := "3"
	cChave += "3"
ElseIf cNomeCol == "FAIXA4_TP"
	cChFil := "F3_FSW"
	cChave += "F3_FSW"
Else
	cChFil := "1"
	cChave += "1"
EndIf

cClientes := &(cChave) + &(cChave+"a") + &(cChave+"b")+&(cChave+"c")+&(cChave+"d")

If ! Empty(cClientes)
	lOk := AllTrim(cCodCli) $ cClientes
EndIf

if AllTrim(cCodCli) $ "T7716900" .and. ADENEW->ADE_DATA < stod("20100501")
	lOk := .F.
EndIf

If 	lOk .And. ADENEW->ADE_TIPO == "000007" // Se for autoatendimento, desconsidero do calculo do SLA do cliente
	lOk := .F.
Endif

//If !lOk
//	cContratos := ""
	// ZQE_FILIAL ZQE_CODCLI ZQE_LJCLI ZQE_CONTR ZQE_VERSAO ZQE_SERVIC ZQE_FAMILI ZQE_SLA ZQE_INADIM ZQE_CLICOL ZQE_LJCOL ZQE_ATENDE ZQE_EMPFIL ZQE_MIGRAC ZQE_CLICPF ZQE_TOTHR ZQE_VLRHR ZQE_DESCFA
//	ZQE->(dbsetorder(1)) // cabec USAR ESSE
  //	ZQE->(dbsetorder(1))
//	if ZQE->(dbseek( myxfilial("ZQE") + cCodCli ) )
//		While !ZQE->(Eof()) .and. ZQE->(ZQE_FILIAL+ZQE_CODCLI+ZQE_LJCLI) == myxfilial("ZQE") + cCodCli
//			cContratos += ZQE->ZQE_SLA + CRLF
//			ZQE->(dbskip())
//		end
//	end
//	myposicione("ZQE",1, myxfilial("ZQE") + cCodCli,"ZQE_SLA")
//	myposicione("ZQG",2, myxfilial("ZQG") + cCodCli,"ZQG_DTFIEQ")	
//	ZQE->(
	// ZQG_FILIAL ZQG_CODCLI ZQG_LOJA ZQG_NUMCTR ZQG_CODVER ZQG_SERVIC ZQG_EMPFIL ZQG_PRODUT ZQG_SITUAC ZQG_DATINI ZQG_DATFIM ZQG_TABSER ZQG_NIVSEV ZQG_DTINEQ ZQG_DTFIEQ
//	ZQG->(dbsetorder(2)) // itens
//	alert(cContratos)
//end

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/19/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function validconfirm(oDlg,oFiltro,lConfirma)
//fElapTime()
If  !empty(aFiltrosTmp[EQUIPEATE])
	lConfirma := .t.
//	aFiltrosTmp[DATADE] := ctod("01/" + strzero( month( aFiltrosTmp[DATADE]),2) + "/" + strzero( year ( aFiltrosTmp[DATADE]),4) )
	aFiltrosTmp[EQUIPEATE] := AllTrim(aFiltrosTmp[EQUIPEATE])
	aFiltros := aFiltrosTmp
Else
	alert("Informe o Grupo")
EndIf

If	aFiltrosTmp[NSTATUS] == "Estatistica Geral" .and. aFiltrosTmp[DATADE] < stod('20090101').AND. lConfirma 
	ALERT("A data inicio nใo pode ser inferior a 01/01/2009")
	lConfirma := .f.
EndIf

If lConfirma
	oDLG:End()
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function calculaSlaMensal( dDataRef )
Local lOk := .f.
//fElapTime()
If ValType( dDataRef ) == "D"
	If Left( DtoS(aFiltros[DATADE] ),6) == Left(DtoS(aFiltros[DATAATE]),6)
		If dDataRef >= aFiltros[DATADE] .and. dDataRef <= aFiltros[DATAATE]
			lOk := .t.
		EndIf
	EndIf
EndIf

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ClclaSla()
Local lOk := .T.
Local nCount := 0
//"N1,N2"
//fElapTime()
For nCount := 1 To Len( aFiltros[EQUIPEATE] ) Step 3
	If lOk
		lOk := SubStr( aFiltros[EQUIPEATE] , nCount , 2 ) $ AREAS_SLA_TOTVS
	EndIf
Next nCount

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Proc_Texto()
Local lOk := .T.
//fElapTime()
If ! lMostraTxt
	If aFiltros[NSTATUS] == "Estatistica Geral" .and. Empty( aFiltros[CLIENTE] )
		lOk := .F.
	Endif
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//  ,999,999,99,999,999,99999,999,999,99,99,9
// 99,99,99,99,99,99,99
Static Function AjustaVirgula(cVar,nTamanho,cDivid)
Local nCount := 0
Local cVarTmp := ""
//fElapTime()
If Empty(cDivid)
	cDivid := ","
EndIf
If Empty(nTamanho)
	nTamanho := 2
EndIf
cVar := AllTrim(cVar)
cVar := StrTran(cVar,",","")
cVar := StrTran(cVar,"/","")

For nCount := 1 To Len(cVar) Step nTamanho
	cVarTmp += SubStr(cVar,nCount,nTamanho) + cDivid
Next nCount

cVarTmp := SubStr(cVarTmp,1,Len(cVarTmp) - 1 )

Return cVarTmp


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetDifTime( cHoraini , cHoraFim )
Local nSec2 := 0
Local cHoras := ""
//fElapTime()
nSec2 += timetosec( cHoraFim )
nSec2 -= timetosec( cHoraini ) 
cHoras  := nToTime( nSec2 )
Return cHoras

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/25/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyFCreate(cFile,nMode,cMaxBuff)
Local nHand := NIL

Default nMode		:= 66
Default cMaxBuff	:= ""

//fElapTime()

cMaxBuff := cTotalBuff := ""
FClose(FCreate(cFile))
nHand := FOpen(cFile,nMode)
If nHand < 0
	MsgStop("Erro criando o arquivo " + cFile )
End

Return nHand

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  06/23/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyFWrite(nHand,cBuff,nBuff,cMaxBuff)
Local lMaximo := .F.

Default cMaxBuff := ""

//fElapTime()

If Len(cMaxBuff) + Len(cBuff) < 1000000
	cMaxBuff += cBuff
Else
	lMaximo := .T.
End
If Len(cMaxBuff) >= 500000 .and. nHand >= 0
	FWrite(nHand,cMaxBuff)
	cMaxBuff := ""
	If lMaximo
		cMaxBuff += cBuff
	End
End

Return Len(cBuff)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  06/23/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MyFClose(nHand,cMaxBuff)
Default cMaxBuff := cTotalBuff

//fElapTime()
If nHand >= 0
	FWrite(nHand,cMaxBuff)
	FClose(nHand)
End
Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function SomaHora(cHoraini,cHoraFim)
Local nSec2 := 0
lOCAL cHoras := ""
//fElapTime()
nSec2 += timetosec(cHoraini)
nSec2 += timetosec(cHoraFim)
cHoras := nToTime(nSec2)
Return cHoras
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  07/20/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function adjfat()
Local aStru := {}
Local oBrowTmp
Local oDlg
lOCAL nLinha := 0
Local lOk := .f.
//fElapTime()
If !Empty( aCols ) .And. !Empty( Retacols( "CHAMADO" , oBrow:nAt ) )
	ADE->( dbSetOrder(1) )
	ADE->( dbSeek(myxfilial("ADE") + Retacols("CHAMADO",oBrow:nAt) ) )
	SA1-> ( dbSetOrder(1) )
	SA1 -> ( dbSeek( Myxfilial("SA1")+ADE->ADE_CHAVE ) )
	Private M->ADE_GRUPO  := ADE->ADE_GRUPO
	Private M->ADE_ASSUNT := ADE->ADE_ASSUNT
	Private M->ADE_FATURA := ADE->ADE_FATURA

	ADF->( dbSetOrder( 1 ) )
	ADF->( dbSeek( MyxFilial("ADF") + ADE->ADE_CODIGO ) )

	While ! ADF->( Eof() ) .AND. ADF->ADF_CODIGO  == ADE->ADE_CODIGO
		ADF -> ( aAdd( aStru, {ADF_DATA, ADF_HORA, ADF_FATDUR, ADF_CODSU7, If(ADF_FATURA=="1","S","N"), AllTrim(MSMM(ADF_CODOBS)), ADF_ITEM } ) )
		ADF->( dbSkip() )
	EndDo

	DEFINE MSDIALOG oDlg From 0,0 To 420,640 Title "Tempo do chamado " + retacols("CHAMADO",oBrow:nAt) Pixel
	
//	nLinha := (oDlg:nClientHeight/2)-10
	
	oBrowTmp := TwBrowse():New(1,1,(oDlg:nClientWidth/2)-15,(oDlg:nClientHeight/2)-160, , , , oDlg, , , , , , , , , , , , .F.,"ARRAY" ,.T.,,.F.,,)
	
	oBrowTmp:AddColumn(TCColumn():New( 'Item',			{|| aStru[oBrowTmp:nat,7] } ,,,,,,.F.,.F.,,,,.F.,))
	oBrowTmp:AddColumn(TCColumn():New( 'Data',			{|| aStru[oBrowTmp:nat,1] } ,,,,,,.F.,.F.,,,,.F.,))
	oBrowTmp:AddColumn(TCColumn():New( 'Hora',			{|| aStru[oBrowTmp:nat,2] } ,,,,,,.F.,.F.,,,,.F.,))
	oBrowTmp:AddColumn(TCColumn():New( 'Fatura',		{|| aStru[oBrowTmp:nat,5] } ,,,,,,.F.,.F.,,,,.F.,))
	oBrowTmp:AddColumn(TCColumn():New( 'Tempo Fatura',	{|| aStru[oBrowTmp:nat,3] } ,,,,,,.F.,.F.,,,,.F.,))
	oBrowTmp:AddColumn(TCColumn():New( 'Analista Linha',{|| aStru[oBrowTmp:nat,4] } ,,,,,,.F.,.F.,,,,.F.,))	
	
	oBrowTmp:setarray(aStru)
	oBrowTmp:refresh()
	oBrowTmp:bChange := {|| oTime:refresh(),oMemo:refresh(),oSim:refresh()  }

	++nLinha
	@ ++nLinha,1 Say "Indique o tempo correto" Pixel
	@ nLinha,2 msget oTime Var aStru[oBrowTmp:nat,3]  PICTURE "99:99" size 30,11 Pixel //WHEN ( cRealUser $ aStru[oBrowTmp:nat,4] )
	@ nLinha,3  say "" pixel
	@ nLinha,4  say "" pixel	

	@ ++nLinha,1 SAY "Fatura (S) ou (N) :" pixel
	@ nLinha,2 get oSim var aStru[oBrowTmp:nat,5] SIZE 20,11 Pixel valid ( aStru[oBrowTmp:nat,5] $ "S/N" )

	@ ++nLinha,1 SAY "Texto da linha:" pixel
	@ nLinha,2 get oMemo var aStru[oBrowTmp:nat,6] SIZE 170,35 readonly MEMO HSCROLL pixel	

	@ ++nLinha,1  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION (lOk := .t., oDlg:end())
	@ nLinha,2  BUTTON "Cancelar" SIZE 40,11 Pixel ACTION (oDlg:end())

	Activate MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
	
	If lOk .and. MsgYesNo("Confirmar tempos?")
		//U_SIMC020()
		ADE->( dbSetOrder(1) )
		ADE->( dbSeek(myxfilial("ADE") + retacols("CHAMADO",oBrow:nAt) ) )

		ADE->( RecLock(Alias(), .F.) )
		ADE->ADE_FATURA := M->ADE_FATURA
		ADE->( MsUnlock() )

		ADF->( dbSetOrder(1) )
		ADF->( dbSeek(myxfilial("ADF")+ADE->ADE_CODIGO) )
		nLinha := 1
		While ! ADF->( Eof() ) .AND. ADF->ADF_CODIGO  == ADE->ADE_CODIGO
			If ADF->ADF_ITEM > "001" .AND. ADF->ADF_CODSUQ $ PRODUCAO //cRealUser $ aStru[nLinha,4] .AND. 
				cText := Upper( AllTrim( MSMM(ADF->ADF_CODOBS) ) )
				If Len(cText) < 5  .OR. (Len(cText) < 30  .AND. ( "EM ATENDIMENTO" $ cText .OR. "EM ANALISE" $ cText .OR. "EM ANมLISE" $ cText .OR. "EM ANDAMENTO" $ cText))				
					MsgStop("Item " + ADF->ADF_ITEM + " Descri็ใo do item invalido para faturamento")				
					ADF->( RecLock(Alias(), .F.) )
					ADF->ADF_FATURA := " "
					ADF->( MsUnlock() )
				Else
					ADF->( RecLock(Alias(), .F.) )		
					//Anderson.Walter_120913_09h51 para fazer um anแlise para o chamado BAEHCY
					If !IsBlind() .And. ("-" $ aStru[nLinha,3] .Or. "*" $ aStru[nLinha,3])
						U_SIMMail(	"Falha no campo ADF_FATDUR",;
									"N๚mero do Chamado: "+M->ADE_FILIAL+"\"+M->ADE_CODIGO+" - "+ADF->ADF_ITEM+CRLF+;
										"Fun็ใo que estแ sendo executada: "+FunName()+CRLF+;
										"Fun็ใo que gerou o valor errado: "+"ADF->ADF_FATDUR := aStru["+StrZero(nLinha,3)+",3]"+CRLF+;
										"Valor que serแ gravado no campo: "+aStru[nLinha,3]+CRLF+;
										"Usuแrio Logado: "+CRLF+;
										"Uusแrio :"+Iif(Type("CUSERNAME") <> "U", CUSERNAME,"")+CRLF+;
										"Nome: "+Iif(Type("__CUSERID") <> "U",UsrFullName(__CUSERID),"")+CRLF+;
										"E-mail: "+Iif(Type("__CUSERID") <> "U", UsrRetMail(__CUSERID),"")+CRLF+;
										"Obs.: Esse e-mail ้ para anแlise do chamado BAEHCY",;
									GetMv("PS_BAEHCY"),,,)
					Endif
					ADF->ADF_FATDUR := aStru[nLinha,3]
//					ADF->ADF_FATURA := IF ( ADE->ADE_FATURA == "1","1", " ")
					ADF->ADF_FATURA := if ( aStru[nLinha,5] == "S","1", " ")
					ADF->( MsUnlock() )
				EndIf
			Else
				If aStru[nLinha,5] == "S"
					MsgStop("Item " + ADF->ADF_ITEM + " ou acao " + ADF->ADF_CODSUQ + " invalida")
				EndIf
				ADF->( RECLOCK(ALIAS(), .F.) )		
				//Anderson.Walter_120913_09h51 para fazer um anแlise para o chamado BAEHCY
				If !IsBlind() .And. ("-" $ aStru[nLinha,3] .Or. "*" $ aStru[nLinha,3])
					U_SIMMail(	"Falha no campo ADF_FATDUR",;
									"N๚mero do Chamado: "+M->ADE_FILIAL+"\"+M->ADE_CODIGO+" - "+ADF->ADF_ITEM+CRLF+;
									"Fun็ใo que estแ sendo executada: "+FunName()+CRLF+;
									"Fun็ใo que gerou o valor errado: "+"ADF->ADF_FATDUR := aStru["+StrZero(nLinha,3)+",3]"+CRLF+;
									"Valor que serแ gravado no campo: "+aStru[nLinha,3]+CRLF+;
									"Usuแrio Logado: "+CRLF+;
									"Uusแrio :"+Iif(Type("CUSERNAME") <> "U", CUSERNAME,"")+CRLF+;
									"Nome: "+Iif(Type("__CUSERID") <> "U",UsrFullName(__CUSERID),"")+CRLF+;
									"E-mail: "+Iif(Type("__CUSERID") <> "U", UsrRetMail(__CUSERID),"")+CRLF+;
									"Obs.: Esse e-mail ้ para anแlise do chamado BAEHCY",;
								GetMv("PS_BAEHCY"),,,)
				EndIf
				ADF->ADF_FATDUR := aStru[nLinha,3]
				ADF->ADF_FATURA := " "
				ADF->( MsUnlock() )
//				MsgStop("Item " + ADF->ADF_ITEM + " ou acao " + ADF->ADF_CODSUQ + " invalida")
			EndIf
			nLinha ++
			ADF->(dbSkip())
		EndDo
	EndIf
Else
	Alert( "Nenhum chamado encontrado para que seja feito o ajuste." )
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/23/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function strtoarray(cVar,cMark,cArea)
Local aArray := {}
Local nPos := 0
//fElapTime()
aadd(aArray,cArea)
While !Empty( cVar )
	nPos := at(cMark,cVar )
	if nPos > 0
		aadd(aArray, substr(cVar,1,nPos-1) )
		cVar := substr(cVar,npos+1 )
	else
		aadd(aArray, cVar)
		cVar := ""
	end
end
Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/23/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function StrToArra2( cVar, cMark )
Local aArray	:= {}
Local nPos		:= 0

Default cMark	:= ","

//fElapTime()

While !Empty( cVar )
	nPos := At( cMark, cVar )
	If nPos > 0
		AAdd(aArray, SubStr( cVar, 1, nPos - 1 ) )
		cVar := SubStr( cVar, npos + 1 )
	Else
		aadd(aArray, cVar)
		cVar := ""
	EndIf
EndDo

Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION TimeToSec(cTime)
Local nSec := 0
Local x
Local nPos := 0
Local cCalc := ""
//fElapTime()
if empty(cTime)
	cTime := ""
end
for x := 1 to 3
	nPos := at (":", cTime)
	if nPos > 0
		cCalc := substr(cTime,1, nPos -1 )
		cTime := substr( cTime , nPos + 1 )
	else
		cCalc := cTime
		cTime := ""
	end

	if x == 1
		nSec += val( cCalc )  * 3600 
	elseif x == 2
		nSec += val( cCalc )  * 60
	elseif x == 3
		nSec += val( cCalc )
	end
next
return nSec
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/27/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION TimeToMin(cTime)
Local nSec := 0
Local x
Local nPos := 0
Local cCalc := ""
//fElapTime()
	for x := 1 to 2
		nPos := at (":", cTime)
		if nPos > 0
			cCalc := substr(cTime,1, nPos -1 )
			cTime := substr( cTime , nPos + 1 )
		else
			cCalc := cTime
			cTime := ""
		end
	
		if x == 1
			nSec += val( cCalc )  * 60
		elseif x == 2
			nSec += val( cCalc )
		end
	next
return nSec


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  09/23/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddDebug( aTxt, lLimpa )
Static cTexto := ""
Local x

//fElapTime()

If lMostraDebug .and. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|"
	If !Empty( lLimpa )
		cTexto := ""
	EndIf
	
	If !Empty( aTxt )
		For x := 1 To Len( aTxt )
			If Len( cTexto ) < 700000
				cTexto += AllToChar( aTxt[ x ] ) + "|"
			EndIf
		Next
		cTexto += "-"
	End
	cTexto += "**" + CHR(10) + CHR(13)
End

Return cTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  09/28/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CodsProd( DataItem )
//Local cProducao := ""
// 2 = produtivo
// 1 = producao
// At้ o dia 08/08/2010.
//fElapTime()
If DataItem <= SToD( "20100808" )
	PRODUTIVO	:= PRODT_SSIM
	PRODUCAO	:= PRODC_SSIM
Else
	PRODUTIVO	:= PRODT_PHOENIX
	PRODUCAO	:= PRODC_PHOENIX
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function feriado(ddata)
//fElapTime() 
Return fferiado(myxfilial("SP3"),ddata) //lFeriado
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  01/31/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function mydebug(uVar)
Local cFile := "c:\log.txt"
Local nHand := 0
Local crlf := chr(13) + chr(10)
Local cBuff := ""
Static mynSec
Static mynSec2
//fElapTime()
if !Empty(lMostraDebug)
	if !file(cFile)
		fclose(fcreate(cFile))
	end
	if empty(mynSec)
		mynSec := seconds()
	end
	if empty(mynSec2)
		mynSec2 := seconds()
	end
	nHand := fOpen(cFile,66)
	if nHand >= 0
		fseek(nHand,0,2)
		cBuff += "Log iniciado data e hora : " + alltochar(date()) + " " + alltochar(time()) + crlf
		cBuff += "Gravando log linha       : " + alltochar(procline(1)) + crlf
		cBuff += "Conteudo passado         : " + alltochar(uVar) + crlf 
		cBuff += "Tempo passado            : " + alltochar(seconds()-mynSec) + crlf
		cBuff += "Tempo total              : " + alltochar(seconds()-mynSec2) + crlf
		cBuff += replicate("-",80)  + crlf
		qout(cBuff)
		if nHand >= 0
			fwrite(nHand,cBuff )
			fclose(nHand)
		end
		nSec := seconds()
	end
end

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/28/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// !empty(aTimeDif[1,6])
/*
	aTempos[1,1] := ADF->ADF_DATA
	aTempos[1,2] := ADF->ADF_HORA
	aTempos[1,3] := date()
	aTempos[1,4] := time()
	aTempos[1,5] := RetNomeOpera(ADF->ADF_CODSU7)
	aTempos[1,6] := tempo fechado

legenda(ADENEW->ADE_SEVCOD,"SEVCOD")	
ADENEW->ADE_SEVCOD


TENHO QUE RETORNAR VERDADEIRO PARA O CHAMADO ESTAR OK
A FUNCAO VALIDA SEMPRE OS CHAMADOS QUE ESTAO OK
se eu quiser que mostre tenho que retornar em verdadeiro

if !ValidCliFaixa(alltrim(retacols("CODCLI",,"")),"FAIXA1_TP")

ADENEW->ADE_CHAVE

RETORNA VERDADEIRO PARA NAO MOSTRAR O CHAMADO
// valida criticidade para o envio de workflow
*/
Static function validcritic(aTempos,cCodChamado,nFaixa)
Local lNaoMostra	:= .T. // NAO MOSTRA O CHAMADO
//fElapTime()
/*
Verifico o tempo na faixa escolhida se estแ invalido
*/


if empty(nFaixa)
	nFaixa := 1
end

if nFaixa == 1 .and. oChamado:lFaixa1//ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA1_TP",.T.)
	lNaoMostra := !Empty(aTimeDif[1,6]) // .T. ( CHAMADO ESTA FECHADO, OK )
	if lNaoMostra
		mydebug("Mostrando chamado faixa 1" + ADENEW->ADE_CODIGO)
	end
elseif nFaixa == 2 .and. aTimeDif[2,13] <> NIL .and. oChamado:lFaixa2//ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA2_TP",.T.) // faixa 2 mais a faixa 3
	// O CHAMADO ESTA NA DATA PARA MOSTRAR ?
	If aTimeDif[2,15] <> NIL // tenho inicio de tempo e estแ pendente sem fechar a faixa
	// SE EU JA TO TIRANDO PENDENTES = 10 OS CHAMADOS JA ESTAO PENDENTES COM O ANALISTA, NAO TENHO QUE VALIDAR NADA
//		aDtLimite := ochamado:aFaixa2 //somatime(aTimeDif[2,13],aTimeDif[2,14],aTimeDif[2,15]+CalcCritic("FAIXA2_TP",.t.))
		lNaoMostra := .F. //! ( date() >= aDtLimite[1]-2  .and. date() <= aDtLimite[1] )
		if lNaoMostra
			mydebug("Mostrando chamado faixa 2 " + ADENEW->ADE_CODIGO)
		end
	end
elseif nFaixa == 3 .and. aTimeDif[3,13] <> NIL .and. ochamado:lFaixa3 //ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA3_TP",.T.) // faixa 2 mais a faixa 3
	if ADENEW->ADE_SEVCOD <> "1" .and. empty( ADENEW->ADE_CHANEX )
		aDtLimite := oChamado:aFaixa3 //somatime(aTimeDif[3,13],aTimeDif[3,14],CalcCritic("FAIXA3_TP",.t.))
		// dtlimit             x
		// date()    1 2 3 y 5 6 7 8 9 10
		//            .f.     .t.     .t.
		//ADF->ADF_DATA >= aFiltros[DATADE] .AND. ADF->ADF_DATA <= aFiltros[DATAATE]
		// inverte
		lNaoMostra := .F. //! ( date() >= aDtLimite[1]-2 ) // .and. date() <= aDtLimite[1] 
		if lNaoMostra
			mydebug("Mostrando chamado faixa 3 " + ADENEW->ADE_CODIGO)
		end
	end
elseif nFaixa == 4 .and. oChamado:lFaixa1 //ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA1_TP",.T.)
	// se tem faixa 1 mostra o chamado pendente do cliente
	lNaoMostra := .F.
end
//final( alltochar(nFaixa) + " " + alltochar(oChamado:lFaixa1) )

Return lNaoMostra

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  07/20/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static function SomaTime(ddata,cTime,uSoma)
Local dataini		:= date()
Local horaini		:= seconds()
Local nDiaSemana	:= 1 // 1 - domingo 7 - sabado
Local lSextaFeira	:= .F.
Local n8Horas		:= timetosec(CBATIDA1) - 1 //28800 - 1 //08*60*60
Local n12Horas		:= timetosec(CBATIDA2) //43200 //12*60*60
Local n1330Horas	:= timetosec(CBATIDA3) - 1 // 48600  - 1 //13*60*60 + 30*60
Local n18Horas		:= timetosec(CBATIDA4) // 64800 //18*60*60
Local n830Horas		:= 30600 //08*60*60  + 30*60
Local n130Horas		:= 5400  // 1*60*60 + 30*60
Local nSoma 		:= 0
//fElapTime()
/*VERIFICAR QUANDO O CHAMADO ษ ABERTO ANTES DO ALMOCO E A SOMA PASSA DO ALMOCO, TA SOMANDO MAIS DE 12 HORAS*/
If !empty(ddata)
	dataini := ddata
end
If !empty(ctime)
	horaini := timetosec( ctime )
end
If !empty(usoma)
	if valtype(usoma) == "C"
		nSoma := timetosec( usoma )
	elseif valtype(usoma) == "N"
		nSoma := usoma // deve ser os segundos
	end
end

lSextaFeira := ( dow(dataini) == 6 )

// se foi no final de semana o horario inicial ้ sempre a primeira batida
nDiaSemana := dow(dataini)
if ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) )
	horaini := n8Horas
end

// se a entrada estiver errada eu acerto
if 	horaini >= n18Horas
	horaini := n8Horas
	dataini++
end

if 	horaini <= n8Horas
	horaini := n8Horas
end


if 	horaini >= n12Horas .and. horaini < n1330Horas // 13:30
	horaini := n1330Horas
end


// TENTO REMOVER OS DIAS ATษ O LIMITE DE
While nSoma >= n830Horas
	dataini++
	nDiaSemana := dow(dataini)
	if ! ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) ) 		
		nSoma -= n830Horas
	end
end

horaini += nSoma

if 	horaini >= n18Horas
	horaini -= n18Horas
	horaini += n8Horas 
	dataini++
	nDiaSemana := dow(dataini)
	While ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) )
		dataini++	
		nDiaSemana := dow(dataini)
	end
end

if 	horaini >= n12Horas .and. horaini < n1330Horas // 13:30
	horaini += n130Horas
end

if 	horaini <= n8Horas
	horaini += n8Horas
end
nDiaSemana := dow(dataini)
While ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dataini) )
	dataini++
	nDiaSemana := dow(dataini)
end


horaini := nToTime(horaini)

return { dataini, horaini } 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  07/21/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CalcCritic(cNomeCol,lCampo)
Local cCritic := if ( empty( lCampo) , substr( retacols("CRITIC_CHM",,"1"), 1, 1 ), ADENEW->ADE_SEVCOD )

Local cTempoAtende := ""
//fElapTime()
if cNomeCol == "FAIXA1_TP"
	cTempoAtende := GetCalcFxs( "TMP1ATDE" )
elseif cNomeCol == "FAIXA2_TP"
	if cCritic $ "5,4"
		cTempoAtende := GetCalcFxs( "F2_ALT_URG" )
	elseif cCritic $ "3"
		cTempoAtende := GetCalcFxs( "F2_MED" )
	elseif cCritic $ "2,1"
		cTempoAtende := GetCalcFxs( "F2_BAIXA" )
	end
elseif cNomeCol == "FAIXA3_TP"
	if cCritic $ "5,4"
		cTempoAtende := GetCalcFxs( "F3_ALT_URG" )
	elseif cCritic $ "3"
		cTempoAtende := GetCalcFxs( "F3_MED" )
	elseif cCritic $ "2"
		cTempoAtende := GetCalcFxs( "F3_BAIXA" )
	elseif cCritic $ "1"
		cTempoAtende := ""
	end
elseif cNomeCol == "FAIXA4_TP"
	if cCritic $ "5,4"
		cTempoAtende := GetCalcFxs( "F3_FSW_ALT_URG" )
	elseif cCritic $ "3"
		cTempoAtende := GetCalcFxs( "F3_FSW_MED" )
	elseif cCritic $ "2"
		cTempoAtende := GetCalcFxs( "F3_FSW_BAIXA" )
	elseif cCritic $ "1"
		cTempoAtende := ""
	end	
end

Return timetosec(cTempoAtende)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/30/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Parametros()
Local x
Local cMemo := ""
Local lOk := .f.
/*
aFiltros[INDICE] 		:= space(1)
aFiltros[CONDICAO]		:= space(1)
aFiltros[ORDEM] 		:= space(1)
aFiltros[QUEBRA]		:= .T.
aFiltros[AGRUPA]		:= .F.
aFiltros[NSTATUS]		:= space(1)
aFiltros[EQUIPEDE] 		:= space(2)
aFiltros[EQUIPEATE] 	:= space(2)
aFiltros[CLIENTE]		:= space(100)
aFiltros[TECNICO]		:= space(100)
aFiltros[DATADE]		:= stod( strzero( year(ddatabase),4 ) + strzero( month(ddatabase),4 ) + "01" )
aFiltros[DATAATE]		:= ddatabase
aFiltros[AUTOSAVE]		:= .T.
aFiltros[PESQUISATEXTO]	:= .F.
aFiltros[QUERY]			:= ""
aFiltros[PRODUTO]		:= SPACE(20)
aFiltros[ROTINA]		:= SPACE(20)
aFiltros[CRITICIDADE]	:= SPACE(20)
aFiltros[SOLUCAO]		:= SPACE(1)
*/
//fElapTime()
cMemo += "Filtro Utilizado" + CRLF
//cMemo += "Query usada " + aFiltros[QUERY] + CRLF
//cMemo += "Processa os textos " + alltochar(Proc_Texto()) + CRLF
cMemo += "Tipo pendencia	:" + aFiltros[NSTATUS] + CRLF
cMemo += "Equipe filtrada	:" + aFiltros[EQUIPEATE] + CRLF
cMemo += "Cliente " + aFiltros[CLIENTE] + CRLF

cMemo += "Analista			:" + aFiltros[TECNICO] + CRLF
cMemo += "Analistas			:" + cFiltraGrupos + CRLF

cMemo += "Data de			:" + alltochar(aFiltros[DATADE]) + CRLF
cMemo += "Data ate			:" + alltochar(aFiltros[DATAATE]) + CRLF

cMemo += cTextFil2 + CRLF

cMemo += "lQueryNew=" + AllToChar( lQueryNew ) + CRLF
cMemo += "cDiasVolta=" + cDiasVolta + CRLF
cMemo += "lUsaZ26Clc=" + AllToChar( lUsaZ26Clc ) + CRLF
cMemo += "lBetween=" + AllToChar( lBetween ) + CRLF
cMemo += "lParaEmail=" + AllToChar( lParaEmail ) + CRLF
cMemo += "lNwFiltros=" + AllToChar( lNwFiltros ) + CRLF
cMemo += "Jobs =" + AllToChar( nMaxJob ) + CRLF
cMemo += "Quantidade de linhas =" + AllToChar( nDivide ) + CRLF

DEFINE MSDIALOG oDlg FROM 0,0 TO oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 TITLE "Parametros Utilizados" PIXEL
@ 0, 0  get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 MEMO HSCROLL pixel
NlINHA := (oDlg:nClientHeight/2)-35
nColuna := 10
	oGet:lreadonly := .T.
@ NlINHA,nColuna BUTTON "Fechar" SIZE 50,10 Pixel ACTION ( ODLG:end() )
ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function addlinha(nChamados)
local x,nPos,cVar,cCampo,dAbert
//fElapTime()
addblank()
ADDValor("FILIAL",substr(aChamados[nChamados],1,2))
/*LEMBRETE SEMPRE POSICIONAR OUTROS ALIAS QUE ESTIVEREM PARA APARECER COMO CAMPO*/
IF !empty(ADENEW->ADE_FNC) .or. !Empty(ADENEW->ADE_CHANEX)
	IF Empty(ADENEW->ADE_CHANEX)
		QI2->(dbseek(myxfilial("QI2")+ADENEW->ADE_FNC+"zz",.T.))
		QI2->(DBSKIP(-1))
		QI3->(dbseek(myxfilial("QI3")+ADENEW->ADE_FNC+QI2->QI2_REV))
	ELSE
		QI2->(dbseek(myxfilial("QI2")+ADE->ADE_FNC+"zz",.T.))
		QI2->(DBSKIP(-1))
		QI3->(dbseek(myxfilial("QI3")+ADE->ADE_FNC+QI2->QI2_REV))
   	END

	//Daniel
	QI5->(dbseek(myxfilial("QI5")+QI3->(QI3_CODIGO+QI3_REV)+"ZZ",.T.))
	QI5->(DBSKIP(-1))
end
For x := 1 to len(aStruTmp)
//AADD(ASTRU,{"CHAMADO"	,"C",20,0,"CHAMADO"					,.F.,.F.,.T.,"C",.F.,.T.,.T.,.F.,"ADE_CODIGO",""})
	if len(aStruTmp[x]) >= 14
		cCampo := aStruTmp[x,14]
		cVar := aStruTmp[x,1]
		if !Empty(cCampo)
			if "ADE_" $ cCampo .and. ADENEW->(type(cCampo)) <> "U"
				ADDValor(cVar,ADENEW->(&(cCampo)))
			elseif "ADF_" $ cCampo .and. ADF->(type(cCampo)) <> "U"
				ADDValor(cVar,ADF->(&(cCampo)))
			elseif "QI2_" $ cCampo .and. QI2->(type(cCampo)) <> "U"
				ADDValor(cVar,QI2->(&(cCampo)))
			end
		end
	end
next

ADDValor("FNCDTPREV","")
ADDValor("FNCPRIOR","")
ADDValor("FNCREVISAO","")
ADDValor("FNCSTATUS","")

/*
ADDValor("FNC_ETAPA","")//Daniel
ADDValor("MIN_FX1",0)//Daniel
ADDValor("MIN_FX2",0)//Daniel
ADDValor("MIN_FX3",0)//Daniel
ADDValor("MIN_FX4",0)//Daniel
ADDValor("TEMPO_COR","")//Daniel
ADDValor("SITUAC_COR","SEM PRAZO")//Daniel
*/

ADDValor("FNCREJE","")

ADDValor("FNCCATEG","")
		
		
ADDValor("VERSAO",alltrim(ADENEW->ADE__VERSA))
ADDValor("FATURA",legenda( ADENEW->ADE_FATURA,"FATURA" ))
ADDValor("TEMPOFAT",cTotFat)

ADDValor("AN_ASSUNT", ALLTRIM( ADENEW->ADE_ASSUNT ) + "-" + ALLTRIM(myPOSICIONE("ZO0",1,myxfilial("ZO0")+ADENEW->ADE_ASSUNT,"ZO0_DESC"))	 )

ADDValor("ROTINA",validarotina( ADENEW->ADE__ZLCRO ) )


ADDValor("ADE_NOMREP",upper( ALLTRIM(myPosicione("SU5",1,myxfilial("SU5")+ADENEW->ADE_CODREP,"U5_CONTAT") ) ))
ADDValor("ADE_EMAREP",upper( ALLTRIM(myPosicione("SU5",1,myxfilial("SU5")+ADENEW->ADE_CODREP,"U5_EMAIL") ) ))

ADDValor("EMAIL",;
strtran( ALLTRIM(ADENEW->ADE_EMAIL) + ";"+ALLTRIM(myPosicione("SU5",1,myxfilial("SU5")+ADENEW->ADE_CODCON,"U5_EMAIL")) , ";" , "/"))

ADDValor("MODULO",ADENEW->ADE_CODSB1)
ADDValor("CRITIC_CHM",legenda(ADENEW->ADE_SEVCOD,"SEVCOD"))

ADDValor("DABERTURA",ADENEW->ADE_DATA)
ADDValor("HDABERT",ADENEW->ADE_HORA)
ADDValor("DT_ULT_MOV", dUltDtMov )
ADDValor("PROBLEMA",cMemo)

IF aFiltros[NSTATUS] == "Pesquisar Ocorrencia"
	ADDValor("SOLUCAO",cMemoSol)
ELSE
	IF aFiltros[SOLUCAO] <> "Total"
		cMemoSol := ""
		if len(aMemoSol)-2 > 1
			cMemoSol := aMemoSol[len(aMemoSol)-1] + CRLF
			cMemoSol += replicate("-",95) + CRLF
			cMemoSol += aMemoSol[len(aMemoSol)]
		end
		if len(aMemoSol) == 1
			cMemoSol := aMemoSol[len(aMemoSol)]
		end
		if !Empty(cMemoSol)
			cMemoSol := "... ** TEXTO PARCIAL COM ULTIMA ANALISE ** " + CRLF + CRLF + cMemoSol
		end
		ADDValor("SOLUCAO",cMemoSol)
	else
		ADDValor("SOLUCAO",cMemoSol)
	end
END

ADDValor("TXT_TRUE",if(lFoundtxt,alltrim(cTexto1),"") +if(lFoundtxt.AND. lFoundtxt2,"/","")+if(lFoundtxt2,alltrim(cTexto2),"") )		
ADDValor("FNC",ADENEW->ADE_FNC) //ADE_FNC procurar a fnc

if aFiltros[NSTATUS] <> "Pesquisar Ocorrencia"
	ADDValor("DT_ORIG_AB",ADENEW->ADE_DATA )
	if upper(substr(ADENEW->ADE_PLVCHV,1,6)) == "INCLUS"
		ADDValor("RESUMO",msmm(ADENEW->ADE_CODINC) )
	else
		ADDValor("RESUMO",ADENEW->ADE_PLVCHV )
	end
	ADDValor("DESCAB",msmm(ADENEW->ADE_CODINC) )
	
	ADDValor("MSTATUS",legenda(ADENEW->ADE__ENTPE))
	// procurar o chamado pai
	if !Empty(ADENEW->ADE_CHANEX)
		ADE->(DBSEEK(myxfilial("ADE")+ADENEW->ADE_CHANEX))
		While !Eof() .and. !Empty(ADE->ADE_CHANEX) .and.  ADE->ADE_CHANEX <> ADENEW->ADE_CHANEX
			ADE->( dbseek(myxfilial("ADE")+ADE->ADE_CHANEX) )
		end
/*STATUS
1 - Em Aberto
2 - Pendente
3 - Encerrado
*/
		ADDValor("FNCDIVERGE",IF( (ADENEW->ADE_STATUS $"12") <> (ADE->ADE_STATUS$"12"),"DIVERGENTE","OK") )
	end

	ADDValor("FNCASSOC",ADENEW->ADE_CHANEX) //ADE_FNCa procurar a fnca

	IF !empty(ADENEW->ADE_FNC) .or. !Empty(ADENEW->ADE_CHANEX)
		/*JA FOI POSICIONADO O ALIAS, NAO EH NECESSARIO REFAZER*/
		IF Empty(ADENEW->ADE_CHANEX)
			QI2->(dbseek(myxfilial("QI2")+ADENEW->ADE_FNC+"zz",.T.))
			QI2->(DBSKIP(-1))
			QI3->(dbseek(myxfilial("QI3")+ADENEW->ADE_FNC+QI2->QI2_REV))
		ELSE
			ADDValor("FNC",ADE->ADE_FNC) //FNC PAI
			QI2->(dbseek(myxfilial("QI2")+ADE->ADE_FNC+"zz",.T.))
			QI2->(DBSKIP(-1))
			QI3->(dbseek(myxfilial("QI3")+ADE->ADE_FNC+QI2->QI2_REV))
		END
		//Daniel
		QI5->(dbseek(myxfilial("QI5")+QI3->(QI3_CODIGO+QI3_REV)+"ZZ",.T.))
		QI5->(DBSKIP(-1))
		ADDValor("FNCDTPREV",QI2->QI2_CONPRE)
		ADDValor("FNCPRIOR",legenda(QI2->QI2_PRIORI,"PRIO"))
		ADDValor("FNCREVISAO",QI2->QI2_REV)
		ADDValor("FNCSTATUS",LEGENDA(QI2->QI2_STATUS,"STATUS"))
		ADDValor("FNC_ETAPA",QI5->QI5_TPACAO)//Daniel

		ADDValor("FNCREJE",if( QI2->QI2_STATUS $ "45","S","N" ) )
		
		ADDValor("FNCCATEG",alltrim(QI2->QI2_CODCAT) + "-" + ALLTRIM(myPOSICIONE("QI0",2,myxfilial("QI0")+alltrim(QI2->QI2_CODCAT),"QI0_DESC")) )
		
	end

	if !Empty(ADENEW->ADE_OPERAD)
		ADDValor("AN_ATUAL",ALLTRIM(upper(myPOSICIONE("SU7",1,MyXfilial("SU7")+ADENEW->ADE_OPERAD,"U7_NOME"))	))
	end

	ADDValor("TP_COMUNIC",ALLTRIM(myPOSICIONE("SUL",1,myxfilial("SUL")+ADENEW->ADE_TIPO,"UL_DESC")))
	ADDValor("DT_SLO",ALLTOCHAR(ADENEW->ADE_DTEXPI))
	if ADENEW->( ADE__ENTPE $ "10,30")
		ADDValor("DT_SLOVENC",ALLTOCHAR(date() - ADENEW->ADE_DTEXPI))
	else
		IF !eMPTY(aTimeDif[1,3])
			ADDValor("DT_SLOVENC",ALLTOCHAR(aTimeDif[1,3] - ADENEW->ADE_DTEXPI))
		else
			ADDValor("DT_SLOVENC",ALLTOCHAR(date() - ADENEW->ADE_DTEXPI))			
		end
	end
	//campos de data para agenda do N2
	if !Empty(ADENEW->ADE_GRUPO)
		ADDValor("GRUPO",ADENEW->ADE_GRUPO +" - " + ALLTRIM( myPOSICIONE("SU0",1,myxfilial("SU0")+ADENEW->ADE_GRUPO,"U0_NOME") ) )
	end
	ADDValor("CODPRIV", IstPrivate(ADENEW->ADE_CHAVE) )

	
	cNome := upper(alltrim(myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_NOME") ))
	if empty(cNome)
		cNome := "REGISTRO NAO ENCONTRADO - "  + ADENEW->ADE_CHAVE
	end
	ADDValor("CLIENTE",cnome )
	if empty(cCliEmail)
		cCliEmail := ALLTRIM(ADENEW->ADE_CHAVE)+" - " + ALLTRIM(myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_NOME"))
	end
	cContato := upper( ALLTRIM(myPosicione("SU5",1,myxfilial("SU5")+ADENEW->ADE_CODCON,"U5_CONTAT") ) )
	cContato := ALLTRIM(ADENEW->ADE_CHAVE) + "-" + cContato
	ADDValor("CONTATCLI",  cContato )
	
	ADDValor("DESCROT",ALLTRIM(myPosicione("ZLC",1,myxfilial("ZLC")+ADENEW->ADE__ZLCRO,"ZLC_NOME") ))
	

	
	IF !eMPTY(ADENEW->ADE__PAIS)
		ADDValor("CODPAIS", ADENEW->ADE__PAIS + " - " + ALLTRIM(myPosicione("SYA",1,myxfilial("SYA")+ADENEW->ADE__PAIS,"YA_DESCR") ))
	END
	
	ADDValor("ACAO",ADF->ADF_CODSUQ +"-" + ALLTRIM(myPosicione("SUQ",1,myxfilial("SUQ")+ADF->ADF_CODSUQ,"UQ_DESC")))
	ADDValor("OCORRE",ADF->ADF_CODSU9 +"-" + ALLTRIM(myPosicione("SU9",2,myxfilial("SU9")+ADF->ADF_CODSU9,"U9_DESC")))
	
	ADDValor("DT_ULT_MOV", dUltDtMov )
	ADDValor("H_ULT_MOV",cUltHrMov)
	if ADENEW->ADE__ENTPE $ "10/30/90"
		
		ADDValor("DIAS_S_MOV",difdias(ddatabase,dUltDtMov))
		dAbert:= IF(!empty(aTimeDif[1,1]),(aTimeDif[1,1]),ADE->ADE_DATA)
		ADDValor("DIASQABRIU",difdias(ddatabase,dAbert))

	end
	cCodCausa := cEmBranco
	IF !Empty( ADENEW->ADE_CODCAU )
		cCodCausa := ADENEW->ADE_CODCAU +"-"+ ALLTRIM(myPosicione("QI0",2,myxfilial("QI0")+ADENEW->ADE_CODCAU,"QI0_DESC") )
	end
	ADDValor("CAUSA",cCodCausa )
	
	if empty(cAreaAnalista)
		cAreaAnalista := cEmBranco
	end
	ADDValor("AN_NOMES",RetNomeOpera(cOpera) )
	cAnArea := RetAnArea( cAnalistaAloc ,dDataAnalista )

	if empty(cAnArea)
		cAnArea := cEmBranco
	end

	ADDValor("AN_ULTIMO", cAnalistaAloc )
	ADDValor("AN_AREA", cAreaAnalista )
	

	ADDValor("AN_CODS",cOpera)
	if empty(cRetOperaSla)
		cRetOperaSla := cEmBranco
	end

	ADDValor("PRODUCAO",nTotProducao)
	ADDValor("PRODUTIVID",nTotProdutivo)

	ADDValor("REABERTURAS",nReaberturas)
	ADDValor("REJEICOES",nRejeicoes)
	
	ADDValor("ANA_VALID_FAIXA",cAnValid)

	addvalor("DT_ULT_ATD",dUltDtATD)
	addvalor("HR_ULT_ATD",cUltHrATD)
	
	aRisco := {}
	nTimedif := 1

	cTimeDif := oChamado:cFaixa1

	if substr(cTimeDif,3,2) >= "01"
		nTimedif := 2
	end
	if substr(cTimeDif,3,2) >= "08"
		nTimedif := 3
	end
	aadd(aRisco,nTimedif)
	if lCalculaSla
		if !Empty(aTimeDif[1,3])
			ADDValor("FAIXA1_DT",aTimeDif[1,1])
			ADDValor("FAIXA1_HR",aTimeDif[1,2])
			ADDValor("FAIXA1_NM",aTimeDif[1,5])									
		END
		//FAIXA1
	
		if !oChamado:lFaixa1//ValidCliFaixa(retacols("CODCLI",,""),"FAIXA1_TP")
		  	ADDValor("FAIXA1_SIT",NOT_CONTRATO_SLA)
			ADDValor("FAIXA1_TP",NOT_CONTRATO_SLA)
		else
			IF EMPTY(cTimeDif)
				ADDValor("FAIXA1_SIT",NOT_EXIST_SLA)
				ADDValor("FAIXA1_TP",NOT_EXIST_SLA)
			ELSEif cTimeDif = "0000:00:00"
				ADDValor("FAIXA1_SIT",OUT_TIME_SLA)
				ADDValor("FAIXA1_TP",OUT_TIME_SLA)

				if !Empty(aTimeDif[1,13])
					aDtLimite := oChamado:aFaixa1//somatime(aTimeDif[1,1],aTimeDif[1,2],CalcCritic("FAIXA1_TP"))
					ADDValor("FAIXA1_DTL",aDtLimite[1])
					ADDValor("FAIXA1_HRL",aDtLimite[2])
				end
				
			ELSE
				if !Empty(aTimeDif[1,13])
					aDtLimite := oChamado:aFaixa1// somatime(aTimeDif[1,1],aTimeDif[1,2],CalcCritic("FAIXA1_TP"))
					ADDValor("FAIXA1_DTL",aDtLimite[1])
					ADDValor("FAIXA1_HRL",aDtLimite[2])
				end
				cValidCampo := validacampo("FAIXA1_TP", cTimeDif)
				IF "ACIMA" $ cValidCampo
					ADDValor("FAIXA1_TP",cTimeDif)
					ADDValor("FAIXA1_TPM",timetomin(cTimeDif))							
					ADDValor("FAIXA1_SIT",OFF_TIME_SLA)

					if calculaSlaMensal(aDtLimite[1])
						aTotaisSla[1]++
						aTotaisSla[2]++
					END
				ELSEIF "ATE " $ cValidCampo
					ADDValor("FAIXA1_TP",cTimeDif)
					ADDValor("FAIXA1_TPM",timetomin(cTimeDif))
					ADDValor("FAIXA1_SIT",ON_TIME_SLA)
					if calculaSlaMensal(aDtLimite[1])
						aTotaisSla[2]++
					end
				ELSEIF TIME_TO_END $ cValidCampo
					ADDValor("FAIXA1_TP",cTimeDif)
					ADDValor("FAIXA1_TPM",timetomin(cTimeDif))
					ADDValor("FAIXA1_SIT",TIME_TO_END)
					/*
					if calculaSlaMensal(aTimeDif[1,3])
						aTotaisSla[2]++
					end*/
				END
			end
		end
		//FAIXA2

		cTimeDif := oChamado:cFaixa2
		if !Empty(aTimeDif[2,3])
			ADDValor("FAIXA2_DT",aTimeDif[2,3])
			ADDValor("FAIXA2_HR",aTimeDif[2,4])
			ADDValor("FAIXA2_NM",aTimeDif[2,5])					
		end
		if !oChamado:lFaixa2//ValidCliFaixa(retacols("CODCLI",,""),"FAIXA2_TP")
		  	ADDValor("FAIXA2_SIT",NOT_CONTRATO_SLA)
			ADDValor("FAIXA2_TP",NOT_CONTRATO_SLA)
        else
			IF EMPTY(cTimeDif)
				ADDValor("FAIXA2_SIT",NOT_EXIST_SLA)
				ADDValor("FAIXA2_TP",NOT_EXIST_SLA)
            elseIF cTimeDif = "0000:00:00"
				ADDValor("FAIXA2_SIT",OUT_TIME_SLA)
				ADDValor("FAIXA2_TP",OUT_TIME_SLA)

				IF !eMPTY(aTimeDif[2,13])
					aDtLimite := oChamado:aFaixa2//somatime(aTimeDif[2,13],aTimeDif[2,14],aTimeDif[2,15]+CalcCritic("FAIXA2_TP"))
					ADDValor("FAIXA2_DTL",aDtLimite[1])
					ADDValor("FAIXA2_HRL",aDtLimite[2])
				end
				
        	else
				IF !eMPTY(aTimeDif[2,13])
					aDtLimite := oChamado:aFaixa2//somatime(aTimeDif[2,13],aTimeDif[2,14],aTimeDif[2,15]+CalcCritic("FAIXA2_TP"))
					
					ADDValor("FAIXA2_DTL",aDtLimite[1])
					ADDValor("FAIXA2_HRL",aDtLimite[2])
					ADDValor("FAIXA2_TPC",nToTime( aTimeDif[2,15] ) )

				end
				cValidCampo := validacampo("FAIXA2_TP", cTimeDif)
				IF "ACIMA" $ cValidCampo
					ADDValor("FAIXA2_TP",cTimeDif)
					ADDValor("FAIXA2_TPM",timetomin(cTimeDif))							
					ADDValor("FAIXA2_SIT",OFF_TIME_SLA)
					if calculaSlaMensal(aDtLimite[1])
			        	aTotaisSla[3]++
			        	aTotaisSla[4]++
			  		end
				ELSEIF "ATE " $ cValidCampo
					ADDValor("FAIXA2_TP",cTimeDif)
					ADDValor("FAIXA2_TPM",timetomin(cTimeDif))							
					ADDValor("FAIXA2_SIT",ON_TIME_SLA)
					if calculaSlaMensal(aDtLimite[1])
						aTotaisSla[4]++
					end
				ELSEIF TIME_TO_END $ cValidCampo
					ADDValor("FAIXA2_TP",cTimeDif)
					ADDValor("FAIXA2_TPM",timetomin(cTimeDif))							
					ADDValor("FAIXA2_SIT",TIME_TO_END)
				END
			ENDif
		END

		//FAIXA3

		cTimeDif := oChamado:cFaixa3
		if !Empty(aTimeDif[3,1])
			IF !eMPTY(aTimeDif[3,3])
				ADDValor("FAIXA3_DT",aTimeDif[3,3])
			END
			ADDValor("FAIXA3_HR",aTimeDif[3,4])
			ADDValor("FAIXA3_AB",aTimeDif[3,1])
			ADDValor("FAIXA3_ABH",aTimeDif[3,2])
			ADDValor("FAIXA3_NM",aTimeDif[3,5])
		END
		// CLIENTE POSSUI CONTRATO NA FAIXA 3?
		IF  !oChamado:lFaixa3//ValidCliFaixa(retacols("CODCLI",,""),"FAIXA3_TP")
			ADDValor("FAIXA3_SIT",NOT_CONTRATO_SLA)
			ADDValor("FAIXA3_TP",NOT_CONTRATO_SLA)
		ELSE
			//	cCateg		:= substr(retacols("FNCCATEG",,""),1,6)
			//	cFncAssoc	:= retacols("FNCASSOC")
			//	retacols("FNCREJE") == "S"
			/*SE INCLUI OU NAO O CHAMADO NAS CONTAGENS DO TEMPO DE SLA OU NAO*/
			lSomaFnc := empty( retacols("FNCASSOC") ) .and. ! ( retacols("FNCREJE") == "S" )
			
			IF EMPTY(retacols("FNC")) .OR. empty(cTimeDif) .OR. !empty( retacols("FNCASSOC") )
				ADDValor("FAIXA3_SIT",NOT_EXIST_SLA)
				ADDValor("FAIXA3_TP",NOT_EXIST_SLA)
				If empty( retacols("FNCASSOC"))
					ADDValor("FAIXA3_AB","")
					ADDValor("FAIXA3_ABH","")
				End
			ElseIf cTimeDif = "0000:00:00"			
				ADDValor("FAIXA3_SIT",OUT_TIME_SLA)
				ADDValor("FAIXA3_TP",OUT_TIME_SLA)
			ElseIf ( retacols("FNCREJE") == "S" .and. substr( retacols("CRITIC_CHM",,"1"), 1, 1 ) <> "1" )
				aDtLimite := oChamado:aFaixa3//somatime(aTimeDif[3,13],aTimeDif[3,14],CalcCritic("FAIXA3_TP"))
				ADDValor("FAIXA3_DTL",aDtLimite[1])
				ADDValor("FAIXA3_HRL",aDtLimite[2])						
				ADDValor("FAIXA3_SIT",REJECT)
				ADDValor("FAIXA3_TP",REJECT)
			ELSE
				cValidCampo := validacampo("FAIXA3_TP", cTimeDif)
				IF "ACIMA" $ cValidCampo
					ADDValor("FAIXA3_TP",cTimeDif)
					ADDValor("FAIXA3_TPM",timetomin(cTimeDif))							
					ADDValor("FAIXA3_SIT",OFF_TIME_SLA)
					if !Empty(aTimeDif[3,13])
						aDtLimite := oChamado:aFaixa3//somatime(aTimeDif[3,13],aTimeDif[3,14],CalcCritic("FAIXA3_TP"))
						ADDValor("FAIXA3_DTL",aDtLimite[1])
						ADDValor("FAIXA3_HRL",aDtLimite[2])
					end
					if lSomaFnc .and. calculaSlaMensal(aDtLimite[1])
						aTotaisSla[5]++
						aTotaisSla[6]++
					end
				ELSEIF "ATE " $ cValidCampo
					ADDValor("FAIXA3_TP",cTimeDif)
					ADDValor("FAIXA3_SIT",ON_TIME_SLA)
					if !Empty(aTimeDif[3,13])
						aDtLimite := oChamado:aFaixa3//somatime(aTimeDif[3,13],aTimeDif[3,14],CalcCritic("FAIXA3_TP"))
						ADDValor("FAIXA3_DTL",aDtLimite[1])
						ADDValor("FAIXA3_HRL",aDtLimite[2])
					end
					if lSomaFnc .and. calculaSlaMensal(aDtLimite[1])
						aTotaisSla[6]++
					end
					ADDValor("FAIXA3_TPM",timetomin(cTimeDif))
				ELSEIF TIME_TO_END $ cValidCampo
					ADDValor("FAIXA3_TP",cTimeDif)
					ADDValor("FAIXA3_SIT",TIME_TO_END)
					if !Empty(aTimeDif[3,13])
						aDtLimite := oChamado:aFaixa3//somatime(aTimeDif[3,13],aTimeDif[3,14],CalcCritic("FAIXA3_TP"))
						ADDValor("FAIXA3_DTL",aDtLimite[1])
						ADDValor("FAIXA3_HRL",aDtLimite[2])
					end
					ADDValor("FAIXA3_TPM",timetomin(cTimeDif))
				ELSEIF NOT_EXIST_SLA $ cValidCampo
					ADDValor("FAIXA3_TP",NOT_EXIST_SLA)
					ADDValor("FAIXA3_SIT",NOT_EXIST_SLA)
				END
			END
		end
		//FAIXA4 - FSW (fabrica)

		cTimeDif := oChamado:cFAIXA4
		if !Empty(aTimeDif[4,1])
			IF !eMPTY(aTimeDif[4,3])
				ADDValor("FAIXA4_DT",aTimeDif[4,3])
			END
			ADDValor("FAIXA4_HR",aTimeDif[4,4])
			ADDValor("FAIXA4_AB",aTimeDif[4,1])
			ADDValor("FAIXA4_ABH",aTimeDif[4,2])
			ADDValor("FAIXA4_NM",aTimeDif[4,5])
		END
		// CLIENTE POSSUI CONTRATO NA Faixa 3Fsw?
		IF  !oChamado:lFAIXA4//ValidCliFaixa(retacols("CODCLI",,""),"FAIXA4_TP")
			ADDValor("FAIXA4_SIT",NOT_CONTRATO_SLA)
			ADDValor("FAIXA4_TP",NOT_CONTRATO_SLA)
		ELSE
		
		IF empty(cTimeDif)
			ADDValor("FAIXA4_SIT",NOT_EXIST_SLA)
			ADDValor("FAIXA4_TP",NOT_EXIST_SLA)
		ElseIf cTimeDif = "0000:00:00"			
			ADDValor("FAIXA4_SIT",OUT_TIME_SLA)
			ADDValor("FAIXA4_TP",OUT_TIME_SLA)
		ELSE
			cValidCampo := validacampo("FAIXA4_TP", cTimeDif)
			IF "ACIMA" $ cValidCampo
				ADDValor("FAIXA4_TP",cTimeDif)
				ADDValor("FAIXA4_TPM",timetomin(cTimeDif))							
				ADDValor("FAIXA4_SIT",OFF_TIME_SLA)
				if !Empty(aTimeDif[4,13])
					aDtLimite := oChamado:aFAIXA4//somatime(aTimeDif[4,13],aTimeDif[4,14],CalcCritic("FAIXA4_TP"))
					ADDValor("FAIXA4_DTL",aDtLimite[1])
					ADDValor("FAIXA4_HRL",aDtLimite[2])
				end
				if calculaSlaMensal(aDtLimite[1])
					aTotaisSla[7]++
					aTotaisSla[8]++
				end
			ELSEIF "ATE " $ cValidCampo
				ADDValor("FAIXA4_TP",cTimeDif)
				ADDValor("FAIXA4_SIT",ON_TIME_SLA)
				if !Empty(aTimeDif[4,13])
					aDtLimite := oChamado:aFAIXA4//somatime(aTimeDif[4,13],aTimeDif[4,14],CalcCritic("FAIXA4_TP"))
					ADDValor("FAIXA4_DTL",aDtLimite[1])
					ADDValor("FAIXA4_HRL",aDtLimite[2])
				end
				if calculaSlaMensal(aDtLimite[1])
					aTotaisSla[8]++
				end
				ADDValor("FAIXA4_TPM",timetomin(cTimeDif))
			ELSEIF TIME_TO_END $ cValidCampo
				ADDValor("FAIXA4_TP",cTimeDif)
				ADDValor("FAIXA4_SIT",TIME_TO_END)
				if !Empty(aTimeDif[4,13])
					aDtLimite := oChamado:aFAIXA4//somatime(aTimeDif[4,13],aTimeDif[4,14],CalcCritic("FAIXA4_TP"))
					ADDValor("FAIXA4_DTL",aDtLimite[1])
					ADDValor("FAIXA4_HRL",aDtLimite[2])
				end
				ADDValor("FAIXA4_TPM",timetomin(cTimeDif))
			ELSEIF NOT_EXIST_SLA $ cValidCampo
				ADDValor("FAIXA4_TP",NOT_EXIST_SLA)
				ADDValor("FAIXA4_SIT",NOT_EXIST_SLA)
			END
		END
	end
	IF EMPTY(aTimeDif[3,5])
		aTimeDif[3,5] := ""
	END
	end
	IF EMPTY(aTimeDif[4,5])
		aTimeDif[4,5] := ""
	END
		
	if !Empty(aTimeDif[1,1])
		ADDValor("DTABCOMPAC",substr(  dtos(aTimeDif[1,1]),1,6) )
//		ADDValor("DABERTURA",aTimeDif[1,1])
//		ADDValor("HDABERT",aTimeDif[1,2])
	end
	

	IF ADENEW->ADE__ENTPE $ "10/30/90"
		aadd(aRisco,val( substr(legenda(ADENEW->ADE_SEVCOD,"SEVCOD"),1,1))*10)
		IF !eMPTY(aTimeDif[1,3])//difdias(ddatabase,dUltDtMov)
			aadd(aRisco,difdias(ddatabase,aTimeDif[1,3]) )
		ELSEIF !eMPTY(aTimeDif[1,1])
			aadd(aRisco,difdias(ddatabase,aTimeDif[1,1]))
		END
		
		AAdd( aRisco, nTotProducao * If( ExecPoint( "000002" ), 10, 1 ) )
		
		IF !eMPTY(aTimeDif[1,1])
			aadd(aRisco,date() - aTimeDif[1,1])
		END
		aadd(aRisco,val(substr(legenda(QI2->QI2_PRIORI,"PRIO"),1,1))*10)
		
		If Empty(aTimeDif[1,1]) // sem o primeiro atendimento
			aadd(aRisco, 64)
		END

	    // Jม ERA
	    if "ACIMA" $ validacampo("FAIXA1_TP", retacols("FAIXA1_TP"))
	      aadd(aRisco, 30)
	    end

		if "ACIMA" $ validacampo("FAIXA2_TP", retacols("FAIXA2_TP"))
			aadd(aRisco, 65)
		end
		
		if "ACIMA" $ validacampo("FAIXA3_TP", retacols("FAIXA3_TP"))
			aadd(aRisco, 130)
		end

	    // PODE DAR PROBLEMA 
	    
	    if "PRAZO-A-VENCER" $ validacampo("FAIXA2_TP", retacols("FAIXA2_TP"))
	      aadd(aRisco, 5)
	    end
	    
	    if "PRAZO-A-VENCER" $ validacampo("FAIXA3_TP", retacols("FAIXA3_TP"))
	      aadd(aRisco, 10)
	    end
		

		addvalor("RISCO",CalcRisco(aRisco))
		addvalor("DESCR_RISC",CalcRisco(aRisco,.t.))
	end

	ClcTmpCorr()//Daniel
end
addvalor("DEBUG",AddDebug())
AddDebug("",.T.)
/*
Procurar se existe campos de item
*/
CriaAcols()
if ( lMUsers .or. cRealUser $ INTERMEDIARIO_ACESSO ).and. ( aFiltros[NSTATUS] == "Estatistica Geral" )
	SomaADF(dDataAdf)
	if empty(aTimeDif[1,1])
		TotalDash(dDataAdf)
	else
		TotalDash(aTimeDif[1,1])
	end

end
nquant++
return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcChamados()
//fElapTime()
If lQueryNew
	ProcChNew()
Else
	ProcChOld()
End

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/30/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcChNew()
Local cInFaixa  := MntInFaixa()
Local cInCliFx  := MntInCliFx()
Local bBlocoAux := { || }
Local nTamCHOrg := TamSX3( "ADE_CHORIG" )[ 1 ]

//fElapTime()
If aFiltros[NSTATUS] == "Estatistica Geral"
	aFiltros[DATADE] -= Val( cDiasVolta )// dias a voltar -- Michel
EndIf

If lBetween .And. ( aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .Or. aFiltros[NSTATUS] == "Estatistica Geral" )
	bBlocoAux := { || nCount++,;
						If(	dDataOldAde > ADE_DATA,;
							dDataOldAde := ADE_DATA,;
							.F.;
						),;
						aAdd( aChamados, ADEQRY->(ADE_FILIAL+ADE_CODIGO) );
					}
Else
	bBlocoAux := { || nCount++,;
						If(	dDataOldAde > ADE_DATA,;
							dDataOldAde := ADE_DATA,;
							.F.;
						),;
						If(	Empty( aScan( aChamados, ADEQRY->(ADE_FILIAL+ADE_CODIGO) ) ),;
							aAdd( aChamados, ADEQRY->(ADE_FILIAL+ADE_CODIGO) ),;
							.F.;
						);
					}
EndIf

qOut( "SIMC010 - Separando registros " + Time() )

If Select( "ADEQRY" ) > 0
	("ADEQRY")->( dbCloseArea() )
EndIf

While !lSaida
	nPassada++

	cTextFil := ""
	MontaFilOk( cInFaixa , cInCliFx , nTamCHOrg )
	
	cQuery := aFiltros[ QUERY ]
	
	cTextFil +=  " Processo: 1/2 - Gerando os dados de analise Query:" + CRLF
	cTextFil +=  " Passagem: " + AllToChar( nPassada ) + CRLF + CRLF
	cTextFil +=  cQuery +CRLF

	//IF MOSTRATEMPOS .OR. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|"
	//	cTextFil += cQuery  + CRLF
	//End
	
	// cQuery := changequery(cQuery)

	//mytext( cTextFil )

	TcQuery (cQuery) New Alias "ADEQRY"
	TcSetField( Alias() , "ADE_DATA" , "D" , 8 , 0 )

	//cTextFil += " Tempo Query: " + nToTime(seconds()-nTempo)  + CRLF
	//mytext( cTextFil )

	dbEval( bBlocoAux )
	dbCloseArea()

	If !( aFiltros[NSTATUS] $ "Pesquisar Ocorrencia|Estatistica Geral" )
		lSaida := .T.                                        	
	EndIf
		
	If aFiltros[NSTATUS] $ "Pesquisar Ocorrencia|Estatistica Geral"
		aFiltros[DATADE]++
		If ( aFiltros[DATADE] > aFiltros[DATAATE] ) .OR. !Empty( cFilChamado )
			lsaida := .T.
		EndIf
	EndIf
EndDo

qOut("SIMC010 - Registros Separados " +alltochar(len(aChamados)) + " " + TIME())
aFiltros[DATADE]	:= DATADEOld
aFiltros[DATAATE]	:= DATAATEOld

ChkFile( "ADE",.f. , "ADENEW")
aMultQ		:= {}
acols		:= {}
acolslinhas	:= {}
cError		:= TCSQLERROR()

If Empty( nCount ) .And. !Empty( cError )
	Alert(cError + CRLF + cQuery)
EndIf

nMeses := contames( dDataOldAde, aFiltros[DATAATE] )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  05/30/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcChOld()
Local cInFaixa  := MntInFaixa()
Local cInCliFx  := MntInCliFx()
Local bBlocoAux := { || }
Local nTamCHOrg := TamSX3( "ADE_CHORIG" )[ 1 ]
//fElapTime()
If aFiltros[NSTATUS] == "Estatistica Geral"
	aFiltros[DATADE] -= Val( cDiasVolta ) // dias a voltar -- Michel
End

If lBetween .And. ( aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .Or. aFiltros[NSTATUS] == "Estatistica Geral" )
	bBlocoAux := { || nCount++,;
					If( dDataOldAde > ADE_DATA , dDataOldAde := ADE_DATA , .F. ),;
					aAdd( aChamados , ADEQRY->(ADE_FILIAL+ADE_CODIGO ) ) }
Else
	bBlocoAux := {|| nCount++,;
					If (dDataOldAde > ADE_DATA,dDataOldAde := ADE_DATA,.F.),;
					If ( Empty( aScan( aChamados,ADEQRY->(ADE_FILIAL+ADE_CODIGO) ) ),;
					aAdd( aChamados , ADEQRY->(ADE_FILIAL+ADE_CODIGO) ),;
					.F. )  }
EndIf

While !lSaida
	nPassada++
	if aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .or. aFiltros[NSTATUS] == "Estatistica Geral"
		aFiltros[DATAATE] := aFiltros[DATADE] + 30
		if aFiltros[DATAATE] > DATAATEOld
			aFiltros[DATAATE] := DATAATEOld
			lsaida := .T.
		end
	end
	
	cTextFil := ""
	MontaFilOk( cInFaixa , cInCliFx , nTamCHOrg )
	cQuery := aFiltros[QUERY]
	
	cTextFil +=  " Processo: 1/2 - Gerando os dados de analise Query:"+CRLF
	cTextFil +=  " Passagem: "+alltochar(nPassada)+CRLF
	
	IF MOSTRATEMPOS .OR. cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|DANIEL.MENDES|"
		cTextFil += cQuery  + CRLF
	END
	cQuery := changequery(cQuery)
	/*
	mytext( cTextFil )
	*/
	TCQUERY (cQuery) new alias "ADEQRY"
	TCSETFIELD(ALIAS(),"ADE_DATA","D",8,0)
/*	
	cTextFil += " Tempo Query: " + nToTime(seconds()-nTempo)  + CRLF
	mytext( cTextFil )
*/	
	dbEval( bBlocoAux )
	dbCloseArea()
		
	If !( aFiltros[NSTATUS] $ "Pesquisar Ocorrencia|Estatistica Geral" )
		lSaida := .T.
	End
		
	if aFiltros[NSTATUS] $ "Pesquisar Ocorrencia|Estatistica Geral"
		aFiltros[DATADE] := aFiltros[DATADE] + 30
		if aFiltros[DATADE] > aFiltros[DATAATE]
			lsaida := .T.
		end
	end
end
	
aFiltros[DATADE] := DATADEOld
aFiltros[DATAATE] := DATAATEOld

ChkFile( "ADE",.f. , "ADENEW")
aMultQ := {}
acols := {}
acolslinhas := {}
cError := TCSQLERROR()
if empty(nCount) .and. !empty(cError)
	alert(cError + CRLF + cQuery)
end
nMeses := contames( dDataOldAde, aFiltros[DATAATE] )

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcLinhas( )
Local cQuery		:= ""

Private cLastEnv	:= ""
Private lCliente	:= .F.
Private nFaixaAtual := 1

//fElapTime( )

If !Empty( CANCELAMENTOS ) .AND. ( CANCELAMENTOS <> "??????" ) 
	// DESCARTANDO OS CHAMADOS CANCELADOS
	cQuery += "SELECT ADF_CODIGO FROM " +RETSQLNAME( "ADF" )+ " WHERE "
	cQuery += "ADF_CODIGO = '" + ADENEW->ADE_CODIGO + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cQuery += "AND ADF_FILIAL = '"+ MyXfilial( "ADF" ) + "' "
	
	If "," $ CANCELAMENTOS .OR. ";" $ CANCELAMENTOS
		cQuery += "AND ADF_CODSUQ IN " + Montain( CANCELAMENTOS ) + " "
	Else
		cQuery += "AND ADF_CODSUQ = '" + CANCELAMENTOS + "' "
	EndIf
	
	TCQUERY cQuery NEW ALIAS "ADFQRY"
//	TCQUERY ChangeQuery( cQuery ) NEW ALIAS "ADFQRY"

	lCancelado := !Empty( ADF_CODIGO )
	DBCLOSEAREA( )
	DBSelectArea( "ADENEW" )
EndIf

If !lCancelado
	// Tempo maximo que o analista pode ficar com o chamado
	aTimeDif[2,18]	:= CalcCritic( "FAIXA2_TP", .T. )
	nFaixaAtual		:= 1
	lFaixa6			:= .F.
	dDataLinha		:= ADF->ADF_DATA
	cHoraLinha		:= ADF->ADF_HORA

	CodsProd( ADF->ADF_DATA )

	While !ADF->( EOF( ) ) .and. ADF->ADF_CODIGO == ADENEW->ADE_CODIGO
		
		If( ADF->ADF_DATA > SToD( "20100808" ), .T., CodsProd( ADF->ADF_DATA ) )
		
		// *********************  filtro dos registro  ********************************
		lProdutivo	:= .F.
		lProducao	:= .F.
		
		If !EMPTY( ADF->ADF_DATA ) .AND. aFiltros[ NSTATUS ] <> "Pesquisar Ocorrencia"
			
			// ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			// ณ CALCULO DE TEMPOS DAS FAIXAS ณ
			// ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lCalculaSla
				CalcTemposSla( aTimeDif )
			EndIf
			
			If !lLinFabrica
				ProcLinOk( )
			end
		end
		nRecAdf := ADF->( RecNo( ) )
		ADF->( DBSkip( ) )
		
	EndDo
	// Ultimo Registro, verifico se estแ pendente algum calculo
	//michel
	
EndIf

Return NIL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*
Usa o ADE e o ADF validar caso esteja com .T. nao pode alterar a Query
*/
static function adjlinha()
//fElapTime()

if cRealUser $ "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|" .and. !empty(Ajustabase)
	lMudaLinha := .F.
	nPossJuri := ASCAN(aareas, {|X| X[1] == "SJURIDICO" } )
	IF !empty( myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_CODBCS") )
		If ADF->ADF_DATA >= aFiltros[DATADE] .AND. ADF->ADF_DATA <= aFiltros[DATAATE]
			IF ADF->ADF_CODSU0 == 'MT' .OR. (( ADF->ADF_CODSU0 == 'HF' .or. ADF->ADF_CODSU0 == 'JL').AND. ( nPossJuri > 0 .AND. alltrim(ADF->ADF_CODSU7) $ aareas[ nPossJuri ,2] ) )
				private M->ADE_GRUPO	:= ADENEW->ADE_GRUPO
				private M->ADE_ASSUNT	:= ADENEW->ADE_ASSUNT
				private M->ADE_FATURA	:= "1"
				
				//U_SIMC020()
				if ALLTRIM(ADENEW->ADE_CHAVE) $ CLIBCSNOTFAT
					M->ADE_FATURA	:= "2"
				END
				
				IF M->ADE_FATURA == "1"
					
					ADENEW->( RECLOCK(ALIAS(), .F.) )
					ADENEW->ADE_FATURA := "1"
					ADENEW->( MSUNLOCK() )
					//PRODUCAO=000005,000011,000025,000033,000034,000036,000037,000038,000002,000039,000019,000016,000010,000021/000004/
					//000008 000002 T7716900
					IF ADF->ADF_CODSUQ $ PRODUCAO .and. (ADF->ADF_CODSU9  <> 'TMK008' .and. ( ADF->ADF_CODSUQ <>'000024' .and.;
						ADF->ADF_CODSUQ <>'000009'  .and. ADF->ADF_CODSUQ <> '000013' .and.  ADF->ADF_CODSUQ<>'000041' .AND. ADF->ADF_CODSUQ<>'000018') .AND.;
						ADENEW->ADE_CHAVE <>'99027 00' .and. ADENEW->ADE_CHAVE <>'99023 00' )
						
						
						lMudaLinha := .F.
						cText := UPPER( alltrim(MSMM(ADF->ADF_CODOBS)) )
						IF LEN(cText) < 5  .OR. (LEN(cText) < 30  .AND. ( "EM ATENDIMENTO" $ cText .OR. "EM ANALISE" $ cText .OR. "EM ANมLISE" $ cText .OR. "EM ANDAMENTO" $ cText))
							ADF->( RECLOCK(ALIAS(), .F.) )
							ADF->ADF_FATURA := " "
							ADF->( MSUNLOCK() )
							myfwrite(nHand,ADENEW->ADE_CODIGO + ADF->ADF_ITEM + ";" + "Nao Fatura por que texto " + cText +;
							";" + "Cliente " + myPosicione("SA1",1,myxFilial("SA1")+ADENEW->ADE_CHAVE,"A1_NOME") + ;
							";" + "BCS " + myPosicione("SA1",1,myxFilial("SA1")+ADENEW->ADE_CHAVE,"A1_CODBCS") + CRLF,,@cTotalBuff)
						ELSE
							ADF->( RECLOCK(ALIAS(), .F.) )
							If Empty(ADF->ADF_FATDUR)
								//Anderson.Walter_120913_09h51 para fazer um anแlise para o chamado BAEHCY
								__hora	:= RetDifTime(ADF->ADF_HORA ,ADF->ADF__HRFIM)
								If !IsBlind() .And. ("-" $ __hora .Or. "*" $ __hora)
									U_SIMMail(	"Falha no campo ADF_FATDUR",;
									"N๚mero do Chamado: "+M->ADE_FILIAL+"\"+M->ADE_CODIGO+" - "+ADF->ADF_ITEM+CRLF+;
													"Fun็ใo que estแ sendo executada: "+FunName()+CRLF+;
													"Fun็ใo que gerou o valor errado: "+"ADF->ADF_FATDUR := RetDifTime("+ADF->ADF_HORA+" ,"+ADF->ADF__HRFIM+" )"+CRLF+;
													"Valor que serแ gravado no campo: "+RetDifTime(ADF->ADF_HORA ,ADF->ADF__HRFIM)+CRLF+;
													"Usuแrio Logado: "+CRLF+;
													"Uusแrio :"+Iif(Type("CUSERNAME") <> "U", CUSERNAME,"")+CRLF+;
													"Nome: "+Iif(Type("__CUSERID") <> "U",UsrFullName(__CUSERID),"")+CRLF+;
													"E-mail: "+Iif(Type("__CUSERID") <> "U", UsrRetMail(__CUSERID),"")+CRLF+;
													"Obs.: Esse e-mail ้ para anแlise do chamado BAEHCY",;
												GetMv("PS_BAEHCY"),,,)
								Endif
								ADF->ADF_FATDUR := __hora
								lMudaLinha := .T.
							End
							ADF->ADF_FATURA := "1"
							ADF->( MSUNLOCK() )
							myfwrite(nHand,ADENEW->ADE_CODIGO + ADF->ADF_ITEM + ;
							";" + if(lMudaLinha,"Tempo nao gravado","Tempo Gravado") + ;
							";" + "Cliente " + myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_NOME") + ;
							";" + "BCS " + myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_CODBCS") + CRLF,,@cTotalBuff)
							
						END
					else
						ADF->( RECLOCK(ALIAS(), .F.) )
						ADF->ADF_FATURA := " "
						ADF->( MSUNLOCK() )
						myfwrite(nHand,ADENEW->ADE_CODIGO + ADF->ADF_ITEM +  ";" + "Nao Fatura por que ADF_CODSUQ  + ADF_CODSU9 ADE_CHAVE nao permite" + ;
						ADF->ADF_CODSUQ  + "-" + ADF->ADF_CODSU9 + "-" + ADENEW->ADE_CHAVE + ;
						";" + "Cliente " + myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_NOME") + ;
						";" + "BCS " + myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_CODBCS") + CRLF,,@cTotalBuff)
					END
				ELSE
					ADENEW->( RECLOCK(ALIAS(), .F.) )
					ADENEW->ADE_FATURA := M->ADE_FATURA
					ADENEW->( MSUNLOCK() )
					ADF->( RECLOCK(ALIAS(), .F.) )
					ADF->ADF_FATURA := " "
					ADF->( MSUNLOCK() )
					myfwrite(nHand,ADENEW->ADE_CODIGO + ADF->ADF_ITEM +  ";" + "Nao Fatura por que ja tem novo contrato" + ;
					";" + "Cliente " + myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_NOME") + ;
					";" + "BCS " + myPosicione("SA1",1,myxfilial("SA1")+ADENEW->ADE_CHAVE,"A1_CODBCS") + CRLF,,@cTotalBuff)
				END
			END
		END
	END
end
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function IsTPrivate(cCodCli)
Local cPrivate	:= ""
Local nPrivate	:= 0
Local nClientes	:= 0
Local lAchou	:= .F.
//fElapTime()
cCodCli := alltrim(cCodCli)
For nClientes := 1 to len(t_privates)
	if !lAchou .and.  ascan(t_privates[nClientes], {|x| x == cCodCli }  ) > 0
		lAchou := .T.
	end
next

Return if (lAchou, "S"," " )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/30/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function ConvPrivates(cClientes)
Local nClientes	:= 0
Local nPai		:= 0
Local cRetCli	:= cClientes
Local cCliTmp	:= ""
//fElapTime()
While !Empty(cClientes)
	nPos := at (",", cClientes)
	if nPos > 0
		cCliTmp		:= substr( cClientes,1, nPos -1 )
		cClientes	:= substr( cClientes , nPos + 1 )
	else
		cCliTmp := cClientes
		cClientes := ""
	end
	if ( nPai := ascan(t_privates, {|x| x[1] == cCliTmp }  ) ) > 0
		aeval(t_privates[nPai],{|x| cRetCli += "," + x } )
	end
end

return cRetCli
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Filtragem das datas por chamado
*/
static function FilDtMes()
Local lConta := .F.
//fElapTime()
lConta :=  ( ADENEW->ADE_DATA >=  aFiltros[DATADE] .AND. ADENEW->ADE_DATA <= aFiltros[DATAATE] )

if ! lConta .and. lConta2
	lConta := lConta2
end
if ! lConta .and. !Empty(aTimeDif[1,1]) .and. !Empty(oChamado:cFaixa1).and. oChamado:lFaixa1 //ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA1_TP",.T.)
	lConta :=  ( oChamado:aFaixa1[1]>= aFiltros[DATADE] .and.;
					oChamado:aFaixa1[1]<= aFiltros[DATAATE] )
end                                              // se tenho tempo de faixa
if ! lConta .and. !Empty(aTimeDif[2,13]) .and. !Empty(oChamado:cFaixa2).and. oChamado:lFaixa2//ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA2_TP",.T.)
	lConta :=  ( oChamado:aFaixa2[1]>= aFiltros[DATADE] .and.;
					oChamado:aFaixa2[1]<= aFiltros[DATAATE] )
end                                                   //verifico se tenho tempo de faixa
if ! lConta .and. !Empty(aTimeDif[3,13]) .and. !Empty(oChamado:cFaixa3).and. oChamado:lFaixa3 //ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA3_TP",.T.)
	lConta := ( oChamado:aFaixa3[1]>= aFiltros[DATADE] .and. ;
					oChamado:aFaixa3[1]<= aFiltros[DATAATE] )
end
if ! lConta .and. !Empty(aTimeDif[4,13]) .and. !Empty(oChamado:cFAIXA4).and. oChamado:lFAIXA4 //ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA3_TP",.T.)
	lConta := ( oChamado:aFAIXA4[1]>= aFiltros[DATADE] .and. ;
					oChamado:aFAIXA4[1]<= aFiltros[DATAATE] )					
end
Return lConta

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
CLASS DashChamado
//se o cliente ้ SLA das faixas
DATA lFaixa1	AS LOGICAL 
DATA lFaixa2	AS LOGICAL 
DATA lFaixa3	AS LOGICAL 
DATA lFAIXA4	AS LOGICAL 
// calculo dos tempos das faixas
DATA aFaixa1	AS ARRAY
DATA aFaixa2	AS ARRAY
DATA aFaixa3	AS ARRAY
DATA aFAIXA4	AS ARRAY
//tempo corrido das faixas
DATA cFaixa1	AS CHARACTER
DATA cFaixa2	AS CHARACTER
DATA cFaixa3	AS CHARACTER
DATA cFAIXA4	AS CHARACTER

METHOD New()
METHOD ValidCliFaixa( cNomeCol )
METHOD CalcTime( aTimeDif )
METHOD CalculaFaixas()

ENDCLASS
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/13/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD New() CLASS DashChamado
::lFaixa1	:= ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA1_TP",.T.)
::lFaixa2	:= ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA2_TP",.T.)
::lFaixa3	:= ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA3_TP",.T.)
::lFAIXA4	:= ValidCliFaixa(ADENEW->ADE_CHAVE,"FAIXA4_TP",.T.)
::cFaixa1	:= ""
::cFaixa2	:= ""
::cFaixa3	:= ""
::cFAIXA4	:= ""

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
METHOD ValidCliFaixa(cNomeCol) CLASS DashChamado
Local lRet := .F.

If cNomeCol == "FAIXA1_TP"
	lRet := ::lFaixa1
ElseIf cNomeCol == "FAIXA2_TP"
	lRet := ::lFaixa2
ElseIf cNomeCol == "FAIXA3_TP"
	lRet := ::lFaixa3
ElseIf cNomeCol == "FAIXA4_TP"
	lRet := ::lFAIXA4
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CalTime
M้todo Responsแvel pelo cแlculo ...

@param   
@author  
@version P10 R1.0
@since   
@return  lRetorno Valor l๓gico que indica Retorno
@obs     Observa็ใo sobre o M้todo/Fun็ใo
@sample
....
....
/*/
//-------------------------------------------------------------------
METHOD CalcTime( aTimeDif ) CLASS DashChamado
Local nSec2	:= 0		//, nConta, aTempoFX
Local x		:= 1
//validar as faixas de clientes aqui
//TEMPOS SLA
//CALCULA OS TEMPOS FINAIS

If ::lFaixa1 .and. !Empty( aTimeDif[1,1] )
	::lFaixa1 := RetCliOk( ADENEW->ADE_CHAVE, aTimeDif[1,1], "1" )
End
If ::lFaixa2 .and. !Empty( aTimeDif[2,1] )
	::lFaixa2 := RetCliOk( ADENEW->ADE_CHAVE, aTimeDif[2,13], "2" )
End
If ::lFaixa3 .and. !Empty( aTimeDif[3,1] )
	::lFaixa3 := RetCliOk( ADENEW->ADE_CHAVE, aTimeDif[3,13], "3" )
end
If ::lFAIXA4 .and. !Empty( aTimeDif[4,1] )
	::lFAIXA4 := RetCliOk( ADENEW->ADE_CHAVE, aTimeDif[4,13], "4" )
End

// TUNGADA CASO A FAIXA 2 ESTEJA AINDA ABERTA
// COMO A FAIXA 2 PODE SER ABERTA E FECHADA VARIAS VEZES O CALCULO PODE SER AQUI

If	Empty( aTimeDif[3,1] );
	.and. ( empty( aTimeDif[2,7] ) .or. ADENEW->ADE__ENTPE $ "90/10" ); //"70/90/10"
	.and. ( ADENEW->ADE_GRUPO $ aFiltros[EQUIPEATE] );
	.and. !empty( aTimeDif[2,1] );
	.and. !empty( aTimeDif[2,3] )

	aTimeDif[2,3] := Date( )
	aTimeDif[2,4] := Time( )

	If Empty( aTimeDif[2,7] )
		aTimeDif[2,7] := 0
	EndIf

	DifTime( aTimeDif[2] ,,@nSec2 )
	
	If Empty( aTimeDif[2,18] )
		aTimeDif[2,18] := 0
	EndIf

	If Empty( aTimeDif[2,19] )
		aTimeDif[2,19] := 0
	EndIf
	
	aTimeDif[2,7] += nSec2

	if aTimeDif[2,18] > 0 .AND. nSec2 > 0
		//tento descontar o tempo do cliente com o tempo restante da faixa
		if aTimeDif[2,18] - nSec2 >= 0
			aTimeDif[2,19] += nSec2
		else
		//nao tem tempo disponivel para descontar, desconta o restante
			aTimeDif[2,19] += aTimeDif[2,18]
		end
		aTimeDif[2,18] -= nSec2

		AddDebug({;
		"TIRANDO DA FAIXA:",;
		"",;
		"",;
		"",;
		"",;
		"",;
		nToTime(aTimeDif[01,07]),;
		nToTime(aTimeDif[02,07]),;
		nToTime(aTimeDif[02,15]),;
		nToTime(aTimeDif[02,19]),;
		nToTime(aTimeDif[02,18]),;
		nToTime(aTimeDif[03,07])})		
	end		
end

// TUNGADA PARA VOLTAR A DATA DE ABERTURA DA FAIXA 2
/* voltar para todas as faixas os tempos atuais */
For x := 1 to 4
	aTimeDif[x,1] := aTimeDif[x,13]
	aTimeDif[x,2] := aTimeDif[x,14]		
Next

If !Empty( aTimeDif[1,1] )
	::cFaixa1 := DifTime( aTimeDif[1] )
EndIf

If !Empty( aTimeDif[2,1] )
	/*
	calculo diferente, ้ o inicio mais o tempo que calculei com a soma
	*/
	
	// parei aqui
	
	// somatime(aTimeDif[2,13],aTimeDif[2,14],aTimeDif[2,15]+CalcCritic("FAIXA2_TP",.t.))
	
	
	//DifTime({aTimeDif[2,10],aTimeDif[2,11],DATE(),time()} ,,@nSec2)
	//ja tenho a soma de todo o tempo
	::cFaixa2 := nToTime(aTimeDif[2,7]) //diftime(aTimeDif[2],aTimeDif[2,7])
EndIf

If !Empty(aTimeDif[3,1])
	::cFaixa3 := diftime(aTimeDif[3])
EndIf

If !Empty(aTimeDif[4,1])
	::cFAIXA4 := diftime(aTimeDif[4])
EndIf

::aFaixa1 := somatime(aTimeDif[1,1],aTimeDif[1,2],CalcCritic("FAIXA1_TP",.T.))
//calculo do limite = meu limite da faixa + tempo do cliente antes de estourar

If Empty( aTimeDif[2,15] )
	aTimeDif[2,15] := 0
EndIf

::aFaixa2 := SomaTime( aTimeDif[2,1], aTimeDif[2,2], aTimeDif[2,15] + CalcCritic( "FAIXA2_TP",.T. ) )
::aFaixa3 := SomaTime( aTimeDif[3,1], aTimeDif[3,2], CalcCritic( "FAIXA3_TP",.T. ) )
::aFaixa4 := SomaTime( aTimeDif[4,1], aTimeDif[4,2], CalcCritic( "FAIXA4_TP",.T. ) )

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/14/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function WhenFiltro(cFiltro)
Local i	:= 0

//fElapTime()

cFiltro := ""

For i := 1 To Len(aStruTmp)
	If Len(aStruTmp[i]) == 15
		If !Empty(aStruTmp[i,15])
			If "," $ aStruTmp[i,15] .OR. ";" $ aStruTmp[i,15]
				cFiltro += " " + aStruTmp[i,14] + "  EM "     + Montain( Alltrim( aStruTmp[i,15] ) )
			Else
				cFiltro += " " + aStruTmp[i,14] + "  IGUAL '" + Alltrim( aStruTmp[i,15] ) + "' "
			End
		End
	End
Next i

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcLinOk( )
Static lPrcLinOk2 := FindFunction( "u_ProcLinOk2" )
//fElapTime()

If lNewFormat .And. lPrcLinOk2
	u_ProcLinOk2()
Else
	ProcLinOk2()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/08/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ProcLinOk2( )
//fElapTime()
if ADF->ADF_FATURA == "1"
	cTotFat := SomaHora(cTotFat,ADF->ADF_FATDUR)
END

//Filtro de analista

If ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .and. ADF->ADF_CODSU9  <> 'TMK008'
	cAnalistaAloc := ALLTRIM(ADF->ADF_CODSU7)
	ddataanalista := ADF->ADF_DATA
End

lCONTA := .F.
if Proc_Texto()
	if nConta >= 2
		aadd(aMemoSol, " ****** EM " + DTOC(ADF->ADF_DATA) + " " + ADF->ADF_HORA + " ****** " + UPPER( alltrim(MSMM(ADF->ADF_CODOBS)) ) )
		cMemoSol += " ****** EM " + DTOC(ADF->ADF_DATA) + " " + ADF->ADF_HORA + " ****** " + UPPER( alltrim(MSMM(ADF->ADF_CODOBS)) ) + CRLF
		cMemoSol += replicate("-",95) + CRLF
	end
	nConta++
end

If ! lAssociado
	// FILTRANDO POR EQUIPE E ANALISTA DIFERENTE DE AUTO
	IF ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .and. ! ( alltrim( ADF->ADF_CODSU7 ) == "AUTO" )
		// aFiltros[TECNICO] == "|RENATO.CAMPOS|CAIO.FELIPE|MICHELLE.ROLLI|VIU|"
		IF !EMPTY( aFiltros[TECNICO]) .AND. !EMPTY( cFiltraGrupos)
			// TENHO O ANALISTA E ELE EH DA AREA
			IF 	cAnalistaAloc $ aFiltros[TECNICO] .AND. RetAnArea( cAnalistaAloc ,dDataAnalista ) $ cFiltraGrupos
				lCONTA=.T.
			ENDIF
		// TENHO O ANALISTA E NAO TENHO A AREA
		ELSEIF !EMPTY( aFiltros[TECNICO]) .AND.  EMPTY( cFiltraGrupos)
			IF 	cAnalistaAloc $ aFiltros[TECNICO]
				lCONTA=.T.
			ENDIF
		// NAO TENHO ANALISTA E NAO TENHO AREA
		ELSEIF EMPTY( aFiltros[TECNICO]) .AND.  EMPTY( cFiltraGrupos)
			lCONTA=.T.
		ENDIF
	// NAO TENHO ANALISTA E NAO TENHO AREA
	elseif	( ( EMPTY(aFiltros[TECNICO]) .AND. EMPTY(cFiltraGrupos) ) .or. ( AllTrim(ADF->ADF_CODSU7) == "AUTO" ) ) .and.;
			( ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE] .OR. ADENEW->ADE_GRUPO $ aFiltros[EQUIPEATE] )
			// .AND. ( cAnalistaAloc == "AUTO" ) alltrim( ADF->ADF_CODSU7 ) == "AUTO" )
		lCONTA=.T.
		// INCLUIR ANALISTA AUTO QUANDO ESTOU FILTRANDO POR ALGUM ANALISTA
	elseif ! EMPTY( aFiltros[TECNICO]) .AND. ( cAnalistaAloc == "AUTO" .and. alltrim( ADF->ADF_CODSU7 ) == "AUTO" ) .AND. aFiltros[NSTATUS]=="Pendente Analista"
		lCONTA=.T.
		// incluir chamados nao alocados / nao testado ainda
	elseif !lAntigo .and. ! EMPTY( aFiltros[TECNICO]) .AND. ( cAnalistaAloc == "AUTO" .OR. EMPTY(cAnalistaAloc) ) .AND. aFiltros[NSTATUS]=="Pendente Analista"
		lCONTA=.T.
	ElseIf !Empty( cAnValid )
		lCONTA=.T.
	end
	/*
	Pendente Analista			- APENAS CABEC	- SEMPRE O CHAMADO DEVE ESTAR AQUI
	Pesquisar Ocorrencia		- APENAS CABEC	- POIS COLOCO ONDE QUERO PESQUISAR -- nใo existe mais, tiramos em 25/08/2011
	Pendente Cliente			- APENAS CABEC	- O CHAMADO SO PODE FICAR PENDENTE COM O CLIENTE NA AREA
	FNC Pendentes				- LINHAS			- O CHAMADO NAO ESTA NA AREA, POREM JA PASSOU POR AQUI
	Pendencias na Qualidade	- LINHAS			- O CHAMADO NAO ESTA NA AREA, POREM JA PASSOU POR AQUI
	Chamados Associado		- APENAS CABEC	- O CHAMADO EH DA AREA
	Estatistica Geral			- AMBOS			- TENHO QUE VER QUALQUER CHAMADO DA AREA NAO IMPORTA ONDE
	*/
	// Se ้ Estatistica Geral, so quero as linhas que estใo no periodo
	If aFiltros[NSTATUS]== "Estatistica Geral" .and. ( ADF->ADF_DATA >= aFiltros[DATADE] .AND. ADF->ADF_DATA <= aFiltros[DATAATE] ) .and. ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
		lConta2 := .T. //tratamento para que mesmo que as datas limites do chamado for fora do periodo solicitado e hแ intera็ใo, traz o chamado mesmo assim.
	EndIf
	
	If !lCONTA
		mydebug("Chamado nใo contado pois nao estแ no filtro de analistas: " + ADENEW->ADE_CODIGO)
	EndIf
	
	//
	If lCONTA
		// marca se existe ou nao pelo menos 1 linha com o analista selecionado
		lContou := lCONTA

		If  ADF->ADF_CODSUQ  $ PRODUTIVO //TI
			If aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .or. aFiltros[NSTATUS] == "Estatistica Geral"
				If ADF->ADF_DATA >= aFiltros[DATADE] .AND. ADF->ADF_DATA <= aFiltros[DATAATE]	// dentro do periodo
					lProdutivo := .T.
					nTotProdutivo++
				Endif
			Else
				lProdutivo := .T.
				nTotProdutivo++
			EndIf
		EndIf

		If ADF->ADF_CODSUQ $ PRODUCAO
			If aFiltros[NSTATUS] == "Pesquisar Ocorrencia" .or. aFiltros[NSTATUS] == "Estatistica Geral"
				If ADF->ADF_DATA >= aFiltros[DATADE] .AND. ADF->ADF_DATA <= aFiltros[DATAATE]	// dentro do periodo
					lProducao_DT_FIL :=.T.
					lProducao := .T.
					nTotProducao++
				EndIf
			Else
				lProducao := .T.
				nTotProducao++
			EndIf
		EndIf
		
		If ADF->ADF_CODSUQ $ REABERTURAS
			nReaberturas++
		EndIf
		
		If ADF->ADF_CODSUQ $ REJEICOES
			nRejeicoes++
		EndIf
		
		RetOpera(@cOpera)
		// VERIFICAR SE A SOMA DOS ITENS DEVEM SER VALIDADOS ASSIM
		// PROVAVELMENTE SIM
		If aFiltros[NSTATUS] == "Estatistica Geral"
			if ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
				lSomaAdf := .T.
				lTemAreaCHM:=.T.
				dDataAdf := ADF->ADF_DATA
				AcolsVirtual() //MICHEL
			ENDIF

			If ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]
				If !Empty( ADF->ADF_CODSU7 )
					cAnValid:= myPosicione("SU7",1,MyXfilial("SU7")+ADF->ADF_CODSU7,"U7_NOME")
				EndIf
				
				If AScan(aAnUnq,cAnValid) == 0
					If ADF->ADF_CODSUQ  $ PRODUTIVO + PRODUCAO + ('S30000,P40000,070000')				
						ADDValorX("ANA_UNICO",cAnValid)
					EndIf
					AAdd(aAnUnq,cAnValid)
				EndIf
			EndIf

			ADDValorX("ANA_VALID_FAIXA",cAnValid)

			ADDValorX("REABERTURAS",ADF->ADF_CODSUQ $ REABERTURAS)
			
			ADDValorX("REJEICOES",ADF->ADF_CODSUQ $ REJEICOES)

		END
		
		AdjLinha()
		
	END
end

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  11/29/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function difdias(dataini,datafim)
Local nDias		:= 0
Local nDiasOk	:= 0
Local nDiaSemana:= 0
Local dDiaMin	:= min(dataini,datafim)
// quantos dias uteis devo contar
//fElapTime()
If !Empty(dataini) .and. !Empty(datafim)
	For nDias := 1 to ( max(dataini,datafim) - dDiaMin )
		nDiaSemana := dow(dDiaMin)
		if ! ( nDiaSemana == 1 .or. nDiaSemana == 7 .or. feriado(dDiaMin) ) 
			nDiasOk++
		end
		dDiaMin++	
	next
End
return nDiasOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// Funcao de auxilio de calculo do dashboard

Static Function LoadObj()
//fElapTime()
__oRpo		:= Rpo():New()
lRpoInit	:= __oRpo:Open( cPathForm+"user.rpo" )
IF !( lRpoInit )
	lIsObject := ( ValType( __oRpo ) == "O" )
	IF ( lIsObject )
		__oRpo:Close()
	EndIF
	__oRpo := NIL
EndIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  12/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
// Funcao de auxilio de calculo do dashboard

static function compilobj()
//fElapTime()
cSrc := memoread(cPathCubosAC+"SIMC010.FORM")
cPCodeRet := ""
if !empty(cSrc) .and. ValType( __oRpo ) == "O"
	if __oRpo:StartBuild( .T. )
	
		IF !( __oRpo:Compile( "SIMC010.FORM" , cSrc , __fDHtoNS( Msdate() , 0 ) + 34700 , __oRpo:ChkSum( cPathForm+"SIMC010.FORM" ) , .T. , @cPCodeRet ) ) 
			ALERT( "SIMC010.FORM" + CRLF+;
			ALLTOCHAR("Linha : " + Alltochar(__oRpo:ErrLine)) + CRLF+;
			ALLTOCHAR("Coluna: " + alltochar(__oRpo:ErrCol) ) + CRLF+;
			ALLTOCHAR("Erro  : " + alltochar(__oRpo:ErrStr) ) )
		end
	else
		alert("RPO em uso")
	end
	__oRpo:EndBuild()	
end
return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  10/16/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function MontaForm()
Local x
Local cMemo := ""
Local oGet
Local lOk := .f.
//fElapTime()
if file(cPathCubosAC+"SIMC010.FORM")
	cMemo := MemoRead(cPathCubosAC+"SIMC010.FORM")
end
DEFINE MSDIALOG oDlg FROM 0,0 TO oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 TITLE "Montagem de formulas" PIXEL
//DEFINE MSDIALOG oDlg FROM 0,0 TO 440,640 TITLE "Montagem de formulas" PIXEL
@ 0, 0  get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 MEMO HSCROLL pixel

oGet:lWordWrap := .F.

oGet:EnableVScroll(.t.)
oGet:EnableHScroll(.t.)

//TMultiGet(): New ( [ nRow], [ nCol], [ bSetGet], [ oWnd], [ nWidth], [ nHeight], [ oFont], [ lHScroll], [ uParam9], [ uParam10], [ uParam11], [ lPixel], [ uParam13], [ uParam14], [ bWhen], [ uParam16], [ uParam17], [ lReadOnly], [ bValid], [ uParam20], [ uParam21], [ lNoBorder], [ lNoVScroll] ) --> oObjeto

NlINHA := (oDlg:nClientHeight/2)-35
nColuna := 10
@ NlINHA,nColuna BUTTON "Salvar" SIZE 50,10 Pixel ACTION ( lOk := .t., ODLG:end() )
@ NlINHA,nColuna+= 60 BUTTON "Cancelar" SIZE 50,10 Pixel ACTION ( ODLG:end() )
ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
if lOk
	memowrit(cPathCubosAC+"SIMC010.FORM",cMemo)
	
	if MsgYesno("Salva Copia Local")
		memowrit(cPathCubosAC+"SIMC010.FORM",cMemo)
	end
	compilobj()
end
return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  01/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function pesquisar()
Local oDlg
Local oCombo
Local oGet
Local aCampos := {}
Local cCombo := ""
Local cMemo := SPACE(30)
Local lOk := .F.
Local nAchou := 0
//fElapTime()
aeval(aStruTmp,{|x| aadd( aCampos, x[5] ) } )

//DEFINE MSDIALOG oDlg FROM 0,0 TO oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 TITLE "Filtro" PIXEL
DEFINE MSDIALOG oDlg FROM 0,0 TO 200,600 TITLE "Pesquisa" PIXEL
@ 1,1 Say "Campo" Pixel
@ 1,2 COMBOBOX oCombo Var cCombo Items aCampos SIZE 90,20 Pixel
@ 1,3 Say "" Pixel
//@ 1,4 Say "" Pixel
@ 2,1 Say "Igual a" Pixel
//@ 1,4 get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 pixel
@ 2,2 get oGet var cMemo SIZE 90,11 pixel


//TMultiGet(): New ( [ nRow], [ nCol], [ bSetGet], [ oWnd], [ nWidth], [ nHeight], [ oFont], [ lHScroll], [ uParam9], [ uParam10], [ uParam11], [ lPixel], [ uParam13], [ uParam14], [ bWhen], [ uParam16], [ uParam17], [ lReadOnly], [ bValid], [ uParam20], [ uParam21], [ lNoBorder], [ lNoVScroll] ) --> oObjeto



@ 3,1 BUTTON "Procurar" SIZE 50,10 Pixel ACTION ( ProcItem(cMemo,oCombo:nAt) )
@ 3,2 BUTTON "Cancela" SIZE 50,10 Pixel ACTION ( ODLG:end() )
@ 4,1 Say "" Pixel

ACTIVATE MSDIALOG ODLG CENTER on init AjustaTamanho(ODLG)
return

Static function ProcItem(cMemo,nPos)
//fElapTime()
if !Empty(oBrow)
	if ( nAchou := ascan(acols,{|x| alltrim(cMemo) $ alltrim(x[npos]) },oBrow:nAt+1 ) ) > 0
		oBrow:nAt := nAchou
		oBrow:Refresh()
		
		EVAL( oBrow:bChange )
	else
		Alert("Nao encontrado")
	End
Else
	alert("Gere um relatorio Primeiro")
end

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  01/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function EscolheProf()
Local oDlg
Local oCombo
Local oGet
Local aCampos := {}
Local cCombo := "<<SELECIONE UM PERFIL>>"
Local cMemo := SPACE(30)
Local lOk := .F.
Local nAchou := 0
Local lNovo := .f.
//fElapTime()
aEval( Directory(cPathCubosAC+"param*.txt") ,{|x| aadd( aCampos, strtran(substr(x[1],6),".TXT","") ) } )

//DEFINE MSDIALOG oDlg FROM 0,0 TO oDlgMain:Nclientheight-30,oDlgMain:Nclientwidth-30 TITLE "Filtro" PIXEL
DEFINE MSDIALOG oDlg FROM 0,0 TO 200,600 TITLE "Escolha o perfil a ser usado" PIXEL
@ 1,1 Say "Perfil" Pixel
@ 1,2 COMBOBOX oCombo Var cCombo Items aCampos SIZE 90,20 Pixel

oCombo:nAt := aScan( aCampos , {|x| x == cEmpAntcFilAnt } )

@ 1,3 Say "" Pixel
@ 2,1 Say "Criar perfil com o nome" Pixel
//@ 1,4 get oGet var cMemo SIZE oDlg:Nclientwidth/2- 10,oDlg:Nclientheight/2 - 60 pixel
@ 2,2 get oGet var cMemo SIZE 90,11 pixel

//TMultiGet(): New ( [ nRow], [ nCol], [ bSetGet], [ oWnd], [ nWidth], [ nHeight], [ oFont], [ lHScroll], [ uParam9], [ uParam10], [ uParam11], [ lPixel], [ uParam13], [ uParam14], [ bWhen], [ uParam16], [ uParam17], [ lReadOnly], [ bValid], [ uParam20], [ uParam21], [ lNoBorder], [ lNoVScroll] ) --> oObjeto
@ 3,1 BUTTON "Confirmar" SIZE 50,10 Pixel ACTION ( lOk := (oCombo:nAt > 0), nPos := oCombo:nAt, ODLG:end() )
@ 3,2 BUTTON "Novo" SIZE 50,10 Pixel ACTION ( lOk := .t., lNovo := .t., ODLG:end() )
@ 3,3 BUTTON "Cancelar" SIZE 50,10 Pixel ACTION ( ODLG:end() )
@ 3,4 Say "" Pixel

@ 4,1 Say "" Pixel

Activate MsDialog oDlg Center on init AjustaTamanho(ODLG)
If lOk
	if !lNovo
		cEmpAntcFilAnt := aCampos[nPos]
	else
		cEmpAntcFilAnt := alltrim(cMemo)
	end
EndIf
Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/15/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function myjobs( aVetProc , cFunc )
Local x := 1
Local y := 1
Local z := 0
Local aRet := {} // retorno da fun็ใo
Local nHand
Local aEnvia := {}
Local aHands := {}
// arquivo de trava para o processo usar um criatrab ้ melhor
//Local cFile := "MICHEL" // nome ๚nico
Local cFile := criatrab(,.F.) // nome ๚nico
Local lMyDebug := .t. // liga ou desliga a multipla thread
//fElapTime()
private aTimeDif := {}
Private oChamado
nDivide := len(aVetProc)
// bloqueada a op็ใo por enquanto
if .f. // cRealUser $ cMultJob
	if len(aVetProc) < 50
		nMaxJob := aMaxJob[1]
	elseif len(aVetProc) < 100
		nMaxJob := aMaxJob[2]
	else
		nMaxJob := aMaxJob[3] // deve cair de 6h para 1h
	end
else
// executar no modo normal e saio
	cFunc += "()"
	&cFunc
	return
	nMaxJob := aMaxJob[1]
end
nDivide := ( len(aVetProc) / nMaxJob )

// determinar quantos processos serao
/*
1500 / 5
*/
y := 0
//alert("total " + alltochar(len(aVetProc)) )
//QOUT("TAREFAS " + ALLTOCHAR( len(aVetProc) ) )
//QOUT("DIVIDE " + ALLTOCHAR(nDivide) )
for  x := 1 to len(aVetProc)
	aadd(aEnvia,aVetProc[x])
	y++
	if y >= nDivide
//		FT_SAVEARR( {aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx},cFile+strzero(z,3)+"J.arr" )
		z++		
		SAVE ALL TO (cFile+strzero(z,3)+".MEM")
		aadd( ahands, fcreate(cFile+strzero(z,3)+".PAI" ) )
		StartJob ( cFunc, getenvserver(), .f., cFile+strzero(z,3) ,{cEmpAnt,cFilAnt},aEnvia,{aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx,aMultQ} )
//		sleep(1)
		aEnvia := {}
		y := 0
	end
next
// resido
if LEN(aEnvia) > 0
//	FT_SAVEARR( {aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx},cFile+strzero(z,3)+"J.arr" )	
	z++	
	SAVE ALL TO (cFile+strzero(z,3)+".MEM")
	aadd( ahands, fcreate(cFile+strzero(z,3)+".PAI" ) )
	StartJob ( cFunc, getenvserver(), .f., cFile+strzero(z,3),{cEmpAnt,cFilAnt}, aEnvia,{aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx,aMultQ} )
	aEnvia := {}

end

//garantia que vai dar tempo de criar o arquivo
sleep(10000)
lEnd := .f.
IF !Empty(aVetProc) 
While !lEnd .AND. !KILLAPP()
//tento pegar a variavel publica do vetor
	For x := 1 to Z
//		if file(cFile+strzero(x,3)+".arr")
/*
	FT_SAVEARR({aStruTmp,aTotaisSla,aFiltros,aFiltrosTmp,acols,acolsx},cFile+".ARR")
*/
//			aRet2 := FT_RESTARR(cFile+strzero(x,3)+".arr")
			aRet2 := multarray(,cFile+strzero(x,3),cFile)
//			n := 0
//			While empty(aRet2) .and. n++ < 10
//				sleep(1) // evitar erros de leitura
//				aRet2 := FT_RESTARR(cFile+strzero(x,3)+".arr")
//			end

			IF !Empty(aRet2)
				aTotaisSla[1] += aRet2[2,1]
				aTotaisSla[2] += aRet2[2,2]
				aTotaisSla[3] += aRet2[2,3]
				aTotaisSla[4] += aRet2[2,4]
				aTotaisSla[5] += aRet2[2,5]
				aTotaisSla[6] += aRet2[2,6]
				aTotaisSla[7] += aRet2[2,7]
				aTotaisSla[8] += aRet2[2,8]
//				next
				IF !Empty(aRet2[5])
//					for y := 1 to len(aRet2[5])
//						aadd(acols,aRet2[5,y])
						aadd(acols,aRet2[5])
//					next
					nquant++
				end
				if !Empty(aRet2[6])
//					for y := 1 to len(aRet2[6])
						aadd(acolsx,aRet2[6,y])
						aadd(acolsx,aRet2[6])
//					next
				end
				aTimeDif := aRet2[7] //michel
				oChamado := DashChamado():New()
				oChamado:CalcTime( aTimeDif )
				if ( lMUsers .or. cRealUser $ INTERMEDIARIO_ACESSO ).and. ( aFiltros[NSTATUS] == "Estatistica Geral" )
					dDataAdf := ctod(RetAcols("DABERTURA"))
					SomaADF(dDataAdf)
					TotalDash(dDataAdf)
				end
//				ferase(cFile+strzero(x,3)+".MEM")				
			END
//			ferase(cFile+strzero(x,3)+".ARR")	

//		end
	end
	// o job deve criar o arquivo imediatamente senao serแ ignorado
	
	// verificar se existe algum job em pe
	lEnd := .T.
	For x := 1 to Z
		if lEnd
			if  ( nHand := fCreate(cFile+strzero(x,3) ) ) < 0
	//			varinfo("Aguardando " , cFile+strzero(x,2) )
				lend := .F.
			end
			
			if nHand >= 0
				fclose(nHand)
			end
		end
	next
end
end

for x:= 1 to len(aHands)
	fclose(aHands[x])
	FERASE(cFile+strzero(x,3)+".PAI")
end
return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChamaExcel( lAbreTela )
Local oDlg		:= Nil
Local oRadio	:= Nil
Local nRadio	:= 1
Local cFile		:= ""
Local cPara		:= ""
Local lOk			:= .F.
Local cMensagem	:= ""
Local cArquivo	:= ""
Local cExtensao	:= ""
Local cPath		:= ""
Local cQuebra		:= ""
Default lAbreTela := .T.

//fElapTime()

If lAbreTela
	DEFINE MSDIALOG oDlg From 0,0 To 200,640 Title "Relatorio Excel" Pixel
	
	@ 1,1 Say "Escolha a Consulta" Pixel
	
	If cRealUser $ INTERMEDIARIO_ACESSO .or. lMUsers
		@ 2,1 RADIO oRadio VAR nRadio ITEMS "Analitico","Sintetico" Of oDlg SIZE 110,10 Pixel
	Else
		@ 2,1 RADIO oRadio VAR nRadio ITEMS "Analitico" Of oDlg SIZE 110,10 Pixel
	End
	
	@ 3,1 BUTTON "Confirmar" SIZE 40,11 Pixel Action ( lOk := .t.,oDLG:End())
	@ 3,2 BUTTON "Sair" SIZE 40,11 Pixel Action ( oDLG:End() )
	@ 4,1 Say "" Pixel
	
	Activate MSDIALOG oDLG Centered On Init AjustaTamanho( oDLG )
Else
	lOk := .T.
EndIf

If lOk
	If nRadio == 1
		If !lGerado .And. lAbreTela
			MudaOrdem()
		EndIf
		lGerado := .T.
		MYMsgRun( "Gerando temporario",, {|| lAgrupaTotais := .F., cFile := ExportExcel(,,,,,!lAbreTela)} )
		If !lAbreTela .And. !Empty( __cUserId ) .And. !Empty( cFile )
			cPara := UsrRetMail( __cUserId )
			If !Empty( cPara )
				SplitPath( cFile , , , @cArquivo , @cExtensao )
				cPath := "\Simc010\"
				If !ExistDir( cPath )
					MakeDir( cPath )
				EndIf
				CpyT2S( cFile , cPath )
				cArquivo := cPath + cArquivo + cExtensao
				If File( cArquivo )
					FErase( cFile )
					cFile     := cArquivo
					cQuebra   := Chr( 13 ) + Chr( 10 )
					cMensagem := "TOTVS - Dashboard" + cQuebra + cQuebra
					cMensagem += "Filtros:" + cQuebra
					cMensagem += "Metodo = " + aFiltros[NSTATUS] + cQuebra
					cMensagem += "Cliente = " + aFiltros[CLIENTE] + cQuebra
					cMensagem += "Tecnico = " + aFiltros[TECNICO] + cQuebra
					cMensagem += "Solucao = " + aFiltros[SOLUCAO] + cQuebra
					cMensagem += "Criticidade = " + aFiltros[CRITICIDADE] + cQuebra
					cMensagem += "Rotina = " + aFiltros[ROTINA] + cQuebra
					cMensagem += "Produto = " + aFiltros[PRODUTO] + cQuebra
					cMensagem += "Condicao = " + aFiltros[CONDICAO] + cQuebra
					cMensagem += "Ordem = " + aFiltros[ORDEM] + cQuebra
					cMensagem += "Equipe de " + aFiltros[EQUIPEDE] + " ate " + aFiltros[EQUIPEATE] + cQuebra
					cMensagem += "Data de " + DtoS( aFiltros[DATADE] ) + " ate " + DtoS( aFiltros[DATAATE] ) + cQuebra
					/*cMensagem += cQuebra + "Query = " + aFiltros[QUERY] + cQuebra + cQuebra
					If File( cFileConfig )
						cMensagem += "Configuracoes:" + cQuebra					
						cMensagem += MemoRead( cFileConfig )
						cMensagem += cQuebra + cQuebra
					EndIf*/
					cMensagem += "Gerado por " + __cUserId + "|" + cRealUser + " em " + DtoS( Date() )
				EndIf
				EnviaEmail( cPara , "Dash - " + aFiltros[NSTATUS] , cFile , cMensagem )
				FErase( cFile )
			EndIf
		EndIf
	Else
		ExcelSintetico( )
	EndIf
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  02/16/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Configura()
Local oDlg,oRadio
Local nRadio
Local lOk := .F.
//fElapTime()
Define MsDialog oDlg From 0,0 To 200,575 Title "Configura็๕es" Pixel
@ 1,1 Say "Escolha a Configura็ใo" Pixel

If cRealUser $ FULL_ACESSO .Or. lMUsers .Or. lSeeAll
	@ 2,1 Radio oRadio Var nRadio Items "Parโmetros","F๓rmulas","Permiss๕es" Of oDlg Size 110,10 Pixel
ElseIf cRealUser $ INTERMEDIARIO_ACESSO
	@ 2,1 Radio oRadio Var nRadio Items "Parโmetros","F๓rmulas" Of oDlg Size 110,10 Pixel
Else
	@ 2,1 Radio oRadio Var nRadio Items "Parโmetros" Of oDlg Size 110,10 Pixel
EndIf

@ 3,1 Say "" Pixel
@ 4,1  BUTTON "Confirmar" SIZE 40,11 Pixel ACTION ( lOk := .t.,oDLG:End())
@ 4,2  BUTTON "Sair" SIZE 40,11 Pixel ACTION ( oDLG:End() )
@ 5,1 Say "" Pixel

Activate MsDialog oDLG Centered On Init AjustaTamanho( oDlg )

If lOk
	If nRadio == 1
		MontaAnalista()
	ElseIf nRadio == 2
		MontaForm()
	ElseIf nRadio ==3
		MontaAcesso()
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function multarray(uVar,cMemory,cFile)
Local uRet
Local ntenta := 0
//fElapTime()
if valtype(uVar) == "A"
	// montagem da string
//	uRet := Array2StrX(uVar) // compatibilizando com o ft_savarr
	uRet := multarra2(uVar)
	if !Empty(cMemory) .and. !Empty(uRet)
		cMemory := alltrim(pad(cMemory,8))
//		qOut("SIMC010 - Enviando " + cMemory +"-"+ time())			
//		qOut("Aguardando a limpeza " + cMemory + time())
		While !empty(GetGlbValue(cMemory) ) .and. !Killapp() .and. ( file(cFile+".PAI") .and. ferase(cFile+".PAI") == -1 ) .and. ntenta++ < 10
			sleep(1)
		end
		if ntenta >= 10
			qout("SIMC010 - timeout " + cMemory +"-" +time())
		end
		PutGlbValue(cMemory,uRet)
	else
		qout("SIMC010 - Erro na variavel ")
	end
else
	if !Empty(cMemory)
		cMemory := alltrim(pad(cMemory,8))
//		Alert("RECEBE " + cMemory)
	//michel
//		qOut("Recebendo " + cMemory + time())	
		uVar := GetGlbValue(cMemory)
//		Alert("Recebi " + uVar)
//		While empty( uVar := GetGlbValue(cMemory) ) .and. !Killapp() .and. ( file(cFile+".PAI") .and. ferase(cFile+".PAI") == -1 )
//			sleep(1)
//		end
//		qOut("Recebi " + cMemory + time())
		PutGlbValue(cMemory,"")
		ClearGlbValue(cMemory)
	end
//		Alert("Limpei " + GetGlbValue(cMemory))
	If !Empty(uVar)
//		uRet := Str2Arrayx(uVar)
		uRet := multarra2(uVar)
	end
end

Return uRet

/*

cGlbName  := "TPL_GLBVALUE"
cGlbValue := ""

// Alimenta variแvel
PutGlbValue(cGlbName,"Teste")

// Verifica valor da variแvel 
cGlbValue := GetGlbValue(cGlbName)

// Limpa variแvel
if Trim(cGlbValue) <> ""
  ClearGlbValue(cGlbName)
endif

*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

static function multarra2(uVar)
Local uRet
Local x
//fElapTime()
if valtype(uVar) == "A"
	// montagem da string
	uRet := "{"
	for x := 1 to len(uvar)
		
		if valtype(uVar[x]) == "A"
			uRet += multarra2(uVar[x])
		Else
			if valtype(uVar[x]) == "C"
				uRet += '"'
			elseif valtype(uVar[x]) == "D"
				uRet += 'CTOD("'
			end
			
			uVar[x] := STRTRAN(uVar[x],'"',"'")
			uVar[x] := STRTRAN(uVar[x],chr(13)+chr(10),"")
			
			uRet += ALLTRIM(alltochar( uVar[x] ))
			if valtype(uVar[x]) == "C"
				uRet += '"'
			elseif valtype(uVar[x]) == "D"
				uRet += '")'
			end
		end
		uRet += ","
	next
	uRet += "}"	
else
	uRet := &(uVar)
end

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFaixa3    บAutor  ณNorberto M de Melo  บ Data ณ  04/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao de controle dos chamados de SLA Faixa 3             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Faixa3()
Local uRet := nil
//fElapTime()
KeySet( ksACTION_OFF )

oObj := TeleServiceDashDialog():New()
oObj:OpenBrowse( Nil , Nil , Nil , Nil , MenuDef() )

KeySet( ksACTION_ON )
Return uRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณKeySet    บAutor  ณNorberto M de Melo  บ Data ณ  04/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao auxiliar para Ativar/Desativar as teclas de funcao. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function KeySet( nAction )
//fElapTime()
Default _bKeyF10 	:= SetKey( 121, {|| .T. } )	// Tecla de funcao F10
Default _bKeyF11	:= SetKey( 122, {|| .T. } )	// Tecla de funcao F11

If		!Empty( nAction ) .and. ( nAction == ksACTION_ON )
	// Restaura as Teclas de Funcoes
	SetKey( 121, _bkeyF10 )	// F10
	SetKey( 122, _bkeyF11 )	// F11
ElseIf	!Empty( nAction ) .and. ( nAction == ksACTION_OFF )
	// Desliga Teclas de Funcoes
	SetKey( 121, NIL )	// F10
	SetKey( 122, NIL )	// F11
EndIf

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณNorberto M de Melo  บ Data ณ  04/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotinas de Acesso para a tela dse atendimento.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef( )
Local aRotina
//fElapTime()               
aRotina	:=	{	{ "Pesquisar"	,"AxPesqui"  ,0,1 }	,;
				{ "Visualizar" 	,"TK503AOpc" ,0,2 }	}
Return( aRotina )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClass     ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  04/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class TeleServiceDashDialog From TeleServiceDialog

Data aCols			AS ARRAY
Data aHeader		AS ARRAY

Data cCodLig        AS CHARACTER	//Codigo da lista, utilizado quando lista de ativo
Data cContValue     AS CHARACTER	//Codigo do contato
Data cEntName       AS CHARACTER	//Nome da entidade
Data cEntValue      AS CHARACTER	//Valor da Chave de busca da entidade

Data lAuto          AS LOGICAL		//Indica se esta em modo automatico

Data nOpc           AS NUMERIC		//Codigo de abertura de tela
Data nStackSX8      AS NUMERIC		//Armazena o codigo da pilha do SX8

Data oDlg			AS OBJECT		// 

Method Init()
Method new() 		Constructor

Method openBrowse()

Method GetModel( lVisFilDif )
Method Tk503Browse()
                                   
EndClass


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณNew       บAutor  ณNorberto M de Melo  บ Data ณ  04/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New() Class TeleServiceDashDialog
	::Init()  
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณInit      บAutor  ณNorberto M de Melo  บ Data ณ  04/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method Init() Class TeleServiceDashDialog

DEFAULT ::cEntValue 	:= "" 
DEFAULT ::cEntName  	:= ""
DEFAULT ::cContValue	:= "" 
DEFAULT ::cCodLig 		:= "" 

DEFAULT ::lAuto			:= .F.

DEFAULT ::nOpc			:= 0
DEFAULT ::nStackSX8		:= 0

DEFAULT ::Service 		:= TeleServicing():New()

Return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณOpenBrowse บAutor  ณNorberto M de Melo บ Data ณ  09/11/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a tela de escolha do modelo de atendimento.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method OpenBrowse( xAutoCab, xAutoItens, nOpcAuto, xRegCode, aRotOpc ) Class TeleServiceDashDialog
Local cAliasUser	:= "" 		// Alias da tabela Master (a partir do configurador)
Local cAt503Fil		:= ""		// Filtro fornecido pelo ponto de entrada
Local bFiltraBrw	:= {||}		// Bloco de c๓digo para execu็ใo do filtro
Local aIndex		:= {}		// Indice da tabela
Local cFiltra		:= ""		// Filtro utilizado no bloco de c๓digo executado para ativar o filtro
Local cTeleServID	:= ""		// Armazena o codigo do TeleAtendimento associado ao Grupo do Operador.
Private aRotina		:= {}		// Variavel utilizada no mBrowse da tela
Private aCores 		:= {}

Default aRotOpc		:= MenuDef()// Carrega o aRotinas padrใo para tela de TeleAtendimento

aRotina	:= aRotOpc

// Carrega o modelo de atendimento
cTeleServID := Self:GetModel()

If !Empty(cTeleServID)
	If Self:service:load(cTeleServID)
		cAliasUser := Self:service:tableStructureInfo:master:alias
		
		DbSelectArea(cAliasUser)
		
		// Verifica a existencia de Filtros na MBrowse
		If (ExistBlock("TK503AFIL"))
			cAt503Fil := ExecBlock("TK503AFIL",.F.,.F.)
			If ( ValType(cAt503Fil) == "C" ) .And. !Empty(cAt503Fil)
				cFiltra := cAt503Fil
			EndIf
			bFiltraBrw 	:= {|| FilBrowse(cAliasUser,@aIndex,@cFiltra) }
			Eval(bFiltraBrw)
		EndIf
		
		SU0->(DbSetOrder(1))
		If SU0-> ( MsSeek(xFilial("SU0")+ Posicione("SU7", 4, MyxFilial("SU7")+__cUserId, "U7_POSTO") ) )
			If SU0->(FieldPos("U0_MSBLQL") ) > 0  .AND. SU0->U0_MSBLQL == "1"
				Final( "Usuแrio pertence a um grupo de atendimento bloqueado" )
				Return Nil
			EndIf
		EndIf
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณIncluida chamada de fun็ใo para atualiza็ใoณ
		//ณdo modelo de atendimento do Service Desk   ณ
		//ณna inicializa็ใo do TeleAtendimento        ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		TMKA510LOAD()
		
		DbSetOrder(1)
		DbSeek(xFilial(cAliasUser))
		
		MsgRun("Aguarde...Carregando informacoes", "Teleatendimento", {||Self:Tk503Browse(cAliasUser) })
		
		// Finaliza o uso da funcao FilBrowse e retorna os indices padroes.
		If !Empty( cFiltra ) .AND. Len( aIndex ) > 0
			EndFilBrw( cAliasUser, aIndex )
		EndIf
		
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณGetModel  บAutor  ณNorberto M de Melo  บ Data ณ  04/05/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GetModel(lVisFilDif) Class TeleServiceDashDialog
Local cModelo		:= ""		//Cod. do modelo de atendimento

Default lVisFilDif	:= .F.		// Visualiza chamamdos de filiais diferentes

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se o USUARIO nao estiver cadastrado em OPERADORES e nao tiver	ณ
//ณ um Posto de Venda associado nao entra na rotina					ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Self:lAuto .AND. !TMKOPERADOR(,,lVisFilDif)
	If !IsBlind()
		Help("  ",1,"OPERADOR")
	Else
		cModelo := SU0->U0_CODSKA
	EndIf
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Pega o modelo no grupo de atendimento ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cModelo := SU0->U0_CODSKA
EndIf

If Empty(cModelo)
	Help( " ",1,"TSOPERAD",,;
	"- Operador relacionado a um " + CRLF + ;
	"Grupo de Atendimento que nใo atende o " + CRLF + ;
	"TeleAtendimento. " + CRLF  + CRLF + ;
	"- Verificar as configura็๕es do"  + CRLF + ;
	"Grupo de Atendimento",1,1)
EndIf

Return cModelo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณTk503BrowseบAutor  ณNorberto M de Melo บ Data ณ  04/05/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Tk503Browse(cAlias) Class TeleServiceDashDialog
oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAlias)
oBrowse:Activate()
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณTk503BrowseบAutor  ณNorberto M de Melo บ Data ณ  12/07/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldFabrica( )
Local lOk	:= .F.
Local nRec	:= ADF->( RECNO( ) )
Local bEval	:= {|| ADF->( MyxFilial( "ADF" ) + ADF_CODIGO ) == ADENEW->( XFILIAL("ADE") + ADE_CODIGO ) }

//fElapTime()

ADF->( DbSkip() )

While	!ADF->( Eof() ) .and. Eval( bEval ) .and. AllTrim( ADF->ADF_CODSU0 ) $ "HM/PP"
	ADF->( dbSkip() )
EndDo

If Eval( bEval )
	lOk := ( ADF->ADF_CODSU0 $ SLA_FSW ) .or. ( ADENEW->ADE_GRUPO $ SLA_FSW )
EndIf

ADF->( DBGoTo( nRec ) )

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMethod    ณTk503BrowseบAutor  ณNorberto M de Melo บ Data ณ  12/07/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VldRetFab()
Local lOk	:= .F.
Local nRec	:= ADF->( RecNo() )

//fElapTime()

ADF->(dbSkip())
While !ADF->(EOF()) .AND. ADF->(XFILIAL()+ADF_CODIGO) == ADENEW->(XFILIAL("ADE")+ADE_CODIGO).and. alltrim(ADF->ADF_CODSU0) $ "HM/PP"
	ADF->(dbSkip())
EndDo

lOk :=  If( ADF->(XFILIAL()+ADF_CODIGO) <> ADENEW->(XFILIAL("ADE")+ADE_CODIGO),.F.,ADF->ADF_CODSU0 $ aFiltros[EQUIPEATE]) .or.;
        If( ADF->(XFILIAL()+ADF_CODIGO) <> ADENEW->(XFILIAL("ADE")+ADE_CODIGO),ADENEW->ADE_GRUPO $ aFiltros[EQUIPEATE],.F.)
        
ADF->( dbGoto(nRec) )

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  06/30/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fElapTime( lFim )
Default lFim := .F.

If .F. //cRealUser == "TI2899"
	If		Len(aElapTime) > 1
		Atail(aElapTime)[4] := Time()
		Atail(aElapTime)[5] := ElapTime( Atail(aElapTime)[3], Atail(aElapTime)[4] )
	ElseIf	Len( aElapTime ) == 0
		AADD(aElapTime,{"PROG2","PROG1","INICIO","TERMINO","DECORRIDO"})
	EndIf
	If Empty(lFim)
		AADD(aElapTime,{ProcName(2),ProcName(1),Time(),,})
	EndIf
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  08/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChkNextADF( cCodSU0 )
Local lRet	:= .F.
Local aArea	:= ADF->( GetArea() )

Default cCodSU0 := ''

ADF->( DBSkip( ) )
If	!ADF->( EOF() )	.and. ( ADF->ADF_CODIGO == ADENEW->ADE_CODIGO )
	lRet := ( cCodSU0 == ADF->ADF_CODSU0 )
EndIf

RestArea( aArea )
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  09/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ExecPoint( cKey )
Return ( AScan( aPointRest, {|e| e == cKey } ) == 0 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  09/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetTableHTML( cTitulo, aSource, aCond )
Local cHtml := ""
Local i		:= 0
Local j		:= 0
Local nInd	:= 0
Local nPos	:= 0
Local nTotal:= 0
Local cText	:= ""

DEFAULT aCond := {}
                   
cHtml += '      <table width="781" border="1" class="fontepadrao">'
cHtml += '         <tr bgcolor="#000000">'
cHtml += '            <td width="621"><strong id="TOTAL">' + cTitulo + '</strong></td>'
cHtml += '            <td colspan="2" width="144" align="center"><strong id="TOTAL">TOTAL</strong></td>'
cHtml += '         </tr>'

cHtml += '         <tr bgcolor="#CCCCCC">'
cHtml += '            <td width="621"></td>'
cHtml += '            <td width="070" align="center"><strong id="QTDE">QTDE</strong></td>'
cHtml += '            <td width="070" align="center"><strong id="%">%</strong></td>'
cHtml += '         </tr>'

For j := 1 to Len( aCond )

	// Totaliza o Sub-Titulo
	nTotal := 0
	AEval( aSource, {|e| nTotal += If( e[2] == aCond[j][1], e[6], 0) } )
	
	// Procura pelo primeiro elemento da condicao atual
	nPos := AScan( aSource, {|e| e[2] == aCond[j][1] } )
	
	If nPos > 0
		cHTML += GetLineHTML( aCond[j][3], .T., nTotal, 100 )
		
		If aCond[j][2]	// Imprime Detalhe
			For i := nPos To Len( aSource )
				If aSource[i][2] == aCond[j][1]
					cText := aSource[i][3]
					If !Empty( aCond[j][4] ) .and.;
						( AScan( aCond[j][4], {|e| UPPER( e[1] ) == UPPER( cText ) } ) > 0 )
						cText := aCond[j][4][AScan( aCond[j][4], {|e| UPPER( e[1] ) == UPPER( cText ) } )][2]
					EndIf
					cHTML += GetLineHTML( cText, .F., aSource[i][6], Round((aSource[i][6]/nTotal)*100,2) )
				Else
					Exit
				EndIf
			Next i
		Else		// Nao Imprime Detalhe
			cHTML += GetLineHTML( aSource[nPos][2], .F., nTotal, 100 )
		EndIf
		
	EndIf
Next j

cHtml += '      </table>'

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSIMC010   บAutor  ณMicrosiga           บ Data ณ  09/11/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetLineHTML( cDescLine, lSubTit, nValue, nPerc )
Local cHTML		:= ""

If lSubTit
	cHtml += '         <tr>'
	cHtml += '            <td><strong>' + cDescLine + '</strong></td>'
	cHtml += '            <td align="right"><strong>' + STR( nValue ) + '</strong></td>'
	cHtml += '            <td align="right"><strong>' + STR( nPerc, 6, 2 ) + '</strong></td>'
Else
	cHtml += '         <tr bgcolor="#CCCCCC">'
	cHtml += '            <td> &nbsp;&nbsp;&nbsp;' + cDescLine + '</td>'
	cHtml += '            <td align="right">' + STR( nValue ) + '</td>'
	cHtml += '            <td align="right">' + STR( nPerc, 6, 2 ) + '</td>'
EndIf
	
cHtml += '         </tr>'

Return cHTML

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ VarsZ26     บAutor  ณ Daniel Mendes   บ Data ณ  01/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controla as variแveis estแticas para as consultas na Z26   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VarsZ26()
//Performance
Static nTamCli  := TamSx3( "Z26_CLIENT" )[ 1 ]
Static nTamLoja := TamSx3( "Z26_LOJA" )[ 1 ]
Static cFilZPD  := MyxFilial( "ZPD" )
Static cFilZ26  := MyxFilial( "Z26" )
Static cFilZ27  := MyxFilial( "Z27" )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GetCalcFxs  บAutor  ณ Daniel Mendes   บ Data ณ  15/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna as horas com base no cadastro da Z26               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetCalcFxs( cVarAux )
Static aFaixasCli := {}
Local aArea		 := GetArea()
Local cFaixa01   := "|TMP1ATDE|"
Local cFaixa02   := "|F2_ALT_URG|F2_MED|F2_BAIXA|"
Local cFaixa03   := "|F3_ALT_URG|F3_MED|F3_BAIXA|"
Local cFaixa04   := "|F3_FSW_ALT_URG|F3_FSW_MED|F3_FSW_BAIXA|"
Local cCampoAux  := "% Z26.Z26_"
Local cSevrdd    := ""
Local cFaixa     := ""
Local cRetHrs    := ""
Local cClientADE := ""
Local cLojaADE   := ""
Local cCmpQry    := ""
Local cQueryZXX  := ""
Local cChavBsc   := ""
Local nPosAux    := 0
Local cCodSLA	 := ""

Static aSk9 	 := {}

BuscaSK9()

If lUsaZ26Clc .And. SELECT( "ADENEW" ) > 0
	VarsZ26()

	Do Case
		Case cVarAux $ cFaixa01
			cFaixa := "1"
			cCodSLA := cSLAFAIXA1
			cCampoAux += "FX1 = 'T' %"
		Case cVarAux $ cFaixa02
			cFaixa := "2"
			cCodSLA := cSLAFAIXA2
			cCampoAux += "FX2 = 'T' %"
		Case cVarAux $ cFaixa03
			cFaixa := "3"
			cCodSLA := cSLAFAIXA3
			cCampoAux += "FX3P = 'T' %"
		Case cVarAux $ cFaixa04
			cFaixa := "4"
			cCodSLA := cSLAFAIXA4
			cCampoAux += "FX3E = 'T' %"
		OtherWise
			cFaixa := ""
			cCodSLA := ""
			cCampoAux += "FX1 = 'X' %"//Evitar erro ao abrir a query 
	EndCase

	Do Case
		Case ADENEW->ADE_SEVCOD $ "|1|" // Planejada
			cSevrdd := "100"
		Case ADENEW->ADE_SEVCOD $ "|2|" // Baixa
			cSevrdd := "400"
		Case ADENEW->ADE_SEVCOD $ "|3|" // Media
			cSevrdd := "600"
		Case ADENEW->ADE_SEVCOD $ "|4|" // Alta
			cSevrdd := "800"
		Case ADENEW->ADE_SEVCOD $ "|5|" // Critica
			cSevrdd := "999"
		OtherWise
			cSevrdd := ""
	EndCase

	cClientADE := SubStr( Trim( ADENEW->ADE_CHAVE ) , 1 , nTamCli )
	cLojaADE   := SubStr( Trim( ADENEW->ADE_CHAVE ) , nTamCli + 1 , nTamLoja )
	cChavBsc   := cFilZ26 + cFilZ27 + cFilZPD + cClientADE + cLojaADE + cFaixa + cSevrdd 
	cChavBsc   += ADENEW->( ADE_FILIAL + ADE_CODSB1 + DtoS( ADE_DATA ) )
	nPosAux    := aScan( aFaixasCli , {|x| x[1] == cChavBsc } )

	If Empty( nPosAux )
		cQueryZXX  := GetNextAlias()

		BeginSql Alias cQueryZXX
			SELECT ZPD.ZPD_HREXPI
			  FROM %Table:ZPD% ZPD
			 INNER JOIN %Table:Z26% Z26
			    ON Z26.Z26_FILIAL = %Exp:cFilZ26%
			   AND Z26.%NotDel%
			   AND Z26.Z26_CLIENT = %Exp:cClientADE%
			   AND Z26.Z26_LOJA   = %Exp:cLojaADE%
			   AND %Exp:ADENEW->ADE_DATA% BETWEEN Z26.Z26_DTCAD AND Z26.Z26_DTVIGE
			   AND %Exp:cCampoAux%
			  LEFT JOIN %Table:Z27% Z27
			    ON Z27.Z27_FILIAL = %Exp:cFilZ27%
			   AND Z27.%NotDel%
			   AND Z27.Z27_PRODUT = %Exp:ADENEW->ADE_CODSB1%
			   AND Z27.Z27_SLAESP = '1'
			   AND Z27.Z27_ITEM   = Z26_CODPRI
			   AND Z27.Z27_PRODUT = ZPD.ZPD_PRODUT
			   AND Z27.Z27_FILPRD = ZPD.ZPD_FILPRD
			 WHERE ZPD.ZPD_FILIAL = %Exp:cFilZPD%   
			   AND ZPD.%NotDel%
			   AND ZPD.ZPD_CLIENT = %Exp:cClientADE%
			   AND ZPD.ZPD_LOJA   = %Exp:cLojaADE%
			   AND ZPD.ZPD_FILPRD = %Exp:ADENEW->ADE_FILIAL%
			   AND ZPD.ZPD_FAIXA  = %Exp:cFaixa%
			   AND ZPD.ZPD_SEVE   = %Exp:cSevrdd%
			 ORDER BY ZPD.ZPD_PRODUT DESC
		EndSql

		If !(cQueryZXX)->( Eof() )
			cRetHrs := nToTime( TimeToMin( cValToChar( (cQueryZXX)->( ZPD_HREXPI ) ) ) * 60 )
		Else
			// fa็o a busca na SK9
			nPosAux := aScan( aSk9 , {|x| x[2] == cSevrdd .And. x[6] == cCodSLA } )
			
			If nPosAux > 0
				cRetHrs := aSk9[nPosAux,4]
			Else
				cRetHrs := &( cVarAux )
			Endif
		EndIf

		aAdd( aFaixasCli , { cChavBsc , cRetHrs } )
		(cQueryZXX)->( dbCloseArea() )
	Else
		cRetHrs := aFaixasCli[ nPosAux , 2 ]
	EndIf
Else
	cRetHrs := &( cVarAux )
EndIf

RestArea( aArea )

Return cRetHrs

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ClcTmpCorr  บAutor  ณ Daniel Mendes   บ Data ณ  01/06/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua o cแlculo corrido das faixas, somando todas elas    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ClcTmpCorr()
Static aTimsFxCli := {}
Local aArea		 := GetArea()
Local cSevrdd    := ""
Local cClientADE := ""
Local cLojaADE   := ""
Local cCmpQry    := ""
Local cQueryZXX  := ""
Local cChavBsc   := ""
Local cZerado    := ""
Local nMinHora   := 60
Local nNumAux    := 0
Local nTotFxs    := 0
Local cTmpAux    := 0
Local aRetTimes  := { 0 , 0 , 0 , 0 }

If lUsaZ26Clc .And. ( !Empty( Select( "ADENEW" ) ) )
	VarsZ26()

	If At( ":" , TMP1ATDE ) > 0
		aRetTimes[ 1 ] := TimeToMin( TMP1ATDE )
	EndIf

	Do Case
		Case ADENEW->ADE_SEVCOD $ "|1|"
			cSevrdd := "100"
			aRetTimes[ 2 ] := 0
			aRetTimes[ 3 ] := 0
			aRetTimes[ 4 ] := 0

		Case ADENEW->ADE_SEVCOD $ "|2|"
			cSevrdd := "400"
			If At( ":" , F2_BAIXA ) > 0
				aRetTimes[ 2 ] := TimeToMin( F2_BAIXA )
			EndIf
			If At( ":" , F3_BAIXA ) > 0
				aRetTimes[ 3 ] := TimeToMin( F3_BAIXA )
			EndIf
			If At( ":" , F3_FSW_BAIXA ) > 0
				aRetTimes[ 4 ] := TimeToMin( F3_FSW_BAIXA )
			EndIf
		Case ADENEW->ADE_SEVCOD $ "|3|"
			cSevrdd := "600"
			If At( ":" , F2_MED ) > 0
				aRetTimes[ 2 ] := TimeToMin( F2_MED )
			EndIf
			If At( ":" , F3_MED ) > 0
				aRetTimes[ 3 ] := TimeToMin( F3_MED )
			EndIf
			If At( ":" , F3_FSW_MED ) > 0
				aRetTimes[ 4 ] := TimeToMin( F3_FSW_MED )
			EndIf
		Case ADENEW->ADE_SEVCOD $ "|4|"
			cSevrdd := "800"
			If At( ":" , F2_ALT_URG ) > 0
				aRetTimes[ 2 ] := TimeToMin( F2_ALT_URG )
			EndIf
			If At( ":" , F3_ALT_URG ) > 0
				aRetTimes[ 3 ] := TimeToMin( F3_ALT_URG )
			EndIf
			If At( ":" , F3_FSW_ALT_URG ) > 0
				aRetTimes[ 4 ] := TimeToMin( F3_FSW_ALT_URG )
			EndIf
		Case ADENEW->ADE_SEVCOD $ "|5|"
			cSevrdd := "999"
			If At( ":" , F2_ALT_URG ) > 0
				aRetTimes[ 2 ] := TimeToMin( F2_ALT_URG )
			EndIf
			If At( ":" , F3_ALT_URG ) > 0
				aRetTimes[ 3 ] := TimeToMin( F3_ALT_URG )
			EndIf
			If At( ":" , F3_FSW_ALT_URG ) > 0
				aRetTimes[ 4 ] := TimeToMin( F3_FSW_ALT_URG )
			EndIf
		OtherWise
			cSevrdd := ""
	EndCase

	cClientADE := SubStr( Trim( ADENEW->ADE_CHAVE ) , 1 , nTamCli )
	cLojaADE   := SubStr( Trim( ADENEW->ADE_CHAVE ) , nTamCli + 1 , nTamLoja )
	cChavBsc   := cFilZ26 + cFilZ27 + cFilZPD + cClientADE + cLojaADE + cSevrdd 
	cChavBsc   += ADENEW->( ADE_FILIAL + ADE_CODSB1 + DtoS( ADE_DATA ) )
	nNumAux    := aScan( aTimsFxCli , {|x| x[1] == cChavBsc } )

	If Empty( nNumAux )
		cQueryZXX  := GetNextAlias()

		BeginSql Alias cQueryZXX
			SELECT ZPD.ZPD_HREXPI
			     , ZPD.ZPD_FAIXA
			     , Z26.Z26_FX1
			     , Z26.Z26_FX2
			     , Z26.Z26_FX3P
			     , Z26.Z26_FX3E
			  FROM %Table:ZPD% ZPD
			 INNER JOIN %Table:Z26% Z26
			    ON Z26.Z26_FILIAL = %Exp:cFilZ26%
			   AND Z26.%NotDel%
			   AND Z26.Z26_CLIENT = %Exp:cClientADE%
			   AND Z26.Z26_LOJA   = %Exp:cLojaADE%
			   AND %Exp:ADENEW->ADE_DATA% BETWEEN Z26.Z26_DTCAD AND Z26.Z26_DTVIGE
			  LEFT JOIN %Table:Z27% Z27
			    ON Z27.Z27_FILIAL = %Exp:cFilZ27%
			   AND Z27.%NotDel%
			   AND Z27.Z27_PRODUT = %Exp:ADENEW->ADE_CODSB1%
			   AND Z27.Z27_SLAESP = '1'
			   AND Z27.Z27_ITEM   = Z26_CODPRI
			   AND Z27.Z27_PRODUT = ZPD.ZPD_PRODUT
			   AND Z27.Z27_FILPRD = ZPD.ZPD_FILPRD
			 WHERE ZPD.ZPD_FILIAL = %Exp:cFilZPD%   
			   AND ZPD.%NotDel%
			   AND ZPD.ZPD_CLIENT = %Exp:cClientADE%
			   AND ZPD.ZPD_LOJA   = %Exp:cLojaADE%
			   AND ZPD.ZPD_FILPRD = %Exp:ADENEW->ADE_FILIAL%
			   AND ZPD.ZPD_SEVE   = %Exp:cSevrdd%
			 ORDER BY ZPD.ZPD_PRODUT DESC
		EndSql

		If !(cQueryZXX)->( Eof() )
			nNumAux   := 0

			While !(cQueryZXX)->( Eof() )
				Do Case
					Case (cQueryZXX)->ZPD_FAIXA == "1" .And. (cQueryZXX)->Z26_FX1 == "T"
						aRetTimes[ 1 ] := TimeToMin( cValToChar( (cQueryZXX)->ZPD_HREXPI ) )
					Case (cQueryZXX)->ZPD_FAIXA == "2" .And. (cQueryZXX)->Z26_FX1 == "T"
						aRetTimes[ 2 ] := TimeToMin( cValToChar( (cQueryZXX)->ZPD_HREXPI ) )
					Case (cQueryZXX)->ZPD_FAIXA == "3" .And. (cQueryZXX)->Z26_FX3P == "T"
						aRetTimes[ 3 ] := TimeToMin( cValToChar( (cQueryZXX)->ZPD_HREXPI ) )
					Case (cQueryZXX)->ZPD_FAIXA == "4" .And. (cQueryZXX)->Z26_FX3E == "T"
						aRetTimes[ 4 ] := TimeToMin( cValToChar( (cQueryZXX)->ZPD_HREXPI ) )
				EndCase

				(cQueryZXX)->( dbSkip() )
				nNumAux++

				If nNumAux >= 4
					Exit
				EndIf
			EndDo
		EndIf

		aAdd( aTimsFxCli , { cChavBsc , aClone( aRetTimes ) } )
		(cQueryZXX)->( dbCloseArea() )
	Else
		aRetTimes := aClone( aTimsFxCli[ nNumAux , 2 ] )
	EndIf
EndIf

If lUsaZ26Clc
	nNumAux := aRetTimes[ 1 ] + aRetTimes[ 2 ] + aRetTimes[ 3 ] + aRetTimes[ 4 ]
	AddValor( "MIN_FX1" , nToTime( aRetTimes[ 1 ] * nMinHora ) )
	AddValor( "MIN_FX2" , nToTime( aRetTimes[ 2 ] * nMinHora ) )
	AddValor( "MIN_FX3" , nToTime( aRetTimes[ 3 ] * nMinHora ) )
	AddValor( "MIN_FX4" , nToTime( aRetTimes[ 4 ] * nMinHora ) )

	cTmpAux := AllTrim( RetACols( "FAIXA1_TP" , , "" ) )
	If !Empty( cTmpAux ) .And. At( ":" , cTmpAux ) > 0
		nTotFxs += TimeToMin( cTmpAux )
	EndIf
	cTmpAux := AllTrim( RetACols( "FAIXA2_TP" , , "" ) )
	If !Empty( cTmpAux ) .And. At( ":" , cTmpAux ) > 0
		nTotFxs += TimeToMin( cTmpAux )
	EndIf
	cTmpAux := AllTrim( RetACols( "FAIXA3_TP" , , "" ) )
	If !Empty( cTmpAux ) .And. At( ":" , cTmpAux ) > 0
		nTotFxs += TimeToMin( cTmpAux )
	EndIf
	cTmpAux := AllTrim( RetACols( "FAIXA4_TP" , , "" ) )
	If !Empty( cTmpAux ) .And. At( ":" , cTmpAux ) > 0
		nTotFxs += TimeToMin( cTmpAux )
	EndIf

	AddValor( "TEMPO_COR" , nToTime( nTotFxs * nMinHora ) )

	If nTotFxs > nNumAux
		AddValor( "SITUAC_COR" , OFF_TIME_SLA )
	Else
		AddValor( "SITUAC_COR" , ON_TIME_SLA  )
	EndIf
Else
	cZerado := nToTime( 0 )
	AddValor( "MIN_FX1"    , cZerado )
	AddValor( "MIN_FX2"    , cZerado )
	AddValor( "MIN_FX3"    , cZerado )
	AddValor( "MIN_FX4"    , cZerado )
	AddValor( "TEMPO_COR"  , NOT_EXIST_SLA )
	AddValor( "SITUAC_COR" , NOT_EXIST_SLA )
EndIf

RestArea( aArea )

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GetTextoIn  บAutor  ณ Daniel Mendes   บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo auxiliar para montar o IN da query                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetTextoIn( cTexto )

cTexto := StrTran( StrTran( AllTrim( cTexto ) , ";" , "," ) , "|" , "," )//Caso tenha sido separado de outra forma

If SubStr( cTexto , 1 , 1 ) == ","//Remove a virgula da primeira posi็ใo
	cTexto := AllTrim( SubStr( cTexto , 2 , Len( cTexto ) ) )
EndIf

If SubStr( cTexto , Len( cTexto ) , 1 ) == ","//Remove a virgula da ultima posi็ใo
	cTexto := AllTrim( SubStr( cTexto , 1 , Len( cTexto ) - 1 ) )
EndIf

Return cTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GetCnctVrg  บAutor  ณ Daniel Mendes   บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo auxiliar para montar o IN da query                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetCnctVrg( cTexto )
If !Empty( cTexto ) .And. SubStr( cTexto , Len( cTexto ) , 1 ) <> ","
	cTexto += ","
EndIf
Return cTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MntInFaixa  บAutor  ณ Daniel Mendes   บ Data ณ  15/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o In para o SQL filtrar somente chamados que       บฑฑ
ฑฑบ          ณ posseum intera็ใo de fแbrica, atendimento ou manuten็ใo    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntInFaixa()
Local cInFaixa := ""
Local cInAux   := ""

If cTpStatist <> "Geral" .And. aFiltros[NSTATUS] == "Estatistica Geral"
	Do Case
		Case cTpStatist == "Manuten็ใo"
			cInAux := GetTextoIn( TPFX3INI )
			cInAux := GetCnctVrg( cInAux )
			cInAux += GetTextoIn( TPFX3FIM )
		Case cTpStatist == "Especํfico"
			cInAux := GetTextoIn( TPFX4INI )
			cInAux := GetCnctVrg( cInAux )
			cInAux += GetTextoIn( TPFX4FIM )
		Case cTpStatist == "Atendimento"
			cInAux := GetTextoIn( TPFX1INI )
			cInAux := GetCnctVrg( cInAux )
			cInAux += GetTextoIn( TPFX1FIM )
			cInAux := GetCnctVrg( cInAux )
			cInAux += GetTextoIn( TPFX2INI )
			cInAux := GetCnctVrg( cInAux )
			cInAux += GetTextoIn( TPFX2FIM )
		OtherWise
			cInAux := ""
	EndCase

	If !Empty( cInAux )
		cInAux   := GetTextoIn( cInAux )
		cInFaixa := " ADF_CODSUQ IN " + FormatIn( cInAux  , "," ) + " AND "
	EndIf
EndIf

Return cInFaixa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MntInCliFx  บAutor  ณ Daniel Mendes   บ Data ณ  30/04/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o In para o SQL filtrar somente chamados de        บฑฑ
ฑฑบ          ณ clientes prime, seja da fแbrica, atendimento ou manuten็ใo บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MntInCliFx()
Local cInCliFaix := ""
Local cInAux     := ""
Local cEscolha   := cFiltCliFx
Local nQtd       := 1
Local I          := 1

If cEscolha <> "Padrใo" .And. aFiltros[NSTATUS] == "Estatistica Geral"

	If cFiltCliFx == "Prime - Geral"
		cEscolha := "Prime - Especํfico"
		nQtd     := 3
	EndIf

	For I := 1 To nQtd
		Do Case
			Case cEscolha == "Prime - Especํfico"
				cInAux := GetTextoIn( CLIFXF3_FSW )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFXF3_FSWa )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFXF3_FSWb )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFXF3_FSWc )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFXF3_FSWd  )
			Case cEscolha == "Prime - Atendimento"
				cInAux := GetTextoIn( CLIFX1 )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX1a )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX1b )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX1c )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX1d  )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX2  )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX2a  )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX2b )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX2c )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX2d )
			Case cEscolha == "Prime - Manuten็ใo"
				cInAux := GetTextoIn( CLIFX3 )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX3a )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX3b )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX3c )
				cInAux := GetCnctVrg( cInAux )
				cInAux += GetTextoIn( CLIFX3d  )
			OtherWise
				cInAux := ""
		EndCase
	
		If !Empty( cInAux )
			cInAux   := GetTextoIn( cInAux )
			cInCliFaix += " ADE_CHAVE IN " + FormatIn( cInAux  , "," )
			If nQtd > 1
				Do Case
					Case I == 1
						cEscolha   := "Prime - Atendimento"
						cInCliFaix += " OR "
					Case I == 2
						cEscolha := "Prime - Manuten็ใo"
						cInCliFaix += " OR "
				EndCase
			EndIf
		EndIf
	Next I

	If !Empty( cInCliFaix )
		cInCliFaix := " ( " + cInCliFaix + " ) AND "
	EndIf
EndIf

Return cInCliFaix

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IsDiaUtil  บAutor  ณ Daniel Mendes   บ Data ณ  04/05/15    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a data informada ้ dia ๚til                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function IsDiaUtil( dData )
Local nDia := 0
Local lRet := .T.

nDia := Dow( dData )

If Feriado( dData ) .Or. nDia == 7 .Or. nDia == 1
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ aColsVazio บAutor  ณ Daniel Mendes   บ Data ณ  25/02/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o aCols possui registros vแlidos               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function aColsVazio()
Local lVazio := .T.
Local nFor   := 0

If Type( "aCols" ) == "A"
	If !Empty( aCols )
		If Len( aCols ) == 1
			For nFor := 1 To Len( aCols[ 1 ] )
				If !Empty( aCols[ 1 , nFor ] ) .And. ValType( Empty( aCols[ 1 , nFor ] ) ) <> "L" 
					lVazio := .F.
					Exit
				EndIf
			Next nFor
		Else
			lVazio := .F.
		EndIf
	EndIf
EndIf

Return lVazio 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BuscaSK9 บAutor  ณ Renato Campos      บ Data ณ  19/07/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca os tempos padr๕es da SK9                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIMC010                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaSK9()
Local cQuerySK9  := ""

Static cSLAFAIXA1 := Nil
Static cSLAFAIXA2 := Nil
Static cSLAFAIXA3 := Nil
Static cSLAFAIXA4 := Nil
Static cFilSK9    := Nil

If cFilSK9 == Nil
	cFilSK9    := MyxFilial( "SK9" )
Endif

If cSLAFAIXA1 == Nil
	cSLAFAIXA1		:= GetMv('PS_SK9GRD1',,'')
Endif

If cSLAFAIXA2 == Nil
	cSLAFAIXA2		:= GetMv('PS_SK9GRD2',,'')
EndIF

If cSLAFAIXA3 == NIL
	cSLAFAIXA3		:= GetMv('PS_SK9GRD3',,'')
Endif

If cSLAFAIXA4 == Nil
	cSLAFAIXA4		:= GetMv('PS_SK9GRD4',,'')
Endif

If Len(aSk9) <= 0
	cQuerySK9  := GetNextAlias()

	BeginSql Alias cQuerySK9
		SELECT SK9.K9_FILIAL
			 , SK9.K9_SEVE
			 , SK9.K9_NOME
			 , SK9.K9_HREXPIR
			 , SK9.K9_HRPSEXP
			 , SK9.K9_CODSLA
		  FROM %Table:SK9% SK9
		 WHERE SK9.K9_FILIAL = %Exp:cFilSK9%   
		   AND SK9.K9_CODSLA IN (%exp:cSLAFAIXA1%,%exp:cSLAFAIXA2%,%exp:cSLAFAIXA3%,%exp:cSLAFAIXA4%) 
		   AND SK9.%NotDel%
		 ORDER BY SK9.K9_SEVE DESC
	EndSql

	If Select(cQuerySK9) > 0
		While !(cQuerySK9)->( Eof() )
			cRetHrs := nToTime( TimeToMin( cValToChar( (cQuerySK9)->( K9_HREXPIR ) ) ) * 60 )
			Aadd( aSk9, { (cQuerySK9)->K9_FILIAL,(cQuerySK9)->K9_SEVE,(cQuerySK9)->K9_NOME,cRetHrs,(cQuerySK9)->K9_HRPSEXP,(cQuerySK9)->K9_CODSLA } )
			(cQuerySK9)->(DbSkip())
		EndDo

		(cQuerySK9)->( dbCloseArea() )
	EndIf
EndIF

RETURN
