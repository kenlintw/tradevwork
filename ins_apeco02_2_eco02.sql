create or replace 
PROCEDURE INS_APECO02_2_ECO02  IS

-- Copy eco02 message from DGOC_AP_ECO02A1 to DSW_ECO02_S1
-- 
-- 

BEGIN
   DECLARE
     V_PG_ID          	            VARCHAR2(70) := 'ins_APECO02_2_ECO02.prc';
     V_STR_VALUE    	              VARCHAR2(50) ;
     V_END_VALUE    	              VARCHAR2(50) ;
    
     V_S_TABLE_T1		                VARCHAR2(70) := 'DGOC_AP_ECO02A0' ;
     --V_S_TABLE_T2		                VARCHAR2(70) := 'DGOC_AP_X801B0' ;
     --V_S_TABLE_T3		                VARCHAR2(70) := 'DGOC_AP_X801A1' ;

     V_T_TABLE_T1		                VARCHAR2(70) := 'DSW_ECO02_S1' ;
     --V_T_TABLE_T2	 	                VARCHAR2(70) := 'DSW_NX801_S2' ;
     --V_T_TABLE_T3	 	                VARCHAR2(70) := 'DSW_NX801_CNTANR' ;

     S_DB_REC_T1                    DGOC_AP_ECO02A0%ROWTYPE;
     T_DB_REC_T1                    DSW_ECO02_S1%ROWTYPE;
 
     V_TRANSACTION_ID               VARCHAR2(24);
     X_TRANSACTION_ID               VARCHAR2(24);

     V_S_DB_CNT_T1                  NUMBER  := 0;
     V_S_DB_CNT_T2                  NUMBER  := 0;
     V_S_DB_CNT_T3                  NUMBER  := 0;
     V_S_DB_CNT_T4                  NUMBER  := 0;

     V_SEQ                          NUMBER  := 0;
     V_DATE                         VARCHAR2(24);
     V_STR_TIME                     VARCHAR2(24);
     V_END_TIME                     VARCHAR2(24);
     V_CUR_TIME                     VARCHAR2(24);
     V_TRAN_ID                      VARCHAR2(24);
     V_COMMIT_CNT                   NUMBER  := 1;

     V_ROWID                        ROWID;
     V_ROWID_T1                     ROWID;
     V_ROWID_T2                     ROWID;
     V_ROWID_T3                     ROWID;
     V_ROWID_T4                     ROWID;
     ERR_CODE                       VARCHAR2(120);
     PROC_TABLE                     VARCHAR2(20);
     M_CNT                          NUMBER  := 0;
     T_CNT                          NUMBER  := 0;

     V_TNAME                        VARCHAR2(50);
     V_C01                          VARCHAR2(150);
     V_C02                          VARCHAR2(150);
     V_C03                          VARCHAR2(150);
     V_C04                          VARCHAR2(150);
     V_C05                          VARCHAR2(150);
     INSERT_ERR 	            NUMBER  := 0;
     V_BAN_ID		            VARCHAR2(3);
     V_CONTAINER_NO	            VARCHAR2(17);
     V_OUTBOUND_FLG             VARCHAR2(1);
     V_L 			NUMBER  := 0;
     i   		                        NUMBER  := 0;
     j   		                        NUMBER  := 0;
    TEST_VAR1                       DATE;
    TEST_VAR2                       DATE;
    V_COMMIT_FLG          VARCHAR2(1) := '0' ;


     --  讀取海運 X801A0 資料
     CURSOR  SEL_DATA_T1       IS
             SELECT  *
               FROM   DGOC_AP_ECO02A0
               WHERE  APFO_DATE = '********'
            ORDER by TRANSACTION_ID;

     --  讀取海關資料庫資料
     --CURSOR  SEL_DATA_T2       IS
     --        SELECT   *
     --          FROM   DGOC_AP_ECO02A0
  	 --          WHERE  TRANSACTION_ID = V_TRANSACTION_ID
  	 --          ORDER  BY ITEM_NO;


     --錯誤處理
     --設定此SP 為獨立的transaction
     PROCEDURE DO_INFO IS PRAGMA AUTONOMOUS_TRANSACTION;
     BEGIN
        INSERT  INTO  SYS_ERR_01  (   TNAME
                                     ,C01
                                     ,C02
                                     ,C03
                                     ,C04
                                     ,C05
                                  )
                         VALUES   (   V_PG_ID
                                     ,TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')
                                     ,V_C02
                                     ,V_C03
                                     ,V_C04
                                     ,V_C05
                                  );
        COMMIT;
     END;

BEGIN
   
    SELECT  TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')
           ,TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
      INTO  V_STR_TIME
           ,V_TRAN_ID
      FROM  DUAL;

    -- 讀取海關表格 DGOC_AP_ECO02A0 此次截取筆數
    SELECT  COUNT(*)
      INTO  V_S_DB_CNT_T1
      FROM  DGOC_AP_ECO02A0
     WHERE  APFO_DATE     =  '********';

    V_C01 := 'GET DGOC_AP_ECO02A0 TEST DATA';
    V_C02 := TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS');
    V_C03 := 'DGOC_AP_ECO02A0 TOTAL CNT : ' || V_S_DB_CNT_T1 ;
    V_C04 := '' ;
    V_C05 := '';
    DO_INFO ;

    V_S_DB_CNT_T1 := 0;

    --  讀取海關 DGOC_AP_ECO02A0 資料
    OPEN  SEL_DATA_T1;
    LOOP
          --S_DB_REC_T1  :=  NULL;
          T_DB_REC_T1  :=  NULL;
          INSERT_ERR   :=  0 ;
          
          S_DB_REC_T1 := NULL;
          T_DB_REC_T1 := NULL;
          
          FETCH  SEL_DATA_T1
              INTO  S_DB_REC_T1;
          
          EXIT  WHEN SEL_DATA_T1%NOTFOUND;
         
          V_TNAME  := V_PG_ID ||' STEP: 2' ;
          V_C02  := 'TRAN_ID: ' || V_TRANSACTION_ID ;
          V_C03  := 'V_COMMIT_FLG: ' || V_COMMIT_FLG ;
          V_C04  := 'for check V_COMMIT_FLG ';
          --V_C05  := 'TRAN_ID: N ' || N_TRANSACTION_ID ;
          DO_INFO ;
          V_COMMIT_FLG := '0';
  
  	      BEGIN       
              INSERT INTO DSW_ECO02_S1 (   
                                       TRANS_ID          
                                      ,SENDER_ID         
                                      ,RECEIVER_ID       
  
                                      ,CONTROL_NUMBER    
                                      ,VAN_ID            
                                      --,DLVR_DATE         
                                      --,DEAL_DATE         
                                              
                                      ,CERT_NO           
                                      ,STATUS            
                                      ,STATUS_DESC       
                                      ,CUSTOMS_MESSAGE_ID
                                      
                                   )
                      VALUES       (                                           
                                      S_DB_REC_T1.TRANSACTION_ID           
                                      ,S_DB_REC_T1.SENDER_NAME          
                                      ,S_DB_REC_T1.RECEIVER_NAME        
          
                                      ,S_DB_REC_T1.CONTROL_NO    
                                      ,S_DB_REC_T1.VAN_ID             
                                      --,to_date(S_DB_REC_T1.APFO_DATE || ' ' || substr(S_DB_REC_T1.APFO_TIME,1,6), 'yyyymmdd hh24miss')          
                                      --,to_date(S_DB_REC_T1.DEAL_DATE || ' ' || substr(S_DB_REC_T1.DEAL_TIME,1,6), 'yyyymmdd hh24miss')
                                                 
                                      ,S_DB_REC_T1.CERTIFICATE_NO           
                                      ,S_DB_REC_T1.STATUS_CODE             
                                      ,S_DB_REC_T1.CODE_DESC        
                                      ,S_DB_REC_T1.CUSTOMS_MESSAGE_ID 
                                   );
          
             INSERT INTO ACI_CSZOBBL  (  TRANS_ID
     		                               ,MSG_TYPE
     		                               ,SENDER_ID
     		                               ,RECEIVER_ID
     		                               ,CONTROL_NO
     		                               ,VAN_ID
     		                               ,WRITE_DATE
     		                               ,DEAL_DATE
     		                             )
     	                       VALUES  (  S_DB_REC_T1.TRANSACTION_ID
     		                               ,'ECO02',
                                       'INC_APECO02_2_ECO02'
                                       ,'CUSTBM'
     		                               ,S_DB_REC_T1.CONTROL_NO
     		                               ,S_DB_REC_T1.VAN_ID
     		                               ,SYSDATE
     		                               ,TO_DATE('00010101','yyyymmdd')
     	                                );
            V_COMMIT_FLG := '0';
            DBMS_output.put_line('寫一筆EVENT入 ACI_CSZOBBL/' || 'WRITE_DATE=' || SYSDATE || 'DEAL_DATE=' || TO_DATE('00010101','yyyymmdd'));
            COMMIT;
             
          EXCEPTION
             WHEN   OTHERS  THEN
                    INSERT_ERR := 1;
                    ERR_CODE   :=  SUBSTR(SQLERRM,1,120);
                    DBMS_output.put_line('ERROR : ' || ERR_CODE);
                    DO_INFO ;

		         V_COMMIT_FLG := '1';
		         ROLLBACK;
          END;
          V_S_DB_CNT_T1 := V_S_DB_CNT_T1 + 1;


         -- 讀取資料須將 DGOC_AP_ECO02A0 資料 UPDATE
         
         BEGIN
           UPDATE  DGOC_AP_ECO02A0
              SET  APFO_DATE       =  TO_CHAR(SYSDATE,'YYYYMMDD')
                  ,APFO_TIME       =  TO_CHAR(SYSDATE,'HH24MISS')
                  
            WHERE  TRANSACTION_ID  =  S_DB_REC_T1.TRANSACTION_ID
              AND  APFO_DATE       =  '********';
            COMMIT;          
         EXCEPTION
            WHEN  OTHERS  THEN
                  ERR_CODE   :=  SUBSTR(SQLERRM,1,120);
                  INSERT_ERR := 1;
                  V_TNAME    := V_PG_ID ||' SEQ: '|| LPAD(TO_CHAR(T_CNT),10,'0');
                  V_C02      := 'TRAN_ID: ' || V_TRANSACTION_ID ;
                  V_C04      := ERR_CODE ;
                  V_C05      := 'PROC TABLE : UPDATE DGOC_AP_ECO02A0';
                  DO_INFO ;
         END;
         
         
    END LOOP;
    T_CNT  :=  T_CNT + M_CNT ;
    V_END_TIME := TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS');
    INSERT INTO SYS_ERR_01 (   TNAME
                              ,C01
                              ,C02
                              ,C03
                            )
                    VALUES (   V_PG_ID
                              ,'INSERT NX801_S1 DATA'
                              ,TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')
                              ,'SELECT CNT: ' || to_char(V_S_DB_CNT_T1) || ' Fetch cnt: '|| to_char(T_CNT)
                            );

   CLOSE SEL_DATA_T1;
   COMMIT;

   EXCEPTION
         WHEN   OTHERS  THEN
                ERR_CODE   :=  SUBSTR(SQLERRM,1,120);
                INSERT_ERR := 1;
		            V_TNAME := V_PG_ID ||' SEQ: '||LPAD(TO_CHAR(T_CNT),10,'0');
                V_C02 := 'TRAN_ID: ' || V_TRANSACTION_ID ;
                V_C04 := ERR_CODE ;
                DO_INFO ;
   END;
  END;
