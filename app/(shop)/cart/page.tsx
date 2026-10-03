import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Cart",
  description: "Review the items in your shopping cart.",
};

export default function CartPage() {
  return (
    <PagePlaceholder
      title="Cart"
      description="Cart items, quantity controls, stock checks and totals. Guest carts live in an httpOnly cookie; signed-in carts belong to the customer."
      task="Task 4"
    />
  );
}