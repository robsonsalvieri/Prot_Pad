#INCLUDE "FISXSERID.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FILEIO.CH"

STATIC aCamposSer := NIL
STATIC lUsaNewKey
Static oCposSerie := nil
Static __RpoRelease := GetRPORelease()
Static lNewSerieNFd := __RpoRelease > "12.1.2510"

//-------------------------------------------------------------------
/*/ {Protheus.doc} SerieNfId 

Funcao que avalia qual campo da tabela devera ser retornado como campo
oficial da serie do Documento Fiscal.

@Param
cAlias   -> Alias da Tabela do campo Serie

nOpcao   -> 1 - Gravacao
			2 - Visualizacao
			3 - Retorna o nome do campo serie a ser utilizado em Querys
			4 - Retorna a Chave de Pesquisa ID ou Serie Real para utilizar em validacoes dbseeks ANTES da gravacao
			5 - Retorna o CriaVar do campo _SDOC em caso onde o campo _SERIE foi alterado tamanho para 14 para gravar o novo formato
			6 - Retorna o TamSX3 do campo  _SDOC em caso onde o campo _SERIE foi alterado tamanho para 14 para gravar o novo formato
			7 - Retorna o RetTitle do campo _SDOC em caso onde o campo _SERIE foi alterado tamanho para 14 para gravar o novo formato

cCpoOrig -> String contendo o nome do campo Serie Original
dEmissao -> Data de Emissao do Documento Fiscal (OPCIONAL Usar somente com opcao "1" - Gravacao e "4" - Validacao)
cEspecie -> Especie do Documento Fiscal (OPCIONAL Usar somente com opcao "1" - Gravacao e "4" - Validacao )
cSerieGrv-> Variavel Conteudo da Serie a ser gravada (OPCIONAL Usar somente com opcao "1" - Gravacao e "4" - Validacao)
cNewIdPai-> Campo da serie original da tabela PAI ao gravar a tabela FILHO, o foco da utilizacao e
herdar o ID gravado na tabela pai para as tabelas filho sem a necessidade de compor o ID
novamente, Exemplo: F1_SERIE = "UNI122014ESPEC" , D1_SEIRE, F3_SERIE, FT_SERIE com o mesmo conteudo
Exemplo de Uso:
SerieNfId("SF1","1","F1_SERIE",dEmissao,cEspecie,cSerieGrv) Gravando o registro Pai
SerieNfId("SD1","1","D1_SERIE",,,,SF1->F1_SERIE) Gravando o registro Filho, os parametros
dEmissao,cEspecie e cSerieGrv NAO devem ser passados, o parametro cNewPai quando referenciar
a um campo, SEMPRE devera ser apontado o alias ALIAS->CAMPO, uma variavel composta do ID de
14 posicoes também pode ser passado, contudo neste caso a varivel deve ter o mesmo formato de
gravacao do campo Id em todos os cenarios

!!! IMPORTANTE - ao gravar a tabela filho a tabela pai deve estar POSICIONADA.

@return

xRetCpoUso com nOpcao = 1 -> Nil
xRetCpoUso com nOpcao = 2 -> Conteudo do Campo Serie a ser Utilizado
xRetCpoUso com nOpcao = 3 -> Nome do Campo Serie a ser utilizado
xRetCpoUso com nOpcao = 4 -> Chave de Pesquisa ID ou Serie Real sempre encima do conteudo gravados nos campos _SERIE
xRetCpoUso com nOpcao = 5 -> Se com o dicionario atualizado o tamanho dos campos _SERIE for alterado para 14 retorna o CriaVar do Campo _SDOC
xRetCpoUso com nOpcao = 6 -> Se com o dicionario atualizado o tamanho dos campos _SERIE for alterado para 14 retorna o TamSX3 do campo _SDOC
xRetCpoUso com nOpcao = 7 -> Se com o dicionario atualizado o tamanho dos campos _SERIE for alterado para 14 retorna o RetTitle do campo _SDOC

@author Alexandre Lemes
@since 05/01/2015
@version 1.1
/*/                 
//-------------------------------------------------------------------
Function SerieNfId(cAlias,nOpcao,cCpoOrig,dEmissao,cEspecie,cSerieGrv,cNewIdPai)

	Local aCpoSerie   //:= SerieToSDoc() // Array contendo todos os campos do Projeto
	Local xRetCpoUso  := ""
	Local cNewId      := ""
	Local nField      := 0

	DEFAULT dEmissao  := dDataBase
	DEFAULT cCpoOrig  := ""
	DEFAULT cEspecie  := ""
	DEFAULT cSerieGrv := ""
	DEFAULT cNewIdPai := ""

	//---------------------------------------------------------------------------------
	//-
	//- verifica o relase a ser executado
	//-
	//---------------------------------------------------------------------------------
	If lNewSerieNFd
		If nOpcao == 1 .and. !Empty(cNewIdPai)
			cSerieGrv := cNewIdPai
		EndIf
 		Return protheus.backoffice.fiscal.NewSerieNFd(cAlias,nOpcao,cCpoOrig,cSerieGrv)
		
	Else
		aCpoSerie   := SerieToSDoc() // Array contendo todos os campos do Projeto
		
		if lUsaNewKey==Nil
			lUsaNewKey  := TamSX3("F1_SERIE")[1] == 14 // Ativa o novo formato de gravacao do Id nos campos _SERIE
		endIf

		nField := GetSerieSDoc(AllTrim(cCpoOrig)) //aScan( aCpoSerie , { |x|  AllTrim(x[1]) == AllTrim(cCpoOrig) } )

		If nField > 0

			cSerieGrv := Substr(cSerieGrv,1,3)

			cCpoEmUso := aCpoSerie[nField][IIf(!lUsaNewKey, 1, 2)] // Campo Original

			If nOpcao == 1

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Uso para gravacao dos campos _SERIE, ao utilizar,sempre em qualquer cenario³
				//³serao gravados os dois campos, _SERIE e o _SDOC.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If !Empty(cNewIdPai)

					cSerieGrv := Substr( cNewIdPai ,1 ,3 )

					If lUsaNewKey
						cNewId    := cNewIdPai
					EndIf

				Else
					cNewId := PadR(cSerieGrv,3)+StrZero(Month(dEmissao),2)+Str(Year(dEmissao),4)+cEspecie
				EndIf

				If lUsaNewKey

					&(cAlias+"->"+AllTrim(cCpoOrig)) := cNewId
					&(cAlias+"->"+cCpoEmUso) := cSerieGrv

				Else

					&(cAlias+"->"+AllTrim(cCpoOrig)) := cSerieGrv

					If (cAlias)->( FieldPos(AllTrim(aCpoSerie[nField][2])) ) > 0  // Retirar apos lancamento do Release 12.1.008 do Protheus 12

						&(cAlias+"->"+AllTrim(aCpoSerie[nField][2])) := cSerieGrv

					EndIf

				EndIf

			ElseIf nOPcao == 2

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Uso para visualizacao dos campos serie em consulta, relatorios, .INIs³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				xRetCpoUso := Substr(&(cAlias+"->"+cCpoEmUso),1,3)

			ElseIf nOPcao == 3

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornar qual campo devera ser utilizado em Querys, Filtros, Arrays³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				xRetCpoUso := AllTrim(cCpoEmUso)

			ElseIf nOPcao == 4

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retornar a chave composta para o ID de Controle, util para se utilizar em rotinas com situacoes    ³
				//³especificas onde se necessite do conteudo gravado nos campos _SERIE conforme o cenario             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				cNewId := PadR(cSerieGrv,3)+StrZero(Month(dEmissao),2)+Str(Year(dEmissao),4)+PadR(cEspecie,Len(SF1->F1_ESPECIE))

				If lUsaNewKey
					xRetCpoUso := cNewId // Retorna o ID composto para validar em dbseeks antes da gravacao
				Else
					xRetCpoUso := PadR(cSerieGrv,3) // Em caso de campos _SERIE com tamanho = 3 retorna a Serie Real
				EndIf

			ElseIf nOPcao == 5

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o Usr estiver com o Dicionario Novo e ter alterado o grupo de campo dos campos _SERIE para 14 ³
				//³ativando assim o novo modo de gravacao, mas por algum motivo necessitar de um CriaVar com o tamanho³
				//³do campo serie real que e igual a 3.                                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				xRetCpoUso := CriaVar( AllTrim(cCpoEmUso) )

				If Len(xRetCpoUso) == 14
					xRetCpoUso := CriaVar( AllTrim(aCpoSerie[nField][2]) )
				EndIf

			ElseIf nOPcao == 6

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o Usr estiver com o Dicionario Novo e ter alterado o grupo de campo dos campos _SERIE para 14 ³
				//³ativando assim o novo modo de gravacao, mas por algum motivo necessitar do TAMSX3 do Novo campo    ³
				//³Serie _SDOC que e 3 para Serie Real.                                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				xRetCpoUso := TamSX3( AllTrim(cCpoEmUso))[1]

				If xRetCpoUso == 14
					xRetCpoUso := TamSX3( AllTrim(aCpoSerie[nField][2]))[1]
				EndIf

			ElseIf nOPcao == 7

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso o Usr estiver com o Dicionario Novo e ter alterado o grupo de campo dos campos _SERIE para 14 ³
				//³ativando assim o novo modo de gravacao, mas por algum motivo necessitar do LABEL  do Novo campo    ³
				//³Serie _SDOC que e a Serie Real.                                                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				xRetCpoUso := RetTitle(cCpoEmUso)

				If TamSX3( AllTrim(cCpoEmUso) )[1] == 14
					xRetCpoUso := RetTitle( AllTrim(aCpoSerie[nField][2]) )
				EndIf

			EndIf

		EndIf
	EndIf

	Return xRetCpoUso

//-------------------------------------------------------------------
/*/{Protheus.doc} SerieToSDoc()

Retorna um array contendo todos os campos _SERIE e seus equivalentes
_SDOC e o Alias da tabela para o Porjeto Chave Unica

@Return ( aCpoSerie )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Static Function SerieToSDoc()
	Local nX as numeric

	If aCamposSer == NIL

		aCamposSer := {}

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                            ATENCAO!!!                           ³
		//³Ao incluir NOVOS campos no array aCamposSer, verifique ANTES     ³
		//³de incluir se o ALIAS (Tabela) ja existe na posicao 3 dos campos ³
		//³existentes do aCamposSer. Caso ja EXISTA, ao incluir um novo ADD ³
		//³para o seu novo campo, crie a posicao 3 em BRANCO "   ". Somente ³
		//³informe o ALIAS do seu novo ADD caso ainda NAO exista a tabela   ³
		//³na posicao 3 do array aCamposSer.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCamposSer := {	{"AA3_ULTSER","AA3_SDOC"  ,"AA3"},;
						{"AD0_SERIE" ,"AD0_SDOC"  ,"AD0"},;
						{"AFN_SERIE" ,"AFN_SDOC"  ,"AFN"},;
						{"AFO_SERIE" ,"AFO_SDOC"  ,"AFO"},;
						{"AFS_SERIE" ,"AFS_SDOC"  ,"AFS"},;
						{"AGH_SERIE" ,"AGH_SDOC"  ,"AGH"},;
						{"B19_SERIE" ,"B19_SDOC"  ,"B19"},;
						{"BM1_SERSF2","BM1_SDOCF2","BM1"},;
						{"BMN_SERSF2","BMN_SDOCF2","BMN"},;
						{"BTV_SERIE" ,"BTV_SDOC"  ,"BTV"},;
						{"CB0_SERIEE","CB0_SDOCE" ,"CB0"},;
						{"CB0_SERIES","CB0_SDOCS" ,"   "},;
						{"CB6_SERIE" ,"CB6_SDOC"  ,"CB6"},;
						{"CB7_SERIE" ,"CB7_SDOC"  ,"CB7"},;
						{"CB8_SERIE" ,"CB8_SDOC"  ,"CB8"},;
						{"CBE_SERIE" ,"CBE_SDOC"  ,"CBE"},;
						{"CBG_SERIEE","CBG_SDOCE" ,"CBG"},;
						{"CBG_SERIES","CBG_SDOCS" ,"   "},;
						{"CBK_SERIE" ,"CBK_SDOC"  ,"CBK"},;
						{"CBL_SERIE" ,"CBL_SDOC"  ,"CBL"},;
						{"CCX_SERIE" ,"CCX_SDOC"  ,"CCX"},;
						{"CD0_SERENT","CD0_SDOCE" ,"CD0"},;
						{"CD0_SERIE" ,"CD0_SDOC"  ,"   "},;
						{"CD2_SERIE" ,"CD2_SDOC"  ,"CD2"},;
						{"CD3_SERIE" ,"CD3_SDOC"  ,"CD3"},;
						{"CD4_SERIE" ,"CD4_SDOC"  ,"CD4"},;
						{"CD5_SERIE" ,"CD5_SDOC"  ,"CD5"},;
						{"CD6_SERIE" ,"CD6_SDOC"  ,"CD6"},;
						{"CD7_SERIE" ,"CD7_SDOC"  ,"CD7"},;
						{"CD8_SERIE" ,"CD8_SDOC"  ,"CD8"},;
						{"CD9_SERIE" ,"CD9_SDOC"  ,"CD9"},;
						{"CDA_SERIE" ,"CDA_SDOC"  ,"CDA"},;
						{"CDB_SERIE" ,"CDB_SDOC"  ,"CDB"},;
						{"CDC_SERIE" ,"CDC_SDOC"  ,"CDC"},;
						{"CDD_SERIE" ,"CDD_SDOC"  ,"CDD"},;
						{"CDD_SERREF","CDD_SDOCRF","   "},;
						{"CDE_SERIE" ,"CDE_SDOC"  ,"CDE"},;
						{"CDE_SERREF","CDE_SDOCRF","   "},;
						{"CDF_SERIE" ,"CDF_SDOC"  ,"CDF"},;
						{"CDG_SERIE" ,"CDG_SDOC"  ,"CDG"},;
						{"CDK_SERIE" ,"CDK_SDOC"  ,"CDK"},;
						{"CDK_SERECP","CDK_SDOCEC","   "},;
						{"CDL_SEREXP","CDL_SDOCEX","CDL"},;
						{"CDL_SERIE" ,"CDL_SDOC"  ,"   "},;
						{"CDL_SERORI","CDL_SDOCOR","   "},;
						{"CDM_SERIEE","CDM_SDOCE" ,"CDM"},;
						{"CDM_SERIES","CDM_SDOCS" ,"   "},;
						{"CDQ_SERIE" ,"CDQ_SDOC"  ,"CDQ"},;
						{"CDR_SERIE" ,"CDR_SDOC"  ,"CDR"},;
						{"CDS_SEREMB","CDS_SDOCEM","CDS"},;
						{"CDS_SERIE" ,"CDS_SDOC"  ,"   "},;
						{"CDT_SERIE" ,"CDT_SDOC"  ,"CDT"},;
						{"CDX_SERIE" ,"CDX_SDOC"  ,"CDX"},;
						{"CE2_SERINF","CE2_SDOC"  ,"CE2"},;
						{"CE5_SERIE" ,"CE5_SDOC"  ,"CE5"},;
						{"CE8_SERIE" ,"CE8_SDOC"  ,"CE8"},;
						{"CF4_SERIE" ,"CF4_SDOC"  ,"CF4"},;
						{"CF6_SERIE" ,"CF6_SDOC"  ,"CF6"},;
						{"CFF_SERIE" ,"CFF_SDOC"  ,"CFF"},;
						{"CG8_SERIE" ,"CG8_SDOC"  ,"CG8"},;
						{"CNG_SERIE" ,"CNG_SDOC"  ,"CNG"},;
						{"CKQ_SERIE" ,"CKQ_SDOC"  ,"CKQ"},;
						{"CL5_SER"   ,"CL5_SDOC"  ,"CL5"},;
						{"CNI_SERIE" ,"CNI_SDOC"  ,"CNI"},;
						{"COG_SERIE" ,"COG_SDOC"  ,"COG"},;
						{"CPP_SERIE" ,"CPP_SDOC"  ,"CPP"},;
						{"CPQ_SERIE" ,"CPQ_SDOC"  ,"CPQ"},;
						{"D07_SERIE" ,"D07_SDOC"  ,"D07"},;
						{"D12_SERIE" ,"D12_SDOC"  ,"D12"},;
						{"D13_SERIE" ,"D13_SDOC"  ,"D13"},;
						{"DAI_SERIE" ,"DAI_SDOC"  ,"DAI"},;
						{"DAI_SERREM","DAI_SDOCRM","   "},;
						{"DB2_SERIE" ,"DB2_SDOC"  ,"DB2"},;
						{"DBB_SERIE" ,"DBB_SDOC"  ,"DBB"},;
						{"DCF_SERIE" ,"DCF_SDOC"  ,"DCF"},;
						{"DCF_SERORI","DCF_SDOCOR","   "},;
						{"DCN_SERIE" ,"DCN_SDOC"  ,"DCN"},;
						{"DCX_SERIE" ,"DCX_SDOC"  ,"DCX"},;
						{"DD9_SERIE" ,"DD9_SDOC"  ,"DD9"},;
						{"DD9_SERNFC","DD9_SDOCNF","   "},;
						{"DEB_SERIE" ,"DEB_SDOC"  ,"DEB"},;
						{"DEF_SERIE" ,"DEF_SDOC"  ,"DEF"},;
						{"DF1_SERIE" ,"DF1_SDOC"  ,"DF1"},;
						{"DF6_SERIE" ,"DF6_SDOC"  ,"DF6"},;
						{"DFN_SERIE" ,"DFN_SDOC"  ,"DFN"},;
						{"DFP_SERDCS","DFP_SDOCS" ,"DFP"},;
						{"DFP_SERDCT","DFP_SDOCT" ,"   "},;
						{"DFR_SERDCT","DFR_SDOCT" ,"DFR"},;
						{"DFS_SERDCT","DFS_SDOCT" ,"DFS"},;
						{"DFV_SERIE" ,"DFV_SDOC"  ,"DFV"},;
						{"DI9_SERIE" ,"DI9_SDOC"  ,"DI9"},;
						{"DIA_SERIE" ,"DIA_SDOC"  ,"DIA"},;
						{"DIB_SERIE" ,"DIB_SDOC"  ,"DIB"},;
						{"DIC_SERIE" ,"DIC_SDOC"  ,"DIC"},;
						{"DIH_SERIE" ,"DIH_SDOC"  ,"DIH"},;
						{"DII_SERIE" ,"DII_SDOC"  ,"DII"},;
						{"DIJ_SERIE" ,"DIJ_SDOC"  ,"DIJ"},;
						{"DIK_SERIE" ,"DIK_SDOC"  ,"DIK"},;
						{"DIM_SERIE" ,"DIM_SDOC"  ,"DIM"},;
						{"DIN_SERNFC","DIN_SDOCC" ,"DIN"},;
						{"DT5_SERIE" ,"DT5_SDOC"  ,"DT5"},;
						{"DT6_SERDCO","DT6_SDOCOR","DT6"},;
						{"DT6_SERIE" ,"DT6_SDOC"  ,"   "},;
						{"DT6_SERMAN","DT6_SDOCMN","   "},;
						{"DT8_SERIE" ,"DT8_SDOC"  ,"DT8"},;
						{"DTA_SERIE" ,"DTA_SDOC"  ,"DTA"},;
						{"DTC_SERDPC","DTC_SDOCPC","DTC"},;
						{"DTC_SERIE" ,"DTC_SDOC"  ,"   "},;
						{"DTC_SERNFC","DTC_SDOCC" ,"   "},;
						{"DTE_SERNFC","DTE_SDOCC" ,"DTE"},;
						{"DTX_SERMAN","DTX_SDOCMN","DTX"},;
						{"DU1_SERIE" ,"DU1_SDOC"  ,"DU1"},;
						{"DU1_SERNFC","DU1_SDOCC" ,"   "},;
						{"DU7_SERIE" ,"DU7_SDOC"  ,"DU7"},;
						{"DUA_SERIE" ,"DUA_SDOC"  ,"DUA"},;
						{"DUB_SERIE" ,"DUB_SDOC"  ,"DUB"},;
						{"DUD_SERBXE","DUD_SDOCBX","DUD"},;
						{"DUD_SERIE" ,"DUD_SDOC"  ,"   "},;
						{"DUD_SERMAN","DUD_SDOCMN","   "},;
						{"DUU_SERIE" ,"DUU_SDOC"  ,"DUU"},;
						{"DV4_SERIE" ,"DV4_SDOC"  ,"DV4"},;
						{"DV4_SERNFC","DV4_SDOCC" ,"   "},;
						{"DVS_SERIE" ,"DVS_SDOC"  ,"DVS"},;
						{"DVV_SERIE" ,"DVV_SDOC"  ,"DVV"},;
						{"DVX_SERIE" ,"DVX_SDOC"  ,"DVX"},;
						{"DXM_SERIE" ,"DXM_SDOC"  ,"DXM"},;
						{"DXS_SERNFS","DXS_SDOC"  ,"DXS"},;
						{"DY4_SERIE" ,"DY4_SDOC"  ,"DY4"},;
						{"DY4_SERNFC","DY4_SDOCC" ,"   "},;
						{"DYC_SERIE" ,"DYC_SDOC"  ,"DYC"},;
						{"DYJ_SERIE" ,"DYJ_SDOC"  ,"DYJ"},;
						{"DYN_SERMAN","DYN_SDOCMN","DYN"},;
						{"ED2_SERIE" ,"ED2_SDOC"  ,"ED2"},;
						{"ED8_SERIE" ,"ED8_SDOC"  ,"ED8"},;
						{"ED9_SERIE" ,"ED9_SDOC"  ,"ED9"},;
						{"EDH_SERIE" ,"EDH_SDOC"  ,"EDH"},;
						{"EE9_SERIE" ,"EE9_SDOC"  ,"EE9"},;
						{"EEM_SERIE" ,"EEM_SDOC"  ,"EEM"},;
						{"EES_SERIE" ,"EES_SDOC"  ,"EES"},;
						{"EEZ_A_SER" ,"EEZ_SDOCA" ,"EEZ"},;
						{"EEZ_SER"   ,"EEZ_SDOC"  ,"   "},;
						{"EI1_SERIE" ,"EI1_SDOC"  ,"EI1"},;
						{"EI2_SERIE" ,"EI2_SDOC"  ,"EI2"},;
						{"EI3_SE_NFC","EI3_SDOC"  ,"EI3"},;
						{"ELA_SERIE" ,"ELA_SDOC"  ,"ELA"},;
						{"EW1_SERNF" ,"EW1_SDOC"  ,"EW1"},;
						{"EW2_SERNF" ,"EW2_SDOC"  ,"EW2"},;
						{"EWI_SERIE" ,"EWI_SDOC"  ,"EWI"},;
						{"EYY_SERSAI","EYY_SDOCS" ,"EYY"},;
						{"EYY_SERENT","EYY_SDOCE" ,"   "},;
						{"FJT_SERIE" ,"FJT_SDOC"  ,"FJT"},;
						{"FN6_SERIE" ,"FN6_SDOC"  ,"FN6"},;
						{"FN8_SERIE" ,"FN8_SDOC"  ,"FN8"},;
						{"FR3_SERIE" ,"FR3_SDOC"  ,"FR3"},;
						{"FRF_SERDOC","FRF_SDOC"  ,"FRF"},;
						{"FRK_SERIE" ,"FRK_SDOC"  ,"FRK"},;
						{"GW1_ORISER","GW1_SDOCOR","GW1"},;
						{"GW1_SERDC" ,"GW1_SDOC"  ,"   "},;
						{"GW4_SERDC" ,"GW4_SDOCDC","GW4"},;
						{"GW8_SERDC" ,"GW8_SDOCDC","GW8"},;
						{"GWB_SERDC" ,"GWB_SDOCDC","GWB"},;
						{"GWE_SERDC" ,"GWE_SDOCDC","GWE"},;
						{"GWE_SERDT" ,"GWE_SDOCDT","   "},;
						{"GWH_SERDC" ,"GWH_SDOCDC","GWH"},;
						{"GWL_SERDC" ,"GWL_SDOCDC","GWL"},;
						{"GWM_SERDC" ,"GWM_SDOCDC","GWM"},;
						{"GWU_SERDC" ,"GWU_SDOC"  ,"GWU"},;
						{"GWW_SERDC" ,"GWW_SDOC"  ,"GWW"},;
						{"GXA_SERDC" ,"GXA_SDOC"  ,"GXA"},;
						{"HB6_SERIE" ,"HB6_SDOC"  ,"HB6"},;
						{"HD1_SERORI","HD1_SDOCO" ,"HD1"},;
						{"HD2_SERIE" ,"HD2_SDOC"  ,"HD2"},;
						{"HF1_SERIE" ,"HF1_SDOC"  ,"HF1"},;
						{"HF2_SERIE" ,"HF2_SDOC"  ,"HF2"},;
						{"JJ2_SERIE" ,"JJ2_SDOC"  ,"JJ2"},;
						{"MAX_SERIE" ,"MAX_SDOC"  ,"MAX"},;
						{"MB1_SERIE" ,"MB1_SDOC"  ,"MB1"},;
						{"MBJ_SERIE" ,"MBJ_SDOC"  ,"MBJ"},;
						{"MBN_SERIE" ,"MBN_SDOC"  ,"MBN"},;
						{"MBR_SERIE" ,"MBR_SDOC"  ,"MBR"},;
						{"MBZ_SERIE" ,"MBZ_SDOC"  ,"MBZ"},;
						{"MDD_SERIR" ,"MDD_SDOCRC","MDD"},;
						{"MDD_SERIV" ,"MDD_SDOCVD","   "},;
						{"MDH_SERIE" ,"MDH_SDOC"  ,"MDH"},;
						{"MDJ_SERIE" ,"MDJ_SDOC"  ,"MDJ"},;
						{"MDK_SERIE" ,"MDK_SDOC"  ,"MDK"},;
						{"MDL_SERIE" ,"MDL_SDOC"  ,"MDL"},;
						{"MDU_SERIE" ,"MDU_SDOC"  ,"MDU"},;
						{"ME4_SERIE" ,"ME4_SDOC"  ,"ME4"},;
						{"MFI_SERIE" ,"MFI_SDOC"  ,"MFI"},;
						{"NNT_SERIE" ,"NNT_SDOC"  ,"MNT"},;
						{"NOA_SERDOC","NOA_SDOC"  ,"NOA"},;
						{"NPA_NFSSER","NPA_SDOC"  ,"NPA"},;
						{"NPM_SERNFS","NPM_SDOC"  ,"NPM"},;
						{"NXA_SERIE" ,"NXA_SDOC"  ,"NXA"},;
						{"QEK_SERINF","QEK_SDOC"  ,"QEK"},;
						{"QEL_SERINF","QEL_SDOC"  ,"QEL"},;
						{"QEP_SERINF","QEP_SDOC"  ,"QEP"},;
						{"QER_SERINF","QER_SDOC"  ,"QER"},;
						{"QEY_SERINF","QEY_SDOC"  ,"QEY"},;
						{"QEZ_SERINF","QEZ_SDOC"  ,"QEZ"},;
						{"RHU_SERIE" ,"RHU_SDOC"  ,"RHU"},;
						{"B6_SERIE"  ,"B6_SDOC"   ,"SB6"},;
						{"B7_SERIE"  ,"B7_SDOC"   ,"SB7"},;
						{"B8_SERIE"  ,"B8_SDOC"   ,"SB8"},;
						{"C5_SERIE"  ,"C5_SDOC"   ,"SC5"},;
						{"C5_SERSUBS","C5_SDOCSUB","   "},;
						{"C6_D1SERIE","C6_SDOCSD1","SC6"},;
						{"C6_SERDED" ,"C6_SDOCDED","   "},;
						{"C6_SERIE"  ,"C6_SDOC"   ,"   "},;
						{"C6_SERIORI","C6_SDOCORI","   "},;
						{"C9_SERIENF","C9_SDOCNF" ,"SC9"},;
						{"C9_SERIREM","C9_SDOCREM","   "},;
						{"CU_SERNCP" ,"CU_SDOCNCP","SCU"},;
						{"CU_SERNF"  ,"CU_SDOCNF" ,"   "},;
						{"D1_SERIE"  ,"D1_SDOC"   ,"SD1"},;
						{"D1_SERIORI","D1_SDOCORI","   "},;
						{"D1_SERIREM","D1_SDOCREM","   "},;
						{"D1_SERVINC","D1_SDOCVNC","   "},;
						{"D2_SERIE"  ,"D2_SDOC"   ,"SD2"},;
						{"D2_SERIORI","D2_SDOCORI","   "},;
						{"D2_SERIREM","D2_SDOCREM","   "},;
						{"D2_SERMAN" ,"D2_SDOCMAN","   "},;
						{"D5_SERIE"  ,"D5_SDOC"   ,"SD5"},;
						{"D7_SERIE"  ,"D7_SDOC"   ,"SD7"},;
						{"D8_SERIE"  ,"D8_SDOC"   ,"SD8"},;
						{"D9_SERIE"  ,"D9_SDOC"   ,"SD9"},;
						{"DA_SERIE"  ,"DA_SDOC"   ,"SDA"},;
						{"DB_SERIE"  ,"DB_SDOC"   ,"SDB"},;
						{"DE_SERIE"  ,"DE_SDOC"   ,"SDE"},;
						{"DS_SERIE"  ,"DS_SDOC"   ,"SDS"},;
						{"DT_SERIE"  ,"DT_SDOC"   ,"SDT"},;
						{"DT_SERIORI","DT_SDOCORI","   "},;
						{"E1_SERIE"  ,"E1_SDOC"   ,"SE1"},;
						{"E1_SERREC" ,"E1_SDOCREC","   "},;
						{"E3_SERIE"  ,"E3_SDOC"   ,"SE3"},;
						{"E5_SERREC" ,"E5_SDOCREC","SE5"},;
						{"EF_SERIE"  ,"EF_SDOC"   ,"SEF"},;//{"EK_SERORI" ,"EK_SDOCORI","SEK}) Nao Foi encontrado no ATUSX Localizado Peru - Retirado do projeto Alinhado com Paulo Pouza
						{"EL_SERIE"  ,"EL_SDOC"   ,"SEL"},;
						{"EM_SERIE"  ,"EM_SDOC"   ,"SEM"},;
						{"EU_SERCOMP","EU_SDOCCOM","SEU"},;
						{"EU_SERIE"  ,"EU_SDOC"   ,"   "},;
						{"EX_SERREC" ,"EX_SDOCREC","SEX"},;
						{"EY_SERIE"  ,"EY_SDOC"   ,"SEY"},;
						{"F1_SERIE"  ,"F1_SDOC"   ,"SF1"},;
						{"F1_SERORIG","F1_SDOCORI","   "},;
						{"F1_SERMAN" ,"F1_SDOCMAN","   "},;
						{"F2_NEXTSER","F2_SDOCNXT","SF2"},;
						{"F2_SERIE"  ,"F2_SDOC"   ,"   "},;
						{"F2_SERIORI","F2_SDOCORI","   "},;
						{"F2_SERSUBS","F2_SDOCSUB","   "},;
						{"F2_SERMAN" ,"F2_SDOCMAN","   "},;
						{"F2_SERMDF" ,"F2_SDOCMDF","   "},;
						{"F3_SERIE"  ,"F3_SDOC"   ,"SF3"},;
						{"F3_SERMAN" ,"F3_SDOCMAN","   "},;
						{"F6_SERIE"  ,"F6_SDOC"   ,"SF6"},;
						{"F8_SEDIFRE","F8_SDOCFRE","SF8"},;
						{"F8_SERORIG","F8_SDOCORI","   "},;
						{"F9_SERNFE" ,"F9_SDOCNFE","SF9"},;
						{"F9_SERNFS" ,"F9_SDOCNFS","   "},;
						{"FE_SERIE"  ,"FE_SDOC"   ,"SFE"},;
						{"FE_SERIEC" ,"FE_SDOCC"  ,"   "},;
						{"FS_SERIE"  ,"FS_SDOC"   ,"SFS"},;
						{"FT_SERIE"  ,"FT_SDOC"   ,"SFT"},;
						{"FT_SERORI" ,"FT_SDOCORI","   "},;
						{"FU_SERIE"  ,"FU_SDOC"   ,"SFU"},;
						{"FX_SERIE"  ,"FX_SDOC"   ,"SFX"},;
						{"GIC_SERNFS","GIC_SDOCNF","GIC"},;
						{"L1_SERIE"  ,"L1_SDOC"   ,"SL1"},;
						{"L1_SERPED" ,"L1_SDOCPED","   "},;
						{"L1_SERRPS" ,"L1_SDOCRPS","   "},;
						{"L1_SUBSERI","L1_SDOCSUB","   "},;
						{"L2_SERIE"  ,"L2_SDOC"   ,"SL2"},;
						{"L2_SERPED" ,"L2_SDOCPED","   "},;
						{"L6_SERIE"  ,"L6_SDOC"   ,"SL6"},;
						{"LQ_SERIE"  ,"LQ_SDOC"   ,"SLQ"},;
						{"LQ_SERPED" ,"LQ_SDOCPED","   "},;
						{"LQ_SERRPS" ,"LQ_SDOCRPS","   "},;
						{"LQ_SUBSERI","LQ_SDOCSUB","   "},;
						{"LR_SERIE"  ,"LR_SDOC"   ,"SLR"},;
						{"LR_SERPED" ,"LR_SDOCPED","   "},;
						{"LS_SERIE"  ,"LS_SDOC"   ,"SLS"},;
						{"LX_SERIE"  ,"LX_SDOC"   ,"SLX"},;
						{"N1_NSERIE" ,"N1_SDOC"   ,"SN1"},;
						{"N4_SERIE"  ,"N4_SDOC"   ,"SN4"},;
						{"N7_SERIE"  ,"N7_SDOC"   ,"SN7"},;
						{"NM_SERIE"  ,"NM_SDOC"   ,"SNM"},;
						{"TL_SERIE"  ,"TL_SDOC"   ,"STL"},;
						{"TT_SERIE"  ,"TT_SDOC"   ,"STT"},;
						{"UA_SERIE"  ,"UA_SDOC"   ,"SUA"},;
						{"W6_SE_NF"  ,"W6_SDOC"   ,"SW6"},;
						{"W6_SE_NFC" ,"W6_SDOCC"  ,"   "},;
						{"WD_SE_NFC" ,"WD_SDOCC"  ,"SWD"},;
						{"WD_SERIE"  ,"WD_SDOC"   ,"   "},;
						{"WD_SE_DOC" ,"WD_SDOCSE" ,"   "},;
						{"WN_SERIE"  ,"WN_SDOC"   ,"SWN"},;
						{"WN_SERORI" ,"WN_SDOCORI","   "},;
						{"WW_SE_NFC" ,"WW_SDOC"   ,"SWW"},;
						{"TE0_SERIE" ,"TE0_SDOC"  ,"TE0"},;
						{"TE1_SERIE" ,"TE1_SDOC"  ,"TE1"},;
						{"TE2_SERIE" ,"TE2_SDOC"  ,"TE2"},;
						{"TEW_SERENT","TEW_SDOCE" ,"TEW"},;
						{"TEW_SERSAI","TEW_SDOCS" ,"   "},;
						{"TR7_SERIE" ,"TR7_SDOC"  ,"TR7"},;
						{"VD2_SERNFI","VD2_SDOC"  ,"VD2"},;
						{"VDD_SERNFI","VDD_SDOC"  ,"VDD"},;
						{"VDR_NFESER","VDR_SDOCE" ,"VDR"},;
						{"VDR_NFSSER","VDR_SDOCS" ,"   "},;
						{"VDU_SERDOC","VDU_SDOC"  ,"VDU"},;
						{"VDV_ESERNF","VDV_SDOCE" ,"VDV"},;
						{"VDV_SSERNF","VDV_SDOCS" ,"   "},;
						{"VE6_SERNFI","VE6_SDOC"  ,"VE6"},;
						{"VEC_SERNFI","VEC_SDOC"  ,"VEC"},;
						{"VEC_SERORI","VEC_SDOCOR","   "},;
						{"VEO_SERNFI","VEO_SDOC"  ,"VEO"},;
						{"VF3_SERNFI","VF3_SDOC"  ,"VF3"},;
						{"VG5_SERENT","VG5_SDOCE" ,"VG5"},;
						{"VG5_SERIEN","VG5_SDOCS" ,"   "},;
						{"VG6_SERENT","VG6_SDOCE" ,"VG6"},;
						{"VG6_SERNFI","VG6_SDOCS" ,"   "},;
						{"VG8_SERENT","VG8_SDOCE" ,"VG8"},;
						{"VG8_SERNFC","VG8_SDOCC" ,"   "},;
						{"VG8_SERNFI","VG8_SDOCS" ,"   "},;
						{"VGA_SERFEC","VGA_SDOCC" ,"VGA"},;
						{"VGA_SERIEN","VGA_SDOCE" ,"   "},;
						{"VGC_SERFEC","VGC_SDOC"  ,"VGC"},;
						{"VI0_SERNFI","VI0_SDOC"  ,"VI0"},;
						{"VI6_SERNFI","VI6_SDOC"  ,"VI6"},;
						{"VI7_SERIE" ,"VI7_SDOC"  ,"VI7"},;
						{"VI7_SERNFI","VI7_SDOCNF","   "},;
						{"VIA_SERNFI","VIA_SDOC"  ,"VIA"},;
						{"VIE_SERNFI","VIE_SDOC"  ,"VIE"},;
						{"VIK_SERNFI","VIK_SDOC"  ,"VIK"},;
						{"VIK_SERORI","VIK_SDOCOR","   "},;
						{"VIN_SERNFI","VIN_SDOC"  ,"VIN"},;
						{"VIP_SERIE" ,"VIP_SDOC"  ,"VIP"},;
						{"VIP_SERNFI","VIP_SDOCNF","   "},;
						{"VIQ_SERNFI","VIQ_SDOC"  ,"VIQ"},;
						{"VIV_SERNFI","VIV_SDOC"  ,"VIV"},;
						{"VIW_SERNFI","VIW_SDOC"  ,"VIW"},;
						{"VJ3_SERNFI","VJ3_SDOC"  ,"VJ3"},;
						{"VJ5_SERNFI","VJ5_SDOC"  ,"VJ5"},;
						{"VJC_SERNFI","VJC_SDOC"  ,"VJC"},;
						{"VJI_SERNFI","VJI_SDOC"  ,"VJI"},;
						{"VMB_SRANTE","VMB_SDOCA" ,"VMB"},;
						{"VMB_SRVSNF","VMB_SDOC"  ,"   "},;
						{"VO3_SERNFI","VO3_SDOC"  ,"VO3"},;
						{"VO4_SERNFI","VO4_SDOC"  ,"VO4"},;
						{"VOO_SERNFI","VOO_SDOC"  ,"VOO"},;
						{"VQ1_SERNFI","VQ1_SDOC"  ,"VQ1"},;
						{"VQ2_SERNFI","VQ2_SDOC"  ,"VQ2"},;
						{"VQ4_SERNFI","VQ4_SDOC"  ,"VQ4"},;
						{"VRF_SERNFI","VRF_SDOC"  ,"VRF"},;
						{"VS1_SERNFI","VS1_SDOC"  ,"VS1"},;
						{"VSC_SERNFI","VSC_SDOC"  ,"VSC"},;
						{"VSY_SERNFI","VSY_SDOC"  ,"VSY"},;
						{"VSZ_SERNFI","VSZ_SDOC"  ,"VSZ"},;
						{"VV0_SERNFI","VV0_SDOC"  ,"VV0"},;
						{"VV0_SNFFDI","VV0_SDOCFD","   "},;
						{"VV0_SNFCOM","VV0_SDOCCO","   "},;
						{"VV9_SERNFI","VV9_SDOC"  ,"VV9"},;
						{"VVD_SERNFI","VVD_SDOC"  ,"VVD"},;
						{"VVF_SERNFI","VVF_SDOC"  ,"VVF"},;
						{"VZK_SERNFI","VZK_SDOC"  ,"VZK"},;
						{"DH_SERIE"  ,"DH_SDOC"   ,"SDH"},;
						{"F0S_SERCRE","F0S_SDOCCR","F0S"},;
						{"F0S_SERSAI","F0S_SDOCSA","   "},;
						{"CDV_SERIE" ,"CDV_SDOC"  ,"CDV"} }
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                            ATENCAO!!!                           ³
		//³Ao incluir NOVOS campos no array aCamposSer, verifique ANTES     ³
		//³de incluir se o ALIAS (Tabela) ja existe na posicao 3 dos campos ³
		//³existentes do aCamposSer. Caso ja EXISTA, ao incluir um novo ADD ³
		//³para o seu novo campo, crie a posicao 3 em BRANCO "   ". Somente ³
		//³informe o ALIAS do seu novo ADD caso ainda NAO exista a tabela   ³
		//³na posicao 3 do array aCamposSer.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If oCposSerie == nil
			oCposSerie := JsonObject():New()
		EndIf

		//- guarda o nome do Campo com a posição
		For nX := 1 to Len(aCamposSer)
			oCposSerie[Alltrim(aCamposSer[nX,1])]:= nX
		Next nX
	EndIf

Return aCamposSer

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSerieSDoc()
Retorna Retorna a posição do Array aCamposSer de acordo com campos informado
@Param
cCampo   -> Campo a ser pesquisado

@Return ( nPos )

@author Alexandre Lemes
@since  21/10/2015
@version 1.0  

/*/
//------------------------------------------------------------------- 
Function GetSerieSDoc(cCampo as Character)
	Local nPos as Numeric
//- Executa a chamada para garantir a carga do Array contendo 
//- todos os campos e Alias do Projeto
	SerieToSDoc()

//- Busca a posição do Campo, não existindo zera o mesmo
	If (nPos := oCposSerie[AllTrim(cCampo)]) == nil
		nPos := 0
	EndIf


Return nPos
