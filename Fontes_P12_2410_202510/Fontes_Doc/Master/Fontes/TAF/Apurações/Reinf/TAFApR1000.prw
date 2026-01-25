#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR1000.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR1000
Função que efetua chamada da rotina de copia/apuração do evento R-1000 

@return Nil

@author Ricardo Lovrenovic
@since  19/02/2018
@version 1.1
/*/
//---------------------------------------------------------------------
Function TAFAPR1000( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lValid, lOnlyQuery, lSucesso, cErro )
	Local lProc     as logical
	Local cReturn	as character
	
	lProc 	:= oProcess <> nil
	cReturn	:= ""

	If lProc
		oProcess:IncRegua2(STR0002)
	EndIf
	TAFR1000COP( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lValid, lOnlyQuery, @lSucesso, @cErro ) 	

Return cReturn
//---------------------------------------------------------------------
/*/{Protheus.doc} TAFA489COP
Funcao que copia registros Tabela C1E(estabelecimentos) - S1000 esocial 

@return aQuery

@author Ricardo Lovrenovic 
@since 19/02/2018
@version 1.1
/*/
//---------------------------------------------------------------------
Function TAFR1000COP( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lValid, lOnlyQuery, lSucesso, cErro)

	Local cAliasQry		as character
	Local cSelect		as character
	Local cFrom			as character
	Local cWhere		as character
	Local cId			as character
	Local cNrIsnc		as character
	Local cTpInsc       as character
	Local cKeyProc		as character
	Local cKeySeek		as character
	Local cKeyLog		as character
	Local cCodFil		as character
	Local cVerReg		as character
	Local cVerAnt		as character
	Local cProtAnt		as character
	Local cRaiz			as character
	Local cAviso		as character
	Local nMatriz		as numeric
	Local nTotReg		as numeric
	Local nTEmail		as numeric
	Local nCont			as numeric
	Local nItem			as numeric
	Local nOper			as numeric
	Local nTamFil		as numeric
	Local nlA			as numeric
	Local nPos			as numeric
	Local nTamRaiz		as numeric
	Local oModel 		as object
	Local AutoGrLog		as array
	Local aErro 		as array
	Local lErro 		as logical
	Local lProc 		as logical
	Local lSeekT9U		as logical
	Local lVSup13		as logical
	Local lDelet		as logical
	Local lGrava		as logical
	Local nRecnoOri		as numeric
	Local aCpos 		as array
	Local cLogErr		as character
	Local aLogErro 		as array
	Local aDadosUtil	as array
	Local aContato		as array
	Local aRaiz			as array
	Local cReturn		as character
	Local cVsReinf 		as character
	Local cTpEvento		as character

	Default lValid		:= .F.
	Default lOnlyQuery	:= .F.
	Default aFiliais	:= {}
	Default lSucesso	:= .F.
	Default cErro		:= ""

	cAliasQry 	:= GetNextAlias()
	nTotReg 	:= 0
	nCont 		:= 0
	nItem 		:= 0
	nTamFil		:= 0
	nlA			:= 0
	nPos		:= 0
	nMatriz		:= 0
	nRecnoOri	:= 0
	nTamRaiz	:= 0
	nTEmail		:= TamSx3('T9U_EMAIL')[1]
	nOper 		:= 3
	AutoGrLog 	:= aErro := {}
	oModel 		:= Nil
	lErro 		:= .F.
	lSeekT9U	:= .F.
	lDelet		:= .F.
	lGrava		:= .T.
	cId			:= ""
	cSelect		:= ""
	cFrom		:= ""
	cWhere		:= ""
	cKeyProc	:= ""
	cKeyLog		:= ""
	cKeySeek	:= ""
	lProc 		:= oProcess <> Nil	
	cCodFil		:= ""
	cLogErr		:= ""
	cTpInsc     := ""
	aLogErro	:= {}
	aDadosUtil	:= {}
	aContato	:= {}
	aRaiz 		:= {}
	cReturn		:= ""
	cVsReinf 	:= StrTran( SuperGetMv('MV_TAFVLRE',.F.,"1_03_02") , "_","" )
	lVSup13 	:= Alltrim(cVsReinf) > '10300'
	nTamFil 	:= len(aFiliais)
	cTpEvento	:= "I"
	cRaiz		:= ""
	cAviso		:= ""

	/*--------------------------------------------------------------------------------|
	|   Contador das filiais selecionadas \ Matrizes por Raiz de CNPJ				  |
	|--------------------------------------------------------------------------------*/	
	For nlA := 1 To nTamFil
		if aFiliais[nlA][7]
			cRaiz := SubStr(AllTrim(aFiliais[nlA][5]),1,8)
			nPos := aScan(aRaiz,{|x| cRaiz $ x[01] })
			if nPos == 0
				aadd(aRaiz,{cRaiz,1})
			else
				++aRaiz[nPos][2]
			endif
		endif
	Next nlA

	/*---------------------------------------------------------------------------------|
	| Tratamento mais de uma matriz na mesma raiz CNPJ -> obter correto ID da C1E      |
	|---------------------------------------------------------------------------------*/
	nTamRaiz := len(aRaiz)
	for nlA := 1 to nTamRaiz
		if aRaiz[nlA][2] >= 2
			nMatriz := aScan(aFiliais,{|x| x[07] .And. x[02] == cFilAnt })
			cAviso := STR0014 + CRLF + STR0015 + CRLF + CRLF //"Foi localizado mais de uma matriz (C1E_MATRIZ) para a mesma Raiz de CNPJ."##"É recomendado apenas uma matriz para cada Raiz de CNPJ."
			Exit
		endif
	Next nlA

	/*---------------------------------------------------------------------------------|
	| Caso nao localize mais de uma matriz na mesma raiz, mantem o mesmo funcionamento.|
	|---------------------------------------------------------------------------------*/
	if nMatriz == 0
		nMatriz := aScan(aFiliais,{|x| x[07] })
	endif

	if nMatriz > 0
		cCodFil := aFiliais[nMatriz][02]
	ElseIf nTamFil > 0
		cCodFil := aFiliais[nTamFil][02]
	EndIf

	//Abre T9U para verificar no MSSEEK abaixo se já existe o registro do Select e setar NOPER
	DBSelectArea( "T9U" )
	T9U->( DBSetOrder( 3 ) )
	
	aCpos 		:= TafR1000Cpo()

	cSelect		:= " "+ aCpos[01] + ", C1E.C1E_EVENTO "
	cFrom		:= RetSqlName( "C1E" ) + " C1E "
	cFrom		+= " LEFT JOIN " + RetSqlName( "CRM" ) + " CRM "
	cFrom		+= " ON C1E.C1E_ID = CRM.CRM_ID AND C1E.C1E_FILIAL = CRM.CRM_FILIAL AND C1E.C1E_VERSAO = CRM.CRM_VERSAO AND CRM.D_E_L_E_T_ = ' ' "
	cFrom		+= " LEFT JOIN " + RetSqlName( "C8D" ) + " C8D "
	cFrom		+= " ON C1E.C1E_CLAFIS = C8D.C8D_ID AND C1E.C1E_FILIAL = C8D.C8D_FILIAL AND C8D.D_E_L_E_T_ = ' ' "
	cWhere		:= " C1E.D_E_L_E_T_ = ' ' "
	cWhere		+= " AND C1E.C1E_FILIAL = '" + xFilial( "C1E" ) + "' "
	cWhere		+= " AND C1E.C1E_MATRIZ = 'T' "
	cWhere		+= " AND C1E.C1E_ATIVO 	= '1' "
	if !lOnlyQuery
		cWhere		+= " AND C1E.C1E_PROCID = ' ' "
	endIf
	cWhere		+= " AND C1E.C1E_FILTAF = '"+cCodFil+"' "

	cSelect	:= "%" + cSelect 	+ "%"
	cFrom  	:= "%" + cFrom   	+ "%"
	cWhere 	:= "%" + cWhere  	+ "%"

	BeginSql Alias cAliasQry
		SELECT %Exp:cSelect% FROM %Exp:cFrom% WHERE %EXP:cWhere%
	EndSql
	
	DBSelectArea(cAliasQry)	
	(cAliasQry )->(DBEVAL({|| ++nTotReg }))
	(cAliasQry)->(DbGoTop())
	
	If lProc
		oProcess:SetRegua2( nTotReg )
	EndIf

	If !lOnlyQuery
		If (cAliasQry )->(!Eof())
			oModel := FWLoadModel("TAFA494")

			While (cAliasQry )->(!Eof())			

				oModel:DeActivate()		
				cFilT9U := xFilial( "T9U" )

				If Empty( cFilT9U )
					cKeyProc 	:= cFilT9U + (cAliasQry)->C1E_ID + (cAliasQry)->C1E_VERSAO 
					cKeySeek 	:= cFilT9U + (cAliasQry)->C1E_ID+"1"
				Else
					cKeyProc 	:= (cAliasQry)->C1E_FILTAF + (cAliasQry)->C1E_ID + (cAliasQry)->C1E_VERSAO 
					cKeySeek 	:= (cAliasQry)->C1E_FILTAF + (cAliasQry)->C1E_ID+"1"
				EndIf

				cKeyLog		:= "Id......: "+(cAliasQry)->C1E_ID + CRLF
				cKeyLog		+= "Versão..: "+(cAliasQry)->C1E_VERSAO +CRLF

				nLine		:= 0
				
				//---- Busca Apuração
				//lSeekT9U	:= T9U->(DbSeek( cKeySeek ) )

				If (cAliasQry)->C1E_EVENTO == "A"
					T9U->( dbSetOrder(3) ) //T9U_FILIAL, T9U_ID, T9U_ATIVO
					If T9U->( MsSeek ( cKeySeek ) )
						lSeekT9U := .T.
					endif
				else
					nRecnoOri := foundVerOri("T9U",cFilT9U,(cAliasQry)->C1E_ID,(cAliasQry)->C1E_VERSAO )
				EndIf

				If nRecnoOri > 0
					T9U->(DBGoto(nRecnoOri) )
					lSeekT9U := .T.
				EndIf

				cKeyC1E		:= (cAliasQry)->C1E_FILIAL+(cAliasQry)->C1E_ID+"1"
				cVerAnt		:= ""
				cProtAnt	:= ""
				
				lGrava		:= .T.
				lDelet 		:= .F.
				cTpEvento 	:= 'I'

				If lSeekT9U				
					If T9U->T9U_STATUS == "2" .Or. T9U->T9U_STATUS == "6"
						lGrava	:= .F.
					else
						//Sobrepor inclusao simples não transmitida
						if T9U->T9U_EVENTO == "I" .And. ( Empty(T9U->T9U_STATUS) .Or. T9U->T9U_STATUS == "0" .Or. T9U->T9U_STATUS == "1" .Or. T9U->T9U_STATUS == "3" )
							cTpEvento 	:= 'I'
							lDelet 		:= .T.
						//Sobrepor alteração não transmitida
						elseif T9U->T9U_EVENTO == "A" .And. ( Empty(T9U->T9U_STATUS) .Or. T9U->T9U_STATUS == "0" .Or. T9U->T9U_STATUS == "1" .Or. T9U->T9U_STATUS == "3" ) 
							cVerAnt	 	:= T9U->T9U_VERANT 	//herda do pai
							cProtAnt 	:= T9U->T9U_PROTPN 	//herda do pai
							cTpEvento 	:= 'A'
							lDelet 		:= .T.
						//Nova inclusão após efetivação da exclusão, é considerado como inclusão
						elseif T9U->T9U_EVENTO == "E" .And. ( T9U->T9U_STATUS == "7" .Or. T9U->T9U_STATUS == "4" )
							//cVerAnt	:= T9U->T9U_VERANT 	//herda do pai
							//cProtAnt 	:= T9U->T9U_PROTPN 	//herda do pai
							cVerAnt	 	:= " "	//não herda do pai
							cProtAnt 	:= " " 	//não herda do pai
							FAltRegAnt( 'T9U', '2', .F. ) 	//inativo anterior
							cTpEvento	:= 'I'
							lDelet 		:= .F.
						//Nova inclusão após exclusão sem transmissão, é considerado como alteracao
						elseif T9U->T9U_EVENTO == "E" .And. Empty( T9U->T9U_STATUS )
							cVerAnt	 	:= T9U->T9U_VERANT 	//herda do pai
							cProtAnt 	:= T9U->T9U_PROTPN 	//herda do pai
							FAltRegAnt( 'T9U', '2', .F. ) 	//inativo anterior
							cTpEvento	:= 'A'
							lDelet 		:= .F.
						//Se a ultima apuracao for transmitida, protocolada, ser uma alteracao, estar ativa e o fim do periodo estiver preenchido, significa que foi
						//enviado um termino de vigencia. Se o periodo inicial novo enviado por superior ao termino da apuração anterior, e nao houver novo FINPER preenchido, 
						//o mesmo deverá ser enviado como Inclusão (sem nova validade presente na alteração), indicando que possui um novo R-1000 vigente.
						elseIf T9U->T9U_STATUS == "4" .And. !Empty(T9U->T9U_PROTUL) .And. T9U->T9U_EVENTO == "A" .And. T9U->T9U_ATIVO == "1" .And. !Empty(T9U->T9U_DTFIN) .And.;
						!Empty((cAliasQry)->C1E_INIPER) .And. Empty((cAliasQry)->C1E_FINPER) .And. substr((cAliasQry)->C1E_INIPER,3,4) + substr((cAliasQry)->C1E_INIPER,1,2) > substr(T9U->T9U_DTFIN,3,4) + substr(T9U->T9U_DTFIN,1,2)
							cVerAnt		:= T9U->T9U_VERSAO 	//primeiro filho
							cProtAnt 	:= T9U->T9U_PROTUL 	//primeiro filho
							FAltRegAnt( 'T9U', '2', .F. )	//inativo anterior
							cTpEvento 	:= 'I' 				//devera ser inclusao pois nesse cenario nao eh uma nova validade e sim uma nova vigencia
							lDelet 		:= .F.
						//Alteracao após transmissão
						elseIf T9U->T9U_STATUS == "4" .And. ( T9U->T9U_EVENTO == "I" .Or. T9U->T9U_EVENTO == "A" )
							cVerAnt		:= T9U->T9U_VERSAO 	//primeiro filho
							cProtAnt 	:= T9U->T9U_PROTUL 	//primeiro filho
							FAltRegAnt( 'T9U', '2', .F. )	//inativo anterior
							cTpEvento 	:= 'A'
							lDelet 		:= .F.
						endif
						if lDelet
							// Apaga o Registro
							oModel:SetOperation(MODEL_OPERATION_DELETE)
							oModel:Activate()
							FwFormCommit( oModel )
							oModel:DeActivate()
						endif
					endif
				EndIf

				If lVSup13
					aContato := TafRtCNA("C1E", cKeyC1E, 5, "R")
					AADD( aDadosUtil, { (cAliasQry)->C1E_ID 	, ;		
										(cAliasQry)->C1E_INIPER	, ; 	
										(cAliasQry)->C1E_FINPER	, ; 	
										aContato[01]			, ; 			
										aContato[04] 			, ;			
										aContato[05]			, ;				
										aContato[06]			, ;				
										aContato[07]			, ;				
										aContato[08]			, ;				
										aContato[09]			  ;							
										 }  )

					If (TAFColumnPos("C1E_DTOBIT"))
						AADD( aDadosUtil, {(cAliasQry)->C1E_FILTAF , ;
										   (cAliasQry)->C1E_DTOBIT} )
					EndIf

				Else //Mantem o Funcionamento da versão ate o 1.03.02
					aContato := TafRetCTT("C1E", cKeyC1E, 5, "R")

					AADD( aDadosUtil, { (cAliasQry)->C1E_ID , ;
										(cAliasQry)->C1E_INIPER, ;
										(cAliasQry)->C1E_FINPER, ;
										aContato[01], ; 
										aContato[04] , ;
										aContato[05], ;
										aContato[06], ;
										aContato[07] ;
										}  )
				EndIf

				cLogErr := cAviso + ProcValid( @aLogErro, aDadosUtil )

				If !Empty( cLogErr ) 
					If lValid
						lGrava := .F.
					Else
						TafXLog( cIdLog, cEvento, "ALERTA"			, cLogErr+CRLF+ "Chave: "+CRLF+cKeyLog, cPeriodo  )																
					EndIf
				EndIf

				If lGrava

					cVerReg := xFunGetVer()
					
					If Empty( cId ) 
						//---- Sempre será uma inclusão
						oModel:SetOperation(MODEL_OPERATION_INSERT)
						oModel:Activate()

						cId 	:= (cAliasQry)->C1E_ID + (cAliasQry)->C1E_VERSAO 
						cNrIsnc := Posicione("SM0",1,SM0->M0_CODIGO + (cAliasQry)->C1E_FILTAF,"M0_CGC")

						oModel:GetModel( 'MODEL_T9U' )
						oModel:LoadValue('MODEL_T9U', "T9U_ID"		, (cAliasQry)->C1E_ID )
						oModel:LoadValue('MODEL_T9U', "T9U_VERSAO"	, cVerReg )
						oModel:LoadValue('MODEL_T9U', "T9U_VERANT"	, cVerAnt )
						oModel:LoadValue('MODEL_T9U', "T9U_TPINSC"	, Iif(Len(Alltrim(cNrIsnc)) == 11, "2", "1") )
						oModel:LoadValue('MODEL_T9U', "T9U_NRINSC"	, cNrIsnc)
						oModel:LoadValue('MODEL_T9U', "T9U_DTINI"	, (cAliasQry)->C1E_INIPER )
						oModel:LoadValue('MODEL_T9U', "T9U_DTFIN "	, (cAliasQry)->C1E_FINPER )
						oModel:LoadValue('MODEL_T9U', "T9U_CLAFIS"	, (cAliasQry)->C1E_CLAFIS)
						oModel:LoadValue('MODEL_T9U', "T9U_CCLAFI"	, (cAliasQry)->C8D_CODIGO)
						oModel:LoadValue('MODEL_T9U', "T9U_DCLAFI"	, (cAliasQry)->C8D_DESCRI)
						oModel:LoadValue('MODEL_T9U', "T9U_INDECD"	, (cAliasQry)->C1E_INDESC)
						oModel:LoadValue('MODEL_T9U', "T9U_IDCPRB"	, (cAliasQry)->C1E_INDDES)
						oModel:LoadValue('MODEL_T9U', "T9U_INDACR"	, (cAliasQry)->C1E_ISEMUL)
						oModel:LoadValue('MODEL_T9U', "T9U_INDSPJ"	, (cAliasQry)->C1E_INDPJ)
						oModel:LoadValue('MODEL_T9U', "T9U_NOMCTT"	, aContato[02] )
						oModel:LoadValue('MODEL_T9U', "T9U_CPFCTT"	, aContato[03] )
						oModel:LoadValue('MODEL_T9U', "T9U_FONFIX"	, Alltrim( aContato[04] ) + Alltrim( aContato[05] ) )
						oModel:LoadValue('MODEL_T9U', "T9U_FONCEL"	, Alltrim( aContato[06] ) + AllTrim( aContato[07] ) )
						oModel:LoadValue('MODEL_T9U', "T9U_EMAIL"	, PadR( aContato[01] , nTEmail ) )
						oModel:LoadValue('MODEL_T9U', "T9U_INDEFR"	, (cAliasQry)->C1E_EFR)
						oModel:LoadValue('MODEL_T9U', "T9U_EFRCNP"	, (cAliasQry)->C1E_CPNJER)
						oModel:LoadValue('MODEL_T9U', "T9U_EVENTO"	, cTpEvento )
						oModel:LoadValue('MODEL_T9U', "T9U_ATIVO"	, "1")
						oModel:LoadValue('MODEL_T9U', "T9U_PROTPN"	, AllTrim(cProtAnt) )

						If TAFColumnPos("T9U_VERORI")	
							oModel:LoadValue('MODEL_T9U', "T9U_VERORI"	, (cAliasQry)->C1E_VERSAO )
						EndIf

						If (TAFColumnPos("C1E_DTOBIT")) .And. (TAFColumnPos("C1E_DTFINS")) .And. (TAFColumnPos("C1E_INDUNI"))
							cTpInsc := Iif(Len(Alltrim(cNrIsnc)) == 11, "2", "1")
							//Gravo o campo C1E_DTOBIT apenas se o tipo de inscrição do contribuinte for igual a CPF.
							If cTpInsc == "2"
								oModel:LoadValue('MODEL_T9U', "T9U_DTOBIT"	, STOD((cAliasQry)->C1E_DTOBIT ))
							EndIf
							oModel:LoadValue('MODEL_T9U', "T9U_DTFINS"	, STOD((cAliasQry)->C1E_DTFINS ))
							oModel:LoadValue('MODEL_T9U', "T9U_INDUNI"	, (cAliasQry)->C1E_INDUNI )
						EndIf
						If TAFColumnPos("T9U_INDPER")
							oModel:LoadValue('MODEL_T9U', "T9U_INDPER"	, (cAliasQry)->C1E_INDPER )
						Endif
					EndIf		

					While cKeySeek == IIf(Empty( cFilT9U ), cFilT9U , (cAliasQry)->C1E_FILTAF) + (cAliasQry)->C1E_ID+"1" .And. (cAliasQry )->(!Eof() ) 	

						If !Empty( (cAliasQry)->CRM_ID )
							If nLine > 0
								oModel:GetModel( "MODEL_T9W" ):lValid:= .T.
								oModel:GetModel( "MODEL_T9W" ):AddLine()
							EndIf

							oModel:LoadValue('MODEL_T9W', "T9W_FILIAL"	, (cAliasQry)->CRM_FILIAL)
							oModel:LoadValue('MODEL_T9W', "T9W_ID"		, (cAliasQry)->CRM_ID)
							oModel:LoadValue('MODEL_T9W', "T9W_VERSAO"	, cVerReg )
							oModel:LoadValue('MODEL_T9W', "T9W_SHCNPJ"	, (cAliasQry)->CRM_CNPJ)
							oModel:LoadValue('MODEL_T9W', "T9W_SHNOME"	, (cAliasQry)->CRM_NOME)
							oModel:LoadValue('MODEL_T9W', "T9W_SHCONT"	, (cAliasQry)->CRM_CONTAT)
							oModel:LoadValue('MODEL_T9W', "T9W_SHTEL"	, Alltrim( (cAliasQry)->CRM_DDD ) + AllTrim( (cAliasQry)->CRM_FONE) )
							oModel:LoadValue('MODEL_T9W', "T9W_EMAIL"	, (cAliasQry)->CRM_MAIL)

							nLine++
						EndIf	
						( cAliasQry )->(DbSkip())	
					EndDo
					
					lSucesso := FwFormCommit( oModel )
					
					If lSucesso
					
						oModel:DeActivate()
						
						TafEndGRV( "T9U","T9U_PROCID", cIdLog, T9U->(Recno())  )
						If lValid
							TafEndGRV( "T9U","T9U_STATUS", "0", T9U->(Recno())  )
						EndIf

						DBSelectArea("C1E") 
						C1E->( dbSetOrder(5) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
						If C1E->( DbSeek( cKeyC1E ) ) 
							TafEndGRV( "C1E","C1E_PROCID", cIdLog, C1E->(Recno())  )
						EndIf
						
						TafXLog( cIdLog, cEvento, "MSG"			, "Registro Gravado com sucesso."+CRLF+"Recno => "+cValToChar(T9U->(Recno())),cPeriodo )						
					Else
						aErro   :={}
						cErro := TafRetEMsg( oModel )
						TafXLog( cIdLog, cEvento, "ERRO"			, "Mensagem do erro: " + CRLF + cErro , cPeriodo)						
					EndIf

					oModel:DeActivate()					
					
				Else
					While cKeySeek == IIf(Empty( cFilT9U ), cFilT9U , (cAliasQry)->C1E_FILTAF) + (cAliasQry)->C1E_ID+"1" .And. (cAliasQry )->(!Eof() ) 	
						nLine++
						( cAliasQry )->(DbSkip())	
					EndDo	

					If !Empty( cLogErr ) 
						TafXLog( cIdLog, cEvento, "ERRO"			, cLogErr+CRLF+ "Chave: "+CRLF+cKeyLog, cPeriodo )										
					Else
						TafXLog( cIdLog, cEvento, "ALERTA"			, "Evento transmitido e aguardando retorno:"+CRLF+ "Chave: "+CRLF+cKeyLog , cPeriodo )										
					EndIf
				EndIf
				If lProc		
					oProcess:IncRegua2( STR0013 + cValTochar(nCont++) + "/" + cValTochar(nTotReg))
				EndIf
			EndDo
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf	

Return cAliasQry

//---------------------------------------------------------------------
/*/{Protheus.doc} foundVerOri

Retorna o RecNo do registro que está pendente de Exclusão

@Param  cAliasEvt  - Alias do Evento pendente de Exclusão
@Param  cFilEvt    - Filial do Evento pendente de Exclusão
@Param  cIdEvt     - Id do Evento pendente de Exclusão
@Param  cReciboEvt - Numero do recibo que se encontra no campo _PROTPN

@Author		Evandro dos Santos O. Teixeira
@Since		18/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function foundVerOri(cAliasEvt,cFilEvt,cIdEvt,cVerOri)

	Local nRecNo as numeric 
	Local cQuery as character 
	Local cAlias as character 
	
	nRecNo := 0
	cQuery := ""
	cAlias := GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName(cAliasEvt)
	cQuery += " WHERE " + cAliasEvt + "_FILIAL = '" + xFilial(cAliasEvt, cFilEvt) + "'"
	cQuery += " AND " + cAliasEvt + "_ID = '" + cIdEvt + "'"
	cQuery += " AND " + cAliasEvt + "_ATIVO = '1' "
	cQuery += " AND " + cAliasEvt + "_VERORI = '"+ cVerOri + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias (cAlias)

		If !Empty((cAlias)->RECNO)
			nRecNo := (cAlias)->RECNO
		EndIf 

	(cAlias)->(dbCloseArea())

Return nRecNo



//---------------------------------------------------------------------
/*/{Protheus.doc} TafR1000Cpo

Retorna os campos do legado que são usados na apuração

@Author		Roberto Souza
@Since		05/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafR1000Cpo()
	Local cRet as character
	Local aRet as array

	aRet 	:= {}

	cRet := "C1E_ID,"
	cRet += "C1E_FILIAL," 
	cRet += "C1E_INIPER," 
	cRet += "C1E_VERSAO," 
	cRet += "C1E_FILTAF," 
	cRet += "C1E_CODFIL," 
	cRet += "C1E_FINPER,"
	cRet += "C1E_CLAFIS,"
	cRet += "C8D_CODIGO,"
	cRet += "C8D_DESCRI,"
	cRet += "C1E_INDESC,"
	cRet += "C1E_INDDES,"
	cRet += "C1E_ISEMUL,"
	cRet += "C1E_INDPJ,"

	// Tratamento para novos campos contato REINF
	If (TAFColumnPos("C1E_REMAIL")) ;
		.And. (TAFColumnPos("C1E_RNOMEC")) 	;
		.And. (TAFColumnPos("C1E_RCPFC")) 	;
		.And. (TAFColumnPos("C1E_RDDDFO")) 	;
		.And. (TAFColumnPos("C1E_RFONEC"))	;
		.And. (TAFColumnPos("C1E_RDDDCE"))	;
		.And. (TAFColumnPos("C1E_RCELC"))

		cRet += "C1E_REMAIL,"
		cRet += "C1E_RNOMEC,"
		cRet += "C1E_RCPFC,"
		cRet += "C1E_RDDDFO,"
		cRet += "C1E_RFONEC,"
		cRet += "C1E_RDDDCE,"
		cRet += "C1E_RCELC,"
	Else
		cRet += "C1E_NOMCNT,"
		cRet += "C1E_CPFCNT,"
		cRet += "C1E_DDDFON,"
		cRet += "C1E_FONCNT,"
		cRet += "C1E_DDDCEL,"
		cRet += "C1E_CELCNT,"
		cRet += "C1E_EMAIL,"
	EndIf

	cRet += "C1E_EFR,"
	cRet += "C1E_CPNJER,"

	If (TAFColumnPos("C1E_DTOBIT")) .And. (TAFColumnPos("C1E_DTFINS")) .And. (TAFColumnPos("C1E_INDUNI"))
		cRet += "C1E_DTOBIT,"
		cRet += "C1E_DTFINS,"
		cRet += "C1E_INDUNI,"
	EndIf

	If TAFColumnPos("C1E_INDPER")
		cRet += "C1E_INDPER,"
	EndIf

	cRet += "CRM_FILIAL,"
	cRet += "CRM_ID,"
	cRet += "CRM_CNPJ,"
	cRet += "CRM_NOME,"
	cRet += "CRM_CONTAT,"
	cRet += "CRM_DDD,"
	cRet += "CRM_FONE,"
	cRet += "CRM_MAIL"

	AADD( aRet , cRet )
	AADD( aRet , Separa( cRet , "," ) ) 

Return( aRet )



//---------------------------------------------------------------------
/*/{Protheus.doc} ProcValid

Efetua as pré-validações do governo para evitar rejeição.

@Author		Roberto Souza
@Since		07/04/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function ProcValid( aLogErro, aDadosUtil )
	Local cLogErr 	as character
	Local aRegras 	as array
	Local Nx		as numeric

	Default aLogErro	:= {}
	Default aDadosUtil	:= {}

	cLogErr	:= ""
	aRegras	:= {}	
	Nx		:= 0

	//-------------------------------------
	// Estrutura aRegras
	// [01] - Regra do governo ou interna TAF tratada no ReinfRules()
	// [02] - Ativo - A regra é inativa quando a mesma já é tratada em algum momento anterior à apuração

	AADD( aRegras , {"REGRA_INFO_PERIODO_CONFLITANTE" , .F. } ) 
	/* o Xml Gera data de nova validade quando há alguma alteração então quando ocorre, somente transmitindo e recebendo a rejeição do governo. */
	
	AADD( aRegras , {"REGRA_INFO_VALIDA_DTINICIAL" , .F. } ) 
	/* Em caso de arquivo gerado por Pessoa Jurídica, a {iniValid} deverá ser sempre igual ou posterior à data de início das atividades da empresa constante na base de dados do CNPJ. */
	
	AADD( aRegras , {"REGRA_INFO_VALIDA_RAIZ_CNPJ", .F. } ) 
	/* A regra geral é que cada "RAIZ" de CNPJ somente gera um "cadastro" do contribuinte.
		Nesse caso, o CNPJ do contribuinte deverá ser informado com 8 dígitos, ou seja, apenas a
		Raiz/Base.
		No caso de órgãos públicos da administração direta federal, com natureza jurídica igual a
		[101-5], [104-0], [107-4], [116-3], cada "CNPJ" completo (14 dígitos) deverá ser tratado
		como um " contribuinte" diferente. Nesse caso, o CNPJ do empregador deverá ser
		informado com 14 dígitos
	*/
	
	AADD( aRegras , {"REGRA_TABGERAL_EXISTE_REGISTRO_ALTERADO", .F. } ) 
	/* Em caso de alteração, deve existir registro na tabela com o mesmo código e período de validade informados no evento. */
	
	AADD( aRegras , {"REGRA_TAB_PERMITE_EXCLUSAO" , .F. } ) 
	/*Em caso de {exclusao}, o registro identificado pelo período de validade deve existir e o
		registro somente pode ser excluído se não houver outros arquivos de eventos enviados
		anteriormente que façam referência ao mesmo. */

	AADD( aRegras , {"REGRA_VALIDA_CONTRIBUINTE", .F. } )
	/*1. Se o {tpInsc} do contribuinte for igual a [1] (CNPJ), o CNPJ indicado no campo {nrInsc}
		deve obedecer às seguintes condições:
		a) CNPJ não poderá pertencer a pessoa jurídica Inapta (situação=4) pelo motivo de
		Inexistência de Fato (motivo=15);
		b) Caso o CNPJ esteja baixado, a data de ocorrência do evento (em caso de evento
		trabalhista) deve ser igual ou anterior a data da baixa. Em caso de evento periódico mensal,
		o período de apuração deverá ser anterior ou igual ao mês/ano da baixa.
		c) CNPJ não poderá estar anulado.
		2. Se o {tpInsc} do empregador for igual a [2] (CPF), o CPF indicado no campo {nrInsc}
		não poderá estar cancelado:
		a) em data anterior à data de ocorrência de evento não periódico;
		b) no mês/ano do período de apuração de evento periódico; */

	AADD( aRegras , {"REGRA_VALIDA_ID_EVENTO", .F. } )
	/*A identificação única do evento (Id) é composta por 36 caracteres, conforme o que segue:
		IDTNNNNNNNNNNNNNNAAAAMMDDHHMMSSQQQQQ
		ID - Texto Fixo "ID";
		T - Tipo de Inscrição do Empregador (1 - CNPJ; 2 - CPF);
		NNNNNNNNNNNNNN - Número do CNPJ ou CPF do empregador - Completar com
		zeros à direita. No caso de pessoas jurídicas, o CNPJ informado deve conter 8 ou 14
		posições de acordo com o enquadramento do contribuinte para preenchimento do campo
		{ideEmpregador/nrInsc} do evento R-1000, completando-se com zeros à direita, se
		necessário.
		AAAAMMDD - Ano, mês e dia da geração do evento;
		HHMMSS - Hora, minuto e segundo da geração do evento;
		QQQQQ - Número sequencial da chave. Incrementar somente quando ocorrer geração de
		eventos na mesma data/hora, completando com zeros à esquerda.
		OBS.: No caso de pessoas jurídicas, o CNPJ informado deverá conter 8 ou 14 posições de
		acordo com o enquadramento do contribuinte para preenchimento do campo
		{ideEmpregador/nrInsc} do evento S-1000, completando-se com zeros à direita, se
		necessário. */

	AADD( aRegras , {"REGRA_TAF_DTINI_EVENTO", .T. } )
	/*	Preencher com o mês e ano de início da validade das informações prestadas no evento, no formato AAAA-MM. Validação: Deve ser uma data válida, igual ou posterior à data inicial de implantação da EFD-Reinf, no formato AAAA-MM.*/

	AADD( aRegras , {"REGRA_TAF_DTFIM_EVENTO", .T. } )
	/* Preencher com o mês e ano de término da validade das informações, se houver. Validação: Se informado, deve estar no formato AAAA-MM e ser um período igual ou posterior a {iniValid} */
	
	AADD( aRegras , {"REGRA_TAF_EMAIL", .T. } )
	/* Endereço eletrônico Validação: O e-mail deve possuir o caractere "@" e este não pode estar no início e/ou no final do endereço informado. Deve possuir no mínimo um caractere "." depois do @ e não pode estar no final do endereço informado. */

	AADD( aRegras , {"REGRA_TAF_FONE", .T. } )
	/*	Informar o número do telefone, com DDD. Validação: O preenchimento é obrigatório se o campo {foneCel} não for preenchido. Se preenchido, deve conter apenas números, com o mínimo de dez dígitos.
		Telefone celular, com DDD Validação: Se preenchido, deve conter apenas números, com o mínimo de dez dígitos.*/

	AADD( aRegras , {"REGRA_TAF_DESONERACAO", .T. } )
	/* Validação: Pode ser igual a [1] apenas se a classificação tributária for igual a [02, 03, 99]. Nos demais casos deve ser igual a [0]. */

	If (TAFColumnPos("C1E_DTOBIT"))
		AADD( aRegras , {"REGRA_TAF_DTOBITO", .T. } )
		/* Validação: DtObito não pode estar preenchido caso TpInsc do contribuinte seja igual a CNPJ */
	EndIf
	
	If FindFunction( "ReinfRules" )
		For Nx := 1 To Len( aRegras )
			If aRegras[nx][02]
				cLogErr += ReinfRules( "C1E", aRegras[Nx][01] , @aLogErro, aDadosUtil, "C1E", .F. )
			EndIf
		Next
	EndIf			
Return( cLogErr )  


//---------------------------------------------------------------------
/*/{Protheus.doc} TafRetCTT
Busca a informações de contato para Reinf, considerando od campos novos e antigos.
@Author		Roberto Souza
@Since		22/05/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafRetCTT( cAlias, cKey, nOrd, cModelo )
	Local aArea		as array
	Local aContato 	as array

	Default nOrd := 1
	aArea		:= GetArea()
	aContato	:= Array(7)

	DBSelectArea( cAlias ) 
	( cAlias )->( dbSetOrder( nOrd ) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
	If ( cAlias )->( DbSeek( cKey ) )
		If cAlias == "C1E"
			If cModelo == "R" // Reinf
				If (TAFColumnPos("C1E_REMAIL")) ;
					.And. (TAFColumnPos("C1E_RNOMEC")) 	;
					.And. (TAFColumnPos("C1E_RCPFC")) 	;
					.And. (TAFColumnPos("C1E_RDDDFO")) 	;
					.And. (TAFColumnPos("C1E_RFONEC"))	;
					.And. (TAFColumnPos("C1E_RDDDCE"))	;
					.And. (TAFColumnPos("C1E_RCELC"))

					aContato[01] := C1E->C1E_REMAIL 
					aContato[02] := C1E->C1E_RNOMEC 
					aContato[03] := C1E->C1E_RCPFC  
					aContato[04] := C1E->C1E_RDDDFO 
					aContato[05] := C1E->C1E_RFONEC 
					aContato[06] := C1E->C1E_RDDDCE 
					aContato[07] := C1E->C1E_RCELC  
				Else
					cModelo := "E"
				EndIf
				If 	Empty(aContato[01]) .And. ;
					Empty(aContato[02]) .And. ;
					Empty(aContato[03]) .And. ;  
					Empty(aContato[04]) .And. ;
					Empty(aContato[05]) .And. ;
					Empty(aContato[06]) .And. ;
					Empty(aContato[07])   
					
					cModelo := "E"
				EndIf
			EndIf
		
			If cModelo == "E" // Reinf				

				aContato[01] := C1E->C1E_EMAIL 
				aContato[02] := C1E->C1E_NOMCNT 
				aContato[03] := C1E->C1E_CPFCNT  
				aContato[04] := C1E->C1E_DDDFON 
				aContato[05] := C1E->C1E_FONCNT 
				aContato[06] := C1E->C1E_DDDCEL 
				aContato[07] := C1E->C1E_CELCNT  

			EndIf
		EndIf
	EndIf
	RestArea( aArea )
Return( aContato )

//---------------------------------------------------------------------
/*/{Protheus.doc} TafRtCNA
Busca as informações de contato para Reinf, considerando os campos novos e antigos.
@Author		Denis Souza
@Since		24/09/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Function TafRtCNA( cAlias, cKey, nOrd, cModelo )
	Local aArea		as array
	Local aContato 	as array

	Default nOrd := 1
	aArea		:= GetArea()
	aContato	:= Array(9)

	DBSelectArea( cAlias )
	( cAlias )->( dbSetOrder( nOrd ) ) //C1E_FILIAL+C1E_FILTAF+C1E_ATIVO
	If ( cAlias )->( DbSeek( cKey ) )
		If cAlias == "C1E"
			If cModelo == "R" // Reinf
				If (TAFColumnPos("C1E_REMAIL")) ;
					.And. (TAFColumnPos("C1E_RNOMEC")) 	;
					.And. (TAFColumnPos("C1E_RCPFC")) 	;
					.And. (TAFColumnPos("C1E_RDDDFO")) 	;
					.And. (TAFColumnPos("C1E_RFONEC"))	;
					.And. (TAFColumnPos("C1E_RDDDCE"))	;
					.And. (TAFColumnPos("C1E_RCELC"))	;
					.And. (TAFColumnPos("C1E_INDDES"))	;
					.And. (TAFColumnPos("C1E_CLAFIS"))
					aContato[01] := C1E->C1E_REMAIL
					aContato[02] := C1E->C1E_RNOMEC
					aContato[03] := C1E->C1E_RCPFC
					aContato[04] := C1E->C1E_RDDDFO
					aContato[05] := C1E->C1E_RFONEC
					aContato[06] := C1E->C1E_RDDDCE
					aContato[07] := C1E->C1E_RCELC
					aContato[08] := C1E->C1E_INDDES
					aContato[09] := C1E->C1E_CLAFIS
				Else
					cModelo := "E"
				EndIf
				If 	Empty(aContato[01]) .And. ;
					Empty(aContato[02]) .And. ;
					Empty(aContato[03]) .And. ;
					Empty(aContato[04]) .And. ;
					Empty(aContato[05]) .And. ;
					Empty(aContato[06]) .And. ;
					Empty(aContato[07]) .And. ;
					Empty(aContato[08]) .And. ;
					Empty(aContato[09])
					cModelo := "E"
				EndIf
			EndIf
			If cModelo == "E" // Reinf
				aContato[01] := C1E->C1E_EMAIL
				aContato[02] := C1E->C1E_NOMCNT
				aContato[03] := C1E->C1E_CPFCNT
				aContato[04] := C1E->C1E_DDDFON
				aContato[05] := C1E->C1E_FONCNT
				aContato[06] := C1E->C1E_DDDCEL
				aContato[07] := C1E->C1E_CELCNT
				aContato[08] := C1E->C1E_INDDES
				aContato[09] := C1E->C1E_CLAFIS
			EndIf
		EndIf
	EndIf
	RestArea( aArea )

Return( aContato )
