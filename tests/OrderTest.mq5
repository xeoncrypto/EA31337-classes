//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 *  This file is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @file
 * Test functionality of Order class.
 */

// Includes.
#include "../Chart.mqh"
#include "../Order.mqh"
#include "../Test.mqh"

// Global defines.
#define MAX_ORDERS 10

// Global variables.
int bar_processed = 0;
bool stop = false;

Chart *chart;
Order *orders[MAX_ORDERS];
Order *orders_dummy[MAX_ORDERS];

/**
 * Implements Init event handler.
 */
int OnInit() {
  bool _result = true;
  chart = new Chart(PERIOD_M1);
  bar_processed = 0;
  _result &= GetLastError() == ERR_NO_ERROR;
  return _result ? INIT_SUCCEEDED : INIT_FAILED;
}

/**
 * Implements Tick event handler.
 */
void OnTick() {
  if (chart.IsNewBar()) {
    bool order_result;

    if (bar_processed < MAX_ORDERS) {
      order_result = OpenOrder(/* index */ bar_processed, /* order_no */ bar_processed + 1);
      assertTrueOrExit(order_result, StringFormat("Order not opened (last error: %d)!", GetLastError()));
    } else if (bar_processed >= MAX_ORDERS && bar_processed < MAX_ORDERS * 2) {
      // No more orders to fit, closing orders one by one.
      order_result = CloseOrder(/* index */ bar_processed - MAX_ORDERS, /* order_no */ bar_processed - MAX_ORDERS + 1);
      assertTrueOrExit(order_result, StringFormat("Order not closed (last error: %d)!", GetLastError()));
    }

    bar_processed++;
  }
}

/**
 * Open an order.
 */
bool OpenOrder(int _index, int _order_no) {
  // New request.
  MqlTradeRequest _request = {0};
  _request.action = TRADE_ACTION_DEAL;
  _request.comment = StringFormat("Order: %d", _order_no);
  _request.deviation = 50;
  _request.magic = _order_no;
  _request.type = bar_processed % 2 == 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  _request.price = chart.GetOpenOffer(_request.type);
  _request.symbol = chart.GetSymbol();
  _request.type_filling = Order::GetOrderFilling(_request.symbol);
  _request.volume = chart.GetVolumeMin();
  // New order.
  MqlTradeResult _result = {0};
  Order *_order;
  _order = orders[_index] = new Order(_request);
  _result = _order.GetResult();
  assertTrueOrReturn(_result.retcode == TRADE_RETCODE_DONE, "Request not completed!", false);
  assertTrueOrReturn(_order.GetData().price_current > 0, "Order's symbol price not correct!", false);
  // Make a dummy order.
  MqlTradeResult _result_dummy = {0};
  Order *_order_dummy;
  OrderParams oparams_dummy(true);
  _request.comment = StringFormat("Order dummy: %d", _order_no);
  _order_dummy = orders_dummy[_index] = new Order(_request, oparams_dummy);
  _result_dummy = _order_dummy.GetResult();
  assertTrueOrReturn(_result.retcode == _result.retcode, "Dummy order not completed!", false);
  //assertTrueOrReturn(_order.GetData().price_current == _order_dummy.GetData().price_current, "Price current of dummy order not correct!", false); // @fixme
  // Compare real order with dummy one.
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Close an order.
 */
bool CloseOrder(int _index, int _order_no) {
  Order *order = orders[_index];
  if (order.IsOpen()) {
    string order_comment = StringFormat("Closing order: %d", _order_no);
    order.OrderClose(order_comment);
  }
  return GetLastError() == ERR_NO_ERROR;
}

/**
 * Implements Deinit event handler.
 */
void OnDeinit(const int reason) {
  delete chart;
  for (int i = 0; i < fmin(bar_processed, MAX_ORDERS); i++) {
    if (CheckPointer(orders[i]) == POINTER_DYNAMIC) {
      delete orders[i];
    }
    if (CheckPointer(orders_dummy[i]) == POINTER_DYNAMIC) {
      delete orders_dummy[i];
    }
  }
}