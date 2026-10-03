import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Admin orders",
  description: "Search, filter and update orders.",
};

export default function AdminOrdersPage() {
  return (
    <PagePlaceholder
      title="Orders"
      description="Search and filter orders by reference, status and payment status. Status changes go through the admin RPCs and add a row to order status history."
      task="Task 9"
    />
  );
}