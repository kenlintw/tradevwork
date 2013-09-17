create or replace 
PROCEDURE PROC_ECO01_VERIFY
(       in_CUSTOMS_MESSAGE_ID            IN  VARCHAR2
        --out_ERR_CODE          OUT VARCHAR2
)        
IS
BEGIN
 DECLARE
 
   --T_DB_REC_T1           DGOC_AP_ECO01A0%ROWTYPE;
   --T_DB_REC_T2           DGOC_AP_ECO01B0%ROWTYPE;
   ERR_CODE              VARCHAR2(120);
 
   V_PG_ID               VARCHAR2(70) := 'PROC_ECO01_VERIFY';
   DSW_VALUE             VARCHAR2(150) ;
   DGOC_VALUE            VARCHAR2(150) ;
   VERIFY_RESULT         VARCHAR2(50);
   l_strSQL              VARCHAR2(1000);
   l_str_DSW_COL_NAME    VARCHAR2(500);
   l_str_DGOC_COL_NAME   VARCHAR2(500);
   l_str_Temp            VARCHAR2(100);
   l_str_CNM             VARCHAR2(100);
   ONE_VERIFY_COLUMN_MAPPING  VERIFY_COLUMN_MAPPING%ROWTYPE;

   TEST_VAR1             DATE;
  

      CURSOR CUR_VERIFY_COLUMN_MAPPING IS                            
       select * from  verify_column_mapping where tname = 'ECO01';

  BEGIN
        --DBMS_output.put_line('your intput is: ' || in_TRANSID);
        -- 寫LOG以方便DEBUG
        INSERT  INTO  VERIFY_LOG_01  (   C00
                                     ,C01
                                  )
                         VALUES   (   'ECO01:比對中繼資料庫與海關資料庫...'
                                     , TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                                   );
  
              
        DSW_VALUE := '';
        DGOC_VALUE := '';
        VERIFY_RESULT := '值不相同';
  
        -- 複寫該筆由DSW_ECO01_S1至DGOC_AP_ECO01A0 
        BEGIN

                IF (DSW_VALUE = DGOC_VALUE) THEN
                       VERIFY_RESULT := '值相同';
                ELSE
                      VERIFY_RESULT := '值不相同';
                END IF;
                
                OPEN CUR_VERIFY_COLUMN_MAPPING; 
                LOOP
                  FETCH CUR_VERIFY_COLUMN_MAPPING INTO ONE_VERIFY_COLUMN_MAPPING;
                  EXIT WHEN CUR_VERIFY_COLUMN_MAPPING%NOTFOUND;
 
                  l_strSQL := 'SELECT a.' || ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME || ', b.' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || 
                  ' from dsw_eco01_s1 a, dgoc_ap_eco01a0 b where a.customs_message_id = b.customs_message_id and a.trans_id = b.transaction_id' ||
                  ' and a.customs_message_id = ''' ||  in_CUSTOMS_MESSAGE_ID || '''  and a.trans_id like ''20130917%''';
  
                  IF  ONE_VERIFY_COLUMN_MAPPING.HC = 'Y'  THEN
                      CASE 
                      WHEN SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME,1,6) = 'NO_CP_' THEN
                        l_str_CNM := SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, 7, LENGTH(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME) - 6);
                        l_str_Temp := '''' || l_str_CNM || '''';
                        DBMS_output.put_line('ls_str_Temp:' || l_str_Temp );
                      WHEN SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, -9, 9) = '_YYYYMMDD' THEN
                        l_str_CNM := SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, 1, LENGTH(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME) - 9);
                        l_str_Temp := 'to_char(a.' || l_str_CNM || ',''yyyymmdd'')';
                      WHEN SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, -9, 9) = '_HH24MISS' THEN  
                        l_str_CNM := SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, 1, LENGTH(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME) - 9);
                        l_str_Temp := 'to_char(a.' || l_str_CNM || ',''hh24miss'')';
                      WHEN SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, 1, 11) = 'SYSDATE_YMD' THEN  
                        l_str_Temp := 'to_char(sysdate,''yyyymmdd'')';     
                       WHEN SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, 1, 11) = 'SYSDATE_HMS' THEN  
                        l_str_Temp := 'to_char(sysdate,''hh24miss'')';    
                       WHEN SUBSTR(ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME, 1, 9) = '8ASTERISK' THEN  
                        l_str_Temp := '''********''';       
                      ELSE 
                        l_str_Temp := 'ERROR!!';
                      END CASE;
                      
                      --l_strSQL := 'SELECT ' || l_str_Temp || ' , b.' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || 
                      --            ' from dsw_eco01_s1 a, dgoc_ap_eco01a0 b where a.customs_message_id = b.customs_message_id and a.trans_id = b.transaction_id' ||
                      --            ' and a.customs_message_id = ''' ||  in_CUSTOMS_MESSAGE_ID || '''  and a.trans_id like ''20130917%'';';
                      l_strSQL := 'SELECT NVL(' || l_str_Temp || ',''N/A'') ' || ' , ' || 'NVL(' || 'b.' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || ',''N/A'') ' || 
                                  ' from dsw_eco01_s1 a, dgoc_ap_eco01a0 b where a.customs_message_id = b.customs_message_id and a.trans_id = b.transaction_id' ||
                                  ' and a.customs_message_id = ''' ||  in_CUSTOMS_MESSAGE_ID || '''  and a.trans_id like ''20130917%''';
                      
                      INSERT INTO VERIFY_COLUMN_MAPPING (TNAME, L_SQL) VALUES ('SQL_LOG', l_strSQL);   
                      commit;
                      execute immediate l_strSQL into l_str_DSW_COL_NAME, l_str_DGOC_COL_NAME ; 
                  
                  ELSE
                      --l_strSQL := 'SELECT a.' || ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME || ', b.' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || 
                      --            ' from dsw_eco01_s1 a, dgoc_ap_eco01a0 b where a.customs_message_id = b.customs_message_id and a.trans_id = b.transaction_id' ||
                      --            ' and a.customs_message_id = ''' ||  in_CUSTOMS_MESSAGE_ID || '''  and a.trans_id like ''20130917%'';';
                      l_strSQL := 'SELECT NVL(a.' || ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME || ',''N/A'')' || ', NVL(' || 'b.' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || ',''N/A'') ' ||
                                  ' from dsw_eco01_s1 a, dgoc_ap_eco01a0 b where a.customs_message_id = b.customs_message_id and a.trans_id = b.transaction_id' ||
                                  ' and a.customs_message_id = ''' ||  in_CUSTOMS_MESSAGE_ID || '''  and a.trans_id like ''20130917%''';
                      INSERT INTO VERIFY_COLUMN_MAPPING (TNAME, L_SQL) VALUES ('SQL_LOG', l_strSQL);            
                      commit;
                      execute immediate l_strSQL into l_str_DSW_COL_NAME, l_str_DGOC_COL_NAME; 
                      
                  
                  END IF;
   
                  
                  DBMS_output.put_line('比對' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || '....');
                  IF (TRIM(l_str_DSW_COL_NAME) = TRIM(l_str_DGOC_COL_NAME)) THEN
                       VERIFY_RESULT := '值相同';
                  ELSE
                      VERIFY_RESULT := '值不相同';
                  END IF;
                
                  DBMS_output.put_line('l_str_DSW_COL_NAME : ' || l_str_DSW_COL_NAME);
                  DBMS_output.put_line('l_str_DGOC_COL_NAME : ' || l_str_DGOC_COL_NAME);
                 
                END LOOP;
                CLOSE CUR_VERIFY_COLUMN_MAPPING;
                COMMIT;      
  
        EXCEPTION
                WHEN  OTHERS  THEN
                    ERR_CODE   :=  SUBSTR(SQLERRM,1,120);
                    DBMS_output.put_line('ERROR HAPPENED IN PROC_ECO01_VERIFY : ' || ERR_CODE);
                    rollback;
          END;       
          
  END;
END;