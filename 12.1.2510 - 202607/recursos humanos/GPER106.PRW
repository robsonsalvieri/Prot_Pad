#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER106.CH"
#INCLUDE "REPORT.CH"

#DEFINE REFER  1
#DEFINE NVALOR 2
#DEFINE NPD    3
#DEFINE DESC   4
#DEFINE PIPE   5
#DEFINE INSS   6
#DEFINE FGTS   7
#DEFINE IR     8
#DEFINE VALORB 1
#DEFINE PDB    2
#DEFINE DESCB  3
#DEFINE REFERB 4

Static lPrinOn := .F.
Static cDAnt   := ""
Static aOrdemP
Static aOrdemD
Static aOrdemB
Static cWhereSRC := "%%"
Static cWhereSRD := "%%"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa   ≥GPER106   ∫Autor  ≥Tania Bronzeri         ∫ Data ≥ 14/11/2007   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.      ≥ Relatorio Folha de Pagamento                                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso        ≥ Folha de pagamento - Todos                                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫             ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.              ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Programador ≥ Data     ≥ BOPS/FNC  | Motivo da Alteracao                    ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Mohanad     ≥07/11/2013≥M12RH01   ≥UNIFICACAO DOS FONTES V12                ∫±±
±±∫            ≥          ≥184701    ≥Rotina liberada para todos paises        ∫±±
±±∫Esther V.   ≥06/08/2014≥M_RH003   ≥Inclus„o dos totalizadores por Unidade de∫±±
±±∫            ≥          ≥          ≥NegÛcio e Empresa. Melhoria nas queries e∫±±
±±∫            ≥          ≥          ≥na funÁ„o fGR106join para tratamento de  ∫±±
±±∫            ≥          ≥          ≥Gest„o Corporativa. CriaÁ„o da funÁ„o    ∫±±
±±∫            ≥          ≥          ≥fGR106Header para impress„o do cabeÁalho.∫±±
±±∫Esther V.   ≥12/08/2014≥M_RH003   ≥Retirada das ordens 9, 10, 11, 12 e 13 do∫±±
±±∫            ≥          ≥          ≥relatorio.Ajuste na Query para nao trazer∫±±
±±∫            ≥          ≥          ≥funcioanrio sem departamento apenas nas  ∫±±
±±∫            ≥          ≥          ≥ordens em que h· quebra de departamento. ∫±±
±±∫            ≥          ≥          ≥Retirada da funcao fQueryVisao.          ∫±±
±±∫Christiane  ≥09/12/2014≥TRAYRP    ≥CorreÁ„o de error log na impress„o sem GC∫±±
±±∫Allyson M   ≥03/08/2015≥TSVCSL    ≥Ajuste p/ respeitar a configuracao do    ∫±±
±±∫            ≥          ≥          ≥campo RV_IMPRIPD nos totais da empresa   ∫±±
±±∫Allyson M   ≥04/08/2015≥TSVCSL    ≥Ajuste p/ geracao do relatorio com a     ∫±±
±±∫            ≥          ≥          ≥opcao de gestao de empresas ativa pois   ∫±±
±±∫            ≥          ≥          ≥gerava error log  			      	   ∫±±
±±∫Hugo Alex   ≥06/08/2015≥PCREQ-5930≥CorrecciÛn en Qry de Seleccion para Mexico∫±±
±±∫Allyson M   ≥27/08/2015≥TTCRLD    ≥Ajuste na sintaxe da query do inner join ∫±±
±±∫            ≥          ≥          ≥e left join da SQB pois gerava error log ∫±±
±±∫GSantacruz  ≥09/11/2015≥PCREQ-5930≥Merge 12.1.8                             ∫±±
±±∫Allyson M   ≥27/11/2015≥TTXMXQ    ≥Ajuste na impressao dos totalizadores da ∫±±
±±∫            ≥          ≥          ≥empresa e unidade de negocio p/ validar  ∫±±
±±∫            ≥          ≥          ≥se ha essa configuracao no layout da SM0 ∫±±
±±∫Renan B.    ≥11/12/2015≥TTTYLL    ≥Ajuste para emitir o Novo relatÛrio da fo∫±±
±±∫            ≥          ≥          ≥lha corretamente quando funcion·rio foi  ∫±±
±±∫            ≥          ≥          ≥transferido de centro de custo.          ∫±±
±±∫Allyson M   ≥02/02/2016≥TUHLZY    ≥Ajuste p/ efetuar filtro pelo tipo de    ∫±±
±±∫            ≥          ≥          ≥contrato do funcionario 		      	   ∫±±
±±∫Gustavo M   ≥25/02/2016≥TUHLZY    ≥Ajuste p/ efetuar filtro pelo tipo de    ∫±±
±±∫            ≥          ≥          ≥contrato do funcionario 		      	   ∫±±
±±∫Raquel H    ≥10/05/2016≥TVCFEN    ≥CriaÁ„o da funÁ„o fAjustFil() que retorna∫±±
±±∫            ≥          ≥          ≥filias que o usuario possui acesso e 	   ∫±±
±±∫            ≥          ≥          ≥permissao de impress„o.                  ∫±±
±±∫Gabriel A.  ≥23/05/2016≥TCGKFO    ≥Inclus„o de quebra de p·gina por filial. ∫±±
±±∫            ≥          ≥          ≥Inclus„o da totalizaÁ„o por empresa      ∫±±
±±∫            ≥          ≥          ≥quando n„o h· gest„o corporativa.        ∫±±
±±∫M. Silveira ≥21/06/2016≥TVLQ32    ≥Implementada melhoria para permitir gerar∫±±
±±∫            ≥          ≥          ≥dados de diversos roteiros e processos.  ∫±±
±±∫Gabriel A.  ≥28/06/2016≥TVJY87    ≥CorreÁ„o do nome da vari·vel para        ∫±±
±±∫            ≥          ≥          ≥impress„o correta dos totais.            ∫±±
±±∫Gabriel A.  ≥12/09/2016≥TVXSB0    ≥Ajuste para validar as filiais           ∫±±
±±∫            ≥          ≥          ≥corretamente.                            ∫±±
±±∫Esther V.   |22/09/2016|  TWADV2  |Retirada implementacao do processamento  ∫±±
±±∫            |          |          |de multiprocesso e multirroteiro.        ∫±±
±±|Claudinei S.|30/11/2016|MRH-1469  |Ajustada fTotIdFat() p/ n„o gerar o ID973|±±
±±|            |          |TUQEAR    |caso n„o tenha mais a desoneraÁ„o.       |±±
±±∫M. Silveira ≥13/02/2017≥MRH-6220  ≥Ajuste p/ gerar a situacao do funcionario∫±±
±±∫            ≥          ≥          ≥no cabecalho do relatorio.               ∫±±
±±∫Paulo O	   ≥24/02/2017≥MRH-7198  ≥retirada da acentuaÁ„o dos campos STR0028∫±±
±±∫Inzonha     ≥          ≥          ≥e STR0021 e acerto da valor campo STR0025∫±±
±±∫			   ≥	      ≥          ≥e STR0024 para posicionar corretamente  ∫±±
±±∫Gabriel A.  ≥15/03/2017≥MRH-7872  ≥Ajuste na busca de perÌodos para filtrar ∫±±
±±∫            ≥          ≥          ≥pelas filiais parametrizadas e n„o apenas∫±±
±±∫            ≥          ≥          ≥pela logada.                             ∫±±
±±∫			   ≥	      ≥          ≥e STR0024 para posicionar corretamente   ∫±±
±±∫Paulo O    ≥17/03/2017≥MRH-7834  ≥Ajuste para n„o desabilitar o campo       ∫±±
±±∫Inzonha    ≥          ≥          ≥RA_SITFOLH quando a ordenaÁ„o for 2       ∫±±
±±∫           ≥          ≥          ≥(nome+lanÁamento) pois o campo n„o existe∫±±
±±∫Paulo O    ≥19/04/2017≥DRHPAG-448≥Ajuste para n„o desabilitar o campo      ∫±±
±±∫Inzonha    ≥          ≥          ≥RA_SITFOLH quando a ordenaÁ„o for 2,4,6,8∫±±
±±∫           ≥          ≥          ≥ pois o campo n„o existe                 ∫±±
±±∫Paulo O    ≥29/06/2017≥DRHPAG-2608≥Ajuste para filtrar utilizando o super  ∫±±
±±∫Inzonha    ≥          ≥          ≥filtro configurado para o usu·rio        ∫±±
±±∫Paulo O     ≥26/07/2017≥DRHPAG-2608≥Ajuste ao carregar o parametro MV_PAR21 ∫±±
±±∫Inzonha     ≥          ≥          ≥do pergunte                              ∫±±
±±∫Oswaldo L  ≥09/10/2017≥DRHPAG-3795≥Criar Totalizador situacao funcionarios ∫±±
±±∫           ≥          ≥          ≥ remover labels sem uso                  ∫±±
±±∫  Marco A.  ≥06/10/2017≥TSSERMI01-≥Se modifica la comparacion, de las pre- ∫±±
±±∫            ≥          ≥168        ≥guntas MV_PAR22 y MV_PAR23, debido a que∫±±
±±∫            ≥          ≥           ≥las preguntas retornan un valor numerico∫±±
±±∫            ≥          ≥           ≥y lo comparaban con un string. (MEX)    ∫±±
±±∫ Rafael R.  ≥30/10/2017≥DRHPAG-3983≥CorreÁ„o de impress„o das entradas na   ∫±±
±±∫            ≥          ≥           ≥tabela S035 (Complemento GPS)		   ∫±±
±±∫Jaqueline L.≥04/01/2018≥DRHPAG-    ≥CorreÁ„o na varÌavel nAnSi, pois quando ∫±±
±±∫            ≥          ≥10798      ≥o mv_par13 n„o estava preenchido gerava ∫±±
±±∫            ≥          ≥           ≥error Log                     		   ∫±±
±±∫Eduardo K.  ≥01/02/2018≥MPRIMESP- ≥Ajuste p/ carregar dados quando informar ∫±±
±±∫            ≥          ≥13521      ≥numero de pagamento 99 nos parametros.  ∫±±
±±∫Jo„o Balbino≥07/03/2018≥MPRIMESP- ≥Ajuste p/ n„o apresentar error log quando∫±±
±±∫            ≥          ≥14153      ≥emitido como sintÈtico.                 ∫±±
±±∫Alberto R.  ≥22/08/2019≥DMINA-7186≥Formato=AnalÌtico y Diferencia Netos=SÌ, ∫±±
±±∫            ≥          ≥          ≥aborta rutina. En fGR106Header() Checar  ∫±±
±±∫            ≥          ≥          ≥que la tabla temporal estÈ activa. MEX   ∫±±
±±∫Oscar G.    ≥25/06/2021≥DMINA-    ≥Se elimina localizacion de campo RA_DEPIR∫±±
±±∫            ≥          ≥     12535≥para COL al crear seccion 01. COL        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function GPER106(lGper670)

Local oReport                              
Local aArea	:= GetArea()

oReport := ReportDef(lGper670)

// N„o imprimir Total Geral
oReport:bTotalcanprint := {|| .F. }

oReport:PrintDialog()

RestArea(aArea)  

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ ReportDef  ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥20/11/2007 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Relatorio de Folha de Pagamento                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ReportDef(lGper670)
Local oReport
Local oSecMat
Local oSecNom
Local oSecLan
Local oSecCtc
Local oSecCtm
Local oSecSqb
Local oSecDifLiq
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0009)		//"Folha de Pagamento" ### "Imprime a Folha de pagamento, de acordo com os parametros solicitados pelo usu†rio."
Local nSize 	:= 14
Local lRobo		:= IsBlind() .And. !FWGetRunSchedule()

DEFAULT lGper670		:= .F.

_SetOwnerPrvt( 'lDepSf'		, IIf(SRA->(FieldPos("RA_DEPSF"))>0,.T.,.F.) )
_SetOwnerPrvt( 'lRaDtRec'	, IIf(SRA->(FieldPos("RA_DTREC"))>0,.T.,.F.) )
_SetOwnerPrvt( 'lRaFecrei'	, IIf(SRA->(FieldPos("RA_FECREI"))>0,.T.,.F.) )
_SetOwnerPrvt( 'lRaSalDia'	, IIf(SRA->(FieldPos("RA_SALDIA"))>0,.T.,.F.) )
_SetOwnerPrvt( 'lRaSalInt'	, IIf(SRA->(FieldPos("RA_SALINT"))>0,.T.,.F.) )
_SetOwnerPrvt( 'aOrd'		, {} )
_SetOwnerPrvt( 'nTamCC'		, TamSX3("RA_CC")[1])
_SetOwnerPrvt('nOrdRemov'	, 0) // QUANTIDADE DE ORDENS NAO EXISTENTES E QUE IMPACTA NA VARIAVEL NORDEM
_SetOwnerPrvt('nPosRemov'	, 0) // POSICAO PARA CONTROLAR O QUE FOI REMOVIDO
_SetOwnerPrvt('nOrdSra'		, 1)

_SetOwnerPrvt( 'cAliasFun' 	, "" )
_SetOwnerPrvt( 'cAliasQry' 	, "" )

_SetOwnerPrvt( 'aFilB'			, {} )
_SetOwnerPrvt( 'aGPSVal'		, {} )
_SetOwnerPrvt( 'cCodFunc'		, "" )
_SetOwnerPrvt( 'cDescFunc'		, "" )
_SetOwnerPrvt( 'cPerg'			, Iif(lGper670,"GPER670","GPE106R4") )
_SetOwnerPrvt( 'dDataRef'		, CtoD("  /  /  ") )
_SetOwnerPrvt( 'cMesAnoRef'		, CtoD("  /  /  ") )
_SetOwnerPrvt( 'cAnoMesRef'		, CtoD("  /  /  ") )
_SetOwnerPrvt( 'cDtPerFim'		, "" )
_SetOwnerPrvt( 'dDtPerIni'		, Ctod("  /  /  ") )
_SetOwnerPrvt( 'dDtPerFim'		, Ctod("  /  /  ") )
_SetOwnerPrvt( 'dDtPago'		, Ctod("  /  /  ") )
_SetOwnerPrvt( 'cTitulo'		, Iif(!lGper670,OemToAnsi(STR0001),STR0112) )	//"Folha de Pagamento" #"IMPRESS√O DO REUSUMO POR COMPET NCIA "
_SetOwnerPrvt( 'cMascCus'  		, GetMv("MV_MASCCUS") )
_SetOwnerPrvt( 'cCalcInf'  		, GetMv("MV_CALCINF") )
_SetOwnerPrvt( 'cQuebFun'  		, GetMv("MV_QUEBFUN",,"S")  )//quando for igual a nao, imprime funcionario sem quebrar pagina
_SetOwnerPrvt( 'cIRefSem'  		, GetMv("MV_IREFSEM",,"S") )
_SetOwnerPrvt( 'lAglutPd'  		, (GetMv("MV_AGLUTPD",,"1") == "1")  )// 1-Aglutina verbas   2-Nao Aglutina
_SetOwnerPrvt( 'lDifLiq'		, .F. )
_SetOwnerPrvt( 'lSumaVerba'		, .F. )

_SetOwnerPrvt( 'cMod1'			, "" )
_SetOwnerPrvt( 'aLanB'			, {} )
_SetOwnerPrvt( 'aLanP'			, {} )
_SetOwnerPrvt( 'aLanD'   		, {} )
_SetOwnerPrvt( 'aNomeFunc'		, {} )
_SetOwnerPrvt( 'aDifLiquidos'	, {} )
_SetOwnerPrvt( 'cPDLiq'			, fGetCodFol("0047") )
_SetOwnerPrvt( 'oSectDifLiq' )
_SetOwnerPrvt( 'cDepto'			, "" ) //UTILIZADO P/ INFORMA«√O HISTORICA
_SetOwnerPrvt( 'cDescDepto'		, "" )
_SetOwnerPrvt( 'cCentroC'		, "" )
_SetOwnerPrvt( 'cDescCC'		, "" )
_SetOwnerPrvt( 'cSitFunc'		, "" )
_SetOwnerPrvt( 'nTotFunc'		, 0 )

_SetOwnerPrvt( 'aSitQtds'       , {0,0,0,0,0} ) //Afastado / ferias / transferido / demitido / normal
_SetOwnerPrvt( 'aTotSitQtds'    , {0,0,0,0,0} ) //Afastado / ferias / transferido / demitido / normal
_SetOwnerPrvt( 'cSitAliasQry'   , GetNextAlias() )
_SetOwnerPrvt( 'aSintSits'      , {} )
_SetOwnerPrvt( 'aSintTot'       , {} )
_SetOwnerPrvt( 'aSintUN'     	, {} )
_SetOwnerPrvt( 'aSintEM'   	    , {} )
_SetOwnerPrvt( 'aSintCC'   	    , {} )
_SetOwnerPrvt( 'aSintEmp'       , {0,0,0,0,0} )
_SetOwnerPrvt( 'lDicInter'		, FindFunction("fChkInterm") .And. fChkInterm() )
_SetOwnerPrvt( 'cDesToma'       , "" ) //DescriÁ„o do tomador de serviÁos.
_SetOwnerPrvt( 'cCEI'           , ""  )// CEI/CNPJ tomador de serviÁos.

_SetOwnerPrvt( 'cProcesso'		, "" )
_SetOwnerPrvt( 'cPeriodo'		, "" )
_SetOwnerPrvt( 'cPagamento'		, "" )
_SetOwnerPrvt( 'cRoteiro'		, "" )
_SetOwnerPrvt( 'cRot'			, "" )

If !lRobo
	_SetOwnerPrvt( 'nOrdem'		, 1 )
EndIf
_SetOwnerPrvt( 'nAnaSin'   		, 0 )
_SetOwnerPrvt( 'nTpContr'		, 0 )

_SetOwnerPrvt( 'aInfo'			, Array(26) )
_SetOwnerPrvt( 'cCodFilial'		, "##" )
_SetOwnerPrvt( 'lCorpManage'	, fIsCorpManage( FWGrpCompany() ) )	// Verifica se o cliente possui Gest„o Corporativa no Grupo Logado
_SetOwnerPrvt( 'lSint'			, .F. ) // vari·vel que informa se foi selecionado tipo sintÈtico

_SetOwnerPrvt( 'lUniNeg'    	, !Empty(FWSM0Layout(cEmpAnt, 2))  )// Verifica se possui tratamento para unidade de Negocios
_SetOwnerPrvt( 'lEmpFil'    	, !Empty(FWSM0Layout(cEmpAnt, 1))  )// Verifica se possui tratamento para Empresa
_SetOwnerPrvt( 'cLayoutGC'  	, FWSM0Layout(cEmpAnt) )
_SetOwnerPrvt( 'nStartEmp'  	, At("E",cLayoutGC) )
_SetOwnerPrvt( 'nStartUnN'  	, At("U",cLayoutGC) )
_SetOwnerPrvt( 'nStartFil'  	, At("F",cLayoutGC) )
_SetOwnerPrvt( 'nEmpLength' 	, Len(FWSM0Layout(cEmpAnt, 1)) )
_SetOwnerPrvt( 'nUnNLength' 	, Len(FWSM0Layout(cEmpAnt, 2)) )
_SetOwnerPrvt( 'nFilLength' 	, Len(FWSM0Layout(cEmpAnt, 3)) )

If cPaisLoc == "COL"
	_SetOwnerPrvt( 'cMoneda'	, "" )
	_SetOwnerPrvt( 'cRemVar'	, "" )
	_SetOwnerPrvt( 'cGrossu'	, "" )
	_SetOwnerPrvt( 'cSalEst'	, "" )
	_SetOwnerPrvt( 'cPerRet'	, "" )
	_SetOwnerPrvt( 'cValSal'	, "" )
	_SetOwnerPrvt( 'cTpSal'		, "" )
	_SetOwnerPrvt( 'cCatFun'	, "" )
EndIF
//----------------
If lGper670
	Aadd(aOrd, OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))  //1  - "MatrÌcula + LanÁamentos"
Else
	Aadd(aOrd, OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))  //1  - "MatrÌcula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))  //2  - "Nome + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//3  - "C.Custo Cad. + MatrÌcula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//4  - "C.Custo Cad. + Nome + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//5  - "C.Custo Mov. + MatrÌcula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//6  - "C.Custo Mov. + Nome + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//7  - "Depto. + Matricula + LanÁamentos"
	Aadd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//8  - "Depto. + Nome + LanÁamentos"
EndIf
nPosRemov := Len(aOrd) + 1

Pergunte(cPerg,.F.)

cRot := MV_PAR02

If lGper670
	cRefOco		:= MV_PAR14
EndIf

cAliasQry	:= GetNextAlias()
cAliasFun	:= GetNextAlias()

If cPaisLoc == "COS"
	nSize := 16
Endif

//CRIACAO DOS COMPONENTES DE IMPRESSAO
DEFINE REPORT oReport NAME iif(lGper670,"GPER670","GPER106") TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R106Imp(oReport,lGper670) } DESCRIPTION cDesc1

	If lGper670
		nAnaSin := 2
		cRefOco		:= MV_PAR14
	Else
		nAnaSin := iif(!empty(mv_par13), mv_par13,0)		//Tipo Relatorio: 1=Analitico; 2=Sintetico)
	EndIf
	oReport:SetTotalInLine(.F.)	// PARA TOTALIZAR EM LINHAS
	If cPaisLoc == "COS"
		oReport:nFontBody	:= 6.5
	Else
		oReport:nFontBody	:= 8
	Endif
	oReport:SetDynamic()

	//SECTION 01
		DEFINE SECTION oSecMat OF oReport TITLE OemToAnsi(STR0036) TABLES "SRA","SQB","CTT","RCO","RGC" ORDERS aOrd	//"Filial / Funcion·rio"

		DEFINE CELL NAME "ESPACO"     OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcion·rio n·o saia colada a collection.
		DEFINE CELL NAME "RA_FILIAL"  OF oSecMat ALIAS "SRA"

		DEFINE CELL NAME "RA_MAT"     OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"    OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "CODFUNC"	  OF oSecMat TITLE FSubst(STR0021) SIZE 5 BLOCK {||cCodFunc}			//"FunÁ„o"
		DEFINE CELL NAME "DESCFUNC"   OF oSecMat TITLE FSubst(STR0028) SIZE 20 BLOCK {||Substr(cDescFunc,1,20)}

		IF cPaisLoc == "COL"
			DEFINE CELL NAME "RA_RG"		OF oSecMat TITLE OemToAnsi(STR0074) Size 20 BLOCK {|| SRA->RA_RG}
		ENDIF

		DEFINE CELL NAME "RA_CC"	  OF oSecMat TITLE  SIZE nTamCC BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.,.F.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.,.F.) )} //busca informaÁ„o historicas
		DEFINE CELL NAME "CTT_DESC01" OF oSecMat TITLE FSubst(STR0028) SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.,.F.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.,.F.) )}
		DEFINE CELL NAME "CTT_NOME"   OF oSecMat TITLE FSubst(STR0110)  SIZE 60 BLOCK {|| (fBusTomad(dDataRef, cCentroC, @cDesToma,,iif (nAnaSin == 1,(cAliasFun)->RA_FILIAL,SRA->RA_FILIAL)),cDesToma)}
		DEFINE CELL NAME "CTT_CEI"    OF oSecMat TITLE FSubst(STR0111)  SIZE 14 BLOCK {|| (fBusTomad(dDataRef, cCentroC,,@cCEI,iif (nAnaSin == 1,(cAliasFun)->RA_FILIAL,SRA->RA_FILIAL)), cCEI)}

		IF cPaisLoc == "COL"
			DEFINE CELL NAME "TPSAL" 		OF oSecMat TITLE OemToAnsi(STR0075) SIZE  20 BLOCK {|| ctpSal := IIF(SRA->RA_TIPOSAL=='1',UPPER(STR0063),IIF(SRA->RA_TIPOSAL=='2',UPPER(STR0064),IIF(SRA->RA_TIPOSAL=='3',UPPER(STR0065),UPPER(STR0066))))}
		ENDIF

		DEFINE CELL NAME "RA_DEPTO"	  OF oSecMat TITLE OemToAnsi(STR0007) SIZE 9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC" OF oSecMat TITLE FSubst(STR0028)SIZE 20 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }


		IF cPaisLoc == "COL"
			DEFINE CELL NAME "CTO_DESC" 	OF oSecMat TITLE OemToAnsi(STR0076) SIZE	20 BLOCK {|| cMoneda := POSICIONE("CTO",1,XFILIAL("CTO")+SRA->RA_MOEDAPG,"CTO_DESC")}
		ENDIF

		DEFINE CELL NAME "RA_ADMISSA" OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }

		IF cPaisLoc == "COL"
			DEFINE CELL NAME "RA_CATFUNC"		OF oSecMat TITLE OemToAnsi(STR0082) SIZE 20  BLOCK {|| cCatFun := SRA->RA_CATFUNC + " " + SUBSTR(POSICIONE("SX5",1,XFILIAL("SX5") + "28" + SRA->RA_CATFUNC ,"X5_DESCSPA"),1,20)  }
			DEFINE CELL NAME "VALSAL"	  	OF oSecMat TITLE( IIF(SRA->RA_TIPOSAL $"13",STR0072,STR0073)) SIZE 20 PICTURE "@E 99,999,999,999.99" BLOCK {|| SRA->RA_SALARIO}

			DEFINE CELL NAME "RA_REMVAR" 	OF oSecMat TITLE OemToAnsi(STR0077)	SIZE 10 BLOCK {|| cRemVar := IIF(SRA->RA_REMVAR == "1", STR0067, STR0068) }
			DEFINE CELL NAME "RA_GROSSUP"	OF oSecMat TITLE OemToAnsi(STR0078) 	SIZE 20 BLOCK {|| cGrossUp:= IIF(SRA->RA_GROSSUP== "1",STR0069,IIF(SRA->RA_GROSSUP =="2",STR0070,STR0071))}
			DEFINE CELL NAME "RA_SALEST"	OF oSecMat TITLE OemToAnsi(STR0079)  	SIZE 20 BLOCK {|| cSalExt	:= IIF(SRA->RA_SALEST=="1",STR0067,STR0068)}

		ELSE
			DEFINE CELL NAME "RA_CATFUNC" OF oSecMat ALIAS "SRA" BLOCK {|| SRA->RA_CATFUNC  }
			DEFINE CELL NAME "VALSAL"	  OF oSecMat TITLE OemToAnsi(STR0022) SIZE 20 PICTURE "@E 99,999,999,999.99" ;	//"Sal.: "
			BLOCK {||fBuscaValSal()}
		ENDIF

		If cPaisLoc != "COS"
			DEFINE CELL NAME "RA_DEPIR"   OF oSecMat ALIAS "SRA" BLOCK {|| SUBSTR(GPRETSR9( "SRA", LastDay(dDataRef), "RA_DEPIR" ),1,4) }
			If lDepSf
				DEFINE CELL NAME "RA_DEPSF"   OF oSecMat ALIAS "SRA" BLOCK {|| SUBSTR(GPRETSR9( "SRA", LastDay(dDataRef), "RA_DEPSF" ),1,4) }
			EndIf

			DEFINE CELL NAME "RA_HRSMES"  OF oSecMat ALIAS "SRA"

			If cPaisLoc =="COL"
				DEFINE CELL NAME "RA_TIPOPRC"	OF oSecMat ALIAS "SRA"
				DEFINE CELL NAME "PERRET"		OF oSecMat TITLE OemToAnsi(STR0081) SIZE 20 BLOCK {||cPerRet := IIF(SRA->RA_TIPOPRC=="1",STR(SRA->RA_PERCIR)+STR0083,"") }
			EndIF
		Endif

		DEFINE CELL NAME "PERCADT"    OF oSecMat TITLE OemToAnsi(STR0023)	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"     OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"    OF oSecMat ALIAS "SRA"

		IF cPaisLoc <> "COL"
			DEFINE CELL NAME "RA_RG"      OF oSecMat ALIAS "SRA"
		EndIf

		DEFINE CELL NAME "RA_TSIMSS"  OF oSecMat ALIAS "SRA"
		DEFINE CELL NAME "RCO_NREPAT" OF oSecMat ALIAS "RCO"
		If cPaisLoc == "COS"
           	DEFINE CELL NAME "RCO_POLRT" OF oSecMat ALIAS "RCO"
		Endif

		If lRaDtrec
			DEFINE CELL NAME "RA_DTREC"   OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_DTREC) }
		Endif

		If lRaFecrei
			DEFINE CELL NAME "RA_FECREI"  OF oSecMat ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_FECREI) }
		Endif

		If lRaSalDia
			DEFINE CELL NAME "RA_SALDIA"  OF oSecMat TITLE  SIZE 13 BLOCK {||cSaldia := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerFim,4), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerFim,4))}
		Endif

		If lRaSalInt
			DEFINE CELL NAME "RA_SALINT"  OF oSecMat TITLE  SIZE 13 BLOCK {||cSaldii :=	IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerFim,5), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDtPerFim,5))}
		EndIf

		DEFINE CELL NAME "RA_SITFOLH"     OF oSecMat TITLE  SIZE 80 BLOCK {|| cSitFunc := IIF( nAnaSin == 1, Gpr106Afas((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerIni,dDtPerFim),''  ) }

		DEFINE CELL NAME "ESPACO2"    OF oSecMat TITLE "" BLOCK {||" "}		//Recurso alternativo para saltar linha.
		DEFINE CELL NAME "PROVDESC"   OF oSecMat TITLE "" SIZE 125

		DEFINE CELL NAME "PROVALT"   OF oSecMat TITLE "" SIZE 24
		DEFINE CELL NAME "ESPACO3"   OF oSecMat TITLE "" SIZE 0
		DEFINE CELL NAME "DESCALT"   OF oSecMat TITLE "" SIZE 17
		DEFINE CELL NAME "BASEALT"   OF oSecMat TITLE "" SIZE 9

		oSecMat:SetLineStyle()
		oSecMat:SetCols(3)
		oSecMat:SetTotalInLine(.F.)
		oSecMat:Cell("ESPACO"    ):SetCellBreak(.T.)
		oSecMat:Cell("RA_NOME"   ):SetCellBreak(.T.)

		If cPaisLoc == "COL"
			oSecMat:Cell("RA_RG"):SetCellBreak(.T.)
			oSecMat:Cell("TPSAL"):SetCellBreak(.T.)
			oSecMat:Cell("CTO_DESC"):SetCellBreak(.T.)
		Else
			oSecMat:Cell("DESCFUNC"  ):SetCellBreak(.T.)
			oSecMat:Cell("CTT_DESC01"):SetCellBreak(.T.)
			oSecMat:Cell("QB_DESCRIC"):SetCellBreak(.T.)
		EndIF

		oSecMat:Cell("ESPACO2"   ):SetCellBreak(.T.)

		If cPaisLoc == "MEX"
			oSecMat:Cell("RA_CATFUNC"):Disable()
			oSecMat:Cell("VALSAL"    ):Disable()
			oSecMat:Cell("RA_DEPIR"  ):Disable()
			oSecMat:Cell("RA_DEPSF"  ):Disable()
			oSecMat:Cell("PERCADT"   ):Disable()
			oSecMat:Cell("RA_HRSMES" ):Disable()
			oSecMat:Cell("RCO_NREPAT"):SetCellBreak(.T.)
			oSecMat:Cell("RA_SALINT" ):SetCellBreak(.T.)
		Else
			If cPaisLoc != "COS"
				oSecMat:Cell("RA_CIC"    ):Disable()
				oSecMat:Cell("RCO_NREPAT"):Disable()

				IF cPaisLoc == "COL"
					oSecMat:Cell("PERRET" ):SetCellBreak(.T.)
				ELSE
					oSecMat:Cell("RA_RG"     ):Disable()
					oSecMat:Cell("RA_HRSMES" ):SetCellBreak(.T.)
				ENDIF
			Else
				oSecMat:Cell("RCO_POLRT"):SetCellBreak(.T.)
			Endif

			oSecMat:Cell("RA_CURP"   ):Disable()
			oSecMat:Cell("RA_TSIMSS" ):Disable()

			If lRaDtRec
				oSecMat:Cell("RA_DTREC"  ):Disable()
			Endif

			If lRaFecrei
				oSecMat:Cell("RA_FECREI" ):Disable()
			Endif

			If lRaSaldia
				oSecMat:Cell("RA_SALDIA" ):Disable()
			Endif

			If lRaSalint
				oSecMat:Cell("RA_SALINT" ):Disable()
			Endif

		EndIf
		
		oSecMat:Disable()
		oSecMat:SetCharSeparator(" ")
		oSecMat:SetDynamicKey(OemToAnsi(STR0002))	//"MatrÌcula"
		oSecMat:SetNoFilter({"SQB","RCO","RGC"})
		TRPosition():New(oSecMat,"SRA",nOrdSra,{|| If (nAnaSin == 1, (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_MAT, (cAliasQry)->RA_FILIAL )},.T.)
		
	//SECTION 02
	DEFINE SECTION oSecLan OF oReport TITLE OemToAnsi(STR0026) TABLES "SRC", "SRD", "SRV", "SRA"	//Verbas do Funcion·rio

		DEFINE CELL NAME "RA_MAT" OF oSecLan ALIAS "SRA"
		DEFINE CELL NAME "PDP"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCP"  OF oSecLan TITLE FSubst(STR0028) SIZE 14 PICTURE "@!" 		//"DescriÁ„o"
		DEFINE CELL NAME "REFERP" OF oSecLan TITLE iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) SIZE 08 					//"Ref." #"OCOR."
		DEFINE CELL NAME "VALORP" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize				//"Valor"

		DEFINE CELL NAME "INSSP"	OF oSecLan TITLE 'IN' SIZE 2
		DEFINE CELL NAME "FGTSP"	OF oSecLan TITLE 'FG' SIZE 2
		DEFINE CELL NAME "IRP"	OF oSecLan TITLE 'IR' SIZE 2

		DEFINE CELL NAME "PIPEP"  OF oSecLan TITLE "|" SIZE 2       BLOCK {||"|"}

		DEFINE CELL NAME "PDD"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCD"  OF oSecLan TITLE FSubst(STR0028) SIZE 14 PICTURE "@!" 		//"DescriÁ„o"
		DEFINE CELL NAME "REFERD" OF oSecLan TITLE  iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) SIZE 08					//"Ref."
		DEFINE CELL NAME "VALORD" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize				//"Valor"

		DEFINE CELL NAME "INSSD"	OF oSecLan TITLE 'IN' SIZE 2
		DEFINE CELL NAME "FGTSD"	OF oSecLan TITLE 'FG' SIZE 2
		DEFINE CELL NAME "IRD"  	OF oSecLan TITLE 'IR' SIZE 2

		DEFINE CELL NAME "PIPED"  OF oSecLan TITLE "|" SIZE 2       BLOCK {||"|"}

		DEFINE CELL NAME "PDB"    OF oSecLan TITLE OemToAnsi(STR0027) SIZE 03 PICTURE "@!"	 	//"Cod."
		DEFINE CELL NAME "DESCB"  OF oSecLan TITLE FSubst(STR0028) SIZE 15 PICTURE "@!" 		//"DescriÁ„o"

		aEval({'P', 'D'},{|x|oSecLan:Cell("INSS" + x):Disable(),oSecLan:Cell("FGTS" + x):Disable(),oSecLan:Cell("IR" + x):Disable()})

		If cPaisLoc == "COS"
			DEFINE CELL NAME "REFERB" OF oSecLan TITLE  iif(lGper670  .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) SIZE 08 					//"Ref."
			oSecLan:Cell("REFERB"):SetHeaderAlign("RIGHT")
		Endif

		DEFINE CELL NAME "VALORB" OF oSecLan TITLE OemToAnsi(STR0030) SIZE nSize 				//"Valor"

		oSecLan:SetName("LANCAMENTO")
		oSecLan:Cell("RA_MAT"):Disable()
		oSecLan:Cell("REFERP"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORP"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORP"):lAutoSize := .F.
		oSecLan:Cell("REFERD"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORD"):SetHeaderAlign("RIGHT")
		oSecLan:Cell("VALORB"):SetHeaderAlign("RIGHT")
		oSecLan:SetTotalInLine(.F.)
 		oSecLan:Disable()
		oSecLan:SetDynamicKey(OemToAnsi(STR0004))	//"LanÁamentos"

	//SECTION 03
	DEFINE SECTION oSecNom OF oReport TITLE OemToAnsi(STR0040) TABLES "SRA","SQB","CTT","RCO" ORDERS aOrd	//"Filial / Nome"

		DEFINE CELL NAME "ESPACO"     OF oSecNom TITLE "" BLOCK {||" "}		//Recurso alternativo para que a section do funcion·rio n·o saia colada a collection.
		DEFINE CELL NAME "RA_FILIAL"  OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_NOME"    OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_MAT"     OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "CODFUNC"	  OF oSecNom TITLE FSubst(STR0021) SIZE 5 BLOCK {||cCodFunc}			//"FunÁ„o"
		DEFINE CELL NAME "DESCFUNC"   OF oSecNom TITLE FSubst(STR0028) SIZE 20 BLOCK {||Substr(cDescFunc,1,20)}

		DEFINE CELL NAME "RA_CC"	  OF oSecNom TITLE  SIZE nTamCC BLOCK {|| cCentroC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,,.T.,.F.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,,.T.,.F.) )} //busca informaÁ„o historicas
		DEFINE CELL NAME "CTT_DESC01" OF oSecNom TITLE FSubst(STR0028) SIZE 60 BLOCK {|| cDescCC := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,2,2,.T.,.F.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,2,2,.T.,.F.) )}
		// Dados do tomador de serviÁo
		DEFINE CELL NAME "CTT_NOME"   OF oSecNom TITLE FSubst(STR0110) SIZE 60 BLOCK {|| (fBusTomad(dDataRef, cCentroC, @cDesToma,,iif (nAnaSin == 1,(cAliasFun)->RA_FILIAL,SRA->RA_FILIAL)),cDesToma)}
		DEFINE CELL NAME "CTT_CEI"    OF oSecNom TITLE FSubst(STR0111) SIZE 14 BLOCK {|| (fBusTomad(dDataRef, cCentroC,,@cCEI,iif (nAnaSin == 1,(cAliasFun)->RA_FILIAL,SRA->RA_FILIAL)),cCEI)}

		DEFINE CELL NAME "RA_DEPTO"	  OF oSecNom TITLE OemToAnsi(STR0007) SIZE 9 BLOCK {|| cDepto := IIf (nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,,.T.) )}
		DEFINE CELL NAME "QB_DESCRIC" OF oSecNom TITLE FSubst(STR0028)SIZE 20 BLOCK {|| cDescDepto := IIF( nAnaSin == 1, fBusHisFun((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDataRef,3,2,.T.), fBusHisFun(SRA->RA_FILIAL,SRA->RA_MAT,dDataRef,3,2,.T.) ) }

		DEFINE CELL NAME "RA_ADMISSA" OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_ADMISSA) }
		DEFINE CELL NAME "RA_CATFUNC" OF oSecNom ALIAS "SRA" BLOCK {|| SRA->RA_CATFUNC }
		DEFINE CELL NAME "VALSAL"	  OF oSecNom TITLE OemToAnsi(STR0022) SIZE 20 PICTURE "@E 99,999,999,999.99" ;	//"Sal.: "
			BLOCK {||fBuscaValSal()}

		If cPaisLoc != "COS"
			DEFINE CELL NAME "RA_DEPIR"   OF oSecNom ALIAS "SRA" BLOCK {|| Substr(GPRETSR9( "SRA", LastDay(dDataRef), "RA_DEPIR" ),1, 4)}

			If lDepSf
				DEFINE CELL NAME "RA_DEPSF"   OF oSecNom ALIAS "SRA" BLOCK {|| Substr(GPRETSR9( "SRA", LastDay(dDataRef), "RA_DEPSF" ),1, 4)}
			EndIf

			DEFINE CELL NAME "RA_HRSMES"  OF oSecNom ALIAS "SRA"
		Endif

		DEFINE CELL NAME "PERCADT"    OF oSecNom TITLE OemToAnsi(STR0023)	SIZE 3 		//"Perc.Adto.: "
		DEFINE CELL NAME "RA_CIC"     OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_CURP"    OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_RG"      OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RA_TSIMSS"  OF oSecNom ALIAS "SRA"
		DEFINE CELL NAME "RCO_NREPAT" OF oSecNom ALIAS "RCO"

		If nAnaSin == 1
			DEFINE CELL NAME "RA_SITFOLH"     OF oSecNom TITLE  SIZE 80 BLOCK {|| IIF( nAnaSin == 1, Gpr106Afas((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT,dDtPerIni,dDtPerFim),'' ) }
		EndIf


		If cPaisLoc == "COS"
			DEFINE CELL NAME "RCO_POLRT" OF oSecNom ALIAS "RCO"
		Endif

		If lRaDtrec
			DEFINE CELL NAME "RA_DTREC"   OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_DTREC) }
		Endif

		If lRaFecrei
			DEFINE CELL NAME "RA_FECREI"  OF oSecNom ALIAS "SRA" BLOCK {|| Dtoc(SRA->RA_FECREI)}
		Endif

		If lRaSalDia
			DEFINE CELL NAME "RA_SALDIA"  OF oSecNom ALIAS "SRA"
		Endif

		If lRaSalInt
			DEFINE CELL NAME "RA_SALINT"  OF oSecNom ALIAS "SRA"
		Endif

		DEFINE CELL NAME "ESPACO2"    OF oSecNom TITLE "" BLOCK {||" "}		//Recurso alternativo para saltar linha.
		DEFINE CELL NAME "PROVDESC"   OF oSecNom TITLE "" SIZE 125

		DEFINE CELL NAME "PROVALT"   OF oSecNom TITLE "" SIZE 24
		DEFINE CELL NAME "ESPACO3"   OF oSecNom TITLE "" SIZE 0
		DEFINE CELL NAME "DESCALT"   OF oSecNom TITLE "" SIZE 17
		DEFINE CELL NAME "BASEALT"   OF oSecNom TITLE "" SIZE 9

		oSecNom:SetLineStyle()
		oSecNom:SetCols(3)
		oSecNom:SetTotalInLine(.F.)
		oSecNom:Cell("ESPACO"    ):SetCellBreak(.T.)
		oSecNom:Cell("RA_MAT"    ):SetCellBreak(.T.)
		oSecNom:Cell("DESCFUNC"  ):SetCellBreak(.T.)
		oSecNom:Cell("QB_DESCRIC"):SetCellBreak(.T.)
		oSecNom:Cell("CTT_DESC01"):SetCellBreak(.T.)
		oSecNom:Cell("ESPACO2"   ):SetCellBreak(.T.)

		If cPaisLoc == "MEX"
			oSecNom:Cell("RA_CATFUNC"):Disable()
			oSecNom:Cell("VALSAL"    ):Disable()
			oSecNom:Cell("RA_DEPIR"  ):Disable()
			oSecNom:Cell("RA_DEPSF"  ):Disable()
			oSecNom:Cell("PERCADT"   ):Disable()
			oSecNom:Cell("RA_HRSMES" ):Disable()
			oSecNom:Cell("RCO_NREPAT"):SetCellBreak(.T.)
			oSecNom:Cell("RA_SALINT" ):SetCellBreak(.T.)
		Else
			If cPaisLoc != "COS"
				oSecNom:Cell("RA_CIC"    ):Disable()
				oSecNom:Cell("RCO_NREPAT"):Disable()
				oSecNom:Cell("RA_RG"     ):Disable()
				oSecNom:Cell("RA_HRSMES" ):SetCellBreak(.T.)
            Else
				oSecNom:Cell("RCO_POLRT"):SetCellBreak(.T.)
			Endif

			oSecNom:Cell("RA_CURP"   ):Disable()
			oSecNom:Cell("RA_TSIMSS" ):Disable()

			If lRaDtRec
				oSecNom:Cell("RA_DTREC"  ):Disable()
			Endif

			If lRaFeCrei
				oSecNom:Cell("RA_FECREI" ):Disable()
			Endif

			If lRaSalDia
				oSecNom:Cell("RA_SALDIA" ):Disable()
			Endif

			If lRaSalInt
				oSecNom:Cell("RA_SALINT" ):Disable()
			Endif

		EndIf

		oSecNom:Disable()
		oSecNom:SetCharSeparator("")
		oSecNom:SetDynamicKey(OemToAnsi(STR0003))	//"Nome"
		oSecNom:SetNoFilter({"SQB","RCO","SRA","CTT"})
		TRPosition():New(oSecNom,"SRA",nOrdSra,{|| If (nAnaSin == 1 , (cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT, " ")},.T.)

	//SECTION 04
	DEFINE SECTION oSecCtc OF oReport TABLES "CTT" ORDERS aOrd TITLE OemToAnsi(STR0041) TOTAL IN COLUMN  // "C.Custo Cadastro"
		DEFINE CELL NAME "CTT_FILIAL" 	OF oSecCtc ALIAS "CTT"
		DEFINE CELL NAME "RA_CC"   		OF oSecCtc ALIAS "CTT"
		DEFINE CELL NAME "CTT_DESC01"	OF oSecCtc TITLE FSubst(STR0028) ALIAS "CTT"

		oSecCtc:SetLineStyle()
		oSecMat:SetCols(4)
		oSecCtc:Disable()
		oSecCtc:SetDynamicKey(OemToAnsi(STR0005))	//"C.Custo Cad."

	//SECTION 05
	DEFINE SECTION oSecSqb OF oReport TABLES "SQB", "CTT", "SRA" ORDERS aOrd TITLE OemToAnsi(STR0046) TOTAL IN COLUMN // "Departamento"

		DEFINE CELL NAME "QB_FILIAL"	OF oSecSqb ALIAS "SQB"
		DEFINE CELL NAME "QB_DEPTO"		OF oSecSqb TITLE OemToAnsi(STR0007)	ALIAS "SQB"
		DEFINE CELL NAME "QB_DESCRIC"	OF oSecSqb TITLE FSubst(STR0028)	ALIAS "SQB"

		oSecSqb:SetLineStyle()
		oSecMat:SetCols(4)
		oSecSqb:Cell("QB_FILIAL"):Disable()
		oSecSqb:Disable()
		oSecSqb:SetDynamicKey(OemToAnsi(STR0007))	//"Depto."
		oSecSqb:SetNoFilter({ "SQB", "CTT", "SRA" })


	//SECTION 06
	DEFINE SECTION oSecCtm OF oReport TABLES "CTT" ORDERS aOrd TITLE OemToAnsi(STR0048) TOTAL IN COLUMN // "C.Custo Movimento"

		DEFINE CELL NAME "CTT_FILIAL" 	OF oSecCtm ALIAS "CTT"
		DEFINE CELL NAME "CTT_CUSTO"   	OF oSecCtm ALIAS "CTT"
		DEFINE CELL NAME "CTT_DESC01"	OF oSecCtm TITLE FSubst(STR0028) ALIAS "CTT"

		oSecCtm:SetLineStyle()
		oSecMat:SetCols(4)
		oSecCtm:Disable()
		oSecCtm:SetDynamicKey(OemToAnsi(STR0006))	//"C.Custo Mov."

	//SECTION 07
	DEFINE SECTION oSecDifLiq OF oReport TITLE "" // "Dif de Liquidos"

Return(oReport)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ R106Imp    ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥30/11/2007 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ≥±±
±±≥Descriáao ≥ Relatorio de Folha de Pagamento                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function R106Imp(oReport,lGper670)
Local oSectLanc		:= oReport:Section(2)
Local oSectFunc
Local oSectCttc
Local oSectDept
Local cFiltro		:= ""
Local cFiltroC 		:= ""
Local cFiltroD 		:= ""
Local cSitQuery		:= ""
Local cCatQuery		:= ""
Local cTpcQuery		:= ""
Local cOrdemFun		:= ""
Local cOrdemLan		:= ""
Local cTitFil		:= ""
Local cTitUnN		:= ""
Local cTitEFil		:= ""
Local cTitCC		:= ""
Local cTitDp		:= ""
Local cTitFun		:= ""
Local cCpoAls		:= ""
Local cCpoAlsC		:= ""
Local cCpoAlsD		:= ""
Local cCpoView		:= ""
Local cCpoViewC		:= ""
Local cCpoViewD		:= ""
Local cCpoViewG		:= ""
Local cCpoAdView	:= ""
Local cCpoDelim		:= ""
Local cCpoDelimC	:= ""
Local cCpoDelimD	:= ""
Local cCpoAdicLan	:= "" // CAMPOS ADICIONAIS A SEREM UTILIZADOS NA SECAO DE LANCAMENTOS
Local cCpoAdicEsp	:= "" // CAMPOS ADICIONAIS DE PAISES ESPECIFICOS
Local cCpoCcRc		:= ""
Local cCpoCcRd		:= ""
Local cJoin			:= ""
Local cJoinC		:= ""
Local cJoinD		:= ""
Local cJoinSQB		:= ""
Local cJoin1		:= "" //Juncao de todos os Joins para realizar a Query cAliasFun SRC
Local cJoin2		:= "" //Juncao de todos os Joins para realizar a Query cAliasFun SRD
Local cJoin3		:= "" //Juncao de todos os Joins para realizar a Query cAliasQry SRC
Local cJoin4		:= "" //Juncao de todos os Joins para realizar a Query cAliasQry SRD
Local cJoinEsp		:= "" // JOIN ADICIONAL DE PAISES ESPECIFICOS
Local cJoinSRC		:= ""
Local cJoinSRD		:= ""
Local cCCpoQuebra	:= ""
Local cDCpoQuebra	:= ""
Local cJoinView		:= ""
Local cNotDel		:= ""
Local cMes			:= ""
Local cAno			:= ""
Local cNumPg		:= Space(2)
Local cExtraC		:= "%%"
Local cExtraD		:= "%%"
Local cGroupEC		:= "%%"
Local cGroupED		:= "%%"
Local nReg			:= 0
Local nPos			:= 0

Local bLancamentos	:= {|oSelf|fImprimeLanca(oSelf)}
Local bLancSint		:= {|oSelf|fImprSint(oSelf,lGper670)}
Local bBlock			:= {}

Local cCoalese		:= ""
Local cDepenContr	:= ""
Local cJoinAux		:= ""
Local cUltSem		:= ""
Local lLandScape := (oReport:GetOrientation() == 2)
Local nDescTam := 15

Local cAcessaSRA  	:=   ChkRH( "GPER106" , "SRA" , "2" )
Local cSFiltrSQL      := fSFiltrSQL(cAcessaSRA)

Local uRatDes
Local lGper040		:= (FunName() == "GPER040")
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})
Local lRobo			:= IsBlind() .And. !FWGetRunSchedule()

Private aFldRv		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RV_DESC"} ), {})
Private lOfusca		:= Len(aFldRel) > 0
Private aVerbas		:= {}
Private aVerbasRet	:= {}
Private aVerbasSin	:= {}
Private aPerAberto	:= {}
Private aPerFechado	:= {}
Private nHrsMes		:= 0
Private nSalario	:= 0
Private cCpoQuebra	:= ""
Private c2CpoQbr	:= ""
Private cFilAux 	:= "##"
Private lRatDes 	:= .F.
Private lPerAberto	:= .T.
Private lHoraSexag  := .F.

uRatDes 	 	:= GetMvRH( "MV_RAT0973", .F., .F. )

If lRobo 				//Carrega valores default Treport
	oReport:nDevice 	:= 4 //Planilha
	oReport:nOrder 		:= nOrdem
EndIf

// Parametro era logico e mudou para caracter indevidamente no P12
If ValType( uRatDes ) == "L"
	lRatDes := uRatDes
ElseIf ValType( uRatDes ) == "C"
	uRatDes := GetMvRH( "MV_RAT0973", .F., ".F." )
	lRatDes	:= ( uRatDes == ".T." )
EndIf

nOrdSra 	:= RetOrdem("RA_FILIAL+RA_MAT")

If !lRobo
	nOrdem		:= oReport:GetOrder()

	If (nOrdRemov > 0) .And. (nOrdem >= nPosRemov)
		nOrdem := nOrdem + nOrdRemov
	EndIf
EndIf

cCpoView	:= "%RAFILIAL RA_FILIAL"
cCpoViewG	:= "%RAFILIAL"
cCpoAls	:= "%RA_FILIAL RAFILIAL"

If nOrdem == 1		//MatrÌcula
	oSectFunc 	:= oReport:Section(1)
ElseIf nOrdem == 2		//Nome
	oSectFunc 	:= oReport:Section(3)
ElseIf nOrdem == 3		//C.Custo Cadastro + MatrÌcula
	oSectCttc	:= oReport:Section(4)
	oSectFunc 	:= oReport:Section(1)
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf
ElseIf nOrdem == 4		//C.Custo Cadastro + Nome
	oSectCttc	:= oReport:Section(4)
	oSectFunc 	:= oReport:Section(3)
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf
ElseIf nOrdem == 5		//C.Custo Movimento + MatrÌcula
	oSectCttc	:= oReport:Section(6)
	oSectFunc 	:= oReport:Section(1)
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf
ElseIf nOrdem == 6		//C.Custo Movimento + Nome
	oSectCttc	:= oReport:Section(6)
	oSectFunc 	:= oReport:Section(3)
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf
ElseIf nOrdem == 7		//Depto + MatrÌcula
	oSectDept	:= oReport:Section(5)
	oSectFunc 	:= oReport:Section(1)
	oSectDept:Cell("QB_FILIAL" ):Enable()
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
	EndIf
ElseIf nOrdem == 8		//Depto + Nome
	oSectDept	:= oReport:Section(5) //section(6)
	oSectFunc 	:= oReport:Section(3) //section(4)
	oSectDept:Cell("QB_FILIAL" ):Enable()
	If nAnaSin == 1	//AnalÌtico
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
	EndIf
EndIf

oSectFunc:SetName("FUNCIONARIO")
oSectFunc:SetLineCondition( { || Eval(bBlock) } )
If lGper670
	fGpr670Perg(@cMes,@cAno,@aPerAberto,@aPerFechado)
	cProcesso	:= cListProc
	cRoteiro	:= cListRot
	cPeriodo	:= substr(mv_par01,3,4) + substr(mv_par01,1,2)
	cPagamento	:= "99"
	cSituacao	:= mv_par10
	cCategoria	:= mv_par11
	nTpContr 	:= mv_par15      //Tipo Contrato:  1=Indeterminado; 2=Determinado; 3=Ambos
	lBrkCc		:= .F. 			 //Salta Pag. quebra C.Custo: 1=Sim; 2=Nao
	lBrkDp		:= .F. 			 //Salta Pag. quebra Depto:   1=Sim; 2=Nao
	lImpFil  	:= mv_par12 == 1 //Imprime totais por Filial: 1=Sim; 2=Nao
	lImpEmp  	:= mv_par13 == 1 //Imprime totais por Empr.:  1=Sim; 2=Nao
	lImpUni		:= lImpEmp       //Imprime totais por Unidade de Negocio: se imprime totais por empresa=Sim; senao = Nao
	nTipCC   	:= 1    		 //Tipo Impressao C.Custo: 1=Codigo; 2=Descricao; 3=Ambos
	nTipDp		:= 1     		 //Tipo Impressao Depto: 1=Codigo; 2=Descricao; 3=Ambos
	lBrkPagFil	:= .F.			 //Salta Pag. quebra Filial 1=Sim; 2=Nao:
	lImpBase	:= mv_par16 == 1
	cRefOco		:= MV_PAR14
	oSectLanc:Cell("REFERD" ):SetTitle( iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)))
	oSectLanc:Cell("REFERP" ):SetTitle( iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)))
Else
	cProcesso	:= mv_par01
	cRoteiro	:= mv_par02
	cPeriodo	:= mv_par03
	cPagamento	:= mv_par04
	cSituacao	:= mv_par10
	cCategoria	:= mv_par11
	nTpContr 	:= mv_par12      //Tipo Contrato:  1=Indeterminado; 2=Determinado; 3=Ambos
	nAnaSin   	:= mv_par13      //Tipo Relatorio: 1=Analitico; 2=Sintetico
	lBrkCc		:= mv_par14 == 1 //Salta Pag. quebra C.Custo: 1=Sim; 2=Nao
	lBrkDp		:= mv_par15 == 1 //Salta Pag. quebra Depto:   1=Sim; 2=Nao
	lImpFil  	:= mv_par16 == 1 //Imprime totais por Filial: 1=Sim; 2=Nao
	lImpEmp  	:= mv_par17 == 1 //Imprime totais por Empr.:  1=Sim; 2=Nao
	lImpUni		:= lImpEmp       //Imprime totais por Unidade de Negocio: se imprime totais por empresa=Sim; senao = Nao
	nTipCC   	:= mv_par18      //Tipo Impressao C.Custo: 1=Codigo; 2=Descricao; 3=Ambos
	nTipDp		:= mv_par19      //Tipo Impressao Depto: 1=Codigo; 2=Descricao; 3=Ambos
	lImpBase	:= mv_par20 == 1 //Imprimir Bases: 1=Sim; 2=Nao
	lBrkPagFil	:= MV_PAR21 == 1 //Salta Pag. quebra Filial 1=Sim; 2=Nao:
	lHoraSexag  := ValType(mv_par22) == "N" .And. mv_par22 == 1 //Imprime verbas de referÍncia horas no formato sexagesimal 1=Sim; 2=Nao
EndIf

If !lGper670
	cTitulo := fDesc("SRY", cRoteiro, "RY_DESC", , xFilial("SRY"), RetOrdem("SRY","RY_FILIAL+RY_CALCULO"))
EndIf

oReport:SetTitle(AllTrim(cTitulo))

lSint := (nAnaSin == 2)

If lSint
	bBlock := {|| .T. }
	oSectLanc:SetParentRecno()
	oSectLanc:SetNoSkip()
Else
	bBlock := {|| dbSelectArea("SRA"), SRA->(dbSetOrder(1)), SRA->(MsSeek((cAliasQry)->RA_FILIAL+(cAliasQry)->RA_MAT)), fBuscaFunc(dDataRef, @cCodFunc, @cDescFunc),  fCtrlDtRA(oSectFunc), fVerSituac((cAliasFun)->RA_FILIAL,(cAliasFun)->RA_MAT, cSituacao, dDtPerIni, dDtPerFim)}
	if(lLandScape)
		nDescTam 	:= oSectLanc:Cell("DESCD" ):GetSize() + 9
		aEval({'P', 'D'},{|x|oSectLanc:Cell("INSS" + x):Enable(),oSectLanc:Cell("FGTS" + x):Enable(),;
				oSectLanc:Cell("IR" + x):Enable(),oSectLanc:Cell("DESC" + x):SetSize(nDescTam)})
		oSectLanc:Cell("DESCB"):SetSize(nDescTam)
	Else
		oSectLanc:Cell("RA_MAT"):Disable()
		aEval({'P', 'D'},{|x|oSectLanc:Cell("INSS" + x):Disable(),oSectLanc:Cell("FGTS" + x):Disable(),oSectLanc:Cell("IR" + x):Disable()})
	endIf
Endif

If cPaisLoc == "MEX" .And. !lGper670
	lDifLiq := Iif(mv_par22 == 1, .T., .F.)		//Imprime Difer.Liquidos: 1=Sim; 2=Nao
	lSumaVerba := Iif(mv_par23 == 1, .T., .F.)	//Sumariza Verbas: 1=Sim; 2=Nao
Else
	lDifLiq	:= .F.
	lSumaVerba	:= lAglutPd
EndIf


If nTipCC == 1              	//-- Codigo C.Custo
	oSectFunc:Cell("CTT_DESC01"):Disable()
ElseIf nTipCC == 2          	//-- Descricao C.Custo
	oSectFunc:Cell("RA_CC"     ):Disable()
EndIf

IF !(nTipCC == 4) // Se n„o for dados de tomador, desabilita as celulas de tomador.
	oSectFunc:Cell("CTT_NOME"):Disable()
	oSectFunc:Cell("CTT_CEI"):Disable()
EndIf

If nTipDp == 1              	//-- Codigo Depto.
	oSectFunc:Cell("QB_DESCRIC"):Disable()
ElseIf nTipDp == 2          	//-- Descricao Depto.
	oSectFunc:Cell("RA_DEPTO"  ):Disable()
EndIf

If (!lSint)	//AnalÌtico
	oSectFunc:Cell("PROVDESC"):Enable()
	If lImpBase
		If oReport:cFontBody <> "Courier New" .Or. oReport:nFontBody <> 8
			oSectFunc:Cell("PROVDESC"  ):Disable()

			oSectFunc:Cell("PROVALT"  ):SetBlock({|| Space(7) + OemToAnsi(STR0114) }) // P R O V E N T O S
			oSectFunc:Cell("DESCALT"  ):SetBlock({|| OemToAnsi(STR0115) }) // D E S C O N T O S 
			oSectFunc:Cell("BASEALT"  ):SetBlock({|| OemToAnsi(STR0116) }) // B A S E S
			oSectFunc:Cell("ESPACO3"  ):SetBlock({|| "" })
			If oReport:nFontBody > 11
				oSectFunc:Cell("ESPACO3"  ):Disable()
			EndIf
		Else
			oSectFunc:Cell("PROVDESC"  ):SetBlock({||OemToAnsi(STR0024)})
			//"        P R O V E N T O S                              D E S C O N T O S                              B A S E S"
			
			oSectFunc:Cell("PROVALT"  ):Disable()
			oSectFunc:Cell("ESPACO3"  ):Disable()
			oSectFunc:Cell("DESCALT"  ):Disable()
			oSectFunc:Cell("BASEALT"  ):Disable()
		EndIf
	Else
		oSectLanc:Cell("PDB"    ):SetTitle("")
		oSectLanc:Cell("DESCB"  ):SetTitle("")
		oSectLanc:Cell("VALORB" ):SetTitle("")

		oSectLanc:Cell("PDB"     ):Hide()
		oSectLanc:Cell("DESCB"   ):Hide()
		oSectLanc:Cell("VALORB"  ):Hide()
		
		If oReport:cFontBody <> "Courier New" .Or. oReport:nFontBody <> 8
			oSectFunc:Cell("PROVDESC"	):Disable()
			oSectFunc:Cell("BASEALT"	):Disable()

			oSectFunc:Cell("PROVALT"  ):SetBlock({|| Space(7) + OemToAnsi(STR0114) }) // P R O V E N T O S
			oSectFunc:Cell("DESCALT"  ):SetBlock({|| OemToAnsi(STR0115) }) // D E S C O N T O S 
			oSectFunc:Cell("ESPACO3"  ):SetBlock({|| "" })
			If oReport:cFontBody <> "Courier New" .And. oReport:nFontBody > 9
				oSectFunc:Cell("ESPACO3"  ):Disable()
			EndIf
		Else
			oSectFunc:Cell("PROVDESC"):SetBlock({||OemToAnsi(STR0025)})
			//"        P R O V E N T O S                              D E S C O N T O S                              B A S E S"
			
			oSectFunc:Cell("PROVALT"  ):Disable()
			oSectFunc:Cell("ESPACO3"  ):Disable()
			oSectFunc:Cell("DESCALT"  ):Disable()
			oSectFunc:Cell("BASEALT"  ):Disable()
		EndIf
	EndIf
Else
	oSectFunc:Cell("PROVDESC"):Disable()
Endif

cNumPg := If (cPagamento == "99" , "" , cPagamento)
If !lGper670
	//ESTA FUN«√O BUSCA TODOS OS PERIODOS EM ABERTO E FECHADO DOS FUNCIONARIOS
	RetPerAbertFech(cProcesso,cRoteiro,cPeriodo,cPagamento,,,@aPerAberto,@aPerFechado,,, )

	If Empty(aPerAberto) .And. Empty(aPerFechado)
	   MsgAlert(STR0031,STR0032)	//"Nao foi encontrado nenhum periodo" ### "Verifique Par‚metros de Impress„o."
	   Return
	Endif

	If (nPos:=aScan(aPerAberto, {|x| x[1] == cPeriodo .And. x[2] == cNumPg})) > 0
		cMes		:= aPerAberto[nPos,3]
		cAno		:= aPerAberto[nPos,4]
		dDtPerIni	:= aPerAberto[nPos,5]
		dDtPerFim	:= aPerAberto[nPos,6]
		dDtPago		:= aPerAberto[nPos,7]
		lPerAberto	:= .T.
	Elseif (nPos:=aScan(aPerFechado, {|x| x[1] == cPeriodo .And. x[2] == cNumPg})) > 0
		cMes		:= aPerFechado[nPos,3]
		cAno		:= aPerFechado[nPos,4]
		dDtPerIni	:= aPerFechado[nPos,5]
		dDtPerFim	:= aPerFechado[nPos,6]
		dDtPago		:= aPerFechado[nPos,7]
		lPerAberto	:= .F.
	Endif
Else
	dDtPerFim := LastDate( CTOD("01/" + cMes + "/" + cAno) )
	cMes	:= Substr(mv_par01,1,2)
	cAno	:= Substr(mv_par01,3,4)
EndIf

If nAnaSin == 2 .and. cPagamento == "99" //Obtem a ˙ltima semana do perÌodo atual
	cUltSem := fLastSem( cProcesso, cRoteiro, cPeriodo ) //Obtem a ˙ltima semana do perÌodo
EndIf

cDtPerFim := DtoS(dDtPerFim)

//--MONTAGEM DO DDATAREF SOBRE O PERIODO
dDataRef	:= StoD(cAno + cMes + "01")
cMesAnoRef	:= StrZero(Month(dDataRef),2) + StrZero(Year(dDataRef),4)
cAnoMesRef	:= Right(cMesAnoRef,4) + Left(cMesAnoRef,2)

If cPagamento # "99"
	cTitulo := Alltrim(cTitulo)+" - "+AllTrim(GR040RetPer( cPagamento, cPeriodo ))
Else
	cTitulo := Alltrim(cTitulo)+" / "+Upper(MesExtenso(Month(dDataRef)))+OemToAnsi(STR0035)+STR(YEAR(dDataRef),4) 	//" DE "
EndIf

If nAnaSin	== 1 	//Analitico
	If !lSint
		cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0033)	//AnalÌtico
	Else
		cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0034)	//Sintetico
	Endif

	If nOrdem == 1
		cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0002)	//MatrÌcula
	ElseIf nOrdem == 2
		cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0003)	//Nome
	Else
		oSectFunc:Cell("RA_FILIAL" ):Disable()
	EndIf

	oSectFunc:OnPrintLine(bLancamentos)
	oSectLanc:OnPrintLine(bLancamentos)

	If cPaisLoc <> "COL"
		oSectFunc:Cell("RA_CATFUNC"):SetBlock({||fRetSR7(dDataRef, dDataRef, .T.)})
	EndIf

	oSectFunc:Cell("PERCADT"   ):SetBlock({||StrZero((cAliasFun)->RA_PERCADT,3)})

Else	//SintÈtico
	If !lGper670
		cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0034)	//Sintetico
	EndIf
	oSectFunc:OnPrintLine(bLancSint)
	oSectLanc:OnPrintLine(bLancSint)
	oSectFunc:Cell("ESPACO"	   ):Disable()
	oSectFunc:Cell("RA_MAT"    ):Disable()
	oSectFunc:Cell("RA_NOME"   ):Disable()
	oSectFunc:Cell("CODFUNC"   ):Disable()
	oSectFunc:Cell("DESCFUNC"  ):Disable()
	oSectFunc:Cell("RA_ADMISSA"):Disable()
	oSectFunc:Cell("RA_CATFUNC"):Disable()
	oSectFunc:Cell("VALSAL"    ):Disable()

	If cPaisLoc == "COS"
		oSectFunc:Cell("RCO_POLRT"):Disable()
	Else
		oSectFunc:Cell("RA_DEPIR"  ):Disable()

		If lDepSf
			oSectFunc:Cell("RA_DEPSF"  ):Disable()
		EndIf

		oSectFunc:Cell("RA_HRSMES" ):Disable()
	Endif

	oSectFunc:Cell("PERCADT"   ):Disable()
	oSectFunc:Cell("RA_CIC"    ):Disable()
	oSectFunc:Cell("RA_CURP"   ):Disable()
	oSectFunc:Cell("RA_RG"     ):Disable()
	oSectFunc:Cell("RA_TSIMSS" ):Disable()
	oSectFunc:Cell("RCO_NREPAT"):Disable()

	If nOrdem != 2 .AND. nOrdem != 4 .AND. nOrdem != 6 .AND. nOrdem != 8
		oSectFunc:Cell("RA_SITFOLH"):Disable()
	EndIf

	If lRaDtRec
		oSectFunc:Cell("RA_DTREC"  ):Disable()
	Endif

	If lRaFeCrei
		oSectFunc:Cell("RA_FECREI" ):Disable()
	Endif

	If lRaSalDia
		oSectFunc:Cell("RA_SALDIA" ):Disable()
	Endif

	If lRaSalInt
		oSectFunc:Cell("RA_SALINT" ):Disable()
	Endif

	If nOrdem == 1 .Or. nOrdem == 2
		oSectFunc:Cell("RA_DEPTO"):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
		oSectFunc:Cell("RA_CC"):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf

	If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6	//C.Custo
		oSectFunc:Cell("RA_DEPTO"  ):Disable()
		oSectFunc:Cell("QB_DESCRIC"):Disable()
	EndIf

	If nOrdem == 7 .Or. nOrdem == 8										//Depto.
		oSectFunc:Cell("RA_CC"     ):Disable()
		oSectFunc:Cell("CTT_DESC01"):Disable()
	EndIf
EndIf

If nOrdem == 3 .Or. nOrdem == 4
	cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0041)	//"C.Custo Cadastro"
ElseIf nOrdem == 5 .Or. nOrdem == 6
	cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0048)	//"C.Custo Movimento"
ElseIf nOrdem == 7 .Or. nOrdem == 8
	cTitulo := Alltrim(cTitulo)+" - " + OemToAnsi(STR0046)	//"Departamento"
EndIf

If ( lDifLiq .and. ( nAnaSin == 1 .And. !lSint) )
	oSectDifLiq	:= oReport:Section(7)
	DEFINE CELL NAME "DIFLIQ" 	OF oSectDifLiq TITLE "" SIZE 150
	oSectDifLiq:SetLineStyle()

   	DEFINE BREAK oBreakDifLiq OF oSectFunc   WHEN {||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT}
	DEFINE FUNCTION NAME "UDIFLIQ"    FROM oSectFunc:Cell("PROVDESC") FUNCTION ONPRINT BREAK oBreakDifLiq NO END SECTION NO END REPORT TITLE OemToAnsi(STR0053) PICTURE "@!" FORMULA {|| fCalcDifLiq(oSectLanc:GetFunction("ULIQVALOR"):GetLastValue())}

	oBreakDifLiq:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0054)})
    oBreakDifLiq:SetTotalText({||cTitFun})
    oBreakDifLiq:SetTotalInLine(.F.)
EndIf

If !lSint //AnalÌtico
	DEFINE BREAK oBreakFun OF oSectFunc   WHEN {||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT}
	DEFINE FUNCTION NAME "UTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE  iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"        	//"Ref."
	DEFINE FUNCTION NAME "UTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
	DEFINE FUNCTION NAME "UTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE  iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"  		//"Ref."
	DEFINE FUNCTION NAME "UTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "ULIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "ULIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakFun NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("UTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("UTOTVALORD"):GetLastValue()) } 	//"Liquido:"

	oBreakFun:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0037)+" "+ x /*Subs(x,3,Len(x)-2)*/})	//"Totais Funcion·rio "
	oBreakFun:SetTotalText({||cTitFun})
	oBreakFun:SetTotalInLine(.F.)
EndIf

If nOrdem == 7 .Or. nOrdem == 8		//Departamento
	If nAnaSin == 1	//AnalÌtico
		DEFINE BREAK oBreakDp  OF oSectDept WHEN  {|| ((cAliasFun)->RA_FILIAL+(cAliasFun)->QB_DEPTO) }
		oBreakDp:lPageBreak := lBrkDp

	Else			//SintÈtico
		oSectFunc:Cell("RA_DEPTO"):SetBlock({||(cAliasQry)->RA_DEPTO})
		oSectFunc:Cell("QB_DESCRIC"):SetBlock({||(cAliasQry)->QB_DESCRIC})
		cCpoQuebra	:= "RA_DEPTO"
		cCpoAls		+= ", RA_DEPTO RADEPTO"
		cCpoView	+= ", RADEPTO RA_DEPTO"
		cCpoViewG	+= ", RADEPTO"
		DEFINE BREAK oBreakDp  OF oReport WHEN  {|| oSectFunc:Cell("RA_FILIAL"):GetText() + oSectFunc:Cell("RA_DEPTO" ):GetText() } TITLE OemToAnsi(STR0047) //"Total do Departamento"
		oBreakDp:lPageBreak := lBrkDp
	EndIf

	DEFINE FUNCTION NAME "DTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE  iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"         	//"Ref."
	DEFINE FUNCTION NAME "DTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"   	//"Valor"
	DEFINE FUNCTION NAME "DTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE  iif(lGper670  .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99" 			//"Ref."
	DEFINE FUNCTION NAME "DTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "DLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "DLIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakDp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("DTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("DTOTVALORD"):GetLastValue()) } 	//"Liquido:"

	oBreakDp:OnBreak({|x,y|cTitDp:=OemToAnsi(STR0047)+" "+x})	//"Total Departamento "
	oBreakDp:SetTotalText({||cTitDp})
	oBreakDp:SetTotalInLine(.F.)

	If nAnaSin == 1
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION	NO END REPORT	//"Proventos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText()} CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakDp TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION	NO END REPORT	//"Descontos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText()} CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakDp TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"

		If lImpBase
			If cPaisLoc == "COS"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERB"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0045) PICTURE "@E 99,999.99"			NO END SECTION NO END REPORT	//"Descontos"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText()} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			Else
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakDp TITLE OemToAnsi(STR0045) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Bases"
			Endif
		EndIf
	EndIf
EndIf

If nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6		//Centro de Custo
	If nAnaSin == 1	//AnalÌtico
		DEFINE BREAK oBreakCc   OF oReport   WHEN  {||((cAliasFun)->RA_FILIAL+(IIf(nOrdem == 3 .Or. nOrdem == 4, (cAliasFun)->RA_CC, (cAliasFun)->CTT_CUSTO)))}
		DEFINE BREAK oBreakCcT  OF oReport   WHEN  {||((cAliasFun)->RA_FILIAL+(IIf(nOrdem == 3 .Or. nOrdem == 4, (cAliasFun)->RA_CC, (cAliasFun)->CTT_CUSTO)))}
		
		oBreakCcT:lPageBreak := lBrkCc
	Else			//SintÈtico
		oSectFunc:Cell("CTT_DESC01"):SetBlock({||(cAliasQry)->CTT_DESC01})
		oSectFunc:Cell("CTT_NOME"):SetBlock({||(cAliasQry)->CTT_NOME})
		oSectFunc:Cell("CTT_CEI"):SetBlock({||(cAliasQry)->CTT_CEI})
	
		If nOrdem == 3 .Or. nOrdem == 4
			oSectFunc:Cell("RA_CC"):SetBlock({||(cAliasQry)->RA_CC})
			cCpoQuebra	:= "RA_CC"
			cCpoAls		+= ", RA_CC RACC"
			cCpoView	+= ", RACC RA_CC"
			cCpoViewG	+= ", RACC"

			DEFINE BREAK oBreakCc  OF oReport WHEN  {|| ": "+oSectFunc:Cell("RA_FILIAL"):GetText() + " - "+oSectFunc:Cell("RA_CC" ):GetText() } TITLE OemToAnsi(STR0042) //"Total do CCusto
			DEFINE BREAK oBreakCcT OF oReport WHEN  {|| Left(oSectFunc:Cell("RA_FILIAL"):GetText()+Space(10),TamSX3("RA_FILIAL")[1]) +	Left(oSectFunc:Cell("RA_CC" ):GetText()+Space(10),TamSX3("RA_CC")[1])  } 
			oBreakCcT:lPageBreak := lBrkCc

		Elseif nOrdem == 5 .Or. nOrdem == 6
			oSectFunc:Cell("RA_CC"):SetBlock({||(cAliasQry)->CTT_CUSTO})
			cCpoQuebra	:= "CTT_CUSTO"
			cCCpoQuebra	:= "RC_CC"
			cCpoAlsC	:= cCpoAls + ", RC_CC CTT_CUSTO"
			cCpoViewC	+= ", CTT_CUSTO RC_CC"
			cDCpoQuebra	:= "RD_CC"
			cCpoAlsD	:= cCpoAls + ", RD_CC CTT_CUSTO"
			cCpoViewD	+= ", CTT_CUSTO RD_CC"

			DEFINE BREAK oBreakCc  OF oReport WHEN  {|| ": "+oSectFunc:Cell("RA_FILIAL"):GetText() + " - "+oSectFunc:Cell("RA_CC" ):GetText() } TITLE OemToAnsi(STR0042) //"Total do CCusto
			DEFINE BREAK oBreakCcT OF oReport WHEN  {|| Left(oSectFunc:Cell("RA_FILIAL"):GetText()+Space(10),TamSX3("RA_FILIAL")[1]) +	Left(oSectFunc:Cell("RA_CC" ):GetText()+Space(10),TamSX3("RA_CC")[1])  } 
			oBreakCcT:lPageBreak := lBrkCc
		EndIf
	EndIf

	DEFINE FUNCTION NAME "CTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakCc NO END SECTION  TITLE  iif(lGper670 .And. cRefOco == 2 ,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"         	//"Ref."
	DEFINE FUNCTION NAME "CTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakCc NO END SECTION  TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"   	//"Valor"
	DEFINE FUNCTION NAME "CTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakCc NO END SECTION  TITLE  iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99" 			//"Ref."
	DEFINE FUNCTION NAME "CTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakCc NO END SECTION  TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "CLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakCc NO END SECTION  TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "CLIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakCc NO END SECTION  TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("CTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("CTOTVALORD"):GetLastValue()) } 	//"Liquido:"

	If nAnaSin == 1

		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION	//"Proventos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText()} CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakCc TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION		//"Descontos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText()} CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakCc TITLE OemToAnsi(STR0030) PICTURE "@E 999,999,999.99"	NO END SECTION	NO END REPORT	//"Valor"

		If lImpBase
			If cPaisLoc == "COS"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERB"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0045) PICTURE "@E 99,999.99"			NO END SECTION 	//"Descontos"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText()} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			Else
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakCc TITLE OemToAnsi(STR0045) PICTURE "@E 999,999,999.99"	NO END SECTION	//"Bases"
			Endif
		EndIf
	EndIf 

	DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakCcT NO END SECTION TITLE '' PICTURE "@!"     FORMULA {|| '' } 	//"Liquido:"

	oBreakCc:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0042)+" "+x})	//"Total C.Custo"
	oBreakCc:SetTotalText({||cTitCC})
	oBreakCc:SetTotalInLine(.F.)

	oBreakCcT:OnBreak(  { |x, y| cTitEFil :=  MntTots(Iif(nAnaSin == 1 .And. !lSint,'A','S'), .F.,"C",x) } )
	oBreakCcT:SetTotalText({ || cTitEFil })
	oBreakCcT:SetTotalInLine(.F.)
EndIf

//QUEBRA FILIAL
DEFINE BREAK oBreakFil    OF oReport WHEN  oSectFunc:Cell("RA_FILIAL") TITLE OemToAnsi(STR0030) //"Total da Filial "
DEFINE BREAK oa2BreakEFil OF oReport WHEN  oSectFunc:Cell("RA_FILIAL")

//QUEBRA UNIDADE DE NEGOCIO e EMPRESA
If lCorpManage
	If lUniNeg
		If nAnaSin == 1 .And. !lSint	//AnalÌtico
			DEFINE BREAK oBreakUnN   OF oReport WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText() ,2 ) }
			DEFINE BREAK oa1BreakUnN OF oReport WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText() ,2 ) }

		Else // SintÈtico
			DEFINE BREAK oBreakUnN   OF oReport WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText(), 2 ) }
			DEFINE BREAK oa1BreakUnN OF oReport WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText(), 2 ) }
		Endif
	EndIf

	If lEmpFil
		If nAnaSin == 1 .And. !lSint	//AnalÌtico
			DEFINE BREAK oBreakEFil   OF oReport  WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText(), 1 ) }
			DEFINE BREAK oa3BreakEFil OF oReport  WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText(), 1 ) }

		Else //SintÈtico
			DEFINE BREAK oBreakEFil   OF oReport  WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText(), 1 ) }
			DEFINE BREAK oa3BreakEFil OF oReport  WHEN { || fQuebra( oSectFunc:Cell("RA_FILIAL"):GetText(), 1 ) }
		Endif
	EndIf
Else
	DEFINE BREAK oBreakEmp   OF oReport WHEN  { || "" }
	DEFINE BREAK oa3BreakEmp OF oReport WHEN  { || "" }	
EndIf

If lImpFil .Or. !lPrinOn

	DEFINE FUNCTION NAME "FTOTREFERP" FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE  iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"        	//"Ref."
	DEFINE FUNCTION NAME "FTOTVALORP" FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
	DEFINE FUNCTION NAME "FTOTREFERD" FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE  iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"  		//"Ref."
	DEFINE FUNCTION NAME "FTOTVALORD" FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
	DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
	DEFINE FUNCTION NAME "FLIQVALOR"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakFil NO END SECTION TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTOTVALORP"):GetLastValue() - oSectLanc:GetFunction("FTOTVALORD"):GetLastValue()) } 	//"Liquido:"

	If lImpFil
		oBreakFil:OnBreak({|x,y| cTitFil := OemToAnsi(STR0038) + " " + x,  oReport:ThinLine()})	//"Total Filial"
		oBreakFil:SetTotalText({||cTitFil})
		oBreakFil:SetTotalInLine(.F.)

		DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oa2BreakEFil NO END SECTION TITLE '' PICTURE "@!"     FORMULA {|| '' } 	//"Liquido:"
		oa2BreakEFil:OnBreak(  { |x, y| cTitEFil := MntTots(Iif(nAnaSin == 1 .And. !lSint,'A','S'), .F.,"F",x) } )
		oa2BreakEFil:SetTotalText({ || cTitEFil })
		oa2BreakEFil:SetTotalInLine(.F.)
		oa2BreakEFil:lPageBreak := lBrkPagFil
	EndIf

	If lCorpManage
		If !lImpEmp
			If lUniNeg .And. lImpUni
				DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oa1BreakUnN NO END SECTION TITLE '' PICTURE "@!"     FORMULA {|| '' } 	//"Liquido:"
				oa1BreakUnN:OnBreak(   { |x, y| cTitUnN := MntTots(Iif(nAnaSin == 1 .And. !lSint,'A','S'), .F.,"U",x) } )
				oa1BreakUnN:SetTotalText({ || cTitUnN })
				oa1BreakUnN:SetTotalInLine(.F.)
			Endif
		Else
		If lUniNeg
				DEFINE FUNCTION NAME "FTUNNREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"        	//"Ref."
				DEFINE FUNCTION NAME "FTUNNVALP"  FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
				DEFINE FUNCTION NAME "FTUNNREFD"  FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"  		//"Ref."
				DEFINE FUNCTION NAME "FTUNNVALD"  FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"  	//"Valor"
				DEFINE FUNCTION NAME "FLUNNDESCB" FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
				DEFINE FUNCTION NAME "FLUNNVALB"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakUnN NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTUNNVALP"):GetLastValue() - oSectLanc:GetFunction("FTUNNVALD"):GetLastValue()) } 	//"Liquido:"

				oBreakUnN:OnBreak({ |x, y| cTitUnN := OemToAnsi(STR0059) + " " + x, oReport:ThinLine() })	//"Total Unidade de Negocios:"
				oBreakUnN:SetTotalText({ || cTitUnN })
				oBreakUnN:SetTotalInLine(.F.)

				DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oa1BreakUnN NO END SECTION TITLE '' PICTURE "@!"     FORMULA {|| '' } 	//"Liquido:"
				oa1BreakUnN:OnBreak(  { |x, y| cTitUnN := MntTots(Iif(nAnaSin == 1 .And. !lSint,'A','S'), .F.,"U",x) } )
				oa1BreakUnN:SetTotalText({ || cTitUnN })
				oa1BreakUnN:SetTotalInLine(.F.)
				oa1BreakUnN:lPageBreak := lBrkPagFil
			EndIf

			If lEmpFil
				DEFINE FUNCTION NAME "FTEFLREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"        	//"Ref."
				DEFINE FUNCTION NAME "FTEFLVALP"  FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
				DEFINE FUNCTION NAME "FTEFLREFD"  FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"  		//"Ref."
				DEFINE FUNCTION NAME "FTEFLVALD"  FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99" 	//"Valor"
				DEFINE FUNCTION NAME "FLEFLDESCB" FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
				DEFINE FUNCTION NAME "FLEFLVALB"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakEFil NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTEFLVALP"):GetLastValue() - oSectLanc:GetFunction("FTEFLVALD"):GetLastValue()) } 	//"Liquido:"
			
				oBreakEFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0060) + " " + x, oReport:ThinLine() })	//"Total Empresa"
				oBreakEFil:SetTotalText({ || cTitEFil })
				oBreakEFil:SetTotalInLine(.F.)

				DEFINE FUNCTION NAME "FLIQDESC"   FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oa3BreakEFil NO END SECTION TITLE '' PICTURE "@!"     FORMULA {|| '' } 	//"Liquido:"
				oa3BreakEFil:OnBreak(  { |x, y| cTitEFil :=  MntTots(Iif(nAnaSin == 1 .And. !lSint,'A','S'), .F.,"E",x) } )
				oa3BreakEFil:SetTotalText({ || cTitEFil })
				oa3BreakEFil:SetTotalInLine(.F.)
			EndIf
		EndIf
	
	ElseIf lImpEmp
		DEFINE FUNCTION NAME "FTEFLREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"        	//"Ref."
		DEFINE FUNCTION NAME "FTEFLVALP"  FROM oSectLanc:Cell("VALORP") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	//"Valor"
		DEFINE FUNCTION NAME "FTEFLREFD"  FROM oSectLanc:Cell("REFERD") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE iif(lGper670 .And. cRefOco == 2,STR0113,OemToAnsi(STR0029)) PICTURE "@E 999,999.99"  		//"Ref."
		DEFINE FUNCTION NAME "FTEFLVALD"  FROM oSectLanc:Cell("VALORD") FUNCTION SUM     BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99" 	//"Valor"
		DEFINE FUNCTION NAME "FLEFLDESCB" FROM oSectLanc:Cell("DESCB" ) FUNCTION ONPRINT BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@!"     FORMULA {|| OemToAnsi(STR0039) } 	//"Liquido:"
		DEFINE FUNCTION NAME "FLEFLVALB"  FROM oSectLanc:Cell("VALORB") FUNCTION ONPRINT BREAK oBreakEmp NO END SECTION NO END REPORT TITLE OemToAnsi(STR0039) PICTURE "@E 99,999,999,999.99" FORMULA {|| (oSectLanc:GetFunction("FTEFLVALP"):GetLastValue() - oSectLanc:GetFunction("FTEFLVALD"):GetLastValue()) } 	//"Liquido:"
	
		oBreakEmp:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0060) + " " + x, oReport:ThinLine() })	//"Total Empresa"
		oBreakEmp:SetTotalText({ || cTitEFil })
		oBreakEmp:SetTotalInLine(.F.)

		DEFINE FUNCTION NAME "FTEFLREFP"  FROM oSectLanc:Cell("REFERP") FUNCTION ONPRINT     BREAK oa3BreakEmp  NO END SECTION NO END REPORT TITLE '' PICTURE "@!"    FORMULA {|| '' }
		oa3BreakEmp:OnBreak({ |x,y| cTitEFil := MntTots(Iif(nAnaSin == 1 .And. !lSint,'A','S'), .T.,"E",x)})
		oa3BreakEmp:SetTotalText({ || cTitEFil })
		oa3BreakEmp:SetTotalInLine(.F.)
	EndIf

	//Imprime a Collection apenas se solicitado Total por Filial
	If lImpFil
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
		DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"

		If lImpBase
			If cPaisLoc == "COS"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERB"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0045) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText()} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)}	BREAK oBreakFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			Else
				DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakFil TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
			EndIf
		EndIf
	EndIf

	If lCorpManage 
		//Imprime a Collection apenas se solicitado Total por Unidade de Negocio
		If lImpUni .And. lUniNeg
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakUnN TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"


			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"

			If lImpBase
				If cPaisLoc == "COS"
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERB"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0045) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText()} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)}	BREAK oBreakUnN TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
				Else
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakUnN TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
				Endif
			EndIf
		EndIf

		//Imprime a Collection apenas se solicitado Total por Empresa
		If lImpEmp .And. lEmpFil
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakEFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"

			If lImpBase
				If cPaisLoc == "COS"
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERB"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0045) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM   FORMULA {|| oSectLanc:Cell("PDB"):GetText()} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)}	BREAK oBreakEFil TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
				Else
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakEFil TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
				Endif
			EndIf
		EndIf
		Else
		If lImpEmp
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDP"):GetText() + " " + oSectLanc:Cell("DESCP"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERP"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0043) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Proventos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDP"):GetText() } CONTENT {|| oSectLanc:Cell("VALORP"):GetValue(.T.)} BREAK oBreakEmp TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDD"):GetText() + " " + oSectLanc:Cell("DESCD"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERD"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0044) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
			DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDD"):GetText() } CONTENT {|| oSectLanc:Cell("VALORD"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"

			If lImpBase
				If cPaisLoc == "COS"
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("REFERB"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0045) PICTURE "@E 999,999.99"			NO END SECTION NO END REPORT	//"Descontos"
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText()} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)}	BREAK oBreakEmp TITLE OemToAnsi(STR0030) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Valor"
				Else
					DEFINE COLLECTION OF oSectLanc FUNCTION SUM FORMULA {|| oSectLanc:Cell("PDB"):GetText() + " " + oSectLanc:Cell("DESCB"):GetValue(.T.)} CONTENT {|| oSectLanc:Cell("VALORB"):GetValue(.T.)} BREAK oBreakEmp TITLE OemToAnsi(STR0045) PICTURE "@E 99,999,999,999.99"	NO END SECTION NO END REPORT	//"Bases"
				Endif
			EndIf
		EndIf
	EndIf
Endif

cSitQuery	:= ""
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += ","
	Endif
Next nReg

cCatQuery	:= ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += ","
	Endif
Next nReg

If cPaisLoc == "MEX" .And. !lGper670
	If !Empty(nTpContr)
		cTpcQuery := "'" + cValToChar(nTpContr) + "'"
	Else
		cTpcQuery := fGetExpTpC() + "' ' "
	EndIf
Else
	If nTpContr == 3 .AND. !lDicInter
		cTpcQuery	:= "'1', '2', ' ' "
	elseIf nTpContr == 4 .AND. lDicInter
		cTpcQuery	:= "'1', '2', '3', ' ' "
	Else
		cTpcQuery	:= "'" + cValToChar(nTpContr) + "'"
	EndIf
EndIf

//ALTERA O TITULO DO RELATORIO
oReport:SetTitle(cTitulo)

If !lGper670
	MakeSqlExpr(cPerg)
	//Permiss„o Filial
	cFiltro += fAjustFil(.F.) //Retorna no filtro somente as filiais que o usu·rio tem acesso
Else
	cFiltro += fAjustFil(.T.) //Retorna no filtro somente as filiais que o usu·rio tem acesso
	cFiltro	+= " AND RA_MAT BETWEEN '" + MV_PAR06 + "' and '" + MV_PAR07 + "'  "
	cFiltro	+= " AND RA_NOME BETWEEN '" + MV_PAR08 + "' and '" + MV_PAR09 + "'  "
	cFiltro	+= " AND RA_CC BETWEEN '" + MV_PAR04 + "' and '" + MV_PAR05 + "'  "
EndIf

If nAnaSin == 1		//Analitico
	If nOrdem == 1
		cOrdemFun := "%RA_FILIAL,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 2
		cOrdemFun := "%RA_FILIAL,RA_NOME,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_NOME,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 3
		cOrdemFun := "%RA_FILIAL,RA_CC,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_CC,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 4
		cOrdemFun := "%RA_FILIAL,RA_CC,RA_NOME,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_CC,RA_NOME,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 5
		cOrdemFun := "%FILIAL,CCUSTO,RA_MAT%"
		cOrdemLan := "%FILIAL,CCUSTO,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 6
		cOrdemFun := "%FILIAL,CCUSTO,RA_NOME,RA_MAT%"
		cOrdemLan := "%FILIAL,CCUSTO,RA_NOME,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 7
		cOrdemFun := "%RA_FILIAL,RA_DEPTO,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_DEPTO,RA_MAT,PD,SEQ%"
	ElseIf nOrdem == 8
		cOrdemFun := "%RA_FILIAL,RA_DEPTO,RA_NOME,RA_MAT%"
		cOrdemLan := "%RA_FILIAL,RA_DEPTO,RA_NOME,RA_MAT,PD,SEQ%"
	Endif
EndIf

cSitQuery	:= "%" + cSitQuery + "%"
cCatQuery	:= "%" + cCatQuery + "%"
cTpcQuery	:= "%" + cTpcQuery + "%"

If !lGper670
	//CENTRO DE CUSTO
	If !Empty(mv_par06)
		If nAnaSin == 1
			cFiltro += Iif(!Empty(cFiltro)," AND ","")
			cFiltro += mv_par06
		Else
			If nOrdem != 5 .And. nOrdem != 6
				cFiltro += Iif(!Empty(cFiltro)," AND ","")
				cFiltro += mv_par06
			EndIf
		EndIf
	EndIf

	//DEPARTAMENTO
	If !Empty(mv_par07)
		cFiltro += Iif(!Empty(cFiltro)," AND ","")
		cFiltro += mv_par07
	EndIf

	//MATRICULA
	If !Empty(mv_par08)
		cFiltro += Iif(!Empty(cFiltro)," AND ","")
		cFiltro	+= mv_par08
	EndIf

	//NOME
	If !Empty(mv_par09)
		cFiltro += Iif(!Empty(cFiltro)," AND ","")
		cFiltro += mv_par09
	EndIf
EndIf

cUserFiltro := ""
cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "SRA",.T.)), oSectFunc:GetUserExp( "SRA",.T.) , "")
cUserFiltro += IIF (!EMPTY(oSectFunc:GetUserExp( "CTT",.T.)), oSectFunc:GetUserExp( "CTT",.T.) , "")
If nOrdem == 3 .Or.  nOrdem == 4 .Or.  nOrdem == 5 .Or.  nOrdem == 6
	cUserFiltro += IIF (!EMPTY(oSectCttc:GetUserExp( "CTT",.T.)), oSectCttc:GetUserExp( "CTT",.T.) , "")
EndIf
cFiltro += Iif(!Empty(cUserFiltro)," AND ( " + cUserFiltro + " ) ","")

If !Empty(cFiltro)
	If nOrdem == 5 .Or. nOrdem == 6
		cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+StrTran( cFiltro, "RA_CC", "RC_CC" ),StrTran( cFiltro, "RA_CC", "RC_CC" ))
		cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+StrTran( cFiltro, "RA_CC", "RD_CC" ),StrTran( cFiltro, "RA_CC", "RD_CC" ))
	Else
		cFiltroC	+= Iif(!Empty(cFiltroC)," AND "+cFiltro,cFiltro)
		cFiltroD	+= Iif(!Empty(cFiltroD)," AND "+cFiltro,cFiltro)	
	EndIf
	cFiltro		:= Iif(!Empty(cFiltro ),cFiltro,"")
EndIf

//SUPER FILTRO
If !Empty(cSFiltrSQL) .AND. cSFiltrSQL != ".T."
	cFiltroC += Iif(!Empty(cFiltroC), " AND "+cSFiltrSQL, cSFiltrSQL)
	cFiltroD += Iif(!Empty(cFiltroD), " AND "+cSFiltrSQL, cSFiltrSQL)
	cFiltro  += Iif(!Empty(cFiltro), " AND "+cSFiltrSQL, cSFiltrSQL)
EndIf

SRA->( dbCloseArea() ) //FECHA O SRA PARA USO DA QUERY

If nAnaSin == 1 	//Analitico

	If !( TcGetDb() == "INFORMIX" )
		cCoalese := "% AND COALESCE(SQB.D_E_L_E_T_,'') = ' '"
		cCoalese += "%"
	Else
		cCoalese := "% AND DECODE(SQB.D_E_L_E_T_,NULL,'','') = ' '"
		cCoalese += "%"
	EndIf

	If nOrdem == 3 .Or. nOrdem == 5 .Or. nOrdem == 7
		cTitulo := Alltrim(cTitulo)+" + " + OemToAnsi(STR0002)	//MatrÌcula
	ElseIf nOrdem == 4 .Or. nOrdem == 6
		cTitulo := Alltrim(cTitulo)+" + " + OemToAnsi(STR0003)	//Nome
	EndIf

	Sx2ChkModo( "CTT", NIL, .F., @cMod1, NIL )
	cJoin := " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND SRA.RA_CC = CTT.CTT_CUSTO AND " + fGR106join("SRA", "CTT")

	If nOrdem == 5 .Or. nOrdem = 6
		cCpoCcRc		:= "  SRC.RC_CC CCUSTO "
		cCpoCcRd		:= "  SRD.RD_CC CCUSTO "
	EndIf

	If nOrdem == 1 .Or. nOrdem == 2
		cCpoAdicLan	:= " CTT.CTT_DESC01 "
		cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectFunc
	ElseIf nOrdem == 3 .Or. nOrdem == 4
		cCpoAdicLan	:= " CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_NOME, CTT.CTT_CEI "
		cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		cCpoAdicLan	:= " CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01, CTT.CTT_NOME, CTT.CTT_CEI "
		cJoinC		:= " INNER JOIN " + RetSqlName("CTT") + " CTT ON SRC.RC_CC = CTT.CTT_CUSTO AND " + fGR106join("SRC", "CTT")
		cJoinD 		:= " INNER JOIN " + RetSqlName("CTT") + " CTT ON SRD.RD_CC = CTT.CTT_CUSTO AND " + fGR106join("SRD", "CTT")
		cJoin 		:= "%%"
		cNotDel	:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		cCpoAdicLan	:= " SQB.QB_FILIAL, SQB.QB_DEPTO, CTT.CTT_DESC01 "
		cNotDel		:= "% AND CTT.D_E_L_E_T_= ' ' %"
		BEGIN REPORT QUERY oSectDept
	EndIf

	If nOrdem == 7 .Or. nOrdem == 8
		cJoinSQB := " INNER JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR106join("SRA", "SQB")
	Else
		cJoinSQB := " LEFT JOIN " + RetSqlName("SQB") + " SQB ON SRA.RA_DEPTO = SQB.QB_DEPTO AND " + fGR106join("SRA", "SQB")
	EndIf

	cJoinC		:= Iif(Empty(cJoinC),cJoin,cJoinC)
	cJoinD		:= Iif(Empty(cJoinD),cJoin,cJoinD)
	cJoinD		:= strTran(cJoinD, "SRC", "SRD")
	cJoinD		:= strTran(cJoinD, "RC_", "RD_")

	cFiltroC	:= Iif(Empty(cFiltroC),"%%","% AND "+cFiltroC+"%")
	cFiltroD	:= Iif(Empty(cFiltroD),"%%","% AND "+cFiltroD+"%")
	cFiltro		:= Iif(Empty(cFiltro ),"%%","% AND "+cFiltro +"%")

	cCpoCcRc	:= If( !Empty(cCpoCcRc), "% , " + cCpoCcRc + ", ", "% , " ) + cCpoAdicLan + " %"
	cCpoCcRd	:= If( !Empty(cCpoCcRd), "% , " + cCpoCcRd + ", ", "% , " ) + cCpoAdicLan + " %"

	If lDepSf
		cDepenContr	:= "% SRA.RA_DEPIR, SRA.RA_DEPSF %"
	Else
		cDepenContr	:= "% SRA.RA_DEPIR %"
	EndIf

	If cPaisLoc == "MEX"
		cCpoAdicEsp := "% SRA.RA_DTREC, SRA.RA_FECREI, SRA.RA_CODRPAT, SRA.RA_CURP, SRA.RA_TSIMSS, SRA.RA_SALDIA, SRA.RA_SALINT, RCO.RCO_NREPAT %"
		cJoinEsp   := " INNER JOIN " + RetSqlName("RCO") + " RCO ON SRA.RA_CODRPAT = RCO.RCO_CODIGO AND " + fGR106join("SRA", "RCO")
		cNotDel	:= SUBSTR(cNotDel, 1, len(cNotDel)-1 ) + " AND RCO.D_E_L_E_T_= ' ' %"
	ElseIf cPaisLoc == "COS"
		cCpoAdicEsp := "% SRA.RA_CODRPAT, RCO.RCO_NREPAT, RCO.RCO_POLRT %"
		cJoinEsp	:= " INNER JOIN " + RetSqlName("RCO") + " RCO ON SRA.RA_CODRPAT = RCO.RCO_CODIGO AND " + fGR106join("SRA", "RCO")
		cNotDel	:= SUBSTR(cNotDel, 1, len(cNotDel)-1 ) + " AND RCO.D_E_L_E_T_= ' ' %"
	ElseIf cPaisLoc == "COL"
			cCpoAdicEsp := "% SRA.RA_RG,SRA.RA_TIPOSAL, SRA.RA_MOEDAPG,SRA.RA_REMVAR,SRA.RA_GROSSUP,SRA.RA_SALEST,RA_TIPOPRC %"
	Else
		cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
	Endif

	cJoinSRC := " INNER JOIN " + RetSqlName("SRC") + " SRC ON SRA.RA_FILIAL = SRC.RC_FILIAL AND SRA.RA_MAT = SRC.RC_MAT "
	cJoinSRD := " INNER JOIN " + RetSqlName("SRD") + " SRD ON SRA.RA_FILIAL = SRD.RD_FILIAL AND SRA.RA_MAT = SRD.RD_MAT "

	cJoin1 := "% " + cJoinSRC + cJoinEsp + cJoinSQB + cJoinC + "%"
	cJoin2 := "% " + cJoinSRD + cJoinEsp + cJoinSQB + cJoinD + "%"

	If cPagamento # '99'
		cWhereSRC := "% SRC.RC_SEMANA = '"+ cPagamento + "' AND %"
		cWhereSRD := "% SRD.RD_SEMANA = '"+ cPagamento + "' AND "
	Else
		cWhereSRC := "% SRC.RC_SEMANA <> '"+ cPagamento + "' AND %"
		cWhereSRD := "% SRD.RD_SEMANA <> '"+ cPagamento + "' AND "
	EndIf

	If lGper040
		cWhereSRD += " SRD.RD_EMPRESA = '  ' AND "
	Else
		cWhereSRD += " (SRD.RD_EMPRESA = '" + Upper(cEmpAnt) + "' OR SRD.RD_EMPRESA = '  ' ) AND "
	EndIf
	cWhereSRD += "%"

	//QUERY cAliasFun
		BeginSql alias cAliasFun

			SELECT SRA.RA_FILIAL,		SRA.RA_MAT,			SRA.RA_NOME,	SRA.RA_CC,
					SRA.RA_DEPTO,		SRA.RA_HRSMES,		SRA.RA_SALARIO,	SRA.RA_SITFOLH,
					SRA.RA_CATFUNC,		SRA.RA_PERCADT,		SRA.RA_ADMISSA,	%exp:cDepenContr%,
					SRA.RA_CIC,			SRA.RA_RG,	 		%exp:cCpoAdicEsp%,
					SRC.RC_FILIAL FILIAL	%exp:cCpoCcRc%, SQB.QB_DESCRIC, SRA.RA_TPCONTR
			FROM %table:SRA% SRA
			%exp:cJoin1%
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND
			   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND
			   		%exp:cWhereSRC%
					SRA.%notDel% %exp:cFiltroC% AND SRC.%notDel% %exp:cNotDel% AND SRC.%notDel% %exp:cCoalese%
			UNION

			SELECT SRA.RA_FILIAL,			SRA.RA_MAT,			SRA.RA_NOME,	SRA.RA_CC,
					SRA.RA_DEPTO,			SRA.RA_HRSMES,		SRA.RA_SALARIO,	SRA.RA_SITFOLH,
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,		SRA.RA_ADMISSA,	%exp:cDepenContr%,
					SRA.RA_CIC,				SRA.RA_RG, 			%exp:cCpoAdicEsp%,
					SRD.RD_FILIAL FILIAL	%exp:cCpoCcRd%,		SQB.QB_DESCRIC,	SRA.RA_TPCONTR
			FROM %table:SRA% SRA
			%exp:cJoin2%
			WHERE	SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND
			   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND
					SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND
			   		%exp:cWhereSRD%
					SRA.%notDel% %exp:cFiltroD% AND SRD.%notDel% %exp:cNotDel% AND SRD.%notDel% %exp:cCoalese%
			ORDER BY %exp:cOrdemFun%

		EndSql
	//END QUERY cAliasFun


	If nOrdem == 1 .Or. nOrdem == 2
		END REPORT QUERY oSectFunc
	ElseIf nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6
		END REPORT QUERY oSectCttc
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		END REPORT QUERY oSectDept
	EndIf

	ApuraSit(cCpoDelim, cCpoViewG, cGroupED, cJoinAux, cFiltro, cPagamento, cRoteiro, cPeriodo, cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD, cExtraD , cGroupEC, "%"+cJoinC+"%", "%"+cJoinD+"%", ;
             cCpoAlsC, cExtraC,  cCpoView , cCpoAdView ,lGper670)

	cCpoAdicLan := "% , " +  cCpoAdicLan + " %"

	If cPaisLoc == "MEX"
		cCpoAdicEsp := "% SRA.RA_DTREC, SRA.RA_FECREI, SRA.RA_CODRPAT %"
		cJoinEsp:= " INNER JOIN " + RetSqlName("RCO") + " RCO ON SRA.RA_CODRPAT IN ( RCO.RCO_CODIGO, ' ' )  "
	ElseIf cPaisLoc == "COS"
		cCpoAdicEsp := "% SRA.RA_CODRPAT, RCO.RCO_POLRT %"
		cJoinEsp:= " INNER JOIN " + RetSqlName("RCO") + " RCO ON SRA.RA_CODRPAT IN ( RCO.RCO_CODIGO, ' ' )  "
	Else
		cCpoAdicEsp := "%SRA.RA_FILIAL as CpoVisual%" // SE NAO FOR UM DOS PAISES MENCIONADOS ATRIBUI O CAMPO RA_FILIAL COM UM ALIAS PARA NAO FICAR VAZIO
		cJoinEsp := ""
	Endif

	cJoin3 := "% " + FWJoinFilial("SRV", "SRA") + cJoinEsp + cJoinSQB + cJoinC + "%"
	cJoin4 := "% " + FWJoinFilial("SRV", "SRA") + cJoinEsp + cJoinSQB + cJoinD + "%"


	BEGIN REPORT QUERY oSectLanc
		BeginSql alias cAliasQry

			SELECT	SRA.RA_FILIAL,          SRA.RA_MAT,           SRA.RA_CC,              SRA.RA_NOME,
					SRA.RA_DEPTO,           SRA.RA_HRSMES,        SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,       %exp:cCpoAdicEsp%,
					SRC.RC_FILIAL FILIAL,   SRC.RC_MAT MAT,       SRC.RC_CC CCUSTO,       SRC.RC_PD PD,
					SRC.RC_TIPO1 TIPO1,     SRC.RC_QTDSEM QTDSEM, SRC.RC_HORINFO HORINFO, SRC.RC_HORAS HORAS,
					SRC.RC_VALINFO VALINFO, SRC.RC_VALOR VALOR,   SRC.RC_VNAOAPL VNAOAPL, SRC.RC_DATA DATPGT,
					SRC.RC_DTREF DTREF,     SRC.RC_SEMANA SEMANA, SRC.RC_PARCELA PARCELA, SRC.RC_TIPO2 TIPO2,
					SRC.RC_SEQ SEQ,         SRC.RC_PROCES PROCES, SRC.RC_PERIODO PERIODO, SRC.RC_POSTO POSTO,
					SRC.RC_NUMID NUMID,     SRC.RC_ROTEIR ROTEIR, SRV.RV_TIPOCOD, SRV.RV_TIPO, SRV.RV_DESC, SRV.RV_IMPRIPD
					%exp:cCpoAdicLan%, SRA.RA_TPCONTR,SRV.RV_INSS AS INSS, SRV.RV_FGTS AS FGTS, SRV.RV_IR AS IR
			FROM %table:SRA% SRA    INNER JOIN      %table:SRC% SRC
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT
			INNER JOIN 	%table:SRV% SRV
			ON		SRV.RV_COD    = SRC.RC_PD AND

			%exp:cJoin3%
			WHERE	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRC.RC_PROCES  =   %exp:Upper(cProcesso)%  AND
			   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND
			   		SRC.RC_ROTEIR  =   %exp:Upper(cRoteiro)%   AND
			   		%exp:cWhereSRC%
					SRA.%notDel% %exp:cFiltroC% AND SRV.%notDel% %exp:cNotDel% AND SRC.%notDel% %exp:cCoalese%
			UNION ALL

			SELECT SRA.RA_FILIAL,          SRA.RA_MAT,           SRA.RA_CC,              SRA.RA_NOME,
					SRA.RA_DEPTO,           SRA.RA_HRSMES,        SRA.RA_SALARIO,         SRA.RA_SITFOLH,
					SRA.RA_CATFUNC,			SRA.RA_PERCADT,	      %exp:cCpoAdicEsp%,
					SRD.RD_FILIAL FILIAL,   SRD.RD_MAT MAT,       SRD.RD_CC CCUSTO,       SRD.RD_PD PD,
					SRD.RD_TIPO1 TIPO1,     SRD.RD_QTDSEM QTDSEM, SRD.RD_HORINFO HORINFO, SRD.RD_HORAS HORAS,
					SRD.RD_VALINFO VALINFO, SRD.RD_VALOR VALOR,   SRD.RD_VNAOAPL VNAOAPL, SRD.RD_DATPGT DATPGT,
					SRD.RD_DTREF DTREF,     SRD.RD_SEMANA SEMANA, 0 PARCELA,              SRD.RD_TIPO2 TIPO2,
					SRD.RD_SEQ SEQ,         SRD.RD_PROCES PROCES, SRD.RD_PERIODO PERIODO, SRD.RD_POSTO POSTO,
					SRD.RD_NUMID NUMID,     SRD.RD_ROTEIR ROTEIR, SRV.RV_TIPOCOD, SRV.RV_TIPO, SRV.RV_DESC, SRV.RV_IMPRIPD
					%exp:cCpoAdicLan%, SRA.RA_TPCONTR,SRV.RV_INSS AS INSS, SRV.RV_FGTS AS FGTS, SRV.RV_IR AS IR
			FROM %table:SRA% SRA    INNER JOIN      %table:SRD% SRD
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT
			INNER JOIN 	%table:SRV% SRV
			ON		SRV.RV_COD    = SRD.RD_PD AND

			%exp:cJoin4%
			WHERE	SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			   		SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
			   		SRD.RD_PROCES  =   %exp:Upper(cProcesso)%  AND
			   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND
			   		SRD.RD_ROTEIR  =   %exp:Upper(cRoteiro)%   AND
			   		%exp:cWhereSRD%
					SRA.%notDel% %exp:cFiltroD% AND SRV.%notDel% %exp:cNotDel% AND SRD.%notDel% %exp:cCoalese%
			ORDER BY %exp:cOrdemLan%
		ENDSQL

	END REPORT QUERY oSectLanc
	If nOrdem == 1 .Or. nOrdem == 2
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT == cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})
	ElseIf nOrdem == 3 .Or. nOrdem == 4
		If cMod1 == "E"
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_CC==cParam},{||(cAliasQry)->CTT_FILIAL+(cAliasQry)->RA_CC})
		Else
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->RA_CC==cParam},{||(cAliasQry)->RA_CC})
		EndIf
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT == cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		If cMod1 == "E"
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->FILIAL+(cAliasFun)->CCUSTO==cParam},{||(cAliasQry)->CTT_FILIAL+(cAliasQry)->CTT_CUSTO})
		Else
			//C.CUSTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->CCUSTO==cParam},{||(cAliasQry)->CTT_CUSTO})
		EndIf
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT+(cAliasQry)->CTT_CUSTO == cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT+(cAliasFun)->CCUSTO})
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		Sx2ChkModo( "SQB", NIL, .F., @cMod1, NIL )
		If cMod1 == "E"
			//DEPTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->FILIAL+(cAliasFun)->RA_DEPTO==cParam},{||(cAliasQry)->QB_FILIAL+(cAliasQry)->QB_DEPTO})
		Else
			//DEPTO X MATRICULA
			oSectFunc:SetParentFilter({|cParam|(cAliasFun)->FILIAL+(cAliasFun)->RA_DEPTO==cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->QB_DEPTO})
		EndIf
		//MATRICULA X LANCAMENTOS
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->MAT==cParam},{||(cAliasFun)->RA_FILIAL+(cAliasFun)->RA_MAT})
	EndIf

Else	//SINTETICO
	cCpoDelim	:= "%RA_FILIAL"
	cCpoDelimC	:= Iif(!Empty(cCCpoQuebra),							;
						cCpoDelim+","+AllTrim(cCCpoQuebra)+"%",		;
						Iif(!Empty(cCpoQuebra ),					;
							cCpoDelim+","+AllTrim(cCpoQuebra)+"%",	;
							cCpoDelim+"%"							;
							)										;
						)

	cCpoDelimD	:= Iif(!Empty(cDCpoQuebra),							;
						cCpoDelim+","+AllTrim(cDCpoQuebra)+"%",		;
						Iif(!Empty(cCpoQuebra ),					;
							cCpoDelim+","+AllTrim(cCpoQuebra)+"%",	;
							cCpoDelim+"%"							;
							)										;
						)

	cCpoDelim	+= Iif(!Empty(cCpoQuebra ),","+AllTrim(cCpoQuebra)+"%","%")
	cCpoView	+= "%"
	cCpoViewG	+= "%"
	cCpoAls	+= "%"

	cFiltro	:= Iif(Empty(cFiltro ),"%%","% AND "+cFiltro +"%")
	cCpoAlsC	:= Iif(Empty(cCpoAlsC),cCpoAls,cCpoAlsC+"%")
	cCpoAlsD	:= Iif(Empty(cCpoAlsD),cCpoAls,cCpoAlsD+"%")

	cJoinC		:= "% AND SRA.RA_MAT = SRC.RC_MAT " +;
	         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR106join("CTT", "SRC") + " AND CTT.CTT_CUSTO = SRC.RC_CC %"
	cJoinD		:= "% AND SRA.RA_MAT = SRD.RD_MAT" +;
	         " INNER JOIN " + RetSqlName("CTT") + " CTT ON CTT.D_E_L_E_T_ = ' ' AND " + fGR106join("CTT", "SRD") + " AND CTT.CTT_CUSTO = SRD.RD_CC %"

	Sx2ChkModo( "CTT", NIL, .F., @cMod1, NIL )

	If lGper670
		If !empty(cListProc)
			cWhereSRC := "% SRC.RC_PROCES IN  (" + cListProc + ") AND "
			cWhereSRD := "% SRD.RD_PROCES IN  (" + cListProc + ") AND "
		EndIf
		If !empty(cListRot)
			If Empty(cListProc)
				cWhereSRC := "%"
				cWhereSRD := "%"
			EndIf
			cWhereSRC += " SRC.RC_ROTEIR IN  (" + cListRot + ") AND "
			cWhereSRD += " SRD.RD_ROTEIR IN  (" + cListRot + ") AND "
		ElseIf Empty(cListProc)
			cWhereSRC := "%"
			cWhereSRD := "%"
		EndIf
	Else
		cWhereSRC := "% SRC.RC_PROCES =  '" + cProcesso + "' AND "
		cWhereSRC += " SRC.RC_ROTEIR =  '" + cRoteiro + "' AND "

		cWhereSRD := "% SRD.RD_PROCES =  '" + cProcesso + "' AND "
		cWhereSRD += " SRD.RD_ROTEIR =  '" + cRoteiro + "' AND "
		If !Empty(mv_par06)
			If nOrdem == 5 .Or. nOrdem == 6
				cWhereSRC += StrTran(mv_par06,"RA_CC","SRC.RC_CC")
				cWhereSRC += " AND "

				cWhereSRD += StrTran(mv_par06,"RA_CC","SRD.RD_CC")
				cWhereSRD += " AND "
			EndIf
		EndIf
	EndIf

	If cPagamento == "99".and. cUltSem > "01"
		cWhereSRC	+= " ( SRC.RC_PD <> '" + fGetCodFol("106") + "' OR SRC.RC_SEMANA = '01' ) AND "
		cWhereSRC	+= " ( SRC.RC_PD <> '" + fGetCodFol("015") + "' OR SRC.RC_SEMANA = '" + cUltSem + "' ) AND "
		cWhereSRD	+= " ( SRD.RD_PD <> '" + fGetCodFol("106") + "' OR SRD.RD_SEMANA = '01' ) AND "
		cWhereSRD	+= " ( SRD.RD_PD <> '" + fGetCodFol("015") + "' OR SRD.RD_SEMANA = '" + cUltSem + "' ) AND "
	EndIf

	If cPagamento # '99'
		cWhereSRC += " SRC.RC_SEMANA = '"+ cPagamento + "' AND "
		cWhereSRD += " SRD.RD_SEMANA = '"+ cPagamento + "' AND "
	Else
		cWhereSRC += " SRC.RC_SEMANA <> '"+ cPagamento + "' AND "
		cWhereSRD += " SRD.RD_SEMANA <> '"+ cPagamento + "' AND "
	EndIf

	If lGper040
		cWhereSRD += " SRD.RD_EMPRESA = '  ' AND "
	Else
		cWhereSRD += " (SRD.RD_EMPRESA = '" + Upper(cEmpAnt) + "' OR SRD.RD_EMPRESA = '  ' ) AND "
	EndIf

	cWhereSRC += "%"
	cWhereSRD += "%"

	If nOrdem == 1 .Or. nOrdem == 2
		cJoinView	:= "%%"
		cCpoAdView	:= "%%"
		cExtraC		:= "%%"
		cExtraD		:= "%%"
		cGroupEC	:= "%%"
		cGroupED	:= "%%"

		cJoinAux := "% " + FWJoinFilial("SRV", "SRC") + StrTran(cJoinView,"%","") + " %"
		cJoinAux := StrTran(cJoinAux,"SRV.RV_FILIAL","RV_FILIAL")
		cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
		cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		ApuraSit(cCpoDelim, cCpoViewG, cGroupED, cJoinAux, cFiltro, cPagamento, cRoteiro, cPeriodo, cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD, cExtraD , cGroupEC, cJoinC, cJoinD, ;
             cCpoAlsC, cExtraC,  cCpoView , cCpoAdView ,lGper670)

		BEGIN REPORT QUERY oSectFunc
	ElseIf nOrdem == 3 .Or. nOrdem == 4

		cExtraC		:= "% , SRA.RA_CC RCCC %"
		cExtraD		:= "% , SRA.RA_CC RDCC %"
		cGroupEC	:= "% , RA_CC %"
		cGroupED	:= "% , RA_CC %"

		cJoinAux := FWJoinFilial("CTT", "SRC")
    	cJoinAux := StrTran(cJoinAux,"CTT.CTT_FILIAL","CTT_FILIAL")
    	cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
    	cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		cJoinView	:= "% INNER JOIN " + RetSqlName("CTT") + " CTTA ON CTTA.CTT_CUSTO = tView.RACC AND (" + cJoinAux + ") WHERE CTTA.D_E_L_E_T_ = ' ' %"
		cCpoAdView	:= "% CTTA.CTT_DESC01, CTTA.CTT_NOME, CTTA.CTT_CEI, %"

		cJoinAux := "% " + FWJoinFilial("SRV", "SRC") + StrTran(cJoinView,"%","") + " %"
		cJoinAux := StrTran(cJoinAux,"SRV.RV_FILIAL","RV_FILIAL")
		cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
		cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		ApuraSit(cCpoDelim, cCpoViewG, cGroupED, cJoinAux, cFiltro, cPagamento, cRoteiro, cPeriodo, cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD, cExtraD , cGroupEC, cJoinC, cJoinD, ;
             cCpoAlsC, cExtraC,  cCpoView , cCpoAdView ,lGper670)

		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		cExtraC		:= "% , SRC.RC_CC RCCC %"
		cExtraD		:= "% , SRD.RD_CC RDCC %"
		cGroupEC	:= "% , RC_CC %"
		cGroupED	:= "% , RD_CC %"

		cJoinAux := FWJoinFilial("CTT", "SRC")
		cJoinAux := StrTran(cJoinAux,"CTT.CTT_FILIAL","CTT_FILIAL")
		cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
		cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		If cMod1 == "E"
			cJoinView	:= "% INNER JOIN " + RetSqlName("CTT") + " CTTA ON CTTA.CTT_CUSTO = tView.CTT_CUSTO AND CTTA.CTT_FILIAL = tView.RAFILIAL WHERE CTTA.D_E_L_E_T_ = ' ' %"
		Else
			cJoinView	:= "% INNER JOIN " + RetSqlName("CTT") + " CTTA ON CTTA.CTT_CUSTO = tView.CTT_CUSTO AND (" + cJoinAux + ") WHERE CTTA.D_E_L_E_T_ = ' ' %"
		Endif
		cCpoAdView	:= "% CTTA.CTT_DESC01, CTTA.CTT_NOME, CTTA.CTT_CEI, tView.CTT_CUSTO, %"

		cJoinAux := "% " + FWJoinFilial("SRV", "SRC") + StrTran(cJoinView,"%","") + " %"
		cJoinAux := StrTran(cJoinAux,"SRV.RV_FILIAL","RV_FILIAL")
		cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
		cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		ApuraSit(cCpoDelim, cCpoViewG, cGroupED, cJoinAux, cFiltro, cPagamento, cRoteiro, cPeriodo, cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD, cExtraD , cGroupEC, cJoinC, cJoinD, ;
             cCpoAlsC, cExtraC,  cCpoView , cCpoAdView ,lGper670)

		BEGIN REPORT QUERY oSectCttc
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		cJoinAux := FWJoinFilial("SQB", "SRC")
		cJoinAux := StrTran(cJoinAux,"SQB.QB_FILIAL","QB_FILIAL")
		cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
		cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		cJoinView	:= "% INNER JOIN " + RetSqlName("SQB") + " SQBA ON (" + cJoinAux + ") AND SQBA.QB_DEPTO = tView.RADEPTO %"
		cCpoAdView	:= "% SQBA.QB_DESCRIC, %"
		cExtraC		:= "%%"
		cExtraD		:= "%%"
		cGroupEC	:= "%%"
		cGroupED	:= "%%"

		cJoinAux := "% " + FWJoinFilial("SRV", "SRC") + StrTran(cJoinView,"%","") + " %"
		cJoinAux := StrTran(cJoinAux,"SRV.RV_FILIAL","RV_FILIAL")
		cJoinAux := StrTran(cJoinAux,"SRC.RC_FILIAL","tView.FILIAL")
		cJoinAux := StrTran(cJoinAux,"RC_FILIAL","tView.FILIAL")

		ApuraSit(cCpoDelim, cCpoViewG, cGroupED, cJoinAux, cFiltro, cPagamento, cRoteiro, cPeriodo, cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD, cExtraD , cGroupEC, cJoinC, cJoinD, ;
             cCpoAlsC, cExtraC,  cCpoView , cCpoAdView ,lGper670)

		BEGIN REPORT QUERY oSectDept
	EndIf

   //BEGIN QUERY cAliasQry
	BeginSql alias cAliasQry

		SELECT	tView.SALARIO, tView.PD, tView.QTDSEM,    tView.HORAS,  tView.VALOR,     tView.PROCES,
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, SRVA.RV_TIPO, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoView%, tView.OCORR
		FROM
		(
			SELECT 	SUM(SRA.RA_SALARIO) SALARIO, SRC.RC_PD PD, SUM(SRC.RC_QTDSEM) QTDSEM, SUM(SRC.RC_HORAS) HORAS,
					SUM(SRC.RC_VALOR) VALOR,     SRC.RC_PROCES PROCES, SRC.RC_PERIODO PERIODO,
					SRC.RC_ROTEIR ROTEIR,        SRC.RC_FILIAL FILIAL	%exp:cExtraC%,
					SRA.%exp:cCpoAlsC%,
					count(SRC.rC_PD) OCORR
			FROM  %table:SRA% SRA
			INNER JOIN %table:SRC% SRC
			ON 		SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
			WHERE 	SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) AND
					SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
					SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND
					%exp:cWhereSRC%
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel%
			GROUP BY RC_QTDSEM, RC_PROCES, RC_PERIODO, RC_ROTEIR, %exp:cCpoDelimC%, RC_PD, RC_FILIAL %exp:cGroupEC%

			UNION ALL

			SELECT SUM(SRA.RA_SALARIO) SALARIO, SRD.RD_PD PD,SUM(SRD.RD_QTDSEM) QTDSEM,         SUM(SRD.RD_HORAS) HORAS,
					SUM(SRD.RD_VALOR) VALOR,     SRD.RD_PROCES PROCES, SRD.RD_PERIODO PERIODO,
					SRD.RD_ROTEIR ROTEIR,        SRD.RD_FILIAL FILIAL	%exp:cExtraD%,
					SRA.%exp:cCpoAlsD%,
					count(SRD.rD_PD) OCORR
			FROM  %table:SRA% SRA
			INNER JOIN %table:SRD% SRD
			ON 		SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
			WHERE 	SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
			 		( ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA <= %exp:cDtPerFim% AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) ) OR
					  ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA > %exp:cDtPerFim% AND ' ' IN (%exp:Upper(cSitQuery)%) ) OR
					  ( SRA.RA_SITFOLH <> 'D' AND SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) ) ) AND
					SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
					SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND
					%exp:cWhereSRD%
					SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel%
			GROUP BY RD_PROCES, RD_PERIODO, RD_ROTEIR, RD_QTDSEM, %exp:cCpoDelimD%, RD_PD, RD_FILIAL %exp:cGroupED%
		) tView
		INNER JOIN	%table:SRV% SRVA
		ON			SRVA.RV_COD = tView.PD AND %exp:cJoinAux% AND SRVA.%notDel%
		GROUP BY tView.SALARIO, tView.PD,tView.QTDSEM, tView.HORAS,  tView.VALOR,     tView.PROCES,
				tView.PERIODO, tView.ROTEIR,    tView.FILIAL, SRVA.RV_TIPOCOD, SRVA.RV_TIPO, %exp:cCpoAdView%
				SRVA.RV_DESC,  SRVA.RV_IMPRIPD, tView.%exp:cCpoViewG%, tView.OCORR
		ORDER BY %exp:cCpoDelim%, PD
    EndSql

    //END cAliasQry

	If nOrdem == 1 .Or. nOrdem == 2
		END REPORT QUERY oSectFunc
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL == cParam},{||(cAliasQry)->RA_FILIAL})
	ElseIf nOrdem == 3 .Or. nOrdem == 4
		END REPORT QUERY oSectCttc
		oSectFunc:SetParentQuery()
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->RA_CC == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_CC})
	ElseIf nOrdem == 5 .Or. nOrdem == 6
		END REPORT QUERY oSectCttc
		oSectFunc:SetParentQuery()
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->CTT_CUSTO == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->CTT_CUSTO})
	ElseIf nOrdem == 7 .Or. nOrdem == 8
		END REPORT QUERY oSectDept
		oSectFunc:SetParentQuery()
		oSectLanc:SetParentQuery()
		oSectLanc:SetParentFilter({|cParam|(cAliasQry)->FILIAL+(cAliasQry)->RA_DEPTO == cParam},{||(cAliasQry)->RA_FILIAL+(cAliasQry)->RA_DEPTO})
	EndIf
	cAliasFun	:= cAliasQry

EndIf

//SELECIONA TABELA DE FUNCIONARIOS
dbSelectArea("SM0")
dbSelectArea(cAliasQry)
(cAliasQry)->(DbGoTop())

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
oReport:SetMeter(LastRec())

oReport:OnPageBreak({||fGR106Header(oReport,lGper670)}) //IMPRESSAO DO CABECALHO

//ALTERA O TITULO DO RELATORIO
oReport:SetTitle(cTitulo)

If nOrdem == 1 .Or. nOrdem == 2
	oSectFunc:Print()
ElseIf nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 6
	If oReport:nDevice == 4 // Excel
		oSectCttc:Print()
	Else
		If nAnaSin == 1  	//AnalÌtico
			oSectCttc:Print()
		Else				//SintÈtico
			oSectFunc:Print()
		EndIf
	Endif
ElseIf nOrdem == 7 .Or. nOrdem == 8
	If nAnaSin	== 1	//AnalÌtico
		oSectDept:Print()
	Else				//SintÈtico
		oSectFunc:Print()
	EndIf
EndIf

If lDifLiq .AND. nAnaSin == 1	//AnalÌtico
	//IMPRIME AS DIFERENCAS DE LIQUIDOS
	fImprDifLiq(oReport)

	//FINALIZA O RELATORIO PARA IMPRESSAO DAS DIFERENCAS DE LIQUIDOS
	oReport:Finish()
	oReport:aBreak := {}
	oReport:aCollection := {}
	oReport:aFunction := {}
EndIf

If nAnaSin == 1 .AND. (oReport:nMeter > 0) //Apenas imprimir linha quando h· dados no reltÛrio.
	oReport:ThinLine()
	oReport:SkipLine()
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ fBuscaValSal  ≥ Autor ≥ Tania Bronzeri   ≥ Data ≥28/11/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Encontra o salario a imprimir no relatorio                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Folha Mexico                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fBuscaValSal()
Local nValSal	:= 0

nValSal := fBuscaSal(dDataRef,,,.F.)
If nValSal ==0 .And. !(fRetSR7(dDataRef, dDataRef, .T.) == "C")
	If nAnaSin == 1
		nValSal := (cAliasQry)->RA_SALARIO
	ElseIf nAnaSin == 2
		nValSal := (cAliasQry)->SALARIO
	EndIf
EndIf

Return nValSal

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fImprimeLanca ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥06/12/2007≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Imprime os lancamentos da Folha de Pagamento                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fImprimeLanca(oSelf)
Local aArea		:= GetArea()
Local cPDB		:= ""	//Horas / Dias / Valores
Local nMax		:= 0	//Controle maximo de verbas por tipo
Local nMaxP		:= 0
Local nMaxD		:= 0
Local nMaxB		:= 0
Local nCta		:= 0
Local nCtaB		:= 0
Local nHoras	:= 0
Local lImprLine
Local lImpAux	:= .F.
Local lSexagPd  := .F.
Local aTemp		:= {}
Local nDescTam	:= 15
Local aOrd		:= {}
Local lCCMov	:= ( nOrdem == 5 .Or. nOrdem == 6 )
Local cMvHorasD	:= SuperGetmv("MV_HORASDE")
Local cRVTipo   := ""

If oSelf:cName == "FUNCIONARIO"
	oSelf:oReport:SkipLine()
	If oSelf:lVisible == .T.
		oSelf:oReport:FatLine()
	ElseIf lSint
		nTotFunc++
	Endif
	lPrinOn	:= .T.
ElseIf oSelf:cName == "LANCAMENTO"
	If lPrinOn
		nDescTam := oSelf:Cell("DESCD" ):GetSize()

		//Impreme verba de desoneraÁ„o
		If cFilAux <>  (cAliasFun)->RA_FILIAL .AND. cPaisLoc == "BRA"
			fTotIdFat((cAliasFun)->RA_FILIAL)
			If cRoteiro <> fGetCalcRot('5')
				fGPSVal((cAliasFun)->RA_FILIAL,cPeriodo,@aGPSVal,AllTrim(STR(nTpContr)))
			EndIf
			cFilAux :=  (cAliasFun)->RA_FILIAL
		EndIf

		oSelf:SetLineStyle(.F.)
		aLanP		:= {}
		aLanD		:= {}
		aLanB		:= {}
		aNomeFunc	:= {}

		While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(FILIAL+MAT) == (cAliasFun)->(RA_FILIAL+RA_MAT) .And. ( !lCCMov .Or. (cAliasQry)->CCUSTO == (cAliasFun)->CTT_CUSTO )
			cPDB := (cAliasQry)->RV_TIPOCOD
			cRVTipo := (cAliasQry)->RV_TIPO
			If(Empty(aNomeFunc)) /*Apenas no primeiro registro*/
				aNomeFunc := (cAliasQry)->({RA_FILIAL,RA_MAT,RA_NOME})
			endIf

			Do Case/* aTemp guarda uma referÍncia ao vetor que deve ser alterado.*/
				Case (cPDB == "1")
					aTemp := aLanP //Proventos
				Case (cPDB == "2")
					aTemp := aLanD //Descontos
				Case (cPDB $ "3/4" .And. (cAliasQry)->RV_IMPRIPD != "2")
					aTemp := aLanB //Bases
				OtherWise
					aTemp := Nil
			EndCase

			If(lSexagPd := (cAliasQry)->RV_TIPO == "H" .And. lHoraSexag .And. cMvHorasD == "S")
				nHoras := fConvHr((cAliasQry)->HORAS, "H")
			Else
				nHoras := (cAliasQry)->HORAS
			EndIf

			If(aTemp != Nil)
				If lSumaVerba .And. (nPos := aScan(aTemp,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aTemp[nPos,3] := If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S", (cAliasQry)->QTDSEM, If(lSexagPd, SomaHoras(aTemp[nPos, 3], nHoras), aTemp[nPos, 3] + nHoras))
					aTemp[nPos,4] += (cAliasQry)->VALOR
				Else
					(cAliasQry)->(aAdd(aTemp,{PD, iIf(Len (aFldRv) > 0, Replicate("*",TamSX3("RV_DESC")[1]),Left(RV_DESC,nDescTam)), iIf(QTDSEM > 0 .And. cIRefSem == "S", QTDSEM, nHoras), VALOR, SEQ, RV_IMPRIPD,INSS,FGTS,IR}))
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		nMaxP	:= Len(aLanP)
		nMaxD 	:= Len(aLanD)
		nMaxB 	:= Len(aLanB)
		nMax	:= MAX(MAX(nMaxP,nMaxD),nMaxB)

		aSort(aLanB,,,{ |x,y| x[6]+x[1] < y[6]+y[1]})
		lPrinOn := .F.
		nCtaB := 1
		oSelf:Init()

		For nCta :=1 to nMax
			lImprLine := .F.

			ConfCells(oSelf,nCta,'P',@lImprLine,aLanP)
			ConfCells(oSelf,nCta,'D',@lImprLine,aLanD)
			aOrd := GetCells(oSelf,"B")

			If nCta > nMaxB .OR. nCtaB > nMaxB
				oSelf:Cell(aOrd[VALORB]):SetPicture("")
				oSelf:Cell(aOrd[PDB]   ):SetValue("")	//"Cod."
				oSelf:Cell(aOrd[DESCB] ):SetValue("")	//"DescriÁ„o"
				If cPaisLoc == "COS"
					oSelf:Cell(aOrd[REFERB]):Hide()
					oSelf:Cell(aOrd[REFERB]):SetPicture("")
					oSelf:Cell(aOrd[REFERB]):SetValue(aLanD[nCta,3])	//"Ref."
				Endif
				oSelf:Cell(aOrd[VALORB]):SetValue("")	//"Valor"
				lImprLine := lImprLine .OR. .F.
			Else
				If nCta > nMaxB
					oSelf:Cell(aOrd[VALORB]):Hide()
					oSelf:Cell(aOrd[PDB]   ):Hide()
					oSelf:Cell(aOrd[DESCB] ):Hide()
					lImprLine := lImprLine .OR. .F.

					oSelf:Cell(aOrd[VALORB]):SetPicture("")
					oSelf:Cell(aOrd[PDB]   ):SetValue("")	//"Cod."
					oSelf:Cell(aOrd[DESCB] ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell(aOrd[VALORB]):SetValue("")	//"Valor"
					If cPaisLoc == "COS"
						oSelf:Cell(aOrd[REFERB]):Hide()
						oSelf:Cell(aOrd[REFERB]):SetPicture("")
						oSelf:Cell(aOrd[REFERB]):SetValue(aLanD[nCta,3])	//"Ref."
					Endif
				Else
					If !lImpBase
						oSelf:Cell(aOrd[VALORB]):Hide()
						oSelf:Cell(aOrd[PDB]   ):Hide()
						oSelf:Cell(aOrd[DESCB] ):Hide()
						If cPaisLoc == "COS"
							oSelf:Cell(aOrd[REFERB]):Hide()
						Endif
						lImprLine := lImprLine .OR. .F.
					Else
						oSelf:Cell(aOrd[VALORB]):Show()
						oSelf:Cell(aOrd[PDB]   ):Show()
						oSelf:Cell(aOrd[DESCB] ):Show()
						If cPaisLoc == "COS"
							oSelf:Cell(aOrd[REFERB]):Show()
						Endif
						lImprLine := .T.
					EndIf
					oSelf:Cell(aOrd[VALORB]):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell(aOrd[PDB]   ):SetValue(aLanB[nCta,1])	//"Cod."
					oSelf:Cell(aOrd[DESCB] ):SetValue(aLanB[nCta,2])	//"DescriÁ„o"
					If cPaisLoc == "COS"
						oSelf:Cell(aOrd[REFERB]):SetPicture("@E 999,999.99")
						oSelf:Cell(aOrd[REFERB]):SetValue(aLanB[nCta,3])	//"Ref."
					Endif
					oSelf:Cell(aOrd[VALORB]):SetValue(aLanB[nCta,4])	//"Valor"
				EndIf
			EndIf

			If nCta < nMax
				If lImprLine
					oSelf:PrintLine()
				Endif
			EndIf

		Next nCta

		If lImpBase .and. lImpFil
		 	lImprLine := .F.
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcion·rio, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)

					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()

					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERP"):SetValue("")	//"Ref."
					oSelf:Cell("VALORP"):SetValue("")	//"Valor"

					oSelf:Cell("REFERD"):Hide()
					oSelf:Cell("VALORD"):Hide()
					oSelf:Cell("PDD"   ):Hide()
					oSelf:Cell("DESCD" ):Hide()
					oSelf:Cell("PIPED"):Hide()

					oSelf:Cell("REFERD"):SetPicture("")
					oSelf:Cell("VALORD"):SetPicture("")
					oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor"

					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"DescriÁ„o"
					oSelf:Cell("VALORB"):SetValue(aFilB[nCta,3])	//"Valor"
					aFilB := {}
					lImprLine := .T.
				Next nCta
			EndIf
			//Imprime os totais de complemento da GPS
			If Len(aGPSVal) > 0
				lImpAux := .F.
				For nCta := 1 to Len(aGPSVal)
					If Substr(aGPSVAL[nCta,1],1,nTamCC) == (cAliasFun)->RA_CC .or. Empty(aGPSVAL[nCta,1])
						If lImprLine .or. lImpAux
							oSelf:PrintLine()
							lImprLine := .F.
						EndIf
						oSelf:Cell("REFERP"):Hide()
						oSelf:Cell("VALORP"):Hide()
						oSelf:Cell("PDP"   ):Hide()
						oSelf:Cell("DESCP" ):Hide()
						oSelf:Cell("PIPEP"):Hide()

						oSelf:Cell("REFERP"):SetPicture("")
						oSelf:Cell("VALORP"):SetPicture("")
						oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERP"):SetValue("")	//"Ref."
						oSelf:Cell("VALORP"):SetValue("")	//"Valor"

						oSelf:Cell("REFERD"):Hide()
						oSelf:Cell("VALORD"):Hide()
						oSelf:Cell("PDD"   ):Hide()
						oSelf:Cell("DESCD" ):Hide()
						oSelf:Cell("PIPED"):Hide()

						oSelf:Cell("REFERD"):SetPicture("")
						oSelf:Cell("VALORD"):SetPicture("")
						oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor"

						//N„o deve ser exibido para o funcion·rio, apenas no totalizador
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(IIF (Len (aFldRv) > 0, Replicate("*",TamSX3("RV_DESC")[1]), fDesc("SRV", aGPSVal[nCta,2], "RV_DESC")))	//"DescriÁ„o"
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						lImpAux := .T.
						aGPSVal[nCta,5] := 0 //Zera para n„o ser duplicado no totalizador
					Endif
				Next nCta
			EndIf
		EndIf

		oSelf:Finish()
	EndIf
EndIf

RestArea(aArea)

Return .T.

Static Function ConfCells(oSection,nPos,cPostfix,lImprLine,aValues)
	//criar define
	//Local aCells := {'REFER','VALOR','PD','DESC','PIPE','INSS','FGTS','IR'}
	Local aReg := {}
	Local nI := 0
	Local aOrd	:= {}

	If cPostfix == "P"
		aOrd := GetCells(oSection,"P")
	ElseIf cPostfix == "D"
		aOrd := GetCells(oSection,"D")
	EndIf

	If nPos > Len(aValues)
		oSection:Cell(aOrd[REFER]):SetPicture("")
		oSection:Cell(aOrd[NVALOR]):SetPicture("")
		for nI:= 1 to Len(aOrd)
			oSection:Cell(aOrd[ni]):Hide()
			oSection:Cell(aOrd[ni]):SetValue("")
		next nI
		lImprLine := lImprLine .OR. .F.
	Else
		aReg := aValues[nPos]

		for nI:= 1 to Len(aOrd)
			oSection:Cell(aOrd[ni]):Show() //Exibe todas as celulas
		next nI

		oSection:Cell(aOrd[REFER]):SetPicture("@E 999,999.99")
		oSection:Cell(aOrd[NVALOR]):SetPicture("@E 99,999,999,999.99")
		oSection:Cell(aOrd[NPD]):SetValue(aReg[1])	//"Cod."
		oSection:Cell(aOrd[DESC]):SetValue(aReg[2])	//"DescriÁ„o"
		oSection:Cell(aOrd[REFER] ):SetValue(aReg[3])	//"Ref."
		oSection:Cell(aOrd[NVALOR]):SetValue(aReg[4])	//"Valor"
		oSection:Cell(aOrd[INSS]):SetValue(aReg[7])
		oSection:Cell(aOrd[FGTS]):SetValue(aReg[8])
		oSection:Cell(aOrd[IR]):SetValue(aReg[9])
		lImprLine := .T.
	EndIf
Return nil


Static Function GetCells(oSection,cPostfix)
	Local aCells := {'REFER','VALOR','PD','DESC','PIPE','INSS','FGTS','IR'}
	Local aCellsB := {'VALORB','PDB','DESCB'}
	Local aReg := {}
	Local nI := 0

	If cPaisLoc == "COS"
		aadd(aCellsB,'REFERB')
	EndIf
	If cPostfix == "P"
		If Empty(aOrdemP)
			For nI:= 1 to Len(aCells)
				aadd(aReg,oSection:Cell(aCells[nI] + cPostfix):GetOrder())
			Next nI
			aOrdemP := aReg
		Else
			aReg := aOrdemP
		EndIf
	EndIf

	If cPostfix == "D"
		If Empty(aOrdemD)
			For nI:= 1 to Len(aCells)
				aadd(aReg,oSection:Cell(aCells[nI] + cPostfix):GetOrder())
			Next nI
			aOrdemD := aReg
		Else
			aReg := aOrdemD
		EndIf
	EndIf

	If cPostfix == "B"
		If Empty(aOrdemB)
			For nI:= 1 to Len(aCellsB)
				aadd(aReg,oSection:Cell(aCellsB[nI]):GetOrder())
			Next nI
			aOrdemB := aReg
		Else
			aReg := aOrdemB
		EndIf
	EndIf
Return aReg
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fImprSint     ≥ Autor ≥ Tania Bronzeri        ≥ Data ≥27/02/2008≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Imprime os lancamentos da Folha de Pagamento Sintetica          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                         ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fImprSint(oSelf,lGper670)
Local aArea		:= GetArea()
Local aLanP		:= {}
Local aLanD 	:= {}
Local aLanB 	:= {}
Local nMax		:= 0 //Controle maximo de verbas por tipo
Local nMaxP 	:= 0
Local nMaxD 	:= 0
Local nMaxB 	:= 0
Local nCta		:= 0
Local nHoras    := 0
Local nTamCC	:=	TamSX3("RA_CC")[1]
Local lImprLine
Local lImpAux	:= .F.
Local lHorasD	:= SuperGetmv("MV_HORASDE",, "N") == "S"
Local cPDB		:= "" //Horas / Dias / Valores
Local cCpoQbr	:= (cAliasQry)->(&(cCpoQuebra))

cDAnt := (cAliasQry)->FILIAL + IIf(Empty(cCpoQbr), "", cCpoQbr)

lcabecalho := .T.

If oSelf:cName != "LANCAMENTO"
	oSelf:oReport:SkipLine()
	//oSelf:oReport:ThinLine()//FatLine()
	lPrinOn	:= .T.
Else

	If lPrinOn

		//Imprime verba de desoneraÁ„o
		If cFilAux <> (cAliasQry)->RA_FILIAL .AND. cPaisLoc == "BRA"
			fTotIdFat((cAliasQry)->RA_FILIAL)
			If cRoteiro <> fGetCalcRot('5')
				fGPSVal((cAliasQry)->RA_FILIAL,cPeriodo,@aGPSVal,AllTrim(STR(nTpContr)))
			EndIf
			cFilAux := (cAliasQry)->RA_FILIAL
		EndIf

		oSelf:lVisible := .T.
		oSelf:SetLineStyle(.F.)
		aLanP	:= {}
		aLanD  	:= {}
		aLanB 	:= {}

		While (cAliasQry)->(!Eof()) .And. ;
			cDAnt == (cAliasQry)->FILIAL + IIf(Empty((cAliasQry)->(&(cCpoQuebra))), "", (cAliasQry)->(&(cCpoQuebra)))

			cPDB   := (cAliasQry)->RV_TIPOCOD
			nHoras := IIf((cAliasQry)->RV_TIPO == "H" .And. lHoraSexag .And. lHorasD, fConvHr((cAliasQry)->HORAS, "H"), (cAliasQry)->HORAS)
			
			If cPDB == "1"
				If lSumaVerba .And. (nPos := aScan(aLanP,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aLanP[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aLanP[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanP,{						 ;
							(cAliasQry)->PD			,;
							(cAliasQry)->RV_DESC	,;
							iif(cIRefSem == 'S' .And. (cAliasQry)->QTDSEM > 0, (cAliasQry)->QTDSEM, iif( !lGper670 .Or. (lGper670 .and. cRefOco == 1), nHoras, (cAliasQry)->OCORR ))		,;
							(cAliasQry)->VALOR		,;
							})
				EndIf
			ElseIf cPDB == "2"
				If lSumaVerba .And. (nPos := aScan(aLanD,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aLanD[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aLanD[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanD,{						 ;
							(cAliasQry)->PD			,;
							(cAliasQry)->RV_DESC	,;
							iif(cIRefSem == 'S' .And. (cAliasQry)->QTDSEM > 0, (cAliasQry)->QTDSEM, iif( !lGper670 .Or. (lGper670 .and. cRefOco == 1), nHoras, (cAliasQry)->OCORR ))		,;
							(cAliasQry)->VALOR		,;
							})
				EndIf
			ElseIf cPDB $ "3/4" .And. (cAliasQry)->RV_IMPRIPD != "2"
				If lSumaVerba .And. (nPos := aScan(aLanB,{ |x| x[1] = (cAliasQry)->PD })) > 0
					aLanB[nPos,3] += If((cAliasQry)->QTDSEM > 0 .And. cIRefSem == "S",(cAliasQry)->QTDSEM,(cAliasQry)->HORAS)
					aLanB[nPos,4] += (cAliasQry)->VALOR
				Else
					aAdd(aLanB,{						 ;
							(cAliasQry)->PD 		,;
							(cAliasQry)->RV_DESC	,;
							iif(cIRefSem == 'S' .And. (cAliasQry)->QTDSEM > 0, (cAliasQry)->QTDSEM, iif( !lGper670 .Or. (lGper670 .and. cRefOco == 1), (cAliasQry)->HORAS, (cAliasQry)->OCORR ))		,;
							(cAliasQry)->VALOR		,;
							})
				EndIf
			EndIf

			(cAliasQry)->(DbSkip())
		EndDo

		nMaxP	:= Len(aLanP)
		nMaxD 	:= Len(aLanD)
		nMaxB 	:= Len(aLanB)
		nMax	:= MAX(MAX(nMaxP,nMaxD),nMaxB)
		lPrinOn := .F.

		oSelf:Init()

		oSelf:Cell("REFERP"):Show()
		oSelf:Cell("VALORP"):Show()
		oSelf:Cell("PDP"   ):Show()
		oSelf:Cell("DESCP" ):Show()
		oSelf:Cell("PIPEP"):Show()

		oSelf:Cell("REFERD"):Show()
		oSelf:Cell("VALORD"):Show()
		oSelf:Cell("PDD"   ):Show()
		oSelf:Cell("DESCD" ):Show()
		oSelf:Cell("PIPED"):Show()

		oSelf:Cell("VALORB"):Show()
		oSelf:Cell("PDB"   ):Show()
		oSelf:Cell("DESCB" ):Show()

		For nCta :=1 to nMax
			If nCta > nMaxP

				oSelf:Cell("REFERP"):SetPicture("")
				oSelf:Cell("VALORP"):SetPicture("")
				oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("REFERP"):SetValue("")	//"Ref."
				oSelf:Cell("VALORP"):SetValue("")	//"Valor"
			Else
				oSelf:Cell("REFERP"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORP"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDP"   ):SetValue(aLanP[nCta,1])	//"Cod."
				oSelf:Cell("DESCP" ):SetValue(aLanP[nCta,2])	//"DescriÁ„o"
				oSelf:Cell("REFERP"):SetValue(aLanP[nCta,3])	//"Ref."
				oSelf:Cell("VALORP"):SetValue(aLanP[nCta,4])	//"Valor"
			EndIf
			If nCta > nMaxD

				oSelf:Cell("REFERD"):SetPicture("")
				oSelf:Cell("VALORD"):SetPicture("")
				oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("REFERD"):SetValue("")	//"Ref."
				oSelf:Cell("VALORD"):SetValue("")	//"Valor"
			Else
				oSelf:Cell("REFERD"):SetPicture("@E 999,999.99")
				oSelf:Cell("VALORD"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDD"   ):SetValue(aLanD[nCta,1])	//"Cod."
				oSelf:Cell("DESCD" ):SetValue(aLanD[nCta,2])	//"DescriÁ„o"
				oSelf:Cell("REFERD"):SetValue(aLanD[nCta,3])	//"Ref."
				oSelf:Cell("VALORD"):SetValue(aLanD[nCta,4])	//"Valor"
			EndIf
			If nCta > nMaxB
				oSelf:Cell("VALORB"):SetPicture("")
				oSelf:Cell("PDB"   ):SetValue("")	//"Cod."
				oSelf:Cell("DESCB" ):SetValue("")	//"DescriÁ„o"
				oSelf:Cell("VALORB"):SetValue("")	//"Valor"
				If cPaisLoc == "COS"
					oSelf:Cell("REFERB"):SetPicture("")
					oSelf:Cell("REFERB"):SetValue(aLanD[nCta,3])	//"Ref."
				Endif
			Else
			   	If !lImpBase
					oSelf:Cell("VALORB"):Hide()
					oSelf:Cell("PDB"   ):Hide()
					oSelf:Cell("DESCB" ):Hide()
				EndIf
				oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
				oSelf:Cell("PDB"   ):SetValue(aLanB[nCta,1])	//"Cod."
				oSelf:Cell("DESCB" ):SetValue(aLanB[nCta,2])	//"DescriÁ„o"
				If cPaisLoc == "COS"
					oSelf:Cell("REFERB"):SetPicture("@E 999,999.99")
					oSelf:Cell("REFERB"):SetValue(aLanB[nCta,3])	//"Ref."
				Endif
				oSelf:Cell("VALORB"):SetValue(aLanB[nCta,4])	//"Valor"
			EndIf
			If nCta < nMax .Or. (lImpBase .and. lImpFil .and. Len(aFilB) > 0)
				oSelf:PrintLine()
			EndIf
		Next nCta

		If lImpBase .and. lImpFil
			If Len(aFilB) > 0
				//Imprime o total da verba 973 no primeiro funcion·rio, sem exibir a linha, para que seja somado no totalizador da filial
				For nCta := 1 to Len(aFilB)

					oSelf:Cell("REFERP"):Hide()
					oSelf:Cell("VALORP"):Hide()
					oSelf:Cell("PDP"   ):Hide()
					oSelf:Cell("DESCP" ):Hide()
					oSelf:Cell("PIPEP"):Hide()

					oSelf:Cell("REFERP"):SetPicture("")
					oSelf:Cell("VALORP"):SetPicture("")
					oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERP"):SetValue("")	//"Ref."
					oSelf:Cell("VALORP"):SetValue("")	//"Valor"

					oSelf:Cell("REFERD"):Hide()
					oSelf:Cell("VALORD"):Hide()
					oSelf:Cell("PDD"   ):Hide()
					oSelf:Cell("DESCD" ):Hide()
					oSelf:Cell("PIPED"):Hide()

					oSelf:Cell("REFERD"):SetPicture("")
					oSelf:Cell("VALORD"):SetPicture("")
					oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
					oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
					oSelf:Cell("REFERD"):SetValue("")	//"Ref."
					oSelf:Cell("VALORD"):SetValue("")	//"Valor"

					If nOrdem == 1 .or. nOrdem == 2
						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
					Else
						oSelf:Cell("VALORB"):Hide()
						oSelf:Cell("PDB"   ):Hide()
						oSelf:Cell("DESCB" ):Hide()
					EndIf

					oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
					oSelf:Cell("PDB"   ):SetValue(aFilB[nCta,1])	//"Cod."
					oSelf:Cell("DESCB" ):SetValue(aFilB[nCta,2])	//"DescriÁ„o"
					oSelf:Cell("VALORB"):SetValue(aFilB[nCta,3])	//"Valor"
					aFilB := {}
					lImprLine := .T.
				Next nCta
			EndIf
			//Imprime os totais de complemento da GPS
			If Len(aGPSVal) > 0
				lImpAux := .F.
				For nCta := 1 to Len(aGPSVal)
					If ( nOrdem >= 3 .And. nOrdem <= 6 )
						If Substr(aGPSVAL[nCta,1],1,nTamCC) == cCpoQbr .or. Empty(aGPSVAL[nCta,1])
							If lImprLine .or. lImpAux
								oSelf:PrintLine()
								lImprLine := .F.
							EndIf
							oSelf:Cell("REFERP"):Hide()
							oSelf:Cell("VALORP"):Hide()
							oSelf:Cell("PDP"   ):Hide()
							oSelf:Cell("DESCP" ):Hide()
							oSelf:Cell("PIPEP"):Hide()

							oSelf:Cell("REFERP"):SetPicture("")
							oSelf:Cell("VALORP"):SetPicture("")
							oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
							oSelf:Cell("REFERP"):SetValue("")	//"Ref."
							oSelf:Cell("VALORP"):SetValue("")	//"Valor"

							oSelf:Cell("REFERD"):Hide()
							oSelf:Cell("VALORD"):Hide()
							oSelf:Cell("PDD"   ):Hide()
							oSelf:Cell("DESCD" ):Hide()
							oSelf:Cell("PIPED"):Hide()

							oSelf:Cell("REFERD"):SetPicture("")
							oSelf:Cell("VALORD"):SetPicture("")
							oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
							oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
							oSelf:Cell("REFERD"):SetValue("")	//"Ref."
							oSelf:Cell("VALORD"):SetValue("")	//"Valor"

							oSelf:Cell("VALORB"):Show()
							oSelf:Cell("PDB"   ):Show()
							oSelf:Cell("DESCB" ):Show()
							oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
							oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
							oSelf:Cell("DESCB" ):SetValue(IIF (Len (aFldRv) > 0, Replicate("*",TamSX3("RV_DESC")[1]),fDesc("SRV", aGPSVal[nCta,2], "RV_DESC")))	//"DescriÁ„o"
							oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
							lImpAux := .T.
						EndIf
					Else
						If lImprLine .or. lImpAux
							oSelf:PrintLine()
							lImprLine := .F.
						EndIf
						oSelf:Cell("REFERP"):Hide()
						oSelf:Cell("VALORP"):Hide()
						oSelf:Cell("PDP"   ):Hide()
						oSelf:Cell("DESCP" ):Hide()
						oSelf:Cell("PIPEP"):Hide()

						oSelf:Cell("REFERP"):SetPicture("")
						oSelf:Cell("VALORP"):SetPicture("")
						oSelf:Cell("PDP"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCP" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERP"):SetValue("")	//"Ref."
						oSelf:Cell("VALORP"):SetValue("")	//"Valor"

						oSelf:Cell("REFERD"):Hide()
						oSelf:Cell("VALORD"):Hide()
						oSelf:Cell("PDD"   ):Hide()
						oSelf:Cell("DESCD" ):Hide()
						oSelf:Cell("PIPED"):Hide()

						oSelf:Cell("REFERD"):SetPicture("")
						oSelf:Cell("VALORD"):SetPicture("")
						oSelf:Cell("PDD"   ):SetValue("")	//"Cod."
						oSelf:Cell("DESCD" ):SetValue("")	//"DescriÁ„o"
						oSelf:Cell("REFERD"):SetValue("")	//"Ref."
						oSelf:Cell("VALORD"):SetValue("")	//"Valor"

						oSelf:Cell("VALORB"):Show()
						oSelf:Cell("PDB"   ):Show()
						oSelf:Cell("DESCB" ):Show()
						oSelf:Cell("VALORB"):SetPicture("@E 99,999,999,999.99")
						oSelf:Cell("PDB"   ):SetValue(aGPSVal[nCta,2])	//"Cod."
						oSelf:Cell("DESCB" ):SetValue(IIF (Len (aFldRv) > 0, Replicate("*",TamSX3("RV_DESC")[1]),fDesc("SRV", aGPSVal[nCta,2], "RV_DESC")))	//"DescriÁ„o"
						oSelf:Cell("VALORB"):SetValue(aGPSVal[nCta,5])	//"Valor"
						lImpAux := .T.
					EndIf
				Next nCta
			EndIf
		EndIf

		oSelf:Finish()
	Else

		If nAnaSin == 1
			oSelf:lVisible := .F.
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GPER106   ∫Autor  ≥Microsiga           ∫ Data ≥  09/11/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fCalcDifLiq(nValDif)
Local nCont 		:= 0
Local nProc 		:= aScan( aLanB, { |x| x[1] == cPdLiq})
Local nValLiq		:= 0
Local nTotVal		:= 0
Local nValPro		:= 0
Local nValDes		:= 0
Local cRet			:= ""

	//SOMA OS PROVENTOS
	For nCont := 1 To Len(aLanP)
		nValPro := nValPro + aLanP[ nCont, 4 ]
	Next

	//SOMA OS DESCONTOS
	For nCont := 1 To Len(aLanD)
		nValDes := nValDes+ aLanD[ nCont, 4 ]
	Next

	If ( nProc > 0 )
		nValLiq	:= aLanB[ nProc, 4 ]
	Else
		nValLiq := 0
	EndIf

	If 	( ( nTotVal := ( nValLiq - ( nValPro - nValDes ) )  ) != 0 )

		cRet := " "+OemToAnsi(STR0055)+" " 	+ AllTrim(aNomeFunc[1])
		cRet += Space(15-Len(cRet)) + "|"
		cRet += " "+OemToAnsi(STR0002)+" " + AllTrim(aNomeFunc[2])
		cRet += Space(35-Len(cRet)) + "|"
		cRet += " "+OemToAnsi(STR0003)+" " + Substr(AllTrim(aNomeFunc[3]), 1, 25)
		cRet += Space(70-Len(cRet)) + "|"
		cRet += " "+OemToAnsi(STR0027)+" " + AllTrim(cPdLiq)
 		cRet += " | "+OemToAnsi(STR0053)+" " + AllTrim(Str(nTotVal))
 		//ADICIONA RESULTADO NO ARRAY QUE SERA IMPRESSO NO FINAL DO RELATORIO COM TODAS AS DIFERENCAS DE LIQUIDOS
		aAdd(aDifLiquidos, cRet)
		cRet := " "+OemToAnsi(STR0053)+" " + AllTrim(Str(nTotVal))
	Else
		cRet := " "+OemToAnsi(STR0039)+" 0.00"
	EndIf

Return cRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥GPER106   ∫Autor  ≥Microsiga           ∫ Data ≥  09/12/08   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fImprDifLiq(oReport)
Local nCont		:= 0
Local nTamADif 	:= Len(aDifLiquidos)

oSectDifLiq:Init()
oSectDifLiq:cell("DIFLIQ"):SetValue( OemToAnsi(STR0053) )
oSectDifLiq:PrintLine()
oReport:ThinLine()
oReport:SkipLine()

If ( nTamADif > 0 )
	For nCont := 1 To nTamADif
		oSectDifLiq:cell("DIFLIQ"):SetValue( aDifLiquidos[ nCont ] )
   		oSectDifLiq:PrintLine()
	Next
EndIf

oReport:SkipLine()

Return (Nil)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fImprQFu  ∫Autor  ≥Reginaldo           ∫ Data ≥  15/10/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥imprime a total de funcionario que foram Gerados	           ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPER106                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fImprQFun(oReport)
oReport:SkipLine()
oSectQtdFun:Init()
oSectQtdFun:cell("TOTFUNC"):SetValue( OemToAnsi(STR0056) + Str(nTotFunc) )
oSectQtdFun:PrintLine()

If nAnaSin == 1
	oReport:ThinLine()
	oReport:SkipLine()
EndIf

Return ( Nil )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fCountTotFunc∫Autor  ≥Reginaldo           ∫ Data ≥  15/10/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Conta os funcionarios que ser„o imprssos na opÁ„o analitica    ∫±±
±±∫          ≥                                                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ GPER106                                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function fCountTotFunc()
	nTotFunc++
Return Nil

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fCtrlDtRa  ≥ Autor ≥ Equipe RH - N3        ≥ Data ≥01/09/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao ≥ Controle de habilitaÁ„o e desabilitaÁ„o das cÈlulas de impre-≥±±
±±≥         ≥ Sess„o das datas de Admiss„o, Readmiss„o e Reconhecimento.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                      ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fCtrlDtRA(oSecAux)
Local aArea := GetArea()

dbSelectArea(cAliasFun)
If cPaisLoc != "MEX"
	oSecAux:Cell("RA_ADMISSA"):Enable()
Else
	If !Empty((cAliasFun)->RA_DTREC)
		oSecAux:Cell("RA_DTREC"  ):Enable()
		oSecAux:Cell("RA_FECREI" ):Disable()
		oSecAux:Cell("RA_ADMISSA"):Disable()
	ElseIf !Empty((cAliasFun)->RA_FECREI)
		oSecAux:Cell("RA_FECREI" ):Enable()
		oSecAux:Cell("RA_DTREC"  ):Disable()
		oSecAux:Cell("RA_ADMISSA"):Disable()
	Else
		oSecAux:Cell("RA_ADMISSA"):Enable()
		oSecAux:Cell("RA_DTREC"  ):Disable()
		oSecAux:Cell("RA_FECREI" ):Disable()
	EndIf
Endif

RestArea(aArea)
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖcao  ≥fGR106join  ≥ Autor ≥  Equipe RH           ≥ Data ≥ 19/09/2012       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescricaáÖo ≥O tratamento a seguir deve-se ao problema do embedded SQL n„o      ≥±±
±±≥          ≥converter clausula "SUBSTRING" no INNER JOIN, ao usar banco de dados ≥±±
±±≥          ≥ORACLE. E segundo sustentaÁao FRAMEWORK, devemos alterar consulta SQL≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametro ≥ExpC1 - Obrigatorio - Vari·vel com Primeira tabela do "inner join"   ≥±±
±±≥          ≥ExpC2 - Obrigatorio - Vari·vel com Segunda  tabela do "inner join"   ≥±±
±±≥          ≥ExpC3 - Vari·vel indica se retorno dever· conter "%   %". Caso vazio ≥±±
±±≥          ≥        o seu valor padr„o ser· "".                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥GPER106                                                              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fGR106join(cTabela1, cTabela2,cEmbedded)
Local cFiltJoin := ""
Default cEmbedded := ""

cFiltJoin := cEmbedded + FWJoinFilial(cTabela1, cTabela2) + cEmbedded

If ( TCGETDB() $ 'DB2|ORACLE|POSTGRES|INFORMIX' )
	cFiltJoin := STRTRAN(cFiltJoin, "SUBSTRING", "SUBSTR")
EndIf

Return (cFiltJoin)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖcao  ≥fGR106Header  ≥ Autor ≥  Esther Viveiro      ≥ Data ≥ 30/04/2014        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescricaáÖo ≥DefiniÁ„o do cabeÁalho do relatÛrio.                                  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametro ≥oReport    - Obrigatorio - objeto com as informaÁıes do realtÛrio.      ≥±±
±±≥          ≥nImpressao - Obrigatorio - Define qual tipo de impress„o ser· realizada.≥±±
±±≥          ≥          1 = Cabecalho de p·gina; 2 = Cabecalho da seÁ„o sintÈtica.    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥GPER106                                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fGR106Header(oReport,lGper670)

	If cPaisLoc == "MEX" .And. !lGper670
		cTipoContrato := fGetDescTC(nTpContr)
	Else
		cTipoContrato := EVAL({||Iif(nTpContr==1,OemToAnsi(STR0013),Iif(nTpContr==2,OemToAnsi(STR0014),Iif(nTpContr==3 .AND. lDicInter,OemToAnsi(STR0109),CapitalAce(OemToAnsi(STR0108)))))})
	EndIf
	cDescProc := EVAL({||Substr(PosAlias("RCJ",cProcesso,xFilial("RCJ"),"RCJ_DESCRI"),1,20)})
	cDtPeriodo := EVAL({||Dtoc(dDtPerIni)+"-"+Dtoc(dDtPerFim)})

	oReport:SkipLine()
	If !lGper670
		oReport:PrintText(OemToAnsi(STR0012) + cTipoContrato + space(05) + OemToAnsi(STR0016) + cProcesso + ' - ' + cDescProc,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.) //"Tipo de Cotrato"##"Processo"
		oReport:SkipLine()
		oReport:PrintText(OemToAnsi(STR0017) + cPeriodo + space(05) + OemToAnsi(STR0018) + cPagamento + space(05) + OemToAnsi(STR0019) + cDtPeriodo + space(05) + OemToAnsi(STR0020) + DtoC(dDtPago),/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.)//"PerÌodo"##"Pagamento"##"DtPeriodo"##"DtPagto"
		oReport:ThinLine()
		oReport:SkipLine()
	Else
		oReport:PrintText(OemToAnsi(STR0012) + cTipoContrato,/*nRow*/,/*nCol*/,/*nClrText*/,/*cStyle*/,/*nCells*/,.F.) //"Tipo de Cotrato"##"Processo"
	EndIf
	
Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao    ≥ fTotIdFat   ≥ Autor ≥ Leandro Drumond    ≥ Data ≥ 25.11.15 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Totaliza os registros ref. verba id 973 no relatio folha.  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fTotIdFat(cFilAux)

Local aArea			:= GetArea()
Local aTabS033		:= {}
Local cRecFatEmp	:= ""
Local cVb973		:= ""
Local cCodEmpDes	:= ""
Local lGera			:= .F.
Local lRecDesTot	:= .F.
Local nCont		    := 0
Local nFatFol		:= 0
Local nEmpFatTot	:= 0
Local nEmpFatDes	:= 0
Local nEmpFatFol	:= 0
Local nPos			:= 0
Local nProp			:= 0
Local nTpc			:= 0
Local nTotCont		:= 0
Local nPercFat		:= 0
Local cMesAnoOne	:= If (Type("P_FDESFOL") # "U", P_FDESFOL, "")

Private aInssEmp[24][2]

aFilB := {}

If lRatDes
	Return
EndIf

If Funname() == "GPER106" .And. !Empty(cMesAnoOne)
	//Se for chamado pelo GPER040 e a empresa n„o for mais desonerada n„o gera no relatÛrio o ID 0973
	If MV_PAR03 > cMesAnoOne
		Return(Nil)
	Endif
Endif

If !fInssEmp(cFilAux,@aInssEmp,,cPeriodo)
	Return
EndIf

//Verifica se a empresa efetua recolhimento da contribuicao patronal s/ o faturamento
For nTpc := 1 To Len( aInssEmp[27] )
	cRecFatEmp	:= aInssEmp[27, nTpc]//X14_RECFAT
	nPercFat    := If(Len(aInssEmp) >= 33, aInssEmp[33, nTpc], 0)//Percentual sobre faturamento
	If cRecFatEmp $ "S*M*C"
		Exit
	EndIf
Next nTpc

cCodEmpDes	:= FwCodEmp()

//Chama fCarrTab para carregar tabela auxiliar S033
fRetTab( @aTabS033, "S033", , , StoD(cPeriodo+"01"), , .T., cFilAux, .T. )

For nCont := 1 To Len(aTabS033)
	If lCorpManage .And. lEmpFil .And. cCodEmpDes != SubStr( aTabS033[nCont, 2], nStartEmp, nEmpLength )
		Loop
	EndIf
	//Apura a receita bruta total da empresa
	nEmpFatTot += aTabS033[nCont, 7]
	If aTabS033[nCont, 6] == "1"
		//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
		nEmpFatDes += aTabS033[nCont, 7]
	Else
		//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
		nEmpFatFol += aTabS033[nCont, 7]
	EndIf
Next nCont

//Verifica se a receita desonerada da empresa e' superior a 95% do total
lRecDesTot := ( nEmpFatDes / nEmpFatTot >= 0.95 )
/*
⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
≥Somente havera recolhimento sobre o Faturamento se o total nao≥
≥desonerado da empresa for MENOR que 95% do total geral        ≥
¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ*/
lGera := ( cRecFatEmp == "M" .And. ( nEmpFatFol / nEmpFatTot ) < 0.95 )

If lGera .Or. cRecFatEmp $ "S*C"

	//Se a empresa efetua a contribucao s; o faturamento ou misto, verifica se existe o ID 973
	If cRecFatEmp $ "S*M*C"
		cVb973 := fGetCodFol("973")//INSS Empresa s/ Faturamento
        //Verifica se a receita desonerada da empresa e' superior a 95% do total
		If !Empty(cVb973)
			If cRecFatEmp != "S" .And. lRecDesTot
				For nCont := 1 To Len(aTabS033)
					If cFilAux + "1" == aTabS033[nCont, 2] + aTabS033[nCont, 6]
						//Apura o total da contribuicao previdenciaria da filial processada sobre as atividades desonerdas
						nTotCont += aTabS033[nCont, 9]
					ElseIf cFilAux + "2" == aTabS033[nCont, 2] + aTabS033[nCont, 6] .And. aTabS033[nCont, 10] > 0
						//Apura a receita bruta que nao e' sobre as atividades beneficiadas da Lei no. 12.546/2011
						nFatFol += aTabS033[nCont, 7]
					EndIf
				Next nCont
			    //Se a receita bruta da atividade desonerada for maior do que 95% do total devera ser
			    //considerado a receita bruta da atividade nao desonerada.Sera aplicado a proporcionalidade
			    //das aliquotas das atividades desoneradas conforme correspondencia do percentual da receita
			    //desonerada em relacao ao total desonerado
			    //Ex: Cod de atividade X possui receita bruta de 45.000 com aliquota de 1%. A receita bruta
			    //    total de atividade desonerada e' igual a 98.000 e ha 2.000 de atividade nao desonerada.
			    //	  Sera feito a regra de 3 para saber quanto da receita bruta da atividade corresponde
			    //    ao total desonerado. Percentual = 45.000 * 100 / 98.000 = 45,91%. O percentual sera
			    //    aplicado sobre os 2.000 da receita nao desonerada. Sobre o valorencontrado sera
			    //	  aplicado a aliquota correspondente ao codigo da atividade. Esse valor sera somado ao
			    //    que a empresa ja recolhe de contribuicao sobre a atividade desonerada.
				For nCont := 1 To Len(aTabS033)
					If lCorpManage .And. lEmpFil .And. cCodEmpDes != SubStr( aTabS033[nCont, 2], nStartEmp, nEmpLength )
						Loop
					EndIf
					If aTabS033[nCont, 6] == "1"
						//Apura a receita bruta que e' sobre as atividades beneficiadas da Lei no. 12.546/2011
						nBasDes := aTabS033[nCont, 7]

						nProp := ( nBasDes / nEmpFatTot )
						nTotCont += ( nProp * nFatFol ) * ( aTabS033[nCont, 8] / 100 )
					EndIf
				Next nCont
			Else
				//Apura o total da contribuicao previdenciaria da filial processada sobre as atividades desoneradas
				For nCont := 1 To Len(aTabS033)
					If cFilAux + "1" == aTabS033[nCont, 2] + aTabS033[nCont, 6]
						nTotCont += aTabS033[nCont, 9]
					EndIf
				Next nCont
			EndIf
		EndIf
	EndIf

	//Se houve faturamento no periodo e existe a verba com Id 973 cadastrada,
	//adiciona os valores no array de totalizacao
	If nTotCont > 0 .And. !Empty( cVb973 )
		If nPercFat > 0
			nTotCont := ( nTotCont / 100 ) * nPercFat
		EndIf
		If ( nPos := aScan( aFilB,{|X| x[1] == cVb973 } ) ) == 0
			aAdd( aFilB, { cVb973, fDesc("SRV", cVb973, "RV_DESC"), nTotCont} )
		Else
			aFilB[nPos, 3] += nTotCont
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return(Nil)


/*/{Protheus.doc} fAjustFil
Filtra pelas filiais que o usu·rio tem acesso.
@Type Function
@author Gabriel Almeida
@since 13/09/2016
@version 2.0
@return cRet, string com as filiais que o usu·rio possui acesso.
/*/
Static Function fAjustFil(lGper670)

	Local cRet      := " RA_FILIAL IN( "
	Local cFiltFil  := "%" + AllTrim(MV_PAR05) + "%"
	Local cAliasQry := GetNextAlias()
	Local cFilPerm  := fValidFil()

	If lGper670
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel% AND
			RA_FILIAL BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
		EndSql
	ElseIf cFiltFil <> "%%"
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel% AND
			%Exp:cFiltFil%
		EndSql
	Else
		BeginSql Alias cAliasQry
			SELECT DISTINCT SRA.RA_FILIAL AS FILIAL
			FROM %table:SRA% SRA
			WHERE SRA.%notDel%
		EndSql
	EndIf

	DbSelectArea(cAliasQry)
	(cAliasQry)->( DbGoTop() )

	While !( (cAliasQry)->( EOF() ) )
		If (cAliasQry)->FILIAL $ cFilPerm
			cRet += " '" + (cAliasQry)->FILIAL + "', "
		EndIf
		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->( DbCloseArea() )

	cRet += " '' )"

Return( cRet )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥Gpr106Afas≥ Autor ≥ M. Silveira           ≥ Data ≥ 13/02/17 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Busca a situacao do funcionario. - ANALITICO                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ GPER106                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ/*/
Static Function Gpr106Afas( cFilMat, cCodMat, dDtIniP, dDtFimP )

Local nX		:= 0
Local nReg		:= 0
Local cSitu		:= ""
Local cRet		:= ""
Local aAux  	:= {}
Local aArea 	:= GetArea()
Local aSitFunc  := RetSituacao( cFilMat, cCodMat, .F., dDtFimP, , , ,dDtIniP )

If Len(aSitFunc) > 0

		Do Case			
			Case aSitFunc[1] == "T"
				cSitu := STR0105 //"TRANSFERIDO"
			Case aSitFunc[1] == "D" .and. aSitFunc[4] <= dDtPerFim
				cSitu := STR0106 //"DEMITIDO"
			OtherWise
				cSitu := STR0107 //"NORMAL"
		EndCase

	If aSitFunc[1] $ "A/F"

		aAfast	:= {}
		fRetAfas( dDtIniP, dDtFimP,,,,, @aAux )
		nReg := Len(aAux)

		If nReg > 0
			For nX := 1 To nReg
				Do Case
					Case aAux[nX][5] == "A"
						cSitu := STR0103 //AFASTADO
					Case aAux[nX][5] == "F"
						cSitu := STR0104 //FERIAS
				EndCase
				If nX == 1
					cRet := cSitu + " - " + STR0017 + dToC(aAux[nX][3]) + " a " + dToC(aAux[nX][4]) //Periodo:
				Else
					cRet += " / " + cSitu + " - " + STR0017 + dToC(aAux[nX][3]) + " a " + dToC(aAux[nX][4])
				EndIf
			Next nX
		EndIf
	Else
		cRet := cSitu
	EndIf

EndIf

RestArea( aArea )

Return(cRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ FSubst        ≥ Autor ≥ Cristina Ogura   ≥ Data ≥ 17/09/98 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Funcao que substitui os caracteres especiais por espacos   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ FSubst()                                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ GPEM610                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FSubst(cTexto)
Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""
Local nTamTxt := Len(cTexto)
Local j
Local nPos

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho≥
//≥ maximo possivel para visualizacao dos mesmos.                                        ≥
//≥ Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252),".";
			}

aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u"," ";
			}

For j:=1 To Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Nao pode sair com 2 espacos em branco.    ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	cAux	:=Space(01)
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar
Next j

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Volta o texto no tamanho original         ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return(cImpLin)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ApuraSit        ≥ Autor ≥ Oswaldo L.   ≥ Data ≥ 07/10/17   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥  Identifica situacao dos funcionarios - SINTETICO          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function ApuraSit(cCpoDelim, cCpoViewG, cGroupED,  cJoinAux,  cFiltro,   cPagamento, cRoteiro, ;
                         cPeriodo,  cProcesso, cTpcQuery, cCatQuery, cSitQuery, cCpoAlsD,   cExtraD , ;
                         cGroupEC,  cJoinC,    cJoinD,    cCpoAlsC,  cExtraC,   cCpoView ,  cCpoAdView ,lGper670)
Local aSitFunc 	:= {}
Local nInd     	:= 0
Local nInd2    	:= 0
Local nInd3    	:= 0
Local nInd4    	:= 0
Local cWhere1	:= "%%"
Local cWhere2	:= "%%"
Local cDtPerFim := DtoS(dDtPerFim)
Local lSit106	:= ExistBlock("SitFol106")

DEFAULT lGper670 := .F.

If !lGper670
	cWhere1 := "% AND SRC.RC_PROCES =  '" + Upper(cProcesso) +"'   AND "
	cWhere1 += " SRC.RC_ROTEIR =   '" + Upper(cRoteiro) + "' %"

	cWhere2 := "% AND SRD.RD_PROCES =   '" + Upper(cProcesso)+"'  AND "
	cWhere2 += " SRD.RD_ROTEIR =   '" + Upper(cRoteiro)+"'  %"
EndIf

	BeginSql alias cSitAliasQry

			SELECT	tView.FILIAL, tView.MAT, tView.CC

			FROM
			(
				SELECT 	SRA.RA_FILIAL FILIAL, SRA.RA_MAT MAT , SRA.RA_CC CC

				FROM  %table:SRA% SRA
				INNER JOIN %table:SRC% SRC
				ON 		SRA.RA_MAT    = SRC.RC_MAT AND
			        SRA.RA_FILIAL = SRC.RC_FILIAL %exp:cJoinC%
				WHERE 	( 
							SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) OR
						  ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA > %exp:cDtPerFim% AND ' ' IN (%exp:Upper(cSitQuery)%) ) 
						) AND
						SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
						SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
						SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND
						%exp:cWhereSRC%
						SRA.%notDel% %exp:Upper(cFiltro)% AND SRC.%notDel%
						%exp:cWhere1%

				GROUP BY SRA.RA_FILIAL, SRA.RA_MAT  , SRA.RA_CC

				UNION ALL

				SELECT SRA.RA_FILIAL FILIAL, SRA.RA_MAT MAT , SRA.RA_CC CC

				FROM  %table:SRA% SRA
				 INNER JOIN %table:SRD% SRD
			ON 		SRA.RA_MAT    = SRD.RD_MAT AND
			        SRA.RA_FILIAL = SRD.RD_FILIAL %exp:cJoinD%
				WHERE 	( 
							SRA.RA_SITFOLH IN (%exp:Upper(cSitQuery)%) OR
						  ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA > %exp:cDtPerFim% AND ' ' IN (%exp:Upper(cSitQuery)%) ) 
						) AND
						SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND
						SRA.RA_TPCONTR IN (%exp:Upper(cTpcQuery)%) AND
						SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND
						%exp:cWhereSRD%
						SRA.%notDel% %exp:Upper(cFiltro)% AND SRD.%notDel%
						%exp:cWhere2%

				GROUP BY SRA.RA_FILIAL, SRA.RA_MAT , SRA.RA_CC

			) tView

			GROUP BY tView.FILIAL, tView.MAT, tView.CC
	EndSql

aSintTot  := {}
aSintEM   := {}
aSintUN   := {}
aSintCC   := {}
aSintSits := {}
aSintEmp  := {0,0,0,0,0}

While (cSitAliasQry)->(!Eof())

	If aScan(aSintSits, {|x| x[1] == (cSitAliasQry)->(FILIAL) .And. x[2] == (cSitAliasQry)->(MAT) }) == 0

		AAdd ( aSintSits, {(cSitAliasQry)->(FILIAL),(cSitAliasQry)->(MAT)} )

		If aScan(aSintTot, {|x| x[1] == AllTrim((cSitAliasQry)->(FILIAL))  }) == 0
			AAdd ( aSintTot , {Alltrim((cSitAliasQry)->(FILIAL)),0,0,0,0,0}  )
		EndIf

		If lCorpManage
			If aScan(aSintUN, {|x| x[1] == substr((cSitAliasQry)->(FILIAL), nStartUnN, nUnNLength)   }) == 0
				AAdd ( aSintUN , {substr((cSitAliasQry)->(FILIAL), nStartUnN, nUnNLength),0,0,0,0,0}  )
			EndIf

			If aScan(aSintEM,  {|x| x[1] == substr((cSitAliasQry)->(FILIAL),  nStartEmp, nEmpLength)   }) == 0
				AAdd ( aSintEM , {substr((cSitAliasQry)->(FILIAL),  nStartEmp, nEmpLength),0,0,0,0,0}  )
			EndIf
		EndIf

		If aScan(aSintCC,  {|x| x[1] == (cSitAliasQry)->(FILIAL) +(cSitAliasQry)->(CC)  }) == 0
			AAdd ( aSintCC , {(cSitAliasQry)->(FILIAL) +(cSitAliasQry)->(CC),0,0,0,0,0}  )
		EndIf
	EndIf

	aSitFunc := RetSituacao( (cSitAliasQry)->(FILIAL), (cSitAliasQry)->(MAT), .F., dDtPerFim ,,,, dDtPerIni  )

	If lSit106
		// Ponto de entrada para alterar a situaÁ„o do funcion·rio
		SRA->(dbSeek((cSitAliasQry)->(FILIAL) + (cSitAliasQry)->(MAT)))
		aSitFunc := ExecBlock("SitFol106", .F., .F., {aSitFunc, dDtPerIni, dDtPerFim })
	EndIf

	If Len(aSitFunc) > 0
		nInd := aScan(aSintTot, {|x| x[1] == AllTrim((cSitAliasQry)->(FILIAL))  })

		If lCorpManage
			nInd2 := aScan(aSintUN, {|x| x[1] == substr((cSitAliasQry)->(FILIAL), nStartUnN, nUnNLength)  })
			nInd3 := aScan(aSintEM, {|x| x[1] == substr((cSitAliasQry)->(FILIAL),  nStartEmp, nEmpLength)  })
		EndIf

		nInd4 := aScan(aSintCC, {|x| x[1] == (cSitAliasQry)->(FILIAL) +(cSitAliasQry)->(CC)  })

		Do Case
			Case aSitFunc[1] == "A"
				aSintTot[nInd][2] += 1
				aSintEmp[1]       += 1
				If lCorpManage
					aSintUN[nInd2][2] += 1
					aSintEM[nInd3][2] += 1
				EndIf
				aSintCC[nInd4][2] += 1
			Case aSitFunc[1] == "F"
				aSintTot[nInd][3] += 1
				aSintEmp[2]       += 1
				If lCorpManage
					aSintUN[nInd2][3] += 1
					aSintEM[nInd3][3] += 1
				EndIf
				aSintCC[nInd4][3] += 1
			Case aSitFunc[1] == "T"
				aSintTot[nInd][4] += 1
				aSintEmp[3]       += 1
				If lCorpManage
					aSintUN[nInd2][4] += 1
					aSintEM[nInd3][4] += 1
				EndIf
				aSintCC[nInd4][4] += 1
			Case aSitFunc[1] == "D" .and. aSitFunc[4] <= dDtPerFim
				aSintTot[nInd][5] += 1
				aSintEmp[4]       += 1
				If lCorpManage
					aSintUN[nInd2][5] += 1
					aSintEM[nInd3][5] += 1
				EndIf
				aSintCC[nInd4][5] += 1
			OtherWise
				aSintTot[nInd][6] += 1
				aSintEmp[5]       += 1
				If lCorpManage
					aSintUN[nInd2][6] += 1
					aSintEM[nInd3][6] += 1
				EndIf
				aSintCC[nInd4][6] += 1
		EndCase
	EndIf

	(cSitAliasQry)->(DbSkip())
EndDo

(cSitAliasQry)->(DBCloseArea())

return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ MntTots        ≥ Autor ≥ Oswaldo L.   ≥ Data ≥ 07/10/17    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Totalizador dados da situacao do funcionario               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
static function MntTots(cAnaSint, lTotEmp,cTipo,cFilBreak)
Local nIndice := 0
Local cRet    := ''
Local aImp

DEFAULT cTipo := "F"

If cTipo == "F"
	aImp := aSintTot
ElseIf cTipo == "U"
	aImp := aSintUN
ElseIf cTipo == "E"
	aImp := aSintEM
ElseIf cTipo == "C"
	aImp := aSintCC
EndIf
If lTotEmp
	If  Len(aSintEmp) > 0
		cRet := STR0103 + ": "       + Alltrim(STRZERO(aSintEmp[1],7))
		cRet += " " + STR0104 + ": " + Alltrim(STRZERO(aSintEmp[2],7))
		cRet += " " + STR0105 + ": " + Alltrim(STRZERO(aSintEmp[3],7))
		cRet += " " + STR0106 + ": " + Alltrim(STRZERO(aSintEmp[4],7))
		cRet += " " + STR0107 + ": " + Alltrim(STRZERO(aSintEmp[5],7))
		cRet += " " + STR0108 + ": " + Alltrim(STRZERO(aSintEmp[1]+aSintEmp[2]+aSintEmp[3]+aSintEmp[4]+aSintEmp[5],7) )
	EndIf
Else

	If Len(aImp) > 0
		If cTipo == "F"
			If lCorpManage
				nIndice := aScan(aImp, {|x| x[1] == AllTrim(cFilBreak) } )
			Else 
				nIndice := aScan(aImp, {|x| x[1] == substr(cFilBreak, nStartFil, nFilLength) } )
			EndIf
		ElseIf cTipo == "U"
			nIndice := aScan(aImp, {|x| x[1] == substr(cFilBreak, nStartUnN, nUnNLength) } )
		ElseIf cTipo == "E"
			nIndice := aScan(aImp, {|x| x[1] == substr(cFilBreak, nStartEmp, nEmpLength) } )
		ElseIf cTipo == "C"
			nIndice := aScan(aImp, {|x| x[1] == cFilBreak} )
		EndIf
	EndIf

	If nIndice > 0
		cRet := STR0103 + ": "       + Alltrim(STRZERO(aImp[nIndice][2],7))
		cRet += " " + STR0104 + ": " + Alltrim(STRZERO(aImp[nIndice][3],7))
		cRet += " " + STR0105 + ": " + Alltrim(STRZERO(aImp[nIndice][4],7))
		cRet += " " + STR0106 + ": " + Alltrim(STRZERO(aImp[nIndice][5],7))
		cRet += " " + STR0107 + ": " + Alltrim(STRZERO(aImp[nIndice][6],7))
		cRet += " " + STR0108 + ": " + Alltrim(STRZERO(aImp[nIndice][2]+aImp[nIndice][3]+aImp[nIndice][4]+aImp[nIndice][5]+aImp[nIndice][6],7))
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} fVerSituac
Filtra pela situaÁ„o do funcion·rio na Època
@Type Function
@author Leandro Drumond
@since 14/03/2018
@version 1.0
@return LÛgico, se deve ou n„o imprimir a linha
/*/
Static Function fVerSituac(cFilFunc, cMatFunc, cSituacao, dDtIniP, dDtFimP)

Local aSitFunc  := {}
Local lRet 		:= .T.

Static __cSitPad := fSituacao(.F.,.F.)

If !lPerAberto
	If StrTran(cSituacao,"*","") <> __cSitPad
		aSitFunc  := RetSituacao( cFilFunc, cMatFunc, .F., dDtFimP, , , ,dDtIniP )
		If aSitFunc[1] == "D"
			If	( aSitFunc[4] <= dDtIniP .or. (aSitFunc[4] > dDtIniP .and. aSitFunc[4] <= dDtFimP) )
				If !(aSitFunc[1] $ cSituacao)
					lRet := .F.
				EndIf
			ElseIf !(" " $ cSituacao) //Se a demiss„o n„o foi dentro do perÌodo de pesquisa verifica se a situaÁ„o normal foi selecionada
				lRet := .F.
			EndIf
		ElseIf !(aSitFunc[1] $ cSituacao)
			lRet := .F.
		EndIf
	EndIf
EndIf

If !lRet //Reposiciona query de movimento
	While (cAliasQry)->(!Eof()) .And. (cAliasQry)->(RA_FILIAL+RA_MAT) == cFilFunc + cMatFunc
		(cAliasQry)->(DbSkip())
	EndDo
EndIf

Return lRet


/*/{Protheus.doc} fBusTomad
Retorna os dados do centro de custo, caso este seja tomador.
@Type Static Function
@author Henrique Ferreira
@since 20/03/2018
@version 1.0
@return Nil
/*/
Static Function fBusTomad(dDataRef, cCodCC, cDesToma, cCEI, cFilCC)
Local aTransf	:= {}
Local nX		:= 0
Local aArea     := {}
Local cIndexKey := ""

Default cCodCC := SRA->RA_CC
Default cFilCC := SRA->RA_FILIAL

If CTT->(indexkey()) != "CTT_FILIAL+CTT_CUSTO"
	aArea  := GetArea()
	cIndexKey  := CTT->(indexkey())
	CTT->(DbSetOrder( RetOrder( "CTT", "CTT_FILIAL+CTT_CUSTO" ) ))
EndIf

fTransfCc( @aTransf , , .F. , .T. )

CTT->(dbSeek(cFilCC+cCodCC))

cDesToma	:=  fDesc("CTT",cCodCC,"CTT_NOME",,cFilCC)
cCEI        :=  fDesc("CTT",cCodCC,"CTT_CEI",,cFilCC)

For nX := 1 to Len(aTransf)
	cCodCC 	    :=	If( aTransf[nX,07] <= dDataRef,aTransf[nX,06],aTransf[nX,03])
	If !Empty(fDesc("CTT",cCodCC,"CTT_NOME",,cFilCC)) .and. AllTrim(fDesc("CTT",cCodCC,"CTT_RECFAT",,cFilCC)) != "S"
		cDesToma	:= fDesc("CTT",cCodCC,"CTT_NOME",,cFilCC)
		cCEI        := fDesc("CTT",cCodCC,"CTT_CEI",,cFilCC)
	EndIf
Next

Return

/*/{Protheus.doc} fLastSem
Retorna a ˙ltima semana de determinado perÌodo
@Type Static Function
@author Leandro Drumond
@since 15/04/2019
@version 1.0
@return Nil
/*/
Static Function fLastSem( cProcesso, cRoteiro, cPeriodo )
Local cRet := ""

RCH->(DbSetOrder(4)) //RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG

If RCH->(DbSeek(xFilial("RCH") + cProcesso + cRoteiro + cPeriodo))
	While RCH->( !Eof() .and. RCH_PROCES + RCH_ROTEIR + RCH_PER == cProcesso + cRoteiro + cPeriodo )
		cRet := RCH->RCH_NUMPAG
		RCH->(DbSkip())
	EndDo
EndIf

Return cRet

/*/{Protheus.doc} fQuebra
Retorna condiÁ„o de Quebra de Unidade de Negocio
@Type Static Function
@author Emerson Grassi Rocha
@since 13/09/2021
@version 1.0
cxTipo -> 1-Empresa, 2-Unidade Negocio, 3-Filial
@return Nil
/*/
Static Function fQuebra(cFilx, nTipo)
Local cRet 		:= ""
Local cFilArq 	:= If(nAnaSin == 1 .and. Select(cAliasFun) > 0,(cAliasFun)->RA_FILIAL,SRA->RA_FILIAL)
Local lEmpty 	:= Empty(cFilx)

Do CASE
	Case nTipo == 1
		cRet := Substr(Iif(lEmpty, cFilArq, cFilx), nStartEmp, nEmpLength)
	Case nTipo == 2
		cRet := Substr(Iif(lEmpty, cFilArq, cFilx), nStartEmp, nEmpLength) + Substr(Iif(lEmpty, cFilArq, cFilx), nStartUnN, nUnNLength)
	Case nTipo == 3
		cRet := Iif(lEmpty, cFilArq, cFilx)
ENDCASE

Return cRet

Static Function SchedDef()
	
	Local aParam
	Local aOrd := {}
	
	aAdd(aOrd, OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))  //1  - "MatrÌcula + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))  //2  - "Nome + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//3  - "C.Custo Cad. + MatrÌcula + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0005)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//4  - "C.Custo Cad. + Nome + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//5  - "C.Custo Mov. + MatrÌcula + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0006)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//6  - "C.Custo Mov. + Nome + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0002)+"+"+OemToAnsi(STR0004))	//7  - "Depto. + Matricula + LanÁamentos"
	aAdd(aOrd, OemToAnsi(STR0007)+"+"+OemToAnsi(STR0003)+"+"+OemToAnsi(STR0004))	//8  - "Depto. + Nome + LanÁamentos"
	
	aParam := { "R",;      	// Tipo R para relatorio P para processo
				"GPE106R4",;// Pergunte do relatorio, caso nao use passar ParamDef
				"",;  		// Alias
   				aOrd,;   	// Array de ordens
				OemToAnsi(STR0001),;        // TÌtulo (para RelatÛrio)
				"",;		// Nome do relatÛrio (par‚metro 1 do mÈtodo new da classe TReport)
				.T.,;		// LÛgico, indica se permite que o agendamento possa ser cadastrado como sempre ativo. Quando n„o enviado, o default È .F. 
				.T.}		// LÛgico, indica que o agendamento pode ser realizado por filiais. Quando n„o enviado, o default È .F.
	
Return aParam

/*/{Protheus.doc} fGetDescTC
	FunciÛn utilizada para obtener la descripciÛn en SX5 de la tabla VY - Tipos de Contrato.
	@type  Static Function
	@author marco.rivera
	@since 13/02/2024
	@version 1.0
	@param cTpContr, Char, Tipo de Contrato
	@return cDescRet, Char, DescripciÛn del Tipo de Contrato
	@example
	fGetDescTC(cTpContr)
/*/
Static Function fGetDescTC(cTpContr)

	Local cDescRet 	:= STR0108 //"TODOS"
	Local aRetSX5	:= {}

	If !Empty(cTpContr)
		aRetSX5 := FWGetSX5("VY", cTpContr, "es")
		If Len(aRetSX5) > 0
			cDescRet := RTrim(aRetSX5[1,4]) //DescripciÛn
		EndIf
	EndIf
	
Return cDescRet

/*/{Protheus.doc} fGetExpTpC
	FunciÛn utilizada para crear expresiÛn con todas las claves
	de contratos en la tabla VY - Tipos de Contrato en SX5.
	@type  Static Function
	@author marco.rivera
	@since 13/02/2024
	@version 1.0
	@return cExpTipCon, Char, ExpresiÛn con los Tipos de Contrato.
	@example
	fGetExpTpC()
/*/
Static Function fGetExpTpC()

	Local cExpTipCon	:= ""
	Local aRetSX5		:= {}
	Local nIteracion	:= 0
	
	aRetSX5 := FWGetSX5("VY") //Obtiene registros de la tabla VY - Tipos de Contrato

	If Len(aRetSX5) > 0
		For nIteracion := 1 To Len(aRetSX5)
			cExpTipCon += "'" + RTrim(aRetSX5[nIteracion, 3]) + "', " //Clave
		Next nIteracion
	EndIf
	
Return cExpTipCon
