#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA850.CH"

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    	Ё GPEA850    Ё Autor Ё Leandro Drumond       	      Ё Data Ё 18/06/12 Ё╠╠
╠╠цдддддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o 	Ё Manutencao de Complementos Trabalhistas                      			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   	Ё GPEA850()                                                    			Ё╠╠
╠╠цдддддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      	Ё Generico ( DOS e Windows )                                   			Ё╠╠
╠╠цдддддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.               			Ё╠╠
╠╠цдддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador  Ё Data     Ё FNC			Ё  Motivo da Alteracao                      Ё╠╠
╠╠цдддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Cecilia C.  Ё 19/05/14 ЁTPPCSB          ЁIncluido o fonte da 11 para a 12 e efetuadaЁ╠╠
╠╠Ё             Ё          Ё                Ёa limpeza.                                 Ё╠╠
╠╠Ё Sidney O.   Ё 29/07/14 ЁTPVN08          ЁAlterada a funcao Gp850VlPer. Ajuste na    Ё╠╠
╠╠Ё             Ё          Ё                Ёvalidacao das datas.                       Ё╠╠
╠╠юдддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/

Function GPEA850()

Local oMBrowse
Local cFiltraRh
   
oMBrowse := FWMBrowse():New()

oMBrowse:SetAlias("RF1")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //'Cadastro de Complementos Trabalhistas'

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFiltraRh := CHKRH("GPEA850","RF1","1")
oMBrowse:SetFilterDefault( cFiltraRh )

oMBrowse:Activate()

Return

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ModelDef 		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Modelagem da gravacao.                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ModelDef()

Local oModel
Local oStructRF1

// Criacao do Objeto de Modelagem de dados da tabela RF1 //
oModel     := MPFormModel():New("GPEA850", NIL, { |oModel| gp850TudOk(oModel) } , {|oModel| GPEA850Commit(oModel)})
oModel:SetDescription( OemToAnsi(STR0001) ) //'Cadastro de Complementos Trabalhistas'

// Estrutura de campos do Model //
oStructRF1 := FWFormStruct(1, "RF1")
oStructRF1:RemoveField("RF1_FILIAL")

oModel:AddFields("GPEA850_RF1", NIL, oStructRF1)
oModel:SetPrimaryKey({"RF1_IDCMPL"})

oModel:GetModel( "GPEA850_RF1" ):SetDescription( OemToAnsi(STR0001) ) //'Cadastro de Complementos Trabalhistas'

Return( oModel )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё ViewDef  		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁRegras de Interface com o Usuario                           Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё       
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function ViewDef()

Local oView 
Local oModel
Local oStructRF1

// Criacao da Interface //
oView := FWFormView():New()

// Vincular o View ao Model //
oModel := FWLoadModel("GPEA850")	
oStructRF1 := FWFormStruct(2, "RF1")

oStructRF1:RemoveField("RF1_FILIAL")

oView:SetModel(oModel)
oView:AddField("GPEA850_RF1", oStructRF1)

oView:CreateHorizontalBox("FIELDS", 100)

oView:SetOwnerView("GPEA850_RF1", "FIELDS")
	
Return oView

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPEA850Commit  ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁGravacao das informacoes com as validacoes pertinentes      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GPEA850Commit(oModel)

Local nOperation

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .or. nOperation == MODEL_OPERATION_UPDATE

	If GP850ValPer(oModel)
      	FWFormCommit(oModel)
    EndIf   

// Tratamento de exclusЦo
ElseIf nOperation == MODEL_OPERATION_DELETE
	
	If Gpa850VldDel(oModel)
		FWFormCommit(oModel)
	EndIf

EndIf
	
Return( .T. )

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gpa850VldDel   ЁAutorЁ  Leandro Drumond  Ё Data Ё27/07/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida delecao dos registros							    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function Gpa850VldDel(oModel)
Local aArea		:= GetArea()
Local cIdCmpl	:= ''
Local oRF1Struct:= oModel:GetModel( "GPEA850_RF1" )
Local lRet 		:= .T.

cIdCmpl := oRF1Struct:GetValue( "RF1_IDCMPL" )

DbSelectArea('RFC')
DbSetOrder(RetOrder('RFC','RFC_IDCMPL'))

If DbSeek(cIdCmpl)
	lRet := .F.
	MsgAlert(STR0008) //"Existem registros de RRA gerados para este complemento. ExclusЦo nЦo poderА ser realizada."
EndIf

RestArea(aArea)

Return lRet

/*                                	
зддддддддддбддддддддддддддбдддддбдддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё Gp850VlPer	  ЁAutorЁ Equipe Inovacao RH  Ё Data Ё09/08/2013Ё
цддддддддддеддддддддддддддадддддадддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida intervalo de periodo                                 Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gp850VlPer(dDataIni, dDataFim)
Local lRet := .T.

If !Empty(dDataIni)           
    If Len(Alltrim(dDataIni)) < 6
        Return(.F.)
    Else
        If Val(Left(dDataIni,2)) < 1 .OR. Val(Left(dDataIni,2)) > 12
            Return(.F.)                                              
        EndIf
    EndIf
EndIf

If !Empty(dDataFim)
    If Len(Alltrim(dDataFim)) < 6
        Return(.F.)
    Else
        If Val(Left(dDataFim,2)) < 1 .OR. Val(Left(dDataFim,2)) > 12
            Return(.F.)                                              
        EndIf
    EndIf

    If Right(dDataFim,4)+Left(dDataFim,2) < Right(dDataIni,4)+Left(dDataIni,2) 
        lRet := .F.
    EndIf                
EndIf

Return(lRet)
  
/*                                	
зддддддддддбдддддддддддддддбдддддбддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё GPEA850ValPer ЁAutorЁ Equipe Inovacao RH Ё Data Ё12/08/2013Ё
цддддддддддедддддддддддддддадддддаддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁValida informacoes de periodo inicial e final               Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function GP850ValPer(oModel)
Local oRF1Struct:= oModel:GetModel( "GPEA850_RF1" )
Local dDataIni := oRF1Struct:GetValue( "RF1_AAMMI" ) 
Local dDataFim := oRF1Struct:GetValue( "RF1_AAMMF" ) 
Local lRet := .T.

If !Empty(dDataIni) .And. !Empty(dDataFim) 
    If Right(dDataFim,4)+Left(dDataFim,2) < Right(dDataIni,4)+Left(dDataIni,2) 
        MsgAlert( OemToAnsi( STR0010 ), OemToAnsi( STR0009 ) )  
        lRet := .F.
    EndIf
EndIf                             
Return( lRet )

/*/{Protheus.doc} gp850TudOk
Valida preenchimento das tags cTpInsAdv, cNrAdv, nVlrAdv (grupo ideAdv) caso campo RF1_TOTADV seja preenchido.
@parameters
@author raquel.andrade
@since 16/04/2024
@version 1.0
/*/
Static Function gp850TudOk(oModel)
Local oMdlRF1	    := oModel:GetModel("GPEA850_RF1")
Local aInfoAdv      := {}
Local cVersEnvio    := ""
Local cFilProNum    := ""
Local cPronum       := ""
Local cTpInsAdv     := ""
Local cNrAdv        := ""
Local nVlrAdv       := ""
Local nX            := 0
Local nTotAdv       := 0
Local nOperacao	    := oMdlRF1:GetOperation()
Local lRet          := .T.
Local lOk           := .T.
Local lVlrAlter     := .F.

    If FindFunction("fVersEsoc")
        fVersEsoc( "S2200", .F., /*aRetGPE*/, /*aRetTAF*/, @cVersEnvio )
    EndIf

    If nOperacao == MODEL_OPERATION_INSERT .Or. nOperacao == MODEL_OPERATION_UPDATE
        If cVersEnvio >= "9.2"
            nTotAdv     := oMdlRF1:GetValue("RF1_TOTADV")
            cPronum     := oMdlRF1:GetValue("RF1_PRONUM") 
            cFilProNum  := xFilial("RE4")
            lVlrAlter   := nTotAdv > 0 .And. nTotAdv <> M->RF1_TOTADV
            If !Empty(cPronum) .And. lVlrAlter              
                DbSelectArea("RE4")
                RE4->(DbSetOrder(1))
                If RE4->(dbSeek(cFilProNum+cPronum))
                    While RE4->(! Eof()) .And. RE4->RE4_FILIAL == cFilProNum .And. RE4->RE4_PRONUM == cPronum
                        cTpInsAdv := If(!Empty(RE4->RE4_ESCRIT),"1", "2") //Se escritorio estiver preenchido tipo = CNPJ senao CPF
                        nVlrAdv	  := RE4->RE4_VLDADV
                        If cTpInsAdv == "1"
                            DbSelectArea("RE3")
                            DbSetOrder(1)
                            If RE3->(dbSeek(xFilial("RE3")+RE4->RE4_ESCRIT) )
                                cNrAdv := RE3->RE3_CNPJ
                            EndIf
                        Else
                            DbSelectArea("RD0")
                            DbSetOrder(1)
                            If RD0->(dbSeek(xFilial("RD0")+RE4->RE4_CODADV) )
                                cNrAdv := RD0->RD0_CIC
                            EndIf
                        EndIf
                        // Carrega Dados os Advogados do Processo do grupo ideADV
                        Aadd(aInfoAdv,{ cTpInsAdv, cNrAdv, nVlrAdv })	
                        RE4->(dbSkip())
                    Enddo

                    If Len(aInfoAdv) > 0
                        For nX := 1 to Len(aInfoAdv)
                            If lOk .And. (Empty(aInfoAdv[nX][1]) .Or. Empty(aInfoAdv[nX][2]) .Or. aInfoAdv[nX][3] == 0 )
                                lOk := .F.
                            EndIf
                        Next nX
                        If !lOk
                            // "AtenГЦo"
                            // "Quando o valor Total das Despesas com Advogado(s) estiver preenchido И obrigatСria a identificaГЦo dos Advogados e o valor pago a cada um deles!"
                            // "Verificar os dados preenchidos na aba Advogados no cadastro de Processos."
                            Help(,,OemToAnsi(STR0009),,OemToAnsi(STR0011) ,1,0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0012)} )
                            lRet    := .F.
                        EndIf
                    EndIf
                EndIf
            ElseIf Empty(cPronum) .And. lVlrAlter
                // "AtenГЦo"
                // "O Campo NЗmero do Processo estА vazio e o campo Total Despesas c/ Advogados estА preenchido!"
                // "Preencher o campo NЗmero do Processo para que as informaГУes de Despesas c/ Advogados sejam verificadas."
                Help(,,OemToAnsi(STR0009),,OemToAnsi(STR0013) ,1,0, NIL, NIL, NIL, NIL, NIL, {OemToAnsi(STR0014)} )
                lRet    := .F.
            EndIf
        EndIf 
    EndIf        

Return (lRet)

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Leandro Drumond  Ё Data Ё18/06/2012Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁCriacao do Menu do Browse.                                  Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA850                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "PESQBRW"         		OPERATION 1 ACCESS 0 DISABLE MENU 	//'Pesquisar'
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.GPEA850" 		OPERATION 2 ACCESS 0 				//'Visualizar'
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.GPEA850" 		OPERATION 3 ACCESS 0				//'Incluir'
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.GPEA850" 		OPERATION 4 ACCESS 0				//'Alterar'  
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.GPEA850" 		OPERATION 5 ACCESS 0				//'Excluir'
	ADD OPTION aRotina TITLE STR0007  ACTION 'VIEWDEF.GPEA850'		OPERATION 9 ACCESS 0 				//"Copiar" 

Return aRotina     

