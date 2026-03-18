import { Router } from "express";
import * as dailySummaryController from "../controllers/dailySummary.controller.js";

const router = Router({ mergeParams: true });

router.get("/", dailySummaryController.getDailySummary);
router.get("/range", dailySummaryController.getDailySummaryRange);

export default router;
