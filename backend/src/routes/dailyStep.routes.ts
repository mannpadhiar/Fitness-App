import { Router } from "express";
import * as dailyStepController from "../controllers/dailyStep.controller.js";

const router = Router({ mergeParams: true });

router.get("/", dailyStepController.getDailySteps);
router.post("/", dailyStepController.upsertDailySteps);

export default router;
