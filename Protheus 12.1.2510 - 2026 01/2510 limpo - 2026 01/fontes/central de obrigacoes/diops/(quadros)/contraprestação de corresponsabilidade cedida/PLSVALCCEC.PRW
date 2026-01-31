#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDECC01

Funcao criada para validar Critica CC01
Valida o código do tipo de evento utilizado

@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author José Paulo de Azevedo
@since 02/05/2019n
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDECC01()

	Local lRetorno	:= .F.
	lRetorno := !Empty( getInCdECE( B36->B36_CODIGO ) )

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI02

Funcao criada para validar Critica CC02
Somatório dos Novos Avisos de Eventos com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDECC02()

	Local lRetorno := .F.
	Local cWhere   := " AND B36_CODIGO BETWEEN '33' AND '46' "
	Local aConta   := {'311711013','311711023','311711033','311711043','311711053','311711063','311721013','311721023','311721033','311721043','311721053','311721063'}
	
	lRetorno	:= PlVldEVICE(cWhere, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI03

Funcao criada para validar Critica CC03
Somatório de baixas por glosa com o total da Conta Contábil respectiva

@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
/*Function PLVLDECC03()

	Local lRetorno	:= .F.
	Local cWhere	:= " AND B36_CODIGO BETWEEN '47' AND '60' " 
	Local aConta	:= {'311711015','311711025','311711035','311711045','311711055','311711065','311721015','311721025','311721035','311721045','311721055','311721065'}

	lRetorno	:= PlVldEVICE(cWhere, aConta)

Return lRetorno*/

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI04

Funcao criada para validar Critica CC04
Somatório de outras recuperações com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
/*Function PLVLDECC04()

	Local lRetorno	:= .F.
	Local cWhere	:= " AND B36_CODIGO BETWEEN '65' AND '78' "
	Local aConta	:= {'311711014','311711024','311711034','311711044','311711054','311711064','311721014','311721024','311721034','311721044','311721054','311721064'}

	lRetorno := PlVldEVICE(cWhere, aConta)

Return lRetorno*/


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldEVICE

Função criada para validar Movimentação de Contraprestação de Corresponsabilidade cedida

@Parametros recebidos:
cCampo	-> Nome do campo referente ao mês do trimestre que irá validar
aConta	-> Array contendo as contas contábeis que validarão o total dos campos  

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldEVICE(cWhere,aConta,oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local cCodOpe := ""
	Local cCodObr := ""
	Local cAnoCmp := ""
	Local cCdComp:= ""	
	Local cConta 	:= ""	
	Local nSldCob	:= 0
	Local nVez		:= 0

	Default oModel	:= Nil	
	Default cWhere	:= ''
	Default aConta	:= {}
	
	If Empty(aConta)
		Return(.F.)
	EndIf	

	For nVez := 1 to Len(aConta)
		cConta += aConta[nVez]+','   
	Next
	cConta := FormatIn(cConta,",")
	
	If oModel == Nil
		cCodOpe := AllTrim(B3D->B3D_CODOPE)
		cCodObr := AllTrim(B3D->B3D_CDOBRI)
		cAnoCmp := AllTrim(B3D->B3D_ANO)
		cCdComp := AllTrim(B3D->B3D_CODIGO)	
	Else
		cCodOpe	:= AllTrim(oModel:GetValue( 'B36MASTER', 'B36_CODOPE' )) 
		cCodObr	:= AllTrim(oModel:GetValue( 'B36MASTER', 'B36_CODOBR' )) 
		cAnoCmp	:= AllTrim(oModel:GetValue( 'B36MASTER', 'B36_ANOCMP' )) 
		cCdComp := AllTrim(oModel:GetValue( 'B36MASTER', 'B36_CDCOMP' ))
	EndIf

	cSql := " SELECT SUM(B36_VLMES1+B36_VLMES2+B36_VLMES3) VALOR "
	cSql += "  FROM " + RetSqlName("B36") 
	cSql += " WHERE B36_FILIAL = '" + xFilial("B36") + "' " 
	cSql += "  AND B36_CODOPE = '" + cCodOpe + "' "
	cSql += "  AND B36_CODOBR = '" + cCodObr + "' "
	cSql += "  AND B36_ANOCMP = '" + cAnoCmp + "' "
	cSql += "  AND B36_CDCOMP = '" + cCdComp + "' "
	cSql += cWhere
	cSql += "  AND D_E_L_E_T_ = ' ' " 	
		
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCON",.F.,.T.)

	If !TRBCON->(Eof())	
		// Se há dados sobre o quadro, guarda valor para comparação com a conta	
		nSldCob	:= TRBCON->VALOR
	Else
		// Se nao há dados sobre o quadro, aborta validação retornando Verdadeiro
		Return(.T.)			
	EndIf
	
	TRBCON->(dbCloseArea())

	cSql := " SELECT SUM(B8A_SALFIN) AS VALCTB "
	cSql += "  FROM " + RetSqlName("B8A")
	cSql += " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
	cSql += "  AND B8A_CODOPE = '" + cCodOpe + "' "
	cSql += "  AND B8A_CODOBR = '" + cCodObr + "' "
	cSql += "  AND B8A_ANOCMP = '" + cAnoCmp + "' "
	cSql += "  AND B8A_CDCOMP = '" + cCdComp + "' "
	cSql += "  AND B8A_CONTA  IN " + cConta + " "
	cSql += "  AND D_E_L_E_T_ = ' ' "
		
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB8A",.F.,.T.)

	If !TRBB8A->(Eof())	
		lRet := ( TRBB8A->VALCTB == nSldCob )
	Else
		lRet	:= .F.			
	EndIf
	TRBB8A->(dbCloseArea())
	 
Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getInCdECE

Retorna descrição do código da Movimentação de COntraprestação de Corresponsabilidade cedida - tabela de dominio ANS

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
function getInCdECE( cCodigo, lRetLogico )

local aInfoEve := {}
local cRetorno := ""
 
default cCodigo := ""
default lRetLogico	:= .F.

aAdd(aInfoEve,{"33","Novos avisos referentes a eventos ocorridos no mês " } )
aAdd(aInfoEve,{"34","Novos avisos referentes a eventos ocorridos no mês n-1 " } )
aAdd(aInfoEve,{"35","Novos avisos referentes a eventos ocorridos no mês n-2 " } )
aAdd(aInfoEve,{"36","Novos avisos referentes a eventos ocorridos no mês n-3 " } )
aAdd(aInfoEve,{"37","Novos avisos referentes a eventos ocorridos no mês n-4 " } )
aAdd(aInfoEve,{"38","Novos avisos referentes a eventos ocorridos no mês n-5 " } )
aAdd(aInfoEve,{"39","Novos avisos referentes a eventos ocorridos no mês n-6 " } )
aAdd(aInfoEve,{"40","Novos avisos referentes a eventos ocorridos no mês n-7 " } )
aAdd(aInfoEve,{"41","Novos avisos referentes a eventos ocorridos no mês n-8 " } )
aAdd(aInfoEve,{"42","Novos avisos referentes a eventos ocorridos no mês n-9 " } )
aAdd(aInfoEve,{"43","Novos avisos referentes a eventos ocorridos no mês n-10 " } )
aAdd(aInfoEve,{"44","Novos avisos referentes a eventos ocorridos no mês n-11 " } )
aAdd(aInfoEve,{"45","Novos avisos referentes a eventos ocorridos no mês n-12 " } )
aAdd(aInfoEve,{"46","Novos avisos referentes a eventos ocorridos no mês n-13 e anteriores a essa data " } )

//---------------------------------------------------------------------------------------
	/*Informações sobre Baixa por Glosas e Outras Recuperações,	foram removidas para a 
	  vigência de 2022. */

	/* 47 ao 60 - Total por Glosa reconhecidas no Mês (todos os códigos) 
	   65 ao 78 - Total de Outras Recuperações Reconhecidas no Mês (todos os códigos)*/
//---------------------------------------------------------------------------------------

/*aAdd(aInfoEve,{"47","Baixa de evento por glosa referentes a eventos ocorridos no mês " } )
aAdd(aInfoEve,{"48","Baixa de evento por glosa referentes a eventos ocorridos no mês n-1 " } )
aAdd(aInfoEve,{"49","Baixa de evento por glosa referentes a eventos ocorridos no mês n-2 " } )
aAdd(aInfoEve,{"50","Baixa de evento por glosa referentes a eventos ocorridos no mês n-3 " } )
aAdd(aInfoEve,{"51","Baixa de evento por glosa referentes a eventos ocorridos no mês n-4 " } )
aAdd(aInfoEve,{"52","Baixa de evento por glosa referentes a eventos ocorridos no mês n-5 " } )
aAdd(aInfoEve,{"53","Baixa de evento por glosa referentes a eventos ocorridos no mês n-6 " } )
aAdd(aInfoEve,{"54","Baixa de evento por glosa referentes a eventos ocorridos no mês n-7 " } )
aAdd(aInfoEve,{"55","Baixa de evento por glosa referentes a eventos ocorridos no mês n-8 " } )
aAdd(aInfoEve,{"56","Baixa de evento por glosa referentes a eventos ocorridos no mês n-9 " } )
aAdd(aInfoEve,{"57","Baixa de evento por glosa referentes a eventos ocorridos no mês n-10 " } )
aAdd(aInfoEve,{"58","Baixa de evento por glosa referentes a eventos ocorridos no mês n-11 " } )
aAdd(aInfoEve,{"59","Baixa de evento por glosa referentes a eventos ocorridos no mês n-12 " } )
aAdd(aInfoEve,{"60","Baixa de evento por glosa referentes a eventos ocorridos no mês n-13 e anteriores a data" } )
aAdd(aInfoEve,{"65","Outras recuperações referentes a eventos ocorridos no mês " } )
aAdd(aInfoEve,{"66","Outras recuperações referentes a eventos ocorridos no mês n-1 " } )
aAdd(aInfoEve,{"67","Outras recuperações referentes a eventos ocorridos no mês n-2 " } )
aAdd(aInfoEve,{"68","Outras recuperações referentes a eventos ocorridos no mês n-3 " } )
aAdd(aInfoEve,{"69","Outras recuperações referentes a eventos ocorridos no mês n-4 " } )
aAdd(aInfoEve,{"70","Outras recuperações referentes a eventos ocorridos no mês n-5 " } )
aAdd(aInfoEve,{"71","Outras recuperações referentes a eventos ocorridos no mês n-6 " } )
aAdd(aInfoEve,{"72","Outras recuperações referentes a eventos ocorridos no mês n-7 " } )
aAdd(aInfoEve,{"73","Outras recuperações referentes a eventos ocorridos no mês n-8 " } )
aAdd(aInfoEve,{"74","Outras recuperações referentes a eventos ocorridos no mês n-9 " } )
aAdd(aInfoEve,{"75","Outras recuperações referentes a eventos ocorridos no mês n-10 " } )
aAdd(aInfoEve,{"76","Outras recuperações referentes a eventos ocorridos no mês n-11 " } )
aAdd(aInfoEve,{"77","Outras recuperações referentes a eventos ocorridos no mês n-12 " } )
aAdd(aInfoEve,{"78","Outras recuperações referentes a eventos ocorridos no mês n-13 e anteriores a essa data " } )*/

nPos := ascan( aInfoEve, {|x| x[1] == allTrim(cCodigo) } )

if ( nPos > 0 )
	cRetorno := aInfoEve[nPos][2]
endif

Return( IIf(lRetLogico, !Empty(cRetorno), cRetorno) )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRIEVCE

Funcao que cria os demais itens do quadro Movimentação de COntraprestação de Corresponsabilidade cedida

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRIEVCE(cCodOpe,cCodObr,cCdComp,cAnoCmp)
	Local cRefere	:= B3DRefere()
	Local nFor		:= 0
	Local lRet		:= .T.
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cCdComp	:= ""
	Default cAnoCmp	:= ""

	//Insere os demais itens no quadro
	For nFor := 33 TO 79

		// Descarta códigos de 61 a 64 que nao existem	
		If nFor >= 61 .and. nFor <= 64
			Loop
		EndIf

		//Monta o where para verificar se existe o item no quadro
		cWhrQuadro := GetWhrQuadro("B36",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND B36_CODIGO = '"+StrZero(nFor,2)+"' "

		//Verifica se ja foi inserido algum item no quadro
		If !ExisteEveInd(cWhrQuadro)
			//Vou inserir o vencto nao encontrado
			InsereEveInd(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,StrZero(nFor,2))

		EndIf
		
	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteEveInd

Funcao verifica se existe um evento no quadro Movimentação de COntraprestação de Corresponsabilidade cedida

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteEveInd(cWhrQuadro)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local lRet		:= .F.
	Default cWhrQuadro	:= ""

	If !Empty(cWhrQuadro)

		cSql := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("B36") + " WHERE " + cWhrQuadro
		cSql := ChangeQuery(cSql)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliTrb,.F.,.T.)

		If !(cAliTrb)->(Eof())
			lRet := .T.
		EndIf

		(cAliTrb)->(dbCloseArea())

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InsereEveInd

Funcao grava itens na tabela de Movimentação de COntraprestação de Corresponsabilidade cedida

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Static Function InsereEveInd(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,cCodigo)
	Default cCodOpe	:= ""
	Default cCodObr	:= ""
	Default cAnoCmp	:= ""
	Default cRefere	:= ""
	Default cCdComp	:= ""
	Default cCodigo := ""

	If !Empty(cCodigo)
		RecLock("B36",.T.)
		B36->B36_FILIAL := xFilial("B36")
		B36->B36_CODOPE := cCodOpe
		B36->B36_CODOBR := cCodObr
		B36->B36_ANOCMP := cAnoCmp
		B36->B36_REFERE := cRefere
		B36->B36_CDCOMP := cCdComp
		B36->B36_CODIGO := cCodigo
		B36->B36_VLMES1	:= 0 //Val(cCodigo)
		B36->B36_VLMES2 := 0 //Val(cCodigo)*2
		B36->B36_VLMES3 := 0 //Val(cCodigo)*3
		B36->B36_STATUS := "1"
		msUnLock()
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B36DesEve

Retorna a descrição

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
Function B36DesEve()
	Local cDesCon := ""
	Local cCodigo := ""

	If INCLUI
		cDesCod := ''
	Else
		cCodigo := B36->B36_CODIGO 
		cDesCod := getInCdECE( cCodigo, .F. ) 
	EndIf
	
Return cDesCod

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getValCom

Retorna descrição para o combo

@author José Paulo de Azevedo
@since 02/05/2019
/*/
//--------------------------------------------------------------------------------------------------
function getValCom()

local cRetorno:=""

cRetorno:="33=Novos avisos referentes a eventos ocorridos no mês;34=Novos avisos referentes a eventos ocorridos no mês n-1;35=Novos avisos referentes a eventos ocorridos no mês n-2;"
cRetorno+="36=Novos avisos referentes a eventos ocorridos no mês n-3;37=Novos avisos referentes a eventos ocorridos no mês n-4;38=Novos avisos referentes a eventos ocorridos no mês n-5;"
cRetorno+="39=Novos avisos referentes a eventos ocorridos no mês n-6;40=Novos avisos referentes a eventos ocorridos no mês n-7;41=Novos avisos referentes a eventos ocorridos no mês n-8;"
cRetorno+="42=Novos avisos referentes a eventos ocorridos no mês n-9;43=Novos avisos referentes a eventos ocorridos no mês n-10;44=Novos avisos referentes a eventos ocorridos no mês n-11;"
cRetorno+="45=Novos avisos referentes a eventos ocorridos no mês n-12;46=Novos avisos referentes a eventos ocorridos no mês n-13 e anteriores a essa data;"

//---------------------------------------------------------------------------------------
	/*Informações sobre Baixa por Glosas e Outras Recuperações,	foram removidas para a 
	  vigência de 2022. */

	/* 47 ao 60 - Total por Glosa reconhecidas no Mês (todos os códigos) 
	   65 ao 78 - Total de Outras Recuperações Reconhecidas no Mês (todos os códigos)*/
//---------------------------------------------------------------------------------------

/*cretorno+="47=Baixa de evento por glosa referentes a eventos ocorridos no mês;"
cRetorno+="48=Baixa de evento por glosa referentes a eventos ocorridos no mês n-1;49=Baixa de evento por glosa referentes a eventos ocorridos no mês n-2;50=Baixa de evento por glosa referentes a eventos ocorridos no mês n-3;"
cRetorno+="51=Baixa de evento por glosa referentes a eventos ocorridos no mês n-4;52=Baixa de evento por glosa referentes a eventos ocorridos no mês n-5;53=Baixa de evento por glosa referentes a eventos ocorridos no mês n-6;"
cRetorno+="54=Baixa de evento por glosa referentes a eventos ocorridos no mês n-7;55=Baixa de evento por glosa referentes a eventos ocorridos no mês n-8;56=Baixa de evento por glosa referentes a eventos ocorridos no mês n-9;"
cRetorno+="57=Baixa de evento por glosa referentes a eventos ocorridos no mês n-10;58=Baixa de evento por glosa referentes a eventos ocorridos no mês n-11;59=Baixa de evento por glosa referentes a eventos ocorridos no mês n-12;"
cRetorno+="60=Baixa de evento por glosa referentes a eventos ocorridos no mês n-13 e anteriores a data;"
cRetorno+="65=Outras recuperações referentes a eventos ocorridos no mês;66=Outras recuperações referentes a eventos ocorridos no mês n-1;"
cRetorno+="67=Outras recuperações referentes a eventos ocorridos no mês n-2;68=Outras recuperações referentes a eventos ocorridos no mês n-3;69=Outras recuperações referentes a eventos ocorridos no mês n-4;"
cRetorno+="70=Outras recuperações referentes a eventos ocorridos no mês n-5;71=Outras recuperações referentes a eventos ocorridos no mês n-6;72=Outras recuperações referentes a eventos ocorridos no mês n-7;"
cRetorno+="73=Outras recuperações referentes a eventos ocorridos no mês n-8;74=Outras recuperações referentes a eventos ocorridos no mês n-9;75=Outras recuperações referentes a eventos ocorridos no mês n-10;"
cRetorno+="76=Outras recuperações referentes a eventos ocorridos no mês n-11;77=Outras recuperações referentes a eventos ocorridos no mês n-12;78=Outras recuperações referentes a eventos ocorridos no mês n-13 e anteriores a essa data;"*/


Return(cRetorno)
