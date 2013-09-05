create or replace 
PROCEDURE INS_ECO01_2_APECO01_DETAIL
(       in_TRANSID            IN  VARCHAR2

)
IS
    mytemp DATE;
BEGIN
 
 --select sysdate into mytemp from dual;
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
     WHERE TRANS_ID = in_TRANSID;
     
     INSERT  INTO  SYS_ERR_01  (   TNAME
                                   ,C01
                                   ,C02
                                   ,C03
                                   

                    )
           VALUES   (   'ECO01'
                       ,'When: ' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')
                       ,'Trigged by Inserting dsw_eco01_s2.'
                       ,in_TRANSID
                       
                    );   
              
END ;