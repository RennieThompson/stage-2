import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Admin dashboard",
  description: "Sales, orders and low-stock overview.",
};

export default function AdminDashboardPage() {
  return (
    <PagePlaceholder
      title="Admin dashboard"
      description="Order counts by status, recent orders and the low-stock list that uses the low-stock limit from store settings. Every admin action calls requireAdmin()."
      task="Task 9"
    />
  );
}