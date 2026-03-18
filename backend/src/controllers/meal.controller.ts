import { Request, Response } from "express";
import * as mealService from "../services/meal.service.js";
import { createMealSchema, addMealItemSchema } from "../validators/index.js";

export async function getUserMeals(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const meals = await mealService.getUserMeals(userId as string, {
      date: req.query.date as string | undefined,
      mealType: req.query.type as string | undefined,
    });
    res.json(meals);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getMeal(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const meal = await mealService.getMealById(id as string);
    if (!meal) {
      res.status(404).json({ error: "Meal not found" });
      return;
    }
    res.json(meal);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createMeal(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const data = createMealSchema.parse(req.body);
    const meal = await mealService.createMeal(userId as string, data);
    res.status(201).json(meal);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function updateMeal(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const meal = await mealService.updateMeal(id as string, req.body);
    res.json(meal);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function deleteMeal(req: Request, res: Response) {
  try {
    const { id } = req.params;
    await mealService.deleteMeal(id as string);
    res.status(204).send();
  } catch (error: any) {
    if (error.message === "Meal not found") {
      res.status(404).json({ error: "Meal not found" });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function addMealItem(req: Request, res: Response) {
  try {
    const { mealId } = req.params;
    const data = addMealItemSchema.parse(req.body);
    const item = await mealService.addMealItem(mealId as string, data);
    res.status(201).json(item);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    if (error.message === "Meal not found") {
      res.status(404).json({ error: "Meal not found" });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function removeMealItem(req: Request, res: Response) {
  try {
    const { id } = req.params;
    await mealService.removeMealItem(id as string);
    res.status(204).send();
  } catch (error: any) {
    if (error.message === "Meal item not found") {
      res.status(404).json({ error: "Meal item not found" });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}
