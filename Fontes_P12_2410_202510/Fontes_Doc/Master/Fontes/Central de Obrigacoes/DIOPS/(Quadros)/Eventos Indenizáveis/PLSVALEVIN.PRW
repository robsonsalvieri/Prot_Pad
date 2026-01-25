#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI01

Funcao criada para validar Critica EI01
Valida o código do tipo de evento utilizado

@return lRetorno .F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDEVI01()
Local lRetorno	:= .F.

lRetorno	:= !Empty( getInfoCdEve( B8L->B8L_CODIGO ) )

Return lRetorno


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI02

Funcao criada para validar Critica EI02
Somatório dos Novos Avisos de Eventos com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDEVI02()
Local lRetorno	:= .F.
Local cWhere 	:= " AND B8L_CODIGO BETWEEN '33' AND '46' "
Local aConta	:= {'411111011','411111021','411111031','411111041','411111051','411111061','411111017','411111027','411111037','411111047','411111057','411111067','411111081','411121011',;
    '411121021','411121031','411121041','411121051','411121061','411121017','411121027','411121037','411121047','411121057','411121067','411121081','411211011','411211021','411211031',;
    '411211041','411211051','411211061','411211081','411221011','411221021','411221031','411221041','411221051','411221061','411221081','411311011','411311021','411311031','411311041',;
    '411311051','411311061','411311081','411321011','411321021','411321031','411321041','411321051','411321061','411321081','411411011','411411021','411411031','411411041','411411051',;
    '411411061','411411017','411411027','411411037','411411047','411411057','411411067','411411081','411421011','411421021','411421031','411421041','411421051','411421061','411421017',;
    '411421027','411421037','411421047','411421057','411421067','411421081','411511011','411511021','411511031','411511041','411511051','411511061','411511081','411521011','411521021',;
    '411521031','411521041','411521051','411521061','411521081','411611011','411611021','411611031','411611041','411611051','411611061','411611017','411611027','411611037','411611047',;
	'411611057','411611067','411621011','411621021','411621031','411621041','411621051','411621061','411621017','411621027','411621037','411621047','411621057','411621067','411711011',;
	'411711021','411711031','411711041','411711051','411711061','411711017','411711027','411711037','411711047','411711057','411711067','411721011','411721021','411721031','411721041',;
    '411721051','411721061','411721017','411721027','411721037','411721047','411721057','411721067','411911011','411911021','411911031','411911041','411911051','411911061','411911017',;
    '411911027','411911037','411911047','411911057','411911067','411911081','411921011','411921021','411921031','411921041','411921051','411921061','411921017','411921027','411921037',;
    '411921047','411921057','411921067','411921081'}
    
lRetorno	:= PlVldEVIGe(cWhere, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI03

Funcao criada para validar Critica EI03
Somatório de baixas por glosa com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDEVI03()
Local lRetorno	:= .F.
Local cWhere	:= " AND B8L_CODIGO BETWEEN '47' AND '60' " 
Local aConta	:= {'411111012','411111022','411111032','411111042','411111052','411111062','411111082','411121012','411121022','411121032','411121042','411121052','411121062','411121082',;
	'411211012','411211022','411211032','411211042','411211052','411211062','411211082','411221012','411221022','411221032','411221042','411221052','411221062','411221082','411311012',;
	'411311022','411311032','411311042','411311052','411311062','411311082','411321012','411321022','411321032','411321042','411321052','411321062','411321082','411411012','411411022',;
	'411411032','411411042','411411052','411411062','411411082','411421012','411421022','411421032','411421042','411421052','411421062','411421082','411511012','411511022','411511032',;
	'411511042','411511052','411511062','411511082','411521012','411521022','411521032','411521042','411521052','411521062','411521082','411611012','411611022','411611032','411611042',;
	'411611052','411611062','411621012','411621022','411621032','411621042','411621052','411621062','411711012','411711022','411711032','411711042','411711052','411711062','411721012',;
	'411721022','411721032','411721042','411721052','411721062','411911012','411911022','411911032','411911042','411911052','411911062','411911082','411921012','411921022','411921032',;
	'411921042','411921052','411921062','411921082'}

lRetorno	:= PlVldEVIGe(cWhere, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI04

Funcao criada para validar Critica EI04
Somatório de outras recuperações com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDEVI04()
Local lRetorno	:= .F.
Local cWhere	:= " AND B8L_CODIGO BETWEEN '65' AND '78' "
Local aConta	:= {'411111013','411111023','411111033','411111043','411111053','411111063','411111019','411111029','411111039','411111049','411111059','411111069','411121013','411121023',;
	'411121033','411121043','411121053','411121063','411121019','411121029','411121039','411121049','411121059','411121069','411211013','411211023','411211033','411211043','411211053',;
	'411211063','411211019','411211029','411211039','411211049','411211059','411211069','411221013','411221023','411221033','411221043','411221053','411221063','411221019','411221029',;
	'411221039','411221049','411221059','411221069','411311013','411311023','411311033','411311043','411311053','411311063','411311019','411311029','411311039','411311049','411311059',;
	'411311069','411321013','411321023','411321033','411321043','411321053','411321063','411321019','411321029','411321039','411321049','411321059','411321069','411411013','411411023',;
	'411411033','411411043','411411053','411411063','411411019','411411029','411411039','411411049','411411059','411411069','411421013','411421023','411421033','411421043','411421053',;
	'411421063','411421019','411421029','411421039','411421049','411421059','411421069','411511013','411511023','411511033','411511043','411511053','411511063','411511019','411511029',;
	'411511039','411511049','411511059','411511069','411521013','411521023','411521033','411521043','411521053','411521063','411521019','411521029','411521039','411521049','411521059',;
	'411521069','411611013','411611023','411611033','411611043','411611053','411611063','411611019','411611029','411611039','411611049','411611059','411611069','411621013','411621023',;
	'411621033','411621043','411621053','411621063','411621019','411621029','411621039','411621049','411621059','411621069','411711013','411711023','411711033','411711043','411711053',;
	'411711063','411711019','411711029','411711039','411711049','411711059','411711069','411721013','411721023','411721033','411721043','411721053','411721063','411721019','411721029',;
	'411721039','411721049','411721059','411721069','411911013','411911023','411911033','411911043','411911053','411911063','411911019','411911029','411911039','411911049','411911059',;
	'411911069','411921013','411921023','411921033','411921043','411921053','411921063','411921019','411921029','411921039','411921049','411921059','411921069'}

lRetorno	:= PlVldEVIGe(cWhere, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLVLDEVI05

Funcao criada para validar Critica EI11
Somatório de outras recuperações do primeiro mês com o total da Conta Contábil respectiva

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLVLDEVI05()
Local lRetorno	:= .F.
Local cWhere	:= " AND B8L_CODIGO = '79' "
Local aConta	:= {'211111041','211121041','231111041','231121041'} 

lRetorno	:= PlVldEVIGe(cWhere, aConta)

Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlVldEVIGe

Funcao criada para validar Critica do Eventos Indenizáveis

@Parametros recebidos:
cCampo	-> Nome do campo referente ao mês do trimestre que irá validar
aConta	-> Array contendo as contas contábeis que validarão o total dos campos  

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author Roger C
@since 22/11/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlVldEVIGe(cWhere, aConta,oModel)
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
		cCodOpe	:= AllTrim(oModel:GetValue( 'B8LMASTER', 'B8L_CODOPE' )) 
		cCodObr	:= AllTrim(oModel:GetValue( 'B8LMASTER', 'B8L_CODOBR' )) 
		cAnoCmp	:= AllTrim(oModel:GetValue( 'B8LMASTER', 'B8L_ANOCMP' )) 
		cCdComp := AllTrim(oModel:GetValue( 'B8LMASTER', 'B8L_CDCOMP' ))
	EndIf

	cSql := " SELECT SUM(B8L_VLMES1+B8L_VLMES2+B8L_VLMES3) VALOR "
	cSql += "	FROM " + RetSqlName("B8L") 
	cSql += "	WHERE B8L_FILIAL = '" + xFilial("B8L") + "' " 
	cSql += "			AND B8L_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND B8L_CODOBR = '" + cCodObr + "' "
	cSql += "			AND B8L_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND B8L_CDCOMP = '" + cCdComp + "' "
	cSql += cWhere
	cSql += " 			AND D_E_L_E_T_ = ' ' " 	
		
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
	cSql += "	FROM " + RetSqlName("B8A") 
	cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' " 
	cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
	cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
	cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
	cSql += "			AND B8A_CDCOMP = '" + cCdComp + "' "
	cSql += "			AND B8A_CONTA  IN " + cConta + " "
	cSql += " 			AND D_E_L_E_T_ = ' ' " 	
		
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
/*/{Protheus.doc} getInfoCdEve

Retorna descrição do código de Eventos Indenizáveis - tabela de dominio ANS     //esta função deve ser retirada pois o campo de descrição foi descontinuado
																				//não retiramos neste momento pois daria problema para quem não aplicou o pacote de dicionário
@author Roger C
@since 07/12/2017
/*/
//--------------------------------------------------------------------------------------------------
function getInfoCdEve( cCodigo, lRetLogico )

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
aAdd(aInfoEve,{"47","Baixa de evento por glosa referentes a eventos ocorridos no mês " } )
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
aAdd(aInfoEve,{"78","Outras recuperações referentes a eventos ocorridos no mês n-13 e anteriores a essa data " } )
aAdd(aInfoEve,{"79","PEONA " } )

nPos := ascan( aInfoEve, {|x| x[1] == allTrim(cCodigo) } )

if ( nPos > 0 )
	cRetorno := aInfoEve[nPos][2]
endif

Return( IIf(lRetLogico, !Empty(cRetorno), cRetorno) )

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCRIEVIN

Funcao que cria os demais itens do quadro Eventos Indenizáveis 

@author RogerC
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCRIEVIN(cCodOpe,cCodObr,cCdComp,cAnoCmp)
	Local cRefere		:= B3DRefere()
	Local nFor			:= 0
	Local lRet			:= .T.
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
		cWhrQuadro := GetWhrQuadro("B8L",cCodOpe,cCodObr,cAnoCmp,cCdComp)
		cWhrQuadro += " AND B8L_CODIGO = '"+StrZero(nFor,2)+"' "

		//Verifica se ja foi inserido algum item no quadro
		If !ExisteEveInd(cWhrQuadro)
			//Vou inserir o vencto nao encontrado
			InsereEveInd(cCodOpe,cCodObr,cAnoCmp,cRefere,cCdComp,StrZero(nFor,2))

		EndIf
		
	Next nFor

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExisteEveInd

Funcao verifica se existe um evento no quadro Eventos Indenizaveis

@author RogerC
@since 03/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ExisteEveInd(cWhrQuadro)
	Local cSql		:= ""
	Local cAliTrb	:= GetNextAlias()
	Local lRet		:= .F.
	Default cWhrQuadro	:= ""

	If !Empty(cWhrQuadro)

		cSql := "SELECT R_E_C_N_O_ REC FROM " + RetSqlName("B8L") + " WHERE " + cWhrQuadro
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

Funcao grava itens na tabela de Movimentação de Eventos Indenizaveis

@author RogerC
@since 03/01/2018
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
		RecLock("B8L",.T.)
		B8L->B8L_FILIAL := xFilial("B8L")
		B8L->B8L_CODOPE := cCodOpe
		B8L->B8L_CODOBR := cCodObr
		B8L->B8L_ANOCMP := cAnoCmp
		B8L->B8L_REFERE := cRefere
		B8L->B8L_CDCOMP := cCdComp
		B8L->B8L_CODIGO := cCodigo
		B8L->B8L_VLMES1	:= 0 //Val(cCodigo)
		B8L->B8L_VLMES2 := 0 //Val(cCodigo)*2
		B8L->B8L_VLMES3 := 0 //Val(cCodigo)*3
		B8L->B8L_STATUS := "1"
		msUnLock()
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} B8LDesEve

Retorna a descrição do Evento

@author Roger C
@since 01/02/2018
/*/
//--------------------------------------------------------------------------------------------------
Function B8LDesEve()
	Local cDesCon	:= ""
	Local cCodigo	:= ""

	If INCLUI
		cDesCod := ''
	Else
		cCodigo := B8L->B8L_CODIGO 
		cDesCod := getInfoCdEve( cCodigo, .F. ) 
	EndIf
	
Return cDesCod

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetListEve

Retorna descrição do código de Eventos Indenizáveis no Combo - tabela de dominio ANS

@author José Paulo de Azevedo
@since 13/06/2019
/*/
//--------------------------------------------------------------------------------------------------
function GetListEve()

local cInfoEve := ""

cInfoEve:="33=Novos avisos referentes a eventos ocorridos no mês;34=Novos avisos referentes a eventos ocorridos no mês n-1;35=Novos avisos referentes a eventos ocorridos no mês n-2;"
cInfoEve+="36=Novos avisos referentes a eventos ocorridos no mês n-3;37=Novos avisos referentes a eventos ocorridos no mês n-4;38=Novos avisos referentes a eventos ocorridos no mês n-5;"
cInfoEve+="39=Novos avisos referentes a eventos ocorridos no mês n-6;40=Novos avisos referentes a eventos ocorridos no mês n-7;41=Novos avisos referentes a eventos ocorridos no mês n-8;"
cInfoEve+="42=Novos avisos referentes a eventos ocorridos no mês n-9;43=Novos avisos referentes a eventos ocorridos no mês n-10;44=Novos avisos referentes a eventos ocorridos no mês n-11;"
cInfoEve+="45=Novos avisos referentes a eventos ocorridos no mês n-12;46=Novos avisos referentes a eventos ocorridos no mês n-13 e anteriores a essa data;47=Baixa de evento por glosa referentes a eventos ocorridos no mês;"
cInfoEve+="48=Baixa de evento por glosa referentes a eventos ocorridos no mês n-1;49=Baixa de evento por glosa referentes a eventos ocorridos no mês n-2;50=Baixa de evento por glosa referentes a eventos ocorridos no mês n-3;"
cInfoEve+="51=Baixa de evento por glosa referentes a eventos ocorridos no mês n-4;52=Baixa de evento por glosa referentes a eventos ocorridos no mês n-5;53=Baixa de evento por glosa referentes a eventos ocorridos no mês n-6;"
cInfoEve+="54=Baixa de evento por glosa referentes a eventos ocorridos no mês n-7;55=Baixa de evento por glosa referentes a eventos ocorridos no mês n-8;56=Baixa de evento por glosa referentes a eventos ocorridos no mês n-9;"
cInfoEve+="57=Baixa de evento por glosa referentes a eventos ocorridos no mês n-10;58=Baixa de evento por glosa referentes a eventos ocorridos no mês n-11;59=Baixa de evento por glosa referentes a eventos ocorridos no mês n-12;"
cInfoEve+="60=Baixa de evento por glosa referentes a eventos ocorridos no mês n-13 e anteriores a data;65=Outras recuperações referentes a eventos ocorridos no mês;66=Outras recuperações referentes a eventos ocorridos no mês n-1;"
cInfoEve+="67=Outras recuperações referentes a eventos ocorridos no mês n-2;68=Outras recuperações referentes a eventos ocorridos no mês n-3;69=Outras recuperações referentes a eventos ocorridos no mês n-4;"
cInfoEve+="70=Outras recuperações referentes a eventos ocorridos no mês n-5;71=Outras recuperações referentes a eventos ocorridos no mês n-6;72=Outras recuperações referentes a eventos ocorridos no mês n-7;"
cInfoEve+="73=Outras recuperações referentes a eventos ocorridos no mês n-8;74=Outras recuperações referentes a eventos ocorridos no mês n-9;75=Outras recuperações referentes a eventos ocorridos no mês n-10;"
cInfoEve+="76=Outras recuperações referentes a eventos ocorridos no mês n-11;77=Outras recuperações referentes a eventos ocorridos no mês n-12;78=Outras recuperações referentes a eventos ocorridos no mês n-13 e anteriores a essa data;"
cInfoEve+="79=PEONA;"

Return(cInfoEve )
