#INCLUDE "Protheus.ch"
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "POSCSS.CH"     
#INCLUDE "STPOS.CH"
#INCLUDE "STDPAYMULTINEG.CH"

Static cPicDefault		:= "@E 9,999,999.99"	//Picture padrao para valores

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDGetMBT
Busca as formas de pagamentos da Regra de Multi Negociação

@param   	oMdl   			- Objeto de Get Regra
@param   	nSpace 			- Tamanho de espaco entre uma informacao e outra
@param   	oListPayForms	- ListBox da Forma de Pagamento
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	aRet
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

Function STDGetMBT(oMdl,nSpace,oListPayForms)
Local aArea 		:= GetArea()               	// Area atual
Local aRet  		:= {}                      	// Array de retorno
Local nTamP			:= TamSx3("MBT_PARCEL")[1] 	// Tamanho da parcela
Local nTamAEDesc	:= 30                      	// Tamanho apresentada na tela do campo AE_DESC

DbSelectArea("MBT")
DbSetOrder(1) //MBT_FILIAL+MBT_CODIGO+MBT_FORMPG+MBT_ADM  

If DbSeek(xFilial("MBT")+SubStr(oMdl:aItems[oMdl:nAt],1,TamSx3("MBS_CODIGO")[1]))
	While !MBT->(EOF()) .AND. xFilial("MBT")+SubStr(oMdl:aItems[oMdl:nAt],1,TamSx3("MBS_CODIGO")[1]) == MBT->MBT_FILIAL+MBT->MBT_CODIGO
        If !EMPTY(MBT->MBT_ADM)
        	
        	DbSelectArea("SAE")
			SAE->( dbSetOrder( 1 ) ) //AE_FILIAL+AE_COD
			If SAE->( DbSeek(xFilial("SAE")+MBT->MBT_ADM) )
				aAdd( aRet,	MBT->MBT_CODIGO			   					+SPACE(nSpace-LEN(MBT->MBT_CODIGO)) 		 		+ ;
							Upper(MBT->MBT_FORMPG)	  	 		   		+SPACE(nSpace-LEN(MBT->MBT_FORMPG)) 		  		+ ;
							STRZERO(MBT->MBT_MINPAR,nTamP)				+SPACE(nSpace-LEN(STRZERO(MBT->MBT_MINPAR,nTamP)))	+ ;
					   		STRZERO(MBT->MBT_PARCEL,nTamP)				+SPACE(nSpace-LEN(STRZERO(MBT->MBT_PARCEL,nTamP)))	+ ;
					   		Upper(SUBSTR(SAE->AE_DESC,1,nTamAEDesc)))				
			EndIf
			
		Else
		
			aAdd( aRet,	MBT->MBT_CODIGO			   			+SPACE(nSpace-LEN(MBT->MBT_CODIGO))   					+ ;
						Upper(MBT->MBT_FORMPG)			  	+SPACE(nSpace-LEN(MBT->MBT_FORMPG)) 					+ ;
						STRZERO(MBT->MBT_MINPAR,nTamP)		+SPACE(nSpace-LEN(STRZERO(MBT->MBT_MINPAR,nTamP)))		+ ;
						STRZERO(MBT->MBT_PARCEL,nTamP)		+SPACE(nSpace-LEN(STRZERO(MBT->MBT_PARCEL,nTamP)))		+ ;
						"")	
								
		EndIf
		
		MBT->(DbSkip())
	EndDo
EndIf

If EMPTY(aRet)
	STFMessage(ProcName(),"STOP",STR0001) //"Nao ha formas de pagamento cadastrado para esta negociação."
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
Else
	STFMessage(ProcName(),"STOP",STR0002) //"Escolha a Forma de Pagamento."
	STFShowMessage(ProcName())	
	STFCleanMessage(ProcName())
EndIf

aPayForms := aRet

/* Atualiza a lista de resumo de pagamento */
oListPayForms:Reset()
oListPayForms:SetArray(aPayForms)

RestArea(aArea)

Return aRet

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/{Protheus.doc} STDLblPayForms
Alimenta os labels relacionados a Formas de Pagamentos

@param   	oListPayForms	- ListBox da Forma de Pagamento
@param   	aLblPayForms	- Representa os Labels da Forma de Pagamento
@param   	aTypeDown		- Conteudo dos tipos de Entrada
@param   	nSpace			- Tamanho de espaco entre uma informacao e outra
@param   	nSaleVal		- Valor da Venda
@author  	Varejo
@version 	P12
@since   	23/09/2013
@return  	NIL
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDLblPayForms(oListPayForms,aLblPayForms,aTypeDown,nSpace,nSaleVal)
Local aArea 		:= GetArea()   																				// Area Atual
Local nTamAEDesc	:= 30       																			   	// Tamanho apresentada na tela do campo AE_DESC
Local cMBTCodigo	:= ""
Local cMBTFormPg	:= ""
Local cMBTParcDe	:= ""
Local cMBTParcAt	:= ""
Local cDescAdmFin	:= ""
Local cBckAdmFin	:= ""																						//Backup da Administradora Financeira 
Local nFor			:= 0																						//Variavel de Laço

// Limpas as variáveis do Label
aLblPayForms := {"","","","","","",{}}
		
DbSelectArea("MBT")
MBT->( DbSetOrder(1) )//MBT_FILIAL+MBT_CODIGO+MBT_FORMPG+MBT_ADM  

aTypeDown := {}


If Len(oListPayForms:aItems) > 0 .AND. oListPayForms:nAt > 0
	cMBTCodigo	:= SubStr(oListPayForms:aItems[oListPayForms:nAt],(00000000)+1	,TamSx3("MBT_CODIGO")[1]) 	//Codigo da Regra
	cMBTFormPg	:= SubStr(oListPayForms:aItems[oListPayForms:nAt],(1*nSpace)+1	,TamSx3("MBT_FORMPG")[1]) 	//Forma de Pagamento da Regra
	cMBTParcDe	:= SubStr(oListPayForms:aItems[oListPayForms:nAt],(2*nSpace)+1	,TamSx3("MBT_MINPAR")[1]) 	//Minimo de Parc. da Regra
	cMBTParcAt	:= SubStr(oListPayForms:aItems[oListPayForms:nAt],(3*nSpace)+1	,TamSx3("MBT_PARCEL")[1]) 	//Maximo de Parc. da Regra
	cDescAdmFin	:= SubStr(oListPayForms:aItems[oListPayForms:nAt],(4*nSpace)+1	,nTamAEDesc)	
Endif 

If DbSeek(xFilial("MBT")+cMBTCodigo+cMBTFormPg)
	
	DbSelectArea("SAE")
	SAE->( dbSetOrder( 1 ) ) //AE_FILIAL+AE_COD
	
	While !MBT->(EOF()) .AND. xFilial("MBT")+cMBTCodigo+cMBTFormPg == MBT->MBT_FILIAL+MBT->MBT_CODIGO+MBT->MBT_FORMPG
		
		If Val(cMBTParcDe) == MBT->MBT_MINPAR .AND. Val(cMBTParcAt) == MBT->MBT_PARCEL
		
	        cBckAdmFin := ""
	        If !EMPTY(MBT->MBT_ADM)
				If SAE->( DbSeek(xFilial("SAE")+MBT->MBT_ADM) ) .AND. Upper(Substr(SAE->AE_DESC,1,nTamAEDesc)) == cDescAdmFin
					cBckAdmFin	:= Upper(Substr(SAE->AE_DESC,1,15))
				EndIf
			EndIf
			
			// Se achou a adm. Financeira equivalente ao conteudo do objeto oListPayForms clicado
			// preencho o restante
			If (!EMPTY(MBT->MBT_ADM) .AND. !EMPTY(cBckAdmFin)) .OR. (EMPTY(MBT->MBT_ADM))
				aLblPayForms[01]	:= Upper(MBT->MBT_FORMPG)
				aLblPayForms[03]	:= STRZERO(MBT->MBT_MINPAR,2) + " A " + STRZERO(MBT->MBT_PARCEL,2)
				aLblPayForms[04] 	:= Alltrim(Transform(MBT->MBT_TXJURO, "@E 99.99"))
				
				If MBT->MBT_VALENT <> 0
					aLblPayForms[05] := Alltrim(Transform(MBT->MBT_VALENT, cPicDefault))
				ElseIf MBT->MBT_PERENT <> 0
					aLblPayForms[05] := Alltrim(Transform(nSaleVal*(MBT->MBT_PERENT/100), cPicDefault))
				Else
					aLblPayForms[05] := Alltrim(Transform(0, cPicDefault))
				EndIF
				
				If !EMPTY(MBT->MBT_FPENT) .AND. aLblPayForms[05] <> Alltrim(Transform(0, cPicDefault))
					aTypeDown := StrToKarr(MBT->MBT_FPENT, ";")
					DbSelectArea("SX5")
					DbSetOrder(1)
					For nFor := 1 To Len(aTypeDown)
						If DbSeek(xFilial("SX5")+ "24"+ aTypeDown[nFor])
							aTypeDown[nFor] += " - " + SX5->X5_DESCRI
						Endif
					Next nFor
				EndIF
				
				aLblPayForms[02]	:= cBckAdmFin
				aLblPayForms[06]	:= MBT->MBT_ADM
				aLblPayForms[07]	:= {MBT->MBT_JUR1PA, MBT->MBT_CAR1PA, MBT->MBT_LIM1PA}
			EndIf
			
		EndIf
		
		MBT->(DbSkip())
		
	EndDo
EndIf

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} STDVldMn
Verifica se os itens de vendas estão na Multi Negociação.

@param   	aItens - Array contendo os itens de venda			
@author  	Vendas & CRM
@version 	P12117
@since   	26/12/2018
@return  	
@obs     
@sample
/*/
//-------------------------------------------------------------------

Function STDVldMn(aItens)
Local nX 		:= 0 //Variavel de loop
Local aAreaMEK	:= {} //Guarda area da MEK
Local aAreaMBS	:= {} //Guarda area da MBS
Local cGrupoPrd	:= "" //Armazena o conteudo do B1_GRUPO
Local lVldProd	:= .T. //Validacao das tabelas MEK e MBS

Default aItens := {}

If Len(aItens) > 0
	aAreaMEK := MEK->(Getarea())
	DbSelectArea("MEK")
	DbSetorder(3) //MEK_FILIAL+MEK_PRODUT
	
	aAreaMBS := MBS->(Getarea())
	DbSelectArea("MBS")
	DbSetorder(3) //MBS_FILIAL+MBS_GRPROD
	
	SB1->(DbSetorder(1)) //B1_FILIAL+B1_COD
	
	For nX := 1 to Len(aItens)
		If !MEK->(DbSeek(xFilial("MEK") + aItens[nX][2])) 
			//Caso o item não esteja como produto procuro como grupo.
			
			If SB1->(DbSeek(xFilial("SB1") + aItens[nX][2]))
				cGrupoPrd := SB1->B1_GRUPO					
			EndIf
			
			lVldProd	:= .F.				
			MBS->(DbgoTop()) 
			While MBS->(!EOF()) 
				If !Empty(cGrupoPrd) .And. xFilial("MBS") + cGrupoPrd == MBS->MBS_FILIAL + MBS->MBS_GRPROD  //Verifico o Groupo do produto
					lVldProd	:= .T.	
					Exit				
				EndIf
				If xFilial("MBS") + AllTrim(aItens[nX][2]) == MBS->MBS_FILIAL + AllTrim(MBS->MBS_PRODUT) //Verifico o produto 
					lVldProd	:= .T.
					Exit					
				EndIf
				MBS->(DbSkip())		
			End	
			If !lVldProd // Se não achou na MBS busco na MEK por grupo de produto 
				If !Empty(cGrupoPrd)
					MEK->(DbgoTop()) 
					While MEK->(!Eof()) 
						If xFilial("MEK") + cGrupoPrd == MEK->MEK_FILIAL + MEK->MEK_GRPROD  //Verifico o Groupo do produto
							lVldProd	:= .T.	
							Exit						
						EndIf
						MEK->(DbSkip())		
					End
				EndIf	
				If !lVldProd // Se nao estiver na MEK e na MBS deve zerar os itens
					Exit
				EndIf
			EndIf					
		EndIf 
	Next nX
	RestArea(aAreaMEK)
	RestArea(aAreaMBS)	

	If !lVldProd  // Se tiver itens nao cadastrados Limpo os Itens	
		aItens := {}
	EndIf
EndIf	

Return
