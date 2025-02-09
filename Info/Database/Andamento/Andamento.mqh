//+------------------------------------------------------------------+
//|                                                    Andamento.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Database\Database.mqh>

// Test Repository

// Struttura per memorizzare le informazioni della tabella
struct TableInfo
  {
   string            name;
   string            query;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAndamento : public CDatabase
  {


private:

   string            QueryCalcolo(int database_handle,int lungo_periodo_giorni, int breve_periodo_giorni);
   string            GetUltimoGiornoInserito(int database_handle, string tabella);
   ulong             GetLastTicketFromDatabase(int database_handle,string table_name);
   int               ContaRecord(int database_handle, string table_name);
   double            SommaColonnaRisultato(int database_handle,string table_name, string colonna, int num_records);

public:

                     CAndamento() {};
                    ~CAndamento() {};

   void              InitDatabase(int magic, string nome_ea);
   void              UpdateDatabase(int magic, string nome_ea, int lungo_periodo_giorni, int breve_periodo_giorni);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CAndamento::QueryCalcolo(int database_handle, int lungo_periodo_giorni, int breve_periodo_giorni)
  {
   string query = "";
   int record_daily = ContaRecord(database_handle, "Daily");

   if(record_daily >= lungo_periodo_giorni)
     {
      int numero_record_lungo = lungo_periodo_giorni;
      double Somma_Lungo_Periodo = NormalizeDouble(SommaColonnaRisultato(database_handle, "Daily", "Risultato", numero_record_lungo), 2);
      double Media_Lungo_Periodo = NormalizeDouble(Somma_Lungo_Periodo / numero_record_lungo, 2);
      int Numero_Mesi_Lungo = (lungo_periodo_giorni >= 30) ? lungo_periodo_giorni / 30 : 0;
      double Media_Tutti_Mesi = (Numero_Mesi_Lungo > 0) ? NormalizeDouble(Somma_Lungo_Periodo / Numero_Mesi_Lungo, 2) : 0;

      int numero_record_breve = breve_periodo_giorni;
      double Somma_Breve_Periodo = NormalizeDouble(SommaColonnaRisultato(database_handle, "Daily", "Risultato", numero_record_breve), 2);
      double Media_Breve_Periodo = NormalizeDouble(Somma_Breve_Periodo / numero_record_breve, 2);
      int Numero_Mesi_Breve = (breve_periodo_giorni >= 30) ? breve_periodo_giorni / 30 : 0;
      double Media_Primi_Mesi = (Numero_Mesi_Breve > 0) ? NormalizeDouble(Somma_Breve_Periodo / Numero_Mesi_Breve, 2) : 0;

      string Valutazione = (Somma_Lungo_Periodo > 0 && Somma_Breve_Periodo > 0 && Media_Primi_Mesi > Media_Tutti_Mesi) ? "Idoneo" : "Non Idoneo";
      string Giorno = TimeToString(TimeCurrent(), TIME_DATE);

      query = StringFormat("INSERT OR REPLACE INTO Calcoli "
                           "(Giorno, Somma_Lungo_Periodo, Somma_Breve_Periodo, Media_Lungo_Periodo, "
                           "Media_Breve_Periodo, Media_Primi_Mesi, Media_Tutti_Mesi, Valutazione,Simbolo) "
                           "VALUES('%s', %f, %f, %f, %f, %f, %f, '%s','%s')",
                           Giorno,
                           Somma_Lungo_Periodo,
                           Somma_Breve_Periodo,
                           Media_Lungo_Periodo,
                           Media_Breve_Periodo,
                           Media_Primi_Mesi,
                           Media_Tutti_Mesi,
                           Valutazione,
                           _Symbol
                          );
     }
   return query;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CAndamento::GetUltimoGiornoInserito(int database_handle, string table_name)
  {
   string query_selezione = StringFormat("SELECT Giorno FROM %s ORDER BY Giorno DESC LIMIT 1", table_name);
   string ultimo_giorno = "";

   ultimo_giorno = RitornaStringa(database_handle,query_selezione);

   return ultimo_giorno;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong CAndamento::GetLastTicketFromDatabase(int database_handle,string table_name)
  {
   string query_selezione = StringFormat("SELECT MAX(TICKET) FROM %s", table_name);
   ulong last_ticket = 0;

   last_ticket = RitornaLong(database_handle,query_selezione);

   return last_ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CAndamento::ContaRecord(int database_handle, string table_name)
  {
   string query_selezione = "SELECT COUNT(*) FROM " + table_name;
   int numero_record = 0;

   numero_record = RitornaInteger(database_handle,query_selezione);

   return numero_record;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAndamento::SommaColonnaRisultato(int database_handle,string table_name, string colonna, int num_records)
  {
   double somma = 0.0;

// Somma risultati dalla tabella Daily_Test
   string query_selezione = "SELECT " + colonna + " FROM "+ table_name +" ORDER BY Giorno DESC LIMIT " + IntegerToString(num_records);

   somma = RitornaSomma(database_handle,query_selezione);

   return somma;
  }
//+------------------------------------------------------------------+
// Metodo che inizializza il nostro database
void CAndamento::InitDatabase(int magic, string nome_ea)
  {
   string nome_database = nome_ea + "_" + IntegerToString(magic);
   int handle = ApriDatabase(nome_database);

// Se siamo in modalità test cancella le tabelle TEST perché verranno ricreate e ricompilate da zero
   if(MQLInfoInteger(MQL_TESTER))
     {
      CancellaTabella(handle, "Daily");
      CancellaTabella(handle, "Calcoli");
     }

// Array di strutture contenenti le informazioni delle tabelle
   TableInfo tables[] =
     {
        {
         "Daily", "CREATE TABLE Daily ("
         "Giorno TEXT PRIMARY KEY,"
         "Risultato REAL,"
         "Simbolo TEXT);"
        },
        {
         "Calcoli", "CREATE TABLE Calcoli ("
         "Giorno TEXT PRIMARY KEY,"
         "Somma_Lungo_Periodo REAL,"
         "Somma_Breve_Periodo REAL,"
         "Media_Lungo_Periodo REAL,"
         "Media_Breve_Periodo REAL,"
         "Media_Primi_Mesi REAL,"
         "Media_Tutti_Mesi REAL,"
         "Valutazione TEXT,"
         "Simbolo TEXT);"
        }
     };

// Creazione delle tabelle utilizzando un ciclo
   for(int i = 0; i < ArraySize(tables); i++)
     {
      CreaTabella(handle, tables[i].name, tables[i].query);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAndamento::UpdateDatabase(int magic, string nome_ea, int lungo_periodo_giorni, int breve_periodo_giorni)
  {
   string nome_database = nome_ea + "_" + IntegerToString(magic);
   int handle = ApriDatabase(nome_database);

   if(handle != INVALID_HANDLE)
     {
      double risultato = RisultatoGiornaliero(magic, Symbol());
      string giorno = TimeToString(TimeCurrent(), TIME_DATE);

      string daily_table = "Daily";

      string ultimo_giorno_inserito = GetUltimoGiornoInserito(handle, daily_table);

      if(giorno != ultimo_giorno_inserito)
        {

         // Popolo Tabella Daily
         string query = StringFormat("INSERT INTO %s (Giorno, Risultato, Simbolo) VALUES ('%s', %f, '%s')", daily_table, giorno, risultato,_Symbol);

         if(query != "")
           {
            InserisciQuery(handle, query);
           }

         // Popolo Tabella Calcoli
         query = QueryCalcolo(handle, lungo_periodo_giorni, breve_periodo_giorni);
         Print("Query Calcolo: ", query);
         if(query != "")
           {
            InserisciQuery(handle, query);
           }
        }

      // Close the database connection
      ChiudiDatabase(handle);
     }
   else
     {
      Print("Failed to open database: ", nome_database);
     }
  }
//+------------------------------------------------------------------+
