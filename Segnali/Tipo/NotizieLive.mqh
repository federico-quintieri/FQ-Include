//+------------------------------------------------------------------+
//|                                                  NotizieLive.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Segnali\SegnaliMain.mqh>

struct notizia
  {
   ulong                               id_valore;             // ID valore
   ulong                               event_id;              // ID evento
   datetime                            time;                  // data e ora dell'evento
   datetime                            period;                // periodo del report degli eventi
   int                                 revision;              // ha rilasciato la revisione dell'indicatore in relazione ad un periodo del report
   long                                actual_value;          // valore attuale dell'indicatore
   long                                prev_value;            // valore precedente dell'indicatore
   long                                revised_prev_value;    // valore rivisto dell'indicatore precedente
   long                                forecast_value;        // valore di previsione dell'indicatore
   ENUM_CALENDAR_EVENT_IMPACT          impact_type;           // impatto potenziale su un tasso di cambio
   ulong                               id_evento;             // ID evento
   ENUM_CALENDAR_EVENT_TYPE            type;                  // tipo di evento dall'enumerazione ENUM_CALENDAR_EVENT_TYPE
   ENUM_CALENDAR_EVENT_SECTOR          sector;                // settore a cui è collegato un evento
   ENUM_CALENDAR_EVENT_FREQUENCY       frequency;             // frequenza degli eventi
   ENUM_CALENDAR_EVENT_TIMEMODE        time_mode;             // modalità orario evento
   ulong                               country_id;            // ID Paese
   ENUM_CALENDAR_EVENT_UNIT            unit;                  // unità di misura del valore dell'indicatore economico
   ENUM_CALENDAR_EVENT_IMPORTANCE      importance;            // importanza dell'evento
   ENUM_CALENDAR_EVENT_MULTIPLIER      multiplier;            // moltiplicatore del valore dell'indicatore economico
   uint                                digits;                // numero di posizioni decimali
   string                              source_url;            // URL di una fonte in cui è pubblicato un evento
   string                              event_code;            // codice evento
   string                              name;                  // nome del testo dell'evento nella lingua del terminale (nella codifica del terminale corrente)
   ulong                               id_paese;              // ID del Paese (ISO 3166-1)
   string                              name_paese;            // nome del testo del Paese (nella codifica del terminale corrente)
   string                              code;                  // nome codice del Paese (ISO 3166-1 alpha-2)
   string                              currency;              // codice valuta del paese
   string                              currency_symbol;       // simbolo di valuta del paese
   string                              url_name;              // nome del paese utilizzato nell'URL del sito Web mql5.com
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CNotizieLive : public CSegnaliMain
  {
public:
   notizia              News(datetime from, datetime to, int index);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
notizia CNotizieLive::News(datetime from, datetime to, int index)
  {
   notizia oggetto;

// Array di tipo struttura
   MqlCalendarValue values[];

// Riempiamo l'array values da startime a endtime con le news
   int valuesTotal = CalendarValueHistory(values, from, to);

// Verifica se la chiamata a CalendarValueHistory è riuscita
   if(valuesTotal == 0)
     {
      Print("Errore nella chiamata a CalendarValueHistory: nessun valore restituito");
      return oggetto;
     }

// Verifica se l'indice è valido
   if(index < 0 || index >= valuesTotal)
     {
      Print("Indice non valido");
      return oggetto; // Ritorna un oggetto vuoto in caso di indice non valido
     }

// Tramite la struttura event popoliamo i parametri event nell'array values[]
   MqlCalendarEvent event;
   if(!CalendarEventById(values[index].event_id, event))
     {
      Print("Errore nella chiamata a CalendarEventById per l'ID evento: ", values[index].event_id);
      return oggetto;
     }

// Tramite la struttura country popoliamo i parametri country della struttura event
   MqlCalendarCountry country;
   if(!CalendarCountryById(event.country_id, country))
     {
      Print("Errore nella chiamata a CalendarCountryById per l'ID paese: ", event.country_id);
      return oggetto;
     }

// Popoliamo la struttura notizia con i dati ottenuti
   oggetto.id_valore            = values[index].id;
   oggetto.event_id             = values[index].event_id;
   oggetto.time                 = values[index].time;
   oggetto.period               = values[index].period;
   oggetto.revision             = values[index].revision;
   oggetto.actual_value         = values[index].actual_value;
   oggetto.prev_value           = values[index].prev_value;
   oggetto.revised_prev_value   = values[index].revised_prev_value;
   oggetto.forecast_value       = values[index].forecast_value;
   oggetto.impact_type          = values[index].impact_type;
   oggetto.id_evento            = event.id;
   oggetto.type                 = event.type;
   oggetto.sector               = event.sector;
   oggetto.frequency            = event.frequency;
   oggetto.time_mode            = event.time_mode;
   oggetto.country_id           = event.country_id;
   oggetto.unit                 = event.unit;
   oggetto.importance           = event.importance;
   oggetto.multiplier           = event.multiplier;
   oggetto.digits               = event.digits;
   oggetto.source_url           = event.source_url;
   oggetto.event_code           = event.event_code;
   oggetto.name                 = event.name;
   oggetto.id_paese             = country.id;
   oggetto.name_paese           = country.name;
   oggetto.code                 = country.code;
   oggetto.currency             = country.currency;
   oggetto.currency_symbol      = country.currency_symbol;
   oggetto.url_name             = country.url_name;

   return oggetto;
  }
//+------------------------------------------------------------------+
