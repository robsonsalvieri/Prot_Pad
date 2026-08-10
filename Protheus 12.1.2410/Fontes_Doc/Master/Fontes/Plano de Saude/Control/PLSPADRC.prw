#INCLUDE "PLSPADRC.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "PLSMCCR.CH"
#include "TOPCONN.CH"  

// DEFINE
#DEFINE PLS_ADMINITRADOR '2'
#DEFINE LOG_AUDITORIA_NOVO_AUTORIZADOR "auditoria_novo_autorizador.log"

// STATIC
STATIC oLinkWord := NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPADRC
Controle das classes

@author Alexander Santos

@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
CLASS PLSPADRC FROM PLSCONTR

DATA o790C			  	AS OBJECT
DATA cOperad		  	AS STRING
DATA cOwner		  		AS STRING
DATA cOwnerAud		  	AS STRING
DATA cAlias		   	AS STRING
DATA lMDDemanda 	  	AS LOGIC
DATA lEditaProcesso		AS LOGIC
DATA lIntSaudInco	  	AS LOGIC
DATA lMDParticipativa  	AS LOGIC
DATA lMDNotacoes 	  	AS LOGIC
DATA lMDEncaminhamento 	AS LOGIC
DATA lMDAnaliseGui     	AS LOGIC
DATA lMDRespAuditor	   	AS LOGIC
DATA lLastReg		  	AS LOGIC
DATA lOwnerEsp		   	AS LOGIC

METHOD New(cAlias) Constructor   

METHOD VWInitVLD( oView )
METHOD VWActBDocPro(oView,oButton)
METHOD VWOkCloseScreenVLD(oView,lExiMsg)
METHOD VWOkButtonVLD(oModel,cAlias)
METHOD VWListProc( oView, oButton )
METHOD MDCommit( oModel,cAlias )
METHOD MDPosVLD( oModel,cAlias )
METHOD MDPreVLD( oModel,cAlias )
METHOD MDActVLD(oModel)
METHOD MDCancelVLD( oGEN,cAlias )
METHOD VldRegOwner()
METHOD Destroy()

EndClass     
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor da Class

@author Alexander Santos
@since 16/02/2011
@version P11
/*/
//-------------------------------------------------------------------
METHOD New(cAlias) CLASS PLSPADRC
DEFAULT ::lLastReg := .F.

::cAlias := cAlias
::o790C  := PLSA790C():New() 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
AtuPClass(Self)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim do metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return Self                  
//-------------------------------------------------------------------
/*/ { Protheus.doc } MDPreVLD
Pre validacao do modelo de dados.

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MDPreVLD(oModel,cAlias) CLASS PLSPADRC
LOCAL lRet := .T.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)                
//-------------------------------------------------------------------
/*/ { Protheus.doc } MDPosVLD
Pos validacao do modelo de dados.

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MDPosVLD( oModel,cAlias, cModelDet,lFluig ) CLASS PLSPADRC
LOCAL aArea      	:= GetArea()
LOCAL lRet		 	:= .T.
LOCAL cChave	 	:= ""
LOCAL nOperation 	:= oModel:GetOperation()
LOCAL oModelD 	 	:= oModel:GetModel( oModel:GetModelIds()[1] )
LOCAL oGEN		 	:= NIL
LOCAL aSaveLines 	:= {}
DEFAULT lFluig   := .F. 

If lFluig
	If !Empty(cModelDet) // passa o nome do model usado na estrutura de detalhes (FLUIG)
		oModelD 	 := oModel:GetModel( cModelDet )
	ELse
		oModelD 	 := oModel:GetModel( oModel:GetModelIds()[1] )
	EndIF
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Registro nao existe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lRet
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Somente Inclusao
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If nOperation == MODEL_OPERATION_INSERT .OR. (nOperation == MODEL_OPERATION_UPDATE ) .AND. lFluig
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Chave de Ligacao
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oModelD:SetValue( cAlias+'_FILIAL', xFilial("B53") )
		oModelD:SetValue( cAlias+'_ALIMOV', B53->B53_ALIMOV )
		oModelD:SetValue( cAlias+'_RECMOV', B53->B53_RECMOV )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Registrando complementar
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oModelD:SetValue( cAlias+'_OPERAD', RETCODUSR() )         
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Analise da guia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If ::lMDAnaliseGui .And. !::o790C:lIntSau 
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Registrando complementar
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			IF (!::o790C:lRotinaGen)
				oModelD:SetValue( 'B72_SEQPRO', _Super:RetConCP(::o790C:cAIte,"SEQUEN") )
				oModelD:SetValue( 'B72_CODPAD', _Super:RetConCP(::o790C:cAIte,"CODPAD") )
				oModelD:SetValue( 'B72_CODPRO', _Super:RetConCP(::o790C:cAIte,"CODPRO") )
				oModelD:SetValue( 'B72_CODGLO', _Super:RetConCP(::o790C:cACri,"CODGLO") )
			ELSE
				oModelD:SetValue( 'B72_SEQPRO', "000" )
				oModelD:SetValue( 'B72_CODPAD', "00" )
				oModelD:SetValue( 'B72_CODGLO', "000" )
				oModelD:SetValue( 'B72_CODPRO', ::o790C:cAIte + cValtoChar((::o790C:cAIte)->(RECNO())) )		
			ENDIF	
		EndIf	                              
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Resposta auditor
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If ::lMDRespAuditor
			oModelD:SetValue( 'B73_SEQPRO', B72->B72_SEQPRO )
			oModelD:SetValue( 'B73_CODGLO', B72->B72_CODGLO )
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Demanda
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If ::lMDDemanda
			cChave := oModelD:GetValue("B68_ALIMOV")+oModelD:GetValue("B68_RECMOV")+oModelD:GetValue("B68_NUMPRC")+oModelD:GetValue("B68_TPPROC")
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Notacoes,Participativa e Encaminhamentos
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		ElseIf ::lMDNotacoes .Or. ::lMDParticipativa .Or. ::lMDEncaminhamento
			cChave := oModelD:GetValue(cAlias+"_ALIMOV")+oModelD:GetValue(cAlias+"_RECMOV")+oModelD:GetValue(cAlias+"_SEQUEN")
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Analise e interna-saude
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		ElseIf ::lMDAnaliseGui .AND. (!::o790C:lRotinaGen)
			cChave := oModelD:GetValue("B72_ALIMOV")+oModelD:GetValue("B72_RECMOV")+oModelD:GetValue("B72_SEQPRO")+oModelD:GetValue("B72_CODGLO")
		ELSEIF ::lMDAnaliseGui .AND. ::o790C:lRotinaGen
			cChave := oModelD:GetValue("B72_ALIMOV")+oModelD:GetValue("B72_RECMOV")+oModelD:GetValue("B72_SEQPRO")+oModelD:GetValue("B72_CODGLO")+oModelD:GetValue("B72_CODPAD")+AllTrim(oModelD:GetValue("B72_CODPRO"))//Armazeno no codpro alias e rec de item
		ElseIf ::lMDRespAuditor
			cChave := oModelD:GetValue("B73_ALIMOV")+oModelD:GetValue("B73_RECMOV")+oModelD:GetValue("B73_SEQPRO")+oModelD:GetValue("B73_CODGLO")+oModelD:GetValue("B73_SEQUEN")
		EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Salvo a linha corrente													 
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		aSaveLines := FWSaveRows()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifico a existencia da chave
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oGEN := PLSREGIC():New()
		oGEN:GetDadReg(cAlias,1, xFilial(cAlias) + cChave ,,,.F. )
	
		If oGEN:lFound .AND. nOperation != MODEL_OPERATION_UPDATE
			_Super:ExbMHelp( STR0001 ) //"JА existe este registro na base de dados"
			lRet := .F.
		EndIf         
		
		oGEN:Destroy()
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Restaura a opcao da linha do grid (modelo)								 
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		FWRestRows( aSaveLines )       
	EndIf	
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Rest nas linhas do browse e na area										 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )                   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)                
//-------------------------------------------------------------------
/*/ { Protheus.doc } MDCommit
Faz o commit necessario do modelo

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MDCommit( oModel,cAlias , cModelDet, lFluig, lCarol ) Class PLSPADRC
LOCAL aArea      	:= GetArea()
LOCAL oB53		 	:= NIL
LOCAL oGEN 		:= NIL
LOCAL oB72		 	:= NIL
LOCAL oGCRI		:= NIL
LOCAL oGITE		:= NIL
LOCAL oBEA			:= NIL
LOCAL oBE4			:= NIL
LOCAL oRegGui	:= NIL
LOCAL cACab		:= ""
LOCAL cAIte		:= ""
LOCAL cACri		:= ""
LOCAL cGuiaSadt	:= ""
LOCAL cParecer 	:= ""
LOCAL cGuiaInter	:= ""
LOCAL cChave 	 	:= ""
LOCAL cCodGlo 	 	:= ""
LOCAL cPerfil	 	:= ""
LOCAL cChavePesq    := ""
LOCAL aChave	 	:= {}
LOCAL aAutFor	 	:= {}
LOCAL aMatGlo		:= {}
LOCAL lAutorizado	:= .F.
LOCAL lNegado 	 	:= (M->B72_PARECE == "1")
LOCAL lAtuCri	 	:= .F.
LOCAL lAtuHis	 	:= .T.
LOCAL lLastReg	 	:= .F.
LOCAL nOperation 	:= oModel:GetOperation()
LOCAL nOpc		 	:= 0
LOCAL nI			:= 1
LOCAL oModelD 	 	:= oModel:GetModel( oModel:GetModelIds()[1] )
LOCAL lGuiAudit   	:= .T.
LOCAL aChaveBQV		:= {}
Local aTmp			:= {}
Local nSom			:= 0
Local cNumTitPagAto := ""

DEFAULT lFluig := .F.

If lFluig .Or. lCarol
	If !Empty(cModelDet) // passa o nome do model usado na estrutura de detalhes (FLUIG)
		oModelD 	 := oModel:GetModel( cModelDet )
	ELse
		oModelD 	 := oModel:GetModel( oModel:GetModelIds()[1] )
	EndIF
EndIf

If ::lMDAnaliseGui .And. !::o790C:lIntSau .And. !::o790C:lRotinaGen .And. oModelD:GetValue("B72_PARECE") $ "0/1"

    cNumTitPagAto := CheckTitPagAto(IIf(::o790C:lInternacao .And. !::o790C:lEvolucao, "BE2", ::o790C:cAIte),;
                                    ::o790C:lInternacao,;
                                    ::o790C:lEvolucao,;
                                    ::o790C:cNumGuia,;
                                    B53->(B53_CODOPE+B53_CODLDP+B53_CODPEG+B53_NUMERO+B53_ORIMOV),;
                                    oModelD:GetValue("B72_PARECE"),;
                                    oModelD:GetValue("B72_SEQPRO"),;
                                    ::o790C:lProrrog,;
                                    B53->B53_NUMGUI)
EndIf
	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se for alteracao ou inclusao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

begin Transaction

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE  .AND. lFluig   
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Atualizacao referente ao cabecalho
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	Do Case 
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Participativa
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDParticipativa
			 
			dbSelectArea("BE2")
			dbSetOrder(1)
			
			If dbSeek(xFilial("BE2")+B53->B53_NUMGUI)
				
				While BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT) ==  xFilial("BE2")+B53->B53_NUMGUI
						::lMDAnaliseGui := .T.
						::o790C:lIntSau := .F.
					
					If BE2->BE2_AUDITO == "1" 
						lGuiAudit := .F.
						EXIT
					EndIf
										
					BE2->(dbSkip())
				EndDo
			EndIf

		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Encaminhamentos
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDEncaminhamento
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Monta Chave
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			aChave := {}             
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_OPEMOV"), '=', Left(B53->B53_NUMGUI,4) 		} )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_ANOAUT"), '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_MESAUT"), '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_NUMAUT"), '=', Right(B53->B53_NUMGUI,8) 		} )
			If (::o790C:cACri)->( FieldPos(::o790C:cACri+"_PENDEN") ) > 0  
				AaDd(aChave, { ::o790C:cACri + "_PENDEN", 'IN', "('')" } )
			Endif
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se ainda tem procedimento a ser analisado
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			aChaveBQV := {}
			
			AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_CODOPE"), '=', Left(B53->B53_NUMGUI,4) 		} )
			AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_ANOINT"), '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
			AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_MESINT"), '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
			AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_NUMINT"), '=', Right(B53->B53_NUMGUI,8) 		} )
			AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_AUDITO"), '=', "1" 		} )
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se ainda tem procedimento a ser analisado
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oGEN 	 := PLSREGIC():New()
			If oGEN:GetCountReg("BQV",aChaveBQV) == 0
		
				lLastReg := oGEN:GetCountReg(::o790C:cACri,aChave ) == 0       
	 		Else
	 			
	 			lLastReg := .F.
	 			
			EndIf
 			
			oGEN:Destroy()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Atualiza o cabecalho
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oB53 := PLSSTRUC():New("B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ))  
			oB53:SetValue("B53_OPEENC",B53->B53_OPERAD )
			oB53:SetValue("B53_CODDEP",oModelD:GetValue("B71_CODDEP") )
			oB53:SetValue("B53_ENCAMI","1")
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se pode retirar o operador e coloca como analisada nao
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If !lLastReg
				oB53:SetValue("B53_OPERAD","")
				oB53:SetValue("B53_SITUAC","0" ) 
			EndIf
			oB53:CRUD() 
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Analise
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDAnaliseGui .And. !::o790C:lIntSau   
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Alias
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			cACab := Iif(::o790C:lInternacao,"BEA",::o790C:cACab)
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Posiciona no tabela com base no numero da guia
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oGEN := PLSREGIC():New() 
			IF (!::o790C:lRotinaGen)
			  oGEN:GetDadReg(cACab,1, xFilial(cACab)+B53->B53_NUMGUI )
			  oGEN:Destroy()
			ELSE
			  (cACab)->( DbGoTo(Val(B53->B53_RECMOV)) ) //r7
			ENDIF    
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se for autorizado guarda o historico de autorizacao
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If oModelD:GetValue( 'B72_PARECE' ) $ '0,1'                  
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Historico
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		        AaDd( aAutFor, {.T., oModelD:GetValue('B72_CODPAD'), oModelD:GetValue('B72_CODPRO'),;
		        				  "","","","",0,RETCODUSR(),Date(),Time(), oModelD:GetValue('B72_MOTIVO'),;
		        				  "",oModelD:GetValue('B72_SEQPRO') } )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Se a opcao todos nao foi selecionada
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If !::o790C:lRotinaGen
				
					oGITE := PLSSTRUC():New(::o790C:cAIte,MODEL_OPERATION_UPDATE,,(::o790C:cAIte)->( Recno() ) )
					
					if oModelD:GetValue( 'B72_VLRAUT' ) > 0
						oGITE:SetValue( ::o790C:cAIte+"_VLRAPR", oModelD:GetValue( 'B72_VLRAUT' ) )
					endIf
					
					if oModelD:GetValue( 'B72_QTDAUT' ) > 0                                         
						oGITE:SetValue( ::o790C:cAIte+"_QTDPRO", oModelD:GetValue( 'B72_QTDAUT' ) )
						oGITE:SetValue( ::o790C:cAIte+"_SALDO",  oModelD:GetValue( 'B72_QTDAUT' ) )
					endIf	
					
					oGITE:SetValue( ::o790C:cAIte+"_VIA", oModelD:GetValue( 'B72_VIA' ) )
					oGITE:SetValue( ::o790C:cAIte+"_PERVIA", oModelD:GetValue( 'B72_PERVIA' ) )
					oGITE:CRUD()
					
					oGITE:Destroy()
				Endif	
				
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Alimenta a tabela de critica com o operador da analise todas as glosas do perfil ou a selecionada
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			cChave := B53->B53_FILIAL + B53->B53_NUMGUI + oModelD:GetValue( 'B72_SEQPRO' )
			
			//Posiciona na glosa
			(::o790C:cACri)->(dbSetOrder(1))
			If (::o790C:cACri)->(MsSeek(cChave))
				//Indica que deve atualizar o historico de criticas por se tratar da primeira glosa
				lAtuHis := .T.
				
				If !lFluig .AND. !::o790C:lRotinaGen			
					While !(::o790C:cACri)->( Eof() ) .And. cChave == xFilial(::o790C:cACri)+(::o790C:cACri)->&( ::o790C:SetFieldGui(::o790C:cACri+"_OPEMOV+"+::o790C:cACri+"_ANOAUT+"+::o790C:cACri+"_MESAUT+"+::o790C:cACri+"_NUMAUT+"+::o790C:cACri+"_SEQUEN") )
		 				
		                cCodGlo := (::o790C:cACri)->&( ::o790C:cACri+"_CODGLO" )
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Somente glosas nao analisadas ainda
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						If Empty( (::o790C:cACri)->&( ::o790C:cACri+"_OPERAD" ) ) .Or. ::o790C:cOwner == (::o790C:cACri)->&( ::o790C:cACri+"_OPERAD" )
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//Ё Se foi autorizado exclui a glosa
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							If oModelD:GetValue( 'B72_PARECE' ) == '0'
								nOpc := MODEL_OPERATION_DELETE
							Else
								nOpc := MODEL_OPERATION_UPDATE
							EndIf	
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//Ё Somente a glosa principal
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							If !Empty(cCodGlo)
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Guarda codigo das glosas para criacao da B72
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								AaDd(aMatGlo, cCodGlo )
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Posiciona na glosa
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								If (::o790C:cACri)->( FieldPos(::o790C:cACri + "_TIPO") ) > 0 .And. !Empty( (::o790C:cACri)->&( ::o790C:cACri + "_TIPO" ) )
									cPerfil := (::o790C:cACri)->&( ::o790C:cACri + "_TIPO" )
								Else	
									oGEN := PLSREGIC():New()
									oGEN:GetDadReg( "BCT",1, xFilial("BCT") + B53->B53_CODOPE + cCodGlo )    
									cPerfil := oGEN:GetValue("BCT_TIPO")
									oGEN:Destroy()
								EndIf
						  	    lAtuCri := .F.
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Verifica se a glosa esta relacionada ao perfil do operador
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							  	If ::o790C:cPerfil == PLS_ADMINITRADOR .Or. ::o790C:cPerfil == cPerfil
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Atualiza critica
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							  	    lAtuCri := .T.
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Atualiza o operador e se a critica ainda esta pendente
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									oGCRI 	:= PLSSTRUC():New(::o790C:cACri,nOpc,,(::o790C:cACri)->( Recno() ) )
									oGCRI:SetValue( ::o790C:cACri+"_OPERAD",::o790C:cOwner )                                       
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё 0=Autorizado;1=Negado;2=Em Analise
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									oGCRI:SetValue(═::o790C:cACri+"_PENDEN",═'0'═) 
									oGCRI:CRUD()                                                                      
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Grava Historico
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									If oModelD:GetValue( 'B72_PARECE' ) $ '0,1' .And. lAtuHis
										
										If ::o790C:cACab == "BE4" 
										
											(::o790C:cACab)->(dbSetOrder(2))
											(::o790C:cACab)->(MsSeek(xfilial(::o790C:cACab) + B53->B53_NUMGUI))
										Else
											(::o790C:cACab)->(dbSetOrder(1))
											(::o790C:cACab)->(MsSeek(xFilial(::o790C:cACab) + B53->B53_NUMGUI) )
										EndIf 
										
										PLSFORHIS(MODEL_OPERATION_INSERT,Iif(AllTrim(B53->B53_TIPO)$"1,2","1",B53->B53_TIPO),cACab,aAutFor, {{ { cCodGlo,"", oModelD:GetValue('B72_CODPAD') + "-" + AllTrim(oModelD:GetValue('B72_CODPRO')) } }} )
										//Indica que NAO deve mais atualizar o historico de criticas
										lAtuHis := .F.
									EndIf	
								EndIf
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//Ё Atualiza o complemento da critica
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							ElseIf lAtuCri
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Atualiza o operador e se a critica ainda esta pendente
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								oGCRI := PLSSTRUC():New(::o790C:cACri,nOpc,,(::o790C:cACri)->( Recno() ) )
								oGCRI:SetValue( ::o790C:cACri+"_OPERAD",::o790C:cOwner )                                       
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё 0=Autorizado;1=Negado;2=Em Analise
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								oGCRI:SetValue(═::o790C:cACri+"_PENDEN",═'0'═) 
								oGCRI:CRUD()                                                                      
			                EndIf
			            EndIf        
					(::o790C:cACri)->( DbSkip() )				
					EndDo
				ElseIF !::o790C:lRotinaGen  //r7 
					While !(::o790C:cACri)->( Eof() ) .And. cChave ==BEG->(BEG_FILIAL + BEG_OPEMOV + BEG_ANOAUT + BEG_MESAUT + BEG_NUMAUT + BEG_SEQUEN) 
						
		                cCodGlo := (::o790C:cACri)->&( ::o790C:cACri+"_CODGLO" )
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Somente glosas nao analisadas ainda
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						If Empty( (::o790C:cACri)->&( ::o790C:cACri+"_OPERAD" ) ) .Or. ::o790C:cOwner == (::o790C:cACri)->&( ::o790C:cACri+"_OPERAD" )
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//Ё Se foi autorizado exclui a glosa
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							If oModelD:GetValue( 'B72_PARECE' ) == '0'
								nOpc := MODEL_OPERATION_DELETE                              
							Else
								nOpc := MODEL_OPERATION_UPDATE                              
							EndIf	
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//Ё Somente a glosa principal
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							If !Empty(cCodGlo)
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Guarda codigo das glosas para criacao da B72
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								AaDd(aMatGlo, cCodGlo )
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Posiciona na glosa
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								If (::o790C:cACri)->( FieldPos(::o790C:cACri + "_TIPO") ) > 0 .And. !Empty( (::o790C:cACri)->&( ::o790C:cACri + "_TIPO" ) )
									cPerfil := (::o790C:cACri)->&( ::o790C:cACri + "_TIPO" )
								Else	
									oGEN := PLSREGIC():New()
									oGEN:GetDadReg( "BCT",1, xFilial("BCT") + B53->B53_CODOPE + cCodGlo )    
									cPerfil := oGEN:GetValue("BCT_TIPO")
									oGEN:Destroy()
								EndIf
						  	    lAtuCri := .F.
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Verifica se a glosa esta relacionada ao perfil do operador
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							  	If ::o790C:cPerfil == PLS_ADMINITRADOR .Or. ::o790C:cPerfil == cPerfil
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Atualiza critica
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							  	    lAtuCri := .T.
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Atualiza o operador e se a critica ainda esta pendente
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									oGCRI 	:= PLSSTRUC():New(::o790C:cACri,nOpc,,(::o790C:cACri)->( Recno() ) )
									oGCRI:SetValue( ::o790C:cACri+"_OPERAD",::o790C:cOwner )                                       
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё 0=Autorizado;1=Negado;2=Em Analise
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									oGCRI:SetValue(═::o790C:cACri+"_PENDEN",═'0'═) 
									oGCRI:CRUD()                                                                      
									//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									//Ё Grava Historico
									//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
									If oModelD:GetValue( 'B72_PARECE' ) $ '0,1' .And. lAtuHis
										PLSFORHIS(MODEL_OPERATION_INSERT,Iif(AllTrim(B53->B53_TIPO)$"1,2","1",B53->B53_TIPO),cACab,aAutFor, {{ { cCodGlo,"", oModelD:GetValue('B72_CODPAD') + "-" + AllTrim(oModelD:GetValue('B72_CODPRO')) } }} )
										//Indica que NAO deve mais atualizar o historico de criticas
										lAtuHis := .F.
									EndIf	
			                    EndIf
							//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							//Ё Atualiza o complemento da critica
							//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
							ElseIf lAtuCri
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё Atualiza o operador e se a critica ainda esta pendente
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								oGCRI := PLSSTRUC():New(::o790C:cACri,nOpc,,(::o790C:cACri)->( Recno() ) )
								oGCRI:SetValue( ::o790C:cACri+"_OPERAD",::o790C:cOwner )                                       
								//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								//Ё 0=Autorizado;1=Negado;2=Em Analise
								//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
								oGCRI:SetValue(═::o790C:cACri+"_PENDEN",═'0'═) 
								oGCRI:CRUD()                                                                      
			                EndIf
			            EndIf        
					(::o790C:cACri)->( DbSkip() )				
					EndDo
				EndIf 
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Parecer informado pelo usuario
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			cParecer := oModelD:GetValue( 'B72_PARECE' )						
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se existe alguma pendencia
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			aChave := {}
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_OPEMOV"), '=', Left(B53->B53_NUMGUI,4) } )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_ANOAUT"), '=', SubStr(B53->B53_NUMGUI,5,4) } )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_MESAUT"), '=', SubStr(B53->B53_NUMGUI,9,2) } )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_NUMAUT"), '=', Right(B53->B53_NUMGUI,8) } )
			AadD(aChave, { ::o790C:cACri + "_SEQUEN", '=', oModelD:GetValue( 'B72_SEQPRO' ) } )		
			AadD(aChave, { ::o790C:cACri + "_PENDEN", '<>', '0' } )		
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se tem pendencia
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oGEN 	 	:= PLSREGIC():New()
			lNEstPen 	:= oModelD:GetValue( 'B72_PARECE' ) $ '0,1' //oGEN:GetCountReg(::o790C:cACri,aChave ) == 0
			oGEN:Destroy()
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se nao esta pendente, mas tem critica na base o procedimento foi negado
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lNEstPen .AND. !::o790C:lRotinaGen
				aChave := {}
				AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_OPEMOV"), '=', Left(B53->B53_NUMGUI,4) } )
				AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_ANOAUT"), '=', SubStr(B53->B53_NUMGUI,5,4) } )
				AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_MESAUT"), '=', SubStr(B53->B53_NUMGUI,9,2) } )
				AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cACri + "_NUMAUT"), '=', Right(B53->B53_NUMGUI,8) } )
				AaDd(aChave, { ::o790C:cACri + "_SEQUEN", '=', oModelD:GetValue( 'B72_SEQPRO' ) } )
				AaDd(aChave, { ::o790C:cACri + "_PENDEN", '=', '0'  } )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se existe critica negada
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				oGEN := PLSREGIC():New()
				If oGEN:GetCountReg(::o790C:cACri,aChave ) > 0
					cParecer := "1"
				EndIf     
				oGEN:Destroy()
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Ajuste dos alias para chamada da funcao na antiga auditoria
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				cACab 		:= ::o790C:cACab
				cAIte 		:= ::o790C:cAIte
				cACri 		:= ::o790C:cACri
				cGuiaSadt	:= ::o790C:cNumGuia
				cGuiaInter	:= ""
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Na internacao
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If ::o790C:lInternacao .And. !::o790C:lEvolucao
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Alias
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					cACab 		:= "BEA"
					cAIte 		:= "BE2"
					cACri 		:= "BEG"
					cGuiaInter := ::o790C:cNumGuia
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Posiciona no bea com base no numero da guia
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					oGEN := PLSREGIC():New()
					oGEN:GetDadReg(cACab,6, xFilial(cACab)+B53->B53_NUMGUI )
					
					If oGEN:lFound
						cGuiaSadt := oGEN:GetValue("BEA_OPEMOV")+oGEN:GetValue("BEA_ANOAUT")+oGEN:GetValue("BEA_MESAUT")+oGEN:GetValue("BEA_NUMAUT")
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Posiciona no be2 e beg com base no bea
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						oGEN:GetDadReg(cAIte,1, xFilial(cAIte)+cGuiaSadt,,,.F. )
						oGEN:GetDadReg(cACri,1, xFilial(cACri)+cGuiaSadt,,,.F. )
					Else
						FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0002 + B53->B53_NUMGUI + "]", 0, 0, {})//"Integridade, NЦo foi possМvel encontrar o BEA com base no BE4 chave ["
					EndIf   
					oGEN:Destroy()
				EndIf
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Grava e realiza ajustes relacionados ITEM,CRITICA E CONTAS
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				IF (!::o790C:lRotinaGen)
					PLS790GVA(	cACab,;
								cAIte,;
								cACri,;
								.T.,;
								.T.,;
								.F.,;              
								::o790C:lReembolso,;
								::o790C:lInternacao,;
								::o790C:lEvolucao,;
								cGuiaInter,;
								cGuiaSadt,;
								B53->(B53_CODOPE+B53_CODLDP+B53_CODPEG+B53_NUMERO+B53_ORIMOV),;
								'1',;
								cParecer,;
								oModelD:GetValue( 'B72_SEQPRO' ),;
								RETCODUSR(),;
								PLRETOPE(),;
								oModelD:GetValue( 'B72_QTDAUT' ),;
								oModelD:GetValue( 'B72_VLRAUT' ),;
								"",;
								nil,;
								iIf((cAIte)->(fieldPos(cAIte+"_VIA"))>0,oModelD:GetValue('B72_VIA'),""),;
								iIf((cAIte)->(fieldPos(cAIte+"_PERVIA"))>0,oModelD:GetValue('B72_PERVIA'),0),;
								iIf(cACab == "B4A", .T.,.F.),;
								::o790C:lProrrog,;
								.F.,;
								cNumTitPagAto)
							
							
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Monta Chave
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					aChave := {}             
					AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_OPEMOV"), '=', Left(B53->B53_NUMGUI,4) } )
					AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_ANOAUT"), '=', SubStr(B53->B53_NUMGUI,5,4) } )
					AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_MESAUT"), '=', SubStr(B53->B53_NUMGUI,9,2)} )
					AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_NUMAUT"), '=', Right(B53->B53_NUMGUI,8)} )
					AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_AUDITO"), '=', "1"} )
					
					aChaveBQV := {}
					AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_CODOPE"), '=', Left(B53->B53_NUMGUI,4) 		} )
					AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_ANOINT"), '=', SubStr(B53->B53_NUMGUI,5,4) 	} )
					AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_MESINT"), '=', SubStr(B53->B53_NUMGUI,9,2) 	} )
					AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_NUMINT"), '=', Right(B53->B53_NUMGUI,8) 		} )
					AaDd(aChaveBQV, { ::o790C:SetFieldGui("BQV_AUDITO"), '=', "1" 		} )
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Verifica se ainda tem procedimento a ser analisado
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					oGEN 	 := PLSREGIC():New()
					If oGEN:GetCountReg("BQV",aChaveBQV) == 0
						
						If cAIte == "BQV"
							lLastReg := .T.
						Else
							lLastReg := oGEN:GetCountReg(::o790C:cAIte,aChave ) == 0
						EndIf       
			 		Else
			 			
			 			lLastReg := .F.
			 			
			 			//Help("",1,FunName(),,"Esta guia ainda possui " + cValToChar( oGEN:GetCountReg("BQV",aChaveBQV)) + " procedimento(s) de evoluГЦo a ser(em) auditado(s).",1,0)
			 			//Mensagem retirada pois estava onerando o processo quando a prorrogaГЦo possuМa muitos procedimentos.
			 			
					EndIf       
					oGEN:Destroy()
				EndIf	   
		ENDIF	   
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Interna-Saude
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDAnaliseGui .And. ::o790C:lIntSau         
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Auditor que fez a analise interna-saude
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oModelD:SetValue( 'B72_COPERE', RETCODUSR() )         
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se tiver inconsistente
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If oModelD:GetValue( 'B72_INCONS' ) == '1'
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Atualiza o cabecalho
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				oB53 := PLSSTRUC():New("B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
					oB53:SetValue("B53_SITUAC","4")
				oB53:CRUD() 
			EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Resposta ao autidor saude
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDRespAuditor	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se o auditor respondeu alguma vez o questionamento do interna-saude
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oB72 := PLSREGIC():New()
			oB72:GetDadReg("B72",,,B72->( Recno() ) )    
			
			If oB72:GetValue( "B72_RESAUT" ) <> '1'
				oB72 := PLSSTRUC():New("B72",MODEL_OPERATION_UPDATE,,B72->( Recno() ) )
					oB72:SetValue("B72_RESAUT","1")
					oB72:SetValue("B72_RESAUT","1")
				oB72:CRUD()
			EndIf 
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se for diferente de nЦo concordar retira a guia da inconsistencia
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If oModelD:GetValue( 'B73_TPACAO' ) <> '3'
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Finaliza guia
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				oB72 := PLSSTRUC():New("B72",MODEL_OPERATION_UPDATE,,B72->( Recno() ) )
				oB72:SetValue("B72_INCONS","3")
				oB72:CRUD() 
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Monta Chave
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				aChave := {}             
				AadD(aChave, { "B72_ALIMOV", '=', B53->B53_ALIMOV } )		
				AadD(aChave, { "B72_RECMOV", '=', B53->B53_RECMOV } )		
				AadD(aChave, { "B72_INCONS", '=', "1" } )		
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se ainda tem procedimento a ser analisado
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				oGEN := PLSREGIC():New()
				If oGEN:GetCountReg("B72",aChave ) == 0
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Atualiza o cabecalho
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					oB53 := PLSSTRUC():New("B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
						oB53:SetValue("B53_SITUAC","1")
					oB53:CRUD() 
				EndIf	
				oGEN:Destroy()
			EndIf
		EndCase	
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Quando for exclusao 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
ElseIf nOperation == MODEL_OPERATION_DELETE
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se tem banco de conhecimento e exclui
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	MsDocument( cAlias, (cAlias)->( Recno() ), 2, , 3)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Participariva
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If ::lMDParticipativa .And. ::o790C:lAgendada	
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Atualiza o pai retirando o agendamento da guia
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oB53 := PLSSTRUC():New("B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ))  
		oB53:SetValue("B53_AGEPAR","0" )
		oB53:CRUD() 
	EndIf
EndIf	    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Commit 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
FWFormCommit( oModel )

oB72 := PLSSTRUC():New( "B72",MODEL_OPERATION_UPDATE,,B72->( Recno() ) )
		oB72:SetValue("B72_DATMOV",dDataBase)
		oB72:SetValue("B72_FILIAL",xFilial("B53"))
		BE2->(dbSetOrder(6)) //BE2_FILIAL+BE2_OPEMOV+BE2_ANOAUT+BE2_MESAUT+BE2_NUMAUT+BE2_CODPAD+BE2_CODPRO+BE2_DENREG+BE2_FADENT
		If BE2->(dbSeek(xFilial("BE2")+B53->B53_NUMGUI+B72->B72_CODPAD+B72->B72_CODPRO))
			oB72:SetValue("B72_QTDAUT",BE2->BE2_QTDPRO)
		EndIf
		
		IF (::o790C:lRotinaGen) 
			aTmp := SEPARA(B53->B53_CVLAUD, ",",.F.)
			
			//Como estА posicionado no item da tabela, jА informo que nЦo estА mais em auditoria
			(::o790C:cAite)->(RecLock(::o790C:cAite,.F.))
			(::o790C:cAite)->&(::o790C:cAite+"_"+aTmp[1]) := aTmp[4]
			(::o790C:cAite)->(MsUnlock())
			
			//Verifico se para esta tabela foi colocado alguma informaГЦo de campo de Parecer ou nЦo. Se sim, atualizo conforme
			//dados do vetor aTmp , proveniente do campo B53_CVLAUD
			IF ( Len(aTmp) > 5)  //Significa que na tabela tem algum campo que armazena o parecer tambИm e necessita de atualizaГЦo
				   DO CASE 
				   Case (oModelD:GetValue('B72_PARECE') == "0")
                   (::o790C:cAite)->(RecLock(::o790C:cAite,.F.))	
				     (::o790C:cAite)->&(::o790C:cAite+"_"+aTmp[5]) := aTmp[6]  
				     (::o790C:cAite)->(MsUnlock())
				   CASE (oModelD:GetValue('B72_PARECE') == "1")
				     (::o790C:cAite)->(RecLock(::o790C:cAite,.F.))
				     (::o790C:cAite)->&(::o790C:cAite+"_"+aTmp[5]) := aTmp[7]
				     (::o790C:cAite)->(MsUnlock())	
				   ENDCASE  
			ENDIF
			(::o790C:cAite)->(DbSetOrder(1))	
			
			//Verifico se para esta guia ainda temos mais procedimentos em auditoriae se jА foram auditados
			IF ( (::o790C:cAite)->(MsSeek(xfilial(::o790C:cAite)+Alltrim(B53->B53_NUMGUI))) )
			  cInd := PLSVerInd(1, .T.)
			  cInd := Substr(cInd,0,Len(cInd)-1)
			  WHILE ( !(::o790C:cAite)->(EOF()) .AND. (::o790C:cAite)->&(cInd) == xFilial(::o790C:cAite)+ Alltrim(B53->B53_NUMGUI)) 
			  	IF ( (::o790C:cAite)->&(::o790C:cAite+"_"+aTmp[1]) == aTmp[2] )
			      nSom += 1
			    ENDIF   
			   (::o790C:cAite)->(DbSkip()) 
			  ENDDO  
			ENDIF  
			
			IF (nSom == 0)
			  (cACab)->(RecLock(cACab,.F.))	
			  (cACab)->&(cACab+"_"+aTmp[1]) := aTmp[4]
			  (::o790C:cAite)->(MsUnlock())
			  B53->(RecLock("B53", .F.))
			  B53->B53_SITUAC := "1"
			  B53->B53_OPERAD := ""
			  B53->(MsUnlock())
			ENDIF
		  ENDIF	   

		
		oB72:CRUD()
		oB72:Destroy()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se foi selecionado a opcao todos 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
For nI:=1 To Len(aMatGlo)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Somente glosa que ainda nao foi inserida na B72
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If oModelD:GetValue('B72_CODGLO') <> aMatGlo[nI]
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se ja existe na base
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oGEN := PLSREGIC():New()
		oGEN:GetDadReg("B72",1 ,xFilial("B72") + B53->(B53_ALIMOV+B53_RECMOV) + oModelD:GetValue('B72_SEQPRO') + aMatGlo[nI] ,,,.F. )
	
		If oGEN:lFound
			oB72 := PLSSTRUC():New("B72",MODEL_OPERATION_UPDATE,,B72->( Recno() ))  
				oB72:SetValue("B72_PARECE",oModelD:GetValue('B72_PARECE') )
				oB72:SetValue("B72_OBSANA",oModelD:GetValue('B72_OBSANA') )
				oB72:SetValue("B72_MOTIVO",oModelD:GetValue('B72_MOTIVO') )
				oB72:SetValue("B72_VLRAUT",oModelD:GetValue('B72_VLRAUT') )
				oB72:SetValue("B72_QTDAUT",oModelD:GetValue('B72_QTDAUT') )
				oB72:SetValue("B72_VIA",oModelD:GetValue('B72_VIA') )
				oB72:SetValue("B72_PERVIA",oModelD:GetValue('B72_PERVIA') )
		Else
			oB72 := PLSSTRUC():New("B72",MODEL_OPERATION_INSERT,,B72->( Recno() ))  
			oB72:SetValue("B72_FILIAL",oModelD:GetValue('B72_FILIAL') )	
			oB72:SetValue("B72_JNTMED",oModelD:GetValue('B72_JNTMED') )
			oB72:SetValue("B72_QTDSOL",oModelD:GetValue('B72_QTDSOL') )
			oB72:SetValue("B72_TPPARE",oModelD:GetValue('B72_TPPARE') )	
			oB72:SetValue("B72_ALIMOV",oModelD:GetValue('B72_ALIMOV') )
			oB72:SetValue("B72_RECMOV",oModelD:GetValue('B72_RECMOV') )
			oB72:SetValue("B72_DATMOV",dDataBase )
			oB72:SetValue("B72_CODPRO",oModelD:GetValue('B72_CODPRO') )
			oB72:SetValue("B72_OPERAD",oModelD:GetValue('B72_OPERAD') )
			oB72:SetValue("B72_CODGLO",aMatGlo[nI])
			oB72:SetValue("B72_OBSISA",oModelD:GetValue('B72_OBSISA') )
			oB72:SetValue("B72_SEQPRO",oModelD:GetValue('B72_SEQPRO') )
			oB72:SetValue("B72_CODPAD",oModelD:GetValue('B72_CODPAD') )
			oB72:SetValue("B72_PARECE",oModelD:GetValue('B72_PARECE') )
			oB72:SetValue("B72_ACOTOD",oModelD:GetValue('B72_ACOTOD') )
			oB72:SetValue("B72_OBSANA",oModelD:GetValue('B72_OBSANA') )
			oB72:SetValue("B72_MOTIVO",oModelD:GetValue('B72_MOTIVO') )
			oB72:SetValue("B72_VLRAUT",oModelD:GetValue('B72_VLRAUT') )
			oB72:SetValue("B72_QTDAUT",oModelD:GetValue('B72_QTDAUT') )
			oB72:SetValue("B72_RESAUT",oModelD:GetValue('B72_RESAUT') )
			oB72:SetValue("B72_COPERE",oModelD:GetValue('B72_COPERE') )
			oB72:SetValue("B72_INCONS",oModelD:GetValue('B72_INCONS') )
			oB72:SetValue("B72_TPINCO",oModelD:GetValue('B72_TPINCO') )
			oB72:SetValue("B72_TPINCO",oModelD:GetValue('B72_TPINCO') )
			oB72:SetValue("B72_VIA",oModelD:GetValue('B72_VIA') )
			oB72:SetValue("B72_PERVIA",oModelD:GetValue('B72_PERVIA') )
		EndIf         		
		oB72:CRUD()
		oGEN:Destroy()
	EndIf		
Next

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Na inclusao ou alteracao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If nOperation == MODEL_OPERATION_INSERT .Or. nOperation = MODEL_OPERATION_UPDATE
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё ANALISE DA CRITICA - GUIA
	//Ё Se for o ultimo registro e nao tiver nenhuma critica pendente atualiza a guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If lLastReg .And. ::lMDAnaliseGui .And. !::o790C:lIntSau
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Atualiza o cabecalho
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oB53 := PLSSTRUC():New("B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica analise do auditor B72_FILIAL + B72_ALIMOV + B72_RECMOV + B72_PARECE
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oB72 := PLSREGIC():New()
		oB72:GetDadReg("B72",3, xFilial("B72") + B53->(B53_ALIMOV+B53_RECMOV)+"2",,,.F. )    
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se esta em analise 0=Autorizado; 1=Negado; 2=Em Analise
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If oB72:lFound	
			oB53:SetValue("B53_SITUAC","2",,,.F. )  //0=NЦo;1=Sim;2=Em Analise;3=Em Espera;4=InconsistЙncia
		Else   

			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//VerificaГЦo Adicional caso seja apenas lNegado. Podemos ter na guia 2 ou mais procedimentos e todos estarem autorizados e apenas 1 foi para auditoria e este foi negado.
			//Nesse caso, o sistema vai identificar que И o Зltimo registro e negado e a guia vai ficar como negada, sendo que na verdade, estА autorizada parcialmente.
			//Assim, para acompanhar o status da guia, alИm de verificar na B72 a situaГЦo, iremos verificar tambИm na tabela de itens os status dos procedimentos.
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			lAutorizado := VeriteAtB53(.T.)	
			lNegado     := VeriteAtB53(.F.)	
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se tem algum registro autorizado
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lAutorizado .And. lNegado
				oB53:SetValue("B53_STATUS","2") //1=Autorizada;2=Aut. Parcial;3=Nao Autorizada;4=FinalizaГЦo Atendimento;5=Liq. Titulo a Receber
			ElseIf lAutorizado	
				oB53:SetValue("B53_STATUS","1")
			ElseIf lNegado
				oB53:SetValue("B53_STATUS","3")
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Coloca a guia como analisada e data e hora do final geral da analise
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oB53:SetValue("B53_SITUAC","1" ) 
		 	oB53:SetValue("B53_OPERAD",'')
			oB53:SetValue("B53_DATFIM",dDataBase)
			oB53:SetValue("B53_HORFIM",Left(Time(),5))
			
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Atualiza Dados da Internacao
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If AllTrim(B53->B53_TIPO) == "3" .And. M->B72_PARECE $ "0,1" 
				BE4->(dbSetOrder(2))
				If dbSeek(xFilial("BE4")+ B53->B53_NUMGUI)
					oBE4 := PLSSTRUC():New( "BE4",MODEL_OPERATION_UPDATE,,BE4->( Recno() ) )
					If ::o790C:lEvolucao
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Atualiza dados da Guia caso for Evolucao
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Status
						If lAutorizado .And. lNegado
							oBE4:SetValue("BE4_STATUS","2") //Aut. Parcial
							oBE4:SetValue("BE4_STTISS","7") 
						
						ElseIf lAutorizado	
							oBE4:SetValue("BE4_STATUS","1") //Autorizada
							oBE4:SetValue("BE4_STTISS","1") 
						
						ElseIf lNegado
							oBE4:SetValue("BE4_STATUS","3") //Nao Autorizada
							oBE4:SetValue("BE4_STTISS","5") 
						EndIf
					Else

						//Data de validade da Internacao
						dData := dDataBase + GETMV("MV_PLPRZLB")
						oBE4:SetValue("BE4_DATVAL",dData)
					EndIf

					oBE4:CRUD()
					oBE4:Destroy()
				EndIf
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Atualiza a data de aprovaГЦo
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oBEA := PLSSTRUC():New( "BEA",MODEL_OPERATION_UPDATE,,BEA->( Recno() ) )
			If BEA->BEA_LIBERA != "1" //Pode atualizar caso for pra liberaГЦo Sadt, caso contrАrio nЦo pode atualizar.
				oBEA:SetValue("BEA_DATPRO",dDataBase)
			EndIf
			//Data de validade da liberaГЦo/ExecuГЦo SADT
			oBEA:SetValue("BEA_VALSEN",dDataBase + GETMV("MV_PLPRZLB"))
			
			//Ponto de entrada para alteraГЦo da Data de AlteraГЦo
			If ExistBlock("PLALTDTPR")			
				oBEA := ExecBlock("PLALTDTPR", .F., .F., {oBEA} ) 
			Endif
			
			oBEA:CRUD()
			oBEA:Destroy()
			
			//Atualiza o campo cAudito da guia
			oRegGui := PLSSTRUC():New(::o790C:cACab, MODEL_OPERATION_UPDATE,,(::o790C:cACab)->( Recno() ) )
			oRegGui:SetValue(::o790C:cACab + "_AUDITO","0")
			If lAutorizado .And. lNegado
				oRegGui:SetValue(::o790C:cACab + "_STALIB","1")			
			ElseIf lAutorizado	
				oRegGui:SetValue(::o790C:cACab + "_STALIB","1")
			ElseIf lNegado
				oRegGui:SetValue(::o790C:cACab + "_STALIB","2")
			EndIf
			oRegGui:CRUD()
			oRegGui:Destroy()

			if B53->B53_ORIMOV == "6"
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] PLSPADRC: INICIANDO JOB PARA COMUNICAR PARECER NO AUTORIZADOR",LOG_AUDITORIA_NOVO_AUTORIZADOR)
				PLJBAUDAUT({{B53->B53_ALIMOV, B53->B53_RECMOV}})
			endIf
			
        EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Grava e destroy as classes
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oB53:CRUD()  
		oB53:Destroy()
		oB72:Destroy()

		if !lCarol
			__oDlgAna:End()  
		endIf
		
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Interna-Saude
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	ElseIf ::lMDAnaliseGui .And. ::o790C:lIntSau .And. oModelD:GetValue( 'B72_INCONS' ) == '3'         
		aChave := {}
		AadD(aChave, { "B72_ALIMOV", '=', B53->B53_ALIMOV } )		
		AadD(aChave, { "B72_RECMOV", '=', B53->B53_RECMOV } )
		AadD(aChave, { "B72_INCONS", '=', "1" } )		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verifica se ainda tem procedimento a ser analisado
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		oGEN := PLSREGIC():New()
		If oGEN:GetCountReg("B72",aChave ) == 0
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Atualiza o cabecalho
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			oB53 := PLSSTRUC():New("B53",MODEL_OPERATION_UPDATE,,B53->( Recno() ) )
				oB53:SetValue("B53_SITUAC","1")
			oB53:CRUD() 
		EndIf     
		oGEN:Destroy()
    EndIf
EndIf    

End Transaction


iF cAlias == "B72"
	cChavePesq := oModelD:GetValue(cAlias+"_ALIMOV")+oModelD:GetValue(cAlias+"_RECMOV")+oModelD:GetValue(cAlias+"_SEQPRO")
Elseif cAlias ==	"B68"
	cChavePesq := oModelD:GetValue(cAlias+"_ALIMOV")+oModelD:GetValue(cAlias+"_RECMOV")+oModelD:GetValue(cAlias+"_NUMPRC")+oModelD:GetValue(cAlias+"_TPPROC")
Else	
	cChavePesq := oModelD:GetValue(cAlias+"_ALIMOV")+oModelD:GetValue(cAlias+"_RECMOV")+oModelD:GetValue(cAlias+"_SEQUEN")
EndIf	

//Ponto de entrada para alteraГУes complementares
If ExistBlock("PLALTB72")			
		ExecBlock("PLALTB72", .F., .F., {cChavePesq}) 
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Rest nas linhas do browse e na area										 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )                   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(.T.)


//-------------------------------------------------------------------
/*/ { Protheus.doc } MDActVLD
Validacao da Ativacao do modelo

@author Alexander Santos 
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MDActVLD(oModel) Class PLSPADRC
LOCAL lRet			:= .T.           
LOCAL cPerfil	 	:= ""
LOCAL nOperation 	:= oModel:GetOperation()
LOCAL oGEN		 	:= NIL
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
AtuPClass(Self)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Valida se o browse pai tem registro										 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !::o790C:lHaveGuia
	_Super:ExbMHelp( STR0003 ) //"ImpossМvel realizar esta operaГЦo"
	lRet := .F.
Else
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se tem acesso a guia e operacao diferente de visualizar
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If oModel:GetOperation() <> 1
		lRet := ::o790C:VldAcessoGui()
	EndIf	                                                                      
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica o modelo que esta acessando o controle
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	Do Case
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Demanda
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDDemanda .And. !::o790C:lIntSau
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Somente se for registro de demanada
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lRet .And. !::o790C:lDemanda
				_Super:ExbMHelp( STR0004) //"Somente guia de Demanda"
				lRet := .F.
			EndIf                
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Somente se for o mesmo operador.
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lRet .And. nOperation == MODEL_OPERATION_UPDATE .And. !::lEditaProcesso
				lRet := ::VldRegOwner()
			EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Encaminhamento
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDEncaminhamento .And. !::o790C:lIntSau
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Somente se for registro de encaminhamento
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lRet .And. nOperation == MODEL_OPERATION_UPDATE
				lRet := ::VldRegOwner()
			EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Participativa
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDParticipativa .And. !::o790C:lIntSau
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se a guia e participativa
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lRet .And. !::o790C:lParticipativa
				_Super:ExbMHelp( STR0005) //"Somente guia Participativa"
				lRet := .F.
			EndIf	
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Se o operador e o dono da guia
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lRet .And. nOperation == MODEL_OPERATION_UPDATE
				lRet := ::VldRegOwner()
			EndIf                                
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se a guia ja esta agendada
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If lRet .And. ::o790C:lAgendada .And. ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT )
				_Super:ExbMHelp( STR0006) //"Esta guia jА esta agendada, exclua o agendamento antes!"
				lRet := .F.
			EndIf
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Analise e nao e interna-saude
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDAnaliseGui .And. !::o790C:lIntSau .AND. !::o790C:lRotinaGen
            
            If Empty( (::o790C:cACri)->&(::o790C:cACri+"_CODGLO") )
				_Super:ExbMHelp(STR0021)//"A critica nЦo esta selecionada!"
				lRet := .F.
            Else   
    			If (::o790C:cACri)->( FieldPos(::o790C:cACri + "_TIPO") ) > 0 .And. !Empty( (::o790C:cACri)->&( ::o790C:cACri + "_TIPO" ) )
					cPerfil := (::o790C:cACri)->&( ::o790C:cACri + "_TIPO" )
				Else	
					oGEN := PLSREGIC():New()
					oGEN:GetDadReg( "BCT",1, xFilial("BCT") + B53->B53_CODOPE + (::o790C:cACri)->&(::o790C:cACri+"_CODGLO") )
					cPerfil := oGEN:GetValue("BCT_TIPO")
			        oGEN:Destroy()
				EndIf	
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Se esta em analise 0=Autorizado;1=Negado;2=Em Analise
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			  	If ::o790C:cPerfil <> PLS_ADMINITRADOR .And. ::o790C:cPerfil <> cPerfil
					_Super:ExbMHelp( STR0007 ) //"Selecione uma critica correspondente ao ser perfil!"
					lRet := .F.
				EndIf
		                        
		    EndIf    
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Interna-saude
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Case ::lMDAnaliseGui .And. ::o790C:lIntSau
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Alteracao
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If nOperation == MODEL_OPERATION_UPDATE
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se e o owner do lancamento
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				lRet := ::VldRegOwner(.T.)
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se este registro tem inconsistencia
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If lRet .And. ::lIntSaudInco
					_Super:ExbMHelp( STR0008) //"JА foi sinalizando para o auditor responsАvel ou jА finalizada!"
					lRet := .F.
				EndIf
			EndIf	
	EndCase	
EndIf          
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } MDCancelVLD
Validacao do botao cancel do modelo

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MDCancelVLD(oGEN,cAlias) Class PLSPADRC
LOCAL lRet 		:= .T.
DEFAULT oGEN	:= NIL      
DEFAULT cAlias 	:= ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fecha o link documento caso exista
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If ValType( oLinkWord ) == "O" 
	If ValType( oGEN ) == "U" 
		oGEN := PLSMACRC():New()
	EndIf	
	oGEN:CloseDoc(oLinkWord:oWord)
EndIf        
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Aborta os SX8 gerados sem confirmacao
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RollBackSX8()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)            
//-------------------------------------------------------------------
/*/ { Protheus.doc } VWActBDocPro
Acao do botao ok da view

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VWActBDocPro(oView, oButton) Class PLSPADRC
LOCAL lRet := .T.
LOCAL oGEN := PLSMACRC():New()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fecha o link documento caso exista
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
::MDCancelVLD(oGEN)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Mostra documento padrao - DOT (View acessando Controle para pegar o modelo)
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oLinkWord := oGEN:GetDocPro()
oGEN:Destroy()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)                       
//-------------------------------------------------------------------
/*/ { Protheus.doc } VWListProc
Acao do botao de Lista do procedimento

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VWListProc( oView, oButton, cAlias ) Class PLSPADRC                            
LOCAL aArea   	:= GetArea()
LOCAL nI	  	:= 1
LOCAL nQtd	  	:= 0
LOCAL nRec 	:= (::o790C:cAIte)->( Recno() )
LOCAL cChave  	:= ""
LOCAL cProc	:= "" 
LOCAL lRet	  	:= .T.
LOCAL aMatCol 	:= {}
LOCAL aMatLin	:= {}
LOCAL aMatPro	:= {}
LOCAL oModelD 	:= oView:oModel:GetModel( oView:oModel:GetModelIds()[1] )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Colunas
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
AaDd( aMatCol,{ "CСdigo"      ,'@!',30} )
AaDd( aMatCol,{ "Procedimento",'@!',120} )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Posiciona no registro
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cChave := xFilial(::o790C:cAIte) + B53->B53_NUMGUI

oGEN := PLSREGIC():New()
oGEN:GetDadReg(::o790C:cAIte,1, cChave )

If oGEN:lFound
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Monta lista de procedimentos
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	While !(::o790C:cAIte)->( Eof() ) .And. cChave == xFilial(::o790C:cAIte)+(::o790C:cAIte)->&( ::o790C:SetFieldGui(::o790C:cAIte+"_OPEMOV+"+::o790C:cAIte+"_ANOAUT+"+::o790C:cAIte+"_MESAUT+"+::o790C:cAIte+"_NUMAUT") )
	
		AaDd( aMatLin, { (::o790C:cAIte)->&( ::o790C:cAIte+"_CODPRO" ) , (::o790C:cAIte)->&( ::o790C:cAIte+"_DESPRO" ), .F. } )
		
	(::o790C:cAIte)->( DbSkip() )
	EndDo
	
EndIf

oGEN:Destroy()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Pega lista
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cProc := StrTran(AllTrim( oModelD:GetValue(cAlias + "_LISPRO") ),Chr(10),"")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Coloca a lista em uma matriz
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oGEN 	:= PLSCONTR():New()
aMatPro := oGEN:Split(',', cProc )
oGEN:Destroy()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Marca os itens ja selecionados
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
For nI:=1 To Len(aMatPro)

	If (nPos := Ascan( aMatLin,{|x| AllTrim(x[1]) == AllTrim(aMatPro[nI]) } ) ) > 0
		aMatLin[ nPos ,Len( aMatLin[nPos] ) ] := .T.
	EndIf                     

Next
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Lista de procedimento
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PLSSELOPT( "Lista de Procedimentos", "Marca e Desmarca todos", aMatLin, aMatCol, MODEL_OPERATION_INSERT,.F.,.T.,.F.,.T.,"Procedimento : ",1 )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Retorna o Recno
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
(::o790C:cAIte)->( DbGoTo(nRec) )                                 

cProc := ""
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica itens selecionado
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
For nI := 1 To Len(aMatLin) 
	If aMatLin[nI,3]
		nQtd++
		cProc += AllTrim(aMatLin[nI,1]) + ","
		If nQtd = 8
			nQtd := 0
			cProc += Chr(10)
		EndIf			
	EndIf
Next                
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza Lista
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oModelD:SetValue( cAlias + "_LISPRO", Left( cProc,Len(cProc)-1 ) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Rest nas linhas do browse e na area										 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
RestArea( aArea )                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)                       
//-------------------------------------------------------------------
/*/ { Protheus.doc } VWOkCloseScreenVLD
Faz validacao para fechar a tela ou nao .T. Fecha .F nao deixa fechar a tela

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VWOkCloseScreenVLD(oView,lExiMsg) Class PLSPADRC
LOCAL lRet 	  	:= .T.
LOCAL oModelD 	:= oView:oModel:GetModel( oView:oModel:GetModelIds()[1] )
DEFAULT lExiMsg	:= .T.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Se for participativa
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If ::lMDParticipativa .And. oModelD:GetValue("B70_RELCON") <> '1' 
	
	lExiMsg := .F.		
EndIf

If lExiMsg
	dbSelectArea("BE2")
	dbSetOrder(1)
	
	If dbSeek(xFilial("BE2")+B53->B53_NUMGUI)
		
		While BE2->(BE2_FILIAL + BE2_OPEMOV + BE2_ANOAUT + BE2_MESAUT + BE2_NUMAUT) ==  xFilial("BE2")+B53->B53_NUMGUI
			
			If BE2->BE2_AUDITO == "1"
				lExiMsg := .F.
				EXIT
			EndIf
			
			BE2->(dbSkip())
		EndDo
	EndIf
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Mensagem ao usuario
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If lExiMsg .And. oView:GetOperation() <> MODEL_OPERATION_DELETE
	_Super:ExbMHelp( STR0009 ) //"Esta guia nЦo esta mais em Analise! OperaГЦo concluida com Sucesso!"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza o browse
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
PLS790OST()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)                          
//-------------------------------------------------------------------
/*/ { Protheus.doc } VWOkButtonVLD
Faz validacao para fechar a tela ou nao
 .T. Fecha

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VWOkButtonVLD(oModel,cAlias,cModelDet, lFluig) Class PLSPADRC
LOCAL lRet 	 	:= .T.
LOCAL nRecIte	:= 0
LOCAL aChave 	:= {}
LOCAL oGEN	 	:= NIL
LOCAL oModelD	:= oModel:GetModel( oModel:GetModelIds()[1] )
Local lDUTGrid := PlsAliasExi("BKY")
DEFAULT lFluig := .F.


 
If lFluig
	If !Empty(cModelDet) // passa o nome do model usado na estrutura de detalhes (FLUIG)
		oModelD 	 := oModel:GetModel( cModelDet )
	ELse
		oModelD 	 := oModel:GetModel( oModel:GetModelIds()[1] )
	EndIF
EndIf

IF (!::o790C:lRotinaGen)
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Analise da guia
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If ::lMDAnaliseGui
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Se for interna saude
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If ::o790C:lIntSau 
		
			If oModelD:GetValue(cAlias+"_INCONS") == "1" .And. Empty( oModelD:GetValue(cAlias+"_TPINCO") )
				_Super:ExbMHelp( STR0010 ) //"Informe o tipo da InconsistЙncia!"
				lRet := .F.                                  
			EndIf                                              
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Analise ope/tec/adm
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		Else
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Monta Chave
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If !::lLastReg 
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_OPEMOV"), '=', Left(B53->B53_NUMGUI,4) } )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_ANOAUT"), '=', SubStr(B53->B53_NUMGUI,5,4) } )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_MESAUT"), '=', SubStr(B53->B53_NUMGUI,9,2)} )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_NUMAUT"), '=', Right(B53->B53_NUMGUI,8)} )
			AaDd(aChave, { ::o790C:SetFieldGui(::o790C:cAIte + "_AUDITO"), '=', "1"} )
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Instancia da classe de acesso a banco
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				oGEN := PLSREGIC():New()
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Se for o ultimo registro
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			::lLastReg := ( oGEN:GetCountReg(::o790C:cAIte,aChave ) == 0 )
				
				oGEN:Destroy()
			EndIf	   
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Verifica se ja foi analisada por algum operador
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If !Empty( (::o790C:cACri)->&( ::o790C:cACri+"_OPERAD" ) ) .And. ::o790C:cOwner != (::o790C:cACri)->&( ::o790C:cACri+"_OPERAD" )
				_Super:ExbMHelp( STR0020+CRLF+"Analise ja iniciada por outro operador!" ) //"AtenГЦo"###"Analise ja iniciada por outro operador!"
				lRet := .F.
			EndIf
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//Ё Autorizado
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			If oModelD:GetValue( 'B72_PARECE' ) $ '0,1'
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verfica se o motivo foi informado
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If oModelD:GetValue( 'B72_PARECE' ) == '1' 
					If Empty( oModelD:GetValue("B72_MOTIVO") )
						MSGALERT( STR0020+CRLF+STR0014 ) //"AtenГЦo"###"Favor informar o Motivo!"
						lRet := .F.
					EndIf
				Endif
				If oModelD:GetValue( 'B72_PARECE' ) == '1' 
					If Empty( oModelD:GetValue("B72_MOTIVO") )
						MSGALERT( STR0020+CRLF+STR0022 ) //"AtenГЦo"###"Informe no campo Motivo a razЦo do procedimento ser Negado!"
						lRet := .F.
					EndIf
				Endif	
				
				If ::o790C:lCriDia .and. oModelD:GetValue( 'B72_PARECE' ) == '0' 
					If Empty( oModelD:GetValue("B72_DIAAUT") )
						
						MSGALERT( "AtenГЦo"+CRLF+"Informe o campo com a quantidade de diАrias autorizadas" ) //"AtenГЦo"###"Informe no campo Motivo a razЦo do procedimento ser Negado!"
						lRet := .F.
				
					ElseIf oModelD:GetValue("B72_DIASOL") < oModelD:GetValue("B72_DIAAUT")
						
						MSGALERT( "AtenГЦo"+CRLF+"Quantidade solicitada menor do que a autorizada." ) //"AtenГЦo"###"Informe no campo Motivo a razЦo do procedimento ser Negado!"
						lRet := .F.

					Else 
						lRet := MsgYesNo("Ao autorizar este procedimento, todas as crМticas serЦo excluМdas! Deseja realmente autorizar? ")
					EndIf
				Endif
						
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se foi informado valor e qtd
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If ::lLastReg .And. ( oModelD:GetValue( 'B72_QTDAUT' ) == 0 .Or. ( oModelD:IsFieldUpdated("B72_VLRAUT") .And. oModelD:GetValue( 'B72_VLRAUT' ) == 0 ) )
					_Super:ExbMHelp( STR0011 ) //"Verifique o conteudo informado na quantidade e valor"
					lRet := .F.
				EndIf  
				//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				//Ё Verifica se tem liberacao e se o saldo esta conforme a quantidade autorizada
				//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
				If ::o790C:lSadt .And. lRet  
					//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					//Ё Numero da liberacao
					//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					cNum := _Super:RetConCP(::o790C:cAIte,"NRLBOR")
					
					If ::lLastReg .And. !Empty(cNum)
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Salva posicao do registro
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					    nRecIte := ( ::o790C:cAIte )->( Recno() )
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Limpa o filtro
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						( ::o790C:cAIte )->( DbClearFilter() )
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Verifica se e liberacao e verifica o saldo
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						oGEN := PLSREGIC():New()
						oGEN:GetDadReg(::o790C:cAIte,1, xFilial(::o790C:cAIte) + _Super:RetConCP(::o790C:cAIte,"NRLBOR") + _Super:RetConCP(::o790C:cAIte,"SEQUEN"),,,.F.)
		
						If oGEN:lFound
		
							If _Super:RetConCP(::o790C:cAIte,"SALDO",'N') == 0
								_Super:ExbMHelp( STR0012 ) //"O item nЦo tem mais saldo para liberaГЦo!"
								lRet := .F.                                  
							EndIf	
							If oModelD:GetValue( 'B72_QTDAUT' ) > _Super:RetConCP(::o790C:cAIte,"SALDO",'N')
								_Super:ExbMHelp( STR0013 ) //"A quantidade nЦo pode ser maior que o saldo restante!"
								lRet := .F.                                  
							EndIf	
				        EndIf
				        oGEN:Destroy()
						//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
						//Ё Retorna ao registro original
						//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
					    ( ::o790C:cAIte )->( DbGoTo(nRecIte) )
					EndIf
				EndIf	
				
				If oModelD:GetValue( 'B72_QTDAUT' ) > oModelD:GetValue( 'B72_QTDSOL' ) //17-11
					MSGALERT( STR0020+CRLF+STR0024 ) //" Quantidade aprovada  maior que a Solicitada!"
					lRet := .F.                                  
				EndIf
			EndIf	              
		EndIf
		
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//  Verifica se os campos B72_PARECE e B72_OBSANA estЦo preenchidos
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд	
		If ! Empty( oModelD:GetValue('B72_PARECE'))
			If oModelD:GetValue('B72_PARECE') $ '0,1' .And. Empty( oModelD:GetValue('B72_OBSANA'))   
			   ApMsgAlert("AtenГЦo"+CRLF+"Informe o campo de observaГЦo auditor na analise")
			   lRet := .F.  
			EndIf
		Else
		    ApMsgAlert("AtenГЦo"+CRLF+"Informe um Parecer!")
		    lRet := .F.
		EndIf

		//Se existir uma sala aberta, precisa finalizar
		if oModelD:GetValue( 'B72_PARECE' ) $ '0,1' .And. GetNewPar("MV_PLSHAT","0") == "1" .And. B53->(FieldPos("B53_MSGSTA")) > 0 .And. B53->B53_MSGSTA $ "12"
			oGEN  := PLSREGIC():New()
			oChat := PLMensView():New(B53->B53_NUMGUI)		
			if oGEN:GetCountReg(::o790C:cAIte,aChave ) == 1 .And. !oChat:procFinRoom()
				ApMsgAlert(STR0025) //"NЦo foi possivel finalizar a sala de Mensageria, contate o administrador do sistema."
				lRet := .F.
			endIf
			oGEN:Destroy()
		endIf

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//  Verifica se o campo B72_CODDUT estА preenchido caso haja DUT para o procedimento
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If lDUTGrid .And. (Empty(oModelD:GetValue('B72_CODDUT')) .Or. Empty(oModelD:GetValue('B72_TABDUT'))) .And. GetQtdDutProc(oModelD:GetValue('B72_CODPRO')) > 0
			MsgInfo(STR0026)
			lRet := .F.  
		EndIf

	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Fim da Rotina															 
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
ELSE
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//Ё Verifica se foi Aprovado ou Rejeitado
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	If oModelD:GetValue( 'B72_PARECE' ) $ '0,1'
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		//Ё Verfica se o motivo foi informado
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
		If oModelD:GetValue( 'B72_PARECE' ) == '1' 
			If Empty( oModelD:GetValue("B72_MOTIVO") )
				MSGALERT( STR0020+CRLF+STR0022 ) //"AtenГЦo"###"Informe no campo Motivo a razЦo do procedimento ser Negado!"
				lRet := .F.
			EndIf
		Endif			
	EndIf
ENDIF  	
If lRet .AND. !EMPTY(oModelD:GetValue('B72_OBSANA'))
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Optamos pela criaГЦo do ponto de entrada via execblock pois o model И chamado muitas vezes,
	//de forma que se utilizassemos o ponto de entrada do MVC o cliente teria que tratar para que executasse
	//sua funГЦo apenas uma vez.                                
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	If ExistBlock("PLPADRCPA") 
		lRet := ExecBlock("PLPADRCPA",.F.,.F.,oModelD)
		If lRet != .F.
			lRet := .T.
		EndIf
	Endif 
EndIf 
Return(lRet)                          
//-------------------------------------------------------------------
/*/ { Protheus.doc } VWInitVLD
Acao do botao ok da view

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VWInitVLD( oView ) Class PLSPADRC
LOCAL lRet := .T.            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } VldRegOwner
Verifica se o operadora corrente e dono do registro selecionado no modelo

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VldRegOwner(lAudITSA) Class PLSPADRC
LOCAL lRet 	     := .T. 
DEFAULT lAudITSA := .F.
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁSe o operador correte e dono do registro se lAudITSA TRUE chega o auditor
//Ёda interna-saude analisou um registro analisado.
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !lAudITSA
	lRet := Empty(::cOwner) .Or. ::cOwner == ::cOperad
Else 
	lRet := Empty(::cOwnerAud) .Or. ::cOwnerAud == ::cOperad
EndIf	    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁMensagem
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If !lRet
	_Super:ExbMHelp( STR0017) //"Somente o responsАvel pelo registro tem acesso"
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//ЁFim do Metodo
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return(lRet)
//-------------------------------------------------------------------
/*/ { Protheus.doc } Destroy
Libera da memoria o obj (Destroy)

@author Alexander Santos
@since 02/02/11
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Destroy(oObj) Class PLSPADRC
FreeObj(oObj)
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁAtuPClass Ё Autor Ё Totvs				    	Ё Data Ё 30/03/10 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Atualiza propriedades da Classe	  						 			Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function AtuPClass(oSelf)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica qual modelo esta sendo usando pelo controle e atualiza propriedade da classe
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oSelf:cOperad 				:= RETCODUSR()
oSelf:lMDDemanda 			:= Iif(oSelf:cAlias=='B68',.T.,.F.)
oSelf:lEditaProcesso 		:= Iif(oSelf:cAlias=='B68' .And. B68->B68_PERPRC == '1',.T.,.F.)
oSelf:lIntSaudInco  		:= Iif(oSelf:cAlias=='B72' .And. B72->B72_INCONS $ '1,3',.T.,.F.)

oSelf:lMDNotacoes	 		:= Iif(oSelf:cAlias=='B69',.T.,.F.)
oSelf:lMDParticipativa 	:= Iif(oSelf:cAlias=='B70',.T.,.F.)
oSelf:lMDEncaminhamento	:= Iif(oSelf:cAlias=='B71',.T.,.F.)
oSelf:lMDAnaliseGui  		:= Iif(oSelf:cAlias=='B72',.T.,.F.)
oSelf:lMDRespAuditor  	:= Iif(oSelf:cAlias=='B73',.T.,.F.)
oSelf:cOwner  				:= Iif( (oSelf:cAlias)->( FieldPos(oSelf:cAlias + "_OPERAD") ) > 0,(oSelf:cAlias)->&( oSelf:cAlias + "_OPERAD" ),"")
oSelf:cOwnerAud			:= Iif( oSelf:cAlias=='B72',B72->B72_COPERE ,"")
oSelf:lOwnerEsp			:= oSelf:cOwner == oSelf:cOperad
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Atualiza informacoes da classe 790c
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oSelf:o790C:SetAtuPClass()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Funcao
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return


//-------------------------------------------------------------------
/*/ { Protheus.doc } VerIteAtB53
Verifica os status dos itens na tabela de Origem
Author Renan Martins
@since 04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VeriteAtB53(lProcAutorizado) 

Local o790C 	 := PLSA790C():New()
Local nPosit	 := 0
Local nNegat	 := 0
Local lRetorno	 := .F.

/*se o valor da variavel for false, ele deve retornar se encontrou ao menos um procedimento 
negado e se verdadeiro deve retornar se encontrou ao menos um procedimento aprovado*/
Default lProcAutorizado := .T. 

(o790C:cAite)->(DbSetOrder((o790C:nIdxIte)))
(o790C:cAite)->(DbGoTop())

If ( !(o790C:cAcab) $ 'B4Q, BE4')
//Verifico se para esta guia ainda temos mais procedimentos em auditoriae se jА foram auditados
	If ( (o790C:cAite)->(MsSeek(xfilial(o790C:cAite)+Alltrim(B53->B53_NUMGUI))) )
		
		While ( !(o790C:cAite)->(EOF()) .AND. xFilial(o790C:cAite)+(o790C:cAite)->&(o790C:cAite+"_OPEMOV")+(o790C:cAite)->&(o790C:cAite+"_ANOAUT")+(o790C:cAite)->&(o790C:cAite+"_MESAUT")+(o790C:cAite)->&(o790C:cAite+"_NUMAUT") == ;
											  xFilial(o790C:cAite)+ Alltrim(B53->B53_NUMGUI))
	
			If (o790C:cAite)->&(o790C:cAite+"_STATUS") == '1'
				nPosit++

				If lProcAutorizado
					lRetorno := .T.
					EXIT
				Endif
			Else
				nNegat++

				If !lProcAutorizado
					lRetorno := .T.
					EXIT
				Endif
			EndIf
			
			(o790C:cAite)->(dbSkip())
		EndDo
	EndIf
Else
	If ( (o790C:cAite)->(MsSeek(xfilial(o790C:cAite)+Alltrim(B53->B53_NUMGUI))) )
		
		While ( !(o790C:cAite)->(EOF()) .AND. xFilial(o790C:cAite)+(o790C:cAite)->&(o790C:cAite+"_CODOPE")+(o790C:cAite)->&(o790C:cAite+"_ANOINT")+(o790C:cAite)->&(o790C:cAite+"_MESINT")+(o790C:cAite)->&(o790C:cAite+"_NUMINT") == ;
											  xFilial(o790C:cAite)+ Alltrim(B53->B53_NUMGUI))

			If (o790C:cAite)->&(o790C:cAite+"_STATUS") == '1'
				nPosit++

				If lProcAutorizado
					lRetorno := .T.
					EXIT
				Endif
			Else
				nNegat++

				If !lProcAutorizado
					lRetorno := .T.
					EXIT
				Endif
			EndIf

			(o790C:cAite)->(dbSkip())
		EndDo
	EndIf
EndIf

Return lRetorno

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSPADRC  Ё Autor Ё Totvs				    Ё Data Ё 30/03/10 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Somente para compilar a class							  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSPADRC
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckTitPagAto
Verifica se a guia auditada possui pagamento no ato, para retornar o 
numero do tМtulo devido a funГЦo NxtSX5Nota nao pode estar entre um 
Begin Transaction

@author Guilherme Carreiro / Vinicius Teixeira
@since 23/05/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function CheckTitPagAto(cAliasIte, lIntern, lEvolucao, cChaveCab, cChaveBD6, cParecer, cSequen, lProrrog, cNumGuia)

    Local cAliIteAto := ""
    Local cStatus := ""
    Local aRetSta := {}
    Local aAreaTit := {}
    Local aAreaBEA := {}
    Local aSeqPagAto := {}
    Local nX := 0
    Local oFindReg := Nil
    Local cNumTitPagAto := ""

    If lIntern .And. !lEvolucao
        aAreaBEA := BEA->(GetArea())

        oFindReg := PLSREGIC():New()
        oFindReg:GetDadReg("BEA", 6, xFilial("BEA")+cNumGuia)
                    
        If oFindReg:lFound
            cChaveCab := oFindReg:GetValue("BEA_OPEMOV")+oFindReg:GetValue("BEA_ANOAUT")+oFindReg:GetValue("BEA_MESAUT")+oFindReg:GetValue("BEA_NUMAUT")                    
        EndIf   

        oFindReg:Destroy()
        FreeObj(oFindReg)
        oFindReg := Nil

        RestArea(aAreaBEA)
    EndIf

    If cParecer <> "3"

        If lIntern .And. !lEvolucao
            cAliIteAto := "BEJ"
        Else
            cAliIteAto := cAliasIte
        EndIf

        aAreaTit := &(cAliIteAto+'->(GetArea())')
        
        aRetSta := PLSGUIAAud(cChaveCab, Nil, Nil, cAliIteAto, lEvolucao, lIntern, Nil, Nil, lProrrog, .F.)
        cStatus := aRetSta[2]

        If aRetSta[3] <= 1 .And. (cStatus $ "1/2" .Or. cParecer == "0") // Verifica se tem item autorizado e se И o ultimo item

            // Verifica se ha itens com pagamento no Ato
            BD6->(DbSetOrder(1))
            If BD6->( MsSeek( xFilial("BD6")+cChaveBD6) )
                While !BD6->(Eof()) .And. xFilial("BD6")+cChaveBD6 == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) 
                    
                    If BD6->BD6_PAGATO == "1"
                        aAdd(aSeqPagAto, BD6->BD6_SEQUEN)
                    EndIf
                    
                    BD6->(DbSkip())
                EndDo
            EndIf

            If Len(aSeqPagAto) > 0 
                
                &(cAliIteAto+"->( DbSetOrder(1))") //_FILIAL + _OPEMOV + _ANOAUT + _MESAUT + _NUMAUT + _SEQUEN
                For nX := 1 To Len(aSeqPagAto)
                    If &(cAliIteAto+"->( MsSeek('"+xFilial(cAliIteAto) + cChaveCab + aSeqPagAto[nX] + "'))")

                        If (cSequen == aSeqPagAto[nX] .And. cParecer == "0") .Or. (&(cAliIteAto+"->"+cAliIteAto+"_AUDITO") <> "1" .And. &(cAliIteAto+"->"+cAliIteAto+"_STATUS") == "1")                         
                            
                            cNumTitPagAto := PLSE1NUM(GetNewPar("MV_PLSPRCP","CPP"))
                            Exit

                        EndIf

                    EndIf
                Next nX 

            EndIf               
        EndIf

        RestArea(aAreaTit)
    EndIf

Return cNumTitPagAto
