#INCLUDE "TOTVS.CH"
#INCLUDE "RHNP08.CH"

Static lTemRF13 := SRF->( ColumnPos( "RF_PER13S2" ) ) > 0 .And. SRF->( ColumnPos( "RF_PER13S3" ) ) > 0

/*/{Protheus.doc} VldDtFer13
Valida se o usuário podera solicitar 13 em férias iniciadas em Jan e Dez.
@author: Marcelo Silveira
@since:	06/08/2021
@param:	dDtIniFer - Data de inicio das férias.
@return: Nil
/*/
Function VldDtFer13(dDtIniFer)

    Local lPermite    := SuperGetMV("MV_MRHS13F",,.T.)
    Local nMonth      := Month(dDtIniFer)
    Local cMsgValid   := ""

    If !lPermite .And. ( nMonth == 1 .Or. nMonth == 12 )
        cMsgValid := OemToAnsi(STR0074) // Não é permitido solicitar o adiantamento do 13 Salario em férias iniciadas em Janeiro ou Dezembro.
    EndIf

Return cMsgValid

/*/{Protheus.doc} fVld13SRH
Valida 13 sem solicitação/programação anterior.
@author: Henrique Ferreira
@since:	30/10/2023
@param:	cFil     - Código da filial
        cMat     - Código da matrícula
        cDataIni - Data de início das férias.
@return: Nil
/*/
Function fVld13SRH(cFil, cMat, cDataIni)

    Local cMsgValid  := ""
    Local dDataIni   := ctod(cDataIni)
    Local aArea      := GetArea()

    DbSelectArea("SRH")
    SRH->(DbSetOrder(1))
    If SRH->(DbSeek(cFil+cMat))
        While SRH->(!Eof()) .And. SRH->RH_FILIAL+SRH->RH_MAT == cFil+cMat
            If SRH->RH_PERC13S > 0 .And. Year(SRH->RH_DATAINI) == Year(dDataIni)
                cMsgValid := OemToAnsi(STR0077) // Já existem férias calculadas com adiantamento de décimo terceiro para este periodo..
                Exit 
            EndIf
            SRH->(DbSkip())
        EndDo
    EndIf

    RestArea(aArea)

Return cMsgValid

/*/{Protheus.doc} fVld13SRF
Valida 13 sem solicitação anterior.
@author: Henrique Ferreira
@since:	30/10/2023
@param:	cFil     - Código da filial
        cMat     - Código da matrícula
        cDataIni - Data de início das férias.
@return: Nil
/*/
Function fVld13SRF(cFil, cMat, cDataIni)

    Local cMsgValid  := ""
    Local dDataIni   := ctod(cDataIni)
    Local nPerc13    := 0
    Local aArea      := GetArea()

    DbSelectArea("SRF")
    SRF->(DbSetOrder(1))
    If SRF->(DbSeek(cFil+cMat))
        While SRF->(!Eof()) .And. SRF->RF_FILIAL+SRF->RF_MAT == cFil+cMat
            nPerc13 := SRF->RF_PERC13S
            nPerc13 += If( !lTemRF13, 0,  SRF->RF_PER13S2 + SRF->RF_PER13S3 )
            //Valida se já foi solicitado adiantamento do décimo terceiro para o mesmo ano.
            If nPerc13 > 0 .And. SRF->RF_STATUS == "1"
                If !Empty(SRF->RF_DATAINI) .Or. !Empty(SRF->RF_DATINI2)
                    If (Year(SRF->RF_DATAINI) == Year(dDataIni)) .Or. (Year(SRF->RF_DATINI2) == Year(dDataIni))
                        cMsgValid := OemToAnsi(STR0076) //"Já existem férias programadas com adiantamento de décimo terceiro para este periodo."
                        Exit
                    EndIf
                EndIf
            EndIf
            SRF->(DbSkip())
        EndDo
    EndIf

    RestArea(aArea)

Return cMsgValid

/*/{Protheus.doc} fMrhFerCol
Verifica se as férias do funcionário são férias coletivas.
@author: Henrique Ferreira
@since:	30/10/2023
@param:	aPerFerias     - array com os dados da SRF.
        aDadosSRH      - array com os dados da SRH.
        nFerDuracao    - quantidade de dias de férias solicitadas.
@return: cMsgFault
/*/
Function fMrhFerCol(aPerFerias, aDadosSRH, nFerDuracao )

   Local cMsgFault := ""
   Local lFerCol   := .F.
   Local nSaldoFer := nFerDuracao - Int(nFerDuracao)

   DEFAULT aPerFerias := {}
   DEFAULT aDadosSRH  := {}
   
   // Checa primeiramente SRF.
   lFerCol := fFerColSRF(aPerFerias, aDadosSRH)

   If !lFerCol .And. nSaldoFer > 0
      cMsgFault := OemToAnsi(STR0079) //"Somente é possivel solicitar ferias fracionadas em casos de saldo de férias coletivas."
   // Validação para que não seja permitido solicitar ponto flutuante inválido.
   // Ex: 10.1 dias, 10.6 dias.
   // Somente será valido ponto flutuante igual a 5. Ex: 10.5 dias, 12.5 dias
   Elseif lFerCol .And. nSaldoFer > 0 .And. nSaldoFer <> 0.5
      cMsgFault := OemToAnsi(STR0080) //"Quantidade fracionada inválida! Ajuste a quantidade para um valor válido."
   EndIf

Return cMsgFault

/*/{Protheus.doc} fFerColSRF
Verifica férias coletivas já gravadas na SRF após o fechamento do período.
@author: Henrique Ferreira
@since:	30/10/2023
@param:	aPerFerias     - array com os dados da SRF.
        aDadosSRH      - array com os dados da SRH.
@return: lFerCol       - .T. caso encontre férias coletivas, .F. caso não encontre.
/*/
Function fFerColSRF( aPerFerias, aDadosSRH )

   Local lFerCol   := .F.

   DEFAULT aPerFerias := 0
   DEFAULT aDadosSRH  := 0

   If Len(aPerFerias) > 0
      If !(lFerCol := ( aPerFerias[1,16]  > 0 ))
         lFerCol := fFerColSRH(aDadosSRH, aPerFerias[1,2])
      EndIf
   EndIf

Return lFerCol

/*/{Protheus.doc} fFerColSRH
Verifica férias coletivas já gravadas na SRF após o fechamento do período.
@author: Henrique Ferreira
@since:	30/10/2023
@param:	aDadosSRH     - array com os dados da SRH.
        dDtFimPer     - data fim do período aquisitivo para comparação se houve troca do período.
@return: lFerCol       - .T. caso encontre férias coletivas, .F. caso não encontre.
/*/
Function fFerColSRH( aDadosSRH, dDtFimPer )

   Local lFerCol   := .F.
   Local nLenSRH   := 0
   Local nX        := 0

   DEFAULT aDadosSRH  := 0

   If ( nLenSRH := Len(aDadosSRH) ) > 0
      // Se não tiver coletivas na SRF, pode ser que ainda não fechou o período, então busca da SRH.
      // Em caso de férias coletivas com menos de 1 ano (muda o período aquisitivo)
      // Então, a data fim do período aquisito da SRH vai ser diferente da data fim do período aquisitivo na SRF.
      For nX := 1 To nLenSRH
         If ( lFerCol := Iif( lFerCol, lFerCol, aDadosSRH[nX,10] == "C" .And. dDtFimPer <> STOD(aDadosSRH[nX,5]) ) )
            exit
         EndIf
      Next nX
   EndIf

Return lFerCol

