# FinApp

A **self-built** financial app in Flutter, crafted from scratch without using third-party charting packages. Inspired by **Binance App**, this project focuses on building an elegant yet minimal UI while handling **real-time price updates** using Binance API. Every pixel, every interaction had to be **manually calculated and optimized**.

## 1. Key Features

- ✅ **Self-built candlestick chart** – No dependencies, fully control rendering with drag, zoom and crosshairs
- ✅ **Large dataset** - Ensures good performance on heavy data
- ✅ **Live Chart Updates** – Real-time candlestick data with smooth animations
- ⏳ **Live Symbol List** – Real-time price tracking for thousands of trading pairs with efficient viewport rendering
- ⏳ **Technical indicators** – Planned enhancements for moving averages and trend lines

## 2. The Challenge

### 2.1 Candlestick Chart

Building a candlestick chart from scratch is far from simple. Unlike static UI components, a candlestick chart requires:  

- **Optimized Rendering** – To optimize performance, the chart must avoid drawing off-screen elements. Every candle, grid line, and label should be conditionally drawn based on the viewport.
- **Precise coordinate mapping** – Each price movement must be accurately translated into screen coordinates.
- **Efficient data handling** – Keeping performance smooth even with thousands of candles.
- **Real-time updates** – Ensuring smooth animations and preventing UI lag.  
- **Touch gestures** – Pinch-to-zoom, crosshairs, and dynamic scaling.

This required deep optimization techniques, manual calculations, and careful use of **Flutter's CustomPainter** to keep performance smooth without relying on external libraries.  

### 2.2 Symbol List

Displaying a **real-time symbol list** with prices introduces another layer of complexity:  

- **Selective Updates** – Avoid re-rendering the entire list when only a few symbols update.
- **Dynamic WebSocket Management** – Subscribe to visible symbols and unsubscribe from off-screen ones to optimize performance and reduce network load.
- **Scalability** – Binance supports thousands of trading pairs, meaning updates come in fast and frequently. A naive approach could overwhelm the app with unnecessary UI rebuilds.  

This part of the project demands a smart **state management strategy**, along with techniques like **lazy loading, viewport tracking, and granular updates** to ensure smooth performance.

## 3. Tech Stack

- **Flutter** (Stack and CustomPainter for chart drawing)
- **WebSocket & REST API** (for real-time Binance data)
- **State Management** (Riverpod and MVVM architecture)

## 4. Screenshots

| Crosshair Indicators | ZoomOut |
|---|---|
| ![Symbol Picker](screenshots/crosshair_sc.png) | ![Interval Picker](screenshots/zoom_out_sc.png) |

| Symbol Picker | Interval Picker |
|---|---|
| ![Symbol Picker](screenshots/symbol_picker_sc.png) | ![Interval Picker](screenshots/interval_picker_sc.png) |

---

Built with ❤️ and a lot of math in **Flutter**. Contributions & feedback are welcome!
