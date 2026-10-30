#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
 
//-------------------------------------------------------------------
/*/{Protheus.doc} STFExecOn
Classe de controle de execução online
@param   	
@author  Varejo
@version P12
@since   30/05/2018
@return  Self  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Class STFExecOn

	Data nStatusCode
	Data cStatusDescription
	Data uResult
	Data oStatusError
	
	Method New()//Construtor

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} STFExecOn
Metodo construtor
@param   	
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Self 
@obs     
@sample
/*/ 
//-------------------------------------------------------------------
Method New() Class STFExecOn

	Self:nStatusCode := 0
	Self:cStatusDescription := ""
	Self:uResult := Nil
	Self:oStatusError := Nil

Return Self
//-------------------------------------------------------------------
/*/{Protheus.doc} STFExecOn
Faz execução da rotina na própria base(Local/Online) póis no PDV Online
não depende da FWCallFunctionality(cProcess, aParams)

@type function
@param   lValue
@author  rafael.pessoa
@version P12
@since   02/03/2018
@return  lIsPOS - Retorna se é PDV
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFExecOn(cProcess, aParams,cEmpresa,cFilExec,lTestAuto)

Local nI 		:= 0
Local bBloco 	:= { || }
Local cParams	:= ""
Local aErroAuto := {}
Local nCount	:= 1
Local lAmbOk := .T.
Local aObjRet	:= {0,"",Nil,Nil} 

Default cProcess 	:= ""
Default aParams  	:= {}
Default cEmpresa 	:= ""
Default cFilExec 	:= ""
Default lTestAuto 	:= .F.

If lTestAuto
	RPCSetType(3) //Nao faz consumo de licença

	//realizamos a abertura do ambiente
	lAmbOk := RPCSetEnv(cEmpresa, cFilExec,Nil,Nil, "LOJA")

	//Seta nModulo para 23 para garantir execucao via Loja
	nModulo := 23
EndIf

If lTestAuto .AND. !lAmbOk
	LjGrvLog( Nil, "Falha ao abrir o ambiente - Empresa: " + cEmpresa + " Filial: " + cFilExec )
	aObjRet[1] := -105//Não foi possível conectar ao host superior
Else
	LjGrvLog( Nil, "Aberto o ambiente - Empresa: " + cEmpAnt + " Filial: " + cFilAnt )
	
	If ExistFunc(cProcess)

		//Quando é execução local (Totvs PDV Online) sem passar pelo FWCallFunctionality, então o primeiro parametro da função não é o 
		//o objeto com os dados da conexão por isso foi necessario fazer um ajuste incluir o conteúdo LjGetLTT na segunda posição.
		If !lTestAuto .AND. cProcess = 'STCOMDIR' .AND. Len(aParams) == 1 .AND. aParams[1] == "LjGetLTT"
			aParams 	:= {}
			aParams 	:= Array(2)
			aParams[1] 	:= Nil
			aParams[2] 	:= "LjGetLTT"
		EndIf

		For nI := 1 To Len(aParams)
			cParams += IIF(nI == 1,"",",")
			cParams += " aParams["+ AllTrim(STR(nI)) +"] "		
		Next nI	
		
		bBloco 	:= { || &(cProcess + "(" + cParams + ")") }
		             
	    BEGIN SEQUENCE                           
			aObjRet[3] := Eval(bBloco) 	     
	    RECOVER    
			aErroAuto := GetAutoGRLog()
			For nCount := 1 To Len(aErroAuto)	  
			   aObjRet[2] += StrTran(StrTran(aErroAuto[nCount],"<",""),"-","") + (" ")
			Next nCount
			aObjRet[1] := -103//Ocorreu um erro na execução da funcionalidade
			DisarmTransaction()
	    END SEQUENCE
		
		If ValType(aObjRet[3])=="C"
			aObjRet[1] := 0//Ocorreu um erro na execução da funcionalidade
			aObjRet[2] := aObjRet[3]	
		ElseIf ValType(aObjRet[3])=="L" .AND. !aObjRet[3]
		 	aObjRet[1] := -103//Ocorreu um erro na execução da funcionalidade
		 	aObjRet[2] := "Falha durante processo executado pela retaguarda!"
		Endif	
	Else
		aObjRet[1] := -102//Função não encontrada no RPO
		aObjRet[2] := "Função não encontrada no RPO"
	Endif 
Endif

If lTestAuto
	RESET ENVIRONMENT//Fecha o ambiente 
EndIf

Return aObjRet

