import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Checkout",
  description: "Customer information, delivery details and order review.",
};

export default function CheckoutPage() {
  return (
    <PagePlaceholder
      title="Checkout"
      description="Customer information, delivery information and order review. Guests and signed-in customers can both place an order. The server reads every price from the database."
      task="Task 5"
    />
  );
}