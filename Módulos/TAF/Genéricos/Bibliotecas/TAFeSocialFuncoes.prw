#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFESOCIALFUNCOES.CH" 

#DEFINE CRLF Chr(13)+Chr(10)
 
Static __aTblsEsocial
Static __aTblsFiscal
Static __aTblsReinf
Static __aTblsECF
Static __aTblsAutoCont
Static __aFilsMatriz
Static __cCGC           := ""
Static __cFilOne        := ""
static __cGroup         := ""
Static __lTAFdbLegacy
Static __lTAFConOut
Static __lTAFinCloud
Static lTAFCodRub		:= FindFunction("TAFCodRub")
Static lCacheSimp		:= Nil
Static __aPicCache  	:= Nil 

//------------------------------------------------------------------- 
/*/{Protheus.doc} FeSocCallV
Realiza a chamada da View de um determinado evento
de acordo com os parâmetros.
@author evandro.oliveira
@since 25/02/2016 
@version 1.0
@param cEvento, character, (Código do Evento e-Social)
@param nRecNo, numérico, (RecNo do registro a ser exibido)
@param nOpc, numérico, (Opção do Cadastro 2-Visualizar,4-Alterar etc...)
@param nScan, numérico, (Indice para busca no TafRotinas)
@param cFilPos, caracter, (Indica se deve posicionar na filial antes de executar o Painel do trabalhador, visto que internamente essa rotina faz filtro por filial )
@return ${Nil}
//teste
/*/

//-------------------------------------------------------------------
Function FeSocCallV(cEvento,nRecNo,nOpc,nScan,cFilPos, nOwner)

	Local aEvento   := {}

	Private oBrowse, oPanelBrw, oTree
	Private nRecnoFunc
	Private lPainel, lFirstOpe, lExistAlt

	Default nScan   := 4
	Default cFilPos := ''
	Default nOwner  := 2

	//Se for enviada a filial eu troco antes de executar o painel do trabalhador
	If !empty( cFilPos )
		cFilposAnt := cFilAnt 
		cFilAnt := cFilPos
	EndIf

	If FPerAcess(/*cAliasTrb*/, cEvento, ""/*cMsg*/, 0/*nMark*/, ""/*cRotina*/, .T./*lJob*/, .F./*lMarkAll*/, cFilAnt/*cFilAccCFG*/)

		If cEvento == 'TAFAPNFUNC'

			DbSelectArea('C9V')
			C9V->(DbGoTo(nRecNo))     
			If !C9V->(Eof())
				FWExecView('' ,cEvento, nOpc,, {|| .T. } )
			Else
				Help(NIL, NIL, STR0051, NIL, STR0052, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0053})
			EndIf 

		Else

			aEvento := TAFRotinas(cEvento ,nScan,.F.,nOwner)
			DbSelectArea(aEvento[3])     
			(aEvento[3])->(DbGoTo(nRecNo))
			
			If !"C9V"$aEvento[3]
				FWExecView('' ,aEvento[1], nOpc,, {|| .T. } ) 
			Else
				AltCadTrab()
			EndIf	
			
		EndIf

	Else

		//"Acesso negado!"- "O usuário corrente não possui privilégios de acesso a rotina relacionada na filial do registro." - "Verifique as configurações DOS privilégios de acesso no configurador."
		Help(NIL, NIL, STR0054, NIL, STR0055, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0056})
		
	EndIf

	If !empty( cFilPos )
		cFilAnt := cFilposAnt
	EndIf 
	
Return Nil 
//-------------------------------------------------------------------
/*/{Protheus.doc}
Verifica se o Servidor WS está no Ar
@author evandro.oliveira
@since 06/04/2016
@version 1.0
@param cUrl, character, (Url do Servidor TSS)
@param cMsg, character, (Mensagem em caso de erro (referência))
@return ${lRet}, ${Indica de houve conexão}
/*/
//-------------------------------------------------------------------
Function TafWVerUrl(cUrl,cMsg)

	Local lRet      := .T.
	Local cCheckURL := ""

	Default cUrl    := TafGetUrlTSS()
	Default cMsg    := ""

	If Empty(AllTrim(cUrl))
		cMsg := "O parâmetro MV_TAFSURL não está preenchido"
		xTAFMsgJob(cMsg)
		lRet := .F. 
	EndIf

	If lRet

		If  !("TSSWSSOCIAL.APW" $ Upper(cUrl)) 
			cCheckURL := cUrl
			cUrl += "/TSSWSSOCIAL.apw"
		Else
			cCheckURL := Substr(cUrl,1,Rat("/",cUrl)-1)
		EndIf

		If !TAFCTSpd(cCheckURL)
			cMsg := "Erro na conexão com o TSS. Verificar se o serviço está iniciado e se o parâmetro MV_TAFSURL está correto" 
			lRet := .F.
		EndIf 

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XVldAfastAf
Funcao utilizada para efetuar a validação de um funcionário,
verificando de já assiste um afastamento para o mesmo.

@return lRet - Retorno da validação efetuada.

@author Vitor Siqueira / Denis R. de Oliveira
@since 25/11/2015	/ 09/11/2017

@version 1.0
   
/*/
//-------------------------------------------------------------------
Function xVldAfastAf( cFunc, dDataDig, nTipo )
	
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local cIdTran    := ""
	Local dDtVincIni := STOD("")

	Default cFunc    := ""

	C9V->( dBSetOrder(2) )
	If C9V->( MSSeek(xFilial("C9V") + cFunc + "1" ) )

		If C9V->C9V_STATUS == "4" 

			cIdTran := C9V->C9V_IDTRAN

			CUP->( dbSetOrder( 1 ) )

			If CUP->( MsSeek( xFilial( "CUP" ) + C9V->C9V_ID + C9V->C9V_VERSAO ) )
						
				//------------------------------------------------------------
				//Verifico se a data de afastamento do S-2200 esta preenchida
				//------------------------------------------------------------
				If !Empty( CUP->CUP_DTINIA ) .AND. Empty( cIdTran )
					dDtVincIni := CUP->CUP_DTINIA
				EndIf
							
			ElseIf ALLTRIM(C9V->C9V_NOMEVE) == "S2300" //TSV

				CUU->( dbSetOrder( 1 ) )
				If CUU->( MsSeek( xFilial( "CUU" ) + C9V->C9V_ID ) )
					If !Empty( CUU->CUU_DTINIA )
						dDtVincIni := CUU->CUU_DTINIA
					EndIf
				EndIf

			EndIf

			lRet := TAFAfasCM6( cFunc, dDataDig, dDtVincIni, nTipo )
		
		EndIf

	EndIf

	RestArea( aArea )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xTafAlt
Cria uma interface para a alteração do evento de acordo com o tipo de
operação 

@Param  cAlias	- Alias do Browse
		 nReg 	- Registro posicionado no Browse
		 nOpc	- Operação de Manutenção 

@Return Nil 

@Author Paulo V.B. Santana
@Since 27/01/2016
@Version 1.0
/*/
//------------------------------------------------------------------
Function xTafAlt(cAlias, nReg, nOpc)

	Local cTitulo     := "ALTERAR"
	Local cNmFun      := Iif(FindFunction("TafSeekRot"), TafSeekRot(cAlias), FunName())
	Local aTafRot     := {}
	Local cOper       := ""
	Local lVldOp      := .T.
	Local cEvento     := ""

	Private cOperEvnt := cValtoChar(nOpc)

	Default nOpc      := 0

	aTafRot           := TAFRotinas(cNmFun,1,.F.,2)
	cAlias            := aTafRot[3]
	cEvento           := aTafRot[4]

	// --> Só executa as validações de status, se o registro controlar esse tipo de status
	If TafColumnPos( (cAlias + "_STATUS" ) )

		If (cAlias)->&( cAlias + "_STATUS" ) ==  "2" 
			lVldOp := .F.
			msgAlert(xValStrEr("000727"))
		ElseIf (cAlias)->&( cAlias + "_STATUS" ) == "6"
			lVldOp := .F.
			msgAlert(xValStrEr("000728"))
		ElseIf (cAlias)->&( cAlias + "_STATUS" ) == "7"	
			lVldOp := .F.					
			msgAlert(xValStrEr("000772"))
		ElseIf (cAlias)->&( cAlias + "_STATUS" ) == "4"	 .And. (cAlias)->&( cAlias + "_EVENTO" ) == "E"	.And. (cAlias)->&( cAlias + "_ATIVO" ) == "2"	
			lVldOp := .F.					
			msgAlert(xValStrEr("001117"))		
		EndIf

		If lVldOp

			If nOpc == 1 .AND.(cAlias)->&( cAlias + "_STATUS" ) == '4' .And. !(cEvento == 'S-2231')
				
				If IsBlind()
					cOper := 1
				Else
					cOper := Aviso( STR0001,STR0005, { "OK", "Cancelar" },3 )   // "Esta operação permite retificar o último evento transmitido, referente a este trabalhador. Para retificar outro evento é necessário excluir as informações enviadas após a transmissão do evento à ser retificado.")
				EndIf

				If cOper <> 1
					lVldOp  := .F.
				Else
					cTitulo := STR0001 // "Retifição do Evento"
				EndIf

			ElseIf nOpc == 2 

				If (cAlias)->&( cAlias + "_EVENTO" ) <> "A" .And. Empty( (cAlias)->&( cAlias + "_STATUS" ) ) 
					msgAlert(STR0006) //"Não é possível cadastrar um evento de 'Alteração', enquanto houver outro evento pendente de transmissão."
					lVldOp := .F.
				ElseIf (cAlias)->&( cAlias + "_EVENTO" ) == "F"
					msgAlert(Iif(cAlias == "CM8",STR0010,STR0007))//"Não é possível cadastrar um evento de 'Alteração', enquanto houver um evento de 'Finalização' ativo."
					lVldOp := .F.
				Else
					cTitulo := STR0002 // "Alteração do Evento "
				EndIf

			ElseIf nOpc == 3
				
				If cAlias == "CM6"
					If TafColumnPos(cAlias + "_XMLREC")
						If (cAlias)->&( cAlias + "_XMLREC" ) == "COMP"
							Help( ,, STR0027,, STR0050, 1, 0 )//"Não é possível realizar um Término de Afastamento para um registro completo."
							lVldOp := .F.
						ElseIf (cAlias)->&(cAlias + "_XMLREC") == "TERM"
							Help(,, STR0027,, STR0066, 1, 0,,,,,, {STR0067}) // "Atenção" // "Este afastamento temporário já possui uma data de término informada." // "Para informar uma nova data de término para este afastamento temporário, faça uma retificação."
							
							lVldOp := .F.
						EndIf
					EndIf
				EndIF
			
				If !cAlias == "CM6"
					If (cAlias)->&( cAlias + "_EVENTO" ) <> "F" .AND. Empty( (cAlias)->&( cAlias + "_STATUS" ) )
						msgAlert(Iif(cAlias == "CM8",STR0009,STR0008))//"Não é possível cadastrar um evento de 'Finalização', enquanto houver outro evento pendente de transmissão."
						lVldOp := .F.
					Else
						cTitulo := IIF(cNmFun == "TAFA263",STR0003,STR0004) //"Cancelamento do Aviso Prévio" # "Finalização do Evento"
					Endif
				EndIf

			EndIf

		EndIf

	EndIf 

	If lVldOp
		If !IsBlind()
			FWExecView(cTitulo,cNmFun,4)
		EndIf
	Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafCloseTb
Cria uma interface para a alteração do evento de acordo com o tipo de
operação 

@Param  cOrigem - Identifica a origem da chamada (I=integracao,C=Cadastro(tela))
		 oModel - Model do regitro Pai
		 cAlias - Alias do registro Pai
		 idModelo - Id do ModelocDt
		cDtOldFim - Data Fim do registro Anterior (somente eventos de tabelas)
		cDtNewReg - Valor do campo Data Inicial do registro Novo depois do input no campo (somente eventos de tabelas)
		cDtOldReg - Valor do campo Data Inicial do registro Novo antes do input no campo (somente eventos de tabelas)
		cDtFinR - Data para gravação do registro anterior (somente quando cOrigem for igual a I), passar por referência
@Return Nil 

@Author Evandro dos Santos Oliveira
@Since 13/05/2016
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafCloseTb(cOrigem,oModel,cAlias,idModelo,cDtOldFim,cDtNewReg,cDtOldReg,cDtFinR)

	Local cMes        := ""
	Local cAno        := ""
	Local cDtIni      := ""
	Local cDtIniAnt   := ""
	
	Default oModel    := Nil
	Default cDtOldFim := ""
	Default cDtNewReg := ""
	Default cDtOldReg := ""
	Default cDtFinR   := ""
	
	If Empty(cDtOldFim)

		If cOrigem = 'I'
			cDtOldReg := StrZero(Month(cDtOldReg),2)+StrZero(Year(cDtOldReg),4)
		EndIf

		cDtIniAnt := Substr(cDtOldReg,3,4) + Substr(cDtOldReg,1,2)

		If Len(cDtNewReg) > 5 
			cDtIni := Substr(cDtNewReg,3,4) + Substr(cDtNewReg,1,2)
		EndIf

		If cDtIni == cDtIniAnt

			If cOrigem = 'I'
				cDtFinR := cDtNewReg	
			Else
				oModel:LoadValue(idModelo,cAlias+"_DTFIN",cDtNewReg)
			EndIf

		ElseIf cDtIni > cDtIniAnt

			cMes := Substr(cDtNewReg,1,2)
			cAno := Substr(cDtNewReg,3,4)
			cMes := StrZero((Val(cMes)-1),2)

			//Quando mês for 00 será igual a 12 e diminui um ano
			If(cMes == '00')
				cMes := '12'
				cAno := StrZero((Val(cAno)-1),4)
			EndIf 

			If cOrigem = 'I'
				cDtFinR := cMes+cAno
			Else
				oModel:LoadValue(idModelo,cAlias+"_DTFIN",cMes+cAno)
			EndIf

		EndIf

	EndIf

Return Nil	
//-------------------------------------------------------------------
/*/{Protheus.doc} TafCacheModel
Grava e Retorna dados do Modelo de acordo com os parâmetros
@type function
@author Evandro
@since 17/06/2016
@version 1.0
@param lForm, ${boolean}, (Define se o modelo é um formulário(.T.), no caso de ser uma grid utilizar .F.)
@param oModel, objeto, (Model do Fonte)
@param cModelTab, character, (Id do Modelo)
@param cAliasTab, character, (Alias do (Pai) do Modelo)
@param cExclCmp, character, (campos a serem desconsiderados(separar por pipe))
@return ${aCampos}, ${Campos com seus respectivos valores}
/*/
//-------------------------------------------------------------------
Function TafCacheModel(lForm,oModel,cModelTab,cAliasTab,cExclCmp)

	Local oModelTab  := Nil
	Local aCampos    := {}
	Local aAuxCmps   := {}
	Local cCmpsExcl  := ""
	Local nX,nY      := 0
	Default cExclCmp := ""
	Default lForm    := .F.

	cCmpsExcl := cAliasTab + "_FILIAL|"
	//cCmpsExcl += cAliasTab + "_ID|" //O campo Id foi retirado da lista pois estava gerando novo Id para novas versões do mesmo registro
	cCmpsExcl += cAliasTab + "_VERSAO|"
	cCmpsExcl += cAliasTab + "_VERANT|"
	cCmpsExcl += cAliasTab + "_PROTUL|"
	cCmpsExcl += cAliasTab + "_PROTPN|"
	cCmpsExcl += cAliasTab + "_ATIVO|"
	cCmpsExcl += cAliasTab + "_EVENTO|"
	cCmpsExcl += cExclCmp

	oModelTab := oModel:GetModel(cModelTab)
	If lForm

		//aEval(oModelTab:aDataModel[1][1],{|x|aAdd(aAuxCmps,{x[1],x[2]})}) 
		For nX := 1 To Len(oModelTab:aDataModel[1])
			If !(oModelTab:aDataModel[1][nX][1] $ cCmpsExcl)
				aAdd(aAuxCmps,{oModelTab:aDataModel[1][nX][1],oModelTab:aDataModel[1][nX][2]})
			EndIf
		Next nX

		aAdd(aCampos,aAuxCmps)

	Else

		For nX := 1 To Len(oModelTab:aCols) 

			For nY := 1 To (Len(oModelTab:aCols[1])-1)

				If !(oModelTab:aHeader[nY][2] $ cCmpsExcl)
					aAdd(aAuxCmps,{oModelTab:aHeader[nY][2],oModelTab:aCols[nX][nY]})
				EndIf

			Next nY

			aAdd(aCampos,aAuxCmps)
			aAuxCmps := {}

		Next nX

	EndIf

Return aCampos
//-------------------------------------------------------------------

/*/{Protheus.doc} TafSetModel
Atribui os valores do array aGrava no modelo passado pelo oModel e cIdModel.
@author Evandro
@since 20/06/2016
@version 1.0
@param lForm, ${boolean}, (Define se o modelo é um formulário(.T.), no caso de ser uma grid utilizar .F.)
@param oModel, objeto, (Model do Fonte)
@param cIdModel, character, (Id Do Model)
@param lDelRegs, boolean,(Indica se deve apagar os registros do Model antes da Inclusão)
@param aGrava, array, (Dados do Modelo)
@return ${boolean},, ${Informa que o processamento foi executado com sucesso}
/*/
//-------------------------------------------------------------------
Function TafSetModel(lForm,oModel,cIdModel,lDelRegs,aGrava)
	
	Local nJ,nI   := 0
	Local lReturn := .F.
	Default lForm := .F.

	If lDelRegs

		For nJ := 1 to oModel:GetModel(cIdModel):Length()
			oModel:GetModel(cIdModel):GoLine(nJ)
			oModel:GetModel(cIdModel):DeleteLine()
		Next nJ

	EndIf
	
	For nI := 1 To Len(aGrava)
	
		If !lForm
			oModel:GetModel(cIdModel):lValid:= .T.
			oModel:GetModel(cIdModel):AddLine()
		EndIf

		For nJ := 1 To Len(aGrava[nI])
			oModel:LoadValue(cIdModel,aGrava[nI][nJ][1],aGrava[nI][nJ][2])
		Next nJ

	Next nI
	
	//Verifico se o laço foi executado até o fim
	lReturn := nI > Len(aGrava)

Return lReturn
//-------------------------------------------------------------------
/*/{Protheus.doc} TafGetAGrv
Retorna valor do campo contido no Array aGrava
@author Evandro
@since 20/06/2016
@version 1.0
@param aGrava, array, (Array Multidimensional com os dados do modelo sendo a primeira posicão o campo e a segunda o valor)
@param	cCampo, string, (Campo para busca no Array)
@return ${several types}, ${O Array de campos contem varios tipos de dados, por isso não é possivel especificar o retorno}
/*/
//-------------------------------------------------------------------
Function TafGetAGrv(aGrava,cCampo)

	Local nPos    := 0
	Local xReturn := Nil
	
	nPos := aScan(aGrava,{|x|x[1] == cCampo})

	If nPos > 0
		xReturn := aGrava[nPos][2]
	EndIf
	
Return xReturn 
//-------------------------------------------------------------------
/*/{Protheus.doc} TafFormCommit

Executa o commit do processamento através do FWFormCommit e deve capturar possível 
erro de chave duplicada na integração.

@param	oModel - Model que sera realizado o commit

@author Vitor Siqueira 

@since 20/01/2017

@version 1.0

/*/
//-------------------------------------------------------------------
Function TafFormCommit( oModel, lTypeRet )

	Local lErroInt   := .F.
	Local cDescError := ""
	Local cRetError  := ""
	Local oError     := ErrorBlock( {|oError| TafTratFWForm( oError, @lErroInt, @cDescError )} )

	Default lTypeRet := .F.

	Begin Sequence
		FWFormCommit( oModel )
	End Sequence

	If lErroInt
		If !Empty( cDescError )
			cRetError := GetAlsDup(cDescError)
		EndIf
		DisarmTransaction()
	EndIf

	oError := Nil

//Tratamento paleativo. Para que, não haja a necessidade de se alterar todos os fontes de uma só vez :(
If lTypeRet
	Return( { lErroInt, cRetError, cDescError } )
Else
	Return lErroInt
EndIf

//-------------------------------------------------------------------
/*/{Protheus.doc} TafTratFWForm

Efetua tratamento de error log da chave duplicada

@param	oError - Objeto carrega erro

@author Vitor Siqueira 

@since 20/01/2017

@version 1.0

/*/
//-------------------------------------------------------------------
Function TafTratFWForm( oError, lErroInt, cDescError )

	Local cErr  := oError:Description
	Local cErro := ""

	cDescError  := cErr
	lErroInt    := .T.
	cErro       := cErr + chr(10) + chr(13)
	TAFConOut(cErro)

Return( NIL )

//----------------------------------------------------------------------------
/*/{Protheus.doc} getTafDStatus 
Retorna a descrição do Status do registro no TAF.

@param cStatus 	- Código do Status

@return cDescr		- Descrição do Status

@author Evandro dos Santos O. Teixeira
@since 02/01/2017
@version 1.0

/*/
//--------------------------------------------------------------------------- 
Function getTafDStatus(cStatus)

	Local cDescr := ""

	If Empty(AllTrim(cStatus))
		cDescr := STR0011 //"Registro Integrado"
	ElseIf AllTrim(cStatus) == "0"
		cDescr := STR0012 //"Registro Valido."
	ElseIf AllTrim(cStatus) == "1"
		cDescr := STR0013 //"Registro Invalido."
	ElseIf AllTrim(cStatus) == "2"
		cDescr := STR0014 //"Registro Transmitido."
	ElseIf AllTrim(cStatus) == "3"
		cDescr := STR0015 //"Registro Transmitido com inconsistência(s)."
	ElseIf AllTrim(cStatus) == "4"
		cDescr := STR0016 //"Registro Transmitido Válido."
	ElseIf AllTrim(cStatus) == "6"
		cDescr := STR0017 //"Registro Com Solicitação de Exclusão."
	ElseIf AllTrim(cStatus) == "7"
		cDescr := STR0018 //"Registro Com Solicitação de Exclusão e Transmitido."
	EndIf
	
Return (cDescr) 
//-------------------------------------------------------------------
/*/{Protheus.doc} xTafTagGroup
Verifica se existe foi criada pelo menos 1 tag Filha para a criação da
tag Pai. 
*Utilizado quando um registro tem ocorrência 0-1

@param cTagPai    	- Nome da Tag Pai
@param aTagFilhas	- array com as informações da Tag Filha
					  [n][1] - Nome da Tag Filha
					  [n][2] - Valor da Tag
					  [n][3] - Picture
					  [n][4] - Informa se a tag deve ser gerada somente
					  quando preenchida (ocorrência 0-1)
					  .T. - gera somente quando preenchida
					  .F. - gera independente se estiver preenchiada ou não
					  [n][5] - Indica se deve ser formatado os campos númerico conforme o Esocial
					  .T. - Troca virgula por ponto na casa de decimais
					  .F. - Mantem padrão do protheus.	  
					  [n][6] - Força a geração de tags numéricas com valor 0 (zero) 
					  .T. - gera tag numerica zerada
					  .F. - considera nulo o valor de tag numerica zerada
					  
@param cXml    	- String de geração do XML - (Passar como referência)
@param aGrpFilhos	- Array com Strings de grupos filhos
					  [n][1] - Nome da Tag Filha
					  [n][2] - Trecho do XML da tag Filha
					  Obs: Enviar String passada por parâmetro dentro desta
					  mesma função quando o Grupo Filho foi gerado. Obrigatoriamente
					  os grupos filhos devem ser gerados antes do Pai para possibilitar
					  a verificação de existência dos mesmos.
					  [n][3] - Ocorrência do Grupo (numérico)

@param lGrpObrigat	- Flag que indica se o grupo de tags eh obrigatorio e deverá ser
					  gerado independente se uma das tags tiver conteúdo.

@lGrpComp			- Usado para idendificar se o grupo filho não obrigatório deve ser criado 
					  caso tenha informações nele.		  
					  
@return cRet - Retorno com a categoria encontrada.

@author Evandro dos Santos O. Teixeira
@since 27/04/2017
@version 1.0
@exemple 

xTafTagGroup("procAdmJudRat"	,{{"tpProc"		,cTpProc					,,.F.};
									, {"nrProc"		,nProcesso					,,.F.};
									, {"codSusp"	,Alltrim(C92->C92_CODSUF)	,,.T.}};
									, @cXmlProcRat)	
			  
xTafTagGroup("procAdmJudFap"	,{{"tpProc"		,cTpProc			,,.F.};
									, {"nrProc"		,nProcesso			,,.F.};
									, {"codSusp"	,C1E->C1E_VLRSUB	,,.T.}};
									, @cXmlProcFat)
														
xTafTagGroup("aliqGirat"			,{{"aliqRat"		,C92->C92_ALQRAT	,								,.F.}};
									, {"fap"			,C92->C92_FAP		,PesqPict("C92","C92_FAP")		,.T.};
									, {"aliqRatAjust"	,C92->C92_AJURAT	,PesqPict("C92","C92_AJURAT")	,.T.};
									, @cXml,{{"procAdmJudRat",cXmlProcRat,0},{"procAdmJudFap",cXmlProcFat,0}})	
   
/*/
//-------------------------------------------------------------------
Function xTafTagGroup( cTagPai , aTagFilhas , cXml , aGrpFilhos , lGrpObrigat, lGrpComp )

	Local nX            := 0
	Local cAuxXml       := ""
	Local lExistVal     := .F.
	Local lExistGrp     := .F.

	Default cTagPai     := ""
	Default cXml        := ""
	Default aTagFilhas  := {}
	Default aGrpFilhos  := {}
	Default lGrpObrigat := .F.
	Default lGrpComp    := .F.
	
	For nX := 1 To Len(aTagFilhas)

		If !Empty(aTagFilhas[nX][2])
			lExistVal := .T.
			Exit
		EndIf

	Next nX

	For nX := 1 To Len(aGrpFilhos)

		If !Empty(aGrpFilhos[nX][2])
			lExistGrp := .T.
			Exit
		EndIf

	Next nX
	
	If lExistVal .or. lGrpObrigat .or. (lGrpComp .and. lExistGrp)

		For nX := 1 To Len(aTagFilhas)

			cAuxXml += xTafTag(	 aTagFilhas[nX][1];
									,aTagFilhas[nX][2];
									,IIf(Len(aTagFilhas[nX]) > 2,aTagFilhas[nX][3],Nil);
									,IIf(Len(aTagFilhas[nX]) > 3,aTagFilhas[nX][4],Nil);
									,IIf(Len(aTagFilhas[nX]) > 4,aTagFilhas[nX][5],Nil);
									,IIf(Len(aTagFilhas[nX]) > 5,aTagFilhas[nX][6],Nil))
		Next nX
		
		cXml += "<"+cTagPai+">"
		cXml += cAuxXml

		If lExistGrp

			For nX := 1 To Len(aGrpFilhos)

				If Empty(aGrpFilhos[nX][2])
					cXml += IIf(aGrpFilhos[nX][3] == 1,"<"+aGrpFilhos[nX][1]+"></"+aGrpFilhos[nX][1]+">","") //Se o Grupo for obrigatorio eu gero a tag em branco
				Else
					cXml += aGrpFilhos[nX][2]
				EndIf

			Next nX

		EndIf

		cXml += "</"+cTagPai+">"

	EndIf
	
	aSize(aTagFilhas,0)
	aSize(aGrpFilhos,0)
	
Return (cXml)

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFGetDTpEvento 
Retorna a descrição do Tipode Evento do registro no TAF.

Return (cXml)
@return cDescr		- Descrição do Tipo de Evento

@author Luccas Curcio
@since 25/05/2017
@version 1.0

/*/
//--------------------------------------------------------------------------- 
Function TAFGetDTpEvento( cTpEvento )

	local cDescr := ""

	If empty( allTrim( cTpEvento ) )
		cDescr := STR0019 //'Desconhecido'
	ElseIf allTrim( cTpEvento ) == "I"
		cDescr := STR0020 //'Inclusão'
	ElseIf allTrim( cTpEvento ) == "A"
		cDescr := STR0021 //'Alteração'
	ElseIf allTrim( cTpEvento ) == "E"
		cDescr := STR0022 //'Exclusão'
	ElseIf allTrim( cTpEvento ) == "R"
		cDescr := STR0023 //'Retificação'
	ElseIf allTrim( cTpEvento ) == "F"
		cDescr := STR0024 //'Finalização'
	ElseIf allTrim( cTpEvento ) == "C"
		cDescr := STR0025 //'Cancelamento'
	EndIf
	
Return ( cDescr )

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFGetLastRcn 
Retorna último recno de chave enviada como parâmetro

@return nMaxRec		- Ultimo recno desejado

@author Luccas Curcio
@since 25/05/2017
@version 1.0

/*/
//--------------------------------------------------------------------------- 
Function TAFGetLastRcn( cTicket , cKey , lValido , nStartRecNo )

	Local cQry       := ""
	Local cWhere     := ""
	Local cTafTicket := ""
	Local cTafKey    := ""
	Local cJoin      := ""
	Local nMaxRec    := 0

	Default cTicket  := ""
	Default cKey     := ""

	cTafTicket	:= AllTrim(cTicket)
	cTafKey 	:= AllTrim(cKey)

	If !Empty(cTafTicket) .And.  !Empty(cTafKey)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
		cWhere += " AND ST2.TAFKEY = '" + cTafKey + "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	ElseIf !Empty(cTafTicket)

		cWhere := " ST2.TAFTICKET =  '" + cTafTicket +  "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	Else 

		cWhere := " ST2.TAFKEY = '" + cTafKey + "'"
		cWhere += " AND ST2.D_E_L_E_T_ <> '*'"

	EndIf

	If lValido
		cWhere += " AND ST2.TAFSTATUS = '3' AND XERP.TAFSTATUS = '1' "
	EndIf

	cWhere += " AND ST2.R_E_C_N_O_ >= " + AllTrim(Str(nStartRecNo))

	cJoin := " LEFT JOIN TAFXERP XERP ON  ST2.TAFKEY = XERP.TAFKEY "
	cJoin += " AND ST2.TAFTICKET = XERP.TAFTICKET "
	cJoin += " AND XERP.D_E_L_E_T_ <> '*' "

	cQry := " SELECT MAX(ST2.R_E_C_N_O_) RECNO"
	cQry += " FROM TAFST2 ST2 "
	cQry += cJoin
	cQry += " WHERE "
	cQry += cWhere

	cQry := ChangeQuery(cQry)
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) ,"MAXST2")

	nMaxRec := MAXST2->RECNO

	MAXST2->(dbCloseArea())

Return ( nMaxRec )

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFxSelMod 
Função que retorna o modelo de montagem de uma mensagem para retorno do WS

@return cMod		- Modelo de montagem da mensagem

@author Luccas Curcio
@since 25/05/2017
@version 1.0

/*/
//--------------------------------------------------------------------------- 
Function TAFxSelMod( cTicket , cKey )

	Local cMod := ""
	
	Default cTicket 	:= ""
	Default cKey 		:= ""

	If !Empty(AllTrim(cTicket)) .And. !Empty(AllTrim(cKey)) 
		cMod := 'both'
	ElseIf !Empty(AllTrim(cTicket)) .And. Empty(AllTrim(cKey))
		cMod := 'ticket'
	Else
		cMod := 'key'
	EndIf
	
return cMod

//----------------------------------------------------------------------------
/*/{Protheus.doc} TAFSeek 
Seek performático para funcionalidades do TAF

@author Luccas Curcio
@since 25/05/2017
@version 1.0

/*/
//--------------------------------------------------------------------------- 
Function TAFSeek( cAliasTXERP , cAliasTaf , nRecno )

	//Evito ficar abrindo a área desnecessariamente
	If cAliasTaf != cAliasTXERP
		cAliasTaf := cAliasTXERP
		dbSelectArea(cAliasTaf)
		dbSetOrder(1)
	EndIf

	(cAliasTaf)->(dbGoTo(nRecno))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldCPFDep
Verifica se já existe um CPF de Dependente na base.

@Param  cVlrOri  -> Valor do campo
@Param  nTpTrc   -> Tipo de Troca

@Return .T.

@Author Daniel Otero Schmidt
@Since 30/06/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function xVldCPFDep(cAlias, cCPFDep, cEvento, cCnpjOp, cPerApu )

	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local cRet      := .F.
	Local cAlias2   := cAlias + "2"

	Default cEvento := ""
	Default cCPFDep := ""
	Default cCnpjOp := ""
	Default cPerApu := ""
		
	If cEvento $ "2299|1202|1200|2399"

		If !Empty( cCPFDep )

			cQuery := "SELECT " 
			cQuery += "COUNT(" + cAlias + "." + cAlias + "_CPFDEP) CONT" 
			cQuery += "FROM "
			cQuery += RetSqlName( cAlias ) + " " + cAlias 

			If cEvento $ "1200" 

				cQuery += " INNER JOIN " + RetSqlName("C91") + " C91 "
				cQuery += "   ON C91.C91_FILIAL = T6Z.T6Z_FILIAL "
				cQuery += "  AND C91.C91_ID = T6Z.T6Z_ID "
				cQuery += "  AND C91.C91_VERSAO = T6Z.T6Z_VERSAO "
				cQuery += "  AND C91.D_E_L_E_T_ = ' ' "

			EndIf

			cQuery += "WHERE " 
			cQuery += cAlias + "." + cAlias	+ "_FILIAL='" + xFilial( cAlias )	+ "' AND "
			cQuery += cAlias + "." + cAlias	+ "_CPFDEP='" + cCPFDep				+ "' AND "
			cQuery += cAlias + "." + cAlias	+ "_CNPJOP='" + cCnpjOp				+ "' AND "

			If cEvento $ "1200"

				cQuery += "C91.C91_PERAPU = '" + cPerApu + "' AND " 
			
			EndIF
			
			If cEvento == "2399"

				cQuery += cAlias + "." + cAlias + "_VERSAO IN "
				cQuery += "(SELECT MAX(" + cAlias2 + "." + cAlias + "_VERSAO) VERSAO FROM "
				cQuery += RetSqlName( cAlias ) + " " + cAlias2 
				cQuery += " WHERE " + cAlias2 + "." + cAlias + "_FILIAL = " + cAlias +"." + cAlias + "_FILIAL AND " 
				cQuery += cAlias2 + "." + cAlias + "_ID =" + cAlias + "." + cAlias + "_ID AND " + cAlias2 + ".D_E_L_E_T_=' ' ) AND "

			EndIf 

			cQuery += cAlias + "." + "D_E_L_E_T_=' ' "
			cQuery := ChangeQuery( cQuery )
		
			dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasQry ) 
					
			If (cAliasQry)->CONT > 1		
				cRet := .T.
			EndIf		

		EndIf

	EndIf	
	
Return(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TafNormTelES
Realiza a Normalização do DDD e Telefone de uma String retornando
somente numeros.

@Param  cTelFull  -> String com o Telefone Completo

@Return aTel -> [1]DDD,[2]Telefone

@Author Evandro dos Santos Oliveira
@Since 06/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafNormTelES(cTelFull)

	Local cDDD    := ""
	Local cDDI    := ""
	Local cTel    := ""
	Local nTamDDD := 0
	Local nTamDDI := 0
	Local aTel    := Array(2)

	cTelFull := AllTrim(cTelFull)
	cTelFull := StrTran(cTelFull," ","")
	cTelFull := StrTran(cTelFull,"-","")
	cTelFull := StrTran(cTelFull,"(","")
	cTelFull := StrTran(cTelFull,")","")

	If Substr(cTelFull,1,1) == "0"
		nTamDDD := 3
	ElseIf Len(cTelFull) == 13
		nTamDDI := 2
		nTamDDD := 2
	Else
		nTamDDD := 2
	EndIf

	If Len(cTelFull) == 13 .And. TafColumnPos("C9V_DDIFPR")
		aTel := Array(3)
		cDDI := Substr(cTelFull,1,nTamDDI)	
		cDDD := Substr(cTelFull,3,nTamDDD)
		cTel := Substr(cTelFull,nTamDDI+nTamDDD+1)
	Else
		cDDD := Substr(cTelFull,1,nTamDDD)
		cTel := Substr(cTelFull,nTamDDD+1)
	EndIf

	aTel[1] := cDDD
	aTel[2] := cTel

	If Len(cTelFull) == 13 .And. TafColumnPos("C9V_DDIFPR")
		aTel[3] := cDDI
	EndIf

Return(aTel)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGetDtTab


@param cDataIni -> Data Inicial
@param cDataFim -> Data Final


@Return cXml -> Retorno do Xml

@Author Evandro dos Santos Oliveira
@Since 20/10/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafGetDtTab(cDataIni,cDataFim)

	Local cXml := ""

	If !Empty(cDataIni)
		cDataIni := Substr(cDataIni,3,4) +"-"+ Substr(cDataIni,1,2)
	EndIf

	If !Empty(cDataFim)
		cDataFim := Substr(cDataFim,3,4) +"-"+ Substr(cDataFim,1,2)
	EndIf

	cXml +=	xTafTag("iniValid",cDataIni)
	cXml +=	xTafTag("fimValid",cDataFim,,.T.)

Return (cXml)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFTabVig

Verifica se o registro referente ao evento de tabela do eSocial
está vigente no período de referência indicado.

@Param	cAlias		-	Alias referente a tabela do evento
		cID			-	ID do registro para verificação de vigência
		cPeriodo	-	Período de referência da pesquisa ( AAAAMM )
		lPosiciona	-	Indica se deve posicionar no registro pesquisado
						Obs: Para utilizar este parâmetro, deve-se realizar
						DBSelectArea e DBSetOrder previamente

@Return	lRet		-	Indica se o registro está vigente

@Author		Felipe C. Seolin
@Since		03/11/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Function TAFTabVig( cAlias, cID, cPeriodo, lPosiciona )

	Local cAliasQry    := GetNextAlias()
	Local cSelect      := ""
	Local cFrom        := ""
	Local cWhere       := ""
	Local cPrefixo     := cAlias + "." + cAlias
	Local lRet         := .F.

	Default lPosiciona := .F.

	cPeriodo := SubStr( cPeriodo, 5, 2 ) + SubStr( cPeriodo, 1, 4 )

	cSelect	:= " " + cAlias + ".R_E_C_N_O_ RECNO "
	cFrom	:= RetSqlName( cAlias ) + " " + cAlias + " "
	cWhere	:= " " + cPrefixo + "_FILIAL = '" + xFilial( cAlias ) + "' "
	cWhere	+= "AND " + cPrefixo + "_ID = '" + cID + "' "
	cWhere	+= "AND ( SUBSTRING( " + cPrefixo + "_DTINI, 3, 4 ) < '" + SubStr( cPeriodo, 3 , 4 ) + "' OR ( SUBSTRING( " + cPrefixo + "_DTINI, 3, 4 ) = '" + SubStr( cPeriodo, 3 , 4 ) + "' AND SUBSTRING( " + cPrefixo + "_DTINI, 1, 2 ) <= '" + SubStr( cPeriodo, 1 , 2 ) + "' ) ) 
	cWhere	+= "AND ( ( SUBSTRING( " + cPrefixo + "_DTFIN, 3, 4 ) > '" + SubStr( cPeriodo, 3 , 4 ) + "' OR ( SUBSTRING( " + cPrefixo + "_DTFIN, 3, 4 ) = '" + SubStr( cPeriodo, 3 , 4 ) + "' AND SUBSTRING( " + cPrefixo + "_DTFIN, 1, 2 ) > '" + SubStr( cPeriodo, 1 , 2 ) + "' ) ) OR " + cPrefixo + "_DTFIN = '' ) 
	cWhere	+= "AND " + cPrefixo + "_ATIVO = '1' "
	cWhere	+= "AND " + cAlias + ".D_E_L_E_T_ = '' "

	cSelect	:= "%" + cSelect + "%"
	cFrom	:= "%" + cFrom   + "%"
	cWhere	:= "%" + cWhere  + "%"

	BeginSql Alias cAliasQry

		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		WHERE
			%Exp:cWhere%

	EndSql

	If ( cAliasQry )->( !Eof() )

		lRet := .T.

		If lPosiciona
			( cAlias )->( DBGoTo( ( cAliasQry )->RECNO ) )
		EndIf

	EndIf

	( cAliasQry )->( DBCloseArea() )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafClearModel
Limpa modelo da memoria.

@param oModel - Modelo


@Return Nil 

@Author Evandro dos Santos Oliveira
@Since 25/11/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafClearModel(oModel)

	If !IsInCallStack("TafPrepInt")
		FwFormCancel( oModel )
		oModel:Destroy()
		FreeObj( oModel )
	EndIf

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVAltEsocial
Funcao que verifica se alteração do evento é permitida e dispara mensagem na tela 
@param cAlias, character, (Alias do registro posicionado)
@Return .T.

@Author Vitor Henrique Ferreira
@Since 25/08/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFVAltEsocial(cAlias, cFonte)

	Local cNmFun   := FunName()
	Local cTitulo  := STR0017

	Default cFonte := cNmFun

	Default cAlias := ''

	/*---------------------------------------------------------
	Se o registro ja foi transmitido
	---------------------------------------------------------*/
	If (cAlias)->&(cAlias + '_STATUS') == ( "4" )
		MsgAlert(xValStrEr("000749")) //"Não é possível realizar alterações em registros já transmitidos." 

	ElseIf	(cAlias)->&(cAlias + '_STATUS') == ( "2" ) 
		MsgAlert(xValStrEr("000727")) //"Registro não pode ser alterado, pois se encontra em processo da transmissão."

	ElseIf (cAlias)->&(cAlias + '_STATUS') == ( "6" ) 
		MsgAlert(xValStrEr("000728")) //"Registro não pode ser alterado. Aguardando processo de transmissão do evento de Exclusão S-3000"
		
	ElseIf (cAlias)->&(cAlias + '_STATUS') == ( "7" )
		MsgAlert(xValStrEr("000772")) //"Registro não pode ser alterado, pois o evento de exclusão já se encontra na base do RET" 
		
	Else
		FWExecView(cTitulo,cFonte,MODEL_OPERATION_UPDATE)
	EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFVExcEsocial
Funcao que verifica se exclusão do evento é permitida e dispara mensagem na tela 
@param cAlias, character, (Alias do registro posicionado)
@Return .T.

@Author Vitor Henrique Ferreira
@Since 07/12/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFVExcEsocial(cAlias)

	Local cNmFun   := FunName()
	Local cTitulo  := STR0017

	Default cAlias := ''

	If (cAlias)->(!Eof())

		/*---------------------------------------------------------
		Se o registro ja foi transmitido
		---------------------------------------------------------*/
		If (cAlias)->&(cAlias + '_STATUS') == ( "4" )
			MsgAlert(xValStrEr("001099")) //"Não é possível realizar a exclusão de um registros já transmitidos." 
		
		ElseIf	(cAlias)->&(cAlias + '_STATUS') == ( "2" ) 
			MsgAlert(xValStrEr("001100")) //"Registro não pode ser excluído, pois se encontra em processo da transmissão."
		
		ElseIf (cAlias)->&(cAlias + '_STATUS') == ( "6" ) 
			MsgAlert(xValStrEr("001101")) //"Registro não pode ser excluído. Aguardando processo de transmissão do evento de Exclusão S-3000"
			
		ElseIf (cAlias)->&(cAlias + '_STATUS') == ( "7" )
			MsgAlert(xValStrEr("001102")) //"Registro não pode ser excluído, pois o evento de exclusão já se encontra na base do RET" 
			
		Else
			FWExecView(cTitulo,cNmFun,MODEL_OPERATION_DELETE)
		EndIf

	Else
		Help(" ",1,"NVAZIO")
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldEvTab
Funcao que valida a inclusão e alteração de eventos de tabelas do e-social

nChmd ->	1 - Dicionário
			2 - Integração	
			
nOper ->	3 - Inclusão	
		 	4 - Alteração
		 	5 - Exclusão

nEscopo	->	Escopo de agrupamento do Evento no TAFRotinas

@Return .T.

@Author Denis R. de Oliveira
@Since 19/12/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function VldEvTab( cTabEvt, nIndice, cCodigo, cPerIni, cPerFin, nChmd, nOper, aIncons, cPerIniXML, nEscopo, cEsocial, lNewValid )

	Local cLayout      := TAFRotinas( cTabEvt, 3, .F., nEscopo )[4]
	Local cChave       := ""
	Local cId          := ""
	Local cStatus      := ""
	Local cProtPn      := ""
	Local cDataIni     := ""
	Local nI           := 1
	Local nTam         := Len( xFilial( cTabEvt ) + cCodigo )
	Local aCpoInd      := {}
	Local aAreaSX3     := {}
	Local aAreaAnt     := {}
	Local aAreaTab     := ( cTabEvt )->( GetArea() )
	Local lRet         := .T.
	Local lNt1519      := FindFunction("TafNT1519") .And. TafNT1519() //Indica se está em vigor a NT 15/2019

	Default cTabEvt    := ""
	Default nIndice    := 0
	Default cCodigo    := ""
	Default cPerIni    := ""
	Default cPerFin    := ""
	Default nChmd      := 1
	Default nOper      := 1
	Default aIncons    := {}
	Default cPerIniXML := ""
	Default nEscopo    := 2
	Default lNewValid  := .F.

	If nChmd == 1 .and. ALTERA

		cStatus 	:= (cTabEvt)->&(cTabEvt + '_STATUS')
		cProtPn		:= (cTabEvt)->&(cTabEvt + '_PROTPN')
		cDataIni	:= (cTabEvt)->&(cTabEvt + '_DTINI' )

	EndIf	

	If nIndice == 13 .AND. cTabEvt == 'C1G' 

		cCodigo := Padr(cEsocial,TamSX3("C1G_ESOCIA")[1]) + cCodigo + Padr(cPerIni,TamSX3("C1G_DTINI")[1]) + Padr(cPerFin,TamSX3("C1G_DTFIN")[1]) + '1'
		nTam         := Len( xFilial( cTabEvt ) + cCodigo )

	ElseIf nIndice == 14 .AND. cTabEvt == 'C1G' 

		cCodigo :=  Padr(cEsocial,TamSX3("C1G_ESOCIA")[1]) + cCodigo + Padr(cPerIni,TamSX3("C1G_DTINI")[1]) //+ '1'
		nTam         := Len( xFilial( cTabEvt ) + cCodigo )

	EndIf

	//Incluso tratamento para controlar Data de Inicio e Data de Fim no Evento S-1050
	If nIndice == 2 .AND. cTabEvt == 'C90'

		cCodigo := cCodigo + Padr(cPerIni,TamSX3("C90_DTINI")[1]) + Padr(cPerFin,TamSX3("C90_DTFIN")[1]) + '1'
		nTam := Len( xFilial( cTabEvt ) + cCodigo )

	EndIf

	//Verifica a existência da tabela e indice
	if TafIndexInDic(cTabEvt, nIndice, .T.)

		//Posiciono na tabela do evento
		(cTabEvt)->(DBSetOrder(nIndice))

		If (cTabEvt)->( MsSeek( xFilial(cTabEvt) + cCodigo )) 		

			//Controla a operação (1-Inclusão|2-Alteração|3-Exclusão)
			If nChmd == 1
				
				If INCLUI 
					nOper	:= 3
				ElseIf ALTERA 
					nOper	:= 4
					cId		:= M->&(cTabEvt + '_ID')
				Else
					nOper 	:= 5
				EndIf
			
			Else
				
				If nOper == 4

					aAreaAnt	:= (cTabEvt)->(GetArea())
					
					(cTabEvt)->(DBSetOrder(nIndice))

					If lTAFCodRub .And.  cTabEvt == "C8R" 

						cRubTab := ""

						If Len(cCodigo) > TamSx3("C8R_CODRUB")[1]
							cRubTab := SubStr(cCodigo,(TamSx3("C8R_CODRUB")[1])+1,TamSx3("C8R_IDTBRU")[1])
						EndIf
					
						IF nChmd != 2
							C8R->(dbGoTo(TAFCodRub(SubStr(cCodigo,1,TamSx3("C8R_CODRUB")[1]), /*DTINI*/SubStr(cPerIniXML,3,4)+SubStr(cPerIniXML,1,2),;
							/*DTFIN*/"", /*ATIVO*/"1",/*TABELA*/cRubTab)))
						Else
							(cTabEvt)->( MsSeek( xFilial(cTabEvt) + cCodigo + cPerIniXML + "1"))
						EndIf

						cId			:= (cTabEvt)->&(cTabEvt + '_ID')
						cStatus 	:= (cTabEvt)->&(cTabEvt + '_STATUS')
						cProtPn	:= (cTabEvt)->&(cTabEvt + '_PROTPN')
						cDataIni	:= (cTabEvt)->&(cTabEvt + '_DTINI')

					ElseIf (cTabEvt)->( MsSeek( xFilial(cTabEvt) + cCodigo + cPerIniXML + "1"))

						cId			:= (cTabEvt)->&(cTabEvt + '_ID')
						cStatus 	:= (cTabEvt)->&(cTabEvt + '_STATUS')
						cProtPn	:= (cTabEvt)->&(cTabEvt + '_PROTPN')
						cDataIni	:= (cTabEvt)->&(cTabEvt + '_DTINI')

					EndIf

					RestArea( aAreaAnt )	

				EndIf
			
			EndIf	
				
			//Pego o título dos campos da chave, exceto _DTINI e _DTFIN
			aAreaSX3	:=	SX3->( GetArea() )
				
			dbSelectArea('SX3')
			SX3->( dbSetOrder(2) )
			
			aCpoInd	:= StrTokArr( (cTabEvt)->(IndexKey()), "+" )

			For nI := 1 To Len(aCpoInd)

				If !Alltrim(Substr(aCpoInd[nI],5)) $ "FILIAL|ID|VERSAO|DTINI|DTFIN|ATIVO|"
					SX3->( dbSeek( aCpoInd[nI] ) )
					cChave := cChave + Alltrim(X3Titulo()) + Iif(Len(aCpoInd)>1, " e ", "")
				EndIf

			Next
			
			RestArea( aAreaSX3 )
			
			//Validação das regras dos eventos de tabela
			If nOper <> 5 

				While !(cTabEvt)->(Eof()) .AND. xFilial(cTabEvt) + cCodigo == Substr((cTabEvt)->&(IndexKey()),1,nTam)

					If cTabEvt == "C1G" .And. lNt1519 .And. C1G->C1G_STATUS == "4" .And. C1G->C1G_LOGOPE == "A" // Caso o processo administrativo/judicial tenha sido incluido de forma automatica por outro evento

						RecLock(cTabEvt,.F.)
						C1G->C1G_ATIVO := "2"
						C1G->(MsUnlock())

					ElseIf (cTabEvt)->&(cTabEvt + '_ATIVO') == "1"

						If cTabEvt == "C1E" .And. (cTabEvt)->&(cTabEvt + '_STATUS') $ " |0|1|3" //Desconsidera a regra para C1E/S-1000 enquanto não for transmitido ou rejeitado pelo RET.
							Exit
						EndIf

						If nOper == 3 .AND. (cTabEvt)->&(cTabEvt + '_STATUS') == "2" 
						
							If nChmd == 1 
								Help( ,,"VLDDATA01",, STR0028 + cLayout + STR0029 + cChave + STR0030 , 1, 0  )//"Não é possível a inclusão do registro. Existe um evento " + cLayout + "na base, com o(a) mesmo(a) " + cChave + " transmitido e aguardando retorno do Governo."
								lRet	:= .F.	
							Else
								Aadd( aIncons, STR0028 + cLayout + STR0029 + cChave + STR0030) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + "na base, com o(a) mesmo(a) " + cChave + " transmitido e aguardando retorno do Governo."
							EndIf
						
						ElseIf nOper == 3 .AND. (cTabEvt)->&(cTabEvt + '_STATUS') == "3" 
						
							If nChmd == 1 	
								Help( ,,"VLDDATA02",, STR0028 + cLayout + STR0029 + cChave + STR0031 , 1, 0  ) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + "na base, com o(a) mesmo(a) " + cChave + " transmitido e não autorizado ( retornado com erro )."
								lRet	:= .F.	
							Else
								Aadd( aIncons, STR0028 + cLayout + STR0029 + cChave + STR0031) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + "na base, com o(a) mesmo(a) " + cChave + " transmitido e não autorizado ( retornado com erro )." 
							EndIf
						
						ElseIf nOper == 3 .AND. (cTabEvt)->&(cTabEvt + '_STATUS') <> "4"  
						
							If nChmd == 1 
								Help( ,,"VLDDATA03",, STR0028 + cLayout + STR0029 + cChave + STR0032 , 1, 0  )//"Não é possível a inclusão do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " não transmitido com sucesso ao RET." 
								lRet	:= .F.			 
							Else
								Aadd( aIncons, STR0028 + cLayout + STR0029 + cChave + STR0032) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " não transmitido com sucesso ao RET." 
							EndIf
					
						ElseIf ( nOper == 3 .OR. nOper == 4 ) .AND. cID <> (cTabEvt)->&(cTabEvt + '_ID') .AND. xPerToData(cPerIni) == xPerToData((cTabEvt)->&(cTabEvt + '_DTINI'))  
						
							If nChmd == 1 
								Help( ,,"VLDDATA04",, STR0034 + cLayout + STR0029 + cChave + STR0033 , 1, 0 ) //"Não é possível a inclusão/alteração do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a mesma data de início de validade {iniValid}."
								lRet	:= .F.
							Else
								Aadd( aIncons, STR0034 + cLayout + STR0029 + cChave + STR0033) //"Não é possível a inclusão/alteração do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a mesma data de início de validade {iniValid}."
							EndIf
				
						ElseIf ( nOper == 3 .OR. nOper == 4 ) .AND. cID <> (cTabEvt)->&(cTabEvt + '_ID') .AND. xPerToData(cPerIni) <= xPerToData((cTabEvt)->&(cTabEvt + '_DTFIN')) .AND. xPerToData(cPerIni) >= xPerToData((cTabEvt)->&(cTabEvt + '_DTINI'))
							
							If nChmd == 1
								Help( ,,"VLDDATA05",, STR0034 + cLayout + STR0029 + cChave + STR0041 , 1, 0 ) //"Não é possível a inclusão/alteração do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a data final igual ou superior a data de início a desse registro"
								lRet	:= .F.
							Else
								Aadd( aIncons, STR0034 + cLayout + STR0029 + cChave + STR0035) //"Não é possível a inclusão/alteração do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a data final igual ou superior a data de início do evento integrado."
							EndIf
						
						ElseIf nOper == 3 .AND. !Empty(cPerFin) .AND. xPerToData(cPerFin) <= xPerToData((cTabEvt)->&(cTabEvt + '_DTINI')) 
					
							If nChmd == 1 
								Help( ,,"VLDDATA06",, STR0028 + cLayout + STR0029 + cChave + STR0040 , 1, 0  ) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + "na base, com o(a) mesmo(a) " + cChave + " com a data início igual ou superior a data final a desse registro"
								lRet	:= .F.
							Else
								Aadd( aIncons, STR0028 + cLayout + STR0029 + cChave + STR0036) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + "na base, com o(a) mesmo(a) " + cChave + " com a data início igual ou superior a data final do evento integrado."
							EndIf
						
						ElseIf nOper == 4 .AND. cID <> (cTabEvt)->&(cTabEvt + '_ID') .AND. !Empty(cPerFin) .and. xPerToData(cPerIni) < xPerToData((cTabEvt)->&(cTabEvt + '_DTINI')) .AND. xPerToData(cPerFin) >= xPerToData((cTabEvt)->&(cTabEvt + '_DTINI')) 
					
							If nChmd == 1 
								Help( ,,"VLDDATA07",, STR0037 + cLayout + STR0029 + cChave + STR0038 , 1, 0  ) //"Não é possível a alteração do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a data início igual ou inferior a data final a desse registro.
								lRet	:= .F.
							Else
								Aadd( aIncons, STR0037 + cLayout + STR0029 + cChave + STR0039) //"Não é possível a alteração do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a data início igual ou inferior a data final do evento integrado."
							EndIf
							
						ElseIf nOper == 3 .AND. !Empty(cPerFin) .and. xPerToData(cPerIni) < xPerToData((cTabEvt)->&(cTabEvt + '_DTINI')) .AND. xPerToData(cPerFin) >= xPerToData((cTabEvt)->&(cTabEvt + '_DTINI')) 
					
							If nChmd == 1 
								Help( ,,"VLDDATA07",, STR0028 + cLayout + STR0029 + cChave + STR0044 , 1, 0  ) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a data início igual ou superior que a data início desse registro."
								lRet	:= .F.
							Else
								Aadd( aIncons, STR0028 + cLayout + STR0029 + cChave + STR0045 ) //"Não é possível a inclusão do registro. Existe um evento " + cLayout + " na base, com o(a) mesmo(a) " + cChave + " com a data início igual ou superior que a data início do evento integrado."
							EndIf
								
						EndIf
					
					EndIf	
					
					(cTabEvt)->(DbSkip())
				EndDo
					
			EndIf

		EndIf

	Endif

	RestArea( aAreaTab )

	//Regra do bloqueio de alteração de data de início dos eventos de tabela
	If !lNewValid

		If nOper == 4 .AND. (cStatus == "4" .OR. !Empty(cProtPn)) .AND. xPerToData(cPerIni) <> xPerToData(cDataIni)

			If nChmd == 1
				Help( ,,"VLDDATA08",, STR0042 + cLayout + STR0043 , 1, 0 ) // "Não é possível a alteração da data de início de validade {iniValid} do evento " # ". Para uma nova data de início de validade, favor inclua um novo registro."
				lRet	:= .F.
			Else
				Aadd( aIncons, STR0042 + cLayout + STR0043 )
			EndIf	

		EndIf

	EndIf

Return Iif ( nChmd == 1, lRet, aIncons )

//-------------------------------------------------------------------
/*/{Protheus.doc} TafAtDtVld
Funcao que verifica se houve alteração na dataFim do evento atual com o evento anterior (alterado, ativo = 2)  

@param cAlias	- Alias que a query erá trabalhar
@param cId		- Id do registro posicionado  
@param dNewDtIni,dNewDtFin - dataIni e dataFim do registro posicionado
@Return True/False

@Author Henrique Pereira
@Since 20/12/2017
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafAtDtVld(cAlias, cId, dNewDtIni, dNewDtFin, cVerAnt, lVldDtIni)

	Local lRet        := .F.
	Local cAliasQry   := GetNextAlias()
	Local cSelect     := ""
	Local cFrom       := ""
	Local cWhere      := ""
	Local cOrderBy    := ""
	Local cCampoIni	  := "_DTINI"
	Local cCampoFin	  := "_DTFIN"
	Default cAlias    := ""
	Default cId       := ""
	Default cVerAnt   := ""
	Default lVldDtIni := .F.

	If !Empty(cAlias) .AND. !Empty(cId) 
		
		If cAlias == 'V82'
			cCampoIni := "_INIPER"
			cCampoFin := "_FINPER"
		Endif

		cSelect	:= cAlias + cCampoIni + ", " + cAlias + cCampoFin
		cFrom		:= RetSqlName( cAlias ) + " " + cAlias
		cWhere 	:= cAlias + "." + cAlias + "_FILIAL = '" + xFilial( cAlias ) + "' "
		cWhere		+= " AND "+ cAlias + "." + cAlias + "_ID  = '" + cId + "'
		If !Empty(cVerAnt)
			cWhere		+= " AND "+ cAlias + "." + cAlias + "_VERSAO  = '" + cVerAnt + "'
		EndIf
		cWhere		+= " AND "+ cAlias + "." + cAlias + "_ATIVO  = '2'
		cWhere 	+= " AND "+ cAlias + ".D_E_L_E_T_ = ' ' "
		cOrderBy	+= cAlias + ".R_E_C_N_O_ "
		
		cSelect	:= "%" + cSelect 	+ "%"
		cFrom		:= "%" + cFrom   	+ "%"
		cWhere		:= "%" + cWhere  	+ "%"
		cOrderBy	:= "%" + cOrderBy	+ "%"
		
		BeginSql Alias cAliasQry
		
			SELECT
				%Exp:cSelect%
			FROM
				%Exp:cFrom%
			WHERE
				%Exp:cWhere%
			ORDER BY 
				%Exp:cOrderBy%
			DESC

		EndSql
		
		If (cAliasQry)->(!EOF())

			If lVldDtIni

				If	(Alltrim(dNewDtIni) <> Alltrim((cAliasQry)->&(cAlias + cCampoIni))) .Or. ;
					(Alltrim(dNewDtFin) <> Alltrim((cAliasQry)->&(cAlias + cCampoFin))) 	
						lRet := .T.
				EndIf

			Else

				If	Alltrim(dNewDtFin) <> Alltrim((cAliasQry)->&(cAlias + cCampoFin)) 	
						lRet := .T.
				EndIf	

			EndIf

		EndIf
		
		(cAliasQry)->(DbCloseArea())
		
	EndIf
	
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFGFilMatriz
Verifica qual é a Filial Matriz da Empresa/Grupo de Empresa

@param lEraseCache - Se True Força a limpeza do cache 
@param lLoadSM0    - Se True Força a Leitura do SM0 
					(está condicionado ao parametro lEraseCache estar .T.)
@param lExitCache  - Se True após a limpeza do cache não analisa se a filial posicionada é matriz
					 (está condicionado ao parametro lEraseCache estar .T.)

@return aFilMatriz [1] - Codigo da Empresa
				   [2] - Filial da Empresa
				   [3] - CNPJ 
				   [4] - IE
				   [5] - Status da Filial no Complemento de Empresa

@Author Evandro dos Santos Oliveira Teixeira
@Since 01/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFGFilMatriz(lEraseCache,lLoadSM0,lExitCache)

	Local cCnpjRaiz     := ""
	Local cCnpjLoop     := ""
	Local aAreaC1E      := {}
    Local nX            := 0
    Local nSizeFil      := 0
	Local aSM0          := {}
	Local aFilMatriz    := {}
	Local nPosFil       := 0
	Local lValidGrp		:= .F. 

	Default lEraseCache := .F.
	Default lLoadSM0    := .F.
	Default lExitCache  := .F.

	If Len(AllTrim(SM0->M0_CGC)) == 11
		cCnpjRaiz := AllTrim(SM0->M0_CGC) //Empresa pessoa Física
	Else 
		cCnpjRaiz := Substr(SM0->M0_CGC,1,8) // Cnpj base da filial posicionada
	EndIf 	

	If __aFilsMatriz == Nil .Or. lEraseCache 
		__aFilsMatriz := {} 
		TafConOut("Startup or Cleaning the Cache")
	Else 
		nPosFil := aScan(__aFilsMatriz,{|f|f[7] == cCnpjRaiz})
	EndIf 

	If !lExitCache

		If nPosFil > 0 .And. !lEraseCache

			aFilMatriz := __aFilsMatriz[nPosFil]

		Else 

			aSM0 := FWLoadSM0(lLoadSM0)
	 		lValidGrp := IIf(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)  //Valida se o cliente utiliza Gestao de Empresas
			aAreaC1E  := C1E->(getArea())
			dbSelectArea("C1E")
			C1E->(dbSetOrder(3))

			For nX := 1 To Len(aSM0)

				If Len(AllTrim(aSM0[nX][18])) == 11
					cCnpjLoop := AllTrim(aSM0[nX][18])
				Else 
					cCnpjLoop := Substr(aSM0[nX][18],1,8)
				EndIf 

				If cCnpjRaiz == cCnpjLoop

					nSizeFil := FWSizeFilial()

					If C1E->(MsSeek(xFilial("C1E")+PadR(AllTrim(aSM0[nX][02]),nSizeFil)+"1"))

						If C1E->C1E_MATRIZ .And. IIf(lValidGrp,aSM0[nX][01] == cEmpAnt,.T.) //Se lValidGrp igual a .T. o grupo do SM0 tem que bater com o grupo da filial logada.

							aFilMatriz	  := Array(8)
							aFilMatriz[1] := AllTrim(aSM0[nX][01]) 			 //Codigo Grupo de Empresa Matriz
							aFilMatriz[2] := AllTrim(aSM0[nX][02]) 			 //Codigo Filial Matriz 	
							aFilMatriz[3] := AllTrim(aSM0[nX][18]) 			 //CNPJ da Filial Matriz
							aFilMatriz[4] := retIESM0(AllTrim(aSM0[nX][22])) //IE da Filial Matriz
							aFilMatriz[5] := C1E->C1E_STATUS				 //Status da Filial Matriz na C1E
							aFilMatriz[6] := C1E->C1E_ID					 //ID da Filial Matriz na C1E
							aFilMatriz[7] := cCnpjRaiz		     			 //Raiz de CNPJ da Filial Matriz		
							aFilMatriz[8] := C1E->C1E_CODFIL		     	 //Filial do ERP		

							nX := nX + Len(aSM0) 	//Só pode ter 1 Filial Marcada como Matriz
													//por isso posso sair do laço quando ha a ocorrência.

							aAdd(__aFilsMatriz,aFilMatriz)

						EndIf

					EndIf 

				EndIf 

			Next nX

			RestArea(aAreaC1E)

		EndIf 

	EndIf 

Return (aFilMatriz)

//-------------------------------------------------------------------
/*/{Protheus.doc} retIESM0
Normaliza a Inscrição Estadual Retornada pela função FWLoadSM0

@param cIEFWSM0 - Posição 22 de retorno da Função FWLoadSM0
@return cIE 	- Numero da Inscrição Estadual

@Author Evandro dos Santos Oliveira Teixeira
@Since 01/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function retIESM0(cIEFWSM0)

	Local cIE  := ""
	Local aAux := {}

	aAux := StrTokArr(cIEFWSM0,"_")

	If Len(aAux) > 1
		cIE := aAux[2]
	EndIf 

Return cIE

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFTransFil
Verifica se deve ser permitido a transmissão de eventos pelas filiais,
o default é somente pela filial Matriz.

Permite a manipulação dos status válidos para a transmissao o default
é somente o 0 - Transmitido.

@return aFilMatriz [1] - Codigo da Empresa
				   [2] - Filial da Empresa
				   [3] - CNPJ 
				   [4] - IE

@Author Evandro dos Santos Oliveira Teixeira
@Since 01/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFTransFil(lJob,cStatus,lApi)

	Local lTransFil := SuperGetMv('MV_TAFTFIL',.F.,.F.) //Permite que seja realizado a tranmissão pela filial
	Local nX 		:= 0
	Local aParamTrs	:= {}
	Local cStsParam	:= ""
	Local lVirgula	:= .F. 

	Default cStatus := ""  
	Default lJob	:= .F.
	Default lApi	:= .F.

	If lJob

		lTransFil := .T. //Quando executado via schedule a transmissão é sempre realiza pela filial
						//Na função TAFRIdEnt foi inserido um tratamento para que o cnpj utilizado
						//na recuperação da entidade seja da matriz.

		If !lApi

			cStsParam := SuperGetMv('MV_TAFSTRS',.F.,"'0'") 
		
			aParamTrs := StrTokArr(cStsParam,",")
			cStatus := ""

			For nX := 1 To Len(aParamTrs)

				Iif( lVirgula, cStatus += ",", )
				cStatus += aParamTrs[nX]
				lVirgula := .T. 	

			Next nX

		EndIf

	EndIf 

Return lTransFil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMonSts
Retorna Status para monitoramento via schedule.

@Author Leonardo Kichitaro
@Since 10/10/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFMonSts(lJob)

	Local nX 		
	Local aParamTrs	
	Local cStsParam	
	Local cStatus	
	Local lVirgula	

	Default lJob	:= .F.

	nX 			:= 0
	aParamTrs 	:= {}
	cStsParam 	:= ""
	cStatus		:= ""
	lVirgula	:= .F. 

	If lJob

		cStsParam := SuperGetMv('MV_TAFSTMN',.F.,"'2'") //Parâmetro com status de monitoramento via Schedule
		
		aParamTrs := StrTokArr(cStsParam,",")
		cStatus := ""

		For nX := 1 To Len(aParamTrs)

			Iif( lVirgula, cStatus += ",", )
			cStatus += aParamTrs[nX]
			lVirgula := .T. 	

		Next nX

	EndIf 

Return cStatus

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSetFilter
Não Apagar, esta função está sendo utilizada apenas para verificação
da existencia da rotina TAFBrwSetFilter
/*/
//-------------------------------------------------------------------
Function TAFSetFilter(cAlias,cRotina,cNomeEve)
Return TAFBrwSetFilter(cAlias,cRotina,cNomeEve)  

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFBrwSetFilter
Define o Filtro do objeto FwMBrowse

@param cAlias - Alias do Browse
@param cRotina - Nome da Rotina

@Author Evandro dos Santos Oliveira Teixeira
@Since 01/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFBrwSetFilter(cAlias,cRotina,cNomeEve)    

	Local cFiltro    := ""
	Default cNomeEve := ""

	If cRotina == "TAFA421"

		cFiltro := "(C9V_ATIVO == '1'"
		cFiltro += " .AND. C9V_NOMEVE <> 'S2399'"
		cFiltro += " .AND. C9V_NOMEVE <> 'TAUTO')"

	ElseIf cNomeEve $ "S-1200|S-1202"

		cNomeEve := StrTran(cNomeEve,"-","") 

		cFiltro := cAlias + "_ATIVO == '1'"
		cFiltro += " .AND. " + cAlias + "_NOMEVE == '" + cNomeEve +  "'"

	Else

		cFiltro := cAlias + "_ATIVO == '1'"

	EndIf 
	
	cFiltro += " .OR. (" + cAlias + "_ATIVO == '2'" 
	
	If cRotina == "TAFA421" 
		cFiltro += " .AND. C9V_NOMEVE <> 'S2399'"
		cFiltro += " .AND. C9V_NOMEVE <> 'TAUTO'
	EndIf  

	If cAlias == "C9V" .AND. TAFColumnPos( "C9V_IDTRAN" ) 
		cFiltro += " .AND. (" + cAlias + "_EVENTO = 'E' .OR. (" + cAlias + "_IDTRAN <> '' .AND. !('|' $ " + cAlias + "_IDTRAN))))"  
	ElseIf cAlias $ "C91"
		cFiltro += " .AND. " + cAlias + "_EVENTO = 'E' .AND. " + cAlias + "_NOMEVE == '" + cNomeEve +  "')" 
	Else
		cFiltro += " .AND. " + cAlias + "_EVENTO = 'E')" 
	EndIf

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} TafAjustRecibo
Altera nome e Descrição do campo _PROTUL

@param oStruct - Estrutura que contem o campo _PROTUL
@param cAlias - Alias do Cadastro

@Author Evandro dos Santos Oliveira Teixeira
@Since 20/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafAjustRecibo(oStruct,cAlias)
	
	oStruct:SetProperty( cAlias+'_PROTUL', MVC_VIEW_TITULO ,STR0046) //"Nº Recibo"
	oStruct:SetProperty( cAlias+'_PROTUL', MVC_VIEW_DESCR  ,STR0047) //"Número do Recibo retornado pelo RET."

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafNmFolder
Altera Descrição e Titulo das pastas MVC

@param cToken - Identificação do Titulo
@param nTipo - Tipo do Titulo (1=Titulo do Folder, 0=Titulo da Pasta)

@Author Evandro dos Santos Oliveira Teixeira
@Since 20/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafNmFolder(cToken,nTipo)

	Local cTitulo := ""
	Default nTipo := 0

	If cToken == 'recibo'
		If nTipo == 0
			cTitulo := STR0048 //"Info. Controle eSocial"
		ElseIf nTipo == 1
			cTitulo := STR0049 //"Recibo da última Transmissão"  			
		Else 
			cTitulo := STR0057 //"Informações de Controle eSocial"
		EndIf 		
	EndIf

Return cTitulo

//-------------------------------------------------------------------
/*/{Protheus.doc} TafLayESoc
Retorna se a versão do layout do eSocial é a versão necessária do parâmetro

@param cVerCompara - Identificação do Titulo
@param lForce - Tipo do Titulo (1=Titulo do Folder, 0=Titulo da Pasta)

@Author Evandro dos Santos Oliveira Teixeira
@Since 20/03/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFLayESoc(cVerCompara as character, lForce as logical, lCompare as logical)

	Local cLayout       as character
	Local cLayAtivo     as character
	Local lRet			as logical

	Default lForce      := .F.
	Default lCompare	:= .F.
	Default cVerCompara := "S_01_00_00"

	cLayout     := ""
	cLayAtivo	:= "S_01_00_00"
	lRet		:= .F.

	If lForce
		cLayout	:= GetMv('MV_TAFVLES', .F., cLayAtivo)
	Else
		cLayout	:= SuperGetMv('MV_TAFVLES', .F., cLayAtivo)
	EndIf
		
	If lCompare
		lRet := cLayout >= cVerCompara
	Else
		lRet := TAFIsSimpl(cLayout)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDicInDb
Verifica se o Ambiente permite o uso de tabela temporaria no Banco

@Author Evandro dos Santos Oliveira Teixeira
@Since 11/04/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TafDicInDb()

	Local lTempTable := .F.

	If Val(GetVersao(.F.)) > 11 .And. AllTrim(GetRpoRelease()) >= "12.1.005"
		lTempTable := .T.
	EndIf

Return(lTempTable)

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelTempTable
Apaga tabela temporário criada no Banco

@param cRealName - Nome da tabela no Banco de dados
@param cErroSQL - Mensagem de Erro (referência)

@Author Evandro dos Santos Oliveira Teixeira
@Since 11/04/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
FuncTion TafDelTempTable(cRealName,cErroSQL)

	Local cQuery := ""
	Local lRet := .T. 

	cQuery := "DELETE FROM " + cRealName
	If TCSQLExec (cQuery) < 0
		cErroSQL := TCSQLError()
		lRet := .F. 
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConOut
Printa mensagens no console Informando a Data e Hora
@param cMensagem - Mensagem a ser impressa
@return Nil
@Author Evandro dos Santos Oliveira Teixeira
@Since 17/04/2018
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFConOut(cMensagem as character, nTipoMsg as numeric, lForce as logical, cAgrup as character)

	Local cDataBase 	as character
	Local cTime 		as character
	Local cTipoMsg 		as character

	Default cMensagem 	:= ""
	Default cAgrup    	:= "TAF"
	Default lForce    	:= .F.
	Default nTipoMsg  	:= 1

	cDataBase	:= ""
	cTime 		:= ""
	cTipoMsg 	:= ""

	If __lTAFConOut == Nil
		__lTAFConOut := (GetPvProfString("General", "TafConOut", "0", GetAdv97()) == "1")
	EndIf

	If __lTAFConOut .Or. lForce
		Do Case
			Case nTipoMsg == 1 
				cTipoMsg := "INFO"

			Case nTipoMsg == 2
				cTipoMsg := "WARN"

			Case nTipoMsg == 3 
				cTipoMsg := "ERROR"

			Case nTipoMsg == 4 
				cTipoMsg := "FATAL"

			Case nTipoMsg == 5 
				cTipoMsg := "DEBUG"

			Otherwise
				cTipoMsg := "INFO"

		EndCase

		cTime     := Time()
		cDataBase := DToC(Date())
		
		ConOut(ANSIToOEM("[" + cAgrup + "]"+"[" + cTipoMsg + "][" + ProcName(1) + " | #" + cValToChar(ProcLine(1)) + "] " + cMensagem + " Date: " + cDataBase + " Time: " + cTime))
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAfasCM6
Retorna se pode incluir afastamento na data informada
@author  Victor A. Barbosa
@since   14/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFAfasCM6( cIDFunc, dData, dDataIniAf, nTipo )

	Local aArea			:= GetArea()
	Local cNextAlias	:= GetNextAlias()
	Local lRet			:= .T.
	Local dDataAfas		:= Nil
	Local dDataFim		:= Nil

	// Início Afastamento
	If nTipo == 1
		
		If !Empty(DToS(dData))

			If Empty( M->CM6_DTAFAS )
				
				If TAFMaxAfast( cIDFunc, DTOS( dData ) )
					
					lRet := .T.
				
				ElseIf Empty( DTOS( dDataIniAf ) )
					
					Help( ,,"Atenção",,"Não existe afastamento com data de inicio para o funcionário", 1, 0 )
					lRet := .F.
				
				EndIf

			ElseIf !Empty( M->CM6_DTFAFA ) .And. dData > M->CM6_DTFAFA

				Help( ,,"Atenção",,"Data inicial informada é maior que a data final.", 1, 0 )
				lRet := .F.

			ElseIf dData < dDataIniAf

				Help( ,,"Atenção",,"Data informada é menor que a data inicial informada no evento S-2200", 1, 0 )
				lRet := .F.

			ElseIf CM6->CM6_STATUS != "4"
				
				If Select( cNextAlias ) > 0
					(cNextAlias)->( DbCloseArea() )
				EndIf

				BeginSQL Alias cNextAlias
					SELECT CM6_DTAFAS, CM6_DTFAFA, CM6_EVENTO, CM6_STATUS FROM %table:CM6% CM6
					WHERE CM6.CM6_FILIAL = %xFilial:CM6%
					AND	CM6.CM6_FUNC = %exp:cIDFunc%
					AND CM6.CM6_ATIVO = '1'
					AND CM6.%notdel%
					ORDER BY CM6_DTAFAS
				EndSQL

				(cNextAlias)->( dbGoTop() )

				While (cNextAlias)->( !Eof() )
						
					dDataAfas	:= STOD( (cNextAlias)->CM6_DTAFAS )
					dDataFim	:= STOD( (cNextAlias)->CM6_DTFAFA )

					If dData <= dDataAfas
						lRet := .T.
						Exit
					ElseIf dData >= dDataAfas .And. dData <= dDataFim
						Help( ,,"Atenção",,"Já existe um afastamento no período informado.", 1, 0 )
						lRet := .F.
						Exit
					EndIf 

					(cNextAlias)->( DbSkip() )
					
				EndDo

				(cNextAlias)->( DbCloseArea() )

			EndIf
					
		EndIf

	//Término Afastamento
	Else 
		If dData < dDataIniAf
			Help( ,,"Atenção",,"Data informada é menor que a data inicial informada no evento S-2200", 1, 0 )
			lRet := .F.
		Else
			// Se a data de início estiver vazia, é sinal que está informando o encerramento que foi iniciado no s-2200
			If !Empty( DTOS( dData ) )
				If Empty( M->CM6_DTAFAS )
					
					If TAFMaxAfast( cIDFunc, DTOS( dData ) )
						lRet := .T.
					ElseIf Empty( DTOS( dDataIniAf ) )
						Help( ,,"Atenção",,"Não existe afastamento com data de inicio para o funcionário", 1, 0 )
						lRet := .F.
					EndIf
				ElseIf !Empty( M->CM6_DTAFAS ) .And. dData < M->CM6_DTAFAS
					Help( ,,"Atenção",,"Data final informada é menor que a data inicial.", 1, 0 )
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFMaxAfast
Retorna se existe algum afastamento com data de início inferior aquela data de término.
@author  Victor A. Barbosa
@since   16/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function TAFMaxAfast( cIDFunc, cParamData )

Local aArea 		:= GetArea()
Local cAliasAfast	:= "AliasAfast"
Local lRet			:= .F.

If Select( cAliasAfast ) > 0
	(cAliasAfast)->( DbCloseArea() )
EndIf

BeginSQL Alias cAliasAfast
	SELECT R_E_C_N_O_ FROM %table:CM6% CM6
	WHERE CM6.CM6_FILIAL = %xFilial:CM6%
	AND	CM6.CM6_FUNC 	= %exp:cIDFunc%
	AND CM6.CM6_DTAFAS < %exp:cParamData%
	AND CM6_DTFAFA	= ''
	AND CM6_VERANT 	= ''
	AND CM6.%notdel%
	ORDER BY CM6_DTAFAS
EndSQL

(cAliasAfast)->( DbGoTop() )

If (cAliasAfast)->( !Eof() )
	lRet := .T.
EndIf

(cAliasAfast)->( DbCloseArea() )

RestArea( aArea )

Return( lRet )


//-------------------------------------------------------------------
/*/{Protheus.doc} isTAFInCloud
Indica se o ambiente está sendo executado em ambiente Cloud.
(Amazon+Docker+Kubernets)

@author  Evandro dos Santos Oliveira
@since   25/05/2018
@version 1
/*/
//-------------------------------------------------------------------
Function isTAFInCloud()

	If __lTAFinCloud == Nil
		__lTAFinCloud := (GetPvProfString(GetEnvServer(),"TafInCloud","0",getAdv97()) == "1")
	EndIf

Return __lTAFinCloud

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGetUrlTSS

@author  Evandro dos Santos Oliveira
@since   13/06/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TafGetUrlTSS(cCodEmp)

	Local cUrl := ""
	Default cCodEmp := FWCodEmp()

	cUrl := PadR(SuperGetMv("MV_TAFSURL",.F.,"",cCodEmp),250)

Return cUrl 

//-------------------------------------------------------------------
/*/{Protheus.doc} TafTableTag

@author  Eduardo Sukeda
@since   28/01/2019
@version 1

CRQ - horario
C9J - infoMV
T3H - procJudTrab
T3I - dmDev
T3J - ideDmDev
CMK - detVerbas
T15 - detOper
T16 - detPlano

/*/
//-------------------------------------------------------------------
Function TafTableTag(cAlias, cErrorLog)

Local cTag 		:= ""
Local cTabTag 	:= ""
Local cMsg 		:= "Verificação de chave duplicada, Erro de chave duplicada, favor verificar as informações que estão sendo integradas. "

Default cErrorLog := ""

If !Empty(cAlias)

	If TAFAlsInDic(cAlias)
	
		If cAlias == "CRQ"	
			cTag := "horario"
		ElseIf cAlias $ "C9M|C9R|T6E|T6K"
			cTag := "itensRemun"
		ElseIf cAlias $ "T05|T5S|CMK"
			cTag := "detVerbas"
		ElseIf cAlias $ "C9J"
			cTag := "infoMV"
		ElseIf cAlias $ "T3H|CRN"
			cTag := "procJudTrab"	
		ElseIf cAlias $ "T3I"
			cTag := "verbasResc"
		ElseIf cAlias $ "T3J|T14"
			cTag := "dmDev"
		ElseIf cAlias $ "T15|T6Y"
			cTag := "detOper"
		ElseIf cAlias == "T6W"
			cTag := "remunOutrEmpr"
		ElseIf cAlias == "C9N"
			cTag := "ideADC"
		ElseIf cAlias == "C9O"
			cTag := "idePeriodo"
		ElseIf cAlias == "C9P"
			cTag := "ideEstabLot"
		ElseIf cAlias $ "LE2|T6Q"
			cTag := "retPgtoTot"
		ElseIf cAlias $ "LE4|T6R"
			cTag := "infoPgtoParc"
		ElseIf cAlias $ "T5V"
			cTag := "detPgtoAnt"
		ElseIf cAlias $ "T5Y"
			cTag := "detRubrFer"
		ElseIf cAlias $ "T5Z|LE3"
			cTag := "penAlim"
		EndIf

		cTabTag := cMsg + "Tabela: " + cAlias + " - " +  "Grupo da Tag: " + cTag
	Else
		cTabTag := "Tabela inexistente no dicionário de dados."
	EndIf

Else
	cTabTag := "Houve um erro que impediu a integração deste registro. Entre em contato com o suporte TOTVS e informe o erro abaixo: " + CRLF
	cTabTag += cErrorLog
EndIf

Return(cTabTag)

/*/{Protheus.doc} GetAlsDup
Rotina para encontrar o Alias da tabela no qual 
ocorreu o error.log em virtude de chave duplicada
@type  Static Function
@author santos.diego
@since 29-01-2019
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GetAlsDup( cDescError )

Local cRet := ""
Local nPos := At( "_UNQ", cDescError)

If nPos > 0
	cRet := Upper(SubStr( cDescError, (nPos - 6), 3 ) )
Else
	nPos := At( "_unq", cDescError)
	If nPos > 0
		cRet := Upper(SubStr( cDescError, (nPos - 6) , 3 ) )
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFLayTables
Retorna os eventos com suas respectivas tabelas de acordo com a
estrura do Model.

@param - nEscopo - Escopo da Obrigação conforme definiçao no 
TAFRotinas:
1-Fiscal
2-eSocial
3-ECF
4-Autocontidas
5-Reinf 
@param cLayoutTAF - Nome do Layout

@Return - Array com Eventos na posicao 1 e Tabelas na posicao 2.
Se o parametro Evento nao for informado a estrura do retorno 
sera um array multidimensional por que serao retornardo todos 
os eventos


@author  Evandro dos Santos Oliveira
@since   22/06/2018
@version 1
/*/
//-------------------------------------------------------------------
Function TAFLayTables(nEscopo,cLayoutTAF) 

    Local aEventos := {} 
    Local cModel := ""
    Local cLayout := ""
    Local cTable := ""
	Local cTblPai := ""
    Local oModel := Nil 
    Local nX := 0
    Local nY := 0
    Local aTables := {}
    Local aTableModel := {}
	Local lLoadModels := .F. 

    Default nEscopo := 0 //Nao Habilitar o Todos
	Default cLayoutTAF := ""

	//Foi realizado a separacao por escopo para forçar o analista
	//utilzar somente o que precisa por que o carregamento de modelo é demorado.
	//É feito cache por demanda de acordo com o Escopo passado.

	If  (__aTblsFiscal   == Nil .And. nEscopo == 1) .Or.;
	    (__aTblsEsocial  == Nil .And. nEscopo == 2) .Or.;
		(__aTblsECF      == Nil .And. nEscopo == 3) .Or.;
		(__aTblsAutoCont == Nil .And. nEscopo == 4) .Or.;
		(__aTblsReinf	 == Nil .And. nEscopo == 5)
	  
		lLoadModels := .T.
		aEventos := TAFRotinas(,,.T.,nEscopo)

	EndIf 

	If lLoadModels	
 
		For nY := 1 To Len(aEventos)

			cModel := aEventos[nY][1]
			cLayout := AllTrim(aEventos[nY][4])
			cTblPai := AllTrim(aEventos[nY][3])

			If !Empty(cLayout) .And. TAFAlsInDic(cTblPai)

				aTables := Array(2)
				aTables[1] := cLayout
				aTables[2] := {}

				oModel := FWLoadModel(cModel)

				For nX := 1 To Len(oModel:aAllSubModels)
				
					If Len(oModel:aAllSubModels[nX]:oFormModelStruct:aTable) > 0
					
						cTable := oModel:aAllSubModels[nX]:oFormModelStruct:aTable[1]
						aAdd(aTables[2],cTable)
						
					EndIf 
					
				Next nX 
				aAdd(aTableModel,aClone(aTables))
				aSize(aTables,0)

			EndIf
		Next nY

		aSize(aEventos,0)

		If nEscopo == 1 
			__aTblsFiscal := aClone(aTableModel)
		ElseIf nEscopo == 2
			__aTblsEsocial := aClone(aTableModel)
		ElseIf nEscopo == 3
			__aTblsECF := aClone(aTableModel)
		ElseIf nEscopo == 4
			__aTblsAutoCont := aClone(aTableModel)
		ElseIf nEscopo == 5
			__aTblsReinf := aClone(aTableModel)
		EndIf 

		FreeObj(oModel)
		oModel := Nil 
		aSize(aTableModel,0)
		DelClassIntF()
	
	EndIf 

Return getTablesLayout(nEscopo,cLayoutTAF)

//-------------------------------------------------------------------
/*/{Protheus.doc} getTablesLayout
Retorna array com eventos + tabelas de acordo com os parametros.

@author  Evandro dos Santos Oliveira
@since   23/06/2018
@version 1
/*/
//-------------------------------------------------------------------
Static Function getTablesLayout(nEscopo,cLayoutTAF)

	Local aLayoutTable := {}
	Local nPosEvento := 0

	Default nEscopo := 0
	Default cLayoutTAF := ""

	If nEscopo == 1 

		If Empty(cLayoutTAF)
			aLayoutTable := aClone(__aTblsFiscal)
		Else 
			nPosEvento := aScan(__aTblsFiscal,{|x|x[1] == cLayoutTAF})
			aLayoutTable :=  aClone(__aTblsFiscal[nPosEvento])
		EndIf 
	ElseIf nEscopo == 2

		If Empty(cLayoutTAF)
			aLayoutTable := aClone(__aTblsEsocial)
		Else
			nPosEvento := aScan(__aTblsEsocial,{|x|x[1] == cLayoutTAF})
			aLayoutTable :=  aClone(__aTblsEsocial[nPosEvento])
		EndIf 
	ElseIf nEscopo == 3

		If Empty(cLayoutTAF)
			aLayoutTable := aClone(__aTblsECF)
		Else
			nPosEvento := aScan(__aTblsECF,{|x|x[1] == cLayoutTAF})
			aLayoutTable :=  aClone(__aTblsECF[nPosEvento])
		EndIf
	ElseIf nEscopo == 4

		If Empty(cLayoutTAF)
			aLayoutTable := aClone(__aTblsAutoCont)
		Else 
			nPosEvento := aScan(__aTblsAutoCont,{|x|x[1] == cLayoutTAF})
			aLayoutTable :=  aClone(__aTblsAutoCont[nPosEvento])
		EndIf 
	ElseIf nEscopo == 5

		If Empty(cLayoutTAF)
			aLayoutTable := aClone(__aTblsReinf)
		Else 
			nPosEvento := aScan(__aTblsReinf,{|x|x[1] == cLayoutTAF})
			aLayoutTable :=  aClone(__aTblsReinf[nPosEvento])	
		EndIf 
	EndIf 

Return aLayoutTable


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFSetEpoch
Altera o SET_EPOCH de campos do tipo data. 
Ou seja, informa qual o ano o sistema assumirá por padrão quando o usuário digitar apenas 2 dígitos.

@author  Leandro Dourado
@since   26/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFSetEpoch(nEpochNew)

Default nEpochNew := 0

If nEpochNew == 0
	nEpochNew := Year(Date()) - 90 
EndIf

SET(_SET_EPOCH,nEpochNew)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFFindClass
Verifica a existência de uma classe contida no RPO. 
Por conta de problemas na lib, a função FindClass está travando o sistema e funciona apenas para a versão 12.1.17. Por conta disso, foi feito um desvio para as demais versões.

@author  Leandro Dourado
@since   15/10/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFFindClass( cClass )
Local lRet     := .F.
Local cRelease := GetRpoRelease()

Default cClass := "FWCSSTools"

If cRelease $ "12.1.017|12.1.023|12.1.025"
	lRet := .T.
Else
	lRet := FindFunction("FindClass") .And. FindClass(cClass)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetEmailAPI
Retorna o email do usuario logado
*Foi necessario a criação dessa função pois a UsrRetMail
estava dando erro nas chamadas via rest. 

@author  Katielly Feitosa Rezende
@since   24/09/2020
@version 1
/*/
//-------------------------------------------------------------------
Function RetEmailAPI(cCodUser)
local aUser  as array
local aRet 	 as array
local cEmail as character

Default cCodUser := ""

aUser  := {}
aRet   := {}
cEmail := ""

if !Empty(cCodUser)
	aUser := StrTokArr( cCodUser, "," ) 
	aRet  := FWSFALLUSERS(aUser)

	cEmail :=  aRet[1][5]
endIf

Return cEmail

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldExtemp
Funcao utilizada para efetuar validação de alterações realizadas no 
cadastro do funcionário, extemporâneo do funcionário e extemporâneo
do benefício

@return lRet - Retorno da validação efetuada.

@author Rodrigo Nicolino
@since 28/10/2020

@version 1.0
   
/*/
//-------------------------------------------------------------------
Function xVldExtemp( cAlias, cNameFunc )

	Local lRet		:= .T.
	Local aArea 	:= GetArea()
	Local cId		:= FWFLDGET(cAlias + "_ID")
	Local cChvTrab	:= cId + '1'
	Local dDataDig	:= &( ReadVar() )
	Local cCmpDtAlt := ""

	If cAlias $ "V76|V77|V78"

		cId		 := (cAlias)->&(cAlias + "_ID")
		cChvTrab := cId + '1'

		If lExist2416 .And. cAlias == "V76"
			cCmpDtAlt		:= "_DALTBE"
		ElseIf lExist2418 .And. cAlias == "V77"
			cCmpDtAlt		:= "_DTREAT"
		ElseIf lExist2420 .And. cAlias == "V78"
			cCmpDtAlt		:= "_DTTERM"
		EndIf

		If RetUltAtv(cAlias, cChvTrab, 1)

			If cNameFunc == "GOSETEXTEMP"

				If dDataDig >= (cAlias)->&(cAlias + cCmpDtAlt)

					lRet := .F.

				EndIf
			EndIf

		EndIf

	Else

		If RetUltAtivo(cAlias,cChvTrab,2)

			If cNameFunc == "GOSETEXTEMP"

				If dDataDig >= (cAlias)->&(cAlias + "_DTALT")

					lRet := .F.

				EndIf

			ElseIf cNameFunc == "ALTCADTRAB"

				If dDataDig < (cAlias)->&(cAlias + "_DTALT")

					lRet := .F.

				EndIf

			EndIf
				
		EndIf

	EndIf
	
	RestArea( aArea )
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xVldExtemp
Funcao utilizada para efetuar alltrim ou rtrim no dado que for passado como parâmetro de acordo com o 
status do parâmetro MV_TAFESPM

@return lRet - Retorno da validação efetuada.

@author Rodrigo Nicolino
@since 03/12/2020

@version 1.0
   
/*/
//-------------------------------------------------------------------
Function xGetMatric(cMatric)

	Local lEspM  	 := SuperGetMV("MV_TAFESPM",,.T.,)
	Local cRetMatric := ""

	If lEspM
		cRetMatric := AllTrim( cMatric )
	Else
		cRetMatric := RTrim( cMatric )
	EndIf

Return(cRetMatric)

//-------------------------------------------------------------------
/*/{Protheus.doc} function EvtExtemp
Verfica se o evento a ser integrado é extemporâneo.
cAlias    -> Alias da Tabela
dDataAlt  -> Data de Alteração
cIdEvtTrb -> Id do trabalhador.
@author  Jose.riquelmo
@since   11/12/2020
@version version
/*/
//-------------------------------------------------------------------
Function EvtExtemp(cAlias, dDataAlt, cIdEvtTrb)

	Local cQuery      := ""
	Local nQtdTotal	  := 0
	Local lReturn 	  := .F.
	Local cAliasQry	  := ""

	Default dDataAlt  := ""
	Default cIdEvtTrb := ""
	Default cAlias	  := ""

	If cAlias == "V75"
		cCmpDtAlt := "_DTINBE"
	ElseIf cAlias == "V76"
		cCmpDtAlt := "_DALTBE"
	ElseIf cAlias == "V77"
		cCmpDtAlt := "_DTREAT"
	ElseIf cAlias == "V78"
		cCmpDtAlt := "_DTTERM"
	Else
		cCmpDtAlt := "_DTALT
	EndIf


	cAliasQry := GetNextAlias()

	cQuery := "SELECT COUNT(*) QUANTIDADE "

	cQuery += "FROM " + RetSqlName(cAlias) + " ALIAS "

	cQuery += " WHERE ALIAS." + cAlias + cCmpDtAlt + " > '" + Dtos(dDataAlt) +  "' " 
	cQuery += "  AND ALIAS." + cAlias + "_ID = '" + cIdEvtTrb +  "' " 
	cQuery += "  AND ALIAS."+ cAlias +"_ATIVO = '1' "
	cQuery += "  AND ALIAS."+ cAlias +"_EVENTO <> 'E' "
	cQuery += "  AND ALIAS.D_E_L_E_T_ = ' ' "


	cQuery := ChangeQuery( cQuery )

	TCQuery cQuery New Alias &cAliasQry


	If ( cAliasQry )->( !Eof() )
		nQtdTotal := ( cAliasQry )->QUANTIDADE
		If nQtdTotal > 0
			lReturn := .T.
			(cAliasQry)->(DbSkip())
		EndIf
	EndIf

	( cAliasQry )->( DBCloseArea() )

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} EvtExclusao

Funcao que gera a exclusão do evento (S-3000)

@Param  oModel  -> Modelo de dados
@Param  nRecno  -> Numero do recno

@Return .T.

@author Rodrigo Nicolino
@since 13/09/2021
@Version 1.0
/*/
//-------------------------------------------------------------------
Function EvtExclusao( oModel, nRecno, cAlias )

	Local aGrava     := {}
	Local cEvento    := ""
	Local cProtocolo := ""
	Local cVerAnt    := ""
	Local cVersao    := ""
	Local nlI        := 0
	Local nlY        := 0
	Local oModelExc	 := Nil

	Default cAlias   := ""
	Default nRecno   := 1
	Default oModel   := Nil

	//Controle se o evento é extemporâneo
	lGoExtemp	:= Iif( Type( "lGoExtemp" ) == "U", .F., lGoExtemp )

	If !Empty(cAlias)

		//Abro as tabelas
		dbSelectArea(cAlias)

		Begin Transaction

			//Posiciona o item
			(cAlias)->( DBGoTo( nRecno ) )

			oModelExc := oModel:GetModel( "MODEL_" + cAlias )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busco a versao anterior do registro para gravacao do rastro³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cVerAnt    := oModelExc:GetValue( cAlias + "_VERSAO" )
			cProtocolo := oModelExc:GetValue( cAlias + "_PROTUL" )
			cEvento    := oModelExc:GetValue( cAlias + "_EVENTO" )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Neste momento eu gravo as informacoes que foram carregadas       ³
			//³na tela, pois neste momento o usuario ja fez as modificacoes que ³
			//³precisava e as mesmas estao armazenadas em memoria, ou seja,     ³
			//³nao devem ser consideradas neste momento                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nlI := 1 To 1
				For nlY := 1 To Len( oModelExc:aDataModel[ nlI ] )
					Aadd( aGrava, { oModelExc:aDataModel[ nlI, nlY, 1 ], oModelExc:aDataModel[ nlI, nlY, 2 ] } )
				Next
			Next

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Seto o campo como Inativo e gravo a versao do novo registro³
			//³no registro anterior                                       ³
			//|                                                           |
			//|ATENCAO -> A alteracao destes campos deve sempre estar     |
			//|abaixo do Loop do For, pois devem substituir as informacoes|
			//|que foram armazenadas no Loop acima                        |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FAltRegAnt( cAlias, '2' )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Neste momento eu preciso setar a operacao do model³
			//³como Inclusao                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oModel:DeActivate()
			oModel:SetOperation( 3 )
			oModel:Activate()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Neste momento eu realizo a inclusao do novo registro ja³
			//³contemplando as informacoes alteradas pelo usuario     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nlI := 1 To Len( aGrava )
				oModel:LoadValue( "MODEL_" + cAlias, aGrava[ nlI, 1 ], aGrava[ nlI, 2 ] )
			Next

			//Busco a nova versao do registro
			cVersao := xFunGetVer()

			/*---------------------------------------------------------
			ATENCAO -> A alteracao destes campos deve sempre estar
			abaixo do Loop do For, pois devem substituir as informacoes
			que foram armazenadas no Loop acima
			-----------------------------------------------------------*/
			oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_VERSAO", cVersao 	)
			oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_VERANT", cVerAnt 	)
			oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_PROTPN", cProtocolo )
			oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_PROTUL", "" 		)

			/*---------------------------------------------------------
			Tratamento para que caso o Evento Anterior fosse de exclusão
			seta-se o novo evento como uma "nova inclusão", caso contrário o
			evento passar a ser uma alteração
			-----------------------------------------------------------*/
			oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_EVENTO", "E" )
			oModel:LoadValue( "MODEL_" + cAlias, cAlias + "_ATIVO" , "1" )

			//Gravo alteração para o Extemporâneo
			If lGoExtemp
				TafGrvExt( oModel, "MODEL_" + cAlias, cAlias )
			EndIf

			FwFormCommit( oModel )
			TAFAltStat( cAlias,"6" )

		End Transaction

	EndIf

Return ( .T. )

//----------------------------------------------------------------------
/*/{Protheus.doc} DelEvento
Deleta o registro do alias que está posicionado

@Return .T.

@Author Rodrigo Nicolino
@Since 04/01/2022
@Version 1.0
/*/
//-----------------------------------------------------------------------
Function DelEvento(cFunName)

	Local oModelDel 	:= Nil

	Default cFunName	:= ""

	If !Empty(cFunName)

		oModelDel := FWLoadModel(cFunName)
		oModelDel:SetOperation( 5 )
		oModelDel:Activate()
		FwFormCommit( oModelDel )
		
	EndIf

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} TAFNT0421
Avalia se o ambiente do Governo já encontra-se com a NT 04/2021 implementada

@param lSimplif - Informa se é layout simplificado ou não

@Return lRet - Informa se a NT 04/2021 está implementada

@Author Melkz Siqueira
@Since 10/02/2022
@Version 1.0
/*/
//-----------------------------------------------------------------------
Function TAFNT0421(lSimplif)

	Local cTAFAmbe 		:= ""
	Local lRet 			:= .F.

	If lSimplif == Nil
	
		If lCacheSimp == NIL

			lCacheSimp := TAFLayESoc("S_01_00_00")
		
		EndIf

		lSimplif := lCacheSimp

	EndIf

	If lSimplif

		cTAFAmbe := SuperGetMV("MV_TAFAMBE", .F., "2") 

		If cTAFAmbe == "2" .And. DToS(Date()) >= SuperGetMV("MV_TAFNTDT", .F., "20220314")

			lRet := .T.

		ElseIf cTAFAmbe == "1" .And. DToS(Date()) >= SuperGetMV("MV_TAFNTDP", .F., "20220321")

			lRet := .T.

		EndIf

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetInfoTSS
Obtem as informações do TSS (codigo da entidade e versão do TSS).
@author Silas Gomes
@since 31/05/2022
@version 1.0

@return aReturn - 	[1]Código da Entidade
					[2]Versão TSS
/*/
//-------------------------------------------------------------------
Function GetInfoTSS()

	Local cFilBack	:= cFilAnt
	Local cUser 	:= __cUserId
	Local cGetIdEnt	:= "GetIdEntTafspnfe"
	Local cURL 		:= PadR(GetNewPar("MV_TAFSURL","http://"),250)
	Local cIdEnt 	:= ""
	Local cProdRura	:= ""
	Local cMsgErro 	:= ""
	Local cVersao	:= ""
	Local cInfo 	:= ""
	Local aArea  	:= SM0->(GetArea())
	Local aProdRura := {}
	Local aReturn	:= {}
	Local lUsaGesEm := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
	Local lRetorno	:= .F.
	Local oWs		:= Nil

	//Coleto informação do complemento cadastral para informar
	//o CNPJ do transmissor quando for diferente do empregador.
	C1E->(DbSetOrder(3))

	If C1E->( DbSeek( xFilial( "C1E" ) + PadR( SM0->M0_CODFIL , TamSX3( 'C1E_FILTAF' )[1] ) + '1' ) )
		cInfo := C1E->C1E_CNPJTR //"CNPJ" do transmissor
	EndIf

	If FindFunction( "VProdRural" ) 
		aProdRura := VProdRural( ,,cGetIdEnt)
		If Len( aProdRura ) > 0
			cProdRura := aProdRura[2]
		EndIf

	EndIf

	//Obtem o codigo da entidade	
	oWS := WSSPEDADM():New()

	oWS:cUSERTOKEN := "TOTVS"
		
	//Realiza tratamento para criação de Entidade no TSS com CPF e manter    
	// Entidade com CNPJ para envio de NFE na mesma filial.            
	If !Empty(cProdRura)
		oWS:OWSEMPRESA:cCPF		:= cProdRura
	Else
		oWS:oWSEMPRESA:cCNPJ	:= IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
		oWS:OWSEMPRESA:cCPF		:= IIF(SM0->M0_TPINSC==3,AllTrim(SM0->M0_CGC),"")
		oWS:oWSEMPRESA:cIE		:= SM0->M0_INSC
	EndIf

	oWS:oWSEMPRESA:cIM         	:= SM0->M0_INSCM		
	oWS:oWSEMPRESA:cNOME       	:= SM0->M0_NOMECOM
	oWS:oWSEMPRESA:cFANTASIA   	:= IIF(lUsaGesEm,FWFilialName(),Alltrim(SM0->M0_NOME))
	oWS:oWSEMPRESA:cENDERECO   	:= FisGetEnd(SM0->M0_ENDENT)[1]
	oWS:oWSEMPRESA:cNUM        	:= FisGetEnd(SM0->M0_ENDENT)[3]
	oWS:oWSEMPRESA:cCOMPL      	:= FisGetEnd(SM0->M0_ENDENT)[4]
	oWS:oWSEMPRESA:cUF         	:= SM0->M0_ESTENT
	oWS:oWSEMPRESA:cCEP        	:= SM0->M0_CEPENT
	oWS:oWSEMPRESA:cCOD_MUN    	:= SM0->M0_CODMUN
	oWS:oWSEMPRESA:cCOD_PAIS   	:= "1058"
	oWS:oWSEMPRESA:cBAIRRO     	:= SM0->M0_BAIRENT
	oWS:oWSEMPRESA:cMUN        	:= SM0->M0_CIDENT
	oWS:oWSEMPRESA:cCEP_CP     	:= Nil
	oWS:oWSEMPRESA:cCP         	:= Nil
	oWS:oWSEMPRESA:cDDD        	:= Str(FisGetTel(SM0->M0_TEL)[2],3)
	oWS:oWSEMPRESA:cFONE       	:= AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
	oWS:oWSEMPRESA:cFAX			:= AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
	oWS:oWSEMPRESA:cEMAIL		:= RetEmailAPI(cUser)  
	oWS:oWSEMPRESA:cNIRE       	:= SM0->M0_NIRE
	oWS:oWSEMPRESA:dDTRE       	:= SM0->M0_DTRE
	oWS:oWSEMPRESA:cNIT        	:= IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
	oWS:oWSEMPRESA:cINDSITESP  	:= ""
	oWS:oWSEMPRESA:cID_MATRIZ  	:= ""

	If lUsaGesEm
		oWS:oWSEMPRESA:CIDEMPRESA	:= FwGrpCompany()+FwCodFil()
	EndIf
		
	oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
	oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

	//Tratamento para inclusao do campo de emissor/responsavel
	If TAFColumnPos( "C1E_CNPJTR" )
		//Verifica a função do client do SPEDADM(sped_wscadm.prw) 
		//e protege para a nova propriedade não gerar error log.
		If(FindFunction("U_TAFSPEDADM") .And. U_TAFSPEDADM() >= "20180227", oWS:oWSEMPRESA:cUPDINSCRTR := "S", TafConOut(STR0001)) //"A versão dos programas de uso do TSS estão desatualizadas."	

		oWS:oWSEMPRESA:cINSCRTRA	:= cInfo
	EndIf

	If oWs:ADMEMPRESAS()
		cIdEnt  := oWs:cADMEMPRESASRESULT
	Else	
	    //Tratamento para mensagens mais amigáveis
		cMsgErro := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		If "WSCERR044" $ cMsgErro
			cMsgErro := STR0005 + CRLF + CRLF                   // Falha ao tentar se conectar ao TSS.
			cMsgErro += STR0005 + CRLF               			// Configurações usadas:
			cMsgErro += STR0007 + AllTrim(cURL) + CRLF + CRLF   // Url Totvs Service SOA:
			cMsgErro += STR0008                                 // Verifique as configurações do servidor e se o mesmo está ativo.
		EndIf

		TAFVldTokenTSS(@cMsgErro,, GetWscError(2)) 	
		TafConOut(cMsgErro)

	EndIf

	aAdd(aReturn, cIdEnt)
		
	FreeObj(oWS)
	oWS := Nil 

	If !Empty(cIdEnt)
		oWS := WsSpedCfgNFe():New()

		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= aReturn[1]
		oWS:cVersao    	:= "0.00"
		oWS:_URL 		:= AllTrim(cURL)+"/SPEDCFGNFe.apw"

		If oWs:CFGCONNECT()
			lRetorno := .T.
		EndIf

		If lRetorno
			oWS:CFGTSSVERSAO()
			cVersao	:= oWS:cCfgTSSVersaoResult
		Else
			cVersao	:= "TSS não conectado"
		EndIf

		FreeObj(oWS)
		oWS := Nil		
	Else
		cVersao	:= "Entidade não encontrada"
	EndIf

	aAdd(aReturn, cVersao)		
		
	RestArea(aArea)
	cFilAnt := cFilBack

Return aReturn


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewEvent
Retorna o modo de visualização do evento de acordo com a versão do layout
@author Jose Riquelmo / Karyna Martins	
@since 04/07/2022
@version 1.0

@return lRet 
/*/
//-------------------------------------------------------------------
Function ViewEvent(cEvent as character, lMenuDef as logical)

	Local aTafRot  		as array
	Local cVersion 		as character
	Local lRet     		as logical
	Local lExibe   		as logical

	Default cEvent		:= "" 
	Default lMenuDef 	:= .T.

	aTafRot		:= TAFRotinas(cEvent, 4, .F., 2,, lMenuDef)
	cVersion	:= AllTrim(SuperGetMV("MV_TAFVLES",.F., "S_01_00_00"))
	lRet		:= .F.
	lExibe		:= .T.	
	
	If !Empty(aTafRot)
		lExibe := aTafRot[19]
	EndIf

	lRet := !lExibe .And. cVersion == "S_01_00_00" 
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDesEven
@description Aviso de descontinuidade de evento do e-Social
@param cVerAnt - Versão anterior do e-Social
@param cVerAtu - Versão atual do e-Social
@param cLayESoc - Versão do laiaute do parâmetro MV_TAFVLES
@param dDataLim - Data limite do período de convivência
@author Melkz Siqueira
@since 04/07/2022
@version 1.0		
/*/ 
//-------------------------------------------------------------------
Function TAFDesEven( cVerAnt as character, cVerAtu as character, cLayESoc as character, dDataLim as date , lAuth as logical)
	
	Local cMsg			as character
	Local oFontSub		as object
	Local oModal		as object

	Default	cVerAnt		:= "2.5"
	Default cVerAtu		:= "S-1.0"
	Default cLayESoc	:= "S_01_00_00"
	Default dDataLim	:= dDataBase
	Default lAuth       := .T.

	cMsg		:= ""
	oFontSub	:= Nil
	oModal		:= Nil

	If lAuth .And. TafLayESoc(cLayESoc) .And. DToS(dDataLim) > "20220309" 
		oFontSub 	:= TFont():New("Arial",, -16, .T.)
		oModal		:= FWDialogModal():New()

		oModal:SetEscClose(.T.)
		oModal:SetTitle(STR0059) 								// "Evento descontinuado"																					
		oModal:SetSize(160, 270)
		oModal:CreateDialog()

		cMsg := '<div align="justify">'																		
		cMsg += '<p>' + STR0060 + cVerAtu + "." //+ STR0061 // "Este evento será aberto em modo de visualização em ambientes configurados para a versão " // " do e-Social e superiores."
		cMsg += ' ' + STR0062 + '.' + ' '	// "Este comportamento se deve ao fato deste leiaute ter sido descontinuado após a versão "
		cMsg += '' + STR0063 + ''  	// "Caso seja necessário fazer a manutenção dos registros deste evento, o parâmetro MV_TAFVLES deve ser alterado para a versão "																																																																								
		cMsg += '' + STR0064 + '.' + '</p>'	// "A alteração deste parâmetro pode causar erros de integração ou transmissão no caso de ocorrência de utilização destas funcionalidades com o ambiente configurado para a versão " 
		cMsg += '</div>'

		oModal:addCloseButton(Nil, STR0065)						// "Estou ciente"

		TSay():New(30, 13, {|| cMsg},,, oFontSub,,,, .T.,,, 250, 100,,,,,, .T.)

		oModal:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFNameEspace
Retona layout do xml que foi integrado
@author  Alexandre de Lima
@since   13/09/2022
@version 1.0
@param  cXml - Xml com caracteristicas originais da integração (Sem remoção do name espace)
@return cLayout - Versão dolayout do esocial 
/*/
//-------------------------------------------------------------------
Function TAFNameEspace(cXML	as character)

	Local aLayout		as array
	Local cLayout		as character
	Local cNameSpace	as character
	Local oXML			as object

	Default cXML	:= ""

	aLayout		:= {}
	cLayout		:= ""
	cNameSpace	:= ""
	oXML		:= Nil

	If !Empty(cXML)
		
		oXML := tXmlManager():New()

		oXML:Parse(cXML)

		aLayout := oXML:XPATHGETROOTNSLIST()

		If aLayout != Nil .And. !Empty(aLayout)
			If ValType(aLayout[1]) == "A" .And. Len(aLayout[1]) >= 2
				cNameSpace := SubStr(aLayout[1][2], At("/v", aLayout[1][2], 1))

				If "/v_" $ cNameSpace  
					cLayout := SubStr(cNameSpace, 4) 
				ElseIf "/v" $ cNameSpace  
					cLayout := SubStr(cNameSpace, 3) 
				EndIf
			EndIf
		EndIf

		If Empty(cLayout)
			cLayout := SuperGetMV("MV_TAFVLES")
		EndIf
	EndIf

Return cLayout

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFIsSimpl
Retorna se o layout do e-Social informado é simplificado ou não

@param cLayout - Layout do e-Social
@return cLaySimpl - Informa se é simplificado ou não

@Author Melkz Siqueira
@Since 21/09/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFIsSimpl(cLayout as character)
	
	Default cLayout := ""

Return cLayout $ "S_01_00_00|S_01_01_00|S_01_02_00|S_01_03_00"

/*/{Protheus.doc} TAFisBDLegacy
Funcao para identificacao de banco de dados nao homologado (versoes descontinuadas)
O Objetivo desta funcao é permitir que o cliente de forma explicita indique que 
está utilizando um banco de dados descontinuado, desta forma será possível realizar
tratamento especificos para clientes estratégicos que estão em fase de migração.

@return __lTAFdbLegacy - Informa se o banco de dados é legado (tafdblegacy = 1)

@Author Evandro Oliveira
@Since 07/10/2022
@Version 1.0
/*/
//-------------------------------------------------------------------
Function TAFisBDLegacy()

	If __lTAFdbLegacy == Nil
		__lTAFdbLegacy := ( GetPvProfString( GetEnvServer(),"tafdblegacy","0",getAdv97()) == "1" )
	EndIf

Return __lTAFdbLegacy

//-----------------------------------------------------------------------
/*/{Protheus.doc} OneOne
	@author Alexandre lima 
	@since 12/06/2023
	@param cPerapu  - Periodo do evento S-1200 e S-1210
	@param cGCG     - Raiz do cnpj que vai ser integrado
	@param cFilEv   - Filial de envio das informações
	@param cCpf     - Cpf do funcionario
	Objetivo : Alteração do cFilant caso o registro já tenha sido integrado 
    anteriormente em filial diferente no mesmo periodo para aglutinação quando o 
    de para de filiais estiver 1 X 1
/*/
//-----------------------------------------------------------------------
Function OneOne(cPerapu as character , cCGC as character, cFilEv as character, cCpf as character, cAlias as character)
    
	Local aSM0      as array
	Local cAliasQry as character
    Local cQuery    as character
	Local Nx        as numeric

	cAliasQry 	:= GetNextAlias()
    cQuery      := ""
	Nx          := 0

	If __cCGC != cCGC

		__cCGC := cCGC
		aSM0   := FWLoadSM0()

		For nX := 1 To Len(aSM0)
		
			If cCGC $ aSM0[nX][18]

				__cGroup := aSM0[nX][1]
	
				If Empty( __cFilOne )
					__cFilOne := "'" + Padr(aSM0[nX][2], TamSx3("C1E_FILTAF")[1]) + "'"
				Else
					__cFilOne += ", '" + Padr(aSM0[nX][2], TamSx3("C1E_FILTAF")[1]) + "'"
				EndIf

			EndIf
		Next Nx

	EndIf

    cQuery := " SELECT " + cAlias + "." + cAlias + "_FILIAL AS FILIAL, " + cAlias + "." + cAlias + "_ID AS ID "
	cQuery += " FROM " + RetSqlName( cAlias ) + " " + cAlias
	cQuery += " WHERE " + cAlias + "." + cAlias + "_PERAPU = '" + StrTran(cPerapu, "-", "" ) + "' "
    cQuery += " AND " + cAlias + "." + cAlias + "_FILIAL IN (" + __cFilOne + ") "
	cQuery += " AND " + cAlias + "." + cAlias + "_CPF = '" + cCpf + "' "
    cQuery += " AND " + cAlias + "." + cAlias + "_ATIVO = '1' " 
    cQuery += " AND D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias &cAliasQry

    DbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())

	If !(cAliasQry)->(EOF())

        If (cAliasQry)->FILIAL != xFilial( cAlias )
            cFilant := (cAliasQry)->FILIAL
            cFilEv  := __cGroup + (cAliasQry)->FILIAL
        EndIf

	EndIf

	(cAliasQry)->(DbCloseArea())
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} verifyDelModelRows
	Deleta linhas do Model caso seja solicitada operação de alteração

	@type Function
	@author Fabio Mendonca
	@since 02/10/2023
	@version 1.0
	@param cModelName, Character, Código do Modelo MVC
	@param nOpc, Numeric, Opcao a ser realizada ( 3 = Inclusao, 4 = Alteracao, 5 = Exclusao )
	@param cPath, Character, Path do Nó no XML
/*/
//-------------------------------------------------------------------
Function verifyDelModelRows( cModelName as Character, nOpc as Numeric, cPath as Character )

	Local nI as Numeric
	
	Default cPath := ""
	Default nOpc  := 0

	If nOpc == 4 .And. oDados:XPathHasNode( cPath )

		For nI := 1 to oModel:GetModel( cModelName ):Length()

			oModel:GetModel( cModelName ):GoLine( nI )
			oModel:GetModel( cModelName ):DeleteLine()

		Next nI

	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ConvertDate
    Converte a picture da data conforme o usuário logado

    @author rodrigo.nicolino
    @since 10/04/2024
    @version 1.0

    @param cDate, string, data 
	@param cIdUser, string, código do usuário logado
       
    @return cConvDate - Data convertida
/*/
//-------------------------------------------------------------------
Function ConvertDate( cDate as Character, cIdUser as Character )

	Local cConvDate := ""
	
	Default cDate := ""

	If Empty(cDate)

		cConvDate := ""

	Else

		cConvDate := Substr(cDate,7,2) + "/" + Substr(cDate,5,2) + "/" + Iif(FWSFALLUSERS({cIdUser}, {"USR_ANO"})[1][3] == "4", Substr(cDate,1,4), Substr(cDate,3,2))

	EndIf

Return cConvDate


//-------------------------------------------------------------------
/*/{Protheus.doc} getPicCache

@description Retorna a Picture de um campo usando cache 
@Param: cAlias - Alias da tabela
cField - Campo a ser pesquisado
@author Evandro Oliveira
@since 29/04/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function getPicCache( cAlias as Character , cField as Character)	

    Local cRet as Character
	Local nPos as Numeric

	cRet := ""
    nPos := 0

    If __aPicCache == Nil
        __aPicCache := {}
    EndIf

    If Len( __aPicCache ) > 0 
		nPos := aScan( __aPicCache, {|x|x[1] == cField} )
	EndIf 

	If nPos == 0
	    cRet := PesqPict( cAlias, cField )
        aAdd( __aPicCache,{cField,cRet} )
	Else 
		cRet := __aPicCache[nPos][2]
    EndIf 

Return cRet

//--------------------------------------------------------------------
/*/{Protheus.doc} FindRecibo

Procura numero do recibo a partir do valor na tag

@author Alexande lima
@since 08/08/2024
@version 1.0

@param cRecChv, caracter, Chave de pesquisa na tabela TAFXERP

/*/
//--------------------------------------------------------------------

Function FindRecibo( cRecChv as character, cEvento as character)

    Local cQry         as character
    Local cBanco       as character
    Local cAliasQry    as character
    Local cAliasTafKey as character
	Local cFldsIndex   as character
	Local cChaveEvt    as character
	LocaL nI           as numeric
	Local nTamCampo    as numeric
	Local nPosChave    as numeric
	Local lFound       as logical

    Default cRecChv := ""
	
    lFound        := .F.
    cTAFKEY       := ""
    cQry          := ""
	cChaveEvt     := ""
    cBanco        := Upper(TcGetDb())
    cAliasQry     := GetNextAlias()  
    cAliasTafKey  := ""
	nPosChave     := 1
	
	aTafRotn := TAFRotinas( cEvento,4,.F.,2)

    If !Empty(aTafRotn)
			
		cAlias		:= aTafRotn[ 3 ]
		cNmFun		:= aTafRotn[ 1 ]
		nIndProt	:= aTafRotn[ 13 ]
		nIndApp		:= aTafRotn[ 10 ]
		cCmpTrab	:= aTafRotn[ 11 ]
		
		dbSelectArea( cAlias )
		
		( cAlias )->( dbSetOrder( nIndApp ) )
	
		cFldsIndex := ( cAlias )->( IndexKey() )
		cFldsIndex := StrTran( cFldsIndex	, "DTOS("		, "" )
		cFldsIndex := StrTran( cFldsIndex	, "STR("		, "" )
		cFldsIndex := StrTran( cFldsIndex	, "DESCEND("	, "" )
		cFldsIndex := StrTran( cFldsIndex	, ")"			, "" )            
		aFldsIndex := Str2Arr( cFldsIndex 	, "+" )
			
		For nI:= 1 To Len( aFldsIndex )

			
			If !(aFldsIndex[nI] == (cAlias + "_FILIAL") .Or. aFldsIndex[nI] == (cAlias + "_ATIVO"))

				nTamCampo := GetSx3Cache(aFldsIndex[nI],"X3_TAMANHO")
				cChaveEvt += Substr(cRecChv,nPosChave,nTamCampo)
				nPosChave += nTamCampo

			EndIf

		Next

		If !Empty(cChaveEvt) .And. ( cAlias )->( msSeek( xFilial( cAlias ) + cChaveEvt + '1' ) ) 

			cRecChv    := ( cAlias )->&( cAlias + "_PROTUL" )
			lFound := .T.

		EndIf
			
		If !lFound //Realiza a procura pelo TAFKEY
			
			cQry += "SELECT TAFALIAS, TAFRECNO FROM TAFXERP TAFXERP "
			cQry += "	WHERE TAFALIAS = '" + cAlias + "'"

			If cBanco == "ORACLE"
				cQry += "   AND TAFXERP.TAFKEY IN ( '" + Padr(cRecChv, 100) + "' ) "
			Else
				cQry += "   AND TAFXERP.TAFKEY IN ( '" + cRecChv + "' ) "
			EndIf

			cQry += "   AND TAFXERP.TAFRECNO <> '0' "
			cQry += "   AND TAFXERP.D_E_L_E_T_ = '' "
			cQry += "   ORDER BY R_E_C_N_O_ DESC"
			
			cQry := ChangeQuery(cQry)
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasQry, .F., .T. )

			If !Empty((cAliasQry)->TAFALIAS)

				cAliasTafKey := (cAliasQry)->TAFALIAS
							
				(cAliasTafKey)->(dbGoTo((cAliasQry)->TAFRECNO))
				
				cRecChv		:= ( cAliasTafKey )->&( cAliasTafKey + "_PROTUL" )
				
			EndIf
			
			(cAliasQry)->(dbCloseArea())

		EndIf

	EndIf

Return cRecChv

//--------------------------------------------------------------------
/*/{Protheus.doc} getVerLayout

Retorna o layout para salvar nos campos _LAYOUT.

@author Daniele Sakamoto
@since 10/02/2025
@version 1.0

/*/
//--------------------------------------------------------------------
Function getVerLayout()

    Local cEsocial   as Character
	Local cVerLay	 as Character
	Local cLayValid  as Character


	cEsocial    := SuperGetMV("MV_TAFVLES")
	cVerLay		:= ''
	cLayValid 	:= "S_01_00_00|S_01_01_00|S_01_02_00|S_01_03_00"

	cVerLay := IIf(cEsocial $ cLayValid, cEsocial, "S_01_00_00")
	

Return cVerLay
