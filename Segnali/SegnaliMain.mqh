//+------------------------------------------------------------------+
//|                                                         Main.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Indicators\BillWilliams.mqh>
#include <Indicators\Custom.mqh>
#include <Indicators\Indicator.mqh>
#include <Indicators\Indicators.mqh>
#include <Indicators\Oscilators.mqh>
#include <Indicators\Series.mqh>
#include <Indicators\TimeSeries.mqh>
#include <Indicators\Trend.mqh>
#include <Indicators\Volumes.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSegnaliMain
  {

public:

   bool              CreaRettangolo(const long chart_ID=0,const int sub_window=0,datetime time1=0,double price1=0,datetime time2=0,double price2=0,const color clr=clrRed,const ENUM_LINE_STYLE style=STYLE_SOLID,const int width=1,const bool fill=false,const bool back=false);
   CiBands*          CreateBandsIndicator(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, double deviation, int applied, int bufferSize);
   void              DeleteBandsIndicator(CiBands *OBBande);
   CiStdDev*         CreateStdDevIndicator(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied, int bufferSize);
   void              DeleteStdDevIndicator(CiStdDev *OBDev);
   CiMA*             CreateMovingAverage(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied, int bufferSize);
   void              DeleteMaIndicator(CiMA *OBMA);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSegnaliMain::CreaRettangolo(const long            chart_ID=0,        // chart's ID
                                  const int             sub_window=0,      // subwindow index
                                  datetime              time1=0,           // first point time
                                  double                price1=0,          // first point price
                                  datetime              time2=0,           // second point time
                                  double                price2=0,          // second point price
                                  const color           clr=clrRed,        // rectangle color
                                  const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                                  const int             width=1,           // width of rectangle lines
                                  const bool            fill=false,        // filling rectangle with color
                                  const bool            back=false         // in the background
                                 )
  {
   static int contatore = 0;
   string nome = "Rettangolo_" + IntegerToString(contatore);

//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,nome,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color
   ObjectSetInteger(chart_ID,nome,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,nome,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,nome,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,nome,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,nome,OBJPROP_BACK,back);

   contatore++;

//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiBands* CSegnaliMain::CreateBandsIndicator(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, double deviation, int applied, int bufferSize)
  {
   CiBands *OBBande = new CiBands();
   OBBande.Create(symbol, period, ma_period, ma_shift, deviation, applied);
   OBBande.BufferResize(bufferSize + 1);
   OBBande.Refresh(-1);
   return OBBande;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSegnaliMain::DeleteBandsIndicator(CiBands *OBBande)
  {
   delete OBBande;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiStdDev* CSegnaliMain::CreateStdDevIndicator(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied, int bufferSize)
  {
   CiStdDev *OBDev = new CiStdDev();
   OBDev.Create(symbol, period, ma_period, ma_shift, ma_method, applied);
   OBDev.BufferResize(bufferSize + 1);
   OBDev.Refresh(-1);
   return OBDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSegnaliMain::DeleteStdDevIndicator(CiStdDev *OBDev)
  {
   delete OBDev;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiMA* CSegnaliMain::CreateMovingAverage(string symbol, ENUM_TIMEFRAMES period, int ma_period, int ma_shift, ENUM_MA_METHOD ma_method, int applied, int bufferSize)
  {
   CiMA *OBMA = new CiMA();
   OBMA.Create(symbol,period,ma_period,ma_shift,ma_method,applied);
   OBMA.BufferResize(bufferSize + 1);
   OBMA.Refresh(-1);
   return OBMA;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSegnaliMain::DeleteMaIndicator(CiMA *OBMA)
  {
   delete OBMA;
  }
//+------------------------------------------------------------------+
