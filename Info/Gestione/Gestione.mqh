//+------------------------------------------------------------------+
//|                                                     Gestione.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <FQInclude\Info\Info.mqh>
#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGestione : public CInfo
  {
protected:
   CTrade            OBTrading;

public:
                     CGestione() {}
                    ~CGestione() {}

   void              Trailing(int magic, string simbolo, double stop_buy, double stop_sell);
   void              ChiudiPosizioni(ENUM_POSITION_TYPE Tipo_Posizione, string simbolo, int magic);
   void              ChiudiPosizioni(string simbolo, int magic);
   void              CancellaPendenti(ENUM_ORDER_TYPE Tipo_Pendente, int magic, string simbolo);
   void              CancellaPendenti(int magic, string simbolo);
   void              Azzeramento(ENUM_POSITION_TYPE Tipo_Posizione, int magic, string simbolo, double PuntiPerAzzerare);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGestione::Trailing(int magic, string simbolo, double stop_buy, double stop_sell)
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);

      if(ticket > 0)
        {
         long position_magic = PositionGetInteger(POSITION_MAGIC);
         string position_symbol = PositionGetString(POSITION_SYMBOL);
         double stoplevel = PositionGetDouble(POSITION_SL);
         long type = PositionGetInteger(POSITION_TYPE);
         double takeprofit = PositionGetDouble(POSITION_TP);
         double price_open = PositionGetDouble(POSITION_PRICE_OPEN);
         double price_current = SymbolInfoDouble(position_symbol, SYMBOL_BID);

         // Verifica il tipo di posizione e i valori dei nuovi stop loss
         if(simbolo == position_symbol && position_magic == magic)
           {
            if(type == POSITION_TYPE_BUY)
              {
               if(stoplevel != stop_buy && stop_buy < price_current - SymbolInfoDouble(position_symbol, SYMBOL_POINT) * 10)
                 {
                  // Modifica solo se il nuovo stop loss è valido e diverso da quello attuale
                  if(OBTrading.PositionModify(ticket, stop_buy, takeprofit))
                    {
                     Print("Stop loss modificato con successo per posizione BUY: ", ticket);
                    }
                  else
                    {
                     Print("Errore nella modifica dello stop loss per posizione BUY: ", ticket, ". Errore: ", GetLastError());
                    }
                 }
              }
            else
               if(type == POSITION_TYPE_SELL)
                 {
                  if(stoplevel != stop_sell && stop_sell > price_current + SymbolInfoDouble(position_symbol, SYMBOL_POINT) * 10)
                    {
                     // Modifica solo se il nuovo stop loss è valido e diverso da quello attuale
                     if(OBTrading.PositionModify(ticket, stop_sell, takeprofit))
                       {
                        Print("Stop loss modificato con successo per posizione SELL: ", ticket);
                       }
                     else
                       {
                        Print("Errore nella modifica dello stop loss per posizione SELL: ", ticket, ". Errore: ", GetLastError());
                       }
                    }
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGestione::ChiudiPosizioni(ENUM_POSITION_TYPE Tipo_Posizione, string simbolo, int magic)
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);

      if(ticket > 0)
        {
         long position_magic = PositionGetInteger(POSITION_MAGIC);
         string position_symbol = PositionGetString(POSITION_SYMBOL);
         long position_type = PositionGetInteger(POSITION_TYPE);

         if(simbolo == position_symbol && magic == position_magic && Tipo_Posizione == position_type)
           {
            OBTrading.PositionClose(ticket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGestione::ChiudiPosizioni(string simbolo, int magic)
  {
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);

      if(ticket > 0)
        {
         long position_magic = PositionGetInteger(POSITION_MAGIC);
         string position_symbol = PositionGetString(POSITION_SYMBOL);

         if(simbolo == position_symbol && magic == position_magic)
           {
            OBTrading.PositionClose(ticket);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGestione::CancellaPendenti(ENUM_ORDER_TYPE Tipo_Pendente, int magic, string simbolo)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);

      long order_type = OrderGetInteger(ORDER_TYPE);
      string order_symbol = OrderGetString(ORDER_SYMBOL);
      long order_magic = OrderGetInteger(ORDER_MAGIC);

      if(order_type == Tipo_Pendente && order_magic == magic && order_symbol == simbolo)
        {
         OBTrading.OrderDelete(ticket);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGestione::CancellaPendenti(int magic, string simbolo)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);

      long order_magic = OrderGetInteger(ORDER_MAGIC);
      string order_symbol = OrderGetString(ORDER_SYMBOL);

      if(order_magic == magic && order_symbol == simbolo)
        {
         OBTrading.OrderDelete(ticket);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGestione::Azzeramento(ENUM_POSITION_TYPE Tipo_Posizione, int magic, string simbolo, double PuntiPerAzzerare)
  {
   double Livello_Stop_Aggiornato = 0.0;
   double Prezzo_Azzeramento = 0.0;
   double Min_Differenza_Punti = 10 * Point();  // Margine minimo per aggiornare il livello

   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);

      if(ticket > 0)
        {
         long position_magic = PositionGetInteger(POSITION_MAGIC);
         string position_symbol = PositionGetString(POSITION_SYMBOL);
         double stoplevel = PositionGetDouble(POSITION_SL);
         double openprice = PositionGetDouble(POSITION_PRICE_OPEN);
         long type = PositionGetInteger(POSITION_TYPE);
         double takeprofit = PositionGetDouble(POSITION_TP);

         if(simbolo == position_symbol && position_magic == magic)
           {
            if(type == POSITION_TYPE_BUY)
              {
               Livello_Stop_Aggiornato = openprice + 10 * Point();
               Prezzo_Azzeramento = openprice + PuntiPerAzzerare * Point();

               if(Bid() >= Prezzo_Azzeramento && fabs(stoplevel - Livello_Stop_Aggiornato) > Min_Differenza_Punti)
                  OBTrading.PositionModify(ticket, Livello_Stop_Aggiornato, takeprofit);
              }
            else
               if(type == POSITION_TYPE_SELL)
                 {
                  Livello_Stop_Aggiornato = openprice - 10 * Point();
                  Prezzo_Azzeramento = openprice - PuntiPerAzzerare * Point();

                  if(Ask() <= Prezzo_Azzeramento && fabs(stoplevel - Livello_Stop_Aggiornato) > Min_Differenza_Punti)
                     OBTrading.PositionModify(ticket, Livello_Stop_Aggiornato, takeprofit);
                 }
           }
        }
     }
  }
//+------------------------------------------------------------------+
