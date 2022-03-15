candle = (column, tables=<-) =>
  tables
    |> reduce(
      identity: {
        count:  0.0,
        open: 0.0,
        high: 0.0,
        low: 0.0,
        close: 0.0
      },
      fn: (r, accumulator) => ({
        count:  accumulator.count + 1.0,
        open: if accumulator.open == 0 then r._value else accumulator.open,
        high: if accumulator.high < r._value then r._value else accumulator.high,
        low: if (accumulator.low == 0 or accumulator.low > r._value) then r._value else accumulator.low,
        close: r._value
      }
  )
)
