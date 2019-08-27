import groovy.sql.Sql

def check(action, db) {
  Objects.requireNonNull(action)
  Objects.requireNonNull(db)
  Objects.requireNonNull(db.name)
  Objects.requireNonNull(db.type)
  Objects.requireNonNull(db.url)
  Objects.requireNonNull(db.user)
  Objects.requireNonNull(db.password)
  Objects.requireNonNull(db.driver)
}

def create(db) {
  if (db.type != 'ORACLE') {
    Sql sql = Sql.newInstance(db.url, db.user, db.password, db.driver)
    sql.execute('create database ' + db.name)
  }
}

def delete(db) {
  if (db.type != 'ORACLE') {
    Sql sql = Sql.newInstance(db.url, db.user, db.password, db.driver)
    sql.execute('drop database ' + db.name)
  } else {
    Sql sql = Sql.newInstance(db.url + ":${db.name}", db.user, db.password, db.driver)
    sql.execute '''
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
        '''
  }
}

def database = [:]
String action = null
int i = -1
while (++i < args.length) {
  switch (args[i]) {
    case '-a':
      action = args[++i].toUpperCase()
      break
    case '-t':
      database.type = args[++i].toUpperCase()
      break
    case '-d':
      database.driver = args[++i]
      break
    case '-u':
      database.url = args[++i]
      break
    case '-n':
      database.name = args[++i]
      break
    case '-U':
      database.user = args[++i]
      break
    case '-P':
      database.password = args[++i]
      break
    default:
      println "ERROR: unknown parameter name: ${args[i]}"
      System.exit(1)
  }
}

check(action, database)

switch (action) {
  case 'CREATE':
    create(database)
    break
  case 'DELETE':
    delete(database)
    break
  default:
    println "ERROR: unknown action: ${action}"
    System.exit(2)
}

