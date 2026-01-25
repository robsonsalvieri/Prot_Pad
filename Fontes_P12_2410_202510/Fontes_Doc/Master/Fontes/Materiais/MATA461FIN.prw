#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA461FIN.CH"

PUBLISH MODEL REST NAME MATA461FIN SOURCE MATA461FIN

//-------------------------------------------------------------------------
/*/	{Protheus.doc} MATA461FIN
Tabela intermediaria FKW Natureza de Rendimentos - Projeto REINF - FAT/CRM

@param nOpc		3-Inclusao/5-Exclusao
@param aNatRend Dados da Natureza de Rendimento do item do Pedido de Venda
@param aRecSE1	Dados dos titulos a receber gerados

@author juan.bartha
@since 30/12/2022
@version 12
@type function
/*/
//-------------------------------------------------------------------------

Function A461FKW(nOpc,aNatRend,aRecSE1)

	Local aArea		:= GetArea()
	Local aDados	:= {}
	Local cChaveTit	:= ""
	Local nI		:= 0
	Local nX		:= 0
	Local nPerc		:= 0
	Local nValor	:= 0
	Local nBase		:= 0
	Local nPercSusp	:= 0
	Local nVlrSusp	:= 0
	Local nBaseSusp	:= 0
	Local cNumProc	:= 0
	Local cTpProc	:= 0
	Local cIndSusp	:= 0

	Local lRatIRRF	:= IIF(nOpc == 3, aRecSE1[1] > aRecSE1[2][1][7], .F.)
	Local nPercRat 	:= IIF(nOpc == 3,(aNatRend[1]/aRecSE1[1]), 0)
	Local cFilSE1	:= xFilial("SE1")
	Local cFilFKW 	:= xFilial("FKW")

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))

	DbSelectArea("SD2")
	SD2->(DbSetOrder(1))

	If nOpc == 3 //Inclusao
		
		//Gera dados para a tabela intermediaria a partir dos titulos (SE1) x Natureza de rendimentos
		For nI := 1 To Len(aRecSE1[2])
			
			cChaveTit := FINGRVFK7("SE1", cFilSE1+"|"+aRecSE1[2][nI][1]+"|"+aRecSE1[2][nI][2]+"|"+aRecSE1[2][nI][3]+"|"+aRecSE1[2][nI][4]+"|"+aRecSE1[2][nI][5]+"|"+aRecSE1[2][nI][6])
			
			For nX := 1 To Len(aNatRend[2])

				If aNatRend[2][nX][2] > 0

					If lRatIRRF
						nPerc	:= (aNatRend[2][nX][2] / aNatRend[1]) * 100
						nValor	:= (aRecSE1[2][nI][7] * nPercRat) * (nPerc/100)
						nBase	:= (aRecSE1[2][nI][8] * nPercRat) * (nPerc/100)

						If !Empty(aNatRend[3])
							nPercSusp 	:= (aNatRend[4][nX][2] / aNatRend[3]) * 100
							nVlrSusp	:= (nValor * aNatRend[4][nX][4])/100
							nBaseSusp	:= (nBase * aNatRend[4][nX][4])/100
							cNumProc	:= aNatRend[4][nX][5]
							cTpProc		:= aNatRend[4][nX][6]
							cIndSusp	:= aNatRend[4][nX][7]
						EndIf
					ElseIf aRecSE1[2][nI][7] > 0 //Valida se o titulo possui valor de IRRF para calculo
						nPerc	:= (aNatRend[2][nX][2] / aNatRend[1]) * 100
						nValor	:= aNatRend[2][nX][2]
						nBase	:= aNatRend[2][nX][3]

						If !Empty(aNatRend[3])
							nPercSusp 	:= (aNatRend[4][nX][2] / aNatRend[3]) * 100
							nVlrSusp	:= (nValor * aNatRend[4][nX][4])/100
							nBaseSusp	:= (nBase * aNatRend[4][nX][4])/100
							cNumProc	:= aNatRend[4][nX][5]
							cTpProc		:= aNatRend[4][nX][6]
							cIndSusp	:= aNatRend[4][nX][7]
						EndIf
					EndIf

					If aRecSE1[2][nI][7] > 0 //Valida se o titulo possui valor de IRRF para gravar na FKW
						If !Empty(aNatRend[3])
							aadd(aDados,{cFilFKW,cChaveTit,"IRF",aNatRend[2][nX][1],nPerc,nBase,nValor,nBaseSusp,nVlrSusp,cNumProc,cTpProc,cIndSusp,nPercSusp})
						Elseif Empty(aNatRend[3])
							aadd(aDados,{cFilFKW,cChaveTit,"IRF",aNatRend[2][nX][1],nPerc,nBase,nValor,0,0,"","","",0})
						Endif
					EndIf

				Endif

			Next nX

		Next nI

		If Len(aDados) > 0 .And. FindFunction("F070Grv") //gravacao na tabela intermediaria
			F070Grv(aDados,3,"2")
		Endif
					
	Endif

	RestArea(aArea)

Return

//-------------------------------------------------------------------------------
/*/	{Protheus.doc} MATA461FIN

Tela Clientes x Processos Ref. (MVC) - Projeto REINF - FAT/CRM

Interface para informacao dos valores de IRRF para Naturezas de Rendimento
que possuem Suspensão Judicial amarrados ao cadastro do cliente - Projeto REINF

@param cAlias 	Sigla da tabela
@param nOpc		3-Inclusao/4-Alteracao/5-Exclusao
@param nReg 	Numero do recno do registro do cliente

@author juan.bartha
@since 03/01/2023
@version 12
@type function
/*/
//-------------------------------------------------------------------------------

Function CRMANatRen(cAlias, nReg, nOpc)

	Local aArea 	:= GetArea()
	Local oModel	:= Nil
	Local cMemory	:= IIF(M->A1_COD == Nil,"SA1->","M->")

	Default cAlias  := Alias()
	Default nReg	:= (cAlias)->(RecNo())
	Default nOpc	:= 4

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona a entidade                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( cAlias )
	MsGoto( nReg )

	oModel := FWLoadModel("MATA461FIN")
	oModel:SetOperation(nOpc)
	oModel:GetModel("SA1MASTER"):bLoad := {|| {xFilial("SA1"),&(cMemory+"A1_COD"),&(cMemory+"A1_LOJA"),&(cMemory+"A1_NOME")}}
	oModel:Activate() 

	oView := FWLoadView("MATA461FIN")
	oView:SetModel(oModel)
	oView:SetOperation(nOpc) 
				
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0001)//Processos
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:SetCloseOnOK({|| .T. })
	oExecView:SetOperation(nOpc)
	oExecView:OpenView(.T.)

	RestArea(aArea)
	aSize(aArea,0)


Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Cria o objeto comtendo a estrutura , relacionamentos das tabelas envolvidas 

@sample		ModelDef()

@author		Juan Bartha
@since		03/01/2023
@version	12              
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

	Local oModel 		:= Nil
	Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ "A1_FILIAL|A1_COD|A1_LOJA|A1_NOME|"}
	Local bAvCpoItm		:= {|cCampo| AllTrim(cCampo)+"|" $ "AQZ_FILIAL|AQZ_CLIENT|AQZ_LOJA|AQZ_NUMPRO|AQZ_TIPO|AQZ_PERIRF|AQZ_INDSUS|"}
	Local oStructCab 	:= FWFormStruct(1,"SA1",bAvCpoCab)
	Local oStructItem 	:= FWFormStruct(1,"AQZ",bAvCpoItm)
	Local aGatilhAQZ	:= {}
	Local nX			:= 0

	oModel := MPFormModel():New("MATA461FIN",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)
	
	//Criação de Gatilho
	aAdd(aGatilhAQZ, FWStruTrigger(	"AQZ_NUMPRO",;        							//Campo Origem
									"AQZ_TIPO",;          							//Campo Destino
									"GMat461Fin('AQZ_TIPO')",;    					//Regra de Preenchimento
									.F.,;                 							//Irá Posicionar?
									"",;               								//Alias de Posicionamento
									0,;                   							//Índice de Posicionamento
									'',;											//Chave de Posicionamento
									NIL,;                 							//Condição para execução do gatilho
									"001"))                							//Sequência do gatilho
	
	aAdd(aGatilhAQZ, FWStruTrigger(	"AQZ_NUMPRO",;        							//Campo Origem
									"AQZ_INDSUS",;          						//Campo Destino
									"GMat461Fin('AQZ_INDSUS') ",;    				//Regra de Preenchimento
									.F.,;                 							//Irá Posicionar?
									"",;               								//Alias de Posicionamento
									0,;                   							//Índice de Posicionamento
									'',;											//Chave de Posicionamento
									NIL,;                 							//Condição para execução do gatilho
									"002"))                							//Sequência do gatilho
	
    //Percorrendo os gatilhos e adicionando na Struct
    For nX := 1 To Len(aGatilhAQZ)
        oStructItem:AddTrigger(  aGatilhAQZ[nX][01],; //Campo Origem
                           		aGatilhAQZ[nX][02],; //Campo Destino
                            	aGatilhAQZ[nX][03],; //Bloco de código na validação da execução do gatilho
                            	aGatilhAQZ[nX][04])  //Bloco de código de execução do gatilho
    Next
	
	oModel:AddFields("SA1MASTER",/*cOwner*/,oStructCab,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	oModel:AddGrid("AQZCONTDET","SA1MASTER",oStructItem,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

	oModel:SetPrimaryKey({"AQZ_FILIAL","AQZ_CLIENT","AQZ_LOJA","AQZ_NUMPRO","AQZ_TIPO","AQZ_INDSUS"})

	oModel:GetModel("AQZCONTDET"):SetOptional( .T. )
	oModel:GetModel("AQZCONTDET"):SetUniqueLine({"AQZ_NUMPRO","AQZ_TIPO","AQZ_INDSUS"})
	oModel:GetModel("AQZCONTDET"):SetMaxLine(9999)

	oModel:SetRelation("AQZCONTDET",{ {"AQZ_FILIAL","A1_FILIAL"},{"AQZ_CLIENT","A1_COD"},{"AQZ_LOJA","A1_LOJA"}},AQZ->( IndexKey(1)))

Return(oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Monta o objeto que irá permitir a visualização da interfece grafica,
com base no Model

@sample		ViewDef()
@return	    oView - bojeto de visualizacao da interface grafica.

@author		Juan Bartha
@since		03/01/2023
@version	12             
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

	Local oView 		:= Nil
	Local oModel		:= FwLoadModel("MATA461FIN")
	Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ "A1_FILIAL|A1_COD|A1_LOJA|A1_NOME|"}
	Local bAvCpoItm		:= {|cCampo| AllTrim(cCampo)+"|" $ "AQZ_NUMPRO|AQZ_TIPO|AQZ_PERIRF|AQZ_INDSUS|"}
	Local oStructCab 	:= FWFormStruct(2,"SA1",bAvCpoCab)
	Local oStructItem 	:= FWFormStruct(2,"AQZ",bAvCpoItm)

	// Alterando a propriedade dos campos, para nao ser editaveis
	oStructCab:SetProperty("A1_COD"		,MVC_VIEW_CANCHANGE, .F. )
	oStructCab:SetProperty("A1_LOJA"  	,MVC_VIEW_CANCHANGE, .F. )
	oStructCab:SetProperty("A1_NOME"   	,MVC_VIEW_CANCHANGE, .F. )

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_MST",oStructCab,"SA1MASTER")
	oView:AddGrid("VIEW_AQZ",oStructItem, "AQZCONTDET")

	oView:CreateHorizontalBox("VIEW_TOP",30)
	oView:SetOwnerView("VIEW_MST","VIEW_TOP")

	oView:CreateHorizontalBox("VIEW_DET",70)  
	oView:SetOwnerView("VIEW_AQZ","VIEW_DET")

Return(oView)

Function GMat461Fin(cCDomin) 

	Local cResult := ""

	If !Empty(M->AQZ_NUMPRO)
		If cCDomin == "AQZ_TIPO"
			cResult := CCF->CCF_TIPO
		ElseIf cCDomin == "AQZ_INDSUS"
			cResult := CCF->CCF_INDSUS
		EndIf
	EndIf

Return cResult

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValIndSus

Função para o valid do campo C6_INDSUS retornar a Suspensão correta na AQZ

@sample		ValIndSus()
@return	    lRetorno - Retorna se encontrou o registro na AQZ

@author		Squad Crm
@since		26/07/2024
@version	12             
/*/
//------------------------------------------------------------------------------
Function ValIndSus() 

Local lRetorno	:= .T.
Local aArea		:= GetArea()

If !Empty(M->C6_INDSUS) 
	lRetorno := ExistCpo("AQZ",M->C5_CLIENTE+M->C5_LOJACLI+M->C6_INDSUS,2)
EndIf

RestArea(aArea)

Return lRetorno
