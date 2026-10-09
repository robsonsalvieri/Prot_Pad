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

if !lTransF // Nï¿½o reutilizou uma linha incluir uma nova
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
Gera uma nova AS na FQ5 uso apenas para transferencia de locaï¿½ï¿½o
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

		CASE  FPA->FPA_TIPOSE $ "L;S" // Locaï¿½ï¿½o
			CSEG := "30"
	ENDCASE
	
	cStatusOri := Posicione("FQ5",9, xFilial("FQ5")+FPA->FPA_AS,"FQ5_STATUS")
	dAceite := If( cStatusOri <> '6', CTod(""), dDataBase)

	cNrAS := GERANUMAS( CSEG , cProjet, cObraNew, cSeqNew, xFilial("FPA"), cSeqNew)

	CEQANT  := FPA->FPA_GRUA
	
	CTIPOAS := M->FP0_TIPOSE //28.06.2011 MAICKON - INCLUIDA POIS Nï¿½O ESTAVA GERANDO VIAGEM PARA PLATAFORMA

	CCONDPAG:=FPA->FPA_CONPAG
	CDESCCON:=POSICIONE("SE4",1,XFILIAL("SE4")+CCONDPAG,"E4_DESCRI")

	ADTQ := {}

	DBSELECTAREA("FQ5")
	DBSETORDER(8)

	// Frank em 17/10/23 - card 1227
	// coloquei um reforï¿½o lï¿½gico para evitar a numeracao repetida da viagem,
	// quando ocorria a repetiï¿½ï¿½o era gerado linhas em branco a fq5 e depois deletadas
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
@param PSRV, variant, Tipo do Serviï¿½ï¿½o (FPA_TIPOSE)
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

if M->FP0_TIPFAT = 'P' // Se o tipo de Faturamento for padrï¿½o validar a data de transferencia

	if dDATATRAN < oModelFPA:GetValue("FPA_DTINI") .or. dDATATRAN < oModelFPA:GetValue("FPA_ULTFAT")
		oModel:SetErrorMessage("","","","","LOCA001C_05",STR0013,) // "Data de transferencia nï¿½o foi preenchida!"
		lRet := .F.
	elseif dDATATRAN > oModelFPA:GetValue("FPA_DTFIM")
		oModel:SetErrorMessage("","","","","LOCA001C_02",STR0014,) //"Data de transferencia nï¿½o pode ser posterior a data final do periodo a faturar!" //"Verifique as data do Proximo Faturamento"
		lRet := .F.
	endif

endif

RETURN lRet

/*/{Protheus.doc} Loca001CTok
Validaï¿½ï¿½o do Model ao se pressionar o botï¿½o OK
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
	Help(NIL, NIL, "LOCA001C_12", NIL, STR0062, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0061}) //"Selecione uma obra na lista de obras disponiveis para transferencia!" //"Para realizar a transferencia a obra de destino deverï¿½ ser selecionada!" //"Verifique a Data de Transferencia ou a Obra destino" //"Hï¿½ dados pendentes de validaï¿½ï¿½o na tela."
	Return .F.
endif
// Validar e uma obra foi selecionada
for nX := 1 to oModelFP1:Length()
	if oModelFP1:GetValue("OK", nX)
		nCheck ++
	endif
next

if nCheck <> 1
	Help(NIL, NIL, "LOCA001C_06", NIL, STR0017, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016}) //"Selecione uma obra na lista de obras disponiveis para transferencia!" //"Para realizar a transferencia a obra de destino deverï¿½ ser selecionada!"
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
		M->FQ4_LOG    := STR0018+cBem + STR0019+ M->FQ4_OBRA + STR0020+ cObraDest +STR0063+ cObraDest + " - " + _cUserName + " - " + FWTimeStamp(2,Date(),Time()) //"BEM " //" Transferido da obra " //" para a obra " //" - Obra "
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
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í»ï¿½ï¿½
ï¿½ï¿½ï¿½Programa  ï¿½ MEM2REG  ï¿½ Autor ï¿½ Andre Schwartz     ï¿½ Data ï¿½  17/11/03   ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Desc.     ï¿½Grava as variaveis de memoria criadas pela funcao Regtomemorï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½          ï¿½Modificado por Carlos Queiroz em 07/12/04.                  ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¹ï¿½ï¿½
ï¿½ï¿½ï¿½Uso       ï¿½ AP                                                         ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½Í¼ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½ï¿½
*/

Static Function Mem2Reg( cAlias, lIncluir )          // Mem2Reg("SB1",cOpca == 3)

Local nFilial := 0     							   // Variavel utilizada para receber a filial
Local cAuxMem, x     //  Declaraï¿½ï¿½o de variaveis locais

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
		oModel:SetErrorMessage("","","","","LOCA001C_10",STR0028,) //"Data do proximo Faturamento nï¿½o pode ser inferior a data de inicio ou a data do Ultimo Faturamento."
		lRet := .F.
	elseif dPFat > oModelFPA:GetValue("FPA_DTFIM")
		oModel:SetErrorMessage("","","","","LOCA001C_11",STR0029,) //"Data de Proximo Faturamento nï¿½o pode ser posterior a data final do periodo a faturar!"
		lRet := .F.
	endif

endif

RETURN lRet

/*/{Protheus.doc} LOCA001C_A
Consulta dos tï¿½tulos provisï¿½rios
@type function
@author Frank Zwarg Fuga
@since 19/11/2025
/*/
Function LOCA001C_A(nOpc)
Local oDlg
Local aSizeAut := MSADVSIZE()
Local cTitJan := STR0030 // consulta dos titulos provisorios
Local cCadOld := cCadastro
Local lProcessa := .T.
Local oFilos
Local aButtons := {}
Local lAs := .F.
Local cAs := ""

Private aProv := {}

	If (nOpc <> 4 .and. nOpc <> 2) .or. file("\SYSTEM\LOCA1CERR.TXT")
		lProcessa := .F.
		Help(Nil,	Nil,STR0030,; //"Consulta dos tï¿½tulos provisï¿½rios"
		Nil,STR0031,1,0,Nil,Nil,Nil,Nil,Nil,; //"Opï¿½ï¿½o invï¿½lida."
		{STR0032}) //"Esta consulta estï¿½ disponivel apenas para visualizaï¿½ï¿½o, ou manutenï¿½ï¿½o."
	EndIF

	If FP0->FP0_PROV == "0"
		lProcessa := .F.
		Help(Nil,	Nil,STR0030,; //"Consulta dos tï¿½tulos provisï¿½rios"
		Nil,STR0031,1,0,Nil,Nil,Nil,Nil,Nil,; //"Opï¿½ï¿½o invï¿½lida."
		{STR0033}) //"Este projeto nï¿½o aceita tï¿½tulos provisï¿½rios."
	EndIF

	If lProcessa

		lAs := MsgYesNo(STR0043,STR0044) //"Deseja considerar a AS posicionada?"###"Atenï¿½ï¿½o!"

		If lAs
			cAs := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"})]
			If empty(cAs)
				Help(Nil,	Nil,STR0030,; //"Consulta dos tï¿½tulos provisï¿½rios"
				Nil,STR0031,1,0,Nil,Nil,Nil,Nil,Nil,; //"Opï¿½ï¿½o invï¿½lida."
				{STR0045}) //"Falta o preenchimento da AS no registro posicionado."
				Return .F.
			EndIf
		EndIf

		AADD(aButtons , {STR0042,{|| ConsPrv(oFilos) },OEMTOANSI(STR0042),OEMTOANSI(STR0042)}) //"Visualizar o tï¿½tulo"

		cCadastro := cTitJan
		DEFINE MSDIALOG oDlg FROM aSizeAut[7], 0 to aSizeAut[6], aSizeAut[5] TITLE OEMTOANSI(cTitJan) OF OMAINWND PIXEL

			aProv := {}
			FWMSGRUN(,{|| GERTEMP(cAs)},,STR0034 ) //"Aguarde... Localizando os movimentos financeiros."

			@ 2,0.7 LISTBOX oFilos FIELDS HEADER STR0035,; //"AS"
			STR0036,; //"Tï¿½tulo"
			STR0037,; //"Prefixo"
			STR0038,; //"Parcela"
			STR0039,; //"Perï¿½odo"
			STR0040,; //"Vencimento"
			STR0041,; //"Valor"
			"Ctrl",;
			SIZE 625,230

			oFilos:SETARRAY(aProv)

			cLinha := "{|| { "
			cLinha += "aProv[oFilos:nAt,1],"
			cLinha += "aProv[oFilos:nAt,2],"
			cLinha += "aProv[oFilos:nAt,3],"
			cLinha += "aProv[oFilos:nAt,4],"
			cLinha += "aProv[oFilos:nAt,5],"
			cLinha += "aProv[oFilos:nAt,6],"
			cLinha += "aProv[oFilos:nAt,7],"
			cLinha += "aProv[oFilos:nAt,8],"
			cLinha += "}}"

			oFilos:BLINE := &(cLinha)

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT ENCHOICEBAR(oDlg , {||oDlg:END()} , {|| oDlg:END()} , , aButtons)
		cCadastro := cCadOld

	EndIf

Return .T.

/*/{Protheus.doc} GERTEMP
Gera os movimentos para a consulta dos tï¿½tulos provisï¿½rios
@type function
@author Frank Zwarg Fuga
@since 19/11/2025
/*/
Static Function GERTEMP(cAs)

	FQB->(dbSetOrder(1))
	FQB->(dbSeek(xFilial("FQB")+FP0->FP0_PROJET))
	While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET) == xFilial("FQB")+FP0->FP0_PROJET

		If !empty(cAs)
			If FQB->FQB_AS <> cAs
				FQB->(dbSkip())
				Loop
			EndIF
		EndIf

		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1")+FQB->(FQB_PREF+FQB_PR+FQB_PARC+"PR")))
			aadd(aProv,{FQB->FQB_AS,;
			FQB->FQB_PR,;
			FQB->FQB_PREF,;
			FQB->FQB_PARC,;
			FQB->FQB_PERIOD,;
			SE1->E1_VENCREA,;
			SE1->E1_VALOR,;
			SE1->(Recno())})
		EndIf
		FQB->(dbSkip())
	EndDo

	If len(aProv) == 0
		aadd(aProv,{"","","","","",dtoc(""),0,0})
	EndIf

Return .T.

/*/{Protheus.doc} ConsPrv
Consulta o tï¿½tulo no contas a receber
@type function
@author Frank Zwarg Fuga
@since 19/11/2025
/*/
Static Function ConsPrv(oFilos)
	If aProv[oFilos:nAt,8] > 0
		SE1->(dbSetOrder(1))
		SE1->(dbGoto(aProv[oFilos:nAt,8]))
		
		FA280Visua("SE1", SE1->(Recno()) , 2)
	EndIf
Return .T.



/*/{Protheus.doc} LOCA001SB
Definicao de relatorios Saude Financeira de projetos no Rental
@type function
@author Alessandro Gois
@since 27/11/2025
/*/
function LOCA001SB()

Local aRotina3 := {}

	AADD(aRotina3, {STR0046, "LOCSV020", 0 , 6}) //STR0046 //"Boletim de Mediï¿½ï¿½es"
	AADD(aRotina3, {STR0047, "LOCSV014", 0 , 6}) //STR0047 //"Fat. Parado e Subs. pend dev"
	AADD(aRotina3, {STR0048, "LOCSV009", 0 , 6}) //STR0048 //"Faturas"
	AADD(aRotina3, {STR0049, "LOCSV016", 0 , 6}) //STR0049 //"Hist. Equip Subst"
	AADD(aRotina3, {STR0050, "LOCSV008", 0 , 6}) //STR0050 //"Mediï¿½ï¿½es Lanï¿½adas"
	AADD(aRotina3, {STR0051, "LOCSV019", 0 , 6}) //STR0051 //"Minutas"
	AADD(aRotina3, {STR0052, "LOCSV012", 0 , 6}) //STR0052 //"Reajustes ï¿½ vencer"
	AADD(aRotina3, {STR0053, "LOCSV015", 0 , 6}) //STR0053 //"Receitas e Custos"
	AADD(aRotina3, {STR0054, "LOCSV010", 0 , 6}) //STR0054 //"Remessas"
	AADD(aRotina3, {STR0055, "LOCSV011", 0 , 6}) //STR0055 //"Retornos de locaï¿½ï¿½o"
	AADD(aRotina3, {STR0056, "LOCSV018", 0 , 6}) //STR0056 //"S.S e O.S por Projeto"
	AADD(aRotina3, {STR0057, "LOCSV023", 0 , 6}) //STR0057 //"Timesheet"
	AADD(aRotina3, {STR0058, "LOCSV017", 0 , 6}) //STR0058 //"Tï¿½tulos"
	AADD(aRotina3, {STR0059, "LOCSV007", 0 , 6}) //STR0059 //"Acompanhamento de validade"
	AADD(aRotina3, {STR0060, "LOCSV006", 0 , 6}) //STR0060 //"Tabela Dinï¿½mica de Contratos"
	If FindFunction( "LOCSV027" )
		AADD(aRotina3, {STR0105, "LOCSV027", 0 , 6}) //STR0105 //"Relatï¿½rio de previsto x realizado
	EndIf 
	
return aRotina3

/*/{Protheus.doc} LOCA001CPA
Fonte de mesmo nome e suas funcoes desativadas conforme alinhado com o Lui e o Rafael, sobre nao fazer validaï¿½ï¿½es da FPZ na FPA.
DSERLOCA-10659
@type function
@version 25.10
@author Alessandro Gois
@since 04/02/2026
@return variant, Retorna se o valor do campo pode ser alterado
/*/
Function LOCA001CPA(cAS)
Local lRet := .T.

	if !empty(cAs)
		lRet := .f.
	endif

	if !lRet
		Help(Nil,	Nil,STR0064+alltrim(upper(Procname())),; //"RENTAL: " //"Rental: "
					Nil,STR0065,1,0,Nil,Nil,Nil,Nil,Nil,; // //"Inconsistï¿½ncia nos dados."
					{STR0076}) //"Nï¿½o ï¿½ possï¿½vel alterar o produto desta linha, pois jï¿½ existe uma A.S. gerada. Para realizar a troca, ï¿½ necessï¿½rio cancelar a A.S. existente."
	endif

return lRet


/*/{Protheus.doc} LOCA001CPA
Valida se o valor pode ser alteradado, nï¿½o se pode alterar se:
- A A.S. Estiver em algum pedido
- A A.S. Estiver em uma demanda
- A A.S. Estiver em Romaneio
- A A.S. 
@type function
@version 25.10
@author Alexandre Circenis
@since 03/12/2025
@return variant, Retorna se o valor do campo pode ser alterado
/*/
/*
Function LOCA001CPA(cAS)
Local lRet := .T.

// Verificar se a A.S. estï¿½ em um Pedido
if  Loca001CPD(cAS)
	lRet := .F.
	Help(Nil,	Nil,STR0064+alltrim(upper(Procname())),; //"RENTAL: " //"Rental: "
					Nil,STR0065,1,0,Nil,Nil,Nil,Nil,Nil,; // //"Inconsistï¿½ncia nos dados."
					{STR0066}) //"Alteraï¿½ï¿½o nï¿½o permitida a A.S. jï¿½ teve pedido gerado."
				  
// Verificar se a A.S. estï¿½ em um romaneio
elseif Loca001CRO(cAS)
	lRet := .F.
	Help(Nil,	Nil,STR0064+alltrim(upper(Procname())),; //"RENTAL: " //"Rental: "
					Nil,STR0065,1,0,Nil,Nil,Nil,Nil,Nil,; // //"Inconsistï¿½ncia nos dados."
					{STR0067}) //"Alteraï¿½ï¿½o nï¿½o permitida a A.S. jï¿½ foi incluida em um romaneio."

// Verificar se a A.S. estï¿½ em uma demanda
elseif Loca001CDE(cAS)
	lRet := .F.
	Help(Nil,	Nil,STR0064+alltrim(upper(Procname())),; //"RENTAL: " //"Rental: "
					Nil,STR0065,1,0,Nil,Nil,Nil,Nil,Nil,; // //"Inconsistï¿½ncia nos dados."
					{STR0068}) //"Alteraï¿½ï¿½o nï¿½o permitida a A.S. jï¿½ foi incluida em uma demanda."
endif

Return lRet
*/
/*/{Protheus.doc} LOCA001CPD
Retorna se a A.S. jï¿½ tiver pedido gerado
@type function
@version 25.10
@author Alexandre Circenis
@since 03/12/2025
@param cAS, character, Codigo da A.S. pesquisada
@return variant, Retorna .T. se algum pedido jï¿½ tiver sido gerado para a A.S. informada.
/*/
/*
Function LOCA001CPD(cAS)
Local lRet := .F.
Local cQuery := ""
Local aBindParam := {}
Local cAliasQry

cQuery += "Select FPZ_AS"
cQuery += " from "+RetSqlName("FPZ")+ " FPZ"
cQuery += " INNER JOIN "+RetSqlName("FPY")+ " FPY "
cQuery += " ON FPY_FILIAL = '"+xFilial("FPY")+"' "
cQuery += " AND FPZ_PEDVEN = FPY_PEDVEN"
cQuery += " AND FPY_STATUS = '1' "
cQuery += " AND FPY.D_E_L_E_T_ = ' '"
cQuery += " where FPZ_FILIAL = '"+xFilial("FPY")+"'"
cQuery += " and FPZ_AS = ? "
Aadd( aBindParam, cAS)
cQuery += " and FPZ.D_E_L_E_T_ = ' '"

cQuery := CHANGEQUERY(cQuery)
cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)

lRet := !((cAliasQry)->(Eof())) // Existe um pedido para essa A.S.

Return lRet
*/
/*/{Protheus.doc} LOCA001CRO
Retorna se o a A.S. estï¿½ num romaneio
@type function
@version 25.10
@author Alexandre Circenis
@since 03/12/2025
@param cAS, character, Codigo da A.S. pesquisada
@return variant,  Retorna .T. se algum romaneio jï¿½ tiver sido gerado para a A.S. informada.
/*/
/*
Function LOCA001CRO(cAS)
Local lRet := .F.
Local cQuery := ""
Local aBindParam := {}
Local cAliasQry

cQuery += "Select FQ3_AS"
cQuery += " from "+RetSqlName("FQ3")+ " FQ3"
cQuery += " where FQ3_FILIAL = '"+xFilial("FQ3")+"'"
cQuery += " and FQ3_AS = ? "
Aadd( aBindParam, cAS)
cQuery += " and FQ3.D_E_L_E_T_ = ' '"
cQuery += " UNION "
cQuery += "Select FQV_AS"
cQuery += " from "+RetSqlName("FQV")+ " FQV"
cQuery += " where FQV_FILIAL = '"+xFilial("FQV")+"'"
cQuery += " and FQV_AS = ? "
Aadd( aBindParam, cAS)
cQuery += " and FQV.D_E_L_E_T_ = ' '"

cQuery := CHANGEQUERY(cQuery)
cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)

lRet := !((cAliasQry)->(Eof())) // Existe um romaneio para essa A.S.

Return lRet
*/

/*/{Protheus.doc} LOCA001CDE
Retorna se o a A.S. estï¿½ numa demanda
@type function
@version 25.10
@author Alexandre Circenis
@since 03/12/2025
@param cAS, character, Codigo da A.S. pesquisada 
@return variant,  Retorna .T. se alguma demanda jï¿½ tiver sido gerada para a A.S. informada.
/*/
/*
Function LOCA001CDE(cAS)
Local lRet := .F.
Local cQuery := ""
Local aBindParam := {}
Local cAliasQry

cQuery += "Select FQ5_AS"
cQuery += " from "+RetSqlName("FQ5")+ " FQ5"
cQuery += " where FQ5_FILIAL = '"+xFilial("FQ5")+"'"
cQuery += " and FQ5_AS = ? "
Aadd( aBindParam, cAS)
cQuery += " and FQ5_DEMAND <> ' '"
cQuery += " and FQ5.D_E_L_E_T_ = ' '"

cQuery := CHANGEQUERY(cQuery)
cAliasQry := MPSysOpenQuery(cQuery,,,,aBindParam)

lRet := !((cAliasQry)->(Eof())) // Existe uma demanda para essa A.S.

Return lRet
*/
/*/{Protheus.doc} LOCA001CA
Preencher a data final (FPA_DTENRE) com base na quantidade de parcelas
Regra exclusiva para dias corridos
@type function
@author Frank Zwarg Fuga
@since 11/12/2025
/*/
Function LOCA001CA
Local dFinal  := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_DTENRE"})]
Local dInicio := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_DTINI"})]
Local nLocDia := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_LOCDIA"})]
Local nQtdPrc := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_QTDPRC"})]

	If oDlgObr:acols[oDlgObr:nAt][ascan(oDlgObr:aHeader,{|X|alltrim(X[2])=="FP1_TPMES" })] == "1" // dias corridos

		If !empty(dInicio)
			If nLocDia > 0 .and. nQtdPrc > 0
				dFinal := (dInicio + (nLocDia * nQtdPrc)) - 1
			EndIf
		EndIf
	
	Else // mes fixo, ou fechado

		If !empty(dInicio)
			If nQtdPrc > 0
				dFinal := LOCA001CB(dInicio, nQtdPrc)
			EndIf
		EndIf

	EndIf

Return dFinal

/*/{Protheus.doc} LOCA001CB
Calculo de dadas para mes fechado, ou fixo
Somar nos meses e repetir o dia
Levar em consideraï¿½ï¿½o se o dia for o ï¿½ltimo do mï¿½s, ajustar para o calculado
31/01/26 com 1 mï¿½s na soma = 28/02/26 
28/02/26 com 1 mï¿½s na soma = 31/03/26
30/04/26 com 1 mï¿½s na soma = 31/05/26
01/05/26 com 10 meses na soma = 01/03/27
@type function
@author Frank Zwarg Fuga
@since 11/12/2025
/*/
Function LOCA001CB(dData, nCalc)
Local nContador := 0
Local nMes
Local nAno
Local dDataX
Local nTotDias 
Local nDiaOri
Local dDataOri
Local lUltimo := .F.

    dDataOri := dData
    If day(dDataOri) == day(lastday(dData))
        lUltimo := .T.
    EndIf

    nDiaOri := day(dData)
    nMes := month(dData)
    nAno := year(dData)
    For nContador := 1 to nCalc
        nMes ++
        If nMes == 13
            nMes := 1
            nAno ++
        EndIf
    Next

    dDataX := ctod("01/"+alltrim(str(nMes))+"/"+alltrim(str(nAno)))
    nTotDias := day(lastdate(dDataX))

    If nDiaOri > nTotDias .or. lUltimo
        dData := ctod(alltrim(str(nTotDias))+"/"+alltrim(str(nMes))+"/"+alltrim(str(nAno)))
    Else
        dData := ctod(alltrim(str(nDiaOri))+"/"+alltrim(str(nMes))+"/"+alltrim(str(nAno)))
    EndIf

	dData := dData - 1

Return dData

/*/{Protheus.doc} LOCA001CC
Localiza a quantidade de dias para locaï¿½ï¿½o
@type function
@author Frank Zwarg Fuga
@since 17/12/2025
/*/
Function LOCA001CC
Local dIni    := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTINI"})]
Local dFimOld := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_DTFIM"})]
Local dFim    := dFimOld
Local nLocDia := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_LOCDIA"})]
Local cAs     := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_AS"})]
Local cViagem := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_VIAGEM"})]
// JTBD_FPA_LOCDIA: usar M-> evita indice invalido quando FPA_ULTFAT nao esta no cabecalho do grid
Local dFat    := ODLGPLA:ACOLS[ODLGPLA:NAT][ASCAN(ODLGPLA:AHEADER,{|X|ALLTRIM(X[2])=="FPA_ULTFAT"})]//M->FPA_ULTFAT

    If alltrim(upper(ReadVar())) == "M->FPA_DTINI"
        dIni := &(ReadVar())
    EndIf

    If alltrim(upper(ReadVar())) == "M->FPA_AS"
        cAs := &(ReadVar())
    EndIf

    If alltrim(upper(ReadVar())) == "M->FPA_VIAGEM"
        cViagem := &(ReadVar())
    EndIf			

    If alltrim(upper(ReadVar())) == "M->FPA_DTFIM"
        dFim := &(ReadVar())
		FPA->(dbSetOrder(3))
		FPA->(dbSeek(xFilial("FPA")+cAs+cViagem))
        // JTBD_FPA_LOCDIA: nao recalcular se o valor de FPA_DTFIM nao foi alterado
        If dFim == FPA->FPA_DTFIM
            Return nLocDia
        EndIf
        // JTBD_FPA_LOCDIA: usar FPA_ULTFAT como data base quando houver faturamento previo
        If !Empty(dFat)
            nLocDia := dFim - dFat
        ElseIf !Empty(dIni) .and. !Empty(dFim)
            nLocDia := (dFim - dIni) + 1
        EndIf
        Return nLocDia
    EndIf

Return nLocDia


/*/{Protheus.doc} LOCA001CG
Valida se processa o gatilho LOCA001CA
@type function
@author Frank Zwarg Fuga
@since 17/12/2025
/*/
Function LOCA001CG(nTipo)
Local dInicio    := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_DTINI"})]
Local nLocDia    := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_LOCDIA"})]
Local nQtdPrc    := oDlgPla:aCols[oDlgPla:nAt][ascan(oDlgPla:aHeader,{|X|alltrim(X[2])=="FPA_QTDPRC"})]
Local lRet       := .T.
Local lMV_LOC278 := supergetmv("MV_LOCX278",,.F.)

Default nTipo := 1

	If nTipo == 1
		If empty(dInicio) .or. nLocDia == 0 .or. nQtdPrc == 0 
			lRet := .F.
		EndIf
	EndIf
	If nTipo == 2
		If FP0->(FieldPos("FP0_PROV")) > 0
			If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
				lMV_LOC278 := .T.
			Else
				lMV_LOC278 := .F.
			EndIf
		EndIf
		If lMV_LOC278
			lRet := .F.
		EndIf
	EndIf

Return lRet


/*/{Protheus.doc} LOCA001CH
Campos FP0_TOTCV e FP0_VLRMV inicializador padrï¿½o
Necessario estar posicionado na FP0 para a chamada desta funï¿½ï¿½o
@type function
@author Frank Zwarg Fuga
@since 12/17/2025
/*/
Function LOCA001CH(nTipo)
Local nValor     := 0
Local lMV_LOCX67 := SuperGetMv("MV_LOCX067",,.T.)
Local aAreaFPA   := FPA->(GetArea())
Local lProc1     := .F. // Indica que tem nota de remessa
Local lProc3     := .F.
Local nFpy       := 0
Local aFpy       := {}
Local nX
Local lTem

	If FP0->FP0_TIPFAT == "P"

		// lMV_LOCX67 == .T. -> somente equipamentos que foram remessados e que nï¿½o foram devolvidos (dt.sol.retirada)
		// lMV_LOCX67 == .F. -> todos os equipamentos que nao foram devolvidos (dt.sol.retirada)

		// Para o contrato posicionado validar todas as ocorrï¿½ncias da FPA 
		// e totalizar com base em todas as obras
		lCalcula := .F.
		lProc1   := .F. // indica que a linha da FPA foi remessada
		lProc2   := .F. // indica que a linha da FPA teve faturamento
		FPA->(dbSetOrder(1))
		FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
		While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == FP0->FP0_PROJET

			// Neste momento o campo chave é a AS
			FPZ->(dbSetOrder(2)) // por AS
			FPZ->(dbSeek(xFilial("FPZ")+FPA->FPA_AS))

			nFpy   := 0
			lProc1 := .F. // indica que a linha da FPA foi remessada
			lProc2 := .F. // indica que a linha da FPA teve faturamento
			While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+FPA->FPA_AS .and. !empty(FPA->FPA_AS)
				
				FPY->(dbSetOrder(1))
				If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
					If alltrim(FPY->FPY_STATUS) == "1" .and. FPY->FPY_TIPFAT == "R"
						lProc1 := .T.
					EndIf
					If alltrim(FPY->FPY_STATUS) == "1" .and. FPY->FPY_TIPFAT == "P"
						
						lTem := .F.
						For nX := 1 to len(aFpy)
							If aFpy[nX] == FPY->FPY_PEDVEN
								lTem := .T.
							EndIf
						Next
						If !lTem
							aadd(aFpy,FPY->FPY_PEDVEN)
							nFpy ++
						EndIf

					EndIf
				EndIf

				FPZ->(dbSkip())
			EndDo

			If empty(FPA->FPA_DTSCRT) // Data da solicitação de retirada
				lProc3 := .T. // indica que nao teve devolução
			EndIf

			If lMV_LOCX67 // remessados sem devolução
				// Teve remessa e não foi devolvido
				If lProc1 .and. lProc3
					If nTipo == 1 // Localiza o valor total do contrato vigente para o campo FP0_TOTCV
						If FPA->FPA_QTDPRC > 0 
							nValor += ( FPA->FPA_VRHOR * ( FPA->FPA_QUANT * ( FPA->FPA_QTDPRC - nFpy ) ) )
						EndIf
					Else // Localiza o valor mensal vigente para o campo FP0_VLRMV
						nValor += FPA->FPA_VRHOR
					EndIF
				EndIf
			Else // sem devolucao
				// não foi devolvido
				If lProc3
					If nTipo == 1 // Localiza o valor total do contrato vigente para o campo FP0_TOTCV
						If FPA->FPA_QTDPRC > 0 
							nValor += ( FPA->FPA_VRHOR * ( FPA->FPA_QUANT * ( FPA->FPA_QTDPRC - nFpy ) ) )
						EndIf
					Else // Localiza o valor mensal vigente para o campo FP0_VLRMV
						nValor += FPA->FPA_VRHOR
					EndIf
				EndIf
			EndIf

			FPA->(dbSkip())
		EndDo


	Else

		nValor := 0

	EndIf

	FPA->(RestArea(aAreaFPA))

Return nValor

Function LOCA001CI()
Local cRetorno := ""

	cRetorno := STR0077+";" //"1=Digitação"
	cRetorno += STR0078+";" //"2=Em aprovação"
	cRetorno += STR0079+";" //"3=Aprovado"
	cRetorno += STR0080+";" //"4=Não aprovado"
	cRetorno += STR0081+";" //"5=Efetivado"
	cRetorno += STR0082+";" //"6=Cancelado"
	cRetorno += STR0083+";" //"7=Rejeitado"
	cRetorno += STR0084+";" //"8=Finalizado"
	cRetorno += STR0085+";" //"A=Revisado"
	cRetorno += STR0086+";" //"B=Excluído"
	cRetorno += STR0087 //"C=Perdido"

Return cRetorno

/*/{Protheus.doc} LOCA001CVQ
ITUP BUSINESS - TOTVS RENTAL
Valida se o saldo de FPA_QUANT esta consistente com os registros de FQZ para o projeto.
Detecta casos onde FQZ foi criado sem que FPA_QUANT fosse debitado (ex: falha de RecLock).
Compativel com Oracle e SQL Server.
@type function
@version 1.0
@author DSERLOCA-11218
@since 10/03/2026
@param cProjet, character, Codigo do Projeto a ser validado
@return logical, .T. (apenas exibe divergencias em tela, nao bloqueia gravacao)
/*/
Function LOCA001CVQ(cProjet)
// ISSUE: DSERLOCA-11218 - Rafael S. - 23/04/2026 - Corrige THREAD ERROR SPON010126740: substitui COALESCE por ISNULL, ORDER BY posicional, fechamento seguro de alias
Local aResult   := {}
Local aArea     := GetArea()
Local nQuant    := 0
Local nEnvio    := 0
Local nDevol    := 0

	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA")+cProjet))
	While !FPA->(Eof()) .and. FPA->(FPA_FILIAL+FPA_PROJET) == xFilial("FPA")+cProjet
		
		// Quantidade atual na FPA
		nQuant := FPA->FPA_QUANT

		// Quantidade remessada
		nEnvio := 0
		FPZ->(dbSetOrder(2))
		FPZ->(dbSeek(FPA->FPA_FILREM+FPA->FPA_AS))
		While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == FPA->FPA_FILREM+FPA->FPA_AS
			FPY->(dbSetOrder(1))
			FPY->(dbSeek(FPZ->FPZ_FILIAL+FPZ->FPZ_PEDVEN))
			If FPY->FPY_TIPFAT == "R"
				nEnvio += FPZ->FPZ_QUANT
			EndIf
			FPZ->(dbSkip())
		EndDo

		// Quantidade retornada
		nDevol := 0
		FQZ->(dbSetOrder(2))
		FQZ->(dbSeek(FPA->FPA_FILREM+FPA->FPA_PROJET))
		While !FQZ->(Eof()) .and. FQZ->(FQZ_FILIAL+FQZ_PROJET) == FPA->FPA_FILREM+FPA->FPA_PROJET
			If FQZ->FQZ_AS == FPA->FPA_AS .and. alltrim(FQZ->FQZ_PV) <> 'X'
				nDevol := FQZ->FQZ_QTD
			EndIf
			FQZ->(dbSkip())
		EndDo

		If nQuant - (nEnvio - nDevol) > 0.001 .and. nDevol > 0
			aRow := {}
			AADD(aRow, ALLTRIM(FPA->FPA_AS))
			AADD(aRow, ALLTRIM(FPA->FPA_PRODUT))
			AADD(aRow, ALLTRIM(FPA->FPA_PROJET))
			AADD(aRow, ALLTRIM(FPA->FPA_OBRA))
			AADD(aRow, ALLTRIM(FPA->FPA_NFREM))
			AADD(aRow, ALLTRIM(FPA->FPA_SERREM))
			AADD(aRow, nQuant)
			AADD(aRow, nEnvio)
			AADD(aRow, nDevol)
			AADD(aRow, nEnvio - nDevol)
			AADD(aRow, nQuant - (nEnvio - nDevol))
			AADD(aRow, ALLTRIM(FPA->FPA_NFRET))
			AADD(aResult, aRow)
			
		EndIf

		FPA->(dbSkip())
	EndDo

	IF !Empty(aResult)
		// DSERLOCA-11218 - exibe divergencias em tela sem bloquear gravacao
		LOCA001CVD(cProjet, aResult)
	ENDIF

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} LOCA001CVD
ITUP BUSINESS - TOTVS RENTAL
Exibe em tela as divergencias de saldo FPA x FQZ encontradas para o projeto.
@type function
@version 1.0
@author DSERLOCA-11218
@since 10/03/2026
@param cProjet,  character, Codigo do Projeto
@param aResult,  array,     Array de divergencias coletado por LOCA001CVQ
@return NIL
/*/
Static Function LOCA001CVD(cProjet, aResult)
Private oDlgVld
Private oLstVld
Private aResVld := {}

	aResVld := aResult

	// DSERLOCA-11218 - dialog de apresentacao das divergencias FPA x FQZ
	// Colunas: AS(1), Produto(2), Projeto(3), Obra(4), NF Remessa(5), Serie(6),
	//          FPA_QUANT(7), Qtd Original(8), Total FQZ(9), Saldo Calc.(10), Diferenca(11), NF Retorno(12)
	Define MSDialog oDlgVld title STR0088 + ALLTRIM(cProjet)  from 0,0 to 250,700 pixel //"Inconsistencia FPA x FQZ - Projeto: "

	/*
	"Produto" - STR0089
	"Projeto" - STR0090
	"Obra" - STR0091
	"NF Remessa" - STR0092
	"Serie" - STR0093
	"Quantidade" - STR0094
	"Qtd Original" - STR0095
	"Total" - STR0096
	"Saldo Calc." - 
	"Diferenca" - STR0098
	"NF Retorno" - 
	*/
	@ 08,04 LISTBOX oLstVld FIELDS HEADER ;
		"AS", STR0089, STR0090, STR0091, STR0092, STR0093, ;
		STR0094, STR0095, STR0096, STR0097, STR0098, STR0099 ;
		SIZE 345,110 OF oDlgVld PIXEL

	oLstVld:SetArray(aResVld)
	oLstVld:bLine := {|| { ;
		ALLTRIM(aResVld[oLstVld:nAt,  1]),;
		ALLTRIM(aResVld[oLstVld:nAt,  2]),;
		ALLTRIM(aResVld[oLstVld:nAt,  3]),;
		ALLTRIM(aResVld[oLstVld:nAt,  4]),;
		ALLTRIM(aResVld[oLstVld:nAt,  5]),;
		ALLTRIM(aResVld[oLstVld:nAt,  6]),;
		TRANSFORM(aResVld[oLstVld:nAt,  7], "@E 9,999.999"),;
		TRANSFORM(aResVld[oLstVld:nAt,  8], "@E 9,999.999"),;
		TRANSFORM(aResVld[oLstVld:nAt,  9], "@E 9,999.999"),;
		TRANSFORM(aResVld[oLstVld:nAt, 10], "@E 9,999.999"),;
		TRANSFORM(aResVld[oLstVld:nAt, 11], "@E 9,999.999"),;
		ALLTRIM(aResVld[oLstVld:nAt, 12]) }}

	oLstVld:Refresh()

	Activate MSDialog oDlgVld Centered

Return

// Para facilitar na passagem do advpr
function LOCA001CX
Return .T.

/*/{Protheus.doc} LOCA001FL
Reativação de Contrato
@type function
@author Dennis Calabrez
@since 20/05/2026
/*/
Function LOCA001FL()
Local cQuery := ""
Local aBindParam := {}
Local cCodUsr    := ""
Local cNomUsr    := ""

    cCodUsr    := RetCodUsr()
    cNomUsr    := Alltrim( UsrRetName(cCodUsr)  )

	FP0->(dbSetOrder(1))
	If FP0->(dbSeek(xFilial("FP0")+FP0->FP0_PROJET))

		If FP0->FP0_STATUS <> "8"
			FWAlertWarning(STR0100,STR0101) //"Somente Contratos com Status 8 (Finalizado/Faturado) podem ser reativados" //"LOCA001FL"
			Return(.F.)
		Else
			RecLock('FP0', .F.)
			FP0->FP0_STATUS := "5"
			FP0->FP0_DTRETO := CTOD("")
			FP0->FP0_DTVALI := CTOD("")
			FP0->(MsUnlock())
			FWAlertSuccess(STR0102,STR0101)			 //"Contrato reativado com Sucesso" //"LOCA001FL"
		EndIf

		LOCACLOSE("TRBP9")
		cQuery += "SELECT FP9_PROJET, FP9.R_E_C_N_O_ REC "
		cQuery += " FROM "+RetSqlName("FP9")+ " FP9"
		cQuery += " WHERE FP9_FILIAL = '"+xFilial("FP9")+"'"
		cQuery += " AND FP9_PROJET = ? "
		Aadd( aBindParam, FP0->FP0_PROJET)

		cQuery += " AND FP9.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY FP9.R_E_C_N_O_ DESC "

		cQuery := CHANGEQUERY(cQuery)
		MPSysOpenQuery(cQuery,"TRBP9",,,aBindParam)

		If !TRBP9->(Eof())
			FP9->(DbGoTo(TRBP9->REC))
			RecLock('FP9', .F.)
			FP9->FP9_FOLLOW := STR0104 + cNomUsr + STR0103 + dtoc(dDataBase) + " " + Time() //" na data " //"Contrato reativado por "
			FP9->(MsUnlock())
		EndIf

	EndIf
Return ()


/*/{Protheus.doc} LOCA00116
Validação sobre as notas de entrada
Chamado na confirmação da gravação da manutenção do orçamento
DSERLOCA-12229 - Frank em 27/05/2026
@type function
@version v1 
@author Frank Zwarg Fuga
@since 27/05/2026
/*/
Function LOCA00116
Local lRet := .T.
Local lLOCX067 := supergetmv("MV_LOCX067",,.F.)
Local nX
Local nPosAS := 0
Local nPosRet := 0
Local nPosSer := 0
Local cAs
Local cProjet := FP0->FP0_PROJET
Local nRet := 0
Local nEnv := 0
Local cNotaRet := ""
Local cSerRet := ""
Local nRegistro := 0

	// este array é criado como private no LOCA001
	// na gravação as informações aqui geradas serão utilizadas para o preenchimento dos campos
	aAjusteNFE := {} 

	If lLOCX067 .AND. !IsInCallStack( 'loca00106' )

		nPosAS := aScan(oDlgPla:aHeader,{ |x| AllTrim(x[02]) == "FPA_AS" })
		nPosRet := aScan(oDlgPla:aHeader,{ |x| AllTrim(x[02]) == "FPA_NFRET" })
		nPosSer := aScan(oDlgPla:aHeader,{ |x| AllTrim(x[02]) == "FPA_SERRET" })

		For nX := 1 to len(ODLGPLA:aCols)
			If !ODLGPLA:aCols[nX][len(ODLGPLA:aHeader)+1]

				cAs := ODLGPLA:aCols[nX][nPosAs]
				cNotaRet := ODLGPLA:aCols[nX][nPosRet]
				cSerRet := ODLGPLA:aCols[nX][nPosSer]

				nRet := 0
				nEnv := 0
				If !empty(cAs)
					FPZ->(dbSetOrder(2))
					FPZ->(dbSeek(xFilial("FPZ")+cAs))
					While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+cAs
						FPY->(dbSetOrder(1))
						If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
							If alltrim(FPY->FPY_STATUS) <> "2" .and. FPY->FPY_TIPFAT == "R"
								nEnv := FPZ->FPZ_QUANT
								Exit
							EndIF
						EndIf
						FPZ->(dbSkip())
					EndDo
				EndIF

				If nEnv > 0 // quantidade da remessa
					
					nRegistro := 0
					FQZ->(dbSetOrder(2))
					FQZ->(dbSeek(xFilial("FQZ")+cProjet))
					While !FQZ->(Eof()) .and. FQZ->(FQZ_FILIAL+FQZ_PROJET) == xFilial("FQZ")+cProjet
						If FQZ->FQZ_AS == cAs .and. FQZ->FQZ_MSBLQL == "2"
							nRet += FQZ->FQZ_QTD
							If FQZ->(Recno()) > nRegistro
								nRegistro := FQZ->(Recno())
							EndIf
						EndIf
						FQZ->(dbSkip())
					EndDo

					// Retornou 100%
					If nEnv == nRet 
						If (empty(cNotaRet) .or. empty(cSerRet)) .and. nRegistro > 0
							FQZ->(dbGoto(nRegistro))
							aadd(aAjusteNFE ,{ 	FQZ->FQZ_EMISS,;
												FQZ->FQZ_DOC,;
												FQZ->FQZ_SERIE,;
												FQZ->FQZ_ITEM,;
												cAs })
						EndIf
					EndIF

				EndIF

			EndIf
		Next


	EndIf

Return lRet
