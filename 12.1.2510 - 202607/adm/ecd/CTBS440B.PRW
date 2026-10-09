#include 'protheus.ch'

//amarracao por falha na geracao do ptm
//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CS440ManJob

Função responsável pela funcionalidade multi-thread para compor os saldo do bloco k300 das n empresas
do conglomerado.

Vale ressaltar que a composição do saldo é efetuada através da funcionalidade CtGerPlan(..). Para cada empresa 
a ser processada, uma thread será aberta para processar em paralelo.

@params:
    oModelA:	Objeto. Instância da classe FwFormModel(). Modelo CTBS440A
	cIDBlK:		Caractere. Código do bloco K
	cCodCta:	Caractere. Código da conta contábil que será processada para carregar o saldo dentro do período
	cMoeda:		Caractere. Código da moeda contábil.
	cTpSald:	Caractere. Código do tipo de saldo
	dDataLP:	Data. Data de Lucros e Perdas
	dDataIni:	Data. Data inicial do período de apuração do saldo da conta contábil
	dDataFim:	Data. Data final do período de apuração do saldo da conta contábil
	lImpAntLP:	Lóigico. .t. efetua análise de lucros e perdas para a composição do saldo da conta contábil
	   
@return: 
	nSaldo:		Numérico. Saldo retornado pela CtGerPlan(..) das n Contas Contábeis por empresa do conglomerado (bloco K210)
@sample:
	nSaldo := CS440ManJob(oModelA,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)
@author Fernando Radu Muscalu

@since 13/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CS440ManJob(oModelA,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)

Local nX        := 0
Local nP        := 0
Local nSaldo    := 0
Local nSldGrp   := 0

Local cEmpBkp   := ""
Local cFilLanc  := ""
Local cError    := ""

Local aEmpresas := {}
Local aContas   := {}

Local oModelCQU
Local oModelCQV

/*
	MAPA de aEmpresas

		aEmpresas:	Array. Contem os dados das empresas que serão processadas
			aEmpresas[n,1]:	Caractere. Código da Empresa
			aEmpresas[n,2]: Array. Dados da filial e contas contábeis pertecente a empresa do elemento [1] deste array
				aEmpresas[n,2,x,1]: 	Caractere. Filial da conta contábil	
				aEmpresas[n,2,x,2]: 	Caractere. Código da conta contábil	

	MAPA de aContas
		aContas: Array. POssui dados de filial e código de conta
			aContas[n,1]: 	Caractere. Filial da conta contábil	
			aContas[n,2]: 	Caractere. Código da conta contábil	

*/
If ( oModelA:IsActive() )
    
    oModelCQU 	:= oModelA:GetModel("CQUMASTER")
    oModelCQV 	:= oModelA:GetModel("CQVDETAIL")
    cEmpBkp		:= cEmpAnt
    
    //Possui empresas para carregar saldo ? (bloco K210) 
	If ( oModelCQV:Length() > 1 .Or. !Empty(oModelCQV:GetValue("CQV_IDBLK",1)) )
   
	   //Efetua a separação das empresas e contas das demais empresas do conglomerado (bloco K210) 
	    For nX := 1 to oModelCQV:Length()
	        
	        nP := aScan(aEmpresas, {|x| Alltrim(Upper(x[1])) == Alltrim(Upper(oModelCQV:GetValue("CQV_XGRP",nX)))})
	
	        If ( nP == 0 )
	            aAdd(aEmpresas,{oModelCQV:GetValue("CQV_XGRP",nX),aClone(aContas)})
	            nP := Len(aEmpresas)
	            aContas := {}
	        EndIf
	        
	        cFilLanc := oModelCQV:GetValue("CQV_XEMP",nX) + oModelCQV:GetValue("CQV_XUNEG",nX) + oModelCQV:GetValue("CQV_XFIL",nX)
	
	        //Para não usar a mesma conta para a mesma empresa do bloco k200 (Código do Grupo de empresas e filial tem de ser diferente se a conta é a mesma)
	        if aScan(aContas,{|x,y| x[1] == cFilLanc }) == 0 .Or. oModelCQV:GetValue("CQV_CTAEMP",nX) <> oModelCQU:GetValue("CQU_CODCTA")
				aAdd(aContas,{cFilLanc, oModelCQV:GetValue("CQV_CTAEMP",nX)})
			endIf
	
	        If ( nP > 0 )
	           aEmpresas[nP,2] := aClone(aContas)
	        EndIf
	
	        cEmpBkp := oModelCQV:GetValue("CQV_XGRP",nX)
	
	    Next nX
	
    EndIf

	//efetua o processamento dos saldos de cada conta de cada empresa
	If ( Len(aEmpresas) > 0 )
		//RETIRADO TRATAMENTO MULTITHREAD POIS INICIALIZACAO AMBIENTE MUITO LENTO
		VarSetUID("CTBS440B_VAR", .T.)

		For nX := 1 to Len(aEmpresas)
			//Chamando diretamente a funcao que era anteriormente chamado por job em multithread
			//Retirado a instrução de chamar por job pois apresentou se muito lento a inicializacao de ambiente
			CT440BJob(aEmpresas[nX,1],aEmpresas[nX,2],cIDBlK,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP) 
		Next nX
						
		If !Empty(cError) //tratava quando era por multithread e uma das threads caiu por erro
			CS440AddLog(oModelCQU:GetValue("CQU_CODCTA"), Alltrim(cError) )
		Else
			//Recupera-se os saldos das empresas do bloco k210 que foram alocadas em variáveis globais	
			For nX := 1 to Len(aEmpresas)
				
				If ( VarGetX( "CTBS440B_VAR","SLD_GERPLAN"+aEmpresas[nX,1], @nSldGrp ) )				
					nSaldo += nSldGrp				
				Endif
		
			Next nX    
			
		Endif 

		//limpa o espaço alocado para as variáveis globais do processamento multi-thread
		VarClean("CTBS440B_VAR")

	EndIf
    
EndIf

Return(nSaldo)


//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} CT440BJob

Função responsável pela execução na thread aberta, do processamento da CtGerPlan(..).

@params:
    cEmp:		Caractere. Código da empresa que será montado o ambiente para a exeução da thread
	aCtaEmp:	Array. Matriz com os dados de filial e conta.
		aCtaEmp[n,1]: Caractere: código da filial
		aCtaEnp[n,2]: Caractere: código da conta contábil
	cIDBlK:		Caractere. Código do bloco K
	cCodCta:	Caractere. Código da conta contábil que será processada para carregar o saldo dentro do período
	cMoeda:		Caractere. Código da moeda contábil.
	cTpSald:	Caractere. Código do tipo de saldo
	dDataLP:	Data. Data de Lucros e Perdas
	dDataIni:	Data. Data inicial do período de apuração do saldo da conta contábil
	dDataFim:	Data. Data final do período de apuração do saldo da conta contábil
	lImpAntLP:	Lóigico. .t. efetua análise de lucros e perdas para a composição do saldo da conta contábil
	   
@return: 
	nSaldo:		Numérico. Saldo retornado pela CtGerPlan(..) das n Contas Contábeis por empresa do conglomerado (bloco K210)
@sample:
	nSaldo := CS440ManJob(oModelA,cIDBlK,cCodCta,cMoeda,cTpSald,dDataLP,dDataIni,dDataFim,lImpAntLP)
@author Fernando Radu Muscalu

@since 13/03/2019
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function CT440BJob(cEmp As Character,aCtaEmp As Array,cIDBlK As Character,cMoeda As Character,;
					cTpSald As Character,dDataLP As Date,dDataIni As Date,dDataFim As Date,lImpAntLP As Logical)

Local cFilBkp   	As Character
Local nSaldo    	As Numeric
Local nSldGrp   	As Numeric
Local nI        	As Numeric
Local aTables 		As Array
Local nPosTbName	As Numeric
Local aFilComp		As Array
Local aRet			As Array

cFilBkp  	:= ""
nSaldo   	:= 0
nSldGrp   	:= 0
nI        	:= 0
aTables 	:= {"CT1", "CQ1"}
nPosTbName 	:= 0
aFilComp	:= {}
aRet		:= {}

If ( Len(aCtaEmp) > 0 )

	//Trecho para armazenar o RetSqlName dos grupos de empresa pra usar na query que busca os saldos
	nPosTbName := Ascan(aNameTable,{|x| x[1] == cEmp}) // o aNameTable é privado e criado nas funções CTBS440Inc() ou C440Saldo()
	If nPosTbName == 0

		If cEmpAnt <> cEmp
			aRet := StartJob("CtRetSqlNm",GetEnvServer(),.T.,cEmp, aCtaEmp[1,1], aTables)
		Else
			aRet := {RetSQLName("CT1"), RetSQLName("CQ1")}
		EndIf	

		If ( Len(aRet) > 0 )
			aadd(aNameTable, {cEmp, aClone(aRet)})
			nPosTbName := Ascan(aNameTable,{|x| x[1] == cEmp})//Caso inclua, recupera a posição de inclusão
		EndIf

	EndIf
        
    For nI := 1 to Len(aCtaEmp)

		//Pego o conteúdo da filial das tabelas que usarei conforme o compartilhamento
		If cFilBkp <> aCtaEmp[nI,1]
			aadd(aFilComp, CtPesqComp(cEmp, aCtaEmp[nI,1], "CT1"))
			aadd(aFilComp, CtPesqComp(cEmp, aCtaEmp[nI,1], "CQ1"))
			cFilBkp := aCtaEmp[nI,1]
		EndIf

        nSldGrp += CTBS440Sld(cIDBlK,aCtaEmp[nI,2],cMoeda,cTpSald,dDataLP,nil,.f.,dDataIni,dDataFim,lImpAntLP, aNameTable[nPosTbName][2], aFilComp)

		aFilComp := {}//Restauro o array pra ser usado em outras filiais

    Next nI
	
	//Prepara a variável global para transação que a atualizará de acordo com o saldo retornado pela função CTBS440Sld(..)
    If ( VarBeginT("CTBS440B_VAR","SLD_GERPLAN"+cEmp) )

        //Capta valor atualizado da variável global SLD_GERPLAN+[Codigo EMpresa]
        VarGetXD("CTBS440B_VAR","SLD_GERPLAN"+cEmp, @nSaldo )

		nSaldo += nSldGrp

		//Atualiza a variável global com o valor atulizado do saldo
        VarSetXD("CTBS440B_VAR","SLD_GERPLAN"+cEmp, @nSaldo )

		//Finaliza a transação
        VarEndT("CTBS440B_VAR","SLD_GERPLAN"+cEmp)

    EndIf 

EndIf    

Return()

//------------------------------------------------------
/*/{Protheus.doc} CtRetSqlNm
Retorna via StartJob o nome real das tabelas solicitadas

@author pierre.nascimento
@since 18/03/2026
@version P12.1.2510

@return array
/*/
//-------------------------------------------------------
Function CtRetSqlNm(cEmp As Character, cFil As Character, aTables As Array) As Array

Local aRet As Array
Local nX   As Numeric

Default aTables := {}
Default cEmp 	:= ""
Default cFil 	:= ""
 
aRet := {}
nX   := 0

If Len(aTables) > 0
	RpcSetType(3)
	RpcSetEnv( cEmp, cFil )

	For nX := 1 to Len(aTables)
		aadd(aRet, RetSqlName(aTables[nX]))
	Next
	
	RpcClearEnv()
EndIf

Return aRet

//------------------------------------------------------------
/*/{Protheus.doc} CtPesqComp
Retorna a informação da filial com a regra de compartilhamento
aplicada para a empresa e filial informada

@author pierre.nascimento
@since 18/03/2026
@version P12.1.2510

@return array
/*/
//-------------------------------------------------------------
Function CtPesqComp(cEmp As Character, cFil As Character, cTable As Character) As Character

Local cRet      As Character
Local nTamSX2   As Numeric
Local nTamTotal As Numeric
Local nTamFil   As Numeric
Local nTamUn    As Numeric
Local nTamEmp   As Numeric

Default cEmp 	:= ""
Default cFil 	:= ""
Default cTable 	:= ""

cRet     	:= ""
nTamSX2  	:= 0
nTamTotal	:= 0
nTamFil		:= 0
nTamUn 		:= 0
nTamEmp		:= 0

If !Empty(cEmp) .And. !Empty(cFil) .And. !Empty(cTable)

	nTamEmp := Len(FWSM0Layout(cEmp, 1))
	nTamUn  := Len(FWSM0Layout(cEmp, 2))
	nTamFil := Len(FWSM0Layout(cEmp, 3))

	nTamSX2 := IIf(FWModeAccess(cTable, 01, cEmp) == "E", nTamEmp, 0)
	nTamSX2 += IIf(FWModeAccess(cTable, 02, cEmp) == "E", nTamUn , 0)
	nTamSX2 += IIf(FWModeAccess(cTable, 03, cEmp) == "E", nTamFil, 0)

	nTamTotal := nTamEmp + nTamUn + nTamFil

	cRet := PadR(SUBSTR(cFil,1,nTamSX2),nTamTotal) //PADR para adicionar os espaços em branco no final e não quebrar em Oracle
EndIf

Return cRet
