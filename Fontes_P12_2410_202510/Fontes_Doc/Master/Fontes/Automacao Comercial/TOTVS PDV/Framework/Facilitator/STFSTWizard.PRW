#INCLUDE "STFSTWizard.ch"
#INCLUDE "TCBROWSE.CH"
#include "PROTHEUS.CH"  
#iNCLUDE "apwizard.ch"  
#INCLUDE "POSCSS.CH" 


#DEFINE X3_USADO_EMUSO 		"€€€€€€€€€€€€€€ "
#DEFINE X3_USADO_NAOUSADO 	"€€€€€€€€€€€€€€€"   


Static oStepWiz 		:= Nil	//Objto tipo Wizard
Static oNewPag			:= Nil	//Objeto que adiciona nova pagina no wizard
Static cL1_DOC			:= ""  	//Numero do Documento NF-e
Static cL1_SERIE		:= ""	//Numero da Serie do documento NF-e

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStWizard
Wizard de Estação
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STFStWizard()     
Local oDlg 			:= NIL 															//Objeto Wizard
Local aItens 		:= NIL 															//Itens do Wizard     
Local cLg_Codigo 	:= SLG->(CriaVar("LG_CODIGO")) 									//codigo da Estação 
Local cLog 			:= ""       													//Variável de Log
Local aSize 		:= MsAdvSize(.F.) 												//Dimensões da Janela
Local aCoord 		:= {aSize[7],0 , aSize[6],aSize[5] }							//Coordenadas da Janela  
Local cImpFisc 		:= CriaVar("LG_IMPFISC") 										//Nome da Impressãra Fiscal
Local cPorta   		:= CriaVar("LG_PORTIF") 										//Porta da Impressora Fiscal  
Local lConecta 		:= .F. 															//ECF Conectado?     
Local cEstAnt 		:= ""   														//Estação Anterior
Local lCaixaECF 	:= nModulo == 12 .AND. IsCaixaLoja(xNumCaixa()) .AND. lFiscal  	//Caixa é Fiscal?
Local aRet			:= {}
    
 	STFStrategyECF()  
 	
 	If lCaixaECF
 		LjCloseDevices()
 	EndIf

 
	oDlg := ApWizard():New( STR0001 , ,STR0002  , STR0003 ,{ ||  .T.  } , { || IIF(lCaixaECF,LjCloseDevices(), STWCloseDevice()), oDlg := FreeObj(oDlg)} , .T. ,   , { || .t. } , .f., aCoord )	 	 //"Apresentação"###"Wizard da Estação"###"Este Wizard fornece passo-a-passo para os itens da estação a serem configurados"
	LoadPanels(	@oDlg, @cLG_CODIGO, @aItens, 1, ;
				@cLog, @cImpFisc, 	@cPorta, @lConecta)

	oDlg:Activate ( .t. , { || IIF(lCaixaECF,LjCloseDevices(), STWCloseDevice()), cEstAnt := cEstacao }, { || .t. }, { || .t.} )
 
    
    cEstacao := cEstAnt    
    
    If lConecta  
		aRet :=	STFFireEvent(		ProcName(0)																,;		// Nome do processo
												"STCloseCom"																,;		// Nome do evento
												{cPorta } ) 
				    
					  	
    EndIf
    
  	If lCaixaECF
 		LjOpenDevices()
 	EndIf    
 	
Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadPanels
Carrega os Painéis do Wizard
@param cCargo  Nó
@param oTree   Arvore
@param aDados  Array dos nós
@param cIdAmb  Código do Ambiente
@param oPanel  Painel
@param oDlg    Janela
@param cLog	   Log
@param cImpFisc Impressora Fiscal
@param cPorta	Porta de Comunicação
@param lConecta Im´ressora Conectada
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LoadPanels(oDlg, cLG_CODIGO, aItens,  nPanelAtu, ;
							cLog, cImpFisc, 	cPorta, lConecta)  
							
Local nI 		:= 0     //Variável contadora
Local nInicial 	:= 0  	//Panel Inicial 
Local nFinal 	:= 0    //Panel Final

DEFAULT oDlg := NIL  	
DEFAULT cLG_CODIGO := SLG->(CriaVar("LG_CODIGO"))  
DEFAULT aItens := {}
DEFAULT cLog := "" 
DEFAULT cImpFisc := ""
DEFAULT cPorta	 := ""    
DEFAULT lConecta := .F.
	

  	//2 
  	nPanelAtu++
  	oDlg:NewPanel ( "Estação", STR0004 , { || .F.  }  , { || !Empty(cLg_CODIGO) } , { || .t. } ,.T., { || CriaCompestat(oDlg, @cLG_CODIGO)}) //"Informe o código da Estação"
	//3  
	nPanelAtu++
 	oDlg:NewPanel ( STR0005, STR0006, { || .T.  }  , { || .t. } , { || .t. } ,.T., { || cEstacao := cLG_CODIGO,  SelectItens(oDlg, @cLG_CODIGO, @aItens, @cLog)}) //"Item a configurar"###"Selecione o item a ser configurado/validado"
    
    nInicial := nPanelAtu
 	aItens := LoadItens(nPanelAtu,	@oDlg, @cLG_CODIGO, @cLog, ;
 						@cImpFisc, @cPorta , @lConecta) 
 	
 	If Len(aItens) > 0
 		nFinal := aTail(aItens)[5] 
 	EndIf  
 	
 	For nI := 1 to Len(aItens)
		oDlg:NewPanel( aItens[nI, 02], , { || .F. }  ,{ || .t. } , { || .t. } ,.T., &("{ || STFStWzLoadPanel(aItens, " + Str(nI) + ", oDlg, cLg_CODIGO, @cImpFisc, @cPorta, @lConecta, @cLog)}"))
	    LoadDetItens( aItens, nI, oDlg, @cLG_CODIGO, @cLog,@cImpFisc, @cPorta, @lConecta)
	Next

	oDlg:NewPanel ( STR0007, STR0008, { || .F.  }  , { || .T. } , { || .t. } ,.T., { || Exibelog(oDlg, oDlg:nPanel, cLog) }) //"Log"###"Log de atividades realizadas"
    
Return     

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaCompestat
Carrega o código da Estação
@param oDlg    Janela
@param cLG_CODIGO Codigo da Estação
@param cLog	   Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function CriaCompestat(oDlg, cLG_CODIGO, cLog)   
Local oPanel 	:= NIL     					   		//Panel Atual
Local nRow 		:= 0  						   		//Linhas do Panel
Local nCol 		:= 0  						   		//Colunas do panel
Local aObjects 	:= {} 						   		//Array de objetos   
Local aPosObj 	:= {} 						   		//Posicao dos objetos   
Local nTam		:= 0 								//tamanho do controle       
Local nTamSX3 	:= SLG->(TamSX3("LG_CODIGO")[1]) 	//Tamanho do Campo Estação
Local aArea		:= GetArea()       					//WorkArea Ativa
Local aAreaSLG	:= SLG->(GetArea()) 				//WorkArea SLG   

DEFAULT oDlg := NIL
DEFAULT cLG_CODIGO := SLG->(CriaVar("LG_CODIGO"))   
DEFAULT cLog := ""
	
	oPanel := oDlg:GetPanel(oDlg:nPanel) 
	nRow		:= Int((oPanel:nHeight ) / 2)  //Linha do Painel
	nCol		:= Int((oPanel:nWidth ) / 2)   //Coluna do Painel	
	

	nTam := CalcFieldSize("C",nTamSX3,0,"@!",STR0009) //"Código da Estação"
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say
	aAdd(aObjects,  { nTam, 10, .F., .F.}) //Impar Sa

	aPosObj := MsObjSize( { 0 , 15 , nRow ,nCol, 2, 3,3,3}, aObjects, .T., .F.)

	@aPosObj[01,01],aPosObj[01, 2] SAY STR0009 SIZE nTam,10 PIXEL OF oPanel 	  //"Código da Estação"
   	@aPosObj[02,01],aPosObj[2, 2] MsGet cLg_CODIGO Size  nTam,10 PIXEL OF oPanel F3 "SLG"  PIXEL Picture "@!" VALID ExistCpo("SLG", cLG_CODIGO, 1)
    
    RestArea(aAreaSLG)
	RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadItens
Carrega as funcionalidades do Wizard
@param nPanelAtu  Panel Atual
@param oDlg    Janela
@param cLG_CODIGO Codigo da Estação
@param cLog	   Log
@param cImpFisc Impressora Fiscal
@param cPorta	Porta de Comunicação
@param lConecta Im´ressora Conectada
@author  Varejo
@version P11.8
@since   26/04/2013
@return  aItens Componentes a configurar
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function LoadItens(nPanelAtu, oDlg,  cLG_CODIGO, cLog, cImpFisc, cPorta, lConecta)        
Local aItens := {}       	//Itens do Wizard
   
DEFAULT nPanelAtu 	:= 1   	//Panel Atual
DEFAULT oDlg 		:= "" 	//Janela
DEFAULT cLG_CODIGO 	:= "" 	//Codigo da Estação
DEFAULT cLog		:= ""  	//Log da Rotina
DEFAULT cImpFisc	:= ""  	//Impressora Fiscal
DEFAULT cPorta		:= ""  	//Porta de Comunicação
DEFAULT lConecta 	:= .F.  //Conectado
	
    nQtdPanels := 5  //quantidade de Paineis  
    nPanelAtu++
  	aAdd(aItens, { .T.,; //Habilitado?
  					 STR0010,; //Descrição //"Impressora Fiscal"
  					  &("{ || STFLdWzIF(oDlg, cLG_CODIGO, " + Str(nPanelAtu) + ", @cLog, aItens[1], @cImpFisc, @cPorta, @lConecta)} "),; //Bloco
  					  nPanelAtu, ;    //Painel Atual
  					  nPanelAtu + nQtdPanels, ; //Painel Seguinte
  					  "STFLdWzIF(oDlg, cLG_CODIGO, " + Str(nPanelAtu) + ", @cLog, aItens[1], @cImpFisc, @cPorta, @lConecta) "})  //Bloco Carregar
  	
  	nPanelAtu += nQtdPanels
  	nQtdPanels := 2 //Cadastro e teste da transação
    aAdd(aItens, {.F., ;
    					STR0011,; //"TEF"
    					&("{ || STFLdWzTEF(oDlg, cLG_CODIGO, " + Str(nPanelAtu) + ", @cLog, aItens[2], lConecta ) } "),;
    					nPanelAtu, ;
    					nPanelAtu + nQtdPanels, ;
    					"STFLdWzTEF(oDlg, cLG_CODIGO, " + Str(nPanelAtu) + ", @cLog, aItens[2], lConecta)"})   
  
  	Return aItens        

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadDetItens
Carrega os paineis do facilitador
@param aItens  Funcionalidades do Wizard
@param nItem	
@param oDlg    nI
@param cLG_CODIGO Codigo da Estação
@param cLog	   Log
@param cImpFisc Impressora Fiscal
@param cPorta	Porta de Comunicação
@param lConecta Im´ressora Conectada
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------
Function LoadDetItens(aItens, nItem, oDlg, cLG_CODIGO, ;
						cLog ,cImpFisc, cPorta, lConecta) 
						
Local nI 		:= 0  //Variavel contadora
Local nTotItens := 0 //total de itens

DEFAULT aItens 		:= {}  	//Paineis da Funciopnalidade
DEFAULT nItem		:= 0   	//Item da funcionalidade
DEFAULT oDlg 		:= NIL 	//Janela
DEFAULT cLG_CODIGO 	:= ""  	//Estação
DEFAULT cLog 		:= "" 	//Variavel de Log
DEFAULT cImpFisc 	:= ""   //Impressora Fiscal
DEFAULT cPorta	 	:= ""   //Porta de Comunicação
DEFAULT lConecta	:= .F.  //ECF Conectado?
	
	nTotItens := aItens[nItem, 05] -  aItens[nItem, 04]
    nTotItens--

	Do Case
	Case nItem == 1
	    For nI := 1 to nTotItens
	    	oDlg:NewPanel( aItens[nItem, 02], , { || .F. }  ,{ || .T. } , { || .t. } ,.T., &("{ || "+  aItens[nItem, 06]  + "}"))	    
	    Next
	Case nItem == 2	 
		For nI := 1 to nTotItens
	    	oDlg:NewPanel( aItens[nItem, 02], , { || .F. }  ,{ || .T. } , { || .t. } ,.T., &("{ || "+  aItens[nItem, 06]  + "}"))	    
	    Next
	Endcase

Return
                      
//-------------------------------------------------------------------
/*/{Protheus.doc} SelectItens
Selecionar as funcionalidades a serem executadas
@param oDlg    nI
@param cLG_CODIGO Codigo da Estação
@param aItens	Itens do Wizard
@param cLog	   Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  NIL
@obs
@sample
/*/
//-------------------------------------------------------------------                      
Static Function SelectItens(oDlg, cLG_CODIGO, aItens, cLog)

Local nRow 		:= 0  	//Linha
Local nCol 		:= 0  	//Coluna  
Local aObjects 	:= {} 	//Objetos 
Local nI		:= 1  	//Contador
Local cVar		:= "" 	//Variavel  
Local cGet 		:= "" 	//Controle
Local cVariable	:= ""  	//Variavel
   	
DEFAULT aItens 		:= {}						//Itens da Funcionalidade
DEFAULT oDlg 		:= NIL	   					//Janela
DEFAULT cLG_CODIGO := SLG->(CriaVar("LG_CODIGO"))//Estação        

	 cLog:= STR0012 + cLG_CODIGO + "]" //" - Configurando dados da estação ["
	
	oDlg:SetMessage( STR0013+ cLG_CODIGO + "]",  oDlg:nPanel  , .F. )  //"Selecione o item a ser configurado/validado da Estação ["

	oPanel := oDlg:GetPanel(oDlg:nPanel) 
	nRow		:= Int((oPanel:nHeight ) / 2)  //Linha do Painel
	nCol		:= Int((oPanel:nWidth ) / 2)   //Coluna do Painel	                      
    @0,0 to nRow, nCol
   
    For  nI := 1 to Len(aItens)  
    
    	nTam := CalcFieldSize("C",Len(aItens[nI,02])+5,0,"",aItens[nI,02])
    	aAdd(aObjects,  { nTam, 10, .F., .F.}) //Impar Say
    Next
    
    aPosObj := MsObjSize( { 0 , 15 , nRow ,nCol, 2, 3,3,3}, aObjects, .T., .F.)
	
    
	For nI := 1 to Len(aItens)
                                   
		cVariable := "aItens["+Str(nI)+"][01]" 
 		cGet := "{ |U| Iif(PCOUNT() > 0, "+cVariable+" := U, "+cVariable+")} "

  		TCheckBox():New(aPosObj[nI, 01], aPosObj[nI, 02],aItens[nI, 02],&cGet,oPanel, aObjects[nI, 01],aObjects[nI, 02],,,,,,,,.T.,,,)
                                                                                          
	Next

Return	                

//-------------------------------------------------------------------
/*/{Protheus.doc} STFStWzLoadPanel
Carrega o Panel
@param aItens  Itens da Funcionalidade
@param nItens  Item da funcionalidade
@param oDlg		Janela
@param cLG_CODIGO Codigo da Estação
@param cImpFisc Impressora Fiscal
@param cPorta	Porta de Comunicação
@param lConecta	Impressora Conectada
@param cLog	   Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  .T.
@obs
@sample
/*/
//-------------------------------------------------------------------  
Function STFStWzLoadPanel(aItens, 	nItens, 	oDlg , 		cLG_CODIGO, ;
						  cImpFisc, cPorta, 	lConecta, 	cLog)
						   
DEFAULT aItens 		:= {} 	//Itens da funcionalidade
DEFAULT nItens 		:= 1  	//Item da Funcionalidade
DEFAULT oDlg 		:= NIL	//Janela
DEFAULT cLG_CODIGO 	:= "" 	//Estação
DEFAULT cImpFisc 	:= ""	//Impressora Fiscal
DEFAULT cPorta 		:= ""	//Porta de Comunicação
DEFAULT lConecta 	:= .F.	//Impressora Conectada
DEFAULT cLog		:= ""	//Log de Execução
	
	If !aItens[nItens, 01]  
		
		oDlg:SetPanel(aItens[nItens, 05])
		
	Else 
		cLog += CRLF + space(5 * 1) + STR0014 + aItens[nItens, 02] + "]" //" - Configurando o item [ "
		Eval( aItens[nItens, 03])
	EndIf 
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibeLog
Exibe o Log de Execução do Wizard
@param oDlg		Janela
@param nPanel	//Painel
@param cLog	   Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  cLog  Log de Execução da Rotina
@obs
@sample
/*/
//-------------------------------------------------------------------  
Static Function ExibeLog(oDlg, nPanel, cLog)

Local aObjects 	:= {} 	//Objetos da Janela
Local aPosObj 	:= {}  	//Posicionamento de Objetos da Janela
Local nRow 		:= 0  	//Linhas do Panel
Local nCol 		:= 0  	//Colunas do panel     
Local oPanel 	:= NIL  //Painel
Local nRow1 	:= 0  	//Linha
    
DEFAULT oDlg := NIL   	//Janela
DEFAULT nPanel := 1 	//Panel
DEFAULT cLog := ""    	//Log

	oPanel := oDlg:GetPanel(nPanel)   

	nRow		:= Int( oPanel:nHeight/2)  //Linha do Painel
	nCol := Int( oPanel:nWidth/ 2)
	
	oPanel := TScrollBox():New( oPanel, 0,0,nRow,nCol)  
	nCol := Int( nCol *.97 )     
	nRow1 := Int( nRow *.93)
	
	aObjects := { {CalcFieldSize("C",110,0),nRow1, .F., .F.} }
	aPosObj2 := MsObjSize( { 0 , 15 , nRow1 ,nCol, 2, 3,3,3}, aObjects, .T., .F.)

	TMultiGet():New(aPosObj2[1, 1],aPosObj2[1, 2],{|| Iif(PCOUNT() > 0, cLog := U,cLog)} ,oPanel,;
								aObjects[1, 01],aObjects[1, 02],/*oFont*/,.T.,;
								/*nClrFore*/,/*nClrBack*/,/*oCursor*/,.T.,;
								/*cMg*/,.T.,,/*lCenter*/,;
								/*lRight*/,.T.,,/*bChange*/,;
								,.F., .T.) 
Return cLog    


//-------------------------------------------------------------------
/*/{Protheus.doc} STFLdWzIF
Paineis do Wizard da Impressora Fiscal
@param oDlg			Janela
@param cLG_CODIGO	Codigo da Estacao
@param nPanelIni	Panel Inicial do Wizard
@param cLog	   		Log 
@param aItem		Item da funcionalidade
@param cImpFisc		Impressora Fiscal
@param cPorta		Porta de Comunicação
@param lConecta		Impressora Conectada	
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//-------------------------------------------------------------------  
Function STFLdWzIF(oDlg, 	cLG_CODIGO, nPanelIni,	cLog, ;
					aItem, 	cImpFisc, 	cPorta, 	lConecta)
					
Local nItem 	:= 0	//Item do Painel	 
Local nPanel 	:= 0    //Painel atual
Local aImpFisc 	:= {}   //Impressora Fiscal
Local aPortas	:= {}  	//Porta de Comunicação
Local lRet		:= .T.  //Retorno 
Local cPDV 		:= CriaVar("LG_PDV")	//PDV     
Local cTamSer 	:= CriaVar("LG_TAMSER") //Tamanho do número de série COO  
Local cSerie  	:= CriaVar("LG_SERPDV") //Numero de Fabricação
Local aAliqICM 	:= {} 					//Alíquotas de ICMS
Local aALiqISS 	:= {}                   //Alíquotas de ISS
Local aALiqECF 	:= {}					//Alíquotas do ECF 
Local aAliqPtr 	:= {}					//Aliquotas do Protheus  
Local aRet	   	:= {} 					//Retorno da rotina  
Local aTotPtr 	:= {} 					//Totalizadores do Protheus
Local aTotNFisc := {}					//Totalizadores não-fiscais
Local cImpFiscST:= ""					//Impressora da Estação
Local cPortaST  := ""                   //Porta da Estação
Local aFormaECF := {}                   //Formas de pagamentos do ECF
Local aFormaPtr := {}					//Formas de pagamento do Protheus
Local lTotvsApi := .F.					//ECF cadastrado no totvsApi?
Local cMessage 	:= ""                   //Mensagem
Local cMessage2 := ""                   //Segunda Mensagem
Local nEspaco 	:= 5                    //Espaço
Local nNivel 	:= 2                    //Nivel

DEFAULT oDlg 		:= NIL 	//Janela
DEFAULT cLG_CODIGO 	:= ""	//Estação 
DEFAULT nPanelIni 	:= 0	//Painel Inicial   
DEFAULT cLog		:= ""	//Log da Rotina
DEFAULT aItem		:= {}	//Paineis da Rotina
DEFAULT cImpFisc 	:= ""	//Impressora Fiscal
DEFAULT cPorta	 	:= ""	//Porta de Comunicação
DEFAULT lConecta 	:= .F.	//Impressora Conectada  

	nPanel := oDlg:nPanel
	
	nItem := (nPanel - nPanelIni) + 1
	
	cMessage2 :=  STR0015+ cLG_CODIGO + "]"	 //" da Estação ["
	Do Case 
		Case nItem == 1  


			cMessage :=  STR0016  + aItem[2]  //"Configuração dos Dados da "
            
            cLog += CRLF + space(nEspaco * nNivel) + " - " + cMessage  
            nNivel++
                 
			lRet := STFWzDtIF(cLG_CODIGO, @cImpFisc, @cPorta, @cPDV, ;
							  @cTamSer,  @aImpFisc, @aPortas, @lConecta, ;
							  @cSerie, @cLog, (nEspaco * nNivel))   
			
			//Carrega a Tela
			If lRet  
				STFWzLdIF(cLG_CODIGO, @cImpFisc, @cPorta, @cPDV, ;
							@cTamSer, aImpFisc, aPortas, oDlg, ;
							nPanel,  @lConecta, @cSerie,@cLog, ;
							(nEspaco * nNivel)) 
							  
			    //So avança se tiver gravado os dados
                
                If !lRet
                		oDlg:SetPanel(aItem[5])
                EndIf      
                
			Else

				oDlg:SetPanel(aItem[5])
			EndIf
	    Case nItem == 2  
			cMessage :=  cMessage :=  STR0017  + aItem[2] //"Programando Alíquotas na "
			
            cLog += CRLF + space(nEspaco * nNivel) + " - " + cMessage 
            nNivel++ 
			
			cImpFiscST := STFGetStat("IMPFISC")
			cPortaST :=  STFGetStat("PORTIF")

		    If ( cImpFisc <>  cImpFiscSt  .OR.  cPorta <> cPortaSt)
		    
		    	
		    	If lConecta 
		    		//Fecha o ECF
			    	aRet :=	STFFireEvent(		ProcName(0)																,;		// Nome do processo
												"STCloseCom"																,;		// Nome do evento
												{cPorta } ) 
				    
					
					lRet := Len(aRet) > 0 .AND. aRet[1] == 0
					lConecta := !lRet
					

					cLog +=  CRLF + space(nEspaco * nNivel) +  IIF(lRet, "", "[ERRO]" ) + STR0018+AllTrim(cImpFisc)+STR0019 +cPorta+"]" //" - Fechando Impressora Fiscal ["###"] Porta["

				EndIf
				
				If lRet
					cImpFisc := cImpFiscST
					cPorta := cPortaST
				EndIf
		    
		    EndIf 

			//Busca as Alíquotas
			lRet := lRet .AND. STFWzLdAIF(cLG_CODIGO, 	cImpFisc, 	cPorta, @lConecta, ;
											@aAliqICM, 	@aAliqISS, 	@aALiqECF,	@cLog,;
											(nEspaco * nNivel) )   

			
			If lRet  .AND. AliasIndic("MFD")
				lRet := STFWzLdAP(cLG_CODIGO, @aAliqPtr, @aAliqECF,	oDLG, ;
									nPanel ,@cLog, (nEspaco * nNivel)) 

				
				If lRet
					STFWzPrAP(cLG_CODIGO, @aAliqPtr, @aAliqECF, oDLG, ;
								nPanel,	  @cLog,	(nEspaco * nNivel))  
				Else	
						oDlg:SetPanel(aItem[5])
				EndIf
			Else
				oDlg:SetPanel(aItem[5])
			EndIf			
	    	
	    Case nItem == 3  //totalizadores não-fiscais
 			cMessage :=  STR0020  + aItem[2] //"Programando Totalizadores Não-Fiscais na "
	        
            cLog += CRLF + space(nEspaco * nNivel) + " - " + cMessage 
            nNivel++ 
				//Busca os Totalizadores 
			lRet := STFWzLdTIF(cLG_CODIGO, 	cImpFisc, 	cPorta, @lConecta, ;
								@aTotNFisc, @lTotvsApi,	@cLog,	 (nEspaco * nNivel))   

			
			If lRet 
				STFWzLdTP(cLG_CODIGO, 	@aTotPtr, @aTotNFisc, lTotvsApi,;
							@cLog, 		(nEspaco * nNivel)) 
				
	
				STFWzPrTP(cLG_CODIGO,  @aTotPtr, @aTotNFisc, 	lTotvsApi, ;
							oDLG, 		nPanel,		@cLog, 		(nEspaco * nNivel)) 

			Else
				oDlg:SetPanel(aItem[5])
			EndIf			

	    Case nItem == 4  
			cMessage :=  STR0021 + aItem[2] //"Programar Formas de Pagamento na "
            cLog += CRLF + space(nEspaco * nNivel) + " - " + cMessage 
            nNivel++ 
            
			//Busca as formas de pagamento 
			lRet := STFWzLdFIF(cLG_CODIGO, 	cImpFisc, cPorta, @lConecta, ;
								@aFormaECF, @lTotvsApi,@cLog, (nEspaco * nNivel)  )   

			
			If lRet   //Busca as formas de pagamento do Sistema
				STFWzLdFP(cLG_CODIGO,	cImpFisc , @aFormaPtr, @aFormaECF, ;
							lTotvsApi,	@cLog, (nEspaco * nNivel)) 
				
	
				STFWzPrFP(cLG_CODIGO,  @aFormaPtr, @aFormaECF, lTotvsApi, ;
							oDLG, 		nPanel,		@cLog, (nEspaco * nNivel))  

			Else
				oDlg:SetPanel(aItem[5])
			EndIf


	    Case nItem == 5   //Programar horário de ver~so 
	    	cMessage := STR0022 + aItem[2] //"Programar Horário de Verão na "
            cLog += CRLF + space(nEspaco * nNivel) + " - " + cMessage 
            nNivel++ 
            	    	
 
 			lRet := STFWzPrHP(cLG_CODIGO, cImpFisc, @lConecta, 			oDLG, ;
 								nPanel, 	@cLog, (nEspaco * nNivel)) 
 			
 			If !lRet     
 				oDlg:SetPanel(aItem[5])
 			EndIf
	EndCase  
	
	If lRet
		oDlg:SetMessage( cMessage + cMessage2,  oDlg:nPanel  , .t. ) 
    EndIf
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} STFLdWzTEF
Paineis do Wizard do TEF
@param oDlg			Janela
@param cLG_CODIGO	Codigo da Estacao
@param nPanelIni	Panel Inicial do Wizard
@param cLog	   		Log 
@param aItem		Item da funcionalidade
@param lConecta		Impressora Conectada	
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFLdWzTEF(oDlg, cLG_CODIGO, nPanelIni, cLog, ;
					aItem, lConecta)
					
Local nItem 	:= 0  	//Item
Local nPanel 	:= 0  	//Painel  
Local oPanel  	:= 0  	//Objeto Painel
Local oCfgTef 	:= NIL 	//Objeto TEF 2.0
Local lRet 		:= .T. 	//Retorno  
Local oPanel2	:= NIL	//Painel 2 
Local nRow 		:= 0	//Linha
Local nCol 		:= 0   	//Coluna
Local nRow1 	:= 0	//Linha 2 seção 
Local nEspaco 	:= 5 	//Espaços
Local nNivel 	:=  2	//Nivel 
Local cMessage2 := ""	//Segunda Mensagem
Local cMessage 	:= ""   //Mensagem
Local cLogTmp 	:= ""	//Log Temporário
	
DEFAULT oDlg 		:= NIL 	//Janela
DEFAULT cLG_CODIGO 	:= "" 	//Codigo da Estação
DEFAULT nPanelIni 	:= 0	//Painel Inicial   
DEFAULT cLog		:= ""	//log   
DEFAULT lConecta	:= .F. 	//Impressora Conectada?
	
	nPanel := oDlg:nPanel
	
	nItem := (nPanel - nPanelIni) + 1   
	oPanel := oDlg:GetPanel(nPanel)


	cMessage2 :=  STR0015+ cLG_CODIGO + "]"	    //" da Estação ["
	
	  
	Do Case
	Case nItem == 1   
	
		cMessage :=   STR0023 //"Configurações TEF"
		oDlg:SetMessage(  cMessage + cMessage2 ,  oDlg:nPanel  , .F. )    
		cLog += CRLF + space(nNivel * nEspaco) + " - " + cMessage + cMessage2

		nRow		:= Int((oPanel:nHeight ) / 2)  //Linha do Painel
		nCol		:= Int((oPanel:nWidth ) / 2)   //Coluna do Painel
		nRow1 		:= nRow-30
		
		oPanel2 := TScrollBox():New( oPanel, 0,0,nRow,nCol)
		
		oCfgTef := STFStTEF20( oPanel2, cLG_CODIGO)  
		
		If ValType(oCfgTef) == "O"
			nNivel++
			@nRow1+3, 0 TO nRow, nCol OF oPanel PIXEL
			TButton():New( nRow1+8, 05, STR0024,oPanel,{|| STFLdGrTEF(oCfgTef, @cLog, aItem, oDlg,; //"Gravar"
																		(nNivel * nEspaco)) },55,15,,,.F.,.T.,.F.,,.F.,{ || .T. },,.F. )
		Else 
			oDlg:SetPanel(aItem[5])
		EndIf
			
	Case nItem == 2  
		  cMessage :=   STR0025	 //"Teste de comunicação TEF"
		  //cLogTmp := cMessage + cMessage2 
		  cLogTmp += CRLF + space(nNivel * nEspaco) + " - " + cMessage + cMessage2
	     //Realiza a Transação TEF  - Administrativa 
	     oDlg:SetMessage(  cMessage + cMessage2,  oDlg:nPanel  , .F. ) 
         nNivel++
	     STFLdTTEF( @cLogTmp, aItem, oDlg, cLG_CODIGO,;
	     			lConecta, (nNivel * nEspaco))  
	     STFLdDTEF(oDlg, oDlg:nPanel, cLogTmp)
	     			
	     cLog += cLogTmp
			  
    EndCase
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFLdGrTEF
Função de Gravação dos Dados do TEF 2.0
@param oCfgTef		Configuração TEF
@param cLog	   		Log 
@param aItem		Item do Wizard TEF
@param oDlg			Janela		
@param nEspacos		Espaços do log	
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Gravado com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFLdGrTEF(oCfgTef, cLog, aItem, oDlg,;
					nEspacos)
Local lRet := .t.  //Retorno da gravação
  
DEFAULT oCfgTef := NIL  //Configurações TEF 2.0
DEFAULT cLog 	:= ""	//Log da Rotina
DEFAULT aItem 	:= {}	//Itens do Wizard
DEFAULT oDlg 	:= NIL  //Janela
DEFAULT nEspacos:= 5   	//Espacos
  
  	If ValType(oCfgTef) == "O" .And. ValType(aItem) =="A" .AND. ValType(oDlg) == "O"
  	
  		If !oCfgTef:TefVl(oCfgTef, @lRet)
			cLog += CRLF + space(nEspacos) + STR0026 + ; //"[ERRO] - Gravação do Registro TEF "
					CRLF + space(nEspacos+5) + STR0027 + oCfgTef:cMenssagem //"[ERRO] - "
			If !MsgYesNo(STR0028) //"Problemas na gravação.Editar o registro novamente ?"
				oCfgTef := FreeObj(oCfgTef)
				oDlg:SetPanel(aItem[5])
			EndIf
		Else
			oCfgTef:Salvar()
		EndIf   
	EndIf
	
Return 	lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} STFLdTTEF
Realiza a função de transação de Teste do TEF 2.0
@param cLog	   		Log 
@param aItem		Item do Wizard TEF
@param oDlg			Janela		
@param cLG_CODIGO	Codigo da Estacao
@param lConecta		Impressora Conectada?
@param nEspacos		Espaços do log	
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Gravado com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFLdTTEF( cLog, aItem, oDlg, cLG_CODIGO, ;
					lConecta, nEspacos)  

Local oTEF20 	:= STBGetTEF() 
Local lPrinter 	:= .F. //Objeto printer ativo
Local lRestore 	:= .F. //Restaura os servicos?       
Local oDados	:= NIL //Objeto da transacao TEF        
Local oRetTran	:= NIL  //Retorno da transação TEf
	  

DEFAULT cLog 		:= ""    //log da rotina
DEFAULT aItem 		:= {}   //Itens da funcionalidade
DEFAULT oDlg 		:= NIL  //Janela   
DEFAULT cLG_CODIGO 	:= ""	//Codigo da Estação 
DEFAULT lConecta 	:= .F.	//Impressora conectada  
DEFAULT nEspacos 	:= 5	//Espaços 
  

  If oTEF20== "O" 
  	STWCloseDevice(@oTEF20) //Fecha o objeto TEF para iniciá-lo novamente     
  	lRestore := .T.
  Else  
      If !Empty(cLG_CODIGO)

		oTEF20 := LJC_TEF():New(STFGetStat("CODIGO") ) 
		If !oTEF20:lAtivo
			cLog +=  CRLF + space(nEspacos) + STR0029 //"[ERRO] - Problemas ao iniciar TEF "
		Else
		     //Senão inicia a transação administrativa
		     lPrinter := !Empty(STFGetStat("PORTIF")) .AND. !Empty(STFGetStat("IMPFISC"))
		     //Envia comando para abrir a impressora
		     If lPrinter .AND. !lConecta
				lPrinter := STFWzCIF(STFGetStat("IMPFISC"), STFGetStat("PORTIF"), @cLog, nEspacos) 		     
		     EndIf 

   			oDados := LJCDadosTransacaoADM():New(0,0, Date(), Time(), .T.)  
   			oRetTran := oTEF20:Cartao():FuncoesAdm(oDados)

   		
				If oRetTran:oRetorno:lTransOk 
				
				    If  oRetTran:oRetorno:oViaCaixa:Count() > 0 .OR. oRetTran:oRetorno:oViaCliente:Count() > 0 

						oTEF20:Cupom():Inserir("G",	oRetTran:oRetorno:oViaCaixa,oRetTran:oRetorno:oViaCliente,	"A",;
			   							   "",		""	,					oRetTran:nValor,			1,;
											0)
	
	                    cLog += CRLF + space(nEspacos) +  STR0030 //" - Transação Administrativa realizada."
	                    If oTEF20:Cupom():Imprimir()
	                    	cLog += CRLF + space(nEspacos) +  STR0031    //"- Impressão Transação Administrativa.."
	                    	oTEF20:Desfazer()
	                    Else
	                    	cLog += CRLF + space(nEspacos) +  STR0032   //"[ERRO] - Impressão Transação Administrativa."
	                    	oTEF20:Desfazer()
	                    EndIf
                    
                    Else   
                    	cLog += CRLF + space(nEspacos) +  STR0030 //" - Transação Administrativa realizada."
                    	oTEF20:Desfazer()
                    EndIf

				Else
					cLog += CRLF + space(nEspacos) +  STR0033 //"[ERRO] - Transação Administrativa."
					oTEF20:Desfazer()
				EndIf 
		     
		     oDados := FreeObj(oDados)
		     STWCloseDevice(@oTEF20)
		EndIf 
	EndIf 
  EndIf 
  
       
  If lRestore
  		STWOpenDevi(@oTEF20)
  EndIf
  
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzDtIF
Carrega os dados cadastrados na estação
@param cLG_CODIGO	Codigo da Estacao
@param cImpFisc		Impressora Fiscal
@param cPorta		Porta de Comunicação
@param cPDV			Numero do PDV
@param cTamSer		Tamanho do COO
@param aImpFisc		Array com os modelos de Impressoras Fiscais
@param aPortas		Array com as portas
@param lConecta		Impressora Conectada?
@param cSerie		Numero de fabricação
@param cLog	   		Log 
@param nEspacos		Espaços do log	
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Execução da rotina com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 

Function STFWzDtIF( cLG_CODIGO, cImpFisc, cPorta, cPDV, ;
					cTamSer, 	aImpFisc, aPortas, 	lConecta, ;
					cSerie	, cLog,		nEspacos)  
					 

Local aDados  	:= {}  	//Retorno do Strategy
Local aRet 		:= {}	//Retorno da Execução da Rotina 
Local aAreaSLG	:= SLG->(GetArea()) //WorkArea SLG 
Local lRet		:= .t.   //Retorno da Rotina
  
DEFAULT cLG_CODIGO 	:= SLG->(CriaVar("LG_CODIGO")) //Codigo da Estacao 
DEFAULT cImpFisc 	:= ""							//Impressora Fiscal	
DEFAULT cPorta	 	:= ""							//Porta de Comunicação
DEFAULT cPDV		:= ""							//Numero do PDV 
DEFAULT cTamSer 	:= ""							//Numero do COO
DEFAULT aImpFisc 	:= {}							//Array de Impressoras Fiscais
DEFAULT aPortas  	:= {}							//Portas de Comunicação	  
DEFAULT cSerie 		:= ""							//Numero de Fabricacao
DEFAULT cLog		:= ""							//Log da Rotina
DEFAULT nEspacos 	:= 15							//Espacos do log da rotina

	aPortas :=  {"COM1", "COM2", "COM3", ;
		"COM4"	, "COM5", "COM6"	}   
	
	cLog += CRLF + space(nEspacos) + STR0034 //" - Localizando configurações da Estação."
	
	SLG->(DbSetOrder(1))
	If SLG->(DbSeek(xFilial() + cLG_CODIGO))
		cImpFisc := SLG->LG_IMPFISC
		cPorta	 := SLG->LG_PORTIF
		cPDV	 := SLG->LG_PDV  
		cTamSer	 := SLG->LG_TAMSER
		cSerie   := SLG->LG_SERPDV 			
	EndIf

   If !Empty(cLG_CODIGO) .AND. SLG->(FieldPos("LG_ISPOS") )  > 0  .AND. SLG->LG_ISPOS == "1" 
        
   		//Carrega os Dados da Estação
	    aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 					"STCheckDLL",;// Nome do evento
	 					{.T.} )
   
   		cLog += CRLF + space(nEspacos) + STR0035  //" - Buscando modelos de Impressoras Fiscais."

   		aDados := {space(5000), .t.}
	    STFFireEvent(	ProcName(0) ,;		// Nome do processo
	 					"STListPrint",;// Nome do evento
	 					aDados )  
		
		aImpFisc := LJStrToArr(AllTrim(aDados[1]))
		aSort(aImpFisc, ,, { |x,y| x< y})   
   	
   Else
   	   //	MsgAlert(STR0036 + xNumCaixa() + STR0037) //"O usuário "###" não possui privilégicos de caixa ."
   	   MsgAlert("O Wizard somente é aplicável a estação com POS") 
   			lRet := .F.    
   	  	cLog += CRLF + space(nEspacos) + "O Wizard somente é aplicável a estação com POS" //"[ERRO] - O usuário "###" não possui privilégicos de caixa ."
   EndIf 
   RestArea(aAreaSLG)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdIF
Função para atualização dos dados da Estação
@param cLG_CODIGO	Codigo da Estacao
@param cImpFisc		Impressora Fiscal
@param cPorta		Porta de Comunicação
@param cPDV			Numero do PDV
@param cTamSer		Tamanho do COO
@param aImpFisc		Array com os modelos de Impressoras Fiscais
@param aPorta		Array com as portas
@param oDlg			Janela
@param nPanel		Painel da rotina
@param lConectado	Impressora Conectada?
@param cSerie		Numero de fabricação
@param cLog	   		Log 
@param nEspacos		Espaços do log	
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Execução da rotina com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFWzLdIF(cLG_CODIGO, cImpFisc, cPorta, cPDV, ;
					cTamSer, aImpFisc, aPorta, oDlg, ;
					nPanel, lConectado, cSerie,cLog,;
					 nEspacos)    
					
Local lRet 		:= .T. 	// Retorno da Função  
Local nRow 		:= 0	//Linha
Local nCol		:= 0	//Coluna
Local nRow1 	:= 0	//Linha 1    
Local oPanel	:= NIL	//Panel    
Local oBtn1 	:= NIL	//Botao 1
Local oBtn2 	:= NIL	//Botao 2
Local oBtn3 	:= NIL	//Botao 3 
Local oBtn4 	:= NIL	//Botao 4
Local oBtn5 	:= NIL	//Botao 5
Local oBtn6 	:= NIL	//Botao 6    
Local aItens	:= {}	//Itens
Local nC		:= 0	//Contador      
Local oSayConn 	:= NIL //Objeto say que indicará se o componente está conectado         
Local oSayCon2 	:= NIL	//Objeto Say
Local oMemECF	:= NIL	//Resultado dos Dados do ECF
Local aObjects 	:= {}	//Objetos da Janela      
Local cDadosImp := "" //Dados da Impressora Fiscal   
Local cEcfCoo 	:= ""	//Tamanho do COO
Local cECFPDV 	:= ""	//PDV
Local cECFCNPJ 	:= ""	//CNPJ do ECF
Local cECFData 	:= ""	//Data do ECF
Local cECFNFAb 	:= ""	//Numero de Fabricacao do ECF 
Local cECFModelo:= ""	//Modelo do ECF
Local cECFPorta := ""	//Porta do ECF
Local cDadosECF	:= ""	//Dados do ECF  
Local aCampos 	:= {"cImpFisc", "cPorta", "cPDV", "cTamSer", "cSerie"}    
Local lEdiTed 	:= .F.   //Editado      
Local cCNPJ 	:= SM0->M0_CGC  //CNPJ da Empresa  

DEFAULT lConectado := .F.
DEFAULT cLG_CODIGO 	:= SLG->(CriaVar("LG_CODIGO")) //Codigo da Estacao 
DEFAULT cImpFisc 	:= ""							//Impressora Fiscal	
DEFAULT cPorta	 	:= ""							//Porta de Comunicação
DEFAULT cPDV		:= ""							//Numero do PDV 
DEFAULT cTamSer 	:= ""							//Numero do COO
DEFAULT aImpFisc 	:= {}							//Array de Impressoras Fiscais
DEFAULT aPorta  	:= {}							//Portas de Comunicação	  
DEFAULT oDlg		:= NIL							//janela
DEFAULT nPanel		:= 1							//Painel
DEFAULT cSerie 		:= ""							//Numero de Fabricacao
DEFAULT cLog		:= ""							//Log da Rotina
DEFAULT nEspacos 	:= 15							//Espacos do log da rotina	

	aItens := { { "S", STR0039, TamSx3("LG_IMPFISC")[1]},; //"Modelo da Impressora Fiscal"
				{ "L", "cImpFisc", NIL, TamSx3("LG_IMPFISC")[1]+50, aImpFisc, STR0039, { |U| Iif(PCOUNT() > 0, (  cImpFisc := U, lEdited := .T.), cImpFisc)}, .F. } ,; //"Modelo da Impressora Fiscal"
	            { "S", STR0040, TamSx3("LG_PORTIF")[1]},; //"Porta de Comunicaçao"
	            { "L", "cPorta"	 , NIL,  TamSx3("LG_PORTIF")[1]+5, aPorta, STR0040,  { |U| Iif(PCOUNT() > 0, (cPorta := U, lEdited := .T.), cPorta)} , .F.} ,; //"Porta de Comunicaçao"
	            { "S", STR0041 , TamSx3("LG_PDV")[1]},; //"Num PDV"
 	            { "G", "cPDV"	 , NIL,  TamSx3("LG_PDV")[1], , "Num PDV",  { |U| Iif(PCOUNT() > 0, (cPDV := U, lEdited := .T.), cPDV)} , .F.} ,;
 	            { "S", "Tam COO"},;
  	            { "G", "cTamSer"	 , NIl,  TamSx3("LG_TAMSER")[1], , STR0042,  { |U| Iif(PCOUNT() > 0, (cTamSer := U, lEdited := .T.), cTamSer)} , .F.},; //"Tam Coo"
  	            { "S", STR0043, TamSX3("LG_SERPDV")[1]},; //"Numero de Fabricação"
  	            { "G", STR0044	 , NIl,  TamSx3("LG_SERPDV")[1], , STR0045,  { |U| Iif(PCOUNT() > 0, (cSerie := U, lEdited := .T.), cSerie)}, .T. } }      //"Serie"###"Número de Fabricação"
		
 	oPanel := oDlg:GetPanel(nPanel)
	
	nRow		:= Int((oPanel:nHeight ) / 2)  //Linha do Painel
	nCol		:= Int((oPanel:nWidth ) / 2)   //Coluna do Painel
	nRow1 := nRow-40 
                      
	oPanel2 := TScrollBox():New( oPanel, 0,0,nRow1,nCol)


    @0,0 to nRow1, nCol
   
    For  nC := 1 to Len(aItens)  
    	IF aItens[nC, 1] == "S" //.OR. aItens[nC, 1] == "L"
    		nTam := CalcFieldSize("C",Len(aItens[nC,02]),0,"",aItens[nC,02]) 
    	Else 
    		nTam := CalcFieldSize("C",aItens[nC,04],0,"",aItens[nC,02]) 
    	EndIf
    	aAdd(aObjects,  { nTam, IIF(aItens[nC, 1] == "S", 6, 10), .F., .F.}) 
    Next 
    
    //Label do Objeto conectado   
    nTam := CalcFieldSize("C",Len(STR0046)+10,0,"",STR0046) //"Objeto Conectado"###"Objeto Conectado"
    aAdd(aObjects,  { nTam, 10, .F., .F.}) //Linha em Branco
    aAdd(aObjects,  { nTam, 10, .F., .F.}) //Say da Conexão do ECF
    aAdd(aObjects,  { nTam, 10, .F., .F.}) //Linha em Branco
    aAdd(aObjects,  { nTam, 10, .F., .F.}) //Say da Conexão do ECF    
    nTam := CalcFieldSize("C",110,0,"@!",STR0047)  //"Dados do ECF"
  	aAdd(aObjects,{nTam ,5*10 , .F., .F.} )//Impar Say

    
    aPosObj := MsObjSize( { 0 , 15 , nRow1 ,nCol, 0, 3,3,3}, aObjects, .T., .F.)
	
    
	For nC := 1 to Len(aItens)
                                   
		cVariable := aItens[nC][02] 
 		cGet := "{ |U| Iif(PCOUNT() > 0, "+cVariable+" := U, "+cVariable+")} "

  		
  		Do Case
  		Case aItens[nC, 01] == "S" //Objeto Say    
  			tSay():New( aPosObj[nC, 1],  aPosObj[nC, 2]  , &("{ || '" + aItens[nC, 02] + "' } "),oPanel2,,,,,,.T.,,,  ,  )

  		
  		Case aItens[nC, 01] == "G" //Objeto GET   

			 aItens[nC, 03] := TGet():New( aPosObj[nC, 1],aPosObj[nC, 2],aItens[nC, 07],oPanel2,aObjects[nC, 01],,,       /*&(cBlkVld)*/,,,, .T.,, .T.,, .T.,            , .F., .F.,, aItens[nC, 8], .F. ,,cVariable,,,,.T.,) 
  		Case aItens[nC, 01] == "L" //Objeto Lista 
		 	 aItens[nC, 03] := TComboBox():New( aPosObj[nC, 1],aPosObj[nC, 2], aItens[nC, 07], aItens[nC, 05], aObjects[nC, 01], aObjects[nC, 02], oPanel2, ,,       ,,,.T.,,,.F.,,.T.,,,,cVariable)

  		
  		EndCase
                                                                                          
	Next
 
        nC := nC + 1
	 	oSayConn:= 	tSay():New( aPosObj[nC, 1],  aPosObj[nC, 2]  , { || IF(lConectado, STR0048, STR0049)  },oPanel2,,,,,,.T.,,,  ,  ) //"Impressora Conectada"###"Impressora Desconectada"
   		nC := nC + 2
	 	oSayCon2:= 	tSay():New( aPosObj[nC, 1],  aPosObj[nC, 2]  , { ||  STR0047  },oPanel2,,,,,,.T.,,,  ,  ) //"Dados do ECF"
		nC := nC + 1
		oMemECF := 	TMultiGet():New(aPosObj[nC, 1],aPosObj[nC, 2],{ |U| Iif(PCOUNT() > 0, cDadosECF := U, cDadosECF)},oPanel2,;
										aObjects[nC, 01],aObjects[nC, 02],/*oFont*/,.F.,;
										/*nClrFore*/,/*nClrBack*/,/*oCursor*/,.T.,;
										/*cMg*/,.T.,,/*lCenter*/,;
										/*lRight*/,.T.,,/*bChange*/,;
										,.F., .T.)

	
	@nRow1+3, 0 TO nRow, nCol OF oPanel PIXEL

	oBtn2 := 	TButton():New( nRow1+8, 05, STR0050,oPanel,{||  STFWzIIF(@cImpFisc, @cPorta, @cLog, aPorta, nEspacos, @lConectado) , cECFModelo := cImpFisc , cECFPorta := cPorta , oBtn1:Refresh( ), oSayConn:Refresh() },55,15,,,.F.,.T.,.F.,,.F.,{ || .T. },,.F. ) //"Identificar Modelo"

	oBtn1 := 	TButton():New( nRow1+8, 070, STR0051,oPanel,{|| cDadosECF := "" , lConectado :=  STFWzCIF(cImpFisc, cPorta, @cLog, nEspacos) , oBtn3:Refresh(), oSayConn:Refresh() , oSayCon2:Refresh() , oMemECF:Refresh() },55,15,,,.F.,.T.,.F.,,.F.,{ || !Empty(cImpFisc) .AND. !Empty(cPorta) },,.F. ) //"Conectar"

	oBtn3 := 	TButton():New( nRow1+8, 145, STR0052,oPanel,{|| IIF(lConectado, STFWzDIF(  cImpFisc, 	cPorta, 	cPDV , 		cTamSer, ; //"Capturar Dados"
																									cCNPJ, 		cSerie, 	@cEcfCoo, 	@cECFPDV, ;
																									@cECFCNPJ, @cECFData, 	@cECFNFab, 	@cDadosECF,;
																									@cLog,		nEspacos), MsgInfo(STR0053) ), oSayCon2:Refresh(), oMemECF:Refresh() },55,15,,,.F.,.T.,.F.,,.F.,{ || lConectado },,.F. ) //"ECF não Conectado"
	
	oBtn4 := 	TButton():New( nRow1+8, 220, STR0054,oPanel,{|| STFWzUIF(@cImpFisc, 	@cPorta, 	@cPDV , 	@cTamSer,; //"Atualizar Dados"
																					@cSerie, 	cEcfCoo, 	cECFPDV, 	cECFModelo,;
																					cECFPorta,  cECFNFab, 	aCampos,  	aItens,;
																					@cLog, nEspacos ), lEdiTed:= .T. , oBtn5:Refresh() },55,15,,,.F.,.T.,.F.,,.F.,{ || lConectado .AND. (!Empty(cEcfCoo) .OR. !Empty(cECFPDV) )  },,.F. )

	oBtn5 := 	TButton():New( nRow1+8, 295, STR0055,oPanel,{|| STFWzRIF(cLG_CODIGO,	cImpFisc,	cPorta,	cPDV ,; //"Gravar Dados"
																				cTamSer, 	cSerie,		@cLog, 	nEspacos), lEdited := .F., oBtn4:Refresh() },55,15,,,.F.,.T.,.F.,,.F.,{ || lEdiTed  },,.F. )
    


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzIIF
Função para identificação do ECF
@param cLG_CODIGO	Codigo da Estacao
@param cImpFisc		Impressora Fiscal
@param cPorta		Porta de Comunicação
@param cLog	   		Log 
@param aPortas		Array com as portas
@param lConecta		Impressora Conectada?
@param nEspacos		Espaços do log	
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Execução da rotina com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzIIF(cImpFisc, cPorta, cLog, aPortas, ;
						 nEspacos, lConecta) 
Local aRet 		:= {}	//Array de retorno
Local aDados  	:= {}	//Dados de retorno do ECF
Local nI 		:= 0  	//Contador
Local nP 		:= 0	//Contador
Local cGetCliDir:= GetClientDir() //Diretorio do Smart client
Local nFabr 	:= 0	//Fabricante   
Local aImpFisc 	:= {}	//Array de modelos de Impressora Fiscal
Local lRet		:= .T.	//Retorno da rotina 
Local nPortas   := 1	//quantidade de Portas 
Local lAchou    := .F. 	//ECF localizado
Local nPos 		:= 0	//Posicao
Local cTmp		:= ""	//Variavel temporaria      
Local aFabricDLL := {						;  
					{"DARUMA", .T., .F., GetClientDir() + "DARUMA32.DLL","DARUMA FS2000 - V. 01.00" }, ;
					{"SWEDA", .F., .F., GetClientDir() + "CONVECF.DLL","SWEDA IF ST120 - V. 01.00.01" } , ;
					{"BEMATECH", .F., .F., GetClientDir() + "BEMAFI32.DLL","BEMATECH MP-3000 TH FI V01.01.01"  }, ; 						
					{"EPSON", .F., .F.,  GetClientDir() + "INTERFACEEPSON.DLL","EPSON TM-H6000 FBII V01.07.00"},;						
					{"LOGGER", .T.,  .F., "","URANO ZPM 200"},;						
					{"ITAUTEC ZPM", .T.,  .F., GetClientDir() + "RFDZPMAPI.DLL","ITAUTEC ZPM-300 256M PRT41 V01.03.00"},;	
					{"IBM", .F.,   .F., GetClientDir() + "IBMFI32.DLL","IBM 4610-KN4 V01.00.02"},;  
					{"ITAUTEC", .T.,  .F., GetClientDir() + "RFDBFIAPI.DLL","ITAUTEC QW PRINTER 6000 MT2 V01.00.05"};
					 } //Principal DLL do Fabricante
Local nPosLogger := aSCan( aFabricDLL, { |f| f[1] == "LOGGER"}) //Posicao do Fabricante Logger (3 dlls)

DEFAULT cImpFisc := ""
DEFAULT cPorta := ""
DEFAULT cLog := ""
DEFAULT nEspacos := 5     
DEFAULT aPortas := {}  
DEFAULT lConecta := .F.
	
	nFabr := Len(aFabricDLL)
	
	//Carrega o Diretorio system 
	aDados := { space(100)}
	aRet :=	STFFireEvent(		ProcName(0)																,;		// Nome do processo
												"STSystemDirectory"																,;		// Nome do evento
												aDados ) 
				    
					
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])	 
		cTmp := aDados[1] 
		aFabricDLL[nPosLogger, 4] := {cTmp+"\DLLG2.DLL", cTmp+"\LEITURA.DLL", cTmp+"\ATO17.DLL"}
	EndIf   
	
	aDados := {}

	// MSGRUN
    For nI := 1 to nFabr 
    	If ValType(aFabricDLL[nI,04]) == "C"
    		aFabricDLL[nI, 03] := File(aFabricDLL[nI,04]) 
    	Else 
    		aFabricDLL[nI, 03] := .T.
    		aEval(aFabricDLL[nI,04], { | l|   aFabricDLL[nI, 03] :=  aFabricDLL[nI, 03]  .AND. File(l)} )
    	EndIf
    Next 		
     
    cLog += CRLF + space(nEspacos) + STR0035  //" - Buscando modelos de Impressoras Fiscais."
     
   	aDados := {space(5000), .t., .T.}
    STFFireEvent(	ProcName(0) ,;		// Nome do processo
 					"STListPrintCod",;// Nome do evento
 					aDados )  
	
	aImpFisc := LJStrToArr(AllTrim(aDados[1]))
	nFabr := Len(aImpFisc)
 
		
	For nI := 1 to nFabr
	
		aImpFisc[nI] := StrTokArr(aImpFisc[nI], "|")
		aImpFisc[nI,1] := StrTran(aImpFisc[nI,1], '"')
		aImpFisc[nI,2] := StrTran(aImpFisc[nI,2], '"')
		//Quebra a primeira coluna por Fabricante + Marca + versão de Dll
		cTmp := aImpFisc[nI,1]
		aImpFisc[nI,1] := {"","","",cTmp}
		nP := At(space(1), AllTrim(cTmp) ) -1
		aImpFisc[nI,1, 1] := Upper(Substr(cTmp, 1,  nP)) 
 		cTmp := AllTrim(StrTran(Substr(cTmp, nP + 1), "."))
        
        nP :=  Len(cTmp)
		Do While IsDigit(Substr(cTmp,nP, 1))
			nP--
		EndDo
		If nP <> Len(cTmp) //Achou numeros
			aImpFisc[nI, 1, 3] := Substr(cTmp, nP+1) 
			cTmp := AllTrim(Substr(cTmp, 1, nP))
			If Right(cTmp, 1) == "V"
				cTmp := AllTrim(Left(cTmp, Len(cTmp) -1))  
				If Right(cTmp, 1) == "-" 
					cTmp := AllTrim(Left(cTmp, Len(cTmp) -1))
				EndIf
			EndIf
        EndIf
        aImpFisc[nI, 1, 2] := StrTran(StrTran(cTmp,"-"), space(1))         
			  	
	Next nI
  	aSort(aImpFisc, ,, { |x,y| x[1,1] + x[1,2] + x[1,3] < y[1,1] + y[1,2] + y[1,3] })

	nFabr := Len(aFabricDLL	)
	For nI := 1 to nFabr 
		If aFabricDLL[nI, 03]  //Dll Exist
			//Conecta no modelo
			 //nPortas := 1
			nPos := 0 
			nPortas := IIF( aFabricDLL[nI, 02 ], Len(aPortas), 1) //Conecta pela porta  

			For nP := 1 to nPortas
	     		cPorta := aPortas[nP] 
	     		
	     		MsgRun(STR0056 + cPorta + STR0057 + aFabricDLL[nI, 01] + "] ", STR0058 , { || lConecta := 	STFWzCIF(aFabricDLL[nI, 05], cPorta, @cLog, nEspacos) })		// Nome do processo //"Conectando Porta ["###"] Fabricante ["###"Aguarde.... "
  

						
				If lConecta
					Exit
				EndIf 
				
				aRet :=	STFFireEvent(		ProcName(0)																,;		// Nome do processo
												"STCloseCom"																,;		// Nome do evento
												{cPorta }  ) 
				
			Next 
			
			If lConecta
				//Achou a Porta
				//Verifica no modelo
				aDados := { "45", space(6) }  // TO DO: Marca
				aRet :=	STFFireEvent(	ProcName(0)	,;		// Nome do processo
								"STPrinterStatus",;																	// Nome do evento
								aDados )  
				
				If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 1
				   If !Empty(aDados[2])
				   	   nPos := aScan(aImpFisc, { |i| AllTrim(i[2]) == AllTrim(aDados[2])})  
				   	   lAchou := (nPos > 0)
				   EndIf 
				   
				   If !lAchou		//
				   		//lAchou
						aDados := { "46", space(100) }  // TO DO: Marca
						aRet :=	STFFireEvent(	ProcName(0)	,;		// Nome do processo
										"STPrinterStatus",;																	// Nome do evento
										aDados )  //Fabricante + Modelo + Versão
						
						If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 1
						   If !Empty(aDados[2])
						   	  lAchou  := STFWzIISF( aImpFisc, aDados[2], @nPos, 3) //Busca Marca modelo e FirmWare
						   Else 
								lAchou := .F.
						   EndIf
						EndIf
				   EndIf
				EndIf

				If lAchou   
					cImpFisc := aImpFisc[nPos, 1, 4]
					Exit
				Else
					aRet :=	STFFireEvent(		ProcName(0)																,;		// Nome do processo
												"STCloseCom"																,;		// Nome do evento
												{cPorta }  ) 

				EndIf
			EndIf

	
		EndIf 
	Next nI
		
		If !lAchou
   			cLog += CRLF + space(nEspacos) + STR0059 //" - [ERRO] Impressora não detectada. Verifique se a mesma encontra-se ligada e/ou conectada no computador"
			MsgInfo(STR0060) //"Impressora não detectada. Verifique se a mesma encontra-se ligada e/ou conectada no computador"
		Else
			cLog += CRLF + space(nEspacos) + STR0061 + cImpFisc + STR0062 + cPorta + "]" //" - Localizada Impressora "###"] na porta ["
			
		EndIf	 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzIISF
Função para seleção do modelo de ECF
@param aImpressoras	Array com os modelos de Impressoras Fiscais
@param cNomeDLL		Nome do modelo retornado pela DLL
@param nPos			Posição do Modelo no Array de Modelos de ECF
@param nNivel	   	Nivel de Busca 3 - Fabricante + Modelo + DLL , 2- Fabricante + Modelo, 1 - Fabricante 
@param cFabricDLL	Nome do Fabricante retornado pelo ECF
@param cModeloDLL	Nome do Modelo retornado pelo ECF
@param cVerDLL		Versão da DLL retornada pelo ECf
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet Localizou o ECF?
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzIISF(aImpressoras, cNomeDLL, 	nPos, nNivel, ;
							cFabricDLL, cModeloDLL, cVerDLL )
							 
Local lAchou 		:= .F.  //Localizou op ECF?
Local cFabric 		:= ""   //Fabricante
Local cModelo 		:= "" 	//Modelo
Local cDLL 			:= ""	//DLL 
Local cTmp 			:= ""	//Temporária
Local nC 			:= 0  	//contador
Local aImpTmp 		:= {} //Impressoras Selecionadas 
Local bCond			:= { | l |  l[1,1] == cFabricDLL .AND. l[1,2] == cModeloDLL .AND. l[1,3] == cVerDLL} 
Local aListaImp 	:= {} 	//Lista de impressoras do Fabricante
	
DEFAULT aImpressoras 	:= {}	//Lista de modelos de impressoras fiscais
DEFAULT cNomeDLL 		:= "" 	//Nome do Modelo de Impressora Fiscal retornado pela DLL
DEFAULT nPos 			:= 0	//Posicao do Modelo de Impressora Fiscal Selecionado
DEFAULT nNivel 			:= 0	//Nivel de busca  
DEFAULT cFabricDLL 		:= ""	//Fabricante retornado pelo ECF	
DEFAULT cModeloDLL 		:= ""	//Modelo retornado pelo ECF
DEFAULT cVerDLL 		:= ""	//Versão retornada pelo ECF
DEFAULT aImpTmp 		:= {}	//Array dos modelos, conforme o fabricante
	
	If !Empty(cNomeDLL) 
	
		If Empty(cFabricDLL)
			nC :=  At(space(1), cNomeDLL) 
			cNomeDLL := Upper(cNomeDLL)
			cFabricDLL := AllTrim(Substr(cNomeDll, 1, nC-1))    			
			cTmp := Substr(cNomeDll, nC+1) 
			If At(cFabricDLL, cTmp)  > 0 
				//Ajusta o nome da dll 
				cTmp := StrTran(cTmp, cFabricDLL)
				cNomeDLL := cFabricDLL + " " + AllTrim(cTmp)
			EndIf
			If (nC := At(" - V.", cTmp) ) > 0 
			   cModeloDLL := StrTran(StrTran(SubsTr(cTmp, 1, nC-1),"-") , space(1))
			   cTmp := SubsTr(cTmp, nC+5)
			   If !Empty(cTmp) 
			   		cVerDLL := AllTrim(StrTran(cTmp, "."))
			   Else
			   		nNivel := 2 
			   		bCond	:= { | l |  l[1,1] == cFabricDLL .AND. l[1,2] == cModeloDLL } 
			   EndIf 
			Else
				cModeloDLL := AllTrim(cTmp) //somente o modelo	
				If nNivel > 2
					nNivel := 2 
					bCond	:= { | l |  l[1,1] == cFabricDLL .AND. l[1,2] == cModeloDLL }  
				EndIf
			EndIf
		EndIf
		
	
		
		While !lAchou .AND. nNivel > 0   
			
			lAchou := (nPos := aScan( aImpressoras, bCond) ) > 0    
			If lAchou .AND. nNivel <= 2
				//Filtra os níveis parecidos com o filtro e exibe para seleção
				aListaImp := {}
				Do While Eval(bCond, aImpressoras[nPos])  
					aAdd(aListaImp, {aImpressoras[nPos, 1, 4], aImpressoras[nPos, 1, 1], aImpressoras[nPos, 1, 2], aImpressoras[nPos,1,  3], nPos})
				    nPos++
				EndDo 
				If Len(aListaImp) > 0  
						
						nPos := STFWzIITF(aListaImp, cNomeDLL, cFabricDLL , cModeloDLL , cVerDLL)
						
						If nPos == 0
							lAchou := .F.
							Exit
						EndIf
						
				EndIf
			EndIf
			nNivel--  
			If nNivel == 2
				bCond	:= { | l |  l[1,1] == cFabricDLL .AND. l[1,2] == cModeloDLL } 
			Else 
				bCond	:= { | l |  l[1,1] == cFabricDLL } 
			EndIf
		EndDo
	EndIf    
	
Return  lAchou
 
//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzIISF
Função para seleção do modelo de ECF pelo usuário
@param aLstaImp		Array com os modelos de Impressoras Fiscais do Fabricante
@param cNomeDLL		Nome do modelo retornado pela DLL
@param cFabricDLL	Nome do Fabricante retornado pelo ECF
@param cModeloDLL	Nome do Modelo retornado pelo ECF
@param cVerDLL		Versão da DLL retornada pelo ECf
@author  Varejo
@version P11.8
@since   26/04/2013
@return  nPos		Posicao do Modelo Selecionado
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzIITF(aListaImp, cNomeDLL, cFabricDLL , cModeloDLL , ;
						  cVerDLL)
						  
Local oDlgSelImp 	:= NIL   //Janela
Local nPos 	   		:= 0  	//Posicao do Modelo
Local oList 		:= NIL	//Objeto Lista
Local cList 		:= "" 	//Modelo
Local aCoord   		:= MsAdvSize(.T.) //Coordenadas da janela

DEFAULT aListaImp 	:= {}	//Lista de Modelos do Fabricante
DEFAULT cNomeDLL 	:= ""	//Nome da DLL retornado pelo ECF
DEFAULT cFabricDLL 	:= ""	//Fabricante da DLL retornado pelo ECF
DEFAULT cModeloDLL 	:= ""	//Modelo da DLL retornado pelo ECF
DEFAULT cVerDLL 	:= ""	//Versçao da DLL retornado pelo ECF
					

		oDlgSelImp := TDialog():New(000,000,aCoord[6]/2,aCoord[5]/2,OemToAnsi(STR0063),,,,,,,,oMainWnd,.T.) //"Seleção da Administrador de Cartão de Crédito/Débito" //"Seleção do Modelo de Impressora Fiscal"
			
			TSay():New(005,003,{|| STR0064 + AllTrim(Upper(cNomeDLL))},oDlgSelImp,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,oDlgSelImp:nClientWidth/2-7,008) //"Identifique qual administradora do sistema é a administradora identificada a seguir: " //"Identifique qual o modelo de ECF é o identificado a seguir: "
			
			TGroup():New(015,003,oDlgSelImp:nClientHeight/2-30,oDlgSelImp:nClientWidth/2-7,STR0065,oDlgSelImp,,,.T.,.F. ) //"Lista das Administradoras Cadastradas" //"Lista das Impressoras Fiscais Cadastradas"
				
				oList := TWBrowse():New(026,005,oDlgSelImp:nClientWidth/2-15,oDlgSelImp:nClientHeight/2-58,,{STR0066,STR0067,STR0068,STR0069},,oDlgSelImp,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Tipo"#"Administradora" //"Nome"###"Marca"###"Modelo"###"Versão DLL"
					
					oList:SetArray(aListaImp)
					oList:bLDblClick := {|| nPos := aListaImp[oList:nAT,5] }
			
 					oList:bLine := { || {aListaImp[oList:nAT,1], aListaImp[oList:nAT,2], aListaImp[oList:nAT,3], aListaImp[oList:nAT,4]}}


			TButton():New(oDlgSelImp:nClientHeight/2-27,003,OemToAnsi(STR0070),oDlgSelImp,{|| nPos := aListaImp[oList:nAT,5], oDlgSelImp:End() },040,010,,,,.T.,,,,{|| })    //"&Ok"
		
		oDlgSelImp:Activate(,,,.T.)

Return nPos

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzCIF
Função para conexão da Impressora Fiscal
@param cImpFisc		Modelo de Impressora Fiscal
@param cPorta		Porta de Conexao
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lConecta	Impressora Conectada
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzCIF(cImpFisc, cPorta, cLog, nEspacos) 
	Local aRet := {}
	Local lConecta := .T.

	
	
	DEFAULT cImpFisc := ""
	DEFAULT cPorta := ""
	DEFAULT cLog := ""
	DEFAULT nEspacos := 5
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
							"STOpenCom"																,;		// Nome do evento
							{AllTrim(cImpFisc)													,;	
							AllTrim(cPorta),;
							 .F.} )
	
   	If !(lConecta :=  Len(aRet) > 0 .AND. aRet[1] = 0 )
	
		STFMessage("STWOpenDevi", "STOP", STR0071) //"Falha no Comando de Abertura e Selecao da Porta"
		STFShowMessage("STWOpenDevi")
						
	EndIf     
	
	cLog +=  CRLF + space(nEspacos) +  IIF(lConecta, "", STR0072 ) + STR0073+AllTrim(cImpFisc)+STR0019 +cPorta+"]" //"[ERRO]"###" - Conectando Impressora Fiscal ["###"] Porta["

Return lConecta	

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzDIF
Função para retornar os dados da Impressora Fiscal
@param cImpFisc		Modelo de Impressora Fiscal
@param cPorta		Porta de Conexao
@param cPDV			Codigo do PDV
@param cTamSer		Tamanho do COO
@param cCNPJ		CNPJ
@param cSerie       Numero de Fabricacao
@param cECFCOO		Tamanho do Numero do COO do ECF
@param cECFPDV		Numero do PDV do ECF
@param cECFCNPJ		CNPJ do ECF
@param cECFData		Data/Hora do ECF
@param cECFNFab		Numero de Fabricação do ECF
@param cDadosECF	Dados do ECF
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzDIF(	cImpFisc, 	cPorta, 	cPDV , 		cTamSer,;
						 	cCNPJ, 		cSerie, 	cEcfCoo, 	cECFPDV, ;
						 	cECFCNPJ, 	cECFData, 	cECFNFab, 	cDadosECF,;
						 	cLog,		nEspacos)
						 	
Local aRet 		:= {}  	//Retorno do Stategy
Local aDados 	:= {}	//Dados retornados pelo ECF 
Local lDateOk	:= .t.	//Data correta     
Local cLogT 	:= ""	//Log Temporário 
Local lSucesso 	:= .T.	//Rotina Executada com sucesso  
Local nEspacoT 	:= 0	//Espaco temporario
Local cTxtTmp 	:= ""	//Texto temporario

DEFAULT cImpFisc 	:= "" 	//Modelo de Impressora fiscal
DEFAULT cPorta 		:= "" 	//Porta da Impressora fiscal
DEFAULT cPDV 		:= "" 	//Codigo do PDV
DEFAULT cTamSer 	:= "" 	//Numero do COO
DEFAULT cCNPJ 		:= ""	//CNPJ
DEFAULT cSerie 		:= ""	//Numero de Serie
DEFAULT cEcfCoo 	:= ""   //COO do ECF
DEFAULT cECFPDV 	:= ""   //PDV do ECF
DEFAULT cECFCNPj 	:= ""   //CNPJ do ECF	
DEFAULT cECFData 	:= ""	//Data do ECF 
DEFAULT cECFNFab 	:= ""	//Numero de Fabricacao do ECF
DEFAULT cDadosECF 	:= ""   //Dados do ECF
DEFAULT cLog 		:= ""   //log da rotina
DEFAULT nEspacos 	:= 5    //espacos

	cDadosECF := ""
	
	cEcfCoo := ""
	cECFPDV := ""
	cECFCNPJ := ""
	cECFData := ""
	cECFNFab := ""  
	
	nEspacoT := nEspacos + 5
   
   //PDV 
    cTxtTmp := STR0074 //"Número do PDV: "
  	//cDadosECF += 
	aDados := {space(20), Nil}
	aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STGetPDV"																,;		// Nome do evento
 													  aDados )
 													  
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
		cECFPDV := AllTrim(aDados[1])
		cTxtTmp += cECFPDV
		If AllTrim(cPDV) <> cECFPDV
			cTxtTmp += space(5) + STR0075 + cPDV +"]"    //"Difere do informado ["
			cLogT += CRLF + space(nEspacoT) + " - " + cTxtTmp  
		EndIf
		
		cDadosECF += cTxtTmp
	Else
		cDadosECF += STR0076 //"Não identificado"
	    cLogT += CRLF + space(nEspacoT) + STR0077 //"[ERRO] - Identificação do Número do PDV"
	EndIf
	cDadosECF += CRLF 
	
	//COO
	aDados := {space(20), nil}
	cTxtTmp := 	STR0078 //"Número do Cupom X Capacidade do COO: "

	aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "StGetReceipt"																,;		// Nome do evento
 													  aDados )
	
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
		cEcfCoo := AllTrim(aDados[1])
		
		cTxtTmp += cEcfCoo + " X " + Replicate("9", Len(cECFCoo))  
		If Len(AllTrim(cTamSer)) <> Len(cEcfCoo)
			cTxtTmp += space(5) + STR0075 + cTamSer +"]"  //"Difere do informado ["
			cLogT += CRLF + space(nEspacoT) + " - " + cTxtTmp 
		EndIf  
		
		cDadosECF += cTxtTmp
	Else
		cDadosECF += STR0076 //"Não identificado"
		cLogT += CRLF + space(nEspacoT) + STR0079 //"[ERRO] - Identificação do Númro do Cupom"
	EndIf
	
	cDadosECF += CRLF    
	
   	cTxtTmp := 	"CNPJ: "   
    aDados := {"20", space(20)}
	aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STPrinterStatus"																,;		// Nome do evento
 													  aDados )
	
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
    	cECFCNPJ := AllTrim(aDados[2])
    	cTxtTmp +=  cECFCNPJ  

    	If AllTrim(cCNPJ) <> StrTran(StrTran(StrTran(cECFCNPJ, "."), "/"), "-")
			cTxtTmp += space(5) + STR0080 + cCNPJ +"]"      //"Difere do cadastrado ["
			cLogT += CRLF + space(nEspacoT) + " - " + cTxtTmp 
		EndIf
    	
    	cDadosECF += cTxtTmp
	Else
		cDadosECF += STR0076   //"Não identificado"
		cLogT += CRLF + space(nEspacoT) + STR0081 //"[ERRO] - Identificação do CNPJ do ECF"
	EndIf 
	cDadosECF += CRLF  
	
	cTxtTmp := STR0082  //"NÚmero de Fabricação: "
    aDados := {space(30), Nil} 
	aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "StGetSerie"																,;		// Nome do evento
 													  aDados )

	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 0 .AND. !Empty(aDados[1])
		cECFNFab := AllTrim(aDados[1])
		cTxtTmp += cECFNFab   
		
		If AllTrim(cSerie) <> cECFNFab
			cTxtTmp += space(5) + STR0080 + cSerie +"]"   //"Difere do Cadastrado ["
			cLogT += CRLF + space(nEspacoT) + " - " + cTxtTmp 
		EndIf
		cDadosECF += cTxtTmp
	Else
		cDadosECF += STR0076 //"Não identificado"
		cLogT += CRLF + space(nEspacoT) + STR0083 //"[ERRO] - Identificação do Número de Fabricação"
	EndIf
	cDadosECF += CRLF  	
	

	aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STCheckHour"																,;		// Nome do evento
 													  {} ) 
    If Len(aRet) > 0 .AND. ValType(aRet[1]) == "L"
    	lDateOk := aRet[1]
    EndIf

	cTxtTmp := STR0084  	 //"Data e Hora: "
	
    aDados := {"2", space(20)}
	aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STPrinterStatus"																,;		// Nome do evento
 													  aDados )
	
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
    	cTxtTmp += AllTrim(aDados[2])
    	
     	aDados := {"1", space(20)}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STPrinterStatus"																,;		// Nome do evento
 													  aDados )   	
    	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
    		cTxtTmp += " " + AllTrim(aDados[2]) 
    		cDadosECF +=  cECFData   
    		If !lDateOK 
    			cTxtTmp +=  space(5) + STR0085 + DtoC(GetRmtDate() ) + " " + GetRmtTime() +"]" //"Divergem da data do computador ["
    			cLogT += CRLF + space(nEspacoT) + " - " + cTxtTmp 
    		EndIf
    	Else
    		cTxtTmp += STR0076  //"Não identificado"
    		cLogT += CRLF + space(nEspacoT) + STR0086 //"[ERRO] - Identificação da Hora do ECF"
    	EndIf 
    	cDadosECF += cTxtTmp
	Else
		cDadosECF += STR0076  //"Não identificado"
		cLogT += CRLF + space(nEspacoT) + STR0087 //"[ERRO] - Identificação da Data do ECF"
	EndIf 	
	
	cLog +=  CRLF + space(nEspacos) + IIF(lSucesso, "", STR0072 ) + " - " + STR0088 + cLogT //"[ERRO]"###"Capturando dados do ECF."
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzUIF
Função para atualizar os dados do ECf no Wizard
@param cImpFisc		Modelo de Impressora Fiscal
@param cPorta		Porta de Conexao
@param cPDV			Codigo do PDV
@param cTamSer		Tamanho do COO
@param cSerie       Numero de Fabricacao
@param cECFCOO		Tamanho do Numero do COO do ECF
@param cECFPDV		Numero do PDV do ECF
@param cECFModelo	Modelo do ECF
@param cECFPorta	Porta do ECF
@param cECFNFab		Numero de Fabricação do ECF
@param aCampos		Campos a serem atualizados
@param aItens		Itens do Wizard
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzUIF(cImpFisc, 	cPorta, 	cPDV , 		cTamSer,;
						 cSerie, 	cEcfCoo,  	cECFPDV, 	cECFModelo,;
						 cECFPorta, cECFNFab, 	aCampos,  	aItens,;
						 cLog	  , nEspacos)      //Verificando o campo - cImpFisc

Local nPos 		:= 0  //Posicao do item 
Local cCampo 	:= "" //Campo   
Local cCOO 		:= "" //COO
         
DEFAULT cImpFisc 	:= ""	//Modelo de Impressora Fiscal
DEFAULT cPorta 		:= ""	//Porta da Impressora Fiscal
DEFAULT cPDV 		:= ""	//Numero do PDV
DEFAULT cTamSer 	:= ""	//Tamanho do COO
DEFAULT cSerie 		:= ""	//Numero de Fabricacao
DEFAULT cECFCOO 	:= ""	//COO do ECF
DEFAULT cECFPDV 	:= ""	//PDV do ECF  
DEFAULT cECFModelo 	:= ""	//Modelo do ECF
DEFAULT cECFPorta 	:= ""	//Porta do ECF
DEFAULT cECFNFab 	:= ""	//Numero do Fabricacao
DEFAULT aCampos 	:= {"cImpFisc", "cPorta", "cPDV" , "cTamSer", "cSerie"}  //Campos
DEFAULT aItens 		:= {}   //Itens do Wizard    
DEFAULT cLog 		:= ""	//Log
DEFAULT nEspacos 	:= 5    //Espacos
      
      //Verifica se o modelo do ECF foi atualizado
      If !Empty(cECFModelo) .AND. AllTrim(cImpFisc) <> AllTrim(cECFModelo)
      		cImpFisc := PadR(cECFModelo, TamSX3("LG_IMPFISC")[1]) 
      		IF (nPos := aScan(aItens, { |c| c[2] == aCampos[1] } ) ) > 0
      			aItens[nPos, 03]:Refresh()
      		EndIf
      EndIf   


      //Verifica se a porta do ECF foi atualizada
      If !Empty(cECFPorta) .AND. AllTrim(cPorta) <> AllTrim(cECFPorta)
      		cPorta := PadR(cECFModelo, TamSX3("LG_PORTIF")[1])
      		IF (nPos := aScan(aItens, { |c| c[2] == aCampos[2] }) ) > 0
      			aItens[nPos, 03]:Refresh()
      		EndIf
      EndIf 
      
      //Verifica se o PDV foi atualizado
      If !Empty(cECFPDV) .AND. AllTrim(cPDV) <> cECFPDV
      		cPDV := PadR(cECFPDV, TamSX3("LG_PDV")[1]) 
      		IF (nPos := aScan(aItens, { |c| c[2] == aCampos[3] } ) ) > 0
      			aItens[nPos, 03]:Refresh()
      		EndIf
      EndIf 


      //Verifica se o numero de Sério foi atualizado 
      cCOO := Replicate("9", Len(cECFCoo))
      If !Empty(cECFPDV) .AND. AllTrim(cTamSer) <> cCOO
      		cTamSer := PadR(cCOO, TamSX3("LG_TAMSER")[1]) 
      		IF (nPos := aScan(aItens, { |c| c[2] == aCampos[4] }) ) > 0
      			aItens[nPos, 03]:Refresh()
      		EndIf
      EndIf 
      
      If !Empty(cECFNFab) .AND. AllTrim(cSerie) <> cECFNfab
      		cSerie := PadR(cECFNfab, TamSX3("LG_SERPDV")[1]) 
      		IF (nPos := aScan(aItens, { |c| c[2] == aCampos[5] } ) ) > 0
      			aItens[nPos, 03]:Refresh()
      		EndIf
      EndIf
      
      cLog := CRLF + space(nEspacos) + STR0089 //" - Atualizando dados na Janeça"
      
Return
 
//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzRIF
Função para atualizar o cadastro da estação
@param cLG_CODIGO   Codigo da Estação
@param cImpFisc		Modelo de Impressora Fiscal
@param cPorta		Porta de Conexao
@param cPDV			Codigo do PDV
@param cTamSer		Tamanho do COO
@param cSerie       Numero de Fabricacao
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Static Function STFWzRIF(cLG_CODIGO, cImpFisc,	cPorta, cPDV , ;
						 cTamSer, 	cSerie,		cLog,	nEspacos)

Local aArea := GetArea() //WorkArea Ativa
Local aAreaSLG := SLG->(GetArea()) //WorkArea SLG
    
DEFAULT cLG_CODIGO 	:= ""  	//Codigo da Estação
DEFAULT cImpFisc 	:= ""	//Impressora Fiscal
DEFAULT cPorta 		:= ""  	//Porta de Comunicação
DEFAULT cPDV 		:= "" 	//PDV
DEFAULT cTamSer 	:= ""  	//COO
DEFAULT cSerie 		:= ""  	//Numero de Fabricação
DEFAULT cLog 		:= ""  	//Log da rotina
DEFAULT nEspacos 	:= 5   	//Espacos

	 
	SLG->(DbSetOrder(1))
	If !Empty(cLG_CODIGO) .AND. SLG->(DbSeek(xFilial() + cLG_CODIGO))   
		RecLock("SLG", .F.)
		
		If !Empty(cImpFisc) .AND. AllTrim(cImpFisc) <>  AllTrim(SLG->LG_IMPFISC )
			SLG->LG_IMPFISC := cImpFisc    
		EndIf
		
		If !Empty(cPorta) .AND. AllTrim(cPorta) <>  AllTrim(SLG->LG_PORTIF)
			SLG->LG_PORTIF := cPorta
		EndIf
		
		If !Empty(cPDV) .AND. AllTrim(cPDV) <>  AllTrim(SLG->LG_PDV)
			SLG->LG_PDV :=  cPDV 
		EndIf  
		
		If !Empty(cTamSer) .AND. AllTrim(cTamSer) <>  AllTrim(SLG->LG_TAMSER)
			SLG->LG_TAMSER := cTamSer
		EndIf 	  
		          
		
		If !Empty(cSerie) .AND. AllTrim(cSerie) <>  AllTrim(SLG->LG_SERPDV)
			SLG->LG_SERPDV := cSerie
		EndIf
				
		
		SLG->(MsUnLock()) 
		cLog += CRLF + space(nEspacos)+ STR0090		 //" -  Cadastro de Estação atualizado."
	Else
		cLog += CRLF + space(nEspacos)+ STR0091 //" -  Estação não localizada."
	EndIf	
   		
   RestArea(aAreaSLG)
   RestArea(aArea)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdAIF
Função para carregar as alíquotas da Impressora Fiscal
@param cLG_CODIGO   Codigo da Estação
@param cImpFisc		Modelo de Impressora Fiscal
@param cPorta		Porta de Conexao
@param lConecta		ECF Conectado
@param aAliqICM		Alíquotas de ICM
@param aAliqISS     Alíquotas de ISS
@param aALiqECF     Alíquotas do ECF
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return	lRet		Execução com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFWzLdAIF(cLG_CODIGO,	cImpFisc,	cPorta,		lConecta,;
					aAliqICM, 	aAliqISS, 	aALiqECF,	cLog,;
					nEspacos ) 
					 
Local lRet 		:= .T.  //Retorno da rotina
Local aRet 		:= {} 	//Retorno do strategy      
Local aDados 	:= {} 	//Dados retornados pelo ECF
Local nC 		:= 0 	//Contador   
      
DEFAULT cLG_CODIGO 	:= ""	//Codigo da Estacao
DEFAULT cImpFisc 	:= ""	//Modelo de Impressora Fiscal
DEFAULT cPorta 		:= ""	//Porta de Comunicacao 
DEFAULT lConecta 	:= .T.	//Impressora Conectada
DEFAULT aAliqICM 	:= {}	//Aliquotas de ICMS
DEFAULT aAliqISS 	:= {}	//Aliquotas de ISS
DEFAULT aAliqECF 	:= {}   //Aliquotas de ECF
DEFAULT cLog 		:= "" 	//log da rotina
DEFAULT nEspacos 	:= 5	//Espacos
      
      aAliqICM := {} 
      aAliqISS := {}
      aAliqECF := {}                                                 
      
      
      If !lConecta 
        If Empty(cImpFisc) 
        
            cImpFisc := STFGetStat("IMPFISC")
      	EndIf
      	If Empty(cPorta)
      		cPorta := STFGetStat("PORTIF")
      	EndIf
      	
		lConecta := lRet := STFWzCIF(cImpFisc, cPorta, @cLog, nEspacos) 
 
      EndIf
      
      If lRet 
      		//Busca as Aliquotas de ICMS
           aDados := {space(100)} 
           aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
 									"STGetAliq"																,;		// Nome do evento 
 									aDados )
 													  
 		   If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0 
 		   	
 		   		aAliqICM := StrTokArr( aDados[1] , "|" )
 														 
           		aDados := {space(100)} 
           		aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
             						"STGetAliISS",;	
 			                         aDados )   
 			    If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0
 			    	 aAliqISS := StrTokArr( aDados[1] , "|" )
 			    Else
 			    	lRet := .F.
 			    EndIf                     
 			    
 			    cLog += CRLF + space(nEspacos) + IIF(lRet, "", STR0072) + STR0092 //"[ERRO]"###" - Capturando alíquotas de ICMS do ECF"
 			Else
 				lRet := .F. 
 				
 			EndIf
 			
 			cLog += CRLF + space(nEspacos) + IIF(lRet, "", STR0072) + STR0093												     		 //"[ERRO]"###" - Capturando alíquotas de ISS do ECF"
      		
      	   //Busca as Aliquotas de ISS	
      EndIf

      If lRet
      	aEval(aAliqICM, { |a| IIF(Val(a) > 0, (nC := nC + 1, aAdd(aALiqECF, {StrZero(nC, 2),"1", Val(a)} )), NIL )})  
      	aEval(aAliqISS, { |a| IIF(Val(a) > 0, (nC := nC + 1, aAdd(aALiqECF, {StrZero(nC, 2), "2", Val(a)} )), NIL )})
      EndIf   
      
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdAP
Função para carregar as alíquotas da Impressora Fiscal
@param cLG_CODIGO   Codigo da Estação
@param aAliqPtr		Alíquotas do Protheus
@param aALiqECF     Alíquotas do ECF
@param oDLG			Janela
@param nPanel		Panel atual
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return	lRet		Execução com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFWzLdAP(cLG_CODIGO,	aAliqPtr,	aAliqECF,	oDlg,;
					nPanel,		cLog,		nEspacos)
					   
	Local aArea := GetArea()
	Local aAreaMFD := MFD->(GetArea()) 
	Local lRet := .T.  
	Local cStatus := ""
	Local cSFI	  := ""
	Local cCampos	:= "" //Codigo dos campos     
	Local cFilMFD := MFD->(xFilial())
	
	
	MFD->(DbSetOrder(1)) //MFD_FILIAL
	MFD->(DbSeek(cFilMFD))
	
	Do While MFD->(!Eof()) .and. MFD->MFD_FILIAL == cFilMFD
		cStatus := "1"  //Não programado
		If MFD->(aScan(aAliqECF, {|e| e[2] == MFD_IMPOST .AND. e[3] == MFD_ALIQ }))  > 0
			cStatus := "2" //Programado
		EndIf
		
		//Verifica se o Campo Existe na SFI
		//Tipo de Imposto
		//Alíquota    
		cCampos := ""
		cSFI := STFWzLdCAP(MFD->MFD_IMPOST, MFD->MFD_ALIQ, @cCampos)
	    aAdd(aAliqPtr, { cStatus, MFD->MFD_IMPOST, MFD->MFD_ALIQ,cSFI, cCampos} )
	
		MFD->(DbSkip(1))
	EndDo  
	
	cLog += CRLF + space(nEspacos) + STR0094  //" - Buscando alíquotas cadastradas no arquivo"
	
	RestArea(aAreaMFD)
	RestArea(aArea)    

Return lRet	     

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdCAP
Função para verificar se o imposto está cadastrado no SFI
@param cImpost	   	Codigo do Imposto 1- ICMS, 2=ISS
@param nAliq 		Alíquotas do Protheus
@param cCampo		Nome dos campos separados por virgulas
@version P11.8
@since   26/04/2013
@return	cRet		1 = Cadastrado,2=Não Cadastrado, 3= Dispensado
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STFWzLdCAP(cImpost, nAliq, cCampos)
	Local cAliq	:= ""  //Codigo da Aliquota do Imposto
	Local cCampo := ""  //Campo de Base do Imposto
	Local cCampo2 := ""  //Campo de Código do tributo "T"  
	Local lRet		:=  .F.  //validacao dos campos
	Local cRet := "2"  //Não Cadastrado  
	
	//Local lOpen := MyOpenSM0Ex()
		
	DEFAULT cImpost := "1" //ICMS
	DEFAULT nAliq := 0 
	DEFAULT cCampos := ""
	
   
	cAliq := AllTrim(Str(Int(nAliq), 2))  
	cCampos := ""

	If nAliq > 0
	
		If cImpost == "1"  
			If nAliq == 1 .AND. LjAnalisaLeg(16)[1]   
			
			     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava a aliq. 0,01%(Garantido Integral ECF Mato Grosso) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCampo  := "FI_BAS001"
				cCampos := cCampo
			Else 
				 			   				
				cCampo := "FI_BAS" + cAliq
				cCampo2 := "FI_COD" + cAliq 
				
				cCampos := cCampo +"," +cCampo2								

			EndIf	

			If !Empty(cCampo) 
				lRet := SFI->(FieldPos(cCampo)) > 0
			EndIf
			
			If !Empty(cCampo2) 
				lRet := lRet .AND. SFI->(FieldPos(cCampo2)) > 0
			EndIf
			
			cRet := IIF(lRet, "1", "2")

  
		Else //ISS - somente a base
		    cCampo := "FI_BIS" + cAliq 
		    cCampos := cCampo
		    If SFI->(FieldPos(cCampo)) > 0
		    	cRet := "1"
		    EndIf 			
		EndIf  
		

	
	EndIf 
	
Return cRet 
	   

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrAP
Função para cadastro das alíquotas a serem programadas
@param cLG_CODIGO   Codigo da Estação
@param aAliqPtr		Alíquotas do Protheus
@param aALiqECF     Alíquotas do ECF
@param oDLG			Janela
@param nPanel		Panel atual
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFWzPrAP(cLG_CODIGO,	aAliqPtr,	aAliqECF,	oDlg,;
					nPanel,		cLog, 		nEspacos)
//Monta o TCBrowse 
Local oOK   	:= LoadBitmap(GetResources(),'br_verde')   //Objeto BMP OK
Local oNO   	:= LoadBitmap(GetResources(),'br_vermelho') //Objeto BMP NO
Local aObjects 	:= {} //Objetos da janeça
Local aPosObj 	:= {} //Posicao do objeto
Local nAliquota := 00.00  //Aliquota a ser programada   
Local oBrowseECF:= NIL	//Browse de aliquotas ECF
Local oBrowsePtr:= NIL  //Browse de aliquotas o Protheus
Local nRow 		:= 0  //Linhas do Panel
Local nCol 		:= 0  //Colunas do panel     
Local nTipo 	:= 1 //tipo do Imposto 
Local oTipo  	:= NIL //tipo da aliquota    
Local nLargB 	:= 0   //Largura do Browse

DEFAULT cLG_CODIGO 	:= SLG->(CriaVar("LG_CODIGO")) //Estação   	
DEFAULT aAliqPtr 	:= {}  //aliquotas do Protheus
DEFAULT aAliqECF 	:= {}	//Aliquotas do ECF	
DEFAULT oDlg 		:= NIL	//Janela    
DEFAULT nPanel 		:= 1	//Panel
DEFAULT cLog 		:= ""	//Log
DEFAULT nEspacos 	:= 5 	//Espacos do Log

	oPanel := oDlg:GetPanel(nPanel)   

	nRow		:= Int( oPanel:nHeight/2)  //Linha do Painel
	nCol := Int( oPanel:nWidth/ 2)
	
	oPanel := TScrollBox():New( oPanel, 0,0,nRow,nCol)  
	nCol := Int( nCol *.97 )

	nLargB 		:= 	(nCol/2) - 20
	
	nTam := CalcFieldSize("C",Len(STR0095),0,"@!",STR0095)  //1 //"Alíquotas cadastradas no ECF"###"Alíquotas cadastradas no ECF"
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //1
	aAdd(aObjects,  { nLargB, 150, .F., .F.}) //Impar Sa //2 
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Linha em branco //3
 	nTam := CalcFieldSize("C",Len(STR0096),0,"@!",STR0096)  //4 //"Programar Alíquotas"###"Programar Alíquotas"
	aAdd(aObjects,  { nTam, 12, .F., .F.}) //4  
	nTam := CalcFieldSize("N",5,9,"@E 99,99%",STR0097)	 //"Alíquota"
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //5
	aAdd(aObjects,  { nTam, 10, .F., .F.}) //6
	nTam := CalcFieldSize("C",Len("ICMS")+5,0,"@!","ICMS")	
 	aAdd(aObjects,  { nTam, 6, .F., .F.}) //7  - mesma linha do  ICMS
	aAdd(aObjects,  { 55, 15, .F., .F.})    //8 botão programar

	
	aPosObj := MsObjSize( { 0 , 15 , nRow ,nCol, 2, 3,3,3}, aObjects, .T., .F.)  
	
	
	//oPanel := oDlg:GetPanel(nPanel)   
	
	//Monta o TCBrowse
   	tSay():New( aPosObj[01, 1],  aPosObj[01, 2]  , { || STR0095 } ,oPanel,,,,,,.T.,,,  ,  ) //"Alíquotas cadastradas no ECF"
	
	oBrowseECF := TCBrowse():New( aPosObj[02,01] , aPosObj[02,02], nLargB, aObjects[02,02], ,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )       
	oBrowseECF:SetArray(aAliqECF) 
    oBrowseECF:AddColumn(TCColumn():New(STR0098,{||aAliqECF[oBrowseECF:nAt,01] },"@!",,,"LEFT",CalcFieldSize("C",2,0,"@!",STR0098),.F.,.F.,,,,,))  //"Código"###"Código"
	oBrowseECF:AddColumn(TCColumn():New(STR0099,{||IIF(aAliqECF[oBrowseECF:nAt,02]== "1", STR0100, STR0101) },"@!",,,"LEFT",CalcFieldSize("C",4,0,"@!",STR0099),.F.,.F.,,,,,)) //"Tipo"###"ICMS"###"ISS"###"Tipo"
	oBrowseECF:AddColumn(TCColumn():New(STR0102,{||aAliqECF[oBrowseECF:nAT,03] },"@E 99.99",,,"LEFT",CalcFieldSize("N",5,5,"@E 99.99",STR0102),.F.,.F.,,,,,)) //"Alíquota %"###"Alíquota %"
	
 	tSay():New( aPosObj[01, 1],  nLargB+aPosObj[02,02]+5  , { || STR0103 } ,oPanel,,,,,,.T.,,,  ,  ) //"Alíquotas cadastradas no sistema"
	oBrowsePtr := TCBrowse():New( aPosObj[02,01] , nLargB+aPosObj[02,02]+5,(nCol - (nLargB+aPosObj[02,02]+5)), aObjects[02,02],,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )       
 	oBrowsePtr:SetArray(aAliqPtr) 
   	oBrowsePtr:AddColumn(TCColumn():New(STR0104,{||IIf(aAliqPtr[oBrowsePtr:nAt,01]== "2",oOK,oNO) },"",,,"LEFT",CalcFieldSize("C",2,0,"@!",STR0104),.T.,.F.,,,,,))  //"Status"###"Status"
	oBrowsePtr:AddColumn(TCColumn():New(STR0099,{||IIF(aAliqPtr[oBrowsePtr:nAt,02]== "1", STR0100, STR0101) },"@!",,,"LEFT",CalcFieldSize("C",4,0,"@!",STR0099),.F.,.F.,,,,,)) //"Tipo"###"ICMS"###"ISS"###"Tipo"
	oBrowsePtr:AddColumn(TCColumn():New(STR0102,{||aAliqPtr[oBrowsePtr:nAT,03] },"@E 99.99",,,"LEFT",CalcFieldSize("N",5,5,"@E 99.99",STR0102),.F.,.F.,,,,,)) //"Alíquota %"###"Alíquota %"
	oBrowsePtr:AddColumn(TCColumn():New(STR0105,{|| IIF(aAliqPtr[oBrowsePtr:nAT,04] == "1", STR0106, IIF(aAliqPtr[oBrowsePtr:nAT,04] == "2", STR0107, STR0108)) },,,,"LEFT",CalcFieldSize("C",14,0,"",STR0105),.F.,.F.,,,,,)) //"Cad Mapa Resumo?"###"Cadastrado"###"Não Cadastrado"###"Dispensado"###"Cad Mapa Resumo?"

  	oBrowsePtr:BHeaderClick := { ||  STFWzShowLg( { 	{"BR_VERDE",	STR0109},; 	 //"Programado"
				   										{"BR_VERMELHO", STR0110}; 	 //"Não programado"
											      }, STR0111 ) }	 //"Legenda Alíquotas"
    
    //Seção 2 Programação de alíquotas
 
  	
 	@aPosObj[03,01], 5 to aPosObj[08, 1] ,nCol OF oPanel PIXEL 	 
	tSay():New( aPosObj[04, 1],  aPosObj[04, 2]+15  , { || STR0096 } ,oPanel,,,,,,.T.,,,  ,  ) //"Programar Alíquotas"
 	tSay():New( aPosObj[05, 1],  aPosObj[05, 2]+15  , { || STR0097 } ,oPanel,,,,,,.T.,,,  ,  ) //"Alíquota"
		
	TGet():New( aPosObj[06, 1],aPosObj[06, 2]+15,{ |U| Iif(PCOUNT() > 0, nAliquota := U, nAliquota)},oPanel,aObjects[06,01],aObjects[06,02],"@E 99.99",{|| nAliquota >= 0 },,,, .T.,, .T.,, .T.,            , .F., .F.,, .f., .F. ,,"nAliquota",,,,.T.,) 
 	@ aPosObj[05, 1], aPosObj[07, 2]+ aPosObj[05, 04] + 20 +15 RADIO oTipo VAR nTipo SIZE aObjects[04, 01], aObjects[04, 02] PROMPT STR0100, STR0101 OF oPanel //"ICMS"###"ISS"
  	TButton():New(aPosObj[05, 1], aPosObj[08, 2]+ aPosObj[05, 04] + aPosObj[07, 04]+50+15, STR0112,oPanel,{||  IIF( STFWzPrAg(  Str(nAliquota,5,2), Str(nTipo,1,0), @aAliqECF, @aAliqPtr, ; //"Programar"
  																																	@cLog, nEspacos), ;
  																													(oBrowseECF:SetArray(aAliqECF), oBrowsePtr:SetArray(aAliqPtr)), )},55,15,,,.F.,.T.,.F.,,.F.,{ || nAliquota > 0 },,.F. )
   	TButton():New(aPosObj[05, 1], aPosObj[08, 2]+ aPosObj[05, 04] + aPosObj[07, 04]+50+15+65, STR0113,oPanel,{||  IIF( STFWzPrAg( "0" ,"T", @aAliqECF, @aAliqPtr,; //"Programar Tudo"
  																																			@cLog, nEspacos), ;
  																																(oBrowseECF:SetArray(aAliqECF), oBrowsePtr:SetArray(aAliqPtr)), )},55,15,,,.F.,.T.,.F.,,.F.,{ || Len(aAliqPtr) > 0 },,.F. )

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrAg
Função para programação das alquotas no ECF
@param cAliquota    Codigo da Aliquota
@param cImposto		Codigo do Imposto 1- ICMS , 2- ISS
@param aAliqPtr		Alíquotas do Protheus
@param aALiqECF     Alíquotas do ECF
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@retun	lPross		Aliquota programada com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------- 
Function STFWzPrAg( cAliquota, cImposto, aALiqECF, aAliqPtr,;
					cLog, nEspacos)

	Local aRet := {} 
	Local lPross := .T. 
	Local aDados := {"17", space(30)}  
	Local nPos := 0  
	Local lTudo := .F. 
	Local cLogT := ""
	Local nEspacoT := 0 
	Local cTxtTmp := ""
	
	
	
	DEFAULT cAliquota := ""
	DEFAULT cImposto := ""
	DEFAULT aAliqECF := {}
	DEFAULT aAliqPtr := {}
	DEFAULT cLog := ""
	DEFAULT nEspacos := 5
	
	
	nEspacoT := nEspacos + 5
	
	lTudo := cAliquota == "0"

	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STPrinterStatus"																,;		// Nome do evento
								{"8"													,;	
								" "} )
	
	
	If Len(aRet) > 0 .AND. aRet[1] == 10
		//Redução Z Pendente 
		cTxtTmp := STR0114 //"Redução Z Pendente. Para a programação de alíquotas, faz-se necessario que seja emitida a redução Z. "
		STFMessage("Z Reduction", "STOP", cTxtTmp)
		STFShowMessage("Z Reduction")    
		lPross := .F.  
		cLogT += CRLF + space(nEspacoT) + STR0027 + cTxtTmp //"[ERRO] - "
	Else
		aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STPrinterStatus"																,;		// Nome do evento //
								aDados )  
		If Len(aDados) < 2 .OR. Len(aRet) =0  .OR. aRet[1] <> 0    
			cTxtTmp := STR0116 //"Falha ao capturar Venda Bruta Diária"
			STFMessage("Printer Status", "STOP", STR0116) //"Falha ao capturar Venda Bruta Diária"
			STFShowMessage("Printer Status")
			cLogT += CRLF + space(nEspacoT) + "[ERRO] - " + cTxtTmp
			lPross := .f.  
		Else
			If Val(aDados[2]) >  0
				cTxtTmp := STR0117 //"Já foram realizadas vendas para este dia"
				STFMessage("Printer Status", "STOP", cTxtTmp)
				STFShowMessage("Printer Status")
				cLogT += CRLF + space(nEspacoT)  + STR0027 + cTxtTmp //"[ERRO] - "
				lPross := .f. 
			EndIf 			
		EndIf		
	EndIf   
	
	
	If lPross 
		If !lTudo
			aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
									"STAddAliq"																,;		// Nome do evento
									{ cAliquota, cImposto} )  

			If (lPross := Len(aRet) > 0 .AND. aRet[1] == 0)
		 		//Aliquota programada com sucesso
				aAdd(aAliqECF, {StrZero(Len(aAliqECF)+1, 2), cImposto, Val(cAliquota)})
				//Verifica se a alíquota existe no Array e muda o status
				cStatus := "1"  //Não programado
				If (nPos := aScan(aAliqPtr, {|e| e[2] == cImposto .AND. e[3] == Val(cAliquota) }))  > 0
					aAliqPtr[nPos, 01] := "2" //Programado
				EndIf           
            Else
            	cTxtTmp := STR0118 +IIF(cImposto == "1" , STR0100, STR0101) + Transform(Val(cAliquota), "@E 99.99%") //"Falha ao programar alíquota de : "###"ICMS"###"ISS"
            	STFMessage("AddAliq","STOP",cTxtTmp ) //STR
				
				STFShowMessage("AddAliq") 
				cLogT += CRLF + space(nEspacoT) + "[ERRO] - " + cTxtTmp 
            EndIf
		Else 
			Do While (nPos := nPos + 1) <= Len(aAliqPtr)
				If aAliqPtr[nPos, 01] == "1" //Não programado 		
					aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
									"STAddAliq"																,;		// Nome do evento
									{ Str(aAliqPtr[nPos, 03],5,2), aAliqPtr[nPos, 02]} )  
					lPross := Len(aRet) > 0 .AND. aRet[1] == 0
				EndIf
				If lPross  
					aAdd(aAliqECF, {StrZero(Len(aAliqECF)+1, 2), aAliqPtr[nPos, 02], aAliqPtr[nPos, 03]})
					aAliqPtr[nPos, 01] := "2"
				Else
		 				cTxtTmp := "Falha ao programar alíquota de : " + IIF(aAliqPtr[nPos, 02] == "1" , STR0100, STR0101) + Transform(aAliqPtr[nPos, 03], "@E 99.99%") //"ICMS"###"ISS"
		 				STFMessage("AddAliq","STOP",cTxtTmp ) //STR
				
						STFShowMessage("AddAliq")
						cLogT += CRLF + space(nEspacoT) + STR0027 + cTxtTmp				 //"[ERRO] - "
					Exit
				EndIf
			EndDo
		EndIf	

	
	EndIf 
	
	cLog += CRLF + space(nEspacos) + IIF(lPross, "", STR0072 ) + STR0119 + IIF(!lTudo," ",STR0120)+ STR0121 + cLogT  //"[ERRO]"###" - Programando alíquota"###"s "###"de ECF"
	
Return lPross    


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdTIF
Função para identificação dos totalizadores nao-fiscais no ECF
@param cLG_CODIGO   Codigo da Estação
@param cImpFisc		Modelo de Impressora Fiscal
@param cPorta		Porta de Conexao
@param lConecta		ECF Conectado
@param aTotNFisc	Totalizadores não fiscais do ECF
@param lTotvsApi    TotvsApi?
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@retun	lRet		Execução com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------
Function STFWzLdTIF(cLG_CODIGO,	cImpFisc,	cPorta,	lConecta,;
					aTotNFisc, 	lTotvsApi,	cLog, 	nEspacos )   
					
Local aRet 		:= {}	//Retorno do Strategy
Local aDados 	:= {}	//Retorno do ECF  
Local lRet 		:= .T.	//Retorno da função 
Local cLogT		:= ""	//Log temporario
Local nEspacoT 	:= 0	//Espaco Temporario

DEFAULT cLG_CODIGO 	:= "	" 	//codigo da Estação
DEFAULT cImpFisc 	:= ""		//Impressora Fiscal
DEFAULT cPorta 		:= ""		//Porta	
DEFAULT aTotNFisc 	:= {}		//totalizadores nao-fiscais cadastrados 
DEFAULT lTotvsApi 	:= .F. 		//TotvsApi?
DEFAULT cLog 		:= ""      	//Log da rotina
DEFAULT nEspacos 	:= 5        //Espacos
	
	nEspacoT := nEspacos+5
	
	
      If !lConecta 
        If Empty(cImpFisc) 
        
            cImpFisc := STFGetStat("IMPFISC")
      	EndIf
      	If Empty(cPorta)
      		cPorta := STFGetStat("PORTIF")
      	EndIf
      	
		lConecta := lRet := STFWzCIF(cImpFisc, cPorta, @cLogT, nEspacoT) 
 
      EndIf
      
      If lRet  
      
      	//vERIFICA SE É TOTVSAPI
      	aDados := {space(30)}
      	aRet := STFFireEvent(	ProcName(0) ,;
      							 "STRetTypePrt", ;	
				   					aDados )  
		If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0 .AND. ValType(aDados[1]) == "C"
			lTotvsApi :=  aDados[1] == "TOTVSAPI"
		EndIf

		aDados := {space(100)} 
	  	aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
	             						"STGetNotFiscalTotal",;	
	 			                         aDados )   
	
		If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0
	 		If aDados[1] == "-99" //função indisponível
	 			STFMessage("XREADER","YESNO",STR0122) //STR //"Modelo de Impressora Fiscal não possui função para retornar os totalizadores parciais. Imprimir Leitura X?"
			
				If STFShowMessage("XREADER")
					aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
		 													  "STReadingX"																,;		// Nome do evento
		 													  {} )
		 			If Len(aRet) = 0 .OR. aRet[1] <> 0
		 				STFMessage("XREADER2","STOP",STR0123) //STR //"Falha na Emissão da Leitura X"
				
						STFShowMessage("XREADER2")  
						lRet := .F.
		 			EndIf 
		 			
		 			cLogT += CRLF + space(nEspacoT) + IIF(lRet, "", STR0124 ) + STR0125 //"[ERRO] "###" - Emitindo Leitura X. Não foi possível realizar leitura dos totalizadores. "
				
		 		EndIf 
		 		aTotNFisc := {{"XX", STR0126}} //"MODELO NAO PERMITE IDENTIFICACAO"
		 	Else
		 		aRet := StrTokArr( aDados[1] , "|" )
		 		aEval(aRet, { |l| aAdd(aTotNFisc, StrTokArr( l , "," ))})
		 		aEval(aTotNFisc, { |l| l[1] := PadL(AllTrim(l[1]),2,"0")})
		 	EndIf
		Else
			lRet := .F.
	  	EndIf                     

	  EndIf	
	  
	  cLog += CRLF + IIF(lRet, "", STR0124 ) + STR0127 + cLogT											     		 //"[ERRO] "###"- Capturando Totalizadores Não-Fiscais"
      		
Return lRet    

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdTP
Função para identificação dos totalizadores nao-fiscais no Sistema
@param cLG_CODIGO   Codigo da Estação
@param aTotPtr     Totalizadores não fiscais do Protheus
@param aTotNFisc	Totalizadores não fiscais do ECF
@param lTotvsApi    TotvsApi?
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@retun	.T.	
@obs
@sample
/*/
//------------------------------------------------------------------
Function STFWzLdTP(cLG_CODIGO, aTotPtr, aTotNFisc, lTotvsApi,;
					cLog, 		nEspacos) 
					
Local aRet 	   		:= {}				//Retorno do Strategy
Local cTot 			:= ""  				//Totalizador      
Local cGetCliDir 	:=  GetClientDir() //Diretório smartclient
Local cStatus 		:= "3" 				//Não  Identificado
Local nPos			:= 0				//Posicao do array 
Local lNoId 		:= .F. 				//Não identificado 
Local cDescTot 		:= ""  				//Descrição do Totalizador 
Local aLista  		:= {}  				//Lista de Totalizadores 
Local aListaECF		:= {}  				//Lista do ECF
Local nC 			:= 0   				//Contador
	
DEFAULT cLG_CODIGO := "	" 	//Codigo da Estação
DEFAULT aTotPtr := {} 		//Chave, Seção, Valor, Arquivo - (se em branco e porque a impressora fiscal não é totvsapi, nesse caso não grava)  
DEFAULT aTotNFisc := {} 	//Totalizador não-fiscal
DEFAULT lTotvsApi := .F.	//TotvsApi
DEFAULT cLog := ""          //log de execução
DEFAULT nEspacos := 5       //Espacos
	
	//Carrega os totalizadores da Sigaloja.ini
	//Recebimento de Títulos  
	
	lNoId := Len(aTotNFisc) == 1 .AND. aTotNFisc[1,1] == "XX"
	
	//TO DO: TOTALIZADOR DE ESTORNO DE VENDA
	aLista :=  {;
	 			{"Recebimento Titulos","Totalizadores", cGetCliDir+"SIGALOJA.INI",1 }, ; 
	 			{"Comprovante TEF","Totalizador", cGetCliDir+"SIGALOJA.INI", 1}, ;
	 			{"Recarga Celular","Totalizador", cGetCliDir+"SIGALOJA.INI", 1} ,; 
	 			{"Correspondente Bancario","Totalizador", cGetCliDir+"SIGALOJA.INI", 1} ;
	 			}
	
	If lTotvsApi 
	
		aAdd(aLista, {"Microsiga", "TotalizadorPedido", cGetCliDir+"TOTVSAPI.INI", 2})
		aAdd(aLista,{"Microsiga", "TotalizadorTefPedido", cGetCliDir+"TOTVSAPI.INI", 2})
		aAdd(aLista,{"Totalizadores", "Sangria", cGetCliDir+"TOTVSAPI.INI", 2})
		aAdd(aLista, {"Totalizadores", "Suprimento", cGetCliDir+"TOTVSAPI.INI", 2})

	Else
		aAdd(aTotPtr, {"3", "","", "Microsiga", "TotalizadorPedido", "", 0})
		aAdd(aTotPtr,{"3", "","", "Microsiga", "TotalizadorTefPedido", "", 0})
		aAdd(aTotPtr,{"3","","", "Microsiga", "TotalizadorTefPedido", "", 0})
		aAdd(aTotPtr,{"3", "", "", "Totalizadores", "Sangria", "", 0})
		aAdd(aTotPtr, {"3","","",  "Totalizadores", "Suprimento", "", 0})
		
	EndIf
	
	For nC := 1 to Len(aLista)
		cStatus := "3" //Não  Identificado
 		cDescTot := ""
		cTot := GetPvProfString(aLista[nC, 01] , aLista[nC, 02], "", aLista[nC, 03])   
		If !Empty(cTot)
			If !lNoId
			   cStatus := "1" //Nao programado 
			   cDescTot := ""
			   If (nPos := aScan(aTotNFisc, { |t| Upper(AllTrim(t[aLista[nC, 04]])) == Upper(AllTrim(cTot))} ) ) > 0
			   		cStatus := "2" //programado
			   		cDescTot := aTotNFisc[nPos, 02]
			   		
			   		If aLista[nC, 04] == 2   
			   			cTot := aTotNFisc[nPos, 01]
			   		EndIf
			   EndIf 

			EndIf 
			If aLista[nC, 04] == 2  .AND. Empty(cDescTot)
			   cDescTot := cTot
			   cTot := ""	
			EndIf   

		Else
			cStatus := "4" //Não cadastrado
		EndIf 
		               //Status //Codigo, //dESCRICAO  //Seção		//Chave			//Arquivo  //FORMA GRAVAÇÃO
		aAdd(aTotPtr,{ cStatus,  cTot, cDescTot , aLista[nC, 01],  aLista[nC, 02],  aLista[nC, 03] , aLista[nC, 04]}  )
	Next 
	
	cLog += CRLF + space(nEspacos) + STR0129 //"- Capturando Totalizadores Não-fiscais do Sistema"

	
Return .T.	

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdTP
Função para cadastro/programação dos totalizadores nao-fiscais
@param cLG_CODIGO   Codigo da Estação
@param aTotPtr     Totalizadores não fiscais do Protheus
@param aTotNFisc	Totalizadores não fiscais do ECF
@param lTotvsApi    TotvsApi?
@param oDLG			Janela
@param nPanel		Painel
@param cLog			Log de Execucao
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------------
Function STFWzPrTP(cLG_CODIGO,  aTotPtr, 	aTotNFisc, lTotvsApi, ;
					oDLG, 		nPanel,		cLog, 		nEspacos) 
//Monta o TCBrowse 
Local oBmp2   	:= LoadBitmap(GetResources(),'br_verde')  //Objeto BMP Programado
Local oBmp1   	:= LoadBitmap(GetResources(),'br_vermelho') //Objeto BMP nao programado
Local oBmp3   	:= LoadBitmap(GetResources(),'br_amarelo') //Objeto BMP não identificado
Local oBmp4   	:= LoadBitmap(GetResources(),'br_laranja')  //Objeto BMP nao cadastrado
Local aObjects 	:= {}  										//Objetos do panel
Local aPosObj 	:= {}  										//Posicionamento do Objeto
Local nTotaliz 	:= 00  										//Codigo do Totalizador
Local cDescr 	:= space(30) 								//Descrição do totalizador
Local cChave 	:= space(20)								//Chave do totalizador
Local cSecao 	:= space(30)								//Secao do totalizador
Local cArquivo 	:= space(100)								//Arquivo.ini do totalizador	   
Local oBrowseECF:= NIL										//Browse de totalizadores do ECF
Local oBrowsePtr:= NIL										//Browse de totalizadores do Protheus
Local nRow 		:= 0  										//Linhas do Panel
Local nCol 		:= 0  										//Colunas do panel     
Local nLargB 	:= 0 										//Largura do Browse
Local aColuna 	:= {} 										//Colunas do Browse   
Local nSepComp 	:= 3										//Colunas de espacamento   
Local oGet1 	:= NIL										//Objeto Get1
Local oGet2 	:= NIL										//Objeto Get2
Local oGet3 	:= NIL										//Objeto Get3
Local oGet4 	:= NIL										//Objeto Get4
Local oGet5 	:= NIL										//Objeto Get5
Local oBtn1 	:= NIL										//Botao1    
Local lGrav 	:= .T. 										//Grava arquivo de configuracao  
Local oChk1 	:= NIL										//Objeto check1 
    
DEFAULT cLG_CODIGO 	:= SLG->(CriaVar("LG_CODIGO"))  //Estacao	 
DEFAULT aTotPtr 	:= {} //totalizadores do Protheus
DEFAULT aTotNFisc 	:= {} //Totalizadores não-fiscais
DEFAULT lTotvsApi 	:= .F. //TotvsApi?
DEFAULT oDlg 		:= NIL//Janela
DEFAULT nPanel 		:= 0	//panel
DEFAULT cLog 		:= ""	//log
DEFAULT nEspacos 	:= 5	//Espacos	
 

	aColuna := { {0,0}, {0,0}, {0,0}}
	
	oPanel := oDlg:GetPanel(nPanel)   

	nRow		:= Int( oPanel:nHeight/2)  //Linha do Painel
	nCol := Int( oPanel:nWidth/ 2)
	
	oPanel := TScrollBox():New( oPanel, 0,0,nRow,nCol)  
	nCol := Int( nCol *.97 )

	nLargB 		:= 	(nCol/4) - 10
	
	nTam := CalcFieldSize("C",Len(STR0130),0,"@!",STR0130)  //1 //"Totalizadores cadastrados no ECF"###"Totalizadores cadastrados no ECF"
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //1
	aAdd(aObjects,  { nLargB, 150+10, .F., .F.}) //Browse //2 
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line 3 
 	nTam := CalcFieldSize("C",Len(STR0131),0,"@!",STR0131)   //"Programar Totalizador"###"Programar Totalizador"
	aAdd(aObjects,  { nTam, 12, .F., .F.}) //4  
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //5
	aAdd(aObjects,  { 55, 15, .F., .F.})    //6 botão programar 
	nTam := CalcFieldSize("C",Len(STR0132),0,"",STR0132) 	 //"Gravar Totalizador no Sistema"###"Gravar Totalizador no Sistema"
	aAdd(aObjects,  { nTam+5, 10, .F., .F.}) //gravar //7
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Label //8
	aAdd(aObjects,  { 10, 60, .F., .F.})    //9 Gets	
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line 10  
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line 11	
			
	aPosObj := MsObjSize( { 0 , 15 , nRow ,nCol, nSepComp, 3,3,3}, aObjects, .T., .F.)   
	
	//Monta o TCBrowse
   	tSay():New( aPosObj[01, 1],  aPosObj[01, 2]  , { || STR0130 } ,oPanel,,,,,,.T.,,,  ,  ) //"Totalizadores cadastrados no ECF"
	
	oBrowseECF := TCBrowse():New( aPosObj[02,01] , aPosObj[02,02], aObjects[02,01], aObjects[02,02], ,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )       
	oBrowseECF:SetArray(aTotNFisc) 
    oBrowseECF:AddColumn(TCColumn():New(STR0098,{|| aTotNFisc[oBrowseECF:nAt,01] },"@!",,,"LEFT",CalcFieldSize("C",2,0,"@!",STR0098),.F.,.F.,,,,,))  //"Código"###"Código"
	oBrowseECF:AddColumn(TCColumn():New(STR0133,{|| aTotNFisc[oBrowseECF:nAt,02] },"@!",,,"LEFT",CalcFieldSize("C",Len(cDescr),0,"@!",STR0133),.F.,.F.,,,,,)) //"Descrição"###"Descrição"
    oBrowseECF:bChange   := {|| IIF(ValType(oGet1) == "O", (nTotaliz := Val(aTotNFisc[oBrowseECF:nAt,01]), cDescr := aTotNFisc[oBrowseECF:nAt,02], oGet1:Refresh(), oGet2:Refresh() ), NIL) }

	
 	tSay():New( aPosObj[01, 1],  nLargB + 10  , { || STR0134 } ,oPanel,,,,,,.T.,,,  ,  ) //"Totalizadores do sistema"


	oBrowsePtr := TCBrowse():New( aPosObj[02,01] , aObjects[02,01]+13, nCol-(aObjects[02,01]+13), aObjects[02,02],,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )       
 	oBrowsePtr:SetArray(aTotPtr) 
   	oBrowsePtr:AddColumn(TCColumn():New(STR0104,{|| IIF(aTotPtr[oBrowsePtr:nAt,01] == "1", oBmp1, IIF(aTotPtr[oBrowsePtr:nAt,01] == "2",oBmp2,IIF(aTotPtr[oBrowsePtr:nAt,01] == "3",oBmp3,oBmp4))) },"",,,"LEFT",CalcFieldSize("C",2,0,"@!",STR0104),.T.,.F.,,,,,))  //"Status"###"Status"
    oBrowsePtr:AddColumn(TCColumn():New(STR0098,{|| aTotPtr[oBrowsePtr:nAt,02] },"@!",,,"LEFT",CalcFieldSize("C",2,0,"@!",STR0098),.F.,.F.,,,,,))  //"Código"###"Código"
	oBrowsePtr:AddColumn(TCColumn():New(STR0133,{|| aTotPtr[oBrowsePtr:nAt,03] },"@!",,,"LEFT",CalcFieldSize("C",Len(cDescr),0,"@!",STR0133),.F.,.F.,,,,,)) //"Descrição"###"Descrição"
	oBrowsePtr:AddColumn(TCColumn():New(STR0135,{|| aTotPtr[oBrowsePtr:nAt,04] },"@!",,,"LEFT",CalcFieldSize("C",Len(cChave),0,"@!",STR0135),.F.,.F.,,,,,)) //"Chave"###"Chave"
	oBrowsePtr:AddColumn(TCColumn():New(STR0136,{|| aTotPtr[oBrowsePtr:nAt,05] },"@!",,,"LEFT",CalcFieldSize("C",Len(cSecao),0,"@!",STR0136),.F.,.F.,,,,,)) //"Seção"###"Seção"
	oBrowsePtr:AddColumn(TCColumn():New(STR0137,{||aTotPtr[oBrowsePtr:nAt,06] },"@!",,,"LEFT",CalcFieldSize("C",Len(cArquivo),0,"@!",STR0137),.F.,.F.,,,,,)) //"Arquivo"###"Arquivo"
    oBrowsePtr:bChange   := {|| IIF(ValType(oGet1) == "O", ( nTotaliz := IIF(Empty(nTotaliz), Val(aTotPtr[oBrowsePtr:nAt,02]), nTotaliz) , cDescr := IIF(Empty(cDescr), IIF(Empty(aTotPtr[oBrowsePtr:nAt,03]), aTotPtr[oBrowsePtr:nAt,04], aTotPtr[oBrowsePtr:nAt,03] ), cDescr) , cChave := aTotPtr[oBrowsePtr:nAt,04], cSecao := aTotPtr[oBrowsePtr:nAt,05], cArquivo := aTotPtr[oBrowsePtr:nAt,06], lGrav := aTotPtr[oBrowsePtr:nAt,07] > 0, oGet1:Refresh(), oGet2:Refresh(), oGet3:Refresh(), oGet4:Refresh(), oGet5:Refresh(), oBtn1:Refresh(), oChk1:Refresh()) , NIL ) }
  	oBrowsePtr:BHeaderClick := { ||  STFWzShowLg( { 	{"BR_VERDE",	STR0109},; 	 //"Programado"
				   								{"BR_VERMELHO", STR0110},; 	 //"Não programado"
												{"BR_AMARELO",	STR0076},; 	 //"Não identificado"
				   								{"BR_LARANJA",		STR0107} }, STR0138 ) } //"Não cadastrado"###"Legenda Tot. Sistema"

 	@aPosObj[03,01], 5 to aPosObj[11, 1] ,nCol OF oPanel PIXEL 	 
	tSay():New( aPosObj[04, 1],  aPosObj[04, 2]+15  , { || STR0131 } ,oPanel,,,,,,.T.,,,  ,  ) //"Programar Totalizador"
   
    //Linha 5 - label da Programação
 	nTam := CalcFieldSize("C",2,0,"@!",STR0139) //Tamanho do Get Codigo        //"Codigo"
 	

 	aColuna[1,1] := aPosObj[05, 2]+15  
 	aColuna[1,2] := nTam
 	tSay():New( aPosObj[05, 1], aColuna[1,1]  , { || STR0139 } ,oPanel,,,,,,.T.,,,  ,  )  //"Codigo"
 	
 	aColuna[2,1] := aColuna[1, 1] + nTam + nSepComp 
  	nTam := CalcFieldSize("C",Len(cDescr),0,"@!",STR0133) //Tamanho do Get Codigo //"Descrição"
    aColuna[2,2] := nTam	
 	tSay():New( aPosObj[05, 1], aColuna[2,1]  , { || STR0133 } ,oPanel,,,,,,.T.,,,  ,  )   //"Descrição"
   
 	aColuna[3,1] := aColuna[2, 1] + nTam + nSepComp 
 	aColuna[3,2] := aObjects[06,01]
	
	//Linha 6 - Gets da Programação
	oGet1 := TGet():New( aPosObj[06, 1],aColuna[1,1],{ |U| Iif(PCOUNT() > 0, nTotaliz := U, nTotaliz)},oPanel, aColuna[1,2],10,"@E 99",{|| nTotaliz >= 0 },,,, .T.,, .T.,, .T.,            , .F., .F.,, .f., .F. ,,"nTotaliz",,,,.T.,) 
	oGet2 := TGet():New( aPosObj[06, 1],aColuna[2,1],{ |U| Iif(PCOUNT() > 0, cDescr := U, cDescr)},oPanel, aColuna[2,2],10,,{|| !Empty(cDescr) },,,, .T.,, .T.,, .T.,            , .F., .F.,, .f., .F. ,,"cDescr",,,,.T.,) 
   	oBtn1 := TButton():New(aPosObj[06, 1], aColuna[3,1], STR0112,oPanel,{||  IIF( STFWzPrTg( 	@nTotaliz, @cDescr, cChave, cSecao, ; //"Programar"
   																									cArquivo, @aTotNFisc, @aTotPtr, lGrav, ;
   																									@cLog, nEspacos),;
   																					 (oBrowseECF:SetArray(aTotNFisc), oBrowsePtr:SetArray(aTotPtr)), ), ;
   																					 oGet1:Refresh(), oGet2:Refresh() },aObjects[06,01],aObjects[06,02],,,.F.,.T.,.F.,,.F.,{ || nTotaliz > 0 .AND. !Empty(cDescr)  },,.F. )
   	oBtn2 := TButton():New(aPosObj[06, 1], aColuna[3,1]+aObjects[06,01]+nSepComp, STR0140,oPanel,{||  IIF( STFWzGrTg( @nTotaliz, @cDescr, cChave, cSecao, ; //"Gravar Sistema"
   																																cArquivo, @aTotPtr, lGrav, @cLog, ;
   																																nEspacos),;
   																													oBrowsePtr:SetArray(aTotPtr), ),;
   																													 oGet1:Refresh(), oGet2:Refresh() },aObjects[06,01],aObjects[06,02],,,.F.,.T.,.F.,,.F.,{ || nTotaliz > 0 .AND. !Empty(cDescr)  .AND. lGrav  .and. !Empty(cArquivo) },,.F. )


	//Linha - Check de Gravação
	oChk1 := TCheckBox():New(aPosObj[7, 01], aColuna[1,1],STR0132,{ |U| Iif(PCOUNT() > 0, lGrav := U, lGrav)},oPanel, aPosObj[7, 03],aPosObj[7, 04],,,,,,,,.T.,,,) //"Gravar Totalizador no Sistema"
                           	
	aColuna := { {0,0}, {0,0}, {0,0}}
 	//Linha 8 - Label do browse do sistema
  	nTam := CalcFieldSize("C",Len(cChave),0,"@!",STR0135) //Tamanho do Get Chave //"Chave"
 	aColuna[1,1] := aPosObj[08, 2]+15  
 	aColuna[1,2] := nTam
 	tSay():New( aPosObj[08, 1], aColuna[1,1]  , { || STR0135 } ,oPanel,,,,,,.T.,,,  ,  )  //"Chave"
 	
 	aColuna[2,1] := aColuna[1, 1] + nTam + nSepComp 
  	nTam := CalcFieldSize("C",Len(cSecao),0,"@!",STR0136) //Tamanho do Get Seção //"Seção"
    aColuna[2,2] := nTam	
 	tSay():New( aPosObj[08, 1], aColuna[2,1]  , { || STR0136 } ,oPanel,,,,,,.T.,,,  ,  )   //"Seção"
   
 	aColuna[3,1] := aColuna[2, 1] + nTam + nSepComp  
 	nTam := CalcFieldSize("C",Len(cArquivo),0,"@!",STR0137) //"Arquivo"
 	aColuna[3,2] := nTam
	tSay():New( aPosObj[08, 1], aColuna[3,1]  , { || STR0137 } ,oPanel,,,,,,.T.,,,  ,  )   //"Arquivo"
	
 	//Linha 9 - Gets do browse do Sistema - não editável
	oGet3 := TGet():New( aPosObj[09, 1],aColuna[1,1],{ |U| Iif(PCOUNT() > 0, cChave := U, cChave)},oPanel, aColuna[1,2],10,"",{|| .t.},,, ,.T.,, .T.,, .T.,            , .F., .f.,, .T., .F. ,,"cChave",,,,.T.,) 
	oGet4 := TGet():New( aPosObj[09, 1],aColuna[2,1],{ |U| Iif(PCOUNT() > 0, cSecao := U, cSecao)},oPanel, aColuna[2,2],10,"",{ || .T.},,,, .T.,, .T.,, .T.,            , .F., .F.,, .T., .F. ,,"cSecao",,,,.T.,) 
	oGet5 := TGet():New( aPosObj[09, 1],aColuna[3,1],{ |U| Iif(PCOUNT() > 0, cArquivo := U, cArquivo)},oPanel, aColuna[3,2],10,,,,,, .T.,, .T.,, .T.,            , .F., .F.,, .T., .F. ,,"cArquivo",,,,.T.,) 

Return     

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrTg
Função para programação para totalizador
@param nTotaliz   	Numero do Totalizador
@param cDescr     	Descrição do totalizador
@param cChave		Chave do arquivo de totalizador
@param cSecao		Secao do arquivo de totalizador
@param cArquivo    	Arquivo de totalizador
@param aTotNFisc	Array dos totalizadores nao-fiscais do ECF
@param aTotPtr		Array dos totalizadores do Sistema
@param lGrav		Gravar o arquivo configuração
@param cLog			Log de Execução da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lPross		Totalizador programado
@obs
@sample
/*/
//------------------------------------------------------------------

Function STFWzPrTg( nTotaliz, cDescr, 	cChave, 	cSecao, ;
					cArquivo, aTotNFisc, aTotPtr, 	lGrav, ;
					cLog, nEspacos)

Local aRet 		:= {}   //Retorno da funcao
Local lPross 	:= .T.	//Retorno da funcao 
Local aDados 	:= {"17", space(30)} //Dados da rotina 
Local nPos 		:= 0 	//Posicao do array 
Local lTudo 	:= .F.	//Grava tudo
Local cTotaliz 	:= ""	//Codigo do totalizador 
Local nPosT 	:= 0	//Posicao do totalizador
Local nPosP 	:= 0	//Posicao do totalizador   
Local cValor 	:= "" 	//Valor do totalizador 
Local cLogT 	:= ""	//Log temporario
Local nEspacoT 	:= 0	//Espaco temporario
Local cTxtTmp 	:= ""	//Texto temporario

DEFAULT nTotaliz 	:= 0  	//Codigo do totalizador
DEFAULT cDescr 		:= ""	//Descricao do totalizador
DEFAULT cChave 		:= ""	//Chave do arquivo de configuracao
DEFAULT cSecao 		:= ""	//Secao do totalizador
DEFAULT cArquivo 	:= ""	//Arquivo do totalizador 
DEFAULT aTotNFisc 	:= {}	//Array de totalizadores não-fiscais 
DEFAULT aTotPtr 	:= {}	//Array de totalizadores do protheus 	
DEFAULT lGrav 		:= .F.	//Grava o arquivo de totalizadores
DEFAULT	cLog 		:= ""	//Log de execucao
DEFAULT nEspacos 	:= 5	//Espacos de execucao

	lTudo := cTotaliz == "0"
    
   	nEspacoT := nEspacos + 5
	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STPrinterStatus"																,;		// Nome do evento
								{"8"													,;	
								" "} )
	
	
	If Len(aRet) > 0 .AND. aRet[1] == 10
		//Redução Z Pendente
		cTxtTmp := STR0141 //"Redução Z Pendente. Para a programação de Totalizador Não-Fiscal, faz-se necessario que seja emitida a redução Z. "
		STFMessage("Z Reduction", "STOP", cTxtTmp)
		STFShowMessage("Z Reduction")    
		lPross := .F.
		cLogT += CRLF + space(nEspacoT) + "[ERRO] " + "- " + cTxtTmp 
	Else
		aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STPrinterStatus"																,;		// Nome do evento
								aDados )  
		If Len(aDados) < 2 .OR. Len(aRet) =0  .OR. aRet[1] <> 0    
			cTxtTmp := STR0116 //"Falha ao capturar Venda Bruta diária"
			STFMessage("Printer Status", "STOP", cTxttmp )
			STFShowMessage("Printer Status")
			lPross := .F.
			cLogT += CRLF + space(nEspacoT) + STR0124 + "- " + cTxtTmp   //"[ERRO] "
		Else
			If Val(aDados[2]) >  0
				cTxtTmp := STR0117 //"Já foram realizadas vendas para este dia"
				STFMessage("Printer Status", "STOP", cTxtTmp)
				STFShowMessage("Printer Status")
				lPross := .f.
				cLogT += CRLF + space(nEspacoT) + STR0124 + "- " + cTxtTmp  //"[ERRO] "
			EndIf 			
		EndIf		
	EndIf   
	
	If lPross 
		If !lTudo
			cTotaliz := StrZero(nTotaliz,2)
			If lGrav .AND. ( nPosP :=  aScan( aTotPtr, { |p| AllTrim(p[2]) == cTotaliz .AND.; 
												AllTrim(p[4]) == AllTrim(cChave) .AND. ;
												AllTrim(p[5]) == AllTrim(cSecao)  .AND. ;
												AllTrim(p[6]) == AllTrim(cArquivo ) } ) ) > 0
				If aTotPtr[nPosP, 01] == "2"
					cTxtTmp := STR0142 //"Totalizador já programado."
	 				STFMessage("TOTPROG","STOP",cTxtTmp) //STR
			
					STFShowMessage("TOTPROG") 
					lPross := .F.     
					
					cLogT += CRLF + space(nEspacoT) + STR0124 + "- " + cTxtTmp //"[ERRO] "
				EndIf
			EndIf   
			If ( nPosT :=  aScan( aTotNFisc, { |t| AllTrim(t[1]) == cTotaliz .AND. ;
												Upper(AllTrim(t[2]))  == Upper(AllTrim(cDescr)) } ) ) > 0 
				cTxtTmp := STR0142 //"Totalizador já programado."
 				STFMessage("TOTPROG","STOP",cTxtTmp) //STR
		
				STFShowMessage("TOTPROG") 
				lPross := .F.
				cLogT += CRLF + space(nEspacoT) + STR0124 + "- " + cTxtTmp //"[ERRO] "
			EndIf
			
			If lPross
				//Prossegue então programa a alíquota 
				
				aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STNotFiscalTotal"																,;		// Nome do evento
								{cTotaliz, cDescr}) 
				
				
				If Len(aDados) < 2 .OR. Len(aRet) = 0  .OR. aRet[1] <> 0  
					cTxtTmp := STR0143 + cTotaliz + " " + cDescr //"Falha ao Programar Totalizador "
					STFMessage("TOTPROGERR","STOP", cTxtTmp ) //STR
					STFShowMessage("TOTPROGERR")
					lPross := .F.  
					cLogT += CRLF + space(nEspacoT) + STR0124 + " - " + cTxtTmp //"[ERRO] "###"- "
                Else
                	
                	If nPosP > 0
	                	If aTotPtr[nPosP, 01] <> "3" .AND. aTotPtr[nPosP, 07] > 0  //Nao Identificado  sem coluna de gravação
	                		cValor := IIF(aTotPtr[nPosP, 07] == 1,cTotaliz, cDescr) 
	                		WritePProString(aTotPtr[nPosP, 04] , aTotPtr[nPosP, 05], cValor, aTotPtr[nPosP, 06]) 
	                	EndIf 
	                	aTotPtr[nPosP, 01] := "2" //Programado
	                	aTotPtr[nPosP, 02] := cTotaliz
	                	aTotPtr[nPosP, 03] := cDescr
                	EndIf  
                	
                	aAdd(aTotNFisc, {cTotaliz, cDescr})
                EndIf
                
				
			EndIf 

		EndIf	

	
	EndIf 
	nTotaliz := 0
	cDescr := space(30)   
	
	cLog += CRLF + space(nEspacos) +  IIF(lPross, "", STR0124) + STR0145 + cLogT //"[ERRO] "###"- Programando Totalizador Não-Fiscal"
	
Return lPross   


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzGrTg
Função para gravação do totalizador
@param nTotaliz   	Numero do Totalizador
@param cDescr     	Descrição do totalizador
@param cChave		Chave do arquivo de totalizador
@param cSecao		Secao do arquivo de totalizador
@param cArquivo    	Arquivo de totalizador
@param aTotPtr		Array dos totalizadores do Sistema
@param lGrav		Gravar o arquivo configuração
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lPross		Totalizador gravado no arquivo de totalizador
@obs
@sample
/*/
//------------------------------------------------------------------
Function STFWzGrTg( nTotaliz, cDescr, 	cChave, cSecao,;
					cArquivo, aTotPtr, 	lGrav,	cLog,;
					nEspacos)
					   
Local lPross 	:= .T.	//Execucao da rotina  
Local nPos 		:= 0	//Posicao do array  
Local lTudo 	:= .F.	//Programa todos os totalizadoresa
Local cTotaliz 	:= ""	//Codigo do totalizador 
Local nPosP 	:= 0 	//Posicao do totalizador  
Local cValor 	:= ""	//Valor do totalizador
Local cLogT 	:= ""	//Log temporario
Local nEspacoT 	:= 0 	//Espaco temporario 
Local cTxtTmp 	:= ""	//Arquivo texto

DEFAULT nTotaliz := 0 	//Codigo do totalizador
DEFAULT cDescr 	:= ""	//Descricao do totalizador
DEFAULT cChave 	:= ""	//Chave do totalizador
DEFAULT cSecao 	:= ""	//Secao do totalizador
DEFAULT cArquivo:= ""	//Arquivo do totalizador
DEFAULT aTotPtr	:= {}	//Totalizador do sistema
DEFAULT lGrav 	:= .F.	//Grava o arquivo
DEFAULT cLog 	:= ""	//Log de execucao
DEFAULT nEspacos:= 5	//Espacos do log

	
	lTudo := cTotaliz == "0" 
	
	nEspacoT := nEspacos + 5

	If !lTudo
		cTotaliz := StrZero(nTotaliz,2)
		If ( nPosP :=  aScan( aTotPtr, { |p| AllTrim(p[2]) == cTotaliz .AND.; 
											AllTrim(p[4]) == AllTrim(cChave) .AND. ;
											AllTrim(p[5]) == AllTrim(cSecao)  .AND. ;
											AllTrim(p[6]) == AllTrim(cArquivo ) } ) ) > 0
			If aTotPtr[nPosP, 01] == "2"
			    cTxtTmp := STR0146 //"Totalizador já configurado"
 				STFMessage("TOTPROG","STOP", cTxtTmp) //STR
				STFShowMessage("TOTPROG") 
				cLogT := CRLF + space(nEspacoT) + STR0027 + cTxtTmp //"[ERRO] - "
				lPross := .F.
			EndIf
		Else

			If  ( nPosP :=  aScan( aTotPtr, { |p| AllTrim(p[4]) == AllTrim(cChave) .AND. ;
											AllTrim(p[5]) == AllTrim(cSecao)  .AND. ;
											AllTrim(p[6]) == AllTrim(cArquivo ) } ) ) = 0

                cTxtTmp := STR0147 //"Totalizador não cadastrado no sistema"
 				STFMessage("TOTPROG","STOP", cTxtTmp) //STR
		
				//lPross := 
				STFShowMessage("TOTPROG") 
				lPross := .F. 
				cLogT := CRLF + space(nEspacoT) + STR0027 + cTxtTmp //"[ERRO] - "
			EndIf
							
		EndIf   

		
		If lPross
                	
			If nPosP > 0
                	If aTotPtr[nPosP, 01] <> "3" .AND. aTotPtr[nPosP, 07] > 0  //Nao Identificado  sem coluna de gravação
                		cValor := IIF(aTotPtr[nPosP, 07] == 1,cTotaliz, cDescr) 
                		WritePProString(aTotPtr[nPosP, 04] , aTotPtr[nPosP, 05], cValor, aTotPtr[nPosP, 06]) 
                	EndIf 
                	aTotPtr[nPosP, 01] := "2" //Programado
                	aTotPtr[nPosP, 02] := cTotaliz
                	aTotPtr[nPosP, 03] := cDescr
                EndIf                 
			
		EndIf 

	EndIf	
	nTotaliz := 0
	cDescr := space(30)  
	
	cLog += CRLF + space(nEspacos) + IIF(lPross, "", STR0072) + STR0148  //"[ERRO]"###" - Realizando a gravação dos Totalizadores Não-Fiscais nos arquivos do Sistema"

Return lPross

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdFIF
Carrega as formas de pagamento do ECF
@param cLG_CODIGO	Codigo da Estacao
@param cImpFisc		Impressora Fiscal
@param cPorta		Porta da Impressora Fiscal
@param lConecta		Impressora Conectada
@param aFormaECF	Forma de pagamento da impressora
@param lTotvsApi	Impressora utiliza TotvsApi? 
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet		Forma de pagamento extraída com sucesso
@obs
@sample
/*/
//------------------------------------------------------------------
Function STFWzLdFIF(cLG_CODIGO, cImpFisc, 	cPorta, lConecta,;
					aFormaECF, 	lTotvsApi,	cLog,	nEspacos)
					  
Local lRet 		:= .T. 	//Retorno da rotina
Local aRet 		:= {} 	//Retorno do Strategy      
Local aDados	:= {}	//Dados de retorno da funcao  
Local cLogT 	:= ""	//log temporario
Local nEspacoT 	:= 0	//Espaco temporario	

DEFAULT cLG_CODIGO 	:= ""	//Codigo da Estacao
DEFAULT cImpFisc 	:= ""	//Modelo de Impressora fiscal
DEFAULT cPorta 		:= ""	//Porta de Comunicação
DEFAULT lConecta 	:= .F.	//Impressora Conectada
DEFAULT aFormaECF 	:= {}	//Forma de pagamento cadastrada no ECF
DEFAULT lTotvsApi 	:= .F.	//Impressora cadastrada na totvsApi
DEFAULT cLog 		:= ""	//Log de execucao da rotina
DEFAULT nEspacos 	:= 5	//Espacos de execucao da rotina 
	
	nEspacoT := nEspacos + 5
	
	 aFormaECF := {}  
      
      If !lConecta 
        If Empty(cImpFisc) 
        
            cImpFisc := STFGetStat("IMPFISC")
      	EndIf
      	If Empty(cPorta)
      		cPorta := STFGetStat("PORTIF")
      	EndIf
      	
		lConecta := lRet := STFWzCIF(cImpFisc, cPorta, @cLogT, nEspacoT) 
 
      EndIf
      
      If lRet  
      
      	//vERIFICA SE É TOTVSAPI
      	aDados := {space(30)}
      	aRet := STFFireEvent(	ProcName(0) ,;
      							 "STRetTypePrt", ;	
				   					aDados )  
		If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0 .AND. ValType(aDados[1]) == "C"
			lTotvsApi :=  aDados[1] == "TOTVSAPI"
		EndIf
	  
	  EndIf
      
      If lRet 
      		//Busca as Formas de pagamento
           aDados := {space(300), NIL} 
           aRet := STFFireEvent(	ProcName(0) ,;		// Nome do processo
 									"STGetConPay"																,;		// Nome do evento 
 									aDados )
 													  
 		   If Len(aRet) > 0 .AND. aRet[1] == 0  .AND. Len(aDados) > 0 
 		   	
 		   		aFormaECF := StrTokArr( aDados[1] , "|" )
 														 
  			Else
 				
 				lRet := .F.
 			EndIf												     		

      EndIf

     
	cLog += CRLF + space(nEspacos )+ IIF(lRet, "", STR0072) + STR0149 + cLogT //"[ERRO]"###" - Verificando formas de pagamento cadastradas no ECF"
      
Return lRet          

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdFP
Carrega as formas de pagamento do sistema
@param cLG_CODIGO	Codigo da Estacao
@param cImpFisc		Impressora Fiscal
@param cPorta		Porta da Impressora Fiscal
@param aFormaPtr	Formas de pagamento do Protheus
@param aFormaECF	Forma de pagamento da impressora
@param lTotvsApi	Impressora utiliza TotvsApi? 
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return  lRet		Forma de pagamento extraída com sucesso
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzLdFP(	cLG_CODIGO, cImpFisc,  	aFormaPtr, aFormaECF,;
					lTotvsApi,	cLog,		nEspacos) 	
	
Local cGetCliDir := GetClientDir() 	//Local do smartclient
Local cStatus 	:= "2" 				//Não  Programado
Local nPos		:= 0				//Posicao do array 
Local cDescTot 	:= ""				//Descricao do totalizador   
Local nC 		:= 0				//Variavel contadora  
Local aAreaSAE 	:= {}				//WorkArea SAE
Local aAreaMDE 	:= {}				//WorkArea MDE
Local aArea 	:= GetArea()		//WorkArea ativa  
Local cForma 	:= ""				//Forma de pagamento     
Local aAreaSX5 	:= SX5->(GetArea())	//Descricao da tabela SX5
Local cTabela	:= PadR( "24" , LEN(SX5->X5_TABELA) ) //Chave da tabela 24 - Formas de pagamento   
Local cFilialX5 := SX5->(xFilial() )	//Filial SX5 
Local lPOS 		:= FindFunction("STFIsPOS") .AND. STFIsPOS() //Pos?
		
DEFAULT cLG_CODIGO 	:= "	"	//Codigo da Estacao
DEFAULT cImpFisc 	:= ""		//Impressora Fiscal
DEFAULT aFormaECF 	:= {} 		//Chave, Seção, Valor, Arquivo - (se em branco e porque a impressora fiscal não é totvsapi, nesse caso não grava)  
DEFAULT aFormaPtr 	:= {} 		//Forma de pagamento do sistema
DEFAULT lTotvsApi 	:= .F.		//impressora totvsApi?
DEFAULT cLog 		:= ""		//log da impressora fiscal
DEFAULT nEspacos 	:= 5		//espacos do log    
	
	 aFormaPtr := {} 

	//Carrega os totalizadores da Sigaloja.ini
	//Recebimento de Títulos  
	cForma := GetPvProfString("Condicao de Pagamento", "Retencoes", "RETENCOES", cGetCliDir+"SIGALOJA.INI")	
    aAdd(aFormaPtr , {"" ,  AllTrim(cForma), "Retencoes","Condição de Pagamento de Retenções " +  cGetCliDir+"SIGALOJA.INI"})
	cForma := GetPvProfString("Recarga Celular", "FormaPgto", " ", cGetCliDir+"SIGALOJA.INI" )	
    If !Empty(cForma) //to do Validar sitef
    	aAdd(aFormaPtr , { "",  Alltrim(cForma), "Recarga Celular", STR0150 +  cGetCliDir+"SIGALOJA.INI"})    //"Forma de pagamento para recarga de celular Sitef "
    EndIf
	
	cForma := &(SuperGetMV("MV_NATRECE", NIL, '"RECEBIMENTO"')) 
	
	If !Empty(cForma)
   		aAdd(aFormaPtr , { "",  AllTrim(cForma), "Recebimento", "Recebimento de títulos - parâmetro MV_NATRECE " +  cGetCliDir+"SIGALOJA.INI"})   
    EndIf

	//Busca as formas de pagamento
	If SX5->(DbSeek(cFilialX5 + cTabela))
		Do While SX5->(!Eof() .AND. X5_FILIAL + X5_TABELA == cFilialX5 + cTabela)
   			aAdd(aFormaPtr , { "",  AllTrim(SX5->(X5Descri())), SX5->X5_CHAVE, STR0151})   						 //"Forma de Pagamento tabela 24"
			SX5->(DbSkip(1))
		EndDo 
			
    EndIf
	
	If lTotvsApi 
		cForma 	:= GetPvProfString("Microsiga", "FormaPgto", "A VISTA", cGetCliDir + "TOTVSAPI.INI")	
   		aAdd(aFormaPtr , { "",  AllTrim(cForma), "FormaPgto", STR0152 +  cGetCliDir+"TOTVSAPI.INI"})    //"Forma de Pagamento para Pedido"
	EndIf 
	
	If "DARUMA FS345" $ cImpFisc 
		cForma := GetPvProfString("DARUMA", "SUPRIMENTO", "", cGetCliDir+"SIGALOJA.INI")
		If !Empty(cForma)
   			aAdd(aFormaPtr , { "",  AllTrim(cForma), "SUPRIMENTO", STR0153  +  cImpFisc})   			 //"Forma de Suprimento da Impressora "
		EndIf 
	EndIf
	    
	
	IF SuperGetMV("MV_LJPAGTO", NIL, 1) == 2   
		aAreaSAE := SAE->(GetArea())	 //WorkArea Anteriror SAE
		aAreaMDE := MDE->(GetArea())   //WorkArea Anterior MDE
			
		DbSelectArea("MDE") 
		MDE->(DbSetOrder(1))  //MDE_FILIAL+MDE_CODIGO
		DbSelectArea("SAE")
		DbSetOrder(1) //AE_FILIAL+AE_COD
		DbSeek(xFilial("SAE"))    
		
		While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")   		
				//Ascan para nã duplicar  a descrição
			If ( lPOS .OR. SuperGetMv("MV_LJADMFI",,.F.) ) .AND. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART ))                                                                                                               //7
				cForma :=  AllTrim(	MDE->MDE_DESC)
			Else                                                                                                                                                          //7
				cForma := AllTrim(SAE->AE_DESC)
			EndIf   
			
			If (nPos :=  aScan( aFormaPtr, { |p| Upper(p[2]) == Upper(cForma) })    ) = 0  
  				aAdd(aFormaPtr , { "",  AllTrim(cForma), STR0154 + SAE->AE_ADMCART, STR0155})   			 //"Adm Fin "###"Administradora TEF"
			EndIf
	
			SAE->(DbSkip()) 
			
			
		End

		RestArea(aAreaSAE)
     	RestArea(aAreaMDE)
     	

	EndIf    
     	//Realiza a consistência
 	For nC := 1 to Len(aFormaPtr)
  		If aScan(aFormaECF, { |e| AllTrim(e) == aFormaPtr[nC, 02] } ) > 0
    		aFormaPtr[nC, 01] := "2" //programado
     	Else
     		aFormaPtr[nC, 01] := "1" //Não Programado
     	EndIf
     		
    Next nC		
	RestArea(aAreaSX5)
    RestArea(aArea) 
    
    cLog += CRLF + space(nEspacos) + STR0156 //"Capturando as Formas de Pagamento do Sistema."
	
Return .T.	

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrFP
Interface para programacao das formas  de pagamento
@param cLG_CODIGO	Codigo da Estacao
@param aFormaPtr	Formas de pagamento do Protheus
@param aFormaECF	Forma de pagamento da impressora
@param lTotvsApi	Impressora utiliza TotvsApi? 
@param oDLG			Janela
@param nPanel		Painel atual
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzPrFP(cLG_CODIGO, aFormaPtr, 	aFormaECF, lTotvsApi, ;
					oDLG, 		nPanel,		cLog, 		nEspacos) 
    
Local oBmp2   	:= LoadBitmap(GetResources(),'br_verde')  	//Objeto BMP programado
Local oBmp1   	:= LoadBitmap(GetResources(),'br_vermelho')	//Objeto BMP nao programado 
Local aObjects 	:= {}										//Objetos da janela
Local aPosObj 	:= {}										//Posicao dos objetos
Local cDescr 	:= space(20)								//Descricao dos objetos
Local oBrowseECF:= NIL										//Browse do ECF
Local oBrowsePtr:= NIL										//Browse do Protheus
Local nRow 		:= 0  										//Linhas do Panel
Local nCol 		:= 0  										//Colunas do panel     
Local nLargB 	:= 0										//Largura do Browse    
Local nSepComp 	:= 3										//Separacao dos componentes   
Local oGet1 	:= NIL										//Get1 
Local oBtn1 	:= NIL										//Botao1   
Local nColT 	:= 0										//coluna temporaria

DEFAULT cLG_CODIGO	:= SLG->(CriaVar("LG_CODIGO"))			//codigo da estacao     	
DEFAULT oDlg 		:= NIL 									//janela
DEFAULT aFormaPtr 	:= {}                                   //forma de pagamento do sistema
DEFAULT aFormaECF 	:= {} 									//forma de pagamento do ECF
DEFAULT lTotvsApi 	:= .F.									//totvsApi
DEFAULT nPanel 		:= 1  									//Panel atual
DEFAULT cLog 		:= ""									//log da rotina
DEFAULT nEspacos 	:= 5									//Espacos
 
	oPanel := oDlg:GetPanel(nPanel)   
	nRow		:= Int( oPanel:nHeight/2)  //Linha do Painel
	nCol := Int( oPanel:nWidth/ 2)
	oPanel := TScrollBox():New( oPanel, 0,0,nRow,nCol)  
	nCol := Int( nCol *.97 )
	nLargB 		:= 	(nCol/4) - 10
	
	nTam := CalcFieldSize("C",Len(STR0157),0,"@!",STR0157)  //1 //"Formas cadastradas no ECF"###"Formas cadastradas no ECF"
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //1
	aAdd(aObjects,  { nLargB, 150+10, .F., .F.}) //Browse //2 
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line 3 
 	nTam := CalcFieldSize("C",Len(STR0158),0,"@!",STR0158)   //"Programar Forma"###"Programar Forma"
	aAdd(aObjects,  { nTam, 12, .F., .F.}) //4  
	aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //5
	aAdd(aObjects,  { 55, 15, .F., .F.})    //6 botão programar 
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line 7 
	aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line 8	
		

 
	
	aPosObj := MsObjSize( { 0 , 15 , nRow ,nCol, nSepComp, 3,3,3}, aObjects, .T., .F.)  
	
	
	//oPanel := oDlg:GetPanel(nPanel)   
	
	//Monta o TCBrowse
   	tSay():New( aPosObj[01, 1],  aPosObj[01, 2]  , { || STR0157 } ,oPanel,,,,,,.T.,,,  ,  ) //"Formas cadastradas no ECF"
	
	oBrowseECF := TCBrowse():New( aPosObj[02,01] , aPosObj[02,02], aObjects[02,01], aObjects[02,02], ,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )       
	oBrowseECF:SetArray(aFormaECF) 
	oBrowseECF:AddColumn(TCColumn():New(STR0133,{|| aFormaECF[oBrowseECF:nAt] },"",,,"LEFT",CalcFieldSize("C",Len(cDescr),0,"@!",STR0133),.F.,.F.,,,,,)) //"Descrição"###"Descrição"

 	tSay():New( aPosObj[01, 1],  nLargB + 10  , { || STR0159 } ,oPanel,,,,,,.T.,,,  ,  ) //"Formas de Pagamento do sistema"
	oBrowsePtr := TCBrowse():New( aPosObj[02,01] , aObjects[02,01]+13, nCol-(aObjects[02,01]+13), aObjects[02,02],,,,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,, )       
 	oBrowsePtr:SetArray(aFormaPtr) 
   	oBrowsePtr:AddColumn(TCColumn():New(STR0104,{|| IIF(aFormaPtr[oBrowsePtr:nAt,01] == "1", oBmp1, oBmp2) },"",,,"LEFT",CalcFieldSize("C",2,0,"@!",STR0104),.T.,.F.,,,,,))  //"Status"###"Status"
    oBrowsePtr:AddColumn(TCColumn():New(STR0160,{|| aFormaPtr[oBrowsePtr:nAt,02] },"@!",,,"LEFT",CalcFieldSize("C",Len(cDescr),0,"@!",STR0160),.F.,.F.,,,,,))  //"Forma"###"Forma"
	oBrowsePtr:AddColumn(TCColumn():New(STR0135,{|| aFormaPtr[oBrowsePtr:nAt,03] },"@!",,,"LEFT",CalcFieldSize("C",30,0,"@!",STR0135),.F.,.F.,,,,,)) //"Chave"###"Chave"
	oBrowsePtr:AddColumn(TCColumn():New(STR0133,{|| aFormaPtr[oBrowsePtr:nAt,04] },"@!",,,"LEFT",CalcFieldSize("C",60,0,"@!",STR0161),.F.,.F.,,,,,)) //"Descrição"###"Descricao"
    oBrowsePtr:bChange   := {|| IIF(ValType(oGet1) == "O", ( cDescr := aFormaPtr[oBrowsePtr:nAt,02], oGet1:Refresh(), oBtn1:Refresh()) , NIL ) }
 	oBrowsePtr:BHeaderClick := { ||  STFWzShowLg( { 	{"BR_VERDE",	STR0109},; 	 //"Programado"
				   										{"BR_VERMELHO", STR0110}; 	 //"Não programado"
											      }, STR0162 ) }	 //"Legenda Formas Pagto"
	
 	@aPosObj[03,01], 5 to aPosObj[08, 1] ,nCol OF oPanel PIXEL 	 
	tSay():New( aPosObj[04, 1],  aPosObj[04, 2]+15  , { || STR0163 } ,oPanel,,,,,,.T.,,,  ,  ) //"Programar Forma de Pagamento"
   
    //Linha 5 - label da Programação
 	nTam := CalcFieldSize("C",Len(cDescr),0,"@!",STR0160) //Tamanho do Get Forma //"Forma"
 	tSay():New( aPosObj[05, 1], aPosObj[05, 2]+15  , { || STR0160 } ,oPanel,,,,,,.T.,,,  ,  )  //"Forma"
 	
 
 	//Linha 6 - Gets da Programação 
 	nCol :=aPosObj[06, 2] + 15 
	oGet1 := TGet():New( aPosObj[06, 1],nCol,{ |U| Iif(PCOUNT() > 0, (cDescr := U, oBtn1:Refresh()), cDescr)},oPanel, nTam,10,"@!",{|| !Empty(cDescr) },,,, .T.,, .T.,, .T.,            , .F., .F.,, .f., .F. ,,"cDescr",,,,.T.,) 
 	nCol += nTam + (nSepComp *2)
   	oBtn1 := TButton():New(aPosObj[06, 1],nCol, STR0112,oPanel,{||  IIF( STFWzPrFg( @cDescr, @aFormaECF, @aFormaPtr, @cLog, ; //"Programar"
   																						nEspacos),;
   																					(oBrowseECF:SetArray(aFormaECF), oBrowsePtr:SetArray(aFormaPtr)), ), ;
   																					oGet1:Refresh() },aObjects[06,01],aObjects[06,02],,,.F.,.T.,.F.,,.F.,{ || !Empty(cDescr) },,.F. )
   	nCol += aObjects[06,01] + (nSepComp *2)
    TButton():New(aPosObj[06, 1],nCol, STR0113,oPanel,{||  IIF( STFWzPrFg( "", @aFormaECF, @aFormaPtr, @cLog,; //"Programar Tudo"
    																				nEspacos),;
    																	 (oBrowseECF:SetArray(aFormaECF), oBrowsePtr:SetArray(aFormaPtr)), ), ;
    																	 oGet1:Refresh() , oBtn1:Refresh()},aObjects[06,01],aObjects[06,02],,,.F.,.T.,.F.,,.F.,{ || .t.  },,.F. )

Return	     

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrFg
Funcao para programacao das formas  de pagamento
@param cDescr		Forma de pagamento
@param aFormaECF	Forma de pagamento da impressora
@param aFormaPtr	Formas de pagamento do Protheus
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return lPross		Programacao realizada com sucesso
@obs
@sample
/*/
//------------------------------------------------------------                                                        
Function STFWzPrFg( cDescr, aFormaECF, aFormaPtr, cLog,;
					nEspacos) 

	Local aRet := {} 
	Local lPross := .T. 
	Local aDados := {"17", space(30)}  
	Local lTudo := .F.
	Local cTotaliz := "" 
	Local nPosT := 0
	Local nPosP := 0   
	Local cValor := ""
	Local nC := 0  
	Local nPos := 0
	Local cTxtTmp := ""
	Local cLogT := ""
	Local nEspacoT := 0
	
	DEFAULT cDescr := ""
	DEFAULT aFormaECF := {}
	DEFAULT aFormaPtr := {}
	DEFAULT cLog := ""
	DEFAULT nEspacos := 5
	
	lTudo := Empty(cDescr)
	nEspacoT := nEspacos + 5

	
	aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STPrinterStatus"																,;		// Nome do evento
								{"8"													,;	
								" "} )
	
	
	If Len(aRet) > 0 .AND. aRet[1] == 10
		//Redução Z Pendente
		cTxtTmp := STR0164 //"Redução Z Pendente. Para a programação de Forma de Pagamento, faz-se necessario que seja emitida a redução Z. "
		STFMessage("Z Reduction", "STOP", cTxtTmp)
		STFShowMessage("Z Reduction")    
		lPross := .F. 
		cLogT := CRLF + space(nEspacoT) + cTxtTmp
	Else
		aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STPrinterStatus"																,;		// Nome do evento
								aDados )  
		If Len(aDados) < 2 .OR. Len(aRet) =0  .OR. aRet[1] <> 0    
			cTxtTmp := STR0165 //"Falha ao capturar Venda Bruta diária."
			STFMessage("Printer Status", "STOP", cTxtTmp)
			STFShowMessage("Printer Status")
			lPross := .F. 
			cLogT := CRLF + space(nEspacoT) + cTxtTmp 
		Else
			If Val(aDados[2]) >  0
				cTxtTmp := STR0166 //"Já foram realizadas vendas para este dia."
				STFMessage("Printer Status", "STOP", cTxtTmp)
				STFShowMessage("Printer Status")
				cLogT := CRLF + space(nEspacoT) + cTxtTmp
				lPross := .F. 
			EndIf 			
		EndIf		
	EndIf   
	
	If lPross 
		If !lTudo
  
			
			If ( nPosT :=  aScan( aFormaECF, { |t|  AllTrim(t) == AllTrim(cDescr) } ) ) > 0 
			    cTxtTmp := STR0167 //"Totalizador já programado"
 				STFMessage("FORMPROG","STOP", cTxtTmp) //STR
		
				STFShowMessage("FORMPROG") 
				lPross := .F. 
				cLogT := CRLF + space(nEspacoT) + cTxtTmp

			EndIf
			
			If lPross
				//Prossegue então programa o totalizador
				
				aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
								"STRecCondPay"																,;		// Nome do evento
								{cDescr}) 
				
				
				If Len(aDados) < 2 .OR. Len(aRet) = 0  .OR. aRet[1] <> 0  
					cTxtTmp := STR0168 + cDescr //"Falha ao programar forma de pagamento "
					STFMessage("FORMPROGERR","STOP", cTxtTmp) 
					STFShowMessage("FORMPROGERR")
					lPross := .F.
					cLogT := CRLF + space(nEspacoT) + cTxtTmp  
                Else
                	
                	nC := 0
                	Do While (nC := nC + 1) <= Len(aFormaPtr)
                		If AllTrim(aFormaPtr[nC, 02])  ==  AllTrim(cDescr) .AND. aFormaPtr[nC,1] == "1" 
	                	//Como pode existir vários  totalizadores iguais, atualiza tudo
	                		aFormaPtr[nC, 01] := "2" //Programado
						EndIf 
                	EndDo 
                	
                	aAdd(aFormaECF, cDescr)
                EndIf
                
				
			EndIf 

		Else
			Do While (nPos := nPos + 1) <= Len(aFormaPtr)     
  				
				If aFormaPtr[nPos, 01] == "1" .AND. ;
					aSCan(aFormaECF, { |e| AllTrim(e) == AllTrim(aFormaPtr[nPos, 02])} ) == 0 // vERIFICAR SE O TOTALIZADOR NÃO EXISTE A FORMA ecf //Não programado 		
					aRet :=	STFFireEvent(	ProcName(0)																,;		// Nome do processo
									"STRecCondPay"																,;		// Nome do evento
									{ AllTrim(aFormaPtr[nPos, 02])} )  
					lPross := Len(aRet) > 0 .AND. aRet[1] == 0   
					
					If lPross  
						aAdd(aFormaECF, AllTrim(aFormaPtr[nPos, 02]))
	                    cDescr := AllTrim(aFormaPtr[nPos, 02] )
	                	nC := nPos
	                	Do While (nC := nC + 1) <= Len(aFormaPtr)	                	    	                	
		                	If AllTrim(aFormaPtr[nC, 02])  ==  AllTrim(cDescr) .AND. aFormaPtr[nC,1] == "1" 
			                	//Como pode existir vários  totalizadores iguais, atualiza tudo
			                	aFormaPtr[nC, 01] := "2" //Programado	
		                	EndIf 
	                	EndDo 
	
	
					Else
			 			
			 			cTxtTmp := STR0169 + aFormaPtr[nPos, 02] //"Falha ao programar Forma de pagamento: "
			 			STFMessage("FORMPROGERR","STOP",cTxtTmp ) //STR
					
						STFShowMessage("FORMPROGERR") 
						cLogT := CRLF + space(nEspacoT) + cTxtTmp				
						Exit
					EndIf

				EndIf
			EndDo

		
		EndIf	

	
	EndIf 	
	cDescr := space(20)
	
	cLog += CRLF + space(nEspacos) + IIF(lPross,"",STR0072) + STR0170 + IIF(!lTudo," ", STR0120) + STR0171 + cLogT   //"[ERRO]"###" - Programando forma"###"s "###" de pagamento"
	
Return lPross 

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrHP
Interface para programacao do horário de verao
@param cLG_CODIGO	Codigo da estacao
@param cImpfisc		Impressora Fiscal
@param lConecta		Impressora Conectada
@param oDLG			Janela
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return lRet		Programacao realizada com sucesso
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzPrHP(cLG_CODIGO, 	cImpFisc, lConecta, oDLG, ;
					nPanel, 	cLog,		nEspacos) 
					
Local lRet    	:= .T. 		//Retorno da rotina
Local aDados 	:= {}		//Dados retornados pelo ECF 
Local dDataPrt 	:= CtoD("")	//Data do Protheus
Local cHoraPrt 	:= ""		//Hora do Protheus
Local dDataECF 	:= CtoD("")	//Data do ECF
Local cHoraECF 	:= ""		//Hora do ECF
Local nDiff 	:= 0 		//Diferença (em minutos)	
Local oGet1 	:= NIL		//Item a ser programado		
Local oGet2 	:= NIL		//Item a ser programado
Local oGet3 	:= NIL		//Item a ser programado
Local nAdic 	:= 1 		//Adiciona/Avança 
Local aObjects 	:= {}		//Array do objetos
Local aPosObj 	:= {}		//Posicao dos objetos
Local nSepComp 	:= 3		//Separacao de componentes 
Local oPanel 	:= NIL		//Panel
Local nRow 		:= 0		//Linha
Local nCol 		:= 0		//Coluna  
Local cDtHrECF 	:= ""		//Data/Hora do ECF
Local cDtHrPrt 	:= ""		//Data/Hora do Protheus
Local nCol2 	:= 0 		//Coluna 
Local oAdic 	:= NIL		//Adiciona 
Local oBtn1 	:= NIL		//Botao1
Local cLogT 	:= ""		//log temporario
Local nEspacoT 	:= 0		//espaco temporario 

DEFAULT cLG_CODIGO 	:= SLG->(CriaVar("LG_CODIGO")) //Codigo da Estacao
DEFAULT oDlg 		:= NIL	//Janela
DEFAULT cImpFisc 	:= ""   //Impressora fiscal
DEFAULT lConecta 	:= .F.	//Impressora Conectada
DEFAULT oDlg 		:= NIL	//Janela
DEFAULT nPanel 		:= 1  	//Panel atual
DEFAULT cLog 		:= ""	//Log
DEFAULT nEspacos 	:= 5	//Espaco temporario

    nEspacoT := nEspacos + 5
	If !lConecta 
		If Empty(cImpFisc) 
		        
			cImpFisc := STFGetStat("IMPFISC")
		EndIf
		If Empty(cPorta)
			cPorta := STFGetStat("PORTIF")
		EndIf
	      	
		lConecta := lRet := STFWzCIF(cImpFisc, cPorta, @cLogT, nEspacoT) 
	 
	EndIf

  	cLog += cLogT
	      
	lRet  := lRet .AND. STFWzLdHC( @dDataECF,  @cHoraECF, @dDataPrt,  @cHoraPrt, ;
						@cDtHrECF , @cDtHrPrt , @nAdic, 	oGet1, ;
						oGet2, 		oGet3, 		oBtn1,	   			,;
						@cLog,		nEspacos)
    

	
	If lRet
		//Monta os panels		
		oPanel := oDlg:GetPanel(nPanel)   
	
		nRow		:= Int( oPanel:nHeight/2)  //Linha do Painel
		nCol := Int( oPanel:nWidth/ 2)
		
		oPanel := TScrollBox():New( oPanel, 0,0,nRow,nCol)  
		nCol := Int( nCol *.97 )	
		
		nTam := CalcFieldSize("C",19,0,"@!",STR0172)  //1 //"Data/Hora do ECF"
		aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //1
		aAdd(aObjects,  { nTam, 10, .F., .F.}) //Get2
	
		nTam := CalcFieldSize("C",19,0,"@!",STR0173)  //1 //"Data/Hora da Estação"
 		aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //3
		aAdd(aObjects,  { nTam, 10, .F., .F.}) //Get4
		nTam := CalcFieldSize("N",2,0,"@!",STR0174)  //1 //"Diferença (em minutos)"
		aAdd(aObjects,  { nTam, 6, .F., .F.}) //Impar Say //5
		aAdd(aObjects,  { nTam, 10, .F., .F.}) //Impar Say //6
		aAdd(aObjects,  { 10, 6, .F., .F.}) //Blank Line 7 
			aAdd(aObjects,  { 10, 1, .F., .F.}) //Blank Line 8 

	 	nTam := CalcFieldSize("C",Len(STR0175),0,"@!",STR0175)   //"Programar Horário de Verão"###"Programar Horário de Verão"
		aAdd(aObjects,  { nTam, 12, .F., .F.}) //9  
		aAdd(aObjects,  { 55, 15, .F., .F.})    //10 botão programar /Adiciona/Avança /Refresh
		aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line11 - ATRASAR 		
		aAdd(aObjects,  { 10, 10, .F., .F.}) //Blank Line12   - LINE
		aAdd(aObjects,  { 10, 6, .F., .F.}) //Blank Line 13	
		aAdd(aObjects,  { 80, 15, .F., .F.})    //14 Imprimir página de teste
	 
		
		aPosObj := MsObjSize( { 0 , 15 , nRow ,nCol, nSepComp, 3,3,3}, aObjects, .T., .F.)  
		
	
		
		//Monta o Label dos Horários
	   	tSay():New( aPosObj[01, 01],  aPosObj[01,02]  , { || STR0172 } ,oPanel,,,,,,.T.,,,  ,  ) //"Data/Hora do ECF"
	    oGet1 := TGet():New( aPosObj[02, 01],aPosObj[02, 02],{ |U| IIf(PCOUNT() > 0, cDtHrECF := U, cDtHrECF) },oPanel, aObjects[02,01],aObjects[02,02],"",{|| .t.  },,,, .T.,, .T.,, .T.,            , .F., .F.,, .T., .F. ,,"cDtHrECF",,,,.T.,) 

 	   	tSay():New( aPosObj[03, 01],  aPosObj[03,02]  , { || STR0173 } ,oPanel,,,,,,.T.,,,  ,  ) //"Data/Hora da Estação"
	    oGet2 := TGet():New( aPosObj[04, 01],aPosObj[04, 02],{ |U| IIf(PCOUNT() > 0, cDtHrPrt := U, cDtHrPrt) },oPanel, aObjects[04,01],aObjects[04,02],"",{|| .t.  },,,, .T.,, .T.,, .T.,            , .F., .F.,, .T., .F. ,,"cDtHrPrt",,,,.T.,) 

	   	tSay():New( aPosObj[05, 01],  aPosObj[05,02]  , { || STR0174 } ,oPanel,,,,,,.T.,,,  ,  ) //"Diferença (em minutos)"
	    oGet3 := TGet():New( aPosObj[06, 01],aPosObj[06, 02],{ |U| IIf(PCOUNT() > 0, nDiff := U, nDiff)  },oPanel, aObjects[06,01],aObjects[06,02],"@ 99",{|| .t.  },,,, .T.,, .T.,, .T.,            , .F., .F.,, .T., .F. ,,"nDiff",,,,.T.,) 
	
		
	 	@aPosObj[08,01], 5 to aPosObj[13, 1] ,nCol OF oPanel PIXEL 	 
		tSay():New( aPosObj[09, 1],  aPosObj[09, 02]+15  , { || STR0176 } ,oPanel,,,,,,.T.,,,  ,  ) //"Programar Horario de Verão"
  		nCol2 := aPosObj[10, 2] +15  
  		nTam := 60 
        

        oAdic := TRadMenu():New(aPosObj[10, 1], nCol2, {STR0177, STR0178, STR0179}, {|u|Iif (PCount()==0,nAdic,nAdic:=u)}, oPanel, ,; //"Adianta"###"Atrasa"###"Não Programar"
							   /*	{ || oBtn1:Refresh() }*/, , , , , ,;
								nTam, 10,{ || oBtn1:Refresh(), .T. }, , , .T.)
	   //	@ aPosObj[10, 1], nCol2 RADIO oAdic VAR nAdic SIZE nTam, 10 PROMPT "Adianta", "Atrasa", "Não Programar" OF oPanel ON CHANGE oBtn1:Refresh()
	    nCol2 += nTam + ( nSepComp * 2) 
	   	oBtn1 := TButton():New(aPosObj[10, 1],nCol2, STR0112,oPanel,{||  STFWzPrHg(@dDataECF,  @cHoraECF, @dDataPrt,  @cHoraPrt, ; //"Programar"
					 																 @cDtHrECF , @cDtHrPrt , @nAdic, 	oGet1, ;
																					oGet2, oGet3, oBtn1, oAdic,;
																					@cLog,	nEspacos)  },aObjects[10,01],aObjects[10,02],,,.F.,.T.,.F.,,.F.,{ || nAdic <= 2 },,.F. )
	   	nCol2 += aObjects[10,01] + (nSepComp *2)
	    TButton():New(aPosObj[10, 1],nCol2, STR0180,oPanel,{|| STFWzLdHC( @dDataECF,  @cHoraECF, @dDataPrt,  @cHoraPrt, ; //"Recapturar Dados"
					 																 @cDtHrECF , @cDtHrPrt , @nAdic, 	oGet1, ;
																					 oGet2, 	oGet3, 		oBtn1, 		oAdic, ;
																				     @cLog, nEspacos) },aObjects[10,01],aObjects[10,02],,,.F.,.T.,.F.,,.F.,{ || .t.  },,.F. )
	    
	    
	    
	    TButton():New(aPosObj[14, 1],aPosObj[14, 2], STR0181,oPanel,{|| STFWzPrtTst(@cLog, nEspacos)  },aObjects[14,01],aObjects[14,02],,,.F.,.T.,.F.,,.F.,{ || .t.  },,.F. ) //"Imprimir Página de Teste"
	 	
	
	EndIf
    

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdHIF
Captura a data/hora do ECF
@param dData		Data do ECF
@param cHora		Hora do ECF
@param cDataHora	Data/Hora do ECF
@param cLog			Log de execucao da rotina
@param nEspacos 	Espacos do log
@author  Varejo
@version P11.8
@since   26/04/2013
@return lRet		Programacao realizada com sucesso
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzLdHIF(dData, cHora, cDataHora, cLog, ;
					nEspacos)
Local aDados 	:= {}  	//Dados do ECF
Local aRet 		:= .T. 	//Retorno do Strategy  
Local lRet 		:= .T.  //Retorno da funcao  

DEFAULT dData 		:= CtoD("")	//Data do ECF
DEFAULT cHora 		:= ""		//Hora do ECF
DEFAULT cDataHora 	:= ""		//Data/Hora do ECF
DEFAULT cLog 		:= ""		//log da rotina
DEFAULT nEspacos	:= 5		//espacos 

cDataHora := ""
			
	//Executa a Captura da Data/Hora  do ECF
      		
    aDados := {"2", space(20)}
	aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STPrinterStatus"																,;		// Nome do evento
 													  aDados )
	
	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
    	dData := CtoD( AllTrim(aDados[2]))
    	
     	aDados := {"1", space(20)}
		aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 													  "STPrinterStatus"																,;		// Nome do evento
 													  aDados )   	
    	If Len(aRet) > 0 .AND. aRet[1] == 0 .AND. Len(aDados) > 1 .AND. !Empty(aDados[2])
    		cHora := AllTrim(aDados[2]) 
		 	cLog += CRLF + space(nEspacos) + STR0182  //" - Capturando Data/Hora do ECF"
    	Else
    		lRet := .F. 
    		cLog += CRLF + space(nEspacos) + STR0183  //"[ERRO] - Capturando Hora do ECF"
    	EndIf
	Else
 		lRet := .F.
 		cLog += CRLF + space(nEspacos) + STR0184 //"[ERRO] - Capturando Data do ECF"
	EndIf 	
		      	
	If !lRet
			STFMessage("DATAHORA","STOP",STR0185) //STR //"Falha ao capturar Data/Hora da Impressora"
					
			STFShowMessage("DATAHORA")  
			lRet := .F.
	Else
		cDataHora := DtoC(dData) + " " + cHora
	EndIf 
	
Return lRet     

Function STFWzLdHP(	dData, cHora, cDataHora )
	dData := GetRmtDate() 
	cHora := GetRmtTime()   
	
	cDataHora := DtoC(dData) + " " + cHora
Return .T. 


//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdHD
Calcula a diferenca entra data do protheus e a data do remote
@param dDataECF		Data do ECF
@param cHoraECF		Hora do ECF
@param dDataPtr		Data do Protheus
@param cHoraPtr		Hora do Protheus
@param nAdic		Adiciona/Atrasa o horario
@author  Varejo
@version P11.8
@since   26/04/2013
@return nDiff		Diferenca de horario
@obs
@sample
/*/
//------------------------------------------------------------
Function  STFWzLdHD(dDataECF,  cHoraECF, dDataPrt,  cHoraPtr, nAdic)
Local nX 		:= 0 	//Variavel temporaria
Local nHoraPtr 	:= 0 	//Hora do Protheus
Local nHoraECF 	:= 0 	//Hora do ECF
Local nDiff 	:= 0	//Diferenca
	
	nX :=  ( dDataECF - dDataPrt ) * 24 * 60
	nHoraPtr  := (Val (SubStr (cHoraPtr, 1, 2))*60) + Val (SubStr (cHoraPtr, 4, 2))
	nHoraECF := (Val (SubStr (cHoraECF, 1, 2))*60) + Val (SubStr (cHoraECF, 4, 2))
	
	nDiff := (nX + nHoraECF - nHoraPtr)  
	
	nAdic := IIF( nDiff <= -60, 1, IIF(nDiff >= 60, 2,  3) )

Return nDiff   

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdHC
Captura da Data/Hora do ECF e do sistema
@param dDataECF		Data do ECF
@param cHoraECF		Hora do ECF
@param dDataPtr		Data do Protheus
@param cHoraPtr		Hora do Protheus
@param cDtHrECF		Data/Hora do ECF
@param cDtHrPtr		Data/Hora do Protheus
@param nAdic		Adiciona/Atrasa o horario  
@param oGet1		Objeto Get1
@param oGet2		Objeto Get2
@param oGet3		Objeto Get3
@param oBtn1		Botao 1
@param oAdic		Adiciona o Horario
@param cLog			Log de execucao da rotina
@param nEspacos		Espacos do Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return lRet		Retorno da funcao
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzLdHC( dDataECF,  cHoraECF, 	dDataPrt,  cHoraPrt, ;
					cDtHrECF , cDtHrPrt, 	nAdic, 	oGet1, ;
					oGet2, 		oGet3, 		oBtn1, oAdic,;
					cLog,		nEspacos) 
						   
Local lRet 		:= .T. 	//Retorno da rotina
Local cLogT 	:= ""	//log temporio da rotina
Local nEspacoT 	:= 0	//espaco temporario
    
DEFAULT dDataECF 	:= CtoD("")	//Data do ECF
DEFAULT cHoraECF 	:= ""		//Hora do ECF
DEFAULT dDataPrt 	:= CtoD("")	//Data do Protheus
DEFAULT cHoraPrt 	:= ""		//Hora do Protheus
DEFAULT cDtHrECF 	:= ""		//Data/Hora do ECF
DEFAULT nAdic 		:= 1		//Adiciona
DEFAULT oGet1 		:= NIL		//Objeto Get1
DEFAULT oGet2 		:= NIL		//Objeto Get2
DEFAULT oGet3 		:= NIL		//Objeto Get3 
DEFAULT oBtn1 		:= NIL 		//Botao1
DEFAULT oAdic 		:= NIL		//Adiciona
DEFAULT cLog 		:= ""		//Log de execucao da rotina
DEFAULT nEspacos 	:= 5		//Espacos de execucao da rotina
    
    dDataECF := dDataPrt := CTod("")
    cHoraECF := cHoraPrt := cDtHrECF := cDtHrPrt := ""
    nAdic := 0   
    
    nEspacoT := nEspacos + 5 

	If (lRet := STFWzLdHIF(	@dDataECF,  @cHoraECF, @cDtHrECF, @cLogT, ;
							nEspacoT)  )
		
		If (lRet := STFWzLdHP(	@dDataPrt,  @cHoraPrT, @cDtHrPrt ) )
			nDiff := STFWzLdHD(dDataECF,  cHoraECF, dDataPrt,  cHoraPrt, @nAdic) 
		Else
		    dDataECF := dDataPrt := CTod("")
		    cHoraECF := cHoraPrt := cDtHrECF := cDtHrPrt := ""
		    nAdic := 0

		EndIf    
		 
	Else
		dDataECF := CtoD("")
		cHoraECF := cDtHrECF := ""
	EndIf   
	
		
	If oGet1 <> NIL 
		oGet1:Refresh()
		oGet2:Refresh() 
		oGet3:Refresh()
		oBtn1:Refresh()  
		oAdic:Refresh()
	EndIf
	
	cLog += CRLF + space(nEspacos) + IF(lRet, "", STR0072) +STR0186 + cLogT //"[ERRO]"###" - Capturando Data/Hora do ECF e Sistema"
	
Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzLdHC
Programacao de Horario de Verão
@param dDataECF		Data do ECF
@param cHoraECF		Hora do ECF
@param dDataPtr		Data do Protheus
@param cHoraPtr		Hora do Protheus
@param cDtHrECF		Data/Hora do ECF
@param cDtHrPtr		Data/Hora do Protheus
@param nAdic		Adiciona/Atrasa o horario  
@param oGet1		Objeto Get1
@param oGet2		Objeto Get2
@param oGet3		Objeto Get3
@param oBtn1		Botao 1
@param oAdic		Adiciona o Horario
@param cLog			Log de execucao da rotina
@param nEspacos		Espacos do Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return lRet		Retorno da funcao
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzPrHg( dDataECF,  cHoraECF, dDataPrt,  cHoraPrt, ;
					cDtHrECF , cDtHrPrt , nAdic, 	oGet1, ;
					oGet2, 		oGet3, 		oBtn1, 	oAdic,;
					cLog,		nEspacos)  
					 
Local lRet 		:= .T.  //Retorno da funcao 
Local aRet 		:= {}	//Retorno do strategy
Local aDados 	:= {}	//Dados de retorno do ECF 
Local cLogT 	:= ""	//Log temporario
Local nEspacoT 	:= 5 	//Espacos temporarios

DEFAULT dDataECF := CtoD("")	//Data do ECF
DEFAULT cHoraECF := "" 			//Hora do ECF
DEFAULT dDataPrt := Ctod("")	//Data do Protheus
DEFAULT cHoraPrt := ""			//Hora do Protheus
DEFAULT cDtHrECF := ""			//Data/Hora do ECF
DEFAULT cDtHrPrt := ""			//Data/Hora do Protheus
DEFAULT nAdic 	 := 1			//Adiciona/Retrocede   	
DEFAULT oGet1	 := NIL			//Objeto Get1
DEFAULT oGet2 	 := NIL			//Objeto Get2
DEFAULT oGet3 	 := NIL			//Objeto Get3
DEFAULT oBtn1	 := NIL			//Botao1
DEFAULT oAdic	 := NIL			//Objeto Adiciona
DEFAULT cLog 	 := ""			//Log
DEFAULT nEspacos := 5			//Espacos

	nEspacoT := nEspacos + 5
	                        
	If nAdic <> 3  
		
		aDados := { IIF( nAdic == 1,'+','-')}

			aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 								"STHourSummerAdjust"																,;		// Nome do evento
 								aDados )   
 									
    	If Len(aRet) = 0 .OR. aRet[1] <> 0 
			STFMessage("HRVERAO","STOP",STR0187) //STR //"Falha ao programar horário de verão"
					
			STFShowMessage("HRVERAO")  			
			lRet := .F.
		Else	
		   	lRet := STFWzLdHC( @dDataECF,  @cHoraECF, @dDataPrt,  @cHoraPrt, ;
					   @cDtHrECF , @cDtHrPrt ,@nAdic, oGet1,;
					   oGet2, oGet3, oBtn1, ,;
					   @cLogT, nEspacoT)
		EndIf  
	EndIf
	       
	cLog := CRLF + space(nEspacos) + IIF(lRet, "", STR0072) + STR0188 + cLogT //"[ERRO]"###" - Programando Horário de Verão"
Return lRet    

//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzPrtTst
Impressão de pagina de teste
@param cLog			Log de execucao da rotina
@param nEspacos		Espacos do Log
@author  Varejo
@version P11.8
@since   26/04/2013
@return lRet		Retorno da funcao
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzPrtTst(cLog, nEspacos)
Local lRet 		:= .T.  //Retorno da rotina
Local aRet 		:= {}	//Retorno do Strategy
Local aDados 	:= {StrTran(OemToAnsi(NoAcento(cLog)), space(5), space(1)), 1}  //parametros da rotina
  

DEFAULT cLog := ""    //Log
DEFAULT nEspacos := 5 //Espacos

	aRet :=	STFFireEvent(	ProcName(0) ,;		// Nome do processo
 								"STManagReportPrint"																,;		// Nome do evento
 								aDados )   
 									
 	If Len(aRet) = 0 .OR. aRet[1] <> 0 
		STFMessage("MANAGRPT","STOP",STR0189) //STR //"Falha ao imprimir Relatório Gerencial"
				
		STFShowMessage("MANAGRPT")  			
		lRet := .F.
	EndIf  

	
    cLog += CRLF + space(nEspacos) + IIF(lRet, "", STR0072) + STR0190 //"[ERRO]"###" - Imprimindo página de teste"
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STFLdDTEF
Resultados de comunicacao TEF
@param oDlg			Janela
@param nPanel		Painel atual
@param cLog			Log de execucao da rotina
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------
Function STFLdDTEF(oDlg, nPanel, cLog)

Local aObjects := {} 	//Array de objetos
Local aPosObj := {} 	//Posicao de objetos
Local nRow := 0  		//Linhas do Panel
Local nCol := 0    		//Colunas do panel     
Local oPanel := NIL 	//panel 
Local nRow1 := 0        //Linha

    
DEFAULT oDlg 	:= NIL //Janela
DEFAULT nPanel 	:= 1 	//Panel
DEFAULT cLog 	:= ""	//Log

	oPanel := oDlg:GetPanel(nPanel)   

	nRow		:= Int( oPanel:nHeight/2)  //Linha do Painel
	nCol := Int( oPanel:nWidth/ 2)
	
	oPanel := TScrollBox():New( oPanel, 0,0,nRow,nCol)  
	nCol := Int( nCol *.97 )     
	nRow1 := Int( nRow *.93)
	
	aObjects := { {CalcFieldSize("C",110,0),nRow1, .F., .F.} }
	aPosObj2 := MsObjSize( { 0 , 15 , nRow1 ,nCol, 2, 3,3,3}, aObjects, .T., .F.)

    cLog := UPPER(STR0191)  + cLog //"Resultado da transação de Teste de Comunicação TEF "
	TMultiGet():New(aPosObj2[1, 1],aPosObj2[1, 2],{|| Iif(PCOUNT() > 0, cLog := U,cLog)} ,oPanel,;
								aObjects[1, 01],aObjects[1, 02],/*oFont*/,.T.,;
								/*nClrFore*/,/*nClrBack*/,/*oCursor*/,.T.,;
								/*cMg*/,.T.,,/*lCenter*/,;
								/*lRight*/,.T.,,/*bChange*/,;
								,.F., .T.) 
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} STFWzShowLg
Exibe a legenda
@param aLegenda		Array de Legenda
@param cTitle		Titulo
@author  Varejo
@version P11.8
@since   26/04/2013
@obs
@sample
/*/
//------------------------------------------------------------
Function STFWzShowLg(aLegenda, cTitle)
	Local oDlgSelImp 	:= NIL   //Janela
	Local aCoord   		:= MsAdvSize(.T.) //Coordenadas da janela
	Local oBMP			:=  NIL //Objeto BMP 
	Local nI			:= 0    //Variavel contatadora
	Local cRow			:= ""   //Linha
	Local cVar			:= ""   //Variavel
	Local cRes			:= ""   //Resource
	
	DEFAULT aLegenda := {} //Legenda
	DEFAULT cTitle   := STR0144		 //"Legenda"

		oDlgSelImp := TDialog():New(000,000,aCoord[6]/6,aCoord[5]/5,OemToAnsi(cTitle),,,,,,,,oMainWnd,.T.) //
			
		For nI := 1 to len(aLegenda)
		
			cRow			:= Str(010*nI)
			cVar			:= "{ || '" + aLegenda[nI, 02] + "' } "
			cRes			:= "'" + aLegenda[nI, 01] + "'"  
						
			TBitmap():Create ( oDlgSelImp, &cRow, 003,10, 10, &cRes, , .t., , ,.F., .F., , , , , .T., , , ,  )   
			
			TSay():New( &cRow,20,&cVar,oDlgSelImp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,50,030)
		Next
				
		oDlgSelImp:Activate(,,,.T.)
	
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} STFRetrNfe
Exibe a tela do Wizard no TOTVS PDV para retransmissão da nota. 
@author  Jeferson Mondeki
@version P11.8
@since   23/04/2025
@return Nil , Nulo
@obs
@sample
/*/
//------------------------------------------------------------
Function STFRetrNfe()

//Instancia a classe FWWizard
oStepWiz:= FWWizardControl():New() // Define o tamanho do wizard  ex: {600,800}
oStepWiz:ActiveUISteps()


// Retransmissão da NF-e 
oNewPag := oStepWiz:AddStep("1") 								// Primeira tela do wizard
oNewPag:SetStepDescription("Retransmissão NF-e PDV On-line") 	//Descrição 
oNewPag:SetConstruction({|Panel|STFRtNfe_1(Panel)}) 			//Bloco de construção
oNewPag:SetNextAction({|| SFTValRtrans(cL1_DOC,cL1_SERIE)})		//Bloco ao clicar no botão Próximo
oNewPag:SetCancelAction({||SFTTrasMit()})						//Valida acao do cancelar 

oNewPag := oStepWiz:AddStep("2", {|Panel|STFFinWiz(Panel)})
oNewPag:SetStepDescription("Retransmição")//Retransmição
oNewPag:SetNextAction({|| lFimWizard := SFTTrasMit(), lFimWizard })
oNewPag:SetCancelWhen({||.F.})

//Ativa Wizard
oStepWiz:Activate()

//Desativa Wizard
oStepWiz:Destroy()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STFRtNfe_1
Exibe os campos para obter a nota que será retransmitida pelo TOTVS PDV. 
@param oPanel	Objeto	Objeto do Wizard
@author  Jeferson Mondeki 
@version 12
@since   23/04/2025
@return Nil , Nulo
@obs
@sample
/*/
//------------------------------------------------------------

Static Function STFRtNfe_1(oPanel)

Local oSayPdv		:= Nil	//Numero da estacao PDV
Local oTGetPDV		:= Nil	//Numero da estacao PDV
Local oSaySerie		:= Nil	//Serie da estacao
Local oTGetSerie	:= Nil	//Serie da Nota
Local cGetSerie 	:= ""   //Serie da nota na SL1

Default oPanel := Nil

//Documento da Nota
cL1_DOC  := Iif(ExistFunc("STDLastPdvOn"),STDLastPdvOn("L1_DOC",@cGetSerie),SL1->L1_DOC) //Busca a ultima numeração da nota 
oSayPdv  := TSay():New(05,10,{|| "Número do Documento" },oPanel,,,,,,.T.,,,100,25) //"Numero do Documento"
oTGetPDV := TGet():New(15,10,{|u| if( PCount() > 0, cL1_DOC := u, cL1_DOC ) } ,oPanel,130,025, "@E " + Replicate("9",TamSx3("L1_DOC")[1] ) ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cL1_DOC,,,, )

//Serie da Nota
cL1_SERIE  := Iif(!Empty(cGetSerie),cGetSerie, SL1->L1_SERIE)
oSaySerie  := TSay():New(05,150,{||"Série do Documento"},oPanel,,,,,,.T.,,,300,25) //"Série do Documento"
oTGetSerie := TGet():New( 15,150,{|u| if( PCount() > 0, cL1_SERIE := u, cL1_SERIE ) },oPanel,80,025,"@E " + Replicate("9",TamSx3("L1_SERIE")[1] ),,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cL1_SERIE,,,, )

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} SFTValRtrans
Valida se existe a nota e se é NF-e. 
@param cDoc 	Caractere	Numero da nota fiscal 
@param cSerie	Caractere  	Serie da nota fiscal
@author  Jeferson Mondeki 
@version 12
@since   23/04/2025
@return lRet , Logico,  Retorna se a nota existe ou não. 
@obs
@sample
/*/
//-------------------------------------------------------------------
Static function SFTValRtrans(cDoc, cSerie)

Local lRet   	:= .F.				//Indica se o processo pode ser concluído.
Local aAreaSL1  := SL1->(Getarea()) //Area da SL1 selecionada. 

DbSetOrder(2) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
If DbSeek(xFilial("SL1") + cSerie + cDoc) .And. SL1->L1_IMPNF == .T. 
	lRet := .T.
	LjGrvLog("SFTValCanc", "O Documento " + cDoc + " Serie " + cSerie + " Está disponivel para retransmissão. ", lRet)
Else
	LjGrvLog("SFTValCanc", "O Documento " + cDoc + " Serie " + cSerie + " Não foi localizado ou campo L1_IMPNF está como .F. por não se tratar de uma NF-e", lRet)
EndIf 

If lRet
	LjAutoNfe(cDoc,cSerie, SL1->L1_CLIENTE, SL1->L1_LOJA) // realiza retransmissão. 
EndIf

If lRet
	SFTMoniTNfe(cDoc,cSerie, @lRet)
EndIf	

If lRet	
	MsgInfo("Retransmissão realizada com sucesso !!!")
Else 
	MsgAlert("Está venda não está disponivel para Retransmissão !!!")
	LjGrvLog("SFTValCanc", "O Documento " + cDoc + " Serie " + cSerie + " Não foi possível retransmitir a NF-e", lRet)	
EndIf

RestArea(aAreaSL1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SFTTrasMit
Conclui o processo e limpa as mensagens da tela. 
@author  Jeferson Mondeki 
@version 12
@since   23/04/2025
@return lRet , Logico,  Retorna se a nota existe ou não. 
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function SFTTrasMit()
	STFCleanInterfaceMessage()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SFTMoniTNfe
Monitoria a nota para verificar se ela foi transmitida. 
@param cDoc		caracter, Numero do documento da nota.
@param cSerie	caracter, Numero da serie da nota.
@param lRet		Logico  , Retorna se a nota está autorizada. 
@author  Jeferson Mondeki 
@version 12
@since   16/05/2025
@return Nill , Nulo,   
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function SFTMoniTNfe(cDoc, cSerie, lRet)

Local cEntidade 	:= LjTSSIDEnt("55") //Entidade do TSS. 
Local aNotas		:= {}				//Nota que enviaremos para função ProcMonitorDoc() 
Local aInfMonNFe	:= {} 				//Recebe o retorno da função ProcMonitorDoc()
Local cCodRetNFE	:= ""				//Codigo de retorno da SEFAZ. 	


Aadd(aNotas, cSerie)
Aadd(aNotas, cDoc)
Aadd(aNotas, cDoc)

lRet := .F. // Somente se a nota for autorizada retorna o lRet para .T.  

aInfMonNFe := ProcMonitorDoc(cEntidade , AllTrim( SuperGetMv("MV_SPEDURL",,"") ) ,aNotas , 1 /*nTpMonitor*/, "55" /*cModelo*/, .F. /*lCte*/)
		
If len(aInfMonNFe)
	cCodRetNFE	:= aInfMonNFe[1][05]
	If cCodRetNFE == "100" 
		lRet := .T. 
	EndIf	
EndIf

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} STFFinWiz
Say de finalização do Wizard. 
@param oPanel	Objeto  	Painel do Wizard.
@author  Jeferson Mondeki 
@version 12
@since   19/05/2025
@return Nil , Nulo, 
@obs
@sample
/*/
//-------------------------------------------------------------------
Static Function STFFinWiz(oPanel)

Local oSayInfo 	:= Nil	//Conclusão do processo. 

oSayInfo := TSay():New(05,10,{|| "Procedimento de retransmissão concluído !" },oPanel,,,,,,.T.,,,100,25) //"Procedimento de retransmissão concluído !"

Return Nil
