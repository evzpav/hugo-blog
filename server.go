package main

import (
	"log"
	"net/http"
	"os"
)

var defaultPort string = "9999"

func main() {
	dir, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	fs := http.FileServer(http.Dir(dir + "/public"))
	http.Handle("/", fs)

	port := getEnvVarPort()
	log.Printf("Serving static on http://localhost:%v", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func getEnvVarPort() string {
	envPort := os.Getenv("PORT")
	if envPort == "" {
		return defaultPort
	}

	return envPort
}
