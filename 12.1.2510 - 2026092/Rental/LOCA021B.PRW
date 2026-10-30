#Include "LOCA021B.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE FAT_RECORRENTE  '1'
#DEFINE FAT_CUSTO		'2'
#DEFINE FAT_PRORATA     '3'
#DEFINE FAT_MEDICAO     '4'
#DEFINE FAT_FRETE       '5'


// Valor do PEdido Simulado
STATIC cSIMFPY := "000"

/*
	Implementa a simulação do faturamento
*/

/*/ Protheus.doc} LOCA021BTR
Cria o Arquivo de trabalho para simulação do faturamento
@type function
@version 25.10
@author Alexandre Circenis
@since 14/05/2026
@return variant, Objeto contendo os dados do Arquivo temporario
/*///Cria os arquivos TRB
Function LOCA021BTR( oTmpFPY, oTmpFPZ )
Local aStru1 := CamposSC5()
Local aStru2 := CamposFPY()

Local aStru3 := CamposSC6()
Local aStru4 := CamposFPZ()

Local aStru  :=  {}
Local nX

// Primeira Tabela Cabeçalho SC5 e FPY
Aadd(aStru,{  "OK"         ,"C",02,0})

For nX := 1 to Len(aStru1)
	Aadd( aStru ,  FWSX3Util():GetFieldStruct( aStru1[nX,2] ) )
	aStru[ Len(aStru), 1] := aStru1[nX,1]
next

For nX := 1 to Len(aStru2)
	if aScan(aStru, { |x| x[1] = aStru2[nx,1]}) = 0	
		Aadd( aStru ,  FWSX3Util():GetFieldStruct( aStru2[nX,2] ) )
		aStru[ Len(aStru), 1] := aStru2[nX,1]
	endif
next

For nX := 1 to Len(aStru3)
	if aScan(aStru, { |x| x[1] = aStru3[nx,1]}) = 0	
		Aadd( aStru ,  FWSX3Util():GetFieldStruct( aStru3[nX,2] ) )
		aStru[ Len(aStru), 1] := aStru3[nX,1]
	endif
next

Aadd(aStru,{ "CUSTNEG"          ,"C",200,0})
Aadd(aStru,{ "XXY_EMAIL"        ,"C",1,0})

If oTmpFPY <> Nil
	oTmpFPY:Delete()
	oTmpFPY := Nil
Endif

oTmpFPY := FWTemporaryTable():New( GetNextAlias() )  
oTmpFPY:SetFields(aStru) 	
oTmpFPY:AddIndex("1", { "XXY_PEDVEN","XXY_ITEM"})
oTmpFPY:AddIndex("2", { "XXY_PROJET","XXY_PEDVEN","XXY_ITEM"})
oTmpFPY:AddIndex("3", { "OK","XXY_PROJET","XXY_PEDVEN","XXY_ITEM"})


aStru := {}
// Segunda tabela produtos e maquinas atreladas ao item 

For nX := 1 to Len(aStru4)
	Aadd( aStru ,  FWSX3Util():GetFieldStruct( aStru4[nX,2] ) )
	aStru[ Len(aStru), 1] := aStru4[nX,1]
next

Aadd(aStru,{ "RECNOFQZ"         ,"N",10,0})
Aadd(aStru,{ "RECNOFPG"         ,"N",10,0})
Aadd(aStru,{ "TIPO"             ,"C",10,0})
Aadd(aStru,{ "DTPROXFAT"        ,"D", 8,0})


If oTmpFPZ <> Nil
	oTmpFPZ:Delete()
	oTmpFPZ := Nil
Endif

oTmpFPZ := FWTemporaryTable():New( GetNextAlias() )  
oTmpFPZ:SetFields(aStru) 	
oTmpFPZ:AddIndex("1", { "XXZ_PEDVEN","XXZ_ITEM"})

//------------------
//Criação das tabelas temporarias
//------------------

oTmpFPY:Create()
oTmpFPZ:Create()
cSIMFPY := Criavar("FPY_PEDVEN")

Return 


/*/ Protheus.doc} LOCA021BPZ
Grava os dados dos pedidos na tabela temporaria
@type function
@version 25.10 
@author Alexandre Circenis
@since 14/05/2026
@param cAliasFPZ, character, Alias do arquivo temporario 
@param aCab, array, Array com os dados do cabecalho do pedido
@param aItens, array, Array com os dados dos Itens do Pedido
/*/
Function LOCA021BPZ(cAliasFPY, cAliasFPZ, aSC5, aSC6 , aFPY, aFPZ, aDescCus)
Local aStru1 := CamposSC5()
Local aStru2 := CamposFPY()
Local aStru3 := CamposSC6()
Local aStru4 := CamposFPZ()
Local nX		:= 0
Local nY        := 0
Local nZ        := 0
Local nW        := 0
Local nPosItem
Local nPosCam
Local cDescCus
Local cEmail := "N"

DEFAULT aDescCus := {}

	cSIMFPY := Soma1( cSIMFPY )
	
	For nX:= 1 to Len(aSC6)

		// Grava o Cabeçalho
		RecLock(cAliasFPY, .T.)
		//prepara itens
		For nZ := 1 To Len(aSC6[nX])
			nPosCam := Ascan(aStru3, {|x| x[2] = aSC6[nX][nZ][1]})
			if nPosCam > 0
				(cAliasFPY)->(FieldPut( FieldPos(aStru3[nPosCam, 1]), aSC6[nX][nZ][2]))
			else
				(cAliasFPY)->(FieldPut( FieldPos(aStru3[nPosCam, 1]), Criavar(aSC6[nX][nZ][1])))
			endif
		next nZ

		For nY := 1 to Len(aSC5)
			nPosCam := Ascan(aStru1, {|x| x[2] = aSC5[nY][1]})
			if nPosCam > 0
				(cAliasFPY)->(FieldPut( FieldPos(aStru1[nPosCam, 1]), aSC5[ny][2]))
			else
				MsgStop("Não encontrado campo "+  aSC5[nY][1] )
			endif
		Next nY

		For nY := 1 to Len(aFPY)
			nPosCam := Ascan(aStru2, {|x| x[2] = aFPY[nY][1]})
			(cAliasFPY)->(FieldPut( FieldPos(aStru2[nPosCam, 1]), aFPY[ny][2]))
		Next nY

		(cAliasFPY)->XXY_PEDVEN := cSIMFPY

		// Frank em 27/08/2026
		// cPar27 = código do documento usado na simulação
		cEmail := "N"
		If type("cPar27") == "C"
			If !empty(cPar27)
				// FPB = documentos x projetos
				FPB->(dbSetOrder(1))
				FPB->(dbSeek(xFilial("FPB")+(cAliasFPY)->XXY_PROJET))
				While !FPB->(Eof()) .and. FPB->FPB_FILIAL+FPB->FPB_PROJET == xFilial("FPB")+(cAliasFPY)->XXY_PROJET
					If FPB->FPB_VALOBR == "1" .and. FPB->FPB_OBRA <> (cAliasFPY)->XXY_OBRA
						FPB->(dbSkip())
						Loop
					EndIf
					If FPB->FPB_CODIGO == cPar27
						cEmail := "S"
						Exit
					EndIf
					FPB->(dbSkip())
				EndDo
			EndIf
		EndIf
		(cAliasFPY)->XXY_EMAIL  := cEmail

		nPosItem := Ascan( aSC6[nX], {|x| x[1] = "C6_ITEM"})
		cItem := aSC6[nX, nPosItem, 2 ]
		cDescCus := ''
		for nZ := 1 to Len(aDescCus)
			if aDescCus[nZ , 3] = cItem
				if !Empty(cDescCus)
					cDescCus += ","
				endif
				cDescCus += Alltrim(Str( aDescCus[nZ, 1],10,0))
			endif
		next

		(cAliasFPY)->CUSTNEG := cDescCus

		(cAliasFPY)->(MsUnlock())

	Next nX

		For nZ := 1 To Len(aFPZ)
			RecLock(cAliasFPZ, .T.)
			for nW := 1 to Len(aFPZ[nZ])
				nPosCam := Ascan(aStru4, {|x| x[2] == aFPZ[nZ][nW][1]})
				if nPosCam <> 0
					(cAliasFPZ)->(FieldPut( FieldPos(aStru4[nPosCam, 1]), aFPZ[nZ][nW][2]))
				else
					(cAliasFPZ)->(FieldPut( FieldPos(aFPZ[nZ][nW][1]), aFPZ[nZ][nW][2]))
				endif
			next nW
			(cAliasFPZ)->XXZ_PEDVEN := cSIMFPY
			(cAliasFPZ)->(MsUnlock())
		Next nZ

	
Return

/*/ Protheus.doc} LOCA021BBR
Monta a tela de visualização da simulação
@type function
@version  25.10
@author Alexandre Circenis
@since 14/05/2026
@param oTmpFPZ, object, Objeto contendo a tabela temporaria
/*/
Function LOCA021BBR(oTmpFPY, oTmpFPZ, lSimSemTel)
Local aCoors  
Local oPanelUp, oFWLayer, oPanelDown, oRodape
Local oDlgPrinc
Local cAliasFPY := oTmpFPY:GetAlias()
Local cAliasFPZ := oTmpFPZ:GetAlias()
Local lConfMrkBr := .F.
Local bOk 			:= { ||( lConfMrkBr 	:= .T., oDlgPrinc:End() )}
Local bCancel		:= { ||( lConfMrkBr 	:= .F., oDlgPrinc:End() )}
Local aSeek         :={  { "PEDIDO" , {{"XXZ_PEDVEN","C",6,0,"Pedido",""   }}, 1,.T.} ,;
					     { "PROJETO", {{ "XXZ_PROJET","C",20,0,"Projeto",""}},2, .T.}}
Local lMarkFPY	:= .f.
						
	Private oBrowseSIM
	Private oBrowseDET
	Private oRelacFPY
	Private aCpMKB := LOCA021BHE(oTmpFPY:cTableName , "FPY" )
	Private cMarca := GetMark()

	Private nItensMark := 0
	Private nValorMark := 0
	Private nQtdMark   := 0
	Private nDesconto  := 0
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4

	If !lSimSemTel .and. !file("\SYSTEM\LOCA21BBR.TXT")
		aCoors  := FWGetDialogSize( oMainWnd )
		Define MsDialog oDlgPrinc Title STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel //'Gestão de Demandas' //"Simulação de Faturamento "
		//
		// Cria o conteiner onde serão colocados os browses
		//
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPrinc, .F., .T. )
		//
		// Define Painel Superior
		//
		oFWLayer:AddLine( 'UP', 45, .F. )                       // Cria uma "linha" com 50% da tela
		oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )            // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
		oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )         // Pego o objeto desse pedaço do container
		//
		// Painel Inferior
		//
		oFWLayer:AddLine( 'DOWN', 45, .F. )                     // Cria uma "linha" com 50% da tela
		oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'DOWN' )        // Na "linha" criada eu crio uma coluna com 50% da tamanho dela
		oPanelDown  := oFWLayer:GetColPanel( 'ALL' , 'DOWN' )  // Pego o objeto desse pedaço do container

		//
		// Painel Rodapé
		//
		oFWLayer:AddLine( 'RODAPE', 10, .F. )                     // Cria uma "linha" com 50% da tela
		oFWLayer:AddCollumn( 'ALL' ,  100, .T., 'RODAPE' )        // Na "linha" criada eu crio uma coluna com 50% da tamanho dela
		oRodape  := oFWLayer:GetColPanel( 'ALL' , 'RODAPE' )  // Pego o objeto desse pedaço do container

		@ 10,10  Say oSay1 VAR STR0002+": " + Transf(nItensMark,Tm(nItensMark,7,0)) OF oRodape PIXEL //"Qtd Itens"
		@ 10,150 Say oSay2 VAR STR0003+": " + Str(nQtdMark,15,2) OF oRodape PIXEL //"Quantidade Marcada"
		@ 10,300 Say oSay3 VAR STR0004+": " +Transf(nValorMark,Tm(nValorMark,15,2)) OF oRodape PIXEL //"Valor Marcado"
		@ 10,450 Say oSay4 VAR "Desconto "+": " +Transf(nDesconto,Tm(nDesconto,15,2)) OF oRodape PIXEL //"Valor Marcado"

		aRotina := {}

		oBrowseSIM := FWMarkBrowse():New()
		oBrowseSIM:SetTemporary(.T.)
		oBrowseSIM:SetOwner( oPanelUp )  
		oBrowseSIM:SetAlias(cAliasFPY)			// Alias da tabela utilizada
		oBrowseSIM:SetFields(aCpMKB)
		oBrowseSIM:SetFieldMark("OK")
		oBrowseSIM:SetMenuDef("")	// Nome do fonte onde esta a função MenuDef
		//aRotina := MenuDef() 
		oBrowseSIM:SetDescription(STR0001+Dtoc(dDatabase))	 //"Simulação de Faturamento "
		oBrowseSIM:SetCustomMarkRec( { || LOCA021BMY(oBrowseSIM, oBrowseDET)})
		oBrowseSIM:bAllMark := { || MsAguarde( { || MarkAllFPY(oBrowseSIM, oBrowseDET) ,oBrowseSIM:Refresh(.T.)}, STR0009+If( !lMarkFPY, STR0008,STR0007)+" ...")    } //"Desmarcando" //"Marcando" //"Aguarde "
		oBrowseSIM:AddButton(STR0005, bOk,, 4) //"Faturar"
		oBrowseSIM:AddButton(STR0006, bCancel,, 2) //"Cancelar" 

		if ExistBlock("LOCREXT2")
			oBrowseSIM:AddButton(STR0010, {|| Execblock("LOCREXT2", .f., .f., {oTmpFPY, oTmpFPZ, oBrowseSIM, 0})},, 2) //"Extrato de Locação"
		EndIf
		oBrowseSIM:AddButton(STR0033, {|| LOCA021B1(oTmpFPY, oTmpFPZ, oBrowseSIM, lSimSemTel)}) //"Envio por e-mail"
		
		oBrowseSIM:SetSeek(.T.,aSeek)
		oBrowseSIM:Activate()

		aCpMKB2 := LOCA021BHE(oTmpFPZ:cTableName , "FPZ" )
		oBrowseDET := FWmBrowse():New()
		oBrowseDET:SetTemporary(.T.)
		oBrowseDET:SetOwner( oPanelDown )  
		oBrowseDET:SetAlias(cAliasFPZ)			// Alias da tabela utilizada
		oBrowseDET:SetFields(aCpMKB2)
	//	oBrowseDET:SetFieldMark("OK")
		oBrowseDET:SetMenuDef("")	// Nome do fonte onde esta a função MenuDef
		//aRotina := MenuDef() 
		oBrowseDET:SetDescription("")	 //"Simulação de Faturamento "

	//	oBrowseDET:SetCustomMarkRec( { || LOCA021BMK(oBrowseDET, oBrowseSIM)})
	//	oBrowseDET:bAllMark := { || MsAguarde( { || MarkAllFPZ(oBrowseDET, lMarkFPZ := ! lMarkFPZ) ,oBrowseDET:Refresh(.T.)}, "Aguarde "+If( !lMarkFPZ, "Marcando","Desmarcando")+" ...")    }
		oBrowseDET:SetSeek(.T.,aSeek)
		oBrowseDET:Activate()

		//
		// Relacionamento entre os Browses
		//
		oRelacFPY:= FWBrwRelation():New()
		oRelacFPY:AddRelation( oBrowseSIM , oBrowseDET , { { 'XXZ_PEDVEN', 'XXY_PEDVEN' }, {'XXZ_ITEM', 'XXY_ITEM'}  } )
		oRelacFPY:Activate()


		Activate MsDialog oDlgPrinc Center

		if lConfMrkBr // Confirmou o faturamento.
			MSAGUARDE( {|| Loca021BGP(oBrowseSIM, oBrowseDET)}  , STR0011    , ; //"Aguarde..." //"Aguarde ..."
				STR0012 , .F. ) //"Gerando os pedidos para os itens selecionados"
		endif
	Else
		LOCA021B1(oTmpFPY, oTmpFPZ, oBrowseSIM, lSimSemTel)
	EndIf

	oTmpFPZ:Delete()
	oTmpFPZ := Nil

	oTmpFPY:Delete()
	oTmpFPY := Nil

Return


/*/{Protheus.doc} LOCA021BHE
Retorna a estrutura das colunas que serão apresentadas no browse
@type function
@version 25.10  
@author Alexandre Circenis
@since 20/05/2026
@param cFileName, character, Nome do arquivo temporario da simulação
@return variant,Array com a estrutura dos campos
/*/
function LOCA021BHE(cFileName, cTabela)

Local aColunas :=  {}
Local nX
Local aStru1 := CamposSC5()
Local aStru2 := CamposFPY()
Local aStru3 := CamposSC6()
Local aStru4 := CamposFPZ()
Local cTitulo := ""


if cTabela = "FPY"
	
	
	for nX := 1 to Len(aStru1)
		if FWSX3Util():SeekX3File(aStru1[nX,2])
			aAux := FWSX3Util():GetFieldStruct(aStru1[nX,2])
			cTitulo := X3Titulo()
			aAdd(aColunas, { cTitulo, aStru1[nX,1],  aAux[ 2 ], aAux[ 3 ], aAux[ 4 ],aAux[ 5 ]})
		endif	
	next

	for nX := 1 to Len(aStru2)
		if !(aStru2[nX, 2] $ "FPY_FILIAL FPY_TIPO") .and. FWSX3Util():SeekX3File(aStru2[nX,2])
			if aStru2[nX,2] = 'FPY_PEDVEN'
				cTitulo := STR0013 //"PV Simulado"
			else
				cTitulo := X3Titulo()
			endif
			aAux := FWSX3Util():GetFieldStruct(aStru2[nX,2])
			aAdd(aColunas, { cTitulo, aStru2[nX,1],  aAux[ 2 ], aAux[ 3 ], aAux[ 4 ],aAux[ 5 ]})
		endif	
	next 

	for nX := 1 to Len(aStru3)
		if !(aStru3[nX, 2] $ "C6_FILIAL C6_FROTA") .and. FWSX3Util():SeekX3File(aStru3[nX,2])
			aAux := FWSX3Util():GetFieldStruct(aStru3[nX,2])
			cTitulo := X3Titulo()
			aAdd(aColunas, { cTitulo, aStru3[nX,1],  aAux[ 2 ], aAux[ 3 ], aAux[ 4 ],aAux[ 5 ]})
		endif	
	next

	// Coluna de controle E-mail (campo XXY_EMAIL nao possui correspondente na SX3, e' gravado manualmente)
	aAdd(aColunas, { "Email", "XXY_EMAIL",  "C", 1, 0,"@!"}) 

elseif cTabela = "FPZ"

	for nX := 1 to Len(aStru4)
		if FWSX3Util():SeekX3File(aStru4[nX,2])
			aAux := FWSX3Util():GetFieldStruct(aStru4[nX,2])
			if aStru4[nX,2] = 'FPZ_PEDVEN'
				cTitulo := STR0013 //"PV Simulado"
			elseif aStru4[nx,2] = "FPZ_ITMFPZ"
				cTitulo := STR0014 //"Sub Item"
			else
				cTitulo := X3Titulo()
			endif
			aAdd(aColunas, { cTitulo, aStru4[nX,1],  aAux[ 2 ], aAux[ 3 ], aAux[ 4 ],aAux[ 5 ]})
		endif	
	next
	aAdd(aColunas, { STR0015, "DTPROXFAT",  "D", 8, 0,"@!"}) //"Prox. Faturamento"
	aAdd(aColunas, { STR0016, "TIPO",  "C", 10, 0,"@!"}) //"Tipo Registro" //"TIPO"
endif

Return aColunas

/*/{Protheus.doc} CamposSC5
Retorna os campos da SC5 usados na geração dos pedidos
@type function
@version 25.10 
@author Alexandre Circenis
@since 20/05/2026
@return variant, Array com a estrutura dos campos da SC5
/*/
Static Function CamposSC5()
Local aCampoSC5 := {}
Local cCmpUsr 		:= SuperGetMv("MV_CMPUSR",.F.,"")

	AADD(aCampoSC5 ,{"XXY_TIPO" , "C5_TIPO"}    )                   
	AADD(aCampoSC5 ,{"XXY_CLIENT",  "C5_CLIENTE"} )               
	AADD(aCampoSC5 ,{"XXY_LOJA"  , "C5_LOJACLI" })		         
	AADD(aCampoSC5 ,{"XXY_TABELA",  "C5_TABELA" })       
	AADD(aCampoSC5 ,{ "XXY_CONDPA", "C5_CONDPAG" })               
	AADD(aCampoSC5 ,{ "XXY_VEND1", "C5_VEND1"  } )       
	IF FP0->(FIELDPOS("FP0_VENDE2")) > 0
		AADD(aCampoSC5 , { "XXY_VEND2", "C5_VEND2"  } )   
	EndIf
	IF FP0->(FIELDPOS("FP0_VENDE3")) > 0
		AADD(aCampoSC5 ,  { "XXY_VEND3", "C5_VEND3"  } )   
	EndIf
	IF FP0->(FIELDPOS("FP0_VENDE4")) > 0
		AADD(aCampoSC5 ,  { "XXY_VEND4", "C5_VEND4" }  )   
	EndIf
	IF FP0->(FIELDPOS("FP0_VENDE5")) > 0
		AADD(aCampoSC5 ,  { "XXY_VEND5", "C5_VEND5" }  )   
	EndIf
	AADD(aCampoSC5 ,  { "XXY_PESOL","C5_PESOL"  } )                
	AADD(aCampoSC5 ,  { "XXY_PBRUTO","C5_PBRUTO" } )                
	AADD(aCampoSC5 ,  { "XXY_SEGURO","C5_SEGURO" } )              
	AADD(aCampoSC5 ,  { "XXY_NATURE","C5_NATUREZ"} )             
	AADD(aCampoSC5 ,  { "XXY_MOEDA","C5_MOEDA"  } ) 
	AADD(aCampoSC5 ,  { "XXY_ORIGEM","C5_ORIGEM"  } )   
	if cPaisLoc <> "BRA" // todos os paises menos o Brasil
		AADD(aCampoSC5 ,  { "XXY_DOCGER", "C5_DOCGER"  } )
		if cPaisLoc = "MEX" .and.  FP1->(FIELDPOS("FP1_USOCFD")) > 0 // Campos para o mexico
			AADD(aCampoSC5 ,  { "XXY_USOCFD", "C5_USOCFDI" } ) 
		endif
	endif
	AADD(aCampoSC5, { "XXY_FRETE", "C5_FRETE"})
	If !Empty(cCmpUsr) .And. SC5->(FieldPos(cCmpUsr)) > 0
		AADD(aCampoSC5, { "XXY_MENNOT", cCmpUsr})
	else
		AADD(aCampoSC5, { "XXY_MENNOT", "C5_MENNOTA"})	
	endif

Return aCampoSC5

/*/{Protheus.doc} CamposFPY
Retorna os campos da FPY usados na geração dos pedidos
@type function
@version 25.10 
@author Alexandre Circenis
@since 20/05/2026
@return variant, Array com a estrutura dos campos da FPY
/*/
Static Function CamposFPY
Local aCampoFPY := {}

	Aadd(aCampoFPY, { "XXY_FILIAL","FPY_FILIAL" })
	Aadd(aCampoFPY, { "XXY_PEDVEN","FPY_PEDVEN" })
	Aadd(aCampoFPY, { "XXY_PROJET","FPY_PROJET"})
	Aadd(aCampoFPY, { "XXY_TIPFAT","FPY_TIPFAT"})  
	Aadd(aCampoFPY, { "XXY_STATUS","FPY_STATUS "}) //1=Pedido Ativo;2=Pedido Cancelado
	If FPY->(FieldPos("FPY_OBRA")) > 0
		Aadd(aCampoFPY, { "XXY_OBRA", "FPY_OBRA"})
	endif

Return aCampoFPY

/*/{Protheus.doc} CamposSC6
Retorna os campos da SC6 usados na geração dos pedidos
@type function
@version 25.10 
@author Alexandre Circenis
@since 20/05/2026
@return variant, Array com a estrutura dos campos da SC6
/*/
Static Function CamposSC6
Local aCampoSC6 := {}

	AADD(aCampoSC6 ,{ "XXY_FILIAL", "C6_FILIAL" }) 
	AADD(aCampoSC6 ,{ "XXY_ITEM"  , "C6_ITEM"   }) 
	AADD(aCampoSC6 ,{ "XXY_PRODUT", "C6_PRODUTO"})  
	AADD(aCampoSC6 ,{ "XXY_DESCRI", "C6_DESCRI" })
	AADD(aCampoSC6 ,{ "XXY_QTDVEN", "C6_QTDVEN" })
	AADD(aCampoSC6 ,{ "XXY_QTDLIB", "C6_QTDLIB" }) 
	AADD(aCampoSC6 ,{ "XXY_PRCVEN", "C6_PRCVEN" })
	AADD(aCampoSC6 ,{ "XXY_PRUNIT", "C6_PRUNIT" })
	AADD(aCampoSC6 ,{ "XXY_VALOR" , "C6_VALOR"  }) 
	AADD(aCampoSC6 ,{ "XXY_LOCAL" ,"C6_LOCAL"	})   
	IF SC6->(FIELDPOS("C6_FROTA")) > 0
		AADD(aCampoSC6 ,{ "XXY_FROTA", "C6_FROTA" } )  
	ENDIF
	AADD(aCampoSC6 ,{ "XXY_LOCALI" ,"C6_LOCALIZ"})
	IF SC6->(FIELDPOS("C6_NUMSERI")) > 0
		AADD(aCampoSC6 ,{ "XXY_NUMSER", "C6_NUMSERI"} )
	ENDIF
	AADD(aCampoSC6 , { "XXY_TES"   ,"C6_TES"    } )
	AADD(aCampoSC6 , { "XXY_CC"    ,"C6_CC"     } )
	AADD(aCampoSC6 , { "XXY_CLVL"  ,"C6_CLVL"   } )
	AADD(aCampoSC6 , { "XXY_VALDES","C6_VALDESC"} )

Return aCampoSC6

/*/{Protheus.doc} CamposFPZ
Retorna os campos da FPZ usados na geração dos pedidos
@type function
@version 25.10 
@author Alexandre Circenis
@since 20/05/2026
@return variant, Array com a estrutura dos campos da FPZ
/*/
Static Function CamposFPZ()
Local aCampoFPZ := {}
lClaVal := .T.

	Aadd(aCampoFPZ, { "XXZ_FILIAL" , "FPZ_FILIAL" })
	Aadd(aCampoFPZ, { "XXZ_PROJET" , "FPZ_PROJET" })
	Aadd(aCampoFPZ, { "XXZ_OBRA" , "FPZ_OBRA"   })
	Aadd(aCampoFPZ, { "XXZ_PEDVEN" , "FPZ_PEDVEN" })
	Aadd(aCampoFPZ, { "XXZ_ITEM" , "FPZ_ITEM"	  })
	Aadd(aCampoFPZ, { "XXZ_ITMFPZ" , "FPZ_ITMFPZ" })
	Aadd(aCampoFPZ, { "XXZ_AS" , "FPZ_AS"	  })
	Aadd(aCampoFPZ, { "XXZ_PROD" , "FPZ_PROD"   })
    Aadd(aCampoFPZ, { "XXZ_FROTA" , "FPZ_FROTA"  })
	Aadd(aCampoFPZ, { "XXZ_QUANT" , "FPZ_QUANT"  })
	Aadd(aCampoFPZ, { "XXZ_VALUNI" , "FPZ_VALUNI" })
	Aadd(aCampoFPZ, { "XXZ_TOTAL" , "FPZ_TOTAL"  })
	Aadd(aCampoFPZ, { "XXZ_DTPED" , "FPZ_DTPED"  })
	Aadd(aCampoFPZ, { "XXZ_DTINI" , "FPZ_DTINI"  })
	Aadd(aCampoFPZ, { "XXZ_DTFIM" , "FPZ_DTFIM"  })
   	Aadd(aCampoFPZ, { "XXZ_PRVFAT" , "FPZ_PRVFAT" })
	Aadd(aCampoFPZ, { "XXZ_EXTRA" , "FPZ_EXTRA"  })
	Aadd(aCampoFPZ, { "XXZ_PERLOC" , "FPZ_PERLOC" })
	Aadd(aCampoFPZ, { "XXZ_CCUSTO" , "FPZ_CCUSTO" })
	Aadd(aCampoFPZ, { "XXZ_GERAEM" , "FPZ_GERAEM" })
	Aadd(aCampoFPZ, { "XXZ_VIAGEM" , "FPZ_VIAGEM" })
	Aadd(aCampoFPZ, { "XXZ_DIAS"   , "FPZ_DIAS"   })
	Aadd(aCampoFPZ, { "XXZ_CLVL"   , "FPZ_CLVL"   })
	Aadd(aCampoFPZ, { "XXZ_TES"    , "FPZ_TES"    })
	Aadd(aCampoFPZ, { "XXZ_ORIGEM" , "FPZ_ORIGEM" })
	Aadd(aCampoFPZ, { "XXZ_PRXFAT" , "FPZ_PRXFAT" })
	Aadd(aCampoFPZ, { "XXZ_PERINI" , "FPZ_PERINI" })
	Aadd(aCampoFPZ, { "XXZ_PERFIM" , "FPZ_PERFIM" })
	Aadd(aCampoFPZ, { "XXZ_ULTFAT" , "FPZ_ULTFAT" })
	Aadd(aCampoFPZ, { "XXZ_LOCDIA" , "FPZ_LOCDIA" })
	Aadd(aCampoFPZ, { "XXZ_GERAAT" , "FPZ_GERAAT" })
	if FPZ->(FieldPos("FPZ_IDPO")) > 0
		Aadd(aCampoFPZ, { "XXZ_IDPO"   , "FPZ_IDPO"   })
		Aadd(aCampoFPZ, { "XXZ_DPTCLI" , "FPZ_DPTCLI" })
	endif

Return aCampoFPZ
/*/{Protheus.doc} Loca021BGP
Com base nos itens selecinados na tabels de simulação grava os pedidos de venda e as notas para o faturamento.
As notas só serão geradas se o parametro MV_LOCX049 estaiver configurado ou o campo da FP0 assimm indicar
@type function
@version 25.10
@author Alexandre Circenis
@since 18/08/2026
@param oMrkMaster, object, Objeto da tabela principal da Simulação
@param oMrkDet, object, Objeto da tabela de itens da FPZ gerados na simulação
@return variant, REtorno .T. se a geração dos pedidos e notas foi realizaso com sucesso
/*/
Function Loca021BGP( oMrkMaster , oMrkDet )
Local cAliasFPY := oMrkMaster:Alias()
Local cAliasFPZ := oMrkDet:Alias()
Local cMark :=  oMrkMaster:Mark()
Local cPedido := Criavar("C6_NUM", .F.)
Local cItem   := Criavar("C6_ITEM", .F.)
Local ACABPV := {}
Local aItensPv := {}
Local aAGlurat  := {} 
Local aFPY := {}
Local aFPZ := {}
Local nPosAgluRat := 0 // Posicao do grupo de rateio do item corrente em aAgluRat (0 = ainda nao criado)
Local nItemAglu   := 0 // Sequencial do item de rateio (AGG_ITEM) dentro do grupo do item corrente
Local aItemAGG    := {} // Estrutura de um item de rateio (AGG_ITEM/AGG_PERC/AGG_CC/AGG_CLVL/AGG_CONTA/AGG_ITEMCT)
Local aCamposSC5 := CamposSC5()
Local aCamposFPY := CamposFPY()
Local aCamposSC6 := CamposSC6()
Local aCamposFPZ := CamposFPZ()
Local aTempSC6   := {}
Local aTempFPZ   := {}
Local lFatura    := .T.	
// Pontos de Entrada
Local lLCX049    := ExistBlock("LOCA2149")
Local lLcjatFPG	 := EXISTBLOCK("LCJATFPG")
Local lLoca061Z  := EXISTBLOCK("LOCA061Z")
Local lLcjaFim   := EXISTBLOCK("LCJATFIM")
Local lLcjatZAG  := EXISTBLOCK("LCJATZAG")
Local cProjeto
Local aCustos    := {}
Local aProRata   := {}
Local cItemAux
// Parametros 
Local lMVLOCX278 	:= SuperGetMv("MV_LOCX278",,.T.)
Local lMVLOCX049 := SuperGetMv("MV_LOCX049"  ,.F.,.T.)
Local lMVLOCX243 := SUPERGETMV("MV_LOCX243",.F.,.F.)
Local lAglutinar := .F.

Local cItemFPZ :=  Criavar("FPZ_ITMFPZ")
Local nX
Local nY
Local cLocx299 		:= GetMV("MV_LOCX299",,"")
Local aAS := {} // Array com as AS que geraram cobrança
Local nRegPr := 0
Local lRegra049 := .T.
Local nValTot   := 0
Local nAgluTot  := 0
Local nPosPv    := 0
Local nPosPerc  := 0

Private  lmsErroAuto

	(cAliasFPY)->( dbSetOrder(3) )
    (cAliasFPY)->( dbSeek(cMark))

	While !( cAliasFPY )->( Eof() ) .and. ( cAliasFPY)->OK == cMark
		
		if ( cAliasFPY )->XXY_PEDVEN <> cPedido // Novo pedido criar SC5 e FPY
			aItensPv := {}
			aAGlurat  := {} 
			aFPY := {}
			aFPZ := {}
			lFatContra := .F.

			FP0->(dbSeek( xFilial("FP0")+( cAliasFPY )->XXY_PROJET))
			lAglutinar := FP0->(FieldPos("FP0_AGLUNF")) > 0 .And. FP0->FP0_AGLUNF == "1"

			For nX := 1 to Len(aCamposSC5)
				if !EmpTy((cAliasFPY)->(FieldGet(FieldPos(aCamposSC5[nX,1]))))
					Aadd( aCabPv, {aCamposSC5[nX,2], (cAliasFPY)->(FieldGet(FieldPos(aCamposSC5[nX,1]))), NIL})
				endif
			Next

			For nX := 1 to Len(aCamposFPY)
				if !Empty((cAliasFPY)->(FieldGet(FieldPos(aCamposFPY[nX, 1]))))
					Aadd( aFPY, {aCamposFPY[nX,2], (cAliasFPY)->(FieldGet(FieldPos(aCamposFPY[nX,1]))), NIL})
					
				endif
			Next

			cProjeto := (cAliasFPY)->XXY_PROJET
			cPedido := ( cAliasFPY )->XXY_PEDVEN
			lFatura := lMVLOCX049
			// Verificar se vamos usar o campo da FP0 para informar se gera pedido e nota ou só pedido
			FP0->(dbSetOrder(1))
			FP0->(dbSeek(xFilial("FP0")+ cProjeto))
			if FP0->(FieldPos("FP0_GERFAT")) > 0
				lFatura := If(FP0->FP0_GERFAT = '1', .F., If(FP0->FP0_GERFAT = '2', .T., lMVLOCX049 ))
			endif
			// Laço para os itens do Pedido
			cItem   := CriaVar("C6_ITEM")
			while !( cAliasFPY )->( Eof() ) .and. ( cAliasFPY)->OK == cMark .and. ( cAliasFPY )->XXY_PEDVEN == cPedido

				aTempSC6 := {}
				aTempFPZ := {}
				cItem := Soma1(cItem)

				// Reinicia o grupo de rateio (aAgluRat) para o novo item do pedido - o grupo
				// e criado sob demanda no laco da FPZ abaixo, no primeiro registro de origem.
				nPosAgluRat := 0
				nItemAglu   := 0

				For nX := 1 to Len(aCamposSC6)
					if !Empty((cAliasFPY)->(FieldGet(FieldPos(aCamposSC6[nX,1])))) .and. aCamposSC6[nX,1] <> "XXY_PEDVEN"
						if aCamposSC6[NX,2] == "C6_ITEM"
							Aadd( aTempSC6, { "C6_ITEM", cItem , NIL})
						else
							Aadd( aTempSC6, {aCamposSC6[nX,2], (cAliasFPY)->(FieldGet(FieldPos(aCamposSC6[nX,1]))), NIL})
							if aCamposSC6[nX, 2] = 'C6_VALOR'
								nValTot += (cAliasFPY)->(FieldGet(FieldPos(aCamposSC6[nX,1])))
							endif
						endif	
					endif

				Next
				Aadd( aItensPv , aClone(aTempSC6))

				// Processar FPZ 

				// Laço para os itens da FPZ 
				cItemAux := (cAliasFPY)->XXY_ITEM
				cItemFPZ :=  Criavar("FPZ_ITMFPZ",.F.)
				( cAliasFPZ )->(dbSeek( cPedido + cItemAux))

				while !( cAliasFPZ )->( Eof() ) .and. ( cAliasFPZ )->XXZ_PEDVEN == cPedido .and. (cAliasFPZ)->XXZ_ITEM == cItemAux
					cItemFPZ := Soma1(cItemFPZ)
					aTempFPZ := {}
					For nX := 1 to Len(aCamposFPZ)
						if !Empty((cAliasFPZ)->(FieldGet(FieldPos(aCamposFPZ[nX,1]))))
							if aCamposFPZ[NX,2] == "FPZ_ITEM"
								Aadd( aTempFPZ, { "FPZ_ITEM", cItem , NIL})
							elseif  aCamposFPZ[NX, 2] == "FPZ_ITMFPZ"
								Aadd( aTempFPZ, { "FPZ_ITMFPZ", cItemFPZ , NIL})
							else
								Aadd( aTempFPZ, {aCamposFPZ[nX,2], (cAliasFPZ)->(FieldGet(FieldPos(aCamposFPZ[nX,1]))), NIL})
							endif
						endif
					Next
					Aadd( aFPZ , aClone(aTempFPZ))

					// Monta o item de rateio (aItemAGG) para esta origem FPZ e agrupa em aAgluRat.
					// Os itens do pedido ja chegam agrupados da simulacao (LOCA021BTR/LOCA021BPZ),
					// entao aqui so precisamos empilhar as origens dentro do grupo do item corrente -
					// sem repetir a logica de decidir "novo produto x soma no existente" do LOCA021.
					if lAGlutinar 
						nItemAglu++
						aItemAGG := {}
						Aadd(aItemAGG, {"AGG_ITEM"   , StrZero(nItemAglu,2)   , NIL})
						Aadd(aItemAGG, {"AGG_PERC"   , (cAliasFPZ)->XXZ_TOTAL , NIL}) // valor; normalizado para % mais abaixo, antes do MATA410
						Aadd(aItemAGG, {"AGG_CC"     , (cAliasFPZ)->XXZ_CCUSTO, NIL})
						Aadd(aItemAGG, {"AGG_CLVL"   , (cAliasFPZ)->XXZ_CLVL  , NIL})
						Aadd(aItemAGG, {"AGG_CONTA"  , ""                     , NIL})
						Aadd(aItemAGG, {"AGG_ITEMCT" , ""                     , NIL})
						If nPosAgluRat == 0
							Aadd(aAgluRat, { cItem , {aClone(aItemAGG)} })
							nPosAgluRat := Len(aAgluRat)
						Else
							Aadd(aAgluRat[nPosAgluRat][2], aClone(aItemAGG))
						EndIf
					endif

					if (cAliasFPZ)->RECNOFPG > 0
						aAdd( aCustos, { (cAliasFPZ)->RECNOFPG , ""       , cItem} )
					endif
					if (cAliasFPZ)->RECNOFQZ > 0
						aAdd(aProRata, (cAliasFPZ)->RECNOFQZ)
					endif
		
					if (cAliasFPZ)->XXZ_ORIGEM = '1' // Só vai atualizar quando recorrente
						if AScan( aAS, { |x| x[2] = (cAliasFPZ)->XXZ_AS  }) = 0
							AADD( aAS , { (cAliasFPZ)->XXZ_PROJET , (cAliasFPZ)->XXZ_AS , (cAliasFPZ)->XXZ_DTFIM , " " , cItem ,;
								(cAliasFPZ)->XXZ_DTFIM ,  (cAliasFPZ)->DTPROXFAT , (cAliasFPZ)->XXZ_GERAEM } )
						endif
					endif
				
					( cAliasFPZ)->(DbSkip() )

				enddo

				( cAliasFPY )->(dbSkip())
			enddo

		endif // Finalizou os itens marcadados do Pedido
		// Gerar o Pedido  

		IF Len(aItensPv) > 0

			lmsErroAuto := .F.
			// Sprint 3 - Frank Z Fuga - EAI - 04/10/22
			If !empty(cLocx299)
				SetRotInteg("MATA410")
			EndIf

			// Se Houver Aglutinção processar o array antes de gravar
			If Len(aAgluRat) > 0
				nAgluTot := 0
				//pega posição dos campos
				nPosPv 		:= aScan(aAgluRat[1][2][1],{|x| AllTrim(x[1])=="AGG_ITEM"})
				nPosPerc 	:= aScan(aAgluRat[1][2][1],{|x| AllTrim(x[1])=="AGG_PERC"})
				//soma total dos itens
				For nY := 1 To Len(aAgluRat)
					nAgluTot := 0
					For nX := 1 To Len(aAgluRat[nY][2])
						//nAgluTot += aAgluRat[nY][2][nx][nPosPerc][2]
						nAgluTot += aAgluRat[nY][2][nx][nPosPerc][2]
					Next nX

					For nX := 1 To Len(aAgluRat[nY][2])
						//aAgluRat[nY][2][nx][nPosPerc][2] 	:= (aAgluRat[nY][2][nx][nPosPerc][2] / nAgluTot) * 100 // atualiza proporção
						aAgluRat[nY][2][nx][nPosPerc][2] 	:= (aAgluRat[nY][2][nx][nPosPerc][2] / nAgluTot) * 100 // atualiza proporção
					 //	aAgluRat[nY][2][nx][nPosPv][2] 	:=  StrZero(nX,2)										// atualiza item
					Next nX

				Next nY

				//exectua rotina automática
				//MSEXECAUTO({|X,Y,Z,,,,,W| MATA410(X,Y,Z,,,,,W)} , aCabPv , aItensPv , 3 , , , , , aAgluRat)
				//pega retorno
				If len(aCabPv) > 0 .and. len(aItensPv) > 0
					MSEXECAUTO({|X,Y,Z,W| MATA410(X,Y,Z,,,,,W)} , aCabPv , aItensPv , 3, aAGlurat)
				EndIf
			else
				If len(aCabPv) > 0 .and. len(aItensPv) > 0
					MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , aCabPv , aItensPv , 3)
				EndIF
			endif

			If len(aCabPv) > 0 .and. len(aItensPv) > 0

				IF lmsErroAuto

					MOSTRAERRO()
					ROLLBACKSXE()
								
						
				ELSE
					CONFIRMSX8()
					_NVLRFRETE := 0
					_NVLRSEG   := 0
					nRegPr++

					AADD( APEDIDOS , SC5->C5_NUM )

					//17/08/2022 - Jose Eulalio - SIGALOC94-321 - FAT - Usar tabela complementar (FPY) para pedidos de vendas
					//Grava Tabela de Pedido de Venda x Locação
					
					// Alimentar os arrays com o pedido gerado Frank 18/09/23
					aFPY[2,2] := SC5->C5_NUM
					For nY := 1 to len(aFPZ)
						aFPZ[nY,4,2] := SC5->C5_NUM
					Next
					LOCA0822(aFPY,aFPZ, .F.) // Atualiza as tabelas auxiliares e não é remessa
					aFPZ := {}

					IF lLCX049    // PONTO DE ENTRADA PARA REGRA ESPECÍFICA AO UTILIZAR MV_LOCX049
					    lRegra049 := EXECBLOCK("LOCA2149" , .F. , .F. ,{lRegra049,SC5->C5_NUM} ) 
					ENDIF   

					// Geramos fatura somente para o Pais Brasil
					IF lFatura .and. cPaisLoc == "BRA" .and. lRegra049
						aNota := LOCA21GRNT(SC5->C5_NUM)
					ENDIF

					If Len(aCustos) > 0
						For nY := 1 to len( aCustos)

							FPG->(dbGoto(aCustos[nY,1]))
							IF lLcjatFPG//EXISTBLOCK("LCJATFPG")
								EXECBLOCK("LCJATFPG" , .T. , .T. , {})
							ELSE
								_cSeq := FPG->FPG_SEQ 
								If empty(_cSeq )
									_cSeq := GetSx8Num("FPG","FPG_SEQ")
									ConfirmSx8()
								EndIf
								FPG->(RecLock("FPG",.F.))
								FPG->FPG_SEQ := _cSeq
								FPG->FPG_STATUS := "2"
								//FPG->FPG_PVNUM  := _CNUMPED Removido por Frank em 18/09/23
								FPG->FPG_PVNUM  := SC5->C5_NUM
								FPG->FPG_PVITEM :=  aCustos[nY][03]
								FPG->(MsUnlock())
						
							EndIF
							//Copia o Banco de Conhecimento do Custo Extra para o Pedido de Venda (LOCA007.PRW)
							LC007BCOPV(SC5->C5_FILIAL,FPG->FPG_PVNUM)

						Next
						aCustos := {}
					EndIF

					If Len(aProRata) > 0 
						FOR nY := 1 TO LEN(aProRata)
							FQZ->(DBGOTO(aProRata[nY]))

							FPA->(dbSetOrder(3))
							If FPA->(dbSeek(xFilial("FPA")+FQZ->FQZ_AS))

								FQZ->(RECLOCK("FQZ",.F.))
								FQZ->FQZ_PV := SC5->C5_NUM
								FQZ->(MSUNLOCK())
									
							EndIf
						NEXT
						aProRata := {}
					EndIf

					DBSELECTAREA("FPA")
					FOR nY := 1 TO LEN(aAS)
						aAS[nY,4] := SC5->C5_NUM
						FPA->(DBSETORDER(6))
						IF FPA->(DBSEEK(XFILIAL("FPA") + aAS[nY][1] + aAS[nY][2]))
							IF lLcjatZAG //EXISTBLOCK("LCJATZAG") 				// --> PONTO DE ENTRADA APÓS A ALTERAÇÃO DE CADA ITEM DA ZAG.
								EXECBLOCK("LCJATZAG" , .T. , .T. , {})
							ELSE
								IF RECLOCK("FPA",.F.)
									// Issue: 9116 - Frank - 11/12/25
									If empty(FPA->FPA_ULTFAT)
										FPY->(dbSetOrder(1))
										If FPY->(dbSeek(xFilial("FPY")+SC5->C5_NUM))
											If FPY->(fieldpos("XXY_DIAORI")) > 0
												FPY->(RecLock("FPY",.F.))
												FPY->FPY_DIAORI := FPA->FPA_LOCDIA
												FPY->(MsUnlock())
											EndIf
										EndIf
									EndIF
									FPA->FPA_ULTFAT := aAS[nY][6]
									FPA->FPA_DTFIM  := aAS[nY][7]
									If FPZ->(FIELDPOS("FPZ_GERAEM")) > 0 .and. FPA->(FIELDPOS("FPA_GERAEM")) > 0
										FPA->FPA_GERAEM := aAS[nY][8]
									EndIf
									// Issue: 9116 - Frank - 11/12/25
									If !empty(FPA->FPA_DTFIM) .and. !empty(FPA->FPA_ULTFAT)
										FPA->FPA_LOCDIA := FPA->FPA_DTFIM - FPA->FPA_ULTFAT
									EndIF
									// DSERLOCA-10880 - Captura valores atualizados antes do unlock para uso no bloco FQZ
									dFpaUltFat := FPA->FPA_ULTFAT
									nFpaLocDia := FPA->FPA_LOCDIA
									FPA->(MSUNLOCK())
								ENDIF

								// DSERLOCA-10880 - Atualiza campos FQZ na Situação A após cada ciclo de locação faturado
								// FQZ com FQZ_RETIRA > FPA_DTFIM (retorno futuro) devem ter ULTFAT, PERPRO e VLRPRO
								// recalculados a cada PV gerado, reduzindo progressivamente até entrar na Situação B (pro-rata)
								// Filtros obrigatórios: FQZ_PV = '' e FQZ_MSBLQL = '2' (mesmo critério do LOCA021DV)
								cQryFQZAt  := ""
								aBindFQZAt := {}
								nLocDiaAt  := If(FP1->FP1_TPMES == "1", If(nFpaLocDia == 0, 1, nFpaLocDia), 30)

								cQryFQZAt += " SELECT FQZ.R_E_C_N_O_ REG"
								cQryFQZAt += " FROM " + RETSQLNAME("FQZ") + " FQZ"
								cQryFQZAt += " WHERE FQZ.FQZ_FILIAL  = '" + XFILIAL("FQZ") + "'"
								cQryFQZAt += "   AND FQZ.FQZ_AS      = ?"
								aadd(aBindFQZAt, FPA->FPA_AS)
								cQryFQZAt += "   AND FQZ.FQZ_PROJET  = ?"
								aadd(aBindFQZAt, FPA->FPA_PROJET)
								cQryFQZAt += "   AND FQZ.FQZ_RETIRA  > ?"
								aadd(aBindFQZAt, DTOS(dFpaUltFat))
								cQryFQZAt += "   AND FQZ.FQZ_PV      = ''"
								cQryFQZAt += "   AND FQZ.FQZ_MSBLQL  = '2'"
								cQryFQZAt += "   AND FQZ.D_E_L_E_T_  = ' '"

								cQryFQZAt := CHANGEQUERY(cQryFQZAt)
								LOCACLOSE("TRBFQZAT")
								MPSysOpenQuery(cQryFQZAt, "TRBFQZAT",,, aBindFQZAt)

								While !TRBFQZAT->(Eof())
									FQZ->(DBGOTO(TRBFQZAT->REG))
									FQZ->(RECLOCK("FQZ", .F.))
										FQZ->FQZ_ULTFAT := dFpaUltFat
										FQZ->FQZ_PERPRO := FQZ->FQZ_RETIRA - dFpaUltFat
										FQZ->FQZ_VLRPRO := ROUND((FQZ->FQZ_VLRTOT * FQZ->FQZ_PERPRO) / nLocDiaAt, GETSX3CACHE("C6_VALOR","X3_DECIMAL"))
									FQZ->(MSUNLOCK())
									TRBFQZAT->(DBSKIP())
								EndDo

								TRBFQZAT->(DBCLOSEAREA())

							ENDIF
						ENDIF

						// DSERLOCA-6564 - Frank em 04/07/2025
						// Tratamento da geração do título provisório pelo campo FP0_PROV
						If FP0->(FieldPos("FP0_PROV")) > 0
							If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
								lMVLOCX278 := .T.
							Else
								lMVLOCX278 := .F.
							EndIf
						EndIf

						If lMVLOCX278 //.and. !lSimula //supergetmv("MV_LOCX278",,.T.)
							DELTITPR(FPA->FPA_AS, FPA->FPA_PROJET)
						EndIf

						IF lMVLOCX243 //SUPERGETMV("MV_LOCX243",.F.,.F.)
							LOCA062(SC5->C5_FILIAL , aAS[nY][4] , aAS[nY][5] , FPA->FPA_FILIAL , aAS[nY][1] , aAS[nY][2])
						ENDIF
					NEXT nY

					IF lLcjaFim//EXISTBLOCK("LCJATFIM")
						EXECBLOCK("LCJATFIM" , .T. , .T. , NIL)
					ENDIF

				EndIF
			EndIf
		endif

		IF len(aItensPv) > 0 .and. cPAR20 == 1 // Frank 13/11/24//_NREG > 0 .and. !lGeraPVx
			IF lLoca061Z//EXISTBLOCK("LOCA061Z")
				For nY := 1 to len(aCustos)
					aCustos[nY,2] := SC5->C5_NUM
				Next
				EXECBLOCK("LOCA061Z" , .T. , .T. , {aCabPv,aItensPv,aCustos,lGeraPVx})
			EndIF
		ENDIF

		IF LCLIBLQ .and. cPAR20 == 1 // Frank 13/11/24
			SA1->( DBGOTO(NSA1RECNO) )
			IF RECLOCK("SA1", .F.)
				SA1->A1_MSBLQL := "1"
				SA1->(MSUNLOCK())
			ENDIF
		ENDIF

	EndDo

	IF nRegPr > 0 
		CMSG := STR0025+ALLTRIM(STR(nRegPr))+ " " + CRLF // //"TOTAL DE REGISTROS PROCESSADOS: "
		ASORT(APEDIDOS,,,{|X,Y| X < Y })
		IF LEN(APEDIDOS) > 0

			If lLOC21Auto
				For nX := 1 to len(aPedidos)
					nValor := 0
					SC6->(dbSetOrder(1))
					SC6->(dbSeek(xFilial("SC6")+aPedidos[nX]))
					cNotAuto := ""
					cSerAuto := ""
					cPerAuto := ""
					While !SC6->(Eof()) .and. SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6") + aPedidos[nX]
						nValor += SC6->C6_VALOR
						cNotAuto := SC6->C6_NOTA
						cSerAuto := SC6->C6_SERIE
						cPerAuto := ""

						If !lMvLocBac
							cPerAuto := SC6->C6_XPERLOC
						Else
							FPY->(dbSetOrder(1))
							If FPY->(dbSeek(xFilial("FPY")+SC6->C6_NUM))
								FPZ->(dbSetOrder(1))
								If FPZ->(dbSeek(xFilial("FPZ")+SC6->C6_NUM+FPY->FPY_PROJET+SC6->C6_ITEM))
									cPerAuto := FPZ->FPZ_PERLOC
								EndIf
							EndIf
						EndIf

						SC6->(dbSkip())
					EndDo
					aadd(aRetExec,{aPedidos[nX],nValor,cNotAuto,cSerAuto,cPerAuto})
				Next
			EndIF

			CMSG += STR0027 + APEDIDOS[1] + STR0026+APEDIDOS[ LEN(APEDIDOS) ] + " "+ CRLF  //" - ULTIMO PEDIDO: " //"PRIMEIRO PEDIDO: "
		EndIF
		If cPar20 == 1
			CMSG += STR0028+ ALLTRIM(STR(LEN(APEDIDOS))) + CRLF  //"TOTAL DE PEDIDOS GERADOS: "
			CMSG += STR0029+ ALLTRIM( TRANSFORM(NVALTOT,"@E 999,999,999,999.99") )  //"VALOR: "
		ENDIF

		If len(aPedidos) > 0
			AVISO(STR0030 , CMSG , {"OK"} , 2)  //STR0030 //"PROCESSAMENTO EXECUTADO COM SUCESSO!"
		EndIf
		lRet := .T.
	ELSE
	
		if len(aPedidos) == 0 
			MSGSTOP(STR0032 , STR0031)  //###"GPO - LCJLF001.PRW" //"Faturamento Automatico" //"NÃO EXISTEM REGISTROS PARA PROCESSAMENTO!"
		endif
			
		lRet := .F.
	
	ENDIF

Return lRet

/*/{Protheus.doc} LOCA021BMY
Função utlizada para atualizar a interface quando ocorrer a marcação ou desmarcação de itens
@type function
@version 25.10
@author Alexandre Circenis
@since 18/08/2026
@param oMrkBrowse, object, Objeto da tabela principal
@param oBrowseDET, object, Objeto da tabela secundaria
@return variant, Retorna sempre .t. para indicar que foi marcado
/*/
STATIC FUNCTION LOCA021BMY(oMrkBrowse, oBrowseDET)
Local aAreaAtu	:= GetArea()

	
	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->OK  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
	//	oMrkBrowse:Refresh()
		nItensMark++
		nQtdMark += Loca021BQt( oBrowseDET )
		nValorMark +=  (oMrkBrowse:Alias())->XXY_VALOR
		nDesconto += (oMrkBrowse:Alias())->XXY_VALDES
	else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->OK  := "  "
		(oMrkBrowse:Alias())->(MsUnLock())
	//	oMrkBrowse:Refresh()
		nItensMark--
		nQtdMark -= Loca021BQt( oBrowseDET )
		nValorMark -=  (oMrkBrowse:Alias())->XXY_VALOR
		nDesconto -= (oMrkBrowse:Alias())->XXY_VALDES
	endif

	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
	oSay4:Refresh()
	
	RestArea( aAreaAtu )

Return( .T. )
/*/{Protheus.doc} MarkAllFPY
Realiza a marcação de todos os itens que estiverem desmarcados e vice-versa
@type function
@version 25.10
@author Alexandre Circenis
@since 18/08/2026
@param oMrkBrowse, object, Objeto da tabela principal
@param oBrowseDET, object, Objeto da tabela de itens
@return variant, Retorna sempre .t. para indicar que foi realizado com sucesso
/*/
STATIC FUNCTION MarkAllFPY(oMrkBrowse, oBrowseDET )
Local nLoopRec := 0

	oMrkBrowse:GoTop(.T.)
	Eval(oMrkBrowse:oBrowse:bChange)
	while .T.
		if nLoopRec = oMrkBrowse:At()
			Exit 
		endif
		LOCA021BMY(oMrkBrowse, oBrowseDET)
		nLoopRec := oMrkBrowse:At()
		oMrkBrowse:GoDown()
		Eval(oMrkBrowse:oBrowse:bChange)
	enddo
	oMrkBrowse:GoTop(.T.)
	Eval(oMrkBrowse:oBrowse:bChange)
	oMrkBrowse:Refresh(.T.)
	oBrowseDET:Refresh(.T.)
	
Return .T.
/*/{Protheus.doc} Loca021BQt
Retorna a soma de todas as quantidades dos itens associados ao item principal marcado/desmarcado
@type function
@version 25.10
@author Alexandre Circenis
@since 18/08/2026
@param oBrowseDET, object, Objeto da tabela de itens
@return variant, Retorna o total da soma das quantidades dos itens relativos a linha marcada
/*/
Static Function Loca021BQt( oBrowseDET )
Local nQtde := 0
Local nLoopRec := 0

	oBrowseDET:Gotop()
	while .T.
		if nLoopRec = oBrowseDET:At()
			Exit 
		endif
		nQtde += (oBrowseDET:Alias())->XXZ_QUANT
		nLoopRec := oBrowseDET:At()
		oBrowseDET:GoDown()
		
	EndDo

	oBrowseDET:GoTop(.T.)
	oBrowseDET:Refresh()

Return nQtde


/*/{Protheus.doc} LOCA021B1
Envio do relatório por PDF.
@type function
@version V1 
@author Frank Zwarg Fuga
@since 27/08/2026
/*/
Function LOCA021B1(oTmpFPY, oTmpFPZ, oBrowseSIM, lSimSemTel)
Local aArea := GetArea()
	If !lSimSemTel
		Processa({|| LOCA021B1P(oTmpFPY, oTmpFPZ, oBrowseSIM, lSimSemTel) },STR0040) // "Aguarde... Enviando os e-mails"
	Else
		LOCA021B1P(oTmpFPY, oTmpFPZ, oBrowseSIM, lSimSemTel)
	EndIf
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} LOCA021B1P
Envio do relatório por PDF.
@type function
@version V1 
@author Frank Zwarg Fuga
@since 27/08/2026
/*/
Function LOCA021B1P(oTmpFPY, oTmpFPZ, oBrowseSIM, lSimSemTel)
Local cFuncao := ""
Local cAliasFPY := oTmpFPY:GetAlias()
Local cMark 
Local aArea := GetArea()
Local aEmail := {}
Local nX
Local lProcessa := .F.
Local cProjeto
Local cObra
Local aAnexos := {}
Local aLog := {}

	If !lSimSemTel
		cMark := oBrowseSIM:Mark()
		ProcRegua(0)
	EndIf

	If FindFunction( "LOCA224B1" ) .and. FindFunction( "LOCA086E1" ) 
        If LOCA224B1("FH8_ID", "FH8")
			lProcessa := .T.
		EndIF
	EndIf

	If lProcessa
		If type("cPar27") == "C"
			If !empty(cPar27)
				(cAliasFPY)->(dbGotop())
				While !( cAliasFPY )->( Eof() ) .and. If(!lSimSemTel, ( cAliasFPY)->OK == cMark, .T.)
					If !lSimSemTel
						IncProc()
						SysRefresh()
					EndIf
					cFuncao := ""
					aEmail := {}
					If (cAliasFPY)->XXY_EMAIL == "S"
						FPB->(dbSetOrder(1))
						FPB->(dbSeek(xFilial("FPB")+(cAliasFPY)->XXY_PROJET))
						While !FPB->(Eof()) .and. FPB->FPB_FILIAL+FPB->FPB_PROJET == xFilial("FPB")+(cAliasFPY)->XXY_PROJET
							If FPB->FPB_VALOBR == "1" .and. FPB->FPB_OBRA <> (cAliasFPY)->XXY_OBRA
								FPB->(dbSkip())
								Loop
							EndIf
							If FPB->FPB_CODIGO == cPar27
								FPC->(dbSetOrder(1))
								FPC->(dbSeek(xFilial("FPC")+FPB->FPB_CODIGO))
								cFuncao := FPC->FPC_PROG
								aadd(aEmail,{cFuncao,FPB->FPB_EMAIL})
							EndIf
							FPB->(dbSkip())
						EndDo
					EndIf
					For nX := 1 to len(aEmail)
						cFuncao := alltrim(aEmail[nX,1])
						If !empty(cFuncao)
							If ExistBlock(cFuncao)
								cRet := Execblock(cFuncao, .f., .f., {oTmpFPY, oTmpFPZ, oBrowseSIM, (cAliasFPY)->(recno()) })
								If type("cRet") == "C"
									If File(cRet)

										aLog := {}

										cProjeto := (cAliasFPY)->XXY_PROJET
										cObra    := (cAliasFPY)->XXY_OBRA
										FP0->(dbSetOrder(1))
										FP0->(dbSeek(xFilial("FP0")+cProjeto+cObra))
										SA1->(dbSetOrder(1))
										SA1->(dbSeek(xFilial("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))
					
										/* aLog
										1 - Reservado
										2 - Código do cliente
										3 - Loja do cliente
										4 - Projeto
										5 - Obra
										6 - Data da geração
										7 - Hora da geração
										8 - Código do usuário
										9 - e-Mail
										10 - Origem
										11 - Doc
										12 - Descrição
										13 - Rastreio
										*/

										aadd(aLog,"")
										aadd(aLog,SA1->A1_COD)
										aadd(aLog,SA1->A1_LOJA)
										aadd(aLog,FP0->FP0_PROJET)
										aadd(aLog,FP1->FP1_OBRA)
										aadd(aLog,dDataBase)
										aadd(aLog,time())
										aadd(aLog,RetCodUsr())
										aadd(aLog,alltrim(aEmail[nX,2]))
										aadd(aLog,"LOCA021")
										aadd(aLog,cPar27)

										cDescr := STR0034+": LOCA021" + Chr(13) + Chr(10) //"Faturamento - Simulação"
										cDescr += STR0035+cProjeto + Chr(13) + Chr(10) //"Projeto: "
										cDescr += STR0036+cObra + Chr(13) + Chr(10) //"Obra: "
										cDescr += STR0037+SA1->A1_COD + Chr(13) + Chr(10) //"Código do cliente: "
										cDescr += STR0038+SA1->A1_LOJA + Chr(13) + Chr(10) // "Código da loja: "          

										aadd(aLog,cDescr)

										cRastreio := STR0034+": LOCA021" + Chr(13) + Chr(10) //"Faturamento - Simulação"
										cRastreio += STR0035+cProjeto + Chr(13) + Chr(10) //"Projeto: "
										cRastreio += STR0036+cObra + Chr(13) + Chr(10) //"Obra: "
										cRastreio += STR0037+SA1->A1_COD + Chr(13) + Chr(10) //"Código do cliente: "
										cRastreio += STR0038+SA1->A1_LOJA + Chr(13) + Chr(10) // "Código da loja: "          

										aadd(aLog,cRastreio)

										aAnexos := {}
										aadd(aAnexos, cRet)

										LOCA086E1(aLog, .T., .T., "", aEmail[nX,2], STR0039, STR0039+" - "+cProjeto, aAnexos) //"Reajuste do faturamento automático - Simulação"

									EndIf
								EndIf
							EndIf					
						EndIf
					Next
					(cAliasFPY)->(dbSkip())
				EndDo
			EndIF
		EndIf
	EndIF
	RestArea(aArea)
Return .T.

