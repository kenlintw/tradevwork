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
   l_strSQL              VARCHAR2(300);
   l_str_DSW_COL_NAME    VARCHAR2(150);
   l_str_DGOC_COL_NAME   VARCHAR2(150);
   ONE_VERIFY_COLUMN_MAPPING  VERIFY_COLUMN_MAPPING%ROWTYPE;

   TEST_VAR1             DATE;
   /*
   CURSOR DSW_JOIN_DGOC IS                            
       select distinct 
              a.TRANS_ID       	    DSW_TRANS_ID       	    ,
              a.SENDER_ID          	DSW_SENDER_ID          	,
              a.RECEIVER_ID        	DSW_RECEIVER_ID        	,
              a.CONTROL_NUMBER     	DSW_CONTROL_NUMBER     	,
              a.VAN_ID             	DSW_VAN_ID             	,
              a.RECV_DATE          	DSW_RECV_DATE          	,
              a.DLVR_DATE          	DSW_DLVR_DATE          	,
              a.DEAL_DATE          	DSW_DEAL_DATE          	,
              a.RETRY_CNT          	DSW_RETRY_CNT          	,
              a.RSLT_CODE          	DSW_RSLT_CODE          	,
              a.RSLT_MSG           	DSW_RSLT_MSG           	,
              a.MSG_FORMAT         	DSW_MSG_FORMAT         	,
              a.CUSTOMS_MESSAGE_ID 	DSW_CUSTOMS_MESSAGE_ID 	,
              a.MSG_FUNC_CD        	DSW_MSG_FUNC_CD        	,
              a.VAN_ID2            	DSW_VAN_ID4	            ,
              a.SAL_ENAME          	DSW_SAL_ENAME          	,
              a.SAL_EADDR          	DSW_SAL_EADDR          	,
              a.DUTY_PAYER_ENAME   	DSW_DUTY_PAYER_ENAME   	,
              a.DUTY_PAYER_BAN     	DSW_DUTY_PAYER_BAN     	,
              a.DUTY_PAYER_EADDR   	DSW_DUTY_PAYER_EADDR   	,
              a.PORT_CD            	DSW_PORT_CD            	,
              a.EXPORT_DATE        	DSW_EXPORT_DATE        	,
              a.UNLOAD_PORT        	DSW_UNLOAD_PORT        	,
              a.DEST_CD            	DSW_DEST_CD            	,
              a.VSL_SIGN           	DSW_VSL_SIGN           	,
              a.VOYAGE_NO          	DSW_VOYAGE_NO          	,
              a.FLIGHT_NO          	DSW_FLIGHT_NO          	,
              a.CERT_NO            	DSW_CERT_NO            	,
              a.REF_CD             	DSW_REF_CD             	,
              a.DECL_NO            	DSW_DECL_NO            	,
              a.ORG_COUNTRY_CD     	DSW_ORG_COUNTRY_CD     	,
              a.EX_DECLARATION     	DSW_EX_DECLARATION     	,
              a.EX_ISSUE_PLACE     	DSW_EX_ISSUE_PLACE     	,
              a.EX_ISSUE_DATE      	DSW_EX_ISSUE_DATE      	,
              a.CERTI_AUTH         	DSW_CERTI_AUTH         	,
              a.CERTI_PLACE        	DSW_CERTI_PLACE        	,
              a.CERTI_DATE         	DSW_CERTI_DATE         	,
              b.TRANSACTION_ID         			DGOC_TRANSACTION_ID         			,
              b.VAN_ID                 			DGOC_VAN_ID                 			,
              b.SENDER_NAME            			DGOC_SENDER_NAME            			,
              b.RECEIVER_NAME          			DGOC_RECEIVER_NAME          			,
              b.SENDER_ID              			DGOC_SENDER_ID              			,
              b.UNB_DATE               			DGOC_UNB_DATE               			,
              b.UNB_TIME               			DGOC_UNB_TIME               			,
              b.CONTROL_NO             			DGOC_CONTROL_NO             			,
              b.XML_EDI_FLAG           			DGOC_XML_EDI_FLAG           			,
              b.CUSTOMS_MESSAGE_ID     			DGOC_CUSTOMS_MESSAGE_ID     			,
              b.MESSAGE_FUNCTION       			DGOC_MESSAGE_FUNCTION       			,
              b.SUPPLIER_NAME          			DGOC_SUPPLIER_NAME          			,
              b.SUPPLIER_ADDRESS       			DGOC_SUPPLIER_ADDRESS       			,
              b.DUTY_PAYER_NAME        			DGOC_DUTY_PAYER_NAME        			,
              b.DUTY_PAYER_BAN         			DGOC_DUTY_PAYER_BAN         			,
              b.DUTY_PAYER_ADDRESS     			DGOC_DUTY_PAYER_ADDRESS     			,
              b.SHIPMENT               			DGOC_SHIPMENT               			,
              b.EXPORTATION_DATE       			DGOC_EXPORTATION_DATE       			,
              b.UNLOADING_PORT         			DGOC_UNLOADING_PORT         			,
              b.FINAL_CNTRY_CD         			DGOC_FINAL_CNTRY_CD         			,
              b.VSL_SIGN               			DGOC_VSL_SIGN               			,
              b.VOYAG_NO               			DGOC_VOYAG_NO               			,
              b.FLIGHT_NO              			DGOC_FLIGHT_NO              			,
              b.CERTIFICATE_NO         			DGOC_CERTIFICATE_NO         			,
              b.REFERENCE_CODE         			DGOC_REFERENCE_CODE         			,
              b.DECL_NO                			DGOC_DECL_NO                			,
              b.ORIG_CNTRY_CD          			DGOC_ORIG_CNTRY_CD          			,
              b.EXP_DECLARATION        			DGOC_EXP_DECLARATION        			,
              b.EXP_ISSUE_PLACE        			DGOC_EXP_ISSUE_PLACE        			,
              b.EXP_ISSUE_DATE         			DGOC_EXP_ISSUE_DATE         			,
              b.EXP_ISSUE_TIME         			DGOC_EXP_ISSUE_TIME         			,
              b.CERTIFYING_AUTHORITY   			DGOC_CERTIFYING_AUTHORITY   			,
              b.CERTIFYING_PLACE       			DGOC_CERTIFYING_PLACE       			,
              b.CERTIFYING_DATE        			DGOC_CERTIFYING_DATE        			,
              b.CERTIFYING_TIME        			DGOC_CERTIFYING_TIME        			,
              b.DEAL_DATE              			DGOC_DEAL_DATE              			,
              b.DEAL_TIME              			DGOC_DEAL_TIME              			,
              b.APFI_DATE              			DGOC_APFI_DATE              			,
              b.APFI_TIME              			DGOC_APFI_TIME              			,
              b.RETRY_COUNT            			DGOC_RETRY_COUNT            			
              from dsw_eco01_s1 a, dgoc_ap_eco01a0 b
              where a.customs_message_id = b.customs_message_id
              and a.trans_id = b.transaction_id
              and a.customs_message_id = in_CUSTOMS_MESSAGE_ID;
       --TYPE DSW_JOIN_DGOC IS TABLE OF SEL_DATA_T1%ROWTYPE;    
       ONE_DSW_JOIN_DGOC     DSW_JOIN_DGOC%ROWTYPE;
       */

      CURSOR CUR_VERIFY_COLUMN_MAPPING IS                            
       select * from  verify_column_mapping where tname = 'ECO01';

  BEGIN
        --DBMS_output.put_line('your intput is: ' || in_TRANSID);
        -- 寫LOG以方便DEBUG
        INSERT  INTO  VERIFY_LOG_01  (   C00
                                     ,C01
                                  )
                         VALUES   (   'ECO01:比對中繼資料庫與海關資料庫'
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
                  --DBMS_output.put_line('DSW_COL_NAME : ' || ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME);
                  --DBMS_output.put_line('DGOC_COL_NAME : ' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME);
                  --l_strSQL := 'SELECT DSW_COL_NAME, DGOC_COL_NAME FROM VERIFY_COLUMN_MAPPING WHERE TNAME = ''ECO01'' AND DSW_COL_NAME = ''' || ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME || '''';
                  --DBMS_output.put_line('l_strSQL : ' || l_strSQL);
                  --execute immediate 
                  l_strSQL := 'SELECT a.' || ONE_VERIFY_COLUMN_MAPPING.DSW_COL_NAME || ', b.' || ONE_VERIFY_COLUMN_MAPPING.DGOC_COL_NAME || 
                  ' from dsw_eco01_s1 a, dgoc_ap_eco01a0 b where a.customs_message_id = b.customs_message_id and a.trans_id = b.transaction_id' ||
                  ' and a.customs_message_id = ''' ||  in_CUSTOMS_MESSAGE_ID || '''  and a.trans_id like ''20130917%''';
                  INSERT INTO VERIFY_COLUMN_MAPPING (TNAME, L_SQL) VALUES ('SQL_LOG', l_strSQL);
                  commit;
                  execute immediate l_strSQL into l_str_DSW_COL_NAME, l_str_DGOC_COL_NAME ; 
                  --DBMS_output.put_line('l_strSQL : ' || l_strSQL);
                  
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