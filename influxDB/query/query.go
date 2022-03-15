package main

import (
	"context"
	"fmt"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api"
	"golang.org/x/term"
	"os"
	"syscall"
	"time"
)

type Candle struct {
	Time    time.Time
	Product string
	Open    float64
	High    float64
	Low     float64
	Close   float64
}

func main() {
	org := getSecret("org")
	url := getSecret("url")
	token := getSecret("token")

	client := getInfluxNonBlockingConnection(url, token)
	queryAPI := getQueryAPI(client, org)

	runQuery(queryAPI)

	client.Close()
}

func runQuery(queryAPI api.QueryAPI) {
	query := `
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

from(bucket: "my-bucket")
  |> range(start: -2mo, stop: -1mo)
  |> filter(fn: (r) => r["_measurement"] == "ticks")
  |> filter(fn: (r) => r["_field"] == "price")
  |> filter(fn: (r) => r["product"] == "MSUE/USD")
  |> aggregateWindow(every: 7d, fn: candle, createEmpty: false)
  |> keep(columns: ["open", "high", "low", "close", "count", "_time", "product"])
`

	result, err := queryAPI.Query(context.Background(), query)
	exitOnError(err)

	var candle Candle
	for result.Next() {
		candle = Candle{
			Time:    result.Record().ValueByKey("_time").(time.Time),
			Product: result.Record().ValueByKey("product").(string),
			Open:    result.Record().ValueByKey("open").(float64),
			High:    result.Record().ValueByKey("high").(float64),
			Low:     result.Record().ValueByKey("low").(float64),
			Close:   result.Record().ValueByKey("close").(float64),
		}
	}

	fmt.Printf("%+v\n", candle)
}

func getQueryAPI(client influxdb2.Client, org string) api.QueryAPI {
	return client.QueryAPI(org)
}

func getInfluxNonBlockingConnection(url, token string) (client influxdb2.Client) {
	client = influxdb2.NewClientWithOptions(url, token, influxdb2.DefaultOptions().SetBatchSize(10000).SetUseGZip(true))
	return
}

func getSecret(prompt string) string {
	fmt.Print(fmt.Sprintf("Enter %s: ", prompt))
	bytes, err := term.ReadPassword(int(syscall.Stdin))
	exitOnError(err)
	fmt.Println()

	return string(bytes)
}

func exitOnError(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
