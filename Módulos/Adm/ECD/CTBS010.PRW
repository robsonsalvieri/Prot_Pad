#INCLUDE "CTBS010.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "ECD.CH"
#INCLUDE "RWMAKE.CH"

//Compatibilização de fontes 30/05/2018

Static _aSocOsten := { NIL }
Static _nRecCS2   := NIL
Static aLoadRes   := Array(ECD_NUMCOLS) //Tamanho do array definido no ECD.CH para salvar as perguntas informadas no wizard 
Static __cCodRev  := Nil
Static __ecdTria  := SuperGetMV("MV_ECDTRIA",.F.,.F.)
Static lAutomato  := isBlind()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CTBS010    ³ Autor ³Microsiga	        ³ Data ³10/02/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Wizard contendo as informacoes necessarias para escrituração³±±
±±³          ³                                                     		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 											                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBS010( cEmp, cModEsc, bIncTree )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Perguntas utilizadas no Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aPerEsc
Local aPerEsc2
Local aPergSped1
Local aPergSped2
Local aPergSped3
Local aPergSped4
Local aPergSped5

Local aArea
Local aHeader	:= {}
Local aFils		:= {}


Local lFim    	:= .F.
Local cMatriz	:= Space(CtbTamFil("033",2))

Local oOk
Local oNo
Local oBold		:= Nil
Local oFil 		:= Nil

Local lFWCodFil   	:= FindFunction( "FWCodFil" )
Local lGestao		:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local aTrimestre := {"",""}
Local bRecibo 	:= {||aRespSped2[1]==1 .Or. ( aRespSped2[1]==2.And.!Empty(aRespSped2[3]) ) }
Local bDataSld  := {|| ( aRespSped3[4]==2 .Or. ( !Empty(aRespSped3[5]).And.!Empty(aRespSped3[6]) ) ) }
Local bPasso3FCO := {||Eval(bDataSld) .And. C010DlgTrim(aRespSped3,aTrimestre) }
Local bEcdFatoCtb := {|| EcdFatoCtb(aRespSped5) }
Local aParLeiaute, aRespLeiaute

Local nOpc   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Respostas referente as perguntas utilizadas no Wizard³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aResEsc	

Private aRespSped 
Private aResExpor   

Private aRespSped1 
Private aRespSped2 
Private aRespSped3 
Private aRespSped4 
Private aRespSped5
Private lMoedfun:= .F. 

Private oWzrdEcd   := Nil
Private lLeiaute2  := .F.
Private cEcdCodVis := ""
Private lLeiaute3  := .F.
Private lCodSCP    := .F.
Private lLeiaute4  := .F.
Private lLeiaute5  := .F.
Private lLeiaute6  := .F.
Private lLeiaute7  := .F.
Private lLeiaute8  := .F.
Private lLeiaute9  := .F.
Private aPerCalTri := {}

Default bIncTree := {||.T.}
Default cEmp		:= ""
If ! (cModEsc $ "ECD|FCO")
	Return
EndIf
If Empty( cEmp )
	Return .F.
Endif

//Limpo o Array para salvar as informações digitadas	
aLoadRes    := Array(ECD_NUMCOLS)

If cModEsc =="FCO" .And. CS0->(FieldPos("CS0_ECDREV")) == 0
	ALERT(STR0072)  //"Campo Tipo Livro (CS0_ECDREV) nao encontrado. Verifique!"
	Return
EndIf

If cModEsc =="ECD" 

	aParLeiaute := {} 
	aRespLeiaute := {2}
	aAdd(aParLeiaute ,{3,STR0118,9,{STR0119,STR0120,STR0155,STR0209,STR0210,STR0224,STR0228,STR0259,STR0271},90,"",.T.,.T.}) //"Informe o leiaute da ECD ?"##"Leiaute 1"##"Leiaute 2"##"Leiaute 3"##"Leiaute 4 "##"Leiaute 6"##"Leiaute 7"##"Leiaute 8"##"Leiaute 9"
	
	If ParamBox( aParLeiaute,"", @aRespLeiaute)
	  If aRespLeiaute[1] == 2
			lLeiaute2  := .T.
	  ElseIf aRespLeiaute[1] == 3
			lLeiaute2  := .T.		  
			lLeiaute3  := .T.
	  ElseIf aRespLeiaute[1] == 4
			lLeiaute2  := .T.
		  lLeiaute3  := .T.
			lLeiaute4  := .T.
		ElseIf aRespLeiaute[1] == 5
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.	  
			lLeiaute5  := .T.
		ElseIf aRespLeiaute[1] == 6
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.
			lLeiaute5  := .T.
			lLeiaute6  := .T.
		ElseIf aRespLeiaute[1] == 7 
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.
			lLeiaute5  := .T.
			lLeiaute6  := .T.
			lLeiaute7  := .T.
		ElseIf aRespLeiaute[1] == 8
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.
			lLeiaute5  := .T.
			lLeiaute6  := .T.
			lLeiaute7  := .T.
			lLeiaute8  := .T.
		ElseIf aRespLeiaute[1] == 9
			lLeiaute2  := .T.
			lLeiaute3  := .T.
			lLeiaute4  := .T.
			lLeiaute5  := .T.
			lLeiaute6  := .T.
			lLeiaute7  := .T.
			lLeiaute8  := .T.
			lLeiaute9  := .T.
	  EndIf	    
		If !VldCSQL7(aRespLeiaute) 
			Return 
		EndIf

  Else
		ALERT(STR0123)  //"Deve ser selecionado um leiaute para ECD. Verifique!")
		Return
  EndIf  

	aPerEsc 	:= ParamEsc(cModEsc, aRespLeiaute[1])
	aPerEsc2 	:= ParamEsc(cModEsc, aRespLeiaute[1])
	aPergSped1 	:= ParamSped('1',cModEsc)[1]
	aPergSped2 	:= ParamSped('2',cModEsc)[1]
	aPergSped3 	:= ParamSped('3',cModEsc)[1]
	aPergSped4 	:= ParamSped('4',cModEsc)[1]
	aPergSped5 	:= ParamSped('5',cModEsc)[1]
	
	aArea    	:= GetArea()
	
	oOk 		:= LoadBitmap( GetResources(), "LBOK")
	oNo			:= LoadBitmap( GetResources(), "LBNO")
	
	aResEsc		:= Array(Len(aPerEsc))
	
	aRespSped	:= ParamSped('1',cModEsc)[2] 
	aResExpor	:= Array(4)   
	
	aRespSped1	:= ParamSped('1',cModEsc)[2] 
	aRespSped2	:= ParamSped('2',cModEsc)[2] 
	aRespSped3	:= ParamSped('3',cModEsc)[2] 
	aRespSped4	:= ParamSped('4',cModEsc)[2] 
	aRespSped5	:= ParamSped('5',cModEsc)[2] 
	
ElseIf cModEsc =="FCO"
	aPerEsc 	:= ParamEsc(cModEsc)
	aPerEsc2 	:= ParamEsc(cModEsc)
	aPergSped1	:= ParamSped('1',cModEsc)[1]
	aPergSped2	:= ParamSped('2',cModEsc)[1]
	aPergSped3	:= ParamSped('3',cModEsc)[1]
	aPergSped4	:= ParamSped('4',cModEsc)[1]
	aPergSped5	:= ParamSped('5',cModEsc)[1]
	
	aArea    	:= GetArea()
	
	oOk 		:= LoadBitmap( GetResources(), "LBOK")
	oNo			:= LoadBitmap( GetResources(), "LBNO")
	
	aResEsc		:= Array(Len(aPerEsc))
	
	aRespSped	:= ParamSped('1',cModEsc)[2] 
	aResExpor	:= Array(4)   
	
	aRespSped1	:= ParamSped('1',cModEsc)[2] 
	aRespSped2	:= ParamSped('2',cModEsc)[2] 
	aRespSped3	:= ParamSped('3',cModEsc)[2] 
	aRespSped4	:= ParamSped('4',cModEsc)[2] 
	aRespSped5	:= ParamSped('5',cModEsc)[2] 

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta o aheader do ListBox das Filiais³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := ARRAY(5)

aHeader[1]	:= ""  		
aHeader[2] 	:= IIF(lGestao,STR0071,STR0001) //"Filial" ##"Empresa/Unidade/Filial"
aHeader[3] 	:= STR0002 //"Razão Social"
aHeader[4]	:= STR0003 //"CNPJ"
aHeader[5]	:= ""

aFils := GetEmpEcd( cEmp )


DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da Interface                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// P1
DEFINE WIZARD oWzrdEcd ;
	TITLE STR0004 + cEmp; //"Assistente de Importação de Dados de Escrituração Contábil - Empresa: "
	HEADER STR0005;		 //"Atenção"
	MESSAGE "" ;
	TEXT STR0006 + CRLF + STR0007 ; //"Essa rotina tem como objetivo ajudá-lo na Escrituração Contábil Digital - ECD"###"Siga atentamente os passos, pois iremos efetuar a importação dos seus dados contábeis."
	NEXT {|| .T.} ;
	FINISH {||.T.}
       

// P2
If cModEsc == "ECD"
	aResEsc[1] := 1 
	If lLeiaute9 //Deixando como padrão a ultima versão selecionada no painel anterior
		aResEsc[2] := 9
	ElseIf lLeiaute8 
		aResEsc[2] := 8
	ElseIf lLeiaute7 
		aResEsc[2] := 7
	ElseIf lLeiaute6
		aResEsc[2] := 6
	Elseif lLeiaute5 
		aResEsc[2] := 5
	ElseIf lLeiaute4
		aResEsc[2] := 4
	ElseIf lLeiaute3
		aResEsc[2] := 3
	ElseIf lLeiaute2
		aResEsc[2] := 2
	EndIf
ElseIf cModEsc == "FCO"
	aResEsc[1] := 2
EndIf

CREATE PANEL oWzrdEcd  ;
	HEADER STR0008; //"Escolha qual o tipo de escrituração que irá efetuar."
	MESSAGE "";
	BACK {|| .T.} ;
	NEXT {|| ValidaParam(aPerEsc,aResEsc)} ;
	PANEL                                                                                           

	ParamBox( aPerEsc,"", @aResEsc,,,,,,oWzrdEcd:GetPanel(2))

// P3
CREATE PANEL oWzrdEcd  ;
	HEADER STR0009; //"Informe os dados da empresa escolhida para escrituração."
	MESSAGE "";
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergSped1,aRespSped1,,{||If(cModEsc=="ECD",ECDL3_SCP() .And. ECDBlocoK() .And. ECDClrRTF(),.T.)}),;
	IIF(lLeiaute8 .And. aRespSped1[15] == 2,(ApMsgInfo(STR0263, STR0262, ), .T.), .T.) } ; // Mostrar mensagem caso o parâmetro 'Existe mudança no plano referencial?' esteja como 'Não' "
	PANEL
	
	ParamBox(aPergSped1,"", @aRespSped1,,,,,,oWzrdEcd:GetPanel(3)) 

// P4
CREATE PANEL oWzrdEcd  ;
	HEADER STR0010; //"Quais são as filiais que essa empresa centralizadora?"
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaEmpEcd(aFils,,aRespSped1,cMatriz) .And. PreVldSCP(aFils,cMatriz)} ;	
	PANEL

	oFil := TWBrowse():New( 0.5, 0.5 , 280, 100,Nil,aHeader, Nil, oWzrdEcd:GetPanel(4), Nil, Nil, Nil,Nil,;
					      {|| aFils := EmpTrocEcd( oFil:nAt, aFils, .T., cModEsc ), oFil:Refresh() })      

	oFil:SetArray( aFils )

	oFil:bHeaderClick := { |o , nCol | CtbsInvtFl( o , nCol , aFils , .T. , cModEsc ) }

	oFil:bLine := {|| {;
					If( aFils[oFil:nAt,1] , oOk , oNo ),;
						aFils[oFil:nAt,3],;
						aFils[oFil:nAt,4],;
						aFils[oFil:nAt,5];
					}}
   
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Campo utilizado para preenchimento da matriz	³
	//³caso a escrituração seja com centralização	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
	@ 110,005 SAY STR0067 SIZE 070,010  PIXEL OF oWzrdEcd:GetPanel(4) //"Matriz"
	@ 110,025 MSGET cMatriz SIZE 015,005 PIXEL OF oWzrdEcd:GetPanel(4) F3 "SM0_01" 
	 
						
// P5
CREATE PANEL oWzrdEcd  ;
	HEADER STR0011; //"Informe neste passo, quais as incrições de sua empresa."
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergSped2, aRespSped2,,{||If(cModEsc=="ECD",.T.,Eval(bRecibo))}) .And. PosVldSCP(cModEsc,aFils,cMatriz) .And. EcMultInsc(cEmp,cModEsc,aRespSped2)} ;
	PANEL

	ParamBox(aPergSped2,"", @aRespSped2,,,,,,oWzrdEcd:GetPanel(5)) 
	
// P6
CREATE PANEL oWzrdEcd  ;
	HEADER STR0012; //"Informe neste passo, quais os dados principais para a escrituração. PASSO 1/3"
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergSped3,aRespSped3,,{||If(cModEsc=="ECD",.T.,Eval(bPasso3FCO))}) } ;
	PANEL

	ParamBox(aPergSped3,"", @aRespSped3,,,,,,oWzrdEcd:GetPanel(6)) 

// P7
CREATE PANEL oWzrdEcd  ;
	HEADER STR0013; //"Informe neste passo, quais os dados principais para a escrituração. PASSO 2/3"
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergSped4,aRespSped4,,{|cMsgAlert| If(cModEsc=="ECD",VldCalTri(@cMsgAlert),.T.)} ) };
	PANEL

	ParamBox(aPergSped4,"", @aRespSped4,,,,,,oWzrdEcd:GetPanel(7)) 
	

// P8
CREATE PANEL oWzrdEcd  ;
	HEADER STR0014; //"Informe neste passo, quais os dados principais para a escrituração. PASSO 3/3"
	MESSAGE ""	;
	BACK {|| .T.} ;
	Next {|| ValidaParam(aPergSped5,aRespSped5) .And. If(cModEsc=="ECD", (CTBSVLDEM(aRespSped5,3) .And. CTBSVLDEM(aRespSped5,4) .And. CTBSVLDEM(aRespSped5,8) .And. CTBSVLARQ(aRespSped5)),.T.)};
	PANEL

	ParamBox(aPergSped5,"", @aRespSped5,,,,,,oWzrdEcd:GetPanel(8)) 

// P9
CREATE PANEL oWzrdEcd  ;
	HEADER STR0015; //"Etapa de Configuração Finalizada!"
	MESSAGE ""	;
	BACK {|| .T.} ;
	FINISH {|| EcdProcessa( cEmp, aFils, aRespSped1, aRespSped2, aRespSped3, aRespSped4, aRespSped5,cMatriz, cModEsc, aTrimestre, bIncTree, bEcdFatoCtb),nOpc:=1 };
	PANEL

	@ 050,010 SAY STR0016 SIZE 270,020 FONT oBold PIXEL OF oWzrdEcd:GetPanel(9) //"Clique no botão finalizar para fechar o wizard e iniciarmos a exportação dos dados para ECD."

ACTIVATE WIZARD oWzrdEcd CENTERED


// Se o usuário cancela o wizzard, após ter cadastrado múltiplas inscrições,
// os registros serão excluídos
If (nOpc != 1 .and. AliasInDic("CSS"))
	DelAbortCss(__cCodRev) 
EndIf

__cCodRev := Nil

RestArea( aArea )

Return lFim 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ParamEsc  ºAutor  ³Microsiga			 º Data ³  28/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua o preenchimento do array do CheckBox e retorna o     º±±
±±º          ³mesmo para ser apresentado no Wizard atraves da função 	  º±± 
±±º          ³parambox      											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ParamEsc(cModEsc, nOpcIni)
Local aArea    	:= GetArea()
Local aParamEsc := {}

Default nOpcIni := 1
aAdd(aParamEsc ,{3,STR0017,1,{STR0018,"FCONT"},90,"",.T.,.F.}) //"Qual o Tipo de Escrituração ?"###"Sped Contábil"
// aAdd(aParamEsc,{4,"",,"E-LALUR",30,,.F.})
// aAdd(aParamEsc,{4,"",,"FCONT",30,,.F.})
If cModEsc == "ECD" 
	aAdd(aParamEsc ,{3,STR0118,9,{STR0119,STR0120,STR0155,STR0209,STR0210,STR0224,STR0228,STR0259,STR0271},90,"",.T.,.F.}) //"Informe o leiaute da ECD ?"##"Leiaute 1"##"Leiaute 2"##"Leiaute 3"##"Leiaute 4##"Leiaute 5"##"Leiaute 6"##"Leiaute 7"##"Leiaute 8"##"Leiaute 9"
EndIf

If .F.
	aAdd(aParamEsc,{2,STR0019		,Space(1),{STR0065,STR0066},50,"",.T.}) //"Exporta Cadastros "
	aAdd(aParamEsc,{2,STR0020		,Space(1),{STR0065,STR0066},50,"",.T.}) //"Exporta Movimentações "
	aAdd(aParamEsc,{2,STR0021		,Space(1),{STR0065,STR0066},50,"",.T.}) //"Exporta Saldos "
	aAdd(aParamEsc,{2,STR0022		,Space(1),{STR0065,STR0066},50,"",.T.}) //"Exporta Demonstrativos "
Endif

RestArea( aArea ) 

Return aParamEsc  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ParamSped    ºAutor  ³Microsiga		 	º Data ³28/01/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Define as perguntas e respostas especificas do Sped         º±±
±±º          ³														      º±±
±±º          ³Exemplo:												      º±±
±±º          ³aRet[1]-> retorna as perguntas						      º±±
±±º          ³aRet[2]-> retorna as respostas 						      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function ParamSped( cPasso, cModEsc )

Local aArea    	    := GetArea()
Local aRet		    := {}
Local aPerguntas    := {}
Local aRespostas    := {}

Local aTipoDeLiv 	:= {STR0023,STR0024,STR0025,STR0026} //"G-Geral"###"R-Diário Resumido"###"A-Diário Auxiliar"###"B-Balancete Diário"###"S-Escrituração SCP Mantida pelo Sócio Ostensivo"
Local aSitEspeci 	:= {STR0028,STR0029,STR0030,STR0031,STR0032,STR0033,STR0124 } 	//"Z-Normal"###"0-Abertura"###"1-Cisão"###"2-Fusão"###"3-Incorporação"###"4-Extinção"## "5-Transformação"## "5-Transformação"
Local aOutrInscr 	:= {STR0034,STR0035,STR0036,STR0037,STR0038,STR0039} //"00-Não ha"###"01-Bco Cent. do Brasil / BACEN"###"02-Super. de Seg. Privados / SUSEP"###"03-Comis. de Val. Mobiliários / CVM"###"04-Agência Nacional de Transportes Terrestres (ANTT)"###"UF-Secretarias de Estado"
Local aTpEscrit 	:= {STR0073 , STR0074}             						// "0-Original"##"1-Retificadora"
Local aQualifPJ 	:= {"00-(SUSEP)" , "10-(RFB)","20-(COSIF)"}
Local aSimNao 		:= {STR0075,STR0076}  									//"1-Sim"##"2-Não"
Local nTamConta 	:= TAMSX3("CT1_CONTA")[1]
Local nTamCusto 	:= TAMSX3("CTT_CUSTO")[1]
Local aPerApuFCO	:= {STR0082 , STR0083 }  								//"A-Anual"##"T-Trimestral"
Local aFormTrib		:= {STR0084, STR0085, STR0086, STR0087}  				//"1-Real"##"2-Real Arbitrado"##"3-Real Presumido(Trimestral)"##"4-Real Presumido Arbitrado(Trimestral)" 
Local aIndIniPer   	:= {STR0125,STR0126,STR0127,STR0128+If(cModEsc=="ECD","ECD","FCONT")}  //"0-Inicio no primeiro dia do ano"##"1-Abertura"##"2-Resultante Cisao/Fusao ou remanescente..."##"3-Inicio Obrigatoriedade Entrega "
Local aEcdFinEscr 	:= {}     //"Indicador de finalidade da escrituração:"##"0-Original"##"1-Substituta com NIRE"##"2-Substituta sem NIRE"##"3-Substituta com troca de NIRE"
Local aEcdIndNire 	:= {STR0133,STR0134}  //"0-Empresa não possui NIRE"##"1-Empresa possui NIRE"
Local aIndGdePorte 	:= {}
Local aEcdTipoSCP 	:= {}
Local nCont         := 0
Local aTabEntid		:= { 	STR0157,;  //"1-PJ em Geral (L100A + L300A da ECF)"
							STR0158,;  //"2-PJ em Geral–Lucro Presumido (P100 + P150 da ECF)"
							STR0159,;  //"3-Financeiras (L100B + L300B da ECF)"
							STR0160,;  //"4-Seguradoras (L100C + L300C da ECF)"
							STR0161,;  //"5-Imunes e Isentas em Geral (U100A + U150A da ECF)"
							STR0162,;  //"6-Financeiras-Imunes e Isentas (U100B + U150B da ECF)"
							STR0163,;  //"7-Seguradoras-Imunes e Isentas (U100C + U150C da ECF)"
							STR0164,;  //"8-Entidades Fechadas de Previdencia Complementar (U100D + U150D da ECF)"
							STR0165 }  //"9-Partidos Politicos (U100E + U150E da ECF)"  

Local aMotSubst			:= {STR0243,;//"000=Não se aplica"
							STR0244,;//"001=Mudanças de saldos"
							STR0245,;//"002=Alteração assinatura"
							STR0246,;//"003=Alteração Dem. contábil"
							STR0247,;//"004=Alteração Forma Escrit. contábil"
							STR0248,;//"005=Alteração do número do livro"
							STR0249}//"099=Outros"  	
		
Local nTamLivro := TAMSX3("CS0_NUMLIV")[1]

Default cModEsc := "ECD"

If (lLeiaute5 .Or. lLeiaute6)
	aEcdFinEscr 	:= {STR0222,STR0223}  //"0 - Original"
	aAdd(aTabEntid,STR0211) //"10-Financeiras – Lucro Presumido (P100B + P150B da ECF)"
Else
	aEcdFinEscr 	:= {STR0129,STR0130,STR0131,STR0132}     //"Indicador de finalidade da escrituração:"##"0-Original"##"1-Substituta com NIRE"##"2-Substituta sem NIRE"##"3-Substituta com troca de NIRE"
EndIf

If aLoadRes[1] == nil //Se o array estiver com seu conteúdo nulo
	For nCont := 1 to Len(aLoadRes) //Adiciono as últimas informações salvas
		aLoadRes[nCont] := EcdLoad('RESPECD',aPerguntas,nCont) //A função EcdLoad(CTBSFUN.PRW) resgata as informações salvas no arquivo txt na pasta profile
	Next
EndIf

If cPasso == '1'
	//passo 1
	aAdd(aPerguntas,{3,STR0040	,1,{STR0042,STR0041},190,"",.T.}) //"Tipo Escrituração"###"Com Centralização"###"Sem Centralização"
	aAdd(aPerguntas,{3,STR0043	,1,aSitEspeci,65,"",.T.}) //Situação Especial
    
  If cModEsc == "FCO"
		aAdd(aPerguntas,{3,STR0135	,1,aIndIniPer,120,"",.T.}) //"Indicador Inicio de Periodo"
    aRespostas := {0,0,1}
 	ElseIf  cModEsc == "ECD" .And. lLeiaute2 
	 	aAdd(aPerguntas,{3,STR0135	,1        ,aIndIniPer ,120,"",.T.}) //"Indicador Inicio de Periodo"
 		aAdd(aPerguntas,{3,STR0136	,2        ,aEcdIndNire,120,"",.T.}) //"Indicador de existência de NIRE"
 		aAdd(aPerguntas,{3,STR0137	,1        ,aEcdFinEscr,120,"",.F.}) //"Indicador de finalidade da escrituração"
		aAdd(aPerguntas,{1,STR0138	,Space(40),""         ,"" ,"", ,110,.F.})  	//"Hash da Escrituração Substituida"
		aAdd(aPerguntas,{1,STR0139	,Space(11),""         ,"" ,"","BloqField()",110,.F.})  	//"NIRE da Escrituração Substituida
		
		//Se o array não estiver preenchido permaneco com o valor padrão do wizard
    aRespostas := { If (Empty(aLoadRes[ECD_TIPOESC])  ,0,Val(aLoadRes[ECD_TIPOESC]  )),;
					    If (Empty(aLoadRes[ECD_SIT_ESP])  ,0,Val(aLoadRes[ECD_SIT_ESP]  )),;
					    If (Empty(aLoadRes[ECD_INDINIPER]),1,Val(aLoadRes[ECD_INDINIPER])),;
					    If (Empty(aLoadRes[ECD_EXISTNIRE]),0,Val(aLoadRes[ECD_EXISTNIRE])),;
					    If (Empty(aLoadRes[ECD_FIN_ESC])  ,0,Val(aLoadRes[ECD_FIN_ESC]  )),;
					    If (Empty(aLoadRes[ECD_HASH_ESC_SUBST]) ,Space(40),Padr(aLoadRes[ECD_HASH_ESC_SUBST],40)),;  
					    Space(11)}
    	
    If lLeiaute3
    	aIndGdePorte 	:= {STR0166,STR0167} //"0 – Empresa não é entidade sujeita a auditoria independente."##"1 – Empresa é entidade sujeita a auditoria independente."
			aEcdTipoSCP 	:= {STR0168,STR0169,STR0170} //"0 – ECD de empresa não participante de SCP como sócio ostensivo."##"1 – ECD de empresa participante de SCP como sócio ostensivo."##"2 – ECD da SCP."
	 		aAdd(aPerguntas,{3,STR0171	,1,aIndGdePorte,190,"",.T.}) //"Indicador Empr.Grande Porte"
 			aAdd(aPerguntas,{3,STR0172	,2,aEcdTipoSCP ,190,"",.T.}) //"Tipo da ECD (SCP)"
			aAdd(aPerguntas,{3,STR0173	,1,aTabEntid   ,190,"",.T.}) //"Plano Contas Referencial"
			
			aAdd(aRespostas,If (Empty(aLoadRes[ECD_GDE_PORTE]),1,Val(aLoadRes[ECD_GDE_PORTE])))
    	aAdd(aRespostas,If (Empty(aLoadRes[ECD_SCP_IND])  ,1,Val(aLoadRes[ECD_SCP_IND]  )))
    	aAdd(aRespostas,If (Empty(aLoadRes[ECD_PLANOREF]) ,1,Val(aLoadRes[ECD_PLANOREF] )))

    	If lLeiaute4
    		aAdd(aPerguntas,{3,STR0212,1,{STR0065,STR0066},190,"",.T.}) //"Moeda funcional diferente da nacional?"
    		aAdd(aRespostas, If (Empty(aLoadRes[ECD_MOE_FUN]),2,Val(aLoadRes[ECD_MOE_FUN])))
    	EndIf

    	If lLeiaute5
				If ( CS0->( ColumnPos( "CS0_IDBLK" )) > 0 )
    			aAdd(aPerguntas,{3,STR0220,1,{STR0065,STR0066},190,"",.T.} )    //,"BloqField()"}) //"Escriturações Contábeis Consolidadas?"
    			aAdd(aRespostas, If (Empty(aLoadRes[ECD_OUT_CEC]),2,Val(aLoadRes[ECD_OUT_CEC])))

	 				aAdd(aPerguntas,{1,STR0225	,Space(10)	,"","","CQQ","",50,.F.})   //"Codigo Identif. Bloco K" 
					aAdd(aRespostas, If (Empty(aLoadRes[ECD_IDBLK]),Space(10),(aLoadRes[ECD_IDBLK] )))
				Else
    			aAdd(aPerguntas,{3,STR0220,1,{STR0065,STR0066},190,"",.T.,"BloqField()"}) //"Escriturações Contábeis Consolidadas?"
    			aAdd(aRespostas, If (Empty(aLoadRes[ECD_OUT_CEC]),2,Val(aLoadRes[ECD_OUT_CEC])))
				Endif
				If lLeiaute8
					aAdd(aPerguntas,{3,STR0260,1,{STR0065,STR0066},190,"",.T.}) //"Ocorreu mudança no Plano de Contas?"
    				aAdd(aRespostas, If (Empty(aLoadRes[ECD_MUD_PLC]),2,Val(aLoadRes[ECD_MUD_PLC])))

					aAdd(aPerguntas,{3,STR0261,1,{STR0065,STR0066},190,"",.T.}) //"Existe amarração com Plano Referencial?"
    				aAdd(aRespostas, If (Empty(aLoadRes[ECD_AMR_PLR]),1,Val(aLoadRes[ECD_AMR_PLR])))
				EndIf
   		EndIf
   	EndIf
  Else
   	aRespostas := {0,0}
  EndIf

ElseIf cPasso == '2'
	// Passo 2
	If cModEsc == "ECD"
		If lLeiaute8
			aAdd(aOutrInscr,STR0264)
		EndIf
		aAdd(aPerguntas,{3,STR0044 ,1,aOutrInscr,100,"",.T.}) //"Outras Inscrições"
		aAdd(aPerguntas,{1,STR0045 ,Space(02),"","","12",,05,.F.}) //"Unidade Federativa"
		aAdd(aPerguntas,{1,STR0046 ,Space(60),"","","",,60,.F.}) //"Inscrição"

		aRespostas := {	If (Empty(aLoadRes[ECD_OUT_INSC]) ,0,Val(aLoadRes[ECD_OUT_INSC])),;
						If (Empty(aLoadRes[ECD_OUT_UF])   ,Space(02),Padr(aLoadRes[ECD_OUT_UF],02)),; 
						If (Empty(aLoadRes[ECD_INSCRICAO]),Space(60),Padr(aLoadRes[ECD_INSCRICAO],60))}
		
		If lLeiaute3
			aAdd(aPerguntas,{1,STR0174		,Space(14),"","","","lCodSCP",160,.F.})  	//"Codigo da SCP"
			aAdd(aRespostas, If (Empty(aLoadRes[ECD_COD_SCP]) ,Space(14),Padr(aLoadRes[ECD_COD_SCP],14)) )
		EndIf

	ElseIf cModEsc == "FCO"
		aAdd(aPerguntas,{3,STR0088  		,1,aTpEscrit,100,"",.T.})   		//"Escrituração"
		aAdd(aPerguntas,{3,STR0089			,2,aQualifPJ,100,"",.T.})  		//"Qualificação Pessoa Jurídica:"
		aAdd(aPerguntas,{1,STR0090			,Space(41),"","","",,110,.F.})  	//"Número do Recibo Anterior"

		aRespostas := {0,2,Space(41)}
	EndIf

ElseIf cPasso == '3'
	If cModEsc == "ECD"
		aAdd(aPerguntas,{3,STR0047		,Space(1),aTipoDeLiv,165,"",.T.}) 	//"Indicação da Escrituracao"
		aAdd(aPerguntas,{1,STR0048		,Space(nTamLivro),"@E "+Replicate('9',nTamLivro),"","",,,.T.})	//"Numero de Ordem do Livro"
		aAdd(aPerguntas,{1,STR0049		,Space(80),"","","",,60,.T.}) 		//"Natureza do Livro "

		aRespostas := {	If (Empty(aLoadRes[ECD_IND_ESC])   ,0,Val(aLoadRes[ECD_IND_ESC])),;
						If (Empty(aLoadRes[ECD_NUM_ORDEM]) ,Space(nTamLivro),Padr(aLoadRes[ECD_NUM_ORDEM],nTamLivro)),; 
						If (Empty(aLoadRes[ECD_NATUREZA])  ,Space(80),Padr(aLoadRes[ECD_NATUREZA],80))}

	ElseIf cModEsc == "FCO"
		
		aAdd(aPerguntas,{1,STR0091	,Space(nTamConta),"","","CT1",,50,.F.})	//"Conta de apuração"
		aAdd(aPerguntas,{3,STR0092	,0,aPerApuFCO,120,"",.T.})   			//"Periodo de Apuração"
		aAdd(aPerguntas,{3,STR0093	,0,aFormTrib ,120,"",.T.})  			//"Forma de Tributação"
		aAdd(aPerguntas,{3,STR0094	,2,aSimNao,100,"",.T.})  				//"Ignora Sl. Ant. Rec/Des ?"
		aAdd(aPerguntas,{1,STR0095	,Space(40),"","","",,40,.F.})  			//"Grupos Receitas/Despesas"
		aAdd(aPerguntas,{1,STR0096	,CTOD(""),"","","",,60,.F.})   			//"Data Sld. Ant. Receitas/Desp."
		aAdd(aPerguntas,{3,STR0097	,1,aSimNao,100,"",.T.})  				//"Processar dados de movimentações?"
		aAdd(aPerguntas,{3,STR0098	,2,aSimNao,100,"",.T.})  				//"Processa C.Custo?"
		aAdd(aPerguntas,{1,STR0099	,Space(nTamCusto),"","","CTT",,50,.F.}) //"Centro Custo de apuração"

		aRespostas := {Space(nTamConta),1,1,2,Space(40),CTOD(""),1,2,Space(nTamCusto)}

	EndIf
	
ElseIf cPasso == '4'
	If cModEsc == "ECD"

		aAdd(aPerguntas,{1,STR0051	,CTOD(""),"","","",,60,.T.}) //"Periodo Inicial Lcto"
		aAdd(aPerguntas,{1,STR0052	,CTOD(""),"","","",,60,.T.}) //"Periodo Final Lcto"
		aAdd(aPerguntas,{1,STR0053	,CTOD(""),"","","",,60,.F.}) //"Apuração do Exercicio(L/P)"
		aAdd(aPerguntas,{1,STR0050	,Space(CTG->(TamSx3("CTG_CALEND")[1])),"@!","ExistCpo('CTG',aRespSped4[4])","CTG",,03,.T.})  //"Calendario"
		aAdd(aPerguntas,{1,STR0054	,Space(CTO->(TamSx3("CTO_MOEDA")[1])),"@!","ExistCpo('CTO',aRespSped4[5])","CTO",,05,.T.}) //"Moeda"
		aAdd(aPerguntas,{1,STR0055	,Space(1), "@!","ExistCpo('SX5','SL'+ aRespSped4[6])","SLD",,05,.T.}) //"Tipo de Saldo"
		aAdd(aPerguntas,{1,STR0056	,Space(CT1->(TamSx3("CT1_CONTA")[1])),"@!","","CT1",,50,.F.}) //"Conta De"
		aAdd(aPerguntas,{1,STR0057  ,Space(CT1->(TamSx3("CT1_CONTA")[1])),"@!","","CT1",,50,.F.})  //"Conta Ate"
		aAdd(aPerguntas,{1,STR0173  ,Space(CS0->(TamSx3("CS0_CODPLA")[1])),"@!","","CVN1",,50,.F.})//"Plan. Conta Ref."
		aAdd(aPerguntas,{1,STR0184 ,Space(CS0->(TamSx3("CS0_VERPLA")[1])),"@!",""," ",,50,.F.})//"Versão"
		
		If lLeiaute7
			aAdd(aPerguntas,{3,STR0229,0,aSimNao,100,"",.T.}) //"Arquivo Trimestral Unificado?"

			If GetNewPar("MV_ECDTRIA", .F.) 			
				aAdd(aPerguntas,{1,"Rev. Anterior",Space(TamSx3("CS0_CODREV")[1]),"@!","","",,50,.F.}) 
			EndIf
		EndIf
	
		aRespostas := {CTOD(aLoadRes[ECD_DATA_INI]),CTOD(aLoadRes[ECD_DATA_FIM]),CTOD(aLoadRes[ECD_DATA_LP]),;
							If (Empty(aLoadRes[ECD_CALENDARIO]), Space(CTG->(TamSx3("CTG_CALEND")[1])),Padr(aLoadRes[ECD_CALENDARIO],Len(CTG->CTG_CALEND))),;
		          If (Empty(aLoadRes[ECD_MOEDA])     , Space(CTO->(TamSx3("CTO_MOEDA")[1])),aLoadRes[ECD_MOEDA]),;
							If (Empty(aLoadRes[ECD_TIPO_SALDO]), Space(1),aLoadRes[ECD_TIPO_SALDO]),;
							If (Empty(aLoadRes[ECD_CONTA_INI]) , Space(CT1->(TamSx3("CT1_CONTA")[1])),PadR(aLoadRes[ECD_CONTA_INI],Len(CT1->CT1_CONTA))),;
							If (Empty(aLoadRes[ECD_CONTA_FIM]) , Space(CT1->(TamSx3("CT1_CONTA")[1])),PadR(aLoadRes[ECD_CONTA_FIM],Len(CT1->CT1_CONTA)))}

		aAdd(aRespostas,If(Empty(aLoadRes[ECD_COD_PLA]),Space(CT1->(TamSx3("CS0_CODPLA")[1])),Padr(aLoadRes[ECD_COD_PLA],Len(CS0_CODPLA))))//"Plan. Conta Ref."
		aAdd(aRespostas,If(Empty(aLoadRes[ECD_VER_PLA]),Space(CT1->(TamSx3("CS0_VERPLA")[1])),Padr(aLoadRes[ECD_VER_PLA],Len(CS0_VERPLA))))//"Versão"

		If lLeiaute7
			aAdd(aRespostas,If(Empty(aLoadRes[ECD_TRI_UNI]),2,Val(aLoadRes[ECD_TRI_UNI]))) //"Arquivo Trimestral Unificado?"

			If GetNewPar("MV_ECDTRIA", .F.) 			
				aAdd(aRespostas,If(Empty(aLoadRes[ECD_REV_ANT]),Space(TamSx3("CS0_CODREV")[1]),Padr(aLoadRes[ECD_REV_ANT],Len(CS0_CODREV))))
			EndIf
		EndIf
		
	ElseIf cModEsc == "FCO"
		aAdd(aPerguntas,{1,STR0051	,CTOD("01/01/"+Str(Year(dDataBase),4)),"","","",,60,.T.}) //"Periodo Inicial Lcto"
		aAdd(aPerguntas,{1,STR0052	,CTOD("31/12/"+Str(Year(dDataBase),4)),"","","",,60,.T.}) //"Periodo Final Lcto"
		aAdd(aPerguntas,{1,STR0053	,CTOD("31/12/"+Str(Year(dDataBase),4)),"","","",,60,.F.}) //"Apuração do Exercicio(L/P)"
		aAdd(aPerguntas,{1,STR0050	,Space(CTG->(TamSx3("CTG_CALEND")[1])),"@!","ExistCpo('CTG',aRespSped4[4],1)","CTG",,03,.T.})  //"Calendario"
		aAdd(aPerguntas,{1,STR0054	,Space(CTO->(TamSx3("CTO_MOEDA")[1])),"@!","ExistCpo('CTO',aRespSped4[5],1)","CTO",,05,.T.}) //"Moeda"
		aAdd(aPerguntas,{1,STR0055	,"1","@!","","SLD",,05,.T.}) //"Tipo de Saldo"
		aAdd(aPerguntas,{1,STR0056	,Space(nTamConta),"@!","","CT1",,50,.F.}) //"Conta De"
		aAdd(aPerguntas,{1,STR0057 	,Repl("Z",nTamConta),"@!","","CT1",,50,.F.})  //"Conta Ate"
		aAdd(aPerguntas,{1,STR0173  ,Space(CS0->(TamSx3("CS0_CODPLA")[1])),"@!","","CVN1",,50,.F.})//"Plan. Conta Ref."
		aAdd(aPerguntas,{1,STR0184  ,Space(CS0->(TamSx3("CS0_VERPLA")[1])),"@!",""," ",,50,.F.})//"Versão"
		
		aRespostas := {CTOD("01/01/"+Str(Year(dDataBase),4)),CTOD("31/12/"+Str(Year(dDataBase),4)),CTOD("31/12/"+Str(Year(dDataBase),4)),Space(CTG->(TamSx3("CTG_CALEND")[1])),Space(CTO->(TamSx3("CTO_MOEDA")[1])),"1",Space(nTamConta),Repl("Z",nTamConta)}
		aAdd(aRespostas,Space(CS0->(TamSx3("CS0_CODPLA")[1])))//"Plan. Conta Ref."
		aAdd(aRespostas,Space(CS0->(TamSx3("CS0_VERPLA")[1])))//"Versão"
	EndIf

ElseIf cPasso == '5'
	If cModEsc == "ECD"
		// Passo 3
		aAdd(aPerguntas,{1,STR0058			,CTOD(""),"","","",,60,.F.}) //"Periodo Inicial Demons"
		aAdd(aPerguntas,{1,STR0069			,CTOD(""),"","","",,60,.F.}) //"Periodo Final Demons"
		aAdd(aPerguntas,{1,STR0059			,Space(CTN->(TamSx3("CTN_CODIGO")[1]))+" ","@!",,"CTN",,,.F.}) //"Cod. Conf. Bal. Patrim"
		aAdd(aPerguntas,{1,STR0068			,Space(CTN->(TamSx3("CTN_CODIGO")[1]))+" ","@!",,"CTN",,,.F.}) //"Cod. Conf. DRE"	
		aAdd(aPerguntas,{1,STR0060 			,Space(500) ,"@!",,"DIR","BloqField()",100,.F.}) //"Outras Demonstracoes"
		aAdd(aPerguntas,{3,STR0070			,1	,{STR0235,STR0234},65,"",.T.}) // "Processa C. Custo ?" //"2-Sim" //"1-Não"
	
		If lLeiaute2
	 		aAdd(aPerguntas,{3,STR0140			,2	,{"DLPA","DMPL"},65,"",.T.})   //"J210:Indicador do tipo de demonstração"
			aAdd(aPerguntas,{1,STR0141			,Space(CTN->(TamSx3("CTN_CODIGO")[1]))+" ","@!",,"CTN",,,.F.}) //"J210: Cod.Conf.Dem. "
			aAdd(aPerguntas,{1,STR0142			,Space(CTN->(TamSx3("CTN_CODIGO")[1]))+" ","@!",,"CTN","BloqField()",,.F.})  //"J310: Cod.Conf.DFC"
			aAdd(aPerguntas,{1,STR0143			,Space(CTN->(TamSx3("CTN_CODIGO")[1]))+" ","@!",,"CTN","BloqField()",,.F.})  //"J410: Cod.Conf.DVA"
	 		aAdd(aPerguntas,{3,STR0144			,2	,{STR0065,STR0066}	,65,"",.T.,"!lLeiaute7"})   //"J200:Historico Fato Contabil - Cadastrar"##"1-Sim"##"2-Nao"
	 		aAdd(aPerguntas,{3,STR0145			,1	,{STR0065,STR0066}	,65,"",.T.})   //"J215:Detalhar Fato Contabil - Detalhar"##"1-Sim"##"2-Nao"
	
			aAdd(aPerguntas,{1,STR0213 	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Dem. Abrang. do Período
			aAdd(aPerguntas,{1,STR0214 	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Dem. Fluxos de Caixa
			aAdd(aPerguntas,{1,STR0215 	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Dem. do Valor Adicionado
			aAdd(aPerguntas,{1,STR0216 	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Notas Explicativas
			aAdd(aPerguntas,{1,STR0217	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Relatório da Administração
			aAdd(aPerguntas,{1,STR0218 	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Parecer dos Auditores
			aAdd(aPerguntas,{1,STR0219 	,Space(500) ,"@!",,"DIR","!lLeiaute7",100,.F.}) //Outros
			aAdd(aPerguntas,{1,STR0221 	,Space(500) ,"@!",,"DIR","EcdVldSubs()",100,.F.}) //Termo de Substituição da ECD
			aAdd(aPerguntas,{3,STR0242	,1			,aMotSubst			,190,"",.T.,"EcdVldSubs() .And. lLeiaute7"})       //Motivo de Substituição

			
			aRespostas := { 	If (Empty(aLoadRes[ECD_DATA_DEMINI]),CTOD(""),CTOD(aLoadRes[ECD_DATA_DEMINI])),;
												If (Empty(aLoadRes[ECD_DATA_DEMFIM]),CTOD(""),CTOD(aLoadRes[ECD_DATA_DEMFIM])),;
			                	If (Empty(aLoadRes[ECD_COD_BALPAT]) ,Space(CTN->(TamSx3("CTN_CODIGO")[1])),Padr(aLoadRes[ECD_COD_BALPAT],Len(CTN->CTN_CODIGO))),;
												If (Empty(aLoadRes[ECD_COD_DRE]) ,Space(CTN->(TamSx3("CTN_CODIGO")[1])),Padr(aLoadRes[ECD_COD_DRE],Len(CTN->CTN_CODIGO))),;
												Space(500),;
			                	If (Empty(aLoadRes[ECD_PROC_CUSTO]),1,Val(aLoadRes[ECD_PROC_CUSTO])),;
												If (Empty(aLoadRes[ECD_SEL_DLPA_DMPL]),2,Val(aLoadRes[ECD_SEL_DLPA_DMPL])),;
												If (Empty(aLoadRes[ECD_COD_DMPL]) ,Space(CTN->(TamSx3("CTN_CODIGO")[1])),Padr(aLoadRes[ECD_COD_DMPL],len(CTN->CTN_CODIGO))),;	
												Space(CTN->(TamSx3("CTN_CODIGO")[1])),;
												Space(CTN->(TamSx3("CTN_CODIGO")[1])),;
												If (lLeiaute7,2, If(Empty(aLoadRes[ECD_CAD_FATO_CTB]),1,Val(aLoadRes[ECD_CAD_FATO_CTB]))),;
												If (Empty(aLoadRes[ECD_DET_FATO_CTB]),1,Val(aLoadRes[ECD_DET_FATO_CTB])),;
												If (Empty(aLoadRes[ECD_OUT_RAP ]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_RAP ],500)),; 
												If (Empty(aLoadRes[ECD_OUT_DFC ]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_DFC ],500)),; 
												If (Empty(aLoadRes[ECD_OUT_DVA ]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_DVA ],500)),; 
												If (Empty(aLoadRes[ECD_OUT_NTE ]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_NTE ],500)),; 
												If (Empty(aLoadRes[ECD_OUT_RADM]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_RADM],500)),; 
												If (Empty(aLoadRes[ECD_OUT_PRAU]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_PRAU],500)),; 
												If (Empty(aLoadRes[ECD_OUT_OTR ]) .Or. lLeiaute7,Space(500),Padr(aLoadRes[ECD_OUT_OTR ],500)),; 
												Space(500),;
												1}
		Else
	 		aRespostas := {CTOD(""),CTOD(""),Space(CTN->(TamSx3("CTN_CODIGO")[1])),Space(CTN->(TamSx3("CTN_CODIGO")[1])),Space(500),1}
		EndIf
		
	ElseIf cModEsc == "FCO"
		aAdd(aPerguntas,{1,STR0100+"( X  ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//""Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( F  ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//"Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( TR ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//"Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( TF ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//"Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( TS ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//"Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( EF ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//"Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( IF ) ?"	,Space(1),"@!","","SLD",,05,.F.})	 //"Tipo de Saldo Corresp. Lanc."
		aAdd(aPerguntas,{1,STR0100+"( IS ) ?"	,Space(1),"@!","","SLD",,05,.F.}) 	//"Tipo de Saldo Corresp. Lanc."
		aRespostas := {Space(1),Space(1),Space(1),Space(1),Space(1),Space(1),Space(1),Space(1)}
	EndIf
	
Endif

aAdd(aRet,aPerguntas)
aAdd(aRet,aRespostas)

RestArea( aArea )
Return aRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidaParam  ºAutor  ³Microsiga			º Data ³04/02/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida as respostas das perguntas genéricas	              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidaParam(aPergGener,aResGener,lPos,bValid)

Local aArea    	:= GetArea()
Local aMsgAlert := {}
Local nX 		:= 0
Local lRet		:= .T.
Local cMsgAlert := ""

Default lPos	:= .F.
Default bValid 	:= {||.T.}


For nX := 1 To Len(aResGener)
	If Empty(aResGener[nX]).And. Iif(aPergGener[nX][1]==1,aPergGener[nX][9],aPergGener[nX][7])
		Aadd(aMsgAlert,aPergGener[nX][2])
		lRet := .F.
	EndIf
Next

If !Empty(aMsgAlert)
	cMsgAlert:=STR0061+CRLF+CRLF //"Campos obrigatórios não preenchidos: "
	For nX := 1 To Len(aMsgAlert)
		cMsgAlert += aMsgAlert[nX]+CRLF
	Next
	lRet:= .F.
EndIf

If lRet .and. Len(aResGener) == 3 .and.  Valtype(aResGener[2]) == "N" .and. aResGener[2]==3 .and. aResGener[3]== 5
	If CSE->(FieldPos("CSE_VALDEB")) == 0
		cMsgAlert := If(Empty(cMsgAlert), STR0250+" "+STR0258 , cMsgAlert) 
	lRet := .F.
	EndIF
EndIF
If lRet
	lRet := Eval(bValid,@cMsgAlert)
	If !lRet
		cMsgAlert := If(Empty(cMsgAlert), StrTran(STR0061,":","."), cMsgAlert) //"Campos obrigatórios não preenchidos: "
	EndIf
EndIf

If !lRet
	MsgAlert(cMsgAlert)
Elseif lRet .And. lPos
	Return lRet
Else
	lRet := .T.
EndIf

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidaChckBoxºAutor  ³Microsiga			º Data ³03/02/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o checkbox foi preenchido			              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 			                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ValidaChckBox(aRespChK)
Local lRet := .F.
Local nX   := 0				

For nX := 1 To Len(aRespChK)
	If aRespChK[nX]
		lRet := .T.
		Exit
	EndIf
Next

If !lRet	           
	Help("",1,"VldChckBox", STR0062,STR0063,1,0)  //"Nenhum item foi selecionado para escrituração."###"Verifique se clicou em um dos itens"
EndIf

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EcdProcessaºAutor  ³Microsiga          º Data ³  02/26/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EcdProcessa( cEmp, aFils, aRespSped1, aRespSped2, aRespSped3, aRespSped4, aRespSped5, cMatriz, cModEsc, aTrimestre, bIncTree, bEcdFatoCtb)

Local oProcess	:= Nil
Local aEntRef 	:= {"00","10","20"}
Local lContinua := .T.
Local lI051		:= .F.
Local cLinkDoc  := "https://tdn.totvs.com/display/public/PROT/ECD0038_ERRO_I051_DUPLICIDADE_COD_CCUS"
Local lProcCC   := .F.

Default cMatriz 	:= ""
Default aTrimestre 	:= {"",""}
Default bIncTree	:= {||.T.}
Default bEcdFatoCtb := {||.T.}
Default lAutomato	:= .F.

aParamEcd := Array( ECD_NUMCOLS )

aParamEcd[ ECD_CODEMP		] := cEmp
aParamEcd[ ECD_AFILS		] := aFils
aParamEcd[ ECD_TIPOESC		] := aRespSped1[1]
aParamEcd[ ECD_SIT_ESP		] := aRespSped1[2]

aParamEcd[ ECD_DATA_INI		] := aRespSped4[1]
aParamEcd[ ECD_DATA_FIM		] := aRespSped4[2]
aParamEcd[ ECD_DATA_LP		] := aRespSped4[3]
aParamEcd[ ECD_CALENDARIO	] := aRespSped4[4]
aParamEcd[ ECD_MOEDA		] := aRespSped4[5]
aParamEcd[ ECD_TIPO_SALDO	] := aRespSped4[6]
aParamEcd[ ECD_CONTA_INI	] := aRespSped4[7]
aParamEcd[ ECD_CONTA_FIM	] := aRespSped4[8]
aParamEcd[ ECD_COD_PLA	    ] := aRespSped4[9]
aParamEcd[ ECD_VER_PLA	    ] := aRespSped4[10]

//I051 checagem de conta e centro de custos duplicado no Plano Referencial ou Visão Gerencial.

If lLeiaute9 //ChkI051(/*ECD_COD_PLA*/,/*ECD_VER_PLA*/,/*ECD_COD_BALPAT*/ ,/*ECD_COD_DRE*/ )
	//Apenas verifico se usado Centro de Custos
	lProcCC:= IIf(aRespSped5[6]== 2 ,.T.,.F.)
	If aRespSped1[15] == 1 .And. aRespSped5[6] == 2 .And. !Empty(aRespSped4[9]) .And. !Empty(aRespSped4[10]) // Verifica duplicidade no plano referencial
		lI051 := ChkI051(aRespSped4[9],aRespSped4[10],aRespSped5[3] ,aRespSped5[4],lProcCC )
		If !lI051
			//ApMsgInfo(STR0272, STR0274, )
			CTBS010Msg(STR0272, STR0274,cLinkDoc)
		EndIf	
	ElseIf aRespSped1[15] == 2 .And. aRespSped5[6] == 2 .And. !Empty(aRespSped5[3]) .And.  !Empty(aRespSped5[4]) // verifico duplicidade na visão gerencial
		lI051 := ChkI051( aRespSped4[9],aRespSped4[10],aRespSped5[3] ,aRespSped5[4],lProcCC )
		If !lI051			
			//ApMsgInfo(STR0273, STR0274, )
			CTBS010Msg(STR0273,STR0274,cLinkDoc)
		EndIf
	EndIf
EndIf

If lLeiaute4 .and. aRespSped1[11]==1
	DbSelectArea( "CS0" )	

	If ColumnPos( 'CS0_MOEFUN' )  == 0
		MsgAlert( STR0188) //STR0188  //"Ambiente não preparado para trabalhar com moeda funcional favor atualizar dicionarios."
		lMoedfun :=.F.
	Else
		dbSelectArea("CTG")
		dbSetOrder(2)
		MsSeek(xFilial("CTG")+aParamEcd[ECD_CALENDARIO])
		lMoedfun:=.T.
		aParamEcd[ ECD_MOE_FUN	]:=CtbEcdMFTaxas( CTG->CTG_EXERC,aRespSped4[5])
	EndIf
Endif  


If cModEsc == "ECD"

	If lLeiaute2
		If aRespSped1[3] > 0
			aParamEcd[ ECD_INDSITPER    ] := Alltrim(Str(aRespSped1[3]-1))
		EndIf
		
		aParamEcd[ ECD_EXISTNIRE		] := aRespSped1[4]
		aParamEcd[ ECD_FIN_ESC			] := aRespSped1[5]
		aParamEcd[ ECD_HASH_ESC_SUBST	] := aRespSped1[6]
		aParamEcd[ ECD_NIRE_ESC_SUBST	] := aRespSped1[7]
    EndIf

    If lLeiaute3
		aParamEcd[ ECD_GDE_PORTE		] := aRespSped1[8]
		aParamEcd[ ECD_SCP_IND			] := aRespSped1[9]
		aParamEcd[ ECD_PLANOREF			] := aRespSped1[10]
		aParamEcd[ ECD_COD_SCP			] := If( aRespSped1[9] == 3, aRespSped2[4], "")
    Endif
    
    If (lLeiaute5 .Or. lLeiaute6) 
    	aParamEcd[ ECD_OUT_CEC			] := aRespSped1[12] //Conglomerado Econômico bloco "K" sempre irá gravar N até a liberação do mesmo
		If ( CS0->( ColumnPos( "CS0_IDBLK" )) > 0 )
    		aParamEcd[ ECD_IDBLK			] := aRespSped1[13] 
		EndIf
    EndIf
    
	aParamEcd[ ECD_OUT_INSC		] := aRespSped2[1]
	aParamEcd[ ECD_OUT_UF		] := aRespSped2[2]
	aParamEcd[ ECD_INSCRICAO	] := aRespSped2[3]

	If aRespSped3[1] <= 4
		aParamEcd[ ECD_IND_ESC		] := aRespSped3[1]
	ElseIf aRespSped3[1] == 5
		aParamEcd[ ECD_IND_ESC		] := 6 //ECD da SCP
	EndIf
	
	aParamEcd[ ECD_NUM_ORDEM	] := aRespSped3[2]
	aParamEcd[ ECD_NATUREZA		] := aRespSped3[3]

	aParamEcd[ ECD_DATA_DEMINI	] := aRespSped5[1]
	aParamEcd[ ECD_DATA_DEMFIM	] := aRespSped5[2]
	aParamEcd[ ECD_COD_BALPAT	] := aRespSped5[3]
	aParamEcd[ ECD_COD_DRE		] := aRespSped5[4]
	aParamEcd[ ECD_OUT_DEM		] := aRespSped5[5]
	
	aParamEcd[ ECD_PROC_CUSTO	] := If(aRespSped5[6] == 1,.F.,.T.)
	
	If lLeiaute2
		aParamEcd[ ECD_SEL_DLPA_DMPL ] 	:= aRespSped5[7]
		aParamEcd[ ECD_COD_DLPA ] 		:= If(aRespSped5[7]==1,aRespSped5[8],"")
		aParamEcd[ ECD_COD_DMPL ] 		:= If(aRespSped5[7]==2,aRespSped5[8],"")
		aParamEcd[ ECD_COD_DFC ] 		:= aRespSped5[9]
		aParamEcd[ ECD_COD_DVA ] 		:= aRespSped5[10]
		aParamEcd[ ECD_CAD_FATO_CTB ] 	:= aRespSped5[11]
		aParamEcd[ ECD_DET_FATO_CTB ] 	:= aRespSped5[12]
		aParamEcd[ ECD_OUT_RAP		] := aRespSped5[13]	//Tipo DOC J800 001 Demonstração do Resultado Abrangente do Período
		aParamEcd[ ECD_OUT_DFC		] := aRespSped5[14]	//Tipo DOC J800 002 Demonstração dos Fluxos de Caixa
		aParamEcd[ ECD_OUT_DVA		] := aRespSped5[15]	//Tipo DOC J800 003 Demonstração do Valor Adicionado
		aParamEcd[ ECD_OUT_NTE		] := aRespSped5[16]	//Tipo DOC J800 010 Notas Explicativas
		aParamEcd[ ECD_OUT_RADM		] := aRespSped5[17]	//Tipo DOC J800 011 Relatório da Administração
		aParamEcd[ ECD_OUT_PRAU		] := aRespSped5[18]	//Tipo DOC J800 012 Parecer dos Auditores
		aParamEcd[ ECD_OUT_OTR		] := aRespSped5[19]	//Tipo DOC J800 099 Outros
		aParamEcd[ ECD_OUT_TVFS		] := aRespSped5[20]	//Tipo DOC J801 000	Termo de Verificação para Fins de Substituição ECD
		
	EndIf

	If lLeiaute7
		aParamEcd[ ECD_TRI_UNI	  ] := aRespSped4[11]

		If GetNewPar("MV_ECDTRIA", .F.) 
			aParamEcd[ ECD_REV_ANT	  ] := aRespSped4[12]
		Endif

		aParamEcd[ ECD_MOT_SUBST	] := aRespSped5[21]		
	EndIf

	If lLeiaute8
		aParamEcd[ ECD_MUD_PLC	] := aRespSped1[14]
		aParamEcd[ ECD_AMR_PLR	] := aRespSped1[15]
	EndIf

	aParamEcd[ ECD_PROC_CAD		] := .T.
	aParamEcd[ ECD_PROC_MOV		] := .T.
	aParamEcd[ ECD_PROC_SALDO	] := .T.
	aParamEcd[ ECD_PROC_DEM		] := .T.

ElseIf cModEsc == "FCO"

	aParamEcd[ ECD_ESCR_ORI_RET	] := aRespSped2[1]
	aParamEcd[ ECD_QUALI_PJ		] := aRespSped2[2]
	aParamEcd[ ECD_REC_ANTERIOR	] := aRespSped2[3]
	aParamEcd[ ECD_IND_ESC		] := 5   			//FCONT
	
	aParamEcd[ ECD_CTA_APURACAO ] := aRespSped3[1]
	aParamEcd[ ECD_PER_APURACAO	] := aRespSped3[2]
	aParamEcd[ ECD_FORMA_TRIBUT	] := aRespSped3[3]
	
	aParamEcd[ ECD_SLD_REC_DESP ] := aRespSped3[4]
	aParamEcd[ ECD_GRU_REC_DESP ] := aRespSped3[5]
	aParamEcd[ ECD_DAT_REC_DESP ] := aRespSped3[6]
	aParamEcd[ ECD_PROC_CUSTO   ] := If(aRespSped3[8] == 2,.F.,.T.)
	aParamEcd[ ECD_APURCCUSTO   ] := aRespSped3[9]
	//
	aParamEcd[ ECD_APCTAREF     ] := C010Ref( aRespSped3[1], aRespSped3[9], aEntRef[ aParamEcd[ECD_QUALI_PJ] ], aParamEcd[ ECD_COD_PLA ] ,aParamEcd[ ECD_VER_PLA ])

	aParamEcd[ ECD_PROC_MOV     ] := If(aRespSped3[7] == 2,.F.,.T.)
	aParamEcd[ ECD_PROC_CAD		] := .T.
	aParamEcd[ ECD_PROC_SALDO	] := aParamEcd[ ECD_PROC_MOV ]
	aParamEcd[ ECD_PROC_DEM		] := .F.

	aParamEcd[ ECD_TIP_X_LANC	] := aRespSped5[1]
	aParamEcd[ ECD_TIP_F_LANC	] := aRespSped5[2]
	aParamEcd[ ECD_TIP_TR_LANC	] := aRespSped5[3]
	aParamEcd[ ECD_TIP_TF_LANC	] := aRespSped5[4]
	aParamEcd[ ECD_TIP_TS_LANC	] := aRespSped5[5]
	aParamEcd[ ECD_TIP_EF_LANC	] := aRespSped5[6]
	aParamEcd[ ECD_TIP_IF_LANC	] := aRespSped5[7]
	aParamEcd[ ECD_TIP_IS_LANC	] := aRespSped5[8]
	aParamEcd[ ECD_ALUCROARBIT  ] := aTrimestre[1]
	aParamEcd[ ECD_ARRAPURTRIM  ] := aTrimestre[2]
	If aRespSped1[3] > 0
		aParamEcd[ ECD_INDSITPER    ] := Alltrim(Str(aRespSped1[3]-1))
	EndIf
EndIf

If aParamEcd[ECD_SIT_ESP] <> 1  //Z=NORMAL EH OPCAO 1
	dbSelectArea("CTG")
	dbSetOrder(2)
	lContinua := MsSeek(xFilial("CTG")+aParamEcd[ECD_CALENDARIO]+DTOS(aParamEcd[ ECD_DATA_INI]))
	If !lContinua
		If Aviso(STR0005, STR0154 , {STR0075,STR0076}) == 1  //"Atencao"##"Situacao Especial requer calendario contemplando periodo inicial ou final de acordo com evento. Continuar Processamento ?"##"Sim"##"Nao"
    	   lContinua := .T.
		EndIf
	Else
		dAuxFim := CTG->CTG_DTFIM
		
		While CTG->(! Eof() .And. CTG_FILIAL == xFilial("CTG") .And. CTG_CALEND == aParamEcd[ECD_CALENDARIO])
			dAuxFim := CTG->CTG_DTFIM
			CTG->( dbSkip() )
		EndDo
		
		If dAuxFim <> aParamEcd[ECD_DATA_FIM]
			lContinua := .F.
			If Aviso(STR0005, STR0154 , {STR0075,STR0076}) == 1  //"Atencao"##"Situacao Especial requer calendario contemplando periodo inicial ou final de acordo com evento. Continuar Processamento ?"##"Sim"##"Nao"
    		   lContinua := .T.
			EndIf
		EndIf		
	EndIf
EndIf

If lContinua
	ECDSave('RespEcd',aParamEcd,"")
	If !lAutomato
		oProcess:= MsNewProcess():New( {|lEnd| EcdExport( lEnd, oProcess, aParamEcd, cMatriz, cModEsc, bIncTree, bEcdFatoCtb,aPerCalTri ),EcdGetMsg()} )
		oProcess:Activate()
	Else
		EcdExport( .F.,, aParamEcd, cMatriz, cModEsc, , bEcdFatoCtb, aPerCalTri )
	EndIf
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBSVLDEM ºAutor  ³Alvaro Camillo Neto º Data ³  23/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o livro para verificar se ele tem uma visao         º±±
±±º          ³ cadastrada                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBSVLDEM(aRespLivro,nPerg)
Local lRet := .T.
Local cLivro 		:= ""
Local aSetOfBook 	:= {}   
Local aArea := GetArea()
Local cQuery 	 :=""
Local cQueryCSE  :=""
Local cJ210 	 :=""
Local lTem210    :=.F.

Default aRespLivro 	:= {}
Default nPerg 		:= 1

cLivro := aRespLivro[nPerg]

dbSelectArea("CTN")
CTN->(dbSetOrder(1))

If !Empty(cLivro)	
	If !(CTN->(dbSeek(xFilial("CTN") + cLivro )))
		Help("ECDDem",1,"HELP",STR0114,STR0115,1,0)   //"Demonstrativo"##"Livro não cadastrado"
		lRet := .F.
	EndIf
	
	aSetOfBook := CtbSetOf( cLivro )
	If lRet .And. !Empty(aSetOfBook) .And. Empty(aSetOfBook[5]) 
		Help("ECDDem",1,"HELP",STR0114,STR0116,1,0)   //"Demonstrativo"##"Livro sem visão gerencial"
		lRet := .F.
	EndIf
	
EndIf
//Se DMPL ou DLPA preenchido e valido
If lRet .And. nPerg == 8 .and. Len(aRespSped4) > 11 .And. GetNewPar("MV_ECDTRIA",.F.) .and. !Empty(cLivro)
	CSE->(dbSetOrder(1))
	If !Empty(aRespSped4[12]) .and. CSE->(dbSeek(xFilial("CSE")+aRespSped4[12]))

		cJ210 := iif(aRespLivro[7]==1,'3','4') //3 - DLPA, 4 - DMPL
		cQuery := " SELECT CSE_PERIOD FROM "+RetSQLName("CSE")+;
				" WHERE CSE_FILIAL = '"+xFilial("CSE")+"' AND "+;
				" CSE_CODREV = '"+aRespSped4[12]+"' AND "+;
				" CSE_TPDEM = '"+cJ210+"' AND "+;							  
				" D_E_L_E_T_ = ' ' "+;
				" GROUP BY CSE_PERIOD "
		cQuery := ChangeQuery(cQuery)
		cQueryCSE := GetNextAlias()
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQueryCSE)
		While !(cQueryCSE)->(Eof())
			If AllTrim((cQueryCSE)->CSE_PERIOD) == "12" 
				lTem210 := .T. //DLPA ou DMPL
			EndIf
			If lTem210 
				Exit
			EndIf
			(cQueryCSE)->(dbSkip())						
		EndDo
		(cQueryCSE)->(dbCloseArea())
		If !lTem210 
			Help("ECDDem",1,"HELP",STR0150,STR0285,1,0)   //"Detalhe Fato Contabil"##"Não foi encontrado o período anual (acumulado) na revisão anterior informada.""
			lRet := MsgYesNo(STR0281 +CRLF+ STR0282 +CRLF+ STR0283)
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbTamFil ºAutor  ³Elton C.			 º Data ³  23/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o tamanho do campo 							      º±±
±±º          ³                                                   		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CtbTamFil(cGrupo,nTamPad)
Local nSize := 0

DbSelectArea("SXG")
DbSetOrder(1)

IF DbSeek(cGrupo)
	nSize := SXG->XG_SIZE
Else
	nSize := nTamPad
Endif

Return nSize
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C010DlgTrim ºAutor  ³Microsiga         º Data ³  28/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Dialog com Informacoes a ser digitada quando o tipo de      º±±
±±º          ³apuracao eh trimestral                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function C010DlgTrim(aRespSped3,aTrimestre)
Local lRetorno := .T., nOpca := 0
Local oDlg
Local oGroupLucr, oGroupApur
Local nRadio1T, nRadio2T, nRadio3T, nRadio4T 
Local oRadio1T, oRadio2T, oRadio3T, oRadio4T
Local nCombo1T, nCombo2T, nCombo3T, nCombo4T
Local oCombo1T, oCombo2T, oCombo3T, oCombo4T
Local aTitGroup := {STR0101, STR0102} 			   					//"Lucro Arbitrado"##"Apuração do Trimestre"
Local aTitLucro := {"1-T", "2-T", "3-T", "4-T" }
Local aSayLucro := {STR0103, STR0104} 								//"Sem Lucro Arbitrado"##"Com Lucro Arbitrado"
Local aSayApur  := {STR0105, STR0106, STR0107, STR0108 }			//"1o. Trimestre (1-T)"##"2o. Trimestre (2-T)"##"3o. Trimestre (3-T)"##"4o. Trimestre (4-T)"
Local aLisOpc   := {STR0109, STR0110, STR0111, STR0112, STR0113} 	//"0-Fora do Periodo da Escrituracao"##"1-Real"##"2-Arbitrado"##"3-Presumido"##"4-Inativo (Somente Trimestral)"
			

If ( aRespSped3[2] == 1 .And. aRespSped3[3] == 2 ) .OR. ; //Forma de Apuracao Anual e Forma de Tributacao = Real Arbitrada
   ( aRespSped3[2] == 2 )
	//cria Dialog
	DEFINE MSDIALOG oDlg FROM  20,05 TO 480,620 TITLE STR0117 PIXEL  //"Forma de Apuração Trimestral"
		nRadio1T := nRadio2T := nRadio3T := nRadio4T := 1
		nCombo1T := nCombo2T := nCombo3T := nCombo4T := 2
				
	If aRespSped3[2] == 1 .And. aRespSped3[3] == 2 //Forma de Apuracao Anual e Forma de Tributacao = Real Arbitrada
		oGroupLucr := TGroup():New( 15, 10, 080, 300, aTitGroup[1], oDlg, CLR_HBLUE, , .T.)

		@ 30, 100 SAY aTitLucro[1] PIXEL OF oDlg          //1-T
		@ 30, 140 SAY aTitLucro[2] PIXEL OF oDlg          //2-T
		@ 30, 180 SAY aTitLucro[3] PIXEL OF oDlg          //3-T
		@ 30, 220 SAY aTitLucro[4] PIXEL OF oDlg          //4-T

		@ 40, 15 SAY aSayLucro[1] PIXEL OF oDlg          //Sem Lucro Arbitrado
		@ 50, 15 SAY aSayLucro[2] PIXEL OF oDlg          //Com Lucro Arbitrado
	
		@ 40, 103 RADIO oRadio1T VAR nRadio1T ITEMS "", "" SIZE 7,5 PIXEL OF oDlg
		@ 40, 143 RADIO oRadio2T VAR nRadio2T ITEMS "", "" SIZE 7,5 PIXEL OF oDlg
		@ 40, 183 RADIO oRadio3T VAR nRadio3T ITEMS "", "" SIZE 7,5 PIXEL OF oDlg
		@ 40, 223 RADIO oRadio4T VAR nRadio4T ITEMS "", "" SIZE 7,5 PIXEL OF oDlg

	ElseIf aRespSped3[2] == 2  //Forma de Apuracao Trimestral
		oGroupApur := TGroup():New( 15, 10, 190, 300, aTitGroup[2], oDlg, CLR_HBLUE, , .T.)
		
		@ 035, 15 SAY aSayApur[1] PIXEL OF oDlg          //1O. TRIMESTRE
		@ 055, 15 SAY aSayApur[2] PIXEL OF oDlg          //2O. TRIMESTRE
		@ 075, 15 SAY aSayApur[3] PIXEL OF oDlg          //30. TRIMESTRE
		@ 095, 15 SAY aSayApur[4] PIXEL OF oDlg          //40. TRIMESTRE
		@ 035, 85 COMBOBOX oCombo1T VAR nCombo1T PROMPTS aLisOpc SIZE 200, 20 PIXEL OF oDlg
		@ 055, 85 COMBOBOX oCombo2T VAR nCombo2T PROMPTS aLisOpc SIZE 200, 20 PIXEL OF oDlg
		@ 075, 85 COMBOBOX oCombo3T VAR nCombo3T PROMPTS aLisOpc SIZE 200, 20 PIXEL OF oDlg
		@ 095, 85 COMBOBOX oCombo4T VAR nCombo4T PROMPTS aLisOpc SIZE 200, 20 PIXEL OF oDlg

	EndIf
	
	DEFINE SBUTTON FROM 205,240 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 205,270 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso 
                                                                // para saida com ESC
	lRetorno := If(nOpca==0, .F., .T.)

	If lRetorno
        //inicializa
		aTrimestre[1] := ""
		aTrimestre[2] := ""
		If aRespSped3[2] == 1 .And. aRespSped3[3] == 2 //Forma de Apuracao Anual e Forma de Tributacao = Real Arbitrada
		    //atribui lucro arbitrario
			aTrimestre[1] += If(nRadio1T==1,"0", "1")
			aTrimestre[1] += If(nRadio2T==1,"0", "1")
			aTrimestre[1] += If(nRadio3T==1,"0", "1")
			aTrimestre[1] += If(nRadio4T==1,"0", "1")
		ElseIf aRespSped3[2] == 2  //Forma de Apuracao Trimestral
			//atribui apuracao trimestre
			nCombo1T := If( ValType(nCombo1T)=="N",nCombo1T,Val(Substr(nCombo1T,1,1))+1 ) 
			nCombo2T := If( ValType(nCombo2T)=="N",nCombo2T,Val(Substr(nCombo2T,1,1))+1 ) 
			nCombo3T := If( ValType(nCombo3T)=="N",nCombo3T,Val(Substr(nCombo3T,1,1))+1 ) 
			nCombo4T := If( ValType(nCombo4T)=="N",nCombo4T,Val(Substr(nCombo4T,1,1))+1 ) 
			aTrimestre[2] += Substr(aLisOpc[nCombo1T],1,1)
			aTrimestre[2] += Substr(aLisOpc[nCombo2T],1,1)
			aTrimestre[2] += Substr(aLisOpc[nCombo3T],1,1)
			aTrimestre[2] += Substr(aLisOpc[nCombo4T],1,1)
		EndIf

	EndIf	
EndIf

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³C010Ref   ºAutor  ³Microsiga           º Data ³  28/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca a conta referencial                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function C010Ref(ContaApu,CCustoApu,cEntRef, cCodPla,cVerPla)
Local aArea		:= GetArea()
Local cCtaRef  := Space(30)
DEFAULT cEntRef := '  '
DEFAULT cCodPla := " "
DEFAULT cVerPla := " "

If !Empty( cEntRef ) .And. !Empty( ContaApu )
	
	DbSelectArea( 'CVD' )
	If Empty(cCodPla)
		CVD->( DbSetOrder(3) )
		
		If MsSeek( xFilial("CVD") + PadR(cEntRef,Len(CVD->CVD_ENTREF)) + PadR(ContaApu,Len(CVD->CVD_CONTA)) + PadR(CCustoApu,Len(CVD->CVD_CUSTO)) )
			cCtaRef := CVD->CVD_CTAREF
		Endif
	Else
		CVD->( DbSetOrder(4) )//CVD_FILIAL+CVD_ENTREF+CVD_CODPLA+CVD_CONTA+CVD_CUSTO+CVD_VERSAO :TODO: Corrigir indice  
		
		If CVD->( MsSeek( xFilial("CVD") + PadR(cEntRef,Len(CVD->CVD_ENTREF)) +cCodPla+ PadR(ContaApu,Len(CVD->CVD_CONTA)) + PadR(CCustoApu,Len(CVD->CVD_CUSTO)) + cVerPla ) )
			cCtaRef := CVD->CVD_CTAREF
		Endif	
	Endif
Endif

RestArea( aArea )

Return(cCtaRef)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EcdFatoCtbºAutor  ³Microsiga           º Data ³  30/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui Registros J200/J215 Ref. DLPA/DMPL incluido no       º±±
±±º          ³registro J210                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function EcdFatoCtb(aRespSped5)
Local cMessage := ""
Local aWizFtContab
Local aWizFtCtb   := {}
Local aPanelWiz	:= {}
Local bFinalWiz := {|| }
Local oBold
Local cTxtFim := STR0146 //"Clique no botão finalizar para fechar o wizard e iniciar a inclusão dos dados."

Private cCadastro := ""

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD


If !Empty(aRespSped5[8]) .And. aRespSped5[11] == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array aWizCalen - Estrutura:                        ³
	//³ Posicao 1 - Titulo                                  ³
	//³         2 - Mensagem Explicativa                    ³
	//³         3 - bNext                                   ³
	//³         4 - bFinish                                 ³
	//³         5 - lPanel                                  ³
	//³         6 - lNoFist                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCadastro := STR0147  //"Cadastro Fatos Contabeis"
	aWizFtContab := {}
	aAdd(aWizFtContab, cCadastro)
	aAdd(aWizFtContab, STR0148)  //"J200/J215 - Cadastro/Detalhe Fato Contabil"
	aAdd(aWizFtContab, {||TSay():New( 50, 05, MontaBlock("{|| '"+cTxtFim+"' }"), aPanelWiz[1] , ,oBold,,,,.T.),.T.})
	aAdd(aWizFtContab, {||.T.})
	aAdd(aWizFtContab, .T.)
	aAdd(aWizFtContab, .F.)

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Paineis                                             ³
	//³ Array aWizPanel - Estrutura:                        |
	//³ Para cada linha dete array multidimensional         ³
	//³ Posicao 1 - Titulo do painel                        ³
	//³         2 - Mensagem Explicativa                    ³
	//³         3 - bNext                                   ³
	//³         4 - bFinish                                 ³
	//³         5 - lPanel                                  ³
	//³         6 - bBack                                   ³
	//³         7 - bExecute                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aWizFtCtb   := {}
	aPanelWiz	:= {}
	
	cMessage 	:= STR0149 //"Neste passo voce devera incluir os cadastros dos fatos contabeis necessarios para registro J200 da ECD."
	
	aAdd(aWizFtCtb, {cCadastro, cMessage, {||.T.}, {||.T.}, .T., {||.T.}, {||.T.} })  
	

	CtbWizard(aWizFtContab, aWizFtCtb, aPanelWiz, /*lCenter*/, bFinalWiz/*bValid*/, /*bInit*/, /*bWhen*/)
		
	dbSelectArea("CSN")
	SET FILTER TO CSN_FILIAL+CSN_CODREV = xFilial("CSN")+CS0->CS0_CODREV
	Set Key VK_F12 To EcdImpFtCt()
	AxCadastro("CSN",cCadastro)
	Set Key VK_F12 To 
	SET FILTER TO 
	
EndIf

If !Empty(aRespSped5[8]) .And. aRespSped5[12] == 1
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array aWizCalen - Estrutura:                        ³
	//³ Posicao 1 - Titulo                                  ³
	//³         2 - Mensagem Explicativa                    ³
	//³         3 - bNext                                   ³
	//³         4 - bFinish                                 ³
	//³         5 - lPanel                                  ³
	//³         6 - lNoFist                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCadastro := STR0150 //"Detalhe Fato Contabil"	
	aWizFtContab := {}
	aAdd(aWizFtContab, cCadastro)
	aAdd(aWizFtContab, STR0152)  //"J215-Detalhe Fato Contabil"
	aAdd(aWizFtContab, {||TSay():New( 50, 05, MontaBlock("{|| '"+cTxtFim+"' }"), aPanelWiz[1] , ,oBold,,,,.T.),.T.})
	aAdd(aWizFtContab, {||.T.})
	aAdd(aWizFtContab, .T.)
	aAdd(aWizFtContab, .F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Paineis                                             ³
	//³ Array aWizPanel - Estrutura:                        |
	//³ Para cada linha dete array multidimensional         ³
	//³ Posicao 1 - Titulo do painel                        ³
	//³         2 - Mensagem Explicativa                    ³
	//³         3 - bNext                                   ³
	//³         4 - bFinish                                 ³
	//³         5 - lPanel                                  ³
	//³         6 - bBack                                   ³
	//³         7 - bExecute                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aWizFtCtb   := {}
	aPanelWiz	:= {}
	cMessage 	:= STR0151 //"Neste passo voce devera incluir os detalhes dos fatos contabeis necessarios para registro J215 da ECD."
	
	aAdd(aWizFtCtb, {STR0152, cMessage, {||.T.}, {||.T.}, .T., {||.T.}, {||.T.} })  //"J215-Detalhe Fato Contabil"
	
	CtbWizard(aWizFtContab, aWizFtCtb, aPanelWiz, /*lCenter*/, bFinalWiz/*bValid*/, /*bInit*/, /*bWhen*/)
		
	If Select("CSO")		
		CSO->(dbCloseArea()) //Não retirar. Estava trazendo registros deletados. TCRefresh no CTBS001 não funcionou.
	EndIf
	dbSelectArea("CSO")	
	SET FILTER TO CSO_FILIAL+CSO_CODREV = xFilial("CSO")+CS0->CS0_CODREV
	Set Key VK_F12 To EcdImpDtFt()
	AxCadastro("CSO",cCadastro,,"VldCSOTOk()")
	Set Key VK_F12 To
	SET FILTER TO 	
	
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTS010FAT ºAutor  ³Microsiga           º Data ³  03/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa na tabela de fatos contabeis o historico digitado  º±±
±±º          ³em detalhe dos fatos contabeis                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function CTS010FAT()
Local lRet := .F.
lRet := CSN->(DBSEEK(XFILIAL("CSN")+CS0->CS0_CODREV+"J200"+M->CSO_CODFAT))
If lRet
	M->CSO_DESFAT := CSN->CSN_DESFAT
Else
	Help( " ",1,"REGNOIS")
	M->CSO_DESFAT := Space(Len(CSN->CSN_DESFAT))
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EcdImpFtCtºAutor  ³Microsiga           º Data ³  03/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Copia de revisao anterior o cadastro de fato contabil       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function EcdImpFtCt()
Local aPergFt 	:= {}
Local aRespFt	:= {Space(Len(CS0->CS0_CODREV))}
Local cFilter
Local nRecno
Local aCpoGrv
Local nX
Local nRecCS0 	:= CS0->( Recno() )
Local cRevAux 	:= CS0->CS0_CODREV
Local cCdFatAux := ""
Local oBrw    	:= GetMBrowse()

aAdd( aPergFt,{1,STR0153,Space(Len(CS0->(CS0_CODREV))),"@!",,"",,,.F.} )   //"Codigo da Revisao"

If 	ParamBox(aPergFt,"", @aRespFt)
	If !Empty(aRespFt[1])

		dbSelectArea("CSN")
		cFilter := CSN->( DBFilter() )
		SET FILTER TO

		dbSetOrder(1)
		If dbSeek( xFilial("CSN")+aRespFt[1] )

			While CSN->( ! Eof() .And. CSN->CSN_FILIAL+CSN->CSN_CODREV == xFilial("CSN")+aRespFt[1] )

				nRecno := CSN->( Recno() )
				
				aCpoGrv := {}
				For nX := 1 TO FCOUNT()
					aAdd(aCpoGrv, FieldGet(nX))
					If FieldName(nX) == "CSN_CODFAT"
						cCdFatAux := FieldGet(nX)
					EndIf
				Next
				
				If CSN->( ! dbSeek(xFilial("CSN")+cRevAux+"J200"+cCdFatAux ) )
					RecLock("CSN", .T.)
					For nX := 1 TO FCOUNT()
						FieldPut(nX, aCpoGrv[nX])
					Next
					CSN->CSN_CODREV := cRevAux 
					MsUnLock()
				EndIf
				
				dbSelectArea("CSN")
				dbGoto(nRecno)
				dbSkip()
				
			EndDo

			CS0->( dbGoto(nRecCS0) )
			dbSelectArea("CSN")
			SET FILTER TO &cFilter
			dbGoTop()   //refresh
			ECdGetDMPL()
			dbGoTop()   //refresh
			
			oBrw:Refresh(.T.)	
			  
		EndIf
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EcdImpDtFtºAutor  ³Microsiga           º Data ³  03/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Copia de revisao anterior os detalhes do fato contabil      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function EcdImpDtFt
Local aPergDetFt 	:= {}
Local aRespDetFt	:= {Space(Len(CS0->CS0_CODREV))}
Local cFilter
Local nRecno
Local aCpoGrv
Local nX
Local nRecCS0 		:= CS0->( Recno() )
Local cRevAux 		:= CS0->CS0_CODREV
Local cCdFatAux 	:= ""
Local cCdAglAux		:= ""
Local cCdIndAux		:= ""
Local cCdPerAux		:= ""
Local lInclDetFt	:= .T.
Local oBrw    		:= GetMBrowse()

aAdd(aPergDetFt,{1,STR0153,Space(Len(CS0->(CS0_CODREV))),"@!",,"",,,.F.})   //"Codigo da Revisao"

If 	ParamBox(aPergDetFt,"", @aRespDetFt)
	If !Empty(aRespDetFt[1])
		dbSelectArea("CSO")
		cFilter := CSO->( DBFilter() )
		SET FILTER TO
		dbSetOrder(1)
		If dbSeek( xFilial("CSO")+aRespDetFt[1] )

			While CSO->( ! Eof() .And. CSO->CSO_FILIAL+CSO->CSO_CODREV == xFilial("CSO")+aRespDetFt[1] )

				nRecno := CSO->( Recno() )
				
				aCpoGrv := {}
				For nX := 1 TO FCOUNT()
					aAdd(aCpoGrv, FieldGet(nX))
					If FieldName(nX) == "CSO_CODFAT"
						cCdFatAux := FieldGet(nX)
					ElseIf FieldName(nX) == "CSO_CODAGL"
						cCdAglAux := FieldGet(nX)
					ElseIf FieldName(nX) == "CSO_INDFAT"
						cCdIndAux := FieldGet(nX)
					ElseIf FieldName(nX) == "CSO_PERIOD"
						cCdPerAux := FieldGet(nX)		
					EndIf
				Next
				
				lInclDetFt := .T.
				
				If CSO->( dbSeek( xFilial("CSO")+cRevAux+cCdAglAux ) ) //se nao existe pode incluir direto
					//laco para percorrer a conta gerencial
					While CSO->( ! Eof() .And. CSO_FILIAL+CSO_CODREV+CSO_CODAGL == xFilial("CSO")+cRevAux+cCdAglAux )
						//Verifica se ja existe o mesmo fato contabil na conta gerencial - caso exista nao inclui
						If CSO->CSO_CODFAT == cCdFatAux .and. CSO->CSO_INDFAT == cCdIndAux .and. CSO->CSO_PERIOD == cCdPerAux
							lInclDetFt := .F.
							Exit
						EndIf
						CSO->( dbSkip() )
					EndDo
				EndIf
				
				If lInclDetFt
					RecLock("CSO", .T.)
					For nX := 1 TO FCOUNT()
						FieldPut(nX, aCpoGrv[nX])
					Next
					CSO->CSO_CODREV := cRevAux 
					MsUnLock()
				EndIf
				
				dbSelectArea("CSO")
				dbGoto(nRecno)
				dbSkip()
				
			EndDo
	
			CS0->( dbGoto(nRecCS0) )

			dbSelectArea("CSO")
			SET FILTER TO &cFilter
			dbGoTop()   //refresh
			ECdGetDMPL()
			
		   	oBrw:Refresh(.T.)	
			dbGoTop()   //refresh

		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ECDL3_SCPtºAutor  ³Microsiga           º Data ³  02/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se Cadastro de auditores não preenchido para      º±±
±±º          ³ empresa sujeita a auditoria.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ECDL3_SCP()
Local lRet := .T.

If lLeiaute3

	//validacao antes de prosseguir
	If aRespSped1[8] == 2

		dbSelectArea("CVR")
		dbSetOrder	(1)
	
		lRet := dbSeek( xFilial() )
	
		If !lRet
			Alert( STR0175 )//"Cadastro de auditores não preenchido para empresa sujeita a auditoria. Verifique!"
		EndIf

	EndIf
	
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ECDL3_SCPtºAutor  ³Microsiga           º Data ³  02/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pre-validacao quando ecd da SCP                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PreVldSCP(aEmp,cMatriz)
Local lRet 			:= .T.
Local cCGCSel		:= ""
Local cEmprFilial 	:= ""
Local cRazaoSoc 	:= ""
Local cCNPJSocio 	:= ""
Local cCodSocOst 	:= ""
Local nX			:= 0 

If lLeiaute3

	//PRE validacao SCP (nao permite digitar codigo da scp se resposta for 1 ou 2)
	If aRespSped1[9] == 1 .OR. aRespSped1[9] == 2
		lRet := .T.
	Else
		If lRet .And. aRespSped1[9] == 3
			//Valida se codigo da SCP (CGC) eh  diferente da filial/matriz selecionada
			If aRespSped1[1] == 2 // Com Centralização  	
				
				For nX := 1 to Len(aEmp)
					If aEmp[nX][1] .And. Alltrim(aEmp[nX][3]) == Alltrim(cMatriz)
						cCGCSel := Alltrim(aEmp[nX][5])
						cEmprFilial := Alltrim(aEmp[nX][3])
						cRazaoSoc := Alltrim(aEmp[nX][4])
					EndIf
				Next nX
				 
			ElseIf aRespSped1[1] == 1  //sem centralizacao
			
				For nX := 1 to Len(aEmp)
					If aEmp[nX][1]
						cCGCSel := Alltrim(aEmp[nX][5])
						cEmprFilial := Alltrim(aEmp[nX][3])
						cRazaoSoc := Alltrim(aEmp[nX][4])
						Exit
					EndIf 
				Next nX
			
			EndIf
		EndIf
			
		nSCPSel := Aviso("S C P ", 	STR0179+cCgcSel+CRLF+;  //"CNPJ: "
										STR0180+cEmprFilial+CRLF+;  //"Empresa/Filial: "
										"[ "+cRazaoSoc+" ]"+CRLF+;
										STR0181,;  //"O CNPJ acima descrito é da SCP ou Socio Ostensivo ?"
										{"[     S C P     ]", STR0182})  //"Socio Ostensivo"

		If nSCPSel == 1  //se pressionar SCP - PRECISA INFORMAR A FILIAL DO SOCIO OSTENSIVO PARA PEGAR DADOS PARA REGISTRO 0000

			lCodSCP := .F.  //nao precisa digitar codigo da SCP
			aRespSped2[4] := cCGCSel //atribuir CNPJ selecionado no campo CODIGO DA SCP
			
			//SOLICITA O CODIGO DA FILIAL PARA O SOCIO OSTENSIVO UTILIZA PARAMBOX
			SelSocio(@cCodSocOst) 

			For nX := 1 to Len(aEmp)

				If Alltrim(aEmp[nX][3]) == Alltrim(cCodSocOst) 

					cCNPJSocio := AllTrim( aEmp[nX][5] )
					
					//valida se cnpj do socio ostensivo é igual ao cnpj selecionado
					lRet := ( cCGCSel != cCNPJSocio )
				
					If !lRet
						
						Alert( STR0178 ) //"CGC da filial/Matriz selecionada deve ser diferente do codigo da SCP"
						Exit
												
					EndIf

					//inserir no array _aSocOsteno cnpj do socio ostensivo pois ele eh quem vai gerar os registros 0000 / I030
					_aSocOsten[1] := aClone( aEmp[nX] )
					Exit
				
				EndIf
				 
			Next nX
			
		ElseIf nSCPSel == 0 .Or.  nSCPSel == 2
			
			//se presssionar ESC ou Socio Ostensivo
			lCodSCP := .T.  //precisa digitar codigo da SCP

		EndIf
						
	EndIf
	
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ECDL3_SCPtºAutor  ³Microsiga           º Data ³  02/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ validacao da SCP QUANDO ECD DA SCP                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PosVldSCP(cModEsc,aEmp,cMatriz)
Local lRet := .T.
Local nX
Local cCGCSel := ""

If cModEsc=="ECD" .And. lLeiaute3

	If aRespSped1[9] == 3 .And. Empty(aRespSped2[4])
		Alert( STR0176 ) //"Codigo da SCP obrigatorio!"
		lRet := .F.
	EndIf
	
	If lRet .And. aRespSped1[9] == 3
		lRet := ECDVldSCP( Alltrim( aRespSped2[4] ) )
		If !lRet
			Alert( STR0185 ) //STR0185 //"Codigo da SCP  invalido. Verifique!"
		EndIf
	EndIf
	
	If lRet .And. lCodSCP .And. aRespSped1[9] == 3  //valida se eh diferente somente se for digitada 
		//Valida se codigo da SCP (CGC) eh  diferente da filial/matriz selecionada
		If aRespSped1[1] == 2 // Com Centralização  	
			For nX := 1 to Len(aEmp)
				If aEmp[nX][1] .And. Alltrim(aEmp[nX][3]) == Alltrim(cMatriz)
					cCGCSel := Alltrim(aEmp[nX][5])
				EndIf
			Next nX
			 
		ElseIf aRespSped1[1] == 1  //sem centralizacao
		
			For nX := 1 to Len(aEmp)
				If aEmp[nX][1]
					cCGCSel := Alltrim(aEmp[nX][5])
				EndIf 
			Next nX
		
		EndIf
		
		lRet := ( cCGCSel != Alltrim(aRespSped2[4]) )
	
		If !lRet
			Alert( STR0178 ) //"CGC da filial/Matriz selecionada deve ser diferente do codigo da SCP"
		EndIf
		
	EndIf
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}CTBS010
ECD Leiaute 3.0 - LIVRO S - SCP - UTILIZADO NO XML
@author Paulo Carnelossi - Totvs
@since  15/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Static Function SelSocio(cCodSocio) 

Local lRet := .F.
Local aParametro := {}
Local aResposta := {Space(CtbTamFil("033",2))}

aAdd(aParametro,{1,STR0182,aResposta[1],"","","SM0_01","",060,.T.})  //"Socio Ostensivo "  	

If ParamBox( aParametro,STR0183, @aResposta)  //"SCP-SOCIO OSTENSIVO"
	cCodSocio := aResposta[1]
	lRet := .T.
EndIf

Return(lRet)	 

//-------------------------------------------------------------------
/*{Protheus.doc}CTBS010
ECD Leiaute 3.0 - LIVRO S - SCP - RETORNA ARRAY COM SOCIO OSTENSIVO
@author Paulo Carnelossi - Totvs
@since  15/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function ECDSocOst()
//variavel static que tem os dados do socio ostensivo
Return _aSocOsten

//-------------------------------------------------------------------
/*{Protheus.doc}CTBS010
ECD Leiaute 3.0 - LIVRO S - SCP 
@author Paulo Carnelossi - Totvs
@since  15/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function ECDlCodSCP(cModEsc)
Local lRet := .F.

Default cModEsc := "ECD"
Default lAutomato := .F.

If (cModEsc == "ECD") .AND. (CS0->CS0_TIPLIV != 'Z') .AND. (CS0->CS0_LEIAUT >= "3.00")
	If aRespSped1[9] == 3 .And. (_aSocOsten[1] != NIL .Or. (IsBlind() .And. lAutomato .And. Type("aSocOstenAut") == "A" .And. aSocOstenAut[1] != NIL ) ) 
		lRet := .T.
	EndIf
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*{Protheus.doc}CTBS010
ECD Leiaute 3.0 - LIVRO S - SCP - validacao quando ecd da SCP
@author Paulo Carnelossi - Totvs
@since  15/05/2014
@version 11.8
*/
//-------------------------------------------------------------------

Function ECDPosSCP()
Local cCodRev := CS0->CS0_CODREV //CSO ja esta posicionado
Local nCountCS2 := 0

If CS0->CS0_TIPECD == '2'
	//PRIMEIRO SALVA REGISTRO PARA POSICIONAR DEPOIS DE EXPORTADO REGISTRO 0000
	If _nRecCS2 == NIL
		_nRecCS2 := CS2->( Recno() )
	EndIf
	//JA ESTA POSICIONADO NO INDICE 1
	CS2->( dbSeek(xFilial("CS2")+cCodRev) )
	//PRIMEIRO VERIFICAR QUANTOS CS2 EXISTEM
	While CS2->( !Eof() .And. CS2->CS2_FILIAL+CS2_CODREV == xFilial("CS2")+cCodRev )
		nCountCS2++
		CS2->( dbSkip() )
	EndDo
	
	//se for 1 reposicion no registro salvo
	If nCountCS2 == 1
		ECDPosCS2()
		
	ElseIf nCountCS2 == 2
		CS2->( dbSeek(xFilial("CS2")+cCodRev) )
		
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*{Protheus.doc}CTBS010
ECD Leiaute 3.0 - LIVRO S - SCP - UTILIZADO NO XML
@author Paulo Carnelossi - Totvs
@since  15/05/2014
@version 11.8
*/
//-------------------------------------------------------------------
Function ECDPosCS2()

If CS0->CS0_TIPECD == '2'
	If _nRecCS2 != NIL .And. _nRecCS2 > 0	
		//POSICIONAR DEPOIS DE EXPORTADO REGISTRO 0000/I030
		CS2->( dbGoto(_nRecCS2) )
	EndIf
	_nRecCS2 := Nil
EndIf
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} CtbEcdMFTaxas
Tela para digitacao da moeda nacional, leiaute e taxas de jan a dez 

@author Paulo Carnelossi
   
@version P12
@since   25/02/2015
@return  Nil	 
/*/
//-------------------------------------------------------------------
Function CtbEcdMFTaxas( cAnoCal,;
							cMoedNac,;
							cCodLay,;
							cMoedFun,;
							nTaxJan,;
							nTaxFev,;
							nTaxMar,;
							nTaxAbr,;
							nTaxMai,;
							nTaxJun,;
							nTaxJul,;
							nTaxAgo,;
							nTaxSet,;
							nTaxOut,;
							nTaxNov,;
							nTaxDez,;
							nTaxFch,;
							nTaxMed	)

Local oDlg

Local  cLbMoedFun := /*/STR0189/*/"Moeda Funcional"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
Local  cLbCodLay  := /*/STR0190/*/"Codigo Leiaute"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
Local  cLbMoedNac := /*/STR0191/*/"Moeda Nacional"
Local  cLbTaxJan := /*/STR0192/*/"Taxa Janeiro"
Local  cLbTaxFev := /*/STR0193/*/"Taxa Fevereiro"
Local  cLbTaxMar := /*/STR0194/*/"Taxa Marco"
Local  cLbTaxAbr := /*/STR0195/*/"Taxa Abril"
Local  cLbTaxMai := /*/str0196/*/"Taxa Maio"
Local  cLbTaxJun := /*/str0197/*/"Taxa Junho"
Local  cLbTaxJul := /*/str0198/*/"Taxa Julho"
Local  cLbTaxAgo := /*/str0199/*/"Taxa Agosto"
Local  cLbTaxSet := /*/str0200/*/"Taxa Setembro"
Local  cLbTaxOut := /*/str0201/*/"Taxa Outrubro"
Local  cLbTaxNov := /*/str0202/*/"Taxa Novembro"
Local  cLbTaxDez := /*/str0203/*/"Taxa Dezembro"
Local  cLbTaxFch := /*/str0204/*/"Taxa Fechamento"
Local  cLbTaxMed := /*/str0205/*/"Taxa Media"

Local nLinha 		:= 045
Local nIncrLin 		:= 000
Local nEntreLinhas 	:= 15
Local nColunm1 		:= 010
Local nColunm2 		:= 180
Local nSizeSay  	:= 080
Local nSizeGet 		:= 045
Local aButtons
Local aFuncional  	:= {}
Local nOpcA         := 0
Local bCambio
Local bMediaFec
Local bValid 

DEFAULT cAnoCal := "    "
DEFAULT cMoedFun := "  "
DEFAULT cCodLay  := "   "
DEFAULT cMoedNac := ""
DEFAULT nTaxJan := 0.0000
DEFAULT nTaxFev := 0.0000
DEFAULT nTaxMar := 0.0000
DEFAULT nTaxAbr := 0.0000
DEFAULT nTaxMai := 0.0000
DEFAULT nTaxJun := 0.0000
DEFAULT nTaxJul := 0.0000
DEFAULT nTaxAgo := 0.0000
DEFAULT nTaxSet := 0.0000
DEFAULT nTaxOut := 0.0000
DEFAULT nTaxNov := 0.0000
DEFAULT nTaxDez := 0.0000
DEFAULT nTaxFch := 0.0000
DEFAULT nTaxMed := 0.0000	

Private aSize		:= MsAdvSize(.T./*lEnchBar*/,.T./*lPadrao*/, 360/*nMinY*/)
Private aInfo	  	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Private aObjects   	:= {}
Private aPosObj	   	:= {}
Private cCadastro 	:= /*/STR0206/*/"Moeda Funcional - Digitação de Taxas e informações como moeda Nacional/leiaute"

aAdd(aObjects,{80,80,.T.,.F.})// Definicoes para a Enchoice

aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal

aButtons	:= { 	{"UPDWARNING",{|| Eval(bCambio),Eval(bMediaFec) },/*/STR0207/*/"Recuperar Taxa de Cambio" ,/*/STR0208/*/"Resgatar Cambio"} }

bCambio := { || ResgCambio(	@cAnoCal,;
							@cMoedNac,;
							@nTaxJan,;
							@nTaxFev,;
							@nTaxMar,;
							@nTaxAbr,;
							@nTaxMai,;
							@nTaxJun,;
							@nTaxJul,;
							@nTaxAgo,;
							@nTaxSet,;
							@nTaxOut,;
							@nTaxNov,;
							@nTaxDez,;
							@nTaxFch,;
							@nTaxMed) }

bMediaFec := { || MediaFec(	nTaxJan,;
							nTaxFev,;
							nTaxMar,;
							nTaxAbr,;
							nTaxMai,;
							nTaxJun,;
							nTaxJul,;
							nTaxAgo,;
							nTaxSet,;
							nTaxOut,;
							nTaxNov,;
							nTaxDez,;
							@nTaxFch,;
							@nTaxMed) }

							
							
bValid := {||Eval(bMediaFec)}		

					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definiçãod dos Objetos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6]+50,aSize[5]+100,cCadastro,,,,,,,,,.T.)

@ nLinha+nIncrLin,nColunm1 			SAY cLbMoedNac SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET cMoedNac Picture "@!" Valid Eval(bValid) WHEN (.F.)  SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbMoedFun SIZE nSizeSay, 10 OF oDlg PIXEL  //F3 "CTO"
@ nLinha+nIncrLin,nColunm2+nSizeSay GET cMoedFun Picture "@!" F3 "CTO" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10  //OF oDlg PIXEL 
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbCodLay SIZE nSizeSay, 10 OF oDlg PIXEL  //F3 "CSV" 
@ nLinha+nIncrLin,nColunm1+nSizeSay GET cCodLay  Picture "@!" F3 "CSV" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 //OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxJan SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxJan Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxFev SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxFev Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxMar SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxMar Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxAbr SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxAbr Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxMai SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxMai Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxJun SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxJun Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxJul SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxJul Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxAgo SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxAgo Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxSet SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxSet Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxOut SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxOut Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxNov SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxNov Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxDez SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxDez Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.T.) SIZE nSizeGet, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2 			SAY cLbTaxFch SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm2+nSizeSay GET nTaxFch Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.F.) SIZE nSizeGet, 10 OF oDlg PIXEL
nIncrLin += nEntreLinhas
@ nLinha+nIncrLin,nColunm1 			SAY cLbTaxMed SIZE nSizeSay, 10 OF oDlg PIXEL
@ nLinha+nIncrLin,nColunm1+nSizeSay GET nTaxMed Picture "@E 99,999.9999" Valid Eval(bValid) WHEN (.F.) SIZE nSizeGet, 10 OF oDlg PIXEL 

oDlg:bInit 		:= EnchoiceBar(oDlg,{||if(!VldCsvMoe(cCodLay,cMoedNac),nOpcA :=0,(nOpcA :=1,oDlg:End()))},{|| oDlg:End()},,aButtons)
oDlg:lCentered	:= .T.
oDlg:Activate()
 

If nOpca == 1
	aFuncional := {} //1
	aAdd(aFuncional,cMoedNac) //2
	aAdd(aFuncional,cMoedFun) //3
	aAdd(aFuncional,cCodLay) //4
	aAdd(aFuncional,cAnoCal) //5
	aAdd(aFuncional,cValToChar(nTaxJan)) //6
	aAdd(aFuncional,cValToChar(nTaxFev)) //7
	aAdd(aFuncional,cValToChar(nTaxMar)) //8
	aAdd(aFuncional,cValToChar(nTaxAbr)) //9
	aAdd(aFuncional,cValToChar(nTaxMai)) //10
	aAdd(aFuncional,cValToChar(nTaxJun)) //11
	aAdd(aFuncional,cValToChar(nTaxJul)) //12
	aAdd(aFuncional,cValToChar(nTaxAgo)) //13
	aAdd(aFuncional,cValToChar(nTaxSet)) //14
	aAdd(aFuncional,cValToChar(nTaxOut)) //15
	aAdd(aFuncional,cValToChar(nTaxNov)) //16
	aAdd(aFuncional,cValToChar(nTaxDez)) //17
	aAdd(aFuncional,cValToChar(nTaxFch)) //18
	aAdd(aFuncional,cValToChar(nTaxMed)) //19
Else
	MsgAlert( "Parametros não preenchidos o processo sera feito sem o tratamento para moeda funcional!")
	lMoedfun:=.f.	
EndIf

Return(aFuncional)


//-------------------------------------------------------------------
/*/{Protheus.doc} ResgCambio
Le a tabela CTP-Cambio e atribui as variaveis de taxa jan-dez 

@author Paulo Carnelossi
   
@version P12
@since   25/02/2015
@return  Nil	 
/*/
//-------------------------------------------------------------------
Static Function ResgCambio(	cAnoCal,;
							cMoedNac,;
							nTaxJan,;
							nTaxFev,;
							nTaxMar,;
							nTaxAbr,;
							nTaxMai,;
							nTaxJun,;
							nTaxJul,;
							nTaxAgo,;
							nTaxSet,;
							nTaxOut,;
							nTaxNov,;
							nTaxDez,;
							nTaxFch,;
							nTaxMed) 

Local cQuery := ""

cQuery := " SELECT CTP_DATA, 1/CTP_TAXA TAXA "
cQuery += " FROM "+RetSqlName("CTP") + " CTP "
cQuery += " WHERE "
cQuery += "     CTP.CTP_FILIAL = '"+xFilial("CTP")+"' "
cQuery += " AND CTP.CTP_MOEDA = '"+cMoedNac+"' "
cQuery += " AND SUBSTRING(CTP.CTP_DATA,1,4)='"+cAnoCal+"' "
cQuery += " AND CTP.D_E_L_E_T_ = ' ' "	
cQuery += " AND CTP.CTP_DATA IN (   SELECT MAX(CTP_DATA) "
cQuery += "                             FROM "+RetSqlName("CTP") + " CTP1 "
cQuery += "                             WHERE "
cQuery += "                                  CTP1.CTP_FILIAL = '"+xFilial("CTP")+"' " 
cQuery += "                              AND CTP1.CTP_MOEDA = '"+cMoedNac+"' "
cQuery += "                              AND SUBSTRING(CTP1.CTP_DATA,1,4)='"+cAnoCal+"' "
cQuery += "                              AND CTP1.D_E_L_E_T_ = ' ' "
cQuery += "                              GROUP BY SUBSTRING(CTP1.CTP_DATA,1,6)  ) "
cQuery += " ORDER BY CTP_DATA"

cQuery:= ChangeQuery(cQuery)							

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'AUXCTP', .F., .T.)
TCSetField('AUXCTP', "CTP_DATA", "D", 8, 0)
TCSetField('AUXCTP', "TAXA", "N", 10, 4)

AUXCTP->( dbGoTop() )
While AUXCTP->( !Eof() )

	If Month(AUXCTP->CTP_DATA) == 1 //Janeiro
		nTaxJan := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 2 //Fevereiro
		nTaxFev := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 3 //Marco
		nTaxMar := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 4 //Abril
		nTaxAbr := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 5 //Maio
		nTaxMai := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 6 //Junho
		nTaxJun := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 7 //Julho
		nTaxJul := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 8 //Agosto
		nTaxAgo := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 9 //Setembro
		nTaxSet := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 10 //Outubro
		nTaxOut := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 11 //Novembro
		nTaxNov := AUXCTP->TAXA
	ElseIf Month(AUXCTP->CTP_DATA) == 12 //Dezembro
		nTaxDez := AUXCTP->TAXA
	EndIf 	 							

	AUXCTP->( dbSkip() )
	
EndDo

AUXCTP->( dbCloseArea() )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MediaFec
Calcula taxa media e de fechamento a partir das taxas digitadas 

@author Paulo Carnelossi
   
@version P12
@since   25/02/2015
@return  Nil	 
/*/
//-------------------------------------------------------------------

Static Function VldCsvMoe(cCodLay,cMoedNac) 
Local lReturn :=.T.
If EMPTY(cCodLay)
	MsgAlert( "Favor preencher o codigo do leiaute")
	lReturn :=.F.
Endif
IF lReturn .and. EMPTY(cMoedNac)
	MsgAlert( "Favor preencher o codigo da Moeda ")
	lReturn :=.F.
Endif
DbSelectArea( "CSV" )
DbSetOrder(1)

IF lReturn .and. !MsSeek( xFilial("CSV") + cCodLay )
	MsgAlert( "Codigo do Leiaute nao encontrado")
	lReturn :=.F.
Endif 
DbSelectArea( "CTO" )
DbSetOrder(1)
		
IF lReturn .and. !MsSeek( xFilial("CTO") + cMoedNac )
	MsgAlert( "Codigo da moeda nao encontrado")
	lReturn :=.F.
Endif 

Return(lReturn)


//-------------------------------------------------------------------
/*/{Protheus.doc} MediaFec
Calcula taxa media e de fechamento a partir das taxas digitadas 

@author Paulo Carnelossi
   
@version P12
@since   25/02/2015
@return  Nil	 
/*/
//-------------------------------------------------------------------

Static Function MediaFec(	nTaxJan,;
							nTaxFev,;
							nTaxMar,;
							nTaxAbr,;
							nTaxMai,;
							nTaxJun,;
							nTaxJul,;
							nTaxAgo,;
							nTaxSet,;
							nTaxOut,;
							nTaxNov,;
							nTaxDez,;
							nTaxFch,;
							nTaxMed)

Local nValorTx := 0
Local nCount := 0

If nTaxJan <> 0
	nValorTx += nTaxJan
	nTaxFch := nTaxJan  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf
 
If nTaxFev <> 0
	nValorTx += nTaxFev
	nTaxFch := nTaxFev //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxMar <> 0
	nValorTx += nTaxMar
	nTaxFch := nTaxMar //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxAbr <> 0
	nValorTx += nTaxAbr
	nTaxFch := nTaxAbr  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxMai <> 0
	nValorTx += nTaxMai
	nTaxFch := nTaxMai //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxJun <> 0
	nValorTx += nTaxJun
	nTaxFch := nTaxJun  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxJul <> 0
	nValorTx += nTaxJul
	nTaxFch := nTaxJul //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxJul <> 0
	nValorTx += nTaxAgo
	nTaxFch := nTaxAgo  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxSet <> 0
	nValorTx += nTaxSet
	nTaxFch := nTaxSet  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxOut <> 0
	nValorTx += nTaxOut
	nTaxFch := nTaxOut  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxNov <> 0
	nValorTx += nTaxNov
	nTaxFch := nTaxNov  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf

If nTaxDez <> 0
	nValorTx += nTaxDez
	nTaxFch := nTaxDez  //ultimo vai conter a taxa de fechamento
	nCount++
EndIf
	
//taxa Media
nTaxMed := nValorTx / nCount

Return(.T.)
							
//-------------------------------------------------------------------
/*{Protheus.doc}CTBS010
ECD Leiaute 3.0 - LIVRO S - SCP - UTILIZADO NO XML
@author Eduardo Lima - Totvs
@since  02/02/2016
@version 11.8
*/
//-------------------------------------------------------------------
Static Function ECDVldSCP(cSCP)
Local lReturn:=.T.
Local nX:=0
If Len(cSCP) !=14  
	lReturn:=.F.
Else
	For nX := 1 TO Len(cSCP)
		IF !IsDigit( SubStr(cSCP,nX,1))
			lReturn:=.F.
			Exit
		Endif
	Next       
Endif 
	
Return lReturn
//-------------------------------------------------------------------
/*{Protheus.doc}ECDBlocoK
ECD Leiaute 5/6 
@author - Totvs
@since  05/03/2018
@version 12.1.17
*/
//-------------------------------------------------------------------
Function ECDBlocoK()
Local lReturn:=.T.
If ( CS0->( ColumnPos( "CS0_IDBLK" )) > 0 )
	If lLeiaute5
		If aRespSped1[12]==1 .And. Empty(aRespSped1[13])
			//Alert("Informe o Identificador do Bloco K.")
			lReturn := .F.
		ElseIf aRespSped1[12]==1 .And. !Empty(aRespSped1[13])
			lReturn := ExistCpo('CQQ',aRespSped1[13])
			aLoadRes[ECD_IDBLK] := If(lReturn, aRespSped1[13],Space(10) )
		Else
			If aRespSped1[12] == 2
				If !Empty(aRespSped1[13])
					aRespSped1[13] := Space(10)
					aLoadRes[ECD_IDBLK] := Space(10)
					lReturn := .T.
				EndIf
			Else
				lReturn := ExistCpo('CQQ',aRespSped1[13])
				aLoadRes[ECD_IDBLK] := If(lReturn, aRespSped1[13],Space(10) )
			EndIf
		EndIf
	Endif 
EndIf	
Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} BloqField
Bloqueia campos inutilizáveis no layout 5

@author André Brito	
   
@version P11
@since   07/03/2017
@return  lBloq - Lógico 
/*/
//-------------------------------------------------------------------

Function BloqField()

Local lBloq := .T.

If lLeiaute5
	lBloq := .F.
EndIf

Return lBloq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma³CTBSVLARQ ºAutor  ³Totvs               º Data ³  08/05/18     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.³ Verif. se um arquivo existe na validação do wizard do Passo 3/3.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º                                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTBSVLARQ(aRespSped5)

Local lRet           := .T.
Local nCont				
Default aRespSped5 	:= {}

If lLeiaute7
	If EcdVldSubs() .And. Empty(aRespSped5[20])
		Help("ECDArq",1,"HELP",STR0252,STR0253,1,0) //"Arquivo inválido"###"Obrigatório informar o arquivo para a escrituração substituta."
		lRet := .F.
	EndIf

	If lRet .And. !Empty(aRespSped5[20]) .And. aRespSped5[21] == 1
		Help("ECDArq",1,"HELP",STR0254,STR0255,1,0) //"Motivo Inválido"###"Informe um motivo válido para a substituição."
		lRet := .F.
	EndIf
EndIf

If lRet 
	// A variável nCont inicializa desde 13 porque o array de respostas aRespSped5 
	// tem os conteúdos das perguntas a partir da posição 13
	For nCont := 13 to Len(aRespSped5)

		cRespSped5 := aRespSped5[nCont]
		
		// A validação Alltrim(cRespSped5) <> "" é para permitir 
		// o funcionamento padrão do processamento sem necessidade de preencher nenhum arquivo
			
		If !Empty(AllTrim(cRespSped5)) .And. !File(cRespSped5) 
			lRet := .F.
			Help("ECDArq",1,"HELP",STR0226,STR0227 + cRespSped5 ,1,0)   //"Arquivo inválido"##"Verificar caminho ou nome do Arquivo: "
			Exit
		EndIf

	Next
EndIf

Return lRet 
//-------------------------------------------------------------------
/*/{Protheus.doc} VldCalTri

Valida o calendário trimestral

@author TOTVS
@since 04/02/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static Function VldCalTri(cMsgAlert)
Local aArea     :=  GetArea()
Local cSQL 		:= ""
Local cQueryCSE := ""
Local cQuery    := ""
Local lTemTrim  := .F.
Local lTemAnual	:= .F.
Local lRet 		:= .T.

aPerCalTri := {}

If lLeiaute7 .And. Len(aRespSped4)>10
	If aRespSped4[11]==1

		cSQL := " SELECT "
		cSQL += "	CTG_DTINI, CTG_DTFIM "
		cSQL += "	FROM "
		cSQL += 		RetSQLName("CTG")
		cSQL += "		WHERE "
		cSQL += "			CTG_FILIAL = '"+xFilial("CTG")+"' AND "
		cSQL += "			CTG_CALEND = '"+aRespSped4[4]+"' AND "
		cSQL += "			D_E_L_E_T_ = ' ' "
			
		cSQL := ChangeQuery(cSQL) 
	
		cAliasCTG := GetNextAlias()
		dbUseArea(.T. ,"TOPCONN",TcGenQry(,,cSQL),cAliasCTG,.T.,.T.)
		
		TcSetField(cAliasCTG,'CTG_DTINI','D')
		TcSetField(cAliasCTG,'CTG_DTFIM','D')		

		Count to nTotRegs

		If nTotRegs > 4
			cMsgAlert := STR0230+CRLF+STR0231 //"Você escolheu a opção de arquivo trimestral."###"O calendário deve conter no máximo quatro períodos."
			lRet := .F.
		EndIf

		If lRet
			(cAliasCTG)->(dbGoTop())
			While !(cAliasCTG)->(Eof())
				aAdd(aPerCalTri,{(cAliasCTG)->CTG_DTINI,(cAliasCTG)->CTG_DTFIM})
				(cAliasCTG)->(dbSkip())
			EndDo
		EndIf
		(cAliasCTG)->(dbCloseArea())
	
		If lRet .And. Len(aRespSped4) > 11 .And. GetNewPar("MV_ECDTRIA",.F.)
			If Empty(aRespSped4[12])						
				lRet := MsgYesNo(STR0281 +CRLF+ STR0282 +CRLF+ STR0283)
				cMsgAlert :=  STR0287 //"Informe o código da revisão anterior."
			Else
				CSE->(dbSetOrder(1))
				If CSE->(dbSeek(xFilial("CSE")+aRespSped4[12]))
					cQuery := " SELECT CSE_PERIOD FROM "+RetSQLName("CSE")+;
							  " WHERE CSE_FILIAL = '"+xFilial("CSE")+"' AND "+;
							  " CSE_CODREV = '"+aRespSped4[12]+"' AND "+;
							  " CSE_TPDEM = '2' AND "+;							  
							  " D_E_L_E_T_ = ' ' "+;
							  " GROUP BY CSE_PERIOD "
					cQuery := ChangeQuery(cQuery)

					cQueryCSE := GetNextAlias()
					dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cQueryCSE)

					While !(cQueryCSE)->(Eof())
						If "T0"$(cQueryCSE)->CSE_PERIOD 
							lTemTrim := .T.
						EndIf
						If AllTrim((cQueryCSE)->CSE_PERIOD) == "12"
							lTemAnual := .T.
						EndIf
					
						If lTemTrim .And. lTemAnual							
							Exit
						EndIf

						(cQueryCSE)->(dbSkip())						
					EndDo
					(cQueryCSE)->(dbCloseArea())

					If !lTemTrim 
						cMsgAlert := STR0284 //"Não foram encontrados períodos trimestrais na revisão anterior informada."
						lRet := .F.
					ElseIf !lTemAnual
						cMsgAlert := STR0285 //"Não foi encontrado o período anual (acumulado) na revisão anterior informada."
						lRet := .F.
					EndIf
				Else
					cMsgAlert := STR0286 //"Não foi encontrada a demonstração DRE na revisão informada."      
					lRet := .F.
				EndIf
			EndIf	
		EndIf

	EndIf
EndIf

RestArea(aArea)

Return lRet
/*/{Protheus.doc} VldCalTri

Valida o calendário trimestral

@author TOTVS
@since 04/02/2019
@version P12.1.25
/*/
Function VldCSOTOk()
Local lRet := .T.
	
If lLeiaute7 
	If aRespSped4[11]==1 .And. Empty(M->CSO_PERIOD)
		MsgAlert(STR0230+CRLF+STR0232)//"Você escolheu a opção de arquivo trimestral."###"O campo Período (CSO_PERIOD) deve ser preenchido."
		lRet := .F.	
	EndIf

	If lRet .and. !__ecdTria
		lRet := CTBSVldCal(aParamEcd[ECD_CALENDARIO],M->CSO_PERIOD,nil,nil,aParamEcd[ECD_SIT_ESP]<>1)
	EndIf

	If lRet .And. !VldUnqCSO()
		MsgAlert(STR0256+CRLF+STR0257)//"Registro já cadastrado para esta escrituração."####"Confira os dados digitados."
		lRet := .F.
	EndIf
EndIf

Return lRet
/*/{Protheus.doc} CTBSVldCal

Valida se o período informado existe no calendário contábil

@author TOTVS
@since 04/02/2019
@version P12.1.25
/*/
Function CTBSVldCal(cCalend,cPeriod,dDatIni,dDatFim,lSitEsp)
Local aArea 	:= GetArea()
Local lRet  	:= .T.
Local lPeriodOk := .F.
Local cSQL  	:= ""
Local cAliasAux := ""
Local nCount    := 0

DEFAULT cCalend := ""
DEFAULT cPeriod := ""
DEFAULT dDatIni := StoD("")
DEFAULT dDatFim := StoD("")
DEFAULT lSitEsp := .F.

cAliasAux :=  GetNextAlias()

cSQL := " SELECT "
cSQL += " 	CTG_PERIOD, CTG_DTINI, CTG_DTFIM "
cSQL += " 	FROM "
cSQL += 		RetSQLName("CTG")
cSQL += " 		WHERE "
cSQL += " 			CTG_FILIAL = '"+xFilial("CTG")+"' AND "
cSQL += " 			CTG_CALEND = '"+cCalend+"' AND "
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL:= ChangeQuery(cSQL)							
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), cAliasAux, .T., .T.)

TCSetField(cAliasAux,"CTG_DTINI","D",8,0)
TCSetField(cAliasAux,"CTG_DTFIM","D",8,0)

While !(cAliasAux)->(Eof())
	If Empty(cPeriod) 		
		If ( (cAliasAux)->CTG_DTFIM <> LastDay((cAliasAux)->CTG_DTINI) .Or.;
			(cAliasAux)->CTG_DTINI <> FirstDay((cAliasAux)->CTG_DTFIM) ) .And. !lSitEsp			
			Help("",1,"CTBSVldCal", STR0238,STR0236,1,0,,,,,,{STR0237})			 //"Quando não for informado o período, o calendário utilizado deve ser mensal." //"Informe o período ou verifique o calendário contábil." //"O calendário contábil não é mensal."
			lRet := .F.
			Exit		
		EndIf
	Else
		If nCount > 4		 	
			Help("",1,"CTBSVldCal", STR0241,STR0239,1,0,,,,,,{STR0240})			 //"Foi informado o período, porém o calendário utilizado possui mais de quatro períodos cadastrados." //"Verifique o calendário contábil." //"O calendário contábil não é trimestral."
			lRet := .F.
			Exit
		EndIf
		If (cAliasAux)->CTG_PERIOD$cPeriod
			dDatIni := (cAliasAux)->CTG_DTINI
			dDatFim := (cAliasAux)->CTG_DTFIM
			lPeriodOk := .T.			
		EndIf
	EndIf
	nCount++	
	(cAliasAux)->(dbSkip())
EndDo
(cAliasAux)->(dbCloseArea())

If !Empty(cPeriod) .And. !lPeriodOk
	//MsgAlert(STR0233)//"O período escolhido não existe no calendário contábil informado."
	Help("",1,"CTBSVldCal",,STR0233,1,0,,,,,,{STR0240})	
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet
/*/{Protheus.doc} EcdVldSubs
Validação do Motivo de Substituição

@author TOTVS
@since 22/02/2019
@version P12.1.25
/*/
Function EcdVldSubs()
Return (Len(aRespSped1)>4 .And. aRespSped1[5]==2) // Verifico se é substituta

/*/{Protheus.doc} VldCSQL7
Validação do dicionário de dados

@author TOTVS
@since 25/02/2019
@version P12.1.25
/*/
Function VldCSQL7(aRespLeiaute)
Local lRet := .T.
DEFAULT aRespLeiaute := {}

If Len(aRespLeiaute)>0 .And. aRespLeiaute[1] >= 7 .And. !TableInDic("CSQ")
	lRet := .F.
ElseIf lLeiaute8 .And. CS0->(FieldPos("CS0_MUDPC")) == 0 .And. CSE->(FieldPos("CSE_ORDEM")) == 0 .And. CS0->(FieldPos("CS0_AMRPC") == 0)
	lRet := .F.
ElseIf lLeiaute9 .And. !TableInDic("CQW") .And. CSB->(FieldPos("CSB_INDSLD")) == 0 // Leiaute 9 - Caso não exista CQW OU cambo na CSB solicitar atualização
	lRet := .F.	
ElseIf lLeiaute9 .And. (!TableInDic("CQW") .Or. CQW->(FieldPos("CQW_SEQ")) == 0)// Leiaute 9 - Caso não exista o campo na CQW solicitar atualização
	lRet := .F.
ElseIf lLeiaute9 .and. CSB->(FIELDPOS( "CSB_DATAAL" )) == 0  .and. CSB->(FIELDPOS( "CSB_LOTE" )) == 0 .and. CSB->(FIELDPOS( "CSB_SUBLOT" )) == 0 // Leiaute 9 - Campos para geração do i157 (2024)
	lRet := .F.
EndIf

If !lRet
	MsgAlert(STR0250+cValToChar(aRespLeiaute[1])+".00."+CRLF+STR0251) //"Dicionário de dados desatualizado para o leiaute escolhido: "###"Atualize o sistema executando o UPDDISTR do ECD."
EndIf

Return lRet

/*/{Protheus.doc} ECDClrRTF
Limpa arquivos RTF de acordo com o indicador de escrituração.

@author TOTVS
@since 20/03/2019
@version P12.1.25
/*/
Function ECDClrRTF()

If lLeiaute2 .And. aRespSped1[5] == 1 .And. Len(aRespSped5)>19
	aRespSped5[20] := Space(500)	
	aRespSped5[21] := 1
EndIf

Return .T.
/*/{Protheus.doc} VldUnqCSO
Verifica se já existe fato contábil cadastrado.

@author TOTVS
@since 17/04/2019
@version P12.1.25
/*/
Static Function VldUnqCSO()
Local aArea     := getArea()
Local lRet := .F.
Local cSQL := ""
Local nRecno    := CSO->(Recno())
Local cAliasAux := GetNextAlias()

cSQL := " SELECT "
cSQL += " 	CSO_CODREV "
cSQL += " 	FROM "
cSQL +=  			RetSQLName("CSO")
cSQL += " 		WHERE "
cSQL += " 			CSO_FILIAL = '"+xFilial("CSO")+"' AND "
cSQL += " 			CSO_CODREV = '"+M->CSO_CODREV +"' AND "
cSQL += " 			CSO_REG    = '"+M->CSO_REG    +"' AND "
cSQL += " 			CSO_CODVIS = '"+M->CSO_CODVIS +"' AND "
cSQL += " 			CSO_CODAGL = '"+M->CSO_CODAGL +"' AND "
cSQL += " 			CSO_CODFAT = '"+M->CSO_CODFAT +"' AND "
cSQL += " 			CSO_INDFAT = '"+M->CSO_INDFAT +"' AND "
cSQL += " 			CSO_PERIOD = '"+M->CSO_PERIOD +"' AND "
if ALTERA
	cSQL += " 		R_E_C_N_O_ <> "+alltrim(str(nRecno))+" AND "
EndIf
cSQL += " 			D_E_L_E_T_ = ' ' "

cSQL:= ChangeQuery(cSQL)							
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), cAliasAux, .F., .T.)

lRet := (cAliasAux)->(Eof())
(cAliasAux)->(dbCloseArea())

restArea(aArea)
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ EcMultInscr   ³ Autor TOTVS	            ³ Data ³03/06/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Validações para manipulação de Múltiplas inscrições         ³±±
±±³  ³1 Verifica atualização de dicionário para o alias CSS               ³±±
±±³  ³2 se já foram incluídas inscrições e deseja dar manutenção          ³±±
±±³  ³3 se selecionou inscrições mas não cadastrou inscrições             ³±±
±±³  ³4 Recupera código da seguinte revisão para poder gravar na  CSS     ³±±
±±³  ³5 Limpa os arrays de resposta se estiverem preenchido               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³lRet                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	Código Empresa, Modo Escrituração, array respostas sped 2 ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function EcMultInsc(cEmp,cModEsc,aRespSped2)
Local cFilter  := ""
Local lAbreCSS := .T.
Local lRet     := .T.
Local lMultiplas := (Len(aRespSped2)>0 .And. Type("aRespSped2[1]") == "N" .And. aRespSped2[1]==7)

//Verifica se existe a tabela CSS, caso selecione múltiplas inscrições
If !AliasInDic("CSS")
    Help(Nil,Nil,STR0264,,STR0251,1,0)  
    Return
EndIf

If cModEsc <> "ECD" .Or. !lMultiplas
    If !lMultiplas
        DelAbortCss(__cCodRev) 
    EndIf       
    Return lRet
EndIf

If __cCodRev == nil		
	__cCodRev :=  GerNextRev(cEmp)	
EndIf

CSS->(dbSetOrder(1))
If CSS->(dbSeek(xFilial("CSS")+__cCodRev))
	lAbreCSS := (Aviso("Atenção","Já existem outras inscrições cadastradas, deseja abrir a tela para manutenção?",{"Sim","Não"})==1)
EndIf

If lAbreCSS
	cFilter := "CSS_FILIAL+CSS_CODREV = xFilial('CSS')+'"+__cCodRev+"'"
	dbSelectArea("CSS")
	SET FILTER TO &cFilter
	AxCadastro("CSS",STR0270)
EndIf

CSS->(dbSetOrder(1))
If !CSS->(dbSeek(xFilial("CSS")+__cCodRev))
	Aviso("Atenção","Foi informada a opção de Múltiplas Inscrições, porém não foi preenchido o cadastro",{"Ok"})
	lRet := .F.
EndIf

If(aRespSped2[1] == 7)
	aRespSped2[2]:=Space(02)
	aRespSped2[3]:=Space(60)
EndIf



Return lRet


/*/{Protheus.doc} CtbRelRev
X3_RELACAO do campo CSS_CODREV
@author TOTVS
@since 03/06/20
@version P12.1.27
/*/

Function CtbRelRev()
Return IIf(__cCodRev == Nil,"",__cCodRev)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ DelAbortCss   ³ Autor TOTVS	            ³ Data ³03/06/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³Exclui registros da tabela CSS caso o Usuário cancele a     ³±±
±±³          ³operação do wizard se antes inseriu dados pela opção        ³±±
±±³          ³Múltiplas inscrições                                        ´±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 	Código da Revisão                                         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function DelAbortCss(cCodRev)
Local aArea:= GetArea()
Local aAreaCss:= CSS->(GetArea())

DEFAULT cCodRev := ""

CSS->(dbSetOrder(1)) //CSS_FILIAL + CSS_CODREV + CSS_INSTIT 	

If !Empty(cCodRev) .And. CSS->(MsSeek(xFilial("CSS") + cCodRev))
	While CSS->(!EOF()) .And. CSS->(CSS_FILIAL+CSS_CODREV) == xFilial("CSS") + cCodRev
		RecLock("CSS",.F.)
		dbDelete()
		FkCommit()
		msUnlock()
		CSS->(dbSkip())
	EndDo
Endif

RestArea(aAreaCss)
RestArea(aArea)

Return

/*/{Protheus.doc} ChkI051
Verifica se já existe fato contábil cadastrado.

@author TOTVS
@since 17/04/2019
@version P12.1.25
/*/
Static Function ChkI051(cCodPla, cCodVer, cBalanco, cDRE, lProcCusto)
Local lRet := .T.
Local lRetPL := .T.
Local lRetVs := .T. 
Local lRetVDRE := .T.
Local cSQL := ""
Local cAliasAux := GetNextAlias()
Local aVldCC := {}
Local aVldConta := {}
Local aConta := {}
Local cBalCTS := ""
Local cDRECTS := ""
Local cCusto := ""
Local nI,nK,nL,nCount := 0
Local lErroAmarr := .F.
Local nSemCusto := 0
Local nComCusto := 0
Local oHashCC := tHashMap():New()//Cria o Objeto do Hash Map
Local aRet := {}
Local oHashCta := tHashMap():New()//Cria o Objeto do Hash Map
Local lAutomacao := FwIsInCallStack("AUTJOBRUNCT")
Local lValida := .F.

Default cCodPla 	:= ""
Default cCodVer		:= ""
Default cBalanco	:= ""
Default cDRE		:= ""
Default lProcCusto  := .F.

If !lAutomacao
	If MsgNoYes(STR0279 + Chr(13) + Chr(10) + STR0280, STR0278)
		lValida := .T.
	EndIf	
EndIf	

If lAutomacao .or. lValida
		If !Empty(cCodPla) .And. !Empty(cCodVer)
			cSQL := " SELECT DISTINCT "
			cSQL += " 	CVD_CUSTO, CVD_CTAREF "
			cSQL += " 	FROM "
			cSQL +=  			RetSQLName("CVD")
			cSQL += " 		WHERE "
			cSQL += " 			CVD_FILIAL = '"+xFilial("CVD")+"' AND "
			cSQL += " 			CVD_CODPLA = '"+ cCodPla +"' AND "
			cSQL += " 			CVD_VERSAO = '"+ cCodVer    +"' AND "
			//cSQL += " 			CVD_CUSTO != ' ' AND "
			cSQL += " 			D_E_L_E_T_ = ' ' "

			cSQL:= ChangeQuery(cSQL)							
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), cAliasAux, .F., .T.)

			aConta := {}
			While !(cAliasAux)->(Eof())
				
				If !Empty((cAliasAux)->CVD_CUSTO)
					AAdd(aVldCC, { (cAliasAux)->CVD_CUSTO }) 
				Endif
				
				If lProcCusto
				
					If !HMGet(oHashCta,(cAliasAux)->CVD_CTAREF,@aRet)
						HMSet(oHashCta,(cAliasAux)->CVD_CTAREF,1)
					EndIf
						aAdd(aVldConta, {(cAliasAux)->CVD_CTAREF, (cAliasAux)->CVD_CUSTO})

				EndIf	
				
				(cAliasAux)->(DbSkip())

			EndDo
			(cAliasAux)->(DBCLOSEAREA())	

			//Usando HashMap
			oHashCC := AToHM(aVldCC,1)

			For nI := 1 to Len(aVldCC)
				
				cCusto := aVldCC[nI][1]
				
				lFound := HMGet(oHashCC,cCusto,@aRet)

				If lFound 
					If Len(aRet) >= 2
						lRetPL := .F.
						Exit
					EndIf	
				EndIF	
			Next nI
			nCount := 0
			oHashCC:Clean()

			If lProcCusto
				For nK := 1 to Len(aConta)
					For nL:= 1 to Len(aVldConta)
						If aConta[nK][1] == aVldConta[nL][1]
							If Empty(aVldConta[nL][2])
								nSemCusto := nSemCusto + 1
							Else
								nComCusto := nComCusto + 1	
							EndIf	
						EndIf
					Next nL
					If nSemCusto > 0 .and. nComCusto > 0
						lErroAmarr := .T.
						nSemCusto := 0
						nComCusto := 0
					Else
						nSemCusto := 0
						nComCusto := 0 
					EndIf	
				Next nK	
			EndIf	

		oHashCta:Clean()
		EndIf

		If !Empty(cBalanco) .And. !Empty(cDRE)

			cBalCTS := POSICIONE("CTN", 1, xFilial("CTN")+cBalanco, "CTN_PLAGER")
			cDRECTS	:= POSICIONE("CTN", 1, XFilial("CTN")+cDRE,	"CTN_PLAGER")

			lRetVs := VldCts(cBalCTS,lProcCusto)
			lRetVDRE :=  VldCts(cDRECTS,lProcCusto)

		EndIf	

		If lRetPL .and. lRetVs .and. lRetVDRE
			lRet := .T.
		Else
			lRet := .F.
		EndIf		

		If lErroAmarr
			ApMsgInfo(STR0276, STR0277, )
		EndIf
EndIf	

Return lRet

Static Function VldCts(cVisao,lProcCusto)
Local lRet := .T.
Local cSQLVis := ""
Local cAliasVis := GetNextAlias()
Local aVldCC := {}
Local oHashCts := HMNew()
Local aVldConta := {}
Local nI, nY := 0
Local cCCIni := ""
Local cCCFim := ""
Local nCount := 0
Local aRet  := {}

cSQLVis := " SELECT "
	cSQLVis += " 	CTS_CONTAG, CTS_CTTINI, CTS_CTTFIM "
	cSQLVis += " 	FROM "
	cSQLVis +=  			RetSQLName("CTS")
	cSQLVis += " 		WHERE "
	cSQLVis += " 			CTS_FILIAL = '"+xFilial("CTS")+"' AND "
	cSQLVis += " 			CTS_CODPLA = '"+ cVisao +"' AND "
	//cSQLVis += " 			CTS_CTTFIM != ' ' AND "
	cSQLVis += " 			D_E_L_E_T_ = ' ' "

	cSQLVis:= ChangeQuery(cSQLVis)							
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQLVis), cAliasVis, .F., .T.)


	While !(cAliasVis)->(Eof())

		AAdd(aVldCC, { (cAliasVis)->CTS_CTTINI, (cAliasVis)->CTS_CTTFIM }) 

			If lProcCusto
				//Hashmap
				If !HMGet(oHashCts,(cAliasVis)->CTS_CONTAG,@aRet)
					HMSet(oHashCts,(cAliasVis)->CTS_CONTAG,1)
				EndIf
				aAdd(aVldConta, {(cAliasVis)->CTS_CONTAG, (cAliasVis)->CTS_CTTINI, (cAliasVis)->CTS_CTTFIM })

			EndIf

		(cAliasVis)->(DbSkip())

	EndDo
	(cAliasVis)->(dbCloseArea())


	For nI := 1 to Len(aVldCC)
		
		cCCIni := aVldCC[nI][1]
		cCCFim	:= aVldCC[nI][2]
		
		For nY := 1 to Len(aVldCC)
			
			If cCCIni >= aVldCC[nY][1] .And. cCCFim <= aVldCC[nY][2] .And. ;
			!Empty(cCCIni) .and. !Empty(cCCFim)
				nCount ++
			EndIf
			If nCount >= 2
				lRet := .F.
				Exit
			EndIf	

		Next nY
		If !lRet
			Exit
		EndIF	
		nCount := 0
	Next nI	

Asize(aVldCC,0)
Asize(aVldConta,0)
oHashCts:Clean()

Return lRet

/*/{Protheus.doc} CTBS010Msg
Exibe a mensagem do centro de custo com link para documentação no TDN

@author TOTVS
@since 16/03/2021
@version P12.1.27
/*/
Function CTBS010Msg(cTextMsg,cTitMsg,cLinkDoc)
Local oFont1   := TFont():New('Arial',,16)
Local oFont2   := TFont():New('Arial',,16,,,,,,,.T.)
Local oDlg
Local oSayEcd1
Local oSayEcd2 
Local bBlocMsg := {|| ShellExecute( "Open", cLinkDoc, "", "C:\", 1 )}
Local bExecute := {|| oDlg:End()}

Default cTextMsg := ""
Default cTitMsg  := ""
Default cLinkDoc := ""

DEFINE DIALOG oDlg TITLE cTitMsg FROM 040,040 TO 200,460 PIXEL

oSayEcd1 := TSay():New(01,05,{||cTextMsg},oDlg,,oFont1,,,,.T.,,,200,100,,,,,,.F./*lHtml*/)

oSayEcd2 := TSay():New(50,05,{|| STR0275 },oDlg,,oFont2,,,,.T.,CLR_HBLUE,,200,100,,,,,,.F./*lHtml*/) //'Acesso à documentação'
oSayEcd2:bLClicked := bBlocMsg

tButton():New(65,170,STR0269,oDlg,bExecute,35,12,,,,.T.) //Ok

ACTIVATE DIALOG oDlg CENTERED

Return
/*
Usar para debugar a tela de mensagem
User Function CtbCallMsg()
CTBS010Msg(STR0272,STR0274,"https://tdn.totvs.com/x/0h8NJ")
Return 
*/
