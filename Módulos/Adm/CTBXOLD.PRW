#include "PROTHEUS.CH"
#include "ERROR.CH"
#include "CTBXOLD.CH"


STATIC aSitEsp
STATIC aOutraInsc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณSitEsp    ณ Autor ณEduardo Nunes Cirqueiraณ Data ณ 27/08/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณApresenta tela para escolha da Situacao Especial na geracao ณฑฑ
ฑฑณ          ณdo SPED Contabil.                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณLogico                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function SitEsp()

Local 	aSitEsp := {	{"Z","Normal"}		 	,; 
					{"0","Abertura"}	 	,;
					{"1","Cisใo"}		 	,;
					{"2","Fusใo"}		 	,;
					{"3","Incorpora็ใo"}	,;
					{"4","Extin็ใo"}	}		
Local lOk

lOk := CtbOpcSX5(aSitEsp)

Return lOk


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSitEspConsบAutor  ณEduardo Nunes Cirqueira บ Data ณ  27/08/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorno para consulta padrao CTBSP1 acima                       บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SitEspCons()
Local cVar := Upper( Alltrim( ReadVar() ) )
Return (M->&(cVar))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณOutraInscrณ Autor ณEduardo Nunes Cirqueiraณ Data ณ 27/08/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณApresenta tela para escolha de Outras Inscricoes na geracao ณฑฑ
ฑฑณ          ณdo SPED Contabil.                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณLogico                                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณNenhum                                                      ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function OutraInscr()

Local 	aOutraInsc := {	{"00","Nใo hแ"}		 							,;
					{"01","Banco Central do Brasil/BACEN"}				,;
					{"02","Superintend๊ncia de Seguros Privados/SUSEP"}	,;
					{"03","Comissใo de Valores Mobiliแrios/CVM"}		,;
					{"04","Secretaria de Previd๊ncia complementar"}	}
Local lOk

lOk := CtbOpcSX5(aOutraInsc)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณOutraInConsบAutor  ณEduardo Nunes Cirqueira บ Data ณ 27/08/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRetorno para consulta padrao CTBSP2 acima                       บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OutraInCons()
Local cVar:= Upper( Alltrim( ReadVar() ) )

Return (M->&(cVar))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบFuncao    ณExistSitEspบAutor  ณEduardo Nunes Cirqueira บ Data ณ 27/08/07   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do parametro "Situacao Especial"                      บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Conteudo do parametro                                          บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExistSitEsp(cConteudo)

Local lRet := .T.

If ! (cConteudo $ "Z01234")
	Help(" ",1,"CT5SEM1",,STR0001+": "+STR0002,1,0)//	"Situacao Especial"##"Conteudo Invalido. Pressione F3 e veja as opcoes para este campo.")
	lRet := .F.
EndIf
     
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtbOpcSX5 บAutor  ณAlvaro Camillo Neto บ Data ณ  23/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que simula o comportamento da tela de SX5            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Generico                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function CtbOpcSX5(aPars)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local oListBox
Local oPanel
Local cVar	    := Upper( Alltrim( ReadVar() ) )
Local cConteudo := ""
Local cCodigo   := ""
Local nPosList  := 0
Local lOk		:= .F.

cConteudo := &(ReadVar())
If !Empty(cConteudo)
	nPosList := ASCAN(aPars, {|aVal| aVal[1] == Upper(cConteudo)})
EndIf


DEFINE MSDIALOG oDlg FROM 00,00 TO 290,490 PIXEL TITLE OemToAnsi("Pesquisa") //"Pesquisa"

oPanel := TPanel():New(1,1,'',oDlg,oDlg:oFont, .T., .T.,,,204,140,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

@ 0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{STR0003,STR0004},,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)  //"Codigo"###"Outras Inscricoes"
oListBox:SetArray(aPars)
oListBox:bLine := { ||{aPars[oListBox:nAT][1],aPars[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
oListBox:Align := CONTROL_ALIGN_ALLCLIENT

@ 115,05 BUTTON oConf Prompt STR0005 SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.T.,cCodigo:=aPars[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL //'Confirma'
@ 115,55 BUTTON oCanc Prompt STR0006 SIZE 45 ,10   FONT oDlg:oFont ACTION (lOk:=.F.,oDlg:End())  OF oDlg PIXEL //'Cancela'

If nPosList > 0
	oListBox:nAT   := nPosList
	oListBox:bLine := { ||{aPars[oListBox:nAT][1],aPars[oListBox:nAT][2]}}
	oConf:SetFocus()
EndIf

ACTIVATE MSDIALOG oDlg CENTERED

If lOk
	M->&(cVar) := cCodigo	
Else
	M->&(cVar) := cConteudo
EndIf

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบFuncao    ณExistOutrInsบAutor  ณEduardo Nunes Cirqueira บ Data ณ 27/08/07  บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณValidacao do parametro "Outras Inscricoes"                      บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ Conteudo do parametro                                          บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณLogico                                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ExistOutrIns(cConteudo)

Local lRet := .T.

If ! (cConteudo $ "00#01#02#03#04")
	Help(" ",1,"CT5SEM2",,STR0004+": "+STR0002,1,0)//	"Outras Inscricoes"##"Conteudo Invalido. Pressione F3 e veja as opcoes para este campo."
	lRet := .F.
EndIf
     
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณElton da C. Santana บ Data ณ  14/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com a das inicial e a data final da apura็ใo  บฑฑ
ฑฑบ          ณde acordo com o periodo informado.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function dtIniFin(tpPeriodo, cAno)
Local aDtIniFin := {CTOD("  /  /  "),CTOD("  /  /  ")}
Local dtIni     := CTOD("  /  /  ")
Local dtFim 	:= CTOD("  /  /  ")

If tpPeriodo=="A00"
	dtIni  := CTOD("01/01/"+cAno)
   	dtFim := CTOD("31/12/"+cAno)
   	aDtIniFin[1] := dtIni
   	aDtIniFin[2] := dtFim
   	
	ElseIf tpPeriodo=="T01"
		dtIni  := CTOD("01/01/"+cAno)
   		dtFim  := CTOD("31/03/"+cAno)
   		aDtIniFin[1] := dtIni
   		aDtIniFin[2] := dtFim

	ElseIf tpPeriodo=="T02"          
		dtIni  := CTOD("01/04/"+cAno)
   		dtFim  := CTOD("30/06/"+cAno)
		aDtIniFin[1] := dtIni
   		aDtIniFin[2] := dtFim
	ElseIf tpPeriodo=="T03"
		dtIni  := CTOD("01/07/"+cAno)
	   	dtFim  := CTOD("30/09/"+cAno)
	   	aDtIniFin[1] := dtIni
   		aDtIniFin[2] := dtFim

	ElseIf tpPeriodo=="T04"
		dtIni  := CTOD("01/10/"+cAno)
	   	dtFim  := CTOD("31/12/"+cAno)
	   	aDtIniFin[1] := dtIni
	   	aDtIniFin[2] := dtFim
	Else
      	dtIni     := CTOD("  /  /  ")
		dtFim     := CTOD("  /  /  ")
		aDtIniFin[1] := dtIni
	   	aDtIniFin[2] := dtFim
EndIf


return aDtIniFin


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณElton da C. Santana บ Data ณ  18/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a valida็ใo dos campos preenchidos pelos usuแrios    บฑฑ
ฑฑบ          ณ									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fContVld(aParamFco)
Local aContRef  := {}
Local aConoutR 	:= {}
Local aCtbMoeda := {} // Moeda?
Local lAbort   	:= .F. 
Local nCont
Local cContaIni := aParamFco[2][1]
Local cContaFim := Iif( !Empty( aParamFco[2][2] ) , aParamFco[2][2] , Replicate( "Z" , 20 ) )

aAdd(aConoutR, "Parametros do Wizard" )

//valida se o ano de apura็ใo foi preenchido
If Empty(aParamFco[1][1])
	aAdd(aConoutR, Padr( "Ano de Apura็ใo" , 28 , "" ) + " --> Parโmetro nใo preenchido" )
EndIf

If SUBSTRING(aParamFco[1][2],1,1) != "Z" .And. (Empty(_aTotal[001]) .Or. Empty(_aTotal[002]))
	aAdd(aConoutR, Padr( "Data Escritura็ใo" , 28 , "" ) + " --> Data inicial e/ou final obrigat๓ria, devido a Sit. Especial ser diferente de Z-Normal" )	
EndIf
//Se o Tipo de escritura็ใo estiver como sim o campo Recibo Anterior deve ser preenchido
If SUBSTRING(_aTotal[037][1][3],1,1)=="1" .And. Empty(aParamFco[1][5])
   aAdd(aConoutR, Padr( "N๚mero do Recibo" , 28) + " --> O tipo de Escritura็ใo estแ marcado como retificadora," )
   aAdd(aConoutR, Padr( "                " , 28) + " --> sendo assim, o campo N๚mero do Recibo anterior deve ser preenchido ")
Endif

//valida se o tipo de saldo foi preenchido ou existente
If Empty(aParamFco[2][4])
	aAdd(aConoutR, Padr( "Tipo de Saldo Balancete" , 28 ) + " --> Parโmetro nใo preenchido" )
ElseIf !VldTpSald( aParamFco[2][4] )
	aAdd(aConoutR, Padr( "Tipo de Saldo Balancete" , 28 ) + " --> Nใo existe")
EndIf

//valida se conta de apura็ใo foi preenchido
If Empty(aParamFco[3][1])
   aAdd(aConoutR, Padr( "Conta de Apura็ใo" , 28 ) + " --> Parโmetro nใo preenchido")
EndIf 

aCtbMoeda := CtbMoeda(aParamFco[2][3])

//valida se a moeda foi preenchido ou existente
If Empty(aParamFco[2][3])
   aAdd(aConoutR, Padr( "Moeda" , 28 ) + " --> Parโmetro nใo preenchido")
Endif

If Empty(aCtbMoeda[1])
	aAdd(aConoutR, Padr( "Moeda" , 28 ) + " --> Nใo existe")
Endif

//valida se a data de apura็ใo foipreenchido
If Empty(aParamFco[3][3])
   aAdd(aConoutR, Padr( "Data L/P" , 28 ) + " --> Parโmetro nใo preenchido")
EndIf 

//verifica se a conta analitica possui conta referencial
If SUBSTRING(aParamFco[1][4],1,2) != "00"
	aContRef := CtaRefVld(cContaIni,cContaFim) 
EndIf

If SUBSTRING(aParamFco[4][1],1,1)=="1"
	//valida se o tipo de saldo de espurgo
	If Empty(aParamFco[4][2])
		aAdd(aConoutR, Padr( "Tipo de Saldo de Expurgo" , 28 ) + " --> Parโmetro nใo preenchido" )
	ElseIf !VldTpSald( aParamFco[4][2] )
		aAdd(aConoutR, Padr( "Tipo de Saldo de Expurgo" , 28 ) + " --> Nใo existe")
	EndIf 

	//valida se o tipo de saldo de inclusao
	If Empty(aParamFco[4][3])
		aAdd(aConoutR, Padr( "Tipo de Saldo de Inclusใo" , 28 ) + " --> Parโmetro nใo preenchido" )
	ElseIf !VldTpSald( aParamFco[4][3] )
		aAdd(aConoutR, Padr( "Tipo de Saldo de Inclusใo" , 28 ) + " --> Nใo existe")
	EndIf 
	
	If !Empty(aParamFco[4][2]) .And. !Empty(aParamFco[4][3])
		If aParamFco[4][2] == aParamFco[4][3]
			aAdd(aConoutR, Padr( "Tipo de Saldo de Expurgo e Inclusใo" , 40 ) + " --> Os parโmetros nใo podem ser iguais")
		EndIf     
	EndIf 
	
EndIf



//verifica se a conta analitica possui conta referencial
If ! Empty(aContRef)
	aAdd(aConoutR, " " )
	aAdd(aConoutR, "Valida็ใo do Plano de Contas" )
	For nCont := 1 to Len(aContRef)
		aAdd(aConoutR, aContRef[nCont])
	Next
EndIf

lAbort := ( Len( aConoutR ) > 1 )

If lAbort
	CtRConOut(aConoutR)
EndIf

Return lAbort  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ          บAutor  ณElton da C. Santana บ Data ณ  18/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se as contas analiticasดpossuem contas referenciais  บฑฑ
ฑฑบ          ณ									                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtaRefVld(cContaIni, cContaFim)
Local aContRef := {}
Local cQuery   := ""

DEFAULT cContaIni := Space(20)
DEFAULT cContaFim := Replicate( "Z" , 20 )

cQuery := "SELECT CT1.CT1_CONTA, CT1.CT1_DESC01, 'CONTA CONTABIL SEM REFERENCIAL' AS MSG "
cQuery += "  FROM " + RetSQLTab( "CT1" )
cQuery += " WHERE " + RetSQLCond( "CT1" )
cQuery += "   AND CT1.CT1_CLASSE = '2'"
cQuery += "   AND CT1.CT1_NTSPED != '05'"
cQuery += "   AND CT1.CT1_NTSPED != '09'"
	
IF cContaIni == cContaFim
	cQuery += " AND CT1_CONTA = '" + cContaIni + "'"
Else
	IF !Empty( cContaIni ) 
		cQuery += " AND CT1_CONTA >= '" + cContaIni + "'"
	Endif
	IF !Empty( cContaFim )
		cQuery += " AND CT1_CONTA <= '" + cContaFim + "'"
	Endif
Endif

cQuery += " AND NOT EXISTS(" 
cQuery += "                 SELECT R_E_C_N_O_ "
cQuery += "                   FROM " + RetSQLTab( "CVD" ) + " "
cQuery += "                  WHERE CVD.CVD_FILIAL = '"+xFilial("CVD")+"'"
cQuery += "                    AND CT1.CT1_CONTA = CVD.CVD_CONTA "
cQuery += "                    AND CVD.D_E_L_E_T_ = ' '"
cQuery += "                )"

cQuery := ChangeQuery( cQuery )
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMPQRYREF",.T.,.T.)

DbSelectArea( 'TMPQRYREF' )
TMPQRYREF->(DbGoTop())

While TMPQRYREF->( ! Eof() )

	aAdd(aContRef, TMPQRYREF->CT1_CONTA + " - " + TMPQRYREF->CT1_DESC01 + " --> " +  TMPQRYREF->MSG )
	
	DbSelectArea( 'TMPQRYREF' )
	TMPQRYREF->(DbSkip())
ENDDO

  
Return aContRef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณFcontFilial บAutor ณElton da C. Santana บ Data ณ 20/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณretorna as Filiais selecionadas 		  					  บฑฑ
ฑฑบ          ณ                                                			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FcontFilial(aFilSel)

Local aArea  	:= GetArea()
Local aRetFil 	:= {}
Local i 		:= 0

Default aFilSel := {}
                
For i := 1 To Len(aFilSel)
    If aFilSel[i][1]
    	Aadd(aRetFil,aFilSel[i][2])
    EndIf 
Next   

RestArea(aArea)

Return aRetFil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหอออออัอออออออออออปฑฑ
ฑฑบPrograma  ณLctoCtaXCustoบAutor  ณElton da C. Santana บData ณ23/06/10   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสอออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se o C.Custo existe para amarra็ใo da Conta x 	  บฑฑ
ฑฑบ          ณConta Ref.                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FCONT.INI                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LctoCtaXCusto(cConta, cCusto  )
Local aArea  	:= GetArea() 
Local cQuery	:= ""
Local cAliasProc:= ''
Local lRet		:= .F.

// Inicializa o processamento
cQuery := "SELECT COUNT(*) CONTCVD FROM "+RetSqlName("CVD")+" ";
+" WHERE CVD_FILIAL = '"+xFilial("CVD")+"' ";
+" AND D_E_L_E_T_ = ' ' ";
+" AND CVD_CONTA = '"+cConta+"' ";
+" AND CVD_CUSTO = '"+cCusto+"' "
	
cQuery := ChangeQuery( cQuery )
	
cAliasProc := GetNextAlias()
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasProc,.T.,.T.)
	
If (cAliasProc)->CONTCVD >0
	lRet := .T.
EndIf
	
If Select( cAliasProc ) > 0
	DbSelectArea( cAliasProc )
	dbCloseArea()
EndIf
									
RestArea(aArea)

Return lRet






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtJobInd บAutor  ณAlvaro Camillo Neto บ Data ณ  25/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Job                                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtJobInd(cEmpX,cFilDe,cFilAte,cAnoMes,cSaldo,cSetOfBook,cAliasTRB,cMoedaDe,cMoedaAte)

Local lRet		 := .T.

DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

//Seta job para nao consumir licensas
RpcSetType(3)
RpcClearEnv()
// Seta job para empresa filial desejada
RpcSetEnv( cEmpX,cFilDe,,,,,)

lRet := CtGerInd(cAnoMes,cSaldo,cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtGerInd บAutor  ณAlvaro Camillo Neto  บ Data ณ  25/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo geradora de saldos mensais baseado na visใo gerenci บฑฑ
ฑฑบ          ณ al                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CtGerInd(cAnoMes,cSaldo,cSetOfBook,cAliasTRB,cFilDe,cFilAte,cMoedaDe,cMoedaAte)
Local lRet := .T.
Local aSM0 := Iif( FindFunction( "AdmAbreSM0" ) , AdmAbreSM0() , {} )
Local nContFil := 0
Local aStruSQL	:= {}
Local cChave	:= "EMPRESA+FILIAL+DTOS(DATAMOV)+MOEDA+CONTA"
Local aRegs		:= 0
Local cFilOri	:= cFilAnt
Local nX		   := 0
Local nZ			:= 0
Local nMoedas	:= 0
Local aMoedas	:= {}
Local nFator

Default cSaldo	:= '1'
DEFAULT cFilDe		:= cFilAnt
DEFAULT cFilAte		:= cFilAnt
DEFAULT cMoedaDe	:= '01'
DEFAULT cMoedaAte	:= '01'

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	Return .F.
Endif

//Array de Moedas
nMoedas	:= CtbMoedas()

If Empty(cMoedaDe)
	cMoedaDe := '01'
EndIf

For nX := 1 to nMoedas
	cMoeda := StrZero(nX,2)
	If cMoeda >= cMoedaDe .And. cMoeda <= cMoedaAte 
		aAdd(aMoedas,cMoeda)
	EndIf
Next nX

//Cria Tabela Temporแria
AADD(aStruSQL,{"EMPRESA","C",02,00})
AADD(aStruSQL,{"FILIAL","C",TamSx3("CT1_FILIAL")[1],00})
AADD(aStruSQL,{"DATAMOV","D",08,00})
AADD(aStruSQL,{"MOEDA","C",TamSx3("CT2_MOEDLC")[1],00})
AADD(aStruSQL,{"CONTA","C",TamSx3("CT1_CONTA")[1],00})
AADD(aStruSQL,{"DESCRICAO","C",TamSx3("CT1_DESC01")[1],00})
AADD(aStruSQL,{"SALDOATU","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOACM","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDODEB","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOCRD","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOATU2","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"SALDOANT","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})
AADD(aStruSQL,{"MOVIMENTO","N",TamSx3("CT7_ATUDEB")[1],TamSx3("CT7_ATUDEB")[2]})

If Select(cAliasTRB) > 0
	(cAliasTRB)->(dbCloseArea())
EndIf

MsErase(cAliasTRB)
MsCreate(cAliasTRB, aStruSQL, 'TOPCONN' )
Sleep(1000)
dbUseArea( .T., 'TOPCONN', cAliasTRB, cAliasTRB, .T., .F. )
//Cria o Indice
IndRegua(cAliasTRB,cAliasTRB,cChave,,)

For nContFil := 1 to Len(aSM0)
	If aSM0[nContFil][SM0_CODFIL] < cFilDe .Or. aSM0[nContFil][SM0_CODFIL] > cFilAte .Or. aSM0[nContFil][SM0_GRPEMP] != cEmpAnt
		Loop
	EndIf
	cFilAnt := aSM0[nContFil][SM0_CODFIL]
	
	For nZ := 1 To Len(aMoedas)
		aRegs := GetSldInd( cAnoMes, cSetOfBook , aMoedas[nZ], aMoedas[nZ] , , cSaldo , , , .T., .T., , .T.)
		             
		For nX := 1 to Len(aRegs)
			nSaldoAtual := aRegs[nX][3] - aRegs[nX][4] // Debito - Credito
			nSaldoACM   := aRegs[nX][5]
			nFator		:= 1
			
			If aRegs[nX][9] == '1' // Conta Natureza Devedora 
				nSaldoAtual :=	nSaldoAtual
				nSaldoACM   := -1 * (nSaldoACM)	
				nFator		:= -1
			EndIf
			
			If aRegs[nX][9] == '2' // Conta Natureza Credora
				nSaldoAtual :=	-1 * nSaldoAtual
				nSaldoACM   := (nSaldoACM)	
			EndIf
			
			If (cAliasTRB)->(MsSeek(cEmpAnt + cFilAnt + DToS(aRegs[nX][1]) + aMoedas[nZ] + aRegs[nX][2] ))
				RecLock(cAliasTRB,.F.)
				(cAliasTRB)->SALDOATU += nSaldoAtual 
				(cAliasTRB)->SALDOACM += nSaldoACM
				(cAliasTRB)->SALDOANT  += nFator * aRegs[nX][10]
				(cAliasTRB)->SALDODEB  += nFator * aRegs[nX][3]
				(cAliasTRB)->SALDOCRD  += nFator * aRegs[nX][4]
				(cAliasTRB)->SALDOATU2 += nFator * aRegs[nX][5]
				(cAliasTRB)->MOVIMENTO += nFator * aRegs[nX][11]
				MsUnlock()
			Else
				RecLock(cAliasTRB,.T.)
				(cAliasTRB)->EMPRESA := cEmpAnt
				(cAliasTRB)->FILIAL  := cFilAnt
				(cAliasTRB)->DATAMOV :=	aRegs[nX][1]
				(cAliasTRB)->MOEDA   := aMoedas[nZ]
				(cAliasTRB)->CONTA   := aRegs[nX][2]
				(cAliasTRB)->DESCRICAO:= aRegs[nX][6]
				(cAliasTRB)->SALDOATU := nSaldoAtual 
				(cAliasTRB)->SALDOACM := nSaldoACM 
				(cAliasTRB)->SALDOANT  := nFator * aRegs[nX][10]
				(cAliasTRB)->SALDODEB  := nFator * aRegs[nX][3]
				(cAliasTRB)->SALDOCRD  := nFator * aRegs[nX][4]
				(cAliasTRB)->SALDOATU2 := nFator * aRegs[nX][5]
				(cAliasTRB)->MOVIMENTO := nFator * aRegs[nX][11]
				MsUnlock()
			EndIf
		Next nX
	Next nZ
	
Next nContFil

cFilAnt := cFilOri

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetSldInd   บAutor ณAlvaro Camillo Neto    บ Data ณ 26/08/10บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o saldo das vis๕es gerenciais de varios perํodos    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function GetSldInd(cAnoMes, cSetOfBook, cMoeda, cMoedaDesc, lConsSaldo, cSaldos,;
cHeader, dDataLP, lVlrZerado, lMovPeriodo, lPlGerSint, lNImpMov, lImpAntLP)

Local nX          := 01
Local lAbs       := .F.
Local lTdsRgs    := .T.
Local nTmArray   := 00
Local aRetOrig   := {}
Local aCTSArea   := {}
Local aSetOfBook := CtbSetOf(cSetOfBook)
Local aRetorno	  := {}
Local dDtIni
Local dDtFim
Default cMoeda      := '01'
Default cMoedaDesc  := '01'
Default lConsSaldo  := .F.
Default cSaldos     := '1'
Default cHeader     := ''
Default dDataLP     := Nil
Default lVlrZerado  := .T.
Default lMovPeriodo := .F.
Default lPlGerSint  := .T.
Default lNImpMov    := .T.
Default lImpAntLP   := .F.

//------------------------------------------------------------//
// Localiza o maior codigo da visใo gerencial em questใo      //
//------------------------------------------------------------//
aCTSArea := CTS->(GetArea())
CTS->(DbSetOrder(2))
CTS->(DbSeek(xFilial("CTS")+aSetOfBook[5]+Replicate("Z",TamSx3("CTS_CONTAG")[1]),.T.))
If CTS->CTS_CODPLA != cSetOfBook
	CTS->(DbSkip(-1))
EndIf
nTmArray := Val(CTS->CTS_CONTAG)
CTS->(RestArea(aCTSArea))

//------------------------------------------------------------//
// Carrega array conforme parametros e exclui arrays em branco//
//------------------------------------------------------------//
dDtIni := STOD(cAnoMes+'01')
dDtFim := LastDay(dDtIni)
aRetOrig := GetSldPlGer( cSetOfBook, dDtIni, dDtFim, cMoeda, nTmArray, lAbs, lTdsRgs, cSaldos, lNImpMov, cHeader, lImpAntLP, dDataLP, lVlrZerado, cMoedaDesc, lMovPeriodo, lPlGerSint, lConsSaldo)
For nX := 1 to Len(aRetOrig)
	aAdd(aRetorno,{dDtFim, aRetOrig[nX][1], aRetOrig[nX][2], aRetOrig[nX][3], aRetOrig[nX][4], aRetOrig[nX][5], aRetOrig[nX][6], aRetOrig[nX][7], aRetOrig[nX][8], aRetOrig[nX][9], aRetOrig[nX][10] } )
Next nX

Return(aRetorno)
 