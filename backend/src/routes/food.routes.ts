import { Router } from "express";
import * as foodController from "../controllers/food.controller.js";

const router = Router();

router.get("/", foodController.searchFoods);
router.get("/:id", foodController.getFood);
router.post("/", foodController.createFood);
router.put("/:id", foodController.updateFood);
router.delete("/:id", foodController.deleteFood);

export default router;
