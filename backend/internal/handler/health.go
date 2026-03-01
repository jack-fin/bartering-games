package handler

import (
	"context"

	"connectrpc.com/connect"

	barteringv1 "github.com/jack-fin/bartering-games/backend/gen/bartering/v1"
)

// HealthHandler implements the HealthService Connect handler.
type HealthHandler struct{}

func (h *HealthHandler) Check(
	_ context.Context,
	_ *connect.Request[barteringv1.CheckRequest],
) (*connect.Response[barteringv1.CheckResponse], error) {
	return connect.NewResponse(&barteringv1.CheckResponse{
		Status: barteringv1.ServingStatus_SERVING_STATUS_SERVING,
	}), nil
}
