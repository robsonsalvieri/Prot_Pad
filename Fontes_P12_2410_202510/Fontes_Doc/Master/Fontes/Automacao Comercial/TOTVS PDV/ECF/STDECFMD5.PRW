#INCLUDE "PROTHEUS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STPOS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STDECFMD5
Function   Gera MD5 do TotvsPDV - SL1,SL2 E SL4

@param   	cAlias - Alias
@param   	nItemLine	- numerodo item
@param   	nItemAnt - Item anterior
@author  Varejo
@version 	P11.8
@since   	13/06/2012
@return  	cPafMd5 - Texto MD5
@obs    ATENÇÃO AO USAR ESTA FUNÇÃO POIS ESTA GERA O MD5
 		DAS TABELAS SL1,SL2,SL4 SOMENTE DO TOTVSPDV
 		SE NECESSÁRIO UTILIZE DIRETAMENTE A FUNÇÃO STxPafMd5
 		QUE GERA PARA TODOS OS MODULOS
/*/
//-------------------------------------------------------------------
Function  STDECFMD5(cAlias, nItemLine, nItemAnt, cTipo)
Local cPafMd5		:= ""		//Conteudo MD5 para retorno da function    
Local oModel		:= NIL		//Model
Local oModelDet		:= NIL		//Detalhes do Model      
Local aArea			:= GetArea()
Local lIsValid		:= .F.

Default cAlias 		:= ""
Default nItemLine 	:= 0
Default nItemAnt 	:= 0
Default cTipo		:= "1"

If SubStr( cAlias, 1, 3 ) == "SL1"          

	oModel := STDGPBModel()//retorna o model Da Cesta
	
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_NUMORC"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_EMISSAO"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_DTLIM"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_VLRTOT"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_NUMCFIS"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_CONTDOC"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_COODAV"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_CLIENTE"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_CGCCLI"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_TPORC"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_PDV"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_SERPDV"))
	cPafMd5 := AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_DOC"))	
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_STORC"))	
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_DESCONT"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_VLRLIQ"))
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_VALMERC"))
	
	cPafMd5 += AllTrim(oModel:GetValue(STDGModelID("SL1"),"L1_HORA"))
    cPafMd5 += AllTrim(SM0->M0_CGC)
        
ElseIf 	SubStr( cAlias, 1, 3 ) == "SL2"

    If nItemAnt > 0 .AND. nItemLine > 0
    	oModel := STDGPBModel()//retorna o model Da Cesta  
    	oModelDet :=  oModel:GetModel( STDGModelID("SL2"))
    	oModelDet:GoLine(nItemLine)
		cPafMd5 := oModelDet:GetValue("L2_SERPDV")
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_DOC"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_CONTDOC"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_PRODUTO"))    
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_QUANT"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_VRUNIT"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_VLRITEM"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_SITTRIB"))
    	cPafMd5 += AllTrim(oModelDet:GetValue("L2_VENDIDO"))
    	cPafMd5 += AllTrim(oModelDet:GetValue("L2_ITEM"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_DESCRI"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_UM"))    
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_PRCTAB"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_VALDESC"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_DESC"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L2_TES"))
		
		If SL2->(ColumnPos("L2_IAT")) > 0
	    	cPafMd5 += AllTrim(oModelDet:GetValue("L2_DECVLU"))
	    	cPafMd5 += AllTrim(oModelDet:GetValue("L2_DECQTD"))
	    	cPafMd5 += AllTrim(oModelDet:GetValue("L2_IAT"))
	    	cPafMd5 += AllTrim(oModelDet:GetValue("L2_IPPT"))
	    EndIf

		If nItemAnt <> nItemLine	  
			oModelDet:GoLine(nItemAnt)
		EndIf
    EndIf
    
ElseIf 	SubStr( cAlias, 1, 3 ) == "SL4"

    If nItemAnt > 0 .AND. nItemLine > 0
    	oModel := STDGPBModel()//retorna o model Da Cesta  
    	oModelDet :=  oModel:GetModel( STDGModelID("SL4"))
    	oModelDet:GoLine(nItemLine)
		cPafMd5 := AllTrim(oModelDet:GetValue("L4_SERPDV"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L4_DOC"))		//COO
		cPafMd5 += AllTrim(oModelDet:GetValue("L4_CONTDOC"))	//CCF
		cPafMd5 += AllTrim(oModelDet:GetValue("L4_CONTONF"))	//GNF
		cPafMd5 += AllTrim(oModelDet:GetValue("L4_DATA"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L4_FORMA"))
		cPafMd5 += AllTrim(oModelDet:GetValue("L4_VALOR"))

		If nItemAnt <> nItemLine	  
			oModelDet:GoLine(nItemAnt)
		EndIf
    EndIf
    
Else
	cPafMd5	:= STxPafMd5(cAlias , "" , cTipo)
	lIsValid:= .T. //MD5 já retornou corretamente
EndIf 

If !lIsValid .And. !Empty(AllTrim(cPafMd5))
	cPafMd5 := MD5(cPafMd5,2)
EndIf	

RestArea(aArea)          
	
Return cPafMd5    

//-------------------------------------------------------------------
/*/{Protheus.doc} STxEDtoC
Converte o Campo Data
@param   	xValor - Valor
@author  Varejo
@version 	P11.8
@since   	03/07/2013
@return  	cValor - Valor
/*/
//-------------------------------------------------------------------
Function STxEDtoC( xValor )
Local cValor := ""

 If ValType(xValor) == "D"
 	cValor :=	Dtos(xValor)
ElseIf ValType(xValor) == "C"
 	If Empty(AllTrim(xValor))
 		cValor := ""
 	Else
 		cValor := Dtos(StoD(xValor))
 	EndIf
EndIf

Return cValor

//-------------------------------------------------------------------
/*/{Protheus.doc} STxPafMd5
Gera MD5 para os campos do PAF
@param cAlias , String , Alias Corrente
@param cDadoAdic , String, Dados Adicionais 
@param cTipo, String, Tipo de SFI
@author  Varejo
@version 	P12
@since   	03/08/2017
@return  	cPafMD5 , String , MD5 do registro
/*/
//-------------------------------------------------------------------
Function STxPafMd5(cAlias , cDadoAdic , cTipo)
Local cPafMd5	:= ""	//Conteudo MD5 para retorno da function
Local cAux		:= ""
Local cValor	:= ""
Local nValor	:= 0 
Local aArea		:= {}

Default cAlias 	:= ""
Default cDadoAdic:= ""
Default cTipo 	:= "1"

//Os campos de data devem ser tratados pois ao verificar o MD-5 na gravação
//e via webservice retornava um MD-5 diferente pois os campos tinham diferentes tipos.
//Variavel para que seja passado algum dado que seja necessário no MD5 e que venha de outra tabela
If !Empty(AllTrim(cAlias)) .AND. !Empty(AllTrim(cDadoAdic))
	cPafMd5 := AllTrim(cDadoAdic)
EndIf

If SubStr( cAlias, 1, 3 ) == "SL1"
	 
	 //DAV 02
	cPafMd5 += AllTrim((cAlias)->L1_NUMORC) 			//numero da DAV		
    cPafMd5 += AllTrim(STxEDtoC((cAlias)->L1_EMISSAO))	//data DAV        
    cPafMd5 += AllTrim(STxEDtoC((cAlias)->L1_DTLIM))
    cPafMd5 += AllTrim(cValToChar((cAlias)->L1_VLRTOT))	//valor da DAV 
	cPafMd5 += AllTrim((cAlias)->L1_NUMCFIS) 			// COO Cupom Fiscal		 
	cPafMd5 += AllTrim((cAlias)->L1_CONTDOC) 			//numero sequencial do ECF
	cPafMd5 += AllTrim((cAlias)->L1_COODAV)  			//COO RG
	cPafMd5 += AllTrim((cAlias)->L1_CLIENTE) 			//nome e cnpj do adquirente
	cPafMd5 += AllTrim((cAlias)->L1_CGCCLI)
	cPafMd5 += AllTrim((cAlias)->L1_TPORC)
	cPafMd5 += AllTrim((cAlias)->L1_PDV)
	 
	//R04
	cPafMd5 += AllTrim((cAlias)->L1_SERPDV)				//numero de série
	cPafMd5 += AllTrim((cAlias)->L1_DOC)				//COO
    cPafMd5 += AllTrim((cAlias)->L1_STORC)        		//Ind. de cancelamento
    cPafMd5 += AllTrim(cValToChar((cAlias)->L1_DESCONT))
    cPafMd5 += AllTrim(cValToChar((cAlias)->L1_VLRLIQ))
    cPafMd5 += AllTrim(cValToChar((cAlias)->L1_VALMERC))
    
    //usado para validar a tabela de estoque, junto com a Serie e a Data de emissao
    cPafMd5 += AllTrim((cAlias)->L1_HORA)
    
    //Validação do Estoque
    cPafMd5 += AllTrim(StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),"."))
    
ElseIf SubStr( cAlias, 1, 3 ) == "SL2"
	
	//No MD5 do SL2 deve-se mandar o L1_NUMORC devido aos teste de validação do Bloco VII - Homologacao PAF
	
	//DAV 03
	//L1_NUMORC - numero da DAV
	cPafMd5 += AllTrim(STxEDtoC((cAlias)->L2_EMISSAO))	//Data de inclusao
	cPafMd5 += AllTrim((cAlias)->L2_ITEM)					//Numero do Item
	cPafMd5 += AllTrim((cAlias)->L2_PRODUTO)				//Codigo do produto
	cPafMd5 += AllTrim((cAlias)->L2_DESCRI)				//Descricao
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_QUANT))	//Quantidade
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_UM))		//Unidade
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_VRUNIT))	//valor unitario
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_PRCTAB)) //Preço Unitario
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_VALDESC)) 
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_DESC)) //desconto do item
	cPafMd5 += AllTrim((cAlias)->L2_TES)

	//acrescimo do item
	cPafMd5 += AllTrim(cValToChar((cAlias)->L2_VLRITEM))	//valor total liquido 
	cPafMd5 += AllTrim((cAlias)->L2_SITTRIB)				//totalizador parcial
	cPafMd5 += AllTrim((cAlias)->L2_VENDIDO)				//ind de cancelamento
	
	//R05
	cPafMd5 += AllTrim((cAlias)->L2_SERPDV)				//numero de serie
	cPafMd5 += AllTrim((cAlias)->L2_DOC)					//COO
	cPafMd5 += AllTrim((cAlias)->L2_CONTDOC)				//CCF
	//Totalizador Parcial é validado na funcao que cria o arquivo
	
	If SL2->(ColumnPos("L2_IAT")) > 0
		cPafMd5 += AllTrim((cAlias)->L2_IAT) //IAT
		cPafMd5 += AllTrim(cValToChar((cAlias)->L2_DECVLU)) //decimais valor unitario
		cPafMd5 += AllTrim(cValToChar((cAlias)->L2_DECQTD)) //decimais quantidade
		cPafMd5 += AllTrim((cAlias)->L2_IPPT) //IPPT		
	EndIf

ElseIf 	SubStr( cAlias, 1, 3 ) == "SL4"
	
	//R07
	cPafMd5 += AllTrim((cAlias)->L4_SERPDV)	//numero de serie
	cPafMd5 += AllTrim((cAlias)->L4_DOC)    	//COO
	cPafMd5 += AllTrim((cAlias)->L4_CONTDOC)  //CCF
	cPafMd5 += AllTrim((cAlias)->L4_CONTONF)  //GNF
    cPafMd5 += AllTrim(STxEDtoC((cAlias)->L4_DATA))	//Data de inclusao		
	cPafMD5 += AllTrim((cAlias)->L4_FORMA) //Forma de pagamento
	cPafMd5 += AllTrim(cValToChar((cAlias)->L4_VALOR)) //Valor 

ElseIf 	SubStr( cAlias, 1, 3 ) == "SFI"

	cPafMd5 += AllTrim((cAlias)->FI_SERPDV)	//numero de serie
	cPafMd5 += AllTrim((cAlias)->FI_NUMREDZ)	//CRZ
	cPafMd5 += AllTrim((cAlias)->FI_PDV)	//CRZ
	cPafMd5 += AllTrim((cAlias)->FI_COO)		//COO
	cPafMd5 += AllTrim((cAlias)->FI_CRO)		//CRO
    cPafMd5 += AllTrim(STxEDtoC((cAlias)->FI_DTMOVTO))	//data do movimento
    cPafMd5 += AllTrim(STxEDtoC((cAlias)->FI_DTREDZ))	//data emissão
	cPafMd5 += AllTrim(cValToChar((cAlias)->FI_HRREDZ))	//hora emissão
	cPafMd5 += AllTrim(cValToChar((cAlias)->(FI_VALCON+FI_DESC+FI_CANCEL+FI_ISS)))	//venda bruta
	
	//Usado para validar exclusão/inclusão do Registro R03 da SFI - TESTE BLOCO VII
	cPafMd5 += AllTrim(cValToChar((cAlias)->FI_DESC))
	cPafMd5 += AllTrim(cValToChar((cAlias)->FI_SUBTRIB))
	cPafMd5 += AllTrim(cValToChar((cAlias)->FI_ISENTO))
	cPafMd5 += AllTrim(cValToChar((cAlias)->FI_NTRIB))
	
	If SFI->(ColumnPos("FI_ISSISEN")) > 0
		cPafMd5 += AllTrim(cValToChar((cAlias)->FI_ISSISEN))
	EndIf
	If SFI->(ColumnPos("FI_ISSNTRI")) > 0
		cPafMd5 += AllTrim(cValToChar((cAlias)->FI_ISSNTRI))
	EndIf
	If SFI->(ColumnPos("FI_ISSFTRI")) > 0
		cPafMd5 += AllTrim(cValToChar((cAlias)->FI_ISSFTRI))
	EndIf

	If cTipo == "2" // Para o campo FI_MD5TRIB

		DbSelectArea("SX3")
		aArea := SX3->(GetArea())
		SX3->(DbSetOrder(2))
		
		//Aliquotas de ICMS
		SX3->(DbSeek("FI_BAS" , .T.))
		Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BAS"
			cAux	:=	SX3->X3_CAMPO
			cPafMd5	+=	AllTrim(cValToChar((cAlias)->&(cAux)))				
			SX3->(dbSkip())
		Enddo
		
		//Alíquotas de ISS			
		SX3->(DbSeek("FI_BIS" , .T.))
		Do While !SX3->(Eof()) .AND. SubStr(SX3->X3_CAMPO,1,6) == "FI_BIS"
			cAux	:=	SX3->X3_CAMPO
			cPafMd5	+=	AllTrim(cValToChar((cAlias)->&(cAux)))
			SX3->(dbSkip())
		Enddo
		
		RestArea(aArea)
	EndIf
	
	cPafMd5 += AllTrim((cAlias)->FI_XMLENV) //XML PAF enviado?

ElseIf 	SubStr( cAlias, 1, 3 ) == "SB1"
		
	//Validação para tabela de produtos - Item 06 do Menu Fiscal
	cPafMd5 += AllTrim(SM0->M0_CGC)
	cPafMd5 += AllTrim( cValToChar(LjGetB0Prv((cAlias)->B1_COD)) ) //Valor Unitario
	cPafMd5 += AllTrim((cAlias)->B1_COD)	//Cod produto
	cPafMd5 += AllTrim((cAlias)->B1_DESC)	//descricao
	cPafMd5 += AllTrim((cAlias)->B1_UM)
	cPafMd5 += AllTrim((cAlias)->B1_IAT)
	cPafMd5 += AllTrim((cAlias)->B1_IPPT)
	cPafMd5 += AllTrim((cAlias)->B1_PRV1)
	cPafMd5 += AllTrim((cAlias)->B1_TS)
	
	//Para validar a Sit Trib nos testes do bloco VII alterar a TES do produto ( de Icms para Iss, ou para NTrib)
	aArea := (cAlias)->(GetArea())
	cPafMd5 += AllTrim(STBFMSitTrib((cAlias)->B1_COD,"P","SB1",.T.)) //Situacao Tributaria
	RestArea(aArea)
	
	cPafMd5 += AllTrim( cValToChar( (cAlias)->B1_ALIQISS ) )	//aliquota
	cPafMd5 += AllTrim( cValToChar( (cAlias)->B1_PICM ))			//aliquota
	
	If SB1->(ColumnPos("B1_QATUPAF")) > 0
		nValor	:= (cAlias)->B1_QATUPAF
	Else
		nValor	:= 0
	EndIf
	
	cPafMd5 += AllTrim( cValToChar(nValor) )		//Quantidade
		
ElseIf 	SubStr( cAlias, 1, 3 ) == "MDZ"			

	//R06,R04,R05,R07
	cPafMd5 += AllTrim((cAlias)->MDZ_SERPDV)	//Numero de Serie
	cPafMd5 += AllTrim((cAlias)->MDZ_COO)		//COO
	cPafMd5 += AllTrim((cAlias)->MDZ_GNF)		//GNF
	cPafMd5 += AllTrim((cAlias)->MDZ_GRG)		
	cPafMd5 += AllTrim((cAlias)->MDZ_CDC)		//CDC
	cPafMd5 += AllTrim((cAlias)->MDZ_CCF)		//CCF
	
	nValor	:=	(cAlias)->MDZ_VALOR			
	cPafMd5 += AllTrim(cValToChar(nValor))	//Valor Liquido

	cPafMd5 += AllTrim(cValToChar((cAlias)->MDZ_HORA))
	cPafMd5 += AllTrim(STxEDtoC((cAlias)->MDZ_DATA))
	cPafMd5 += AllTrim((cAlias)->MDZ_SIMBOL)
	cPafMd5 += AllTrim((cAlias)->MDZ_NOMCLI)
	cPafMd5 += AllTrim((cAlias)->MDZ_CGCCLI)
	cPafMd5 += AllTrim((cAlias)->MDZ_SERIE)
	cPafMd5 += AllTrim((cAlias)->MDZ_TIPO)
	cPafMd5 += AllTrim((cAlias)->MDZ_PDV)
	cPafMd5 += AllTrim((cAlias)->MDZ_XMLENV) //XML PAF enviado?
	cPafMd5 += AllTrim((cAlias)->MDZ_NUM)

ElseIf SubStr( cAlias, 1, 3) == "SF2"
	//J1
	cPafMd5 += AllTrim(StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),"."))
	cPafMd5 += AllTrim((cAlias)->F2_CHVNFE)
	cPafMd5 += AllTrim((cAlias)->F2_ESPECIE)
	cPafMd5 += cValToChar((cAlias)->F2_DESCONT)
	cPafMd5 += cValToChar((cAlias)->F2_VALBRUT)
	cPafMd5 += AllTrim((cAlias)->F2_PDV)
	cPafMd5 += AllTrim((cAlias)->F2_ECF)
	cPafMd5 += AllTrim(STxEDtoC((cAlias)->F2_EMISSAO))
	cPafMd5 += cValToChar((cAlias)->F2_VALFAT)
	cPafMd5 += AllTrim((cAlias)->F2_CLIENTE)
	cPafMd5 += AllTrim((cAlias)->F2_LOJA)
	cPafMd5 += AllTrim((cAlias)->F2_CGCCLI)
	cPafMd5 += AllTrim((cAlias)->F2_DOC)
	cPafMd5 += AllTrim((cAlias)->F2_SERIE)
	
ElseIf SubStr( cAlias, 1, 3) == "SD2"
	//J2      
	cPafMd5 += AllTrim(StrTran(StrTran(StrTran(SM0->M0_CGC,"-"),"/"),"."))
	cPafMd5 += AllTrim((cAlias)->D2_ITEM)
	cPafMd5 += AllTrim((cAlias)->D2_DOC)
	cPafMd5 += cValToChar((cAlias)->D2_QUANT)
	cPafMd5 += cValToChar((cAlias)->D2_TOTAL)
	cPafMd5 += cValToChar((cAlias)->D2_PICM)
	cPafMd5 += cValToChar((cAlias)->D2_ALIQISS)
	cPafMD5 += cValToChar((cAlias)->D2_DESCON)
	cPafMD5 += cValToChar((cAlias)->D2_PRUNIT)
	cPafMD5 += cValToChar((cAlias)->D2_DECVLU)
	cPafMD5 += cValToChar((cAlias)->D2_DECQTD)
	cPafMD5 += AllTrim((cAlias)->D2_UM)
	cPafMd5 += AllTrim(STxEDtoC((cAlias)->D2_EMISSAO))
	cPafMd5 += AllTrim((cAlias)->D2_COD)
	cPafMd5 += AllTrim((cAlias)->D2_SERIE)
	cPafMd5 += AllTrim((cAlias)->D2_TES)
	
ElseIf Substr(cAlias, 1, 3) == "SLG"
	
	//deve ser mandado antes a informação do LG_ECFINFO
	/* não acrescentar mais campos senão deve alterar
	o conteudo enviado a função LJPRVldLG senão
	sempre dara erro no MD5*/
	cPafMD5 += AllTrim((cAlias)->LG_ECFINFO)
	cPafMd5 += Upper(AllTrim((cAlias)->LG_IMPFISC))

ElseIf Substr(cAlias, 1, 3) == "MFT"

	//D4	
	cPafMd5 += AllTrim((cAlias)->MFT_DOC)
	cPafMd5 += AllTrim((cAlias)->MFT_HRALT)
	cPafMd5 += AllTrim(STxEDtoC((cAlias)->MFT_ALTERA))
	cPafMd5 += AllTrim((cAlias)->MFT_PRODUT)
	cPafMd5 += AllTrim((cAlias)->MFT_DESCRI)		
	cPafMd5 += cValToChar((cAlias)->MFT_QUANT)
	cPafMd5 += AllTrim((cAlias)->MFT_UM)
	cPafMd5 += cValToChar((cAlias)->MFT_PRCTAB)
	cPafMd5 += cValToChar((cAlias)->MFT_VALDES)
	cPafMd5 += cValToChar((cAlias)->MFT_DESC)
	cPafMd5 += cValToChar((cAlias)->MFT_VLRITE)
	cPafMd5 += AllTrim((cAlias)->MFT_SITTRI)
	cPafMd5 += AllTrim((cAlias)->MFT_VENDID)
	cPafMd5 += AllTrim((cAlias)->MFT_SITUA)	
	cPafMd5 += AllTrim(cValToChar((cAlias)->MFT_DECVLU))
	cPafMd5 += AllTrim(cValToChar((cAlias)->MFT_DECQTD))
EndIf

If !Empty(AllTrim(cPafMd5))
	cPafMd5 := MD5(cPafMd5,2)
EndIf

Return cPafMd5
