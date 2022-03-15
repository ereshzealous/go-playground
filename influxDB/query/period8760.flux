from(bucket: "akasztenny's Bucket")
    |> range(start: -365d, stop: -364d)
    |> filter(fn: (r) => r["_measurement"] == "ticks")
    |> filter(fn: (r) => r["_field"] == "price")
    |> filter(fn: (r) => r["product"] == "BHMM/USD")
    |> aggregateWindow(every: 1d, fn: max, createEmpty: false)
    |> yield(name: "max")