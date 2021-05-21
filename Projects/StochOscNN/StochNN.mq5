#include <Trade\Trade.mqh>        //include the library for execution of trades
#include <Trade\PositionInfo.mqh> //include the library for obtaining information on positions
#include "../../Include/DeepNeuralNetwork.mqh"

// NN shape
const int numInput=4;
const int numHiddenA = 4;
const int numHiddenB = 4;
const int numOutput=3;

// Trade Settings 
const string symbol = "GBPUSD";
const ENUM_TIMEFRAMES timeframe_low = PERIOD_M15; // variable for storing the low time frame
const ENUM_TIMEFRAMES timeframe_high = PERIOD_D1; // variable for storing the low time frame
const double lots = 0.01;
const long order_magic=55555;//MagicNumber
const double stop_loss = 0.01;
const double take_profit = 0.02;

DeepNeuralNetwork dnn(numInput,numHiddenA,numHiddenB,numOutput);

//--- weight values
input double w0=1.0;
input double w1=1.0;
input double w2=1.0;
input double w3=1.0;
input double w4=1.0;
input double w5=1.0;
input double w6=1.0;
input double w7=1.0;
input double w8=1.0;
input double w9=1.0;

input double w10=1.0;
input double w11=1.0;
input double w12=1.0;
input double w13=1.0;
input double w14=1.0;
input double w15=1.0;

input double b0=1.0;
input double b1=1.0;
input double b2=1.0;
input double b3=1.0;

input double w40=1.0;
input double w41=1.0;
input double w42=1.0;
input double w43=1.0;
input double w44=1.0;
input double w45=1.0;
input double w46=1.0;
input double w47=1.0;
input double w48=1.0;
input double w49=1.0;
input double w50=1.0;
input double w51=1.0;
input double w52=1.0;
input double w53=1.0;
input double w54=1.0;
input double w55=1.0;

input double b4=1.0;
input double b5=1.0;
input double b6=1.0;
input double b7=1.0;

input double w60=1.0;
input double w61=1.0;
input double w62=1.0;
input double w63=1.0;
input double w64=1.0;
input double w65=1.0;
input double w66=1.0;
input double w67=1.0;
input double w68=1.0;
input double w69=1.0;
input double w70=1.0;
input double w71=1.0;

input double b9=1.0;
input double b10=1.0;
input double b11=1.0;

double            _xValues[4];   // array for storing inputs
double            weight[55];   // array for storing weights
double            _yValues[3]; // array

int low_handle;
int high_handle;

CTrade            m_Trade;      // entity for execution of trades
CPositionInfo     m_Position;   // entity for obtaining information on positions
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
  bool isCustom = false;
  if (!SymbolExist(symbol, isCustom))
  {
    Print("Symbol: " + symbol + " does not exist!");
    return -1;
  }
  m_Trade.SetExpertMagicNumber(order_magic);

  weight[0]=w0;
  weight[1]=w1;
  weight[2]=w2;
  weight[3]=w3;
  weight[4]=w4;
  weight[5]=w5;
  weight[6]=w6;
  weight[7]=w7;
  weight[8]=w8;
  weight[9]=w9;
  weight[10]=w10;
  weight[11]=w11;
  weight[12]=w12;
  weight[13]=w13;
  weight[14]=w14;
  weight[15]=w15;

  weight[16]=b0;
  weight[17]=b1;
  weight[18]=b2;
  weight[19]=b3;

  weight[20]=w40;
  weight[21]=w41;
  weight[22]=w42;
  weight[23]=w43;
  weight[24]=w44;
  weight[25]=w45;
  weight[26]=w46;
  weight[27]=w47;
  weight[28]=w48;
  weight[29]=w49;
  weight[30]=w50;
  weight[31]=w51;
  weight[32]=w52;
  weight[33]=w53;
  weight[34]=w54;
  weight[35]=w55;

  weight[36]=b4;
  weight[37]=b5;
  weight[38]=b6;
  weight[39]=b7;

  weight[40]=w60;
  weight[41]=w61;
  weight[42]=w62;
  weight[43]=w63;
  weight[44]=w64;
  weight[45]=w65;
  weight[46]=w66;
  weight[47]=w67;
  weight[48]=w68;
  weight[49]=w69;
  weight[50]=w70;
  weight[51]=w71;

  weight[52]=b9;
  weight[53]=b10;
  weight[54]=b11;

  low_handle = iStochastic(symbol,timeframe_low,5,3,3,MODE_SMA,STO_LOWHIGH);
  high_handle = iStochastic(symbol,timeframe_high,5,3,3,MODE_SMA,STO_LOWHIGH);


//--- return 0, initialization complete
   return 0;
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }

void fill_input() {
  double k_array_low[];
  double k_array_high[];
  double d_array_low[];
  double d_array_high[];

  CopyBuffer(low_handle, 0, 0, 1, k_array_low);
  CopyBuffer(low_handle, 1, 0, 1, d_array_low);
  CopyBuffer(high_handle, 0, 0, 1, k_array_high);
  CopyBuffer(high_handle, 1, 0, 1, d_array_high);

  _xValues[0] = k_array_low[0]; 
  _xValues[1] = d_array_low[0];
  _xValues[2] = k_array_high[0];
  _xValues[3] = d_array_high[0];
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   // Setup take profit and stop loss
   MqlTick Latest_Price; // Structure to get the latest prices      
   SymbolInfoTick(symbol ,Latest_Price); // Assign current prices to structure 
   double stop_loss_price = Latest_Price.bid*(1-stop_loss);
   double take_profit_price = Latest_Price.bid*(1+take_profit);

  fill_input();
  dnn.SetWeights(weight);
  dnn.ComputeOutputs(_xValues,_yValues);
  int max_out = ArrayMaximum(_yValues);

  switch(max_out) {
    case 0: // Make a buy trade
      if(m_Position.Select(symbol))//check if there is an open position
      {
        if(m_Position.PositionType()==POSITION_TYPE_SELL) m_Trade.PositionClose(symbol);//Close the opposite position if exists
        if(m_Position.PositionType()==POSITION_TYPE_BUY) return;
      }
      m_Trade.Buy(lots,symbol, 0.0, stop_loss_price, take_profit_price);//open a Long position  
      PrintFormat("BUY %f lots from %s", lots, symbol);
      break;
    case 1: // Do nothing
      break;
    case 2: // Close a buy trade
      if(m_Position.Select(symbol))//check if there is an open position
      {
        if(m_Position.PositionType()==POSITION_TYPE_BUY) {
          m_Trade.PositionClose(symbol);//Close the buy position if exists
          Print("Close BUY from " + symbol);
        } 
        else if(m_Position.PositionType()==POSITION_TYPE_SELL) return;
      }
    default: // Invalid inde
      Print("Error calculating maximum output from NN");
  }
}