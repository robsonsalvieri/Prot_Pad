#include "totvs.ch"
#include "OFIA539.CH"


/*/{Protheus.doc} OFIA539
Controla o processo de importação de arquivo para atualização da SB1 e SB5
@type function
@version
@author Jessé Augusto
@since 15/10/2025
@return variant, return_description
/*/
Function OFIA539()

	Local lAbort     As Logical
	Local lTudoOk    As Logical
	Local oControle  As Object
	Local aMsg 		 As Array
	local lSchedule := FWGetRunSchedule()

	aMsg := {}
	oControle       	  := JSonObject():New()
	oControle["schedule"] := lSchedule

	lTudoOk   := .F.
	lAbort    := .F.
	
	If lSchedule
		lTudoOk := OA539001M_VldTOk( @oControle )

		If !lTudoOk
			OA539009M_GrvLog( { STR0010 } )
			lAbort := .t.
		EndIf
	Else 
		While !lAbort .And. !lTudoOk

			lAbort  := Pergunte("OFIA539", .T., STR0032) // Parâmetro

			If !lAbort .Or. !OA539001M_VldTOk( @oControle )   

				lAbort  := If( !lAbort , .T., .F.) ; Loop   
			Else
				lTudoOk := .T.
			EndIf
		End
	EndIf  
	
	If lAbort .And. !lTudoOk 
		Return
	Else
		if MV_PAR07 == 3
			aadd(aMsg, {STR0019}) // "O arquivo será excluido ao final do processamento"
		endif

		aadd(aMsg, {STR0036}) //'Início do processo'

		oControle["id_log"] := OA539009M_GrvLog( aMsg ) 

		FWMsgRun(,{|| OA539002M_ExecutaLeitura( oControle )},, STR0020 )
	EndIf

Return

/*/{Protheus.doc} OA539001M_VldTOk
Realiza a validação geral em contextos com e sem Schedule
@type function
@version
@author Jessé Augusto
@since 15/10/2025
@param oControle, object, param_description
@return variant, return_description
/*/
Static Function OA539001M_VldTOk( oControle )    
	
	Local lSX6 := !Empty( GetNewPar( "MV_ARQPROD" ,"") ) 
	Local lSChedule := .F.
	local lOpen := .f.
	local oFile := nil

	oFile := FWFileReader():New( Alltrim( MV_PAR01 ) ) 
	lOpen := oFile:Open()
	oControle["ofile"] := oFile

	lSChedule		   := oControle["schedule"]

	If !lOpen 
		OA539010M_ExibeMensagem( lSChedule, "OA539001F", STR0007, STR0025 ) // Não foi possível realizar a leitura do arquivo informado // Verifique se o arquivo está presente no diretório informado e se é valido
		Return .F. 
	EndIf

	If !OA539008M_VldEstruturaArquivo( oControle ) 
		OA539010M_ExibeMensagem( lSChedule, "OA539001G", STR0008, STR0026 )  // O arquivo informado não é valido // Informe um arquivo válido
		oFile:Close()
		Return .F.
	EndIf 

	If Empty( Alltrim( StrTran( MV_PAR02,"/","" ) ) )  
		OA539010M_ExibeMensagem( lSChedule, "OA539001B", STR0003, STR0022 ) // O campo Grupos de Produto não foi preenchido // Informe, no mínimo, um grupo de produto válido
		Return .F. 
	EndIf   

	If MV_PAR07 == 2 .And. Empty(MV_PAR08)
		OA539010M_ExibeMensagem( lSChedule, "OA539001C", STR0004, STR0023 ) // O campo Mover Para não foi preenchido // Preencha o campo Mover Para com um diretório existente
		Return .F. 
	EndIf

	If !lSx6
		OA539010M_ExibeMensagem( lSChedule, "OA539001E", STR0006, STR0024 ) // O parâmetro MV_ARQPROD não existe ou não está habilitado neste ambiente  // Verifique se o parâmetro MV_ARQPROD existe e está preenchido com SB1 ou SBZ
		Return .F.
	EndIf



Return .T.

/*/{Protheus.doc} OA539008M_VldEstruturaArquivo
Realiza a validação da estrutura do arquivo a ser lido
@type function
@version  
@author Jessé Augusto
@since 15/10/2025
@param oControle, object, param_description
@return variant, return_description
/*/
Static Function OA539008M_VldEstruturaArquivo( oControle  )

	Local cLinha  := ""   As Character
	Local nVezes  := 0    As Numeric
	Local lTudoOk := .F.  As Logical
	local oFile := nil

	oFile := oControle["ofile"] 

	While ( oFile:hasLine() .And. nVezes <= 10 )

		cLinha  := oFile:GetLine()

		oControle["modelo"] := OA539003M_DefineLayout( cLinha )

		lTudoOk  := oControle["modelo"]["tudook"]

		nVezes += If( lTudoOk, 11 , 1 ) 
	End

Return lTudoOk

/*/{Protheus.doc} OA539002M_ExecutaLeitura
Executa a leitura do arquivo
@type function
@version  
@author Jessé Augusto
@since 15/10/2025
@param oControle, object, param_description
@return variant, return_description
/*/
Static Function OA539002M_ExecutaLeitura( oControle )

	Local cLin      As Character
	Local cId       As Character
	Local cLog      As Character
	Local nQuant    As Numeric
	Local lSB5      As Logical
	Local lOA539Lin As Logical 
	Local lOA539Fim As Logical 
	Local aGrupos   As Array 
	local aItNoEx 	as array
	local cGroup 	as Character
	local oFile := nil

	aGrupos   := OA539011M_SeparaGrupo()
	
	oDados    := oControle["modelo"]
	oFile     := oControle["ofile"]

	nPos      := aScan( oDados["indices"], {|x| x["campo"] == "B1_COD" })

	nPosIni   := If( nPos > 0 , oDados["indices"][nPos]["inicio"] , 0 )
	nPosFim   := If( nPos > 0 , oDados["indices"][nPos]["fim"]    , 0 )
	nQuant    := 0

	lSB5      := aSCan( oDados["itens"], {|x| Left( x["campo"] , 2 ) == "B5" }) > 0

	lOA539Lin := ExistBlock("OA539LIN")
	lOA539Fim := ExistBlock("OA539FIM")

	cLog	  := oControle["id_log"]

	cFilBck   := cFilAnt

	aItNoEx := {}
	
	SB1->(dbSetOrder(7)) // Grupo + Cod Item		

	While ( oFile:hasLine() )			

		cFilAnt := cFilBck
		
		cLin    := oFile:GetLine()
		
		cId     := SubStr( cLin, nPosIni, nPosFim )
		
		nTam    := 1
		
		While nTam <= Len( aGrupos )    
			cGroup := aGrupos[nTam]
			cChave := xFilial("SB1") + PadR(cGroup, TamSx3("B1_GRUPO")[1]) + PadR( cId, TamSx3("B1_CODITE")[1] )

			If !SB1->(MsSeek( cChave ) )
				aadd(aItNoEx, {Alltrim(cGroup), Alltrim(cId)}) //Grupo e CodIte, vão ser passados para o log na VQL, um Json só contendo os itens que não foram encontrados na B1
				nTam++
				Loop
			EndIf 

			OA539004M_GRAVASB1( oDados , cLin, cLog  )
			nTam++
		End 

		If lOA539Lin 
			ExecBlock("OA539LIN",.f.,.f.,{ cLin } ) 
		EndIf 
		
		nQuant++
	EndDo
	
	If lOA539Fim
		ExecBlock("OA539FIM",.f.,.f.,{} ) 
	EndIf

	cFilAnt := cFilBck

	oFile:Close()
	
	if len(aItNoEx) > 0
		OA539009M_GrvLog({OA539012J_MontaJsonDeItensNaoImportados(aItNoEx)}, cLog)
	endif
	fwFreeArray(aItNoEx)

	If MV_PAR07 != 1 .And. nQuant > 0

		OA539006M_MoveArquivo( oFile:cFileName , cLog )
	
	ElseIf MV_PAR07 == 1  

		OA539009M_GrvLog( { STR0009  }, cLog ) // "Nenhuma acao foi realizada sobre o arquivo"
	EndIf

	OA539009M_GrvLog( { STR0010 }, cLog )      // "Processo finalizado"  

Return 

/*/{Protheus.doc} OA539006M_MoveArquivo
Move e exclui o arquivo dentro do diretorio
@type function
@version  
@author Jessé Augusto
@since 15/10/2025
@param cFile, character, param_description
@param cLog, character, param_description
@return variant, return_description
/*/
Static Function OA539006M_MoveArquivo( cFile, cLog )

	Local cDesc    As Character
	Local cDestino As Character
	Local lMove    As Logical
	Local lDel     As Logical 
	
	cDesc    := SubStr( cFile, Rat("\", cFile) + 1 , Len(cFile) )

	cDestino := Alltrim(MV_PAR08) + "\"

	lDel     :=  MV_PAR07 == 3
	lMove    :=  MV_PAR07 == 2
	lOk		 := .F. 

	lOk 	 := If(  ( lMove .And. __CopyFile( cFile , cDestino + cDesc ) ) .Or. lDel,  Ferase( cFile ) == 0 ,  .F. )  
	
	If lOk .And. ( lDel .Or. lMove )

		cDesc := If( lDel , STR0011, STR0012 ) + " " + cDestino 
		
		OA539009M_GrvLog( { cDesc }, cLog )   
	EndIf

Return lOk         

/*/{Protheus.doc} OA539005M_PreValid
Executa a pré-validação em tempo de digitaçao
@type function
@version  
@author Jessé Augusto
@since 15/10/2025
@param nCampo, numeric, Indicativo utilizado na SX1 para indicar qual função sendo que 
	nCampo == 1 referente ao tratamento do MV_PAR01
	nCampo == 2 referente ao tratamento do MV_PAR02
	nCampo == 3 referente a tratamentos dos seguintes parâmetros MV_PAR03, MV_PAR04, MV_PAR05
	nCampo == 4 referente ao tratamento do MV_PAR08
@return variant, return_description
/*/
Function OA539005M_PreValid( nCampo )

	Local cMascara As Character
	Local cPrefixo As Character
	Local nX   	   As Number
	Local nErro    As Number
	Local aGrupos  As Array
	Local aAux     As Array
	Local xValue   As Variant
	Local lRet     As Logical
	Local lMove    As Logical
	Local lFileOk  As Logical
	Local lDirOk   As Logical
	
	xValue := Upper(Alltrim(&(ReadVar())))
	
	lRet   := .T.
	
	lMove  := nCampo == 2  

	If nCampo == 1  .Or. nCampo == 4

		cMascara := If( !lMove, "*.txt|*.txt", "" )

		If nCampo == 1
			
			lFileOk := File( MV_PAR01 ) 

			If !lFileOk
				xValue  := MV_PAR01 := cGetFile( cMascara , STR0015, , STR0016, .T., 0, .T., .T. ) // Selecione // SERVIDOR
			EndIf 
			
			return !Empty(xValue) .And. File( MV_PAR01 ) 
		Else
			
			lDirOk   := ExistDir( MV_PAR08 ) 

			If !lDirOk
				xValue := MV_PAR08 := cGetFile( cMascara , STR0015, , STR0016, .T., 128, .T., .T. ) // Selecione // SERVIDOR
			EndIf 

			return !Empty(xValue) .And. ExistDir( MV_PAR08 ) 
		EndIf
	EndIf

	If nCampo == 2
		
		aGrupos := {} 
		nErro := 0
		
		aAux    := StrTokArr( Alltrim(xValue), "/" )   
		
		For nX := 1 To Len( aAux )
			
			If SBM->(dbSeek( xFilial("SBM") + PadR( Alltrim(aAux[nX]), TamSx3("BM_GRUPO")[1] ) ) )
				 
				aAdd( aGrupos , SBM->BM_GRUPO )
			
			ElseIf !Empty( aAux[nX] )

				nErro++
			EndIf	 

		Next nX 

		If nErro > 0	
			
			OA539010M_ExibeMensagem( .F., "OA539005A", STR0013, STR0027 ) // Um ou mais grupo informado não está presente no cadastro // Informe apenas grupos válidos
			Return .F. 

		ElseIf Len(aGrupos) > 1 
			
			aAux := {}; nX	:= 1

			While nX <= Len(aGrupos) 
				
				nPos := aSCan( aAux, {|x| x == aGrupos[nX] }  ) 

				If nPos <= 0
					aAdd( aAux , aGrupos[nX] ) 
				Else

					OA539010M_ExibeMensagem( .F., "OA539005B", STR0017 + " " + aAux[nPos], STR0028 ) // Foi identificada reincidência na digitação do grupo // Evite digitar grupos repetidos

					nX := Len(aGrupos) + 1
					lRet := .F.
				EndIf
				nX++
 			End

			Return lRet
		EndIf 
	EndIf 

	If nCampo == 3
		
		cPrefixo := "B1_PRV1|B5_PRV2|B5_PRV3|B5_PRV4|B5_PRV5|B5_PRV6|B5_PRV7"

		lRet     := lExist := ExistCPO("SX3", xValue ,2) .And. GetSX3Cache( xValue, "X3_TIPO") != Nil .And. xValue $ cPrefixo

		If lExist

			aCampos := { MV_PAR03, MV_PAR04, MV_PAR05 }; nErro := 0 

			For nX := 1 To Len( aCampos )
				  
				nErro += If( xValue == Upper(Alltrim( aCampos[nX] )) , 1, 0 ) 

			Next nX 

			If nErro > 1
			
				OA539010M_ExibeMensagem( .F., "OA539005C", STR0018, STR0029 ) ; Return .F. // O campo informado já está em uso  // Evite utilizar campos repetidos  
			EndIf 
		EndIf 
	EndIf  

Return lRet
/*/{Protheus.doc} OA539004M_GravaSB1
Executa a gravação dos dados da SB1
@type function
@version  
@author Jessé Augusto
@since 15/10/2025
@param aItens, array, param_description
@param cLin, character, param_description
@param cLog, character, param_description
@return variant, return_description
/*/

Static Function OA539004M_GravaSB1( oMoldura , cLin, cLog )  

	Local aSBZFil  As Array 
	Local lSB5     As Logical
	Local lSBZ     As Logical
	Local nX       As Number 
	Local nW       As Number 

	aSB1Fil := { xFilial("SB1") } 
	aSB5Fil := If( FWModeAccess("SB5", 3) == "E", FWAllFilial(), { xFilial("SB5") }) 
	aSBZFil := If( FWModeAccess("SBZ", 3) == "E", FWAllFilial(), { xFilial("SBZ") }) 
	
	cPula   := Chr(13) + Chr(010) 

	SB5->(dbSetOrder(1)) 
	SBZ->(dbSetOrder(1))

	cChave := SB1->B1_COD 
	
	// SB1 
	If !Empty( aSB1Fil ) .And. !Empty( oMoldura["sb1"] )

		For nX  := 1 To Len( aSB1Fil )
			
			SB1->(RecLock("SB1", .F. ))
			
			For nW := 1 To Len( oMoldura["sb1"] )
				
				cCampo  := oMoldura["sb1"][nW]["campo"]
				cColuna	:= oMoldura["sb1"][nW]["nome"]
				
				nIni    := oMoldura["sb1"][nW]["inicio"] 
				nFim    := oMoldura["sb1"][nW]["fim"]

				xParte  := SubStr( cLin, nIni, nFim ) 

				lTipoN  := GetSX3Cache( cCampo, "X3_TIPO") == "N" 
				
				If lTipoN .And. !IsNumeric( xParte ) 
					
					OA539009M_GrvLog( { STR0033 + cPula + STR0034 + cLin + cPula + STR0035 + cColuna  }, cLog ) // Falha na leitura da linha // Linha: / Coluna: 
					Loop
				EndIf

				xValor := &(oMoldura["sb1"][nW]["valor"])

				SB1->&(cCampo) := xValor

			Next nW
			
			SB1->(MsUnlock()) 

		Next nX  
	
	EndIf 

	// SB5
	If !Empty( aSB5Fil ) .And. !Empty( oMoldura["sb5"] )

		For nX  := 1 To Len( aSB5Fil ) 

			cFilAnt := aSB5Fil[nX]
			
			lSB5	:= SB5->( MsSeek( xFilial("SB5") + SB1->B1_COD ) )  

			SB5->(RecLock("SB5", !lSB5 ))
			
			For nW := 1 To Len( oMoldura["sb5"] )
				
				cCampo 	:= oMoldura["sb5"][nW]["campo"]
				cColuna	:= oMoldura["sb5"][nW]["nome"]
				
				nIni	:= oMoldura["sb5"][nW]["inicio"]  
				nFim 	:= oMoldura["sb5"][nW]["fim"]

				xValor 	:= &(oMoldura["sb5"][nW]["valor"]) 

				xParte  := SubStr( cLin, nIni, nFim ) 

				lTipoN := GetSX3Cache( cCampo, "X3_TIPO") == "N"
				
				If lTipoN .And. !IsNumeric( xParte ) 
					
					OA539009M_GrvLog( { STR0033 + cPula + STR0034 + cLin + cPula + STR0035 + cColuna  }, cLog ) // Falha na leitura da linha // Linha: / Coluna:
					Loop
				EndIf  

				SB5->&(cCampo) 	:= xValor 

			Next nW
			
			SB5->(MsUnlock())

		Next nX  		
	EndIf 

	// SBZ 
	If !Empty( aSBZFil ) .And.  !Empty( oMoldura["sbz"] ) 

		For nX  := 1 To Len( aSBZFil )

			cFilAnt := aSBZFil[nX] 
			
			lSBZ	:= SBZ->( MsSeek( xFilial("SBZ") + SB1->B1_COD ) )   

			SBZ->(RecLock("SBZ", !lSBZ ))
			
			For nW := 1 To Len( oMoldura["sbz"] )
				
				cCampo 	:= oMoldura["sbz"][nW]["campo"]  
				cColuna	:= oMoldura["sbz"][nW]["nome"]

				nIni	:= oMoldura["sbz"][nW]["inicio"]  
				nFim 	:= oMoldura["sbz"][nW]["fim"]

				xValor 	:= &(oMoldura["sbz"][nW]["valor"])  

				xParte  := SubStr( cLin, nIni, nFim ) 

				lTipoN  := GetSX3Cache( cCampo, "X3_TIPO") == "N"  
				
				If lTipoN .And. !IsNumeric( xParte ) 
					
					OA539009M_GrvLog( { STR0033 + cPula + STR0034 + cLin + cPula + STR0035 + cColuna  }, cLog ) // Falha na leitura da linha // Linha: / Coluna:

					Loop
				EndIf 

				SBZ->&(cCampo) 	:= xValor 		 	

			Next nW
			
			SBZ->(MsUnlock())

		Next nX 
	EndIf 

Return 

/*/{Protheus.doc} OA539003M_DefineLayout
Definição do modelo de leitura do arquivo
@type function
@version  
@author Jessé Augusto 
@since 15/10/2025
@param cLin, character, param_description
@return variant, return_description
/*/
Static Function OA539003M_DefineLayout( cLin )

	Local cValor	 As Character
	Local lPub	     As Logical
	Local l30d	     As Logical
	Local lBalcao    As Logical
	Local lAtuSB1    As Logical
	Local lAtuSBZ    As Logical
	Local lAtuQtd    As Logical
	Local oDados     As Object
	Local oItem    	 As Object
	Local aSB1 	     As Array

	aSB1		       	   := SB1->(FWGetArea())
  
	lPub	               := !Empty( Alltrim( MV_PAR03 ) )
	l30d	               := !Empty( Alltrim( MV_PAR04 ) )
	lBalcao                := !Empty( Alltrim( MV_PAR05 ) ) 

	lAtuSB1         	   := GetNewPar("MV_ARQPROD","") == "SB1"
	lAtuSBZ         	   := GetNewPar("MV_ARQPROD","") == "SBZ"
	
	lAtuQtd         	   := MV_PAR06 == 1

	oDados  		       := JSonObject():New()
	oDados["itens"]        := {}
	oDados["itens"]        := {}
	oDados["indices"]      := {}
	oDados["sb1"]          := {}
	oDados["sb5"]          := {}
	oDados["sbz"]          := {} 

	// Estrutura de valor que será, posteriormente, utilizada em ExecAuto por meio da Macrosubstituição 
	cValor				   := "Val( SubStr( cLin, aItens[nX]['inicio'], aItens[nX]['fim'] ) )" 

	// Item
	oItem   	    	   := JSonObject():New()
	oItem["nome"]   	   := "Item"
	oItem["campo"]  	   := "B1_COD"
	oItem["ativo"]  	   := .F.
	oItem["inicio"] 	   :=  0
	oItem["fim"]    	   :=  0
	oItem["tamanho"]   	   :=  7
	oItem["valor"]  	   := cValor
	aAdd( oDados["itens"]  , oItem )
	aAdd( oDados["indices"], oItem )

	// Publico
	oItem   	    	   := JSonObject():New()
	oItem["nome"]   	   := "Publico"
	oItem["campo"]  	   := MV_PAR03
	oItem["ativo"]  	   := lPub
	oItem["inicio"] 	   := 0
	oItem["fim"]    	   := 0
	oItem["tamanho"]   	   := 0
	oItem["valor"]  	   := "Val( SubStr( cLin, nIni, nFim ) ) / 100"
	aAdd( oDados[ "itens"] , oItem)

	// Publico 30d
	oItem   	           := JSonObject():New()
	oItem["nome"]          := "Publico 30d"
	oItem["campo"]         := MV_PAR04
	oItem["ativo"]         := l30d
	oItem["inicio"]        := 0
	oItem["fim"]           := 0
	oItem["tamanho"]   	   := 0
	oItem["valor"]         := "Val( SubStr( cLin, nIni, nFim ) ) / 100" 
	aAdd( oDados[ "itens"] , oItem)

	// Balcao
	oItem   	           := JSonObject():New()
	oItem["nome"]          := "Balcao"
	oItem["campo"]         := MV_PAR05
	oItem["ativo"]         := lBalcao
	oItem["inicio"]		   := 0
	oItem["fim"]           := 0 
	oItem["tamanho"]   	   := 0
	oItem["valor"]         := "Val( SubStr( cLin, nIni, nFim ) ) / 100" 
	aAdd( oDados[ "itens"] , oItem)
	
	// B5_FILIAL     
	oItem   	           := JSonObject():New()
	oItem["nome"]          := "B5_FILIAL"
	oItem["campo"]         := "B5_FILIAL"
	oItem["ativo"]         := .T. 					  
	oItem["inicio"]		   := 0	
	oItem["fim"]           := 0
	oItem["tamanho"]   	   := 0
	oItem["valor"]         := 'xFilial("SB5")'
	aAdd( oDados[ "itens"] , oItem)
	
	// B5_COD
	oItem   	           := JSonObject():New()
	oItem["nome"]          := "B5_COD"
	oItem["campo"]         := "B5_COD"
	oItem["ativo"]         := .T. 					  
	oItem["inicio"]		   := 0	
	oItem["fim"]           := 0
	oItem["tamanho"]   	   := 0
	oItem["valor"]         := "SB1->B1_COD"
	aAdd( oDados[ "itens"] , oItem) 
	
	// B5_CEME
	oItem   	           := JSonObject():New()
	oItem["nome"]          := "B5_CEME"
	oItem["campo"]         := "B5_CEME"
	oItem["ativo"]         := .T. 					  
	oItem["inicio"]		   := 0	
	oItem["fim"]           := 0
	oItem["tamanho"]   	   := 0
	oItem["valor"]         := "SB1->B1_DESC"
	aAdd( oDados[ "itens"] , oItem)
	
	// B1_QE
	If lAtuQtd .And. lAtuSB1 

		oItem   			:= JSonObject():New() 
		oItem["nome"]       := "Qt.Peca_Emb"
		oItem["campo"]     	:= "B1_QE"
		oItem["ativo"]      := .T.
		oItem["inicio"]		:=  0
		oItem["fim"]        :=  0
		oItem["tamanho"]   	:=  0 
		oItem["valor"]     	:=  "Val( SubStr( cLin, nIni, nFim ))" 
		aAdd( oDados[ "itens"] , oItem)
		
	ElseIf lAtuQtd .And. lAtuSBZ 

		// BZ_FILIAL
		oItem   			:= JSonObject():New() 
		oItem["nome"]       := "BZ_FILIAL" 
		oItem["campo"]     	:= "BZ_FILIAL"
		oItem["ativo"]      := .T.
		oItem["inicio"]		:=  0
		oItem["fim"]        :=  0
		oItem["tamanho"]   	:=  0
		oItem["valor"]     	:= 'xFilial("SBZ")'
		aAdd( oDados[ "itens"] , oItem )
		
		// BZ_COD
		oItem   			:= JSonObject():New() 
		oItem["nome"]       := "BZ_COD" 
		oItem["campo"]     	:= "BZ_COD"
		oItem["ativo"]      := .T.
		oItem["inicio"]		:=  0
		oItem["fim"]        :=  0
		oItem["tamanho"]   	:=  0
		oItem["valor"]     	:= "SB1->B1_COD"  
		aAdd( oDados[ "itens"] , oItem )
		
		// BZ_LOCPAD
		oItem   			:= JSonObject():New() 
		oItem["nome"] 		:= "BZ_LOCPAD"
		oItem["campo"]     	:= "BZ_LOCPAD" 
		oItem["ativo"]      := .T.
		oItem["inicio"]		:=  0
		oItem["fim"]        :=  0
		oItem["tamanho"]   	:=  0
		oItem["valor"]     	:= "SB1->B1_LOCPAD"
		aAdd( oDados[ "itens"] , oItem )
		
		// BZ_QE
		oItem   			:= JSonObject():New()
		oItem["nome"] 		:= "Qt.Peca_Emb"
		oItem["campo"]     	:= "BZ_QE"
		oItem["ativo"]      := .T.
		oItem["inicio"]		:= 0
		oItem["fim"]        := 0
		oItem["tamanho"]   	:= 0
		oItem["valor"]     	:= "Val( SubStr( cLin, nIni, nFim ) )"
		aAdd( oDados[ "itens"] , oItem )
	
	ElseIf !lAtuQtd 

		oItem   			:= JSonObject():New() 
		oItem["nome"]       := "Qt.Peca_Emb"
		oItem["campo"]     	:= ""
		oItem["ativo"]      := .F.
		oItem["inicio"]		:=  0
		oItem["fim"]        :=  0
		oItem["tamanho"]   	:=  0
		oItem["valor"]     	:=  ""
		aAdd( oDados[ "itens"] , oItem)	 
	EndIf

	oDados := OA539007M_Mapeia_Colunas( cLin , oDados )  

	SB1->(FWRestArea(aSB1)) 

Return  oDados

/*/{Protheus.doc} OA539007M_Mapeia_Colunas
Mapeia as colunas do arquivo .TXT
@type function
@version  
@author Jessé Augusto
@since 15/10/2025
@param cLin, character, param_description
@param oDados, object, param_description
@return variant, return_description
/*/
Static Function OA539007M_Mapeia_Colunas( cLin , oDados )

	Local nX      := 0
	Local nAux    := 0
	Local aAux    := {}
	Local aCampos := {"Item", "Publico", "Publico 30d", "Balcao", "Qt.Peca_Emb" } 

	For nX  := 1 To Len( aCampos )

		nPos := At( aCampos[nX], cLin )

		If nPos > 0

			nIndex	:= aSCan( oDados[ "itens"], {|x| Upper( x["nome"] )  == Upper( aCampos[nX] ) } )

			If nIndex >  0 

				nTam := oDados["itens"][nIndex]["tamanho"]

				nTam := If( nTam > 0, nTam , Len( oDados["itens"][nIndex]["nome"] ) )

				oDados["itens"][nIndex]["inicio"]  := nPos
				oDados["itens"][nIndex]["fim"]     := nTam

				nAux++
			EndIf
		EndIf

	Next nX 

	oDados["tudook"] := Len( aCampos ) == nAux 

	For nX := 1 To Len( oDados["itens"] )   
		
		xItem  := oDados["itens"][nX] 

		If xItem["ativo"]

			If( Left( xItem["campo"], 2 ) == "B1" , aAdd( oDados["sb1"], xItem) ,  )
			If( Left( xItem["campo"], 2 ) == "B5" , aAdd( oDados["sb5"], xItem) ,  )
			If( Left( xItem["campo"], 2 ) == "BZ" , aAdd( oDados["sbz"], xItem) ,  )

			aAdd( aAux, xItem ) 
		EndIf 

	Next nX

	oDados["itens"] := If( !Empty( aAux ), aAux,  oDados["itens"] )

Return oDados

/*/{Protheus.doc} OA539009M_GrvLog
Grava os logs da operação
@type function
@version
@author Jessé Augusto
@since 15/10/2025
@param aMsg, array, param_description
@param cId, character, param_description
@return variant, return_description
/*/
Static Function OA539009M_GrvLog( aMsg, cId )

	Local oLogger   As Object
	Local jLog      As JSon
	Local jItem     As JSon
	Local aValor    As Array
	Local lSchedule	As Logical
	Local nX		As Numeric

	Default cId   := ""
	Default aMsg  := {}
	
	lSchedule				 := FWGetRunSchedule()
	
	jLog			         := JSonObject():New() 
	jLog["geral"]            := {}
	jLog["parametros"]       := {}
	jLog["mensagem"]         := {}

	// Captura os parâmetros da SX1 usados pelo usuário
	jItem 			         := JSonObject():New()
	jItem["MV_PAR01"]        := Alltrim( MV_PAR01 )
	jItem["MV_PAR02"]        := Alltrim( MV_PAR02 )
	jItem["MV_PAR03"]        := Alltrim( MV_PAR03 ) 
	jItem["MV_PAR05"]        := Alltrim( MV_PAR05 )
	jItem["MV_PAR04"]        := Alltrim( MV_PAR04 )
	jItem["MV_PAR06"]        := Alltrim( MV_PAR06 )
	jItem["MV_PAR08"]        := Alltrim( MV_PAR08 ) 
	jItem["MV_PAR07"]        := MV_PAR07
	
	aAdd( jLog["parametros"] , jItem )

	// Obtém os dados gerais do Sistema
	jItem 			         := JSonObject():New()
	jItem["EMPRESA"]         := cEmpAnt
	jItem["FILIAL"]          := cFilAnt
	jItem["USUARIO"]         := cUserName
	jItem["MODE_EXECUCAO"]   := If( lSchedule , "SCHEDULE","MANUAL" )  
	
	aAdd( jLog["geral"]      , jItem )

	For nX := 1 To Len( aMsg )
		
		aAdd( jLog["mensagem"], aMsg[nX] ) 
	Next nX 

	// Aciona o processo de gravação dos dados
	aValor :=  {}
	aAdd( aValor , {"VQL_AGROUP", "OFIA539"       							  })
	aAdd( aValor , {"VQL_FILORI", xFilial("VQL")  							  })
	aAdd( aValor , {"VQL_DATAI" , dDatabase       							  }) 
	aAdd( aValor , {"VQL_DATAF" , dDatabase       							  })
	aAdd( aValor , {"VQL_HORAI" , Val( StrTran( Left( Time(), 5), ":", "" ) ) })
	aAdd( aValor , {"VQL_HORAF" , Val( StrTran( Left( Time(), 5), ":", "" ) ) }) 
	aAdd( aValor , {"VQL_MSGLOG", jLog:ToJSon()  							  })  
	
	If !Empty(cId)
		aAdd( aValor , {"VQL_CODVQL", cId  							  	      })    
	EndIf 
	
	oLogger := DMS_Logger():New()

Return oLogger:LogToTable( aValor )

/*/{Protheus.doc} OA539010M_ExibeMensagem
Controla o processo de emitir mensagem de valida ou gerar log
@type function
@version
@author Jessé Augusto
@since 16/10/2025
@param lSchedule, logical, param_description
@param cLabel, character, param_description
@param cMsg, character, param_description
@param cSolucao, character, param_description
@return variant, return_description 
/*/
Static Function OA539010M_ExibeMensagem( lSchedule, cLabel, cMsg, cSolucao )
		
	OA539009M_GrvLog( { cMsg, cSolucao } )   
	
	If !lSChedule
		FMX_HELP( cLabel, cMsg, cSolucao )
	EndIf

Return 

/*/{Protheus.doc} OA539011M_SeparaGrupo
Realiza a separação dos grupos dentro da variável
@type function
@version  
@author Jessé Augusto
@since 16/10/2025
@return variant, return_description
/*/
Static Function OA539011M_SeparaGrupo()  

	Local nX 	  As Numeric 
	Local aGrupos As Array

	aGrupos := {}
	aAux    := StrTokArr( Alltrim(MV_PAR02), "/" ) 
	
	For nX := 1 To Len( aAux )
		
		If !Empty( Alltrim( aAux[nX] ) )
			 
			aAdd( aGrupos, Alltrim( aAux[nX] ) )
		EndIf 

	Next nX

Return aGrupos

Static Function OA539012J_MontaJsonDeItensNaoImportados(aItens)
	local jJson := JSonObject():New()
	local jAuxJson := nil
	local nX := 0

	jJson['notFoundItems'] := {}
 
	for nX := 1 to len(aItens)
		jAuxJson := JSonObject():New()
		jAuxJson["groupCode"] := alltrim(aItens[nx][1])
		jAuxJson["itemId"] := alltrim(aItens[nX][2])
		aadd(jJson['notFoundItems'], jAuxJson)
		freeObj(jAuxJson)
	next
Return jJson:ToJSon()



/*/{Protheus.doc} SchedDef
Estabelece a comunicaçã que permite a definição do Pergunte por SChedule
@type function
@version  
@author Jessé Augusto
@since 10/15/2025
@return variant, return_description
/*/
Static Function SchedDef() 

	local aParam := {}

	aadd(aParam, "P")
	aadd(aParam, "OFIA539")
	aadd(aParam, "")
	aadd(aParam, {})
	aadd(aParam, "")
	aadd(aParam, "")


Return aParam