import { getDataConnect, DataConnect } from "firebase/data-connect";
import { app } from "./config";

let dataConnect: DataConnect;

if (typeof window !== "undefined") {
  dataConnect = getDataConnect(app, {
    connector: "ecommerce",
    location: "us-east4", // TODO
    service: "oxela-auth-service", // TODO
  });
}

export { dataConnect };

// Réexporter les types et fonctions générés
export * from "./generated";

// Types personnalisés pour l'application
export interface CartItemWithProduct {
  id: string;
  quantity: number;
  product: {
    id: string;
    name: string;
    slug: string;
    price: number;
    imageUrl: string;
    stock: number;
  };
}

export interface OrderWithItems {
  id: string;
  orderNumber: string;
  status: string;
  total: number;
  createdAt: string;
  items: {
    id: string;
    quantity: number;
    priceAtTime: number;
    product: {
      name: string;
      imageUrl: string;
    };
  }[];
}
