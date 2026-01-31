#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#INCLUDE "PSHPROMOCTRL.CH"


//------------------------------------------------------------------
/*/{Protheus.doc} PshDescT
Calcula o desconto no total.

@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function PshDescT(nVlrPago,lAbateISS,nValAbISS,cFormPagto,nVlPromo)
Local nDescAnt    := 0
Local nDescCalc   := 0
Local nValor      := Lj7T_Total( 2 )-nVlrPago - If( lAbateISS, nValAbISS, 0 )
Local nDesc       := 0


nDesc := nVlPromo //Recebe o valor desconto

If nDesc > 0
    nDescCalc := lj7Arred(2, 3, nVlPromo)//lj7Arred(2, 3,  ((nDesc / 100) * nValor) )  // % Valor do desconto a ser aplicado (regra de desconto)

    //Abate o valor descontado no total
    Lj7T_DescV( 2, nDescAnt + nDescCalc  )
    //Valida por valor
    VldPer(1)

    //Abate o Desconto no Valor da Forma
    nValor -= nDescCalc
    LjSetDesFP(1,.T.)	//reseta o array estatico aDescTotFP(LOJA3026.PRW)
    //³ aDesconto[1] := 0-Nao tem desconto, 1-Antes da condicao de pagamento  2-Depois da condicao de pagamento
    //³ aDesconto[2] := 0%	// Porcentagem de Desconto                      ³
    //³ aDesconto[3] := 0	// Valor de Desconto                            ³
    //³ aDesconto[4] := .T.	// Desconto Motor de Promocoes         ³
    aDesconto := { 2, Lj7T_DescP(2), Lj7T_DescV(2),.T.} //Private usado para atualizar a tela.
    // Atualiza array aRetLj7T com os valores de totais
    LjSetLj7T( 1, M->LQ_NUM, Lj7T_SUBTOTAL(2), Lj7T_DESCP(2), Lj7T_DESCV(2), Lj7T_TOTAL(2) )
EndIf
    
Return nValor

//------------------------------------------------------------------
/*/{Protheus.doc} PshDesIt
Valida se o desconto ja foi aplicado para forma de pagamento.

@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Function PshDesIt(cItem,cProd,nDesc,cFormPagto)
Local nX     := 0
Local nBkp   := n
Local xReadbkp:= __ReadVar
Local aBkpPgtos := {}   
Local nPosItem  := 0
Local nPosProd  := 0
Local nPosVrUni := 0 


nPosItem     := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ITEM"})][2]
nPosProd     := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]
nPosVrUni    := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]
AADD(aBkpPgtos,{aclone(OPGTOS:AARRAY) ,aClone(OPGTOSSINT:AARRAY),aClone(APGTOS),aClone(APGTOSSINT)})

ProcRegua(Len(aCols))

For nX:= 1 To Len(aCols)
    IncProc(STR0007 + Alltrim(cItem +STR0008+cProd))//"Aplicando Desconto no Item:" " Produto: "
    If Alltrim(cItem)+Alltrim(cProd) == Alltrim(aCols[nX][nPosItem])+Alltrim(aCols[nX][nPosProd])
        __ReadVar := "M->LR_VALDESC"
        M->LR_VALDESC:= nDesc
        n := nX
        Lj7VlItem(4,.T.)
        VldPer(1)
    EndIf
NEXT

OPGTOS:AARRAY     := aClone(aBkpPgtos[1][1])
OPGTOSSINT:AARRAY := aClone(aBkpPgtos[1][2])
APGTOS	          := aClone(aBkpPgtos[1][3])
APGTOSSINT        := aClone(aBkpPgtos[1][4])
n := nBkp
__ReadVar := xReadbkp


Return
//------------------------------------------------------------------
/*/{Protheus.doc} VldPer
Valida se o desconto ja foi aplicado para forma de pagamento.

@author Everson S P Junior
@since  29/08/2022
/*/
//-------------------------------------------------------------------
Static function VldPer(nOpcDesc)

Local aDesc 		:= {}				// Array com as informacoes de desconto
Local lRet 			:= .F.				// Retorno da funcao
Local nValorDesc 	:= 0				// Valor de desconto
Local nValFret		:= Lj7CalcFrete()

Default nOpcDesc 	:= 1					// Opcao escolhida

Do Case
	//³Mantem o valor do desconto³
	Case nOpcDesc == 1
		nValorDesc := ( 100 * Lj7T_DescV(2) ) / LJ7T_SubTotal(2)
		aDesc := {"P",nValorDesc}

		//³Verifica permissao para desconto³

		If LjProfile(11, Nil, aDesc, nValorDesc, Lj7T_DescV(2))
			Lj7T_DescP( 2, nValorDesc )
			Lj7T_Total( 2, (LJ7T_SubTotal(2) + nValFret) - Lj7T_DescV(2) - LjPCCRet() )
			nValorDesc	:= 0
			lRet := .T.
		EndIf
	Case nOpcDesc == 2
		Lj7T_DescP( 2,0 )
		Lj7T_DescV( 2,0 )
		Lj7T_Total( 2, (LJ7T_SubTotal(2) + nValFret) )
		lRet := .T.
    EndCase

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PshLimpIt
Limpa os descontos no Acols aplicado pelo Motor de Promocoes.

@author  Everson S P Junior
@since 	 03/04/2023
@version 12

@return nil
/*/
//------------------------------------------------------------------------------
Function PshLimpIt()
Local nX 		:= 0
Local nInd		:= 1
Local nBkp   	:= n
Local xReadbkp	:= __ReadVar

PshCodMTP()//Limpa o Array de codigo de promoções.
ProcRegua(Len(aCols))
For nX:= 1 To Len(aCols)
	 IncProc(STR0001 + Alltrim(Str(nX)))//"Excluindo Promoção do Item... "
    If !Acols[nX][Len(Acols[nX])]
        __ReadVar := "M->LR_VALDESC"
        M->LR_VALDESC:= 0
        n := nX
        VldPer(2)
        Lj7VlItem(4,.T.)
    EndIf    
Next

n := nBkp
__ReadVar := xReadbkp

While MaFisFound("IT",nInd)
	MaFisLoad("IT_DESCONTO", 0, nInd) //Retira da MATXFIS, todos os descontos para recalcular
	nInd++
End

//Recalcula MatxFis
For nInd:=1 To Len(aCols)
	If MaFisFound("IT",nInd)
		MaFisRecal("IT_DESCONTO",nInd)
	EndIf
Next nInd


Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} PshAtivMTP
Verifica se esta ativo Motor de promoções

@author  Everson S P Junior
@since 	 03/04/2023
@version 12

@return nil
/*/
//------------------------------------------------------------------------------
Function PshAtivMTP()
Local lRet 		:= .F.

lRet 	:= SuperGetMv("MV_LJMTPRO",,.F.) .AND.;//Indica se usa nova regra de desconto Motor de promções
ExistFunc("PshMtProm") .AND. ExistFunc("PshMtPdvP") .AND. ExistFunc("PshAtivMTP") .AND. ExistFunc("PshAplProm") .AND. ExistFunc("PshMsgDel") .AND. ExistFunc("PshLimpIt") .AND. ExistFunc("PshMsgAlt")
//Verifica todas as func do motor de promoções

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} PshMsgDel
Verifica se esta ativo Motor de promoções recaldula os itens na Deleção
do carrinho.

@author  Everson S P Junior
@since 	 03/04/2023
@version 12

@return nil
/*/
//------------------------------------------------------------------------------
Function PshMsgDel()
Local lRet 		:= .T.

MsgInfo(STR0004 + CHR(10) + CHR(13) + STR0002)//"Item deletado no carrinho os valores de descontos e os pagamentos escolhidos serão zerados! " ,"Motor de Promoções"
    Lj7ZeraPgtos(,,,,,.T.)	
    LjGrvLog( NIL, "Parâmetro MV_LJMTPRO está configurado com [.T.] " + CHR(10) + CHR(13) +;
        " Regra de desconto Motor de Promoções ativo será zerado" )

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PshMsgAlt
Verifica se esta ativo Motor de promoções recaldula os itens na alteração
do carrinho.

@author  Everson S P Junior
@since 	 03/04/2023
@version 12

@return nil
/*/
//------------------------------------------------------------------------------
Function PshMsgAlt(nField,lAuto,lRecpDelet)
Local lRet 		:= .T.

Default lAuto   := .F.
Default nField  := 5
Default lRecpDelet := .F.

If (nField == 3 .OR. nField == 4)
    If !lAuto
        MsgStop(STR0005)//"Não é permitido aplicar desconto manual a integração com Motor de Promoções esta ativa!
        lRet    := .F.
    EndIf    
EndIf

If !lAuto .AND. (nField == 0 .OR. nField == 1)
    If !lRecpDelet .AND. MSGYESNO(STR0006 + CHR(10) + CHR(13) +; 
            STR0003,STR0004)//"Alterar algum item no carrinho os valores de descontos e pagamentos selecionados serão zerados! " "Deseja Continuar?","Motor de Promoções"
        Lj7ZeraPgtos(,,,,,.T.)	
        LjGrvLog( NIL, "Parâmetro MV_LJMTPRO está configurado com [.T.] " + CHR(10) + CHR(13) +;
            " Regra de desconto Motor de Promoções ativo será zerado" )
        lRet := .T.
    elseIf lRecpDelet//"Item deletado sendo recuperado
        MsgInfo(STR0004 + CHR(10) + CHR(13) + STR0002)//"Item deletado no carrinho os valores de descontos e os pagamentos escolhidos serão zerados! " ,"Motor de Promoções"
        Lj7ZeraPgtos(,,,,,.T.)	
        LjGrvLog( NIL, "Recuperando um delete Parâmetro MV_LJMTPRO está configurado com [.T.] " + CHR(10) + CHR(13) +;
            " Regra de desconto Motor de Promoções ativo será zerado" )
    else
        lRet := .F.
    EndIf
EndIf

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} PshMsgInfo
Exibir a tela com mensagem de promoções

@type 	 Static Function
@author  Everson S P Junior
@since 	 03/04/2023
@version 12

@return nil
/*/
//------------------------------------------------------------------------------
Function PshMsgInfo()
Local aMsgPro   := {}
Local nX        := 0
Local cMsg      := ""

aMsgPro := aClone(PshArrayMP())

If Len(aMsgPro) > 0
    For nX := 1 To Len(aMsgPro)
        cMsg += "PROMOÇÕES APLICADAS NA VENDA : " +aMsgPro[nX][2][4] + CHR(10) + CHR(13)
        cMsg += "CODIGO DA PROMOÇÕES : "+aMsgPro[nX][2][6] + CHR(10) + CHR(13)
    next
    MsgInfo(cMsg + CHR(10) + CHR(13))
EndIf

Return
