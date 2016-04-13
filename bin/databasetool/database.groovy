import groovy.sql.Sql

def usage =  """\
Usage: database create|delete RDBMS [HOST]
       database help
with:
  RDBMS the database type: either POSTGRES or MSSQL
  HOST  the name or the IP address of the server hosting the database
        (by default localhost).
Description:
  create or delete the 'silvertest' database hosting in the specified server."""

if (args.length == 1 && args[0] == "help") {
  println usage
  System.exit(0)
} else if (args.length != 2 && args.length != 3) {
  println "Missing arguments"
  println usage
  System.exit(1)
}

String action = args[0]
String rdbms  = args[1]
String host   = (args.length == 3 ? args[2]:"localhost")
def sql
switch(rdbms) {
  case 'POSTGRESQL':
    sql = Sql.newInstance('jdbc:postgresql://' + host + ':5432/',
      'postgres', 'postgres', 'org.postgresql.Driver')
    break;
  case 'MSSQL':
    sql = Sql.newInstance('jdbc:jtds:sqlserver://' + host + ':1433',
      'sa', 'dauph1DO', 'net.sourceforge.jtds.jdbc.Driver')
    break;
  default:
    println "The RDBMS ${rdbms} isn't currently supported!"
    System.exit(2)
}

try {
  switch(action) {
    case 'create':
      sql.execute('create database silvertest')
      break;
    case 'delete':
      sql.execute('drop database silvertest')
      break;
    default:
      println "Unknown action: ${action}"
      System.exit(4)
  }
} catch (Exception ex) {
  println "Error while executing the action ${action}: ${ex.message}"
  System.exit(3)
}

System.exit(0)
