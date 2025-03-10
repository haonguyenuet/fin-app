# Market Stream

My personal playground in Flutter, MarketStream is a **real-time market data visualization app**, this project delivers a **minimalist, high-performance UI** for tracking market prices and custom candlestick chart. Every pixel, every interaction had to be **manually calculated and optimized**.

## 1. Key Features

- ✅ **Live Market Data** – Real-time price tracking for thousands of trading pairs with efficient viewport rendering
- ✅ **Scalable Data Handling** – Ensures smooth performance with large datasets.  
- ✅ **Custom Candlestick Chart** – Built from scratch - no dependences, supporting drag, zoom, and crosshairs.  
- ✅ **Real-time Chart Updates** – Smooth animations with live candlestick data.  
- ⏳ **Technical Indicators** – Upcoming support for moving averages and trend lines.

## 2. The Challenge

### 2.1 Market Data Streaming

Displaying a **real-time symbol list** with prices introduces another layer of complexity:  

- **Selective Updates** – Avoid re-rendering the entire list when only a few symbols update.
- **Dynamic WebSocket Management** – Subscribe to visible symbols and unsubscribe from off-screen ones to optimize performance and reduce network load.
- **Scalability** – Binance supports thousands of trading pairs, meaning updates come in fast and frequently. A naive approach could overwhelm the app with unnecessary UI rebuilds.  

This part of the project demands a smart **state management strategy**, along with techniques like **lazy loading, viewport tracking, and granular updates** to ensure smooth performance.

### 2.2 Custom Candlestick Chart  

Crafting a candlestick chart from scratch is far from simple. Unlike static UI components, a candlestick chart requires:  

- **Optimized Rendering** – To optimize performance, the chart must avoid drawing off-screen elements. Every candle, grid line, and label should be conditionally drawn based on the viewport.
- **Precision Coordinate Translation** – Each price movement must be accurately translated into screen coordinates.
- **Robust Data Optimization** – Keeping performance smooth even with thousands of candles.
- **Real-time Updates** – Ensuring smooth animations and preventing UI lag.  
- **Touch Interactions** – Pinch-to-zoom, crosshairs, and dynamic scaling.

This required deep optimization techniques, manual calculations, and careful use of **Flutter's CustomPainter** to keep performance smooth without relying on external libraries.  

## 3. Tech Stack

- **Flutter** (Stack and CustomPainter for chart drawing)
- **WebSocket & REST API** (for real-time Binance data)
- **State Management** (Riverpod and MVVM architecture)

## 4. Screenshots

| LiveMarket | Crosshairs |
|---|---|
| ![Screenshot1](screenshots/market_sc.png)  | ![Screenshot2](screenshots/crosshair_sc.png) |

| Zoom In | Zoom Out |
|---|---|
| ![Screenshot3](screenshots/zoom_in_sc.png) | ![Screenshot4](screenshots/zoom_out_sc.png) |

| Symbol Picker | Interval Picker |
|---|---|
| ![Screenshot3](screenshots/symbol_picker_sc.png) | ![Screenshot4](screenshots/interval_picker_sc.png) |

---

Built with ❤️ and a lot of math in **Flutter**. Contributions & feedback are welcome!
