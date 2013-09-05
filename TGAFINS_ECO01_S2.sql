create or replace 
trigger TGAFINS_ECO01_S2
after insert on ECO01_S2
for each row

begin

   IDB_INS_ECO01_2_APECO01_DETAIL(:NEW.TRANS_ID);

end;