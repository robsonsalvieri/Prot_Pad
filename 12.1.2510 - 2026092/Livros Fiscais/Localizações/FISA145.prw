#INCLUDE "FISA145.ch"   
#INCLUDE "Protheus.ch"   
#INCLUDE "TopConn.ch"

#DEFINE _ZONAFIS "FO"
#DEFINE _IMPPER "IBB"
#DEFINE _IMPRET "IBR"


/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA145  ³ Autor ³ DANILO SANTOS       ³ Data ³ 25.08.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcionalidad requerida por la RG 72/20 –                  ³±±
±±³Formosa - Padrón de Retenciones, Percepciones y Riesgo Fiscales.       ³±± 
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Uso       ³ Fiscal - Formosa- Argentina                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   

Function FISA145()

Local   aCombo := {}
Local	 aTipo:= {}
Local   oDlg   := Nil
Local   oFld   := Nil
Local   cDelimit:=Space(1)
Local   lReg:= SFH->(ColumnPos("FH_REGIMEN") > 0)
Private cMes   := StrZero(Month(dDataBase),2)
Private cAno   := StrZero(Year(dDataBase),4)
Private cTipo := ""
Private lRet   := .T.
Private lPer   := .T.
Private dDatIni := CTOD("  /  /  ") 
Private dDatFim := CTOD("  /  /  ") 

aAdd( aTipo, STR0002 ) //Percepiciones
aAdd( aTipo, STR0003 ) //Retenciones
aAdd( aTipo, STR0004 ) //Ambos


    IF lReg==.F.
	  Help(" ",1,STR0039,,STR0040, 2, 0,,,,,,{STR0041}) //STR0039-PADRON FOMOSA STR0040-"Es necesario crear el campo 'FH_REGIMEN'"   STR0041-Verificar que se cuente con campo FH_REGIMEN y valores.
	  Return .F.
	ENDIF
	

		DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //RN 18-2018 – Ciudad de Córdoba - Padrón Riesgo Fiscal
		
		@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"
		@ 011,010 SAY STR0017 SIZE 065,008 PIXEL OF oFld //"Arquivo :"
		@ 020,010 COMBOBOX oCombo VAR cTipo ITEMS aTipo SIZE 65,8 PIXEL OF oFld //ON CHANGE ValidChk(cCombo)
		@ 022,080 SAY STR0027 SIZE 150,008 PIXEL OF oFld //"Delimitador:"
		@ 020,114 MSGET cDelimit Picture "@!" VALID !Empty(cDelimit)   SIZE 024,008 PIXEL OF oFld
		//+----------------------   
		//| Campos Check-Up
		//+----------------------
		@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importação de Arquivo CSV"
		
		//+----------------
		//| Campos Folder 2
		//+----------------
		@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opcao tem como objetivo atualizar o cadastro    "
		@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Fornecedor / Cliente                                 "
		@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"disponibilizado pelo governo                         "
		@ 045,005 SAY STR0015 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe o periodo:"
		@ 045,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
		@ 045,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
		@ 045,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]
		
		//+-------------------
		//| Boton de MSDialog
		//+-------------------
		@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpArq(aCombo,cTipo,cDelimit,"") //"&Importar"
		@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Sair"

		ACTIVATE MSDIALOG oDlg CENTER


	

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpArq   ³ Autor ³ Danilo Santos       ³ Data ³ 25.08.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa a importacao do arquivo.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar01 - Variavel com as opcoes do combo cliente/fornec.   ³±±
±±³          ³ cPar01 - Variavel com a opcao escolhida do combo.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Formosa Argentina                                 ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/{Protheus.doc} ImpArq
	funcion utilizada en la automatizacion de la FISA145
	@type  void
	@author Danilo Santos
	@since 25/08/2021
	@version version 1
	@param aCombo,caracter,opciones ("1- Proveedor","2- Cliente","3- Ambos" )
	@param cTipo,caracter,indica la opcion escogisa del combo ("1- Proveedor","2- Cliente","3- Ambos" )
	@param cDelimit,caracter, delimitador del txt
	@param cFileAut,caracter, nombre de archivo se informa cuando viene desde un auto con advpr
	@return nil, nil, no retorna nada
/*/
Static Function ImpArq(aCombo,cTipo,cDelimit,cFileAut)

Local lRet	 	:= .F.
Local cPesq	  := "\"
Local cfinal  := ""
Local aGeratmp:={}
Local cRG7220:=""
Local cLog:=""
Local oTmpLog:=Nil

Private  cFile    := ""

Private lCli     := .F.
Private	cStartPath := GetSrvProfString("StartPath","")
Private lCuitSM0 := .F.
Private lAutomato := isblind()
Private oTmpTable	:= Nil	// Arquivo temporario para importacao

Default aCombo := {}
Default cTipo := ""
Default cDelimit:=","
DEFAULT cFileAut:=""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporario a partir do XLS importado ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// Seleciona o arquivo
IF !lAutomato
	cFile := FGetFile()
	If Empty(cFile)
		MsgStop(STR0023) //"Seleccione un archivo e intente nuevamente."
		Return Nil
	EndIf
else
	cFile:=cFileAut
EndIf

If !lAutomato
	// Seleciona o arquivo
	cStartPath := StrTran(cStartPath,"/","\")
	cStartPath +=If(Right(cStartPath,1)=="\","","\")
	cfinal:= cFile
	If !Empty(cFile) 	
		If ! cFile $ cStartPath
			If ":" $ cFile
				CpyT2S(cFile,cStartPath,.T.)
			Endif
		EndIf
	EndIF
Endif
If !File(cFile)
	Return Nil
EndIf

If !lAutomato		
	If !Substr(cFile,1,6) $ cStartPath
		While AT( cPesq, cfinal) > 0  		
			Naux:=AT( cPesq, cfinal ) 
			Naux:=Naux+1
			nTamArq:= Len(cfinal)
			cfinal:= SubStr(cfinal,Naux,nTamArq)		
		EndDo
	Endif
Endif

IF !lAutomato
	// Cria e alimenta a tabela temporaria 
	Processa({|| aGeratmp := GeraTemp(@oTmpTable,cFile,cStartPath,cfinal,cDelimit)})
Else
	// Cria e alimenta a tabela temporaria 
	Processa({|| aGeratmp := GeraTemp(@oTmpTable,cFile,cStartPath,"",cDelimit)})
Endif
IF len(aGeratmp)>0

	lRet:= aGeratmp[1]
	cRG7220:= aGeratmp[2]

Endif



If lRet
    dDatIni := CTOD("01/"+cMes+"/"+cAno) 
    dDatFim := LastDay(dDatIni) 

	cLog:=fGeraLog(@oTmpLog)
	If Substr(cTipo,1,1) $ "1|3" // Cliente/Fornecedor - Percepção Ambos.
		
		//³Processo de valiadacao para Clientes³
		Processa({|| fPerCliFor("SA1",cRG7220,cLog)})
		
		
			//³Processo de valiadacao para Fornecedores³
		Processa({|| fPerCliFor("SA2",cRG7220,cLog)})
		
	Endif
	If SubStr(cTipo,1,1) $ "2|3"  //Fornecedor - Retenção
		
		//³Processo de valiadacao para Fornecedores ³
		Processa({|| fRetFor("SA2",cRG7220,cLog)})
	EndIf


	Msginfo(STR0019)

	If Substr(cTipo,1,1) $ "1|3"
		FISR145(cLog)
	ENDIF

	oTmpTable:Delete()
	oTmpLog:Delete()
	If !lAutomato
		FERASE(cStartPath+cfinal)
	Endif
Endif	
Return Nil

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetFile ³  Autor ³ Danilo Santos      ³ Data ³ 25.08.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de seleção do arquivo CSV a ser importado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Diretorio e arquivo selecionado.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Formosa Argentina - MSSQL                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetFile()

	Local cRet := Space(50)
	
	oDlg01 := MSDialog():New(000,000,100,500,STR0020,,,,,,,,,.T.)//"Selecionar arquivo"
	
		oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
		oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDir(oGet01)},oDlg01,STR0020,,.T.)//"Selecionar arquivo"
		
		oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
		oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)

Return cRet

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGetDir  ³ Autor ³ Danilo Santos       ³ Data ³ 25.08.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela para procurar e selecionar o arquivo nos diretorios   ³±±
±±³          ³ locais/servidor/unidades mapeadas.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oPar1 - Objeto TGet que ira receber o local e o arquivo    ³±±
±±³          ³         selecionado.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - Formosa Argentina - MSSQL                         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FGetDir(oTGet)

	Local cDir := ""
	
	cDir := cGetFile(,STR0020,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³GeraTemp ³ Autor ³ Danilo Santos             ³ Data ³ 25.08.2021 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Gera arquivo temporario a partir do XLS importado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³GeraTemp(ExpC1)                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico FISA145                                               ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/          
Static Function GeraTemp(oTmpTable,cFile,cStartPath,cfinal,cDelimit)
Local aInforma   := {} 									// Array auxiliar com as informacoes da linha lida no arquivo XLS
Local aCampos    := {}         							// Array auxiliar para criacao do arquivo temporario
Local cArqProc   := cFile									// Arquivo a ser importado selecionado na tela de Wizard
Local cTitulo    := STR0008								// "Problemas na Importação de Arquivo"
Local cErro	     := ""   								// Texto de mensagem de erro ocorrido na validacao do arquivo a ser importado
Local cSolucao   := ""           						// Texto de solucao proposta em relacao a algum erro ocorrido na validacao do arquivo a ser importado
Local cLinha     := ""									// Informacao lida para cada linha do arquivo XLS
Local lArqValido := .T.                               	// Determina se o arquivo XLS esta ok para importacao
Local nInd       := 0                   				// Indexadora de laco For/Next
Local nHandle    := 0            						// Numero de referencia atribuido na abertura do arquivo XLS
Local nTam       := 0 									// Tamanho de buffer do arquivo XLS 

Local aOrdem := {"CUIT"}
Local cRG7220:= GetNextAlias()

Default oTmpTable  := Nil
Default cFile      := ""
Default cStartPath := ""
Default cfinal     := ""
DEFAULT cDelimit:= ","

lRet := .T. // Determina a continuidade do processamento como base nas informacoes da tela de Wizard 						

If !lAutomato
	FT_FUSE(cStartPath + cfinal)
Else		
	FT_FUSE(cFile)
Endif	
nUltArq:= FT_FLASTREC()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria o arquivo temporario para a importacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************Modelo do arquivo*************
//CUIT|DENOMINACIÓN|CATEGORÍA|CATEGORÍA DESCRIPCIÓN|ALÍCUOTA RETENCIÓN|ALÍCUOTA PERCEPCIÓN|RÉGIMEN|FECHA EXCLUSIÓN RETENCIÓN|FECHA EXCLUSIÓN PERCEPCIÓN|EXENTO

AADD(aCampos,{"CUIT"	      		,"C",FWSX3Util():GetFieldStruct("A2_CGC")[3],0}) //CUIT 1 //
AADD(aCampos,{"DENOM"         		,"C",80,0})    //DENOMINACIÓN 2
AADD(aCampos,{"PERIO"         		,"C",6,0})     //PERIODO ejemplo 202301 3 // no se usa en el proceso
AADD(aCampos,{"CATE"         		,"C",20,0})    //CATEGORÍA 4
AADD(aCampos,{"CATE_DESC"   		,"C",18,0})    //CATEGORÍA DESCRIPCIÓN 5
AADD(aCampos,{"ALI_R_2897"      ,"C",05,0})    //ALÍCUOTA RETENCIÓN RG 28-97 6
AADD(aCampos,{"ALI_P_2314"      ,"C",05,0})    //ALÍCUOTA PERCEPCIÓN RG 2314 7
AADD(aCampos,{"FERET_2897"        ,"C",10,0})    //FECHA EXCLUSIÓN RETENCIÓN RG28-97 8
AADD(aCampos,{"FEPER_2314" 	    ,"C",10,0})    //FECHA EXCLUSIÓN PERCEPCIÓN RG 23-14 9
AADD(aCampos,{"ALI_P_3399"     ,"C",05,0})    //ALÍCUOTA PERCEPCIÓN RG 33-99 10
AADD(aCampos,{"ALI_P_2700"     ,"C",05,0})    //ALÍCUOTA PERCEPCIÓN RG 27-00 11
AADD(aCampos,{"FEPER_3399"        ,"C",10,0})    //FECHA EXCLUSIÓN PERCEPCIÓN  RG 33- 99 12
AADD(aCampos,{"FEPER_2700"	    ,"C",10,0})    //FECHA EXCLUSIÓN PERCEPCIÓN  RG 27- 00 113
AADD(aCampos,{"REGIMEN"             ,"C",80,0})    //RÉGIMEN 14
AADD(aCampos,{"EXENTO"              ,"C",02,0})    //EXENTO  15


oTmpTable := FWTemporaryTable():New(cRG7220,aCampos )
oTmpTable:AddIndex( "I1", aOrdem )
oTmpTable:Create()


If !lAutomato
	cArqProc := cStartPath + cfinal
Endif	

If File(cArqProc) .And. lRet
	nHandle	:= FOpen(cArqProc) 
	If nHandle > 0 
		nTam := FSeek(nHandle,0,2)  
		FSeek(nHandle,0,0)
		FT_FUse(cArqProc)
		FT_FGotop()
	Else
		lArqValido := .F.	
		cErro	   := STR0009 + cArqProc	//"Não foi possível efetuar a abertura do arquivo: "
		cSolucao  := STR0010 			//"Verifique se foi informado o arquivo correto para importação"
	EndIf
	If lArqValido 
		ProcRegua(nTam)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gera arquivo temporario a partir do arquivo XLS ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (!FT_FEof())          
			cLinha   := FT_FREADLN()
			IncProc()
			aInforma := {} 			
   			If !("CUIT" $ cLinha) .And.  !("Cuit" $ cLinha)
   				If !(cDelimit $ cLinha)
					Help(" ",1,STR0039,,STR0042, 2, 0,,,,,,{STR0043}) //  //STR0039-PADRON FOMOSA STR0040-"Es necesario crear el campo 'FH_REGIMEN'"  STR0042 // STR0042 "No existe coincidencias con el delimitador" // STR0043 "Revisar delimitador del archivo"
					Return (aInforma) // regresa un arreglo vacio para evitar que truene la validación superior
				EndIf

				For nInd := 1 to 15
					nPos := at(cDelimit,cLinha)
					If nPos > 0
						AADD (aInforma,Alltrim(SubStr(cLinha,1,(nPos-1))))
					Else
						AADD (aInforma,Alltrim(cLinha))
					Endif	
					cLinha := SubStr(cLinha,nPos+1,Len(cLinha))
				Next
				If len(aInforma)>=15
				    RecLock(cRG7220,.T.)
					cCuit := SM0->M0_CGC
					(cRG7220)->CUIT		:= STRTRAN(aInforma[1],"", "")
					If Alltrim((cRG7220)->CUIT) $ SM0->M0_CGC
						lCuitSM0 := .T.
					Endif 				
					(cRG7220)->DENOM		   := Alltrim(aInforma[2])
					(cRG7220)->PERIO		   := Alltrim(aInforma[3])
					(cRG7220)->CATE		       := aInforma[4]
					(cRG7220)->CATE_DESC       := aInforma[5]
					(cRG7220)->ALI_R_2897      := Alltrim(aInforma[6])
					(cRG7220)->ALI_P_2314      := Alltrim(aInforma[7])
					(cRG7220)->FERET_2897      := Alltrim(aInforma[8])
					(cRG7220)->FEPER_2314      := Alltrim(aInforma[9])
					(cRG7220)->ALI_P_3399      := Alltrim(aInforma[10])
					(cRG7220)->ALI_P_2700      := Alltrim(aInforma[11])
					(cRG7220)->FEPER_3399      := Alltrim(aInforma[12])
					(cRG7220)->FEPER_2700      := Alltrim(aInforma[13])
					(cRG7220)->REGIMEN         := Alltrim(aInforma[14])
					(cRG7220)->EXENTO          := Alltrim(aInforma[15])
					MsUnLock()	
				ENDIF
				
			Endif
			FT_FSkip()
		Enddo
	Endif	

	FT_FUse()
	FClose(nHandle)

	If Empty(cErro) .and. (cRG7220)->(LastRec())==0     
		cErro		:= STR0011	//"A importação não foi realizada por não existirem informações no arquivo texto informado."
		cSolucao	:= STR0012	//"Verifique se foi informado o arquivo correto para importação"
	Endif
	
Else

	cErro	 := STR0013+CHR(13)+cArqProc	//"O arquivo informado para importação não foi encontrado: "
	cSolucao := STR0014 		   			//"Informe o diretório e o nome do arquivo corretamente e processe a rotina novamente."

EndIf
	 
If !Empty(cErro)

	xMagHelpFis(cTitulo,cErro,cSolucao)

	lRet := .F.
	
Endif

Return({lRet,cRG7220})

/*/{Protheus.doc} FIS145AUT
	funcion utilizada en la automatizacion de la FISA145
	@type  void
	@author Danilo Santos
	@since 30/08/2021
	@version version 1
	@param cArchivo,caracter,ruta del padron a cargar.
	@param cCombo,caracter,indica si es cliente proveedor o ambos("1- Proveedor","2- Cliente","3- Ambos" )
	@param cDelimit,caracter, delimitador del txt
	@return nil, nil, no retorna nada
/*/
	
Function FIS145AUT(cArchivo,cCombo,cDelimit)
	Local cFileAut:=cArchivo
	Local aCombo:={}

	DEFAULT cArchivo:=""
	DEFAULT cCombo:=""
	DEFAULT cDelimit:=","

	aAdd( aCombo, "1- Proveedor" ) //"1- Fornecedor"
	aAdd( aCombo, "2- Cliente" ) //"2- Cliente"
	aAdd( aCombo, "3- Ambos" ) //"3- Ambos"

	IF FILE(cArchivo)
		ImpArq(aCombo,cCombo,cDelimit,cFileAut)
	EndIf
Return nil

/*
*/

/*/{Protheus.doc} MayorFech
//busca el registro de mayor vigencia en SFH
@author adrian.perez
@param cCod,caracter,codigo de cliente-proveedor
@param cLoja,caracter, tienda
@param cImpuesto,caracter, impuesto
@param cZonaFis,caracter,zona fiscal
@param cAlias,caracter,indica que tabla fue usada SA1-Clientes o SA2-Percepción
@return nAux, numerico, número de registro(recno)  de la SFH de mayor vigencia
/*/

Static Function MayorFech(cCod,cLoja,cImpuesto,cZonaFis,cAlias)

	Local dFecAnt := ""
	Local nAux :=0
	Local cTabla :=""
	Local nAuxIni :=0

	DEFAULT cCod:=""
	DEFAULT cLoja:=""
	DEFAULT cImpuesto:=""
	DEFAULT cZonaFis:=""
	DEFAULT cAlias:=""
		
	Iif(cAlias=="SA1",cTabla:="FH_CLIENTE",cTabla:="FH_FORNECE")
	cQuery	:= ""
	cQuery := "SELECT  FH_FIMVIGE AS FECHA,R_E_C_N_O_ AS NUM,FH_INIVIGE AS INI"
	cQuery += " FROM " + RetSqlName("SFH") 
	cQuery += " WHERE FH_FILIAL = '" + xFilial("SFH") + "'"
	cQuery += " AND "+cTabla+" = '"+cCod+"'"
	cQuery += " AND FH_LOJA ='"+cLoja+"'"
	cQuery += " AND FH_IMPOSTO ='"+cImpuesto+"'"
	cQuery += " AND FH_ZONFIS ='"+cZonaFis+"'"
	cQuery += " AND D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), "cTMayor", .T., .T.)

	cTMayor->(dbGoTop())
	Do While cTMayor->(!EOF()) 
		If cTMayor->FECHA > dFecAnt
			nAux := cTMayor->NUM
			dFecAnt := cTMayor->FECHA
		EndIf
		
		If(DTOS(dDatIni) == cTMayor->INI)
			nAuxIni :=cTMayor->NUM
		EndIf
		cTMayor->(dbSkip())
	EndDo
	If(nAuxIni<>0)
		nAux :=nAuxIni
	EndIf
	cTMayor->(dbCloseArea())

Return nAux

/*/{Protheus.doc} fSFHPer
//reglas para percepción IIB
@author adrian.perez
@param nOrd, numerico, indice usado para filtrar
@param cCod,caracter,codigo de cliente-proveedor
@param cLoja,caracter, tienda
@param cAlias,caracter,indica que tabla fue usada SA1-Clientes o SA2-Percepción
@param lExistTXT,logico, indica si existe en el padron(TX)
@param cRG7220, caracter, nombre de la tabla temporal padron
@param cLog, caracter, nombre de la tabla temporal log
@param cAuxCuit, caracter, cuit que viene desde SA1-Clientes o SA2-Percepción, usado en caso de no estar en TXT O SFH
@param cAuxNom, caracter, nombre que viene desde SA1-Clientes o SA2-Percepción, usado en caso de no estar en TXT O SFH
@return nil
/*/
Static Function fSFHPer(nOrd,cCod,cLoja,cAlias,lExistTXT,cRG7220,cLog,cAuxCuit,cAuxNom)
Local aArea    := GetArea()	
Local nRecFim:=0
Local cChave:=""
Local cAuxCateg :=""
Local cSFHReg:=""
Local lReg:= SFH->(ColumnPos("FH_REGIMEN") > 0)
Local aCampos:={} 
Local cTipo:=""
Local cExento:="S"
Local cForClie:= ""
Local nPorcent:=0

DEFAULT nOrd:=0
DEFAULT cCod:=""
DEFAULT cLoja:=""
DEFAULT	cAlias:=""
DEFAULT lExistTXT:=.F.
DEFAULT cRG7220:=""
DEFAULT cLog:=""
DEFAULT cAuxCuit:=""
DEFAULT cAuxNom:=""

	cChave := xFilial("SFH")+cCod+cLoja+_IMPPER+_ZONAFIS
	dbSelectArea("SFH")
	SFH->(dbSetOrder(nOrd))
	SFH->(dbGoTop())


	IF  lReg //existe campo FH_REGIMEN
	    IF nOrd==3
		   cForClie:="Cli" //Cliente
		ELSE
		   cForClie:="Pro" //Proveedor
		EndIF
		IF lExistTXT //esta en TXT(Padron)
			If SFH->(MsSeek(cChave)) 

				nRecFim :=  MayorFech(cCod,cLoja,_IMPPER,_ZONAFIS,cAlias)

				SFH->(DbGoTo(nRecFim))
				cSFHReg:=ALLTRIM(SFH->FH_REGIMEN)

				IF cSFHReg!=""
					aCampos:=cChekRG(cSFHReg) //columnas de alicuota y fecha de percepción se obtienen de acuerdo a lo informado en FH_REGIMEN
					cAuxCateg := IIf(ALLTRIM((cRG7220)->CATE) $ "A|B","2","1")

					/* Valores de REGIMEN(Columna 14)
					-	CONVENIO MULTILATERAL
					-	ORGANISMO PÚBLICO
					-	PRODUCTORES DEL PAIPPA
					-	RÉGIMEN GENERAL

					*/
					IF ALLTRIM((cRG7220)->REGIMEN) $  ALLTRIM("CONVENIO MULTILATERAL")
						cTipo:="V"
					ELSEIF (ALLTRIM((cRG7220)->REGIMEN) $  ALLTRIM("RÉGIMEN GENERAL")) .OR. (ALLTRIM((cRG7220)->REGIMEN) $  ALLTRIM("REGIMEN GENERAL"))
						cTipo:="I"
					ELSE
					   cTipo:=""
					ENDIF

					//- cib_exento=Si “EXENTO”=SI ? cib_exento=”E”; sino cib_exento=”N”
					IF ALLTRIM((cRG7220)->EXENTO) =="NO"
						cExento:="N"
					ENDIF

					If dDatIni  <= SFH->FH_FIMVIGE 
						SFH->(dbCloseArea())
						RestArea(aArea)
						return nil
					ElseIf ( (dDatIni  == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == VAL((cRG7220)->&(aCampos[1])) ) .AND.(SFH->FH_SITUACA== cAuxCateg) .AND. (SFH->FH_TIPO==cTipo) )
						Reclock("SFH",.F.) 
						SFH->FH_FIMVIGE := dDatFim
						MsUnLock()	
					Else
							IF ALLTRIM(((cRG7220)->&(aCampos[2])))!=""
								nPorcent:=100
							ENDIF
							fSFHCrea(SFH->FH_AGENTE,cCOD,SFH->FH_NOME,cTipo,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,cAuxCateg,VAL((cRG7220)->&(aCampos[1])) ,dDatIni,dDatFim,nPorcent,cExento,cAlias,SFH->FH_REGIMEN)
					EndIf

				ELSE // no esta lleno(FH_REGIMEN)
					fGravaLog(cLog,cAuxCuit,cCOD+"-"+cLoja,SFH->FH_NOME,cForClie,STR0028)	 //STR0028-Registro  encontrado, sin clasificación en SFH
				ENDIF // Fin SI esta lleno FH_REGIMEN
				
			ELSE // no encontro SFH
			  fGravaLog(cLog,cAuxCuit,cCOD+"-"+cLoja,cAuxNom,cForClie,STR0029)	 //STR0029-Registro en TXT pero no en SFH
			EndIf
		ELSE // No esta en TXT(Padron)
			//---------
				If SFH->(MsSeek(cChave)) 

					nRecFim :=  MayorFech(cCod,cLoja,_IMPPER,_ZONAFIS,cAlias)

					SFH->(DbGoTo(nRecFim))
					cSFHReg:=ALLTRIM(SFH->FH_REGIMEN)

					IF cSFHReg!=""
						

						If dDatIni  <= SFH->FH_FIMVIGE 
							 SFH->(dbCloseArea())
							 RestArea(aArea)
							 return nil
						ElseIf (dDatIni > SFH->FH_FIMVIGE) .AND. (SFH->FH_INIVIGE<> dDatIni)

						fSFHCrea(SFH->FH_AGENTE,cCOD,SFH->FH_NOME,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,"1",VAL("0") ,dDatIni,CTOD("//"),0,"N",cAlias,SFH->FH_REGIMEN)
						EndIf

					ELSE // no esta lleno(FH_REGIMEN)
					 fGravaLog(cLog,cAuxCuit,cCOD+"-"+cLoja,cAuxNom,cForClie,STR0030)	 // STR0030-"No encontrado TXT, esta en SFH sin clasificación "
					ENDIF // Fin SI esta lleno FH_REGIMEN
					
				ELSE // no encontro SFH
					 fGravaLog(cLog,cAuxCuit,cCOD+"-"+cLoja,cAuxNom,cForClie,STR0031)	 //STR0031-"Registro no encontrado en TXT y SFH "
				EndIf
			//---------
		ENDIF
	ENDIF
    SFH->(dbCloseArea())
	RestArea(aArea)

return nil


/*/{Protheus.doc} cChekRG
//Se obtiene las columnas de alicuota y fecha de percepción  de acuerdo a lo informado en cRG( se toma del campo FH_REGIMEN)
@author adrian.perez
@param cRG, caracter, RG seleccionado en el campo FH_REGIMEN
@return aCampos,arreglo,contiene los campos: alicuota y fecha; que corresponde a la RG seleccionada
/*/
Function cChekRG(cRG)

Local aCampos:={}

DEFAULT cRG:=""

	//Valores que puede contener cRG (FH_REGIMEN)
	//1.-RES_23_14 – Régimen General Percepción IIBB
	//2.-RES_27_00 – Régimen Percepción IIBB Venta Mayorista Combustibles
    //3.-RES_33_99 – Régimen Percepción IIBB Venta de Medicamentos

IF  cRG!=""
	IF cRG=="1"
	AADD(aCampos,"ALI_P_2314") // posición 7
	AADD(aCampos,"FEPER_2314") // posición 9
	ELSEIF cRG== "2"
		AADD(aCampos,"ALI_P_2700") // posición 11
		AADD(aCampos,"FEPER_2700")  // posición 13
	ELSE
		AADD(aCampos,"ALI_P_3399")  // posición 10
		AADD(aCampos,"FEPER_3399")  // // posición 12
	ENDIF
ENDIF

return aCampos

/*/{Protheus.doc}fGeraLog
// crea tabla de log
@author adrian.perez
@param oTmpTable, objeto, tabla temporal
@return nil
/*/
Function fGeraLog(oTmpTable)

Local cInfome:= GetNextAlias()
Local aCampos:={}
Local aOrdem := {"CUIT"}

DEFAULT oTmpTable:=nil

	 // Cuit| código/sucursal | nombre | indica | situación

	AADD(aCampos,{"CUIT"	      		,"C",18,0}) //CUIT 1
	AADD(aCampos,{"CODSUC"         		,"C",40,0})     //Codigo cliente/proveedor tienda
	AADD(aCampos,{"NOMBRE"         		,"C",80,0})     //Nombre
	AADD(aCampos,{"INDICA"         		,"C",9,0})      //Indica si es P(proveedor) o C /cliente
	AADD(aCampos,{"SITUACION"   		,"C",512,0})    //Muestra si : "Registro encontrado, pero sin clasificación en la SFH" o "Registro no encontrado en la SFH"
	
	oTmpTable := FWTemporaryTable():New(cInfome,aCampos )
	oTmpTable:AddIndex( "I1", aOrdem )
	oTmpTable:Create()

return cInfome

/*/{Protheus.doc}fGravaLog
//Grava registro en tabla de LOG
@author adrian.perez
@param cLog, caracter, nombre de la tabla temporal para log
@param cCUIT, caracter,CUIT cliente-proveedor
@param cCODSUC, caracter, tienda
@param cINDICA, caracter, indica si es cliente(C) o Proveedor(p)
@param cMesg, caracter, mensaje 
@return nil
/*/
Function fGravaLog(cLog,cCUIT,cCODSUC,cNombre,cINDICA,cMesg)
DEFAULT cLog:=""
DEFAULT cCUIT:=""
DEFAULT cCODSUC:=""
DEFAULT cNombre:=""
DEFAULT cINDICA:=""
DEFAULT cMesg:=""

RecLock(cLog,.T.)

   (cLog)->CUIT  :=cCUIT
   (cLog)->CODSUC:=cCODSUC
   (cLog)->NOMBRE:=cNombre
   (cLog)->INDICA:= cINDICA
   (cLog)->SITUACION:=cMesg

MsUnLock()
Return nil

/*/{Protheus.doc} fSFHCrea
//grava registro en SFH
@author adrian.perez
@param cAgente, caracter, indica si es agente
@param cCOD, caracter, codigo cliente/proveedor
@param cNome, caracter, nombre del cliente/proveedor
@param cTipo, caracter, Clas. IBB   
@param cLoja, caracter,  tienda
@param cPercIBI, caracter, pago impuesto
@param cAPERIB, caracter, indica si paga IB
@param cZonaFis, caracter, zona fiscal
@param cImpost, caracter, impuesto
@param cCatego, caracter, situación
@param nAliq, numerico, alicuota
@param dDataIni, fecha, fecha inicial
@param dDataFIm, fecha, fecha final
@param cPercent, caracter, Porcentaje de exencion   
@param cExento, caracter, indica si es exento de impuesto
@param cTable, caracter, indica que tabla fue usada SA1-Clientes o SA2-Percepción
@return nil
/*/
Function fSFHCrea(cAgente,cCOD,cNome,cTipo,cLoja,cPercIBI,cAPERIB,cZonaFis,cImpost,cCatego,nAliq,dDataIni,dDataFim,nPercent,cExento,cTable,cRegi)


 DEFAULT cAgente	:=""
 DEFAULT cCOD		:=""
 DEFAULT cNome		:=""
 DEFAULT cTipo		:=""
 DEFAULT cLoja		:=""
 DEFAULT cPercIBI	:=""
 DEFAULT cAPERIB	:=""
 DEFAULT cZonaFis	:=""
 DEFAULT cImpost	:=""
 DEFAULT cCatego	:=""
 DEFAULT nAliq		:=""
 DEFAULT dDataIni	:=""
 DEFAULT dDataFim	:=""
 DEFAULT nPercent	:=0
 DEFAULT cExento	:=""
 DEFAULT cTable	    :=""
 DEFAULT cRegi		:=""

	RecLock("SFH", .T.)
	SFH->FH_FILIAL	:=  xFilial("SFH")
	SFH->FH_AGENTE	:= cAgente
	SFH->FH_ZONFIS	:= cZonaFis
	If cTable == "SA2"
		SFH->FH_FORNECE := cCOD  
	Else
		SFH->FH_CLIENTE	:= cCOD
	EndIf
	SFH->FH_TIPO    := cTipo
	SFH->FH_LOJA	:= cLoja 
	SFH->FH_NOME	:= cNome
	SFH->FH_IMPOSTO	:= cImpost
	SFH->FH_PERCIBI	:= cPercIBI	
	SFH->FH_APERIB	:= cAPERIB

	SFH->FH_ALIQ	:= nAliq
	SFH->FH_SITUACA := cCatego
	
	SFH->FH_INIVIGE := dDataIni
	SFH->FH_FIMVIGE := dDataFim 	

	SFH->FH_ISENTO	:=cExento
	SFH->FH_PERCENT	:= nPercent
	SFH->FH_REGIMEN	:=cRegi
	SFH->(MsUnlock())

return nil


/*/{Protheus.doc} fPerCliFor
//Verifica si la percepción es de cliente o proveedor
@author adrian.perez
@param cAlias, caracter,indica cuál tabla es usada SA1-Clientes o SA2-Percepción
@param cRG7220, caracter,tabla temporal usada para cargar padrón(TXT)
@param cLog, caracter, nombre de la tabla temporal para log
@return nil
/*/
Static Function fPerCliFor(cAlias,cRG7220,cLog)

Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos(A1_ O A2_)
Local nOrd:=0
Local lExist:=.F.


Default cAlias := ""
Default cRG7220:=""
Default cLog:=""

If (cAlias=="SA1")
	nOrd:=3 //CLIENTES
Else
    nOrd:=1 //Provedores
EndIF

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())

IF lCuitSM0 .and. nOrd==1

	IF (cRG7220)->(MsSeek(ALLTRIM(SM0->M0_CGC) ))  
		lExist:=.T.
	ENDIF
	
ENDIF
    
ProcRegua(RecCount())

While !Eof() // recorre SA1 o SA2 

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"

	IF  nOrd==3
		IF !Empty((cAlias)->&(cPrefTab+"_CGC"))
			If (cRG7220)->(MsSeek(ALLTRIM((cAlias)->&(cPrefTab+"_CGC"))))   // esta dentro del padron
				lExist:=.T.
			Else 
				lExist:=.F.
			EndIf
		ENDIF

		 fSFHPer(nOrd,(cAlias)->&(cPrefTab+"_COD"),(cAlias)->&(cPrefTab+"_LOJA"),cAlias,lExist,cRG7220,cLog,(cAlias)->&(cPrefTab+"_CGC"),(cAlias)->&(cPrefTab+"_NOME"))
	ELSE
	// viene de percepcion para proveedores

	
		fSFHPer(nOrd,(cAlias)->&(cPrefTab+"_COD"),(cAlias)->&(cPrefTab+"_LOJA"),cAlias,lExist,cRG7220,cLog,(cAlias)->&(cPrefTab+"_CGC"),(cAlias)->&(cPrefTab+"_NOME"))

	Endif
	

	dbSkip()
	
EndDo

RestArea(aArea)

Return NIL

/*/{Protheus.doc} fRetFor
//Verifica datos de proveedores para comenzar retención
@author adrian.perez
@param cAlias, caracter,indica cuál tabla es usada SA1-Clientes o SA2-Percepción
@param cRG7220, caracter,tabla temporal usada para cargar padrón(TXT)
@param cLog, caracter, nombre de la tabla temporal para log
@return nil
/*/

Static Function fRetFor(cAlias,cRG7220,cLog)

Local aArea     := GetArea()			// Salva area atual para posterior restauracao
Local cPrefTab  := Substr(cAlias,2,2)	// Prefixo para acesso dos campos(A1_ O A2_)
Local lExist:=.F.

Default cAlias := ""
Default cRG7220:=""
Default cLog:=""

dbSelectArea(cAlias)
(cAlias)->(dbGoTop())
    
ProcRegua(RecCount())


While !Eof() // recorre SA2

	IncProc(Iif(lCli,STR0015,STR0016))	//##"(15)Processando Clientes/(16)Processando Fornecedores"
	
	IF !Empty((cAlias)->&(cPrefTab+"_CGC"))
		If (cRG7220)->(MsSeek(ALLTRIM((cAlias)->&(cPrefTab+"_CGC"))))   // esta dentro del padron
			lExist:=.T.
		Else 
		    lExist:=.F.
		EndIf

		fSFHRet((cAlias)->&(cPrefTab+"_COD"),(cAlias)->&(cPrefTab+"_LOJA"),cAlias,lExist,cRG7220,cLog,(cAlias)->&(cPrefTab+"_CGC"),(cAlias)->&(cPrefTab+"_NOME"))
	EndIF

	dbSkip()
	
EndDo

RestArea(aArea)

Return NIL

/*/{Protheus.doc} fSFHRet
//reglas para retención IIB
@author adrian.perez
@param cCod,caracter,codigo de cliente-proveedor
@param cLoja,caracter, tienda
@param cAlias,caracter,indica que tabla fue usada SA1-Clientes o SA2-Percepción
@param lExistTXT,logico, indica si existe en el padron(TX)
@param cRG7220, caracter, nombre de la tabla temporal padron
@param cLog, caracter, nombre de la tabla temporal log
@param cAuxCuit, caracter, cuit que viene desde SA1-Clientes o SA2-Percepción, usado en caso de no estar en TXT O SFH
@param cAuxNom, caracter, nombre que viene desde SA1-Clientes o SA2-Percepción, usado en caso de no estar en TXT O SFH
@return nil
/*/

Static Function fSFHRet(cCod,cLoja,cAlias,lExistTXT,cRG7220,cLog,cAuxCuit,cAuxNom)
Local aArea    := GetArea()	
Local nRecFim:=0
Local cChave:=""
Local cAuxCateg :=""
Local cTipo:=""
Local cExento:="S"
Local nPorcent:=0

DEFAULT cCod:=""
DEFAULT cLoja:=""
DEFAULT	cAlias:=""
DEFAULT lExistTXT:=.F.
DEFAULT cRG7220:=""
DEFAULT cLog:=""
DEFAULT cAuxCuit:=""
DEFAULT cAuxNom:=""

	cChave := xFilial("SFH")+cCod+cLoja+_IMPRET+_ZONAFIS
	dbSelectArea("SFH")
	SFH->(dbSetOrder(1))
	SFH->(dbGoTop())

		cAuxCateg := IIf(ALLTRIM((cRG7220)->CATE) $ "A|B","2","1")
		/* Valores de REGIMEN(Columna 14)
		-	CONVENIO MULTILATERAL
		-	ORGANISMO PÚBLICO
		-	PRODUCTORES DEL PAIPPA
		-	RÉGIMEN GENERAL
		*/
		IF ALLTRIM((cRG7220)->REGIMEN) $  ALLTRIM("CONVENIO MULTILATERAL")
			cTipo:="V"
		ELSEIF (ALLTRIM((cRG7220)->REGIMEN) $  ALLTRIM("RÉGIMEN GENERAL")) .OR. (ALLTRIM((cRG7220)->REGIMEN) $  ALLTRIM("REGIMEN GENERAL"))
			cTipo:="I"
		ELSE
		   cTipo:=""
		ENDIF

		//- cib_exento=Si “EXENTO”=SI ? cib_exento=”E”; sino cib_exento=”N”
		IF ALLTRIM((cRG7220)->EXENTO) =="NO"
			cExento:="N"
		ENDIF

		IF lExistTXT //esta en TXT(Padron)
			If SFH->(MsSeek(cChave)) 

				nRecFim :=  MayorFech(cCod,cLoja,_IMPRET,_ZONAFIS,cAlias)

				SFH->(DbGoTo(nRecFim))
			
					If dDatIni  <= SFH->FH_FIMVIGE 
						SFH->(dbCloseArea())
						RestArea(aArea)
						Return nil
					ElseIf ( (dDatIni  == (SFH->FH_FIMVIGE + 1)) .AND. (SFH->FH_ALIQ == VAL((cRG7220)->ALI_R_2897) ) .AND.(SFH->FH_SITUACA== cAuxCateg) .AND. (SFH->FH_TIPO==cTipo) )
						Reclock("SFH",.F.) 
						SFH->FH_FIMVIGE := dDatFim
						MsUnLock()	
					Else
						IF ALLTRIM(((cRG7220)->FERET_2897))!=""
							nPorcent:=100
						ENDIF
						fSFHCrea(SFH->FH_AGENTE,cCOD,SFH->FH_NOME,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,cAuxCateg,VAL((cRG7220)->ALI_R_2897) ,dDatIni,dDatFim,nPorcent,cExento,cAlias,"")
					EndIf

			ELSE // no encontro SFH

				IF ALLTRIM(((cRG7220)->FERET_2897))!=""
					nPorcent:=100
				ENDIF
			   
				fSFHCrea("N",cCOD,cAuxNom,cTipo,cLoja,"N","N",_ZONAFIS,_IMPRET,cAuxCateg,VAL((cRG7220)->ALI_R_2897) ,dDatIni,dDatFim,nPorcent,cExento,cAlias,"")
			EndIf
		ELSE // No esta en TXT(Padron)
			//---------
				If SFH->(MsSeek(cChave)) 

					nRecFim :=  MayorFech(cCod,cLoja,_IMPRET,_ZONAFIS,cAlias)

					SFH->(DbGoTo(nRecFim))
					
					If dDatIni  <= SFH->FH_FIMVIGE 
						SFH->(dbCloseArea())
						RestArea(aArea)
						Return nil
					ElseIf dDatIni > SFH->FH_FIMVIGE  .AND. (SFH->FH_INIVIGE<> dDatIni)

					fSFHCrea(SFH->FH_AGENTE,cCOD,SFH->FH_NOME,SFH->FH_TIPO,SFH->FH_LOJA,SFH->FH_PERCIBI,SFH->FH_APERIB,SFH->FH_ZONFIS,SFH->FH_IMPOSTO,"1",VAL("0") ,dDatIni,CTOD("//"),0,"N",cAlias,"")
							
					EndIf

				EndIf
			//---------
		ENDIF
	
    SFH->(dbCloseArea())
	RestArea(aArea)

return nil

/*/{Protheus.doc} FISR145
//Imprime log de los cuits que no fueron afectados para la perceoción de IIBB
@author adrian.perez
@param cLog, caracter, nombre de la tabla temporal para log
@return nil
/*/

Function FISR145(cLog)

Local opReport := Nil
DEFAULT cLog:=""

If TRepInUse()
	opReport:=GeraReport(cLog,opReport)
	opReport:PrintDialog()
Endif

Return Nil

/*/{Protheus.doc} GeraReport
//Define la estructura del log para impresión
@author adrian.perez
@param cLog, caracter, nombre de la tabla temporal para log
@param opReport,objeto, objeto reporte
@return nil
/*/
Static Function GeraReport(cLog,opReport)

Local olReport := Nil

DEFAULT cLog:=""
DEFAULT opReport := Nil

olReport:= TReport():New("FISA145LOG",STR0001,,{|opReport|PrintReport(cLog,opReport)},"") //"Comprovante de Retencao"
olReport:lHeaderVisible		:= .F. // Não imprime cabeçalho do protheus
olReport:lFooterVisible		:= .F. // Não imprime rodapé do protheus
olReport:lParamPage			:= .F. // Não imprime pagina de parametros
olReport:oPage:nPaperSize	:= 2   // Impressão em papel A4
olReport:NFONTBODY			:= 11  // Tamanho da fonte
olReport:SetLandscape()	
olReport:DisableOrientation()  

Return olReport


/*/{Protheus.doc} PrintReport
//Imprime lo almacenado en la tabla de LOG
@author adrian.perez
@param cLog, caracter, nombre de la tabla temporal para log
@param opReport,objeto, objeto reporte
@return nil
/*/
Static Function PrintReport(cLog,opReport)

	
	Local nlY:= 50	
	DEFAULT cLog:=""
	DEFAULT opReport := Nil

			opReport:PrintText("",nlY,0950)
			opReport:PrintText(STR0032,nlY+=40,0950)  //STR0032"Informe log CUITS Fomosa"

			opReport:PrintText(STR0033,nlY+=40,0750) // STR0033 "Este Log solo informa detalles de la percepción de IIBB"
		

			oSection1 := TRSection():New(opReport,"RB IIB",{cLog})

			TRCell():New( oSection1, "CUIT"        ,cLog,STR0034,,50)  // STR0034 "CUIT" 
			TRCell():New( oSection1, "CODSUC"      ,cLog,STR0035,,40) // STR0035 "Sucursal"
			TRCell():New( oSection1, "NOMBRE"      ,cLog,STR0036,,80) //STR0036  "Nombre"
			TRCell():New( oSection1, "INDICA"      ,cLog,STR0037,,22)   // STR0037 "Cli-Pro"
			TRCell():New( oSection1, "SITUACION"   , cLog,STR0038,,700)  //STR0038 "Situación"
			opReport:PrintText("",nlY+=70,0950)
			(cLog)->(DBGoTop())

			opReport:Section(1):Init() 
    		while !(cLog)->(Eof())
			
	  		opReport:Section(1):PrintLine()
			
	
        	(cLog)->(DBSkip())
    		enddo
			opReport:Section(1):Finish()

			opReport:EndPage()
   
Return Nil

