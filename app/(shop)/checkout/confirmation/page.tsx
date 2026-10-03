import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Order confirmation",
  description: "Your order reference and the next steps to pay.",
};

export default function CheckoutConfirmationPage() {
  return (
    <PagePlaceholder
      title="Order confirmation"
      description="The order reference (ORD-YYYY-NNNNNN), the order summary and the bank transfer instructions from store settings. The confirmation email is sent in Task 6."
      task="Task 5"
    />
  );
}