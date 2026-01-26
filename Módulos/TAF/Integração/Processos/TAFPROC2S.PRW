#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFPROC2S.CH"

#DEFINE cST1TAB		    "TAFST1"	// Nome DEFINIDO da tabela compartilhada no dominio do ERP
#DEFINE cST2TAB		    "TAFST2"	// Nome DEFINIDO da tabela compartilhada no dominio do TAF
#DEFINE cTAFXERP		"TAFXERP"	// Nome DEFINIDO da tabela de controle de integrações ( TICKET )

#DEFINE	cStsReady		"1"			// Registros em prontos para ser processados
#DEFINE	cStsProc		"2"			// Registros em Processamento (ja identificados/separados pela Slice)
#DEFINE	cStsFinal		"3"			// Registros em Ja processados / Finalizados

#DEFINE	cTAFCodTxt      "1"			// Codigo para mensagens de texto
#DEFINE	cTAFCodESoc     "2"			// Codigo para mensagens XML eSocial
#DEFINE	cTAFCodNFe	    "3"			// Codigo para mensagens XML NFe

//---------------------------------------------------------------------------
/*/{Protheus.doc} TAFProc2S 
Rotina de processamento ERP x TAF (Job2) exclusiva para execução via 
Schedule (scheddef)

@return Nil 

@author Evandro dos Santos Oliveira
@since 07/11/2018  
@version 1.0
/*/
//-----------------------------------------------------------------------------   
Function TAFProc2S(cEventos)

    Local lVerEstruct	:= .T.
    Local cSemaphore	:= ""
    Local cST1Alias     := ""
    Local cST2Alias     := ""
    Local cXERPAlias    := ""
    Local cTopBuild		:= ""
    Local nInteg        := 2
    Local aTABDados		:= {}  
    Local aTabConf 		:= {} 	// Chama funcao de retorno da estrutura das tabelas compartilhadas
    Local aErros        := {}
    Local aPar          := {}
    Local cTCBuild		:= "TCGetBuild" // Nome da funcao para verificao da Build
    Local cBancoDB		:= ""			// Identifica banco DB
    Local lJob          := isBlind() 
    Local nHdlTaf		:= 0
    Local cMvTAFTDB		:= ""
    Local cMvTAFTALI	:= ""
    Local lTAFConn		:= .F.        		// Variavel de controle
    Local lVirgula		:= .F.
    Local nMvTAFPort	:= 0
    Local nCntFil       := 0
    Local aCodFil       := {}
    Local cUIdST2		:= ''
    Local lProcInExec   := .F.
    Local lOk           := .T.
    Local cUserLock     := ""
    Local cCodFils      := ""
    Local cMsgErro      := ""
    Local cIdThread     := ""
    Local cTicketXML    := "" //TAFA500
    Local lEnd          := ""
    Local nTopSlct      := 0
    Local nX            := 0
    Local aTopInfo		:= FWGetTopInfo()
    Local aLayout       := {}
    Local cEscopo       := "3"
    
    DEFAULT cEventos    := ""
    //-----------------------------------------------------------------------
    // Prepara informacoes das tabelas compartilhadas      
    //-----------------------------------------------------------------------
    TafConOut("Verificando ambiente para execucao do processo TAFPROC2. Empresa: " + cEmpAnt + " Filial: " + cFilAnt )
    
    cST1Alias	:= GetNextAlias()
    cST2Alias	:= GetNextAlias()
    cXERPAlias	:= GetNextAlias()
    aTABDados	:= {{cST1TAB,cST1Alias},{cST2TAB,cST2Alias},{cTAFXERP,cXERPAlias}}

	// Verificação da Build  para tratamento de campo CLOB
	If FindFunction(cTCBuild) 
		cTopBuild := &cTCBuild.()
	EndIf

	// -----------------------------------------------------
	// Verifica Banco
    // -----------------------------------------------------
	cBancoDB := Upper(AllTrim(TcGetDB()))

    cMvTAFTDB	:= GetNewPar( "MV_TAFTDB", "" ) //Parâmetro MV_TAFTDB - TAF TOP DATABASE DO ERP
    cMvTAFTALI	:= GetMV( "MV_TAFTALI" ) //Parâmetro MV_TAFTALI - TAF TOP ALIAS DO ERP
    nMvTAFPort	:= GetNewPar( "MV_TAFPORT", 7890 ) //Parâmetro MV_TAFPORT - PORTA DO DBACCESS - DEFAULT PORTA CORRENTE
    lVerEstruct := GetNewPar("MV_TAFESTR",.T.)
	nTopSlct    := GetNewPar("MV_TAFQPRC",0) // Parametrizado quantidade de registros
    cIdThread   := StrZero( ThreadID(), 10 )
    aTabConf 	:= xTAFGetStru(cST2TAB) 


    //-------------------------------------------------------------------------
    // Tratamento para obter a porta, devido ambiente com DBAccess distribuido
    //-------------------------------------------------------------------------
    If nMvTAFPort == 0
    	nMvTAFPort := aTopInfo[03]
    EndIf

    xTAFMsgJob(STR0001) // "Conectando as bases de dados..."
    lTAFConn := TAFConn(1,nInteg,aTABDados,aTabConf,@aErros,aPar,cTopBuild,cBancoDB,lJob,@nHdlTaf,cMvTAFTALI,cMvTAFTDB,nMvTAFPort )

    If lTAFConn

        cSemaphore := AllTrim(Str(ThreadID()))
        aCodFil	   :=	TAFCodFilErp()

        //--------------------------------------------------------------------------------------------
        //Verifica Estrutura dos registros apenas se houver registros Layout TAF  a ser processado.
        //--------------------------------------------------------------------------------------------										//
        If lVerEstruct

            (cST2Alias)->(dBSetOrder(6))
            (cST2Alias)->(dBGoTop())

            C1E->(dBSetOrder(7))

            For nCntFil := 1 to Len( aCodFil )
                If      (( cST2Alias )->( MsSeek( Padr( aCodFil[nCntFil] , Len(( cST2Alias )->TAFFIL))+ cStsReady + cTAFCodTxt ));
                .Or.    ( cST2Alias )->( MsSeek( Padr( aCodFil[nCntFil] , Len(( cST2Alias )->TAFFIL))+ cStsProc + cTAFCodTxt  ));
                .Or.    ( cST2Alias )->( MsSeek( Padr( aCodFil[nCntFil] , Len(( cST2Alias )->TAFFIL))+ cStsReady + cTAFCodTxt )) );
                 .And. ( (!Empty(cEventos) .And. Alltrim(( cST2Alias )->TAFTPREG) $ cEventos .And. IsInCallStack("TAFDEMAND") ) .Or. Empty(cEventos) ) 
                    aLayout       := TAFLoadLay()
                    TAFVerEstru( @lEnd, cST2Alias, aLayout, lJob, cXERPAlias, , , , , cEscopo  )
                Else
                    TafConOut(STR0002) //"Não há registros para verificação de estrutura..."
                EndIf
            Next nCntFil

            //Volta posicionamento Tabela
            (cST2Alias)->(dBSetOrder(1))
            (cST2Alias)->(dBGoTop())
        EndIf

        cUIdST2 := 'UIdST2' // fazer função para retornar UUID do TAFAINTEG
        //Cria Identificador de sessão para variavel de controle da TAFST2.
        If VarSetUID(cUIdST2,.T.)

            If FindFunction("TafLockInteg")

                For nX := 1 to Len(aCodFil)
                    If nX > 1
                        cCodFils +=	","
                    EndIf 
                    cCodFils +=	"'" + AllTrim(aCodFil[nX]) + "'"
                Next nX

                If !TafLockInteg(cUIdST2,.T.,@cUserLock,cCodFils,,@cMsgErro)
                    TafConOut(cMsgErro)
                    lProcInExec := .T.
                EndIf


                If !lProcInExec //Verifica se não existe outro processo da rotina na mesma filial.

                    //---------------------------------------------------------------------
                    //Fatio os registros que serão processados
                    //---------------------------------------------------------------------
                    xTafSlice(cST2TAB,AllTrim(StrZero(nTopSlct,10)),cIDThread,cBancoDB,,,,,aCodFil,cTicketXML, cEscopo, cEventos)
  
                    //---------------------------------------------------------------------
                    //Processo integração
                    //---------------------------------------------------------------------
                    TAFProc2( @lEnd, lJob, cST2Alias, cST1Alias, nTopSlct, aTabConf[01], cIDThread, @aErros, cXERPAlias, @lOk, cTicketXML ,,cEventos,,,cEscopo)

                    If FindFunction("TafLockInteg") 
                        TafLockInteg(cUIdST2,.F.)
                    EndIf
                Endif
                    
            Else

                cMsgErro := STR0003 //"Rotina TAFXINTEG.PRW desatualizada. Atualize seu ambiente para a execução desta rotina."
                TafConOut(cMsgErro)
            EndIf
        Else

            cMsgErro := STR0004 //"Erro ao tentar criar o semaforo para integração. Reinicie o serviço do TAF, se o erro persistir entre em contato com o suporte Totvs."
            TafConOut(cMsgErro)
        EndIF 

    Else
        If nHdlTaf > 0
            TCUnlink( nHdlTaf )
            nHdlTaf := 0
        EndIf
        TafConOut(STR0005) //"Não foi possivel realizar conexão com as tabelas Auxiliares do TAF."
    EndIf

    AEval( aTABDados, { | x | IIF( Select( x[2] ) > 0, ( x[2] )->( DbCloseArea( ) ), nil ) } )

Return Nil 


//-------------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Informacoes de definicao dos parametros do schedule
@Return  Array com as informacoes de definicao dos parametros do schedule
		 Array[x,1] -> Caracter, Tipo: "P" - para Processo, "R" - para Relatorios
		 Array[x,2] -> Caracter, Nome do Pergunte
		 Array[x,3] -> Caracter, Alias(para Relatorio)
		 Array[x,4] -> Array, Ordem(para Relatorio)
		 Array[x,5] -> Caracter, Titulo(para Relatorio)

@author Evandro dos Santos Oliveira	
@since  25/10/2018
@version 1.0

/*///----------------------------------------------------------------
Static Function SchedDef()

Local aParam := {}

aParam := { "P",;			//Tipo R para relatorio P para processo
            "",;	        //Pergunte do relatorio, caso nao use passar ParamDef
            ,"SM0";			//Alias
            ,;			    //Array de ordens
            }				//Titulo

Return (aParam)
