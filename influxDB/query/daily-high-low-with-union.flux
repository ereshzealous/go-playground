### From main DataSet
data = from(bucket: "local")
  |> range(start: -1mo)
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "AGUX/USD")
  |> window(every: 1mo)

min = data
  |> min()
  |> set(key: "type", value: "min" )

max = data
  |> max()
  |> set(key: "type", value: "max" )

union(tables: [min, max])
  |> group(columns:["type"], mode: "by")
  |> yield()

## From Downsizing DataSet
data = from(bucket: "daily-aggregate")
  |> range(start: -1mo)
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["product"] == "AGUX/USD")
  |> window(every: -1mo)

max = data
  |> filter(fn: (r) => r["_field"] == "max")
  |> max()
  |> set(key: "type", value: "max" )

min = data
|> filter(fn: (r) => r["_field"] == "min")
|> min()
|> set(key: "type", value: "min" )


union(tables: [min, max])
  |>  group(columns:["type"], mode: "by")
  |> yield()
