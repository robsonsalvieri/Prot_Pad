#INCLUDE "AGRR840A.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'

Static __nLin := 60
/*/{Protheus.doc} AGRR840A
Função responsável pela geração do relatório MAPA DE PRODUÇÃO E COMERCIALIZAÇÃO DE SEMENTES
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Function AGRR840A()
    Private _cPerg	 := 'AGRR840A'
	Private _aDadosRel := {}

	Private _nPosCtVar	:= 1
	Private _nPosUF 		:= 2
	Private _nPosAPlan	:= 3
	Private _nPosAApro	:= 4
	Private _nPosBruta	:= 5
	Private _nPosBenef	:= 6
	Private _nPosApro	:= 7
	Private _nPosComUf	:= 8
	Private _nPosOutUf	:= 9
	Private _nPosExpor 	:= 10	
	Private _nPosPlaPro	:= 11 
	Private _nPosOutDes	:= 12
	Private _nPosSaldo 	:= 13
	Private _nPosCateg 	:= 14
	Private _nPoskey 	:= 15
	Private _nPosCdCtVar := 16
	
	If !TableInDic("NNM")
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

	If !Pergunte(_cPerg,.T.)
		Return
	EndIf

	oReport := ReportDef()
	oReport:PrintDialog()
Return .t.

/*/{Protheus.doc} ReportDef
Função responsavel por criar o objeto TReport()
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function ReportDef()
	local oSec1 := nil
	local oReport := nil

	Private _oBreak1 := nil
	//Montando o objeto oReport
	oReport := TReport():NEW('AGRR840A', STR0001 , _cPerg, {|oReport|PrintReport(oReport)}, STR0002)	//###'MAPA DE PRODUÇÃO E COMERCIALIZAÇÃO DE SEMENTES'##"Este relatório mostra o Mapa de Produção de acordo com os parâmetros selecionados."

	//Para não imprimir a pÃ¡gina de parÃ¢metros
	oReport:lParamPage 	:= .F.
	oreport:nFontBody 	:= 8
	oReport:CFONTBODY	:= "COURIER NEW"
	oReport:nLineHeight	:= 060
	oReport:SetDevice(6) //IMPRESSORA
	oReport:oPage:setPaperSize(9) // 9 e 10 sao A4
	oReport:lBold := .t.
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oSec1 := TRSection():New(oReport,"MPRODUCAO")

	oSec1:SettotalInline(.f.)
	osec1:lbold:=.f.

	oSec1:AutoSize(.T.)
	osec1:SetLineBreak(.F.)

	TRCell():New(oSec1,STR0003		,"", STR0003	,PesqPict('NP4',"NP4_DESCRI")  	,220,.T.) //#"CULTIVAR"
	TRCell():New(oSec1,STR0004		,"", STR0004	,"@!"							,75	,.T.) //# "UF"
	TRCell():New(oSec1,STR0005		,"", STR0005	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //"A.PLANTADA(ha)"
	TRCell():New(oSec1,STR0006 		,"", STR0006	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"A.APROVADA(ha)"
	TRCell():New(oSec1,STR0007    	,"", STR0007	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"BRUTA"
	TRCell():New(oSec1,STR0008		,"", STR0008 	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"BENEFICIADA"
	TRCell():New(oSec1,STR0009		,"", STR0009	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //"APROVADA"
	TRCell():New(oSec1,STR0010		,"", STR0010	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"COM.NA UF"
	TRCell():New(oSec1,STR0011		,"", STR0011 	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"COM.OUTRA UF"
	TRCell():New(oSec1,STR0012		,"", STR0012	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"EXPORTADA"
	TRCell():New(oSec1,STR0013		,"", STR0013	,PesqPict('SE1',"E1_SALDO")		,220,.T.) //#"PLA. PROPRIO"
	TRCell():New(oSec1,STR0014		,"", STR0014	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"OUTRAS DESTIN."
	TRCell():New(oSec1,STR0015		,"", STR0015	,PesqPict('SE1',"E1_VALOR")		,220,.T.) //#"SALDO"

	oSec1:lAutosize  := .T. 
	osec1:llinebreak := .f. //-- Utilizado com T. para ver como os espaçoes entre as colunas estavam
	oSec1:SetHeaderBreak(.T.)
	osec1:lbold:=.T.

	_oBreak1 := TRBreak():New( oSec1, oSec1:Cell(STR0003), "T O T A L:",.F. )	//#CULTIVAR
	TRFunction():New(oSec1:Cell(STR0005),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#A.PLANTADA(ha)"
	TRFunction():New(oSec1:Cell(STR0006),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"A.APROVADA(ha)"
	TRFunction():New(oSec1:Cell(STR0007),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"BRUTA"
	TRFunction():New(oSec1:Cell(STR0008),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"BENEFICIADA"
	TRFunction():New(oSec1:Cell(STR0009),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"APROVADA"
	TRFunction():New(oSec1:Cell(STR0010),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"COM.NA UF"
	TRFunction():New(oSec1:Cell(STR0011),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"COM.OUTRA UF"
	TRFunction():New(oSec1:Cell(STR0012),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"EXPORTADA"
	TRFunction():New(oSec1:Cell(STR0013),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"PLA. PROPRIO"
	TRFunction():New(oSec1:Cell(STR0014),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"OUTRAS DESTIN."
	TRFunction():New(oSec1:Cell(STR0015),,"SUM",_oBreak1,,,,.T., .F., .F. ) //#"SALDO"

	oSec1:settotalinline(.f.)
	

Return(oReport)

/*/{Protheus.doc} PrintReport
Função responsavel por popular os dados no objeto TReport()
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function PrintReport(oReport)
	
	local cCultivar	
	local cUF			
	local nAplantada	
	local nAaprovada	
	local nBruta		
	local nBenefici	
	local nAprovada	
	local nComUF      
	local nComOutUF   
	local nExport     
	local nProprio    
	local nOutrDest   
	local ni
	
	Local oSec1	:= oReport:Section(1)

	private _nTAplantad	:= 0 
	private _nTAaprovad	:= 0
	private _nTBruta		:= 0
	private _nTBenefici	:= 0
	private _nTAprovada	:= 0
	private _nTComUF   	:= 0
	private _nTComOutUF	:= 0
	private _nTExport  	:= 0
	private _nTProprio 	:= 0
	private _nTOutrDest	:= 0
	private _nTSaldo		:= 0
	private _cCtrCateg   := ""
	Private _cSeparador  := ": "

	Private _lPlanilha := IIF(oReport:ndevice = 4, .t.,.f.)

	nCont	:= 0
	nPag	:= 1

	oReport:SetPageNumber(nPag)
	oReport:Page(nPag)

	//carregar os dados no array a dados
	fBusDados()

	nCont := 0
	oSec1:Init()
	
	//TIRA O NEGRITO PARA IMPRESSÃO
	oReport:lBold := .F.

	aSort(_aDadosRel, , , {|x, y| x[_nPosCateg] < y[_nPosCateg]})

	oReport:SetMeter(Len(_aDadosRel))	
	If Len(_aDadosRel) > 0
		for ni:= 1 to Len(_aDadosRel)
			oReport:IncMeter()

			//CONTROLE DE IMPRESSÃO PARA SALTAR AS PÁGINAS POR CATEGORIA
			if _cCtrCateg <> _aDadosRel[ni][_nPosCateg] //.or. ni == Len(_aDadosRel)

				_cCtrCateg := _aDadosRel[ni][_nPosCateg]
				//se for a primeira linha do _aDadosRel imprime o cabeçalho
				if ni = 1
					fPrnCab(_cCtrCateg,_aDadosRel[ni][_nPosCdCtVar])
				else
					//imprime o total da categoria
					fPrintTot()
					//imprime o rodapé
					fPrintRod()

					//zera os valores totais da categoria
					_nTAplantad	:= 0
					_nTAaprovad	:= 0
					_nTBruta		:= 0
					_nTBenefici	:= 0
					_nTAprovada	:= 0
					_nTComUF   	:= 0
					_nTComOutUF	:= 0
					_nTExport  	:= 0
					_nTProprio 	:= 0
					_nTOutrDest	:= 0
					_nTSaldo		:= 0	
					
					//se ainda existir dados array imprime o cabeçalho
					IF ni <= Len(_aDadosRel)
						fPrnCab(_cCtrCateg,_aDadosRel[ni][_nPosCdCtVar])	
					ENDIF

				endif
			endif

			//VARIÁVEIS PARA IMPRESSÃO DA LINHA
			cCultivar	:= _aDadosRel[ni][_nPosCtVar]
			cUF			:= _aDadosRel[ni][_nPosUF]
			nAplantada	:= _aDadosRel[ni][_nPosAPlan]
			nAaprovada	:= _aDadosRel[ni][_nPosAApro]
			nBruta		:= _aDadosRel[ni][_nPosBruta]
			nBenefici	:= _aDadosRel[ni][_nPosBenef] // NP9
			nAprovada	:= _aDadosRel[ni][_nPosApro] // NP9
			nComUF      := _aDadosRel[ni][_nPosComUf] // NP9
			nComOutUF   := _aDadosRel[ni][_nPosOutUf] // NP9
			nExport     := _aDadosRel[ni][_nPosExpor] // NP9
			nProprio    := _aDadosRel[ni][_nPosPlaPro] // NP9
			nOutrDest   := _aDadosRel[ni][_nPosOutDes] // NP9
			nSaldo		:= _aDadosRel[ni][_nPosSaldo] // NP9 // SB8

			//incrementando os totais
			_nTAplantad	+= nAplantada
			_nTAaprovad	+= nAaprovada
			_nTBruta		+= nBruta
			_nTBenefici	+= nBenefici
			_nTAprovada	+= nAprovada
			_nTComUF   	+= nComUF
			_nTComOutUF	+= nComOutUF
			_nTExport  	+= nExport
			_nTProprio 	+= nProprio
			_nTOutrDest	+= nOutrDest
			_nTSaldo		+= nSaldo
					
			oSec1:Cell(STR0003):SetValue( cCultivar ) //#"CULTIVAR"
			oSec1:Cell(STR0004):SetValue( cUF ) //#"UF"	
			oSec1:Cell(STR0005):SetValue( nAplantada ) //#"A.PLANTADA(ha)"
			oSec1:Cell(STR0006):SetValue( nAaprovada ) //#"A.APROVADA(ha)"
			oSec1:Cell(STR0007):SetValue( nBruta ) //#"BRUTA"
			oSec1:Cell(STR0008):SetValue( nBenefici ) //#"BENEFICIADA"
			oSec1:Cell(STR0009):SetValue( nAprovada ) //#"APROVADA"
			oSec1:Cell(STR0010):SetValue( nComUF ) //#"COM.NA UF"
			oSec1:Cell(STR0011):SetValue( nComOutUF ) //#"COM.OUTRA UF"
			oSec1:Cell(STR0012):SetValue( nExport ) //#"EXPORTADA"
			oSec1:Cell(STR0013):SetValue( nProprio ) //#"PLA. PROPRIO"
			oSec1:Cell(STR0014):SetValue( nOutrDest) //#"OUTRAS DESTIN."
			oSec1:Cell(STR0015):SetValue( nSaldo) //#"SALDO"

			//SE FOR PLANILHA IMPRIME A LINHA
			if _lPlanilha
				oSec1:PrintLine()
			else //SE NÃO FOR PLANILHA DESENHA OS BOX E UTILIZA O PRINTLINE PARA ESCREVER AS LINHAS
				oReport:SkipLine(1)	
				//if fSaltaPage(5) 
				//	oreport:SkipLine(1)
				//endif 
				//imprime o desenho da linha
				fBoxLine()
				oreport:PrintText ( cCultivar	, oreport:row() , 025)
				oreport:PrintText ( cUF			, oreport:row() , 767)
				oreport:PrintText ( TRANSFORM(nAplantada	, "@E 999,999.99") , oreport:row() , 845)
				oreport:PrintText ( TRANSFORM(nAaprovada	, "@E 999,999.99") , oreport:row() , 1065)
				oreport:PrintText ( TRANSFORM(nBruta		, "@E 999,999.99") , oreport:row() , 1275)
				oreport:PrintText ( TRANSFORM(nBenefici		, "@E 999,999.99") , oreport:row() , 1505)
				oreport:PrintText ( TRANSFORM(nAprovada		, "@E 999,999.99") , oreport:row() , 1725)
				oreport:PrintText ( TRANSFORM(nComUF		, "@E 999,999.99") , oreport:row() , 1945)
				oreport:PrintText ( TRANSFORM(nComOutUF		, "@E 999,999.99") , oreport:row() , 2165)
				oreport:PrintText ( TRANSFORM(nExport		, "@E 999,999.99") , oreport:row() , 2385)
				oreport:PrintText ( TRANSFORM(nProprio		, "@E 999,999.99") , oreport:row() , 2605)
				oreport:PrintText ( TRANSFORM(nOutrDest		, "@E 999,999.99") , oreport:row() , 2825)
				oreport:PrintText ( TRANSFORM(nSaldo		, "@E 999,999.99") , oreport:row() , 3045)
			endif
		next ni

		//IMPRIME O TOTAL DA ÚLTIMA CATEGORIA
		fPrintTot()
		//IMPRIME O RODAPÉ DA ÚLTIMA CATEGORIA
		fPrintRod()

	EndIf
	oReport:lBold := .T.
	//oSec1:Finish()
	oReport:Skipline()
	oReport:IncMeter()
	
Return //oReport

/*/{Protheus.doc} fPrnCab
Função que imprime o cabeçalho do relatório
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function fPrnCab(cCtrCateg, cCultivar)

	Local cProdutor := alltrim(FWSM0Util():GetSM0Data(, , { "M0_NOMECOM" } )[1][2]) //_fCmpSM0("M0_NOMECOM")//"UNIGGEL SEMENTES CHAPADAO"
	Local cInscRenas := SuperGetMV("MV_AGRRENA",.F.,"")
	local cEspecie := fBuscEspec(cCultivar)
	Local cCategoria := cCtrCateg
	Local cSafra := alltrim(mv_par03)
	Local cPeriodo := CVALTOCHAR(mv_par01) + " a " + CVALTOCHAR(mv_par02)
	
	if !_lPlanilha
		//*********************** LINHA 1
		//-------------- Dados do  Produtor
		oreport:PrintText ( STR0016				, oreport:row() 	, 10)	//#"Produtor"
		oreport:PrintText ( _cSeparador + cProdutor	, oreport:row() 	, 350)	

		oreport:SkipLine(1)

		//*********************** LINHA 2
		//-------------- Dados dO Renasem
		oreport:PrintText ( STR0017 , oreport:row() , 10) //#"Inscrição Renasem"
		oreport:PrintText ( _cSeparador + cInscRenas , oreport:row() , 350)
		
		oreport:SkipLine(1)

		//*********************** LINHA 3
		//-------------- Dados do Espécie
		oreport:PrintText ( STR0018	, oreport:row() 	, 10)	//#"ESPÉCIE"
		oreport:PrintText ( _cSeparador + cEspecie   , oreport:row() 	, 350)

		oreport:SkipLine(1)

		//*********************** LINHA 4
		//-------------- Dados Categoria
		oreport:PrintText ( STR0019	, oreport:row() 	, 10)	//#"CATEGORIA"
		oreport:PrintText ( _cSeparador + cCategoria	, oreport:row() 	, 350)
		
		oreport:SkipLine(1)

		//*********************** LINHA 5
		//-------------- Dados de Safra
		oreport:PrintText ( STR0020 , oreport:row() 	, 10)	//#"SAFRA"
		oreport:PrintText ( _cSeparador + cSafra		, oreport:row() 	, 350)
		
		oreport:SkipLine(1)

		//*********************** LINHA 6
		//-------------- Dados data
		oreport:PrintText ( STR0021		, oreport:row() 	, 10)	//#"Período"
		oreport:PrintText ( _cSeparador + cPeriodo	, oreport:row() 	, 350)
		oreport:SkipLine(2) 


		//IMPRIMIR OS BOX DO CABEÇADO DA TABELA
		oReport:Box( oreport:row()-5, 010 , oreport:row()+(__nLin*4)+3 , 755, ) //cultivar

		oReport:Box( oreport:row()-5, 755 , oreport:row()+(__nLin*4)+3 , 830 , ) // UF

		oReport:Box( oreport:row()-5, 830 , oreport:row()+(__nLin*2) , 1270 , ) //AREA CUMULADA


		oReport:Box( oreport:row()-5, 1270 , oreport:row()+(__nLin*2) , 1930, ) //PRODUÇÃO ACUMULADA NA SAFRA (Ton)
		oReport:Box( oreport:row()-5, 1930 , oreport:row()+(__nLin*2) , 3030, ) //DISTRIBUIÇÃO ACUMULADA (Ton) 
		oReport:Box( oreport:row()-5, 3030 , oreport:row()+(__nLin*4) , 3250 , ) //SALDO


		oReport:Box( oreport:row() + (__nLin*2) , 830 , oreport:row()+(__nLin*4) , 1050 , ) //AREA PLANTADA
		oReport:Box( oreport:row() + (__nLin*2) , 1050 , oreport:row()+(__nLin*4) , 1270 , ) //AREA APROVADA 

		oReport:Box( oreport:row() + (__nLin*2) , 1270 , oreport:row()+(__nLin*4) , 1490, ) //BRUTA
		oReport:Box( oreport:row() + (__nLin*2) , 1490 , oreport:row()+(__nLin*4) , 1710 , ) //BENEFICIADA
		oReport:Box( oreport:row() + (__nLin*2) , 1710 , oreport:row()+(__nLin*4) , 1930 , ) //APROVADA  
	
		oReport:Box( oreport:row() + (__nLin*2) , 1930 , oreport:row()+(__nLin*4) , 2590 , ) //COMERCIALIZADA

		oReport:Box( oreport:row() + (__nLin*3) , 1930 , oreport:row()+(__nLin*4) , 2150 , ) //NA UF
		oReport:Box( oreport:row() + (__nLin*3) , 2150 , oreport:row()+(__nLin*4) , 2370 , ) //OUTRA UF
		oReport:Box( oreport:row() + (__nLin*3) , 2370 , oreport:row()+(__nLin*4) , 2590 , ) //EXPORTADA

		oReport:Box( oreport:row() + (__nLin*2) , 2590 , oreport:row()+(__nLin*4) , 2810 , ) //PLANTIO PRÓPRIO
		oReport:Box( oreport:row() + (__nLin*2) , 2810 , oreport:row()+(__nLin*4) , 3030 , ) //OUTRAS DESTINAÇÕES
		

		//Linha 1 
		oreport:PrintText ( STR0022 , oreport:row() 	, 910) //#"AREA ACUMULADA"
		

		oreport:SkipLine(1)

		//Linha 02
		oreport:PrintText ( STR0023	, oreport:row() 	, 1330) //#"PRODUÇÃO ACUMULADA NA SAFRA (Ton)"
		oreport:PrintText ( STR0024	, oreport:row() 	, 960 ) //#"NA SAFRA"
		oreport:PrintText ( STR0025	, oreport:row() 	, 2250) //#"DISTRIBUIÇÃO ACUMULADA (Ton)"
		oreport:PrintText ( STR0015 , oreport:row() 	, 3100) //#"SALDO"

		oreport:SkipLine(1)

		//Linha 03
		oreport:PrintText ( STR0026	, oreport:row(), 870)  //#"PLANTADA"
		oreport:PrintText ( STR0027	, oreport:row(), 1090) //#"APROVADA"	 	
		oreport:PrintText ( STR0028	, oreport:row(), 1330) //#"BRUTA"	 	
		oreport:PrintText ( STR0029	, oreport:row(), 1500) //#"BENEFICIADA" 
		oreport:PrintText ( STR0027	, oreport:row(), 1750) //#"APROVADA"	 
		oreport:PrintText ( STR0030 , oreport:row(), 2145) //#"COMERCIALIZADA"	 
		oreport:PrintText ( STR0031	, oreport:row(), 2630) //#"PLANTIO"
		oreport:PrintText ( STR0032	, oreport:row(), 2860) //#"OUTRAS"
		oreport:PrintText ( STR0033	, oreport:row(), 3100) //#"Ton"

		oreport:SkipLine(1)

		// Linha 04
		oreport:PrintText ( STR0003	, oreport:row() , 300) //#"CULTIVAR"
		oreport:PrintText ( STR0004 , oreport:row() , 767) //#"UF"
		oreport:PrintText ( STR0034 , oreport:row() , 860) //#"ÁREA (ha)"
		oreport:PrintText ( STR0034 , oreport:row() , 1080) //#"ÁREA (ha)"
		oreport:PrintText ( STR0033 , oreport:row() , 1345) //#"Ton"
		oreport:PrintText ( STR0033 , oreport:row() , 1560) //#"Ton"
		oreport:PrintText ( STR0033 , oreport:row() , 1770) //#"Ton"
		oreport:PrintText ( STR0035 , oreport:row() , 1980) //#"NA UF"
		oreport:PrintText ( STR0036	, oreport:row() , 2190) //#"OUTRA UF"
		oreport:PrintText ( STR0012	, oreport:row() , 2390) //#"EXPORTADA"
		oreport:PrintText ( STR0037	, oreport:row() , 2630) //#"PRÓPRIO"
		oreport:PrintText ( STR0038 , oreport:row() , 2830) //#"DESTINAÇÕES"
		

	else 
		oreport:SkipLine(2)
		oReport:PrintText(STR0016 + _cSeparador + cProdutor		, oreport:row() ,  025) //#"Produtor"
		oreport:SkipLine(1)
		oReport:PrintText(STR0017 + _cSeparador + cInscRenas, oreport:row() ,  025) //#"Inscrição Renasem"
		oreport:SkipLine(1)
		oReport:PrintText(STR0018 + _cSeparador + cEspecie		, oreport:row() ,  025) //##"ESPÉCIE"
		oreport:SkipLine(1)
		oReport:PrintText(STR0019 + _cSeparador + cCategoria	, oreport:row() ,  025) //#"CATEGORIA"
		oreport:SkipLine(1)
		oReport:PrintText(STR0020 + _cSeparador + cSafra			, oreport:row() ,  025) //#STR0020
		oreport:SkipLine(1)
		oReport:PrintText(STR0021 + _cSeparador + cPeriodo			, oreport:row() ,  025)		
		oreport:SkipLine(2)
	endif

Return

/*/{Protheus.doc} fBoxLine
Função que imprime os box das linhas de dados do relatorio
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function fBoxLine()
	//oreport:PrintText ( ""	, oreport:row() , 005)
	oReport:Box( oreport:row(), 010 , oreport:row()+__nLin , 755, )	//CULTIVAR
	oReport:Box( oreport:row(), 755 , oreport:row()+__nLin , 830 , )	//UF
	oReport:Box( oreport:row(), 830 , oreport:row()+__nLin , 1050 , ) //AREA PLANTADA
	oReport:Box( oreport:row(), 1050, oreport:row()+__nLin , 1270 , ) //AREA APROVADA
	oReport:Box( oreport:row(), 1270, oreport:row()+__nLin , 1490, ) //BRUTA
	oReport:Box( oreport:row(), 1490, oreport:row()+__nLin , 1710 , ) //BENEFICIADA
	oReport:Box( oreport:row(), 1710, oreport:row()+__nLin , 1930 , ) //APROVADA  
	oReport:Box( oreport:row(), 1930, oreport:row()+__nLin , 2152 , ) //NA UF
	oReport:Box( oreport:row(), 2150, oreport:row()+__nLin , 2370 , ) //OUTRA UF
	oReport:Box( oreport:row(), 2370, oreport:row()+__nLin , 2590 , ) //EXPORTADA
	oReport:Box( oreport:row(), 2590, oreport:row()+__nLin , 2810 , ) //PLANTIO PRÓPRIO
	oReport:Box( oreport:row(), 2810, oreport:row()+__nLin , 3030 , ) //OUTRAS DESTINAÇÕES
	oReport:Box( oreport:row(), 3030, oreport:row()+__nLin , 3250 , ) //SALDO
Return 

/*/{Protheus.doc} fPrintRod
Função que imprime o rodapé do relatório
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function fPrintRod()

	local cCidade 	:= UPPER(Alltrim(FWSM0Util():GetSM0Data(, , {"M0_CIDCOB"})[1][2])) // Alltrim(SM0->M0_CIDCOB)
	local cData 	:= STRZERO(Day(dDataBase), 2) + " de " + MesExtenso(dDataBase) + " de " + StrZero(Year(dDataBase), 4) 
	local cRespTec 	:= ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + AllTrim(mv_par07), "NP8_NOME")) // SuperGetMV("UG_RESPTEC",.F., "Emerson Coelho")
	local cCREA 	:= NP8->NP8_CREA  //ja esta posicionado devido ao posicione acima
	local cRensa 	:= NP8->NP8_RENASE

	if !_lPlanilha
	 
		oreport:PrintText( cCidade + ", " +	cData, oreport:row() , 025 )
		
		oReport:SkipLine(5)
		oReport:Line(oreport:row(), 025, oreport:row(), 1000)
		oReport:SkipLine(1)
		oReport:PrintText(STR0039 + cRespTec, oreport:row() ,  025) //#"Responsável Técnico: "
		
		oReport:SkipLine(1)
		oReport:PrintText( STR0040 + cCREA, oreport:row() , 025 ) //#"CREA: "
		
		oReport:SkipLine(1)
		oReport:PrintText( STR0017 + _cSeparador + cRensa, oreport:row() ,025 ) //#"Inscrição Renasem"
		fSaltaPage(35)	 
		oReport:endpage()
	else
		oReport:Skipline(5)
	endif
Return 

/*/{Protheus.doc} fBusDados
Função que busca os dados e carrega no array _aDadosRel
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
static Function fBusDados()
	Local aDadosMod := {"","", 0,0,0,0,0,0,0,0,0,0,0,"","",""}
	local nLin 		:= 0
	local cDataDe	:= dtos(mv_par01)
	local cDataAte 	:= dtos(mv_par02)
	local cCodSaf 	:= mv_par03
	local cNoTes 	:= fFmtFilt(mv_par06)
	local cCtvarDe	:= mv_par04
	local cCtvarAte := mv_par05
	local cUF 		:= alltrim(FWSM0Util():GetSM0Data(, , {"M0_ESTENT"})[1][2]) //U_fCmpSM0("M0_ESTENT")"
	Local cTMPAlias := GetNextAlias()
	Local cNNM_SEQ 	:= ""
	Local nY		:= 0

	_aDadosRel := {} //zra/inicializa
	
	/*==============================================================*/
	// PREENCHENDO OS CAMPOS CTVAR, AREA PLANTADA E BRUTA NO ARRAY	//
	/*==============================================================*/

	BEGINSQL ALIAS cTMPAlias

		SELECT NNM_CTVAR , NNM_CATEG ,NP4_CODIGO,TRIM(NP4_DESCRI) NP4_DESCRI, NNM_AREA,NNM_SEQ, SUM(NNM_QTAPRD) NNM_QTAPRD, SUM(NJJ_PSLIQU) NJJ_PSLIQU, trim( NNM_CTVAR ) || trim(NNM_CATEG ) NNM_KEY
		FROM %Table:NNM% NNM 
		INNER JOIN %Table:NJJ% NJJ ON NJJ_FILIAL = NNM_FILIAL AND NJJ_MAPA = NNM_SEQ AND NJJ_STATUS='3' AND NJJ_CODPRO=NNM_CODPRO AND NJJ_CODSAF=NNM_CODSAF
		INNER JOIN %Table:NP4% NP4 ON NP4.NP4_CODIGO = NNM_CTVAR 
		WHERE NNM.%notDel%
		AND NJJ.%notDel%
		AND NP4.%notDel%
		AND NNM_FILIAL=  %XFilial:NNM%
		AND NJJ_DATPS1 BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND NNM_CODSAF = %Exp:cCodSaf%
		AND NNM_CTVAR  >= %Exp:cCtvarDe%
		AND NNM_CTVAR  <= %Exp:cCtvarAte%
		GROUP BY NNM_CTVAR , NNM_CATEG , NP4_DESCRI,NP4_CODIGO,NNM_SEQ,NNM_AREA
		ORDER BY NNM_CTVAR , NNM_CATEG , NNM_SEQ

	ENDSQL
	
	while (cTMPAlias)->(!Eof())
		//cria uma nova linha
		If Len(_aDadosRel) < 1 .or. (cTMPAlias)->NNM_KEY != _aDadosRel[nY][_nPoskey] 
			//adicionando os dados
			aadd(_aDadosRel,aClone(aDadosMod))
			nY = Len(_aDadosRel)

			cNNM_SEQ := (cTMPAlias)->NNM_SEQ

			_aDadosRel[nY][_nPosCtVar] 	:= (cTMPAlias)->NP4_DESCRI
			_aDadosRel[nY][_nPosAPlan] 	:= (cTMPAlias)->NNM_AREA
			_aDadosRel[nY][_nPosAApro] 	:= (cTMPAlias)->NNM_AREA
			_aDadosRel[nY][_nPosBruta] 	:= ROUND((cTMPAlias)->NJJ_PSLIQU / 1000,2) //CONVERTENDO PARA TON
			_aDadosRel[nY][_nPosCateg] 	:= (cTMPAlias)->NNM_CATEG 
			_aDadosRel[nY][_nPoskey]   	:= (cTMPAlias)->NNM_KEY
			_aDadosRel[nY][_nPosUF] 	  	:= cUF
			_aDadosRel[nY][_nPosCdCtVar] := (cTMPAlias)->NP4_CODIGO

		else
			If cNNM_SEQ != (cTMPAlias)->NNM_SEQ //para somar a area de forma correta
				cNNM_SEQ := (cTMPAlias)->NNM_SEQ
				_aDadosRel[nY][_nPosAPlan] 	+= (cTMPAlias)->NNM_AREA
				_aDadosRel[nY][_nPosAApro] 	+= (cTMPAlias)->NNM_AREA
				_aDadosRel[nY][_nPosBruta] 	+= ROUND((cTMPAlias)->NJJ_PSLIQU / 1000,2) //CONVERTENDO PARA TON
			
			EndIf		
		EndIf

		(cTMPAlias)->(DbSkip())
	enddo
	(cTMPAlias)->(dbCloseArea())
	
	/*==========================================*/
	// PREENCHENDO A QUANTIDADE BENEFICIADA	    //
	/*==========================================*/
	BEGINSQL alias cTMPAlias
		
		SELECT NP9_CTVAR, NP9_CATEG, SUM(NP9_QUANT * NP9_PSMDEN) NP9_BENEF, trim( NP9_CTVAR) || trim(NP9_CATEG) NNM_KEY 
		FROM  %Table:NP9% NP9
		INNER JOIN %Table:SB5% SB5 ON B5_FILIAL = %xFilial:SB5% AND B5_COD = NP9_PROD
		WHERE SB5.%notDel%
		AND NP9.%notDel%
		AND NP9_FILIAL = %XFilial:NP9%
		AND NP9_DATA BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND NP9_CODSAF = %Exp:cCodSaf%
		AND NP9_TRATO = '2'		
		AND B5_SEMENTE='1'
		AND NP9_CTVAR >= %Exp:cCtvarDe%
		AND NP9_CTVAR <= %Exp:cCtvarAte%
		GROUP BY NP9_CTVAR, NP9_CATEG
	ENDSQL

	while (cTMPAlias)->(!Eof())
		//VERIFICA SE A CULTIVAR EXISTE NO ARRAY
		nLin := aScan(_aDadosRel, {|X| X[_nPoskey] == alltrim((cTMPAlias)->NNM_KEY)})

		//SE A CULTIVAR EXISTE NO ARRAY DE CAMPOS DE PRODUÇÃO ADICIONA A QUANTIDADE BENEFICIADA
		if nlin > 0
			_aDadosRel[nLin][_nPosBenef] := ROUND((cTMPAlias)->NP9_BENEF/1000,2)//CONVERTENDO PARA TON
		endif

		(cTMPAlias)->(DbSkip())
	enddo	
	(cTMPAlias)->(dbCloseArea())

	/*==============================================*/
	// PREENCHENDO A QUANTIDADE APROVADA			//
	/*==============================================*/
	//query para buscar a quantidade aprovada (NP9_STATUS ='2')
	BEGINSQL alias cTMPAlias
		SELECT NP9_CTVAR, NP9_CATEG, SUM(NP9_QUANT * NP9_PSMDEN) NP9_APROVADA,
		trim( NP9_CTVAR) || trim(NP9_CATEG) NNM_KEY 
		FROM  %Table:NP9% NP9
		INNER JOIN %Table:SB5% SB5 ON B5_FILIAL = %xFilial:SB5% AND B5_COD = NP9_PROD
		WHERE SB5.%notDel%
		AND NP9.%notDel%
		AND NP9_FILIAL = %XFilial:NP9%
		AND NP9_DATA BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND NP9_CODSAF = %Exp:cCodSaf%
		AND NP9_TRATO = '2'		
		AND B5_SEMENTE='1'
		AND NP9_STATUS = '2'
		AND NP9_CTVAR >= %Exp:cCtvarDe%
		AND NP9_CTVAR <= %Exp:cCtvarAte%		
		GROUP BY NP9_CTVAR, NP9_CATEG
	ENDSQL	
		
	while (cTMPAlias)->(!Eof())
		//VERIFICA SE A CULTIVAR EXISTE NO ARRAY
		nLin := aScan(_aDadosRel, {|X| X[_nPoskey] == alltrim((cTMPAlias)->NNM_KEY)})

		//SE A CULTIVAR EXISTE NO ARRAY DE CAMPOS DE PRODUÇÃO ADICIONA A QUANTIDADE aprovada
		if nlin > 0
			_aDadosRel[nLin][_nPosApro] := ROUND((cTMPAlias)->NP9_APROVADA/1000,2)//CONVERTENDO PARA TON
		endif

		(cTMPAlias)->(DbSkip())
	enddo	
	(cTMPAlias)->(dbCloseArea())

	/*==============================================*/
	// PREENCHENDO A QUANTIDADE COMERCIALIZADA		//
	/*==============================================*/
	//VERIFICA SE HOUVE ALGUMA TES QUE FOI RETIRADA DA CONSULTA DA SD2
	if !Empty(cNoTes)
		cFiltro := "AND D2_TES NOT IN (" + cNoTes + ")"
	endif

	//query para buscar a quantidade COMERCIALIZADA
	BEGINSQL alias cTMPAlias
		SELECT NP9_CTVAR, NP9_CATEG, SUM(D2_QUANT * NP9_PSMDEN) D2_QUANT, SUBSTRING(D2_CF ,1,1) D2_CF, NP9_CTVAR || NP9_CATEG NNM_KEY
		FROM %Table:SD2% SD2
		INNER JOIN %Table:NP9% NP9 ON NP9_FILIAL = D2_FILIAL AND NP9_PROD = D2_COD AND NP9_LOTE = D2_LOTECTL
		WHERE SD2.%notDel%
		AND NP9.%notDel% 
		AND D2_FILIAL = %XFilial:NNM% 
		AND D2_EMISSAO BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND NP9_CODSAF = %Exp:cCodSaf%
		AND D2_TES NOT IN (%exp:cNoTes%)
		AND NP9_CTVAR >= %Exp:cCtvarDe%
		AND NP9_CTVAR <= %Exp:cCtvarAte%
		GROUP BY NP9_CTVAR, NP9_CATEG, SUBSTRING(D2_CF ,1,1)
	ENDSQL	
		
	while (cTMPAlias)->(!Eof())
		//VERIFICA SE A CULTIVAR EXISTE NO ARRAY
		nLin := aScan(_aDadosRel, {|X| X[_nPoskey] == alltrim((cTMPAlias)->NNM_KEY)})

		//SE A CULTIVAR EXISTE NO ARRAY DE CAMPOS DE PRODUÇÃO ADICIONA A QUANTIDADE aprovada
		if nlin > 0
			if (cTMPAlias)->D2_CF == "6" //SE CFOP INICIA COM 6 É COMERCIALIZADA PARA OUTRA UF
				_aDadosRel[nLin][_nPosOutUf] := ROUND((cTMPAlias)->D2_QUANT/1000,2)//CONVERTENDO PARA TON
			elseif (cTMPAlias)->D2_CF == "5"//SE CFOP INICIA COM 5 É COMERCIALIZADA PARA UF
				_aDadosRel[nLin][_nPosComUf] := ROUND((cTMPAlias)->D2_QUANT/1000,2)//CONVERTENDO PARA TON
			else 
				_aDadosRel[nLin][_nPosExpor] := ROUND((cTMPAlias)->D2_QUANT/1000,2)//CONVERTENDO PARA TON	
			endif
		endif

		(cTMPAlias)->(DbSkip())
	enddo	
	(cTMPAlias)->(dbCloseArea())

	/*==============================================*/
	// PREENCHENDO O SALDO							//
	/*==============================================*/
	BEGINSQL Alias cTMPAlias
		SELECT NP9_CTVAR, NP9_CATEG, SUM(B8_SALDO * NP9_PSMDEN) B8_SALDO, NP9_CTVAR || NP9_CATEG NNM_KEY
		FROM %Table:SB8% SB8
		INNER JOIN %Table:NP9% NP9 ON NP9_FILIAL = B8_FILIAL AND NP9_PROD = B8_PRODUTO AND NP9_LOTE = B8_LOTECTL
		WHERE SB8.%notDel%
		AND NP9.%notDel%
		AND B8_FILIAL = %XFilial:SB8%
		AND NP9_CODSAF = %Exp:cCodSaf%
		AND NP9_DATA BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND NP9_CTVAR >= %Exp:cCtvarDe%
		AND NP9_CTVAR <= %Exp:cCtvarAte%
		GROUP BY NP9_CTVAR, NP9_CATEG
	ENDSQL
	
	while (cTMPAlias)->(!Eof())
		//VERIFICA SE A CULTIVAR EXISTE NO ARRAY
		nLin := aScan(_aDadosRel, {|X| X[_nPoskey] == alltrim((cTMPAlias)->NNM_KEY)})

		//SE A CULTIVAR EXISTE NO ARRAY DE CAMPOS DE PRODUÇÃO ADICIONA O SALDO
		if nlin > 0
			_aDadosRel[nLin][_nPosSaldo] := ROUND((cTMPAlias)->B8_SALDO/1000,2)//CONVERTENDO PARA TON
		endif

		(cTMPAlias)->(DbSkip())
	enddo	
	(cTMPAlias)->(dbCloseArea())

	/*==============================================*/
	// PREENCHENDO OUTRAS DESTINAÇÕES 				//
	/*==============================================*/
	BEGINSQL alias cTMPAlias

		SELECT NP9_CTVAR, NP9_CATEG, SUM(SD3.D3_QUANT) D3_QUANT, NP9_CTVAR || NP9_CATEG NNM_KEY
		FROM %Table:SD3% SD3 
		INNER JOIN %Table:SD3% ORI ON ORI.D3_FILIAL=SD3.D3_FILIAL AND ORI.D3_NUMSEQ=SD3.D3_NUMSEQ
		INNER JOIN %Table:NP9% NP9 ON ORI.D3_FILIAL=NP9.NP9_FILIAL AND ORI.D3_COD=NP9.NP9_PROD AND ORI.D3_LOTECTL = NP9.NP9_LOTE
		WHERE SD3.%notDel% 
		AND NP9.%notDel%
		AND ORI.%notDel%
		AND SD3.D3_FILIAL=%XFilial:SD3%
		AND ORI.D3_FATHER = 'F'
		AND SD3.D3_EMISSAO BETWEEN %Exp:cDataDe% AND %Exp:cDataAte%
		AND SD3.D3_CF='DE7'
		AND ORI.D3_CF='RE7'
		AND NP9_CTVAR >= %Exp:cCtvarDe%
		AND NP9_CTVAR <= %Exp:cCtvarAte%
		GROUP BY NP9_CTVAR, NP9_CATEG

	ENDSQL
	//D3_FATHER	Identifica-se o produto que originou a desmontagem(Produto Origem)

	while (cTMPAlias)->(!Eof())
		//VERIFICA SE A CULTIVAR EXISTE NO ARRAY
		nLin := aScan(_aDadosRel, {|X| X[_nPoskey] == alltrim((cTMPAlias)->NNM_KEY)})

		//SE A CULTIVAR EXISTE NO ARRAY DE CAMPOS DE PRODUÇÃO ADICIONA OUTRAS DESTINAÇOES
		if nlin > 0
			_aDadosRel[nLin][_nPosOutDes] := ROUND((cTMPAlias)->D3_QUANT/1000,2)//CONVERTENDO PARA TON
		endif

		(cTMPAlias)->(DbSkip())
	enddo
	(cTMPAlias)->(dbCloseArea())

Return .t.

/*/{Protheus.doc} fPrintTot
Função que imprime a linha de totais 
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
static function fPrintTot()
	
	//if !_lPlanilha
		oReport:SkipLine(1)
		fSaltaPage(5)	 
		fBoxLine()
		oReport:lBold := .T.
		oreport:PrintText ( STR0041	, oreport:row() , 500) //#"TOTAL"
		oreport:PrintText ( TRANSFORM(_nTAplantad	, "@E 999,999.99") , oreport:row() , 845)
		oreport:PrintText ( TRANSFORM(_nTAaprovad	, "@E 999,999.99") , oreport:row() , 1065)
		oreport:PrintText ( TRANSFORM(_nTBruta		, "@E 999,999.99") , oreport:row() , 1275)
		oreport:PrintText ( TRANSFORM(_nTBenefici	, "@E 999,999.99") , oreport:row() , 1505)
		oreport:PrintText ( TRANSFORM(_nTAprovada	, "@E 999,999.99") , oreport:row() , 1725)
		oreport:PrintText ( TRANSFORM(_nTComUF		, "@E 999,999.99") , oreport:row() , 1945)
		oreport:PrintText ( TRANSFORM(_nTComOutUF	, "@E 999,999.99") , oreport:row() , 2165)
		oreport:PrintText ( TRANSFORM(_nTExport		, "@E 999,999.99") , oreport:row() , 2385)
		oreport:PrintText ( TRANSFORM(_nTProprio		, "@E 999,999.99") , oreport:row() , 2605)
		oreport:PrintText ( TRANSFORM(_nTOutrDest	, "@E 999,999.99") , oreport:row() , 2825)
		oreport:PrintText ( TRANSFORM(_nTSaldo		, "@E 999,999.99") , oreport:row() , 3045)
		oReport:SkipLine(3)
	//endif	

return .t.

/*/{Protheus.doc} fSaltaPage
Funcao que verifica se precisa imprimir o rodape e pular a pagina
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function fSaltaPage(nLines)
	Local lSaltou := .f.
	Local ni:=0
	ni:=1

	While oReport:ChkIncRow(nLines,.t.)
		if nI == 1
			lSaltou := .t.
		ELSE
			oReport:SkipLine(1)
		EndIF
		ni++
	EndDo

Return(lSaltou)

/*/{Protheus.doc} fFmtFilt
Função para formatar o filtro para o not in de TES da sql
@type function
@version P12 
@author Daniel Silveira/claudineia.reinert
@since 26/01/2024
/*/
Static Function fFmtFilt(cFiltro)
	local cRet := ""
	local aAux := separa(cFiltro, "/")
	local ni

	for ni := 1 to len(aAux)
		if ni == 1
			cRet += alltrim(aAux[ni])
		else
			cRet += "','" + alltrim(aAux[ni])
		endif
	next ni

return cRet

/*/{Protheus.doc} fBuscEspec
Busca a descrição e nome cientifico da cultura/especie
@type function
@version P12  
@author claudineia.reinert
@since 26/01/2024
@param cCultivar, character, codigo da cultivar
@return variant, descrição da cultura/especie e nome cientifico
/*/
Static Function fBuscEspec(cCultivar)
	Local cRet := ""

	dbSelectArea("NP4")
	NP4->(dbSetOrder(1))
	IF NP4->(DbSeek(FWxFilial("NP4")+cCultivar))
		dbSelectArea("NP3")
		NP3->(dbSetOrder(1))
		IF NP3->(DbSeek(FWxFilial("NP3")+NP4->NP4_CULTRA))
			cRet := AllTrim(NP3->NP3_DESCRI) + " ("+AllTrim(NP3->NP3_NOMCIE)+") "
		EndIf
	EndIf

Return cRet
