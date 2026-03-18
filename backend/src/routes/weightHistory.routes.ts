import { Router } from "express";
import * as whController from "../controllers/weightHistory.controller.js";

const router = Router({ mergeParams: true });

router.get("/", whController.getWeightHistory);
router.post("/", whController.addWeightEntry);

export default router;
