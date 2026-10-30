#INCLUDE 'PROTHEUS.CH'  
#INCLUDE 'WMSA381.CH'

#DEFINE WMSA38101 "WMSA38101"
#DEFINE WMSA38102 "WMSA38102"
#DEFINE WMSA38103 "WMSA38103"
#DEFINE WMSA38104 "WMSA38104"
#DEFINE WMSA38105 "WMSA38105"

//-------------------------------------------------------------
/*/{Protheus.doc} WmsA381
Corte de Produtos de OS WMS de Expedição e Embalagem
@author felipe.m
@since 26/05/2015
@version 2.0
/*/
//-------------------------------------------------------------
Function WmsA381()
Local oSize    := Nil
Local cMapaSep := Space(Len(D12->D12_MAPSEP))
Local aButtons := {}
Local aAltera  := {'C6_QTDLIB'} // Campos que poderão ser alterados

Private oGetD   := Nil
Private aHeader := {}
Private aCols   := {}
Private aRotina := {{STR0001,'AxPesqui',0,1},; // Pesquisar
                    {STR0002,'AxVisual',0,2},; // Visualizar
                    {STR0003,'AxInclui',0,3},; // Incluir
                    {STR0004,'AxAltera',0,4},; // Alterar
                    {STR0005,'AxDeleta',0,5} } // Excluir

	If !SuperGetMV("MV_WMSNEW", .F., .F.)
		Return wmsa380()
	EndIf

	oSize := FWDefSize():New(.T.)

	oSize:AddObject("CAMPOMAPA", 100, 10, .T., .T.) //Área útil vertical da tela que o campo Mapa Separação irá ocupar 10%
	oSize:AddObject("ITENSGRID", 100, 90, .T., .T.) //Área útil vertical da tela que a MSGetDados irá ocupar 90%

	// Permite redimensionar as telas de acordo com a proporção do AddObject
	oSize:lProp := .T.

	// Executa os cálculos
	oSize:Process()

	// Inicia aHeader e aCols
	InicHC()

	DEFINE MSDIALOG oDlg TITLE STR0006 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	@ oSize:GetDimension("CAMPOMAPA","LININI")+15,oSize:GetDimension("CAMPOMAPA","COLINI")+15 SAY   STR0007 SIZE 20,9 OF oDlg PIXEL // Mapa
	@ oSize:GetDimension("CAMPOMAPA","LININI")+15,oSize:GetDimension("CAMPOMAPA","COLINI")+35 MSGET cMapaSep SIZE 25,9 VALID VldMapa(cMapaSep) OF oDlg PIXEL

	oGetD := MSGetDados():New(oSize:GetDimension("ITENSGRID","LININI"),;
								oSize:GetDimension("ITENSGRID","COLINI"),;
								oSize:GetDimension("ITENSGRID","LINEND"),;
								oSize:GetDimension("ITENSGRID","COLEND"),;
								3,,'AllWaysTrue',,,aAltera)

	oGetD:OBROWSE:BADD := { || { || .F.  }} // Não permite incluir nova linha no browse

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| Iif(WmsA381TOk(),(WmsA381Grv(),InicHC(@cMapaSep),oGetD:ForceRefresh()),.F.)},{||oDlg:End()},, aButtons )//Ativa a Dialog e inclui a Enchoice
Return
//---------------------------------------------------------------------------//
//------------------------ Inicializa aHeader e aCols -----------------------//
//---------------------------------------------------------------------------//
Static Function InicHC(cMapaSep)
Local aCampos  := {}
Local nX       := 1
Local aColsSX3 := {}

	If !Empty(cMapaSep)
		cMapaSep := Space(Len(D12->D12_MAPSEP))
		aHeader  := {}
		aCols    := {}
	EndIf

	AAdd(aCampos,{"DCF","DCF_DOCTO" ,"C"})
	AAdd(aCampos,{"D12","D12_LOCORI","C"})
	AAdd(aCampos,{"D12","D12_PRODUT","C"})
	AAdd(aCampos,{"D12","D12_QTDMOV","N"})
	AAdd(aCampos,{"SC6","C6_QTDLIB" ,"N"})

	For nX := 1 To Len(aCampos)
		BuscarSX3(aCampos[nX,2],,aColsSX3)
		AAdd(aHeader,{Iif(AllTrim(aCampos[nX,2])=='D12_QTDMOV',STR0008,; // Qtde Original
						Iif(AllTrim(aCampos[nX,2])=='C6_QTDLIB',STR0009,;  // Qtde p/ Corte
						AllTrim(aColsSX3[1]))),;                           // Titulo
						aCampos[nX,2]  ,;                                  // Campo
						aColsSX3[2],;                                      // Picture
						aColsSX3[3],;                                      // Tamanho
						aColsSX3[4],;                                      // Decimal
						Iif(AllTrim(aCampos[nX,2])=='C6_QTDLIB','WMSA381VQC()',''),; // Valid
						X3Usado(aCampos[nX,2]),;                           // Usado
						aCampos[nX,3],;                                    // Tipo
						aCampos[nX,1],;                                    // Arquivo
						"R"})                                              // Contexto
	Next
	// Cria uma linha no aCols
	AAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 To Len(aHeader)
		GdFieldPut(aHeader[nX,2],CriaVar(aHeader[nX,2],.F.,,.F.),1)
	Next
	aCols[1,Len(aHeader)+1] := .F.
Return
//---------------------------------------------------------------------------//
//---- Valida mapa de separação e carrega seus respectivos itens na tela ----//
//---------------------------------------------------------------------------//
Static Function VldMapa(cMapaSep)
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cAliasQry := Nil

	If !Empty(cMapaSep)
		aCols := {}
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			SELECT D12.R_E_C_N_O_ RECNOD12
			FROM %Table:D12% D12
			WHERE D12.D12_FILIAL = %xFilial:D12%
			AND D12.D12_MAPSEP = %Exp:cMapaSep%
			AND D12.D12_RADIOF = '2'
			AND D12.D12_STATUS = '4'
			AND D12.%NotDel%
			ORDER BY D12.D12_DOC,
						D12.D12_LOCORI,
						D12.D12_PRODUT
		EndSql
		Do While (cAliasQry)->(!Eof())
			// Posiciona D12
			D12->(dbGoTo((cAliasQry)->RECNOD12))
			// Carrega os itens do mapa que serão mostrados na tela
			AAdd(aCols,{D12->D12_DOC,;
						D12->D12_LOCORI,;
						D12->D12_PRODUT,;
						D12->D12_QTDMOV,;
						0,;
						D12->(Recno())} )
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
		If Empty(aCols)
			WmsMessage(STR0010,WMSA38101) // Cortes sao permitidos somente em o.s.wms de expedicao e embalagem, pois se trata de um processo manual e sera considerado pela conferencia (wmsa360)
			lRet := .F.
		Else
			oGetD:ForceRefresh()
		EndIf
	Else
		WmsMessage(STR0012,WMSA38102,1) // Informe o mapa de separação!
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet
//---------------------------------------------------------------------------//
//----------------------- Valida o campo Qtde p/ Corte ----------------------//
//---------------------------------------------------------------------------//
// antiga funcao VldQtCorte
Function WMSA381VQC()

	If QtdComp(M->C6_QTDLIB) > QtdComp(GdFieldGet('D12_QTDMOV',n))
		WmsMessage(STR0011,WMSA38103,1) // Quantidade para corte maior que quantidade original
		Return .F.
	EndIf
Return .T.

//---------------------------------------------------------------------------//
//---------------------- Validação geral da MSGetDados, ---------------------//
//-------- verifica se existe alguma quantidade para realizar corte ---------//
//---------------------------------------------------------------------------//
Static Function WmsA381TOk()
	If AScan(aCols,{|x|x[5]>0}) == 0
		WmsMessage(STR0013,WMSA38104) // É necessário informar quantidade para realizar o corte de produto!
		Return .F.
	EndIf
Return .T.
//---------------------------------------------------------------------------//
//------------------------- Grava o corte de produto ------------------------//
//----------------- atualizando as tabelas correspondentes ------------------//
//---------------------------------------------------------------------------//
Static Function WmsA381Grv()
Local lRet     := .F.
Local aVisErr  := {}
Local nX       := 1
Local nQtdMvto := 0
Local nQtdOrig := 0

Private oMovimento  := WMSBCCMovimentoServico():New()

	For nX := 1 To Len(aCols)
		If QtdComp(aCols[nX,5]) > QtdComp(0) .And. aCols[nX,5] < aCols[nX,4]
			// Posiciona no registro D12
			oMovimento:GoToD12(aCols[nX,6])
			// Verifica se é o primeiro movimento
			If !oMovimento:IsPriAtiv()
				lRet := .F.
			EndIf
			nQtdOrig := aCols[nX,4]
			nQtdMvto := nQtdOrig - aCols[nX,5]
			// Verifica se movimento não está aglutinado
			If oMovimento:GetAgluti() == "2"
				If oMovimento:oOrdServ:GetOrigem() $ "DCF/SC9"
					Begin Transaction
						If !WmsGrvDif(oMovimento,.F.,nQtdOrig,nQtdMvto)
							DisarmTransaction()
						EndIf
					End Transaction
				EndIf
			Else
				WMSVTAviso("SIGAWMS",STR0016) // Atividade está aglutinada, não permite o cancelamento parcial da separação. Utilize o estorno do monitor de serviço
				lRet := .F.
			EndIf
		EndIf
	Next
	If !Empty(aVisErr)
		TmsMsgErr(aVisErr, STR0014) //Houveram problemas no corte do documento/produto:
	Else
		WmsMessage(STR0015,WMSA38105) //Corte de produto realizado com sucesso!
	EndIf
Return lRet