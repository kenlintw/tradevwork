create or replace 
trigger TGAFINS_ECO01_S1
after insert on ECO01_S1
for each row


begin
 
   IDB_INS_ECO01_2_APECO01(:NEW.TRANS_ID);

end;