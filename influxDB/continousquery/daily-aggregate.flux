option task = {name: "daily_aggregate", every: 1d}

max = from(bucket: "local")
	|> range(start: -1y)
	|> filter(fn: (r) =>
		(r["_measurement"] == "ticks"))
	|> filter(fn: (r) =>
		(r["_field"] == "price"))
	|> aggregateWindow(every: 1d, fn: max, createEmpty: false)
	|> yield(name: "max")
	|> set(key: "_field", value: "max")
	|> to(bucket: "daily-aggregate", org: "local")
min = from(bucket: "local")
	|> range(start: -1y)
	|> filter(fn: (r) =>
		(r["_measurement"] == "ticks"))
	|> filter(fn: (r) =>
		(r["_field"] == "price"))
	|> aggregateWindow(every: 1d, fn: min, createEmpty: false)
	|> yield(name: "min")
	|> set(key: "_field", value: "min")
	|> to(bucket: "daily-aggregate", org: "local")
first = from(bucket: "local")
	|> range(start: -1y)
	|> filter(fn: (r) =>
		(r["_measurement"] == "ticks"))
	|> filter(fn: (r) =>
		(r["_field"] == "price"))
	|> aggregateWindow(every: 1d, fn: first, createEmpty: false)
	|> yield(name: "first")
	|> set(key: "_field", value: "first")
	|> to(bucket: "daily-aggregate", org: "local")
last = from(bucket: "local")
	|> range(start: -1y)
	|> filter(fn: (r) =>
		(r["_measurement"] == "ticks"))
	|> filter(fn: (r) =>
		(r["_field"] == "price"))
	|> aggregateWindow(every: 1d, fn: last, createEmpty: false)
	|> yield(name: "last")
	|> set(key: "_field", value: "last")
	|> to(bucket: "daily-aggregate", org: "local")
mean = from(bucket: "local")
	|> range(start: -1y)
	|> filter(fn: (r) =>
		(r["_measurement"] == "ticks"))
	|> filter(fn: (r) =>
		(r["_field"] == "price"))
	|> aggregateWindow(every: 1d, fn: mean, createEmpty: false)
	|> yield(name: "mean")
	|> set(key: "_field", value: "mean")
	|> to(bucket: "daily-aggregate", org: "local")
count = from(bucket: "local")
	|> range(start: -1y)
	|> filter(fn: (r) =>
		(r["_measurement"] == "ticks"))
	|> filter(fn: (r) =>
		(r["_field"] == "price"))
	|> aggregateWindow(every: 1d, fn: count, createEmpty: false)
	|> yield(name: "count")
	|> set(key: "_field", value: "count")
	|> to(bucket: "daily-aggregate", org: "local")