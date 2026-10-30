CREATE PROCEDURE MSSOMA1
(
 IN IN_SOMAR VARCHAR( 100 ) , 
 IN IN_SOMALOW CHAR( 01 ) , 
 OUT OUT_RESULTADO VARCHAR( 100 ) 
)
 
LANGUAGE SQL
 
BEGIN
 declare vIAUX INTEGER ;
 declare vITAMORI INTEGER ;
 declare vINX INTEGER ;
 declare vCNEXT CHAR( 01 ) ;
 declare vCSPACE CHAR( 01 ) ;
 declare vCREF VARCHAR( 1 ) ;
 declare vCRESULT VARCHAR( 100 ) ;
 declare vITAMSTR INTEGER ;
 
 set vITAMSTR  =  (LENGTH ( IN_SOMAR  || '#' ) - 1 ) ;
 set vITAMORI  =  (LENGTH ( IN_SOMAR  || '#' ) - 1 ) ;
 set vIAUX  = 1 ;
 set vINX  = 1 ;
 set vCREF  = ' ' ;
 set vCNEXT  = '0' ;
 set vCSPACE  = '0' ;
 set vCRESULT  = ' ' ;
 IF LENGTH ( RTRIM ( IN_SOMAR )) = 0  THEN 
  CALL MSSTRZERO (vIAUX , vITAMSTR , OUT_RESULTADO );
 ELSE 
  IF IN_SOMAR  = REPEAT( '*' , vITAMORI) THEN 
   set OUT_RESULTADO  = IN_SOMAR ;
  ELSE 
   parse1:
   WHILE (vITAMSTR  >= vINX ) DO
    set vCREF  = SUBSTR ( IN_SOMAR  || '#' , vITAMSTR , 1 );
    IF vCREF  = ' '  THEN 
     set vCRESULT  = ' '  || vCRESULT ;
     set vCNEXT  = '1' ;
     set vCSPACE  = '1' ;
    ELSE 
     IF IN_SOMAR  =  REPEAT( 'Z' , vITAMORI)  THEN 
      set vCRESULT  = REPEAT( '*' , vITAMORI) ;
      leave parse1;
     ELSE 
      IF vCREF  < '9'  THEN 
       set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || CHR ( ASCII ( vCREF ) + 1 ) || vCRESULT ;
       set vCNEXT  = '0' ;
      ELSE 
       IF  (vCREF  = '9'  AND vITAMSTR  > 1 )  THEN 
        IF  (SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <= '9'  AND SUBSTR ( IN_SOMAR , vITAMSTR  - 1 , 1 ) <> ' ' )  THEN 
         set vCRESULT  = '0'  || vCRESULT ;
         set vCNEXT  = '1' ;
        ELSE 
         IF  (SUBSTR ( IN_SOMAR ,  ( vITAMSTR ) , 1 ) = ' ' )  THEN 
          set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 2 ) ) || '10'  || vCRESULT ;
          set vCNEXT  = '0' ;
         ELSE 
          set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || 'A'  || vCRESULT ;
          set vCNEXT  = '0' ;
         END IF;
        END IF;
       ELSE 
        IF vCREF  = '9'  AND  (vITAMSTR  = 1 )  AND  (vCSPACE  = '1' )  THEN 
         set vCRESULT  = '10'  || SUBSTR ( vCRESULT , 1 ,  (LENGTH ( vCRESULT  || '#' ) - 1 ) );
         set vCNEXT  = '0' ;
        ELSE 
         IF vCREF  = '9'  AND vITAMSTR  = 1  AND vCSPACE  = '0'  THEN 
          set vCRESULT  = 'A'  || vCRESULT ;
          set vCNEXT  = '0' ;
         ELSE 
          IF vCREF  > '9'  AND vCREF  < 'Z'  THEN 
           set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || CHR (  (ASCII ( vCREF ) + 1 ) ) || vCRESULT ;
           set vCNEXT  = '0' ;
          ELSE 
           IF vCREF  > 'Z'  AND vCREF  < 'Z'  THEN 
            set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || CHR (  (ASCII ( vCREF ) + 1 ) ) || vCRESULT ;
            set vCNEXT  = '0' ;
           ELSE 
            IF vCREF  = 'Z'  AND IN_SOMALOW  = '1'  THEN 
             set vCRESULT  = SUBSTR ( IN_SOMAR , 1 ,  (vITAMSTR  - 1 ) ) || 'A'  || vCRESULT ;
             set vCNEXT  = '0' ;
            ELSE 
             IF  (vCREF  = 'Z'  OR vCREF  = 'Z' )  AND vCSPACE  = '1'  THEN 
              set vCRESULT  = SUBSTR ( IN_SOMAR , 1 , vITAMSTR ) || '0'  || SUBSTR ( vCRESULT , 1 ,  (LENGTH ( vCRESULT  || '#' 
                     ) - 2 ) );
              set vCNEXT  = '0' ;
             ELSE 
              IF vCREF  = 'Z'  OR vCREF  = 'Z'  THEN 
               set vCRESULT  = '0'  || vCRESULT ;
               set vCNEXT  = '1' ;
              END IF;
             END IF;
            END IF;
           END IF;
          END IF;
         END IF;
        END IF;
       END IF;
      END IF;
     END IF;
    END IF;
    IF vCNEXT  = '0'  THEN 
     leave parse1;
    END IF;
    set vITAMSTR  = vITAMSTR  - 1 ;
   END WHILE;
   set OUT_RESULTADO  = vCRESULT ;
  END IF;
 END IF;
END
