from(bucket: "my-bucket")
  |> range(start: -2mo, stop: -1mo)
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "MSUE/USD")
  |> aggregateWindow(every: 7d, fn: candle, createEmpty: false)
  |> keep(columns: ["open", "high", "low", "close", "count"])


### WIth multiple aggregations
from(bucket: "local")
  |> range(start: -2mo , stop: -1mo )
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AFSQ/USD")
  |> aggregateWindow(every: 1w, fn: min, createEmpty: false)
  |> yield(name: "min")

from(bucket: "local")
  |> range(start: -2mo , stop: -1mo )
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AFSQ/USD")
  |> aggregateWindow(every: 1w, fn: max, createEmpty: false)
  |> yield(name: "max")

from(bucket: "local")
  |> range(start: -2mo , stop: -1mo )
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AFSQ/USD")
  |> aggregateWindow(every: 1w, fn: first, createEmpty: false)
  |> yield(name: "first")

from(bucket: "local")
  |> range(start: -2mo , stop: -1mo )
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AFSQ/USD")
  |> aggregateWindow(every: 1w, fn: last, createEmpty: false)
  |> yield(name: "last")

### With variables not a great performance. better avoid this
data = from(bucket: "local")
  |> range(start: -2mo , stop: -1mo )
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AEBC/USD")

max = data
  |> aggregateWindow(every: 1w, fn: max, createEmpty: false)
  |> yield(name: "max")
  |> set(key: "_field", value: "max")

min = data
  |> aggregateWindow(every: 1w, fn: min, createEmpty: false)
  |> yield(name: "min")
  |> set(key: "_field", value: "min")

first = data
  |> aggregateWindow(every: 1w, fn: first, createEmpty: false)
  |> yield(name: "first")
  |> set(key: "_field", value: "first")

last = data
  |> aggregateWindow(every: 1w, fn: last, createEmpty: false)
  |> yield(name: "last")
  |> set(key: "_field", value: "last")

### With Union - Better choice among all
data = from(bucket: "local")
  |> range(start: -2mo, stop: -1mo)
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AGUX/USD")
  |> window(every: 1w)

min = data
  |> min()
  |> set(key: "type", value: "min" )

max = data
  |> max()
  |> set(key: "type", value: "max" )

union(tables: [min, max])
  |> group(columns:["type"], mode: "by")
  |> yield()