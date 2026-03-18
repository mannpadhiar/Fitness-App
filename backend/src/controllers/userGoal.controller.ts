import { Request, Response } from "express";
import * as userGoalService from "../services/userGoal.service.js";
import { createGoalSchema, updateGoalSchema } from "../validators/index.js";

export async function getUserGoals(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const activeOnly = req.query.active === "true";
    const goals = await userGoalService.getUserGoals(userId as string, activeOnly);
    res.json(goals);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function createGoal(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const data = createGoalSchema.parse(req.body);
    const goal = await userGoalService.createUserGoal(userId as string, data);
    res.status(201).json(goal);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}

export async function updateGoal(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const data = updateGoalSchema.parse(req.body);
    const goal = await userGoalService.updateUserGoal(id as string, data);
    res.json(goal);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}
