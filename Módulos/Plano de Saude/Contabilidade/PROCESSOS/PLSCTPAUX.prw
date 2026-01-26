#include 'protheus.ch'
#include 'topconn.ch'

static lPLSVLDB5F := findFunction("PLSVLDB5F")
static arryDET    := {}

/*/{Protheus.doc} plctpBA1 
busca beneficiario e produto

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpBA1(cMatric, cMatric2)
local cPlano     := ''
local cVerSao    := ''
local cCodPla    := ''
local cOpeOri    := ''
local cCodInt    := ''
local cBi3ModPag := ''
local cBi3ApoSrg := ''
local cBi3TipCon := ''
local cBi3Tipo   := ''
local cBi3CodSeg := ''
local cBi3TpBen  := ''
local cTipoBG9   := ''
local cPatroc    := ''
local cGruOpe    := ''
local cContac    := ''
local cMatUsu    := ''
local lBA1Found  := .t.
local aRet       := {}

default cMatric2 := ''

if cMatric <> BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
    
    BA1->(dbSetOrder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
    lBA1Found := BA1->( msSeek(cMatric) )

    if ! lBA1Found .and. ! empty(cMatric2)
		
        lBA1Found := BA1->( msSeek(cMatric2, .f.) )
		
        if ! lBA1Found	
			BA1->(dbSetOrder(5)) //BA1_FILIAL+BA1_MATANT+BA1_TIPANT
			lBA1Found := BA1->( msSeek(cMatric2, .f.) )
        endIf

    endIf
endIf

if lBA1Found

    cMatUsu := BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)
    
    BA3->(dbSetOrder(1)) //BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
    BA3->( msSeek( xFilial("BA3") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC) ) )

    if empty(BA1->BA1_CODPLA)

        cPlano	:= BA3->(BA3_CODPLA + BA3_VERSAO)
        cCodPla := BA3->BA3_CODPLA
        cCodInt := BA3->BA3_CODINT
        cVerSao := BA3->BA3_VERSAO

    else
        
        cPlano	:= BA1->(BA1_CODPLA + BA1_VERSAO)
        cCodPla := BA1->BA1_CODPLA
        cCodInt := BA1->BA1_CODINT
        cVerSao := BA1->BA1_VERSAO

    endIf

    cOpeOri := BA1->BA1_OPEORI
    
    BI3->(dbSetOrder(1)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
    if BI3->( msSeek( xFilial("BI3") + cCodInt + cCodPla + cVerSao ) )

        cBi3ModPag := BI3->BI3_MODPAG
        cBi3ApoSrg := BI3->BI3_APOSRG
        cBi3TipCon := BI3->BI3_TIPCON
        cBi3Tipo   := BI3->BI3_TIPO
        cBi3CodSeg := BI3->BI3_CODSEG
        cBi3TpBen  := BI3->BI3_TPBEN

    endIf
    
    cTipoBG9 := plctpBG9()
    
    aRet    := plctpBQC()
    cPatroc := aRet[1]
    cContac := aRet[2]
    cGruOpe	:= plctpBA0(cOpeOri)

 endIf   

return( { cPlano, cCodPla, cCodInt, cBi3ModPag, cBi3ApoSrg, cBi3TipCon, cBi3Tipo, cBi3CodSeg, cBi3TpBen, cTipoBG9, cPatroc, cContac, cGruOpe, lBA1Found, cMatUsu, cOpeOri } )

/*/{Protheus.doc} plctpBG9 
posiciona na empresa                                    

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpBG9()

if BG9->(BG9_CODINT+BG9_CODIGO) <> BA1->(BA1_CODINT+BA1_CODEMP)

    BG9->(dbSetOrder(1))//BG9_FILIAL+BG9_CODINT+BG9_CODIGO+BG9_TIPO
    BG9->( msSeek( xFilial('BG9') + BA1->(BA1_CODINT + BA1_CODEMP) ) )

endIf

return(BG9->BG9_TIPO)

/*/{Protheus.doc} plctpBQC 
posiciona na empresa                                    

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpBQC()

if BQC->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB) <> xFilial('BGQ') + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)

    BQC->(dbSetOrder(1))//BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB
    BQC->( msSeek( xFilial('BQC') + BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) ) )

endIf

return( { BQC->BQC_PATROC, BQC->BQC_CONTAC } )

/*/{Protheus.doc} plctpBA0 
grupo operadora

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpBA0(cOpeOri)

if BA0->(BA0_FILIAL+BA0_CODIDE+BA0_CODINT) <> xFilial('BGQ') + cOpeOri

    BA0->(dbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
    BA0->( msSeek( xFilial('BA0') + cOpeOri ) )

endIf

return(BA0->BA0_GRUOPE)

/*/{Protheus.doc} plctpBAU 
busca beneficiario e produto

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpBAU(cCodRDA)
local cBauEst	 := ''
local cBauTipPre := ''
local cBauCopCre := ''
local cBauRecPro := ''
local cBauTPPag  := ''
local cOpeRda    := ''

BAU->(dbSetOrder(1))//BAU_FILIAL+BAU_CODIGO

if BAU->(msSeek( xFilial('BAU') + cCodRDA ) )

    cBauEst		:= BAU->BAU_EST
    cBauTipPre	:= BAU->BAU_TIPPRE
    cBauCopCre	:= BAU->BAU_COPCRE
    cBauRecPro	:= BAU->BAU_RECPRO
    cOpeRda     := BAU->BAU_CODOPE

    if empty(cOpeRda)
        cOpeRda := plsIntPad()
    endIf
    
    //0 - free-for-service 1 - Captation 2 - Performance 3 - Global
    if BAU->( fieldPos("BAU_TPPAG") ) > 0 
        cBauTPPag := BAU->BAU_TPPAG
    endIf

endIf

return( { cBauEst, cBauTipPre, cBauCopCre, cBauRecPro, cBauTPPag, cOpeRda } )

/*/{Protheus.doc} plctpBR8 
busca procedimento

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpBR8(cCodPad, cCodPro)
local cClasse := ''
local cTpProc := ''

BR8->(dbSetOrder(1))//BR8_FILIAL+BR8_CODPAD+BR8_CODPSA+BR8_ANASIN

if BR8->(msSeek( xFilial('BR8') + cCodPad + cCodPro ) )  
	cClasse	:= BR8->BR8_CLASSE
	cTpProc	:= BR8->BR8_TPPROC
endIf

return( { cClasse, cTpProc } )

/*/{Protheus.doc} plctpTPP 

TIPO DE PRESTADOR                                                          						
Analisa o vinculo do prestador com a cooperativa e a classe do procedimento						
executado. As opcoes sao:                                                  						
0 - Nulo --> Para atendimento pelo SUS ou Exterior                         						
1 - Proprio/Assalariado --> Para Funcionarios em atendimento a consultas   						
2 - Cooperados --> Para Cooperados em atendimento a consultas              						
3 - Nao Cooperados --> Para Nao Cooperados, qualquer atendimento           						
4 - Rede Propria --> Para Cooperados, qualquer atendimento exceto consultas	
5 - Rede Conveniada --> Para Credenciados, todos atendimentos 								 	
6 - Intecambio --> Atendimento em Intercambio 
@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpTPP(cBauCopCre, cBauRecPro, cBauTipPre, cCtpl14, cCtpl04, cBauEst, cCodPad, cCodPro)

local cBusca := ''

do case

	// SUS e Exterior
	case allTrim(BAU->BAU_CODIGO) $ cCtpl04 .or. cBauEst == 'EX'
		
		cBusca	+= '0'

	// Credenciados e não é recurso próprio
	case cBauCopCre $ '2' .and. cBauRecPro $ '0' .and. ! (cBauTipPre $ cCtpl14)
		
		cBusca	+= '5'

	// Intercambio
	case cBauTipPre $ cCtpl14
		
		cBusca	+= '6'

	// Nao Cooperados - Todas as classes...
	case cBauCopCre $ '4'
		
		cBusca	+= '3'

	// Se Funcionarios ou Cooperados 
	case cBauCopCre $ '1/3'
		
		cBusca	+= iIf(cBauCopCre $ '3', '1', '2' ) 
	
    // Credenciados e é recurso próprio
	Case cBauCopCre $ '2' .and. cBauRecPro $ '1' 

		cBusca	+= '4'
	
	// Captation
	case cBauCopCre $ '7'

		cBusca	+= cBauCopCre

	// Performance
	case cBauCopCre $ '8'

		cBusca	+= cBauCopCre

	// Global
	case cBauCopCre $ '9'
		
		cBusca	+= cBauCopCre
		
	// Outras opcoes
	otherWise
		
		cBusca	+= ' '
		
endCase

return(cBusca) 

/*/{Protheus.doc} plctpMDC 

MODALIDADE DE COBRANCA                                      
Verifica se a modalidade eh Pre-Pagamento, senao classifica 
direto em demais modalidades.                               
1 - Pre-Pagamento                                           
2 - Demais Modalidades                                      

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpMDC(cBi3ModPag)
return( iIf( allTrim(cBi3ModPag) $ '1', '1', '2' ) )

/*/{Protheus.doc} plctpTPA 

TIPO DE ATO                                                          
Analisa os tipos de atos conforme o tipo de vinculo com a operadora. 
Em definicao com a Minou (Tubarao) em 09/02/06, fica estabelecido    
os seguintes criterios para classificacao contabil dos tipos de atos:
0 - Ato Cooperativo Auxiliar --> Quando a RDA for um Credenciado.    
1 - Ato Cooperativo Principal --> Quando a RDA for um Cooperado ou um Funcionario.                                                   
2 - Ato Nao Cooperativo --> Quando a RDA for Nao Cooperado.          
                                                                     
ATENCAO: EM CASOS DE INTERCAMBIO, SERA MANTIDO O TIPO DE ATO PROVE-  
NIENTE DO ARQUIVO DE INTERCAMBIO INFORMADO NA OPERADORA ORIGEM VIA   
PTU A500, GRAVADO NO CAMPO BD6_CODATO.                               
** VALIDAR ESTA REGRA COM A OPERADORA QUE FOR IMPLANTAR **        

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpTPA(cBauTipPre, cBauCopCre, cBauRecPro, cCodAto, cCtpl14, cCodLDP, cCtpl12, cAlias)
local lUnimed   := getNewPar('MV_PLSUNI','0') == '1'
local cBusca    := ''

default cBauTipPre  := ''
default cBauCopCre  := ''
default cBauRecPro  := ''
default cCodAto     := ''
default cCtpl14     := ''
default cCodLDP     := ''
default cCtpl12     := ''
default cAlias      := ''

if ! empty(cAlias)

    if empty(cCodAto)
        cBusca	+= &(cAlias+'->'+cAlias+'_ATOCOO')
    else
        cBusca	+= cCodAto
    endIf

else

    do case

        // Se não for cooperativas (Unimeds) classifica como Ato Nao Cooperativo
        case ! lUnimed

            cBusca	+= '2'	

        // Intercambio digitado manualmente
        case cBauTipPre $ cCtpl14 .and. cCodLDP $ cCtpl12

            do case
                case cBauCopCre $ '1,3'
                    cBusca	+= '1'
                case cBauCopCre $ '2'
                    cBusca	+= '0'
                case cBauCopCre $ '4'
                    cBusca	+= '2'
                otherWise
                    cBusca	+= ' '
            endCase
            
        // Intercambio
        case cBauTipPre $ cCtpl14
            
            //Inclusão de ponto de entrada para definição específica de 
            //tratamento a tipo de ato. Envia variável cBusca e espera  
            //retorno desta, classificando o tipo de ato, que pode ser: 
            //1 - Ato Cooperativo Principal                             
            //0 - Ato Cooperativo Auxiliar                              
            //2 - Ato Não Cooperativo		                                 
            if  empty(cCodAto) .and. existBlock("PLSCTP20")
                cBusca := execBlock("PLSCTP20",.f.,.f., { cBusca } )
            else 
                // Necessário conversão do preenchimento do BD6_CODATO: 1=Ato Cooperativo Principal;2=Ato Cooperativo Acessorio;3=Ato Nao Cooperativo
                cBusca += iIf(cCodAto == '2', '0', iIf(cCodAto == '3', '2', cCodAto) )
            endIf
        
        // Cooperados e funcionarios OU Credenciados e Recursos Próprios
        case cBauCopCre $ '1,3' .or. ( cBauCopCre $ '2' .and. cBauRecPro $ '1' )

            cBusca	+= '1'
        
        // Credenciados
        case cBauCopCre $ '2'

            cBusca	+= '0'
        
        // Nao Cooperados
        case cBauCopCre $ '4'

            cBusca	+= '2'
        
        // Opcoes nao previstas
        otherWise
            
            cBusca	+= ' '

    endCase

endIf

return(cBusca)

/*/{Protheus.doc} plctpPLR 

PLANO REGULAMENTADO                                   
Analisa se o plano do usuario e regulamentado. Opcoes:
0 - Nao                                               
1 - Sim                                               

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpPLR(cBi3ApoSrg)
return iIf( cBi3ApoSrg == '1', '1', '0' )

/*/{Protheus.doc} plctpPLC 

TIPO DE PLANO / CONTRATO                                     
Analisa o tipo de plano / contrato do usuario. As opcoes sao:
1 - Individual / Familiar                                    
2 - Coletivo Empresarial                                     
3 - Coletivo por Adesáo                                      

BI3_TIPO => 1=Pessoa Fisica;2=Pessoa Juridica;3=Ambas | 1 - Individual / Familiar                                             

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpPLC(cBi3Tipo, cBi3TipCon)
local cBusca := ''

if cBi3Tipo == "1"	
	cBusca += "1"	
else

	if BII->( msSeek( xFilial('BII') + cBi3TipCon ) ) 
		cBusca += BII->BII_TIPPLA
	else
		cBusca += '2'	
	endIf
	
endIf

return(cBusca)

/*/{Protheus.doc} plctpPTC 

PATROCINIO                                              
Analisa se o plano tem patrocinio ou nao. As opcoes sao:
0 - Sem patrocinio                                      
1 - Com patrocinio                                      
Plano tipo Ambos e contrato Pessoa Fisica ou produto Individual/Familiar nunca tera patrocinio

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpPTC(cBi3Tipo, cTipoBG9, cPatroc)
local cBusca := ''

if ( cBi3Tipo == "3" .and. cTipoBG9 == "1" ) .or. cBi3Tipo == '1'
	
    cBusca	+= "0"

// Plano coletivo, forca que o campo esteja preenchido ou retorna sem patrocinio
else
	cBusca	+= iIf( cPatroc == '1', '1', '0' )
endIf

return(cBusca)

/*/{Protheus.doc} plctpSEG 

SEGMENTACAO                                                
Segue a segmentacao conforme o cadastro no proprio produto.

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpSEG(cBi3CodSeg)
return(cBi3CodSeg)

/*/{Protheus.doc} plctpTPB 

TIPO DO BENEFICIARIO                                                    
Verifica conteudo do campo BG9_XTPBEN ( Char(1) ), especifico que indica
o tipo de beneficiario do contrato. As opcoes sao:                      
1 - BE  - Beneficiario Exposto                                           
2 - ENB - Exposto Nao Beneficiario                                      
3 - BNE - Beneficiario Nao Exposto                                      
4 - PS  - Prestacao de Servicos
5 - BF  - Benef. Funcionário;
6 - BE  - Habitual ( nao vem da BI3 )

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpTPB(cBi3TpBen, dData, lB5F, cOpeDES)
local cBusca := ''

default lB5F    := .t.
default cOpeDES := ''

cBusca := cBi3TpBen //BI3->BI3_TPBEN			

//tratamento para habitual
if lB5F .and. ! empty(cOpeDES)
    
    if lPLSVLDB5F .and. PLSVLDB5F( BA1->( BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO ), dData, nil, cOpeDES, BA1->BA1_OPEORI)
        cBusca := '6'
    endIf	

endIf    

return(cBusca)

/*/{Protheus.doc} plctpCRD 

CLASSE DA RDA
Assume a classe da RDA configurada em RDA Cadastro.
Inclusão de tratamento específico via parâmetro, para necessidade de clientes

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpCRD(cCodRDA, cCtpl19, cCtpl20, cBauTipPre)
local cBusca := ''

if allTrim(cCodRDA) $ cCtpl19
	cBusca += cCtpl20
else
	cBusca += cBauTipPre
endIf

return(cBusca)


/*/{Protheus.doc} plctpTCF 

tipo do contrato para faturamento
Este campo analisa condicoes para classificar o tipo de contrato, 
conforme segue:                                                   
1 - Demais Modalidades (CO) --> alterado para programa CTBPLS11.  
2 - Mensalidade PP                                                
3 - Mensalidade CO                                                
4 - CO em PP        } estas situações são descartadas             
5 - Participacao    } neste programa. RC.   

@author  PLS TEAM
@version P12
@since   02.12.16
/*/
function plctpTCF(cAlias, cBi3ModPag, cCtPl07, cCtpl13, cTipCo)
local lMensal	:= .f.
local cRet      := ''
local cBusca    := ''

default cAlias      := ''
default cBi3ModPag  := ''
default cCtPl07     := ''
default cCtpl13     := ''
default cTipCo      := ''

if ! empty(cTipCo)

	do case
		
		// Lancamentos exclusivos de Custo Operacional em contrato Demais Modalidades
		Case cTipCo $ '0/5'
		
			cBusca += '1'
			
		// Lancamentos exclusivos de Custo Operacional -> 1->Custo Operacional / 3->Taxa Adm.s/Custo Oper.
		Case cTipCo $ '1/3'
		
			cBusca += '4'
			
		// Lancamentos exclusivos de Co-Participação -> 2->Co-Participação / 4->Taxa Adm.s/Co-Participação
		Case cTipCo $ '2/4'
		
			cBusca += '5'
			
		otherWise
		
			cBusca	+= 'X'
			
	EndCase

else

    // Posiciona para tratamento a conta fixa no BFQ
    if allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) <> allTrim(BFQ->BFQ_PROPRI)+allTrim(BFQ->BFQ_CODLAN)
        BFQ->(dbSetOrder(1))
        BFQ->(msSeek(xFilial('BFQ')+PlsIntPad()+allTrim(&(cAlias+'->'+cAlias+'_CODTIP')),.F.))
    endIf

    do case
        
        // Tratamento a conta fixa no BFQ para qualquer tipo de lançamento, exceto Outros Débitos/Créditos
        Case ! empty(BFQ->BFQ_CONTA) .and. ! allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '113,128,129,130,131,132,135,136,180'
            
            cRet := BFQ->BFQ_CONTA

        // Lancamentos exclusivos de Custo Operacional -> retorna Demais modalidades (CO)
        Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '104,127,134,137,138,139,140,141,142,143,144,145,156,157,158,159,160,161,162,163,164,165,166,167'
            
            // 104	Custo Operac. Servicos Medicos			// 127- Custo Operacional Serv.Acessorios
            // 134- Custo Operacional outros servicos		// 137-	Producao de coop / PF
            // 138-	Producao de coop / PJ					// 139- Servico coop PF outras operadoras
            // 140-	Servico coop PJ outras operadoras		// 141-	SERV.AUXILI.DE DIAGN. E TER
            // 142-	SERV.AUXILIARES OUTRAS UNIM				// 143-	Prod nao cooperados
            // 144- Prod nao coop outras operadoras			// 145- Custos em servicos proprios
            // 156- Taxa custo oper serv medicos			// 157- Taxa adm serv acessorios
            // 158- Taxa outros servicos					// 159- Taxa prod coop / PF
            // 160- Taxa prod coop / PJ						// 161- Taxa serv coop PF / outras operadoras
            // 162- Taxa serv coop PJ / outras operadoras	// 163- Taxa SADT
            // 164- Taxa SADT / outras operadoras			// 165- Taxa prod nao coop
            // 166- Taxa prod nao coop / outras operadoras	// 167- Taxa custo serv proprios
            cBusca	+= '1'
            
        // Lancamentos de Mensalidade -> retorna 2-Mensalidade PP ou 3-Mensalidade C.O.
        Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '101,107,110,118,190,191,189' .or.;
            (allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '102,133,146' .and. ! allTrim(&(cAlias+'->'+cAlias+'_CODEVE')) $ cCtPl07)
            
            // 101- Mensalidade								// 102- Opcional
            // 107- Cartao de Identificacao					// 110- Valor do Agravo
            // 118- Mensalidade Retroativa                  // 146- Opcional Retroativo
            // 133- Taxa de Adesao do Opcional				// 190- Diferenca Reajuste Mensalidade 
            cBusca	+= iIf( allTrim(cBi3ModPag) $ '1', '2', '3' )
            lMensal	:= .t.
            
        // Opcional Usimed
        Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '102,133,146' .and. allTrim(&(cAlias+'->'+cAlias+'_CODEVE')) $ cCtPl07
            
            // 102- Opcional		// 133- Taxa de Adesao do Opcional		// 146- Opcional Retroativo
            BI3->(dbSetOrder(1)) //BI3_FILIAL+BI3_CODINT+BI3_CODIGO+BI3_VERSAO
            if BI3->( msSeek( xFilial("BI3") + plsIntPad() + allTrim( &(cAlias+'->'+cAlias+'_CODEVE') ) ) )
                cRet := BI3->BI3_CONTA
            endIf    
            
        // Taxa de Inscricao -> retorna 2-Mensalidade PP ou 3-Mensalidade CO
        Case allTrim( &(cAlias+'->'+cAlias+'_CODTIP') ) $ '103'
        
            // 103- Taxa de Inscricao
            cBusca	+= iIf( allTrim(cBi3ModPag) $ '1', '2', '3' )
            
        // revisado RN136 - 31/10/07 - RC ==> CREIO NECESSITAR ALTERACAO, VERIFICAR REGRA COM TULIO
        // Lancamentos de Taxa Adm sobre compra de procedimento - trata somente se a conta for fixa
        Case allTrim( &(cAlias+'->'+cAlias+'_CODTIP') ) $ '117,122,125'
        
            // 117- Taxa Administrativa
            // 122- Taxa administrativa compras pagamento no ato
            // 125- Taxa administrativa compras pagamento a faturar
            // Se for conta fixa para taxa administrativa, pega a conta via parametro
            if ! empty(cCtpl13)
                cRet := cCtpl13
            else
                cBusca += ' '
            endIf

        // Outros Debitos / Creditos diversos -> busca conta na tabela BSQ ou BSP
        Case subs(&(cAlias+'->'+cAlias+'_CODTIP'),1,1) == '9' .or. allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '111,113,128,129,130,131,132,135,136,180'
        
            // 111- Juros do Mes Anterior
            // 113- Debitos servicos medicos		// 128- Debito servicos acessorios
            // 129- Credito servicos medicos		// 130- Credito servicos acessorios
            // 131- Credito odontologico			// 132- Debito odontologico
            // 135- Debito outros servicos			// 136- Credito outros servicos
            // 180- Debito servicos medicos			// Codigo do Tipo iniciando com '9' é lançto usuário
            if ! empty(BSQ->BSQ_CONTA)
            
                cRet := BSQ->BSQ_CONTA
            
            else

                if allTrim(BSP->BSP_CODSER) <> allTrim(&(cAlias+'->'+cAlias+'_CODEVE'))
                    BSP->(dbSetOrder(1))
                    BSP->(msSeek(xFilial('BSP')+allTrim(&(cAlias+'->'+cAlias+'_CODEVE')),.F.))
                endIf

                if ! empty(BSP->BSP_CONTA)
                    
                    cRet := BSP->BSP_CONTA
                    
                elseIf ! empty(BFQ->BFQ_CONTA)
                    
                    cRet := BFQ->BFQ_CONTA
                    
                else

                    cRet := 'C->Eve:'+allTrim(&(cAlias+'->'+cAlias+'_CODEVE'))

                endIf

            endIf
            
        // revisado RN136 - 31/10/07 - RC ==> NECESSITA ALTERACAO, AGUARDANDO DEFINIÇÃO TULIO
        // Reembolso de livre escolha -- arquivos BKD / BKE
        Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '108'

            // 108- Reembolso de livre escolha
            cBusca += ' '
            
        // revisado RN136 - 31/10/07 - RC ==> NECESSITA ALTERACAO, AGUARDANDO REGRA CLIENTES
        // Via de boleto -- arquivo BEE
        Case allTrim(&(cAlias+'->'+cAlias+'_CODTIP')) $ '109'
        
            // 109- Via de boleto
            cBusca += ' '
            
        otherWise

            cBusca	+= ' '
            
    EndCase

endIf

return( { lMensal, cRet, cBusca } )

/*/{Protheus.doc} plLogDet
Log detalhado das combinacoes.
@type function
@author TOTVS
@since 26/06/19
@version 1.0
/*/
function plLogDet(cConteudo, cFieldBBH, cField, cDesc, cFun, cRotina, lError)
local nI 	:= 0
local nTam 	:= 0
local nPos	:= 0

default cConteudo	:= ''
default cFieldBBH	:= ''
default cField		:= ''
default cDesc		:= ''
default cFun		:= ''
default cRotina     := ''
default lError		:= .f.

if ! empty(cFieldBBH)
	
	if len(arryDet) > 0
		nPos := arryDet[ len(arryDet), 6 ] 
		nTam := len(cConteudo) - nPos
		cAux := subStr(cConteudo, nPos + 1, nTam)
	else
		cAux := cConteudo
	endIf

	aadd(arryDet, { cDesc, cFun, cFieldBBH, cAux, cField, len(cConteudo) } )

else

	if lError
		
		for nI := 1 to len(arryDet)		
			PlGrvLog(arryDet[nI,1] + '|' + arryDet[nI,2] + '|' + arryDet[nI,3] + '|' + arryDet[nI,4] + '|' + arryDet[nI,5], cRotina, 1 )
		next	

	endIf

	arryDet := {}

endIf

return
