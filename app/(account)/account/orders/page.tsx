import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Orders",
  description: "Your order history.",
};

export default function AccountOrdersPage() {
  return (
    <PagePlaceholder
      title="Orders"
      description="Your order history with the reference, date, total, order status and payment status. Guests cannot read orders."
      task="Task 7"
    />
  );
}