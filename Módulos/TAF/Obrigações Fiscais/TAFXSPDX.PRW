#Include "Protheus.ch"
#INCLUDE "FileIO.CH"

#Define _Enter Chr(13) + Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} WrtStrTxt
Funcao responsavel pela gravacao das informacoes configuradas no array
	de depara definido na funcao "DistrCmps"

@Param	aCmps		->  Array com os campos de gravacao conforme registro
		cReg		->	Registro a ser gravadao conforme estrutura do array
		lSeek		->	Variavel para tratamento interno na MACRO casa haja necessidade de se verificar um SEEK qualquer
		aMacro		->	Array com linhas de macro execucao para ser executado na gravacao dos campos antes do input dos valores
		lGrvTabSpd -> Indica se deve gravar a tabela de geracao do Sped ou o arquivo txt
		aInfoGrv   -> Informações necessárias para serem gravadas na tabela
		cChvReg    -> Chave do registro a ser gravado
		
@Return nRet

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0

Altered by Rodrigo Aguilar 
Implementada gravação na tabela temporária de geração dos Speds ao inves de gerar o arquivo magnético
/*/
//-------------------------------------------------------------------
Function WrtStrTxt( nHandle, cString, lGrvTabSpd, aInfoGrv, cChvReg )

Local	nRet	            :=	0
Local  cAliasSpd          := "TAFSPED" + "_" + cEmpAnt //Tabela de informacoes geradas pelos SPED´s
Local  cInsert, cValues   := ""
Local cBanco	:=	Upper( AllTrim( TcGetDB() ) )

Local aBlocoSpd := {}

Default cString	  :=	Nil
Default lGrvTabSpd := .F.
Default cChvReg    := ""

If !lGrvTabSpd
	If cString != Nil .And. !Empty( cString )
		FSeek( nHandle, 0, FS_END )
		nRet	:=	FWrite( nHandle , cString , Len( cString ) )
	EndIf
	
	//Se houver erro na gravacao, nao limpo a variavel
	If nRet != -1
		cString :=	''
	EndIf
Else
	aBlocoSpd := StrToKarr( cString, _Enter )   
		
	For nRet := 1 To Len( aBlocoSpd )	
		If !Empty( aBlocoSpd[nRet] ) 
			
			cInsert := "INSERT INTO " + cAliasSpd + " ( FILIAL, PERINI, PERFIN, BLOCO, REGSEQ, REGISTRO, LINREG, CHAVE ) VALUES "
	
			//Caso não tenha sido enviado gravo a propria indicação do registro como chave
			If Empty( cChvReg )
				cChvReg := SubString( Alltrim( aBlocoSpd[nRet] ), 2, 4 )
			EndIf
					
			//Para o primeiro registro da familia devo gravar o sequencializador enviado na chamada,
			//para os demais devo somar 1 no mesmo, quando o aInfoGrv[5] == 0 eh para o bloco 0
			//deve sempre gerar o sequencializador com 0 
			If nRet > 1 .And. aInfoGrv[5] > 0 
				aInfoGrv[5]++
			EndIf
			
			//Tratamento para adicionar o Pipe ( '|' ) ao final da string de linha do texto
			//pois o comando TCSQLExec está inserindo informações sem o último caracter em ORACLE
			If cBanco == "ORACLE"
				aBlocoSpd[nRet] := Alltrim( aBlocoSpd[nRet] ) + "|"
			EndIf
			
			aBlocoSpd[nRet] := StrTran(aBlocoSpd[nRet], "'", " " )
			
			cValues := "( '" + aInfoGrv[1] + "', '" + aInfoGrv[2] + "', '" + aInfoGrv[3] + "', '" + aInfoGrv[4] + "', '" + StrZero( aInfoGrv[5], 10 ) + "', '" + SubString( Alltrim( aBlocoSpd[nRet] ), 2, 4 ) + "', '" + aBlocoSpd[nRet] + "', '" + Alltrim( cChvReg ) + "')     "                
			
			//Tratamento para quando ocorre erro na gravacao			
			If TcSqlExec( cInsert + SubStr( cValues, 1, Len( cValues ) -  2 ) ) < 0
				Conout( "Erro na gravação do registro na tabela de controle, Instrução: " + TCSQLError() + " --->" + 	cInsert + cValues ) 			
			EndIf
			
		EndIf
	Next
	
	//Limpo a variavel utilizada para grvacao das informações
	cString := ""
	
	//Apenas para que o retorno seja > 0 e nao impactar nos tratamentos no processamento na origem
	nRet := 10
EndIf

Return ( nRet )
//-------------------------------------------------------------------
/*/{Protheus.doc} SaveTxt
Realiza a Gravacao do Arquivo TXT

@param	nHandle -> Handle para gravacao
		cTxtSys -> Arquivo TXT criado pela rotina para gerar o arquivo dentro da System
		cTxtUsu -> Arquivo destino definido pelo usuario
		lArqTemp-> Arquivo .txt temporario, gerado para posterior consolidacao dos dados.
		
@return NIL

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function SaveTxt( nHandle , cTxtSys , cTxtUsu, lArqTemp )

Local	cDrive		:=	''
Local	cPath		:=	''
Local	cNewFile	:=	''
Local	cExt		:=	''
Local	lCopied		:=	.F.
Local 	cStartPath 	:= 	GetSrvProfString( "StartPath" , "" )
Local	lRet		:=	.F.
Local 	lWebApp		:= Nil 
Default lArqTemp := .f.

If nHandle >= 0
	FClose( nHandle )
Endif

If File( cTxtUsu )		
	FErase( cTxtUsu )
Endif             

SplitPath( cTxtUsu , @cDrive , @cPath , @cNewFile , @cExt )
cNewFile	:=	cNewFile + cExt

If Substr( cStartPath , Len( AllTrim( cStartPath ) ) , 1 ) <> "\"
	cStartPath += '\'
EndIf
	
lWebApp := GetRemoteType() = 5 .and. !lArqTemp
if lWebApp
	if FRename( cStartPath + cTxtSys , cStartPath + cNewFile  ) == 0
		if CpyS2TW(cStartPath + cNewFile, .t.) == 0
			FErase( cNewFile )
			lRet := .t.
		endif	
	endif
else	
	lCopied := iif ( Empty( cDrive ) , __CopyFile( cTxtSys , cDrive + cPath + cNewFile ) , CpyS2T( cStartPath + cTxtSys , cDrive + cPath , .F. ) )
	If lCopied 
		FErase( cTxtSys )
		If File( cDrive + cPath + cTxtSys )
			FRename( cDrive + cPath + cTxtSys , cTxtUsu )
			lRet	:=	.T.
		EndIf
	EndIf
endif	

Return ( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Val2Str
Funcao responsavel por converter o '.' do resultado do STR() em ',', separador padrao de decimal
exigido no TAF para o arquivo de importacao

@param	nValor	-> 	Valor a ser convertido
		nInt	->	Quantidade de casas inteiras
		nDec	->	Quantidade de decimais
		
@return cRet

@author Gustavo G. Rueda
@since 22/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
//-------------------------------------------------------------------
Function Val2Str( nValor , nInt , nDec, lZerNil ) //mauro 

Local cRet := ""

Default lZerNil := .F. 

If Valtype( nValor ) == "C"
	cRet := nValor
Else
	cRet := IIf(nValor==0 .And. lZerNil, '', Alltrim( StrTran( Str( nValor , nInt , nDec ) , '.' , ',' ) )) //mauro
EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Dt2Caract

Funcao responsavel por converter a Data no Formato AAAMMDD para
DDMMAAAA conforme exigido pelo Layout do Sped Fiscal

@param	xData -> Data a ser convertida
		
@return cData

@author Rodrigo Aguilar
@since 14/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function Dt2Caract( xData )	     

Local cData := ""

If ValType( xData )  == "D"
	cData := dToS( xData )//StrTran( DToC( xData ), "/", "" ) 
	cData := Right( cData, 2 ) + SubStr( cData, 5, 2 ) + Left( cData, 4 )
	 
ElseIf ValType( xData )  == "C"
	cData := dToS( cToD( xData ) )
	cData := Right( xData, 2 ) + SubStr( xData, 5, 2 ) + Left( xData, 4 )
	
EndIf

cData := AllTrim( cData )
Return ( cData )  

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFConType 

@author Fabio V. Santana
@since	22/02/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFConType(xValor,nTam)

Local cNovo    := ""

If nTam==Nil
	xValor := AllTrim(xValor)
EndIf
DEFAULT nTam := 60
If FindFunction( "FWNoAccent" )
	cNovo := AllTrim( EnCodeUtf8( FWNoAccent( SubStr( xValor , 1 , nTam ) ) ) )
Else
	cNovo := AllTrim( EnCodeUtf8( NoAcento( SubStr( xValor , 1 , nTam ) ) ) )
Endif

//Tratamento para que quando o cliente utilize "'" em seus campos de descrição seja incluído um
//"'" a mais, pois o banco de dados considera apenas um "'" e não ocorre erro de sintaxe,
//caso ocorra problema para algum banco específico NÃO RETIRE ESSA VALIDAÇÃO mas sim analise uma
//solução alternativa 
cNovo := StrTran( cNovo, "'", "''" )

Return(cNovo)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldIE 

@author Fabio V. Santana
@since	22/02/2013 
@version 1.0

/*/
//-------------------------------------------------------------------
Function VldIE(cInsc,lContr,lIsent)

Local 		cRet	:=	""
Local 		nI		:=	1
Default 	lContr  :=	.T.
Default		lIsent	:=	.T.

For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)

If lIsent
	If "ISENT"$Upper(cRet)
		cRet := ""
	EndIf
	If !(lContr) .And. !Empty(cRet)
		cRet := "ISENTA"
	EndIf
EndIf 

Return(cRet)  

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetEnd

Retorna a estrutura do endereco passado.

@Param cEndereco -> Endereco completo
       cUF       -> UF do endereço

@Return 1 - Endereco
        2 - Numero ( N )
        3 - Numero ( C )
        4 - Complemento

@Author Felipe C. Seolin (Copiada de MATA950)
@Since 27/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGetEnd( cEndereco, cUF )

Local cNumero    := ""
Local cEnderec   := ""
Local cCompl     := ""
Local cComplemen := ""
Local nVirgula   := Rat( ",", cEndereco )
Local nNumero    := 0
Local aNumStr    := {}
Local lEndNfe    := If( FunName() == "SPEDNFE", .T., .F. )
Local lExterior  := .F.

Default cUF      := ""

lExterior := ( cUF == "EX" )

cNumero    := If( !lExterior, AllTrim( SubStr( cEndereco, nVirgula + 1 ) ), Left( cEndereco, nVirgula - 1 ) )
nNumero    := NoRound( Val( cNumero ), 3 )
cCompl     := If( !lExterior, AllTrim( SubStr( cEndereco, nVirgula + 1 ) ), Left( cEndereco, nVirgula - 1 ) )
cComplemen := ""

If lEndNfe
	If nNumero <> 0
		If !lExterior
			cEnderec := PadR( SubStr( cEndereco, 1, nVirgula - 1 ), 60 )
		Else
			cEnderec := PadR( LTrim( SubStr( cEndereco, nVirgula + 1 ) ), 60 )
		EndIf
	Else
		cEnderec := PadR( cEndereco, 60 )
	EndIf
Else
	If nNumero <> 0
		If !lExterior
			cEnderec := PadR( SubStr( cEndereco, 1, nVirgula - 1 ), 34 )
		Else
			cEnderec := PadR( LTrim( SubStr( cEndereco, nVirgula + 1 ) ), 34 )
		EndIf
	Else
		cEnderec := PadR( SubStr( cEndereco, 1, nVirgula - 1 ), 34 )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando nao ha virgula no endereco procura-se o caracter branco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nVirgula == 0 )
	nVirgula := Rat( " ", AllTrim( cEndereco ) )
	cEnderec := RTrim( cEndereco )
	cCompl   := "" //NAO TEM COMO PEGAR O COMPLEMENTO, JAH QUE UTILIZO O ULTIMO ESPACO A DIREITO PARA SEPARAR O LOGRADOURO DO NUMERO.
	cNumero  := AllTrim( SubStr( cEndereco, nVirgula + 1 ) )
	aNumStr  := RetNumTaf( cNumero )

	If Len( aNumStr[1] ) > 1
		cNumero := "S/N"
	EndIf

	nNumero := Val( cNumero )

	If lEndNfe == .F.
		lEnderec := PadR( IIf( nNumero <> 0, SubStr( cEndereco, 1, nVirgula - 1 ), cEndereco ), 34 )
	Else
		lEnderec := PadR( IIf( nNumero <> 0, SubStr( cEndereco, 1, nVirgula - 1 ), cEndereco), 60 )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quando o numero é numerico, obtem-se o complemento            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nNumero <> 0
	If At( " ", AllTrim( cCompl ) ) > 0
		cComplemen := AllTrim( SubStr( cCompl, At( " ", AllTrim( cCompl ) ) + 1 ) )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o numero caracter extrai o complemmento.                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumero := StrTran( cNumero, cComplemen, "" )

Return( { cEnderec, nNumero, cNumero, cComplemen } )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFGetTel

Retorna a estrutura do telefone passado.

@Param cTelefone -> Texto do Telefone
       cArea     -> Codigo de Area
       cPais     -> Codigo do Pais

@Return 1 - Codigo do Pais
        2 - Codigo de Area
        3 - Telefone

@Author Felipe C. Seolin (Copiada de MATA950)
@Since 27/06/2014
@Version 1.0
/*/
//---------------------------------------------------------------------
Function TAFGetTel( cTelefone, cArea, cPais )

Local nX      := 0
Local nCount  := 0
Local cAux    := ""
Local cNumero := ""
Local lFone   := .T.
Local lArea   := .F.
Local lPais   := .F.

Default cArea := ""
Default cPais := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico o que deve ser extraido do numero do telefone        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lArea     := Empty( cArea )
lPais     := Empty( cPais ) .and. lArea
cTelefone := AllTrim( cTelefone )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtenho o codigo de pais/area e telefone do Telefone          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := Len( cTelefone ) to 1 Step - 1
	nCount ++
	cAux := SubStr( cTelefone, nX, 1 )

	If cAux >= "0" .and. cAux <= "9"
		Do Case
			Case lFone
				cNumero := cAux + cNumero
			Case lArea
				cArea := cAux + cArea
			Case lPais
				cPais := cAux + cPais
		EndCase

		If nCount == 9
			lFone := .F.
		EndIf
	Else
		Do Case
			Case lFone
				If Len( cNumero ) > 5
					lFone := .F.
				EndIf
			Case lArea
				If !Empty( cArea )
					lArea := .F.
				EndIf
		EndCase
	EndIf
Next nX

Return( { Val( cPais ), Val( cArea ), Val( cNumero ) } )

//-------------------------------------------------------------------
/*/{Protheus.doc} RetNumTaf
Funcao que retorna valores numericos e strings de um texto separado.
@param	cTexto	-> Texto para separar os tipos de caracteres
@return	aRet	-> Array que possui duas posicoes:
                   1 - Conteudos Caracteres
                   2 - Conteudos numericos
@author	Denis R Oliveira
/*/
//-------------------------------------------------------------------
Static Function RetNumTaf(cTexto)

Local nX		:= 0
Local aRet		:= {"",""}
Local cVar		:= ""
Local cVarFil	:= AllTrim(cTexto)
Local nTamTxt	:= Len(cVarFil)

For nX := 1 To nTamTxt
	cVar	:= SubStr(cVarFil,1,1)
	cVarFil	:= SubStr(cVarFil,2)
	If Empty(cVar)
		Loop
	ElseIf cVar <> "0" .And. Val(cVar) = 0
		aRet[1] += cVar
	Else
		aRet[2] += cVar
	EndIf
Next

Return aRet
