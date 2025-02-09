//+------------------------------------------------------------------+
//|                                                     Database.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Info.mqh>

//+------------------------------------------------------------------+
//| Class Database                                                   |
//+------------------------------------------------------------------+
class CDatabase : public CInfo
  {

public:
                     CDatabase() {};
                    ~CDatabase() {};

   int               ApriDatabase(string filename);
   void              ChiudiDatabase(int database_handle);
   bool              CreaTabella(int database_handle, string table_name, string query);
   bool              CancellaTabella(int database_handle, string table_name);
   bool              InserisciQuery(int database_handle, string query_inserimento);
   int               RitornaInteger(int database_handle, string query_selezione);
   string            RitornaStringa(int database_handle,string query_selezione);
   double            RitornaDouble(int database_handle,string query_selezione);
   long              RitornaLong(int database_handle,string query_selezione);
   double            RitornaSomma(int database_handle,string query_selezione);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CDatabase::ApriDatabase(string filename)
  {

// Apro/Creo il database nella cartella common
   int db=DatabaseOpen(filename, DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE | DATABASE_OPEN_COMMON);

// Se c'è un errore di creazione me lo printi
   if(db==INVALID_HANDLE)
     {
      Print("DB: ", filename, " apertura/creazione database fallita, errore: ", GetLastError());
     }

   return db;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDatabase::ChiudiDatabase(int database_handle)
  {
   DatabaseClose(database_handle);
  }

//+------------------------------------------------------------------+
//| CreateTable                                                      |
//+------------------------------------------------------------------+
bool CDatabase::CreaTabella(int database_handle, string table_name, string query)
  {

   bool table_exists = DatabaseTableExists(database_handle, table_name);

   if(!table_exists)
     {
      if(!DatabaseExecute(database_handle, query))
        {
         Print("DB: creazione tabella " + table_name + " fallita, errore: ", GetLastError());
         return false;
        }
     }
   else
     {
      Print("La tabella esiste già.");
     }
   return true;
  }

//+------------------------------------------------------------------+
//| DeleteTable                                                      |
//+------------------------------------------------------------------+
bool CDatabase::CancellaTabella(int database_handle,string table_name)
  {
   if(!DatabaseExecute(database_handle, "DROP TABLE IF EXISTS " + table_name))
     {
      Print("Fallita cancellazione tabella "+ table_name + ", errore: ", GetLastError());
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| InserisciQuery                                                   |
//+------------------------------------------------------------------+
bool CDatabase::InserisciQuery(int database_handle,string query_inserimento)
  {

   if(!DatabaseTransactionBegin(database_handle))
     {
      PrintFormat("Inizio Transazione con database fallita. Error: %d", GetLastError());
      return false;
     }

   if(!DatabaseExecute(database_handle, query_inserimento))
     {
      PrintFormat("Errore inserimento query. Error: %d", GetLastError());
      DatabaseTransactionRollback(database_handle);
      return false;
     }

   if(!DatabaseTransactionCommit(database_handle))
     {
      PrintFormat("Commit Transazione fallita. Error: %d", GetLastError());
      return false;
     }

   Print("Query inviata correttamente.");
   return true;
  }

//+------------------------------------------------------------------+
int CDatabase::RitornaInteger(int database_handle, string query_selezione)
  {

   int request = DatabasePrepare(database_handle, query_selezione);

   if(request == INVALID_HANDLE)
     {
      Print("DB: richiesta per ottenere i record fallita con codice ", GetLastError());
      return 0;
     }

   int valore_integer = 0;

// Usa `while` per iterare attraverso tutti i record risultanti dalla query
   while(DatabaseRead(request))
     {
      int temp_record;
      DatabaseColumnInteger(request, 0, temp_record);

      // Puoi decidere cosa fare con i vari record. Qui semplicemente assegni l'ultimo letto
      valore_integer = temp_record;
     }

   DatabaseFinalize(request);
   return valore_integer;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabase::RitornaStringa(int database_handle,string query_selezione)
  {
   int request = DatabasePrepare(database_handle, query_selezione);

   if(request == INVALID_HANDLE)
     {
      Print("DB: richiesta per ottenere i record fallita con codice ", GetLastError());
      return "";
     }

   string valore_stringa = "";

// Usa `while` per iterare attraverso tutti i record risultanti dalla query
   while(DatabaseRead(request))
     {
      string temp_record;
      DatabaseColumnText(request, 0, temp_record);

      // Puoi decidere cosa fare con i vari record. Qui semplicemente assegni l'ultimo letto
      valore_stringa = temp_record;
     }

   DatabaseFinalize(request);
   return valore_stringa;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDatabase::RitornaDouble(int database_handle,string query_selezione)
  {
   int request = DatabasePrepare(database_handle, query_selezione);

   if(request == INVALID_HANDLE)
     {
      Print("DB: richiesta per ottenere i record fallita con codice ", GetLastError());
      return 0;
     }

   double valore_double = 0.0;

// Usa `while` per iterare attraverso tutti i record risultanti dalla query
   while(DatabaseRead(request))
     {
      double temp_record;
      DatabaseColumnDouble(request, 0, temp_record);

      // Puoi decidere cosa fare con i vari record. Qui semplicemente assegni l'ultimo letto
      valore_double = temp_record;
     }

   DatabaseFinalize(request);
   return valore_double;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CDatabase::RitornaLong(int database_handle,string query_selezione)
  {
   int request = DatabasePrepare(database_handle, query_selezione);

   if(request == INVALID_HANDLE)
     {
      Print("DB: richiesta per ottenere i record fallita con codice ", GetLastError());
      return 0;
     }

   long valore_long = 0;

// Usa `while` per iterare attraverso tutti i record risultanti dalla query
   while(DatabaseRead(request))
     {
      long temp_record;
      DatabaseColumnLong(request, 0, temp_record);

      // Puoi decidere cosa fare con i vari record. Qui semplicemente assegni l'ultimo letto
      valore_long = temp_record;
     }

   DatabaseFinalize(request);
   return valore_long;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDatabase::RitornaSomma(int database_handle,string query_selezione)
  {

   int request = DatabasePrepare(database_handle, query_selezione);
   double somma_risultati = 0.0;

   if(request == INVALID_HANDLE)
     {
      Print("DB: richiesta selezione fallita con codice: ", GetLastError());
      return 0;
     }

   while(DatabaseRead(request))
     {
      double risultato;
      DatabaseColumnDouble(request, 0, risultato);
      somma_risultati += risultato;
     }
   DatabaseFinalize(request);

   return somma_risultati;
  }
//+------------------------------------------------------------------+
