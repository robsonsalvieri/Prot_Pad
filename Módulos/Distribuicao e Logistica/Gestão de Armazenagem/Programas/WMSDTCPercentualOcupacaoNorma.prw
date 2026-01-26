#Include "Totvs.ch"  
#Include "WMSDTCPercentualOcupacaoNorma.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0034
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0034()
Return Nil
//-----------------------------------------------
/*/{Protheus.doc} WMSDTCPercentualOcupacaoNorma
Classe para analise do percentual de ocupação da norma
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-----------------------------------------------
CLASS WMSDTCPercentualOcupacaoNorma FROM LongNameClass
	// Data
	DATA cArmazem
	DATA cEndereco
	DATA cEstFis
	DATA cCodNorma
	DATA cProduto
	DATA nPorcento
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cArmazAnt
	DATA cEnderAnt
	DATA cEstFisAnt
	DATA cCodNorAnt
	DATA cProdutAnt	
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	// Setters
	METHOD SetArmazem(cArmazem)
	METHOD SetEnder(cEndereco)
	METHOD SetEstFis(cEstFis)
	METHOD SetCodNor(cCodNorma)
	METHOD SetProduto(cProduto)
	METHOD SetPorcento(nPorcento)
	// Getters
	METHOD GetArmazem()
	METHOD GetEndereco()
	METHOD GetEstFis()
	METHOD GetNorma()
	METHOD GetProduto()
	METHOD GetPorcento()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS WMSDTCPercentualOcupacaoNorma
	Self:cArmazem   := PadR("",TamSx3("DCP_LOCAL")[1])
	Self:cEndereco  := PadR("",TamSx3("DCP_ENDERE")[1])
	Self:cEstFis    := PadR("",TamSx3("DCP_ESTFIS")[1])
	Self:cCodNorma  := PadR("",TamSx3("DCP_NORMA")[1])
	Self:cProduto   := PadR("",TamSx3("DCP_CODPRO")[1])
	Self:cErro      := ""
	Self:nPorcento  := 0
	Self:nRecno     := 0
	Self:cArmazAnt  := PadR("",Len(Self:cArmazem))
	Self:cEnderAnt  := PadR("",Len(Self:cEndereco))
	Self:cEstFisAnt := PadR("",Len(Self:cEstFis))
	Self:cCodNorAnt := PadR("",Len(Self:cCodNorma))
	Self:cProdutAnt := PadR("",Len(Self:cProduto))
Return

METHOD Destroy() CLASS WMSDTCPercentualOcupacaoNorma
	//Mantido para compatibilidade
Return

METHOD LoadData(nIndex) CLASS WMSDTCPercentualOcupacaoNorma
Local lRet       := .T.
Local lCarrega   := .T. 
Local aAreaAnt   := GetArea()
Local aDCP_PORCEN:= TamSx3("DCP_PORCEN")
Local aAreaDCP   := DCP->(GetArea())
Local cAliasDCP  := Nil
Default nIndex = 1
	Do Case 
		Case nIndex == 1 // DCP_FILIAL+DCP_LOCAL+DCP_ENDERE+DCP_ESTFIS+DCP_NORMA+DCP_CODPRO
			If (Empty(Self:cArmazem) .OR. Empty(Self:cEndereco) .OR. Empty(Self:cEstFis) .OR. Empty(Self:cCodNorma) .OR. Empty(Self:cProduto)) 
				lRet := .F.
			Else
				If Self:cArmazem == Self:cArmazAnt .And.;
					Self:cEndereco == Self:cEnderAnt .And.;
					Self:cEstFis == Self:cEstFisAnt .And.;
					Self:cCodNorma == Self:cCodNorAnt .And.;
					Self:cProduto == Self:cProdutAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.
	EndCase	
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasDCP  := GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasDCP
						SELECT DCP.DCP_LOCAL,
								DCP.DCP_ENDERE,
								DCP.DCP_ESTFIS,
								DCP.DCP_NORMA,
								DCP.DCP_CODPRO,
								DCP.DCP_PORCEN,
								DCP.R_E_C_N_O_ RECNODCP
						FROM %Table:DCP% DCP
						WHERE DCP.DCP_FILIAL = %xFilial:DCP%
						AND DCP.DCP_LOCAL =  %Exp:Self:cArmazem%
						AND DCP.DCP_ENDERE = %Exp:Self:cEndereco%
						AND DCP.DCP_ESTFIS = %Exp:Self:cEstFis  %
						AND DCP.DCP_NORMA = %Exp:Self:cCodNorma%
						AND DCP.DCP_CODPRO = %Exp:Self:cProduto%
						AND DCP.%NotDel%
					EndSql
			EndCase
			TCSetField(cAliasDCP,'DCP_PORCEN','N',aDCP_PORCEN[1],aDCP_PORCEN[2])
			lRet := (cAliasDCP)->(!Eof())
			If lRet 
				Self:cArmazem  := (cAliasDCP)->DCP_LOCAL
				Self:cEndereco := (cAliasDCP)->DCP_ENDERE
				Self:cEstFis   := (cAliasDCP)->DCP_ESTFIS
				Self:cCodNorma := (cAliasDCP)->DCP_NORMA
				Self:cProduto  := (cAliasDCP)->DCP_CODPRO
				Self:nPorcento := (cAliasDCP)->DCP_PORCEN
				Self:nRecno    := (cAliasDCP)->RECNODCP
				// Controle dados anteriores
				Self:cArmazAnt  := Self:cArmazem
				Self:cEnderAnt  := Self:cEndereco
				Self:cEstFisAnt := Self:cEstFis
				Self:cCodNorAnt := Self:cCodNorma
				Self:cProdutAnt := Self:cProduto
			EndIf
			(cAliasDCP)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDCP)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetArmazem(cArmazem) CLASS WMSDTCPercentualOcupacaoNorma
	Self:cArmazem := PadR(cArmazem, Len(Self:cArmazem))
Return 

METHOD SetEnder(cEndereco) CLASS WMSDTCPercentualOcupacaoNorma
	Self:cEndereco := PadR(cEndereco, Len(Self:cEndereco))
Return 

METHOD SetEstFis(cEstFis) CLASS WMSDTCPercentualOcupacaoNorma
	Self:cEstFis := PadR(cEstFis, Len(Self:cEstFis))
Return 

METHOD SetCodNor(cCodNorma) CLASS WMSDTCPercentualOcupacaoNorma
	Self:cCodNorma := PadR(cCodNorma, Len(Self:cCodNorma))
Return 

METHOD SetProduto(cProduto) CLASS WMSDTCPercentualOcupacaoNorma
	Self:cProduto := PadR(cProduto, Len(Self:cProduto))
Return 

METHOD SetPorcento(nPorcento) CLASS WMSDTCPercentualOcupacaoNorma
	Self:nPorcento := nPorcento
Return 
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetArmazem() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:cArmazem 

METHOD GetEndereco() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:cEndereco

METHOD GetEstFis() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:cEstFis

METHOD GetNorma() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:cCodNorma

METHOD GetProduto() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:cProduto

METHOD GetPorcento() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:nPorcento

METHOD GetErro() CLASS WMSDTCPercentualOcupacaoNorma
Return Self:cErro
