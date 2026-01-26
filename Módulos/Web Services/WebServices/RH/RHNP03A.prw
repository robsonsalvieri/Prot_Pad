#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP03.CH"

/*/{Protheus.doc} GetTrfDetails
- Efetua a query na SRC/SRD a partir dos dados de transferencia e efetuando a consulta em cada arquivo do grupo correspondente

@author:	Marcelo Silveira
@since:		20/12/2021
@param:		aTransAux - Array com os dados da transferencia;
			nCount - Posicao do registro que esta sendo avaliado dentro do array;
			cQuery - Alias da query recebido por referencia;
			initView - Data inicio do periodo para filtro;
			endView - Data fim do periodo para filtro;
			lOrigem - Se verdadeiro indica que a consulta sera feita a partir dos dados de origem
/*/
Function GetTrfDetails(aTransAux, nCount, cQuery, initView, endView, lOrigem)
	
	Local cWhrSRC		:= ""
	Local cWhrSRD		:= ""
	Local cSRCEmp		:= ""
	Local cSRDEmp		:= ""
	Local cSRVEmp		:= ""
	Local cJoinSRCFil	:= "%%"
	Local cJoinSRDFil	:= "%%"
	Local cMod			:= If(SRA->RA_REGIME=='2', 'GFP','GPE')
	Local nPosEmp		:= 2
	Local nPosFil		:= 4
	Local nPosMat		:= 6
	Local lRet			:= .F.
	Local aTabJoin		:= {}
	Local aRetJoin		:= {}

	DEFAULT cLastPer	:= ""
	DEFAULT aTransAux	:= {}
	DEFAULT nCount		:= 0
	DEFAULT cQuery		:= GetNextAlias()
	DEFAULT initView	:= ""
	DEFAULT endView		:= ""
	DEFAULT lOrigem		:= .F.
	
	//Avalia os dados da transferencia a partir da empresa origem
	If lOrigem
		nPosEmp	:= 1
		nPosFil	:= 3
		nPosMat	:= 5
	EndIf

	//Pesquisa no arquivo da empresa para a busca dos resultados
	cSRCEmp := "%" + RetFullName("SRC", aTransAux[nCount,nPosEmp]) + "%"
	cSRDEmp := "%" + RetFullName("SRD", aTransAux[nCount,nPosEmp]) + "%" 
	cSRVEmp := "%" + RetFullName("SRV", aTransAux[nCount,nPosEmp]) + "%"

	aAdd( aTabJoin, {"SRC", "SRV"} )
	aAdd( aTabJoin, {"SRD", "SRV"} )

	aRetJoin := GetDataForJob( "9", {aTransAux[nCount,nPosEmp], aTransAux[nCount,nPosFil], aTabJoin, .T.}, aTransAux[nCount,nPosEmp] )
	If Len(aRetJoin) == Len(aTabJoin)
		cJoinSRCFil := "%" + If( !Empty(aRetJoin[1]), aRetJoin[1] + " AND ", "") + "%"
		cJoinSRDFil := "%" + If( !Empty(aRetJoin[2]), aRetJoin[2] + " AND ", "") + "%"
	EndIf

	cWhrSRC := "%"
	cWhrSRD := "%"
	
	cWhrSRC += " (SRC.RC_FILIAL = '" + aTransAux[nCount][nPosFil] + "'"
	cWhrSRD += " (SRD.RD_FILIAL = '" + aTransAux[nCount][nPosFil] + "'"

	cWhrSRC += " AND SRC.RC_MAT = '" + aTransAux[nCount][nPosMat] + "'"
	cWhrSRD += " AND SRD.RD_MAT = '" + aTransAux[nCount][nPosMat] + "'"

	cWhrSRC += " AND SRC.RC_PERIODO >= '" + initView + "'"
	cWhrSRD += " AND SRD.RD_PERIODO >= '" + initView + "'"

	cWhrSRC += " AND SRC.RC_PERIODO <= '" + endView + "'"
	cWhrSRD += " AND SRD.RD_PERIODO <= '" + endView + "'"
	cWhrSRD += " AND (SRD.RD_EMPRESA = '' OR SRD.RD_EMPRESA = '" + aTransAux[nCount,nPosEmp] + "')"

	cWhrSRC += ")"
	cWhrSRD += ")"

	cWhrSRC += " AND SRC.RC_ROTEIR IN ("
	cWhrSRC += " '" + fGetCalcRot('1',cMod,aTransAux[nCount][nPosFil]) + "', " // FOL
	cWhrSRC += " '" + fGetCalcRot('2',cMod,aTransAux[nCount][nPosFil]) + "', " // ADI
	cWhrSRC += " '" + fGetCalcRot('5',cMod,aTransAux[nCount][nPosFil]) + "', " // 131
	cWhrSRC += " '" + fGetCalcRot('6',cMod,aTransAux[nCount][nPosFil]) + "', " // 132
	cWhrSRC += " '" + fGetCalcRot('F',cMod,aTransAux[nCount][nPosFil]) + "', " // PLR
	cWhrSRC += " '" + fGetCalcRot('9',cMod,aTransAux[nCount][nPosFil]) + "'"   // AUT
	cWhrSRC += " )"
	
	cWhrSRD += " AND SRD.RD_ROTEIR IN ("
	cWhrSRD += " '" + fGetCalcRot('1',cMod,aTransAux[nCount][nPosFil]) + "', " // FOL
	cWhrSRD += " '" + fGetCalcRot('2',cMod,aTransAux[nCount][nPosFil]) + "', " // ADI
	cWhrSRD += " '" + fGetCalcRot('5',cMod,aTransAux[nCount][nPosFil]) + "', " // 131
	cWhrSRD += " '" + fGetCalcRot('6',cMod,aTransAux[nCount][nPosFil]) + "', " // 132
	cWhrSRD += " '" + fGetCalcRot('F',cMod,aTransAux[nCount][nPosFil]) + "', " // PLR
	cWhrSRD += " '" + fGetCalcRot('9',cMod,aTransAux[nCount][nPosFil]) + "'"   // AUT
	cWhrSRD += " )"
		
	cWhrSRC += " AND SRC.D_E_L_E_T_ = ' '"
	cWhrSRC += " %"
	
	cWhrSRD += " AND SRD.D_E_L_E_T_ = ' '"
	cWhrSRD += " %"

	BEGINSQL ALIAS cQuery
		COLUMN RC_DATA as Date
	
		SELECT DISTINCT
		RC_PERIODO,
		RC_SEMANA,
		0 AS ARCHIVED,
		RC_ROTEIR,
		RC_FILIAL AS FILIAL,
		RC_MAT AS MATRICULA,
		RC_VALOR,
		RC_DATA AS DATAPAGTO,
		RC_PROCES AS PROCESSO,
		RC_PD AS VERBA,
		RV_TIPOCOD,
		'' AS EMPRESA
		FROM
		%exp:cSRCEmp% SRC
		INNER JOIN %exp:cSRVEmp% SRV
		ON %exp:cJoinSRCFil% SRC.RC_PD = SRV.RV_COD AND SRV.%NotDel%
		WHERE
		%exp:cWhrSRC%
		UNION
		
		SELECT DISTINCT
		RD_PERIODO,
		RD_SEMANA,
		1 AS ARCHIVED,
		RD_ROTEIR,
		RD_FILIAL AS FILIAL,
		RD_MAT AS MATRICULA,
		RD_VALOR,
		RD_DATPGT AS DATAPAGTO,
		RD_PROCES AS PROCESSO,
		RD_PD AS VERBA,
		RV_TIPOCOD,
		RD_EMPRESA AS EMPRESA
		FROM
		%exp:cSRDEmp% SRD
		INNER JOIN %exp:cSRVEmp% SRV
		ON %exp:cJoinSRDFil% SRD.RD_PD = SRV.RV_COD AND SRV.%NotDel% 

		WHERE
		%exp:cWhrSRD%
		ORDER BY 1 desc, 2 desc, 4 
	ENDSQL

	lRet := (cQuery)->( !Eof() )

Return(lRet)

/*/{Protheus.doc} fChkRegsDup
- Checa e elimina registros em duplicidade que podem ser gerados quando o periodo está compreendido numa interseccao de transferencias

@author:	Marcelo Silveira
@since:		20/12/2021
@param:		aDataTransf - Array com os registros das verbas;
/*/
Function fChkRegsDup(aDataTransf)

Local nX		:= 0
Local cKey		:= ""
Local aKeys  	:= {}
Local aDataAux  := {}

//Elimina duplicidades a partir dos dados: roteiro + periodo + semana
For nX := 1 To Len(aDataTransf)

	cKey := aDataTransf[nX,5] + aDataTransf[nX,6] + aDataTransf[nX,7]
	
	If Ascan( aKeys,{|x| x[2] == cKey }) == 0
		aAdd( aKeys, {nX, cKey})
		aAdd( aDataAux, aDataTransf[nX])
	EndIf
Next nX

aDataTransf := aClone(aDataAux)

Return()



/*/{Protheus.doc} fSkipMultV
- Checa se deve pular o registro do informe de rendimentos, caso o funcionário possua MultV

@author:	Henrique Ferreira
@since:		31/03/2022
@param:		cFilSRA 	- Filial do Funcionário Logado;
		    cMatSRA 	- Matricula do Funcionário Logado;
			aMultV  	- Array com os vínculos;
			nAnoBase	- Ano base do informe de rendimentos;
/*/
Function fSkipMultV(cFilSRA, cMatSRA, aMultV, nAnoBase)

Local nPos  := NIL
Local lSkip := .F.

DEFAULT aMultV 		:= {}
DEFAULT cFilSRA 	:= ""
DEFAULT cMatSRA 	:= ""
DEFAULT nAnoBase 	:= 0

If Len(aMultV) > 0 .And. !Empty(cFilSRA) .And. !Empty(cMatSRA) .And. nAnoBase > 0

	//Se existir apenas matrículas ativas, então não skipa.
	If AScan(aMultV, {|x| x[9] $ "D/T" } ) == 0
		Return .F.
	EndIf
	//Verifica se no multV existe alguma matricula ativa.
	If ( nPos := AScan(aMultV, {|x| !(x[3]+x[1] == cFilSRA + cMatSRA) .And. !(x[9] $ "D/T") } ) ) > 0
		// Se, logado com o demitido, existir alguma matrícula ativa
		// Checa se a admissão da matricula ativa é igual ao ano calendário
		// Se for, então skipa a matricula demitida (Logada), pois o informe será exibido na matrícula ativa
		If Year(aMultV[nPos, 5]) == nAnoBase
			lSkip := .T.
		EndIf
	EndIf
EndIf

Return lSkip

/*/{Protheus.doc} fGetFileAnnualRec
Retorna o arquivo PDF do informe de rendimentos pelo Meu RH
@author:	Marcelo Silveira
@since:		04/05/2022
@param:		xCodFil 	- Filial do Funcionário Logado;
		    cCodMat 	- Matricula do Funcionário Logado;
		    cAnoBas 	- Ano base do informe de rendimentos;
			cArqLocal  	- Endereço do STARTPATH
			cFileName	- Nome do arquivo
			cExtFile	- Complemento do nome do arquivo
			xCodEmp		- Codigo da empresa 
			lJob 		- Indica que a execução será feita via job
			cUID 		- Id da thread quando executado via job		
/*/
Function fGetFileAnnualRec(xCodFil, cCodMat, cAnoBas, cArqLocal, cFileName, cExtFile, cCodRet, xCodEmp, lJob, cUID)

	Local oFile		:= Nil
	Local nCont		:= 0
	Local nX 		:= 0
	Local nSizeFil	:= 0
	Local nSizeMat	:= 0
	Local lContinua := .T.
	Local cFile 	:= ""
	Local cPDF		:= ".PDF"

	Default cCodRet := ""

	If lJob
		//Instancia o ambiente para a empresa onde a funcao sera executada
		RPCSetType( 3 )
		RPCSetEnv( xCodEmp, xCodFil )
	EndIf

	nSizeFil 	:= TamSX3("RA_FILIAL")[1]
	nSizeMat	:= TamSX3("RA_MAT")[1]
	xCodFil		:= SubStr(xCodFil,1,nSizeFil)
	cCodMat		:= SubStr(cCodMat,1,nSizeMat)

	//------------------------------------------------------------------------------
	//Existe um problema ainda nao solucionado que o APP envia mais de uma requisicao via mobile
	//Quando isso ocorre o sistema nao gera o arquivo e envia uma resposta sem conteudo. 
	//Solucao paliativa:
	//Caso alguma requisicao falhe tentaremos gerar o arquivo novamente por 3 vezes no maximo
	//Cada nova requisicao ira gerar o arquivo com um nome diferente (Filial + Matricula + IRPF + nX) 
	//------------------------------------------------------------------------------
	For nX := 1 To 3

		//Se existir o arquivo temporario nao executamos a GPEM580 porque indica uma requisicao em andamento
		If !File( cArqLocal + cFileName + cExtFile + '*' )
			GPEM580(.T., xCodFil, cCodMat, cAnoBas, .F., .T., cFileName + cExtFile + cValToChar(nX), cCodRet )
		EndIf
	
		//Avalia o arquivo gerado no servidor
		While lContinua

			//Verifica se o arquivo PDF ja foi gerado e retorna seu conteudo
			If File( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
				oFile := FwFileReader():New( cArqLocal + cFileName + cExtFile + cValToChar(nX) + cPDF )
				
				If (oFile:Open())
					cFile := oFile:FullRead()
					oFile:Close()
				EndIf

				FreeObj(oFile)
			EndIf

			//Em ambiente lento o sistema esta demorando para gerar o arquivo PDF
			//Como alternativa pesquisaremos o arquivo durante 5 segundos no maximo
			If ( lContinua := Empty(cFile) .And. nCont < 4 )
				nCont++
				Sleep(1000)
			EndIf
		End

		If !Empty(cFile)
			Exit
		Else
			lContinua := .T.
			conout( EncodeUTF8(">>>"+ STR0013 +"("+ cValToChar(nX) +")") ) //"Aguardando a geração do arquivo PDF..."
		EndIf
	
	Next Nx

	//Exclui os arquivos temporarios gerados durante o processamento (REL/PDF/PD_)
	fExcFileMRH( cArqLocal + cFileName + '*' )

	If lJob
		//Atualiza a variavel de controle que indica a finalizacao do JOB
		PutGlbValue(cUID, "1")
	EndIf		    
	
Return(cFile)
