### Flux Query
from(bucket: "local")
    |> range(start: -1y)
    |> filter(fn: (r) => r["_measurement"] == "ticks")
    |> filter(fn: (r) => r["_field"] == "price")
    |> filter(fn: (r) => r["product"] == "AFZI/USD")
    |> aggregateWindow(every: 1y, fn: max, createEmpty: false)
    |> yield(name: "max")

from(bucket: "local")
    |> range(start: -1y)
    |> filter(fn: (r) => r["_measurement"] == "ticks")
    |> filter(fn: (r) => r["_field"] == "price")
    |> filter(fn: (r) => r["product"] == "AFZI/USD")
    |> aggregateWindow(every: 1y, fn: min, createEmpty: false)
    |> yield(name: "min")

### CURL Command
curl --location --request POST '<Base URI>>/api/v2/query?org=<Your Org>' \
--header 'Authorization: Token <Token>>' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query": "from(bucket: \"local\")|> range(start: -1y) |> filter(fn: (r) => r[\"_measurement\"] == \"ticks\") |> filter(fn: (r) => r[\"_field\"] == \"price\") |> filter(fn: (r) => r[\"product\"] == \"AFZI/USD\") |> aggregateWindow(every: 1y, fn: max, createEmpty: false) |> yield(name: \"max\") from(bucket: \"local\") |> range(start: -1y) |> filter(fn: (r) => r[\"_measurement\"] == \"ticks\") |> filter(fn: (r) => r[\"_field\"] == \"price\") |> filter(fn: (r) => r[\"product\"] == \"AFZI/USD\") |> aggregateWindow(every: 1y, fn: min, createEmpty: false) |> yield(name: \"min\")",
    "type": "flux"
}'
