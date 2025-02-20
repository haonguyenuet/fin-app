# FinApp

A **self-built** candlestick chart in Flutter, crafted from scratch without using third-party charting packages. Inspired by **Binance App**, this project focuses on building an elegant yet minimal UI while handling **real-time price updates** using Binance API. Every pixel, every interaction had to be **manually calculated and optimized**.

## Features

- ✅ **Custom-built candlestick rendering** – No dependencies, full control over rendering.  
- ✅ **Real-time data streaming** – Fetches and updates the chart dynamically via WebSockets.  
- ✅ **Interactive chart interactions** – Crosshairs, zooming, and smooth animations.  
- ✅ **Large dataset** – Good performance on heavy data.  
- ⏳ **Advanced technical indicators** – Planned enhancements for moving averages and trend lines.  
- ⏳ **Support multiple chart types** (line chart, OHLC, etc.).

## The Challenge

Building a financial chart from scratch is **incredibly complex**. Unlike regular UI elements, a candlestick chart demands:

- 📈 **Precise coordinate mapping** for price movements.
- ⏰ **Handling variable time intervals** dynamically.
- 🔥 **Efficient rendering of large datasets** without performance loss
- ⚡ **Real-time updates & state management** while ensuring smooth UX.
- 🎯 **Interactivity with touch gestures**, zoom, and crosshair indicators.

## Tech Stack

- **Flutter** (Stack and CustomPainter for chart drawing)
- **WebSocket & REST API** (for real-time Binance data)
- **State Management** (Riverpod and MVVM architecture)

## Screenshots

| Crosshair Indicators | ZoomOut |
|---|---|
| ![Symbol Picker](screenshots/crosshair_sc.png) | ![Interval Picker](screenshots/zoom_out_sc.png) |

| Symbol Picker | Interval Picker |
|---|---|
| ![Symbol Picker](screenshots/symbol_picker_sc.png) | ![Interval Picker](screenshots/interval_picker_sc.png) |

---

Built with ❤️ and a lot of math in **Flutter**. Contributions & feedback are welcome!
