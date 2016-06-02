BEGIN
 --Drop Tables, index and constraints!
    FOR c IN (SELECT object_name,
                     object_type
              FROM user_objects
              WHERE object_type IN ('TABLE') AND object_name NOT LIKE '%$%') LOOP
        EXECUTE IMMEDIATE 'DROP '
                             || c.object_type || ' "'
                             || c.object_name || '" CASCADE CONSTRAINTS';
    END LOOP;
    
 --Drop Sequences!
  FOR i IN (SELECT us.sequence_name
              FROM USER_SEQUENCES us) LOOP
    EXECUTE IMMEDIATE 'drop sequence '|| i.sequence_name ||'';
  END LOOP;
END;

