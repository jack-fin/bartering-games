package handler_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"github.com/go-chi/chi/v5"

	pb "github.com/jack-fin/bartering-games/backend/gen/bartering/v1"
	rpc "github.com/jack-fin/bartering-games/backend/gen/bartering/v1/barteringv1connect"
	"github.com/jack-fin/bartering-games/backend/internal/handler"
)

func newTestRouter() *chi.Mux {
	r := chi.NewRouter()
	path, h := rpc.NewHealthServiceHandler(&handler.HealthHandler{})
	r.Mount(path, h)
	return r
}

func TestHealthCheck(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	t.Cleanup(srv.Close)

	client := rpc.NewHealthServiceClient(srv.Client(), srv.URL)
	if _, err := client.Check(context.Background(), connect.NewRequest(&pb.CheckRequest{})); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestHealthCheckJSON(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	t.Cleanup(srv.Close)

	client := rpc.NewHealthServiceClient(
		srv.Client(),
		srv.URL,
		connect.WithProtoJSON(),
	)
	if _, err := client.Check(context.Background(), connect.NewRequest(&pb.CheckRequest{})); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestHealthCheckHTTPMethod(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	t.Cleanup(srv.Close)

	// Connect uses POST — verify a GET returns an error.
	resp, err := http.Get(srv.URL + "/bartering.v1.HealthService/Check")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode == http.StatusOK {
		t.Error("expected non-200 for GET on a Connect endpoint")
	}
}
