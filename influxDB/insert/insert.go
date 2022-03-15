package main

import (
	"fmt"
	"os"
	"syscall"
	"time"

	"github.com/brianvoe/gofakeit/v6"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api"
	"golang.org/x/term"
)

type Tick struct {
	TickedAt  time.Time
	CreatedAt time.Time
	Product   string
	Price     float64
}

func main() {
	org := getSecret("org")
	bucket := getSecret("bucket")
	url := getSecret("url")
	token := getSecret("token")

	client := getInfluxNonBlockingConnection(url, token)
	writeAPI := getWriteAPI(client, org, bucket)
	ticks := generateTicks(generateProducts())

	fmt.Printf("Going to insert %d ticks\n", len(ticks))

	for _, tick := range ticks {
		point := influxdb2.NewPoint("ticks",
			map[string]string{
				"product": tick.Product,
			},
			map[string]interface{}{
				"createdAt": tick.CreatedAt,
				"price":     tick.Price,
			},
			tick.TickedAt)

		//fmt.Println("Inserting", tick)

		// write asynchronously
		writeAPI.WritePoint(point)
	}

	writeAPI.Flush()
	client.Close()

	fmt.Println("Done generating ticks")
}

func generateTicks(products []string) (ticks []Tick) {
	start := time.Now().AddDate(-1, 0, 0)
	end := time.Now()

	for d := start; d.Before(end); d = d.Add(1 * time.Minute) {
		for _, product := range products {
			tick := Tick{
				Product:   product,
				Price:     gofakeit.Price(0.1, 800000.0),
				TickedAt:  d,
				CreatedAt: d,
			}
			ticks = append(ticks, tick)
		}
	}
	return
}

func getInfluxNonBlockingConnection(url, token string) (client influxdb2.Client) {
	client = influxdb2.NewClientWithOptions(url, token, influxdb2.DefaultOptions().SetBatchSize(10000).SetUseGZip(true))
	return
}

func getWriteAPI(client influxdb2.Client, org, bucket string) (writeAPI api.WriteAPI) {
	writeAPI = client.WriteAPI(org, bucket)
	return
}

func generateProducts() (products []string) {
	for i := 0; i < 100; i++ {
		products = append(products, gofakeit.Regex("[A-Z]{4}/USD"))
	}
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
