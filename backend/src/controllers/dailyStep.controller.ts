import { Request, Response } from "express";
import * as dailyStepService from "../services/dailyStep.service.js";
import { upsertDailyStepsSchema } from "../validators/index.js";

export async function getDailySteps(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const result = await dailyStepService.getDailySteps(
      userId as string,
      req.query.date as string | undefined
    );
    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function upsertDailySteps(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const data = upsertDailyStepsSchema.parse(req.body);
    const record = await dailyStepService.upsertDailySteps(
      userId as string,
      data.steps,
      data.date
    );
    res.json(record);
  } catch (error: any) {
    if (error.name === "ZodError") {
      res.status(400).json({ error: "Validation failed", details: error.errors });
      return;
    }
    res.status(500).json({ error: error.message });
  }
}
