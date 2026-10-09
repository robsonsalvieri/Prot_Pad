#INCLUDE "OfiOA020.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ OFIOA020 ³ Autor ³  Fabio                ³ Data ³ 28/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Cadastro de Grupo de servico                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA020

PRIVATE cCadastro := OemToAnsi(STR0006) //"Cadastro de Grupo de servico"

DbSelectArea("VOS")
axCadastro("VOS", cCadastro,"OA020E()", "OA0200018_VldGrp()")

Return
           
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OA020E    ºAutor  ³Fabio               º Data ³  08/23/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Excluir                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Garantia                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OA020E()
Local aVetValid := {}
aAdd(aVetValid, {"VFA" ,"VFA_CODMAR+VFA_GRUSER", VOS->VOS_CODMAR+VOS->VOS_CODGRU  , NIL } )
aAdd(aVetValid, {"VG8" ,"VG8_CODMAR+VG8_GRUSER", VOS->VOS_CODMAR+VOS->VOS_CODGRU  , NIL } )
aAdd(aVetValid, {"VO6" ,"VO6_CODMAR+VO6_GRUSER", VOS->VOS_CODMAR+VOS->VOS_CODGRU  , NIL } )
aAdd(aVetValid, {"VS4" ,"VS4_GRUSER", VOS->VOS_CODGRU  , "VS1->( DbSeek( xFilial('VV1') + VS4->VS4_NUMORC ) ) .And. VS1->VS1_CODMAR == VOS->VOS_CODMAR" } )
aAdd(aVetValid, {"VO4" ,"VO4_GRUSER", VOS->VOS_CODGRU  , "VO1->( DbSeek( xFilial('VO1') + VO4->VO4_NOSNUM ) ) .And. VO1->VO1_CODMAR == VOS->VOS_CODMAR" } )
Return FG_DELETA( aVetValid )

Static Function MenuDef()
Local aRotina := {  { oemtoansi(STR0001),"AxPesqui", 0 , 1,,.F.},;  // "Pesquisar"
                    { oemtoansi(STR0002),"AxCadVis", 0 , 2},;       // "Visualizar"
                    { oemtoansi(STR0003),"AxCadInc", 0 , 3},;       // "Incluir"
                    { oemtoansi(STR0004),"AxCadAlt", 0 , 4},;       // "Alterar"
                    { oemtoansi(STR0005),"AxCadDel", 0 , 5}}        // "Excluir"
Return aRotina

Function OA0200018_VldGrp()
    Local lVOSGRPSER := VOS->(FieldPos("VOS_GRPSER")) > 0
    Local lRet := .T.
    local cAlert := ''

    If !Empty(M->VOS_GRPSER)
        if lVOSGRPSER
            cQuery := "SELECT VOS.R_E_C_N_O_ "
            cQuery += "FROM "+ RetSqlName("VOS") + " VOS "
            cQuery += "WHERE VOS.VOS_FILIAL = '" + xFilial("VOS") + "' "
            cQuery += "AND VOS.VOS_GRPSER = '" + M->VOS_GRPSER +"' "
            cQuery += "AND VOS.VOS_CODGRU <> '" + M->VOS_CODGRU +"' "
            cQuery += "AND VOS.D_E_L_E_T_ = ' ' "

            nRecVOS := FM_SQL(cQuery)
        EndIf

        If nRecVOS > 0 
            cAlert := STR0007 + M->VOS_GRPSER //O código informado para o Grupo da Montadora já está vinculado a outro Grupo de Serviço no Protheus Grupo
            FMX_HELP("OA0200018", STR0006 , cAlert) //Grupo de serviços 
            lRet := .F.
        EndIf
    EndIf    
return lRet