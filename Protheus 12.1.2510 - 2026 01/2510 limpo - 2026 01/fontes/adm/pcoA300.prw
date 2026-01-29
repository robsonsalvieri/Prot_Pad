#INCLUDE "PCOA300.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWLIBVERSION.CH"
// INCLUIDO PARA TRADUÇÃO DE PORTUGAL//

Static __lBlind  := IsBlind()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ Pcoa300 º Autor ³                     º Data ³  06/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de reprocessamento de cubos                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300 - Planejamento e Controle Orcamentario             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Pcoa300(lAuto, aParametros)
Local cFunction		:= "PCOA300"
Local cTitle		:= STR0001	//"Reprocessamento dos Saldos"
Local cDescription	:= STR0002 + CRLF +;		//"  Este programa tem como objetivo recalcular e analisar os saldos dia a dia de um "
					   STR0003 + CRLF + CRLF+;	//"  determinado per¡odo ate a data base do sistema. "
					   STR0004	//"  Utilizado no caso de haver necessidade de entrada de movimentos  retroativos. "
Local bProcess		:= { |oSelf| PCOA300Sld(oSelf) }
Local lRet          := .T.

Local oProcess
Local aInfoCustom 	:= {}
Local cLibLabel 	:= "20240520"
Local lLibSchedule	:= FwLibVersion() >= cLibLabel
Local lSchedule 	:= FWGetRunSchedule()

Private cPerg	  := "PCA300"
Private cCadastro := STR0001 //"Reprocessamento dos Saldos"

DEFAULT lAuto := .F.
DEFAULT aParametros := {}

IF FunName() == 'PCOA300'  //acerta variavel static __lBlind qdo anteriormente foi chamada de outra rotina pcoa301/pcoa302
	__lBlind  := IsBlind()
EndIf

If lAuto .And. Len(aParametros) > 0
	
	MV_PAR01 := aParametros[1]  //Cubo de
	MV_PAR02 := aParametros[2]  //Cubo Ate
	MV_PAR03 := aParametros[3]  //data de 
	MV_PAR04 := aParametros[4]  //data ate
	MV_PAR05 := aParametros[5]  //Considera todos os tipos de saldo 
	MV_PAR06 := aParametros[6]  //Tipo de saldo especifico
	
	__lBlind := .T.
		
	lRet := PCOA300Sld()
	
Else

	If !__lBlind .Or. (lSchedule .And. lLibSchedule)
		oProcess := tNewProcess():New(cFunction, cTitle, bProcess, cDescription, cPerg,;
									  aInfoCustom                    /*aInfoCustom*/  ,;
									  .T.                            /*lPanelAux*/    ,;
									  5                              /*nSizePanelAux*/,;
									  cDescription    				 /*cDescriAux*/   ,;
									  .T.                            /*lViewExecute*/ ,;
									  .F.                            /*lOneMeter*/    ,;
									  .T.                            /*lSchedAuto*/    )
	Else
	 	Eval(bProcess)
	EndIf
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ PCOA300Sld º Autor ³                  º Data ³  06/07/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de reprocessamento de cubos                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300 - Planejamento e Controle Orcamentario             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	
Static Function PCOA300Sld(oSelf)
Local aConfig	:= {,,,}
Local dDataIni	
Local dDataFim	
Local lRet	:=	.T.
Local lRet1	:=	.T.
Local aNivel:= {}
Local aNivelAux := {}
Local iX      := 0
Local nZ:=0
Local nRegua	:= 0
Local aTmpDim 	:={}
Local cTpSld  	:= ""

Local cLibLabel 	:= "20240520"
Local lLibSchedule	:= FwLibVersion() >= cLibLabel
Local lSchedule 	:= FWGetRunSchedule()

//**********************************************
// Controle de atualização de saldo por nivel  *
//**********************************************

If mv_par05 == 2
	cTpSld := "( '"+AllTrim(mv_par06)+"' )"
EndIf

aConfig[1] := MV_PAR01
aConfig[2] := MV_PAR02
aConfig[3] := MV_PAR03
aConfig[4] := MV_PAR04

dDataIni := aConfig[3]
dDataFim := aConfig[4]

If !__lBlind 
	oSelf:Savelog(STR0012)	//"Processamento iniciado."
EndIf	

aTmpDim := {}
AL1->(dbSetOrder(1))
AL1->(dbSeek(xFilial("AL1")+aConfig[1],.T.))
While AL1->(!Eof() .And. AL1_FILIAL+AL1_CONFIG <= xFilial("AL1")+aConfig[2] )
	nRegua++
	aNivel := PcoGeraSup(AL1->AL1_CONFIG,aTmpDim)
	AADD(aNivelAux, {AL1->AL1_CONFIG, aClone(aNivel)})	
	AL1->(dbSkip())
EndDo

//Seta a regua para execução em segundo plano
If lSchedule .And. lLibSchedule
	oSelf:SetRegua1(nRegua)
EndIf

AL1->(dbSetOrder(1))
AL1->(dbSeek(xFilial("AL1")+aConfig[1],.T.))
While AL1->( !Eof() .And. AL1_FILIAL+AL1_CONFIG <= xFilial("AL1")+aConfig[2] )
	
	If lSchedule .And. lLibSchedule
		oSelf:IncRegua1()
	EndIf

	//vERIFICA SE A ESTRUTURA DO CUBO EXISTE	
	AKW->(dbSetOrder(1))
	If !AKW->(dbSeek(xFilial("AKW")+AL1->AL1_CONFIG))		
		AL1->(dbSkip())
		Loop
	EndIf 

	//Bloquear o cubo com RecLock() para ninguem atualiza-lo durante o processamento
	If AL1->(dbRLock())
		//AL1->AL1_STATUS := "2" // em reprocessamento
		PcoCubeStatus("2")			
	Else		
		AL1->(dbSkip())
		Loop
	EndIf
	
	If !__lBlind
		oSelf:SetRegua1(2)
		oSelf:IncRegua1(STR0010+AL1->AL1_CONFIG)//'Selecionando lancamentos para processar o cubo ']
		SysRefresh()
	EndIf
	
	aNivel  := aClone(aNivelAux[Ascan(aNivelAux,{|x|x[1]==AL1->AL1_CONFIG}),2])
	
	lRet := P300CallProc(aNivel, dDataIni, dDataFim, cTpSld, AL1->AL1_CONFIG)
	
	If !__lBlind		
		oSelf:IncRegua1("..."+AL1->AL1_CONFIG)//'Selecionando lancamentos para processar o cubo ']
		SysRefresh()		
	EndIf

	//AL1->AL1_STATUS := "1" // em reprocessamento
	PcoCubeStatus("1")	

	AL1->(dbRUnlock())	
	AL1->(dbSkip())		
Enddo

For nZ := 1 to Len(aNivelAux)
	aNivel := aClone(aNivelAux[nZ,2])
	For iX := 1 to Len(aNivel)     // tabelas com as superiores
		If TcCanOpen(aNivel[iX][2])
			lRet1 := TcDelFile(aNivel[iX][2])
			If !lRet1
				MsgAlert(STR0014+aNivel[iX][2]+STR0015)  //"Erro na exclusao da Tabela: "##". Excluir manualmente"
			Endif
		EndIf
	Next iX
Next nZ

If !__lBlind .Or. (lSchedule .And. lLibSchedule)
	oSelf:Savelog(STR0013) 	//"Processamento encerrado."
EndIf	

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PCOA300Proc³ Autor ³ Alice Yaeko Yamamoto    ³ Data ³06.06.08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria  procedures Pai                                           ³±±
±±³          ³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso     ³ SigaPCO                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ExpC1 = cCubo    - Codigo do Cubo a ser atualizado             ³±±
±±³          ³ExpA1 = aNivel   - Niveis a serem atualizados                  ³±±
±±³          ³ExpC2 = cArq     - Nome da procedure q sera criada no banco    ³±±
±±³          ³ExpA1 = aProc    - Array c procedures                          ³±±
±±³          ³ExpA2 = aProcAKT - Array com as procedures criadas p niveis AKT³±±
±±³          ³ExpC3 = cTpSald  - Tipo do Saldo                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PCOA300Qry(aNivel as Array, dDataIni as Date, dDataFim as Date, cTpSald as Character, cCubo as Character)
Local cAliasAKD as Character
Local cCposQry  as Character
Local cOrderBy  as Character
Local cNivel    as Character
Local cCtaAna   as Character
Local cCtaSup   as Character
Local cFilAKT   as Character
Local nI,nJ 	as Numeric
Local nNiveis   as Numeric
Local aCposNiv  as Array
Local aDataAKT  as Array
Local oDadosCub as Object
Local oBulkAKT  as Object
Local jSupNiv   as JsonObject
Local jTamCpos	as JsonObject
Local jContChv  as JsonObject
Local lRet	    as Logical

Default aNivel   := {}
DEFAULT dDataIni := StoD("")
DEFAULT dDataFim := Stod("")
DEFAULT cTpSald  := ""
DEFAULT cCubo    := ""

jSupNiv   := JsonObject():New()
jTamCpos  := JsonObject():New()
jContChv  := JsonObject():New()
aDataAKT  := {}
lRet := .F.

oDadosCub := PcoCubeInfo():New()

If oDadosCub:SetPCOCubo(cCubo)

	nNiveis  := oDadosCub:GetNiveis()
	aCposNiv := oDadosCub:GetCposNiv()	
	cChvCub  := oDadosCub:GetChvNiv()

	aCampos := P300GtCpos(nNiveis, aCposNiv, @jTamCpos)
	
	oBulkAKT := FwBulk():New(RetSQLName("AKT"))
	oBulkAKT:setFields(aCampos)
	
	cCposQry := "AKD_FILIAL, AKD_TIPO, AKD_DATA"
	cCposQry += oDadosCub:GetCposSel()

	cOrderBy := "AKD_DATA"
	cOrderBy += oDadosCub:GetOrderBy()

	jSupNiv := P300PopJson(aNivel)
	
	//Faz a consulta na AKD
	cAliasAKD := P300GetQry(cTpSald, dDataIni, dDataFim, cCposQry, cOrderBy)

	If !(cAliasAKD)->(Eof())
		//Exclui os registros do cubo no periodo
		lRet := PCODelAKT(cCubo, dDataIni, dDataFim)

		If lRet		

			cFilAKT := xFilial("AKT")
			
			While !(cAliasAKD)->(Eof())

				//Grava analítica
				P300GtData(cAliasAKD, cFilAKT, cChvCub, "1", cCubo, nNiveis, aCposNiv, @jContChv, @aDataAKT)
				
				//Grava superiores (sintética)
				For nI := 1 to nNiveis
					cNivel := StrZero(nI,2)
					If jSupNiv[cNivel] <> Nil
						cCtaAna := &('(cAliasAKD)->('+aCposNiv[nI]+')')
						cCtaAna := AllTrim(cCtaAna)
						cCtaAna := StrTran(cCtaAna,".","-")

						aCtaSup := jSupNiv[cNivel][cCtaAna]
						If aCtaSup <> Nil
							//Grava todos os níveis de superiores (sintética)
							For nJ := 1 to Len(aCtaSup)
								cCtaSup := PadR(aCtaSup[nJ], jTamCpos[cNivel])							
								cChvSup := StrTran(cChvCub,aCposNiv[nI]+"+","'"+cCtaSup+"'+")

								P300GtData(cAliasAKD, cFilAKT, cChvSup, "0", cCubo, nNiveis, aCposNiv, @jContChv, @aDataAKT, cCtaSup, cNivel)
							Next nJ						
						EndIf					
					EndIf				
				Next nI	
				(cAliasAKD)->(DbSkip())
			EndDo

			For nI := 1 to Len(aDataAKT)	
				oBulkAKT:AddData(aDataAKT[nI])				
			Next nI 
		EndIf
	EndIf
	(cAliasAKD)->(dbCloseArea())
	
	oBulkAKT:Close()

	oBulkAKT:Destroy()
	FreeObj(oBulkAKT)

	oDadosCub:Destroy()
	FreeObj(oDadosCub)	

	FreeObj(jSupNiv)
	FreeObj(jTamCpos)
	FreeObj(jContChv)

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³P300CallProcºAutor  ³Microsiga           º Data ³  04/24/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcão responsavel pela chamada das procedures.               º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PCOA300 e PCOA301                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function P300CallProc(aNivel as Array, dDataIni as Date, dDataFim as Date, cTpSld as Character, cCubo as Character) 
Local lRet as Logical

DEFAULT aNivel := {}
DEFAULT dDataIni := Stod("")
DEFAULT dDataFim := Stod("")
DEFAULT cTpSld := ""
DEFAULT cCubo := ""

lRet := PCOA300Qry(aNivel, dDataIni, dDataFim, cTpSld, cCubo)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Retorna os parametros no schedule.

@return aReturn			Array com os parametros

@author  TOTVS
@since   07/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function SchedDef()

Local aParam  := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "PCA300",;		//Pergunte do relatorio, caso nao use passar ParamDef
            ,;				//Alias
            ,;				//Array de ordens
            STR0001,;		//Titulo - "Reprocessamento dos Saldos"
			,;				//Nome do Relatório
			.T.,;			//Indica se permite que o agendamento possa ser cadastrado como sempre ativo
			.T. }			//Indica que o agendamento pode ser realizado por filiais		

Return aParam

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Classe para retornar informações sobre o cubo gerencial.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Class PCOCubeInfo
	DATA cOrderBy as Character
	DATA cSelect  as Character
	DATA cChvCub  as Character
	DATA nNiveis  as Numeric
	DATA aCposNiv as Array	

	Method New() Constructor
	Method SetPCOCubo()
	Method GetOrderBy()
	Method GetCposSel()
	Method GetNiveis()
	Method GetCposNiv()
	Method GetChvNiv()	
	Method Destroy()
EndClass

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método construtor da classe.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method New() Class PCOCubeInfo
	Self:cOrderBy := ""
	Self:cSelect  := ""
	Self:nNiveis  := 0
	Self:aCposNiv := {}
	Self:cChvCub  := ""
Return Self

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método para setar as informações do cubo.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method SetPCOCubo(cCubo as character) Class PCOCubeInfo
Local cCposAKW as Character
Local cCposChv as Character
Local cCposAux as Character
Local aCposAux as Array
Local aCposNiv as Array
Local nI 	   as Numeric
Local nNiveis  as Numeric
Local lRet	   as Logical

DEFAULT cCubo := ""

cCposAKW := ""
cCposChv := ""
cCposAux := ""
aCposAux := {}
aCposNiv := {}
nI	     := 0
nNiveis  := 0
lRet     := .F.

AKW->(dbSetOrder(1))
AKW->(MsSeek(xFilial("AKW")+cCubo))
While !AKW->(Eof()) .And. AKW->(AKW_FILIAL+AKW->AKW_COD) == xFilial("AKW")+cCubo
	
	cCposAux := Alltrim(StrTran(AKW->AKW_CHAVER,"AKD->",""))
	
	If !Empty(cCposChv)
		cCposChv += "+"
	EndIf
	cCposChv += cCposAux

	aAdd(aCposNiv, cCposAux)
	
	aCposAux :=	Str2Arr( Alltrim(AKW->AKW_CHAVER), "+")  //quebra em array por delimitador "+"
	
	If Len(aCposAux) == 1
		cCposAKW += ", " + AllTrim(SubStr(AKW->AKW_CHAVER,6,Len(AKW->AKW_RELAC)))		
	Else
		For nI := 1 to Len(aCposAux)	
			cCposAKW += ", " + Alltrim(StrTran(aCposAux[nI], "AKD->", "")) 			
		Next nI	
	EndIf	

	nNiveis++

	AKW->(DbSkip())
EndDo

If !Empty(cCposAKW)	
	lRet := .T.
	::cOrderBy := cCposAKW
	::cSelect  := cCposAKW
	::nNiveis  := nNiveis-1	
	::aCposNiv := aCposNiv
	::cChvCub  := cCposChv
EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método para retornar o Order By do cubo.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method GetOrderBy() Class PCOCubeInfo
Return ::cOrderBy

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método para retornar os campos de seleção do cubo.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method GetCposSel() Class PCOCubeInfo
Return ::cSelect

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método para retornar o número de níveis do cubo.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method GetNiveis() Class PCOCubeInfo
Return ::nNiveis

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método para retornar os campos de níveis do cubo.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method GetCposNiv() Class PCOCubeInfo
Return ::aCposNiv

//-------------------------------------------------------------------
/*{Protheus.doc} GetChvNiv
Método para retornar a chave dos níveis do cubo.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method GetChvNiv() Class PCOCubeInfo
Return ::cChvCub

//-------------------------------------------------------------------
/*{Protheus.doc} PCOCubeInfo
Método destrutor da classe.
@author  TOTVS
@since   19/11/2025
@version 12
*/
//--------------------------------------------------------------------
Method Destroy() Class PCOCubeInfo
	Self:cOrderBy := nil
	Self:cSelect  := nil
	Self:nNiveis  := nil	
	Self:cChvCub  := nil
	FwFreeArray(Self:aCposNiv)
Return

//-------------------------------------------------------------------
/*{Protheus.doc} P300PopJson
Popula o Json com as contas superiores por nivel.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//-------------------------------------------------------------------
Static Function P300PopJson(aNivel as Array)
Local cQuery 	 as Character
Local cAliasSup  as Character
Local cCtaAnaAnt as Character
Local cCtaAnaAtu as Character
Local cNivel 	 as Character
Local jSupNiv 	 as JsonObject
Local nI 		 as Numeric
Local aCtasSup 	 as Array

DEFAULT aNivel := {}

jSupNiv := JsonObject():New()

For nI := 1 to Len(aNivel)
	cQuery := "SELECT ANALITICA, SUPERIOR FROM "+aNivel[nI][2]
	cAliasSup := GetNextAlias()
	dbUseArea( .T., "TopConn", TCGenQry(,,cQuery),cAliasSup, .F., .F. )

	If !(cAliasSup)->(Eof())
		
		cNivel := aNivel[nI][4]		
		jSupNiv[cNivel] := JsonObject():New()
		aCtasSup := {}
		cCtaAnaAnt := Alltrim(StrTran((cAliasSup)->ANALITICA,".","-"))
		
		While !(cAliasSup)->(Eof())
			cCtaAnaAtu	:= Alltrim(StrTran((cAliasSup)->ANALITICA,".","-"))
			
			If cCtaAnaAnt <> cCtaAnaAtu
				jSupNiv[cNivel][cCtaAnaAnt] := aCtasSup
				aCtasSup := {}				
				cCtaAnaAnt := cCtaAnaAtu 
			EndIf			

			aAdd(aCtasSup, Alltrim((cAliasSup)->SUPERIOR))			

			(cAliasSup)->(dbSkip())
		EndDo		
		jSupNiv[cNivel][cCtaAnaAnt] := aCtasSup
	EndIf
	(cAliasSup)->(dbCloseArea())
Next nI

Return jSupNiv

//-------------------------------------------------------------------
/*{Protheus.doc} P300GtData
Retorna os dados formatados para inserção na AKT.
@author  TOTVS
@since   19/11/2025
@version 12
*/
//-------------------------------------------------------------------
Static Function P300GtData(cAliasQry as Character, cFilAKT as Character, cChvAKT as Character, cClasse as Character, cCubo as Character, nNiveis as Numeric,;
							aCposNiv as Array, jContChv as JsonObject, aDataAKT as Array, cCtaSup as Character, cNivel as Character)
Local aDatRet  as Array
Local nI       as Numeric
Local cTpSald  as Character
Local cChvAux  as Character

DEFAULT cAliasQry := ""
DEFAULT cFilAKT   := ""
DEFAULT cChvAKT   := ""
DEFAULT cClasse   := ""
DEFAULT cCubo     := ""
DEFAULT cCtaSup   := ""
DEFAULT cNivel    := ""
DEFAULT nNiveis   := 0
DEFAULT aCposNiv  := {}
DEFAULT aDataAKT  := {}
DEFAULT jContChv  := Nil

cTpSald := (cAliasQry)->AKD_TIPO
cChvAux := &('(cAliasQry)->('+cChvAKT+')')

aDatRet := {	cFilAKT,;
				cChvAux,;
				DtoS((cAliasQry)->AKD_DATA),;
				cCubo,;
				cClasse,; //1 = Analitica, 0 = Sintetica
				(cAliasQry)->AKD_TPSALD,;
				IIf(cTpSald=="1", (cAliasQry)->AKD_VALOR1, 0),;
				IIf(cTpSald=="1", (cAliasQry)->AKD_VALOR2, 0),;
				IIf(cTpSald=="1", (cAliasQry)->AKD_VALOR3, 0),;
				IIf(cTpSald=="1", (cAliasQry)->AKD_VALOR4, 0),;
				IIf(cTpSald=="1", (cAliasQry)->AKD_VALOR5, 0),;
				IIf(cTpSald=="1", 0, (cAliasQry)->AKD_VALOR1),;
				IIf(cTpSald=="1", 0, (cAliasQry)->AKD_VALOR2),;
				IIf(cTpSald=="1", 0, (cAliasQry)->AKD_VALOR3),;
				IIf(cTpSald=="1", 0, (cAliasQry)->AKD_VALOR4),;
				IIf(cTpSald=="1", 0, (cAliasQry)->AKD_VALOR5)}

For nI := 1 to nNiveis	
	If !Empty(cCtaSup) .and. val(cNivel) == nI
		aAdd(aDatRet, cCtaSup)
	Else
		aAdd(aDatRet, &('(cAliasQry)->('+aCposNiv[nI]+')'))
	EndIf	
Next nI	

cChvAux += DtoS((cAliasQry)->AKD_DATA)

If jContChv[cChvAux] == Nil
	jContChv[cChvAux] := JsonObject():New()
	aAdd(aDataAKT, aClone(aDatRet))
	jContChv[cChvAux] := Len(aDataAKT)
Else
	aDataAKT[jContChv[cChvAux]][7]  += aDatRet[7]
	aDataAKT[jContChv[cChvAux]][8]  += aDatRet[8]
	aDataAKT[jContChv[cChvAux]][9]  += aDatRet[9]
	aDataAKT[jContChv[cChvAux]][10] += aDatRet[10]
	aDataAKT[jContChv[cChvAux]][11] += aDatRet[11]
	aDataAKT[jContChv[cChvAux]][12] += aDatRet[12]
	aDataAKT[jContChv[cChvAux]][13] += aDatRet[13]
	aDataAKT[jContChv[cChvAux]][14] += aDatRet[14]
	aDataAKT[jContChv[cChvAux]][15] += aDatRet[15]
	aDataAKT[jContChv[cChvAux]][16] += aDatRet[16]
EndIf	

Return

//-------------------------------------------------------------------
/*{Protheus.doc} P300GetQry
Retorna o alias com a query preparada para seleção dos saldos.
@author  TOTVS
@since   19/11/2025
@version 12
*/
//-------------------------------------------------------------------
Static Function P300GetQry(cTpSald as Character, dDataIni as Date, dDataFim as Date, cCposQry as Character, cOrderBy as Character)
Local cQuery	as Character
Local nQry		as Numeric
Local aTpSald   as Array
Local lTpSald   as Logical
Local oQueryAKD as Object
Local cAliasAKD as Character

DEFAULT cTpSald := ""
DEFAULT dDataIni := Stod("")
DEFAULT dDataFim := Stod("")
DEFAULT cCposQry := ""
DEFAULT cOrderBy := ""

lTpSald := !Empty(cTpSald)

If lTpSald
	cTpSald := StrTran( Alltrim( cTpSald ) , "(", "")
	cTpSald := StrTran( Alltrim( cTpSald ) , ")", "")
	cTpSald := StrTran( Alltrim( cTpSald ) , "'", "")
	aTpSald := Str2Arr( Alltrim( cTpSald ) , "," )
EndIf

cQuery := " SELECT "+cCposQry+", SUM(AKD_VALOR1) AKD_VALOR1, SUM(AKD_VALOR2) AKD_VALOR2, SUM(AKD_VALOR3) AKD_VALOR3, SUM(AKD_VALOR4) AKD_VALOR4, SUM(AKD_VALOR5) AKD_VALOR5"+CRLF
cQuery += "    FROM "+RetSqlName("AKD")+" AKD "+CRLF
cQuery += "    WHERE AKD_FILIAL = ? "+CRLF
cQuery += "			AND AKD_DATA BETWEEN ? AND ? "+CRLF
cQuery += "			AND AKD_STATUS = ? "+CRLF
cQuery += "       	AND AKD_TIPO IN (?) "+CRLF

If lTpSald
	cQuery += "     AND AKD_TPSALD IN (?) "+CRLF
EndIf

cQuery += "			AND D_E_L_E_T_ = ? "+CRLF
cQuery += "       	AND NOT EXISTS ( SELECT 1 "+CRLF
cQuery += "                          	FROM "+RetSqlName("ALA")+CRLF
cQuery += "                               WHERE ALA_FILIAL = ? "+CRLF
cQuery += "                                 AND ALA_STATUS = ? "+CRLF
cQuery += "                                 AND ALA_RECAKD = AKD.R_E_C_N_O_"+CRLF
cQuery += "                                 AND D_E_L_E_T_ = ? )"+CRLF
cQuery += "		GROUP BY "+cCposQry+CRLF	
cQuery +="		ORDER BY "+cOrderBy

oQueryAKD := FWPreparedStatement():New(cQuery)

nQry := 1
//Qry AKD
oQueryAKD:SetString(nQry++, xFilial('AKD'))
oQueryAKD:SetString(nQry++, DtoS(dDataIni))
oQueryAKD:SetString(nQry++, DtoS(dDataFim))
oQueryAKD:SetString(nQry++, '1')
oQueryAKD:SetIn(nQry++,{'1','2'})
If lTpSald
	oQueryAKD:SetIn(nQry++,aTpSald)
EndIf		
oQueryAKD:SetString(nQry++, ' ')
//Qry ALA
oQueryAKD:SetString(nQry++, xFilial('ALA'))
oQueryAKD:SetString(nQry++, '1')
oQueryAKD:SetString(nQry++, ' ')

cAliasAKD := GetNextAlias()
MPSYSOpenQuery(oQueryAKD:GetFixQuery(), cAliasAKD)
TCSetField(cAliasAKD, "AKD_DATA", "D")

oQueryAKD:Destroy()
freeObj(oQueryAKD)

Return cAliasAKD

//-------------------------------------------------------------------
/*{Protheus.doc} PCODelAKT
Exclui os registros da AKT para o cubo e periodo informados.
@author  TOTVS
@since   19/11/2025
@version 12
*/
//-------------------------------------------------------------------
Static Function PCODelAKT(cCubo as Character, dDataIni as Date, dDataFim as Date)
Local lRet as Logical
Local nI as Numeric
Local nRecMin as Numeric
Local nRecMax as Numeric
Local cQryDel as Character
Local oQryDel as Object
Local cAliasDel as Character
Local cNameAKT as Character
Local cFilAKT as Character
Local nQry as Numeric

DEFAULT cCubo := ""
DEFAULT dDataIni := Stod("")	
DEFAULT dDataFim := Stod("")

lRet := .T.

cNameAKT := RetSqlName('AKT')
cFilAKT := xFilial('AKT')

cQryDel	:=	" SELECT Min(R_E_C_N_O_) MINRECNO, MAX(R_E_C_N_O_) MAXRECNO "
cQryDel	+=	" FROM "+cNameAKT 
cQryDel	+=	" WHERE AKT_FILIAL = ? AND "
cQryDel	+=	" AKT_CONFIG = ? AND "
cQryDel	+=	" AKT_DATA BETWEEN ? AND ? "

oQryDel	:=	FWPreparedStatement():New(cQryDel)

nQry := 1
//Qry AKD
oQryDel:SetString(nQry++, cFilAKT)
oQryDel:SetString(nQry++, cCubo)
oQryDel:SetString(nQry++, DtoS(dDataIni))
oQryDel:SetString(nQry++, DtoS(dDataFim))

cAliasDel	:=	GetNextAlias()
MPSYSOpenQuery(oQryDel:GetFixQuery(), cAliasDel)

If !(cAliasDel)->(Eof())
	nRecMin	:=	(cAliasDel)->MINRECNO
	nRecMax	:=	(cAliasDel)->MAXRECNO
Endif
(cAliasDel)->(dbCloseArea())

oQryDel:Destroy()
freeObj(oQryDel)

For nI := nRecMin To nRecMax STEP 10000
	cQryDel	:= " DELETE FROM  "+cNameAKT 
	cQryDel += " WHERE AKT_FILIAL='" + cFilAKT + "' AND "
	cQryDel += " AKT_CONFIG = '" + cCubo +"' AND "
	cQryDel += " AKT_DATA BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim)+"' "
	cQryDel += " AND R_E_C_N_O_ BETWEEN " + Str(nI)+ " AND " + Str(nI+10000)
	
	lRet := TCSQLExec(cQryDel) == 0
	
	If !lRet
		UserException(STR0007+CRLF+STR0009+CRLF+TCSqlError())//"Erro na delecao de movimentos "####"Processo cancelado..."
		lRet :=	.F.
		Exit 
	Endif	
Next
	
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} P300GtCpos
Retorna os campos fixos da AKT.
@author  TOTVS
@since   19/11/2025
@version 12
*/
//-------------------------------------------------------------------
Static Function P300GtCpos(nNiveis as Numeric, aCposNiv as Array, jTamCpos as JsonObject)
Local aRetCpos as Array
Local nI as Numeric

DEFAULT nNiveis := 0
DEFAULT aCposNiv := {}

aRetCpos := {{"AKT_FILIAL"},; //1
			{"AKT_CHAVE"},;  //2
			{"AKT_DATA"},;   //3
			{"AKT_CONFIG"},; //4
			{"AKT_ANALIT"},; //5
			{"AKT_TPSALD"},; //6						
			{"AKT_MVCRD1"},; //7
			{"AKT_MVCRD2"},; //8
			{"AKT_MVCRD3"},; //9
			{"AKT_MVCRD4"},; //10
			{"AKT_MVCRD5"},; //11
			{"AKT_MVDEB1"},; //12
			{"AKT_MVDEB2"},; //13
			{"AKT_MVDEB3"},; //14
			{"AKT_MVDEB4"},; //15
			{"AKT_MVDEB5"}}	 //16
						
	For nI := 1 to nNiveis			
		jTamCpos[StrZero(nI,2)] := TamSX3(aCposNiv[nI])[1]
		aAdd(aRetCpos,{"AKT_NIV"+StrZero(nI,2)})			
	Next nI

Return aClone(aRetCpos)

//-------------------------------------------------------------------
/*{Protheus.doc} CallXFilial
Procedure para retornar a filial correta para acesso a tabela.

@author  TOTVS
@since   19/11/2025
@version 12
*/
//-------------------------------------------------------------------
Function CallXFilial( cArq )
Local aSaveArea := GetArea()
Local cProc   := cArq+"_"+cEmpAnt
Local cQuery  := ""
Local lRet    := .F.
Local aCampos := CT2->(DbStruct())
Local nPos    := 0
Local cTipo   := ""

lRet := TCSPExist( cProc )	//Se já existe não precisa criar

If !lRet
	cQuery :="Create procedure "+cProc+CRLF
	cQuery +="( "+CRLF
	cQuery +="  @IN_ALIAS        Char(03),"+CRLF
	nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "CT2_FILIAL" } )
	cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
	cQuery +="  @IN_FILIALCOR    "+cTipo+","+CRLF
	cQuery +="  @OUT_FILIAL      "+cTipo+" OutPut"+CRLF
	cQuery +=")"+CRLF
	cQuery +="as"+CRLF

	/* -------------------------------------------------------------------
		Versão      -  <v> Genérica </v>
		Assinatura  -  <a> 010 </a>
		Descricao   -  <d> Retorno o modo de acesso da tabela em questao </d>

		Entrada     -  <ri> @IN_ALIAS        - Tabela a ser verificada
							@IN_FILIALCOR    - Filial corrente </ri>

		Saida       -  <ro> @OUT_FILIAL      - retorna a filial a ser utilizada </ro>
					<o> brancos para modo compartilhado @IN_FILIALCOR para modo exclusivo </o>

		Responsavel :  <r> Alice Yaeko </r>
		Data        :  <dt> 14/12/10 </dt>
	
	X2_CHAVE X2_MODO X2_MODOUN X2_MODOEMP X2_TAMFIL X2_TAMUN X2_TAMEMP
	-------- ------- --------- ---------- --------- -------- ---------
	CT2      E       E         E          3.0       3.0        2.0       
		X2_CHAVE   - Tabela
		X2_MODO    - Comparti/o da Filial, 'E' exclusivo e 'C' compartilhado
		X2_MODOUN  - Comparti/o da Unidade de Negócio, 'E' exclusivo e 'C' compartilhado
		X2_MODOEMP - Comparti/o da Empresa, 'E' exclusivo e 'C' compartilhado
		X2_TAMFIL  - Tamanho da Filial
		X2_TAMUN   - Tamanho da Unidade de Negocio
		X2_TAMEMP  - tamanho da Empresa
	
	Existe hierarquia no compartilhamento das entidades filial, uni// de negocio e empresa.
	Se a Empresa for compartilhada as demais entidades DEVEM ser compartilhadas
	Compartilhamentos e tamanhos possíveis
	compartilhaemnto         tamanho ( zero ou nao zero)
	EMP UNI FIL             EMP UNI FIL
	--- --- ---             --- --- ---
		C   C   C               0   0   X   -- 1 - somente filial
		E   C   C               0   X   X   -- 2 - filial e unidade de negocio
		E   E   C               X   0   X   -- 3 - empresa e filial
		E   E   E               X   X   X   -- 4 - empresa, unidade de negocio e filial
	------------------------------------------------------------------- */
	cQuery +="Declare @cModo    Char( 01 )"+CRLF
	cQuery +="Declare @cModoUn  Char( 01 )"+CRLF
	cQuery +="Declare @cModoEmp Char( 01 )"+CRLF
	cQuery +="Declare @iTamFil  Integer"+CRLF
	cQuery +="Declare @iTamUn   Integer"+CRLF
	cQuery +="Declare @iTamEmp  Integer"+CRLF

	cQuery +="begin"+CRLF
	
	cQuery +="  Select @OUT_FILIAL = ' '"+CRLF
	cQuery +="  Select @cModo = ' ', @cModoUn = ' ', @cModoEmp = ' '"+CRLF
	cQuery +="  Select @iTamFil = 0, @iTamUn = 0, @iTamEmp = 0"+CRLF
	
	cQuery +="  Select @cModo = X2_MODO,   @cModoUn = X2_MODOUN, @cModoEmp = X2_MODOEMP,"+CRLF
	cQuery +="         @iTamFil = X2_TAMFIL, @iTamUn = X2_TAMUN, @iTamEmp = X2_TAMEMP"+CRLF
	cQuery +="    From SX2"+cEmpAnt+"0 "+CRLF
	cQuery +="   Where X2_CHAVE = @IN_ALIAS"+CRLF
	cQuery +="     and D_E_L_E_T_ = ' '"+CRLF
	
	/*   SITUACAO -> 1 somente FILIAL */
	cQuery +="  If ( @iTamEmp = 0 and @iTamUn = 0 and @iTamFil >= 2 ) begin"+CRLF   //  -- so tem filial tam 2
	cQuery +="    If @cModo = 'C' select @OUT_FILIAL = '  '"+CRLF
	cQuery +="    else select @OUT_FILIAL = @IN_FILIALCOR"+CRLF
	cQuery +="  end else begin"+CRLF
		/*  SITUACAO -> 2 UNIDADE DE NEGOCIO e FILIAL  */
	cQuery +="    If @iTamEmp = 0 begin"+CRLF
	cQuery +="      If @cModoUn = 'E' begin"+CRLF
	cQuery +="        If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamUn + 1, @iTamFil )"+CRLF
	cQuery +="        else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamUn)"+CRLF
	cQuery +="      end"+CRLF
	cQuery +="    end else begin"+CRLF
		/* SITUACAO -> 4 EMPRESA, UNIDADE DE NEGOCIO e FILIAL */
	cQuery +="      If @iTamUn > 0 begin"+CRLF
	cQuery +="        If @cModoEmp = 'E' begin"+CRLF
	cQuery +="          If @cModoUn = 'E' begin"+CRLF
	cQuery +="            If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)||Substring( @IN_FILIALCOR, @iTamEmp+@iTamUn + 1, @iTamFil )"+CRLF
	cQuery +="            else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring(@IN_FILIALCOR, @iTamEmp+1, @iTamUn)"+CRLF
	cQuery +="          end else begin"+CRLF
	cQuery +="            select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
	cQuery +="          end"+CRLF
	cQuery +="        end"+CRLF
	cQuery +="      end else begin"+CRLF
			/*  SITUACAO -> 3 EMPRESA e FILIAL */
	cQuery +="        If @cModoEmp = 'E' begin"+CRLF
	cQuery +="          If @cModo = 'E' select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)||Substring( @IN_FILIALCOR, @iTamEmp+1, @iTamFil )"+CRLF
	cQuery +="          else select @OUT_FILIAL = Substring(@IN_FILIALCOR, 1, @iTamEmp)"+CRLF
	cQuery +="        end"+CRLF
	cQuery +="      end"+CRLF
	cQuery +="    end"+CRLF
	cQuery +="  end"+CRLF
	cQuery +="end"+CRLF

	cQuery := MsParse( cQuery, Alltrim(TcGetDB()) )
	cQuery := CtbAjustaP(.F., cQuery, 0)
	
	lRet := !Empty( cQuery ) //Se não estiver vazio, passou pelo parse

	If lRet
		lRet := (TcSqlExec(cQuery) == 0) // Se executou sem erros
		If !lRet .And. !__lBlind
			MsgAlert(STR0028+cProc)  //"Erro na criacao da proc filial: "
		EndIf	
	ElseIf !__lBlind
		MsgAlert(MsParseError(),STR0027+cProc)  //'A query da filial nao passou pelo Parse '			
	EndIf
EndIf

RestArea(aSaveArea)

Return(lRet)  
