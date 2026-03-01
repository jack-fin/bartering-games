import { createClient } from "@connectrpc/connect";
import { HealthService } from "../../../gen/bartering/v1/health_pb.js";
import { transport } from "./transport.js";

export const healthClient = createClient(HealthService, transport);
