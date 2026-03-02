package handler

import (
	"context"

	"connectrpc.com/connect"

	pb "github.com/jack-fin/bartering-games/backend/gen/bartering/v1"
)

// HealthHandler implements the HealthService Connect handler.
type HealthHandler struct{}

func (h *HealthHandler) Check(
	_ context.Context,
	_ *connect.Request[pb.CheckRequest],
) (*connect.Response[pb.CheckResponse], error) {
	return connect.NewResponse(&pb.CheckResponse{}), nil
}
