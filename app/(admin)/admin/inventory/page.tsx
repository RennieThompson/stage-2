import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Admin inventory",
  description: "Stock levels per variant.",
};

export default function AdminInventoryPage() {
  return (
    <PagePlaceholder
      title="Inventory"
      description="Stock per variant with the low-stock flag. Stock follows the stock policy in store settings: it is deducted when the admin confirms the order."
      task="Task 9"
    />
  );
}