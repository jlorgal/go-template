package main

import (
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/jlorgal/go-template/demo"
	"gopkg.in/mgo.v2"
)

func main() {
	// Get the database host and database name
	mongoURL := os.Getenv("MONGO_URL")
	if mongoURL == "" {
		mongoURL = "localhost"
	}
	mongoName := os.Getenv("MONGO_NAME")
	if mongoName == "" {
		mongoName = "demo"
	}

	// Connect to database
	session, err := mgo.Dial(mongoURL)
	if err != nil {
		panic(err)
	}
	defer session.Close()
	session.SetMode(mgo.Monotonic, true)

	// Create the service handlers
	svc := demo.NewProductService(session.DB(mongoName).C("products"))

	// Configure API routes
	r := mux.NewRouter()
	r.HandleFunc("/products", svc.CreateProduct).Methods("POST")
	r.HandleFunc("/products", svc.ListProducts).Methods("GET")
	r.HandleFunc("/products", svc.RemoveProducts).Methods("DELETE")
	http.Handle("/", r)
	http.ListenAndServe(":8000", nil)
}
