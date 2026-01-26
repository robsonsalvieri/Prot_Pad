#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "STBITEMCHECK.CH"

//------------------------------------------------------------------------------
/*{Protheus.doc} STBItLstCk
Função para montar itens para Dialog de conferencia
@param   	aSL2     
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/2018
@return     aRet
/*/
//------------------------------------------------------------------------------
Function STBItLstCk( aSL2 )
Local aRet 			:= {}
Local aStItemChk	:= {}
Local nX			:= 0
Local nTamL2ITEM	:= TamSX3("L2_ITEM")[1]
Local cItem			:= Replicate("0",TamSX3("L2_ITEM")[1])			//tratamento do sequencial do item
Local aItem			:= {}
Local cDescItem		:= ""
Local nPosQUANT		:= AScan( aSL2[1] , { |x| x[1] == "L2_QUANT"	} 	)
Local nPosPRODUTO	:= AScan( aSL2[1] , { |x| x[1] == "L2_PRODUTO"	} 	)
Local nPosENTREGA	:= AScan( aSL2[1] , { |x| x[1] == "L2_ENTREGA"	} 	)
Local lStItemChk  	:= ExistBlock("STITEMCHK")

For nX := 1 to Len(aSL2)

	cItem 	:= Soma1(cItem,nTamL2ITEM)
	aItem	:= STWFindItem( aSL2[nX][nPosPRODUTO][2] )

	If !aItem[ITEM_ENCONTRADO]
		LjGrvLog("Importa_Orcamento:STBItemCheck","Item Nao encontrado na base, chama rotina: STBUpdProducts")
		STBUpdProducts( aSL2[nX][nPosPRODUTO][2] )		
		aItem	:= STWFindItem( aSL2[nX][nPosPRODUTO][2] ) //Chama novamente para atualizar descricao
	EndIf
	
	cDescItem 	:= IIF(Empty(aItem[ITEM_DESCRICAO]),STR0001 + aSL2[nX][nPosPRODUTO][2],aItem[ITEM_DESCRICAO]) //para não parar o processo de venda, sinaliza qual código não foi localizado para permitir seguir o fluxo padrao de importacao		//"Código de Produto não encontrado na base do PDV:"
	lCheck	 	:= .F.
		
	Do Case
		Case aSL2[nX][nPosENTREGA][2] == "1"
			cEntrega := STR0002		//"Retira Posterior"
		Case aSL2[nX][nPosENTREGA][2] == "2"
			cEntrega := STR0003		//"Retira"
			lCheck	 := .T. 
		Case aSL2[nX][nPosENTREGA][2] == "3"
			cEntrega := STR0004		//"Entrega"
		Case aSL2[nX][nPosENTREGA][2] == "4"
			cEntrega := STR0005		//"Retira Posterior"
		OtherWise
			cEntrega := "ND"
	EndCase
	
	//PE para permitir alterar a obrigatoriedade de conferência do item (lCheck)
	If lStItemChk
		LjGrvLog("Conferencia de Item","Antes da Chamada do Ponto de Entrada:STITEMCHK",{lCheck, aSL2[nX]} )
		aStItemChk := ExecBlock( "STITEMCHK",.F.,.F.,{lCheck, @aSL2[nX]} )
		lCheck	:= aStItemChk[1]
		cEntrega := aStItemChk[2]
		LjGrvLog("Conferencia de Item","Apos a Chamada do Ponto de Entrada:STITEMCHK. Retorno:", lCheck )
	EndIf 
	AAdd(aRet, {cItem, cDescItem, aSL2[nX][nPosQUANT][2],0,cEntrega,lCheck, AllTrim(aSL2[nX][nPosPRODUTO][2]), .T. } )
Next nX

Return aRet


//------------------------------------------------------------------------------
/*{Protheus.doc} STBItPesq
Função para pesquisar o item na lista
@param   	cGetCodProd, oGetCodProd, oListConf, oMsgErro     
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/2018
@return     lRet
/*/
//------------------------------------------------------------------------------
Function STBItPesq( cGetCodProd, oGetCodProd, oListConf, oMsgErro, oBtnOk )

Local nX		:= 0
Local lRet		:= .T.
Local lPendIt	:= .F.
Local aItem		:= {} 
Local nPosQuant	:= 0
Local nQuant	:= 1
Local cCodItem	:= ""
Local aMVLJITOP := StrToKarr(SuperGetMv("MV_LJITOP", ,"*,-,%,?")  , ",") //Parametro com os codigos dos caracteres de atalho de operacoes do item no registro do item

nPosQuant 	:= AT(AllTrim(aMVLJITOP[1]),cGetCodProd)  //utilizar regra de quantidade para permitir conferir quantidade de Item > 1
If nPosQuant > 0
	nQuant := STIComma(SubStr(cGetCodProd,1,nPosQuant-1))
EndIf 

cCodItem	:= SubStr(cGetCodProd,nPosQuant+1)
aItem 		:= STWFindItem( cCodItem )
lRet		:= aItem[ITEM_ENCONTRADO]
	
If lRet
	lRet := .F.
	
	For nX:=1 to Len(oListConf:AARRAY)
		If oListConf:AARRAY[nX][6] .AND. oListConf:AARRAY[nX][8] .AND. ((oListConf:AARRAY[nX][3] - oListConf:AARRAY[nX][4] ) >= nQuant) .AND. oListConf:AARRAY[nX][7] == AllTrim(aItem[ITEM_CODIGO])				
			oListConf:AARRAY[nX][4] := oListConf:AARRAY[nX][4] + nQuant
			oListConf:Refresh()		
			lRet := .T.
			Exit
		EndIf 									
	Next nX
	
	If lRet
		cGetCodProd := Space(TamSX3("L1_PRODUTO")[1])  
	EndIf

	oMsgErro:lVisible := .F.
	oMsgErro:Refresh()
				
	For nX:=1 to Len(oListConf:AARRAY)
		If oListConf:AARRAY[nX][6] .AND. oListConf:AARRAY[nX][8] .AND. ((oListConf:AARRAY[nX][3] - oListConf:AARRAY[nX][4] ) > 0)
			lPendIt := .T.
			Exit	
		EndIf 
	Next nX

	If lPendIt
		oGetCodProd:SetFocus()
	Else 
		oBtnOk:SetFocus()	
	EndIf
EndIf

If !lRet
	oMsgErro:cCaption := STR0006	//"Produto/quantidade não encontrado!"
	oMsgErro:lVisible := .T.
	oMsgErro:Refresh()
	
	STFMessage(ProcName(),"ALERT",oMsgErro:cCaption ) 
	STFShowMessage(ProcName())
EndIf

Return lRet


//------------------------------------------------------------------------------
/*{Protheus.doc} STBItCkOk
Função para pesquisar o item na lista
@param   	oListConf, oMsgErro, aSL2     
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/2018
@return     lRet
/*/
//------------------------------------------------------------------------------
Function STBItCkOk( oListConf, oMsgErro, aSL2, lZeraPay )
Local lRet 		:= .T.
Local cItPend 	:= ""
Local nQtdDel	:= 0
Local nX
Local aSL2BKP	:= {}	//Backup da Tabela aSl2

Default aSL2		:= {}
Default lZeraPay	:= .F.

If  !Empty(aSL2)

	aSL2BKP := aClone(aSL2)

	For nX:=1 to Len(oListConf:AARRAY)
		If oListConf:AARRAY[nX][6] .AND. oListConf:AARRAY[nX][8] .AND.  ((oListConf:AARRAY[nX][3] - oListConf:AARRAY[nX][4] ) > 0)
			lRet 	:= .F.
			cItPend := oListConf:AARRAY[nX][1]
			Exit
		EndIf	
	Next nX

	If lRet
		//Atualiza aSL2 removendo itens excluídos
		For nX:=1 to Len(oListConf:AARRAY)
			If !oListConf:AARRAY[nX][8]
				ADel(aSL2,nX-nQtdDel)
				nQtdDel += 1
			EndIf		
		Next nX
		
		If nQtdDel > 0
			ASize(aSL2,len(aSL2)-nQtdDel)
		EndIf
	Else
		oMsgErro:cCaption := STR0007 + cItPend		//"Existe item pendente para conferência: "
		oMsgErro:lVisible := .T.
		oMsgErro:Refresh()

		STFMessage(ProcName(),oMsgErro:cCaption ) 
		STFShowMessage(ProcName())
	EndIf
	If nQtdDel > 0 
		STFMessage("STBItCkOk","YESNO",STR0012) //"Itens do orçamento alterados, por esse motivo a negociação de Formas de Pagamento e Descontos no total serão desfeitas, deseja continuar?" //"Itens do orçamento alterado, por esse motivo a negociação será desfeita,  deseja continuar?"
		If STFShowMessage("STBItCkOk")
			STISetZrPg(.T.)
			lZeraPay := .T.
		Else
			aSl2 := aSL2BKP
			lRet := .F.
		EndIf
	EndIf 
Else
	lRet := .F.
EndIf 

Return lRet

//------------------------------------------------------------------------------
/*{Protheus.doc} STBItCkDel
Função para pesquisar o item na lista
@param   	oListConf, oMsgErro     
@author     Paulo Henrique Santos de Moura
@version    P12
@since      10/01/2018
@return     lRet
/*/
//------------------------------------------------------------------------------
Function STBItCkDel( oListConf, oMsgErro )
Local nItem := oListConf:nAt
Local lRet	:= .T.

If !oListConf:AARRAY[nItem][6]
	oMsgErro:cCaption := STR0008 + oListConf:AARRAY[nItem][1] + STR0009		//"Item:"	//" não possui controle de conferência." 
	oMsgErro:lVisible := .T.
	oMsgErro:Refresh()

	STFMessage(ProcName(),"ALERT",oMsgErro:cCaption ) 
	STFShowMessage(ProcName())
	lRet := .F.
EndIf 

If lRet .AND. oListConf:AARRAY[nItem][8] .AND. ApMsgYesNo(STR0010 + oListConf:AARRAY[nItem][1] + " - " + AllTrim(oListConf:AARRAY[nItem][2]))	//"Confirmar cancelar o Item:"
	oListConf:AARRAY[nItem][8] := .F.
ElseIf lRet .AND. !oListConf:AARRAY[nItem][8] .AND. ApMsgYesNo(STR0011 + oListConf:AARRAY[nItem][1] + " - " + AllTrim(oListConf:AARRAY[nItem][2]))	//"Deseja remover o status de cancelado do Item:"
	oListConf:AARRAY[nItem][8] := .T.
EndIf

Return lRet
