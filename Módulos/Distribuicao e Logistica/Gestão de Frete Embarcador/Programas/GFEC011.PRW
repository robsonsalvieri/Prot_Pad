#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEC011
Movimentação por Período
Generico

@sample
GFEC011()

@author Felipe M. / Alan Victor Lamb
@since 26/07/12
@version 1.0                                                                                      
*/
//------------------------------------------------------------------------------------------------/*/  
Function GFEC011()   
	Local aStruct := {}, nCont 
	Private oBrowse011, cAlias, aCampos
		
	//Array principal com os campos.. *fazer manutenção aqui*
	aCampos := {{""					,"M0_OK"         ,"C",01          ,0, ""  },;
				{"Código Filial"		,"M0_CODFIL"   	,"C",Len(cFilAnt),0, ""  },;
				{"Nome Filial"		,"M0_FILIAL"	    ,"C",25          ,0, "@!"},;
				{"Nome Comercial"		,"M0_NOMECOM"    ,"C",25          ,0, ""  },;
				{"Cid. de Entrega"	,"M0_CIDENT"     ,"C",15          ,0, ""  },;
				{"UF de Entrega","M0_ESTENT"     ,"C",2           ,0, ""  }}
	For nCont := 2 to Len(aCampos)
		aADD(aStruct,{ aCampos[nCont][1],;
						aCampos[nCont][2],;
						aCampos[nCont][3],;
						aCampos[nCont][4],;
						aCampos[nCont][5],;
						aCampos[nCont][6]})
	Next nCont
	
	cAlias := GFEC011TAB() // Cria a tabela
	GFEC011FIL(cAlias) // Carrega as Filiais
	
	oBrowse011 := FWMarkBrowse():New()
	oBrowse011:SetTemporary(.T.)
	oBrowse011:SetAlias(cAlias)						    // Alias da tabela utilizada
	oBrowse011:SetMenuDef("GFEC011")				        // Nome do fonte onde esta a função MenuDef
	oBrowse011:SetDescription("Consulta de Movimentação de Carga por Período")	// Descrição do browse   
	oBrowse011:SetFieldMark("M0_OK")
	oBrowse011:SetFields(aStruct)
	oBrowse011:SetAllMark({|| MarcaRegistro() })
	oBrowse011:Activate()
	GFEDelTab(cAlias)
return(Nil)

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Movimentação" ACTION "GFEC011OPC(1)" OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE "Ocorrências" 	 ACTION "GFEC011OPC(2)" OPERATION 2 ACCESS 0
Return aRotina   


/*-------------------------------------------------------------------                                                                           
{Protheus.doc} MarcaRegistro
Marcação de Todos os Registros quando clicado no header

@author Lucas Manolli de Oliveira Cristo
@since 06/06/2014
@version 1.0
-------------------------------------------------------------------*/
Function MarcaRegistro()

	dbSelectArea(cAlias)
	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())
		
		If((cAlias)->M0_OK <> oBrowse011:Mark())
				
			(cAlias)->M0_OK := oBrowse011:Mark()
			
		ElseIf ((cAlias)->M0_OK  == oBrowse011:Mark())
			
			(cAlias)->M0_OK := " "
			
		EndIf
		(cAlias)->(DbSkip())
	EndDo
	
	oBrowse011:Refresh(.T.)
Return

Function GFEC011FIL(cAlias)
	Local nCont 
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(dbGoTop())
	While SM0->(!Eof())      
		RecLock((cAlias),.T.)
		
		//Carregando as informações das filiais
		For nCont := 2 to Len(aCampos)
			(cAlias)->&(aCampos[nCont][2])   := SM0->&(aCampos[nCont][2])	
		Next nCont
		
		MsUnlock()
	    SM0->(DbSkip())
	EndDo
Return 

Function GFEC011TAB()
	Local nCont, aStruct := {} 
    //busca no aCampos as propriedades para criar as colunas
	For nCont := 1 to Len(aCampos) 
		aADD(aStruct,{aCampos[nCont][2], aCampos[nCont][3], aCampos[nCont][4], aCampos[nCont][5]})
	Next nCont 
	cAlias := GFECriaTab({aStruct,{"M0_CODFIL"}}) 
Return cAlias  

Function GFEC011OPC(nOpcao)
	Local aParam := {}, aFiliais := {}
	dbSelectArea(cAlias)
	dbCommit()
	(cAlias)->(dbGoTop())
	While (cAlias)->(!Eof())
		If !((cAlias)->M0_OK == " ") 
	    	aADD( aFiliais, (cAlias)->M0_CODFIL )
		EndIf
		
		(cAlias)->(DbSkip())
	EndDo
		
	//Validação
	If Len(aFiliais) == 0
		Alert("É necessario escolher pelo menos uma filial")
		Return
	EndIf
	
	If !Pergunte("GFEC011")
		Return
	EndIf
	
	If Vazio(MV_PAR02)
		Help( ,, 'HELP',, "Data final não informada.", 1, 0,)
		Return Nil
	EndIf
	
	If !(MV_PAR03 > 0)
		Help( ,, 'HELP',, "Quantidade de períodos deve ser maior que 0.", 1, 0,)
		Return Nil
	EndIf
	
	aADD( aParam, aFiliais )
	aADD( aParam, MV_PAR01 ) //Tipo de Periodo
	aADD( aParam, MV_PAR02 ) //Data Final
	aADD( aParam, MV_PAR03 ) //Qtd de periodos
	aADD( aParam, MV_PAR06 ) //Grupo de Transp 
	aADD( aParam, MV_PAR04 ) //Transp de
	aADD( aParam, MV_PAR05 ) //Transp até
	
	If nOpcao == 1 // Movimentação
		GFEC011A(aParam)
	ElseIf nOpcao == 2 // Ocorrências
		GFEC011B(aParam)
	EndIf
Return
