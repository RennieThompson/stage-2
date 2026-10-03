import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Account",
  description: "Your account dashboard.",
};

export default function AccountDashboardPage() {
  return (
    <PagePlaceholder
      title="Account dashboard"
      description="A summary of your recent orders and a short profile card. Customers only ever read their own profile and orders."
      task="Task 7"
    />
  );
}