import { Request, Response } from "express";
import * as weightHistoryService from "../services/weightHistory.service.js";
import { addWeightSchema } from "../validators/index.js";

export async function getWeightHistory(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const history = await weightHistoryService.getWeightHistory(userId as string);
    res.json(history);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function addWeightEntry(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const data = addWeightSchema.parse(req.body);
    const entry = await weightHistoryService.addWeightEntry(
      userId as string,
      data.weightKg,
      data.recordedAt
    );
    res.status(201).json(entry);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}
