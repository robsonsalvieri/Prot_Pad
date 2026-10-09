#Include 'Protheus.ch'

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*{Protheus.doc} STDAdmFinan
Retorna as administradoras

@param   	
@author  	Vendas & CRM
@version 	P12
@since   	28/01/2013
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDAdmFinan(cType,cTpStruct)

Local aArea 	 := GetArea()
Local aRet  	 := {}
Local lAE_MSBLQL := SAE->(ColumnPos("AE_MSBLQL")) > 0

Default cTpStruct := "1" //Tipo da estrutura do array de retorno  

DbSelectArea("SAE")
SAE->(DbSetOrder(1))
SAE->(DbSeek(xFilial("SAE")))
While !EOF() .AND. xFilial("SAE") == SAE->AE_FILIAL
	If (AllTrim(SAE->AE_TIPO) $ cType) .And. (lAE_MSBLQL == .F. .Or. AllTrim(SAE->AE_MSBLQL) != '1')
		If cTpStruct == "1"
			Aadd(aRet,SAE->AE_COD + "- " + SAE->AE_DESC)
		ElseIf cTpStruct == "2"
			AAdd(aRet, {SAE->AE_COD, AllTrim(SAE->AE_TIPO), AllTrim(Upper(SAE->AE_DESC)) } )
		EndIf
	EndIf 	
	SAE->(DbSkip())
EndDo

RestArea(aArea)

Return aRet


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*{Protheus.doc} STDTaxDiscInsArr()
Taxa Administrativa para descontar da doação para o Instituto Arredondar

@param   	
@author  	Varejo
@version 	P12
@since   	10/11/2014
@return  	
@obs     
@sample
/*/
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
Function STDTaxDiscInsArr(cForma,cAdmFin)

Local aArea			:= GetArea()					// Guardar area anterior
Local lArredondar 	:= SuperGetMV( "MV_LJINSAR",,.F. )	// Parâmetro para habilitar doação ao Inst. Arredondar
Local lAplicaTaxa	:= SuperGetMv('MV_LJTEFIA',,2)==1  // Aplica desconto da taxa administrativa na doação
Local nValDoacao	:= STBGetInsArr()				// Valor da doação ao Ins. Arredondar
Local cFilSAE		:= xFilial("SAE")				// Filial da tabela SAE
Local nTamAE_COD  	:= TamSx3("AE_COD")[1]			// Tamanho do campo AE_COD
Local nPctTaxAdm	:= 0							// % da Taxa da Administradora Financeira

Default cForma		:= ""
Default cAdmFin		:= ""
Default nValDoacao	:= 0

If lArredondar .AND. lAplicaTaxa .AND. nValDoacao > 0

	DbSelectArea("SAE")
	DbSetOrder(1)
	If SAE->(MsSeek(cFilSAE+Left(cAdmFin,nTamAE_COD))) .AND. AllTrim(cForma) $ "CC/CD"
		nPctTaxAdm := SAE->AE_TAXA
		STBSetDInsArr(nValDoacao-(nValDoacao*(nPctTaxAdm/100)))  // Aplicar desconto  
	Else
		STBSetDInsArr(nValDoacao)
	EndIf

EndIf
	
RestArea(aArea)

Return nil

/*
{Protheus.doc} STDGetDias
Retorna os dias para pagamento da administradora selecionada

@param   	
@author  	Lucas Novais (lnovais)
@version 	P12
@since   	04/09/2018
@return		Dias para pagamento da administradora AE_DIAS  	
@obs     
@sample
*/
Function STDGetDias(cChave)

Local aArea 	:= GetArea()		//Guardo Area atual
Local aAreaSAE  := SAE->(GetArea())	//Guardo a Area da SAE
Local nRet  	:= 0				//Retorno da função

Default cChave 	:= ""				//Chave de busca

DbSelectArea("SAE")
SAE->(DbSetOrder(1))//AE_FILIAL+AE_COD

If SAE->(DbSeek(xFilial("SAE") + cChave))
	nRet := SAE->AE_DIAS
EndIf 

RestArea(aAreaSAE)
RestArea(aArea)

Return nRet




