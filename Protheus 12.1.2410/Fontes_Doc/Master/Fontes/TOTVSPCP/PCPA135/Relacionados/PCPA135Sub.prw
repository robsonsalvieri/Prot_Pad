#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA135.CH"

Static scCRLF     := Chr(13) + Chr(10)

Static sl135Auto  := .F.
Static slReplica  := SuperGetMv("MV_PCPRLEP", .F., 2) == 1
Static snGGCOMP	  := GetSx3Cache("GG_COMP" , "X3_TAMANHO")
Static snGGGROPC  := GetSx3Cache("GG_GROPC", "X3_TAMANHO")
Static snGGOPC    := GetSx3Cache("GG_OPC"  , "X3_TAMANHO")
Static slMarca	  := .F.
Static soRecNo

/*/{Protheus.doc} P135Subst
Substituicao de componentes na Estrutura
@author Carlos Alexandre da Silveira
@since 25/02/2019
@version 1.0
@param 01 - aAutoCab  , array  , Array com as informações do cabeçalho do programa
                                 e com parâmetros adicionais para identificar alguns comportamentos do programa.
@param 02 - aAutoItens, array  , Array com as informações dos componentes que serão modificados.
                                 Para a operação de exclusão, este array não é considerado.
/*/
Function P135Subst(aAutoCab, aAutoItens)
	Local aArea      := GetArea()
	Local cCodOrig   := Criavar("GG_COMP" ,.F.)
	Local cCodDest   := Criavar("GG_COMP" ,.F.)
	Local cGrpOrig   := Criavar("GG_GROPC",.F.)
	Local cGrpDest   := Criavar("GG_GROPC",.F.)
	Local cDescOrig  := Criavar("B1_DESC" ,.F.)
	Local cDescDest  := Criavar("B1_DESC" ,.F.)
	Local cOpcOrig   := Criavar("GG_OPC"  ,.F.)
	Local cOpcDest   := Criavar("GG_OPC"  ,.F.)
	Local oSay
	Local oSay2
	Local lOk        := .F.
	Local lPyme      := Iif(Type("__lPyme") <> "U",__lPyme,.F.) //Variável lPyme utilizada para Tratamento do Siga PyME
	Local nPosCoOrig
	Local nPosGrOrig
	Local nPosOpOrig
	Local nPosCoDest
	Local nPosGrDest
	Local nPosOpDest
	Local oDlg
	Local oSize
	Local oSize2
	Local oSize3
	Local oProdOrig

	Default aAutoCab   := {}
	Default aAutoItens := {}

	If !Empty(aAutoCab)
		sl135Auto  := .T.
		nPosCoOrig := aScan(aAutoCab, {|x| x[1] == "GG_CODORIG"} )
		nPosGrOrig := aScan(aAutoCab, {|x| x[1] == "GG_GRPORIG"} )
		nPosOpOrig := aScan(aAutoCab, {|x| x[1] == "GG_OPCORIG"} )
		nPosCoDest := aScan(aAutoCab, {|x| x[1] == "GG_CODDEST"} )
		nPosGrDest := aScan(aAutoCab, {|x| x[1] == "GG_GRPDEST"} )
		nPosOpDest := aScan(aAutoCab, {|x| x[1] == "GG_OPCDEST"} )

		//Os campos de produto origem e destino devem ser preenchidos
		If nPosCoOrig >= 1 .And. nPosCoDest >= 1
			cCodOrig := PadR(aAutoCab[nPosCoOrig,2], snGGCOMP )
			cGrpOrig := PadR(aAutoCab[nPosGrOrig,2], snGGGROPC)
			cOpcOrig := PadR(aAutoCab[nPosOpOrig,2], snGGOPC  )
			cCodDest := PadR(aAutoCab[nPosCoDest,2], snGGCOMP )
			cGrpDest := PadR(aAutoCab[nPosGrDest,2], snGGGROPC)
			cOpcDest := PadR(aAutoCab[nPosOpDest,2], snGGOPC  )

			If P135SubOK(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest)
				P135PrSubs(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest, aAutoItens)
			EndIf
		EndIf
		sl135Auto := .F.
	Else
		dbSelectArea("SGG")
		DEFINE MSDIALOG oDlg FROM  140, 000 TO 385, 615 TITLE OemToAnsi(STR0225) PIXEL //"Substituição de Componentes"

		//Calcula dimensÃµes em linha
		oSize := FwDefSize():New(.T.,,,oDlg)
		oSize:AddObject( "LABEL1" 	,  100, 50, .T., .T. ) //Totalmente dimensionável
		oSize:AddObject( "LABEL2"   ,  100, 50, .T., .T. ) //Totalmente dimensionável
		oSize:lProp 	:= .T. //Proporcional
		oSize:aMargins 	:= { 6, 6, 6, 6 } //Espaço ao lado dos objetos 0, entre eles 3
		oSize:Process() 	   //Dispara os cálculos

		//Calcula dimensões em coluna
		oSize2 := FwDefSize():New()
		oSize2:aWorkArea := oSize:GetNextCallArea( "LABEL1" )
		oSize2:AddObject( "ESQ",  100, 50, .T., .T. ) //Totalmente dimensionável
		oSize2:AddObject( "DIR",  100, 50, .T., .T. ) //Totalmente dimensionável
		oSize2:lLateral := .T.
		oSize2:lProp 	:= .T. //Proporcional
		oSize2:aMargins := { 3, 3, 3, 3 } //Espaço ao lado dos objetos 0, entre eles 3
		oSize2:Process() 	   //Dispara os cálculos

		//Calcula dimensões em coluna
		oSize3 := FwDefSize():New()
		oSize3:aWorkArea := oSize:GetNextCallArea( "LABEL2" )
		oSize3:AddObject( "ESQ",  100, 50, .T., .T. ) //Totalmente dimensionável
		oSize3:AddObject( "DIR",  100, 50, .T., .T. ) //Totalmente dimensionável
		oSize3:lLateral := .T.
		oSize3:lProp 	:= .T. //Proporcional
		oSize3:aMargins := { 3, 3, 3, 3 } //Espaço ao lado dos objetos 0, entre eles 3
		oSize3:Process() 	   //Dispara os cálculos

		DEFINE SBUTTON oBtn FROM 800,800 TYPE 5 ENABLE OF oDlg
		@ oSize:GetDimension("LABEL1","LININI"), oSize:GetDimension("LABEL1","COLINI") TO oSize:GetDimension("LABEL1","LINEND"), oSize:GetDimension("LABEL1","COLEND");
			LABEL OemToAnsi(STR0226) OF oDlg PIXEL //"Componente Original"

		@ oSize:GetDimension("LABEL2","LININI"), oSize:GetDimension("LABEL2","COLINI") TO oSize:GetDimension("LABEL2","LINEND"), oSize:GetDimension("LABEL2","COLEND");
			LABEL OemToAnsi(STR0227) OF oDlg PIXEL //"Novo Componente"

		@ oSize2:GetDimension("ESQ","LININI")+10, oSize2:GetDimension("ESQ","COLINI")+30 MSGET oProdOrig VAR cCodOrig   F3 "SB1" Picture PesqPict("SGG","GG_COMP");
			Valid NaoVazio(cCodOrig) .And. ExistCpo("SB1",cCodOrig) .And. P135IniDsc(1,oSay,cCodOrig,cCodDest) SIZE 105,09 OF oDlg PIXEL

		If !lPyme
			@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+40 MSGET cGrpOrig   F3 "SGAPCP" Picture PesqPict("SGG","GG_GROPC");
				Valid Vazio(cGrpOrig) .Or. ExistCpo("SGA",cGrpOrig) SIZE 15,09 OF oDlg PIXEL

			@ oSize2:GetDimension("DIR","LININI")+10, oSize2:GetDimension("DIR","COLINI")+120 MSGET cOpcOrig   Picture PesqPict("SGG","GG_OPC");
				Valid If(!Empty(cGrpOrig),NaoVazio(cOpcOrig) .And.ExistCpo("SGA",cGrpOrig+cOpcOrig),Vazio(cOpcOrig)) SIZE 15,09 OF oDlg PIXEL
		EndIf

		@ oSize3:GetDimension("ESQ","LININI")+10, oSize3:GetDimension("ESQ","COLINI")+30 MSGET cCodDest   F3 "SB1" Picture PesqPict("SGG","GG_COMP");
			Valid NaoVazio(cCodDest) .And. ExistCpo("SB1",cCodDest)  .And. P135IniDsc(2,oSay2,cCodDest,cCodOrig) SIZE 105,9 OF oDlg PIXEL

		If !lPyme
			@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+40 MSGET cGrpDest   F3 "SGAPCP" Picture PesqPict("SGG","GG_GROPC");
				Valid Vazio(cGrpDest) .Or. ExistCpo("SGA",cGrpDest) SIZE 15,09 OF oDlg PIXEL

			@ oSize3:GetDimension("DIR","LININI")+10, oSize3:GetDimension("DIR","COLINI")+120 MSGET cOpcDest   Picture PesqPict("SGG","GG_OPC");
				Valid If(!Empty(cGrpDest),NaoVazio(cOpcDest).And.ExistCpo("SGA",cGrpDest+cOpcDest),Vazio(cOpcDest)) SIZE 15,09 OF oDlg PIXEL
		EndIf

		@ oSize2:GetDimension("ESQ","LININI")+24, oSize2:GetDimension("ESQ","COLINI")+33     SAY oSay Prompt cDescOrig  SIZE 130,6 OF oDlg PIXEL
		@ oSize3:GetDimension("ESQ","LININI")+24, oSize3:GetDimension("ESQ","COLINI")+33     SAY oSay2 Prompt cDescDest SIZE 130,6 OF oDlg PIXEL
		@ oSize2:GetDimension("ESQ","LININI")+12, oSize2:GetDimension("ESQ","COLINI")        SAY OemtoAnsi(STR0228)     SIZE 24,7  OF oDlg PIXEL //"Produto"

		If !lPyme
			@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI")    SAY RetTitle("GG_GROPC")   SIZE 42,13 OF oDlg PIXEL
			@ oSize2:GetDimension("DIR","LININI")+12, oSize2:GetDimension("DIR","COLINI")+85 SAY RetTitle("GG_OPC")     SIZE 30,7  OF oDlg PIXEL
		EndIf

		@ oSize3:GetDimension("ESQ","LININI")+12, oSize3:GetDimension("ESQ","COLINI")        SAY OemToAnsi(STR0228)     SIZE 24,7  OF oDlg PIXEL //"Produto"

		If !lPyme
			@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI")    SAY RetTitle("GG_GROPC") SIZE 42,13 OF oDlg PIXEL
			@ oSize3:GetDimension("DIR","LININI")+12, oSize3:GetDimension("DIR","COLINI")+85 SAY RetTitle("GG_OPC")   SIZE 30,7  OF oDlg PIXEL
		EndIf

		ACTIVATE MSDIALOG oDlg CENTER;
			ON INIT (EnchoiceBar(oDlg, {|| Iif(P135SubOK(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest), (lOk:=.T., oDlg:End()), lOk := .F.)} , {|| (lOk := .F., oDlg:End())} ),;
					oProdOrig:SetFocus())

		If lOk	//Processa substituição dos componentes
			Processa({|| P135PrSubs(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest) })
		EndIf
	EndIf


	//Remove lock's - fonte PCPA135EVDEF
	SGGUnLockR(,,soRecNo)
	soRecNo := Nil

	RestArea(aArea)

Return

/*/{Protheus.doc} P135SubOK
Validação final da Substituição de Pré-Estrutura
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@param 01 - cCodOrig, caracter, Codigo do produto origem
@param 02 - cGrpOrig, caracter, Grupo de opcionais origem
@param 03 - cOpcOrig, caracter, Opcionais do produto origem
@param 04 - cCodDest, caracter, Codigo do produto destino
@param 05 - cGrpDest, caracter, Grupo de opcionais destino
@param 06 - cOpcDest, caracter, Opcionais do produto destino
@return lRet, logico, False caso ocorra algum problema na validação True C.C.
/*/
Static Function P135SubOK(cCodOrig,cGrpOrig,cOpcOrig,cCodDest,cGrpDest,cOpcDest)
	Local lRet := .T.

	//Valida a utilização do conceito de versão da produção em conjunto com o conceito de componentes opcionais
	If AliasInDic("SVC") .And. (!Empty(cGrpDest) .Or. !Empty(cOpcDest))
		dbSelectArea("SVC")
		dbSetOrder(1)
		If SVC->(DbSeek(xFilial("SVC")))
			Help( ,  , "Help", ,  STR0271,;  //"Não é permitido utilizar a versão da produção em conjunto com o conceito de Componentes Opcionais."
			1, 0, , , , , , {STR0272})  //"Para a utilização dos opcionais, não pode haver versão de produção cadastrada."
			lRet := .F.
		EndIf
	EndIf

	Do Case
		Case Vazio(cCodOrig) .Or. !ExistCpo("SB1",cCodOrig)
			lRet := .F.
			Help('', 1, 'A200PRDORI')
		Case Vazio(cCodDest) .Or. !ExistCpo("SB1",cCodDest)
			lRet := .F.
			Help('', 1, 'A200PRDDES')
	EndCase

Return lRet

/*/{Protheus.doc} P135PrSubs
Monta markbrowse para seleção e substituição dos componentes
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@param 01 - cCodOrig, caracter, Codigo do produto origem
@param 02 - cGrpOrig, caracter, Grupo de opcionais origem
@param 03 - cOpcOrig, caracter, Opcionais do produto origem
@param 04 - cCodDest, caracter, Codigo do produto destino
@param 05 - cGrpDest, caracter, Grupo de opcionais destino
@param 06 - cOpcDest, caracter, Opcionais do produto destino
@param 07 - aAutoItens, array  , Array com as informações dos componentes que serão modificados.
                                 Para a operação de exclusão, este array não é considerado. 
/*/
Static Function P135PrSubs(cCodOrig, cGrpOrig, cOpcOrig, cCodDest, cGrpDest, cOpcDest, aAutoItens)
	Local aBackRotina  := Iif(Type("aRotina") != "U", aClone(aRotina), Nil)
	Local cFilSGG      := ""
	Local lPyme        := Iif(Type("__lPyme") <> "U", __lPyme, .F.)	//Variável lPyme utilizada para Tratamento do Siga PyME

	Private aDadosDest := {cCodDest, cGrpDest, cOpcDest}
	Private aRotina    := {  {STR0224,"P135DoSubs", 0 , 1} } 		//"Substituir"
	Private cCadastro  := OemToAnsi(STR0225)						//"Substituição de Componentes"
	Private cCodOrig2  := cCodOrig
	Private cMarca135  := ThisMark()
	Private lMarkAll   := .F.
	Private lHelpList  := .F.

	Default aAutoItens := {}

	If sl135Auto
		P135DoSubs("","","","","",aAutoItens)
	Else
		cFilSGG := "GG_FILIAL ='" + xFilial("SGG") + "' "
		cFilSGG += ".AND. GG_COMP ='" + cCodOrig + "' "

		If SuperGetMV("MV_APRESTR",.F.,.F.)
			cFilSGG += ".AND. GG_STATUS <> '5'"
			cFilSGG += ".AND. GrpEng('" +RetCodUsr() +"',SGG->GG_USUARIO)"
		EndIf

		If !lPyme
			cFilSGG += ".AND. GG_GROPC ='" + cGrpOrig + "' "
			cFilSGG += ".AND. GG_OPC ='" + cOpcOrig + "' "
		EndIf

		If !IsProdProt(cCodOrig) .And. !IsProdProt(cCodDest)
			cFilSGG += " .AND. 1 = 1 "
		Else
			cFilSGG += " .AND. 1 = 2 "
		EndIf

		//Realiza a filtragem
		dbSelectArea("SGG")
		SGG->(dbSetOrder(1))
		If !SGG->(MsSeek(xFilial("SGG")))
			Help(" ",1,"RECNO")
		Else
			//Monta o browse para a seleção
			oMark := FWMarkBrowse():New()
			oMark:SetAlias("SGG")
			oMark:SetDescription( OemToAnsi(STR0225) )	//"Substituição de Componentes"
			oMark:SetFieldMark( "GG_OK" )
			oMark:SetFilterDefault(cFilSGG)
			oMark:SetValid({|| ValidMarca() })
			oMark:SetAfterMark({|| RELockSGG() })
			oMark:SetAllMark({|| MarkAll(oMark) })
			oMark:Activate()
		EndIf
	EndIf

	//Restaura condição original
	dbSelectArea("SGG")
	RetIndex("SGG")
	dbClearFilter()
	aRotina := Iif(Type("aBackRotina")!="U", aClone(aBackRotina), Nil)

Return Nil

/*/{Protheus.doc} RELockSGG
Reloca a SGG após bug frame que remove o lock pré-existe em MarkBrowse
@author brunno.costa
@since 11/04/2019
@version 1.0
/*/
Static Function RELockSGG()
	If !SGG->(Eof()) .AND. !IsInCallStack("SHOWDATA") .AND. !IsInCallStack("LINEREFRESH")
		soRecNo := Iif(soRecNo == Nil, JsonObject():New(), soRecNo)
		If soRecNo[cValToChar(SGG->(RecNo()))]
			SGG->(SimpleLock())
		EndIf
	EndIf
Return


/*/{Protheus.doc} P135IniDsc
Inicializa a descrição dos códigos digitados
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@param 01 - nOpcao    , numerico , Indica se esta validando origem (1) ou destino (2)
@param 02 - oSay      , objeto   , Objeto say que deve ser atualizado
@param 03 - cProduto  , caracter , Codigo do produto digitado
@param 04 - cProdDesOr, caracter , Cod.do produto origem(nOpcao=2) ou destino(nOpcao=1)
@return lRet, logico, indica se o produto origem ja existe na estrutura do produto destino
/*/
Static Function P135IniDsc(nOpcao,oSay,cProduto,cProdDesOr)
	Local aEstruOrig   := {}
	Local lRet		   := .T.

	Default cProdDesOr := Criavar("GG_COMP", .F.)

	Private nEstru     := 0

	SB1->(MsSeek(xFilial("SB1")+cProduto))

	If nOpcao == 1
		cDescOrig:=SB1->B1_DESC

		//Preenche a descrição do produto
		oSay:SetText(cDescOrig)
	ElseIf nOpcao == 2
		cDescDest:=SB1->B1_DESC

		//Preenche a descrição do produto
		oSay:SetText(cDescDest)
	EndIf

	//Troca a cor do texto para vermelho
	oSay:SetColor(CLR_HRED,GetSysColor(15))

	If !Empty(cProdDesOr)
		//Os produtos origem e destino foram informados. Explode sempre o produto destino
		aEstruOrig := Estrut( If(nOpcao == 2,cProduto,cProdDesOr) ,1,Nil,.T.)

		//Verifica se o produto origem já existe na estrutura do produto destino
		If (aScan(aEstruOrig,{|x| x[3] == If(nOpcao == 2, cProdDesOr, cProduto) }) > 0)
			Help(' ',1,'A202NODES')
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ValidMarca
Valida a marcação de registros para substituição
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@return lRet, logico, indica se pode ou nao marcar o registro para substituição
/*/
Static Function ValidMarca()
	Local lExibHelp := .T.
	Local lRet      := .T.
	Local aBloqueio
	Local lInRefresh := IsInCallStack("LINEREFRESH")
	Local nRecno     := SGG->(Recno())

	If !lInRefresh
		SGG->(DbSkip())                       //Forca desposicianamento de registro
		SGG->(dbGoTo(nRecno))                 //Forca reposicionamento do registro
		If SGG->(Deleted()) .OR. SGG->(Eof()) //Verifica se o registro esta excluido ou se esta em EOF - sem registros dentro da condicao de filtro
			lRet := .F.
			SGG->(DbSkip())                   //Forca desposicianamento de registro
			SGG->(DbGoTop())                  //Posiciona no primeiro registro
			oMark:Refresh()                   //Atualiza MarkBrowse eliminando registros invalidos
			IF SGG->(Eof())
				//Não existem registros válidos para a substituição.
				//Reinicie o processo utilizando outro 'Produto Original'.
				Help( ,  , "Help", ,  STR0266, 1, 0, , , , , , {STR0267})
			Else
				//Este registro foi excluído por outro usuário.
				//Selecione outro registro e tente novamente.
				Help( ,  , "Help", ,  STR0268, 1, 0, , , , , , {STR0269})
			EndIf
		EndIf
	EndIf

	If lRet .and. !SGG->(Eof()) .AND. !IsInCallStack("SHOWDATA") .AND. !lInRefresh
		soRecNo := Iif(soRecNo == Nil, JsonObject():New(), soRecNo)
		If !oMark:IsMark(oMark:Mark())
			If SGG->(SimpleLock())                              //Bloqueou registro atual da SGG
				soRecNo[cValToChar(SGG->(RecNo()))] := .T.

			Else                                                //NAO Bloqueou registro atual da SGG
				lRet      := .F.
				If soRecNo[cValToChar(SGG->(RecNo()))] == Nil .OR.;
				   soRecNo[cValToChar(SGG->(RecNo()))] .OR. !lMarkAll

					aBloqueio := StrTokArr(TCInternal(53),"|")
					//Esta estrutura 'X' está bloqueada para o usuário: Y
					//Entre em contato com o usuário ou tente novamente.
					Help( ,  , "Help", ,  STR0256 + AllTrim(SGG->GG_COD) + STR0257 + aBloqueio[1] + scCRLF + scCRLF + " [" + aBloqueio[2] + "]";
						, 1, 0, , , , , , {STR0258})
				EndIf
				soRecNo[cValToChar(SGG->(RecNo()))] := .F.
			EndIf

		Else                                                  //Desbloqueia registro atual da SGG
			soRecNo[cValToChar(SGG->(RecNo()))] := Nil
			//Remove lock - fonte PCPA135EVDEF
			SGGUnLockR(SGG->(RecNo()))

		EndIf
	EndIf

	If lRet .And. slReplica .And. !Empty(SGG->GG_LISTA)
		lRet       := .F.
		If lMarkAll .And. !lHelpList
			lHelpList := .T.
		ElseIf lMarkAll .And. lHelpList
			lExibHelp := .F.
		EndIf
		If lExibHelp
			Help(,,'Help',,STR0229,1,0,,,,,,; //"Registro inválido para substituição pois está relacionado a uma lista e o parâmetro MV_PCPRLEP está com conteúdo '1'."
						{STR0230})            //"Utilize um registro válido ou reconfigure o parâmetro MV_PCPRLEP."
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} MarkAll
Marca todos os registros
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@param 01 - oMark, objeto, objeto da MarkBrowse
/*/
Static Function MarkAll(oMark)
	Local aArea  := GetArea()

	lMarkAll  	:= .T.
	slMarca		:= !slMarca

	SGG->(DbGoTop())
	While !SGG->(Eof())
		If (slMarca .And. !oMark:IsMark(oMark:Mark()) .AND. ValidMarca()) .Or. (!slMarca .And. oMark:IsMark(oMark:Mark()) .AND. ValidMarca())
    		oMark:MarkRec()
		EndIf
		SGG->(DbSkip())
	End

	lMarkAll  := .F.
	lHelpList := .F.
	RestArea(aArea)
	oMark:Refresh()

Return

/*/{Protheus.doc} P135DoSubs
Grava a substituição dos componentes
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@param 01 - cAlias   , caracter, Alias do registro           (OPC)
@param 02 - nRecno   , numerico, Número do registro          (OPC)
@param 03 - nOpc     , caracter, Número da opção selecionada (OPC)
@param 04 - cMarca200, caracter, Marca para substituição
@param 05 - lInverte , caracter, Inverte marcação
@param 06 - aAutoItens, array  , Array com as informações dos componentes que serão modificados.
                                 Para a operação de exclusão, este array não é considerado.
/*/
Function P135DoSubs(cAlias, nRecno, nOpc, cMarca135, lInverte, aAutoItens)
	Local aAtualiza  := {}
	Local aErrEstrut := {}
	Local aRecnosSGG := {}
	Local cAliasTmp  := GetNextAlias()
	Local cCodPai    := ""
	Local cCodOrig   := Criavar("GG_COMP" , .F.)
	Local cCodDest   := Criavar("GG_COMP" , .F.)
	Local cOpcOrig   := Criavar("C2_OPC"  , .F.)
	Local cGrpOrig   := ''
	Local cQuery2    := ''
	Local cQuery     := ''
	Local cLista     := Criavar("GG_LISTA", .F.)
	Local lAtualiza  := .F.
	Local lRet		 := .F.
	Local nZ         := 0
	Local nI         := 0

	Default aAutoItens := {}

	Pergunte('PCPA135', .F.)

	If sl135Auto
		lRet := .T.
		For nI := 1 to Len(aAutoItens)
			SGG->(dbSetOrder(2))
			If SGG->( dbSeek( xFilial("SGG") + cCodOrig2 + aAutoItens[nI] [2] [2] ) )
				aAdd(aRecnosSGG, SGG->(Recno()))
			EndIf
		Next nI
    Else
		dbSelectArea("SGG")
		SGG->(dbSeek(xFilial("SGG")))
		While SGG->(!Eof());
			.And. SGG->GG_FILIAL == xFilial("SGG")

			//Verifica os registros marcados para substituição
			If IsMark("GG_OK", cMarca135, lInverte)
				lRet := .T.
				aAdd(aRecnosSGG,Recno())
			EndIf
			SGG->(dbSkip())
		EndDo
	EndIf

	If lRet
		//Grava a substituição de componentes
		cGrpOrig := aDadosDest[2]
		cCodOrig := cCodOrig2
		cOpcOrig := aDadosDest[3]
		cCodDest := aDadosDest[1]
		If Len(aRecnosSGG) < 1001 .And. Len(aRecnosSGG) > 0  //Tratamento para oracle pois tem limite de 1000 itens no "IN"
			cQuery2 := " WHERE GG_COD <> '" + aDadosDest[1] + "' AND R_E_C_N_O_ IN ("
			For nZ := 1 to Len(aRecnosSGG)
				If nZ > 1
					cQuery2+= ","
				EndIf
				cQuery2 += "'" + Str(aRecnosSGG[nZ], 10, 0) + "'"
			Next nZ
			cQuery2 += ")"

			//Primeiro busca os registros que serão alterados
			cQuery := "SELECT SGG.GG_COD, SGG.R_E_C_N_O_, "
			cQuery += "(SELECT COUNT(SGG2.GG_COD) "
			cQuery += "   FROM " + RetSqlName("SGG") + " SGG2 "
			cQuery += "  WHERE SGG2.GG_COD = SGG.GG_COD "
			cQuery += "    AND SGG2.GG_FILIAL = '" + xFilial('SGG') + "' "
			cQuery += "    AND SGG2.GG_COMP = '" + aDadosDest[1] + "' "
			cQuery += "    AND SGG2.GG_GROPC = '" + aDadosDest[2] + "' "
			cQuery += "	AND SGG2.D_E_L_E_T_ = ' ' ) EXISTE "
			cQuery += "FROM " + RetSqlName("SGG") + " SGG "
			cQuery += cQuery2
			dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAliasTmp, .T., .T.)
			While (cAliasTmp)->(!EOF())
				If (cAliasTmp)->EXISTE > 0
					aAdd(aErrEstrut, {(cAliasTmp)->GG_COD, STR0231} ) //"Componente já cadastrado na estrutura."
					(cAliasTmp)->(dbSkip())
					Loop
				EndIf
				aAdd(aAtualiza, (cAliasTmp)->R_E_C_N_O_)
				(cAliasTmp)->(dbSkip())
			End
			(cAliasTmp)->(dbCloseArea())

			If Len(aAtualiza) > 0
				//Depois atualiza
				cQuery := "UPDATE "
				cQuery += RetSqlName("SGG") + " "
				cQuery += "SET GG_COMP = '" + aDadosDest[1] + "' , GG_GROPC = '" + aDadosDest[2] + "' , GG_OPC = '" + aDadosDest[3] + "', GG_LISTA = '" + cLista + "' "
				cQuery += "WHERE GG_COD <> '"+aDadosDest[1]+"' AND R_E_C_N_O_ IN ("
				For nZ := 1 to Len(aAtualiza)
					If nZ > 1
						cQuery += ","
					EndIf
					cQuery += "'" + Str(aAtualiza[nZ],10,0) + "'"
				Next nZ
				cQuery += ")"
				TcSqlExec(cQuery)
			EndIf
		Else
			For nZ := 1 to Len(aRecnosSGG)
				lAtualiza := .F.
				cQuery2 := " WHERE GG_COD <> '" + aDadosDest[1] + "' AND R_E_C_N_O_ = "
				cQuery2 += "'" + Str(aRecnosSGG[nZ],10,0) + "'"

				//Primeiro busca os registros que serão alterados
				cQuery := "SELECT SGG.GG_COD, SGG.R_E_C_N_O_, "
				cQuery += "(SELECT COUNT(SGG2.GG_COD) "
				cQuery += "   FROM " + RetSqlName("SGG") + " SGG2 "
				cQuery += "  WHERE SGG2.GG_COD = SGG.GG_COD "
				cQuery += "    AND SGG2.GG_FILIAL = '" + xFilial('SGG') + "' "
				cQuery += "    AND SGG2.GG_COMP = '" + aDadosDest[1] + "' "
				cQuery += "    AND SGG2.GG_GROPC = '" + aDadosDest[2] + "' "
				cQuery += "	AND SGG2.D_E_L_E_T_ = ' ' ) EXISTE "
				cQuery += "FROM " + RetSqlName("SGG") + " SGG "
				cQuery += cQuery2
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
				While (cAliasTmp)->(!EOF())
					If (cAliasTmp)->EXISTE > 0
						aAdd(aErrEstrut, {(cAliasTmp)->GG_COD, STR0231} ) //"Componente já cadastrado na estrutura."
						(cAliasTmp)->(dbSkip())
						Loop
					EndIf
					aAdd(aAtualiza, (cAliasTmp)->R_E_C_N_O_)
					lAtualiza := .T.
					(cAliasTmp)->(dbSkip())
				End
				(cAliasTmp)->(dbCloseArea())

				If lAtualiza
					//Depois atualiza
					cQuery := "UPDATE "
					cQuery += RetSqlName("SGG") + " "
					cQuery += "SET GG_COMP = '" + aDadosDest[1] + "' , GG_GROPC = '" + aDadosDest[2] + "' , GG_OPC = '" + aDadosDest[3] + "', GG_LISTA = '" + cLista + "'"
					cQuery += cQuery2
					TcSqlExec(cQuery)
				EndIf
			Next nZ
		EndIf

		If SuperGetMV("MV_APRESTR",.F.,.F.)
			nRecno := SGG->(Recno())
			SGN->(dbSetOrder(1))
			SGG->(dbSetOrder(1))
			For nZ := 1 to Len(aAtualiza)
				SGG->(dbGoto(aAtualiza[nZ]))
				cCodPai := SGG->GG_COD
				SGN->(dbSeek(xFilial("SGN")+"SGG"+cCodPai))
				While !SGN->(EOF()) .And. SGN->GN_NUM == cCodPai
					RecLock("SGN",.F.)
					SGN->(dbDelete())
					SGN->(MsUnLock())
					SGN->(dbSkip())
				End
				//Atualiza GG_STATUS
				cQuery := "UPDATE "
				cQuery += RetSqlName("SGG") + " "
				cQuery += "SET GG_STATUS = '1'"
				cQuery += "WHERE GG_FILIAL = '" + xFilial('SGG') + "' AND GG_COD = '" + cCodPai + "' AND D_E_L_E_T_ = ' '"
				TcSqlExec(cQuery)
			Next nZ
			SGG->(dbGoto(nRecno))
		EndIf

		//Altera conteúdo do parâmetro de níveis
		If Len(aRecnosSGG) > 0
			P135NivAlt()
		EndIf

		If !sl135Auto
			oMark:Refresh()
		EndIf
	EndIf

	If Len(aErrEstrut) > 0
		P135ErrStr(aErrEstrut)
	EndIf

	//Remove lock's - fonte PCPA135EVDEF
	SGGUnLockR(,,soRecNo)
	soRecNo := Nil

	dbSelectArea("SGG")
Return

/*/{Protheus.doc} P135ErrStr
Monta tela para exibir o que não foi substituído pois o componente já existia na estrutura.
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@param 01 - aErrEstrut, array, Array contendo os produtos não substituídos
@return .T.
/*/
Static Function P135ErrStr(aErrEstrut)
	Local aHeader  := { }
	Local aSizes   := { }
	Local oBrowse
	Local oDlgErr
	Local oGroup
	Local oPanel

	aAdd(aHeader,STR0228) //Produto
	aAdd(aHeader,STR0232) //Mensagem

	aAdd(aSizes,60)
	aAdd(aSizes,100)
	aAdd(aSizes,30)
	aAdd(aSizes,70)
	aAdd(aSizes,30)
	aAdd(aSizes,70)

	DEFINE MSDIALOG oDlgErr TITLE STR0233 FROM 0,0 TO 350,800 PIXEL //"Listagem de Inconsistências"
	oPanel  := tPanel():Create(oDlgErr, 1, 1,,,,,,, 350, 800)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	oGroup  := TGroup():New(05,07,152,396,STR0234,oPanel,,,.T.) //"Dados"
	oBrowse := TWBrowse():New(14,12,380,135,,aHeader,aSizes,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
	oBrowse:SetArray(aErrEstrut)
	oBrowse:bLine := {|| { aErrEstrut[oBrowse:nAT,01], aErrEstrut[oBrowse:nAt,02]} }
	DEFINE SBUTTON FROM 158,370 TYPE 1 ACTION (oDlgErr:End()) ENABLE OF oPanel
	ACTIVATE MSDIALOG oDlgErr CENTER

Return .T.

/*/{Protheus.doc} P135NivAlt
Seta o Parametro MV_NIVALT para 'S'
@author Carlos Alexandre da Silveira
@since 26/02/2019
@version 1.0
@return lRet
/*/
Static Function P135NivAlt()
	Local aAreaAnt   := GetArea()
	Local lRet       := .F.

	//Seta o parâmetro para alteração de níveis
	If !(GetMV('MV_NIVALT')=='S')
		lRet := .T.
		PutMV('MV_NIVALT','S')
	EndIf

	RestArea(aAreaAnt)

Return lRet