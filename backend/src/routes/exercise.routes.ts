import { Router } from "express";
import * as exerciseController from "../controllers/exercise.controller.js";

const router = Router({ mergeParams: true });

// User's exercises (GET with ?date=YYYY-MM-DD)
router.get("/", exerciseController.getUserExercises);
router.post("/", exerciseController.createExercise);

export default router;
