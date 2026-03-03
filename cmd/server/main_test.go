package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/go-chi/chi/v5"

	"github.com/jack-fin/bartering-games/internal/components/pages"
)

func newTestRouter() *chi.Mux {
	r := chi.NewRouter()

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		_ = pages.Home().Render(r.Context(), w)
	})

	r.Get("/login", func(w http.ResponseWriter, r *http.Request) {
		_ = pages.Login().Render(r.Context(), w)
	})

	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = io.WriteString(w, "ok")
	})

	r.Get("/readyz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = io.WriteString(w, "ok")
	})

	return r
}

func TestHomePageRoute(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/")
	if err != nil {
		t.Fatalf("GET / failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}

	ct := resp.Header.Get("Content-Type")
	if !strings.HasPrefix(ct, "text/html") {
		t.Errorf("expected Content-Type text/html, got %q", ct)
	}

	body, _ := io.ReadAll(resp.Body)
	if !strings.Contains(string(body), "bartering.games") {
		t.Error("expected body to contain 'bartering.games'")
	}
}

func TestLoginPageRoute(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/login")
	if err != nil {
		t.Fatalf("GET /login failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}

	ct := resp.Header.Get("Content-Type")
	if !strings.HasPrefix(ct, "text/html") {
		t.Errorf("expected Content-Type text/html, got %q", ct)
	}

	body, _ := io.ReadAll(resp.Body)
	if !strings.Contains(string(body), "Log in") {
		t.Error("expected body to contain 'Log in'")
	}
}

func TestHealthzRoute(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/healthz")
	if err != nil {
		t.Fatalf("GET /healthz failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}

	body, _ := io.ReadAll(resp.Body)
	if string(body) != "ok" {
		t.Errorf("expected body 'ok', got %q", string(body))
	}
}

func TestReadyzRoute(t *testing.T) {
	srv := httptest.NewServer(newTestRouter())
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/readyz")
	if err != nil {
		t.Fatalf("GET /readyz failed: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected 200, got %d", resp.StatusCode)
	}

	body, _ := io.ReadAll(resp.Body)
	if string(body) != "ok" {
		t.Errorf("expected body 'ok', got %q", string(body))
	}
}
