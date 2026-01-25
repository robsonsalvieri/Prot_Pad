#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "hatActions.ch"

#define _glossProtocol_B4D_alt              "0054"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPedPD
Funcao generica de cadastro de pedidos simples.

	cCodtra  -> Codigo do EndPoint                            
	cAlias -> Alias da tabela que esta sendo gravada 
	cChave -> Chave do registro na tabela correspondente
	aDadosAlt -> Array com os campos que sao enviados no HAT 
	nInd -> Indice para posicionar no registro correspondente

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPedPD(nOpc,cCodtra,cAlias,cChave,aDadosAlt,nInd,nRecno)
Local nX := 0
Local cCamposAlt  := ""
Local cBase       := ""
Local cAlt        := ""
Local lFind       := .F.
Local aArea       := (cAlias)->(GetArea())
Default aDadosAlt := {}
Default nInd      := 1
Default nRecno    := 0

if PLHTACTRA(cCodtra)

	if nOpc == K_Incluir
		PLHTGrvPed(cCodtra,cChave,"",cAlias,nRecno)

	elseif nOpc == K_Alterar
		(cAlias)->(DbSetOrder(nInd))
		//Para achar o registro, priorizo a busca pelo Recno
		if nRecno > 0
			(cAlias)->(DbGoTo(nRecno))
			lFind := .T.
		elseIf (cAlias)->(MsSeek(xFilial(cAlias)+cChave)) 
			lFind := .T.
		endIf

		if lFind
			for nX := 1 to len(aDadosAlt)
				if Valtype(&(cAlias+"->"+aDadosAlt[nX][1])) == "C"
					cBase := Alltrim(&(cAlias+"->"+aDadosAlt[nX][1]))
					cAlt  := Alltrim(aDadosAlt[nX][2])
					iif(cBase <> cAlt .Or. cAlt <> cBase,cCamposAlt += ","+aDadosAlt[nX][1],cCamposAlt += "")
				else
					iif(&(cAlias+"->"+aDadosAlt[nX][1]) <> aDadosAlt[nX][2],cCamposAlt += ","+aDadosAlt[nX][1],cCamposAlt += "")
				endIf
			next
			
		endIf
		
		if !Empty(cCamposAlt)
			PLHTGrvPed(cCodtra,cChave,cCamposAlt,cAlias,nRecno)
		endIf
				
	endIf

	//Se for uma transacao prioritaria, ja realizo o envio
	VerifPrior(cCodtra)
	restArea(aArea)

endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPedGD
Funcao generica de cadastro padrão de Grids

	cCodtra  -> Codigo do EndPoint                            
	cAlias -> Alias da tabela que esta sendo gravada 
	cChave -> Chave do registro na tabela correspondente
	aDadosAlt -> Array com os campos que sao enviados no HAT 
	nInd -> Indice para posicionar no registro correspondente

@author  Renan Sakai 
@version P12
@since   06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPedGD(nOpc,cCodTraInc,cCodTraAlt,cAlias,aHeader,aCols,nInd,aChave,cCompChave,aCamposAlt)
Local nX   := 0
Local nY   := 0
Local nPos := 0
Local cChave  := ""
Local cBase   := ""
Local cAlt    := ""
Local cCamposAlt := ""
Local aArea       := (cAlias)->(GetArea())
Local lExitChave  := .F.
Default nInd      := 1

(cAlias)->(DbSetOrder(nInd))

for nX := 1 to len(aCols)
	cCamposAlt := "" //Reinicializa campos alterados
	lExitChave := .F.

	//Se o registro esta deletado, pula
	if aCols[nX][len(aHeader)+1]
		loop
	endIf

	//Monta a chave
	for nY := 1 to len(aChave)
		if nY == 1 .And. !Empty(cCompChave)
			cChave := cCompChave
		endIf
		nPos := PLRETPOS(aChave[nY],aHeader)
		if nPos > 0 
			if Empty(aCols[nX][nPos])
				lExitChave := .T.
			else
				cChave += aCols[nX][nPos]
			endIf	
		endIf	
	next

	//Se algum campo da chave estiver vazio, nao incluo o registro
	if lExitChave //IMPORTANTE: Analisar se tem algum Alias que pode vir com Chave vazia
		loop
	endIf
	
	//Procura o registro 
	if nOpc == K_Alterar .And. (cAlias)->(MsSeek(xFilial(cAlias)+cChave))
		for nY := 1 to len(aCamposAlt) 
			nPos := PLRETPOS(aCamposAlt[nY],aHeader)
			if nPos > 0 
				if Valtype(&(cAlias+"->"+aCamposAlt[nY])) == "C"
					cBase := Alltrim(&(cAlias+"->"+aCamposAlt[nY]))
					cAlt  := Alltrim(aCols[nX][nPos])
					iif(cBase <> cAlt .Or. cAlt <> cBase,cCamposAlt += ","+aCamposAlt[nY],cCamposAlt += "")
				else
					iif( &(cAlias+"->"+aCamposAlt[nY]) <> aCols[nX][nPos],cCamposAlt += ","+aCamposAlt[nY],cCamposAlt += "")
				endIf
			endIf	
		next
		if !Empty(cCamposAlt)
			PLHTGrvPed(cCodTraAlt,cChave,cCamposAlt,cAlias)
		endIf
	//Nao encontrou o registro, e uma inclusao
	else
		PLHTGrvPed(cCodTraInc,cChave,"",cAlias)
	endIf
next	

//Se for uma transacao prioritaria, ja realizo o envio
VerifPrior(cCodTraInc)
restArea(aArea)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPrior
Faz o envio para o HAT de pedidos prioritarios

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPrior(cEmp,cFil,cCodtra)
Local aRet := {}

RpcSetType(3)
RpcSetEnv(cEmp,cFil,,,'PLS')

aRet := PLHATEndPo(cCodtra)
PLHTPosGen(aRet[1],aRet[2],aRet[3],aRet[4],aRet[5])

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHAT260
Realiza a gestao do cadastro de Beneficiarios x HAT

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHAT260(nOpc,aHeaderBA1,aColsBA1,aCabBFE,aDadBFE,cCodPlaBA3,lAltBTS,aDadosBTS,aCabBF3,aColsBF3,;
				  aCabBFG,aDadBFG,aCabBFD,aDadBFD,cKeyBA3,aCabBFC,aDadBFC) 
Local aChave     := {}
Local aCamposAlt := {}
Local aMap       := {}
Local nX := 0

if nOpc <> K_Excluir
	PLHATBenef(nOpc,aHeaderBA1,aColsBA1,aCabBFE,aDadBFE,cCodPlaBA3,lAltBTS,aDadosBTS) //beneficiaries
	PLHATPreDi(nOpc,aHeaderBA1,aColsBA1,aCabBF3,aColsBF3) //preExistingDiseases - BF3
	PLHATadBFG(nOpc,aHeaderBA1,aColsBA1,aCabBFG,aDadBFG) //coverages/level - BFG

	//BFD - Procedimentos das Famílias
	aChave := {'BFD_CODPAD','BFD_CODPSA','BFD_NIVEL'}
	aMap := PLHATMap("BFD")
	for nX := 1 to len(aMap)
		aadd(aCamposAlt,aMap[nX][2])
	next				
	PLHATPedGD(nOpc,_coverageProcedureLevel_BFD_inc,_coverageProcedureLevel_BFD_alt,'BFD',aCabBFD,aDadBFD,1,aChave,cKeyBA3,aCamposAlt)

	//BFC - Grupos de Cobertura Famílias
	aChave := {'BFC_CODGRU'}
	aMap := PLHATMap("BFC")
	for nX := 1 to len(aMap)
		aadd(aCamposAlt,aMap[nX][2])
	next	
	PLHATPedGD(nOpc,_coverageGroupLevel_BFC_inc,_coverageGroupLevel_BFC_alt,'BFC',aCabBFC,aDadBFC,1,aChave,cKeyBA3,aCamposAlt)

endIf

Return    


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHAT360
Realiza a gestao do cadastro de Prestadores x HAT

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHAT360(nOpc,cCodBAU,aDadBAU)

PLHATPedPD(nOpc,IIF(nOpc==K_Incluir,_healthProviders_inc,_healthProviders_alt),"BAU",cCodBAU,aDadBAU,1)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATBCI
Realiza a gestao do cadastro de protocolos de faturamento do prestador

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATBCI(nOpc,cCodOpe,cCodLdp,cCodPeg)

	PLHTGrvPed(_billing_BCI_alt,cCodOpe+cCodLdp+cCodPeg,"","BCI")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATB4D
Atualiza a BCI do HAT com os dados do recurso de glosa

@author  Lucas Nonato
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATB4D(cProtoc)

	PLHTGrvPed(_glossProtocol_B4D_alt, cProtoc, "", "B4D")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHAT365
Realiza a gestao do complemento de Prestadores x HAT

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHAT365(nOpc,cCodBAU,oBB8,oBAX)
Local aChave     := {}
Local aCamposAlt := {}
Local aMap       := {}
Local nX         := 0
Local aCabBB8    := aClone(oBB8:aHeader)
Local aDadBB8    := aClone(oBB8:aCols)
Local aCabBAX    := aClone(oBAX:aHeader)
Local aDadBAX    := aClone(oBAX:aCols)

//BB8 - Locais de Atendimento
aChave := {'BB8_CODINT','BB8_CODLOC','BB8_LOCAL'} //BB8_CODIGO passo atraves do cCodBAU
aCamposAlt := {}
aMap := PLHATMap("BB8")
for nX := 1 to len(aMap)
	aadd(aCamposAlt,aMap[nX][2])
next
PLHATPedGD(nOpc,_attendanceLocations_inc,_attendanceLocations_alt,'BB8',aCabBB8,aDadBB8,1,aChave,cCodBAU,aCamposAlt)

//BAX - Especialidades
aChave := {'BAX_CODINT','BAX_CODLOC','BAX_CODESP'} //BAX_CODIGO passo atraves do cCodBAU
aCamposAlt := {}
aMap := PLHATMap("BAX")
for nX := 1 to len(aMap)
	aadd(aCamposAlt,aMap[nX][2])
next
PLHATPedGD(nOpc,_healthProviderSpecialties_inc,_healthProviderSpecialties_alt,'BAX',aCabBAX,aDadBAX,1,aChave,cCodBAU,aCamposAlt)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHAT660
Realiza a gestao dos Contratos/SubContratos

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHAT660(nOpc,cChave,oBrwBT8,oBrwBT7)
Local aChave     := {}
Local aCamposAlt := {}
Local aCabBT8 := aClone(oBrwBT8:aHeader)
Local aDadBT8 := aClone(oBrwBT8:aCols)
Local aCabBT7 := aClone(oBrwBT7:aHeader)
Local aDadBT7 := aClone(oBrwBT7:aCols)
Local nX := 0

//BT8 - Empresa Cobertura
aChave     := {'BT8_CODPRO','BT8_VERPRO','BT8_CODPAD','BT8_CODPSA','BT8_NIVEL'}
aCamposAlt := {}
aMap := PLHATMap("BT8")
for nX := 1 to len(aMap)
	aadd(aCamposAlt,aMap[nX][2])
next
PLHATPedGD(nOpc,_coverageProcedureLevel_BT8_inc,_coverageProcedureLevel_BT8_alt,'BT8',aCabBT8,aDadBT8,1,aChave,cChave,aCamposAlt)

//BT7 - Empresa Grupo de Cobertura
aChave := {'BT7_CODPRO','BT7_VERPRO','BT7_CODGRU'}
aCamposAlt := {}
aMap := PLHATMap("BT7")
for nX := 1 to len(aMap)
	aadd(aCamposAlt,aMap[nX][2])
next
PLHATPedGD(nOpc,_coverageGroupLevel_BT7_inc,_coverageGroupLevel_BT7_alt,'BT7',aCabBT7,aDadBT7,1,aChave,cChave,aCamposAlt)

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PLHAT800
Realiza a gestao dos Produtos

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHAT800(nOpc,cChave,oBrwBB2,oBrwBRV)
Local aChave     := {}
Local aCamposAlt := {}
Local aCabBB2 := aClone(oBrwBB2:aHeader)
Local aDadBB2 := aClone(oBrwBB2:aCols)
Local aCabBRV := aClone(oBrwBRV:aHeader)
Local aDadBRV := aClone(oBrwBRV:aCols)
Local nX := 0

//BB2 - Procedimentos Produto
aChave     := {'BB2_CODPAD','BB2_CODPSA','BB2_NIVEL'}
aCamposAlt := {}
aMap := PLHATMap("BB2")
for nX := 1 to len(aMap)
	aadd(aCamposAlt,aMap[nX][2])
next
PLHATPedGD(nOpc,_coverageProcedureLevel_BB2_inc,_coverageProcedureLevel_BB2_alt,'BB2',aCabBB2,aDadBB2,1,aChave,cChave,aCamposAlt)

//BRV - Planos e Grupos de Cobertura
aChave     := {'BRV_CODGRU'}
aCamposAlt := {}
aMap := PLHATMap("BRV")
for nX := 1 to len(aMap)
	aadd(aCamposAlt,aMap[nX][2])
next
PLHATPedGD(nOpc,_coverageGroupLevel_BRV_inc,_coverageGroupLevel_BRV_alt,'BRV',aCabBRV,aDadBRV,1,aChave,cChave,aCamposAlt)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATBenef
Realiza a gestao do cadastro de beneficiarios/grupo de cobertura

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATBenef(nOpc,aHeaderBA1,aColsBA1,aCabBFE,aDadBFE,cCodPlaBA3,lAltBTS,aDadosBTS)
Local nX := 0
Local nY := 0
Local nPosBFE    := 0
Local nPos       := 0
Local aStrucBA1  := {}
Local aCampos    := {}
Local cMatricVid := ""
Local cValueBA1  := ""
Local cValueBTS  := ""
Local cBase      := ""
Local cAlt       := ""
Local aCampos    := {} 
Local aMap       := {}
Default lAltBTS   := .F.
Default cMatricVid := ""

aMap := PLHATMap("BA1")
for nX := 1 to len(aMap)
	aadd(aCampos,aMap[nX][2])
next

//Alteracao na vida BTS replica para o usuario BA1
if lAltBTS 
	BA1->(DbSetOrder(7))//BA1_FILIAL+BA1_MATVID
	nPos := Ascan(aDadosBTS,{|x|x[1] == "BA1_MATVID" })
	cMatricVid := aDadosBTS[nPos][2]
	 
	if BA1->(MsSeek(xFilial("BA1")+cMatricVid))
		while BA1->(BA1_FILIAL+BA1_MATVID) == xFilial("BA1")+cMatricVid .And. !BA1->(Eof()) 
			cCamposAlt := ""
			
			for nX := 1 to len(aDadosBTS)
				if Valtype(&("BA1->"+aDadosBTS[nX][1])) == "C"
					cValueBA1 := Alltrim(&("BA1->"+aDadosBTS[nX][1]))
					cValueBTS := Alltrim(aDadosBTS[nX][2])
					iif(cValueBA1 <> cValueBTS .Or. cValueBTS <> cValueBA1,cCamposAlt += ","+aDadosBTS[nX][1],cCamposAlt += "")	
				else
					iif(&("BA1->"+aDadosBTS[nX][1]) <> aDadosBTS[nX][2],cCamposAlt += ","+aDadosBTS[nX][1],cCamposAlt += "")
				endIf
			next
						
			if !Empty(cCamposAlt)
				PLHTGrvPed(_beneficiaries_inc ,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),cCamposAlt,"BA1")
			endIf	
			BA1->(DbSkip())
		endDo	          
	endIf	
	
	//Se for uma transacao prioritaria, ja realizo o envio
	VerifPrior(_beneficiaries_inc )

else
	      
	BA1->(DbSetOrder(2))//BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	BFE->(DbSetOrder(1))//BFE_FILIAL+BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG+BFE_CODGRU    
	BA3->(DbSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
	
	if nOpc == K_Incluir 
		for nX := 1 to len(aColsBA1)
			cChave     := Substr(aColsBA1[nX,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,14)+aColsBA1[nX,PLRETPOS("BA1_TIPREG",aHeaderBA1)]+aColsBA1[nX,PLRETPOS("BA1_DIGITO",aHeaderBA1)]//aColsBA1[nX,PLRETPOS("BA1_MATUSU",aHeaderBA1)]
			PLHTGrvPed(_beneficiaries_inc ,cChave,"","BA1")
		next	                     
		
	elseif nOpc == K_Alterar   
	
		//Percorre os beneficiarios
		for nX := 1 to len(aColsBA1)
		    
		    cCamposAlt := ""
			cChave     := Substr(aColsBA1[nX,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,14)+aColsBA1[nX,PLRETPOS("BA1_TIPREG",aHeaderBA1)]+aColsBA1[nX,PLRETPOS("BA1_DIGITO",aHeaderBA1)]
			
			//Verifica se o beneficiario esta deletado
			if aColsBA1[nX,len(aColsBA1[nX])]
				loop
			endIf

			//Envio do beneficiario completo - todo: Verificar ordem futura para enviar somente os dados alterados
			PLHTGrvPed(_beneficiaries_inc ,cChave,cCamposAlt,"BA1")
									 
			//Verifica se ele ja existe ou e uma nova inclusao
			/*if BA1->(MsSeek(xFilial("BA1")+aColsBA1[nX,PLRETPOS("BA1_MATUSU",aHeaderBA1)] ))
				
				//Verifica alteracoes no usuario
				for nY := 1 to len(aCampos)
					if PLRETPOS(aCampos[nY],aHeaderBA1) > 0 //Verifico se o campo existe no aCols 
						if Valtype(&('BA1->'+aCampos[nY])) == "C"
							cBase := Alltrim(&('BA1->'+aCampos[nY]) )
							cAlt  := Alltrim(aColsBA1[nX,PLRETPOS(aCampos[nY],aHeaderBA1)])
							if cBase <> cAlt .Or. cAlt <> cBase
								cCamposAlt += ","+aCampos[nY]
							endIf
						elseIf &('BA1->'+aCampos[nY]) <> aColsBA1[nX,PLRETPOS(aCampos[nY],aHeaderBA1)]
							cCamposAlt += ","+aCampos[nY]	
						endIf	
					endIf	
				next

				//Codigo/Versao do Plano faco verificacao separada pois pode estar em BA1 ou BA3
				if BA3->(MsSeek(xFilial("BA3")+Substr(aColsBA1[nX,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,14)))
					if BA1->BA1_CODPLA <> aColsBA1[nX,PLRETPOS("BA1_CODPLA",aHeaderBA1)] 
						if Empty(aColsBA1[nX,PLRETPOS("BA1_CODPLA",aHeaderBA1)] )//Se limpei o BA1_CODPLA, passo a enviar o BA3_CODPLA
							cCamposAlt += ',BA3_CODPLA,BA3_VERSAO'
						else
							cCamposAlt += ',BA1_CODPLA,BA1_VERSAO'
						endIf	
					elseif Empty(BA1->BA1_CODPLA) .And. cCodPlaBA3 <> BA3->BA3_CODPLA 
	                	cCamposAlt += ',BA3_CODPLA,BA3_VERSAO'
					endIf                  
				endIf
				    
		        //Dados do beneficiario
				if !Empty(cCamposAlt)
					PLHTGrvPed(_beneficiaries_inc ,cChave,cCamposAlt,"BA1")
				endIf	
			
			//E um novo beneficiario, envio o cadastro completo
			else
	        	PLHTGrvPed(_beneficiaries_inc ,cChave,cCamposAlt,"BA1")
			endIf 
			*/
	    next
	    
	    //Percorre os grupos de cobertura
	    for nX := 1 to len(aDadBFE)
			if (nPosBFE := Ascan(aColsBA1,{|x|x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aDadBFE[nX,PLRETPOS("BFE_TIPREG",aCabBFE)] }) ) > 0 .And. !Empty(aDadBFE[nX,PLRETPOS("BFE_CODGRU",aCabBFE)])
	
				cChave := Substr(aColsBA1[nPosBFE,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,16)+aDadBFE[nX,PLRETPOS("BFE_CODGRU",aCabBFE)]
				cCamposAlt := ""
				
				//Verifica se o beneficiario esta deletado
				if (nPos := Ascan(aColsBA1,{|x| x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aDadBFE[nX][PLRETPOS("BFE_TIPREG",aCabBFE)] }) ) > 0 .And. aColsBA1[nPos,len(aColsBA1[nPos])] 
					loop
				endIf
				
				//Verifica se o grupo esta deletado 
				if aDadBFE[nX][len(aDadBFE[nX])]
					loop
				endIf
				
	    		//Verifica se ja existe o registro na BFE
	    		if BFE->(MsSeek(xFilial("BFE")+aColsBA1[nPosBFE,PLRETPOS("BA1_MATUSU",aHeaderBA1)]+aDadBFE[nX,PLRETPOS("BFE_CODGRU",aCabBFE)]))
	    			Iif(BFE->BFE_DATCAR <> aDadBFE[nX,PLRETPOS("BFE_DATCAR",aCabBFE)],cCamposAlt += ',BFE_DATCAR',nil) //dataCarenciaInicio 
	    			
	    			//Dados do grupo de cobertura
					if !Empty(cCamposAlt)
						PLHTGrvPed(_beneficiaries_inc ,cChave,cCamposAlt,"BFE")
					endIf
				
	    		//Novo registro, devo adiciona-lo ao pedido
	    		else
	    			PLHTGrvPed(_beneficiaries_inc ,cChave,cCamposAlt,"BFE")
	    		endIf
	    	endIf
	    Next
	endIf
	
	//Se for uma transacao prioritaria, ja realizo o envio
	VerifPrior(_beneficiaries_inc)
	
endIf

Return                                                                                                


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTGrvPed
Funcao padrao para a gravacao fisica de um Pedido

@author  Renan Sakai
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHTGrvPed(cCodTra,cChave,cCamposAlt,cAlias,nRecno)
Local aCampos  := {}
Local lFindBNV := .F.
Default cChave     := ""
Default cCamposAlt := ""
Default cAlias     := ""
Default nRecno     := 0

//Funcao para gravar os dados obrigatorios de chave de cada item baseado no seu alias (caso possua algum valor nos campos alterados)
/*if !empty(cCamposAlt) 
	cCamposAlt := AddPKFields(cCamposAlt, cAlias) 
endif*/

if PLHTACTRA(cCodtra)

	BNV->(DbSetOrder(2)) //BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
	if BNV->(MsSeek(xFilial("BNV")+cCodTra+cAlias+cChave))
		while Alltrim(BNV->(BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE)) == Alltrim(xFilial("BNV")+cCodTra+cAlias+cChave) .And. !BNV->(Eof())
			if BNV->BNV_STATUS == "0"
				lFindBNV := .T.
				Exit
			endIf
			BNV->(DbSkip())	
		endDo
	endIf

	// Importante: esta tratativa de nao gerar pedido repetido com BNV_STATUS = 0
	// deve ser removida se implementado ajuste para gravar o campo BNV_CAMPOS
	if !lFindBNV
		//Monto o array para registrar o pedido
		aadd( aCampos,{ "BNV_FILIAL", xFilial("BNV") })
		aadd( aCampos,{ "BNV_CODIGO", GetSXENum( "BNV","BNV_CODIGO" ) })
		aadd( aCampos,{ "BNV_CODTRA", cCodtra })
		aadd( aCampos,{ "BNV_CHAVE" , cChave })
		aadd( aCampos,{ "BNV_CAMPOS", "" }) //Mandar sempre todos os campos para o HAT, posteriormente iremos checar os campos alterados
		aadd( aCampos,{ "BNV_STATUS", "0" })
		aadd( aCampos,{ "BNV_ALIAS" , cAlias })    
		aadd( aCampos,{ "BNV_DATCRI", Date() })
		aadd( aCampos,{ "BNV_HORCRI", Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2) })
		aadd( aCampos,{ "BNV_IDINT" , nRecno })
		BNV->(ConfirmSX8())

		PLS274GRV( K_Incluir, aCampos )
	endIf
endIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATPreDi
Realiza a gestao do cadastro de doencas pre-existentes

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATPreDi(nOpc,aHeaderBA1,aColsBA1,aCabBF3,aDadBF3)  
Local nX := 0
Local nY := 0
Local nPosBF3    := 0
Local nPos       := 0
Local aStrucBA1  := {}
Local aCampos    := {}
Local aMap       := PLHATMap("BF3")

for nX := 1 to len(aMap)
	aadd(aCampos,aMap[nX][2])
next

if nOpc == K_Incluir
	for nX := 1 to len(aDadBF3)
		if (nPosBF3 := Ascan(aColsBA1,{|x|x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aDadBF3[nX,PLRETPOS("BF3_TIPREG",aCabBF3)] }) ) > 0 .And. ;
					  !Empty(aDadBF3[nX,PLRETPOS("BF3_CODDOE",aCabBF3)])

			cChave := Substr(aColsBA1[nPosBF3,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,16)+aDadBF3[nX,PLRETPOS("BF3_CODDOE",aCabBF3)]
					
			//Verifica se o beneficiario esta deletado
			if (nPos := Ascan(aColsBA1,{|x| x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aDadBF3[nX][PLRETPOS("BF3_TIPREG",aCabBF3)] }) ) > 0 .And. aColsBA1[nPos,len(aColsBA1[nPos])]
				loop
			endIf
			
			//Verifica se o grupo esta deletado
			if aDadBF3[nX][len(aDadBF3[nX])]
				loop
			endIf

			PLHTGrvPed(_preExistingDiseases_inc,cChave,"","BF3")
		endIf
	next	

elseIf nOpc == K_Alterar	
	
	//Percorre os grupos de cobertura
	for nX := 1 to len(aDadBF3)
		if (nPosBF3 := Ascan(aColsBA1,{|x|x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aDadBF3[nX,PLRETPOS("BF3_TIPREG",aCabBF3)] }) ) > 0 .And. !Empty(aDadBF3[nX,PLRETPOS("BF3_CODDOE",aCabBF3)])
			
			cChave := Substr(aColsBA1[nPosBF3,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,16)+aDadBF3[nX,PLRETPOS("BF3_CODDOE",aCabBF3)]
			cCamposAlt := ""
			
			//Verifica se o beneficiario esta deletado
			if (nPos := Ascan(aColsBA1,{|x| x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aDadBF3[nX][PLRETPOS("BF3_TIPREG",aCabBF3)] }) ) > 0 .And. aColsBA1[nPos,len(aColsBA1[nPos])]
				loop
			endIf
			
			//Verifica se o grupo esta deletado
			if aDadBF3[nX][len(aDadBF3[nX])]
				loop
			endIf
			
			//Verifica se ja existe o registro na BF3
			if BF3->(MsSeek(xFilial("BF3")+aColsBA1[nPosBF3,PLRETPOS("BA1_MATUSU",aHeaderBA1)]+aDadBF3[nX,PLRETPOS("BF3_CODDOE",aCabBF3)]))
			
				for nY := 1 to len(aCampos)
					if PLRETPOS(aCampos[nY],aCabBF3) > 0 //Verifico se o campo existe no aCols 
						if Valtype(&('BF3->'+aCampos[nY])) == "C"
							cBase := Alltrim(&('BF3->'+aCampos[nY]) )
							cAlt  := Alltrim(aDadBF3[nX,PLRETPOS(aCampos[nY],aCabBF3)])
							if cBase <> cAlt .Or. cAlt <> cBase
								cCamposAlt += ","+aCampos[nY]
							endIf
						elseIf &('BF3->'+aCampos[nY]) <> aDadBF3[nX,PLRETPOS(aCampos[nY],aCabBF3)]
							cCamposAlt += ","+aCampos[nY]	
						endIf	
					endIf	
				next

				//Dados do grupo de cobertura
				if !Empty(cCamposAlt)
					PLHTGrvPed(_preExistingDiseases_alt,cChave,cCamposAlt,"BF3")
				endIf
				
				//Novo registro, devo adiciona-lo ao pedido
			else
				PLHTGrvPed(_preExistingDiseases_inc,cChave,cCamposAlt,"BF3")
			endIf
		endIf
	Next
endIf

//Se for uma transacao prioritaria, ja realizo o envio
VerifPrior(_preExistingDiseases_inc)

Return   


//-------------------------------------------------------------------
/*/{Protheus.doc} VerifPrior
Verfica se uma acao e prioritaria e ja realiza o envio

@author  Renan Sakai 
@version P12
@since    16.10.18
/*/
//-------------------------------------------------------------------
Static Function VerifPrior(cCodtra)

BNN->(DbSetOrder(1))//BNN_FILIAL+BNN_CODTRA
if BNN->(MsSeek(xFilial("BNN")+cCodtra)) .And. BNN->BNN_PRIORI == "1"
	StartJob("PLHATPrior",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cCodtra)
endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLHATadBFG
Realiza a gestao do cadastro de procedimentos dos usuarios

@author  Renan Sakai 
@version P12
@since    06.09.18
/*/
//-------------------------------------------------------------------
Function PLHATadBFG(nOpc,aHeaderBA1,aColsBA1,aHeaderBFG,aColsBFG)
Local nX := 0
Local nY := 0
Local nPosBFG    := 0
Local nPos       := 0
Local aStrucBA1  := {}
Local aMap       := PLHATMap("BFG")
Local aCampos    := {}

	for nX := 1 to len(aMap)
		aadd(aCampos,aMap[nX][2])
	next

	if nOpc == K_Incluir

		for nX := 1 to len(aColsBFG)
			if (nPosBFG := Ascan(aColsBA1,{|x|x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aColsBFG[nX,PLRETPOS("BFG_TIPREG",aHeaderBFG)] }) ) > 0 .And. ;
						!Empty(aDadBFG[nX,PLRETPOS("BFG_CODPAD",aCabBFG)]) .And. !Empty(aDadBFG[nX,PLRETPOS("BFG_CODPSA",aCabBFG)])	   

				cChave := Substr(aColsBA1[nPosBFG,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,16)+aColsBFG[nX,PLRETPOS("BFG_CODPAD",aHeaderBFG)]+;
								aColsBFG[nX,PLRETPOS("BFG_CODPSA",aHeaderBFG)]+aColsBFG[nX,PLRETPOS("BFG_NIVEL",aHeaderBFG)]

				//Verifica se o beneficiario esta deletado
				if (nPos := Ascan(aColsBA1,{|x| x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aColsBFG[nX][PLRETPOS("BFG_TIPREG",aHeaderBFG)] }) ) > 0 .And. aColsBA1[nPos,len(aColsBA1[nPos])]
					loop 
				endIf
				
				//Verifica se o grupo esta deletado
				if aColsBFG[nX][len(aColsBFG[nX])]
					loop
				endIf

				PLHTGrvPed(_coverageProcedureLevel_BFG_inc,cChave,"","BFG")
			endIf	
		next

	elseIf nOpc == K_Alterar	
		
		//Percorre os procedimentos
		for nX := 1 to len(aColsBFG)
			if (nPosBFG := Ascan(aColsBA1,{|x|x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aColsBFG[nX,PLRETPOS("BFG_TIPREG",aHeaderBFG)] }) ) > 0 .And. ;
						!Empty(aDadBFG[nX,PLRETPOS("BFG_CODPAD",aCabBFG)]) .And. !Empty(aDadBFG[nX,PLRETPOS("BFG_CODPSA",aCabBFG)])	            
				
				cChave := Substr(aColsBA1[nPosBFG,PLRETPOS("BA1_MATUSU",aHeaderBA1)],1,16)+aColsBFG[nX,PLRETPOS("BFG_CODPAD",aHeaderBFG)]+;
								aColsBFG[nX,PLRETPOS("BFG_CODPSA",aHeaderBFG)]+aColsBFG[nX,PLRETPOS("BFG_NIVEL",aHeaderBFG)]

				cCamposAlt := ""
				
				//Verifica se o beneficiario esta deletado
				if (nPos := Ascan(aColsBA1,{|x| x[PLRETPOS("BA1_TIPREG",aHeaderBA1)] == aColsBFG[nX][PLRETPOS("BFG_TIPREG",aHeaderBFG)] }) ) > 0 .And. aColsBA1[nPos,len(aColsBA1[nPos])]
					loop
				endIf
				
				//Verifica se o grupo esta deletado
				if aColsBFG[nX][len(aColsBFG[nX])]
					loop
				endIf
				
				//Verifica se ja existe o registro na BFG
				if BFG->(MsSeek(xFilial("BFG")+aColsBA1[nPosBFG,PLRETPOS("BA1_MATUSU",aHeaderBA1)]+aColsBFG[nX,PLRETPOS("BFG_CODPAD",aHeaderBFG)]+;
											aColsBFG[nX,PLRETPOS("BFG_CODPSA",aHeaderBFG)]+aColsBFG[nX,PLRETPOS("BFG_NIVEL",aHeaderBFG)]                                          ))
					for nY := 1 to len(aCampos)
						if PLRETPOS(aCampos[nY],aHeaderBFG) > 0 //Verifico se o campo existe no aCols 
							if Valtype(&('BFG->'+aCampos[nY])) == "C"
								cBase := Alltrim(&('BFG->'+aCampos[nY]) )
								cAlt  := Alltrim(aColsBFG[nX,PLRETPOS(aCampos[nY],aHeaderBFG)])
								if cBase <> cAlt .Or. cAlt <> cBase
									cCamposAlt += ","+aCampos[nY]
								endIf
							elseIf &('BFG->'+aCampos[nY]) <> aColsBFG[nX,PLRETPOS(aCampos[nY],aHeaderBFG)]
								cCamposAlt += ","+aCampos[nY]	
							endIf	
						endIf	
					next

					//Dados dos procedimentos
					if !Empty(cCamposAlt)
						PLHTGrvPed(_coverageProcedureLevel_BFG_alt,cChave,cCamposAlt,"BFG")
					endIf
					
					//Novo registro, devo adiciona-lo ao pedido
				else
					PLHTGrvPed(_coverageProcedureLevel_BFG_inc,cChave,cCamposAlt,"BFG")
				endIf
			endIf
		Next
	endIf

	//Se for uma transacao prioritaria, ja realizo o envio
	VerifPrior(_coverageProcedureLevel_BFG_inc)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddPKFields
Funcao responsavel para adicionar os campos obrigatorios à estrutura de envio da integração
@author  Rodrigo Morgon
@since   2018-11-14
/*/
//-------------------------------------------------------------------
Static Function AddPKFields(cCamposAlt, cAlias)

	Local aCamposAlt := {}
	Local aObrigAlias := {}
	Local nI := 1

	Default cCamposAlt := ''
	Default cAlias := ''

	if !empty(cCamposAlt) .and. !empty(cAlias)

		aCamposAlt := StrTokArr(Alltrim(cCamposAlt),",")

		do case
			case cAlias == "BA1" //Beneficiario
				aObrigAlias := { "BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO" }

			case cAlias == "BTS" //Vidas
				aObrigAlias := { "BTS_MATVID" }

			case cAlias == "BAU" //Prestadores
				aObrigAlias := { "BAU_CODIGO", "BAU_CPFCGC" }
		endcase

		//Pesquisa nos campos alterados se ja existe o elemento obrigatorio
		for nI := 1 to len(aObrigAlias)

			if aScan(aCamposAlt, aObrigAlias[nI]) == 0
				cCamposAlt += "," + aObrigAlias[nI]
			endif
		next nI
	endif

Return cCamposAlt
//

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTACTRA
description Verifica se a transação está ativa
@author  karine.limp
@since   2020-12-01
@version 1.0
/*/
//-------------------------------------------------------------------
function PLHTACTRA(cCodtra)
	local aActiveTransactions := PLHTRACT()
return aScan(aActiveTransactions, cCodTra) > 0

//-------------------------------------------------------------------
/*/{Protheus.doc} PLHTRACT
description Retorna as transações ativas
@author  karine.limp
@since   2020-12-01
@version 1.0
/*/
//-------------------------------------------------------------------
function PLHTRACT()
	local aActiveTransactions := {}
	local cIniFile := PLSMUDSIS("\plshat.ini")
	local aActiveIni := StrTokArr2(GetPvProfString( "CONFIG", "activeIntegration" , "", cIniFile ), ",")
	local nInt := 1

    // * Considero todas as transações ativas caso não tenha a config no INI
    if empty(aActiveIni)
        aActiveTransactions := {;
            _beneficiaries_inc,;
            _beneficiaries_alt,;
            _healthProviders_inc,;
            _healthProviders_alt,;
            _clinicalStaff_BC1_inc,;
            _clinicalStaff_BC1_alt,;
            _persons_inc,;
            _persons_alt,;
            _preExistingDiseases_inc,;
            _preExistingDiseases_alt,;
            _beneficiaryStatus_blo,;
            _beneficiaryStatus_desblo,;
            _healthProviderStatus_blo,;
            _healthProviderStatus_desblo,;
            _attendanceLocations_inc,;
            _attendanceLocations_alt,;
            _healthProviderSpecialties_inc,;
            _healthProviderSpecialties_alt,;
            _coverageProcedureLevel_BFG_inc,;
            _coverageProcedureLevel_BFG_alt,;
            _coverageProcedureLevel_BFD_inc,;
            _coverageProcedureLevel_BFD_alt,;
            _coverageGroupLevel_BFC_inc,;
            _coverageGroupLevel_BFC_alt,;
            _coverageProcedureLevel_BT8_inc,;
            _coverageProcedureLevel_BT8_alt,;
            _coverageGroupLevel_BT7_inc,;
            _coverageGroupLevel_BT7_alt,;
            _coverageProcedureLevel_BB2_inc,;
            _coverageProcedureLevel_BB2_alt,;
            _coverageGroupLevel_BRV_inc,;
            _coverageGroupLevel_BRV_alt,;
            _billing_BCI_alt,;
            _coverageGroupLevel_BG8_inc,;
            _coverageGroupLevel_BG8_alt,;
            _cancel_BEA_atu,;
			_glossProtocol_B4D_alt }
    else

        for nInt := 1 to len(aActiveIni)
            do case
                case aActiveIni[nInt] == "beneficiaries"
                    aAdd(aActiveTransactions, _beneficiaries_inc)
                    aAdd(aActiveTransactions, _beneficiaries_alt)
                case aActiveIni[nInt] == "healthProviders"
                    aAdd(aActiveTransactions, _healthProviders_inc)
                    aAdd(aActiveTransactions, _healthProviders_alt)
                case aActiveIni[nInt] == "clinicalStaff"
                    aAdd(aActiveTransactions, _clinicalStaff_BC1_inc)
                    aAdd(aActiveTransactions, _clinicalStaff_BC1_alt)
                case aActiveIni[nInt] == "persons"
                    aAdd(aActiveTransactions, _persons_inc)
                    aAdd(aActiveTransactions, _persons_alt)
                case aActiveIni[nInt] == "preExistingDiseases"
                    aAdd(aActiveTransactions, _preExistingDiseases_inc)
                    aAdd(aActiveTransactions, _preExistingDiseases_alt)
                case aActiveIni[nInt] == "beneficiaryStatus"
                    aAdd(aActiveTransactions, _beneficiaryStatus_blo)
                    aAdd(aActiveTransactions, _beneficiaryStatus_desblo)
                case aActiveIni[nInt] == "healthProviderStatus"
                    aAdd(aActiveTransactions, _healthProviderStatus_blo)
                    aAdd(aActiveTransactions, _healthProviderStatus_desblo)
                case aActiveIni[nInt] == "attendanceLocations"
                    aAdd(aActiveTransactions, _attendanceLocations_inc)
                    aAdd(aActiveTransactions, _attendanceLocations_alt)
                case aActiveIni[nInt] == "healthProviderSpecialties"
                    aAdd(aActiveTransactions, _healthProviderSpecialties_inc)
                    aAdd(aActiveTransactions, _healthProviderSpecialties_alt)
                case aActiveIni[nInt] == "coverageProcedureLevel_BFG"
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BFG_inc)
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BFG_alt)
                case aActiveIni[nInt] == "coverageProcedureLevel_BFD"
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BFD_inc)
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BFD_alt)
                case aActiveIni[nInt] == "coverageGroupLevel_BFC"
                    aAdd(aActiveTransactions, _coverageGroupLevel_BFC_inc)
                    aAdd(aActiveTransactions, _coverageGroupLevel_BFC_alt)
                case aActiveIni[nInt] == "coverageProcedureLevel_BT8"
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BT8_inc)
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BT8_alt)
                case aActiveIni[nInt] == "coverageGroupLevel_BT7"
                    aAdd(aActiveTransactions, _coverageGroupLevel_BT7_inc)
                    aAdd(aActiveTransactions, _coverageGroupLevel_BT7_alt)
                case aActiveIni[nInt] == "coverageProcedureLevel_BB2"
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BB2_inc)
                    aAdd(aActiveTransactions, _coverageProcedureLevel_BB2_alt)
                case aActiveIni[nInt] == "coverageGroupLevel_BRV"
                    aAdd(aActiveTransactions, _coverageGroupLevel_BRV_inc)
                    aAdd(aActiveTransactions, _coverageGroupLevel_BRV_alt)
                case aActiveIni[nInt] == "billing_BCI"
                    aAdd(aActiveTransactions, _billing_BCI_alt)
                case aActiveIni[nInt] == "coverageGroupLevel_BG8"
                    aAdd(aActiveTransactions, _coverageGroupLevel_BG8_inc)
                    aAdd(aActiveTransactions, _coverageGroupLevel_BG8_alt)
                case aActiveIni[nInt] == "cancel_BEA"
                    aAdd(aActiveTransactions, _cancel_BEA_atu)
				case aActiveIni[nInt] == "_glossProtocol_B4D_alt"
                    aAdd(aActiveTransactions, _glossProtocol_B4D_alt)	
            endCase
        next nInt

    endIf
return aActiveTransactions
