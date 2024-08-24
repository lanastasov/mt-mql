//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   double stopLoss = 100 * _Point; // Stop loss in points
   double takeProfit = 200 * _Point; // Take profit in points
   int totalOrders = OrdersTotal();
   
   for (int i = totalOrders - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderMagicNumber() == 0) // Check if the order was placed manually
         {
            double newSL, newTP;
            
            if (OrderType() == ORDER_BUY)
            {
               newSL = OrderOpenPrice() - stopLoss;
               newTP = OrderOpenPrice() + takeProfit;
            }
            else if (OrderType() == ORDER_SELL)
            {
               newSL = OrderOpenPrice() + stopLoss;
               newTP = OrderOpenPrice() - takeProfit;
            }
            else
            {
               continue;
            }

            bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, newTP, 0);
            if (result)
            {
               Print("Stop Loss and Take Profit set successfully.");
            }
            else
            {
               Print("Failed to set Stop Loss and Take Profit. Error: ", GetLastError());
            }
            break; // Stop after modifying the latest order
         }
      }
   }
}
//+------------------------------------------------------------------+
