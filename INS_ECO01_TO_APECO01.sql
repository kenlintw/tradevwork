create or replace 
PROCEDURE INS_ECO01_TO_APECO01
-- 


IS
BEGIN
 DECLARE
   V_PG_ID               VARCHAR2(70) := 'INS_ECO01_TO_APECO01.prc';
   V_STR_VALUE           VARCHAR2(50) ;
   V_END_VALUE           VARCHAR2(50) ;

   --單一窗口的二個Tables
   V_S_TABLE_T1          VARCHAR2(70) := 'DSW_ECO01_S1' ;
   V_S_TABLE_T2          VARCHAR2(70) := 'DSW_ECO01_S2' ;

   -- 海關的二個Tables
   V_T_TABLE_T1          VARCHAR2(70) := 'DGOC_AP_ECO01A0' ;
   V_T_TABLE_T2          VARCHAR2(70) := 'DGOC_AP_ECO01B0' ;

   -- 以下至TEST_VAR1為程式邏輯使用的變數
   S_DB_REC_T1           DSW_ECO01_S1%ROWTYPE;
   S_DB_REC_T2           DSW_ECO01_S2%ROWTYPE;

   T_DB_REC_T1           DGOC_AP_ECO01A0%ROWTYPE;
   T_DB_REC_T2           DGOC_AP_ECO01B0%ROWTYPE;
   T_DB_REC_T3           DGOC_AP_X802B0%ROWTYPE;

   V_TRANSACTION_ID      VARCHAR2(24);
   N_TRANSACTION_ID      VARCHAR2(24);
   V_RECV_DATE           DATE;

   V_S_DB_CNT_T1         NUMBER  := 0;
   V_S_DB_CNT_T2         NUMBER  := 0;
   V_S_DB_CNT_T3         NUMBER  := 0;
   V_S_DB_CNT_T4         NUMBER  := 0;

   V_SEQ                 NUMBER  := 0;
   V_DATE                VARCHAR2(24);
   V_STR_TIME            VARCHAR2(24);
   V_END_TIME            VARCHAR2(24);
   V_CUR_TIME            VARCHAR2(24);
   V_TRAN_ID             VARCHAR2(24);
   V_COMMIT_CNT          NUMBER  := 1;

   V_ROWID               ROWID;
   V_ROWID_T1            ROWID;
   V_ROWID_T2            ROWID;
   V_ROWID_T3            ROWID;
   V_ROWID_T4            ROWID;
   ERR_CODE              VARCHAR2(120);
   PROC_TABLE            VARCHAR2(20);
   M_CNT                 NUMBER  := 0;
   T_CNT                 NUMBER  := 0;

   V_TNAME               VARCHAR2(50);
   V_C01                 VARCHAR2(150);
   V_C02                 VARCHAR2(150);
   V_C03                 VARCHAR2(150);
   V_C04                 VARCHAR2(150);
   V_C05                 VARCHAR2(150);
   INSERT_ERR            NUMBER  := 0;

   i                     NUMBER  := 0;
   j                     NUMBER  := 0;
   m                     NUMBER  := 0;
   n                     NUMBER  := 0;
   V_ITEM_NO             DSW_ECO01_S2.ITEM_NO%TYPE;
   V_ERROR_CODE          VARCHAR2(198);
   V_COMMIT_FLG          VARCHAR2(1) := '0' ;

   TEST_VAR1             DATE;


   -- 取主表資料DSW_ECO01_S1
   CURSOR  SEL_DATA_T1 IS
           SELECT  *
             FROM  DSW_ECO01_S1
 	           WHERE
              --TO_CHAR(DEAL_DATE,'YYYYMMDD') = '00010101'; -- 目前由TV寫進單一窗的DEAL_DATE的值不是 MINI DATE, 而是NULL， 
              DEAL_DATE is null;                            -- 所以先暫時 WHREE DSW_ECO01_S1 is null 
              
 
     -- 獨立的Log Writer
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
                                     ,TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                                     ,V_C02
                                     ,V_C03
                                     ,V_C04
                                     ,V_C05
                                  );
        COMMIT;
     END;
 BEGIN

   V_TRAN_ID      := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
   V_C01          := V_TRAN_ID;
   V_S_DB_CNT_T1  := 0;
   
   S_DB_REC_T1 := NULL;
   T_DB_REC_T1 := NULL;
   S_DB_REC_T2 := NULL;
   T_DB_REC_T2 := NULL;
   
   

   OPEN  SEL_DATA_T1;
   LOOP
        FETCH  SEL_DATA_T1
            INTO  S_DB_REC_T1;
        EXIT  WHEN SEL_DATA_T1%NOTFOUND;

        V_TRANSACTION_ID := S_DB_REC_T1.TRANS_ID ;
        V_TNAME  := V_PG_ID ||' STEP: 2' ;
        V_C02  := 'TRAN_ID: ' || V_TRANSACTION_ID ;
        V_C03  := 'V_COMMIT_FLG: ' || V_COMMIT_FLG ;
        V_C04  := 'for check V_COMMIT_FLG ';
        V_C05  := 'TRAN_ID: N ' || N_TRANSACTION_ID ;
        DO_INFO ;
	      V_COMMIT_FLG := '0';



        
        -- 複寫該筆由DSW_ECO01_S1至DGOC_AP_ECO01A0 
        BEGIN
        INSERT INTO DGOC_AP_ECO01A0 ( TRANSACTION_ID
                                      ,VAN_ID
                                      ,SENDER_NAME
                                      ,SENDER_ID
                                      ,CONTROL_NO
                                      ,MESSAGE_FUNCTION
                                     ,DECL_NO
                                     ,CUSTOMS_MESSAGE_ID
                                     ,SHIPMENT
                                     ,SUPPLIER_NAME
                                     ,SUPPLIER_ADDRESS
                                     ,DUTY_PAYER_NAME
                                     ,DUTY_PAYER_BAN
                                     ,DUTY_PAYER_ADDRESS
                                     ,UNLOADING_PORT
                                     ,FINAL_CNTRY_CD
                                     ,VOYAG_NO
                                     ,CERTIFICATE_NO
                                     ,REFERENCE_CODE
                                     ,ORIG_CNTRY_CD
                                     ,EXP_ISSUE_PLACE
                                     ,EXP_ISSUE_DATE
                                     ,EXP_ISSUE_TIME
                                     ,CERTIFYING_AUTHORITY
                                     ,CERTIFYING_PLACE
                                     ,CERTIFYING_DATE
                                     ,CERTIFYING_TIME
                                     ,DEAL_DATE
                                     ,XML_EDI_FLAG
                                     ,RECEIVER_NAME
                                     --,APFI_DATE
                                     --,APFI_TIME

                                   )
                           VALUES  (  S_DB_REC_T1.TRANS_ID
                                     ,'1'
                                     ,'TVRTV'
                                     ,'X'
                                     ,'X'
                                     ,S_DB_REC_T1.MSG_FUNC_CD
                                     ,S_DB_REC_T1.DECL_NO
                                     ,S_DB_REC_T1.CUSTOMS_MESSAGE_ID
                                     ,S_DB_REC_T1.PORT_CD
                                     --,S_DB_REC_T1.SAL_ENAME
                                     ---,S_DB_REC_T1.SAL_EADDR
                                     ,SUBSTR(S_DB_REC_T1.SAL_ENAME,1,25)
                                     ,SUBSTR(S_DB_REC_T1.SAL_EADDR,1,25)
                                      ,S_DB_REC_T1.DUTY_PAYER_ENAME
                                     ,S_DB_REC_T1.DUTY_PAYER_BAN
                                     ,S_DB_REC_T1.DUTY_PAYER_EADDR
                                     ,S_DB_REC_T1.UNLOAD_PORT
                                     ,S_DB_REC_T1.DEST_CD
                                     ,S_DB_REC_T1.VOYAGE_NO
                                     ,S_DB_REC_T1.CERT_NO
                                     ,S_DB_REC_T1.REF_CD
                                     ,S_DB_REC_T1.ORG_COUNTRY_CD
                                     ,S_DB_REC_T1.EX_ISSUE_PLACE
                                     ,to_char(S_DB_REC_T1.EX_ISSUE_DATE,'yyyymmdd')
                                     ,to_char(S_DB_REC_T1.EX_ISSUE_DATE,'hh24mi')
                                     ,S_DB_REC_T1.CERTI_AUTH
                                     ,S_DB_REC_T1.CERTI_PLACE
                                     ,to_char(S_DB_REC_T1.CERTI_DATE,'yyyymmdd')
                                     ,to_char(S_DB_REC_T1.CERTI_DATE,'hh24mi')
                                     ,'********'
                                     ,'XML'
                                     ,'CTRXML'
                                     --,to_char(SYSDATE,'yyyymmdd')
                                     --,to_char(SYSDATE,'hh24mi') || '00'
                                   );
       -- 寫LOG以方便DEBUG
       INSERT  INTO  SYS_ERR_01  (   TNAME
                                     ,C01
                                     ,C02
                                     ,C03
                                     ,C04
  
                                  )
                         VALUES   (   'ECO01'
                                     ,'When: ' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                                     ,'Inserted one to dgoc_ap_eco01a0'
                                     ,S_DB_REC_T1.TRANS_ID
                                     ,S_DB_REC_T1.CUSTOMS_MESSAGE_ID
                                     
                                  );
                                  
       -- 複寫該訊息的細節檔由DSW_ECO01_S2至DGOC_AP_ECO01B0 
       INSERT INTO DGOC_AP_ECO01B0 (  TRANSACTION_ID
                                           ,SEQ_NO
                                           ,ITEM_ID
                                           ,ITEM_NO
                                           ,GOODS_DESC
                                           ,GROSS_WEIGHT
                                           ,GROSS_WEIGHT_UNIT
                                           ,NET_WEIGHT
                                           ,NET_WEIGHT_UNIT
                                           ,INVOICE_NO
                                           ,INVOICE_DATE
                                           ,CCC_CODE
                                           ,QTY
                                           ,QTY_UNIT
                                         )
                      SELECT  TRANS_ID
                           ,SORT_SEQ_NO
                           ,CETI_ITEM_ID
                           ,ITEM_NO
                           ,GOODS_DESC
                           ,TOT_GROSS_WEIGHT
                           ,GROSS_WEIGHT_UNIT
                           ,NET_WEIGHT
                           ,NET_WEIGHT_UNIT
                           ,INVOICE_NO
                           ,TO_CHAR(INVOICE_DATE, 'yyyymmdd')
                           ,CCC_CODE
                           ,QTY
                           ,QTY_UNIT 
                      FROM DSW_ECO01_S2
                      WHERE TRANS_ID = S_DB_REC_T1.TRANS_ID;
       
       -- 寫LOG以方便DEBUG
       INSERT  INTO  SYS_ERR_01  (   TNAME
                                   ,C01
                                   ,C02
                                   ,C03
                                   

                                 )
                      VALUES     ( 
                                     'ECO01'
                                    ,'When: ' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                                    ,'Inserted one into dgoc_ap_eco01b0.'
                                    ,S_DB_REC_T1.TRANS_ID
                       
                    );   
              
  
       EXCEPTION
         WHEN  OTHERS  THEN
              ERR_CODE   :=  SUBSTR(SQLERRM,1,120);
              DBMS_output.put_line('ERROR HAPPENED IN INS_ECCO001_TO_APECO01 : ' || ERR_CODE);
              V_COMMIT_FLG := '1';
              rollback;
      END;


      IF ( V_COMMIT_FLG = '0' ) THEN
        UPDATE  DSW_ECO01_S1
           SET  DEAL_DATE  =  SYSDATE
         WHERE  TRANS_ID   =  S_DB_REC_T1.TRANS_ID;

      ELSE
         ROLLBACK;
      END IF;
      /**** T1 End ****/

      M_CNT  :=  M_CNT + 1 ;
      IF  M_CNT  >= V_COMMIT_CNT  THEN
          T_CNT       :=  T_CNT + M_CNT ;
          COMMIT;
          M_CNT := 0;
       END  IF;

   END LOOP;

   T_CNT  :=  T_CNT + M_CNT ;

  CLOSE SEL_DATA_T1;
  COMMIT;

  END;
END;