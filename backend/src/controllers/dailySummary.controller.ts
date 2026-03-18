import { Request, Response } from "express";
import * as dailySummaryService from "../services/dailySummary.service.js";

export async function getDailySummary(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const date = req.query.date as string | undefined;
    if (!date) {
      res.status(400).json({ error: "date query parameter is required" });
      return;
    }
    const summary = await dailySummaryService.getDailySummary(
      userId as string,
      date
    );
    if (!summary) {
      res.json({
        userId,
        date,
        totalCaloriesConsumed: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFats: 0,
        totalCaloriesBurned: 0,
      });
      return;
    }
    res.json(summary);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}

export async function getDailySummaryRange(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const from = req.query.from as string | undefined;
    const to = req.query.to as string | undefined;
    if (!from || !to) {
      res.status(400).json({ error: "from and to query parameters are required" });
      return;
    }
    const summaries = await dailySummaryService.getDailySummaryRange(
      userId as string,
      from,
      to
    );
    res.json(summaries);
  } catch (error: any) {
    res.status(500).json({ error: error.message });
  }
}
