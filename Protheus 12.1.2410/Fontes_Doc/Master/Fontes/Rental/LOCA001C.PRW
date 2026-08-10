#Include "loca001c.ch"
#include "totvs.ch"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA001C
Rotina de Transferencia de Obra os itens do contrato
@type function
@version 1.0
@author Alexandre Circenis
@since 1/6/2025
/*/
Function LOCA001C()
Local aArea     := GetArea()
Local aAreaFPA  := FPA->(GetArea())
Local aAreaFP1  := FP1->(GetArea())
Local nPosAs    := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"})
Local nPosSeqGr := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
Local nPosObra  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBRA"})
Local nPosDtRet := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTSCRT"})
Local nPosNFRet := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFRET"})
Local nPosTpSer := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_TIPOSE"})

Local cAS :=  ODLGPLA:aCols[ ODLGPLA:nAt, nPosAS]
Local cSeqGru := ODLGPLA:aCols[ ODLGPLA:nAt, nPosSeqGr]
Local oModel		:= Nil
Local oView			:= Nil
Local oExecView		:= Nil
Local aButtons		:= {}

Private cObraTran := ODLGPLA:aCols[ ODLGPLA:nAt, nPosObra]
Private DataTran

// Linhas Deletadas não podem ser transferidas
if ATail(ODLGPLA:aCols[ ODLGPLA:nAt])
	Help(NIL, NIL, "LOCA001C_04", NIL, STR0001, 1, 0, NIL, NIL, NIL, NIL, NIL, ) //"Linhas deletadas não podem ser Transferidas!"
	Return
endif

// Se a linha da FPA já retornou não se pode realizar a transferencia
if !Empty(ODLGPLA:aCols[ ODLGPLA:nAt, nPosDtRet]) .or. !Empty(ODLGPLA:aCols[ ODLGPLA:nAt, nPosNFRet])
	Help(NIL, NIL, "LOCA001C_03", NIL, STR0002, 1, 0, NIL, NIL, NIL, NIL, NIL, ) //"Item de locação com data de Retirada preenchida não se poderá realizar a Transferencia!"
	Return
endif

If Empty(cAS)
	Help(NIL, NIL, "LOCA001C_07", NIL, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL,{STR0024} )  //"Só itens com código de AS podem ser transferidos." //"Exclua o item e o inclua na nova obra."
	Return
endif

If ODLGPLA:aCols[ ODLGPLA:nAt, nPosTpSer] <> 'L' // Só transfere Locação
	Help(NIL, NIL, "LOCA001C_09", NIL, STR0025, 1, 0, NIL, NIL, NIL, NIL, NIL, ) //"Item não tem o Tipo de Serviço igual a Locação e não poderá ser transferido."
	Return
endif

dbSelectArea("FPA")
dbSetOrder(1)
if dbSeek(xFilial("FPA")+M->FP0_PROJET+cObraTran+cSeqGru)

   aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
            {.F.,Nil},{.T.,"OK"},{.T.,STR0026},{.F.,Nil}		,; //"Fechar"
            {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }

   oModel:= FWLoadModel("LOCA001C")
   oModel:SetOperation(MODEL_OPERATION_UPDATE)

   oModel:Activate(.T.)

   oView := FWLoadView("LOCA001C")
   oView:SetModel(oModel)
   oView:SetOperation(MODEL_OPERATION_UPDATE)

   //apresenta a tela de transferencia de obras
   oExecView := FWViewExec():New()
   oExecView:SetTitle(STR0027) //"Transferencia de Obra"
   oExecView:SetView(oView)
   oExecView:SetOk({|| if (Loca001CTok(oView:GetModel()),Loca001CTRP(),.F.)})
   oExecView:SetModal(.F.)
   oExecView:SetOperation(MODEL_OPERATION_UPDATE)
   oExecView:SetButtons(aButtons)
   oExecView:setReduction(55)
   oExecView:OpenView(.F.)

else
	Help(NIL, NIL, "LOCA001C_01", NIL, STR0004, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0003}) //"Exclua a linha e inclua na obra correta." //"Somente itens já gravados podem ser transferidos!"
endif

Restarea(aAreaFP1)
Restarea(aAreaFPA)
Restarea(aArea)

return

/*/{Protheus.doc} ModelDef
Modelo para transferencia
@type function
@version 1.-
@author Alexandre Circenis
@since 1/6/2025
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oModel
Local oStruFPA := FWFormStruct( 1, 'FPA' )
Local oStruFP1 := FWFormModelStruct():New()
Local oStruAux := FWFormModelStruct():New()
Local bLoad := {|oGridModel, lCopy| loadGrid01(oGridModel, lCopy)}


oStruFP1:AddField(" "," " , 'OK', 'L', 1, 0, { |oModel| MarkObra(oModel)} )
oStruFP1:AddField(STR0005,STR0005 , 'OBRA', 'C', 3, 0,) //STR0005 //"Obra"
oStruFP1:AddField(STR0006,STR0006 , 'DESCRI', 'C', 40, 0, ) //STR0006 //"Descricao"
// Cria o objeto do Modelo de Dados
oStruAux:addField(STR0007, STR0007, "DATATRAN","D",; // <cTipo > //STR0007 //"Data Transferencia"
                8,; // <nTamanho >
                0,; // [ nDecimal ],
                {|| ValidData()},; //[ bValid ]
                {|| .T.},; // [ bWhen ]
                ,; // [ aValues ]
                .T.,; // [ lObrigat ]
                ,; // [ bInit ],
                ,; // <lKey >
                .F.,; // [ lNoUpd ]
                .F.,; //[ lVirtual ]
                '') // [ cValid ])
oStruAux:addField("Prox. Faturamento", "Prox. Faturamento", "DPROXFAT","D",; // <cTipo > //STR0007 //"Data Transferencia"
                8,; // <nTamanho >
                0,; // [ nDecimal ],
                {|| ValProxFat()},; //[ bValid ]
                {|| .T.},; // [ bWhen ]
                ,; // [ aValues ]
                .F.,; // [ lObrigat ]
                ,; // [ bInit ],
                ,; // <lKey >
                .F.,; // [ lNoUpd ]
                .F.,; //[ lVirtual ]
                '') // [ cValid ])

oStruFPA:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
oModel := MPFormModel():New( 'LOCA001C', ,{| oModel| Loca001CTok(oModel)} , {|| .T.}, {|| .T.})

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'FPAMASTER',, oStruFPA )
oModel:AddFields( 'DTTRANSF','FPAMASTER',oStruAux,/*bPreVld*/,/*bPosVld*/,/*bLoad { || LoadDtTran()}*/)
// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'FP1DETAIL', 'FPAMASTER', oStruFP1, , , , ,bLoad)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0008 ) //'Modelo de Transferencia'
oModel:SetPrimaryKey({""})
// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'FPAMASTER' ):SetDescription( STR0009 ) //'Dados do Bem'
oModel:GetModel('FPAMASTER'):SetOnlyQuery(.T.)
oModel:GetModel("FPAMASTER"):SetForceLoad(.T.)

oModel:GetModel( 'DTTRANSF' ):SetDescription( STR0010 ) //'Data de Transferencia'
oModel:GetModel( 'DTTRANSF' ):SetForceLoad(.T.)
oModel:GetModel('DTTRANSF'):SetOnlyQuery(.T.)

oModel:GetModel( 'FP1DETAIL' ):SetDescription( STR0011  ) //'Obras para Transferencia'
oModel:GetModel("FP1DETAIL"):SetOptional(.T.)
oModel:GetModel("FP1DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("FP1DETAIL"):SetForceLoad(.T.)
oModel:GetModel("FP1DETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("FP1DETAIL"):SetNoDeleteLine(.T.)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
VIEW da tela de transferencia de Obras
@type function
@version  1.0
@author Alexandre Circenis
@since 1/6/2025
/*/
Static Function ViewDef()
// Cria a estrutura a ser usada na View
Local oStruFPA := FWFormStruct( 2, 'FPA', { |cCampo| cCampo $ 'FPA_PROJET,FPA_OBRA  ,FPA_SEQGRU,FPA_PRODUT,FPA_DESPRO,FPA_GRUA  ,FPA_DESGRU,FPA_DTINI ,FPA_DTFIM ,FPA_ULTFAT'} )
Local oStruFP1 := FWFormViewStruct():New()
Local oStruAux := FWFormViewStruct():New()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('LOCA001C')

oStruFPA:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
/*
 * Adiciona Campos Virtuais
 */
oStruAux:AddField( 'DATATRAN' ,'01', STR0007, STR0007,,"Get",,,,,,,,,,,,,) //STR0007 //"Data Transferencia"
oStruAux:AddField( 'DPROXFAT' ,'02', "Prox. Faturamento", "Prox. Faturamento",,"Get",,,,,,,,,,,,, )

oStruFP1:AddFIELD( 'OK'	,'01'," "," ",, 'Check'   )
oStruFP1:SetProperty( "OK", MVC_VIEW_WIDTH, 2 )
oStruFP1:AddFIELD( 'OBRA','02',STR0005,STR0005,, 'Get' ,,,,,,,,,,,, ) //STR0005 //"Obra"
oStruFP1:AddFIELD( 'DESCRI','03',STR0006,STR0006,, 'Get' ,,,,,,,,,,,, ) //STR0006 //"Descricao"

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_FPA', oStruFPA, 'FPAMASTER' )
oView:AddField( 'VIEW_DTA', oStruAux, 'DTTRANSF' )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_FP1', oStruFP1, 'FP1DETAIL' )

// Criar um box horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )
oView:CreateVerticalBox( 'DATA', 30 , 'INFERIOR')
oView:CreateVerticallBox( 'OBRAS', 70, 'INFERIOR')
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_FPA', 'SUPERIOR'  )
oView:SetOwnerView( 'VIEW_DTA', 'DATA'  )
oView:SetOwnerView( 'VIEW_FP1', STR0012 ) //'OBRAS'

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_FPA')
oView:EnableTitleView('VIEW_DTA')
oView:EnableTitleView('VIEW_FP1')

Return oView


/*/{Protheus.doc} loadGrid01
Função de Carga da Obras
@type function
@version
@author Alexandre Circenis
@since 1/6/2025
@param oGridModel, object, param_description
@param lCopy, logical, param_description
@return variant, return_description
/*/
Static Function loadGrid01(oGridModel, lCopy)
Local aLoad := {}
Local nPosObr  := Ascan(ODLGOBR:aHeader, {|X|ALLTRIM(X[2])=="FP1_OBRA"})
Local nPosNome := Ascan(ODLGOBR:aHeader, {|X|ALLTRIM(X[2])=="FP1_NOMORI"})
Local nX


for nX := 1 To Len(ODLGOBR:aCols)
	if nX <> oDlgObr:nAt //  só trazer obras que não forem da linah atual
      aAdd(aLoad,{0,{.F., ODLGOBR:aCols[nX, nPosObr], ODLGOBR:aCols[nX, nPosNome]}})
   endif
Next

Return aLoad

/*Static Function loadDtTran(oField, lCopy)
Local aLoad := {}

   aLoad := {{dDataBase},0}

Return aLoad
*/
/*/{Protheus.doc} MarkObra
Marca apenas uma obra por vez
@type function
@version 1.0
@author Alexandre Circenis
@since 1/6/2025
@param oModel, object, Modelo que está sendo processado
@return variant, Retorna .T. para indicar que a obra poderá ser marcada
/*/
Static Function MarkObra(oModel)

Local oModelFP1	:= oModel
Local lRet			:= .T.
Local oView			:= FWViewActive()
Local aSaveLines 	:= FWSaveRows()
Local nX			:= 0

Local nLinAtu   := oModelFP1:GetLine()

For nX := 1 to oModelFP1:Length()
      if nX <> nLInAtu
         oModelFP1:GoLine(nX)
	      oModelFP1:LoadValue("OK",.F.)
      endif
Next nX

//oModelFP1:GoLine(nLinAtu)
//oModelFP1:LoadValue("OK",lMarca)
FWRestRows(aSaveLines)
oModelFP1:GoLine(nLinAtu)
oView:Refresh()

Return lRet
/*/{Protheus.doc} Loca001CTR
Função que reliza a troca de obra entre as linhas da FPA
@type function
@version
@author Alexandre Circenis
@since 1/6/2025
@return variant, return_description
/*/
FUNCTION Loca001CTR()
Local oModel	:=  FwModelActive()
Local nPOBRA    := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_OBRA"})
Local nPDtSR    := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTSCRT"}) // Data de Solicitação de Retirada
Local nPDNFR    := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DNFRET"}) // Data da Nota Fical de Retorno
Local nPNFRet   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFRET"}) // Nota Fiscal de retorno
Local nPNFRem   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_NFREM"}) // Nota Fiscal de Remessa
Local nPAS      := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"})
Local nPUltFat  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ULTFAT"})
Local nPProxFat := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})
Local nPDTINI   := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})
Local nPSeqGru  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_SEQGRU"})
Local nPProd    := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_PRODUT"})
Local nPBem     := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_GRUA"})
Local nPViagem  := ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VIAGEM"})
Local cSeqGru   := CriaVar("FPA_SEQGRU", .T.)
//Local oModelFPA	:= oModel:GetModel("FPAMASTER")
Local oModelFP1	:= oModel:GetModel("FP1DETAIL")
Local oModelDtT	:= oModel:GetModel('DTTRANSF')
Local cObraDest := ''
Local nQItens   := 0
Local nX
Local nLinha := oDlgPla:nAt
Local aCopiaLinha
Local lTransf := .F.
Local nObraFP1 := ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="FP1_OBRA"})
Local nQtdItem := ASCAN(ODLGOBR:AHEADER,{|X|ALLTRIM(X[2])=="QTDEITENS"})
Local aNewAS := {}

//Obter a Obra Destino
For nX := 1 to oModelFP1:Length()
   if oModelFP1:GetValue("OK", nX)
      cObraDest := oModelFP1:GetValue("OBRA", nX)
      exit
   endif
Next nX

aCopiaLinha := aClone(oDlgPla:aCols[nLinha])

// ajustar a linha atual para troca
oDlgPla:aCols[nLinha, nPDtSR  ] := oModelDtT:GetValue("DATATRAN")
oDlgPla:aCols[nLinha, nPDNFR  ] := oModelDtT:GetValue("DATATRAN")
oDlgPla:aCols[nLinha, nPNFRet ] := "TRAN-"+cObraDest
oDlgPla:aCols[nLinha, nPNFRem ] := "TRAN-"+cObraDest
// Incluir nova linha

aCopiaLinha[nPOBRA] := cObraDest
aCopiaLinha[nPUltFat] := Ctod("")
aCopiaLinha[nPDtIni]  := oModelDtT:GetValue("DATATRAN")+1 // Saltar um dia pois cobramos a data de transferencia na AS anterior

// Busacr na nova obra uma linha sem Produto para reutilizar
FOR nX := 1 TO LEN(OPLA_COLS)
	WOBRA := OPLA_COLS[nX][nPOBRA]
	IF OPLA_COLS[nX][nPOBRA] == cObraDest
		if Empty(OPLA_COLS[nX][nPProd]) // Se não tem produto usar essa linha para transferencia
			aCopiaLinha[nPSeqGru] := OPLA_COLS[nX][nPSeqGru]
			aNewAS := GeraAS(M->FP0_PROJET, oDlgPla:aCols[nLinha, nPObra  ] , cObraDest, oDlgPla:aCols[nLinha,nPSeqGru]  , aCopiaLinha[nPSeqGru])
			aCopiaLinha[nPAS] := aNewAS[1]
			aCopiaLinha[nPViagem] := aNewAS[2]
			OPLA_COLS[nX] := Aclone(aCopiaLinha)
			nQItens++
			lTransf := .T.
			exit
		else
			nQItens++
			cSeqGru := if( OPLA_COLS[nX][nPSeqGru]> cSeqGru,OPLA_COLS[nX][nPSeqGru], cSeqGru)
		endif
    endif
next

if !lTransF // Não reutilizou uma linha incluir uma nova
   	cSeqGru := Soma1(cSeqGru) // Proxima sequencia de FPA
   	aCopiaLinha[nPSeqGru] := cSeqGru
   	aNewAS := GeraAS(M->FP0_PROJET, oDlgPla:aCols[nLinha, nPObra  ] , cObraDest, oDlgPla:aCols[nLinha,nPSeqGru]  , cSeqGru)
	aCopiaLinha[nPAS] := aNewAS[1]
	aCopiaLinha[nPViagem] := aNewAS[2]
	if !Empty(oModelDtT:GetValue("DPROXFAT"))
		aCopiaLinha[nPProxFat] := oModelDtT:GetValue("DPROXFAT")	
	endif
   Aadd(OPLA_COLS, Aclone(acopiaLinha))
   nQItens++
endif

nPosObra := Ascan(ODLGOBR:aCols, {|X|ALLTRIM(X[nObraFP1])== ODLGPLA:ACOLS[1][nPOBRA]} )
if nQItens > 0 .and. nQtdItem > 0
	ODLGOBR:aCols[nPosObra][nQtdItem] := nQitens
endif

// atualizar o array de transferencia

Aadd(aTransf ,{oDlgPla:aCols[nLinha, nPBem  ], cObraDest, oModelDtT:GetValue("DATATRAN"), oDlgPla:aCols[nLinha, nPAS], aNewAS[1]})

Return .T.
/*/{Protheus.doc} GeraAS
Gera uma nova AS na FQ5 uso apenas para transferencia de locação
@type function
@version  1.0
@author Alexandre Circenis
@since 1/6/2025
@param cProjet, character, Codigo do Projeto
@param cObra, character, Codigo da Obra
@param cSeqGru, character, Sequencial do item na Obra
@return variant, Codigo da AS
/*/
STATIC Function GeraAS(cProjet, cObraOld, cObraNew, cSeqOld, cSeqNew)
Local CNRAS := ""
Local aArea  := GetArea()
Local aAreaFPA := FPA->(GetArea())
Local aAreaFP1 := FP1->(GetArea())
Local cSeg
Local XIT
Local CVIAGEM := ''
Local cStatusOri := "1"
Local aDTQ := {}
Local dAceite :=  Ctod("")

// Buscar FPA atual para trocar o numero da AS
dbSelectArea("FPA")
dbSetOrder(1)
IF DBSEEK(XFILIAL("FPA")+cProjet+cObraOld+cSeqOld)

	DO CASE

		CASE  FPA->FPA_TIPOSE $ "L;S" // Locação
			CSEG := "30"
	ENDCASE
	
	cStatusOri := Posicione("FQ5",9, xFilial("FQ5")+FPA->FPA_AS,"FQ5_STATUS")
	dAceite := If( cStatusOri <> '6', CTod(""), dDataBase)

	cNrAS := GERANUMAS( CSEG , cProjet, cObraNew, cSeqNew, xFilial("FPA"), cSeqNew)

	CEQANT  := FPA->FPA_GRUA
	
	CTIPOAS := M->FP0_TIPOSE //28.06.2011 MAICKON - INCLUIDA POIS NÃO ESTAVA GERANDO VIAGEM PARA PLATAFORMA

	CCONDPAG:=FPA->FPA_CONPAG
	CDESCCON:=POSICIONE("SE4",1,XFILIAL("SE4")+CCONDPAG,"E4_DESCRI")

	ADTQ := {}

	DBSELECTAREA("FQ5")
	DBSETORDER(8)

	// Frank em 17/10/23 - card 1227
	// coloquei um reforço lógico para evitar a numeracao repetida da viagem,
	// quando ocorria a repetição era gerado linhas em branco a fq5 e depois deletadas
	// e este erro gravava a AS na FPA sem gerar a FQ5.
	While .T.
		CVIAGEM := GETSX8NUM("FQ5", "FQ5_VIAGEM" )
		CONFIRMSX8()
		FQ5->(dbSetOrder(1))
		If !FQ5->(dbSeek(xFilial("FQ5")+CVIAGEM))
			Exit
		EndIF
	Enddo

	RECLOCK("FQ5",.T.)
	lASNova := .T.
	AADD(ADTQ , {"FQ5_FILIAL" , RETFILGRV("FQ5_FILIAL")})
	AADD(ADTQ , {"FQ5_FILORI" , RETFILGRV("FQ5_FILORI")})
	AADD(ADTQ , {"FQ5_VIAGEM" , CVIAGEM})
	AADD(ADTQ , {"FQ5_CONTRA" , CPROJET})
	AADD(ADTQ , {"FQ5_DATGER" , DDATABASE})
	AADD(ADTQ , {"FQ5_HORGER" , SUBSTR(TIME(),1,2)+SUBSTR(TIME(),4,2)})
	AADD(ADTQ , {"FQ5_ROTA"   , "000001"})
	AADD(ADTQ , {"FQ5_TIPVIA" , "1"})
	AADD(ADTQ , {"FQ5_DATINI" , FPA->FPA_DTINI})
	AADD(ADTQ , {"FQ5_HORINI" , FPA->FPA_HRINI})
	AADD(ADTQ , {"FQ5_DATFIM" , FPA->FPA_DTENRE})
	AADD(ADTQ , {"FQ5_HORFIM" , FPA->FPA_HRFIM})
	AADD(ADTQ , {"FQ5_SERTMS" , "2"})
	AADD(ADTQ , {"FQ5_TIPTRA" , "1"})
	AADD(ADTQ , {"FQ5_NOMCLI" , M->FP0_CLINOM})
	AADD(ADTQ , {"FQ5_ORIGEM" , "EMPRESA"})
	AADD(ADTQ , {"FQ5_DESTIN" , FP1->FP1_MUNORI+FP1->FP1_ESTORI})
	AADD(ADTQ , {"FQ5_CONDPG" , CCONDPAG})
	AADD(ADTQ , {"FQ5_DCOND"  , CDESCCON})
	AADD(ADTQ , {"FQ5_STATUS", cStatusOri}) // AS nasce com o mesmo status da Original
	AADD(ADTQ , {"FQ5_ACEITE", dAceite})
	AADD(ADTQ , {"FQ5_SOT"   , cProjet})
	AADD(ADTQ , {"FQ5_OBRA"  , cObraNew})
	AADD(ADTQ , {"FQ5_TPAS"  , CTIPOAS})
	AADD(ADTQ , {"FQ5_AS"    , CNRAS})
	AADD(ADTQ , {"FQ5_GUINDA", FPA->FPA_GRUA})
	AADD(ADTQ , {"FQ5_SEQVIA", FPA->FPA_SEQGRU})
	AADD(ADTQ , {"FQ5_CODCLI", M->FP0_CLI})	//NOME DO CLIENTE
	AADD(ADTQ , {"FQ5_LOJA"  , M->FP0_LOJA})	//NOME DO CLIENTE
	AADD(ADTQ , {"FQ5_XQTD"  , FPA->FPA_QUANT}) // FRANK ZWARG FUGA - 13/08/2020
	AADD(ADTQ , {"FQ5_XPROD" , FPA->FPA_PRODUT}) // FRANK ZWARG FUGA - 13/08/2020
	/*
	IF _GRCONTR_ //EXISTBLOCK( "GRCONTR_" )
		XRET := EXECBLOCK( "GRCONTR_", .T., .T., { "ANTESDTQ", @ADTQ, "FPA" } )
		IF VALTYPE( XRET ) == "A"
			ADTQ := XRET
		ENDIF
	ENDIF
	*/
	FOR XIT := 1 TO LEN(ADTQ)
		FQ5->&(ADTQ[XIT][1]) := ADTQ[XIT][2]
	NEXT
	FQ5->(MSUNLOCK())
endif

RestArea(aAreaFP1)
RestArea(aAreaFPA)
RestArea(aArea)

Return {cNrAS, CVIAGEM} 

/*/{Protheus.doc} GERANUMAS
Gera uma novo Codidgo de AS
@type function
@version 1.0
@author Alexandre Circenis
@since 1/6/2025
@param PSRV, variant, Tipo do Servição (FPA_TIPOSE)
@param PPROJETO, variant, Codigo do Projeto
@param POBRA, variant, Codigo da Obra
@param PSEQ, variant, Sequencial do Item
@param PFILIAL, variant, Filial
@param CNEWSEQ, character, Novo sequencial
@return variant, Codigo da AA
/*/// ======================================================================= \\
STATIC FUNCTION GERANUMAS( PSRV , PPROJETO, POBRA, PSEQ, PFILIAL, CNEWSEQ)
// ======================================================================= \\
Local AAREA     := GETAREA()
Local AAREADTQ  := FQ5->(GETAREA())
Local LCONTINUA := .T.
Local CSERVICO  := ALLTRIM( PSRV )
Local CPROJETO  := SUBSTR( ALLTRIM( PPROJETO ), 5, 5 )
Local COBRA     := ALLTRIM( POBRA )
Local _CFILIAL  := ALLTRIM( PFILIAL )

Default CNEWSEQ   := ALLTRIM( IIF( VALTYPE(PSEQ) == "N", STRZERO(PSEQ, 3), PSEQ ) )

	FQ5->(DBSETORDER(9))								// FQ5_FILIAL + FQ5_AS + FQ5_VIAGEM
	WHILE LCONTINUA
		CNRAS     := CSERVICO + CPROJETO + COBRA + CNEWSEQ + _CFILIAL
		LCONTINUA := FQ5->(DBSEEK( XFILIAL("FQ5") + CNRAS, .T.))
		CNEWSEQ   := SOMA1(CNEWSEQ)
	ENDDO

	FQ5->(RESTAREA(AAREADTQ))
	RESTAREA( AAREA )

RETURN CNRAS

/*/{Protheus.doc} ValidData
Valida a data de Transferencia
@type function
@version
@author Alexandre Circenis
@since 1/6/2025
@return variant, .t. se for uma data valida
/*/
Static Function ValidData()
Local lRet := .T.
Local oModel :=  FwModelActive()
Local oModelFPA := oModel:GetModel("FPAMASTER")
Local oModelDtT := oModel:GetModel('DTTRANSF')
Local dDataTran := oModelDtT:GetValue("DATATRAN")

if M->FP0_TIPFAT = 'P' // Se o tipo de Faturamento for padrão validar a data de transferencia

	if dDATATRAN < oModelFPA:GetValue("FPA_DTINI") .or. dDATATRAN < oModelFPA:GetValue("FPA_ULTFAT")
		oModel:SetErrorMessage("","","","","LOCA001C_05",STR0013,) // "Data de transferencia não foi preenchida!"
		lRet := .F.
	elseif dDATATRAN > oModelFPA:GetValue("FPA_DTFIM")
		oModel:SetErrorMessage("","","","","LOCA001C_02",STR0014,) //"Data de transferencia não pode ser posterior a data final do periodo a faturar!" //"Verifique as data do Proximo Faturamento"
		lRet := .F.
	endif

endif

RETURN lRet

/*/{Protheus.doc} Loca001CTok
Validação do Model ao se pressionar o botão OK
@type function
@version 1.0
@author Alexandre Circenis
@since 1/6/2025
@param oModel, object, Modelo ativo
@return variant, .T. se o modelo estiver valido
/*/
Static Function Loca001CTok(oModel)

Local oModelFP1 := oModel:GetModel('FP1DETAIL')
Local oModelDtT := oModel:GetModel('DTTRANSF')
Local nX
Local nCheck := 0
Local lRet := .T.

if !oModelDtT:Vlddata() 
	Help(NIL, NIL, "LOCA001C_12", NIL, "Há dados pendentes de validação na tela.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique a Data de Transferencia ou a Obra destino"}) //"Selecione uma obra na lista de obras disponiveis para transferencia!" //"Para realizar a transferencia a obra de destino deverá ser selecionada!"
	Return .F.
endif
// Validar e uma obra foi selecionada
for nX := 1 to oModelFP1:Length()
	if oModelFP1:GetValue("OK", nX)
		nCheck ++
	endif
next

if nCheck <> 1
	Help(NIL, NIL, "LOCA001C_06", NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) //"Selecione uma obra na lista de obras disponiveis para transferencia!" //"Para realizar a transferencia a obra de destino deverá ser selecionada!"
	lRet := .F.
endif

Return lRet

/*/{Protheus.doc} Loca001CLO
Processa o array de Transferencia para gerar o historico de transferencias
@type function
@version 1.0
@author Alexandre Circenis
@since 1/6/2025
@param aTransf, array, Array contendo os bens tranferidos
@return variant, return_description
/*/
Function Loca001CLO(aTransf)
Local nX

for nX := 1 to Len(aTransf)
	if !Empty(aTransf[nX, 1]) // Tem Bem gerar o historico da Transferencia
		Loca001CSt(aTransf[nX, 1], aTransf[nX, 2], aTransf[nX, 3], aTransf[nX, 5])
	endif
	LOCA001CFP( aTransf[nX, 4], aTransf[nX, 5], aTransf[nX, 2])
next

Return
/*/{Protheus.doc} Loca001CSt
Gera o historico da Transferencia da FQ4
@type function
@version 1.0
@author Alexandre Circenis
@since 1/6/2025
@param cBem, character, Codigo do Bem transferido
@param cObraDest, character, Codigo da Obra Destino
@param dTransf, date, Data da Transferencia
@return variant, return_description
/*/
Function Loca001CSt(cBem, cObraDest, dTransf, cNewAS)
Local aArea := GetArea()
Local nRegFQ4 := 0
Local _cUserName := Upper(AllTrim(cUserName))

dbSelectArea("FQ4")
dbSetOrder(1)
if dbSeek(xFilial("FQ4")+cBem)
	// Buscar o ultimo registro
	while !Eof() .and. FQ4->(FQ4_FILIAL+FQ4_CODBEM) = xFilial("FQ4")+cBem
		nRegFQ4 := FQ4->(Recno())
		dbSkip()
	enddo
	if nRegFQ4 > 0
		dbGoto(nRegFQ4)
		RegToMemory("FQ4",.F.,.F.)
		// Gerar os dados da FQ4 de Saida do Obra Origem
		M->FQ4_DOCUME := ''
		M->FQ4_SERIE  := ''
		M->FQ4_AS     := cNewAS
		M->FQ4_LOG    := STR0018+cBem + STR0019+ M->FQ4_OBRA + STR0020+ cObraDest +" - Obra "+ cObraDest + " - " + _cUserName + " - " + FWTimeStamp(2,Date(),Time()) //"BEM " //" Transferido da obra " //" para a obra "
		M->FQ4_OBRA   := cObraDest
		M->FQ4_SEQ := GetSx8Num("FQ4","FQ4_SEQ")
    	ConfirmSx8()
		Mem2Reg( "FQ4", .T. )
		msUnLock()
	endif

endif
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MEM2REG  º Autor ³ Andre Schwartz     º Data ³  17/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava as variaveis de memoria criadas pela funcao Regtomemorº±±
±±º          ³Modificado por Carlos Queiroz em 07/12/04.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mem2Reg( cAlias, lIncluir )          // Mem2Reg("SB1",cOpca == 3)

Local nFilial := 0     							   // Variavel utilizada para receber a filial
Local cAuxMem, x     //  Declaração de variaveis locais

dbSelectArea(cAlias)                              // Seciona a area da tabela SB1
nFilial := aScan(dbStruct(), {|x| "_FILIAL" $ x[1]})    // Procura no array pelo aScan o conteudo de _FILIAL

RecLock(cALias, lIncluir)                         // Trava a tabela para a gravacao

for x:= 1 TO FCount()                             // For de 1 ateh o numero de campos que sao utilizados na tabela SB1(FCount())
	cAuxMem := Alltrim("M->"+FieldName(x))       // Armazena o conteudo do campo da tabela em uma variavel auxiliar.
	FieldPut(x, &(cAuxMem))                      // Grava o conteudo do campo armazenado na auxilar no Banco de Dados.
next			 								 // Proximo campo da tabela SB1

If nFilial > 0                                // Se Filial for Maior que Zero, ou seja, se ele localizou no aScan a filial
	FieldPut(nFilial, xFilial(cAlias))       // Grava-se o conteudo da filial no registro do campo que estah ativo no FOR
Endif

msUnlock()  	 // Destrava a tabela da gravacao
// RestArea(aArea)  //Retorna a area da tabela anterior
return

Function LOCA001CFP( cASOld, cASNew, cObraNew)
local cQuery := ""
LOcal cAliasQry :=  ''
Local aArea := GetArea()

cQuery += "SELECT FPZ.R_E_C_N_O_ REG "
cQuery += " FROM "+RetSqlName("FPZ")+ " FPZ "
cQuery += " INNER JOIN "+RetSqlName("FPY")+ " FPY "
cQuery += " ON FPY_FILIAL = '"+xFilial("FPY")+"' "
cQuery += " AND FPZ_PEDVEN = FPY_PEDVEN"
cQuery += " AND FPY_TIPFAT = 'R' "
cQuery += " AND FPY.D_E_L_E_T_ = ' '"
cQuery += " WHERE FPZ_FILIAL = '"+xFilial("FPZ")+"'"
cQuery += " AND FPZ_AS = ? "
cQuery += " AND FPZ.D_E_L_E_T_ = ' '"

CQUERY := CHANGEQUERY(CQUERY)
aBindParam := { cAsOld }

cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)

WHILE ! (cAliasQry)->( EOF() )
	dbSelectArea("FPZ")
	dbGoto((cAliasQry)->REG)
	RecLock("FPZ",.F.)
	FPZ->FPZ_AS := cASNew
	FPZ->FPZ_OBRA := cObraNew
	(cAliasQry)->( dbSkip() )
ENDDO

RestArea(aArea)

RETURN

// --------------------------------------------------------------------------
/*/{PROTHEUS.DOC} RETFILGRV
RETORNA A FILIAL QUE VAI SER GRAVADA NO REGISTRO.
@AUTHOR  IT UP BUSINESS
@SINCE   21/04/2019
@type Function
/*/
// --------------------------------------------------------------------------
STATIC FUNCTION RETFILGRV(CCAMPO)
Local CINFRET  := ""
Local LVLDFIL  := SUPERGETMV("MV_LOCX085",.F.,.T.)			// GETMV("MV_LOCX085" , , .F.)
Local CFILPROJ := FP0->FP0_FILIAL

Default CCAMPO := ""

	DO CASE
	CASE ALLTRIM(CCAMPO) == "FQ5_FILIAL"
		IF LVLDFIL
			IF EMPTY(XFILIAL("FQ5"))
				CINFRET := XFILIAL("FQ5")
			ELSE
				CINFRET := CFILPROJ
			ENDIF
		ELSE
			CINFRET     := XFILIAL("FQ5")
		ENDIF
	CASE ALLTRIM(CCAMPO) == "FQ5_FILORI"
		IF LVLDFIL
			CINFRET     := CFILPROJ
		ELSE
			CINFRET     := CFILANT
		ENDIF
	ENDCASE

RETURN CINFRET

STATIC FUNCTION ValProxFat()
Local lRet := .T.
Local oModel :=  FwModelActive()
Local oModelFPA := oModel:GetModel("FPAMASTER")
Local oModelDtT := oModel:GetModel('DTTRANSF')
Local dPFAT     := oModelDtT:GetValue("DPROXFAT")

if !Empty(dPFat)

	if dPFAT < oModelFPA:GetValue("FPA_DTINI") .or. dPFAT < oModelFPA:GetValue("FPA_ULTFAT")
		oModel:SetErrorMessage("","","","","LOCA001C_10",STR0028,) //"Data do proximo Faturamento não pode ser inferior a data de inicio ou a data do Ultimo Faturamento."
		lRet := .F.
	elseif dPFat > oModelFPA:GetValue("FPA_DTFIM")
		oModel:SetErrorMessage("","","","","LOCA001C_11",STR0029,) //"Data de Proximo Faturamento não pode ser posterior a data final do periodo a faturar!"
		lRet := .F.
	endif

endif

RETURN lRet
