#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PLSA260EVDEF //MATA035EvDef
Classe Responsavel pelo Evento de validações e
atualizações do Cadastro de Grupo do Grupo Familiar
@author    Totver
@since     12/08/2019
/*/
Class PLSA260EVDEF From FwModelEvent

	Data auMovStatus As Array
	Data oModel As Object

	Method New() Constructor
	Method AfterTTS(oModel, cIdModel)
	Method After(oSubModel, cModelId, cAlias, lNewRecord)
	Method ModelPreVld(oModel, cModelId)
	Method ModelPosVld(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Totver
@since     12/08/2019
/*/
Method new() Class PLSA260EVDEF
	
	self:oModel := Nil
	self:auMovStatus:= {}

Return Self

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do  após a transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Totver
@since     12/08/2019
/*/

Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PLSA260EVDEF
	
Return .T.


/*/{Protheus.doc} ModelPreVld
Metodo responsavel por realizar a pre validação do modelo
@author    Totver
@since     12/08/2019
/*/
Method ModelPreVld( oModel, cModelId ) Class PLSA260EVDEF
	Local nOperation := oModel:GetOperation()
	Local aArea      := GetArea()
	Local aAreaBA3   := BA3->(GetArea())
	Local aAreaBA1   := BA1->(GetArea())
	Local nContProds := 0
	Local oBA3
	Local oBA1
	Local cMatricOld := "AUTO"
	Local cCodInt    := Substr(BQC->BQC_CODIGO,1,4) //00010002
	Local cCodEmp    := BQC->BQC_CODEMP
	Local cMatricNew := ""

	If cModelID == "BA3DETAIL" .AND. nOperation == MODEL_OPERATION_INSERT
		If lJuridico .AND. Empty(oModel:GetValue( 'BA3DETAIL',  'BA3_CODPLA')) .AND. oModel:GetValue( 'BA3DETAIL',  'BA3_TIPOUS') == '2'
			BT6->( dbSetorder(1) )
			If BT6->( MsSeek(xFilial("BT6")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)) )
				nRegBT6 := BT6->( Recno() )
				While !BT6->(Eof()) .and. BT6->BT6_CODINT+BT6->BT6_CODIGO+BT6->BT6_NUMCON+;
						BT6->BT6_VERCON+BT6->BT6_SUBCON+BT6->BT6_VERSUB == BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
					nContProds++
					BT6->( dbSkip() )
				Enddo
				If nContProds == 1
					BT6->( dbGoto(nRegBT6) )
					oModel:LoadValue( 'BA3DETAIL',  'BA3_CODPLA',AllTrim(BT6->BT6_CODPRO))
					oModel:LoadValue( 'BA3DETAIL',  'BA3_VERSAO',AllTrim(BT6->BT6_VERSAO))
					oModel:LoadValue( 'BA3DETAIL',  'BA3_DESPLA',Substr(Posicione("BI3",1,xFilial("BI3")+SUBSTR(cKeySubCon,1,4)+BT6->(BT6_CODPRO+BT6_VERSAO),"BI3_DESCRI"),1,30))
					BT9->( dbSetorder(01) )
					If BT9->( MsSeek(xFilial("BT9")+BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)))
						oModel:LoadValue( 'BA3DETAIL',  'BA3_FORPAG',AllTrim(BT9->BT9_CODFOR) )
					Endif
					oModel:LoadValue( 'BA3DETAIL',  'BA3_RATSAI',AllTrim(BT6->BT6_RATSAI))
					oModel:LoadValue( 'BA3DETAIL',  'BA3_DESMEN',BT6->BT6_DESMEN)

					PLSA260GCMvc(oModel)

					If !IsInCallStack("PL260MVC01")//Desvio para automação
						oView := FwViewActive()
						oView:Refresh()
					EndIf

				Endif
			Endif
		Endif


		RestArea(aAreaBA3)
		RestArea(aAreaBA1)

	Endif

	RestArea(aArea)

Return .T.


//Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PLSA260EVDEF
//Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
@author    Totver
@since     12/08/2019
/*/
Method ModelPosVld( oModel, cModelId ) Class PLSA260EVDEF	

	Local cCodInt := oModel:GetValue("BA3DETAIL","BA3_CODINT")
	Local cCodEmp := oModel:GetValue("BA3DETAIL","BA3_CODEMP")
	Local cMatric := oModel:GetValue("BA3DETAIL","BA3_MATRIC")
	Local dtIncFamilia := oModel:GetValue("BA3DETAIL","BA3_DATBAS")
	Local cCodPla := oModel:GetValue("BA3DETAIL","BA3_CODPLA")
	Local cVerPla := oModel:GetValue("BA3DETAIL","BA3_VERSAO")
	Local cCodNemp := oModel:GetValue("BA3DETAIL","BA3_CONEMP")
	Local cVerCon := oModel:GetValue("BA3DETAIL","BA3_VERCON")
	Local cSubCon := oModel:GetValue("BA3DETAIL","BA3_SUBCON")
	Local cVerSub := oModel:GetValue("BA3DETAIL","BA3_VERSUB")
	Local cTipous := oModel:GetValue("BA3DETAIL","BA3_TIPOUS")
	Local dInclusao := oModel:GetValue("BA1MASTER","BA1_DATINC") //INCLUSÃO BENEFICIARIO
	Local cTipusu := oModel:GetValue("BA1MASTER","BA1_TIPUSU")// T-TITULAR D-DEPENDENTE
	Local cGraupa := oModel:GetValue("BA1MASTER","BA1_GRAUPA")
	Local cEstCiv := oModel:GetValue("BA1MASTER","BA1_ESTCIV")
	Local cSexo := oModel:GetValue("BA1MASTER","BA1_SEXO")
	Local cDatNas := oModel:GetValue("BA1MASTER","BA1_DATNAS")
	Local cMatVid := oModel:GetValue("BA1MASTER","BA1_MATVID")

	Local nOperation := oModel:GetOperation()
	Local cIdModel := oModel:GetId()
	Local cMatricNew := "AUTO"

	Local _nH := NIL
	Local lRet := .T.

	Local aAreaBA1 := BA1->(GetArea())
	Local cCodTit := GetNewPar("MV_PLCDTIT","T")
	Local cCodUsu := oModel:GetModel('BA1MASTER'):GetValue('BA1_TIPUSU')
	Local cMatTit := ""
	Local lfindBG9 := Type('lAmbos') == 'L' .And. lAmbos

	If nOperation == MODEL_OPERATION_VIEW .or. nOperation == MODEL_OPERATION_DELETE
		Return(.T.)
	EndIF

	If !Empty(M->BA3_GRPFAM) .And. M->BA1_TIPUSU == "T"
		Help("", 1, "VALID", Nil, STR0297, 1, 0)
		Return .F.
	EndIf

	//Validação da data de inclusão do Titular e do Dependente
	IF cTipusu == GetNewPar("MV_PLCDTIT")
		IF dInclusao <> dtIncFamilia
			Help(,, "Atenção!",,"A data de inclusão do TITULAR não pode ser diferente da data de inclusão da família.",1, 0,,,,,,{"Informe a data de inclusão do Beneficiario novamente"})
			Return .F.
		ENDIF
	ELSE
		IF dInclusao < BA3->BA3_DATBAS
			Help(,, "Atenção!",,"A data de inclusão do DEPENDENTE não pode ser menor do que a data de inclusão da família.",1, 0,,,,,,{"Informe a data de inclusão do Beneficiario novamente"})
			Return.F.
		ENDIF
	ENDIF

	//Verifica se o usuario possui permissao para usar o plano
	lRet := PLSPerm(cTipusu,cGraupa,cEstCiv,cSexo,nil,cCodInt,cCodPla,cVerPla,dInclusao,cDatNas,cCodEmp,cCodNemp,cVerCon,cSubCon,cVerSub,Iif(cTipous == "2",.T.,.F.),oModel,cMatric,cMatVid)

	If !lRet
		Help("",1,"PLSA260VLD")
		Return(.F.)
	Endif

	If lfindBG9
		BG9->(DbSetORder(1))
		BG9->(MsSeek(xFilial("BG9") + cCodInt + cCodEmp))
	Endif

	// Validando as funcionalidades
	If BG9->BG9_TIPO == "2" .And. !PLSA260Vld(.T.)
		Return(.F.)
	Endif

	//Inicio da Transacao...
	_nH := PLSAbreSem("PLSA260EVE.SMF")

	Begin Transaction

		// Valida se a versao do produto esta ativa
		DbSelectArea("BIL")
		BIL->(DbSetOrder(1))
		BIL->(MsSeek(xFilial("BIL") + cCodInt + cCodPla + cVerPla))

		If !Empty(DtoS(BIL->BIL_DATFIN)) .AND. BIL->BIL_DATFIN < dDataBase .And.;
				Aviso(OemtoAnsi(STR0071),OemtoAnsi(STR0178)+CHR(10)+CHR(13)+; //"Atenção"###"A versão do produto informada na família está encerrada."
				OemtoAnsi(STR0179),{OemtoAnsi(STR0085),OemtoAnsi(STR0086)},1) <> 1 //"Deseja continuar?"###"Sim"###"Não"
			lRet := .F.
			DisarmTransaction()		
		EndIf

		If nOperation == MODEL_OPERATION_INSERT .And. !IsNumeric(oModel:GetValue('BA1MASTER',  'BA1_MATRIC'))
			If 	cModelId == "PL260DEPMVC" // inclusao de dependennte
				cMatricNew := Substr(oModel:GetValue("BA3DETAIL", "MATTIT"),9,6)
			Else
				cMatricNew := PLPROXMAT(cCodInt,cCodEmp, cFilBA1)
			Endif

			//Preenche com a matrícula do titular do registro mencionado no BA3_GRPFAM
			// que está na memória para salvar no Grupo Familiar
			If cCodUsu <> cCodTit .And. !Empty(M->BA3_GRPFAM)
				BA1->(DbSetOrder(1))
				If BA1->(MsSeek(xFilial("BA1")+Substr(M->BA3_GRPFAM,1,14)+cCodTit))
					cMatTit := BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG+BA1->BA1_DIGITO
				EndIf
				RestArea(aAreaBA1)
			EndIf

			oModel:LoadValue( 'BA3DETAIL',  'BA3_MATRIC', cMatricNew)
			oModel:LoadValue( 'BA1MASTER',  'BA1_MATRIC', cMatricNew)
			oModel:LoadValue( 'BA1MASTER',  'BA1_CODEMP', cCodEmp)
			oModel:LoadValue( 'BA1MASTER',  'BA1_MUDFAI', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_INTERD', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_OPERES', PLSINTPAD())
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCANS', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCATE', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCEMI', '1')
			oModel:LoadValue( 'BA1MASTER',  'BA1_REEWEB', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_10ANOS', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_INSALU', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_INFCOB', '0')
			oModel:LoadValue( 'BA1MASTER',  'BA1_LOCSIB', '0')
			oModel:LoadValue( 'BA3DETAIL',  'BA3_GRPFAM', cMatTit)

			If oModel:getvalue('BA1MASTER','BA1_TIPUSU') <> GetNewPar("MV_PLCDTIT","T") .And. oModel:getvalue('BA1MASTER','BA1_TIPREG') == GetNewPar("MV_PLTRTIT","00") .And.;
					!Empty(oModel:getvalue('BA3DETAIL','BA3_GRPFAM'))

				oModel:LoadValue( 'BA1MASTER','BA1_TIPREG',"01")

			EndIf

			If oModel:GetValue( 'BA3DETAIL',  'BA3_TIPOUS') == '2' //Iif(lJuridico,"2","1")
				oModel:LoadValue( 'BA3DETAIL',  'BA3_CONEMP', AllTrim(BQC->BQC_NUMCON))
				oModel:LoadValue( 'BA3DETAIL',  'BA3_VERCON', AllTrim(BQC->BQC_VERCON))
				oModel:LoadValue( 'BA3DETAIL',  'BA3_SUBCON', AllTrim(BQC->BQC_SUBCON))
				oModel:LoadValue( 'BA3DETAIL',  'BA3_VERSUB', AllTrim(BQC->BQC_VERSUB))
				oModel:LoadValue( 'BA1MASTER',  'BA1_CONEMP', AllTrim(BQC->BQC_NUMCON))
				oModel:LoadValue( 'BA1MASTER',  'BA1_VERCON', AllTrim(BQC->BQC_VERCON))
				oModel:LoadValue( 'BA1MASTER',  'BA1_SUBCON', AllTrim(BQC->BQC_SUBCON))
				oModel:LoadValue( 'BA1MASTER',  'BA1_VERSUB', AllTrim(BQC->BQC_VERSUB))
			EndIF
			// Calcula o digito verificador
			oModel:LoadValue( 'BA1MASTER',  'BA1_DIGITO', Modulo11(PLSINTPAD()+cCodEmp+cMatricNew+oModel:GetValue( 'BA1MASTER',  'BA1_TIPREG')))

		Endif
	End Transaction

	If !lRet
		Help(NIL, NIL, "HELP", NIL, "Operação Cancelada!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Execute Novamente!"})
		Return lRet
	Endif

	PLSFechaSem(_nH,"EVE")


Return lRet

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/
Method AfterTTS(oModel, cIdModel) Class PLSA260EVDEF

	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
	Local nContProds := 0
	Local nContForma := 0
	Local cIdModel := oModel:GetId()
	Local lDocNotEnt := .F.
	Local lAutomato := IsInCallStack("PL260MVC01") .or. IsInCallStack("PL260MVC02") //Automação
	Local lVinc := GetNewPar("MV_PLCAROP","0") <> 0
	DbSelectArea("BA1")
	SET FILTER TO
	BA1->(DbSetOrder(1))

	cCodInt	:=	BA1->BA1_CODINT
	cCodEmp	:=	BA1->BA1_CODEMP
	cMatric	:=	BA1->BA1_MATRIC
	cTipReg :=  BA1->BA1_TIPREG

	//Posiciono a BA3, pois necessito do CODPLA da familia
	BA3->(DbSetOrder(1))
	BA3->(DbGotop())

	BA3->(DbSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

	//Outras Validações apos commit
	If  nOperation == MODEL_OPERATION_INSERT .And. !PL260MVCOK(nOperation,oModel)
		Return(.F.)
	EndIf

	If nOperation == MODEL_OPERATION_INSERT //Verificar a origem da inclusão do beneficiário 
		BA1->(DbGoTop())
		If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))
			If ("BA1")->(FieldPos("BA1_ORIINC")) > 0
				BA1->(RecLock("BA1",.F.))
				BA1->BA1_ORIINC := 'PLSA260MVC'
				BA1->(Msunlock())
			EndIf
		EndIf

	EndIf

	If (!Empty(oModel:GetModel('BA3DETAIL'):GetValue('BA3_FORPAG')) .Or. BA1->BA1_TIPUSU <> "T") .and. (nOperation == MODEL_OPERATION_INSERT .Or.  nOperation == MODEL_OPERATION_DELETE .or. nOperation == MODEL_OPERATION_UPDATE)

		Begin Transaction
			
			if nOperation <> MODEL_OPERATION_DELETE
				//Atualização da faixa etaria
				if nOperation == MODEL_OPERATION_INSERT
					PLS260FAIXA( ,oModel:GetValue( 'BA3DETAIL',  'BA3_TIPOUS'),BA1->BA1_MATRIC)
				endif

				//Documentos Obrigatórios
				P260ChkDoc(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_TIPREG,BA1->BA1_TIPUSU,BA1->BA1_GRAUPA,BA1->BA1_SEXO,Calc_Idade( dDataBase , BA1->BA1_DATNAS ),nOperation,@lDocNotEnt)

				//Carrega taxa de adesao...
				if BA1->BA1_TIPUSU == "T"
					PL260AdeMVC(nOperation,BA1->BA1_TIPUSU,BA1->BA1_MATRIC)
				endif

				//Carrega Grupos Determinados..
				if BA1->BA1_TIPUSU == "T"
					PL260GrpDet(nOperation,BA1->BA1_TIPUSU,BA1->BA1_MATRIC)
				endif

				//Carrega Classe de Carência..
				if BA1->BA1_TIPUSU == "T"
					PL260ClaCar(nOperation,BA1->BA1_TIPUSU,BA1->BA1_MATRIC)
				endif

			endif
				
			// Opcionais da Familia
			If lVinc .And. BA1_TIPUSU == "T"
				PL260OpcMVC(nOperation, .T.)
			ElseIf lVinc .And. BA1->BA1_TIPUSU <> "T"
				PL260OpcMVC(nOperation, .F.)
			EndIf

			//Habilita a cobrança de novos dependentes no ato da inclusão.
			If GetNewPar("MV_PLSCBND","0") == "1" .and. cIdModel == "PL260DEPMVC"
				P260CbInAto(oModel)
			Endif

			//Gerando informação SA1/BA1/BA3/BTS
			GerSincronismo()

		End Transaction

		If lDocNotEnt .and. nOperation == MODEL_OPERATION_INSERT

			If lAutomato .or. MsgYesNo("Existem documentos obrigatorios não entregues. Deseja confirmar a entrega?")
				If (!lAutomato,FWExecView('','PLSA260BCP', 4,, { || .T. } ) <> 0 ,.T.)
			Endif

		Endif


	EndIF

Return .T.

/*/{Protheus.doc} GerSincronismo
Função chamada para atualizar SA1/BA3/BTS/BA1 funcionada como sincronixador de cadastro
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/

Function GerSincronismo(oModel)

	Local cTipTit 		:= SuperGetMv("MV_PLCDTIT")
	Local aAreaBA1		:= BA1->(GetArea())
	Local lExiOutResp	:= .F.
	Local nRecOutResp	:= BA1->(Recno())
	Local nRecRespTit	:= BA1->(Recno())
	Local cCriaCli		:= GetNewPar("MV_PLSFMCL","1")
	Local cCodSA1		:=''
	Local cLojSa1		:=''

	Default oModel = nil
	DbSelectArea("BA1")
	SET FILTER TO
	BA1->(DbSetOrder(1))

	cCodInt	:=	BA1->BA1_CODINT
	cCodEmp	:=	BA1->BA1_CODEMP
	cMatric	:=	BA1->BA1_MATRIC

	//Descobrindo o responsavel da familia ou o endereco de origem

	//Descobrindo o responsavel da familia ou o endereco de origem
	If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))

		While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric
			If BA1->BA1_TIPUSU	= cTipTit
				If cCriaCli ='1'
					// Gravando Cliente a partir do titular
					SA1->( dbSetorder(3) )
					If !SA1->( MsSeek(xFilial("SA1")+BA1->BA1_CPFUSR) )
						SA1->(RecLock("SA1",.T.))
						SA1->A1_FILIAL := xFilial("SA1")
						cVlCod         := CriaVar("A1_COD")
						cVlLoj         := CriaVar("A1_LOJA")
						cCodSa1        := If(!Empty(cVlCod),cVlCod,GetSX8Num("SA1","A1_COD"))
						cLojSa1        := If(!Empty(cVlLoj),cVlLoj,StrZero(1,TamSx3("A1_LOJA")[1]))

						SA1->A1_COD    := cCodSA1
						SA1->A1_LOJA   := cLojSA1
						SA1->A1_TIPO   := "F"
						PlsSinc("PLSA260","BA1","SA1",NIL,.T.,BA1->(RECNO()),NIL,NIL,SA1->(RECNO()))
						SA1->(MsUnLock())
						ConfirmSX8()


					Else
						PlsSinc("PLSA260","BA1","SA1",NIL,.T.,BA1->(RECNO()),NIL,NIL,SA1->(RECNO()))

						/*	If oModel <> nil
						oModel:GetModel("BA3MASTER"):LoadValue("BA3_CODCLI"	,SA1->A1_COD)
						oModel:GetModel("BA3MASTER"):LoadValue("BA3_LOJA"	,SA1->A1_LOJA)
						Endif	*/

					Endif
					If BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
						// Gravando familia
						BA3->(RecLock("BA3",.F.))
						BA3->BA3_CODCLI = SA1->A1_COD
						BA3->BA3_LOJA	= SA1->A1_LOJA
						If BA3->BA3_TIPOUS == '1'
							// Se tratando de pessoa Fisica ja gravo o nivel
							BA3->BA3_COBNIV = "1"
						ElseIf BA3->BA3_TIPOUS == '2' .and. !Empty(BA3->BA3_CODCLI) .and. !Empty(BA3->BA3_LOJA)
							//Caso seja pessoa Jurídica e tenha associado o cliente
							BA3->BA3_COBNIV = "1"
						EndIF

						BA3->(MsUnLock())

					Endif
				Endif

			Endif


			If  (BA1->BA1_ORIEND $ '1|5' .And. BA1->BA1_TIPUSU	== cTipTit ) .Or. (BA1->BA1_ORIEND $ '1|5' .And. BA1->BA1_RESFAM = '1' )

				cCodInt	:=	BA1->BA1_CODINT
				cCodEmp	:=	BA1->BA1_CODEMP
				cMatric	:=	BA1->BA1_MATRIC
				cCepUsr :=	BA1->BA1_CEPUSR
				cEndere	:= 	BA1->BA1_ENDERE
				cBairro :=	BA1->BA1_BAIRRO
				cMunici :=	BA1->BA1_MUNICI
				cEstado :=	BA1->BA1_ESTADO
				cCodMun	:=	BA1->BA1_CODMUN
				cNrEnd 	:=	BA1->BA1_NR_END
				cComend	:=	BA1->BA1_COMEND
				cTipEnd :=	BA1->BA1_TIPEND
				cResExt	:=	BA1->BA1_RESEXT
				nRecRespTit	:= BA1->(Recno())
				Exit
			Endif
			BA1->(DbSkip())
		Enddo
	Endif

	//Apos Veiricar o endereco do titular ou responsavel sera aplciado nos usuarios da mesma famila caso esteja configurado BA1->BA1_ORIEND	 ou BA1_RESFAM
	BA1->(DbGoTop())
	If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))

		While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric

			If  BA1->BA1_ORIEND $ '1|5' .And.  nRecRespTit <> BA1->(Recno())

				BA1->(RecLock("BA1",.F.))
				BA1->BA1_CODINT	:= cCodInt
				BA1->BA1_CODEMP	:= cCodEmp
				BA1->BA1_MATRIC	:= cMatric
				BA1->BA1_CEPUSR	:= cCepUsr
				BA1->BA1_ENDERE	:= cEndere
				BA1->BA1_BAIRRO	:= cBairro
				BA1->BA1_MUNICI	:= cMunici
				BA1->BA1_ESTADO	:= cEstado
				BA1->BA1_CODMUN	:= cCodMun
				BA1->BA1_NR_END := cNrEnd
				BA1->BA1_COMEND	:= cComend
				BA1->BA1_TIPEND	:= cTipEnd
				BA1->BA1_RESEXT	:= cResExt
				BA1->(Msunlock())
			Endif

			If BA1->BA1_RESFAM = '1' .And. BA1->BA1_TIPUSU	<> cTipTit .and. !Empty(BA1->BA1_DATBLO)
				lExiOutResp:= .T.
				nRecOutResp:= BA1->(Recno())
			Endif


			BA1->(DbSkip())
		Enddo
	Endif


	If GetNewPar("MV_PLRESFA",.F.) .And. BA1->( FieldPos("BA1_RESFAM") ) > 0 .And. lExiOutResp
		BA1->(DbGoTo(nRecOutResp))

		cCodInt	:=	BA1->BA1_CODINT
		cCodEmp	:=	BA1->BA1_CODEMP
		cMatric	:=	BA1->BA1_MATRIC
		cCepUsr :=	BA1->BA1_CEPUSR
		cEndere	:= 	BA1->BA1_ENDERE
		cBairro :=	BA1->BA1_BAIRRO
		cMunici :=	BA1->BA1_MUNICI
		cEstado :=	BA1->BA1_ESTADO
		cCodMun	:=	BA1->BA1_CODMUN
		cNrEnd 	:=	BA1->BA1_NR_END
		cComend	:=	BA1->BA1_COMEND
		cTipEnd :=	BA1->BA1_TIPEND
		cResExt	:=	BA1->BA1_RESEXT
		BA1->(DbGoTop())

		If BA1->((DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric)))

			While !BA1->(Eof()) .and. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == xFilial('BA1')+cCodInt+cCodEmp+cMatric

				If BA1->(Recno()) <> nRecOutResp .And. BA1->BA1_ORIEND $ '1|5'

					BA1->(RecLock("BA1",.F.))
					BA1->BA1_CODINT	:= cCodInt
					BA1->BA1_CODEMP	:= cCodEmp
					BA1->BA1_MATRIC	:= cMatric
					BA1->BA1_CEPUSR	:= cCepUsr
					BA1->BA1_ENDERE	:= cEndere
					BA1->BA1_BAIRRO	:= cBairro
					BA1->BA1_MUNICI	:= cMunici
					BA1->BA1_ESTADO	:= cEstado
					BA1->BA1_CODMUN	:= cCodMun
					BA1->BA1_NR_END := cNrEnd
					BA1->BA1_COMEND	:= cComend
					BA1->BA1_TIPEND	:= cTipEnd
					BA1->BA1_RESEXT	:= cResExt
					BA1->(Msunlock())
				Endif

				BA1->(DbSkip())
			Enddo
		Endif

	Endif


	RestArea(aAreaBA1)

Return .T.

/*/{Protheus.doc}  PLSA260OK()
Função chamada para validar os itens na inclusão da familia
Realizo as integrações
@author    Totver
@since     12/08/2019
/*/

Function PL260MVCOK(nOpc,oModel)

	Local  lRet			:= .T.

	// Parametro controla a criacao automatica de cliente na inclusao da familia |
	Local cCriaCli	:= GetNewPar("MV_PLSFMCL","1")
	Local cIdModel	:= oModel:GetId()
	Local lAutomato := IsInCallStack("PL260MVC01") .or. IsInCallStack("PL260MVC02") //Automação
	Local lIncLogin := GetNewPar("MV_PILOGAU",.F.)
	Local nOperation := oModel:GetOperation()

	If BA3->BA3_TIPOUS == "2" .and. lRet .And. cIdModel == "PLSA260MVC" // pessoa juridica
		BQC->(DbSetOrder(1))
		If BQC->(MsSeek(xFilial("BQC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)))
			BT5->(DbSetOrder(1))
			If BT5->(MsSeek(xFilial("BT5")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON)) )
				If BQC->BQC_OBRFAM == "1"  .And. BA3->BA3_COBNIV  # "1"
					If(!lAutomato,ApMsgAlert(OemtoAnsi(STR0070) ,OemtoAnsi(STR0071)),) //" O campo 'Cobranca neste nivel' deve ser preenchido com 1=Sim. "
					lRet := .F.
				ElseIf BQC->BQC_COBNIV <> "1" .And. BT5->BT5_COBNIV <> "1" .And. Empty(BG9->BG9_CODCLI)
					If(!lAutomato,ApMsgAlert(OemtoAnsi(STR0070)+Chr(13)+OemtoAnsi(STR0171) ,OemtoAnsi(STR0071)),) //" O campo 'Cobranca neste nivel' deve ser preenchido com 1=Sim. "###"A cobrança não foi definida em nenhum dos possíveis níveis (grupo/empresa, contrato ou subcontrato)."
					If(!lAutomato,FWExecView('Edição','PLSA260FD1COB', MODEL_OPERATION_UPDATE,, { || .T. } ),)
				EndIf
			EndIf
		EndIf
	Elseif BA3->BA3_TIPOUS == "1" .And. lRet // pessoa Fisica
		If Empty(BA3->BA3_CODCLI) .And. cCriaCli <> "1"
			If(!lAutomato,MsgAlert(OemtoAnsi(STR0068)+OemtoAnsi(STR0069)),) //  //"A criacao automatica de clientes esta desabilitada no paramentro MV_PLSFMCL, "##"e obrigatorio informa-lo manualmente juntamente com a data de vencimento"
			lRet := .F.
		Endif
	EndIf

	// Ponto de entrada para validacao de usuario para inclusao da familia.
	If lRet .and. ExistBlock("PLS260VU")
		lRet := Execblock("PLS260VU",.F.,.F.,{nOpc})
		If !lRet
			Return(.F.)
		EndIf
	EndIf

	// Valida se a versao do produto esta ativa
	DbSelectArea("BIL")
	BIL->(DbSetOrder(1))
	If (BA3->BA3_CODPLA <> M->BA3_CODPLA .Or.;
			BA3->BA3_VERSAO <> M->BA3_VERSAO) .And.;
			BIL->(MsSeek(xFilial("BIL") + M->BA3_CODINT + M->BA3_CODPLA + M->BA3_VERSAO))
		If !Empty(DtoS(BIL->BIL_DATFIN)) .AND. BIL->BIL_DATFIN < dDataBase .And.;
				If(!lAutomato,Aviso(OemtoAnsi(STR0071),OemtoAnsi(STR0178)+CHR(10)+CHR(13)+ OemtoAnsi(STR0179),{OemtoAnsi(STR0085),OemtoAnsi(STR0086)},1) <> 1,) ////"Atenção"###"A versão do produto informada na família está encerrada." ##"Deseja continuar?"###"Sim"###"Não"
			lRet := .F.
		EndIf
	EndIf

	If lIncLogin .AND. (BA3->BA3_REEWEB = '' .Or. BA3->BA3_REEWEB <> "") .AND. BA1->BA1_TIPUSU = "T" .AND. nOperation == MODEL_OPERATION_INSERT// Crio Login apenas para o Titular

        PIncLogin(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),,,,BA1->BA1_CPFUSR,BA1->BA1_EMAIL)

    Endif

Return(lRet)



/*/{Protheus.doc}  P260CbInAto()
Função chamada para  a cobrança de novos dependentes no ato dainclusão.
Realizo as integrações
@author    Totver
@since     12/12/2019
/*/


Function P260CbInAto(oModel)

	Local aUsrCobAto	:= {}
	Local aAux			:= {}
	Local cAnoFt 		:= StrZero(Year(oModel:GetModel('BA1MASTER'):GetValue('BA1_DATINC')),4)
	Local cMesFt 		:= StrZero(Month(oModel:GetModel('BA1MASTER'):GetValue('BA1_DATINC')),2)
	Local lFatura 		:= .F.


	aadd(aUsrCobAto,BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+oModel:GetModel('BA1MASTER'):GetValue('BA1_TIPREG')+oModel:GetModel('BA1MASTER'):GetValue('BA1_DIGITO'))

	aAux := PLS770NIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,If(BA3->BA3_TIPOUS=="1","F","J"),	BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB,1)

	If Len(aAux) > 0 .And. Len(aAux[1]) > 17
		cNiv := aAux[1][18]
		If cNiv == "1" // Empresa
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP
		ElseIf cNiv == "2" //Nivel contrato
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON
		ElseIf cNiv == "3"  //Nivel subcontrato
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB
		ElseIf cNiv == "4" //Nivel familia
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		ElseIf cNiv == "5" //Usuario
			cChv := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
		EndIf

		BBT->(DbSetOrder(Val(cNiv)))
		If BBT->(MsSeek(xFilial("BBT")+cNiv+cChv+cAnoFt+cMesFt))
			lFatura := .T.
		EndIf

	Else
		//Caso nao consiga pegar o nivel de cobranca, faz o tratamento fixo na Familia como ja existia...
		BBT->(dbSetOrder(4))
		If BBT->(MsSeek(xFilial("BBT")+"4"+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+cAnoFt+cMesFt))
			lFatura := .T.
		EndIf

	EndIf

	If !lFatura .And. !(Empty(cAnoFt) .Or. Empty(cMesFt))
		Aviso("Atenção","Ainda não foi gerado o faturamento da competência "+cAnoFt+"/"+cMesFt+" para esta família."+CHR(10)+CHR(13)+;//Atenção###"Ainda não foi gerado o faturamento da competência "###" para esta família."
			"A cobrança do(s) dependente(s) incluso(s) será processada ao gerar a cobrança da família na rotina de faturamento.",{"Ok"},2) //"A cobrança do(s) dependente(s) incluso(s) será processada ao gerar a cobrança da família na rotina de faturamento."###"Ok"
	ElseIf Len(aUsrCobAto) > 0 .And.(BA3->BA3_TIPOUS == "1" .or. (BA3->BA3_TIPOUS <> '1' .AND. BA3->BA3_COBNIV == '1') ) .And.	lFatura .And.;
			(Aviso("A cobrança não foi definida em nenhum dos possíveis níveis (grupo/empresa, contrato ou subcontrato).","Deseja cobrar os novos dependentes incluidos neste momento ?",{"Sim","Não"},1)==1) // "Deseja cobrar os novos dependentes incluidos neste momento ?"

		PLSCBMSINC(aUsrCobAto,.T.,BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),'4',cAnoFt,cMesFt,2)
		lMsgDepInc := .F.
	EndIf



Return


/*/{Protheus.doc}  P260ChkDoc()
Função chamada para  tratamento de documentos obrigatorios
Realizo as integrações
@author    Totver
@since     12/12/2019
/*/

Function P260ChkDoc(cCodInt,cCodEmp,cMatric,cTpRg,cTipUsu,cGrauPar,cSexo,nIdade,nOperation,lDocNotEnt)

	Local aArea   := GetArea()
	LOCAL cSQL
	LOCAL cNumCon := BA1->BA1_CONEMP
	LOCAL cVerCon := BA1->BA1_VERCON
	LOCAL cSubCon := BA1->BA1_SUBCON
	LOCAL cVerSub := BA1->BA1_VERSUB
	LOCAL cCodPla := BA3->BA3_CODPLA
	LOCAL cVerPla := BA3->BA3_VERSAO
	LOCAL nAcha   := 0
	Local lFlag	  := .F.
	Local oModelBCP := nil
	Default lDocNotEnt	:=.F.

	DbSelectArea("BCP")
	DbSetOrder(1)

	oModelBCP := FWLoadModel("PLSA260BCP")

	oModelBCP:SetDescription( "Inclusão de Documentos" )
	oModelBCP:SetOperation(nOperation)
	oModelBCP:activate(.T.)

	oBA1 := oModelBCP:getModel( 'BA1MASTER' )
	oBCP := oModelBCP:getModel( 'BCPDETAIL' )

	aSaveLines := FWSaveRows()
	nLine:= 1

	//Posiciona nos documentos definidos no Sub Contrato...
	BCO->(DbSetOrder(1))
	if BCO->(MsSeek(xFilial("BCO")+cCodInt+cCodEmp+cNumCon+cVerCon+cSubCon+cVerSub))
		nAcha := 1
	endif

	If nAcha == 0
		BQP->(DbSetOrder(1))
		If BQP->(MsSeek(xFilial("BQP")+cCodInt+cCodPla+cVerPla))
			nAcha := 2
		EndIf
	endif
	If nAcha == 1

		cSQL := "SELECT  BCO_CODOPE, BCO_CODEMP, BCO_CODDOC, BCO_TIPUSR, BCO_GRAUPA, BCO_SEXO, BCO_IDAINI,BCO_IDAFIN,BCO_DOCOBR FROM "+RetSQLName("BCO")+" WHERE "
		cSQL += "BCO_FILIAL = '"+xFilial("BCO")+"' AND "
		cSQL += "BCO_CODOPE = '"+cCodInt+"' AND "
		cSQL += "BCO_CODEMP = '"+cCodEmp+"' AND "
		cSQL += "BCO_NUMCON = '"+cNumCon+"' AND "
		cSQL += "BCO_VERCON = '"+cVerCon+"' AND "
		cSQL += "BCO_SUBCON = '"+cSubCon+"' AND "
		cSQL += "BCO_VERSUB = '"+cVerSub+"' AND "
		cSQL += " D_E_L_E_T_= ''"

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBCO", .T., .T.)

		TrbBCO->(DBGoTop())
		oBCP:GoLine(nLine)

		While !TrbBCO->(Eof())
			oBCP:LoadValue("BCP_FILIAL", xFilial("BCP"))
			oBCP:LoadValue("BCP_CODDOC", TrbBCO->(BCO_CODDOC))
			oBCP:LoadValue("BCP_ENTREG", TrbBCO->(BCO_DOCOBR))
			oBCP:LoadValue("BCP_CODOPE", TrbBCO->(BCO_CODOPE))
			oBCP:LoadValue("BCP_CODEMP", TrbBCO->(BCO_CODEMP))
			oBCP:LoadValue("BCP_MATRIC", BA1->BA1_MATRIC)
			oBCP:LoadValue("BCP_TIPREG", BA1->BA1_TIPREG)
			oBCP:LoadValue("BCP_DATINC", Date())
			oBCP:LoadValue("BCP_DOCOBR", TrbBCO->(BCO_DOCOBR))
			oBCP:LoadValue("BCP_DESCRI", Posicione("BD2",1,xFilial("BD2")+TrbBCO->(BCO_CODDOC),"BD2_DESCRI"))

			If TrbBCO->(BCO_DOCOBR) == '1' .And. TrbBCO->(BCO_DOCOBR) == '0'
				lDocNotEnt	:=.T.
			Endif

			TrbBCO->(DbSkip())
			If !TrbBCO->(Eof())
				nLine := oBCP:AddLine()
			Else
				If oModelBCP:VldData()
					oModelBCP:CommitData()
				Else
					aError := oModelBCP:GetErrorMessage()
				EndIf
			Endif
		Enddo
		TrbBCO->(DbCloseArea())
	Elseif nAcha == 2

		cSQL := "SELECT BQP_CODIGO, BQP_VERSAO, BQP_CODDOC, BQP_TIPUSR, BQP_GRAUPA, BQP_SEXO, BQP_IDAINI, BQP_IDAFIN, BQP_DOCOBR FROM "+RetSQLName("BQP")+" WHERE "
		cSQL += "BQP_FILIAL = '"+xFilial("BQP")+"' AND "
		cSQL += "BQP_CODIGO = '"+cCodInt+cCodPla+"' AND "
		cSQL += "BQP_VERSAO = '"+cVerPla+"' AND "
		cSQL += " D_E_L_E_T_= ' '"

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TrbBCN", .T., .T.)


		While !TrbBCN->(Eof())
			oBCP:LoadValue("BCP_FILIAL", xFilial("BCP"))
			oBCP:LoadValue("BCP_CODDOC", TrbBCN->BQP_CODDOC)
			oBCP:LoadValue("BCP_ENTREG", If(TrbBCN->BQP_DOCOBR=='1','0','1'))
			oBCP:LoadValue("BCP_CODOPE", BA1->BA1_CODINT)
			oBCP:LoadValue("BCP_CODEMP", BA1->BA1_CODEMP)
			oBCP:LoadValue("BCP_MATRIC", BA1->BA1_MATRIC)
			oBCP:LoadValue("BCP_TIPREG", BA1->BA1_TIPREG)
			oBCP:LoadValue("BCP_DOCOBR", TrbBCN->BQP_DOCOBR)
			oBCP:LoadValue("BCP_DESCRI", Posicione("BD2",1,xFilial("BD2")+TrbBCN->(BQP_CODDOC),"BD2_DESCRI"))

			If TrbBCN->(BQP_DOCOBR) == '1' .And. TrbBCN->BQP_DOCOBR == '1'
				lDocNotEnt	:=.T.
			Endif

			TrbBCN->(DbSkip())

			If !TrbBCN->(Eof())
				nLine := oBCP:AddLine()
			Else
				If oModelBCP:VldData()
					oModelBCP:CommitData()
				Else
					aError := oModelBCP:GetErrorMessage()
				EndIf
			Endif

		Enddo
		TrbBCN->(DbCloseArea())
	Endif

	RestArea(aArea)

Return

/*/{Protheus.doc} PLS260FAIXA
Função para atualização da forma de cobranca pessoa fisica ou juridica
Realizo as integrações
@author    Totver
@since     18/02/2019
/*/
Function PLS260FAIXA(nOperation,cTipUsu,cMatric)

	Local	oModelBjk 	:= FwLoadModel("PLSA260BJK")
	Local	cChave		:=''
	Local 	lRet 		:= .F.
	Local	cCodOpe 	:= BA3->BA3_CODINT
	Local 	cCodEmp		:= BA3->BA3_CODEMP
	Local 	cMatric		:= BA3->BA3_MATRIC
	Local 	cForCob

	Default nOperation := 4
	Default cTipUsu	:= BA1->BA1_TIPUSU
	Default cMatric := BA1->BA1_MATRIC

	oModelBjk:SetOperation(nOperation)
	oModelBjk:SetDescription( "Forma de Cobrança" )
	oModelBjk:Activate()

	cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
	If nOperation == MODEL_OPERATION_UPDATE
		If cTipUsu == "1" // Pessoa Fisica - Forma de Cobranca
			BJ3->(DbSetOrder(1))
			If BJ3->(DbSeek(xFilial("BJ3") + BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)))
				while !BJ3->(eof()) .and. Substr(BJ3->BJ3_CODIGO,1,4)+Substr(BJ3->BJ3_CODIGO,5,4)+BJ3->(BJ3_VERSAO+BJ3_CODFOR) == BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
					cForCob := BJ3->BJ3_CODFOR
					BJ1->(MsSeek(xFilial("BJ1") + cForCob))
					
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_FILIAL', xFilial('BJK'))
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_CODOPE' , PLSINTPAD())
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_CODEMP' , BA3->BA3_CODEMP)
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_MATRIC' , BA3->BA3_MATRIC)
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_CODFOR' , BJ3->BJ3_CODFOR)   
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_DESFOR' , BJ1->BJ1_DESCRI)
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_AUTOMA' , "1")

					BJ3->( dbSkip() )

					If oModelBjk:VldData()
						lRet := FWFormCommit(oModelBjk)
					Endif
				EndDo
			EndIf

		ElseIf cTipUsu =="2"	// Pessoa Juridica - Forma de Cobranca
			dbSelectarea("BT9")
			BT9->(DbSetOrder(1))
			If BT9->(DbSeek(xFilial("BT9") + BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB+BA3->BA3_CODPLA+BA3->BA3_VERSAO+BA3->BA3_FORPAG))
				While !BT9->(Eof()) .and. Substr(BT9->BT9_CODIGO,1,4)+Substr(BT9->BT9_CODIGO,5,4)+BT9->(BT9_NUMCON+BT9_VERCON+;
					BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO) == BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+;
						BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)
					cForCob := BT9->BT9_CODFOR
					BJ1->(MsSeek(xFilial("BJ1") + cForCob))

					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_FILIAL', xFilial('BJK'))
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_CODOPE' , PLSINTPAD())
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_CODEMP' , BA3->BA3_CODEMP)
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_MATRIC' , BA3->BA3_MATRIC)
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_CODFOR' , BT9->BT9_CODFOR)   
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_DESFOR' , BJ1->BJ1_DESCRI)
					oModelBjk:SetValue( 'BJKDETAIL', 'BJK_AUTOMA' , "1")

					BT9->( dbSkip() )

				EndDo

				If oModelBjk:VldData()
					lRet := FWFormCommit(oModelBjk)
				Endif
			EndIf
		EndIf
	EndIf
	
	If lRet
		If BJK->(MsSeek(xFilial("BJK")+BJK->(cCodOpe+cCodEmp+cMatric+cForCob)))
			if cForCob == "108"
				PLFAISALB1C(nOperation)
			else 
				PLFAIETABBU(nOperation)
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} PL260FSalMVC
Substitui a função PL260Adesao
Sugere as formas de cobranca de adesao de acordo produto
@author DEV TOTVS
@since 05/08/2019
@version P12
/*/
Function PL260AdeMVC(nOperation,cTipUsu,cMatric)

	Local	oModelBJL	:= FwLoadModel("PLSA260BJL")
	Local	lTipUsu		:=  Empty(BA3->BA3_SUBCON)
	Local 	lRet		:= .F.

	Default nOperation	:= 3
	Default cTipUsu		:= BA1->BA1_TIPUSU
	Default cMatric		:= BA1->BA1_MATRIC

	oModelBJL:SetOperation(MODEL_OPERATION_UPDATE)
	oModelBJL:SetDescription( "Taxa de Adesão" )
	oModelBJL:Activate()

	BJL->(DbSetOrder(1))
	BFX->(DbSetOrder(1))

	If lTipUsu	// Pessoa Fisica - Taxa de Adesao

		dbSelectarea("BRY")
		BRY->(DbSetOrder(1))
		If BRY->(DbSeek(	xFilial("BRY") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO + BA3->BA3_FORCTX))

			oModelBJL:SetValue("BJLDETAIL","BJL_CODFOR",BA3->BA3_FORCTX)

			If oModelBJL:VldData()
				lRet := FWFormCommit(oModelBJL)
			Endif
		EndIF

	Else	// Pessoa Juridica - Taxa de Adesao

		BR6->(DbSetOrder(1))
		If BR6->(DbSeek(	xFilial("BR6") + BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB + BA3->BA3_CODPLA + BA3->BA3_VERSAO ))

			oModelBJL:SetValue("BJLDETAIL","BJL_CODOPE",BA3->BA3_CODINT)
			oModelBJL:SetValue("BJLDETAIL","BJL_MATRIC",cMatric)
			oModelBJL:SetValue("BJLDETAIL","BJL_CODFOR",BR6->BR6_CODFOR)
			oModelBJL:SetValue("BJLDETAIL","BJL_AUTOMA","1")
		Endif
		If oModelBJL:VldData()
			lRet := FWFormCommit(oModelBJL)
		Endif

	EndIF

Return lRet

/*/{Protheus.doc} PL260FSalMVC
Substitui a função PL260Adesao
Carrega grupos DeTerminado na Familia
@author DEV TOTVS
@since 05/08/2019
@version P12
/*/
Function PL260GrpDet(nOperation,cTipUsu,cMatric)

	Local oModelBFC := FwLoadModel("PLSA260BFC")
	Local oBBFC := oModelBFC:GetModel("BFCDETAIL")
	Local oBBVC := oModelBFC:GetModel("BVCDETAIL")
	Local lTipUsu :=  Empty(BA3->BA3_SUBCON)

	oModelBFC:SetOperation(MODEL_OPERATION_UPDATE)
	oModelBFC:SetDescription( "Grupos de Cobertura da Familia" )
	oModelBFC:Activate()

	BFC->(DbSetOrder(1))
	BVC->(DbSetOrder(1))

	If lTipUsu	// Pessoa Fisica - Carrega grupos DeTerminado

		dbSelectarea("BRV")
		BRV->(DbSetOrder(1))
		If BRV->(DbSeek(xFilial("BRV")+BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO))

			BHI->(DbSetOrder(1))
			while !BRV->(eof()) .and. BRV->(BRV_FILIAL+BRV_CODPLA+BRV_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)

				oBBFC:LoadValue("BFC_CODGRU",BRV->BRV_CODGRU)	

				If BHI->(DbSeek(xFilial("BHI")+BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO+BRV->BRV_CODGRU))

					while !BHI->(eof()) .and. BHI->(BHI_FILIAL+BHI_CODINT+BHI_CODPLA+BHI_VERSAO+BHI_CODGRU) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BRV->BRV_CODGRU)

						oBBVC:LoadValue("BVC_CODGRU"	,BHI->BHI_CODGRU)
						oBBVC:LoadValue("BVC_TIPO"		,BHI->BHI_TIPO)
						oBBVC:LoadValue("BVC_QTD"		,BHI->BHI_QTD)
						oBBVC:LoadValue("BVC_PERCOP"	,BHI->BHI_PERCOP)
						oBBVC:LoadValue("BVC_VALCOP"	,BHI->BHI_VLRCOP)
						oBBVC:LoadValue("BVC_VALUS" 	,BHI->BHI_VALUS)
						oBBVC:LoadValue("BVC_LIMFRA" 	,BHI->BHI_LIMFRA)
						oBBVC:LoadValue("BVC_CODTAB"	,BHI->BHI_CODTAB)
						oBBVC:LoadValue("BVC_TXADM" 	,BHI->BHI_TXADM)
						oBBVC:LoadValue("BVC_SOMCOM"	,BHI->BHI_SOMCOM)
						oBBVC:LoadValue("BVC_PAGATO"	,BHI->BHI_PAGATO)
						oBBVC:LoadValue("BVC_PAGRDA"	,BHI->BHI_PAGRDA)
						oBBVC:LoadValue("BVC_SOMPRO"	,BHI->BHI_SOMPRO)
						oBBVC:LoadValue("BVC_VIGINI"	,BHI->BHI_VIGDE)
						oBBVC:LoadValue("BVC_VIGFIN"	,BHI->BHI_VIGATE)

						BHI->(dbSkip())
						If  BHI->(BHI_FILIAL+BHI_CODINT+BHI_CODPLA+BHI_VERSAO+BHI_CODGRU) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BRV->BRV_CODGRU)
							oBBVC:AddLine()
						Endif

					EndDo
				Endif

				BRV->(dbSkip())
				If  BRV->(BRV_FILIAL+BRV_CODPLA+BRV_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
					oBBFC:AddLine()
				Endif

			EndDo

			If oModelBFC:VldData()
				lRet := FWFormCommit(oModelBFC)
			Endif

		EndIF

	Else	// Pessoa Juridica - - Carrega grupos DeTerminado

		dbSelectarea("BT7")
		BT7->(DbSetOrder(1))
		If BT7->(DbSeek(xFilial("BT7") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA)))

			BHF->(DbSetOrder(1))
			while !BT7->(eof()) .and. BT7->(BT7_FILIAL+BT7_CODINT+BT7_CODIGO+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB+BT7_CODPRO) == BA3->(BA3_FILIAL + BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB + BA3_CODPLA)

				oBBFC:LoadValue("BFC_CODGRU", BT7->BT7_CODGRU)

				If BHF->(DbSeek(xFilial("BHF") + BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BT7->BT7_CODGRU)))

					while !BHF->(eof()) .and. BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB+BHF_CODPRO+BHF_CODGRU) ==  BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BT7->BT7_CODGRU)

						oBBVC:LoadValue("BVC_CODGRU"	,BHF->BHF_CODGRU)
						oBBVC:LoadValue("BVC_TIPO"		,BHF->BHF_TIPO)
						oBBVC:LoadValue("BVC_QTD"		,BHF->BHF_QTD)
						oBBVC:LoadValue("BVC_PERCOP"	,BHF->BHF_PERCOP)
						oBBVC:LoadValue("BVC_VALCOP"	,BHF->BHF_VALCOP)
						oBBVC:LoadValue("BVC_VALUS" 	,BHF->BHF_VALUS)
						oBBVC:LoadValue("BVC_LIMFRA"	,BHF->BHF_LIMFRA)
						oBBVC:LoadValue("BVC_CODTAB"	,BHF->BHF_CODTAB)
						oBBVC:LoadValue("BVC_TXADM" 	,BHF->BHF_TXADM)
						oBBVC:LoadValue("BVC_SOMCOM"	,BHF->BHF_SOMCOM)
						oBBVC:LoadValue("BVC_PAGATO"	,BHF->BHF_PAGATO)
						oBBVC:LoadValue("BVC_PAGRDA"	,BHF->BHF_PAGRDA)
						oBBVC:LoadValue("BVC_SOMPRO"	,BHF->BHF_SOMPRO)
						oBBVC:LoadValue("BVC_VIGINI"	,BHF->BHF_VIGINI)
						oBBVC:LoadValue("BVC_VIGFIN"	,BHF->BHF_VIGFIN)
						oBBVC:LoadValue("BVC_FINATE"	,BHF->BHF_FINATE)

						BHF->(dbSkip())
						If  BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB+BHF_CODPRO+BHF_CODGRU) ==  BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BT7->BT7_CODGRU)
							oBBVC:AddLine()
						Endif

					EndDo

				EndIF

				BT7->(dbSkip())
				If  BT7->(BT7_FILIAL+BT7_CODINT+BT7_CODIGO+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB+BT7_CODPRO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA)
					oBBFC:AddLine()
				Endif

			EndDo

			If oModelBFC:VldData()
				lRet := FWFormCommit(oModelBFC)
			Endif

		EndIF

	EndIF

Return .T.

/*/{Protheus.doc} PL260OpcMVC
Substitui a função PL260Opc
Atualiza os opcionais/forma de cobrança de acordo com produto ou subcontrato
@author Dev TOTVS
@since 13/05/2022
@version P12
/*/

Function PL260OpcMVC(nOperation, lFamilia)

	Local oModelBF1 	:= FwLoadModel("PLS260BF1MVC") //Opcionais da Familia
	Local oModelBF4     := FwLoadModel("PLBF4OPCMVC") //Opcionais do Beneficiário
	Local oBBF1 		:= oModelBF1:GetModel("BF1DETAIL")
	Local oBBF4		    := oModelBF4:GetModel("MASTERBF4")
	Local oBBK0			:= oModelBF1:GetModel("BK0DETAIL")
	Local oBBYX			:= oModelBF4:GetModel("BYXDETAIL")
	Local lIncSoVinc 	:= GetNewPar("MV_PLCAROP","0") == 2 //0=Nenhum;1=Todos;2=Apenas Vinculados
	Local nCount 		:= 1
	Local nTamDescr 	:= TamSX3('BF1_DESPRO')[1]
	Local nTamDesBF4    := TamSX3('BF4_DESPRO')[1]
	Local nTamBK0		:= TamSX3('BK0_DESFOR')[1]
	Local nTamBYX		:= TamSX3('BYX_DESFOR')[1]
	Local lRet          := .F.
	Local lAchou		:= .F.

	If lFamilia
		oModelBF1:SetOperation(nOperation)
		oModelBF1:SetDescription("Opcionais")
		oModelBF1:Activate()
	EndIf

	BF1->(DbsetOrder(1))
	BF4->(DbsetOrder(1))
	BK0->(DbSetOrder(1))
	BYX->(DbSetOrder(1))
	BHS->(DbSetorder(1))

	cKeyBHS := 	BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB+;
		BA3_CODPLA + BA3_VERSAO)
	cKeyBF4 := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+BA1->BA1_TIPREG+BA1->BA1_CODPLA

	If M->BA3_TIPOUS <> "1" //2-Juridico
		// Posiciona nos opcionais do Subcontrato
		If BHS->( MsSeek(xFilial("BHS")+cKeyBHS) )
			cKeyBYX := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+BHS->(BHS_CODPLA+BHS_VERPLA)+BA1->BA1_TIPREG
			cKeyBK0 := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BHS->(BHS_CODPLA+BHS_VERPLA)
			While !BHS->( Eof() ) .and. BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB+;
					BHS_CODPRO+BHS_VERPRO) == cKeyBHS

				//Quando o parâmetro MV_PLCAROP for igual a 2, só trago os opcionais vinculados
				If lIncSoVinc .AND. BHS->BHS_TIPVIN == '0'
					BHS->( dbSkip() )
					Loop
				EndIf

				If lFamilia

					If !oBBF1:SeekLine({{"BF1_CODPRO", BHS->BHS_CODPLA}, {"BF1_VERPRO", BHS->BHS_VERPLA}})
						If(nCount > 1)
							oBBF1:AddLine()
						EndIF
						oBBF1:Goline( nCount )
						oBBF1:LoadValue("BF1_CODINT", BHS->BHS_CODINT)
						oBBF1:LoadValue("BF1_CODPRO", BHS->BHS_CODPLA)
						oBBF1:LoadValue("BF1_VERSAO", BHS->BHS_VERPLA)
						oBBF1:LoadValue("BF1_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BHS->BHS_CODINT+BHS->BHS_CODPLA,"BI3_DESCRI"), 1, nTamDescr))
						oBBF1:LoadValue("BF1_DATBAS", BA3->BA3_DATBAS)
						oBBF1:LoadValue("BF1_A300", "0")
						oBBF1:LoadValue("BF1_TIPVIN", BHS->BHS_TIPVIN)
						oBBF1:loadValue("BF1_MATRIC", BA3->BA3_MATRIC)
						nCount++

					EndIf
				Else
					If !BF4->(DBSeek(xFilial("BF4")+ cKeyBF4))
						oModelBF4:SetOperation(nOperation)
						oModelBF4:SetDescription("Opcionais do Beneficiário")
						oModelBF4:Activate()

						oBBF4:LoadValue("BF4_CODEMP", BA3->BA3_CODEMP)
						oBBF4:LoadValue("BF4_TIPREG", BA1->BA1_TIPREG)
						oBBF4:LoadValue("BF4_CODINT", BHS->BHS_CODINT)
						oBBF4:LoadValue("BF4_CODPRO", BHS->BHS_CODPLA)
						oBBF4:LoadValue("BF4_VERSAO", BHS->BHS_VERPLA)
						oBBF4:LoadValue("BF4_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BHS->BHS_CODINT+BHS->BHS_CODPLA,"BI3_DESCRI"), 1, nTamDesBF4))
						oBBF4:LoadValue("BF4_DATBAS", iif(empty(BA1->BA1_DATINC),CTOD(""),BA1->BA1_DATINC))
						oBBF4:LoadValue("BF4_A300", "0")
						oBBF4:LoadValue("BF4_TIPVIN", BHS->BHS_TIPVIN)
						oBBF4:SetValue("BF4_MATRIC", BA1->BA1_MATRIC)

						If BHS->BHS_TIPVIN == '1'
							If oModelBF4:VldData()
								lRet := FWFormCommit(oModelBF4)
							EndIF
							oModelBF4:DeActivate()
						EndIf
					EndIf
				EndIf

				If BHS->BHS_TIPVIN == '0' //Quando o opcional não é vinculado também leva as formas de cobrança
					BJW->(dbSetOrder(1))
					cKeyBJW := BHS->(BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB)+;
						BHS->(BHS_CODPRO+BHS_VERPRO+BHS_CODPLA+BHS_VERPLA)
					If BJW->(MsSeek(xFilial("BJW")+cKeyBJW))
						While !BJW->( Eof() ) .And. BJW->(BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC) == cKeyBJW

							If lFamilia
								If !BK0->(dbSeek(xFilial("BK0") + cKeyBK0))
									oBBK0:LoadValue("BK0_CODOPE", BHS->BHS_CODINT)
									oBBK0:LoadValue("BK0_CODEMP", BA3->BA3_CODEMP)
									oBBK0:LoadValue("BK0_MATRIC", BA3->BA3_MATRIC)
									oBBK0:LoadValue("BK0_VEROPC", BHS->BHS_VERPLA)
									oBBK0:LoadValue("BK0_CODOPC", BHS->BHS_CODPLA)
									oBBK0:LoadValue("BK0_CODFOR", BJW->BJW_CODFOR)
									oBBK0:LoadValue("BK0_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJW->BJW_CODFOR,"BJ1_DESCRI"),1, nTamBK0)

								EndIf
							Else
								If !BYX->(dbSeek(xFilial("BYX") + cKeyBYX))
									oBBYX:LoadValue("BYX_VEROPC", BHS->BHS_VERPLA)
									oBBYX:LoadValue("BYX_CODOPC", BHS->BHS_CODPLA)
									oBBYX:LoadValue("BYX_CODFOR", BJW->BJW_CODFOR)
									oBBYX:LoadValue("BYX_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJW->BJW_CODFOR,"BJ1_DESCRI"), 1, nTamBYX)
									oBBYX:LoadValue("BYX_TIPREG", BA1->BA1_TIPREG)
									oBBYX:LoadValue("BYX_RGIMP", '0')

									If oModelBF4:VldData()
										lRet := FWFormCommit(oModelBF4)
									EndIF

								EndIf
								oModelBF4:DeActivate()
							EndIf
							BJW->(dbSkip())
						EndDo
					EndIf
				EndIf
				BHS->(dbSkip())
			EndDo
		EndIf
	Else //1-Física
		cKeyBYX := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)+BT3->(BT3_CODPLA+BT3_VERPLA)+BA1->BA1_TIPREG
		cKeyBK0 := BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+BT3->(BT3_CODPLA+BT3_VERPLA)
		// Posiciona nos Opcionais do Produto
		If !BT3->( MsSeek(xFilial("BT3")+ BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
			Return .T.
		Else

			While !BT3->(Eof()) .And. BT3->(BT3_CODIGO+BT3_VERSAO) == BA3->BA3_CODINT+Iif(!lAchou, BA3->(BA3_CODPLA+BA3_VERSAO), BA1->(BA1_CODPLA+BA1_VERSAO))

				//Quando o parâmetro MV_PLCAROP for igual a 2, só trago os opcionais vinculados
				If lIncSoVinc .And. BT3->BT3_TIPVIN == '0'
					BT3->(dbSkip())
					Loop
				EndIf

				If lFamilia
					if empty( oModelBF1:getmodel('MasterBA1'):getvalue("BA1_MATRIC") )
						oModelBF1:getmodel('MasterBA1'):loadvalue("BA1_MATRIC", BA3->BA3_MATRIC)
					endif
					If !oBBF1:SeekLine({{"BF1_CODPRO", BT3->BT3_CODPLA}, {"BF1_VERPRO", BT3->BT3_VERPLA}})
						If(nCount > 1)
							oBBF1:AddLine()
						EndIF
						oBBF1:Goline( nCount )
						oBBF1:LoadValue("BF1_CODINT", BA3->BA3_CODINT)
						oBBF1:LoadValue("BF1_CODPRO", BT3->BT3_CODPLA)
						oBBF1:LoadValue("BF1_VERSAO", BT3->BT3_VERPLA)
						oBBF1:LoadValue("BF1_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BT3->(SubSTR(BT3_CODIGO,1,4)+BT3->(BT3_CODPLA+BT3_VERPLA)),"BI3_DESCRI"), 1, nTamDescr))
						oBBF1:LoadValue("BF1_DATBAS", BA3->BA3_DATBAS)
						oBBF1:LoadValue("BF1_A300", "0")
						oBBF1:LoadValue("BF1_TIPVIN", BT3->BT3_TIPVIN)
						oBBF1:loadValue("BF1_MATRIC", BA3->BA3_MATRIC)
						nCount++
					EndIf
				Else
					If !BF4->(DBSeek(xFilial("BF4")+ cKeyBF4))
						oModelBF4:SetOperation(nOperation)
						oModelBF4:SetDescription("Opcionais do Beneficiário")
						oModelBF4:Activate()

						oBBF4:LoadValue("BF4_CODEMP", BA1->BA1_CODEMP)
						oBBF4:LoadValue("BF4_TIPREG", BA1->BA1_TIPREG)
						oBBF4:LoadValue("BF4_CODINT", BA1->BA1_CODINT)
						oBBF4:LoadValue("BF4_CODPRO", BT3->BT3_CODPLA)
						oBBF4:LoadValue("BF4_VERSAO", BT3->BT3_VERPLA)
						oBBF4:LoadValue("BF4_DESPRO", SubSTR(Posicione("BI3",1,xFilial("BI3")+BT3->(SubSTR(BT3_CODIGO,1,4)+BT3->(BT3_CODPLA+BT3_VERPLA)),"BI3_DESCRI"), 1, nTamDesBF4))
						oBBF4:LoadValue("BF4_DATBAS", iif(empty(BA1->BA1_DATINC),CTOD(""),BA1->BA1_DATINC))
						oBBF4:LoadValue("BF4_A300", "0")
						oBBF4:LoadValue("BF4_TIPVIN", BT3->BT3_TIPVIN)
						oBBF4:SetValue("BF4_MATRIC", BA1->BA1_MATRIC)

						If BT3->BT3_TIPVIN == '1'
							If oModelBF4:VldData()
								lRet := FWFormCommit(oModelBF4)
							EndIF

							oModelBF4:DeActivate()
						EndIf
					EndIf
				EndIf

				If BT3->BT3_TIPVIN == '0' //Quando o opcional não é vinculado também leva as formas de cobrança

					BJY->(dbSetOrder(1))
					cKeyBJY := BT3->(BT3_CODIGO+BT3_VERSAO+BT3_CODPLA+BT3_VERPLA)

					If BJY->(MsSeek(xFilial("BJY")+cKeyBJY))
						While !BJY->( Eof() ) .and. BJY->(BJY_CODIGO+BJY_VERSAO+BJY_CODOPC+BJY_VEROPC) == cKeyBJY
							If lFamilia
								if !BK0->(dbSeek(xFilial("BK0") + cKeyBK0))
									oBBK0:LoadValue("BK0_CODFOR", BJY->BJY_CODFOR)
									oBBK0:LoadValue("BK0_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJY->BJY_CODFOR,"BJ1_DESCRI"),1, nTamBK0)

								EndIf
							Else
								If !BYX->(dbSeek(xFilial("BYX") + cKeyBYX))
									oBBYX:LoadValue("BYX_VEROPC", BT3->BT3_VERPLA)
									oBBYX:LoadValue("BYX_CODOPC", BT3->BT3_CODPLA)
									oBBYX:LoadValue("BYX_CODFOR", BJY->BJY_CODFOR)
									oBBYX:LoadValue("BYX_DESFOR", Posicione("BJ1",1,xFilial("BJ1")+BJY->BJY_CODFOR,"BJ1_DESCRI"), 1, nTamBYX)
									oBBYX:LoadValue("BYX_RGIMP", '0')
									oBBYX:LoadValue("BYX_TIPREG", BA1->BA1_TIPREG)

									If oModelBF4:VldData()
										lRet := FWFormCommit(oModelBF4)
									EndIF
								EndIf
								oModelBF4:DeActivate()
							EndIf
							BJY->(dbSkip())
						EndDo
					EndIF
				EndIf
				BT3->(dbSkip())
			EndDo
		EndIF
	EndIf
	If lFamilia
		If oModelBF1:VldData()
			lRet := FWFormCommit(oModelBF1)
		EndIf
	EndIF

Return lRet

/*/{Protheus.doc} Pl260BusCnpj
Função chamada para retornar o CNPJ do Contrato
@author Guilherme Carreiro da Silva
@since 13/01/2023
/*/
Function Pl260BusCnpj()
	Local cContrato := ""
	Local cCodInt := BA3->BA3_CODINT
	Local aRetCli := {}
	Local cCNPJ := ""

	cContrato :=	BA3->BA3_CODEMP+;
		BA3->BA3_CONEMP+;
		BA3->BA3_VERCON+;
		BA3->BA3_SUBCON+;
		BA3->BA3_VERSUB

	// Numero do CNPJ da pessoa juridica contratante do plano coletivo
	If BA3->BA3_TIPOUS <> "1" //Beneficiario PJ
		BQC->(dbSetOrder(1))
		If BQC->(MsSeek(xFilial("BQC")+BA3->BA3_CODINT+cContrato ))
			If Empty(BQC->BQC_CNPJ) .AND. Empty(BQC->BQC_CEINSS) .AND. Empty(BQC->BQC_CAEPF)
				If SA1->(MsSeek(xFilial("SA1")+BQC->(BQC_CODCLI+BQC_LOJA)))
					cCNPJ := IIf (CNPJ(SA1->A1_CGC),SA1->A1_CGC,"")
				Else
					aRetCli := PLSRETNCB(cCodInt,BA1->BA1_CODEMP,BA1->BA1_MATRIC,BA1->BA1_OPEORI)
					If aRetCli[1]
						If SA1->(msSeek(xFilial("SA1")+(BA3->(BA3_CODCLI+BA3_LOJA))))
							cCNPJ := IIf (CNPJ(SA1->A1_CGC),SA1->A1_CGC,"")
						EndIf
					EndIf
				EndIf
			Else
				cCNPJ := IIf (CNPJ(BQC->BQC_CNPJ),BQC->BQC_CNPJ,"")
			EndIf
		EndIf
	EndIf

Return cCNPJ

/*/ {Protheus.doc} PlGetBenFam
 Função para retorna os membros da Familia para a Verificação das Permissoes do Plano
@author Giovanna Charlo
@since 20/10/2023
@version 2410
/*/
Function PlGetBenFam(cCodInt,cCodEmp,cMatric,cMatVid,dDatInc)
	Local aArea := GetArea()
	local cAlias := GetNextAlias()
	Local aQtd := {}

	BeginSql Alias cAlias
		SELECT * 
		FROM %Table:BA1%
		WHERE  
		BA1_FILIAL = %Exp: xFilial("BA1")% AND
		BA1_CODINT = %Exp: cCodInt% AND
		BA1_CODEMP = %Exp: cCodEmp% AND
		BA1_MATRIC = %Exp: cMatric% AND
		%NotDel%
	EndSql
	
	While !(cAlias)->(Eof())
		If  Empty((cAlias)->BA1_DATBLO) .And. ((cAlias)->BA1_MATVID) <> cMatVid
			aadd(aQtd,{ (cAlias)->BA1_TIPUSU,(cAlias)->BA1_GRAUPA,;
					(cAlias)->BA1_SEXO,(cAlias)->BA1_ESTCIV,;
					dDatInc - Stod((cAlias)->BA1_DATNAS)})
		EndIf
		(cAlias)->( dbSkip())
	Enddo
	(cAlias)->(DBCloseArea())
	BA1->(RestArea(aArea))
Return aQtd

/*/ {Protheus.doc} PLFAIETABBU
 Função para retorna os dados da forma de cobrança quando for faixa etária
@author Gabriela Cattin
@since 12/12/2023
@version 2410
/*/
Function PLFAIETABBU(nOperation)
Local oModelBBU 	:= FwLoadModel("PLSA260BBU") 
Local oBBBU 		:= oModelBBU:GetModel("BBUDETAIL")
Local oBBFY		    := oModelBBU:GetModel("BFYDETAIL")
Local lRet          := .F.

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)

oModelBBU:SetOperation(nOperation)
oModelBBU:SetDescription( "Forma de Cobrança" )
oModelBBU:Activate()

If lJuridico
	//Verifico se existe Faixa etaria no SubContrato, caso exista, adiciono no grid da BBU
	BTN->(dbSetOrder(3))
	If BTN->(msSeek( xFilial('BTN')+cChave))
		while !BTN->(eof()) .and. BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO) ==;
								xFilial('BTN')+cChave

			oBBBU:SetValue( "BBU_FILIAL", xFilial('BBU'))
			oBBBU:SetValue( "BBU_CODOPE", BA3->BA3_CODINT)	
			oBBBU:SetValue( "BBU_CODEMP", BA3->BA3_CODEMP)
			oBBBU:SetValue( "BBU_MATRIC", BA3->BA3_MATRIC)
			oBBBU:SetValue( "BBU_CODFOR", BTN->BTN_CODFOR)
			oBBBU:SetValue( "BBU_CODFAI", BTN->BTN_CODFAI)
			oBBBU:SetValue( "BBU_TABVLD", BTN->BTN_TABVLD)
			oBBBU:SetValue( "BBU_TIPUSR", BTN->BTN_TIPUSR)
			oBBBU:SetValue( "BBU_GRAUPA", BTN->BTN_GRAUPA)
			oBBBU:SetValue( "BBU_SEXO"  , BTN->BTN_SEXO)
			oBBBU:SetValue( "BBU_IDAINI", BTN->BTN_IDAINI)
			oBBBU:SetValue( "BBU_IDAFIN", BTN->BTN_IDAFIN)
			oBBBU:SetValue( "BBU_VALFAI", BTN->BTN_VALFAI)
			oBBBU:SetValue( "BBU_FAIFAM", BTN->BTN_FAIFAM)
			oBBBU:SetValue( "BBU_QTDMIN", BTN->BTN_QTDMIN)
			oBBBU:SetValue( "BBU_QTDMAX", BTN->BTN_QTDMAX)
			oBBBU:SetValue( "BBU_REJAPL", BTN->BTN_REJAPL)
			oBBBU:SetValue( "BBU_AUTOMA", BTN->BTN_AUTOMA)
			oBBBU:SetValue( "BBU_PERREJ", BTN->BTN_PERREJ)
			oBBBU:SetValue( "BBU_ANOMES", BTN->BTN_ANOMES)
			oBBBU:SetValue( "BBU_VLRANT", BTN->BTN_VLRANT)

			BTN->(dbSkip())
			If BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO+BTN_CODFOR) ==	xFilial('BTN')+cChave+BA3_FORPAG
				oBBBU:AddLine()
			Endif
		EndDo  	

		//Verifico se Existe dados na BFT e carrego na BFY 
		BFT->(DBSetOrder(1))
		If BFT->(MsSeek( xFilial("BFT") + cChave+BTN->BTN_CODFOR+BTN->BTN_CODFAI))
			while !BFT->(eof()) .and. BFT->(BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB+BFT_CODPRO+BFT_VERPRO+BFT_CODFOR+BFT_CODFAI) ==	xFilial('BFT')+cChave+BTN->BTN_CODFOR+BTN->BTN_CODFAI
					
				oBBFY:SetValue( "BFY_FILIAL", xFilial('BFY'))
				oBBFY:SetValue( "BFY_CODOPE",	BA3->BA3_CODINT)	
				oBBFY:SetValue( "BFY_CODEMP",	BA3->BA3_CODEMP)
				oBBFY:SetValue( "BFY_MATRIC",	BA3->BA3_MATRIC)
				oBBFY:SetValue( "BFY_CODFOR",	BFT->BFT_CODFOR)
				oBBFY:SetValue( "BFY_CODFAI",	BFT->BFT_CODFAI)
				oBBFY:SetValue( "BFY_TIPUSR",	BFT->BFT_TIPUSR)
				oBBFY:SetValue( "BFY_GRAUPA",	BFT->BFT_GRAUPA)
				oBBFY:SetValue( "BFY_PERCEN",	BFT->BFT_PERCEN)
				oBBFY:SetValue( "BFY_VALOR" ,	BFT->BFT_VALOR)				
				oBBFY:SetValue( "BFY_QTDDE" ,	BFT->BFT_QTDDE)
				oBBFY:SetValue( "BFY_QTDATE" ,	BFT->BFT_QTDATE)
				oBBFY:SetValue( "BFY_TIPO"  ,	BFT->BFT_TIPO)
				oBBFY:SetValue( "BFY_DATDE" ,	BFT->BFT_DATDE)
				oBBFY:SetValue( "BFY_DATATE",	BFT->BFT_DATATE)
				oBBFY:SetValue( "BFY_AUTOMA",	BFT->BFT_AUTOMA)

				BFT->(dbSkip())
				If BFT->(BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB+BFT_CODPRO+BFT_VERPRO+BFT_CODFOR+BFT_CODFAI) ==	xFilial('BFT')+cChave+BTN->BTN_CODFOR+BTN->BTN_CODFAI
					oBBFY:AddLine()
				Endif
			EndDo
		EndIf			
	EndIf

	If oModelBBU:VldData()
		lRet := FWFormCommit(oModelBBU)
	EndIF

Else
	BB3->(DbSetOrder(1))
	If BB3->(msSeek( xFilial('BB3')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)))
		while !BB3->(eof()) .and. BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
			
			oBBBU:SetValue("BBU_CODOPE"	,BA3->BA3_CODINT)
			oBBBU:SetValue("BBU_CODEMP"	,BA3->BA3_CODEMP)
			oBBBU:SetValue("BBU_MATRIC"	,BA3->BA3_MATRIC)
			oBBBU:SetValue("BBU_CODFOR"	,BB3->BB3_CODFOR)
			oBBBU:SetValue("BBU_CODFAI"	,BB3->BB3_CODFAI)
			oBBBU:SetValue("BBU_TABVLD"	,Date())
			oBBBU:SetValue("BBU_TIPUSR"	,BB3->BB3_TIPUSR)
			oBBBU:SetValue("BBU_GRAUPA"	,BB3->BB3_GRAUPA)
			oBBBU:SetValue("BBU_SEXO"	,BB3->BB3_SEXO)
			oBBBU:SetValue("BBU_IDAINI"	,BB3->BB3_IDAINI)
			oBBBU:SetValue("BBU_IDAFIN"	,BB3->BB3_IDAFIN)
			oBBBU:SetValue("BBU_VALFAI"	,BB3->BB3_VALFAI)
			oBBBU:SetValue("BBU_FAIFAM"	,BB3->BB3_FAIFAM)
			oBBBU:SetValue("BBU_QTDMIN"	,BB3->BB3_QTDMIN)
			oBBBU:SetValue("BBU_QTDMAX"	,BB3->BB3_QTDMAX)
			oBBBU:SetValue("BBU_REJAPL"	,BB3->BB3_REJAPL)
			oBBBU:SetValue("BBU_AUTOMA"	, "1")
			oBBBU:SetValue("BBU_PERREJ"	,BB3->BB3_PERREJ)
			oBBBU:SetValue("BBU_ANOMES"	,BB3->BB3_ANOMES)

			BB3->(dbSkip())
			If BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
				oBBBU:AddLine()	
			Endif

		EndDo

		//Incluindo BFY
		BFS->(DbSetOrder(1))//BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI+BFS_TIPUSR
		If BFS->(MsSeek(xFilial("BFS")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG+BB3->BB3_CODFAI)))
			while !BFS->(eof()) .and. BFS->(BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)+BB3->BB3_CODFAI
				
				oBBFY:SetValue("BFY_FILIAL", xFilial('BFY'))
				oBBFY:SetValue("BFY_CODOPE", BA3->BA3_CODINT) //
				oBBFY:SetValue("BFY_CODEMP", BA3->BA3_CODEMP) //
				oBBFY:SetValue("BFY_MATRIC", BA3->BA3_MATRIC)
				oBBFY:SetValue("BFY_CODFOR", BFS->BFS_CODFOR)
				oBBFY:SetValue("BFY_CODFAI", BFS->BFS_CODFAI)
				oBBFY:SetValue("BFY_TIPUSR", BFS->BFS_TIPUSR)
				oBBFY:SetValue("BFY_GRAUPA", BFS->BFS_GRAUPA)
				oBBFY:SetValue("BFY_PERCEN", BFS->BFS_PERCEN)
				oBBFY:SetValue("BFY_VALOR" , BFS->BFS_VALOR)				
				oBBFY:SetValue("BFY_QTDDE" , BFS->BFS_QTDDE)
				oBBFY:SetValue("BFY_QTDATE", BFS->BFS_QTDATE)
				oBBFY:SetValue("BFY_TIPO"  , BFS->BFS_TIPO)
				oBBFY:SetValue("BFY_DATDE" , BFS->BFS_DATDE)
				oBBFY:SetValue("BFY_DATATE", BFS->BFS_DATATE)
				oBBFY:SetValue("BFY_AUTOMA", "1")

				BFS->(dbSkip())
				If BFS->(BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI) == xFilial('BFS')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)+BB3->BB3_CODFAI
					oBBFY:AddLine()
				EndIF
			EndDo
		EndIF
	EndIf

	If oModelBBU:VldData()
		lRet := FWFormCommit(oModelBBU)
	EndIF
EndIf   	

Return lRet

/*/ {Protheus.doc} PLFAISALB1C
 Função para retorna os dados da forma de cobrança quando for faixa salarial
@author Gabriela Cattin
@since 12/12/2023
@version 2410
/*/
Function PLFAISALB1C(nOperation)
Local oModelB1C 	:= FwLoadModel("PLSA260B1C") 
Local oBB1C 		:= oModelB1C:GetModel("B1CDETAIL")
Local lRet          := .F.
Local cChave 

BA3->(DbSetOrder(1))
BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)

oModelB1C:SetOperation(nOperation)
oModelB1C:SetDescription( "Forma de Cobrança" )
oModelB1C:Activate()

If lJuridico
	B1B->(dbSetOrder(1))
	If B1B->(msSeek( xFilial('B1B')+cChave))
		while !B1B->(eof()) .and. B1B->(B1B_FILIAL+B1B_CODIGO+B1B_NUMCON+B1B_VERCON+B1B_SUBCON+B1B_VERSUB+B1B_CODPRO+B1B_VERPRO+B1B_CODFOR) ==;
			xFilial('B1B')+cChave

			oBB1C:SetValue( "B1C_FILIAL", xFilial('B1C'))
			oBB1C:SetValue( "B1C_CODOPE", BA3->BA3_CODINT)	
			oBB1C:SetValue( "B1C_CODEMP", BA3->BA3_CODEMP)
			oBB1C:SetValue( "B1C_MATRIC", BA3->BA3_MATRIC)
			oBB1C:SetValue( "B1C_CODFOR", B1B->B1B_CODFOR)
			oBB1C:SetValue( "B1C_CODFAI", B1B->B1B_CODFAI)
			oBB1C:SetValue( "B1C_VLSLIN", B1B->B1B_VLSLIN)
			oBB1C:SetValue( "B1C_VLSLFN", B1B->B1B_VLSLFN)
			oBB1C:SetValue( "B1C_VALOR" , B1B->B1B_VALOR)
			oBB1C:SetValue( "B1C_AUTOMA", "1")
			oBB1C:SetValue( "B1C_VLRANT", B1B->B1B_VLRANT)
			oBB1C:SetValue( "B1C_GRAUPA", B1B->B1B_GRAUPA)
			oBB1C:SetValue( "B1C_FAIFAM", B1B->B1B_FAIFAM)
			oBB1C:SetValue( "B1C_ANOMES", AnoMes(Date()))
			oBB1C:SetValue( "B1C_SEXO",   B1B->B1B_SEXO)
			oBB1C:SetValue( "B1C_TIPUSR", B1B->B1B_TIPUSR)

			B1B->(dbSkip())
			If B1B->(B1B_FILIAL+B1B_CODIGO+B1B_NUMCON+B1B_VERCON+B1B_SUBCON+B1B_VERSUB+B1B_CODPRO+B1B_VERPRO+B1B_CODFOR) == xFilial('B1B')+cChave
				oBB1C:AddLine()
			Endif
		EndDo

		If oModelB1C:VldData()
			lRet := FWFormCommit(oModelB1C)
		EndIF
	EndIF

Else
	B1A->(DbSetOrder(1))
	If B1A->(msSeek( xFilial('B1A')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)))
		while !B1A->(eof()) .and. B1A->(B1A_FILIAL+B1A_CODIGO+B1A_VERSAO+B1A_CODFOR) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
			
			oBB1C:SetValue( "B1C_FILIAL", xFilial('B1A'))
			oBB1C:SetValue( "B1C_CODOPE", BA3->BA3_CODINT)	
			oBB1C:SetValue( "B1C_CODEMP", BA3->BA3_CODEMP)
			oBB1C:SetValue( "B1C_MATRIC", BA3->BA3_MATRIC)
			oBB1C:SetValue( "B1C_CODFOR", B1A->B1A_CODFOR)
			oBB1C:SetValue( "B1C_CODFAI", B1A->B1A_CODFAI)
			oBB1C:SetValue( "B1C_VLSLIN", B1A->B1A_VLSLIN)
			oBB1C:SetValue( "B1C_VLSLFN", B1A->B1A_VLSLFN)
			oBB1C:SetValue( "B1C_VALOR" , B1A->B1A_VALOR)
			oBB1C:SetValue( "B1C_AUTOMA", "1")
			oBB1C:SetValue( "B1C_VLRANT", B1A->B1A_VLRANT)
			oBB1C:SetValue( "B1C_GRAUPA", B1A->B1A_GRAUPA)
			oBB1C:SetValue( "B1C_FAIFAM", B1A->B1A_FAIFAM)
			oBB1C:SetValue( "B1C_ANOMES", B1A->B1A_ANOMES)
			oBB1C:SetValue( "B1C_SEXO",   B1A->B1A_SEXO)
			oBB1C:SetValue( "B1C_TIPUSR", B1A->B1A_TIPUSR)

			B1A->(dbSkip())
			If B1A->(B1A_FILIAL+B1A_CODIGO+B1A_VERSAO+B1A_CODFOR) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
				oBB1C:AddLine()	
			Endif

		EndDo

		If oModelB1C:VldData()
			lRet := FWFormCommit(oModelB1C)
		EndIF
	EndIf

EndIf
Return

/*/{Protheus.doc} PL260ClaCar
Carrega Classe de Carência na Familia
@author Guilherme Carreiro
@since 11/04/2024
@version P12
/*/
Function PL260ClaCar(nOperation,cTipUsu,cMatric)

	Local oModelBFJ := FwLoadModel("PLSA260BFJ")
	Local oBBFJ := oModelBFJ:GetModel("BFJDETAIL")
	Local lTipUsu	:=  Empty(BA3->BA3_SUBCON)

	oModelBFJ:SetOperation(MODEL_OPERATION_UPDATE)
	oModelBFJ:SetDescription( "Grupos de Cobertura da Familia" )
	oModelBFJ:Activate()

	BFJ->(DbSetOrder(1))
	
	If lTipUsu	// Pessoa Fisica - Carrega grupos DeTerminado

		dbSelectarea("BAN")
		BAN->(DbSetOrder(1))
		If BAN->(DbSeek(xFilial("BAN") + BA3->BA3_CODINT + BA3->BA3_CODPLA + BA3->BA3_VERSAO))

			while !BAN->(eof()) .and. BAN->(BAN_FILIAL+BAN_CODIGO+BAN_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)

				oBBFJ:LoadValue("BFJ_CLACAR",BAN->BAN_CLACAR)
				oBBFJ:LoadValue("BFJ_CARENC",BAN->BAN_QTDCAR)
				oBBFJ:LoadValue("BFJ_UNICAR",BAN->BAN_UNCAR)

				BAN->(dbSkip())
				If BAN->(BAN_FILIAL+BAN_CODIGO+BAN_VERSAO) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
					oBBFJ:AddLine()
				Endif

			EndDo

			If oModelBFJ:VldData()
				lRet := FWFormCommit(oModelBFJ)
			Endif

		EndIF

	Else	// Pessoa Juridica - - Carrega grupos DeTerminado

		dbSelectarea("BA6")
		BA6->(DbSetOrder(1))
		If BA6->(DbSeek(xFilial("BA6") + BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)))

			while !BA6->(eof()) .and. BA6->(BA6_FILIAL+BA6_CODINT+BA6_CODIGO+BA6_NUMCON+BA6_VERCON+BA6_SUBCON+BA6_VERSUB) == BA3->(BA3_FILIAL + BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_CONEMP + BA3->BA3_VERCON + BA3->BA3_SUBCON + BA3->BA3_VERSUB)

				oBBFJ:LoadValue("BFJ_CLACAR",BA6->BA6_CLACAR)
				oBBFJ:LoadValue("BFJ_CARENC",BA6->BA6_CARENC)
				oBBFJ:LoadValue("BFJ_UNICAR",BA6->BA6_UNICAR)

				BA6->(dbSkip())
				If  BA6->(BA6_FILIAL+BA6_CODINT+BA6_CODIGO+BA6_NUMCON+BA6_VERCON+BA6_SUBCON+BA6_VERSUB) == BA3->(BA3_FILIAL +BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB)
					oBBFJ:AddLine()
				Endif

			EndDo

			If oModelBFJ:VldData()
				lRet := FWFormCommit(oModelBFJ)
			Endif

		EndIF

	EndIF

Return .T.
