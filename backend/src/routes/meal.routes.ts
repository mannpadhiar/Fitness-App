import { Router } from "express";
import * as mealController from "../controllers/meal.controller.js";

const router = Router({ mergeParams: true });

// User's meals
router.get("/", mealController.getUserMeals);
router.post("/", mealController.createMeal);

// Single meal operations
router.get("/:id", mealController.getMeal);
router.put("/:id", mealController.updateMeal);
router.delete("/:id", mealController.deleteMeal);

// Meal items
router.post("/:mealId/items", mealController.addMealItem);

export default router;
