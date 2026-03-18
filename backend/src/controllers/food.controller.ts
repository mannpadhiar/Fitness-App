import { Request, Response } from "express";
import * as foodService from "../services/food.service.js";
import { createFoodSchema, updateFoodSchema } from "../validators/index.js";

export async function searchFoods(req: Request, res: Response) {
  try {
    const result = await foodService.searchFoods({
      search: req.query.search as string | undefined,
      source: req.query.source as string | undefined,
      page: req.query.page ? parseInt(req.query.page as string) : undefined,
      limit: req.query.limit ? parseInt(req.query.limit as string) : undefined,
    });
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getFood(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const food = await foodService.getFoodById(id as string);
    if (!food) {
      res.status(404).json({ error: "Food not found" });
      return;
    }
    res.json(food);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createFood(req: Request, res: Response) {
  try {
    const data = createFoodSchema.parse(req.body);
    const food = await foodService.createFood(data);
    res.status(201).json(food);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function updateFood(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const data = updateFoodSchema.parse(req.body);
    const food = await foodService.updateFood(id as string, data);
    res.json(food);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function deleteFood(req: Request, res: Response) {
  try {
    const { id } = req.params;
    await foodService.deleteFood(id as string);
    res.status(204).send();
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}
