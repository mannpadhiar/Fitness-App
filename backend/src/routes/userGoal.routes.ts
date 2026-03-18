import { Router } from "express";
import * as goalController from "../controllers/userGoal.controller.js";

const router = Router({ mergeParams: true });

router.get("/", goalController.getUserGoals);
router.post("/", goalController.createGoal);

export default router;
