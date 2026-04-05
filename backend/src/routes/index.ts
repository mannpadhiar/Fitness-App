import { Router } from "express";
import * as mealController from "../controllers/meal.controller.js";
import * as goalController from "../controllers/userGoal.controller.js";
import * as exerciseController from "../controllers/exercise.controller.js";
import userRoutes from "./user.routes.js";
import weightHistoryRoutes from "./weightHistory.routes.js";
import userGoalRoutes from "./userGoal.routes.js";
import foodRoutes from "./food.routes.js";
import mealRoutes from "./meal.routes.js";
import dailyStepRoutes from "./dailyStep.routes.js";
import dailySummaryRoutes from "./dailySummary.routes.js";
import exerciseRoutes from "./exercise.routes.js";

const router = Router();

// User routes
router.use("/users", userRoutes);

// Nested user routes
router.use("/users/:userId/weight-history", weightHistoryRoutes);
router.use("/users/:userId/goals", userGoalRoutes);
router.use("/users/:userId/meals", mealRoutes);
router.use("/users/:userId/daily-steps", dailyStepRoutes);
router.use("/users/:userId/daily-summary", dailySummaryRoutes);
router.use("/users/:userId/exercises", exerciseRoutes);

// Food routes (not user-scoped)
router.use("/foods", foodRoutes);

// Standalone meal operations
router.get("/meals/:id", mealController.getMeal);
router.put("/meals/:id", mealController.updateMeal);
router.delete("/meals/:id", mealController.deleteMeal);
router.post("/meals/:mealId/items", mealController.addMealItem);

// Standalone meal item deletion
router.delete("/meal-items/:id", mealController.removeMealItem);

// Standalone goal update
router.put("/goals/:id", goalController.updateGoal);

// Standalone exercise deletion
router.delete("/exercises/:id", exerciseController.deleteExercise);

export default router;
