#include 'protheus.ch'
#include 'mntc281.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTC281
Análise de Sentimentos feita pela I.A.
@type function

@author Alexandre Santos
@since 12/02/2024                           	
/*/
//-------------------------------------------------------------------
Function MNTC281( oTemp280 )

    Local oProc696

    Private aSize281  := MsAdvSize()
    Private aGrid281  := {}
    Private aGrid2812 := {}
    
    Private oGrid281
    Private oGrid2812
    Private oTemp281

    Private cTotAtPos := ''
    Private cTotAtNeg := ''
    Private cTotAtNeu := ''
    Private cTotPrPos := ''
    Private cTotPrNeg := ''
    Private cTotPrNeu := ''

    Private cTotAtAle := ''
    Private cTotAtDes := ''
    Private cTotAtMed := ''
    Private cTotAtRai := ''
    Private cTotAtSur := ''
    Private cTotAtTri := ''
    Private cTotPrAle := ''
    Private cTotPrDes := ''
    Private cTotPrMed := ''
    Private cTotPrRai := ''
    Private cTotPrSur := ''
    Private cTotPrTri := ''

    /*-------------------------------------------------+
    | Cria browse conforme dados da tabela temporária. |
    +-------------------------------------------------*/
    fCriaTemp()

    /*-------------------------------------------+
    | Faz a carga de dados na tabela temporária. |
    +-------------------------------------------*/
    oProc696 := MsNewProcess():New ( { |lEnd| fLoadTemp( @oProc696, oTemp280 ) }, STR0009, , .T. ) // Filtrando
    oProc696:Activate()

    /*-------------------------------------------------+
    | Cria browse conforme dados da tabela temporária. |
    +-------------------------------------------------*/
    fCriaBrow()

    FWFreeArray( aSize281 )
    FWFreeArray( aGrid281 )
    FWFreeArray( aGrid2812 )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaBrow
Cria o browse principal da consulta.
@type function

@author Alexandre Santos
@since 12/02/2024

@param 
@return
/*/
//---------------------------------------------------------------------
Static Function fCriaBrow()

    Local aFolder  := { STR0001, STR0002 } // Prazo ## Atendimento
    
    Local oDlg281
    Local oPnl0
    Local oFold281

    DEFINE MSDIALOG oDlg281 TITLE STR0003 From aSize281[7],0 TO aSize281[6],aSize281[5] PIXEL // Análise de Sentimentos por I.A.

        oDlg281:lMaximized := .T.

        // Monta Tela Principal
	    oPnl0 := TPanel():New( 0, 0, , oDlg281, , , , , , 10, 10, .F., .F. )
		    oPnl0:Align := CONTROL_ALIGN_ALLCLIENT

            oFold281 := TFolder():New( 0, 0, aFolder, , oPnl0, , , , .F., .F., 0 , 0 )
                oFold281:Align := CONTROL_ALIGN_ALLCLIENT

                /*---------------------------------------------------------------+
                | Montagem superior da tela, referente a análise de sentimentos. |
                +---------------------------------------------------------------*/
                fBrowSent( oFold281 )

                /*------------------------------------------------------------+
                | Montagem da tela ao centro, referente a análise de emoções. |
                +------------------------------------------------------------*/
                fBrowEmoc( oFold281 )

                /*---------------------------------------------------------------+
                | Montagem da tela inferior, referente a análise de sentimentos. |
                +---------------------------------------------------------------*/
                fGridSent( oFold281 )

    ACTIVATE MSDIALOG oDlg281 CENTERED

    FWFreeArray( aFolder )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrowSent
Cria browse superior no qual é apresentado os sentimentos da análise.
@type function

@author Alexandre Santos
@since 12/02/2024

@param  oObjBrw, object, Indica o objeto pai, onde é montado o browse.
@return
/*/
//---------------------------------------------------------------------
Static Function fBrowSent( oObjBrw )

    Local nCenter  := Round( ( aSize281[5] / 2 ), 2 )
    Local nCenter2 := Round( ( nCenter / 2 ), 2 )

    Local oPnl1
    Local oGrp1
    Local oPnl11
    Local oPnl2
    Local oGrp2
    Local oPnl21

    oPnl1 := TPanel():New( 01, 01, , oObjBrw:aDialogs[1], , .T., , , , 0, 90 )
    oPnl1:Align := CONTROL_ALIGN_TOP

        oGrp1:= TGroup():New( 8, 5, 0, 0, STR0004, oPnl1 ) // Sentimentos
        oGrp1:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl11 := TPaintPanel():New( 0, 0, 10, 100, oGrp1, .F. )
            oPnl11:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl11:addShape( 'id=1'                                           +;
                             ';type=8'                                        +;
                             ';left=' + cValToChar( nCenter - nCenter2 - 65 ) +;
                             ';top=10'                                        +;
                             ';width=0.1'                                     +;
                             ';height=0.1'                                    +;
                             ';image-file=rpo:negative.png;' )
                
            oPnl11:addShape( 'id=2'                                           +;
                             ';type=7'                                        +;
                             ';pen-width=1'                                   +;
                             ';font=lucida console,14,0,0,3'                  +;
                             ';left=' + cValToChar( nCenter - nCenter2 - 38 ) +;
                             ';top=140'                                       +;
                             ';width=80'                                      +;
                             ';height=50'                                     +;
                             ';text=' + cTotAtNeg + ' %'                      +;
                             ';pen-color=#FF0000;' )

            oPnl11:addShape( 'id=3'                                +;
                             ';type=8'                             +;
                             ';left=' + cValToChar( nCenter - 65 ) +;
                             ';top=10'                             +;
                             ';width=0.1'                          +;
                             ';height=0.1'                         +;
                             ';image-file=rpo:neutral.png;' )

            oPnl11:addShape( 'id=4'                                +;
                             ';type=7'                             +;
                             ';pen-width=1'                        +;
                             ';font=lucida console,14,0,0,3'       +;
                             ';left=' + cValToChar( nCenter - 38 ) +;
                             ';top=140'                            +;
                             ';width=80'                           +;
                             ';height=50'                          +;
                             ';text=' + cTotAtNeu + ' %'           +;
                             ';pen-color=#B88F14;' )
                
            oPnl11:addShape( 'id=5'                                           +;
                             ';type=8'                                        +;
                             ';left=' + cValToChar( nCenter + nCenter2 - 65 ) +;
                             ';top=10'                                        +;
                             ';width=0.1'                                     +;
                             ';height=0.1'                                    +;
                             ';image-file=rpo:positive.png;' )

            oPnl11:addShape( 'id=6'                                           +;
                             ';type=7'                                        +;
                             ';pen-width=1'                                   +;
                             ';font=lucida console,14,0,0,3'                  +;
                             ';left=' + cValToChar( nCenter + nCenter2 - 38 ) +;
                             ';top=140'                                       +;
                             ';width=80'                                      +;
                             ';height=50'                                     +;
                             ';text=' + cTotAtPos + ' %'                      +;
                             ';pen-color=#008000;' )

    oPnl2 := TPanel():New( 01, 01, , oObjBrw:aDialogs[2], , .T., , , , 0, 90 )
    oPnl2:Align := CONTROL_ALIGN_TOP

        oGrp2:= TGroup():New( 8, 5, 0, 0, STR0004, oPnl2 ) // Sentimentos
        oGrp2:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl21 := TPaintPanel():New( 0, 0, 10, 100, oGrp2, .F. )
            oPnl21:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl21:addShape( 'id=7'                                           +;
                             ';type=8'                                        +;
                             ';left=' + cValToChar( nCenter - nCenter2 - 65 ) +;
                             ';top=10'                                        +;
                             ';width=0.1'                                     +;
                             ';height=0.1'                                    +;
                             ';image-file=rpo:negative.png;' )
                
            oPnl21:addShape( 'id=8'                                           +;
                             ';type=7'                                        +;
                             ';pen-width=1'                                   +;
                             ';font=lucida console,14,0,0,3'                  +;
                             ';left=' + cValToChar( nCenter - nCenter2 - 38 ) +;
                             ';top=140'                                       +;
                             ';width=80'                                      +;
                             ';height=50'                                     +;
                             ';text=' + cTotPrNeg + ' %'                      +;
                             ';pen-color=#FF0000;' )

            oPnl21:addShape( 'id=9'                                +;
                             ';type=8'                             +;
                             ';left=' + cValToChar( nCenter - 65 ) +;
                             ';top=10'                             +;
                             ';width=0.1'                          +;
                             ';height=0.1'                         +;
                             ';image-file=rpo:neutral.png;' )

            oPnl21:addShape( 'id=10'                               +;
                             ';type=7'                             +;
                             ';pen-width=1'                        +;
                             ';font=lucida console,14,0,0,3'       +;
                             ';left=' + cValToChar( nCenter - 38 ) +;
                             ';top=140'                            +;
                             ';width=80'                           +;
                             ';height=50'                          +;
                             ';text=' + cTotPrNeu + ' %'           +;
                             ';pen-color=#B88F14;' )
                
            oPnl21:addShape( 'id=11'                                          +;
                             ';type=8'                                        +;
                             ';left=' + cValToChar( nCenter + nCenter2 - 65 ) +;
                             ';top=10'                                        +;
                             ';width=0.1'                                     +;
                             ';height=0.1'                                    +;
                             ';image-file=rpo:positive.png;' )

            oPnl21:addShape( 'id=12'                                          +;
                             ';type=7'                                        +;
                             ';pen-width=1'                                   +;
                             ';font=lucida console,14,0,0,3'                  +;
                             ';left=' + cValToChar( nCenter + nCenter2 - 38 ) +;
                             ';top=140'                      +;
                             ';width=80'                     +;
                             ';height=50'                    +;
                             ';text=' + cTotPrPos + ' %'     +;
                             ';pen-color=#008000;' )
    
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} fBrowEmoc
Cria browse central no qual é apresentado as emoções da análise.
@type function

@author Alexandre Santos
@since 12/02/2024

@param  oObjBrw, object, Indica o objeto pai, onde é montado o browse.
@return
/*/
//---------------------------------------------------------------------
Static Function fBrowEmoc( oObjBrw )

    Local nPosIni  := Round( ( aSize281[5] / 7 ), 2 )

    Local oPnl4
    Local oPnl41
    Local oGrp4 
    Local oPnl5
    Local oPnl51
    Local oGrp5   

    oPnl4 := TPanel():New( 0, 0, , oObjBrw:aDialogs[1], , .T., , , , 0, 80 )
    oPnl4:Align := CONTROL_ALIGN_TOP

        oGrp4:= TGroup():New( 5, 5, 0, 0, STR0005, oPnl4 ) // Emoções
        oGrp4:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl41 := TPaintPanel():New( 0, 0, 10, 100, oGrp4, .F. )
            oPnl41:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl41:addShape( 'id=13'                              +;
                            ';type=8'                             +;
                            ';left=' + cValToChar( nPosIni - 45 ) +;
                            ';top=10 '                            +;
                            ';width=0.1'                          +;
                            ';height=0.1'                         +;
                            ';image-file=rpo:angry.png;' )
                
            oPnl41:addShape( 'id=14'                              +;
                            ';type=7'                             +;
                            ';pen-width=1'                        +;
                            ';font=lucida console,14,0,0,3'       +;
                            ';left=' + cValToChar( nPosIni - 30 ) +;
                            ';top=120'                            +;
                            ';width=80'                           +;
                            ';height=50'                          +;
                            ';text=' + cTotAtTri + ' %'           +;
                            ';pen-color=#000000;' )

            oPnl41:addShape( 'id=15'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 2 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:disgusted.png;' )
        
            oPnl41:addShape( 'id=16'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 2 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotAtDes + ' %'                   +;
                            ';pen-color=#000000;' )
        
            oPnl41:addShape( 'id=17'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 3 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:fear.png;' )

            oPnl41:addShape( 'id=18'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 3 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotAtMed + ' %'                   +;
                            ';pen-color=#000000;' )

            oPnl41:addShape( 'id=19'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 4 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:happy.png;' )
            
            oPnl41:addShape( 'id=20'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 4 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotAtAle + ' %'                   +;
                            ';pen-color=#000000;' )

            oPnl41:addShape( 'id=21'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 5 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:sad.png;' )

            oPnl41:addShape( 'id=22'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 5 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotAtRai + ' %'                   +;
                            ';pen-color=#000000;' )
        
            oPnl41:addShape( 'id=23'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 6 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:surprise.png;' )

            oPnl41:addShape( 'id=24'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 6 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotAtSur + ' %'                   +;
                            ';pen-color=#000000;' )
    
    oPnl5 := TPanel():New( 0, 0, , oObjBrw:aDialogs[2], , .T., , , , 0, 80 )
    oPnl5:Align := CONTROL_ALIGN_TOP

        oGrp5:= TGroup():New( 5, 5, 0, 0, STR0005, oPnl5 ) // Emoções
        oGrp5:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl51 := TPaintPanel():New( 0, 0, 10, 100, oGrp5, .F. )
            oPnl51:Align := CONTROL_ALIGN_ALLCLIENT

            oPnl51:addShape( 'id=25'                              +;
                            ';type=8'                             +;
                            ';left=' + cValToChar( nPosIni - 45 ) +;
                            ';top=10 '                            +;
                            ';width=0.1'                          +;
                            ';height=0.1'                         +;
                            ';image-file=rpo:angry.png;' )
                    
            oPnl51:addShape( 'id=26'                              +;
                            ';type=7'                             +;
                            ';pen-width=1'                        +;
                            ';font=lucida console,14,0,0,3'       +;
                            ';left=' + cValToChar( nPosIni - 30 ) +;
                            ';top=120'                            +;
                            ';width=80'                           +;
                            ';height=50'                          +;
                            ';text=' + cTotPrTri + ' %'           +;
                            ';pen-color=#000000;' )

            oPnl51:addShape( 'id=27'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 2 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:disgusted.png;' )
            
            oPnl51:addShape( 'id=28'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 2 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotPrDes + ' %'                   +;
                            ';pen-color=#000000;' )
            
            oPnl51:addShape( 'id=29'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 3 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:fear.png;' )

            oPnl51:addShape( 'id=30'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 3 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotPrMed + ' %'                   +;
                            ';pen-color=#000000;' )

            oPnl51:addShape( 'id=31'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 4 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:happy.png;' )
            
            oPnl51:addShape( 'id=32'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 4 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotPrAle + ' %'                   +;
                            ';pen-color=#000000;' )

            oPnl51:addShape( 'id=33'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 5 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:sad.png;' )

            oPnl51:addShape( 'id=34'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 5 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotPrRai + ' %'                   +;
                            ';pen-color=#000000;' )
            
            oPnl51:addShape( 'id=35'                                      +;
                            ';type=8'                                     +;
                            ';left=' + cValToChar( ( nPosIni * 6 ) - 55 ) +;
                            ';top=10 '                                    +;
                            ';width=0.1'                                  +;
                            ';height=0.1'                                 +;
                            ';image-file=rpo:surprise.png;' )

            oPnl51:addShape( 'id=36'                                      +;
                            ';type=7'                                     +;
                            ';pen-width=1'                                +;
                            ';font=lucida console,14,0,0,3'               +;
                            ';left=' + cValToChar( ( nPosIni * 6 ) - 40 ) +;
                            ';top=120'                                    +;
                            ';width=80'                                   +;
                            ';height=50'                                  +;
                            ';text=' + cTotPrSur + ' %'                   +;
                            ';pen-color=#000000;' )

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGridSent
Montagem do grid inferior, no qual é apresentado a comparação entre as
emoções da análise com as indicadas na S.S. pelo usuário.
@type function

@author Alexandre Santos
@since 12/02/2024

@param  oObjBrw, object, Indica o objeto pai, onde é montado o grid.
@return
/*/
//---------------------------------------------------------------------
Static Function fGridSent( oObjBrw )

    Local aFldsBrw  := {}
    Local aFldsBrw2 := {}

    Local oPnl3
    Local oPnl6
    Local oColuna

    oPnl3 := TPanel():New( 0, 0, , oObjBrw:aDialogs[1], , , , , , 0, 0 )
    oPnl3:Align := CONTROL_ALIGN_ALLCLIENT

        oColuna := FWBrwColumn():New()
        oColuna:SetAlign( CONTROL_ALIGN_LEFT )
        oColuna:SetData( &( '{ || aGrid281[oGrid281:At()][1] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( FWTamSX3( 'TQB_SOLICI' )[1] )
        oColuna:SetType( 'C' )
        oColuna:SetPicture( X3Picture( 'TQB_SOLICI' ) )
        oColuna:SetTitle( X3Titulo( 'TQB_SOLICI' ) )

        aAdd( aFldsBrw, oColuna )

        oColuna := FWBrwColumn():New()
        oColuna:SetData( &( '{ || aGrid281[oGrid281:At()][2] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( 2 )
        oColuna:SetType( 'C' )
        oColuna:SetPicture( '@BMP' )
        oColuna:SetTitle( STR0006 ) // Tempo
        oColuna:SetImage( .T. ) 
        oColuna:SetAlign( 2 )

        aAdd( aFldsBrw, oColuna )

        oColuna := FWBrwColumn():New()
        oColuna:SetData( &( '{ || aGrid281[oGrid281:At()][3] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( 2 )
        oColuna:SetType( 'C' )
        oColuna:SetPicture( '@BMP' )
        oColuna:SetTitle( STR0007 ) // Sentimento
        oColuna:SetImage( .T. ) 
        oColuna:SetAlign( 2 )

        aAdd( aFldsBrw, oColuna )

        oColuna := FWBrwColumn():New()
        oColuna:SetAlign( CONTROL_ALIGN_LEFT )
        oColuna:SetData( &( '{ || aGrid281[oGrid281:At()][4] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( FWTamSX3( 'TQB_OBSPRA' )[1] )
        oColuna:SetType( '@' )
        oColuna:SetPicture( X3Picture( 'TQB_OBSPRA' ) )
        oColuna:SetTitle( X3Titulo( 'TQB_OBSPRA' ) )

        aAdd( aFldsBrw, oColuna )

        oGrid281 := FWBrowse():New()
        oGrid281:SetOwner( oPnl3 )
        oGrid281:SetDataArray()
        oGrid281:SetInsert( .F. )
        oGrid281:DisableConfig() 
        oGrid281:DisableFilter() 
        oGrid281:DisableLocate() 
        oGrid281:DisableReport() 
        oGrid281:DisableSaveConfig()
        oGrid281:SetColumns( aFldsBrw )
        oGrid281:SetArray( aGrid281 )
        oGrid281:Activate()

    oPnl6 := TPanel():New( 0, 0, , oObjBrw:aDialogs[2], , , , , , 0, 0 )
    oPnl6:Align := CONTROL_ALIGN_ALLCLIENT

        oColuna := FWBrwColumn():New()
        oColuna:SetAlign( CONTROL_ALIGN_LEFT )
        oColuna:SetData( &( '{ || aGrid2812[oGrid2812:At()][1] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( FWTamSX3( 'TQB_SOLICI' )[1] )
        oColuna:SetType( 'C' )
        oColuna:SetPicture( X3Picture( 'TQB_SOLICI' ) )
        oColuna:SetTitle( X3Titulo( 'TQB_SOLICI' ) )

        aAdd( aFldsBrw2, oColuna )

        oColuna := FWBrwColumn():New()
        oColuna:SetData( &( '{ || aGrid2812[oGrid2812:At()][2] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( 2 )
        oColuna:SetType( 'C' )
        oColuna:SetPicture( '@BMP' )
        oColuna:SetTitle( STR0002 ) // Atendimento
        oColuna:SetImage( .T. ) 
        oColuna:SetAlign( 2 )

        aAdd( aFldsBrw2, oColuna )

        oColuna := FWBrwColumn():New()
        oColuna:SetData( &( '{ || aGrid2812[oGrid2812:At()][3] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( 2 )
        oColuna:SetType( 'C' )
        oColuna:SetPicture( '@BMP' )
        oColuna:SetTitle( STR0007 ) // Sentimento
        oColuna:SetImage( .T. ) 
        oColuna:SetAlign( 2 )

        aAdd( aFldsBrw2, oColuna )

        oColuna := FWBrwColumn():New()
        oColuna:SetAlign( CONTROL_ALIGN_LEFT )
        oColuna:SetData( &( '{ || aGrid2812[oGrid2812:At()][4] }' ) )
        oColuna:SetEdit( .F. )
        oColuna:SetSize( FWTamSX3( 'TQB_OBSPRA' )[1] )
        oColuna:SetType( '@' )
        oColuna:SetPicture( X3Picture( 'TQB_OBSPRA' ) )
        oColuna:SetTitle( X3Titulo( 'TQB_OBSPRA' ) )

        aAdd( aFldsBrw2, oColuna )

        oGrid2812 := FWBrowse():New()
        oGrid2812:SetOwner( oPnl6 )
        oGrid2812:SetDataArray()
        oGrid2812:SetInsert( .F. )
        oGrid2812:DisableConfig() 
        oGrid2812:DisableFilter() 
        oGrid2812:DisableLocate() 
        oGrid2812:DisableReport() 
        oGrid2812:DisableSaveConfig()
        oGrid2812:SetColumns( aFldsBrw2 )
        oGrid2812:SetArray( aGrid2812 )
        oGrid2812:Activate()

    FWFreeArray( aFldsBrw )
    FWFreeArray( aFldsBrw2 )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCriaTemp
Cria a tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 12/02/2024

@param
@return
/*/
//---------------------------------------------------------------------
Static Function fCriaTemp()

    Local aFields  := {}
    Local cAls696  := GetNextAlias()

    aAdd( aFields, { 'IA_RECNO' , 'N', 15, 00 } )
    aAdd( aFields, { 'IA_SOLICI', 'C', 06, 00 } )
    aAdd( aFields, { 'IA_TIPOAN', 'N', 01, 00 } )
    aAdd( aFields, { 'IA_RAIVA' , 'N', 01, 00 } )
    aAdd( aFields, { 'IA_DESGOS', 'N', 01, 00 } )
    aAdd( aFields, { 'IA_MEDO'  , 'N', 01, 00 } )
    aAdd( aFields, { 'IA_ALEGRE', 'N', 01, 00 } )
    aAdd( aFields, { 'IA_TRISTE', 'N', 01, 00 } )
    aAdd( aFields, { 'IA_SURPRE', 'N', 01, 00 } )
    aAdd( aFields, { 'IA_SENTIM', 'N', 01, 00 } )
    
	oTemp281 := FWTemporaryTable():New( cAls696, aFields )

    oTemp281:AddIndex( '1', { 'IA_TIPOAN', 'IA_SOLICI' })

	oTemp281:Create()

    FWFreeArray( aFields )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadTemp
Carga inicial da tabela temporária da rotina.
@type function

@author Alexandre Santos
@since 12/02/2024

@param oProc696, object, Objeto MsNewProcess.
@param oTemp280, object, Tabela temporaria contendo as S.S. filtradas.
@return
/*/
//---------------------------------------------------------------------
Static Function fLoadTemp( oProc696, oTemp280 )

    Local aObjects  := {}
    Local cAls281   := oTemp281:GetAlias()
    Local cEmjSent  := ''

    Local nInd1     := 0

    Local nPrPosit  := 0
    Local nPrNegat  := 0
    Local nPrNeutr  := 0
    Local nAtPosit  := 0
    Local nAtNegat  := 0
    Local nAtNeutr  := 0

    Local nPrAlegre := 0
    Local nPrDesgos := 0
    Local nPrMedo   := 0
    Local nPrRaiva  := 0
    Local nPrSurpre := 0
    Local nPrTriste := 0
    Local nAtAlegre := 0
    Local nAtDesgos := 0
    Local nAtMedo   := 0
    Local nAtRaiva  := 0
    Local nAtSurpre := 0
    Local nAtTriste := 0

    Local nPrTotal  := 0
    Local nAtTotal  := 0

    Local nLenGrid := 0

    cQueryTQI := "INSERT INTO " + oTemp281:GetRealName()
    cQueryTQI +=     " ( "
    cQueryTQI +=      " IA_RECNO , "
    cQueryTQI +=      " IA_SOLICI, "
    cQueryTQI +=      " IA_TIPOAN, "
    cQueryTQI +=      " IA_RAIVA , "
    cQueryTQI +=      " IA_DESGOS, "
    cQueryTQI +=      " IA_MEDO  , "
    cQueryTQI +=      " IA_ALEGRE, "
    cQueryTQI +=      " IA_TRISTE, "
    cQueryTQI +=      " IA_SURPRE, "
    cQueryTQI +=      " IA_SENTIM  "
    cQueryTQI +=     " ) "
    
    cQueryTQI += "SELECT "
    cQueryTQI +=      "TQB.R_E_C_N_O_, "
    cQueryTQI +=      "TQB.TQB_SOLICI, "
    cQueryTQI +=      "1             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "0               "
    cQueryTQI += "FROM "
    cQueryTQI +=      RetSqlName( 'TQB' ) + " TQB " 
    cQueryTQI += "INNER JOIN "
    cQueryTQI +=      oTemp280:GetRealName() + " TRB ON " 
    cQueryTQI +=        " TQB.TQB_FILIAL  =  TRB.DT_FILIAL AND "
    cQueryTQI +=        " TQB.TQB_SOLICI  =  TRB.DT_SOLICI "
    cQueryTQI += "WHERE"
    cQueryTQI +=    " TQB.D_E_L_E_T_  = ' '"

    cQueryTQI += "UNION "

    cQueryTQI += "SELECT "
    cQueryTQI +=      "TQB.R_E_C_N_O_, "
    cQueryTQI +=      "TQB.TQB_SOLICI, "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "2             , "
    cQueryTQI +=      "0               "
    cQueryTQI += "FROM "
    cQueryTQI +=      RetSqlName( 'TQB' ) + " TQB " 
    cQueryTQI += "INNER JOIN "
    cQueryTQI +=      oTemp280:GetRealName() + " TRB ON " 
    cQueryTQI +=        " TQB.TQB_FILIAL  =  TRB.DT_FILIAL AND "
    cQueryTQI +=        " TQB.TQB_SOLICI  =  TRB.DT_SOLICI "
    cQueryTQI += "WHERE"
    cQueryTQI +=    " TQB.D_E_L_E_T_  = ' '"

    TcSQLExec( cQueryTQI )

    /*------------------------------------------+
    | Processa requisição da API de sentimentos |
    +------------------------------------------*/
    aObjects := fGetSentim()

    For nInd1 := 1 To Len( aObjects )

        dbSelectArea( cAls281 )
        dbSetOrder( 1 )
        If msSeek( aObjects[nInd1]['id'] )

            TQB->( msGoTo( (cAls281)->IA_RECNO ) )

            /*-------------------------------------------------+
            | Análise de sentimentos para Prazo de atendimento |
            +-------------------------------------------------*/
            If (cAls281)->IA_TIPOAN == 1

                RecLock( cAls281, .F. )
                    
                    Do Case

                        Case aObjects[nInd1]['emotion']['anger']
                        
                            IA_RAIVA  := 1
                            nPrRaiva++
                        
                        Case aObjects[nInd1]['emotion']['disgust']
                        
                            IA_DESGOS := 1
                            nPrDesgos++

                        Case aObjects[nInd1]['emotion']['fear']
                        
                            IA_MEDO   := 1
                            nPrMedo++

                        Case aObjects[nInd1]['emotion']['joy']
                        
                            IA_ALEGRE := 1
                            nPrAlegre++

                        Case aObjects[nInd1]['emotion']['sadness']
                        
                            IA_TRISTE := 1
                            nPrTriste++

                        Case aObjects[nInd1]['emotion']['surprise']
                        
                            IA_SURPRE := 1
                            nPrSurpre++

                    End Case

                    IA_SENTIM := aObjects[nInd1]['sentiment']
                    nPrTotal++

                MsUnLock()

                /*----------------------------------------------+
                | Define imagem do sentimento retornado pela IA |
                +----------------------------------------------*/
                If (cAls281)->IA_SENTIM == 2

                    cEmjSent := 'positive_mini'
                    nPrPosit++

                ElseIf (cAls281)->IA_SENTIM == 1

                    cEmjSent := 'neutral_mini'
                    nPrNeutr++

                Else

                    cEmjSent := 'negative_mini'
                    nPrNegat++

                EndIf

                /*---------------------------------------+
                | Grava divergência de sentimento neutro |
                +---------------------------------------*/
                If Val( TQB->TQB_PSAP ) == 3 .And.;
                    (cAls281)->IA_SENTIM != 1
                    
                    aAdd( aGrid281, Array( 4 ) )
                    nLenGrid := Len(aGrid281)
                    
                    aGrid281[nLenGrid,1] := TQB->TQB_SOLICI
                    aGrid281[nLenGrid,2] := 'neutral_mini'
                    aGrid281[nLenGrid,3] := cEmjSent
                    aGrid281[nLenGrid,4] := TQB->TQB_OBSPRA

                EndIf
                
                /*-----------------------------------------+
                | Grava divergência de sentimento positivo |
                +-----------------------------------------*/
                If ( Val( TQB->TQB_PSAP ) == 1 .Or. Val( TQB->TQB_PSAP ) == 2 ) .And.;
                    (cAls281)->IA_SENTIM != 2 
                    
                    aAdd( aGrid281, Array( 4 ) )
                    nLenGrid := Len(aGrid281)
                    
                    aGrid281[nLenGrid,1] := TQB->TQB_SOLICI
                    aGrid281[nLenGrid,2] := 'positive_mini'
                    aGrid281[nLenGrid,3] := cEmjSent
                    aGrid281[nLenGrid,4] := TQB->TQB_OBSPRA

                EndIf

                /*-----------------------------------------+
                | Grava divergência de sentimento negativo |
                +-----------------------------------------*/
                If Val( TQB->TQB_PSAP ) == 4 .And.;
                    (cAls281)->IA_SENTIM != ( 0 )
                    
                    aAdd( aGrid281, Array( 4 ) )
                    nLenGrid := Len(aGrid281)
                    
                    aGrid281[nLenGrid,1] := TQB->TQB_SOLICI
                    aGrid281[nLenGrid,2] := 'negative_mini'
                    aGrid281[nLenGrid,3] := cEmjSent
                    aGrid281[nLenGrid,4] := TQB->TQB_OBSPRA

                EndIf

            /*---------------------------------------------------------+
            | Análise de sentimentos para satisfação com o atendimento |
            +---------------------------------------------------------*/
            Else

                RecLock( cAls281, .F. )
                    
                    Do Case

                        Case aObjects[nInd1]['emotion']['anger']
                        
                            IA_RAIVA  := 1
                            nAtRaiva++
                        
                        Case aObjects[nInd1]['emotion']['disgust']
                        
                            IA_DESGOS := 1
                            nAtDesgos++

                        Case aObjects[nInd1]['emotion']['fear']
                        
                            IA_MEDO   := 1
                            nAtMedo++

                        Case aObjects[nInd1]['emotion']['joy']
                        
                            IA_ALEGRE := 1
                            nAtAlegre++

                        Case aObjects[nInd1]['emotion']['sadness']
                        
                            IA_TRISTE := 1
                            nAtTriste++

                        Case aObjects[nInd1]['emotion']['surprise']
                        
                            IA_SURPRE := 1
                            nAtSurpre++

                    End Case

                    IA_SENTIM := aObjects[nInd1]['sentiment']
                    nAtTotal++

                MsUnLock()

                /*----------------------------------------------+
                | Define imagem do sentimento retornado pela IA |
                +----------------------------------------------*/
                If (cAls281)->IA_SENTIM == 2

                    cEmjSent := 'positive_mini'
                    nAtPosit++

                ElseIf (cAls281)->IA_SENTIM == 1

                    cEmjSent := 'neutral_mini'
                    nAtNeutr++
                
                Else

                    cEmjSent := 'negative_mini'
                    nAtNegat++

                EndIf

                /*---------------------------------------+
                | Grava divergência de sentimento neutro |
                +---------------------------------------*/
                If Val( TQB->TQB_PSAN ) == 3 .And.;
                    (cAls281)->IA_SENTIM != 1
                    
                    aAdd( aGrid2812, Array( 4 ) )
                    nLenGrid := Len(aGrid2812)
                    
                    aGrid2812[nLenGrid,1] := TQB->TQB_SOLICI
                    aGrid2812[nLenGrid,2] := 'neutral_mini'
                    aGrid2812[nLenGrid,3] := cEmjSent
                    aGrid2812[nLenGrid,4] := TQB->TQB_OBSATE

                EndIf
                
                /*-----------------------------------------+
                | Grava divergência de sentimento positivo |
                +-----------------------------------------*/
                If ( Val( TQB->TQB_PSAN ) == 1 .Or. Val( TQB->TQB_PSAN ) == 2 ) .And.;
                    (cAls281)->IA_SENTIM != 2 
                    
                    aAdd( aGrid2812, Array( 4 ) )
                    nLenGrid := Len(aGrid2812)
                    
                    aGrid2812[nLenGrid,1] := TQB->TQB_SOLICI
                    aGrid2812[nLenGrid,2] := 'positive_mini'
                    aGrid2812[nLenGrid,3] := cEmjSent
                    aGrid2812[nLenGrid,4] := TQB->TQB_OBSATE

                EndIf

                /*-----------------------------------------+
                | Grava divergência de sentimento negativo |
                +-----------------------------------------*/
                If Val( TQB->TQB_PSAN ) == 4 .And.;
                    (cAls281)->IA_SENTIM != ( 0 )
                    
                    aAdd( aGrid2812, Array( 4 ) )
                    nLenGrid := Len(aGrid2812)
                    
                    aGrid2812[nLenGrid,1] := TQB->TQB_SOLICI
                    aGrid2812[nLenGrid,2] := 'negative_mini'
                    aGrid2812[nLenGrid,3] := cEmjSent
                    aGrid2812[nLenGrid,4] := TQB->TQB_OBSATE

                EndIf

            EndIf

        EndIf
        
    Next nInd1

    /*---------------------------------------+
    | Realiza calculo dos indicadores finais |
    +---------------------------------------*/
    fCalIndic( { nPrNegat, nPrNeutr, nPrPosit, nPrAlegre, nPrDesgos, nPrMedo, nPrRaiva, nPrSurpre, nPrTriste, nPrTotal },;
        { nAtNegat, nAtNeutr, nAtPosit, nAtAlegre, nAtDesgos, nAtMedo, nAtRaiva, nAtSurpre, nAtTriste, nAtTotal } )

    FWFreeArray( aObjects )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fCalIndic
Calcula percentual de cada indicador apresentado na consulta.
@type function

@author Alexandre Santos
@since 12/02/2024

@param aValPrazo, array, Valores referente ao folder Prazo.
@param aValAtend, array, Valores referente ao folder atendimento.
@return
/*/
//---------------------------------------------------------------------
Static Function fCalIndic( aValPrazo, aValAtend )

    /*-----------------------------------------+
    | Indicadores totais do folder atendimento |
    +-----------------------------------------*/
    cTotAtNeg  := cValToChar( Round( ( aValAtend[1] * 100 ) / aValAtend[10], 2 ) )

    cTotAtNeu  := cValToChar( Round( ( aValAtend[2] * 100 ) / aValAtend[10], 2 ) )

    cTotAtPos  := cValToChar( Round( ( aValAtend[3] * 100 ) / aValAtend[10], 2 ) )

    cTotAtAle  := cValToChar( Round( ( aValAtend[4] * 100 ) / aValAtend[10], 2 ) )

    cTotAtDes  := cValToChar( Round( ( aValAtend[5] * 100 ) / aValAtend[10], 2 ) )

    cTotAtMed  := cValToChar( Round( ( aValAtend[6] * 100 ) / aValAtend[10], 2 ) )

    cTotAtRai  := cValToChar( Round( ( aValAtend[7] * 100 ) / aValAtend[10], 2 ) )

    cTotAtSur  := cValToChar( Round( ( aValAtend[8] * 100 ) / aValAtend[10], 2 ) )

    cTotAtTri  := cValToChar( Round( ( aValAtend[9] * 100 ) / aValAtend[10], 2 ) )

    /*-----------------------------------+
    | Indicadores totais do folder prazo |
    +-----------------------------------*/
    cTotPrNeg  := cValToChar( Round( ( aValPrazo[1] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrNeu  := cValToChar( Round( ( aValPrazo[2] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrPos  := cValToChar( Round( ( aValPrazo[3] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrAle  := cValToChar( Round( ( aValPrazo[4] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrDes  := cValToChar( Round( ( aValPrazo[5] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrMed  := cValToChar( Round( ( aValPrazo[6] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrRai  := cValToChar( Round( ( aValPrazo[7] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrSur  := cValToChar( Round( ( aValPrazo[8] * 100 ) / aValPrazo[10], 2 ) )

    cTotPrTri  := cValToChar( Round( ( aValPrazo[9] * 100 ) / aValPrazo[10], 2 ) )
    
Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fGetSentim
Realiza comunicação com API para análise dos sentimentos.
@type function

@author Alexandre Santos
@since 12/02/2024

@param cObserv, string, Texto que será analisado pela IA.
@return object, Json contendo o retorno da API.
/*/
//---------------------------------------------------------------------
Static Function fGetSentim()
    
    Local aReturn    := {}
    Local cUrl       := "https://ai.ngi.com.br/graphql"
    Local cAls281    := oTemp281:GetAlias()
    Local cHead      := ''
    Local cBody      := ''
    Local cJSON      := ''
    Local nTimeOut   := 120
    Local aHeadOut   := {}
    Local cHeadRet   := ""
    Local sPostRet   := ""
    Local oJSON281   := JSONObject():New()

    dbSelectArea( cAls281 )
    dbGoTop()

    cHead := '{'
    cHead += '"query":"query sentimentsAnalysis( $texts: [SentimentToAnalysis!]! ) 
    cHead += '{ \n sentimentsAnalysis( texts: $texts ) { \n errors\n sentiment 
    cHead += '{ \n id\n emotion { \n anger\n disgust\n fear\n joy\n sadness\n surprise\n }
    cHead += '\n sentiment\n words { \n keywords\n sentence_count\n word_count\n }
    cHead += '\n text\n }\n success\n } \n }",
   
    While (cAls281)->( !EoF() )

        TQB->( msGoTo( (cAls281)->IA_RECNO ) )

        If Empty( cBody )

            cBody += '"variables": { '
            cBody += '"texts": [ { '

        Else

            cBody += ',{'

        EndIf
        
        If (cAls281)->IA_TIPOAN == 1

            cBody += '"id":"1'  + TQB->TQB_SOLICI + '",'
            cBody += '"text":"' + TQB->TQB_OBSPRA + '"'

        Else

            cBody += '"id":"2'  + TQB->TQB_SOLICI + '",'
            cBody += '"text":"' + TQB->TQB_OBSATE + '"'

        EndIf

        cBody += '}'

        (cAls281)->( dbSkip() )

    End

    cBody += '] } }'
    
    /*-------------------------------------------------------------------+
    | Trata encode correto para strings que possuam caracteres especiais |
    +-------------------------------------------------------------------*/
    cJSON := FWHttpEncode( cHead + cBody )
   
    aAdd(aHeadOut, "Content-Type: application/json")   
   
    /*----------------------------+
    | Realiza a requisição da API |
    +----------------------------*/
    sPostRet := HTTPPost( cUrl, '', cJSON, nTimeOut, aHeadOut, @cHeadRet )
    
    /*----------------------------+
    | Retorno com sucesso do JSON |
    +----------------------------*/
    If Empty( cError := oJSON281:FromJSON( sPostRet ) ) .And.;
        oJSON281['data']['sentimentsAnalysis']['success']

        aReturn := oJSON281['data']['sentimentsAnalysis']['sentiment']

    /*--------------------------------------+
    | Tratamento de erro no retorno do JSON |
    +--------------------------------------*/
    Else

        Help( '', 1, 'NGATENCAO', , STR0008 +; // Não foi possivel concluir a análise de sentimentos, avaliar o seguinte retorno:
            CRLF + CRLF + cError, 3, 1 )

    EndIf

Return aReturn
