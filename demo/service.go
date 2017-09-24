package demo

import (
	"encoding/json"
	"net/http"

	mgo "gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

// Product models the database object
type Product struct {
	ID   bson.ObjectId `json:"id" bson:"_id"`
	Name string        `json:"name" bson:"name"`
}

// ProductService provides the HTTP handlers to manage products.
type ProductService struct {
	collection *mgo.Collection
}

// NewProductService creates an instance of ProductService.
func NewProductService(collection *mgo.Collection) *ProductService {
	return &ProductService{collection: collection}
}

// CreateProduct is a HTTP handler to insert a product in database.
func (p *ProductService) CreateProduct(w http.ResponseWriter, r *http.Request) {
	product := Product{}
	json.NewDecoder(r.Body).Decode(&product)
	product.ID = bson.NewObjectId()
	p.collection.Insert(product)
	// Generate the HTTP response
	response, err := json.Marshal(product)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	w.Write(response)
}

// ListProducts is a HTTP handler to list all the products registered in database.
func (p *ProductService) ListProducts(w http.ResponseWriter, r *http.Request) {
	products := []Product{}
	err := p.collection.Find(nil).All(&products)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	// Generate the HTTP response
	response, err := json.Marshal(products)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(response)
}

// RemoveProducts is a HTTP handler to remove all the products from database.
func (p *ProductService) RemoveProducts(w http.ResponseWriter, r *http.Request) {
	_, err := p.collection.RemoveAll(nil)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
