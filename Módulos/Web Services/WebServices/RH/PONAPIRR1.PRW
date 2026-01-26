#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PONAPIRR1.CH"

#DEFINE TAB CHR ( 13 ) + CHR ( 10 )

Static __oSt1//fDisp()
Static __oSt2//fValNSR()
Static __oSt3//fValNSR() PW

//---------------------------------------------------------------------
/*/{Protheus.doc} recordClockMarkings
@type			method
@description	Serviço para gravação de marcações originadas do Suricato na tabela RR1
@author			Allyson Mesashi
@since			16/10/2020
/*/
//---------------------------------------------------------------------
WSRESTFUL recordClockMarkings DESCRIPTION STR0001 FORMAT APPLICATION_JSON//"Serviço para gravação de marcações originadas do Suricato na tabela RR1"

WSDATA companyId			AS STRING
WSDATA branchId			    AS STRING
WSDATA items				AS ARRAY

WSMETHOD POST;
	DESCRIPTION STR0002;//"Inclui marcações originadas do Suricato na tabela RR1"
	WSSYNTAX "api/rh/v1/recordClockMarkings";
	PATH "api/rh/v1/recordClockMarkings";
	TTALK "v1";
	PRODUCES APPLICATION_JSON

END WSRESTFUL

/*/{Protheus.doc} POST
@type			method
@description	Método responsável por incluir marcações originadas do Suricato na tabela RR1
@author			Allyson Mesashi
@since			16/10/2020
@version 12.1.27
/*/
WSMETHOD POST WSREST recordClockMarkings 

Local cBody	    	:= self:GetContent()
Local lRet          := .T.
Local oParams   	:= JsonObject():New()
Local oResp     	:= JsonObject():New()

Private bError      := { |e| oError := e, Break(e) }
Private bErrorBlock := ErrorBlock( bError )
Private oError
Private aGrpEmp		:= {}

oParams:FromJSON( cBody )

BEGIN SEQUENCE
	If checkParams(oParams)
        If !AliasInDic("RR1")
            lRet := .F.
            SetRestFault( 400, EncodeUTF8( STR0004 ) )//"A tabela RR1 não existe no dicionário de dados. É necessário a atualização do sistema para utilizar este serviço."
        Else
            If fGrvRR1( oParams, @oResp )
				Self:setHeader("Status", "200")
			Else
				Self:setHeader("Status", "400")
			EndIf
			Self:setResponse( EncodeUTF8(oResp:ToJson()) )
        EndIf
	Else
		lRet := .F.
		SetRestFault( 400, EncodeUTF8( STR0005 ) )//"Parâmetro inválido: verifique se o parâmetro 'items' foi enviado."
	EndIf
RECOVER
	lRet := .F.
	ErrorBlock( bErrorBlock )
	SetRestFault( 500, EncodeUTF8( STR0006 ) + TAB + EncodeUTF8( oError:Description ) ) //"Ocorreu uma falha no retorno da informação: "
END SEQUENCE

Return lRet

/*/{Protheus.doc} checkParams
Validação dos parâmetros recebidos.
@author Allyson Mesashi
@since 16/10/2020
/*/
Static Function checkParams( oParams )

Local lRet	:=	.T.

If Empty( oParams["items"] )
	lRet := .F.
EndIf

Return lRet

/*/{Protheus.doc} function fSetErrorHandler
Função para setar erros tratados
@author  Hugo de Oliveira
@since   07/02/2020
/*/
Static Function fSetErrorHandler( cTitle )

bError  := { |e| oError := e , oError:Description := cTitle + TAB + oError:Description, Break(e) }
bErrorBlock	:= ErrorBlock( bError )

Return .T.

/*/{Protheus.doc} function fResetErrorHandler
Função para limpar o retorno de erros
@author  Hugo de Oliveira
@since   07/02/2020
/*/
Static Function fResetErrorHandler( cTitle )

bError  	:= { |e| oError := e , Break( e ) }
bErrorBlock := ErrorBlock( bError )

Return .T.

/*/{Protheus.doc} checkParams
Validação dos parâmetros recebidos.
@author Allyson Mesashi
@since 16/10/2020
/*/
Static Function fGrvRR1( oParams, oResp )
Local aMarcs		:= oParams["items"]
Local aRet			:= {}
Local lTudoOk		:= .T.
Local lRR1671		:= .F. 
Local lEnv671		:= .F.
Local lPontoWeb		:= .F.
Local oRet     		:= Nil
Local nCodNSR		:= 0
Local nVersLayou	:= 0
Local nNumMarcac	:= 0
Local nCont			:= 0
Local cCodPIS		:= ""
Local cDatMarcac	:= ""
Local cCodRelExt	:= ""
Local cCodFuncM		:= ""
Local aCodFuncM		:= ""
Local cCodREP		:= ""
Local cCodUniExt	:= ""
Local cCodUsrExt	:= ""
Local aCodUsrExt	:= {}
Local cCodCPF		:= ""
Local cInscrEmp		:= ""
Local cCodFuso		:= ""
Local cModo			:= ""
Local cCodCCT		:= ""
Local cEmpAntBck	:= cEmpAnt
Local aEmp			:= {}
Local cTipoREP		:= ""
Local nI			:= 0
Local lGrvUsr		:= .T.

Private	nTamCodRel	:= GetSx3Cache( "RR1_CODREL" , "X3_TAMANHO" )
Private	nTamCodRep	:= GetSx3Cache( "RR1_CODREP" , "X3_TAMANHO" )

dbSelectArea("RR1")

lRR1671 := RR1->(ColumnPos("RR1_CODPIS")) > 0 .And. ;
		   RR1->(ColumnPos("RR1_FUSO"  )) > 0 .And. ;
		   RR1->(ColumnPos("RR1_VRSLAY")) > 0 .And. ;
		   RR1->(ColumnPos("RR1_INSCR" )) > 0 .ANd. ;
		   RR1->(ColumnPos("RR1_CCTREP")) > 0

For nCont := 1 To Len(aMarcs)
	oRet     	:= JsonObject():New()
	
	If aMarcs[nCont]["codRelogioExtChave"] <> Nil .And. AllTrim(Upper(aMarcs[nCont]["codRelogioExtChave"])) == "PONTOWEB"
		lPontoWeb := .T.
		lGrvUsr := .T.
		
		oRet["codCCT"]				:= cCodCCT		:= If(aMarcs[nCont]["codCCT"] == Nil, "", cValToChar(aMarcs[nCont]["codCCT"]))
		oRet["codCPF"]				:= cCodCPF		:= aMarcs[nCont]["codCPF"]
		oRet["codFuncMsa"]			:= aCodFuncM	:= aMarcs[nCont]["codFuncMsa"]
		oRet["codFuso"]				:= cCodFuso		:= aMarcs[nCont]["codFuso"]
		oRet["codNsr"]				:= nCodNSR		:= aMarcs[nCont]["codNsr"]
		oRet["codRelogioExtChave"]	:= cCodRelExt	:= Upper(aMarcs[nCont]["codRelogioExtChave"])
		oRet["codRep"]				:= cCodREP		:= aMarcs[nCont]["codRep"]
		oRet["codUsuarExtChave"]	:= aCodUsrExt	:= aMarcs[nCont]["codUsuarExtChave"]
		oRet["datMarcacAces"]		:= cDatMarcac	:= aMarcs[nCont]["datMarcacAces"]
		oRet["numHorarMarcacAces"]	:= nNumMarcac	:= aMarcs[nCont]["numHorarMarcacAces"]
		oRet["numVersLayout"]		:= nVersLayou	:= aMarcs[nCont]["numVersLayout"]
		oRet["inscrEmp"]			:= cInscrEmp	:= aMarcs[nCont]["inscrEmp"]
		
		If !Empty(aCodUsrExt) .And. ValType(aCodUsrExt) == "A"
			cCodUsrExt := aCodUsrExt[1]
			If Len(aCodUsrExt) > 1
				lGrvUsr := .F.
			EndIf
		EndIf
		
		If !Empty(aCodFuncM) .And. ValType(aCodFuncM) == "A"
			cCodFuncM := aCodFuncM[1]
			If Len(aCodFuncM) > 1
				lGrvUsr := .F.
			EndIf
		EndIf
		
		aEmp := fDefEmp(@aGrpEmp, If(ValType(cCodUsrExt) != "C", "", cCodUsrExt))
		
		cTipoREP := If(Empty(cCodCCT), "4", "2") //4 = REP-P; 2 = REP-A
		
		If !Empty(cCodREP) .And. ValType(cCodREP) == "C"
			// Verifica se o relógio está cadastrado na filial da marcação
			For nI := 1 To Len(aCodUsrExt)
				If !fDisp(cCodREP,, aEmp, aCodUsrExt[nI])
					//Caso não encontre, cadastra o relógio
					NewREP(aEmp, aCodUsrExt[nI], cCodREP, cTipoREP)
				EndIf
			Next nI
		EndIf
		
		If !lRR1671
			lTudoOk			:= .F.
			oRet["message"]	:= STR0038 // "Não foram encontrados os campos RR1_CODPIS, RR1_FUSO, RR1_VRSLAY, RR1_INSCR, RR1_CCTREP na tabela RR1. Atualize o ambiente com o pacote mais recente de expedição contínua do RH."
			oRet["status"]	:= 400
			
			aAdd( aRet, oRet )
			Loop
		ElseIf Empty(aEmp)
			lTudoOk			:= .F.
			oRet["message"]	:= STR0039 // "Empresa não encontrada. Verifique se o campo 'codUsuarExtChave' possui uma empresa válida."
			oRet["status"]	:= 400
			
			aAdd( aRet, oRet )
			Loop
		ElseIf cCodCPF == Nil .Or. cCodFuncM == Nil .Or. cCodFuso == Nil .Or. nCodNSR == Nil .Or. cCodRelExt == Nil .Or. cCodREP == Nil .Or. cCodUsrExt == Nil .Or. cDatMarcac == Nil .Or. nNumMarcac == Nil .Or. nVersLayou == Nil
			lTudoOk			:= .F.
			oRet["message"]	:= STR0040 // "Algum campo obrigatório não foi informado. Verifique se os campos 'codCPF', 'codFuncMsa', 'codFuso', 'codNsr', 'codRelogioExtChave', 'codRep', 'codUsuarExtChave', 'datMarcacAces', 'numHorarMarcacAces' ou 'numVersLayout' foram enviados."
			oRet["status"]	:= 400
			
			aAdd( aRet, oRet )
			Loop
		ElseIf Empty(cCodCPF) .Or. ValType(cCodCPF) != "C"
			lTudoOk			:= .F.
			oRet["message"]	:= If(Empty(cCodCPF), STR0041, STR0042) // "O campo codCPF está vazio.", "codCPF no formato inválido. Ele deve ser preenchido como caractere."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf Empty(cCodFuncM) .Or. ValType(cCodFuncM) != "C"
			lTudoOk			:= .F.
			oRet["message"]	:= If(Empty(cCodFuncM), STR0043, STR0044) // "O campo codFuncMsa está vazio.", "codFuncMsa no formato inválido. Ele deve ser preenchido como caractere."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf ValType(cCodFuso) != "C"
			lTudoOk			:= .F.
			oRet["message"]	:= STR0045 // "codFuso no formato inválido. Ele deve ser preenchido como caractere."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf Empty(nCodNSR) .Or. ValType(nCodNSR) != "N"
			lTudoOk			:= .F.
			oRet["message"]	:= If(Empty(nCodNSR), STR0046, STR0047) // "O campo codNsr está vazio.", "codNsr no formato inválido. Ele deve ser preenchido como númerico."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf Empty(cCodREP) .Or. ValType(cCodREP) != "C"
			lTudoOk			:= .F.
			oRet["message"]	:= If(Empty(cCodREP), STR0055, STR0048)  //"O campo codRep está vazio" - "codRep no formato inválido. Ele deve ser preenchido como caractere."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf Empty(cDatMarcac) .Or. ValType(cDatMarcac) != "C"
			lTudoOk			:= .F.
			oRet["message"]	:= If(Empty(cDatMarcac), STR0051, STR0052) // "O campo datMarcacAces está vazio.", "datMarcacAces no formato inválido. Ele deve ser preenchido como caractere."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf ValType(nNumMarcac) != "N"
			lTudoOk			:= .F.
			oRet["message"]	:= STR0053 // "numHorarMarcacAces no formato inválido. Ele deve ser preenchido como númerico."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf ValType(nVersLayou) != "N"
			lTudoOk			:= .F.
			oRet["message"]	:= STR0054 // "numVersLayout no formato inválido. Ele deve ser preenchido como númerico."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf !fValNSR(nCodNSR, cCodREP, cCodRelExt, aEmp, .T., cInscrEmp)
			lTudoOk			:= .F.
			oRet["message"]	:= STR0026 // "NSR duplicado. Número já foi importado na tabela."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		ElseIf cTipoREP == "4" .And. (Empty(cInscrEmp) .Or. ValType(cInscrEmp) != "C")
			lTudoOk			:= .F.
			oRet["message"]	:= If(Empty(cInscrEmp), STR0056, STR0031) // "O campo cInscrEmp está vazio." - "cInscrEmp no formato inválido. Ele deve ser preenchido como caractere."
			oRet["status"]	:= 400
			
			aAdd(aRet, oRet)
			Loop
		EndIf
		
		cCodUniExt := "PONTOWEB"
		cCodRelExt := ""
	Else
		cCodRelExt	:= aMarcs[nCont]["codRelogioExtChave"]
		cCodFuncM	:= aMarcs[nCont]["codFuncMsa"]
		nCodNSR		:= aMarcs[nCont]["codNsr"]
		cCodPIS		:= aMarcs[nCont]["codPisMsa"]
		cDatMarcac	:= aMarcs[nCont]["datMarcacAces"]
		nNumMarcac	:= aMarcs[nCont]["numHorarMarcacAces"]
		cCodREP		:= aMarcs[nCont]["codRep"]
		cCodUsrExt	:= aMarcs[nCont]["codUsuarExtChave"]
		nVersLayou	:= 0

		If aMarcs[nCont]["codFuso"] <> Nil .And. aMarcs[nCont]["codCPF"] <> Nil .And. aMarcs[nCont]["numVersLayout"] <> Nil .And. aMarcs[nCont]["inscrEmp"] <> Nil
			cCodFuso	:= aMarcs[nCont]["codFuso"]
			cCodCPF		:= aMarcs[nCont]["codCPF"]
			cInscrEmp	:= aMarcs[nCont]["inscrEmp"]

			If Empty(aMarcs[nCont]["numVersLayout"])
				nVersLayou := 0
			ElseIf ValType(aMarcs[nCont]["numVersLayout"]) == "C"
				nVersLayou := Val(aMarcs[nCont]["numVersLayout"])
			ElseIf ValType(aMarcs[nCont]["numVersLayout"]) == "N"
				nVersLayou := aMarcs[nCont]["numVersLayout"]
			EndIf

			lEnv671 := .T.
		EndIf

		If aMarcs[nCont]["codCCT"] <> Nil .And. ValType(aMarcs[nCont]["codCCT"]) == "C"
			cCodCCT := aMarcs[nCont]["codCCT"]
		Else
			cCodCCT := ""
		EndIf
		
		If ValType(aMarcs[nCont]["codUnidExtChave"]) != "C"
			cCodUniExt := ""
		Else
			cCodUniExt := aMarcs[nCont]["codUnidExtChave"]
		EndIf

		aEmp := {}
		aEmp := fDefEmp(@aGrpEmp, cCodUniExt)

		If (cCodRelExt == Nil .And. cCodREP == Nil) .Or. cCodFuncM == Nil .Or. cCodPIS == Nil .Or. cDatMarcac == Nil .Or.;
			nNumMarcac == Nil .Or. cCodUniExt == Nil .Or. cCodUsrExt == Nil
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			
			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf 
			
			oRet["message"] 			:= STR0033 // "Não foi informado algum dos campos obrigatórios: 'codRelogioExtChave', 'codFuncMsa', 'codPisMsa', 'datMarcacAces', 'numHorarMarcacAces', 'codRep', 'codUnidExtChave' ou 'codUsuarExtChave'."
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"

			aAdd( aRet, oRet )
			Loop
		ElseIf Empty(aEmp)
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			
			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf 
			
			oRet["message"] 			:= STR0036 // "Empresa não encontrada. Verifique se o campo 'codUnidExtChave' possui uma empresa válida."
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"

			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cCodRelExt ) != "C"
			lTudoOk				:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			
			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0014 // "Campo 'codRelogioExtChave' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cCodFuncM ) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			
			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0015 // "Campo 'codFuncMsa' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( nCodNSR ) != "U" .And. ValType( nCodNSR ) != "N"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0016 // "Campo 'codNsr' no formato incorreto. Deve ser preenchido como numérico."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cCodPIS ) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0017 // "Campo 'codPisMsa' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cDatMarcac ) != "C" .Or. ValType( sToD( StrTran( SubStr(cDatMarcac, 1, 10), "-" ) ) ) != "D"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0018 // "Campo 'datMarcacAces' no formato incorreto. Deve ser preenchido como data."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( nNumMarcac ) != "N"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0019 // "Campo 'numHorarMarcacAces' no formato incorreto. Deve ser preenchido como numérico."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cCodREP ) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0020 // "Campo 'codRep' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cCodUniExt ) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0021 // "Campo 'codUnidExtChave' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf ValType( cCodUsrExt ) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0022 // "Campo 'codUsuarExtChave' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf !lEnv671 .And. !fValPis(cCodPIS, aEmp)
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00001"
			oRet["message"] 			:= STR0023 // "PIS em formato inválido ou inexistente no cadastro."
			aAdd( aRet, oRet )
			Loop
		ElseIf !fDisp(cCodREP, cCodRelExt,aEmp)
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			
			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00007"
			oRet["message"] 			:= STR0024 // "Foi enviado marcações de um relógio que não está cadastrado no ERP."
			aAdd( aRet, oRet )
			Loop
		ElseIf nCodNSR == Nil
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf
			
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00003"
			oRet["message"] 			:= STR0025 // "NSR não foi informado e é obrigatório."
			aAdd( aRet, oRet )
			Loop
		ElseIf !fValNSR(nCodNSR, cCodREP, cCodRelExt,aEmp)
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt

			If lEnv671
				oRet["codFuso"]				:= cCodFuso
				oRet["codCPF"]				:= cCodCPF
				oRet["numVersLayout"]		:= nVersLayou
				oRet["inscrEmp"]			:= cInscrEmp
				oRet["codCCT"]				:= cCodCCT
			EndIf

			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00002"
			oRet["message"] 			:= STR0026 // "NSR duplicado. Número já foi importado na tabela."
			aAdd( aRet, oRet )
			Loop
		ElseIf lEnv671 .And. !Empty(cCodFuso) .And. ValType(cCodFuso) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["codCCT"]				:= cCodCCT
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00009"
			oRet["message"] 			:= STR0034 // "Campo 'codFuso' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop	
		ElseIf lEnv671 .And. !Empty(cCodCPF) .And. ValType(cCodCPF) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["codCCT"]				:= cCodCCT
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00009"
			oRet["message"] 			:= STR0032 // "Campo 'codCPF' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf lEnv671 .And. !Empty(cCodCPF) .And. !ChkCPF(cCodCPF)
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["codCCT"]				:= cCodCCT
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0029 // "CPF inválido."
			aAdd( aRet, oRet )
			Loop
		ElseIf lEnv671 .And. !Empty(nVersLayou) .And. ValType(nVersLayou) != "N"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0030 // "Campo 'numVersLayout' no formato incorreto. Deve ser preenchido como número."
			aAdd( aRet, oRet )
			Loop
		ElseIf lEnv671 .And. !Empty(cInscrEmp) .And. ValType(cInscrEmp) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["codCCT"]				:= cCodCCT
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0031 // "Campo 'inscrEmp' no formato incorreto. Deve ser preenchido como texto."
			aAdd( aRet, oRet )
			Loop
		ElseIf (lEnv671 .And. Empty(cCodCPF) .And. Empty(cCodPIS)) .Or. (!lEnv671 .And. Empty(cCodPIS))
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["codCCT"]				:= cCodCCT
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0035 // "O documento do funcionário não foi enviado. O PIS ou o CPF deve ser preenchido."
			aAdd( aRet, oRet )
			Loop
		ElseIf lEnv671 .And. ValType(aMarcs[nCont]["codCCT"]) != "C"
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["codFuso"]				:= cCodFuso
			oRet["codCPF"]				:= cCodCPF
			oRet["numVersLayout"]		:= nVersLayou
			oRet["inscrEmp"]			:= cInscrEmp
			oRet["codCCT"]				:= aMarcs[nCont]["codCCT"]
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "00006"
			oRet["message"] 			:= STR0037 // "O Campo 'codCCT' foi enviado no formato incorreto. Ele deve ser preenchido como caractere."
			aAdd( aRet, oRet )
			Loop
		EndIf
	EndIf
	
	If EmpOpenFile("RR1","RR1",1,.T.,aEmp[1,1],@cModo)
		If RR1->( Reclock("RR1", .T.) )
			RR1->RR1_VALCON		:= fProxVal(aEmp)
			RR1->RR1_CODREL		:= cCodRelExt
			RR1->RR1_LOGIP		:= "0"
			RR1->RR1_CODNSR		:= nCodNSR
			RR1->RR1_CODPIS		:= cCodPIS
			RR1->RR1_DATMAR		:= sToD( StrTran( SubStr(cDatMarcac, 1, 10), "-" ) )
			RR1->RR1_NUMMAR		:= nNumMarcac
			RR1->RR1_CODREP		:= cCodREP
			RR1->RR1_CODUNI		:= cCodUniExt
			If lGrvUsr
				RR1->RR1_CODFUN		:= cCodFuncM
				RR1->RR1_CODUSU		:= cCodUsrExt
			EndIF
			
			If (lRR1671 .And. lEnv671) .Or. lPontoWeb
				RR1->RR1_FUSO		:= cCodFuso
				RR1->RR1_CODCPF		:= cCodCPF
				RR1->RR1_VRSLAY		:= nVersLayou
				RR1->RR1_INSCR		:= cInscrEmp
				RR1->RR1_CCTREP		:= cCodCCT		
			EndIf
			
			RR1->( MsUnlock() )
			If !lPontoWeb
				oRet["codRelogioExtChave"]	:= cCodRelExt
				oRet["codFuncMsa"]			:= cCodFuncM
				oRet["codNsr"]				:= nCodNSR
				oRet["codPisMsa"]			:= cCodPIS
				oRet["datMarcacAces"]		:= cDatMarcac
				oRet["numHorarMarcacAces"]	:= nNumMarcac
				oRet["codRep"]				:= cCodREP
				oRet["codUnidExtChave"]		:= cCodUniExt
				oRet["codUsuarExtChave"]	:= cCodUsrExt
				
				If lEnv671
					oRet["codFuso"]				:= cCodFuso
					oRet["codCPF"]				:= cCodCPF
					oRet["numVersLayout"]		:= nVersLayou
					oRet["inscrEmp"]			:= cInscrEmp
					oRet["codCCT"]				:= cCodCCT
				EndIf
			EndIf
			
			oRet["status"] 				:= 200
			oRet["errorCode"] 			:= ""
			oRet["message"] 			:= STR0027 // "Gravação efetuada com sucesso."
			aAdd( aRet, oRet )
		Else
			lTudoOk						:= .F.
			oRet["codRelogioExtChave"]	:= cCodRelExt
			oRet["codFuncMsa"]			:= cCodFuncM
			oRet["codNsr"]				:= nCodNSR
			oRet["codPisMsa"]			:= cCodPIS
			oRet["datMarcacAces"]		:= cDatMarcac
			oRet["numHorarMarcacAces"]	:= nNumMarcac
			oRet["codRep"]				:= cCodREP
			oRet["codUnidExtChave"]		:= cCodUniExt
			oRet["codUsuarExtChave"]	:= cCodUsrExt
			oRet["status"] 				:= 400
			oRet["errorCode"] 			:= "99999"
			oRet["message"] 			:= "Erro interno no lock da tabela RR1. Registro não foi gravado"
			aAdd( aRet, oRet )
		EndIf
		EmpOpenFile("RR1","RR1",1,.T.,cEmpAntBck,@cModo)
		lPontoWeb := .F.
		Loop
	EndIf
Next nCont

oResp["items"]	:= aRet

Return lTudoOk

/*/{Protheus.doc} fProxVal
Busca o proximo registro sequencial da tabela RR1.
@author Allyson Mesashi
@since 16/10/2020
/*/
Static Function fProxVal(aEmp)
Local cAliasTMP := GetNextAlias()
Local nContador := 0
Local cTabela	:= ""

cTabela := "%" + aEmp[1,3] + "%"

BeginSql alias cAliasTMP
	SELECT 	MAX(RR1_VALCON) AS MAXIMO
	FROM 	%Exp:cTabela%
EndSql

nContador := (cAliasTMP)->(MAXIMO)

(cAliasTMP)->(dbCloseArea())

nContador += 1

Return nContador

/*/{Protheus.doc} fValPis
Efetua busca do PIS na SRA
@author Allyson Mesashi
@since 26/03/2021
@version P12.1.27
/*/
Static Function fValPis(cCodPIS,aEmp)
Local cPisSRA		:= Iif( Left( cCodPIS , 1) == "0", Right(cCodPIS, 11), cCodPIS )
Local lRet			:= .F.
Local cModo			:= ""
Local cEmpAntBck	:= cEmpAnt
Local aArea 		:= GetArea()
Local aAreaSRA 		:= SRA->(GetArea())

Default aEmp 	:= {}

If EmpOpenFile("SRA","SRA",26,.T.,aEmp[1,1],@cModo)
	lRet := SRA->( dbSeek( cPisSRA ) )
EndIf

EmpOpenFile("SRA","SRA",26,.T.,cEmpAntBck,@cModo)
RestArea(aArea)
RestArea(aAreaSRA)

Return lRet

/*/{Protheus.doc} fDisp
Efetua busca do dispositivo
@author Allyson Mesashi
@since 26/03/2021
@version P12.1.27
/*/
Static Function fDisp(cCodREP, cCodRelExt, aEmp, cCodUsrExt)
Local cAliasQRY := GetNextAlias()
Local cCodRel	:= ""
Local cQuery	:= ""
Local lRet		:= .F.

Default cCodREP 	:= ""
Default cCodRelExt 	:= ""
Default aEmp 		:= {}
Default cCodUsrExt 	:= ""

If !Empty(cCodREP)
	cCodRel	:= cCodREP
Else
	cCodRel	:= cCodRelExt
EndIf

If __oSt1 == Nil
	__oSt1 := FWPreparedStatement():New()	 

	cQuery := "SELECT COUNT(*) AS CONT "
	cQuery += "FROM ? "
	cQuery += "WHERE "
	cQuery += "P0_REP = ? AND "

	If !Empty(cCodUsrExt)
		cQuery += "P0_FILIAL = ? AND "
	EndIf
	
	cQuery += "D_E_L_E_T_= ' '"	
	cQuery := ChangeQuery(cQuery)
	
	__oSt1:SetQuery(cQuery)
EndIf

__oSt1:SetString(1, aEmp[1,2])
__oSt1:SetString(2, cCodRel)

If !Empty(cCodUsrExt)
	__oSt1:SetString(3, xFilial("SP0", SubStr(cCodUsrExt, Len(aEmp[1][1]) + 1, aEmp[1][4])))
EndIf

cQuery := __oSt1:getFixQuery()

cQuery := StrTran(cQuery, "'" + aEmp[1,2] + "'",aEmp[1,2])

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQRY)

lRet := (cAliasQRY)->CONT > 0

(cAliasQRY)->( dbCloseArea() )

Return lRet

/*/{Protheus.doc} fValNSR
Efetua validação/busca do NSR
@author Allyson Mesashi
@since 26/03/2021
@version P12.1.27
/*/
Static Function fValNSR(nCodNSR, cCodREP, cCodRelExt, aEmp, lPontoWeb, cInscrEmp)
Local cAliasQRY 	:= GetNextAlias()
Local cChaveBus		:= ""
Local cCodRel		:= ""
Local cQuery		:= ""
Local cModo			:= ""
Local lMarc			:= .F.
Local lRep			:= .F.
Local lRet			:= .T.
Local cEmpAntBck	:= cEmpAnt
Local aArea 		:= GetArea()
Local aAreaRR1 		:= RR1->(GetArea())
Local aAreaSP0 		:= SP0->(GetArea())

Default nCodNSR		:= 0
Default cCodREP		:= ""
Default cCodRelExt	:= ""
Default aEmp 		:= {}
Default lPontoWeb	:= .F.
Default cInscrEmp	:= ""

If lPontoWeb
	If __oSt3 == Nil
		__oSt3 := FWPreparedStatement():New()	 
		
		cQuery := "SELECT R_E_C_N_O_ AS RECNO "
		cQuery += "FROM ? "
		cQuery += "WHERE RR1_CODUNI = ?"
		cQuery += " AND RR1_CODREP = ?"
		cQuery += " AND RR1_CODNSR = ?"
		cQuery += " AND RR1_INSCR = ?"
		cQuery += " AND D_E_L_E_T_= ?"
		cQuery := ChangeQuery(cQuery)
		
		__oSt3:SetQuery(cQuery)
	EndIf
	
	__oSt3:SetString(1, aEmp[1,3])
	__oSt3:SetString(2, cCodRelExt)
	
	If !Empty(cCodREP)
		__oSt3:SetString(3, cCodREP)
	Else
		__oSt3:SetString(3, " ")
	EndIf
	
	__oSt3:setNumeric(4, nCodNSR)
	
	If !Empty(cInscrEmp)
		__oSt3:SetString(5, cInscrEmp)
	Else
		__oSt3:SetString(5, " ")
	EndIf
	
	__oSt3:SetString(6, " ")
	
	cQuery := __oSt3:getFixQuery()
	
	cQuery := StrTran(cQuery, "'" + aEmp[1,3] + "'",aEmp[1,3])
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQRY)
	
	If (cAliasQRY)->(!EoF())
		lRet := .F.
		(cAliasQRY)->(DbSkip())
	EndIf
	
	(cAliasQRY)->(dbCloseArea())
Else
	If !Empty(cCodREP)
		cCodRel	:= cCodREP
		lRep	:= .T.
	Else
		cCodRel	:= cCodRelExt
	EndIf

	If __oSt2 == Nil
		__oSt2 := FWPreparedStatement():New()	 

		cQuery := "SELECT R_E_C_N_O_ AS RECNO "
		cQuery += "FROM ? "
		cQuery += "WHERE "
		cQuery += "P0_REP = ? AND "
		cQuery += "D_E_L_E_T_= ' '"	
		cQuery := ChangeQuery(cQuery)
		
		__oSt2:SetQuery(cQuery)
	EndIf

	__oSt2:SetString(1, aEmp[1,2])
	__oSt2:SetString(2, cCodRel)

	cQuery := __oSt2:getFixQuery()

	cQuery := StrTran(cQuery, "'" + aEmp[1,2] + "'",aEmp[1,2])

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasQRY)

	If (cAliasQRY)->( !EoF() )
		If EmpOpenFile("SP0","SP0",1,.T.,aEmp[1,1],@cModo)
			SP0->( dbGoTo((cAliasQRY)->RECNO) )
			lMarc := SP0->P0_CONTROL == "P"
		EndIf
	EndIf

	(cAliasQRY)->( dbCloseArea() )

	If lRet .And. lMarc
		If EmpOpenFile("RR1","RR1",1,.T.,aEmp[1,1],@cModo)
			If lRep
				RR1->( dbSetOrder(7) )//RR1_CODREP+STR(RR1_CODNSR,9)
				cChaveBus := PadR(cCodREP, nTamCodRep)+Str(nCodNSR, 9)
			Else
				RR1->( dbSetOrder(5) )//RR1_CODREL+STR(RR1_CODNSR,9)
				cChaveBus := PadR(cCodRel, nTamCodRel)+Str(nCodNSR, 9)
			EndIf
			
			If RR1->( dbSeek( cChaveBus ) )
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
	
EmpOpenFile("SP0","SP0",1,.T.,cEmpAntBck,@cModo)
EmpOpenFile("RR1","RR1",1,.T.,cEmpAntBck,@cModo)
RestArea(aArea)
RestArea(aAreaRR1)
RestArea(aAreaSP0)

Return lRet

/*/{Protheus.doc} fDefEmp
Função para definir qual grupo de empresas deverá ser utilizado para validar e salvar a marcação
@author Marco Nakazawa
@since 25/05/2023
@version P12.1.2210
/*/
Static Function fDefEmp(aGrpEmp, cCodUniExt)
	
	Local nI			:= 0
	Local aRet			:= {}
	Local cEmpMarc		:= SubStr(cCodUniExt, 1, Len(cEmpAnt))
	
	Default	aGrpEmp		:= {}
	Default	cCodUniExt	:= ""
	
	If !Empty(cCodUniExt) .And. !Empty(aGrpEmp)
		For nI := 1 To Len(aGrpEmp)
			If aGrpEmp[nI, 1] $ cEmpMarc
				aAdd(aRet, aGrpEmp[nI])
				EXIT
			EndIf
		Next
	EndIf
	
	If Empty(aRet)
		aRet := AddEmp(cEmpMarc, @aGrpEmp)
	EndIf
	
Return aRet

/*/{Protheus.doc} NewREP
Chama a função para a inclusão de um novo relógio
@type static function
@author Cícero Alves
@since 19/09/2025
@param aEmp, array, informações sobre o grupo de empresas e tabelas utilizadas
@param cCodUsrExt, character, chave composta por Empresa + Filial + Matrícula
@param cCodREP, character, Código REP 
@param cTipoREP, character, Qual o tipo do REP de acordo com a portaria 671
@return nil, nil
/*/
Static Function NewREP(aEmp, cCodUsrExt, cCodREP, cTipoREP)
	
	Local nCount	:= 0
	Local cUID		:= ""
	Local cFilFunc	:= ""
	Local lExecJob	:= .F.
	Local nTime		:= 1000
	
	DEFAULT aEmp := {}
	DEFAULT cCodUsrExt := ""
	DEFAULT cCodREP := ""
	DEFAULT cTipoREP := ""

	cFilFunc := SubStr(cCodUsrExt, Len(aEmp[1][1]) + 1, aEmp[1][4])
	
	If !Empty(aEmp)
		
		If lExecJob := !(aEmp[1][1] == cEmpAnt .And. cFilFunc == cFilAnt)
			//Define o nome da variavel de controle
			cUID := "APIRR1_NEW_REP_" + AllTrim(Str(ThreadID()))
			
			//Atribui a variavel de controle
			PutGlbValue(cUID, "0")
			
			StartJob( "fNewSP0", GetEnvServer(), .T., aEmp, cCodUsrExt, cCodREP, cTipoREP, lExecJob, cUID)
			
		Else
			fNewSP0(aEmp, cCodUsrExt, cCodREP, cTipoREP)
		EndIf
		
	EndIf
	
	While lExecJob
		//Obtem o valor da variavel global
		If (GetGlbValue(cUID) == "1", nCount := 10, (nCount++, Sleep(nTime)))
		
		lExecJob := (nCount < 10)
	EndDo
	
	//Limpa a variavel global da memoria
	If !Empty(cUID)
		ClearGlbValue(cUID)
	EndIf
	
Return

/*/{Protheus.doc} fNewSP0
Realiza a inclusão de um relógio com as informação enviadas pelo PontoWeb
@type static function
@author Cícero Alves
@since 11/08/2025
@param aEmp, array, Informações da empresa e filial
@param cCodUsrExt, character, Chave com Empresa + Filial + Mantrícula 
@param cCodREP, character, Número identificador do REP
@param cTipoREP, character, Tipo do REP de acordo com o campo P0_TPREP
@return NIL, NIL
/*/
Function fNewSP0(aEmp, cCodUsrExt, cCodREP, cTipoREP, lExecJob, cUID)
	
	Local cCodSP0		:= ""
	Local cFilFunc		:= ""
	Local cFilSP0		:= ""
	Local aInfo			:= {}
	
	DEFAULT cCodREP := ""
	DEFAULT cTipoREP := ""
	DEFAULT cCodUsrExt := ""
	DEFAULT lExecJob := .F.
	DEFAULT cUID := ""
	
	cFilFunc := SubStr(cCodUsrExt, Len(aEmp[1][1]) + 1, aEmp[1][4])
	
	If lExecJob
		RPCSetType(3)
		RPCSetEnv(aEmp[1][1], cFilFunc)
	EndIf
	
	cFilSP0 := xFilial("SP0", cFilFunc)
	cCodSP0 := GetNextSP0(cFilSP0)
	
	aAdd(aInfo, {"P0_FILIAL" , cFilSP0		  , NIL})
	aAdd(aInfo, {"P0_RELOGIO", cCodSP0		  , NIL})
	aAdd(aInfo, {"P0_NOVO"   , "1"	  		  , NIL})
	aAdd(aInfo, {"P0_DESC"   , "PONTOWEB AUTO", NIL})
	aAdd(aInfo, {"P0_CONTROL", "P"		 	  , NIL})
	aAdd(aInfo, {"P0_TIPOARQ", "R"			  , NIL})
	aAdd(aInfo, {"P0_ARQUIVO", "PONTOWEB"	  , NIL})
	aAdd(aInfo, {"P0_REP"    , cCodREP		  , NIL})
	aAdd(aInfo, {"P0_INC"    , "1"			  , NIL})
	aAdd(aInfo, {"P0_TPREP"  , cTipoREP		  , NIL})
	
	// Realiza a inclusão do relógio
	PONA030(aInfo, 3)
	
	If lExecJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf
	
Return

/*/{Protheus.doc} GetNextSP0
Busca o próximom código disponível para uso na SP0
@type static function
@author Cícero Alves
@since 11/08/2025
@param cFilSP0, character, Filial da tabela SP0
@return character, Próximo código para ser usado na SP0
/*/
Static Function GetNextSP0(cFilSP0)
	
	Local cCodSP0 	:= ""
	Local cCodAux	:= ""
	Local nI		:= 1
	Local nTamRel	:= GetSx3Cache("P0_RELOGIO", "X3_TAMANHO")
	Local nMax		:= Val(Replicate("9", nTamRel))
	
	DEFAULT cFilSP0 := xFilial("SP0")
	
	dbSelectArea("SP0")
	
	While nI <= nMax
		cCodAux := StrZero(nI, nTamRel, 0)
		If !SP0->(dbSeek(cFilSP0 + cCodAux))
			cCodSP0 := cCodAux
			EXIT
		EndIf
		nI++
	EndDo
	
Return cCodSP0

/*/{Protheus.doc} AddEmp
Adiciona informações sobre as tabelas no array aGrpEmp
@type static function
@author Cícero Alves
@since 19/09/2025
@param cEmpAtual, character, Grupo de empresas
@param aGrpEmp, array, array onde as informações serão adicionadas; passado por referência
@return Array, informações que foram adionadas no aGrpEmp
/*/
Static Function AddEmp(cEmpAtual, aGrpEmp)
	
	Local cEmpLog	:= cEmpAnt
	Local aAux		:= {}
	Local aRet		:= {}
	
	DEFAULT cEmpAtual := cEmpAnt
	DEFAULT aGrpEmp := {}
	
	If cEmpAtual == cEmpLog
		aAdd(aGrpEmp, {cEmpAtual, RetSqlName('SP0'), RetSqlName('RR1'), Len(xFilial("SRA"))})
		aAdd(aRet, aTail(aGrpEmp))
	Else
		aAux := GetEmpInfo(cEmpAtual)
		If !Empty(aAux) .And. Len(aAux) == 3
			aAdd(aGrpEmp, {cEmpAtual, aAux[1], aAux[2], aAux[3]})
			aAdd(aRet, aTail(aGrpEmp))
		EndIf
	EndIf
	
Return aRet

/*/{Protheus.doc} GetEmpInfo
Chama o job para buscar informações de um grupo de empresas diferente do logado
@type static function
@author Cícero Alves
@since 19/09/2025
@param cEmpAtual, character, grupo de empresas
@return array, Informaçãoes das tabelas SP0; RR1 e o tamanho do campo filial
/*/
Static Function GetEmpInfo(cEmpAtual)
	
	Local aRet		:= {}
	Local nCount	:= 0
	Local cUID		:= ""
	Local lExecJob	:= .T.
	Local nTime		:= 500
	
	DEFAULT cEmpAtual := cEmpAnt
	
	//Define o nome da variavel de controle
	cUID := "APIRR1_EMP_INFO_" + AllTrim( Str(ThreadID()) )
	
	//Atribui a variavel de controle				
	PutGlbValue(cUID, "0")
	
	//Define a criação e o retorno do Job				
	aRet := StartJob( "JobEmpInfo", GetEnvServer(), .T., cEmpAtual, cUID )
	
	While lExecJob
		//Obtem o valor da variavel global
		If (GetGlbValue(cUID) == "1", nCount := 10, (nCount++, Sleep(nTime)))
		
		lExecJob := (nCount < 10)
	EndDo
	
	//Limpa a variavel global da memoria
	If !Empty(cUID)
		ClearGlbValue(cUID)
	EndIf
	
Return aRet

/*/{Protheus.doc} JobEmpInfo
Job para buscar os nomes físico das taberlas em um grupo de empresas diferente do logado
@type function
@author Cícero Alves
@since 19/09/2025
@param cEmpAtual, character, grupo de empresas
@param cUID, character, ID da thread
@return array, Informaçãoes das tabelas SP0; RR1 e o tamanho do campo filial
/*/
Function JobEmpInfo(cEmpAtual, cUID)
	
	Local aRet 			:= {}
	Local cFilialVld	:= ""
	
	DEFAULT cEmpAtual := cEmpAnt
	DEFAULT cFilialVld := FwCodFil(cEmpAtual)
	
	RPCSetType(3)
	RPCSetEnv(cEmpAtual, cFilialVld)
	
	aAdd(aRet, RetSqlName('SP0'))
	aAdd(aRet, RetSqlName('RR1'))
	aAdd(aRet, Len(xFilial("SRA")))
	
	//Atualiza a variavel de controle que indica a finalizacao do JOB
	PutGlbValue(cUID, "1")
	
Return aRet
